local Mod = Furtherance
local sin = math.sin
local ceil = math.ceil
local min = math.min
local max = math.max

local LEAH_B = {}

Furtherance.Character.LEAH_B = LEAH_B

Mod.Include("scripts.furtherance.characters.leah_b.shattered_heart")

LEAH_B.HEART_DECAY_TIMER = 600

LEAH_B.SpecialHeartToRedHeart = {
	[HeartSubType.HEART_HALF_SOUL] = HeartSubType.HEART_HALF
}

LEAH_B.StatTable = {
	{ Name = "Damage",       Flag = CacheFlag.CACHE_DAMAGE,    Buff = 0.1 },
	{ Name = "MaxFireDelay", Flag = CacheFlag.CACHE_FIREDELAY, Buff = 0.05},
	{ Name = "TearRange",    Flag = CacheFlag.CACHE_RANGE,     Buff = 0.25 * Mod.RANGE_BASE_MULT },
	{ Name = "ShotSpeed",    Flag = CacheFlag.CACHE_SHOTSPEED, Buff = 0.2 },
	{ Name = "MoveSpeed",    Flag = CacheFlag.CACHE_SPEED,     Buff = 0.02 },
}

function LEAH_B:IsLeahB(player)
	return player:GetPlayerType() == Mod.PlayerType.LEAH_B
end

local heartCache = Mod:Set({
	CacheFlag.CACHE_DAMAGE,
	CacheFlag.CACHE_FIREDELAY,
	CacheFlag.CACHE_RANGE,
	CacheFlag.CACHE_SHOTSPEED,
	CacheFlag.CACHE_SPEED
})

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function LEAH_B:HealthyStatUp(player, cacheFlag)
	if not LEAH_B:IsLeahB(player) then return end
	local hearts = max(0, player:GetHearts() - 2)
	if heartCache[cacheFlag] then
		for _, stat in ipairs(LEAH_B.StatTable) do
			if stat.Flag == cacheFlag then
				if cacheFlag == CacheFlag.CACHE_FIREDELAY then
					player[stat.Name] = Mod:TearsUp(player[stat.Name], hearts * stat.Buff)
				else
					player[stat.Name] = player[stat.Name] + hearts * stat.Buff
				end
				break
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LEAH_B.HealthyStatUp)

function LEAH_B:GetDamageRequirement()
	return 55 + 15 * Mod.Level():GetAbsoluteStage()
end

---@param player EntityPlayer
function LEAH_B:HeartDecay(player)
	local data = Mod:GetData(player)
	local damageNeeded = LEAH_B:GetDamageRequirement()
	while (data.LeahBBrokenDamage or 0) > damageNeeded do
		data.LeahBBrokenDamage = data.LeahBBrokenDamage - damageNeeded
		player:AddBrokenHearts(-1)
		player:AddMaxHearts(2)
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	end
	if player:GetBrokenHearts() < player:GetHeartLimit() - 1 then
		data.LeahBHeartDecayCountdown = data.LeahBHeartDecayCountdown or LEAH_B.HEART_DECAY_TIMER
		data.LeahBHeartDecayCountdown = data.LeahBHeartDecayCountdown - 1
		if data.LeahBHeartDecayCountdown == 0 then
			player:AddBrokenHearts(1)
			data.LeahBHeartDecayCountdown = LEAH_B.HEART_DECAY_TIMER
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, LEAH_B.HeartDecay, Mod.PlayerType.LEAH_B)

---@param player EntityPlayer
function LEAH_B:UpdateStatsOnHeart(player)
	if LEAH_B:IsLeahB(player) then
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_HEARTS, LEAH_B.UpdateStatsOnHeart)

function LEAH_B:UpdateStatsOnDamage(ent, amount)
	local player = ent:ToPlayer()
	---@cast player EntityPlayer
	if LEAH_B:IsLeahB(player) and amount > 0 then
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, LEAH_B.UpdateStatsOnDamage, EntityType.ENTITY_PLAYER)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function LEAH_B:RemoveBrokensFromDamage(ent, amount, flags, source, countdown)
	local player = Mod:TryGetPlayer(source)
	if player and LEAH_B:IsLeahB(player) and Mod:IsValidEnemyTarget(ent) then
		local data = Mod:GetData(player)
		local damageDealt = min(ent.HitPoints, amount)
		data.LeahBBrokenDamage = (data.LeahBBrokenDamage or 0) + damageDealt
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, LEAH_B.RemoveBrokensFromDamage)

local brokenHeart = Sprite("gfx/ui/ui_brokenheart.anm2", true)
brokenHeart:SetFrame(brokenHeart:GetDefaultAnimation(), 0)

HudHelper.RegisterHUDElement({
	Name = "Leah B Heart Decay",
	Priority = HudHelper.Priority.NORMAL,
	Condition = function (player, playerHUDIndex, hudLayout)
		return LEAH_B:IsLeahB(player)
			and player:GetBrokenHearts() < 11
	end,
	OnRender = function (player, playerHUDIndex, hudLayout, position, maxColumns, _, numPlayers)
		local data = Mod:GetData(player)
		local alpha = (sin(Mod.Game:GetFrameCount() * 4 * 1.5 * math.pi / 180) + 1) / 2
		local allHearts = ceil((player:GetEffectiveMaxHearts() + player:GetSoulHearts()) / 2)
		local brokenHearts = player:GetBrokenHearts()
		local offset = 0
		if allHearts == ceil(player:GetHeartLimit() / 2) then
			offset = allHearts - 1
		else
			offset = allHearts + brokenHearts
		end
		local pos = Vector(position.X + (offset % maxColumns) * 12,
			position.Y + math.floor(offset / maxColumns) * 10)
		brokenHeart.Color = Color(0, 0, 0, alpha / 2 + 0.25, 0, 0, 0)
		brokenHeart:Render(pos)
		if data.LeahBHeartDecayCountdown then
			Isaac.RenderText(data.LeahBHeartDecayCountdown, 50, 50, 1, 1, 1, 1)
		end
	end
}, HudHelper.HUDType.HEALTH)

function LEAH_B:Render()
	local player = Isaac.GetPlayer()
	local data = Mod:GetData(player)
	if data.LeahBBrokenDamage then
		Isaac.RenderText(data.LeahBBrokenDamage, 50, 70, 1, 1, 1, 1)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_RENDER, LEAH_B.Render)

---@param entType EntityType
---@param variant PickupVariant
---@param subtype integer
---@param spawner Entity
---@param seed integer
function LEAH_B:ReplaceHearts(entType, variant, subtype, pos, spawner, seed)
	if entType == EntityType.ENTITY_PICKUP
		and variant == PickupVariant.PICKUP_HEART
		and PlayerManager.AnyoneIsPlayerType(Mod.PlayerType.LEAH_B)
		and not Mod.Core.HEARTS.RedHearts[subtype]
	then
		return {entType, variant, LEAH_B.SpecialHeartToRedHeart[subtype] or HeartSubType.HEART_FULL, seed}
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, CallbackPriority.IMPORTANT, LEAH_B.ReplaceHearts)