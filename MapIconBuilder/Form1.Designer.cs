namespace MapIconBuilder
{
  partial class Form1
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
      this.groupBox1 = new System.Windows.Forms.GroupBox();
      this.panel1 = new System.Windows.Forms.Panel();
      this.btBuildicons = new System.Windows.Forms.Button();
      this.btSymbols = new System.Windows.Forms.Button();
      this.btOutput = new System.Windows.Forms.Button();
      this.btResize = new System.Windows.Forms.Button();
      this.label1 = new System.Windows.Forms.Label();
      this.btRules = new System.Windows.Forms.Button();
      this.folderBrowserDialog1 = new System.Windows.Forms.FolderBrowserDialog();
      this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
      this.btIcons = new System.Windows.Forms.Button();
      this.label2 = new System.Windows.Forms.Label();
      this.cbFileType = new System.Windows.Forms.ComboBox();
      this.tabControl1 = new System.Windows.Forms.TabControl();
      this.tabPage1 = new System.Windows.Forms.TabPage();
      this.tabPage2 = new System.Windows.Forms.TabPage();
      this.label3 = new System.Windows.Forms.Label();
      this.label4 = new System.Windows.Forms.Label();
      this.btCombine = new System.Windows.Forms.Button();
      this.btMapIcons = new System.Windows.Forms.Button();
      this.groupBox1.SuspendLayout();
      this.tabControl1.SuspendLayout();
      this.tabPage1.SuspendLayout();
      this.tabPage2.SuspendLayout();
      this.SuspendLayout();
      // 
      // groupBox1
      // 
      this.groupBox1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                  | System.Windows.Forms.AnchorStyles.Left)
                  | System.Windows.Forms.AnchorStyles.Right)));
      this.groupBox1.Controls.Add(this.panel1);
      this.groupBox1.Location = new System.Drawing.Point(0, 132);
      this.groupBox1.Name = "groupBox1";
      this.groupBox1.Size = new System.Drawing.Size(1000, 531);
      this.groupBox1.TabIndex = 0;
      this.groupBox1.TabStop = false;
      this.groupBox1.Text = "Review";
      // 
      // panel1
      // 
      this.panel1.AutoScroll = true;
      this.panel1.Dock = System.Windows.Forms.DockStyle.Fill;
      this.panel1.Location = new System.Drawing.Point(3, 16);
      this.panel1.Name = "panel1";
      this.panel1.Size = new System.Drawing.Size(994, 512);
      this.panel1.TabIndex = 0;
      // 
      // btBuildicons
      // 
      this.btBuildicons.Location = new System.Drawing.Point(84, 12);
      this.btBuildicons.Name = "btBuildicons";
      this.btBuildicons.Size = new System.Drawing.Size(75, 23);
      this.btBuildicons.TabIndex = 1;
      this.btBuildicons.Text = "Buildicons";
      this.btBuildicons.UseVisualStyleBackColor = true;
      this.btBuildicons.Click += new System.EventHandler(this.btBuildicons_Click);
      // 
      // btSymbols
      // 
      this.btSymbols.Location = new System.Drawing.Point(179, 12);
      this.btSymbols.Name = "btSymbols";
      this.btSymbols.Size = new System.Drawing.Size(75, 23);
      this.btSymbols.TabIndex = 2;
      this.btSymbols.Text = "Icons";
      this.btSymbols.UseVisualStyleBackColor = true;
      this.btSymbols.Click += new System.EventHandler(this.btSymbols_Click);
      // 
      // btOutput
      // 
      this.btOutput.Location = new System.Drawing.Point(372, 12);
      this.btOutput.Name = "btOutput";
      this.btOutput.Size = new System.Drawing.Size(75, 23);
      this.btOutput.TabIndex = 3;
      this.btOutput.Text = "Output";
      this.btOutput.UseVisualStyleBackColor = true;
      this.btOutput.Click += new System.EventHandler(this.btOutput_Click);
      // 
      // btResize
      // 
      this.btResize.Location = new System.Drawing.Point(84, 57);
      this.btResize.Name = "btResize";
      this.btResize.Size = new System.Drawing.Size(75, 23);
      this.btResize.TabIndex = 4;
      this.btResize.Text = "ResizeOnly";
      this.btResize.UseVisualStyleBackColor = true;
      this.btResize.Click += new System.EventHandler(this.btProcess_Click);
      // 
      // label1
      // 
      this.label1.AutoSize = true;
      this.label1.Location = new System.Drawing.Point(24, 17);
      this.label1.Name = "label1";
      this.label1.Size = new System.Drawing.Size(38, 13);
      this.label1.TabIndex = 5;
      this.label1.Text = "Setup:";
      // 
      // btRules
      // 
      this.btRules.Location = new System.Drawing.Point(273, 12);
      this.btRules.Name = "btRules";
      this.btRules.Size = new System.Drawing.Size(75, 23);
      this.btRules.TabIndex = 6;
      this.btRules.Text = "Rules";
      this.btRules.UseVisualStyleBackColor = true;
      this.btRules.Click += new System.EventHandler(this.btRules_Click);
      // 
      // openFileDialog1
      // 
      this.openFileDialog1.FileName = "openFileDialog1";
      // 
      // btIcons
      // 
      this.btIcons.Location = new System.Drawing.Point(179, 57);
      this.btIcons.Name = "btIcons";
      this.btIcons.Size = new System.Drawing.Size(75, 23);
      this.btIcons.TabIndex = 7;
      this.btIcons.Text = "Add icons";
      this.btIcons.UseVisualStyleBackColor = true;
      this.btIcons.Click += new System.EventHandler(this.button1_Click);
      // 
      // label2
      // 
      this.label2.AutoSize = true;
      this.label2.Location = new System.Drawing.Point(24, 62);
      this.label2.Name = "label2";
      this.label2.Size = new System.Drawing.Size(45, 13);
      this.label2.TabIndex = 8;
      this.label2.Text = "Actions:";
      // 
      // cbFileType
      // 
      this.cbFileType.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
      this.cbFileType.FormattingEnabled = true;
      this.cbFileType.Items.AddRange(new object[] {
            "png",
            "dds",
            "bmp",
            "pcx",
            "jpg"});
      this.cbFileType.Location = new System.Drawing.Point(468, 12);
      this.cbFileType.Name = "cbFileType";
      this.cbFileType.Size = new System.Drawing.Size(45, 21);
      this.cbFileType.TabIndex = 10;
      this.cbFileType.SelectedIndexChanged += new System.EventHandler(this.cbFileType_SelectedIndexChanged);
      // 
      // tabControl1
      // 
      this.tabControl1.Controls.Add(this.tabPage1);
      this.tabControl1.Controls.Add(this.tabPage2);
      this.tabControl1.Dock = System.Windows.Forms.DockStyle.Top;
      this.tabControl1.Location = new System.Drawing.Point(0, 0);
      this.tabControl1.Name = "tabControl1";
      this.tabControl1.SelectedIndex = 0;
      this.tabControl1.Size = new System.Drawing.Size(1000, 130);
      this.tabControl1.TabIndex = 11;
      // 
      // tabPage1
      // 
      this.tabPage1.Controls.Add(this.label2);
      this.tabPage1.Controls.Add(this.btIcons);
      this.tabPage1.Controls.Add(this.btRules);
      this.tabPage1.Controls.Add(this.btResize);
      this.tabPage1.Controls.Add(this.btSymbols);
      this.tabPage1.Controls.Add(this.btBuildicons);
      this.tabPage1.Controls.Add(this.btOutput);
      this.tabPage1.Controls.Add(this.label1);
      this.tabPage1.Controls.Add(this.cbFileType);
      this.tabPage1.Location = new System.Drawing.Point(4, 22);
      this.tabPage1.Name = "tabPage1";
      this.tabPage1.Padding = new System.Windows.Forms.Padding(3);
      this.tabPage1.Size = new System.Drawing.Size(992, 104);
      this.tabPage1.TabIndex = 0;
      this.tabPage1.Text = "BuildIcons";
      this.tabPage1.UseVisualStyleBackColor = true;
      // 
      // tabPage2
      // 
      this.tabPage2.Controls.Add(this.btMapIcons);
      this.tabPage2.Controls.Add(this.label4);
      this.tabPage2.Controls.Add(this.btCombine);
      this.tabPage2.Controls.Add(this.label3);
      this.tabPage2.Location = new System.Drawing.Point(4, 22);
      this.tabPage2.Name = "tabPage2";
      this.tabPage2.Padding = new System.Windows.Forms.Padding(3);
      this.tabPage2.Size = new System.Drawing.Size(992, 104);
      this.tabPage2.TabIndex = 1;
      this.tabPage2.Text = "MapIcons";
      this.tabPage2.UseVisualStyleBackColor = true;
      // 
      // label3
      // 
      this.label3.AutoSize = true;
      this.label3.Location = new System.Drawing.Point(25, 20);
      this.label3.Name = "label3";
      this.label3.Size = new System.Drawing.Size(38, 13);
      this.label3.TabIndex = 6;
      this.label3.Text = "Setup:";
      // 
      // label4
      // 
      this.label4.AutoSize = true;
      this.label4.Location = new System.Drawing.Point(25, 58);
      this.label4.Name = "label4";
      this.label4.Size = new System.Drawing.Size(45, 13);
      this.label4.TabIndex = 11;
      this.label4.Text = "Actions:";
      // 
      // btCombine
      // 
      this.btCombine.Location = new System.Drawing.Point(85, 53);
      this.btCombine.Name = "btCombine";
      this.btCombine.Size = new System.Drawing.Size(75, 23);
      this.btCombine.TabIndex = 9;
      this.btCombine.Text = "Combine";
      this.btCombine.UseVisualStyleBackColor = true;
      this.btCombine.Click += new System.EventHandler(this.btCombine_Click);
      // 
      // btMapIcons
      // 
      this.btMapIcons.Location = new System.Drawing.Point(85, 15);
      this.btMapIcons.Name = "btMapIcons";
      this.btMapIcons.Size = new System.Drawing.Size(75, 23);
      this.btMapIcons.TabIndex = 12;
      this.btMapIcons.Text = "MapIcons";
      this.btMapIcons.UseVisualStyleBackColor = true;
      this.btMapIcons.Click += new System.EventHandler(this.btMapIcons_Click);
      // 
      // Form1
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.ClientSize = new System.Drawing.Size(1000, 665);
      this.Controls.Add(this.tabControl1);
      this.Controls.Add(this.groupBox1);
      this.Name = "Form1";
      this.Text = "Map icon builder";
      this.groupBox1.ResumeLayout(false);
      this.tabControl1.ResumeLayout(false);
      this.tabPage1.ResumeLayout(false);
      this.tabPage1.PerformLayout();
      this.tabPage2.ResumeLayout(false);
      this.tabPage2.PerformLayout();
      this.ResumeLayout(false);

    }

    #endregion

    private System.Windows.Forms.GroupBox groupBox1;
    private System.Windows.Forms.Panel panel1;
    private System.Windows.Forms.Button btBuildicons;
    private System.Windows.Forms.Button btSymbols;
    private System.Windows.Forms.Button btOutput;
    private System.Windows.Forms.Button btResize;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.Button btRules;
    private System.Windows.Forms.FolderBrowserDialog folderBrowserDialog1;
    private System.Windows.Forms.OpenFileDialog openFileDialog1;
    private System.Windows.Forms.Button btIcons;
    private System.Windows.Forms.Label label2;
    private System.Windows.Forms.ComboBox cbFileType;
    private System.Windows.Forms.TabControl tabControl1;
    private System.Windows.Forms.TabPage tabPage1;
    private System.Windows.Forms.TabPage tabPage2;
    private System.Windows.Forms.Button btMapIcons;
    private System.Windows.Forms.Label label4;
    private System.Windows.Forms.Button btCombine;
    private System.Windows.Forms.Label label3;

  }
}

