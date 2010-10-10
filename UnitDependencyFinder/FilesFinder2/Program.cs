using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;

namespace FilesFinder2
{
	class Program
	{
		static void Main(string[] args)
		{
			var ca = new ModInfo(@"c:\work\zk\trunk\mods\zk");
			var units = File.ReadAllLines("unitlist.txt").Where(x => !string.IsNullOrEmpty(x)).ToArray();
			var resources = new List<string>();
			foreach (var unit in units)
			{
				var f = new FilesFinder(unit, ca);
				f.Print();
				resources.Add(f.CopyTo(@"C:\temp\zkfix"));
			}

			foreach (var resource in resources.SelectMany(r => r.Split(new[] { '\n' }, StringSplitOptions.RemoveEmptyEntries).Where(s => !String.IsNullOrWhiteSpace(s))).Distinct().OrderBy(x=>x))
			{
				Debug.WriteLine(resource);
			}

			Debug.WriteLine("END");
		}
	}
}
