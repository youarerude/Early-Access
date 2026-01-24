-- ▖▖▗   ▄▖▖ ▖▄▖▄▖▖▖▄▖▄▖▄▖▄   ▄▖▄ ▖  ▖▄▖▖ ▖
-- ▌▌▜   ▙▖▛▖▌▌ ▙▘▌▌▙▌▐ ▙▖▌▌  ▌▌▌▌▛▖▞▌▐ ▛▖▌
-- ▚▘▟▖  ▙▖▌▝▌▙▖▌▌▐ ▌ ▐ ▙▖▙▘  ▛▌▙▘▌▝ ▌▟▖▌▝▌
--                                        
-- Encryption Admin V1 in alpha.

print("▖▖▗   ▄▖▖ ▖▄▖▄▖▖▖▄▖▄▖▄▖▄   ▄▖▄ ▖  ▖▄▖▖ ▖")
print("▌▌▜   ▙▖▛▖▌▌ ▙▘▌▌▙▌▐ ▙▖▌▌  ▌▌▌▌▛▖▞▌▐ ▛▖▌")
print("▚▘▟▖  ▙▖▌▝▌▙▖▌▌▐ ▌ ▐ ▙▖▙▘  ▛▌▙▘▌▝ ▌▟▖▌▝▌")
print("                                        ")
print("Encryption Admin V1 in alpha.")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables
local noclipEnabled = false
local noclipConnection = nil
local commandPrefix = "√"
local flyEnabled = false
local flySpeed = 1
local flyBg = nil
local flyBv = nil
local flyControl = {f = 0, b = 0, l = 0, r = 0}
local lastExecutedCommand = nil
local lastExecutedValue = nil
local espEnabled = false
local espObjects = {}
local espConnections = {}
local espPartObjects = {}
local espPartConnections = {}
local invisibilityEnabled = false
local invisChair = nil
local requireScriptsMenu = nil
local chatLogGui = nil
local chatLogButton = nil

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EncryptionAdmin"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -25, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "[A]"
ToggleButton.TextColor3 = Color3.fromRGB(0, 100, 255)
ToggleButton.TextSize = 24
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

-- Button Corner
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 12)
ButtonCorner.Parent = ToggleButton

-- Button Stroke
local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = Color3.fromRGB(0, 100, 255)
ButtonStroke.Thickness = 2
ButtonStroke.Parent = ToggleButton

-- Particle Effect for Button
local ParticleEmitter = Instance.new("ParticleEmitter")
ParticleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
ParticleEmitter.Color = ColorSequence.new(Color3.fromRGB(0, 100, 255))
ParticleEmitter.Size = NumberSequence.new(0.3)
ParticleEmitter.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.5),
    NumberSequenceKeypoint.new(1, 1)
})
ParticleEmitter.Lifetime = NumberRange.new(0.5, 1)
ParticleEmitter.Rate = 20
ParticleEmitter.Speed = NumberRange.new(2, 4)
ParticleEmitter.SpreadAngle = Vector2.new(180, 180)
ParticleEmitter.Parent = ToggleButton

-- Glow Effect
local ButtonGlow = Instance.new("ImageLabel")
ButtonGlow.Name = "Glow"
ButtonGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
ButtonGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
ButtonGlow.AnchorPoint = Vector2.new(0.5, 0.5)
ButtonGlow.BackgroundTransparency = 1
ButtonGlow.Image = "rbxasset://textures/ui/Glow.png"
ButtonGlow.ImageColor3 = Color3.fromRGB(0, 100, 255)
ButtonGlow.ImageTransparency = 0.5
ButtonGlow.ZIndex = 0
ButtonGlow.Parent = ToggleButton

-- Main Frame (Admin GUI)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 50, 0, 50)
MainFrame.Position = UDim2.new(0.5, -25, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Main Frame Corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Main Frame Stroke
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 100, 255)
MainStroke.Thickness = 3
MainStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Encryption Admin [A]"
TitleLabel.TextColor3 = Color3.fromRGB(0, 100, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Search Bar
local SearchBar = Instance.new("TextBox")
SearchBar.Name = "SearchBar"
SearchBar.Size = UDim2.new(1, -20, 0, 35)
SearchBar.Position = UDim2.new(0, 10, 0, 50)
SearchBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SearchBar.BorderSizePixel = 0
SearchBar.PlaceholderText = "Search commands or type √command..."
SearchBar.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
SearchBar.Text = ""
SearchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBar.TextSize = 14
SearchBar.Font = Enum.Font.Gotham
SearchBar.TextXAlignment = Enum.TextXAlignment.Left
SearchBar.ClearTextOnFocus = false
SearchBar.Parent = MainFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = SearchBar

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Color = Color3.fromRGB(0, 100, 255)
SearchStroke.Thickness = 1
SearchStroke.Parent = SearchBar

local SearchPadding = Instance.new("UIPadding")
SearchPadding.PaddingLeft = UDim.new(0, 10)
SearchPadding.PaddingRight = UDim.new(0, 10)
SearchPadding.Parent = SearchBar

-- Value Input Box
local ValueInput = Instance.new("TextBox")
ValueInput.Name = "ValueInput"
ValueInput.Size = UDim2.new(1, -20, 0, 35)
ValueInput.Position = UDim2.new(0, 10, 0, 95)
ValueInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ValueInput.BorderSizePixel = 0
ValueInput.PlaceholderText = "Value (for commands like √Speed 5)"
ValueInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
ValueInput.Text = ""
ValueInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueInput.TextSize = 14
ValueInput.Font = Enum.Font.Gotham
ValueInput.TextXAlignment = Enum.TextXAlignment.Left
ValueInput.ClearTextOnFocus = false
ValueInput.Parent = MainFrame

local ValueCorner = Instance.new("UICorner")
ValueCorner.CornerRadius = UDim.new(0, 8)
ValueCorner.Parent = ValueInput

local ValueStroke = Instance.new("UIStroke")
ValueStroke.Color = Color3.fromRGB(0, 100, 255)
ValueStroke.Thickness = 1
ValueStroke.Parent = ValueInput

local ValuePadding = Instance.new("UIPadding")
ValuePadding.PaddingLeft = UDim.new(0, 10)
ValuePadding.PaddingRight = UDim.new(0, 10)
ValuePadding.Parent = ValueInput

-- Scroll Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -20, 1, -150)
ScrollFrame.Position = UDim2.new(0, 10, 0, 140)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 100, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 8)
ScrollCorner.Parent = ScrollFrame

local ScrollStroke = Instance.new("UIStroke")
ScrollStroke.Color = Color3.fromRGB(0, 100, 255)
ScrollStroke.Thickness = 1
ScrollStroke.Parent = ScrollFrame

-- List Layout for Commands
local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = ScrollFrame

local ListPadding = Instance.new("UIPadding")
ListPadding.PaddingTop = UDim.new(0, 5)
ListPadding.PaddingBottom = UDim.new(0, 5)
ListPadding.PaddingLeft = UDim.new(0, 5)
ListPadding.PaddingRight = UDim.new(0, 5)
ListPadding.Parent = ScrollFrame

-- Commands Data Structure
local Commands = {
    {
        name = "√Speed",
        aliases = "√ws, √walkspeed",
        description = "Sets your character speed",
        requiresValue = true,
        valueType = "number",
        func = function(value)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local speed = tonumber(value)
                if speed then
                    LocalPlayer.Character.Humanoid.WalkSpeed = speed
                    return true, "Speed set to " .. speed
                else
                    return false, "Invalid speed value"
                end
            end
            return false, "Character not found"
        end
    },
    {
        name = "√JumpPower",
        aliases = "√jp, √jump",
        description = "Sets your jump power",
        requiresValue = true,
        valueType = "number",
        func = function(value)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local power = tonumber(value)
                if power then
                    LocalPlayer.Character.Humanoid.JumpPower = power
                    LocalPlayer.Character.Humanoid.UseJumpPower = true
                    return true, "Jump power set to " .. power
                else
                    return false, "Invalid jump power value"
                end
            end
            return false, "Character not found"
        end
    },
    {
        name = "√Goto",
        aliases = "√tp, √teleport",
        description = "Teleport to a player",
        requiresValue = true,
        valueType = "player",
        func = function(value)
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                return false, "Your character not found"
            end
            
            local targetPlayer = findPlayer(value)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                return true, "Teleported to " .. targetPlayer.DisplayName
            else
                return false, "Player not found or has no character"
            end
        end
    },
    {
        name = "√Fly",
        aliases = "√flight",
        description = "Enable fly with custom speed",
        requiresValue = true,
        valueType = "number",
        func = function(value)
            local speed = tonumber(value) or 1
            if speed < 1 then speed = 1 end
            enableFly(speed)
            return true, "Fly enabled with speed " .. speed
        end
    },
    {
        name = "√Unfly",
        aliases = "√unflight",
        description = "Disable fly",
        requiresValue = false,
        func = function()
            disableFly()
            return true, "Fly disabled"
        end
    },
    {
        name = "√Noclip",
        aliases = "√clip",
        description = "Enable noclip through objects",
        requiresValue = false,
        func = function()
            enableNoclip()
            return true, "Noclip enabled"
        end
    },
    {
        name = "√Unnoclip",
        aliases = "√unclip",
        description = "Disable noclip",
        requiresValue = false,
        func = function()
            disableNoclip()
            return true, "Noclip disabled"
        end
    },
    {
        name = "√PreviousCommand",
        aliases = "√prev, √last, √again",
        description = "Re-execute the previous command",
        requiresValue = false,
        func = function()
            if lastExecutedCommand then
                local success, message = lastExecutedCommand(lastExecutedValue)
                return success, "Re-executed: " .. (message or "Previous command")
            else
                return false, "No previous command to execute"
            end
        end
    },
    {
        name = "√ESP",
        aliases = "√wallhack",
        description = "Enable ESP for all players",
        requiresValue = false,
        func = function()
            enableESP()
            return true, "ESP enabled for all players"
        end
    },
    {
        name = "√UnESP",
        aliases = "√unesp, √unwallhack",
        description = "Disable ESP",
        requiresValue = false,
        func = function()
            disableESP()
            return true, "ESP disabled"
        end
    },
    {
        name = "√ESPPart",
        aliases = "√esppart, √EspP, √EPart",
        description = "Highlight specific parts/models",
        requiresValue = true,
        valueType = "string",
        func = function(value)
            if not value or value == "" then
                return false, "Please specify a part or model name"
            end
            
            enableESPPart(value)
            return true, "ESP enabled for: " .. value
        end
    },
    {
        name = "√UnESPPart",
        aliases = "√unespp, √UEP, √Unsp, √unesppart",
        description = "Disable ESP for specific parts",
        requiresValue = true,
        valueType = "string",
        func = function(value)
            if not value or value == "" then
                return false, "Please specify a part or model name"
            end
            
            local count = disableSpecificESPPart(value)
            if count > 0 then
                return true, "Removed ESP from " .. count .. " objects matching '" .. value .. "'"
            else
                return false, "No ESP objects found matching '" .. value .. "'"
            end
        end
    },
    {
        name = "√UnESPAllPart",
        aliases = "√UEAP, √unespallpart, √Unespap",
        description = "Disable all part ESP",
        requiresValue = false,
        func = function()
            local count = #espPartObjects
            disableESPPart()
            return true, "Disabled ESP for all " .. count .. " objects"
        end
    },
    {
        name = "√Invisible",
        aliases = "√invisible, √Invis",
        description = "Make yourself invisible",
        requiresValue = false,
        func = function()
            enableInvisibility()
            return true, "Invisibility enabled"
        end
    },
    {
        name = "√UnInvisible",
        aliases = "√uninvisible, √Visible, √Vis",
        description = "Disable invisibility",
        requiresValue = false,
        func = function()
            disableInvisibility()
            return true, "Invisibility disabled"
        end
    },
    {
        name = "√RequireScripts",
        aliases = "√requirescripts, √RS, √backdoor, √ReqScript",
        description = "Open require scripts menu",
        requiresValue = false,
        func = function()
            openRequireScriptsMenu()
            return true, "Require scripts menu opened"
        end
    },
    {
        name = "√ChatLog",
        aliases = "√chatlog, √ChatLogger, √ChatLg",
        description = "Open chat logger",
        requiresValue = false,
        func = function()
            openChatLog()
            return true, "Chat logger opened"
        end
    },
    {
        name = "√Headsit",
        aliases = "√hsit, √headt, √hs",
        description = "Sit on a player's head",
        requiresValue = true,
        valueType = "player",
        func = function(value)
            local you = LocalPlayer.Character
            if not you then
                return false, "Your character not found"
            end
            
            local humanoid = you:FindFirstChild("Humanoid")
            local humanoidrootpart = you:FindFirstChild("HumanoidRootPart")
            
            if not humanoid or not humanoidrootpart then
                return false, "Your character is missing required parts"
            end
            
            local targetPlayer = findPlayer(value)
            if not targetPlayer or not targetPlayer.Character then
                return false, "Player not found or has no character"
            end
            
            local plr = targetPlayer.Character
            local plrhead = plr:FindFirstChild("Head")
            local plrhumanoid = plr:FindFirstChild("Humanoid")
            
            if not plrhead or not plrhumanoid then
                return false, "Player has no head or humanoid"
            end
            
            -- Execute headsit
            humanoidrootpart.CFrame = plrhead.CFrame * CFrame.new(0, 0, 1)
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = humanoidrootpart
            weld.Part1 = plrhead
            weld.Parent = humanoidrootpart
            humanoid.Sit = true
            
            -- Continuous loop to maintain headsit
            spawn(function()
                while true do
                    task.wait(0.01)
                    plrhead.CanCollide = false
                    
                    if not plr or not plr.Parent then
                        weld:Destroy()
                        humanoid.Sit = false
                        plrhead.CanCollide = true
                        break
                    end
                    
                    if humanoid.Health == 0 then
                        weld:Destroy()
                        plrhead.CanCollide = true
                        break
                    end
                    
                    if humanoid.Jump == true then
                        weld:Destroy()
                        plrhead.CanCollide = true
                        humanoid.Jump = true
                        break
                    end
                end
            end)
            
            return true, "Now sitting on " .. targetPlayer.DisplayName .. "'s head"
        end
    },
    {
        name = "√InfiniteYield",
        aliases = "√infyield, √infiniteyield, √iy, √IY",
        description = "Load Infinite Yield admin script",
        requiresValue = false,
        func = function()
            local success, err = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
            end)
            
            if success then
                return true, "Infinite Yield loaded successfully"
            else
                return false, "Failed to load Infinite Yield: " .. tostring(err)
            end
        end
    }
}

-- Helper Functions
function findPlayer(input)
    if not input or input == "" then return nil end
    
    local searchInput = input:lower()
    local players = Players:GetPlayers()
    
    -- First try exact username match
    for _, player in ipairs(players) do
        if player.Name:lower() == searchInput then
            return player
        end
    end
    
    -- Then try exact display name match
    for _, player in ipairs(players) do
        if player.DisplayName:lower() == searchInput then
            return player
        end
    end
    
    -- Then try partial username match
    for _, player in ipairs(players) do
        if player.Name:lower():find(searchInput, 1, true) then
            return player
        end
    end
    
    -- Finally try partial display name match
    for _, player in ipairs(players) do
        if player.DisplayName:lower():find(searchInput, 1, true) then
            return player
        end
    end
    
    return nil
end

function enableNoclip()
    if noclipEnabled then return end
    noclipEnabled = true
    
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        if not LocalPlayer.Character then return end
        
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

function disableNoclip()
    noclipEnabled = false
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

function enableFly(speed)
    if flyEnabled then
        disableFly()
        task.wait(0.1)
    end
    
    flyEnabled = true
    flySpeed = speed or 1
    
    local speaker = LocalPlayer
    if not speaker.Character then return end
    
    local chr = speaker.Character
    local hum = chr:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    
    -- Disable humanoid states
    hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
    
    -- Disable animations
    chr.Animate.Disabled = true
    local AnimController = chr:FindFirstChildOfClass("Humanoid") or chr:FindFirstChildOfClass("AnimationController")
    if AnimController then
        for _, track in pairs(AnimController:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(0)
        end
    end
    
    -- Setup tp walking
    for i = 1, flySpeed do
        spawn(function()
            local hb = RunService.Heartbeat
            local tpwalking = true
            
            while flyEnabled and hb:Wait() and chr and hum and hum.Parent do
                if hum.MoveDirection.Magnitude > 0 then
                    chr:TranslateBy(hum.MoveDirection)
                end
            end
        end)
    end
    
    -- Determine rig type and setup fly
    local isR6 = hum.RigType == Enum.HumanoidRigType.R6
    local torso = isR6 and chr:FindFirstChild("Torso") or chr:FindFirstChild("UpperTorso")
    
    if not torso then return end
    
    local maxspeed = 50
    local currentSpeed = 0
    local lastctrl = {f = 0, b = 0, l = 0, r = 0}
    
    flyBg = Instance.new("BodyGyro", torso)
    flyBg.P = 9e4
    flyBg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBg.cframe = torso.CFrame
    
    flyBv = Instance.new("BodyVelocity", torso)
    flyBv.velocity = Vector3.new(0, 0.1, 0)
    flyBv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    hum.PlatformStand = true
    
    -- Setup controls
    local flyConnection
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled or hum.Health == 0 then
            if flyConnection then
                flyConnection:Disconnect()
            end
            return
        end
        
        if flyControl.l + flyControl.r ~= 0 or flyControl.f + flyControl.b ~= 0 then
            currentSpeed = currentSpeed + 0.5 + (currentSpeed / maxspeed)
            if currentSpeed > maxspeed then
                currentSpeed = maxspeed
            end
        elseif not (flyControl.l + flyControl.r ~= 0 or flyControl.f + flyControl.b ~= 0) and currentSpeed ~= 0 then
            currentSpeed = currentSpeed - 1
            if currentSpeed < 0 then
                currentSpeed = 0
            end
        end
        
        if (flyControl.l + flyControl.r) ~= 0 or (flyControl.f + flyControl.b) ~= 0 then
            flyBv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (flyControl.f + flyControl.b)) + 
                ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(flyControl.l + flyControl.r, (flyControl.f + flyControl.b) * 0.2, 0).p) - 
                workspace.CurrentCamera.CoordinateFrame.p)) * currentSpeed
            lastctrl = {f = flyControl.f, b = flyControl.b, l = flyControl.l, r = flyControl.r}
        elseif (flyControl.l + flyControl.r) == 0 and (flyControl.f + flyControl.b) == 0 and currentSpeed ~= 0 then
            flyBv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f + lastctrl.b)) + 
                ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - 
                workspace.CurrentCamera.CoordinateFrame.p)) * currentSpeed
        else
            flyBv.velocity = Vector3.new(0, 0, 0)
        end
        
        flyBg.cframe = workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((flyControl.f + flyControl.b) * 50 * currentSpeed / maxspeed), 0, 0)
    end)
end

function disableFly()
    flyEnabled = false
    flyControl = {f = 0, b = 0, l = 0, r = 0}
    
    if flyBg then
        flyBg:Destroy()
        flyBg = nil
    end
    
    if flyBv then
        flyBv:Destroy()
        flyBv = nil
    end
    
    local speaker = LocalPlayer
    if speaker.Character then
        local chr = speaker.Character
        local hum = chr:FindFirstChildWhichIsA("Humanoid")
        
        if hum then
            hum.PlatformStand = false
            
            -- Re-enable humanoid states
            hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
            hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
        
        chr.Animate.Disabled = false
    end
end

-- Fly controls (WASD)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not flyEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        flyControl.f = 1
    elseif input.KeyCode == Enum.KeyCode.S then
        flyControl.b = -1
    elseif input.KeyCode == Enum.KeyCode.A then
        flyControl.l = -1
    elseif input.KeyCode == Enum.KeyCode.D then
        flyControl.r = 1
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if not flyEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        flyControl.f = 0
    elseif input.KeyCode == Enum.KeyCode.S then
        flyControl.b = 0
    elseif input.KeyCode == Enum.KeyCode.A then
        flyControl.l = 0
    elseif input.KeyCode == Enum.KeyCode.D then
        flyControl.r = 0
    end
end)

function enableESP()
    if espEnabled then
        disableESP()
        task.wait(0.1)
    end
    
    espEnabled = true
    
    local function createESPForPlayer(player)
        if player == LocalPlayer then return end
        
        local function setupESP(character)
            if not espEnabled then return end
            if espObjects[player] then
                -- Clean up old ESP
                if espObjects[player].Highlight then
                    espObjects[player].Highlight:Destroy()
                end
                if espObjects[player].BillboardGui then
                    espObjects[player].BillboardGui:Destroy()
                end
            end
            
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
            local humanoid = character:WaitForChild("Humanoid", 5)
            
            if not humanoidRootPart or not humanoid then return end
            
            -- Create Highlight
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.Adornee = character
            highlight.FillColor = Color3.fromRGB(0, 100, 255)
            highlight.OutlineColor = Color3.fromRGB(0, 150, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = character
            
            -- Create BillboardGui
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESPBillboard"
            billboard.Adornee = humanoidRootPart
            billboard.Size = UDim2.new(0, 200, 0, 100)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = humanoidRootPart
            
            -- Create background frame
            local bgFrame = Instance.new("Frame")
            bgFrame.Size = UDim2.new(1, 0, 1, 0)
            bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            bgFrame.BackgroundTransparency = 0.5
            bgFrame.BorderSizePixel = 0
            bgFrame.Parent = billboard
            
            local bgCorner = Instance.new("UICorner")
            bgCorner.CornerRadius = UDim.new(0, 8)
            bgCorner.Parent = bgFrame
            
            -- Create text label
            local textLabel = Instance.new("TextLabel")
            textLabel.Name = "InfoLabel"
            textLabel.Size = UDim2.new(1, -10, 1, -10)
            textLabel.Position = UDim2.new(0, 5, 0, 5)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextSize = 14
            textLabel.Font = Enum.Font.GothamBold
            textLabel.TextWrapped = true
            textLabel.TextYAlignment = Enum.TextYAlignment.Top
            textLabel.Parent = bgFrame
            
            espObjects[player] = {
                Highlight = highlight,
                BillboardGui = billboard,
                TextLabel = textLabel,
                Character = character,
                Humanoid = humanoid,
                HumanoidRootPart = humanoidRootPart
            }
            
            -- Update loop for this player
            local updateConnection
            updateConnection = RunService.Heartbeat:Connect(function()
                if not espEnabled or not espObjects[player] or not character.Parent then
                    if updateConnection then
                        updateConnection:Disconnect()
                    end
                    return
                end
                
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                    local health = math.floor(humanoid.Health)
                    local maxHealth = math.floor(humanoid.MaxHealth)
                    
                    textLabel.Text = string.format(
                        "%s\n%s\nHP: %d/%d\n%.1f Studs",
                        player.Name,
                        player.DisplayName,
                        health,
                        maxHealth,
                        distance
                    )
                    
                    -- Color based on health
                    local healthPercent = health / maxHealth
                    if healthPercent > 0.6 then
                        highlight.FillColor = Color3.fromRGB(0, 255, 0)
                        highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                    elseif healthPercent > 0.3 then
                        highlight.FillColor = Color3.fromRGB(255, 255, 0)
                        highlight.OutlineColor = Color3.fromRGB(200, 200, 0)
                    else
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
                    end
                end
            end)
            
            table.insert(espConnections, updateConnection)
        end
        
        if player.Character then
            setupESP(player.Character)
        end
        
        local charAddedConnection = player.CharacterAdded:Connect(function(character)
            if espEnabled then
                task.wait(0.5)
                setupESP(character)
            end
        end)
        
        table.insert(espConnections, charAddedConnection)
    end
    
    -- Setup ESP for all current players
    for _, player in pairs(Players:GetPlayers()) do
        createESPForPlayer(player)
    end
    
    -- Setup ESP for new players
    local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
        if espEnabled then
            createESPForPlayer(player)
        end
    end)
    
    table.insert(espConnections, playerAddedConnection)
    
    -- Handle player removing
    local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        if espObjects[player] then
            if espObjects[player].Highlight then
                espObjects[player].Highlight:Destroy()
            end
            if espObjects[player].BillboardGui then
                espObjects[player].BillboardGui:Destroy()
            end
            espObjects[player] = nil
        end
    end)
    
    table.insert(espConnections, playerRemovingConnection)
end

function disableESP()
    espEnabled = false
    
    -- Disconnect all connections
    for _, connection in pairs(espConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    espConnections = {}
    
    -- Clean up all ESP objects
    for player, espData in pairs(espObjects) do
        if espData.Highlight then
            espData.Highlight:Destroy()
        end
        if espData.BillboardGui then
            espData.BillboardGui:Destroy()
        end
    end
    espObjects = {}
end

function enableESPPart(partName)
    -- Clear previous ESP parts
    for _, highlight in pairs(espPartObjects) do
        if highlight then
            highlight:Destroy()
        end
    end
    espPartObjects = {}
    
    for _, connection in pairs(espPartConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    espPartConnections = {}
    
    local searchName = partName:lower()
    local foundCount = 0
    
    local function highlightObject(obj)
        -- Check if it's a BasePart or Model
        local isBasePart = obj:IsA("BasePart")
        local isModel = obj:IsA("Model")
        
        if not (isBasePart or isModel) then return end
        
        -- Check if name matches
        if not obj.Name:lower():find(searchName, 1, true) then return end
        
        -- Don't highlight player characters
        if obj:FindFirstAncestorOfClass("Model") then
            local model = obj:FindFirstAncestorOfClass("Model")
            if Players:GetPlayerFromCharacter(model) then
                return
            end
        end
        
        -- Create highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPPartHighlight"
        highlight.Adornee = isModel and obj or obj.Parent
        highlight.FillColor = Color3.fromRGB(255, 0, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 100, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = obj
        
        table.insert(espPartObjects, highlight)
        foundCount = foundCount + 1
        
        -- Create BillboardGui for distance tracking
        if isBasePart or (isModel and obj:FindFirstChild("PrimaryPart")) then
            local targetPart = isBasePart and obj or obj.PrimaryPart
            if targetPart then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESPPartBillboard"
                billboard.Adornee = targetPart
                billboard.Size = UDim2.new(0, 150, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 2, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = targetPart
                
                local bgFrame = Instance.new("Frame")
                bgFrame.Size = UDim2.new(1, 0, 1, 0)
                bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                bgFrame.BackgroundTransparency = 0.5
                bgFrame.BorderSizePixel = 0
                bgFrame.Parent = billboard
                
                local bgCorner = Instance.new("UICorner")
                bgCorner.CornerRadius = UDim.new(0, 8)
                bgCorner.Parent = bgFrame
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Name = "InfoLabel"
                textLabel.Size = UDim2.new(1, -10, 1, -10)
                textLabel.Position = UDim2.new(0, 5, 0, 5)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.TextSize = 14
                textLabel.Font = Enum.Font.GothamBold
                textLabel.TextWrapped = true
                textLabel.Parent = bgFrame
                
                table.insert(espPartObjects, billboard)
                
                -- Update loop for distance
                local updateConnection = RunService.Heartbeat:Connect(function()
                    if not targetPart.Parent then
                        if billboard then billboard:Destroy() end
                        if highlight then highlight:Destroy() end
                        return
                    end
                    
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude
                        textLabel.Text = string.format("%s\n%.1f Studs", obj.Name, distance)
                    end
                end)
                
                table.insert(espPartConnections, updateConnection)
            end
        end
    end
    
    -- Search in workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        highlightObject(obj)
    end
    
    -- Monitor for new objects
    local descendantAddedConnection = workspace.DescendantAdded:Connect(function(obj)
        task.wait(0.1)
        highlightObject(obj)
    end)
    
    table.insert(espPartConnections, descendantAddedConnection)
    
    if foundCount > 0 then
        createNotification("Highlighted " .. foundCount .. " objects matching '" .. partName .. "'", true)
    else
        createNotification("No objects found matching '" .. partName .. "'", false)
    end
end

function disableESPPart()
    -- Clean up all ESP part highlights
    for _, obj in pairs(espPartObjects) do
        if obj then
            obj:Destroy()
        end
    end
    espPartObjects = {}
    
    -- Disconnect all connections
    for _, connection in pairs(espPartConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    espPartConnections = {}
end

function disableSpecificESPPart(partName)
    local searchName = partName:lower()
    local removedCount = 0
    local objectsToKeep = {}
    
    for i, obj in pairs(espPartObjects) do
        if obj and obj.Parent then
            -- Check if this object matches the name to remove
            local adornee = obj.Adornee or obj:FindFirstAncestorOfClass("Model") or obj.Parent
            
            if adornee and adornee.Name:lower():find(searchName, 1, true) then
                obj:Destroy()
                removedCount = removedCount + 1
            else
                table.insert(objectsToKeep, obj)
            end
        end
    end
    
    espPartObjects = objectsToKeep
    return removedCount
end

function enableInvisibility()
    if invisibilityEnabled then
        return
    end
    
    invisibilityEnabled = true
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        invisibilityEnabled = false
        return
    end
    
    local savedpos = LocalPlayer.Character.HumanoidRootPart.CFrame
    task.wait()
    LocalPlayer.Character:MoveTo(Vector3.new(-25.95, 84, 3537.55))
    task.wait(0.15)
    
    invisChair = Instance.new('Seat', workspace)
    invisChair.Anchored = false
    invisChair.CanCollide = false
    invisChair.Name = 'EncryptionInvisChair'
    invisChair.Transparency = 1
    invisChair.Position = Vector3.new(-25.95, 84, 3537.55)
    
    local Weld = Instance.new("Weld", invisChair)
    Weld.Part0 = invisChair
    Weld.Part1 = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
    
    task.wait()
    invisChair.CFrame = savedpos
    
    -- Set transparency
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = 0.5
        end
    end
end

function disableInvisibility()
    if not invisibilityEnabled then
        return
    end
    
    invisibilityEnabled = false
    
    -- Remove invisible chair
    if invisChair then
        invisChair:Destroy()
        invisChair = nil
    end
    
    -- Also check workspace for the chair
    local chairInWorkspace = workspace:FindFirstChild('EncryptionInvisChair')
    if chairInWorkspace then
        chairInWorkspace:Destroy()
    end
    
    -- Reset transparency
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = 0
            end
        end
        
        -- Fix head transparency
        local head = LocalPlayer.Character:FindFirstChild("Head")
        if head then
            head.Transparency = 0
            local face = head:FindFirstChild("face")
            if face then
                face.Transparency = 0
            end
        end
    end
end

-- Require Scripts Data
local RequireScripts = {
    {
        section = "Others",
        scripts = {
            {name = "KJ", code = 'require(17776365113).kj("Insert your username")', desc = "Loads KJ."},
            {name = "Grab Knife", code = 'require(14638461547).GKV1("Insert your username")', desc = "Loads GKV1/Grab Knife."},
            {name = "You are an Idiot", code = 'require(8222129769).youareanidiot("Insert victim name")', desc = "Gives you are an idiot virus to players."},
            {name = "Memelord", code = 'require(6583586016).load("Your Name Here")', desc = "Loads Memelord."},
            {name = "AI Special Ops", code = 'require(7215403029).RRT("Your Name Here")', desc = "Spawns 9 Special ops bot around you to protect you."},
            {name = "Polaris Cube", code = 'require(6583577614).load("Your Name Here")', desc = "Loads Polaris Cube."}
        }
    },
    {
        section = "Destructive",
        scripts = {
            {name = "Dex Explorer", code = 'require(14572394952)("Your Name Here")', desc = "Loads Dark Dex."},
            {name = "Obama Jumpscare", code = 'for i,v in pairs(game.Players:GetPlayers()) do require(94540928447702).s(v.Name) end', desc = "Triggers obama jumpscare to all players."},
            {name = "Missile Launcher", code = 'require(7804327506).amigodogodenot123("Your Name Here")', desc = "Gives you the privilege to destroy the server with missile."}
        }
    },
    {
        section = "Maps",
        scripts = {
            {name = "Space Elevator", code = 'require(5702244094).space("YourNameHere")', desc = "Loads space elevator map."}
        }
    },
    {
        section = "Admins",
        scripts = {
            {name = "Infinite Yield", code = 'require(7634392335)("your name here")', desc = "Loads infinite yield admin."}
        }
    }
}

function openRequireScriptsMenu()
    -- Close if already open with animation
    if requireScriptsMenu then
        closeRequireScriptsMenu()
        return
    end
    
    -- Create menu frame
    local targetWidth = math.min(380, ScreenGui.AbsoluteSize.X - 20)
    local targetHeight = math.min(450, ScreenGui.AbsoluteSize.Y - 100)
    
    requireScriptsMenu = Instance.new("Frame")
    requireScriptsMenu.Name = "RequireScriptsMenu"
    requireScriptsMenu.Size = UDim2.new(0, 50, 0, 50)
    requireScriptsMenu.Position = UDim2.new(0.5, -25, 0.5, -25)
    requireScriptsMenu.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    requireScriptsMenu.BorderSizePixel = 0
    requireScriptsMenu.BackgroundTransparency = 1
    requireScriptsMenu.ClipsDescendants = true
    requireScriptsMenu.Parent = ScreenGui
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 12)
    menuCorner.Parent = requireScriptsMenu
    
    local menuStroke = Instance.new("UIStroke")
    menuStroke.Color = Color3.fromRGB(0, 100, 255)
    menuStroke.Thickness = 3
    menuStroke.Parent = requireScriptsMenu
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = requireScriptsMenu
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Require Scripts Menu"
    titleLabel.TextColor3 = Color3.fromRGB(0, 100, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 8)
    closeBtnCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        closeRequireScriptsMenu()
    end)
    
    -- Scroll frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 100, 255)
    scrollFrame.Parent = requireScriptsMenu
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 8)
    scrollCorner.Parent = scrollFrame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scrollFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = scrollFrame
    
    -- Populate scripts
    local totalHeight = 10
    
    for _, category in ipairs(RequireScripts) do
        -- Section header
        local sectionHeader = Instance.new("TextLabel")
        sectionHeader.Size = UDim2.new(1, -20, 0, 30)
        sectionHeader.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
        sectionHeader.Text = "  " .. category.section
        sectionHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
        sectionHeader.TextSize = 16
        sectionHeader.Font = Enum.Font.GothamBold
        sectionHeader.TextXAlignment = Enum.TextXAlignment.Left
        sectionHeader.Parent = scrollFrame
        
        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 6)
        headerCorner.Parent = sectionHeader
        
        totalHeight = totalHeight + 40
        
        -- Scripts in section
        for _, script in ipairs(category.scripts) do
            local scriptFrame = Instance.new("Frame")
            scriptFrame.Size = UDim2.new(1, -20, 0, 90)
            scriptFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            scriptFrame.BorderSizePixel = 0
            scriptFrame.Parent = scrollFrame
            
            local scriptCorner = Instance.new("UICorner")
            scriptCorner.CornerRadius = UDim.new(0, 8)
            scriptCorner.Parent = scriptFrame
            
            local scriptStroke = Instance.new("UIStroke")
            scriptStroke.Color = Color3.fromRGB(0, 100, 255)
            scriptStroke.Thickness = 1
            scriptStroke.Transparency = 0.5
            scriptStroke.Parent = scriptFrame
            
            -- Script name
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -70, 0, 20)
            nameLabel.Position = UDim2.new(0, 10, 0, 5)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = script.name
            nameLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
            nameLabel.TextSize = 14
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = scriptFrame
            
            -- Description
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, -70, 0, 30)
            descLabel.Position = UDim2.new(0, 10, 0, 25)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = script.desc
            descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            descLabel.TextSize = 11
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.TextYAlignment = Enum.TextYAlignment.Top
            descLabel.TextWrapped = true
            descLabel.Parent = scriptFrame
            
            -- Code display
            local codeLabel = Instance.new("TextLabel")
            codeLabel.Size = UDim2.new(1, -70, 0, 30)
            codeLabel.Position = UDim2.new(0, 10, 0, 55)
            codeLabel.BackgroundTransparency = 1
            codeLabel.Text = script.code
            codeLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            codeLabel.TextSize = 10
            codeLabel.Font = Enum.Font.Code
            codeLabel.TextXAlignment = Enum.TextXAlignment.Left
            codeLabel.TextYAlignment = Enum.TextYAlignment.Top
            codeLabel.TextWrapped = true
            codeLabel.Parent = scriptFrame
            
            -- Copy button
            local copyBtn = Instance.new("TextButton")
            copyBtn.Size = UDim2.new(0, 50, 0, 35)
            copyBtn.Position = UDim2.new(1, -55, 0.5, -17.5)
            copyBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
            copyBtn.Text = "COPY"
            copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            copyBtn.TextSize = 11
            copyBtn.Font = Enum.Font.GothamBold
            copyBtn.Parent = scriptFrame
            
            local copyCorner = Instance.new("UICorner")
            copyCorner.CornerRadius = UDim.new(0, 6)
            copyCorner.Parent = copyBtn
            
            copyBtn.MouseButton1Click:Connect(function()
                setclipboard(script.code)
                createNotification("Copied: " .. script.name, true)
                copyBtn.Text = "✓"
                copyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                task.wait(1)
                copyBtn.Text = "COPY"
                copyBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
            end)
            
            -- Hover effects
            copyBtn.MouseEnter:Connect(function()
                if copyBtn.Text == "COPY" then
                    TweenService:Create(copyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 100, 255)}):Play()
                end
            end)
            
            copyBtn.MouseLeave:Connect(function()
                if copyBtn.Text == "COPY" then
                    TweenService:Create(copyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 80, 200)}):Play()
                end
            end)
            
            scriptFrame.MouseEnter:Connect(function()
                TweenService:Create(scriptStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
            end)
            
            scriptFrame.MouseLeave:Connect(function()
                TweenService:Create(scriptStroke, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
            end)
            
            totalHeight = totalHeight + 100
        end
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    
    -- Expand animation
    local expandTween = TweenService:Create(requireScriptsMenu, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, targetWidth, 0, targetHeight),
        Position = UDim2.new(0.5, -targetWidth/2, 0.5, -targetHeight/2),
        BackgroundTransparency = 0
    })
    expandTween:Play()
    
    -- Fade in content
    expandTween.Completed:Connect(function()
        TweenService:Create(titleBar, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(closeBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        TweenService:Create(scrollFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        TweenService:Create(menuStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    end)
end

function closeRequireScriptsMenu()
    if not requireScriptsMenu then return end
    
    local menu = requireScriptsMenu
    requireScriptsMenu = nil
    
    -- Fade out content first
    local titleBar = menu:FindFirstChild("Frame")
    local scrollFrame = menu:FindFirstChild("ScrollingFrame")
    local menuStroke = menu:FindFirstChild("UIStroke")
    
    if titleBar then
        TweenService:Create(titleBar, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        local titleLabel = titleBar:FindFirstChild("TitleLabel") or titleBar:FindFirstChild("TextLabel")
        local closeBtn = titleBar:FindFirstChild("TextButton")
        if titleLabel then TweenService:Create(titleLabel, TweenInfo.new(0.2), {TextTransparency = 1}):Play() end
        if closeBtn then TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play() end
    end
    
    if scrollFrame then
        TweenService:Create(scrollFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    end
    
    if menuStroke then
        TweenService:Create(menuStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
    end
    
    task.wait(0.2)
    
    -- Shrink animation
    local shrinkTween = TweenService:Create(menu, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.5, -25, 0.5, -25),
        BackgroundTransparency = 1
    })
    shrinkTween:Play()
    shrinkTween.Completed:Connect(function()
        menu:Destroy()
    end)
end

function openChatLog()
    if chatLogGui then
        return
    end
    
    -- Create chat log button
    chatLogButton = Instance.new("TextButton")
    chatLogButton.Name = "ChatLogButton"
    chatLogButton.Size = UDim2.new(0, 100, 0, 30)
    chatLogButton.Position = UDim2.new(0, 10, 1, -40)
    chatLogButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    chatLogButton.BorderSizePixel = 0
    chatLogButton.Text = "[Chat V1.2]"
    chatLogButton.TextColor3 = Color3.fromRGB(0, 100, 255)
    chatLogButton.TextSize = 14
    chatLogButton.Font = Enum.Font.GothamBold
    chatLogButton.Parent = ScreenGui
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = chatLogButton
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(0, 100, 255)
    btnStroke.Thickness = 2
    btnStroke.Parent = chatLogButton
    
    -- Create main chat log GUI
    chatLogGui = Instance.new("Frame")
    chatLogGui.Name = "ChatLogGui"
    chatLogGui.Size = UDim2.new(0, 100, 0, 30)
    chatLogGui.Position = UDim2.new(0, 10, 1, -40)
    chatLogGui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    chatLogGui.BorderSizePixel = 0
    chatLogGui.Visible = false
    chatLogGui.ClipsDescendants = true
    chatLogGui.Active = true
    chatLogGui.Draggable = true
    chatLogGui.Parent = ScreenGui
    
    local guiCorner = Instance.new("UICorner")
    guiCorner.CornerRadius = UDim.new(0, 8)
    guiCorner.Parent = chatLogGui
    
    local guiStroke = Instance.new("UIStroke")
    guiStroke.Color = Color3.fromRGB(0, 100, 255)
    guiStroke.Thickness = 2
    guiStroke.Parent = chatLogGui
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0, 115, 0, 25)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Chat Logger"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.SourceSans
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Position = UDim2.new(0, 5, 0, 0)
    titleLabel.Parent = chatLogGui
    
    -- Log Toggle Button
    local logToggle = Instance.new("TextButton")
    logToggle.Name = "LogToggle"
    logToggle.Size = UDim2.new(0, 90, 0, 24)
    logToggle.Position = UDim2.new(0.293, 0, 0, 0)
    logToggle.BackgroundTransparency = 1
    logToggle.Text = "Log Chat [ON]"
    logToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    logToggle.TextSize = 14
    logToggle.Font = Enum.Font.SourceSans
    logToggle.Parent = chatLogGui
    
    -- Minimize Button
    local miniBtn = Instance.new("TextButton")
    miniBtn.Name = "Minimize"
    miniBtn.Size = UDim2.new(0, 69, 0, 24)
    miniBtn.Position = UDim2.new(0.648, 0, 0, 0)
    miniBtn.BackgroundTransparency = 1
    miniBtn.Text = "Minimize"
    miniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    miniBtn.TextSize = 14
    miniBtn.Font = Enum.Font.SourceSans
    miniBtn.Parent = chatLogGui
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 69, 0, 24)
    closeBtn.Position = UDim2.new(0.824, 0, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "Close"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.SourceSans
    closeBtn.Parent = chatLogGui
    
    -- Log Panel (ScrollingFrame)
    local logPanel = Instance.new("ScrollingFrame")
    logPanel.Name = "LogPanel"
    logPanel.Size = UDim2.new(0, 392, 0, 0)
    logPanel.Position = UDim2.new(0, 0, 0.969, 0)
    logPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    logPanel.BorderColor3 = Color3.fromRGB(57, 57, 57)
    logPanel.ScrollBarThickness = 5
    logPanel.CanvasSize = UDim2.new(2, 0, 100, 0)
    logPanel.Parent = chatLogGui
    
    local logCorner = Instance.new("UICorner")
    logCorner.CornerRadius = UDim.new(0, 8)
    logCorner.Parent = logPanel
    
    -- Chat logging variables
    local logging = true
    local minimized = false
    local prevOutputPos = 0
    
    -- Output function
    local function output(plr, msg)
        if not logging then return end
        
        local colour = Color3.fromRGB(255, 255, 255) -- Default gray/white
        
        -- Check for command prefix or special commands
        if string.sub(msg, 1, 1) == ":" or string.sub(msg, 1, 1) == ";" or string.sub(msg, 1, 1) == "√" then
            colour = Color3.fromRGB(255, 0, 0) -- Red for commands
        elseif string.sub(msg, 1, 2) == "/w" or string.sub(msg, 1, 8) == "/whisper" or string.sub(msg, 1, 5) == "/team" or string.sub(msg, 1, 2) == "/t" then
            colour = Color3.fromRGB(0, 0, 255) -- Blue for whispers/team chat
        end
        
        local o = Instance.new("TextLabel", logPanel)
        o.Text = plr.Name .. ": " .. msg
        o.Size = UDim2.new(0.5, 0, 0.006, 0)
        o.Position = UDim2.new(0, 0, 0.007 + prevOutputPos, 0)
        o.Font = Enum.Font.SourceSansSemibold
        o.TextColor3 = colour
        o.TextStrokeTransparency = 0
        o.BackgroundTransparency = 0
        o.BackgroundColor3 = Color3.new(0, 0, 0)
        o.BorderSizePixel = 0
        o.BorderColor3 = Color3.new(0, 0, 0)
        o.TextSize = 14
        o.TextXAlignment = Enum.TextXAlignment.Left
        o.ClipsDescendants = true
        
        prevOutputPos = prevOutputPos + 0.007
    end
    
    -- Connect to all current players
    for _, v in pairs(Players:GetPlayers()) do
        v.Chatted:Connect(function(msg)
            output(v, msg)
        end)
    end
    
    -- Connect to new players
    Players.PlayerAdded:Connect(function(plr)
        plr.Chatted:Connect(function(msg)
            output(plr, msg)
        end)
    end)
    
    -- Log Toggle functionality
    logToggle.MouseButton1Down:Connect(function()
        logging = not logging
        logToggle.Text = logging and "Log Chat [ON]" or "Log Chat [OFF]"
    end)
    
    -- Minimize functionality
    miniBtn.MouseButton1Down:Connect(function()
        if minimized then
            logPanel:TweenSize(UDim2.new(0, 392, 0, 203), "InOut", "Sine", 0.5, false, nil)
        else
            logPanel:TweenSize(UDim2.new(0, 392, 0, 0), "InOut", "Sine", 0.5, false, nil)
        end
        minimized = not minimized
    end)
    
    -- Close functionality
    closeBtn.MouseButton1Down:Connect(function()
        -- Fade out animation
        for _, child in pairs(chatLogGui:GetChildren()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            elseif child:IsA("ScrollingFrame") then
                TweenService:Create(child, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            end
        end
        
        TweenService:Create(guiStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        
        task.wait(0.3)
        
        -- Resize animation
        local shrinkTween = TweenService:Create(chatLogGui, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0, 10, 1, -25)
        })
        shrinkTween:Play()
        shrinkTween.Completed:Connect(function()
            chatLogGui:Destroy()
            chatLogGui = nil
            chatLogButton:Destroy()
            chatLogButton = nil
        end)
    end)
    
    -- Button click to open/close GUI
    local isOpen = false
    chatLogButton.MouseButton1Click:Connect(function()
        if isOpen then
            -- Close animation
            for _, child in pairs(chatLogGui:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
                elseif child:IsA("ScrollingFrame") then
                    TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                end
            end
            
            task.wait(0.2)
            
            chatLogGui:TweenSize(UDim2.new(0, 100, 0, 30), "InOut", "Sine", 0.4, false, function()
                chatLogGui.Visible = false
            end)
        else
            -- Open animation
            chatLogGui.Visible = true
            chatLogGui:TweenSize(UDim2.new(0, 392, 0, 25), "InOut", "Sine", 0.4, false, function()
                -- Fade in elements
                for _, child in pairs(chatLogGui:GetChildren()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        child.TextTransparency = 1
                        TweenService:Create(child, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
                    elseif child:IsA("ScrollingFrame") then
                        child.BackgroundTransparency = 1
                        TweenService:Create(child, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
                    end
                end
            end)
        end
        isOpen = not isOpen
    end)
end

function createNotification(message, isSuccess)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 250, 0, 60)
    NotifFrame.Position = UDim2.new(1, -260, 1, -70)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = ScreenGui
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 10)
    NotifCorner.Parent = NotifFrame
    
    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = isSuccess and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(255, 50, 50)
    NotifStroke.Thickness = 2
    NotifStroke.Parent = NotifFrame
    
    local NotifLabel = Instance.new("TextLabel")
    NotifLabel.Size = UDim2.new(1, -20, 1, -20)
    NotifLabel.Position = UDim2.new(0, 10, 0, 10)
    NotifLabel.BackgroundTransparency = 1
    NotifLabel.Text = message
    NotifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifLabel.TextSize = 14
    NotifLabel.Font = Enum.Font.Gotham
    NotifLabel.TextWrapped = true
    NotifLabel.TextXAlignment = Enum.TextXAlignment.Left
    NotifLabel.TextYAlignment = Enum.TextYAlignment.Top
    NotifLabel.Parent = NotifFrame
    
    -- Slide in animation
    NotifFrame.Position = UDim2.new(1, 10, 1, -70)
    local slideIn = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -260, 1, -70)
    })
    slideIn:Play()
    
    -- Wait and slide out
    task.wait(3)
    local slideOut = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(1, 10, 1, -70)
    })
    slideOut:Play()
    slideOut.Completed:Connect(function()
        NotifFrame:Destroy()
    end)
end

function createCommandButton(commandData, index)
    local CommandFrame = Instance.new("Frame")
    CommandFrame.Name = "Command_" .. index
    CommandFrame.Size = UDim2.new(1, -10, 0, 80)
    CommandFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    CommandFrame.BorderSizePixel = 0
    CommandFrame.Parent = ScrollFrame
    
    local CmdCorner = Instance.new("UICorner")
    CmdCorner.CornerRadius = UDim.new(0, 8)
    CmdCorner.Parent = CommandFrame
    
    local CmdStroke = Instance.new("UIStroke")
    CmdStroke.Color = Color3.fromRGB(0, 100, 255)
    CmdStroke.Thickness = 1
    CmdStroke.Transparency = 0.5
    CmdStroke.Parent = CommandFrame
    
    local CommandName = Instance.new("TextLabel")
    CommandName.Name = "CommandName"
    CommandName.Size = UDim2.new(1, -70, 0, 20)
    CommandName.Position = UDim2.new(0, 10, 0, 5)
    CommandName.BackgroundTransparency = 1
    CommandName.Text = commandData.name
    CommandName.TextColor3 = Color3.fromRGB(0, 150, 255)
    CommandName.TextSize = 15
    CommandName.Font = Enum.Font.GothamBold
    CommandName.TextXAlignment = Enum.TextXAlignment.Left
    CommandName.Parent = CommandFrame
    
    -- Add aliases display
    local AliasLabel = Instance.new("TextLabel")
    AliasLabel.Name = "AliasLabel"
    AliasLabel.Size = UDim2.new(1, -70, 0, 15)
    AliasLabel.Position = UDim2.new(0, 10, 0, 23)
    AliasLabel.BackgroundTransparency = 1
    AliasLabel.Text = commandData.aliases or ""
    AliasLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    AliasLabel.TextSize = 11
    AliasLabel.Font = Enum.Font.Gotham
    AliasLabel.TextXAlignment = Enum.TextXAlignment.Left
    AliasLabel.Parent = CommandFrame
    
    local CommandDesc = Instance.new("TextLabel")
    CommandDesc.Name = "CommandDesc"
    CommandDesc.Size = UDim2.new(1, -70, 0, 35)
    CommandDesc.Position = UDim2.new(0, 10, 0, 40)
    CommandDesc.BackgroundTransparency = 1
    CommandDesc.Text = commandData.description
    CommandDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
    CommandDesc.TextSize = 12
    CommandDesc.Font = Enum.Font.Gotham
    CommandDesc.TextXAlignment = Enum.TextXAlignment.Left
    CommandDesc.TextYAlignment = Enum.TextYAlignment.Top
    CommandDesc.TextWrapped = true
    CommandDesc.Parent = CommandFrame
    
    local ExecuteButton = Instance.new("TextButton")
    ExecuteButton.Name = "ExecuteButton"
    ExecuteButton.Size = UDim2.new(0, 50, 0, 30)
    ExecuteButton.Position = UDim2.new(1, -55, 0.5, -15)
    ExecuteButton.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
    ExecuteButton.BorderSizePixel = 0
    ExecuteButton.Text = "RUN"
    ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExecuteButton.TextSize = 12
    ExecuteButton.Font = Enum.Font.GothamBold
    ExecuteButton.Parent = CommandFrame
    
    local ExecCorner = Instance.new("UICorner")
    ExecCorner.CornerRadius = UDim.new(0, 6)
    ExecCorner.Parent = ExecuteButton
    
    -- Execute command on button click
    ExecuteButton.MouseButton1Click:Connect(function()
        executeCommand(commandData)
    end)
    
    -- Hover effects
    ExecuteButton.MouseEnter:Connect(function()
        local tween = TweenService:Create(ExecuteButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        })
        tween:Play()
    end)
    
    ExecuteButton.MouseLeave:Connect(function()
        local tween = TweenService:Create(ExecuteButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 80, 200)
        })
        tween:Play()
    end)
    
    CommandFrame.MouseEnter:Connect(function()
        local tween = TweenService:Create(CmdStroke, TweenInfo.new(0.2), {
            Transparency = 0
        })
        tween:Play()
    end)
    
    CommandFrame.MouseLeave:Connect(function()
        local tween = TweenService:Create(CmdStroke, TweenInfo.new(0.2), {
            Transparency = 0.5
        })
        tween:Play()
    end)
    
    return CommandFrame
end

function executeCommand(commandData)
    local value = ValueInput.Text
    
    if commandData.requiresValue and (not value or value == "") then
        createNotification("Error: This command requires a value!", false)
        return
    end
    
    -- Save last executed command (except PreviousCommand itself)
    if commandData.name ~= "√PreviousCommand" then
        lastExecutedCommand = commandData.func
        lastExecutedValue = value
    end
    
    local success, message = commandData.func(value)
    createNotification(message, success)
    
    if success then
        ValueInput.Text = ""
    end
end

function populateCommands(filterText)
    -- Clear existing commands
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local count = 0
    filterText = filterText and filterText:lower() or ""
    
    for index, commandData in ipairs(Commands) do
        local shouldShow = true
        
        if filterText ~= "" then
            local commandNameLower = commandData.name:lower()
            local commandDescLower = commandData.description:lower()
            local aliasesLower = (commandData.aliases or ""):lower()
            
            if not (commandNameLower:find(filterText, 1, true) or 
                    commandDescLower:find(filterText, 1, true) or
                    aliasesLower:find(filterText, 1, true)) then
                shouldShow = false
            end
        end
        
        if shouldShow then
            createCommandButton(commandData, index)
            count = count + 1
        end
    end
    
    -- Update canvas size (increased from 65 to 85 for taller frames with aliases)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * 85 + 10)
end

function parseCommand(text)
    if not text:sub(1, #commandPrefix) == commandPrefix then
        return nil, nil
    end
    
    local parts = {}
    for part in text:gmatch("%S+") do
        table.insert(parts, part)
    end
    
    if #parts == 0 then return nil, nil end
    
    local commandName = parts[1]
    local value = table.concat(parts, " ", 2)
    
    return commandName, value
end

function executeFromSearch(text)
    local commandName, value = parseCommand(text)
    
    if not commandName then return end
    
    for _, commandData in ipairs(Commands) do
        if commandData.name:lower() == commandName:lower() then
            if commandData.requiresValue and value and value ~= "" then
                local success, message = commandData.func(value)
                createNotification(message, success)
            elseif not commandData.requiresValue then
                local success, message = commandData.func()
                createNotification(message, success)
            else
                createNotification("Error: Command requires a value!", false)
            end
            return
        end
    end
    
    createNotification("Command not found!", false)
end

-- Animation Functions
local isOpen = false

function openGUI()
    if isOpen then return end
    isOpen = true
    
    ToggleButton.Visible = false
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 50, 0, 50)
    MainFrame.Position = UDim2.new(0.5, -25, 0, 10)
    
    -- Calculate target size (mobile optimized)
    local targetWidth = math.min(399, ScreenGui.AbsoluteSize.X - 20)
    local targetHeight = math.min(500, ScreenGui.AbsoluteSize.Y - 100)
    
    local expandTween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, targetWidth, 0, targetHeight),
        Position = UDim2.new(0.5, -targetWidth/2, 0.5, -targetHeight/2)
    })
    
    expandTween:Play()
    
    expandTween.Completed:Connect(function()
        -- Fade in elements
        for _, element in ipairs({TitleBar, SearchBar, ValueInput, ScrollFrame}) do
            element.BackgroundTransparency = 1
            local transparency = element == TitleBar and 0 or 0
            
            if element:FindFirstChild("TitleLabel") then
                element.TitleLabel.TextTransparency = 1
            end
            if element:FindFirstChild("CloseButton") then
                element.CloseButton.BackgroundTransparency = 1
                element.CloseButton.TextTransparency = 1
            end
            
            local fadeTween = TweenService:Create(element, TweenInfo.new(0.3), {
                BackgroundTransparency = transparency
            })
            fadeTween:Play()
            
            if element:FindFirstChild("TitleLabel") then
                TweenService:Create(element.TitleLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            end
            if element:FindFirstChild("CloseButton") then
                TweenService:Create(element.CloseButton, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
                TweenService:Create(element.CloseButton, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            end
        end
        
        -- Populate commands after fade in
        task.wait(0.2)
        populateCommands()
    end)
end

function closeGUI()
    if not isOpen then return end
    isOpen = false
    
    -- Fade out elements
    for _, element in ipairs({TitleBar, SearchBar, ValueInput, ScrollFrame}) do
        local fadeTween = TweenService:Create(element, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        })
        fadeTween:Play()
        
        if element:FindFirstChild("TitleLabel") then
            TweenService:Create(element.TitleLabel, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        end
        if element:FindFirstChild("CloseButton") then
            TweenService:Create(element.CloseButton, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(element.CloseButton, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        end
    end
    
    task.wait(0.2)
    
    -- Shrink back to button
    local shrinkTween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.5, -25, 0, 10)
    })
    
    shrinkTween:Play()
    
    shrinkTween.Completed:Connect(function()
        MainFrame.Visible = false
        ToggleButton.Visible = true
        SearchBar.Text = ""
        ValueInput.Text = ""
    end)
end

-- Button Connections
ToggleButton.MouseButton1Click:Connect(function()
    openGUI()
end)

CloseButton.MouseButton1Click:Connect(function()
    closeGUI()
end)

-- Search functionality
SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local text = SearchBar.Text
    
    -- Check if it's a command
    if text:sub(1, #commandPrefix) == commandPrefix then
        -- Don't filter, keep all commands visible
        populateCommands()
    else
        -- Filter commands based on search
        populateCommands(text)
    end
end)

SearchBar.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local text = SearchBar.Text
        
        -- Check if it's a command
        if text:sub(1, #commandPrefix) == commandPrefix then
            executeFromSearch(text)
            SearchBar.Text = ""
        end
    end
end)

-- Button hover effects
ToggleButton.MouseEnter:Connect(function()
    local tween = TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 55, 0, 55)
    })
    tween:Play()
    
    local glowTween = TweenService:Create(ButtonGlow, TweenInfo.new(0.2), {
        ImageTransparency = 0.3
    })
    glowTween:Play()
end)

ToggleButton.MouseLeave:Connect(function()
    local tween = TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 50, 0, 50)
    })
    tween:Play()
    
    local glowTween = TweenService:Create(ButtonGlow, TweenInfo.new(0.2), {
        ImageTransparency = 0.5
    })
    glowTween:Play()
end)

-- Pulsing glow animation for button
spawn(function()
    while true do
        local pulse1 = TweenService:Create(ButtonGlow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Size = UDim2.new(1.7, 0, 1.7, 0),
            ImageTransparency = 0.7
        })
        pulse1:Play()
        pulse1.Completed:Wait()
        
        local pulse2 = TweenService:Create(ButtonGlow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Size = UDim2.new(1.5, 0, 1.5, 0),
            ImageTransparency = 0.5
        })
        pulse2:Play()
        pulse2.Completed:Wait()
    end
end)

-- Chat command detection (Legacy Chat)
local function onPlayerChatted(message)
    if message:sub(1, #commandPrefix) == commandPrefix then
        executeFromSearch(message)
    end
end

LocalPlayer.Chatted:Connect(onPlayerChatted)

-- TextChatService support (New Chat)
local success, textChatService = pcall(function()
    return game:GetService("TextChatService")
end)

if success and textChatService then
    local chatInputBarConfiguration = textChatService:FindFirstChild("ChatInputBarConfiguration")
    if chatInputBarConfiguration then
        local chatBar = chatInputBarConfiguration:FindFirstChild("TargetTextChannel")
        if chatBar then
            chatBar.MessageReceived:Connect(function(message)
                if message.TextSource and message.TextSource.UserId == LocalPlayer.UserId then
                    local text = message.Text
                    if text:sub(1, #commandPrefix) == commandPrefix then
                        executeFromSearch(text)
                    end
                end
            end)
        end
    end
    
    -- Alternative method for new chat
    local channels = textChatService:FindFirstChild("TextChannels")
    if channels then
        local rbxGeneral = channels:FindFirstChild("RBXGeneral")
        if rbxGeneral then
            rbxGeneral.MessageReceived:Connect(function(message)
                if message.TextSource and message.TextSource.UserId == LocalPlayer.UserId then
                    local text = message.Text
                    if text:sub(1, #commandPrefix) == commandPrefix then
                        executeFromSearch(text)
                    end
                end
            end)
        end
    end
end

-- Cleanup on character respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    -- Re-enable noclip if it was enabled
    if noclipEnabled then
        task.wait(0.5)
        enableNoclip()
    end
    
    -- Re-enable fly if it was enabled
    if flyEnabled then
        local savedSpeed = flySpeed
        disableFly()
        task.wait(0.5)
        enableFly(savedSpeed)
    end
    
    -- Re-enable invisibility if it was enabled
    if invisibilityEnabled then
        disableInvisibility()
        task.wait(0.5)
        enableInvisibility()
    end
end)

-- Handle mobile keyboard
if UserInputService.TouchEnabled then
    SearchBar.Focused:Connect(function()
        -- Adjust GUI position when keyboard appears on mobile
        local keyboardHeight = 200
        if MainFrame.Visible then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Position = UDim2.new(0.5, -MainFrame.AbsoluteSize.X/2, 0, 10)
            }):Play()
        end
    end)
    
    SearchBar.FocusLost:Connect(function()
        -- Reset position
        if MainFrame.Visible then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Position = UDim2.new(0.5, -MainFrame.AbsoluteSize.X/2, 0.5, -MainFrame.AbsoluteSize.Y/2)
            }):Play()
        end
    end)
    
    ValueInput.Focused:Connect(function()
        local keyboardHeight = 200
        if MainFrame.Visible then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Position = UDim2.new(0.5, -MainFrame.AbsoluteSize.X/2, 0, 10)
            }):Play()
        end
    end)
    
    ValueInput.FocusLost:Connect(function()
        if MainFrame.Visible then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Position = UDim2.new(0.5, -MainFrame.AbsoluteSize.X/2, 0.5, -MainFrame.AbsoluteSize.Y/2)
            }):Play()
        end
    end)
end

-- Dynamic resizing for different screen sizes
local function updateGUISize()
    if isOpen then
        local targetWidth = math.min(399, ScreenGui.AbsoluteSize.X - 20)
        local targetHeight = math.min(500, ScreenGui.AbsoluteSize.Y - 100)
        
        MainFrame.Size = UDim2.new(0, targetWidth, 0, targetHeight)
        MainFrame.Position = UDim2.new(0.5, -targetWidth/2, 0.5, -targetHeight/2)
    end
end

ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGUISize)

-- Additional command parsing for value input
ValueInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and ValueInput.Text ~= "" then
        -- Auto-detect last searched command or first visible command
        local lastCommand = nil
        
        for _, child in ipairs(ScrollFrame:GetChildren()) do
            if child:IsA("Frame") and child.Visible then
                lastCommand = child
                break
            end
        end
        
        if lastCommand then
            local commandName = lastCommand:FindFirstChild("CommandName")
            if commandName then
                for _, commandData in ipairs(Commands) do
                    if commandData.name == commandName.Text then
                        executeCommand(commandData)
                        break
                    end
                end
            end
        end
    end
end)

-- Smart command suggestions as you type
SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local text = SearchBar.Text
    
    if text:sub(1, #commandPrefix) == commandPrefix then
        -- Extract command and value
        local parts = {}
        for part in text:gmatch("%S+") do
            table.insert(parts, part)
        end
        
        if #parts > 1 then
            -- Auto-fill value input
            local value = table.concat(parts, " ", 2)
            ValueInput.Text = value
        end
    end
end)

-- Add reset command functionality for mobile
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle GUI with specific key (for desktop users)
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.RightShift then
        if isOpen then
            closeGUI()
        else
            openGUI()
        end
    end
end)

-- Touch gesture for opening GUI (swipe from top)
if UserInputService.TouchEnabled then
    local touchStart = nil
    local swipeThreshold = 100
    
    UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
        if gameProcessed then return end
        touchStart = touch.Position
    end)
    
    UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
        if gameProcessed or not touchStart then return end
        
        local swipeDistance = touch.Position.Y - touchStart.Y
        
        if touchStart.Y < 50 and swipeDistance > swipeThreshold and not isOpen then
            openGUI()
        end
        
        touchStart = nil
    end)
end

-- Command history system
local commandHistory = {}
local historyIndex = 0
local maxHistory = 20

local function addToHistory(command)
    table.insert(commandHistory, 1, command)
    if #commandHistory > maxHistory then
        table.remove(commandHistory, #commandHistory)
    end
    historyIndex = 0
end

-- History navigation with up/down arrows
SearchBar.Focused:Connect(function()
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not SearchBar:IsFocused() then
            connection:Disconnect()
            return
        end
        
        if input.KeyCode == Enum.KeyCode.Up then
            historyIndex = math.min(historyIndex + 1, #commandHistory)
            if commandHistory[historyIndex] then
                SearchBar.Text = commandHistory[historyIndex]
            end
        elseif input.KeyCode == Enum.KeyCode.Down then
            historyIndex = math.max(historyIndex - 1, 0)
            if historyIndex == 0 then
                SearchBar.Text = ""
            elseif commandHistory[historyIndex] then
                SearchBar.Text = commandHistory[historyIndex]
            end
        end
    end)
end)

-- Enhanced executeFromSearch with history
local originalExecuteFromSearch = executeFromSearch
executeFromSearch = function(text)
    addToHistory(text)
    originalExecuteFromSearch(text)
end

-- Status indicator
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -20, 0, 15)
StatusLabel.Position = UDim2.new(0, 10, 1, -20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Ready"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local function updateStatus(text, color)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color or Color3.fromRGB(0, 255, 100)
end

-- Monitor noclip status
spawn(function()
    while true do
        if isOpen then
            local espPartCount = #espPartObjects / 2 -- Divide by 2 because we have highlights + billboards
            
            if invisibilityEnabled then
                updateStatus("Status: Invisible Mode Active", Color3.fromRGB(150, 150, 150))
            elseif #espPartObjects > 0 then
                updateStatus("Status: Part ESP Active (" .. math.floor(espPartCount) .. " objects)", Color3.fromRGB(255, 0, 255))
            elseif espEnabled then
                local playerCount = 0
                for _ in pairs(espObjects) do
                    playerCount = playerCount + 1
                end
                updateStatus("Status: Player ESP Active (" .. playerCount .. " players)", Color3.fromRGB(255, 0, 255))
            elseif flyEnabled then
                updateStatus("Status: Flying (Speed " .. flySpeed .. ")", Color3.fromRGB(0, 200, 255))
            elseif noclipEnabled then
                updateStatus("Status: Noclip Active", Color3.fromRGB(255, 200, 0))
            else
                updateStatus("Status: Ready", Color3.fromRGB(0, 255, 100))
            end
        end
        task.wait(0.5)
    end
end)

-- Add command aliases
local commandAliases = {
    ["√ws"] = "√Speed",
    ["√walkspeed"] = "√Speed",
    ["√jp"] = "√JumpPower",
    ["√jump"] = "√JumpPower",
    ["√tp"] = "√Goto",
    ["√teleport"] = "√Goto",
    ["√clip"] = "√Noclip",
    ["√unclip"] = "√Unnoclip",
    ["√flight"] = "√Fly",
    ["√unflight"] = "√Unfly",
    ["√prev"] = "√PreviousCommand",
    ["√last"] = "√PreviousCommand",
    ["√again"] = "√PreviousCommand",
    ["√wallhack"] = "√ESP",
    ["√unesp"] = "√UnESP",
    ["√unwallhack"] = "√UnESP",
    ["√hsit"] = "√Headsit",
    ["√headt"] = "√Headsit",
    ["√hs"] = "√Headsit",
    ["√infyield"] = "√InfiniteYield",
    ["√infiniteyield"] = "√InfiniteYield",
    ["√iy"] = "√InfiniteYield",
    ["√IY"] = "√InfiniteYield",
    ["√esppart"] = "√ESPPart",
    ["√EspP"] = "√ESPPart",
    ["√EPart"] = "√ESPPart",
    ["√unespp"] = "√UnESPPart",
    ["√UEP"] = "√UnESPPart",
    ["√Unsp"] = "√UnESPPart",
    ["√unesppart"] = "√UnESPPart",
    ["√UEAP"] = "√UnESPAllPart",
    ["√unespallpart"] = "√UnESPAllPart",
    ["√Unespap"] = "√UnESPAllPart",
    ["√invisible"] = "√Invisible",
    ["√Invis"] = "√Invisible",
    ["√uninvisible"] = "√UnInvisible",
    ["√Visible"] = "√UnInvisible",
    ["√Vis"] = "√UnInvisible",
    ["√requirescripts"] = "√RequireScripts",
    ["√RS"] = "√RequireScripts",
    ["√backdoor"] = "√RequireScripts",
    ["√ReqScript"] = "√RequireScripts",
    ["√chatlog"] = "√ChatLog",
    ["√ChatLogger"] = "√ChatLog",
    ["√ChatLg"] = "√ChatLog"
}

local function resolveAlias(commandName)
    return commandAliases[commandName:lower()] or commandName
end

-- Update executeFromSearch to handle aliases
local oldExecute = executeFromSearch
executeFromSearch = function(text)
    local commandName, value = parseCommand(text)
    
    if commandName then
        commandName = resolveAlias(commandName)
        if value and value ~= "" then
            text = commandName .. " " .. value
        else
            text = commandName
        end
    end
    
    oldExecute(text)
end

-- Draggable GUI (for when opened)
local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    local newPos = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
    
    TweenService:Create(MainFrame, TweenInfo.new(0.1), {Position = newPos}):Play()
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)

-- Performance optimization: Only update visible commands
ScrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    local canvasPos = ScrollFrame.CanvasPosition.Y
    local frameHeight = ScrollFrame.AbsoluteSize.Y
    
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            local childPos = child.AbsolutePosition.Y - ScrollFrame.AbsolutePosition.Y
            local isVisible = childPos + child.AbsoluteSize.Y > canvasPos and childPos < canvasPos + frameHeight + 100
            
            -- Optimize rendering
            if isVisible and child.BackgroundTransparency == 1 then
                child.BackgroundTransparency = 0
            elseif not isVisible and child.BackgroundTransparency == 0 then
                child.BackgroundTransparency = 1
            end
        end
    end
end)

-- Anti-AFK (keeps player active)
local antiAFK = true
spawn(function()
    while antiAFK do
        for i = 1, 60 do
            task.wait(1)
        end
        
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Additional utility commands that can be added later
local utilityFunctions = {
    resetCharacter = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
            return true, "Character reset"
        end
        return false, "No character found"
    end,
    
    clearNotifications = function()
        for _, child in ipairs(ScreenGui:GetChildren()) do
            if child.Name == "Frame" and child ~= MainFrame then
                child:Destroy()
            end
        end
        return true, "Notifications cleared"
    end
}

-- Version display
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "VersionLabel"
VersionLabel.Size = UDim2.new(0, 100, 0, 15)
VersionLabel.Position = UDim2.new(1, -110, 1, -20)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v1.0 Alpha"
VersionLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
VersionLabel.TextSize = 10
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
VersionLabel.Parent = MainFrame

-- Initialize with first notification
task.wait(1)
createNotification("Encryption Admin loaded! Press [A] or swipe down to open.", true)

-- Auto-save preferences (mock implementation for future expansion)
local preferences = {
    theme = "blue",
    autoNoclip = false,
    defaultSpeed = 16,
    defaultJumpPower = 50
}

local function savePreferences()
    -- In a real implementation, this would save to DataStore
    -- For exploits, this might use writefile/readfile
end

local function loadPreferences()
    -- Load saved preferences
end

-- Command suggestions dropdown (future enhancement placeholder)
local suggestions = {}

local function showSuggestions(query)
    -- This would show a dropdown of matching commands
end

-- Final initialization
print("[Encryption Admin] Initialized successfully")
print("[Encryption Admin] Commands loaded: " .. #Commands)
print("[Encryption Admin] Ready for use")
print("[Encryption Admin] Use " .. commandPrefix .. " prefix for commands")

-- Heartbeat optimization for smooth animations
RunService.Heartbeat:Connect(function()
    if isOpen and MainFrame.Visible then
        -- Smooth scroll animation
        local target = ScrollFrame.CanvasPosition
        local current = ScrollFrame.CanvasPosition
        
        if (target - current).Magnitude > 1 then
            ScrollFrame.CanvasPosition = current:Lerp(target, 0.3)
        end
    end
end)

-- Memory cleanup on destroy
ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui.Parent then
        disableNoclip()
        disableFly()
        disableESP()
        disableESPPart()
        disableInvisibility()
        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end
end)

print("[Encryption Admin] All systems operational")
