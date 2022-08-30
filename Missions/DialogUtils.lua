-- Author: Nameous Changey
-- GitHub: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension
-- Workshop: https://steamcommunity.com/id/Bilkokuya/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@class LifeBoatAPI.DialogUtils
LifeBoatAPI.DialogUtils = {
    ---@param zone LifeBoatAPI.Zone
    ---@param dialogModel LifeBoatAPI.Dialog
    ---@param npc LifeBoatAPI.Object|LifeBoatAPI.Vehicle
    ---@param heightOffset number
    ---@param goodbyeLine string
    ---@param onDialogStarted fun(dialog:LifeBoatAPI.DialogInstance)
    ---@param onDialogComplete LifeBoatAPI.DialogOnCompleteHandler 
    ---@param displayLocally boolean|nil
    ---@param defaultResults table|nil
    ---@param popupRange number|nil
    ---@param useRelativePosPoup boolean|nil whether to use the more costly, "Relative" UIPopup that stays vertical, even if the object topples over
    ---@return LifeBoatAPI.IDisposable
    newSimpleZoneDialog = function(zone, dialogModel, npc, heightOffset, goodbyeLine, onDialogStarted, onDialogComplete, defaultResults, popupRange, displayLocally, useRelativePosPoup)
        popupRange = popupRange or 100
        heightOffset = heightOffset or 1

        local disposable = LifeBoatAPI.SimpleDisposable:new()

        local popup;
        local collision = zone.onCollision:register(function (l, context, zone, collision, collidingWith)
            -- check we're colliding with a *real* player and not just a crate we've given the "player" collision tag
            ---@cast collidingWith LifeBoatAPI.Player
            local player = collidingWith
            if not player.onChat then
                return
            end

            if popup then
                -- we're already displaying this to another player
                return;
            end
            
            if useRelativePosPoup then
            popup = LifeBoatAPI.UIPopupRelativePos:new(displayLocally and player or nil, "", LifeBoatAPI.Matrix:newMatrix(0, heightOffset, 0), nil, popupRange, npc, true)
            else
                popup = LifeBoatAPI.UIPopup:new(displayLocally and player or nil, "", 0, heightOffset, 0, popupRange, npc, true)
            end
            --collision:attach(popup)
    
            local dialog = dialogModel:start(popup, player, defaultResults)
            collision:attach(dialog)
    
            -- additional start points for the dialog, to make it more interesting
            if onDialogStarted then
                onDialogStarted(dialog)
            end

            dialog.onComplete:register(onDialogComplete)

            -- when you walk away, add a nice little goodbye message when you leave that destroys itself after 2 seconds (120 ticks)
            collision.onCollisionEnd:register(function (l, context, collision)
                -- be polite if exiting mid conversation
                if dialog and not dialog.isDisposed then
                    popup:edit(goodbyeLine)
                    LifeBoatAPI.CoroutineUtils.disposeAfterDelay(popup, 120)
                else
                    LifeBoatAPI.lb_dispose(popup)
                end
                popup = nil
            end)
        end)

        disposable:attach(collision)
        
        return disposable
    end;
}