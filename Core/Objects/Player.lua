-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class LifeBoatAPI.Player : LifeBoatAPI.GameObject
---@field id number peerID
---@field steamID string
---@field isAdmin boolean
---@field isAuth boolean
---@field displayName string
---@field savedata table persistent data for this specific player
---
---@field onTeleport LifeBoatAPI.Event
---@field onButtonPress LifeBoatAPI.Event 
---@field onSeatedChange LifeBoatAPI.Event
---@field onSpawnVehicle LifeBoatAPI.Event
---@field onAliveChanged LifeBoatAPI.Event
---@field onCommand LifeBoatAPI.Event
---@field onChat LifeBoatAPI.Event
---@field onToggleMap LifeBoatAPI.Event
LifeBoatAPI.Player = {
    ---@param cls LifeBoatAPI.Player
    ---@return LifeBoatAPI.Player
    new = function (cls, peerID, steamID, isAdmin, isAuth, name, savedata)
        savedata.collisionLayers = savedata.collisionLayers or {"player"} 
        local self = {
            savedata = savedata;
            type = "player";
            id = peerID;
            steamID = steamID;
            isAdmin = isAdmin;
            isAuth = isAuth;
            displayName = name;

            --- events
            onTeleport = LifeBoatAPI.Event:new();
            onButtonPress = LifeBoatAPI.Event:new();
            onSeatedChange = LifeBoatAPI.Event:new();
            onSpawnVehicle = LifeBoatAPI.Event:new();
            onAliveChanged = LifeBoatAPI.Event:new();
            onCommand = LifeBoatAPI.Event:new();
            onChat = LifeBoatAPI.Event:new();
            onToggleMap = LifeBoatAPI.Event:new();

            onDespawn = LifeBoatAPI.Event:new();
            onCollision = LifeBoatAPI.Event:new();

            -- methods
            getTransform = cls.getTransform;
            attach = LifeBoatAPI.lb_attachDisposable,
            toggleCollision = LifeBoatAPI.GameObject.toggleCollision;
            awaitLoaded = cls.awaitLoaded;
        }

        -- ensure position is up to date
        if self.getTransform then
            self:getTransform()
        end

        -- by default all players are collision enabled
        if self.collisionLayers then
            LB.collision:trackObject(self)
        end
        
        return self
    end;

    ---@param self LifeBoatAPI.Player
    ---@param timeout number|nil time to keep checking for in ticks, before giving up - nil to continue indefinitely
    ---@return LifeBoatAPI.Coroutine
    awaitLoaded = function(self, timeout)
        -- check if it's already loaded
        local timePassed = 0
        
        return LifeBoatAPI.Coroutine:start()
        :andImmediately(function (cr, deltaTicks, lastResult)
            -- keep checking if the player has loaded, until the timeout
            timeout = timeout + deltaTicks

            local characterID, success = server.getPlayerCharacterID(self.id)
            if success then
                local loadedState, success = server.getObjectSimulating(characterID)
                if success and loadedState then
                    return cr.yield, characterID
                end
            end

            if self.isDisposed then
                return cr.yield, nil, "Player disconnected"
            end

            if timeout and timePassed > timeout then
                return cr.yield, nil, "Timeout reached before loading"
            end

            return cr.loop
        end)
    end;

    ---@param self LifeBoatAPI.Player
    getTransform = function(self)
        local matrix, success = server.getPlayerPos(self.id)
        if success then
            self.transform = matrix
            self.lastTickUpdated = LB.ticks.ticks
        end
        return self.transform
    end;
}