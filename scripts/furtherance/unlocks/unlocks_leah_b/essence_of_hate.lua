local Mod = Furtherance

local ESSENCE_OF_HATE = {}

Furtherance.Rune.ESSENCE_OF_HATE = ESSENCE_OF_HATE

ESSENCE_OF_HATE.ID = Isaac.GetCardIdByName("Essence of Hate")

local function spawnExplodingHeart()
	local room = Mod.Room()
	local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL,
		room:FindFreeTilePosition(Isaac.GetRandomPosition(), 0), Vector.Zero, nil):ToPickup()
	---@cast heart EntityPickup
	heart.Timeout = 32
	Mod:GetData(heart).EssenceOfHateHeart = true
end

function ESSENCE_OF_HATE:OnUse()
	spawnExplodingHeart()
	Isaac.CreateTimer(function()
		spawnExplodingHeart()
	end, 10, 5, false)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, ESSENCE_OF_HATE.OnUse, ESSENCE_OF_HATE.ID)

function ESSENCE_OF_HATE:ExplodeOnTimeout(pickup)
	local data = Mod:TryGetData(pickup)
	if data and data.EssenceOfHateHeart and pickup.Timeout == 2 then
		Mod.Item.SHATTERED_HEART:ExplodeHeart(pickup)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, ESSENCE_OF_HATE.ExplodeOnTimeout, PickupVariant.PICKUP_HEART)
