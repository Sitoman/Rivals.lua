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
   Target = nil,
   TargetLockEnabled = false,
   POVValue = 70,
   SpectateTarget = nil,
   SpectateEnabled = false
}

local function SaveSettings()
    pcall(function()
        if writefile and type(writefile) == "function" then
            local success, encoded = pcall(function()
                return HttpService:JSONEncode(Settings)
            end)
            if success then
                writefile(FileName, encoded)
            end
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
                    if Settings[k] ~= nil then
                        Settings[k] = v
                    end
                end
            end
        end
    end)
end

LoadSettings()

local parentGui = pcall(function() return CoreGui end) and CoreGui:FindFirstChild("RobloxGui") or localPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("SitomanStudioHub") then
   parentGui.SitomanStudioHub:Destroy()
end

pcall(function()
    RunService:UnbindFromRenderStep("SitomanEngine")
end)

local PhantomUI = Instance.new("ScreenGui", parentGui)
PhantomUI.Name = "SitomanStudioHub"
PhantomUI.ResetOnSpawn = false
PhantomUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local FOVGuiHolder = Instance.new("Frame", PhantomUI)
FOVGuiHolder.Size = UDim2.new(0, 400, 0, 400)
FOVGuiHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVGuiHolder.AnchorPoint = Vector2.new(0.5, 0.5)
FOVGuiHolder.BackgroundTransparency = 1

local FOVCircleFrame = Instance.new("Frame", FOVGuiHolder)
FOVCircleFrame.Size = UDim2.new(0, 400, 0, 400)
FOVCircleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircleFrame.BackgroundTransparency = 1
Instance.new("UICorner", FOVCircleFrame).CornerRadius = UDim.new(1, 0)
local UICircleStroke = Instance.new("UIStroke", FOVCircleFrame)
UICircleStroke.Thickness = 2
UICircleStroke.Color = Color3.fromRGB(255, 0, 0)

local CrosshairHolder = Instance.new("Frame", PhantomUI)
CrosshairHolder.Size = UDim2.new(0, 60, 0, 60)
CrosshairHolder.Position = UDim2.new(0.5, 0, 0.5, -25)
CrosshairHolder.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairHolder.BackgroundTransparency = 1

local CrosshairStrokes = {}
for i = 1, 4 do
    local Line = Instance.new("Frame", CrosshairHolder)
    Line.Size = UDim2.new(0, 3, 0, 12)
    Line.Position = UDim2.new(0.5, -1.5, 0.5, -6)
    Line.AnchorPoint = Vector2.new(0.5, 0.5)
    Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Line).CornerRadius = UDim.new(1, 0)
    
    if i == 1 then Line.Position = UDim2.new(0.5, 0, 0.5, -16)
    elseif i == 2 then Line.Position = UDim2.new(0.5, 16, 0.5, 0); Line.Rotation = 90
    elseif i == 3 then Line.Position = UDim2.new(0.5, 0, 0.5, 16)
    elseif i == 4 then Line.Position = UDim2.new(0.5, -16, 0.5, 0); Line.Rotation = 90 end
    table.insert(CrosshairStrokes, Line)
end

local MainFrame = Instance.new("Frame", PhantomUI)
MainFrame.Size = UDim2.new(0, 300, 0, 560)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
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
local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 8)
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
   Container.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 20)
end)

local function GetTargetPart(character)
   return character and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))
end

local function IsValidTarget(player)
   if player == localPlayer or not player.Character then return false end
   local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
   local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
   if not humanoid or not targetHrp or humanoid.Health <= 0 then return false end
   return true
end

RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = localPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if humanoid and hrp then
                if Settings.SpectateEnabled and Settings.SpectateTarget and Settings.SpectateTarget.Character then
                    local targetChar = Settings.SpectateTarget.Character
                    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                    if targetHrp then
                        hrp.CFrame = targetHrp.CFrame + Vector3.new(0, 5, 0)
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        humanoid.PlatformStand = true
                    end
                else
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
        end
    end)
end)

local ESPFolder = Instance.new("Folder", PhantomUI)
ESPFolder.Name = "SitomanESPStorage"
local TracersFolder = Instance.new("Folder", PhantomUI)
TracersFolder.Name = "SitomanTracersStorage"
local tracerLines, tracerTexts = {}, {}

local function GetOrCreateTracer(player)
    if not tracerLines[player] then
        local line = Instance.new("Frame", TracersFolder)
        line.BackgroundColor3 = Color3.fromRGB(255, 220, 50)
        line.BorderSizePixel = 0; line.ZIndex = 5; line.Visible = false
        tracerLines[player] = line
        
        local txt = Instance.new("TextLabel", TracersFolder)
        txt.BackgroundTransparency = 1; txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        txt.TextStrokeTransparency = 0.3; txt.Font = Enum.Font.Gotham; txt.TextSize = 11; txt.ZIndex = 6; txt.Visible = false
        tracerTexts[player] = txt
    end
    return tracerLines[player], tracerTexts[player]
end

local function UpdateESP()
   pcall(function()
       for _, player in ipairs(Players:GetPlayers()) do
           if player ~= localPlayer then
               local char = player.Character
               local existingHighlight = ESPFolder:FindFirstChild(player.Name)
               local line, txt = GetOrCreateTracer(player)
               
               if Settings.ESPEnabled and char and char:FindFirstChild("HumanoidRootPart") then
                   local humanoid = char:FindFirstChildOfClass("Humanoid")
                   if humanoid and humanoid.Health > 0 then
                       if not existingHighlight then
                           local highlight = Instance.new("Highlight")
                           highlight.Name = player.Name
                           highlight.FillColor = Color3.fromRGB(255, 50, 50)
                           highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                           highlight.FillTransparency = 0.5
                           highlight.Adornee = char
                           highlight.Parent = ESPFolder
                       else
                           existingHighlight.Adornee = char
                       end

                       local hrp = char.HumanoidRootPart
                       local localHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                       if hrp and localHrp then
                           local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                           local viewportSize = Camera.ViewportSize
                           local origin = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                           local destination = Vector2.new(screenPos.X, screenPos.Y)
                           local distance = (hrp.Position - localHrp.Position).Magnitude
                           local length = (destination - origin).Magnitude
                           
                           line.Size = UDim2.new(0, 2, 0, length)
                           line.Position = UDim2.new(0, origin.X, 0, origin.Y)
                           line.AnchorPoint = Vector2.new(0.5, 0)
                           line.Rotation = math.deg(math.atan2(destination.Y - origin.Y, destination.X - origin.X)) - 90
                           line.Visible = true

                           txt.Text = player.Name .. " [" .. math.floor(distance) .. " studs]"
                           txt.Position = UDim2.new(0, destination.X - 60, 0, destination.Y - 35)
                           txt.Size = UDim2.new(0, 120, 0, 15)
                           txt.Visible = true
                       else
                           line.Visible = false; txt.Visible = false
                       end
                   else
                       if existingHighlight then existingHighlight:Destroy() end
                       line.Visible = false; txt.Visible = false
                   end
               else
                   if existingHighlight then existingHighlight:Destroy() end
                   line.Visible = false; txt.Visible = false
               end
           end
       end
   end)
end

local SliderFillsList = {}
local SliderStrokesList = {}

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
       
       for _, line in ipairs(CrosshairStrokes) do line.BackgroundColor3 = rgbColor end
       for _, fill in ipairs(SliderFillsList) do if fill and fill.Parent then fill.BackgroundColor3 = rgbColor end end  
       for _, stroke in ipairs(SliderStrokesList) do if stroke and stroke.Parent then stroke.Color = rgbColor end end
   end)

   pcall(function() CrosshairHolder.Rotation = (CrosshairHolder.Rotation + (dt * 120)) % 360 end)
   pcall(function() if Camera then Camera.FieldOfView = Settings.POVValue end end)
   UpdateESP()  

   local activeCamera = workspace.CurrentCamera
   if not activeCamera then return end
   local viewportSize = activeCamera.ViewportSize  
   local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)  

   pcall(function()
       local diameter = Settings.Radius * 2
       FOVCircleFrame.Size = UDim2.new(0, diameter, 0, diameter)
   end)

   pcall(function()
       local ClosestPlayer = nil  
       local ShortestDist = math.huge  

       for _, player in ipairs(Players:GetPlayers()) do  
           if IsValidTarget(player) then  
               local targetPart = GetTargetPart(player.Character)  
               if targetPart then  
                   local screenPos, onScreen = activeCamera:WorldToViewportPoint(targetPart.Position)  
                   if onScreen then  
                       local targetVec = Vector2.new(screenPos.X, screenPos.Y)  
                       local diff = targetVec - center  
                       if diff.Magnitude <= Settings.Radius and diff.Magnitude < ShortestDist then  
                           ClosestPlayer = player  
                           ShortestDist = diff.Magnitude
                       end
                   end  
               end  
           end  
       end  
       Settings.Target = ClosestPlayer  

       if Settings.TargetLockEnabled and Settings.Target and Settings.Target.Character then  
           local targetPart = GetTargetPart(Settings.Target.Character)  
           if targetPart then  
               local screenPos, onScreen = activeCamera:WorldToViewportPoint(targetPart.Position)
               if onScreen and (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude <= Settings.Radius then
                   activeCamera.CFrame = CFrame.new(activeCamera.CFrame.Position, targetPart.Position)
               end
           end  
       end
   end)
end)

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

CreateToggleButton("Speed", Settings.SpeedEnabled, function(v) Settings.SpeedEnabled = v; SaveSettings() end)
CreateSlider("Speed Value", 16, 200, Settings.SpeedValue, function(v) Settings.SpeedValue = v; SaveSettings() end)
CreateSlider("Circle Radius / FOV", 50, 800, Settings.Radius, function(v) Settings.Radius = v; SaveSettings() end)
CreateToggleButton("Player ESP", Settings.ESPEnabled, function(v) Settings.ESPEnabled = v; SaveSettings() end)

local StopFreezeBtn = Instance.new("TextButton", Container)
StopFreezeBtn.Size = UDim2.new(1, 0, 0, 35)
StopFreezeBtn.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
StopFreezeBtn.Text = "OFF FREEZE AND INFINITY LOOP [OFF]"
StopFreezeBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
StopFreezeBtn.Font = Enum.Font.GothamBold
StopFreezeBtn.TextSize = 11
Instance.new("UICorner", StopFreezeBtn).CornerRadius = UDim.new(0, 8)
local StopStroke = Instance.new("UIStroke", StopFreezeBtn)
StopStroke.Thickness = 1.5
table.insert(SliderStrokesList, StopStroke)

StopFreezeBtn.MouseButton1Click:Connect(function()
    Settings.SpectateEnabled = false
    Settings.SpectateTarget = nil
    StopFreezeBtn.Text = "OFF FREEZE AND INFINITY LOOP [OFF]"
end)

local TpLabel = Instance.new("TextLabel", Container)
TpLabel.Size = UDim2.new(1, 0, 0, 20)
TpLabel.BackgroundTransparency = 1
TpLabel.Text = "CLICK TO FREEZE OVERHEAD PLAYER"
TpLabel.TextColor3 = Color3.fromRGB(150, 180, 255)
TpLabel.Font = Enum.Font.GothamBold
TpLabel.TextSize = 10
TpLabel.TextXAlignment = Enum.TextXAlignment.Center

local PlayerListContainer = Instance.new("ScrollingFrame", Container)
PlayerListContainer.Size = UDim2.new(1, 0, 0, 130)
PlayerListContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
PlayerListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListContainer.ScrollBarThickness = 3
Instance.new("UICorner", PlayerListContainer).CornerRadius = UDim.new(0, 8)
local ListStroke = Instance.new("UIStroke", PlayerListContainer)
ListStroke.Thickness = 1.2
table.insert(SliderStrokesList, ListStroke)

local ListLayout = Instance.new("UIListLayout", PlayerListContainer)
ListLayout.Padding = UDim.new(0, 4)

local function RefreshPlayerList()
    for _, child in ipairs(PlayerListContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local players = Players:GetPlayers()
    local count = 0
    for _, p in ipairs(players) do
        if p ~= localPlayer then
            count = count + 1
            local pBtn = Instance.new("TextButton", PlayerListContainer)
            pBtn.Size = UDim2.new(1, -4, 0, 30)
            pBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
            pBtn.Text = "  > " .. p.Name
            pBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
            pBtn.Font = Enum.Font.Gotham
            pBtn.TextSize = 12
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 6)
            
            pBtn.MouseButton1Click:Connect(function()
                Settings.SpectateTarget = p
                Settings.SpectateEnabled = true
                StopFreezeBtn.Text = "OFF FREEZE (" .. p.Name .. ") [ON]"
            end)
        end
    end
    PlayerListContainer.CanvasSize = UDim2.new(0, 0, 0, count * 34)
end

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)
task.spawn(RefreshPlayerList)

LockButton.MouseButton1Click:Connect(function()
    Settings.TargetLockEnabled = not Settings.TargetLockEnabled
    LockButton.Text = Settings.TargetLockEnabled and "Lock: ON" or "Lock: OFF"
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
