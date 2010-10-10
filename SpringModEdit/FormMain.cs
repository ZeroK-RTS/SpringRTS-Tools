#region using

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using SpringModEdit.Properties;

#endregion

namespace SpringModEdit
{
    public partial class FormMain : Form
    {
        #region Delegates

        public delegate void Func();

        #endregion

        #region Fields

        private FormBuildEditor buildEditor;
        private Mod mod;
        private Point resultClickLocation = Point.Empty;
        private FormChanges scriptResults;

        #endregion

        #region Constructors

        public FormMain()
        {
            InitializeComponent();
        }

        #endregion

        #region Public methods

        public void AddTab(string id)
        {
            if (tabControl1.TabPages.ContainsKey(id)) tabControl1.SelectTab(id);
            else {
                tabControl1.TabPages.Add(id, id);
                tabControl1.SelectTab(id);
                var tb = new TextBox();
                tb.AcceptsTab = true;
                tb.AcceptsReturn = true;
                tb.Dock = DockStyle.Fill;
                tb.Click += tb_Click;
                tb.KeyDown += tb_KeyDown;
                tb.KeyUp += tb_Click;
                tabControl1.SelectedTab.Controls.Add(tb);
                tb.Font = new Font("Courier New", 10);
                tb.ScrollBars = ScrollBars.Both;
                tb.Text = mod.GetUnitSource(id).Replace("\n", "\r\n");
                tb.Multiline = true;
            }
        }


        public void ReloadTabs()
        {
            var todel = new List<string>();
            foreach (TabPage tp in tabControl1.TabPages) {
                var box = (TextBox) tp.Controls[0];
                if (mod.Units[tp.Text] != null) box.Text = mod.GetUnitSource(tp.Text).Replace("\n", "\r\n");
                else todel.Add(tp.Text);
            }

            foreach (var s in todel) tabControl1.TabPages.RemoveByKey(s);
        }

        #endregion

        #region Other methods

        private void LoadProcedures()
        {
            cbProcedures.Items.Clear();
            foreach (var s in Directory.GetFiles(Path.Combine(Application.StartupPath, "../procedures"), "*.lua")) cbProcedures.Items.Add(Path.GetFileNameWithoutExtension(s));
        }

        private void mod_ModChanged(object sender, EventArgs e)
        {
            ReloadTabs();
        }

        private void Searchbox(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.F && e.Control) {
                var fs = new FormContextSearch();
                fs.ShowDialog();
                var tb = sender as TextBox;
                int ind = tb.Text.IndexOf(fs.EnteredText, tb.SelectionStart, StringComparison.InvariantCultureIgnoreCase);
                if (ind > -1) {
                    tb.SelectionStart = ind;
                    tb.SelectionLength = fs.EnteredText.Length;
                    tb.ScrollToCaret();
                }
            }
        }

        #endregion

        #region Event Handlers

        private void btChanges_Click(object sender, EventArgs e)
        {
            viewChangesToolStripMenuItem1.PerformClick();
        }

        private void btnBuildList_Click(object sender, EventArgs e)
        {
            editBuildOptionsToolStripMenuItem.PerformClick();
        }

        private void btnExecute_Click(object sender, EventArgs e)
        {
            try {
                scriptResults = new FormChanges();
                scriptResults.Title = "Procedure result";
                var now = DateTime.Now;
                LuaFunctions.EchoEvents.Clear();
                var ret = mod.ExecuteScript(tbCommand.Text);

                foreach (var x in LuaFunctions.EchoEvents) {
                    scriptResults.TextBox.SelectionColor = x.color;
                    scriptResults.TextBox.SelectedText = x.message.Replace("\n", "\r\n");
                }

                if (ret != null) {
                    lbResults.Items.Clear();
                    foreach (var ms in ret) lbResults.Items.Add(ms);
                }
                if (scriptResults.TextBox.TextLength > 0) {
                    var ts = DateTime.Now - now;
                    scriptResults.TextBox.AppendText("\r\n -- Executed in  " + ts.Milliseconds + "ms");
                    scriptResults.TopMost = true;
                    scriptResults.Show();
                }
                ReloadTabs();
            } catch (Exception ex) {
                MessageBox.Show("Error in script:\r\n" + ex.Message, "Script error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnLoadProcedure_Click(object sender, EventArgs e)
        {
            if ((cbProcedures.SelectedItem as string) + "" != "") {
                ;
                tbCommand.Text = File.ReadAllText(Path.Combine(Application.StartupPath, "../procedures/" + (string) cbProcedures.SelectedItem + ".lua"));
            }
        }

        private void btnScriptSave_Click(object sender, EventArgs e)
        {
            var fg = new FormGetFileName();
            if (cbProcedures.SelectedItem != null) fg.FileName = cbProcedures.SelectedItem.ToString();
            if (fg.ShowDialog() == DialogResult.OK && fg.FileName + "" != "") {
                File.WriteAllText(Application.StartupPath + "/procedures/" + fg.FileName + ".lua", tbCommand.Text);
                LoadProcedures();
                cbProcedures.SelectedItem = fg.FileName;
            }
        }

        private void btnSearch_Click(object sender, EventArgs e)
        {
            lbResults.Items.Clear();
            foreach (var ms in mod.SearchUnits(tbSearch.Text, false)) lbResults.Items.Add(ms);
        }

        private void btnSearchLua_Click(object sender, EventArgs e)
        {
            lbResults.Items.Clear();
            try {
                foreach (var ms in mod.SearchUnits(tbSearch.Text, true)) lbResults.Items.Add(ms);
            } catch (Exception ex) {
                MessageBox.Show("Error in search script\r\n" + ex.Message, "Script error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void buildEditor_BuildOptionsChanged(object sender, EventArgs e)
        {
            ReloadTabs();
        }

        private void cloneUnitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (tabControl1.SelectedTab != null) {
                string id = tabControl1.SelectedTab.Text;
                string data = (tabControl1.SelectedTab.Controls[0]).Text;
                try {
                    string res = mod.CloneUnit(id, data);
                    AddTab(res);
                } catch (Exception ex) {
                    MessageBox.Show("Error while cloning " + id + "\r\n" + ex.Message, "Cloning errror", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
        }

        private void closeToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            if (tabControl1.SelectedTab != null) {
                try {
                    string oid = tabControl1.SelectedTab.Text;
                    string nid = mod.RedefineUnit((tabControl1.SelectedTab.Controls[0]).Text);
                    tabControl1.TabPages.Remove(tabControl1.SelectedTab);
                } catch (Exception ex) {
                    MessageBox.Show("Error while saving " + tabControl1.SelectedTab.Text + "\r\n" + ex.Message, "Script error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
        }

        private void contextMenuFile_Opening(object sender, CancelEventArgs e)
        {
            var cms = sender as ContextMenuStrip;
            if (cms.SourceControl == tabControl1) {
                cms.Tag = tabControl1.SelectedTab.Text;
                closeToolStripMenuItem1.Enabled = true;
                saveAllToolStripMenuItem1.Enabled = true;
                discardChangesToolStripMenuItem.Enabled = true;
            } else {
                var lb = cms.SourceControl as ListBox;
                var p = lb.PointToClient(new Point(cms.Left, cms.Top));
                int index = lb.IndexFromPoint(p);
                if (index > -1) contextMenuFile.Tag = ((Mod.ModSearchUnitResult) lb.Items[index]).id;
                else e.Cancel = true;
                closeToolStripMenuItem1.Enabled = false;
                saveAllToolStripMenuItem1.Enabled = false;
                discardChangesToolStripMenuItem.Enabled = false;
            }
        }


        private void deleteUnitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (tabControl1.SelectedTab != null) {
                string id = tabControl1.SelectedTab.Text;
                try {
                    mod.DeleteUnit(id);
                } catch (Exception ex) {
                    MessageBox.Show("Error while deleting " + id + "\r\n" + ex.Message, "Deleting errror", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
                tabControl1.TabPages.Remove(tabControl1.SelectedTab);
            }
        }

        private void discardChangesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (tabControl1.SelectedTab != null) tabControl1.TabPages.Remove(tabControl1.SelectedTab);
        }

        private void editBuildOptionsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (buildEditor != null) buildEditor.Close();
            buildEditor = new FormBuildEditor();
            buildEditor.Mod = mod;
            buildEditor.TopMost = true;
            buildEditor.TopLevel = true;
            buildEditor.ReloadBuildTree();
            if (lbResults.SelectedIndex > -1) buildEditor.SelectUnit(((Mod.ModSearchUnitResult) lbResults.SelectedItem).id);
            buildEditor.BuildOptionsChanged += buildEditor_BuildOptionsChanged;
            buildEditor.Show();
        }

        private void FormMain_Load(object sender, EventArgs e)
        {
            if ((string) Settings.Default["modPath"] + "" != "") {
                try {
                    mod = new Mod((string) Settings.Default["modPath"]);
                    MessageBox.Show("Mod loaded", "Mod loading", MessageBoxButtons.OK, MessageBoxIcon.Information);
                } catch (Exception ex) {
                    MessageBox.Show(ex.ToString(), "Error occurred while loading mod", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            } else miLoad.PerformClick();


            LoadProcedures();
        }

        private void lbResults_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            if (lbResults.SelectedIndex > -1) {
                string id = ((Mod.ModSearchUnitResult) lbResults.Items[lbResults.SelectedIndex]).id;
                AddTab(id);
                if (buildEditor != null && buildEditor.Visible) buildEditor.SelectUnit(id);
            }
        }

        private void lbResults_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left) {
                resultClickLocation = e.Location;
                var lb = sender as ListBox;
                if (lb.SelectedIndex > -1) {
                    string unit = ((Mod.ModSearchUnitResult) lb.Items[lb.SelectedIndex]).id;
                    DoDragDrop(unit, DragDropEffects.All);
                }
            } else resultClickLocation = Point.Empty;
        }

        private void lbResults_MouseUp(object sender, MouseEventArgs e)
        {
            if (e.Location == resultClickLocation) contextMenuFile.Show((Control) sender, e.Location);
        }


        private void miLoad_Click(object sender, EventArgs e)
        {
            var df = new FolderBrowserDialog();
            df.SelectedPath = (string) Settings.Default["modPath"];
            df.Description = "Please select CA mod directory";
            df.ShowDialog();
            try {
                mod = new Mod(df.SelectedPath);
                Settings.Default["modPath"] = df.SelectedPath;
                Settings.Default.Save();
                MessageBox.Show("Mod loaded", "Mod loading", MessageBoxButtons.OK, MessageBoxIcon.Information);
                tabControl1.TabPages.Clear();
            } catch (Exception ex) {
                MessageBox.Show(ex.ToString(), "Error occurred while loading", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void miReload_Click(object sender, EventArgs e)
        {
            try {
                mod = new Mod(mod.Folder);
                ReloadTabs();
                MessageBox.Show("Mod reloaded", "Mod reloading", MessageBoxButtons.OK, MessageBoxIcon.Information);
            } catch (Exception ex) {
                MessageBox.Show(ex.ToString(), "Error occurred while loading", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void miSave_Click(object sender, EventArgs e)
        {
            try {
                mod.Save(mod.Folder);
                MessageBox.Show("Mod saved", "Mod saving", MessageBoxButtons.OK, MessageBoxIcon.Information);
            } catch (Exception ex) {
                MessageBox.Show(ex.ToString(), "Error occurred while saving", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void miSaveAs_Click(object sender, EventArgs e)
        {
            var df = new FolderBrowserDialog();
            df.SelectedPath = (string) Settings.Default["modSavePath"];
            df.Description = "Please select mod save directory";
            df.ShowDialog();
            try {
                Settings.Default["modSavePath"] = df.SelectedPath;
                Settings.Default.Save();
                mod.Save(df.SelectedPath);
                MessageBox.Show("Mod saved to " + df.SelectedPath, "Mod saving", MessageBoxButtons.OK, MessageBoxIcon.Information);
            } catch (Exception ex) {
                MessageBox.Show(ex.ToString(), "Error occurred while saving", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void saveAllToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            foreach (TabPage tp in tabControl1.TabPages) {
                try {
                    string oid = tp.Text;
                    string nid = mod.RedefineUnit((tp.Controls[0]).Text);
                    if (oid != nid) {
                        tabControl1.TabPages.RemoveByKey(oid);
                        AddTab(nid);
                    }
                } catch (Exception ex) {
                    MessageBox.Show("Error while saving " + tp.Text + "\r\n" + ex.Message, "Script error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
        }

        private void tb_Click(object sender, EventArgs e)
        {
            var tb = (TextBox) sender;
            lbLine.Text = (tb.GetLineFromCharIndex(tb.GetFirstCharIndexOfCurrentLine()) + 1) + "/" + tb.Lines.Length;
        }

        private void tb_KeyDown(object sender, KeyEventArgs e)
        {
            tb_Click(sender, e);
            Searchbox(sender, e);
        }

        private void tbCommand_Click(object sender, EventArgs e)
        {
            lbLineScript.Text = (tbCommand.GetLineFromCharIndex(tbCommand.GetFirstCharIndexOfCurrentLine()) + 1) + "/" + tbCommand.Lines.Length;
        }

        private void tbCommand_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter && e.Control) {
                e.Handled = true;
                btnExecute.PerformClick();
            }
            Searchbox(sender, e);
            lbLineScript.Text = (tbCommand.GetLineFromCharIndex(tbCommand.GetFirstCharIndexOfCurrentLine()) + 1) + "/" + tbCommand.Lines.Length;
        }

        private void tbSearch_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter) {
                e.Handled = true;
                if (e.Control) btnSearchLua.PerformClick();
                else btnSearch.PerformClick();
            }
        }

        private void viewChangesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            var fc = new FormChanges();
            mod.GetChanges(new Mod(mod.Folder), fc.TextBox);
            if (fc.TextBox.TextLength > 0) {
                fc.TopLevel = true;
                fc.TopMost = true;
                fc.Show();
            } else MessageBox.Show("No changes detected", "Change detection", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        #endregion
    }
}