local Mod = Furtherance

local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_items.items_en_us"),
}

local descData = {}
for lang, desc in pairs(descriptions) do
	for itemID, data in pairs(desc) do
		descData[itemID] = descData[itemID] or {}
		descData[itemID][lang] = data
	end
end

return descData
