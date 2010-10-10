using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Tao.Lua;

namespace WinterSync
{
    public class Mod
    {
        #region Fields

        static string[] ignoredArchives = new[]
                                              {
                                                  "bitmaps.sdz", "cursors.sdz", "maphelper.sdz", "otacontent.sdz", "otacontent.sdz", "tacontent_v2.sdz",
                                                  "tatextures_v062.sdz", "tacontent.sdz"
                                              };

        IntPtr L;
        IDictionary<string, string> allMods;
        string modsPath;
        string springContentFile;
        string springPath;

        #endregion

        #region Properties

        public string ArchiveName { get; set; }
        public string[] DependencyPaths { get; set; }

        Dictionary<string, LazyFileData> FileMap { get; set; }
        public string Name { get; set; }

        #endregion

        #region Constructors

        public Mod(string name, IDictionary<string, string> allMods)
        {
            Name = name;
            ArchiveName = allMods[name];
            modsPath = Path.Combine(ArchiveName, "..");
            springPath = Path.Combine(modsPath, "..");
            var basePath = Path.Combine(springPath, "base");
            springContentFile = Path.Combine(basePath, "springcontent.sdz");
            L = SpringLua.GetLuaState(springPath);
            this.allMods = allMods;
            var dependencies = new List<string>();
            dependencies.Add(springContentFile);
            dependencies.AddRange(GetDependencyArchivePaths(ArchiveName));
            DependencyPaths = dependencies.ToArray();
            dependencies.Add(ArchiveName);
            FileMap = LoadArchives(dependencies);
            Lua.lua_close(L);
        }

        public static Mod FromSpringPath(string springPath, string modName)
        {
            var archives = new ArchiveLister(springPath);
            return new Mod(modName, archives.Mods);
        }

        #endregion

        #region Other methods

        string ToModName(string path)
        {
            if (path.ToLower().EndsWith(".sdz") || path.ToLower().EndsWith("sd7")) {
                return SpringLua.GetModName(L, path);
            }
            return path; // is already mod name
        }

        /// <summary>
        /// gets the list of dependencies from modinfo.lua
        /// </summary>
        string[] GetDependenciesFromLua(string archiveName, string fileName)
        {
            var modInfoFile = Archive.ExtractTextFile(archiveName, fileName);
            var results = CLua.TraceDoString(L, 1, modInfoFile);
            return results[0].GetLuaValues("depend").Select(v => v.ToString()).ToArray();
        }

        /// <summary>
        ///gets the list of dependencies from modinfo.tdf
        /// </summary>
        string[] GetDependenciesFromTdf(string archiveName, string fileName)
        {
            var modInfoText = Archive.ExtractTextFile(archiveName, fileName);
            Lua.lua_getglobal(L, "TDFparser"); // push the parser table on the stack
            Lua.lua_getfield(L, -1, "ParseText"); // push the parse string function
            var modInfoTable = CLua.TraceCall(L, 2, new LuaString(modInfoText)); // load the tdf from string
            var modInfo = modInfoTable[0].GetField("mod");

            // get all existing "dependN" fields
            var dependencies = new List<string>();
            var n = 0;
            while (true) {
                var field = modInfo.GetField("depend" + n++);
                if (field != null) dependencies.Add(field.ToString());
                else break;
            }
            LuaValue.Pop(L, 1);
            return dependencies.ToArray();
        }

        string[] GetDependencyArchiveNames(string archiveName)
        {
            var tdfInfo = GetModInfo(archiveName, "tdf");
            if (tdfInfo != null) return GetDependenciesFromTdf(archiveName, tdfInfo);
            var luaInfo = GetModInfo(archiveName, "lua");
            if (luaInfo != null) return GetDependenciesFromLua(archiveName, luaInfo);
            throw new Exception("no modinfo found");
        }

        /// <summary>
        /// gets all dependencies from an archive recursively
        /// </summary>
        string[] GetDependencyArchivePaths(string archiveName)
        {
            var archivePaths = from dependencyName in GetDependencyArchiveNames(archiveName)
                               where IsUsefulArchive(dependencyName)
                               select ToArchivePath(dependencyName)
                               into archivePath where IsUsefulArchive(archivePath) select archivePath;
            var paths = archivePaths.ToArray();
            return paths.Concat(paths.SelectMany(p => GetDependencyArchivePaths(p))).ToArray();
        }

        static string GetModInfo(string archiveName, string extension)
        {
            return Archive.ListFiles(archiveName).FirstOrDefault(f => f.ToLower() == "modinfo." + extension);
        }

        bool IsUsefulArchive(string name)
        {
            return !ignoredArchives.Any(path => path.EndsWith(name));
        }

        /// <summary>
        /// Make a dictionary with all the files in the VFS
        /// </summary>
        Dictionary<string, LazyFileData> LoadArchives(IEnumerable<string> archives)
        {
            var fileMap = new Dictionary<string, LazyFileData>();
            foreach (var archiveName in archives) {
                var archive = Archive.Open(archiveName);
                var fileName = archiveName.ToLower().Replace("\\", "/");
                var fileData = new LazyFileData(archiveName, archive);
                fileMap.Remove(fileName);
                fileMap[fileName] = fileData;
            }
            return fileMap;
        }

        /// <summary>
        /// /// translates a mod name or mod archive to a mod archive name
        /// </summary>
        string ToArchivePath(string name)
        {
            var path = name.EndsWith(".sd7") ? allMods[name] : name;
            return modsPath + "\\" + path;
        }

        #endregion
    }
}