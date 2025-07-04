local Mod = Furtherance
local Item = Mod.Item

return function(modifiers)
	return {
		[Mod.PlayerType.LEAH] = {
			Name = "Leah",
			Description = {
				"{{ArrowUp}} {{Damage}} Damage bonus from {{Collectible" .. Item.HEART_RENOVATOR.ID .. "}} is doubled",
				"#Killing 20 enemies activates a normal damage bonus Heart Renovator effect"
			}
		},
		[Mod.PlayerType.PETER] = {
			Name = "Peter",
			Description = {
				"Time to spare bosses reduced from 30 seconds to 15 seconds"
			}
		},
		[Mod.PlayerType.MIRIAM] = {
			Name = "Miriam",
			Description = {
				"Increased knockback",
				"#Whirlpools spawn every 8 tears",
				"#Increased tear knockback"
			}
		},
		[Mod.PlayerType.LEAH_B] = {
			Name = "Tainted Leah",
			Description = {
				"20% chance to upgrade any spawned {{Heart}} Red Hearts",
				"#Enemies that collide with the specially dropped Scared Hearts will have it also act like it was collected by Isaac",
				"#{{Collectible" .. Item.SHATTERED_HEART.ID .. "}} double damage of exploded hearts"
			}
		},
		[Mod.PlayerType.PETER_B] = {
			Name = "Tainted Peter",
			Description = {
				"Provides bonuses to flipped special rooms",
				"#{{TreasureRoom}} {{RedTreasureRoom}} : Allows two items to choose from",
				"#{{Planetarium}} : Planetarium items no longer grant broken hearts",
				"#{{Library}} : Library books no longer cost money",
				"#{{Shop}} : {{Player33}} Tainted Keeper-style shops",
				"#{{DevilRoom}} : One item can be taken for free without removing the others",
				"#{{AngelRoom}} : {{Collectible64}} Steam Sale effect",
			}
		},
		[Mod.PlayerType.MIRIAM_B] = {
			Name = "Tainted Miriam",
			Description = {
				"Spiritual Wound becomes Death Field",
				"#Damage cooldown from Death Field is as fast as Chain Lightning",
				"#Chain Lightning deals {{Damage}} x1.5 Damage to enemies inflicted with {{Fear}} Fear",
				"#Health drains at half the rate while Chain Lightning is active"
			}
		},
	}
end
