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

MUDDLED_CROSS.TARGET_FLIP = 0
MUDDLED_CROSS.FLIP_FACTOR = 0
MUDDLED_CROSS.PAUSE_MENU_STOP_FLIP = false
MUDDLED_CROSS.FLIP_X_SPEED = 0.15

function MUDDLED_CROSS:FlipX()
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

function MUDDLED_CROSS:FlipY()
	MUDDLED_CROSS.TARGET_FLIP = 1
	Mod.SFXMan:Play(MUDDLED_CROSS.SFX_FLIP)
end

function MUDDLED_CROSS:TryFlip(player)
	local isPeter = Mod.Character.PETER_B:IsPeterB(player)
	local room = Mod.Room()
	local enemiesActive = room:GetAliveEnemiesCount() > 0
	local isXFlipped = MUDDLED_CROSS.FLIP.FLIP_FACTOR >= 0.95

	if not MUDDLED_CROSS.SPECIAL_ROOM_FLIP:IsFlippedRoom(Mod.Level():GetCurrentRoomIndex())
		and (not isPeter or not enemiesActive)
		and not isXFlipped
		and Mod.Item.MUDDLED_CROSS.SPECIAL_ROOM_FLIP.ALLOWED_SPECIAL_ROOMS[room:GetType()]
	then
		MUDDLED_CROSS:FlipY()
		return true
	elseif isPeter then
		MUDDLED_CROSS:FlipX()
		return true
	end

	return false
end

---@param player EntityPlayer
---@param flags UseFlag
function MUDDLED_CROSS:OnUse(itemID, rng, player, flags)
	if not Mod:HasBitFlags(flags, UseFlag.USE_CARBATTERY) then
		local flipped = MUDDLED_CROSS:TryFlip(player)
		if not flipped then
			return {Discharge = false, Remove = false, ShowAnim = false}
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
		Mod:ForEachPlayer(function(player)
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
					player:SetActiveCharge(
					min(MAX_CHARGE, slotData.Charge + floor(MUDDLED_CROSS.MAX_CHARGES / CHARGE_FRACTION)), slotData.Slot)
				end
			end
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, MUDDLED_CROSS.ChargeOnEnemyDeath)

function MUDDLED_CROSS:AnimateFlip()
	local isFlipped = MUDDLED_CROSS.TARGET_FLIP == 1
	MUDDLED_CROSS.PAUSE_MENU_STOP_FLIP = Mod.Game:IsPauseMenuOpen()

	if not MUDDLED_CROSS.PAUSE_MENU_STOP_FLIP then
		if not isFlipped then
			--Should only ever be true if done within via instant room change (i.e. debug console) or restarting the game via holding R
			if (Mod.Game:IsPaused() and RoomTransition.GetTransitionMode() == 0) or Mod.Game:GetFrameCount() == 0 then
				MUDDLED_CROSS.FLIP_FACTOR = 0
				return
			end
		end
		local lerp = Mod:Lerp(MUDDLED_CROSS.FLIP_FACTOR, isFlipped and 1 or 0, MUDDLED_CROSS.FLIP_X_SPEED)
		MUDDLED_CROSS.FLIP_FACTOR = Mod:Clamp(lerp, 0, 1)
	end

	if MUDDLED_CROSS.FLIP_FACTOR >= 0.5 and MUDDLED_CROSS.TARGET_FLIP == 1 then
		Mod.Item.MUDDLED_CROSS.SPECIAL_ROOM_FLIP:TryFlipSpecialRoom()
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

Mod.Include("scripts.furtherance.characters.peter_b.flip")
Mod.Include("scripts.furtherance.characters.peter_b.special_room_flip")

return MUDDLED_CROSS
