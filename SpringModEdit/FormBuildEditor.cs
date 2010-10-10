using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace SpringModEdit
{
  public partial class FormBuildEditor : Form
  {
    private Mod mod;
    public Mod Mod
    {
      get { return mod; }
      set
      {
        mod = value;
      }
    }


    Dictionary<string, List<string>> builds = new Dictionary<string, List<string>>();
    string selectedUnit = "armcom";

    public event EventHandler BuildOptionsChanged;



    public enum BuildsMode { Builds, BuiltBy };

    public BuildsMode DisplayMode = BuildsMode.Builds;


    public FormBuildEditor()
    {
      InitializeComponent();
    }



    public void SelectUnit(string id)
    {
      selectedUnit = id;
      lbUnit.Text = id + " - " + mod.GetUnitDescription(id);
      FillOptions();
    }

    public void ReloadBuildTree()
    {
      builds = mod.GetAllBuildOptions();
      lbUnit.Text = selectedUnit + " - " + mod.GetUnitDescription(selectedUnit);
      FillOptions();
    }


    private void FillOptions()
    {
      if (DisplayMode == BuildsMode.Builds) {
        lbOptions.Items.Clear();
        if (builds.ContainsKey(selectedUnit)) {
          foreach (string s in builds[selectedUnit]) {
            lbOptions.Items.Add(new Mod.ModSearchUnitResult(s, mod));
          }
        }
      } else {
        lbOptions.Items.Clear();
        foreach (KeyValuePair<string, List<string>> kv in builds) {
          if (kv.Value != null && kv.Value.Contains(selectedUnit)) {
            lbOptions.Items.Add(new Mod.ModSearchUnitResult(kv.Key, mod));
          }
        }
      }
    }


    private void SaveOptions()
    {
      if (DisplayMode == BuildsMode.Builds) {
        List<string> ls = new List<string>();
        foreach (Mod.ModSearchUnitResult ms in lbOptions.Items) {
          ls.Add(ms.id);
        }
        builds[selectedUnit] = ls;
        mod.SetUnitBuildOptions(selectedUnit, builds[selectedUnit]);
      } else {
        List<string> ls = new List<string>();
        foreach (Mod.ModSearchUnitResult ms in lbOptions.Items) {
          ls.Add(ms.id);
          if (!builds[ms.id].Contains(selectedUnit)) {
            builds[ms.id].Add(selectedUnit);
            mod.SetUnitBuildOptions(ms.id, builds[ms.id]);
          }
        }

        foreach (KeyValuePair<string, List<string>> kv in builds) {
          if (kv.Value != null && kv.Value.Contains(selectedUnit)) {
            if (!ls.Contains(kv.Key)) {
              builds[kv.Key].RemoveAll(delegate(string s) { return s == selectedUnit; });
              mod.SetUnitBuildOptions(kv.Key, builds[kv.Key]);
            }
          }
        }
      }
      FillOptions();
      if (BuildOptionsChanged != null) BuildOptionsChanged(this, EventArgs.Empty);
    }


    private void FormBuildEditor_Load(object sender, EventArgs e)
    {
      ReloadBuildTree();
    }

    private void tbBuilds_CheckedChanged(object sender, EventArgs e)
    {
      if (tbBuilds.Checked) {
        rbBuiltBy.Checked = false;
        tbAddAfter.Enabled = false;
        btnAddAfter.Enabled = false;
        tbCopyFrom.Enabled = true;
        btnCopyFrom.Enabled = true;
      }
      DisplayMode = BuildsMode.Builds;
      FillOptions();
    }

    private void rbBuiltBy_CheckedChanged(object sender, EventArgs e)
    {
      if (rbBuiltBy.Checked) {
        tbBuilds.Checked = false;
        tbAddAfter.Enabled = true;
        btnAddAfter.Enabled = true;
        tbCopyFrom.Enabled = false;
        btnCopyFrom.Enabled = false;

      }
      DisplayMode = BuildsMode.BuiltBy;
      FillOptions();
    }

    private void lbOptions_MouseDoubleClick(object sender, MouseEventArgs e)
    {
      ListBox lb = sender as ListBox;
      if (lb.SelectedIndex > -1) {
        SelectUnit(((Mod.ModSearchUnitResult)lb.Items[lb.SelectedIndex]).id);
      }
    }

    private void lbOptions_DragDrop(object sender, DragEventArgs e)
    {
      ListBox lb = sender as ListBox;
      Point p = lb.PointToClient(new Point(e.X, e.Y));
      int i = lb.IndexFromPoint(p.X, p.Y);

      string newid = (string)e.Data.GetData(typeof(string));
      int orgi = ContainsItem(newid);
      if (orgi >= 0) {
        lb.Items.RemoveAt(orgi);
        if (i > -1) lb.Items.Insert(i, new Mod.ModSearchUnitResult(newid, mod));
        else lb.Items.Add(new Mod.ModSearchUnitResult(newid, mod));
      } else {
        if (i > -1) lb.Items.Insert(i, new Mod.ModSearchUnitResult(newid, mod));
        else lb.Items.Add(new Mod.ModSearchUnitResult(newid, mod));
      }
      SaveOptions();

    }


    private int ContainsItem(string id)
    {
      ListBox lb = lbOptions;
      int i = 0;
      foreach (Mod.ModSearchUnitResult ms in lb.Items) {
        if (ms.id == id) {
          return i;
        }
        i++;
      }
      return -1;
    }


    private void lbOptions_DragEnter(object sender, DragEventArgs e)
    {
      ListBox lb = sender as ListBox;
      e.Effect = DragDropEffects.Copy;
      int ind = ContainsItem((string)e.Data.GetData(typeof(string)));
      if (ind > -1) {
        e.Effect = DragDropEffects.Move;
      }
    }

    private void lbOptions_MouseDown(object sender, MouseEventArgs e)
    {
      if (e.Button == MouseButtons.Right) {
        ListBox lb = sender as ListBox;
        if (lb.SelectedIndex > -1) {
          string unit = ((Mod.ModSearchUnitResult)lb.Items[lb.SelectedIndex]).id;
          DoDragDrop(unit, DragDropEffects.All);
        }
      }
    }

    private void lbOptions_KeyDown(object sender, KeyEventArgs e)
    {
      ListBox lb = sender as ListBox;
      if (e.KeyCode == Keys.Delete) {
        if (lb.SelectedIndex > -1) {
          lb.Items.RemoveAt(lb.SelectedIndex);
          SaveOptions();
        }
      }
    }

    private void btnCopyFrom_Click(object sender, EventArgs e)
    {
      string id = tbCopyFrom.Text;
      if (builds.ContainsKey(id) && id != selectedUnit) {
        foreach (string s in builds[id]) {
          if (!builds[selectedUnit].Contains(s)) builds[selectedUnit].Add(s);
        }
        mod.SetUnitBuildOptions(selectedUnit, builds[selectedUnit]);
        FillOptions();
      } else MessageBox.Show("Cannot find unit " + id, "Erorr in copy buildlist", MessageBoxButtons.OK, MessageBoxIcon.Warning);
      if (BuildOptionsChanged != null) BuildOptionsChanged(this, EventArgs.Empty);
    }

    private void btnAddAfter_Click(object sender, EventArgs e)
    {
      string id = tbAddAfter.Text;
      int added = 0;
      foreach (KeyValuePair<string, List<string>> kv in builds) {
        int ind = kv.Value.IndexOf(id);
        if (ind > -1) {
          added++;
          builds[kv.Key].Insert(ind, selectedUnit);
          mod.SetUnitBuildOptions(kv.Key, builds[kv.Key]);
        }
      }
      FillOptions();
      if (BuildOptionsChanged != null) BuildOptionsChanged(this, EventArgs.Empty);
    }

    private void btnCleanup_Click(object sender, EventArgs e)
    {
      int total = 0;
      foreach (KeyValuePair<string, List<string>> kv in builds) {
        int org = kv.Value.Count;
        RemoveDuplicates(kv.Value);
        List<string> todel = new List<string>();
        foreach (string s in kv.Value) {
          if (mod.Units[s] == null) todel.Add(s);
        }
        foreach (string s in todel) kv.Value.Remove(s);
        total += (org - kv.Value.Count);
      }
      MessageBox.Show("Removed " + total + " duplicate and invalid entries", "Buildlist cleanup", MessageBoxButtons.OK, MessageBoxIcon.Information);

    }


    private static void RemoveDuplicates(List<string> inputList)
    {
      Dictionary<string, int> uniqueStore = new Dictionary<string, int>();
      List<string> finalList = new List<string>();

      foreach (string currValue in inputList) {
        if (!uniqueStore.ContainsKey(currValue)) {
          uniqueStore.Add(currValue, 0);
          finalList.Add(currValue);
        }
      }
      inputList.Clear();
      foreach (string s in finalList) {
        inputList.Add(s);
      }
    }
  }
}
