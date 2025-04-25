local Mod = Furtherance

local SPIRITUAL_WOUND = {}

Furtherance.Item.SPIRITUAL_WOUND = SPIRITUAL_WOUND

SPIRITUAL_WOUND.ID = Isaac.GetItemIdByName("Spiritual Wound")

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
			--[[ player:EnableWeaponType(WeaponType.WEAPON_LASER, true)
			Mod:DelayOneFrame(function()
				local brimWeapon = Isaac.CreateWeapon(WeaponType.WEAPON_LASER, player)
				brimWeapon:SetModifiers(brimWeapon:GetModifiers() | WeaponModifier.MONSTROS_LUNG)
				player:SetWeapon(brimWeapon, 1)
				local weapon = player:GetWeapon(2)
				if weapon then
					Isaac.DestroyWeapon(weapon)
				end
			end) ]]
		--end)
	elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
		player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
	elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
		player.LaserColor = Color(1, 1, 1, 1, 0, 0, 0, 5, 2, 1, 1)
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SPIRITUAL_WOUND.SpiritualWoundCache)

---@param player EntityPlayer
function SPIRITUAL_WOUND:OnPeffectUpdate(player)
	--player:GetWeapon(1):SetCharge(202)
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SPIRITUAL_WOUND.OnPeffectUpdate)