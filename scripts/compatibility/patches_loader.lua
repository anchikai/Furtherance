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
---@param mod string|fun():boolean
---@param patchFunc fun()
---@param modName? string
function loader:RegisterPatch(mod, patchFunc, modName)
	table.insert(loader.Patches, { Mod = mod, ModName = modName or tostring(mod), PatchFunc = patchFunc, Loaded = false })
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
			Mod:DebugLog(table.concat({ "Loaded", patch.ModName, "patch" }, " "))
		end
	end

	loader.AppliedPatches = true
end

local patches = {
	"addicted_beggar",
	"andromeda",
	"arachna",
	"birthcake_rebaked",
	"brawler_beggar",
	"cadaver",
	"epiphany",
	"fiend_folio",
	"furtherance",
	"future",
	"heavens_call",
	"gods_gambit",
	"last_judgement",
	"lost_and_forgotten",
	"minimapi",
	"pogforgooditems",
	"punished",
	"repentance_plus",
	"reshaken",
	"retribution",
	"sheriff",
	"stageapi",
	"tainted_treasures",
	"library_expanded"
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
