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
local Trinket = Mod.Trinket

function FR_EID:ClosestPlayerTo(entity) --This seems to error for some people sooo yeah
	if not entity then return EID.player end

	if EID.ClosestPlayerTo then
		return EID:ClosestPlayerTo(entity)
	else
		return EID.player
	end
end

--#region Icons
local player_icons = Sprite()
player_icons:Load("gfx/ui/eid_character_icons.anm2", true)

local offsetX, offsetY = 6, 6

EID:addIcon("Leah", "Main", 1, 16, 16, offsetX, offsetY, player_icons)
EID:addIcon("Peter", "Main", 2, 16, 16, offsetX, offsetY, player_icons)
EID:addIcon("Miriam", "Main", 3, 16, 16, offsetX, offsetY, player_icons)
EID:addIcon("LeahB", "Main", 21, 16, 16, offsetX, offsetY, player_icons)
EID:addIcon("PeterB", "Main", 21, 16, 16, offsetX, offsetY, player_icons)
EID:addIcon("MiriamB", "Main", 20, 16, 16, offsetX, offsetY, player_icons)

-- Assign Player Icons for Birthright
EID.InlineIcons["Player" .. Mod.PlayerType.LEAH] = EID.InlineIcons["Leah"]
EID.InlineIcons["Player" .. Mod.PlayerType.PETER] = EID.InlineIcons["Peter"]
EID.InlineIcons["Player" .. Mod.PlayerType.MIRIAM] = EID.InlineIcons["Miriam"]
EID.InlineIcons["Player" .. Mod.PlayerType.LEAH_B] = EID.InlineIcons["LeahB"]
EID.InlineIcons["Player" .. Mod.PlayerType.PETER_B] = EID.InlineIcons["PeterB"]
EID.InlineIcons["Player" .. Mod.PlayerType.MIRIAM] = EID.InlineIcons["MiriamB"]

-- Assign card icons
local cardFronts = Sprite("gfx/ui/eid_furtherance_cardfronts.anm2", true)
for _, card in pairs(Mod.Card) do
	if card.ID then
		local name = Mod.ItemConfig:GetCard(card.ID).Name
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
CustomSprite:Load("gfx/ui/eid_furtherance_mod_icon.anm2", true)
EID:addIcon("Furtherance ModIcon", "Main", 0, 8, 8, 6, 6, CustomSprite)
EID:setModIndicatorIcon("Furtherance ModIcon")

--#endregion

--#region Dynamic Descriptions functions

local function containsFunction(tbl)
	for _, v in pairs(tbl) do
		if type(v) == "function" then
			return true
		end
	end
	return false
end

local DynamicDescriptions = {
	[EntityType.ENTITY_PICKUP] = {
		[PickupVariant.PICKUP_COLLECTIBLE] = {},
		[PickupVariant.PICKUP_TAROTCARD] = {},
	}
}

local DD = {} ---@class DynamicDescriptions

---@param descTab table
---@return {Func: fun(descObj: table): (string), AppendToEnd: boolean}
function DD:CreateCallback(descTab, appendToEnd)
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
								return {
									"Placeholder"
								}
							end
						end

						return val or ""
					end
				),
				""
			)
		end,
		AppendToEnd = appendToEnd or false
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
---@return {Func: fun(descObj: table): (string?), AppendToEnd: boolean}?
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

local function trinketMulti(player, trinketId)
	return FR_EID:TrinketMulti(player, trinketId)
end

local function trinketMultiStr(multiplier, ...)
	return FR_EID:TrinketMultiStr(multiplier, ...)
end

-- OK means the language's description has been made
-- ! means the description needs to be updated
-- X means the description hasn't been done yet

--!EXAMPLE SETUP
--[[ [Item.X.ID] = { -- EN: [OK] | RU: [X] | SPA: [X]
		_modifier = function(descStr)
			return descStr .. " but epic"
		end,

		en_us = {
			Name = "PlaceholderName"
			---@param descObj EID_DescObj
			Description = function(descObj)
				return EID_Collectibles[Item.X]._modifier()
			end
		},
}, ]]

local EID_Collectibles -- this allows modifier functions defined inside this table to index it without causing an error
EID_Collectibles = {
	[Item.ALTERNATE_REALITY.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.APOCALYPSE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.ASTRAGALI.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.BEGINNERS_LUCK.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.BINDS_OF_DEVOTION.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.BLOOD_CYST.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.BOOK_OF_AMBIT.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.BOOK_OF_BOOKS.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.BOOK_OF_GUIDANCE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.BOOK_OF_LEVITICUS.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.BOOK_OF_SWIFTNESS.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.BRUNCH.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.BUTTERFLY.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.CADUCEUS_STAFF.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.CARDIOMYOPATHY.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.CERES.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.CHIRON.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.CHI_RHO.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.COLD_HEARTED.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.COSMIC_OMNIBUS.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.CRAB_LEGS.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.D16.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.D9.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.EPITAPH.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.EXSANGUINATION.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.FIRSTBORN_SON.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.FLUX.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.GOLDEN_PORT.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.HEART_EMBEDDED_COIN.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.HEART_RENOVATOR.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.IRON.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.ITCHING_POWDER.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.JAR_OF_MANNA.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.JUNO.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KARETH.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KERATOCONUS.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KEYS_TO_THE_KINGDOM.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KEY_ALT.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KEY_BACKSPACE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KEY_C.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KEY_CAPS.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KEY_E.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KEY_ENTER.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KEY_ESC.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KEY_F4.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KEY_Q.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KEY_SHIFT.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KEY_SPACEBAR.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KEY_TAB.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.KEY_TILDE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.LEAHS_HEART.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.LEAKING_TANK.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.LIBERATION.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.LITTLE_RAINCOAT.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.MANDRAKE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.MIRIAMS_WELL.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.MOLTEN_GOLD.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.MUDDLED_CROSS.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.BOX_OF_BELONGINGS.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.OLD_CAMERA.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.OPHIUCHUS.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.OWLS_EYE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.PALLAS.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.PALLIUM.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.LIL_POOFER.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.PHARAOH_CAT.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.PILLAR_OF_CLOUDS.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.PILLAR_OF_FIRE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.PLUG_N_PLAY.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.POLARIS.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.POLARITY_SHIFT.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.PRAYER_JOURNAL.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.QUARANTINE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.ROTTEN_APPLE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.COFFEE_BREAK.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.RUE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.SECRET_DIARY.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.SERVITUDE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.SEVERED_EAR.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.SHATTERED_HEART.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.SPIRITUAL_WOUND.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.SUNSCREEN.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.TAMBOURINE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.TECHNOLOGY_MINUS_1.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.TECH_IX.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.THE_DREIDEL.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.TREPANATION.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.UNSTABLE_CORE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.VESTA.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.WINE_BOTTLE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Item.ZZZZOPTIONSZZZZ.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
}

for id, collectibleDescData in pairs(EID_Collectibles) do
	for language, descData in pairs(collectibleDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid collectible description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		local minimized = DD:MakeMinimizedDescription(description)

		if not containsFunction(minimized) and not collectibleDescData._AppendToEnd then
			EID:addCollectible(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla items that already have one
			if not EID.descriptions[language].collectibles[id] then
				EID:addCollectible(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, collectibleDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COLLECTIBLE, id, language)
		end

		::continue::
	end
end

local EID_Trinkets
EID_Trinkets = {
	[Trinket.ABYSSAL_PENNY.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.ALABASTER_SCRAP.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.ALMAGEST_SCRAP.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.ALTRUISM.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.BI_84.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.CRINGE.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.DUNGEON_KEY.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.ESCAPE_PLAN.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.GLITCHED_PENNY.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.GRASS.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.HAMMERHEAD_WORM.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.HOLY_HEART.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.LEAHS_LOCK.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.LEVIATHANS_TENDRIL.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.NIL_NUM.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.PARASOL.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.REBOUND_WORM.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.SALINE_SPRAY.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Trinket.WORMWOOD_LEAF.ID] = {
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
}

for id, trinketDescData in pairs(EID_Trinkets) do
	for language, descData in pairs(trinketDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid trinket description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		local minimized = DD:MakeMinimizedDescription(description)

		if not containsFunction(minimized) and not trinketDescData._AppendToEnd then
			EID:addTrinket(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla trinkets that already have one
			if not EID.descriptions[language].trinkets[id] then
				EID:addTrinket(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, trinketDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_TRINKET, id, language)
		end

		::continue::
	end
end

--Tarot Cloth uses ColorShinyPurple

local EID_Cards
EID_Cards = {
	[Mod.Card.ACE_OF_SHIELDS.ID] = {
		_metadata = { 12, false },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Card.CHARITY.ID] = {
		_metadata = { 2, false },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Card.FAITH.ID] = {
		_metadata = { 2, false },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Card.GOLDEN_CARD.ID] = {
		_metadata = { 12, false },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Card.HOPE.ID] = {
		_metadata = { 2, false },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Card.KEY_CARD.ID] = {
		_metadata = { 6, false },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Card.REVERSE_CHARITY.ID] = {
		_metadata = { 2, false },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Card.REVERSE_FAITH.ID] = {
		_metadata = { 2, false },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Card.REVERSE_HOPE.ID] = {
		_metadata = { 2, false },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Card.TRAP_CARD.ID] = {
		_metadata = { 1, false },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Card.TWO_OF_SHIELDS.ID] = {
		_metadata = { 12, false },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Rune.ESSENCE_OF_DEATH.ID] = {
		_metadata = { 4, true },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Rune.ESSENCE_OF_DELUGE.ID] = {
		_metadata = { 1, true },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Rune.ESSENCE_OF_DROUGHT.ID] = {
		_metadata = { 2, true },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Rune.ESSENCE_OF_HATE.ID] = {
		_metadata = { 6, true },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Rune.ESSENCE_OF_LIFE.ID] = {
		_metadata = { 2, true },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Rune.ESSENCE_OF_LOVE.ID] = {
		_metadata = { 3, true },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Rune.SOUL_OF_LEAH.ID] = {
		_metadata = { 6, true },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Rune.SOUL_OF_MIRIAM.ID] = {
		_metadata = { 12, true },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Rune.SOUL_OF_PETER.ID] = {
		_metadata = { 6, true },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
}

for id, cardDescData in pairs(EID_Cards) do
	for language, descData in pairs(cardDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description
		local metadata = cardDescData._metadata

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid card description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		local minimized = DD:MakeMinimizedDescription(description)

		if not containsFunction(minimized) and not cardDescData._AppendToEnd then
			EID:addCard(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla cards that already have one
			if not EID.descriptions[language].cards[id] then
				EID:addCard(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, cardDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_TAROTCARD, id, language)
		end

		if metadata then
			EID:addCardMetadata(id, metadata[1], metadata[2])
		end

		::continue::
	end
end

local EID_Pills
EID_Pills = {
	[Mod.Pill.HEARTACHE.ID_UP] = {
		_metadata = { 4, "3-" },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
	[Mod.Pill.HEARTACHE.ID_DOWN] = {
		_metadata = { 6, "3+" },
		en_us = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
}

for id, pillDescData in pairs(EID_Pills) do
	for language, descData in pairs(pillDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description
		local metadata = pillDescData._metadata

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid pill description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		local minimized = DD:MakeMinimizedDescription(description)

		if not containsFunction(minimized) and not pillDescData._AppendToEnd then
			EID:addPill(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla pills that already have one
			if not EID.descriptions[language].pills[id + 1] then
				EID:addPill(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, pillDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_PILL, id, language)
		end

		if metadata then
			EID:addPillMetadata(id, metadata[1], metadata[2])
		end

		::continue::
	end
end

local EID_Entities = {
	[EntityType.ENTITY_PICKUP] = {
		[PickupVariant.PICKUP_BOMB] = {
			[Mod.Pickup.CHARGED_BOMB.ID] = {
				en_us = {
					Name = "PlaceholderName",
					Description = {
						"PlaceholderDesc"
					}
				},
				ru = {
					Name = "PlaceholderName",
					Description = {
						"PlaceholderDesc"
					}
				},
				spa = {
					Name = "PlaceholderName",
					Description = {
						"PlaceholderDesc"
					}
				}
			},
		},
		[PickupVariant.PICKUP_GRAB_BAG] = {
			[Mod.Pickup.GOLDEN_SACK.ID] = {
				en_us = {
					Name = "PlaceholderName",
					Description = {
						"PlaceholderDesc"
					}
				},
				ru = {
					Name = "PlaceholderName",
					Description = {
						"PlaceholderDesc"
					}
				},
				spa = {
					Name = "PlaceholderName",
					Description = {
						"PlaceholderDesc"
					}
				}
			},
		},
		[PickupVariant.PICKUP_HEART] = {
			[Mod.Pickup.MOON_HEART.ID] = {
				en_us = {
					Name = "PlaceholderName",
					Description = {
						"PlaceholderDesc"
					}
				},
				ru = {
					Name = "PlaceholderName",
					Description = {
						"PlaceholderDesc"
					}
				},
				spa = {
					Name = "PlaceholderName",
					Description = {
						"PlaceholderDesc"
					}
				}
			},
		},
		[PickupVariant.PICKUP_COIN] = {
			[Mod.Pickup.UNLUCKY_PENNY.ID] = {
				en_us = {
					Name = "PlaceholderName",
					Description = {
						"PlaceholderDesc"
					}
				},
				ru = {
					Name = "PlaceholderName",
					Description = {
						"PlaceholderDesc"
					}
				},
				spa = {
					Name = "PlaceholderName",
					Description = {
						"PlaceholderDesc"
					}
				}
			},
		},
	},
	[EntityType.ENTITY_SLOT] = {

	},
}

for type, variantDescData in pairs(EID_Entities) do
	for variant, subtypeDescData in pairs(variantDescData) do
		for subtype, entityDescData in pairs(subtypeDescData) do
			for language, descData in pairs(entityDescData) do
				if language:match('^_') then goto continue end -- skip helper private fields

				local name = descData.Name
				local description = descData.Description

				if not DD:IsValidDescription(description) then
					Mod:Log("Invalid entity description for " .. name .. " (" .. subtype .. ")", "Language: " .. language)
					goto continue
				end

				local minimized = DD:MakeMinimizedDescription(description)
				if not containsFunction(minimized) and not entityDescData._AppendToEnd then
					EID:addEntity(type, variant, subtype, name, table.concat(minimized, ""), language)
				else
					EID:addEntity(type, variant, subtype, "", name, language) -- description only contains name/language, the actual description is generated at runtime
					DD:SetCallback(DD:CreateCallback(minimized, entityDescData._AppendToEnd), type, variant, subtype,
						language)
				end

				::continue::
			end
		end
	end
end

local EID_Birthrights
EID_Birthrights = {

}

local EID_Characters
EID_Characters = {

}

for playerId, brDescData in pairs(EID_Birthrights) do
	for lang, descData in pairs(brDescData) do
		if not DD:IsValidDescription(descData.Description) or containsFunction(descData.Description) then
			Mod:Log("Invalid birthright description for " .. descData.Name, "Language: " .. lang)
		else
			EID:addBirthright(playerId, table.concat(descData.Description, ""), descData.Name, lang)
		end
	end
end

for playerId, charDescData in pairs(EID_Characters) do
	for lang, descData in pairs(charDescData) do
		if not DD:IsValidDescription(descData.Description) or containsFunction(descData.Description) then
			Mod:Log("Invalid character description for " .. descData.Name, "Language: " .. lang)
		else
			EID:addCharacterInfo(playerId, table.concat(descData.Description, ""), descData.Name, lang)
		end
	end
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
		else
			descObj.Description = descString .. descObj.Description
		end

		return descObj
	end
)

EID._currentMod = "Furtherance_reserved" -- to prevent other mods overriding Furtherance mod items
