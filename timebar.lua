TB = {}
TB.gfxAlignWidth = 0.952
TB.gfxAlignHeight = 0.949

TB.initialX = 0.795
TB.initialY = 0.923
TB.initialBusySpinnerY = 0.887

TB.bgBaseX = 0.874
TB.progressBaseX = 0.913
TB.checkpointBaseX = 0.9445

TB.bgOffset = 0.008
TB.bgThinOffset = 0.012
TB.textOffset = -0.006
TB.playerTitleOffset = -0.005
TB.barOffset = 0.012
TB.checkpointOffsetX = 0.0094
TB.checkpointOffsetY = 0.012

TB.timerBarWidth = 0.165
TB.timerBarHeight = 0.035
TB.timerBarThinHeight = 0.028
TB.timerBarMargin = 0.0399
TB.timerBarThinMargin = 0.0319

TB.progressWidth = 0.069
TB.progressHeight = 0.011

TB.checkpointWidth = 0.012
TB.checkpointHeight = 0.023

TB.titleScale = 0.288
TB.titleWrap = 0.867
TB.textScale = 0.494
TB.textWrap = 0.95
TB.playertitleScale = 0.447
TB.timebarUnique = 0

function DrawTextLabel(label, position, options)

    SetTextFont(options.font)
    SetTextScale(0.0, options.scale)
    SetTextColour(options.color[1], options.color[2], options.color[3], options.color[4])
    SetTextJustification(options.justification);

    if options.wrap then
        SetTextWrap(0.0, options.wrap);
    end

    if options.shadow then
        SetTextDropShadow()
    end

    if options.outline then
        SetTextOutline()
    end

    BeginTextCommandDisplayText(label);
    EndTextCommandDisplayText(position[1], position[2]);
end

function CreateTimeBarBase(title)
    local o = {}

    -- assign unique ID
    TB.timebarUnique = TB.timebarUnique + 1

    o._id = TB.timebarUnique

    -- set initial styling props
    o._thin = false
    o._highlightColor = nil

    -- assign TextEntry for title
    o._titleGxtName = "TMRB_TITLE_" .. o._id
    o._title = title
    AddTextEntry(o._titleGxtName, title)

    -- set initial styling for title
    o.titleDrawParams = {
        font = 0,
        color = {240, 240, 240, 255},
        scale = TB.titleScale,
        justification = 2,
        wrap = TB.titleWrap,
        shadow = false,
        outline = false
    }

    -- set new title
    o.setTitle = function(title)
        o._title = title
        AddTextEntry(o._titleGxtName, title)
    end

    -- set new title color
    o.setTitleColor = function(titleColor)
        o.titleDrawParams.color = titleColor
    end

    -- set new highlight color
    o.setHighlightColor = function(highlightColor)
        o._highlightColor = highlightColor
    end

    -- draw background
    o.drawBackground = function(y)
        y = y + (o._thin and TB.bgThinOffset or TB.bgThinOffset)

        -- draw highlight side of gradient, if it's set
        if o._highlightColor then
            DrawSprite("timerbars", "all_white_bg", TB.bgBaseX, y, TB.timerBarWidth,
                (o._thin and TB.timerBarThinHeight or TB.timerBarHeight), 0.0, o._highlightColor[1],
                o._highlightColor[2], o._highlightColor[3], o._highlightColor[4])
        end
        -- draw black side of gradient background
        DrawSprite("timerbars", "all_black_bg", TB.bgBaseX, y, TB.timerBarWidth,
            (o._thin and TB.timerBarThinHeight or TB.timerBarHeight), 0.0, 255, 255, 255, 140)
    end

    -- draw title
    o.drawTitle = function(y)
        DrawTextLabel(o._titleGxtName, {TB.initialX, y}, o.titleDrawParams)
    end

    -- draw
    o.draw = function(y)
        -- draws background & title
        o.drawBackground(y)
        o.drawTitle(y)
    end
    return o
end

function CreateBarTimerBar(title, progress)
    local o = {}

    -- create base class
    o.base = CreateTimeBarBase(title)

    -- progress background and fill props
    o._bgColor = {155, 155, 155, 255};
    o._fgColor = {240, 240, 240, 255};
    o._fgWidth = 0.0;
    o._fgX = 0.0;

    -- set new progress
    o.setProgress = function(v)
        o._progress = Clamp(v, 0.0, 1.0)
        o._fgWidth = TB.progressWidth * o._progress
        o._fgX = (TB.progressBaseX - TB.progressWidth * 0.5) + (o._fgWidth * 0.5)
    end

    o.draw = function(y)
        -- draw TimerBarBase
        o.base.draw(y)

        -- draw progress
        y = y + TB.barOffset
        -- progress background
        DrawRect(TB.progressBaseX, y, TB.progressWidth, TB.progressHeight, o._bgColor[1], o._bgColor[2], o._bgColor[3],
            o._bgColor[4])
        -- progress fill
        DrawRect(o._fgX, y, o._fgWidth, TB.progressHeight, o._fgColor[1], o._fgColor[2], o._fgColor[3], o._fgColor[4])
    end

    -- set initial progress 
    o._progress = progress;

    -- show initial progress
    o.setProgress(progress)

    o.setHighlightColor = o.base.setHighlightColor
    o.setTitleColor = o.base.setTitleColor
    return o
end

function CreateTextTimeBar(title, text)
    local o = {}

    -- create base class
    o.base = CreateTimeBarBase(title)

    -- assign TextEntry for text
    o._textGxtName = "TMRB_TEXT_" .. o.base._id
    o._text = text
    AddTextEntry(o._textGxtName, text)

    -- assign defailt text params
    o.textDrawParams = {
        font = 0,
        color = {238, 232, 170, 255},
        scale = TB.textScale,
        justification = 2,
        wrap = TB.textWrap
    };

    o.setTextColor = function(color)
        o.textDrawParams.color = color
    end

    -- draw
    o.draw = function(y)
        -- draw TimerBarBase
        o.base.draw(y)
        -- draw text
        y = y + TB.textOffset;
        DrawTextLabel(o._textGxtName, {TB.initialX, y}, o.textDrawParams)
    end

    o.setHighlightColor = o.base.setHighlightColor
    o.setTitleColor = o.base.setTitleColor

    return o
end

function CreatePlayerTimeBar(title, text)
    local o = {}

    -- create base class
    o.base = CreateTextTimeBar(title, text)

    -- override TextTimeBars title styling 
    local titleDrawParams = o.base.base.titleDrawParams
    titleDrawParams.font = 4
    titleDrawParams.color = {238, 232, 170, 255}
    titleDrawParams.scale = TB.playertitleScale
    titleDrawParams.justification = 2
    titleDrawParams.wrap = TB.titleWrap
    titleDrawParams.shadow = true

    o.draw = function(y)
        -- draw TimerBarBase background
        o.base.base.drawBackground(y)
        -- draw title
        DrawTextLabel(o.base.base._titleGxtName, {TB.initialX, y + TB.playerTitleOffset}, titleDrawParams)
        -- draw text
        DrawTextLabel(o.base._textGxtName, {TB.initialX, y + TB.textOffset}, o.base.textDrawParams)
    end

    o.setTextColor = o.base.setTextColor
    o.setHighlightColor = o.base.base.setHighlightColor
    o.setTitleColor = o.base.base.setTitleColor

    return o
end

function CreateCheckpointTimeBar(title, numCheckpoints)
    local o = {}

    -- create base class
    o.base = CreateTimeBarBase(title)
    o.base._thin = true

    -- checkpoints
    o._checkpointStates = {}
    o._numCheckpoints = numCheckpoints

    -- colors
    o._color = {113, 204, 111, 255}
    o._inProgressColor = {255, 255, 255, 51}
    o._failedColor = {0, 0, 0, 255}

    -- initialize list
    for i = 1, numCheckpoints, 1 do
        o._checkpointStates[i] = 0
    end

    -- set value on all checkpoints
    o.toggleAll = function(toggle)
        for i = 1, numCheckpoints, 1 do
            o._checkpointStates[i] = toggle
        end
    end

    -- set all checkpoints checked
    o.checkAll = function()
        o.toggleAll(1)
    end

    -- set all checkpoints unchecked
    o.uncheckAll = function()
        o.toggleAll(0)
    end

    -- set checkpoint state
    o.setCheckpointState = function(index, state)
        if o._checkpointStates[index] == nil then
            return
        end
        o._checkpointStates[index] = state
    end

    -- draw
    o.draw = function(y)
        o.base.draw(y)
        y = y + TB.checkpointOffsetY

        local cpX = TB.checkpointBaseX

        for i = 1, o._numCheckpoints, 1 do
            local state = o._checkpointStates[i]
            local drawColor = (state == 0 and o._inProgressColor or (state == -1 and o._failedColor or o._color))
            DrawSprite("timerbars", "circle_checkpoints", cpX, y, TB.checkpointWidth, TB.checkpointHeight, 0.0,
                drawColor[1], drawColor[2], drawColor[3], drawColor[4])
            cpX = cpX - TB.checkpointOffsetX;
        end
    end

    o.setHighlightColor = o.base.setHighlightColor
    o.setTitleColor = o.base.setTitleColor

    return o
end

function DrawTimeBars(bars)

    HideHudComponentThisFrame(6); -- HUD_VEHICLE_NAME
    HideHudComponentThisFrame(7); -- HUD_AREA_NAME
    HideHudComponentThisFrame(8); -- HUD_VEHICLE_CLASS
    HideHudComponentThisFrame(9); -- HUD_STREET_NAME

    local busySpinner = BusyspinnerIsOn()
    local drawY = (busySpinner and TB.initialBusySpinnerY or TB.initialY)

    SetScriptGfxAlign(82, 66)
    SetScriptGfxAlignParams(0.0, 0.0, TB.gfxAlignWidth, TB.gfxAlignHeight)

    for _, v in pairs(bars) do
        v.draw(drawY)
        drawY = drawY - (v.base._thin and TB.timerBarThinMargin or TB.timerBarMargin);
    end

    ResetScriptGfxAlign()
end

RegisterCommand("tb", function(source, args, rawCommand)

    CreateThread(function()
        RequestStreamedTextureDict("timerbars")

        while not HasStreamedTextureDictLoaded("timerbars") do
            Wait(33)
        end

        local bars = {CreateBarTimerBar("STRENGTH", 0.5), CreatePlayerTimeBar("3st: Robin", "$0"),
                      CreatePlayerTimeBar("2st: Xogos", "$10 000"),
                      CreatePlayerTimeBar("1st: SomeStupidGuyWithALongNickName", "$50 000"),
                      CreateTextTimeBar("JUMP OR DIE", "0:10"), CreateTextTimeBar("LUCKY WHEEL COOLDOWN", "05:30"),
                      CreateCheckpointTimeBar("BASES", 5)}

        bars[2].setTextColor({167, 136, 115, 255})
        bars[2].setTitleColor({167, 136, 115, 255})

        bars[3].setTextColor({155, 155, 155, 255})
        bars[3].setTitleColor({155, 155, 155, 255})

        bars[4].setTextColor({202, 181, 128, 255})
        bars[4].setTitleColor({202, 181, 128, 255})

        bars[5].setTextColor({203, 57, 58, 255})
        bars[5].setHighlightColor({203, 57, 58, 255})

        bars[6].setTextColor({114, 167, 81, 255})
        bars[6].setHighlightColor({114, 167, 81, 255})

        bars[7].setCheckpointState(1, 1)

        while true do
            DrawTimeBars(bars)
            Wait(0)
        end

    end)

end)
