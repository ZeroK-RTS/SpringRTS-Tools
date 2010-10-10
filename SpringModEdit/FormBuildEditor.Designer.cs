namespace SpringModEdit
{
  partial class FormBuildEditor
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

    #region Windows Form Designer generated code

    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
      this.lbOptions = new System.Windows.Forms.ListBox();
      this.tbBuilds = new System.Windows.Forms.RadioButton();
      this.rbBuiltBy = new System.Windows.Forms.RadioButton();
      this.lbUnit = new System.Windows.Forms.Label();
      this.groupBox1 = new System.Windows.Forms.GroupBox();
      this.btnCopyFrom = new System.Windows.Forms.Button();
      this.tbCopyFrom = new System.Windows.Forms.TextBox();
      this.groupBox2 = new System.Windows.Forms.GroupBox();
      this.btnAddAfter = new System.Windows.Forms.Button();
      this.tbAddAfter = new System.Windows.Forms.TextBox();
      this.btnCleanup = new System.Windows.Forms.Button();
      this.label1 = new System.Windows.Forms.Label();
      this.groupBox1.SuspendLayout();
      this.groupBox2.SuspendLayout();
      this.SuspendLayout();
      // 
      // lbOptions
      // 
      this.lbOptions.AllowDrop = true;
      this.lbOptions.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                  | System.Windows.Forms.AnchorStyles.Left)
                  | System.Windows.Forms.AnchorStyles.Right)));
      this.lbOptions.FormattingEnabled = true;
      this.lbOptions.Location = new System.Drawing.Point(12, 64);
      this.lbOptions.Name = "lbOptions";
      this.lbOptions.Size = new System.Drawing.Size(342, 407);
      this.lbOptions.TabIndex = 0;
      this.lbOptions.MouseDoubleClick += new System.Windows.Forms.MouseEventHandler(this.lbOptions_MouseDoubleClick);
      this.lbOptions.DragDrop += new System.Windows.Forms.DragEventHandler(this.lbOptions_DragDrop);
      this.lbOptions.MouseDown += new System.Windows.Forms.MouseEventHandler(this.lbOptions_MouseDown);
      this.lbOptions.DragEnter += new System.Windows.Forms.DragEventHandler(this.lbOptions_DragEnter);
      this.lbOptions.KeyDown += new System.Windows.Forms.KeyEventHandler(this.lbOptions_KeyDown);
      // 
      // tbBuilds
      // 
      this.tbBuilds.AutoSize = true;
      this.tbBuilds.Checked = true;
      this.tbBuilds.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
      this.tbBuilds.Location = new System.Drawing.Point(16, 41);
      this.tbBuilds.Name = "tbBuilds";
      this.tbBuilds.Size = new System.Drawing.Size(65, 19);
      this.tbBuilds.TabIndex = 1;
      this.tbBuilds.TabStop = true;
      this.tbBuilds.Text = "Builds";
      this.tbBuilds.UseVisualStyleBackColor = true;
      this.tbBuilds.CheckedChanged += new System.EventHandler(this.tbBuilds_CheckedChanged);
      // 
      // rbBuiltBy
      // 
      this.rbBuiltBy.AutoSize = true;
      this.rbBuiltBy.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
      this.rbBuiltBy.Location = new System.Drawing.Point(96, 41);
      this.rbBuiltBy.Name = "rbBuiltBy";
      this.rbBuiltBy.Size = new System.Drawing.Size(72, 19);
      this.rbBuiltBy.TabIndex = 2;
      this.rbBuiltBy.Text = "Built by";
      this.rbBuiltBy.UseVisualStyleBackColor = true;
      this.rbBuiltBy.CheckedChanged += new System.EventHandler(this.rbBuiltBy_CheckedChanged);
      // 
      // lbUnit
      // 
      this.lbUnit.AutoSize = true;
      this.lbUnit.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
      this.lbUnit.Location = new System.Drawing.Point(12, 9);
      this.lbUnit.Name = "lbUnit";
      this.lbUnit.Size = new System.Drawing.Size(52, 17);
      this.lbUnit.TabIndex = 3;
      this.lbUnit.Text = "label1";
      // 
      // groupBox1
      // 
      this.groupBox1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
      this.groupBox1.Controls.Add(this.btnCopyFrom);
      this.groupBox1.Controls.Add(this.tbCopyFrom);
      this.groupBox1.Location = new System.Drawing.Point(360, 64);
      this.groupBox1.Name = "groupBox1";
      this.groupBox1.Size = new System.Drawing.Size(200, 100);
      this.groupBox1.TabIndex = 4;
      this.groupBox1.TabStop = false;
      this.groupBox1.Text = "Copy build list";
      // 
      // btnCopyFrom
      // 
      this.btnCopyFrom.Location = new System.Drawing.Point(38, 59);
      this.btnCopyFrom.Name = "btnCopyFrom";
      this.btnCopyFrom.Size = new System.Drawing.Size(116, 23);
      this.btnCopyFrom.TabIndex = 1;
      this.btnCopyFrom.Text = "Copy from unit";
      this.btnCopyFrom.UseVisualStyleBackColor = true;
      this.btnCopyFrom.Click += new System.EventHandler(this.btnCopyFrom_Click);
      // 
      // tbCopyFrom
      // 
      this.tbCopyFrom.Location = new System.Drawing.Point(18, 19);
      this.tbCopyFrom.Name = "tbCopyFrom";
      this.tbCopyFrom.Size = new System.Drawing.Size(150, 20);
      this.tbCopyFrom.TabIndex = 0;
      // 
      // groupBox2
      // 
      this.groupBox2.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
      this.groupBox2.Controls.Add(this.btnAddAfter);
      this.groupBox2.Controls.Add(this.tbAddAfter);
      this.groupBox2.Location = new System.Drawing.Point(360, 182);
      this.groupBox2.Name = "groupBox2";
      this.groupBox2.Size = new System.Drawing.Size(200, 100);
      this.groupBox2.TabIndex = 5;
      this.groupBox2.TabStop = false;
      this.groupBox2.Text = "Add to all buildlists after unit";
      // 
      // btnAddAfter
      // 
      this.btnAddAfter.Enabled = false;
      this.btnAddAfter.Location = new System.Drawing.Point(38, 59);
      this.btnAddAfter.Name = "btnAddAfter";
      this.btnAddAfter.Size = new System.Drawing.Size(116, 23);
      this.btnAddAfter.TabIndex = 1;
      this.btnAddAfter.Text = "Add after unit";
      this.btnAddAfter.UseVisualStyleBackColor = true;
      this.btnAddAfter.Click += new System.EventHandler(this.btnAddAfter_Click);
      // 
      // tbAddAfter
      // 
      this.tbAddAfter.Enabled = false;
      this.tbAddAfter.Location = new System.Drawing.Point(18, 19);
      this.tbAddAfter.Name = "tbAddAfter";
      this.tbAddAfter.Size = new System.Drawing.Size(150, 20);
      this.tbAddAfter.TabIndex = 0;
      // 
      // btnCleanup
      // 
      this.btnCleanup.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
      this.btnCleanup.Location = new System.Drawing.Point(418, 304);
      this.btnCleanup.Name = "btnCleanup";
      this.btnCleanup.Size = new System.Drawing.Size(75, 23);
      this.btnCleanup.TabIndex = 6;
      this.btnCleanup.Text = "Cleanup";
      this.btnCleanup.UseVisualStyleBackColor = true;
      this.btnCleanup.Click += new System.EventHandler(this.btnCleanup_Click);
      // 
      // label1
      // 
      this.label1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
      this.label1.AutoSize = true;
      this.label1.Location = new System.Drawing.Point(12, 488);
      this.label1.Name = "label1";
      this.label1.Size = new System.Drawing.Size(382, 13);
      this.label1.TabIndex = 7;
      this.label1.Text = "Hold right mouse to drag items (possible from main window too), Del deletes item";
      // 
      // FormBuildEditor
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.ClientSize = new System.Drawing.Size(572, 503);
      this.Controls.Add(this.label1);
      this.Controls.Add(this.btnCleanup);
      this.Controls.Add(this.groupBox2);
      this.Controls.Add(this.groupBox1);
      this.Controls.Add(this.lbUnit);
      this.Controls.Add(this.rbBuiltBy);
      this.Controls.Add(this.tbBuilds);
      this.Controls.Add(this.lbOptions);
      this.Name = "FormBuildEditor";
      this.Text = "Buildlist editor";
      this.Load += new System.EventHandler(this.FormBuildEditor_Load);
      this.groupBox1.ResumeLayout(false);
      this.groupBox1.PerformLayout();
      this.groupBox2.ResumeLayout(false);
      this.groupBox2.PerformLayout();
      this.ResumeLayout(false);
      this.PerformLayout();

    }

    #endregion

    private System.Windows.Forms.ListBox lbOptions;
    private System.Windows.Forms.RadioButton tbBuilds;
    private System.Windows.Forms.RadioButton rbBuiltBy;
    private System.Windows.Forms.Label lbUnit;
    private System.Windows.Forms.GroupBox groupBox1;
    private System.Windows.Forms.Button btnCopyFrom;
    private System.Windows.Forms.TextBox tbCopyFrom;
    private System.Windows.Forms.GroupBox groupBox2;
    private System.Windows.Forms.Button btnAddAfter;
    private System.Windows.Forms.TextBox tbAddAfter;
    private System.Windows.Forms.Button btnCleanup;
    private System.Windows.Forms.Label label1;

  }
}