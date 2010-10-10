using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace FilesFinder2
{
	internal class Model3do
	{
		// Root peice of the model 
		public Piece Root;

		public static List<string> TextureNames = new List<string>();

		/// (summary) 
		/// Primitive - FIXME: Lacks definition 
		/// (/summary) 
		internal struct Primitive
		{
			public int[] VertexArray;
			public long Offset;
			public String TextureName;
		}

		/// (summary) 
		/// Definition of a vertex 
		/// (/summary) 
		internal struct Vertex
		{
			public int X, Y, Z;

			public Vertex(int x, int y, int z)
			{
				X = x;
				Y = y;
				Z = z;
			}
		}

		/// (summary) 
		/// Defines a piece of the model 
		/// (/summary) 
		internal class Piece
		{
			// Instance fields 
			public Vertex[] Vertexes; // Vertices of this piece 
			public Primitive[] primitives; // Faces of this model 
			public ArrayList Children; // Children of this object 
			public Vertex ParentOffset; // Offset from parent 
			public Piece Parent; // Parent in the hierarchy 
			public String Name; // Name of this object 

			/// (summary) 
			/// Read in this piece from the file (Root) 
			/// (/summary) 
			/// (param name="fileReader")File Reader(/param) 
			public Piece(BinaryReader fileReader) : this(fileReader, 0, null) { }

			/// (summary) 
			/// Read a piece in from the file. 
			/// (/summary) 
			/// (param name="fileReader")File Reader(/param) 
			/// (param name="depth")Depth(/param) 
			public Piece(BinaryReader fileReader, int depth, Piece parent)
			{
				// Create objects 
				Children = new ArrayList();

				// Set parent & store origin 
				Parent = parent;
				long startPos = fileReader.BaseStream.Position;

				// Load parameters 
				fileReader.ReadInt32(); // Version sig 
				int vertices = fileReader.ReadInt32(); // # of vertices 
				int primatives = fileReader.ReadInt32(); // # of primatives 
				fileReader.ReadInt32(); // Offset to the selection primative (Always -1/base) 

				// Get the offset from the parent and rea the name 
				ParentOffset = new Vertex(fileReader.ReadInt32(), fileReader.ReadInt32(), fileReader.ReadInt32());
				Name = ReadString(fileReader, fileReader.ReadInt32());
				fileReader.ReadInt32(); // Skip an always zero set of bytes. 

				// Vertices and faces 
				int vertexOffset = fileReader.ReadInt32(); // Vertex array offset 
				int primativesOffset = fileReader.ReadInt32(); // Primitive array offset 
				int siblingOffset = fileReader.ReadInt32(); // Sibling Piece offset 
				int childOffset = fileReader.ReadInt32(); // Child piece offset 

				// Process siblings first 
				if (siblingOffset > 0)
				{
					fileReader.BaseStream.Seek(siblingOffset, SeekOrigin.Begin);
					Parent.Children.Add(new Piece(fileReader, depth, Parent));
				}

				// Then ourselves 
				//for (int x = 0; x < depth; x++) Console.Write("-");
				//Console.WriteLine("-)Piece: {0} ({1} Vertices, {2} Faces)", Name, vertices, primatives);

				// Then our children 
				if (childOffset > 0)
				{
					fileReader.BaseStream.Seek(childOffset, SeekOrigin.Begin);
					Children.Add(new Piece(fileReader, (depth + 1), this));
				}

				// Load the vertex array 
				LoadVertices(fileReader, vertexOffset, vertices);

				// Load primatives 
				LoadPrimatives(fileReader, primativesOffset, primatives);

				// Return to start of file 
				fileReader.BaseStream.Seek(startPos, SeekOrigin.Begin);
			}

			/// (summary) 
			/// Load the vertices of the piece 
			/// (/summary) 
			/// (param name="fileReader")File stream(/param) 
			/// (param name="offset")Start of list(/param) 
			/// (param name="count")Number of vertices(/param) 
			public void LoadVertices(BinaryReader fileReader, long offset, int count)
			{
				Vertexes = new Vertex[count];
				fileReader.BaseStream.Seek(offset, SeekOrigin.Begin);
				for (int x = 0; x < count; x++) Vertexes[x] = new Vertex(fileReader.ReadInt32(), fileReader.ReadInt32(), fileReader.ReadInt32());
			}


			/// (summary) 
			/// Load the primatives and their vertex lists 
			/// (/summary) 
			/// (param name="fileReader")File stream(/param) 
			/// (param name="offset")Start of list(/param) 
			/// (param name="count")Number of primatives(/param) 
			public void LoadPrimatives(BinaryReader fileReader, long offset, int count)
			{
				// Load the primatives list 
				primitives = new Primitive[count];
				fileReader.BaseStream.Seek(offset, SeekOrigin.Begin);
				for (int x = 0; x < count; x++)
				{
					// Create a new primative 
					Primitive p = new Primitive();

					// Load the properties 
					fileReader.ReadInt32(); // Skip colour index 
					p.VertexArray = new int[fileReader.ReadInt32()]; // Create vertex list 
					fileReader.ReadInt32(); // Always Zero 
					p.Offset = fileReader.ReadInt32(); // Offset to vertex array 
					p.TextureName = ReadString(fileReader, fileReader.ReadInt32());
					TextureNames.Add(p.TextureName);
					primitives[x] = p;

					// Skip three unknowns 
					fileReader.ReadInt32();
					fileReader.ReadInt32();
					fileReader.ReadInt32();
				}

				// Now for each primative, load the vertex list 
				foreach (Primitive p in primitives)
				{
					fileReader.BaseStream.Seek(p.Offset, SeekOrigin.Begin);
					for (int x = 0; x < p.VertexArray.Length; x++)
					{
						// Read the ID of the vertex from the piece's vertex list 
						p.VertexArray[x] = fileReader.ReadInt16(); // FIXED:- Was int16, not 32! 
					}
				}
			}
		}

		/// (summary) 
		/// Load a model from file 
		/// (/summary) 
		/// (param name="fileName")The model to load(/param) 
		public Model3do(String fileName)
		{
			// Verify the file path 
			FileInfo file = new FileInfo(fileName);
			if (!file.Exists) return;

			// Open the stream and binary reader 
			using (FileStream fileStream = new FileStream(fileName, FileMode.Open)) {
				using (BinaryReader fileReader = new BinaryReader(fileStream)) {
					Root = new Piece(fileReader);
				}
			}
		}

		/// (summary) 
		/// Read a null terminated string from this file at a specified index, 
		/// then return to the position we were at in the file originally. 
		/// (/summary) 
		/// (param name="fileReader")Binary stream reader(/param) 
		/// (param name="start")Start of the null terminated string(/param) 
		/// (returns)String(/returns) 
		public static String ReadString(BinaryReader fileReader, long start)
		{
			// Store the start position 
			long oldPos = fileReader.BaseStream.Position;

			// Move to the start of the string 
			fileReader.BaseStream.Seek(start, SeekOrigin.Begin);

			// Read only 128 chars max 
			Byte[] stringBytes = new Byte[128];
			for (int loop = 0; loop < 128; loop++)
			{
				// Read a byte 
				stringBytes[loop] = fileReader.ReadByte();

				// If it's the null terminator, break out 
				if (stringBytes[loop].Equals(Byte.MinValue))
				{
					// Move home 
					fileReader.BaseStream.Seek(oldPos, SeekOrigin.Begin);

					// Build string 
					return Encoding.ASCII.GetString(stringBytes, 0, loop);
				}
			}

			// Return to position & return the string thus far 
			fileReader.BaseStream.Seek(oldPos, SeekOrigin.Begin);
			return Encoding.ASCII.GetString(stringBytes, 0, 128);
		}
	}
}
