local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI Base Parent Fallback
local parentGui = CoreGui:FindFirstChild("RobloxGui") or localPlayer:WaitForChild("PlayerGui")

-- Clean up pre-existing instances
if parentGui:FindFirstChild("SitomanStudioHub") then
   parentGui.SitomanStudioHub:Destroy()
end

local PhantomUI = Instance.new("ScreenGui", parentGui)
PhantomUI.Name = "SitomanStudioHub"
PhantomUI.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame", PhantomUI)
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2

-- Header
local FullHeaderText = "MADE BY SITOMAN"
local HeaderText = Instance.new("TextLabel", MainFrame)
HeaderText.Size = UDim2.new(1, -50, 0, 35)
HeaderText.Position = UDim2.new(0, -10, 0, 8)
HeaderText.BackgroundTransparency = 1
HeaderText.Text = ""
HeaderText.TextTransparency = 1
HeaderText.Font = Enum.Font.GothamBold
HeaderText.TextSize = 12
HeaderText.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -34, 0, 12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

-- Toggle "S" Button
local ToggleButton = Instance.new("TextButton", PhantomUI)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0, 20, 0, 20)
ToggleButton.Text = "S"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 20
ToggleButton.Visible = false
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", ToggleButton).Color = Color3.fromRGB(255, 255, 255)

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, -24, 1, -55)
Container.Position = UDim2.new(0, 12, 0, 45)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 4
local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 8)
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
   Container.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 20)
end)

-- --- ENGINE STATE ---
local Settings = {
   AutoKill = false,
   CircleEnabled = false,
   ShootButtonEnabled = false,
   Radius = 200,
   BoxWidth = 150,
   BoxHeight = 300,
   UseBoxFOV = true,
   ESPEnabled = false,
   Target = nil,
   DebugHitboxes = false,
   HitboxSize = 5,
   RTXEnabled = false
}

local DebugHitboxes = Settings.DebugHitboxes
local HitboxSize = Settings.HitboxSize

-- Circular FOV Drawing (Safe Check)
local FOVCircle = nil
pcall(function()
   if Drawing then
       FOVCircle = Drawing.new("Circle")
       FOVCircle.Thickness = 2
       FOVCircle.NumSides = 64
       FOVCircle.Radius = Settings.Radius
       FOVCircle.Filled = false
       FOVCircle.Visible = false
   end
end)

-- FOV Rect Lines (Safe Check)
local RectLines = {}
pcall(function()
   if Drawing then
       RectLines = {
           Top = Drawing.new("Line"),
           Bottom = Drawing.new("Line"),
           Left = Drawing.new("Line"),
           Right = Drawing.new("Line")
       }
       for _, line in pairs(RectLines) do
           line.Thickness = 2
           line.Visible = false
       end
   end
end)

local function GetTargetPart(character)
   return character:FindFirstChild("Head")
end

-- Fungsi semakan pemain sah (Tanpa Team Check, hanya semak sama ada hidup dan bukan diri sendiri)
local function IsValidTarget(player)
   if player == localPlayer then return false end
   if not player.Character then return false end
   
   local humanoid = player.Character:FindFirstChild("Humanoid")
   local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
   
   if not humanoid or not targetHrp or humanoid.Health <= 0 then return false end
   
   return true
end

-- --- RTX SHADER CONTROLLER ---
local RTXStorage = { CreatedInstances = {}, OriginalSettings = {} }

local function ToggleRTX(state)
   Settings.RTXEnabled = state
   if state then
       RTXStorage.OriginalSettings = {
           Technology = Lighting.Technology,
           Brightness = Lighting.Brightness,
           GlobalShadows = Lighting.GlobalShadows,
           ClockTime = Lighting.ClockTime,
           ExposureCompensation = Lighting.ExposureCompensation,
           EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
           EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
       }
       pcall(function() Lighting.Technology = Enum.Technology.Future end)  
       Lighting.Brightness = 3  
       Lighting.GlobalShadows = true  
       Lighting.ClockTime = 14  
       Lighting.ExposureCompensation = 0.3  
       Lighting.EnvironmentDiffuseScale = 1  
       Lighting.EnvironmentSpecularScale = 1  

       local cc = Instance.new("ColorCorrectionEffect")  
       cc.Name = "SitomanRTX_CC"  
       cc.Brightness = 0.05; cc.Contrast = 0.2; cc.Saturation = 0.15; cc.Parent = Lighting  
       table.insert(RTXStorage.CreatedInstances, cc)  

       local bloom = Instance.new("BloomEffect")  
       bloom.Name = "SitomanRTX_Bloom"  
       bloom.Intensity = 0.3; bloom.Size = 32; bloom.Threshold = 0.9; bloom.Parent = Lighting  
       table.insert(RTXStorage.CreatedInstances, bloom)  

       local sun = Instance.new("SunRaysEffect")  
       sun.Name = "SitomanRTX_Sun"  
       sun.Intensity = 0.08; sun.Spread = 0.9; sun.Parent = Lighting  
       table.insert(RTXStorage.CreatedInstances, sun)  

       local atmosphere = Instance.new("Atmosphere")  
       atmosphere.Name = "SitomanRTX_Atmos"  
       atmosphere.Density = 0.35; atmosphere.Offset = 0; atmosphere.Color = Color3.fromRGB(210, 220, 255)  
       atmosphere.Decay = Color3.fromRGB(100, 120, 160); atmosphere.Glare = 1; atmosphere.Haze = 1.5; atmosphere.Parent = Lighting  
       table.insert(RTXStorage.CreatedInstances, atmosphere)  
   else  
       for _, obj in ipairs(RTXStorage.CreatedInstances) do  
           if obj and obj.Parent then obj:Destroy() end  
       end  
       RTXStorage.CreatedInstances = {}  
       if RTXStorage.OriginalSettings.Brightness then  
           pcall(function() Lighting.Technology = RTXStorage.OriginalSettings.Technology end)  
           Lighting.Brightness = RTXStorage.OriginalSettings.Brightness  
           Lighting.GlobalShadows = RTXStorage.OriginalSettings.GlobalShadows  
           Lighting.ClockTime = RTXStorage.OriginalSettings.ClockTime  
           Lighting.ExposureCompensation = RTXStorage.OriginalSettings.ExposureCompensation  
           Lighting.EnvironmentDiffuseScale = RTXStorage.OriginalSettings.EnvironmentDiffuseScale  
           Lighting.EnvironmentSpecularScale = RTXStorage.OriginalSettings.EnvironmentSpecularScale  
       end  
   end
end

-- --- ESP HIGHLIGHT CONTROLLER ---
local ESPFolder = Instance.new("Folder", parentGui)
ESPFolder.Name = "SitomanESPStorage"

local function UpdateESP()
   pcall(function()
       for _, player in ipairs(Players:GetPlayers()) do
           if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               local existingHighlight = ESPFolder:FindFirstChild(player.Name)
               if Settings.ESPEnabled then
                   if IsValidTarget(player) then
                       if not existingHighlight then
                           local highlight = Instance.new("Highlight")
                           highlight.Name = player.Name
                           highlight.FillColor = Color3.fromRGB(255, 50, 50)
                           highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                           highlight.FillTransparency = 0.5
                           highlight.OutlineTransparency = 0
                           highlight.Adornee = player.Character
                           highlight.Parent = ESPFolder
                       else
                           existingHighlight.Adornee = player.Character
                       end
                   elseif existingHighlight then
                       existingHighlight:Destroy()
                   end
               elseif existingHighlight then
                   existingHighlight:Destroy()
               end
           else
               local highlight = ESPFolder:FindFirstChild(player.Name)
               if highlight then highlight:Destroy() end
           end
       end
   end)
end

-- --- HITBOX EXPANDER CONTROLLER ---
local function UpdateHitboxes()
   pcall(function()
       for _, player in ipairs(Players:GetPlayers()) do
           if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               local hrp = player.Character.HumanoidRootPart
               if DebugHitboxes then
                   if IsValidTarget(player) then
                       hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                       hrp.Transparency = 0.4
                       hrp.Color = Color3.fromRGB(130, 0, 0)
                       hrp.Material = Enum.Material.Neon
                       hrp.CanCollide = false
                   else
                       hrp.Size = Vector3.new(2, 2, 1)
                       hrp.Transparency = 1
                   end
               else
                   hrp.Size = Vector3.new(2, 2, 1)
                   hrp.Transparency = 1
               end
           end
       end
   end)
end

-- --- MAIN RENDER LOOP & CHROMA ---
local SliderFillsList = {}

RunService:BindToRenderStep("SitomanEngine", Enum.RenderPriority.Camera.Value + 1, function()
   local hue = (tick() * 0.4) % 1
   local rgbColor = Color3.fromHSV(hue, 0.8, 1)

   pcall(function()
       MainStroke.Color = rgbColor  
       HeaderText.TextColor3 = rgbColor  
       ToggleButton.BackgroundColor3 = rgbColor  
       if FOVCircle then FOVCircle.Color = rgbColor end  
       for _, line in pairs(RectLines) do line.Color = rgbColor end  

       for _, fill in ipairs(SliderFillsList) do  
           if fill and fill.Parent then fill.BackgroundColor3 = rgbColor end  
       end  
   end)

   UpdateESP()  
   UpdateHitboxes()  

   -- --- AUTO KILL / AUTO FARM LOGIC ---
   if Settings.AutoKill then
       pcall(function()
           if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
               local myHrp = localPlayer.Character.HumanoidRootPart
               local closestTarget = nil
               local shortestDist = math.huge

               for _, player in ipairs(Players:GetPlayers()) do
                   if IsValidTarget(player) then
                       local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
                       if targetHrp then
                           local dist = (targetHrp.Position - myHrp.Position).Magnitude
                           if dist < shortestDist then
                               closestTarget = player
                               shortestDist = dist
                           end
                       end
                   end
               end

               if closestTarget and closestTarget.Character then
                   local targetHead = closestTarget.Character:FindFirstChild("Head")
                   local targetHrp = closestTarget.Character:FindFirstChild("HumanoidRootPart")
                   
                   if targetHrp and targetHead then
                       for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                           if part:IsA("BasePart") then part.CanCollide = false end
                       end
                       
                       myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 3.5, 0)
                       myHrp.Velocity = Vector3.new(0, 0, 0)
                       Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
                   end
               end
           end
       end)
   end

   local viewportSize = Camera.ViewportSize  
   local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)  

   -- Handle FOV Rendering  
   pcall(function()
       if Settings.CircleEnabled then  
           if Settings.UseBoxFOV then  
               if FOVCircle then FOVCircle.Visible = false end  
               local w, h = Settings.BoxWidth, Settings.BoxHeight  
               local topLeft = Vector2.new(center.X - w/2, center.Y - h/2)  
               local topRight = Vector2.new(center.X + w/2, center.Y - h/2)  
               local bottomLeft = Vector2.new(center.X - w/2, center.Y + h/2)  
               local bottomRight = Vector2.new(center.X + w/2, center.Y + h/2)  

               if RectLines.Top then  
                   RectLines.Top.From = topLeft; RectLines.Top.To = topRight; RectLines.Top.Visible = true  
                   RectLines.Bottom.From = bottomLeft; RectLines.Bottom.To = bottomRight; RectLines.Bottom.Visible = true  
                   RectLines.Left.From = topLeft; RectLines.Left.To = bottomLeft; RectLines.Left.Visible = true  
                   RectLines.Right.From = topRight; RectLines.Right.To = bottomRight; RectLines.Right.Visible = true  
               end  
           else  
               for _, line in pairs(RectLines) do line.Visible = false end  
               if FOVCircle then  
                   FOVCircle.Position = center  
                   FOVCircle.Radius = Settings.Radius  
                   FOVCircle.Visible = true  
               end  
           end  
       else  
           if FOVCircle then FOVCircle.Visible = false end  
           for _, line in pairs(RectLines) do line.Visible = false end  
       end  
   end)

   -- Target Acquisition Logic  
   pcall(function()
       if Settings.CircleEnabled or Settings.ShootButtonEnabled then  
           local ClosestPlayer = nil  
           local ShortestDist = math.huge  

           for _, player in ipairs(Players:GetPlayers()) do  
               if IsValidTarget(player) then  
                   local targetPart = GetTargetPart(player.Character)  
                   if targetPart then  
                       local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)  
                       if onScreen then  
                           local targetVec = Vector2.new(screenPos.X, screenPos.Y)  
                           local diff = targetVec - center  

                           local insideFOV = false  
                           if Settings.UseBoxFOV then  
                               insideFOV = math.abs(diff.X) <= (Settings.BoxWidth / 2) and math.abs(diff.Y) <= (Settings.BoxHeight / 2)  
                           else  
                               insideFOV = diff.Magnitude <= Settings.Radius  
                           end  

                           if insideFOV and diff.Magnitude < ShortestDist then  
                               ClosestPlayer = player  
                               ShortestDist = diff.Magnitude  
                           end  
                       end  
                   end  
               end  
           end  
           Settings.Target = ClosestPlayer  
       else  
           Settings.Target = nil  
       end  

       if Settings.Target and Settings.Target.Character then  
           local targetPart = GetTargetPart(Settings.Target.Character)  
           if targetPart then  
               Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)  
           end  
       end
   end)
end)

-- --- UI COMPONENT GENERATORS ---
local function CreateToggleButton(text, defaultState, callback)
   local state = defaultState
   local Btn = Instance.new("TextButton", Container)
   Btn.Size = UDim2.new(1, 0, 0, 40)
   Btn.BackgroundColor3 = state and Color3.fromRGB(230, 35, 35) or Color3.fromRGB(40, 40, 40)
   Btn.Text = text .. (state and " (ON)" or " (OFF)")
   Btn.TextColor3 = Color3.new(1, 1, 1)
   Btn.Font = Enum.Font.GothamMedium
   Btn.TextSize = 12
   Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)

   Btn.MouseButton1Click:Connect(function()  
       state = not state  
       Btn.BackgroundColor3 = state and Color3.fromRGB(230, 35, 35) or Color3.fromRGB(40, 40, 40)  
       Btn.Text = text .. (state and " (ON)" or " (OFF)")  
       
       local success, err = pcall(function()
           callback(state)
       end)
       if not success then
           warn("Callback Error: " .. tostring(err))
       end
   end)  
   return Btn
end

local function CreateSlider(text, min, max, default, callback)
   local SliderFrame = Instance.new("Frame", Container)
   SliderFrame.Size = UDim2.new(1, 0, 0, 45)
   SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
   Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 10)

   local Label = Instance.new("TextLabel", SliderFrame)  
   Label.Size = UDim2.new(1, -20, 0, 18); Label.Position = UDim2.new(0, 10, 0, 4)  
   Label.BackgroundTransparency = 1; Label.Text = text .. ": " .. default  
   Label.TextColor3 = Color3.new(1, 1, 1); Label.Font = Enum.Font.GothamMedium; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left  

   local SliderBar = Instance.new("Frame", SliderFrame)  
   SliderBar.Size = UDim2.new(1, -20, 0, 4); SliderBar.Position = UDim2.new(0, 10, 0, 28)  
   SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  
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
           dragging = true  
           updateSlider(input)  
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

-- --- CONSTRUCT FEATURES ---
CreateToggleButton("Auto Kill (Auto Farm)", false, function(v) Settings.AutoKill = v end)
CreateToggleButton("Target Lock Active", false, function(v) Settings.CircleEnabled = v end)
CreateToggleButton("Use Rectangular FOV", true, function(v) Settings.UseBoxFOV = v end)
CreateSlider("Circle Radius", 50, 800, 200, function(v) Settings.Radius = v end)
CreateSlider("Box Width", 50, 500, 150, function(v) Settings.BoxWidth = v end)
CreateSlider("Box Height", 100, 800, 300, function(v) Settings.BoxHeight = v end)

CreateToggleButton("Player ESP", false, function(v) Settings.ESPEnabled = v end)
CreateToggleButton("Debug Hitboxes", false, function(v)
   DebugHitboxes = v
   Settings.DebugHitboxes = v
end)
CreateSlider("Hitbox Size", 2, 20, 5, function(v)
   HitboxSize = v
   Settings.HitboxSize = v
end)
CreateToggleButton("RTX Shaders", false, function(v) ToggleRTX(v) end)

-- --- ANIMATED OPEN & CLOSE FLOW ---
local isBusy = false

local function animateHeader()
   HeaderText.Text = ""
   HeaderText.Position = UDim2.new(0, -10, 0, 8)
   HeaderText.TextTransparency = 1

   TweenService:Create(HeaderText, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {  
       Position = UDim2.new(0, 12, 0, 8),  
       TextTransparency = 0  
   }):Play()  

   task.spawn(function()  
       for i = 1, #FullHeaderText do  
           if not MainFrame.Visible then break end  
           HeaderText.Text = string.sub(FullHeaderText, 1, i)  
           task.wait(0.03)  
       end  
   end)
end

local function toggleUI()
   if isBusy then return end
   isBusy = true

   if not MainFrame.Visible then  
       MainFrame.Visible = true  
       ToggleButton.Visible = false  

       local openTween = TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {  
           Size = UDim2.new(0, 280, 0, 380)  
       })  
       openTween:Play()  
       animateHeader()  
       openTween.Completed:Wait()  
   else  
       local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {  
           Size = UDim2.new(0, 0, 0, 0)  
       })  
       closeTween:Play()  
       closeTween.Completed:Wait()  

       MainFrame.Visible = false  
       ToggleButton.Visible = true  
   end  

   isBusy = false
end

toggleUI()

CloseBtn.MouseButton1Click:Connect(toggleUI)
ToggleButton.MouseButton1Click:Connect(toggleUI)

UserInputService.InputBegan:Connect(function(input, processed)
   if not processed and input.KeyCode == Enum.KeyCode.P then
       toggleUI()
   end
end)

-- --- DRAGGING SYSTEM ---
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


