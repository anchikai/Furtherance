local Mod = Furtherance

function Mod:OnMove(player)
	local data = Mod:GetData(player)
	local inputPlayer = player
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
		inputPlayer = player:GetOtherTwin()
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_CRAB_LEGS) then
		local movementDirection = inputPlayer:GetMovementDirection()
		local isMovingSideways = movementDirection == Direction.LEFT or movementDirection == Direction.RIGHT
		if data.CrabSpeed ~= isMovingSideways then
			data.CrabSpeed = isMovingSideways
		else
			return
		end
	elseif data.CrabSpeed == true then
		data.CrabSpeed = false
	else
		return
	end

	player:AddCacheFlags(CacheFlag.CACHE_SPEED)
	player:EvaluateItems()
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.OnMove)

function Mod:CrabCacheEval(player)
	local data = Mod:GetData(player)
	if data.CrabSpeed == nil then
		data.CrabSpeed = false
	end
	if data.CrabSpeed == true then
		player.MoveSpeed = player.MoveSpeed + 0.2
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.CrabCacheEval, CacheFlag.CACHE_SPEED)
