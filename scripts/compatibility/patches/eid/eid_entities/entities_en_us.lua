local Mod = Furtherance

return function(modifiers)
	return {
		[EntityType.ENTITY_PICKUP] = {
			[PickupVariant.PICKUP_BOMB] = {
				[Mod.Pickup.CHARGED_BOMB.ID] = {
					Name = "Charged Bomb",
					Description = {
						"{{Bomb}} +1 Bomb",
						"#{{Battery}} Fully recharges one of Isaac's active items",
						"#!!! 1% chance to explode if Isaac has more than a half heart of health"
					}
				},
			},
			[PickupVariant.PICKUP_GRAB_BAG] = {
				[Mod.Pickup.GOLDEN_SACK.ID] = {
					Name = "Golden Sack",
					Description = {
						"80% chance to spawn another Golden Sack somewhere in the room upon pickup"
					}
				},
			},
			[PickupVariant.PICKUP_HEART] = {
				[Mod.Pickup.MOON_HEART.ID] = {
					Name = "Moon Heart {{MoonHeart}}",
					Description = {
						"{{SoulHeart}} Functions like a Soul Heart",
						"#{{SecretRoom}} For each Moon Heart any player has, a Secret and Super Secret Room will contain a {{Collectible589}} Luna light beam",
						"#The first light gives Isaac +1 Fire rate, and all subsequent ones give +0.5 Fire rate",
						"#Reveals the Secret or Super Secret room once depleted",
						function(descObj)
							return modifiers[5][10][Mod.Pickup.MOON_HEART.ID]._modifier(descObj,
								"#{{Collectible589}} Grants an additional {{Tears}} +0.5 Fire rate for every Moon Heart Isaac has when interacting with a Luna beam"
							)
						end,
					}
				},
			},
			[PickupVariant.PICKUP_COIN] = {
				[Mod.Pickup.UNLUCKY_PENNY.ID] = {
					Name = "Unlucky Penny",
					Description = {
						"↓ {{Luck}} -1 Luck",
						"#↑ {{Damage}} +0.5 Damage"
					}
				},
			},
		},
		[EntityType.ENTITY_SLOT] = {
			[Mod.Slot.LOVE_TELLER.ID] = {
				[0] = {
					Name = "Love Teller",
					Description = {
						"{{Coin}} Costs 5 coins to use",
						"#Randomly pairs the character who used the machine with another character. Grants a reward depending on the matchup",
						"#{{EmptyHeart}} Spawns a fly",
						"#{{HalfHeart}} Spawns two heart pickups",
						"#{{Heart}} Spawns a unique shooter familiar related to the character's \"true love\"",
						function(descObj)
							return modifiers[EntityType.ENTITY_SLOT][Mod.Slot.LOVE_TELLER.ID][0]._modifier({
								[PlayerType.PLAYER_ISAAC] = "Occasionally briefly grants {{Collectible206}} Guillotine",
								[PlayerType.PLAYER_MAGDALENE] = "Occasionally activates {{Collectible45}} Yum Heart",
								[PlayerType.PLAYER_CAIN] = "Occasionally refunds keys used on chests",
								[PlayerType.PLAYER_JUDAS] = "Occasionally activates {{Collectible34}} Book of Belial",
								[PlayerType.PLAYER_BLUEBABY] = "Occasionally briefly grants {{Collectible248}} Hive Mind",
								[PlayerType.PLAYER_EVE] = "Occasionally briefly grants the {{Collectible122}} Whore of Babylon effect",
								[PlayerType.PLAYER_SAMSON] = "Occasionally briefly grants {{Collectible157}} Blood Lust with +3 hits",
								[PlayerType.PLAYER_AZAZEL] = "Occasionally briefly grants the {{Trinket162}} Azazel's Stump effect",
								[PlayerType.PLAYER_LAZARUS] = "Occasionally briefly grants the {{Collectible214}} Anemic effect",
								[PlayerType.PLAYER_EDEN] = "Becomes a random Love Teller baby. After activating its effect, will become another random Love Teller baby",
								[PlayerType.PLAYER_THELOST] = "Occasionally briefly grants a {{Collectible313}} mantle shield. Cannot grant another until the shield breaks",
								[PlayerType.PLAYER_LILITH] = "Occasionally activates {{Collectible357}} Box of Friends",
								[PlayerType.PLAYER_KEEPER] = "Occasionally briefly grants {{Collectible450}} Eye of Greed",
								[PlayerType.PLAYER_APOLLYON] = "Occasionally spawns a random locust",
								[PlayerType.PLAYER_THEFORGOTTEN] = "Occasionally swaps between bone and soul form, each shooting different tears",
								[PlayerType.PLAYER_BETHANY] = "Occasionally briefly grants {{Collectible584}} Book of Virtues",
								[PlayerType.PLAYER_JACOB] = "Occasionally activates {{Collectible687}} Friend Finder",
								[PlayerType.PLAYER_ESAU] = "Occasionally briefly grants a small {{Collectible621}} Red Stew effect",
								[Mod.PlayerType.LEAH] = "Occasionally activates {{Collectible" .. Mod.Item.HEART_RENOVATOR.ID .. "}} Heart Renovator",
								[Mod.PlayerType.PETER] = "Occasionally activates {{Collectible" .. Mod.Item.KEYS_TO_THE_KINGDOM.ID .. "}} Keys to the Kingdom on a single non-boss target",
								[Mod.PlayerType.MIRIAM] = "Occasionally activates {{Collectible" .. Mod.Item.TAMBOURINE.ID .. "}} Tambourine",
							})
						end
					}
				}
			},
			[Mod.Slot.ESCORT_BEGGAR.SLOT] = {
				[0] = {
					Name = "Escort Beggar",
					Description = {
						"Can be picked up and carried to the requested special room on the floor for a reward from their {{ItemPoolEscortBeggar}} Item Pool",
						"#{{Throwable}} Throw against enemies to knock them back for 5 damage",
						"#!!! Can take damage and will die after 3 hits",
						"#!!! Will be abducted if left in a previous room for too long"
					}
				}
			},
		},
	}
end