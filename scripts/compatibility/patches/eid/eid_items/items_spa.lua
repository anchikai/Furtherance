local Mod = Furtherance
local FR_EID = Mod.EID_Support
local Item = Mod.Item

return function(modifiers)
	return {
		[Item.ALTERNATE_REALITY.ID] = {
			Name = "Realidad Alternativa",
			Description = {
				"Transporta a Isaac a una Etapa Aleatoria con uan variante aleatoria",
				"#Incluye todo piso desde el Sotano a El Vacio, Incluyendo el camino alternativo"
			}
		},
		[Item.APOCALYPSE.ID] = {
			Name = "Apocalipsis",
			Description = {
				"!!! Borra todo objeto pasivo y otorga 2 aumentos de estadisticas de los sigientes por cada objeto borrado:",
				"#{{Speed}} +0.05 Velocidad",
				"#{{Tears}} -0.5 Tear delay",
				"#{{Damage}} +1 Daño",
				"#{{Range}} +0.3 Rango",
				"#{{Shotspeed}} +0.1 Velocidad de Disparo",
				"#{{Luck}} +1 Suerte"
			}
		},
		[Item.ASTRAGALI.ID] = {
			Name = "Astragali",
			Description = {
				"Cambia los cofres en la habitacion por otras variantes de cofres"
			}
		},
		[Item.BEGINNERS_LUCK.ID] = {
			Name = "Suerte del Principiante",
			Description = {
				"↑ {{Luck}} +10 Suerte",
				"#Por cada habitacion sinb explorar en la que entre Isaac, {{Luck}} -1 Suerte hasta que se cancele la suerte dada por este objeto",
				"#Se reinicia al entrar a un nuevo piso"
			}
		},
		[Item.BINDS_OF_DEVOTION.ID] = {
			Name = "Vínculos de devoción",
			Description = {
				"{{Player19}} Genera a jacob como segundo jugador sin Esau",
				"#Cuando muere jacob elimina Vinculos de devoción y cualquier objeto que tenga",
			}
		},
		[Item.BLOOD_CYST.ID] = {
			Name = "Quiste de sangre",
			Description = {
				"Genera un quiste de sangre en un lugar al azar de una habitacion sin explorar",
				"#Dañarlo hara que explote, haciendo que genere una fuente de 20 lagrimas"
			}
		},
		[Item.BOOK_OF_AMBIT.ID] = {
			Name = "Libro de Ámbito",
			Description = {
				"{{Timer}} Recive por la habitacion:",
				"#↑ {{Range}} +5 Rango",
				"#↑ {{Shotspeed}} +1.5 Velocidad de Disparo",
				"# Lagrimas perforantes"
			}
		},
		[Item.BOOK_OF_BOOKS.ID] = {
			Name = "Libro de Libros",
			Description = {
				"Usa el efecto de un libro aleatorio"
			}
		},
		[Item.BOOK_OF_GUIDANCE.ID] = {
			Name = "Libro de la Orientación",
			Description = {
				"{{Collectible175}} Por el resto del piso, Todas las puertas estan desbloqueadas como si se usase la Llave de papa"
			}
		},
		[Item.BOOK_OF_LEVITICUS.ID] = {
			Name = "Libro de Levítico",
			Description = {
				function(descObj)
					return modifiers[Item.BOOK_OF_LEVITICUS.ID]._modifier(descObj)
				end
			}
		},
		[Item.BOOK_OF_SWIFTNESS.ID] = {
			Name = "Libro de la Rapidez",
			Description = {
				function(descObj)
					return modifiers[Item.BOOK_OF_SWIFTNESS.ID]._modifier(descObj)
				end
			}
		},
		[Item.BRUNCH.ID] = {
			Name = "Brunch",
			Description = {
				"↑ {{Heart}} +2 Contenedores de Corazon Vacios",
				"#{{HealingRed}} Cura 4 Corazones Rojos",
				"#↑ {{Shotspeed}} +0.16 Velocidad de Disparo",
			}
		},
		[Item.BUTTERFLY.ID] = {
			Name = "Mariposa",
			Description = {
				"Recibir daño hace que Isaac dispare lagrimas de 50% de su daño en direcciones aleatorias por 1 segundo"
			}
		},
		[Item.CADUCEUS_STAFF.ID] = {
			Name = "Baston del Caduceo",
			Description = {
				"5% de probabilidad de que el daño recibido no te quite vida y en vez te otorgue un {{Heart}} Corazon Rojo, {{SoulHeart}} Corazon De Alma, o medio de cada dependiendo de la vida de Isaac",
				"#Si el efecto no se activo se duplica la probabilidad de que se active en el futuro",
				"#La Probabilidad se reinicia a 5% cuando se activa el efecto"
			}
		},
		[Item.CARDIOMYOPATHY.ID] = {
			Name = "Cardiomiopatía",
			Description = {
				"{{Timer}} Recjoer un corazon que otorga {{Heart}} Vida roja tiene probabilidad de otorgar invencibilidad por un segundo",
				"#La probabilidad es un 25% por cada medi ocorazon que otorgaria (e.g. Un corazon entero 50%)"
			}
		},
		[Item.CERES.ID] = {
			Name = "Ceres?",
			Description = {
				"5% de probabilidad de disparar una lagriam verde que hace que el enemigo deje liquido verde por 3 segundos",
				"#{{Luck}} 50% de probabilidad con 9 Suerte",
				"#Hace 30 de daño por segundo a otros enemigos que toquen el liquido",
			}
		},
		[Item.CHIRON.ID] = {
			Name = "Quirón?",
			Description = {
				--Book of Secrets description
				"{{Timer}} Cada piso, otorga uno de estos efectos por el piso:#{{Collectible54}} Mapa del Tesoro#{{Collectible21}} Compas#{{Collectible246}} Mapa Azul",
				"#{{BossRoom}} Entering a boss room activates a random \"offensive\" book"
			}
		},
		[Item.CHI_RHO.ID] = {
			Name = "Chi Rho",
			Description = {
				"{{Collectible643}} 2% de probablidad de disparo un rayo sagrado mientras disparas",
				"#{{Luck}} 15% de probabilidad con 15 Suerte"
			}
		},
		[Item.COLD_HEARTED.ID] = {
			Name = "De Corazón frío",
			Description = {
				"{{Freezing}} Tocar enemigos los congela",
				"#{{Slow}} Tocar Jefes los realentiza por 5 segundos"
			}
		},
		[Item.COSMIC_OMNIBUS.ID] = {
			Name = "Ómnibus cósmico",
			Description = {
				"Transporta a isaac a uan habitacion especial sin explorar en el piso",
				"#{{Planetarium}} Si se exploraron todas las habitaciones especiales teletransporta a isaac a un planetario adicional",
				"#Usos posteriores teletransporta a Isaac a una habitacion especial al azar en el piso"
			}
		},
		[Item.CRAB_LEGS.ID] = {
			Name = "Patas de Cangrejo",
			Description = {
				"Caminar en una direcion perpendicular a la direcion en la que Isaac dispara otorga {{Speed}} +0.5 Velocidad"
			}
		},
		[Item.D16.ID] = {
			Name = "D16",
			Description = {
				"Cambia todos los corazones en la habitacion a otras variantes de corazon"
			}
		},
		[Item.D9.ID] = {
			Name = "D9",
			Description = {
				"Cambia todos los trinkets en la habitacion por otros"
			}
		},
		[Item.EPITAPH.ID] = {
			Name = "Epitafio",
			Description = {
				"{{Collectible545}} 10% de probabilidad de que los enemigos revivan como un orbvital de hueso o compañero esqueletico",
				"#Morir con este onjetp creara una tumba en una habitacion al azar en el mismo piso en la proxima run",
				"#{{Collectible}} Bombardear la tumba 3 veces Generara {{Coin}} 3-5 Monedas, {{Key}} 2-3 Llaves, El primer y ultimo objeto pasivo de la run anterior"
			}
		},
		[Item.EXSANGUINATION.ID] = {
			Name = "Desangramiento",
			Description = {
				"↑ Todo corazon otorga una mejora de {{Damage}} +0.05 Daño permanente",
				"#Los corazones generados tienen un 50% de probabilidad de parpadear y desaparecer tras 2 segundos"
			}
		},
		[Item.FIRSTBORN_SON.ID] = {
			Name = "Primogénito",
			Description = {
				"{{Collectible634}} Mientras estas en una habitacion sin completar se volvera un fantasma detonador que persigue a enemigos",
				"#Perseguira a los enemigos con las sigientes prioridades: No-jefes antes que jefes > Mayor Vida > El mas cercano al fantasma ",
				"#Mata instantaneamente al enemigo perseguido y no dañara a otros, Si es un ejfe solo dañara un 10% de su vida maxima"
			}
		},
		[Item.FLUX.ID] = {
			Name = "Flujo",
			Description = {
				"↑ Otorga {{Range}} +9.75 Rango y lagrimas espectrales",
				"#Las lagrimas solo se mueven cuando se mueve Isaac",
				"#Dispara lagrimas en la direcion opuesta que imitan el movimiento de Isaac",
			}
		},
		[Item.GOLDEN_PORT.ID] = {
			Name = "Puerto Dorado",
			Description = {
				"{{Battery}} Usar un objeeto activo sin cagar l ocargara compeltamente por 5 centimos",
				"#Solo funciona cuando el objeto no tiene cargas"
			}
		},
		[Item.HEART_EMBEDDED_COIN.ID] = {
			Name = "Moneda con corazón incrustado",
			Description = {
				"{{Coin}} Recoger {{Heart}} Corazones rojos mientras tengas la vida completa dara el valor de ese corazon en monedas"
			}
		},
		[Item.HEART_RENOVATOR.ID] = {
			Name = "Renueva Corazones",
			Description = {
				"Puedes recoger {{Heart}} Corazones rojos aun que tengas la vida maxima y los pondra en un contador especial que almacena hasta 99 de vida",
				"#!!! Pulsar dos veces {{ButtonRT}} Elimina 2 del contador y otorga un {{BrokenHeart}} Corazon Roto",
				"#↑ Al Usarlo, Elimina un corazon roto y otorga Permeantemente {{Damage}} +0.5 Daño"
			}
		},
		[Item.IRON.ID] = {
			Name = "Plancha",
			Description = {
				"Orbital",
				"#{{Collectible257}} Lagrimas amigables duplicaran su tamaño y daño y quemaran enemigos"
			}
		},
		[Item.ITCHING_POWDER.ID] = {
			Name = "Polvo de picapica",
			Description = {
				"Recivir daño hara daño falso u nsegundo mas tarde"
			}
		},
		[Item.JAR_OF_MANNA.ID] = {
			Name = "Jarra de Maná",
			Description = {
				"{{Battery}} Debe de cargarse con Orbes de Maná que son soltados por los enemigos Luego:",
				"#{{Collectible464}} Otorga lo que Isaac mas necesita",
				"#{{Collectible644}} Si Isaac ya esta satisfecho en Vida y Recolectables, Incrementa la estadistica mas baja de Velocidad, Lagrimas, Daño, Rango, Velocidad de disparo y Suerte"
			}
		},
		[Item.JUNO.ID] = {
			Name = "Juno?",
			Description = {
				"+2 {{SoulHeart}} Corazones de Alma",
				"#{{{Collectible722}} 3% de probabilidad de disparar uan lagrima que encadena a enemigos en el lugar por 2 segundos",
				"#{{Luck}} 25% chance at 11 luck"
			}
		},
		[Item.KARETH.ID] = {
			Name = "Kareth",
			Description = {
				"!!! Remplaza todos los pedestales con entre 1 y 3 trinkets dependiendo de la calidad del objeto",
				"#{{Quality0}}-{{Quality1}}: 1 trinket",
				"#{{Quality2}}: 2 trinkets",
				"#{{Quality3}}-{{Quality4}}: 3 trinkets"
			}
		},
		[Item.KERATOCONUS.ID] = {
			Name = "Queratocono",
			Description = {
				"↑ {{Range}} +2 Rango",
				"#↓ {{Shotspeed}} -0.15 Velocidad de Disparo",
				"#Enemigos lejanos a Isaac pareceran mas grandes de lo normal y seran mas similares a su tamaño original cuando esten cerca de Isaac",
				"#{{Slow}} Los enemigos seran relentizados dependiendo de su distancia a Isaac, Mas lejos significara un efecto mas fuerte"
			}
		},
		[Item.KEYS_TO_THE_KINGDOM.ID] = { --123 filigree feather
			Name = "Llaves al Reino",
			Description = {
				"#{{Timer}} Enemigps normales seran \"Perdonados\", desapareciendo y otorgando un aumento de estadisticas por el piso por cada enemigo perdonado",
				"#{{BossRoom}} Jefes seran perdonados despues de 30 segundos otorgando 3 aumentos de estadisticas al azar",
				"#{{Blank}} Recibir daño o hacer daño al jefe añadira un tercio del contador de nuevo",
				"#{{AngelRoom}} Perdona instantaneamente a angeles, Soltando una {{Collectible238}}{{Collectible239}} pieza de llave, y si ya tiene ambas otorga un {{ItemPoolAngel}}Objeto de la habticaion angel",
				"#{{DevilRoom}} Elimina todo pacto del diavlo de la habitacion, otorga un aumento de estadisticas permanente al azar por cada pacto eliminado"
			}
		},
		[Item.KEY_ALT.ID] = {
			Name = "Tecla Alt",
			Description = {
				"Reinicia el piso con una variante del camino Alternativo y si ya estas en el camino alternativo en una variante del camino normal"
			}
		},
		[Item.KEY_BACKSPACE.ID] = {
			Name = "Tecla Retroceso",
			Description = {
				"!!! Borra los 2 ultimos objetos pasivos y lo trae a el piso anterior",
				"#El piso es nuevamente generado pero mantiene la misma variante",
				"#!!! Solo se puede usar hasta 3 veces antes de desaparecer"
			}
		},
		[Item.KEY_C.ID] = {
			Name = "Tecla C",
			Description = {
				"{{Library}} Teletransporta a Isaac a una biblioteca con 5 libros",
			}
		},
		[Item.KEY_CAPS.ID] = {
			Name = "Caps Key",
			Description = {
				function(descObj)
					return modifiers[Item.KEY_CAPS.ID]._modifier(descObj)
				end
			}
		},
		[Item.KEY_E.ID] = {
			Name = "E Key",
			Description = {
				"{{GigaBomb}} Spawns a lit Giga Bomb"
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
			Description = {
				"Spawns a pool at the entrance of certain special rooms that reveal an alternate room",
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
				"↑ {{Tearsize}}+20% Tear size",
				"#{{Collectible529}} Isaac's tears bounce off the floor after floating for a short time",
				function(descObj)
					return modifiers[Item.PALLAS.ID]._modifier(descObj,
						"#{{Collectible540}} + Flat Stone: {{Damage}} +16% damage and {{Tearsize}} x2 Tear size"
					)
				end
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
				"#While active:",
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
				"#When coming into contact with another Polydipsia creep, increases its lifetime by 1 second",
				"#The creep will stay alive for "
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
				"↑ {{Damage}} +2 Damage",
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
				"#{{Collectible395}} Isaac's tears are replaced with small green piercing and spectral technology rings"
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
