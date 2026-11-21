local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local FileName = "SitomanStudioHub_Config.json"
local Settings = {
   SpeedEnabled = false,
   SpeedValue = 16,
   Radius = 200,
   ESPEnabled = false,
   NameHealthESP = false,
   Target = nil,
   TargetLockEnabled = false,
   POVValue = 70,
   HitboxEnabled = false,
   HitboxSize = 2,
   LockPart = "Head",
   FullbrightEnabled = false
}

local DefaultLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd
}

local function SaveSettings()
    pcall(function()
        if writefile and type(writefile) == "function" then
            local success, encoded = pcall(function()
                return HttpService:JSONEncode(Settings)
            end)
            if success then writefile(FileName, encoded) end
        end
    end)
end

local function LoadSettings()
    pcall(function()
        if readfile and isfile and isfile(FileName) then
            local content = readfile(FileName)
            local success, decoded = pcall(function()
                return HttpService:JSONDecode(content)
            end)
            if success and type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if Settings[k] ~= nil then Settings[k] = v end
                end
            end
        end
    end)
end
LoadSettings()

local function GetSafeGuiParent()
    local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        return playerGui
    end

    local okCore, core = pcall(function() return CoreGui end)
    if okCore and core then
        local okProtect, _ = pcall(function()
            local testFolder = Instance.new("Folder")
            testFolder.Name = "SitomanTest"
            testFolder.Parent = core
            testFolder:Destroy()
        end)
        if okProtect then
            return core
        end
    end

    return localPlayer:WaitForChild("PlayerGui")
end

local parentGui = GetSafeGuiParent()

if parentGui:FindFirstChild("SitomanStudioHub") then
   parentGui.SitomanStudioHub:Destroy()
end

pcall(function() RunService:UnbindFromRenderStep("SitomanEngine") end)

local PhantomUI = Instance.new("ScreenGui")
PhantomUI.Name = "SitomanStudioHub"
PhantomUI.ResetOnSpawn = false
PhantomUI.DisplayOrder = 999999
PhantomUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
PhantomUI.Parent = parentGui

-- Paparan Status Very Smart Lock di Sebelah Kanan Skrin
local LockStatusFrame = Instance.new("Frame", PhantomUI)
LockStatusFrame.Name = "SmartLockStatus"
LockStatusFrame.Size = UDim2.new(0, 195, 0, 34)
LockStatusFrame.Position = UDim2.new(1, -210, 0.5, -17)
LockStatusFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
LockStatusFrame.BackgroundTransparency = 0.2
LockStatusFrame.Visible = false
Instance.new("UICorner", LockStatusFrame).CornerRadius = UDim.new(0, 8)
local LockStatusStroke = Instance.new("UIStroke", LockStatusFrame)
LockStatusStroke.Thickness = 1.8

local LockStatusLabel = Instance.new("TextLabel", LockStatusFrame)
LockStatusLabel.Size = UDim2.new(1, -12, 1, 0)
LockStatusLabel.Position = UDim2.new(0, 6, 0, 0)
LockStatusLabel.BackgroundTransparency = 1
LockStatusLabel.Text = ""
LockStatusLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
LockStatusLabel.Font = Enum.Font.GothamBold
LockStatusLabel.TextSize = 11
LockStatusLabel.TextTruncate = Enum.TextTruncate.AtEnd
LockStatusLabel.TextXAlignment = Enum.TextXAlignment.Center

-- FOV Circle
local FOVGuiHolder = Instance.new("Frame", PhantomUI)
FOVGuiHolder.Size = UDim2.new(0, 400, 0, 400)
FOVGuiHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVGuiHolder.AnchorPoint = Vector2.new(0.5, 0.5)
FOVGuiHolder.BackgroundTransparency = 1
FOVGuiHolder.Active = false

local FOVCircleFrame = Instance.new("Frame", FOVGuiHolder)
FOVCircleFrame.Size = UDim2.new(0, 400, 0, 400)
FOVCircleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircleFrame.BackgroundTransparency = 1
FOVCircleFrame.Active = false
Instance.new("UICorner", FOVCircleFrame).CornerRadius = UDim.new(1, 0)
local UICircleStroke = Instance.new("UIStroke", FOVCircleFrame)
UICircleStroke.Thickness = 2
UICircleStroke.Color = Color3.fromRGB(255, 0, 0)

local MainFrame = Instance.new("Frame", PhantomUI)
MainFrame.Size = UDim2.new(0, 300, 0, 470)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 3.5

local HeaderText = Instance.new("TextLabel", MainFrame)
HeaderText.Size = UDim2.new(1, -50, 0, 35)
HeaderText.Position = UDim2.new(0, 14, 0, 10)
HeaderText.BackgroundTransparency = 1
HeaderText.Text = "SITOMAN ULTRA RGB HUB"
HeaderText.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderText.Font = Enum.Font.GothamBold
HeaderText.TextSize = 13
HeaderText.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -36, 0, 12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

local ToggleButton = Instance.new("TextButton", PhantomUI)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0, 20, 0, 20)
ToggleButton.Text = "S"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 20
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)
local ToggleButtonStroke = Instance.new("UIStroke", ToggleButton)
ToggleButtonStroke.Thickness = 3

local LockButton = Instance.new("TextButton", PhantomUI)
LockButton.Size = UDim2.new(0, 100, 0, 36)
LockButton.Position = UDim2.new(0, 75, 0, 12)
LockButton.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
LockButton.Text = Settings.TargetLockEnabled and "Lock: ON" or "Lock: OFF"
LockButton.TextColor3 = Color3.fromRGB(240, 240, 240)
LockButton.Font = Enum.Font.GothamBold
LockButton.TextSize = 11
Instance.new("UICorner", LockButton).CornerRadius = UDim.new(0, 8)
local LockStroke = Instance.new("UIStroke", LockButton)
LockStroke.Thickness = 2

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 48)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 3
Container.Active = true
local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 8)
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
   Container.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 20)
end)

local SliderFillsList = {}
local SliderStrokesList = {}

local function CreateToggleButton(text, defaultState, callback)
   local state = defaultState
   local Btn = Instance.new("TextButton", Container)
   Btn.Size = UDim2.new(1, 0, 0, 40)
   Btn.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
   Btn.Text = text .. (state and " [ON]" or " [OFF]")
   Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
   Btn.Font = Enum.Font.GothamMedium
   Btn.TextSize = 12
   Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
   
   local stroke = Instance.new("UIStroke", Btn)
   stroke.Thickness = 1.8; stroke.Color = Color3.fromRGB(255, 255, 255)
   table.insert(SliderStrokesList, stroke)

   Btn.MouseButton1Click:Connect(function()  
       state = not state  
       Btn.Text = text .. (state and " [ON]" or " [OFF]")  
       pcall(function() callback(state) end)
   end)  
   return Btn
end

local function CreateSlider(text, min, max, default, callback)
   local SliderFrame = Instance.new("Frame", Container)
   SliderFrame.Size = UDim2.new(1, 0, 0, 45)
   SliderFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
   Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

   local frameStroke = Instance.new("UIStroke", SliderFrame)
   frameStroke.Thickness = 1.2
   table.insert(SliderStrokesList, frameStroke)

   local Label = Instance.new("TextLabel", SliderFrame)  
   Label.Size = UDim2.new(1, -20, 0, 18); Label.Position = UDim2.new(0, 10, 0, 4)  
   Label.BackgroundTransparency = 1; Label.Text = text .. ": " .. default  
   Label.TextColor3 = Color3.fromRGB(220, 220, 220); Label.Font = Enum.Font.GothamMedium; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left  

   local SliderBar = Instance.new("Frame", SliderFrame)  
   SliderBar.Size = UDim2.new(1, -20, 0, 4); SliderBar.Position = UDim2.new(0, 10, 0, 28)  
   SliderBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)  
   Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)  

   local SliderFill = Instance.new("Frame", SliderBar)  
   SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)  
   Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)  
   table.insert(SliderFillsList, SliderFill)  

   local function updateSlider(input)  
       local percentage = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)  
       SliderFill.Size = UDim2.new(percentage, 0, 1, 0)  
       local value = math.floor(min + (percentage * (max - min)))  
       Label.Text = text .. ": " .. value  
       pcall(function() callback(value) end)  
   end  

   local dragging = false  
   SliderBar.InputBegan:Connect(function(input)  
       if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
           dragging = true; updateSlider(input)  
       end  
   end)  
   UserInputService.InputChanged:Connect(function(input)  
       if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then  
           updateSlider(input)  
       end  
   end)  
   UserInputService.InputEnded:Connect(function(input)  
       if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
           dragging = false  
       end  
   end)
end

-- WIDGET GUI
CreateToggleButton("Speed", Settings.SpeedEnabled, function(v) Settings.SpeedEnabled = v; SaveSettings() end)
CreateSlider("Speed Value", 16, 200, Settings.SpeedValue, function(v) Settings.SpeedValue = v; SaveSettings() end)
CreateSlider("Circle Radius / FOV", 50, 800, Settings.Radius, function(v) Settings.Radius = v; SaveSettings() end)
CreateToggleButton("Player ESP", Settings.ESPEnabled, function(v) Settings.ESPEnabled = v; SaveSettings() end)
CreateToggleButton("Name & Health ESP", Settings.NameHealthESP, function(v) Settings.NameHealthESP = v; SaveSettings() end)

local partsList = {"Head", "HumanoidRootPart", "UpperTorso"}
local currentPartIdx = 1

local LockPartBtn = Instance.new("TextButton", Container)
LockPartBtn.Size = UDim2.new(1, 0, 0, 40)
LockPartBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
LockPartBtn.Text = "Lock Target: " .. Settings.LockPart
LockPartBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
LockPartBtn.Font = Enum.Font.GothamMedium
LockPartBtn.TextSize = 12
Instance.new("UICorner", LockPartBtn).CornerRadius = UDim.new(0, 8)
local LockPartStroke = Instance.new("UIStroke", LockPartBtn)
LockPartStroke.Thickness = 1.8
table.insert(SliderStrokesList, LockPartStroke)

LockPartBtn.MouseButton1Click:Connect(function()
    currentPartIdx = currentPartIdx % #partsList + 1
    Settings.LockPart = partsList[currentPartIdx]
    LockPartBtn.Text = "Lock Target: " .. Settings.LockPart
    SaveSettings()
end)

CreateToggleButton("Hitbox Extender", Settings.HitboxEnabled, function(v) Settings.HitboxEnabled = v; SaveSettings() end)
CreateSlider("Hitbox Size", 1, 10, Settings.HitboxSize, function(v) Settings.HitboxSize = v; SaveSettings() end)
CreateToggleButton("Fullbright / Bright Map", Settings.FullbrightEnabled, function(v) Settings.FullbrightEnabled = v; SaveSettings() end)

local function GetTargetPart(character)
   if not character then return nil end
   return character:FindFirstChild(Settings.LockPart) 
       or character:FindFirstChild("Head") 
       or character:FindFirstChild("HumanoidRootPart") 
       or character:FindFirstChild("Torso")
end

local function IsEnemyByTeam(player)
    if not player or player == localPlayer then return false end
    if localPlayer.Team and player.Team then
        return localPlayer.Team ~= player.Team
    end
    return true
end

local function IsValidTarget(player)
   if not player or player == localPlayer or not player.Parent then return false end
   if not player.Character then return false end
   local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
   local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
   if not humanoid or not targetHrp or humanoid.Health <= 0 then return false end
   return IsEnemyByTeam(player)
end

local function FindBestTargetInFOV(activeCamera, center)
   local bestPlayer = nil
   local bestScore = math.huge

   for _, player in ipairs(Players:GetPlayers()) do
       if IsValidTarget(player) then
           local targetPart = GetTargetPart(player.Character)
           if targetPart then
               local screenPos, onScreen = activeCamera:WorldToViewportPoint(targetPart.Position)
               if onScreen and screenPos.Z > 0 then
                   local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                   if distFromCenter <= Settings.Radius then
                       local worldDist = (activeCamera.CFrame.Position - targetPart.Position).Magnitude
                       local score = distFromCenter + (worldDist * 0.05)
                       if score < bestScore then
                           bestPlayer = player
                           bestScore = score
                       end
                   end
               end
           end
       end
   end

   return bestPlayer
end

RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = localPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if humanoid and hrp then
                humanoid.PlatformStand = false
                if Settings.SpeedEnabled then
                    humanoid.WalkSpeed = Settings.SpeedValue
                    if humanoid.MoveDirection.Magnitude > 0 then
                        local currentVelocity = hrp.AssemblyLinearVelocity
                        local moveDir = humanoid.MoveDirection
                        hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * Settings.SpeedValue, currentVelocity.Y, moveDir.Z * Settings.SpeedValue)
                    end
                else
                    humanoid.WalkSpeed = 16
                end
            end
        end

        if Settings.FullbrightEnabled then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 100.0
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
        else
            Lighting.Ambient = DefaultLighting.Ambient
            Lighting.Brightness = DefaultLighting.Brightness
            Lighting.GlobalShadows = DefaultLighting.GlobalShadows
            Lighting.FogEnd = DefaultLighting.FogEnd
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if Settings.HitboxEnabled then
                        hrp.Size = Vector3.new(2, 2, 1) * Settings.HitboxSize
                        hrp.Transparency = 0.88
                        hrp.BrickColor = BrickColor.new("Bright red")
                        hrp.Material = Enum.Material.SmoothPlastic
                        hrp.CanCollide = false
                    else
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 1
                        hrp.CanCollide = true
                    end
                end
            end
        end
    end)
end)

local ESPFolder = Instance.new("Folder", PhantomUI)
ESPFolder.Name = "SitomanESPStorage"
local NameHealthFolder = Instance.new("Folder", PhantomUI)
NameHealthFolder.Name = "SitomanNameHealthStorage"

local function UpdateESP(activeCamera)
   pcall(function()
       for _, player in ipairs(Players:GetPlayers()) do
           if player ~= localPlayer then
               local char = player.Character
               local existingHighlight = ESPFolder:FindFirstChild(player.Name)
               local existingText = NameHealthFolder:FindFirstChild(player.Name)
               local humanoid = char and char:FindFirstChildOfClass("Humanoid")
               local alive = char and humanoid and char:FindFirstChild("HumanoidRootPart") and humanoid.Health > 0

               if Settings.ESPEnabled and alive then
                   if not existingHighlight then
                       local highlight = Instance.new("Highlight")
                       highlight.Name = player.Name
                       highlight.FillColor = Color3.fromRGB(220, 70, 70)
                       highlight.OutlineColor = Color3.fromRGB(235, 235, 235)
                       highlight.FillTransparency = 0.78
                       highlight.OutlineTransparency = 0.35
                       highlight.Adornee = char
                       highlight.Parent = ESPFolder
                   else
                       existingHighlight.Adornee = char
                       existingHighlight.FillTransparency = 0.78
                       existingHighlight.OutlineTransparency = 0.35
                   end
               elseif existingHighlight then
                   existingHighlight:Destroy()
               end

               if Settings.NameHealthESP and alive and char:FindFirstChild("Head") then
                   local txtLabel = existingText
                   if not txtLabel then
                       txtLabel = Instance.new("TextLabel", NameHealthFolder)
                       txtLabel.Name = player.Name
                       txtLabel.BackgroundTransparency = 1
                       txtLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
                       txtLabel.TextStrokeTransparency = 0.35
                       txtLabel.Font = Enum.Font.GothamBold
                       txtLabel.TextSize = 11
                       txtLabel.Size = UDim2.new(0, 150, 0, 30)
                   end
                   local head = char.Head
                   local screenPos, onScreen = activeCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
                   if onScreen and screenPos.Z > 0 then
                       txtLabel.Text = player.Name .. " | HP: " .. math.floor(humanoid.Health)
                       txtLabel.Position = UDim2.new(0, screenPos.X - 75, 0, screenPos.Y - 15)
                       txtLabel.Visible = true
                   else
                       txtLabel.Visible = false
                   end
               elseif existingText then
                   existingText:Destroy()
               end
           end
       end
   end)
end

RunService:BindToRenderStep("SitomanEngine", Enum.RenderPriority.Camera.Value + 1, function(dt)
   local hue = (tick() * 0.4) % 1
   local rgbColor = Color3.fromHSV(hue, 0.9, 1)

   pcall(function()
       MainStroke.Color = rgbColor  
       HeaderText.TextColor3 = rgbColor  
       ToggleButton.BackgroundColor3 = rgbColor  
       ToggleButtonStroke.Color = rgbColor
       LockButton.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
       LockStroke.Color = rgbColor
       UICircleStroke.Color = rgbColor
       LockStatusStroke.Color = rgbColor
       
       for _, fill in ipairs(SliderFillsList) do if fill and fill.Parent then fill.BackgroundColor3 = rgbColor end end  
       for _, stroke in ipairs(SliderStrokesList) do if stroke and stroke.Parent then stroke.Color = rgbColor end end
   end)

   pcall(function()
       local activeCam = workspace.CurrentCamera
       if activeCam then activeCam.FieldOfView = Settings.POVValue end
   end)

   local activeCamera = workspace.CurrentCamera
   if not activeCamera then return end
   UpdateESP(activeCamera)  

   local viewportSize = activeCamera.ViewportSize  
   local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)  

   pcall(function()
       local diameter = Settings.Radius * 2
       FOVCircleFrame.Size = UDim2.new(0, diameter, 0, diameter)
   end)

   pcall(function()
       if not Settings.TargetLockEnabled then
           LockStatusFrame.Visible = false
           return
       end

       if not IsValidTarget(Settings.Target) then
           Settings.Target = FindBestTargetInFOV(activeCamera, center)
       end

       if Settings.Target and IsValidTarget(Settings.Target) and Settings.Target.Character then
           local targetPart = GetTargetPart(Settings.Target.Character)
           if targetPart then
               LockStatusLabel.Text = "Locked at " .. Settings.Target.Name
               LockStatusFrame.Visible = true
               activeCamera.CFrame = CFrame.new(activeCamera.CFrame.Position, targetPart.Position)
           else
               LockStatusFrame.Visible = false
           end
       else
           LockStatusFrame.Visible = false
       end
   end)
end)

LockButton.MouseButton1Click:Connect(function()
    Settings.TargetLockEnabled = not Settings.TargetLockEnabled
    LockButton.Text = Settings.TargetLockEnabled and "Lock: ON" or "Lock: OFF"
    if not Settings.TargetLockEnabled then
        Settings.Target = nil
        LockStatusFrame.Visible = false
    end
    SaveSettings()
end)

local isOpen = true
local function toggleUI()
   isOpen = not isOpen
   MainFrame.Visible = isOpen
end

CloseBtn.MouseButton1Click:Connect(toggleUI)
ToggleButton.MouseButton1Click:Connect(toggleUI)

local function MakeDraggable(obj)
   local drag, startPos, inputStart
   obj.InputBegan:Connect(function(i)
       if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
           drag = true; startPos = obj.Position; inputStart = i.Position
       end
   end)
   UserInputService.InputChanged:Connect(function(i)
       if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
           obj.Position = startPos + UDim2.new(0, i.Position.X - inputStart.X, 0, i.Position.Y - inputStart.Y)
       end
   end)
   UserInputService.InputEnded:Connect(function(i)
       if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
           drag = false
       end
   end)
end

MakeDraggable(MainFrame)
MakeDraggable(ToggleButton)
MakeDraggable(LockButton)
