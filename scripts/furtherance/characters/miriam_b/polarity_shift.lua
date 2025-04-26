local Mod = Furtherance

local POLARITY_SHIFT = {}

Furtherance.Item.POLARITY_SHIFT = POLARITY_SHIFT

POLARITY_SHIFT.ID_1 = Isaac.GetItemIdByName("Polarity Shift (Spiritual Wound)")
POLARITY_SHIFT.ID_2 = Isaac.GetItemIdByName("Polarity Shift (Chain Lightning)")
POLARITY_SHIFT.SFX = Isaac.GetSoundIdByName("Polarity Shift Use")

---@param player EntityPlayer
function POLARITY_SHIFT:ChainLightningActive(player)
	return player:GetActiveItem(ActiveSlot.SLOT_POCKET) == POLARITY_SHIFT.ID_2
end

---@param itemID CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param slot ActiveSlot
function POLARITY_SHIFT:OnSWUse(itemID, rng, player, useFlags, slot)
	if slot == ActiveSlot.SLOT_POCKET then
		Mod:DelayOneFrame(function()
			player:RemoveCollectible(itemID, true, slot)
			player:SetPocketActiveItem(POLARITY_SHIFT.ID_2, slot)
			player:FullCharge(ActiveSlot.SLOT_POCKET, true)
			player:SetActiveCharge(player:GetActiveCharge(ActiveSlot.SLOT_POCKET) - 1, ActiveSlot.SLOT_POCKET)
			player:AddCacheFlags(CacheFlag.CACHE_TEARCOLOR, true)
		end)
		Mod.SFXMan:Play(POLARITY_SHIFT.SFX)
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, POLARITY_SHIFT.OnSWUse, POLARITY_SHIFT.ID_1)

---@param player EntityPlayer
function POLARITY_SHIFT:DrainChainLightning(player)
	if POLARITY_SHIFT:ChainLightningActive(player) then
		local charge = player:GetActiveCharge(ActiveSlot.SLOT_POCKET)
		if charge > 0 then
			player:SetActiveCharge(charge - 1, ActiveSlot.SLOT_POCKET)
		end
		if player:GetActiveCharge(ActiveSlot.SLOT_POCKET) == 0 then
			player:RemoveCollectible(POLARITY_SHIFT.ID_2, true, ActiveSlot.SLOT_POCKET)
			player:SetPocketActiveItem(POLARITY_SHIFT.ID_1, ActiveSlot.SLOT_POCKET)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, POLARITY_SHIFT.DrainChainLightning, Mod.PlayerType.MIRIAM_B)