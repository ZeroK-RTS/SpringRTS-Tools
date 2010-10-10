using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace SpringModEdit
{
  public partial class FormChanges : Form
  {
    public FormChanges()
    {
      InitializeComponent();
    }

    public string Title {
      set {
        Text = value;
      }
    }

    public RichTextBox TextBox
    {
      get
      {
        return this.richTextBox1;
      }
    }
  }
}
