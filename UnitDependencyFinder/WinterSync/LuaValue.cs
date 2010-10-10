using System;
using System.Collections.Generic;
using System.Linq;
using Tao.Lua;

namespace WinterSync
{
	public abstract class LuaValue
    {
        #region Public methods

        /// <summary>
        /// /// returns value that corresponds to a key from a LuaValue.Table map
        /// </summary>
        public LuaValue GetField(string key)
        {
            var table = this as LuaTable;
            if (table == null) throw new Exception("value is not table");
            var found = table.Values.FirstOrDefault(kvp => kvp.Key is LuaString && ((LuaString) kvp.Key).Value == key);
            return found.Value;
        }

        public string GetStringField(string key)
        {
            var field = GetField(key);
            if (field == null) throw new Exception("string field not found");
            return field.ToString();
        }

        public static LuaValue GetGlobal(IntPtr L, string name)
        {
            Lua.lua_getglobal(L, name);
            var ret = Read(L, -1);
            Pop(L, 1);
            return ret;
        }

        /// <summary>
        /// /// extracts the the values (and not the keys) from a LuaValue.Table
        /// </summary>
        public LuaValue[] GetLuaValues(string key)
        {
            var table = this as LuaTable;
            if (table == null) throw new Exception("value is not table");
            return table.Values.Select(kvp => kvp.Value).ToArray();
        }

        public static void Pop(IntPtr L, int n)
        {
            var top = Lua.lua_gettop(L);
            if (top < n) throw new Exception("Stack is too small to pop");
            Lua.lua_pop(L, n);
        }

        public abstract void Push(IntPtr L);

        public static LuaValue Read(IntPtr L, int n)
        {
            var type = Lua.lua_type(L, n);
            switch (type) {
                case Lua.LUA_TNUMBER:
                    return new LuaNumber(Lua.lua_tonumber(L, n));
                case Lua.LUA_TSTRING:
                    return new LuaString(Lua.lua_tostring(L, n));
                case Lua.LUA_TBOOLEAN:
                    return new LuaBoolean(Lua.lua_toboolean(L, n));
                case Lua.LUA_TFUNCTION:
                    return new LuaFunction(Lua.lua_tocfunction(L, n));
                case Lua.LUA_TTABLE:
                    return new LuaTable(L, n);
                case Lua.LUA_TNIL:
                    return new LuaNil();
                case Lua.LUA_TNONE:
                    return new LuaNoValue();
                case Lua.LUA_TLIGHTUSERDATA:
                    return new LuaLightUserData();
                case Lua.LUA_TTHREAD:
                    return new LuaThread();
                case Lua.LUA_TUSERDATA:
                    return new LuaUserData();
                default:
                    throw new Exception("type of lua value not recognized");
            }
        }

        #endregion
    }

	public class LuaNumber : LuaValue
    {
        #region Properties

        public double Value { get; set; }

        #endregion

        #region Constructors

        public LuaNumber(double value)
        {
            Value = value;
        }

        #endregion

        #region Overrides

        public override void Push(IntPtr L)
        {
            Lua.lua_pushnumber(L, Value);
        }

        public override string ToString()
        {
            return Value.ToString();
        }

        #endregion
    }

	public class LuaString : LuaValue
    {
        #region Properties

        public string Value { get; set; }

        #endregion

        #region Constructors

        public LuaString(string value)
        {
            Value = value;
        }

        #endregion

        #region Public methods

        public static string Read(IntPtr L, int n)
        {
            var s = LuaValue.Read(L, n) as LuaString;
            if (s == null) throw new Exception("string expected but not found");
            return s.Value;
        }

        #endregion

        #region Overrides

        public override void Push(IntPtr L)
        {
            Lua.lua_pushstring(L, Value);
        }

        public override string ToString()
        {
            return Value;
        }

        #endregion
    }

	public class LuaBoolean : LuaValue
    {
        #region Properties

        public bool Value { get; set; }

        #endregion

        #region Constructors

        public LuaBoolean(bool value)
        {
            Value = value;
        }

        public LuaBoolean(int value)
        {
            Value = value != 0;
        }

        #endregion

        #region Overrides

        public override void Push(IntPtr L)
        {
            Lua.lua_pushboolean(L, CLua.CBool(Value));
        }

        #endregion
    }

	public class LuaTable : LuaValue
    {
        #region Properties

        public List<KeyValuePair<LuaValue, LuaValue>> Values { get; set; }

        #endregion

        #region Constructors

        public LuaTable(IEnumerable<KeyValuePair<LuaValue, LuaValue>> values)
        {
            Values = values.ToList();
        }

        /// <summary>
        /// expects table at position n
        /// </summary>
        public LuaTable(IntPtr L, int n)
        {
            Check(L, n);
            Values = new List<KeyValuePair<LuaValue, LuaValue>>();
            new LuaNil().Push(L);
            while (Lua.lua_next(L, n - 1) != 0) {
                var key = Read(L, -2);
                var value = Read(L, -1);
                Pop(L, 1);
                Values.Add(new KeyValuePair<LuaValue, LuaValue>(key, value));
            }
        }

        #endregion

        #region Public methods

        public static void Check(IntPtr L, int n)
        {
            var type = Lua.lua_type(L, n);
            if (type != Lua.LUA_TTABLE) throw new Exception("Expected table");
        }

        /// <summary>
        /// expects table on top
        /// returns field from table on top of stack
        /// </summary>
        public static LuaValue GetField(IntPtr L, LuaValue key)
        {
            Check(L, -1);
            key.Push(L);
            Lua.lua_gettable(L, -2);
            var ret = Read(L, -2);
            Pop(L, 1);
            return ret;
        }

        /// <summary>
        /// expects table on top
        /// </summary>
        public static void SetField(IntPtr L, LuaValue key, LuaValue value)
        {
            Check(L, -1);
            key.Push(L);
            value.Push(L);
            Lua.lua_settable(L, -3);
        }

        #endregion

        #region Overrides

        /// <summary>
        /// Does not support circular tables
        /// </summary>
        public override void Push(IntPtr L)
        {
            Lua.lua_newtable(L);
            Values.ForEach(kvp => SetField(L, kvp.Key, kvp.Value));
        }

        #endregion
    }

    class LuaFunction : LuaValue
    {
        #region Fields

        /// <summary>
        /// Store functions delegates here so the CLR won't garbage collect them (it can't know they are still in use in the Lua VM).
        /// </summary>
        static List<Lua.lua_CFunction> reserve = new List<Lua.lua_CFunction>();

        #endregion

        #region Properties

        public Lua.lua_CFunction Value { get; set; }

        #endregion

        #region Constructors

        public LuaFunction(Lua.lua_CFunction value)
        {
            Value = value;
        }

        #endregion

        #region Public methods

        public static LuaValue[] Call(IntPtr L, int resultNumber, params LuaValue[] arguments)
        {
            Check(L, -1);
            Array.ForEach(arguments, a => a.Push(L));
            CLua.CheckError(L, Lua.lua_pcall(L, arguments.Length, resultNumber, 0));
            var ret = Enumerable.Range(0, resultNumber).Select(n => Read(L, -n - 1)).ToArray();
            Array.Reverse(ret);
            return ret;
        }

        public static LuaValue[] CallGlobal(IntPtr L, string functionName, int resultNumber, params LuaValue[] arguments)
        {
            Lua.lua_getglobal(L, functionName);
            return Call(L, resultNumber, arguments);
        }

        public static void Check(IntPtr L, int n)
        {
            if (Lua.lua_type(L, n) != Lua.LUA_TFUNCTION) throw new Exception("expected function");
        }

        /// <summary>
        /// Store functions delegates so the CLR won't garbage collect them (it can't know they are still in use in the Lua VM).
        /// </summary>
        public void KeepAlive()
        {
            reserve.Add(Value);
        }

        #endregion

        #region Overrides

        public override void Push(IntPtr L)
        {
            KeepAlive();
            Lua.lua_pushcfunction(L, Value);
        }

        #endregion
    }

	public class LuaNil : LuaValue
    {
        #region Overrides

        public override void Push(IntPtr L)
        {
            Lua.lua_pushnil(L);
        }

        #endregion
    }

    class LuaNoValue : LuaValue
    {
        #region Overrides

        public override void Push(IntPtr L)
        {
            throw new NotImplementedException();
        }

        #endregion
    }

    class LuaThread : LuaValue
    {
        #region Overrides

        public override void Push(IntPtr L)
        {
            throw new NotImplementedException();
        }

        #endregion
    }

    class LuaUserData : LuaValue
    {
        #region Overrides

        public override void Push(IntPtr L)
        {
            throw new NotImplementedException();
        }

        #endregion
    }

    class LuaLightUserData : LuaValue
    {
        #region Overrides

        public override void Push(IntPtr L)
        {
            throw new NotImplementedException();
        }

        #endregion
    }

	public interface IResultCount {}

	public class ConstantResults : IResultCount
    {
        #region Properties

        public int Count { get; set; }

        #endregion

        #region Constructors

        public ConstantResults(int count)
        {
            Count = count;
        }

        #endregion
    }

    class VariableResults : IResultCount {}
}