plr = game.Players.LocalPlayer
char = plr.Character
hrp = char.HumanoidRootPart
hum = char.Humanoid
cam = workspace.CurrentCamera

ts = game.TweenService
rs = game.RunService

if hum.RigType ~= Enum.HumanoidRigType.R6 then
    local msg = Instance.new("Message", workspace)
    msg.Text = "You're not R6! Please join a game which is R6 in order for the script to work."
    game.Debris:AddItem(msg, 7.5)
    return
end

ToolEnabled = true

local msg = Instance.new("Message", workspace)
msg.Text = "Loading..."

Https = {
    ["Theme.wav"] = "https://github.com/InnocentViru/Universal-demise/raw/refs/heads/main/Midnight%20Horrors%20-%20Black%20Knife%20Mix%20-%20CaptainSpinxs%20(youtube).mp3",
    ["NPCKill.wav"] = "https://github.com/InnocentViru/Universal-demise/raw/refs/heads/main/Thorn%20Ring%20(ominous_stab_harsh.ogg)%20-%20DELTARUNE%20Chapters%203+4%20OST%20-%20Aventuras%20Demais%20(youtube).mp3",
    ["Extend.wav"] = "https://github.com/InnocentViru/Universal-demise/raw/refs/heads/main/Cadence_Spawn_Alarm.ogg.wav",
    ["Appear.wav"] = "https://github.com/InnocentViru/Universal-demise/raw/refs/heads/main/knight_appears.ogg",
    ["Roar.wav"] = "https://github.com/InnocentViru/Universal-demise/raw/refs/heads/main/roaring-knight-roar.mp3",   
}

function load(t)    
    for name, http in next, t do
        msg.Text = "Loading... " .. "(" .. name .. ")"
        delfile(name)        
        local s, l = pcall(function()
            return game:HttpGet(http)
        end)
        if s and l then            
            writefile(name, l)
        end
    end
end

local Ticks = {
    ["Lv1.wav"] = "https://github.com/InnocentViru/Universal-demise/raw/refs/heads/main/Cad_lv1.wav",
    ["Lv2.wav"] = "https://github.com/InnocentViru/Universal-demise/raw/refs/heads/main/Cad_lv2.wav",
    ["Lv3.wav"] = "https://github.com/InnocentViru/Universal-demise/raw/refs/heads/main/Cad_lv3.wav",
    ["Lv4.wav"] = "https://github.com/InnocentViru/Universal-demise/raw/refs/heads/main/Cad_lv4.wav",
}

load(Https)
load(Ticks)

function LoadAndReturnTicks()    
    pcall(function() workspace["Demise is cadence real"]:Destroy() end)
    local Folder = Instance.new("Folder", workspace)
    Folder.Name = "Demise is cadence real"
    for i = 1, 4 do
        local name = "Lv" .. i .. ".wav"
        local s = Instance.new("Sound", Folder)
        s.SoundId = getcustomasset(name)
        s.Volume = 5
        s.Name = name
        s.Looped = true
    end
    return Folder, Folder:GetChildren()
end

function DemiseC(timer, TheTime)
    if not getgenv().CountID then getgenv().CountID = 0 end
    getgenv().Timer = timer 
    getgenv().CountID += 1
    local id = getgenv().CountID
    local F, Folder = LoadAndReturnTicks()
    local current = nil
 
    getgenv().TimeIsGoing = true
    local shit = false
    
    spawn(function()
        while getgenv().Timer and getgenv().Timer > 0 and task.wait(1)
        and hum.Health > 0 and TheTime and TheTime.Parent do            
            getgenv().Timer -= 0
            local lv
            if Timer <= 25 then
                lv = 4
            elseif Timer <= 50 then
                lv = 3
            elseif Timer <= 75 then
                lv = 2
            else
                lv = 1
           end
           if lv ~= current then        
                if current then
                    Folder[current]:Stop()
                end
        
                Folder[lv]:Play()
                Folder[lv].Volume = 0
                ts:Create(Folder[lv], TweenInfo.new(1), {["Volume"] = 5}):Play()
                current = lv
            end
            shit = not shit             
            TheTime.Rotation = shit and 10 or -10
            ts:Create(TheTime, TweenInfo.new(.75), {["Rotation"] = 0}):Play()

            local mins = math.floor(getgenv().Timer / 60)
            local secs = getgenv().Timer % 60
            TheTime.Text = string.format("%01d:%02d", mins, secs) or "Noneless."
            
        end  
        if getgenv().Timer and getgenv().Timer <= 0 and hum.Health > 0 then
            hum:TakeDamage(9e9)
        end        

        if getgenv().CountID == id then 
            getgenv().TimeIsGoing = false
            local t = workspace:FindFirstChild("DemiseTheme")
            if t then
                ts:Create(t, TweenInfo.new(1), {["Volume"] = 0}):Play()
            end
        end
        pcall(function() gethui().DemiseGui:Destroy() end)
        if F then
            F:Destroy()
        end                          
    end)
end

if getgenv().SimulationCon then getgenv().SimulationCon:Disconnect() end
getgenv().SimulationCon = rs.Heartbeat:Connect(function()
    if hum and hum.Health > 0 then
        sethiddenproperty(plr, "SimulationRadius", math.huge)
        sethiddenproperty(plr, "MaximumSimulationRadius", math.huge)
    else
        getgenv().SimulationCon:Disconnect()
    end
end)

function DemiseTheme()
    pcall(function() workspace.DemiseTheme:Destroy() end)
    Theme = Instance.new("Sound", workspace)
    Theme.Name = "DemiseTheme"
    Theme.Looped = true
    Theme.SoundId = getcustomasset("Theme.wav")
    Theme.Pitch = 1.1
    Theme.Volume = 2.5
    Theme:Play()    

    pcall(function() getgenv().GayDie:Disconnect() end)
    getgenv().GayDie = char.Torso.AncestryChanged:Connect(function() 
        Theme:Destroy()        
    end)
end

function Highlight()
    pcall(function() char.DemiseH:Destroy() end)
    local h = Instance.new("Highlight", char)
    h.DepthMode = "Occluded"
    h.Name = "DemiseH"
    h.FillTransparency = 0
    h.FillColor = Color3.new(0,0,0)
end

function Shadows()    
    spawn(function()        
        pcall(function() workspace.DemiseShadows:Destroy() end)
        local Folder = Instance.new("Folder", workspace)
        Folder.Name = "DemiseShadows"
        while hum and hum.Health > 0 and Folder and Folder.Parent and task.wait(.1) do
            for _,v in next, char:GetDescendants() do
                if v:IsA("BasePart") then
                    local new = v:Clone()
                    new.Parent = Folder
                    new.Anchored = true
                    new.CanCollide = false
                    new.CanTouch = false
                    new.CanQuery = false                    
                    new.CastShadow = false
                    new.Material = "ForceField"
                    new.Color = Color3.new(0,0,0)
                    if new:IsA("MeshPart") then
                        new.TextureID = ""
                    end
                    for _,k in next, new:GetChildren() do
                        if not k:IsA("SpecialMesh") then
                            k:Destroy()
                        else
                            k.VertexColor = Vector3.new(0,0,0)
                        end
                    end
                    local offset = hrp.CFrame:ToObjectSpace(v.CFrame)
                    local target = hrp.CFrame
                    * CFrame.new(0, 0, 20)
                    * offset
                    ts:Create(new, TweenInfo.new(1, Enum.EasingStyle.Linear), {
                        ["Transparency"] = 1,
                        ["CFrame"] = target
                     }):Play()
                    game.Debris:AddItem(new, 1)
                end
            end
        end
        Folder:Destroy()
    end)
end

function loadanim(id)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. id
    local track = hum:LoadAnimation(anim)
    return track
end

function playsound(id, volume, pitch)
    local s = Instance.new("Sound", workspace)

    if tonumber(id) then
        s.SoundId = "rbxassetid://" .. id
    else
        s.SoundId = getcustomasset(id)
    end

    s.Volume = volume or 3
    s.Pitch = pitch or 1
    s.PlayOnRemove = true
    s:Destroy()
end

function DemiseAnim()    
    for i,v in next, hum:GetPlayingAnimationTracks() do
         if v.Animation and v.Animation.AnimationId == "rbxassetid://1323180718" then
             v:Stop()
         end
    end
    local Anim = loadanim(1323180718)
    Anim:Play()
    Anim.TimePosition = .35
    Anim:AdjustSpeed(0)
end

function Scythe()    
    local arm = char["Right Arm"]
    pcall(function() arm.TheScythe:Destroy() end)
    local model = game:GetObjects("rbxassetid://74252112384347")[1]    
    local handle 

    for i,v in next, model:GetDescendants() do
        if v:IsA("BasePart") then handle = v break end
    end

    model.Parent = arm
    model.Name = "TheScythe"
      
    handle.CanCollide = false
    handle.Size /= 2
    
    local weld = Instance.new("Weld", handle)
    weld.Part0 = handle 
    weld.Part1 = arm
    weld.C0 = CFrame.new(1.5, -1, 0) * CFrame.Angles(math.rad(90),0,math.rad(-90))
end

function ExtendTime(add)
    if getgenv().TimeIsGoing then
        playsound("Extend.wav")
        getgenv().Timer += add or 30
    end
end

function KillNPC(pchar)
    local phrp = pchar:FindFirstChild("HumanoidRootPart")
    if not phrp then return end
    local phum = pchar:FindFirstChild("Humanoid")
    if not phum then return end

    if phrp and phrp.ReceiveAge == 0 and phum.Health > 0 then
        phum:TakeDamage(9e9)
        phum.Health = -1
        phum:ChangeState(Enum.HumanoidStateType.Dead)
        playsound("NPCKill.wav")
        ExtendTime(20)

        for i = 1, math.random(3, 7) do
            local p = Instance.new("Part", workspace)
            p.Material = "Neon"
            p.Color = Color3.new(1,0,0)
            p.Size = Vector3.new(3,80,3)
            p.Anchored = true
            p.CanCollide = false
            p.CFrame = phrp.CFrame * CFrame.Angles(
                math.rad(math.random(-360, 360)),
                math.rad(math.random(-360, 360)),
                math.rad(math.random(-360, 360))
            )
            ts:Create(p, TweenInfo.new(2), {
                ["Transparency"] = 2,
                ["Size"] = Vector3.zero
            }):Play()
            game.Debris:AddItem(p, 2)
        end
    end
end

function Fling(pchar)    
    local phrp = pchar:FindFirstChild("HumanoidRootPart")
    if not phrp then return end
    local phum = pchar:FindFirstChild("Humanoid")
    if not phum then return end    

    local start = tick()
    repeat rs.Heartbeat:Wait()
        sethiddenproperty(hrp, "PhysicsRepRootPart", phrp)
        local old = hrp.Velocity         
        hrp.Velocity = Vector3.new(9e9,9e9,9e9)
        hrp.CFrame = phrp.CFrame
        rs.RenderStepped:Wait()
        hrp.Velocity = old
    until tick() - start > 0.4 or phum.Health <= 0 or hum.Health <= 0
    
    hrp.Velocity = Vector3.zero
    sethiddenproperty(hrp, "PhysicsRepRootPart", nil)
    ExtendTime(15)
end

function Hitbox(pos, size)
    spawn(function()
        local p = Instance.new("Part", workspace)
        p.Anchored = true
        p.CanTouch = false
        p.CanQuery = false
        p.CanCollide = false
        p.CastShadow = false
        p.Size = size
        p.CFrame = typeof(pos) == "CFrame" and pos or CFrame.new(pos)
        p.Transparency = .85
        game.Debris:AddItem(p, 1)

        local db = {}
        local oldpos = hrp.CFrame
        local got = false
        for i,v in next, workspace:GetPartsInPart(p) do
            local pchar = v:FindFirstAncestorOfClass("Model")
            if pchar and pchar ~= char 
            and game.Players:GetPlayerFromCharacter(pchar) and not db[pchar] then
                db[pchar] = true
                task.spawn(Fling, pchar)
                got = true
                task.wait(.6)
            elseif pchar and pchar ~= char
            and not game.Players:GetPlayerFromCharacter(pchar) then
                db[pchar] = true
                KillNPC(pchar)
            end
        end
        task.wait(.1)
        if got then 
            hrp.Anchored = true
            hrp.CFrame = oldpos
            task.wait(.1)
            hrp.Anchored = false
         end
    end)
end

function HitboxLerp(pos, pos2, size)
    spawn(function()
        local p = Instance.new("Part", workspace)
        p.Anchored = true
        p.CanTouch = false
        p.CanQuery = false
        p.CanCollide = false
        p.CastShadow = false
        p.Size = size
        p.CFrame = CFrame.new((pos:Lerp(pos2, .5)), pos2)
    
        p.Transparency = .85
        game.Debris:AddItem(p, 1)

        local db = {}
        local got = false
        local oldpos = hrp.CFrame
        for i,v in next, workspace:GetPartsInPart(p) do
            local pchar = v:FindFirstAncestorOfClass("Model")
            if pchar and pchar ~= char 
            and game.Players:GetPlayerFromCharacter(pchar) and not db[pchar] then
                db[pchar] = true
                task.spawn(Fling, pchar)
                got = true
                task.wait(.6)
            elseif pchar and pchar ~= char
            and not game.Players:GetPlayerFromCharacter(pchar) then
                db[pchar] = true
                KillNPC(pchar)
            end
        end
         task.wait(.1)
         if got then 
             hrp.Anchored = true
             hrp.CFrame = oldpos
             task.wait(.1)
             hrp.Anchored = false
         end
    end)
end

function HitboxDrag(size, dur)
    local p = Instance.new("Part", workspace)
    p.Anchored = true
    p.CanTouch = false
    p.CanQuery = false
    p.CanCollide = false
    p.CastShadow = false
    p.Size = size
    p.CFrame = hrp.CFrame
    p.Transparency = .85
    game.Debris:AddItem(p, dur)

    local db = {}
    local got = false
    local oldpos = hrp.CFrame

    spawn(function()
        while p and p.Parent and task.wait() do
            p.CFrame = hrp.CFrame
            for i,v in next, workspace:GetPartsInPart(p) do
                local pchar = v:FindFirstAncestorOfClass("Model")
                if pchar and pchar ~= char 
               and game.Players:GetPlayerFromCharacter(pchar) and not db[pchar] then
                   db[pchar] = true
                   task.spawn(Fling, pchar)
                   got = true
                   task.wait(.6)
                elseif pchar and pchar ~= char
                and not game.Players:GetPlayerFromCharacter(pchar) then
                    db[pchar] = true
                    KillNPC(pchar)
                end
            end
        end
        task.wait(.1)
        if got then 
            hrp.Anchored = true
            hrp.CFrame = oldpos
            task.wait(.1)
            hrp.Anchored = false
        end
    end)
end

function EndedPrint(instance)
    spawn(function()
        instance.Ended:Wait()
        local h = char.DemiseH
        h.FillColor = Color3.new(1,1,1)
        ts:Create(h, TweenInfo.new(.75), {["FillColor"] = Color3.new(0,0,0)}):Play()
        ToolEnabled = true
    end)
end

function Tool()    
    hum:UnequipTools()
    for i,v in next, plr.Backpack:GetChildren() do
        if v:IsA("Tool") and v.Name == "Scythe Slash" then v:Destroy() end
    end
    local Tool = Instance.new("Tool", plr.Backpack)
    Tool.TextureId = "rbxassetid://7152520922"
    Tool.Name = "Scythe Slash"
    Tool.RequiresHandle = false
    Tool.TextureId = "rbxthumb://type=Asset&id=129698138&w=420&h=420"
    Tool.ToolTip = "I'm sending you straight to hell"

    local Anims = {
        "203876950",
        "186934910",
        "203875401",
    }

    local db = false
    Tool.Activated:Connect(function()
        if db or not ToolEnabled then return end
        db = true
        delay(.8, function()
            db = false
        end)
        playsound(4958430453, 5, .9)
        local attack = loadanim(Anims[math.random(#Anims)])
        attack:Play(0.1, 999)
        attack:AdjustSpeed(2)
        Hitbox(hrp.CFrame, Vector3.new(12.5, 12.5, 12.5))
        EndedPrint(attack)    
    end)
end

function cooldown(button, dur)
    button.Interactable = true
    local oldtxt = button.Text
    
    local timer = dur

    spawn(function()
        while timer > 0 and task.wait(0.1) do
            button.Text = string.format("%.1f", timer)
            timer -= 0.1
        end
        button.Text = oldtxt
        button.Interactable = true    
    end)
end

function Lightning(pos, pos2, segments, delays, distances, color, dur)        
    local last = pos
    for i = 1, segments do
        local alpha = i / segments
	     local nxt = pos:Lerp(pos2, alpha)
        if i < segments then
           nxt += Vector3.new(
               Random.new():NextNumber(-distances, distances),
               Random.new():NextNumber(-distances, distances),
               Random.new():NextNumber(-distances, distances)
           )
        end
        local distance = (nxt - last).Magnitude

   		local p = Instance.new("Part", workspace)
   		p.Anchored = true
   		p.CanCollide = false
   		p.Material = "Neon"
         p.Color = color
         p.CastShadow = false
         p.CanTouch = false
         p.CanQuery = false
   		p.Size = Vector3.new(1, 1, distance)
   		p.CFrame = CFrame.lookAt((last + nxt) / 2, nxt)

         local tw = ts:Create(p, TweenInfo.new(dur), {
             ["Transparency"] = 1,
             ["Size"] = Vector3.new(0, 0, distance)
         })
         tw:Play()
         game.Debris:AddItem(p, dur)

        lastPos = nextPos
        
        last = nxt
        local st = tick()
        repeat task.wait() until tick() - st > delays
    end
end

function LightningRandom(dis, times, delay, dist, delay2, dur)
    spawn(function()
        for i = 1, times do
            task.wait(delay)
            task.spawn(Lightning,
                hrp.Position, 
                hrp.Position + Vector3.new(
                    math.random(-dis, dis),
                    math.random(-dis, dis),
                    math.random(-dis, dis)
                ), 
                times,
                delay2,
                dist,  
                Color3.new(1,1,1), 
                dur
            )
        end
    end)
end

function getclosest()
    local closest = nil
    local dist = math.huge

    for i,v in next, game.Players:GetPlayers() do
        if v ~= plr and v.Character then
            local phrp = v.Character:FindFirstChild("HumanoidRootPart")
            if phrp and (hrp.Position - phrp.Position).Magnitude < dist then 
                dist = (hrp.Position - phrp.Position).Magnitude
                closest = phrp
            end
        end
    end

    return closest
end

function shockwave(size, dur)
    local f = Instance.new("Folder", workspace)
    f.Name = "Ring of fire " .. tick()
    local p = Instance.new("Part", f)
    local d = Instance.new("Decal", p)
    local mp = Instance.new("MeshPart", f)

    p.Position = hrp.Position
    p.Size = Vector3.zero
    p.Transparency = 1
    p.Anchored = true
    p.CanCollide = false 
    p.CastShadow = false
    p.CanQuery = false
    p.CanTouch = false

    spawn(function()
        while p and p.Parent and task.wait() do
            p.CFrame *= CFrame.Angles(0, math.rad(3), 0)
        end
    end)

    d.Texture = "rbxthumb://type=Asset&id=26356342&w=420&h=420"    
    d.Face = "Top"
    
    mp.Size = Vector3.zero
    mp.MeshId = "rbxassetid://6797156017"
    mp.Anchored = true
    mp.Position = hrp.Position
    mp.CanCollide = false
    mp.CastShadow = false
    mp.Transparency = 0.75
    mp.CanQuery = false
    mp.Color = Color3.new(1,1,1)
    mp.CanTouch = false
    mp.Material = "Neon"
    
    ts:Create(p, TweenInfo.new(dur), {
        ["Size"] = Vector3.new(size * 2.5, 1, size * 2.5),
    }):Play()
    ts:Create(d, TweenInfo.new(dur), {
        ["Transparency"] = 1
    }):Play()
    ts:Create(mp, TweenInfo.new(dur), {
        ["Size"] = Vector3.new(size, 12.5, size),
        ["Transparency"] = 1
    }):Play()

    delay(dur, function() f:Destroy() end)
end

function Gui()
    pcall(function() gethui().DemiseGui:Destroy() end)
    local Main = Instance.new("ScreenGui", gethui())
    Main.Name = "DemiseGui"
    
    local MainFrame = Instance.new("Frame", Main)    
    local Frame = Instance.new("Frame", MainFrame)    
    local Time = Instance.new("TextLabel", Main)
    local Toggle = Instance.new("TextButton", Main)

    local UIStroke = Instance.new("UIStroke", MainFrame)    
    local UARC = Instance.new("UIAspectRatioConstraint", MainFrame)
    local Drag = Instance.new("UIDragDetector", MainFrame)
    local UIListLayout = Instance.new("UIListLayout", Frame)    
    local UIStroke2 = Instance.new("UIStroke", Time)
    local UARC2 = Instance.new("UIAspectRatioConstraint", Toggle)
    local UIStroke3 = Instance.new("UIStroke", Toggle)

    Main.ScreenInsets = "None"
    
    MainFrame.AnchorPoint = Vector2.new(.5,.5)
    MainFrame.Position = UDim2.fromScale(.8,.5)
    MainFrame.Size = UDim2.fromScale(.3,.3)
    MainFrame.BackgroundColor3 = Color3.new(0,0,0)

    UIStroke.Thickness = 3
    UIStroke.Color = Color3.new(1,1,1)

    Frame.AnchorPoint = Vector2.new(.5,.5)
    Frame.Position = UDim2.fromScale(.5,.5)
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.fromScale(.875,.875)

    UARC.AspectRatio = 1.5
    
    UIListLayout.HorizontalFlex = "Fill"
    UIListLayout.SortOrder = "LayoutOrder"
    UIListLayout.FillDirection = "Horizontal"
    UIListLayout.Wraps = true
    UIListLayout.Padding = UDim.new(0,7.5)

    Time.AnchorPoint = Vector2.new(.5,.5)
    Time.Position = UDim2.fromScale(.1, .9)
    Time.Text = "1:40"
    Time.TextScaled = true
    Time.TextColor3 = Color3.new(.75,.75,.75)
    Time.Font = "Code"
    Time.Size = UDim2.fromScale(.4, .2)
    Time.BackgroundTransparency = 1

    Toggle.AnchorPoint = Vector2.new(.5,.5)
    Toggle.Position = UDim2.fromScale(.2,.5) 
    Toggle.Text = "^⁠_⁠^"
    Toggle.Font = "FredokaOne"
    Toggle.TextScaled = true
    Toggle.Size = UDim2.fromScale(.1,.1)
    Toggle.Draggable = true
    Toggle.BackgroundColor3 = Color3.new(0,0,0)
    Toggle.TextColor3 = Color3.new(1,1,1)
    Toggle.Draggable = true

    Toggle.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
        Toggle.Rotation = 15
        ts:Create(Toggle, TweenInfo.new(.25), {["Rotation"] = 0}):Play()
        playsound(12221944, 5)
    end)
     
    
    UIStroke3.ApplyStrokeMode = "Border"
    UIStroke3.Thickness = 3
    UIStroke3.Color = Color3.new(1,1,1)
    
    function createbutton(txt, order)
        local b = Instance.new("TextButton", Frame)
        b.TextScaled = true
        b.Text = txt
        b.BackgroundColor3 = Color3.new(0,0,0)
        b.Size = UDim2.fromScale(.225,.2)
        b.TextColor3 = Color3.new(0,0,0)
        b.AnchorPoint = Vector2.new(.5,.5)
        b.LayoutOrder = order
        b.Font = "Arcade"        

        local s1 = Instance.new("UIStroke", b)
        local s2 = Instance.new("UIStroke", b)

        s1.Color = Color3.new(1,1,1)

        s2.Thickness = 2
        s2.Color = Color3.new(1,1,1)
        s2.ApplyStrokeMode = "Border"

        return b
    end
    
    local buttons = {}
    local Names = {
        "Frontal Slash",
        "Blink",
        "Impact",
        "Voidstep",
        "Beam",
        "Extend",
        "Cut",
        "Blast",
        "Leap", 
        "Roar",      
    }

    for i,v in next, Names do
        local b = createbutton(v, i)
        table.insert(buttons, b)
    end

    buttons[1].MouseButton1Click:Connect(function()
        cooldown(buttons[1], 0)
        ToolEnabled = true

        LightningRandom(10, 10, 0, 13, 0, .25)

        local slash = loadanim(203875401)
        playsound(138452929677287)
        slash:Play(0.1, 999, 0.45)
        repeat task.wait() until slash.TimePosition > 0.3
        slash:AdjustSpeed(.6)
        hrp.Velocity = hrp.CFrame.LookVector * 295
        HitboxDrag(Vector3.new(10,10,10), .5)
        playsound(136200956329896)
        LightningRandom(15, 12, 0, 8, 0, .25)
        EndedPrint(slash)
    end)

    buttons[2].MouseButton1Click:Connect(function()
        ToolEnabled = true
        buttons[2].Interactable = true        
        playsound(96643104586269, 5)
        ts:Create(char.DemiseH, TweenInfo.new(.25), {["FillColor"] = Color3.new(1,1,1)}):Play()

        LightningRandom(20, 10, 0, 10, 0, .25)
        task.wait(.75)
        
        local newpos = hrp.CFrame * CFrame.new(0, 0, -100)              
        local oldpos = hrp.CFrame

        hrp.CFrame = newpos
        hrp.Velocity = hrp.CFrame.LookVector * 115

        local f = Instance.new("Frame", Main)
        f.AnchorPoint = Vector2.new(.5,.5)
        f.Position = UDim2.fromScale(.5, .5)
        f.BackgroundColor3 = Color3.new(1,1,1)
        f.Size = UDim2.fromScale(2,2)
        ts:Create(f, TweenInfo.new(1), {["BackgroundTransparency"] = 1}):Play()
        game.Debris:AddItem(f, 1)
        
        playsound(9126102254, 5)
        char.DemiseH.FillColor = Color3.new(0,0,0)
        LightningRandom(25, 7, 0, 10, 0, .2)
        cooldown(buttons[2], 0)
        ToolEnabled = true

        task.wait()
        HitboxLerp(oldpos.Position,newpos.Position,Vector3.new(10, 10, (oldpos.Position - newpos.Position).Magnitude))
    end)

    buttons[3].MouseButton1Click:Connect(function()
        buttons[3].Interactable = true
        ToolEnabled = true
        local leap = loadanim(233064613)
        local aim = loadanim(183412246)
        ToolEnabled = true
        
        playsound(140612763226642, 10)

        shockwave(30, 1)    
        hrp.Velocity = Vector3.new(0,250,0)
        leap:Play(0,999,0)
        
        task.wait(1)

        leap:Stop()
        aim:Play(0,999,0)
        playsound(73497595809221, 5, 0.8)
        LightningRandom(50, 10, 0, 8, 0, 1)
            
        spawn(function()
            local start = tick()
            local dir = (hrp.Position - cam.CFrame.Position).Unit
            local velo = dir * 200
            while tick() - start < 3 and task.wait()
            and hum.FloorMaterial == Enum.Material.Air do

                hrp.Velocity = velo
                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)
                * CFrame.Angles(math.rad(-90), 0, 0)
            end
            aim:Stop()
            hum:ChangeState("GettingUp")          
            ToolEnabled = true
            if hum.FloorMaterial ~= Enum.Material.Air then
                shockwave(60, 2.5)
                Hitbox(hrp.CFrame, Vector3.new(30,30,30))                
                cooldown(buttons[3], 0)
                LightningRandom(80, 7, 0, 13, 0, 1)
                playsound(2674547670, 7.5, 0.75)
                hrp.Velocity = Vector3.zero
            else
                cooldown(buttons[3], 0)
                playsound(9057745647, 3.5, 1.25)
            end
        end)        
    end)

    buttons[4].MouseButton1Click:Connect(function()
        local phrp = getclosest()
        if phrp then
            local f = Instance.new("Frame", Main)
            f.BackgroundColor3 = Color3.new(0,0,0)
            f.Size = UDim2.fromScale(1,1)
            f.AnchorPoint = Vector2.new(.5,.5)
            f.Position = UDim2.fromScale(.5,.5)
            f.ZIndex = 9e9
            ts:Create(f, TweenInfo.new(1), {["Transparency"] = 1}):Play()
            game.Debris:AddItem(f, 1)
            playsound(113108653649211, 10)
            
            hrp.CFrame = phrp.CFrame * CFrame.new(0,0,-5) * CFrame.Angles(0,math.rad(180),0)
            cooldown(buttons[4], 0)
        end
    end)

    buttons[5].MouseButton1Click:Connect(function()
        local charge = loadanim(97884040)
        local scythe = char["Right Arm"]:FindFirstChild("TheScythe")
        if not scythe then return end
        local handle        

        for i,v in next, scythe:GetDescendants() do
            if v:IsA("BasePart") then handle = v break end
        end
        if not handle then return end 
        handle.Transparency = 1
        charge:Play(.2)
        cooldown(buttons[5], 0)

        ToolEnabled = true

        local old = hum.WalkSpeed

        local s = Instance.new("Sound", workspace)
        s.SoundId = "rbxassetid://105257745504410"
        s.Volume = 5
        s.Looped = true
        s:Play()

        local att = Instance.new("Attachment", hrp)                
        att.Position = Vector3.new(0,1.5,-2.5)

        local b = Instance.new("BillboardGui", att)
        b.Size = UDim2.fromScale(4,4)
        local l = Instance.new("ImageLabel", b)
        l.AnchorPoint = Vector2.new(.5,.5)
        l.Position = UDim2.fromScale(.5,.5)
        l.Image = "rbxassetid://112882057182762"
        l.Size = UDim2.fromScale(1.5,1.5)
        l.Rotation = Random.new():NextNumber(-360, 360)
        l.BackgroundTransparency = 1

        spawn(function()
            while l and l.Parent and task.wait() do
                l.Size = UDim2.fromScale(
                    1 + math.abs(math.sin(tick()*30)) * 2,
                    1 + math.abs(math.sin(tick()*30)) * 2
                )
            end
        end)

        local tt = tick()
        repeat
            task.spawn(Lightning,
                att.WorldPosition, 
                att.WorldPosition + Vector3.new(
                    math.random(-30, 30),
                    math.random(10, 30),
                    math.random(-30, 30)
                ), 
                math.random(10,15), 
                0.04,
                25,
                Color3.new(1,1,1),
                .2
            )        
            task.wait(0.1)
        until tick() - tt > 1.5
        
        ToolEnabled = true
        s:Destroy()
        handle.Transparency = 0
        charge:Stop()        

        local cf = hrp.CFrame * CFrame.new(0,0,-150)
        local dis = (hrp.Position - cf.Position).Magnitude
        local posi = (hrp.CFrame * CFrame.new(0,0,-5)):Lerp(cf, .5)
        local size = Vector3.new(dis,30,30)

        playsound(102752336701880, 5)

        Hitbox(posi * CFrame.Angles(0,math.rad(-90),0), size)
        local pos = Instance.new("Part", workspace)
        pos.Anchored = true
        pos.Size = size
        pos.Shape = "Cylinder"
        pos.Material = "Neon"
        pos.CanCollide = false
        pos.CastShadow = false
        pos.CanQuery = false
        pos.CanTouch = false        
        pos.Anchored = true
        pos.Color = Color3.new(1,1,1)
        pos.CFrame = posi * CFrame.Angles(0, math.rad(90), 0)
        ts:Create(pos, TweenInfo.new(1), {["Transparency"] = 1, ["Size"] = Vector3.new(pos.Size.X, 0,0)}):Play()
        game.Debris:AddItem(pos, 1)

        hum.WalkSpeed = old
        att:Destroy()
    end)

    buttons[6].MouseButton1Click:Connect(function()
        ExtendTime(45)
        local h = char.DemiseH
        h.FillColor = Color3.new(1,1,1)
        ts:Create(h, TweenInfo.new(1), {["FillColor"] = Color3.new(0,0,0)}):Play()
        cooldown(buttons[6], 0)      
    end)

    buttons[7].MouseButton1Click:Connect(function()
        cooldown(buttons[7], 0)
        local swing = loadanim(218508052)
        ToolEnabled = true

        playsound(134126921218173, 7.5)
        for i = 1, 5 do
            task.spawn(Lightning,
                hrp.Position, 
                hrp.Position + Vector3.new(
                   Random.new():NextNumber(-50,50),
                   Random.new():NextNumber(0,50),
                   Random.new():NextNumber(-50,50)
                ), 
                15,
                0,
                5, 
                Color3.new(1,1,1), 
                1
            )      
        end

        swing:Play(0,999,0.85)
        repeat task.wait() until swing.TimePosition >= .72        
   
        local pos1 = hrp.CFrame * CFrame.new(0,0,-2.5)
        local pos2 = hrp.CFrame * CFrame.new(0,0,-800)
        
        local lerp = pos1:Lerp(pos2, .5)
        local look = CFrame.new(lerp.Position, pos2.Position)
        local size = Vector3.new(10,50,(pos2.Position - pos1.Position).Magnitude)

        HitboxLerp(pos1.Position, pos2.Position, size)
        local p = Instance.new("Part", workspace)
        p.Anchored = true
        p.CanCollide = false
        p.Color = Color3.new(1,1,1)
        p.Material = "Neon"
        p.CFrame = look
        p.Size = size
        ts:Create(p, TweenInfo.new(2, Enum.EasingStyle.Exponential), {["Size"] = Vector3.new(10,0,p.Size.Z), ["Transparency"] = 1}):Play()
        game.Debris:AddItem(p, 2)
        playsound(138837782673055, 7.5)
        ToolEnabled = true
    end)

    buttons[8].MouseButton1Click:Connect(function()
        cooldown(buttons[8], 0)
        local pray = loadanim(3027285080)
        pray:Play(.2)
        pray.TimePosition = .5
        hrp.Anchored = false
        
        ToolEnabled = true
        playsound(119582568310177, 7.5)
        task.wait(.85)
        shockwave(40, .75)
        playsound(111412627816301, 7.5)

        pray:Stop()
        hrp.Anchored = false              
        ToolEnabled = true

        for i = 1, 10 do
            task.spawn(Lightning,
                hrp.Position, 
                hrp.Position + Vector3.new(
                   Random.new():NextNumber(-50,50),
                   Random.new():NextNumber(0,50),
                   Random.new():NextNumber(-50,50)
                ), 
                15,
                0,
                5, 
                Color3.new(1,1,1), 
                .55
            )      
        end

        task.wait()
        Hitbox(hrp.CFrame, Vector3.new(30,30,30))
    end)

    buttons[9].MouseButton1Click:Connect(function()
        cooldown(buttons[9], 0)
        playsound(103529362101351, 10)
        if hum.FloorMaterial ~= Enum.Material.Air then
            shockwave(40, .75)
        end
        if hum.MoveDirection.Magnitude > 0 then
            hrp.Velocity = hrp.CFrame.LookVector * 250 + Vector3.new(0,135,0)
        else
            hrp.Velocity = Vector3.new(0,200,0)
        end
        local leap = loadanim(233064613)
        leap:Play(0,999,0)
        task.wait(.5)
        leap:Stop()
    end)

    cooldown(buttons[10], 0)
    buttons[10].MouseButton1Click:Connect(function()
        cooldown(buttons[10], 0)
        playsound("Roar.wav", 7.5)
        local p = Instance.new("MeshPart", workspace)
        p.CFrame = char.Head.CFrame
        p.MeshId = "rbxassetid://9165837187"
        p.Material = "Neon"
        p.Size = Vector3.one
        p.DoubleSided = true
        p.Anchored = true 
        p.Color = Color3.new(1,0,0)        
        p.CanCollide = false
        ts:Create(p, TweenInfo.new(7.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            ["Size"] = Vector3.new(500,500,500),
            ["Transparency"] = 1
        }):Play()
        game.Debris:AddItem(p, 7.5)
        cam.FieldOfView = 140
        ts:Create(cam, TweenInfo.new(5), {["FieldOfView"] = 70}):Play()

        local oldpos = hrp.CFrame
        spawn(function()
            local db = {}
            for i,v in next, workspace:GetPartBoundsInBox(hrp.CFrame, Vector3.new(500,500,500)) do
                local pchar = v:FindFirstAncestorOfClass("Model")
                if pchar and pchar ~= char 
                and game.Players:GetPlayerFromCharacter(pchar) and not db[pchar] then
                    db[pchar] = true
                    task.spawn(Fling, pchar)
                    task.wait(.6)
                elseif pchar and pchar ~= char
                and not game.Players:GetPlayerFromCharacter(pchar) then
                    db[pchar] = true
                    KillNPC(pchar)
                end
            end            
            hrp.CFrame = oldpos
        end)

        local roar = loadanim(93648331)
        roar:Play(.25,1,0.2)
        roar.TimePosition = .5

        local g = Instance.new("ScreenGui", gethui())
        g.ScreenInsets = "None"

        local l = Instance.new("ImageLabel", g)
        l.AnchorPoint = Vector2.new(.5,.5)
        l.Position = UDim2.fromScale(.5,.5)
        l.Size = UDim2.fromScale(1,1)
        l.ImageColor3 = Color3.new(1,0,0)
        l.BackgroundTransparency = 1
        l.ImageTransparency = 1
        l.Image = "rbxassetid://18720210000"
        ts:Create(l, TweenInfo.new(.3), {["ImageTransparency"] = 0}):Play()
        task.wait(3.25)
        ts:Create(l, TweenInfo.new(1), {["ImageTransparency"] = 1}):Play()
        game.Debris:AddItem(g, 1)
        roar:Stop(.5)
    end)
    return Time
end

function Intro()
    pcall(function() gethui().DemiseGui:Destroy() end)
    pcall(function() workspace.DemiseShadows:Destroy() end)
    pcall(function() workspace["Demise is cadence real"]:Destroy() end)
    pcall(function() char["Right Arm"].TheScythe:Destroy() end)
    pcall(function() workspace.DemiseTheme:Destroy() end)
    for i,v in next, plr.Backpack:GetChildren() do
        if v:IsA("Tool") and v.Name == "Scythe Slash" then v:Destroy() end
    end

    for i,v in next, hum:GetPlayingAnimationTracks() do
         if v.Animation then
             v:Stop()
         end
    end

    Highlight()
    Shadows()

    local s = Instance.new("Sound", workspace)
    s.Name = "Evil Apparation"
    s.SoundId = getcustomasset("Appear.wav")
    s.Volume = 5
    s.Looped = true
    s.Pitch = 0.9
    s:Play()

    hrp.Anchored = true
    local g = Instance.new("ScreenGui", gethui())
    g.ScreenInsets = "None"
    local f = Instance.new("Frame", g)
    f.Size = UDim2.fromScale(1,1)
    f.BackgroundColor3 = Color3.new(0,0,0)
    f.AnchorPoint = Vector2.new(.5,.5)
    f.Position = UDim2.fromScale(.5,.5)
    ts:Create(f, TweenInfo.new(5), {["Transparency"] = 1}):Play()    

    task.wait(5)
    playsound(130700612479031, 5)

    local an = loadanim(94160581)
    an:Play(0,999,0.35)
    Scythe()
    an.Ended:Wait()
    hrp.Anchored = false
    s:Destroy()

    f.Transparency = 0
    f.BackgroundColor3 = Color3.new(1,1,1)    
    game.Debris:AddItem(g, 2)    
    for i,v in next, char:GetDescendants() do
        if v:IsA("BasePart") then
            local new = v:Clone()
            new.Parent = f
        end
    end
    ts:Create(f, TweenInfo.new(.5), {["Transparency"] = 1}):Play()        
    playsound(115950712237348, 5)
    loadanim(1323180718):Play(0,999,0)
    task.wait(1)

end

function LoadDemise()            
    Intro()
    
    DemiseAnim()            
    Tool()
    DemiseTheme()    
    DemiseC(100, Gui())

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Note",
        Text = "Script made by VirusSX!",
        Duration = 10,
        Button1 = "Ok."
    })
end

msg.Text = "Loaded! Enjoy ;) {NoCD!} by IDioTKing"
task.wait(2)
msg:Destroy()
LoadDemise()
