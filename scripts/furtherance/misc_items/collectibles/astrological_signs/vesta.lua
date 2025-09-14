local Mod = Furtherance

local VESTA = {}

Furtherance.Item.VESTA = VESTA

VESTA.ID = Isaac.GetItemIdByName("Vesta?")

VESTA.TEAR_MODIFIER = Mod.TearModifier.New({
	Name = "Vesta",
	Items = {VESTA.ID},
	MinChance = 0.1,
	MaxChance = 1,
	MinLuck = 0,
	MaxLuck = 10,
	ShouldAffectBombs = true
})

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function VESTA:Stats(player, cacheFlag)
	if player:HasCollectible(VESTA.ID) then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 2 * Mod:GetPlayerDamageMultiplier(player)
		elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			player.TearColor = Color(1, 1, 1, 0.8)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, VESTA.Stats, CacheFlag.CACHE_DAMAGE)
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, VESTA.Stats, CacheFlag.CACHE_TEARCOLOR)

---@param tear EntityTear
function VESTA:PostFireTear(tear)
	local player = Mod:TryGetPlayer(tear.SpawnerEntity)
	if player and player:HasCollectible(VESTA.ID) then
		tear:ChangeVariant(TearVariant.BLUE)
		local sprite = tear:GetSprite()
		tear.Scale = 0.1
		sprite:Load("gfx/tear_vesta.anm2", true)
		sprite:Play("Rotate0", true)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_FIRE_TEAR, CallbackPriority.EARLY, VESTA.PostFireTear)

---@param bomb EntityBomb
function VESTA:PostFireBomb(bomb)
	local player = Mod:TryGetPlayer(bomb.SpawnerEntity)
	if player and player:HasCollectible(VESTA.ID) then
		bomb:SetScale(0.1)
		bomb:SetLoadCostumes(true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, VESTA.PostFireBomb)

---@param laser EntityLaser
function VESTA:PostFireLaser(laser)
	local player = Mod:TryGetPlayer(laser.SpawnerEntity)
	if player and player:HasCollectible(VESTA.ID) then
		--RGON my beloved
		laser:SetScale(0.353553)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, VESTA.PostFireLaser)

function VESTA.TEAR_MODIFIER:PostFire(object)
	if object:ToTear() or object:ToBomb() then
		object:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_QUADSPLIT)
	end
end

function VESTA.TEAR_MODIFIER:PostUpdate(object)
	local player = Mod:TryGetPlayer(object.SpawnerEntity)
	if player and object:ToLaser() and not Mod:HasBitFlags(player.TearFlags, TearFlags.TEAR_QUADSPLIT) then
		object:AddTearFlags(TearFlags.TEAR_QUADSPLIT)
	end
end

function VESTA.TEAR_MODIFIER:PostNpcHit(hitter, npc)
	if hitter:ToLaser() and hitter:HasTearFlags(TearFlags.TEAR_QUADSPLIT) then
		--Too lazy to reimplement unlike others that are just status effects
	end
end
