---Credit to Epiphany

function Furtherance:Delay2Tears(delay)
	return 30 / (delay + 1)
end

function Furtherance:Tears2Delay(tears)
	return (30 / tears) - 1
end

function Furtherance:TearsUp(firedelay, val)
	local currentTears = Furtherance:Delay2Tears(firedelay)
	local newTears = currentTears + val
	return math.max(Furtherance:Tears2Delay(newTears), -0.99)
end

function Furtherance:TearsDown(firedelay, val)
	local currentTears = Furtherance:Delay2Tears(firedelay)
	local newTears = currentTears - val
	return math.max(Furtherance:Tears2Delay(newTears), -0.99)
end

---@param player EntityPlayer
---@param tear EntityTear
function Furtherance:ShouldLudovicoUpdate(player, tear)
	return math.floor(tear.FrameCount / player.MaxFireDelay) ~= math.floor((tear.FrameCount - 1) / player.MaxFireDelay)
end