-- =============================================
--         Fatal Floors Script
--         Made by Wrath
--         Version 1.3
-- =============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- =============================================
-- STATE
-- =============================================

local autocollectOreEnabled = false
local autocollectOreThread = nil

local autocollectShardEnabled = false
local autocollectShardThread = nil

local autoSellEnabled = false
local autoSellThread = nil

local oreNames = {"Iron Ore", "Jade Ore", "Amber Ore", "Amethyst Ore", "Gold Ore"}

-- =============================================
-- UTILITY
-- =============================================

local function safeTeleport(target)
    if not target then return end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
    end
end

local function isInventoryFull()
    local toolCount = 0
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then toolCount += 1 end
        end
    end
    local char = player.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then toolCount += 1 end
        end
    end
    return toolCount >= 2
end

local function getOresInInventory()
    local ores = {}
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then table.insert(ores, item) end
        end
    end
    local char = player.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then table.insert(ores, item) end
        end
    end
    return ores
end

local function findMapPart()
    local placedTiles = workspace:FindFirstChild("PlacedTiles")
        or workspace:FindFirstChild("PlacedTiles", true)
    if not placedTiles then warn("[FFS] PlacedTiles not found!") return nil end
    local map = placedTiles:FindFirstChild("Map", true)
    if map then
        if map:IsA("BasePart") then return map end
        local part = map:FindFirstChildWhichIsA("BasePart", true)
        if part then return part end
    end
    warn("[FFS] Map not found inside PlacedTiles!")
    return nil
end

local function findSellingSpot()
    -- Search entire workspace regardless of parent
    local spot = workspace:FindFirstChild("SellingSpot", true)
    if spot then
        if spot:IsA("BasePart") then return spot end
        local part = spot:FindFirstChildWhichIsA("BasePart", true)
        if part then return part end
    end
    warn("[FFS] SellingSpot not found in workspace!")
    return nil
end

local function fireNearbyProximityPrompts(position, radius)
    radius = radius or 15
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            local partPos
            if parent:IsA("BasePart") then
                partPos = parent.Position
            else
                local bp = parent:FindFirstChildWhichIsA("BasePart")
                if bp then partPos = bp.Position end
            end
            if partPos and (partPos - position).Magnitude <= radius then
                pcall(function() fireproximityprompt(obj) end)
            end
        end
    end
end

local function updateStatus(label, text, color)
    if label and label.Parent then
        label.Text = "Status: " .. text
        label.TextColor3 = color or Color3.fromRGB(110, 110, 110)
    end
end

local function sendChat(msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = "[Wrath] " .. msg,
            Color = Color3.fromRGB(255, 80, 80),
            Font = Enum.Font.GothamBold,
            FontSize = Enum.FontSize.Size18
        })
    end)
    local fired = false
    pcall(function()
        if not fired then
            game:GetService("ReplicatedStorage")
                .DefaultChatSystemChatEvents
                .SayMessageRequest:FireServer(msg, "All")
            fired = true
        end
    end)
    if not fired then
        pcall(function()
            for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if obj:IsA("RemoteEvent") and obj.Name == "SayMessageRequest" then
                    obj:FireServer(msg, "All")
                    fired = true
                    break
                end
            end
        end)
    end
    if not fired then
        pcall(function()
            local tcs = game:GetService("TextChatService")
            local channel = tcs:FindFirstChild("TextChannels")
                and tcs.TextChannels:FindFirstChild("RBXGeneral")
            if channel then
                channel:SendAsync(msg)
            end
        end)
    end
end

-- =============================================
-- ORE FINDER
-- =============================================

local function findOrePart(oreName)
    local generated = workspace:FindFirstChild("ProcGenGenerated")
        or workspace:FindFirstChild("ProcGenGenerated", true)
    if not generated then return nil end
    local items = generated:FindFirstChild("ProcGenItems")
        or generated:FindFirstChild("ProcGenItems", true)
    if not items then return nil end
    for _, obj in ipairs(items:GetDescendants()) do
        if obj.Name == oreName then
            if obj:IsA("BasePart") then return obj end
            if obj:IsA("Model") then
                if obj.PrimaryPart then return obj.PrimaryPart end
                local part = obj:FindFirstChildWhichIsA("BasePart", true)
                if part then return part end
            end
        end
    end
    return nil
end

-- =============================================
-- SHARD FINDER
-- =============================================

local function findShards()
    local generated = workspace:FindFirstChild("ProcGenGenerated")
        or workspace:FindFirstChild("ProcGenGenerated", true)
    if not generated then warn("[FFS] ProcGenGenerated not found!") return {} end
    local shards = {}
    for _, obj in ipairs(generated:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Shard" then
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("UnionOperation") and child.Name == "Shard" then
                    table.insert(shards, child)
                end
            end
        end
    end
    return shards
end

-- =============================================
-- SELL SEQUENCE (shared by both loops)
-- =============================================

local function sellAllOres(statusLabel)
    local spot = findSellingSpot()
    if not spot then
        warn("[FFS] SellingSpot not found, cannot sell!")
        return
    end

    local ores = getOresInInventory()
    if #ores == 0 then return end

    safeTeleport(spot)
    task.wait(0.2)

    for _, ore in ipairs(ores) do
        if not ore or not ore.Parent then continue end

        updateStatus(statusLabel, "Selling " .. ore.Name .. "...", Color3.fromRGB(255, 200, 50))
        safeTeleport(spot)
        task.wait(0.1)

        -- Spam prox prompts until ore leaves inventory
        local attempts = 0
        while ore and ore.Parent and attempts < 60 do
            safeTeleport(spot)
            task.wait(0.05)
            fireNearbyProximityPrompts(spot.Position, 15)
            attempts += 1
            task.wait(0.08)
        end

        task.wait(0.1)
    end
end

-- =============================================
-- AUTOCOLLECT ORE LOOP
-- =============================================

local function autocollectOreLoop(statusLabel)
    while autocollectOreEnabled do

        if isInventoryFull() then
            if autoSellEnabled then
                -- Combined mode: sell instead of waiting
                updateStatus(statusLabel, "Inventory Full! Selling ores...", Color3.fromRGB(255, 180, 30))
                sellAllOres(statusLabel)
                updateStatus(statusLabel, "Sold! Resuming collection...", Color3.fromRGB(60, 200, 80))
                task.wait(0.5)
            else
                -- Standalone mode: go to map and wait
                updateStatus(statusLabel, "Inventory Full! Waiting...", Color3.fromRGB(255, 180, 30))
                local mapPart = findMapPart()
                if mapPart then safeTeleport(mapPart) end
                sendChat("Your Inventory is full go sell the ores.")
                while autocollectOreEnabled and isInventoryFull() do
                    task.wait(0.8)
                end
                updateStatus(statusLabel, "Collecting ores...", Color3.fromRGB(60, 200, 80))
                task.wait(0.5)
            end
            continue
        end

        -- Shuffle ores
        local shuffled = table.clone(oreNames)
        for i = #shuffled, 2, -1 do
            local j = math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end

        local collectedAny = false

        for _, oreName in ipairs(shuffled) do
            if not autocollectOreEnabled then break end
            if isInventoryFull() then break end

            local orePart = findOrePart(oreName)
            if orePart then
                collectedAny = true
                updateStatus(statusLabel, "Going to " .. oreName, Color3.fromRGB(60, 200, 80))
                safeTeleport(orePart)
                task.wait(0.2)

                local attempts = 0
                while autocollectOreEnabled and attempts < 50 do
                    if isInventoryFull() then break end
                    local currentOre = findOrePart(oreName)
                    if not currentOre then break end
                    safeTeleport(currentOre)
                    task.wait(0.05)
                    fireNearbyProximityPrompts(currentOre.Position, 15)
                    attempts += 1
                    task.wait(0.08)
                end
            end
            task.wait(0.05)
        end

        if not collectedAny then
            -- No ores left in world
            if autoSellEnabled then
                -- Sell any remaining ores then go to map
                local remaining = getOresInInventory()
                if #remaining > 0 then
                    updateStatus(statusLabel, "Selling remaining ores...", Color3.fromRGB(255, 200, 50))
                    sellAllOres(statusLabel)
                end
            end
            updateStatus(statusLabel, "No ores! Returning to Map...", Color3.fromRGB(180, 180, 60))
            local mapPart = findMapPart()
            if mapPart then safeTeleport(mapPart) end
            task.wait(2)
        end
    end
end

-- =============================================
-- AUTOCOLLECT SHARD LOOP
-- =============================================

local function autocollectShardLoop(statusLabel)
    while autocollectShardEnabled do
        local shards = findShards()

        if #shards == 0 then
            updateStatus(statusLabel, "No shards! Returning to Map...", Color3.fromRGB(180, 180, 60))
            local mapPart = findMapPart()
            if mapPart then safeTeleport(mapPart) end
            task.wait(2)
            continue
        end

        updateStatus(statusLabel, "Collecting shards (" .. #shards .. " left)...", Color3.fromRGB(100, 180, 255))

        for _, shard in ipairs(shards) do
            if not autocollectShardEnabled then break end
            if not shard or not shard.Parent then continue end

            safeTeleport(shard)
            task.wait(0.15)

            local attempts = 0
            while autocollectShardEnabled and shard and shard.Parent and attempts < 40 do
                safeTeleport(shard)
                task.wait(0.05)
                fireNearbyProximityPrompts(shard.Position, 15)
                attempts += 1
                task.wait(0.08)
            end
            task.wait(0.05)
        end
        task.wait(0.1)
    end
end

-- =============================================
-- AUTO SELL LOOP (standalone)
-- Runs only when autoSell ON but autocollect ore OFF
-- When both are ON, autocollect ore handles selling internally
-- =============================================

local function autoSellLoop(statusLabel)
    while autoSellEnabled do
        -- If autocollect ore is also running, let it drive selling
        if autocollectOreEnabled then
            task.wait(1)
            continue
        end

        local ores = getOresInInventory()

        if #ores == 0 then
            updateStatus(statusLabel, "No ores to sell. Waiting...", Color3.fromRGB(180, 180, 60))
            task.wait(1.5)
            continue
        end

        sellAllOres(statusLabel)

        -- After selling, go to Map
        updateStatus(statusLabel, "Done selling! Returning to Map...", Color3.fromRGB(255, 200, 50))
        local mapPart = findMapPart()
        if mapPart then safeTeleport(mapPart) end
        task.wait(2)
    end
end

-- =============================================
-- GUI
-- =============================================

if player.PlayerGui:FindFirstChild("FatalFloorsScript") then
    player.PlayerGui.FatalFloorsScript:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FatalFloorsScript"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 420)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(180, 40, 40)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(22, 8, 8)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(22, 8, 8)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "⚠ Fatal Floors Script"
titleLabel.Size = UDim2.new(1, -75, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(220, 55, 55)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local creditLabel = Instance.new("TextLabel")
creditLabel.Text = "by Wrath"
creditLabel.Size = UDim2.new(0, 60, 0, 14)
creditLabel.Position = UDim2.new(0, 10, 1, -15)
creditLabel.BackgroundTransparency = 1
creditLabel.TextColor3 = Color3.fromRGB(110, 110, 110)
creditLabel.Font = Enum.Font.Gotham
creditLabel.TextSize = 10
creditLabel.TextXAlignment = Enum.TextXAlignment.Left
creditLabel.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Text = "—"
minimizeBtn.Size = UDim2.new(0, 28, 0, 22)
minimizeBtn.Position = UDim2.new(1, -62, 0.5, -11)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
minimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 14
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = titleBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 5)

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "✕"
closeBtn.Size = UDim2.new(0, 28, 0, 22)
closeBtn.Position = UDim2.new(1, -30, 0.5, -11)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 35, 35)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

-- Content
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -48)
content.Position = UDim2.new(0, 10, 0, 44)
content.BackgroundTransparency = 1
content.Parent = mainFrame

-- ---- AUTOCOLLECTS CATEGORY ----
local catLabel1 = Instance.new("TextLabel")
catLabel1.Text = "🪨  AUTOCOLLECTS"
catLabel1.Size = UDim2.new(1, 0, 0, 20)
catLabel1.Position = UDim2.new(0, 0, 0, 0)
catLabel1.BackgroundTransparency = 1
catLabel1.TextColor3 = Color3.fromRGB(160, 160, 160)
catLabel1.Font = Enum.Font.GothamBold
catLabel1.TextSize = 11
catLabel1.TextXAlignment = Enum.TextXAlignment.Left
catLabel1.Parent = content

local div1 = Instance.new("Frame")
div1.Size = UDim2.new(1, 0, 0, 1)
div1.Position = UDim2.new(0, 0, 0, 24)
div1.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
div1.BorderSizePixel = 0
div1.Parent = content

-- Autocollect Ore Button
local oreBtn = Instance.new("TextButton")
oreBtn.Text = "Autocollect Ore   [ OFF ]"
oreBtn.Size = UDim2.new(1, 0, 0, 40)
oreBtn.Position = UDim2.new(0, 0, 0, 32)
oreBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
oreBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
oreBtn.Font = Enum.Font.Gotham
oreBtn.TextSize = 13
oreBtn.BorderSizePixel = 0
oreBtn.Parent = content
Instance.new("UICorner", oreBtn).CornerRadius = UDim.new(0, 8)
local oreBtnStroke = Instance.new("UIStroke")
oreBtnStroke.Color = Color3.fromRGB(70, 70, 90)
oreBtnStroke.Thickness = 1
oreBtnStroke.Parent = oreBtn

-- Autocollect Shard Button
local shardBtn = Instance.new("TextButton")
shardBtn.Text = "Autocollect Shard  [ OFF ]"
shardBtn.Size = UDim2.new(1, 0, 0, 40)
shardBtn.Position = UDim2.new(0, 0, 0, 78)
shardBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
shardBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
shardBtn.Font = Enum.Font.Gotham
shardBtn.TextSize = 13
shardBtn.BorderSizePixel = 0
shardBtn.Parent = content
Instance.new("UICorner", shardBtn).CornerRadius = UDim.new(0, 8)
local shardBtnStroke = Instance.new("UIStroke")
shardBtnStroke.Color = Color3.fromRGB(70, 70, 90)
shardBtnStroke.Thickness = 1
shardBtnStroke.Parent = shardBtn

-- Status Label (shared)
local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Status: Idle"
statusLabel.Size = UDim2.new(1, 0, 0, 18)
statusLabel.Position = UDim2.new(0, 0, 0, 126)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(110, 110, 110)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = content

local div2 = Instance.new("Frame")
div2.Size = UDim2.new(1, 0, 0, 1)
div2.Position = UDim2.new(0, 0, 0, 152)
div2.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
div2.BorderSizePixel = 0
div2.Parent = content

-- ---- AUTOMATIC CATEGORY ----
local catLabel2 = Instance.new("TextLabel")
catLabel2.Text = "⚙  AUTOMATIC"
catLabel2.Size = UDim2.new(1, 0, 0, 20)
catLabel2.Position = UDim2.new(0, 0, 0, 160)
catLabel2.BackgroundTransparency = 1
catLabel2.TextColor3 = Color3.fromRGB(160, 160, 160)
catLabel2.Font = Enum.Font.GothamBold
catLabel2.TextSize = 11
catLabel2.TextXAlignment = Enum.TextXAlignment.Left
catLabel2.Parent = content

local div3 = Instance.new("Frame")
div3.Size = UDim2.new(1, 0, 0, 1)
div3.Position = UDim2.new(0, 0, 0, 184)
div3.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
div3.BorderSizePixel = 0
div3.Parent = content

-- Auto Sell Button
local sellBtn = Instance.new("TextButton")
sellBtn.Text = "Auto Sell   [ OFF ]"
sellBtn.Size = UDim2.new(1, 0, 0, 40)
sellBtn.Position = UDim2.new(0, 0, 0, 192)
sellBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
sellBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
sellBtn.Font = Enum.Font.Gotham
sellBtn.TextSize = 13
sellBtn.BorderSizePixel = 0
sellBtn.Parent = content
Instance.new("UICorner", sellBtn).CornerRadius = UDim.new(0, 8)
local sellBtnStroke = Instance.new("UIStroke")
sellBtnStroke.Color = Color3.fromRGB(70, 70, 90)
sellBtnStroke.Thickness = 1
sellBtnStroke.Parent = sellBtn

-- Hint label for combined mode
local hintLabel = Instance.new("TextLabel")
hintLabel.Text = "💡 Enable with Autocollect Ore for full auto loop"
hintLabel.Size = UDim2.new(1, 0, 0, 28)
hintLabel.Position = UDim2.new(0, 0, 0, 238)
hintLabel.BackgroundTransparency = 1
hintLabel.TextColor3 = Color3.fromRGB(90, 90, 110)
hintLabel.Font = Enum.Font.Gotham
hintLabel.TextSize = 10
hintLabel.TextXAlignment = Enum.TextXAlignment.Left
hintLabel.TextWrapped = true
hintLabel.Parent = content

local div4 = Instance.new("Frame")
div4.Size = UDim2.new(1, 0, 0, 1)
div4.Position = UDim2.new(0, 0, 0, 270)
div4.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
div4.BorderSizePixel = 0
div4.Parent = content

local oreListLabel = Instance.new("TextLabel")
oreListLabel.Text = "Ore Targets: Iron · Jade · Amber · Amethyst · Gold"
oreListLabel.Size = UDim2.new(1, 0, 0, 18)
oreListLabel.Position = UDim2.new(0, 0, 0, 278)
oreListLabel.BackgroundTransparency = 1
oreListLabel.TextColor3 = Color3.fromRGB(90, 90, 110)
oreListLabel.Font = Enum.Font.Gotham
oreListLabel.TextSize = 10
oreListLabel.TextXAlignment = Enum.TextXAlignment.Left
oreListLabel.TextWrapped = true
oreListLabel.Parent = content

-- Watermark
local watermark = Instance.new("TextLabel")
watermark.Text = "Fatal Floors Script v1.3  •  by Wrath"
watermark.Size = UDim2.new(1, 0, 0, 16)
watermark.Position = UDim2.new(0, 0, 1, -16)
watermark.BackgroundTransparency = 1
watermark.TextColor3 = Color3.fromRGB(65, 65, 80)
watermark.Font = Enum.Font.Gotham
watermark.TextSize = 10
watermark.TextXAlignment = Enum.TextXAlignment.Center
watermark.Parent = content

-- Minimized Circle
local circleBtn = Instance.new("TextButton")
circleBtn.Text = "⚠"
circleBtn.Size = UDim2.new(0, 54, 0, 54)
circleBtn.Position = UDim2.new(0, 20, 0.5, -27)
circleBtn.BackgroundColor3 = Color3.fromRGB(180, 35, 35)
circleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
circleBtn.Font = Enum.Font.GothamBold
circleBtn.TextSize = 22
circleBtn.BorderSizePixel = 0
circleBtn.Visible = false
circleBtn.Active = true
circleBtn.Parent = screenGui
Instance.new("UICorner", circleBtn).CornerRadius = UDim.new(1, 0)
local circleStroke = Instance.new("UIStroke")
circleStroke.Color = Color3.fromRGB(255, 90, 90)
circleStroke.Thickness = 2
circleStroke.Parent = circleBtn

-- =============================================
-- DRAGGABLE
-- =============================================

local function makeDraggable(frame, handle)
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(mainFrame, titleBar)
makeDraggable(circleBtn, circleBtn)

-- =============================================
-- BUTTON EVENTS
-- =============================================

minimizeBtn.MouseButton1Click:Connect(function()
    local absPos = mainFrame.AbsolutePosition
    circleBtn.Position = UDim2.new(0, absPos.X + 10, 0, absPos.Y + 10)
    mainFrame.Visible = false
    circleBtn.Visible = true
end)

circleBtn.MouseButton1Click:Connect(function()
    local absPos = circleBtn.AbsolutePosition
    mainFrame.Position = UDim2.new(0, absPos.X - 10, 0, absPos.Y - 10)
    circleBtn.Visible = false
    mainFrame.Visible = true
end)

closeBtn.MouseButton1Click:Connect(function()
    autocollectOreEnabled = false
    autocollectShardEnabled = false
    autoSellEnabled = false
    if autocollectOreThread then task.cancel(autocollectOreThread) end
    if autocollectShardThread then task.cancel(autocollectShardThread) end
    if autoSellThread then task.cancel(autoSellThread) end
    screenGui:Destroy()
end)

oreBtn.MouseButton1Click:Connect(function()
    autocollectOreEnabled = not autocollectOreEnabled
    if autocollectOreEnabled then
        oreBtn.Text = "Autocollect Ore   [ ON ]"
        oreBtn.BackgroundColor3 = Color3.fromRGB(15, 70, 22)
        oreBtnStroke.Color = Color3.fromRGB(50, 190, 70)
        updateStatus(statusLabel, "Collecting ores...", Color3.fromRGB(60, 200, 80))
        autocollectOreThread = task.spawn(function()
            autocollectOreLoop(statusLabel)
        end)
    else
        oreBtn.Text = "Autocollect Ore   [ OFF ]"
        oreBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        oreBtnStroke.Color = Color3.fromRGB(70, 70, 90)
        updateStatus(statusLabel, "Idle", Color3.fromRGB(110, 110, 110))
        if autocollectOreThread then task.cancel(autocollectOreThread) autocollectOreThread = nil end
    end
end)

shardBtn.MouseButton1Click:Connect(function()
    autocollectShardEnabled = not autocollectShardEnabled
    if autocollectShardEnabled then
        shardBtn.Text = "Autocollect Shard  [ ON ]"
        shardBtn.BackgroundColor3 = Color3.fromRGB(15, 40, 80)
        shardBtnStroke.Color = Color3.fromRGB(80, 160, 255)
        updateStatus(statusLabel, "Collecting shards...", Color3.fromRGB(100, 180, 255))
        autocollectShardThread = task.spawn(function()
            autocollectShardLoop(statusLabel)
        end)
    else
        shardBtn.Text = "Autocollect Shard  [ OFF ]"
        shardBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        shardBtnStroke.Color = Color3.fromRGB(70, 70, 90)
        updateStatus(statusLabel, "Idle", Color3.fromRGB(110, 110, 110))
        if autocollectShardThread then task.cancel(autocollectShardThread) autocollectShardThread = nil end
    end
end)

sellBtn.MouseButton1Click:Connect(function()
    autoSellEnabled = not autoSellEnabled
    if autoSellEnabled then
        sellBtn.Text = "Auto Sell   [ ON ]"
        sellBtn.BackgroundColor3 = Color3.fromRGB(70, 45, 10)
        sellBtnStroke.Color = Color3.fromRGB(255, 180, 40)
        updateStatus(statusLabel, "Auto Sell active...", Color3.fromRGB(255, 200, 50))
        autoSellThread = task.spawn(function()
            autoSellLoop(statusLabel)
        end)
    else
        sellBtn.Text = "Auto Sell   [ OFF ]"
        sellBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        sellBtnStroke.Color = Color3.fromRGB(70, 70, 90)
        updateStatus(statusLabel, "Idle", Color3.fromRGB(110, 110, 110))
        if autoSellThread then task.cancel(autoSellThread) autoSellThread = nil end
    end
end)

player.CharacterAdded:Connect(function(char)
    character = char
end)

-- =============================================
print("[Fatal Floors Script v1.3] Loaded! Made by Wrath.")
-- =============================================
