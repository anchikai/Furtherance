local Mod = Furtherance

return function(modifiers)
	return {
		[Mod.PlayerType.LEAH] = {
			Name = "Leah",
			Description = {
				"{{Tears}} +0.2 Tears for every {{BrokenHeart}} Broken Heart"
			}
		},
		[Mod.PlayerType.PETER] = {
			Name = "Peter",
			Description = {
				"{{Battery}} {{SoulHeart}} Soul/Black Hearts will instead charge {{Collectible" ..
				Mod.Item.KEYS_TO_THE_KINGDOM.ID ..
				"}} Keys to the Kingdom instead of Peter's health if it still needs charges"
			}
		},
		[Mod.PlayerType.MIRIAM] = {
			Name = "Miriam",
			Description = {
				"Every 12 tears, a whirlpool will spawn where the tear landed. It sucks enemies into it in a spiral motion, dealing constant damage",
				"#Whirlpool lasts 2 seconds"
			}
		},
		[Mod.PlayerType.LEAH_B] = {
			Name = "Tainted Leah",
			Description = {
				"{{EmptyHeart}} Maximum of 24 heart containers",
				"#{{BrokenHeart}} Health above one heart will be slowly be replaced with Broken Hearts, 1 every 20 seconds",
				"#↑ All stats up for every Half Red Heart Leah has",
				"#{{SoulHeart}} Soul/Black Hearts are replaced with Red Hearts"
			}
		},
		[Mod.PlayerType.PETER_B] = {
			Name = "Tainted Peter",
			Description = {
				"Permanent water rooms",
				"#Peter and non-boss enemies exist separately between the water",
				"#Walking below an enemy will submerge them. They gain {{StrengthStatus}} Strength, taking 25% less damage",
				"#{{Collectible" ..
				Mod.Item.MUDDLED_CROSS.ID ..
				"}} On use: Flips the room. Enemies and players swap sides for 5 + (X * 2.5) seconds, where X is the number of submerged enemies",
				"#{{Timer}} While room is flipped:",
				"#Cannot submerge enemies",
				"#{{Weakness}} Weakness instead of Strength"
			}
		},
		[Mod.PlayerType.MIRIAM_B] = {
			Name = "Tainted Miriam",
			Description = {
				"{{BoneHeart}} Heart containers converted to Bone Hearts",
				"#{{SoulHeart}} Can't have Soul Hearts",
				"#Spiritual Wound: Rapidly fire a wide arc of short homing lasers.",
				"#{{ArrowDown}} Has a small delay to how often it damages an enemy",
				"#{{ArrowDown}} Damage dealt decreases with distance",
				"#{{Fear}} Fear aura that increases in size with {{Heart}} Red Hearts",
				"#{{HealingRed}} Heal a Half Red Heart after dealing enough damage",
			}
		},
	}
end
