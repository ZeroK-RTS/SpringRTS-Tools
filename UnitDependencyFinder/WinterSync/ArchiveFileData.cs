using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace WinterSync
{
	public interface IArchiveFileData
    {
        Stream Stream { get; }
        string Text { get; }
        string ArchiveName { get; }
        string FileName { get; }
        byte[] Bytes { get; }
    }
}
