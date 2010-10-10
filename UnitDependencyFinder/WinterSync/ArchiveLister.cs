using System.Collections.Generic;
using System.IO;
using Tao.Lua;

namespace WinterSync
{
    public class ArchiveLister
    {
        #region Properties

        public Dictionary<string, string> Maps { get; private set; }
        public Dictionary<string, string> Mods { get; private set; }

        #endregion

        #region Constructors

        public ArchiveLister(string springPath)
        {
            Mods = new Dictionary<string, string>();
            Maps = new Dictionary<string, string>();
            var contentFolders = new[] {"mods", "maps", "base"};
            var L = SpringLua.GetLuaState(springPath);

            foreach (var folderPath in contentFolders) {
                foreach (var archivePath in Directory.GetFiles(Path.Combine(springPath, folderPath), "*")) {
                    if (!IsSpringArchive(archivePath)) continue;
                    foreach (var fileName in Archive.RawListFiles(archivePath)) {
                        if (IsModInfo(fileName)) {
                            var modName = SpringLua.ProtectedGetModName(L, archivePath);
                            if (modName != null) {
                                Mods.Remove(modName);
                                Mods[modName] = archivePath;
                            }
                        } else if (IsMap(fileName)) {
                            var mapName = Path.GetFileName(fileName);
                            Maps.Remove(mapName);
                            Maps[mapName] = archivePath;
                        }
                    }
                }
            }
            Lua.lua_close(L);
        }

        #endregion

        #region Other methods

        static bool IsMap(string fileName)
        {
            return fileName.ToLower().EndsWith(".smf");
        }

        static bool IsModInfo(string fileName)
        {
            var lowerFileName = fileName.ToLower();
            return lowerFileName == "modinfo.tdf" || lowerFileName == "modinfo.lua";
        }

        static bool IsSpringArchive(string archivePath)
        {
            var lowerArchivePath = archivePath.ToLower();
            return lowerArchivePath.EndsWith("sdz") || lowerArchivePath.EndsWith("sd7");
        }

        #endregion
    }
}