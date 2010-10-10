using System;
using System.IO;
using System.Windows.Forms;
using System.Xml.Serialization;

namespace MapIconBuilder
{
  public class ConfigBase
  {
    /// <summary>
    /// Returns valid path to store config file
    /// </summary>
    /// <returns>valid path</returns>
    protected virtual string GetPath()
    {
      string path = Application.StartupPath;
      if (!Directory.Exists(path)) {
        Directory.CreateDirectory(path);
      }
      return path;
    }

    protected virtual string GetFileName()
    {
      return GetType() + ".xml";
    }


    protected virtual ConfigBase Load()
    {
      var xml = new XmlSerializer(GetType());

      try {
        using (var fs = new FileStream(GetPath() + "/" + GetFileName(), FileMode.Open)) {
          return (ConfigBase) xml.Deserialize(fs);
        }
      } catch {
        Save();
      }
      return null;
    }

    public virtual void Save()
    {
      var xml = new XmlSerializer(GetType());
      try {
        using (var fs = new FileStream(GetPath() + "/" + GetFileName(), FileMode.Create)) {
          xml.Serialize(fs, this);
        }
      } catch {
      }
    }

    public static T Load<T>() where T:ConfigBase, new()
    {
      var empty = new T();
      empty = (T) empty.Load();
      return empty ?? new T();
    }
  }
}