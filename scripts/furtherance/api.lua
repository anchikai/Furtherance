local Mod = Furtherance

local API = {}

Furtherance.API = API

---Registers a beggar that takes coins as payment. Used for the Altruism trinket to refund the player
---
---Use API:RegisterAltruismBeggar if this doesn't happen to trigger for your beggar
---@param variant SlotVariant
---@param payAmount? integer
function API:RegisterAltruismCoinBeggar(variant, payAmount, rgonMethod)
	payAmount = payAmount or 1
	if rgonMethod then
		Mod.Trinket.ALTRUISM.ResourceRequirement[variant] = function (player, slot)
			return player:GetNumCoins() >= payAmount and slot:GetState() == Mod.SlotState.IDLE
		end
	else
		Mod.Trinket.ALTRUISM.ResourceRequirement[variant] = function (player, slot)
			local sprite = slot:GetSprite()
			local anim = sprite:GetAnimation()
			local frame = sprite:GetFrame()
			return player:GetNumCoins() >= payAmount and (sprite:IsPlaying("Idle") or frame == 0 and (anim == "PayNothing" or anim == "PayPrize"))
		end
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
	Mod.Trinket.ALTRUISM.PreCallbackBeggars[variant] = true
end

---Registers a beggar for usage with the Altruism trinket to refund the player
---@param variant SlotVariant
---@param funcRequirement fun(player: EntityPlayer, slot: EntitySlot): boolean @If the player meets the conditions to pay the beggar. Runs on MC_PRE_SLOT_COLLISION
---@param funcRefund fun(player: EntityPlayer, slot: EntitySlot) @What to enact onto the player that negates the price paid. Runs on MC_POST_SLOT_COLLISION
function API:RegisterAltruismBeggar(variant, funcRequirement, funcRefund)
	Mod.Trinket.ALTRUISM.ResourceRequirement[variant] = funcRequirement
	Mod.Trinket.ALTRUISM.ResourceRefund[variant] = funcRefund
end

---Registers a chest that the Astragali item can both select for reroll and reroll chests into
---@param variant PickupVariant
---@param unlockCond fun(): boolean
function API:RegisterAstragaliChest(variant, unlockCond)
	Mod.Insert(Mod.Item.ASTRAGALI.Chests, {ID = variant, Unlocked = unlockCond})
end

---Adds a trinket to the list of worm trinkets that the Rotten Apple item will randomly selected from to become a gulped trinket
---@param variant TrinketType
function API:AddRottenAppleWormTrinket(variant)
	Mod.Insert(Mod.Item.ROTTEN_APPLE.Worms, variant)
end

---@param entTypeOrName string
---@param var nil
---@param sub nil
---@overload fun(self: table, entTypeOrName: EntityType, var: integer, sub: integer)
local function getTypeVarSub(entTypeOrName, var, sub)
	if type(entTypeOrName) == "string" then
		local name = entTypeOrName ---@type string
		local typeVarSub = Mod:GetTypeVarSubFromName(name, true)
		return typeVarSub
	else
		local entType = entTypeOrName ---@type EntityType
		local entityConfig = EntityConfig.GetEntity(entType, var, sub)
		if entityConfig then
			local typeVarSub = Mod:GetTypeVarSubFromEntityConfig(entityConfig)
			return typeVarSub
		end
	end
end

---Registers a miniboss. Used by Keys to the Kingdom for sparing enemies faster than normal bosses
---@param entTypeOrName string
---@param var nil
---@param sub nil
---@overload fun(self: table, entTypeOrName: EntityType, var: integer, sub: integer)
function API:RegisterKTTKMiniboss(entTypeOrName, var, sub)
	local typeVarSub = getTypeVarSub(entTypeOrName, var, sub)
	Mod.Item.KEYS_TO_THE_KINGDOM.MINIBOSS[typeVarSub] = true
end

---Sets a new default spare timer for the entity for Keys to the Kingdom. Normally only used for Baby Plum
---@param entTypeOrName string
---@param var nil
---@param sub nil
---@overload fun(self: table, entTypeOrName: EntityType, var: integer, sub: integer)
function API:SetDefaultKTTKSpareCountdown(time, entTypeOrName, var, sub)
	local typeVarSub = getTypeVarSub(entTypeOrName, var, sub)
	Mod.Item.KEYS_TO_THE_KINGDOM.SPARE_TIMER[typeVarSub] = time
end

---@param cards Card[]
function API:AddToBoxOfBelongingsCardPool(cards)
	Mod:AppendTable(Mod.Item.BOX_OF_BELONGINGS.CARD_DROPS, cards)
end

---@param trinkets TrinketType[]
function API:AddToBoxOfBelongingsTrinketPool(trinkets)
	Mod:AppendTable(Mod.Item.BOX_OF_BELONGINGS.TRINKET_DROPS, trinkets)
end