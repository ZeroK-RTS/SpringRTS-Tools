using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Text;
using LuaInterface;
using System.Collections;
using System.Windows.Forms;
using System.Drawing;

namespace SpringModEdit
{
  class TableProxy
  {
    public enum TableType {UnitDef, WeaponDef, FeatureDef, Other};

    TableType tableType = TableType.Other;
    ListDictionary table;
    private Lua lua;
    public TableProxy(LuaTable table, Lua lua):this(table, TableType.Other,lua) {
    }
    public TableProxy(LuaTable table, TableType tableType, Lua lua)
    {
        this.table = lua.GetTableDict(table);
        this.tableType = tableType;
        this.lua = lua;
    }


    
    private static string GetIndentString(int indent) {
      string s = "";
      for (int i = 0; i < indent; ++i) s += " ";
      return s;
    }


    
    private static int GetSortLevel(DictionaryEntry a) {
      if (a.Key is string) {
        string s = (string)a.Key;
        if (s == "unitname") return 0;
        else if (s == "name") return 1;
        else if (s == "description") return 2;
        else if (s == "default") return 3;
        else if (s == "def") return 4;
        else if (s == "weapons") return int.MaxValue - 10;
        else if (s == "weaponDefs") return int.MaxValue - 9;
        else if (s == "featureDefs") return int.MaxValue - 8;
      } else if (a.Key is double) return (int)(double)a.Key;
      return int.MaxValue - 11;
    }
    
    private static int SortCompare(DictionaryEntry a, DictionaryEntry b) {
      int la = GetSortLevel(a);
      int lb = GetSortLevel(b);
      if (la == lb) return a.Key.ToString().CompareTo(b.Key.ToString()); else 
      return la.CompareTo(lb);
      
    }


    public virtual void Changes(RichTextBox rb, string tblName, LuaTable againstTable, Lua againstLua) {
      ListDictionary against = againstLua.GetTableDict(againstTable);
      List<DictionaryEntry> items = new List<DictionaryEntry>();
      int maxlen = 0;
      bool allNumber = true;
      int cnt = 1;
      foreach (DictionaryEntry de in table) {
        items.Add(de);
        int len = de.Key.ToString().Length;
        if (len > maxlen) maxlen = len;
        if (!(de.Key is Double) || (int)(double)de.Key != cnt) allNumber = false;
        cnt++;
      }
      bool firstLine  = true;

      foreach (DictionaryEntry de in items) {
        if (against[de.Key] == null) {
          
          StringBuilder sb = new StringBuilder();
          if (firstLine) {
            rb.SelectionColor = Color.Black;
            rb.AppendText("\r\n=============================\r\n" + tblName + "\r\n=============================\r\n");
            firstLine = false;
          }
          rb.SelectionColor = Color.Green;
          FormatEntry(sb, maxlen, allNumber, 0, de);
          sb.AppendLine();
          rb.SelectedText = sb.ToString();
        }  else if (de.Value != null && against[de.Key].ToString() != de.Value.ToString() && !(de.Value is LuaTable)) {
          if (firstLine) {
            rb.SelectionColor = Color.Black;
            rb.AppendText("\r\n=============================\r\n" + tblName + "\r\n=============================\r\n");
            firstLine = false;
          }

          rb.SelectionColor = Color.Blue;
          StringBuilder sb = new StringBuilder();
          FormatEntry(sb, maxlen, allNumber, 0, de);
          sb.Append("  <- ");
          sb.AppendFormat("{0}", against[de.Key]);
          sb.AppendLine();
          rb.SelectedText = sb.ToString();
        }
      }

      foreach (DictionaryEntry de in against) {
        if (table[de.Key] == null) {
          if (firstLine) {
            rb.SelectionColor = Color.Black;
            rb.AppendText("\r\n=============================\r\n" + tblName + "\r\n=============================\r\n");
            firstLine = false;
          }
          rb.SelectionColor = Color.Red;
          StringBuilder sb = new StringBuilder();
          FormatEntry(sb, maxlen, allNumber, 0, de);
          sb.AppendLine();
          rb.SelectedText = sb.ToString();
        }
      }

      foreach (DictionaryEntry de in table) {
        if (against[de.Key] != null && de.Value is LuaTable) {
          new TableProxy((LuaTable)de.Value, lua).Changes(rb, tblName + "/" + de.Key, (LuaTable)against[de.Key], againstLua);
        }

      }

    }


    
    public static string Export(LuaTable table, int indent) {
      StringBuilder sb = new StringBuilder();
      List<DictionaryEntry> items = new List<DictionaryEntry>();
      int maxlen = 0;
      bool allNumber = true;
      int cnt = 1;
      foreach (DictionaryEntry de in table) {
        items.Add(de);
        int len = de.Key.ToString().Length;
        if (len > maxlen) maxlen = len;
        if (!(de.Key is Double) || (int)(double)de.Key != cnt) allNumber = false;
        cnt++;
      }

      items.Sort(SortCompare);

      sb.Append("{\r\n");

      string ind = GetIndentString(indent + 2);
      foreach (DictionaryEntry de in items) {
        if (de.Value is LuaTable) sb.AppendLine();
        sb.Append(ind);

        FormatEntry(sb, maxlen, allNumber, indent, de);

        sb.Append(",\r\n");
        if (de.Value is LuaTable) sb.AppendLine();
      }

      ind = GetIndentString(indent);
      sb.Append(ind + "}");
      return sb.ToString();
    }


    private static void FormatEntry(StringBuilder sb, int maxlen, bool allNumber, int indent, DictionaryEntry de) {
      if (de.Key is string) {
        string s = (string)de.Key;
        if (s == "else") s = "[\"else\"]";
        sb.AppendFormat("{0,-" + maxlen + "} = ", s);
      } else if (de.Key is double) {
        if (!allNumber) sb.AppendFormat("[{0,-" + maxlen + "}] = ", (de.Key.ToString()));
      } else {
        sb.AppendFormat("{0,-" + maxlen + "} = ", (de.Key.ToString()));
      }

      if (de.Value is string) {
        sb.AppendFormat("[[{0}]]", (string)de.Value);
      } else if (de.Value is LuaTable) {
          sb.Append(Export((LuaTable)de.Value ,indent + 2));
      } else if (de.Value is bool) {
        if ((bool)de.Value) sb.Append("true"); else sb.Append("false");
      } else {
        sb.Append(de.Value.ToString());
      }

    }
  }
}
