


-- Manager for handling UI popups/map markers
-- Ensures those meant for all players, are added whenever a player connects
-- Ensures those meant for a single player, are added when that player re-connects etc.
-- Provides a smooth way to handle basic popups
---@class LifeBoatAPI.UIManager
---@field savedata table
---@field uiByID table<number, LifeBoatAPI.UIElement>
---@field uiBySteamID table<string, LifeBoatAPI.UIElement[]>
---@field onInitScripts table<string, fun(obj:LifeBoatAPI.GameObject)>
---@field enableVehicleCallbacks boolean
---@field enableVehicleDamageCallback boolean
LifeBoatAPI.UIManager = {
    ---@param cls LifeBoatAPI.UIManager
    new = function(cls)
        local self = {
            savedata = {
                uiByID = {} -- id : savedata
            };
            uiByID = {}; -- id: object
            uiBySteamID = { -- id: object[]
                all = {}
            };
        }

        return self
    end;

    ---@param self LifeBoatAPI.UIManager
    init = function(self)
        g_savedata.uiManager = g_savedata.uiManager or self.savedata
        self.uiManager = g_savedata.uiManager

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
            end

            if element and not element.isDisposed then
                self.uiByID[element.id] = element

                local steamID = element.savedata.steamID
                self.uiBySteamID[steamID] = self.uiBySteamID[steamID] or {}
                self.uiBySteamID[steamID][#self.uiBySteamID[steamID]+1] = element
            end
        end

        -- load and show all "-1" everybody UI elements
        local uiForAll = self.uiBySteamID["all"]
        for i=1, #uiForAll do
            local ui = uiForAll[i]
            ui:show(-1)
        end

        -- handle each player's individual UI by steamID
        for iPlayer=1, #LB.players.players do
            local player = LB.players.players[iPlayer]
            local uiBySteamID = self.uiBySteamID[player.steamID] or {}
            for iUI=1, #uiBySteamID do
                local ui = uiBySteamID[iUI]
                ui:show(player.id)
            end
        end

        -- register for new players connecting
        LB.players.onPlayerConnected:register(self._onPlayerJoin, self)
    end;

    _onPlayerJoin = function(l, self, player)
        -- do we want to load everything?
        -- the plus side, is easier to do
        -- the downside, is stuff that relies only on a certain player is not good
        -- but then it's really hard to dispose of stuff that's no longer wanted if it happens while the player is offline
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

    ---@param self LifeBoatAPI.UIManager
    ---@param uiElement LifeBoatAPI.UIElement
    trackEntity = function(self, uiElement)
        if uiElement.isDisposed then
            return 
        end

        self.savedata.uiByID[uiElement.id] = uiElement.savedata
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
