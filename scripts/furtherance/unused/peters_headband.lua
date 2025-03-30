local Mod = Furtherance
local game = Game()

local HeadbandRoomCount = 0

function Mod:Rapturing()
	local room = game:GetRoom()

	if room:IsFirstVisit() then
		HeadbandRoomCount = HeadbandRoomCount + 1
	end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player and player:HasCollectible(CollectibleType.COLLECTIBLE_PETERS_HEADBAND) then
			if HeadbandRoomCount >= 12 then
				HeadbandRoomCount = 0
				player:UseActiveItem(CollectibleType.COLLECTIBLE_KEYS_TO_THE_KINGDOM, false, false, true, false, -1)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.Rapturing)

function Mod:ResetCounter(continued)
	if continued == false then
		HeadbandRoomCount = 0
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.ResetCounter)
