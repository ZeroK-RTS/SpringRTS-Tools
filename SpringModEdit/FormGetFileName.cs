using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace SpringModEdit
{
  public partial class FormGetFileName : Form
  {
    public string FileName {
      get {
        return textBox1.Text;
      }
      set {
        textBox1.Text = value;
      }
    }

    public FormGetFileName()
    {
      InitializeComponent();
    }

    private void btnOk_Click(object sender, EventArgs e)
    {
      DialogResult = DialogResult.OK;
      Close();
    }

    private void btnCancel_Click(object sender, EventArgs e)
    {
      DialogResult = DialogResult.Cancel;
      Close();
    }
  }
}
