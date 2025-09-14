local Mod = Furtherance
local Trinket = Mod.Trinket

return function(modifiers)
	return {
		[Trinket.ABYSSAL_PENNY.ID] = {
			Name = "Abyssal Penny",
			Description = {
				"Picking up a coin spawns a damaging creep, dealing 40 damage per second",
				"#Creep size and duration scales with the value of the coin"
			}
		},
		[Trinket.ALABASTER_SCRAP.ID] = {
			Name = "Alabaster Scrap",
			Description = {
				"↑ {{Damage}} +0.5 Damage for every item that counts towards the {{Seraphim}} Seraphim transformation"
			}
		},
		[Trinket.ALMAGEST_SCRAP.ID] = {
			Name = "Almagest Scrap",
			Description = {
				"{{Planetarium}} Treasure Rooms are replaced with Planetariums",
				function(descObj)
					return modifiers[Trinket.ALMAGEST_SCRAP.ID]._modifier(descObj,
						"{{BrokenHeart}} Items inside grant broken hearts",
						"{{BrokenHeart}} Items inside grant 1 broken heart",
						"Items inside are free"
					)
				end
			}
		},
		[Trinket.ALTRUISM.ID] = {
			Name = "Altruism",
			Description = {
				"Donating to any kind of beggar has a 25% chance to either heal Isaac for a {{HalfHeart}} Half Red Heart or refund the price Isaac paid to a beggar"
			}
		},
		[Trinket.BI_84.ID] = {
			Name = "BI-84",
			Description = {
				"{{Collectible68}} 25% chance to grant a random Technology-related item for the room"
			}
		},
		[Trinket.CRINGE.ID] = {
			Name = "Cringe",
			Description = {
				"{{Petrify}} Taking damage petrifies all enemies in the room for 2 seconds",
				"#Replaces Isaac's hurt sounds with the \"Bruh\" sound effect"
			}
		},
		[Trinket.DUNGEON_KEY.ID] = {
			Name = "Dungeon Key",
			Description = {
				"Opens Challenge Room doors regardless of Isaac's health",
				function(descObj)
					return Mod.EID_Support:TrinketMultiGoldStr(descObj,
						"Door will stay open while ambush is active",
						false, true
					) .. Mod.EID_Support:TrinketMultiGoldStr(descObj,
						"Boss Room doors will stay open",
						false, true
					)
				end,
				function(descObj)
					return Mod.EID_Support:TrinketMultiGoldStr(descObj,
						"Upon clearing a Challenge Room, opens all doors and creates red rooms on every door if possible",
						3, true, "{{Card83}}"
					)
				end
			}
		},
		[Trinket.ESCAPE_PLAN.ID] = {
			Name = "Escape Plan",
			Description = {
				"Taking damage has a 10% chance to teleport Isaac to the starting room"
			}
		},
		[Trinket.GLITCHED_PENNY.ID] = {
			Name = "Glitched Penny",
			Description = {
				"Picking up a coin has a 25% chance to use a random active item",
				"#{{Battery}} Only uses actives found in the {{TreasureRoom}} Treasure Room pool that have at least 1 charge"
			}
		},
		[Trinket.GRASS.ID] = {
			Name = "Grass",
			Description = {
				"Replaces all prop decorations with grass",
				"#Walking over grass grants a {{Speed}} +0.05 Speed up for the room"
			}
		},
		[Trinket.HAMMERHEAD_WORM.ID] = {
			Name = "Hammerhead Worm",
			Description = {
				"Isaac's tears are slightly randomized in damage, range, and shotspeed"
			}
		},
		[Trinket.HOLY_HEART.ID] = {
			Name = "Holy Heart",
			Description = {
				"Picking up Soul, Black, or Eternal Hearts grants a {{Collectible313}} Holy Mantle shield",
				"#{{HalfSoulHeart}} Half Soul Hearts and Blended Hearts only have a 50% chance to grant a shield",
			}
		},
		[Trinket.LEAHS_LOCK.ID] = {
			Name = "Leah's Lock",
			Description = {
				function(descObj)
					return modifiers[Trinket.LEAHS_LOCK.ID]._modifier(descObj,
						"%s chance to fire {{Charm}} Charm or {{Fear}} Fear tears",
						"#{{Luck}} %s chance at %s luck"
					)
				end,
				function(descObj)
					return Mod.EID_Support:TrinketMultiGoldStr(descObj,
						"Can trigger both charm and fear at the same time",
						false, true
					)
				end
			}
		},
		[Trinket.LEVIATHANS_TENDRIL.ID] = {
			Name = "Leviathan's Tendril",
			Description = function(descObj)
				return modifiers[Trinket.LEVIATHANS_TENDRIL.ID]._modifier(descObj, {
						"%s chance to deflect projectiles away from Isaac, gaining homing and increased velocity",
						"#{{Fear}} %s chance to inflict fear when near enemies",
					},
					"#{{Leviathan}} Additional +5% chance to each effect"
				)
			end
		},
		[Trinket.NIL_NUM.ID] = {
			Name = "Nil Num",
			Description = {
				"2% chance to get destroyed and spawn a duplicate of one of Isaac's passive items in his inventory when hit"
			}
		},
		[Trinket.PARASOL.ID] = {
			Name = "Parasol",
			Description = {
				"All of Isaac's familiars block projectiles",
				function (descObj)
					return Mod.EID_Support:TrinketMultiGoldStr(descObj,
						"50% chance to reflect the projectile that can hit enemies instead"
				)
				end
			}
		},
		[Trinket.REBOUND_WORM.ID] = {
			Name = "Rebound Worm",
			Description = {
				"Tears ricochet off of walls and grid entities, firing at the closest enemy in range"
			}
		},
		[Trinket.SALINE_SPRAY.ID] = {
			Name = "Saline Spray",
			Description = function(descObj)
				return modifiers[Trinket.SALINE_SPRAY.ID]._modifier(descObj,
					"{{Collectible596}} %s chance to shoot freezing tears",
					"#{{Luck}} %s chance at %s luck"
				)
			end,
		},
		[Trinket.WORMWOOD_LEAF.ID] = {
			Name = "Wormwood Leaf",
			Description = {
				"10% chance to negate damage and turn Isaac into an invulnerable immobile statue for 2 seconds",
				"#Grants Isaac a half second of invulnerability afterwards"
			}
		},
	}
end
