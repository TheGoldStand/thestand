--[[
    MM2 FULL MENU v8 (Ultimate): AutoFarm, Fly, Teleport, Proximity Fling, Noclip, Speed, Jump,
    Role ESP (Outline), Music Player, AutoShoot, KillAll, Take Gun
    Изменения:
    - Fling: теперь персонаж бешено крутится на месте и отбрасывает любого, кто подойдёт близко (Proximity Fling)
    - Добавлены кнопки: AutoShoot (автоматическое наведение на мёрдера и выстрел), KillAll (убить всех, если вы мёрдер), Take Gun (телепорт к лежащему пистолету и подбор)
    - Заголовок: "🔪 MM2 Script / BY TheG0ldStand"
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Глобальные переменные
_G.AutoFarm = false
_G.Fly = false
_G.Noclip = false
_G.Fling = false
_G.ESPEnabled = false
_G.SelectedTarget = nil
_G.WalkSpeed = 16
_G.JumpPower = 50
_G.ESPRefresh = false
_G.AutoShoot = false
_G.KillAllActive = false

-- ==================== GUI ====================
local gui = Instance.new("ScreenGui")
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 580)  -- увеличен под новые кнопки
mainFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Parent = gui

local shadow = Instance.new("ImageLabel", mainFrame)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6014261993"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24, 24, 24, 24)
shadow.ZIndex = 0

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 14)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
header.BorderSizePixel = 0
header.Parent = mainFrame
local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 14)

local headerGradient = Instance.new("UIGradient", header)
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 40, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 0))
})
headerGradient.Rotation = 90

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "🔪 MM2 Script / BY TheG0ldStand"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
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
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 22
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextStrokeTransparency = 0.6

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 90, 0, 40)
openBtn.Position = UDim2.new(0.5, -45, 0.2, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
openBtn.Text = "OPEN"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.TextSize = 16
openBtn.Font = Enum.Font.GothamBold
openBtn.Visible = false
openBtn.Active = true
openBtn.Parent = gui
local openCorner = Instance.new("UICorner", openBtn)
openCorner.CornerRadius = UDim.new(0, 10)
local openShadow = Instance.new("ImageLabel", openBtn)
openShadow.Size = UDim2.new(1, 12, 1, 12)
openShadow.Position = UDim2.new(0, -6, 0, -6)
openShadow.BackgroundTransparency = 1
openShadow.Image = "rbxassetid://6014261993"
openShadow.ImageTransparency = 0.7
openShadow.ScaleType = Enum.ScaleType.Slice
openShadow.SliceCenter = Rect.new(24, 24, 24, 24)
openShadow.ZIndex = 0

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

local function createTargetSelector(parent, yPos)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -24, 0, 32)
    holder.Position = UDim2.new(0, 12, 0, yPos)
    holder.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    holder.BorderSizePixel = 0
    local hC = Instance.new("UICorner", holder)
    hC.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", holder)
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 35, 0, 0)
    label.Text = "Target: None"
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.BackgroundTransparency = 1

    local btnPrev = Instance.new("TextButton", holder)
    btnPrev.Size = UDim2.new(0, 35, 1, 0)
    btnPrev.Position = UDim2.new(0, 0, 0, 0)
    btnPrev.Text = "◀"
    btnPrev.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnPrev.BackgroundTransparency = 1
    btnPrev.Font = Enum.Font.GothamBold
    btnPrev.TextSize = 14

    local btnNext = Instance.new("TextButton", holder)
    btnNext.Size = UDim2.new(0, 35, 1, 0)
    btnNext.Position = UDim2.new(1, -35, 0, 0)
    btnNext.Text = "▶"
    btnNext.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnNext.BackgroundTransparency = 1
    btnNext.Font = Enum.Font.GothamBold
    btnNext.TextSize = 14

    local targetIndex = 1
    local function getPlayers()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(list, p) end
        end
        return list
    end

    local function updateTarget()
        local list = getPlayers()
        if #list == 0 then
            label.Text = "Target: None"
            _G.SelectedTarget = nil
            return
        end
        if targetIndex > #list then targetIndex = 1 end
        if targetIndex < 1 then targetIndex = #list end
        _G.SelectedTarget = list[targetIndex]
        label.Text = "Target: " .. _G.SelectedTarget.Name
    end

    btnPrev.MouseButton1Click:Connect(function() targetIndex = targetIndex - 1; updateTarget() end)
    btnNext.MouseButton1Click:Connect(function() targetIndex = targetIndex + 1; updateTarget() end)

    task.spawn(function()
        while task.wait(2) do
            if _G.SelectedTarget and not _G.SelectedTarget.Parent then updateTarget() end
        end
    end)
    holder.Parent = parent
    updateTarget()
end

-- ===== Построение меню =====
local y = 45
createToggle(mainFrame, y, "Auto Farm", function(state) _G.AutoFarm = state end); y = y + 38
createToggle(mainFrame, y, "Fly", function(state)
    _G.Fly = state
    if state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = true
    end
end); y = y + 38
createToggle(mainFrame, y, "Noclip", function(state) _G.Noclip = state end); y = y + 38

createTargetSelector(mainFrame, y); y = y + 38
createButton(mainFrame, y, "Teleport to Target", function()
    if _G.SelectedTarget and _G.SelectedTarget.Character and _G.SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = _G.SelectedTarget.Character.HumanoidRootPart.CFrame
        end
    end
end); y = y + 38

createToggle(mainFrame, y, "Spin Fling", function(state) _G.Fling = state end); y = y + 38

createInputControl(mainFrame, y, "WalkSpeed", 16, function(val)
    _G.WalkSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end); y = y + 38

createInputControl(mainFrame, y, "JumpPower", 50, function(val)
    _G.JumpPower = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end); y = y + 38

createToggle(mainFrame, y, "Role ESP", function(state)
    _G.ESPEnabled = state
    if not state then clearESP() end
end); y = y + 38

createToggle(mainFrame, y, "AutoShoot", function(state) _G.AutoShoot = state end); y = y + 38
createButton(mainFrame, y, "Kill All", function() 
    if not _G.KillAllActive then
        _G.KillAllActive = true
        task.spawn(function()
            killAll()
            _G.KillAllActive = false
        end)
    end
end); y = y + 38

createButton(mainFrame, y, "Take Gun", function() takeGun() end); y = y + 38

-- Music Player
local musicFrame = Instance.new("Frame")
musicFrame.Size = UDim2.new(1, -24, 0, 50)
musicFrame.Position = UDim2.new(0, 12, 0, y)
musicFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
musicFrame.BorderSizePixel = 0
local mCorner = Instance.new("UICorner", musicFrame); mCorner.CornerRadius = UDim.new(0, 8)
musicFrame.Parent = mainFrame

local musicLabel = Instance.new("TextLabel", musicFrame)
musicLabel.Size = UDim2.new(1, 0, 0, 18)
musicLabel.Position = UDim2.new(0, 8, 0, 5)
musicLabel.Text = "🎵 Music ID"
musicLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
musicLabel.Font = Enum.Font.GothamBold
musicLabel.TextSize = 12
musicLabel.BackgroundTransparency = 1

local musicInput = Instance.new("TextBox", musicFrame)
musicInput.Size = UDim2.new(0, 140, 0, 22)
musicInput.Position = UDim2.new(0, 8, 0, 23)
musicInput.Text = "1837897837"
musicInput.TextColor3 = Color3.new(1, 1, 1)
musicInput.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
musicInput.Font = Enum.Font.GothamBold
musicInput.TextSize = 12
musicInput.BorderSizePixel = 0
local inputCorner = Instance.new("UICorner", musicInput); inputCorner.CornerRadius = UDim.new(0, 5)

local playBtn = Instance.new("TextButton", musicFrame)
playBtn.Size = UDim2.new(0, 60, 0, 22)
playBtn.Position = UDim2.new(1, -68, 0, 23)
playBtn.Text = "▶ Play"
playBtn.TextColor3 = Color3.new(1, 1, 1)
playBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
playBtn.Font = Enum.Font.GothamBold
playBtn.TextSize = 12
playBtn.BorderSizePixel = 0
local playCorner = Instance.new("UICorner", playBtn); playCorner.CornerRadius = UDim.new(0, 5)

-- ==================== Игровая логика ====================

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

-- Proximity Fling (Spin + отбрасывание)
RunService.Stepped:Connect(function()
    if not _G.Fling then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    hum.PlatformStand = true
    root.RotVelocity = Vector3.new(0, 2000, 0)  -- бешеное вращение

    -- Проверяем всех игроков в радиусе 15
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local targetChar = plr.Character
        if targetChar then
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local dist = (root.Position - targetRoot.Position).Magnitude
                if dist <= 15 then
                    -- Кидаем за карту
                    targetRoot.Velocity = Vector3.new(
                        math.random(-3000, 3000),
                        math.random(4000, 8000),
                        math.random(-3000, 3000)
                    )
                end
            end
        end
    end
end)

-- Auto Farm
RunService.RenderStepped:Connect(function()
    if not _G.AutoFarm then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

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
        root.CFrame = coins[1].CFrame
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

-- AutoShoot
RunService.RenderStepped:Connect(function()
    if not _G.AutoShoot then return end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or not (tool.Name:lower():find("gun") or tool.Name:lower():find("sheriff") or tool.Name:lower():find("pistol")) then return end
    -- Ищем мёрдера
    local murderer = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local role = getRole(plr)
        if role == "Murderer" then
            murderer = plr
            break
        end
    end
    if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("Head") then return end
    local head = murderer.Character.Head
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    -- Поворачиваемся к голове мёрдера
    root.CFrame = CFrame.new(root.Position, head.Position)
    -- Стреляем
    tool:Activate()
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
            local targetRoot = targetChar.HumanoidRootPart
            -- Телепортируемся к нему
            root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
            -- Убиваем (активируем нож)
            tool:Activate()
            task.wait(0.1)  -- небольшая задержка
        end
    end
end

-- Take Gun
function takeGun()
    local gun = nil
    -- Ищем пистолет на карте (Tool)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("pistol") or obj.Name:lower():find("sheriff")) then
            gun = obj
            break
        end
    end
    if not gun then return end
    -- Находим точку для телепортации (ручка или сам объект)
    local handle = gun:FindFirstChild("Handle") or gun.Parent
    local pos = handle and handle.Position or gun.Position
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    -- Ждём подбора
    task.wait(0.3)
    -- Если не подобралось, попробуем вручную положить в рюкзак (но обычно срабатывает)
    if gun.Parent ~= LocalPlayer.Backpack and gun.Parent ~= char then
        pcall(function() gun.Parent = LocalPlayer.Backpack end)
    end
end

-- ==================== ESP (обводка) ====================
local drawingCache = {}
function clearESP()
    for _, obj in ipairs(drawingCache) do
        if obj.box then
            obj.box.Visible = false
            obj.box:Remove()
        end
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
        if _G.ESPEnabled then
            _G.ESPRefresh = true
        end
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

-- Music Player
local currentSound = nil
local playConnection
playBtn.MouseButton1Click:Connect(function()
    if playConnection then playConnection:Disconnect(); playConnection = nil end
    local id = tonumber(musicInput.Text)
    if not id then return end
    if currentSound then currentSound:Stop(); currentSound:Destroy(); currentSound = nil end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = 5
    sound.Parent = LocalPlayer.PlayerGui
    sound:Play()
    currentSound = sound
    playBtn.Text = "⏹ Stop"
    playBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    playConnection = playBtn.MouseButton1Click:Connect(function()
        if currentSound then
            currentSound:Stop(); currentSound:Destroy(); currentSound = nil
            playBtn.Text = "▶ Play"
            playBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            if playConnection then playConnection:Disconnect(); playConnection = nil end
        end
    end)
end)

-- Сброс состояния при выключении флинга или полёта
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

print("✅ MM2 Script v8 / BY TheG0ldStand загружен!")
