local Mod = Furtherance
local Trinket = Mod.Trinket
local FR_EID = Mod.EID_Support
local DD = FR_EID.DynamicDescriptions

local modifiers = {
	[Mod.Trinket.ALMAGEST_SCRAP.ID] = {
		---@param descObj EID_DescObj
		_modifier = function(descObj, ...)
			local player = Mod.EID_Support:ClosestPlayerTo(descObj.Entity)
			local trinketMult = Mod.EID_Support:TrinketMulti(player, Trinket.ALMAGEST_SCRAP.ID)
			local str = Mod.EID_Support:TrinketMultiStr(trinketMult, ...)
			return Mod.EID_Support:TrinketMultiGoldStr(descObj, str, false, true)
		end,
	},
	[Mod.Trinket.LEVIATHANS_TENDRIL.ID] = {
		---@param descObj EID_DescObj
		_modifier = function(descObj, desc, leviathanLine)
			local player = FR_EID:ClosestPlayerTo(descObj.Entity)
			if player:HasPlayerForm(PlayerForm.PLAYERFORM_EVIL_ANGEL) then
				Mod.Insert(desc, leviathanLine)
			end
			local multi = FR_EID:TrinketMulti(player, descObj.ObjSubType)
			local chance1 = Mod.Trinket.LEVIATHANS_TENDRIL.REFLECT_CHANCE
			local chance2 = Mod.Trinket.LEVIATHANS_TENDRIL.FEAR_CHANCE
			local chanceStr1 = tostring(math.floor(chance1 * 100)) .. "%"
			local chanceStr2 = tostring(math.floor(chance2 * 100)) .. "%"
			if multi > 1 then
				chanceStr1 = "{{ColorGold}}" .. chanceStr1 .. "{{CR}}"
				chanceStr2 = "{{ColorGold}}" .. chanceStr2 .. "{{CR}}"
			end
			desc[1] = desc[1]:format(chanceStr1, chanceStr2)
			desc[2] = desc[2]:format(chanceStr2, chanceStr2)
			return desc
		end,
	},
	[Mod.Trinket.LEAHS_LOCK.ID] = {
		_modifier = function (descObj, chanceStr, luckStr)
			local baseChance = Mod.math.floor((Trinket.LEAHS_LOCK.TEAR_MODIFIER.MinChance * 100))
			local player = Mod.EID_Support:ClosestPlayerTo(descObj.Entity)
			local mult = Mod.EID_Support:TrinketMulti(player, descObj.ObjSubType)
			local newChance = Mod.EID_Support:TrinketMultiGoldStr(descObj, baseChance * mult)
			chanceStr = chanceStr:format(newChance .. "%")
			return chanceStr .. Mod.EID_Support:LuckChanceStr(luckStr, player, Trinket.LEAHS_LOCK.TEAR_MODIFIER, mult)
		end
	},
	[Mod.Trinket.SALINE_SPRAY.ID] = {
		_modifier = function (descObj, chanceStr, luckStr)
			local baseChance = Mod.math.floor((Trinket.SALINE_SPRAY.TEAR_MODIFIER.MinChance * 100))
			local player = Mod.EID_Support:ClosestPlayerTo(descObj.Entity)
			local mult = Mod.EID_Support:TrinketMulti(player, descObj.ObjSubType)
			local newChance = Mod.EID_Support:TrinketMultiGoldStr(descObj, baseChance * mult)
			chanceStr = chanceStr:format(newChance .. "%")
			return chanceStr .. Mod.EID_Support:LuckChanceStr(luckStr, player, Trinket.SALINE_SPRAY.TEAR_MODIFIER, mult)
		end
	},
}

local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_trinkets.trinkets_en_us")(modifiers),
}

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for trinketID, data in pairs(desc) do
		allDescData[trinketID] = allDescData[trinketID] or {}
		if modifiers[trinketID] then
			Mod:AddToDictionary(allDescData[trinketID], modifiers[trinketID])
		end
		allDescData[trinketID][lang] = data
	end
end

for id, trinketDescData in pairs(allDescData) do
	for language, descData in pairs(trinketDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid trinket description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		local minimized = DD:MakeMinimizedDescription(description)

		if not DD:ContainsFunction(minimized) and not trinketDescData._AppendToEnd then
			EID:addTrinket(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla trinkets that already have one
			if not EID.descriptions[language].trinkets[id] then
				EID:addTrinket(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, trinketDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_TRINKET, id, language)
		end

		::continue::
	end
end

EID:addGoldenTrinketTable(Mod.Trinket.ABYSSAL_PENNY.ID, {t = {40}, mults = {1.5, 2}})
EID:addGoldenTrinketTable(Mod.Trinket.BI_84.ID, {t = {25}})
EID:addGoldenTrinketTable(Mod.Trinket.NIL_NUM.ID, {t = {2}})
EID:addGoldenTrinketTable(Mod.Trinket.WORMWOOD_LEAF.ID, {t = {10}})
EID:addGoldenTrinketTable(Mod.Trinket.ALABASTER_SCRAP.ID, {t = {0.5}})
EID:addGoldenTrinketTable(Mod.Trinket.GRASS.ID, {t = {0.05}})
EID:addGoldenTrinketTable(Mod.Trinket.GLITCHED_PENNY.ID, {t = {25}})
EID:addGoldenTrinketTable(Mod.Trinket.ESCAPE_PLAN.ID, {t = {10}})
EID:addGoldenTrinketTable(Mod.Trinket.CRINGE.ID, {t = {2}, mults = {1.5, 2}})
EID:addGoldenTrinketTable(Mod.Trinket.ALTRUISM.ID, {t = {25}, mults = {1.5, 2}})