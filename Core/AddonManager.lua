-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


-- Provides a simple way to spawn all the assets associated with a specific addon
---@class LifeBoatAPI.AddonManager
---@field this LifeBoatAPI.Addon
---@field addons LifeBoatAPI.Addon[]
---@field addonsByName table<string, LifeBoatAPI.Addon>
LifeBoatAPI.AddonManager = {
    ---@param cls LifeBoatAPI.AddonManager
    ---@return LifeBoatAPI.AddonManager
    new = function(cls)
        local self = {
            this = nil;
            addons = {};
            addonsByName = {};
            scripts = {};

            --- methods
            init = cls.init,
            loadOtherAddons = cls.loadOtherAddons
        }

        return self
    end;

    ---@param self LifeBoatAPI.AddonManager
    init = function(self)
        -- addon indexes start at 0
        local numberOfAddons = server.getAddonCount()
        for i=0, numberOfAddons-1 do
            local addonData = server.getAddonData(i)
            local addon = LifeBoatAPI.Addon:new(i, addonData)
            self.addons[#self.addons+1] = addon
            self.addonsByName[addon.name] = addon
        end

        local thisIndex = server.getAddonIndex() + 1
        self.this = self.addons[thisIndex]
        self.this:load()
    end;

    -- by default, not loaded; as 99% of addons won't care or need to know
    ---@param self LifeBoatAPI.AddonManager
    loadOtherAddons = function(self)
        local thisAddon = self.this
        for i=1, #self.addons do
            local addon = self.addons[i]
            if addon ~= thisAddon then
                addon:load()
            end
        end
    end;
}

---@class LifeBoatAPI.Addon
---@field rawdata SWAddonData
---@field name string
---@field index number
---@field locations LifeBoatAPI.AddonLocation[]
---@field locationsByName table<string, LifeBoatAPI.AddonLocation>
---@field componentsByID LifeBoatAPI.AddonComponent global lists of components in this addon, by id
---@field isLoaded boolean prevent loading the same component twice
LifeBoatAPI.Addon = {
    ---@param addonData SWAddonData
    ---@return LifeBoatAPI.Addon
    new = function(cls, index, addonData)
        return {
            rawdata = addonData,
            name = addonData.name,
            index = index;
            locations = {};
            locationsByName = {};
            componentsByID = {};
            isLoaded = false;

            --methods
            load = cls.load
        }
    end;

    ---@param self LifeBoatAPI.Addon
    load = function(self)
        if not self.isLoaded then
            self.isLoaded = true

            -- addon location indexes start at 0
            for i=0, self.rawdata.location_count-1 do
                local locationData = server.getLocationData(self.index, i)
                local location = LifeBoatAPI.AddonLocation:new(self, i, locationData)
                self.locations[#self.locations+1] = location
                self.locationsByName[locationData.name] = location

                for iComponent=1, #location.components do
                    local component = location.components[iComponent]
                    self.componentsByID[component.index] = component
                end
            end
        end
    end;
}

---@class LifeBoatAPI.AddonLocation
---@field components LifeBoatAPI.AddonComponent[]
---@field componentsByID table<string, LifeBoatAPI.AddonComponent>
---@field addon LifeBoatAPI.Addon
---@field rawdata SWLocationData
---@field index number
LifeBoatAPI.AddonLocation = {
    ---@param cls LifeBoatAPI.AddonLocation
    ---@param locationData SWLocationData
    ---@param parent LifeBoatAPI.Addon
    ---@return LifeBoatAPI.AddonLocation
    new = function(cls, parent, index, locationData)
        local self = {
            addon = parent,
            index = index,
            rawdata = locationData,
            components = {};
            componentsByID = {};
            componentsByName = {};

            firesByName = {};
            zonesByName = {};
            vehiclesByName = {};
            objectsByName = {};

            --methods
            spawnAll = cls.spawnAll;
            spawnAllRelativeToPosition = cls.spawnAllRelativeToPosition;
        }

        -- component index starts at 0
        for i=0, locationData.component_count-1 do
            local componentData = server.getLocationComponentData(self.addon.index, self.index, i)
            local component = LifeBoatAPI.AddonComponent:new(self, i, componentData)

            -- manage parented items
            self.componentsByID[componentData.id] = component -- this ID is actually the spawned ID though isn't it?
            self.components[#self.components+1] = component

            if componentData.display_name ~= "" then
                self.componentsByName[componentData.display_name] = component
            end
        end

        return self
    end;

    ---Spawn the location exactly as it is in the editor
    ---@param self LifeBoatAPI.AddonLocation
    ---@param closestToMatrix LifeBoatAPI.Matrix|nil (optional) default is 0,0,0. some tiles can be represented multiple times, such as ocean or small islands - this determines the search start for the closest one
    ---@return LifeBoatAPI.GameObject[] spawned
    spawnAll = function(self, closestToMatrix)
        closestToMatrix = closestToMatrix or LifeBoatAPI.Matrix:newMatrix()
        local tileMatrix, success = server.getTileTransform(closestToMatrix, self.rawdata.tile, 50000)

        if not success then
            return {}
        end

        local spawned = {}
        for i=1, #self.components do
            local component = self.components[i]
            spawned[#spawned +1] = component:spawnRelativeToPosition(tileMatrix)
        end
        return spawned
    end;

    ---@param self LifeBoatAPI.AddonLocation
    ---@param position LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.GameObject[]
    spawnAllRelativeToPosition = function(self, position)
        local spawned = {}
        for i=1, #self.components do
            local component = self.components[i]
            spawned[#spawned+1] = component:spawnRelativeToPosition(position)
        end
        return spawned
    end;
}

---@class LifeBoatAPI.AddonComponent
---@field index number
---@field location LifeBoatAPI.AddonLocation
---@field rawdata SWAddonComponentData
---@field tags table<string,string> -- or table<number,string> where no specific key was given (iterate for flags, use key names for tags)
---@field children LifeBoatAPI.AddonComponent[]
LifeBoatAPI.AddonComponent = {

    ---@param cls LifeBoatAPI.AddonComponent
    ---@param componentData SWAddonComponentData
    ---@return LifeBoatAPI.AddonComponent 
    new = function(cls, location, index, componentData)
        local self = {
            index = index;
            location = location;
            rawdata = componentData;
            tags = {};

            --methods
            parseSequentialTag = cls.parseSequentialTag;
            spawnRelativeToPosition = cls.spawnRelativeToPosition;
            spawnAtPosition = cls.spawnAtPosition;
            spawn = cls.spawn
        }

        -- parse tags delimited by ";" and "," (a=b) => ["a"] = "b", and (a) => ["a"]=true
        local rawtags = self.rawdata.tags_full
        local tags = self.tags
        for tagbase in string.gmatch(rawtags, "%s*([^;,]*%w+)%s*[;,]?") do

            local wasKeyVal = false
            -- if it was a key-value pair a = b, then add to the key:value pairs, otherwise add as a iterable "flag"
            for key,value in string.gmatch(tagbase, "([^;,]*%w+)%s*=%s*([^;,]*%w+)") do
                tags[key] = value
                wasKeyVal = true
            end

            if not wasKeyVal then
                tags[tagbase] = true; 
            end
        end

        return self
    end;

    ---@param self LifeBoatAPI.AddonComponent
    ---@return string[]|nil
    parseSequentialTag = function(self, tagBase)
        local sequence = {}

        -- potentially first named collision layer
        local baseTag = self.tags[tagBase]
        if baseTag then
            sequence[#sequence+1] = baseTag
        end

        -- find numbered following tags (e.g. a1=1, a2=1, a3=1)
        local i=1
        while true do
            local tag = self.tags[tagBase .. i]
            if tag then
                sequence[#sequence+1] = tag
            else
                break
            end
        end

        if #sequence > 0 then
            return sequence
        else
            return nil
        end
    end;

    ---@param self LifeBoatAPI.AddonComponent
    ---@param relativePosition LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.GameObject|nil
    spawnRelativeToPosition = function(self, relativePosition)
        return self:spawn(LifeBoatAPI.Matrix.multiplyMatrix(relativePosition, self.rawdata.transform))
    end;

    ---@param self LifeBoatAPI.AddonComponent
    ---@param position LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.GameObject|nil
    spawnAtPosition = function(self, position)
        return self:spawn(position)
    end;

    ---@param self LifeBoatAPI.AddonComponent
    ---@param matrix LifeBoatAPI.Matrix (optional) if not provided, uses the preset matrix from the editor
    ---@param parent LifeBoatAPI.GameObject|nil
    ---@return LifeBoatAPI.GameObject|nil
    spawn = function(self, matrix, parent)

        local spawnedData, success =  server.spawnAddonComponent(matrix, self.location.addon.index, self.location.index, self.index)
        if success then
            spawnedData.betterTags = self.tags

            ---@type LifeBoatAPI.GameObject
            local entity;
            if spawnedData.type == 0        -- zone
            or spawnedData.type == 10 then  -- cargo_zone (deprecated)
                entity = LifeBoatAPI.Zone:fromAddonSpawn(self, spawnedData, parent)

            elseif spawnedData.type == 2 then -- npc/character
                entity = LifeBoatAPI.Object:fromAddonSpawn(self, spawnedData)

            elseif spawnedData.type == 3 then -- vehicle
                entity = LifeBoatAPI.Vehicle:fromAddonSpawn(self, spawnedData)

            elseif spawnedData.type == 5 then -- fire
                entity = LifeBoatAPI.Fire:fromAddonSpawn(self, spawnedData, parent)
                
            -- regular objects
            elseif spawnedData.type == 1    -- small objects 
            or spawnedData.type == 4        -- flare
            or spawnedData.type == 6        -- loot
            or spawnedData.type == 7        -- button
            or spawnedData.type == 8        -- animal
            or spawnedData.type == 9 then   -- ice
                entity = LifeBoatAPI.Object:fromAddonSpawn(self, spawnedData)
            end

            -- spawn children, at relative positions
            for i=1, #self.children do
                -- is this how we want to do it? (yes)
                local child = self.children[i]
                child:spawn(LifeBoatAPI.Matrix.multiplyMatrix(matrix, child.rawdata.transform), entity)
            end

            return entity
        end
        return nil
    end;
}