
--- @diagnostic disable: undefined-global

require("LifeBoatAPI.Tools.Build.Builder")

-- replace newlines
for k,v in pairs(arg) do
    arg[k] = v:gsub("##LBNEWLINE##", "\n")
end

local luaDocsAddonPath  = LifeBoatAPI.Tools.Filepath:new(arg[1]);
local luaDocsMCPath     = LifeBoatAPI.Tools.Filepath:new(arg[2]);
local outputDir         = LifeBoatAPI.Tools.Filepath:new(arg[3]);
local params            = {
    boilerPlate             = arg[4],
    reduceAllWhitespace     = arg[5] == "true",
    reduceNewlines          = arg[6] == "true",
    removeRedundancies      = arg[7] == "true",
    shortenVariables        = arg[8] == "true",
    shortenGlobals          = arg[9] == "true",
    shortenNumbers          = arg[10]== "true",
    forceNCBoilerplate      = arg[11]== "true",
    forceBoilerplate        = arg[12]== "true",
    shortenStringDuplicates = arg[13]== "true",
    removeComments          = arg[14]== "true",
    skipCombinedFileOutput  = arg[15]== "true"
};
local rootDirs          = {};

for i=15, #arg do
    table.insert(rootDirs, LifeBoatAPI.Tools.Filepath:new(arg[i]));
end

local _builder = LifeBoatAPI.Tools.Builder:new(rootDirs, outputDir, luaDocsMCPath, luaDocsAddonPath)

if onLBBuildStarted then onLBBuildStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]])) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[init.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\init.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[init.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\init.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[init.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\init.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Missions\Dialog.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Missions\Dialog.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Missions\Dialog.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Missions\Dialog.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Missions\Dialog.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Missions\Dialog.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Missions\Mission.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Missions\Mission.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Missions\Mission.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Missions\Mission.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Missions\Mission.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Missions\Mission.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Missions\DialogUtils.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Missions\DialogUtils.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Missions\DialogUtils.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Missions\DialogUtils.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Missions\DialogUtils.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Missions\DialogUtils.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Maths\Matrix.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Maths\Matrix.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Maths\Matrix.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Maths\Matrix.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Maths\Matrix.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Maths\Matrix.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Maths\Vector.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Maths\Vector.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Maths\Vector.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Maths\Vector.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Maths\Vector.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Maths\Vector.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Util\Constants.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\Constants.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Util\Constants.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\Constants.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Util\Constants.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\Constants.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\EventManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\EventManager.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\EventManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\EventManager.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\EventManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\EventManager.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Maths\RollingAverage.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Maths\RollingAverage.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Maths\RollingAverage.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Maths\RollingAverage.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Maths\RollingAverage.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Maths\RollingAverage.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\game.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\game.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[AddonSimulator\game.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\game.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\game.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\game.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Event.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Event.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\Event.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Event.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Event.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Event.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Coroutine.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Coroutine.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\Coroutine.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Coroutine.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Coroutine.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Coroutine.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\ai.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\ai.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[AddonSimulator\ai.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\ai.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\ai.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\ai.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\LB.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\LB.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\LB.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\LB.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\LB.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\LB.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\init.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\init.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[AddonSimulator\init.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\init.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\init.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\init.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\CollisionManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\CollisionManager.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\CollisionManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\CollisionManager.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\CollisionManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\CollisionManager.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Util\Bitwise.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\Bitwise.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Util\Bitwise.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\Bitwise.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Util\Bitwise.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\Bitwise.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Maths\Colliders.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Maths\Colliders.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Maths\Colliders.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Maths\Colliders.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Maths\Colliders.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Maths\Colliders.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\addon.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\addon.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[AddonSimulator\addon.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\addon.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\addon.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\addon.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\AddonManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\AddonManager.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\AddonManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\AddonManager.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\AddonManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\AddonManager.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Util\CoroutineUtils.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\CoroutineUtils.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Util\CoroutineUtils.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\CoroutineUtils.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Util\CoroutineUtils.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\CoroutineUtils.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\misc.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\misc.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[AddonSimulator\misc.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\misc.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\misc.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\misc.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\vehicle.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\vehicle.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[AddonSimulator\vehicle.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\vehicle.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\vehicle.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\vehicle.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\ui.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\ui.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[AddonSimulator\ui.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\ui.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\ui.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\ui.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIManager.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\UIManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIManager.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIManager.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\objects.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\objects.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[AddonSimulator\objects.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\objects.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[AddonSimulator\objects.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\AddonSimulator\objects.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\TickManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\TickManager.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\TickManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\TickManager.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\TickManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\TickManager.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\PlayerManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\PlayerManager.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\PlayerManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\PlayerManager.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\PlayerManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\PlayerManager.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Util\Utils.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\Utils.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Util\Utils.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\Utils.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Util\Utils.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\Utils.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Util\notes.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\notes.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Util\notes.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\notes.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Util\notes.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\notes.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Util\Disposable.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\Disposable.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Util\Disposable.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\Disposable.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Util\Disposable.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Util\Disposable.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\ObjectManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\ObjectManager.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\ObjectManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\ObjectManager.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\ObjectManager.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\ObjectManager.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIScreenPopup.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIScreenPopup.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\UIObjects\UIScreenPopup.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIScreenPopup.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIScreenPopup.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIScreenPopup.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIPopupRelativePos.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIPopupRelativePos.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\UIObjects\UIPopupRelativePos.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIPopupRelativePos.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIPopupRelativePos.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIPopupRelativePos.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIPopup.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIPopup.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\UIObjects\UIPopup.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIPopup.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIPopup.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIPopup.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIMapObject.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIMapObject.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\UIObjects\UIMapObject.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIMapObject.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIMapObject.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIMapObject.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIMapLine.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIMapLine.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\UIObjects\UIMapLine.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIMapLine.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIMapLine.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIMapLine.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Objects\Zone.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Zone.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\Objects\Zone.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Zone.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Objects\Zone.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Zone.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIMapLabel.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIMapLabel.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\UIObjects\UIMapLabel.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIMapLabel.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIMapLabel.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIMapLabel.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Objects\Vehicle.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Vehicle.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\Objects\Vehicle.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Vehicle.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Objects\Vehicle.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Vehicle.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIMapCollection.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIMapCollection.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\UIObjects\UIMapCollection.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIMapCollection.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIMapCollection.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIMapCollection.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Objects\Player.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Player.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\Objects\Player.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Player.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Objects\Player.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Player.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Objects\ObjectCollection.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\ObjectCollection.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\Objects\ObjectCollection.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\ObjectCollection.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Objects\ObjectCollection.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\ObjectCollection.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIElement.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIElement.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\UIObjects\UIElement.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIElement.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\UIObjects\UIElement.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\UIObjects\UIElement.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Objects\Object.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Object.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\Objects\Object.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Object.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Objects\Object.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Object.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Objects\GameObject.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\GameObject.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\Objects\GameObject.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\GameObject.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Objects\GameObject.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\GameObject.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Objects\Fire.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Fire.lua]])) end

local combinedText, outText, outFile = _builder:buildAddonScript([[Core\Objects\Fire.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Fire.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]]), [[Core\Objects\Fire.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI\Core\Objects\Fire.lua]]), outFile, combinedText, outText) end

if onLBBuildComplete then onLBBuildComplete(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Workspaces\stormworks\projects\FarmerJacksPotatoLifter\addon\_build\libs\LifeBoatAPI]])) end
--- @diagnostic enable: undefined-global
