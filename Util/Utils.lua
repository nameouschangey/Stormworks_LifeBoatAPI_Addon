-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

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