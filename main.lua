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

include("scripts.helpers.extra_enums")

---@type table[]
local getData = {}

---Slightly faster than calling GetData, a micromanagement at best
---
---However GetData() is wiped on POST_ENTITY_REMOVE, so this also helps retain the data until after entity removal
---@param ent Entity
---@return table
function Furtherance:GetData(ent)
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
	"save_manager",
	"pickups_tools"
}

local core = {
	"hearts"
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

Furtherance.PlayerType = {
	LEAH = Isaac.GetPlayerTypeByName("Laeh", false),
	PETER = Isaac.GetPlayerTypeByName("Peter", false),
	MIRIAM = Isaac.GetPlayerTypeByName("Miriam", false),
	LEAH_B = Isaac.GetPlayerTypeByName("Laeh", true),
	PETER_B = Isaac.GetPlayerTypeByName("Peter", true),
	MIRIAM_B = Isaac.GetPlayerTypeByName("Miriam", true),
}

local characters = {
	--"leah.leah"
	"leah.heart_renovator",
	--"leah_b.leah_b",
	--"leah_b.shattered_heart",
	--"peter.peter",
	--"peter.keys_to_the_kingdom",
	--"peter_b.peter_b",
	--"peter_b.muddled_cross",
	--"miriam.miriam",
	--"miriam.tambourine",
	--"miriam.polydipsia",
	--"miriam_b.miriam_b",
	--"miriam_b.polarity_shift"
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
-- Characters
PlayerType.PLAYER_LEAH = Isaac.GetPlayerTypeByName("Leah", false)
PlayerType.PLAYER_LEAH_B = Isaac.GetPlayerTypeByName("Leah", true)
PlayerType.PLAYER_PETER = Isaac.GetPlayerTypeByName("Peter", false)
PlayerType.PLAYER_PETER_B = Isaac.GetPlayerTypeByName("Peter", true)
PlayerType.PLAYER_MIRIAM = Isaac.GetPlayerTypeByName("Miriam", false)
PlayerType.PLAYER_MIRIAM_B = Isaac.GetPlayerTypeByName("Miriam", true)

-- Collectibles
CollectibleType.COLLECTIBLE_TECH_IX = Isaac.GetItemIdByName("Tech IX")
CollectibleType.COLLECTIBLE_LEAKING_TANK = Isaac.GetItemIdByName("Leaking Tank")
CollectibleType.COLLECTIBLE_UNSTABLE_CORE = Isaac.GetItemIdByName("Unstable Core")
CollectibleType.COLLECTIBLE_TECHNOLOGY_MINUS_1 = Isaac.GetItemIdByName("Technology -1")
CollectibleType.COLLECTIBLE_BOOK_OF_SWIFTNESS = Isaac.GetItemIdByName("Book of Swiftness")
CollectibleType.COLLECTIBLE_BOOK_OF_AMBIT = Isaac.GetItemIdByName("Book of Ambit")
CollectibleType.COLLECTIBLE_NEASS = Isaac.GetItemIdByName("Plug N' Play")
CollectibleType.COLLECTIBLE_ZZZZoptionsZZZZ = Isaac.GetItemIdByName("ZZZZoptionsZZZZ")
CollectibleType.COLLECTIBLE_BRUNCH = Isaac.GetItemIdByName("Brunch")
CollectibleType.COLLECTIBLE_CRAB_LEGS = Isaac.GetItemIdByName("Crab Legs")
CollectibleType.COLLECTIBLE_OWLS_EYE = Isaac.GetItemIdByName("Owl's Eye")
CollectibleType.COLLECTIBLE_HEART_RENOVATOR = Isaac.GetItemIdByName("Heart Renovator")
CollectibleType.COLLECTIBLE_PHARAOH_CAT = Isaac.GetItemIdByName("Pharaoh Cat")
CollectibleType.COLLECTIBLE_F4_KEY = Isaac.GetItemIdByName("F4 Key")
CollectibleType.COLLECTIBLE_TAB_KEY = Isaac.GetItemIdByName("Tab Key")
CollectibleType.COLLECTIBLE_SHATTERED_HEART = Isaac.GetItemIdByName("Shattered Heart")
CollectibleType.COLLECTIBLE_KEYS_TO_THE_KINGDOM = Isaac.GetItemIdByName("Keys to the Kingdom")
CollectibleType.COLLECTIBLE_BINDS_OF_DEVOTION = Isaac.GetItemIdByName("Binds of Devotion")
CollectibleType.COLLECTIBLE_MUDDLED_CROSS = Isaac.GetItemIdByName("Muddled Cross")
CollectibleType.COLLECTIBLE_PARASITIC_POOFER = Isaac.GetItemIdByName("Parasitic Poofer")
CollectibleType.COLLECTIBLE_HEART_EMBEDDED_COIN = Isaac.GetItemIdByName("Heart Embedded Coin")
CollectibleType.COLLECTIBLE_SPIRITUAL_WOUND = Isaac.GetItemIdByName("Spiritual Wound")
CollectibleType.COLLECTIBLE_CADUCEUS_STAFF = Isaac.GetItemIdByName("Caduceus Staff")
CollectibleType.COLLECTIBLE_POLYDIPSIA = Isaac.GetItemIdByName("Polydipsia")
CollectibleType.COLLECTIBLE_KARETH = Isaac.GetItemIdByName("Kareth")
CollectibleType.COLLECTIBLE_PILLAR_OF_FIRE = Isaac.GetItemIdByName("Pillar of Fire")
CollectibleType.COLLECTIBLE_PILLAR_OF_CLOUDS = Isaac.GetItemIdByName("Pillar of Clouds")
CollectibleType.COLLECTIBLE_FIRSTBORN_SON = Isaac.GetItemIdByName("Firstborn Son")
CollectibleType.COLLECTIBLE_MIRIAMS_WELL = Isaac.GetItemIdByName("Miriam's Well")
CollectibleType.COLLECTIBLE_QUARANTINE = Isaac.GetItemIdByName("Quarantine")
CollectibleType.COLLECTIBLE_BOOK_OF_GUIDANCE = Isaac.GetItemIdByName("Book of Guidance")
CollectibleType.COLLECTIBLE_JAR_OF_MANNA = Isaac.GetItemIdByName("Jar of Manna")
CollectibleType.COLLECTIBLE_TAMBOURINE = Isaac.GetItemIdByName("Tambourine")
CollectibleType.COLLECTIBLE_THE_DREIDEL = Isaac.GetItemIdByName("The Dreidel")
CollectibleType.COLLECTIBLE_APOCALYPSE = Isaac.GetItemIdByName("Apocalypse")
CollectibleType.COLLECTIBLE_MANDRAKE = Isaac.GetItemIdByName("Mandrake")
-- CollectibleType.COLLECTIBLE_LITTLE_SISTER = Isaac.GetItemIdByName("Little Sister")
CollectibleType.COLLECTIBLE_OLD_CAMERA = Isaac.GetItemIdByName("Old Camera")
CollectibleType.COLLECTIBLE_BUTTERFLY = Isaac.GetItemIdByName("Butterfly")
CollectibleType.COLLECTIBLE_ALTERNATE_REALITY = Isaac.GetItemIdByName("Alternate Reality")
CollectibleType.COLLECTIBLE_WINE_BOTTLE = Isaac.GetItemIdByName("Wine Bottle")
CollectibleType.COLLECTIBLE_FLUX = Isaac.GetItemIdByName("Flux")
-- CollectibleType.COLLECTIBLE_BRAINSTORM = Isaac.GetItemIdByName("Brainstorm")
CollectibleType.COLLECTIBLE_COSMIC_OMNIBUS = Isaac.GetItemIdByName("Cosmic Omnibus")
CollectibleType.COLLECTIBLE_LITTLE_RAINCOAT = Isaac.GetItemIdByName("Little Raincoat")
CollectibleType.COLLECTIBLE_BLOOD_CYST = Isaac.GetItemIdByName("Blood Cyst")
CollectibleType.COLLECTIBLE_POLARIS = Isaac.GetItemIdByName("Polaris")
CollectibleType.COLLECTIBLE_D9 = Isaac.GetItemIdByName("D9")
-- CollectibleType.COLLECTIBLE_LEAHS_HAIR_TIE = Isaac.GetItemIdByName("Leah's Hair Tie")
-- CollectibleType.COLLECTIBLE_LEAHS_TORN_HEART = Isaac.GetItemIdByName("Leah's Torn Heart")
-- CollectibleType.COLLECTIBLE_PETERS_HEADBAND = Isaac.GetItemIdByName("Peter's Headband")
-- CollectibleType.COLLECTIBLE_PETERS_BLOODY_FRACTURE = Isaac.GetItemIdByName("Peter's Bloody Fracture")
-- CollectibleType.COLLECTIBLE_MIRIAMS_HEADBAND = Isaac.GetItemIdByName("Miriam's Headband")
-- CollectibleType.COLLECTIBLE_MIRIAMS_PUTRID_VEIL = Isaac.GetItemIdByName("Miriam's Putrid Veil")
CollectibleType.COLLECTIBLE_POLARITY_SHIFT = Isaac.GetItemIdByName("Polarity Shift")
CollectibleType.COLLECTIBLE_BOOK_OF_BOOKS = Isaac.GetItemIdByName("Book of Books")
CollectibleType.COLLECTIBLE_KERATOCONUS = Isaac.GetItemIdByName("Keratoconus")
CollectibleType.COLLECTIBLE_SERVITUDE = Isaac.GetItemIdByName("Servitude")
CollectibleType.COLLECTIBLE_CARDIOMYOPATHY = Isaac.GetItemIdByName("Cardiomyopathy")
CollectibleType.COLLECTIBLE_SUNSCREEN = Isaac.GetItemIdByName("Sunscreen")
CollectibleType.COLLECTIBLE_SECRET_DIARY = Isaac.GetItemIdByName("Secret Diary")
CollectibleType.COLLECTIBLE_D16 = Isaac.GetItemIdByName("D16")
CollectibleType.COLLECTIBLE_IRON = Isaac.GetItemIdByName("Iron")
CollectibleType.COLLECTIBLE_ROTTEN_APPLE = Isaac.GetItemIdByName("Rotten Apple")
CollectibleType.COLLECTIBLE_BEGINNERS_LUCK = Isaac.GetItemIdByName("Beginner's Luck")
CollectibleType.COLLECTIBLE_DADS_WALLET = Isaac.GetItemIdByName("Dad's Wallet")
CollectibleType.COLLECTIBLE_CHI_RHO = Isaac.GetItemIdByName("Chi Rho")
CollectibleType.COLLECTIBLE_LEAHS_HEART = Isaac.GetItemIdByName("Leah's Heart")
CollectibleType.COLLECTIBLE_PALLIUM = Isaac.GetItemIdByName("Pallium")
CollectibleType.COLLECTIBLE_COLD_HEARTED = Isaac.GetItemIdByName("Cold Hearted")
CollectibleType.COLLECTIBLE_ROTTEN_LOVE = Isaac.GetItemIdByName("Rotten Love")
CollectibleType.COLLECTIBLE_RUE = Isaac.GetItemIdByName("Rue")
CollectibleType.COLLECTIBLE_EXSANGUINATION = Isaac.GetItemIdByName("Exsanguination")
CollectibleType.COLLECTIBLE_PRAYER_JOURNAL = Isaac.GetItemIdByName("Prayer Journal")
CollectibleType.COLLECTIBLE_BOOK_OF_LEVITICUS = Isaac.GetItemIdByName("Book of Leviticus")
CollectibleType.COLLECTIBLE_MOLTEN_GOLD = Isaac.GetItemIdByName("Molten Gold")
CollectibleType.COLLECTIBLE_TREPANATION = Isaac.GetItemIdByName("Trepanation")
CollectibleType.COLLECTIBLE_ASTRAGALI = Isaac.GetItemIdByName("Astragali")
CollectibleType.COLLECTIBLE_LIBERATION = Isaac.GetItemIdByName("Liberation")
CollectibleType.COLLECTIBLE_SEVERED_EAR = Isaac.GetItemIdByName("Severed Ear")
CollectibleType.COLLECTIBLE_GOLDEN_PORT = Isaac.GetItemIdByName("Golden Port")
CollectibleType.COLLECTIBLE_ITCHING_POWDER = Isaac.GetItemIdByName("Itching Powder")

-- Isaac's Keyboard
CollectibleType.COLLECTIBLE_ESC_KEY = Isaac.GetItemIdByName("Esc Key")
CollectibleType.COLLECTIBLE_TILDE_KEY = Isaac.GetItemIdByName("Tilde Key")
CollectibleType.COLLECTIBLE_ALT_KEY = Isaac.GetItemIdByName("Alt Key")
CollectibleType.COLLECTIBLE_SPACEBAR_KEY = Isaac.GetItemIdByName("Spacebar Key")
CollectibleType.COLLECTIBLE_BACKSPACE_KEY = Isaac.GetItemIdByName("Backspace Key")
CollectibleType.COLLECTIBLE_Q_KEY = Isaac.GetItemIdByName("Q Key")
CollectibleType.COLLECTIBLE_E_KEY = Isaac.GetItemIdByName("E Key")
CollectibleType.COLLECTIBLE_C_KEY = Isaac.GetItemIdByName("C Key")
CollectibleType.COLLECTIBLE_CAPS_KEY = Isaac.GetItemIdByName("Caps Key")
CollectibleType.COLLECTIBLE_ENTER_KEY = Isaac.GetItemIdByName("Enter Key")
CollectibleType.COLLECTIBLE_SHIFT_KEY = Isaac.GetItemIdByName("Shift Key")

-- Astrological Signs
CollectibleType.COLLECTIBLE_OPHIUCHUS = Isaac.GetItemIdByName("Ophiuchus")
CollectibleType.COLLECTIBLE_CHIRON = Isaac.GetItemIdByName("Chiron")
CollectibleType.COLLECTIBLE_CERES = Isaac.GetItemIdByName("Ceres")
CollectibleType.COLLECTIBLE_PALLAS = Isaac.GetItemIdByName("Pallas")
CollectibleType.COLLECTIBLE_JUNO = Isaac.GetItemIdByName("Juno")
CollectibleType.COLLECTIBLE_VESTA = Isaac.GetItemIdByName("Vesta")

-- Trinkets
TrinketType.TRINKET_HOLY_HEART = Isaac.GetTrinketIdByName("Holy Heart")
TrinketType.TRINKET_CRINGE = Isaac.GetTrinketIdByName("Cringe")
TrinketType.TRINKET_SLICK_WORM = Isaac.GetTrinketIdByName("Slick Worm")
TrinketType.TRINKET_GRASS = Isaac.GetTrinketIdByName("Grass")
TrinketType.TRINKET_ALABASTER_SCRAP = Isaac.GetTrinketIdByName("Alabaster Scrap")
TrinketType.TRINKET_LEAHS_LOCK = Isaac.GetTrinketIdByName("Leah's Lock")
TrinketType.TRINKET_ABYSSAL_PENNY = Isaac.GetTrinketIdByName("Abyssal Penny")
TrinketType.TRINKET_SALINE_SPRAY = Isaac.GetTrinketIdByName("Saline Spray")
TrinketType.TRINKET_ALMAGEST_SCRAP = Isaac.GetTrinketIdByName("Almagest Scrap")
TrinketType.TRINKET_WORMWOOD_LEAF = Isaac.GetTrinketIdByName("Wormwood Leaf")
TrinketType.TRINKET_ESCAPE_PLAN = Isaac.GetTrinketIdByName("Escape Plan")
TrinketType.TRINKET_EPITAPH = Isaac.GetTrinketIdByName("Epitaph")
TrinketType.TRINKET_LEVIATHANS_TENDRIL = Isaac.GetTrinketIdByName("Leviathan's Tendril")
TrinketType.TRINKET_ALTRUISM = Isaac.GetTrinketIdByName("Altruism")
TrinketType.TRINKET_NIL_NUM = Isaac.GetTrinketIdByName("Nil Num")
TrinketType.TRINKET_KEY_TO_THE_PIT = Isaac.GetTrinketIdByName("Key to the Pit")
TrinketType.TRINKET_BI_84 = Isaac.GetTrinketIdByName("BI-84")
TrinketType.TRINKET_GLITCHED_PENNY = Isaac.GetTrinketIdByName("Glitched Penny")
TrinketType.TRINKET_HAMMERHEAD_WORM = Isaac.GetTrinketIdByName("Hammerhead Worm")
TrinketType.TRINKET_PARASOL = Isaac.GetTrinketIdByName("Parasol")

-- Cards/Runes/Pills/etc
RUNE_SOUL_OF_LEAH = Isaac.GetCardIdByName("Soul of Leah")
CARD_TWO_OF_SHIELDS = Isaac.GetCardIdByName("Two of Shields")
CARD_ACE_OF_SHIELDS = Isaac.GetCardIdByName("Ace of Shields")
CARD_TRAP = Isaac.GetCardIdByName("Trap Card")
CARD_KEY = Isaac.GetCardIdByName("Key Card")
RUNE_SOUL_OF_PETER = Isaac.GetCardIdByName("Soul of Peter")
RUNE_SOUL_OF_MIRIAM = Isaac.GetCardIdByName("Soul of Miriam")
RUNE_ESSENCE_OF_LOVE = Isaac.GetCardIdByName("Essence of Love")
RUNE_ESSENCE_OF_HATE = Isaac.GetCardIdByName("Essence of Hate")
RUNE_ESSENCE_OF_LIFE = Isaac.GetCardIdByName("Essence of Life")
RUNE_ESSENCE_OF_DEATH = Isaac.GetCardIdByName("Essence of Death")
RUNE_ESSENCE_OF_DELUGE = Isaac.GetCardIdByName("Essence of Deluge")
RUNE_ESSENCE_OF_DROUGHT = Isaac.GetCardIdByName("Essence of Drought")
PILLEFFECT_HEARTACHE_UP = Isaac.GetPillEffectByName("Heartache Up")
PILLEFFECT_HEARTACHE_DOWN = Isaac.GetPillEffectByName("Heartache Down")
CARD_GOLDEN = Isaac.GetCardIdByName("Golden Card")
CARD_HOPE = Isaac.GetCardIdByName("Hope")
CARD_REVERSE_HOPE = Isaac.GetCardIdByName("ReverseHope")
CARD_FAITH = Isaac.GetCardIdByName("Faith")
CARD_REVERSE_FAITH = Isaac.GetCardIdByName("ReverseFaith")
CARD_CHARITY = Isaac.GetCardIdByName("Charity")
CARD_REVERSE_CHARITY = Isaac.GetCardIdByName("ReverseCharity")

-- Pickups
HeartSubType.HEART_MOON = 225
HeartSubType.HEART_ROCK = 226
SackSubType.SACK_GOLDEN = 3
CoinSubType.COIN_UNLUCKYPENNY = 117
BombSubType.BOMB_CHARGED = 118

---- Lua Files ----
include("lua/customcallbacks.lua")
include("lua/saveapi.lua")
include("lua/piber.lua")
include("lua.utility.helpers.misc_util")

-- Players
include("lua/players/Leah.lua")
include("lua/players/Peter.lua")
include("lua/players/Miriam.lua")

-- Collectibles
include("lua/items/collectibles/Esc.lua")
include("lua/items/collectibles/Tilde.lua")
include("lua/items/collectibles/Alt.lua")
include("lua/items/collectibles/Spacebar.lua")
include("lua/items/collectibles/Backspace.lua")
include("lua/items/collectibles/Q.lua")
include("lua/items/collectibles/E.lua")
include("lua/items/collectibles/C.lua")
include("lua/items/collectibles/Caps.lua")
include("lua/items/collectibles/Enter.lua")
include("lua/items/collectibles/Shift.lua")
include("lua/items/collectibles/Ophiuchus.lua")
include("lua/items/collectibles/Chiron.lua")
include("lua/items/collectibles/Ceres.lua")
include("lua/items/collectibles/Pallas.lua")
include("lua/items/collectibles/Juno.lua")
include("lua/items/collectibles/Vesta.lua")
include("lua/items/collectibles/TechIX.lua")
include("lua/items/collectibles/LeakingTank.lua")
include("lua/items/collectibles/UnstableCore.lua")
include("lua/items/collectibles/Technology-1.lua")
include("lua/items/collectibles/BookOfSwiftness.lua")
include("lua/items/collectibles/BookOfAmbit.lua")
include("lua/items/collectibles/NEASS.lua")
include("lua/items/collectibles/ZZZZoptionsZZZZ.lua")
include("lua/items/collectibles/Brunch.lua")
include("lua/items/collectibles/CrabLegs.lua")
include("lua/items/collectibles/OwlsEye.lua")
include("lua/items/collectibles/HeartRenovator.lua")
include("lua/items/collectibles/PharaohCat.lua")
include("lua/items/collectibles/F4.lua")
include("lua/items/collectibles/Tab.lua")
include("lua/items/collectibles/ShatteredHeart.lua")
include("lua/items/collectibles/KeysToTheKingdom.lua")
include("lua/items/collectibles/BindsOfDevotion.lua")
include("lua/items/collectibles/MuddledCross.lua")
include("lua/items/collectibles/ParasiticPoofer.lua")
include("lua/items/collectibles/HeartEmbeddedCoin.lua")
include("lua/items/collectibles/SpiritualWound/SpiritualWound.lua")
include("lua/items/collectibles/CaduceusStaff.lua")
include("lua/items/collectibles/Polydipsia.lua")
include("lua/items/collectibles/Kareth.lua")
include("lua/items/collectibles/PillarOfFire.lua")
include("lua/items/collectibles/PillarOfClouds.lua")
include("lua/items/collectibles/FirstbornSon.lua")
include("lua/items/collectibles/MiriamsWell.lua")
include("lua/items/collectibles/Quarantine.lua")
include("lua/items/collectibles/BookOfGuidance.lua")
include("lua/items/collectibles/JarOfManna.lua")
include("lua/items/collectibles/Tambourine.lua")
include("lua/items/collectibles/TheDreidel.lua")
include("lua/items/collectibles/Apocalypse.lua")
include("lua/items/collectibles/Mandrake.lua")
-- include("lua/items/collectibles/LittleSister.lua")
include("lua/items/collectibles/OldCamera.lua")
include("lua/items/collectibles/Butterfly.lua")
include("lua/items/collectibles/AlternateReality.lua")
include("lua/items/collectibles/WineBottle.lua")
include("lua/items/collectibles/Flux.lua")
-- include("lua/items/collectibles/Brainstorm.lua")
include("lua/items/collectibles/CosmicOmnibus.lua")
include("lua/items/collectibles/LittleRaincoat.lua")
include("lua/items/collectibles/BloodCyst.lua")
include("lua/items/collectibles/Polaris.lua")
include("lua/items/collectibles/D9.lua")
-- include("lua/items/collectibles/LeahsHairTie.lua")
-- include("lua/items/collectibles/LeahsTornHeart.lua")
-- include("lua/items/collectibles/PetersHeadband.lua")
-- include("lua/items/collectibles/PetersBloodyFracture.lua")
-- include("lua/items/collectibles/MiriamsHeadband.lua")
-- include("lua/items/collectibles/MiriamsPutridVeil.lua")
include("lua/items/collectibles/PolarityShift.lua")
include("lua/items/collectibles/BookOfBooks.lua")
include("lua/items/collectibles/Keratoconus.lua")
include("lua/items/collectibles/Servitude.lua")
include("lua/items/collectibles/Cardiomyopathy.lua")
include("lua/items/collectibles/Sunscreen.lua")
include("lua/items/collectibles/SecretDiary.lua")
include("lua/items/collectibles/D16.lua")
include("lua/items/collectibles/Iron.lua")
include("lua/items/collectibles/RottenApple.lua")
include("lua/items/collectibles/BeginnersLuck.lua")
include("lua/items/collectibles/DadsWallet.lua")
include("lua/items/collectibles/ChiRho.lua")
include("lua/items/collectibles/LeahsHeart.lua")
include("lua/items/collectibles/Pallium.lua")
include("lua/items/collectibles/ColdHearted.lua")
include("lua/items/collectibles/RottenLove.lua")
include("lua/items/collectibles/Rue.lua")
include("lua/items/collectibles/Exsanguination.lua")
include("lua/items/collectibles/PrayerJournal.lua")
include("lua/items/collectibles/BookOfLeviticus.lua")
include("lua/items/collectibles/MoltenGold.lua")
include("lua/items/collectibles/Trepanation.lua")
include("lua/items/collectibles/Astragali.lua")
include("lua/items/collectibles/Liberation.lua")
include("lua/items/collectibles/SeveredEar.lua")
include("lua/items/collectibles/GoldenPort.lua")
include("lua/items/collectibles/ItchingPowder.lua")

-- Trinkets
include("lua/items/trinkets/HolyHeart.lua")
include("lua/items/trinkets/SlickWorm.lua")
include("lua/items/trinkets/Grass.lua")
include("lua/items/trinkets/AlabasterScrap.lua")
include("lua/items/trinkets/LeahsLock.lua")
include("lua/items/trinkets/AbyssalPenny.lua")
include("lua/items/trinkets/SalineSpray.lua")
include("lua/items/trinkets/AlmagestScrap.lua")
include("lua/items/trinkets/WormwoodLeaf.lua")
include("lua/items/trinkets/EscapePlan.lua")
include("lua/items/trinkets/Epitaph/Epitaph.lua")
include("lua/items/trinkets/LeviathansTendril.lua")
include("lua/items/trinkets/Altruism.lua")
include("lua/items/trinkets/NilNum.lua")
include("lua/items/trinkets/KeyToThePit.lua")
include("lua/items/trinkets/BI-84.lua")
include("lua/items/trinkets/GlitchedPenny.lua")
include("lua/items/trinkets/HammerheadWorm.lua")
include("lua/items/trinkets/Parasol.lua")
include("lua/items/trinkets/Cringe.lua")

-- Enemies
include("lua/enemies/Hostikai.lua")
include("lua/enemies/Illusioner.lua")
include("lua/enemies/Goon.lua")

-- Effects
include("lua/effects/MiriamWhirlpool.lua")

-- Pockets
include("lua/pocket/SoulOfLeah.lua")
include("lua/pocket/TwoOfShields.lua")
include("lua/pocket/AceOfShields.lua")
include("lua/pocket/TrapCard.lua")
include("lua/pocket/KeyCard.lua")
include("lua/pocket/SoulOfPeter.lua")
include("lua/pocket/SoulOfMiriam.lua")
include("lua/pocket/EssenceOfLove.lua")
include("lua/pocket/EssenceOfHate.lua")
include("lua/pocket/EssenceOfLife.lua")
include("lua/pocket/EssenceOfDeath.lua")
include("lua/pocket/EssenceOfDeluge.lua")
include("lua/pocket/EssenceOfDrought.lua")
include("lua/pocket/Heartache.lua")
include("lua/pocket/GoldenCard.lua")
include("lua/pocket/Hope.lua")
include("lua/pocket/ReverseHope.lua")
include("lua/pocket/Faith.lua")
include("lua/pocket/ReverseFaith.lua")
include("lua/pocket/Charity.lua")
include("lua/pocket/ReverseCharity.lua")

-- Pickups
--include("lua/pickups/Hearts.lua")
include("lua/pickups/GoldenSack.lua")
include("lua/pickups/UnluckyPenny.lua")
include("lua/pickups/ChargedBomb.lua")

-- Floor Generation
--include("lua/rooms/NoahsArk.lua")
include("lua/rooms/HomeExit.lua")

-- Custom Challenges
include("lua/challenges/WhereAmI.lua")

-- Achievements
include("lua/achievements.lua")
include("lua/achievementCommands.lua")

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

-- Other


-------- Lua Files End --------

function Furtherance:playFailSound()
	SFXManager():Play(Furtherance.FailSound)
end

function mod:LoadDataCacheEval(player)
	if player.FrameCount == 1 then
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.LoadDataCacheEval)

-- helper callback for applying custom tear effects
-- used by Flux and Pharaoh Cat
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(self, tear)
	local data = mod:GetData(tear)
	if data.AppliedTearFlags == nil then
		data.AppliedTearFlags = {}
	end
end)

function mod:ShouldRender()
	local seeds = game:GetSeeds()
	local hud = game:GetHUD()
	if hud:IsVisible() == true and (not seeds:HasSeedEffect(SeedEffect.SEED_NO_HUD)) then
		return true
	end
	return false
end

function mod:GetScreenCenterPosition()
	local room = game:GetRoom()
	local shape = room:GetRoomShape()
	local centerOffset = (room:GetCenterPos()) - room:GetTopLeftPos()
	local pos = room:GetCenterPos()
	if centerOffset.X > 260 then
		pos.X = pos.X - 260
	end
	if shape == RoomShape.ROOMSHAPE_LBL or shape == RoomShape.ROOMSHAPE_LTL then
		pos.X = pos.X - 260
	end
	if centerOffset.Y > 140 then
		pos.Y = pos.Y - 140
	end
	if shape == RoomShape.ROOMSHAPE_LTR or shape == RoomShape.ROOMSHAPE_LTL then
		pos.Y = pos.Y - 140
	end
	return Isaac.WorldToRenderPosition(pos)
end

function mod:GetScreenSize()
	local room = game:GetRoom()
	local pos = room:WorldToScreenPosition(Vector(0, 0)) - room:GetRenderScrollOffset() - game.ScreenShakeOffset
	local rx = pos.X + 60 * 26 / 40
	local ry = pos.Y + 140 * (26 / 40)
	return Vector(rx * 2 + 13 * 26, ry * 2 + 7 * 26)
end

function mod:GetScreenCenter()
	return mod:GetScreenSize() / 2
end

function mod:GetScreenBottomRight(offset)
	offset = offset or 0
	local pos = mod:GetScreenSize()
	local hudOffset = Vector(-offset * 2.2, -offset * 1.6)
	pos = pos + hudOffset
	return pos
end

function mod:GetScreenBottomLeft(offset)
	offset = offset or 0
	local pos = Vector(0, mod:GetScreenBottomRight(0).Y)
	local hudOffset = Vector(offset * 2.2, -offset * 1.6)
	pos = pos + hudOffset
	return pos
end

function mod:GetScreenTopRight(offset)
	offset = offset or 0
	local pos = Vector(mod:GetScreenBottomRight(0).X, 0)
	local hudOffset = Vector(-offset * 2.2, offset * 1.2)
	pos = pos + hudOffset
	return pos
end

function mod:GetScreenTopLeft(offset)
	offset = offset or 0
	local pos = Vector.Zero
	local hudOffset = Vector(offset * 2, offset * 1.2)
	pos = pos + hudOffset
	return pos
end

function Furtherance:GetFireDelayFromTears(tearsPerSecond)
	return 30 / tearsPerSecond - 1
end

function Furtherance:GetTearsFromFireDelay(fireDelay)
	return 30 / (fireDelay + 1)
end

-- if a player exists at this time, the mod was just hot-reloaded with luamod
if Isaac.GetPlayer() ~= nil then
    for i = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        Furtherance:RegisterPlayer(player)
	end
	Furtherance:OnLoadData(true)
end

print("Type \"furtherancehelp\" for Furtherance commands.") ]]
