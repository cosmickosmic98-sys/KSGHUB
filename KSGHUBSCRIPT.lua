local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()


local Window = Rayfield:CreateWindow({
   Name = "KSG HUB",
   Icon = 0,
   LoadingTitle = "Best FSS scripts",
   LoadingSubtitle = "by LazixRobloxx",
   ShowText = "Rayfield",
   Theme = "Amethyst",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

      ConfigurationSaving = {
      Enabled = false,
   },


   KeySystem = false,

   KeySettings = {
      Title = "Lazix Keys",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Lazix Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"LazixPlaystyle"}
   }
})


-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Walkspeed Settings

local walkSpeedEnabled = false
local walkSpeedValue = 32

local originalWalkSpeed = nil

local speedConnection


-- JumpPower Settings

local jumpPowerEnabled = false
local jumpPowerValue = 100

local originalJumpPower = nil

local jumpConnection


-- Hitbox Settings

local hitboxEnabled = false

local hitboxX = 4.521
local hitboxY = 5.73
local hitboxZ = 2.398

local hitboxTransparency = 0

local tackleHitboxEnabled = false

local tackleHitboxX = 2.57
local tackleHitboxY = 5.73
local tackleHitboxZ = 2.064

local tackleHitboxTransparency = 0

-- Goal Hitbox Settings

local homeGoalHitboxEnabled = false
local awayGoalHitboxEnabled = false

local homeGoalHitboxX = 31.327
local homeGoalHitboxY = 11.278
local homeGoalHitboxZ = 8.289

local awayGoalHitboxX = 31.327
local awayGoalHitboxY = 11.278
local awayGoalHitboxZ = 8.289

local originalHomeGoalHitboxSize = nil
local originalAwayGoalHitboxSize = nil

local homeGoalTransparency = 1
local awayGoalTransparency = 1

local originalHomeGoalTransparency = nil
local originalAwayGoalTransparency = nil



-- Ball Trajectory Settings

local ballTrajectoryEnabled = false

local trajectoryBall = nil
local trajectoryStateConnection = nil
local lastVelocity = Vector3.zero
local predicting = false

local trajectoryFolder = Instance.new("Folder")
trajectoryFolder.Name = "TrajectoryLine"
trajectoryFolder.Parent = workspace

local KICK_THRESHOLD = 8
local SAMPLE_DELAY = 0.05
local SIM_STEP = 0.05
local SIM_DURATION = 1
local LINE_LIFETIME = 2
local LINE_THICKNESS = 0.15

local originalHitboxSize = nil
local originalHitboxTransparency = nil

local originalTackleHitboxSize = nil
local originalTackleHitboxTransparency = nil



-- BALL TRAJECTORY SYSTEM

local function findTrajectoryFootball()

    local misc = workspace:FindFirstChild("Misc")

    if not misc then
        return nil
    end

    for _, obj in ipairs(misc:GetChildren()) do

        if obj:IsA("BasePart") and obj.Name:match("^Football") then
            return obj
        end

    end

    return nil

end


local function clearTrajectoryLine()

    for _, child in ipairs(trajectoryFolder:GetChildren()) do
        child:Destroy()
    end

end


local function addTrajectorySegment(pointA, pointB)

    local distance = (pointB - pointA).Magnitude

    if distance < 0.01 then
        return
    end


    local segment = Instance.new("Part")

    segment.Anchored = true
    segment.CanCollide = false
    segment.CanQuery = false
    segment.CanTouch = false

    segment.Material = Enum.Material.Neon
    segment.Color = Color3.fromRGB(255,80,0)

    segment.Size = Vector3.new(
        LINE_THICKNESS,
        LINE_THICKNESS,
        distance
    )

    segment.CFrame =
        CFrame.new(pointA, pointB)
        * CFrame.new(0,0,-distance / 2)

    segment.Parent = trajectoryFolder

end


local function drawBallTrajectory(startPosition, startVelocity, acceleration)

    clearTrajectoryLine()

    local previousPoint = startPosition
    local velocity = startVelocity

    local elapsed = 0


    while elapsed < SIM_DURATION do

        elapsed += SIM_STEP

        velocity += acceleration * SIM_STEP

        local nextPoint =
            previousPoint + velocity * SIM_STEP


        addTrajectorySegment(
            previousPoint,
            nextPoint
        )

        previousPoint = nextPoint

    end


    task.delay(LINE_LIFETIME,function()

        clearTrajectoryLine()

    end)

end


local function predictBallTrajectory()

    if predicting then
        return
    end

    if not trajectoryBall then
        return
    end


    predicting = true


    local position =
        trajectoryBall.Position

    local velocity =
        trajectoryBall.AssemblyLinearVelocity


    task.wait(SAMPLE_DELAY)


    if not trajectoryBall
    or not trajectoryBall.Parent then

        predicting = false
        return

    end


    local newVelocity =
        trajectoryBall.AssemblyLinearVelocity


    local acceleration =
        (newVelocity - velocity)
        / SAMPLE_DELAY


    drawBallTrajectory(
        position,
        velocity,
        acceleration
    )


    predicting = false

end


local function connectTrajectoryBall(ball)

    if trajectoryStateConnection then

        trajectoryStateConnection:Disconnect()

        trajectoryStateConnection = nil

    end


    trajectoryBall = ball


    if not trajectoryBall then
        return
    end


    lastVelocity =
        trajectoryBall.AssemblyLinearVelocity


    local lastState =
        trajectoryBall:GetAttribute("State")


    trajectoryStateConnection =
        trajectoryBall:GetAttributeChangedSignal("State"):Connect(function()


            local newState =
                trajectoryBall:GetAttribute("State")


            if lastState == "Possessed"
            and newState ~= "Possessed" then

                predictBallTrajectory()

            end


            lastState = newState


        end)

end

-- Ball TP Settings

local ballTPEnabled = false
local ballTPKeybind = Enum.KeyCode.LeftControl

-- Cosmetics Settings

local selectedDribble = "Float"
local dribbleEnabled = false

local function updateDribble()

    if dribbleEnabled then

        player:SetAttribute("EquippedDribble", selectedDribble)

        print("Equipped Dribble:", selectedDribble)

    end

end

local selectedSideDribble = "Flair Spin"
local sideDribbleEnabled = false

local function updateSideDribble()

    if sideDribbleEnabled then

        player:SetAttribute("EquippedSideDribble", selectedSideDribble)

        print("Equipped Side Dribble:", selectedSideDribble)

    end

end

local selectedBallTheme = "Snowball"
local ballThemeEnabled = false

local function updateBallTheme()

    if ballThemeEnabled then

        player:SetAttribute("EquippedBallTheme", selectedBallTheme)

        print("Equipped Ball Theme:", selectedBallTheme)

    end

end

-- Update Hitbox

local function updateHitbox()

    local character = player.Character

    if not character then
        return
    end


    local hitbox = character:FindFirstChild("Hitbox")

    if hitbox and hitbox:IsA("BasePart") then
        
        if hitboxEnabled then

            if not originalHitboxSize then
                originalHitboxSize = hitbox.Size
            end

            if not originalHitboxTransparency then
    originalHitboxTransparency = hitbox.Transparency
end

            hitbox.Size = Vector3.new(
                hitboxX,
                hitboxY,
                hitboxZ
            )

            hitbox.Transparency = hitboxTransparency

        else

    if originalHitboxSize then
        hitbox.Size = originalHitboxSize
    end

    if originalHitboxTransparency then
        hitbox.Transparency = originalHitboxTransparency
    end

end

    end

end



-- Update TackleHitbox

local function updateTackleHitbox()

    local character = player.Character

    if not character then
        return
    end


    local tackleHitbox = character:FindFirstChild("TackleHitbox")

    if tackleHitbox and tackleHitbox:IsA("BasePart") then
        
        if tackleHitboxEnabled then

            if not originalTackleHitboxSize then
                originalTackleHitboxSize = tackleHitbox.Size
            end

            if not originalTackleHitboxTransparency then
    originalTackleHitboxTransparency = tackleHitbox.Transparency
end

            tackleHitbox.Size = Vector3.new(
                tackleHitboxX,
                tackleHitboxY,
                tackleHitboxZ
            )

            tackleHitbox.Transparency = tackleHitboxTransparency

        else

    if originalTackleHitboxSize then
        tackleHitbox.Size = originalTackleHitboxSize
    end

    if originalTackleHitboxTransparency then
        tackleHitbox.Transparency = originalTackleHitboxTransparency
    end

end

    end

end

local function updateHomeGoalHitbox()

    local hitbox = workspace
        :WaitForChild("Stadium")
        :WaitForChild("Teams")
        :WaitForChild("Home")
        :WaitForChild("Goal")
        :WaitForChild("Hitbox")

    if hitbox and hitbox:IsA("BasePart") then

        if homeGoalHitboxEnabled then

            if not originalHomeGoalHitboxSize then
                originalHomeGoalHitboxSize = hitbox.Size
            end

            if not originalHomeGoalTransparency then
                originalHomeGoalTransparency = hitbox.Transparency
            end

            hitbox.Size = Vector3.new(
                homeGoalHitboxX,
                homeGoalHitboxY,
                homeGoalHitboxZ
            )

            hitbox.Transparency = homeGoalTransparency

        else

            if originalHomeGoalHitboxSize then
                hitbox.Size = originalHomeGoalHitboxSize
            end

            if originalHomeGoalTransparency then
                hitbox.Transparency = originalHomeGoalTransparency
            end

        end

    end

end

local function updateAwayGoalHitbox()

    local hitbox = workspace
        :WaitForChild("Stadium")
        :WaitForChild("Teams")
        :WaitForChild("Away")
        :WaitForChild("Goal")
        :WaitForChild("Hitbox")

    if hitbox and hitbox:IsA("BasePart") then

        if awayGoalHitboxEnabled then

            if not originalAwayGoalHitboxSize then
                originalAwayGoalHitboxSize = hitbox.Size
            end

            if not originalAwayGoalTransparency then
                originalAwayGoalTransparency = hitbox.Transparency
            end

            hitbox.Size = Vector3.new(
                awayGoalHitboxX,
                awayGoalHitboxY,
                awayGoalHitboxZ
            )

            hitbox.Transparency = awayGoalTransparency

        else

            if originalAwayGoalHitboxSize then
                hitbox.Size = originalAwayGoalHitboxSize
            end

            if originalAwayGoalTransparency then
                hitbox.Transparency = originalAwayGoalTransparency
            end

        end

    end

end

local function getFootball()

    local misc = workspace:FindFirstChild("Misc")

    if not misc then
        return nil
    end

    for _, obj in ipairs(misc:GetChildren()) do
        if obj.Name:match("^Football") then
            return obj
        end
    end

    return nil
end


local function teleportFootball()

    local character = player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local football = getFootball()
    if not football then return end

    local target = root.CFrame

    if football:IsA("Model") then

        football:PivotTo(target)

        if football.PrimaryPart then
            football.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
            football.PrimaryPart.AssemblyAngularVelocity = Vector3.zero
        end

    elseif football:IsA("BasePart") then

        football.CFrame = target
        football.AssemblyLinearVelocity = Vector3.zero
        football.AssemblyAngularVelocity = Vector3.zero

    end

end


-- Update Walkspeed

local function updateWalkSpeed()

    local character = player.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")

    if not humanoid then
        return
    end


    if not originalWalkSpeed then
        originalWalkSpeed = humanoid.WalkSpeed
    end


    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end


    if walkSpeedEnabled then

        speedConnection = RunService.RenderStepped:Connect(function()

            if humanoid.Parent then

                if humanoid.WalkSpeed ~= walkSpeedValue then
                    humanoid.WalkSpeed = walkSpeedValue
                end

            end

        end)

    else

        humanoid.WalkSpeed = originalWalkSpeed

    end

end

-- Update JumpPower

local function updateJumpPower()

    local character = player.Character

    if not character then
        return
    end


    local humanoid = character:FindFirstChild("Humanoid")

    if not humanoid then
        return
    end


    if not originalJumpPower then
        originalJumpPower = humanoid.JumpPower
    end


    if jumpConnection then
        jumpConnection:Disconnect()
        jumpConnection = nil
    end


    if jumpPowerEnabled then

        jumpConnection = RunService.RenderStepped:Connect(function()

            if humanoid.Parent then

                if humanoid.JumpPower ~= jumpPowerValue then
                    humanoid.JumpPower = jumpPowerValue
                end

            end

        end)

    else

        humanoid.JumpPower = originalJumpPower

    end

end

-- Camera Max Zoom Distance Settings

local cameraZoomEnabled = false
local cameraZoomValue = 20

local function updateCameraMaxZoomDistance()

    if cameraZoomEnabled then

        player.CameraMaxZoomDistance = cameraZoomValue

    else

        player.CameraMaxZoomDistance = 20

    end

end

-- Respawn Support

player.CharacterAdded:Connect(function(character)

    originalHitboxSize = nil
    originalTackleHitboxSize = nil
    originalWalkSpeed = nil
    originalJumpPower = nil

    character:WaitForChild("Humanoid", 5)

    updateWalkSpeed()
    updateJumpPower()


    character:WaitForChild("Hitbox", 5)
    character:WaitForChild("TackleHitbox", 5)


    updateHitbox()
    updateTackleHitbox()
    updateHomeGoalHitbox()
    updateAwayGoalHitbox()

end)



-- Tab

local MiscTab = Window:CreateTab("Misc", "list")

local Section = MiscTab:CreateSection("BallTP")

MiscTab:CreateToggle({

    Name = "Ball TP",

    CurrentValue = false,

    Flag = "BallTP",

    Callback = function(Value)

        ballTPEnabled = Value

    end,

})

local BallTPKeybind = MiscTab:CreateKeybind({

    Name = "Ball TP Keybind",

    CurrentKeybind = "LeftControl",

    HoldToInteract = false,

    Flag = "BallTPKeybind",

    Callback = function()

        if ballTPEnabled then
            teleportFootball()
        end

    end,

})

local BallTrajectorySection = MiscTab:CreateSection("Ball Trajectory")

MiscTab:CreateToggle({

    Name = "Ball Trajectory",

    CurrentValue = false,

    Flag = "BallTrajectoryToggle",

    Callback = function(Value)

        ballTrajectoryEnabled = Value

        if not Value then

            clearTrajectoryLine()

        end

    end,

})

local WalkspeedSection = MiscTab:CreateSection("Walkspeed")

MiscTab:CreateToggle({

    Name = "Walkspeed",

    CurrentValue = false,

    Flag = "WalkspeedToggle",

    Callback = function(Value)

        walkSpeedEnabled = Value

        updateWalkSpeed()

    end,

})

MiscTab:CreateInput({

    Name = "Walkspeed Value",

    CurrentValue = tostring(walkSpeedValue),

    PlaceholderText = "32",

    RemoveTextAfterFocusLost = false,

    Flag = "WalkspeedValue",

    Callback = function(Text)

        local value = tonumber(Text)

        if value then

            walkSpeedValue = value

            updateWalkSpeed()

        end

    end,

})

local Section = MiscTab:CreateSection("JumpPower")

MiscTab:CreateToggle({

    Name = "JumpPower",

    CurrentValue = false,

    Flag = "JumpPowerToggle",

    Callback = function(Value)

        jumpPowerEnabled = Value

        updateJumpPower()

    end,

})


MiscTab:CreateInput({

    Name = "JumpPower Value",

    CurrentValue = tostring(jumpPowerValue),

    PlaceholderText = "100",

    RemoveTextAfterFocusLost = false,

    Flag = "JumpPowerValue",

    Callback = function(Text)

        local value = tonumber(Text)

        if value then

            jumpPowerValue = value

            updateJumpPower()

        end

    end,

})

local CameraZoomSection = MiscTab:CreateSection("Camera Zoom")

MiscTab:CreateToggle({

    Name = "Camera Max Zoom",

    CurrentValue = false,

    Flag = "CameraMaxZoomToggle",

    Callback = function(Value)

        cameraZoomEnabled = Value

        updateCameraMaxZoomDistance()

    end,

})

MiscTab:CreateInput({

    Name = "Camera Max Zoom Distance",

    CurrentValue = tostring(cameraZoomValue),

    PlaceholderText = "20",

    RemoveTextAfterFocusLost = false,

    Flag = "CameraMaxZoomValue",

    Callback = function(Text)

        local value = tonumber(Text)

        if value and value >= 0 then

            cameraZoomValue = value

            updateCameraMaxZoomDistance()

        end

    end,

})

-- Tab

local HitboxTab = Window:CreateTab("Hitbox", "box")

local HitboxSection = HitboxTab:CreateSection("Hitbox")

-- Hitbox Toggle

HitboxTab:CreateToggle({

   Name = "Hitbox",

   CurrentValue = false,

   Flag = "HitboxToggle",

   Callback = function(Value)

      hitboxEnabled = Value

      updateHitbox()

   end,

})



HitboxTab:CreateInput({

   Name = "Hitbox (X)",

   CurrentValue = tostring(hitboxX),

   PlaceholderText = "4.521",

   RemoveTextAfterFocusLost = false,

   Flag = "HitboxX",

   Callback = function(Text)

      local value = tonumber(Text)

      if value then

         hitboxX = value

         updateHitbox()

      end

   end,

})


HitboxTab:CreateInput({

   Name = "Hitbox (Y)",

   CurrentValue = tostring(hitboxY),

   PlaceholderText = "5.73",

   RemoveTextAfterFocusLost = false,

   Flag = "HitboxY",

   Callback = function(Text)

      local value = tonumber(Text)

      if value then

         hitboxY = value

         updateHitbox()

      end

   end,

})


HitboxTab:CreateInput({

   Name = "Hitbox (Z)",

   CurrentValue = tostring(hitboxZ),

   PlaceholderText = "2.398",

   RemoveTextAfterFocusLost = false,

   Flag = "HitboxZ",

   Callback = function(Text)

      local value = tonumber(Text)

      if value then

         hitboxZ = value

         updateHitbox()

      end

   end,

})

HitboxTab:CreateInput({

   Name = "Hitbox Transparency",

   CurrentValue = tostring(hitboxTransparency),

   PlaceholderText = "0",

   RemoveTextAfterFocusLost = false,

   Flag = "HitboxTransparency",

   Callback = function(Text)

      local value = tonumber(Text)

      if value and value >= 0 and value <= 1 then

         hitboxTransparency = value

         updateHitbox()

      end

   end,

})

local TackleSection = HitboxTab:CreateSection("TackleHitbox")

-- TackleHitbox Toggle

HitboxTab:CreateToggle({

   Name = "TackleHitbox",

   CurrentValue = false,

   Flag = "TackleHitboxToggle",

   Callback = function(Value)

      tackleHitboxEnabled = Value

      updateTackleHitbox()

   end,

})



HitboxTab:CreateInput({

   Name = "TackleHitbox (X)",

   CurrentValue = tostring(tackleHitboxX),

   PlaceholderText = "2.57",

   RemoveTextAfterFocusLost = false,

   Flag = "TackleHitboxX",

   Callback = function(Text)

      local value = tonumber(Text)

      if value then

         tackleHitboxX = value

         updateTackleHitbox()

      end

   end,

})


HitboxTab:CreateInput({

   Name = "TackleHitbox (Y)",

   CurrentValue = tostring(tackleHitboxY),

   PlaceholderText = "5.73",

   RemoveTextAfterFocusLost = false,

   Flag = "TackleHitboxY",

   Callback = function(Text)

      local value = tonumber(Text)

      if value then

         tackleHitboxY = value

         updateTackleHitbox()

      end

   end,

})


HitboxTab:CreateInput({

   Name = "TackleHitbox (Z)",

   CurrentValue = tostring(tackleHitboxZ),

   PlaceholderText = "2.064",

   RemoveTextAfterFocusLost = false,

   Flag = "TackleHitboxZ",

   Callback = function(Text)

      local value = tonumber(Text)

      if value then

         tackleHitboxZ = value

         updateTackleHitbox()

      end

   end,

})

HitboxTab:CreateInput({

   Name = "TackleHitbox Transparency",

   CurrentValue = tostring(tackleHitboxTransparency),

   PlaceholderText = "0",

   RemoveTextAfterFocusLost = false,

   Flag = "TackleHitboxTransparency",

   Callback = function(Text)

      local value = tonumber(Text)

      if value and value >= 0 and value <= 1 then

         tackleHitboxTransparency = value

         updateTackleHitbox()

      end

   end,

})

local HomeGoalSection = HitboxTab:CreateSection("Home Goal Hitbox")

HitboxTab:CreateToggle({

    Name = "Home Goal Hitbox",

    CurrentValue = false,

    Flag = "HomeGoalHitboxToggle",

    Callback = function(Value)

        homeGoalHitboxEnabled = Value
        updateHomeGoalHitbox()

    end,

})

HitboxTab:CreateInput({

    Name = "Home Goal Hitbox (X)",

    CurrentValue = tostring(homeGoalHitboxX),

    PlaceholderText = "31.327",

    RemoveTextAfterFocusLost = false,

    Flag = "HomeGoalHitboxX",

    Callback = function(Text)

        local value = tonumber(Text)

        if value then

            homeGoalHitboxX = value

            updateHomeGoalHitbox()

        end

    end,

})

HitboxTab:CreateInput({

    Name = "Home Goal Hitbox (Y)",

    CurrentValue = tostring(homeGoalHitboxY),

    PlaceholderText = "11.278",

    RemoveTextAfterFocusLost = false,

    Flag = "HomeGoalHitboxY",

    Callback = function(Text)

        local value = tonumber(Text)

        if value then

            homeGoalHitboxY = value

            updateHomeGoalHitbox()

        end

    end,

})

HitboxTab:CreateInput({

    Name = "Home Goal Hitbox (Z)",

    CurrentValue = tostring(homeGoalHitboxZ),

    PlaceholderText = "8.289",

    RemoveTextAfterFocusLost = false,

    Flag = "HomeGoalHitboxZ",

    Callback = function(Text)

        local value = tonumber(Text)

        if value then

            homeGoalHitboxZ = value

            updateHomeGoalHitbox()

        end

    end,

})

HitboxTab:CreateInput({

    Name = "Home Goal Transparency",

    CurrentValue = tostring(homeGoalTransparency),

    PlaceholderText = "1",

    RemoveTextAfterFocusLost = false,

    Flag = "HomeGoalTransparency",

    Callback = function(Text)

        local value = tonumber(Text)

        if value and value >= 0 and value <= 1 then

            homeGoalTransparency = value

            updateHomeGoalHitbox()

        end

    end,

})

local AwayGoalSection = HitboxTab:CreateSection("Away Goal Hitbox")

HitboxTab:CreateToggle({

    Name = "Away Goal Hitbox",

    CurrentValue = false,

    Flag = "AwayGoalHitboxToggle",

    Callback = function(Value)

        awayGoalHitboxEnabled = Value

        updateAwayGoalHitbox()

    end,

})

HitboxTab:CreateInput({

    Name = "Away Goal Hitbox (X)",

    CurrentValue = tostring(awayGoalHitboxX),

    PlaceholderText = "31.327",

    RemoveTextAfterFocusLost = false,

    Flag = "AwayGoalHitboxX",

    Callback = function(Text)

        local value = tonumber(Text)

        if value then

            awayGoalHitboxX = value

            updateAwayGoalHitbox()

        end

    end,

})

HitboxTab:CreateInput({

    Name = "Away Goal Hitbox (Y)",

    CurrentValue = tostring(awayGoalHitboxY),

    PlaceholderText = "11.278",

    RemoveTextAfterFocusLost = false,

    Flag = "AwayGoalHitboxY",

    Callback = function(Text)

        local value = tonumber(Text)

        if value then

            awayGoalHitboxY = value

            updateAwayGoalHitbox()

        end

    end,

})

HitboxTab:CreateInput({

    Name = "Away Goal Hitbox (Z)",

    CurrentValue = tostring(awayGoalHitboxZ),

    PlaceholderText = "8.289",

    RemoveTextAfterFocusLost = false,

    Flag = "AwayGoalHitboxZ",

    Callback = function(Text)

        local value = tonumber(Text)

        if value then

            awayGoalHitboxZ = value

            updateAwayGoalHitbox()

        end

    end,

})

HitboxTab:CreateInput({

    Name = "Away Goal Transparency",

    CurrentValue = tostring(awayGoalTransparency),

    PlaceholderText = "1",

    RemoveTextAfterFocusLost = false,

    Flag = "AwayGoalTransparency",

    Callback = function(Text)

        local value = tonumber(Text)

        if value and value >= 0 and value <= 1 then

            awayGoalTransparency = value

            updateAwayGoalHitbox()

        end

    end,

})

-- Tab

local CosmeticsTab = Window:CreateTab("Cosmetics", "palette")


-- Dribbles

local DribblesSection = CosmeticsTab:CreateSection("Dribbles")


CosmeticsTab:CreateToggle({

    Name = "Enable Dribbles",

    CurrentValue = false,

    Flag = "DribblesToggle",

    Callback = function(Value)

    dribbleEnabled = Value

    updateDribble()

    end,

})


CosmeticsTab:CreateDropdown({

    Name = "Select Dribble",

    Options = {
        "Float",
        "Penguin Slide",
        "Front Flip",
        "Flip",
        "WC26 Trophy Dribble",
        "Rainbow Flick"
    },

    CurrentOption = {
        "Float"
    },

    MultipleOptions = false,

    Flag = "DribbleDropdown",

    Callback = function(Options)

    selectedDribble = Options[1]

    updateDribble()

    end,

})



-- Side Dribbles

local SideDribblesSection = CosmeticsTab:CreateSection("Side Dribbles")


CosmeticsTab:CreateToggle({

    Name = "Enable Side Dribbles",

    CurrentValue = false,

    Flag = "SideDribblesToggle",

    Callback = function(Value)

    sideDribbleEnabled = Value

    updateSideDribble()

    end,

})


CosmeticsTab:CreateDropdown({

    Name = "Select Side Dribble",

    Options = {
        "Flair Spin",
        "Heel to Ball Roll",
        "Juke",
        "Hocus Pocus",
        "Portugal Chop"
    },

    CurrentOption = {
        "Flair Spin"
    },

    MultipleOptions = false,

    Flag = "SideDribbleDropdown",

    Callback = function(Options)

    selectedSideDribble = Options[1]

    updateSideDribble()

    end,

})



-- Ball Themes

local BallThemesSection = CosmeticsTab:CreateSection("Ball Themes")


CosmeticsTab:CreateToggle({

    Name = "Enable Ball Theme",

    CurrentValue = false,

    Flag = "BallThemeToggle",

    Callback = function(Value)

    ballThemeEnabled = Value

    updateBallTheme()

    end,

})


CosmeticsTab:CreateDropdown({

    Name = "Select Ball Theme",

    Options = {
        "Snowball",
        "Fireball",
        "Celestial Awakening Ball",
        "Inferno Dragon Ball",
        "Thunder Emperor Ball",
        "Pumpkin Ball",
        "The Bomb",
        "Gumball",
        "Fishbowl",
        "Spiky",
        "Disco",
        "8-Bit",
        "Void Singularity Soccer Ball",
        "Riley's Football"
    },

    CurrentOption = {
        "Snowball"
    },

    MultipleOptions = false,

    Flag = "BallThemeDropdown",

    Callback = function(Options)

    selectedBallTheme = Options[1]

    updateBallTheme()

    end,

})

-- Tab

local SettingsTab = Window:CreateTab("Settings", "settings")

local Section = SettingsTab:CreateSection("Settings")

-- =========================================================
-- KSG HUB CONFIG MANAGER
-- =========================================================

local HttpService = game:GetService("HttpService")

local CONFIG_FOLDER = "LazixRobloxx"
local CONFIG_FILE = CONFIG_FOLDER .. "/KSG_ConfigSlots.json"

local configSlots = {
    [1] = {
        Name = "Config 1",
        Data = nil
    },

    [2] = {
        Name = "Config 2",
        Data = nil
    },

    [3] = {
        Name = "Config 3",
        Data = nil
    }
}

local selectedConfigSlot = 1

-- ---------------------------------------------------------
-- Filesystem
-- ---------------------------------------------------------

if not isfolder(CONFIG_FOLDER) then
    makefolder(CONFIG_FOLDER)
end

local function saveConfigDatabase()

    local success, encoded = pcall(function()
        return HttpService:JSONEncode(configSlots)
    end)

    if success then
        writefile(CONFIG_FILE, encoded)
        return true
    end

    return false
end


local function loadConfigDatabase()

    if not isfile(CONFIG_FILE) then
        return
    end

    local success, content = pcall(function()
        return readfile(CONFIG_FILE)
    end)

    if not success then
        return
    end

    local decodeSuccess, data = pcall(function()
        return HttpService:JSONDecode(content)
    end)

    if not decodeSuccess or type(data) ~= "table" then
        return
    end

    for i = 1, 3 do

        if data[tostring(i)] then

            configSlots[i].Name =
                data[tostring(i)].Name or ("Config " .. i)

            configSlots[i].Data =
                data[tostring(i)].Data

        elseif data[i] then

            configSlots[i].Name =
                data[i].Name or ("Config " .. i)

            configSlots[i].Data =
                data[i].Data

        end

    end

end


loadConfigDatabase()


-- ---------------------------------------------------------
-- Get values from Rayfield
-- ---------------------------------------------------------

local function getCurrentConfig()

    local data = {}

    for flagName, element in pairs(Rayfield.Flags) do

        if element.Type == "ColorPicker" then

            data[flagName] = {
                R = element.Color.R,
                G = element.Color.G,
                B = element.Color.B
            }

        elseif element.CurrentValue ~= nil then

            data[flagName] = element.CurrentValue

        elseif element.CurrentKeybind ~= nil then

            data[flagName] = element.CurrentKeybind

        elseif element.CurrentOption ~= nil then

            data[flagName] = element.CurrentOption

        end

    end

    return data

end


-- ---------------------------------------------------------
-- Apply saved values
-- ---------------------------------------------------------

local function applyConfig(data)

    if type(data) ~= "table" then
        return false
    end

    for flagName, value in pairs(data) do

        local element = Rayfield.Flags[flagName]

        if element then

            pcall(function()

                if element.Type == "ColorPicker" then

                    if type(value) == "table" then

                        element:Set(
                            Color3.fromRGB(
                                value.R,
                                value.G,
                                value.B
                            )
                        )

                    end

                elseif element.Type == "Dropdown" then

                    if type(value) == "table" then
                        element:Set(value)
                    else
                        element:Set({value})
                    end

                else

                    element:Set(value)

                end

            end)

        end

    end

    return true

end


-- ---------------------------------------------------------
-- Default values
-- ---------------------------------------------------------

local DEFAULT_CONFIG = {

    BallTP = false,
    BallTrajectoryToggle = false,

    WalkspeedToggle = false,
    WalkspeedValue = "16",

    JumpPowerToggle = false,
    JumpPowerValue = "50",

    CameraMaxZoomToggle = false,
    CameraMaxZoomValue = "20",

    HitboxToggle = false,
    HitboxX = "4.521",
    HitboxY = "5.73",
    HitboxZ = "2.398",
    HitboxTransparency = "1",

    TackleHitboxToggle = false,
    TackleHitboxX = "2.57",
    TackleHitboxY = "5.73",
    TackleHitboxZ = "2.064",
    TackleHitboxTransparency = "1",

    HomeGoalHitboxToggle = false,
    HomeGoalHitboxX = "31.327",
    HomeGoalHitboxY = "11.278",
    HomeGoalHitboxZ = "8.289",
    HomeGoalTransparency = "1",

    AwayGoalHitboxToggle = false,
    AwayGoalHitboxX = "31.327",
    AwayGoalHitboxY = "11.278",
    AwayGoalHitboxZ = "8.289",
    AwayGoalTransparency = "1",

    DribblesToggle = false,
    DribbleDropdown = {"Float"},

    SideDribblesToggle = false,
    SideDribbleDropdown = {"Flair Spin"},

    BallThemeToggle = false,
    BallThemeDropdown = {"Snowball"},

    BallTPKeybind = "LeftControl"
}


local function resetToDefaults()

    applyConfig(DEFAULT_CONFIG)

end


-- ---------------------------------------------------------
-- Config dropdown helpers
-- ---------------------------------------------------------

local ConfigDropdown


local function getConfigNames()

    return {
        configSlots[1].Name,
        configSlots[2].Name,
        configSlots[3].Name
    }

end


local function refreshConfigDropdown()

    if not ConfigDropdown then
        return
    end

    ConfigDropdown:Refresh(getConfigNames())

    ConfigDropdown:Set({
        configSlots[selectedConfigSlot].Name
    })

end


local function getSelectedSlot()

    return selectedConfigSlot

end


-- ---------------------------------------------------------
-- Save
-- ---------------------------------------------------------

local function saveSelectedConfig(customName)

    local slot = getSelectedSlot()

    customName = tostring(customName or ""):match("^%s*(.-)%s*$")

    if customName == "" then
        customName = "Config " .. slot
    end

    -- Nie pozwalaj na identyczne nazwy dwóch configów
    for i = 1, 3 do

        if i ~= slot
        and configSlots[i].Name:lower() == customName:lower() then

            Rayfield:Notify({
                Title = "Config",
                Content = "Ta nazwa jest już używana.",
                Duration = 3
            })

            return false

        end

    end


    configSlots[slot].Name = customName
    configSlots[slot].Data = getCurrentConfig()

    if not saveConfigDatabase() then

        Rayfield:Notify({
            Title = "Config",
            Content = "Nie udało się zapisać configu.",
            Duration = 3
        })

        return false

    end


    refreshConfigDropdown()

    Rayfield:Notify({
        Title = "Config",
        Content = customName .. " został zapisany.",
        Duration = 3
    })

    return true

end


-- ---------------------------------------------------------
-- Load
-- ---------------------------------------------------------

local function loadSelectedConfig()

    local slot = getSelectedSlot()
    local config = configSlots[slot]

    if not config.Data then

        Rayfield:Notify({
            Title = "Config",
            Content = config.Name .. " nie zawiera zapisanego configu.",
            Duration = 3
        })

        return false

    end


    applyConfig(config.Data)

    Rayfield:Notify({
        Title = "Config",
        Content = config.Name .. " został wczytany.",
        Duration = 3
    })

    return true

end


-- ---------------------------------------------------------
-- Delete
-- ---------------------------------------------------------

local function deleteSelectedConfig()

    local slot = getSelectedSlot()

    -- Usuwamy dane
    configSlots[slot].Data = nil

    -- Przywracamy domyślną nazwę
    configSlots[slot].Name = "Config " .. slot

    -- Resetujemy aktualne ustawienia
    resetToDefaults()

    -- Zapisujemy zmianę
    saveConfigDatabase()

    -- Odświeżamy dropdown
    refreshConfigDropdown()

    Rayfield:Notify({
        Title = "Config",
        Content = "Config " .. slot .. " został usunięty i zresetowany.",
        Duration = 3
    })

end

-- Config Tab

local ConfigTab = Window:CreateTab("Config", "save")

local ConfigSection = ConfigTab:CreateSection("Configuration")

-- Config slot dropdown

ConfigDropdown = ConfigTab:CreateDropdown({

    Name = "Select Config",

    Options = getConfigNames(),

    CurrentOption = {
        configSlots[selectedConfigSlot].Name
    },

    MultipleOptions = false,

    Flag = "ConfigSlotDropdown",

    Callback = function(Options)

        local selectedName = Options[1]

        for i = 1, 3 do

            if configSlots[i].Name == selectedName then

                selectedConfigSlot = i
                break

            end

        end

    end,

})


-- Save Config

ConfigTab:CreateInput({

    Name = "Config Name",

    CurrentValue = "",

    PlaceholderText = "Config name",

    RemoveTextAfterFocusLost = false,

    Flag = "ConfigNameInput",

    Callback = function(Text)

        local name = tostring(Text or "")

        if name:gsub("%s+", "") ~= "" then

            saveSelectedConfig(name)

        end

    end,

})


ConfigTab:CreateButton({

    Name = "Load Config",

    Callback = function()

        loadSelectedConfig()

    end,

})


ConfigTab:CreateButton({

    Name = "Delete Config",

    Callback = function()

        deleteSelectedConfig()

    end,

})

-- Tab

local AboutTab = Window:CreateTab("About", "info")

local Section = AboutTab:CreateSection("About")

AboutTab:CreateParagraph({
    Title = "About",
    Content = "Developed by LazixRobloxx & Ksg.\n\nBuilt for Roblox sports games.\nRefined through experience.\nMade to stand above the rest.\n\nKSG HUB #1."
})

RunService.Heartbeat:Connect(function()

    updateHitbox()
    updateTackleHitbox()
    updateHomeGoalHitbox()
    updateAwayGoalHitbox()

    if ballTrajectoryEnabled then

        if not trajectoryBall or not trajectoryBall.Parent then

            local foundBall = findTrajectoryFootball()

            if foundBall then

                connectTrajectoryBall(foundBall)

            end

        else

            if trajectoryBall:GetAttribute("State") ~= "Possessed" then

                local currentVelocity =
                    trajectoryBall.AssemblyLinearVelocity


                local velocityDelta =
                    (currentVelocity - lastVelocity).Magnitude


                if velocityDelta > KICK_THRESHOLD
                and not predicting then

                    predictBallTrajectory()

                end


                lastVelocity = currentVelocity

            end

        end

    end

end)





Rayfield:LoadConfiguration()

Rayfield:Notify({

   Title = "LazixRobloxx",

   Content = "Ksg hub loaded",

   Duration = 6.5,

   Image = 4483362458,

})