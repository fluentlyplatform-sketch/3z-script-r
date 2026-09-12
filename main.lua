-- 3Z ULTIMATE AIMLOCK (NEON EDITION)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local AIM_RANGE = 350
local enabled = false
local currentTarget = nil
local currentHighlight = nil
local targetPartName = "HumanoidRootPart"

local gui = Instance.new("ScreenGui")
gui.Name = "3Z_Neon_Gui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(160, 120)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2.5
stroke.Color = Color3.fromRGB(0, 230, 255)

task.spawn(function()
    local h = 0
    while task.wait(0.03) do
        h = (h + 0.005) % 1
        stroke.Color = Color3.fromHSV(h, 0.9, 1)
    end
end)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0.3, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ 3Z LOCK ⚡"
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(0, 230, 255)

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0.86, 0, 0.28, 0)
button.Position = UDim2.new(0.07, 0, 0.34, 0)
button.Text = "OFF [T]"
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.TextColor3 = Color3.new(1, 1, 1)
button.BackgroundColor3 = Color3.fromRGB(220, 30, 60)
button.BorderSizePixel = 0
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

local partButton = Instance.new("TextButton", frame)
partButton.Size = UDim2.new(0.86, 0, 0.24, 0)
partButton.Position = UDim2.new(0.07, 0, 0.68, 0)
partButton.Text = "Target: Body [H]"
partButton.Font = Enum.Font.GothamBold
partButton.TextScaled = true
partButton.TextColor3 = Color3.fromRGB(200, 200, 200)
partButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
partButton.BorderSizePixel = 0
Instance.new("UICorner", partButton).CornerRadius = UDim.new(0, 8)

local function clearHighlight()
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
    end
end

local function applyHighlight(character)
    clearHighlight()
    if not character then return end
    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(0, 255, 170)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.35
    hl.OutlineTransparency = 0
    hl.Adornee = character
    hl.Parent = character
    currentHighlight = hl
end

local function toggleScript()
    enabled = not enabled
    button.Text = enabled and "ON [T]" or "OFF [T]"
    button.BackgroundColor3 = enabled and Color3.fromRGB(0, 210, 106) or Color3.fromRGB(220, 30, 60)
    if not enabled then
        currentTarget = nil
        clearHighlight()
    end
end

local function toggleTargetPart()
    if targetPartName == "HumanoidRootPart" then
        targetPartName = "Head"
        partButton.Text = "Target: Head [H]"
    else
        targetPartName = "HumanoidRootPart"
        partButton.Text = "Target: Body [H]"
    end
end

button.Activated:Connect(toggleScript)
partButton.Activated:Connect(toggleTargetPart)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T then
        toggleScript()
    elseif input.KeyCode == Enum.KeyCode.H then
        toggleTargetPart()
    end
end)

local function getClosestPlayerToCrosshair()
    local myChar = player.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local closestPart = nil
    local shortestDistance = AIM_RANGE

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local hum = plr.Character:FindFirstChild("Humanoid")
            local targetPart = plr.Character:FindFirstChild(targetPartName) or plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and targetPart then
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    local worldDist = (myChar.HumanoidRootPart.Position - targetPart.Position).Magnitude
                    if worldDist <= AIM_RANGE and mouseDist < shortestDistance then
                        shortestDistance = mouseDist
                        closestPart = targetPart
                    end
                end
            end
        end
    end
    return closestPart
end

RunService.RenderStepped:Connect(function()
    if not enabled then return end
    local newTarget = getClosestPlayerToCrosshair()
    if newTarget then
        if not currentTarget or currentTarget.Parent ~= newTarget.Parent then
            applyHighlight(newTarget.Parent)
        end
        currentTarget = newTarget
        camera.CFrame = CFrame.new(camera.CFrame.Position, currentTarget.Position)
    else
        currentTarget = nil
        clearHighlight()
    end
end)