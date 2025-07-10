local Mod = Furtherance
local emptyShaderName = ""

local VERSION = 1.14 -- (v1.1.4) do not modify
local game = Game()
local itemConfig = Isaac.GetItemConfig()

-- debug
local FORCE_VERSION_UPDATE = false

local CACHED_CALLBACKS
local CACHED_ELEMENTS
local CACHED_MOD_CALLBACKS

local min = math.min
local max = math.max
local floor = function(x) return x // 1 end
local ceil = math.ceil

---Initializes data that should not be reset when a newer version of the mod is loaded.
local function InitMod()
	---@class HUDInfo
	---@field Name string @The name of the HUD element.
	---@field Priority integer @The priority of the HUD element. The lower the number, the higher the priority.
	---@field Condition fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout): boolean @A function that returns true if the HUD element should be drawn.
	---@field OnRender fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout, position: Vector) @Runs for each player, if the condition is true.
	---@field BypassGhostBaby boolean? @default: `false`. Set to `true` to ignore if your player is a co-op baby and continue rendering.
	---@field PreRenderCallback boolean? @default: `false`. Set to `true` to specify your callback should on the PRE version of a render callback rather than POST.

	---@class HUDInfo_Active: HUDInfo
	---@field Condition fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout, slot: ActiveSlot): boolean @A function that returns true if the HUD element should be drawn.
	---@field OnRender fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout, position: Vector, alpha: number, scale: number, slot: ActiveSlot, chargebarOffset: Vector) @Runs for each player, if the condition is true.

	---@class HUDInfo_Health: HUDInfo
	---@field Condition fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout, mainPlayer: EntityPlayer?): boolean @A function that returns true if the HUD element should be drawn.
	---@field OnRender fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout, position: Vector, maxColumns: integer, alpha: number, mainPlayer: EntityPlayer?) @Runs for each player, if the condition is true.

	---@class HUDInfo_Pocket: HUDInfo
	---@field OnRender fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout, position: Vector, alpha: number, scale: number) @Runs for each player, if the condition is true.

	---@class HUDInfo_Trinket: HUDInfo
	---@field Condition fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout, slot: integer): boolean @A function that returns true if the HUD element should be drawn.
	---@field OnRender fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout, position: Vector, scale: number, slot: integer) @Runs for each player, if the condition is true.

	---@class HUDInfo_Extra: HUDInfo
	---@field YPadding integer | fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout): integer @The height of the HUD element. This is used to calculate the padding between HUD elements.
	---@field XPadding integer | table<integer, integer> @The padding between the HUD element and vanilla ui, by player index.

	---@class HUDInfo_ActiveID: HUDInfo
	---@field Name nil
	---@field Priority nil
	---@field Condition nil | fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout): boolean
	---@field ItemID CollectibleType
	---@field OnRender fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout, position: Vector, alpha: number, scale: number, itemID: CollectibleType, slot: ActiveSlot?) @Runs for each player, if the condition is true.

	---@class HUDInfo_TrinketID: HUDInfo
	---@field Name nil
	---@field Priority nil
	---@field Condition nil | fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout): boolean
	---@field ItemID TrinketType
	---@field OnRender fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout, position: Vector, alpha: number, scale: number, trinketID: TrinketType, slot: integer?) @Runs for each player, if the condition is true.

	---@class HUDInfo_CardID: HUDInfo
	---@field Name nil
	---@field Priority nil
	---@field Condition nil | fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout): boolean
	---@field ItemID Card | PillColor
	---@field OnRender fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout, position: Vector, alpha: number, scale: number, cardID: Card) @Runs for each player, if the condition is true.

	---@class HUDInfo_PillID: HUDInfo
	---@field Name nil
	---@field Priority nil
	---@field Condition nil | fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout): boolean
	---@field ItemID Card | PillColor
	---@field OnRender fun(player: EntityPlayer, playerHUDIndex: integer, hudLayout: HUDLayout, position: Vector, alpha: number, scale: number, pillID: PillColor) @Runs for each player, if the condition is true.

	---@class HUDCallback
	---@field Priority integer
	---@field Function function
	---@field Args any[]

	local HudHelper = RegisterMod(("[%s] HUD Helper"):format(Mod.Name), 1)
	HudHelper.Version = VERSION

	---@enum HUDType
	HudHelper.HUDType = {
		BASE = 0,   		--Top left corner of each HUD
		ACTIVE = 1, 		--Renders on every active item
		HEALTH = 2, 		--Location of the first heart of each HUD
		POCKET = 3, 		--Renders on the primary pocket item slot of each HUD
		TRINKET = 4,		--Renders on every trinket
		EXTRA = 5,  		--For any miscellaneous HUD elements per-player. Renders below/above the player's health
		ACTIVE_ID = 6, 		--Like ACTIVE, but for specific collectible IDs instead of slots
		TRINKET_ID = 7, 	--Like TRINKET, but for specific trinket IDs instead of slots
		CARD_ID = 8, 		--Like POCKET, but for specific card IDs instead of slots
		PILL_ID = 9, 		--Like POCKET, but for specific pill IDs instead of slots
		NUM_TYPES = 10
	}

	HudHelper.HUD_ELEMENTS = {
		[HudHelper.HUDType.BASE] = {}, ---@type HUDInfo[]
		[HudHelper.HUDType.ACTIVE] = {}, ---@type HUDInfo_Active[]
		[HudHelper.HUDType.HEALTH] = {}, ---@type HUDInfo_Health[]
		[HudHelper.HUDType.POCKET] = {}, ---@type HUDInfo_Pocket[]
		[HudHelper.HUDType.TRINKET] = {}, ---@type HUDInfo_Trinket[]
		[HudHelper.HUDType.EXTRA] = {}, ---@type HUDInfo_Extra[]
		[HudHelper.HUDType.ACTIVE_ID] = {}, ---@type {[CollectibleType]: HUDInfo_ActiveID}
		[HudHelper.HUDType.TRINKET_ID] = {}, ---@type{[TrinketType]: HUDInfo_TrinketID}
		[HudHelper.HUDType.CARD_ID] = {}, ---@type{[Card]: HUDInfo_TrinketID}
		[HudHelper.HUDType.PILL_ID] = {}, ---@type{[PillColor]: HUDInfo_TrinketID}
	}
	--Legacy
	local legacyStrings = {
		Base = HudHelper.HUDType.BASE,
		Actives = HudHelper.HUDType.ACTIVE,
		Health = HudHelper.HUDType.HEALTH,
		PocketItems = HudHelper.HUDType.POCKET,
		Trinkets = HudHelper.HUDType.TRINKET,
		Extra = HudHelper.HUDType.EXTRA
	}

	if CACHED_ELEMENTS then
		for hudType, hudElements in pairs(CACHED_ELEMENTS) do
			--Older version of HudHelper using string keys
			if type(hudType) == "string" then
				--If elements with the proper HudType key already exist, group them together
				local targetTable = CACHED_ELEMENTS[legacyStrings[hudType]]
				if targetTable then
					for _, element in ipairs(hudElements) do
						targetTable[#targetTable] = element
					end
					table.sort(hudElements, function(a, b)
						return a.Priority < b.Priority
					end)
					HudHelper.HUD_ELEMENTS[legacyStrings[hudType]] = hudElements
				else
					--If it doesn't exist, can just shove the whole thing in there
					HudHelper.HUD_ELEMENTS[legacyStrings[hudType]] = hudElements
				end
			else
				HudHelper.HUD_ELEMENTS[hudType] = hudElements
			end
		end
	end
	HudHelper.ItemSpecificOffset = {
		Normal = {
			[CollectibleType.COLLECTIBLE_THE_JAR] = Vector(4, 3),
			[CollectibleType.COLLECTIBLE_JAR_OF_FLIES] = Vector(4, 2),
			[CollectibleType.COLLECTIBLE_JAR_OF_WISPS] = Vector.One,
			[CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS] = -Vector.One,
			[CollectibleType.COLLECTIBLE_URN_OF_SOULS] = Vector(2, 1),
		},
		Book = {
			[CollectibleType.COLLECTIBLE_THE_JAR] = Vector(-1, 0),
			[CollectibleType.COLLECTIBLE_JAR_OF_FLIES] = -Vector.One,
			[CollectibleType.COLLECTIBLE_JAR_OF_WISPS] = Vector.Zero,
			[CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS] = -Vector.One,
			[CollectibleType.COLLECTIBLE_URN_OF_SOULS] = Vector(1, 0),
		},
		TwinCoopBook = { --WHY DOES IT CHANGE AGAIN FOR THIS
			[CollectibleType.COLLECTIBLE_THE_JAR] = Vector(-6, -3),
			[CollectibleType.COLLECTIBLE_JAR_OF_FLIES] = Vector(-6, -4),
			[CollectibleType.COLLECTIBLE_JAR_OF_WISPS] = -Vector.One,
			[CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS] = -Vector.One,
			[CollectibleType.COLLECTIBLE_URN_OF_SOULS] = Vector(0, -1),
		}
	}

	---@enum HUDLayout
	HudHelper.HUDLayout = {
		P1 = 1,
		P1_MAIN_TWIN = 2,
		P1_OTHER_TWIN = 3,
		COOP = 4,
		STRAWMAN_HEARTS = 5,
		TWIN_COOP = 6 --Rep+ exclusive
	}

	---@enum HUDIconType
	HudHelper.IconType = {
		COINS = 1,					--Coins counter
		BOMBS = 2,					--Bombs counter
		KEYS = 3,					--Keys counter
		DIFFICULTY_ICON = 5,		--Hard Mode, Greed, Greedier icons
		NO_ACHIEVEMENT_ICON = 6,	--Disabled achievements icon
		DESTINATION_ICON = 7,		--Challenge destination icon
		MISC_ICON = 8,				--Icon that awkwardly renders to the right of the previous icons
		STAT = 9					--Bottom of the stats, if the FoundHUD option is enabled
	}

	---@type table<ModCallbacks, function[]>
	HudHelper.AddedCallbacks = {
		[ModCallbacks.MC_USE_ITEM] = {},
		[ModCallbacks.MC_POST_RENDER] = {},
	} -- for any vanilla callback functions added by this library

	if REPENTOGON then
		HudHelper.AddedCallbacks[ModCallbacks.MC_PRE_PLAYERHUD_RENDER_HEARTS] = {}
		HudHelper.AddedCallbacks[ModCallbacks.MC_POST_PLAYERHUD_RENDER_HEARTS] = {}
		HudHelper.AddedCallbacks[ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM] = {}
		HudHelper.AddedCallbacks[ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM] = {}
		HudHelper.AddedCallbacks[ModCallbacks.MC_POST_HUD_RENDER] = {}
		HudHelper.AddedCallbacks[ModCallbacks.MC_POST_MODS_LOADED] = {}
	else
		HudHelper.AddedCallbacks[ModCallbacks.MC_POST_GAME_STARTED] = {}
		HudHelper.AddedCallbacks[ModCallbacks.MC_GET_SHADER_PARAMS] = {}
	end

	HudHelper.Callbacks = {}

	---@type table<string, HUDCallback[]>
	HudHelper.Callbacks.RegisteredCallbacks = game:GetFrameCount() == 0 and CACHED_CALLBACKS or {}
	HudHelper.AddedCallbacks = game:GetFrameCount() == 0 and CACHED_MOD_CALLBACKS or HudHelper.AddedCallbacks

	HudHelper.LoadedPatches = false

	return HudHelper
end

---Initializes data and functions that get overwritten when a newer version of the mod is loaded.
local function InitFunctions()
	local HUD_ELEMENTS = HudHelper.HUD_ELEMENTS

	local isItemIDType = {
		[HudHelper.HUDType.ACTIVE_ID] = true,
		[HudHelper.HUDType.TRINKET_ID] = true,
		[HudHelper.HUDType.CARD_ID] = true,
		[HudHelper.HUDType.PILL_ID] = true
	}

	---List of HudHelper.HUDPlayers, indexed by corner of which corner of the HUD they're in.
	---@type table<integer, EntityPtr[] | nil>
	HudHelper.HUDPlayers = {}

	HudHelper.HUDTwinBlacklist = {
		[PlayerType.PLAYER_THESOUL_B] = true,
	}

	---@param entityPtr EntityPtr
	---@return EntityPlayer?
	local function tryGetPlayerFromPtr(entityPtr)
		if entityPtr
			and entityPtr.Ref
			and entityPtr.Ref:ToPlayer()
		then
			local player = entityPtr.Ref:ToPlayer()
			if player
				and player:Exists()
				and player.Variant == 0
			then
				return player
			end
		end
	end

	--#region Constants
	HudHelper.EXTRA_HUD_PADDING_TOP = Vector(0, 6)
	HudHelper.EXTRA_HUD_PADDING_BOTTOM = Vector(0, 3)

	HudHelper.Priority = {
		VANILLA = -1,
		MOD_PATCH = -0.999,
		HIGHEST = 0,
		HIGH = 10,
		NORMAL = 20,
		LOW = 30,
		LOWEST = 40,
		EID = 1000,
	}

	HudHelper.Callbacks.ID = {
		CHECK_HUD_HIDDEN = "HUDHELPER_CHECK_HUD_HIDDEN",
	}
	for _, v in pairs(HudHelper.Callbacks.ID) do
		if not HudHelper.Callbacks.RegisteredCallbacks[v] then
			HudHelper.Callbacks.RegisteredCallbacks[v] = {}
		end
	end

	HudHelper.CallbackPriority = {
		HIGHEST = 0,
		HIGH = 10,
		NORMAL = 20,
		LOW = 30,
		LOWEST = 40,
	}
	--#endregion

	--#region Helper Functions
	HudHelper.Utils = {}

	local condensedCoopHUD = false

	---@param player EntityPlayer
	local function canAddTwinHUD(player)
		local twinPlayer = player:GetOtherTwin()
		if player:GetPlayerType() == PlayerType.PLAYER_LAZARUS_B
			or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B
		then
			return false
		end

		if twinPlayer											 --You have a twin player
			and GetPtrHash(player:GetMainTwin()) == GetPtrHash(player) --Are the main of the 2 twins
			and not HudHelper.HUDTwinBlacklist[twinPlayer:GetPlayerType()] --Ensure your twin is allowed a HUD
		then
			return true
		end

		return false
	end

	---@param player EntityPlayer
	function HudHelper.Utils.FillPlayerHUDInventory(player)
		player = player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B and player:GetMainTwin() or player
		player:AddCollectible(CollectibleType.COLLECTIBLE_MOMS_PURSE)
		player:AddCollectible(CollectibleType.COLLECTIBLE_POLYDACTYLY)
		player:AddCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG)
		player:AddCollectible(CollectibleType.COLLECTIBLE_D6)
		player:AddCollectible(CollectibleType.COLLECTIBLE_TAMMYS_HEAD)
		player:AddTrinket(TrinketType.TRINKET_AAA_BATTERY)
		player:AddTrinket(TrinketType.TRINKET_SWALLOWED_PENNY)
		player:AddCard(Card.CARD_FOOL)
		player:AddCard(Card.CARD_MAGICIAN)
	end

	---@param player EntityPlayer
	---@param ignoreMod? boolean
	function HudHelper.Utils.GetEffectiveMaxHealth(player, ignoreMod)
		---@diagnostic disable-next-line: undefined-global
		if NoHealthCapModEnabled and not ignoreMod then
			---@diagnostic disable-next-line: undefined-global
			return NoHealthCapRedMax + NoHealthCapSoulHearts + (NoHealthCapBoneHearts * 2) + (NoHealthCapBrokenHearts * 2)
		end
		return player:GetEffectiveMaxHearts() + player:GetSoulHearts() +
			(player:GetBrokenHearts() * 2)
	end

	---@param hudLayout HUDLayout
	function HudHelper.Utils.GetMaxHeartColumns(hudLayout)
		if not REPENTANCE_PLUS
			and (
				hudLayout == HudHelper.HUDLayout.COOP
				or hudLayout == HudHelper.HUDLayout.STRAWMAN_HEARTS
			) then
			return 3
		end
		return 6
	end

	function HudHelper.Utils.GetCurrentMaxHeartRows(player)
		local hudLayout = HudHelper.Utils.GetHUDLayout(HudHelper.Utils.GetHUDPlayerNumberIndex(player))
		local heartPerRow = HudHelper.Utils.GetMaxHeartColumns(hudLayout) * 2
		local rows = ceil(HudHelper.Utils.GetEffectiveMaxHealth(player) / heartPerRow)
		return rows
	end

	function HudHelper.Utils.GetBookOffset(player)
		if player:IsCoopGhost() then return Vector.Zero end
		if (player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
				and player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
			or (player:GetPlayerType() == PlayerType.PLAYER_JUDAS and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
			return Vector(0, -4)
		end
		return Vector.Zero
	end

	---Returns the numbered index of the player corresponding with their placement on the HUD. 1 for P1, 2 for P2, etc
	---@param player EntityPlayer
	---@return integer
	function HudHelper.Utils.GetHUDPlayerNumberIndex(player)
		for index, hudPlayerTable in pairs(HudHelper.HUDPlayers) do
			for _, hudPlayer in pairs(hudPlayerTable) do
				local _player = tryGetPlayerFromPtr(hudPlayer)
				if _player and GetPtrHash(player) == GetPtrHash(_player) then
					return index
				end
			end
		end
		return -1
	end

	---@generic T
	---@param value T
	---@vararg string
	---@return T
	function HudHelper.Utils.CheckValueType(valueName, value, ...)
		local types = { ... }
		for i = 1, #types do
			if type(value) == types[i] then
				return value
			end
		end
		error(valueName .. " must be one of the following types: " .. table.concat({ ... }, ", "), 2)
	end

	---@generic T
	---@param val T | fun(...): T
	---@param ... any
	---@return T
	function HudHelper.Utils.ProcessFuncOrValue(val, ...)
		if type(val) == "function" then
			return val(...)
		else
			return val
		end
	end

	---@param vec Vector
	function HudHelper.Utils.CopyVector(vec)
		return Vector(vec.X, vec.Y)
	end

	---Executes given function for every player
	---Return anything to end the loop early
	---@param func fun(player: EntityPlayer, playerNum?: integer): any?
	function HudHelper.Utils.ForEachPlayer(func)
		if REPENTOGON then
			for i, player in ipairs(PlayerManager.GetPlayers()) do
				if func(player, i) then
					return true
				end
			end
		else
			for i = 0, game:GetNumPlayers() - 1 do
				if func(Isaac.GetPlayer(i), i) then
					return true
				end
			end
		end
	end

	---@param playerType PlayerType
	function HudHelper.Utils.AnyoneIsPlayerType(playerType)
		if REPENTOGON then return PlayerManager.AnyoneIsPlayerType(playerType) end
		local isType = false
		HudHelper.Utils.ForEachPlayer(function(player)
			if player:ToPlayer():GetPlayerType() == playerType then
				isType = true
			end
		end)
		return isType
	end

	---@param playerHUDIndex integer
	---@return HUDLayout
	function HudHelper.Utils.GetHUDLayout(playerHUDIndex)
		local hudPlayer = HudHelper.HUDPlayers[playerHUDIndex][1]
		local player = tryGetPlayerFromPtr(hudPlayer)
		if not player then return HudHelper.HUDLayout.P1 end

		if not REPENTANCE_PLUS then
			if playerHUDIndex == 1 then
				if canAddTwinHUD(player) then
					return HudHelper.HUDLayout.P1_MAIN_TWIN
				else
					return HudHelper.HUDLayout.P1
				end
			else
				if playerHUDIndex == 5 then
					return HudHelper.HUDLayout.P1_OTHER_TWIN
				else
					return HudHelper.HUDLayout.COOP
				end
			end
		else
			if playerHUDIndex == 1 then
				if not condensedCoopHUD and not player:GetOtherTwin() then
					return HudHelper.HUDLayout.P1
				elseif not condensedCoopHUD and player:GetOtherTwin() then
					return HudHelper.HUDLayout.P1_MAIN_TWIN
				elseif HudHelper.HUDPlayers[playerHUDIndex][2] then
					return HudHelper.HUDLayout.TWIN_COOP
				else
					return HudHelper.HUDLayout.COOP
				end
			else
				if playerHUDIndex == 5 then
					return HudHelper.HUDLayout.P1_OTHER_TWIN
				elseif HudHelper.HUDPlayers[playerHUDIndex][2] then
					return HudHelper.HUDLayout.TWIN_COOP
				else
					return HudHelper.HUDLayout.COOP
				end
			end
		end
	end

	function HudHelper.Utils.CheckFadedHealth(player)
		return player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE)
		or (player:GetSubPlayer() == nil and (player:GetPlayerType() == PlayerType.PLAYER_THESOUL or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN))
		or player:GetPlayerType() == PlayerType.PLAYER_JACOB2_B
	end

	local tempest = Font()
	tempest:Load("font/pftempestasevencondensed.fnt")

	--Moved out of util but remains for backwards compat
	---@param text string
	---@param pos Vector
	---@param kColor? KColor @Default: KColor.White
	---@param font? Font @Default: Tempest
	function HudHelper.Utils.RenderFont(text, pos, kColor, font)
		HudHelper.RenderFont(text, pos, kColor, font)
	end

	local getBookOffset = HudHelper.Utils.GetBookOffset
	local checkValueType = HudHelper.Utils.CheckValueType
	local processFuncOrValue = HudHelper.Utils.ProcessFuncOrValue
	local copyVector = HudHelper.Utils.CopyVector

	--#endregion

	--#region Custom Callbacks

	---@param id string
	---@param priority integer
	---@param func function
	---@param ... any
	function HudHelper.Callbacks.AddPriorityCallback(id, priority, func, ...)
		local callbacks = HudHelper.Callbacks.RegisteredCallbacks[id]
		local callback = {
			Priority = priority,
			Function = func,
			Args = { ... },
		}

		if #callbacks == 0 then
			callbacks[#callbacks + 1] = callback
		else
			for i = #callbacks, 1, -1 do
				if callbacks[i].Priority <= priority then
					table.insert(callbacks, i + 1, callback)
					return
				end
			end
			table.insert(callbacks, 1, callback)
		end
	end

	---@param id string
	---@param func function
	---@param ... any
	function HudHelper.Callbacks.AddCallback(id, func, ...)
		HudHelper.Callbacks.AddPriorityCallback(id, HudHelper.CallbackPriority.NORMAL, func, ...)
	end

	---@param id string
	---@param func function
	function HudHelper.Callbacks.RemoveCallback(id, func)
		local callbacks = HudHelper.Callbacks.RegisteredCallbacks[id]
		for i = #callbacks, 1, -1 do
			if callbacks[i].Function == func then
				table.remove(callbacks, i)
			end
		end
	end

	--#endregion

	function HudHelper.ShouldHideHUD()
		if ModConfigMenu and ModConfigMenu.IsVisible
			or not game:GetHUD():IsVisible() and not (TheFuture or {}).HiddenHUD
			or game:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD)
		then
			return true
		end

		local callbacks = HudHelper.Callbacks.RegisteredCallbacks[HudHelper.Callbacks.ID.CHECK_HUD_HIDDEN]
		for i = 1, #callbacks do
			if callbacks[i].Function() then
				return true
			end
		end

		return false
	end

	--#region Offset Functions

	---Gives the location of the player's HUD as a vector, starting from the top left corner.
	---@param playerHUDIndex integer
	---@return Vector
	---@function
	---@scope Mod.HudHelper
	function HudHelper.GetHUDPosition(playerHUDIndex)
		playerHUDIndex = min(4, playerHUDIndex)
		local hudOffsetOption = Options.HUDOffset
		local width, height = Isaac.GetScreenWidth(), Isaac.GetScreenHeight()
		local cornerOffsets = {
			Vector((hudOffsetOption * 20), (hudOffsetOption * 12)),
			Vector((-hudOffsetOption * 24) + width, (hudOffsetOption * 12)),
			Vector((hudOffsetOption * 22), (-hudOffsetOption * 16) + height),
			Vector((-hudOffsetOption * 16) + width, (-hudOffsetOption * 6) + height)
		}
		local REP_HUD_OFFSET = {
			Vector.Zero,
			Vector(-159, 0),
			Vector(10, -29),
			Vector(-167, -39)
		}
		local REP_PLUS_OFFSET = {
			Vector(0, 6),
			Vector(-175, 6),
			Vector(10, -29),
			Vector(-183, -39)
		}

		local hudOffset = REPENTANCE_PLUS and REP_PLUS_OFFSET or REP_HUD_OFFSET
		local hudPos = cornerOffsets[playerHUDIndex] + hudOffset[playerHUDIndex]

		if REPENTANCE_PLUS
			and (playerHUDIndex == 3 or playerHUDIndex == 4)
			and HudHelper.HUDPlayers[playerHUDIndex]
			and HudHelper.HUDPlayers[playerHUDIndex][1]
		then
			local player = tryGetPlayerFromPtr(HudHelper.HUDPlayers[playerHUDIndex][1])
			if player then
				if player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B
					or player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B
				then
					hudPos = Vector(hudPos.X, hudPos.Y - 32 + 10 * hudOffsetOption)
				elseif player:GetPlayerType() == PlayerType.PLAYER_CAIN_B then
					hudPos = Vector(hudPos.X, hudPos.Y - 28 + 10 * hudOffsetOption)
				elseif HudHelper.Utils.GetHUDLayout(playerHUDIndex) == HudHelper.HUDLayout.TWIN_COOP then
					hudPos = Vector(hudPos.X, hudPos.Y - 32 + 16 * hudOffsetOption)
				end
			end
		end

		return hudPos
	end

	local bethanyChecks = {
		PlayerType.PLAYER_BETHANY,
		PlayerType.PLAYER_BETHANY_B
	}
	---@param specificResource? "Coins" | "Bombs" | "Keys"
	function HudHelper.GetResourcesOffset(specificResource)
		local hasBB = HudHelper.Utils.AnyoneIsPlayerType(PlayerType.PLAYER_BLUEBABY_B)
		local offset = 0
		local hudLayout = HudHelper.Utils.GetHUDLayout(1)
		local p1TwinOffset = 0
		local poopAndBombsOffset = 0
		local bethOffset = 0
		local repPlusOffset = REPENTANCE_PLUS and -4 or 0

		--Tainted BB + Others
		HudHelper.Utils.ForEachPlayer(function(player)
			local playerType = player:GetPlayerType()
			if hasBB and playerType ~= PlayerType.PLAYER_BLUEBABY_B then
				offset = 9
				poopAndBombsOffset = 9
			end
		end)

		--J&E
		if hudLayout == HudHelper.HUDLayout.P1_MAIN_TWIN
			or hudLayout == HudHelper.HUDLayout.TWIN_COOP
		then
			offset = offset + 14
			p1TwinOffset = 14
		end

		local bethStupidOffset = 0
		--The Beths (why are they so fucking stupid)
		for i, playerType in ipairs(bethanyChecks) do
			if HudHelper.Utils.AnyoneIsPlayerType(playerType) then
				if i == 1 and poopAndBombsOffset > 0 then
					offset = offset + 2
				end
				offset = offset + 9 + bethStupidOffset
				bethOffset = bethOffset + 9 + bethStupidOffset
				bethStupidOffset = bethStupidOffset + 2
			end
		end

		if specificResource then
			if specificResource == "Coins" then
				return Vector(0, repPlusOffset + p1TwinOffset)
			elseif specificResource == "Bombs" then
				local stupidJEOffset = ((offset - p1TwinOffset) > 0 or p1TwinOffset == 0) and 0 or 1
				return Vector(0, repPlusOffset + p1TwinOffset + (offset > 0 and -1 or 0) + stupidJEOffset)
			elseif specificResource == "Keys" then
				local keysOffset = p1TwinOffset + poopAndBombsOffset
				if poopAndBombsOffset == 0 and bethOffset > 0 then
					keysOffset = keysOffset - 2
				end
				return Vector(0, repPlusOffset + keysOffset)
			end
		end
		return Vector(0, repPlusOffset + offset)
	end

	---Gives the location of where the custom hud (turnover, throwing bag, etc) should be drawn.
	---
	---Starts its position from GetHUDOffset.
	---@param playerHUDIndex integer
	function HudHelper.GetExtraHUDOffset(playerHUDIndex)
		local REP_EXTRA_OFFSET = {
			Vector(50, 33),
			Vector(50, 50),
			Vector(50, -20),
			Vector(50, -20),
		}
		local REP_PLUS_EXTRA_OFFSET = {
			Vector(50, 29),
			Vector(50, 41),
			Vector(50, -20),
			Vector(50, -20),
		}
		local customOffset = REP_EXTRA_OFFSET
		local hudLayout = HudHelper.Utils.GetHUDLayout(playerHUDIndex)
		playerHUDIndex = min(4, playerHUDIndex)
		if REPENTANCE_PLUS then
			customOffset = REP_PLUS_EXTRA_OFFSET
			if playerHUDIndex == 1 and #HudHelper.GetHUDPlayers() > 2 then
				customOffset[1] = Vector(50, 41)
			end
		end
		if hudLayout == HudHelper.HUDLayout.P1_OTHER_TWIN then
			customOffset[playerHUDIndex] = Vector(80, -20)
		end
		return copyVector(customOffset[playerHUDIndex])
	end

	function HudHelper.GetItemSpecificOffset(itemID, book, twinCOOP)
		local checkFrom = HudHelper.ItemSpecificOffset

		if book then
			checkFrom = twinCOOP and checkFrom.TwinCoopBook or checkFrom.Book
		else
			checkFrom = checkFrom.Normal
		end

		return checkFrom[itemID] or Vector.Zero
	end

	---@param player EntityPlayer
	---@param itemID CollectibleType
	---@param slot ActiveSlot
	function HudHelper.ShouldActiveBeDisplayed(player, itemID, slot)
		return not HudHelper.ShouldHideHUD()
			and not player:IsCoopGhost()
			and itemID ~= CollectibleType.COLLECTIBLE_NULL
			and player:HasCollectible(itemID, true)
			and itemConfig:GetCollectible(itemID).Type == ItemType.ITEM_ACTIVE
			and player:GetActiveItem(slot) == itemID
			and (slot <= ActiveSlot.SLOT_SECONDARY --Fine to display if you simply have the item
				or (player:GetCard(0) == 0 --Otherwise, assumed to be in first slot if no cards or pills are there.
					and player:GetPill(0) == 0
				)
			)
	end

	---@param slot ActiveSlot
	---@param scale number
	---@param hudLayout HUDLayout
	function HudHelper.GetActiveChargeBarHUDOffset(slot, scale, hudLayout)
		local chargebarXOffset = 34
		if hudLayout ~= HudHelper.HUDLayout.P1_OTHER_TWIN and slot == ActiveSlot.SLOT_SECONDARY then
			chargebarXOffset = -2
		elseif hudLayout == HudHelper.HUDLayout.P1_OTHER_TWIN then
			if slot == ActiveSlot.SLOT_SECONDARY then
				chargebarXOffset = 38
			else
				chargebarXOffset = 0
			end
		end
		return Vector(chargebarXOffset * scale, 17 * scale)
	end

	---Gives the location of the player's active item HUD as a vector
	---@param player EntityPlayer
	---@param playerHUDIndex integer
	---@param slot ActiveSlot
	---@param separateReturns? boolean @If true, separates the base active slot position and the slot-specific offset (Book of Virtues + item-specific offsets)
	---@return Vector, Vector?
	function HudHelper.GetActiveHUDOffset(player, playerHUDIndex, slot, scale, separateReturns)
		local hudLayout = HudHelper.Utils.GetHUDLayout(playerHUDIndex)
		local itemOffset = Vector.Zero
		local bookOffset = slot == ActiveSlot.SLOT_PRIMARY and getBookOffset(player) or Vector.Zero
		local itemSpecificOffset = HudHelper.GetItemSpecificOffset(player:GetActiveItem(slot), bookOffset.Y ~= 0, hudLayout == HudHelper.HUDLayout.TWIN_COOP) * scale
		itemOffset = itemSpecificOffset + bookOffset

		if slot <= ActiveSlot.SLOT_SECONDARY then
			playerHUDIndex = min(4, playerHUDIndex)
			local activeOffset = Vector(4, 0)
			local additionalOffset = Vector.Zero
			if hudLayout == HudHelper.HUDLayout.P1_OTHER_TWIN then
				additionalOffset = REPENTANCE_PLUS and Vector(143, 0) or Vector(127, 0)
			end
			if slot == ActiveSlot.SLOT_SECONDARY then
				if hudLayout == HudHelper.HUDLayout.P1_OTHER_TWIN then
					additionalOffset = REPENTANCE_PLUS and Vector(159, -4) or Vector(153, 0)
				elseif (hudLayout == HudHelper.HUDLayout.P1_MAIN_TWIN or hudLayout == HudHelper.HUDLayout.COOP) and REPENTANCE_PLUS then
					additionalOffset = Vector(-1, -4)
				else
					additionalOffset = Vector(-9, 0)
				end
			end
			if hudLayout == HudHelper.HUDLayout.TWIN_COOP then
				additionalOffset = additionalOffset + Vector(19, 4)
			end
			activeOffset = activeOffset + additionalOffset

			if separateReturns then
				return activeOffset, itemOffset
			else
				return activeOffset + itemOffset
			end
		else
			if separateReturns then
				return HudHelper.GetPocketHUDOffset(player), itemOffset
			else
				return HudHelper.GetPocketHUDOffset(player) + itemOffset
			end
		end
	end

	---@param player EntityPlayer
	---@param nameOrHUD string | HUDInfo
	---@return Vector
	function HudHelper.GetExtraHUDPadding(player, nameOrHUD)
		local playerHUDIndex = HudHelper.Utils.GetHUDPlayerNumberIndex(player)
		if playerHUDIndex == -1 then
			return Vector.Zero
		end
		local hudLayout = HudHelper.Utils.GetHUDLayout(playerHUDIndex)
		local isAtTop = playerHUDIndex <= 2
		local padding = isAtTop and HudHelper.EXTRA_HUD_PADDING_TOP or HudHelper.EXTRA_HUD_PADDING_BOTTOM

		local hud
		if type(nameOrHUD) == "table" then
			hud = nameOrHUD
		else
			for _, searchHUD in ipairs(HUD_ELEMENTS[HudHelper.HUDType.EXTRA]) do
				if searchHUD.Name == nameOrHUD then
					hud = searchHUD
				end
			end
		end
		if not hud then return Vector.Zero end
		local yPadding = processFuncOrValue(hud.YPadding, player, playerHUDIndex, hudLayout) + padding.Y
		if not isAtTop then
			yPadding = -yPadding
		end
		local xPadding = hud.XPadding[min(4, playerHUDIndex)] + padding.X
		local pos = Vector(xPadding, yPadding)

		return pos
	end

	---@param playerHUDIndex integer
	---@return Vector
	function HudHelper.GetHealthHUDOffset(playerHUDIndex)
		local healthOffset = Vector(48, 12)
		local hudLayout = HudHelper.Utils.GetHUDLayout(playerHUDIndex)
		playerHUDIndex = min(4, playerHUDIndex)

		if hudLayout == HudHelper.HUDLayout.P1_OTHER_TWIN then
			healthOffset = REPENTANCE_PLUS and Vector(135, 12) or Vector(119, 12)
		end
		return healthOffset
	end

	---@param player EntityPlayer
	function HudHelper.GetStrawmanHealthHUDOffset(player)
		local playerPos = Isaac.WorldToRenderPosition(player.Position + player.PositionOffset)
		local heartOffset = Vector(0, (-30 * player.SpriteScale.Y))
		local flyingOffset = player:IsFlying() and Vector(0, -4) or Vector.Zero
		local position = playerPos + heartOffset + flyingOffset
		local numHearts = (player:GetEffectiveMaxHearts() + player:GetSoulHearts()) / 2
		local xOffset = 0
		for i = 1, min(6, numHearts) do
			xOffset = 5 * (i - 1)
		end
		position = position - Vector(xOffset, 0)
		return position
	end

	---@param player EntityPlayer
	---@return Vector
	function HudHelper.GetPocketHUDOffset(player)
		local playerHUDIndex = HudHelper.Utils.GetHUDPlayerNumberIndex(player)
		local hudLayout = HudHelper.Utils.GetHUDLayout(playerHUDIndex)
		playerHUDIndex = min(4, playerHUDIndex)
		local isActive = player:GetCard(0) == 0 and player:GetPill(0) == 0
		local pocketPosOffset = isActive and Vector(-24, -18) or Vector(-3, 0)
		if hudLayout == HudHelper.HUDLayout.P1_MAIN_TWIN and not REPENTANCE_PLUS then
			pocketPosOffset = pocketPosOffset + (isActive and Vector(11, 41) or Vector(14, 41))
		elseif hudLayout == HudHelper.HUDLayout.P1_OTHER_TWIN then
			if isActive then
				pocketPosOffset = pocketPosOffset + (REPENTANCE_PLUS and Vector(150, 43) or Vector(160, -5))
			else
				pocketPosOffset = pocketPosOffset + (REPENTANCE_PLUS and Vector(138, 33) or Vector(160, -5))
			end
		elseif hudLayout == HudHelper.HUDLayout.P1 then
			---Should be mindful that this is relative to bottom right HUD and should be combined with that HUD's position
			pocketPosOffset = pocketPosOffset + (REPENTANCE_PLUS and Vector(171, 27) or Vector(155, 27))
		elseif hudLayout == HudHelper.HUDLayout.TWIN_COOP then
			pocketPosOffset = pocketPosOffset + (isActive and Vector(60, 45) or Vector(48, 35))
		else
			if isActive then
				pocketPosOffset = pocketPosOffset + (REPENTANCE_PLUS and Vector(60, 45) or Vector(12, 44))
			else
				pocketPosOffset = pocketPosOffset + (REPENTANCE_PLUS and Vector(48, 35) or Vector(15, 44))
			end
			if REPENTANCE_PLUS then
				if player:GetTrinket(0) ~= 0 then
					pocketPosOffset = pocketPosOffset + Vector(13, 0)
				end
				if player:GetTrinket(1) ~= 0 then
					pocketPosOffset = pocketPosOffset + Vector(16, 0)
				end
			else
				local maxHearts = HudHelper.Utils.GetEffectiveMaxHealth(player)
				if maxHearts > 18 then
					local rows = HudHelper.Utils.GetCurrentMaxHeartRows(player)
					local startAt = (rows - 3) * 2
					pocketPosOffset = pocketPosOffset + Vector(0, startAt + (rows - 3) * 8)
				end
			end
		end
		return pocketPosOffset
	end

	---@param player EntityPlayer
	---@param slot integer
	function HudHelper.GetTrinketHUDOffset(player, slot)
		local playerHUDIndex = HudHelper.Utils.GetHUDPlayerNumberIndex(player)
		local hudLayout = HudHelper.Utils.GetHUDLayout(playerHUDIndex)
		playerHUDIndex = min(4, playerHUDIndex)
		local pos = Vector.Zero

		if hudLayout == HudHelper.HUDLayout.P1 or (hudLayout == HudHelper.HUDLayout.P1_MAIN_TWIN and not REPENTANCE_PLUS) then
			pos = slot == 0 and Vector(12, 1) or Vector(-12, -23)
		elseif hudLayout == HudHelper.HUDLayout.COOP then
			if REPENTANCE_PLUS then
				pos = slot == 0 and Vector(38.5, 25) or Vector(54.5, 25)
			else
				pos = slot == 0 and Vector(6, 24) or Vector(16, 24)
			end
		elseif hudLayout == HudHelper.HUDLayout.P1_MAIN_TWIN and REPENTANCE_PLUS then
			pos = slot == 0 and Vector(38.5, 25) or Vector(54.5, 25)
		elseif hudLayout == HudHelper.HUDLayout.TWIN_COOP then
			pos = slot == 0 and Vector(26.5, 23) or Vector(50.5, 23)
		elseif hudLayout == HudHelper.HUDLayout.P1_OTHER_TWIN then
			if REPENTANCE_PLUS then
				pos = slot == 0 and Vector(125.5, 23) or Vector(109.5, 23)
			else
				pos = slot == 0 and Vector(135, -20) or Vector(107, -20)
			end
		end

		return pos
	end

	function HudHelper.GetExtraItemHUDOffset()
		local extraHUDOffset = Vector(112, 92)
		if Options.ExtraHUDStyle == 2 then
			extraHUDOffset = Vector(104, 79.5)
		end
		return extraHUDOffset
	end

	--#endregion

	--#region Misc helper functions

	---@param HUDSprite Sprite
	---@param charge number
	---@param maxCharge number
	---@param position Vector
	---@function
	function HudHelper.RenderChargeBar(HUDSprite, charge, maxCharge, position)
		if HudHelper.ShouldHideHUD() or not Options.ChargeBars then
			return
		end

		if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
			return
		end

		local chargePercent = min(charge / maxCharge, 1)

		if chargePercent == 1 then
			-- ChargedHUD:IsPlaying("StartCharged") and not
			if HUDSprite:IsFinished("Charged") or HUDSprite:IsFinished("StartCharged") then
				if not HUDSprite:IsPlaying("Charged") then
					HUDSprite:Play("Charged", true)
				end
			elseif not HUDSprite:IsPlaying("Charged") then
				if not HUDSprite:IsPlaying("StartCharged") then
					HUDSprite:Play("StartCharged", true)
				end
			end
		elseif chargePercent > 0 and chargePercent < 1 then
			if not HUDSprite:IsPlaying("Charging") then
				HUDSprite:Play("Charging")
			end
			local frame = floor(chargePercent * 100)
			HUDSprite:SetFrame("Charging", frame)
		elseif chargePercent == 0 and not HUDSprite:IsPlaying("Disappear") and not HUDSprite:IsFinished("Disappear") then
			HUDSprite:Play("Disappear", true)
		end

		HUDSprite:Render(position)
		if Isaac.GetFrameCount() % 2 == 0 and not game:IsPaused() then
			HUDSprite:Update()
		end
	end

	--Literally just rendering font, but with the screenshake offset, because the game is funny like that
	---@param text string
	---@param pos Vector
	---@param kColor? KColor @Default: KColor.White
	---@param font? Font @Default: Tempest
	function HudHelper.RenderFont(text, pos, kColor, font)
		pos = pos + game.ScreenShakeOffset
		font = font or tempest
		font:DrawString(text, pos.X, pos.Y, kColor or KColor.White)
	end

	---@type SeedEffect[]
	local seedDisablesAchievements = {
		SeedEffect.SEED_INFINITE_BASEMENT,
		SeedEffect.SEED_PICKUPS_SLIDE,
		SeedEffect.SEED_ITEMS_COST_MONEY,
		SeedEffect.SEED_PACIFIST,
		SeedEffect.SEED_ENEMIES_RESPAWN,
		SeedEffect.SEED_POOP_TRAIL,
		SeedEffect.SEED_INVINCIBLE,
		SeedEffect.SEED_KIDS_MODE,
		SeedEffect.SEED_PERMANENT_CURSE_LABYRINTH,
		SeedEffect.SEED_PREVENT_CURSE_DARKNESS,
		SeedEffect.SEED_PREVENT_CURSE_LABYRINTH,
		SeedEffect.SEED_PREVENT_CURSE_LOST,
		SeedEffect.SEED_PREVENT_CURSE_UNKNOWN,
		SeedEffect.SEED_PREVENT_CURSE_MAZE,
		SeedEffect.SEED_PREVENT_CURSE_BLIND,
		SeedEffect.SEED_PREVENT_ALL_CURSES,
		SeedEffect.SEED_GLOWING_TEARS,
		SeedEffect.SEED_ALL_CHAMPIONS,
		SeedEffect.SEED_ALWAYS_CHARMED,
		SeedEffect.SEED_ALWAYS_CONFUSED,
		SeedEffect.SEED_ALWAYS_AFRAID,
		SeedEffect.SEED_ALWAYS_ALTERNATING_FEAR,
		SeedEffect.SEED_ALWAYS_CHARMED_AND_AFRAID,
		SeedEffect.SEED_SUPER_HOT
	}

	---@param iconType HUDIconType
	function HudHelper.RenderHUDIcon(spr, iconType)
		if HudHelper.ShouldHideHUD() then return end
		local pos = HudHelper.GetHUDPosition(1)
		local xPos = 0
		local yPos = 0
		if iconType == HudHelper.IconType.COINS then
			yPos = 32 + HudHelper.GetResourcesOffset("Coins").Y
		elseif iconType == HudHelper.IconType.BOMBS then
			yPos = 44 + HudHelper.GetResourcesOffset("Bombs").Y
		elseif iconType == HudHelper.IconType.KEYS then
			yPos = 56 + HudHelper.GetResourcesOffset("Keys").Y
		else
			yPos = 72
			local hasChallenge = Isaac.GetChallenge() > Challenge.CHALLENGE_NULL
			local hasNoAchievements = hasChallenge
			local seeds = game:GetSeeds()
			if not hasNoAchievements and iconType ~= HudHelper.IconType.DESTINATION_ICON then
				for _, seed in ipairs(seedDisablesAchievements) do
					if seeds:HasSeedEffect(seed) then
						hasNoAchievements = true
						break
					end
				end
			end
			local isGreedMode = game:IsGreedMode()
			local hasDifficulty = isGreedMode or not hasChallenge and game.Difficulty > Difficulty.DIFFICULTY_NORMAL

			if iconType == HudHelper.IconType.MISC_ICON then
				--1 icon present
				xPos = 20

				if isGreedMode then
					if game:GetLevel():GetStage() == LevelStage.STAGE7_GREED then
						if game:GetRoom():IsCurrentRoomLastBoss() and game:GetRoom():IsClear() then
							if Isaac.GetPlayer():GetGreedDonationBreakChance() < 10 then
								xPos = 37
							else
								xPos = 45
							end
							if hasNoAchievements then
								xPos = xPos + 4
							end
						else
							xPos = 21
						end
					else
						xPos = 48
						if hasNoAchievements then
							xPos = xPos + 4
						end
					end
					if hasNoAchievements then
						xPos = xPos + 12
					end
				--2 or 0 icons present
				elseif hasChallenge
					or (hasDifficulty and hasNoAchievements)
					or (not hasDifficulty and not hasNoAchievements)
				then
					xPos = 34
				end
				if not hasDifficulty and not hasNoAchievements then
					yPos = 65
				end
			elseif iconType == HudHelper.IconType.DIFFICULTY_ICON then
				if not hasDifficulty then
					return
				elseif isGreedMode then
					--Greed icon disappears
					if game:GetLevel():GetStage() == LevelStage.STAGE7_GREED
						and game:GetRoom():IsCurrentRoomLastBoss()
						and game:GetRoom():IsClear()
					then
						return
					end
					xPos = hasNoAchievements and 16 or 0
				else
					xPos = hasNoAchievements and 0 or 4
				end
			elseif iconType == HudHelper.IconType.NO_ACHIEVEMENT_ICON then
				if not hasNoAchievements then
					return
				elseif isGreedMode then
					xPos = 0
				else
					xPos = hasChallenge and 0 or not hasDifficulty and 4 or 16
				end
			elseif iconType == HudHelper.IconType.DESTINATION_ICON then
				if not hasChallenge then
					return
				else
					xPos = 16
				end
			elseif iconType == HudHelper.IconType.STAT then
				if not Options.FoundHUD then return end
				local players = HudHelper.GetHUDPlayers()
				local DUALITY_OFFSET = 15
				if #players > 1 then
					yPos = 185
				else
					yPos = 170
				end
				if REPENTOGON and PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DUALITY) then
					yPos = yPos - DUALITY_OFFSET
				else
					for _, player in ipairs(players) do
						if player:HasCollectible(CollectibleType.COLLECTIBLE_DUALITY) then
							yPos = yPos - DUALITY_OFFSET
							break
						end
					end
				end
			end
			yPos = yPos + HudHelper.GetResourcesOffset().Y
		end
		pos = pos + Vector(xPos, yPos)
		spr:Render(pos)
		return pos
	end

	local lastRenderedHUDSprite
	local lastRenderedGoldenHUDSprite
	local hudSprite = Sprite()
	local shadowSprite = Sprite()
	local goldenHUDSprite = Sprite()
	if REPENTOGON then
		goldenHUDSprite:SetRenderFlags(AnimRenderFlags.GOLDEN)
	end

	---For rendering active items or trinkets
	---@param spritePath string
	---@param pos Vector
	---@param scale number
	---@param alpha number
	---@param isGolden? boolean
	---@param renderShadow? boolean
	function HudHelper.RenderHUDItem(spritePath, pos, scale, alpha, isGolden, renderShadow)
		if isGolden and spritePath ~= lastRenderedGoldenHUDSprite then
			if not goldenHUDSprite:IsLoaded() or not shadowSprite:IsLoaded() then
				if REPENTOGON then
					goldenHUDSprite:Load("gfx/ui/hudhelper_hud_item.anm2")
				else
					goldenHUDSprite:Load("gfx/ui/hudhelper_hud_golden_item.anm2")
				end
				goldenHUDSprite:Play("Idle")
				shadowSprite:Load("gfx/ui/hudhelper_hud_item.anm2")
				shadowSprite:Play("Idle")
			end
			shadowSprite:ReplaceSpritesheet(0, spritePath)
			shadowSprite:LoadGraphics()
			for i = 0, REPENTOGON and 0 or 31 do
				goldenHUDSprite:ReplaceSpritesheet(i, spritePath)
			end
			goldenHUDSprite:LoadGraphics()
			lastRenderedGoldenHUDSprite = spritePath
		end
		if not isGolden and not spritePath ~= lastRenderedHUDSprite then
			if not hudSprite:IsLoaded() or not shadowSprite:IsLoaded() then
				hudSprite:Load("gfx/ui/hudhelper_hud_item.anm2")
				hudSprite:Play("Idle")
				shadowSprite:Load("gfx/ui/hudhelper_hud_item.anm2")
				shadowSprite:Play("Idle")
			end
			shadowSprite:ReplaceSpritesheet(0, spritePath)
			shadowSprite:LoadGraphics()
			hudSprite:ReplaceSpritesheet(0, spritePath)
			hudSprite:LoadGraphics()
			lastRenderedHUDSprite = spritePath
		end
		if isGolden then
			if renderShadow then
				shadowSprite.Color = Color(0, 0, 0, alpha * 0.25)
				shadowSprite.Scale = Vector(scale, scale)
				shadowSprite:Render(pos + (Vector(2, 2) * scale))
			end
			goldenHUDSprite.Color = Color(1, 1, 1, alpha)
			goldenHUDSprite.Scale = Vector(scale, scale)
			goldenHUDSprite:Render(pos)
		else
			if renderShadow then
				shadowSprite.Color = Color(0, 0, 0, alpha * 0.25)
				shadowSprite.Scale = Vector(scale, scale)
				shadowSprite:Render(pos + (Vector(2, 2) * scale))
			end
			hudSprite.Color = Color(1, 1, 1, alpha)
			hudSprite.Scale = Vector(scale, scale)
			hudSprite:Render(pos)
		end
	end

	--#endregion

	--#region HUD Element Functions

	---@param params HUDInfo | HUDInfo_Active | HUDInfo_Health | HUDInfo_Pocket | HUDInfo_Trinket | HUDInfo_Extra | HUDInfo_ActiveID | HUDInfo_TrinketID | HUDInfo_CardID | HUDInfo_PillID
	---@param hudType? HUDType
	function HudHelper.RegisterHUDElement(params, hudType)
		local hudElements = HudHelper.HUD_ELEMENTS[hudType]
		if not hudElements then hudElements = HudHelper.HUD_ELEMENTS[HudHelper.HUDType.BASE] end
		local useItemID = isItemIDType[hudType]

		local targetIndex = useItemID and params.ItemID or #hudElements + 1
		if not useItemID then
			for i, hud in ipairs(hudElements) do
				if hud.Name == params.Name then
					targetIndex = i
				end
			end
		end
		local xPadding = checkValueType("XPadding", params.XPadding, "number", "table", "nil")

		if params.XPadding then
			if type(xPadding) == "number" then
				xPadding = {
					xPadding,
					xPadding,
					xPadding,
					xPadding,
				}
			end
		end

		hudElements[targetIndex] = {
			Name = checkValueType("Name", params.Name, useItemID and "nil" or "string"),
			Priority = checkValueType("Priority", params.Priority, useItemID and "nil" or "number"),
			Condition = checkValueType("Condition", params.Condition, "function", useItemID and "nil" or nil),
			OnRender = checkValueType("OnRender", params.OnRender, "function"),
			XPadding = xPadding,
			YPadding = checkValueType("YPadding", params.YPadding, "number", "function", "nil"),
			BypassGhostBaby = checkValueType("BypassGhostBaby", params.BypassGhostBaby, "boolean", "nil"),
			PreRenderCallback = checkValueType("PreRenderCallback", params.PreRenderCallback, "boolean", "nil"),
			ItemID = checkValueType("ItemID", params.ItemID, useItemID and "number" or "nil")
		}

		if not useItemID then
			table.sort(hudElements, function(a, b)
				return a.Priority < b.Priority
			end)
		end
	end

	--- Removes all HUD elements with the given name.
	---@param nameOrID string | integer @The string (or ItemID, if an ID-based elemment) you used when registering your HUD element. Passing a 0 or an empty string will unregister all elements of the specified type
	---@param hudType HUDType
	function HudHelper.UnregisterHUDElement(nameOrID, hudType)
		local hudElements = HudHelper.HUD_ELEMENTS[hudType]
		if not hudElements then return end

		for i = #hudElements, 1, -1 do
			if (hudElements[i].ItemID or 0) == nameOrID or (hudElements[i].Name or "") == nameOrID then
				table.remove(hudElements, i)
			end
		end
	end

	--#endregion

	--#region Render HUD Elements

	---HUDInfo object of last HUD element that was rendered, indexed by player number
	HudHelper.LastAppliedHUD = {
		[HudHelper.HUDType.BASE] = {}, ---@type table<integer, HUDInfo>
		[HudHelper.HUDType.ACTIVE] = {}, ---@type table<integer, HUDInfo_Active>
		[HudHelper.HUDType.HEALTH] = {}, ---@type table<integer, HUDInfo_Health>
		[HudHelper.HUDType.POCKET] = {}, ---@type table<integer, HUDInfo_Pocket>
		[HudHelper.HUDType.TRINKET] = {}, ---@type table<integer, HUDInfo_Trinket>
		[HudHelper.HUDType.EXTRA] = {}, ---@type table<integer, HUDInfo_Extra>
		[HudHelper.HUDType.ACTIVE_ID] = {}, ---@type table<integer, HUDInfo_ActiveID>
		[HudHelper.HUDType.TRINKET_ID] = {}, ---@type table<integer, HUDInfo_TrinketID>
		[HudHelper.HUDType.CARD_ID] = {}, ---@type table<integer, HUDInfo_CardID>
		[HudHelper.HUDType.PILL_ID] = {}, ---@type table<integer, HUDInfo_PillID>
	}

	local numPlayers = 0
	local TWIN_COOP_OFFSET = Vector(0, 32)

	---@param playerIndex integer
	local function addActivePlayers(playerIndex)
		local numHudPlayers = 0
		for _, _ in ipairs(HudHelper.HUDPlayers) do
			numHudPlayers = numHudPlayers + 1
		end
		local player = Isaac.GetPlayer(playerIndex)
		if not player
			or player.Parent
			or numHudPlayers == 4
			or GetPtrHash(player:GetMainTwin()) ~= GetPtrHash(player)
		then
			return
		end

		local hudPlayer = {}
		HudHelper.HUDPlayers[numHudPlayers + 1] = hudPlayer
		table.insert(hudPlayer, EntityPtr(player))
		local twinPlayer = player:GetOtherTwin()

		if not condensedCoopHUD
			and #HudHelper.HUDPlayers == 1
			and canAddTwinHUD(player)
		then
			HudHelper.HUDPlayers[5] = {}
			--I fucking hate this game because P4 can take up the same corner as P1 Esau
			--So I'm doing this in order to give both huds different layouts
			HudHelper.HUDPlayers[5][1] = EntityPtr(twinPlayer)
		end
		if REPENTANCE_PLUS
			and (#HudHelper.HUDPlayers > 1 or condensedCoopHUD)
			and canAddTwinHUD(player)
		then
			table.insert(hudPlayer, EntityPtr(twinPlayer))
		end
	end

	function HudHelper.GetHUDPlayers()
		local players = {}
		for _, hudPlayer in pairs(HudHelper.HUDPlayers) do
			for _, entityPtr in pairs(hudPlayer) do
				local player = tryGetPlayerFromPtr(entityPtr)
				if player then
					table.insert(players, player)
				end
			end
		end
		return players
	end

	---For other mods to use
	---@param hudType HUDType
	---@param isPreCallback boolean
	---@param player EntityPlayer
	---@param playerHUDIndex integer
	---@param hudLayout HUDLayout
	---@param position Vector
	function HudHelper.RenderHUDElements(hudType, isPreCallback, player, playerHUDIndex, hudLayout, position, ...)
		if checkValueType("player", player, "userdata") and getmetatable(player).__type == "EntityPlayer"
			and checkValueType("playerHUDIndex", playerHUDIndex, "number")
			and checkValueType("hudType", hudType, "number") and hudType >= 0 and hudType < HudHelper.HUDType.NUM_TYPES
			and checkValueType("position", position, "userdata") and getmetatable(position).__type == "Vector"
		then
			local hudElements = HudHelper.HUD_ELEMENTS[hudType]
			local extraParams = { ... }
			local conditionParam
			local useItemID = isItemIDType[hudType]
			if useItemID
				or hudType == HudHelper.HUDType.ACTIVE
			then
				conditionParam = extraParams[3]
			elseif hudType == HudHelper.HUDType.TRINKET then
				conditionParam = extraParams[2]
			end
			if useItemID then
				local itemID = conditionParam
				local hud = hudElements[itemID & ~TrinketType.TRINKET_GOLDEN_FLAG]
				if hud
					and (not hud.Condition or hud.Condition(player, playerHUDIndex, hudLayout))
					and (not player:IsCoopGhost() or hud.BypassGhostBaby)
					and ((not hud.PreRenderCallback and not isPreCallback) or (hud.PreRenderCallback and isPreCallback))
				then
					hud.OnRender(player, playerHUDIndex, hudLayout, position, ...)
					HudHelper.LastAppliedHUD[hudType][playerHUDIndex] = hud
				end
			else
				for _, hud in ipairs(hudElements) do
					if (not player:IsCoopGhost() or hud.BypassGhostBaby)
						and hud.Condition(player, playerHUDIndex, hudLayout, conditionParam)
						and ((not hud.PreRenderCallback and not isPreCallback) or (hud.PreRenderCallback and isPreCallback))
					then
						hud.OnRender(player, playerHUDIndex, hudLayout, position, ...)
						HudHelper.LastAppliedHUD[hudType][playerHUDIndex] = hud
					end
				end
			end
		end
	end

	---@param player EntityPlayer
	---@param playerHUDIndex integer
	---@param hudLayout HUDLayout
	---@param pos Vector
	---@param hud HUDInfo
	local function renderBaseHUDs(player, playerHUDIndex, hudLayout, pos, hud)
		hud.OnRender(player, playerHUDIndex, hudLayout, pos)
		HudHelper.LastAppliedHUD[HudHelper.HUDType.BASE][playerHUDIndex] = hud
	end

	---@param player EntityPlayer
	---@param playerHUDIndex integer
	---@param hudLayout HUDLayout
	---@param hud HUDInfo_Active | HUDInfo_ActiveID
	local function renderActiveHUDs(player, playerHUDIndex, hudLayout, pos, hud, i, isItem)
		if REPENTOGON then return end
		for slot = ActiveSlot.SLOT_POCKET, ActiveSlot.SLOT_PRIMARY, -1 do
			local cornerHUD = min(4, playerHUDIndex)
			if slot == ActiveSlot.SLOT_POCKET
				and playerHUDIndex == 1
				and hudLayout == HudHelper.HUDLayout.P1
			then
				cornerHUD = 4
			end

			local scale = 1
			local alpha = 1

			if hudLayout == HudHelper.HUDLayout.P1_MAIN_TWIN
				or hudLayout == HudHelper.HUDLayout.P1_OTHER_TWIN
				or hudLayout == HudHelper.HUDLayout.TWIN_COOP
			then
				if hudLayout == HudHelper.HUDLayout.TWIN_COOP then
					if slot == ActiveSlot.SLOT_SECONDARY then
						scale = 0.245
					else
						scale = 0.5
					end
				else
					if slot == ActiveSlot.SLOT_SECONDARY then
						scale = 0.5
					end
				end
				local dropTrigger = not game:IsPaused()
					and player.ControlsEnabled
					and Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex)
				if Options.JacobEsauControls and Options.JacobEsauControls == 1 then
					if hudLayout == HudHelper.HUDLayout.TWIN_COOP then
						alpha = (i == 1) and 1 or 0.25
					else
						alpha = (i == 1) and 0.25 or 1
					end

					if dropTrigger then
						alpha = i == 1 and 0.25 or 1
					end
				elseif not Options.JacobEsauControls or Options.JacobEsauControls == 0 then
					alpha = slot < ActiveSlot.SLOT_POCKET and 1 or 0.25
					if dropTrigger then
						alpha = slot < ActiveSlot.SLOT_POCKET and 0.25 or 1
					end
				end
			elseif slot == ActiveSlot.SLOT_SECONDARY
				or slot == ActiveSlot.SLOT_POCKET and (condensedCoopHUD or playerHUDIndex ~= 1)
			then
				scale = 0.5
			end
			if game:GetLevel():GetCurrentRoomDesc().Flags & RoomDescriptor.FLAG_CURSED_MIST == RoomDescriptor.FLAG_CURSED_MIST then
				alpha = 0.5
			end
			local activePos, itemPos = HudHelper.GetActiveHUDOffset(player, playerHUDIndex, slot, scale, true)
			local pos = HudHelper.GetHUDPosition(cornerHUD) + activePos
			if i == 2 then
				pos = pos + TWIN_COOP_OFFSET
			end

			local itemID = player:GetActiveItem(slot)

			if isItem
				and itemID == hud.ItemID
				and HudHelper.ShouldActiveBeDisplayed(player, itemID, slot)
				and (not hud.Condition or hud.Condition(player, playerHUDIndex, hudLayout))
			then
				---@cast hud HUDInfo_ActiveID
				hud.OnRender(player, playerHUDIndex, hudLayout, pos + itemPos, alpha, scale, itemID, slot)
				HudHelper.LastAppliedHUD[HudHelper.HUDType.ACTIVE_ID][playerHUDIndex] = hud
			elseif not isItem
				and hud.Condition(player, playerHUDIndex, hudLayout, slot)
			then
				local bookOffset = slot == ActiveSlot.SLOT_PRIMARY and getBookOffset(player) or Vector.Zero
				if bookOffset.Y ~= 0 then
					bookOffset = bookOffset + Vector(0, 1)
				end
				local chargebarPos = pos + HudHelper.GetActiveChargeBarHUDOffset(slot, scale, hudLayout) - bookOffset
				---@cast hud HUDInfo_Active
				hud.OnRender(player, playerHUDIndex, hudLayout, pos + itemPos, alpha, scale, slot, chargebarPos)
				HudHelper.LastAppliedHUD[HudHelper.HUDType.ACTIVE][playerHUDIndex] = hud
			end
		end
	end

	---@param player EntityPlayer
	---@param slot ActiveSlot
	---@param offset Vector
	---@param alpha number
	---@param scale number
	---@param isPreCallback boolean
	local function renderActiveHUDs_REPENTOGON(_, player, slot, offset, alpha, scale, chargebarOffset, isPreCallback)
		if not player:Exists()
			or player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_NULL
			or HudHelper.ShouldHideHUD()
			or player.Variant ~= 0
			or not HudHelper.HUDPlayers[1]
			or not HudHelper.HUDPlayers[1][1]
			or not tryGetPlayerFromPtr(HudHelper.HUDPlayers[1][1])
		then
			return
		end
		local playerHUDIndex = HudHelper.Utils.GetHUDPlayerNumberIndex(player)
		if playerHUDIndex == -1 then return end
		local hudLayout = HudHelper.Utils.GetHUDLayout(playerHUDIndex)

		offset = offset + HudHelper.GetItemSpecificOffset(player:GetActiveItem(slot), slot == ActiveSlot.SLOT_PRIMARY and (getBookOffset(player).Y ~= 0), hudLayout == HudHelper.HUDLayout.TWIN_COOP) * scale

		for _, hud in ipairs(HUD_ELEMENTS[HudHelper.HUDType.ACTIVE]) do
			if (not player:IsCoopGhost() or hud.BypassGhostBaby)
				and hud.Condition(player, playerHUDIndex, hudLayout, slot)
				and ((not hud.PreRenderCallback and not isPreCallback) or (hud.PreRenderCallback and isPreCallback))
			then
				hud.OnRender(player, playerHUDIndex, hudLayout, offset, alpha, scale, slot, chargebarOffset)
				HudHelper.LastAppliedHUD[HudHelper.HUDType.ACTIVE][playerHUDIndex] = hud
			end
		end
		local itemID = player:GetActiveItem(slot)
		if HudHelper.ShouldActiveBeDisplayed(player, itemID, slot) then
			local hud = HUD_ELEMENTS[HudHelper.HUDType.ACTIVE_ID][itemID]
			if hud
				and (not player:IsCoopGhost() or hud.BypassGhostBaby)
				and ((not hud.PreRenderCallback and not isPreCallback) or (hud.PreRenderCallback and isPreCallback))
				and (not hud.Condition or hud.Condition(player, playerHUDIndex, hudLayout))
			then
				hud.OnRender(player, playerHUDIndex, hudLayout, offset, alpha, scale, itemID, slot)
				HudHelper.LastAppliedHUD[HudHelper.HUDType.ACTIVE_ID][playerHUDIndex] = hud
			end
		end
	end

	---@param player EntityPlayer
	---@param playerHUDIndex integer
	---@param hudLayout HUDLayout
	---@param pos Vector
	---@param hud HUDInfo_Health
	local function renderHeartHUDs(player, playerHUDIndex, hudLayout, pos, hud, mainPlayer)
		if REPENTOGON then return end
		local maxColumns = HudHelper.Utils.GetMaxHeartColumns(hudLayout)
		local alpha = HudHelper.Utils.CheckFadedHealth(player) and 0.3 or 1
		hud.OnRender(player, playerHUDIndex, hudLayout, pos, maxColumns, alpha, mainPlayer)
		HudHelper.LastAppliedHUD[HudHelper.HUDType.HEALTH][playerHUDIndex] = hud
	end

	---@param offset Vector
	---@param sprite Sprite
	---@param pos Vector
	---@param unkFloat number
	---@param player EntityPlayer
	---@param isPreCallback boolean
	local function renderHeartHUDs_REPENTOGON(_, offset, sprite, pos, unkFloat, player, isPreCallback, dontLoop, mainPlayer)
		if HudHelper.ShouldHideHUD()
			or player.Variant ~= 0
			or not HudHelper.HUDPlayers[1]
			or not HudHelper.HUDPlayers[1][1]
			or not tryGetPlayerFromPtr(HudHelper.HUDPlayers[1][1])
		then
			return
		end

		local alpha = HudHelper.Utils.CheckFadedHealth(player) and 0.3 or 1
		local playerHUDIndex = HudHelper.Utils.GetHUDPlayerNumberIndex(player)
		local hudLayout = playerHUDIndex == -1 and HudHelper.HUDLayout.STRAWMAN_HEARTS or
			HudHelper.Utils.GetHUDLayout(playerHUDIndex)

		local maxColumns = HudHelper.Utils.GetMaxHeartColumns(hudLayout)
		for _, hud in ipairs(HUD_ELEMENTS[HudHelper.HUDType.HEALTH]) do
			if (not player:IsCoopGhost() or hud.BypassGhostBaby)
				and hud.Condition(player, playerHUDIndex, hudLayout, mainPlayer)
				and ((not hud.PreRenderCallback and not isPreCallback) or (hud.PreRenderCallback and isPreCallback))
			then
				hud.OnRender(player, playerHUDIndex, hudLayout, pos, maxColumns, alpha, mainPlayer)
				HudHelper.LastAppliedHUD[HudHelper.HUDType.HEALTH][playerHUDIndex] = hud
			end
		end
		if player:GetSubPlayer() and not dontLoop then
			renderHeartHUDs_REPENTOGON(_, offset, sprite, pos + Vector(0, 10), unkFloat, player:GetSubPlayer(), isPreCallback, true, player)
		end
	end

	---@param player EntityPlayer
	---@param playerHUDIndex integer
	---@param hudLayout HUDLayout
	---@param pos Vector
	---@param hud HUDInfo_Pocket | HUDInfo_CardID | HUDInfo_PillID
	local function renderPocketItemHUDs(player, playerHUDIndex, hudLayout, pos, hud, i, isCard, isPill)
		local scale = 1
		local alpha = 1

		if hudLayout == HudHelper.HUDLayout.P1 and not condensedCoopHUD then
			pos = HudHelper.GetHUDPosition(4)
		end
		if i == 2 then
			pos = pos + TWIN_COOP_OFFSET
		end
		pos = pos + HudHelper.GetPocketHUDOffset(player)

		if hudLayout == HudHelper.HUDLayout.P1_MAIN_TWIN
			or hudLayout == HudHelper.HUDLayout.P1_OTHER_TWIN
			or hudLayout == HudHelper.HUDLayout.TWIN_COOP
		then
			if REPENTANCE_PLUS then
				scale = 0.5
			end
			local dropTrigger = not game:IsPaused()
				and player.ControlsEnabled
				and Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex)
			if Options.JacobEsauControls and Options.JacobEsauControls == 1 then
				alpha = i == 1 and 1 or 0.25
				if dropTrigger then
					alpha = i == 1 and 0.25 or 1
				end
			elseif not Options.JacobEsauControls or Options.JacobEsauControls == 0 then
				alpha = 0.25
				if dropTrigger then
					alpha = 1
				end
			end
		elseif condensedCoopHUD or playerHUDIndex ~= 1 then
			scale = 0.5
		end

		if isCard and player:GetCard(0) == hud.ItemID then
			hud.OnRender(player, playerHUDIndex, hudLayout, pos, alpha, scale)
			HudHelper.LastAppliedHUD[HudHelper.HUDType.CARD_ID][playerHUDIndex] = hud
		elseif isPill and player:GetPill(0) == hud.ItemID then
			hud.OnRender(player, playerHUDIndex, hudLayout, pos, alpha, scale)
			HudHelper.LastAppliedHUD[HudHelper.HUDType.PILL_ID][playerHUDIndex] = hud
		else
			hud.OnRender(player, playerHUDIndex, hudLayout, pos, alpha, scale)
			HudHelper.LastAppliedHUD[HudHelper.HUDType.POCKET][playerHUDIndex] = hud
		end
	end

	---@param player EntityPlayer
	---@param playerHUDIndex integer
	---@param hudLayout HUDLayout
	---@param pos Vector
	---@param hud HUDInfo_Trinket | HUDInfo_TrinketID
	local function renderTrinketHUDs(player, playerHUDIndex, hudLayout, pos, hud, i, isItem)
		local cornerHUD = min(4, playerHUDIndex)
		if hudLayout == HudHelper.HUDLayout.P1 or (hudLayout == HudHelper.HUDLayout.P1_MAIN_TWIN and not REPENTANCE_PLUS) then
			cornerHUD = 3
		end
		local scale = 1
		for slot = 0, 1 do
			pos = HudHelper.GetHUDPosition(cornerHUD) + HudHelper.GetTrinketHUDOffset(player, slot)
			if i == 2 then
				pos = pos + TWIN_COOP_OFFSET
			end
			if hudLayout == HudHelper.HUDLayout.COOP
				or (REPENTANCE_PLUS and hudLayout ~= HudHelper.HUDLayout.P1)
			then
				scale = 0.5
			end
			local trinketID = player:GetTrinket(slot)
			if isItem
				and hud.ItemID == trinketID & ~TrinketType.TRINKET_GOLDEN_FLAG
				and (not hud.Condition or hud.Condition(player, playerHUDIndex, hudLayout))
			then
				---@cast hud HUDInfo_TrinketID
				hud.OnRender(player, playerHUDIndex, hudLayout, pos, 1, scale, trinketID, slot)
				HudHelper.LastAppliedHUD[HudHelper.HUDType.TRINKET_ID][playerHUDIndex] = hud
			elseif not isItem
				and hud.Condition(player, playerHUDIndex, hudLayout, slot)
			then
				---@cast hud HUDInfo_Trinket
				hud.OnRender(player, playerHUDIndex, hudLayout, pos, scale, slot)
				HudHelper.LastAppliedHUD[HudHelper.HUDType.TRINKET][playerHUDIndex] = hud
			end
		end
	end

	local extraYPadding = 0

	---@param player EntityPlayer
	---@param playerHUDIndex integer
	---@param hudLayout HUDLayout
	---@param pos Vector
	---@param hud HUDInfo_Extra
	local function renderExtraHUDs(player, playerHUDIndex, hudLayout, pos, hud)
		pos = pos + Vector(0, extraYPadding)
		local customPadding = HudHelper.GetExtraHUDPadding(player, hud)
		hud.OnRender(player, playerHUDIndex, hudLayout, pos + Vector(customPadding.X, 0))
		HudHelper.LastAppliedHUD[HudHelper.HUDType.EXTRA][playerHUDIndex] = hud
		extraYPadding = extraYPadding + customPadding.Y
	end

	function HudHelper.PopulateHUDPlayers()
		HudHelper.HUDPlayers = {}
		local numHUDPlayers = 0
		condensedCoopHUD = false

		if REPENTANCE_PLUS then
			for playerIndex = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(playerIndex)
				if player
					and not player.Parent
					and not HudHelper.HUDTwinBlacklist[player:GetPlayerType()]
					and GetPtrHash(player:GetMainTwin()) == GetPtrHash(player)
				then
					numHUDPlayers = numHUDPlayers + 1

					if numHUDPlayers > 1 then
						if canAddTwinHUD(player) then
							numHUDPlayers = numHUDPlayers + 1
						end
						if numHUDPlayers >= 3 then
							condensedCoopHUD = true
						end
					end
				end
			end
		end
		for playerIndex = 0, game:GetNumPlayers() - 1 do
			addActivePlayers(playerIndex)
			numPlayers = game:GetNumPlayers()
		end
	end

	---@param player EntityPlayer
	---@param isPreCallback boolean
	function HudHelper.RenderStrawmenHealth(player, isPreCallback)
		for _, hud in ipairs(HudHelper.HUD_ELEMENTS[HudHelper.HUDType.HEALTH]) do
			if hud.Condition(player, -1, HudHelper.HUDLayout.STRAWMAN_HEARTS)
				and ((not hud.PreRenderCallback and not isPreCallback) or (hud.PreRenderCallback and isPreCallback))
			then
				---@cast hud HUDInfo_Health
				local position = HudHelper.GetStrawmanHealthHUDOffset(player)
				renderHeartHUDs(player, -1, HudHelper.HUDLayout.STRAWMAN_HEARTS, position, hud)
			end
		end
	end

	--Unused. Is mostly done, but the cutoff for when items stop rendering I don't know how to figure out.
	function HudHelper.RenderExtraItemHUDTrinkets(isPreCallback)
		local player = Isaac.GetPlayer()
		local posIndex = 0
		local columns = Options.ExtraHUDStyle * 2
		local maxInventory = Options.ExtraHUDStyle * 5 * columns
		local scale = Options.ExtraHUDStyle == 1 and 1 or 0.5
		local extraHUDOffset = HudHelper.GetExtraItemHUDOffset()
		local alpha = 0.5
		for trinketID, hud in pairs(HudHelper.HUD_ELEMENTS[HudHelper.HUDType.TRINKET_ID]) do
			if player:HasTrinket(trinketID) then
				local collectiblesHistory = player:GetHistory():GetCollectiblesHistory()
				for i = #collectiblesHistory, 1, -1 do
					local historyItem = collectiblesHistory[i]
					if historyItem:IsTrinket() or itemConfig:GetCollectible(historyItem:GetItemID()).Type ~= ItemType.ITEM_ACTIVE then
						posIndex = posIndex + 1
					end
					if posIndex > maxInventory then return end
					if historyItem:IsTrinket() and (historyItem:GetItemID() & ~TrinketType.TRINKET_GOLDEN_FLAG) == trinketID
						and (not player:IsCoopGhost() or hud.BypassGhostBaby)
						and ((not hud.PreRenderCallback and not isPreCallback) or (hud.PreRenderCallback and isPreCallback))
					then
						local xPos = (32 * scale) * ((posIndex - 1) % columns)
						local yPos = (32 * scale) * (ceil(posIndex / columns) - 1)
						local offset = Vector(xPos, yPos)

						local position = HudHelper.GetHUDPosition(2) + extraHUDOffset + offset

						hud.OnRender(player, 1, HudHelper.Utils.GetHUDLayout(1), position, scale, alpha, historyItem:GetItemID())
					end
				end
			end
		end
	end

	function HudHelper.RenderHUDs(isPreCallback)
		if HudHelper.ShouldHideHUD() then
			return
		end

		if not HudHelper.HUDPlayers[1]
			or not HudHelper.HUDPlayers[1][1]
			or tryGetPlayerFromPtr(HudHelper.HUDPlayers[1][1]) == nil
			or numPlayers ~= game:GetNumPlayers()
		then
			HudHelper.PopulateHUDPlayers()
		end
		for playerHUDIndex, hudPlayer in pairs(HudHelper.HUDPlayers) do
			for i, entityPtr in pairs(hudPlayer) do
				local player = tryGetPlayerFromPtr(entityPtr)
				if not player then goto continue end
				local hudLayout = HudHelper.Utils.GetHUDLayout(playerHUDIndex)

				for hudType, hudTable in pairs(HudHelper.HUD_ELEMENTS) do
					extraYPadding = 0
					---Separated as these are indexed uniquely by itemIDs instead of a priority order
					if not isItemIDType[hudType] then
						for _, hud in ipairs(hudTable) do
							if not ((not player:IsCoopGhost() or hud.BypassGhostBaby)
									and (hudType == HudHelper.HUDType.ACTIVE
										or hudType == HudHelper.HUDType.TRINKET
										or hud.Condition(player, playerHUDIndex, hudLayout))
									and ((not hud.PreRenderCallback and not isPreCallback) or (hud.PreRenderCallback and isPreCallback))
								) then
								goto continue2
							end
							local pos = HudHelper.GetHUDPosition(playerHUDIndex)
							if i == 2 then
								pos = pos + TWIN_COOP_OFFSET
							end
							if hudType == HudHelper.HUDType.BASE and i ~= 2 then
								---@cast hud HUDInfo
								renderBaseHUDs(player, playerHUDIndex, hudLayout, pos, hud)
							elseif hudType == HudHelper.HUDType.ACTIVE then
								---@cast hud HUDInfo_Active
								renderActiveHUDs(player, playerHUDIndex, hudLayout, pos, hud, i, false)
							elseif hudType == HudHelper.HUDType.HEALTH then
								---@cast hud HUDInfo_Health
								pos = pos + HudHelper.GetHealthHUDOffset(playerHUDIndex)
								if i == 2 then
									--WHYYYYY ARE HEARTS NOT OFFSET THE SAME AMOUNT AS ACTIVES WHYYYYYY
									pos = pos + Vector(0, 2)
								end
								renderHeartHUDs(player, playerHUDIndex, hudLayout, pos, hud)
								if player:GetSubPlayer() and hud.Condition(player:GetSubPlayer(), playerHUDIndex, hudLayout, player) then
									renderHeartHUDs(player:GetSubPlayer(), playerHUDIndex, hudLayout, pos + Vector(0, 10), hud, player)
								end
							elseif hudType == HudHelper.HUDType.POCKET then
								---@cast hud HUDInfo_Pocket
								renderPocketItemHUDs(player, playerHUDIndex, hudLayout, pos, hud, i)
							elseif hudType == HudHelper.HUDType.TRINKET then
								---@cast hud HUDInfo_Trinket
								renderTrinketHUDs(player, playerHUDIndex, hudLayout, pos, hud, i, false)
							elseif hudType == HudHelper.HUDType.EXTRA then
								pos = pos + HudHelper.GetExtraHUDOffset(playerHUDIndex)
								---@cast hud HUDInfo_Extra
								renderExtraHUDs(player, playerHUDIndex, hudLayout, pos, hud)
							end
							::continue2::
						end
					else
						for _, hud in pairs(hudTable) do
							if not ((not player:IsCoopGhost() or hud.BypassGhostBaby)
									and ((not hud.PreRenderCallback and not isPreCallback) or (hud.PreRenderCallback and isPreCallback))
								) then
								goto continue2
							end
							local pos = HudHelper.GetHUDPosition(playerHUDIndex)
							if i == 2 then
								pos = pos + TWIN_COOP_OFFSET
							end
							if hudType == HudHelper.HUDType.ACTIVE_ID then
								---@cast hud HUDInfo_ActiveID
								renderActiveHUDs(player, playerHUDIndex, hudLayout, pos, hud, i, true)
							elseif hudType == HudHelper.HUDType.TRINKET_ID then
								---@cast hud HUDInfo_TrinketID
								renderTrinketHUDs(player, playerHUDIndex, hudLayout, pos, hud, i, true)
							elseif (hudType == HudHelper.HUDType.CARD_ID or hudType == HudHelper.HUDType.PILL_ID)
								and (not hud.Condition or hud.Condition(player, playerHUDIndex, hudLayout))
							then
								---@cast hud HUDInfo_CardID | HUDInfo_PillID
								renderPocketItemHUDs(player, playerHUDIndex, hudLayout, pos, hud, i, hudType == HudHelper.HUDType.CARD_ID, hudType == HudHelper.HUDType.PILL_ID)
							end
							::continue2::
						end
					end
				end

				::continue::
			end
		end
		if #HudHelper.HUD_ELEMENTS[HudHelper.HUDType.HEALTH] ~= 0 and not REPENTOGON then
			for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
				local player = ent:ToPlayer()
				if player and player.Parent and not player:IsDead() and player.Variant == 0 then
					HudHelper.RenderStrawmenHealth(player, isPreCallback)
				end
			end
		end
		if Options.ExtraHUDStyle > 0 then
			--HudHelper.RenderExtraItemHUDTrinkets(isPreCallback)
		end
	end

	-- Unregister previous callbacks
	for callback, funcs in pairs(HudHelper.AddedCallbacks) do
		for i = 1, #funcs do
			HudHelper:RemoveCallback(callback, funcs[i])
		end
	end

	local function preRenderHeartHUDs_REPENTOGON(_, offset, sprite, pos, unkFloat, player)
		renderHeartHUDs_REPENTOGON(_, offset, sprite, pos, unkFloat, player, true)
	end

	local function postRenderHeartHUDs_REPENTOGON(_, offset, sprite, pos, unkFloat, player)
		renderHeartHUDs_REPENTOGON(_, offset, sprite, pos, unkFloat, player, false)
	end

	local function preRenderActiveHUDs_REPENTOGON(_, player, slot, offset, alpha, scale, chargebarOffset)
		renderActiveHUDs_REPENTOGON(_, player, slot, offset, alpha, scale, chargebarOffset, true)
	end

	local function postRenderActiveHUDs_REPENTOGON(_, player, slot, offset, alpha, scale, chargebarOffset)
		renderActiveHUDs_REPENTOGON(_, player, slot, offset, alpha, scale, chargebarOffset, false)
	end

	local function preRenderHUDs()
		HudHelper.RenderHUDs(true)
	end

	local function postRenderHUDs()
		HudHelper.RenderHUDs(false)
	end

	local function updateGoldenItemHUD()
		if not REPENTOGON and Isaac.GetFrameCount() % 2 == 0 and not game:IsPaused() then
			goldenHUDSprite:Update()
		end
	end

	local function resetHUDPlayersOnLazBBirthrightFlip(_, _, _, player)
		local playerType = player:GetPlayerType()
		if (playerType == PlayerType.PLAYER_LAZARUS_B
				or playerType == PlayerType.PLAYER_LAZARUS2_B)
			and player:GetOtherTwin()
		then
			HudHelper.PopulateHUDPlayers()
		end
	end

	local function postModsLoaded()
		if HudHelper.LoadedPatches then return end
		HudHelper.LoadedPatches = true

		if EID then
			--EID support. Adds a custom position modifier to work with other HUD elements registered under HudHelper
			--If any elements are active, gets rid of EID's own position modifiers as HudHelper already accounts for them
			--If none are active, removes the modifier
			HudHelper.RegisterHUDElement({
				Name = "Reset EID",
				Priority = HudHelper.Priority.EID,
				XPadding = 0,
				YPadding = 0,
				Condition = function(player, playerHUDIndex)
					return game:GetFrameCount() > 0
						and playerHUDIndex == 1
						and (not HudHelper.LastAppliedHUD[HudHelper.HUDType.EXTRA][1]
							or HudHelper.LastAppliedHUD[HudHelper.HUDType.EXTRA][1].Name == "EID"
							or HudHelper.LastAppliedHUD[HudHelper.HUDType.EXTRA][1].Priority == HudHelper.Priority.VANILLA
						)
						and EID.PositionModifiers["HudHelper"]
				end,
				OnRender = function()
					EID:removeTextPosModifier("HudHelper")
				end
			}, HudHelper.HUDType.EXTRA)

			HudHelper.RegisterHUDElement({
				Name = "EID",
				Priority = HudHelper.Priority.EID,
				XPadding = 0,
				YPadding = 0,
				Condition = function(player, playerHUDIndex)
					return EID.isDisplaying
						and playerHUDIndex == 1
						and HudHelper.LastAppliedHUD[HudHelper.HUDType.EXTRA][1]
						and HudHelper.LastAppliedHUD[HudHelper.HUDType.EXTRA][1].Name ~= "Reset EID"
						and HudHelper.LastAppliedHUD[HudHelper.HUDType.EXTRA][1].Priority ~= HudHelper.Priority.VANILLA
				end,
				OnRender = function(_, _, _, position)
					local posYModifier = 0
					local offset = -40
					local vanillaOffsets = {
						"Tainted HUD",
						"J&E HUD",
						"18 Heart HUD",
						"24 Heart HUD"
					}
					for _, offsetName in ipairs(vanillaOffsets) do
						if EID.PositionModifiers[offsetName] then
							offset = offset - EID.PositionModifiers[offsetName].Y
						end
					end

					posYModifier = position.Y + offset

					EID:addTextPosModifier(
						"HudHelper",
						Vector(0, max(0, posYModifier))
					)
				end
			}, HudHelper.HUDType.EXTRA)
		end

		if REVEL then
			HudHelper.RegisterHUDElement({
				Name = "Revelations Vanity",
				Priority = HudHelper.Priority.MOD_PATCH,
				XPadding = 0,
				YPadding = 6,
				Condition = function (player, playerHUDIndex, hudLayout)
						return REVEL.ShouldRenderHudElements()
							and REVEL.GetShrineVanity() > 0
							and playerHUDIndex == 1
					end,
				OnRender = function ()
					if EID.PositionModifiers["rev-pact-vanity"] then
						EID:removeTextPosModifier("rev-pact-vanity")
					end
				end
			}, HudHelper.HUDType.EXTRA)
		end

		if Martha then
			HudHelper.RegisterHUDElement({
				Name = "Martha Hope",
				Priority = HudHelper.Priority.MOD_PATCH,
				XPadding = 0,
				YPadding = 6,
				Condition = function (player, playerHUDIndex, hudLayout)
						return player:GetPlayerType() == Isaac.GetPlayerTypeByName("Martha", false)
							and playerHUDIndex == 1
					end,
				OnRender = function ()
				end
			}, HudHelper.HUDType.EXTRA)
		end
	end

	function HudHelper.ReloadPatches()
		HudHelper.LoadedPatches = false
		postModsLoaded()
	end

	local function AddPriorityCallback(callback, priority, func, arg)
		HudHelper:AddPriorityCallback(callback, priority, func, arg)

		if not HudHelper.AddedCallbacks[callback] then
			HudHelper.AddedCallbacks[callback] = {}
		end
		table.insert(HudHelper.AddedCallbacks[callback], func)
	end

	local function AddCallback(callback, func, arg)
		AddPriorityCallback(callback, CallbackPriority.DEFAULT, func, arg)
	end

	-- Register new callbacks
	if REPENTOGON then
		AddCallback(ModCallbacks.MC_POST_HUD_RENDER, postRenderHUDs)
		AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, preRenderActiveHUDs_REPENTOGON)
		AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, postRenderActiveHUDs_REPENTOGON)
		AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_HEARTS, preRenderHeartHUDs_REPENTOGON)
		AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_HEARTS, postRenderHeartHUDs_REPENTOGON)
		AddCallback(ModCallbacks.MC_POST_MODS_LOADED, postModsLoaded)
	else
		local function getShaderParams(_, name)
			if name == emptyShaderName then
				postRenderHUDs()
			end
		end
		AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, getShaderParams)
		AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postModsLoaded)
	end

	AddPriorityCallback(ModCallbacks.MC_POST_RENDER, CallbackPriority.LATE, preRenderHUDs)
	AddCallback(ModCallbacks.MC_POST_RENDER, updateGoldenItemHUD)
	AddCallback(ModCallbacks.MC_USE_ITEM, resetHUDPlayersOnLazBBirthrightFlip, CollectibleType.COLLECTIBLE_FLIP)

	--#endregion

	--Register HUD elements. Previous versions of these get overwritten.
	HudHelper.RegisterHUDElement({
		Name = "Heart Cap",
		Priority = HudHelper.Priority.VANILLA - 1,
		XPadding = 0,
		YPadding = function(player, playerHUDIndex, hudLayout)
			local heartPerRow = HudHelper.Utils.GetMaxHeartColumns(hudLayout) * 2
			local startAt = (heartPerRow == 12) and 5 or -15
			local taintedOffsets = 0

			--condensedCoopHUD
			if REPENTANCE_PLUS and hudLayout == HudHelper.HUDLayout.COOP then
				startAt = startAt - 11
			end

			for _, hud in ipairs(HudHelper.HUD_ELEMENTS[HudHelper.HUDType.EXTRA]) do
				if hud.Priority >= HudHelper.Priority.HIGHEST then
					break
				end

				if hud.Name == "Tainted Blue Baby" or hud.Name == "Tainted Isaac" then
					if hud.Condition(player, playerHUDIndex, hudLayout) then
						taintedOffsets = taintedOffsets + processFuncOrValue(hud.YPadding, player, playerHUDIndex, hudLayout) + 5

						if startAt == -6 then
							taintedOffsets = taintedOffsets + 6
						end

						break
					end
				end
			end

			local rows = HudHelper.Utils.GetCurrentMaxHeartRows(player)

			---@diagnostic disable-next-line: undefined-global
			if not (NoHealthCapModEnabled or CustomHealthAPI) then
				rows = min(48 / heartPerRow, rows) --Hearts literally stop rendering after 4 rows legitimately
			end

			return max(-6, startAt + (rows - 3) * 10 - taintedOffsets)
		end,
		Condition = function(player, playerHUDIndex)
			if playerHUDIndex > 2 or game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN == LevelCurse.CURSE_OF_THE_UNKNOWN then
				return false
			end

			return HudHelper.Utils.GetEffectiveMaxHealth(player) > 24
		end,
		OnRender = function() end, -- handled by the game
	}, HudHelper.HUDType.EXTRA)
	HudHelper.RegisterHUDElement({
		Name = "Tainted Isaac",
		Priority = HudHelper.Priority.VANILLA,
		XPadding = 0,
		YPadding = 20,
		Condition = function(player, playerHUDIndex)
			return player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B
				and (REPENTANCE_PLUS and playerHUDIndex <= 2 or playerHUDIndex == 1)
		end,
		OnRender = function() end, -- handled by the game
	}, HudHelper.HUDType.EXTRA)
	HudHelper.RegisterHUDElement({
		Name = "Tainted Blue Baby",
		Priority = HudHelper.Priority.VANILLA,
		XPadding = 0,
		YPadding = 17,
		Condition = function(player, playerHUDIndex)
			return player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B
				and (REPENTANCE_PLUS and playerHUDIndex <= 2 or playerHUDIndex == 1)
		end,
		OnRender = function() end, -- handled by the game
	}, HudHelper.HUDType.EXTRA)

	if REPENTANCE_PLUS then
		HudHelper.RegisterHUDElement({
			Name = "Bag of Crafting",
			Priority = HudHelper.Priority.VANILLA,
			XPadding = 0,
			YPadding = 7,
			Condition = function(player, playerHUDIndex, hudLayout)
				return player:GetActiveItem(ActiveSlot.SLOT_POCKET) == CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING
					and hudLayout == HudHelper.HUDLayout.COOP and playerHUDIndex <= 2
			end,
			OnRender = function() end, -- handled by the game
		}, HudHelper.HUDType.EXTRA)
	end

	HudHelper.RegisterHUDElement({
		Name = "P1 Main Twin",
		Priority = HudHelper.Priority.VANILLA,
		XPadding = 0,
		YPadding = 16,
		Condition = function(_, _, hudLayout)
			return hudLayout == HudHelper.P1_MAIN_TWIN
		end,
		OnRender = function() end, -- handled by the game
	}, HudHelper.HUDType.EXTRA)
end

if HudHelper then
	if HudHelper.Version > VERSION and not FORCE_VERSION_UPDATE then
		return
	end

	CACHED_CALLBACKS = HudHelper.Callbacks.RegisteredCallbacks
	CACHED_ELEMENTS = HudHelper.HUD_ELEMENTS
	CACHED_MOD_CALLBACKS = HudHelper.AddedCallbacks
end

HudHelper = InitMod()
InitFunctions()
