---@class ModReference
_G.Furtherance = RegisterMod("Furtherance", 1)
local Mod = Furtherance

Furtherance.Version = "1.1.4"

Furtherance.SaveManager = include("scripts.tools.save_manager")
Furtherance.SaveManager.Init(Furtherance)
Furtherance.Game = Game()
Furtherance.ItemConfig = Isaac.GetItemConfig()
Furtherance.SFXMan = SFXManager()
Furtherance.MusicMan = MusicManager()
Furtherance.HUD = Furtherance.Game:GetHUD()
Furtherance.Room = function() return Furtherance.Game:GetRoom() end
Furtherance.Level = function() return Furtherance.Game:GetLevel() end
Furtherance.PersistGameData = Isaac.GetPersistentGameData()
Furtherance.Font = {
	Terminus = Font(),
	Tempest = Font(),
	Meat10 = Font(),
	Meat16 = Font()
}
Furtherance.Font.Terminus:Load("font/terminus.fnt")
Furtherance.Font.Tempest:Load("font/pftempestasevencondensed.fnt")
Furtherance.Font.Meat10:Load("font/teammeatfont10.fnt")
Furtherance.Font.Meat16:Load("font/teammeatfont16bold.fnt")

Furtherance.GENERIC_RNG = RNG()

Furtherance:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	local seed = Furtherance.Game:GetSeeds():GetStartSeed()
	Furtherance.GENERIC_RNG:SetSeed(seed)
end)

Furtherance.RANGE_BASE_MULT = 40

Furtherance.REPLACER_EFFECT = Isaac.GetEntityVariantByName("Furtherance PRE_ENTITY_SPAWN Replacement")

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	effect:Remove()
end, Furtherance.REPLACER_EFFECT)

include("scripts.helpers.extra_enums")

---@type table[]
local getData = {}

---Slightly faster than calling GetData, a micromanagement at best
---
---However GetData() is wiped on POST_ENTITY_REMOVE, so this also helps retain the data until after entity removal
---@param ent Entity
---@return table
function Furtherance:GetData(ent)
	if not ent then return {} end
	local ptrHash = GetPtrHash(ent)
	if not getData[ptrHash] then
		local newData = {
			Pointer = EntityRef(ent)
		}
		getData[ptrHash] = newData
	end
	return getData[ptrHash]
end

---@param ent Entity
---@return table?
function Furtherance:TryGetData(ent)
	local ptrHash = GetPtrHash(ent)
	return getData[ptrHash]
end

Furtherance:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.LATE, function(_, ent)
	if not ent:ToNPC() then
		getData[GetPtrHash(ent)] = nil
	end
end)

Furtherance:AddPriorityCallback(ModCallbacks.MC_POST_NPC_DEATH, CallbackPriority.LATE, function(_, ent)
	getData[GetPtrHash(ent)] = nil
end)

Furtherance:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, function(_, ent)
    for ptrHash, entityData in pairs(getData) do
        local entityPointer = (entityData and entityData.Pointer)
        if not (entityPointer and entityPointer.Ref) then
            entityData[ptrHash] = nil
        end
    end
end)

Furtherance.FileLoadError = false
Furtherance.InvalidPathError = false

---Mimics include() but with a pcall safety wrapper and appropriate error codes if any are found
---
---VSCode users: Go to Settings > Lua > Runtime:Special and link Furtherance.Include to require, just like you would regular include!
---@return unknown
function Furtherance.Include(path)
	Isaac.DebugString("[Furtherance] Loading " .. path)
	local wasLoaded, result = pcall(include, path)
	local errMsg = ""
	local foundError = false
	if not wasLoaded then
		Furtherance.FileLoadError = true
		foundError = true
		errMsg = 'Error in path "' .. path .. '":\n' .. result .. '\n'
	elseif result and type(result) == "string" and string.find(result, "no file '") then
		foundError = true
		Furtherance.InvalidPathError = true
		errMsg = 'Unable to locate file in path "' .. path .. '"\n'
	end
	if foundError then
		Furtherance:Log(errMsg)
	end
	return result
end

function Furtherance.LoopInclude(tab, path)
	for _, fileName in pairs(tab) do
		Furtherance.Include(path .. "." .. fileName)
	end
end

Furtherance.Core = {}
Furtherance.Item = {}
Furtherance.Trinket = {}
Furtherance.Pickup = {}
Furtherance.Card = {}
Furtherance.Rune = {}
Furtherance.Pill = {}
Furtherance.Challenge = {}
Furtherance.Character = {}
Furtherance.Misc = {}
Furtherance.Slot = {}
include("flags")

local helpers = {
	"table_functions",
	"saving_system",
	"bitmask_helper",
	"console_command_helper",
	"maths_util",
	"misc_util",
	"players_util",
	"familiars_util",
	"string_util",
	"stats_util",
	"tears_util",
	"proximity",
	"npc_util",
	"rooms_helper",
	"pickups_helper",
	"hearts"
}

local tools = {
	"debug_tools",
	"hud_helper",
	"status_effect_library",
	"save_manager",
	"pickups_tools"
}

local core = {
	"customhealthapi.core",
	"custom_callbacks",
	"entity_replacement"
}

local config = {
	"settings_enum",
	"settings_helper",
	"settings_setup",
	"mcm_setup",
}

Furtherance.Spawn = include("scripts.helpers.spawn")
Furtherance.Foreach = include("scripts.helpers.for_each")

Mod.Include("scripts.tools.jumplib").Init()
Mod.LoopInclude(helpers, "scripts.helpers")
Mod.ConsoleCommandHelper:AddParentDescription("debug", "Debug commands for specific interactions")
Dump = include("scripts.helpers.everything_function")
InputHelper = include("scripts.helpers.vendor.inputhelper")
Mod.LoopInclude(tools, "scripts.tools")
Mod.LoopInclude(core, "scripts.furtherance.core")
Mod.LoopInclude(config, "scripts.furtherance.config")
Mod.Include("scripts.furtherance.api")

if CustomHealthAPI and CustomHealthAPI.Library and CustomHealthAPI.Library.UnregisterCallbacks then
	CustomHealthAPI.Library.UnregisterCallbacks("Furtherance")
end

Furtherance.TearModifier = include("scripts.furtherance.core.tear_modifiers")

Furtherance.PlayerType = {
	LEAH = Isaac.GetPlayerTypeByName("Leah", false),
	PETER = Isaac.GetPlayerTypeByName("Peter", false),
	MIRIAM = Isaac.GetPlayerTypeByName("Miriam", false),
	LEAH_B = Isaac.GetPlayerTypeByName("Leah", true),
	PETER_B = Isaac.GetPlayerTypeByName("Peter", true),
	MIRIAM_B = Isaac.GetPlayerTypeByName("Miriam", true),
}

local characters = {
	"leah.leah",
	"leah_b.leah_b",
	"peter.peter",
	"peter_b.peter_b",
	"miriam.miriam",
	"miriam.polydipsia",
	"miriam_b.miriam_b",
	"tainted_unlock"
}

Mod.LoopInclude(characters, "scripts.furtherance.characters")

local challenges = {}

Mod.LoopInclude(challenges, "scripts.furtherance.challenges")

Mod.Include("scripts.furtherance.unlocks.unlock_loader")
Mod.Include("scripts.furtherance.misc_items.misc_items_loader")

-- shader crash fix by AgentCucco
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
	if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
		Isaac.ExecuteCommand("reloadshaders")
	end
end)

Mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function(_, shaderName)
	if shaderName == 'Peter Flip' then
		return { FlipFactor = 0 }
	end
end)

function Furtherance:RunIDCheck()
	local foundBadID = false
	for _, subTable in pairs(Furtherance) do
		if type(subTable) == "table" then
			for name, itemTable in pairs(subTable) do
				if type(itemTable) == "table" and itemTable.ID and itemTable.ID == -1 then
					print(name, itemTable.ID)
					foundBadID = true
				end
 			end
		end
	end
	if not foundBadID then
		print("No -1 IDs found!")
	end
end

--!End of file

Mod.Include("scripts.compatibility.patches.eid.eid_support")
Mod.Include("scripts.compatibility.patches_loader")

if Mod.FileLoadError then
	Mod:Log("Mod failed to load! Report this to Benny in the dev server!")
elseif Mod.InvalidPathError then
	Mod:Log("One or more files were unable to be loaded. Report this to Benny in the dev server!")
else
	Mod:Log("v" .. Mod.Version .. " successfully loaded!")
end

Furtherance.Include = nil
Furtherance.LoopInclude = nil

