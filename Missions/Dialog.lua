-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


---@class DialogChoice
---@field phrase string
---@field next string
---@field customHandler fun(self:DialogChoice, player: LifeBoatAPI.Player, message: string) : boolean

---@class DialogLine
---@field text string
---@field id string|nil
---@field choices DialogChoice[]|nil
---@field textWithChoices string
---@field showChoices boolean|nil
---@field result table|nil
---@field timeout number|nil
---@field next string|nil
---@field terminate boolean|nil

---@class Dialog
---@field defaultTimeout number
---@field tickFrequency number
---@field lines DialogLine[]
---@field lineIndexesByID table<string, number>
---@field hasChoices boolean (internal)
---@field isProcessed boolean (internal)
Dialog = {

    ---@param cls Dialog
    ---@param lines DialogLine[]|nil
    ---@param defaultTimeout number|nil
    ---@param tickFrequency number|nil
    ---@return Dialog
    new = function(cls, lines, defaultTimeout, tickFrequency)
        local self = {
            defaultTimeout = defaultTimeout or 120,
            tickFrequency = tickFrequency,
            lines = {},
            lineIndexesByID = {},
            isProcessed = false,
            hasChoices = true,

            ---methods
            start = cls.start,
            addLine = cls.addLine,
        }

        -- add initial lines
        if lines then
            for i=1, #lines do
                self:addLine(lines[i])
            end
        end

        return self
    end;

    --- can just directly add to self.lines
    ---@param self Dialog
    ---@param line DialogLine
    addLine = function(self, line)
        self.lines[#self.lines+1] = line

        if line.choices then
            self.hasChoices = true

            local textParts = {line.text, "\n\n"}
            for i=1, #line.choices do -- cheaper than string.format
                textParts[#textParts+1] = "["
                textParts[#textParts+1] = line.choices[i].phrase
                textParts[#textParts+1] = "] "
            end

            line.textWithChoices = table.concat(textParts)
        else
            line.textWithChoices = line.text
        end

        if line.id then
            self.lineIndexesByID[line.id] = #self.lines
        end 
    end;

    ---@param self Dialog
    ---@param popupOrDrawFunc LifeBoatAPI.UIPopup|LifeBoatAPI.UIPopupRelativePos|fun(player, line)
    ---@param player LifeBoatAPI.Player
    ---@return DialogInstance
    start = function(self, popupOrDrawFunc, player)
        return DialogInstance:new(self, popupOrDrawFunc, player)
    end;
}



---@class DialogInstance : LifeBoatAPI.IDisposable
---@field results table
---@field dialog Dialog
---@field player LifeBoatAPI.Player
---@field onDispose fun(self: DialogInstance) can be overridden if wanted, otherwise nil
---@field drawText fun(player: LifeBoatAPI.Player, line: DialogLine)
DialogInstance = {

    ---@param cls DialogInstance
    ---@param dialog Dialog
    ---@param player LifeBoatAPI.Player
    new = function(cls, dialog, popupOrDrawFunc, player)

        -- begin the dialog
        local self = {
            disposables = {},
            results = {},
            dialog = dialog,
            player = player,
            lineIndex = 1,
            line = dialog.lines[1],

            -- methods
            attach = LifeBoatAPI.lb_attachDisposable;
            gotoNextLine = cls.gotoNextLine;
        }

        -- create the draw function to use
        ---@cast popupOrDrawFunc fun(player : LifeBoatAPI.Player, line:DialogLine)
        self.drawText = popupOrDrawFunc
        if type(popupOrDrawFunc) == "table" then
            ---@cast popupOrDrawFunc LifeBoatAPI.UIPopup|LifeBoatAPI.UIPopupRelativePos
            self.drawText = function(player, line)
                popupOrDrawFunc:edit(line.textWithChoices)
            end
        end

        -- initial line timeout
        self.lineTimeout = (not self.line.choices and (self.line.timeout or self.dialog.defaultTimeout)) or nil
        if self.lineTimeout then
            self.lineTimeout = LB.ticks.ticks + self.lineTimeout
        end
        self.drawText(player, self.line)


        -- run the main thread for the dialog
        self.disposables[#self.disposables+1] = LB.ticks:register(function (listener, context, deltaTicks)
            if self.lineTimeout then
                if self.lineTimeout < LB.ticks.ticks then
                    self:gotoNextLine()
                end
            end
        end, nil, self.tickFrequency or 30)

        -- setup listener for player replies, if we've got choices to make in this dialogue tree
        if dialog.hasChoices then
            self.disposables[#self.disposables+1] = player.onChat:register(function (l, context, player, message)
                local line = self.line
                if line.choices then
                    for i=1, #line.choices do
                        local choice = line.choices[i]
                        if choice.customHandler then
                            if choice:customHandler(player, message) then
                                self:gotoNextLine(choice.next)
                                return;
                            end
                        elseif message:find(choice.phrase, 0, true) then
                            self:gotoNextLine(choice.next)
                            return
                        end
                    end
                end
            end)
        end

        --- if the player disconnects during the chat, we kill the dialog
        self.disposables[#self.disposables+1] = player.onDespawn:register(function (l, context, object)
            LifeBoatAPI.lb_dispose(self)
        end)

        return self
    end;

    ---@param self DialogInstance
    ---@param nextLineName string|nil
    gotoNextLine = function(self, nextLineName)
        -- add result from current line
        if self.line.result then
            for k,v in pairs(self.line.result) do
                self.results[k] = v
            end
        end

        -- find the next line
        nextLineName = nextLineName or self.line.next
        self.lineIndex = (nextLineName and self.dialog.lineIndexesByID[nextLineName]) or (self.lineIndex + 1)
        local nextLine = self.dialog.lines[self.lineIndex]

        -- current line said to terminate, or next line doesn't exist
        if self.line.terminate ~= nil or not nextLine then
            self.drawText(self.player, {text=""})
            LifeBoatAPI.lb_dispose(self)
        else
            -- move to the next line
            self.line = nextLine
            self.lineTimeout = (not self.line.choices and (self.line.timeout or self.dialog.defaultTimeout)) or nil
            if self.lineTimeout then
                self.lineTimeout = LB.ticks.ticks + self.lineTimeout
            end

            self.drawText(self.player, self.line)
        end
    end;
}