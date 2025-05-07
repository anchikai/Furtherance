local Mod = Furtherance

local TAMBOURINE = {}

Furtherance.Item.TAMBOURINE = TAMBOURINE

TAMBOURINE.ID = Isaac.GetItemIdByName("Tambourine")

TAMBOURINE.SFX = Isaac.GetSoundIdByName("Tambourine")

---@param player EntityPlayer
function TAMBOURINE:OnUse(_, _, player)
	local source = EntityRef(player)
	Mod.Foreach.NPCInRadius(player.Position, 125, function (npc, index)
		if npc:IsActiveEnemy(false) then
			local dir = (npc.Position - player.Position):Resized(15)
			npc:AddKnockback(source, dir, 15, true)
		end
	end)
	local bigSplash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, player.Position, Vector.Zero, nil):ToEffect()
	---@cast bigSplash EntityEffect
	bigSplash.SpriteScale = Vector(1.5, 1.5)
	local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 0, player.Position, Vector.Zero, nil):ToEffect()
	---@cast splash EntityEffect
	splash.SpriteScale = Vector(5, 5)
	splash.Color = Color(1,1,1,1,0.25,0.5,1)
	local ripple = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_RIPPLE, 0, player.Position, Vector.Zero, nil):ToEffect()
	---@cast ripple EntityEffect
	ripple.SpriteScale = Vector(3, 3)
	Mod.SFXMan:Play(SoundEffect.SOUND_BOSS2_DIVE, 0.4, 2, false, 1.5)
	Mod.SFXMan:Play(TAMBOURINE.SFX)
	local creep = Mod.Item.POLYDIPSIA:SpawnPolydipsiaCreep(player, player)
	creep.SpriteScale = Vector.Zero
	creep.Timeout = 30
	Mod:GetData(creep).TambourinePolydipsiaSizeUp = true
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, TAMBOURINE.OnUse, TAMBOURINE.ID)

---@param effect EntityEffect
function TAMBOURINE:RapidlyUpdateSize(effect)
	local data = Mod:TryGetData(effect)
	if data and data.TambourinePolydipsiaSizeUp then
		if effect.SpriteScale.X < 2.5 then
			local scale = effect.SpriteScale
			scale:Lerp(Vector(4, 4), 0.1)
		else
			data.TambourinePolydipsiaSizeUp = nil
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, TAMBOURINE.RapidlyUpdateSize, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL)