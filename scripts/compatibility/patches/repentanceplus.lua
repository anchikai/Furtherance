local Mod = Furtherance
local loader = Mod.PatchesLoader

local function repentancePlusMODPatch()

	Mod:AddToDictionary(Mod.Core.HEARTS.HeartAmount, {
		[RepentancePlusMod.CustomPickups.TaintedHearts.HEART_HOARDED] = 8,
		[RepentancePlusMod.CustomPickups.TaintedHearts.HEART_CURDLED] = 2,
		[RepentancePlusMod.CustomPickups.TaintedHearts.HEART_SAVAGE] = 2,
		[RepentancePlusMod.CustomPickups.TaintedHearts.HEART_HARLOT] = 2
	})

	Mod:AddToDictionary(Mod.Core.HEARTS.RedHearts, Mod:Set({
		RepentancePlusMod.CustomPickups.TaintedHearts.HEART_HOARDED,
		RepentancePlusMod.CustomPickups.TaintedHearts.HEART_CURDLED,
		RepentancePlusMod.CustomPickups.TaintedHearts.HEART_SAVAGE,
		RepentancePlusMod.CustomPickups.TaintedHearts.HEART_HARLOT
	}))

	Mod:AddToDictionary(Mod.Core.HEARTS.SoulHearts, Mod:Set({
		RepentancePlusMod.CustomPickups.TaintedHearts.HEART_FETTERED,
		RepentancePlusMod.CustomPickups.TaintedHearts.HEART_ZEALOT
	}))
end

loader:RegisterPatch("RepentancePlus", repentancePlusMODPatch)