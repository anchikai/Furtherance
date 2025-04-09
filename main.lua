---@class ModReference
_G.Furtherance = RegisterMod("Furtherance", 1)
local Mod = Furtherance

Furtherance.Version = "INDEV_REWRITE"

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
	local data = getData[ptrHash]
	if not data then
		local newData = {}
		getData[ptrHash] = newData
		data = newData
	end
	return data
end

---@param ent Entity
---@return table?
function Furtherance:TryGetData(ent)
	local ptrHash = GetPtrHash(ent)
	local data = getData[ptrHash]
	return data
end

Furtherance:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.LATE, function(_, ent)
	getData[GetPtrHash(ent)] = nil
end)

Furtherance.FileLoadError = false
Furtherance.InvalidPathError = false

---Mimics include() but with a pcall safety wrapper and appropriate error codes if any are found
---
---VSCode users: Go to Settings > Lua > Runtime:Special and link Furtherance.Include to require, just like you would regular include!
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

---@param tab table
---@param path string
local function loopInclude(tab, path)
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
include("flags")

local helpers = {
	"table_functions",
	"saving_system",
	"bitmask_helper",
	"maths_util",
	"misc_util",
	"players_util",
	"familiars_util",
	"string_util",
	"stats_util",
	"tears_util",
	"proximity",
	"npc_util",
	"custom_callbacks",
	"rooms_helper",
	"pickups_helper"
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
	"hearts",
	"custom_callbacks"
}

local config = {
	"settings_enum",
	"settings_helper",
	"settings_setup",
	"mcm_setup",
}

loopInclude(helpers, "scripts.helpers")
Dump = include("scripts.helpers.everything_function")
InputHelper = include("scripts.helpers.vendor.inputhelper")
loopInclude(tools, "scripts.tools")
loopInclude(core, "scripts.furtherance.core")
loopInclude(config, "scripts.furtherance.config")

Furtherance.TearModifier = include("scripts.furtherance.core.tear_modifiers")

Furtherance.PlayerType = {
	LEAH = Isaac.GetPlayerTypeByName("Laeh", false),
	PETER = Isaac.GetPlayerTypeByName("Peter", false),
	MIRIAM = Isaac.GetPlayerTypeByName("Miriam", false),
	LEAH_B = Isaac.GetPlayerTypeByName("Laeh", true),
	PETER_B = Isaac.GetPlayerTypeByName("Peter", true),
	MIRIAM_B = Isaac.GetPlayerTypeByName("Miriam", true),
}

local characters = {
	"leah.leah",
	"leah_b.leah_b",
	"leah_b.shattered_heart",
	"peter.peter",
	"peter.keys_to_the_kingdom",
	"peter_b.peter_b",
	"miriam.miriam",
	"miriam.tambourine",
	"miriam.polydipsia",
	"miriam_b.miriam_b",
	"miriam_b.polarity_shift"
}

loopInclude(characters, "scripts.furtherance.characters")

local challenges = {}

loopInclude(challenges, "scripts.furtherance.challenes")

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

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_APPLY_INNATE_COLLECTIBLE_NUM, function(_, count, player, itemID, onlyTrue)
	if itemID == 64 then
		return 1
	end
end)

--!End of file

Mod.Include("scripts.compatibility.patches_loader")

if Mod.FileLoadError then
	Mod:Log("Mod failed to load! Report this to a coder in the dev server!")
elseif Mod.InvalidPathError then
	Mod:Log("One or more files were unable to be loaded. Report this to a coder in the dev server!")
else
	Mod:Log("v" .. Mod.Version .. " successfully loaded!")
end

Furtherance.Include = nil

--[[
-- Floor Generation
--include("lua/rooms/NoahsArk.lua")
include("lua/rooms/HomeExit.lua")

-- Mod Support
if EID then
	include("lua/eid.lua")
end

if Encyclopedia then
	include("lua/encyclopedia.lua")
end

if Poglite then
	-- Leah
	local LeahCostumeA = Isaac.GetCostumeIdByPath("gfx/characters/Character_001_Leah_Pog.anm2")
	Poglite:AddPogCostume("LeahPog", PlayerType.PLAYER_LEAH, LeahCostumeA)
	-- Tainted Leah
	local LeahCostumeB = Isaac.GetCostumeIdByPath("gfx/characters/Character_001b_Leah_Pog.anm2")
	Poglite:AddPogCostume("LeahBPog", PlayerType.PLAYER_LEAH_B, LeahCostumeB)
	-- Tainted Peter
	local PeterCostumeB = Isaac.GetCostumeIdByPath("gfx/characters/Character_002b_Peter_Pog.anm2")
	Poglite:AddPogCostume("PeterBPog", PlayerType.PLAYER_PETER_B, PeterCostumeB)
	-- Miriam
	local MiriamCostumeA = Isaac.GetCostumeIdByPath("gfx/characters/Character_003_Miriam_Pog.anm2")
	Poglite:AddPogCostume("MiriamPog", PlayerType.PLAYER_MIRIAM, MiriamCostumeA)
	-- Tainted Miriam
	local MiriamCostumeB = Isaac.GetCostumeIdByPath("gfx/characters/Character_003b_Miriam_Pog.anm2")
	Poglite:AddPogCostume("MiriamBPog", PlayerType.PLAYER_MIRIAM_B, MiriamCostumeB)
end

if MiniMapiItemsAPI then
	local MoonHeartSprite = Sprite()
	MoonHeartSprite:Load("gfx/ui/heart_icon.anm2", true)
	-- Moon Heart
	MinimapAPI:AddIcon("MoonHeartIcon", MoonHeartSprite, "MoonHeart", 0)
	MinimapAPI:AddPickup(HeartSubType.HEART_MOON, "MoonHeartIcon", 5, 10, HeartSubType.HEART_MOON, MinimapAPI.PickupNotCollected, "hearts", 13000)
	-- Rock Heart
	MinimapAPI:AddIcon("RockHeartIcon", RockHeartSprite, "RockHeart", 0)
	MinimapAPI:AddPickup(HeartSubType.HEART_ROCK, "RockHeartIcon", 5, 10, HeartSubType.HEART_ROCK, MinimapAPI.PickupNotCollected, "hearts", 13000)
end

if ModConfigMenu then
	include("lua/MCM.lua")
end
]]
