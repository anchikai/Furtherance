local Mod = Furtherance

---@param player EntityPlayer
function Mod:UseCaps(_, _, player, slot, data)
	player:UseCard(Card.CARD_HUGE_GROWTH, UseFlag.USE_NOANIM)
	SFXManager():Stop(SoundEffect.SOUND_HUGE_GROWTH)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseCaps, CollectibleType.COLLECTIBLE_CAPS_KEY)
