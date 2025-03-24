---@param owner EntityPlayer | EntityFamiliar
function Furtherance:GetWeaponOwnerDamageMult(owner)
	local damageMult = 1
	if owner:ToPlayer() then return damageMult end
	---@cast owner EntityFamiliar
	local variantToDamage = {
		[FamiliarVariant.INCUBUS] = 0.75,
		[FamiliarVariant.TWISTED_BABY] = 0.375,
		[FamiliarVariant.BLOOD_BABY] = 0.35,
		[FamiliarVariant.UMBILICAL_BABY] = 1,
		[FamiliarVariant.CAINS_OTHER_EYE] = 0.75,
	}
	if variantToDamage[owner.Variant] then
		damageMult = variantToDamage[owner.Variant]
		if owner.Variant == FamiliarVariant.BLOOD_BABY then
			local subtypeToDamage = {
				[Furtherance.BloodClotSubtype.BLACK] = 0.43,
				[Furtherance.BloodClotSubtype.ETERNAL] = 0.52
			}
			damageMult = subtypeToDamage[owner.SubType]
		end
		if owner.Player:GetPlayerType() == PlayerType.PLAYER_LILITH then
			damageMult = 1
		end
	end
	return damageMult * owner:GetMultiplier()
end

---@param baseChance number
---@param maxChance number
---@param luckValue number
---@param currentLuck number
---@param rng RNG
function Furtherance:DoesLuckChanceTrigger(baseChance, maxChance, luckValue, currentLuck, rng)
	local number = baseChance + (currentLuck * luckValue)
	if number > maxChance then
		number = maxChance
	end
	if rng:RandomFloat() <= number then
		return true
	else
		return false
	end
end

--Taken directly from the source! Shoutouts to the modders who decompiled the Switch port.
---@param tear EntityTear
---@return string
function Furtherance:TearScaleToSizeAnim(tear)
	local scale = tear.Scale
	local anim = "8"

	if scale <= 0.3 then
		anim = "1"
	elseif scale <= 0.55 then
		anim = "2"
	elseif scale <= 0.675 then
		anim = "3"
	elseif scale <= 0.8 then
		anim = "4"
	elseif scale <= 0.925 then
		anim = "5"
	elseif scale <= 1.05 then
		anim = "6"
	elseif scale <= 1.175 then
		anim = "7"
	elseif 1.425 < scale then
		if scale <= 1.675 then
			anim = "9"
		elseif scale <= 1.925 then
			anim = "10"
		elseif scale <= 2.175 then
			anim = "11"
		elseif 2.55 < scale then
			anim = "12"
		end
		anim = "13"
	end
	return anim
end

---From decomp
---@param bomb EntityBomb
function Furtherance:GetBombRadius(bomb)
	local damage = bomb.ExplosionDamage
	local radius = 90.0
	if 175.0 <= damage then
		radius = 105.0
	elseif damage <= 140.0 then
		radius = 75.0
	end
	return radius * bomb.RadiusMultiplier
end

---Put together by Connor from ghidra code
---@param tear EntityTear
function Furtherance:TearDamageToScale(tear)
	local baseScale = 1.0

	-- Item effects may directly alter tear scale here.

	if baseScale > 1.0 then
		-- Reduces scaling rate, so for example 2.0 scale is actually ~x1.41, not x2
		baseScale = math.log(baseScale) + 1.0
	end

	local scaleWithDamage = (math.sqrt(tear.CollisionDamage) * 0.23 + baseScale * 0.55 + tear.CollisionDamage * 0.01)

	if tear:HasTearFlags(TearFlags.TEAR_EXPLOSIVE) then
		-- Ipecac moment
		scaleWithDamage = scaleWithDamage * 0.5
	end
	return scaleWithDamage
end
