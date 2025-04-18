local Mod = Furtherance

local MOON_HEART = {}

Furtherance.Pickup.MOON_HEART = MOON_HEART

MOON_HEART.ID = Isaac.GetEntitySubTypeByName("Moon Heart")
MOON_HEART.KEY = "HEART_MOON"
MOON_HEART.PICKUP_SFX = Isaac.GetSoundIdByName("Moon Heart Pickup")

MOON_HEART.REPLACE_CHANCE = 0.2

---@param player EntityPlayer
---@param amount integer
function MOON_HEART:AddMoonHearts(player, amount)
	CustomHealthAPI.Library.AddHealth(player, MOON_HEART.KEY, amount, false, false)
end

---@param player EntityPlayer
---@return integer
function MOON_HEART:GetMoonHearts(player)
	if CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		return 0
	end
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
		if player:GetSubPlayer() == nil then
			return 0
		end
		return CustomHealthAPI.Library.GetHPOfKey(player:GetSubPlayer(), MOON_HEART.KEY)
	end
	return CustomHealthAPI.Library.GetHPOfKey(player, MOON_HEART.KEY)
end

CustomHealthAPI.Library.RegisterSoulHealth(MOON_HEART.KEY, {
	AnimationFilename = "gfx/ui/ui_moonheart.anm2",
	AnimationName = { "MoonHeartHalf", "MoonHeartFull" },

	SortOrder = 100,
	AddPriority = 150,
	HealFlashRO = 50 / 255,
	HealFlashGO = 70 / 255,
	HealFlashBO = 90 / 255,
	MaxHP = 2,
	PrioritizeHealing = true,
	PickupEntities = {
		{ ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = MOON_HEART.ID },
	},
	SumptoriumSubType = 55,
	SumptoriumSplatColor = Color(1.00, 1.00, 1.00, 1.00, 0.00, 0.00, 0.00),
	SumptoriumTrailColor = Color(1.00, 1.00, 1.00, 1.00, 0.00, 0.00, 0.00),
	SumptoriumCollectSoundSettings = {
		ID = SoundEffect.SOUND_ROTTEN_HEART,
		Volume = 1.0,
		FrameDelay = 0,
		Loop = false,
		Pitch = 1.0,
		Pan = 0,
	},
})

---@param entType EntityType
---@param variant PickupVariant
---@param subtype integer
---@param spawner Entity
---@param seed integer
function MOON_HEART:SpawnMoonHeart(entType, variant, subtype, _, _, spawner, seed)
	if
		entType == EntityType.ENTITY_PICKUP
		and variant == PickupVariant.PICKUP_HEART
		and subtype == HeartSubType.HEART_ETERNAL
	then
		local rng = RNG(seed)
		if rng:RandomFloat() <= MOON_HEART.REPLACE_CHANCE then
			return { entType, variant, MOON_HEART.ID, seed }
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, MOON_HEART.SpawnMoonHeart)

---@param player EntityPlayer
function MOON_HEART:AddExtraLuna(player)
	if MOON_HEART:GetMoonHearts(player) == 0 then return end
	local data = Mod:GetData(player)
	if not data.MoonHeartLunaTrack then
		data.MoonHeartLunaTrack = player:GetEffects():GetNullEffectNum(NullItemID.ID_LUNA)
	end
	if data.MoonHeartLunaTrack ~= player:GetEffects():GetNullEffectNum(NullItemID.ID_LUNA)
		and player:HasCollectible(CollectibleType.COLLECTIBLE_LUNA)
	then
		player:GetEffects():AddNullEffect(NullItemID.ID_LUNA, true, math.ceil(MOON_HEART:GetMoonHearts(player) / 2))
		data.MoonHeartLunaTrack = player:GetEffects():GetNullEffectNum(NullItemID.ID_LUNA)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MOON_HEART.AddExtraLuna)

---@param pickup EntityPickup
---@param collider Entity
function MOON_HEART:CollectMoonHeart(pickup, collider)
	if pickup.SubType ~= MOON_HEART.ID then
		return
	end
	local player = collider:ToPlayer()
	if player then
		if pickup:IsShopItem() then
			if not Mod:CanPlayerBuyShopItem(player, pickup) then
				return pickup:IsShopItem()
			end
			Mod:PayPickupPrice(player, pickup)
			Mod:PickupShopKill(player, pickup, MOON_HEART.PICKUP_SFX)
		else
			pickup:GetSprite():Play("Collect", true)
			Mod.SFXMan:Play(MOON_HEART.PICKUP_SFX, 1, 0, false)
			pickup:Die()
		end
		MOON_HEART:AddMoonHearts(player, 2)

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
	MOON_HEART.CollectMoonHeart,
	PickupVariant.PICKUP_HEART
)

function MOON_HEART:SpawnLunarLight()
	if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_LUNA) then
		return
	end
	Mod:ForEachPlayer(function(player)
		if player.FrameCount == 0 then
			return true
		end
		if MOON_HEART:GetMoonHearts(player) > 0 then
			local room = Mod.Room()
			if
				(room:GetType() == RoomType.ROOM_SECRET or room:GetType() == RoomType.ROOM_SUPERSECRET)
				and room:IsFirstVisit()
				and #Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HEAVEN_LIGHT_DOOR, 1) == 0
			then
				Isaac.Spawn(
					EntityType.ENTITY_EFFECT,
					EffectVariant.HEAVEN_LIGHT_DOOR,
					1,
					room:GetCenterPos(),
					Vector.Zero,
					nil
				)
			end
			return true
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MOON_HEART.SpawnLunarLight)

CustomHealthAPI.Library.AddCallback(
	"Furtherance",
	CustomHealthAPI.Enums.Callbacks.CAN_PICK_HEALTH,
	0,
	---@param player EntityPlayer
	---@param key string
	function(player, key)
		if key == MOON_HEART.KEY then
			return player:CanPickSoulHearts()
		end
	end
)

---@generic K
---@param rooms table<K, RoomDescriptor>
local function ShowSecretRoom(rooms)
	if #rooms == 0 then
		return false
	end
	local idx = Mod.GENERIC_RNG:RandomInt(#rooms) + 1
	local room = rooms[idx]
	room.DisplayFlags = room.DisplayFlags | 6
	return true
end

CustomHealthAPI.Library.AddCallback(
	"Furtherance",
	CustomHealthAPI.Enums.Callbacks.POST_HEALTH_DAMAGED,
	0,
	function(player, flags, key, hpDamaged, wasDepleted, wasLastDamaged)
		if key == MOON_HEART.KEY then
			if wasDepleted then
				local secretRooms = Mod:GetAllRooms(function(room)
					---@cast room RoomDescriptor
					local roomData = room.Data
					return roomData.Type == RoomType.ROOM_SECRET and not Mod:HasBitFlags(room.DisplayFlags, 1 << 2)
				end)
				if not ShowSecretRoom(secretRooms) then
					local superSecretRooms = Mod:GetAllRooms(function(room)
						---@cast room RoomDescriptor
						local roomData = room.Data
						return roomData.Type == RoomType.ROOM_SUPERSECRET
							and not Mod:HasBitFlags(room.DisplayFlags, 1 << 2)
					end)
					ShowSecretRoom(superSecretRooms)
				end
			end
		end
	end
)
