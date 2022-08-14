

---Global instance of the LifeBoatAPI
---Use LB.member for "live" managers etc.
---Use LifeBoatAPI.member for static types
---@class LifeBoatAPI.LB
---@field ticks LifeBoatAPI.TickManager
---@field collision LifeBoatAPI.CollisionManager
---@field players LifeBoatAPI.PlayerManager
---@field events LifeBoatAPI.EventManager
---@field addons LifeBoatAPI.AddonManager
---@field objects LifeBoatAPI.ObjectManager
---@field ui LifeBoatAPI.UIManager
---@field savedata table
LifeBoatAPI.LB = {

    ---@param cls LifeBoatAPI.LB
    ---@return LifeBoatAPI.LB
    new = function(cls)
        ---@type LifeBoatAPI.LB
        local self = {
        }

        self.collision = LifeBoatAPI.CollisionManager:new(); -- fair, specific purpose
        self.players = LifeBoatAPI.PlayerManager:new();
        self.events = LifeBoatAPI.EventManager:new(); -- necessary? yes (using events multiple places in coroutines etc.)
        self.ticks = LifeBoatAPI.TickManager:new();
        self.addons = LifeBoatAPI.AddonMananger:new();
        self.objects = LifeBoatAPI.ObjectManager:new();
        self.ui = LifeBoatAPI.UIManager:new();
        return self
    end;

    ---@param self LifeBoatAPI.LB
    init = function(self)
        self.savedata = g_savedata
        self.events:init()
        self.ticks:init()
        self.collision:init()
        self.addons:init()
        self.players:init()
        self.objects:init()
        self.ui:init()
    end;
}

LB = LifeBoatAPI.LB:new()

--[[
    -- how to use:
    onInit = function()
        LB:init()
    end
]]