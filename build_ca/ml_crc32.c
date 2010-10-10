#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/custom.h>
#include <string.h>
#include <sys/types.h>
#include "7zCrc.h"

#include <stdio.h>

// CRC32

#define crc32_custom_val(v) (*((u_int32_t **) Data_custom_val(v)))

static void finalize_crc32_custom(value custom)
{
	u_int32_t *context = crc32_custom_val(custom);
	free(context);
}

static struct custom_operations crc32_custom_ops = {
	"org.detrino.crc32",
	finalize_crc32_custom,
	custom_compare_default,
	custom_hash_default,
	custom_serialize_default,
	custom_deserialize_default
};

static value alloc_crc32_custom(void)
{
	CAMLparam0 ();
	CAMLlocal1 (custom);
	u_int32_t *context;

	context = (u_int32_t *) malloc(sizeof(u_int32_t));
	CrcInit (context);

	custom = alloc_custom(&crc32_custom_ops, sizeof(u_int32_t *), 0, 1);
	crc32_custom_val(custom) = context;
	CAMLreturn (custom);
}

value ml_crc32_init (value unit) 
{
	CAMLparam1 (unit);
	InitCrcTable();
	CAMLreturn (unit);	
}

value ml_crc32_create (value unit) 
{
	CAMLparam1 (unit);
	CAMLlocal1 (custom);
	custom = alloc_crc32_custom();
	CAMLreturn (custom);	
}

value ml_crc32_update (value custom, value string)
{
	CAMLparam2 (custom, string);
	u_int32_t *context = crc32_custom_val(custom);
	CrcUpdate (context, String_val(string), caml_string_length(string));
	CAMLreturn (Val_unit);	
}

value ml_crc32_update_int32 (value custom, value uint)
{
	CAMLparam2 (custom, uint);
	u_int32_t *context = crc32_custom_val(custom);
	CrcUpdateUInt32 (context, Int32_val(uint));
	CAMLreturn (Val_unit);	
}

value ml_crc32_final(value custom)
{
	CAMLparam1 (custom);
	CAMLlocal1 (uint);
	
	u_int32_t *context = crc32_custom_val(custom);
	uint = caml_copy_int32(CrcGetDigest(context));

	CAMLreturn (uint);
}
