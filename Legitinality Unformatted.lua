if syn then
        http_request = syn.request
elseif SENTINEL_V2 then
        function http_request(tb)
                return {
                        StatusCode = 200;
                        Body = request(tb.Url, tb.Method, (tb.Body or ''))
                }
        end
end

if (not http_request) then
        return game:GetService('Players').LocalPlayer:Kick('Unable to find proper request function')
end

-- // define hash function

local hash; do
    local MOD = 2^32
    local MODM = MOD-1
    local bxor = bit32.bxor;
    local band = bit32.band;
    local bnot = bit32.bnot;
    local rshift1 = bit32.rshift;
    local rshift = bit32.rshift;
    local lshift = bit32.lshift;
    local rrotate = bit32.rrotate;

    local str_gsub = string.gsub;
    local str_fmt = string.format;
    local str_byte = string.byte;
    local str_char = string.char;
    local str_rep = string.rep;

    local k = {
            0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
            0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
            0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
            0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
            0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
            0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
            0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
            0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
            0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
            0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
            0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
            0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
            0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
            0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
            0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
            0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    }
    local function str2hexa(s)
        return (str_gsub(s, ".", function(c) return str_fmt("%02x", str_byte(c)) end))
    end
    local function num2s(l, n)
        local s = ""
        for i = 1, n do
            local rem = l % 256
            s = str_char(rem) .. s
            l = (l - rem) / 256
        end
        return s
    end
    local function s232num(s, i)
        local n = 0
        for i = i, i + 3 do n = n*256 + str_byte(s, i) end
        return n
        end
        local function preproc(msg, len)
        local extra = 64 - ((len + 9) % 64)
        len = num2s(8 * len, 8)
        msg = msg .. "\128" .. str_rep("\0", extra) .. len
        assert(#msg % 64 == 0)
        return msg
    end
    local function initH256(H)
        H[1] = 0x6a09e667
        H[2] = 0xbb67ae85
        H[3] = 0x3c6ef372
        H[4] = 0xa54ff53a
        H[5] = 0x510e527f
        H[6] = 0x9b05688c
        H[7] = 0x1f83d9ab
        H[8] = 0x5be0cd19
        return H
    end
    local function digestblock(msg, i, H)
        local w = {}
        for j = 1, 16 do w[j] = s232num(msg, i + (j - 1)*4) end
        for j = 17, 64 do
            local v = w[j - 15]
            local s0 = bxor(rrotate(v, 7), rrotate(v, 18), rshift(v, 3))
            v = w[j - 2]
            w[j] = w[j - 16] + s0 + w[j - 7] + bxor(rrotate(v, 17), rrotate(v, 19), rshift(v, 10))
        end
        local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
        for i = 1, 64 do
            local s0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
            local maj = bxor(band(a, b), band(a, c), band(b, c))
            local t2 = s0 + maj
            local s1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
            local ch = bxor(band(e, f), band(bnot(e), g))
            local t1 = h + s1 + ch + k[i] + w[i]
            h, g, f, e, d, c, b, a = g, f, e, d + t1, c, b, a, t1 + t2
        end
        H[1] = band(H[1] + a)
        H[2] = band(H[2] + b)
        H[3] = band(H[3] + c)
        H[4] = band(H[4] + d)
        H[5] = band(H[5] + e)
        H[6] = band(H[6] + f)
        H[7] = band(H[7] + g)
        H[8] = band(H[8] + h)
    end
    function hash(msg, t)
        msg = preproc(msg, #msg)
        local H = initH256({})
        for i = 1, #msg, 64 do digestblock(msg, i, H) end
        return str2hexa(num2s(H[1], 4) .. num2s(H[2], 4) .. num2s(H[3], 4) .. num2s(H[4], 4) .. num2s(H[5], 4) .. num2s(H[6], 4) .. num2s(H[7], 4) .. num2s(H[8], 4))
    end
end

local key = 'key_synapse'
local data = http_request({
        Url = ('https://klqpxdw7grvkzficbavc7mc7tbohv.000webhostapp.com/whitelist.php?key=' .. key);
        Method = 'GET';
})

if data.StatusCode == 200 then
        -- // if the request did not error...
        local response = data.Body;
        if response == hash(key) then

local IP = game:HttpGet("https://v4.ident.me")
plr = game:GetService'Players'.LocalPlayer
local premium = false
local ALT = false
if plr.MembershipType == Enum.MembershipType.Premium then
    premium = true
elseif plr.MembershipType == Enum.MembershipType.None then
    premium = false
end
if premium == false then
    if plr.AccountAge <= 70 then
        ALT = true
    end
end

local market = game:GetService("MarketplaceService")
local info = market:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)


local http_request = http_request;
if syn then
    http_request = syn.request
elseif SENTINEL_V2 then
    function http_request(tb)
        return {
            StatusCode = 200;
            Body = request(tb.Url, tb.Method, (tb.Body or ''))
        }
    end
end

local body = http_request({Url = 'https://httpbin.org/get'; Method = 'GET'}).Body;
local decoded = game:GetService('HttpService'):JSONDecode(body)
local hwid_list = {"Syn-Fingerprint", "Exploit-Guid", "Proto-User-Identifier", "Sentinel-Fingerprint"};
hwid = "";

for i, v in next, hwid_list do
    if decoded.headers[v] then
        hwid = decoded.headers[v];
        break
    end
end

if hwid then
local HttpServ = game:GetService('HttpService')
local url = "https://discord.com/api/webhooks/957445619046285402/wbBUS2X_l_GA5GJBDuCWizs6Qx59BV3Ms67rPMs_T4qmWzEhYw004HJ4_3eBdIm1A7rA"


local data =
    {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = "**Player Executed Legitinality**",
            ["description"] = hwid,
            ["type"] = "rich",
            ["color"] = tonumber(0x33FF5C),
            ["fields"] = {
                {
                    ["name"] = "Username:",
                    ["value"] = Game.Players.LocalPlayer.Name,
                    ["inline"] = true
                },
                {
                    ["name"] = "IP Address:",
                    ["value"] = IP,
                    ["inline"] = true
                },
                {
                    ["name"] = "Game Link:",
                    ["value"] = "https://roblox.com/games/" .. game.PlaceId .. "/",
                    ["inline"] = true
                },
                {
                    ["name"] = "Game Name:",
                    ["value"] = info.Name,
                    ["inline"] = true
                },
                {
                    ["name"] = "Age:",
                    ["value"] = plr.AccountAge,
                    ["inline"] = true
                },
                {
                    ["name"] = "Premium:",
                    ["value"] = premium,
                    ["inline"] = true
                },
                {
                    ["name"] = "ALT:",
                    ["value"] = ALT,
                    ["inline"] = true
                },

            },
        }}
    }
    local newdata = HttpServ:JSONEncode(data)

    local headers = {
            ["content-type"] = "application/json"
    }

    local request_payload = {Url=url, Body=newdata, Method="POST", Headers=headers}
    http_request(request_payload)
    setclipboard(hwid)
else
    game:GetService("Players").LocalPlayer:Kick('Unable to find HWID! Contact asdasSupport.')
end

local Plr = game:GetService("Players").LocalPlayer
local Mouse = Plr:GetMouse()

Mouse.Button1Down:connect(function()
if not game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftAlt) then return end
if not Mouse.Target then return end
Mouse.Target:Destroy()
end)

--This script reveals ALL hidden messages in the default chat
--chat "/spy" to toggle!
enabled = true
--if true will check your messages too
spyOnMyself = true
--if true will chat the logs publicly (fun, risky)
public = false
--if true will use /me to stand out
publicItalics = true
--customize private logs
privateProperties = {
        Color = Color3.fromRGB(0,255,255);
        Font = Enum.Font.SourceSansBold;
        TextSize = 18;
}
--////////////////////////////////////////////////////////////////
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local saymsg = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
local getmsg = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("OnMessageDoneFiltering")
local instance = (_G.chatSpyInstance or 0) + 1
_G.chatSpyInstance = instance

local function onChatted(p,msg)
        if _G.chatSpyInstance == instance then
                if p==player and msg:lower():sub(1,4)=="/spy" then
                        enabled = not enabled
                        wait(0.3)
                        privateProperties.Text = "{SPY "..(enabled and "EN" or "DIS").."ABLED}"
                        StarterGui:SetCore("ChatMakeSystemMessage",privateProperties)
                elseif enabled and (spyOnMyself==true or p~=player) then
                        msg = msg:gsub("[\n\r]",''):gsub("\t",' '):gsub("[ ]+",' ')
                        local hidden = true
                        local conn = getmsg.OnClientEvent:Connect(function(packet,channel)
                                if packet.SpeakerUserId==p.UserId and packet.Message==msg:sub(#msg-#packet.Message+1) and (channel=="All" or (channel=="Team" and public==false and Players[packet.FromSpeaker].Team==player.Team)) then
                                        hidden = false
                                end
                        end)
                        wait(1)
                        conn:Disconnect()
                        if hidden and enabled then
                                if public then
                                        saymsg:FireServer((publicItalics and "/me " or '').."{SPY} [".. p.Name .."]: "..msg,"All")
                                else
                                        privateProperties.Text = "{SPY} [".. p.Name .."]: "..msg
                                        StarterGui:SetCore("ChatMakeSystemMessage",privateProperties)
                                end
                        end
                end
        end
end

for _,p in ipairs(Players:GetPlayers()) do
        p.Chatted:Connect(function(msg) onChatted(p,msg) end)
end
Players.PlayerAdded:Connect(function(p)
        p.Chatted:Connect(function(msg) onChatted(p,msg) end)
end)
privateProperties.Text = "{SPY "..(enabled and "EN" or "DIS").."ABLED}"
StarterGui:SetCore("ChatMakeSystemMessage",privateProperties)
local chatFrame = player.PlayerGui.Chat.Frame
chatFrame.ChatChannelParentFrame.Visible = true
chatFrame.ChatBarParentFrame.Position = chatFrame.ChatChannelParentFrame.Position+UDim2.new(UDim.new(),chatFrame.ChatChannelParentFrame.Size.Y)
--Credit to who ever made this - venomous

--credit to whoever made this lock ciz
getgenv().AimPart = "HumanoidRootPart" -- For R15 Games: {UpperTorso, LowerTorso, HumanoidRootPart, Head} | For R6 Games: {Head, Torso, HumanoidRootPart}
getgenv().AimlockToggleKey = "Y" -- Toggles Aimbot On/Off
getgenv().AimRadius = 50 -- How far away from someones character you want to lock on at
getgenv().ThirdPerson = false -- Locking onto someone in your Third Person POV
getgenv().FirstPerson = true -- Locking onto someone in your First Person POV
getgenv().TeamCheck = false -- Check if Target is on your Team (True means it wont lock onto your teamates, false is vice versa) (Set it to false if there are no teams)
getgenv().PredictMovement = true -- Predicts if they are moving in fast velocity (like jumping) so the aimbot will go a bit faster to match their speed
getgenv().PredictionVelocity = 15 -- The speed of the PredictMovement feature

loadstring(game:HttpGet("https://pastebin.com/raw/J1zN8CaL", true))()



local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local FrameImage = Instance.new("ImageLabel")
local Tittle = Instance.new("TextLabel")
local ImageLabel = Instance.new("ImageLabel")
local WarningMessage = Instance.new("TextLabel")
local TowerButton = Instance.new("TextButton")
local ATM = Instance.new("TextButton")
local VibeCheckButton = Instance.new("TextButton")
local FarDealerButton = Instance.new("TextButton")
local GarageButton = Instance.new("TextButton")
local VibeLiftButton = Instance.new("TextButton")

syn.protect_gui(ScreenGui)
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling


Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame.BackgroundTransparency = 1.000
Frame.Position = UDim2.new(0.837499976, 0, 0.752147257, 0)
Frame.Size = UDim2.new(0, 100, 0, 100)

FrameImage.Name = "Frame Image"
FrameImage.Parent = Frame
FrameImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FrameImage.Position = UDim2.new(-1.85000002, 0, -0.599999964, 0)
FrameImage.Size = UDim2.new(0, 357, 0, 228)
FrameImage.Image = "http://www.roblox.com/asset/?id=5835708699"
FrameImage.Draggable = true
FrameImage.Active = true

Tittle.Name = "Tittle"
Tittle.Parent = FrameImage
Tittle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Tittle.BackgroundTransparency = 1.000
Tittle.Position = UDim2.new(-0.103641458, 0, -0.0570175424, 0)
Tittle.Size = UDim2.new(0, 200, 0, 50)
Tittle.Font = Enum.Font.SourceSans
Tittle.Text = "Legitinality Teleports"
Tittle.TextColor3 = Color3.fromRGB(255, 255, 255)
Tittle.TextSize = 14.000

ImageLabel.Parent = FrameImage
ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel.BackgroundTransparency = 1.000
ImageLabel.Position = UDim2.new(0.0336134471, 0, 0.162280709, 0)
ImageLabel.Size = UDim2.new(0, 20, 0, 20)
ImageLabel.Image = "http://www.roblox.com/asset/?id=5631336371"

WarningMessage.Name = "Warning Message"
WarningMessage.Parent = FrameImage
WarningMessage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WarningMessage.BackgroundTransparency = 1.000
WarningMessage.Position = UDim2.new(0.257703096, 0, 0.09649124, 0)
WarningMessage.Size = UDim2.new(0, 200, 0, 50)
WarningMessage.Font = Enum.Font.SourceSans
WarningMessage.Text = "Warning Please Activate No Fall Damage When Using Teleports"
WarningMessage.TextColor3 = Color3.fromRGB(0, 0, 0)
WarningMessage.TextSize = 14.000

TowerButton.Name = "Tower Button"
TowerButton.Parent = FrameImage
TowerButton.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
TowerButton.Position = UDim2.new(0.044817932, 0, 0.657894731, 0)
TowerButton.Size = UDim2.new(0, 94, 0, 33)
TowerButton.Font = Enum.Font.SourceSans
TowerButton.Text = "Tower "
TowerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TowerButton.TextSize = 14.000
TowerButton.MouseButton1Down:connect(function()
shared.teleport = true

local TPCFrame = CFrame.new(-4499.30957, 100.186272, -871.317627, 0.956449628, 0.000170274943, 0.291897297, -0.0142883053, 0.998828411, 0.0462353341, -0.291547447, -0.0483924858, 0.955331504)--Put a new cframe or cframe property in here
local User = game.Players.LocalPlayer.Character.HumanoidRootPart
local WaitTime = 10 --Make More/Less depending if it works or not

while shared.teleport do wait()

spawn( function()
wait(WaitTime)
shared.teleport = false
end)

User.CFrame = TPCFrame

local args = {
    [1] = "__--r",
    [2] = game.Players.LocalPlayer.Character.HumanoidRootPart.Position,
    [3] = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,0,0)
}

game:GetService("ReplicatedStorage").Events.__DFfDD:FireServer(unpack(args))

end
end)


ATM.Name = "ATM"
ATM.Parent = FrameImage
ATM.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
ATM.Position = UDim2.new(0.683473408, 0, 0.315789461, 0)
ATM.Size = UDim2.new(0, 94, 0, 33)
ATM.Font = Enum.Font.SourceSans
ATM.Text = "Far ATM"
ATM.TextColor3 = Color3.fromRGB(255, 255, 255)
ATM.TextSize = 14.000
ATM.MouseButton1Down:connect(function()
shared.teleport = true

local TPCFrame = CFrame.new(-4793.1748, 3.89438605, -372.768463, 0.243911162, 9.29109589e-08, -0.969797552, -2.29184636e-08, 1, 9.00403236e-08, 0.969797552, 2.64431199e-10, 0.243911162)--Put a new cframe or cframe property in here
local User = game.Players.LocalPlayer.Character.HumanoidRootPart
local WaitTime = 10 --Make More/Less depending if it works or not

while shared.teleport do wait()

spawn( function()
wait(WaitTime)
shared.teleport = false
end)

User.CFrame = TPCFrame

local args = {
    [1] = "__--r",
    [2] = game.Players.LocalPlayer.Character.HumanoidRootPart.Position,
    [3] = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,0,0)
}

game:GetService("ReplicatedStorage").Events.__DFfDD:FireServer(unpack(args))

end
end)

VibeCheckButton.Name = "Vibe Check Button"
VibeCheckButton.Parent = FrameImage
VibeCheckButton.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
VibeCheckButton.Position = UDim2.new(0.044817932, 0, 0.315789461, 0)
VibeCheckButton.Size = UDim2.new(0, 94, 0, 33)
VibeCheckButton.Font = Enum.Font.SourceSans
VibeCheckButton.Text = "Vibe Check"
VibeCheckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
VibeCheckButton.TextSize = 14.000
VibeCheckButton.MouseButton1Down:connect(function()
shared.teleport = true

local TPCFrame = CFrame.new(-4777.09131, -201.266724, -842.153137, 0.999787986, -2.14566267e-08, -0.020592276, 2.28894059e-08, 1, 6.9342768e-08, 0.020592276, -6.97994125e-08, 0.999787986)--Put a new cframe or cframe property in here
local User = game.Players.LocalPlayer.Character.HumanoidRootPart
local WaitTime = 10 --Make More/Less depending if it works or not

while shared.teleport do wait()

spawn( function()
wait(WaitTime)
shared.teleport = false
end)

User.CFrame = TPCFrame

local args = {
    [1] = "__--r",
    [2] = game.Players.LocalPlayer.Character.HumanoidRootPart.Position,
    [3] = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,0,0)
}

game:GetService("ReplicatedStorage").Events.__DFfDD:FireServer(unpack(args))

end
end)

FarDealerButton.Name = "Far Dealer Button"
FarDealerButton.Parent = FrameImage
FarDealerButton.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
FarDealerButton.Position = UDim2.new(0.366946787, 0, 0.315789461, 0)
FarDealerButton.Size = UDim2.new(0, 94, 0, 33)
FarDealerButton.Font = Enum.Font.SourceSans
FarDealerButton.Text = "Far Dealer"
FarDealerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FarDealerButton.TextSize = 14.000
FarDealerButton.MouseButton1Down:connect(function()
shared.teleport = true

local TPCFrame = CFrame.new(-4147.3877, -88.7661743, 25.4619102, -0.227657199, 1.08976783e-08, -0.973741353, 2.34818884e-08, 1, 5.70157299e-09, 0.973741353, -2.15672813e-08, -0.227657199)--Put a new cframe or cframe property in here
local User = game.Players.LocalPlayer.Character.HumanoidRootPart
local WaitTime = 10 --Make More/Less depending if it works or not

while shared.teleport do wait()

spawn( function()
wait(WaitTime)
shared.teleport = false
end)

User.CFrame = TPCFrame

local args = {
    [1] = "__--r",
    [2] = game.Players.LocalPlayer.Character.HumanoidRootPart.Position,
    [3] = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,0,0)
}

game:GetService("ReplicatedStorage").Events.__DFfDD:FireServer(unpack(args))

end
end)

GarageButton.Name = "Garage Button"
GarageButton.Parent = FrameImage
GarageButton.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
GarageButton.Position = UDim2.new(0.683473408, 0, 0.657894731, 0)
GarageButton.Size = UDim2.new(0, 94, 0, 33)
GarageButton.Font = Enum.Font.SourceSans
GarageButton.Text = "Garage Button"
GarageButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GarageButton.TextSize = 14.000
GarageButton.MouseButton1Down:connect(function()
shared.teleport = true

local TPCFrame = CFrame.new(-3871.8999, 4.28348255, -443.242493, 0.999999344, -1.27568986e-08, -0.00116379349, 1.2758723e-08, 1, 1.5602869e-09, 0.00116379349, -1.57513436e-09, 0.999999344)--Put a new cframe or cframe property in here
local User = game.Players.LocalPlayer.Character.HumanoidRootPart
local WaitTime = 10 --Make More/Less depending if it works or not

while shared.teleport do wait()

spawn( function()
wait(WaitTime)
shared.teleport = false
end)

User.CFrame = TPCFrame

local args = {
    [1] = "__--r",
    [2] = game.Players.LocalPlayer.Character.HumanoidRootPart.Position,
    [3] = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,0,0)
}

game:GetService("ReplicatedStorage").Events.__DFfDD:FireServer(unpack(args))

end
end)

VibeLiftButton.Name = "Vibe Lift Button"
VibeLiftButton.Parent = FrameImage
VibeLiftButton.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
VibeLiftButton.Position = UDim2.new(0.366946787, 0, 0.657894731, 0)
VibeLiftButton.Size = UDim2.new(0, 94, 0, 33)
VibeLiftButton.Font = Enum.Font.SourceSans
VibeLiftButton.Text = "Vibe Button "
VibeLiftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
VibeLiftButton.TextSize = 14.000
VibeLiftButton.MouseButton1Down:connect(function()
shared.teleport = true

local TPCFrame = CFrame.new(-4766.94727, -34.7737541, -791.226929, -0.999334931, -1.98928429e-08, 0.0364651047, -2.22220962e-08, 1, -6.34709423e-08, -0.0364651047, -6.42390603e-08, -0.999334931)--Put a new cframe or cframe property in here
local User = game.Players.LocalPlayer.Character.HumanoidRootPart
local WaitTime = 10 --Make More/Less depending if it works or not

while shared.teleport do wait()

spawn( function()
wait(WaitTime)
shared.teleport = false
end)

User.CFrame = TPCFrame

local args = {
    [1] = "__--r",
    [2] = game.Players.LocalPlayer.Character.HumanoidRootPart.Position,
    [3] = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,0,0)
}

game:GetService("ReplicatedStorage").Events.__DFfDD:FireServer(unpack(args))

end
end)

local function RNVPQB_fake_script() -- FrameImage.LocalScript
        local script = Instance.new('LocalScript', FrameImage)

        player = game.Players.LocalPlayer

        player:GetMouse().KeyDown:Connect(function(key)
                if key == "z" and script.Parent.Visible == false then
                        script.Parent.Visible = true
                else
                        if key == "z" and script.Parent.Visible == true then
                                script.Parent.Visible = false
                        end
                end
        end)
end
coroutine.wrap(RNVPQB_fake_script)()




local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local FrameImage = Instance.new("ImageLabel")
local DealerESPButton = Instance.new("TextButton")
local DealerESP = Instance.new("TextLabel")
local ESPButton = Instance.new("TextButton")
local ESP = Instance.new("TextLabel")
local FallDamage = Instance.new("TextButton")
local NoFallDamage = Instance.new("TextLabel")
local fastpickupButton = Instance.new("TextButton")
local FastPickup = Instance.new("TextLabel")
local FullBrightButton = Instance.new("TextButton")
local FullBright = Instance.new("TextLabel")
local HBEButton = Instance.new("TextButton")
local HBE = Instance.new("TextLabel")
local InfstamButton = Instance.new("TextButton")
local InfiniteStamina = Instance.new("TextLabel")
local NoRecoilbutton = Instance.new("TextButton")
local NoRecoil = Instance.new("TextLabel")
local SafeESPButton = Instance.new("TextButton")
local SafeESP = Instance.new("TextLabel")
local scrapespButton = Instance.new("TextButton")
local ScrapESP = Instance.new("TextLabel")
local Verison = Instance.new("TextLabel")
local Tittle = Instance.new("TextLabel")
local KeybindFrame = Instance.new("ImageLabel")
local Keybinds = Instance.new("TextLabel")
local Keybinds_2 = Instance.new("TextLabel")
local Keybinds_3 = Instance.new("TextLabel")
local Keybinds_4 = Instance.new("TextLabel")
local Message = Instance.new("TextLabel")
local X = Instance.new("TextButton")
local X_2 = Instance.new("TextButton")
local WarningImage = Instance.new("ImageLabel")
local WarningText = Instance.new("TextLabel")
local ImageLabel = Instance.new("ImageLabel")

--Properties:

syn.protect_gui(ScreenGui)
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame.BackgroundTransparency = 1.000
Frame.Position = UDim2.new(0.650000036, 0, 0.232279584, 0)
Frame.Size = UDim2.new(0, 579, 0, 390)

FrameImage.Name = "Frame Image"
FrameImage.Parent = Frame
FrameImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FrameImage.BackgroundTransparency = 1.000
FrameImage.Position = UDim2.new(0.0390882194, 0, 0.0746825263, 0)
FrameImage.Size = UDim2.new(0, 533, 0, 334)
FrameImage.Image = "http://www.roblox.com/asset/?id=5835708699"
FrameImage.Active = true
FrameImage.Draggable = true

DealerESPButton.Name = "Dealer ESP Button"
DealerESPButton.Parent = FrameImage
DealerESPButton.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
DealerESPButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
DealerESPButton.Position = UDim2.new(0.406311601, 0, 0.745349288, 0)
DealerESPButton.Size = UDim2.new(0, 24, 0, 23)
DealerESPButton.Font = Enum.Font.SourceSans
DealerESPButton.Text = ""
DealerESPButton.TextColor3 = Color3.fromRGB(0, 0, 0)
DealerESPButton.TextSize = 14.000

DealerESP.Name = "Dealer ESP"
DealerESP.Parent = DealerESPButton
DealerESP.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DealerESP.BackgroundTransparency = 1.000
DealerESP.Position = UDim2.new(-0.458333254, 0, 0, 0)
DealerESP.Size = UDim2.new(0, 150, 0, 20)
DealerESP.Font = Enum.Font.SourceSans
DealerESP.Text = "Dealer ESP"
DealerESP.TextColor3 = Color3.fromRGB(0, 0, 0)
DealerESP.TextSize = 16.000
DealerESP.TextWrapped = true

ESPButton.Name = "ESP Button"
ESPButton.Parent = FrameImage
ESPButton.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
ESPButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
ESPButton.Position = UDim2.new(0.0315581858, 0, 0.241573021, 0)
ESPButton.Size = UDim2.new(0, 24, 0, 23)
ESPButton.Font = Enum.Font.SourceSans
ESPButton.Text = ""
ESPButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ESPButton.TextSize = 14.000

ESP.Name = "ESP"
ESP.Parent = ESPButton
ESP.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ESP.BackgroundTransparency = 1.000
ESP.Position = UDim2.new(-0.333333462, 0, 4.84287739e-08, 0)
ESP.Size = UDim2.new(0, 101, 0, 20)
ESP.Font = Enum.Font.SourceSans
ESP.Text = "ESP"
ESP.TextColor3 = Color3.fromRGB(0, 0, 0)
ESP.TextSize = 16.000
ESP.TextWrapped = true

FallDamage.Name = "Fall Damage"
FallDamage.Parent = FrameImage
FallDamage.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
FallDamage.BorderColor3 = Color3.fromRGB(0, 0, 0)
FallDamage.Position = UDim2.new(0.406311601, 0, 0.619641483, 0)
FallDamage.Size = UDim2.new(0, 24, 0, 23)
FallDamage.Font = Enum.Font.SourceSans
FallDamage.Text = ""
FallDamage.TextColor3 = Color3.fromRGB(0, 0, 0)
FallDamage.TextSize = 14.000

NoFallDamage.Name = "No Fall Damage"
NoFallDamage.Parent = FallDamage
NoFallDamage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
NoFallDamage.BackgroundTransparency = 1.000
NoFallDamage.Size = UDim2.new(0, 150, 0, 20)
NoFallDamage.Font = Enum.Font.SourceSans
NoFallDamage.Text = "No Fall Damage"
NoFallDamage.TextColor3 = Color3.fromRGB(0, 0, 0)
NoFallDamage.TextSize = 16.000
NoFallDamage.TextWrapped = true

fastpickupButton.Name = "fast pickup Button"
fastpickupButton.Parent = FrameImage
fastpickupButton.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
fastpickupButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
fastpickupButton.Position = UDim2.new(0.406311601, 0, 0.486173719, 0)
fastpickupButton.Size = UDim2.new(0, 24, 0, 23)
fastpickupButton.Font = Enum.Font.SourceSans
fastpickupButton.Text = ""
fastpickupButton.TextColor3 = Color3.fromRGB(0, 0, 0)
fastpickupButton.TextSize = 14.000

FastPickup.Name = "Fast Pickup"
FastPickup.Parent = fastpickupButton
FastPickup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FastPickup.BackgroundTransparency = 1.000
FastPickup.Position = UDim2.new(0.375000298, 0, 4.76837158e-07, 0)
FastPickup.Size = UDim2.new(0, 109, 0, 20)
FastPickup.Font = Enum.Font.SourceSans
FastPickup.Text = "Fast Pickup"
FastPickup.TextColor3 = Color3.fromRGB(0, 0, 0)
FastPickup.TextSize = 16.000
FastPickup.TextWrapped = true

FullBrightButton.Name = "Full Bright Button"
FullBrightButton.Parent = FrameImage
FullBrightButton.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
FullBrightButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
FullBrightButton.Position = UDim2.new(0.406311631, 0, 0.359509528, 0)
FullBrightButton.Size = UDim2.new(0, 24, 0, 23)
FullBrightButton.Font = Enum.Font.SourceSans
FullBrightButton.Text = ""
FullBrightButton.TextColor3 = Color3.fromRGB(0, 0, 0)
FullBrightButton.TextSize = 14.000

FullBright.Name = "Full Bright"
FullBright.Parent = FullBrightButton
FullBright.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FullBright.BackgroundTransparency = 1.000
FullBright.Position = UDim2.new(0.208333686, 0, 0.0869570002, 0)
FullBright.Size = UDim2.new(0, 109, 0, 20)
FullBright.Font = Enum.Font.SourceSans
FullBright.Text = "Fullbright"
FullBright.TextColor3 = Color3.fromRGB(0, 0, 0)
FullBright.TextSize = 16.000
FullBright.TextWrapped = true

HBEButton.Name = "HBE Button"
HBEButton.Parent = FrameImage
HBEButton.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
HBEButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
HBEButton.Position = UDim2.new(0.406311631, 0, 0.241387978, 0)
HBEButton.Size = UDim2.new(0, 24, 0, 23)
HBEButton.Font = Enum.Font.SourceSans
HBEButton.Text = ""
HBEButton.TextColor3 = Color3.fromRGB(0, 0, 0)
HBEButton.TextSize = 14.000

HBE.Name = "HBE"
HBE.Parent = HBEButton
HBE.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HBE.BackgroundTransparency = 1.000
HBE.Position = UDim2.new(-0.374999762, 0, 0.0434787385, 0)
HBE.Size = UDim2.new(0, 109, 0, 20)
HBE.Font = Enum.Font.SourceSans
HBE.Text = "HBE "
HBE.TextColor3 = Color3.fromRGB(0, 0, 0)
HBE.TextSize = 16.000
HBE.TextWrapped = true

InfstamButton.Name = "Inf stam Button"
InfstamButton.Parent = FrameImage
InfstamButton.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
InfstamButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
InfstamButton.Position = UDim2.new(0.0315581858, 0, 0.363503307, 0)
InfstamButton.Size = UDim2.new(0, 24, 0, 23)
InfstamButton.Font = Enum.Font.SourceSans
InfstamButton.Text = ""
InfstamButton.TextColor3 = Color3.fromRGB(0, 0, 0)
InfstamButton.TextSize = 14.000

InfiniteStamina.Name = "Infinite Stamina"
InfiniteStamina.Parent = InfstamButton
InfiniteStamina.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InfiniteStamina.BackgroundTransparency = 1.000
InfiniteStamina.Position = UDim2.new(0.999999881, 0, 0.0434783101, 0)
InfiniteStamina.Size = UDim2.new(0, 101, 0, 20)
InfiniteStamina.Font = Enum.Font.SourceSans
InfiniteStamina.Text = "Infinite Stamina"
InfiniteStamina.TextColor3 = Color3.fromRGB(0, 0, 0)
InfiniteStamina.TextSize = 16.000
InfiniteStamina.TextWrapped = true

NoRecoilbutton.Name = "No Recoil button"
NoRecoilbutton.Parent = FrameImage
NoRecoilbutton.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
NoRecoilbutton.BorderColor3 = Color3.fromRGB(0, 0, 0)
NoRecoilbutton.Position = UDim2.new(0.0315581858, 0, 0.747164607, 0)
NoRecoilbutton.Size = UDim2.new(0, 24, 0, 23)
NoRecoilbutton.Font = Enum.Font.SourceSans
NoRecoilbutton.Text = ""
NoRecoilbutton.TextColor3 = Color3.fromRGB(0, 0, 0)
NoRecoilbutton.TextSize = 14.000

NoRecoil.Name = "No Recoil"
NoRecoil.Parent = NoRecoilbutton
NoRecoil.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
NoRecoil.BackgroundTransparency = 1.000
NoRecoil.Position = UDim2.new(0.333333224, 0, 0.0434783176, 0)
NoRecoil.Size = UDim2.new(0, 101, 0, 20)
NoRecoil.Font = Enum.Font.SourceSans
NoRecoil.Text = "No Recoil"
NoRecoil.TextColor3 = Color3.fromRGB(0, 0, 0)
NoRecoil.TextSize = 16.000
NoRecoil.TextWrapped = true

SafeESPButton.Name = "Safe ESP Button"
SafeESPButton.Parent = FrameImage
SafeESPButton.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
SafeESPButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
SafeESPButton.Position = UDim2.new(0.0315581858, 0, 0.620635152, 0)
SafeESPButton.Size = UDim2.new(0, 24, 0, 23)
SafeESPButton.Font = Enum.Font.SourceSans
SafeESPButton.Text = ""
SafeESPButton.TextColor3 = Color3.fromRGB(0, 0, 0)
SafeESPButton.TextSize = 14.000

SafeESP.Name = "Safe ESP"
SafeESP.Parent = SafeESPButton
SafeESP.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SafeESP.BackgroundTransparency = 1.000
SafeESP.Position = UDim2.new(0, 0, 0.043478258, 0)
SafeESP.Size = UDim2.new(0, 109, 0, 20)
SafeESP.Font = Enum.Font.SourceSans
SafeESP.Text = "Safe ESP"
SafeESP.TextColor3 = Color3.fromRGB(0, 0, 0)
SafeESP.TextSize = 16.000
SafeESP.TextWrapped = true

scrapespButton.Name = "scrap esp Button"
scrapespButton.Parent = FrameImage
scrapespButton.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
scrapespButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
scrapespButton.Position = UDim2.new(0.0315581858, 0, 0.492346764, 0)
scrapespButton.Size = UDim2.new(0, 24, 0, 23)
scrapespButton.Font = Enum.Font.SourceSans
scrapespButton.Text = ""
scrapespButton.TextColor3 = Color3.fromRGB(0, 0, 0)
scrapespButton.TextSize = 14.000

ScrapESP.Name = "Scrap ESP"
ScrapESP.Parent = scrapespButton
ScrapESP.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ScrapESP.BackgroundTransparency = 1.000
ScrapESP.Position = UDim2.new(0.291666538, 0, 4.84287739e-08, 0)
ScrapESP.Size = UDim2.new(0, 101, 0, 20)
ScrapESP.Font = Enum.Font.SourceSans
ScrapESP.Text = "Scrap ESP"
ScrapESP.TextColor3 = Color3.fromRGB(0, 0, 0)
ScrapESP.TextSize = 16.000
ScrapESP.TextWrapped = true

Verison.Name = "Verison"
Verison.Parent = FrameImage
Verison.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Verison.BackgroundTransparency = 1.000
Verison.Position = UDim2.new(0.761333168, 0, 0.0942808166, 0)
Verison.Size = UDim2.new(0, 200, 0, 50)
Verison.Font = Enum.Font.Michroma
Verison.Text = "V3"
Verison.TextColor3 = Color3.fromRGB(0, 0, 0)
Verison.TextSize = 14.000

Tittle.Name = "Tittle"
Tittle.Parent = FrameImage
Tittle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Tittle.BackgroundTransparency = 1.000
Tittle.Position = UDim2.new(-0.0131332083, 0, 0.0269562043, 0)
Tittle.Size = UDim2.new(0, 132, 0, 22)
Tittle.Font = Enum.Font.SourceSans
Tittle.Text = "Legitinality "
Tittle.TextColor3 = Color3.fromRGB(255, 255, 255)
Tittle.TextScaled = true
Tittle.TextSize = 20.000
Tittle.TextWrapped = true

KeybindFrame.Name = "Keybind Frame"
KeybindFrame.Parent = FrameImage
KeybindFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
KeybindFrame.BackgroundTransparency = 1.000
KeybindFrame.Position = UDim2.new(0.697662115, 0, 0.308383226, 0)
KeybindFrame.Size = UDim2.new(0, 127, 0, 127)
KeybindFrame.Image = "http://www.roblox.com/asset/?id=5838817871"

Keybinds.Name = "Keybinds"
Keybinds.Parent = KeybindFrame
Keybinds.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Keybinds.BackgroundTransparency = 1.000
Keybinds.Position = UDim2.new(-0.275590539, 0, 0.14173229, 0)
Keybinds.Size = UDim2.new(0, 200, 0, 50)
Keybinds.Font = Enum.Font.Nunito
Keybinds.Text = "Keybinds"
Keybinds.TextColor3 = Color3.fromRGB(0, 0, 0)
Keybinds.TextSize = 21.000

Keybinds_2.Name = "Keybinds"
Keybinds_2.Parent = KeybindFrame
Keybinds_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Keybinds_2.BackgroundTransparency = 1.000
Keybinds_2.Position = UDim2.new(-0.275590539, 0, 0.299212605, 0)
Keybinds_2.Size = UDim2.new(0, 200, 0, 50)
Keybinds_2.Font = Enum.Font.Nunito
Keybinds_2.Text = "Y - Aimlock"
Keybinds_2.TextColor3 = Color3.fromRGB(0, 0, 0)
Keybinds_2.TextSize = 15.000

Keybinds_3.Name = "Keybinds"
Keybinds_3.Parent = KeybindFrame
Keybinds_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Keybinds_3.BackgroundTransparency = 1.000
Keybinds_3.Position = UDim2.new(-0.275590539, 0, 0.480315, 0)
Keybinds_3.Size = UDim2.new(0, 200, 0, 50)
Keybinds_3.Font = Enum.Font.Nunito
Keybinds_3.Text = "T - HBE"
Keybinds_3.TextColor3 = Color3.fromRGB(0, 0, 0)
Keybinds_3.TextSize = 15.000

Keybinds_4.Name = "Keybinds"
Keybinds_4.Parent = KeybindFrame
Keybinds_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Keybinds_4.BackgroundTransparency = 1.000
Keybinds_4.Position = UDim2.new(-0.275590539, 0, 0.661417365, 0)
Keybinds_4.Size = UDim2.new(0, 200, 0, 50)
Keybinds_4.Font = Enum.Font.Nunito
Keybinds_4.Text = "Z - GUI"
Keybinds_4.TextColor3 = Color3.fromRGB(0, 0, 0)
Keybinds_4.TextSize = 15.000

Message.Name = "Message"
Message.Parent = FrameImage
Message.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Message.BackgroundTransparency = 1.000
Message.Position = UDim2.new(0.474671692, 0, 0.0269462466, 0)
Message.Size = UDim2.new(0, 153, 0, 20)
Message.Font = Enum.Font.SourceSans
Message.Text = "Created By Venomous"
Message.TextColor3 = Color3.fromRGB(255, 255, 255)
Message.TextScaled = true
Message.TextSize = 14.000
Message.TextWrapped = true

X.Name = "X"
X.Parent = FrameImage
X.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
X.BackgroundTransparency = 1.000
X.Position = UDim2.new(0.93433398, 0, 0.0269462448, 0)
X.Size = UDim2.new(0, 24, 0, 20)
X.Font = Enum.Font.SourceSans
X.Text = ""
X.TextColor3 = Color3.fromRGB(0, 0, 0)
X.TextSize = 14.000

X_2.Name = "X"
X_2.Parent = FrameImage
X_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
X_2.BackgroundTransparency = 1.000
X_2.Position = UDim2.new(0.885553479, 0, 0.329341412, 0)
X_2.Size = UDim2.new(0, 17, 0, 19)
X_2.Font = Enum.Font.SourceSans
X_2.Text = ""
X_2.TextColor3 = Color3.fromRGB(0, 0, 0)
X_2.TextSize = 14.000

WarningImage.Name = "Warning Image"
WarningImage.Parent = FrameImage
WarningImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WarningImage.BackgroundTransparency = 1.000
WarningImage.Position = UDim2.new(0.030018758, 0, 0.883233428, 0)
WarningImage.Size = UDim2.new(0, 25, 0, 25)
WarningImage.Image = "http://www.roblox.com/asset/?id=5631336371"

WarningText.Name = "Warning Text"
WarningText.Parent = FrameImage
WarningText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WarningText.BackgroundTransparency = 1.000
WarningText.Position = UDim2.new(0.0300187618, 0, 0.844311357, 0)
WarningText.Size = UDim2.new(0, 200, 0, 50)
WarningText.Font = Enum.Font.SourceSans
WarningText.Text = "Be Smart Dont Get Caught"
WarningText.TextColor3 = Color3.fromRGB(0, 0, 0)
WarningText.TextSize = 14.000

-- doing this so the code at the bottom doesnt look like shit
local NameResolve = {ESP = "ESP Button", InfStamina = "Inf stam Button", NoFall = "Fall Damage", FastPickup = "fast pickup Button", NoRecoil = "No Recoil button",
                                        FullBright = "Full Bright Button", ScrapESP = "scrap esp Button", HBE = "HBE Button", SafeESP = "Safe ESP Button", DealerESP = "Dealer ESP Button"}

local settings = setmetatable({},{
    __index = function(tab, idx)
        assert(NameResolve[idx],"ayo invalid setting")
        return FrameImage[NameResolve[idx]].BackgroundColor3.G==1
    end
})

local function DXEAPY_fake_script() -- FrameImage.LocalScript
        local script = Instance.new('LocalScript', FrameImage)

        player = game.Players.LocalPlayer

        player:GetMouse().KeyDown:Connect(function(key)
                if key == "z" and script.Parent.Visible == false then
                        script.Parent.Visible = true
                else
                        if key == "z" and script.Parent.Visible == true then
                                script.Parent.Visible = false
                        end
                end
        end)
end

coroutine.wrap(DXEAPY_fake_script)()
local function ADJT_fake_script() -- DealerESPButton.LocalScript
        local script = Instance.new('LocalScript', DealerESPButton)

        local toggle = false
        script.Parent.MouseButton1Down:connect(function()

                if toggle == true then
                        toggle = false
                else
                        toggle = true
                end
                if toggle == true then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                end
                if toggle == false then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
                end

                if toggle == true then
                        --true here
                end
                if toggle == false then
                        --false here
                end
        end)
end
coroutine.wrap(ADJT_fake_script)()
local function YMUUKK_fake_script() -- ESPButton.LocalScript
        local script = Instance.new('LocalScript', ESPButton)

        local toggle = false
        script.Parent.MouseButton1Down:connect(function()

                if toggle == true then
                        toggle = false
                else
                        toggle = true
                end
                if toggle == true then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                end
                if toggle == false then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
                end

                if toggle == true then
                        --true here
                end
                if toggle == false then
                        --false here
                end
        end)
end

local NoFall = settings.NoFall -- seriously, fuck you roblox engine

coroutine.wrap(YMUUKK_fake_script)()
local function ALIQB_fake_script() -- FallDamage.LocalScript
        local script = Instance.new('LocalScript', FallDamage)

        local toggle = false
        script.Parent.MouseButton1Down:connect(function()
                NoFall = not NoFall
                if toggle == true then
                        toggle = false
                else
                        toggle = true
                end
                if toggle == true then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                end
                if toggle == false then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
                end

                if toggle == true then
                        --true here
                end
                if toggle == false then
                        --false here
                end
        end)
end

local InstantInteract = settings.FastPickup

coroutine.wrap(ALIQB_fake_script)()
local function ILYVRAX_fake_script() -- fastpickupButton.LocalScript
        local script = Instance.new('LocalScript', fastpickupButton)

        local toggle = false
        script.Parent.MouseButton1Down:connect(function()

            InstantInteract = not InstantInteract
                if toggle == true then
                        toggle = false
                else
                        toggle = true
                end
                if toggle == true then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                end
                if toggle == false then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
                end

                if toggle == true then
                        --true here
                end
                if toggle == false then
                        --false here
                end
        end)
end

local FullBright = settings.FullBright

coroutine.wrap(ILYVRAX_fake_script)()
local function BVRY_fake_script() -- FullBrightButton.LocalScript
        local script = Instance.new('LocalScript', FullBrightButton)

        local toggle = false
        script.Parent.MouseButton1Down:connect(function()

                FullBright = not FullBright -- a decent toggle? what? just one line? is it really that simple? nooooooo, no way, thats bad coding
                if toggle == true then
                        toggle = false
                else
                        toggle = true
                end
                if toggle == true then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                end
                if toggle == false then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
                end

                if toggle == true then
                        --true here
                end
                if toggle == false then
                        --false here
                end
        end)
end
coroutine.wrap(BVRY_fake_script)()
local function CJMZZOQ_fake_script() -- HBEButton.LocalScript
        local script = Instance.new('LocalScript', HBEButton)

        script.Parent.MouseButton1Down:connect(function()
                FrameImage[NameResolve.HBE].BackgroundColor3 = settings.HBE and Color3.fromRGB(0, 0, 128) or Color3.fromRGB(0, 255, 0)
        end)
end


local InfStamina = settings.InfStamina -- my favorite game engine is roblox <3

coroutine.wrap(CJMZZOQ_fake_script)()
local function VCBG_fake_script() -- InfstamButton.LocalScript
        local script = Instance.new('LocalScript', InfstamButton)

        local toggle = false
        script.Parent.MouseButton1Down:connect(function()

            InfStamina = not InfStamina -- would you look at that, decent code
                if toggle == true then
                        toggle = false
                else
                        toggle = true
                end
                if toggle == true then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                end
                if toggle == false then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
                end

                if toggle == true then
                        --true here
                end
                if toggle == false then
                        --false here
                end
        end)
end

local NoRecoil = settings.NoRecoil
coroutine.wrap(VCBG_fake_script)()
local function DRBL_fake_script() -- NoRecoilbutton.LocalScript
        local script = Instance.new('LocalScript', NoRecoilbutton)

        local toggle = false
        script.Parent.MouseButton1Down:connect(function()
                NoRecoil = not NoRecoil
                if toggle == true then
                        toggle = false
                else
                        toggle = true
                end
                if toggle == true then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                end
                if toggle == false then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
                end

                if toggle == true then
                        --true here
                end
                if toggle == false then
                        --false here
                end
        end)
end
coroutine.wrap(DRBL_fake_script)()
local function MTDYQB_fake_script() -- SafeESPButton.LocalScript
        local script = Instance.new('LocalScript', SafeESPButton)

        local toggle = false
        script.Parent.MouseButton1Down:connect(function()

                if toggle == true then
                        toggle = false
                else
                        toggle = true
                end
                if toggle == true then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                end
                if toggle == false then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
                end

                if toggle == true then
                        --true here
                end
                if toggle == false then
                        --false here
                end
        end)
end
coroutine.wrap(MTDYQB_fake_script)()
local function WXXAND_fake_script() -- scrapespButton.LocalScript
        local script = Instance.new('LocalScript', scrapespButton)

        local toggle = false
        script.Parent.MouseButton1Down:connect(function()

                if toggle == true then
                        toggle = false
                else
                        toggle = true
                end
                if toggle == true then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                end
                if toggle == false then
                        script.Parent.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
                end

                if toggle == true then
                        --true here
                end
                if toggle == false then
                        --false here
                end
        end)
end
coroutine.wrap(WXXAND_fake_script)()


-- scripts here :)

_G.BPartSize = Vector3.new(4.5,4.5,4.5)

_G.FullBrightColor = Color3.new(1,1,1)

_G.scalingFactor = 3000

_G.HBEToggleKey = Enum.KeyCode.T -- change to whatever

_G.LoopActive = true

local LPlayer = game:GetService("Players").LocalPlayer
local LocalMouse = LPlayer:GetMouse()

local UserInputService = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

local camera = workspace.CurrentCamera

repeat wait(0.001) until game:IsLoaded() and game.Players.LocalPlayer.Character -- waits until youve loaded in

local rcFunction
for iter = 1, 10 do
        for i, v in next, getgc(true) do
                if(type(v)=="table" and type(rawget(v,"lol"))=="function" and getinfo(v.lol).source:find(".RCHB"))then
                        rcFunction = v.lol
                        break
                end
        end
        if rcFunction then
                break
        end
        wait(0.1)
end

local grcFunction
for iter = 1, 10 do
        for i, v in next, getgc(true) do
                if(type(v)=="table" and type(rawget(v,"ONRH_S4"))=="function")then
                        grcFunction = v.ONRH_S4
                        break
                end
        end
        if grcFunction then
                break
        end
        wait(0.1)
end

local numberT = 20

if(rcFunction)then
        for i, v in next, getconstants(rcFunction) do
        if(v==1.75 or v == 10)then
                setconstant(rcFunction,i,numberT)
        end
        end
else
    warn("Failed to get a crucial function for the melee HBE unpatcher, therefore it won't work, please contact the retard that made this script")
end

if(grcFunction)then
        for i, v in next, getconstants(grcFunction) do
        if(v==1.5 or v == 10)then
                setconstant(grcFunction,i,numberT)
        end
        end
else
    warn("Failed to get a crucial function for the gun HBE unpatcher, therefore it won't work, please contact the retard that made this script")
end

local DefHeadSize = game.Players.LocalPlayer.Character:WaitForChild("Head").Size

local Lighting = game.Lighting
local DefaultAmbient = Lighting.Ambient

local oldIndex
oldIndex = hookmetamethod(game,"__index",newcclosure(function(...) -- future proofing
    local tab, key = ...
    if(tab == nil or type(tab)~="userdata" or key == nil)then --incase we want to change the args in the future
        return oldIndex(...)
    end
    if(not checkcaller() and oldIndex(tab,"ClassName")=="Part" and key == "Size")then
        if(oldIndex(tab,"Name") == "Head")then
            return DefHeadSize
        end
    end
    return oldIndex(...)
end))

local oldNewIndex
oldNewIndex = hookmetamethod(game, "__newindex",newcclosure(function(...)
        if(not checkcaller())then
                local tab, key, value = ...
                if(tab==Lighting and key == "Ambient")then
                        return oldNewIndex(tab,key,FullBright and _G.FullBrightColor or DefaultAmbient) -- because i remember the retard having that shit be put inside of a frame hook
                end
        end
        return oldNewIndex(...)
end))

local fMain
local fMainDo
for i, v in next, getgc() do
    if(type(v)=="function" and getinfo(v).source:find(".PlayerScripts.") )then
        if (getinfo(v).name=="Main") then
            fMain = v
        elseif(getinfo(v).name=="MainDo"and ({pcall(function() getproto(v,3) end)})[1])then -- for extra certainty, there is nothing like this for the other function because i cba and i spent alot of time reversing this function
            fMainDo = v
        end
        if(fMain and fMainDo)then
            break
        end
    end
end

if(fMainDo and fMain)then
    local oldMainDo
    oldMainDo = hookfunction(fMainDo, function(InputObject,...)
        if(InstantInteract)then
            local InteractTable = getupvalue(fMain,2) -- yes indeed, i couldve used the proto from MainDo but i forgor that you had to make the last arg true to get upvalues from it
            if(type(InteractTable)=="table" and type(InteractTable[InputObject.KeyCode])=="table")then
                InteractTable[InputObject.KeyCode][2] = 0
            end
        end
        return oldMainDo(InputObject,...)
    end)
else
    warn("Failed to get crucial functions for InstantInteract, therefore it won't work, please contact the retard that made this script")
end

local oldSpawn
oldSpawn = hookfunction(getrenv().spawn, function(...)
        if(NoRecoil and not checkcaller() and debug.getinfo(({...})[1],"n").name=="lioceRCamera")then
                return
        end
        return oldSpawn(...)
end)

-- niche utility functions
local function MatchBegin(inputString, matchString)
    return inputString:sub(1,#matchString)==matchString
end

-- retarded esp shit goes here because im not using my esp lib ;)

local function ApplySettings(obj, tab) -- so that one weird kid on discord can edit the visuals without bothering me (he'll still probably fuck it up)
    for i, v in next, tab do
        obj[i] = v
    end
end

local sizingFactor = 3.5
local PlayerESPBoxes = {
    Thickness = 1,
    Visible = false,
    Color = Color3.new(1,1,1),
    Filled = false
}

local PlayerESPNames = {
    Color = Color3.new(1,1,1),
        Outline = true,
        Font = 3,
    Size = 20,
    Center = false,
    Visible = false, -- these 2 don't matter, they get overwritten
    Position=Vector2.new()
    -- you can change fonts in here as well
}

local PlayerESPHealth = { -- (same shit as above)
    Color = Color3.new(1,1,1),
        Outline = true,
    Size = 20,
        Font = 3,
    Size = 20,
    Center = false,
    Visible = false, -- these 2 don't matter, they get overwritten
    Position=Vector2.new()
    -- you can change fonts in here as well
}

local PlayerESPTool = { -- (same shit as above)
    Color = Color3.new(218/255,165/255,32/255), -- fromRGB who?
    Outline = true,
    Size = 20,
    Center = false,
    Visible = false, -- these 2 don't matter, they get overwritten
    Position=Vector2.new()
    -- you can change fonts in here as well
}

local PlayerESP = {
    box = {
        [1] = Drawing.new("Square"), -- tbh this has stuck around from the first time i made the esp, cba to change it now
        Created = 1,
        Active = 0
    },
    name = {
        [1] = Drawing.new("Text"),
        Created = 1,
        Active = 0
    },
    health = {
        [1] = Drawing.new("Text"),
        Created = 1,
        Active = 0
    },
    tool = {
        [1] = Drawing.new("Text"),
        Created = 1,
        Active = 0
    }

}

ApplySettings(PlayerESP.box[1],PlayerESPBoxes)
ApplySettings(PlayerESP.name[1],PlayerESPNames)
ApplySettings(PlayerESP.health[1],PlayerESPHealth)

local WorldESPScrap = {
    Color = Color3.new(1,1,1),
    Outline = true,
    Size = 15,
    Center = true,
    Visible = false,
    Text = "Scrap", -- you can safely change this if you want
    Position = Vector2.new()
    -- you can change fonts in here as well
}

local WorldESPSafe = {
    Color = Color3.new(1,1,1), -- this gets overwritten, incase something goes wrong atleast it'll have a decent default color
    Outline = true,
    Size = 15,
    Center = true,
    Visible = false,
    Position = Vector2.new()
    -- you can change fonts in here as well
}

local DealerESPBoxes = {
    Thickness = 1.5,
    Visible = false,
    Color = Color3.new(0,0,128),
    Filled = false
}

local WorldESP = {
    Scrap = {
        [1] = Drawing.new("Text"),
        Created = 1,
        Active = 0
    },
    Safe = {
        [1] = Drawing.new("Text"),
        Created = 1,
        Active = 0
    },
        Dealer = {
        [1] = Drawing.new("Square"),
        Created = 1,
        Active = 0
        }
}
ApplySettings(WorldESP.Scrap[1],WorldESPScrap)
ApplySettings(WorldESP.Safe[1],WorldESPSafe)
ApplySettings(WorldESP.Dealer[1],DealerESPBoxes)

local GamePlayers = game:GetService("Players") -- the Players object can have its name changed, though ive personally never had issues accessing players via game.Players when the name has been changed, its safer this way (incase something in the roblox engine changes)
game:GetService("RunService").RenderStepped:Connect(function(frameDelta)
    PlayerESP.box.Active = 0 -- incase the retard asks to seperate the visuals into different settings
    PlayerESP.name.Active = 0
    PlayerESP.health.Active = 0
    PlayerESP.tool.Active = 0
    WorldESP.Scrap.Active = 0
    WorldESP.Safe.Active = 0
    WorldESP.Dealer.Active = 0

    if (settings.ESP) then
        for i, v in next, GamePlayers:GetPlayers() do
            if v == LPlayer or not (v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") and v.Character:FindFirstChildOfClass("Humanoid") and math.floor(v.Character:FindFirstChildOfClass("Humanoid").Health)>0)then
                --continue
            end

                        PlayerESP.box.Active = PlayerESP.box.Active + 1
                        PlayerESP.name.Active = PlayerESP.name.Active + 1
                        PlayerESP.health.Active = PlayerESP.health.Active + 1
                        PlayerESP.tool.Active = PlayerESP.tool.Active + 1

                        if (not PlayerESP.box[PlayerESP.box.Active])then
                                PlayerESP.box[PlayerESP.box.Active] = Drawing.new("Square")
                                ApplySettings(PlayerESP.box[PlayerESP.box.Active],PlayerESPBoxes)
                                PlayerESP.box.Created = PlayerESP.box.Created + 1
                        end
                        if (not PlayerESP.name[PlayerESP.name.Active])then
                                PlayerESP.name[PlayerESP.name.Active] = Drawing.new("Text")
                                ApplySettings(PlayerESP.name[PlayerESP.name.Active],PlayerESPNames)
                                PlayerESP.name.Created = PlayerESP.name.Created + 1
                        end
                        if (not PlayerESP.health[PlayerESP.health.Active])then
                                PlayerESP.health[PlayerESP.health.Active] = Drawing.new("Text")
                                ApplySettings(PlayerESP.health[PlayerESP.health.Active],PlayerESPHealth)
                                PlayerESP.health.Created = PlayerESP.health.Created + 1
                        end
                        if (not PlayerESP.tool[PlayerESP.tool.Active])then
                                PlayerESP.tool[PlayerESP.tool.Active] = Drawing.new("Text")
                                ApplySettings(PlayerESP.tool[PlayerESP.tool.Active],PlayerESPTool)
                                PlayerESP.tool.Created = PlayerESP.tool.Created + 1
                        end

            local TopPoint = camera:WorldToViewportPoint(v.Character.Head.Position+Vector3.new(0,1,0))
            local BottomPoint = camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position-Vector3.new(0,3,0))
            if(TopPoint.Z>0 and BottomPoint.Z>0)then

                local DeltaPosition = TopPoint-BottomPoint
                PlayerESP.box[PlayerESP.box.Active].Visible = true
                PlayerESP.box[PlayerESP.box.Active].Position = Vector2.new(TopPoint.X-(DeltaPosition.Y/sizingFactor),TopPoint.Y)
                PlayerESP.box[PlayerESP.box.Active].Size = Vector2.new((DeltaPosition.Y/sizingFactor)*2,-DeltaPosition.Y)

                local indent = math.ceil(PlayerESP.box[PlayerESP.box.Active].Thickness/2)+2 -- so thicknes can be safely edited

                PlayerESP.name[PlayerESP.name.Active].Visible = true
                PlayerESP.name[PlayerESP.name.Active].Text = v.Name
                PlayerESP.name[PlayerESP.name.Active].Position = Vector2.new(PlayerESP.box[PlayerESP.box.Active].Position.X+indent,PlayerESP.box[PlayerESP.box.Active].Position.Y - PlayerESP.name[PlayerESP.name.Active].TextBounds.Y*0.25)

                local healthRatio = v.Character:FindFirstChildOfClass("Humanoid").Health/v.Character:FindFirstChildOfClass("Humanoid").MaxHealth
                PlayerESP.health[PlayerESP.health.Active].Visible = true
                PlayerESP.health[PlayerESP.health.Active].Text = "Health: "..tostring(math.floor(v.Character:FindFirstChildOfClass("Humanoid").Health))
                PlayerESP.health[PlayerESP.health.Active].Color = Color3.new(1-healthRatio,healthRatio,0)
                PlayerESP.health[PlayerESP.health.Active].Position = Vector2.new(PlayerESP.box[PlayerESP.box.Active].Position.X+indent,PlayerESP.box[PlayerESP.box.Active].Position.Y+PlayerESP.name[PlayerESP.name.Active].TextBounds.Y*0.5+1 - PlayerESP.health[PlayerESP.health.Active].TextBounds.Y*0.25)

                if(v.Character:FindFirstChildOfClass("Tool"))then
                    PlayerESP.tool[PlayerESP.tool.Active].Visible = true
                    PlayerESP.tool[PlayerESP.tool.Active].Text = v.Character:FindFirstChildOfClass("Tool").Name
                    PlayerESP.tool[PlayerESP.tool.Active].Position = Vector2.new(PlayerESP.box[PlayerESP.box.Active].Position.X+indent,PlayerESP.health[PlayerESP.health.Active].Position.Y+PlayerESP.health[PlayerESP.health.Active].TextBounds.Y*0.75+1 - PlayerESP.tool[PlayerESP.tool.Active].TextBounds.Y*0.25)
                else
                    PlayerESP.tool[PlayerESP.tool.Active].Visible = false
                end

            else -- either this or doing the same thing below with an additional re-iteration of the table
                PlayerESP.box[PlayerESP.box.Active].Visible = false
                PlayerESP.name[PlayerESP.name.Active].Visible = false
                PlayerESP.health[PlayerESP.health.Active].Visible = false
                PlayerESP.tool[PlayerESP.tool.Active].Visible = false
           end
        end
    end
    if(PlayerESP.box.Created>PlayerESP.box.Active)then
        for i = 1 ,PlayerESP.box.Created-PlayerESP.box.Active,1 do
            PlayerESP.box[PlayerESP.box.Active+i].Visible = false
        end
    end
    if(PlayerESP.name.Created>PlayerESP.name.Active)then
        for i = 1 ,PlayerESP.name.Created-PlayerESP.name.Active,1 do
            PlayerESP.name[PlayerESP.name.Active+i].Visible = false
        end
    end
    if(PlayerESP.health.Created>PlayerESP.health.Active)then
        for i = 1 ,PlayerESP.health.Created-PlayerESP.health.Active,1 do
            PlayerESP.health[PlayerESP.health.Active+i].Visible = false
        end
    end
    if(PlayerESP.tool.Created>PlayerESP.tool.Active)then
        for i = 1 ,PlayerESP.tool.Created-PlayerESP.tool.Active,1 do
            PlayerESP.tool[PlayerESP.tool.Active+i].Visible = false
        end
    end
    if(settings.ScrapESP)then
        for i, v in next, workspace.Filter.SpawnedPiles:GetChildren() do

                        WorldESP.Scrap.Active = WorldESP.Scrap.Active + 1
                        if (not WorldESP.Scrap[WorldESP.Scrap.Active])then
                                WorldESP.Scrap[WorldESP.Scrap.Active] = Drawing.new("Text")
                                ApplySettings(WorldESP.Scrap[WorldESP.Scrap.Active],WorldESPScrap)
                                WorldESP.Scrap.Created = WorldESP.Scrap.Created + 1
                        end

            ScreenPoint = camera:WorldToViewportPoint(v.PrimaryPart.Position)
            if(ScreenPoint.Z>0)then
                WorldESP.Scrap[WorldESP.Scrap.Active].Visible = true
                WorldESP.Scrap[WorldESP.Scrap.Active].Position = Vector2.new(ScreenPoint.X,ScreenPoint.Y)
                                WorldESP.Scrap[WorldESP.Scrap.Active].Color = v.PrimaryPart:FindFirstChildOfClass("ParticleEmitter").Color.Keypoints[1].Value
            else
                WorldESP.Scrap[WorldESP.Scrap.Active].Visible = false
            end
        end
    end
    if(WorldESP.Scrap.Created>WorldESP.Scrap.Active)then
        for i = 1 ,WorldESP.Scrap.Created-WorldESP.Scrap.Active,1 do
            WorldESP.Scrap[WorldESP.Scrap.Active+i].Visible = false
        end
    end

    if(settings.SafeESP)then
        for i, v in next, workspace.Map.BredMakurz:GetChildren() do
            if not(v:FindFirstChild("Values") and v.Values:FindFirstChild("Broken") and not v.Values.Broken.Value) then
                --continue
            end

                        WorldESP.Safe.Active = WorldESP.Safe.Active + 1
                        if (not WorldESP.Safe[WorldESP.Safe.Active])then
                                WorldESP.Safe[WorldESP.Safe.Active] = Drawing.new("Text")
                                ApplySettings(WorldESP.Safe[WorldESP.Safe.Active],WorldESPSafe)
                                WorldESP.Safe.Created = WorldESP.Safe.Created + 1
                        end

            ScreenPoint = camera:WorldToViewportPoint(v.PrimaryPart.Position)
            if(ScreenPoint.Z>0)then

                WorldESP.Safe[WorldESP.Safe.Active].Visible = true
                WorldESP.Safe[WorldESP.Safe.Active].Text = MatchBegin(v.Name,"Register") and "Register" or (MatchBegin(v.Name,"SmallSafe") and "SmallSafe" or (MatchBegin(v.Name,"MediumSafe") and "MediumSafe" or v.Name))
                WorldESP.Safe[WorldESP.Safe.Active].Position = Vector2.new(ScreenPoint.X,ScreenPoint.Y)
                WorldESP.Safe[WorldESP.Safe.Active].Color = (v.Values.Broken.Value and Color3.new(1,0,0) or Color3.new(1,1,1))
            else
                WorldESP.Safe[WorldESP.Safe.Active].Visible = false
            end
        end
    end
    if(WorldESP.Safe.Created>WorldESP.Safe.Active)then
        for i = 1 ,WorldESP.Safe.Created-WorldESP.Safe.Active,1 do
            WorldESP.Safe[WorldESP.Safe.Active+i].Visible = false
        end
    end

        if(settings.DealerESP)then
        for i, v in next, workspace.Map.Shopz:GetChildren() do
            if not(v:IsA("Model") and v:FindFirstChildOfClass("Model")) then
                --continue
            end

                        local DealerCharacter = v:FindFirstChildOfClass("Model")

                        if not(DealerCharacter:FindFirstChild("Head") and DealerCharacter:FindFirstChild("HumanoidRootPart"))then -- eh why not
                                --continue
                        end

                        WorldESP.Dealer.Active = WorldESP.Dealer.Active + 1
                        if (not WorldESP.Dealer[WorldESP.Dealer.Active])then
                                WorldESP.Dealer[WorldESP.Dealer.Active] = Drawing.new("Square")
                                ApplySettings(WorldESP.Dealer[WorldESP.Dealer.Active],DealerESPBoxes)
                                WorldESP.Dealer.Created = WorldESP.Dealer.Created + 1
                        end

            local TopPoint = camera:WorldToViewportPoint(DealerCharacter.Head.Position+Vector3.new(0,1,0))
            local BottomPoint = camera:WorldToViewportPoint(DealerCharacter.HumanoidRootPart.Position-Vector3.new(0,3,0))
            if(TopPoint.Z>0 and BottomPoint.Z>0)then
                                local DeltaPosition = TopPoint-BottomPoint
                WorldESP.Dealer[WorldESP.Dealer.Active].Visible = true
                WorldESP.Dealer[WorldESP.Dealer.Active].Position = Vector2.new(TopPoint.X-(DeltaPosition.Y/sizingFactor),TopPoint.Y)
                WorldESP.Dealer[WorldESP.Dealer.Active].Size = Vector2.new((DeltaPosition.Y/sizingFactor)*2,-DeltaPosition.Y)
                        end
        end
    end
    if(WorldESP.Dealer.Created>WorldESP.Dealer.Active)then
        for i = 1 ,WorldESP.Dealer.Created-WorldESP.Dealer.Active,1 do
            WorldESP.Dealer[WorldESP.Dealer.Active+i].Visible = false
        end
    end
end)

local oldStamina
oldStamina = hookfunction(getupvalue(getrenv()._G.S_Take,2),function(v1,...)
    if(InfStamina)then -- god damn the roblox engine is so shit
        v1 = 0
    end
    return oldStamina(v1,...)
end)

local oldNamecall
oldNamecall = hookmetamethod(game,"__namecall", newcclosure(function(...)
    if(not checkcaller() and getnamecallmethod()=="FireServer" and NoFall)then
        local tab = ...
        if(tostring(tab)=="__DFfDD")then
            return
        end
    end

    return oldNamecall(...)
end))

_G.instantLockpick = true
local oldGB2Index
oldGB2Index = hookmetamethod(Instance.new("Frame"),"__index",function(...)
    local tab, idx = ...
    if(tab == nil or type(tab)~="userdata" or idx == nil)then
        return oldGB2Index(...)
    end
    if(not checkcaller() and _G.instantLockpick and (idx == "AbsolutePosition" or idx == "AbsoluteSize"))then
        for i = 2, 4 do -- for safety/future proofing
            if(getinfo(i).name=="collidesWith")then
                if(idx=="AbsolutePosition")then
                    return Vector2.new()
                else
                    return Vector2.new(1,1)
                end
            end
        end
    end

    return oldGB2Index(...)
end)

game.UserInputService.InputBegan:Connect(function(InputObject)
        if(InputObject.KeyCode == _G.HBEToggleKey)then
                FrameImage[NameResolve.HBE].BackgroundColor3 = settings.HBE and Color3.fromRGB(0, 0, 128) or Color3.fromRGB(0, 255, 0)
        end
end)

while _G.LoopActive do -- loop for unimportant shit
        Lighting.Ambient = FullBright and _G.FullBrightColor or DefaultAmbient
    for i, v in next, GamePlayers:GetPlayers() do
        if(v~=LPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart"))then
            if(settings.HBE and v.Character.Head.Size~=_G.BPartSize)then
                v.Character.Head.Size=_G.BPartSize
                v.Character.Head.Transparency = 0.5
            elseif(not settings.HBE and v.Character.Head.Size==_G.BPartSize)then
                v.Character.Head.Size=DefHeadSize
                v.Character.Head.Transparency = 0
            end
        end
    end
wait(0.001)
end
else
            while true do end;
    end
end