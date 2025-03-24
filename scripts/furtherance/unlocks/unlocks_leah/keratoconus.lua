local Mod = Furtherance

local KERATOCONUS = {}

Furtherance.Item.KERATOCONUS = KERATOCONUS

KERATOCONUS.ID = Isaac.GetItemIdByName("Keratoconus")

--TODO: Will revisit for tear modifier/status effect implementation

--[[ function Mod:KeratoconusBuffs(player, flag)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_KERATOCONUS) then return end

    if flag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed - 0.5
    elseif flag == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + 8
    end
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.KeratoconusBuffs)

local function clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

function Mod:KeratoconusTear(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if player == nil then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_KERATOCONUS) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_KERATOCONUS)

    local chance = clamp(player.Luck, 0, 14) * 0.25 / 14 + 0.25
    if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
        chance = 1 - (1 - chance) ^ 2
    end

    if rng:RandomFloat() < chance then
        local data = Mod:GetData(tear)
        data.IsKeratoconusTear = true

        local glowEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND, 0, tear.Position, tear.Velocity, tear):ToEffect()
        glowEffect:FollowParent(tear)
        data.KeratoconusGlow = glowEffect
        glowEffect.SpriteScale = glowEffect.SpriteScale / 2.2
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Mod.KeratoconusTear)

function Mod:SizeChanging(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if player == nil then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_KERATOCONUS) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_KERATOCONUS)
    for _, entity in ipairs(Isaac.FindInRadius(tear.Position, 40, EntityPartition.ENEMY)) do
        if entity:IsActiveEnemy(false) and entity:IsVulnerableEnemy() and entity:IsBoss() == false then
            local data = Mod:GetData(entity)
            if data.IsAffectedByKer ~= true then
                data.IsAffectedByKer = true
                if rng:RandomFloat() <= 0.5 then
                    data.KeratoconusScale = 2
                else
                    data.KeratoconusScale = 0.5
                end
                data.AffectedByKerFrame = entity.FrameCount
            end
        end
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, Mod.SizeChanging)

local sizingDuration = 0.5 * 60

local function quadEase(index)
    if index < 0 then
        return 0
    elseif index > 1 then
        return 1
    else
        return -(index - 1) ^ 2 + 1
    end
end

function Mod:SmoothSizing(entity)
    local data = Mod:GetData(entity)
    if not data.IsAffectedByKer then return end

    local index = (entity.FrameCount - data.AffectedByKerFrame) / sizingDuration
    local alpha = quadEase(index)
    local scaleGoal = data.KeratoconusScale
    entity.Scale = 1 * (1 - alpha) + scaleGoal * alpha
end
Mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, Mod.SmoothSizing) ]]