local Mod = Furtherance

local POLARITY_SHIFT = {}

Furtherance.Item.POLARITY_SHIFT = POLARITY_SHIFT

POLARITY_SHIFT.ID_1 = Isaac.GetItemIdByName("Polarity Shift")
POLARITY_SHIFT.ID_2 = Isaac.GetItemIdByName(" Polarity Shift")
POLARITY_SHIFT.SFX = Isaac.GetSoundIdByName("Polarity Shift Use")

POLARITY_SHIFT.MAX_CHARGES = Mod.ItemConfig:GetCollectible(POLARITY_SHIFT.ID_1).MaxCharges

local min = math.min

---@param player EntityPlayer
function POLARITY_SHIFT:IsChainLightningActive(player)
	return player:GetEffects():HasCollectibleEffect(POLARITY_SHIFT.ID_1) or Mod:GetData(player).FrameStartedPolarityShift ~= nil
end

---@param player EntityPlayer
function POLARITY_SHIFT:PolarityShfitNormal(_, _, player, _, _)
	for _, itemID in ipairs(Mod.Character.MIRIAM_B.SPIRITUAL_WOUND.INNATE_COLLECTIBLES) do
		if not player:HasCollectible(itemID, false, true) then
			player:AddInnateCollectible(itemID)
			local itemConfigItem = Mod.ItemConfig:GetCollectible(itemID)
			if not player:HasCollectible(itemID, true, true) then
				player:RemoveCostume(itemConfigItem)
			end
		end
	end
	Mod.SFXMan:Play(POLARITY_SHIFT.SFX)
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, POLARITY_SHIFT.PolarityShfitNormal, POLARITY_SHIFT.ID_1)

---@param player EntityPlayer
---@param itemConfig ItemConfigItem
function POLARITY_SHIFT:RemoveInnateItems(player, itemConfig)
	if itemConfig:IsCollectible() and itemConfig.ID == POLARITY_SHIFT.ID_1 then
		local INNATE_MAP = Mod:Set(Mod.Character.MIRIAM_B.SPIRITUAL_WOUND.INNATE_COLLECTIBLES)
		local spoofList = player:GetSpoofedCollectiblesList()

		for _, spoof in pairs(spoofList) do
			local itemID = spoof.CollectibleID
			if INNATE_MAP[itemID] and spoof.AppendedCount > 0 then
				player:AddInnateCollectible(itemID, -1)
				local itemConfigItem = Mod.ItemConfig:GetCollectible(itemID)
				if not player:HasCollectible(itemID, true, true) then
					player:RemoveCostume(itemConfigItem)
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, POLARITY_SHIFT.RemoveInnateItems)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function POLARITY_SHIFT:ChargeWithDamage(ent, amount, flags, source, countdown)
	local player = Mod:TryGetPlayer(source)
	if player then
		local slots = Mod:GetActiveItemCharges(player, POLARITY_SHIFT.ID_1)
		local hasBattery = player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY)
		local maxCharges = POLARITY_SHIFT.MAX_CHARGES
		if hasBattery then
			maxCharges = maxCharges * 2
		end
		for _, slotData in ipairs(slots) do
			if slotData.Charge < maxCharges then
				local damageDealt = min(ent.HitPoints, amount)
				player:SetActiveCharge(min(maxCharges, slotData.Charge + damageDealt), slotData.Slot)
				return
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, POLARITY_SHIFT.ChargeWithDamage)

---@param itemID CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param slot ActiveSlot
function POLARITY_SHIFT:PolarityShiftMiriam(itemID, rng, player, useFlags, slot)
	if slot == ActiveSlot.SLOT_POCKET then
		if player:GetHearts() == 0 then
			return
		end
		local data = Mod:GetData(player).FrameStartedPolarityShift
		if not data.FrameStartedPolarityShift then
			data.FrameStartedPolarityShift = player.FrameCount
		else
			data.FrameStartedPolarityShift = nil
		end
		Mod.SFXMan:Play(POLARITY_SHIFT.SFX)
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, POLARITY_SHIFT.PolarityShiftMiriam, POLARITY_SHIFT.ID_2)

HudHelper.RegisterHUDElement({
	ItemID = POLARITY_SHIFT.ID_2,
	OnRender = function (player, playerHUDIndex, hudLayout, position, alpha, scale)
		HudHelper.RenderHUDItem("gfx/items/polarity_shift_alt.png", position, scale, alpha)
	end
})