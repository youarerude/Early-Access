-- ═══════════════════════════════════════════════════════
--               NULLSCAPE EXPLOIT SCRIPT
--                    Codex Edition
-- ═══════════════════════════════════════════════════════

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

pcall(function()
    game:GetService("CoreGui"):FindFirstChild("NullscapeScript"):Destroy()
end)

-- ══════════════════════════════════════════════
--                  GUI SETUP
-- ══════════════════════════════════════════════

local SG = Instance.new("ScreenGui")
SG.Name           = "NullscapeScript"
SG.ResetOnSpawn   = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset = true
SG.Parent         = game:GetService("CoreGui")

local Win = Instance.new("Frame")
Win.Size             = UDim2.new(0, 400, 0, 340)
Win.Position         = UDim2.new(0.5, -200, 0.5, -170)
Win.BackgroundColor3 = Color3.fromRGB(10, 8, 20)
Win.BorderSizePixel  = 0
Win.Active           = true
Win.Draggable        = true
Win.Parent           = SG
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 10)
local WinStroke = Instance.new("UIStroke", Win)
WinStroke.Color     = Color3.fromRGB(75, 50, 155)
WinStroke.Thickness = 1.5

local TBar = Instance.new("Frame")
TBar.Size             = UDim2.new(1, 0, 0, 38)
TBar.BackgroundColor3 = Color3.fromRGB(18, 13, 40)
TBar.BorderSizePixel  = 0
TBar.ZIndex           = 2
TBar.Parent           = Win
Instance.new("UICorner", TBar).CornerRadius = UDim.new(0, 10)
local TBarPatch = Instance.new("Frame", TBar)
TBarPatch.Size             = UDim2.new(1, 0, 0.5, 0)
TBarPatch.Position         = UDim2.new(0, 0, 0.5, 0)
TBarPatch.BackgroundColor3 = Color3.fromRGB(18, 13, 40)
TBarPatch.BorderSizePixel  = 0
TBarPatch.ZIndex           = 2

local TIcon = Instance.new("TextLabel", TBar)
TIcon.Size               = UDim2.new(0, 24, 1, 0)
TIcon.Position           = UDim2.new(0, 10, 0, 0)
TIcon.BackgroundTransparency = 1
TIcon.Text               = "◈"
TIcon.TextColor3         = Color3.fromRGB(130, 90, 255)
TIcon.TextSize           = 17
TIcon.Font               = Enum.Font.GothamBold
TIcon.ZIndex             = 3

local TLabel = Instance.new("TextLabel", TBar)
TLabel.Size              = UDim2.new(1, -80, 1, 0)
TLabel.Position          = UDim2.new(0, 36, 0, 0)
TLabel.BackgroundTransparency = 1
TLabel.Text              = "Nullscape Script"
TLabel.TextColor3        = Color3.fromRGB(200, 175, 255)
TLabel.TextSize          = 13
TLabel.Font              = Enum.Font.GothamBold
TLabel.TextXAlignment    = Enum.TextXAlignment.Left
TLabel.ZIndex            = 3

local MinBtn = Instance.new("TextButton", TBar)
MinBtn.Size             = UDim2.new(0, 24, 0, 24)
MinBtn.Position         = UDim2.new(1, -32, 0.5, -12)
MinBtn.BackgroundColor3 = Color3.fromRGB(55, 38, 100)
MinBtn.BorderSizePixel  = 0
MinBtn.Text             = "─"
MinBtn.TextColor3       = Color3.fromRGB(190, 165, 255)
MinBtn.TextSize         = 12
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.ZIndex           = 3
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)

local CWrap = Instance.new("Frame", Win)
CWrap.Size               = UDim2.new(1, 0, 1, -38)
CWrap.Position           = UDim2.new(0, 0, 0, 38)
CWrap.BackgroundTransparency = 1
CWrap.ClipsDescendants   = true

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    CWrap.Visible = not minimized
    TweenService:Create(Win, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = minimized and UDim2.new(0, 400, 0, 38) or UDim2.new(0, 400, 0, 340)
    }):Play()
    MinBtn.Text = minimized and "+" or "─"
end)

local TabRow = Instance.new("Frame", CWrap)
TabRow.Size               = UDim2.new(1, -16, 0, 28)
TabRow.Position           = UDim2.new(0, 8, 0, 8)
TabRow.BackgroundTransparency = 1
local TabLayout = Instance.new("UIListLayout", TabRow)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding       = UDim.new(0, 4)

local CArea = Instance.new("Frame", CWrap)
CArea.Size             = UDim2.new(1, -16, 1, -44)
CArea.Position         = UDim2.new(0, 8, 0, 40)
CArea.BackgroundColor3 = Color3.fromRGB(16, 12, 30)
CArea.BorderSizePixel  = 0
CArea.ClipsDescendants = true
Instance.new("UICorner", CArea).CornerRadius = UDim.new(0, 8)
local CAreaStroke = Instance.new("UIStroke", CArea)
CAreaStroke.Color     = Color3.fromRGB(45, 35, 85)
CAreaStroke.Thickness = 1

-- ══════════════════════════════════════════════
--                   TABS
-- ══════════════════════════════════════════════

local TABS      = {"Gifts", "Environment", "Enemy", "Others"}
local tabFrames = {}
local tabBtns   = {}

local COL_ACTIVE   = Color3.fromRGB(85, 55, 165)
local COL_INACTIVE = Color3.fromRGB(28, 22, 52)

for _, name in ipairs(TABS) do
    local sf = Instance.new("ScrollingFrame", CArea)
    sf.Size                 = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel      = 0
    sf.ScrollBarThickness   = 3
    sf.ScrollBarImageColor3 = Color3.fromRGB(100, 70, 200)
    sf.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    sf.CanvasSize           = UDim2.new(0, 0, 0, 0)
    sf.Visible              = (name == "Gifts")
    tabFrames[name] = sf

    local ll = Instance.new("UIListLayout", sf)
    ll.Padding   = UDim.new(0, 5)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", sf)
    pad.PaddingLeft   = UDim.new(0, 8)
    pad.PaddingRight  = UDim.new(0, 8)
    pad.PaddingTop    = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)

    local btn = Instance.new("TextButton", TabRow)
    btn.Size             = UDim2.new(0, 88, 1, 0)
    btn.BackgroundColor3 = (name == "Gifts") and COL_ACTIVE or COL_INACTIVE
    btn.BorderSizePixel  = 0
    btn.Text             = name
    btn.TextColor3       = Color3.fromRGB(210, 190, 255)
    btn.TextSize         = 11
    btn.Font             = Enum.Font.GothamSemibold
    tabBtns[name] = btn
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(TABS) do
            tabFrames[t].Visible        = (t == name)
            -- Tween tab button color
            TweenService:Create(tabBtns[t], TweenInfo.new(0.12), {
                BackgroundColor3 = (t == name) and COL_ACTIVE or COL_INACTIVE
            }):Play()
        end
    end)
end

-- ══════════════════════════════════════════════
--             UI COMPONENT HELPERS
-- ══════════════════════════════════════════════

local function MakeSection(parent, text)
    local f = Instance.new("Frame", parent)
    f.Size               = UDim2.new(1, 0, 0, 24)
    f.BackgroundTransparency = 1

    local line = Instance.new("Frame", f)
    line.Size             = UDim2.new(1, 0, 0, 1)
    line.Position         = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = Color3.fromRGB(55, 42, 95)
    line.BorderSizePixel  = 0

    local lbl = Instance.new("TextLabel", f)
    lbl.Size             = UDim2.new(0, 0, 1, 0)
    lbl.AutomaticSize    = Enum.AutomaticSize.X
    lbl.Position         = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundColor3 = Color3.fromRGB(16, 12, 30)
    lbl.BorderSizePixel  = 0
    lbl.Text             = "  " .. text .. "  "
    lbl.TextColor3       = Color3.fromRGB(145, 110, 230)
    lbl.TextSize         = 10
    lbl.Font             = Enum.Font.GothamBold
    lbl.ZIndex           = 2
end

local function MakeToggle(parent, labelText, default, callback)
    local row = Instance.new("Frame", parent)
    row.Size             = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = Color3.fromRGB(22, 16, 42)
    row.BorderSizePixel  = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
    local rs = Instance.new("UIStroke", row)
    rs.Color     = Color3.fromRGB(50, 38, 92)
    rs.Thickness = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size             = UDim2.new(1, -58, 1, 0)
    lbl.Position         = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = labelText
    lbl.TextColor3       = Color3.fromRGB(210, 200, 230)
    lbl.TextSize         = 12
    lbl.Font             = Enum.Font.Gotham
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.TextWrapped      = true

    local pill = Instance.new("Frame", row)
    pill.Size             = UDim2.new(0, 42, 0, 22)
    pill.Position         = UDim2.new(1, -50, 0.5, -11)
    pill.BackgroundColor3 = default and Color3.fromRGB(85, 195, 85) or Color3.fromRGB(55, 45, 78)
    pill.BorderSizePixel  = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pill)
    knob.Size             = UDim2.new(0, 17, 0, 17)
    knob.Position         = default and UDim2.new(1, -19, 0.5, -8.5) or UDim2.new(0, 2, 0.5, -8.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel  = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state   = default
    local blocked = false

    local function Set(val)
        state = val
        -- TweenService for smooth pill + knob animation
        TweenService:Create(pill, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            BackgroundColor3 = val and Color3.fromRGB(85, 195, 85) or Color3.fromRGB(55, 45, 78)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            Position = val and UDim2.new(1, -19, 0.5, -8.5) or UDim2.new(0, 2, 0.5, -8.5)
        }):Play()
        -- Wrap callback in pcall so one bad feature never breaks others
        pcall(callback, val)
    end

    pill.InputBegan:Connect(function(inp)
        if (inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch)
            and not blocked then
            blocked = true
            Set(not state)
            task.delay(0.22, function() blocked = false end)
        end
    end)
end

local function MakeButton(parent, labelText, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(50, 32, 105)
    btn.BorderSizePixel  = 0
    btn.Text             = labelText
    btn.TextColor3       = Color3.fromRGB(210, 185, 255)
    btn.TextSize         = 12
    btn.Font             = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local bs = Instance.new("UIStroke", btn)
    bs.Color     = Color3.fromRGB(90, 60, 165)
    bs.Thickness = 1

    local blocked = false
    btn.MouseButton1Click:Connect(function()
        if blocked then return end
        blocked = true
        -- TweenService flash on press
        TweenService:Create(btn, TweenInfo.new(0.08), {
            BackgroundColor3 = Color3.fromRGB(80, 55, 155)
        }):Play()
        pcall(callback)
        task.delay(0.3, function()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(50, 32, 105)
            }):Play()
            blocked = false
        end)
    end)
end

-- ══════════════════════════════════════════════
--          AUTO-REMOVER FACTORY
--  Event-driven: one initial wipe, then
--  workspace.DescendantAdded fires instantly
--  when a new object spawns — zero polling loops.
-- ══════════════════════════════════════════════

local function MakeAutoRemover(namesList)
    local active     = false
    local connection = nil

    local function checkAndDestroy(obj)
        pcall(function()
            for _, n in ipairs(namesList) do
                if obj.Name == n then
                    pcall(function() obj:Destroy() end)
                    break
                end
            end
        end)
    end

    local function doRemove()
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                checkAndDestroy(obj)
            end
        end)
    end

    local function startFn()
        if active then return end
        active = true
        -- One-shot initial wipe (async so it doesn't stall)
        task.spawn(doRemove)
        -- Then let the game tell us whenever something new spawns
        connection = workspace.DescendantAdded:Connect(function(obj)
            if active then checkAndDestroy(obj) end
        end)
    end

    local function stopFn()
        active = false
        if connection then connection:Disconnect(); connection = nil end
    end

    return startFn, stopFn, doRemove
end

-- ══════════════════════════════════════════════
--  NEAREST-ONLY GIFT ESP
--  Scans for nearest Gift/GoldenGift every 0.5s.
--  Only ONE ESP active at a time — the closest one.
--  RenderStepped ONLY updates the line + label (no scan).
--  Everything wrapped in pcall.
-- ══════════════════════════════════════════════

local giftESP = (function()
    -- Persistent ESP objects (reused, not recreated every frame)
    local hl   = nil
    local bb   = nil
    local dl   = nil
    local ln   = nil

    local currentPart  = nil  -- the BasePart we're currently pointing at
    local scanActive   = false
    local renderConn   = nil
    local enabled      = false

    local function buildESPObjects(col)
        -- Destroy old ones safely
        pcall(function() if hl then hl:Destroy() end end)
        pcall(function() if bb then bb:Destroy() end end)
        pcall(function() if ln then ln:Remove()  end end)

        hl = Instance.new("Highlight")
        hl.OutlineColor        = col
        hl.FillColor           = col
        hl.FillTransparency    = 0.80
        hl.OutlineTransparency = 0
        hl.Parent              = workspace

        bb = Instance.new("BillboardGui")
        bb.Size                  = UDim2.new(0, 150, 0, 26)
        bb.StudsOffsetWorldSpace = Vector3.new(0, 5, 0)
        bb.AlwaysOnTop           = true
        bb.Parent                = workspace

        dl = Instance.new("TextLabel", bb)
        dl.Size                   = UDim2.new(1, 0, 1, 0)
        dl.BackgroundTransparency = 1
        dl.Text                   = "? studs Away"
        dl.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
        dl.TextStrokeTransparency = 0.35
        dl.TextSize               = 13
        dl.Font                   = Enum.Font.GothamBold
        dl.TextColor3             = col

        ln             = Drawing.new("Line")
        ln.Thickness   = 1.5
        ln.Color       = col
        ln.Transparency = 0.25
        ln.Visible     = false
    end

    local function clearESP()
        pcall(function() if hl then hl:Destroy() end end)
        pcall(function() if bb then bb:Destroy() end end)
        pcall(function() if ln then ln:Remove()  end end)
        hl = nil; bb = nil; dl = nil; ln = nil
        currentPart = nil
    end

    local function start()
        clearESP()
        enabled    = true
        scanActive = true

        -- Pool of known gifts maintained by events — no workspace polling
        local giftPool   = {}
        local addConn    = nil
        local removeConn = nil

        local function tryAddGift(obj)
            pcall(function()
                if obj.Name ~= "Gift" and obj.Name ~= "GoldenGift" then return end
                local part
                if obj:IsA("BasePart") then
                    part = obj
                elseif obj:IsA("Model") then
                    part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                end
                if part then giftPool[obj] = part end
            end)
        end

        -- One-time seed of whatever gifts already exist
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do tryAddGift(obj) end
        end)

        addConn = workspace.DescendantAdded:Connect(function(obj)
            if scanActive then tryAddGift(obj) end
        end)
        removeConn = workspace.DescendantRemoving:Connect(function(obj)
            giftPool[obj] = nil
        end)

        -- Lightweight loop: picks nearest from pool — never scans workspace
        task.spawn(function()
            while scanActive do
                pcall(function()
                    local char = LP.Character
                    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end

                    local bestPart = nil
                    local bestDist = math.huge
                    local bestObj  = nil

                    for obj, part in pairs(giftPool) do
                        if obj.Parent and part.Parent then
                            local d = (hrp.Position - part.Position).Magnitude
                            if d < bestDist then
                                bestDist = d
                                bestPart = part
                                bestObj  = obj
                            end
                        else
                            giftPool[obj] = nil
                        end
                    end

                    if bestObj and bestPart then
                        local isGold = (bestObj.Name == "GoldenGift")
                        local col    = isGold
                            and Color3.fromRGB(255, 215, 50)
                            or  Color3.fromRGB(110, 230, 255)
                        if currentPart ~= bestPart then
                            buildESPObjects(col)
                            currentPart = bestPart
                        end
                        if hl then hl.Adornee = bestObj  end
                        if bb then bb.Adornee = bestPart end
                    else
                        if ln then pcall(function() ln.Visible = false end) end
                        currentPart = nil
                    end
                end)

                task.wait(0.5)
            end

            if addConn    then addConn:Disconnect()    end
            if removeConn then removeConn:Disconnect() end
        end)

        -- Render loop: ONLY updates line position + distance text
        -- No scans, no Instance creation — extremely lightweight
        renderConn = RunService.RenderStepped:Connect(function()
            if not enabled then return end
            pcall(function()
                if not currentPart or not currentPart.Parent then
                    if ln then ln.Visible = false end
                    return
                end

                local char = LP.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then
                    if ln then ln.Visible = false end
                    return
                end

                -- Distance text
                local dist = (hrp.Position - currentPart.Position).Magnitude
                if dl then dl.Text = math.floor(dist) .. " studs Away" end

                -- Line: depth = sp.Z (NOT a 3rd return value)
                local vp     = Camera.ViewportSize
                local botMid = Vector2.new(vp.X * 0.5, vp.Y)
                local sp, onScreen = Camera:WorldToViewportPoint(currentPart.Position)
                local depth = sp.Z

                if ln then
                    if onScreen and depth > 0 then
                        ln.From    = botMid
                        ln.To      = Vector2.new(sp.X, sp.Y)
                        ln.Visible = true
                    else
                        ln.Visible = false
                    end
                end
            end)
        end)
    end

    local function stop()
        enabled    = false
        scanActive = false
        if renderConn then renderConn:Disconnect(); renderConn = nil end
        clearESP()
    end

    local function hideLines()
        pcall(function() if ln then ln.Visible = false end end)
    end

    return { start = start, stop = stop, hideLines = hideLines }
end)()

-- ══════════════════════════════════════════════
--  MULTI-TARGET ESP (Altars — all, not nearest)
--  pcall wrapped throughout. Scan in task.spawn,
--  lines updated in RenderStepped only.
-- ══════════════════════════════════════════════

local function MakeESP(namesList, espColor, yOffset, labelPrefix)
    local tracked    = {}
    local scanActive = false
    local renderConn = nil
    local esp        = { enabled = false }

    local function clearAll()
        for _, d in pairs(tracked) do
            pcall(function() d.highlight:Destroy() end)
            pcall(function() d.billboard:Destroy() end)
            pcall(function() d.line:Remove()        end)
        end
        tracked = {}
    end

    local function attachESP(obj)
        pcall(function()
            for _, n in ipairs(namesList) do
                if obj.Name == n then
                    if tracked[obj] then return end  -- already tracked
                    local part
                    if obj:IsA("BasePart") then
                        part = obj
                    elseif obj:IsA("Model") then
                        part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    end
                    if not part then return end

                    local col = type(espColor) == "function" and espColor(obj) or espColor

                    local hl = Instance.new("Highlight")
                    hl.OutlineColor        = col
                    hl.FillColor           = col
                    hl.FillTransparency    = 0.80
                    hl.OutlineTransparency = 0
                    hl.Adornee             = obj
                    hl.Parent              = workspace

                    local bb = Instance.new("BillboardGui")
                    bb.Size                  = UDim2.new(0, 150, 0, 26)
                    bb.StudsOffsetWorldSpace = Vector3.new(0, yOffset or 5, 0)
                    bb.AlwaysOnTop           = true
                    bb.Adornee               = part
                    bb.Parent                = workspace

                    local dl = Instance.new("TextLabel", bb)
                    dl.Size                   = UDim2.new(1, 0, 1, 0)
                    dl.BackgroundTransparency = 1
                    dl.Text                   = "? studs Away"
                    dl.TextColor3             = col
                    dl.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
                    dl.TextStrokeTransparency = 0.35
                    dl.TextSize               = 13
                    dl.Font                   = Enum.Font.GothamBold

                    local ln        = Drawing.new("Line")
                    ln.Thickness    = 1.5
                    ln.Color        = col
                    ln.Transparency = 0.25
                    ln.Visible      = false

                    tracked[obj] = { part = part, highlight = hl,
                                     billboard = bb, distLbl = dl, line = ln }
                    break
                end
            end
        end)
    end

    local espAddConn    = nil
    local espRemoveConn = nil

    function esp.start()
        clearAll()
        esp.enabled = true
        scanActive  = true

        -- Seed with existing objects (one scan only)
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do attachESP(obj) end
        end)

        -- Event-driven from here on — no more polling loops
        espAddConn = workspace.DescendantAdded:Connect(function(obj)
            if esp.enabled then attachESP(obj) end
        end)
        espRemoveConn = workspace.DescendantRemoving:Connect(function(obj)
            local d = tracked[obj]
            if d then
                pcall(function() d.highlight:Destroy() end)
                pcall(function() d.billboard:Destroy() end)
                pcall(function() d.line:Remove()        end)
                tracked[obj] = nil
            end
        end)

        renderConn = RunService.RenderStepped:Connect(function()
            if not esp.enabled then return end
            pcall(function()
                local char = LP.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then
                    for _, d in pairs(tracked) do d.line.Visible = false end
                    return
                end

                local vp     = Camera.ViewportSize
                local botMid = Vector2.new(vp.X * 0.5, vp.Y)

                for _, d in pairs(tracked) do
                    pcall(function()
                        local part = d.part
                        if not part or not part.Parent then
                            d.line.Visible = false
                            return
                        end

                        local dist = (hrp.Position - part.Position).Magnitude
                        d.distLbl.Text = (labelPrefix and labelPrefix .. " " or "")
                            .. math.floor(dist) .. " studs Away"

                        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                        local depth = sp.Z  -- depth is sp.Z, never a 3rd return

                        if onScreen and depth > 0 then
                            d.line.From    = botMid
                            d.line.To      = Vector2.new(sp.X, sp.Y)
                            d.line.Visible = true
                        else
                            d.line.Visible = false
                        end
                    end)
                end
            end)
        end)
    end

    function esp.stop()
        esp.enabled = false
        scanActive  = false
        if renderConn    then renderConn:Disconnect();    renderConn    = nil end
        if espAddConn    then espAddConn:Disconnect();    espAddConn    = nil end
        if espRemoveConn then espRemoveConn:Disconnect(); espRemoveConn = nil end
        clearAll()
    end

    function esp.hideLines()
        for _, d in pairs(tracked) do
            pcall(function() d.line.Visible = false end)
        end
    end

    return esp
end

-- ══════════════════════════════════════════════
--              FEATURE INSTANCES
-- ══════════════════════════════════════════════

local AltarESP = MakeESP(
    {"AltarModel"},
    Color3.fromRGB(255, 140, 50),
    6, "Altar"
)

local startTripmine,  stopTripmine,  manualTripmine  = MakeAutoRemover({"Tripmine", "Gold Tripmine"})

-- Enemy folder remover — targets the "Enemy" folder directly
local function MakeEnemyFolderRemover()
    local active     = false
    local connection = nil

    local function doRemove()
        pcall(function()
            local folder = workspace:FindFirstChild("Enemy")
            if folder then
                for _, obj in ipairs(folder:GetChildren()) do
                    pcall(function() obj:Destroy() end)
                end
            end
        end)
    end

    local function startFn()
        if active then return end
        active = true
        task.spawn(doRemove)
        -- Instantly destroy anything added to the Enemy folder
        connection = workspace.DescendantAdded:Connect(function(obj)
            if not active then return end
            pcall(function()
                local parent = obj.Parent
                if parent and parent.Name == "Enemy" then
                    pcall(function() obj:Destroy() end)
                end
            end)
        end)
    end

    local function stopFn()
        active = false
        if connection then connection:Disconnect(); connection = nil end
    end

    return startFn, stopFn, doRemove
end

local startAllEnemies, stopAllEnemies, manualAllEnemies = MakeEnemyFolderRemover()
local startBell,      stopBell,      manualBell      = MakeAutoRemover({"Bell"})
local startMart,      stopMart,      manualMart      = MakeAutoRemover({"Mart"})
local startSpringer,  stopSpringer,  manualSpringer  = MakeAutoRemover({"Springer"})
local startShockwave, stopShockwave                  = MakeAutoRemover({"DemonShockwave", "SpringerShockwave"})
local startICBM,      stopICBM,      manualICBM      = MakeAutoRemover({"ICBM"})
local startOperator,  stopOperator,  manualOperator  = MakeAutoRemover({"Operator"})

-- ══════════════════════════════════════════════
--               POPULATE TABS
-- ══════════════════════════════════════════════

-- GIFTS
MakeSection(tabFrames["Gifts"], "Gift")
MakeToggle(tabFrames["Gifts"], "Nearest Gift ESP", false, function(val)
    if val then giftESP.start() else giftESP.stop() end
end)

-- ENVIRONMENT
MakeSection(tabFrames["Environment"], "Environment")
MakeToggle(tabFrames["Environment"], "Remove Tripmine", false, function(val)
    if val then startTripmine() else stopTripmine() end
end)
MakeButton(tabFrames["Environment"], "Manual Remove Tripmine", manualTripmine)

-- ENEMY
MakeSection(tabFrames["Enemy"], "Everything")
MakeToggle(tabFrames["Enemy"], "Delete All Enemies", false, function(val)
    if val then startAllEnemies() else stopAllEnemies() end
end)
MakeButton(tabFrames["Enemy"], "Manual Delete Enemies", manualAllEnemies)

MakeSection(tabFrames["Enemy"], "Bell")
MakeToggle(tabFrames["Enemy"], "Remove Bell", false, function(val)
    if val then startBell() else stopBell() end
end)
MakeButton(tabFrames["Enemy"], "Manual Remove Bell", manualBell)

MakeSection(tabFrames["Enemy"], "Mart")
MakeToggle(tabFrames["Enemy"], "Remove Mart", false, function(val)
    if val then startMart() else stopMart() end
end)
MakeButton(tabFrames["Enemy"], "Manual Remove Mart", manualMart)

MakeSection(tabFrames["Enemy"], "Springer")
MakeToggle(tabFrames["Enemy"], "Remove Springer", false, function(val)
    if val then startSpringer() else stopSpringer() end
end)
MakeButton(tabFrames["Enemy"], "Manual Remove Springer", manualSpringer)
MakeToggle(tabFrames["Enemy"], "Remove Shockwave", false, function(val)
    if val then startShockwave() else stopShockwave() end
end)

MakeSection(tabFrames["Enemy"], "ICBM")
MakeToggle(tabFrames["Enemy"], "Remove ICBM", false, function(val)
    if val then startICBM() else stopICBM() end
end)
MakeButton(tabFrames["Enemy"], "Manual Remove ICBM", manualICBM)

MakeSection(tabFrames["Enemy"], "Operator")
MakeToggle(tabFrames["Enemy"], "Remove Operator", false, function(val)
    if val then startOperator() else stopOperator() end
end)
MakeButton(tabFrames["Enemy"], "Manual Remove Operator", manualOperator)

-- OTHERS
MakeSection(tabFrames["Others"], "Altar")
MakeToggle(tabFrames["Others"], "ESP Altars", false, function(val)
    if val then AltarESP.start() else AltarESP.stop() end
end)

-- ══════════════════════════════════════════════
--              CLEANUP ON RESPAWN
-- ══════════════════════════════════════════════

LP.CharacterRemoving:Connect(function()
    pcall(function() giftESP.hideLines() end)
    pcall(function() AltarESP.hideLines() end)
end)

print("[NullscapeScript] Loaded ✓")
