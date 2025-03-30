local Mod = Furtherance
local game = Game()

FractureRoomCount = 6
function Mod:FlippingLogic()
	local room = game:GetRoom()
	if room:IsFirstVisit() then
		FractureRoomCount = FractureRoomCount + 1
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.FlippingLogic)

function Mod:ResetCounter(continued)
	if continued == false then
		FractureRoomCount = 6
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.ResetCounter)

function Mod:AcutalFlippage(player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_PETERS_BLOODY_FRACTURE) and FractureRoomCount == 6 then
		FractureRoomCount = 0
		player:UseActiveItem(CollectibleType.COLLECTIBLE_MUDDLED_CROSS, false, false, true, false, -1)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.AcutalFlippage)
