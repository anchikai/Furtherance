local Mod = Furtherance

local ESSENCE_OF_HATE = {}

Furtherance.Rune.ESSENCE_OF_HATE = ESSENCE_OF_HATE

ESSENCE_OF_HATE.ID = Isaac.GetCardIdByName("Essence of Hate")

ESSENCE_OF_HATE.MAX_BROKEN_HEARTS = 11

--TODO: To be reworked. Requires Love Teller implementation

---@param player EntityPlayer
function ESSENCE_OF_HATE:OnUse(_, player, _)
	local brokenHearts = player:GetBrokenHearts()
	local numToAdd = ESSENCE_OF_HATE.MAX_BROKEN_HEARTS - brokenHearts
	player:AddBrokenHearts(ESSENCE_OF_HATE.MAX_BROKEN_HEARTS - brokenHearts)
	local room = Mod.Room()
	for _ = 1, numToAdd do
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_NULL, NullPickupSubType.ANY,
			room:FindFreePickupSpawnPosition(player.Position, 40), Vector.Zero, player)
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, ESSENCE_OF_HATE.OnUse, ESSENCE_OF_HATE.ID)
