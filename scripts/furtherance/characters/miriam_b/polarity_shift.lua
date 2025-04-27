local Mod = Furtherance

local POLARITY_SHIFT = {}

Furtherance.Item.POLARITY_SHIFT = POLARITY_SHIFT

POLARITY_SHIFT.ID_1 = Isaac.GetItemIdByName("Polarity Shift")
POLARITY_SHIFT.ID_2 = Isaac.GetItemIdByName(" Polarity Shift")
POLARITY_SHIFT.SFX = Isaac.GetSoundIdByName("Polarity Shift Use")

---@param player EntityPlayer
function POLARITY_SHIFT:IsChainLightningActive(player)
	return player:GetActiveItem(ActiveSlot.SLOT_POCKET) == POLARITY_SHIFT.ID_2
end

---@param itemID CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param slot ActiveSlot
function POLARITY_SHIFT:OnSWUse(itemID, rng, player, useFlags, slot)
	if slot == ActiveSlot.SLOT_POCKET then
		if player:GetHearts() == 0 and itemID == POLARITY_SHIFT.ID_1 then
			return
		end
		if itemID == POLARITY_SHIFT.ID_1 then
			player:RemoveCollectible(itemID, true, slot)
			player:SetPocketActiveItem(POLARITY_SHIFT.ID_2, slot)
			Mod:GetData(player).FrameStartedPolarityShift = player.FrameCount
		else
			player:RemoveCollectible(itemID, true, ActiveSlot.SLOT_POCKET)
			player:SetPocketActiveItem(POLARITY_SHIFT.ID_1, ActiveSlot.SLOT_POCKET)
			Mod:GetData(player).FrameStartedPolarityShift = nil
		end
		player:AddCacheFlags(CacheFlag.CACHE_TEARCOLOR, true)
		Mod.SFXMan:Play(POLARITY_SHIFT.SFX)
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, POLARITY_SHIFT.OnSWUse, POLARITY_SHIFT.ID_1)
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, POLARITY_SHIFT.OnSWUse, POLARITY_SHIFT.ID_2)
