local Mod = Furtherance
local loader = Mod.PatchesLoader

local function godsGambitPatch()
	local ents = GodsGambit.ENT
	local virtues = {
		"Kindness",
		"Temperance",
		"Patience",
		"Humility",
		"Chastity",
		"Charity",
		"Diligence"
	}
	for _, virtue in ipairs(virtues) do
		local id = ents[virtue].ID
		local var = ents[virtue].Var
		local superId = ents["Super" .. virtue].ID
		local superVar = ents["Super" .. virtue].Var
		Mod:AddToDictionary(Mod.Item.KEYS_TO_THE_KINGDOM.MINIBOSS, Mod:Set({
			tostring(id) .. "." .. tostring(var) .. "." .. Isaac.GetEntitySubTypeByName(virtue),
			tostring(superId) .. "." .. tostring(superVar) .. "." .. Isaac.GetEntitySubTypeByName("Super " .. virtue),
		}))
	end
end

loader:RegisterPatch("GodsGambit", godsGambitPatch)