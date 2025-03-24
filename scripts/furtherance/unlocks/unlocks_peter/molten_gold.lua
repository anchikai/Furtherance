local Mod = Furtherance

local MOLTEN_GOLD = {}

Furtherance.Item.MOLTEN_GOLD = MOLTEN_GOLD

MOLTEN_GOLD.ID = Isaac.GetItemIdByName("Molten Gold")

MOLTEN_GOLD.ACTIVATION_CHANCE = 0.25
MOLTEN_GOLD.USE_FLAGS = UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOCOSTUME | UseFlag.USE_ALLOWWISPSPAWN

---@param entity Entity
function MOLTEN_GOLD:RandomRune(entity)
	local player = entity:ToPlayer()
	if player and player:HasCollectible(MOLTEN_GOLD.ID) then
		local rng = player:GetCollectibleRNG(MOLTEN_GOLD.ID)
		if rng:RandomFloat() <= 0.25 then
			player:UseCard(Mod.Game:GetItemPool():GetCard(rng:GetSeed(), false, true, true), MOLTEN_GOLD.USE_FLAGS)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, MOLTEN_GOLD.RandomRune, EntityType.ENTITY_PLAYER)
