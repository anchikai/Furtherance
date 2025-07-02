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
								[PlayerType.PLAYER_MAGDALENE] = "Ocasionalmente activa {{Collectible45}} Corazón delicioso",
								[PlayerType.PLAYER_CAIN] = "Ocasionalmente devuelve las llaves usadas en cofre",
								[PlayerType.PLAYER_JUDAS] = "Ocasionalmente activa {{Collectible34}} Libro de Belial",
								[PlayerType.PLAYER_BLUEBABY] = "Ocasionalmente otorga temporalmente {{Collectible248}} Mente Colmena",
								[PlayerType.PLAYER_EVE] = "Ocasionalmente otorga temporalmente el efecto {{Collectible122}} Ramera de Babilonia",
								[PlayerType.PLAYER_SAMSON] = "Ocasionalmente otorga temporalmente {{Collectible157}} Lujuria de Sangre con +3 golpes",
								[PlayerType.PLAYER_AZAZEL] = "Ocasionalmente otorga temporalmente el efecto {{Trinket162}} Muñon de Azazel",
								[PlayerType.PLAYER_LAZARUS] = "Ocasionalmente otorga temporalmente el efecto {{Collectible214}} Anemico",
								[PlayerType.PLAYER_EDEN] = "Se vuelve un familiar de Contador del amor al azar. Despues de activar su efecto se convertira en otro al azar",
								[PlayerType.PLAYER_THELOST] = "Ocasionalmente otorga temporalmente un {{Collectible313}} Manto Sagrado. No puede otorgar otro hasta que el anterior se rompa",
								[PlayerType.PLAYER_LILITH] = "Ocasionalmente activa {{Collectible357}} Cajon de Amigos",
								[PlayerType.PLAYER_KEEPER] = "Ocasionalmente otorga temporalmente {{Collectible450}} Ojo de Codicia",
								[PlayerType.PLAYER_APOLLYON] = "Ocasionalmente Genera un Locust al azar",
								[PlayerType.PLAYER_THEFORGOTTEN] = "Ocasionalmente cambia entre la forma hueso y la forma alma, cada uno dispara lagrimas distintas",
								[PlayerType.PLAYER_BETHANY] = "Ocasionalmente otorga temporalmente {{Collectible584}} Libro de virtudes",
								[PlayerType.PLAYER_JACOB] = "Ocasionalmente activa {{Collectible687}} Buscador de Amigos",
								[PlayerType.PLAYER_ESAU] = "Ocasionalmente otorga temporalmente un pequeño efecto de {{Collectible621}} Guisado Rojo",
								[Mod.PlayerType.LEAH] = "Ocasionalmente activa {{Collectible" .. Mod.Item.HEART_RENOVATOR.ID .. "}} Reneuva Corazon",
								[Mod.PlayerType.PETER] = "Ocasionalmente activa {{Collectible" .. Mod.Item.KEYS_TO_THE_KINGDOM.ID .. "}} Llaves al reino en un solo enemigo no-jefe ",
								[Mod.PlayerType.MIRIAM] = "Ocasionalmente activa {{Collectible" .. Mod.Item.TAMBOURINE.ID .. "}} Pandereta",
							})
						end
					}
				}
			},
			[Mod.Slot.ESCORT_BEGGAR.SLOT] = {
				[0] = {
					Name = "Mendigo Escoltado",
					Description = {
						"Puede ser recogido y llevado a la habitacion especial pedida para una recomepsa de su {{ItemPoolEscortBeggar}} Item Pool",
						"#{{Throwable}} Tiralo contra enemigos para que sean empujados con 5 de daño",
						"#!!! Puede recibir daño y morira en 3 golpes",
						"#!!! Sera abducido si se deja en la habitacion anterior mucho tiempo"
					}
				}
			},
		},
	}
end