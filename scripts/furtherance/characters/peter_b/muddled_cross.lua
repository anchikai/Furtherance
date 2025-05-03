--#region Variables

local Mod = Furtherance

local MUDDLED_CROSS = {}

Furtherance.Item.MUDDLED_CROSS = MUDDLED_CROSS

MUDDLED_CROSS.ID = Isaac.GetItemIdByName("Muddled Cross")

MUDDLED_CROSS.SFX_FLIP = Isaac.GetSoundIdByName("Peter Flip")
MUDDLED_CROSS.SFX_UNFLIP = Isaac.GetSoundIdByName("Peter Unflip")
MUDDLED_CROSS.SFX_ROOM_FLIP = Isaac.GetSoundIdByName("Peter Room Flip")
MUDDLED_CROSS.MAX_CHARGES = Mod.ItemConfig:GetCollectible(MUDDLED_CROSS.ID).MaxCharges
MUDDLED_CROSS.CHARGE_FRACTION_PER_KILL = 6
MUDDLED_CROSS.CHARGE_FRACTION_NOT_PETERB = 18

MUDDLED_CROSS.PUDDLE = Isaac.GetEntityVariantByName("Muddled Cross Puddle")
MUDDLED_CROSS.POOL_MASK_COLORIZE = Color(1, 1, 1, 0.1, 0, 0, 0, 1, 0, 0, 0)

local FIVE_SECONDS = 150
local HALF_FIVE_SECONDS = FIVE_SECONDS / 2

MUDDLED_CROSS.TARGET_FLIP = 0
MUDDLED_CROSS.FLIP_FACTOR = 0
MUDDLED_CROSS.PAUSE_MENU_STOP_FLIP = false
MUDDLED_CROSS.FLIP_X_SPEED = 0.15

--#endregion

--#region Flip on use

function MUDDLED_CROSS:EnemyFlip()
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

function MUDDLED_CROSS:TryRoomFlip()
	local successful = MUDDLED_CROSS.SPECIAL_ROOM_FLIP:TryFlipSpecialRoom()
	print(successful)
	if successful then
		MUDDLED_CROSS.TARGET_FLIP = 1
		Mod.SFXMan:Play(MUDDLED_CROSS.SFX_ROOM_FLIP)
	end
	return successful
end

function MUDDLED_CROSS:TryFlip(player)
	local isPeter = Mod.Character.PETER_B:IsPeterB(player)
	local room = Mod.Room()
	local enemiesActive = room:GetAliveEnemiesCount() > 0
	local peterFlipActive = Mod.Character.PETER_B.FLIP.FLIP_FACTOR >= 0.95

	if not MUDDLED_CROSS.SPECIAL_ROOM_FLIP:IsFlippedRoom()
		and (not isPeter or not enemiesActive)
		and not peterFlipActive
		and MUDDLED_CROSS.SPECIAL_ROOM_FLIP.ALLOWED_SPECIAL_ROOMS[room:GetType()]
	then
		local flipped

		Mod.Foreach.EffectInRadius(player.Position, player.Size, function(effect, index)
			flipped = MUDDLED_CROSS:TryRoomFlip()
			return true
		end, MUDDLED_CROSS.PUDDLE)

		if flipped == false then
			Mod.SFXMan:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
			Mod.Foreach.Effect(function(effect, index)
				effect.Timeout = 4
				if effect.SubType == 0 then
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 2, effect.Position, Vector.Zero, nil)
				end
			end, Mod.Item.MUDDLED_CROSS.PUDDLE)
			return false
		elseif flipped then
			return true
		end
	elseif isPeter then
		MUDDLED_CROSS:EnemyFlip()
		return true
	end
end

---@param player EntityPlayer
---@param flags UseFlag
function MUDDLED_CROSS:OnUse(itemID, rng, player, flags)
	if not Mod:HasBitFlags(flags, UseFlag.USE_CARBATTERY) then
		local flipped = MUDDLED_CROSS:TryFlip(player)

		if not flipped then
			Mod.SFXMan:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
			return { Discharge = false, Remove = false, ShowAnim = true }
		else
			Mod.Game:ShakeScreen(10)
		end
	end
	if Mod.Character.PETER_B:IsPeterB(player) then
		local extraCooldown = Mod:HasBitFlags(flags, UseFlag.USE_CARBATTERY) and FIVE_SECONDS or 0
		Mod:ForEachEnemy(function(npc)
			if Mod:GetData(npc).PeterFlipped then
				extraCooldown = extraCooldown + HALF_FIVE_SECONDS
			end
		end, false)
		Mod:DelayOneFrame(function()
			local tempEffect = Mod.Room():GetEffects():GetCollectibleEffect(MUDDLED_CROSS.ID)
			tempEffect.Cooldown = tempEffect.Cooldown + extraCooldown
			player:GetEffects():RemoveCollectibleEffect(MUDDLED_CROSS.ID, -1)
		end)
	else
		Mod:DelayOneFrame(function()
			player:GetEffects():RemoveCollectibleEffect(MUDDLED_CROSS.ID, -1)
		end)
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, MUDDLED_CROSS.OnUse, MUDDLED_CROSS.ID)

--#endregion

--#region Charging

---@param player EntityPlayer
function MUDDLED_CROSS:OnRoomClear(player)
	local slots = Mod:GetActiveItemCharges(player, MUDDLED_CROSS.ID)
	for _, slotData in ipairs(slots) do
		if slotData.Charge < MUDDLED_CROSS.MAX_CHARGES then
			player:FullCharge(slotData.Slot, true)
		end
	end
	if Mod.Character.PETER_B.FLIP:IsRoomEffectActive() then
		Mod.Room():GetEffects():RemoveCollectibleEffect(MUDDLED_CROSS.ID, -1)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, CallbackPriority.LATE, MUDDLED_CROSS.OnRoomClear)

---@param player EntityPlayer
function MUDDLED_CROSS:TimedRecharge(player)
	local effects = Mod.Room():GetEffects()
	if Mod.Room():GetAliveEnemiesCount() > 0
		or effects:HasCollectibleEffect(MUDDLED_CROSS.ID)
		or not Mod.Character.PETER_B:IsPeterB(player)
	then
		return
	end
	local slots = Mod:GetActiveItemCharges(player, MUDDLED_CROSS.ID)
	for _, slotData in ipairs(slots) do
		if slotData.Charge < MUDDLED_CROSS.MAX_CHARGES then
			player:SetActiveCharge(slotData.Charge + 1, slotData.Slot)
			if player:GetActiveCharge(slotData.Slot) == MUDDLED_CROSS.MAX_CHARGES then
				Mod.HUD:FlashChargeBar(player, slotData.Slot)
				Mod.SFXMan:Play(SoundEffect.SOUND_ITEMRECHARGE)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MUDDLED_CROSS.TimedRecharge, Mod.PlayerType.PETER_B)

local floor = math.floor

---@param player EntityPlayer
function MUDDLED_CROSS:GetChargeFractionPerKill(player)
	local charge = MUDDLED_CROSS.CHARGE_FRACTION_PER_KILL
	if not Mod.Character.PETER_B:IsPeterB(player) then
		charge = MUDDLED_CROSS.CHARGE_FRACTION_NOT_PETERB
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT) then
		CHARGE_FRACTION = CHARGE_FRACTION - 1
	end
	if player:HasTrinket(TrinketType.TRINKET_AAA_BATTERY) then
		CHARGE_FRACTION = CHARGE_FRACTION - 1
	end
	return charge
end

---@param ent Entity
function MUDDLED_CROSS:ChargeOnEnemyDeath(ent)
	if not Mod:IsDeadEnemy(ent) or not PlayerManager.AnyoneHasCollectible(MUDDLED_CROSS.ID) then return end
	local effects = Mod.Room():GetEffects()
	if Mod.Character.PETER_B.FLIP:IsRoomEffectActive() and effects:HasCollectibleEffect(MUDDLED_CROSS.ID) then
		Mod:DelayOneFrame(function()
			local aliveFlippedEnemies = false
			Mod:ForEachEnemy(function(_npc)
				if GetPtrHash(_npc) ~= GetPtrHash(ent) and Mod:GetData(_npc).PeterFlipped then
					aliveFlippedEnemies = true
				end
			end, true)
			if not aliveFlippedEnemies then
				effects:RemoveCollectibleEffect(MUDDLED_CROSS.ID, -1)
			end
		end)
	else
		--If spawned from something else
		if ent.SpawnerEntity
			and RNG(ent.InitSeed):RandomFloat() <= 0.5
		then
			return
		end
		Mod.Foreach.Player(function(player)
			local slots = Mod:GetActiveItemCharges(player, MUDDLED_CROSS.ID)
			local CHARGE_FRACTION = MUDDLED_CROSS:GetChargeFractionPerKill(player)
			for _, slotData in ipairs(slots) do
				player:AddActiveCharge(floor(MUDDLED_CROSS.MAX_CHARGES / CHARGE_FRACTION), slotData.Slot, true, false,
					true)
			end
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, MUDDLED_CROSS.ChargeOnEnemyDeath)

--#endregion

--#region Flip animation

function MUDDLED_CROSS:AnimateFlip()
	local isFlipped = MUDDLED_CROSS.TARGET_FLIP == 1

	if not Mod.Game:IsPauseMenuOpen() then
		if not isFlipped then
			--Should only ever be true if done within via instant room change (i.e. debug console) or restarting the game via holding R
			if Mod.Game:GetFrameCount() == 0 then
				MUDDLED_CROSS.FLIP_FACTOR = 0
				return
			end
		end
		local lerp = Mod:Lerp(MUDDLED_CROSS.FLIP_FACTOR, isFlipped and 1 or 0, MUDDLED_CROSS.FLIP_X_SPEED)
		MUDDLED_CROSS.FLIP_FACTOR = Mod:Clamp(floor(lerp * 100) / 100, 0, 1)
	end

	if MUDDLED_CROSS.FLIP_FACTOR >= 0.5 and MUDDLED_CROSS.TARGET_FLIP == 1 then
		MUDDLED_CROSS.SPECIAL_ROOM_FLIP:UpdateRoom()
		MUDDLED_CROSS.TARGET_FLIP = 0
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_RENDER, MUDDLED_CROSS.AnimateFlip)

function MUDDLED_CROSS:XFlipShader(shaderName)
	if shaderName == "Peter Room Type Flip" then
		return { FlipFactor = MUDDLED_CROSS.PAUSE_MENU_STOP_FLIP and 0 or MUDDLED_CROSS.FLIP_FACTOR }
	end
end

Mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, MUDDLED_CROSS.XFlipShader)

--#endregion

--#region Pool effect

---@param effect EntityEffect
function MUDDLED_CROSS:OnEffectInit(effect)
	if effect.SubType == 0 then
		local sprite = effect:GetSprite()
		local cross = Isaac.Spawn(effect.Type, effect.Variant, 1, effect.Position, Vector.Zero, effect):ToEffect()
		---@cast cross EntityEffect
		cross:GetSprite():Play("IdleCross")
		cross:GetSprite().PlaybackSpeed = 0.5
		cross.Parent = effect
		effect.SortingLayer = SortingLayer.SORTING_BACKGROUND
		local maskLayer = sprite:GetLayer("mask")
		---@cast maskLayer LayerState
		maskLayer:SetCustomShader("shaders/PhysHairCuttingShadder")
		maskLayer:SetColor(MUDDLED_CROSS.POOL_MASK_COLORIZE)
		sprite:SetLayerFrame(1, RNG(Mod.Room():GetSpawnSeed()):RandomInt(6))
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, MUDDLED_CROSS.OnEffectInit, MUDDLED_CROSS.PUDDLE)

---@param effect EntityEffect
function MUDDLED_CROSS:OnEffectUpdate(effect)
	if effect.SubType == 1 then
		local sprite = effect:GetSprite()
		if sprite:IsEventTriggered("Ripple") then
			local ripple = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_RIPPLE, 0, effect.Position,
				Vector.Zero, nil)
			ripple:GetSprite():GetLayer(0):GetBlendMode():SetMode(BlendType.ADDITIVE)
			Mod.SFXMan:Play(SoundEffect.SOUND_WATER_DROP)
		end
	end
	if effect.Timeout == 0
		or not PlayerManager.AnyoneHasCollectible(Mod.Item.MUDDLED_CROSS.ID)
		or (effect.Parent and not effect.Parent:Exists())
	then
		effect:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, MUDDLED_CROSS.OnEffectUpdate, MUDDLED_CROSS.PUDDLE)

function MUDDLED_CROSS:OnPossibleRoomFlipEnter()
	if PlayerManager.AnyoneHasCollectible(MUDDLED_CROSS.ID)
		and MUDDLED_CROSS.SPECIAL_ROOM_FLIP:CanFlipRoom()
	then
		local room = Mod.Room()
		local roomType = room:GetType()
		local backdrop = Isaac.RunCallbackWithParam(Mod.ModCallbacks.GET_MUDDLED_CROSS_PUDDLE_BACKDROP, roomType)
		if not backdrop then return end
		local puddle = Isaac.Spawn(EntityType.ENTITY_EFFECT, MUDDLED_CROSS.PUDDLE, 0,
			room:FindFreeTilePosition(Isaac.GetPlayer().Position, 0), Vector.Zero, nil):ToEffect()
		---@cast puddle EntityEffect
		local sprite = puddle:GetSprite()
		sprite:ReplaceSpritesheet(0, backdrop, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MUDDLED_CROSS.OnPossibleRoomFlipEnter)

function MUDDLED_CROSS:OnAddCollectible()
	if #Isaac.FindByType(EntityType.ENTITY_EFFECT, MUDDLED_CROSS.PUDDLE) == 0 then
		MUDDLED_CROSS:OnPossibleRoomFlipEnter()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, MUDDLED_CROSS.OnAddCollectible, MUDDLED_CROSS.ID)

--#endregion

Mod.Include("scripts.furtherance.characters.peter_b.special_room_flip")

return MUDDLED_CROSS
