--Full credit to Epiphany for this easy and flexible EID system

--luacheck: no max line length
-- Markdown guide https://github.com/wofsauge/External-Item-Descriptions/wiki
local Mod = Furtherance
local FR_EID = {}

Furtherance.EID_Support = FR_EID

if not EID then
	return
end

local Item = Mod.Item

---@param entity Entity
---@return EntityPlayer
function FR_EID:ClosestPlayerTo(entity) --This seems to error for some people sooo yeah
	if not entity then return EID.player end

	if EID.ClosestPlayerTo then
		return EID:ClosestPlayerTo(entity)
	else
		return EID.player
	end
end

if EID.HealthUpData then
	EID.HealthUpData["5.100." .. tostring(Item.BRUNCH.ID)] = 2
	EID.HealthUpData["5.100." .. tostring(Item.LITTLE_RAINCOAT.ID)] = 1
	EID.HealthUpData["5.100." .. tostring(Item.CRAB_LEGS.ID)] = 1
	EID.HealthUpData["5.100." .. tostring(Item.COFFEE_BREAK.ID)] = 1
end

if EID.HealingItemData then
	EID.HealingItemData["5.100." .. tostring(Item.BRUNCH.ID)] = true
	EID.HealingItemData["5.100." .. tostring(Item.CRAB_LEGS.ID)] = true
	EID.HealingItemData["5.100." .. tostring(Item.COFFEE_BREAK.ID)] = true
end

if EID.SingleUseCollectibles then
	EID.SingleUseCollectibles[Item.ALTERNATE_REALITY.ID] = true
	EID.SingleUseCollectibles[Item.KEY_C.ID] = true
	EID.SingleUseCollectibles[Item.KEY_ENTER.ID] = true
	EID.SingleUseCollectibles[Item.KEY_ESC.ID] = true
	EID.SingleUseCollectibles[Item.APOCALYPSE.ID] = true
end

if EID.ItemReminderBlacklist then
end

--#region Icons

local player_icons = Sprite("gfx/ui/eid_fr_players_icon.anm2", true)

local offsetX, offsetY = 2, 1

EID:addIcon("Leah", "Leah", 0, 18, 12, offsetX, offsetY, player_icons)
EID:addIcon("Peter", "Peter", 0, 18, 12, offsetX, offsetY, player_icons)
EID:addIcon("Miriam", "Miriam", 0, 18, 12, offsetX, offsetY, player_icons)
EID:addIcon("LeahB", "LeahB", 0, 18, 12, offsetX, offsetY, player_icons)
EID:addIcon("PeterB", "PeterB", 0, 18, 12, offsetX, offsetY, player_icons)
EID:addIcon("MiriamB", "MiriamB", 0, 18, 12, offsetX, offsetY, player_icons)

-- Assign Player Icons for Birthright
EID.InlineIcons["Player" .. Mod.PlayerType.LEAH] = EID.InlineIcons["Leah"]
EID.InlineIcons["Player" .. Mod.PlayerType.PETER] = EID.InlineIcons["Peter"]
EID.InlineIcons["Player" .. Mod.PlayerType.MIRIAM] = EID.InlineIcons["Miriam"]
EID.InlineIcons["Player" .. Mod.PlayerType.LEAH_B] = EID.InlineIcons["LeahB"]
EID.InlineIcons["Player" .. Mod.PlayerType.PETER_B] = EID.InlineIcons["PeterB"]
EID.InlineIcons["Player" .. Mod.PlayerType.MIRIAM_B] = EID.InlineIcons["MiriamB"]

local cardFronts = Sprite("gfx/ui/eid_fr_cardfronts.anm2", true)

for _, cardID in ipairs(Mod.Item.OLD_CAMERA.PHOTO_IDs) do
	local name = Mod.ItemConfig:GetCard(cardID).HudAnim
	local metadata = { 12, 12, -2, 0 }
	EID:addIcon("Card" .. cardID, name, 0, metadata[1], metadata[2], metadata[3], metadata[4], cardFronts)
end

-- Assign card icons
for _, card in pairs(Mod.Card) do
	if card.ID then
		local name = Mod.ItemConfig:GetCard(card.ID).HudAnim
		local metadata = { 8, 8, 0, 1 }
		EID:addIcon("Card" .. card.ID, name, 0, metadata[1], metadata[2], metadata[3], metadata[4], cardFronts)
	end
end
for _, rune in pairs(Mod.Rune) do
	if rune.ID then
		local name = Mod.ItemConfig:GetCard(rune.ID).Name
		local metadata = { 12, 12, -4, -2 }
		EID:addIcon("Card" .. rune.ID, name, 0, metadata[1], metadata[2], metadata[3], metadata[4], cardFronts)
	end
end

local eid_icons = Sprite("gfx/ui/eid_fr_icons.anm2", true)

EID:addIcon("StrengthStatus", "Strength", 0, 10, 9, 1, 1, eid_icons)
EID:addIcon("MoonHeart", "Moon Heart", 0, 10, 9, 1, 1, eid_icons)
EID:addIcon("ItemPoolEscortBeggar", "ItemPoolEscortBeggar", 0, 11, 11, 0, 0, eid_icons)

--#endregion

--#region Helper functions

---@function
function FR_EID:GetTranslatedString(strTable)
	local lang = EID.getLanguage() or "en_us"
	local desc = strTable[lang] or strTable["en_us"] -- default to english description if there's no translation

	if desc == '' then                            --Default to english if the corresponding translation doesn't exist and is blank
		desc = strTable["en_us"];
	end

	return desc
end

--#endregion

--#region Changing mod's name and indicator for EID

EID._currentMod = "Furtherance"
EID:setModIndicatorName("Furtherance")
local CustomSprite = Sprite()
CustomSprite:Load("gfx/ui/eid_fr_mod_icon.anm2", true)
EID:addIcon("Furtherance ModIcon", "Main", 0, 8, 8, 6, 6, CustomSprite)
EID:setModIndicatorIcon("Furtherance ModIcon")

--#endregion

--#region Dynamic Descriptions functions

local DynamicDescriptions = {
	[EntityType.ENTITY_PICKUP] = {
		[PickupVariant.PICKUP_COLLECTIBLE] = {},
		[PickupVariant.PICKUP_TAROTCARD] = {},
	}
}

local DD = {} ---@class DynamicDescriptions

function DD:ContainsFunction(tbl)
	for _, v in pairs(tbl) do
		if type(v) == "function" then
			return true
		end
	end
	return false
end

---@param descTab table
---@return {Func: fun(descObj: table): (string), AppendToEnd: boolean, HasFallback: boolean}
function DD:CreateCallback(descTab, appendToEnd, hasFallback)
	return {
		Func = function(descObj)
			return table.concat(
				Mod:Map(
					descTab,
					function(val)
						if type(val) == "function" then
							local ret = val(descObj)
							if type(ret) == "table" then
								return table.concat(ret, "")
							elseif type(ret) == "string" then
								return ret
							else
								return ""
							end
						end

						return val or ""
					end
				),
				""
			)
		end,
		AppendToEnd = appendToEnd or false,
		HasFallback = hasFallback or false
	}
end

---@param modFunc { Func: function } | fun(descObj: table): string
---@param type integer
---@param variant integer
---@param subtype integer
---@param language string
function DD:SetCallback(modFunc, type, variant, subtype, language)
	if not DynamicDescriptions[type] then
		DynamicDescriptions[type] = {}
	end

	if not DynamicDescriptions[type][variant] then
		DynamicDescriptions[type][variant] = {}
	end

	if not DynamicDescriptions[type][variant][subtype] then
		DynamicDescriptions[type][variant][subtype] = {}
	end

	if not DynamicDescriptions[type][variant][subtype][language] then
		DynamicDescriptions[type][variant][subtype][language] = modFunc
	else
		error("Description modifier already exists for " .. type .. " " .. variant .. " " .. subtype .. " " .. language,
			2)
	end
end

---@param type integer
---@param variant integer
---@param subtype integer
---@param language string
---@return {Func: fun(descObj: table): (string?), AppendToEnd: boolean, HasFallback: boolean}?
function DD:GetCallback(type, variant, subtype, language)
	if not DynamicDescriptions[type] then
		return nil
	end

	if not DynamicDescriptions[type][variant] then
		return nil
	end

	if not DynamicDescriptions[type][variant][subtype] then
		return nil
	end

	if not DynamicDescriptions[type][variant][subtype][language] then
		return DynamicDescriptions[type][variant][subtype]
			["en_us"] -- fallback to english if no translation is available
	end

	return DynamicDescriptions[type][variant][subtype][language]
end

-- concat all subsequent string elements of a dynamic description
-- into one string so we have to concat less stuff at runtime
--
-- this is very much a micro optimization but at worst it does nothing
---@param desc (string | function)[] | function
---@return (string | function)[]
function DD:MakeMinimizedDescription(desc)
	if type(desc) == "function" then
		return { desc }
	end

	local out = {}
	local builder = {}

	for _, strOrFunc in ipairs(desc) do
		if type(strOrFunc) == "string" then
			builder[#builder + 1] = strOrFunc
		elseif type(strOrFunc) == "function" then
			out[#out + 1] = table.concat(builder, "")
			builder = {}
			out[#out + 1] = strOrFunc
		end
	end

	out[#out + 1] = table.concat(builder, "")

	return out
end

---@param desc (string | function)[] | function
---@return boolean
function DD:IsValidDescription(desc)
	if type(desc) == "function" then
		return true
	elseif type(desc) == "table" then
		for _, val in ipairs(desc) do
			if type(val) ~= "string" and type(val) ~= "function" then
				return false
			end
		end
	end

	return true
end

FR_EID.DynamicDescriptions = DD

--#endregion

---@param player EntityPlayer
---@param trinketId TrinketType
function FR_EID:TrinketMulti(player, trinketId)
	local multi = 1
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
		multi = multi + 1
	end
	if Mod:HasBitFlags(trinketId, TrinketType.TRINKET_GOLDEN_FLAG) then
		multi = multi + 1
	end

	return multi
end

---@param multiplier integer
---@param ... string
function FR_EID:TrinketMultiStr(multiplier, ...)
	return ({ ... })[multiplier] or ""
end

function FR_EID:TrinketMultiGoldStr(player, trinketID, num)
	local multi = FR_EID:TrinketMulti(player, trinketID)
	if multi > 1 then
		return "{{ColorGold}}" .. num * multi .. "{{CR}}"
	end
	return num
end

local min = math.min
local max = math.max
local floor = math.floor

---@param player EntityPlayer
---@param modifier TearModifier
---@param chanceMult integer
function FR_EID:GetTearModifierMaxLuckChance(player, modifier, chanceMult)
	local luck = player.Luck
	player.Luck = 0
	local minChance = modifier:GetChance(player, true, chanceMult)
	player.Luck = luck
	local maxLuck = modifier.MaxLuck
	local luckWorth = (modifier.MaxChance - modifier.MinChance) / (modifier.MaxLuck - modifier.MinLuck)
	local maxChance = minChance + (luckWorth * modifier.MaxLuck)
	if maxChance > 1 then
		local luckSavedInChance = floor((maxChance - 1) / luckWorth)
		maxLuck = max(0, maxLuck - luckSavedInChance)
	end
	return maxChance, maxLuck
end

---@param str string
---@param player EntityPlayer
---@param modifier TearModifier
---@param chanceMult integer
function FR_EID:LuckChanceStr(str, player, modifier, chanceMult)
	local maxChance, maxLuck = FR_EID:GetTearModifierMaxLuckChance(player, modifier, chanceMult)
	local maxChanceCapped = min(1, maxChance)
	local maxChanceStr = (tostring(floor(maxChanceCapped * 100)))
	local maxLuckStr = tostring(maxLuck)
	--So that a golden glow doesn't trigger at 100% chance
	if maxChanceCapped > modifier.MaxChance then
		maxChanceStr = "{{ColorGold}}" .. maxChanceStr .. "{{CR}}"
	end
	if maxLuck < modifier.MaxLuck then
		maxLuckStr = "{{ColorGold}}" .. maxLuckStr .. "{{CR}}"
	end
	return str:format(maxChanceStr .. "%", maxLuckStr)
end

---@param descObj EID_DescObj
function FR_EID.GetFallbackDescription(descObj)
	return EID:getDescriptionObj(5, 100, descObj.ObjSubType, nil, false).Description
end

local eidCategory = {
	"items",
	"trinkets",
	"cards",
	"pills",
	"entities",
	"characters",
	"birthrights"
}

for _, category in ipairs(eidCategory) do
	Mod.Include("scripts.compatibility.patches.eid.eid_" .. category .. "_descriptions")
end

EID:addDescriptionModifier(
	"Furtherance Dynamic Description Manager",
	-- condition
	---@param descObj EID_DescObj
	function(descObj)
		local subtype = descObj.ObjSubType
		if descObj.ObjVariant == PickupVariant.PICKUP_TRINKET then
			subtype = Mod:RemoveBitFlags(subtype, TrinketType.TRINKET_GOLDEN_FLAG)
		elseif descObj.ObjVariant == PickupVariant.PICKUP_PILL then
			subtype = Mod.Game:GetItemPool():GetPillEffect(subtype, FR_EID:ClosestPlayerTo(descObj.Entity))
		end

		return DD:GetCallback(descObj.ObjType, descObj.ObjVariant, subtype, EID.getLanguage() or "en_us") ~= nil
	end,
	-- modifier
	function(descObj)
		local subtype = descObj.ObjSubType
		if descObj.ObjVariant == PickupVariant.PICKUP_TRINKET then
			subtype = Mod:RemoveBitFlags(subtype, TrinketType.TRINKET_GOLDEN_FLAG)
		elseif descObj.ObjVariant == PickupVariant.PICKUP_PILL then
			subtype = Mod.Game:GetItemPool():GetPillEffect(subtype, FR_EID:ClosestPlayerTo(descObj.Entity))
		end

		local callback = DD:GetCallback(descObj.ObjType, descObj.ObjVariant, subtype, EID.getLanguage() or "en_us")
		local descString = callback.Func(descObj) ---@diagnostic disable-line: need-check-nil

		if callback.AppendToEnd then ---@diagnostic disable-line: need-check-nil
			descObj.Description = descObj.Description .. descString
		elseif callback.HasFallback then ---@diagnostic disable-line: need-check-nil
			descObj.Description = descString
		else
			descObj.Description = descString .. descObj.Description
		end
		return descObj
	end
)

EID._currentMod = "Furtherance_reserved" -- to prevent other mods overriding Furtherance mod items
