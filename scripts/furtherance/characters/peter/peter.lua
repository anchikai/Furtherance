local Mod = Furtherance

local PETER = {}

Furtherance.Character.PETER = PETER

Mod.Include("scripts.furtherance.characters.peter.keys_to_the_kingdom")

local max = math.max

---@param player EntityPlayer
function PETER:IsPeter(player)
	return player:GetPlayerType() == Mod.PlayerType.PETER
end

---@param player EntityPlayer
function PETER:OnInit(player)
	player:AddTrinket(Mod.Trinket.ALABASTER_SCRAP.ID)
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, PETER.OnInit, Mod.PlayerType.PETER)

---@param player EntityPlayer
---@param amount integer
function PETER:DistributeSoulHeartsToPocket(player, amount)
	if PETER:IsPeter(player) then
		local activeItem = player:GetActiveItem(ActiveSlot.SLOT_POCKET)
		if activeItem == Mod.Item.KEYS_TO_THE_KINGDOM.ID then
			local charge = player:GetActiveCharge(ActiveSlot.SLOT_POCKET)
			local maxCharge = Mod.ItemConfig:GetCollectible(activeItem).MaxCharges
		if charge < maxCharge then
				local newAmount = charge + amount - maxCharge
				player:AddActiveCharge(amount, ActiveSlot.SLOT_POCKET, true, false, true)
				return max(0, newAmount)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, PETER.DistributeSoulHeartsToPocket, AddHealthType.SOUL)
Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, PETER.DistributeSoulHeartsToPocket, AddHealthType.BLACK)

--#region Book of Virtues-like effect

function PETER:ForceNewAngel()
	local level = Mod.Level()
	if PlayerManager.AnyoneIsPlayerType(Mod.PlayerType.PETER)
		and (level:GetAbsoluteStage() >= LevelStage.STAGE1_2 or Mod:HasBitFlags(Mod.Level():GetCurses(), LevelCurse.CURSE_OF_LABYRINTH))
		and Mod.Game:GetStateFlag(GameStateFlag.STATE_DEVILROOM_SPAWNED)
	then
		--Literally any angel room chance forces the 50/50, and if no angel room encountered, 100%
		--Which will essentially act just like Book of Virtues' effect minus the bonus chance
		level:AddAngelRoomChance(0.0000001)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PETER.ForceNewAngel)
