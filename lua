---------------------------------------------------
-- WAIT FOR GAME
---------------------------------------------------
repeat task.wait() until game:IsLoaded()

---------------------------------------------------
-- SERVICES
---------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

---------------------------------------------------
-- STATES
---------------------------------------------------
local autoFarmEnabled = false
local autoResetEnabled = false
local antiAFKEnabled = false

local farmSpeed = 20
local activeTween
local lastCoinTime = tick()

---------------------------------------------------
-- CLEAN OLD GUI
---------------------------------------------------
pcall(function()
    game.CoreGui:FindFirstChild("Rayfield"):Destroy()
end)

---------------------------------------------------
-- LOAD RAYFIELD
---------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

---------------------------------------------------
-- WINDOW
---------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "❄️ Winter AutoFarm | beezelbub",
    LoadingTitle = "Winter AutoFarm",
    LoadingSubtitle = "made by beezelbub",
    ConfigurationSaving = { Enabled = false },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

---------------------------------------------------
-- TABS
---------------------------------------------------
local MainTab = Window:CreateTab("🎄 Main")
local AntiTab = Window:CreateTab("🛡️ Anti")

---------------------------------------------------
-- UI
---------------------------------------------------
MainTab:CreateToggle({
    Name = "❄️ Auto Farm Coins",
    CurrentValue = false,
    Callback = function(v)
        autoFarmEnabled = v
    end
})

MainTab:CreateToggle({
    Name = "📦 Auto Reset Bag",
    CurrentValue = false,
    Callback = function(v)
        autoResetEnabled = v
    end
})

MainTab:CreateInput({
    Name = "🌬️ Farm Speed (20–22)",
    PlaceholderText = "20",
    Callback = function(t)
        local n = tonumber(t)
        if n and n >= 15 and n <= 22 then
            farmSpeed = n
            Rayfield:Notify({
                Title = "Speed Updated",
                Content = "Speed set to "..n,
                Duration = 2
            })
        end
    end
})

MainTab:CreateParagraph({
    Title = "⚠️ WARNING",
    Content = "DO NOT USE ALT ACCOUNT TO AVOID BAN\n\nUse MAIN account only."
})

---------------------------------------------------
-- ANTI AFK
---------------------------------------------------
AntiTab:CreateToggle({
    Name = "🎅 Anti-AFK",
    CurrentValue = false,
    Callback = function(v)
        antiAFKEnabled = v
        if v then
            player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
})

---------------------------------------------------
-- CHARACTER HELPERS
---------------------------------------------------
local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
    return getChar():WaitForChild("HumanoidRootPart")
end

---------------------------------------------------
-- TWEEN MOVE
---------------------------------------------------
local function tweenTo(cf)
    local hrp = getHRP()
    if not hrp then return end

    local dist = (hrp.Position - cf.Position).Magnitude
    local time = math.clamp(dist / farmSpeed, 0.35, 1.😎

    if activeTween then
        activeTween:Cancel()
    end

    activeTween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        { CFrame = cf }
    )

    activeTween:Play()
    activeTween.Completed:Wait()
end

---------------------------------------------------
-- NEAREST COIN
---------------------------------------------------
local function getNearestCoin(maxDist)
    local hrp = getHRP()
    local nearest, best = nil, maxDist or 80

    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart")
        and v:FindFirstChild("TouchInterest")
        and v.Name:lower():find("coin") then
            local d = (hrp.Position - v.Position).Magnitude
            if d < best then
                best = d
                nearest = v
            end
        end
    end

    return nearest
end

---------------------------------------------------
-- COIN FARM LOOP
---------------------------------------------------
local collected = {}
local COIN_DELAY = 0.18
local BURST_LIMIT = 5
local burst = 0

task.spawn(function()
    while task.wait(0.12) do
        if not autoFarmEnabled then continue end

        local coin = getNearestCoin(80)
        if not coin then continue end

        if collected[coin] and tick() - collected[coin] < COIN_DELAY then
            continue
        end

        collected[coin] = tick()
        burst += 1

        tweenTo(coin.CFrame + Vector3.new(0, 2.2, 0))
        lastCoinTime = tick()

        task.wait(COIN_DELAY)

        if burst >= BURST_LIMIT then
            burst = 0
            task.wait(0.45 + math.random() * 0.25)
        end
    end
end)

---------------------------------------------------
-- READY
---------------------------------------------------
Rayfield:Notify({
    Title = "Loaded",
    Content = "Winter AutoFarm ready",
    Duration = 4
})
