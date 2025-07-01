local Mod = Furtherance

return function(modifiers)
	return {
		[Mod.Card.ACE_OF_SHIELDS.ID] = {
			Name = "As de Escudos",
			Description = {
				"{{Battery}} Vuelve todos los recolectables, cofres y enemigos no-jefes a Micro Baterias"
			}
		},
		[Mod.Card.CHARITY.ID] = {
			Name = "XXIV - Caridad",
			Description = {
				"{{Collectible464}} Otorga a Isaac lo que necesita mas 3 veces",
				"#Si tiene lo que necesita en vida y recolectables, incrementa su peor estadistica en su lugar"
			}
		},
		[Mod.Card.FAITH.ID] = {
			Name = "XXV - Fe",
			Description = {
				"{{Confessional}} Genera un Confesionario"
			}
		},
		[Mod.Card.GOLDEN_CARD.ID] = {
			Name = "Carta Dorada",
			Description = {
				"Efecto de una carta aleatoria",
				"#50% de probabilidad de destruirse con cada uso"
			}
		},
		[Mod.Card.HOPE.ID] = {
			Name = "XXIII - Esperanza",
			Description = {
				"Por la duracion de la habitacion, los enemigos tienen un 20% de probabilidad de soltar un recolectable aleatorio al morir",
				"#los recolectables soltados no pueden ser objetos, cofres o trinkets"
			}
		},
		[Mod.Card.KEY_CARD.ID] = {
			Name = "Carta Llave",
			Description = {
				"{{LadderRoom}} Genera un espacio de acceso"
			}
		},
		[Mod.Card.REVERSE_CHARITY.ID] = {
			Name = "XXIV - Caridad?",
			Description = {
				"Duplica todos los recolectables en la habitacion y los convierte en objetos de tienda"
			}
		},
		[Mod.Card.REVERSE_FAITH.ID] = {
			Name = "XXV - Fe?",
			Description = {
				"Genera 2 {{MoonHeart}} Corazones Lunares"
			}
		},
		[Mod.Card.REVERSE_HOPE.ID] = {
			Name = "XXIII - Esperanza?",
			Description = {
				"Teletransporta a Isaac a una habitacion de desafio extra"
			}
		},
		[Mod.Card.TRAP_CARD.ID] = {
			Name = "Carta Trampa",
			Description = {
				"{{Chained}} Encadena al enemigo mas cercano"
			}
		},
		[Mod.Card.TWO_OF_SHIELDS.ID] = {
			Name = "Dos de Escudos",
			Description = {
				"{{Battery}} Duplica las cargas del objeto activo de Isaac",
			}
		},
		[Mod.Rune.ESSENCE_OF_DEATH.ID] = {
			Name = "Esencia de la Muerte",
			Description = {
				"{{Collectible693}} Mata a todo enemigo no-jefe en la habitacion y genera una mosca orbital por cada uno"
			}
		},
		[Mod.Rune.ESSENCE_OF_DELUGE.ID] = {
			Name = "Esencia del Diluvio",
			Description = {
				"Genera 15 gotas de lluvia encima de cada enemigo en la habitacionen el transcurso de 5 segundos",
				"#{{Slow}} Las gotas de lluvia realentizan enemigos e inflingen el 66% del daño de Isaac"
			}
		},
		[Mod.Rune.ESSENCE_OF_DROUGHT.ID] = {
			Name = "Esencia de la Sequía",
			Description = {
				"{{BleedingOut}} Inflige sangrado permanente a todo enemigo no jefe en la habitacion, los jefes sangran por 5 segundo ",
				"#{{Freezing}} Los enemigos se vuelven estatuas congeladas al morir"
			}
		},
		[Mod.Rune.ESSENCE_OF_HATE.ID] = {
			Name = "Esencia del Odio",
			Description = {
				"{{Collectible" ..
				Mod.Item.SHATTERED_HEART.ID .. "}} Genera 6 {{Heart}} Corazones Rojos que explotan poco despues de generarse",
				"#Estos corazones no pueden ser recogidos",
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
			Description = function()
				return modifiers[Mod.Item.OLD_CAMERA.PHOTO_IDs[1]]._modifier(Mod.Item.OLD_CAMERA.PHOTO_IDs[1],
					"{{Collectible634}} Spawns %s Purgatory ghosts to immediately target enemies"
				)
			end
		},
		[Mod.Item.OLD_CAMERA.PHOTO_IDs[2]] = {
			Name = "Haunted Photo",
			Description = function()
				return modifiers[Mod.Item.OLD_CAMERA.PHOTO_IDs[1]]._modifier(Mod.Item.OLD_CAMERA.PHOTO_IDs[2],
					"{{Collectible634}} Spawns %s Purgatory ghosts to immediately target enemies"
				)
			end
		},
		[Mod.Item.OLD_CAMERA.PHOTO_IDs[3]] = {
			Name = "Possessed Photo",
			Description = function()
				return modifiers[Mod.Item.OLD_CAMERA.PHOTO_IDs[1]]._modifier(Mod.Item.OLD_CAMERA.PHOTO_IDs[3],
				"{{Collectible634}} Spawns %s Purgatory ghosts to immediately target enemies"
				)
			end
		}
	}
end
