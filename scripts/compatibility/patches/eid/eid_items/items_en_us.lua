local Mod = Furtherance
local FR_EID = Mod.EID_Support
local Item = Mod.Item

return function(modifiers)
	return {
		[Item.ALTERNATE_REALITY.ID] = {
			Name = "Alternate Reality",
			Description = {
				"Sends Isaac to a completely random stage with a random stage variant",
				"#Includes any floor from The Basement to The Void, including the alt path"
			}
		},
		[Item.APOCALYPSE.ID] = {
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
		[Item.ASTRAGALI.ID] = {
			Name = "Astragali",
			Description = {
				"Rerolls all chests in the room into other chest variants"
			}
		},
		[Item.BEGINNERS_LUCK.ID] = {
			Name = "Beginner's Luck",
			Description = {
				"↑ {{Luck}} +10 Luck",
				"#For every new unexplored room Isaac enters, {{Luck}} -1 Luck until the it cancels out the luck granted by this item",
				"#Luck is granted back on the next floor"
			}
		},
		[Item.BINDS_OF_DEVOTION.ID] = {
			Name = "Binds of Devotion",
			Description = {
				"{{Player19}} Spawns Jacob as a second character without Esau",
				"#When he dies, permanently removes Binds of Devotion and any item that he has picked up from his inventory",
			}
		},
		[Item.BLOOD_CYST.ID] = {
			Name = "Blood Cyst",
			Description = {
				"Spawns a Blood Cyst in a random spot upon entering an uncleared room",
				"#Damaging the Blood Cyst will cause it to explode, shooting out a fountain of 20 tears"
			}
		},
		[Item.BOOK_OF_AMBIT.ID] = {
			Name = "Book of Ambit",
			Description = {
				"{{Timer}} Receive for the room:",
				"#↑ {{Range}} +5 Range",
				"#↑ {{Shotspeed}} +1.5 Shot speed",
				"# Piercing tears"
			}
		},
		[Item.BOOK_OF_BOOKS.ID] = {
			Name = "Book of Books",
			Description = {
				"Uses a random book active item"
			}
		},
		[Item.BOOK_OF_GUIDANCE.ID] = {
			Name = "Book of Guidance",
			Description = {
				"{{Collectible175}} For the remainder of the floor, all doors are unlocked as if used with Dad's Key"
			}
		},
		[Item.BOOK_OF_LEVITICUS.ID] = {
			Name = "Book of Leviticus",
			Description = {
				function(descObj)
					return modifiers[Item.BOOK_OF_LEVITICUS.ID]._modifier(descObj)
				end
			},
			FallbackDescription = {
				"{{Card72}} Uses XVI - The Tower?"
			}
		},
		[Item.BOOK_OF_SWIFTNESS.ID] = {
			Name = "Book of Swiftness",
			Description = {
				function(descObj)
					return modifiers[Item.BOOK_OF_SWIFTNESS.ID]._modifier(descObj)
				end
			},
			FallbackDescription = {
				"{{Card54}} Uses Era Walk"
			}
		},
		[Item.BRUNCH.ID] = {
			Name = "Brunch",
			Description = {
				"↑ {{Heart}} +2 Health",
				"#{{HealingRed}} Heals 4 hearts",
				"#↑ {{Shotspeed}} +0.16 Shot speed"
			}
		},
		[Item.BUTTERFLY.ID] = {
			Name = "Butterfly",
			Description = {
				"Taking damage causes Isaac to shoot out tears at 50% damage in random directions for 1 second"
			}
		},
		[Item.CADUCEUS_STAFF.ID] = {
			Name = "Caduceus Staff",
			Description = {
				"5% chance for damage taken to not remove any health and grant either a {{Heart}} Red Heart, {{SoulHeart}} Soul Heart, or half of both depending on Isaac's health",
				"#If effect wasn't triggered upon taking damage, multiplies chance by x1.7 to trigger on next damage",
				"#Chance resets upon effect activating"
			}
		},
		[Item.CARDIOMYOPATHY.ID] = {
			Name = "Cardiomyopathy",
			Description = {
				"Picking up {{Heart}} Red Hearts has a 33% chance to grant brief invincibility",
				"#Invincibility lasts 1 second for each half a heart the pickup grants",
				"#{{Heart}} Additionally adds a 1% chance upon heart pickup to grant +1 Red Heart",
				"#{{Luck}} 20% chance at 20 luck",
				"#!!! Converts all {{BoneHeart}} Bone Hearts into {{Heart}} Red Hearts"
			}
		},
		[Item.CERES.ID] = {
			Name = "Ceres?",
			Description = {
				"5% chance to shoot a green tear that causes the enemy to start leaving green creep for 3 seconds",
				"#{{Luck}} 50% chance at 9 luck",
				"#The creep deals 30 damage per second to other enemies",
			}
		},
		[Item.CHIRON.ID] = {
			Name = "Chiron?",
			Description = {
				--Book of Secrets description
				"{{Timer}} Each floor, grants one of these effects for the floor:#{{Collectible54}} Treasure Map#{{Collectible21}} Compass#{{Collectible246}} Blue Map",
				"#{{BossRoom}} Entering a boss room activates a random \"offensive\" book"
			}
		},
		[Item.CHI_RHO.ID] = {
			Name = "Chi Rho",
			Description = {
				"{{Collectible643}} 2% chance to fire a holy beam while shooting",
				"#{{Luck}} 15% chance at 15 luck"
			}
		},
		[Item.COLD_HEARTED.ID] = {
			Name = "Cold Hearted",
			Description = {
				"{{Freezing}} Touching enemies freezes them",
				"#{{Slow}} Touching bosses slows them for 5 seconds"
			}
		},
		[Item.COSMIC_OMNIBUS.ID] = {
			Name = "Cosmic Omnibus",
			Description = {
				"Teleports Isaac to a random unvisited special room on the floor",
				"#{{Planetarium}} If all special rooms on the floor have been visited, teleports Isaac to an extra Planetarium room",
				"#Subsequent uses sends Isaac to a random special room on the floor"
			}
		},
		[Item.CRAB_LEGS.ID] = {
			Name = "Crab Legs",
			Description = {
				"Walking in a perpendicular direction to the direction Isaac is shooting grants {{Speed}} +0.5 Speed"
			}
		},
		[Item.D16.ID] = {
			Name = "D16",
			Description = {
				"Rerolls all heart pickups in the room into other heart variants"
			}
		},
		[Item.D9.ID] = {
			Name = "D9",
			Description = {
				"Rerolls all trinkets in the room into other trinkets"
			}
		},
		[Item.EPITAPH.ID] = {
			Name = "Epitaph",
			Description = {
				"{{Collectible545}} 10% chance for dead enemies to revive upon room clear as a bone orbital or a skeletal companion",
				"#Dying with this item will create a tombstone in a random room on the same floor Isaac died on for the next run",
				"#{{Collectible}} Bombing the tombstone 3 times spawns {{Coin}} 3-5 coins, {{Key}} 2-3 keys, and the first and last passive items Isaac had in his inventory the previous run"
			}
		},
		[Item.EXSANGUINATION.ID] = {
			Name = "Exsanguination",
			Description = {
				"↑ Every heart pickup grants a permament {{Damage}} +0.05 Damage up",
				"#Newly spawned hearts have a 50% chance to start flashing, disappearing after 2 seconds"
			}
		},
		[Item.FIRSTBORN_SON.ID] = {
			Name = "Firstborn Son",
			Description = {
				"{{Collectible634}} When in an uncleared room with enemies, will turn into a homing exploding ghost",
				"#The ghost will target the enemy with the folowing priorities: Non-bosses over bosses > Highest health > Closest to the ghost ",
				"#Will instantly kill the targeted enemy and does not damage other enemies. If a boss, deals 10% of their maximum health instead"
			}
		},
		[Item.FLUX.ID] = {
			Name = "Flux",
			Description = {
				"↑ Grants {{Range}} +9.75 Range and spectral tears",
				"#Tears only move when Isaac moves",
				"#Shoot tears in the opposite direction that mirror Isaac's movement"
			}
		},
		[Item.GOLDEN_PORT.ID] = {
			Name = "Golden Port",
			Description = {
				"{{Battery}} Using an uncharged active fully recharges it at the cost of 5 cents",
				"#Only works when the item has no charges"
			}
		},
		[Item.HEART_EMBEDDED_COIN.ID] = {
			Name = "Heart Embedded Coin",
			Description = {
				"{{Coin}} Picking up {{Heart}} Red Hearts while at full health gives that heart's worth in coins instead"
			}
		},
		[Item.HEART_RENOVATOR.ID] = {
			Name = "Heart Renovator",
			Description = {
				"Picking up {{Heart}} Red Hearts while at full red health puts them in a special counter",
				"#!!! Double tapping {{ButtonRT}} removes 2 from the counter and grants a {{BrokenHeart}} Broken Heart",
				"#↑ Upon use, removes a Broken Heart and grants a permanent {{Damage}} +0.5 Damage up"
			}
		},
		[Item.IRON.ID] = {
			Name = "Iron",
			Description = {
				"Orbital",
				"#{{Collectible257}} Friendly tears hitting it will double in size and damage and burn enemeis"
			}
		},
		[Item.ITCHING_POWDER.ID] = {
			Name = "Itching Powder",
			Description = {
				"Taking damage will deal fake damage one second later"
			}
		},
		[Item.JAR_OF_MANNA.ID] = {
			Name = "Jar of Manna",
			Description = {
				"{{Battery}} Must be charged by Manna Orbs dropped from enemies, then:",
				"#{{Collectible464}} Grants whatever Isaac needs the most",
				"#{{Collectible644}} If Isaac is already satisfied in health and pickups, increases Isaac's lowest stat out of Speed, Fire rate, Damage, Range, Shot speed, and Luck"
			}
		},
		[Item.JUNO.ID] = {
			Name = "Juno?",
			Description = {
				"+2 {{SoulHeart}} Soul Hearts",
				"#{{Collectible722}} 3% chance to fire a tear that chains them in place for 2 seconds",
				"#{{Luck}} 25% chance at 11 luck"
			}
		},
		[Item.KARETH.ID] = {
			Name = "Kareth",
			Description = {
				"!!! Replaces all pedestals with 1-3 trinkets dependent on the collectible's quality",
				"#{{Quality0}}-{{Quality1}}: 1 trinket",
				"#{{Quality2}}: 2 trinkets",
				"#{{Quality3}}-{{Quality4}}: 3 trinkets"
			}
		},
		[Item.KERATOCONUS.ID] = {
			Name = "Keratoconus",
			Description = {
				"↑ {{Range}} +2 Range",
				"#↓ {{Shotspeed}} -0.15 Shot speed",
				"#Enemies far away from Isaac will appear larger in size and become closer to their regular size when getting closer",
				"#{{Slow}} Enemies are slowed depending on their distance from Isaac, farther away having a stronger effect"
			}
		},
		[Item.KEYS_TO_THE_KINGDOM.ID] = { --123 filigree feather
			Name = "Keys to the Kingdom",
			Description = {
				"#{{Timer}} Each normal enemy is removed and grants a random temporary stat up for the remainder of the floor",
				"#{{BossRoom}} Bosses are spared after 30 seconds, granting 3 random permanent stat ups",
				"#Getting hit or hurting the boss will add 1/3rd of the countdown back",
				"#{{AngelRoom}} Instantly spares angels, dropping a {{Collectible238}}{{Collectible239}} key piece, or if Isaac has them already, a random {{ItemPoolAngel}}angel room item",
				"#{{DevilRoom}} Each Devil Deal in the room is removed and grants a random permanent stat up"
			}
		},
		[Item.KEY_ALT.ID] = {
			Name = "Alt Key",
			Description = {
				"Restarts the floor on a random variant of the alt path, or if on the alt path, a random variant of the normal path"
			}
		},
		[Item.KEY_BACKSPACE.ID] = {
			Name = "Backspace Key",
			Description = {
				"!!! Removes 2 of Isaac's earliest passive items and brings him to the previous floor.",
				"#The floor is newly generated but remains the same floor variant as when it was last visited",
				"#!!! Can only be used up to 3 times before disappearing"
			}
		},
		[Item.KEY_C.ID] = {
			Name = "C Key",
			Description = {
				"{{Library}} Teleports Isaac to a Library with 5 books"
			}
		},
		[Item.KEY_CAPS.ID] = {
			Name = "Caps Key",
			Description = {
				function(descObj)
					return modifiers[Item.KEY_CAPS.ID]._modifier(descObj)
				end
			},
			FallbackDescription = {
				"{{Card52}} Uses Huge Growth"
			}
		},
		[Item.KEY_E.ID] = {
			Name = "E Key",
			Description = {
				"{{Crafting17}} Spawns a lit Giga Bomb"
			}
		},
		[Item.KEY_ENTER.ID] = {
			Name = "Enter Key",
			Description = {
				"{{BossRushRoom}} Opens a Boss Rush door in the current room, regardless of in-game time"
			}
		},
		[Item.KEY_ESC.ID] = {
			Name = "Esc Key",
			Description = {
				"Teleports Isaac to a random room",
				"#Heals Isaac with Red and Soul Hearts if he has less than 6 hearts"
			}
		},
		[Item.KEY_F4.ID] = {
			Name = "F4 Key",
			Description = {
				"Teleports Isaac to a random special room that has not been explored yet depending on what consumables he has the least of",
				"#Coins: {{ArcadeRoom}}",
				"#Bombs: {{SuperSecretRoom}}, {{IsaacsRoom}}, {{SecretRoom}}",
				"#Keys: {{Shop}}, {{TreasureRoom}}, {{DiceRoom}}, {{Library}}, {{ChestRoom}}, {{Planetarium}}",
				"#Can teleport Isaac to any of the rooms above if all consumable counts are equal"
			}
		},
		[Item.KEY_Q.ID] = {
			Name = "Q Key",
			Description = {
				"Triggers the effect of the pocket item Isaac holds without using it",
				"#Max charge changes depending on the pocket item's assigned \"mimic charge\", or if an eternal item, its actual charge"
			}
		},
		[Item.KEY_SHIFT.ID] = {
			Name = "Shift Key",
			Description = {
				"↑ +15 Damage",
				"#The damage up wears off over 1 minute"
			}
		},
		[Item.KEY_SPACEBAR.ID] = {
			Name = "Spacebar Key",
			Description = {
				"{{ErrorRoom}} Teleports Isaac to the I AM ERROR room"
			}
		},
		[Item.KEY_TAB.ID] = {
			Name = "Tab Key",
			Description = {
				"Full mapping effect",
				"#{{UltraSecretRoom}} Reveals the Ultra Secret room"
			}
		},
		[Item.KEY_TILDE.ID] = {
			Name = "Tilde Key",
			Description = {
				"{{Timer}} Activates a random debug command for the room"
			}
		},
		[Item.LEAHS_HEART.ID] = {
			Name = "Leah's Heart",
			Description = {
				"↑ {{Damage}} +20% Damage",
				"#Using an active item removes the damage bonus for the floor, but grants 2 {{SoulHeart}} Soul Hearts and a {{Collectible313}} Holy Mantle shield",
			}
		},
		[Item.LEAKING_TANK.ID] = {
			Name = "Leaking Tank",
			Description = {
				"{{Collectible317}} Leave a trail of damaging creep that deals 30 damage per second",
				"#Frequency of producing creep increases with each empty heart container"
			}
		},
		[Item.LIBERATION.ID] = {
			Name = "Liberation",
			Description = {
				"Killing enemies has a 5% chance to grant flight and open all doors in the current room"
			}
		},
		[Item.LITTLE_RAINCOAT.ID] = {
			Name = "Little Raincoat",
			Description = {
				"↑ Size down",
				"#Spawns a {{Pill}} Power Pill! and adds it to the current run's pill pool",
				"#Every 6 hits, activate a Power Pill! effect",
				"#Power Pill! now deals 15 + Isaac's damage and can damage the same enemy more often the more empty heart containers he has",
				"#Killing enemies with Power Pill! has a 6% to grant +1 {{EmptyHeart}} Heart Container",
			}
		},
		[Item.MANDRAKE.ID] = {
			Name = "Mandrake",
			Description = {
				"Allows Isaac to choose between one item and a familiar item"
			}
		},
		[Item.MIRIAMS_WELL.ID] = {
			Name = "Miriam's Well",
			Description = {
				"Orbital",
				"#Blocks projectiles",
				"#When blocking a projectile, creates a large damaging creep that deals half of Isaac's damage. Afterwards, cannot do so again for 8 seconds"
			}
		},
		[Item.MOLTEN_GOLD.ID] = {
			Name = "Molten Gold",
			Description = {
				"Taking damage has a 25% chance to activate a random rune"
			}
		},
		[Item.MUDDLED_CROSS.ID] = {
			Name = "Muddled Cross",
			Description = function (descObj)
				return modifiers[Item.MUDDLED_CROSS.ID]._modifier(descObj, "killing", "submerging")
			end,
			FallbackDescription = {
				"{{Battery}} Must be charged by killing enemies",
				"#Spawns a pool at the entrance of certain special rooms that reveal an alternate room",
				"#On use, changes the current room into the previewed room",
				"#{{TreasureRoom}} <-> {{RedTreasureRoom}}",
				"#{{UltraSecretRoom}} <-> {{Planetarium}} Planetarium items grant broken hearts",
				"#{{Shop}} <-> {{Library}} Library books cost money",
				"#{{DevilRoom}} <-> {{AngelRoom}} Angel room items cost money. Devil room items disappear after picking one up",
			}
		},
		[Item.BOX_OF_BELONGINGS.ID] = {
			Name = "Box of Belongings",
			Description = {
				"Spawns 2 random special cards/object and a trinket from a unique pool"
			}
		},
		[Item.OLD_CAMERA.ID] = {
			Name = "Old Camera",
			Description = {
				"{{Card" ..
				Item.OLD_CAMERA.PHOTO_IDs[1] ..
				"}} Removes all enemies in the room and spawns a photo consumable that spawns {{Collectible634}} Purgatory ghosts on use",
				"#Number of ghosts spawned depends on the combined maximum HP of all enemies removed"
			}
		},
		[Item.OPHIUCHUS.ID] = {
			Name = "Ophiuchus?",
			Description = {
				"+1 {{SoulHeart}} Soul Heart",
				"#↑ {{Tears}} -0.4 Tear Delay",
				"#↑ {{Damage}} +0.3 Damage",
				"#Spectral tears",
				"#Isaac's tears move in waves"
			}
		},
		[Item.OWLS_EYE.ID] = {
			Name = "Owl's Eye",
			Description = {
				"8% chance to fire a homing and piercing tear that deals double damage",
				"#{{Luck}} 50% chance at 15 luck"
			}
		},
		[Item.PALLAS.ID] = {
			Name = "Pallas?",
			Description = {
				Mod.EID_Support.GetFallbackDescription,
				function(descObj)
					return modifiers[Item.PALLAS.ID]._modifier(descObj,
						"#{{Collectible540}} + Flat Stone: {{Damage}} +16% damage and {{Tearsize}} x2 Tear size"
					)
				end
			},
			FallbackDescription = {
				"↑ {{Tearsize}}+20% Tear size",
				"#{{Collectible529}} Isaac's tears bounce off the floor after floating for a short time",
			}
		},
		[Item.PALLIUM.ID] = {
			Name = "Pallium",
			Description = {
				"{{Collectible658}} On room clear, spawns 1-3 Minisaacs",
				"#Minisaacs disappear on the next floor"
			}
		},
		[Item.LIL_POOFER.ID] = {
			Name = "Lil Poofer",
			Description = {
				"Blocks projectiles",
				"#Each projectile blocked has it grow in size",
				"#After taking 10 hits, it explodes. The explosion {{HealingRed}} Heals players in its radius for {{HalfHeart}} +1 Half Red Heart, deals 10 damage to enemies, and leaves 6 lines of damaging creep in a radial spread that deal 20 damage per second"
			}
		},
		[Item.PHARAOH_CAT.ID] = {
			Name = "Pharoh Cat",
			Description = {
				"A Bastet Statue in will appear in a random location in an uncleared room",
				"#Projectiles in its aura will be instantly destroyed",
				"#Statue is destroyed once the room is cleared"
			}
		},
		[Item.PILLAR_OF_CLOUDS.ID] = {
			Name = "Pillar of Clouds",
			Description = {
				"{{Timer}} Receive for 10 seconds:",
				"#Flight that bypasses walls to move between rooms",
				"#Unable to interact with anything in the room",
				"#Unable to fire tears",
			}
		},
		[Item.PILLAR_OF_FIRE.ID] = {
			Name = "Pillar of Fire",
			Description = {
				"Taking damage has a 5% chance to shoot out 5 flames from Isaac",
				"#{{Burning}} Flames will target enemies and shoot fire projectiles that inflict burn",
				"#Flames disspate after a short period of time"
			}
		},
		[Item.PLUG_N_PLAY.ID] = {
			Name = "Plug N' Play",
			Description = {
				"{{Collectible721}} Spawns a glitched item"
			}
		},
		[Item.POLARIS.ID] = {
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
		[Item.POLARITY_SHIFT.ID_1] = {
			Name = "Polarity Shift",
			Description = {
				"{{Battery}} Charges with damage dealt",
				"#{{Timer}} Receive for 10 seconds:",
				"#{{ArrowDown}} {{Tears}} -Stat 1 down",
				"#{{ArrowDown}} {{Damage}} -Stat 2 down",
				"#Restricts Isaac's attack to a flurry of lightning strikes"
			}
		},
		[Item.POLARITY_SHIFT.ID_2] = {
			Name = "Polarity Shift",
			Description = {
				"Changes Spiritual Wound to Chain Lightning",
				"#Can only be activated while Isaac has {{Heart}} Red Hearts",
				"#{{Timer}} While active:",
				"#{{Blank}} Life steal is disabled, instead rapidly draining {{Heart}} Red Hearts.",
				"#{{Blank}} Less delay between damaging enemies"
			}
		},
		[Item.POLYDIPSIA.ID] = {
			Name = "Polydipsia",
			Description = {
				"↓ {{Tears}} x0.5 Tears multiplier",
				"#↓ {{Tears}} +8 Tear delay",
				"#Isaac's tears are shot in an arc",
				"#Isaac's tears leave creep, its size scaling with the size of the tear",
				"#{{Damage}} The creep deals 66% of Isaac's damage per second and inherits his tear effects",
				"#When coming into contact with another Polydipsia creep, increases its lifetime by 1 second"
			}
		},
		[Item.PRAYER_JOURNAL.ID] = {
			Name = "Prayer Journal",
			Description = {
				"{{BlackHeart}} 50% chance to grant a Black Heart",
				"#{{SoulHeart}} 40% chance to grant a Soul Heart",
				"#{{BrokenHeart}} 10% chance to grant a Broken Heart"
			}
		},
		[Item.QUARANTINE.ID] = {
			Name = "Quarantine",
			Description = {
				"{{Fear}} Entering an uncleared room fears all enemies for 6 seconds",
				"#{{Poison}} Getting close to enemies during this period poisons them for 2x Isaac's damage"
			}
		},
		[Item.ROTTEN_APPLE.ID] = {
			Name = "Rotten Apple",
			Description = {
				"↑ {{Damage}} +1 Damage",
				"#Permanently grants a random worm trinket effect"
			}
		},
		[Item.COFFEE_BREAK.ID] = {
			Name = "Coffee Break",
			Description = {
				"↑ {{Heart}} +1 Health",
				"#↑ {{SoulHeart}} +1 Soul Heart",
				"#{{HealingRed}} Heals 2 hearts",
				"#↑ {{Speed}} +0.2 Speed"
			}
		},
		[Item.RUE.ID] = {
			Name = "Rue",
			Description = {
				"{{Collectible118}} Taking damage fires a Brimstone laser as the nearest enemy"
			}
		},
		[Item.SECRET_DIARY.ID] = {
			Name = "Secret Diary",
			Description = {
				"{{Timer}} Receive a {{Collectible619}}Birthright effect for the room"
			}
		},
		[Item.SERVITUDE.ID] = {
			Name = "Servitude",
			Description = {
				"Using with a pedestal nearby will note the item down. Does not discharge and can no longer be recharged normally",
				"#Clearing a room reduces charges instead of gaining",
				"#Reaching 0 charge without taking damage spawns a copy of the item it noted",
				"#!!! Taking damage while the item has charge will discharge it, forgets the noted item, and grants {{BrokenHeart}} +1 Broken Heart",
			}
		},
		[Item.SEVERED_EAR.ID] = {
			Name = "Severed Ear",
			Description = {
				"↑ {{Damage}} +20% Damage",
				"#↑ {{Range}} +1.2 Range",
				"#↓ {{Tears}} +20% Tear delay",
				"#↓ {{Shotspeed}} -0.6 Shot speed",
			}
		},
		[Item.SHATTERED_HEART.ID] = {
			Name = "Shattered Heart",
			Description = {
				"Explodes all hearts in the room, dealing damage based on the heart and leaves damaging creep"
			}
		},
		[Item.SUNSCREEN.ID] = {
			Name = "Sunscreen",
			Description = {
				"Immunity to fire"
			}
		},
		[Item.TAMBOURINE.ID] = {
			Name = "Tambourine",
			Description = {
				"Inflicts extreme knockback to enemies in a small radius around Isaac",
				"#Spawns a giant damaging blue creep for one second"
			}
		},
		[Item.TECHNOLOGY_MINUS_1.ID] = {
			Name = "Technology -1",
			Description = {
				"Tears have a 3.14% chance to fire 3 lasers in random directions"
			}
		},
		[Item.TECH_IX.ID] = {
			Name = "Tech IX",
			Description = {
				"↓ -5 Fire rate",
				"#{{Collectible395}} Isaac's tears are replaced with small green piercing and spectral technology rings",
				"#Rings deal 66% of Isaac's damage"
			}
		},
		[Item.THE_DREIDEL.ID] = {
			Name = "The Driedel",
			Description = {
				"Reduces 1-4 random stats and spawns 1 random item from the current room's item pool",
				"#Quality of the spawned item will depend on the amount of stats lowered"
			}
		},
		[Item.TREPANATION.ID] = {
			Name = "Trepanation",
			Description = {
				"{{Collectible531}} Fire a Haemolacria-like shot every 15 tears"
			}
		},
		[Item.UNSTABLE_CORE.ID] = {
			Name = "Unstable Core",
			Description = {
				"{{Burning}} Using an active item burns enemies in a small radius around Isaac",
				"#Burn lasts longer the more charges the active item has"
			}
		},
		[Item.VESTA.ID] = {
			Name = "Vesta?",
			Description = {
				"↑ {{Damage}} +50% Damage",
				"#↓ {{Tearsize}} Permanent micro-sized tears",
				"#Spectral tears",
				"#{{Collectible224}} 10% chance for tears to split into 4",
				"#{{Luck}} 100% chance at 10 luck"
			}
		},
		[Item.WINE_BOTTLE.ID] = {
			Name = "Wine Bottle",
			Description = {
				"Fires a high-velocity cork every 15 tears",
				"#Cork deals double damage and is 50% larger"
			}
		},
		[Item.ZZZZOPTIONSZZZZ.ID] = {
			Name = "ZZZZoptionsZZZZ",
			Description = {
				"{{Collectible721}} Allows Isaac to choose between one item and a glitched item"
			}
		},
	}
end
