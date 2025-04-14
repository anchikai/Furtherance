local Mod = Furtherance

local MIRIAM = {}

Furtherance.Character.MIRIAM = MIRIAM

MIRIAM.WHIRLPOOL_THRESHOLD = 12
MIRIAM.WHIRLPOOL = Isaac.GetEntityVariantByName("Miriam Whirlpool")

---@param player EntityPlayer
function MIRIAM:IsMiriam(player)
	return player:GetPlayerType() == Mod.PlayerType.MIRIAM
end

---@param player EntityPlayer
function MIRIAM:OnPlayerInit(player)
	if MIRIAM:IsMiriam(player) then
		player:AddInnateCollectible(Mod.Item.POLYDIPSIA.ID)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MIRIAM.OnPlayerInit)

---@param ent Entity @The source of the Whirlpool
function MIRIAM:SpawnWhirlpool(ent)
	local pos = ent:ToLaser() and ent:ToLaser():GetEndPoint() or ent.Position
end

---@param dir Vector
---@param amount integer
---@param owner EntityPlayer | EntityFamiliar
---@param weapon Weapon
function MIRIAM:WhirlpoolOnFire(dir, amount, owner, weapon)
	local player = Mod:TryGetPlayer(owner)
	if not player or not MIRIAM:IsMiriam(player) then return end
	local previousNum = weapon:GetNumFired() - amount

	if (previousNum % MIRIAM.WHIRLPOOL_THRESHOLD) + amount >= MIRIAM.WHIRLPOOL_THRESHOLD then
		Mod:GetData(player).MiriamQueueWhirlpoolShot = true
		Mod:DelayOneFrame(function() Mod:GetData(player).MiriamQueueWhirlpoolShot = false end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, MIRIAM.WhirlpoolOnFire)

---@param weaponEnt Entity
function MIRIAM:OnWeaponEntityFire(weaponEnt)
	local player = Mod:TryGetPlayer(weaponEnt)
	if not player then return end
	local data = Mod:GetData(player)
	if data.MiriamQueueWhirlpoolShot then
		Mod:GetData(weaponEnt).MiriamWhirlpoolShot = true
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, MIRIAM.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, MIRIAM.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, MIRIAM.OnWeaponEntityFire, EffectVariant.ROCKET)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_SWORD, MIRIAM.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_KNIFE, MIRIAM.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, MIRIAM.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE_BALL, MIRIAM.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, MIRIAM.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, MIRIAM.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BONE_CLUB, MIRIAM.OnWeaponEntityFire)

---@param tear EntityTear
function MIRIAM:OnTearDeath(tear)
	local data = Mod:TryGetData(tear)
	if data and data.MiriamWhirlpoolShot then
		MIRIAM:SpawnWhirlpool(tear)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, MIRIAM.OnTearDeath)

---@param tear EntityTear
function MIRIAM:OnLudoTearUpdate(tear)
	if not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then return end
	local player = Mod:TryGetPlayer(tear)
	if not player then return end
	local data = Mod:GetData(player)
	if data.MiriamQueueWhirlpoolShot then
		MIRIAM:SpawnWhirlpool(tear)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, MIRIAM.OnLudoTearUpdate)

---@param bomb EntityBomb
function MIRIAM:OnBombExplode(bomb)
	local data = Mod:TryGetData(bomb)
	if data and data.MiriamWhirlpoolShot then
		MIRIAM:SpawnWhirlpool(bomb)
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, MIRIAM.OnBombExplode)

---@param knife EntityKnife
function MIRIAM:SpawnWhirlpoolAtKnifePeak(knife)
	local player = Mod:TryGetPlayer(knife)
	if not player then return end
	local pData = Mod:GetData(player)
	if pData.MiriamQueueWhirlpoolShot then
		Mod:GetData(knife).MiriamWhirlpoolShot = true
	end
	local kData = Mod:TryGetData(knife)
	if kData and kData.MiriamWhirlpoolShot and knife:IsFlying() then
		if not kData.MiriamWhirlpoolHighestDistance
			or kData.MiriamWhirlpoolHighestDistance < knife:GetKnifeDistance()
		then
			kData.MiriamWhirlpoolHighestDistance = knife:GetKnifeDistance()
		else
			kData.MiriamWhirlpoolShot = nil
			MIRIAM:SpawnWhirlpool(knife)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, MIRIAM.SpawnWhirlpoolAtKnifePeak)

---@param laser EntityLaser
function MIRIAM:WhirlpoolAtLaserPeak(laser)
	local data = Mod:TryGetData(laser)
	if data and data.MiriamWhirlpoolShot then
		data.MiriamWhirlpoolShot = nil
		MIRIAM:SpawnWhirlpool(laser)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, MIRIAM.WhirlpoolAtLaserPeak)