using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using FilesFinder2.Properties;
using Tao.Lua;
using WinterSync;

namespace FilesFinder2
{
	class FilesFinder
	{
		static IntPtr L;
		string buildpic;
		List<string> customExplosions;
		ModInfo mod;
		List<string> models = new List<string>();
		List<string> scripts = new List<string>();
		List<string> sounds = new List<string>();
		List<string> texturesS3o = new List<string>();
		List<string> textures3do = new List<string>();
		string unitFilePath;
		readonly string unitName;
		List<string> weaponFiles = new List<string>();
		string[] explosionTextureNames;
		string[] expTextures;
		string[] expFiles;
		string resourceLines;
		List<string> customTextures = new List<string>();
		string groundDecal;

		static FilesFinder()
		{
			L = Lua.luaL_newstate();
			Lua.luaL_openlibs(L);
			CLua.TraceDoString(L, 0, Resources.luastuff);
		}

		public FilesFinder(string unitName, ModInfo mod)
		{
			this.mod = mod;
			this.unitName = unitName;
			unitFilePath = FixPath(mod.ModFolder + "\\units\\" + unitName + ".lua");
			ProcessUnitFile();
			explosionTextureNames = customExplosions.Where(e => mod.ExplosionTextures.ContainsKey(e)).SelectMany(e => mod.ExplosionTextures[e]).Concat(customTextures).ToArray();
			expTextures = explosionTextureNames.Where(e => mod.ProjectileTextures.ContainsKey(e)).Select(e => mod.ProjectileTextures[e]).Select(FixPath).Distinct().ToArray();

			expFiles = customExplosions.Where(e => mod.ExplosionFiles.ContainsKey(e)).SelectMany(e => mod.ExplosionFiles[e]).Distinct().Select(FixPath).ToArray();

			resourceLines = String.Join("\n",
											   explosionTextureNames.Where(n => mod.ProjectileTextures.ContainsKey(n)).Select(n => "      " + n + "= \"" +
																			mod.ProjectileTextures[n].Replace(mod.ModFolder + "/bitmaps/", String.Empty) + "\",").
			                                   	ToArray());

		}

		public void Print() {

			Debug.WriteLine("================= " + unitName + " ====================");

			Debug.WriteLine("");
			Debug.WriteLine("Unit File: ");
			Debug.WriteLine(unitFilePath);

			Debug.WriteLine("");
			Debug.WriteLine("Resources Lines: ");
			Debug.WriteLine(resourceLines);

			Debug.WriteLine("");
			Debug.WriteLine("Effect Files: ");
			foreach (var l in expFiles) Debug.WriteLine(l);

			Debug.WriteLine("");
			Debug.WriteLine("Effect Texture Files: ");
			foreach (var l in expTextures) Debug.WriteLine(l);

			Debug.WriteLine("");
			Debug.WriteLine("Models: ");
			foreach (var l in models) Debug.WriteLine(l);

			Debug.WriteLine("");
			Debug.WriteLine("Buildpic: ");
			Debug.WriteLine(buildpic);

			Debug.WriteLine("");
			Debug.WriteLine("Sounds: ");
			foreach (var l in sounds) Debug.WriteLine(l);

			Debug.WriteLine("");
			Debug.WriteLine("Model Textures: ");
			foreach (var l in texturesS3o) Debug.WriteLine(l);

			Debug.WriteLine("");
			Debug.WriteLine("3do Textures: ");
			foreach (var l in textures3do) Debug.WriteLine(l);

			Debug.WriteLine("");
			Debug.WriteLine("Animation Scripts: ");
			foreach (var l in scripts) Debug.WriteLine(l);

			Debug.WriteLine("");
			Debug.WriteLine("Death weapon: ");
			foreach (var l in weaponFiles) Debug.WriteLine(l);

			Debug.WriteLine("");
			Debug.WriteLine("Ground Decal: ");
			Debug.WriteLine(groundDecal);


		}

		public string CopyTo(string destination)
		{
			CopyFile(unitFilePath, destination);
			CopyFile(buildpic, destination);
			CopyFile(groundDecal, destination);
			CopyFiles(expFiles, destination);
			CopyFiles(expTextures, destination);
			CopyFiles(models, destination);
			CopyFiles(sounds, destination);
			CopyFiles(texturesS3o, destination);
			CopyFiles(scripts, destination);
			CopyFiles(weaponFiles, destination);
			CopyFiles(textures3do, destination);
			CopyFile(groundDecal, destination);
			return resourceLines;
		}

		public static string FixPath(string path)
		{
			return path.Replace("\\", "/").Replace("//", "/").ToLower();
		}

		void CopyFile(string filePath, string destinationFolder)
		{
			if (!string.IsNullOrEmpty(filePath)) {
				var destinationPath = filePath.Replace(mod.ModFolder, destinationFolder);
				Debug.WriteLine("Copying: " + filePath);
				Directory.CreateDirectory(Path.GetDirectoryName(destinationPath));
				if (File.Exists(filePath) && !File.Exists(destinationPath)) {
					File.Copy(filePath, destinationPath);
				}
			}
		}
		void CopyFiles(IEnumerable<string> filePaths, string destinationFolder)
		{
			foreach (var filePath in filePaths)
			{
				CopyFile(filePath, destinationFolder);
			}
		}

		static public IEnumerable<string> GetS3oTextures(string filepath)
		{
			var textures = new List<string>();
			using (var br = new BinaryReader(new FileStream(filepath, FileMode.Open))) {
				br.BaseStream.Seek(44, SeekOrigin.Begin);
				var texoffset1 = br.ReadInt32();
				var texoffset2 = br.ReadInt32();
				textures.Add(GetS3oTexture(br, texoffset1, texoffset2));
				if (texoffset2 > 0) 
				{
					textures.Add(GetS3oTexture(br, texoffset2, 0));
				}
				
				foreach (var t in new List<string>(textures)) {
					var nam = Path.GetFileNameWithoutExtension(t);
					while (Char.IsNumber(nam[nam.Length - 1])) nam = nam.Substring(0, nam.Length - 2);
					var normals = nam + "_normals.dds";
					textures.Add(normals);
				}
			}
			return textures;
		}

		static string GetS3oTexture(BinaryReader br, int start, int end)
		{
			if (end == 0) end = (int)br.BaseStream.Length;
			if (start > 0)
			{
				br.BaseStream.Seek(start, SeekOrigin.Begin);
				var tex = br.ReadChars(end - start - 1);
				return new string(tex);
			}
			throw new Exception();
		}

		static IEnumerable<string> Get3doTextures (string filePath)
		{
			new Model3do(filePath);
			var textureNames = Model3do.TextureNames.Distinct().ToArray();
			Model3do.TextureNames.Clear();
			return textureNames.Select(t => t.ToLower());
		}

		void ProcessUnitFile()
		{
			customExplosions = new List<string>();
			var modelFileNames = new List<string>();
			var soundNames = new List<string>();

			dynamic unitTable = CLua.TraceDoString(L, 1, File.ReadAllText(unitFilePath))[0].GetField(unitName);
			var objectName = unitTable.GetField("objectname");
			modelFileNames.Add(objectName.Value);
			buildpic = FixPath(mod.ModFolder + "/unitpics/" + unitTable.GetField("buildpic").Value);
			var sfxTypes = unitTable.GetField("sfxtypes");
			if (sfxTypes is LuaTable)
			{
				var explosionGenerators = sfxTypes.GetField("explosiongenerators");
				if (explosionGenerators is LuaTable)
				{
					foreach (var kvp in explosionGenerators.Values)
					{
						var value = kvp.Value.Value;
						if (value.StartsWith("custom:")) customExplosions.Add(value.Substring(7, value.Length - 7).ToLower());
					}
				}
			}
			string explodeAs = unitTable.GetField("explodeas").Value.ToLower();
			if (mod.WeaponExplosions.ContainsKey(explodeAs))
			{
				customExplosions.Add(mod.WeaponExplosions[explodeAs]);
				weaponFiles.Add(mod.WeaponFiles[explodeAs]);
			} 
			else
			{
				customExplosions.Add(explodeAs);
			}


			var weaponDefs = unitTable.GetField("weapondefs");
			if (weaponDefs is LuaTable)
			{
				foreach (var kvp in weaponDefs.Values)
				{
					var weaponDef = kvp.Value;
					var explosionGenerator = weaponDef.GetField("explosiongenerator");
					if (explosionGenerator != null)
					{
						var value = explosionGenerator.Value;
						if (value.StartsWith("custom:")) customExplosions.Add(value.Substring(7, value.Length - 7).ToLower());
					}
					var cegTag = weaponDef.GetField("cegtag");
					if (cegTag != null) customExplosions.Add(cegTag.Value.ToLower());
					var model = weaponDef.GetField("model");
					if (model != null) modelFileNames.Add(model.Value);
					var soundHit = weaponDef.GetField("soundhit");
					if (soundHit != null) soundNames.Add(soundHit.Value);
					var soundStart = weaponDef.GetField("soundstart");
					if (soundStart != null) soundNames.Add(soundStart.Value);
					for (var i = 1; i <= 10; i++)
					{
						var texture = weaponDef.GetField("texture" + i);
						if (texture != null) customTextures.Add(texture.Value.ToLower());
					}
				}
			}

			var groundDecalType = unitTable.GetField("buildinggrounddecaltype");
			if (groundDecalType is LuaString) groundDecal = mod.ModFolder + "/unittextures/" + groundDecalType.Value;

			var scriptField = unitTable.GetField("script");
			if (scriptField is LuaString) scripts.Add(mod.ModFolder + "/scripts/" + scriptField.Value);
			else scripts.Add(FixPath(mod.ModFolder + "/scripts/" + unitName + ".cob"));
			if (scripts.First().ToLower().EndsWith(".cob"))
			{
				var bosPath = scripts.First().ToLower().Replace(".cob", ".bos");
				if (File.Exists(bosPath)) scripts.Add(FixPath(bosPath));
			}

			var featureDefs = unitTable.GetField("featuredefs");
			if (featureDefs is LuaTable)
			{
				foreach (var kvp in featureDefs.Values)
				{
					modelFileNames.Add(kvp.Value.GetField("object").Value.ToLower());
				}
			}

			foreach (var fileName in modelFileNames)
			{
				var n = fileName.ToLower();
				if (!n.Contains('.')) n += ".3do";
				n = mod.ModFolder + "/Objects3d/" + n;
				models.Add(n);
				if (n.EndsWith(".s3o")) {
					texturesS3o.AddRange(GetS3oTextures(n).Select(t => mod.ModFolder + "/unittextures/" + t).Select(FixPath));
				}
				if (n.EndsWith(".3do"))
				{
					var allTextures = Directory.GetFiles(mod.ModFolder + "/unittextures", "*", SearchOption.AllDirectories).Where(p => !p.Contains(".svn")).Select(FixPath).ToArray();

					var textures = Get3doTextures(n);
					foreach (var textureName in textures)
					{
						var found = false;
						foreach (var file in allTextures)
						{
							var fileNameWithoutExtension = Path.GetFileNameWithoutExtension(file);
							if (textureName == fileNameWithoutExtension || textureName + "00" == fileNameWithoutExtension)
							{
								textures3do.Add(FixPath(file));
								found = true;
							}
						}
						if (!found)
						{
							Debug.WriteLine("not found: " + textureName);
						}
					}
				}
			}
			texturesS3o = texturesS3o.Distinct().Select(FixPath).ToList();
			models = models.Distinct().Select(FixPath).ToList();
			var soundFiles = Directory.GetFiles(mod.ModFolder + "/sounds", "*", SearchOption.AllDirectories).Where(p => !p.Contains(".svn")).Select(FixPath).ToArray();
			foreach (var soundName in soundNames) 
				foreach (var soundFile in soundFiles) 
					if (Path.GetFileNameWithoutExtension(soundFile).ToUpper() == Path.GetFileNameWithoutExtension(soundName).ToUpper()) sounds.Add(FixPath(soundFile));
		}
	}
}