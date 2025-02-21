local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst   = game:GetService("ReplicatedFirst")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Lighting          = game:GetService("Lighting")
local Players           = game:GetService("Players")

local originalTimeOfDay = Lighting.TimeOfDay or "12:00:00"
local originalAmbientColor = Lighting.Ambient
local originalOutdoorAmbientColor = Lighting.OutdoorAmbient
local originalBrightness = Lighting.Brightness or 2

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer.PlayerGui
local Mouse       = LocalPlayer:GetMouse()
local Camera      = workspace.CurrentCamera
RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
end)

local function Create(Object, Properties, Parent)
    local Obj = Instance.new(Object)

    for i,v in pairs (Properties) do
        Obj[i] = v
    end
    if Parent ~= nil then
        Obj.Parent = Parent
    end

    return Obj
end

local function GetCharacter()
end
local function GetHumanoid()
end
local function GetHealth()
end
local function GetBodypart()
end


local menu
do
    local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/vy-xa/havoc.lol/main/lib.lua"))()

    menu = library.new([[havoc<font color="rgb(88,32,88)">.lol</font>]], "nemv2\\")
    local tabs = {
        menu.new_tab("rbxassetid://7300535052"),
        menu.new_tab("rbxassetid://7300480952"),
        menu.new_tab("rbxassetid://7300486042"),
    }

    do

        local antiaim = tabs[1].new_section("antiaim")

        local direction = antiaim.new_sector("direction")
        direction.element("Toggle", "enabled"):add_keybind()
        direction.element("Dropdown", "yaw base", {options = {"camera", "random", "spin"}})
        direction.element("Slider", "yaw offset", {default = {min = -180, max = 180, default = 0}})
        direction.element("Dropdown", "yaw modifier", {options = {"none", "jitter", "offset jitter"}})
        direction.element("Slider", "modifier offset", {default = {min = -180, max = 180, default = 0}})
        direction.element("Toggle", "force angles")


        local fakelag = antiaim.new_sector("fakelag", "Right")
        fakelag.element("Toggle", "enabled"):add_keybind()
        fakelag.element("Dropdown", "method", {options = {"static", "random"}})
        fakelag.element("Slider", "limit", {default = {min = 1, max = 50, default = 6}})
        fakelag.element("Toggle", "visualize"):add_color(nil, true)
        fakelag.element("Toggle", "freeze world", nil, function(state)
            if menu.values[1].antiaim.fakelag["freeze world"].Toggle and menu.values[1].antiaim.fakelag["$freeze world"].Active then
                settings().Network.IncomingReplicationLag = 1000
            else
                settings().Network.IncomingReplicationLag = 0
            end
        end):add_keybind(nil, function(state)
            if menu.values[1].antiaim.fakelag["freeze world"].Toggle and menu.values[1].antiaim.fakelag["$freeze world"].Active then
                settings().Network.IncomingReplicationLag = 1000
            else
                settings().Network.IncomingReplicationLag = 0
            end
        end)

        local Line = Drawing.new("Line")
        Line.Visible = false
        Line.Transparency = 1
        Line.Color = Color3.new(1,1,1)
        Line.Thickness = 1
        Line.ZIndex = 1

        local EnabledPosition = Vector3.new()
        fakelag.element("Toggle", "no send", nil, function(State)
            if menu.values[1].antiaim.fakelag["no send"].Toggle and menu.values[1].antiaim.fakelag["$no send"].Active then
                local SelfCharacter = LocalPlayer.Character
                local SelfRootPart, SelfHumanoid = SelfCharacter and SelfCharacter:FindFirstChild("HumanoidRootPart"), SelfCharacter and SelfCharacter:FindFirstChildOfClass("Humanoid")
                if not SelfCharacter or not SelfRootPart or not SelfHumanoid then Line.Visible = false return end

                EnabledPosition = SelfRootPart.Position
            end
        end):add_keybind(nil, function(State)
            if menu.values[1].antiaim.fakelag["no send"].Toggle and menu.values[1].antiaim.fakelag["$no send"].Active then
                local SelfCharacter = LocalPlayer.Character
                local SelfRootPart, SelfHumanoid = SelfCharacter and SelfCharacter:FindFirstChild("HumanoidRootPart"), SelfCharacter and SelfCharacter:FindFirstChildOfClass("Humanoid")
                if not SelfCharacter or not SelfRootPart or not SelfHumanoid then Line.Visible = false return end

                EnabledPosition = SelfRootPart.Position
            end
        end)

        local WasEnabled = false
        local FakelagLoop = RunService.Heartbeat:Connect(function()
            local Enabled = menu.values[1].antiaim.fakelag["no send"].Toggle and menu.values[1].antiaim.fakelag["$no send"].Active or false

            local SelfCharacter = LocalPlayer.Character
            local SelfRootPart, SelfHumanoid = SelfCharacter and SelfCharacter:FindFirstChild("HumanoidRootPart"), SelfCharacter and SelfCharacter:FindFirstChildOfClass("Humanoid")
            if not SelfCharacter or not SelfRootPart or not SelfHumanoid then Line.Visible = false return end

            sethiddenproperty(SelfRootPart, "NetworkIsSleeping", Enabled)

            Line.Visible = Enabled
            local StartPos = Camera:WorldToViewportPoint(SelfRootPart.Position)
            Line.From = Vector2.new(StartPos.X, StartPos.Y)
            local EndPos, OnScreen = Camera:WorldToViewportPoint(EnabledPosition)
            if not OnScreen then
                Line.Visible = false
            end
            Line.To = Vector2.new(EndPos.X, EndPos.Y)
        end)

        task.spawn(function()
            local Network = game:GetService("NetworkClient")
            local LagTick = 0

            while true do
                task.wait(1/16)
                LagTick = math.clamp(LagTick + 1, 0, menu.values[1].antiaim.fakelag.limit.Slider)
                if menu.values[1].antiaim.fakelag.enabled.Toggle and menu.values[1].antiaim.fakelag["$enabled"].Active and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    if LagTick == (menu.values[1].antiaim.fakelag.method.Dropdown == "static" and menu.values[1].antiaim.fakelag.limit.Slider or math.random(1, menu.values[1].antiaim.fakelag.limit.Slider)) then
                        Network:SetOutgoingKBPSLimit(9e9)
                        LagTick = 0

                        if LocalPlayer.Character:FindFirstChild("Fakelag") then
                            LocalPlayer.Character:FindFirstChild("Fakelag"):ClearAllChildren()
                        else
                            local Folder = Instance.new("Folder")
                            Folder.Name = "Fakelag"
                            Folder.Parent = LocalPlayer.Character
                        end
                        if menu.values[1].antiaim.fakelag.visualize.Toggle then
                            LocalPlayer.Character.Archivable = true
                            local Clone = LocalPlayer.Character:Clone()
                            for _,Obj in next, Clone:GetDescendants() do
                                if Obj.Name == "HumanoidRootPart" or Obj:IsA("Humanoid") or Obj:IsA("LocalScript") or Obj:IsA("Script") or Obj:IsA("Decal") then
                                    Obj:Destroy()
                                elseif Obj:IsA("BasePart") or Obj:IsA("Meshpart") or Obj:IsA("Part") then
                                    if Obj.Transparency == 1 then
                                        Obj:Destroy()
                                    else
                                        Obj.CanCollide = false
                                        Obj.Anchored = true
                                        Obj.Material = "ForceField"
                                        Obj.Color = menu.values[1].antiaim.fakelag["$visualize"].Color
                                        Obj.Transparency = menu.values[1].antiaim.fakelag["$visualize"].Transparency
                                        Obj.Size = Obj.Size + Vector3.new(0.03, 0.03, 0.03)
                                    end
                                end
                                pcall(function()
                                    Obj.CanCollide = false
                                end)
                            end
                            Clone.Parent = LocalPlayer.Character.Fakelag
                        end
                    else
                        Network:SetOutgoingKBPSLimit(1)
                    end
                else
                    if LocalPlayer.Character then
                        if LocalPlayer.Character:FindFirstChild("Fakelag") then
                            LocalPlayer.Character:FindFirstChild("Fakelag"):ClearAllChildren()
                        else
                            local Folder = Instance.new("Folder")
                            Folder.Name = "Fakelag"
                            Folder.Parent = LocalPlayer.Character
                        end
                    end
                    Network:SetOutgoingKBPSLimit(9e9)
                end
            end
        end)
    end

    do
        local players = tabs[2].new_section("players")

        local esp = players.new_sector("esp")
        esp.element("Toggle", "enabled"):add_keybind()
        esp.element("Slider", "max distance", {default = {min = 250, max = 15000, default = 15000}})

        local enemies = players.new_sector("enemies")
        enemies.element("Toggle", "box"):add_color({Color = Color3.fromRGB(255, 255, 255)})
        enemies.element("Toggle", "name"):add_color({Color = Color3.fromRGB(255, 255, 255)})
        enemies.element("Toggle", "health"):add_color({Color = Color3.fromRGB(0, 255, 0)})
        enemies.element("Toggle", "indicators"):add_color({Color = Color3.fromRGB(255, 255, 255)})
        enemies.element("Combo", "types", {options = {"tool", "distance"}})

        local friendlies = players.new_sector("friendlies")
        friendlies.element("Toggle", "box"):add_color({Color = Color3.fromRGB(255, 255, 255)})
        friendlies.element("Toggle", "name"):add_color({Color = Color3.fromRGB(255, 255, 255)})
        friendlies.element("Toggle", "health"):add_color({Color = Color3.fromRGB(0, 255, 0)})
        friendlies.element("Toggle", "indicators"):add_color({Color = Color3.fromRGB(255, 255, 255)})
        friendlies.element("Combo", "types", {options = {"tool", "distance"}})

        local oof = players.new_sector("out of fov", "Right")
        oof.element("Toggle", "enemies"):add_color({Color = Color3.fromRGB(84, 101, 255)})
        oof.element("Toggle", "teammates"):add_color({Color = Color3.fromRGB(84, 101, 255)})
        oof.element("Slider", "size", {default = {min = 10, max = 15, default = 15}})
        oof.element("Slider", "offset", {default = {min = 100, max = 700, default = 400}})
        oof.element("Combo", "settings", {options = {"outline", "blinking"}})

        local function UpdateChams()
            for _,Player in next, Players:GetPlayers() do
                if Player ~= LocalPlayer then
                    ApplyChams(Player)
                end
            end
        end

        local chams = players.new_sector("chams", "Right")
        chams.element("Toggle", "enemies", nil, UpdateChams):add_color({Color = Color3.fromRGB(141, 115, 245)}, false, UpdateChams)
        chams.element("Toggle", "friendlies", nil, UpdateChams):add_color({Color = Color3.fromRGB(102, 255, 102)}, false, UpdateChams)
        chams.element("Toggle", "through walls", nil, UpdateChams):add_color({Color = Color3.fromRGB(170, 170, 170)}, false, UpdateChams)

        local drawings = players.new_sector("drawings", "Right")
        drawings.element("Dropdown", "font", {options = {"Plex", "Monospace", "System", "UI"}})
        drawings.element("Dropdown", "surround", {options = {"none", "[]", "--", "<>"}})

        local other = tabs[2].new_section("other")

        local self = other.new_sector("self", "Left")
        self.element("Toggle", "fov changer"):add_keybind()
        self.element("Slider", "field of view", {default = {min = 30, max = 120, default = 80}})

        local ltng = other.new_sector("lighting", "Right")
        ltng.element("Toggle", "night", nil)
        ltng.element("Toggle", "brightness changer", nil)
        ltng.element("Slider", "brightness", {default = {min = 0, max = 10, default = originalBrightness}})
        ltng.element("Toggle", "ambient", nil):add_color({Color = Color3.fromRGB(255, 255, 255)})
        ltng.element("Toggle", "outdoor ambient", nil):add_color({Color = Color3.fromRGB(255, 255, 255)})
    end
    do
        local misc = tabs[3].new_section("misc")

        local character = misc.new_sector("character")
        character.element("Toggle", "walkspeed"):add_keybind()
        character.element("Slider", "speed", {default = {min = 20, max = 200, default = 50}})
        character.element("Toggle", "jumppower"):add_keybind()
        character.element("Slider", "power", {default = {min = 50, max = 200, default = 50}})
        character.element("Toggle", "noclip"):add_keybind()

        local NoclipLoop = RunService.Stepped:Connect(function()
            if not LocalPlayer.Character then return end
            if not menu.values[3].misc.character.noclip.Toggle and not menu.values[3].misc.character["$noclip"].Toggle then return end

            for _,part in pairs (LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end)
    end
end

function ApplyChams(Player)
    if Player.Character == nil then return end

    local BodyParts =
    {
    "Torso", "UpperTorso", "LowerTorso",
    "Left Arm", "LeftUpperArm","LeftLowerArm", "LeftHand",
    "Right Arm", "RightUpperArm", "RightLowerArm", "RightHand",
    "Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"
    }

    local Enabled, Color
    if Player.Team ~= LocalPlayer.Team then
        Enabled = menu.values[2].players.chams["enemies"].Toggle
        Color = menu.values[2].players.chams["$enemies"].Color
    else
        Enabled = menu.values[2].players.chams["friendlies"].Toggle
        Color = menu.values[2].players.chams["$friendlies"].Color
    end
    local Enabled2, Color2 = menu.values[2].players.chams["through walls"].Toggle, menu.values[2].players.chams["$through walls"].Color

    local function ApplyHandle(Part, Handle)
        local Inline, __Outline = Part:FindFirstChild("Inline"), Part:FindFirstChild("_Outline")
        if not Inline then
            Inline = Create(Handle, {
                Name = "Inline",
                Color3 = Color2,
                Transparency = 0.75,
                ZIndex = 2,
                AlwaysOnTop = true,
                AdornCullingMode = "Never",
                Visible = Enabled and Enabled2 or false,
                Adornee = Part,
            })
            if Handle == "BoxHandleAdornment" then
                Inline.Size = Part.Size + Vector3.new(0.05, 0.05, 0.05)
            else
                Inline.Radius = Part.Size.X / 2 + 0.15
                Inline.Height = Part.Size.Y + 0.3
                Inline.CFrame = CFrame.new(Vector3.new(), Vector3.new(0,1,0))
            end
        end
        if not _Outline then
            _Outline = Create(Handle, {
                Name = "_Outline",
                Color3 = Color,
                Transparency = 0.55,
                Transparency = 0.55,
                ZIndex = 2,
                AlwaysOnTop = false,
                AdornCullingMode = "Never",
                Visible = Enabled,
                Adornee = Part,
            })
            if Handle == "BoxHandleAdornment" then
                _Outline.Size = Part.Size + Vector3.new(0.1, 0.1, 0.1)
            else
                _Outline.Radius = Part.Size.X / 2 + 0.2
                _Outline.Height = Part.Size.Y + 0.35
                _Outline.CFrame = CFrame.new(Vector3.new(), Vector3.new(0,1,0))
            end
        end
        Inline.Color3 = Color2
        Inline.Visible = Enabled and Enabled2 or false
        _Outline.Color3 = Color
        _Outline.Visible = Enabled

        Inline.Parent = Part
        _Outline.Parent = Part
		
        return Inline, _Outline
    end

    for _,Part in next, Player.Character:GetChildren() do
        if Part.Name == "Head" and not Part:IsA("LocalScript") and not Part:IsA("Accessory") then
            ApplyHandle(Part, "CylinderHandleAdornment")
        elseif table.find(BodyParts, Part.Name) and not Part:IsA("LocalScript") and not Part:IsA("Accessory") then
            ApplyHandle(Part, "BoxHandleAdornment")
        end
    end

    Player.Character.ChildAdded:Connect(function(Child)
        if Child.Name == "Head" and not Child:IsA("LocalScript") and not Child:IsA("Accessory") then
            ApplyHandle(Child, "CylinderHandleAdornment")
        elseif table.find(BodyParts, Child.Name) and not Child:IsA("LocalScript") and not Child:IsA("Accessory") then
            ApplyHandle(Child, "BoxHandleAdornment")
        end
    end)
end

Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function()
        RunService.RenderStepped:Wait()
        ApplyChams(Player)
    end)

    Player:GetPropertyChangedSignal("Team"):Connect(function()
        ApplyChams(Player)
    end)
end)
for _,Player in next, Players:GetPlayers() do
    if Player ~= LocalPlayer then
        ApplyChams(Player)

        Player.CharacterAdded:Connect(function()
            RunService.RenderStepped:Wait()
            ApplyChams(Player)
        end)

        Player:GetPropertyChangedSignal("Team"):Connect(function()
            ApplyChams(Player)
        end)
    end
end
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
    for _,Player in next, Players:GetPlayers() do
        ApplyChams(Player)
    end
end)


local OriginalWalkspeed = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed or 16
local OriginalJumpPower = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower or 50
local OriginalJumpHeight = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpHeight or 7.2
local OriginalAutoRotate = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").AutoRotate or true
local AntiaimAngle = CFrame.new()
local Jitter = false
local FOV = Camera.FieldOfView
RunService.RenderStepped:Connect(function()
    local SelfCharacter = LocalPlayer.Character
    local SelfRootPart, SelfHumanoid = SelfCharacter and SelfCharacter:FindFirstChild("HumanoidRootPart"), SelfCharacter and SelfCharacter:FindFirstChildOfClass("Humanoid")
    if not SelfCharacter or not SelfRootPart or not SelfHumanoid then return end

    if menu.values[3].misc.character.walkspeed.Toggle and menu.values[3].misc.character["$walkspeed"].Active then
        SelfHumanoid.WalkSpeed = menu.values[3].misc.character.speed.Slider
    else
        SelfHumanoid.WalkSpeed = OriginalWalkspeed
    end

    if menu.values[3].misc.character.jumppower.Toggle and menu.values[3].misc.character["$jumppower"].Active then
        SelfHumanoid.JumpPower = menu.values[3].misc.character.power.Slider
        SelfHumanoid.JumpHeight = menu.values[3].misc.character.height.Slider
    else
        SelfHumanoid.JumpPower = OriginalJumpPower
        SelfHumanoid.JumpHeight = OriginalJumpHeight
    end
    if menu.values[1].antiaim.direction.enabled.Toggle and menu.values[1].antiaim.direction["$enabled"].Active then
        SelfHumanoid.AutoRotate = false

        local Angle do
            Angle = -math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X) + math.rad(-90)
            if menu.values[1].antiaim.direction["yaw base"].Dropdown == "random" then
                Angle = -math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X) + math.rad(math.random(0, 360))
            elseif menu.values[1].antiaim.direction["yaw base"].Dropdown == "spin" then
                Angle = -math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X) + tick() * 10 % 360
            end
        end

        local Offset = math.rad(menu.values[1].antiaim.direction["yaw offset"].Slider)
        Jitter = not Jitter
        if Jitter then
            if menu.values[1].antiaim.direction["yaw modifier"].Dropdown == "jitter" then
                Offset = math.rad(menu.values[1].antiaim.direction["modifier offset"].Slider)
            elseif menu.values[1].antiaim.direction["yaw modifier"].Dropdown == "offset jitter" then
                Offset = Offset + math.rad(menu.values[1].antiaim.direction["modifier offset"].Slider)
            end
        end
        local NewAngle = CFrame.new(SelfRootPart.Position) * CFrame.Angles(0, Angle + Offset, 0)
        local function ToYRotation(_CFrame)
            local X, Y, Z = _CFrame:ToOrientation()
            return CFrame.new(_CFrame.Position) * CFrame.Angles(0, Y, 0)
        end
        if menu.values[1].antiaim.direction["yaw base"].Dropdown == "targets" then
            local Target
            local Closest = 9999
            for _,Player in next, Players:GetPlayers() do
                if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then continue end

                local Pos, OnScreen = Camera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)
                local Magnitude = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if Closest > Magnitude then
                    Target = Player.Character.HumanoidRootPart
                    Closest = Magnitude
                end
            end
            if Target ~= nil then
                NewAngle = CFrame.new(SelfRootPart.Position, Target.Position) * CFrame.Angles(0, 0, 0)
            end
        end
        AntiaimAngle = Angle + Offset
        SelfRootPart.CFrame = ToYRotation(NewAngle)
    else
        SelfHumanoid.AutoRotate = OriginalAutoRotate
    end
    if menu.values[2].other.self["fov changer"].Toggle and menu.values[2].other.self["$fov changer"].Active then
        Camera.FieldOfView = menu.values[2].other.self["field of view"].Slider
    else
        Camera.FieldOfView = FOV
    end
    if menu.values[2].other.lighting["night"].Toggle then
        Lighting.TimeOfDay = "00:00:00"
    else
        Lighting.TimeOfDay = originalTimeOfDay
    end
    if menu.values[2].other.lighting["ambient"].Toggle then
        Lighting.Ambient = menu.values[2].other.lighting["$ambient"].Color
    else
        game.Lighting.Ambient = originalAmbientColor
    end
    if menu.values[2].other.lighting["outdoor ambient"].Toggle then
        Lighting.OutdoorAmbient = menu.values[2].other.lighting["$outdoor ambient"].Color
    else
        game.Lighting.OutdoorAmbient = originalOutdoorAmbientColor
    end
    if menu.values[2].other.lighting["brightness changer"].Toggle then
        Lighting.Brightness = menu.values[2].other.lighting["brightness"].Slider
    else
        Lighting.Brightness = originalBrightness
    end
end)

local OldNewIndex; OldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
    local SelfName = tostring(self)

    if not checkcaller() then
        if key == "FieldOfView" then
            FOV = value
            if menu.values[2].other.self["fov changer"].Toggle and menu.values[2].other.self["$fov changer"].Active then
                value = menu.values[2].other.self["field of view"].Slider
            end
        end
        if key == "WalkSpeed" then
            OriginalWalkspeed = value
            if menu.values[3].misc.character.walkspeed.Toggle and menu.values[3].misc.character["$walkspeed"].Active then
                value = menu.values[3].misc.character.speed.Slider
            end
        end
        if key == "JumpPower" then
            OriginalJumpPower = value
            if menu.values[3].misc.character.jumppower.Toggle and menu.values[3].misc.character["$jumppower"].Active then
                value = menu.values[3].misc.character.power.Slider
            end
        end
        if key == "JumpHeight" then
            OriginalJumpHeight = value
            if menu.values[3].misc.character.jumppower.Toggle and menu.values[3].misc.character["$jumppower"].Active then
                value = menu.values[3].misc.character.height.Slider
            end
        end
        if key == "AutoRotate" then
            OriginalAutoRotate = value
            if menu.values[1].antiaim.direction.enabled.Toggle and menu.values[1].antiaim.direction["$enabled"].Active then
                value = false
            end
        end
        if SelfName == "HumanoidRootPart" and key == "CFrame" then
            if menu.values[1].antiaim.direction.enabled.Toggle and menu.values[1].antiaim.direction["$enabled"].Active and menu.values[1].antiaim.direction["force angles"].Toggle then
                value = CFrame.new(value.Position) * CFrame.Angles(0, AntiaimAngle, 0)
            end
        end
        

        return OldNewIndex(self, key, value)
    end

    return OldNewIndex(self, key, value)
end)
local _Humanoid do
    RunService.RenderStepped:Connect(function()
        _Humanoid = nil
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            _Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end)
end

local PlayerDrawings = {}
local Utility        = {}

Utility.Settings = {
    Line = {
        Thickness = 1,
        Color = Color3.fromRGB(0, 255, 0)
    },
    Text = {
        Size = 13,
        Center = true,
        Outline = true,
        Font = Drawing.Fonts.Plex,
        Color = Color3.fromRGB(255, 255, 255)
    },
    Square = {
        Thickness = 1,
        Color = menu.values[2].players.enemies["$box"].Color,
        Filled = false,
    },
    Triangle = {
        Color = Color3.fromRGB(255, 255, 255),
        Filled = true,
        Visible = false,
        Thickness = 1,
    }
}
function Utility.New(Type, Outline, Name)
    local drawing = Drawing.new(Type)
    for i, v in pairs(Utility.Settings[Type]) do
        drawing[i] = v
    end
    if Outline then
        drawing.Color = Color3.new(0,0,0)
        drawing.Thickness = 3
    end
    return drawing
end
function Utility.Add(Player)
    if not PlayerDrawings[Player] then
        PlayerDrawings[Player] = {
            Offscreen = Utility.New("Triangle", nil, "Offscreen"),
            Name = Utility.New("Text", nil, "Name"),
            Tool = Utility.New("Text", nil, "Tool"),
            Distance = Utility.New("Text", nil, "Distance"),
            BoxOutline = Utility.New("Square", true, "BoxOutline"),
            Box = Utility.New("Square", nil, "Box"),
            HealthOutline = Utility.New("Line", true, "HealthOutline"),
            Health = Utility.New("Line", nil, "Health")
        }
    end
end

for _,Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        Utility.Add(Player)
    end
end
Players.PlayerAdded:Connect(Utility.Add)
Players.PlayerRemoving:Connect(function(Player)
    if PlayerDrawings[Player] then
        for i,v in pairs(PlayerDrawings[Player]) do
            if v then
                v:Remove()
            end
        end

        PlayerDrawings[Player] = nil
    end
end)

local ESPLoop = game:GetService("RunService").RenderStepped:Connect(function()
    for _,Player in pairs (Players:GetPlayers()) do
        local PlayerDrawing = PlayerDrawings[Player]
        if not PlayerDrawing then continue end

        for _,Drawing in pairs (PlayerDrawing) do
            Drawing.Visible = false
        end

        if not menu.values[2].players.esp.enabled.Toggle or not menu.values[2].players.esp["$enabled"].Active then continue end

        local Character = Player.Character
        local RootPart, Humanoid = Character and Character:FindFirstChild("HumanoidRootPart"), Character and Character:FindFirstChildOfClass("Humanoid")
        if not Character or not RootPart or not Humanoid then continue end

        local DistanceFromCharacter = (Camera.CFrame.Position - RootPart.Position).Magnitude
        if menu.values[2].players.esp["max distance"].Slider < DistanceFromCharacter then continue end

        local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
        if not OnScreen then
            local VisualTable = menu.values[2].players["out of fov"]
            if Player.Team ~= LocalPlayer.Team and not VisualTable.enemies.Toggle then continue end
            if Player.Team == LocalPlayer.Team and not VisualTable.teammates.Toggle then continue end

            local RootPos = RootPart.Position
            local CameraVector = Camera.CFrame.Position
            local LookVector = Camera.CFrame.LookVector

            local Dot = LookVector:Dot(RootPart.Position - Camera.CFrame.Position)
            if Dot <= 0 then
                RootPos = (CameraVector + ((RootPos - CameraVector) - ((LookVector * Dot) * 1.01)))
            end

            local ScreenPos, OnScreen = Camera:WorldToScreenPoint(RootPos)
            if not OnScreen then
                local Drawing = PlayerDrawing.Offscreen
                local FOV     = 800 - menu.values[2].players["out of fov"].offset.Slider
                local Size    = menu.values[2].players["out of fov"].size.Slider

                local Center = (Camera.ViewportSize / 2)
                local Direction = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Unit
                local Radian = math.atan2(Direction.X, Direction.Y)
                local Angle = (((math.pi * 2) / FOV) * Radian)
                local ClampedPosition = (Center + (Direction * math.min(math.abs(((Center.Y - FOV) / math.sin(Angle)) * FOV), math.abs((Center.X - FOV) / (math.cos(Angle)) / 2))))
                local Point = Vector2.new(math.floor(ClampedPosition.X - (Size / 2)), math.floor((ClampedPosition.Y - (Size / 2) - 15)))

                local function Rotate(point, center, angle)
                    angle = math.rad(angle)
                    local rotatedX = math.cos(angle) * (point.X - center.X) - math.sin(angle) * (point.Y - center.Y) + center.X
                    local rotatedY = math.sin(angle) * (point.X - center.X) + math.cos(angle) * (point.Y - center.Y) + center.Y

                    return Vector2.new(math.floor(rotatedX), math.floor(rotatedY))
                end

                local Rotation = math.floor(-math.deg(Radian)) - 47
                Drawing.PointA = Rotate(Point + Vector2.new(Size, Size), Point, Rotation)
                Drawing.PointB = Rotate(Point + Vector2.new(-Size, -Size), Point, Rotation)
                Drawing.PointC = Rotate(Point + Vector2.new(-Size, Size), Point, Rotation)
                Drawing.Color = Player.Team ~= LocalPlayer.Team and VisualTable["$enemies"].Color or VisualTable["$teammates"].Color

                Drawing.Filled = not table.find(menu.values[2].players["out of fov"].settings.Combo, "outline") and true or false
                if table.find(menu.values[2].players["out of fov"].settings.Combo, "blinking") then
                    Drawing.Transparency = (math.sin(tick() * 5) + 1) / 2
                else
                    Drawing.Transparency = 1
                end

                Drawing.Visible = true
            end
        else
            local VisualTable = Player.Team ~= LocalPlayer.Team and menu.values[2].players.enemies or menu.values[2].players.friendlies

            local Size           = (Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, 2.6, 0)).Y) / 2
            local BoxSize        = Vector2.new(math.floor(Size * 1.5), math.floor(Size * 1.9))
            local BoxPos         = Vector2.new(math.floor(Pos.X - Size * 1.5 / 2), math.floor(Pos.Y - Size * 1.6 / 2))

            local Name           = PlayerDrawing.Name
            local Tool           = PlayerDrawing.Tool
            local Distance       = PlayerDrawing.Distance
            local Box            = PlayerDrawing.Box
            local BoxOutline     = PlayerDrawing.BoxOutline
            local Health         = PlayerDrawing.Health
            local HealthOutline  = PlayerDrawing.HealthOutline

            if VisualTable.box.Toggle then
                Box.Size = BoxSize
                Box.Position = BoxPos
                Box.Visible = true
                Box.Color = VisualTable["$box"].Color
                BoxOutline.Size = BoxSize
                BoxOutline.Position = BoxPos
                BoxOutline.Visible = true
            end

            if VisualTable.health.Toggle then
                Health.From = Vector2.new((BoxPos.X - 5), BoxPos.Y + BoxSize.Y)
                Health.To = Vector2.new(Health.From.X, Health.From.Y - (Humanoid.Health / Humanoid.MaxHealth) * BoxSize.Y)
                Health.Color = VisualTable["$health"].Color
                Health.Visible = true

                HealthOutline.From = Vector2.new(Health.From.X, BoxPos.Y + BoxSize.Y + 1)
                HealthOutline.To = Vector2.new(Health.From.X, (Health.From.Y - 1 * BoxSize.Y) -1)
                HealthOutline.Visible = true
            end

            local function SurroundString(String, Add)
                local Left = ""
                local Right = ""

                local Remove = false
                if Add == "[]" then
                    String = string.gsub(String, "%[", "")
                    String = string.gsub(String, "%[", "")

                    Left = "["
                    Right = "]"
                elseif Add == "--" then
                    Left = "-"
                    Right = "-"
                    Remove = true
                elseif Add == "<>" then
                    Left = "<"
                    Right = ">"
                    Remove = true
                end
                if Remove then
                    String = string.gsub(String, Left, "")
                    String = string.gsub(String, Right, "")
                end

                return Left..String..Right
            end

            if VisualTable.name.Toggle then
                Name.Text = SurroundString(Player.Name, menu.values[2].players.drawings.surround.Dropdown)
                Name.Position = Vector2.new(BoxSize.X / 2 + BoxPos.X, BoxPos.Y - 16)
                Name.Color = VisualTable["$name"].Color
                Name.Font = Drawing.Fonts[menu.values[2].players.drawings.font.Dropdown]
                Name.Visible = true
            end

            if VisualTable.indicators.Toggle then
                local BottomOffset = BoxSize.Y + BoxPos.Y + 1
                if table.find(VisualTable.types.Combo, "tool") then
                    local Equipped = Player.Character:FindFirstChildOfClass("Tool") and Player.Character:FindFirstChildOfClass("Tool").Name or "None"
                    Equipped = SurroundString(Equipped, menu.values[2].players.drawings.surround.Dropdown)
                    Tool.Text = Equipped
                    Tool.Position = Vector2.new(BoxSize.X/2 + BoxPos.X, BottomOffset)
                    Tool.Color = VisualTable["$indicators"].Color
                    Tool.Font = Drawing.Fonts[menu.values[2].players.drawings.font.Dropdown]
                    Tool.Visible = true
                    BottomOffset = BottomOffset + 15
                end
                if table.find(VisualTable.types.Combo, "distance") then
                    Distance.Text = SurroundString(math.floor(DistanceFromCharacter).."m", menu.values[2].players.drawings.surround.Dropdown)
                    Distance.Position = Vector2.new(BoxSize.X/2 + BoxPos.X, BottomOffset)
                    Distance.Color = VisualTable["$indicators"].Color
                    Distance.Font = Drawing.Fonts[menu.values[2].players.drawings.font.Dropdown]
                    Distance.Visible = true

                    BottomOffset = BottomOffset + 15
                end
            end
        end
    end
end)
