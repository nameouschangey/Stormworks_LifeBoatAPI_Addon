-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class LifeBoatAPI.UIMapLabel : LifeBoatAPI.UIElement
LifeBoatAPI.UIMapLabel = {
    ---@param cls LifeBoatAPI.UIMapLabel
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

    new = function(cls, player, labelType, name, x, z, isTemporary)
        local obj = cls:fromSavedata({
            id = server.getMapID(),
            type = "maplabel",
            steamID = player and player.steamID or "all",
            labelType = labelType,
            name = name,
            x = x,
            z = z
        })

        if not isTemporary then
            LB.ui:trackEntity(obj)
        end

        obj:show(player and player.id or -1)

        return obj
    end;

    ---@param self LifeBoatAPI.UIElement
    show = function(self, peerID)
        local save = self.savedata
        server.addMapLabel(peerID, self.id, save.labelType, save.name, save.x, save.z)
    end;

    ---@param self LifeBoatAPI.UIElement
    onDispose = function(self)
        server.removeMapLabel(-1, self.id)
        LB.ui:stopTracking(self)
    end;
}