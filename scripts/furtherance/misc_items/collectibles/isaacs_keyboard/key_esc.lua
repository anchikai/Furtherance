local Mod = Furtherance

local ESC_KEY = {}

Furtherance.Item.KEY_ESC = ESC_KEY

ESC_KEY.ID = Isaac.GetItemIdByName("Esc Key")

---@param rng RNG
---@param player EntityPlayer
function ESC_KEY:UseEsc(_, rng, player, slot, data)
	local level = Mod.Level()
	local stage = level:GetStage()

	if (stage == LevelStage.STAGE8) then
		player:UseCard(Card.CARD_FOOL)
	else
		local randomRoom = level:QueryRoomTypeIndex(RoomType.ROOM_DEFAULT, false, rng)
		level.LeaveDoor = -1
		Mod.Game:StartRoomTransition(randomRoom, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)
	end
	player:AddCollectible(CollectibleType.COLLECTIBLE_DOGMA)
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_DOGMA)
	player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
	return {Discharge = true, Remove = true, ShowAnim = false}
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, ESC_KEY.UseEsc, ESC_KEY.ID)
