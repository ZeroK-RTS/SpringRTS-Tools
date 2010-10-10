using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.IO;
using System.Threading;
using SevenZip;

namespace MapReader
{
    public class SM2
    {
        public event ProgressChangedEventHandler ProgressChanged = delegate { };

        static byte[] ExtractFile(string archive, string file)
        {
            if (!archive.ToLower().EndsWith("sdz") && !archive.ToLower().EndsWith("sd7")) throw new ArgumentException("Invalid archive name");
            var stream = new MemoryStream();
            var format = archive.EndsWith("sdz") ? InArchiveFormat.Zip : InArchiveFormat.SevenZip;

            // extract the file synchronously
            var thread = new Thread(() =>
                                    {
                                        using (var extractor = new SevenZipExtractor(File.OpenRead(archive), format)) {
                                            extractor.ExtractFile(file, stream, true);
                                        }
                                    });
            thread.Start();
            thread.Join();
            stream.Position = 0;
            return stream.ToArray();
        }

        /// <summary>
        /// Returns a SM2 map texuture
        /// </summary>
        public Bitmap GetTexture(string mapArchive, string mapName, int detail)
        {
            int height;
            int width;
            return GetTexture(mapArchive, mapName, detail, out width, out height);
        }

        /// <summary>
        /// Returns n SM2 map texuture
        /// </summary>
        public Bitmap GetTexture(string mapArchive, string mapName, int detail, out int width, out int height)
        {
            if (!mapName.ToLower().EndsWith("smf")) throw new ArgumentException("Invalid map name");
            if (!mapArchive.ToLower().EndsWith("sdz") && !mapArchive.ToLower().EndsWith("sd7")) throw new ArgumentException("Invalid map archive");
            ProgressChanged(this, new ProgressChangedEventArgs(0, "Extracting map"));

            var reader = new BinaryReader(new MemoryStream(ExtractFile(mapArchive, "maps\\" + mapName)));
            var smfHeader = reader.ReadStruct<SMFHeader>();
            smfHeader.SelfCheck();
            width = smfHeader.mapx;
            height = smfHeader.mapy;

            reader.BaseStream.Position = smfHeader.tilesPtr;
            var mapTileHeader = reader.ReadStruct<MapTileHeader>();

            // get the tile files and the number of tiles they contain
            var tileFiles = new Dictionary<byte[], int>();
            for (var i = 0; i < mapTileHeader.numTileFiles; i++) {
                var numTiles = reader.ReadInt32();
                tileFiles.Add(ExtractFile(mapArchive, "maps\\" + reader.ReadCString()), numTiles);
            }

            // get the position of the tiles
            var mapUnitInTiles = Tiles.TileMipLevel1Size/smfHeader.texelPerSquare;
            var tilesX = smfHeader.mapx/mapUnitInTiles;
            var tilesY = smfHeader.mapy/mapUnitInTiles;
            var tileIndices = new int[tilesX*tilesY];
            for (var i = 0; i < tileIndices.Length; i++) {
                tileIndices[i] = reader.ReadInt32();
            }

            Tiles.ProgressChanged += (s, e) => ProgressChanged(this, e);

            // load the tiles
            return Tiles.LoadTiles(tileFiles, tileIndices, tilesX, tilesY, detail);
            
        }
    }
}