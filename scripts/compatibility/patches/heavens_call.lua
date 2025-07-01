local Mod = Furtherance
local loader = Mod.PatchesLoader

local function heavensCallPatch()
	local function solBossKTTKMantle()
		if HeavensCall:IsRoomDescSolarBoss(Mod:GetRoomDesc(), 1) then
			return true
		end
	end

	Mod:AddCallback(Mod.ModCallbacks.KTTK_GRANT_HOLY_MANTLE, solBossKTTKMantle)
end

loader:RegisterPatch("HeavensCall", heavensCallPatch)