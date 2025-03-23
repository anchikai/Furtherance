---Credit to Epiphany

function Furtherance:Delay2Tears(delay)
	return 30 / (delay + 1)
end

function Furtherance:Tears2Delay(tears)
	return (30 / tears) - 1
end
