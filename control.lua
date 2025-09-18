local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local SetBounty = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SetBounty")
local targets = getgenv().targets
local buyer = getgenv().buyer
local amount = getgenv().amount
local kick = getgenv().kick

local function getPreTax(amount)
    return math.ceil(amount / 0.65)
end

local function getBuyerCurrency()
    local buyerPlayer = Players:FindFirstChild(getgenv.buyer)
    if buyerPlayer and buyerPlayer:FindFirstChild("DataFolder") then
        local currency = buyerPlayer.DataFolder:FindFirstChild("Currency")
        if currency then
            return currency.Value
        end
    end
    return 0
end

local function kickIfNeeded(totalSet)
    if getgenv.kick then
        local buyerCurrency = getBuyerCurrency()
        if totalSet + buyerCurrency >= getgenv.amount then
            LocalPlayer:Kick("Bounty amount reached")
        end
    end
end

local function waitForPlayers()
    while true do
        local allHere = true
        for _, targetId in ipairs(getgenv.targets) do
            if not Players:GetPlayerByUserId(targetId) then
                allHere = false
                break
            end
        end
        if not Players:FindFirstChild(getgenv.buyer) then
            allHere = false
        end
        if allHere then break end
        wait(1)
    end
end

local function setBounties()
    waitForPlayers()
    local total = 0
    local increment = 2500000
    while total < getgenv.amount do
        for _, targetId in ipairs(getgenv.targets) do
            local targetPlayer = Players:GetPlayerByUserId(targetId)
            if targetPlayer and total < getgenv.amount then
                local remaining = getgenv.amount - total
                local toSet = math.min(increment, remaining)
                SetBounty:InvokeServer(targetPlayer.Name, getPreTax(toSet))
                total = total + toSet
                kickIfNeeded(total)
                wait(60)
            end
        end
    end
end

setBounties()
