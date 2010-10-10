using System;
using System.Collections.Generic;
using System.Text;

namespace MapIconBuilder
{
  public class Conf:ConfigBase
  {
    public string BuildIconPath;
    public string SymbolPath;
    public string OutputPath;
    public string MapIconPath;
    public string TransformFile;
    public string Extension = "png";
  }
}
