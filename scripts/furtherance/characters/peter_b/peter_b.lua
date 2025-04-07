local Mod = Furtherance

local PETER_B = {}

Furtherance.Character.PETER_B = PETER_B

Mod.Include("scripts.furtherance.characters.peter_b.muddled_cross")

function PETER_B:BloodTears(tear)
	Mod:TryChangeTearToBloodVariant(tear)
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, PETER_B.BloodTears)

function PETER_B:OnNewRoom()
	local room = Mod.Room()
	if PlayerManager.AnyoneIsPlayerType(Mod.PlayerType.PETER_B) and not room:HasWater() then
		room:SetWaterAmount(0.5)
		room:GetFXParams().UseWaterV2 = true
	end
	if room:HasWater() then
		room:SetWaterColor(KColor(2, 0, 0, 0.5))
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PETER_B.OnNewRoom)

