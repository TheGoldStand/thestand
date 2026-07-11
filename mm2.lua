--[[
    MM2 FULL MENU v12 (Fling, TeleportAlways push, AutoFarm Fast/Slow, Radio, No AutoShoot)
    - Real Fling: телепорт к цели + отбрасывание
    - Teleport Always + отбрасывание цели
    - AutoFarm: выбор Fast (телепорт) / Slow (ходьба)
    - Take Gun: подбор пистолета с земли
    - Radio: отдельное окно с вводом ID и плеером
    - AutoShoot убран полностью
    - Окно выбора цели отдельное, перетаскиваемое
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Глобальные переменные
_G.AutoFarm = false
_G.AutoFarmDelay = 2
_G.AutoFarmMode = "Fast"          -- "Fast" или "Slow"
_G.Fly = false
_G.Noclip = false
_G.Fling = false
_G.ESPEnabled = false
_G.SelectedTarget = nil
_G.WalkSpeed = 16
_G.JumpPower = 50
_G.ESPRefresh = false
_G.TeleportAlways = false
_G.KillAllActive = false

-- ==================== GUI ====================
local gui = Instance.new("ScreenGui")
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 450)
mainFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Parent = gui

-- Мерцающая обводка
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Thickness = 2
stroke.LineJoinMode = Enum.LineJoinMode.Round
task.spawn(function()
    while true do
        for _, color in ipairs({
            Color3.fromRGB(255, 200, 0),
            Color3.fromRGB(255, 230, 50),
            Color3.fromRGB(255, 170, 0),
            Color3.fromRGB(255, 215, 0)
        }) do
            stroke.Color = color
            task.wait(0.4)
        end
    end
end)

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 14)

-- Жёлтый заголовок
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
header.BorderSizePixel = 0
header.Parent = mainFrame
local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 14)
local headerGradient = Instance.new("UIGradient", header)
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 0))
})
headerGradient.Rotation = 90

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "🔪 MM2 Script / BY TheG0ldStand"
title.TextColor3 = Color3.fromRGB(180, 0, 0)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextStrokeTransparency = 0.5
title.TextStrokeColor3 = Color3.fromRGB(100, 0, 0)

local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0, 36, 0, 36)
minimizeBtn.Position = UDim2.new(1, -36, 0, 0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(180, 0, 0)
minimizeBtn.TextSize = 22
minimizeBtn.Font = Enum.Font.GothamBold

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 90, 0, 40)
openBtn.Position = UDim2.new(0.5, -45, 0.2, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
openBtn.Text = "OPEN"
openBtn.TextColor3 = Color3.fromRGB(180, 0, 0)
openBtn.TextSize = 16
openBtn.Font = Enum.Font.GothamBold
openBtn.Visible = false
openBtn.Active = true
openBtn.Parent = gui
local openCorner = Instance.new("UICorner", openBtn)
openCorner.CornerRadius = UDim.new(0, 10)

-- Перетаскивание
local function makeDraggable(dragArea, moveTarget)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveTarget.Position
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            moveTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(header, mainFrame)
makeDraggable(openBtn, openBtn)

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openBtn.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset + 105, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset)
    openBtn.Visible = true
end)

local clickStartPos
openBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        clickStartPos = input.Position
    end
end)
openBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if clickStartPos and (input.Position - clickStartPos).Magnitude < 10 then
            openBtn.Visible = false
            mainFrame.Position = UDim2.new(openBtn.Position.X.Scale, openBtn.Position.X.Offset - 105, openBtn.Position.Y.Scale, openBtn.Position.Y.Offset)
            mainFrame.Visible = true
        end
    end
end)

-- ScrollingFrame
local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
scrollFrame.Size = UDim2.new(1, 0, 1, -36)
scrollFrame.Position = UDim2.new(0, 0, 0, 36)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
scrollFrame.ScrollBarImageTransparency = 0.7
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local scrollContent = Instance.new("Frame", scrollFrame)
scrollContent.Size = UDim2.new(1, 0, 0, 0)
scrollContent.BackgroundTransparency = 1

-- ===== Элементы интерфейса =====
local function createToggle(parent, yPos, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 32)
    btn.Position = UDim2.new(0, 12, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = text .. "  OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    local btnGradient = Instance.new("UIGradient", btn)
    btnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 45))
    })
    btnGradient.Rotation = 90
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.Text = text .. "  ON"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 80)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 140, 60))
            })
        else
            btn.Text = text .. "  OFF"
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btnGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 55)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 45))
            })
        end
        callback(state)
    end)
    btn.Parent = parent
    return btn
end

local function createButton(parent, yPos, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 32)
    btn.Position = UDim2.new(0, 12, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(60, 90, 230)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    local btnGradient = Instance.new("UIGradient", btn)
    btnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 100, 240)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 70, 200))
    })
    btnGradient.Rotation = 90
    btn.MouseButton1Click:Connect(callback)
    btn.Parent = parent
    return btn
end

local function createInputControl(parent, yPos, name, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -24, 0, 32)
    holder.Position = UDim2.new(0, 12, 0, yPos)
    holder.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    holder.BorderSizePixel = 0
    local hC = Instance.new("UICorner", holder)
    hC.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", holder)
    label.Size = UDim2.new(0, 110, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local input = Instance.new("TextBox", holder)
    input.Size = UDim2.new(0, 65, 1, -8)
    input.Position = UDim2.new(1, -75, 0, 4)
    input.Text = tostring(default)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 13
    input.BorderSizePixel = 0
    local inputC = Instance.new("UICorner", input)
    inputC.CornerRadius = UDim.new(0, 6)

    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then
            callback(val)
        else
            input.Text = tostring(default)
        end
    end)
    holder.Parent = parent
    callback(default)
    return holder
end

-- ==================== Окно выбора цели ====================
local targetWindow = Instance.new("Frame")
targetWindow.Size = UDim2.new(0, 220, 0, 250)
targetWindow.Position = UDim2.new(0.5, -110, 0.3, 0)
targetWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
targetWindow.BorderSizePixel = 0
targetWindow.Visible = false
targetWindow.Active = true
targetWindow.Parent = gui
local tCorner = Instance.new("UICorner", targetWindow)
tCorner.CornerRadius = UDim.new(0, 10)
local tStroke = Instance.new("UIStroke", targetWindow)
tStroke.Color = Color3.fromRGB(255, 200, 0)
tStroke.Thickness = 2

local targetHeader = Instance.new("Frame", targetWindow)
targetHeader.Size = UDim2.new(1, 0, 0, 30)
targetHeader.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
local thCorner = Instance.new("UICorner", targetHeader)
thCorner.CornerRadius = UDim.new(0, 10)
local thGradient = Instance.new("UIGradient", targetHeader)
thGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 0))
})
thGradient.Rotation = 90

local thTitle = Instance.new("TextLabel", targetHeader)
thTitle.Size = UDim2.new(1, -30, 1, 0)
thTitle.Position = UDim2.new(0, 10, 0, 0)
thTitle.Text = "Select Target"
thTitle.TextColor3 = Color3.fromRGB(180, 0, 0)
thTitle.Font = Enum.Font.GothamBold
thTitle.TextSize = 14
thTitle.BackgroundTransparency = 1
thTitle.TextXAlignment = Enum.TextXAlignment.Left

local closeTargetBtn = Instance.new("TextButton", targetHeader)
closeTargetBtn.Size = UDim2.new(0, 30, 1, 0)
closeTargetBtn.Position = UDim2.new(1, -30, 0, 0)
closeTargetBtn.BackgroundTransparency = 1
closeTargetBtn.Text = "✕"
closeTargetBtn.TextColor3 = Color3.fromRGB(180, 0, 0)
closeTargetBtn.Font = Enum.Font.GothamBold
closeTargetBtn.TextSize = 16
closeTargetBtn.MouseButton1Click:Connect(function()
    targetWindow.Visible = false
end)

makeDraggable(targetHeader, targetWindow)

local tScroll = Instance.new("ScrollingFrame", targetWindow)
tScroll.Size = UDim2.new(1, 0, 1, -30)
tScroll.Position = UDim2.new(0, 0, 0, 30)
tScroll.BackgroundTransparency = 1
tScroll.ScrollBarThickness = 4
tScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
tScroll.ScrollBarImageTransparency = 0.8
tScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local tContent = Instance.new("Frame", tScroll)
tContent.Size = UDim2.new(1, 0, 0, 0)
tContent.BackgroundTransparency = 1

local function refreshTargetList()
    for _, child in ipairs(tContent:GetChildren()) do child:Destroy() end
    local players = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(players, p) end
    end
    local yPos = 0
    for _, plr in ipairs(players) do
        local entry = Instance.new("TextButton")
        entry.Size = UDim2.new(1, -8, 0, 36)
        entry.Position = UDim2.new(0, 4, 0, yPos)
        entry.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        entry.BorderSizePixel = 0
        entry.AutoButtonColor = false
        entry.Parent = tContent
        local eCorner = Instance.new("UICorner", entry)
        eCorner.CornerRadius = UDim.new(0, 6)

        local avatar = Instance.new("ImageLabel", entry)
        avatar.Size = UDim2.new(0, 28, 0, 28)
        avatar.Position = UDim2.new(0, 5, 0.5, -14)
        avatar.BackgroundTransparency = 1
        avatar.Image = ""
        local aCorner = Instance.new("UICorner", avatar)
        aCorner.CornerRadius = UDim.new(1, 0)

        local nameLabel = Instance.new("TextLabel", entry)
        nameLabel.Size = UDim2.new(1, -40, 1, 0)
        nameLabel.Position = UDim2.new(0, 40, 0, 0)
        nameLabel.Text = plr.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.GothamSemibold
        nameLabel.TextSize = 13
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left

        if _G.SelectedTarget == plr then
            entry.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        end

        entry.MouseButton1Click:Connect(function()
            _G.SelectedTarget = plr
            targetWindow.Visible = false
            if targetSelectBtn then
                targetSelectBtn.Text = "Target: " .. plr.Name
            end
        end)

        task.spawn(function()
            local userId = plr.UserId
            if userId <= 0 then return end
            local suc, thumbnail = pcall(function()
                return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if suc and thumbnail then
                avatar.Image = thumbnail
            end
        end)

        yPos = yPos + 40
    end
    tContent.Size = UDim2.new(1, 0, 0, yPos)
    tScroll.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if targetWindow.Visible then
            local pos = input.Position
            local absPos = targetWindow.AbsolutePosition
            local absSize = targetWindow.AbsoluteSize
            if pos.X < absPos.X or pos.X > absPos.X + absSize.X or pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
                local btnAbsPos = targetSelectBtn and targetSelectBtn.AbsolutePosition
                local btnAbsSize = targetSelectBtn and targetSelectBtn.AbsoluteSize
                if not (btnAbsPos and pos.X >= btnAbsPos.X and pos.X <= btnAbsPos.X + btnAbsSize.X and pos.Y >= btnAbsPos.Y and pos.Y <= btnAbsPos.Y + btnAbsSize.Y) then
                    targetWindow.Visible = false
                end
            end
        end
    end
end)

-- ==================== Окно Radio ====================
local radioWindow = Instance.new("Frame")
radioWindow.Size = UDim2.new(0, 250, 0, 120)
radioWindow.Position = UDim2.new(0.5, -125, 0.35, 0)
radioWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
radioWindow.BorderSizePixel = 0
radioWindow.Visible = false
radioWindow.Active = true
radioWindow.Parent = gui
local rCorner = Instance.new("UICorner", radioWindow)
rCorner.CornerRadius = UDim.new(0, 10)
local rStroke = Instance.new("UIStroke", radioWindow)
rStroke.Color = Color3.fromRGB(255, 200, 0)
rStroke.Thickness = 2

local radioHeader = Instance.new("Frame", radioWindow)
radioHeader.Size = UDim2.new(1, 0, 0, 30)
radioHeader.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
local rhCorner = Instance.new("UICorner", radioHeader)
rhCorner.CornerRadius = UDim.new(0, 10)
local rhGradient = Instance.new("UIGradient", radioHeader)
rhGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 0))
})
rhGradient.Rotation = 90

local rhTitle = Instance.new("TextLabel", radioHeader)
rhTitle.Size = UDim2.new(1, -30, 1, 0)
rhTitle.Position = UDim2.new(0, 10, 0, 0)
rhTitle.Text = "🎵 Radio"
rhTitle.TextColor3 = Color3.fromRGB(180, 0, 0)
rhTitle.Font = Enum.Font.GothamBold
rhTitle.TextSize = 14
rhTitle.BackgroundTransparency = 1
rhTitle.TextXAlignment = Enum.TextXAlignment.Left

local closeRadioBtn = Instance.new("TextButton", radioHeader)
closeRadioBtn.Size = UDim2.new(0, 30, 1, 0)
closeRadioBtn.Position = UDim2.new(1, -30, 0, 0)
closeRadioBtn.BackgroundTransparency = 1
closeRadioBtn.Text = "✕"
closeRadioBtn.TextColor3 = Color3.fromRGB(180, 0, 0)
closeRadioBtn.Font = Enum.Font.GothamBold
closeRadioBtn.TextSize = 16
closeRadioBtn.MouseButton1Click:Connect(function()
    radioWindow.Visible = false
end)

makeDraggable(radioHeader, radioWindow)

local radioInput = Instance.new("TextBox", radioWindow)
radioInput.Size = UDim2.new(0, 150, 0, 30)
radioInput.Position = UDim2.new(0, 10, 0, 40)
radioInput.Text = "1837897837"
radioInput.TextColor3 = Color3.fromRGB(255, 255, 255)
radioInput.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
radioInput.Font = Enum.Font.GothamBold
radioInput.TextSize = 13
radioInput.BorderSizePixel = 0
Instance.new("UICorner", radioInput).CornerRadius = UDim.new(0, 5)

local radioPlayBtn = Instance.new("TextButton", radioWindow)
radioPlayBtn.Size = UDim2.new(0, 70, 0, 30)
radioPlayBtn.Position = UDim2.new(0, 170, 0, 40)
radioPlayBtn.Text = "▶ Play"
radioPlayBtn.TextColor3 = Color3.new(1, 1, 1)
radioPlayBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
radioPlayBtn.Font = Enum.Font.GothamBold
radioPlayBtn.TextSize = 13
radioPlayBtn.BorderSizePixel = 0
Instance.new("UICorner", radioPlayBtn).CornerRadius = UDim.new(0, 5)

local currentRadioSound = nil
local radioPlayConnection

radioPlayBtn.MouseButton1Click:Connect(function()
    if radioPlayConnection then radioPlayConnection:Disconnect(); radioPlayConnection = nil end
    local id = tonumber(radioInput.Text)
    if not id then return end
    if currentRadioSound then
        currentRadioSound:Stop()
        currentRadioSound:Destroy()
        currentRadioSound = nil
    end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = 5
    sound.Parent = LocalPlayer.PlayerGui
    sound:Play()
    currentRadioSound = sound
    radioPlayBtn.Text = "⏹ Stop"
    radioPlayBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    radioPlayConnection = radioPlayBtn.MouseButton1Click:Connect(function()
        if currentRadioSound then
            currentRadioSound:Stop()
            currentRadioSound:Destroy()
            currentRadioSound = nil
            radioPlayBtn.Text = "▶ Play"
            radioPlayBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            if radioPlayConnection then radioPlayConnection:Disconnect(); radioPlayConnection = nil end
        end
    end)
end)

-- ===== Построение меню =====
local y = 0
createToggle(scrollContent, y, "Auto Farm", function(state) _G.AutoFarm = state end); y = y + 38
createInputControl(scrollContent, y, "AF Delay (s)", _G.AutoFarmDelay, function(val)
    _G.AutoFarmDelay = math.clamp(val, 0.5, 5)
end); y = y + 38

-- Кнопка переключения режима Auto Farm
local afModeBtn = createButton(scrollContent, y, "AF Mode: Fast", function()
    if _G.AutoFarmMode == "Fast" then
        _G.AutoFarmMode = "Slow"
        afModeBtn.Text = "AF Mode: Slow"
    else
        _G.AutoFarmMode = "Fast"
        afModeBtn.Text = "AF Mode: Fast"
    end
end)
y = y + 38

createToggle(scrollContent, y, "Fly", function(state)
    _G.Fly = state
    if state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = true
    end
end); y = y + 38
createToggle(scrollContent, y, "Noclip", function(state) _G.Noclip = state end); y = y + 38

local targetSelectBtn = createButton(scrollContent, y, "Target: None", function()
    if targetWindow.Visible then targetWindow.Visible = false
    else refreshTargetList(); targetWindow.Visible = true end
end)
y = y + 38

createButton(scrollContent, y, "Teleport to Target", function()
    if _G.SelectedTarget and _G.SelectedTarget.Character and _G.SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = _G.SelectedTarget.Character.HumanoidRootPart.CFrame
        end
    end
end); y = y + 38

createToggle(scrollContent, y, "Teleport Always", function(state) _G.TeleportAlways = state end); y = y + 38

createToggle(scrollContent, y, "Real Fling", function(state) _G.Fling = state end); y = y + 38

createInputControl(scrollContent, y, "WalkSpeed", 16, function(val)
    _G.WalkSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end); y = y + 38

createInputControl(scrollContent, y, "JumpPower", 50, function(val)
    _G.JumpPower = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end); y = y + 38

createToggle(scrollContent, y, "Role ESP", function(state)
    _G.ESPEnabled = state
    if not state then clearESP() end
end); y = y + 38

createButton(scrollContent, y, "Kill All", function()
    if not _G.KillAllActive then
        _G.KillAllActive = true
        task.spawn(function() killAll(); _G.KillAllActive = false end)
    end
end); y = y + 38

createButton(scrollContent, y, "Take Gun", function() takeGun() end); y = y + 38

createButton(scrollContent, y, "🎵 Radio", function()
    radioWindow.Visible = not radioWindow.Visible
end); y = y + 38

-- Обновление размера скролла
scrollContent.Size = UDim2.new(1, 0, 0, y + 10)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollContent.Size.Y.Offset)

-- ==================== Логика функций ====================

-- Noclip
RunService.Stepped:Connect(function()
    if _G.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Real Fling
RunService.Stepped:Connect(function()
    if not _G.Fling then return end
    if not _G.SelectedTarget or not _G.SelectedTarget.Character then return end
    local targetChar = _G.SelectedTarget.Character
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    hum.PlatformStand = true
    root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)  -- чуть впереди
    root.RotVelocity = Vector3.new(0, 2000, 0)  -- вращение
    targetRoot.Velocity = Vector3.new(math.random(-3000,3000), 5000, math.random(-3000,3000))  -- отбрасываем
end)

-- Auto Farm (с режимами)
task.spawn(function()
    while true do
        if _G.AutoFarm then
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if root then
                    local coins = {}
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and (obj.Name == "Coin" or obj.Name == "Coin_Server") then table.insert(coins, obj) end
                    end
                    for _, folderName in ipairs({"Coins", "CoinContainer", "CoinFolder", "ServerCoins"}) do
                        local folder = Workspace:FindFirstChild(folderName)
                        if folder then
                            for _, obj in ipairs(folder:GetDescendants()) do
                                if obj:IsA("BasePart") then table.insert(coins, obj) end
                            end
                        end
                    end
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name == "Coin" or obj:FindFirstChild("Coin")) then
                            local prim = obj.PrimaryPart or obj:FindFirstChild("Coin") or obj:FindFirstChildOfClass("BasePart")
                            if prim then table.insert(coins, prim) end
                        end
                    end

                    if #coins > 0 then
                        table.sort(coins, function(a, b) return (root.Position - a.Position).Magnitude < (root.Position - b.Position).Magnitude end)
                        for _, coin in ipairs(coins) do
                            if not _G.AutoFarm then break end
                            if _G.AutoFarmMode == "Fast" then
                                -- телепорт
                                local currentChar = LocalPlayer.Character
                                if currentChar and currentChar:FindFirstChild("HumanoidRootPart") then
                                    currentChar.HumanoidRootPart.CFrame = coin.CFrame
                                    task.wait(_G.AutoFarmDelay)
                                end
                            else
                                -- Slow: идём к монете
                                local currentChar = LocalPlayer.Character
                                if currentChar and hum and hum.Health > 0 then
                                    hum:MoveTo(coin.Position)
                                    -- ждём, пока расстояние станет < 5 или таймаут
                                    local startTime = tick()
                                    while (root.Position - coin.Position).Magnitude > 5 and tick() - startTime < 5 do
                                        if not _G.AutoFarm then break end
                                        task.wait(0.1)
                                    end
                                    task.wait(_G.AutoFarmDelay)
                                end
                            end
                        end
                    else
                        task.wait(0.5)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Fly
local PlayerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
RunService.RenderStepped:Connect(function()
    if not _G.Fly then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = true end

    local moveVector = PlayerModule:GetControls():GetMoveVector()
    local moveDirection = Vector3.new()
    if moveVector.Magnitude > 0 then
        moveDirection = (Camera.CFrame.RightVector * moveVector.X) + (Camera.CFrame.LookVector * -moveVector.Z)
    end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0, 1, 0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection -= Vector3.new(0, 1, 0) end

    if moveDirection.Magnitude > 0 then
        root.CFrame = root.CFrame + moveDirection.Unit * 1.5
        root.Velocity = Vector3.new(0, 0, 0)
    else
        root.Velocity = Vector3.new(0, 0, 0)
    end
end)

-- Teleport Always с отбрасыванием цели
RunService.RenderStepped:Connect(function()
    if not _G.TeleportAlways then return end
    if not _G.SelectedTarget or not _G.SelectedTarget.Character then return end
    local targetRoot = _G.SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    root.CFrame = targetRoot.CFrame
    -- Отбрасываем цель
    targetRoot.Velocity = Vector3.new(math.random(-500,500), 500, math.random(-500,500))
end)

-- Kill All
function killAll()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or not tool.Name:lower():find("knife") then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local targetChar = plr.Character
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            root.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
            tool:Activate()
            task.wait(0.1)
        end
    end
end

-- Take Gun (подбираем пистолет с земли)
function takeGun()
    local gun = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("pistol") or obj.Name:lower():find("sheriff")) then
            -- Проверяем, что он не в рюкзаке и не у персонажа (лежит в Workspace)
            if obj.Parent == Workspace then
                gun = obj
                break
            end
        end
    end
    if not gun then return end
    local handle = gun:FindFirstChild("Handle") or gun
    local pos = handle.Position
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    task.wait(0.3)
    if gun.Parent ~= LocalPlayer.Backpack and gun.Parent ~= char then
        pcall(function() gun.Parent = LocalPlayer.Backpack end)
    end
end

-- ==================== ESP ====================
local drawingCache = {}
function clearESP()
    for _, obj in ipairs(drawingCache) do
        if obj.box then obj.box.Visible = false; obj.box:Remove() end
    end
    table.clear(drawingCache)
end

function getRole(player)
    local char = player.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                local name = child.Name:lower()
                if name:find("knife") or name:find("murder") then return "Murderer"
                elseif name:find("gun") or name:find("sheriff") or name:find("pistol") then return "Sheriff" end
            end
        end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, child in ipairs(bp:GetChildren()) do
            if child:IsA("Tool") then
                local name = child.Name:lower()
                if name:find("knife") or name:find("murder") then return "Murderer"
                elseif name:find("gun") or name:find("sheriff") or name:find("pistol") then return "Sheriff" end
            end
        end
    end
    return "Innocent"
end

function createESPBox(target, color)
    local box = Drawing.new("Square")
    box.Color = color
    box.Thickness = 2
    box.Filled = false
    box.Visible = false

    local function update()
        pcall(function()
            local char = target.Character
            if not char then box.Visible = false; return end
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            if not root or not head then box.Visible = false; return end
            local cam = Workspace.CurrentCamera
            local pos, onScreen = cam:WorldToViewportPoint(root.Position)
            if onScreen then
                local headPos = cam:WorldToViewportPoint(head.Position)
                local height = (pos - headPos).Magnitude * 1.2
                local width = height * 0.55
                box.Size = Vector2.new(width, height)
                box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                box.Visible = true
            else
                box.Visible = false
            end
        end)
    end
    table.insert(drawingCache, {box = box, update = update})
    return update
end

local roleESPfunctions = {}
task.spawn(function()
    while true do
        if _G.ESPEnabled then _G.ESPRefresh = true end
        task.wait(1)
    end
end)
RunService.RenderStepped:Connect(function()
    if not _G.ESPEnabled then return end
    if _G.ESPRefresh then
        _G.ESPRefresh = false
        clearESP()
        roleESPfunctions = {}
    end
    local newESP = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if roleESPfunctions[plr] then
                newESP[plr] = roleESPfunctions[plr]
            else
                local role = getRole(plr)
                local color = Color3.fromRGB(80, 200, 80)
                if role == "Murderer" then color = Color3.fromRGB(255, 50, 50)
                elseif role == "Sheriff" then color = Color3.fromRGB(50, 150, 255) end
                newESP[plr] = createESPBox(plr, color)
            end
        end
    end
    roleESPfunctions = newESP
    for _, func in pairs(roleESPfunctions) do func() end
end)

LocalPlayer.CharacterAdded:Connect(function()
    clearESP()
    roleESPfunctions = {}
end)

-- Сброс при выключении флинга/полёта
RunService.Stepped:Connect(function()
    if not _G.Fling and not _G.Fly then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if hum then hum.PlatformStand = false end
            if root then root.RotVelocity = Vector3.new(0, 0, 0) end
        end
    end
end)

print("✅ MM2 Script v12 — Real Fling, TeleportAlways push, AutoFarm Fast/Slow, Radio, Take Gun с земли.")
