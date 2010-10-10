using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Windows.Forms;
using System.IO;
using LuaInterface;
using System.Collections;

//http://trepan.bzflag.bz/spring/lua/paramMaps/

namespace SpringModEdit
{
  static class Program
  {
    [STAThread]
    static void Main()
    {
      Process.GetCurrentProcess().ProcessorAffinity = (IntPtr)1;
      Directory.SetCurrentDirectory(Application.StartupPath);
      System.Threading.Thread.CurrentThread.CurrentCulture = System.Globalization.CultureInfo.InvariantCulture;
      Application.EnableVisualStyles();
      FormMain form = new FormMain();
      Application.Run(form);

    }
  }
}



