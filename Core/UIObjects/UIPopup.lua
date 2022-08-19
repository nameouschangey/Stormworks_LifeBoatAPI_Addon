-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


---@class LifeBoatAPI.UIElement : LifeBoatAPI.IDisposable
---@field savedata table
---@field id number uiID
---@field isPopup boolean
LifeBoatAPI.UIPopup = {
    fromSavedata = function(cls, savedata, isTemporary)
        local self = {
            savedata = savedata,
            id = savedata.id,

            -- methods
            despawn = LifeBoatAPI.lb_dispose,
            setVisible = cls.setVisible,
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

    new = function(cls, player, text, x, y, z, renderDistance, parent, isTemporary)
        local obj = cls:fromSavedata({
            id = server.getMapID(),
            type = "popup",
            steamID = player and player.steamID or "all",
            x = x,
            y = y,
            z = z,
            text = text,
            renderDistance = renderDistance,
            parentID = parent and parent.id,
            parentType = parent and parent.type,
        })

        if not isTemporary then
            LB.ui:trackEntity(obj)
        end

        return obj
    end;

    ---@param self LifeBoatAPI.UIElement
    ---@param peerID number
    show = function(self, peerID)
        local save = self.savedata

        if save.parentID then
            server.setPopup(peerID, save.id, nil, true, save.text, save.x, save.y, save.z, save.renderDistance, save.parentType == "vehicle" and save.parentID or nil, save.parentType ~= "vehicle" and save.parentID or nil)
        else
            server.setPopup(peerID, save.id, nil, true, save.text, save.x, save.y, save.z, save.renderDistance, nil, nil)
        end
    end;

    ---@param self LifeBoatAPI.UIElement
    onDispose = function(self)
        server.removePopup(-1, self.id)
        LB.ui:stopTracking(self)
    end;
}
