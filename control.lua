local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local SetBounty = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SetBounty")

local targets = getgenv().targets or {}
local buyerName = getgenv().buyer or ""
local totalAmount = getgenv().amount or 0
local kick = getgenv().kick or false

local function getPreTax(amount)
    return math.ceil(amount / 0.65)
end

local function getBuyerCurrency()
    local buyerPlayer = Players:FindFirstChild(buyerName)
    if buyerPlayer and buyerPlayer:FindFirstChild("DataFolder") then
        local currency = buyerPlayer.DataFolder:FindFirstChild("Currency")
        if currency then
            return currency.Value
        end
    end
    return 0
end

local function kickIfNeeded(totalSet)
    if kick then
        local buyerCurrency = getBuyerCurrency()
        if totalSet + buyerCurrency >= totalAmount then
            LocalPlayer:Kick("Bounty amount reached")
        end
    end
end

local function waitForPlayers()
    while true do
        local allHere = true
        for _, targetId in ipairs(targets) do
            if not Players:GetPlayerByUserId(targetId) then
                allHere = false
                break
            end
        end
        if not Players:FindFirstChild(buyerName) then
            allHere = false
        end
        if allHere then break end
        wait(1)
    end
end

local function setBounties()
    waitForPlayers()
    local totalSet = 0
    local increment = 2500000
    while totalSet < totalAmount do
        for _, targetId in ipairs(targets) do
            local targetPlayer = Players:GetPlayerByUserId(targetId)
            if targetPlayer and totalSet < totalAmount then
                local remaining = totalAmount - totalSet
                local toSet = math.min(increment, remaining)
                SetBounty:InvokeServer(targetPlayer.Name, getPreTax(toSet))
                totalSet = totalSet + toSet
                kickIfNeeded(totalSet)
                wait(60)
            end
        end
    end
end

setBounties()
