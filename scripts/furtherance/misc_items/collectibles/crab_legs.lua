local Mod = Furtherance

local CRAB_LEGS = {}

Furtherance.Item.CRAB_LEGS = CRAB_LEGS

CRAB_LEGS.ID = Isaac.GetItemIdByName("Crab Legs")

CRAB_LEGS.SPEED = 0.5

---@param player EntityPlayer
function CRAB_LEGS:OnMove(player)
	local data = Mod:GetData(player)
	local inputPlayer = player
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
		inputPlayer = player:GetOtherTwin()
	end
	local movementDirection = inputPlayer:GetMovementDirection()

	if player:HasCollectible(CRAB_LEGS.ID) then
		local headDirection = inputPlayer:GetHeadDirection()
		local relativeLeft, relativeRight = (headDirection + 1) % 4, (headDirection + 3) % 4
		local isMovingSideways = movementDirection == relativeLeft or movementDirection == relativeRight
		if data.CrabSpeed ~= isMovingSideways then
			data.CrabSpeed = isMovingSideways
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
