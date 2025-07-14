local Mod = Furtherance
local max = Mod.math.max

local PHARAOH_CAT = {}

Furtherance.Item.PHARAOH_CAT = PHARAOH_CAT

PHARAOH_CAT.ID = Isaac.GetItemIdByName("Pharaoh Cat")
PHARAOH_CAT.EFFECT = Isaac.GetEntityVariantByName("Bastet Statue")

PHARAOH_CAT.RADIUS = 100

function PHARAOH_CAT:GetRadius()
	local numCat = PlayerManager.GetNumCollectibles(PHARAOH_CAT.ID)
	local radius = PHARAOH_CAT.RADIUS + max(0, (PHARAOH_CAT.RADIUS / 2) * (numCat - 1))
	return radius
end

function PHARAOH_CAT:SpawnStatueOnNewRoom()
	local room = Mod.Room()
	if room:GetType() ~= RoomType.ROOM_DUNGEON
		and not room:IsClear()
		and PlayerManager.AnyoneHasCollectible(PHARAOH_CAT.ID)
	then
		local gridIndex = room:GetRandomTileIndex(room:GetSpawnSeed())
		local gridPos = room:GetGridPosition(gridIndex)
		local freeGridPos = room:FindFreeTilePosition(gridPos, 0)

		Isaac.Spawn(EntityType.ENTITY_EFFECT, PHARAOH_CAT.EFFECT, 0,
			freeGridPos, Vector.Zero, nil)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PHARAOH_CAT.SpawnStatueOnNewRoom)

---@param ent Entity
function PHARAOH_CAT.Die(ent)
	Mod.SFXMan:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
	local dustClouds = Mod.Spawn.DustClouds(ent.Position)
	for i, dustCloud in ipairs(dustClouds) do
		if i % 3 == 0 then
			dustCloud.Color = Color(1, 1, 1, 1, 0.7, 0.5, 0.15)
		else
			dustCloud.Color = Color(0.25, 0.25, 0.25)
		end
	end
	ent:Remove()
end

function PHARAOH_CAT:OnRoomClear()
	Mod.Foreach.Effect(PHARAOH_CAT.Die, PHARAOH_CAT.EFFECT)
end

Mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, PHARAOH_CAT.OnRoomClear)

---@param effect EntityEffect
function PHARAOH_CAT:OnEffectInit(effect)
	effect:GetSprite():SetRenderFlags(AnimRenderFlags.ENABLE_NULL_LAYER_LIGHTING)
	local haloSize = PHARAOH_CAT:GetRadius() / PHARAOH_CAT.RADIUS
	effect:GetSprite():GetLayer(2):SetSize(Vector(haloSize, haloSize))
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PHARAOH_CAT.OnEffectInit, PHARAOH_CAT.EFFECT)

---@param effect EntityEffect
function PHARAOH_CAT:OnBastetStatueUpdate(effect)

	Mod.Foreach.ProjectileInRadius(effect.Position, PHARAOH_CAT:GetRadius(), function (projectile, index)
		if not projectile:IsDead() then
			projectile:Die()
		end
	end, nil, nil, {Inverse = true})
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PHARAOH_CAT.OnBastetStatueUpdate, PHARAOH_CAT.EFFECT)
