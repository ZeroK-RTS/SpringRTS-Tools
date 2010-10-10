namespace SpringModEdit
{
  partial class FormMain
  {
    /// <summary>
    /// Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    protected override void Dispose(bool disposing)
    {
      if (disposing && (components != null)) {
        components.Dispose();
      }
      base.Dispose(disposing);
    }


    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
        this.components = new System.ComponentModel.Container();
        this.splitContainer1 = new System.Windows.Forms.SplitContainer();
        this.btnBuildList = new System.Windows.Forms.Button();
        this.label2 = new System.Windows.Forms.Label();
        this.lbLine = new System.Windows.Forms.Label();
        this.tabControl1 = new System.Windows.Forms.TabControl();
        this.contextMenuFile = new System.Windows.Forms.ContextMenuStrip(this.components);
        this.closeToolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
        this.saveAllToolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
        this.discardChangesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.deleteUnitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.cloneUnitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.splitContainer2 = new System.Windows.Forms.SplitContainer();
        this.groupBox1 = new System.Windows.Forms.GroupBox();
        this.groupBox2 = new System.Windows.Forms.GroupBox();
        this.lbResults = new System.Windows.Forms.ListBox();
        this.btnSearchLua = new System.Windows.Forms.Button();
        this.btnSearch = new System.Windows.Forms.Button();
        this.tbSearch = new System.Windows.Forms.TextBox();
        this.groupBox3 = new System.Windows.Forms.GroupBox();
        this.btnScriptSave = new System.Windows.Forms.Button();
        this.lbLineScript = new System.Windows.Forms.Label();
        this.btnLoadProcedure = new System.Windows.Forms.Button();
        this.label1 = new System.Windows.Forms.Label();
        this.cbProcedures = new System.Windows.Forms.ComboBox();
        this.btnExecute = new System.Windows.Forms.Button();
        this.tbCommand = new System.Windows.Forms.TextBox();
        this.menuMain = new System.Windows.Forms.MenuStrip();
        this.miViewChanges = new System.Windows.Forms.ToolStripMenuItem();
        this.miLoad = new System.Windows.Forms.ToolStripMenuItem();
        this.miReload = new System.Windows.Forms.ToolStripMenuItem();
        this.miSave = new System.Windows.Forms.ToolStripMenuItem();
        this.miSaveAs = new System.Windows.Forms.ToolStripMenuItem();
        this.toolsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.editBuildOptionsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.btChanges = new System.Windows.Forms.Button();
        this.viewChangesToolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
        this.splitContainer1.Panel1.SuspendLayout();
        this.splitContainer1.Panel2.SuspendLayout();
        this.splitContainer1.SuspendLayout();
        this.contextMenuFile.SuspendLayout();
        this.splitContainer2.Panel1.SuspendLayout();
        this.splitContainer2.Panel2.SuspendLayout();
        this.splitContainer2.SuspendLayout();
        this.groupBox1.SuspendLayout();
        this.groupBox2.SuspendLayout();
        this.groupBox3.SuspendLayout();
        this.menuMain.SuspendLayout();
        this.SuspendLayout();
        // 
        // splitContainer1
        // 
        this.splitContainer1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                    | System.Windows.Forms.AnchorStyles.Left)
                    | System.Windows.Forms.AnchorStyles.Right)));
        this.splitContainer1.Location = new System.Drawing.Point(0, 27);
        this.splitContainer1.Name = "splitContainer1";
        // 
        // splitContainer1.Panel1
        // 
        this.splitContainer1.Panel1.Controls.Add(this.btnBuildList);
        this.splitContainer1.Panel1.Controls.Add(this.btChanges);
        this.splitContainer1.Panel1.Controls.Add(this.label2);
        this.splitContainer1.Panel1.Controls.Add(this.lbLine);
        this.splitContainer1.Panel1.Controls.Add(this.tabControl1);
        // 
        // splitContainer1.Panel2
        // 
        this.splitContainer1.Panel2.Controls.Add(this.splitContainer2);
        this.splitContainer1.Size = new System.Drawing.Size(820, 611);
        this.splitContainer1.SplitterDistance = 558;
        this.splitContainer1.TabIndex = 0;
        // 
        // btnBuildList
        // 
        this.btnBuildList.Location = new System.Drawing.Point(335, 0);
        this.btnBuildList.Name = "btnBuildList";
        this.btnBuildList.Size = new System.Drawing.Size(75, 20);
        this.btnBuildList.TabIndex = 11;
        this.btnBuildList.Text = "Buildlist";
        this.btnBuildList.UseVisualStyleBackColor = true;
        this.btnBuildList.Click += new System.EventHandler(this.btnBuildList_Click);
        // 
        // label2
        // 
        this.label2.AutoSize = true;
        this.label2.Location = new System.Drawing.Point(416, 4);
        this.label2.Name = "label2";
        this.label2.Size = new System.Drawing.Size(132, 13);
        this.label2.TabIndex = 9;
        this.label2.Text = "(Use ctrl+f to search in file)";
        // 
        // lbLine
        // 
        this.lbLine.AutoSize = true;
        this.lbLine.Location = new System.Drawing.Point(7, 4);
        this.lbLine.Name = "lbLine";
        this.lbLine.Size = new System.Drawing.Size(0, 13);
        this.lbLine.TabIndex = 8;
        // 
        // tabControl1
        // 
        this.tabControl1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                    | System.Windows.Forms.AnchorStyles.Left)
                    | System.Windows.Forms.AnchorStyles.Right)));
        this.tabControl1.ContextMenuStrip = this.contextMenuFile;
        this.tabControl1.HotTrack = true;
        this.tabControl1.Location = new System.Drawing.Point(0, 20);
        this.tabControl1.Name = "tabControl1";
        this.tabControl1.SelectedIndex = 0;
        this.tabControl1.Size = new System.Drawing.Size(555, 588);
        this.tabControl1.TabIndex = 0;
        // 
        // contextMenuFile
        // 
        this.contextMenuFile.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.closeToolStripMenuItem1,
            this.saveAllToolStripMenuItem1,
            this.discardChangesToolStripMenuItem,
            this.deleteUnitToolStripMenuItem,
            this.cloneUnitToolStripMenuItem});
        this.contextMenuFile.Name = "contextMenuFile";
        this.contextMenuFile.Size = new System.Drawing.Size(194, 114);
        this.contextMenuFile.Opening += new System.ComponentModel.CancelEventHandler(this.contextMenuFile_Opening);
        // 
        // closeToolStripMenuItem1
        // 
        this.closeToolStripMenuItem1.Name = "closeToolStripMenuItem1";
        this.closeToolStripMenuItem1.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.W)));
        this.closeToolStripMenuItem1.Size = new System.Drawing.Size(193, 22);
        this.closeToolStripMenuItem1.Text = "Close";
        this.closeToolStripMenuItem1.Click += new System.EventHandler(this.closeToolStripMenuItem1_Click);
        // 
        // saveAllToolStripMenuItem1
        // 
        this.saveAllToolStripMenuItem1.Name = "saveAllToolStripMenuItem1";
        this.saveAllToolStripMenuItem1.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Q)));
        this.saveAllToolStripMenuItem1.Size = new System.Drawing.Size(193, 22);
        this.saveAllToolStripMenuItem1.Text = "Save all";
        this.saveAllToolStripMenuItem1.Click += new System.EventHandler(this.saveAllToolStripMenuItem1_Click);
        // 
        // discardChangesToolStripMenuItem
        // 
        this.discardChangesToolStripMenuItem.Name = "discardChangesToolStripMenuItem";
        this.discardChangesToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.R)));
        this.discardChangesToolStripMenuItem.Size = new System.Drawing.Size(193, 22);
        this.discardChangesToolStripMenuItem.Text = "Discard changes";
        this.discardChangesToolStripMenuItem.Click += new System.EventHandler(this.discardChangesToolStripMenuItem_Click);
        // 
        // deleteUnitToolStripMenuItem
        // 
        this.deleteUnitToolStripMenuItem.Name = "deleteUnitToolStripMenuItem";
        this.deleteUnitToolStripMenuItem.Size = new System.Drawing.Size(193, 22);
        this.deleteUnitToolStripMenuItem.Text = "Delete unit";
        this.deleteUnitToolStripMenuItem.Click += new System.EventHandler(this.deleteUnitToolStripMenuItem_Click);
        // 
        // cloneUnitToolStripMenuItem
        // 
        this.cloneUnitToolStripMenuItem.Name = "cloneUnitToolStripMenuItem";
        this.cloneUnitToolStripMenuItem.Size = new System.Drawing.Size(193, 22);
        this.cloneUnitToolStripMenuItem.Text = "Clone unit";
        this.cloneUnitToolStripMenuItem.Click += new System.EventHandler(this.cloneUnitToolStripMenuItem_Click);
        // 
        // splitContainer2
        // 
        this.splitContainer2.Dock = System.Windows.Forms.DockStyle.Fill;
        this.splitContainer2.Location = new System.Drawing.Point(0, 0);
        this.splitContainer2.Name = "splitContainer2";
        this.splitContainer2.Orientation = System.Windows.Forms.Orientation.Horizontal;
        // 
        // splitContainer2.Panel1
        // 
        this.splitContainer2.Panel1.Controls.Add(this.groupBox1);
        // 
        // splitContainer2.Panel2
        // 
        this.splitContainer2.Panel2.Controls.Add(this.groupBox3);
        this.splitContainer2.Size = new System.Drawing.Size(258, 611);
        this.splitContainer2.SplitterDistance = 242;
        this.splitContainer2.TabIndex = 1;
        // 
        // groupBox1
        // 
        this.groupBox1.Controls.Add(this.groupBox2);
        this.groupBox1.Controls.Add(this.btnSearchLua);
        this.groupBox1.Controls.Add(this.btnSearch);
        this.groupBox1.Controls.Add(this.tbSearch);
        this.groupBox1.Dock = System.Windows.Forms.DockStyle.Fill;
        this.groupBox1.Location = new System.Drawing.Point(0, 0);
        this.groupBox1.Name = "groupBox1";
        this.groupBox1.Size = new System.Drawing.Size(258, 242);
        this.groupBox1.TabIndex = 0;
        this.groupBox1.TabStop = false;
        this.groupBox1.Text = "Search";
        // 
        // groupBox2
        // 
        this.groupBox2.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                    | System.Windows.Forms.AnchorStyles.Left)
                    | System.Windows.Forms.AnchorStyles.Right)));
        this.groupBox2.Controls.Add(this.lbResults);
        this.groupBox2.Location = new System.Drawing.Point(6, 75);
        this.groupBox2.Name = "groupBox2";
        this.groupBox2.Size = new System.Drawing.Size(243, 164);
        this.groupBox2.TabIndex = 3;
        this.groupBox2.TabStop = false;
        this.groupBox2.Text = "Search results";
        // 
        // lbResults
        // 
        this.lbResults.ContextMenuStrip = this.contextMenuFile;
        this.lbResults.Dock = System.Windows.Forms.DockStyle.Fill;
        this.lbResults.FormattingEnabled = true;
        this.lbResults.Location = new System.Drawing.Point(3, 16);
        this.lbResults.Name = "lbResults";
        this.lbResults.Size = new System.Drawing.Size(237, 134);
        this.lbResults.TabIndex = 0;
        this.lbResults.MouseUp += new System.Windows.Forms.MouseEventHandler(this.lbResults_MouseUp);
        this.lbResults.MouseDoubleClick += new System.Windows.Forms.MouseEventHandler(this.lbResults_MouseDoubleClick);
        this.lbResults.MouseDown += new System.Windows.Forms.MouseEventHandler(this.lbResults_MouseDown);
        // 
        // btnSearchLua
        // 
        this.btnSearchLua.Location = new System.Drawing.Point(110, 46);
        this.btnSearchLua.Name = "btnSearchLua";
        this.btnSearchLua.Size = new System.Drawing.Size(142, 23);
        this.btnSearchLua.TabIndex = 2;
        this.btnSearchLua.Text = "LUA Search (ctrl+enter)";
        this.btnSearchLua.UseVisualStyleBackColor = true;
        this.btnSearchLua.Click += new System.EventHandler(this.btnSearchLua_Click);
        // 
        // btnSearch
        // 
        this.btnSearch.Location = new System.Drawing.Point(12, 46);
        this.btnSearch.Name = "btnSearch";
        this.btnSearch.Size = new System.Drawing.Size(86, 23);
        this.btnSearch.TabIndex = 1;
        this.btnSearch.Text = "Search(enter)";
        this.btnSearch.UseVisualStyleBackColor = true;
        this.btnSearch.Click += new System.EventHandler(this.btnSearch_Click);
        // 
        // tbSearch
        // 
        this.tbSearch.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                    | System.Windows.Forms.AnchorStyles.Right)));
        this.tbSearch.Location = new System.Drawing.Point(7, 20);
        this.tbSearch.Name = "tbSearch";
        this.tbSearch.ScrollBars = System.Windows.Forms.ScrollBars.Both;
        this.tbSearch.Size = new System.Drawing.Size(244, 20);
        this.tbSearch.TabIndex = 0;
        this.tbSearch.KeyDown += new System.Windows.Forms.KeyEventHandler(this.tbSearch_KeyDown);
        // 
        // groupBox3
        // 
        this.groupBox3.Controls.Add(this.btnScriptSave);
        this.groupBox3.Controls.Add(this.lbLineScript);
        this.groupBox3.Controls.Add(this.btnLoadProcedure);
        this.groupBox3.Controls.Add(this.label1);
        this.groupBox3.Controls.Add(this.cbProcedures);
        this.groupBox3.Controls.Add(this.btnExecute);
        this.groupBox3.Controls.Add(this.tbCommand);
        this.groupBox3.Dock = System.Windows.Forms.DockStyle.Fill;
        this.groupBox3.Location = new System.Drawing.Point(0, 0);
        this.groupBox3.Name = "groupBox3";
        this.groupBox3.Size = new System.Drawing.Size(258, 365);
        this.groupBox3.TabIndex = 0;
        this.groupBox3.TabStop = false;
        this.groupBox3.Text = "Script execution";
        // 
        // btnScriptSave
        // 
        this.btnScriptSave.Location = new System.Drawing.Point(64, 43);
        this.btnScriptSave.Name = "btnScriptSave";
        this.btnScriptSave.Size = new System.Drawing.Size(51, 23);
        this.btnScriptSave.TabIndex = 10;
        this.btnScriptSave.Text = "Save";
        this.btnScriptSave.UseVisualStyleBackColor = true;
        this.btnScriptSave.Click += new System.EventHandler(this.btnScriptSave_Click);
        // 
        // lbLineScript
        // 
        this.lbLineScript.AutoSize = true;
        this.lbLineScript.Location = new System.Drawing.Point(131, 40);
        this.lbLineScript.Name = "lbLineScript";
        this.lbLineScript.Size = new System.Drawing.Size(0, 13);
        this.lbLineScript.TabIndex = 9;
        // 
        // btnLoadProcedure
        // 
        this.btnLoadProcedure.Location = new System.Drawing.Point(9, 43);
        this.btnLoadProcedure.Name = "btnLoadProcedure";
        this.btnLoadProcedure.Size = new System.Drawing.Size(51, 23);
        this.btnLoadProcedure.TabIndex = 4;
        this.btnLoadProcedure.Text = "Load";
        this.btnLoadProcedure.UseVisualStyleBackColor = true;
        this.btnLoadProcedure.Click += new System.EventHandler(this.btnLoadProcedure_Click);
        // 
        // label1
        // 
        this.label1.AutoSize = true;
        this.label1.Location = new System.Drawing.Point(9, 19);
        this.label1.Name = "label1";
        this.label1.Size = new System.Drawing.Size(59, 13);
        this.label1.TabIndex = 3;
        this.label1.Text = "Procedure:";
        // 
        // cbProcedures
        // 
        this.cbProcedures.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                    | System.Windows.Forms.AnchorStyles.Right)));
        this.cbProcedures.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
        this.cbProcedures.FormattingEnabled = true;
        this.cbProcedures.Location = new System.Drawing.Point(74, 16);
        this.cbProcedures.Name = "cbProcedures";
        this.cbProcedures.Size = new System.Drawing.Size(172, 21);
        this.cbProcedures.TabIndex = 2;
        // 
        // btnExecute
        // 
        this.btnExecute.Location = new System.Drawing.Point(121, 60);
        this.btnExecute.Name = "btnExecute";
        this.btnExecute.Size = new System.Drawing.Size(128, 23);
        this.btnExecute.TabIndex = 1;
        this.btnExecute.Text = "Execute (ctrl+enter)";
        this.btnExecute.UseVisualStyleBackColor = true;
        this.btnExecute.Click += new System.EventHandler(this.btnExecute_Click);
        // 
        // tbCommand
        // 
        this.tbCommand.AcceptsReturn = true;
        this.tbCommand.AcceptsTab = true;
        this.tbCommand.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                    | System.Windows.Forms.AnchorStyles.Left)
                    | System.Windows.Forms.AnchorStyles.Right)));
        this.tbCommand.Font = new System.Drawing.Font("Courier New", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
        this.tbCommand.Location = new System.Drawing.Point(6, 84);
        this.tbCommand.Multiline = true;
        this.tbCommand.Name = "tbCommand";
        this.tbCommand.ScrollBars = System.Windows.Forms.ScrollBars.Both;
        this.tbCommand.Size = new System.Drawing.Size(245, 278);
        this.tbCommand.TabIndex = 0;
        this.tbCommand.Click += new System.EventHandler(this.tbCommand_Click);
        this.tbCommand.KeyDown += new System.Windows.Forms.KeyEventHandler(this.tbCommand_KeyDown);
        // 
        // menuMain
        // 
        this.menuMain.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.miViewChanges,
            this.toolsToolStripMenuItem});
        this.menuMain.Location = new System.Drawing.Point(0, 0);
        this.menuMain.Name = "menuMain";
        this.menuMain.Size = new System.Drawing.Size(820, 24);
        this.menuMain.TabIndex = 0;
        this.menuMain.Text = "menuStrip1";
        // 
        // miViewChanges
        // 
        this.miViewChanges.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.miLoad,
            this.miReload,
            this.miSave,
            this.miSaveAs});
        this.miViewChanges.Name = "miViewChanges";
        this.miViewChanges.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.V)));
        this.miViewChanges.Size = new System.Drawing.Size(40, 20);
        this.miViewChanges.Text = "Mod";
        // 
        // miLoad
        // 
        this.miLoad.Name = "miLoad";
        this.miLoad.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.O)));
        this.miLoad.Size = new System.Drawing.Size(174, 22);
        this.miLoad.Text = "Load";
        this.miLoad.Click += new System.EventHandler(this.miLoad_Click);
        // 
        // miReload
        // 
        this.miReload.Name = "miReload";
        this.miReload.ShortcutKeys = ((System.Windows.Forms.Keys)(((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Shift)
                    | System.Windows.Forms.Keys.O)));
        this.miReload.Size = new System.Drawing.Size(174, 22);
        this.miReload.Text = "Reload";
        this.miReload.Click += new System.EventHandler(this.miReload_Click);
        // 
        // miSave
        // 
        this.miSave.Name = "miSave";
        this.miSave.ShortcutKeys = ((System.Windows.Forms.Keys)(((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Shift)
                    | System.Windows.Forms.Keys.S)));
        this.miSave.Size = new System.Drawing.Size(174, 22);
        this.miSave.Text = "Save";
        this.miSave.Click += new System.EventHandler(this.miSave_Click);
        // 
        // miSaveAs
        // 
        this.miSaveAs.Name = "miSaveAs";
        this.miSaveAs.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.S)));
        this.miSaveAs.Size = new System.Drawing.Size(174, 22);
        this.miSaveAs.Text = "Save As";
        this.miSaveAs.Click += new System.EventHandler(this.miSaveAs_Click);
        // 
        // toolsToolStripMenuItem
        // 
        this.toolsToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.viewChangesToolStripMenuItem1,
            this.editBuildOptionsToolStripMenuItem});
        this.toolsToolStripMenuItem.Name = "toolsToolStripMenuItem";
        this.toolsToolStripMenuItem.Size = new System.Drawing.Size(45, 20);
        this.toolsToolStripMenuItem.Text = "Tools";
        // 
        // editBuildOptionsToolStripMenuItem
        // 
        this.editBuildOptionsToolStripMenuItem.Name = "editBuildOptionsToolStripMenuItem";
        this.editBuildOptionsToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.B)));
        this.editBuildOptionsToolStripMenuItem.Size = new System.Drawing.Size(192, 22);
        this.editBuildOptionsToolStripMenuItem.Text = "Edit build options";
        this.editBuildOptionsToolStripMenuItem.Click += new System.EventHandler(this.editBuildOptionsToolStripMenuItem_Click);
        // 
        // btChanges
        // 
        this.btChanges.Location = new System.Drawing.Point(242, 0);
        this.btChanges.Name = "btChanges";
        this.btChanges.Size = new System.Drawing.Size(75, 19);
        this.btChanges.TabIndex = 10;
        this.btChanges.Text = "Changes";
        this.btChanges.UseVisualStyleBackColor = true;
        this.btChanges.Click += new System.EventHandler(this.btChanges_Click);
        // 
        // viewChangesToolStripMenuItem1
        // 
        this.viewChangesToolStripMenuItem1.Name = "viewChangesToolStripMenuItem1";
        this.viewChangesToolStripMenuItem1.Size = new System.Drawing.Size(192, 22);
        this.viewChangesToolStripMenuItem1.Text = "View changes";
        this.viewChangesToolStripMenuItem1.Click += new System.EventHandler(this.viewChangesToolStripMenuItem_Click);
        // 
        // FormMain
        // 
        this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
        this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
        this.ClientSize = new System.Drawing.Size(820, 637);
        this.Controls.Add(this.menuMain);
        this.Controls.Add(this.splitContainer1);
        this.MainMenuStrip = this.menuMain;
        this.MinimumSize = new System.Drawing.Size(828, 664);
        this.Name = "FormMain";
        this.Text = "CA Mod Editor";
        this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
        this.Load += new System.EventHandler(this.FormMain_Load);
        this.splitContainer1.Panel1.ResumeLayout(false);
        this.splitContainer1.Panel1.PerformLayout();
        this.splitContainer1.Panel2.ResumeLayout(false);
        this.splitContainer1.ResumeLayout(false);
        this.contextMenuFile.ResumeLayout(false);
        this.splitContainer2.Panel1.ResumeLayout(false);
        this.splitContainer2.Panel2.ResumeLayout(false);
        this.splitContainer2.ResumeLayout(false);
        this.groupBox1.ResumeLayout(false);
        this.groupBox1.PerformLayout();
        this.groupBox2.ResumeLayout(false);
        this.groupBox3.ResumeLayout(false);
        this.groupBox3.PerformLayout();
        this.menuMain.ResumeLayout(false);
        this.menuMain.PerformLayout();
        this.ResumeLayout(false);
        this.PerformLayout();

    }


    private System.Windows.Forms.SplitContainer splitContainer1;
    private System.Windows.Forms.TabControl tabControl1;
    private System.Windows.Forms.MenuStrip menuMain;
    private System.Windows.Forms.ToolStripMenuItem miViewChanges;
    private System.Windows.Forms.ToolStripMenuItem miLoad;
    private System.Windows.Forms.ToolStripMenuItem miReload;
    private System.Windows.Forms.ToolStripMenuItem miSave;
    private System.Windows.Forms.ToolStripMenuItem miSaveAs;
    private System.Windows.Forms.GroupBox groupBox1;
    private System.Windows.Forms.TextBox tbSearch;
    private System.Windows.Forms.GroupBox groupBox2;
    private System.Windows.Forms.Button btnSearchLua;
    private System.Windows.Forms.Button btnSearch;
    private System.Windows.Forms.SplitContainer splitContainer2;
    private System.Windows.Forms.GroupBox groupBox3;
    private System.Windows.Forms.Button btnLoadProcedure;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.ComboBox cbProcedures;
    private System.Windows.Forms.Button btnExecute;
    private System.Windows.Forms.TextBox tbCommand;
    private System.Windows.Forms.ListBox lbResults;
    private System.Windows.Forms.Label lbLine;
    private System.Windows.Forms.Label lbLineScript;
    private System.Windows.Forms.ContextMenuStrip contextMenuFile;
    private System.Windows.Forms.ToolStripMenuItem closeToolStripMenuItem1;
    private System.Windows.Forms.ToolStripMenuItem saveAllToolStripMenuItem1;
    private System.Windows.Forms.ToolStripMenuItem discardChangesToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem deleteUnitToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem cloneUnitToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem toolsToolStripMenuItem;
    private System.Windows.Forms.Button btnScriptSave;
    private System.Windows.Forms.ToolStripMenuItem editBuildOptionsToolStripMenuItem;
    private System.Windows.Forms.Button btnBuildList;
    private System.Windows.Forms.Label label2;
    private System.Windows.Forms.Button btChanges;
    private System.Windows.Forms.ToolStripMenuItem viewChangesToolStripMenuItem1;
  }
}