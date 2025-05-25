local Mod = Furtherance

local PHARAOH_CAT = {}

Furtherance.Item.PHARAOH_CAT = PHARAOH_CAT

PHARAOH_CAT.ID = Isaac.GetItemIdByName("Pharaoh Cat")
PHARAOH_CAT.EFFECT = Isaac.GetEntityVariantByName("Bastet Statue")

PHARAOH_CAT.RADIUS = 100

function PHARAOH_CAT:GetRadius()
	local numCat = PlayerManager.GetNumCollectibles(PHARAOH_CAT.ID)
	local radius = PHARAOH_CAT.RADIUS + math.max(0, (PHARAOH_CAT.RADIUS / 2) * (numCat - 1))
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

		room:SetGridPath(gridIndex, 3999)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, PHARAOH_CAT.EFFECT, 0,
			freeGridPos, Vector.Zero, nil)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PHARAOH_CAT.SpawnStatueOnNewRoom)

---@param ent Entity
function PHARAOH_CAT:Die(ent)
	Mod.SFXMan:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
	for _ = 1, 8 do
		local dustCloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0,
			ent.Position, RandomVector():Resized(Mod:RandomNum(4, 7) - Mod:RandomNum()), nil):ToEffect()
		---@cast dustCloud EntityEffect
		dustCloud:SetTimeout(30)
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
	local gridIndex = Mod.Room():GetGridIndex(effect.Position)

	Mod.Room():SetGridPath(gridIndex, 3999)

	Mod.Foreach.ProjectileInRadius(effect.Position, PHARAOH_CAT:GetRadius(), function (projectile, index)
		if not projectile:IsDead() then
			projectile:Die()
		end
	end, nil, nil, {Inverse = true})
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PHARAOH_CAT.OnBastetStatueUpdate, PHARAOH_CAT.EFFECT)

function PHARAOH_CAT:PreGridCollision(player, index, gridEnt)
	if not gridEnt then
		Mod.Foreach.Effect(function(effect)
			local catIndex = Mod.Room():GetGridIndex(effect.Position)
			if index == catIndex then
				return true
			end
		end, PHARAOH_CAT.EFFECT)
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, PHARAOH_CAT.PreGridCollision)
