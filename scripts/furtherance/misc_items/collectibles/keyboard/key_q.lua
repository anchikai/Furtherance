local Mod = Furtherance

local Q_KEY = {}

Furtherance.Item.KEY_Q = Q_KEY

Q_KEY.ID = Isaac.GetItemIdByName("Q Key")

---@param rng RNG
---@param player EntityPlayer
function Q_KEY:OnUse(_, rng, player)
	if (player:GetCard(0) == Card.CARD_QUESTIONMARK) then
		player:SetCard(0, Card.CARD_NULL)
		Mod.Game:StartRoomTransition(Mod.Level():QueryRoomTypeIndex(RoomType.ROOM_ERROR, false, rng),
			Direction.NO_DIRECTION, 3)
	else
		local pocketItem = player:GetPocketItem(PillCardSlot.PRIMARY)
		local ID = pocketItem:GetSlot()
		if ID == 0 then return end
		if pocketItem:GetType() == PocketItemType.ACTIVE_ITEM then
			player:UseActiveItem(player:GetActiveItem(ID), UseFlag.USE_MIMIC, ID)
		elseif pocketItem:GetType() == PocketItemType.PILL then
			player:UsePill(Mod.Game:GetItemPool():GetPillEffect(ID, player), ID, UseFlag.USE_MIMIC)
		elseif pocketItem:GetType() == PocketItemType.CARD then
			player:UseCard(ID, UseFlag.USE_MIMIC)
		end
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Q_KEY.OnUse, Q_KEY.ID)
