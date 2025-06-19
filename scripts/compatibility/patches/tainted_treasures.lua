local Mod = Furtherance
local loader = Mod.PatchesLoader

local function taintedTreasuresPatch()
	Mod.API:RegisterAltruismCoinBeggar(TaintedMachines.TAINTED_BEGGAR)
	Mod.Trinket.ALTRUISM.ResourceRefund[TaintedMachines.TAINTED_BEGGAR] = function (player, slot)
		--Tainted Beggar's payment is taken after this runs, so delay it on the same callback the mod uses
		local data = Mod:GetData(player)
		data.AltruismTaintedBeggarRefund = true
		Mod:DelayOneFrame(function ()
			data.AltruismTaintedBeggarRefund = nil
		end)
	end

	local function refundTaintedBeggar()
		Mod.Foreach.Player(function (player, index)
			local data = Mod:GetData(player)
			if data.AltruismTaintedBeggarRefund then
				player:AddCoins(1)
			end
		end)
	end

	Mod:AddPriorityCallback(ModCallbacks.MC_POST_UPDATE, CallbackPriority.LATE, refundTaintedBeggar)
end

loader:RegisterPatch("TaintedTreasure", taintedTreasuresPatch)
