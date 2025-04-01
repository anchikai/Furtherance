local Mod = Furtherance

local GRASS = {}

Furtherance.Trinket.GRASS = GRASS

GRASS.ID = Isaac.GetTrinketIdByName("Grass")

--30 minutes
GRASS.TIMER = 30 * 60 * 30
GRASS.LAUGH_SFX = Isaac.GetSoundIdByName("Sitcom Laugh Track")

---@param player EntityPlayer
function GRASS:Grass(player)
	local player_run_save = Mod:RunSave(player)
	local trinketMult = player:GetTrinketMultiplier(GRASS.ID)
	if not player_run_save.GrassTimer then return end
	if player_run_save.GrassTimer > 0 then
		player_run_save.GrassTimer = player_run_save.GrassTimer - trinketMult
	else
		Mod.SFXMan:Play(GRASS.LAUGH_SFX)
		player:AnimateHappy()
		while player:HasTrinket(GRASS.ID) do
			player:TryRemoveTrinket(GRASS.ID)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_GNAWED_LEAF,
				Mod.Room():FindFreePickupSpawnPosition(player.Position, 40), Vector.Zero, player)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, GRASS.Grass)

---@param player EntityPlayer
function GRASS:UpdateGrass(player, trinketID)
	local player_run_save = Mod:RunSave(player)
	if player:HasTrinket(trinketID) then
		if not player_run_save.GrassTimer then
			player_run_save.GrassTimer = GRASS.TIMER
		end
	elseif not player:HasTrinket(trinketID) then
		player_run_save.GrassTimer = nil
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, GRASS.UpdateGrass)
Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, GRASS.UpdateGrass)
