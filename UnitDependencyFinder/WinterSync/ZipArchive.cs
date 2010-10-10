using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using ICSharpCode.SharpZipLib.Core;
using ICSharpCode.SharpZipLib.Zip;

namespace WinterSync
{
    class ZipArchive : Archive
    {
        ZipFile extractor;
        public ZipArchive(string archive)
        {
            extractor = new ZipFile(archive);
        }

        public override byte[] ExtractFile(string file)
        {
            using (var stream = extractor.GetInputStream(new ZipEntry(file.Replace("\\", "/")))) {
                return stream.ToArray();
            }
        }

        public override string[] RawListFiles()
        {
            return extractor.Cast<ZipEntry>().Select(e => e.Name).ToArray();
        }

        public override void Dispose()
        {
            extractor.Close();
        }

        public override string Name
        {
            get { return extractor.Name; }
        }
    }
}
