local Mod = Furtherance

function Mod:SunscreenDamage(entity, amount, flag)
	local player = entity:ToPlayer()
	if player:HasCollectible(CollectibleType.COLLECTIBLE_SUNSCREEN) and flag & DamageFlag.DAMAGE_FIRE == DamageFlag.DAMAGE_FIRE then
		player:ResetDamageCooldown()
		player:SetMinDamageCooldown(60)
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.SunscreenDamage, EntityType.ENTITY_PLAYER)
