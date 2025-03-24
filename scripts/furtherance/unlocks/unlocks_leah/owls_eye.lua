local Mod = Furtherance

local OWLS_EYE = {}

Furtherance.Item.OWLS_EYE = OWLS_EYE

OWLS_EYE.ID = Isaac.GetItemIdByName("Owl's Eye")

--TODO: Will revisit for tear modifier implementation

--[[ function Mod:OwlTear(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if player and player:HasCollectible(OWLS_EYE.ID) then
		local rng = player:GetCollectibleRNG(OWLS_EYE.ID)

		local chance = Mod:Clamp(player.Luck * 0.08 + 0.08, 0, 12)
		if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
			chance = 1 - (1 - chance) ^ 2
		end

		if rng:RandomFloat() <= chance then
			tear:ChangeVariant(TearVariant.CUPID_BLUE)
			tear.CollisionDamage = tear.CollisionDamage * 2

			local OwlColor = Color(1, 1, 1, 1, 0, 0, 0)
			OwlColor:SetColorize(3, 1, 0, 1)
			tear:SetColor(OwlColor, 0, 0, false, false)
			tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_HOMING)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Mod.OwlTear) ]]
