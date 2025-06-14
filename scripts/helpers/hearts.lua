local Mod = Furtherance

Furtherance.HeartGroups = {
	Red = Mod:Set({
		HeartSubType.HEART_FULL,
		HeartSubType.HEART_HALF,
		HeartSubType.HEART_SCARED,
		HeartSubType.HEART_DOUBLEPACK,
		HeartSubType.HEART_BLENDED
	}),
	Rotten = Mod:Set({
		HeartSubType.HEART_ROTTEN,
	}),
	Soul = Mod:Set({
		HeartSubType.HEART_SOUL,
		HeartSubType.HEART_HALF_SOUL,
		HeartSubType.HEART_BLENDED
	}),
	Blended = Mod:Set({
		HeartSubType.HEART_BLENDED
	}),
	Eternal = Mod:Set({
		HeartSubType.HEART_ETERNAL
	}),
	Black = Mod:Set({
		HeartSubType.HEART_BLACK
	}),
	Bone = Mod:Set({
		HeartSubType.HEART_BONE
	}),
	Special = {},
	Greedy = Mod:Set({
		HeartSubType.HEART_GOLDEN
	}),
}

Furtherance.HeartValueIncrease = {
	[HeartSubType.HEART_HALF] = HeartSubType.HEART_FULL,
	[HeartSubType.HEART_FULL] = HeartSubType.HEART_DOUBLEPACK,
	[HeartSubType.HEART_HALF_SOUL] = HeartSubType.HEART_SOUL
}

Furtherance.HeartAmount = {
	[HeartSubType.HEART_FULL] = 2,
	[HeartSubType.HEART_SCARED] = 2,
	[HeartSubType.HEART_DOUBLEPACK] = 4,
	[HeartSubType.HEART_HALF] = 1,
	[HeartSubType.HEART_BLENDED] = 2,
	[HeartSubType.HEART_HALF_SOUL] = 1,
	[HeartSubType.HEART_SOUL] = 2,
	[HeartSubType.HEART_BLACK] = 2
}

---@param player EntityPlayer
function Furtherance:CanCollectHeart(player, heartSubType)
	local result = Isaac.RunCallbackWithParam(Mod.ModCallbacks.CAN_COLLECT_HEART, heartSubType, player)
	if result == "boolean" then
		return result
	end
	return Mod.HeartGroups.Red[heartSubType] and player:CanPickRedHearts()
		or Mod.HeartGroups.Soul[heartSubType] and player:CanPickSoulHearts()
		or Mod.HeartGroups.Black[heartSubType] and player:CanPickBlackHearts()
		or Mod.HeartGroups.Bone[heartSubType] and player:CanPickBoneHearts()
		or Mod.HeartGroups.Rotten[heartSubType] and player:CanPickRottenHearts()
		or Mod.HeartGroups.Greedy[heartSubType] and player:CanPickGoldenHearts()
		or Mod.HeartGroups.Eternal[heartSubType]
		or false
end