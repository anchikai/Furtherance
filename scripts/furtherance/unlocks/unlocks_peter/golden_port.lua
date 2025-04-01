local Mod = Furtherance

local GOLDEN_PORT = {}

Furtherance.Item.GOLDEN_PORT = GOLDEN_PORT

GOLDEN_PORT.ID = Isaac.GetItemIdByName("Golden Port")

---@param player EntityPlayer
function GOLDEN_PORT:OnDischargedUse(player)
	local usedActive = Input.IsActionPressed(ButtonAction.ACTION_ITEM, player.ControllerIndex)
	local activeItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
	if player:HasCollectible(GOLDEN_PORT.ID)
		and activeItem ~= 0
		and player:NeedsCharge(ActiveSlot.SLOT_PRIMARY) --Always false for special-chargetype actives
		and player:GetNumCoins() >= 5
		and player:IsExtraAnimationFinished()
		and usedActive
	then
		player:AddCoins(-5)
		player:AddActiveCharge(6, ActiveSlot.SLOT_PRIMARY, true, true, false)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, GOLDEN_PORT.OnDischargedUse, PlayerVariant.PLAYER)
