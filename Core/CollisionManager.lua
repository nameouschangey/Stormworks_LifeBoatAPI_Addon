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
---@field staticPartitionsSmall table<number< table<number,LifeBoatAPI.Zone[]>>> 
---@field staticPartitionsBig table<number< table<number,LifeBoatAPI.Zone[]>>>
---@field staticPartitionsMassive table<number< table<number,LifeBoatAPI.Zone[]>>>
---@field dynamicPartitionsSmall table<number< table<number,LifeBoatAPI.Zone[]>>> 
---@field dynamicPartitionsBig table<number< table<number,LifeBoatAPI.Zone[]>>>
---@field dynamicPartitionsMasive table<number< table<number,LifeBoatAPI.Zone[]>>>
---@field dynamicZones LifeBoatAPI.Zone[]
LifeBoatAPI.CollisionLayer = {
    ---@return LifeBoatAPI.CollisionLayer
    new = function(cls)
        return {
            staticPartitionsSmall = {}; -- 100m
            staticPartitionsBig = {}; -- 1000m is the size of a tile, is that going to be really used?
            dynamicPartitionsSmall = {};
            dynamicPartitionsBig = {};
            dynamicPartitionsMassive = {};
            dynamicZones = {};
            objectsOnLayer = 0;
        }
    end;
}

---@class LifeBoatAPI.CollisionManager
---@field layers table<string, LifeBoatAPI.CollisionLayer>
---@field partitionSizeSmall number size of the small partitions, 
---@field partitionSizeBig number
---@field partitionSizeMassive number
---@field collisions table<any, table<LifeBoatAPI.Zone, LifeBoatAPI.Collision>>
---@field objects LifeBoatAPI.GameObject[]
---@field lastObjectPositions table<LifeBoatAPI.GameObject, LifeBoatAPI.Matrix>
---@field tickFrequency number frequency to update collisions, default is 30ticks (twice per second - which is going to be more than enough for 99.9% of cases)
LifeBoatAPI.CollisionManager = {

    ---@param cls LifeBoatAPI.CollisionManager
    ---@return LifeBoatAPI.CollisionManager
    new = function(cls, tickFrequency)
        ---@type LifeBoatAPI.CollisionManager
        local self = {
            layers = {};
            partitionSizeSmall = 100;
            partitionSizeBig = 1000;
            partitionSizeMassive = 10000;
            objects = {};
            collisions = {};
            lastObjectPositions = {};
            tickFrequency = tickFrequency or 30; -- twice per second seems pretty reasonable really. Not sure why you'd need it much higher, especially as we're checking by line

            ---methods
            init = cls.init;
            trackZone = cls.trackZone;
            trackObject = cls.trackObject;
            _onTick = cls._onTick;
            _buildDynamicPartitions = cls._buildDynamicPartitions;
            _storeObjectPositionsForNextTick = cls._storeObjectPositionsForNextTick;
            _removeDeadObjectsAndCalulateActiveLayers = cls._removeDeadObjectsAndCalulateActiveLayers;
            _handleCollisions = cls._handleCollisions;
        }
        return self
    end;

    ---@param self LifeBoatAPI.CollisionManager
    init = function(self)
        LB.ticks:register(self._onTick, self, self.tickFrequency)
    end;

    ---@param self LifeBoatAPI.CollisionManager
    ---@param zone LifeBoatAPI.Zone
    trackZone = function(self, zone)
        local save = zone.savedata

        if not save.collisionLayer then
            return
        end

        self.layers[save.collisionLayer] = self.layers[save.collisionLayer] or LifeBoatAPI.CollisionLayer:new()
        local layer = self.layers[save.collisionLayer]

        -- static zones have no getTransform
        if not zone.getTransform then
            
            local partitions;
            local partitionSize;
            local diameter = save.radius * 2
            if save.overrideIsBig or diameter > self.partitionSizeBig then
                partitionSize = self.partitionSizeMassive
                partitions = layer.staticPartitionsMassive
            elseif save.overrideIsBig or diameter > self.partitionSizeSmall then
                partitionSize = self.partitionSizeBig
                partitions = layer.dynamicPartitionsBig
            else
                partitionSize = self.partitionSizeSmall
                partitions = layer.dynamicPartitionsSmall
            end
            local partitionSizeReciprocal = 1/partitionSize
            local Zx,Zz = zone.transform[13], zone.transform[15]
            local x,z = Zx-((Zx* partitionSizeReciprocal)%1),  (Zz - (Zz * partitionSizeReciprocal)%1)

            -- find if it spills on the x axis
            local iXstart = (Zx-save.radius < x) and (x-partitionSize) or x
            local iXend = (Zx+save.radius > (x+partitionSize)) and (x+partitionSize) or x
            
            -- find if it spills on the z axis
            local iZstart = (Zz-save.radius < z) and (z-partitionSize) or z
            local iZend = (Zz+save.radius > (z+partitionSize)) and (z+partitionSize) or z

            -- add reference to all applicable zones (will be between 1 and at most 4 in 2D)
            -- no need to care about removal, we can do that while iterating later; anytime we end up in a bucket with a dead zone, we can clear it
            -- otherwise, no need at all
            for iX=iXstart, iXend, partitionSize do
                partitions[iX] = partitions[iX] or {}

                for iZ=iZstart, iZend, partitionSize do
                    partitions[iX][iZ] = partitions[iX][iZ] or {}
                    local partition = partitions[iX][iZ]
                    partition[#partition+1] = zone
                end
            end
        else
            layer.dynamicZones[#layer.dynamicZones+1] = zone
        end
    end;

    ---@param self LifeBoatAPI.CollisionManager
    ---@param object LifeBoatAPI.GameObject
    trackObject = function(self, object)
        self.objects[#self.objects+1] = object
    end;

    ---@param listener LifeBoatAPI.ITickable
    _onTick = function(listener)
        ---@type LifeBoatAPI.CollisionManager
        local self = listener.context
        local layersWithObjects = self:_removeDeadObjectsAndCalulateActiveLayers()
        self:_buildDynamicPartitions(layersWithObjects)
        self:_handleCollisions()
        self:_storeObjectPositionsForNextTick()
    end;

    ---@param self LifeBoatAPI.CollisionManager
    _storeObjectPositionsForNextTick = function(self)
        local objects = self.objects
        -- store object positions for next tick
        self.lastObjectPositions = {}
        local lastObjectPositions = self.lastObjectPositions
        for i=1, #objects do
            local object = objects[i]
            lastObjectPositions[object] = object.transform
        end
    end;

    --- Remove any objects that are now disposed
    --- Which in turn, needs to clear layers off that no longer have objects on them - so we don't build dynamic partitions for these
    --- is there a reason to do it this way?
    ---@param self LifeBoatAPI.CollisionManager
    ---@return LifeBoatAPI.CollisionLayer[]
    _removeDeadObjectsAndCalulateActiveLayers = function(self)
        local objects = self.objects
        local layersWithObjects = {}
        local layersWithObjectsSet = {}

        for iObject=#objects, 1, -1 do
            local object = objects[iObject]
            local objsave = object.savedata
            local layerNames = objsave.collisionLayers
            
            if object.isDisposed or not layerNames then
                -- remove from objects list, performance less of a concern as it'll happen infrequently
                table.remove(objects, iObject)
            else
                for iLayerName=1, #layerNames do
                    local layerName = layerNames[iLayerName]
                    if not layersWithObjectsSet[layerName] then
                        layersWithObjectsSet[layerName] = true -- store true, even if there layer doesn't exist, to save checking it again
                        local layer = self.layers[layerName]
                        
                        if layer then
                            layersWithObjects[#layersWithObjects+1] = layer
                        end
                    end
                end
            end
        end

        return layersWithObjects
    end;

    ---@param self LifeBoatAPI.CollisionManager
    ---@param layersWithZones LifeBoatAPI.CollisionLayer[]
    _buildDynamicPartitions = function(self, layersWithZones)
        local currentTick = LB.ticks.ticks

        for iLayer=1, #layersWithZones do
            local layer = layersWithZones[iLayer]
            
            layer.dynamicPartitionsBig = {}
            layer.dynamicPartitionsSmall = {}
            layer.dynamicPartitionsMassive = {}
        
            local dynamicZones = layer.dynamicZones
            local numDynamicZones = #dynamicZones
            if numDynamicZones > 0 then
                -- rebuild the dynamic tree from scratch each time

                for iZone=#dynamicZones, 1, -1 do
                    local zone = dynamicZones[iZone]
                    local zonesave = zone.savedata

                    if zone.isDisposed then
                        table.remove(dynamicZones, iZone)

                    elseif not zonesave.isCollisionDisabled then
                        -- ensure zone is fully updated, as it is "dynamic" and moves
                        if zone.getTransform and zone.lastTickUpdated ~= currentTick then
                            zone:getTransform()
                        end

                        --[[Build Dynamic Paritions for This Layer. Duplicate of addZone (but for dynamic zones)]]
                        local partitions;
                        local partitionSize;
                        local diameter = zonesave.radius * 2
                        if zonesave.overrideIsBig or diameter > self.partitionSizeBig then
                            partitionSize = self.partitionSizeMassive
                            partitions = layer.dynamicPartitionsMassive
                        elseif zonesave.overrideIsBig or diameter > self.partitionSizeSmall then
                            partitionSize = self.partitionSizeBig
                            partitions = layer.dynamicPartitionsBig
                        else
                            partitionSize = self.partitionSizeSmall
                            partitions = layer.dynamicPartitionsSmall
                        end
                        local partitionSizeReciprocal = 1/partitionSize
                        local Zx,Zz = zone.transform[13], zone.transform[15]
                        local x,z = Zx - ((Zx * partitionSizeReciprocal)%1),  (Zz - (Zz * partitionSizeReciprocal)%1)

                        -- find if it spills on the x axis
                        local iXstart = (Zx-zonesave.radius < x) and (x-partitionSize) or x
                        local iXend = (Zx+zonesave.radius > (x+partitionSize)) and (x+partitionSize) or x

                        -- find if it spills on the z axis
                        local iZstart = (Zz-zonesave.radius < z) and (z-partitionSize) or z
                        local iZend = (Zz+zonesave.radius > (z+partitionSize)) and (z+partitionSize) or z

                        -- add reference to all applicable zones (will be between 1 and at most 4 in 2D)
                        for iX=iXstart, iXend, partitionSize do
                            partitions[iX] = partitions[iX] or {}

                            for iZ=iZstart, iZend, partitionSize do
                                partitions[iX][iZ] = partitions[iX][iZ] or {}
                                local partition = partitions[iX][iZ]
                                partition[#partition+1] = zone
                            end
                        end

                    end
                end
            end
        end
    end;
    
    ---@param self LifeBoatAPI.CollisionManager
    _handleCollisions = function(self)
        local collisions = self.collisions

        local objects = self.objects
        local currentTick = LB.ticks.ticks
        local partitionSizeSmall = self.partitionSizeSmall
        local partitionSizeBig = self.partitionSizeBig
        local partitionSizeMassive = self.partitionSizeMassive

        local smallRecirocal = 1/partitionSizeSmall
        local bigReciprocal = 1/partitionSizeBig
        local massiveReciprocal = 1/partitionSizeMassive

        local isLineInZone = LifeBoatAPI.Colliders.isLineInZone
        local isLineInSphere = LifeBoatAPI.Colliders.isLineInSphere

        local layers = self.layers

        for iObject=1, #objects do
            local object = objects[iObject]
            local objsave = object.savedata

            if not objsave.isCollisionDisabled then
                local lastPosition = self.lastObjectPositions[object] or object.transform -- no movement default

                -- make sure position is updated
                -- this is likely the most performance heavy call; as it can end up needing 2 function calls for e.g. players
                if object.getTransform and object.lastTickUpdated ~= currentTick then
                    object:getTransform()
                end

                -- object lastPosition
                local Oldx,Oldz = object.transform[13], object.transform[15]
                local OldSmallx,OldSmallz = Oldx - ((Oldx * smallRecirocal)%1),  (Oldz - (Oldz * smallRecirocal)%1)
                local OldBigx,OldBigz = Oldx - ((Oldx * bigReciprocal)%1),  (Oldz - (Oldz * bigReciprocal)%1)
                local OldMassivex,OldMassivez = Oldx - ((Oldx * massiveReciprocal)%1),  (Oldz - (Oldz * massiveReciprocal)%1)
                -- does this add too much work for little gain?
                
                -- object position
                local Newx,Newz = object.transform[13], object.transform[15]
                local Smallx,Smallz = Newx - ((Newx * smallRecirocal)%1),  (Newz - (Newz * smallRecirocal)%1)
                local Bigx,Bigz = Newx - ((Newx * bigReciprocal)%1),  (Newz - (Newz * bigReciprocal)%1)
                local Massivex,Massivez = Newx - ((Newx * massiveReciprocal)%1),  (Newz - (Newz * massiveReciprocal)%1)

                -- determine check direction, for the loops below
                local xPartitionDirectionSmall = Oldx > Newx and partitionSizeSmall or -partitionSizeSmall
                local zPartitionDirectionSmall = Oldz > Newz and partitionSizeSmall or -partitionSizeSmall
                local xPartitionDirectionBig = Oldx > Newx and partitionSizeBig or -partitionSizeBig
                local zPartitionDirectionBig = Oldz > Newz and partitionSizeBig or -partitionSizeBig
                local xPartitionDirectionMassive = Oldx > Newx and partitionSizeMassive or -partitionSizeMassive
                local zPartitionDirectionMassive = Oldz > Newz and partitionSizeMassive or -partitionSizeMassive

                ---@type LifeBoatAPI.Zone[][]
                local zoneListsToCheck = {}

                do  --[[INLINE: Find all relevant zone lists that might contain collisions, based on the partitions we straddle]]
                    --[[Heavily unrolled code to find the potential collisions, for minor optimization]]

                    --[[smalls]]
                    for x=OldSmallx, Smallx, xPartitionDirectionSmall do
                        for z=OldSmallz, Smallz, zPartitionDirectionSmall do
                            for iLayer=1, #objsave.collisionLayers do
                                local layerName = objsave.collisionLayers[iLayer]
                                local layer = layers[layerName]

                                -- check statics
                                local partitionXPart = layer.staticPartitionsSmall[x]
                                if partitionXPart then
                                    ---@type LifeBoatAPI.Zone[]
                                    local zonesInPartition = partitionXPart[z]
                                    if zonesInPartition then
                                        -- cleanup in static zone lists
                                        if #zonesInPartition > 0 then
                                            zoneListsToCheck[#zoneListsToCheck+1] = zonesInPartition
                                        else
                                            partitionXPart[z] = nil
                                        end
                                    end
                                end

                                -- check dynamics
                                local partitionXPart = layer.dynamicPartitionsSmall[x]
                                if partitionXPart then
                                    ---@type LifeBoatAPI.Zone[]
                                    local zonesInPartition = partitionXPart[z]
                                    if zonesInPartition then
                                        zoneListsToCheck[#zoneListsToCheck+1] = zonesInPartition
                                    end
                                end
                            end
                        end
                    end

                    --[[bigs]]
                    for x=OldBigx, Bigx, xPartitionDirectionBig do
                        for z=OldBigz, Bigz, zPartitionDirectionBig do
                            for iLayer=1, #objsave.collisionLayers do
                                local layerName = objsave.collisionLayers[iLayer]
                                local layer = layers[layerName]
                                -- check statics
                                local partitionXPart = layer.staticPartitionsBig[x]
                                if partitionXPart then
                                    ---@type LifeBoatAPI.Zone[]
                                    local zonesInPartition = partitionXPart[z]
                                    -- cleanup in static zone lists
                                    if #zonesInPartition > 0 then
                                        zoneListsToCheck[#zoneListsToCheck+1] = zonesInPartition
                                    else
                                        partitionXPart[z] = nil
                                    end
                                end

                                -- check dynamics
                                local partitionXPart = layer.dynamicPartitionsBig[x]
                                if partitionXPart then
                                    ---@type LifeBoatAPI.Zone[]
                                    local zonesInPartition = partitionXPart[z]
                                    if zonesInPartition then
                                        zoneListsToCheck[#zoneListsToCheck+1] = zonesInPartition
                                    end
                                end
                            end
                        end
                    end

                    
                    --[[massives]]
                    for x=OldMassivex, Massivex, xPartitionDirectionMassive do
                        for z=OldMassivez, Massivez, zPartitionDirectionMassive do
                            for iLayer=1, #objsave.collisionLayers do
                                local layerName = objsave.collisionLayers[iLayer]
                                local layer = layers[layerName]
                                -- check statics
                                local partitionXPart = layer.staticPartitionsBig[x]
                                if partitionXPart then
                                    ---@type LifeBoatAPI.Zone[]
                                    local zonesInPartition = partitionXPart[z]
                                    -- cleanup in static zone lists
                                    if #zonesInPartition > 0 then
                                        zoneListsToCheck[#zoneListsToCheck+1] = zonesInPartition
                                    else
                                        partitionXPart[z] = nil
                                    end
                                end

                                -- check dynamics
                                local partitionXPart = layer.dynamicPartitionsBig[x]
                                if partitionXPart then
                                    ---@type LifeBoatAPI.Zone[]
                                    local zonesInPartition = partitionXPart[z]
                                    if zonesInPartition then
                                        zoneListsToCheck[#zoneListsToCheck+1] = zonesInPartition
                                    end
                                end
                            end
                        end
                    end
                end

                -- continue collision checks, only if we found any potential zones (most objects will NOT be near zones most of the time)
                if #zoneListsToCheck > 0 then

                    -- check collisions with each unique zone we've found
                    local zonesSeen = {} -- avoid collision checks on the same zone twice
                    for iZoneList=1, #zoneListsToCheck do
                        local zonelist = zoneListsToCheck[iZoneList]
                        for iZone=#zonelist, 1, -1  do
                            local zone = zonelist[iZone]
                            local zonesave = zone.savedata
                            
                            -- check if we were colliding last run; so we can handle onExit appropriately
                            ---@type LifeBoatAPI.Collision?
                            local existingCollision = (collisions[zone] and collisions[zone][object]) or nil

                            -- ensure disposed zones are always cleaned up
                            if zone.isDisposed then
                                table.remove(zonelist, iZone) -- cleanup - shared reference to the actual zone list in the partition; remove it if it's dead

                            elseif not zonesSeen[zone] then -- only check collisions for zones once each per object
                                zonesSeen[zone] = true 

                                if not zonesave.isCollisionDisabled then
                                    -- check for collision
                                    local isCollision;
                                    if zonesave.collisionType == "sphere" then
                                        isCollision = isLineInSphere(object.transform, lastPosition, zone.transform, zonesave.radius)
                                    else
                                        isCollision = isLineInZone(object.transform, lastPosition, zone.transform, zonesave.sizeX, zonesave.sizeY, zonesave.sizeZ)
                                    end

                                    if isCollision then
                                        -- record this collision pair for next time we check, to see if the player/object left the zone etc.
                                        if not existingCollision then
                                            -- new collision
                                            local collisionObject = {
                                                startTick = LB.ticks.ticks,
                                                zone = zone,
                                                object = object,
                                                onCollisionEnd = LifeBoatAPI.Event:new(),
                                                onDispose = LifeBoatAPI.Collision.onDispose
                                            }
                                            
                                            -- add to disposables, so we can handle the collision as a lifespan
                                            --inline: attach
                                            zone.disposables = zone.disposables or {}
                                            zone.disposables[#zone.disposables+1] = collisionObject

                                            --inline: attach
                                            object.disposables = object.disposables or {}
                                            object.disposables[#object.disposables+1] = collisionObject

                                            
                                            collisions[zone] = collisions[zone] or {}
                                            collisions[zone][object] = collisionObject

                                            if object.onCollision.hasListeners then
                                                object.onCollision:trigger(object, collisionObject, zone)
                                            end
                                            if zone.onCollision.hasListeners then
                                                zone.onCollision:trigger(zone, collisionObject, object)
                                            end
                                        end
                                    elseif existingCollision  then
                                        -- no longer colliding
                                        if existingCollision.onCollisionEnd.hasListeners then
                                            existingCollision.onCollisionEnd:trigger(existingCollision)
                                        end

                                        LifeBoatAPI.lb_dispose(existingCollision)
                                    end
                                    
                                -- if the zone is disabled, or disposed of; and we *were* colliding - we need to handle that exit
                                elseif existingCollision then
                                    if existingCollision.onCollisionEnd.hasListeners then
                                        existingCollision.onCollisionEnd:trigger(existingCollision)
                                    end
                                    -- check if the collider was turned off/killed while an object was inside it
                                    LifeBoatAPI.lb_dispose(existingCollision)
                                end
                            end
                            
                        end
                    end
                end -- end of checking collisions on potential collision candidates
            end
        end -- end of object loop
    end;
}