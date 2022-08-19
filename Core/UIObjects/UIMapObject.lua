-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


---@class LifeBoatAPI.UIMapObject : LifeBoatAPI.UIElement
---@field savedata table
---@field id number uiID
---@field isPopup boolean
LifeBoatAPI.UIMapObject = {
    ---@return LifeBoatAPI.UIMapObject
    fromSavedata = function(cls, savedata)
        local self = {
            savedata = savedata,
            id = savedata.id,

            -- methods
            despawn = LifeBoatAPI.lb_dispose,
            show = cls.show,
            onDispose = cls.onDispose
        }

        if savedata.parentID then
            local parent = LB.objects:getByType(savedata.parentType, savedata.parentID)
            if parent then
                parent:attach(self)
            else
                LifeBoatAPI.lb_dispose(self)
            end
        end

        return self
    end;

    ---@return LifeBoatAPI.UIMapObject
    new = function(cls, player, positionType, markerType, x, z, radius, label, hoverLabel, parent, isTemporary)
        local obj = cls:fromSavedata({
            id = server.getMapID(),
            type = "mapobject",
            steamID = player and player.steamID or "all",
            positionType = positionType,
            markerType = markerType,
            x = x,
            z = z, 
            parentType = parent and parent.type,
            parentID = parent and parent.id,
            label = label,
            radius = radius,
            hoverLabel = hoverLabel
        })

        if not isTemporary then
            LB.ui:trackEntity(obj)
        end

        return obj
    end;

    ---@param self LifeBoatAPI.UIMapObject
    ---@param peerID number
    show = function(self, peerID)
        local save = self.savedata

        if save.parentID then
            server.addMapObject(peerID, save.id, save.positionType, save.markerType, nil, nil, save.x, save.z, save.parentType == "vehicle" and save.parentID or nil, save.parentType ~= "vehicle" and save.parentID or nil, save.label, save.radius, save.hoverLabel)
        else
            server.addMapObject(peerID, save.id, save.positionType, save.markerType, save.x, save.z, nil, nil, nil, nil, save.label, save.radius, save.hoverLabel)
        end
    end;

    ---@param self LifeBoatAPI.UIMapObject
    onDispose = function(self)
        server.removeMapObject(-1, self.id)
        LB.ui:stopTracking(self)
    end;
}
