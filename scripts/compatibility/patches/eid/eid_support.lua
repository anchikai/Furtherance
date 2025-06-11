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

local EID_Collectibles = Mod.Include("scripts.compatibility.patches.eid.eid_items_descriptions")

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

local EID_Trinkets = Mod.Include("scripts.compatibility.patches.eid.eid_trinkets_descriptions")

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

local EID_Cards = Mod.Include("scripts.compatibility.patches.eid.eid_cards_descriptions")

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
								[PlayerType.PLAYER_ISAAC] =
								"Occasionally temporarily grants {{Collectible206}} Guillotine",
								[PlayerType.PLAYER_MAGDALENE] = "Occasionally activates {{Collectible45}} Yum Heart",
								[PlayerType.PLAYER_CAIN] = "Occasionally refunds keys used on chests",
								[PlayerType.PLAYER_JUDAS] = "Occasionally activates {{Collectible34}} Book of Belial",
								[PlayerType.PLAYER_BLUEBABY] =
								"Occasionally temporarily grants {{Collectible248}} Hive Mind",
								[PlayerType.PLAYER_EVE] =
								"Occasionally temporarily grants the {{Collectible122}} Whore of Babylon effect",
								[PlayerType.PLAYER_SAMSON] =
								"Occasionally temporarily grants {{Collectible157}} Blood Lust with +3 hits",
								[PlayerType.PLAYER_AZAZEL] =
								"Occasionally temporarily grants the {{Trinket162}} Azazel's Stump effect",
								[PlayerType.PLAYER_LAZARUS] =
								"Occasionally temporarily grants the {{Collectible214}} Anemic effect",
								[PlayerType.PLAYER_EDEN] =
								"Becomes a random Love Teller baby. After activating its effect, will become another random Love Teller baby",
								[PlayerType.PLAYER_THELOST] =
								"Occasionally temporarily grants a {{Collectible313}} mantle shield. Cannot grant another until the shield breaks",
								[PlayerType.PLAYER_LILITH] = "Occasionally activates {{Collectible357}} Box of Friends",
								[PlayerType.PLAYER_KEEPER] =
								"Occasionally temporarily grants {{Collectible450}} Eye of Greed",
								[PlayerType.PLAYER_APOLLYON] = "Occasionally spawns a random locust",
								[PlayerType.PLAYER_THEFORGOTTEN] =
								"Occasionally swaps between bone and soul form, each shooting different tears",
								[PlayerType.PLAYER_BETHANY] =
								"Occasionally temporarily grants {{Collectible584}} Book of Virtues",
								[PlayerType.PLAYER_JACOB] = "Occasionally activates {{Collectible687}} Friend Finder",
								[PlayerType.PLAYER_ESAU] =
								"Occasionally temporarily grants a small {{Collectible621}} Red Stew effect",
								[Mod.PlayerType.LEAH] = "Occasionally activates {{Collectible" ..
								Item.HEART_RENOVATOR.ID .. "}} Heart Renovator",
								[Mod.PlayerType.PETER] = "Occasionally activates {{Collectible" ..
								Item.KEYS_TO_THE_KINGDOM.ID .. "}} Keys to the Kingdom on a single non-boss target",
								[Mod.PlayerType.MIRIAM] = "Occasionally activates {{Collectible" ..
								Item.TAMBOURINE.ID .. "}} Tambourine",
							})
						end
					}
				}
			}
		},
		[Mod.Slot.ESCORT_BEGGAR.SLOT] = {
			[0] = {
				en_us = {
					Name = "Escort Beggar",
					Description = {
						"Can be picked up and carried to the requested special room on the floor for a reward from their {{ItemPoolEscortBeggar}} Item Pool",
						"#{{Throwable}} Throw against enemies to knock them back for 5 damage",
						"#!!! Can take damage and will die after 3 hits",
						"#!!! Will be abducted if left in a previous room for too long"
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
					DD:SetCallback(DD:CreateCallback(minimized, entityDescData._AppendToEnd), id, variant, subtype,
						language)
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
				"{{Battery}} {{SoulHeart}} Soul/Black Hearts will instead charge {{Collectible" ..
				Mod.Item.KEYS_TO_THE_KINGDOM.ID ..
				"}} Keys to the Kingdom instead of Peter's health if it still needs charges"
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
				"#↑ All stats up for every Half Red Heart Leah has",
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
				"#{{Collectible" ..
				Mod.Item.MUDDLED_CROSS.ID ..
				"}} On use: Enemies and players swap sides for X * 5 seconds, where X is 1 + number of submerged enemies",
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
				"#Spiritual Wound: Rapidly fire a wide arc of short homing lasers. Has a small delay to how often it damages an enemy",
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
				"#Killing 20 enemies activates a normal damage bonus Heart Renovator effect"
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
				"Spiritual Wound becomes Death Field",
				"#Damage cooldown from Death Field is as fast as Chain Lightning",
				"#Chain Lightning deals {{Damage}} x1.5 Damage to enemies inflicted with {{Fear}} Fear",
				"#Health drains at half the rate while Chain Lightning is active"
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
