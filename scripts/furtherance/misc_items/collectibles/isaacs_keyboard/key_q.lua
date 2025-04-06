local Mod = Furtherance

local Q_KEY = {}

Furtherance.Item.KEY_Q = Q_KEY

Q_KEY.ID = Isaac.GetItemIdByName("Q Key")

---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
function Q_KEY:OnUse(_, rng, player, flags, slot)
	if (player:GetCard(0) == Card.CARD_QUESTIONMARK) then
		player:SetCard(0, Card.CARD_NULL)
		if Mod.Item.SPACEBAR_KEY:IsEndStage() then
			Isaac.Spawn(EntityType.ENTITY_SHOPKEEPER, 2, 0, player.Position, Vector.Zero, nil)
		else
			Mod.Game:StartRoomTransition(Mod.Level():QueryRoomTypeIndex(RoomType.ROOM_ERROR, false, rng), Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)
		end
	else
		local pocketItem = player:GetPocketItem(PillCardSlot.PRIMARY)
		local ID = pocketItem:GetSlot()
		if ID == 0 then return true end
		local mimicCharge = 0
		if pocketItem:GetType() == PocketItemType.ACTIVE_ITEM then
			local itemConfig = Mod.ItemConfig:GetCollectible(ID)
			if itemConfig.ChargeType == ItemConfig.CHARGE_SPECIAL then
				return {Discharge = false, ShowAnim = false, Remove = false}
			elseif itemConfig.ChargeType == ItemConfig.CHARGE_TIMED then
				mimicCharge = 1
			else
				mimicCharge = itemConfig.MaxCharges
			end
			player:UseActiveItem(player:GetActiveItem(ID), UseFlag.USE_MIMIC, ID)
		elseif pocketItem:GetType() == PocketItemType.PILL then
			local pillEffect = Mod.Game:GetItemPool():GetPillEffect(ID, player)
			local pillConfig = Mod.ItemConfig:GetPillEffect(pillEffect)
			if not pillEffect == PillEffect.PILLEFFECT_NULL
				or not pillConfig
				or not pillConfig.MimicCharge
				or pillConfig.MimicCharge <= 0
			then
				mimicCharge = 1
			else
				mimicCharge = pillConfig.MimicCharge
			end
			player:UsePill(pillEffect, ID, UseFlag.USE_MIMIC)
		elseif pocketItem:GetType() == PocketItemType.CARD then
			local cardConfig = Mod.ItemConfig:GetPillEffect(ID)
			if not cardConfig.MimicCharge
				or cardConfig.MimicCharge <= 0
			then
				mimicCharge = 1
			else
				mimicCharge = cardConfig.MimicCharge
			end
			player:UseCard(ID, UseFlag.USE_MIMIC)
		end
		if Mod:HasBitFlags(flags, UseFlag.USE_OWNED)
			and slot ~= -1
			and player:GetActiveItem(slot) == Q_KEY.ID
		then
			player:SetActiveVarData(mimicCharge, slot)
		end
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Q_KEY.OnUse, Q_KEY.ID)

function Q_KEY:MimicCharge(itemID, player, varData, currentMax)
	return varData == 0 and 6 or varData
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, Q_KEY.MimicCharge, Q_KEY.ID)