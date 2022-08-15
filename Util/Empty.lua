-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

LifeBoatAPI.lb_empty = function()end

---@param t any
---@param indent nil|number
---@return string
LifeBoatAPI.lb_tostring = function(t, indent)
    local typeof = type(t)
    if typeof == "table" then
        indent = (indent or 0)+1
        local s = {}
        for k,v in pairs(t) do
            if type(k) ~= "number" then
                s[#s+1] = string.rep(" ", indent*2) .. "[" .. tostring(k) .. "] = " .. LifeBoatAPI.lb_tostring(v, indent)
            end
        end
        for i=1,#t do
            s[#s+1] = string.rep(" ", indent*2) .. LifeBoatAPI.lb_tostring(t[i])
        end
        return "{\n" .. table.concat(s, ",\n") .. "\n" .. string.rep(" ", (indent-1)*2) .. "}"
    else
        return tostring(t)
    end
end;