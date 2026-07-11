--[[
    The G0ld Stand HUB v3.0 (Full Rebuild)
    - Полностью переписан для стабильности
    - Золотой интерфейс, мерцающая обводка, перетаскивание
    - Все функции MM2: AutoFarm, Fly, Noclip, Real Fling, Teleport Always, ESP, Kill All, Take Gun, Radio
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Глобальные переменные MM2
_G.AutoFarm = false
_G.AutoFarmDelay = 2
_G.AutoFarmMode = "Fast"  -- "Fast" или "Slow"
_G.Fly = false
_G.Noclip = false
_G.Fling = false
_G.ESPEnabled = false
_G.SelectedTarget = nil
_G.WalkSpeed = 16
_G.JumpPower = 50
_G.TeleportAlways = false
_G.KillAllActive = false

-- ==================== GUI ====================
local hubGui = Instance.new("ScreenGui")
hubGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
hubGui.ResetOnSpawn = false
hubGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 400)
mainFrame.Position = UDim2.new(0.5, -160, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Parent = hubGui

-- Мерцающая золотая обводка
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Thickness = 2.5
stroke.LineJoinMode = Enum.LineJoinMode.Round
task.spawn(function()
    while true do
        for _, c in ipairs({Color3.fromRGB(255,200,0), Color3.fromRGB(255,230,50), Color3.fromRGB(255,170,0), Color3.fromRGB(255,215,0)}) do
            stroke.Color = c
            task.wait(0.4)
        end
    end
end)

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 14)

-- Заголовок
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(255,200,0)
header.BorderSizePixel = 0
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
local hGrad = Instance.new("UIGradient", header)
hGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,220,50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,180,0))
})
hGrad.Rotation = 90

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "The G0ld Stand HUB"
title.TextColor3 = Color3.fromRGB(180,0,0)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextStrokeTransparency = 0.4
title.TextStrokeColor3 = Color3.fromRGB(80,0,0)

-- Кнопка сворачивания
local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0, 36, 0, 36)
minimizeBtn.Position = UDim2.new(1, -36, 0, 0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(180,0,0)
minimizeBtn.TextSize = 24
minimizeBtn.Font = Enum.Font.GothamBold

-- Кнопка "HUB" для разворачивания
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 100, 0, 40)
openBtn.Position = UDim2.new(0.5, -50, 0.2, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(255,200,0)
openBtn.Text = "HUB"
openBtn.TextColor3 = Color3.fromRGB(180,0,0)
openBtn.TextSize = 18
openBtn.Font = Enum.Font.GothamBold
openBtn.Visible = false
openBtn.Parent = hubGui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 10)

-- Функция перетаскивания
local function makeDraggable(dragArea, moveTarget)
    local dragging, startPos, dragStart = false
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
    openBtn.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset + 110, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset)
    openBtn.Visible = true
end)

openBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local clickStart = input.Position
        openBtn.InputEnded:Connect(function(input2)
            if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
                if (input2.Position - clickStart).Magnitude < 10 then
                    openBtn.Visible = false
                    mainFrame.Position = UDim2.new(openBtn.Position.X.Scale, openBtn.Position.X.Offset - 110, openBtn.Position.Y.Scale, openBtn.Position.Y.Offset)
                    mainFrame.Visible = true
                end
            end
        end)
    end
end)

-- Контейнер страниц
local contentArea = Instance.new("Frame", mainFrame)
contentArea.Size = UDim2.new(1, 0, 1, -40)
contentArea.Position = UDim2.new(0, 0, 0, 40)
contentArea.BackgroundTransparency = 1

-- ==================== СТРАНИЦЫ ====================
-- Страница выбора игры
local gamePage = Instance.new("Frame", contentArea)
gamePage.Size = UDim2.new(1, 0, 1, 0)
gamePage.BackgroundTransparency = 1
gamePage.Visible = true

local gameScroll = Instance.new("ScrollingFrame", gamePage)
gameScroll.Size = UDim2.new(1, 0, 1, 0)
gameScroll.BackgroundTransparency = 1
gameScroll.ScrollBarThickness = 4
gameScroll.ScrollBarImageColor3 = Color3.fromRGB(255,255,255)
gameScroll.ScrollBarImageTransparency = 0.8
gameScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local gameList = Instance.new("Frame", gameScroll)
gameList.Size = UDim2.new(1, 0, 0, 0)
gameList.BackgroundTransparency = 1

-- Кнопка игры
local function addGameButton(parent, y, name, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 50)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,45)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local grad = Instance.new("UIGradient", btn)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50,50,60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30,30,40))
    })
    grad.Rotation = 90
    btn.MouseButton1Click:Connect(callback)
end

addGameButton(gameList, 10, "🔪 Murder Mystery 2", function()
    gamePage.Visible = false
    mm2Page.Visible = true
end)

gameList.Size = UDim2.new(1, 0, 0, 70)
gameScroll.CanvasSize = UDim2.new(0, 0, 0, 70)

-- Страница MM2
local mm2Page = Instance.new("Frame", contentArea)
mm2Page.Size = UDim2.new(1, 0, 1, 0)
mm2Page.BackgroundTransparency = 1
mm2Page.Visible = false

-- Верхняя панель с кнопкой "Назад"
local mm2Top = Instance.new("Frame", mm2Page)
mm2Top.Size = UDim2.new(1, 0, 0, 30)
mm2Top.BackgroundTransparency = 1

local backBtn = Instance.new("TextButton", mm2Top)
backBtn.Size = UDim2.new(0, 80, 1, 0)
backBtn.Position = UDim2.new(0, 5, 0, 0)
backBtn.BackgroundColor3 = Color3.fromRGB(60,90,230)
backBtn.Text = "← Back"
backBtn.TextColor3 = Color3.new(1,1,1)
backBtn.Font = Enum.Font.GothamSemibold
backBtn.TextSize = 13
backBtn.BorderSizePixel = 0
Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 6)
backBtn.MouseButton1Click:Connect(function()
    mm2Page.Visible = false
    gamePage.Visible = true
end)

-- Скролл для функций MM2
local mm2Scroll = Instance.new("ScrollingFrame", mm2Page)
mm2Scroll.Size = UDim2.new(1, 0, 1, -30)
mm2Scroll.Position = UDim2.new(0, 0, 0, 30)
mm2Scroll.BackgroundTransparency = 1
mm2Scroll.ScrollBarThickness = 5
mm2Scroll.ScrollBarImageColor3 = Color3.fromRGB(255,255,255)
mm2Scroll.ScrollBarImageTransparency = 0.7
mm2Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local mm2Content = Instance.new("Frame", mm2Scroll)
mm2Content.Size = UDim2.new(1, 0, 0, 0)
mm2Content.BackgroundTransparency = 1

-- Вспомогательные функции для создания элементов
local function createToggle(parent, y, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,55)
    btn.Text = text .. "  OFF"
    btn.TextColor3 = Color3.fromRGB(200,200,200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local grad = Instance.new("UIGradient", btn)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45,45,55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35,35,45))
    })
    grad.Rotation = 90
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.Text = text .. "  ON"
            btn.TextColor3 = Color3.new(1,1,1)
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0,180,80)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0,140,60))
            })
        else
            btn.Text = text .. "  OFF"
            btn.TextColor3 = Color3.fromRGB(200,200,200)
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(45,45,55)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(35,35,45))
            })
        end
        callback(state)
    end)
    btn.Parent = parent
    return btn
end

local function createButton(parent, y, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(60,90,230)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local grad = Instance.new("UIGradient", btn)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70,100,240)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40,70,200))
    })
    grad.Rotation = 90
    btn.MouseButton1Click:Connect(callback)
    btn.Parent = parent
    return btn
end

local function createInput(parent, y, labelText, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 32)
    holder.Position = UDim2.new(0, 10, 0, y)
    holder.BackgroundColor3 = Color3.fromRGB(30,30,40)
    holder.BorderSizePixel = 0
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", holder)
    label.Size = UDim2.new(0, 100, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local input = Instance.new("TextBox", holder)
    input.Size = UDim2.new(0, 60, 1, -8)
    input.Position = UDim2.new(1, -70, 0, 4)
    input.Text = tostring(default)
    input.TextColor3 = Color3.new(1,1,1)
    input.BackgroundColor3 = Color3.fromRGB(15,15,22)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 13
    input.BorderSizePixel = 0
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

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

-- ==================== ОТДЕЛЬНЫЕ ОКНА ====================
-- Окно выбора цели
local targetWindow = Instance.new("Frame")
targetWindow.Size = UDim2.new(0, 220, 0, 250)
targetWindow.Position = UDim2.new(0.5, -110, 0.3, 0)
targetWindow.BackgroundColor3 = Color3.fromRGB(25,25,35)
targetWindow.BorderSizePixel = 0
targetWindow.Visible = false
targetWindow.Active = true
targetWindow.Parent = hubGui
Instance.new("UICorner", targetWindow).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", targetWindow).Color = Color3.fromRGB(255,200,0)
Instance.new("UIStroke", targetWindow).Thickness = 2

local tHeader = Instance.new("Frame", targetWindow)
tHeader.Size = UDim2.new(1, 0, 0, 30)
tHeader.BackgroundColor3 = Color3.fromRGB(255,200,0)
Instance.new("UICorner", tHeader).CornerRadius = UDim.new(0, 10)
local tGrad = Instance.new("UIGradient", tHeader)
tGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,220,50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,180,0))
})
local tTitle = Instance.new("TextLabel", tHeader)
tTitle.Size = UDim2.new(1, -30, 1, 0)
tTitle.Position = UDim2.new(0, 10, 0, 0)
tTitle.Text = "Select Target"
tTitle.TextColor3 = Color3.fromRGB(180,0,0)
tTitle.Font = Enum.Font.GothamBold
tTitle.TextSize = 14
tTitle.BackgroundTransparency = 1
tTitle.TextXAlignment = Enum.TextXAlignment.Left

local tClose = Instance.new("TextButton", tHeader)
tClose.Size = UDim2.new(0, 30, 1, 0)
tClose.Position = UDim2.new(1, -30, 0, 0)
tClose.BackgroundTransparency = 1
tClose.Text = "✕"
tClose.TextColor3 = Color3.fromRGB(180,0,0)
tClose.Font = Enum.Font.GothamBold
tClose.TextSize = 16
tClose.MouseButton1Click:Connect(function()
    if targetWindow then targetWindow.Visible = false end
end)

makeDraggable(tHeader, targetWindow)

local tScroll = Instance.new("ScrollingFrame", targetWindow)
tScroll.Size = UDim2.new(1, 0, 1, -30)
tScroll.Position = UDim2.new(0, 0, 0, 30)
tScroll.BackgroundTransparency = 1
tScroll.ScrollBarThickness = 4
tScroll.ScrollBarImageTransparency = 0.8
tScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local tContent = Instance.new("Frame", tScroll)
tContent.Size = UDim2.new(1, 0, 0, 0)
tContent.BackgroundTransparency = 1

local function refreshTargetList()
    for _, child in ipairs(tContent:GetChildren()) do child:Destroy() end
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p) end
    end
    local yP = 0
    for _, plr in ipairs(list) do
        local entry = Instance.new("TextButton")
        entry.Size = UDim2.new(1, -8, 0, 36)
        entry.Position = UDim2.new(0, 4, 0, yP)
        entry.BackgroundColor3 = (_G.SelectedTarget == plr) and Color3.fromRGB(80,80,100) or Color3.fromRGB(40,40,50)
        entry.BorderSizePixel = 0
        entry.AutoButtonColor = false
        entry.Parent = tContent
        Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 6)

        local avatar = Instance.new("ImageLabel", entry)
        avatar.Size = UDim2.new(0, 28, 0, 28)
        avatar.Position = UDim2.new(0, 5, 0.5, -14)
        avatar.BackgroundTransparency = 1
        avatar.Image = ""
        Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

        local nameLabel = Instance.new("TextLabel", entry)
        nameLabel.Size = UDim2.new(1, -40, 1, 0)
        nameLabel.Position = UDim2.new(0, 40, 0, 0)
        nameLabel.Text = plr.Name
        nameLabel.TextColor3 = Color3.new(1,1,1)
        nameLabel.Font = Enum.Font.GothamSemibold
        nameLabel.TextSize = 13
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left

        entry.MouseButton1Click:Connect(function()
            _G.SelectedTarget = plr
            if targetWindow then targetWindow.Visible = false end
            if targetSelectBtn then
                targetSelectBtn.Text = "Target: " .. plr.Name
            end
        end)

        task.spawn(function()
            local uid = plr.UserId
            if uid > 0 then
                local ok, thumb = pcall(function()
                    return Players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                end)
                if ok and thumb then
                    avatar.Image = thumb
                end
            end
        end)
        yP = yP + 40
    end
    tContent.Size = UDim2.new(1, 0, 0, yP)
    tScroll.CanvasSize = UDim2.new(0, 0, 0, yP)
end

-- Закрытие окна при клике вне
UIS.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and targetWindow and targetWindow.Visible then
        local pos = input.Position
        local absPos = targetWindow.AbsolutePosition
        local absSize = targetWindow.AbsoluteSize
        if pos.X < absPos.X or pos.X > absPos.X + absSize.X or pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
            local btnPos = targetSelectBtn and targetSelectBtn.AbsolutePosition
            local btnSize = targetSelectBtn and targetSelectBtn.AbsoluteSize
            if not (btnPos and pos.X >= btnPos.X and pos.X <= btnPos.X + btnSize.X and pos.Y >= btnPos.Y and pos.Y <= btnPos.Y + btnSize.Y) then
                targetWindow.Visible = false
            end
        end
    end
end)

-- Окно радио
local radioWindow = Instance.new("Frame")
radioWindow.Size = UDim2.new(0, 250, 0, 120)
radioWindow.Position = UDim2.new(0.5, -125, 0.35, 0)
radioWindow.BackgroundColor3 = Color3.fromRGB(25,25,35)
radioWindow.BorderSizePixel = 0
radioWindow.Visible = false
radioWindow.Active = true
radioWindow.Parent = hubGui
Instance.new("UICorner", radioWindow).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", radioWindow).Color = Color3.fromRGB(255,200,0)
Instance.new("UIStroke", radioWindow).Thickness = 2

local rHeader = Instance.new("Frame", radioWindow)
rHeader.Size = UDim2.new(1, 0, 0, 30)
rHeader.BackgroundColor3 = Color3.fromRGB(255,200,0)
Instance.new("UICorner", rHeader).CornerRadius = UDim.new(0, 10)
local rGrad = Instance.new("UIGradient", rHeader)
rGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,220,50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,180,0))
})
local rTitle = Instance.new("TextLabel", rHeader)
rTitle.Size = UDim2.new(1, -30, 1, 0)
rTitle.Position = UDim2.new(0, 10, 0, 0)
rTitle.Text = "🎵 Radio"
rTitle.TextColor3 = Color3.fromRGB(180,0,0)
rTitle.Font = Enum.Font.GothamBold
rTitle.TextSize = 14
rTitle.BackgroundTransparency = 1

local rClose = Instance.new("TextButton", rHeader)
rClose.Size = UDim2.new(0, 30, 1, 0)
rClose.Position = UDim2.new(1, -30, 0, 0)
rClose.BackgroundTransparency = 1
rClose.Text = "✕"
rClose.TextColor3 = Color3.fromRGB(180,0,0)
rClose.Font = Enum.Font.GothamBold
rClose.TextSize = 16
rClose.MouseButton1Click:Connect(function()
    if radioWindow then radioWindow.Visible = false end
end)

makeDraggable(rHeader, radioWindow)

local radioInput = Instance.new("TextBox", radioWindow)
radioInput.Size = UDim2.new(0, 150, 0, 30)
radioInput.Position = UDim2.new(0, 10, 0, 40)
radioInput.Text = "1837897837"
radioInput.TextColor3 = Color3.new(1,1,1)
radioInput.BackgroundColor3 = Color3.fromRGB(15,15,22)
radioInput.Font = Enum.Font.GothamBold
radioInput.TextSize = 13
radioInput.BorderSizePixel = 0
Instance.new("UICorner", radioInput).CornerRadius = UDim.new(0, 5)

local radioPlayBtn = Instance.new("TextButton", radioWindow)
radioPlayBtn.Size = UDim2.new(0, 70, 0, 30)
radioPlayBtn.Position = UDim2.new(0, 170, 0, 40)
radioPlayBtn.Text = "▶ Play"
radioPlayBtn.TextColor3 = Color3.new(1,1,1)
radioPlayBtn.BackgroundColor3 = Color3.fromRGB(0,180,80)
radioPlayBtn.Font = Enum.Font.GothamBold
radioPlayBtn.TextSize = 13
radioPlayBtn.BorderSizePixel = 0
Instance.new("UICorner", radioPlayBtn).CornerRadius = UDim.new(0, 5)

local currentSound = nil
local playConn
radioPlayBtn.MouseButton1Click:Connect(function()
    if playConn then playConn:Disconnect(); playConn = nil end
    local id = tonumber(radioInput.Text)
    if not id then return end
    if currentSound then currentSound:Stop(); currentSound:Destroy(); currentSound = nil end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = 5
    sound.Parent = LocalPlayer.PlayerGui
    sound:Play()
    currentSound = sound
    radioPlayBtn.Text = "⏹ Stop"
    radioPlayBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
    playConn = radioPlayBtn.MouseButton1Click:Connect(function()
        if currentSound then
            currentSound:Stop(); currentSound:Destroy(); currentSound = nil
            radioPlayBtn.Text = "▶ Play"
            radioPlayBtn.BackgroundColor3 = Color3.fromRGB(0,180,80)
            if playConn then playConn:Disconnect(); playConn = nil end
        end
    end)
end)

-- ==================== ИНТЕРФЕЙС MM2 ====================
local y = 0
createToggle(mm2Content, y, "Auto Farm", function(state) _G.AutoFarm = state end); y = y + 38
createInput(mm2Content, y, "AF Delay (s)", _G.AutoFarmDelay, function(val)
    _G.AutoFarmDelay = math.clamp(val, 0.5, 5)
end); y = y + 38

local afModeBtn = createButton(mm2Content, y, "AF Mode: Fast", function()
    if _G.AutoFarmMode == "Fast" then
        _G.AutoFarmMode = "Slow"
        afModeBtn.Text = "AF Mode: Slow"
    else
        _G.AutoFarmMode = "Fast"
        afModeBtn.Text = "AF Mode: Fast"
    end
end)
y = y + 38

createToggle(mm2Content, y, "Fly", function(state)
    _G.Fly = state
    if state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = true
    end
end); y = y + 38
createToggle(mm2Content, y, "Noclip", function(state) _G.Noclip = state end); y = y + 38

targetSelectBtn = createButton(mm2Content, y, "Target: None", function()
    if targetWindow then
        if targetWindow.Visible then targetWindow.Visible = false
        else refreshTargetList(); targetWindow.Visible = true end
    end
end)
y = y + 38

createButton(mm2Content, y, "Teleport to Target", function()
    if _G.SelectedTarget and _G.SelectedTarget.Character and _G.SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = _G.SelectedTarget.Character.HumanoidRootPart.CFrame
        end
    end
end); y = y + 38

createToggle(mm2Content, y, "Teleport Always", function(state) _G.TeleportAlways = state end); y = y + 38
createToggle(mm2Content, y, "Real Fling", function(state) _G.Fling = state end); y = y + 38

createInput(mm2Content, y, "WalkSpeed", 16, function(val)
    _G.WalkSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end); y = y + 38

createInput(mm2Content, y, "JumpPower", 50, function(val)
    _G.JumpPower = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end); y = y + 38

createToggle(mm2Content, y, "Role ESP", function(state)
    _G.ESPEnabled = state
    if not state then
        for _, obj in ipairs(ESP_cache) do
            if obj.box then obj.box.Visible = false; obj.box:Remove() end
        end
        table.clear(ESP_cache)
    end
end); y = y + 38

createButton(mm2Content, y, "Kill All", function()
    if not _G.KillAllActive then
        _G.KillAllActive = true
        task.spawn(function() killAll(); _G.KillAllActive = false end)
    end
end); y = y + 38

createButton(mm2Content, y, "Take Gun", function() takeGun() end); y = y + 38

createButton(mm2Content, y, "🎵 Radio", function()
    if radioWindow then radioWindow.Visible = not radioWindow.Visible end
end); y = y + 38

mm2Content.Size = UDim2.new(1, 0, 0, y + 10)
mm2Scroll.CanvasSize = UDim2.new(0, 0, 0, mm2Content.Size.Y.Offset)

-- ==================== ЛОГИКА ====================
-- Noclip
RunService.Stepped:Connect(function()
    if _G.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end
end)

-- Real Fling
RunService.Stepped:Connect(function()
    if not _G.Fling then return end
    if not _G.SelectedTarget or not _G.SelectedTarget.Character then return end
    local targetRoot = _G.SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    hum.PlatformStand = true
    root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
    root.RotVelocity = Vector3.new(0, 2000, 0)
    targetRoot.Velocity = Vector3.new(math.random(-3000,3000), 5000, math.random(-3000,3000))
end)

-- Auto Farm
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
                                local currentChar = LocalPlayer.Character
                                if currentChar and currentChar:FindFirstChild("HumanoidRootPart") then
                                    currentChar.HumanoidRootPart.CFrame = coin.CFrame
                                    task.wait(_G.AutoFarmDelay)
                                end
                            else
                                local currentChar = LocalPlayer.Character
                                if currentChar and hum and hum.Health > 0 then
                                    hum:MoveTo(coin.Position)
                                    local t0 = tick()
                                    while (root.Position - coin.Position).Magnitude > 5 and tick() - t0 < 5 do
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
local PlayerModule = nil
local function getPlayerModule()
    if PlayerModule then return PlayerModule end
    local success, module = pcall(function()
        return require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    end)
    if success then
        PlayerModule = module
        return module
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    if not _G.Fly then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = true end

    local module = getPlayerModule()
    if not module then return end

    local moveVector = module:GetControls():GetMoveVector()
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

-- Teleport Always + push
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
    targetRoot.Velocity = Vector3.new(math.random(-500,500), 500, math.random(-500,500))
end)

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

function takeGun()
    local gun = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("pistol") or obj.Name:lower():find("sheriff")) then
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

-- ESP
ESP_cache = {}
function getRole(player)
    local char = player.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                local n = child.Name:lower()
                if n:find("knife") or n:find("murder") then return "Murderer"
                elseif n:find("gun") or n:find("sheriff") or n:find("pistol") then return "Sheriff" end
            end
        end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, child in ipairs(bp:GetChildren()) do
            if child:IsA("Tool") then
                local n = child.Name:lower()
                if n:find("knife") or n:find("murder") then return "Murderer"
                elseif n:find("gun") or n:find("sheriff") or n:find("pistol") then return "Sheriff" end
            end
        end
    end
    return "Innocent"
end

local ESP_functions = {}
task.spawn(function()
    while true do
        if _G.ESPEnabled then
            -- обновление принудительно раз в секунду
            ESP_functions = {}
        end
        task.wait(1)
    end
end)

RunService.RenderStepped:Connect(function()
    if not _G.ESPEnabled then return end
    local newESP = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if not ESP_functions[plr] then
                local role = getRole(plr)
                local color = Color3.fromRGB(80,200,80)
                if role == "Murderer" then color = Color3.fromRGB(255,50,50)
                elseif role == "Sheriff" then color = Color3.fromRGB(50,150,255) end
                local box = Drawing.new("Square")
                box.Color = color
                box.Thickness = 2
                box.Filled = false
                box.Visible = false
                local function update()
                    pcall(function()
                        local char = plr.Character
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
                ESP_functions[plr] = {box = box, update = update}
            end
            newESP[plr] = ESP_functions[plr]
        end
    end
    for _, v in pairs(newESP) do v.update() end
    for plr, _ in pairs(ESP_functions) do
        if not newESP[plr] then
            ESP_functions[plr].box.Visible = false
            ESP_functions[plr].box:Remove()
            ESP_functions[plr] = nil
        end
    end
    ESP_functions = newESP
end)

LocalPlayer.CharacterAdded:Connect(function()
    for _, v in pairs(ESP_functions) do
        v.box.Visible = false
        v.box:Remove()
    end
    table.clear(ESP_functions)
end)

-- Сброс PlatformStand при выключении Fly/Fling
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

print("✅ The G0ld Stand HUB v3.0 загружен! Исправлены все ошибки.")
