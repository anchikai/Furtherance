local Mod = Furtherance
local loader = Mod.PatchesLoader

local function lastJudgementPatch()
	local AIDS = LastJudgement.ENT.Aids
	Mod.API:RegisterKTTKMiniboss(AIDS.ID, AIDS.Var, AIDS.Sub)
end

loader:RegisterPatch("LastJudgement", lastJudgementPatch)