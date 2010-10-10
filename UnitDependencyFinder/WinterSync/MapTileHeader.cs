using System.Runtime.InteropServices;

namespace MapReader
{
    [StructLayout(LayoutKind.Sequential)]
    struct MapTileHeader
    {
        public int numTileFiles; // Number of tile files to read in (usually 1)
        public int numTiles; // Total number of tiles
    }
}