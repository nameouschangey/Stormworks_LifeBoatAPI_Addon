-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class EventTypes.LBOnCollisionEnd : LifeBoatAPI.Event
---@field register fun(self:LifeBoatAPI.Event, func:fun(l:LifeBoatAPI.IEventListener, context:any, collision:LifeBoatAPI.Collision), context:any, timesToExecute:number|nil) : LifeBoatAPI.IEventListener

---@class LifeBoatAPI.Collision : LifeBoatAPI.IDisposable
---@field zone LifeBoatAPI.GameObject
---@field object LifeBoatAPI.GameObject
---@field onCollisionEnd EventTypes.LBOnCollisionEnd
LifeBoatAPI.Collision = {
    ---@param self LifeBoatAPI.Collision
    onDispose = function(self)
        if self.onCollisionEnd.hasListeners then
            self.onCollisionEnd:trigger(self)
        end
    end;
}

---@class LifeBoatAPI.CollisionLayer
---@field objects LifeBoatAPI.GameObject[]
---@field zones LifeBoatAPI.Zone[]
---@field name string
LifeBoatAPI.CollisionLayer = {
    ---@return LifeBoatAPI.CollisionLayer
    new = function(cls, name)
        return {
            name = name,
            zones = {},
            objects = {}
        }
    end;
}

---@class LifeBoatAPI.CollisionManager
---@field layers LifeBoatAPI.CollisionLayer[]
---@field layersByName table<string, LifeBoatAPI.CollisionLayer>
---@field collisions table<any, table<LifeBoatAPI.Zone, LifeBoatAPI.Collision>>
---@field tickFrequency number frequency to update collisions, default is 30ticks (twice per second - which is going to be more than enough for 99.9% of cases)
LifeBoatAPI.CollisionManager = {

    ---@param cls LifeBoatAPI.CollisionManager
    ---@return LifeBoatAPI.CollisionManager
    new = function(cls, tickFrequency)
        ---@type LifeBoatAPI.CollisionManager
        local self = {
            layers = {};
            layersByName = {};
            collisions = {};
            tickFrequency = tickFrequency or 1; -- twice per second seems pretty reasonable really. Not sure why you'd need it much higher, especially as we're checking by line

            ---methods
            init = cls.init;
            trackEntity = cls.trackEntity;
            stopTracking = cls.stopTracking;
            _onTick = cls._onTick;
        }
        return self
    end;

    ---@param self LifeBoatAPI.CollisionManager
    init = function(self)
        LB.ticks:register(self._onTick, self, self.tickFrequency)
    end;

    ---@param self LifeBoatAPI.CollisionManager
    ---@param entity LifeBoatAPI.GameObject
    trackEntity = function(self, entity)
        local layerName = entity.savedata.collisionLayer

        if not entity.isCollisionRegistered and layerName then
            if not self.layersByName[layerName] then
                local layer = LifeBoatAPI.CollisionLayer:new(layerName)
                self.layers[#self.layers+1] = layer
                self.layersByName[layerName] = layer
            end

            local layer = self.layersByName[layerName]

            if entity.savedata.type == "zone" then
                ---@cast entity LifeBoatAPI.Zone
                layer.zones[#layer.zones+1] = entity
            else
                layer.objects[#layer.objects+1] = entity
            end

            entity.isCollisionRegistered = true
        end
        server.announce("obj added", "added object on layer " .. tostring(layerName))
    end;
    
    ---@param self LifeBoatAPI.CollisionManager
    ---@param entity LifeBoatAPI.GameObject
    stopTracking = function(self, entity)
        entity.isCollisionStopped = false
    end;

    ---@param listener LifeBoatAPI.ITickable
    _onTick = function(listener, self)
        for i=1, 100 do
            LifeBoatAPI.CollisionManager.run(self, i)
        end
    end;

    run = function(self, runtime)
        ---@type LifeBoatAPI.CollisionManager
        local collisions = self.collisions

        local currentTick = LB.ticks.ticks

        local isLineInZone = LifeBoatAPI.Colliders.isLineInZone
        local isLineInSphere = LifeBoatAPI.Colliders.isLineInSphere
        local isPointInZone = LifeBoatAPI.Colliders.isPointInZone
        local isPointInSphere = LifeBoatAPI.Colliders.isPointInSphere

        local layers = self.layers
        for iLayer=#self.layers, 1, -1  do
            local layer = self.layers[iLayer]
            local objects = layer.objects
            local zones = layer.zones

            -- remove any completely dead layers
            local numObjects = #objects
            local numZones = #zones

            if runtime == 1 and currentTick % 60 ==0 then
                server.announce("num in layer", tostring(layer.name) .. " -> objs: " .. tostring(numObjects) .. " + zones: " .. tostring(numZones))
            end

            if numZones == 0 and numObjects == 0 then
                server.announce("removing layer", layer.name)
                table.remove(layers, iLayer)
                self.layersByName[layer.name] = nil
            else
                for iObject = numObjects, 1, -1 do
                    local object = objects[iObject]
                    if object.isDisposed or object.isCollisionStopped then
                        object.isCollisionRegistered = false
                        object.isCollisionStopped = false
                        table.remove(objects, iObject)
                        numObjects = numObjects - 1

                        -- we should check for collisions ending here

                    elseif object.lastTickUpdated + object.velocityOffset < currentTick then
                        object:getTransform()
                    end
                end

                for iZone = numZones, 1, -1 do
                    local zone = zones[iZone]
                    if zone.isDisposed or zone.isCollisionStopped then
                        zone.isCollisionRegistered = false
                        zone.isCollisionStopped = false
                        table.remove(zones, iZone)
                        numZones = numZones - 1

                        --check for existing collisions to end

                    elseif zone.parent and zone.parent.lastTickUpdated + zone.parent.velocityOffset < currentTick then
                        zone:getTransform()
                    end
                end

                if numObjects > 0 and numZones > 0 then

                    -- must be objects
                    for iObject = numObjects, 1, -1 do
                        local object = objects[iObject]

                        for iZone = numZones, 1, -1 do -- this kind of nested loop gives me severe heebie jeebies
                            local zone = layer.zones[iZone]
                            if iZone==1 and runtime == 1 and currentTick % 60 == 0 then
                                server.announce("collisionXYZFloor", tostring(zone.collisionXYZFloor) .. " -> objs: " .. tostring(object.collisionXYZFloor) .. " - radius3: " .. tostring(zone.radiusTripled))
                            end

                            local isCollision;
                            -- is concentric rings a terrible idea? (probably)
                            if object.velocityOffset == 59 then -- static (hack)
                                if object.collisionRadius > zone.collisionRadiusMin and object.collisionRadius < zone.collisionRadiusMax then
                                    if zone.savedata.collisionType == "sphere" then
                                        isCollision = isPointInSphere(object.transform, zone.transform, zone.savedata.radius)
                                    else
                                        isCollision = isPointInZone(object.transform, zone.transform, zone.savedata.sizeX, zone.savedata.sizeY, zone.savedata.sizeZ)
                                    end
                                end
                            else -- moving object
                                if (object.collisionRadius > zone.collisionRadiusMin and object.collisionRadius < zone.collisionRadiusMax)
                                or (object.collisionRadiusLast > zone.collisionRadiusMax and object.collisionRadiusLast < zone.collisionRadiusMax)
                                or (object.collisionRadiusLast < zone.collisionRadiusMax and object.collisionRadius > zone.collisionRadiusMax)
                                then
                                    if zone.savedata.collisionType == "sphere" then
                                        isCollision = isLineInSphere(object.lastTransform, object.transform, zone.transform, zone.savedata.radius)
                                    else
                                        isCollision = isLineInZone(object.lastTransform, object.transform, zone.transform, zone.savedata.sizeX, zone.savedata.sizeY, zone.savedata.sizeZ)
                                    end
                                end
                            end
                            
                            if isCollision then
                                if iZone==1 and runtime == 1 and currentTick % 60 == 0 then
                                    server.announce("Collision!", "object: " .. object.id .. " with zone: " .. zone.id)
                                end
                            end
                            -- check if floored x+y+z is within a ballpark; false positives are OK, as long as we eliminate a lot of "just uselessly far away" points
                            if zone.collisionXYZFloor - object.collisionXYZFloor < zone.radiusTripled then -- 500 in every direction

                                --local isCollision;
                                --if zone.savedata.collisionType == "sphere" then
                                --    isCollision = isLineInSphere(object.lastTransform, object.transform, zone.transform, zone.savedata.radius)
                                --else
                                --    isCollision = isLineInZone(object.lastTransform, object.transform, zone.transform, zone.savedata.sizeX, zone.savedata.sizeY, zone.savedata.sizeZ)
                                --end
--
                                --if isCollision == true then
                                --    server.announce("Collision!", "object: " .. object.id .. " with zone: " .. zone.id)
                                --end

                            end
                        end
                    end
                end
            end
        end
    end;
}
 
--                 -- object lastPosition
--                 local Oldx,Oldz = lastPosition[13], lastPosition[15]
--                 local OldSmallx,OldSmallz = math.floor(Oldx * smallReciprocal), math.floor(Oldz * smallReciprocal)
--                 local OldBigx,OldBigz = math.floor(Oldx * bigReciprocal),  math.floor(Oldz * bigReciprocal)
--                 -- does this add too much work for little gain?
                
--                 -- object position
--                 local Newx,Newz = object.transform[13], object.transform[15]
--                 local Smallx, Smallz = math.floor(Newx * smallReciprocal), math.floor(Oldz * smallReciprocal)
--                 local Bigx, Bigz = math.floor(Newx * bigReciprocal),  math.floor(Newz * bigReciprocal)
-- --
--                 -- determine check direction, for the loops below
--                 local xPartitionDirectionSmall = Oldx > Newx and partitionSizeSmall or -partitionSizeSmall
--                 local zPartitionDirectionSmall = Oldz > Newz and partitionSizeSmall or -partitionSizeSmall
--                 local xPartitionDirectionBig = Oldx > Newx and partitionSizeBig or -partitionSizeBig
--                 local zPartitionDirectionBig = Oldz > Newz and partitionSizeBig or -partitionSizeBig

--                 --server.announce("smallx, smallz", tostring(Smallx) .. "," .. tostring(Smallz))
--                 --server.announce("oldSmallX, oldSmallz", tostring(OldSmallx) .. "," .. tostring(OldSmallz))
--                 --server.announce("xPartitionDirectionSmall", tostring(xPartitionDirectionSmall))

--                 ---@type LifeBoatAPI.Zone[][]
--                 local zoneListsToCheck = {}

--                 do  --[[INLINE: Find all relevant zone lists that might contain collisions, based on the partitions we straddle]]
--                     --[[Heavily unrolled code to find the potential collisions, for minor optimization]]
--                     --[[smalls]]
--                     for x=OldSmallx, Smallx, xPartitionDirectionSmall do
--                         for z=OldSmallz, Smallz, zPartitionDirectionSmall do
--                             for iLayer=1, #objsave.collisionLayers do
--                                 local layerName = objsave.collisionLayers[iLayer]
--                                 local layer = layers[layerName]

--                                 if layer == "123123" then
--                                     -- check statics
--                                     local partitionXPart = layer.staticPartitionsSmall[x]
--                                     --server.announce("x", tostring(x) .. " found: " .. tostring(partitionXPart))
--                                     if partitionXPart then
--                                         ---@type LifeBoatAPI.Zone[]
--                                         local zonesInPartition = partitionXPart[z]
--                                         if zonesInPartition then
--                                             -- cleanup in static zone lists
--                                             if #zonesInPartition > 0 then
--                                                 zoneListsToCheck[#zoneListsToCheck+1] = zonesInPartition
--                                             else
--                                                 partitionXPart[z] = nil
--                                             end
--                                         end
--                                     end

--                                     -- check dynamics
--                                     local partitionXPart = layer.dynamicPartitionsSmall[x]
--                                     if partitionXPart then
--                                         ---@type LifeBoatAPI.Zone[]
--                                         local zonesInPartition = partitionXPart[z]
--                                         if zonesInPartition then
--                                             zoneListsToCheck[#zoneListsToCheck+1] = zonesInPartition
--                                         end
--                                     end
--                                 end
--                             end
--                         end
--                     end

--                     --[[bigs]]
--                     for x=OldBigx, Bigx, xPartitionDirectionBig do
--                         for z=OldBigz, Bigz, zPartitionDirectionBig do
--                             for iLayer=1, #objsave.collisionLayers do
--                                 local layerName = objsave.collisionLayers[iLayer]
--                                 local layer = layers[layerName]
--                                 if layer == "123123" then
--                                     -- check statics
--                                     local partitionXPart = layer.staticPartitionsBig[x]
--                                     if partitionXPart then
--                                         ---@type LifeBoatAPI.Zone[]
--                                         local zonesInPartition = partitionXPart[z]
--                                         -- cleanup in static zone lists
--                                         if #zonesInPartition > 0 then
--                                             zoneListsToCheck[#zoneListsToCheck+1] = zonesInPartition
--                                         else
--                                             partitionXPart[z] = nil
--                                         end
--                                     end
--                                     -- check dynamics
--                                     local partitionXPart = layer.dynamicPartitionsBig[x]
--                                     if partitionXPart then
--                                         ---@type LifeBoatAPI.Zone[]
--                                         local zonesInPartition = partitionXPart[z]
--                                         if zonesInPartition then
--                                             zoneListsToCheck[#zoneListsToCheck+1] = zonesInPartition
--                                         end
--                                     end
--                                 end
--                             end
--                         end
--                     end
--                 end

--                 -- continue collision checks, only if we found any potential zones (most objects will NOT be near zones most of the time)
--                 if #zoneListsToCheck > 0 then

--                     -- check collisions with each unique zone we've found
--                     local zonesSeen = {} -- avoid collision checks on the same zone twice
--                     for iZoneList=1, #zoneListsToCheck do
--                         local zonelist = zoneListsToCheck[iZoneList]
--                         for iZone=#zonelist, 1, -1  do
--                             local zone = zonelist[iZone]
--                             local zonesave = zone.savedata
                            
--                             -- check if we were colliding last run; so we can handle onExit appropriately
--                             ---@type LifeBoatAPI.Collision?
--                             local existingCollision = (collisions[zone] and collisions[zone][object]) or nil

--                             -- ensure disposed zones are always cleaned up
--                             if zone.isDisposed then
--                                 table.remove(zonelist, iZone) -- cleanup - shared reference to the actual zone list in the partition; remove it if it's dead

--                             elseif not zonesSeen[zone] then -- only check collisions for zones once each per object
--                                 zonesSeen[zone] = true 

--                                 if not zonesave.isCollisionDisabled then
--                                     -- check for collision
--                                     local isCollision;
--                                     if zonesave.collisionType == "sphere" then
--                                         isCollision = isLineInSphere(object.transform, lastPosition, zone.transform, zonesave.radius)
--                                     else
--                                         isCollision = isLineInZone(object.transform, lastPosition, zone.transform, zonesave.sizeX, zonesave.sizeY, zonesave.sizeZ)
--                                     end

--                                     if isCollision then
--                                         -- record this collision pair for next time we check, to see if the player/object left the zone etc.
--                                         if not existingCollision then
--                                             -- new collision
--                                             local collisionObject = {
--                                                 startTick = LB.ticks.ticks,
--                                                 zone = zone,
--                                                 object = object,
--                                                 onCollisionEnd = LifeBoatAPI.Event:new(),
--                                                 onDispose = LifeBoatAPI.Collision.onDispose
--                                             }
                                            
--                                             -- add to disposables, so we can handle the collision as a lifespan
--                                             --inline: attach
--                                             zone.disposables = zone.disposables or {}
--                                             zone.disposables[#zone.disposables+1] = collisionObject

--                                             --inline: attach
--                                             object.disposables = object.disposables or {}
--                                             object.disposables[#object.disposables+1] = collisionObject

                                            
--                                             collisions[zone] = collisions[zone] or {}
--                                             collisions[zone][object] = collisionObject

--                                             if object.onCollision.hasListeners then
--                                                 object.onCollision:trigger(object, collisionObject, zone)
--                                             end
--                                             if zone.onCollision.hasListeners then
--                                                 zone.onCollision:trigger(zone, collisionObject, object)
--                                             end
--                                         end
--                                     elseif existingCollision  then
--                                         -- no longer colliding
--                                         if existingCollision.onCollisionEnd.hasListeners then
--                                             existingCollision.onCollisionEnd:trigger(existingCollision)
--                                         end

--                                         LifeBoatAPI.lb_dispose(existingCollision)
--                                     end
                                    
--                                 -- if the zone is disabled, or disposed of; and we *were* colliding - we need to handle that exit
--                                 elseif existingCollision then
--                                     if existingCollision.onCollisionEnd.hasListeners then
--                                         existingCollision.onCollisionEnd:trigger(existingCollision)
--                                     end
--                                     -- check if the collider was turned off/killed while an object was inside it
--                                     LifeBoatAPI.lb_dispose(existingCollision)
--                                 end
--                             end
                            
--                         end
--                     end
--                 end -- end of checking collisions on potential collision candidates
