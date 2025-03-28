local Mod = Furtherance
local game = Game()

function Mod:Covid()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = Mod:GetData(player)
		if (player and player:HasCollectible(CollectibleType.COLLECTIBLE_QUARANTINE)) then
			local entities = Isaac.GetRoomEntities()
			for i, entity in ipairs(entities) do
				if entity:IsActiveEnemy(false) and entity:IsVulnerableEnemy() then
					entity:AddFear(EntityRef(player), 180)
					data.poopooVirus = 180
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.Covid)

function Mod:NoMoreCovid(player)
	local data = Mod:GetData(player)
	if data.poopooVirus == nil or data.poopooVirus < 0 then
		data.poopooVirus = 0
	elseif data.poopooVirus > 0 then
		data.poopooVirus = data.poopooVirus - 1
		local radius = Isaac.FindInRadius(player.Position, 80)
		for i, entity in ipairs(radius) do
			if entity:IsActiveEnemy(false) and entity:IsVulnerableEnemy() then
				entity:AddPoison(EntityRef(player), 30, 1)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.NoMoreCovid)
