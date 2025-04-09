local Mod = Furtherance

local MUDDLED_CROSS = {}

Furtherance.Item.MUDDLED_CROSS = MUDDLED_CROSS

MUDDLED_CROSS.ID = Isaac.GetItemIdByName("Muddled Cross")

MUDDLED_CROSS.SFX_FLIP = Isaac.GetSoundIdByName("Peter Flip")
MUDDLED_CROSS.SFX_UNFLIP = Isaac.GetSoundIdByName("Peter Unflip")
MUDDLED_CROSS.MAX_CHARGES = Mod.ItemConfig:GetCollectible(MUDDLED_CROSS.ID).MaxCharges
MUDDLED_CROSS.CHARGE_FRACTION_PER_KILL = 6

local FIVE_SECONDS = 150
local HALF_FIVE_SECONDS = FIVE_SECONDS / 2

---@param player EntityPlayer
---@param flags UseFlag
function MUDDLED_CROSS:OnUse(itemID, rng, player, flags)
	if MUDDLED_CROSS.FLIP.FLIP_FACTOR > 0.05 and MUDDLED_CROSS.FLIP.FLIP_FACTOR < 0.95 then
		return {Discharge = false, Remove = false, ShowAnim = false}
	end
	if not Mod:HasBitFlags(flags, UseFlag.USE_CARBATTERY) then
		Mod.Game:ShakeScreen(10)
		local room = Mod.Room()
		local effects = room:GetEffects()
		local isFlipped = effects:HasCollectibleEffect(MUDDLED_CROSS.ID)
		if not isFlipped then
			effects:AddCollectibleEffect(MUDDLED_CROSS.ID)
			Mod.SFXMan:Play(MUDDLED_CROSS.SFX_FLIP)
		else
			effects:RemoveCollectibleEffect(MUDDLED_CROSS.ID, -1)
			Mod.SFXMan:Play(MUDDLED_CROSS.SFX_UNFLIP)
		end
	end
	local extraCooldown = Mod:HasBitFlags(flags, UseFlag.USE_CARBATTERY) and FIVE_SECONDS or 0
	Mod:ForEachEnemy(function (npc)
		if Mod:GetData(npc).PeterFlipped then
			extraCooldown = extraCooldown + HALF_FIVE_SECONDS
		end
	end, false)
	Mod:DelayOneFrame(function()
		local tempEffect = Mod.Room():GetEffects():GetCollectibleEffect(MUDDLED_CROSS.ID)
		tempEffect.Cooldown = tempEffect.Cooldown + extraCooldown
		player:GetEffects():RemoveCollectibleEffect(MUDDLED_CROSS.ID, -1)
	end)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, MUDDLED_CROSS.OnUse, MUDDLED_CROSS.ID)

function MUDDLED_CROSS:IsRoomEffectActive()
	return MUDDLED_CROSS.FLIP.FLIP_FACTOR > 0.5
end

---@param player EntityPlayer
function MUDDLED_CROSS:OnRoomClear(player)
	local slots = Mod:GetActiveItemCharges(player, MUDDLED_CROSS.ID)
	for _, slotData in ipairs(slots) do
		if slotData.Charge < MUDDLED_CROSS.MAX_CHARGES then
			player:FullCharge(slotData.Slot, true)
		end
	end
	if MUDDLED_CROSS:IsRoomEffectActive() then
		Mod.Room():GetEffects():RemoveCollectibleEffect(MUDDLED_CROSS.ID, -1)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, CallbackPriority.LATE, MUDDLED_CROSS.OnRoomClear)

---@param player EntityPlayer
function MUDDLED_CROSS:TimedRecharge(player)
	local effects = Mod.Room():GetEffects()
	if Mod.Room():GetAliveEnemiesCount() > 0 or effects:HasCollectibleEffect(MUDDLED_CROSS.ID) then return end
	local slots = Mod:GetActiveItemCharges(player, MUDDLED_CROSS.ID)
	for _, slotData in ipairs(slots) do
		if slotData.Charge < MUDDLED_CROSS.MAX_CHARGES then
			player:SetActiveCharge(slotData.Charge + 1, slotData.Slot)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MUDDLED_CROSS.TimedRecharge, Mod.PlayerType.PETER_B)

local floor = math.floor
local min = math.min

---@param ent Entity
function MUDDLED_CROSS:ChargeOnEnemyDeath(ent)
	if not Mod:IsDeadEnemy(ent) then return end
	local effects = Mod.Room():GetEffects()
	if MUDDLED_CROSS:IsRoomEffectActive() and effects:HasCollectibleEffect(MUDDLED_CROSS.ID) then
		local aliveFlippedEnemies = false
		Mod:ForEachEnemy(function(_npc)
			if GetPtrHash(_npc) ~= GetPtrHash(ent) and Mod:GetData(_npc).PeterFlipped then
				aliveFlippedEnemies = true
			end
		end, true)
		if not aliveFlippedEnemies then
			effects:RemoveCollectibleEffect(MUDDLED_CROSS.ID, -1)
		end
	else
		Mod:ForEachPlayer(function (player)
			local slots = Mod:GetActiveItemCharges(player, MUDDLED_CROSS.ID)
			local MAX_CHARGE = MUDDLED_CROSS.MAX_CHARGES
			local CHARGE_FRACTION = MUDDLED_CROSS.CHARGE_FRACTION_PER_KILL
			if player:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT) then
				CHARGE_FRACTION = CHARGE_FRACTION - 1
			end
			if player:HasTrinket(TrinketType.TRINKET_AAA_BATTERY) then
				CHARGE_FRACTION = CHARGE_FRACTION - 1
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
				MAX_CHARGE = MAX_CHARGE * 2
			end
			for _, slotData in ipairs(slots) do
				if slotData.Charge < MAX_CHARGE then
					player:SetActiveCharge(min(MAX_CHARGE, slotData.Charge + floor(MUDDLED_CROSS.MAX_CHARGES / CHARGE_FRACTION)), slotData.Slot)
				end
			end
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, MUDDLED_CROSS.ChargeOnEnemyDeath)

Mod.Include("scripts.furtherance.characters.peter_b.flip")

return MUDDLED_CROSS

--[[ local game = Game()

Mod:SaveModData({
	Flipped = false,
	MuddledCrossBackdropType = Mod.SaveNil
})

local FlipSFX = Isaac.GetSoundIdByName("PeterFlip")
local UnflipSFX = Isaac.GetSoundIdByName("PeterUnflip")

local function clamp(value, min, max)
	return math.min(math.max(value, min), max)
end

local function switchBackground(isFlipped)
	local level = game:GetLevel()
	local room = game:GetRoom()
	if isFlipped == true then
		Mod.MuddledCrossBackdropType = room:GetBackdropType()
		if room:GetType() == RoomType.ROOM_DEFAULT or room:GetType() == RoomType.ROOM_TREASURE then
			if level:GetStageType() <= StageType.STAGETYPE_AFTERBIRTH then
				if level:GetStage() < LevelStage.STAGE4_3 then
					game:ShowHallucination(0, Mod.MuddledCrossBackdropType + 3)
				elseif level:GetStage() ~= LevelStage.STAGE4_3 and level:GetStage() < LevelStage.STAGE6 then
					game:ShowHallucination(0, Mod.MuddledCrossBackdropType + 2)
				end
			elseif level:GetStageType() >= StageType.STAGETYPE_REPENTANCE then
				if level:GetStage() < LevelStage.STAGE4_1 then
					if (Mod.MuddledCrossBackdropType >= BackdropType.MAUSOLEUM2 and Mod.MuddledCrossBackdropType <= BackdropType.MAUSOLEUM4) or Mod.MuddledCrossBackdropType == BackdropType.MAUSOLEUM then
						game:ShowHallucination(0, BackdropType.CORPSE)
					else
						game:ShowHallucination(0, Mod.MuddledCrossBackdropType + 1)
					end
				end
			end
		end
	elseif isFlipped == false then
		game:ShowHallucination(0, Mod.MuddledCrossBackdropType)
	end
	SFXManager():Stop(SoundEffect.SOUND_DEATH_CARD)
end

function Mod:UseFlippedCross(_, _, player)
	game:ShakeScreen(10)

	Mod.Flipped = not Mod.Flipped
	switchBackground(Mod.Flipped)

	if Mod.Flipped == true then
		SFXManager():Play(FlipSFX)
	else
		SFXManager():Play(UnflipSFX)
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseFlippedCross, CollectibleType.COLLECTIBLE_MUDDLED_CROSS)

function Mod:RoomPersist()
	if Mod.Flipped == true then
		switchBackground(true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.RoomPersist)

function Mod:UltraSecretPool(pool, decrease, seed)
	if Mod.Flipped == true then
		if Rerolled ~= true then
			Rerolled = true
			return game:GetItemPool():GetCollectible(ItemPoolType.POOL_ULTRA_SECRET, false, seed,
				CollectibleType.COLLECTIBLE_NULL)
		end
		Rerolled = false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, Mod.UltraSecretPool)

function Mod:DoubleStuff(pickup)
	local room = game:GetRoom()
	if pickup.FrameCount ~= 1 or Mod.Flipped ~= true then
		return
	end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if pickup.SpawnerType ~= EntityType.ENTITY_PLAYER then
			pickup.SpawnerEntity = player
			pickup.SpawnerType = EntityType.ENTITY_PLAYER
			pickup.SpawnerVariant = player.Variant
			if Mod.Flipped and room:IsFirstVisit() then
				local newItem = Isaac.Spawn(EntityType.ENTITY_PICKUP, pickup.Variant, 0,
					Isaac.GetFreeNearPosition(pickup.Position, 80), Vector.Zero, player):ToPickup()
				newItem.Price = pickup.Price
				newItem.OptionsPickupIndex = pickup.OptionsPickupIndex
			end

			break
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Mod.DoubleStuff)

function Mod:HealthDrain(player)
	if Mod.Flipped == true and player:GetHearts() > 1 and game:GetFrameCount() ~= 0 then
		local drainSpeed
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and player:GetName() == "PeterB" then
			drainSpeed = 420
		else
			drainSpeed = 210
		end
		if game:GetFrameCount() % drainSpeed == 0 then
			player:AddHearts(-1)
			local blood = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, player.Position,
				Vector.Zero, player):ToEffect()
			blood.Scale = 1.5
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.HealthDrain)

function Mod:TougherEnemies(entity)
	if Mod.Flipped ~= true then return end

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = Mod:GetData(player)
		if entity:IsActiveEnemy(false) and entity:IsVulnerableEnemy() then
			if data.DamageTimeout == nil then
				data.DamageTimeout = false
			elseif data.DamageTimeout == true then
				data.DamageTimeout = false
				entity:SetColor(Color(0.709, 0.0196, 0.0196, 1, 0.65, 0, 0), 1, 1, false, false)
				return false
			else
				data.DamageTimeout = true
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.TougherEnemies)


local flipFactor = 0
function Mod:NewFloor()
	if Mod.Flipped and not newGame then
		Mod.Flipped = false
		flipFactor = 0
	end
	newGame = false
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Mod.NewFloor)

local pauseTime = 0
local pausedFixed = false
function Mod:AnimateFlip()
	local speed = 0.05
	if Furtherance.FlipSpeed == 1 then
		speed = 0.0172413793
	elseif Furtherance.FlipSpeed == 2 then
		speed = 0.05
	elseif Furtherance.FlipSpeed == 3 then
		speed = 0.1
	end

	local renderFlipped = Mod.Flipped and not pausedFixed
	if renderFlipped == true then
		flipFactor = flipFactor + speed
	elseif renderFlipped == false then
		flipFactor = flipFactor - speed
	end
	flipFactor = clamp(flipFactor, 0, 1)

	if game:IsPaused() then
		pauseTime = math.min(pauseTime + 1, 26)
	else
		pauseTime = 0
	end
	if Mod.Flipped and pauseTime == 26 then
		pausedFixed = true
	elseif pausedFixed and not game:IsPaused() then
		pausedFixed = false
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_RENDER, Mod.AnimateFlip)

-- Thank you im_tem for the shader!!
function Mod:PeterFlip(name)
	if name == 'Peter Flip' then
		return { FlipFactor = flipFactor }
	end
end

Mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, Mod.PeterFlip)

function Mod:ResetFlipped(continued)
	pausedFixed = false
	if not continued and Mod.Flipped then
		switchBackground(false)
		flipFactor = 0
		Mod.Flipped = false
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.ResetFlipped)
 ]]