--[[
    Jump Library by Kerkel
    Version 1.3.6
    Direct issues and requests to the dedicated resources post in https://discord.gg/modding-of-isaac-962027940131008653
    GitHub repository: https://github.com/drpandacat/JumpLib/
    GitBook documentation: https://kerkeland.gitbook.io/jumplib
]]

---@diagnostic disable: undefined-global, undefined-field

---@class JumpData
---@field Jumping boolean
---@field Tags table
---@field Height number
---@field StaticHeightIncrease number
---@field StaticJumpSpeed number
---@field Fallspeed number
---@field StoredEntityColl EntityCollisionClass
---@field StoredGridColl GridCollisionClass
---@field Flags integer

---@class JumpConfig
---@field Height number
---@field Speed number | nil
---@field Flags integer | nil
---@field Tags string | string[] | nil

---@class PassedJumpConfig
---@field Height number
---@field Speed number
---@field Flags integer
---@field Tags string[]

---@class InternalJumpData
---@field UpdateFrame integer
---@field Jumping boolean
---@field Tags table
---@field PrevTags table
---@field Height number
---@field StaticHeightIncrease number
---@field StaticJumpSpeed number
---@field Fallspeed number
---@field StoredEntityColl EntityCollisionClass
---@field StoredGridColl GridCollisionClass
---@field ChildStoredEntityColl EntityCollisionClass
---@field ChildStoredGridColl GridCollisionClass
---@field StoredSpriteScale Vector
---@field Flags integer
---@field LaserOffset Vector
---@field Pitfall boolean
---@field PitPos Vector
---@field Config JumpConfig
---@field SetInitialLaserHeight boolean
---@field GridCollToSet GridCollisionClass
---@field EntCollToSet EntityCollisionClass
---@field Familiar Entity
---@field JumpPos Vector

local LOCAL_JUMPLIB = {}

function LOCAL_JUMPLIB.Init()
    local LOCAL_VERSION = 17

    if JumpLib then
        if JumpLib.Version > LOCAL_VERSION then
            return
        end
        JumpLib.Internal:RemoveCallbacks()
    end

    JumpLib = RegisterMod("JumpLib", 1)
    JumpLib.Version = LOCAL_VERSION

    ---@enum JumpCallback
    ---All jump callbacks shared optional parameter table:
    ---
    ---* type = `EntityType`
    ---* variant = `integer`
    ---* subtype = `integer`
    ---* tag = `string`
    ---
    ---Additional params for player callbacks:
    ---
    ---* collectible = `CollectibleType`
    ---* trinket = `TrinketType`
    ---* effect = `CollectibleType`
    ---* player = `PlayerType`
    ---* weapon = `WeaponType` (REPENTOGON-only)
    JumpLib.Callbacks = {
        ---Called before an entity jumps
        ---
        ---Parameters:
        ---* entity - `Entity`
        ---* config - `PassedJumpConfig`
        ---
        ---Returns:
        ---* Return `true` to cancel jump
        ---* Return `JumpConfig` object to override config
        PRE_ENTITY_JUMP = "JUMPLIB_PRE_ENTITY_JUMP",
        ---Called after an entity jumps
        ---
        ---Parameters:
        ---* entity - `Entity`
        ---* config - `PassedJumpConfig`
        POST_ENTITY_JUMP = "JUMPLIB_POST_ENTITY_JUMP",
        ---Called after an entity lands
        ---
        ---Parameters:
        ---* entity - `Entity`
        ---* data - `JumpData`
        ---* pitfall - `boolean`
        ENTITY_LAND = "JUMPLIB_ENTITY_LAND",
        ---Called before a player falls into a pit after jumping
        ---
        ---Parameters:
        ---* player - `EntityPlayer`
        ---* data - `JumpData`
        ---
        ---Returns:
        ---* Return `true` to cancel
        ---* Return `false` to fall into the pit but take no damage
        ---* Return `integer` to override damage
        PRE_PITFALL = "JUMPLIB_PRE_PITFALL",
        ---Called before a player takes damage after falling into a pit
        ---
        ---Parameters:
        ---* player - `EntityPlayer`
        ---* data - `JumpData`
        ---* damage - `integer`
        ---
        ---Returns:
        ---* Return `true` to cancel
        ---* Return `integer` to override damage
        PRE_PITFALL_HURT = "JUMPLIB_PRE_PITFALL_HURT",
        ---Called after a player exits a pit
        ---
        ---Parameters:
        ---* player - `EntityPlayer`
        ---* data - `JumpData`
        PITFALL_EXIT = "JUMPLIB_PITFALL_EXIT",
        ---Called before setting an entity's fallspeed
        ---
        ---Parameters:
        ---* player - `EntityPlayer`
        ---* speed - `number`
        ---* data - `JumpData`
        ---Returns:
        ---* Return `true` to cancel
        ---* Return `number` to multiply provided speed by
        PRE_ENTITY_SET_FALLSPEED = "JUMPLIB_PRE_ENTITY_SET_FALLSPEED",
        ---Called after setting an entity's fallspeed
        ---
        ---Parameters:
        ---* player - `EntityPlayer`
        ---* speed - `number`
        ---* data - `JumpData`
        POST_ENTITY_SET_FALLSPEED = "JUMPLIB_POST_ENTITY_SET_FALLSPEED",
        ---Runs 30 times per second for every entity in the air
        ---
        ---Parameters:
        ---* entity - `Entity`
        ---* data - `JumpData`
        ENTITY_UPDATE_30 = "JUMPLIB_ENTITY_UPDATE_30",
        ---Runs 60 times per second for every entity in the air
        ---
        ---Parameters:
        ---* entity - `Entity`
        ---* data - `JumpData`
        ENTITY_UPDATE_60 = "JUMPLIB_ENTITY_UPDATE_60",
        ---Runs 60 times per second for every entity in the air, before `ENTITY_UPDATE_60`
        ---
        ---Parameters:
        ---* entity - `Entity`
        ---* data - `JumpData`
        ---
        ---Returns:
        ---* Return `true` to cancel the update
        PRE_ENTITY_UPDATE = "JUMPLIB_PRE_ENTITY_UPDATE",
        ---@deprecated
        PRE_PLAYER_JUMP = "JUMPLIB_PRE_PLAYER_JUMP",
        ---@deprecated
        POST_PLAYER_JUMP = "JUMPLIB_POST_PLAYER_JUMP",
        ---@deprecated
        PLAYER_LAND = "JUMPLIB_PLAYER_LAND",
        ---@deprecated
        PRE_PLAYER_SET_FALLSPEED = "JUMPLIB_PRE_PLAYER_SET_FALLSPEED",
        ---@deprecated
        POST_PLAYER_SET_FALLSPEED = "JUMPLIB_POST_PLAYER_SET_FALLSPEED",
        ---@deprecated
        PRE_PLAYER_UPDATE = "JUMPLIB_PRE_PLAYER_UPDATE",
        ---@deprecated
        GET_LASER_CAN_FOLLOW_ENTITY = "JUMPLIB_GET_LASER_CAN_FOLLOW_ENTITY",
        ---@deprecated
        GET_LASER_CAN_FOLLOW_PLAYER = "JUMPLIB_GET_LASER_CAN_FOLLOW_PLAYER",
        ---@deprecated
        PLAYER_UPDATE_30 = "JUMPLIB_PLAYER_UPDATE_30",
        ---@deprecated
        PLAYER_UPDATE_60 = "JUMPLIB_PLAYER_UPDATE_60",
    }

    JumpLib.Flags = {
        ---Player will not fall into pits on landing
        NO_PITFALL = 1 << 0,
        ---Player will not take damage from pitfall
        NO_HURT_PITFALL = 1 << 1,
        ---Player will fall into pits regardless of flight
        IGNORE_FLIGHT = 1 << 2,
        ---Entity will collide with grid entities
        ---
        ---Affects player movement if REPENTOGON is not enabled
        COLLISION_GRID = 1 << 3,
        ---Entity will collide with other entities
        COLLISION_ENTITY = 1 << 4,
        ---`CanJump()` will return `true`
        OVERWRITABLE = 1 << 5,
        ---Knives that follow parent jump will not collide with entities
        KNIFE_DISABLE_ENTCOLL = 1 << 6,
        ---Knives will not follow parent jump
        KNIFE_FOLLOW_CUSTOM = 1 << 7,
        ---Unaffected by PRE_SET_FALLSPEED returns
        IGNORE_FALLSPEED_MODIFIERS = 1 << 8,
        ---Unaffected by `PRE_JUMP` `JumpConfig` returns
        IGNORE_CONFIG_OVERRIDE = 1 << 9,
        ---Lasers will not follow parent
        DISABLE_LASER_FOLLOW = 1 << 10,
        ---Orbitals will follow the player while jumping
        FAMILIAR_FOLLOW_ORBITALS =  1 << 11,
        ---Tear-copying familiars will follow the player while jumping
        FAMILIAR_FOLLOW_TEARCOPYING = 1 << 12,
        ---Lasers will not use default jumping behaviors
        LASER_FOLLOW_CUSTOM = 1 << 14,
        ---Bombs drop as if you were not jumping
        DISABLE_COOL_BOMBS = 1 << 15,
        ---Bombs are unable to be dropped
        DISABLE_BOMB_INPUT = 1 << 16,
        ---Player is unable to shoot
        DISABLE_SHOOTING_INPUT = 1 << 17,
        ---Disables tears and projectiles being spawned at spawner height
        DISABLE_TEARHEIGHT = 1 << 18,
        ---Entity will not collide with walls
        GRIDCOLL_NO_WALLS = 1 << 19,
        ---Damage is not prevented while in the air
        DAMAGE_CUSTOM = 1 << 20,
        ---Following familiars will follow the player while jumping
        FAMILIAR_FOLLOW_FOLLOWERS = 1 << 21,
        ---Player is unable to move
        DISABLE_MOVING_INPUT = 1 << 22,
        ---Player can't use consumables
        DISABLE_PILL_CARD_INPUT = 1 << 23,
        ---Player can't use active item
        DISABLE_ACTIVE_ITEM_INPUT = 1 << 24,

        ---Use `FAMILIAR_FOLLOW_ORBITALS`
        ---@deprecated
        FAMILIAR_FOLLOW_ORBITALS_ONLY =  1 << 11,
        ---Use `FAMILIAR_FOLLOW_TEARCOPYING`
        ---@deprecated
        FAMILIAR_FOLLOW_TEARCOPYING_ONLY = 1 << 12,
        ---Deprecated as familiars no longer follow the player by default
        ---@deprecated
        FAMILIAR_FOLLOW_CUSTOM = 1 << 13,
    }

    ---Combination of:
    ---* `COLLISION_GRID`
    ---* `COLLISION_ENTITY`
    ---* `OVERWRITABLE`
    ---* `DISABLE_COOL_BOMBS`
    ---* `IGNORE_CONFIG_OVERRIDE`
    ---* `DAMAGE_CUSTOM`
    ---* `FAMILIAR_FOLLOW_ORBITALS`
    ---
    ---Useful for small, frequent jumps
    JumpLib.Flags.WALK_PRESET = JumpLib.Flags.COLLISION_GRID
    | JumpLib.Flags.COLLISION_ENTITY
    | JumpLib.Flags.OVERWRITABLE
    | JumpLib.Flags.DISABLE_COOL_BOMBS
    | JumpLib.Flags.IGNORE_CONFIG_OVERRIDE
    | JumpLib.Flags.DAMAGE_CUSTOM
    | JumpLib.Flags.FAMILIAR_FOLLOW_ORBITALS

    JumpLib.Constants = {
        PITFRAME_START = 15,
        PITFRAME_DAMAGE = 20,
        PITFRAME_END = 30,
        HEIGHT_TO_LASER_OFFSET = 1.5525,
        CONFIG_HEIGHT_MULT = 2,
        CONFIG_SPEED_MULT = 0.2,
        FALLSPEED_INCR = 0.2,
        TEAR_HEIGHT_MULT = 3.95
    }

    JumpLib.Internal = {
        ActiveEntities = {},
        CallbackEntries = {},
        PRE_RENDER_CALLBACKS = {
            ModCallbacks.MC_PRE_PLAYER_RENDER,
            ModCallbacks.MC_PRE_TEAR_RENDER,
            ModCallbacks.MC_PRE_FAMILIAR_RENDER,
            ModCallbacks.MC_PRE_BOMB_RENDER,
            ModCallbacks.MC_PRE_PICKUP_RENDER,
            ModCallbacks.MC_PRE_SLOT_RENDER,
            ModCallbacks.MC_PRE_KNIFE_RENDER,
            ModCallbacks.MC_PRE_PROJECTILE_RENDER,
            ModCallbacks.MC_PRE_NPC_RENDER,
            ModCallbacks.MC_PRE_EFFECT_RENDER,
        },
        PLAYER_TO_ENTITY_CALLBACK = {
            ---@diagnostic disable-next-line: deprecated
            [JumpLib.Callbacks.PLAYER_LAND] = JumpLib.Callbacks.ENTITY_LAND,
            ---@diagnostic disable-next-line: deprecated
            [JumpLib.Callbacks.PLAYER_UPDATE_30] = JumpLib.Callbacks.ENTITY_UPDATE_30,
            ---@diagnostic disable-next-line: deprecated
            [JumpLib.Callbacks.PLAYER_UPDATE_60] = JumpLib.Callbacks.ENTITY_UPDATE_60,
            ---@diagnostic disable-next-line: deprecated
            [JumpLib.Callbacks.PRE_PLAYER_JUMP] = JumpLib.Callbacks.PRE_ENTITY_JUMP,
            ---@diagnostic disable-next-line: deprecated
            [JumpLib.Callbacks.PRE_PLAYER_UPDATE] = JumpLib.Callbacks.PRE_ENTITY_UPDATE,
            ---@diagnostic disable-next-line: deprecated
            [JumpLib.Callbacks.PRE_PLAYER_SET_FALLSPEED] = JumpLib.Callbacks.PRE_ENTITY_SET_FALLSPEED,
            ---@diagnostic disable-next-line: deprecated
            [JumpLib.Callbacks.POST_PLAYER_JUMP] = JumpLib.Callbacks.POST_ENTITY_JUMP,
            ---@diagnostic disable-next-line: deprecated
            [JumpLib.Callbacks.POST_PLAYER_SET_FALLSPEED] = JumpLib.Callbacks.POST_ENTITY_SET_FALLSPEED,
        },
        TEAR_COPYING_FAMILIARS = {
            [FamiliarVariant.INCUBUS] = true,
            [FamiliarVariant.TWISTED_BABY] = true,
            [FamiliarVariant.UMBILICAL_BABY] = true,
            [FamiliarVariant.BLOOD_BABY] = true,
            [FamiliarVariant.CAINS_OTHER_EYE] = true,
            [FamiliarVariant.SPRINKLER] = true,
        },
        HOOK_TO_CANCEL = {
            [InputHook.GET_ACTION_VALUE] = 0,
            [InputHook.IS_ACTION_PRESSED] = false,
            [InputHook.IS_ACTION_TRIGGERED] = false,
        },
        SHOOT_ACTIONS = {
            [ButtonAction.ACTION_SHOOTLEFT] = true,
            [ButtonAction.ACTION_SHOOTRIGHT] = true,
            [ButtonAction.ACTION_SHOOTUP] = true,
            [ButtonAction.ACTION_SHOOTDOWN] = true,
        },
        MOVE_ACTIONS = {
            [ButtonAction.ACTION_LEFT] = true,
            [ButtonAction.ACTION_RIGHT] = true,
            [ButtonAction.ACTION_UP] = true,
            [ButtonAction.ACTION_DOWN] = true,
        },
        SchedulerEntries = {},
        Vector = {
            Zero = Vector(0, 0),
            One = Vector(1, 1)
        },

        DOOR_DIRECTION_TO_OFFSET = {
            [Direction.UP] = Vector(0, 40),
            [Direction.RIGHT] = Vector(-40, 0),
            [Direction.DOWN] = Vector(0, -40),
            [Direction.LEFT] = Vector(40, 0),
        },
        GRID_PLAYER_SEARCH_RADIUS = 50,
        ---Non-REPENTOGON
        PLAYER_POSITION_OFFSET_MULT = 1.5,
        WATCHSTATE_TO_TIMESCALE = {
            [0] = 1,
            [1] = 0.8,
            [2] = 1.43
        }
    }

    ---@param callback ModCallbacks | JumpCallback
    ---@param fn function
    ---@param param any
    ---@param priority? CallbackPriority
    local function AddCallback(callback, fn, param, priority)
        table.insert(JumpLib.Internal.CallbackEntries, {
            Callback = callback,
            Function = fn,
            Param = param,
            Priority = priority
        })
    end

    local game = Game()

    ---@param familiar EntityFamiliar
    ---@return boolean
    function JumpLib.Internal:IsOrbital(familiar)
        return familiar.OrbitDistance:Length() > 0.001 and math.abs(familiar.OrbitSpeed) > 0
    end

    ---@param familiar EntityFamiliar
    ---@return boolean
    function JumpLib.Internal:IsFollower(familiar)
        if not familiar.IsFollower then return false end
        if familiar.Player:GetAimDirection():Length() > 0.001 then
            for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.KING_BABY)) do
                local _v = v:ToFamiliar() ---@cast _v EntityFamiliar
                if GetPtrHash(_v.Player) == GetPtrHash(familiar.Player) then
                    return false
                end
            end
        end
        return familiar.IsFollower
    end

    ---@param entity Entity
    ---@return InternalJumpData
    function JumpLib.Internal:GetData(entity)
        local data = entity:GetData()
        data.__JUMPLIB = data.__JUMPLIB or {}
        return data.__JUMPLIB
    end

    function JumpLib.Internal:RemoveCallbacks()
        for _, v in ipairs(JumpLib.Internal.CallbackEntries) do
            JumpLib:RemoveCallback(v.Callback, v.Function)
        end
    end

    ---@deprecated
    function JumpLib.Internal:LaserBehaviorsFromEntity() end

    ---@deprecated
    function JumpLib.Internal:AccessibleFromDoors() end

    ---@param entity Entity
    function JumpLib.Internal:UpdateCollision(entity)
        local data = JumpLib.Internal:GetData(entity)
        local player = entity:ToPlayer()

        if data.Jumping then
            entity.GridCollisionClass = data.GridCollToSet or entity.GridCollisionClass
            entity.EntityCollisionClass = data.EntCollToSet or entity.EntityCollisionClass
        else
            if player then
                player:AddCacheFlags(CacheFlag.CACHE_FLYING)
                player:EvaluateItems()

                player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            else
                entity.GridCollisionClass = data.StoredGridColl or entity.GridCollisionClass
                entity.EntityCollisionClass = data.StoredEntityColl or entity.EntityCollisionClass
            end

            data.StoredGridColl = nil
            data.StoredEntityColl = nil
        end
    end

    ---@param entity Entity
    ---@return EntityPlayer?
    function JumpLib.Internal:GetPlayerFromEntity(entity)
        local thingsToCheck = {entity, entity.SpawnerEntity, entity.Parent}
        local player

        for _, v in pairs(thingsToCheck) do
            if v then
                player = v:ToPlayer() if player then
                    break
                end

                local familiar = v:ToFamiliar() if familiar then
                    player = familiar.Player
                    break
                end
            end
        end

        if player then
            return player
        end
    end

    ---@param entity Entity
    function JumpLib.Internal:RemoveEntity(entity)
        local hash = GetPtrHash(entity)

        for i, v in pairs(JumpLib.Internal.ActiveEntities) do
            if GetPtrHash(v) == hash then
                table.remove(JumpLib.Internal.ActiveEntities, i)
                break
            end
        end
    end

    ---@param fn function
    ---@param delay integer
    ---@param persistent boolean | nil
    function JumpLib.Internal:ScheduleFunction(fn, delay, persistent)
        table.insert(JumpLib.Internal.SchedulerEntries, {
            Frame = game:GetFrameCount(),
            Function = fn,
            Delay = delay,
            Persistent = persistent
        })
    end

    AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function ()
        JumpLib.Internal.SchedulerEntries = {}
    end)

    AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
        local frame = game:GetFrameCount()

        for i = #JumpLib.Internal.SchedulerEntries, 1, -1 do
            local v = JumpLib.Internal.SchedulerEntries[i]
            if v.Frame + v.Delay <= frame then
                v.Function()
                table.remove(JumpLib.Internal.SchedulerEntries, i)
            end
        end
    end)

    AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
        for i, v in ipairs(JumpLib.Internal.SchedulerEntries) do
            if not v.Persistent then
                table.remove(JumpLib.Internal.SchedulerEntries, i)
            end
        end
    end)

    ---@param callback JumpCallback | string
    ---@param entity Entity
    ---@return any[]
    function JumpLib:RunCallbackWithParam(callback, entity, ...)
        local directPlayer = entity:ToPlayer()
        local player = directPlayer or JumpLib.Internal:GetPlayerFromEntity(entity)
        local familiar = entity:ToFamiliar()
        local data = JumpLib.Internal:GetData(entity)
        local returns = {}

        for _, v in ipairs(Isaac.GetCallbacks(callback)) do
            ---@diagnostic disable-next-line: cast-type-mismatch
            local param = v.Param ---@cast param table
            local tbl = type(param) == "table"
            local tags = data.PrevTags or data.Tags

            local isType = not tbl or not param.type or param.type == entity.Type
            local isVariant = not tbl or not param.variant or param.variant == entity.Variant
            local isSubType = not tbl or not param.subtype or param.subtype == entity.SubType
            local hasCollectible = not tbl or not param.collectible or not player or player:HasCollectible(param.collectible)
            local hasTrinket = not tbl or not param.trinket or not player or player:HasTrinket(param.trinket)
            local hasEffect = not tbl or not param.effect or not player or player:GetEffects():HasCollectibleEffect(param.effect)
            local hasTag = not tbl or not param.tag or tags and tags[param.tag]
            local isPlayer = not tbl or not param.player or not player or player:GetPlayerType() == param.player
            local hasWeapon = not tbl or not param.weapon

            if REPENTOGON and not hasWeapon then
                if directPlayer then
                    for i = 0, 4 do
                        local weapon = directPlayer:GetWeapon(i) if weapon and weapon:GetWeaponType() == param.weapon then
                            hasWeapon = true
                            break
                        end
                    end
                elseif familiar then
                    local weapon = familiar:GetWeapon() if weapon and weapon:GetWeaponType() == param.weapon then
                        hasWeapon = true
                    end
                end
            end

            if isType and isVariant and isSubType and hasCollectible and hasTrinket and hasEffect and hasTag and isPlayer and hasWeapon then
                local _return = v.Function(v.Mod, entity, ...)

                if _return then
                    table.insert(returns, _return)
                end
            end
        end

        return returns
    end

    ---@param entity Entity
    function JumpLib:CanJump(entity)
        local jumpData = JumpLib:GetData(entity)

        if jumpData.Flags & JumpLib.Flags.OVERWRITABLE ~= 0 then
            return true
        end

        return not jumpData.Jumping
    end

    ---@param entity Entity
    ---@param config JumpConfig
    ---@param force boolean | nil
    ---@return boolean
    function JumpLib:Jump(entity, config, force)
        config = {
            Height = config.Height,
            Speed = config.Speed or 1,
            Flags = config.Flags or 0,
            Tags = config.Tags or {},
        }

        config.Tags = type(config.Tags) == "string" and {config.Tags} or config.Tags


        local player = entity:ToPlayer()

        local passedConfig = {}

        if config.Flags & JumpLib.Flags.IGNORE_CONFIG_OVERRIDE ~= 0 then
            for k, v in pairs(config) do
                passedConfig[k] = v
            end
        else
            passedConfig = config
        end

        local returns = JumpLib:RunCallbackWithParam(JumpLib.Callbacks.PRE_ENTITY_JUMP, player or entity, passedConfig)

        if not force and (config.Flags & JumpLib.Flags.IGNORE_CONFIG_OVERRIDE == 0) then
            for _, v in ipairs(returns) do
                if v == true then
                    return false
                end
            end
        end

        local data = JumpLib.Internal:GetData(entity)
        local hash = GetPtrHash(entity)

        if not data.Jumping then
            table.insert(JumpLib.Internal.ActiveEntities, entity)
            data.JumpPos = entity.Position
        end

        data.Flags = config.Flags
        data.Jumping = true
        data.Height = data.Height or 0
        data.StaticHeightIncrease = config.Height * JumpLib.Constants.CONFIG_HEIGHT_MULT * config.Speed * JumpLib.Constants.CONFIG_SPEED_MULT
        data.StaticJumpSpeed = config.Speed
        data.Fallspeed = 0
        data.Tags = data.Tags or {}
        data.Config = config

        ---@diagnostic disable-next-line: param-type-mismatch
        for _, v in ipairs(config.Tags) do
            ---@diagnostic disable-next-line: assign-type-mismatch
            data.Tags[v] = true
        end

        if not data.StoredEntityColl and data.Flags & JumpLib.Flags.COLLISION_ENTITY == 0 then
            data.StoredEntityColl = entity.EntityCollisionClass

            if player and data.Flags & JumpLib.Flags.DISABLE_SHOOTING_INPUT == 0 then
                data.EntCollToSet = EntityCollisionClass.ENTCOLL_PLAYERONLY
            else
                data.EntCollToSet = EntityCollisionClass.ENTCOLL_NONE
            end
        end

        if entity.Type ~= EntityType.ENTITY_KNIFE then
            if not data.StoredGridColl and data.Flags & JumpLib.Flags.COLLISION_GRID == 0 then
                data.StoredGridColl = entity.GridCollisionClass
                data.GridCollToSet = data.Flags & JumpLib.Flags.GRIDCOLL_NO_WALLS == 0 and EntityGridCollisionClass.GRIDCOLL_WALLS or EntityGridCollisionClass.GRIDCOLL_NONE
            end

            if data.Flags & JumpLib.Flags.KNIFE_FOLLOW_CUSTOM == 0 then
                for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_KNIFE)) do
                    if v.Parent and GetPtrHash(v.Parent) == hash then
                        local konfig = config; konfig.Flags = (konfig.Flags | JumpLib.Flags.GRIDCOLL_NO_WALLS) ~ JumpLib.Flags.COLLISION_GRID

                        if data.Flags & JumpLib.Flags.KNIFE_DISABLE_ENTCOLL ~= 0 then
                            konfig.Flags = konfig.Flags | JumpLib.Flags.COLLISION_ENTITY
                        end

                        JumpLib:Jump(v, konfig)
                    end
                end
            end
        end

        JumpLib:RunCallbackWithParam(JumpLib.Callbacks.POST_ENTITY_JUMP, player or entity, config)

        if player then
            local orbitals = data.Flags & JumpLib.Flags.FAMILIAR_FOLLOW_ORBITALS ~= 0
            local followers = data.Flags & JumpLib.Flags.FAMILIAR_FOLLOW_FOLLOWERS ~= 0
            local tearcopying = data.Flags & JumpLib.Flags.FAMILIAR_FOLLOW_TEARCOPYING ~= 0

            for i, v in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR)) do
                local familiar = v:ToFamiliar() ---@cast familiar EntityFamiliar
                local orbital = (orbitals and JumpLib.Internal:IsOrbital(familiar))

                if orbital or (followers and (JumpLib.Internal:IsFollower(familiar) or familiar.Variant == FamiliarVariant.BLOOD_BABY)) or (tearcopying and JumpLib.Internal.TEAR_COPYING_FAMILIARS[familiar.Variant] and familiar.Variant ~= FamiliarVariant.SPRINKLER) then
                    local _config = config if orbital then _config.Flags = _config.Flags | JumpLib.Flags.GRIDCOLL_NO_WALLS end
                    JumpLib:Jump(v, _config, force)
                end
            end
        end

        return true
    end

    ---Jumps if `CanJump()` returns `true`
    ---
    ---Returns `true` if successful, `false` otherwise
    ---@param entity Entity
    ---@param config JumpConfig
    ---@return boolean
    function JumpLib:TryJump(entity, config)
        local canJump = JumpLib:CanJump(entity)

        if canJump then
            return JumpLib:Jump(entity, config)
        end

        return canJump
    end

    ---Stops the current jump
    ---
    ---Returns `true` if successful, `false` otherwise
    ---@param entity Entity
    ---@return boolean
    function JumpLib:QuitJump(entity)
        local data = JumpLib.Internal:GetData(entity) if not data.Jumping then return false end

        data.EntCollToSet = nil
        data.GridCollToSet = nil
        data.Jumping = false
        data.Flags = 0
        data.Fallspeed = 0
        data.LaserOffset = nil
        data.Height = 0
        data.Tags = nil
        data.UpdateFrame = 0

        JumpLib.Internal:UpdateCollision(entity)
        JumpLib.Internal:RemoveEntity(entity)

        return true
    end

    ---Begins player pitfall sequence
    ---@param player EntityPlayer
    ---@param position Vector
    ---@param damage integer | nil
    ---@return boolean
    function JumpLib:Pitfall(player, position, damage)
        if player.Type ~= EntityType.ENTITY_PLAYER or JumpLib:IsPitfalling(player) or player:IsCoopGhost() then return false end

        damage = damage or 1

        player:PlayExtraAnimation("FallIn")

        local data = JumpLib.Internal:GetData(player)

        data.Pitfall = true
        data.PitPos = position

        data.StoredEntityColl = player.EntityCollisionClass
        data.StoredGridColl = player.GridCollisionClass

        JumpLib.Internal:ScheduleFunction(function ()
            for _, v in ipairs(JumpLib:RunCallbackWithParam(JumpLib.Callbacks.PRE_PITFALL_HURT, player, JumpLib:GetData(player), damage)) do
                damage = type(v) == "number" and v or damage
                if v == true then
                    return
                end
            end

            player:TakeDamage(damage, DamageFlag.DAMAGE_PITFALL, EntityRef(player), 30)
        end, JumpLib.Constants.PITFRAME_START, true)

        JumpLib.Internal:ScheduleFunction(function ()
            player:AnimatePitfallOut()

            player:AddCacheFlags(CacheFlag.CACHE_SIZE)
            player:EvaluateItems()

            data.PitPos = data.JumpPos or game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true, true)
        end, JumpLib.Constants.PITFRAME_DAMAGE, true)

        JumpLib.Internal:ScheduleFunction(function ()
            data.Pitfall = false
            data.PitPos = nil

            player.ControlsEnabled = true

            JumpLib:RunCallbackWithParam(JumpLib.Callbacks.PITFALL_EXIT, player, JumpLib:GetData(player))
            JumpLib.Internal:UpdateCollision(player)
        end, JumpLib.Constants.PITFRAME_END, true)

        return true
    end

    ---Returns if player is currently pitfalling
    ---@param player Entity
    ---@return boolean
    function JumpLib:IsPitfalling(player)
        return not not JumpLib.Internal:GetData(player).Pitfall
    end

    ---Returns non-writable `JumpData` of provided entity
    ---@param entity Entity
    ---@return JumpData
    function JumpLib:GetData(entity)
        local data = JumpLib.Internal:GetData(entity)

        return  {
            Jumping = data.Jumping or false,
            Tags = data.Tags or {},
            Height = data.Height or 0,
            StaticHeightIncrease = data.StaticHeightIncrease or 0,
            StaticJumpSpeed = data.StaticJumpSpeed or 0,
            Fallspeed = data.Fallspeed or 0,
            Flags = data.Flags or 0,
        }
    end

    ---Sets height of entity if jumping
    ---
    ---If `config` is provided, entity jumps and height is automatically set
    ---
    ---Returns `true` if successful, `false` otherwise
    ---@param entity Entity
    ---@param height number
    ---@param config JumpConfig | nil
    ---@return boolean
    function JumpLib:SetHeight(entity, height, config)
        if not JumpLib:GetData(entity).Jumping then
            if config then
                JumpLib:Jump(entity, config)
            else
                return false
            end
        end

        JumpLib.Internal:GetData(entity).Height = height

        return true
    end

    ---Removes a tag from the current jump
    ---@param entity Entity
    ---@param tag string
    function JumpLib:ClearTag(entity, tag)
        local data = JumpLib.Internal:GetData(entity) if not data.Tags then return end
        data.Tags[tag] = nil
    end

    ---Sets speed of current jump
    ---
    ---Returns `true` if successful, `false` otherwise
    ---@param entity Entity
    ---@param speed number
    ---@return boolean
    function JumpLib:SetSpeed(entity, speed)
        local data = JumpLib:GetData(entity)

        if not data.Jumping then
            return false
        end

        local player = entity:ToPlayer()

        if data.Flags & JumpLib.Flags.IGNORE_FALLSPEED_MODIFIERS == 0 then
            local returns = JumpLib:RunCallbackWithParam(JumpLib.Callbacks.PRE_ENTITY_SET_FALLSPEED, player or entity, speed, JumpLib:GetData(entity))

            for _, v in ipairs(returns) do
                if type(v) == "number" then
                    speed = speed * v
                elseif v == true then
                    return false
                end
            end
        end

        JumpLib.Internal:GetData(entity).Fallspeed = speed

        JumpLib:RunCallbackWithParam(JumpLib.Callbacks.POST_ENTITY_SET_FALLSPEED, player or entity, speed, JumpLib:GetData(entity))

        return true
    end

    ---Returns a render offset for non-laser entites that is automatically adjusted for reflections
    ---
    ---Returns a position offset for laser entities
    ---@param entity Entity
    ---@param yOffset number | nil
    ---@return Vector
    function JumpLib:GetOffset(entity, yOffset)
        local data = JumpLib:GetData(entity)

        if entity.Type == EntityType.ENTITY_LASER then
            local laser = entity:ToLaser() ---@cast laser EntityLaser

            if not data.Jumping then
                return laser.PositionOffset
            end

            local laserData = JumpLib.Internal:GetData(entity)

            if not laserData.LaserOffset then
                laserData.LaserOffset = Vector(laser.PositionOffset.X, laser.PositionOffset.Y)
            end

           return Vector(laserData.LaserOffset.X, -data.Height * JumpLib.Constants.HEIGHT_TO_LASER_OFFSET + laserData.LaserOffset.Y)
        end

        if not data.Jumping then
            return JumpLib.Internal.Vector.Zero
        end

        local renderOffset = Vector(0, -data.Height + (yOffset or 0))

        if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
            renderOffset = -renderOffset
        end

        return renderOffset
    end

    ---@param entity Entity
    function JumpLib:IsFalling(entity)
        local data = JumpLib.Internal:GetData(entity)
        if (data.Fallspeed or 0) > (data.StaticHeightIncrease or 1) then
            return true
        end
        return false
    end

    ---@param entity Entity
    function JumpLib:Update(entity)
        local entityData = JumpLib.Internal:GetData(entity)
        local jumpData = JumpLib:GetData(entity)
        local player = entity:ToPlayer()

        entityData.UpdateFrame = (entityData.UpdateFrame or 1) + 1

        if entityData.Jumping then
            for _, v in ipairs(JumpLib:RunCallbackWithParam(JumpLib.Callbacks.PRE_ENTITY_UPDATE, player or entity, jumpData)) do
                if v == true then
                    return
                end
            end

            if entityData.UpdateFrame % 2 == 0 and entityData.Jumping then
                JumpLib:RunCallbackWithParam(JumpLib.Callbacks.ENTITY_UPDATE_30, player or entity, jumpData)
            end

            local timescale = JumpLib.Internal.WATCHSTATE_TO_TIMESCALE[game:GetRoom():GetBrokenWatchState() or 0]

            entityData.Fallspeed = entityData.Fallspeed + (JumpLib.Constants.FALLSPEED_INCR * entityData.StaticJumpSpeed) * timescale

            entityData.Height = math.max(0,
                entityData.Height + (entityData.StaticHeightIncrease - entityData.Fallspeed * entityData.StaticJumpSpeed) * timescale
            )

            if not REPENTOGON and not player then
                entity.SpriteOffset = JumpLib:GetOffset(entity)
            end

            JumpLib.Internal:UpdateCollision(entity)
            JumpLib:RunCallbackWithParam(JumpLib.Callbacks.ENTITY_UPDATE_60, player or entity, jumpData)

            if entityData.Height == 0 then
                entityData.PrevTags = entityData.Tags

                JumpLib:QuitJump(entity)

                local fell

                if player then
                    if jumpData.Flags & JumpLib.Flags.NO_PITFALL == 0 then
                        if jumpData.Flags & JumpLib.Flags.COLLISION_GRID == 0 then

                            local pitFound
                            local room = game:GetRoom()

                            local grid = room:GetGridEntityFromPos(player.Position)
                            local pit

                            if grid then
                                pit = grid:ToPit()
                            end

                            if pit then
                                if pit.State == 0 and not pit.HasLadder then
                                    pitFound = true

                                    if FiendFolio and StageAPI then
                                        for _, customGrid in ipairs(StageAPI.GetCustomGrids(room:GetGridIndex(player.Position), FiendFolio.LilyPadGrid.Name)) do
                                            if customGrid.PersistentData.State == "Idle" then
                                                pitFound = false
                                                break
                                            end
                                        end
                                    end
                                end
                            end

                            if pitFound then
                                local canFly = player.CanFly
                                local hurt = jumpData.Flags & JumpLib.Flags.NO_HURT_PITFALL == 0 and 1 or 0

                                if jumpData.Flags & JumpLib.Flags.IGNORE_FLIGHT ~= 0 then
                                    canFly = false
                                end

                                local fall = true and not canFly

                                if fall then
                                    for _, v in ipairs(JumpLib:RunCallbackWithParam(JumpLib.Callbacks.PRE_PITFALL, player, jumpData)) do
                                        if v == true then
                                            fall = false
                                            break
                                        elseif v == false then
                                            hurt = 0
                                        elseif type(v) == "number" then
                                            hurt = v
                                        end
                                    end

                                    if fall then
                                        fell = true
                                        JumpLib:Pitfall(player, grid.Position, hurt)
                                    end
                                end
                            end
                        end
                    end

                    if not REPENTOGON then
                        player.PositionOffset = JumpLib.Internal.Vector.Zero
                    end
                end

                JumpLib:RunCallbackWithParam(JumpLib.Callbacks.ENTITY_LAND, player or entity, jumpData, fell)

                entityData.PrevTags = nil
            end
        end
    end

    AddCallback(ModCallbacks.MC_POST_RENDER, function ()
        if game:IsPaused() then return end

        for _, entity in ipairs(JumpLib.Internal.ActiveEntities) do
            JumpLib:Update(entity)
        end
    end)

    ---Pitfall
    ---@param player EntityPlayer
    AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
        local data = JumpLib.Internal:GetData(player) if not data.Pitfall then return end

        player.ControlsEnabled = false

        player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

        player.Velocity = (data.PitPos - player.Position):Resized(player.Position:Distance(data.PitPos) * 0.2)

        if player:GetSprite():IsFinished("FallIn") then
            player.SpriteScale = JumpLib.Internal.Vector.Zero
        end
    end)

    AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
        for i = 0, game:GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            JumpLib.Internal:GetData(player).JumpPos = player.Position
        end
    end)

    if not REPENTOGON then
        ---@param player EntityPlayer
        AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
            if JumpLib:GetData(player).Jumping then
                player.PositionOffset = JumpLib:GetOffset(player) * JumpLib.Internal.PLAYER_POSITION_OFFSET_MULT
            end
        end)
    end

    ---@param laser EntityLaser
    AddCallback(ModCallbacks.MC_POST_LASER_RENDER, function (_, laser)
        if laser.Variant == LaserVariant.TRACTOR_BEAM then return end

        local entity = laser.Parent

        if not entity then return end

        if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end

        local entityData = entity and JumpLib.Internal:GetData(entity)

        if entityData and entityData.Jumping then
            if JumpLib:GetData(entity).Flags & JumpLib.Flags.LASER_FOLLOW_CUSTOM == 0 then
                local laserData = JumpLib.Internal:GetData(laser)

                if not (laser.DisableFollowParent or laser:IsCircleLaser()) or not laserData.SetInitialLaserHeight then
                    local config = entityData.Config

                    config.Speed = 0

                    if laser:IsCircleLaser() then
                        JumpLib:SetHeight(laser, entityData.Height, {Height = 0, Speed = 0.8})
                    else
                        JumpLib:SetHeight(laser, entityData.Height, config)

                        laserData.StaticHeightIncrease = 0
                        laserData.StaticJumpSpeed = 0
                    end

                    laserData.SetInitialLaserHeight = true
                end

                laser.PositionOffset = JumpLib:GetOffset(laser)
            end
        end
    end)

    ---@param entity Entity
    local function PreRender(_, entity)
        local jumpData = JumpLib:GetData(entity)

        if jumpData.Jumping then
            return JumpLib:GetOffset(entity)
        end
    end

    if REPENTOGON then
        for _, v in ipairs(JumpLib.Internal.PRE_RENDER_CALLBACKS) do
            AddCallback(v, PreRender)
        end
    end

    ---@param bomb EntityBomb
    AddCallback(ModCallbacks.MC_POST_BOMB_INIT, function (_, bomb)
        if not (bomb.SpawnerEntity and bomb.SpawnerEntity.Type == EntityType.ENTITY_PLAYER) then return end
        if bomb.Position:Distance(bomb.SpawnerEntity.Position) > 1 then return end
        local data = JumpLib:GetData(bomb.SpawnerEntity) if not data.Jumping or data.Flags & JumpLib.Flags.DISABLE_COOL_BOMBS ~= 0 then return end

        JumpLib:SetHeight(bomb, data.Height, {
            Height = 0,
            Speed = 1.25,
            Tags = "JUMPLIB_BOMB"
        })

        if not REPENTOGON then
            JumpLib:Update(bomb)
        end
    end)

    ---@param entity Entity
    AddCallback(JumpLib.Callbacks.ENTITY_LAND, function (_, entity)
        local bomb = entity:ToBomb() ---@cast bomb EntityBomb

        if bomb.IsFetus then return end

        bomb:SetExplosionCountdown(0)
    end, {
        type = EntityType.ENTITY_BOMB,
        tag = "JUMPLIB_BOMB"
    })

    ---@param entity Entity
    ---@param flags DamageFlag
    AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function (_, entity, _, flags)
        if flags & DamageFlag.DAMAGE_RED_HEARTS ~= 0 then return end
        local data = JumpLib:GetData(entity) if not data.Jumping then return end
        if data.Flags & JumpLib.Flags.DAMAGE_CUSTOM ~= 0 then return end
        return false
    end)

    ---@param tear EntityTear
    AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function (_, tear)
        local spawner = tear.SpawnerEntity or tear.Parent if not spawner then return end
        local data = JumpLib:GetData(spawner) if not data.Jumping or data.Flags & JumpLib.Flags.DISABLE_TEARHEIGHT ~= 0 then return end

        for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR)) do
            local dist = v.Position:Distance(tear.Position - tear.Velocity)

            if dist < 0.1 then
                JumpLib.Internal:GetData(tear).Familiar = v
                break
            end
        end
    end)

    ---@param tear EntityTear | EntityProjectile
    local function TearUpdate(_, tear)
        if tear.FrameCount ~= 0 then return end
        if tear.Type == EntityType.ENTITY_TEAR and tear:HasTearFlags(TearFlags.TEAR_CHAIN) then return end

        local spawner = tear.SpawnerEntity or tear.Parent if not spawner then return end
        local familiar = JumpLib.Internal:GetData(tear).Familiar
        local data = JumpLib:GetData(familiar or spawner) if not data.Jumping or data.Flags & JumpLib.Flags.DISABLE_TEARHEIGHT ~= 0 then return end

        tear.Height = tear.Height - data.Height * JumpLib.Constants.TEAR_HEIGHT_MULT
    end

    for _, v in ipairs({
        ModCallbacks.MC_POST_TEAR_UPDATE,
        ModCallbacks.MC_POST_PROJECTILE_UPDATE,
    }) do
        AddCallback(v, TearUpdate)
    end

    ---@param entity Entity
    ---@param hook InputHook
    ---@param action ButtonAction
    AddCallback(ModCallbacks.MC_INPUT_ACTION, function (_, entity, hook, action)
        if not entity then return end

        local data = JumpLib:GetData(entity) if not data.Jumping then return end

        if (JumpLib.Internal.MOVE_ACTIONS[action] and data.Flags & JumpLib.Flags.DISABLE_MOVING_INPUT ~= 0)
        or (JumpLib.Internal.SHOOT_ACTIONS[action] and data.Flags & JumpLib.Flags.DISABLE_SHOOTING_INPUT ~= 0)
        or (action == ButtonAction.ACTION_BOMB and data.Flags & JumpLib.Flags.DISABLE_BOMB_INPUT ~= 0)
        or (action == ButtonAction.ACTION_PILLCARD and data.Flags & JumpLib.Flags.DISABLE_PILL_CARD_INPUT ~= 0)
        or (action == ButtonAction.ACTION_ITEM and data.Flags & JumpLib.Flags.DISABLE_ACTIVE_ITEM_INPUT ~= 0) then
            return JumpLib.Internal.HOOK_TO_CANCEL[hook]
        end     
    end)

    ---@param entity Entity
    AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (_, entity)
        JumpLib.Internal:RemoveEntity(entity)
    end)

    if REPENTOGON then
        ---@param grid GridEntity
        AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_LOCK_UPDATE, function (_, grid)
            for _, v in ipairs(Isaac.FindInRadius(grid.Position, JumpLib.Internal.GRID_PLAYER_SEARCH_RADIUS, EntityPartition.PLAYER)) do
                local data = JumpLib:GetData(v) if data.Jumping and data.Flags & JumpLib.Flags.COLLISION_GRID == 0 then
                    return false
                end
            end
        end)

        ---@param entity Entity
        ---@param grid GridEntity?
        local function GridCollision(_, entity, _, grid)
            local lock = grid and grid:ToLock() if not lock then return end
            local data = JumpLib:GetData(entity) if data.Jumping and data.Flags & JumpLib.Flags.COLLISION_GRID == 0 then
                return true
            end
        end

        for _, v in ipairs({
            ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION,
            ModCallbacks.MC_PRE_TEAR_GRID_COLLISION,
            ModCallbacks.MC_PRE_FAMILIAR_GRID_COLLISION,
            ModCallbacks.MC_PRE_BOMB_GRID_COLLISION,
            ModCallbacks.MC_PRE_PICKUP_GRID_COLLISION,
            ModCallbacks.MC_PRE_PROJECTILE_GRID_COLLISION,
            ModCallbacks.MC_PRE_NPC_GRID_COLLISION,
        }) do
            AddCallback(v, GridCollision)
        end

        ---@param effect EntityEffect
        AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, function (_, effect)
            if not effect.Parent then return end
            return JumpLib:GetOffset(effect.Parent)
        end, 201)
    end

    AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function ()
        for playerCallback, entityCallback in pairs(JumpLib.Internal.PLAYER_TO_ENTITY_CALLBACK) do
            for _, callbackEntry in pairs(Isaac.GetCallbacks(playerCallback)) do
                -- print("Patching callback " .. playerCallback .. " to " .. entityCallback .. " from mod " .. callbackEntry.Mod.Name .. "!")
                local param = callbackEntry.Param
                param = param or {}
                ---@diagnostic disable-next-line: inject-field
                param.type = EntityType.ENTITY_PLAYER
                callbackEntry.Mod:RemoveCallback(playerCallback, callbackEntry.Function)
                callbackEntry.Mod:AddCallback(entityCallback, callbackEntry.Function, param)
            end
        end
    end)

    for _, v in ipairs(JumpLib.Internal.CallbackEntries) do
        if v.Priority then
            JumpLib:AddPriorityCallback(v.Callback, v.Priority, v.Function, v.Param)
        else
            JumpLib:AddCallback(v.Callback, v.Function, v.Param)
        end
    end
end

return LOCAL_JUMPLIB

-- Special thanks to Thicco Catto
