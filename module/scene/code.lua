---@type Zenitha.Scene

------------------------------------------------------
-- This file contains spoilers for future content!! --
------------------------------------------------------

local scene = {}

local clr = {
    D = { COLOR.HEX '191E31FF' },
    L = { COLOR.HEX '4D67A6FF' },
    T = { COLOR.HEX '6F82ACFF' },
    LT = { COLOR.HEX 'B0CCEBFF' },
    cbFill = { COLOR.HEX '0B0E17FF' },
    cbFrame = { COLOR.HEX '6A82A7FF' },
}
local colorRev = false
local bindBuffer

function scene.load()
    MSG.clear()
    bindBuffer = nil
    SetMouseVisible(true)
    if GAME.anyRev ~= colorRev then
        colorRev = GAME.anyRev
        for _, C in next, clr do
            C[1], C[3] = C[3], C[1]
        end
    end
    TASK.unlock('import')
end

scene.resize = refreshWidgets

-- Panel size
local w, h = 800, 500
local baseX, baseY = (1600 - w) / 2, (1000 - h) / 2

local gc = love.graphics
local gc_replaceTransform = gc.replaceTransform
local gc_setColor, gc_rectangle, gc_print, gc_printf = gc.setColor, gc.rectangle, gc.print, gc.printf
local gc_ucs_move, gc_ucs_back = GC.ucs_move, GC.ucs_back
local gc_setAlpha, gc_mRect, gc_mStr = GC.setAlpha, GC.mRect, GC.mStr



function scene.draw()
    DrawBG(STAT.bgBrightness)

    local t = love.timer.getTime()

    -- Panel
    gc_replaceTransform(SCR.xOy)
    gc.translate(800 - w / 2, 510 - h / 2)
    gc_setColor(clr.D)
    gc_rectangle('fill', 0, 0, w, h)
    gc_setColor(0, 0, 0, .26)
    gc_rectangle('fill', 3, 3, w - 6, h - 6)
    gc_setColor(1, 1, 1, .1)
    gc_rectangle('fill', 0, 0, w, 3)
    gc_setColor(1, 1, 1, .04)
    gc_rectangle('fill', 0, 3, 3, h + 3)

    FONT.set(40)
    GC.setColor(COLOR.L)
    GC.print('PLACEHOLDER', 400, 0, 0, 1.2)

end

scene.widgetList = {

    WIDGET.new {
        name = 'import', type = 'button',
        x = baseX + 400, y = baseY + 400, w = 380, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "INSERT CODE",
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        onClick = function()
            -- MSG.clear()
            local data = CLIPBOARD.get():filterASCII():trim()
            if #data <= 26 then
                if data == '' then
                    MSG('dark', "No data in clipboard")
                --elseif data == 'pathoflightsunflickered' then
                --    SFX.play('card_tone_volatile', 1, 0, Tone(-2))
                --    SFX.play('inject', 1, 0, Tone(-3))
                --    MSG('dark', "GATE - VOLATILITY")
                elseif data == 'hid' then
                    MSG('dark', STAT.hid)
                else
                    local msg = "Invalid code '" .. data .. "' in clipboard."
                    
                    MSG('dark', msg)
                    SFX.play('staffwarning')
                    return
                end
                LOG('info', "Secret: " .. data)
                return
            end
            if TASK.lock('import', 4.2) then
                SFX.play('notify')
                MSG('dark',
                    "Import data from clipboard text?\nThe version must match; all progress you made so far will be permanently lost!\nPress again to confirm",
                    4.2)
                return
            end
            TASK.unlock('import')
            local d3 = STRING.split(data, ',')
            local suc1, res1 = pcall(STRING.unpackTable, d3[1])
            local suc2, res2 = pcall(STRING.unpackTable, d3[2])
            local suc3, res3
            if d3[3] then
                suc3, res3 = pcall(STRING.unpackTable, d3[3])
            else
                suc3, res3 = true, {}
            end
            if not suc1 or not suc2 or not suc3 then
                MSG('dark', "Invalid data format")
                SFX.play('staffwarning')
                return
            elseif res1.version > STAT.version then
                MSG('error', "Cannot import data from future versions\nPlease update your game first!")
                SFX.play('staffwarning')
                return
            elseif res1.mod and res1.mod ~= 'vanilla' then
                MSG('dark', "Cannot import data from modded version")
                SFX.play('staffwarning')
                return
            end
            TABLE.update(STAT, res1)
            BEST, ACHV = res2, res3
            setmetatable(BEST.highScore, Metatable.best_highscore)
            GAME.refreshLockState()
            setmetatable(BEST.speedrun, Metatable.best_speedrun)
            if STAT.system ~= SYSTEM then
                STAT.system = SYSTEM
                IssueAchv('zenith_relocation')
            end
            Initialize(true)
            if TestMode then
                MSG('dark', "Progress imported, but won't be saved.")
            else
                MSG('dark', "Progress imported!")
            end
            SFX.play('social_notify_major')
        end,
    },

    WIDGET.new {
        name = 'back', type = 'button',
        pos = { 0, 0 }, x = 60, y = 140, w = 160, h = 60,
        color = { .15, .15, .15 },
        sound_hover = 'menutap',
        fontSize = 30, text = "    BACK", textColor = 'DL',
        onClick = function() love.keypressed('escape') end,
    },
}

return scene