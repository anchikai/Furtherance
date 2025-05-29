local Mod = Furtherance

local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_trinkets.trinkets_en_us"),
}

local descData = {}
for lang, desc in pairs(descriptions) do
	for trinketID, data in pairs(desc) do
		descData[trinketID] = descData[trinketID] or {}
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
