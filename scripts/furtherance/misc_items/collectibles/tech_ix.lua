local Mod = Furtherance

local TECH_IX = {}

Furtherance.Item.TECH_IX = TECH_IX

TECH_IX.ID = Isaac.GetItemIdByName("Tech IX")

TECH_IX.LASER_COLOR = Color(0, 1, 0, 1, 0, 1, 0.6)
TECH_IX.FIREDELAY_UP = 5

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function TECH_IX:EvaluteCache(player, cacheFlag)
	if not player:HasCollectible(TECH_IX.ID) then return end
	if cacheFlag == CacheFlag.CACHE_WEAPON then
		Mod:DelayOneFrame(function()
			local weapon = player:GetWeapon(1)
			local weaponType = weapon and weapon:GetWeaponType()

			if weapon
				and (
					weaponType == WeaponType.WEAPON_BRIMSTONE
					or weaponType == WeaponType.WEAPON_TECH_X
					or weaponType == WeaponType.WEAPON_LASER
				)
				and not Mod:HasBitFlags(weapon:GetModifiers(), WeaponModifier.LUDOVICO_TECHNIQUE)
			then
				player:SetWeapon(Isaac.CreateWeapon(WeaponType.WEAPON_TEARS, player), 1)
			elseif weapon and weaponType == WeaponType.WEAPON_LUDOVICO_TECHNIQUE then
				local newWeapon = Isaac.CreateWeapon(WeaponType.WEAPON_LASER, player)
				player:SetWeapon(newWeapon, 1)
			end
		end)
	elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
		player.LaserColor = TECH_IX.LASER_COLOR
	elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
		player.MaxFireDelay = player.MaxFireDelay + TECH_IX.FIREDELAY_UP
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
		player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, TECH_IX.EvaluteCache)

local weaponOverridingItems = {
	CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE,
	CollectibleType.COLLECTIBLE_TECHNOLOGY,
	CollectibleType.COLLECTIBLE_BRIMSTONE,
	CollectibleType.COLLECTIBLE_TECH_X
}

---A weapon cache doesn't actually re-evaluate your weapon...for some reason. This tricks the game into doing so.
---@param player EntityPlayer
function TECH_IX:ReevaluateWeaponOnRemove(player)
	for _, itemID in ipairs(weaponOverridingItems) do
		if player:HasCollectible(itemID) then
			player:BlockCollectible(itemID)
			player:UnblockCollectible(itemID)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, TECH_IX.ReevaluateWeaponOnRemove, TECH_IX.ID)

---@param ent Entity
---@param pos Vector
---@param size number
---@param vel Vector
function TECH_IX:FireTechIXRing(ent, pos, size, vel)
	local owner = Mod:TryGetPlayer(ent, true, true)
	if not owner then return end
	local sizeMult = 1.5
	local damageMult = 0.66
	if owner:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS) then
		sizeMult = sizeMult + 2
	end
	local weapon = owner:GetWeapon(1)
	if weapon and Mod:HasBitFlags(weapon:GetModifiers(), WeaponModifier.CHOCOLATE_MILK) then
		local charge = weapon:GetCharge()
		damageMult = 0.1 * charge
	end
	if owner:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
		sizeMult = sizeMult + 2
		damageMult = damageMult * 1.5
	end
	if owner:HasCollectible(Mod.Item.VESTA.ID) then
		sizeMult = 1
	end
	local laser = owner:FireTechXLaser(pos, vel, size * sizeMult, owner, damageMult * Mod:GetWeaponOwnerDamageMult(owner))
	Mod:GetData(laser).TechIXRing = true
	return laser
end

---@param tear EntityTear
function TECH_IX:PostFireTear(tear)
	local player = Mod:TryGetPlayer(tear, true)
	if player and player:HasCollectible(TECH_IX.ID) then
		if tear:HasTearFlags(TearFlags.TEAR_FETUS) then
			if tear:HasTearFlags(TearFlags.TEAR_FETUS_BRIMSTONE) then
				tear:ClearTearFlags(TearFlags.TEAR_FETUS_BRIMSTONE)
			end
			if tear:HasTearFlags(TearFlags.TEAR_FETUS_TECH) then
				tear:ClearTearFlags(TearFlags.TEAR_FETUS_TECH)
			end
			return
		end
		TECH_IX:FireTechIXRing(player, tear.Position, tear.Size, tear.Velocity)
		tear:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, TECH_IX.PostFireTear)

---@param bomb EntityBomb
function TECH_IX:PostFireBomb(bomb)
	local player = Mod:TryGetPlayer(bomb, true)
	if player and player:HasCollectible(TECH_IX.ID) and not player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
		local laser = TECH_IX:FireTechIXRing(player, bomb.Position, bomb.Size, Vector.Zero)
		laser.Parent = bomb
		laser.SubType = LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, TECH_IX.PostFireBomb)

---@param tear EntityTear
function TECH_IX:FetusFireTechIX(tear)
	local player = Mod:TryGetPlayer(tear, true)
	if player and player:HasCollectible(TECH_IX.ID)
		and not (
			tear:HasTearFlags(TearFlags.TEAR_FETUS_SWORD)
			or tear:HasTearFlags(TearFlags.TEAR_FETUS_BONE)
			or tear:HasTearFlags(TearFlags.TEAR_FETUS_BOMBER) --Unused?
			or player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)
		)
		and tear.FrameCount % 30 == 0
	then
		local enemy = Mod:GetClosestEnemy(tear.Position, 160)
		if enemy then
			TECH_IX:FireTechIXRing(player, tear.Position, tear.Size, (enemy.Position - tear.Position):Resized(player.ShotSpeed * 10))
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, TECH_IX.FetusFireTechIX, TearVariant.FETUS)

---@param tear EntityTear
function TECH_IX:LudoTear(tear)
	Mod:DelayOneFrame(function()
		local player = Mod:TryGetPlayer(tear, true)
		if player and player:HasCollectible(TECH_IX.ID) and tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
			tear:Remove()
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, TECH_IX.LudoTear)

function TECH_IX:LessDeafeningLasers(id, volume, framedelay, loop, pitch, pan)
	if PlayerManager.AnyoneHasCollectible(TECH_IX.ID) then
		return { id, volume / 2.5, framedelay, loop, pitch, pan }
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, TECH_IX.LessDeafeningLasers, SoundEffect.SOUND_LASERRING_WEAK)
Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, TECH_IX.LessDeafeningLasers, SoundEffect.SOUND_LASERRING)
Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, TECH_IX.LessDeafeningLasers, SoundEffect.SOUND_LASERRING_STRONG)

---@param player EntityPlayer
function TECH_IX:MultiShot(player)
	local numTechIX = player:GetCollectibleNum(TECH_IX.ID)
	if numTechIX <= 1 then return end
	local weapon = player:GetWeapon(1)
	if weapon then
		local weaponType = weapon:GetWeaponType()
		local params = player:GetMultiShotParams()
		local mult = numTechIX - 1
		params:SetSpreadAngle(weaponType, params:GetSpreadAngle(weaponType) + 2.167 * mult)
		params:SetNumTears(params:GetNumTears() + mult)
		local expectedAmount = params:GetNumTears() / params:GetNumEyesActive()
		params:SetNumLanesPerEye(expectedAmount)
		return params
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_GET_MULTI_SHOT_PARAMS, TECH_IX.MultiShot)
