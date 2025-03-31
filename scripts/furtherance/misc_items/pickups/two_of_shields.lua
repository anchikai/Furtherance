local Mod = Furtherance

local TWO_OF_SHIELDS = {}

Furtherance.Item.TWO_OF_SHIELDS = TWO_OF_SHIELDS

TWO_OF_SHIELDS.ID = Isaac.GetCardIdByName("Two of Shields")

---@param player EntityPlayer
function TWO_OF_SHIELDS:UseAceOfShields(_, player, _)
	for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
		if player:GetActiveItem(slot) ~= CollectibleType.COLLECTIBLE_NULL
			and player:NeedsCharge(slot)
		then
			local charge = player:GetActiveCharge(slot)
			player:AddActiveCharge(charge == charge and 2 or charge * 2, slot, true, false, false)
			break
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, TWO_OF_SHIELDS.UseAceOfShields, TWO_OF_SHIELDS.ID)
