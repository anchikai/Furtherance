local Mod = Furtherance

local SPACEBAR_KEY = {}

Furtherance.Item.KEY_SPACEBAR = SPACEBAR_KEY

SPACEBAR_KEY.ID = Isaac.GetItemIdByName("Spacebar Key")

SPACEBAR_KEY.REMOVE_CHANCE = 0.08

function SPACEBAR_KEY:IsEndStage()
	local level = Mod.Level()
	local stage = level:GetStage()
	local stageType = level:GetStageType()
	if Mod.Game:IsGreedMode() then
		return stage == LevelStage.STAGE7_GREED
	else
		--Chest/Dark Room, Void, Home, Corpse II, Dad's Note Maus II
		return stage >= LevelStage.STAGE6
		or stage == LevelStage.STAGE4_2
			and (
			stageType >= StageType.STAGETYPE_REPENTANCE
			or Mod.Game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH_INIT) == true
		)
	end
end

---@param rng RNG
---@param player EntityPlayer
function SPACEBAR_KEY:OnUse(_, rng, player)
	if SPACEBAR_KEY:IsEndStage() then
		Isaac.Spawn(EntityType.ENTITY_SHOPKEEPER, 2, 0, player.Position, Vector.Zero, nil)
	else
		Mod.Game:StartRoomTransition(Mod.Level():QueryRoomTypeIndex(RoomType.ROOM_ERROR, false, rng), Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)
	end
	local remove = false
	if rng:RandomFloat() <= SPACEBAR_KEY.REMOVE_CHANCE then
		remove = true
	end
	return {Discharge = true, Remove = remove, ShowAnim = true}
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, SPACEBAR_KEY.OnUse, SPACEBAR_KEY.ID)
