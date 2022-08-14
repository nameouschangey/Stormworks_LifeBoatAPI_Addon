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
LifeBoatAPI.UIMapLine = {
    fromSavedata = function(cls, savedata)
        local self = {
            savedata = savedata,
            id = savedata.id,

            -- methods
            despawn = LifeBoatAPI.lb_dispose,
            show = cls.show,
            onDispose = cls.onDispose
        }
        return self
    end;

    new = function(cls, player, startMatrix, endMatrix, width, isTemporary)
        local obj = cls:fromSavedata({
            id = server.getMapID(),
            type = "mapline",
            steamID = player and player.steamID or "all",
            startMatrix = startMatrix,
            endMatrix = endMatrix,
            width = width,
        })
        
        if not isTemporary then
            LB.ui:trackEntity(obj)
        end

        obj:show(player and player.id or -1)

        return obj
    end;

    ---@param self LifeBoatAPI.UIElement
    ---@param peerID number
    show = function(self, peerID)
        local save = self.savedata
        server.addMapLine(peerID, save.id, save.startMatrix, save.endMatrix, save.width)
    end;

    ---@param self LifeBoatAPI.UIElement
    onDispose = function(self)
        server.removeMapLine(-1, self.id)
        LB.ui:stopTracking(self)
    end;
}
