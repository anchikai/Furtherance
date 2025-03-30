local Mod = Furtherance

local QUARANTINE = {}

Furtherance.Item.QUARANTINE = QUARANTINE

QUARANTINE.ID = Isaac.GetItemIdByName("Quarantine")

QUARANTINE.FEAR_DURATION = 180
QUARANTINE.POISON_RADIUS = 80
QUARANTINE.POISON_DURATION = 30

---@param player EntityPlayer
function QUARANTINE:OnNewRoom(player)
	if player:HasCollectible(QUARANTINE.ID) then
		player:GetEffects():AddCollectibleEffect(QUARANTINE.ID)
		local source = EntityRef(player)
		Mod:ForEachEnemy(function (npc)
			if Mod:IsValidEnemyTarget(npc) then
				npc:AddFear(source, QUARANTINE.FEAR_DURATION)
				--Normal max of 5 seconds. Force to 6
				npc:SetFearCountdown(QUARANTINE.FEAR_DURATION)
			end
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, QUARANTINE.OnNewRoom)

---@param player EntityPlayer
function QUARANTINE:NoMoreCovid(player)
	if player:GetEffects():HasCollectibleEffect(QUARANTINE.ID) then
		for _, ent in ipairs(Isaac.FindInRadius(player.Position, QUARANTINE.POISON_RADIUS * player.Size, EntityPartition.ENEMY)) do
			if Mod:IsValidEnemyTarget(ent) and ent:HasEntityFlags(EntityFlag.FLAG_FEAR) then
				ent:AddPoison(EntityRef(player), QUARANTINE.POISON_DURATION, 1)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, QUARANTINE.NoMoreCovid)
