local Mod = Furtherance

return function(modifiers)
	return {
		[EntityType.ENTITY_PICKUP] = {
			[PickupVariant.PICKUP_BOMB] = {
				[Mod.Pickup.CHARGED_BOMB.ID] = {
					Name = "Bomba Cargada",
					Description = {
						"{{Bomb}} +1 Bomba",
						"#{{Battery}} Recarga por ocmpleto un objeto activo de Isaac",
						"#!!! 1% de probabilidad de explotar si Isaac tiene más de medio corazón de salud"
					}
				},
			},
			[PickupVariant.PICKUP_GRAB_BAG] = {
				[Mod.Pickup.GOLDEN_SACK.ID] = {
					Name = "Saco Dorado",
					Description = {
						"80% de probabilidad de que aparezca otro Saco Dorado en algún lugar de la habitación al recogerlo"
					}
				},
			},
			[PickupVariant.PICKUP_HEART] = {
				[Mod.Pickup.MOON_HEART.ID] = {
					Name = "Corazon Lunar {{MoonHeart}}",
					Description = {
						"{{SoulHeart}} Funciona como un Corazón de Alma",
						"#{{SecretRoom}} Habitaciones Secretas y Super Secretas Contienen un {{Collectible589}} Rayo de luz Lunar",
						"#El primer rayo de luz otorga +1 de Fire Rate, y todos los demas +0.5 Fire Rate",
						function(descObj)
							return modifiers[5][10][Mod.Pickup.MOON_HEART.ID]._modifier(descObj,
								"#El numero de rayos de luz es equivalente a ña suma de los corazones lunares de todos los Jugadores (e.g. 1 Corazon Lunar = Solo un rayo de luz en el piso)",
								"#{{Collectible589}} Otorga un {{Tears}} +0.5 Fire rate extra por cada corazon lunar que tiene Isaac al interactuar con un rayo de luz luanr"
							)
						end
					}
				},
			},
			[PickupVariant.PICKUP_COIN] = {
				[Mod.Pickup.UNLUCKY_PENNY.ID] = {
					Name = "Penique Desafortunado",
					Description = {
						"↓ {{Luck}} -1 Suerte",
						"#↑ {{Damage}} +0.5 Daño"
					}
				},
			},
		},
		[EntityType.ENTITY_SLOT] = {
			[Mod.Slot.LOVE_TELLER.ID] = {
				[0] = {
					Name = "Contador del Amor",
					Description = {
						"{{Coin}} Cuesta 5 monedas para usar",
						"#Empareja a Isaac con otro personaje otorga una recompensa dependiendo del resultado",
						"#{{EmptyHeart}} Genera una mosca",
						"#{{HalfHeart}} Genera dos corazones",
						"#{{Heart}} Genera un familiar unico relacionado con el personaje obtenido",
						function(descObj)
							return modifiers[EntityType.ENTITY_SLOT][Mod.Slot.LOVE_TELLER.ID][0]._modifier({
								[PlayerType.PLAYER_ISAAC] = "Ocasionalmente otorga temporalmente {{Collectible206}} Guillotina",
								[PlayerType.PLAYER_MAGDALENE] = "Ocasionalmente activa {{Collectible45}} Yum Heart",
								[PlayerType.PLAYER_CAIN] = "Occasionally refunds keys used on chests",
								[PlayerType.PLAYER_JUDAS] = "Ocasionalmente activa {{Collectible34}} Book of Belial",
								[PlayerType.PLAYER_BLUEBABY] = "Ocasionalmente otorga temporalmente {{Collectible248}} Hive Mind",
								[PlayerType.PLAYER_EVE] = "Ocasionalmente otorga temporalmente el efecto {{Collectible122}} Whore of Babylon effect",
								[PlayerType.PLAYER_SAMSON] = "Ocasionalmente otorga temporalmente {{Collectible157}} Blood Lust with +3 hits",
								[PlayerType.PLAYER_AZAZEL] = "Ocasionalmente otorga temporalmente el efecto {{Trinket162}} Azazel's Stump effect",
								[PlayerType.PLAYER_LAZARUS] = "Ocasionalmente otorga temporalmente el efecto {{Collectible214}} Anemic effect",
								[PlayerType.PLAYER_EDEN] = "Se vuelve un familiar de Contador del amor al azar. Despues de activar su efecto se convertira en otro al azar",
								[PlayerType.PLAYER_THELOST] = "Ocasionalmente otorga temporalmente un {{Collectible313}} mantle shield. Cannot grant another until the shield breaks",
								[PlayerType.PLAYER_LILITH] = "Ocasionalmente activa {{Collectible357}} Box of Friends",
								[PlayerType.PLAYER_KEEPER] = "Ocasionalmente otorga temporalmente {{Collectible450}} Eye of Greed",
								[PlayerType.PLAYER_APOLLYON] = "Ocasionalmente Genera un Locust al azar",
								[PlayerType.PLAYER_THEFORGOTTEN] = "Occasionally swaps between bone and soul form, each shooting different tears",
								[PlayerType.PLAYER_BETHANY] = "Ocasionalmente otorga temporalmente {{Collectible584}} Book of Virtues",
								[PlayerType.PLAYER_JACOB] = "Ocasionalmente activa {{Collectible687}} Friend Finder",
								[PlayerType.PLAYER_ESAU] = "Ocasionalmente otorga temporalmente un pequeño efecot de {{Collectible621}} Red Stew effect",
								[Mod.PlayerType.LEAH] = "Ocasionalmente activa {{Collectible" .. Mod.Item.HEART_RENOVATOR.ID .. "}} Heart Renovator",
								[Mod.PlayerType.PETER] = "Ocasionalmente activa {{Collectible" .. Mod.Item.KEYS_TO_THE_KINGDOM.ID .. "}} Keys to the Kingdom on a single non-boss target",
								[Mod.PlayerType.MIRIAM] = "Ocasionalmente activa {{Collectible" .. Mod.Item.TAMBOURINE.ID .. "}} Tambourine",
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