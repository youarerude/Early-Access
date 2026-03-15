-- =============================================
--         Fatal Floors Script
--         Made by Wrath
--         Version 1
-- =============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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

local autoGrabEnabled = false
local autoGrabThread = nil
local selectedGrabItems = {}

local espEnabled = false
local espThread = nil

local autoCookEnabled = false
local autoCookThread = nil

local autocollectEggEnabled = false
local autocollectEggThread = nil
local floatPart = nil -- invisible float platform under feet

local maxBagSize = 2 -- adjustable via text input

local grabItemsList = {
    "Campfire", "Carrot", "Cooked Carrot", "Cooked Ham",
    "Ham", "Flashlight", "Hammer", "Planter",
    "Reviver", "Storage", "Teleporter"
}

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
    return toolCount >= maxBagSize
end

local function getOresInInventory()
    local ores = {}
    local oreSet = {}
    for _, name in ipairs(oreNames) do oreSet[name] = true end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and oreSet[item.Name] then
                table.insert(ores, item)
            end
        end
    end
    local char = player.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and oreSet[item.Name] then
                table.insert(ores, item)
            end
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

local function equipTool(tool)
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if humanoid and tool and tool.Parent then
        pcall(function()
            humanoid:EquipTool(tool)
        end)
    end
end

local function sellAllOres(statusLabel)
    local spot = findSellingSpot()
    if not spot then
        warn("[FFS] SellingSpot not found, cannot sell!")
        return
    end

    local ores = getOresInInventory()
    if #ores == 0 then return end

    safeTeleport(spot)
    task.wait(0.3)

    for _, ore in ipairs(ores) do
        if not ore or not ore.Parent then continue end

        updateStatus(statusLabel, "Selling " .. ore.Name .. "...", Color3.fromRGB(255, 200, 50))

        -- Equip (hold) the ore first
        equipTool(ore)
        task.wait(0.2)

        safeTeleport(spot)
        task.wait(0.1)

        -- Spam prox prompts while holding the ore until it disappears
        local attempts = 0
        while ore and ore.Parent and attempts < 60 do
            equipTool(ore)
            safeTeleport(spot)
            task.wait(0.05)
            fireNearbyProximityPrompts(spot.Position, 15)
            attempts += 1
            task.wait(0.08)
        end

        task.wait(0.15)
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
            sendChat("Theres no Shards.")
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
-- AUTO GRAB ITEM FINDER
-- Searches ALL of ProcGenGenerated regardless of parent
-- =============================================

local function findItemInProcGen(itemName)
    local generated = workspace:FindFirstChild("ProcGenGenerated")
        or workspace:FindFirstChild("ProcGenGenerated", true)
    if not generated then return nil end

    for _, obj in ipairs(generated:GetDescendants()) do
        if obj.Name == itemName then
            if obj:IsA("BasePart") then return obj end
            if obj:IsA("Model") then
                if obj.PrimaryPart then return obj.PrimaryPart end
                local part = obj:FindFirstChildWhichIsA("BasePart", true)
                if part then return part end
            end
            if obj:IsA("UnionOperation") then return obj end
        end
    end
    return nil
end

-- =============================================
-- AUTO GRAB LOOP
-- =============================================

local function autoGrabLoop(statusLabel)
    while autoGrabEnabled do
        if next(selectedGrabItems) == nil then
            updateStatus(statusLabel, "No items selected!", Color3.fromRGB(200, 80, 80))
            task.wait(1)
            continue
        end

        local foundAny = false

        for itemName, _ in pairs(selectedGrabItems) do
            if not autoGrabEnabled then break end

            local itemPart = findItemInProcGen(itemName)

            if not itemPart then
                sendChat(itemName .. " not found.")
                task.wait(0.5)
                continue
            end

            foundAny = true
            updateStatus(statusLabel, "Grabbing " .. itemName .. "...", Color3.fromRGB(160, 100, 220))
            safeTeleport(itemPart)
            task.wait(0.2)

            local attempts = 0
            while autoGrabEnabled and attempts < 50 do
                local current = findItemInProcGen(itemName)
                if not current then break end
                safeTeleport(current)
                task.wait(0.05)
                fireNearbyProximityPrompts(current.Position, 15)
                attempts += 1
                task.wait(0.08)
            end

            task.wait(0.05)
        end

        if foundAny then
            updateStatus(statusLabel, "Done! Returning to Map...", Color3.fromRGB(160, 100, 220))
            local mapPart = findMapPart()
            if mapPart then safeTeleport(mapPart) end
            task.wait(2)
        else
            task.wait(1)
        end
    end
end

-- =============================================
-- ESP ENTITY
-- =============================================

local monsterConfig = {
    FleshMonster  = { label = "Blob",         color = Color3.fromRGB(220, 30,  30)  },
    RobotMonster  = { label = "Weatherman",   color = Color3.fromRGB(160, 160, 160) },
    PlantMonster  = { label = "Thorns",       color = Color3.fromRGB(30,  90,  30)  },
    CaveCrawler   = { label = "Cave-Crawler", color = Color3.fromRGB(120, 20,  20)  },
    BirdMonster   = { label = "Giant Kiwi",   color = Color3.fromRGB(220, 120, 30)  },
}

local espObjects = {} -- stores { highlight, billboard } per model

local function clearESP()
    for _, objs in pairs(espObjects) do
        if objs.highlight and objs.highlight.Parent then
            objs.highlight:Destroy()
        end
        if objs.billboard and objs.billboard.Parent then
            objs.billboard:Destroy()
        end
    end
    espObjects = {}
end

local function applyESP(model, cfg)
    if espObjects[model] then return end -- already applied

    -- Highlight
    local hl = Instance.new("SelectionBox")
    hl.Color3 = cfg.color
    hl.LineThickness = 0.06
    hl.SurfaceTransparency = 0.6
    hl.SurfaceColor3 = cfg.color
    hl.Adornee = model
    hl.Parent = workspace

    -- Billboard (name + distance)
    local root = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    local bb, lbl
    if root then
        bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 120, 0, 36)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = root
        bb.Parent = workspace

        lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = cfg.color
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.Text = cfg.label
        lbl.TextStrokeTransparency = 0.4
        lbl.Parent = bb
    end

    espObjects[model] = { highlight = hl, billboard = bb, label = lbl, root = root, cfg = cfg }
end

local function espLoop()
    while espEnabled do
        local monstersFolder = workspace:FindFirstChild("Monsters")
            or workspace:FindFirstChild("Monsters", true)

        local foundModels = {}

        if monstersFolder then
            for modelName, cfg in pairs(monsterConfig) do
                for _, obj in ipairs(monstersFolder:GetChildren()) do
                    if obj.Name == modelName and obj:IsA("Model") then
                        foundModels[obj] = cfg
                        applyESP(obj, cfg)
                    end
                end
            end
        end

        -- Remove ESP from monsters that no longer exist
        for model, objs in pairs(espObjects) do
            if not model.Parent then
                if objs.highlight then pcall(function() objs.highlight:Destroy() end) end
                if objs.billboard then pcall(function() objs.billboard:Destroy() end) end
                espObjects[model] = nil
            end
        end

        -- Update distance labels
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for model, objs in pairs(espObjects) do
                if objs.root and objs.root.Parent and objs.label then
                    local dist = math.floor((objs.root.Position - hrp.Position).Magnitude)
                    objs.label.Text = objs.cfg.label .. "\n" .. dist .. " studs"
                end
            end
        end

        task.wait(0.2)
    end
    clearESP()
end

-- =============================================
-- AUTO COOK
-- =============================================

local rawFoods = {"Carrot", "Ham", "Giant Egg"}
local cookedMap = {
    ["Carrot"]    = "Cooked Carrot",
    ["Ham"]       = "Cooked Ham",
    ["Giant Egg"] = "Cooked Giant Egg",
}
local ignoredItems = {
    ["Reviver"] = true,
    ["Flashlight"] = true, ["Hammer"] = true, ["Planter"] = true,
    ["Storage"] = true, ["Teleporter"] = true, ["Campfire"] = true,
}
for _, n in ipairs(oreNames) do ignoredItems[n] = true end

local function findCampfire()
    -- Search entire workspace regardless of parent
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Campfire" and obj:IsA("Model") then
            if obj.PrimaryPart then return obj.PrimaryPart end
            local part = obj:FindFirstChildWhichIsA("BasePart", true)
            if part then return part end
        end
    end
    return nil
end

local function getAllToolsInInventory()
    local tools = {}
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then table.insert(tools, item) end
        end
    end
    local char = player.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then table.insert(tools, item) end
        end
    end
    return tools
end

local function getRawFoodsInInventory()
    local foods = {}
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and cookedMap[item.Name] then
                table.insert(foods, item)
            end
        end
    end
    local char = player.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and cookedMap[item.Name] then
                table.insert(foods, item)
            end
        end
    end
    return foods
end

local function allFoodCooked()
    -- Returns true if no raw food items remain (ignoring ignored items)
    local tools = getAllToolsInInventory()
    for _, tool in ipairs(tools) do
        if cookedMap[tool.Name] then
            return false -- still has raw food
        end
    end
    return true
end

local function unequipAll()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        pcall(function() humanoid:UnequipTools() end)
    end
end

local function autoCookLoop(statusLabel)
    while autoCookEnabled do
        local campfire = findCampfire()
        if not campfire then
            sendChat("Place the Campfire first.")
            task.wait(3)
            continue
        end

        local rawFoodList = getRawFoodsInInventory()

        if #rawFoodList == 0 then
            local mapPart = findMapPart()
            if mapPart then safeTeleport(mapPart) end
            task.wait(2)
            while autoCookEnabled and #getRawFoodsInInventory() == 0 do
                task.wait(1)
            end
            continue
        end

        -- Cook each raw food one by one sequentially
        for _, food in ipairs(rawFoodList) do
            if not autoCookEnabled then break end
            if not food or not food.Parent then continue end
            -- Skip if already cooked name
            if not cookedMap[food.Name] then continue end

            local expectedCooked = cookedMap[food.Name]

            -- Unequip whatever is currently held first
            unequipAll()
            task.wait(0.2)

            -- Equip the raw food
            equipTool(food)
            task.wait(0.25)

            safeTeleport(campfire)
            task.wait(0.2)

            -- Spam until food name changes to cooked or disappears
            local attempts = 0
            while autoCookEnabled and attempts < 80 do
                -- Check if cooked version now exists in inventory
                local allTools = getAllToolsInInventory()
                local foundCooked = false
                local stillRaw = false
                for _, t in ipairs(allTools) do
                    if t.Name == expectedCooked then foundCooked = true end
                    if t == food and t.Parent then stillRaw = true end
                end
                if foundCooked or not stillRaw then break end

                -- Re-equip raw food and spam
                if food and food.Parent then
                    equipTool(food)
                    task.wait(0.1)
                end
                safeTeleport(campfire)
                task.wait(0.05)
                fireNearbyProximityPrompts(campfire.Position, 15)
                attempts += 1
                task.wait(0.08)
            end

            -- Unequip cooked food before moving to next
            unequipAll()
            task.wait(0.2)
        end

        task.wait(0.1)
    end
end

-- =============================================
-- AUTOCOLLECT GIANT EGG
-- =============================================

local function findGiantEggs()
    -- Structure: ProcGenGenerated > Nest (Model) > EggSpot1/2/3 (Part) > Giant Egg (Tool)
    -- Returns list of {spot = Part, tool = Tool} for each occupied egg spot
    local generated = workspace:FindFirstChild("ProcGenGenerated")
        or workspace:FindFirstChild("ProcGenGenerated", true)
    if not generated then return {} end

    local nest = generated:FindFirstChild("Nest")
    if not nest then return {} end

    local eggs = {}
    for _, spot in ipairs(nest:GetChildren()) do
        if spot:IsA("BasePart") and string.find(spot.Name, "EggSpot") then
            local tool = spot:FindFirstChild("Giant Egg")
            if tool then
                table.insert(eggs, { spot = spot, tool = tool })
            end
        end
    end
    return eggs
end

local function createFloatPart()
    -- Invisible part that keeps player floating in air
    local part = Instance.new("Part")
    part.Name = "EggFloatPad"
    part.Size = Vector3.new(4, 1, 4)
    part.Anchored = true
    part.CanCollide = true
    part.Transparency = 1
    part.CanTouch = false
    part.CastShadow = false
    part.Parent = workspace
    return part
end

local function updateFloatPart(position)
    if floatPart and floatPart.Parent then
        floatPart.CFrame = CFrame.new(position - Vector3.new(0, 3, 0))
    end
end

local function removeFloatPart()
    if floatPart and floatPart.Parent then
        floatPart:Destroy()
    end
    floatPart = nil
end

local function teleportBelowEgg(egg)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and egg and egg.Parent then
        local targetPos = egg.Position - Vector3.new(0, 5, 0)
        hrp.CFrame = CFrame.new(targetPos)
        -- Place float pad right under feet
        if floatPart and floatPart.Parent then
            floatPart.CFrame = CFrame.new(targetPos - Vector3.new(0, 3, 0))
        end
    end
end

local function autocollectEggLoop(statusLabel)
    floatPart = createFloatPart()

    while autocollectEggEnabled do
        local eggs = findGiantEggs()

        if #eggs == 0 then
            sendChat("There's no giant kiwi.")
            removeFloatPart()
            local mapPart = findMapPart()
            if mapPart then safeTeleport(mapPart) end
            task.wait(2)
            while autocollectEggEnabled and #findGiantEggs() == 0 do
                task.wait(1)
            end
            floatPart = createFloatPart()
            continue
        end

        for _, entry in ipairs(eggs) do
            if not autocollectEggEnabled then break end

            local spot = entry.spot
            local tool = entry.tool

            if not spot or not spot.Parent then continue end

            -- Check inventory before grabbing
            if isInventoryFull() then
                sendChat("Max Inventory, Put the eggs first.")
                removeFloatPart()
                local mapPart = findMapPart()
                if mapPart then safeTeleport(mapPart) end
                while autocollectEggEnabled and isInventoryFull() do
                    task.wait(0.8)
                end
                floatPart = createFloatPart()
                task.wait(0.5)
            end

            if not autocollectEggEnabled then break end
            if not spot or not spot.Parent then continue end

            -- Teleport 5 studs below the EggSpot part and float
            teleportBelowEgg(spot)
            task.wait(0.2)

            -- Spam prox prompt until Giant Egg tool is gone from the spot
            local attempts = 0
            while autocollectEggEnabled and spot:FindFirstChild("Giant Egg") and attempts < 60 do
                teleportBelowEgg(spot)
                task.wait(0.05)
                fireNearbyProximityPrompts(spot.Position, 15)
                attempts += 1
                task.wait(0.08)
            end

            task.wait(0.1)
        end

        -- All eggs collected — go to elevator
        if autocollectEggEnabled then
            removeFloatPart()
            local mapPart = findMapPart()
            if mapPart then safeTeleport(mapPart) end
            task.wait(2)
            while autocollectEggEnabled and #findGiantEggs() == 0 do
                task.wait(1)
            end
            if autocollectEggEnabled then
                floatPart = createFloatPart()
            end
        end
    end

    removeFloatPart()
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

-- =============================================
-- LOADING SCREEN
-- =============================================

local loadFrame = Instance.new("Frame")
loadFrame.Name = "LoadScreen"
loadFrame.Size = UDim2.new(1, 0, 1, 0)
loadFrame.Position = UDim2.new(0, 0, 0, 0)
loadFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
loadFrame.BorderSizePixel = 0
loadFrame.ZIndex = 100
loadFrame.Parent = screenGui

-- Vignette gradient
local vignette = Instance.new("UIGradient")
vignette.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 8, 8)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
})
vignette.Rotation = 45
vignette.Parent = loadFrame

-- Logo container
local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(0, 320, 0, 180)
logoFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
logoFrame.BackgroundTransparency = 1
logoFrame.ZIndex = 101
logoFrame.Parent = loadFrame

-- Warning icon
local warnIcon = Instance.new("TextLabel")
warnIcon.Text = "⚠"
warnIcon.Size = UDim2.new(0, 60, 0, 60)
warnIcon.Position = UDim2.new(0.5, -30, 0, 0)
warnIcon.BackgroundTransparency = 1
warnIcon.TextColor3 = Color3.fromRGB(220, 50, 50)
warnIcon.Font = Enum.Font.GothamBold
warnIcon.TextSize = 48
warnIcon.TextTransparency = 1
warnIcon.ZIndex = 101
warnIcon.Parent = logoFrame

-- Title
local loadTitle = Instance.new("TextLabel")
loadTitle.Text = "Fatal Floors Script"
loadTitle.Size = UDim2.new(1, 0, 0, 40)
loadTitle.Position = UDim2.new(0, 0, 0, 68)
loadTitle.BackgroundTransparency = 1
loadTitle.TextColor3 = Color3.fromRGB(220, 50, 50)
loadTitle.Font = Enum.Font.GothamBold
loadTitle.TextSize = 28
loadTitle.TextTransparency = 1
loadTitle.ZIndex = 101
loadTitle.Parent = logoFrame

-- Subtitle
local loadSub = Instance.new("TextLabel")
loadSub.Text = "by Devious Goober"
loadSub.Size = UDim2.new(1, 0, 0, 20)
loadSub.Position = UDim2.new(0, 0, 0, 112)
loadSub.BackgroundTransparency = 1
loadSub.TextColor3 = Color3.fromRGB(120, 120, 140)
loadSub.Font = Enum.Font.Gotham
loadSub.TextSize = 13
loadSub.TextTransparency = 1
loadSub.ZIndex = 101
loadSub.Parent = logoFrame

-- Divider line
local loadLine = Instance.new("Frame")
loadLine.Size = UDim2.new(0, 0, 0, 1)
loadLine.Position = UDim2.new(0.5, 0, 0, 140)
loadLine.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
loadLine.BorderSizePixel = 0
loadLine.ZIndex = 101
loadLine.Parent = logoFrame

-- Status text
local loadStatus = Instance.new("TextLabel")
loadStatus.Text = "Initializing..."
loadStatus.Size = UDim2.new(1, 0, 0, 20)
loadStatus.Position = UDim2.new(0, 0, 0, 152)
loadStatus.BackgroundTransparency = 1
loadStatus.TextColor3 = Color3.fromRGB(160, 160, 180)
loadStatus.Font = Enum.Font.Gotham
loadStatus.TextSize = 12
loadStatus.TextTransparency = 1
loadStatus.ZIndex = 101
loadStatus.Parent = logoFrame

-- Progress bar background
local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(0, 300, 0, 4)
progressBg.Position = UDim2.new(0.5, -150, 0.5, 60)
progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
progressBg.BorderSizePixel = 0
progressBg.ZIndex = 101
progressBg.Parent = loadFrame
Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)

-- Progress bar fill
local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.Position = UDim2.new(0, 0, 0, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
progressFill.BorderSizePixel = 0
progressFill.ZIndex = 102
progressFill.Parent = progressBg
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

-- Progress percentage
local progressPct = Instance.new("TextLabel")
progressPct.Text = "0%"
progressPct.Size = UDim2.new(0, 300, 0, 20)
progressPct.Position = UDim2.new(0.5, -150, 0.5, 70)
progressPct.BackgroundTransparency = 1
progressPct.TextColor3 = Color3.fromRGB(100, 100, 120)
progressPct.Font = Enum.Font.Gotham
progressPct.TextSize = 11
progressPct.TextTransparency = 1
progressPct.ZIndex = 101
progressPct.Parent = loadFrame

-- Spinning dots indicator
local dotsLabel = Instance.new("TextLabel")
dotsLabel.Text = "●  ○  ○"
dotsLabel.Size = UDim2.new(0, 80, 0, 20)
dotsLabel.Position = UDim2.new(0.5, -40, 0.5, 90)
dotsLabel.BackgroundTransparency = 1
dotsLabel.TextColor3 = Color3.fromRGB(220, 50, 50)
dotsLabel.Font = Enum.Font.GothamBold
dotsLabel.TextSize = 14
dotsLabel.TextTransparency = 1
dotsLabel.ZIndex = 101
dotsLabel.Parent = loadFrame

local dotPatterns = {"●  ○  ○", "○  ●  ○", "○  ○  ●"}
local dotIndex = 1
local dotThread

-- Status text shown at these % thresholds
local statusSteps = {
    {pct = 0,   text = "Creating GUI..."},
    {pct = 15,  text = "Loading Text..."},
    {pct = 29,  text = "Creating Buttons..."},
    {pct = 43,  text = "Loading Functions..."},
    {pct = 58,  text = "Loading extra stuff..."},
    {pct = 72,  text = "Loading ANOTHER extra stuff..."},
    {pct = 90,  text = "Loaded!"},
}

local tweenFast = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenSlow = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenMed  = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Preload sound
local loadedSound = Instance.new("Sound")
loadedSound.SoundId = "rbxassetid://125936118513893"
loadedSound.Volume = 0.8
loadedSound.Parent = screenGui

task.spawn(function()
    -- Fade in icon + title
    TweenService:Create(warnIcon, tweenSlow, {TextTransparency = 0}):Play()
    task.wait(0.15)
    TweenService:Create(loadTitle, tweenSlow, {TextTransparency = 0}):Play()
    task.wait(0.15)
    TweenService:Create(loadSub, tweenSlow, {TextTransparency = 0}):Play()
    task.wait(0.2)

    -- Expand divider line
    TweenService:Create(loadLine, tweenMed, {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 140)
    }):Play()
    task.wait(0.3)

    -- Fade in status + progress
    TweenService:Create(loadStatus, tweenFast, {TextTransparency = 0}):Play()
    TweenService:Create(progressPct, tweenFast, {TextTransparency = 0}):Play()
    TweenService:Create(dotsLabel, tweenFast, {TextTransparency = 0}):Play()
    task.wait(0.2)

    -- Spinning dots animation
    dotThread = task.spawn(function()
        while loadFrame and loadFrame.Parent do
            dotIndex = (dotIndex % 3) + 1
            dotsLabel.Text = dotPatterns[dotIndex]
            task.wait(0.35)
        end
    end)

    -- 1% per 0.022s = 2.2s total for bar
    local currentStatus = 0
    for pct = 0, 100 do
        if not loadFrame or not loadFrame.Parent then break end

        -- Update status text at thresholds
        for i = #statusSteps, 1, -1 do
            if pct >= statusSteps[i].pct and currentStatus < i then
                currentStatus = i
                loadStatus.Text = statusSteps[i].text
                break
            end
        end

        -- Update bar and percentage
        progressFill.Size = UDim2.new(pct / 100, 0, 1, 0)
        progressPct.Text = pct .. "%"

        task.wait(0.022)
    end

    -- Play loaded sound
    loadedSound:Play()

    -- Stop dots
    if dotThread then task.cancel(dotThread) dotThread = nil end
    dotsLabel.Text = "●  ●  ●"

    task.wait(0.5)

    -- Slide out downward
    TweenService:Create(loadFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Position = UDim2.new(0, 0, 1, 0)
    }):Play()

    task.wait(0.55)
    loadFrame:Destroy()
    loadedSound:Destroy()
end)

-- Main Frame (hidden until loading done — starts invisible then fades in)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 340)
mainFrame.Position = UDim2.new(0, 10, 0, 60)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.BackgroundTransparency = 1
mainFrame.Visible = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Fade in after loading screen exits (~4.3s total)
task.delay(4.3, function()
    mainFrame.Visible = true
    TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
    }):Play()
end)

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
creditLabel.Text = "by Devious Goober"
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
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 28, 0, 22)
closeBtn.Position = UDim2.new(1, -30, 0.5, -11)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 35, 35)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

-- Scrollable Content
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -8, 1, -48)
content.Position = UDim2.new(0, 4, 0, 44)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = Color3.fromRGB(180, 40, 40)
content.CanvasSize = UDim2.new(0, 0, 0, 590)
content.ScrollingDirection = Enum.ScrollingDirection.Y
content.ElasticBehavior = Enum.ElasticBehavior.Never
content.Parent = mainFrame

-- ---- AUTOCOLLECTS ----
local catLabel1 = Instance.new("TextLabel")
catLabel1.Text = "⛏  AUTOCOLLECTS"
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

local eggBtn = Instance.new("TextButton")
eggBtn.Text = "Autocollect Giant Egg  [ OFF ]"
eggBtn.Size = UDim2.new(1, 0, 0, 40)
eggBtn.Position = UDim2.new(0, 0, 0, 124)
eggBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
eggBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
eggBtn.Font = Enum.Font.Gotham
eggBtn.TextSize = 13
eggBtn.BorderSizePixel = 0
eggBtn.Parent = content
Instance.new("UICorner", eggBtn).CornerRadius = UDim.new(0, 8)
local eggBtnStroke = Instance.new("UIStroke")
eggBtnStroke.Color = Color3.fromRGB(70, 70, 90)
eggBtnStroke.Thickness = 1
eggBtnStroke.Parent = eggBtn

local div2 = Instance.new("Frame")
div2.Size = UDim2.new(1, 0, 0, 1)
div2.Position = UDim2.new(0, 0, 0, 170)
div2.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
div2.BorderSizePixel = 0
div2.Parent = content

-- ---- AUTOMATIC ----
local catLabel2 = Instance.new("TextLabel")
catLabel2.Text = "⚙  AUTOMATIC"
catLabel2.Size = UDim2.new(1, 0, 0, 20)
catLabel2.Position = UDim2.new(0, 0, 0, 178)
catLabel2.BackgroundTransparency = 1
catLabel2.TextColor3 = Color3.fromRGB(160, 160, 160)
catLabel2.Font = Enum.Font.GothamBold
catLabel2.TextSize = 11
catLabel2.TextXAlignment = Enum.TextXAlignment.Left
catLabel2.Parent = content

local div3 = Instance.new("Frame")
div3.Size = UDim2.new(1, 0, 0, 1)
div3.Position = UDim2.new(0, 0, 0, 202)
div3.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
div3.BorderSizePixel = 0
div3.Parent = content

local sellBtn = Instance.new("TextButton")
sellBtn.Text = "Auto Sell   [ OFF ]"
sellBtn.Size = UDim2.new(1, 0, 0, 40)
sellBtn.Position = UDim2.new(0, 0, 0, 210)
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

local grabBtn = Instance.new("TextButton")
grabBtn.Text = "Auto-Grab Items   [ OFF ]"
grabBtn.Size = UDim2.new(1, 0, 0, 40)
grabBtn.Position = UDim2.new(0, 0, 0, 256)
grabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
grabBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
grabBtn.Font = Enum.Font.Gotham
grabBtn.TextSize = 13
grabBtn.BorderSizePixel = 0
grabBtn.Parent = content
Instance.new("UICorner", grabBtn).CornerRadius = UDim.new(0, 8)
local grabBtnStroke = Instance.new("UIStroke")
grabBtnStroke.Color = Color3.fromRGB(70, 70, 90)
grabBtnStroke.Thickness = 1
grabBtnStroke.Parent = grabBtn

local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Text = "Select Items to Grab  ▼"
dropdownBtn.Size = UDim2.new(1, 0, 0, 34)
dropdownBtn.Position = UDim2.new(0, 0, 0, 302)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
dropdownBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
dropdownBtn.Font = Enum.Font.Gotham
dropdownBtn.TextSize = 12
dropdownBtn.BorderSizePixel = 0
dropdownBtn.Parent = content
Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 8)
local dropdownBtnStroke = Instance.new("UIStroke")
dropdownBtnStroke.Color = Color3.fromRGB(60, 60, 80)
dropdownBtnStroke.Thickness = 1
dropdownBtnStroke.Parent = dropdownBtn

-- Dropdown List — high ZIndex so it renders on top of buttons below
local dropdownList = Instance.new("Frame")
dropdownList.Name = "DropdownList"
dropdownList.Size = UDim2.new(1, 0, 0, 0)
dropdownList.Position = UDim2.new(0, 0, 0, 340)
dropdownList.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
dropdownList.BorderSizePixel = 0
dropdownList.ClipsDescendants = true
dropdownList.ZIndex = 8
dropdownList.Parent = content
Instance.new("UICorner", dropdownList).CornerRadius = UDim.new(0, 8)
local dropdownStroke = Instance.new("UIStroke")
dropdownStroke.Color = Color3.fromRGB(60, 60, 80)
dropdownStroke.Thickness = 1
dropdownStroke.Parent = dropdownList

local ITEM_H = 30
local dropdownOpen = false
local DROPDOWN_FULL_H = #grabItemsList * ITEM_H

local itemButtons = {}
for i, itemName in ipairs(grabItemsList) do
    local itemBtn = Instance.new("TextButton")
    itemBtn.Text = "  " .. itemName
    itemBtn.Size = UDim2.new(1, 0, 0, ITEM_H)
    itemBtn.Position = UDim2.new(0, 0, 0, (i - 1) * ITEM_H)
    itemBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    itemBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
    itemBtn.Font = Enum.Font.Gotham
    itemBtn.TextSize = 12
    itemBtn.TextXAlignment = Enum.TextXAlignment.Left
    itemBtn.BorderSizePixel = 0
    itemBtn.ZIndex = 8
    itemBtn.Parent = dropdownList
    local itemStroke = Instance.new("UIStroke")
    itemStroke.Color = Color3.fromRGB(35, 35, 50)
    itemStroke.Thickness = 0.5
    itemStroke.Parent = itemBtn
    if i < #grabItemsList then
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, -10, 0, 1)
        line.Position = UDim2.new(0, 5, 1, -1)
        line.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        line.BorderSizePixel = 0
        line.ZIndex = 8
        line.Parent = itemBtn
    end
    itemButtons[itemName] = itemBtn
    itemBtn.MouseButton1Click:Connect(function()
        if selectedGrabItems[itemName] then
            selectedGrabItems[itemName] = nil
            itemBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
            itemBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
        else
            selectedGrabItems[itemName] = true
            itemBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 60)
            itemBtn.TextColor3 = Color3.fromRGB(180, 120, 255)
        end
    end)
end

-- BASE Y positions for all elements that push down when dropdown opens
local BASE_COOK     = 346
local BASE_DIVM     = 392
local BASE_CATM     = 400
local BASE_DIVM2    = 424
local BASE_ESP      = 432
local BASE_BAGLBL   = 478
local BASE_BAGINPUT = 474
local BASE_RETURN   = 514
local BASE_WM       = 562

local cookBtn = Instance.new("TextButton")
cookBtn.Text = "Auto-Cook   [ OFF ]"
cookBtn.Size = UDim2.new(1, 0, 0, 40)
cookBtn.Position = UDim2.new(0, 0, 0, BASE_COOK)
cookBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
cookBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
cookBtn.Font = Enum.Font.Gotham
cookBtn.TextSize = 13
cookBtn.BorderSizePixel = 0
cookBtn.Parent = content
Instance.new("UICorner", cookBtn).CornerRadius = UDim.new(0, 8)
local cookBtnStroke = Instance.new("UIStroke")
cookBtnStroke.Color = Color3.fromRGB(70, 70, 90)
cookBtnStroke.Thickness = 1
cookBtnStroke.Parent = cookBtn

-- ---- MANUAL ----
local divManual = Instance.new("Frame")
divManual.Size = UDim2.new(1, 0, 0, 1)
divManual.Position = UDim2.new(0, 0, 0, BASE_DIVM)
divManual.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
divManual.BorderSizePixel = 0
divManual.Parent = content

local catManual = Instance.new("TextLabel")
catManual.Text = "👁  MANUAL"
catManual.Size = UDim2.new(1, 0, 0, 20)
catManual.Position = UDim2.new(0, 0, 0, BASE_CATM)
catManual.BackgroundTransparency = 1
catManual.TextColor3 = Color3.fromRGB(160, 160, 160)
catManual.Font = Enum.Font.GothamBold
catManual.TextSize = 11
catManual.TextXAlignment = Enum.TextXAlignment.Left
catManual.Parent = content

local divManual2 = Instance.new("Frame")
divManual2.Size = UDim2.new(1, 0, 0, 1)
divManual2.Position = UDim2.new(0, 0, 0, BASE_DIVM2)
divManual2.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
divManual2.BorderSizePixel = 0
divManual2.Parent = content

local espBtn = Instance.new("TextButton")
espBtn.Text = "ESP Entity   [ OFF ]"
espBtn.Size = UDim2.new(1, 0, 0, 40)
espBtn.Position = UDim2.new(0, 0, 0, BASE_ESP)
espBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
espBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
espBtn.Font = Enum.Font.Gotham
espBtn.TextSize = 13
espBtn.BorderSizePixel = 0
espBtn.Parent = content
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 8)
local espBtnStroke = Instance.new("UIStroke")
espBtnStroke.Color = Color3.fromRGB(70, 70, 90)
espBtnStroke.Thickness = 1
espBtnStroke.Parent = espBtn

local maxBagLabel = Instance.new("TextLabel")
maxBagLabel.Text = "Max Bag Detection"
maxBagLabel.Size = UDim2.new(0.6, 0, 0, 20)
maxBagLabel.Position = UDim2.new(0, 0, 0, BASE_BAGLBL)
maxBagLabel.BackgroundTransparency = 1
maxBagLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
maxBagLabel.Font = Enum.Font.Gotham
maxBagLabel.TextSize = 11
maxBagLabel.TextXAlignment = Enum.TextXAlignment.Left
maxBagLabel.Parent = content

local maxBagInput = Instance.new("TextBox")
maxBagInput.Text = "2"
maxBagInput.Size = UDim2.new(0.35, 0, 0, 30)
maxBagInput.Position = UDim2.new(0.65, 0, 0, BASE_BAGINPUT)
maxBagInput.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
maxBagInput.TextColor3 = Color3.fromRGB(220, 220, 220)
maxBagInput.Font = Enum.Font.GothamBold
maxBagInput.TextSize = 13
maxBagInput.TextXAlignment = Enum.TextXAlignment.Center
maxBagInput.ClearTextOnFocus = false
maxBagInput.BorderSizePixel = 0
maxBagInput.Parent = content
Instance.new("UICorner", maxBagInput).CornerRadius = UDim.new(0, 6)
local maxBagInputStroke = Instance.new("UIStroke")
maxBagInputStroke.Color = Color3.fromRGB(80, 80, 100)
maxBagInputStroke.Thickness = 1
maxBagInputStroke.Parent = maxBagInput

local returnBtn = Instance.new("TextButton")
returnBtn.Text = "Return to Elevator"
returnBtn.Size = UDim2.new(1, 0, 0, 40)
returnBtn.Position = UDim2.new(0, 0, 0, BASE_RETURN)
returnBtn.BackgroundColor3 = Color3.fromRGB(35, 20, 20)
returnBtn.TextColor3 = Color3.fromRGB(220, 100, 100)
returnBtn.Font = Enum.Font.GothamBold
returnBtn.TextSize = 13
returnBtn.BorderSizePixel = 0
returnBtn.Parent = content
Instance.new("UICorner", returnBtn).CornerRadius = UDim.new(0, 8)
local returnBtnStroke = Instance.new("UIStroke")
returnBtnStroke.Color = Color3.fromRGB(180, 40, 40)
returnBtnStroke.Thickness = 1
returnBtnStroke.Parent = returnBtn

local watermark = Instance.new("TextLabel")
watermark.Text = "Fatal Floors Script v1  •  by Devious Goober"
watermark.Size = UDim2.new(1, 0, 0, 16)
watermark.Position = UDim2.new(0, 0, 0, BASE_WM)
watermark.BackgroundTransparency = 1
watermark.TextColor3 = Color3.fromRGB(65, 65, 80)
watermark.Font = Enum.Font.Gotham
watermark.TextSize = 10
watermark.TextXAlignment = Enum.TextXAlignment.Center
watermark.Parent = content

-- Table of elements that push down when dropdown opens
local pushElements = {
    { obj = cookBtn,    base = BASE_COOK     },
    { obj = divManual,  base = BASE_DIVM     },
    { obj = catManual,  base = BASE_CATM     },
    { obj = divManual2, base = BASE_DIVM2    },
    { obj = espBtn,     base = BASE_ESP      },
    { obj = maxBagLabel,base = BASE_BAGLBL   },
    { obj = maxBagInput,base = BASE_BAGINPUT },
    { obj = returnBtn,  base = BASE_RETURN   },
    { obj = watermark,  base = BASE_WM       },
}

-- nil statusLabel — removed from GUI, functions handle nil safely
local statusLabel = nil

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
            local vp = workspace.CurrentCamera.ViewportSize
            local newX = framePos.X.Offset + delta.X
            local newY = framePos.Y.Offset + delta.Y
            -- Clamp so frame always stays on screen
            newX = math.clamp(newX, 0, vp.X - frame.AbsoluteSize.X)
            newY = math.clamp(newY, 0, vp.Y - frame.AbsoluteSize.Y)
            frame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
end

-- Make ENTIRE mainFrame draggable, not just title bar
makeDraggable(mainFrame, mainFrame)
makeDraggable(circleBtn, circleBtn)

-- =============================================
-- BUTTON EVENTS
-- =============================================

local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local isAnimating = false

minimizeBtn.MouseButton1Click:Connect(function()
    if isAnimating then return end
    isAnimating = true

    local absPos = mainFrame.AbsolutePosition
    local targetX = absPos.X + mainFrame.AbsoluteSize.X / 2 - 27
    local targetY = absPos.Y + mainFrame.AbsoluteSize.Y / 2 - 27

    -- Shrink mainFrame to a circle
    local shrink = TweenService:Create(mainFrame, tweenInfo, {
        Size = UDim2.new(0, 54, 0, 54),
        Position = UDim2.new(0, targetX, 0, targetY),
        BackgroundTransparency = 1
    })
    mainStroke.Enabled = false
    shrink:Play()
    shrink.Completed:Wait()

    mainFrame.Visible = false
    mainFrame.Size = UDim2.new(0, 300, 0, 340)
    mainFrame.BackgroundTransparency = 0
    mainStroke.Enabled = true

    circleBtn.Position = UDim2.new(0, targetX, 0, targetY)
    circleBtn.Visible = true
    circleBtn.Size = UDim2.new(0, 0, 0, 0)
    circleBtn.BackgroundTransparency = 1

    local grow = TweenService:Create(circleBtn, tweenInfo, {
        Size = UDim2.new(0, 54, 0, 54),
        BackgroundTransparency = 0
    })
    grow:Play()
    grow.Completed:Wait()
    isAnimating = false
end)

circleBtn.MouseButton1Click:Connect(function()
    if isAnimating then return end
    isAnimating = true

    local absPos = circleBtn.AbsolutePosition

    -- Shrink circle away
    local shrink = TweenService:Create(circleBtn, tweenInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    })
    shrink:Play()
    shrink.Completed:Wait()
    circleBtn.Visible = false
    circleBtn.Size = UDim2.new(0, 54, 0, 54)
    circleBtn.BackgroundTransparency = 0

    -- Restore mainFrame from same position, expanding out
    mainFrame.Position = UDim2.new(0, absPos.X - 123, 0, absPos.Y - 143)
    mainFrame.Size = UDim2.new(0, 54, 0, 54)
    mainFrame.BackgroundTransparency = 1
    mainStroke.Enabled = false
    mainFrame.Visible = true

    local expand = TweenService:Create(mainFrame, tweenInfo, {
        Size = UDim2.new(0, 300, 0, 340),
        BackgroundTransparency = 0
    })
    mainStroke.Enabled = true
    expand:Play()
    expand.Completed:Wait()
    isAnimating = false
end)

closeBtn.MouseButton1Click:Connect(function()
    if isAnimating then return end
    isAnimating = true

    autocollectOreEnabled = false
    autocollectShardEnabled = false
    autocollectEggEnabled = false
    autoSellEnabled = false
    autoGrabEnabled = false
    autoCookEnabled = false
    espEnabled = false
    if autocollectOreThread then task.cancel(autocollectOreThread) end
    if autocollectShardThread then task.cancel(autocollectShardThread) end
    if autocollectEggThread then task.cancel(autocollectEggThread) end
    if autoSellThread then task.cancel(autoSellThread) end
    if autoGrabThread then task.cancel(autoGrabThread) end
    if autoCookThread then task.cancel(autoCookThread) end
    if espThread then task.cancel(espThread) end
    removeFloatPart()
    clearESP()

    -- Fade + shrink out
    local close = TweenService:Create(mainFrame, tweenInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    })
    mainStroke.Enabled = false
    close:Play()
    close.Completed:Wait()
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
        autocollectShardThread = task.spawn(function()
            autocollectShardLoop(statusLabel)
        end)
    else
        shardBtn.Text = "Autocollect Shard  [ OFF ]"
        shardBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        shardBtnStroke.Color = Color3.fromRGB(70, 70, 90)
        if autocollectShardThread then task.cancel(autocollectShardThread) autocollectShardThread = nil end
    end
end)

eggBtn.MouseButton1Click:Connect(function()
    autocollectEggEnabled = not autocollectEggEnabled
    if autocollectEggEnabled then
        eggBtn.Text = "Autocollect Giant Egg  [ ON ]"
        eggBtn.BackgroundColor3 = Color3.fromRGB(50, 35, 10)
        eggBtnStroke.Color = Color3.fromRGB(220, 180, 30)
        autocollectEggThread = task.spawn(function()
            autocollectEggLoop(statusLabel)
        end)
    else
        eggBtn.Text = "Autocollect Giant Egg  [ OFF ]"
        eggBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        eggBtnStroke.Color = Color3.fromRGB(70, 70, 90)
        if autocollectEggThread then task.cancel(autocollectEggThread) autocollectEggThread = nil end
        removeFloatPart()
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

-- Auto-Grab toggle
grabBtn.MouseButton1Click:Connect(function()
    autoGrabEnabled = not autoGrabEnabled
    if autoGrabEnabled then
        grabBtn.Text = "Auto-Grab Items   [ ON ]"
        grabBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 70)
        grabBtnStroke.Color = Color3.fromRGB(160, 80, 255)
        updateStatus(statusLabel, "Auto-Grab active...", Color3.fromRGB(160, 100, 220))
        autoGrabThread = task.spawn(function()
            autoGrabLoop(statusLabel)
        end)
    else
        grabBtn.Text = "Auto-Grab Items   [ OFF ]"
        grabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        grabBtnStroke.Color = Color3.fromRGB(70, 70, 90)
        updateStatus(statusLabel, "Idle", Color3.fromRGB(110, 110, 110))
        if autoGrabThread then task.cancel(autoGrabThread) autoGrabThread = nil end
    end
end)

-- Dropdown open/close animation
local dropTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
dropdownBtn.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    if dropdownOpen then
        dropdownBtn.Text = "Select Items to Grab  ▲"
        TweenService:Create(dropdownList, dropTweenInfo, {
            Size = UDim2.new(1, 0, 0, DROPDOWN_FULL_H)
        }):Play()
        -- Push all elements below the dropdown down
        for _, entry in ipairs(pushElements) do
            TweenService:Create(entry.obj, dropTweenInfo, {
                Position = UDim2.new(
                    entry.obj.Position.X.Scale, entry.obj.Position.X.Offset,
                    0, entry.base + DROPDOWN_FULL_H
                )
            }):Play()
        end
        TweenService:Create(content, dropTweenInfo, {
            CanvasSize = UDim2.new(0, 0, 0, 590 + DROPDOWN_FULL_H)
        }):Play()
    else
        dropdownBtn.Text = "Select Items to Grab  ▼"
        TweenService:Create(dropdownList, dropTweenInfo, {
            Size = UDim2.new(1, 0, 0, 0)
        }):Play()
        -- Push elements back up to base positions
        for _, entry in ipairs(pushElements) do
            TweenService:Create(entry.obj, dropTweenInfo, {
                Position = UDim2.new(
                    entry.obj.Position.X.Scale, entry.obj.Position.X.Offset,
                    0, entry.base
                )
            }):Play()
        end
        TweenService:Create(content, dropTweenInfo, {
            CanvasSize = UDim2.new(0, 0, 0, 590)
        }):Play()
    end
end)

-- Auto-Cook toggle
cookBtn.MouseButton1Click:Connect(function()
    autoCookEnabled = not autoCookEnabled
    if autoCookEnabled then
        cookBtn.Text = "Auto-Cook   [ ON ]"
        cookBtn.BackgroundColor3 = Color3.fromRGB(60, 35, 10)
        cookBtnStroke.Color = Color3.fromRGB(255, 150, 30)
        updateStatus(statusLabel, "Auto-Cooking...", Color3.fromRGB(255, 160, 40))
        autoCookThread = task.spawn(function()
            autoCookLoop(statusLabel)
        end)
    else
        cookBtn.Text = "Auto-Cook   [ OFF ]"
        cookBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        cookBtnStroke.Color = Color3.fromRGB(70, 70, 90)
        updateStatus(statusLabel, "Idle", Color3.fromRGB(110, 110, 110))
        if autoCookThread then task.cancel(autoCookThread) autoCookThread = nil end
    end
end)

-- Max bag size input
maxBagInput.FocusLost:Connect(function()
    local val = tonumber(maxBagInput.Text)
    if val and val >= 1 and val <= 20 then
        maxBagSize = math.floor(val)
        maxBagInput.Text = tostring(maxBagSize)
        maxBagInputStroke.Color = Color3.fromRGB(50, 190, 70)
        task.delay(1, function()
            maxBagInputStroke.Color = Color3.fromRGB(80, 80, 100)
        end)
    else
        maxBagInput.Text = tostring(maxBagSize)
        maxBagInputStroke.Color = Color3.fromRGB(200, 60, 60)
        task.delay(1, function()
            maxBagInputStroke.Color = Color3.fromRGB(80, 80, 100)
        end)
    end
end)

-- ESP Entity toggle
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        espBtn.Text = "ESP Entity   [ ON ]"
        espBtn.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
        espBtnStroke.Color = Color3.fromRGB(220, 60, 60)
        espThread = task.spawn(espLoop)
    else
        espBtn.Text = "ESP Entity   [ OFF ]"
        espBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        espBtnStroke.Color = Color3.fromRGB(70, 70, 90)
        if espThread then task.cancel(espThread) espThread = nil end
        clearESP()
    end
end)

-- Return to Map button
returnBtn.MouseButton1Click:Connect(function()
    local mapPart = findMapPart()
    if mapPart then
        safeTeleport(mapPart)
        updateStatus(statusLabel, "Returned to Map.", Color3.fromRGB(110, 110, 110))
    else
        updateStatus(statusLabel, "Map not found!", Color3.fromRGB(200, 80, 80))
    end
end)

player.CharacterAdded:Connect(function(char)
    character = char
    removeFloatPart()
end)

-- =============================================
print("[Fatal Floors Script v1] Loaded! Made by Devious Goober.")
-- =============================================
