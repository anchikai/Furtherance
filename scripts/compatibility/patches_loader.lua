-- Full credit to Epiphany for this method of applying patches for other mods

local Mod = Furtherance
local loader = {
	Patches = {},
	AppliedPatches = false,
}

Furtherance.PatchesLoader = loader

-- Registers a mod patch
-- mod:string           Name of mod global
-- patchFunc:function   Function that takes 0 arguments and applies the patch
---@function
function loader:RegisterPatch(mod, patchFunc)
	table.insert(loader.Patches, { Mod = mod, PatchFunc = patchFunc, Loaded = false })
	--Isaac.DebugString(Dump({ Mod = mod, PatchFunc = patchFunc, Loaded = false }))
end

---@function
function loader:ApplyPatches()
	for _, patch in pairs(loader.Patches) do
		-- check if mod reference is valid by getting it by name from the table of globals
		-- we cannot directly pass the mod reference to RegisterPatch
		-- and then check for it because that mod reference will be nil
		-- if that mod is loaded after ours
		local modExists
		if type(patch.Mod) == "function" then
			modExists = patch.Mod()
		else
			modExists = _G[patch.Mod]
		end

		if modExists and not patch.Loaded then
			patch.PatchFunc()
			patch.Loaded = true

			Mod:DebugLog(table.concat({ "Loaded", tostring(patch.Mod), "patch" }, " "))
		end
	end

	loader.AppliedPatches = true
end

local patches = {

}
for _, fileName in ipairs(patches) do
	Furtherance.Include("scripts.compatibility.patches." .. fileName)
end

-- This has to be done after all mods are loaded
-- Because otherwise mods that are loaded after Epiphany will not be detected
Mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE, loader.ApplyPatches)

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if not loader.AppliedPatches then
		loader:ApplyPatches()
	end
end)
