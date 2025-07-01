local Mod = Furtherance
local FR_EID = Mod.EID_Support

local modifiers = {
	[Mod.Trinket.ALMAGEST_SCRAP.ID] = {
		---@param descObj EID_DescObj
		---@param desc string
		_modifier = function(descObj, desc)
			if Mod:HasBitFlags(descObj.ObjSubType, TrinketType.TRINKET_GOLDEN_FLAG) then
				return "#{{ColorGold}}" .. desc .. "{{CR}}"
			end
		end,
	},
	[Mod.Trinket.LEAHS_LOCK.ID] = {
		_modifier = function(descObj, desc)
			local multi = FR_EID:TrinketMulti(EID.player, descObj.ObjSubType)
			if multi > 1 then
				return "#{{ColorGold}}" .. desc .. "{{CR}}"
			end
			return ""
		end,
	},
	[Mod.Trinket.LEVIATHANS_TENDRIL.ID] = {
		_modifier = function(descObj, desc, leviathanLine)
			local player = FR_EID:ClosestPlayerTo(descObj.Entity)
			if player:HasPlayerForm(PlayerForm.PLAYERFORM_EVIL_ANGEL) then
				Mod.Insert(desc, leviathanLine)
			end
			local multi = FR_EID:TrinketMulti(EID.player, descObj.ObjSubType)
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
	}
}
local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_trinkets.trinkets_en_us")(modifiers),
	spa = Mod.Include("scripts.compatibility.patches.eid.eid_trinkets.trinekts_spa")(modifiers),
}

local descData = {}
for lang, desc in pairs(descriptions) do
	for trinketID, data in pairs(desc) do
		descData[trinketID] = descData[trinketID] or {}
		if modifiers[trinketID] then
			Mod:AddToDictionary(descData[trinketID], modifiers[trinketID])
		end
		descData[trinketID][lang] = data
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
EID:addGoldenTrinketTable(Mod.Trinket.CRINGE.ID, {t = {1}})
EID:addGoldenTrinketTable(Mod.Trinket.ALTRUISM.ID, {t = {25}, mults = {1.5, 2}})

return descData
