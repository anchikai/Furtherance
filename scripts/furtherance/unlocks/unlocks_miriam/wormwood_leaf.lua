local Mod = Furtherance

local WORMWOOD_LEAF = {}

Furtherance.Trinket.WORMWOOD_LEAF = WORMWOOD_LEAF

WORMWOOD_LEAF.ID = Isaac.GetTrinketIdByName("Wormwood Leaf")

WORMWOOD_LEAF.CHANCE = 0.1

local function rockCrumble(pos)
	Mod.SFXMan:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
	for _ = 1, 5 do
		local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, pos, RandomVector():Resized(3), nil):ToEffect()
		---@cast effect EntityEffect
		effect:SetTimeout(30)
		effect.SpriteOffset = Vector(0, -10)
	end
end

---@param ent Entity
---@param flags DamageFlag
function WORMWOOD_LEAF:TryPreventDamage(ent, amount, flags, source, countdown)
	local player = ent:ToPlayer()
	if player and player:HasTrinket(WORMWOOD_LEAF.ID) then
		local effects = player:GetEffects()
		if effects:HasTrinketEffect(WORMWOOD_LEAF.ID) then
			if not Mod:HasAnyBitFlags(flags, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES) then
				return false
			end
		elseif not Mod:HasAnyBitFlags(flags, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES) then
			local rng = player:GetTrinketRNG(WORMWOOD_LEAF.ID)
			local trinketMult = player:GetTrinketMultiplier(WORMWOOD_LEAF.ID)
			if rng:RandomFloat() <= WORMWOOD_LEAF.CHANCE * trinketMult then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player)
				player:GetEffects():AddTrinketEffect(WORMWOOD_LEAF.ID)
				rockCrumble(player.Position)
				return false
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, WORMWOOD_LEAF.TryPreventDamage, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
---@param itemConfig ItemConfigItem
function WORMWOOD_LEAF:OnEffectExpire(player, itemConfig)
	if itemConfig:IsTrinket()
		and itemConfig.ID == WORMWOOD_LEAF.ID
	then
		rockCrumble(player.Position)
		player:SetMinDamageCooldown(30)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, WORMWOOD_LEAF.OnEffectExpire)

---@param entity Entity
---@param button ButtonAction
function WORMWOOD_LEAF:NoMovement(entity, _, button)
	local player = entity and entity:ToPlayer()
	if player
		and player:GetEffects():HasTrinketEffect(WORMWOOD_LEAF.ID)
		and (button == ButtonAction.ACTION_LEFT
		or button == ButtonAction.ACTION_RIGHT
		or button == ButtonAction.ACTION_UP
		or button == ButtonAction.ACTION_DOWN)
	then
		return 0
	end
end

Mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, WORMWOOD_LEAF.NoMovement, InputHook.GET_ACTION_VALUE)
