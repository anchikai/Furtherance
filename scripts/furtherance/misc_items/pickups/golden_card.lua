local Mod = Furtherance

local GOLDEN_CARD = {}

Furtherance.Card.GOLDEN_CARD = GOLDEN_CARD

GOLDEN_CARD.ID = Isaac.GetCardIdByName("Golden Card")
GOLDEN_CARD.REMOVAL_CHANCE = 0.5

---@param card Card
---@param player EntityPlayer
---@param flags UseFlag
function GOLDEN_CARD:OnUse(card, player, flags)
	local rng = player:GetCardRNG(card)
	if rng:RandomFloat() <= GOLDEN_CARD.REMOVAL_CHANCE then
		if Mod:HasBitFlags(flags, UseFlag.USE_OWNED) then
			player:AddCard(card)
		end
	end
	local newCard = Mod.Game:GetItemPool():GetCard(rng:GetSeed(), true, false, false)
	player:UseCard(newCard, UseFlag.USE_NOANIM)
	local name = Mod:TryGetTranslatedString("PocketItems", Mod.ItemConfig:GetCard(newCard).Name)
	Mod.HUD:ShowItemText(name)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, GOLDEN_CARD.OnUse, GOLDEN_CARD.ID)
