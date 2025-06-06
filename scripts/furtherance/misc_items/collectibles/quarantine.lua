local Mod = Furtherance

local QUARANTINE = {}

Furtherance.Item.QUARANTINE = QUARANTINE

QUARANTINE.ID = Isaac.GetItemIdByName("Quarantine")

QUARANTINE.FEAR_DURATION = 180
QUARANTINE.POISON_RADIUS = 40
QUARANTINE.POISON_DURATION = 30

---@param player EntityPlayer
function QUARANTINE:OnNewRoom(player)
	if player:HasCollectible(QUARANTINE.ID) then
		player:GetEffects():AddCollectibleEffect(QUARANTINE.ID)
		local source = EntityRef(player)
		Mod.Foreach.NPC(function (npc, index)
			local duration = QUARANTINE.FEAR_DURATION + (QUARANTINE.FEAR_DURATION * (player:GetCollectibleNum(QUARANTINE.ID) - 1) * 0.5)
			npc:AddFear(source, duration)
			--Normal max of 5 seconds. Force new duration
			npc:SetFearCountdown(duration)
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
