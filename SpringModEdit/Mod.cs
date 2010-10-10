#region using

using System;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Text;
using System.Windows.Forms;
using LuaInterface;

#endregion

namespace SpringModEdit
{
    public class Mod
    {
        #region Fields

        private string folder;
        private Lua lua = new Lua();

        #endregion

        #region Properties

        public string Folder
        {
            get { return folder; }
        }

        public Lua Lua
        {
            get { return lua; }
        }

        public LuaTable Units
        {
            get
            {
                if (lua["Units"] == null) lua.NewTable("Units");
                return (LuaTable) lua["Units"];
            }
        }

        #endregion

        #region Constructors

        public Mod()
        {
            lua.DoString("lowerkeys = function (x) return x end");
            lua.DoString("luanet.load_assembly(\"CaEdit\")\n");
            lua.DoString("Editor = luanet.import_type(\"SpringModEdit.LuaFunctions\")");
        }

        public Mod(string loadPath) : this()
        {
            folder = loadPath;
            foreach (var s in Directory.GetFiles(loadPath + "/units", "*.lua", SearchOption.TopDirectoryOnly)) {
				try {
					var stri = File.ReadAllText(s);

					var res = lua.DoString(stri);
					var t = res[0] as LuaTable;
					var enu = t.GetEnumerator();
					enu.Reset();
					enu.MoveNext();
					var de = (DictionaryEntry) enu.Current;
					string unitId = de.Key.ToString().ToLower();
					if (Units[unitId] != null) throw new ApplicationException("Unit " + unitId + " is defined multiple times");
					Units[unitId] = de.Value;
				} catch (Exception ex) {
					throw new ApplicationException("Error loading unit " + s, ex);
				}
            }
        }

        #endregion

        #region Public methods

        public string CloneUnit(string unitId, string data)
        {
            int cnt = 2;
            while (Units[unitId + cnt] != null) cnt++;
            RedefineUnit(data, unitId + cnt);
            return unitId + cnt;
        }

        public void DeleteUnit(string unitId)
        {
            Units[unitId] = null;
        }

        public List<ModSearchUnitResult> ExecuteScript(string script)
        {
            foreach (var s in Directory.GetFiles("../include/", "*.lua")) {
                try {
                    lua.DoFile(s);
                } catch (Exception ex) {
                    MessageBox.Show("Error in include " + s + ":\r\n" + ex.Message, "Include error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }

            List<ModSearchUnitResult> res = null;
            var ret = lua.DoString(script);
            if (ret != null && ret.Length > 0) {
                var rettab = ret[0] as LuaTable;
                if (rettab != null) {
                    res = new List<ModSearchUnitResult>();
                    foreach (DictionaryEntry de in rettab) if (Units[de.Value] != null) res.Add(new ModSearchUnitResult((LuaTable) Units[de.Value]));
                }
            }

            return res;
        }


        public Dictionary<string, List<string>> GetAllBuildOptions()
        {
            var opts = new Dictionary<string, List<string>>();
            foreach (DictionaryEntry de in Units) {
                var t = de.Value as LuaTable;
                var res = new List<string>();
                if (t == null) opts.Add(de.Key.ToString(), res);
                else {
                    var builds = t["buildoptions"] as LuaTable;
                    if (builds != null) foreach (var s in builds.Values) if (s is string) res.Add((string) s);
                    opts.Add(de.Key.ToString(), res);
                }
            }
            return opts;
        }


        public void GetChanges(Mod against, RichTextBox rb)
        {
            foreach (DictionaryEntry de in Units) {
                var ag = against.Units[de.Key] as LuaTable;
                if (ag != null) new TableProxy((LuaTable)de.Value, lua).Changes(rb, de.Key.ToString(), ag, against.lua);
                else {
                    rb.SelectionColor = Color.Green;
                    rb.SelectedText = "\r\n=== " + de.Key + "  added ===\r\n";
                }
            }

            foreach (DictionaryEntry de in against.Units) {
                var ag = Units[de.Key] as LuaTable;
                if (ag == null) {
                    rb.SelectionColor = Color.Red;
                    rb.SelectedText = "\r\n=== " + de.Key + "  deleted ===\r\n";
                }
            }
        }

        public List<string> GetUnitBuildOptions(string unitId)
        {
            var t = Units[unitId] as LuaTable;
            List<string> res = null;
            if (t == null) return res;
            res = new List<string>();
            var builds = t["buildoptions"] as LuaTable;
            if (builds != null) foreach (var s in builds.Values) if (s is string) res.Add((string) s);
            return res;
        }

        public string GetUnitDescription(string id)
        {
            var t = Units[id] as LuaTable;
            if (t != null) return t["name"] + " (" + t["description"] + ")";
            else return "";
        }

        public string GetUnitSource(string unitId)
        {
            return TableProxy.Export((LuaTable)Units[unitId],0);
        }

        public string RedefineUnit(string data)
        {
            return RedefineUnit(data, null);
        }

        public string RedefineUnit(string data, string unitId)
        {
            var ret = lua.DoString("return " + data);
            var t = ret[0] as LuaTable;
            if (unitId != null) t["unitname"] = unitId;
            else unitId = (string) t["unitname"];
            Units[unitId] = ret[0];
            return unitId;
        }

        public void Save(string path)
        {
            try {
                Directory.CreateDirectory(path);
            } catch {}
            ;
            try {
                Directory.CreateDirectory(path + "/units");
            } catch {}
            ;
            foreach (var s in Directory.GetFiles(path + "/units", "*.lua")) {
                try {
                    File.Delete(s);
                } catch {}
                ;
            }

            foreach (DictionaryEntry de in Units) {
                string key = de.Key.ToString().ToLower();
                string s = String.Format("unitDef = {0}\r\n\r\nreturn lowerkeys({{ {1} = unitDef }})\r\n", TableProxy.Export((LuaTable)de.Value,0), key);
                File.WriteAllText(path + "/units/" + key + ".lua", s);
            }
        }

        public List<ModSearchUnitResult> SearchUnits(string text, bool useLua)
        {
            var res = new List<ModSearchUnitResult>();

            if (!useLua) {
                var words = text.ToLower().Split(new[] {' ', '\r', '\n'}, StringSplitOptions.RemoveEmptyEntries);
                foreach (DictionaryEntry de in Units) {
                    bool hasWords = true;
                    foreach (var w in words) if (!HasWord((LuaTable) de.Value, w)) hasWords = false;
                    if (hasWords) res.Add(new ModSearchUnitResult((LuaTable) de.Value));
                }
            } else {
                var ret = lua.DoString(string.Format(@"local function Funct(Unit) {0}
          end

          local res = {{}}
          for k,v in pairs(Units) do if (Funct(v)) then table.insert(res, v) end end
          return res", text));
                var rettab = (LuaTable) ret[0];
                foreach (DictionaryEntry de in rettab) res.Add(new ModSearchUnitResult((LuaTable) de.Value));
            }
            res.Sort(delegate(ModSearchUnitResult a, ModSearchUnitResult b) { return a.id.CompareTo(b.id); });
            return res;
        }

        public void SetUnitBuildOptions(string unitId, List<string> options)
        {
            var t = Units[unitId] as LuaTable;
            if (t == null) return;
            lua.NewTable("_tmpEditor_" + unitId);
            var builds = lua.GetTable("_tmpEditor_" + unitId);
            int index = 1;
            foreach (var s in options) if (s != null) builds[index++] = s;
            t["buildoptions"] = builds;
        }

        #endregion

        #region Other methods

        private bool HasWord(LuaTable t, string w)
        {
            string s = (string) t["unitname"];
            if (s != null && s.ToLower().Contains(w)) return true;
            s = (string) t["name"];
            if (s != null && s.ToLower().Contains(w)) return true;
            s = (string) t["description"];
            if (s != null && s.ToLower().Contains(w)) return true;
            return false;
        }

        #endregion

        #region Nested type: ModSearchUnitResult

        public class ModSearchUnitResult
        {
            #region Properties

            public string description;
            public string id;

            #endregion

            #region Constructors

            public ModSearchUnitResult(string id, Mod mod)
            {
                this.id = id;
                description = id + " - " + mod.GetUnitDescription(id);
            }

            public ModSearchUnitResult(LuaTable de)
            {
                id = de["unitname"].ToString();
                description = id + " - " + (string) de["name"] + " (" + (string) de["description"] + ")";
            }

            #endregion

            #region Overrides

            public override string ToString()
            {
                return description;
            }

            #endregion
        }

        #endregion
    }
}