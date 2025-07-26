Furtherance.CollectibleDamageMultipliers = {
	[CollectibleType.COLLECTIBLE_MEGA_MUSH] = function(player)
		if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then return 1 end
		return 4
	end,
	[CollectibleType.COLLECTIBLE_CRICKETS_HEAD] = 1.5,
	[CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM] = function(player)
		-- Cricket's Head/Blood of the Martyr/Magic Mushroom don't stack with each other
		if player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_HEAD) then return 1 end
		return 1.5
	end,
	[CollectibleType.COLLECTIBLE_BLOOD_OF_THE_MARTYR] = function(player)
		if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL) then return 1 end

		-- Cricket's Head/Blood of the Martyr/Magic Mushroom don't stack with each other
		if
			player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_HEAD)
				or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM)
		then
			return 1
		end
		return 1.5
	end,
	[CollectibleType.COLLECTIBLE_POLYPHEMUS] = 2,
	[CollectibleType.COLLECTIBLE_SACRED_HEART] = 2.3,
	[CollectibleType.COLLECTIBLE_EVES_MASCARA] = 2,
	[CollectibleType.COLLECTIBLE_ODD_MUSHROOM_THIN] = 0.9,
	[CollectibleType.COLLECTIBLE_20_20] = 0.75,
	[CollectibleType.COLLECTIBLE_EVES_MASCARA] = 2,
	[CollectibleType.COLLECTIBLE_SOY_MILK] = function(player)
		-- Almond Milk overrides Soy Milk
		if player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then return 1 end
		return 0.2
	end,
	[CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT] = function(player)
		if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT) then return 2 end
		return 1
	end,
	[CollectibleType.COLLECTIBLE_ALMOND_MILK] = 0.33,
	[CollectibleType.COLLECTIBLE_IMMACULATE_HEART] = 1.2,
}
