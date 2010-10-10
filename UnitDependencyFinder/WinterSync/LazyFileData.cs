using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace WinterSync
{
    class LazyFileData : IArchiveFileData
    {
        readonly Archive archive;
        static readonly Encoding textEncoding = Encoding.GetEncoding("iso-8859-1"); 

        public LazyFileData(string fileName, Archive archive)
        {
            FileName = fileName;
            this.archive = archive;
            ArchiveName = archive.Name;
        }

        public Stream Stream
        {
            get { return new MemoryStream(bytes); }
        }

        string text;
        public string Text
        {
            get
            {
                if (text != null) return text;
                text = textEncoding.GetString(bytes);
                return text;
            }
        }

        public string ArchiveName { get; set; }

        public string FileName { get; set; }

        byte[] bytes;

        public byte[] Bytes
        {
            get
            {
                if (bytes != null) return bytes;
                bytes = archive.ExtractFile(FileName);
                return bytes;
            }
        }
    }
}
