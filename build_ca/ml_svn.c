/* #include <apr_pools.h> */
#include <subversion-1/svn_types.h>
#include <subversion-1/svn_auth.h>
#include <subversion-1/svn_config.h>
#include <subversion-1/svn_client.h>
#include <subversion-1/svn_error.h>
#include <subversion-1/svn_compat.h>
#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/custom.h>
#include <stdbool.h>

svn_client_ctx_t *global_ctx;

value normal_variant;
value added_variant;
value modified_variant;
value deleted_variant;
value none_variant;
value file_variant;
value dir_variant;
value unknown_variant;

value ml_svn_init (value unit)
{
	CAMLparam1(unit);

	apr_pool_t *pool;
	svn_auth_provider_object_t *provider;
	apr_array_header_t *providers;
	svn_auth_baton_t *auth_baton;
	apr_hash_t *config;

	apr_initialize ();
	apr_pool_create (&pool, NULL);

	svn_client_create_context(&global_ctx, pool);
	svn_config_get_config(&config, NULL, pool);
	global_ctx->config = config;

	provider = apr_pcalloc (pool, sizeof(*provider));
	providers = apr_array_make (pool, 1, sizeof (*provider));
	svn_auth_get_username_provider(&provider, pool);
	*(svn_auth_provider_object_t **)apr_array_push (providers) = provider;
	
	svn_auth_open (&auth_baton, providers, pool);
	(global_ctx)->auth_baton = auth_baton;

	normal_variant = hash_variant("Normal");
	added_variant = hash_variant("Added");
	modified_variant = hash_variant("Modified");
	deleted_variant = hash_variant("Deleted");
	none_variant = hash_variant("None");
	file_variant = hash_variant("File");
	dir_variant = hash_variant("Dir");
	unknown_variant = hash_variant("Unknown");

	CAMLreturn (Val_unit);
}

// Svn.summarize

svn_error_t *ml_svn_summarize_callback (const svn_client_diff_summarize_t *diff, void *baton, apr_pool_t *pool)
{
	CAMLparam0 ();
	CAMLlocal2 (mcallback, tuple);

	mcallback = *((value *) baton);
	tuple = caml_alloc_tuple(4);

	Store_field(tuple, 0, caml_copy_string(diff->path));

	switch (diff->summarize_kind) {
		
	case svn_client_diff_summarize_kind_normal: Store_field(tuple, 1, normal_variant); break;
	case svn_client_diff_summarize_kind_added: Store_field(tuple, 1, added_variant); break;
	case svn_client_diff_summarize_kind_modified: Store_field(tuple, 1, modified_variant); break;
	case svn_client_diff_summarize_kind_deleted: Store_field(tuple, 1, deleted_variant); break;
		
	}
	
	switch (diff->node_kind) {
		
	case svn_node_none: Store_field(tuple, 2, none_variant); break;
	case svn_node_file: Store_field(tuple, 2, file_variant); break;
	case svn_node_dir: Store_field(tuple, 2, dir_variant); break;
	case svn_node_unknown: Store_field(tuple, 2, unknown_variant); break;
		
	}
	
	Store_field(tuple, 3, Val_bool(diff->prop_changed));

	caml_callback(mcallback, tuple);
	
	CAMLreturnT(svn_error_t *, NULL);
}

value ml_svn_client_summarize (value source_path, value source_revision_num, value dest_path, value dest_revision_num, value callback)
{

	CAMLparam5 (source_path, source_revision_num, dest_path, dest_revision_num, callback);
	CAMLlocal1 (error_message);

	svn_opt_revision_t *source_revision;
	svn_opt_revision_t *dest_revision;
	svn_error_t *error;
	apr_pool_t *pool;

	apr_pool_create (&pool, NULL);

	source_revision = apr_pcalloc (pool, sizeof(*source_revision));
	dest_revision = apr_pcalloc (pool, sizeof(*dest_revision));
	source_revision->kind = svn_opt_revision_number;
	dest_revision->kind = svn_opt_revision_number;
	source_revision->value.number = Int_val(source_revision_num);
	dest_revision->value.number = Int_val(dest_revision_num);
	
	error = svn_client_diff_summarize2(
		String_val(source_path),
		source_revision,
		String_val(dest_path),
		dest_revision,
		svn_depth_infinity,
		true,
		NULL,
		&ml_svn_summarize_callback,
		&callback,
		global_ctx,
		pool
	);
	
	if (error != NULL) {
		caml_failwith(error->message);
	}

	apr_pool_destroy(pool);
	CAMLreturn (Val_unit);
}

// Svn.cat

svn_error_t *ml_svn_write_callback(void *baton, const char *data, apr_size_t *len)
{
	CAMLparam0 ();
	CAMLlocal2 (mcallback, string);

	mcallback = *((value *) baton);
	string = caml_alloc_string(*len);
	memcpy(String_val(string), data, *len);

	caml_callback (mcallback, string);
	
	CAMLreturnT(svn_error_t *, NULL);
}

value ml_svn_client_cat(value source, value revision_num, value callback)
{
	CAMLparam3 (source, revision_num, callback);
	
	svn_opt_revision_t *revision;
	svn_opt_revision_t *peg;
	svn_stream_t *stream;
	svn_error_t *error;
	apr_pool_t *pool;

	apr_pool_create (&pool, NULL);
	revision = apr_pcalloc (pool, sizeof(*revision));
	peg = apr_pcalloc (pool, sizeof(*peg));
	revision->kind = svn_opt_revision_number;
	revision->value.number = Int_val(revision_num);
	peg->kind = svn_opt_revision_unspecified;

	stream = svn_stream_create(&callback, pool);
	svn_stream_set_baton(stream, &callback);
	svn_stream_set_write(stream, &ml_svn_write_callback);

	error = svn_client_cat2(
		stream,
		String_val(source),
		revision,
		revision,
		global_ctx,
		pool
	);

	if (error != NULL) {
		caml_failwith(error->message);
	}

	apr_pool_destroy(pool);														
	CAMLreturn (Val_unit);
}

// Svn.log

svn_error_t *log_callback (void *baton, svn_log_entry_t *log_entry, apr_pool_t *pool)
{
	CAMLparam0 ();
	CAMLlocal5 (mcallback, tuple, camlauthor, camldate, camlmessage);

	const char *author;
	const char *date;
	const char *message;

	mcallback = *((value *) baton);

	svn_compat_log_revprops_out(&author, &date, &message, log_entry->revprops);


	if (author == NULL) camlauthor = caml_alloc_string(0);
	else camlauthor = caml_copy_string(author);
	if (date == NULL) camldate = caml_alloc_string(0);
	else camldate = caml_copy_string(date);
	if (message == NULL) camlmessage = caml_alloc_string(0);
	else camlmessage = caml_copy_string(message);

	tuple = caml_alloc_tuple(3);
	Store_field(tuple, 0, camlauthor);
	Store_field(tuple, 1, camldate);
	Store_field(tuple, 2, camlmessage);
	
	caml_callback(mcallback, tuple);

	CAMLreturnT(svn_error_t *, NULL);
}

value ml_svn_client_log(value url, value path, value revision_num, value mcallback)
{
	CAMLparam2 (url, revision_num);

	svn_opt_revision_t *revision;
	svn_opt_revision_t *peg;
	svn_error_t *error;
	apr_pool_t *pool;
	apr_array_header_t *targets;
	apr_array_header_t *revision_ranges;

	apr_pool_create (&pool, NULL);

	revision = apr_pcalloc (pool, sizeof(*revision));
	peg = apr_pcalloc (pool, sizeof(*peg));
	revision->kind = svn_opt_revision_number;
	revision->value.number = Int_val(revision_num);

	revision_ranges = apr_array_make(pool, 2, sizeof(svn_opt_revision_t *));
	APR_ARRAY_PUSH(revision_ranges, svn_opt_revision_t *) = revision;
	APR_ARRAY_PUSH(revision_ranges, svn_opt_revision_t *) = revision;

	peg->kind = svn_opt_revision_unspecified;

	targets = apr_array_make(pool, 2, sizeof(char *));
	APR_ARRAY_PUSH(targets, char *) = String_val(url);
	APR_ARRAY_PUSH(targets, char *) = String_val(path);

	error = svn_client_log5(
		targets,
		revision,
		revision_ranges,
		1,
		false,
		false,
		false,
		NULL,
		&log_callback,
		&mcallback,
		global_ctx,
		pool
	);

	if (error != NULL) {
		caml_failwith(error->message);
	}

	apr_pool_destroy(pool);
	CAMLreturn (Val_unit);
}
