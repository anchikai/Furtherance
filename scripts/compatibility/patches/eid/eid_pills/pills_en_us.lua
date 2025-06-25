local Mod = Furtherance

return function(modifiers)
	return {
		[Mod.Pill.HEARTACHE.ID_UP] = {
			Name = "Heartache Up",
			Description = {
				"↓ {{BrokenHeart}} +1 Broken Heart"
			}

		},
		[Mod.Pill.HEARTACHE.ID_DOWN] = {
			Name = "Heartache Down",
			Description = {
				"↑ {{BrokenHeart}} -1 Broken Heart"
			}

		},
	}
end
