using System;
using System.Collections.Generic;
using System.Linq;
using Tao.Lua;

namespace WinterSync
{
    public static class CLua
    {
        #region Public methods

        public static int CBool(bool b)
        {
            return b ? 1 : 0;
        }

        public static void CheckError(IntPtr L, int status)
        {
            if (status == 0) return; // no error
            var message = Lua.lua_tostring(L, -1) ?? "(no error message)";
            LuaValue.Pop(L, 1);
            switch (status) {
                case Lua.LUA_ERRFILE:
                    throw new Exception("File error: " + message);
                case Lua.LUA_ERRRUN:
                    throw new Exception("Runtime error: " + message);
                case Lua.LUA_ERRSYNTAX:
                    throw new Exception("Syntax error: " + message);
                case Lua.LUA_ERRMEM:
                    throw new Exception("Memory error: " + message);
                case Lua.LUA_ERRERR:
                    throw new Exception("Error function error: " + message);
                default:
                    throw new Exception("Invalid error code");
            }
        }

        /// <summary>
        /// loads chunk from string, runs it, pushes results on stack
        /// tao's dostring causes segfault, use this instead
        /// </summary>
        public static void DoString(IntPtr L, string s)
        {
            CheckError(L, Lua.luaL_loadstring(L, s));
            CheckError(L, Lua.lua_pcall(L, 0, Lua.LUA_MULTRET, 0));
        }

        public static IEnumerable<LuaValue> GetReverseStack(IntPtr L)
        {
            for (var i = Lua.lua_gettop(L); i <= 0; i--)
            {
                yield return LuaValue.Read(L, i);
            }
        }

        public static IEnumerable<LuaValue> GetStack(IntPtr L)
        {
            for (var i = 1; i <= Lua.lua_gettop(L); i++) {
                yield return LuaValue.Read(L, i);
            }
        }

        /// <summary>
        /// /// pops n values from stack, returns them  
        /// </summary>
        public static LuaValue[] ExpectArgs(IntPtr L, int n)
        {
            return GetStack(L).Take(n).ToArray();
        }

        /// <summary>
        /// pushes values on stack, returns number of pushed values
        /// </summary>
        public static int ReturnValues(IntPtr L, params LuaValue[] values)
        {
            Array.Reverse(values);
            Array.ForEach(values, v => v.Push(L));
            return values.Length;
        }

        public static void RegisterGlobalFunction(IntPtr L, string name, Lua.lua_CFunction f)
        {
            new LuaFunction(f).Push(L);
            Lua.lua_setglobal(L, name);
        }

        public static void SetGlobal(IntPtr L, string name, LuaValue value)
        {
            value.Push(L);
            Lua.lua_setglobal(L, name);
        }

        /// <summary>
        /// calls debug.traceback, pushes result
        /// </summary>
        public static int Traceback(IntPtr L)
        {
            Lua.lua_getglobal(L, "debug");
            Lua.lua_getfield(L, -1, "traceback");
            Lua.lua_pushvalue(L, 1); // pass error message
            Lua.lua_pushinteger(L, 2); // skip this function and traceback 
            Lua.lua_call(L, 2, 1);  // call debug.traceback
            return 1;
        }

        /// <summary>
        /// expects function on top
        /// runs function on top of stack, pushes return values, shows traceback in case of errors
        /// </summary>
        public static void TraceCallPushReturn(IntPtr L, IResultCount resultCount, params LuaValue[] arguments)
        {
            LuaFunction.Check(L, -1);
            Array.ForEach(arguments, a => a.Push(L));
            var constantResults = resultCount as ConstantResults;
            int results = constantResults != null ? constantResults.Count : Lua.LUA_MULTRET;
            var baseIndex = Lua.lua_gettop(L) - arguments.Length; // function index
            new LuaFunction(Traceback).Push(L); // push traceback function
            Lua.lua_insert(L, baseIndex); // put it under chunk and args
            var status = Lua.lua_pcall(L, arguments.Length, results, baseIndex);
            Lua.lua_remove(L, baseIndex); // remove traceback function
            if (status != 0) {
                Lua.lua_gc(L, Lua.LUA_GCCOLLECT, 0); // force a complete garbage collection in case of errors
                CheckError(L, status);
            }
        }

        /// <summary>
        /// expects function on top
        /// runs function on top of stack, returns values returned from function, shows traceback in case of errors
        /// </summary>
        public static LuaValue[] TraceCall(IntPtr L, int resultCount, params LuaValue[] arguments)
        {
            TraceCallPushReturn(L, new ConstantResults(resultCount), arguments);
            var ret = Enumerable.Range(0, resultCount).Select(n => LuaValue.Read(L, -n - 1)).ToArray();
            Array.Reverse(ret);
            LuaValue.Pop(L, resultCount);
            return ret;
        }


        /// <summary>
        /// expects function on top
        /// runs function on top of stack, no return values, shows traceback in case of errors
        /// </summary>
        public static void TraceCallNoReturn(IntPtr L, params LuaValue[] arguments)
        {
            TraceCallPushReturn(L, new ConstantResults(0), arguments);
        }

        /// <summary>
        /// /// runs a lua chunk loaded from a string, pushes returned values on stack, shows traceback in case of errors
        /// </summary>
        public static void DoStringPushReturn(IntPtr L, string s, IResultCount resultCount, params LuaValue[] arguments)
        {
            CheckError(L, Lua.luaL_loadstring(L, s));
            TraceCallPushReturn(L, resultCount, arguments);
        }


        /// <summary>
        /// runs a lua chunk loaded from a string, returns values returned from function, shows traceback in case of errors    
        /// </summary>
        public static LuaValue[] TraceDoString(IntPtr L, int resultCount, string s, params LuaValue[] arguments)
        {
            CheckError(L, Lua.luaL_loadstring(L, s));
            return TraceCall(L, resultCount, arguments);
        }

        /// <summary>
        /// /// sends arguments to output function, can be used to make print()-like functions
        /// </summary>
        public static int Print(Action<String> outputFunc, IntPtr L)
        {
            var n = Lua.lua_gettop(L); // number of arguments
            for (var i = 1; i <= n; i++) {
                Lua.lua_pushvalue(L, -1); // function to be called
                Lua.lua_pushvalue(L, i);  // value to print
                Lua.lua_call(L, 1, 1);
                var s = Lua.lua_tostring(L, 1);  // get result
                if (i > 1) outputFunc("\t");
                outputFunc(s);
                LuaValue.Pop(L, 1);
            }
            outputFunc("\n");
            return 0;
        }

        
    

        #endregion
    }
}