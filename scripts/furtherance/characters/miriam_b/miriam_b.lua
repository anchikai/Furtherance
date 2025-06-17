local sin = math.sin
local floor = math.floor
local Mod = Furtherance

local MIRIAM_B = {}

Furtherance.Character.MIRIAM_B = MIRIAM_B

MIRIAM_B.HEALH_DRAIN_COUNTDOWN = 30 * 3
MIRIAM_B.BASE_HEAL_DAMAGE_THRESHOLD = 20
MIRIAM_B.ADD_SCALING_DAMAGE_THRESHOLD = 5

MIRIAM_B.FEAR_BASE_RADIUS = 62.5
MIRIAM_B.FEAR_BASE_SCALE = 0.75
MIRIAM_B.FEAR_DURATION = 2
MIRIAM_B.FEAR_SCALE_PER_HEART = 0.05

local heartHUD = Sprite(Mod:GetHealthPath(), true)
heartHUD:SetFrame("RedHeartFull", 0)

function MIRIAM_B:GetHealDamageThreshold()
	return MIRIAM_B.BASE_HEAL_DAMAGE_THRESHOLD + MIRIAM_B.ADD_SCALING_DAMAGE_THRESHOLD * Mod.Level():GetAbsoluteStage()
end

---@param player EntityPlayer
function MIRIAM_B:IsMiriamB(player)
	return player:GetPlayerType() == Mod.PlayerType.MIRIAM_B
end

---@param player EntityPlayer
function MIRIAM_B:MiriamBHasBirthright(player)
	return MIRIAM_B:IsMiriamB(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

---@param player EntityPlayer
function MIRIAM_B:OnPlayerInit(player)
	if MIRIAM_B:IsMiriamB(player) then
		local deathAura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 3, player.Position, Vector.Zero, player):ToEffect()
		---@cast deathAura EntityEffect
		deathAura.RenderZOffset = -1000
		deathAura.Parent = player
		deathAura:FollowParent(player)
		deathAura:AddEntityFlags(EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_DONT_OVERWRITE)
		Mod:GetData(deathAura).MiriamBFearAura = true
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MIRIAM_B.OnPlayerInit)

function MIRIAM_B:NoSoulHearts(player)
	if MIRIAM_B:IsMiriamB(player) then
		return 0
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, MIRIAM_B.NoSoulHearts, AddHealthType.SOUL)
Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, MIRIAM_B.NoSoulHearts, AddHealthType.BLACK)

---@param player EntityPlayer
function MIRIAM_B:TryHealFromDamageDealt(player)
	local data = Mod:GetData(player)
	local healed = false
	local threshold = MIRIAM_B:GetHealDamageThreshold()
	while (data.MiriamBLifeSteal or 0) >= threshold do
		data.MiriamBLifeSteal = data.MiriamBLifeSteal - threshold
		player:AddHearts(1)
		healed = true
	end
	if healed then
		Mod:SpawnNotifyEffect(player.Position, Furtherance.NotifySubtype.HEART)
		Mod.SFXMan:Play(SoundEffect.SOUND_VAMP_GULP)
	end
end

---@param player EntityPlayer
function MIRIAM_B:HealthDrain(player)
	if not Mod.Item.POLARITY_SHIFT:IsChainLightningActive(player) then return end
	if player:GetHearts() == 0 then
		player:UseActiveItem(Mod.Item.POLARITY_SHIFT.ID_2, UseFlag.USE_NOANIM, ActiveSlot.SLOT_POCKET)
		MIRIAM_B.SPIRITUAL_WOUND:TryStopAttackSFX(player)
		return
	end
	local drainCountdown = MIRIAM_B.HEALH_DRAIN_COUNTDOWN
	if MIRIAM_B:MiriamBHasBirthright(player) then
		drainCountdown = drainCountdown * 2
	end
	local data = Mod:GetData(player)

	if data and data.FrameStartedPolarityShift then
		local frameReference = (player.FrameCount - data.FrameStartedPolarityShift)
		if frameReference > 0 and frameReference % drainCountdown == 0 and player:GetHearts() > 0 then
			player:AddHearts(-1)
		end
	end
end

---@param player EntityPlayer
function MIRIAM_B:OnPeffectUpdate(player)
	MIRIAM_B:HealthDrain(player)
	MIRIAM_B:TryHealFromDamageDealt(player)
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MIRIAM_B.OnPeffectUpdate, Mod.PlayerType.MIRIAM_B)

HudHelper.RegisterHUDElement({
	Name = "Tainted Miriam Health Drain",
	Priority = HudHelper.Priority.LOWEST,
	Condition = function(player, playerHUDIndex, hudLayout)
		return MIRIAM_B:IsMiriamB(player)
			and not Mod:HasBitFlags(Mod.Level():GetCurses(), LevelCurse.CURSE_OF_THE_UNKNOWN)
			and Mod.Item.POLARITY_SHIFT:IsChainLightningActive(player)
	end,
	OnRender = function(player, playerHUDIndex, hudLayout, position, maxColumns)
		local alpha = (sin(Mod.Game:GetFrameCount() * 4 * 1.5 * math.pi / 180) + 1) / 2
		local playerHeartsHUD = Mod.HUD:GetPlayerHUD(player:GetPlayerIndex()):GetHearts()

		for i, heart in ipairs(playerHeartsHUD) do
			local offset = 0
			local anim = heart:GetHeartAnim()
			if (string.find(anim, "Bone")
					or string.find(anim, "Red")
					or string.find(anim, "Rotten"))
				and not string.find(anim, "Empty")
			then
				local pos = Vector(position.X + ((i + offset - 1) % maxColumns) * 12,
					position.Y + floor((i + offset - 1) / maxColumns) * 10)
				heartHUD.Color = Color(0, 0, 0, alpha / 2 + 0.25, 0.5 - alpha / 2, 0, 0)
				heartHUD:Render(pos)
			end
		end
	end
}, HudHelper.HUDType.HEALTH)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
function MIRIAM_B:AddToDamageCounter(ent, amount, flags, source)
	local player = Mod:TryGetPlayer(source.Entity, true)
	if player
		and MIRIAM_B:IsMiriamB(player)
		and Mod:HasBitFlags(flags, DamageFlag.DAMAGE_LASER)
		and ent:ToNPC()
		and not Mod.Item.POLARITY_SHIFT:IsChainLightningActive(player)
	then
		local data = Mod:GetData(player)
		data.MiriamBLifeSteal = (data.MiriamBLifeSteal or 0) + amount
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, MIRIAM_B.AddToDamageCounter)

---@param effect EntityEffect
function MIRIAM_B:FearInRadius(effect)
	if effect.SubType == 3
		and Mod:GetData(effect).MiriamBFearAura
	then
		if not effect.Parent or not effect.Parent:Exists() then
			effect:Remove()
			return
		end
		local player = effect.Parent:ToPlayer()
		if not player then return end
		local source = EntityRef(player)
		local size = MIRIAM_B.FEAR_BASE_SCALE + (player:GetHearts() * MIRIAM_B.FEAR_SCALE_PER_HEART)
		effect.SpriteScale = Vector(size, size)
		Mod.Foreach.NPCInRadius(effect.Position, MIRIAM_B.FEAR_BASE_RADIUS * size, function (npc, index)
			if npc:IsActiveEnemy(false) then
				npc:AddFear(source, 2)
			end
		end, nil, nil)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, MIRIAM_B.FearInRadius, EffectVariant.HALO)

if Isaac.IsInGame() then
	Mod.Foreach.Effect(function (effect, index)
		Mod.Foreach.PlayerInRadius(effect.Position, 5, function (player)
			Mod:GetData(player).MiriamBFearAura = true
		end)
	end, EffectVariant.HALO, 3)
end

--#region No Soul Hearts

---@param entType EntityType
---@param variant PickupVariant
---@param subtype integer
---@param spawner Entity
---@param seed integer
function MIRIAM_B:ReplaceHearts(entType, variant, subtype, pos, vel, spawner, seed)
	if entType == EntityType.ENTITY_PICKUP
		and variant == PickupVariant.PICKUP_HEART
		and PlayerManager.AnyoneIsPlayerType(Mod.PlayerType.MIRIAM_B)
		and (Mod.HeartGroups.Soul[subtype] or Mod.HeartGroups.Black[subtype])
	then
		local anyoneNotMiriamB = Mod.Foreach.Player(function (player, index)
			if not MIRIAM_B:IsMiriamB(player) and not Mod.Character.LEAH_B:IsLeahB(player) then
				return true
			end
		end)
		if anyoneNotMiriamB then return end
		return {entType, variant, (Mod.HeartAmount[subtype] or 0) == 1 and HeartSubType.HEART_HALF or HeartSubType.HEART_FULL, seed}
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, CallbackPriority.IMPORTANT, MIRIAM_B.ReplaceHearts)

---@param pickup EntityPickup
---@param collider Entity
function MIRIAM_B:NoSoulHeartCollision(pickup, collider)
	local player = collider:ToPlayer()
	if player
		and MIRIAM_B:IsMiriamB(player)
		and Mod.HeartGroups.SoulHearts[pickup.SubType]
		and not Mod:CanCollectHeart(player, pickup.SubType)
	then
		return pickup:IsShopItem()
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, MIRIAM_B.NoSoulHeartCollision, PickupVariant.PICKUP_HEART)

---@param effect EntityEffect
function MIRIAM_B:StopFearAuraReflection(effect)
	if effect.SubType == 3 and Mod.Room():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, MIRIAM_B.StopFearAuraReflection, EffectVariant.HALO)

--#endregion

Mod.Include("scripts.furtherance.characters.miriam_b.polarity_shift")
Mod.Include("scripts.furtherance.characters.miriam_b.spiritual_wound")
