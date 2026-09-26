--====================================================================
-- VOID OVERLORD - V8.3 (ROAR & SHOCKWAVE UPDATE)
-- Updated
--====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer

--====================================================================
-- 1. BẢNG ANIMATION ID
--====================================================================
local AnimIDs = {
    Idle = "rbxassetid://93326430026112",      
    Run = "rbxassetid://139307201297469",       
    Cast = "rbxassetid://129478724915743",      
    Shift = "rbxassetid://133631846764964",     
    Ultimate = "rbxassetid://75767173951160"   
}

--====================================================================
-- 2. DỌN UI RÁC & BẢO VỆ
--====================================================================
local function cleanOldGUI()
    pcall(function()
        for _, v in ipairs(CoreGui:GetChildren()) do if v.Name == "VoidOverlordHub" then v:Destroy() end end
        for _, v in ipairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do if v.Name == "VoidOverlordHub" then v:Destroy() end end
        if gethui then for _, v in ipairs(gethui():GetChildren()) do if v.Name == "VoidOverlordHub" then v:Destroy() end end end
    end)
end
cleanOldGUI()

pcall(function()
    if hookmetamethod and checkcaller then
        local oldIndex; oldIndex = hookmetamethod(game, "__index", function(self, key)
            if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") then
                if key == "WalkSpeed" then return 16 end
                if key == "JumpPower" then return 50 end
            end
            return oldIndex(self, key)
        end)
        local oldNewIndex; oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
            if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") then
                if key == "WalkSpeed" or key == "JumpPower" then return end
            end
            return oldNewIndex(self, key, value)
        end)
    end
end)

local isExecuting = false
local voidDomainActive = false
local chamsEnabled = false

local holeCooldown = false
local shiftCooldown = false
local domainCooldown = false

--====================================================================
-- 3. HÀM HỖ TRỢ VFX SIÊU CẤP & UI BẢO VỆ
--====================================================================
local function GetCharacterParts()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    local anim = hum:WaitForChild("Animator")
    return char, hum, root, anim
end

local function protectUI(gui)
    local success = pcall(function() gui.Parent = gethui() end)
    if not success then pcall(function() gui.Parent = CoreGui end)
        if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    end
end

local function PlayBlinkEffect(callback)
    local blinkGui = Instance.new("ScreenGui")
    blinkGui.Name = "BlinkEffectGui"
    blinkGui.IgnoreGuiInset = true 
    protectUI(blinkGui)
    
    local topLid = Instance.new("Frame", blinkGui)
    topLid.BackgroundColor3 = Color3.new(0, 0, 0); topLid.BorderSizePixel = 0
    topLid.Size = UDim2.new(1.2, 0, 0.6, 0); topLid.Position = UDim2.new(-0.1, 0, -0.6, 0)
    
    local botLid = Instance.new("Frame", blinkGui)
    botLid.BackgroundColor3 = Color3.new(0, 0, 0); botLid.BorderSizePixel = 0
    botLid.Size = UDim2.new(1.2, 0, 0.6, 0); botLid.Position = UDim2.new(-0.1, 0, 1, 0)
    
    TweenService:Create(topLid, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {Position = UDim2.new(-0.1, 0, 0, 0)}):Play()
    TweenService:Create(botLid, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {Position = UDim2.new(-0.1, 0, 0.4, 0)}):Play()
    
    task.wait(0.3)
    if callback then callback() end
    
    TweenService:Create(topLid, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {Position = UDim2.new(-0.1, 0, -0.6, 0)}):Play()
    TweenService:Create(botLid, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {Position = UDim2.new(-0.1, 0, 1, 0)}):Play()
    task.delay(0.4, function() blinkGui:Destroy() end)
end

local function PlayTrackSafely(animId, priority)
    if not animId or animId == "" then return nil end
    local success, track = pcall(function()
        local _, _, _, anim = GetCharacterParts()
        local animObj = Instance.new("Animation")
        animObj.AnimationId = animId
        local tr = anim:LoadAnimation(animObj)
        tr.Priority = priority or Enum.AnimationPriority.Action
        tr.Looped = false
        tr:Play()
        tr:AdjustSpeed(3)
        return tr
    end)
    if success then return track end
end

local function ChangeDefaultAnimation(char, animName, newId)
    if not newId or newId == "" then return end
    local animateScript = char:FindFirstChild("Animate")
    if animateScript then
        local animValue = animateScript:FindFirstChild(animName)
        if animValue then
            for _, animObj in ipairs(animValue:GetChildren()) do
                if animObj:IsA("Animation") then animObj.AnimationId = newId end
            end
        end
    end
end

local function RefreshAnimateScript(char)
    local animateScript = char:FindFirstChild("Animate")
    local hum = char:FindFirstChild("Humanoid")
    local animator = hum and hum:FindFirstChild("Animator")
    if animateScript then
        animateScript.Disabled = true
        if animator then for _, track in ipairs(animator:GetPlayingAnimationTracks()) do track:Stop(0) end end
        task.wait(0.05)
        animateScript.Disabled = false
    end
end

local function SpawnVoidAura(part)
    if part:FindFirstChild("VoidPermanentAura") then return end
    local att = Instance.new("Attachment", part)
    att.Name = "VoidPermanentAura"
    local pe = Instance.new("ParticleEmitter", att)
    pe.Texture = "rbxassetid://243098098"
    pe.Color = ColorSequence.new(Color3.fromRGB(190, 40, 255), Color3.fromRGB(20, 0, 50))
    pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 0)})
    pe.Lifetime = NumberRange.new(0.6, 1.2)
    pe.Rate = 60
    pe.Speed = NumberRange.new(2, 5)
    pe.SpreadAngle = Vector2.new(360, 360)
end

local function SpawnGhost(char, cframe, duration)
    local ghost = Instance.new("Model")
    ghost.Name = "VoidGhost"
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local p = part:Clone()
            p.Anchored = true; p.CanCollide = false
            p.Material = Enum.Material.ForceField
            p.Color = Color3.fromRGB(170, 0, 255)
            p.CFrame = cframe * char.HumanoidRootPart.CFrame:ToObjectSpace(part.CFrame)
            for _, c in ipairs(p:GetChildren()) do
                if not c:IsA("SpecialMesh") then c:Destroy() end
            end
            p.Parent = ghost
            TweenService:Create(p, TweenInfo.new(duration), {Transparency = 1}):Play()
        end
    end
    ghost.Parent = workspace
    Debris:AddItem(ghost, duration)
end

local function SpawnZap(p1, p2)
    local dist = (p1 - p2).Magnitude
    local zap = Instance.new("Part")
    zap.Size = Vector3.new(0.3, dist, 0.3)
    zap.Material = Enum.Material.Neon
    zap.Color = Color3.fromRGB(200, 100, 255)
    zap.CanCollide = false; zap.Anchored = true
    zap.CFrame = CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -dist/2)
    zap.Parent = workspace
    TweenService:Create(zap, TweenInfo.new(0.25), {Size = Vector3.new(0, dist, 0), Transparency = 1}):Play()
    Debris:AddItem(zap, 0.25)
end

local function CreateShockwaveRing(pos, color, endSize, duration)
    local ring = Instance.new("Part")
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.2, 1, 1)
    ring.Material = Enum.Material.Neon
    ring.Color = color
    ring.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
    ring.CanCollide = false; ring.Anchored = true
    ring.Parent = workspace
    TweenService:Create(ring, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.2, endSize, endSize),
        Transparency = 1
    }):Play()
    Debris:AddItem(ring, duration)
end

--====================================================================
-- 4. GIAO DIỆN
--====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidOverlordHub"
ScreenGui.ResetOnSpawn = false
protectUI(ScreenGui)

local IntroFrame = Instance.new("Frame", ScreenGui)
IntroFrame.Size = UDim2.new(0, 420, 0, 240)
IntroFrame.Position = UDim2.new(0.5, -210, 0.5, -120)
IntroFrame.BackgroundColor3 = Color3.fromRGB(12, 6, 22)
IntroFrame.BorderSizePixel = 0
Instance.new("UICorner", IntroFrame).CornerRadius = UDim.new(0, 16)

local IntroStroke = Instance.new("UIStroke", IntroFrame)
IntroStroke.Color = Color3.fromRGB(160, 30, 255)
IntroStroke.Thickness = 2.5

local IntroGlow = Instance.new("ImageLabel", IntroFrame)
IntroGlow.Size = UDim2.new(1, 60, 1, 60)
IntroGlow.Position = UDim2.new(0, -30, 0, -30)
IntroGlow.BackgroundTransparency = 1
IntroGlow.Image = "rbxassetid://6014261993"
IntroGlow.ImageColor3 = Color3.fromRGB(130, 0, 255)
IntroGlow.ImageTransparency = 0.6

local TitleLabel = Instance.new("TextLabel", IntroFrame)
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.Position = UDim2.new(0, 0, 0.1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "VOID OVERLORD [NoCD!]"
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 30
TitleLabel.TextColor3 = Color3.fromRGB(200, 100, 255)

local SubTitleLabel = Instance.new("TextLabel", IntroFrame)
SubTitleLabel.Size = UDim2.new(1, 0, 0, 24)
SubTitleLabel.Position = UDim2.new(0, 0, 0.32, 0)
SubTitleLabel.BackgroundTransparency = 1
SubTitleLabel.Text = "Master of Space & Gravitational Singularity"
SubTitleLabel.Font = Enum.Font.GothamSemibold
SubTitleLabel.TextColor3 = Color3.fromRGB(170, 160, 210)
SubTitleLabel.TextSize = 13

local LineDivider = Instance.new("Frame", IntroFrame)
LineDivider.Size = UDim2.new(0.8, 0, 0, 2)
LineDivider.Position = UDim2.new(0.1, 0, 0.48, 0)
LineDivider.BackgroundColor3 = Color3.fromRGB(150, 40, 255)
LineDivider.BorderSizePixel = 0

local CreditLabel = Instance.new("TextLabel", IntroFrame)
CreditLabel.Size = UDim2.new(1, 0, 0, 20)
CreditLabel.Position = UDim2.new(0, 0, 0.84, 0)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "Animation by KageFloppey"
CreditLabel.Font = Enum.Font.Gotham
CreditLabel.TextColor3 = Color3.fromRGB(120, 100, 180)
CreditLabel.TextSize = 11

local YtLabel = Instance.new("TextLabel", IntroFrame)
YtLabel.Size = UDim2.new(0, 120, 0, 15)
YtLabel.Position = UDim2.new(1, -130, 1, -22)
YtLabel.BackgroundTransparency = 1
YtLabel.Text = "Youtube: KageFloppey & IDioTKing"
YtLabel.Font = Enum.Font.GothamBold
YtLabel.TextColor3 = Color3.fromRGB(180, 120, 255)
YtLabel.TextSize = 10
YtLabel.TextXAlignment = Enum.TextXAlignment.Right

local StartBtn = Instance.new("TextButton", IntroFrame)
StartBtn.Size = UDim2.new(0, 220, 0, 48)
StartBtn.Position = UDim2.new(0.5, -110, 0.56, 0)
StartBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 240)
StartBtn.Text = "AWAKEN POWER"
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 15
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 10)

RunService.RenderStepped:Connect(function()
    if TitleLabel and TitleLabel.Parent then 
        TitleLabel.TextColor3 = Color3.fromHSV((tick() % 4) / 4, 0.8, 1) 
    end
end)

-- MAIN MENU
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 235) 
MainFrame.Position = UDim2.new(0.06, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 5, 18)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true; MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(150, 20, 255)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 12, 45)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local TopTitle = Instance.new("TextLabel", TopBar)
TopTitle.Size = UDim2.new(1, 0, 1, 0)
TopTitle.BackgroundTransparency = 1
TopTitle.Text = "Void Overlord Hub [NoCD!]IDioTKing"
TopTitle.Font = Enum.Font.GothamBold
TopTitle.TextColor3 = Color3.fromRGB(220, 20, 100)
TopTitle.TextSize = 12

local ButtonContainer = Instance.new("Frame", MainFrame)
ButtonContainer.Size = UDim2.new(1, 0, 1, -38)
ButtonContainer.Position = UDim2.new(0, 0, 0, 38)
ButtonContainer.BackgroundTransparency = 1
local UIListLayout = Instance.new("UIListLayout", ButtonContainer)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateButton(text, layoutOrder)
    local btn = Instance.new("TextButton", ButtonContainer)
    btn.Size = UDim2.new(0.92, 0, 0, 34)
    btn.LayoutOrder = layoutOrder
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = Color3.fromRGB(240, 220, 255)
    btn.BackgroundColor3 = Color3.fromRGB(24, 16, 38)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local DragBtn = CreateButton("DRAG MENU: OFF", 1)
local ChamsBtn = CreateButton("VOID CHAMS (ESP)", 2)
local HoleBtn = CreateButton("EVENT HORIZON", 3)
local ShiftBtn = CreateButton("VOID SHIFT", 4)
local DomainBtn = CreateButton("CELESTIAL COLLAPSE", 5)

local dragEnabled, dragging, dragInput, dragStart, startPos = false
TopBar.InputBegan:Connect(function(input)
    if dragEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TopBar.InputChanged:Connect(function(input) if dragEnabled and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

DragBtn.MouseButton1Click:Connect(function()
    dragEnabled = not dragEnabled
    DragBtn.Text = dragEnabled and "DRAG MENU: ON" or "DRAG MENU: OFF"
    DragBtn.BackgroundColor3 = dragEnabled and Color3.fromRGB(140, 0, 220) or Color3.fromRGB(24, 16, 38)
end)

local function UpdateChams()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local existing = p.Character:FindFirstChild("VoidChams")
            if chamsEnabled and not existing then
                local hl = Instance.new("Highlight")
                hl.Name = "VoidChams"; hl.FillColor = Color3.fromRGB(160, 0, 255); hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.5; hl.OutlineTransparency = 0; hl.Parent = p.Character
            elseif not chamsEnabled and existing then existing:Destroy()
            end
        end
    end
end

ChamsBtn.MouseButton1Click:Connect(function()
    chamsEnabled = not chamsEnabled
    PlayBlinkEffect(function()
        ChamsBtn.Text = chamsEnabled and "VOID CHAMS: ON" or "VOID CHAMS: OFF"
        ChamsBtn.BackgroundColor3 = chamsEnabled and Color3.fromRGB(140, 0, 220) or Color3.fromRGB(24, 16, 38)
        UpdateChams()
    end)
end)

--====================================================================
-- KỸ NĂNG 1: EVENT HORIZON (HỐ ĐEN TỬ THẦN)
--====================================================================
HoleBtn.MouseButton1Click:Connect(function()
    if isExecuting or holeCooldown then return end
    isExecuting = false; holeCooldown = false
    
    local char, hum, root = GetCharacterParts()
    PlayTrackSafely(AnimIDs.Cast, Enum.AnimationPriority.Action)
    
    -- DELAY GỒNG CHIÊU 2 GIÂY
    task.wait(0)
    if not root or not root.Parent or hum.Health <= 0 then 
        isExecuting = false; holeCooldown = false; return 
    end
    
    local orb = Instance.new("Part")
    orb.Shape = Enum.PartType.Ball; orb.Size = Vector3.new(4, 4, 4)
    orb.Material = Enum.Material.Neon; orb.Color = Color3.fromRGB(180, 0, 255)
    orb.CanCollide = false; orb.Anchored = true; orb.CFrame = root.CFrame * CFrame.new(0, 1, -4)
    orb.Parent = workspace
    
    local orbLight = Instance.new("PointLight", orb)
    orbLight.Color = Color3.fromRGB(200, 50, 255); orbLight.Range = 25; orbLight.Brightness = 5
    
    local orbAtt = Instance.new("Attachment", orb)
    local trail = Instance.new("Trail", orb)
    trail.Attachment0 = orbAtt; trail.Attachment1 = Instance.new("Attachment", orb, CFrame.new(0, 0, 1))
    trail.Color = ColorSequence.new(Color3.fromRGB(200, 50, 255), Color3.fromRGB(80, 0, 150))
    trail.Lifetime = 0.5; trail.WidthScale = NumberSequence.new({NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0)})
    
    local orbParticles = Instance.new("ParticleEmitter", orbAtt)
    orbParticles.Texture = "rbxassetid://243098098"; orbParticles.Color = ColorSequence.new(Color3.fromRGB(220, 100, 255))
    orbParticles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0)})
    orbParticles.Lifetime = NumberRange.new(0.3, 0.6); orbParticles.Rate = 200; orbParticles.Speed = NumberRange.new(5, 20); orbParticles.SpreadAngle = Vector2.new(360, 360)
    
    local maxDist = 150; local speed = 130; local startCFrame = orb.CFrame; local targetPos = nil
    
    local zapTask = task.spawn(function()
        while orb and orb.Parent do
            local pPrev = orb.Position; task.wait(0.06)
            if orb and orb.Parent then SpawnZap(pPrev, orb.Position) end
        end
    end)
    
    local flightConn
    flightConn = RunService.Heartbeat:Connect(function(dt)
        if not orb or not orb.Parent then flightConn:Disconnect() return end
        local step = speed * dt
        local ray = workspace:Raycast(orb.Position, orb.CFrame.LookVector * step)
        
        if ray and ray.Instance and ray.Instance.CanCollide then
            targetPos = ray.Position; orb.Position = targetPos; flightConn:Disconnect()
        else
            orb.CFrame = orb.CFrame + orb.CFrame.LookVector * step
            if (orb.Position - startCFrame.Position).Magnitude >= maxDist then
                targetPos = orb.Position; flightConn:Disconnect()
            end
        end
    end)
    
    while not targetPos do task.wait(0.02) end
    pcall(function() task.cancel(zapTask) end)
    
    local blackHole = Instance.new("Part")
    blackHole.Shape = Enum.PartType.Ball; blackHole.Size = Vector3.new(4, 4, 4)
    blackHole.Material = Enum.Material.SmoothPlastic; blackHole.Color = Color3.new(0, 0, 0)
    blackHole.CanCollide = false; blackHole.Anchored = true; blackHole.Position = targetPos; blackHole.Parent = workspace
    
    local bhLight = Instance.new("PointLight", blackHole)
    bhLight.Color = Color3.fromRGB(150, 0, 255); bhLight.Range = 60; bhLight.Brightness = 8
    
    local distortion = Instance.new("Part")
    distortion.Shape = Enum.PartType.Ball; distortion.Size = Vector3.new(5, 5, 5)
    distortion.Material = Enum.Material.Glass; distortion.Transparency = 0.6; distortion.Color = Color3.new(1,1,1)
    distortion.CanCollide = false; distortion.Anchored = true; distortion.Position = targetPos; distortion.Parent = workspace
    
    local function createRing(sizeX, sizeZ, color, angleX, angleZ)
        local ring = Instance.new("Part")
        ring.Shape = Enum.PartType.Cylinder; ring.Size = Vector3.new(0.1, sizeX, sizeZ)
        ring.Material = Enum.Material.Neon; ring.Color = color
        ring.CanCollide = false; ring.Anchored = true
        ring.CFrame = CFrame.new(targetPos) * CFrame.Angles(angleX, 0, angleZ)
        ring.Parent = workspace; return ring
    end
    
    local diskInner = createRing(6, 6, Color3.fromRGB(220, 120, 255), math.rad(10), 0)
    local diskMid = createRing(12, 12, Color3.fromRGB(160, 20, 255), math.rad(80), math.rad(30))
    local diskOuter = createRing(16, 16, Color3.fromRGB(100, 0, 200), math.rad(45), math.rad(60))
    
    local bhAtt = Instance.new("Attachment", blackHole)
    local bhWind = Instance.new("ParticleEmitter", bhAtt)
    bhWind.Texture = "rbxassetid://4591741755"; bhWind.Color = ColorSequence.new(Color3.fromRGB(200, 80, 255))
    bhWind.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 6), NumberSequenceKeypoint.new(1, 0)})
    bhWind.Lifetime = NumberRange.new(0.4, 0.8); bhWind.Rate = 400; bhWind.Speed = NumberRange.new(15, 40)
    bhWind.SpreadAngle = Vector2.new(360, 360)
    
    TweenService:Create(blackHole, TweenInfo.new(0.6, Enum.EasingStyle.Elastic), {Size = Vector3.new(35, 35, 35)}):Play()
    TweenService:Create(distortion, TweenInfo.new(0.6, Enum.EasingStyle.Elastic), {Size = Vector3.new(50, 50, 50)}):Play()
    TweenService:Create(diskInner, TweenInfo.new(0.6, Enum.EasingStyle.Elastic), {Size = Vector3.new(0.2, 55, 55)}):Play()
    TweenService:Create(diskMid, TweenInfo.new(0.6, Enum.EasingStyle.Elastic), {Size = Vector3.new(0.2, 85, 85)}):Play()
    TweenService:Create(diskOuter, TweenInfo.new(0.6, Enum.EasingStyle.Elastic), {Size = Vector3.new(0.2, 115, 115)}):Play()
    
    local ringRot = RunService.RenderStepped:Connect(function()
        if diskInner and diskInner.Parent then diskInner.CFrame = diskInner.CFrame * CFrame.Angles(0, math.rad(6), 0) end
        if diskMid and diskMid.Parent then diskMid.CFrame = diskMid.CFrame * CFrame.Angles(0, math.rad(-4), 0) end
        if diskOuter and diskOuter.Parent then diskOuter.CFrame = diskOuter.CFrame * CFrame.Angles(0, math.rad(2.5), 0) end
    end)
    
    local pullTime = 5; local startTime = tick()
    task.spawn(function()
        while tick() - startTime < pullTime do
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local tRoot = p.Character.HumanoidRootPart
                    if (tRoot.Position - targetPos).Magnitude <= 95 then
                        tRoot.CFrame = tRoot.CFrame + (targetPos - tRoot.Position).Unit * 3.5
                    end
                end
            end
            task.wait(0.05)
        end
        
        ringRot:Disconnect()
        TweenService:Create(blackHole, TweenInfo.new(0.2), {Size = Vector3.new(1, 1, 1)}):Play()
        TweenService:Create(distortion, TweenInfo.new(0.2), {Size = Vector3.new(1, 1, 1)}):Play()
        TweenService:Create(diskInner, TweenInfo.new(0.2), {Size = Vector3.new(0.1, 1, 1)}):Play()
        TweenService:Create(diskMid, TweenInfo.new(0.2), {Size = Vector3.new(0.1, 1, 1)}):Play()
        TweenService:Create(diskOuter, TweenInfo.new(0.2), {Size = Vector3.new(0.1, 1, 1)}):Play()
        task.wait(0.25)
        
        local shockwave = Instance.new("Part")
        shockwave.Shape = Enum.PartType.Ball; shockwave.Size = Vector3.new(2, 2, 2)
        shockwave.Material = Enum.Material.Neon; shockwave.Color = Color3.fromRGB(255, 255, 255)
        shockwave.CanCollide = false; shockwave.Anchored = true; shockwave.Position = targetPos; shockwave.Parent = workspace
        TweenService:Create(shockwave, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(180, 180, 180), Transparency = 1}):Play()
        
        Debris:AddItem(blackHole, 0.1); Debris:AddItem(distortion, 0.1); Debris:AddItem(diskInner, 0.1); Debris:AddItem(diskMid, 0.1); Debris:AddItem(diskOuter, 0.1); Debris:AddItem(shockwave, 0.7); Debris:AddItem(orb, 0.1)
    end)
    
    task.wait(0.3); isExecuting = false
    task.spawn(function()
        HoleBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 60)
        for i = 0, 1, -1 do HoleBtn.Text = "COOLDOWN: " .. i; task.wait(1) end
        HoleBtn.Text = "EVENT HORIZON"; HoleBtn.BackgroundColor3 = Color3.fromRGB(24, 16, 38); holeCooldown = false
    end)
end)

--====================================================================
-- KỸ NĂNG 2: VOID SHIFT (LƯỚT NHANH)
--====================================================================
ShiftBtn.MouseButton1Click:Connect(function()
    if isExecuting or shiftCooldown then return end
    isExecuting = false; shiftCooldown = false
    
    local char, hum, root = GetCharacterParts()
    PlayTrackSafely(AnimIDs.Shift, Enum.AnimationPriority.Action)
    
    local startPos = root.CFrame
    local endPos = startPos * CFrame.new(0, 0, -50)
    
    CreateShockwaveRing(startPos.Position, Color3.fromRGB(150, 0, 255), 40, 0.4)
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.TintColor = Color3.fromRGB(200, 150, 255); cc.Contrast = 1.5; cc.Brightness = 0.5
    TweenService:Create(cc, TweenInfo.new(0.4), {TintColor = Color3.fromRGB(255,255,255), Contrast = 0, Brightness = 0}):Play()
    Debris:AddItem(cc, 0.5)
    
    local steps = 5
    for i = 1, steps do
        local lerpCFrame = startPos:Lerp(endPos, i/steps)
        SpawnGhost(char, lerpCFrame, 0.5)
        local prevCFrame = startPos:Lerp(endPos, (i-1)/steps)
        SpawnZap(prevCFrame.Position, lerpCFrame.Position)
    end
    
    root.CFrame = endPos
    CreateShockwaveRing(endPos.Position, Color3.fromRGB(220, 100, 255), 50, 0.5)
    
    local burst = Instance.new("Part")
    burst.Anchored = true; burst.CanCollide = false; burst.Transparency = 1
    burst.CFrame = root.CFrame; burst.Parent = workspace
    local bAtt = Instance.new("Attachment", burst)
    local bPart = Instance.new("ParticleEmitter", bAtt)
    bPart.Texture = "rbxassetid://243098098"; bPart.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 0, 255))
    bPart.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 4), NumberSequenceKeypoint.new(1, 0)})
    bPart.Lifetime = NumberRange.new(0.4, 0.8); bPart.Speed = NumberRange.new(20, 50)
    bPart.SpreadAngle = Vector2.new(360, 360); bPart.Rate = 0
    bPart:Emit(50)
    Debris:AddItem(burst, 1)
    
    isExecuting = false
    task.spawn(function()
        ShiftBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 60)
        local cd = 0
        while cd > 0 do
            ShiftBtn.Text = "COOLDOWN: " .. string.format("%.1f", cd)
            task.wait(0.1)
            cd = cd - 0.1
        end
        ShiftBtn.Text = "VOID SHIFT"; ShiftBtn.BackgroundColor3 = Color3.fromRGB(24, 16, 38); shiftCooldown = false
    end)
end)

--====================================================================
-- KỸ NĂNG 3: CELESTIAL COLLAPSE (THIÊN THẠCH)
--====================================================================
DomainBtn.MouseButton1Click:Connect(function()
    if isExecuting or voidDomainActive or domainCooldown then return end
    voidDomainActive = false; isExecuting = false
    
    local char, hum, root = GetCharacterParts()
    PlayTrackSafely(AnimIDs.Ultimate, Enum.AnimationPriority.Action4)
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Name = "VoidDomainVision"; cc.TintColor = Color3.fromRGB(120, 50, 255)
    cc.Saturation = -0.5; cc.Contrast = 0.8
    
    local arrayPos = root.Position - Vector3.new(0, 2.5, 0)
    local magicArray = Instance.new("Part")
    magicArray.Shape = Enum.PartType.Cylinder; magicArray.Size = Vector3.new(0.3, 10, 10)
    magicArray.Material = Enum.Material.Neon; magicArray.Color = Color3.fromRGB(180, 0, 255)
    magicArray.CFrame = CFrame.new(arrayPos) * CFrame.Angles(0, 0, math.rad(90))
    magicArray.CanCollide = false; magicArray.Anchored = true; magicArray.Parent = workspace
    
    local innerArray = magicArray:Clone()
    innerArray.Size = Vector3.new(0.35, 5, 5); innerArray.Color = Color3.fromRGB(220, 100, 255); innerArray.Parent = workspace
    
    TweenService:Create(magicArray, TweenInfo.new(1.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = Vector3.new(0.3, 120, 120)}):Play()
    TweenService:Create(innerArray, TweenInfo.new(1.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = Vector3.new(0.35, 70, 70)}):Play()
    
    local arrayRot = RunService.RenderStepped:Connect(function()
        if magicArray and magicArray.Parent then magicArray.CFrame = magicArray.CFrame * CFrame.Angles(math.rad(2), 0, 0) end
        if innerArray and innerArray.Parent then innerArray.CFrame = innerArray.CFrame * CFrame.Angles(math.rad(-3), 0, 0) end
    end)
    
    local liftedPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local tRoot = p.Character.HumanoidRootPart
            if (tRoot.Position - root.Position).Magnitude <= 100 then
                table.insert(liftedPlayers, p.Character)
                
                local circle = Instance.new("Part")
                circle.Shape = Enum.PartType.Cylinder; circle.Size = Vector3.new(0.1, 9, 9)
                circle.Material = Enum.Material.Neon; circle.Color = Color3.fromRGB(200, 50, 255)
                circle.CanCollide = false; circle.Anchored = false 
                circle.CFrame = tRoot.CFrame * CFrame.new(0, -3, 0) * CFrame.Angles(0, 0, math.rad(90))
                circle.Parent = workspace
                
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = tRoot; weld.Part1 = circle; weld.Parent = circle
                Debris:AddItem(circle, 6)
            end
        end
    end
    
    task.spawn(function()
        for i = 1, 28 do 
            for _, charObj in ipairs(liftedPlayers) do
                if charObj and charObj:FindFirstChild("HumanoidRootPart") then
                    local tRoot = charObj.HumanoidRootPart
                    tRoot.CFrame = tRoot.CFrame + Vector3.new(0, 1.5, 0)
                end
            end
            task.wait(0.07)
        end
    end)
    
    -- [MỚI] ĐỢI 1.5 GIÂY ĐỂ KÍCH HOẠT HIỆU ỨNG GẦM
    task.wait(1.5)
    
    task.spawn(function()
        if root and root.Parent then
            -- Bắn ra 5 đợt sóng xung kích màu tím liên tục
            for i = 1, 5 do
                local roarWave = Instance.new("Part")
                roarWave.Shape = Enum.PartType.Ball
                roarWave.Size = Vector3.new(5, 5, 5)
                roarWave.Material = Enum.Material.Neon
                roarWave.Color = Color3.fromRGB(170, 20, 255)
                roarWave.CanCollide = false
                roarWave.Anchored = true
                roarWave.CFrame = root.CFrame
                roarWave.Parent = workspace
                
                TweenService:Create(roarWave, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = Vector3.new(100, 100, 100), 
                    Transparency = 1
                }):Play()
                
                -- Rung màn hình nhẹ khi gầm
                task.spawn(function()
                    local humObj = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                    if humObj then
                        local origOffset = humObj.CameraOffset
                        for j = 1, 5 do
                            humObj.CameraOffset = Vector3.new(math.random(-5,5)/10, math.random(-5,5)/10, math.random(-5,5)/10)
                            task.wait(0.02)
                        end
                        humObj.CameraOffset = origOffset
                    end
                end)
                
                Debris:AddItem(roarWave, 0.6)
                task.wait(0.12) -- Khoảng cách giữa các đợt sóng
            end
        end
    end)
    
    -- [MỚI] ĐỢI THÊM 0.5 GIÂY NỮA (TỔNG LÀ 2 GIÂY KỂ TỪ KHI BẬT) THÌ THIÊN THẠCH RƠI
    task.wait(0.5)
    
    for _, targetChar in ipairs(liftedPlayers) do
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            task.spawn(function()
                local tRoot = targetChar.HumanoidRootPart
                local mStart = tRoot.Position + Vector3.new(0, 180, 0)
                local mTarget = tRoot.Position - Vector3.new(0, 5, 0)
                
                local meteor = Instance.new("Part")
                meteor.Shape = Enum.PartType.Ball; meteor.Size = Vector3.new(40, 40, 40)
                meteor.Material = Enum.Material.Basalt; meteor.Color = Color3.fromRGB(15, 5, 25)
                meteor.CanCollide = false; meteor.Anchored = true; meteor.Position = mStart; meteor.Parent = workspace
                
                local meteorGlow = Instance.new("Part")
                meteorGlow.Shape = Enum.PartType.Ball; meteorGlow.Size = Vector3.new(48, 48, 48)
                meteorGlow.Material = Enum.Material.Neon; meteorGlow.Color = Color3.fromRGB(180, 0, 255)
                meteorGlow.CanCollide = false; meteorGlow.Anchored = true; meteorGlow.Position = mStart; meteorGlow.Parent = workspace
                
                local trailAtt = Instance.new("Attachment", meteorGlow)
                local fire = Instance.new("ParticleEmitter", trailAtt)
                fire.Texture = "rbxassetid://4591741755"; fire.Color = ColorSequence.new(Color3.fromRGB(220, 80, 255), Color3.fromRGB(80, 0, 150))
                fire.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 45), NumberSequenceKeypoint.new(1, 10)})
                fire.Lifetime = NumberRange.new(0.5, 1.0); fire.Rate = 800; fire.Speed = NumberRange.new(0)
                
                TweenService:Create(meteor, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = mTarget}):Play()
                TweenService:Create(meteorGlow, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = mTarget}):Play()
                
                task.wait(1.0)
                meteor:Destroy(); meteorGlow:Destroy()
                
                local flash = Instance.new("Part")
                flash.Shape = Enum.PartType.Ball; flash.Size = Vector3.new(5, 5, 5)
                flash.Material = Enum.Material.Neon; flash.Color = Color3.fromRGB(255, 255, 255)
                flash.Position = mTarget; flash.Anchored = true; flash.CanCollide = false; flash.Parent = workspace
                TweenService:Create(flash, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = Vector3.new(200, 200, 200), Transparency = 1
                }):Play()
                Debris:AddItem(flash, 0.5)
                
                task.spawn(function()
                    local humObj = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                    if humObj then
                        local origOffset = humObj.CameraOffset
                        for i = 1, 20 do
                            humObj.CameraOffset = Vector3.new(math.random(-15,15)/10, math.random(-15,15)/10, math.random(-15,15)/10)
                            task.wait(0.03)
                        end
                        humObj.CameraOffset = origOffset
                    end
                end)
                
                local pillar = Instance.new("Part")
                pillar.Shape = Enum.PartType.Cylinder; pillar.Size = Vector3.new(150, 10, 10)
                pillar.Material = Enum.Material.Neon; pillar.Color = Color3.fromRGB(230, 150, 255)
                pillar.CFrame = CFrame.new(mTarget + Vector3.new(0, 75, 0)) * CFrame.Angles(0, 0, math.rad(90))
                pillar.CanCollide = false; pillar.Anchored = true; pillar.Parent = workspace
                TweenService:Create(pillar, TweenInfo.new(0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                    Size = Vector3.new(150, 60, 60), Transparency = 1
                }):Play()
                Debris:AddItem(pillar, 0.9)
                
                for i = 1, 4 do
                    local wave = Instance.new("Part")
                    wave.Shape = Enum.PartType.Cylinder; wave.Size = Vector3.new(1, 10, 10)
                    wave.Material = Enum.Material.Neon; wave.Color = i % 2 == 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 0, 255)
                    wave.CFrame = CFrame.new(mTarget) * CFrame.Angles(0, 0, math.rad(90))
                    wave.CanCollide = false; wave.Anchored = true; wave.Parent = workspace
                    TweenService:Create(wave, TweenInfo.new(0.4 + (i*0.2), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = Vector3.new(0.2, 90 + (i*40), 90 + (i*40)), Transparency = 1
                    }):Play()
                    Debris:AddItem(wave, 1.2)
                end
            end)
        end
    end
    
    task.wait(1.5)
    arrayRot:Disconnect(); Debris:AddItem(magicArray, 0.2); Debris:AddItem(innerArray, 0.2)
    TweenService:Create(cc, TweenInfo.new(1.5), {Saturation = 0, Contrast = 0, TintColor = Color3.fromRGB(255, 255, 255)}):Play()
    Debris:AddItem(cc, 1.6)
    
    voidDomainActive = false; isExecuting = false
    task.spawn(function()
        domainCooldown = true
        DomainBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 60)
        for i = 0, 1, -1 do DomainBtn.Text = "COOLDOWN: " .. i; task.wait(1) end
        DomainBtn.Text = "CELESTIAL COLLAPSE"; DomainBtn.BackgroundColor3 = Color3.fromRGB(24, 16, 38); domainCooldown = false
    end)
end)

--====================================================================
-- NÚT START VÀ HỒI SINH
--====================================================================
StartBtn.MouseButton1Click:Connect(function()
    IntroFrame.Visible = false
    IntroFrame:Destroy()
    MainFrame.Visible = true
    
    local char, hum, root = GetCharacterParts()
    ChangeDefaultAnimation(char, "idle", AnimIDs.Idle)
    ChangeDefaultAnimation(char, "run", AnimIDs.Run)
    ChangeDefaultAnimation(char, "walk", AnimIDs.Run)
    RefreshAnimateScript(char)
    SpawnVoidAura(root)
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    if MainFrame.Visible then
        isExecuting = false
        voidDomainActive = false
        task.wait(0.5)
        
        local hum = newChar:WaitForChild("Humanoid")
        local root = newChar:WaitForChild("HumanoidRootPart")
        ChangeDefaultAnimation(newChar, "idle", AnimIDs.Idle)
        ChangeDefaultAnimation(newChar, "run", AnimIDs.Run)
        ChangeDefaultAnimation(newChar, "walk", AnimIDs.Run)
        RefreshAnimateScript(newChar)
        SpawnVoidAura(root)
        
        if chamsEnabled then task.delay(1, function() UpdateChams() end) end
    end
end)
