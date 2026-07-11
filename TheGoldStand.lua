local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

_G.AutoFarm = false
_G.AutoFarmDelay = 2
_G.AutoFarmMode = "Fast"
_G.Fly = false
_G.Noclip = false
_G.SelectedTarget = nil
_G.WalkSpeed = 16
_G.JumpPower = 50
_G.TeleportAlways = false
_G.ESPEnabled = false
_G.GunESP = false

local gui = Instance.new("ScreenGui")
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 300)
mainFrame.Position = UDim2.new(0.5, -150, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Parent = gui

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

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = Color3.fromRGB(255,200,0)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
local hGrad = Instance.new("UIGradient", header)
hGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,220,50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,180,0))
})
hGrad.Rotation = 90

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 40, 0, 0)
title.Text = "The G0ld Stand HUB"
title.TextColor3 = Color3.fromRGB(180,0,0)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Center

local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -66, 0, 3)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(180,0,0)
minimizeBtn.TextSize = 22
minimizeBtn.Font = Enum.Font.GothamBold

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -33, 0, 3)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(180,0,0)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold

local openHubBtn = Instance.new("TextButton")
openHubBtn.Size = UDim2.new(0, 100, 0, 40)
openHubBtn.Position = UDim2.new(0.5, -50, 0.2, 0)
openHubBtn.BackgroundColor3 = Color3.fromRGB(255,200,0)
openHubBtn.Text = "HUB"
openHubBtn.TextColor3 = Color3.fromRGB(180,0,0)
openHubBtn.TextSize = 18
openHubBtn.Font = Enum.Font.GothamBold
openHubBtn.Visible = false
openHubBtn.Parent = gui
Instance.new("UICorner", openHubBtn).CornerRadius = UDim.new(0, 10)

local function makeDraggable(dragArea, moveTarget)
    local dragging = false
    local startPos = nil
    local dragStart = nil
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
makeDraggable(openHubBtn, openHubBtn)

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openHubBtn.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset + 110, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset)
    openHubBtn.Visible = true
end)

openHubBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local clickStart = input.Position
        openHubBtn.InputEnded:Connect(function(input2)
            if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
                if (input2.Position - clickStart).Magnitude < 10 then
                    openHubBtn.Visible = false
                    mainFrame.Position = UDim2.new(openHubBtn.Position.X.Scale, openHubBtn.Position.X.Offset - 110, openHubBtn.Position.Y.Scale, openHubBtn.Position.Y.Offset)
                    mainFrame.Visible = true
                end
            end
        end)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local mm2Btn = Instance.new("TextButton", mainFrame)
mm2Btn.Size = UDim2.new(1, -20, 0, 50)
mm2Btn.Position = UDim2.new(0, 10, 0, 46)
mm2Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mm2Btn.Text = "🔪 Murder Mystery 2"
mm2Btn.TextColor3 = Color3.fromRGB(255, 50, 50)
mm2Btn.Font = Enum.Font.GothamBold
mm2Btn.TextSize = 16
mm2Btn.BorderSizePixel = 0
mm2Btn.AutoButtonColor = false
Instance.new("UICorner", mm2Btn).CornerRadius = UDim.new(0, 10)

local btnGrad = Instance.new("UIGradient", mm2Btn)
btnGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 40))
})
btnGrad.Rotation = 90

local mm2Frame = nil
local openMM2Btn = nil
local targetWindow = nil

local function createMM2Window()
    if mm2Frame then return end

    mm2Frame = Instance.new("Frame")
    mm2Frame.Size = UDim2.new(0, 300, 0, 400)
    mm2Frame.Position = UDim2.new(0.5, -150, 0.2, 0)
    mm2Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mm2Frame.BackgroundTransparency = 0.15
    mm2Frame.BorderSizePixel = 0
    mm2Frame.ClipsDescendants = true
    mm2Frame.Active = true
    mm2Frame.Visible = true
    mm2Frame.Parent = gui

    local mStroke = Instance.new("UIStroke", mm2Frame)
    mStroke.Thickness = 2.5
    mStroke.LineJoinMode = Enum.LineJoinMode.Round
    task.spawn(function()
        while true do
            for _, c in ipairs({Color3.fromRGB(255,200,0), Color3.fromRGB(255,230,50), Color3.fromRGB(255,170,0), Color3.fromRGB(255,215,0)}) do
                mStroke.Color = c
                task.wait(0.4)
            end
        end
    end)
    Instance.new("UICorner", mm2Frame).CornerRadius = UDim.new(0, 14)

    local mHeader = Instance.new("Frame", mm2Frame)
    mHeader.Size = UDim2.new(1, 0, 0, 36)
    mHeader.BackgroundColor3 = Color3.fromRGB(255,200,0)
    mHeader.BorderSizePixel = 0
    Instance.new("UICorner", mHeader).CornerRadius = UDim.new(0, 14)
    local mhGrad = Instance.new("UIGradient", mHeader)
    mhGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,220,50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,180,0))
    })
    mhGrad.Rotation = 90

    local mTitle = Instance.new("TextLabel", mHeader)
    mTitle.Size = UDim2.new(1, -100, 1, 0)
    mTitle.Position = UDim2.new(0, 40, 0, 0)
    mTitle.Text = "MM2 Script"
    mTitle.TextColor3 = Color3.fromRGB(180,0,0)
    mTitle.TextSize = 16
    mTitle.Font = Enum.Font.GothamBold
    mTitle.BackgroundTransparency = 1
    mTitle.TextXAlignment = Enum.TextXAlignment.Center

    local mMinimize = Instance.new("TextButton", mHeader)
    mMinimize.Size = UDim2.new(0, 30, 0, 30)
    mMinimize.Position = UDim2.new(1, -66, 0, 3)
    mMinimize.BackgroundTransparency = 1
    mMinimize.Text = "−"
    mMinimize.TextColor3 = Color3.fromRGB(180,0,0)
    mMinimize.TextSize = 22
    mMinimize.Font = Enum.Font.GothamBold

    local mClose = Instance.new("TextButton", mHeader)
    mClose.Size = UDim2.new(0, 30, 0, 30)
    mClose.Position = UDim2.new(1, -33, 0, 3)
    mClose.BackgroundTransparency = 1
    mClose.Text = "✕"
    mClose.TextColor3 = Color3.fromRGB(180,0,0)
    mClose.TextSize = 18
    mClose.Font = Enum.Font.GothamBold

    makeDraggable(mHeader, mm2Frame)

    local mScroll = Instance.new("ScrollingFrame", mm2Frame)
    mScroll.Size = UDim2.new(1, 0, 1, -36)
    mScroll.Position = UDim2.new(0, 0, 0, 36)
    mScroll.BackgroundTransparency = 1
    mScroll.ScrollBarThickness = 5
    mScroll.ScrollBarImageColor3 = Color3.fromRGB(255,255,255)
    mScroll.ScrollBarImageTransparency = 0.7
    mScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    local mContent = Instance.new("Frame", mScroll)
    mContent.Size = UDim2.new(1, 0, 0, 0)
    mContent.BackgroundTransparency = 1

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
                btn.TextColor3 = Color3.fromRGB(255,255,255)
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
        btn.TextColor3 = Color3.fromRGB(255,255,255)
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
        input.TextColor3 = Color3.fromRGB(255,255,255)
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

    local targetSelectBtn

    local function createTargetWindow()
        if targetWindow then return end
        targetWindow = Instance.new("Frame")
        targetWindow.Size = UDim2.new(0, 220, 0, 250)
        targetWindow.Position = UDim2.new(0.5, -110, 0.3, 0)
        targetWindow.BackgroundColor3 = Color3.fromRGB(25,25,35)
        targetWindow.BorderSizePixel = 0
        targetWindow.Visible = false
        targetWindow.Active = true
        targetWindow.Parent = gui
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
                nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
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

        targetWindow.Refresh = refreshTargetList
    end

    local y = 0
    createToggle(mContent, y, "Auto Farm", function(state) _G.AutoFarm = state end); y = y + 38
    createInput(mContent, y, "AF Delay (s)", _G.AutoFarmDelay, function(val)
        _G.AutoFarmDelay = math.clamp(val, 0.5, 3)
    end); y = y + 38

    local afModeBtn = createButton(mContent, y, "AF Mode: Fast", function()
        if _G.AutoFarmMode == "Fast" then
            _G.AutoFarmMode = "Slow"
            afModeBtn.Text = "AF Mode: Slow"
        else
            _G.AutoFarmMode = "Fast"
            afModeBtn.Text = "AF Mode: Fast"
        end
    end)
    y = y + 38

    createToggle(mContent, y, "Fly", function(state)
        _G.Fly = state
        if state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = true
        end
    end); y = y + 38
    createToggle(mContent, y, "Noclip", function(state) _G.Noclip = state end); y = y + 38

    targetSelectBtn = createButton(mContent, y, "Target: None", function()
        if not targetWindow then createTargetWindow() end
        if targetWindow then
            if targetWindow.Visible then
                targetWindow.Visible = false
            else
                targetWindow.Refresh()
                targetWindow.Visible = true
            end
        end
    end)
    y = y + 38

    createButton(mContent, y, "Teleport to Target", function()
        if _G.SelectedTarget and _G.SelectedTarget.Character and _G.SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = _G.SelectedTarget.Character.HumanoidRootPart.CFrame
            end
        end
    end); y = y + 38

    createToggle(mContent, y, "Teleport Always", function(state) _G.TeleportAlways = state end); y = y + 38

    createInput(mContent, y, "WalkSpeed", 16, function(val)
        _G.WalkSpeed = val
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end); y = y + 38

    createInput(mContent, y, "JumpPower", 50, function(val)
        _G.JumpPower = val
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = val
        end
    end); y = y + 38

    createToggle(mContent, y, "Role ESP", function(state)
        _G.ESPEnabled = state
        if not state then
            for _, v in pairs(ESP_objects) do
                if v.box then v.box.Visible = false; v.box:Remove() end
            end
            table.clear(ESP_objects)
        end
    end); y = y + 38

    createToggle(mContent, y, "ESP Gun", function(state)
        _G.GunESP = state
    end); y = y + 38

    mContent.Size = UDim2.new(1, 0, 0, y + 10)
    mScroll.CanvasSize = UDim2.new(0, 0, 0, mContent.Size.Y.Offset)

    openMM2Btn = Instance.new("TextButton")
    openMM2Btn.Size = UDim2.new(0, 100, 0, 40)
    openMM2Btn.Position = UDim2.new(0.5, -50, 0.25, 0)
    openMM2Btn.BackgroundColor3 = Color3.fromRGB(255,200,0)
    openMM2Btn.Text = "MM2"
    openMM2Btn.TextColor3 = Color3.fromRGB(180,0,0)
    openMM2Btn.TextSize = 18
    openMM2Btn.Font = Enum.Font.GothamBold
    openMM2Btn.Visible = false
    openMM2Btn.Parent = gui
    Instance.new("UICorner", openMM2Btn).CornerRadius = UDim.new(0, 10)

    makeDraggable(openMM2Btn, openMM2Btn)

    mMinimize.MouseButton1Click:Connect(function()
        mm2Frame.Visible = false
        openMM2Btn.Position = UDim2.new(mm2Frame.Position.X.Scale, mm2Frame.Position.X.Offset + 110, mm2Frame.Position.Y.Scale, mm2Frame.Position.Y.Offset)
        openMM2Btn.Visible = true
    end)

    openMM2Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local clickStart = input.Position
            openMM2Btn.InputEnded:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
                    if (input2.Position - clickStart).Magnitude < 10 then
                        openMM2Btn.Visible = false
                        mm2Frame.Position = UDim2.new(openMM2Btn.Position.X.Scale, openMM2Btn.Position.X.Offset - 110, openMM2Btn.Position.Y.Scale, openMM2Btn.Position.Y.Offset)
                        mm2Frame.Visible = true
                    end
                end
            end)
        end
    end)

    mClose.MouseButton1Click:Connect(function()
        if mm2Frame then mm2Frame:Destroy(); mm2Frame = nil end
        if openMM2Btn then openMM2Btn:Destroy(); openMM2Btn = nil end
        if targetWindow then targetWindow:Destroy(); targetWindow = nil end
    end)
end

mm2Btn.MouseButton1Click:Connect(function()
    createMM2Window()
end)

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

-- Teleport Always
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
end)

-- Сброс PlatformStand при выключении Fly
RunService.Stepped:Connect(function()
    if not _G.Fly then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end)

-- ==================== ESP ====================
ESP_objects = {}
local OriginalSheriff = nil

local function findOriginalSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, tool in ipairs(p.Character:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("gun") or tool.Name:lower():find("sheriff") or tool.Name:lower():find("pistol")) then
                    return p
                end
            end
        end
        local bp = p:FindFirstChild("Backpack")
        if bp then
            for _, tool in ipairs(bp:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("gun") or tool.Name:lower():find("sheriff") or tool.Name:lower():find("pistol")) then
                    return p
                end
            end
        end
    end
    return nil
end

OriginalSheriff = findOriginalSheriff()

local function getRole(player)
    local char = player.Character
    if not char then return "Innocent" end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("knife") or name:find("murder") then
                return "Murderer"
            end
        end
    end
    local hasGun = false
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("gun") or tool.Name:lower():find("sheriff") or tool.Name:lower():find("pistol")) then
            hasGun = true
            break
        end
    end
    if hasGun then
        if OriginalSheriff and OriginalSheriff == player and OriginalSheriff.Character then
            return "Sheriff"
        else
            return "Fake Sheriff"
        end
    end
    return "Innocent"
end

local function createESPBox(target, color)
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
    table.insert(ESP_objects, {box = box, update = update, target = target})
    return update
end

local gunESPbox = nil

RunService.RenderStepped:Connect(function()
    if not _G.ESPEnabled and not _G.GunESP then return end

    local newESP = {}
    if _G.ESPEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local found = nil
                for _, obj in ipairs(ESP_objects) do
                    if obj.target == plr then
                        found = obj
                        break
                    end
                end
                if not found then
                    local role = getRole(plr)
                    local color = Color3.fromRGB(80,200,80)
                    if role == "Murderer" then color = Color3.fromRGB(255,50,50)
                    elseif role == "Sheriff" then color = Color3.fromRGB(50,150,255)
                    elseif role == "Fake Sheriff" then color = Color3.fromRGB(255,255,0)
                    end
                    found = {target = plr, box = nil, update = nil}
                    found.update = createESPBox(plr, color)
                    found.box = ESP_objects[#ESP_objects].box
                end
                newESP[plr] = found
            end
        end
    end

    for _, obj in ipairs(ESP_objects) do
        if not newESP[obj.target] then
            obj.box.Visible = false
            obj.box:Remove()
        end
    end
    ESP_objects = {}
    for _, v in pairs(newESP) do table.insert(ESP_objects, v) end

    for _, obj in ipairs(ESP_objects) do
        obj.update()
    end

    if _G.GunESP then
        local gunTool = nil
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("pistol") or obj.Name:lower():find("sheriff")) and obj.Parent == Workspace then
                gunTool = obj
                break
            end
        end
        if gunTool then
            local handle = gunTool:FindFirstChild("Handle")
            if handle then
                if not gunESPbox then
                    gunESPbox = Drawing.new("Square")
                    gunESPbox.Color = Color3.fromRGB(255,255,0)
                    gunESPbox.Thickness = 2
                    gunESPbox.Filled = false
                    gunESPbox.Visible = true
                end
                local cam = Workspace.CurrentCamera
                local pos, onScreen = cam:WorldToViewportPoint(handle.Position)
                if onScreen then
                    local size = Vector2.new(30, 30)
                    gunESPbox.Size = size
                    gunESPbox.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                    gunESPbox.Visible = true
                else
                    gunESPbox.Visible = false
                end
            else
                if gunESPbox then gunESPbox.Visible = false end
            end
        else
            if gunESPbox then
                gunESPbox.Visible = false
            end
        end
    else
        if gunESPbox then
            gunESPbox.Visible = false
            gunESPbox:Remove()
            gunESPbox = nil
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    for _, obj in ipairs(ESP_objects) do
        obj.box.Visible = false
        obj.box:Remove()
    end
    table.clear(ESP_objects)
    if gunESPbox then
        gunESPbox.Visible = false
        gunESPbox:Remove()
        gunESPbox = nil
    end
end)
