local Mod = Furtherance

return function(modifiers)
	return {
		[Mod.Pill.HEARTACHE.ID_UP] = {
			Name = "Más Dolor de Corazón",
			Description = {
				"↓ {{BrokenHeart}} +1 Corazón Roto"
			}

		},
		[Mod.Pill.HEARTACHE.ID_DOWN] = {
			Name = "Menos Dolor de Corazón",
			Description = {
				"↑ {{BrokenHeart}} -1 Corazón Roto"
			}

		},
	}
end
