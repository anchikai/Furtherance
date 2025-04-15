local Mod = Furtherance

local LITTLE_RAINCOAT = {}

Furtherance.Item.LITTLE_RAINCOAT = LITTLE_RAINCOAT

LITTLE_RAINCOAT.ID = Isaac.GetItemIdByName("Little Raincoat")
LITTLE_RAINCOAT.HEART_CHANCE = 0.06

local floor = math.floor

--TODO: Revisit for rework. Idea:
--every 6 hits triggers power pill effect
--increase power pill dmg to scale off of isaac's tear dmg with a bonus for every empty heart container
--killing an enemy with power pill has a 6% chance to gain 1 empty red heart container
--guarantees power pill will be in rotation
--tick rate also scales off of empty heart containers

function LITTLE_RAINCOAT:RaincoatSize(player, flag)
	local numRaincoats = player:GetCollectibleNum(LITTLE_RAINCOAT.ID)
	if numRaincoats > 0 then
		player.SpriteScale = player.SpriteScale * 0.8 ^ numRaincoats
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LITTLE_RAINCOAT.RaincoatSize, CacheFlag.CACHE_SIZE)

function LITTLE_RAINCOAT:OnFirstPickup(item, charge, firstTime, slot, varData, player)
	if firstTime then
		local color = Mod.Game:GetItemPool():ForceAddPillEffect(PillEffect.PILLEFFECT_POWER)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, color,
			Mod.Room():FindFreePickupSpawnPosition(player.Position, 40), Vector.Zero, player)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, LITTLE_RAINCOAT.OnFirstPickup, LITTLE_RAINCOAT.ID)

---@param ent Entity
function LITTLE_RAINCOAT:RaincoatDamage(ent)
	local player = ent:ToPlayer()
	if player and player:HasCollectible(LITTLE_RAINCOAT.ID) then
		local effects = player:GetEffects()
		effects:AddCollectibleEffect(LITTLE_RAINCOAT.ID)
		local damageCounter = effects:GetCollectibleEffectNum(LITTLE_RAINCOAT.ID)
		if damageCounter >= 6 then
			player:UsePill(PillEffect.PILLEFFECT_POWER, PillColor.PILL_NULL,
			UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)
			effects:RemoveCollectibleEffect(LITTLE_RAINCOAT.ID, -1)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, LITTLE_RAINCOAT.RaincoatDamage, EntityType.ENTITY_PLAYER)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function LITTLE_RAINCOAT:DamageScaling(ent, amount, flags, source, countdown)
	local player = source.Entity and source.Entity:ToPlayer()
	if player
		and player:HasCollectible(LITTLE_RAINCOAT.ID)
		and player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_GAMEKID)
		and countdown > 0
	then
		ent:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
		return {Damage = (15 + player.Damage), DamageCountdown = countdown - floor((player:GetEffectiveMaxHearts() - player:GetHearts()) * 1.5)}
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, LITTLE_RAINCOAT.DamageScaling)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function LITTLE_RAINCOAT:AddHeart(ent, amount, flags, source, countdown)
	local player = source.Entity and source.Entity:ToPlayer()
	if player
		and player:HasCollectible(LITTLE_RAINCOAT.ID)
		and player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_GAMEKID)
		and countdown > 0
		and ent:HasMortalDamage()
		and player:GetCollectibleRNG(LITTLE_RAINCOAT.ID):RandomFloat() <= LITTLE_RAINCOAT.HEART_CHANCE
	then
		player:AddMaxHearts(2)
		Mod:SpawnNotifyEffect(ent.Position, Mod.NotifySubtype.HEART)
		Mod.SFXMan:Play(SoundEffect.SOUND_VAMP_GULP)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, LITTLE_RAINCOAT.AddHeart)
