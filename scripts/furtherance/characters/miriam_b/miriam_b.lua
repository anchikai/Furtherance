local sin = math.sin
local floor = math.floor
local Mod = Furtherance

local MIRIAM_B = {}

Furtherance.Character.MIRIAM_B = MIRIAM_B

MIRIAM_B.HEALTH_DRAIN_RATE = 30 * 5
MIRIAM_B.BASE_HEAL_DAMAGE_THRESHOLD = 12
MIRIAM_B.ADD_SCALING_DAMAGE_THRESHOLD = 4

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
		if not player:HasCollectible(Mod.Item.SPIRITUAL_WOUND.ID) then
			player:AddInnateCollectible(Mod.Item.SPIRITUAL_WOUND.ID)
		end
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
		Mod.Item.SPIRITUAL_WOUND:TryStopAttackSFX(player)
		player:UseActiveItem(Mod.Item.POLARITY_SHIFT.ID_2, UseFlag.USE_NOANIM, ActiveSlot.SLOT_POCKET)
		return
	end
	local drainRate = MIRIAM_B.HEALTH_DRAIN_RATE
	if MIRIAM_B:MiriamBHasBirthright(player) then
		drainRate = drainRate * 2
	end
	local data = Mod:GetData(player)

	if data and data.FrameStartedPolarityShift then
		local frameReference = (player.FrameCount - data.FrameStartedPolarityShift)
		if frameReference > 0 and frameReference % drainRate == 0 and player:GetHearts() > 0 then
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
		Mod:ForEachEnemy(function (npc)
			npc:AddFear(source, 2)
		end, true, effect.Position, MIRIAM_B.FEAR_BASE_RADIUS * size)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, MIRIAM_B.FearInRadius, EffectVariant.HALO)

if Isaac.IsInGame() then
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 3)) do
		for _, _ in ipairs(Isaac.FindInRadius(ent.Position, 5, EntityPartition.PLAYER)) do
			Mod:GetData(ent).MiriamBFearAura = true
		end
	end
end

Mod.Include("scripts.furtherance.characters.miriam_b.polarity_shift")
Mod.Include("scripts.furtherance.characters.miriam_b.spiritual_wound")
