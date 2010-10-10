using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using FilesFinder2.Properties;
using Tao.Lua;
using WinterSync;

namespace FilesFinder2
{
	class ModInfo
	{
		public Dictionary<string, string[]> ExplosionFiles { get; set; }
		public Dictionary<string, string[]> ExplosionTextures { get; set; }
		public Dictionary<string, string> ProjectileTextures { get; set; }
		public string ModFolder;
		IntPtr L;

		public ModInfo(string modFolder)
		{
			this.ModFolder = FilesFinder.FixPath(modFolder);
			L = Lua.luaL_newstate();
			Lua.luaL_openlibs(L);
			CLua.TraceDoString(L, 0, Resources.luastuff);

			ProcessResources();
			ProcessExplosions();
			ProcessWeapons();
			
		}

		void ProcessWeapons()
		{
			WeaponExplosions = new Dictionary<string, string>();
			WeaponFiles = new Dictionary<string, string>();
			foreach (var filePath in Directory.GetFiles(ModFolder + "/weapons"))
			{
				var text = File.ReadAllText(filePath);
				foreach (dynamic returValue in GetTdfTableFromString(L, text))
				{
					if (returValue is LuaTable)
					{
						foreach (var kvp in returValue.Values)
						{
							string weaponName = kvp.Key.Value;
							WeaponFiles.Add(weaponName, FilesFinder.FixPath(filePath));
							if (kvp.Value.GetField("explosiongenerator") is LuaString)
							{
								string explosionGenerator = kvp.Value.GetField("explosiongenerator").Value;
								if (explosionGenerator.StartsWith("custom:")) WeaponExplosions.Add(weaponName, explosionGenerator.Substring(7, explosionGenerator.Length - 7).ToLower());
							}
						}
					}
				}
			}
		}

		public Dictionary<string, string> WeaponExplosions { get; set; }
		public Dictionary<string, string> WeaponFiles { get; set; }

		static LuaValue[] GetTdfTableFromString(IntPtr L, string fileString)
		{
			Lua.lua_getglobal(L, "TDFparser"); // push the parser table on the stack
			Lua.lua_getfield(L, -1, "ParseText"); // push the parse string function
			var ret = CLua.TraceCall(L, 2, new LuaString(fileString));
			LuaValue.Pop(L, 1);
			return ret;
		}

		void ProcessExplosions()
		{
			var texturePairs = new List<TexturePair>();
			var filePairs = new List<FilePair>();
			var spawners = new List<SpawnerPair>();
			var effectsFolder = ModFolder + "\\effects";

			foreach (var file in Directory.GetFiles(effectsFolder, "*.lua"))
			{

				dynamic explosions = CLua.TraceDoString(L, 1, File.ReadAllText(file))[0];
				foreach (var explosion in explosions.Values)
				{
					filePairs.Add(new FilePair(explosion.Key.Value, file));

					foreach (var effect in explosion.Value.Values)
					{
						if (effect.Value is LuaTable && effect.Value.GetField("class") != null)
						{
							if (effect.Value.GetField("class").Value == "CExpGenSpawner")
							{
								var explosionGenerator = effect.Value.GetField("properties").GetField("explosiongenerator").Value.ToLower();
								if (explosionGenerator.StartsWith("custom:")) explosionGenerator = explosionGenerator.Substring(7, explosionGenerator.Length - 7).ToLower();
								spawners.Add(new SpawnerPair(explosion.Key.Value, explosionGenerator));
							}
							else if (effect.Value.GetField("class").Value == "CBitmapMuzzleFlame")
							{
								texturePairs.Add(new TexturePair(explosion.Key.Value, effect.Value.GetField("properties").GetField("fronttexture").Value.ToLower()));
								texturePairs.Add(new TexturePair(explosion.Key.Value, effect.Value.GetField("properties").GetField("sidetexture").Value.ToLower()));
							}
							else if (effect.Value.GetField("class").Value == "CSimpleParticleSystem")
							{
								texturePairs.Add(new TexturePair(explosion.Key.Value, effect.Value.GetField("properties").GetField("texture").Value.ToLower()));
							}
							else if (effect.Value.GetField("class").Value == "CSimpleGroundFlash")
							{
								texturePairs.Add(new TexturePair(explosion.Key.Value, effect.Value.GetField("properties").GetField("texture").Value.ToLower()));
							}
							else if (effect.Value.GetField("class").Value == "heatcloud")
							{
								texturePairs.Add(new TexturePair(explosion.Key.Value, effect.Value.GetField("properties").GetField("texture").Value.ToLower()));
							}
						}
					}
				}
			}

			var dependencies = filePairs.Select(p => p.ExplosionName).Distinct().Select(n => GetExplosionDependencies(n, texturePairs, spawners, filePairs)).ToArray();
			// var dupes = filePairs.GroupBy(p => p.ExplosionName).Where(g => g.Count() > 1).ToArray();
			//foreach (var dupe in dupes)
			//{
			//    Debug.WriteLine("====== " + dupe.Key + " ==========");
			//    foreach (var d in dupe) Debug.WriteLine(d.FilePath);
			//}

			// var dupes = dependencies.GroupBy(p => p.Name).Where(g => g.Count() > 1).ToArray();
			ExplosionTextures = dependencies.ToDictionary(d => d.Name, d => d.Textures.Select(FilesFinder.FixPath).ToArray());
			ExplosionFiles = dependencies.ToDictionary(d => d.Name, d => d.Files.Select(FilesFinder.FixPath).ToArray());
		}

		void ProcessResources()
		{
			var resourcesPath = ModFolder + "\\gamedata\\resources.lua";
			dynamic resources = CLua.TraceDoString(L, 1, File.ReadAllText(resourcesPath))[0];
			ProjectileTextures = new Dictionary<string, string>();
			var textures = resources.GetField("graphics").GetField("projectiletextures");
			foreach (var kvp in textures.Values)
			{
				ProjectileTextures.Add(kvp.Key.Value, FilesFinder.FixPath(ModFolder + "/bitmaps/" + textures.GetField(kvp.Key.Value).Value));
			}
		}

		class ExplosionDeps
		{
			public string Name;
			public List<string> Textures = new List<string>();
			public List<string> Files = new List<string>();
		}

		class SpawnerPair
		{
			public SpawnerPair(string spawnerName, string spawnedExplosion)
			{
				SpawnerName = spawnerName;
				SpawnedExplosion = spawnedExplosion;
			}

			public string SpawnerName;
			public string SpawnedExplosion;
		}

		class TexturePair
		{
			public TexturePair(string explosionName, string textureName)
			{
				ExplosionName = explosionName;
				TextureName = textureName;
			}

			public string ExplosionName;
			public string TextureName;
		}

		class FilePair
		{
			public FilePair(string explosionName, string filePath)
			{
				ExplosionName = explosionName;
				FilePath = filePath;
			}

			public string ExplosionName;
			public string FilePath;
		}

		ExplosionDeps GetExplosionDependencies(string explosionName,
							   IEnumerable<TexturePair> texturePairs,
							   IEnumerable<SpawnerPair> spawners,
							   IEnumerable<FilePair> filePairs)
		{

			var ret = new ExplosionDeps { Name = explosionName };
			foreach (var texturePair in texturePairs.Where(p => p.ExplosionName == explosionName).ToArray())
			{
				ret.Textures.Add(texturePair.TextureName);
			}
			foreach (var filePair in filePairs.Where(p => p.ExplosionName == explosionName).ToArray())
			{
				ret.Files.Add(filePair.FilePath);
			}
			// if (explosionName.ToLower() == "roachplosion") Debugger.Break();
			foreach (var sp in spawners.Where(p => p.SpawnerName == explosionName))
			{
				var deps = GetExplosionDependencies(sp.SpawnedExplosion, texturePairs, spawners, filePairs);
				ret.Files.AddRange(deps.Files);
				ret.Textures.AddRange(deps.Textures);
			}
			return ret;
		}
	}
}
