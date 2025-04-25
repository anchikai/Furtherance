local Mod = Furtherance

local SPIRITUAL_WOUND = {}

Furtherance.Item.SPIRITUAL_WOUND = SPIRITUAL_WOUND

SPIRITUAL_WOUND.ID = Isaac.GetItemIdByName("Spiritual Wound")

---@param player EntityPlayer
function SPIRITUAL_WOUND:GetLaserRange(player)
	return 60 + math.max(0, player.TearRange - 112) * 0.25
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function SPIRITUAL_WOUND:SpiritualWoundCache(player, cacheFlag)
	if not player:HasCollectible(SPIRITUAL_WOUND.ID) then return end
	if cacheFlag == CacheFlag.CACHE_WEAPON then
		--[[ local weapon = Isaac.GetPlayer():GetWeapon(1)
		if weapon then
			Isaac.DestroyWeapon(weapon)
		end ]]
		--Mod:DelayOneFrame(function()
			player:EnableWeaponType(WeaponType.WEAPON_BRIMSTONE, true)
			Mod:DelayOneFrame(function()
				local brimWeapon = Isaac.CreateWeapon(WeaponType.WEAPON_BRIMSTONE, player)
				player:SetWeapon(brimWeapon, 1)
				local weapon = player:GetWeapon(2)
				if weapon then
					Isaac.DestroyWeapon(weapon)
				end
			end)
		--end)
	elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
		player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
	elseif cacheFlag == CacheFlag.CACHE_RANGE then
		--Offsetting range granted by innate Eye of the Occult
		player.TearRange = player.TearRange - (2 * 40)
	elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
		player.LaserColor = Color(1, 1, 1, 1, 0, 0, 0, 5, 2, 1, 1)
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SPIRITUAL_WOUND.SpiritualWoundCache)

local VariantToTechVariant = {
	[LaserVariant.THICK_RED] = {LaserVariant.BRIM_TECH, "007.009_brimtech.anm2"},
	[LaserVariant.THICKER_RED] = {LaserVariant.THICKER_BRIM_TECH, "007.014_thicker red laser tech.anm2"},
	[LaserVariant.GIANT_RED] = {LaserVariant.GIANT_BRIM_TECH, "007.015_giant red laser tech.anm2"}
}

function SPIRITUAL_WOUND:SpiritualWoundGrantEOTO(type, charge, firstTime, slot, varData, player)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT) then
		player:AddInnateCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT)
		player:RemoveCostume(Mod.ItemConfig:GetCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT))
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, SPIRITUAL_WOUND.SpiritualWoundGrantEOTO, SPIRITUAL_WOUND.ID)

function SPIRITUAL_WOUND:SpiritualWoundRemoveEOTO(type, charge, firstTime, slot, varData, player)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT) then
		player:AddInnateCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT)
		player:RemoveCostume(Mod.ItemConfig:GetCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT))
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, SPIRITUAL_WOUND.SpiritualWoundRemoveEOTO, SPIRITUAL_WOUND.ID)

---@param laser EntityLaser
function SPIRITUAL_WOUND:OnLaserFire(laser)
	local player = Mod:TryGetPlayer(laser)
	---@cast player EntityPlayer
	if player:HasCollectible(SPIRITUAL_WOUND.ID) then
		local techVariant = VariantToTechVariant[laser.Variant]
		if techVariant then
			laser.Variant = techVariant[1]
			laser:GetSprite():Load("gfx/" .. techVariant[2], true)
			laser:GetSprite():Play(laser:GetSprite():GetDefaultAnimation())
		end
		laser.MaxDistance = SPIRITUAL_WOUND:GetLaserRange(player)
		laser:SetScale(0.75)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, SPIRITUAL_WOUND.OnLaserFire)

---@param laser EntityLaser
function SPIRITUAL_WOUND:OnLaserUpdate(laser)
	local player = Mod:TryGetPlayer(laser, true)
	if not player then return end
	if not player:HasCollectible(SPIRITUAL_WOUND.ID) then return end
	if player:HasCollectible(SPIRITUAL_WOUND.ID) then
		laser.MaxDistance = SPIRITUAL_WOUND:GetLaserRange(player)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, SPIRITUAL_WOUND.OnLaserUpdate)

--TODO: REP+ RGON has a new way of modifying MultiShot params and this should be deprecated/exclusive to non-rep+ once released

---@param player EntityPlayer
function SPIRITUAL_WOUND:MultiLaser(player)
	if not player:HasCollectible(SPIRITUAL_WOUND.ID) then return end
	local multiShotParams = player:GetMultiShotParams(WeaponType.WEAPON_BRIMSTONE)
	multiShotParams:SetNumTears(multiShotParams:GetNumTears() + 2)
	multiShotParams:SetNumLanesPerEye(multiShotParams:GetNumLanesPerEye() + 2)
	multiShotParams:SetSpreadAngle(WeaponType.WEAPON_BRIMSTONE, 25)
	return multiShotParams
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_GET_MULTI_SHOT_PARAMS, SPIRITUAL_WOUND.MultiLaser)