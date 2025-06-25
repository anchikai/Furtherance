local Mod = Furtherance
local FR_EID = Mod.EID_Support

local modifiers = {
	[Mod.Pill.HEARTACHE.ID_UP] = {
		_metadata = { 4, "3-" },
	},
	[Mod.Pill.HEARTACHE.ID_DOWN] = {
		_metadata = { 6, "3+" },
	},
}
local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_pills.pills_en_us")(modifiers),
}

local descData = {}
for lang, desc in pairs(descriptions) do
	for pillEffect, data in pairs(desc) do
		descData[pillEffect] = descData[pillEffect] or {}
		if modifiers[pillEffect] then
			Mod:AddToDictionary(descData[pillEffect], modifiers[pillEffect])
		end
		descData[pillEffect][lang] = data
	end
end

return descData
