using System;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace WinterSync
{
	public abstract class Archive : IDisposable
    {
        #region Fields

        static Encoding textEncoding = Encoding.GetEncoding("iso-8859-1");

        #endregion

        #region Properties

        public abstract string Name { get; }

        #endregion

        #region Constructors

        public abstract void Dispose();

        #endregion

        #region Public methods

        static public byte[] ExtracFile(string archiveName, string fileName)
        {
            using (var extractor = Open(archiveName)) return extractor.ExtractFile(fileName);
        }

        public abstract byte[] ExtractFile(string file);

        public string ExtractTextFile(string fileName)
        {
            return textEncoding.GetString(ExtractFile(fileName));
        }

        static public string ExtractTextFile(string archiveName, string fileName)
        {
            using (var extractor = Open(archiveName)) return extractor.ExtractTextFile(fileName);
        }

        public abstract string[] RawListFiles();

        public string[] ListFiles()
        {
            const string springIgnoreFileName = "springignore.txt";
            const char springIgnoreComment = '#';
            var rawFileList = RawListFiles();
            if (!rawFileList.Any(file => file == springIgnoreFileName)) return RawListFiles();
            var ignoreLines = ExtractTextFile(springIgnoreFileName).Replace("\r\n", "\n").Split('\n').ToArray();
            for (var i = 0; i < ignoreLines.Length; i++) {
                var pos = ignoreLines[i].IndexOf(springIgnoreComment);
                if (pos == -1) continue;
                ignoreLines[i] = ignoreLines[i].Substring(pos + 1);
            }
            ignoreLines = ignoreLines.Where(l => !String.IsNullOrEmpty(l)).ToArray();
            return RawListFiles().Where(file => !ignoreLines.Any(pattern => Regex.IsMatch(file, pattern))).ToArray();
        }

        public static Archive Open(string archive)
        {
            return archive.ToLower().EndsWith("sdz") ? (Archive) new ZipArchive(archive) : new SevenZipArchive(archive);
        }

        public static string[] ListFiles(string archiveName)
        {
            using (var archive = Open(archiveName)) {
                return archive.ListFiles();
            }
        }

        public static string[] RawListFiles(string archiveName)
        {
            using (var archive = Open(archiveName))
            {
                return archive.RawListFiles();
            }
        }
        
        #endregion
    }
}