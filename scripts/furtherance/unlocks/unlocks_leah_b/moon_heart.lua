local Mod = Furtherance

local MOON_HEART = {}

Furtherance.Pickup.MOON_HEART = MOON_HEART

MOON_HEART.ID = Isaac.GetEntitySubTypeByName("Moon Heart")
MOON_HEART.ID_HALF = Isaac.GetEntitySubTypeByName("Half Moon Heart")
MOON_HEART.KEY = "HEART_MOON"
MOON_HEART.PICKUP_SFX = Isaac.GetSoundIdByName("Moon Heart Pickup")

MOON_HEART.ROOM_MOONLIGHT_FLAGS = {
	---Spawn moonlight flag
	FLAG_SPAWN = 1 << 0,
	---Moonlight effect activation flag
	FLAG_ACTIVATED = 1 << 1,
	--Moonlight spawned by luna flag
	FLAG_LUNA = 1 << 2
}

Mod.SaveManager.Utility.AddDefaultFloorData(Mod.SaveManager.DefaultSaveKeys.GLOBAL, { ActivatedMoonlights = 0 })

---@param player EntityPlayer
---@param amount integer
function MOON_HEART:AddMoonHearts(player, amount)
	CustomHealthAPI.Library.AddHealth(player, MOON_HEART.KEY, amount, false, false)
end

---@param player EntityPlayer
function MOON_HEART:CanPickup(player)
	return CustomHealthAPI.Library.CanPickKey(player, MOON_HEART.KEY)
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
		return CustomHealthAPI.Library.GetHPOfKey(player:GetSubPlayer(), MOON_HEART.KEY, nil, nil, true)
	end
	return CustomHealthAPI.Library.GetHPOfKey(player, MOON_HEART.KEY, nil, nil, true)
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
		{ ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = MOON_HEART.ID_HALF },
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
		if data.MoonHeartLunaTrack < player:GetEffects():GetNullEffectNum(NullItemID.ID_LUNA) then
			player:GetEffects():AddNullEffect(NullItemID.ID_LUNA, true, math.ceil(MOON_HEART:GetMoonHearts(player) / 2))
		end
		data.MoonHeartLunaTrack = player:GetEffects():GetNullEffectNum(NullItemID.ID_LUNA)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MOON_HEART.AddExtraLuna)

---@param pickup EntityPickup
---@param collider Entity
function MOON_HEART:CollectMoonHeart(pickup, collider)
	if pickup.SubType ~= MOON_HEART.ID and pickup.SubType ~= MOON_HEART.ID_HALF then
		return
	end
	local player = collider:ToPlayer()
	if player then
		if MOON_HEART:CanPickup(player) then
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
			local heartWorth = pickup.SubType == MOON_HEART.ID and 2 or 1
			MOON_HEART:AddMoonHearts(player, heartWorth)
			CustomHealthAPI.Library.IncrementImmaculateConception(player, 1, pickup.InitSeed)
			CustomHealthAPI.Library.AddSoulLocketBonus(player, heartWorth, pickup.InitSeed)
			pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			pickup.Friction = 0

			if pickup.OptionsPickupIndex > 0 then
				Mod:KillChoice(pickup)
			end
		else
			return pickup:IsShopItem()
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
	local roomDesc = Mod.Level():GetCurrentRoomDesc()
	if roomDesc.Data.Type == RoomType.ROOM_SECRET or roomDesc.Data.Type == RoomType.ROOM_SUPERSECRET then
		local room_save = Mod:RoomSave()
		local floor_save = Mod:FloorSave()
		local allMoonHearts = 0
		Mod.Foreach.Player(function(player)
			allMoonHearts = allMoonHearts + math.ceil(MOON_HEART:GetMoonHearts(player) / 2)
		end)
		Mod:DebugLog("Total moon hearts: " .. allMoonHearts)
		Mod:DebugLog("Activated moonlights: " .. floor_save.ActivatedMoonlights)

		local room = Mod.Room()
		if not room_save.SpawnMoonlight and room:IsFirstVisit() then
			Mod:DebugLog("Init room moonlight data")
			room_save.SpawnMoonlight = 0
			if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_LUNA) then
				room_save.SpawnMoonlight = Mod:AddBitFlags(room_save.SpawnMoonlight, MOON_HEART.ROOM_MOONLIGHT_FLAGS.FLAG_LUNA)
				Mod:DebugLog("Adding luna flag")
			end
		end
		if Mod:HasAnyBitFlags(room_save.SpawnMoonlight, MOON_HEART.ROOM_MOONLIGHT_FLAGS.FLAG_ACTIVATED | MOON_HEART.ROOM_MOONLIGHT_FLAGS.FLAG_LUNA) then
			Mod:DebugLog("Moonlight was activated")
			return
		end
		if (allMoonHearts - floor_save.ActivatedMoonlights) > 0 then
			room_save.SpawnMoonlight = Mod:AddBitFlags(room_save.SpawnMoonlight, MOON_HEART.ROOM_MOONLIGHT_FLAGS.FLAG_SPAWN)
			Mod:DebugLog("Adding flag to spawn in a room")
		else
			room_save.SpawnMoonlight = Mod:RemoveBitFlags(room_save.SpawnMoonlight, MOON_HEART.ROOM_MOONLIGHT_FLAGS.FLAG_SPAWN)
			Mod:DebugLog("Removing flag to spawn in a room")
		end

		Mod:DebugLog("Moonlight can be spawned?: " .. tostring(Mod:HasBitFlags(room_save.SpawnMoonlight, MOON_HEART.ROOM_MOONLIGHT_FLAGS.FLAG_SPAWN)))
		Mod.Foreach.Player(function(player)
			if player.FrameCount > 0 then
				if #Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HEAVEN_LIGHT_DOOR, 1) > 0 then
					Mod:DebugLog("Moonlight already exists")
					return true
				end
				if Mod:HasBitFlags(room_save.SpawnMoonlight, MOON_HEART.ROOM_MOONLIGHT_FLAGS.FLAG_SPAWN)
				then
					Isaac.Spawn(
						EntityType.ENTITY_EFFECT,
						EffectVariant.HEAVEN_LIGHT_DOOR,
						1,
						room:GetCenterPos(),
						Vector.Zero,
						nil
					)
					return true
				end
			end
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MOON_HEART.SpawnLunarLight)

---@param moonlight EntityEffect
function MOON_HEART:ActivateMoonlight(moonlight)
	if moonlight.SubType == 1 then
		local roomSave = Mod:RoomSave()
		if moonlight:GetSprite():IsPlaying("Disappear")
			and not Mod:HasBitFlags(roomSave.SpawnMoonlight, MOON_HEART.ROOM_MOONLIGHT_FLAGS.FLAG_ACTIVATED)
		then
			roomSave.SpawnMoonlight = Mod:AddBitFlags(roomSave.SpawnMoonlight, MOON_HEART.ROOM_MOONLIGHT_FLAGS.FLAG_ACTIVATED)
			Mod:DebugLog("Moonlight activated")
			local floorSave = Mod:FloorSave()
			floorSave.ActivatedMoonlights = floorSave.ActivatedMoonlights + 1
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, MOON_HEART.ActivateMoonlight, EffectVariant.HEAVEN_LIGHT_DOOR)

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
	room.DisplayFlags = Mod.DisplayFlags.VISIBLE_WITH_ICON
	Mod.Level():UpdateVisibility()
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

					return roomData.Type == RoomType.ROOM_SECRET and not Mod:HasBitFlags(room.DisplayFlags, Mod.DisplayFlags.VISIBLE)
				end)

				if not ShowSecretRoom(secretRooms) then
					local superSecretRooms = Mod:GetAllRooms(function(room)
						---@cast room RoomDescriptor
						local roomData = room.Data
						return roomData.Type == RoomType.ROOM_SUPERSECRET
							and not Mod:HasBitFlags(room.DisplayFlags, Mod.DisplayFlags.VISIBLE)
					end)
					ShowSecretRoom(superSecretRooms)
				end
			end
		end
	end
)
