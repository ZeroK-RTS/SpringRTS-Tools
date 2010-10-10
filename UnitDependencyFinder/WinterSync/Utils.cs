using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using ICSharpCode.SharpZipLib.Core;

namespace WinterSync
{
    static class Utils
    {
        public static byte[] ToArray(this Stream stream)
        {
            var buffer = new byte[4096];
            var memoryStream = new MemoryStream();
            StreamUtils.Copy(stream, memoryStream, buffer);
            return memoryStream.ToArray();
        }
    }
}
