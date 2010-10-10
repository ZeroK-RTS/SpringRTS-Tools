using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;
using System.Windows.Forms;

namespace MapIconBuilder
{
  class MyListener:TraceListener
  {
    StringBuilder sb = new StringBuilder();


    public override void Write(string message)
    {
      sb.Append(message);
    }

    public override void WriteLine(string message)
    {
      sb.AppendLine(message);
    }

    public string GetData()
    {
      return sb.ToString();
    }
  }
}
