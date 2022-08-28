-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class DialogRun : LifeBoatAPI.IDisposable
---@field results table
---@field onDispose fun(self: DialogRun)

---@class DialogChoice
---@field phrase string
---@field next string
---@field customHandler fun(self:DialogChoice, player: LifeBoatAPI.Player, message: string) : boolean

---@class DialogLine
---@field text string
---@field id string|nil
---@field choices DialogChoice[]|nil
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
            lines = lines or {},
            lineIndexesByID = {},

            ---methods
            start = cls.start
        }
        return self
    end;

    ---@param self Dialog
    ---@param popupOrDrawFunc LifeBoatAPI.UIPopup|LifeBoatAPI.UIPopupRelativePos|fun(player, line)
    ---@param player LifeBoatAPI.Player
    ---@return DialogRun
    start = function(self, popupOrDrawFunc, player)
        ---@cast popupOrDrawFunc fun(player : LifeBoatAPI.Player, line:DialogLine)
        local drawText = popupOrDrawFunc
        if type(popupOrDrawFunc) == "table" then
            ---@cast popupOrDrawFunc LifeBoatAPI.UIPopup|LifeBoatAPI.UIPopupRelativePos
            local popup = popupOrDrawFunc

            ---@param line DialogLine
            drawText = function(player, line)
                
                if line.showChoices and line.choices then
                    local textParts = {line.text, "\n\n"}
                    for i=1, #line.choices do
                        textParts[#textParts+1] = "["
                        textParts[#textParts+1] = line.choices[i].phrase
                        textParts[#textParts+1] = "] "
                    end

                    popup:edit(table.concat(textParts))
                else
                    popup:edit(line.text)
                end
            end
        end

        -- process the tree to get the list of indexesById and find if there's choices
        local hasChoices = false
        for i=1, #self.lines do
            local line = self.lines[i]
            if line.choices then
                hasChoices = true
            end
            if line.id then
                self.lineIndexesByID[line.id] = i
            end
        end
        
        -- begin the dialog
        local disposable = {
            disposables = {},
            attach = LifeBoatAPI.lb_attachDisposable,
            results = {}
        }

        -- draw the first text
        local resultContainer = disposable.results -- container for the results that come out during this
        local lineIndex = 1
        local line = self.lines[lineIndex]
        local lineTimeout = (not line.choices and (line.timeout or self.defaultTimeout)) or nil
        if lineTimeout then
            lineTimeout = LB.ticks.ticks + lineTimeout
        end

        drawText(player, line)

        -- helper func
        local gotoNextLine = function(nextLineName)
            if line.result then
                for k,v in pairs(line.result) do
                    resultContainer[k] = v
                end
            end

            nextLineName = nextLineName or line.next
            lineIndex = (nextLineName and self.lineIndexesByID[nextLineName]) or (lineIndex + 1)
            local nextLine = self.lines[lineIndex]

            -- current line said to terminate, or next line doesn't exist
            if line.terminate ~= nil or not nextLine then
                drawText(player, {text=""})
                LifeBoatAPI.lb_dispose(disposable)
            else
                -- move to the next line
                line = nextLine
                lineTimeout = (not line.choices and (line.timeout or self.defaultTimeout)) or nil
                if lineTimeout then
                    lineTimeout = LB.ticks.ticks + lineTimeout
                end

                drawText(player, line)
            end
        end;
        
        -- run the main thread for the dialog
        disposable.disposables[#disposable.disposables+1] = LB.ticks:register(function (listener, context, deltaTicks)
            if lineTimeout then
                if lineTimeout < LB.ticks.ticks then
                    gotoNextLine()
                end
            end
        end, nil, self.tickFrequency or 30)

        -- setup listener for player replies, if we've got choices to make in this dialogue tree
        if hasChoices then
            disposable.disposables[#disposable.disposables+1] = player.onChat:register(function (l, context, player, message)
                if line.choices then
                    for i=1, #line.choices do
                        local choice = line.choices[i]
                        if choice.customHandler then
                            if choice:customHandler(player, message) then
                                gotoNextLine(choice.next)
                                return;
                            end
                        elseif message:find(choice.phrase, 0, true) then
                            gotoNextLine(choice.next)
                            return
                        end
                    end
                end
            end)
        end

        return disposable
    end;
}
