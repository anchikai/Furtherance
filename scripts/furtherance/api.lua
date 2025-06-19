local Mod = Furtherance

local API = {}

Furtherance.API = API

---Registers a beggar that takes coins as payment. Used for the Altruism trinket to refund the player
---
---Use API:RegisterAltruismBeggar if this doesn't happen to trigger for your beggar
---@param variant SlotVariant
---@param payAmount? integer
function API:RegisterAltruismCoinBeggar(variant, payAmount)
	payAmount = payAmount or 1
	Mod.Trinket.ALTRUISM.ResourceRequirement[variant] = function (player, slot)
		local sprite = slot:GetSprite()
		local anim = sprite:GetAnimation()
		local frame = sprite:GetFrame()
		return player:GetNumCoins() >= payAmount and (sprite:IsPlaying("Idle") or frame == 0 and (anim == "PayNothing" or anim == "PayPrize"))
	end
	Mod.Trinket.ALTRUISM.ResourceRefund[variant] = function (player, slot)
		player:AddCoins(payAmount)
	end
end

---Registers a beggar that deals a half heart of damage as payment. Used for the Altruism trinket to refund the player
---
---Use API:RegisterAltruismBeggar if this doesn't happen to trigger for your beggar
---@param variant SlotVariant
function API:RegisterAltruismHurtBeggar(variant)
	Mod.Trinket.ALTRUISM.ResourceRequirement[variant] = function (player, slot)
		local sprite = slot:GetSprite()
		local anim = sprite:GetAnimation()
		local frame = sprite:GetFrame()
		return sprite:IsPlaying("Idle") or frame == 0 and (anim == "PayNothing" or anim == "PayPrize")
	end
	Mod.Trinket.ALTRUISM.ResourceRefund[variant] = function (player, slot)
		Mod:GetData(player).AltruismPreventDamage = true
		Mod:DelayOneFrame(function() Mod:GetData(player).AltruismPreventDamage = nil end)
	end
end

---Registers a beggar for usage with the Altruism trinket
---@param variant SlotVariant
---@param funcRequirement fun(player: EntityPlayer, slot: EntitySlot): boolean @If the player meets the conditions to pay the beggar. Runs on MC_PRE_SLOT_COLLISION
---@param funcRefund fun(player: EntityPlayer, slot: EntitySlot) @What to enact onto the player that negates the price paid. Runs on MC_POST_SLOT_COLLISION
function API:RegisterAltruismBeggar(variant, funcRequirement, funcRefund)
	Mod.Trinket.ALTRUISM.ResourceRequirement[variant] = funcRequirement
	Mod.Trinket.ALTRUISM.ResourceRefund[variant] = funcRefund
end