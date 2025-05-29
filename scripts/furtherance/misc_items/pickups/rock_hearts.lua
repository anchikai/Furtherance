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
		data.Overlays[ROCK_HEART.KEY] =
			data.Overlays[ROCK_HEART.KEY] + amount
		ROCK_HEART:ClampRockHearts(player)
		ROCK_HEART:UpdateRockHeartMask(player)
	end
end

---@param player EntityPlayer
function ROCK_HEART:ClampRockHearts(player)
	if player:GetHealthType() == HealthType.RED then
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		local data = player:GetData().CustomHealthAPISavedata
		data.Overlays[ROCK_HEART.KEY] =	Furtherance:Clamp(data.Overlays[ROCK_HEART.KEY] or 0, 0, ROCK_HEART:GetMaxRockIndex(player) * 2)
		--ROCK_HEART:UpdateRockHeartMask(player)
	end
end

function ROCK_HEART:CanPickup(player)
	return CustomHealthAPI.Library.CanPickKey(player, ROCK_HEART.KEY)
end

---@param player EntityPlayer
---@return integer
function ROCK_HEART:GetRockHearts(player)
	if player:GetHealthType() == HealthType.RED then
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		return CustomHealthAPI.Library.GetHPOfKey(player, ROCK_HEART.KEY)
	else
		return 0
	end
end

---@param player EntityPlayer
---@return integer
function ROCK_HEART:GetMaxRockIndex(player)
	if player:GetHealthType() == HealthType.RED then
		return math.ceil(CustomHealthAPI.PersistentData.OverriddenFunctions.GetMaxHearts(player) / 2)
	end
	return 0
end

---@param player EntityPlayer
---@return integer
function ROCK_HEART:GetRightRockIndex(player)
	if player:GetHealthType() == HealthType.RED and ROCK_HEART:GetRockHeartsMask(player) ~= nil then
		local mask = ROCK_HEART:GetRockHeartsMask(player)
		local _, size = Furtherance:MaxInTable(Furtherance:GetKeys(mask))
		return size
	end
	return 0
end

local function SumFromTable(tab)
	local sum = 0
	for _,v in pairs(tab) do
		sum = sum + v
	end
	return sum
end

---@param player EntityPlayer
---@return table, boolean
function ROCK_HEART:ShiftRockHeartMask(player)
	local data = player:GetData().CustomHealthAPISavedata
	local limit = ROCK_HEART:GetMaxRockIndex(player)
	local size = ROCK_HEART:GetRightRockIndex(player)
	local rockMask = data.RockRenderMask
	if limit < size then
		local cutMask = Furtherance:FlattenTable(Furtherance:FilterDict(rockMask, function(v, k) return k >= limit end))
	end
	return rockMask, false
end

---@param player EntityPlayer
function ROCK_HEART:UpdateRockHeartMask(player)
	if player:GetHealthType() == HealthType.RED and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		ROCK_HEART:ClampRockHearts(player)
		local rockHearts = ROCK_HEART:GetRockHearts(player)
		local data = player:GetData().CustomHealthAPISavedata
		local rockIndex = ROCK_HEART:GetMaxRockIndex(player)
		local rockMask = data.RockRenderMask or {}
		local shifted = false
		if rockHearts == 0 or rockIndex == 0 then
			data.RockRenderMask = Furtherance:ClearTable(rockMask)
			return
		end
		rockMask, shifted = ROCK_HEART:ShiftRockHeartMask(player)
		local maskHearts = SumFromTable(rockMask)
		if shifted then
			data.RockRenderMask = rockMask
		end
		if maskHearts ~= rockHearts then
			local diff = rockHearts - maskHearts
			if diff > 0 then
				for i = rockIndex, 1, -1 do
					if rockMask[i] == nil then
						rockMask[i] = math.min(diff, 2)
						diff = diff - rockMask[i]
					elseif rockMask[i] == 1 then
						rockMask[i] = 2
						diff = diff - 1
					end
					if diff <= 0 then
						break
					end
				end
			elseif diff < 0 then
				diff = -diff
				for i = rockIndex, 1, -1 do
					if rockMask[i] ~= nil then
						if rockMask[i] - diff <= 0 then
							diff = diff - rockMask[i]
							rockMask[i] = nil
						else
							rockMask[i] = rockMask[i] - diff
							diff = 0
						end
					end
					if diff <= 0 then
						break
					end
				end
			end
			data.RockRenderMask = rockMask
		end
	end
end

---@param player EntityPlayer
---@return table?
function ROCK_HEART:GetRockHeartsMask(player)
	if player:GetHealthType() == HealthType.RED and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		local data = player:GetData().CustomHealthAPISavedata
		return data.RockRenderMask
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

--[[ ---@param entType EntityType
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
Mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, ROCK_HEART.SpawnRockHeart) ]]

---@param pickup EntityPickup
---@param collider Entity
function ROCK_HEART:CollectRockHeart(pickup, collider)
	if pickup.SubType ~= ROCK_HEART.ID then
		return
	end
	local player = collider:ToPlayer()
	if player then
		if ROCK_HEART:CanPickup(player) then
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
		else
			return pickup:IsShopItem()
		end
	end
end
Mod:AddCallback(
	ModCallbacks.MC_PRE_PICKUP_COLLISION,
	--CallbackPriority.LATE,
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
			return player:GetHealthType() == HealthType.RED and ROCK_HEART:GetMaxRockIndex(player) * 2 > ROCK_HEART:GetRockHearts(player)
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
		data.RockRenderMask = {}
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
	function(player, flags, key, hp, otherKey, otherHp, damage)
		if
			player:GetHealthType() == HealthType.RED
			and flags & DamageFlag.DAMAGE_FAKE == 0
			and flags & DamageFlag.DAMAGE_IV_BAG == 0
		then
			local rockHearts = ROCK_HEART:GetRockHearts(player)
			if
				otherKey ~= nil
				and CustomHealthAPI.Library.GetInfoOfKey(otherKey, "KindContained") == CustomHealthAPI.Enums.HealthKinds.HEART
				and CustomHealthAPI.Library.GetInfoOfKey(otherKey, "Type") == CustomHealthAPI.Enums.HealthTypes.CONTAINER
				and otherHp == 0
				and key ~= nil
				and CustomHealthAPI.Library.GetInfoOfKey(key, "Type") == CustomHealthAPI.Enums.HealthTypes.RED
				and CustomHealthAPI.Library.GetInfoOfKey(key, "Kind") == CustomHealthAPI.Enums.HealthKinds.HEART
				and rockHearts > 0
				and ROCK_HEART:GetRightRockIndex(player) >= math.ceil(CustomHealthAPI.PersistentData.OverriddenFunctions.GetHearts(player) / 2)
			then
				local returnDamage = math.max(0, damage - rockHearts)
				damage = damage - returnDamage
				ROCK_HEART:AddRockHearts(player, -damage + player:GetEternalHearts())
				return returnDamage
			end
		end
	end
)

CustomHealthAPI.Library.AddCallback(
	"Furtherance",
	CustomHealthAPI.Enums.Callbacks.POST_RESYNC_PLAYER,
	0,
	---@param player EntityPlayer
	---@param isSubPlayer boolean
	function(player, isSubPlayer)
		if player:GetHealthType() == HealthType.RED then
			ROCK_HEART:ClampRockHearts(player)
			ROCK_HEART:UpdateRockHeartMask(player)
		end
	end
)

CustomHealthAPI.Library.AddCallback(
	"Furtherance",
	CustomHealthAPI.Enums.Callbacks.POST_ADD_HEALTH,
	0,
	---@param player EntityPlayer
	---@param key string
	---@param hp integer
	function(player, key, hp)
		if player:GetHealthType() == HealthType.RED and 
		CustomHealthAPI.Library.GetInfoOfKey(key, "KindContained") == CustomHealthAPI.Enums.HealthKinds.HEART
		and CustomHealthAPI.Library.GetInfoOfKey(key, "Type") == CustomHealthAPI.Enums.HealthTypes.CONTAINER then
			ROCK_HEART:ClampRockHearts(player)
			ROCK_HEART:UpdateRockHeartMask(player)
		end
	end
)

CustomHealthAPI.Library.AddCallback(
	"Furtherance",
	CustomHealthAPI.Enums.Callbacks.POST_RENDER_HEART,
	0,
	---@param player EntityPlayer
	---@param healthIndex integer
	---@param health table
	---@param redHealth table
	---@param filename string
	---@param animname string
	---@param color Color
	function(player, playerSlot, healthIndex, health, redHealth, filename, animname, color)
		if player:GetHealthType() == HealthType.RED and ROCK_HEART:GetRockHearts(player) > 0 then
			local mask = ROCK_HEART:GetRockHeartsMask(player)
			if mask ~= nil and mask[healthIndex + 1] ~= nil and mask[healthIndex + 1] > 0 then
				local animation = ROCK_HEART.ANIMATIONS[Furtherance:Clamp(mask[healthIndex + 1], 1, 2)]
				local file = CustomHealthAPI.Helper.GetHealthSprite(ROCK_HEART.ANIMATION_FILE)
				
				local hasEternal = CustomHealthAPI.Helper.GetEternalRenderIndex(player) == (healthIndex + 1) and player:GetEternalHearts() > 0
				local goldenMask = CustomHealthAPI.Helper.GetGoldenRenderMask(player)
				if hasEternal then
					animation = animation.."Eternal"
				end
				if goldenMask[healthIndex + 1] then
					animation = animation.."Gold"
				end
				file:Play(animation, true)
				CustomHealthAPI.Helper.RenderHealth(file, player, playerSlot, healthIndex)
			end
		end
	end
)
