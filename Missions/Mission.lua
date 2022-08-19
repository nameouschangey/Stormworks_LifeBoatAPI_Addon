-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@section Mission


-- not 100% confident that this does what we want
-- does it self-init? or only on mission:start()?


---@class LifeBoatAPI.Mission
---@field cr LifeBoatAPI.Coroutine
---@field savedata table
---@field name string
---@field stages LifeBoatAPI.Mission[]
---@field onInit function
---@field onCleanup function
---@field parentSaveData table
---@field parent LifeBoatAPI.Mission
---@field onComplete LifeBoatAPI.Event
---@field isInitialized boolean
---@field current number
LifeBoatAPI.Mission = {
    ---@param cls LifeBoatAPI.Mission
    ---@param name string unique name for this mission part, used in g_savedata
    ---@param onInit fun(self:LifeBoatAPI.Mission)
    ---@param onCleanup fun(self:LifeBoatAPI.Mission)
    ---@param parentSaveData table|nil (default: g_savedata) Allows for non-global missions, provide any persistence table as the parent of this mission (e.g. player save-data for per-player missions etc.)
    ---@param parent LifeBoatAPI.Mission|nil (default: nil) if you're setting this, you'll likely be better using mission:addStage() instead
    ---@return LifeBoatAPI.Mission
    new = function(cls, name, onInit, onCleanup, parentSaveData, parent)
        local self = {
            parentSaveData = parentSaveData;
            parent = parent;
            name = name; -- "BrothersInBeer:GatheringIngredients";
            cr = LifeBoatAPI.Coroutine:start();
            stages = {};
            current = 1;
            onComplete = LifeBoatAPI.Event:new();
            isInitialized = false;

            --- methods
            start = cls.start;
            next = cls.next;
            onInit = onInit;
            onCleanup = onCleanup;
        }

        -- improve the onComplete await function, to take into account savedata/isComplete
        self.onComplete.await = function(event)
            local cr = LifeBoatAPI.Coroutine:start(nil, true)
            if self.savedata and self.savedata.isComplete then
                cr:trigger()
            else
                self.onComplete:register(function(l)
                    l.isDisposed = true
                    cr:trigger()
                end, nil, 1)
            end
            return cr
        end

        return self
    end;

    ---@param self LifeBoatAPI.Mission
    ---@param name string unique name for this mission part, used in g_savedata
    ---@param init fun(self:LifeBoatAPI.Mission)
    ---@param cleanup fun(self:LifeBoatAPI.Mission)
    addStage = function(self, name, init, cleanup)
        local mission = LifeBoatAPI.Mission:new(name, init, cleanup, nil, self)
        self.stages[#self.stages+1] = mission
        return mission
    end;

    ---@param self LifeBoatAPI.Mission
    ---@param nextStage number|nil stage to go to, or nil for the next one
    next = function(self, nextStage)
        nextStage = nextStage or (self.current + 1)

        local stage = self.stages[self.current]
        if not stage.savedata.isComplete then
            stage:complete()
        end

        stage = self.stages[nextStage]

        if stage then
            stage:start()
        else
            self:complete()
        end
    end;

    ---@param self LifeBoatAPI.Mission
    start = function(self)
        -- get savedata from parent, or global if not provided
        if self.parent then
            self.parent.savedata[self.name] = self.parent.savedata[self.name] or {
                stage = 1
            }
            self.savedata = self.parent.savedata[self.name]

        elseif self.parentSaveData then
            self.parentSaveData[self.name] = self.parentSaveData[self.name] or {
                stage = 1
            }
            self.savedata = self.parentSaveData[self.name]
            
        else
            g_savedata.lb_missions = g_savedata.lb_missions or {}
            g_savedata.lb_missions[self.name] = g_savedata.lb_missions[self.name] or {
                stage = 1
            }
            self.savedata = g_savedata.lb_missions[self.name]
        end

        if self.savedata.isComplete then
            self:complete()
            return    
        end

        self:onInit()
        self.isInitialized = true
        self.stages[self.current]:start()
    end;

    ---@param self LifeBoatAPI.Mission
    complete = function(self)
        self.savedata.isComplete = true

        if self.onComplete.hasListeners then
            self.onComplete:trigger(self)
        end

        if self.isInitialized and self.onCleanup then
            self:onCleanup()
            self.isInitialized = false
        end

        if self.parent then
            self.parent:next()
        end
    end
}

---@endsection