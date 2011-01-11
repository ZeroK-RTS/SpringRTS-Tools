local doPreviewOnly = true

for unitID, unit in pairs(Units) do

	if unit.featureDefs and unit.featureDefs.DEAD and unit.featureDefs.DEAD.object then
	
		local footX = unit.featureDefs.DEAD.footprintX
		local footZ = unit.featureDefs.DEAD.footprintZ
		
		if footZ ~= 1 and footX ~= 1 and (footX <= 5 or footZ <= 5) then
			local s3o = string.find(unit.featureDefs.DEAD.object, ".s3o")
			if not s3o then

				local letter = "a"
				if (footX <= 4 or footZ <= 4) then
					local number = math.floor(math.random()*3)
					if number == 0 then
						letter = "b"
					elseif number == 1 then
						letter = "c"
					end
				end
				
				if footX < footZ then
					 SetTableValue(unit.featureDefs.DEAD, "object", 
						"wreck" .. footX .. "x" .. footX .. letter .. ".s3o"
						, doPreviewOnly, unitID, "Black")
				else
					 SetTableValue(unit.featureDefs.DEAD, "object", 
						"wreck" .. footZ .. "x" .. footZ .. letter .. ".s3o"
						, doPreviewOnly, unitID, "Black")
				end
				
			end	
		end
	end
	

end
