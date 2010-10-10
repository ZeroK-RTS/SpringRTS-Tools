using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using Tao.Lua;

namespace WinterSync
{
    /// <summary>
    /// Lua utilities for reading spring archives
    /// </summary>
    static class SpringLua
    {
        #region Public methods


        static string FindModInfo(Archive archive, string extension)
        {
            return archive.ListFiles().FirstOrDefault(fileName => fileName.ToLower() == "modinfo." + extension);
        }

        static string GetTdfField(IntPtr L, string fieldName, string archivePath)
        {
            var archive = Archive.Open(archivePath);
            var tdfFile = FindModInfo(archive, "tdf");
            if (tdfFile != null) {
                var modInfoTable = GetTdfTableFromString(L, Archive.ExtractTextFile(archivePath, tdfFile));
                if (modInfoTable[0] is LuaNil) throw new Exception(String.Format("Error in file {0}: {1}", archivePath, modInfoTable[1]));
                var modInfo = modInfoTable[0].GetField("mod");
                if (modInfo == null) return null;
                var field = modInfo.GetField(fieldName);
                if (field == null) return null;
                return field.ToString();
            }
            var luaFile = FindModInfo(archive, "lua");
            if (luaFile != null) {
                var modinfo = Archive.ExtractTextFile(archivePath, luaFile);
                var result = CLua.TraceDoString(L, 1, modinfo)[0].GetField(fieldName);
                if (result == null) return null;
                return result.ToString();
            }
            return null;
        }

        static LuaValue[] GetTdfTableFromString(IntPtr L, string fileString)
        {
            Lua.lua_getglobal(L, "TDFparser"); // push the parser table on the stack
            Lua.lua_getfield(L, -1, "ParseText"); // push the parse string function
            var ret = CLua.TraceCall(L, 2, new LuaString(fileString));
            LuaValue.Pop(L, 1);
            return ret;
        }

        public static string GetModName(IntPtr L, string path)
        {
            var name = GetTdfField(L, "name", path);
            if (name == null) return null;
            var version = GetTdfField(L, "version", path);
            if (version == null) return name;
            if (name.EndsWith(version)) return name;
            return name + " " + version;
        }

        public static string ProtectedGetModName(IntPtr L, string path)
        {
            //try {
                return GetModName(L, path);
            //} catch (Exception e) {
            //    Debug.WriteLine("Exception while getting mod name: " + e.GetType().Name + " " + e.Message);
            //    return null;
            //}
        }

        #endregion

        #region Other methods

        ///<summary>
        /// creates a lua state and registers the TDF parser
        ///</summary>
        public static IntPtr GetLuaState(string springPath)
        {
            if (Path.HasExtension(springPath)) throw new Exception("Invalid spring path");
            var L = Lua.luaL_newstate();
            Lua.luaL_openlibs(L);
            var springContent = Path.Combine(springPath, @"base\springcontent.sdz");
            var tdfParserString = Archive.ExtractTextFile(springContent, "gamedata/parse_tdf.lua");
            CLua.DoStringPushReturn(L, tdfParserString, new ConstantResults(1));
            Lua.lua_setglobal(L, "TDFParser");
            return L;
        }


        /// <summary>
        /// creates a lua state and registers functions commonly used in lua defs   
        /// </summary>
        static IntPtr GetLuaStpringState(Dictionary<string, IArchiveFileData> fileMap)
        {
            var L = Lua.luaL_newstate();
            Lua.luaL_openlibs(L);

            // it seems CA makes lowerkeys global, so lets do the same

            // push the system table
            CLua.DoStringPushReturn(L, fileMap["gamedata/system.lua"].Text, new ConstantResults(1));
            // get the lowerkeys field from the system table and push it
            Lua.lua_pushstring(L, "lowerkeys");
            Lua.lua_gettable(L, -2);
            // set the lowerkeys function as global
            Lua.lua_setglobal(L, "lowerkeys");

            Lua.lua_CFunction VFS_Include = l =>
                                                {
                                                    var path = CLua.ExpectArgs(l, 1)[0].ToString();
                                                    IArchiveFileData file;
                                                    if (!fileMap.TryGetValue(path, out file)) throw new Exception("path not found: " + path);
                                                    CLua.DoStringPushReturn(l, file.Text, new ConstantResults(1));
                                                    return 1;
                                                };
            Lua.lua_CFunction VFS_LoadFile = l =>
                                                 {
                                                     var path = CLua.ExpectArgs(l, 1)[0].ToString();
                                                     IArchiveFileData file;
                                                     if (!fileMap.TryGetValue(path, out file)) throw new Exception("path not found: " + path);
                                                     return CLua.ReturnValues(l, new LuaString(file.Text));
                                                 };
            Lua.lua_CFunction VFS_FileExists = l =>
                                                   {
                                                       var path = CLua.ExpectArgs(l, 1)[0].ToString();
                                                       return CLua.ReturnValues(l, new LuaBoolean(fileMap.ContainsKey(path)));
                                                   };

            Lua.lua_CFunction VFS_DirList = l =>
                                                {
                                                    var args = CLua.ExpectArgs(l, 2);
                                                    var path = args[0].ToString().ToLower();
                                                    var mask = args[1].ToString().ToLower().Substring(1);

                                                    var i = 0;
                                                    var files = from s in fileMap.Keys
                                                                where s.StartsWith(path) && s.EndsWith(mask)
                                                                let arrayIndex = new LuaNumber(i++)
                                                                select new KeyValuePair<LuaValue, LuaValue>(arrayIndex, new LuaString(s));
                                                    return CLua.ReturnValues(l, new LuaTable(files));
                                                };
            Lua.lua_CFunction Spring_TimeCheck = l =>
                                                     {
                                                         var desc = LuaValue.Read(l, 1).ToString();
                                                         Lua.lua_pushvalue(l, 2);
                                                         var sw = Stopwatch.StartNew();
                                                         CLua.TraceCallPushReturn(l, new ConstantResults(0));
                                                         Trace.TraceInformation(desc + " " + sw.Elapsed);
                                                         // call function on top, push return values on stack
                                                         return 0;
                                                     };

            Lua.lua_CFunction Spring_Echo = l => CLua.Print(s => Trace.WriteLine(s), l);


            // morphs defs crash if they can't figure out what kind of commander we're using (why do we need morph defs anyway, here?)
            Lua.lua_CFunction Spring_GetModOptions = l =>
                                                         {
                                                             var data = new KeyValuePair<LuaValue, LuaValue>(new LuaString("commtype"),
                                                                                                             new LuaString("default"));
                                                             return CLua.ReturnValues(l, new LuaTable(new[] {data}));
                                                         };

            var springFunctions = new List<KeyValuePair<LuaValue, LuaValue>>
                                      {
                                          new KeyValuePair<LuaValue, LuaValue>(new LuaString("TimeCheck"), new LuaFunction(Spring_TimeCheck)),
                                          new KeyValuePair<LuaValue, LuaValue>(new LuaString("Echo"), new LuaFunction(Spring_Echo)),
                                          new KeyValuePair<LuaValue, LuaValue>(new LuaString("GetModOptions"), new LuaFunction(Spring_GetModOptions)),
                                      };
            CLua.SetGlobal(L, "Spring", new LuaTable(springFunctions));

            var vfsFunctions = new List<KeyValuePair<LuaValue, LuaValue>>
                                   {
                                       new KeyValuePair<LuaValue, LuaValue>(new LuaString("Include"), new LuaFunction(VFS_Include)),
                                       new KeyValuePair<LuaValue, LuaValue>(new LuaString("LoadFile"), new LuaFunction(VFS_LoadFile)),
                                       new KeyValuePair<LuaValue, LuaValue>(new LuaString("FileExists"), new LuaFunction(VFS_FileExists)),
                                       new KeyValuePair<LuaValue, LuaValue>(new LuaString("DirList"), new LuaFunction(VFS_DirList)),
                                   };
            CLua.SetGlobal(L, "VFS", new LuaTable(vfsFunctions));
            return L;
        }

        #endregion
    }
}