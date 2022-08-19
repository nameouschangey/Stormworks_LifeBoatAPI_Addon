-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

--- Empty function for use in and/or statements
--- Does nothing, just makes readbility a bit easier/easier to check if something *is* the empty function if it's always this one
LifeBoatAPI.lb_empty = function()end


--- Converts the given value t, to a string, regardless of what type of value it is 
--- Doesn't handle self-referential tables (e.g. a = {}; a.b=a)
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


---Shallow copy of all values from parent into child, or makes a copy of parent
---@param parent table Object to copy from
---@param child table|nil Object to copy into, or nil if we want a fresh copy
LifeBoatAPI.lb_copy = function(parent, child)
    child = child or {}
    
    for k,v in pairs(parent) do
        if child[k] == nil then
            child[k] = v
        end
    end
    return child
end;

---Deep copy, cloning every sub table one at a time
---Beware of how this is used, high performance cost - very few times you want to have this function
---Can handle circular table references
---Note, for arrays; will apply the same overwriting rules, e.g. child1, child2 + parent1,parent2,parent3 -> child1,child2,parent3
---@param parent table Object to copy from
---@param child table|nil Object to copy into, or nil if we want a fresh copy
---@param tablesSeen table[]|nil internal list of tables seen so far, allows for circular references
LifeBoatAPI.lb_deepcopy = function(parent, child, tablesSeen)
    child = child or {}
    local tablesSeen = tablesSeen or {}
    tablesSeen[parent] = child

    for k,v in pairs(parent) do
        if type(v) == "table" then
            if tablesSeen[v] then
                child[k] = tablesSeen[v]
            else
                child[k] = LifeBoatAPI.lb_deepcopy(v, child[k], tablesSeen)
            end
        elseif child[k] == nil then
            child[k] = v
        end
    end
    return child
end;