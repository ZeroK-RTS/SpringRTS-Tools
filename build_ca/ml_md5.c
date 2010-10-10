#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/custom.h>
#include <stdbool.h>
#include <apr-1.0/apr_md5.h>

// MD5

#define md5_custom_val(v) (*((apr_md5_ctx_t **) Data_custom_val(v)))

static void finalize_md5_custom(value custom)
{
	apr_md5_ctx_t *context = md5_custom_val(custom);
	free(context);
}

static struct custom_operations md5_custom_ops = {
	"org.detrino.md5",
	finalize_md5_custom,
	custom_compare_default,
	custom_hash_default,
	custom_serialize_default,
	custom_deserialize_default
};

static value alloc_md5_custom(void)
{
	CAMLparam0 ();
	CAMLlocal1 (custom);
	apr_md5_ctx_t *context;

	context = (apr_md5_ctx_t *) malloc(sizeof(apr_md5_ctx_t));
	apr_md5_init (context);

	custom = alloc_custom(&md5_custom_ops, sizeof(apr_md5_ctx_t *), 0, 1);
	md5_custom_val(custom) = context;
	CAMLreturn (custom);
}

value ml_md5_create (value unit) 
{
	CAMLparam1 (unit);
	CAMLlocal1 (custom);
	custom = alloc_md5_custom();
	CAMLreturn (custom);	
}

value ml_md5_update (value custom, value string)
{
	CAMLparam2 (custom, string);
	apr_md5_ctx_t *context = md5_custom_val(custom);
	apr_md5_update (context, String_val(string), caml_string_length(string));
	CAMLreturn (Val_unit);	
}

value ml_md5_final(value custom)
{
	CAMLparam1 (custom);
	CAMLlocal1 (string);
	
	apr_md5_ctx_t *context = md5_custom_val(custom);
	string = caml_alloc_string(APR_MD5_DIGESTSIZE);
	apr_md5_final ((unsigned char *) String_val(string), context);
	CAMLreturn (string);
}
