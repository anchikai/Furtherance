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
		Mod.Foreach.NPC(function (npc, index)
			npc:AddFear(source, QUARANTINE.FEAR_DURATION)
			--Normal max of 5 seconds. Force new duration
			npc:SetFearCountdown(QUARANTINE.FEAR_DURATION)
		end, nil, nil, nil, {UseEnemySearchParams = true})
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, QUARANTINE.OnNewRoom)

---@param player EntityPlayer
function QUARANTINE:NoMoreCovid(player)
	if player:GetEffects():HasCollectibleEffect(QUARANTINE.ID) then
		local source = EntityRef(player)
		Mod.Foreach.NPCInRadius(player.Position, QUARANTINE.POISON_RADIUS + player.Size, function (npc, index)
			npc:AddPoison(source, QUARANTINE.POISON_DURATION, player.Damage * 2)
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, QUARANTINE.NoMoreCovid)
