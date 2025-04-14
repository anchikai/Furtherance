---Credit to Epiphany

function Furtherance:Delay2Tears(delay)
	return 30 / (delay + 1)
end

function Furtherance:Tears2Delay(tears)
	return (30 / tears) - 1
end

---@param player EntityPlayer
---@param tear EntityTear
function Furtherance:ShouldLudovicoUpdate(player, tear)
	return math.floor(tear.FrameCount / player.MaxFireDelay) ~= math.floor((tear.FrameCount - 1) / player.MaxFireDelay)
end