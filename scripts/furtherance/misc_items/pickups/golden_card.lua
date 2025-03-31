local Mod = Furtherance

local GOLDEN_CARD = {}

Furtherance.Card.GOLDEN_CARD = GOLDEN_CARD

GOLDEN_CARD.ID = Isaac.GetCardIdByName("Golden Card")

--2.5%
GOLDEN_CARD.REPLACE_CHANCE = 0.025

---@param entType EntityType
---@param variant PickupVariant
---@param subtype integer
---@param position Vector
---@param spawner Entity
---@param seed integer
function GOLDEN_CARD:SpawnGoldenCard(entType, variant, subtype, position, _, spawner, seed)
	if entType == EntityType.ENTITY_PICKUP
		and variant == PickupVariant.PICKUP_TAROTCARD
		and subtype ~= GOLDEN_CARD.ID
		and Mod.ItemConfig:GetCard(subtype)
		and Mod.ItemConfig:GetCard(subtype):IsCard()
	then
		local floor_save = Mod:FloorSave()
		floor_save.CheckedGoldenCard = floor_save.CheckedGoldenCard or {}
		local key = tostring(seed)
		if floor_save.CheckedGoldenCard[key] then
			return
		end
		if (spawner and spawner:ToPlayer()) then
			floor_save.CheckedGoldenCard[key] = true
			return
		end
		local gridEnt = Mod.Room():GetGridEntityFromPos(position)
		if gridEnt and gridEnt:GetType() == GridEntityType.GRID_ROCK_ALT2 and subtype == Card.CARD_FOOL then
			floor_save.CheckedGoldenCard[key] = true
			return
		end
		local rng = RNG(seed)
		if rng:RandomFloat() <= GOLDEN_CARD.REPLACE_CHANCE then
			return {entType, variant, GOLDEN_CARD.ID, seed}
		else
			floor_save.CheckedGoldenCard[key] = true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, GOLDEN_CARD.SpawnGoldenCard)

---@param card Card
---@param player EntityPlayer
---@param flags UseFlag
function GOLDEN_CARD:OnUse(card, player, flags)
	local rng = player:GetCardRNG(card)
	if rng:RandomFloat() <= 0.5 then
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
