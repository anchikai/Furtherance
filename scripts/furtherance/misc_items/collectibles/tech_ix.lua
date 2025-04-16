local Mod = Furtherance

local TECH_IX = {}

Furtherance.Item.TECH_IX = TECH_IX

TECH_IX.ID = Isaac.GetItemIdByName("Tech IX")

TECH_IX.LASER_COLOR = Color(0, 1, 0, 1, 0, 1, 0.6)

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function TECH_IX:EvaluteCache(player, cacheFlag)
	if not player:HasCollectible(TECH_IX.ID) then return end
	if cacheFlag == CacheFlag.CACHE_WEAPON then
		Mod:DelayOneFrame(function()
			local weapon = player:GetWeapon(1)
			if weapon and weapon:GetWeaponType() == WeaponType.WEAPON_BRIMSTONE and not Mod:HasBitFlags(weapon:GetModifiers(), WeaponModifier.LUDOVICO_TECHNIQUE) then
				player:SetWeapon(Isaac.CreateWeapon(WeaponType.WEAPON_TEARS, player), 1)
			elseif weapon and weapon:GetWeaponType() == WeaponType.WEAPON_LUDOVICO_TECHNIQUE then
				local newWeapon = Isaac.CreateWeapon(WeaponType.WEAPON_LASER, player)
				newWeapon:SetModifiers(weapon:GetModifiers() | WeaponModifier.LUDOVICO_TECHNIQUE)
				player:SetWeapon(newWeapon, 1)
			end
		end)
	elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
		player.LaserColor = TECH_IX.LASER_COLOR
	elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
		player.MaxFireDelay = player.MaxFireDelay + 5
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
		player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, TECH_IX.EvaluteCache)

---@param tear EntityTear
function TECH_IX:PostFireTear(tear)
	local player = Mod:TryGetPlayer(tear, true)
	if player and player:HasCollectible(TECH_IX.ID) then
		local sizeMult = 1.5
		if player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS) or tear:HasTearFlags(TearFlags.TEAR_BURSTSPLIT) then
			sizeMult = sizeMult + 1
		end
		if player:HasCollectible(Mod.Item.VESTA.ID) then
			sizeMult = 1
		end
		player:FireTechXLaser(tear.Position, tear.Velocity, tear.Size * sizeMult, player, 0.66)
		tear:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, TECH_IX.PostFireTear)
Mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, TECH_IX.PostFireTear, TearVariant.SWORD_BEAM)
Mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, TECH_IX.PostFireTear, TearVariant.TECH_SWORD_BEAM)

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
		return {id, volume / 2.5, framedelay, loop, pitch, pan}
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, TECH_IX.LessDeafeningLasers, SoundEffect.SOUND_LASERRING_WEAK)
Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, TECH_IX.LessDeafeningLasers, SoundEffect.SOUND_LASERRING)
Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, TECH_IX.LessDeafeningLasers, SoundEffect.SOUND_LASERRING_STRONG)
