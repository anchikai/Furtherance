local Mod = Furtherance
local Trinket = Mod.Trinket

return function(modifiers)
    return {
        [Trinket.ABYSSAL_PENNY.ID] = {
            Name = "Moneda Abisal",
            Description = {
                "Recoger una moneda genera un fluido dañino que inflige 40 de daño por segundo",
                "#El tamaño varía dependiendo del valor de la moneda"
            }
        },
        [Trinket.ALABASTER_SCRAP.ID] = {
            Name = "Chatarra de Alabastro",
            Description = {
                "↑ {{Damage}} +0.5 de daño por cada objeto que cuente para la transformación {{Seraphim}} Serafín"
            }
        },
        [Trinket.ALMAGEST_SCRAP.ID] = {
            Name = "Chatarra de Almagesto",
            Description = {
                "{{Planetarium}} Las habitaciones del tesoro se convierten en planetarios",
                "#{{BrokenHeart}} Los objetos dentro otorgan corazones rotos",
                function(descObj)
                    return modifiers[Trinket.ALMAGEST_SCRAP.ID]._modifier(descObj,
                        "Los objetos dentro son gratuitos"
                    )
                end
            }
        },
        [Trinket.ALTRUISM.ID] = {
            Name = "Altruismo",
            Description = {
                "25% de probabilidad de curar a Isaac {{HalfHeart}} medio corazón rojo o devolver el precio pagado a un mendigo"
            }
        },
        [Trinket.BI_84.ID] = {
            Name = "BI-84",
            Description = {
                "{{Collectible68}} 25% de probabilidad de obtener un objeto coleccionable relacionado con tecnología por habitación",
            }
        },
        [Trinket.CRINGE.ID] = {
            Name = "Cringe",
            Description = {
                "{{Petrify}} Petrifica a todos los enemigos en la habitación durante 2 segundos al recibir daño",
                "#Cambia el sonido al recibir daño por \"Bruh\""
            }
        },
        [Trinket.DUNGEON_KEY.ID] = {
            Name = "Llave de Mazmorra",
            Description = {
                "Las habitaciones de desafío estarán abiertas sin importar la vida de Isaac"
            }
        },
        [Trinket.ESCAPE_PLAN.ID] = {
            Name = "Plan de Escape",
            Description = {
                "Recibir daño tiene un 10% de probabilidad de teletransportar a Isaac a la habitación inicial"
            }
        },
        [Trinket.GLITCHED_PENNY.ID] = {
            Name = "Moneda Glitcheada",
            Description = {
                "Recoger una moneda tiene un 25% de probabilidad de activar un objeto activo aleatorio",
                "#{{Battery}} Solo utiliza objetos de {{TreasureRoom}} habitaciones del tesoro con más de 1 carga",
            }
        },
        [Trinket.GRASS.ID] = {
            Name = "Hierba",
            Description = {
                "Reemplaza las decoraciones de la habitación con hierba",
                "#Caminar sobre hierba otorga {{Speed}} +0.05 de velocidad por habitación"
            }
        },
        [Trinket.HAMMERHEAD_WORM.ID] = {
            Name = "Gusano Cabeza de Martillo",
            Description = {
                "Las lágrimas de Isaac obtienen rango, daño y velocidad de disparo ligeramente aleatorizados"
            }
        },
        [Trinket.HOLY_HEART.ID] = {
            Name = "Corazón Sagrado",
            Description = {
                "Recoger un corazón negro, de alma o eterno otorga un {{Collectible313}} escudo del manto sagrado",
                "#{{HalfSoulHeart}} Medio corazón de alma o corazones mezclados solo tienen un 50% de probabilidad de otorgarlo",
            }
        },
        [Trinket.LEAHS_LOCK.ID] = {
            Name = "Cerradura de Leah",
            Description = {
                "25% de probabilidad de disparar lágrimas con efecto de {{Charm}} Encanto o {{Fear}} Miedo",
                "#{{Luck}} 50% de probabilidad con 10 de suerte",
                function(descObj)
                    local funy = modifiers[Trinket.LEAHS_LOCK.ID]._modifier(descObj,
                        "Ambos efectos pueden activarse a la vez"
                    )
                    return funy
                end
            }
        },
        [Trinket.LEVIATHANS_TENDRIL.ID] = {
            Name = "Zarcillo del Leviatán",
            Description = function(descObj)
                return modifiers[Trinket.LEVIATHANS_TENDRIL.ID]._modifier(descObj, {
                        "%s de probabilidad de desviar proyectiles lejos de Isaac, otorgando persecución y velocidad aumentada",
                        "#{{Fear}} %s de probabilidad de infligir Miedo a los enemigos cercanos",
                    },
                    "#{{Leviathan}} +5% de probabilidad adicional para cada efecto"
                )
            end
        },
        [Trinket.NIL_NUM.ID] = {
            Name = "Número Nulo",
            Description = {
                "2% de probabilidad de destruirse y crear un clon de un objeto pasivo en el inventario de Isaac"
            }
        },
        [Trinket.PARASOL.ID] = {
            Name = "Parasol",
            Description = {
                "Todos los familiares de Isaac bloquean proyectiles"
            }
        },
        [Trinket.REBOUND_WORM.ID] = {
            Name = "Gusano de Rebote",
            Description = {
                "Las lágrimas rebotan en las paredes y obstáculos, disparando al enemigo más cercano dentro del rango"
            }
        },
        [Trinket.SALINE_SPRAY.ID] = {
            Name = "Spray Salino",
            Description = {
                "{{Collectible596}} 5% de probabilidad de disparar lágrimas congelantes",
                "#{{Luck}} 100% de probabilidad con 10 de suerte",
            }
        },
        [Trinket.WORMWOOD_LEAF.ID] = {
            Name = "Hoja de Ajenjo",
            Description = {
                "10% de probabilidad de negar daño y convertir a Isaac en una estatua inmóvil durante 2 segundos",
                "#Otorga medio segundo de invencibilidad después del efecto"
            }
        },
    }
end
