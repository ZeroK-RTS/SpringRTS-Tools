using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using DevIL;

namespace MapIconBuilder
{
  public class IconTransform
  {
    private const char IconSeparator = '|';
    private const char ParamSeparator = ';';
    private readonly string name;
    private readonly string path;
    private readonly List<Symbol> symbols = new List<Symbol>();
    private Image image;

    public IconTransform(string dataLine)
    {
      string[] icons = dataLine.Split(new[] {IconSeparator}, StringSplitOptions.RemoveEmptyEntries);
      if (icons.Length == 0) throw new ApplicationException("Incorrect data line: " + dataLine);

      path = icons[0];
      name = Path.GetFileNameWithoutExtension(path);
      for (int i = 1; i < icons.Length; ++i)
      {
        string[] pars = icons[i].Split(new[] {ParamSeparator}, StringSplitOptions.RemoveEmptyEntries);
        if (pars.Length >= 5)
        {
          if (pars[0].ToLower() != "default.png") {
            var s = new Symbol {Name = pars[0], X = Convert.ToInt32(pars[1]), Y = Convert.ToInt32(pars[2]), W = Convert.ToInt32(pars[3]), H = Convert.ToInt32(pars[4]),};
            s.HasColor = pars.Length >= 8;
            if (s.HasColor) {
              s.R = Convert.ToSingle(pars[5]);
              s.G = Convert.ToSingle(pars[6]);
              s.B = Convert.ToSingle(pars[7]);
            }

            symbols.Add(s);
          }
        }
      }
    }


    public Image Image
    {
      get { return image; }
    }

    public static Color FromFloatRgb(double r, double g, double b)
    {
      return Color.FromArgb((int) (r*255), (int) (g*255), (int) (b*255));
    }

    public void Load()
    {
      try {
        image = LoadImage(string.Format("{0}/{1}", Program.Conf.BuildIconPath, path), 96, 96);
      } catch (Exception ex) {
        Trace.WriteLine(string.Format("Error loading {0}:{1}", name, ex.Message));
        return;
      }
    }


    public void Process()
    {
      if (image != null)
      {
        foreach (Symbol s in symbols)
        {
          try
          {
            AddIcon(image, s);
          }
          catch (Exception ex)
          {
            Trace.WriteLine(string.Format("Error adding symbol {0} to {1}: {2}", s.Name, name, ex.Message));
          }
        }
      }
    }

    public void Save()
    {
      string target = string.Format("{0}/{1}.{2}", Program.Conf.OutputPath, name, Program.Conf.Extension);
      if (File.Exists(target)) File.Delete(target);
      if (image != null) DevIL.DevIL.SaveBitmap(target, (Bitmap) image);
    }

    private static Bitmap LoadImage(string path, int x, int y)
    {
      Bitmap bm;
      if (x != 0 && y != 0)
        bm = DevIL.DevIL.LoadBitmapAndScale(path, x, y, DevILScaleFilter.BILINEAR, DevILScaleKind.WIDTH_AND_HEIGHT);
      else bm = DevIL.DevIL.LoadBitmap(path);

      if (bm == null) throw new ApplicationException("Cannot load image " + path);
      return bm.Clone(new Rectangle(0, 0, bm.Width, bm.Height), PixelFormat.Format32bppArgb);
    }

    private static Bitmap LoadImage(string path)
    {
      return LoadImage(path, 0, 0);
    }

    private static void AddIcon(Image image, Symbol s)
    {
      using (Graphics gr = Graphics.FromImage(image))
      {
        var atribs = new ImageAttributes();
        if (s.HasColor)
        {
          var mat = new ColorMatrix();
          mat.Matrix00 = s.R;
          mat.Matrix11 = s.G;
          mat.Matrix22 = s.B;
          mat.Matrix33 = 1;
          mat.Matrix44 = 1;
          atribs.SetColorMatrix(mat);
        }
        if (s.Name == "lrm.png")
        {
          Console.WriteLine("got");
        }

        s.Load();


        gr.DrawImage(s.Bitmap, new Rectangle(s.X, s.Y, s.W, s.H), s.Bounds.X, s.Bounds.Y, s.Bounds.Width, s.Bounds.Height, GraphicsUnit.Pixel, atribs);
      }
    }


    public static Rectangle GetBounds(Bitmap bm)
    {
      int minx = int.MaxValue;
      int maxx = 0;
      int miny = int.MaxValue;
      int maxy = 0;
      for (int x = 0; x < bm.Width; x++) {

        for (int y = 0; y < bm.Height; y++)
        {
          Color c = bm.GetPixel(x, y);
          if (c.A != 0)
          {
            if (x < minx) minx = x;
            if (x > maxx) maxx = x;
            if (y < miny) miny = y;
            if (y > maxy) maxy = y;
          }
        }
      }
      return new Rectangle(minx,miny, maxx - minx + 1, maxy-miny+1);
    }

    #region Nested type: Symbol

    public class Symbol
    {
      public Bitmap Bitmap;
      public Rectangle Bounds;
      public float B;
      public float G;
      public int H;
      public bool HasColor;
      public string Name;
      public float R;
      public int W;
      public int X, Y;

      public void Load()
      {
        Bitmap = LoadImage(Program.Conf.SymbolPath + "/" + Name);
        Bounds = GetBounds(Bitmap);
      }
    }

    #endregion
  }
}