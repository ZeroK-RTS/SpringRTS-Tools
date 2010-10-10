using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using SevenZip;

namespace WinterSync
{
    class SevenZipArchive : Archive
    {
        SevenZipExtractor extractor;
        public SevenZipArchive(string archive)
        {
            extractor = new SevenZipExtractor(File.OpenRead(archive), InArchiveFormat.SevenZip);
        }

        public override byte[] ExtractFile(string file)
        {
            var waitHandle = new EventWaitHandle(false, EventResetMode.ManualReset);
            var stream = new MemoryStream();
            extractor.FileExtractionFinished += (s, e) =>
                                                    {
                                                        stream.Position = 0;
                                                        waitHandle.Set();
                                                    };
            waitHandle.WaitOne();
            extractor.ExtractFile(file.Replace("/", "\\"), stream, true);
            return stream.ToArray();

        }

        public override string[] RawListFiles()
        {
            return extractor.ArchiveFileNames.ToArray();
        }

        public override void Dispose()
        {
            extractor.Dispose();
        }

        public override string Name
        {
            get { return extractor.FileName; }
        }
    }
}
