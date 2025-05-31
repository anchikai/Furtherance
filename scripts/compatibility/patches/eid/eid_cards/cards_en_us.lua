local Mod = Furtherance

return function(modifiers)
	return {
		[Mod.Card.ACE_OF_SHIELDS.ID] = {
			Name = "Ace of Shields",
			Description = {
				"{{Battery}} Turns all pickups, chests and non-boss enemies into Micro Batteries"
			}
		},
		[Mod.Card.CHARITY.ID] = {
			Name = "XXIV - Charity",
			Description = {
				"{{Collectible" ..
				Mod.Item.JAR_OF_MANNA.ID ..
				"}} Gives Isaac what he needs the most 3 times. If he has what he needs in health and pickups, increases Isaac's lowest stat instead"
			}
		},
		[Mod.Card.FAITH.ID] = {
			Name = "XXV - Faith",
			Description = {
				"{{Confessional}} Spawns a Confessional"
			}
		},
		[Mod.Card.GOLDEN_CARD.ID] = {
			Name = "Golden Card",
			Description = {
				"Random card effect",
				"#50% chance to destroy itself with each use"
			}
		},
		[Mod.Card.HOPE.ID] = {
			Name = "XXIII - Hope",
			Description = {
				"For the duration of the room, enemies have a 20% chance to drop a random pickup upon death",
				"#Dropped pickups cannot be collectibles, chests, or trinkets"
			}
		},
		[Mod.Card.KEY_CARD.ID] = {
			Name = "Key Card",
			Description = {
				"{{LadderRoom}} Spawns a crawlspace"
			}
		},
		[Mod.Card.REVERSE_CHARITY.ID] = {
			Name = "XXIV - Charity?",
			Description = {
				"Duplicates all pickups in the room and turns them into shop items"
			}
		},
		[Mod.Card.REVERSE_FAITH.ID] = {
			Name = "XXV - Faith?",
			Description = {
				"Spawns 2 {{MoonHeart}} Moon Hearts"
			}
		},
		[Mod.Card.REVERSE_HOPE.ID] = {
			Name = "XXIII - Hope?",
			Description = {
				"Teleports Isaac to an extra Challenge room"
			}
		},
		[Mod.Card.TRAP_CARD.ID] = {
			Name = "Trap Card",
			Description = {
				"{{Chained}} Chains down the nearest enemy"
			}
		},
		[Mod.Card.TWO_OF_SHIELDS.ID] = {
			Name = "Two of Shields",
			Description = {
				"{{Battery}} Doubles Isaac's active item charges",
			}
		},
		[Mod.Rune.ESSENCE_OF_DEATH.ID] = {
			Name = "Essence of Death",
			Description = {
				"{{Collectible693}} Kills all non-boss enemies in the room and spawns a Swarm fly orbital for each one"
			}
		},
		[Mod.Rune.ESSENCE_OF_DELUGE.ID] = {
			Name = "Essence of Deluge",
			Description = {
				"Spawns 15 drain drops over each enemy over the course of 5 seconds",
				"#{{Slow}} Rain drops slow enemies and damage them for 66% of Isaac's damage"
			}
		},
		[Mod.Rune.ESSENCE_OF_DROUGHT.ID] = {
			Name = "Essence of Drought",
			Description = {
				"{{BleedingOut}} Inflicts permanent bleeding on all non-boss enemies in the room. Bosses instead bleed for 5 seconds",
				"#{{Freezing}} Enemies will become frozen statues upon death"
			}
		},
		[Mod.Rune.ESSENCE_OF_HATE.ID] = {
			Name = "Essence of Hate",
			Description = {
				"{{Collectible" ..
				Mod.Item.SHATTERED_HEART.ID .. "}} Spawns 6 {{Heart}} Red Hearts that explode shortly after spawning",
				"#These hearts cannot be collected"
			}
		},
		[Mod.Rune.ESSENCE_OF_LIFE.ID] = {
			Name = "Essence of Life",
			Description = {
				"{{Collectible658}} Spawns 1 Minisaac for each enemy in the room"
			}
		},
		[Mod.Rune.ESSENCE_OF_LOVE.ID] = {
			Name = "Essence of Love",
			Description = {
				"{{Friendly}} Turns all non-boss enemies into permanent friendly companions"
			}
		},
		[Mod.Rune.SOUL_OF_LEAH.ID] = {
			Name = "Soul of Leah",
			Description = {
				"↑ The max amount of heart containers is increased by 3",
				"#↓ {{BrokenHeart}} +3 Broken Hearts",
				"#!!! Cannot increase max heart containers past 24, but still grants Broken Hearts",
				function(descObj)
					return modifiers[Mod.Rune.SOUL_OF_LEAH.ID]._modifier(descObj,
						"Only increases max health by 1 and gains +1 Broken Coin Heart"
					)
				end
			}
		},
		[Mod.Rune.SOUL_OF_MIRIAM.ID] = {
			Name = "Soul of Miriam",
			Description = {
				"Starts raining in the room and fills the room with water",
				"#A damaging creep will slowly and infinitely grow from the center of the room",
				"#Lasts 40 seconds between rooms and floors"
			}
		},
		[Mod.Rune.SOUL_OF_PETER.ID] = {
			Name = "Soul of Peter",
			Description = {
				"Adds 5 rooms randomly on the map",
				"#Rooms can either be a default room or a 10% chance of being a random special room",
			}
		},
		[Mod.Item.OLD_CAMERA.PHOTO_IDs[1]] = {
			Name = "Spooky Photo",
			Description = function(descObj)
				return modifiers[Mod.Item.OLD_CAMERA.PHOTO_IDs[1]]._modifier(1,
					"{{Collectible634}} Spawns %s Purgatory ghosts to immediately target enemies"
				)
			end
		},
		[Mod.Item.OLD_CAMERA.PHOTO_IDs[2]] = {
			Name = "Haunted Photo",
			Description = function(descObj)
				return modifiers[Mod.Item.OLD_CAMERA.PHOTO_IDs[1]]._modifier(2,
					"{{Collectible634}} Spawns %s Purgatory ghosts to immediately target enemies"
				)
			end
		},
		[Mod.Item.OLD_CAMERA.PHOTO_IDs[3]] = {
			Name = "Possessed Photo",
			Description = function(descObj)
				return modifiers[Mod.Item.OLD_CAMERA.PHOTO_IDs[1]]._modifier(3,
				"{{Collectible634}} Spawns %s Purgatory ghosts to immediately target enemies"
				)
			end
		}
	}
end
