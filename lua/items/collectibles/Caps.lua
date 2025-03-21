local mod = Furtherance

---@param player EntityPlayer
function mod:UseCaps(_, _, player, slot, data)
	player:UseCard(Card.CARD_HUGE_GROWTH, UseFlag.USE_NOANIM)
	SFXManager():Stop(SoundEffect.SOUND_HUGE_GROWTH)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseCaps, CollectibleType.COLLECTIBLE_CAPS_KEY)