-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


---@class LifeBoatAPI.UIScreenPopup : LifeBoatAPI.UIElement
---@field savedata table
---@field id number uiID
---@field isPopup boolean
LifeBoatAPI.UIScreenPopup = {

    ---@return LifeBoatAPI.UIScreenPopup
    fromSavedata = function(cls, savedata, isTemporary)
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

    ---@param isTemporary boolean if true, this will not persist between reload_scripts
    ---@param player LifeBoatAPI.Player|nil nil displays to all players
    ---@return LifeBoatAPI.UIScreenPopup
    new = function(cls, player, text, screenX, screenY, isTemporary)
        local obj = cls:fromSavedata({
            id = server.getMapID(),
            type = "screenpopup",
            steamID = player and player.steamID or "all",
            screenX = screenX,
            screenY = screenY,
            text = text
        })

        if not isTemporary then
            LB.ui:trackEntity(obj)
        end

        return obj
    end;

    ---@param self LifeBoatAPI.UIElement
    ---@param peerID number true => display, false => hide
    show = function(self, peerID)
        local save = self.savedata
        server.setPopupScreen(peerID, save.id, nil, true, save.text, save.screenX, save.screenY)
    end;

    ---@param self LifeBoatAPI.UIElement
    onDispose = function(self)
        server.removePopup(-1, self.id)
        LB.ui:stopTracking(self)
    end;
}
