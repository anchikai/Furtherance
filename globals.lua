---@meta
---@diagnostic disable: lowercase-global
-- This file only exists to tell the code editor what exists outside of the mod folder to stop it complaining
ModConfigMenu = {}
ModConfigMenuPopupGfx = {}
ANDROMEDA = {}
arachnaIsUnlocked = {}
CCO = {}
RareChest = {}
CustomCollectibles = {}
RepentancePlusMod = {}
CustomPickups = {}
SpecialistModAPI = {}
TaintedCollectibles = {}
TaintedMachines = {}
Sewn_API = {}
FiendFolio = {}
RareChests = {}
StageAPI = {} -- Ew
HeavensCall = {}
TaintedTreasure = {}
RAAV = {}
ThePunished = {}
Poglite = {} -- Pog for good items
Epic = {} -- Specialist for good items
REVEL = {} -- Revelations
FilepathHelper = {}
CorruptedCharactersMod = {} -- Old mod namespace
SamaelMod = {}
CustomHealthAPI = {}
Retribution = {}
yandereWaifu = {} -- Rebekah
TheFuture = {}
UNINTRUSIVEPAUSEMENU = {}
MinimapAPI = {}
MiniPauseMenu_Mod = {}
MiniPauseMenuPlus_Mod = {}
Encyclopedia = {}
EID = {}
LibraryExpanded = {}
UnlockAPI = {}
FFGRACE = {}
REPENTOGON = {}
HudHelper = {}
StatusEffectLibrary = {}
HPBars = {}
Epiphany = {}
CustomCoopGhost = {}
Ughlite = {} --Ugh for bad items
NoCostumes = {}
GodsGambit = {}
UniqueProgressBarIcon = {}
EnlightenmentMod = {}
UniqueProgressBarIcon = {}
CustomPoopAPI = {} --From Fiend Folio
EeveeMod = {}

---@class EID_DescObj
---@field ObjType integer
---@field ObjVariant integer
---@field ObjSubType integer
---@field fullItemString string
---@field Name string
---@field Description string
---@field Transformation string
---@field ModName string
---@field Quality integer
---@field Icon table @[see docs](https://github.com/wofsauge/External-Item-Descriptions/wiki/Description-Modifiers#description-object-attributes)
---@field Entity Entity?
---@field ShowWhenUndefined boolean

---Simple function to help with adding properly formatted sections to the reminder description
---returns false, when no further descriptions should be added
---@param icon string?
---@param title string
---@param newDesc string
function EID:ItemReminderAddTempDescriptionEntry(icon, title, newDesc) end

---@param categoryID string
---@return boolean
function EID:IsCategorySelected(categoryID) end

---returns true, if its possible for the currently evaluated view to have more descriptions added to it
---@return boolean
function EID:ItemReminderCanAddMoreToView() end

-- Adds a new icon object with the shortcut defined in the "shortcut" variable (e.g. "{{shortcut}}" = your icon)
-- Shortcuts are case Sensitive! Shortcuts can be overriden with this function to allow for full control over everything
-- Setting "animationFrame" to -1 will play the animation. The spriteObject needs to be of class Sprite() and have an .anm2 loaded
-- default values: leftOffset= -1 , topOffset = 0
function EID:addIcon(shortcut, animationName, animationFrame, width, height, leftOffset, topOffset, spriteObject)end

-- Add text to a pedestal's description when you own a different item
--
-- Example usage: EID:addCondition(myDevilishItemID, EID.IsGreedMode, "{{GreedMode}} Reduces shop prices by 1 for each optional Nightmare wave completed")
---@param ID CollectibleType | string | table @ID and ownedID can be a collectible ID or a full item string (like "5.350.54"). For convenience, ID can be a table of IDs that will all get the condition applied
---@param ownedID integer | function @ownedID can also be a function rather than just an ID; if it returns true, the text will be displayed
---@param text string @The text will be added as a new line, with the owned item's icon at the start
---@param replaceText? string @If you pass in replaceText, instead the text is found in the description and replaced with replaceText
---@param language? string
---@param extraTable? table
function EID:addCondition(ID, ownedID, text, replaceText, language, extraTable) end

---@type string
MOD_PATH = nil

CARDBOARD_CHEST = Isaac.GetEntityVariantByName("Cardboard Chest")
FILE_CABINET = Isaac.GetEntityVariantByName("File Cabinet")
SLOT_CHEST = Isaac.GetEntityVariantByName("Slot Chest")
TOMB_CHEST = Isaac.GetEntityVariantByName("Tomb Chest")
DEVIL_CHEST = Isaac.GetEntityVariantByName("Devil Chest")
CURSED_CHEST = Isaac.GetEntityVariantByName("Cursed Chest")
BLOOD_CHEST = Isaac.GetEntityVariantByName("Blood Chest")
PENITENT_CHEST = Isaac.GetEntityVariantByName("Penitent Chest")

_ = {} ---@type any

--[[
	MinimapAPI:AddPickup(
		id, -- ID of the pickup, can be a string
		Icon, -- see AddIcon
		EntityType,
		number variant,
		number subtype,
		function,
		icongroup,
		number priority) -- Icons with higher priorities will be displayed over other icons. Default = 13000

	MinimapAPI:AddIcon(
		id, -- ID of the icon, will be put inside of Icon in add pickup
		Sprite,
		string animationName,
		number frame,
		(optional) Color color)
]]

---@param id string
---@param icon string @Same ID you used in :AddIcon()
---@param entType EntityType
---@param variant integer
---@param subtype integer
---@param func fun(): boolean
---@param iconGroup "slots" | "keys" | "cards" | "coins" | "other" | "hearts" | "bombs"
---@param number? number @default: `13000`
function MinimapAPI:AddPickup(id, icon, entType, variant, subtype, func, iconGroup, number)
end

---@param id string
---@param sprite Sprite
---@param animationName string
---@param frame number
---@param color? Color
function MinimapAPI:AddIcon(id, sprite, animationName, frame, color)
end

MinimapAPI.PickupSlotMachineNotBroken = function() return true end
MinimapAPI.PickupChestNotCollected = function() return true end
MinimapAPI.PickupNotCollected = function() return true end