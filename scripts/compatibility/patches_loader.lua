-- Full credit to Epiphany for this method of applying patches for other mods

local Mod = Furtherance
local loader = {
	Patches = {},
	AppliedPatches = false,
}

Furtherance.PatchesLoader = loader

-- Registers a Mod patch
-- Mod:string           Name of Mod global
-- patchFunc:function   Function that takes 0 arguments and applies the patch
---@function
function loader:RegisterPatch(Mod, patchFunc)
	table.insert(loader.Patches, { Mod = Mod, PatchFunc = patchFunc, Loaded = false })
	--Isaac.DebugString(Dump({ Mod = Mod, PatchFunc = patchFunc, Loaded = false }))
end

---@function
function loader:ApplyPatches()
	for _, patch in pairs(loader.Patches) do
		-- check if Mod reference is valid by getting it by name from the table of globals
		-- we cannot directly pass the Mod reference to RegisterPatch
		-- and then check for it because that Mod reference will be nil
		-- if that Mod is loaded after ours
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
	"andromeda",
	"arachna",
	"cadaver",
	"epiphany",
	"fiend_folio",
	"furtherance",
	"future",
	"gods_gambit",
	"last_judgement",
	"lost_and_forgotten",
	"minimapi",
	"pogforgooditems",
	"punished",
	"repentance_plus",
	"retribution",
	"sheriff",
	"stageapi",
	"tainted_treasures",
}

for _, fileName in ipairs(patches) do
	Furtherance.Include("scripts.compatibility.patches." .. fileName)
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_MODS_LOADED, CallbackPriority.LATE, loader.ApplyPatches)

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if not loader.AppliedPatches then
		loader:ApplyPatches()
	end
end)
