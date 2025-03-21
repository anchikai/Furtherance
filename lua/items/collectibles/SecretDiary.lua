local mod = Furtherance

function mod:UseSecretDiary(_, _, player)
	player:AddItemWisp(CollectibleType.COLLECTIBLE_BIRTHRIGHT, Vector(999999, 999999), false)
	return true
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseSecretDiary, CollectibleType.COLLECTIBLE_SECRET_DIARY)

function mod:RemoveWisp(player)
	--IsPaused() returns true on update callbacks right before doing a room transition
	--Unfortunately TemporaryEffects are still cleared when this happens. I'll probably wanna use HiddenItemManager for this later anyways
	if Game():IsPaused() then
		for _, wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP, CollectibleType.COLLECTIBLE_BIRTHRIGHT)) do
			if GetPtrHash(player) == GetPtrHash(wisp:ToFamiliar().Player) then
				wisp:Remove()
				wisp:Kill()
				break
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.RemoveWisp)
