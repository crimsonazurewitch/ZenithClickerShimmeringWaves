---@type Zenitha.Scene
local scene = {}

local maskAlpha, cardShow
local card = GC.newCanvas(1200, 720)

local floor = math.floor

local baseColor = { .12, .26, .14 }
local areaColor = { .12, .23, .12 }
local titleColor = { COLOR.HEX("16582D") }
local textColor = { COLOR.HEX("54B06D") }
local scoreColor = { COLOR.HEX("B0FFC0") }
local setup = { stencil = true, card }

local clr = {
    D = { COLOR.HEX '191E31' },
    L = { COLOR.HEX '4D67A6' },
    T = { COLOR.HEX '6F82AC' },
    LT = { COLOR.HEX 'B0CCEB' },
    cbFill = { COLOR.HEX '0B0E17' },
    cbFrame = { COLOR.HEX '6A82A7' },
}
local colorRev = false

function scene.load()
    SetMouseVisible(true)
    TASK.lock('no_back')
    maskAlpha, cardShow = 0, 0
    TWEEN.new(function(t)
        maskAlpha = t
    end):setTag('stat_in'):setDuration(.26):run():setOnFinish(function()
        TWEEN.new(function(t)
            cardShow = t
        end):setTag('stat_in'):setDuration(.1):run():setOnFinish(function()
            TASK.unlock('no_back')
        end)
    end)
end

function scene.keyDown(key, isRep)
    if isRep then return true end
    if (key == 'escape' or key == '/') then
        SFX.play('menuclick')
        SCN.back('none')
    end
    return true
end

function scene.update(dt)
    SCN.scenes.tower.update(dt)
    for _, W in next, SCN.scenes.tower.widgetList do
        W:update(dt)
    end
end

local w, h = 900, 830
local baseX, baseY = (1600 - w) / 2, (1000 - h) / 2
local gc = love.graphics
local gc_replaceTransform = gc.replaceTransform
local gc_setColor, gc_rectangle, gc_print, gc_printf = gc.setColor, gc.rectangle, gc.print, gc.printf
local gc_ucs_move, gc_ucs_back = GC.ucs_move, GC.ucs_back
local gc_setAlpha, gc_mRect, gc_mStr = GC.setAlpha, GC.mRect, GC.mStr

function scene.draw()
	DrawBG(STAT.bgBrightness)
    SCN.scenes.tower.draw()
    GC.replaceTransform(SCR.xOy)
    WIDGET.draw(SCN.scenes.tower.widgetList)
    SCN.scenes.tower.overDraw()
    GC.origin()
    GC.setColor(0, 0, 0, maskAlpha * .8)
    GC.rectangle('fill', 0, 0, SCR.w, SCR.h)
	
	-- Panel
    gc_replaceTransform(SCR.xOy)
	gc.translate(800 - w / 2, 510 - h / 2)
    gc_setColor(.418, .418, .418)
    gc_rectangle('fill', 0, 0, w, h)
    gc_setColor(.378, .378, .378, .26)
    gc_rectangle('fill', 3, 3, w - 6, h - 6)
    gc_setColor(1, 1, 1, .1)
    gc_rectangle('fill', 0, 0, w, 3)
    gc_setColor(1, 1, 1, .04)
    gc_rectangle('fill', 0, 3, 3, h + 3)

    -- Grid
    if love.keyboard.isDown('space') then
        gc_setColor(1, 1, 0)
        FONT.set(30)
        for x = 0, 1200 - 100, 100 do
            for y = 0, 1600 - 100, 100 do
                gc_rectangle('line', x, y, 100, 100)
                gc_print(x .. ',' .. y, x + 2.6, y, 0, .355)
            end
        end
    end


    if cardShow > 0 then
        GC.replaceTransform(SCR.xOy_m)
        GC.setColor(1, 1, 1, cardShow)
        local k = .9 + cardShow * .1
        GC.mDraw(card, 0, 0, 0, k * .67, k ^ 26 * .67)
    end
end

scene.widgetList = {
	WIDGET.new {
        name = 'nc', type = 'button',
        x = baseX + 240, y = baseY + 100, w = 380, h = 50,
		color = { .5, .5, .5, 1 },
		fontSize = 30, text = "Nightcore (Z)", textColor = 'L',
        sound_hover = 'menutap',
        onClick = function()
			if not GAME.nightcore then
				GAME.nightcore = true
				MSG('dark', "Nightcore: On")
                SFX.play('z', 1, 0, Tone(6))
			else 
				GAME.nightcore = false
				MSG('dark', "Nightcore: Off")
			end
            GAME.refreshLayout()
            GAME.refreshUltra()
            GAME.refreshCurrentCombo()
            RefreshBGM()
            GAME.refreshRPC()
		end,
    },
	WIDGET.new {
        name = 'slowmo', type = 'button',
        x = baseX + 660, y = baseY + 100, w = 380, h = 50,
		color = { .5, .5, .5, 1 },
		fontSize = 30, text = "Slow-mo (S)", textColor = 'L',
        sound_hover = 'menutap',
        onClick = function()
			if not GAME.slowmo then
				GAME.slowmo = true
				MSG('dark', "Slow-mo: On")
                SFX.play('s', 1, 0, Tone(6))
			else
				GAME.slowmo = false
				MSG('dark', "Slow-mo: Off")
			end
            GAME.refreshLayout()
            GAME.refreshUltra()
            GAME.refreshCurrentCombo()
            RefreshBGM()
            GAME.refreshRPC()
		end,
    },
	WIDGET.new {
        name = 'glassc', type = 'button',
        x = baseX + 240, y = baseY + 175, w = 380, h = 50,
		color = { .5, .5, .5, 1 },
		fontSize = 30, text = "Glass Cards (J)", textColor = 'L',
        sound_hover = 'menutap',
        onClick = function()
			if not GAME.glassCard and not GAME.invisCard then
				GAME.glassCard = true
				MSG('dark', "Glass Cards: On")
                SFX.play('j', 1, 0, Tone(6))
			elseif GAME.invisCard and not GAME.glassCard then
				GAME.invisCard = false
				GAME.glassCard = true
				MSG('dark', "Glass Cards: On")
				MSG('dark', "Conflict found - Invisible Cards: Off")
                SFX.play('j', 1, 0, Tone(6))
                SFX.play('no')
			else
				GAME.glassCard = false
				MSG('dark', "Glass Cards: Off")
			end
            GAME.refreshLayout()
            GAME.refreshUltra()
            GAME.refreshCurrentCombo()
            RefreshBGM()
            GAME.refreshRPC()
		end,
    },
	WIDGET.new {
        name = 'invisc', type = 'button',
        x = baseX + 660, y = baseY + 175, w = 380, h = 50,
		color = { .5, .5, .5, 1 },
		fontSize = 30, text = "Invisible Cards (O)", textColor = 'L',
        sound_hover = 'menutap',
        onClick = function()
			if not GAME.invisCard and not GAME.glassCard then
				GAME.invisCard = true
				MSG('dark', "Invisible Cards: On")
                SFX.play('o', 1, 0, Tone(6))
			elseif GAME.glassCard and not GAME.invisCard then
				GAME.glassCard = false
				GAME.invisCard = true
				MSG('dark', "Invisible Cards: On")
				MSG('dark', "Conflict found - Glass Cards: Off")
                SFX.play('o', 1, 0, Tone(6))
                SFX.play('no')
			else
				GAME.invisCard = false
				MSG('dark', "Invisible Cards: Off")
			end
            GAME.refreshLayout()
            GAME.refreshUltra()
            GAME.refreshCurrentCombo()
            RefreshBGM()
            GAME.refreshRPC()
		end,
    },
	WIDGET.new {
        name = 'invisui', type = 'button',
        x = baseX + 240, y = baseY + 250, w = 380, h = 50,
		color = { .5, .5, .5, 1 },
		fontSize = 30, text = "Invisible UI (T)", textColor = 'L',
        sound_hover = 'menutap',
        onClick = function()
			if not GAME.invisUI then
				GAME.invisUI = true
				MSG('dark', "Invisible UI: On")
                SFX.play('t', 1, 0, Tone(6))
			else
				GAME.invisUI = false
				MSG('dark', "Invisible UI: Off")
			end
            GAME.refreshLayout()
            GAME.refreshUltra()
            GAME.refreshCurrentCombo()
            RefreshBGM()
            GAME.refreshRPC()
		end,
    },
	WIDGET.new {
        name = 'bleed', type = 'button',
        x = baseX + 660, y = baseY + 250, w = 380, h = 50,
		color = { .5, .5, .5, 1 },
		fontSize = 30, text = "Fast Leak (L)", textColor = 'L',
        sound_hover = 'menutap',
        onClick = function()
			if not GAME.fastLeak then
				GAME.fastLeak = true
				MSG('dark', "Fast Leak: On")
                SFX.play('l', 1, 0, Tone(6))
			else
				GAME.fastLeak = false
				MSG('dark', "Fast Leak: Off")
			end
            GAME.refreshLayout()
            GAME.refreshUltra()
            GAME.refreshCurrentCombo()
            RefreshBGM()
            GAME.refreshRPC()
		end,
    },
    WIDGET.new {
        name = 'close', type = 'button',
        x = baseX + 240, y = baseY + 325, w = 380, h = 50,
		color = { .5, .5, .5, 1 },
		fontSize = 30, text = "Close Cards (I)", textColor = 'L',
        sound_hover = 'menutap',
        onClick = function()
			if not GAME.closeCard then
				GAME.closeCard = true
				MSG('dark', "Close Cards: On")
                SFX.play('i', 1, 0, Tone(6))
			else
				GAME.closeCard = false
				MSG('dark', "Close Cards: Off")
			end
            GAME.refreshLayout()
            GAME.refreshUltra()
            GAME.refreshCurrentCombo()
            RefreshBGM()
            GAME.refreshRPC()
		end,
    },
    WIDGET.new {
        name = 'omit', type = 'button',
        x = baseX + 660, y = baseY + 325, w = 380, h = 50,
		color = { .5, .5, .5, 1 },
		fontSize = 30, text = "Redaction (R)", textColor = 'L',
        sound_hover = 'menutap',
        onClick = function()
			if not GAME.ryoshu then
				GAME.ryoshu = true
				MSG('dark', "Redacting: On")
                SFX.play('r', 1, 0, Tone(6))
			else
				GAME.ryoshu = false
				MSG('dark', "Redacting: Off")
			end
            GAME.refreshLayout()
            GAME.refreshUltra()
            GAME.refreshCurrentCombo()
            RefreshBGM()
            GAME.refreshRPC()
		end
    },
    WIDGET.new {
        name = 'nohit', type = 'button',
        x = baseX + 240, y = baseY + 400, w = 380, h = 50,
		color = { .5, .5, .5, 1 },
		fontSize = 30, text = "No-Hit (P)", textColor = 'L',
        sound_hover = 'menutap',
        onClick = function()
			if not GAME.noHit then
				GAME.noHit = true
				MSG('dark', "No-Hit: On")
                SFX.play('p', 1, 0, Tone(6))
			else
				GAME.noHit = false
				MSG('dark', "No-Hit: Off")
			end
            GAME.refreshLayout()
            GAME.refreshUltra()
            GAME.refreshCurrentCombo()
            RefreshBGM()
            GAME.refreshRPC()
		end,
    },
    WIDGET.new {
        name = 'grace', type = 'button',
        x = baseX + 660, y = baseY + 400, w = 380, h = 50,
		color = { .5, .5, .5, 1 },
		fontSize = 30, text = "Graceless (G)", textColor = 'L',
        sound_hover = 'menutap',
        onClick = function()
			if not GAME.graceless then
				GAME.graceless = true
				MSG('dark', "Graceless: On")
                SFX.play('g', 1, 0, Tone(6))
			else
				GAME.graceless = false
				MSG('dark', "Graceless: Off")
			end
            GAME.refreshLayout()
            GAME.refreshUltra()
            GAME.refreshCurrentCombo()
            RefreshBGM()
            GAME.refreshRPC()
		end,
    },
	WIDGET.new {
        name = 'ac', type = 'button',
        x = baseX + 440, y = baseY + 760, w = 380, h = 50,
		color = { .5, .5, .5, 1 },
		fontSize = 30, text = "ALL CLEAR", textColor = 'DL',
        sound_hover = 'menutap',
        onClick = function()
            PieceSFXID = 0
	    	GAME.nightcore = false
		    GAME.slowmo = false
		    GAME.glassCard = false
		    GAME.invisCard = false
		    GAME.invisUI = false
		    GAME.noHit = false
		    GAME.fastLeak = false
		    GAME.ryoshu = false
            GAME.graceless = false
            SFX.play('allclear')
            MSG('dark', "All Clear!")
            GAME.refreshLayout()
            GAME.refreshUltra()
            GAME.refreshCurrentCombo()
            RefreshBGM()
            GAME.refreshRPC()
		end,
    },
}

return scene