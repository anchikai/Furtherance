local Mod = Furtherance

local ROCK_HEART = {}

Furtherance.Pickup.ROCK_HEART = ROCK_HEART

ROCK_HEART.ID = Isaac.GetEntitySubTypeByName("Rock Heart")
ROCK_HEART.KEY = "HEART_ROCK"
ROCK_HEART.PICKUP_SFX = SoundEffect.SOUND_ROCK_CRUMBLE
ROCK_HEART.ANIMATION_FILE = "gfx/ui/ui_rockheart.anm2"
ROCK_HEART.ANIMATIONS = { "RockHeartHalf", "RockHeartFull" }

ROCK_HEART.REPLACE_CHANCE = 0.2

---@param player EntityPlayer
---@param amount integer
function ROCK_HEART:AddRockHearts(player, amount)
	if player:GetHealthType() == HealthType.RED then
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		local data = player:GetData().CustomHealthAPISavedata
		data.Overlays[ROCK_HEART.KEY] = data.Overlays[ROCK_HEART.KEY] + amount
	end
end

---@param player EntityPlayer
---@return integer
function ROCK_HEART:GetRockHearts(player)
	if player:GetHealthType() == HealthType.RED then
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		local data = player:GetData().CustomHealthAPISavedata
		return data.Overlays[ROCK_HEART.KEY]
	else
		return 0
	end
end

CustomHealthAPI.Library.RegisterHealthOverlay(ROCK_HEART.KEY, {
	AnimationFilename = ROCK_HEART.ANIMATION_FILE,
	AnimationName = ROCK_HEART.ANIMATIONS,
	IgnoreBleeding = true,
	PickupEntities = {
		{ ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = ROCK_HEART.ID },
	},
})

---@param entType EntityType
---@param variant PickupVariant
---@param subtype integer
---@param spawner Entity
---@param seed integer
function ROCK_HEART:SpawnRockHeart(entType, variant, subtype, _, _, spawner, seed)
	if
		entType == EntityType.ENTITY_PICKUP
		and variant == PickupVariant.PICKUP_HEART
		and subtype == HeartSubType.HEART_ETERNAL
	then
		local rng = RNG(seed)
		if rng:RandomFloat() <= ROCK_HEART.REPLACE_CHANCE then
			return { entType, variant, ROCK_HEART.ID, seed }
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, ROCK_HEART.SpawnRockHeart)

---@param pickup EntityPickup
---@param collider Entity
function ROCK_HEART:CollectRockHeart(pickup, collider)
	if pickup.SubType ~= ROCK_HEART.ID then
		return
	end
	local player = collider:ToPlayer()
	if player then
		if pickup:IsShopItem() then
			if not Mod:CanPlayerBuyShopItem(player, pickup) then
				return pickup:IsShopItem()
			end
			Mod:PayPickupPrice(player, pickup)
			Mod:PickupShopKill(player, pickup, ROCK_HEART.PICKUP_SFX)
		else
			pickup:GetSprite():Play("Collect", true)
			Mod.SFXMan:Play(ROCK_HEART.PICKUP_SFX, 1, 0, false)
			pickup:Die()
		end
		ROCK_HEART:AddRockHearts(player, 2)

		pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		pickup.Friction = 0
		if pickup.OptionsPickupIndex > 0 then
			Mod:KillChoice(pickup)
		end
	end
end

Mod:AddPriorityCallback(
	ModCallbacks.MC_PRE_PICKUP_COLLISION,
	CallbackPriority.LATE,
	ROCK_HEART.CollectRockHeart,
	PickupVariant.PICKUP_HEART
)

CustomHealthAPI.Library.AddCallback(
	"Furtherance",
	CustomHealthAPI.Enums.Callbacks.CAN_PICK_HEALTH,
	0,
	---@param player EntityPlayer
	---@param key string
	function(player, key)
		if key == ROCK_HEART.KEY then
			return player:GetHealthType() == HealthType.RED and math.ceil(ROCK_HEART:GetRockHearts(player) / 2) < math.ceil(player:GetHearts() / 2)
		end
	end
)

CustomHealthAPI.Library.AddCallback(
	"Furtherance",
	CustomHealthAPI.Enums.Callbacks.POST_PLAYER_INITIALIZE,
	0,
	---@param player EntityPlayer
	---@param isSubPlayer boolean
	function(player, isSubPlayer)
		local data = player:GetData().CustomHealthAPISavedata
		data.Overlays[ROCK_HEART.KEY] = 0
	end
)

CustomHealthAPI.Library.AddCallback(
	"Furtherance",
	CustomHealthAPI.Enums.Callbacks.PRE_HEALTH_DAMAGED,
	0,
	---@param player EntityPlayer
	---@param flags DamageFlag | integer
	---@param key string
	---@param hp integer
	---@param otherKey string
	---@param otherHp integer
	---@param damage integer
	---@return boolean | integer?
	function(player, flags, key, hp, otherKey, otherHp, damage) end
)
