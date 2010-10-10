#include <string.h>
#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/custom.h>
#include <lua5.1/lua.h>
#include <lua5.1/lualib.h>
#include <lua5.1/lauxlib.h>

value ml_lua_modinfo (value string) 
{
	CAMLparam1 (string);
	CAMLlocal4 (name, version, depends, tuple);
	int err, i, n;

	lua_State *L = luaL_newstate();
	luaL_openlibs(L);
	err = luaL_dostring (L, String_val(string));
	if (err != 0) {
		caml_failwith("Lua.modinfo");
	}

	name = caml_alloc_string(0);
	version = caml_alloc_string(0);
	depends = caml_alloc_tuple(0);

	lua_pushnil(L);
	while (lua_next(L, -2) != 0) {
		const char *s = lua_tostring(L, -2);

		// Get name string
		if (strcasecmp(s, "name") == 0) { 
			const char *s = lua_tostring(L, -1);
			name = caml_copy_string(s);
		}

		// Get depends array
		else if (strcasecmp(s, "depend") == 0) {
			lua_pushstring(L, "table");
			lua_gettable(L, LUA_GLOBALSINDEX);

			lua_pushstring(L, "getn");
			lua_gettable(L, -2);

			lua_pushvalue(L, -3);
			lua_call(L, 1, 1);
			n = lua_tonumber(L, -1);
			lua_pop(L, 2);

			depends = caml_alloc_tuple(n);

			i = 0;	
			lua_pushnil(L);
			while (lua_next(L, -2) != 0) {
				const char *s = lua_tostring(L, -1);
				Store_field(depends, i, caml_copy_string(s));
				i++;
				lua_pop(L, 1);
			}
		}

		// Get version string
		else if (strcasecmp(s, "version") == 0) {
			const char *s = lua_tostring(L, -1);
			version = caml_copy_string(s);
		}

		lua_pop(L, 1);
	}

	tuple = caml_alloc_tuple(3);
	Store_field(tuple, 0, name);
	Store_field(tuple, 1, version);
	Store_field(tuple, 2, depends);

	CAMLreturn (tuple);
}

