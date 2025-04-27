local min = math.min
local SEL = StatusEffectLibrary
local Mod = Furtherance

local CERES = {}

Furtherance.Item.CERES = CERES

CERES.ID = Isaac.GetItemIdByName("Ceres?")

CERES.CREEP_DURATION_ON_HIT = 90

CERES.MODIFIER = Mod.TearModifier.New({
	Name = "Ceres",
	Items = {CERES.ID},
	MinLuck = 0,
	MaxLuck = 9,
	MinChance = 0.05,
	MaxChance = 0.5,
	Color = Color(0, 0.75, 0),
	LaserColor = Color(1, 1, 1, 1, 0, 0, 0, 1, 4, 1, 1)
})

local identifier = "FR_CERES"
SEL.RegisterStatusEffect(identifier, nil, Color(0, 0.75, 0, 1, 0, 0, 0), nil, true)
CERES.STATUS_CERES = SEL.StatusFlag[identifier]

function CERES.MODIFIER:PostNpcHit(hitter, npc)
	local player = Mod:TryGetPlayer(hitter)
	if player then
		SEL:AddStatusEffect(npc, CERES.STATUS_CERES, CERES.CREEP_DURATION_ON_HIT, EntityRef(player))
	end
end

function CERES:GetCeres(player, flag)
	if player:HasCollectible(CERES.ID) then
		player.Damage = player.Damage + 0.5
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, CERES.GetCeres, CacheFlag.CACHE_DAMAGE)

---@param npc EntityNPC
function CERES:OnCeresStatusUpdate(npc)
	local statusData = SEL:GetStatusEffectData(npc, CERES.STATUS_CERES)
	---@cast statusData StatusEffectData
	if statusData.Countdown % 5 == 0 then
		local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, npc.Position,
			Vector.Zero, statusData.Source.Entity):ToEffect()
		---@cast creep EntityEffect
		creep.Timeout = 60
		Mod:GetData(creep).CeresCreepOwner = npc
	end
end

SEL.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.ENTITY_STATUS_EFFECT_UPDATE, CERES.OnCeresStatusUpdate, CERES.STATUS_CERES)

---@param source EntityRef
function CERES:PreventCreepDamage(ent, amount, flags, source)
	if source.Entity and source.Entity:ToEffect() and source.Variant == EffectVariant.PLAYER_CREEP_GREEN then
		local data = Mod:TryGetData(source.Entity)
		if data and data.CeresCreepOwner and GetPtrHash(data.CeresCreepOwner) == GetPtrHash(ent) then
			return false
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CERES.PreventCreepDamage)