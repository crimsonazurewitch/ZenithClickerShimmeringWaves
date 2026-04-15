local warpPS = GC.newParticleSystem(TEXTURE.lightDot, 512)
warpPS:setEmissionRate(126)
warpPS:setLinearDamping(1)
warpPS:setParticleLifetime(1.26, 2.6)
warpPS:setDirection(1.5708)
local warpPSlastT
return {
    duration = 10,
    switchTime = 7.2,
    init = function()
        warpPS:setEmissionArea('normal', SCR.w, SCR.h * .0026)
        local k = .62 * SCR.k
        warpPS:setSizes(.42 * k, 1 * k, .9 * k, .8 * k, .7 * k, .62 * k, .42 * k)
        warpPS:setParticleLifetime(1.26, 2.6)
        warpPS:setColors(
            1, 1, 1, 0,
            1, 1, 1, 1,
            1, 1, 1, .626,
            1, 1, 1, 0
        )
        warpPS:setSpeed(0)
        warpPS:reset()
        warpPS:start()
        warpPSlastT = 0
    end,
    draw = function(t)
        if warpPSlastT < .62 and t > .62 then
            warpPS:setParticleLifetime(2.6, 4.2)
            warpPS:setSizes(SCR.k * .62)
            warpPS:setColors(
                1, 1, 1, 1,
                1, 1, 1, 0
            )
            warpPS:setSpeed(120, 420)
            warpPS:emit(42)
            warpPS:setSpeed(-120, -420)
            warpPS:emit(42)
            warpPS:stop()
        end
        warpPS:update((t - warpPSlastT) * 10)
        warpPSlastT = t
        if t >= .3 then
            GC.setColor(0, 0, 0, MATH.iLerp(1, .7, t))
            GC.rectangle('fill', 0, 0, SCR.w, SCR.h)
            GC.setColor(.85, .85, .85, MATH.iLerp(1, .7, t))
            GC.mRect('fill', SCR.w / 2, SCR.h / 2, SCR.w, MATH.lerp(SCR.h * .005, SCR.h * 1.26, MATH.icLerp(.64, .75, t) ^ 2))
            GC.setColor(1, 1, 1, MATH.iLerp(.872, .62, t))
            GC.draw(warpPS, SCR.w / 2, SCR.h / 2)
        end
        local a1 = 1 - math.abs(t - .3) * 20
        if a1 > 0 then
            GC.setColor(.85, .85, .85, a1)
            GC.rectangle('fill', 0, 0, SCR.w, SCR.h)
        end
        local a2 = 1 - math.abs(t - .62) * 42
        if a2 > 0 then
            GC.setColor(.62, .62, .62, a2)
            GC.rectangle('fill', 0, 0, SCR.w, SCR.h)
        end
    end,
}