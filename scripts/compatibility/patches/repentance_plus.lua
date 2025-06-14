local Mod = Furtherance
local loader = Mod.PatchesLoader

local function repentancePlusMODPatch()
	local taintedHeart = RepentancePlusMod.CustomPickups.TaintedHearts

	Mod:AddToDictionary(Mod.HeartAmount, {
		[taintedHeart.HEART_BROKEN] = 2,
		[taintedHeart.HEART_DAUNTLESS] = 2,
		[taintedHeart.HEART_HOARDED] = 8,
		--Deciever (disappears)
		[taintedHeart.HEART_SOILED] = 2,
		[taintedHeart.HEART_CURDLED] = 2,
		[taintedHeart.HEART_SAVAGE] = 2, --Can always collect
		[taintedHeart.HEART_BENIGHTED] = 2,
		[taintedHeart.HEART_HARLOT] = 1,
		--Enigma (An extra life, not part of health)
		--Capricious (Splits into other normal hearts)
		[taintedHeart.HEART_HARLOT] = 2,
		[taintedHeart.HEART_MISER] = 2,
		[taintedHeart.HEART_EMPTY] = 2,
		[taintedHeart.HEART_FETTERED] = 2,
		[taintedHeart.HEART_ZEALOT] = 2,
		[taintedHeart.HEART_DESERTED] = 2
	})

	Mod:AddToDictionary(Mod.HeartGroups.Red, Mod:Set({
		taintedHeart.HEART_HOARDED,
		taintedHeart.HEART_CURDLED,
		taintedHeart.HEART_SAVAGE,
		taintedHeart.HEART_HARLOT
	}))

	Mod:AddToDictionary(Mod.HeartGroups.Soul, Mod:Set({
		taintedHeart.HEART_DAUNTLESS,
		taintedHeart.HEART_FETTERED,
		taintedHeart.HEART_ZEALOT
	}))

	Mod:AddToDictionary(Mod.HeartGroups.Rotten, Mod:Set({
		taintedHeart.HEART_SOILED,
		taintedHeart.HEART_EMPTY
	}))

	Mod:AddToDictionary(Mod.HeartGroups.Eternal, Mod:Set({
		taintedHeart.HEART_BALEFUL
	}))

	Mod:AddToDictionary(Mod.HeartGroups.Black, Mod:Set({
		taintedHeart.HEART_BENIGHTED,
		taintedHeart.HEART_DESERTED
	}))

	Mod:AddToDictionary(Mod.HeartGroups.Special, Mod:Set({
		taintedHeart.HEART_BROKEN,
		taintedHeart.HEART_ENIGMA,
		taintedHeart.HEART_CAPRICIOUS
	}))

	Mod:AddToDictionary(Mod.HeartGroups.Greedy, Mod:Set({
		taintedHeart.HEART_MISER
	}))

	local function alwaysCollectSavage()
		return true
	end

	Mod:AddCallback(Mod.ModCallbacks.CAN_COLLECT_HEART, alwaysCollectSavage, taintedHeart.HEART_SAVAGE)
end

loader:RegisterPatch("RepentancePlusMod", repentancePlusMODPatch)