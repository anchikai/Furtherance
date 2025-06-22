local Mod = Furtherance

local ESSENCE_OF_HATE = {}

Furtherance.Rune.ESSENCE_OF_HATE = ESSENCE_OF_HATE

ESSENCE_OF_HATE.ID = Isaac.GetCardIdByName("Essence of Hate")

---@param player EntityPlayer?
local function spawnExplodingHeart(player)
	local room = Mod.Room()
	local heart = Mod.Spawn.Heart(HeartSubType.HEART_FULL,
		room:FindFreeTilePosition(Isaac.GetRandomPosition(), 0),
		nil, player, player and player:GetCardRNG(ESSENCE_OF_HATE.ID):Next()
	)
	heart.Timeout = 32
	heart.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	Mod:GetData(heart).EssenceOfHateHeart = true
end

function ESSENCE_OF_HATE:OnUse(_, player)
	spawnExplodingHeart()
	Isaac.CreateTimer(function()
		spawnExplodingHeart(player)
	end, 10, 5, false)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, ESSENCE_OF_HATE.OnUse, ESSENCE_OF_HATE.ID)

function ESSENCE_OF_HATE:ExplodeOnTimeout(pickup)
	local data = Mod:TryGetData(pickup)
	if data and data.EssenceOfHateHeart and pickup.Timeout == 2 then
		Mod.Item.SHATTERED_HEART:ExplodeHeart(pickup, pickup.SpawnerEntity and pickup.SpawnerEntity:ToPlayer())
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, ESSENCE_OF_HATE.ExplodeOnTimeout, PickupVariant.PICKUP_HEART)
