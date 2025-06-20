local Mod = Furtherance

local ALTRUISM = {}

Furtherance.Trinket.ALTRUISM = ALTRUISM

ALTRUISM.ID = Isaac.GetTrinketIdByName("Altruism")

ALTRUISM.BEGGAR_TRIGGER_ALTRUISM_CHANCE = 0.25
ALTRUISM.BEGGAR_HEAL_CHANCE = 0.5

ALTRUISM.DEBUG_REFUND = false

---@param ent Entity
---@param amount integer
---@param flags DamageFlag
---@param source EntityRef
function ALTRUISM:TryPreventDevilBeggarDamage(ent, amount, flags, source, frames)
	if Mod:HasBitFlags(flags, DamageFlag.DAMAGE_RED_HEARTS)
		and source.Entity
		and source.Entity:ToSlot()
		and Mod:GetData(ent).AltruismPreventDamage
	then
		Mod:GetData(ent).AltruismPreventDamage = nil
		ent:TakeDamage(amount, flags | DamageFlag.DAMAGE_FAKE, source, frames)
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ALTRUISM.TryPreventDevilBeggarDamage, EntityType.ENTITY_PLAYER)

local function vanillaBeggarAnimCheck(slot)
	local sprite = slot:GetSprite()
	local anim = slot:GetSprite():GetAnimation()
	return (anim == "Idle" or (anim == "PayNothing" and sprite:GetFrame() + 1 == sprite:GetCurrentAnimationData():GetLength()))
end

---@param player EntityPlayer
---@param slot EntitySlot
local function coinBeggarRequirement(player, slot)
	return player:GetNumCoins() > 0 and vanillaBeggarAnimCheck(slot)
end

---@param player EntityPlayer
local function coinBeggarReward(player)
	player:AddCoins(1)
end

local function hurtBeggarRequirement(player, slot)
	return vanillaBeggarAnimCheck(slot)
end

---@param player EntityPlayer
local function hurtBeggarReward(player)
	Mod:GetData(player).AltruismPreventDamage = true
	Mod:DelayOneFrame(function() Mod:GetData(player).AltruismPreventDamage = nil end)
end

---@type {[SlotVariant]: fun(player: EntityPlayer, slot: EntitySlot): boolean}
ALTRUISM.ResourceRequirement = {
	[SlotVariant.BEGGAR] = coinBeggarRequirement,
	[SlotVariant.DEVIL_BEGGAR] = hurtBeggarRequirement,
	[SlotVariant.BOMB_BUM] = function(player, slot)
		return player:GetNumBombs() > 0 and vanillaBeggarAnimCheck(slot)
	end,
	[SlotVariant.KEY_MASTER] = function(player, slot)
		return player:GetNumKeys() > 0 and vanillaBeggarAnimCheck(slot)
	end,
	[SlotVariant.SHELL_GAME] = coinBeggarRequirement,
	[SlotVariant.BATTERY_BUM] = coinBeggarRequirement,
	[SlotVariant.HELL_GAME] = hurtBeggarRequirement,
	[SlotVariant.ROTTEN_BEGGAR] = coinBeggarRequirement
}

---@type {[SlotVariant]: fun(player: EntityPlayer, slot: EntitySlot)}
ALTRUISM.ResourceRefund = {
	[SlotVariant.BEGGAR] = coinBeggarReward,
	[SlotVariant.DEVIL_BEGGAR] = hurtBeggarReward,
	[SlotVariant.BOMB_BUM] = function(player)
		player:AddBombs(1)
	end,
	[SlotVariant.KEY_MASTER] = function(player)
		player:AddKeys(1)
	end,
	[SlotVariant.SHELL_GAME] = coinBeggarReward,
	[SlotVariant.BATTERY_BUM] = coinBeggarReward,
	[SlotVariant.HELL_GAME] = hurtBeggarReward,
	[SlotVariant.ROTTEN_BEGGAR] = coinBeggarReward
}

ALTRUISM.PreCallbackBeggars = Mod:Set({
	SlotVariant.DEVIL_BEGGAR,
	SlotVariant.HELL_GAME
})

---@param slot EntitySlot
---@param collider Entity
function ALTRUISM:PreBeggarCollision(slot, collider)
	local player = collider:ToPlayer()

	if not (player
			and player:HasTrinket(ALTRUISM.ID)
			and slot:GetState() == Furtherance.SlotState.IDLE
			and ALTRUISM.ResourceRequirement[slot.Variant]
			and ALTRUISM.ResourceRequirement[slot.Variant](player, slot)
		) then
		return
	end
	local rng = player:GetTrinketRNG(ALTRUISM.ID)
	local smallerMultiplier = (player:GetTrinketMultiplier(ALTRUISM.ID) - 1) * 0.5
	local trinketMult = ALTRUISM.BEGGAR_TRIGGER_ALTRUISM_CHANCE * smallerMultiplier

	if rng:RandomFloat() > ALTRUISM.BEGGAR_TRIGGER_ALTRUISM_CHANCE + trinketMult and not ALTRUISM.DEBUG_REFUND then
		Mod:DebugLog("Failed Altruism chance")
		return
	end

	if rng:RandomFloat() <= ALTRUISM.BEGGAR_HEAL_CHANCE and not ALTRUISM.DEBUG_REFUND then
		Mod:DebugLog("Altruism heal")
		Mod:SpawnNotifyEffect(player.Position, Furtherance.NotifySubtype.HEART)
		Mod.SFXMan:Play(SoundEffect.SOUND_VAMP_GULP)
		player:AddHearts(1)
	elseif ALTRUISM.PreCallbackBeggars[slot.Variant] then
		Mod:DebugLog("Altruism beggar refund")
		ALTRUISM.ResourceRefund[slot.Variant](player, slot)
	else
		local data = Mod:GetData(player)
		data.AltruismBeggarRefund = true
		Mod:DelayOneFrame(function ()
			data.AltruismBeggarRefund = nil
		end)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, CallbackPriority.EARLY, ALTRUISM.PreBeggarCollision)

---@param slot EntitySlot
---@param collider Entity
function ALTRUISM:RefundPlayer(slot, collider)
	local player = collider:ToPlayer()
	if player and Mod:GetData(player).AltruismBeggarRefund then
		Mod:DebugLog("Altruism beggar refund")
		ALTRUISM.ResourceRefund[slot.Variant](player, slot)
		Mod:GetData(player).AltruismBeggarRefund = nil
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_SLOT_COLLISION, CallbackPriority.LATE, ALTRUISM.RefundPlayer)

Mod.ConsoleCommandHelper:Create("altruismrefund", "Beggars will always refund while having Altruism",
	{},
	function(arguments)
		ALTRUISM.DEBUG_REFUND = not ALTRUISM.DEBUG_REFUND
		return "[Furtherance] altruismrefund is now set to " .. tostring(ALTRUISM.DEBUG_REFUND)
	end
)
Mod.ConsoleCommandHelper:SetParent("altruismrefund", "debug")
