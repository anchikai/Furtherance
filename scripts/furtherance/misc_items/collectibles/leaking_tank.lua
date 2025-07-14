local Mod = Furtherance
local max = Mod.math.max

local LEAKING_TANK = {}

Furtherance.Item.LEAKING_TANK = LEAKING_TANK

LEAKING_TANK.ID = Isaac.GetItemIdByName("Leaking Tank")

LEAKING_TANK.MAX_EMPTY_HEALTH_PROC = 12 --6 hearts, 2 units = 1 heart
LEAKING_TANK.MINIMUM_CHANCE = 0.16


---@param player EntityPlayer
function LEAKING_TANK:Leaking(player)
	if not player:HasCollectible(LEAKING_TANK.ID) then return end

	local rng = player:GetCollectibleRNG(LEAKING_TANK.ID)
	if rng:RandomFloat() <= max(LEAKING_TANK.MINIMUM_CHANCE, (player:GetEffectiveMaxHearts() - player:GetHearts()) / LEAKING_TANK.MAX_EMPTY_HEALTH_PROC) then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, player.Position, Vector.Zero,
			player)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, LEAKING_TANK.Leaking)
