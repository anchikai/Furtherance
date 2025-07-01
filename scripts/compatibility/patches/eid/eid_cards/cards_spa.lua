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
				"{{Collectible464}} Otorga a Isaac lo que más necesita 3 veces",
				"#Si tiene lo que necesita en vida y recolectables, incrementa su peor estadística en su lugar"
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
				"Por la duración de la habitación, los enemigos tienen un 20% de probabilidad de soltar un recolectable aleatorio al morir",
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
				"Duplica todos los recolectables en la habitación y los convierte en objetos de tienda"
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
				"Teletransporta a Isaac a una habitación de desafio extra"
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
				"{{Collectible693}} Mata a todo enemigo no-jefe en la habitación y genera una mosca orbital por cada uno"
			}
		},
		[Mod.Rune.ESSENCE_OF_DELUGE.ID] = {
			Name = "Esencia del Diluvio",
			Description = {
				"Genera 15 gotas de lluvia encima de cada enemigo en la habitación en el transcurso de 5 segundos",
				"#{{Slow}} Las gotas de lluvia ralentizan enemigos e inflingen el 66% del daño de Isaac"
			}
		},
		[Mod.Rune.ESSENCE_OF_DROUGHT.ID] = {
			Name = "Esencia de la Sequía",
			Description = {
				"{{BleedingOut}} Inflige sangrado permanente a todo enemigo no jefe en la habitación, los jefes sangran por 5 segunds ",
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
			Name = "Esencia de la Vida",
			Description = {
				"{{Collectible658}} Genera 1 miniIsaac por cada enemigo en la habitación",
			}
		},
		[Mod.Rune.ESSENCE_OF_LOVE.ID] = {
			Name = "Esencia del Amor",
			Description = {
				"{{Friendly}} Vuelve todo enemigo no-jefe en la habitación en un aliado permanente"
			}
		},
		[Mod.Rune.SOUL_OF_LEAH.ID] = {
			Name = "Alma de Leah",
			Description = {
				"↑ El máximo de contenedores de corazon aumenta en 3",
				"#↓ {{BrokenHeart}} +3 Corazones Rotos",
				"#!!! No puede aumentar el máximo de corazones más de 24, pero si otorgará los corazones rotos",
				function(descObj)
					return modifiers[Mod.Rune.SOUL_OF_LEAH.ID]._modifier(descObj,
						"Solo incrementa el máximo de corazones por 1 y otorga 1 corazón roto moneda"
					)
				end
			}
		},
		[Mod.Rune.SOUL_OF_MIRIAM.ID] = {
			Name = "Alma de Miriam",
			Description = {
				"Empieza a llover y llena la habitacion de agua",
				"#Un creep dañino crecerá infinitamente en el centro de la habitación",
				"#dura 40 segundos entre habitaciones y pisos"
			}
		},
		[Mod.Rune.SOUL_OF_PETER.ID] = {
			Name = "Alma de Peter",
			Description = {
				"Añade 5 habitaciones aleatorias en el piso actual",
				"#Las habitaciones tienen un 10% de probabilidad de ser una habitación especial",
			}
		},
		[Mod.Item.OLD_CAMERA.PHOTO_IDs[1]] = {
			Name = "Foto Aterradora",
			Description = function()
				return modifiers[Mod.Item.OLD_CAMERA.PHOTO_IDs[1]]._modifier(Mod.Item.OLD_CAMERA.PHOTO_IDs[1],
					"{{Collectible634}} Genera %s Fantasmas del Purgatorio que atacan inmediatamente a los enemigos"
				)
			end
		},
		[Mod.Item.OLD_CAMERA.PHOTO_IDs[2]] = {
			Name = "Foto Embrujada",
			Description = function()
				return modifiers[Mod.Item.OLD_CAMERA.PHOTO_IDs[1]]._modifier(Mod.Item.OLD_CAMERA.PHOTO_IDs[2],
					"{{Collectible634}} Genera %s Fantasmas del Purgatorio que atacan inmediatamente a los enemigos"
				)
			end
		},
		[Mod.Item.OLD_CAMERA.PHOTO_IDs[3]] = {
			Name = "Foto Poseída",
			Description = function()
				return modifiers[Mod.Item.OLD_CAMERA.PHOTO_IDs[1]]._modifier(Mod.Item.OLD_CAMERA.PHOTO_IDs[3],
				"{{Collectible634}} Genera %s Fantasmas del Purgatorio que atacan inmediatamente a los enemigos"
				)
			end
		}
	}
end
