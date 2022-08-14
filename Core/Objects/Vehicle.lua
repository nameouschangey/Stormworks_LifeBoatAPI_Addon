-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class LifeBoatAPI.Vehicle : LifeBoatAPI.GameObject
---@field onLoaded LifeBoatAPI.Event
---@field onDamaged LifeBoatAPI.Event
---@field onTeleport LifeBoatAPI.Event
---@field onButtonPress LifeBoatAPI.Event 
---@field onSeatedChange LifeBoatAPI.Event
LifeBoatAPI.Vehicle = {
    ---@param cls LifeBoatAPI.Vehicle
    fromSavedata = function(cls, savedata)
        local self = {
            savedata = savedata,
            id = savedata.id,
            transform = savedata.transform,

            -- events
            onDamaged = LifeBoatAPI.Event:new(),
            onTeleport = LifeBoatAPI.Event:new(),
            onButtonPress = LifeBoatAPI.Event:new(),
            onSeatedChange = LifeBoatAPI.Event:new(),
            onLoaded = LifeBoatAPI.Event:new(),
            onDespawn = LifeBoatAPI.Event:new(),

            onCollision = LifeBoatAPI.Event:new(),

            -- methods
            awaitLoaded = cls.awaitLoaded,
            getTransform = not savedata.isStatic and cls.getTransform or nil,
            attach = LifeBoatAPI.lb_attachDisposable,
            despawn = LifeBoatAPI.GameObject.despawn,
            onDispose = cls.onDispose,
            toggleCollision = LifeBoatAPI.GameObject.toggleCollision
        }
        
        -- ensure position is up to date
        if self.getTransform then
            self:getTransform()
        end

        -- run init script (before enabling collision detection, so it can be cancelled if wanted)
        local script = LB.objects.onInitScripts[self.savedata.onInitScript]
        if script then
            script(self)
        end
        
        if self.collisionLayers then
            LB.collision:trackObject(self)
        end

        return self
    end;

    ---@param cls LifeBoatAPI.Vehicle
    ---@param component LifeBoatAPI.AddonComponent
    ---@param spawnData SWAddonComponentSpawned
    fromAddonSpawn = function(cls, component, spawnData)
        local obj = cls:fromSavedata({
            id = spawnData.id,
            isAddonSpawn = true,
            tags = component.tags,
            dynamicType = component.rawdata.dynamic_object_type,
            name = component.rawdata.display_name,
            transform = spawnData.transform,
            isStatic = component.tags["isStatic"],
            collisionLayers = component:parseSequentialTag("collisionLayer"),
            onInitScript = component.tags["onInitScript"]
        })

        LB.objects:trackEntity(obj)

        return obj
    end;

    ---@param vehicleID number
    ---@param isStatic boolean if true, will not collide and will not move
    ---@param collisionLayers string[]|nil (ignored if isStatic) leave nil if this shouldn't perform collision checks
    ---@return LifeBoatAPI.Vehicle
    fromUntrackedSpawn = function(cls, vehicleID, ownerPeerID, spawnCost, isStatic, collisionLayers, onInitScript)
        local obj = cls:fromSavedata({
            id = vehicleID,
            isAddonSpawn = false,
            ownerSteamID = LB.players.playersByPeerID[ownerPeerID].steamID,
            spawnCost = spawnCost,
            isStatic = isStatic,
            collisionLayers = isStatic and nil or collisionLayers,
            onInitScript = onInitScript
        })
        
        LB.objects:trackEntity(obj)

        return obj
    end;
    
    ---@param self LifeBoatAPI.Vehicle
    ---@return LifeBoatAPI.Coroutine
    awaitLoaded = function(self)
        local isLoaded = server.getVehicleSimulating(self.id)
        if isLoaded then
            return LifeBoatAPI.Coroutine:start()
        elseif LB.objects.enableVehicleCallbacks then
            return self.onLoaded:await()
        else
            local cr = LifeBoatAPI.Coroutine:start(nil, true)
            cr:attach(LB.events.onVehicleLoad:register(function (l, context, vehicle_id)
                if vehicle_id == self.id then
                    cr:trigger()
                    l.isDisposed = true
                end
            end,nil,nil))
            return cr
        end
    end;

    ---@param self LifeBoatAPI.Vehicle
    ---@return LifeBoatAPI.Matrix
    getTransform = function(self)
        local matrix, success = server.getVehiclePos(self.id, 0, 0, 0)
        if success then
            self.transform = matrix
            self.lastTickUpdated = LB.ticks.ticks
        end
        return self.transform
    end;

    ---@param self LifeBoatAPI.Vehicle
    onDispose = function(self)
        if self.onDespawn.hasListeners then
            self.onDespawn:trigger(self)
        end
        LB.objects:stopTracking(self)
        server.despawnVehicle(self.id, true)
    end;
}