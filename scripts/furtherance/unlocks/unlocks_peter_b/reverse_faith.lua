local Mod = Furtherance

local REVERSE_FAITH = {}

Furtherance.Card.REVERSE_FAITH = REVERSE_FAITH

REVERSE_FAITH.ID = Isaac.GetCardIdByName("ReverseFaith")

function REVERSE_FAITH:UseReverseFaith(card, player, flag)
	local room = Mod.Room()
	for _ = 1, 2 do
		Mod.Spawn.Heart(Mod.Pickup.MOON_HEART.ID, room:FindFreePickupSpawnPosition(player.Position, 40), nil, player)
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, REVERSE_FAITH.UseReverseFaith, REVERSE_FAITH.ID)
