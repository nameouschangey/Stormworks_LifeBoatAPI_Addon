


-- Manager for handling UI popups/map markers
-- Ensures those meant for all players, are added whenever a player connects
-- Ensures those meant for a single player, are added when that player re-connects etc.
-- Provides a smooth way to handle basic popups
---@class LifeBoatAPI.UIManager
---@field savedata table
---@field uiByID table<number, LifeBoatAPI.UIElement>
---@field uiBySteamID table<string, LifeBoatAPI.UIElement[]>
LifeBoatAPI.UIManager = {
    ---@param cls LifeBoatAPI.UIManager
    new = function(cls)
        local self = {
            savedata = {
                uiByID = {}, -- id : savedata
                temporaryUIIDs = {} -- list of ids to be killed when re-starting the server, as these are all temporary
            };
            uiByID = {}; -- id: object
            uiBySteamID = { -- id: object[]
                all = {}
            };

            --- methods
            init = cls.init,
            trackEntity = cls.trackEntity,
            stopTracking = cls.stopTracking,
            getUIByID = cls.getUIByID,
            getUIBySteamID = cls.getUIBySteamID,
            _onPlayerJoin = cls._onPlayerJoin
        }

        return self
    end;

    ---@param self LifeBoatAPI.UIManager
    init = function(self)
        g_savedata.uiManager = g_savedata.uiManager or self.savedata
        self.savedata = g_savedata.uiManager

        -- kill all temporaryIDs that shouldn't exist anymore
        -- prevents UI duplicates between reload_scripts
        server.announce("removing ui", tostring(#self.savedata.temporaryUIIDs))
        for i=1, #self.savedata.temporaryUIIDs do
            local uiID = self.savedata.temporaryUIIDs[i]
            server.removePopup(-1, uiID)
            server.removeMapID(-1, uiID)
        end
        self.savedata.temporaryUIIDs = {}

        -- load all elements (note: only very popular, long running servers - potentially for data leak, due to UI that never gets seen again, by players who never return)
        for id, elementSave in pairs(self.savedata.uiByID) do
            local element;
            if elementSave.type == "maplabel" then
                element = LifeBoatAPI.UIMapLabel:fromSavedata(elementSave)
            elseif elementSave.type == "mapline" then
                element = LifeBoatAPI.UIMapLine:fromSavedata(elementSave)
            elseif elementSave.type == "mapobject" then
                element = LifeBoatAPI.UIMapObject:fromSavedata(elementSave)
            elseif elementSave.type == "popup" then
                element = LifeBoatAPI.UIPopup:fromSavedata(elementSave)
            elseif elementSave.type == "screenpopup" then
                element = LifeBoatAPI.UIScreenPopup:fromSavedata(elementSave)
            elseif elementSave.type == "mapcollection" then
                element = LifeBoatAPI.UIMapCollection:fromSavedata(elementSave)
                element:beginDisplaying()
            elseif elementSave.type == "popuprelative" then
                element = LifeBoatAPI.UIPopupRelativePos:fromSavedata(elementSave)
            end

            if element and not element.isDisposed then
                self.uiByID[element.id] = element

                local steamID = element.savedata.steamID
                self.uiBySteamID[steamID] = self.uiBySteamID[steamID] or {}
                self.uiBySteamID[steamID][#self.uiBySteamID[steamID]+1] = element
            end
        end

        -- register for new players connecting
        LB.players.onPlayerConnected:register(self._onPlayerJoin, self)
    end;

    _onPlayerJoin = function(l, self, player)
        -- when the player joins, give them all the UI they are entitled to
        -- this will generally be used for when you want popups to display for all players
        local uiForAll = self.uiBySteamID["all"]
        for i=1, #uiForAll do
            local ui = uiForAll[i]
            ui:show(player.id)
        end

        local uiBySteamID = self.uiBySteamID[player.steamID] or {}
        for i=1, #uiBySteamID do
            local ui = uiBySteamID[i]
            ui:show(player.id)
        end
    end;

    --- Tracks this entity, so that it exists "permanently"
    ---@param self LifeBoatAPI.UIManager
    ---@param uiElement LifeBoatAPI.UIElement
    trackEntity = function(self, uiElement)
        if uiElement.isDisposed then
            return 
        end

        -- temporary elements are stored separately, so we can safely remove them next reload
        if uiElement.savedata.isTemporary then
            self.savedata.temporaryUIIDs[#self.savedata.temporaryUIIDs+1] = uiElement.id
        else
            self.savedata.uiByID[uiElement.id] = uiElement.savedata
        end

        self.uiByID[uiElement.id] = uiElement
        self.uiBySteamID[uiElement.savedata.steamID] = uiElement
    end;

    ---@param self LifeBoatAPI.UIManager
    ---@param uiElement LifeBoatAPI.UIElement
    stopTracking = function(self, uiElement)
        self.savedata.uiByID[uiElement.id] = nil
        self.uiByID[uiElement.id] = nil
        self.uiBySteamID[uiElement.savedata.steamID] = nil
    end;

    ---@param self LifeBoatAPI.UIManager
    ---@param uiID number
    ---@return LifeBoatAPI.UIElement
    getUIByID = function(self, uiID)
        return self.uiByID[uiID]
    end;

    ---@param self LifeBoatAPI.UIManager
    ---@param steamID string
    ---@return LifeBoatAPI.UIElement[]
    getUIBySteamID = function(self, steamID)
        return self.uiBySteamID[steamID] or {}
    end;
}
