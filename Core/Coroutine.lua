
---@alias LifeBoatAPI.ICoroutineFunc fun(cr:LifeBoatAPI.Coroutine, deltaTicks:number, lastResult:any) : number

---@class LifeBoatAPI.ICoroutineStage
---@field onExecute LifeBoatAPI.ICoroutineFunc
---@field isImmediate boolean

---@class LifeBoatAPI.Coroutine : LifeBoatAPI.IDisposable
---@field yield number (or nil) move onto the next stage
---@field terminate number terminate permanently, should only be used for non-recoverable failure conditions
---@field loop number repeat current stage again
---@field await number await the given coroutine/awaitable
--
---@field stages LifeBoatAPI.ICoroutineStage[]
---@field current number
---@field onTickListener LifeBoatAPI.ITickable
---@field tickFrequency number
---@field lastResult any|nil 
---@field listeners table
---@field status number running status: 0: not yet triggered, 1:triggered and running, 2: result(Success) - awaiting next actions
LifeBoatAPI.Coroutine = {
	---@param cls LifeBoatAPI.Coroutine
	---@param tickFrequency number|nil how often to run the coroutine
	---@param beginUntriggered boolean|nil whether the coroutine should start already triggered/running, or await a specific signal before starting
	---@return LifeBoatAPI.Coroutine
	start = function (cls, tickFrequency, beginUntriggered)
		local self = {
			-- "constants"
			dispose = -1; -- end coroutine "now" as a failure, does not allow it to be resurrected
			loop = -2; -- repeat current stage
			await = -3; -- await a single event finishing

			-- fields
			tickFrequency = tickFrequency or LifeBoatAPI.TickFrequency.HIGH;
			lastTick = LB.ticks.gameTicks;
			current = 1;
			stages = {};
			listeners = {};
			status = beginUntriggered and 0 or 1; -- 0: not yet triggered, 1:triggered and running, 2: result(Success) - awaiting next actions

			-- methods
			attach = LifeBoatAPI.lb_attachDisposable;
			trigger = cls.trigger;
			andThen = cls.andThen;
			andImmediately = cls.andImmediately;
			setTickFrequency = cls.setTickFrequency;
		}
		return self
	end;

	---@param self LifeBoatAPI.Coroutine
	---@param tickFrequency number
	---@return LifeBoatAPI.Coroutine
	setTickFrequency = function(self, tickFrequency)
		self.tickFrequency = tickFrequency
		if self.onTickListener then
			self.onTickListener.tickFrequency = tickFrequency
		end
		return self -- potentially allows chaining
	end;

	---Adds a step that will be run asynchronously at the next available tick
	--- The number of ticks between each step, is determined by setTickFrequency
	--- Useful for long-running checks, e.g. "check if the fuel is running low if it has do something, otherwise wait a while"
	---@param self LifeBoatAPI.Coroutine
	---@param func LifeBoatAPI.ICoroutineFunc
	---@return LifeBoatAPI.Coroutine
	andThen = function(self, func)
		if not self.isDisposed then
			self.stages[#self.stages+1] = {onExecute = func, --[[isImmediate = nil]]}

			-- status 2: already reached end of instructions, so restart it
			if self.status == 2 then
				self.status = 1
				self.current = #self.stages
			end

			-- register with tick
			if not self.onTickListener then
				self.onTickListener = LB.ticks:register(self.trigger, self, self.tickFrequency)
				self.onTickListener.isPaused = not self.status == 0
			end

		end
		return self
	end;

	---Adds a step that will be run immediately after the previously one, synchronously
	--- Useful for "follow-up" style work; e.g. "await this, THEN STRAIGHT AFTER -> do this other work"
	---@param self LifeBoatAPI.Coroutine
	---@param func LifeBoatAPI.ICoroutineFunc
	---@return LifeBoatAPI.Coroutine
	andImmediately = function(self, func)
		if not self.isDisposed then
			self.stages[#self.stages+1] = {onExecute = func, isImmediate = true}

			-- status 2: has run out of instructions to run, so restart it
			if self.status == 2 then
				self.status = 1
				self.current = #self.stages -- ensures that if we've run all stages, and current is now not pointing at anything - when we add a stage; it runs that stage

				-- start running instructions again
				self:trigger()
			end
		end
		return self
	end;

	---@param self LifeBoatAPI.Coroutine
	trigger = function (self)

		-- no further triggers should do anything
		if self.isDisposed then
			return
		end

		-- we need to calculate deltatime ourselves here, due to awaitables and triggering outside onTick
		local lastTick = self.lastTick
		local currentTick = LB.ticks.gameTicks
		local deltaTicks = currentTick - lastTick
		self.lastTick = currentTick

		self.isTriggered = true
		if self.onTickListener then
			self.onTickListener.isPaused = false
		end

		local shouldDispose = false;
		repeat
			local stage = self.stages[self.current]
			if not stage then
				break -- no stages, will only happen on the first trigger; we follow throw to status=3 (out of instructions)
			end

			-- execute the stage and store pass the results onto the next stage
			local yieldType, result = stage.onExecute(self, deltaTicks, self.lastResult)
			
			-- "terminated"
			if yieldType == -1 then
				shouldDispose = true;
				self.lastResult = result

			-- "loop"
			elseif yieldType == -2 then
				-- don't change the stage
				self.lastResult = result
				stage.isImmediate = false -- looping cannot be done in immediate mode
				
			-- "await"
			elseif yieldType == -3 then
				local coroutine = result
                
				if not coroutine.isDisposed or not coroutine.isTriggered then
					-- if we're given a coroutine (eventually will be the only way)
					coroutine.listeners[#coroutine.listeners + 1] = self

					if self.onTickListener then
						self.onTickListener.isPaused = true
					end

					return; -- no more processing while we wait for the awaitable to trigger
				else
					-- awaitable has already terminated, we need to grab the last result it had; and move onto the next stage
					self.lastResult = coroutine.lastResult
					self.current = self.current + 1
				end

			-- "yield/next" (any nonsense argument or nil, assume the best)
			else
				self.current = self.current + 1
				self.lastResult = result
			end

			-- if the next stage is "immediate" it should run without any delay
		until(shouldDispose
		      or not self.stages[self.current]
			  or not self.stages[self.current].isImmediate)


		-- terminated or no further stages
		if shouldDispose or not self.stages[self.current] then
			-- trigger all children that this coroutine has finished
			for i=1, #self.listeners do
				local listener = self.listeners[i]
				if not listener.isDisposed then
					self.lastResult = listener.lastResult
					listener:trigger()
				end
			end

			-- clear existing listeners, in case it's resurrected
			if #self.listeners > 0 then
				self.listeners = {}
			end

			-- disposal
			if self.onTickListener then
				self.onTickListener.isDisposed = true
				self.onTickListener = nil
			end

			self.status = 2 -- end of current instructions

			if shouldDispose then
				if self.disposables or self.onDispose then
					LifeBoatAPI.lb_dispose(self)
				else
					self.isDisposed = true
				end
			end

			return
		end
	end;
}



