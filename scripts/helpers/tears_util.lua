---Credit to Epiphany

function Furtherance:Delay2Tears(delay)
	return 30 / (delay + 1)
end

function Furtherance:Tears2Delay(tears)
	return (30 / tears) - 1
end

function Furtherance:TearsUp(firedelay, val)
	local currentTears = 30 / (firedelay + 1)
	local newTears = currentTears + val
	return math.max((30 / newTears) - 1, -0.99)
end

---@param player EntityPlayer
---@param tear EntityTear
function Furtherance:ShouldLudovicoUpdate(player, tear)
	return math.floor(tear.FrameCount / player.MaxFireDelay) ~= math.floor((tear.FrameCount - 1) / player.MaxFireDelay)
end