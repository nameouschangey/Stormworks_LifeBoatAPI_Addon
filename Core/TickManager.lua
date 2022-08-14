
---@alias LifeBoatAPI.ITickableFunc fun(listener:LifeBoatAPI.ITickable, deltaGameTicks:number)

---@class LifeBoatAPI.ITickable : LifeBoatAPI.IDisposable
---@field tickFrequency number
---@field nextTick number
---@field onExecute LifeBoatAPI.ITickableFunc
---@field isPaused boolean
---@field lastTick number 
---@field context any|nil

LifeBoatAPI.TickFrequency = {
    REALTIME    = 1,        -- relatively few things need to happen every tick - consider before using this
    HIGH        = 20,       -- player interactions that need to "feel instant"
    LOW         = 60,       -- player interactions that can afford a "slight delay"
    BACKGROUND  = 5*60,    -- things that aren't directly affecting the player/out of their sight do not need to happen so immediately
}

---@class LifeBoatAPI.TickManager
---@field ticks number
---@field gameTicks number
---@field tickables LifeBoatAPI.ITickable[]
---@field onTick function own implementation of the onTick function
LifeBoatAPI.TickManager = {

    ---@param cls LifeBoatAPI.TickManager
    ---@return LifeBoatAPI.TickManager
    new = function (cls)
        local self = {
            tickables = {};
            ticks = 0;
            gameTicks = 0;
            
            --methods
            init = cls.init,
            register = cls.register;
            _onTickClosure = cls._onTickClosure
        }

        return self
    end;

    ---@param self LifeBoatAPI.TickManager
    init = function(self)
        -- if we should have already set onTick, but then something has overwritten it
        -- steal it back (i.e. player defined onTick after LB was intantiated, AND something registered before onCreate ran ~ low probability but saves a nightmare error to debug)
		if self.onTick and self.onTick ~= _ENV["onTick"] then
            onTick = self:_onTickClosure()
            self.onTick = onTick
		end
    end;

    ---@param self LifeBoatAPI.TickManager
    ---@param func LifeBoatAPI.ITickableFunc
    ---@param tickFrenquency number|nil
    ---@param firstTickDelay number|nil 
    ---@param context any|nil
    ---@return LifeBoatAPI.ITickable
    register = function (self, func, context, tickFrenquency, firstTickDelay)
        tickFrenquency = tickFrenquency or -1
        
        -- if not explicitly provided, first tick delay should be randomly spread out across the tick frequency
        -- this avoids having tons of tickables all running on the exact same tick, and removing any benefit of the tickable system
        if not firstTickDelay and tickFrenquency > 0 then
            firstTickDelay = math.floor(math.random() * math.min(60, tickFrenquency)) + 1
        end

        local tickable = {
            onExecute = func,
            tickFrenquency = tickFrenquency,
            nextTick = self.ticks + (firstTickDelay or 1),
            lastTick = self.ticks,
            context = context
        }

        -- safe during iteration, as the loop is fixed length
        -- as such, new tickables will *never* be evaluated during the tick they are added (hence setting nextTick to ticks+1)
        self.tickables[#self.tickables + 1] = tickable

        if not self.onTick then
            onTick = self:_onTickClosure()
            self.onTick = onTick
            self.isOnTickRegistered = true
        end

        -- allow tickables to be run instantly in the tick they're registered, unlikely to be used
        if firstTickDelay == 0 then
            tickable:onExecute(0)
        end

        return tickable
    end;
    
    ---@param self LifeBoatAPI.TickManager
    _onTickClosure = function(self)
        local _onTick = onTick

        return function (gameTicks)
            -- call original/global registered onTick
            if _onTick then
                _onTick(gameTicks)
            end

            self.ticks = self.ticks + 1
            self.gameTicks = self.gameTicks + gameTicks -- track the in-game time separately
            
            local disposablesAwaitingRemoval = 0;
            for i=1, #self.tickables do
                local tickable = self.tickables[i]

                if not tickable.isDisposed and tickable.nextTick == self.ticks and not tickable.isPaused then

                    if tickable.tickFrequency and tickable.tickFrequency > 0 then
                        tickable.nextTick = self.ticks + tickable.tickFrequency
                    else
                        -- todo: decision to make after real-world use: does tickManager need to lb_dispose the tickables, or not
                        if tickable.disposables then
                            LifeBoatAPI.lb_dispose(tickable) -- necessary?
                        else
                            if tickable.disposables or tickable.onDispose then
                                LifeBoatAPI.lb_dispose(tickable)
                            else
                                tickable.isDisposed = true
                            end
                        end
                    end

                    tickable:onExecute(self.gameTicks - tickable.lastTick)
                    tickable.lastTick = self.gameTicks
                end

                if tickable.isDisposed then
                    disposablesAwaitingRemoval = disposablesAwaitingRemoval + 1;
                end
            end
            
            -- handle restructuring whenever there are a significant number of tickables waiting to be disposed of
            -- it depends on how impactful having too many "dead" tickables is to performance
            local MAX_DISPOSABLES = 100
            if disposablesAwaitingRemoval > MAX_DISPOSABLES then
                local newTickables = {}

                for i=1, #self.tickables do
                    local tickable = self.tickables[i]
                    if not tickable.isDisposed then
                        newTickables[#newTickables+1] = tickable
                    end
                end
        
                self.tickables = newTickables
                disposablesAwaitingRemoval = 0
            end

            -- deregister self if nothing listening anymore
            if #self.tickables == 0 then
                onTick = _onTick
                self.isOnTickRegistered = false
            end
        end
    end;
}

