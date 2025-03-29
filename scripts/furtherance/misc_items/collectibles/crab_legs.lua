local Mod = Furtherance

local CRAB_LEGS = {}

Furtherance.Item.CRAB_LEGS = CRAB_LEGS

CRAB_LEGS.ID = Isaac.GetItemIdByName("Crab Legs")

CRAB_LEGS.SPEED = 0.3

---@param player EntityPlayer
function CRAB_LEGS:OnMove(player)
	local data = Mod:GetData(player)
	local inputPlayer = player
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
		inputPlayer = player:GetOtherTwin()
	end

	if player:HasCollectible(CRAB_LEGS.ID) then
		local headDirection = inputPlayer:GetHeadDirection()
		local movementDirection = inputPlayer:GetMovementDirection()
		local relativeRight, relativeLeft = headDirection + 1, headDirection + 3
		if relativeRight > 3 then
			relativeRight = relativeRight - 3
		end
		if relativeLeft > 3 then
			relativeLeft = relativeLeft - 3
		end
		local isMovingSideways = movementDirection == relativeLeft or movementDirection == relativeRight
		if data.CrabSpeed ~= isMovingSideways then
			player:AddCacheFlags(CacheFlag.CACHE_SPEED, true)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CRAB_LEGS.OnMove, PlayerVariant.PLAYER)

---@param player EntityPlayer
function CRAB_LEGS:CrabSpeed(player)
	local data = Mod:GetData(player)
	if data.CrabSpeed == true then
		player.MoveSpeed = player.MoveSpeed + (CRAB_LEGS.SPEED * player:GetCollectibleNum(CRAB_LEGS.ID))
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, CRAB_LEGS.CrabSpeed, CacheFlag.CACHE_SPEED)
