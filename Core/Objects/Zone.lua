-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class LifeBoatAPI.ZoneSaveData : LifeBoatAPI.GameObjectSaveData
---@field sizeX number
---@field sizeY number
---@field sizeZ number
---@field radius number
---@field collisionType string
---@field collisionLayer string
---@field overrideIsBig boolean

---@class LifeBoatAPI.Zone : LifeBoatAPI.GameObject
---@field savedata LifeBoatAPI.ZoneSaveData
---@field parent LifeBoatAPI.GameObject
LifeBoatAPI.Zone = {
    _generateZoneID = function()
        g_savedata.lb_nextZoneID = g_savedata.lb_nextZoneID and (g_savedata.lb_nextZoneID + 1) or 0
        return g_savedata.lb_nextZoneID
    end;

    ---@param cls LifeBoatAPI.Zone
    ---@param savedata LifeBoatAPI.ZoneSaveData
    fromSavedata = function(cls, savedata)
        local parentID = savedata.parentID
        local parentType = savedata.parentType
        local parent;
        if parentID and parentType then
            parent = LB.objects:getByType(parentType, parentID)
        end

        local self = {
            savedata = savedata,
            id = savedata.id,
            transform = savedata.transform,
            parent = parent,
            getTransform = parent and cls.getTransform or nil,
            
            onDespawn = LifeBoatAPI.Event:new(),
            onCollision = LifeBoatAPI.Event:new(),

            attach = LifeBoatAPI.lb_attachDisposable,
            despawn = LifeBoatAPI.GameObject.despawn,
            onDispose = LifeBoatAPI.GameObject.onDispose,
            toggleCollision = LifeBoatAPI.GameObject.toggleCollision
        }

        if savedata.collisionType == "box" then
            savedata.radius = (((savedata.sizeX * savedata.sizeX)
                              + (savedata.sizeY * savedata.sizeY)
                              + (savedata.sizeZ * savedata.sizeZ))^0.5) / 2
        end

        -- meant to be attached to an object that's now gone, or parent object exists but is disposed
        if parentID and not parent then
            LifeBoatAPI.lb_dispose(self)
        elseif parent then
            parent:attach(self)
        end

        if self.isDisposed then
            return self
        end

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

    ---@param cls LifeBoatAPI.Zone
    ---@param spawnData SWAddonComponentSpawned
    fromAddonSpawn = function(cls, component, spawnData, parent)
        local obj = cls:fromSavedata({
            id = spawnData.id,
            type = "zone",
            collisionType = (component.tags["collisionType"] == "sphere" and "sphere") or "box",
            collisionLayer = component.tags["collisionLayer"],
            transform = spawnData.transform,
            radius = component.tags["radius"] and tonumber(component.tags["radius"]) or 0,
            sizeX = component.tags["sizeX"] and tonumber(component.tags["sizeX"]) or 0,
            sizeY = component.tags["sizeY"] and tonumber(component.tags["sizeY"]) or 0,
            sizeZ = component.tags["sizeZ"] and tonumber(component.tags["sizeZ"]) or 0,
            overrideIsBig = component.tags["overrideIsBig"],

            parentID = parent and parent.id,
            parentType = parent and parent.type,
            onInitScript = component.tags["onInitScript"]
        })

        LB.objects:trackEntity(obj)

        return obj
    end;

    ---@param cls LifeBoatAPI.Zone
    ---@param isTemporary boolean|nil if true, doesn't track between addon reloads (can simplify mission creation in some specific cases)
    ---@return LifeBoatAPI.Zone
    newSphere = function(cls, collisionLayer, transform, radius, parent, onInitScript, isTemporary)
        local zoneID = LifeBoatAPI.Zone._generateZoneID()
        local obj = cls:fromSavedata({
            id = zoneID,
            type = "zone",
            collisionType = "sphere",
            transform = transform,
            radius = radius,
            collisionLayer = collisionLayer,
            parentID = parent and parent.id,
            parentType = parent and parent.type,
            onInitScript = onInitScript
        })

        if not isTemporary then
            LB.objects:trackEntity(obj)
        end

        return obj
    end;

    ---@param cls LifeBoatAPI.Zone
    ---@param isTemporary boolean|nil if true, doesn't track between addon reloads (can simplify mission creation in some specific cases)
    ---@return LifeBoatAPI.Zone
    newZone = function(cls, collisionLayer, transform, sizeX, sizeY, sizeZ, parent, onInitScript, isTemporary)
        local zoneID = LifeBoatAPI.Zone._generateZoneID()
        local obj = cls:fromSavedata({
            id = zoneID,
            type = "zone",
            collisionType = "box",
            transform = transform,
            sizeX = sizeX,
            sizeY = sizeY,
            sizeZ = sizeZ,
            collisionLayer = collisionLayer,
            parentID = parent and parent.id,
            parentType = parent and parent.type,
            onInitScript = onInitScript
        })

        if not isTemporary and not obj.isDisposed then
            LB.objects:trackEntity(obj)
        end

        return obj
    end;

    ---@param self LifeBoatAPI.Zone
    getTransform = function(self)
        -- function isn't assigned unless this has a parent
        -- if parent has moved, recalculate our position
        if self.parent.getTransform and self.parent.lastTickUpdated ~= LB.ticks.ticks then
            self.transform = LifeBoatAPI.Matrix.multiplyMatrix(self.parent:getTransform(), self.transform)
            self.lastTickUpdated = LB.ticks.ticks
        end
        
        return self.transform
    end;

    ---@param self LifeBoatAPI.Zone
    onDispose = function(self)
        -- ensures all references are collected correctly
        LB.objects:stopTracking(self)
    end;
}