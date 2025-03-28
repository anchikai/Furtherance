local Mod = Furtherance

local CAPS_KEY = {}

Furtherance.Item.KEY_CAPS = CAPS_KEY

CAPS_KEY.ID = Isaac.GetItemIdByName("Caps Key")

---@param player EntityPlayer
function CAPS_KEY:OnUse(_, _, player, slot, data)
	player:UseCard(Card.CARD_HUGE_GROWTH, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, CAPS_KEY.OnUse, CAPS_KEY.ID)
