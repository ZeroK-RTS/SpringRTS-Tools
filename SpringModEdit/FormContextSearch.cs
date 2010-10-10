using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace SpringModEdit
{
  public partial class FormContextSearch : Form
  {
    static string lastText =  "";

    public FormContextSearch()
    {
      InitializeComponent();
    }


    public string EnteredText {
      get {
        return textBox1.Text;
      }
    }

    private void button1_Click(object sender, EventArgs e)
    {
      lastText = textBox1.Text;
      Close();
    }

    private void FormContextSearch_Load(object sender, EventArgs e)
    {
      textBox1.Text = lastText;
    }
  }
}
