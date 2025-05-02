local Mod = Furtherance

local HEARTS = {}

Furtherance.Core.HEARTS = HEARTS

HEARTS.RedHearts = Mod:Set({
	HeartSubType.HEART_FULL,
	HeartSubType.HEART_HALF,
	HeartSubType.HEART_DOUBLEPACK,
	HeartSubType.HEART_SCARED,
	HeartSubType.HEART_BLENDED,
})

HEARTS.SoulHearts = Mod:Set({
	HeartSubType.HEART_SOUL,
	HeartSubType.HEART_HALF_SOUL,
	HeartSubType.HEART_BLENDED,
})

HEARTS.HeartValueIncrease = {
	[HeartSubType.HEART_HALF] = HeartSubType.HEART_FULL,
	[HeartSubType.HEART_FULL] = HeartSubType.HEART_DOUBLEPACK,
	[HeartSubType.HEART_HALF_SOUL] = HeartSubType.HEART_SOUL
}

HEARTS.HeartAmount = {
	[HeartSubType.HEART_FULL] = 2,
	[HeartSubType.HEART_SCARED] = 2,
	[HeartSubType.HEART_DOUBLEPACK] = 4,
	[HeartSubType.HEART_HALF] = 1,
	[HeartSubType.HEART_BLENDED] = 2,
}

---@param player EntityPlayer
function HEARTS:CanCollectHeart(player, heartSubType)
	return HEARTS.RedHearts[heartSubType] and player:CanPickRedHearts()
		or HEARTS.SoulHearts[heartSubType] and player:CanPickSoulHearts()
		or heartSubType == HeartSubType.HEART_BLACK and player:CanPickBlackHearts()
		or heartSubType == HeartSubType.HEART_BONE and player:CanPickBoneHearts()
		or heartSubType == HeartSubType.HEART_ROTTEN and player:CanPickRottenHearts()
		or heartSubType == HeartSubType.HEART_GOLDEN and player:CanPickGoldenHearts()
		or heartSubType == HeartSubType.HEART_ETERNAL
		--[[ or heartSubType == HeartSubType.HEART_ROCK and Mod.CanPickHearts(player, "RockHeart")
		or heartSubType == HeartSubType.HEART_MOON and Mod.CanPickHearts(player, "MoonHeart") ]]
		or false -- make it false in case it's nil
end