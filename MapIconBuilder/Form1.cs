using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Windows.Forms;

namespace MapIconBuilder
{
  public partial class Form1 : Form
  {
    public static Image LoadImage(string path)
    {
      Bitmap bm = DevIL.DevIL.LoadBitmap(path);
      return (Image)bm.Clone(new Rectangle(0, 0, bm.Width, bm.Height), PixelFormat.Format32bppArgb);
    }

    public Form1()
    {
      InitializeComponent();
      CheckSettings();
      cbFileType.SelectedItem = Program.Conf.Extension;
    }

    private void btBuildicons_Click(object sender, System.EventArgs e)
    {
      folderBrowserDialog1.Description = "Select folder with buildicons";
      folderBrowserDialog1.SelectedPath = Program.Conf.BuildIconPath;
      folderBrowserDialog1.ShowDialog();
      Program.Conf.BuildIconPath = folderBrowserDialog1.SelectedPath;
      CheckSettings();
    }

    private void btSymbols_Click(object sender, System.EventArgs e)
    {
      folderBrowserDialog1.Description = "Select folder with map icons";
      folderBrowserDialog1.SelectedPath = Program.Conf.SymbolPath;
      folderBrowserDialog1.ShowDialog();
      Program.Conf.SymbolPath = folderBrowserDialog1.SelectedPath;
      CheckSettings();
    }

    private void CheckSettings()
    {
      bool err = false;
      if (!Directory.Exists(Program.Conf.BuildIconPath)) {
        err = true;
        btBuildicons.ForeColor = Color.Red;
      } else btBuildicons.ForeColor = Color.Black;

      if (!Directory.Exists(Program.Conf.SymbolPath)) {
        err = true;
        btSymbols.ForeColor = Color.Red;
      } else btSymbols.ForeColor = Color.Black;

      if (!Directory.Exists(Program.Conf.OutputPath)) {
        err = true;
        btOutput.ForeColor = Color.Red;
      } else btOutput.ForeColor = Color.Black;

      if (!File.Exists(Program.Conf.TransformFile)) {
        err = true;
        btRules.ForeColor = Color.Red;
      } else btRules.ForeColor = Color.Black;
      btResize.Enabled = !err;
      btIcons.Enabled = !err;


      bool errComb = false;
      if (!Directory.Exists(Program.Conf.MapIconPath))
      {
        errComb = true;
        btMapIcons.ForeColor = Color.Red;
      } else btMapIcons.ForeColor = Color.Black;

      btCombine.Enabled = !errComb;
    }

    private void btRules_Click(object sender, System.EventArgs e)
    {
      openFileDialog1.Title = "Select file containing rules for adding icons";
      openFileDialog1.FileName = Program.Conf.TransformFile;
      openFileDialog1.ShowDialog();
      Program.Conf.TransformFile = openFileDialog1.FileName;
      CheckSettings();

    }

    private void btOutput_Click(object sender, System.EventArgs e)
    {
      folderBrowserDialog1.Description = "Select output folder";
      folderBrowserDialog1.SelectedPath = Program.Conf.OutputPath;
      folderBrowserDialog1.ShowDialog();
      Program.Conf.OutputPath = folderBrowserDialog1.SelectedPath;
      CheckSettings();
    }

    

    private void btProcess_Click(object sender, System.EventArgs e)
    {
      Process(false);
    }

    private void Process(bool transform)
    {
      MyListener ml = new MyListener();
      Trace.Listeners.Add(ml);

      Program.Conf.Save();
      List<IconTransform> itList = new List<IconTransform>();

      foreach (string s in File.ReadAllText(Program.Conf.TransformFile).Split(new char[] {'\n', '\r'}, StringSplitOptions.RemoveEmptyEntries))
      {
        try
        {
          IconTransform it = new IconTransform(s);
          itList.Add(it);
        } catch (Exception ex)
        {
          Trace.WriteLine("Cannot parse " + s + ":" + ex.Message);
        }
      }



      int cnt = 0;
      int num = panel1.Width/100;
      panel1.Controls.Clear();
      foreach(IconTransform it in itList)
      {
        it.Load();
        if (transform) it.Process();
        if (it.Image != null)
        {
          PictureBox pb = new PictureBox();
          pb.Image = it.Image;
          pb.Width = it.Image.Width;
          pb.Height = it.Image.Height;
          pb.Location = new Point((cnt%num)*100, (cnt/num)*100);
          panel1.Controls.Add(pb);
          cnt++;
        }
        it.Save();
      }

      string res = ml.GetData();
      if (res != null) {
        Console.WriteLine(res);
        MessageBox.Show(res);
      }
    }

    private void button1_Click(object sender, EventArgs e)
    {
      Process(true);
    }

    private void cbFileType_SelectedIndexChanged(object sender, EventArgs e)
    {
      Program.Conf.Extension = cbFileType.SelectedItem as string;
    }

    private void btMapIcons_Click(object sender, EventArgs e)
    {
      folderBrowserDialog1.Description = "Select path with map icons to combine";
      folderBrowserDialog1.SelectedPath = Program.Conf.MapIconPath;
      folderBrowserDialog1.ShowDialog();
      Program.Conf.MapIconPath = folderBrowserDialog1.SelectedPath;
      CheckSettings();

    }

    private void btCombine_Click(object sender, EventArgs e)
    {
      Program.Conf.Save();
      string[] categories = Directory.GetDirectories(Program.Conf.MapIconPath);
      int maxCnt = categories.Length;
      int[] position = new int[maxCnt];
      List<string>[] names = new List<string>[maxCnt];

      for (int i = 0; i < maxCnt; i++)
      {
        position[i] = 0;
        names[i] = new List<string>();
        foreach (string s in Directory.GetFiles(categories[i], "*.png"))
        {
          names[i].Add(s);
        }
      }


      int colCount = panel1.Width / 150;
      int num = 0;
      panel1.Controls.Clear();
      do
      {
        Bitmap original = null;
        string name = "";
        for (int i = 0; i < maxCnt; i++)
        {
          if (names[i].Count <= 0) continue;
          Bitmap next = DevIL.DevIL.LoadBitmap(names[i][position[i]]);
          name += Path.GetFileNameWithoutExtension(names[i][position[i]]);
          if (original == null)
          {
            original = next;
            continue;
          }
          using (Graphics gr = Graphics.FromImage(original))
          {
            gr.DrawImage(next, 0,0);
          }
        }

        string targetFileName = Program.Conf.MapIconPath + "/" + name + ".png";
        if (File.Exists(targetFileName)) File.Delete(targetFileName);
        DevIL.DevIL.SaveBitmap(targetFileName, original);
        

        PictureBox pb = new PictureBox();
        pb.Image = original;
        pb.Width = original.Width;
        pb.Height = original.Height;
        pb.Location = new Point((num%colCount) * 150, (num/colCount)*150);
        panel1.Controls.Add(pb);

        num++;

        
        for (int i = maxCnt - 1; i >= 0; i--)
        {
          position[i]++;
          if (position[i] < names[i].Count) break;
          if (i == 0 && position[i] > names[i].Count) return;
          position[i] = 0;
        }
      } while (true); 
    }
  }
}
