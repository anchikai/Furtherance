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
	EID.HealthUpData["5.100." .. tostring(Item.COFFEE_BREAK.ID)] = 1
end

if EID.HealingItemData then
	EID.HealingItemData["5.100." .. tostring(Item.BRUNCH.ID)] = true
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
	EID.ItemReminderBlacklist["5.100."..Item.SPIRITUAL_WOUND.ID] = true
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

-- Assign card icons
local cardFronts = Sprite("gfx/ui/eid_fr_cardfronts.anm2", true)
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

local eid_icons = Sprite("gfx/ui/eid_fr_icons.anm2", true)

EID:addIcon("StrengthStatus", "Strength", 0, 10, 9, 1, 1, eid_icons)
EID:addIcon("MoonHeart", "Moon Heart", 0, 10, 9, 1, 1, eid_icons)

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
								return ""
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
			Name = "Alternate Reality",
			Description = {
				"Sends Isaac to a completely random stage with a random stage variant",
				"#Includes any floor from The Basement to The Void, including the alt path"
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
			Name = "Apocalypse",
			Description = {
				"!!! Removes all passive items in exchange for two of any of the following stat buffs selected at random per item removed:",
				"#{{Speed}} +0.05 Speed",
				"#{{Tears}} -0.5 Tear delay",
				"#{{Damage}} +1 Damage",
				"#{{Range}} +0.3 Range",
				"#{{Shotspeed}} +0.1 Shot speed",
				"#{{Luck}} +1 Luck"
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
			Name = "Astragali",
			Description = {
				"Rerolls all chests in the room into other chest variants"
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
			Name = "Beginner's Luck",
			Description = {
				"↑ {{Luck}} +10 Luck",
				"#For every new unexplored room you enter, {{Luck}} -1 Luck until the it cancels out the luck granted by this item",
				"#Luck is granted back on the next floor"
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
			Name = "Binds of Devotion",
			Description = {
				"{{Player19}} Spawns Jacob as a second character without Esau",
				"#When he dies, permanently removes Binds of Devotion and any item that he has picked up from his inventory",
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
			Name = "Blood Cyst",
			Description = {
				"Spawns a Blood Cyst in a random spot upon entering an uncleared room",
				"#Damaging the Blood Cyst will cause it to explode, shooting out a fountain of 20 tears"
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
			Name = "Book of Ambit",
			Description = {
				"{{Timer}} Receive for the room:",
				"#↑ {{Range}} +5 Range",
				"#↑ {{Shotspeed}} +1.5 Shot speed",
				"# Piercing tears"
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
			Name = "Book of Books",
			Description = {
				"Uses a random book active item"
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
			Name = "Book of Guidance",
			Description = {
				"{{Collectible175}} For the remainder of the floor, all doors are unlocked as if used with Dad's Key"
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
		---@param descObj EID_DescObj
		_modifier = function(descObj)
			local desc = EID:getDescriptionObj(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_REVERSE_TOWER, descObj.Entity, true)
			return desc and desc.Description or "{{Card72}} Uses XVI - The Tower?"
		end,
		en_us = {
			Name = "Book of Leviticus",
			Description = {
				function(descObj)
					return EID_Collectibles[Item.BOOK_OF_LEVITICUS.ID]._modifier(descObj)
				end
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
		---@param descObj EID_DescObj
		_modifier = function(descObj)
			local desc = EID:getDescriptionObj(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_ERA_WALK, descObj.Entity, true)
			return desc and desc.Description or "{{Card54}} Uses Era Walk"
		end,
		en_us = {
			Name = "Book of Swiftness",
			Description = {
				function(descObj)
					return EID_Collectibles[Item.BOOK_OF_SWIFTNESS.ID]._modifier(descObj)
				end
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
			Name = "Brunch",
			Description = {
				"↑ {{Heart}} +2 Health",
				"#{{HealingRed}} Heals 4 hearts",
				"#↑ {{Shotspeed}} +0.16 Shot speed"
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
			Name = "Butterfly",
			Description = {
				"Taking damage causes Isaac to shoot out tears at 50% damage in random directions for 1 second"
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
			Name = "Caduceus Staff",
			Description = {
				"5% chance for damage taken to not remove any health and grant either a {{Heart}} Red Heart, {{SoulHeart}} Soul Heart, or half of both depending on Isaac's health",
				"#If effect wasn't triggered upon taking damage, doubles chance to trigger on next damage",
				"#Chance resets upon effect activating"
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
			Name = "Cardiomyopathy",
			Description = {
				"{{Timer}} Picking up hearts that grant {{Heart}} Red Health has a chance to grant invincibility for 1 second",
				"#Chance is a stacking 25% for each half a heart the it would grant"
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
			Name = "Ceres?",
			Description = {
				"5% chance to shoot a green tear that causes the enemy to start leaving green creep for 3 seconds",
				"#{{Luck}} 50% chance at 9 luck",
				"#The creep deals 30 damage per second to other enemies",
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
			Name = "Chiron?",
			Description = {
				--Book of Secrets description
				"{{Timer}} Each floor, grants one of these effects for the floor:#{{Collectible54}} Treasure Map#{{Collectible21}} Compass#{{Collectible246}} Blue Map",
				"#{{BossRoom}} Entering a boss room activates a random \"offensive\" book"
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
			Name = "Chi Rho",
			Description = {
				"{{Collectible643}} 2% chance to fire a holy beam while shooting",
				"#{{Luck}} 15% chance at 15 luck"
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
			Name = "Cold Hearted",
			Description = {
				"{{Freezing}} Touching enemies freezes them",
				"#{{Slow}} Touching bosses slows them for 5 seconds"
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
			Name = "Cosmic Omnibus",
			Description = {
				"Teleports Isaac to a random unvisited special room on the floor",
				"#{{Planetarium}} If all special rooms on the floor have been visited, teleports Isaac to an extra Planetarium room",
				"#Subsequent uses sends Isaac to a random special room on the floor"
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
			Name = "Crab Legs",
			Description = {
				"Walking in a perpendicular direction to the direction you're shooting grants {{Speed}} +0.3 Speed"
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
			Name = "D16",
			Description = {
				"Rerolls all heart pickups in the room into other heart variants"
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
			Name = "D9",
			Description = {
				"Rerolls all trinkets in the room into other trinkets"
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
			Name = "Epitaph",
			Description = {
				"{{Collectible545}} 10% chance for dead enemies to revive upon room clear as a bone orbital or a skeletal companion",
				"#Dying with this item will create a tombstone in a random room on the same floor you died on for the next run",
				"#{{Collectible}} Bombing the tombstone 3 times spawns {{Coin}} 3-5 coins, {{Key}} 2-3 keys, and the first and last passive items in you had in your inventory the previous run"
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
			Name = "Exsanguination",
			Description = {
				"↑ Every heart pickup grants a permament {{Damage}} +0.05 Damage up",
				"#Newly spawned hearts have a 50% chance to start flashing, disappearing after 2 seconds"
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
			Name = "Firstborn Son",
			Description = {
				"{{Collectible634}} When in an uncleared room with enemies, will turn into a homing exploding ghost",
				"#The ghost will target the enemy with the folowing priorities: Non-bosses over bosses > Highest health > Closest to the ghost ",
				"#Will instantly kill the targeted enemy and does not damage other enemies. If a boss, deals 10% of their maximum health instead"
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
			Name = "Flux",
			Description = {
				"↑ Grants {{Range}} +9.75 Range and spectral tears",
				"#Tears only move when Isaac moves",
				"#Shoot tears in the opposite direction that mirror Isaac's movement"
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
			Name = "Golden Port",
			Description = {
				"{{Battery}} Using an uncharged active fully recharges it at the cost of 5 cents",
				"#Only works when the item has no charges"
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
			Name = "Heart Embedded Coin",
			Description = {
				"{{Coin}} Picking up {{Heart}} Red Hearts while at full health gives that heart's worth in coins instead"
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
			Name = "Heart Renovator",
			Description = {
				"Can pick up {{Heart}} Red Hearts while at full red health puts them in a special counter, up to 99 total health",
				"#!!! Double tapping {{ButtonRT}} removes 2 from the counter and grants a {{BrokenHeart}} Broken Heart",
				"#↑ Upon use, removes a Broken Heart and grants a permanent {{Damage}} +0.5 Damage up"
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
			Name = "Iron",
			Description = {
				"Orbital",
				"#{{Collectible257}} Friendly tears hitting it will double in size and damage and burn enemeis"
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
			Name = "Itching Powder",
			Description = {
				"Taking damage will deal fake damage one second later"
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
			Name = "Jar of Manna",
			Description = {
				"{{Battery}} Must be charged by killing enemiesm spawning a Manna Orb that grants +1 charge",
				"#{{Collectible464}} Grants whatever Isaac needs the most",
				"#{{Collectible644}} If Isaac is already satisfied in health and pickups, increases Isaac's lowest stat out of Speed, Fire rate, Damage, Range, Shot speed, and Luck"
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
			Name = "Juno?",
			Description = {
				"+2 {{SoulHeart}} Soul Hearts",
				"#{{{Collectible722}} 3% chance to fire a tear that chains them in place for 2 seconds",
				"#{{Luck}} 25% chance at 11 luck"
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
			Name = "Kareth",
			Description = {
				"!!! Replaces all pedestals with 1-3 trinkets dependent on the collectible's quality",
				"#{{Quality0}}-{{Quality1}}: 1 trinket",
				"#{{Quality2}}: 2 trinkets",
				"#{{Quality3}}-{{Quality4}}: 3 trinkets"
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
			Name = "Keratoconus",
			Description = {
				"↑ {{Range}} +2 Range",
				"#↓ {{Shotspeed}} -0.15 Shot speed",
				"#Enemies far away from Isaac will appear larger in size and become closer to their regular size when getting closer",
				"#{{Slow}} Enemies are slowed depending on their distance from Isaac, farther away having a stronger effect"
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
		en_us = { --123 filigree feather
			Name = "Keys to the Kingdom",
			Description = {
				"Has different interactions depending on the room",
				"#{{Timer}} Rooms with enemies will \"spare\" them, removing them from the room and granting a random stat up per enemy for the duration of the floor",
				"#{{BossRoom}}: Rooms with bosses will begin a 30 second countdown. Afterwards, spares the boss and grants 3 stronger, permanent random stat ups compared to sparing enemies",
				"#{{Blank}} Getting hit or hurting the boss will add 10 seconds to the countdown",
				"#{{AngelRoom}}: Instantly spares angels, dropping a {{Collectible238}}{{Collectible239}} key piece, or if Isaac has them already, a random {{ItemPoolAngel}}angel room item",
				"#{{DevilRoom}}: Removes all Devil Deals from the room. Grants a random permanent for each deal removed"
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
			Name = "Alt Key",
			Description = {
				"Restarts the floor on a random variant of the alt path, or if on the alt path, a random variant of the normal path"
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
			Name = "Backspace Key",
			Description = {
				"!!! Removes 2 of your earliest passive items and sends you to the previous floor. If Isaac does not have enough passive items to sacrifice, he dies",
				"#The floor is newly generated but remains the same floor variant as when last you visited it",
				"#Subsequent uses adds 2 to the amount of passives to be removed"
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
			Name = "C Key",
			Description = {
				"{{Library}} Teleports Isaac to a Library with 5 books"
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
		_modifier = function(descObj)
			local desc = EID:getDescriptionObj(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_HUGE_GROWTH, descObj.Entity, true)
			return desc and desc.Description or "{{Card52}} Uses Huge Growth"
		end,
		en_us = {
			Name = "Caps Key",
			Description = {
				function(descObj)
					return EID_Collectibles[Item.KEY_CAPS.ID]._modifier(descObj)
				end
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
			Name = "E Key",
			Description = {
				"{{GigaBomb}} Spawns a lit Giga Bomb"
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
			Name = "Enter Key",
			Description = {
				"{{BossRushRoom}} Opens a Boss Rush door in the current room, regardless of in-game time"
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
			Name = "Esc Key",
			Description = {
				"Teleports Isaac to a random room",
				"#Heals Isaac with Red and Soul Hearts if he has less than 6 hearts"
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
			Name = "F4 Key",
			Description = {
				"Teleports you to another random special room that has not been explored yet depending on what consumables you have the least of",
				"#Coins: {{ArcadeRoom}}",
				"#Bombs: {{SuperSecretRoom}}, {{IsaacsRoom}}, {{SecretRoom}}",
				"#Keys: {{Shop}}, {{TreasureRoom}}, {{DiceRoom}}, {{Library}}, {{ChestRoom}}, {{Planetarium}}",
				"#Can teleport Isaac to any of the rooms above if all consumable counts are equal"
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
			Name = "Q Key",
			Description = {
				"Triggers the effect of the pocket item Isaac holds without using it",
				"#Max charge changes depending on the pocket item's assigned \"mimic charge\", or if an eternal item, its actual charge"
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
			Name = "Shift Key",
			Description = {
				"↑ +15 Damage",
				"#The damage up wears off over 1 minute"
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
			Name = "Spacebar Key",
			Description = {
				"{{ErrorRoom}} Teleports Isaac to the I AM ERROR room"
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
			Name = "Tab Key",
			Description = {
				"Full mapping effect",
				"#{{UltraSecretRoom}} Reveals the Ultra Secret room"
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
			Name = "Tilde Key",
			Description = {
				"{{Timer}} Activates a random debug command for the room"
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
			Name = "Leah's Heart",
			Description = {
				"↑ {{Damage}} +20% Damage",
				"#Using an active item removes the damage bonus for the floor, but grants 2 {{SoulHeart}} Soul Hearts and a {{Collectible313}} Holy Mantle shield",
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
			Name = "Leaking Tank",
			Description = {
				"{{Collectible317}} Leave a trail of damaging creep that deals 30 damage per second",
				"#Frequency of producing creep increases with each empty heart container"
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
			Name = "Liberation",
			Description = {
				"Killing enemies has a 5% chance to grant flight and open all doors in the current room"
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
			Name = "Little Raincoat",
			Description = {
				"↑ Size down",
				"#Spawns a {{Pill}} Power Pill! and adds it to the current run's pill pool",
				"#Every 6 hits, activate a Power Pill! effect",
				"#Power Pill! now deals 15 + Isaac's damage and can damage the same enemy more often the more empty heart containers he has",
				"#Killing enemies with Power Pill! has a 6% to grant +1 {{EmptyHeart}} Heart Container",
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
			Name = "Mandrake",
			Description = {
				"Allows Isaac to choose between one item and a familiar item"
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
			Name = "Miriam's Well",
			Description = {
				"Orbital",
				"#Blocks projectiles",
				"#When blocking a projectile, creates a large damaging creep that deals half of Isaac's damage. Afterwards, cannot do so again for 8 seconds"
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
			Name = "Molten Gold",
			Description = {
				"Taking damage has a 25% chance to activate a random rune"
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
			Name = "Muddled Cross",
			Description = {
				"Spawns a pool at the entrance of certain special rooms that reveal an alternate room",
				"#On use, changes the current room into the previewed room",
				"#{{TreasureRoom}} <-> {{RedTreasureRoom}}",
				"#{{UltraSecretRoom}} <-> {{Planetarium}} Planetarium items grant broken hearts",
				"#{{Shop}} <-> {{Library}} Library books cost money",
				"#{{DevilRoom}} <-> {{AngelRoom}} Angel room items cost money. Devil room items disappear after picking one up",
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
			Name = "Box of Belongings",
			Description = {
				"Spawns 2 random special cards/object and a trinket from a unique pool"
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
			Name = "Old Camera",
			Description = {
				"No effect at the moment! Sorry!"
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
			Name = "Ophiuchus?",
			Description = {
				"↑ {{Tears}} -0.4 Tear Delay",
				"#↑ {{Damage}} +0.3 Damage",
				"#Spectral tears",
				"#Isaac's tears move in waves"
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
			Name = "Owl's Eye",
			Description = {
				"8% chance to fire a homing and piercing tear that deals double damage",
				"#{{Luck}} 50% chance at 15 luck"
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
		_modifier = function(descObj, flatStone)
			local player = FR_EID:ClosestPlayerTo(descObj.Entity)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then
				return flatStone
			end
			return ""
		end,
		en_us = {
			Name = "Pallas?",
			Description = {
				"↑ {{Tearsize}}+20% Tear size",
				"#{{Collectible529}} Isaac's tears bounce off the floor after floating for a short time",
				function(descObj)
					return EID_Collectibles[Item.PALLAS.ID]._modifier(descObj,
					"#{{Collectible540}} + Flat Stone: {{Damage}} +16% damage and {{Tearsize}} x2 Tear size"
				)
				end
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
			Name = "Pallium",
			Description = {
				"{{Collectible658}} On room clear, spawns 1-3 Minisaacs",
				"#Minisaacs disappear on the next floor"
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
			Name = "Lil Poofer",
			Description = {
				"Blocks projectiles",
				"#Each projectile blocked has it grow in size",
				"#After taking 10 hits, it explodes. The explosion {{HealingRed}} Heals players in its radius for {{HalfHeart}} +1 Half Red Heart, deals 10 damage to enemies, and leaves 6 lines of damaging creep in a radial spread that deal 20 damage per second"
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
			Name = "Pharoh Cat",
			Description = {
				"A Bastet Statue in will appear in a random location in an uncleared room",
				"#Projectiles in its aura will be instantly destroyed",
				"#Statue is destroyed once the room is cleared"
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
			Name = "Pillar of Clouds",
			Description = {
				"No effect at the moment. Sorry!"
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
			Name = "Pillar of Fire",
			Description = {
				"Taking damage has a 5% chance to shoot out 5 flames from Isaac",
				"#{{Burning}} Flames will target enemies and shoot fire projectiles that inflict burn",
				"#Flames disspate after a short period of time"
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
			Name = "Plug N' Play",
			Description = {
				"{{Collectible721}} Spawns a glitched item"
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
			Name = "Polaris",
			Description = {
				"Grants stats and one of the following effects per room depending on the color of the familiar:",
				"#{{ColorRed}}Red{{CR}} = +2 Shot speed, {{Tearsize}} -50% Tear size",
				"#{{ColorOrange}}Orange{{CR}} = +1.5 Shot speed, +0.5 Damage",
				"#{{ColorYellow}}Yellow{{CR}} = +1 Shot speed, +1 damage, 50% chance for a heart to spawn upon room clear",
				"#White = +0.5 Shot speed, +1.5 Damage, 10% chance for {{Collectible374}} holy light tears. {{Luck}} 50% chance at 9 luck",
				"#{{ColorBlue}}Blue{{CR}} = +2 Damage, {{Tearsize}} +100% Tear size, tears inflict {{Burning}}Burning",
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
	[Item.POLARITY_SHIFT.ID_1] = {
		en_us = {
			Name = "Polarity Shift",
			Description = {
				"Changes Spiritual Wound to Chain Lightning",
				"#Can only be activated while you have {{Heart}} Red Hearts",
				"#While active:",
				"#{{Blank}} Life steal is disabled, instead rapidly draining {{Heart}} Red Hearts.",
				"#{{Blank}} Less delay between damaging enemies"
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
	[Item.POLYDIPSIA.ID] = {
		en_us = {
			Name = "Polydipsia",
			Description = {
				"↓ {{Tears}} x0.5 Tears multiplier",
				"#↓ {{Tears}} +8 Tear delay",
				"#Isaac's tears are shot in an arc",
				"#Isaac's tears leave creep, its size scaling with the size of the tear",
				"#{{Damage}} The creep deals 66% of Isaac's damage per second and inherits his tear effects"
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
			Name = "Prayer Journal",
			Description = {
				"{{BlackHeart}} 50% chance to grant a Black Heart",
				"#{{SoulHeart}} 40% chance to grant a Soul Heart",
				"#{{BrokenHeart}} 10% chance to grant a Broken Heart"
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
			Name = "Quarantine",
			Description = {
				"{{Fear}} Entering an uncleared room fears all enemies for 6 seconds",
				"#{{Poison}} Getting close to enemies during this period poisons them for 2x Isaac's damage"
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
			Name = "Rotten Apple",
			Description = {
				"↑ {{Damage}} +2 Damage",
				"#Permanently grants a random worm trinket effect"
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
			Name = "Coffee Break",
			Description = {
				"↑ {{Heart}} +1 Health",
				"#↑ {{SoulHeart}} +1 Soul Heart",
				"#{{HealingRed}} Heals 2 hearts",
				"#↑ {{Speed}} +0.2 Speed"
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
			Name = "Rue",
			Description = {
				"{{Collectible118}} Taking damage fires a Brimstone laser as the nearest enemy"
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
			Name = "Secret Diary",
			Description = {
				"{{Timer}} Receive a {{Collectible619}}Birthright effect for the room"
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
			Name = "Servitude",
			Description = {
				"Using with a pedestal nearby will note the item down. Does not discharge and can no longer be recharged normally",
				"#Clearing a room reduces charges instead of gaining",
				"#Reaching 0 charge without taking damage spawns a copy of the item it noted",
				"#!!! Taking damage while the item has charge will discharge it, forgets the noted item, and grants {{BrokenHeart}} +1 Broken Heart",
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
			Name = "Severed Ear",
			Description = {
				"↑ {{Damage}} +20% Damage",
				"#↑ {{Range}} +1.2 Range",
				"#↓ {{Tears}} +20% Tear delay",
				"#↓ {{Shotspeed}} -0.6 Shot speed",
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
			Name = "Shattered Heart",
			Description = {
				"Explodes all hearts in the room, dealing damage based on the heart and leaves damaging creep"
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
			Name = "Spiritual Wound",
			Description = {
				"Funny aaa star wars"
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
			Name = "Sunscreen",
			Description = {
				"Immunity to fire"
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
			Name = "Tambourine",
			Description = {
				"Inflicts extreme knockback to enemies in a small radius around Isaac",
				"#Spawns a giant damaging blue creep for one second"
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
			Name = "Technology -1",
			Description = {
				"Tears have a 3.14% chance to fire 3 lasers in random directions"
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
			Name = "Tech IX",
			Description = {
				"↓ +5 Tear delay",
				"#{{Collectible395}} Isaac's tears are replaced with small green piercing and spectral technology rings"
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
			Name = "The Driedel",
			Description = {
				"Reduces 1-4 random stats and spawns 1 random item from the current room's item pool",
				"#Quality of the spawned item will depend on the amount of stats lowered"
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
			Name = "Trepanation",
			Description = {
				"{{Collectible531}} Fire a Haemolacria-like shot every 15 tears"
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
			Name = "Unstable Core",
			Description = {
				"{{Burning}} Using an active item burns enemies in a small radius around Isaac",
				"#Burn lasts longer the more charges the active item has"
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
			Name = "Vesta?",
			Description = {
				"↑ {{Damage}} +50% Damage",
				"#↓ {{Tearsize}} Permanent micro-sized tears",
				"#Spectral tears",
				"#{{Collectible224}} 10% chance for tears to split into 4",
				"#{{Luck}} 100% chance at 10 luck"
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
			Name = "Wine Bottle",
			Description = {
				"Fires a high-velocity cork every 15 tears",
				"#Cork deals double damage and is 50% larger"
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
			Name = "ZZZZoptionsZZZZ",
			Description = {
				"{{Collectible721}} Allows Isaac to choose between one item and a glitched item"
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

EID_Collectibles[Item.POLARITY_SHIFT.ID_2] = EID_Collectibles[Item.POLARITY_SHIFT.ID_1]

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
			Name = "Abyssal Penny",
			Description = {
				"Picking up a coin spawns a damaging creep, dealing 40 damage per second",
				"#Creep size and duration scales with the value of the coin"
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
			Name = "Alabaster Scrap",
			Description = {
				"↑ {{Damage}} +0.5 Damage for every item that counts towards the {{Seraphim}} Seraphim transformation",
				"#Trinket does not grant progress to the transformation but is marked as such, granting +0.5 Damage by default"
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
			Name = "Almagest Scrap",
			Description = {
				"{{Planetarium}} Treasure Rooms are replaced with Planetariums",
				"#{{BrokenHeart}} Items inside grant broken hearts"
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
			Name = "Altruism",
			Description = {
				"25% chance to heal Isaac for a {{HalfHeart}} Half Red Heart or refund the price Isaac paid to a beggar"
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
			Name = "BI-84",
			Description = {
				"{{Collectible68}} 25% chance to grant a random Technology-related item for the room"
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
			Name = "Cringe",
			Description = {
				"{{Petrify}} Taking damage petrifies all enemies in the room for 1 second",
				"#Replaces Isaac's hurt sounds with the \"Bruh\" sound effect"
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
			Name = "Dungeon Key",
			Description = {
				"Opens Challenge Room doors regardless of Isaac's health"
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
			Name = "Escape Plan",
			Description = {
				"Taking damage has a 10% chance to teleport Isaac to the starting room"
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
			Name = "Glitched Penny",
			Description = {
				"Picking up a coin has a 25% chance to use a random active item",
				"#{{Battery}} Only uses actives found in the {{TreasureRoom}} Treasure Room pool that have at least 1 charge"
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
			Name = "Grass",
			Description = {
				"Replaces all prop decorations with grass",
				"#Walking over grass grants a {{Speed}} +0.05 Speed up for the room"
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
			Name = "Hammerhead Worm",
			Description = {
				"Isaac's tears are slightly randomized in damage, range, and shotspeed"
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
			Name = "Holy Heart",
			Description = {
				"Picking up specific hearts have a chance to grant a {{Collectible313}} Holy Mantle shield depending on the type of heart",
				"#{{HalfSoulHeart}}: 5% chance",
				"#{{SoulHeart}}: 10% chance",
				"#{{BlackHeart}}: 10% chance",
				"#{{EternalHeart}}: 50% chance"
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
			Name = "Leah's Lock",
			Description = {
				"25% chance to fire {{Charm}} Charm or {{Fear}} Fear tears",
				"#Not affected by luck"
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
		_modifier = function(descObj, desc)
			local player = FR_EID:ClosestPlayerTo(descObj.Entity)
			if player:HasPlayerForm(PlayerForm.PLAYERFORM_EVIL_ANGEL) then
				return desc
			end
			return ""
		end,
		en_us = {
			Name = "Leviathan's Tendril",
			Description = {
				"25% chance to deflect projectiles away from Isaac, gaining homing and increased velocity",
				"#{{Fear}} 5% chance to inflict fear when near enemies",
				function(descObj)
					return EID_Trinkets[Trinket.LEVIATHANS_TENDRIL.ID]._modifier(descObj,
						"#{{Leviathan}} Additional +5% chance to each effect"
					)
				end
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
			Name = "Nil Num",
			Description = {
				"2% chance to get destroyed and spawn a duplicate of one of Isaac's passive items in his inventory when hit"
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
			Name = "Parasol",
			Description = {
				"All of Isaac's familiars block projectiles"
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
			Name = "Rebound Worm",
			Description = {
				"Tears ricochet off of walls and grid entities, firing at the closest enemy in range"
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
			Name = "Saline Spray",
			Description = {
				"{{Collectible596}} Chance to shoot freezing tears"
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
			Name = "Wormwood Leaf",
			Description = {
				"10% chance to negate damage and turn Isaac into an invulnerable immobile statue for 2 seconds",
				"#Grants Isaac a half second of invulnerability afterwards"
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
			Name = "Ace of Shields",
			Description = {
				"{{Battery}} Turns all pickups, chests and non-boss enemies into Micro Batteries"
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
			Name = "XXIV - Charity",
			Description = {
				"{{Collectible" .. Mod.Item.JAR_OF_MANNA.ID .. "}} Triggers 3 free uses of Jar of Manna"
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
			Name = "XXV - Faith",
			Description = {
				"{{Confessional}} Spawns a Confessional"
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
			Name = "Golden Card",
			Description = {
				"Random card effect",
				"#50% chance to destroy itself with each use"
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
			Name = "XXIII - Hope",
			Description = {
				"For the duration of the room, enemies have a 20% chance to drop a random pickup upon death",
				"#Dropped pickups cannot be collectibles, chests, or trinkets"
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
			Name = "Key Card",
			Description = {
				"{{LadderRoom}} Spawns a crawlspace"
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
			Name = "XXIV - Charity?",
			Description = {
				"Duplicates all pickups in the room and turns them into shop items"
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
			Name = "XXV - Faith?",
			Description = {
				"Spawns 2 {{MoonHeart}} Moon Hearts"
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
			Name = "XXIII - Hope?",
			Description = {
				"Teleports Isaac to an extra Challenge room"
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
			Name = "Trap Card",
			Description = {
				"{{Chained}} Chains down the nearest enemy"
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
			Name = "Two of Shields",
			Description = {
				"{{Battery}} Doubles Isaac's active item charges",
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
			Name = "Essence of Death",
			Description = {
				"{{Collectible693}} Kills all non-boss enemies in the room and spawns a Swarm fly orbital for each one"
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
			Name = "Essence of Deluge",
			Description = {
				"Spawns 15 drain drops over each enemy over the course of 5 seconds",
				"#{{Slow}} Rain drops slow enemies and damage them for 66% of Isaac's damage"
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
			Name = "Essence of Drought",
			Description = {
				"{{BleedingOut}} Inflicts permanent bleeding on all non-boss enemies in the room. Bosses instead bleed for 5 seconds",
				"#{{Freezing}} Enemies will become frozen statues upon death"
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
			Name = "Essence of Hate",
			Description = {
				"{{Collectible" .. Item.SHATTERED_HEART.ID .. "}}",
				"Spawns 6 {{Heart}} Red Hearts that explode shortly after spawning",
				"#These hearts cannot be collected"
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
			Name = "Essence of Life",
			Description = {
				"{{Collectible658}} Spawns 1 Minisaac for each enemy in the room"
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
			Name = "Essence of Love",
			Description = {
				"{{Friendly}} Turns all non-boss enemies into permanent friendly companions"
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
	--TODO: Modifier for keeper to only grant 1 Coin Heart
	[Mod.Rune.SOUL_OF_LEAH.ID] = {
		_metadata = { 6, true },
		en_us = {
			Name = "Soul of Leah",
			Description = {
				"↑ The max amount of heart containers is increased by 3",
				"#↓ {{BrokenHeart}} +3 Broken Hearts",
				"#!!! Cannot increase max heart containers past 24, but still grants Broken Hearts"
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
			Name = "Soul of Miriam",
			Description = {
				"Starts raining in the room and fills the room with water",
				"#A damaging creep will slowly and infinitely grow from the center of the room",
				"#Lasts 40 seconds between rooms and floors"
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
			Name = "Soul of Peter",
			Description = {
				"Adds 5 rooms randomly on the map",
				"#Rooms can either be a default room or a 10% chance of being a random special room",
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
			Name = "Heartache Up",
			Description = {
				"↓ {{BrokenHeart}} +1 Broken Heart"
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
			Name = "Heartache Down",
			Description = {
				"↑ {{BrokenHeart}} -1 Broken Heart"
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

local EID_Entities
EID_Entities = {
	[EntityType.ENTITY_PICKUP] = {
		[PickupVariant.PICKUP_BOMB] = {
			[Mod.Pickup.CHARGED_BOMB.ID] = {
				en_us = {
					Name = "Charged Bomb",
					Description = {
						"{{Bomb}} +1 Bomb",
						"#{{Battery}} Fully recharges one of Isaac's active items",
						"#!!! 1% chance to explode if Isaac has more than a half heart of health"
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
					Name = "Golden Sack",
					Description = {
						"80% chance to spawn another Golden Sack somewhere in the room upon pickup"
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
				---@param descObj EID_DescObj
				---@param noLuna string
				---@param hasLuna string
				_modifier = function(descObj, noLuna, hasLuna)
					local player = FR_EID:ClosestPlayerTo(descObj.Entity)
					if player:HasCollectible(CollectibleType.COLLECTIBLE_LUNA) then
						return hasLuna
					else
						return noLuna
					end
				end,

				en_us = {
					Name = "{{MoonHeart}} Moon Heart",
					Description = {
						"{{SoulHeart}} Functions like a Soul Heart",
						"#{{SecretRoom}} Secret and Super Secret Rooms will contain a {{Collectible589}} Luna beam",
						function(descObj)
							return EID_Entities[5][10][Mod.Pickup.MOON_HEART.ID]._modifier(descObj,
								"#The number of Luna beams available is dependent on the amount of Moon Hearts available across all players (e.g. 1 Moon Heart = Can only find 1 beam on the floor)",
								"#{{Collectible589}} Grants an additional {{Tears}} +0.5 Fire rate for every Moon Heart Isaac has when interacting with a Luna beam"
							)
						end
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
					Name = "Unlucky Penny",
					Description = {
						"↓ {{Luck}} -1 Luck",
						"#↑ {{Damage}} +0.5 Damage"
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
		[Mod.Slot.LOVE_TELLER.ID] = {
			[0] = {
				_modifier = function(charList)
					local renderedPlayerTypes = {}
					local desc = "#"
					for _, player in ipairs(EID.coopAllPlayers) do
						local playerType = player:GetPlayerType()
						local iconPlayerType = playerType
						local parentType = Mod.Slot.LOVE_TELLER.ParentPlayerTypes[playerType]
						if parentType then
							playerType = parentType
						end
						if not renderedPlayerTypes[playerType] then
							local icon = EID:GetPlayerIcon(iconPlayerType)
							local lover = Mod.Slot.LOVE_TELLER:GetMatchMaker(playerType, 2)
							local loverIcon = EID:GetPlayerIcon(lover)
							desc = desc .. icon .. " {{Heart}}" .. loverIcon .. " - " .. charList[lover] .. "#"
							renderedPlayerTypes[playerType] = true
						end
					end
					desc = string.sub(desc, 1, -2)
					return desc
				end,
				en_us = {
					Name = "Love Teller",
					Description = {
						"{{Coin}} Costs 5 coins to use",
						"#Randomly pairs Isaac with another character. Grants a reward depending on the matchup",
						"#{{EmptyHeart}} Spawns a fly",
						"#{{HalfHeart}} Spawns two heart pickups",
						"#{{Heart}} Spawns a unique shooter familiar related to the selected character",
						function(descObj)
							return EID_Entities[EntityType.ENTITY_SLOT][Mod.Slot.LOVE_TELLER.ID][0]._modifier({
								[PlayerType.PLAYER_ISAAC] = "Occasionally temporarily grants {{Collectible206}} Guillotine",
								[PlayerType.PLAYER_MAGDALENE] = "Occasionally activates {{Collectible45}} Yum Heart",
								[PlayerType.PLAYER_CAIN] = "Occasionally refunds keys used on chests",
								[PlayerType.PLAYER_JUDAS] = "Occasionally activates {{Collectible34}} Book of Belial",
								[PlayerType.PLAYER_BLUEBABY] = "Occasionally temporarily grants {{Collectible248}} Hive Mind",
								[PlayerType.PLAYER_EVE] = "Occasionally temporarily grants the {{Collectible122}} Whore of Babylon effect",
								[PlayerType.PLAYER_SAMSON] = "Occasionally temporarily grants {{Collectible157}} Blood Lust with +3 hits",
								[PlayerType.PLAYER_AZAZEL] = "Occasionally temporarily grants the {{Trinket162}} Azazel's Stump effect",
								[PlayerType.PLAYER_LAZARUS] = "Occasionally temporarily grants the {{Collectible214}} Anemic effect",
								[PlayerType.PLAYER_EDEN] = "Becomes a random Love Teller baby. After activating its effect, will become another random Love Teller baby",
								[PlayerType.PLAYER_THELOST] = "Occasionally temporarily grants a {{Collectible313}} mantle shield. Cannot grant another until the shield breaks",
								[PlayerType.PLAYER_LILITH] = "Occasionally activates {{Collectible357}} Box of Friends",
								[PlayerType.PLAYER_KEEPER] = "Occasionally temporarily grants {{Collectible450}} Eye of Greed",
								[PlayerType.PLAYER_APOLLYON] = "Occasionally spawns a random locust",
								[PlayerType.PLAYER_THEFORGOTTEN] = "Occasionally swaps between bone and soul form, each shooting different tears",
								[PlayerType.PLAYER_BETHANY] = "Occasionally temporarily grants {{Collectible584}} Book of Virtues",
								[PlayerType.PLAYER_JACOB] = "Occasionally activates {{Collectible687}} Friend Finder",
								[PlayerType.PLAYER_ESAU] = "Occasionally temporarily grants a small {{Collectible621}} Red Stew effect",
								[Mod.PlayerType.LEAH] = "Occasionally activates {{Collectible" .. Item.HEART_RENOVATOR.ID .. "}} Heart Renovator",
								[Mod.PlayerType.PETER] = "Occasionally activates {{Collectible" .. Item.KEYS_TO_THE_KINGDOM.ID .. "}} Keys to the Kingdom on a single non-boss target",
								[Mod.PlayerType.MIRIAM] = "Occasionally activates {{Collectible" .. Item.TAMBOURINE.ID .. "}} Tambourine",
							})
						end
					}
				}
			}
		},
		[Mod.Slot.ESCORT_BEGGAR.ID] = {
			[0] = {
				_modifier = function()

				end,
				en_us = {
					Name = "Escort Beggar",
					Description = {
						"PlaceholderDesc"
					}
				}
			}
		},
	},
}

for id, variantDescData in pairs(EID_Entities) do
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
					EID:addEntity(id, variant, subtype, name, table.concat(minimized, ""), language)
				else
					EID:addEntity(id, variant, subtype, "", name, language) -- description only contains name/language, the actual description is generated at runtime
					DD:SetCallback(DD:CreateCallback(minimized, entityDescData._AppendToEnd), id, variant, subtype, language)
				end

				::continue::
			end
		end
	end
end

local EID_Characters
EID_Characters = {
	[Mod.PlayerType.LEAH] = {
		en_us = {
			Name = "Leah",
			Description = {
				"{{Tears}} +0.2 Tears for every {{BrokenHeart}} Broken Heart"
			}
		}
	},
	[Mod.PlayerType.PETER] = {
		en_us = {
			Name = "Peter",
			Description = {
				"{{Battery}} {{SoulHeart}} Soul/Black Hearts will instead charge {{Collectible" .. Mod.Item.KEYS_TO_THE_KINGDOM.ID .. "}} Keys to the Kingdom instead of your health if still needs charges"
			}
		}
	},
	[Mod.PlayerType.MIRIAM] = {
		en_us = {
			Name = "Miriam",
			Description = {
				"Every 12 tears, a whirlpool will spawn where the tear landed. It sucks enemies into it in a spiral motion, dealing constant damage",
				"#Whirlpool lasts 2 seconds"
			}
		}
	},
	[Mod.PlayerType.LEAH_B] = {
		en_us = {
			Name = "Tainted Leah",
			Description = {
				"{{EmptyHeart}} Maximum of 24 heart containers",
				"#{{BrokenHeart}} Health above one heart will be slowly be replaced with Broken Hearts, 1 every 20 seconds",
				"#{{Heart}} Damaging enemies may have them drop a special Scared Heart. It disappears after 10 seconds and be collected by enemies, damaging them",
				"#↑ All stats up for every Half Red Heart you have",
				"#{{SoulHeart}} Soul/Black Hearts are replaced with Red Hearts"
			}
		}
	},
	[Mod.PlayerType.PETER_B] = {
		en_us = {
			Name = "Tainted Peter",
			Description = {
				"Permanent water rooms",
				"#Peter and non-boss enemies exist separately between the water",
				"#Walking below an enemy will submerge them. They gain {{StrengthStatus}} Strength and take 25% less damage",
				"#{{Collectible" .. Mod.Item.MUDDLED_CROSS.ID .. "}} On use: Enemies and players swap sides for X * 5 seconds, where X is 1 + number of submerged enemies",
				"#While room is flipped: Cannot recharge Muddled Cross, cannot interact with enemies. {{Weakness}} Weakness instead of Strength"
			}
		}
	},
	[Mod.PlayerType.MIRIAM_B] = {
		en_us = {
			Name = "Tainted Miriam",
			Description = {
				"{{BoneHeart}} Heart containers converted to Bone Hearts",
				"#{{SoulHeart}} Can't use Soul Hearts as health",
				"#{{Collectible" .. Mod.Item.SPIRITUAL_WOUND.ID .. "}} Spiritual Wound: Rapidly fire a wide arc of short homing lasers. Has a small delay to how often it damages an enemy",
				"#{{Fear}} Fear aura that increases in size with {{Heart}} Red Hearts",
				"#{{HealingRed}} Heal a Half Red Heart after dealing enough damage",
			}
		}
	},
}

local EID_Birthrights
EID_Birthrights = {
	[Mod.PlayerType.LEAH] = {
		en_us = {
			Name = "Leah",
			Description = {
				"{{ArrowUp}} {{Damage}} Damage bonus from {{Collectible" .. Item.HEART_RENOVATOR.ID .. "}} is doubled",
				"Killing 20 enemies activates a normal damage bonus Heart Renovator effect"
			}
		}
	},
	[Mod.PlayerType.PETER] = {
		en_us = {
			Name = "Peter",
			Description = {
				"Time to spare bosses reduced from 30 seconds to 15 seconds"
			}
		}
	},
	[Mod.PlayerType.MIRIAM] = {
		en_us = {
			Name = "Miriam",
			Description = {
				"Increased knockback",
				"#Whirlpools spawn every 8 tears",
				"#Increased tear knockback"
			}
		}
	},
	[Mod.PlayerType.LEAH_B] = {
		en_us = {
			Name = "Tainted Leah",
			Description = {
				"20% chance to upgrade any spawned {{Heart}} Red Hearts",
				"#Enemies that collide with the specially dropped Scared Hearts will have it also act like it was collected by Isaac",
				"#{{Collectible" .. Item.SHATTERED_HEART.ID .. "}} double damage of exploded hearts"
			}
		}
	},
	[Mod.PlayerType.PETER_B] = {
		en_us = {
			Name = "Tainted Peter",
			Description = {
				"Provides bonuses to specially flipped rooms",
				"#{{TreasureRoom}} {{RedTreasureRoom}} : Allows two items to choose from",
				"#{{Planetarium}} : Planetarium items no longer grant broken hearts",
				"#{{Library}} : Library books no longer cost money",
				"#{{Shop}} : {{Player33}} Tainted Keeper-style shops",
				"#{{DevilRoom}} : One item can be taken for free without removing the others",
				"#{{AngelRoom}} : {{Collectible64}} Steam Sale effect",
			}
		}
	},
	[Mod.PlayerType.MIRIAM_B] = {
		en_us = {
			Name = "Tainted Miriam",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
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
