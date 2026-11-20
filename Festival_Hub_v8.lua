-- Festival Hub | Brookhaven RP
-- v7 | Developer: kutaydox
-- Discord: https://discord.gg/c8FWGnaG92

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- ==================== ASSETS (logo / banner / discord) ====================
local FESTIVAL = {
    Developer = "kutaydox",
    Discord   = "https://discord.gg/c8FWGnaG92",
    Logo      = "https://raw.githubusercontent.com/yigitcanpy/festivalhub/refs/heads/main/pfp.jpg",
    Banner    = "https://raw.githubusercontent.com/yigitcanpy/festivalhub/refs/heads/main/banner.jpg",
}

local function loadRemoteImage(url, fileName)
    local ok, result = pcall(function()
        local getAsset = getcustomasset or getsynasset
        if not (getAsset and writefile) then return nil end
        local data = game:HttpGet(url)
        if not data or #data < 100 then return nil end
        writefile(fileName, data)
        return getAsset(fileName)
    end)
    if ok and result and result ~= "" then return result end
    return nil
end

local LogoAsset   = loadRemoteImage(FESTIVAL.Logo,   "FestivalHub_pfp.jpg")    or "rbxassetid://464093673"
local BannerAsset = loadRemoteImage(FESTIVAL.Banner, "FestivalHub_banner.jpg") or "rbxassetid://1235887402"

-- ==================== STAFF SYSTEM (KEPT) ====================
local Staff = {
    Owner = { ["Kaidor2oo8"] = true, ["kaidor2oo8"] = true, ["kutaydox"] = true, ["Kutaydox"] = true },
    Admin = { ["hiimsamet2"] = true, ["Hiimsamet2"] = true },
    Developer = {},
}

-- Staff by Roblox UserId (role: "Owner" / "Admin" / "Developer")
local StaffIds = {
    [9533118317] = "Owner",
}

local function GetRole(playerName)
    local lower = string.lower(playerName or "")
    local plr = Players:FindFirstChild(playerName or "")
    if plr and StaffIds[plr.UserId] then return StaffIds[plr.UserId] end
    for name in pairs(Staff.Owner) do if string.lower(name) == lower then return "Owner" end end
    for name in pairs(Staff.Admin) do if string.lower(name) == lower then return "Admin" end end
    for name in pairs(Staff.Developer) do if string.lower(name) == lower then return "Developer" end end
    return "User"
end

local function GetRoleDisplay(playerName)
    local role = GetRole(playerName)
    if role == "Owner" then return "Festival Owner"
    elseif role == "Admin" then return "Festival Admin"
    elseif role == "Developer" then return "Festival Developer" end
    return "Festival User"
end

local function IsStaff(playerName)
    return GetRole(playerName) ~= "User"
end

-- ==================== BAN ====================
local BanListURL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/banlist.txt"
local BannedUsers = {}
local function LoadBanList()
    local ok, result = pcall(function() return game:HttpGet(BanListURL) end)
    if ok and result then
        BannedUsers = {}
        for line in result:gmatch("[^\r\n]+") do
            local name = line:match("^%s*(.-)%s*$")
            if name and name ~= "" then BannedUsers[string.lower(name)] = true end
        end
    end
end
local function IsBanned(n) return BannedUsers[string.lower(n or "")] == true end
pcall(LoadBanList)
if IsBanned(LocalPlayer.Name) then LocalPlayer:Kick("You are banned from Festival Hub.") return end

-- ==================== WEBHOOK (KEPT) ====================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1555873586235965540/8byfXFIyNPtonCrVguw8J2qdUL_tMw1aqawxLY0S-yJf6XhA9d38hKireGY_YKH46yaE"

local function SendJoinLog()
    local playerName, userId, displayName = LocalPlayer.Name, LocalPlayer.UserId, LocalPlayer.DisplayName
    local placeId, jobId = game.PlaceId, game.JobId
    local role = GetRoleDisplay(playerName)
    local gameName = "Brookhaven RP"
    pcall(function() gameName = MarketplaceService:GetProductInfo(placeId).Name end)
    local executor = "Unknown"
    pcall(function() if identifyexecutor then executor = identifyexecutor() elseif getexecutorname then executor = getexecutorname() end end)
    local joinLink = string.format("https://www.roblox.com/games/start?placeId=%s&gameInstanceId=%s", tostring(placeId), tostring(jobId))
    local profileLink = "https://www.roblox.com/users/" .. tostring(userId) .. "/profile"
    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(userId) .. "&width=420&height=420&format=png"
    local embed = {
        title = "Festival Hub - Player Joined", color = 15158332, thumbnail = {url = avatarUrl},
        fields = {
            {name = "Player", value = displayName .. " (@" .. playerName .. ")", inline = true},
            {name = "UserId", value = tostring(userId), inline = true},
            {name = "Role", value = role, inline = true},
            {name = "Profile", value = "[Open Profile](" .. profileLink .. ")", inline = true},
            {name = "Executor", value = executor, inline = true},
            {name = "Players", value = tostring(#Players:GetPlayers()), inline = true},
            {name = "Game", value = gameName, inline = false},
            {name = "PlaceId", value = tostring(placeId), inline = true},
            {name = "JobId", value = tostring(jobId), inline = true},
            {name = "Join Server", value = "[Click to Join](" .. joinLink .. ")", inline = false},
        },
        footer = {text = "Festival Hub • " .. os.date("%d/%m/%Y %H:%M:%S")},
    }
    local body = HttpService:JSONEncode({username = "Festival Hub Logs", embeds = {embed}})
    local req = (syn and syn.request) or http_request or request or (fluxus and fluxus.request)
    if req then pcall(function() req({Url = WEBHOOK_URL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = body}) end)
    else pcall(function() HttpService:PostAsync(WEBHOOK_URL, body, Enum.HttpContentType.ApplicationJson) end) end
end
task.spawn(function() task.wait(2) pcall(SendJoinLog) end)

-- ==================== LOADING SCREEN ====================
do
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FestivalLoading"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local root = Instance.new("Frame")
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundColor3 = Color3.fromRGB(8,8,12)
    root.BorderSizePixel = 0
    root.Parent = screenGui

    local banner = Instance.new("ImageLabel")
    banner.Size = UDim2.new(1,0,1,0)
    banner.BackgroundTransparency = 1
    banner.Image = BannerAsset
    banner.ImageTransparency = 0.3
    banner.ScaleType = Enum.ScaleType.Crop
    banner.Parent = root

    local shade = Instance.new("Frame")
    shade.Size = UDim2.new(1,0,1,0)
    shade.BackgroundColor3 = Color3.new(0,0,0)
    shade.BackgroundTransparency = 0.45
    shade.BorderSizePixel = 0
    shade.Parent = root

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5,0.5)
    card.Position = UDim2.new(0.5,0,0.5,0)
    card.Size = UDim2.new(0,380,0,330)
    card.BackgroundColor3 = Color3.fromRGB(14,14,18)
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel = 0
    card.Parent = root
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,18)
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = Color3.fromRGB(220,30,40)
    cardStroke.Thickness = 2

    local logo = Instance.new("ImageLabel")
    logo.AnchorPoint = Vector2.new(0.5,0)
    logo.Position = UDim2.new(0.5,0,0,18)
    logo.Size = UDim2.new(0,92,0,92)
    logo.BackgroundColor3 = Color3.fromRGB(10,10,12)
    logo.Image = LogoAsset
    logo.ScaleType = Enum.ScaleType.Crop
    logo.Parent = card
    Instance.new("UICorner", logo).CornerRadius = UDim.new(1,0)
    local logoStroke = Instance.new("UIStroke", logo)
    logoStroke.Color = Color3.fromRGB(255,45,55)
    logoStroke.Thickness = 3

    local function label(text, y, h, color, font)
        local l = Instance.new("TextLabel")
        l.AnchorPoint = Vector2.new(0.5,0)
        l.Position = UDim2.new(0.5,0,0,y)
        l.Size = UDim2.new(1,-40,0,h)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = color
        l.TextScaled = true
        l.Font = font
        l.Parent = card
        return l
    end

    local titleL  = label("FESTIVAL HUB", 118, 38, Color3.fromRGB(255,45,55), Enum.Font.GothamBlack)
    local subL    = label("Brookhaven RP  |  by "..FESTIVAL.Developer, 160, 20, Color3.fromRGB(220,220,230), Enum.Font.GothamMedium)
    local welcome = label("Welcome, "..LocalPlayer.DisplayName.."  -  "..GetRoleDisplay(LocalPlayer.Name), 186, 20, Color3.fromRGB(255,90,100), Enum.Font.GothamSemibold)

    local barBg = Instance.new("Frame")
    barBg.AnchorPoint = Vector2.new(0.5,0)
    barBg.Position = UDim2.new(0.5,0,0,226)
    barBg.Size = UDim2.new(1,-60,0,10)
    barBg.BackgroundColor3 = Color3.fromRGB(30,30,38)
    barBg.BorderSizePixel = 0
    barBg.Parent = card
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1,0)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0,0,1,0)
    barFill.BackgroundColor3 = Color3.fromRGB(220,30,40)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1,0)

    local status  = label("Starting...", 244, 20, Color3.fromRGB(170,170,190), Enum.Font.Gotham)
    local percent = label("0%", 268, 16, Color3.fromRGB(255,255,255), Enum.Font.GothamBold)
    local invite  = label(FESTIVAL.Discord, 296, 18, Color3.fromRGB(120,140,255), Enum.Font.GothamMedium)

    -- fade in
    card.BackgroundTransparency = 1
    TweenService:Create(card, TweenInfo.new(0.5), {BackgroundTransparency = 0.15}):Play()

    local steps = {
        {0,  "Starting..."},
        {15, "Checking ban list..."},
        {30, "Verifying staff role..."},
        {50, "Loading modules..."},
        {70, "Building UI..."},
        {88, "Applying Festival theme..."},
        {97, "Almost ready..."},
    }
    local si = 1
    for i = 1, 100 do
        TweenService:Create(barFill, TweenInfo.new(0.05), {Size = UDim2.new(i/100,0,1,0)}):Play()
        percent.Text = i.."%"
        if steps[si] and i >= steps[si][1] then status.Text = steps[si][2] si = si + 1 end
        task.wait(0.03)
    end
    status.Text = "Welcome to Festival Hub!"
    task.wait(0.5)

    -- fade out
    for _, o in ipairs(root:GetDescendants()) do
        if o:IsA("TextLabel") then TweenService:Create(o, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        elseif o:IsA("ImageLabel") then TweenService:Create(o, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
        elseif o:IsA("Frame") then TweenService:Create(o, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        elseif o:IsA("UIStroke") then TweenService:Create(o, TweenInfo.new(0.4), {Transparency = 1}):Play() end
    end
    TweenService:Create(root, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    task.wait(0.45)
    screenGui:Destroy()
end

-- ==================== STAFF NAME TAGS ====================
-- Every Festival Hub user sees these tags above staff players' heads.
-- Owner tag is special (rainbow text + logo). Change texts below or live from Staff Panel > Owner Only.
local TagStyles = {
    Owner     = { Text = "Festival Owner",     Color = Color3.fromRGB(255,45,55)  },
    Admin     = { Text = "Festival Admin",     Color = Color3.fromRGB(255,170,0)  },
    Developer = { Text = "Festival Developer", Color = Color3.fromRGB(0,170,255)  },
}
local CustomTagText = {}   -- [lowercase username] = "custom text"   e.g. CustomTagText["kaidor2oo8"] = "kutaydox | Owner"
local ownerLabels = {}

local function removeTag(plr)
    local c = plr.Character
    local head = c and c:FindFirstChild("Head")
    local old = head and head:FindFirstChild("FestivalTag")
    if old then old:Destroy() end
end

local function applyTag(plr)
    pcall(function()
        removeTag(plr)
        local role = GetRole(plr.Name)
        if role == "User" then return end
        local char = plr.Character
        local head = char and char:FindFirstChild("Head")
        if not head then return end
        local style = TagStyles[role]
        local text = CustomTagText[string.lower(plr.Name)] or style.Text

        local gui = Instance.new("BillboardGui")
        gui.Name = "FestivalTag"
        gui.Adornee = head
        gui.Size = UDim2.new(0, 220, 0, 36)
        gui.StudioOffset = Vector3.new(0, 2.4, 0)
        gui.AlwaysOnTop = true
        gui.MaxDistance = 250
        gui.Parent = head

        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1,0,1,0)
        holder.BackgroundColor3 = Color3.fromRGB(10,10,14)
        holder.BackgroundTransparency = 0.25
        holder.BorderSizePixel = 0
        holder.Parent = gui
        Instance.new("UICorner", holder).CornerRadius = UDim.new(0,10)
        local stroke = Instance.new("UIStroke", holder)
        stroke.Color = style.Color
        stroke.Thickness = 1.5

        local textX = 6
        if role == "Owner" then
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0,26,0,26)
            icon.Position = UDim2.new(0,5,0.5,-13)
            icon.BackgroundTransparency = 1
            icon.Image = LogoAsset
            icon.ScaleType = Enum.ScaleType.Crop
            icon.Parent = holder
            Instance.new("UICorner", icon).CornerRadius = UDim.new(1,0)
            textX = 36
        end

        local lbl = Instance.new("TextLabel")
        lbl.Position = UDim2.new(0,textX,0,0)
        lbl.Size = UDim2.new(1,-textX-6,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = style.Color
        lbl.TextScaled = true
        lbl.Font = Enum.Font.GothamBlack
        lbl.Parent = holder
        local tc = Instance.new("UITextSizeConstraint", lbl)
        tc.MaxTextSize = 18

        if role == "Owner" then table.insert(ownerLabels, lbl) end
    end)
end

local function hookTagPlayer(plr)
    plr.CharacterAdded:Connect(function() task.wait(0.6) applyTag(plr) end)
    if plr.Character then task.spawn(function() task.wait(0.3) applyTag(plr) end) end
end
for _, p in ipairs(Players:GetPlayers()) do hookTagPlayer(p) end
Players.PlayerAdded:Connect(hookTagPlayer)

-- rainbow animation for owner tags
task.spawn(function()
    while true do
        local hue = (tick() % 4) / 4
        for i = #ownerLabels, 1, -1 do
            local l = ownerLabels[i]
            if l and l.Parent then l.TextColor3 = Color3.fromHSV(hue, 0.85, 1)
            else table.remove(ownerLabels, i) end
        end
        task.wait(0.05)
    end
end)

-- ==================== RP NAME ====================
local re = ReplicatedStorage:WaitForChild("RE")
local colorRed = Color3.fromRGB(220,30,40)
local colorBlack = Color3.fromRGB(10,10,12)
local roleDisplay = GetRoleDisplay(LocalPlayer.Name)
pcall(function() re:WaitForChild("1RPNam1eColo1r"):FireServer("PickingRPNameColor", colorRed) end)
pcall(function() re:WaitForChild("1RPNam1eTex1t"):FireServer("RolePlayName", roleDisplay) end)
pcall(function() re:WaitForChild("1RPNam1eColo1r"):FireServer("PickingRPBioColor", colorBlack) end)
pcall(function() re:WaitForChild("1RPNam1eTex1t"):FireServer("RolePlayBio", "Thank you for using Festival Hub") end)

-- ==================== UI LIB ====================
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Lindao10/Redzlib-cor-neo/refs/heads/main/RedzHubUI_NeoBlack_COMPLETO_EDITADO.lua"))()
local window = library:MakeWindow({
    Title = "Festival Hub | Brookhaven RP",
    SubTitle = "by " .. FESTIVAL.Developer,
    SaveFolder = "FestivalConfig"
})
window:AddMinimizeButton({
    Button = { Image = LogoAsset, BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(180,25,35) },
    Corner = { CornerRadius = UDim.new(0,12) },
})

-- ==================== HELPERS ====================
local camera = Workspace.CurrentCamera
local function getHRP(plr)
    plr = plr or LocalPlayer
    local c = plr.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum(plr)
    plr = plr or LocalPlayer
    local c = plr.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function fireRE(name, ...)
    pcall(function()
        local r = re:FindFirstChild(name)
        if r then
            if r:IsA("RemoteEvent") then r:FireServer(...)
            elseif r:IsA("RemoteFunction") then r:InvokeServer(...) end
        end
    end)
end
local function giveTool(toolName)
    pcall(function() re:WaitForChild("1Too1l"):InvokeServer("PickingTools", toolName) end)
end
local function notify(title, text, dur)
    pcall(function() StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=dur or 4}) end)
end

-- ==================== INFO ====================
local tabInfo = window:MakeTab({"Info", LogoAsset})
tabInfo:AddDiscordInvite({ Name="Festival Hub | Community", Description="Updates, support & more", Logo=LogoAsset, Invite=FESTIVAL.Discord })
tabInfo:AddParagraph({"Festival Hub V7", "Brookhaven RP script hub."})
tabInfo:AddParagraph({"Developer", FESTIVAL.Developer})
tabInfo:AddParagraph({"Your Role", roleDisplay})
tabInfo:AddParagraph({"Version", "V7"})
tabInfo:AddButton({Name="Copy Discord Invite", Callback=function()
    if setclipboard then setclipboard(FESTIVAL.Discord) end
    notify("Festival Hub", "Discord invite copied!", 4)
end})

-- ==================== LOCAL PLAYER ====================
local tabLocal = window:MakeTab({"Local Player", "user"})
tabLocal:AddSection({Name="Movement"})
tabLocal:AddTextBox({Name="WalkSpeed", PlaceholderText="50", Callback=function(v) local n=tonumber(v) if n and getHum() then getHum().WalkSpeed=n end end})
tabLocal:AddButton({Name="Reset Speed 16", Callback=function() if getHum() then getHum().WalkSpeed=16 end end})
tabLocal:AddTextBox({Name="JumpPower", PlaceholderText="100", Callback=function(v) local n=tonumber(v) if n and getHum() then getHum().UseJumpPower=true getHum().JumpPower=n end end})
tabLocal:AddButton({Name="Reset Jump 50", Callback=function() if getHum() then getHum().JumpPower=50 end end})
tabLocal:AddTextBox({Name="Gravity", PlaceholderText="80", Callback=function(v) local n=tonumber(v) if n then Workspace.Gravity=n end end})
tabLocal:AddButton({Name="Reset Gravity", Callback=function() Workspace.Gravity=196.2 end})
tabLocal:AddButton({Name="Reset All Movement", Callback=function()
    if getHum() then getHum().WalkSpeed=16 getHum().JumpPower=50 getHum().UseJumpPower=true end
    Workspace.Gravity=196.2
end})

local noclipOn = false
tabLocal:AddToggle({Name="Noclip", Default=false, Callback=function(s)
    noclipOn=s
    if s then task.spawn(function()
        while noclipOn do
            local c=LocalPlayer.Character
            if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
            task.wait()
        end
    end) end
end})

tabLocal:AddSection({Name="Anti Systems"})
local antiSitTool, antiSitVeh, antiSitAll, antiFling, antiLag = false,false,false,false,false
tabLocal:AddToggle({Name="Anti Sit Tool", Default=false, Callback=function(s)
    antiSitTool=s
    if s then task.spawn(function() while antiSitTool do local h=getHum() if h and h.Sit then h.Sit=false h:ChangeState(Enum.HumanoidStateType.GettingUp) end task.wait(0.1) end end) end
end})
tabLocal:AddToggle({Name="Anti Sit Vehicle", Default=false, Callback=function(s)
    antiSitVeh=s
    if s then task.spawn(function()
        while antiSitVeh do local h=getHum() if h then h:SetStateEnabled(Enum.HumanoidStateType.Seated,false) if h.Sit then h.Sit=false end end task.wait(0.12) end
        local h=getHum() if h then h:SetStateEnabled(Enum.HumanoidStateType.Seated,true) end
    end) end
end})
tabLocal:AddToggle({Name="Anti Sit Total", Default=false, Callback=function(s)
    antiSitAll=s
    if s then task.spawn(function()
        while antiSitAll do local h=getHum() if h then h:SetStateEnabled(Enum.HumanoidStateType.Seated,false) h.Sit=false end task.wait(0.08) end
        local h=getHum() if h then h:SetStateEnabled(Enum.HumanoidStateType.Seated,true) end
    end) end
end})
tabLocal:AddToggle({Name="Anti Fling", Default=false, Callback=function(s)
    antiFling=s
    if s then task.spawn(function()
        while antiFling do
            local c=LocalPlayer.Character
            if c then for _,p in pairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.Velocity=Vector3.zero p.RotVelocity=Vector3.zero
                    if p:FindFirstChild("BodyVelocity") then p.BodyVelocity:Destroy() end
                    if p:FindFirstChild("BodyAngularVelocity") then p.BodyAngularVelocity:Destroy() end
                end
            end end
            task.wait(0.08)
        end
    end) end
end})
tabLocal:AddToggle({Name="Anti Lag", Default=false, Callback=function(s)
    antiLag=s
    if s then task.spawn(function() while antiLag do pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end) task.wait(1) end end) end
end})

tabLocal:AddSection({Name="Chat Spam"})
local chatMsg=""
local function SendChat(msg)
    if not msg or msg=="" then return end
    pcall(function()
        local tcs=game:GetService("TextChatService")
        if tcs.ChatVersion==Enum.ChatVersion.LegacyChatService then
            ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents").SayMessageRequest:FireServer(msg,"All")
        else
            local ch=tcs.ChatInputBarConfiguration and tcs.ChatInputBarConfiguration.TargetTextChannel
            if ch then ch:SendAsync(msg) end
        end
    end)
end
tabLocal:AddTextBox({Name="Chat Message", PlaceholderText="...", Callback=function(t) chatMsg=t end})
tabLocal:AddButton({Name="Send Chat", Callback=function() SendChat(chatMsg) end})
getgenv().FestivalSendDelay=1
tabLocal:AddSlider({Name="Spam Delay", Min=0.4, Max=10, Default=1, Increment=0.1, Callback=function(v) getgenv().FestivalSendDelay=v end})
tabLocal:AddToggle({Name="Spam Chat", Default=false, Callback=function(s)
    getgenv().FestivalSpamChat=s
    while getgenv().FestivalSpamChat do SendChat(chatMsg) task.wait(getgenv().FestivalSendDelay) end
end})

-- ==================== TROLL PLAYERS (FULL) ====================
local tabTroll = window:MakeTab({"Troll Players", "rbxassetid://12921294273"})
local playerList, selectedPlayer = {}, nil
for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(playerList,p.Name) end end
Players.PlayerAdded:Connect(function(p) if p~=LocalPlayer then table.insert(playerList,p.Name) pcall(function() if PlayerDD then PlayerDD:SetOptions(playerList) end end) end end)
Players.PlayerRemoving:Connect(function(p)
    for i,n in ipairs(playerList) do if n==p.Name then table.remove(playerList,i) break end end
    pcall(function() if PlayerDD then PlayerDD:SetOptions(playerList) end end)
end)

local PlayerDD = tabTroll:AddDropdown({Name="Select Player", Options=playerList, Callback=function(v) selectedPlayer=v end})
tabTroll:AddButton({Name="Refresh Players", Callback=function()
    playerList={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(playerList,p.Name) end end
    pcall(function() PlayerDD:SetOptions(playerList) end)
end})

local viewing=false
tabTroll:AddToggle({Name="View Player", Callback=function(s)
    viewing=s
    if s and selectedPlayer then
        task.spawn(function()
            while viewing do
                local t=Players:FindFirstChild(selectedPlayer)
                if not t or not t.Character or not getHum(t) then break end
                camera.CameraSubject=getHum(t)
                task.wait()
            end
        end)
    else
        if getHum() then camera.CameraSubject=getHum() end
    end
end})
tabTroll:AddButton({Name="Teleport to Player", Callback=function()
    if not selectedPlayer then return end
    local t=Players:FindFirstChild(selectedPlayer)
    if t and getHRP(t) and getHRP() then getHRP().CFrame=getHRP(t).CFrame+Vector3.new(0,3,0) end
end})
tabTroll:AddButton({Name="Bring Player", Callback=function()
    if not selectedPlayer then return end
    local t=Players:FindFirstChild(selectedPlayer)
    if t and getHRP(t) and getHRP() then getHRP(t).CFrame=getHRP().CFrame+Vector3.new(0,0,-4) end
end})

-- ESP
local espOn=false
local espConns={}
local function dist(char)
    if char and getHRP(LocalPlayer) and char:FindFirstChild("HumanoidRootPart") then
        return math.floor((char.HumanoidRootPart.Position-getHRP().Position).Magnitude)
    end
    return 0
end
local function makeESP(plr)
    if plr==LocalPlayer then return end
    local function onChar(char)
        if not char:FindFirstChild("Head") then char:WaitForChild("Head") end
        if char:FindFirstChild("ESP_HL") then return end
        local hl=Instance.new("Highlight")
        hl.Name="ESP_HL"
        hl.FillColor=Color3.fromRGB(220,40,50)
        hl.FillTransparency=0.55
        hl.Parent=char
        local bb=Instance.new("BillboardGui")
        bb.Name="ESP_INFO"
        bb.Size=UDim2.new(0,170,0,34)
        bb.StudsOffset=Vector3.new(0,3.3,0)
        bb.Adornee=char.Head
        bb.AlwaysOnTop=true
        bb.Parent=char
        local lb=Instance.new("TextLabel")
        lb.Size=UDim2.new(1,0,1,0)
        lb.BackgroundTransparency=1
        lb.TextColor3=Color3.new(1,1,1)
        lb.TextScaled=true
        lb.Font=Enum.Font.GothamMedium
        lb.Parent=bb
        local last=0
        RunService.Heartbeat:Connect(function()
            if espOn and tick()-last>0.7 then
                local h=char:FindFirstChildOfClass("Humanoid")
                if h then lb.Text=string.format("%s | HP:%d | %dm", plr.Name, math.floor(h.Health), dist(char)) end
                last=tick()
            end
        end)
    end
    if plr.Character then onChar(plr.Character) end
    plr.CharacterAdded:Connect(function(c) if espOn then onChar(c) end end)
end
local function clearESP(plr)
    if plr.Character then
        if plr.Character:FindFirstChild("ESP_HL") then plr.Character.ESP_HL:Destroy() end
        if plr.Character:FindFirstChild("ESP_INFO") then plr.Character.ESP_INFO:Destroy() end
    end
end
tabTroll:AddToggle({Name="ESP Players", Default=false, Callback=function(s)
    espOn=s
    if s then
        for _,p in pairs(Players:GetPlayers()) do makeESP(p) end
        espConns.pa=Players.PlayerAdded:Connect(function(p) if espOn then makeESP(p) end end)
    else
        for _,p in pairs(Players:GetPlayers()) do clearESP(p) end
        if espConns.pa then espConns.pa:Disconnect() end
    end
end})

tabTroll:AddSection({Name="Fling / Kill"})
local function doFling(target, duration)
    duration = duration or 3
    if not target or not target.Character or not getHRP(target) or not getHRP() then return end
    local myHRP, hum = getHRP(), getHum()
    local tHRP = getHRP(target)
    local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if tool then tool.Parent=LocalPlayer.Character end
    Workspace.FallenPartsDestroyHeight = 0/0
    local bv=Instance.new("BodyVelocity")
    bv.Name="FlingForce"
    bv.Velocity=Vector3.new(9e9,9e9,9e9)
    bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
    bv.Parent=myHRP
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
    camera.CameraSubject=tHRP
    local angle, endT = 0, tick()+duration
    while tick()<endT do
        if not target.Character or not getHum(target) then break end
        angle=angle+50
        myHRP.CFrame=tHRP.CFrame*CFrame.new(0,1.5,0)*CFrame.Angles(math.rad(angle),0,0)
        myHRP.Velocity=Vector3.new(9e9,9e9,9e9)
        myHRP.RotVelocity=Vector3.new(9e9,9e9,9e9)
        task.wait()
    end
    bv:Destroy()
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
    camera.CameraSubject=hum
    for _,p in pairs(LocalPlayer.Character:GetDescendants()) do
        if p:IsA("BasePart") then p.Velocity=Vector3.zero p.RotVelocity=Vector3.zero end
    end
end

local flingToggle=false
tabTroll:AddToggle({Name="Fling Couch", Default=false, Callback=function(s)
    flingToggle=s
    if s and selectedPlayer then
        local t=Players:FindFirstChild(selectedPlayer)
        if t then task.spawn(function() doFling(t, 999) end) end
    end
end})
tabTroll:AddButton({Name="Give Couch", Callback=function() giveTool("Couch") end})
tabTroll:AddButton({Name="Fling Selected (3s)", Callback=function()
    if not selectedPlayer then return end
    local t=Players:FindFirstChild(selectedPlayer)
    if t then task.spawn(function() doFling(t,3) end) end
end})
tabTroll:AddButton({Name="Fling All", Callback=function()
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer then task.spawn(function() doFling(p,2.5) end) task.wait(0.4) end
    end
end})
tabTroll:AddButton({Name="Auto Fling Selected 5s", Callback=function()
    if not selectedPlayer then return end
    local t=Players:FindFirstChild(selectedPlayer)
    if t then task.spawn(function() doFling(t,5) end) end
end})
tabTroll:AddButton({Name="Fling Ball", Callback=function()
    if not selectedPlayer then return end
    local t=Players:FindFirstChild(selectedPlayer)
    if not t or not getHRP(t) then return end
    pcall(function()
        local ball=Workspace:FindFirstChild("SoccerBall") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("SoccerBall"))
        if ball and ball:FindFirstChild("FootballInteraction") then
            ball.FootballInteraction:FireServer(CFrame.new(1,1,1))
        end
        doFling(t,2)
    end)
end})
tabTroll:AddButton({Name="House Ban Kill", Callback=function()
    if not selectedPlayer then return end
    local t=Players:FindFirstChild(selectedPlayer)
    if t then
        pcall(function()
            re:FindFirstChild("1Playe1rTrigge1rEven1t"):FireServer("BanPlayerFromHouse", t, t.Character)
        end)
        task.wait(0.3)
        doFling(t,2)
    end
end})
tabTroll:AddButton({Name="Bring All Cars", Callback=function()
    for _,v in next, Workspace.Vehicles:GetChildren() do
        if v.PrimaryPart and getHRP() then pcall(function() v:SetPrimaryPartCFrame(LocalPlayer.Character:GetPrimaryPartCFrame()) end) end
    end
end})

tabTroll:AddSection({Name="Sign Troll"})
local signTarget, signText = nil, ""
local function playersWithSign()
    local list={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer then
            local has=(p.Backpack and p.Backpack:FindFirstChild("Sign")) or (p.Character and p.Character:FindFirstChild("Sign"))
            if has then table.insert(list,p.Name) end
        end
    end
    return list
end
local SignDD=tabTroll:AddDropdown({Name="Player with Sign", Options=playersWithSign(), Callback=function(v) signTarget=v end})
tabTroll:AddButton({Name="Refresh Sign List", Callback=function() pcall(function() SignDD:SetOptions(playersWithSign()) end) end})
tabTroll:AddTextBox({Name="Sign Text", PlaceholderText="...", Callback=function(t) signText=t end})
tabTroll:AddButton({Name="Edit Sign", Callback=function()
    if not signTarget or signText=="" then return end
    local t=Players:FindFirstChild(signTarget)
    if not t or not t.Character then return end
    local sign=t.Character:FindFirstChild("Sign")
    if not sign then notify("Festival","No Sign equipped",3) return end
    local ts=sign:FindFirstChild("ToolSound")
    if ts then pcall(function() ts:FireServer("Sign","SignWords",signText) end) end
end})

tabTroll:AddSection({Name="Click Tools"})
tabTroll:AddButton({Name="Click Fling Couch Tool", Callback=function()
    local bp=LocalPlayer:FindFirstChild("Backpack")
    if not bp then return end
    if bp:FindFirstChild("Click Fling Couch") then return end
    local tool=Instance.new("Tool")
    tool.Name="Click Fling Couch"
    tool.RequiresHandle=false
    tool.CanBeDropped=false
    tool.Parent=bp
    tool.Activated:Connect(function()
        local mouse=LocalPlayer:GetMouse()
        local target=mouse.Target
        if target then
            local model=target:FindFirstAncestorOfClass("Model")
            local plr=Players:GetPlayerFromCharacter(model)
            if plr then task.spawn(function() doFling(plr,3) end) end
        end
    end)
    notify("Festival","Click Fling Couch tool given",3)
end})
tabTroll:AddButton({Name="Click Kill Couch Tool", Callback=function()
    local bp=LocalPlayer:FindFirstChild("Backpack")
    if not bp or bp:FindFirstChild("Click Kill Couch") then return end
    local tool=Instance.new("Tool")
    tool.Name="Click Kill Couch"
    tool.RequiresHandle=false
    tool.CanBeDropped=false
    tool.Parent=bp
    tool.Activated:Connect(function()
        local mouse=LocalPlayer:GetMouse()
        local target=mouse.Target
        if target then
            local model=target:FindFirstAncestorOfClass("Model")
            local plr=Players:GetPlayerFromCharacter(model)
            if plr then
                pcall(function() re:FindFirstChild("1Playe1rTrigge1rEven1t"):FireServer("BanPlayerFromHouse", plr, plr.Character) end)
                task.spawn(function() doFling(plr,2) end)
            end
        end
    end)
    notify("Festival","Click Kill Couch tool given",3)
end})

-- ==================== AVATAR / EXTRA TROLL ====================
local tabAvatar = window:MakeTab({"Avatar Troll", "fun"})

tabAvatar:AddSection({Name = "Copy Avatar"})

local copyTarget = nil
local function getAllPlayerNames()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(t, p.Name)
    end
    return t
end

local CopyDD = tabAvatar:AddDropdown({
    Name = "Select Player to Copy",
    Options = getAllPlayerNames(),
    Callback = function(v) copyTarget = v end
})

tabAvatar:AddButton({
    Name = "Refresh Player List",
    Callback = function()
        pcall(function() CopyDD:SetOptions(getAllPlayerNames()) end)
    end
})

tabAvatar:AddButton({
    Name = "Copy Avatar",
    Description = "Copy selected player's appearance (FE)",
    Callback = function()
        if not copyTarget then
            notify("Festival", "Select a player first", 3)
            return
        end
        local target = Players:FindFirstChild(copyTarget)
        if not target or not target.Character then
            notify("Festival", "Target not found / no character", 3)
            return
        end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        local targetHum = target.Character:FindFirstChildOfClass("Humanoid")
        if not myHum or not targetHum then return end

        local desc
        local ok, err = pcall(function()
            desc = targetHum:GetAppliedDescription()
        end)
        if not ok or not desc then
            notify("Festival", "Could not read avatar description", 3)
            return
        end

        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then
            notify("Festival", "Remotes not found", 3)
            return
        end

        -- Body parts
        pcall(function()
            remotes:WaitForChild("ChangeCharacterBody"):InvokeServer({
                {
                    desc.Torso or 0,
                    desc.RightArm or 0,
                    desc.LeftArm or 0,
                    desc.RightLeg or 0,
                    desc.LeftLeg or 0,
                    desc.Head or 0,
                }
            })
        end)
        task.wait(0.3)

        -- Wear assets
        local wear = remotes:FindFirstChild("Wear")
        if wear then
            local function tryWear(id)
                if id and tonumber(id) and tonumber(id) > 0 then
                    pcall(function() wear:InvokeServer(tonumber(id)) end)
                    task.wait(0.15)
                end
            end
            tryWear(desc.Shirt)
            tryWear(desc.Pants)
            tryWear(desc.Face)
            tryWear(desc.GraphicTShirt)

            -- Accessories from description strings
            local accFields = {
                desc.HatAccessory, desc.HairAccessory, desc.FaceAccessory,
                desc.NeckAccessory, desc.ShouldersAccessory, desc.FrontAccessory,
                desc.BackAccessory, desc.WaistAccessory
            }
            for _, field in ipairs(accFields) do
                if type(field) == "string" then
                    for id in string.gmatch(field, "%d+") do
                        tryWear(id)
                    end
                end
            end
        end

        notify("Festival", "Avatar copied from " .. copyTarget, 4)
        print("[Festival] Copied avatar from " .. copyTarget)
    end
})

tabAvatar:AddSection({Name="Invisible"})
tabAvatar:AddButton({Name="Go Invisible FE", Callback=function()
    pcall(function()
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ChangeCharacterBody"):InvokeServer({{102344834840950,70400527171038,0,0,0,0}})
    end)
    pcall(function()
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Wear"):InvokeServer(111858803548720)
    end)
    notify("Festival","Invisible applied",3)
end})

tabAvatar:AddSection({Name="Hair RGB"})
local hairRGB=false
local hairCols={Color3.new(1,1,0),Color3.new(0,0,1),Color3.new(1,0,1),Color3.new(1,1,1),Color3.new(0,1,0),Color3.new(0.5,0,1),Color3.new(1,0.647,0),Color3.new(0,1,1)}
tabAvatar:AddToggle({Name="Hair RGB", Default=false, Callback=function(s)
    hairRGB=s
    if s then task.spawn(function()
        local i=1
        while hairRGB do
            pcall(function() re:WaitForChild("1Max1y"):FireServer("ChangeHairColor2", hairCols[i]) end)
            i=i%#hairCols+1
            task.wait(0.12)
        end
    end) end
end})

tabAvatar:AddSection({Name="Avatar RGB"})
local avatarRGB=false
tabAvatar:AddToggle({Name="Avatar RGB (Highlight)", Default=false, Callback=function(s)
    avatarRGB=s
    if s then task.spawn(function()
        while avatarRGB do
            local col=Color3.fromHSV(math.random(),1,1)
            local c=LocalPlayer.Character
            if c then
                local hl=c:FindFirstChild("FestivalRGB")
                if not hl then hl=Instance.new("Highlight") hl.Name="FestivalRGB" hl.FillTransparency=0.3 hl.Parent=c end
                hl.FillColor=col hl.OutlineColor=col
            end
            task.wait(0.12)
        end
        local c=LocalPlayer.Character
        if c and c:FindFirstChild("FestivalRGB") then c.FestivalRGB:Destroy() end
    end) end
end})

tabAvatar:AddSection({Name="Character RGB via Remote"})
local bodyRGB=false
tabAvatar:AddToggle({Name="Body Color RGB", Default=false, Callback=function(s)
    bodyRGB=s
    if s then task.spawn(function()
        while bodyRGB do
            local col=Color3.fromHSV(tick()%1,1,1)
            pcall(function()
                -- try common remotes
                fireRE("1Max1y", "ChangeHairColor2", col)
            end)
            task.wait(0.15)
        end
    end) end
end})

-- ==================== AVATAR EXTRAS (ported from Brookhaven script) ====================
do
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")

    tabAvatar:AddSection({Name="Fire Player"})
    local fireTypes = {
        Black  = {"18637072603","035FireBlack"},  Purple = {"18637070174","034FirePurple"},
        Blue   = {"18637076370","033FireBlue"},   Green  = {"18637078598","032FireGreen"},
        Orange = {"18637025451","031FireOrange"}, White  = {"18637074370","030FireWhite"},
    }
    local fireSel = "Black"
    tabAvatar:AddDropdown({Name="Fire Color", Options={"Black","Purple","Blue","Green","Orange","White"}, Default="Black", Callback=function(v) fireSel=v end})
    tabAvatar:AddButton({Name="Fire Player", Callback=function()
        local f = fireTypes[fireSel]
        if f then pcall(function() Remotes:WaitForChild("ApplyEmmiter"):InvokeServer(f[1], f[2]) end) end
    end})

    tabAvatar:AddSection({Name="Smoke Player"})
    local smokeTypes = {
        Black  = {"18637798529","087SmokeBlack"},  Purple = {"18637813360","085SmokePurple"},
        Blue   = {"18637803021","084SmokeBlue"},   Green  = {"18637789299","083SmokeGreen"},
        Orange = {"18637793920","082SmokeOrange"}, White  = {"18637791748","080SmokeWhite"},
        Yellow = {"18637800482","081SmokeYellow"}, Red    = {"18637796598","086SmokeRed"},
    }
    local smokeSel = "Black"
    tabAvatar:AddDropdown({Name="Smoke Color", Options={"Black","Purple","Blue","Green","Orange","White","Yellow","Red"}, Default="Black", Callback=function(v) smokeSel=v end})
    tabAvatar:AddButton({Name="Smoke Player", Callback=function()
        local f = smokeTypes[smokeSel]
        if f then pcall(function() Remotes:WaitForChild("ApplyEmmiter"):InvokeServer(f[1], f[2]) end) end
    end})

    tabAvatar:AddSection({Name="Reset Avatar"})
    tabAvatar:AddButton({Name="Reset Avatar", Callback=function()
        pcall(function() Remotes:WaitForChild("ResetCharacterAppearance"):FireServer() end)
    end})

    tabAvatar:AddSection({Name="Body Parts"})
    local body = {Torso=0, RightArm=0, LeftArm=0, RightLeg=0, LeftLeg=0, Head=0}
    local bodyOrder = {"Torso","RightArm","LeftArm","RightLeg","LeftLeg","Head"}
    local bodySel = "Head"
    for _, pair in ipairs({{"Torso","Torso"},{"Right Arm","RightArm"},{"Left Arm","LeftArm"},{"Right Leg","RightLeg"},{"Left Leg","LeftLeg"},{"Head","Head"}}) do
        tabAvatar:AddTextBox({Name=pair[1], PlaceholderText="ID", Callback=function(v) body[pair[2]] = tonumber(v) or 0 end})
    end
    tabAvatar:AddDropdown({Name="Part List", Options=bodyOrder, Default="Head", Callback=function(v) bodySel=v end})
    tabAvatar:AddButton({Name="Load Selected Part", Callback=function()
        local args = {}
        for i, n in ipairs(bodyOrder) do args[i] = (n == bodySel) and body[n] or 0 end
        pcall(function() Remotes:WaitForChild("ChangeCharacterBody"):InvokeServer(args) end)
    end})
    tabAvatar:AddButton({Name="Load All Parts", Callback=function()
        local args = {}
        for i, n in ipairs(bodyOrder) do args[i] = body[n] end
        pcall(function() Remotes:WaitForChild("ChangeCharacterBody"):InvokeServer(args) end)
    end})
end

-- ==================== STAFF PANEL (ADVANCED) ====================
if IsStaff(LocalPlayer.Name) then
    local tabStaff = window:MakeTab({"Staff Panel", "rbxassetid://6034287594"})
    tabStaff:AddParagraph({"STAFF PANEL", "Advanced tools for Festival staff."})
    tabStaff:AddParagraph({"Role", GetRoleDisplay(LocalPlayer.Name)})
    tabStaff:AddParagraph({"Account", LocalPlayer.Name.." | "..tostring(LocalPlayer.UserId)})
    tabStaff:AddParagraph({"Online", tostring(#Players:GetPlayers()).." players"})

    tabStaff:AddSection({Name="Global Broadcast"})
    local staffMsg=""
    tabStaff:AddTextBox({Name="Message", PlaceholderText="Special message...", Callback=function(t) staffMsg=t end})
    tabStaff:AddButton({Name="Send Staff Broadcast", Callback=function()
        if staffMsg=="" then return end
        local msg="[FESTIVAL STAFF] "..LocalPlayer.Name.." ("..GetRoleDisplay(LocalPlayer.Name).."): "..staffMsg
        notify("Festival Staff", msg, 12)
        pcall(function()
            local old=roleDisplay
            re:WaitForChild("1RPNam1eTex1t"):FireServer("RolePlayName", msg)
            task.wait(6)
            re:WaitForChild("1RPNam1eTex1t"):FireServer("RolePlayName", old)
        end)
        pcall(function() SendChat(msg) end)
        print("[Staff]: "..msg)
    end})
    tabStaff:AddButton({Name="Announce My Role", Callback=function()
        notify("Festival", LocalPlayer.Name.." is "..GetRoleDisplay(LocalPlayer.Name), 6)
    end})

    tabStaff:AddSection({Name="Player Management"})
    local staffTarget=""
    tabStaff:AddTextBox({Name="Target Username", PlaceholderText="username", Callback=function(t) staffTarget=t end})
    tabStaff:AddButton({Name="Kick", Callback=function()
        if staffTarget=="" then return end
        local t=Players:FindFirstChild(staffTarget)
        if t then pcall(function() t:Kick("Kicked by Festival Staff ("..LocalPlayer.Name..")") end)
        else notify("Festival","Player not found",3) end
    end})
    tabStaff:AddButton({Name="Teleport to Target", Callback=function()
        local t=Players:FindFirstChild(staffTarget)
        if t and getHRP(t) and getHRP() then getHRP().CFrame=getHRP(t).CFrame+Vector3.new(0,3,0) end
    end})
    tabStaff:AddButton({Name="Bring Target", Callback=function()
        local t=Players:FindFirstChild(staffTarget)
        if t and getHRP(t) and getHRP() then getHRP(t).CFrame=getHRP().CFrame+Vector3.new(0,0,-5) end
    end})
    tabStaff:AddButton({Name="View Target", Callback=function()
        local t=Players:FindFirstChild(staffTarget)
        if t and getHum(t) then camera.CameraSubject=getHum(t) end
    end})
    tabStaff:AddButton({Name="Reset Camera", Callback=function() if getHum() then camera.CameraSubject=getHum() end end})
    tabStaff:AddButton({Name="Fling Target", Callback=function()
        local t=Players:FindFirstChild(staffTarget)
        if t then task.spawn(function() doFling(t,3) end) end
    end})

    tabStaff:AddSection({Name="Server Tools"})
    tabStaff:AddButton({Name="List All Players + Roles", Callback=function()
        local lines={}
        for _,p in ipairs(Players:GetPlayers()) do table.insert(lines, p.Name.." | "..GetRoleDisplay(p.Name)) end
        print(table.concat(lines,"\n"))
        notify("Players", tostring(#Players:GetPlayers()).." online", 4)
    end})
    tabStaff:AddButton({Name="Copy Join Link", Callback=function()
        local link=string.format("https://www.roblox.com/games/start?placeId=%s&gameInstanceId=%s", tostring(game.PlaceId), tostring(game.JobId))
        if setclipboard then setclipboard(link) end
        notify("Festival","Join link copied",3)
    end})
    tabStaff:AddButton({Name="Re-apply Role Name", Callback=function()
        local r=GetRoleDisplay(LocalPlayer.Name)
        pcall(function()
            re:WaitForChild("1RPNam1eTex1t"):FireServer("RolePlayName", r)
            re:WaitForChild("1RPNam1eColo1r"):FireServer("PickingRPNameColor", colorRed)
        end)
    end})

    tabStaff:AddSection({Name="Ban System"})
    tabStaff:AddButton({Name="Refresh Ban List", Callback=function()
        LoadBanList()
        local c=0 for _ in pairs(BannedUsers) do c=c+1 end
        notify("Ban List", c.." entries", 4)
    end})
    tabStaff:AddButton({Name="Check Target Banned", Callback=function()
        if staffTarget=="" then return end
        notify("Ban Check", staffTarget.." = "..(IsBanned(staffTarget) and "BANNED" or "OK"), 4)
    end})

    tabStaff:AddSection({Name="Festival Info"})
    tabStaff:AddButton({Name="Copy Discord Invite", Callback=function()
        if setclipboard then setclipboard(FESTIVAL.Discord) end
        notify("Festival Staff","Discord invite copied",3)
    end})
    tabStaff:AddButton({Name="Copy Job ID", Callback=function()
        if setclipboard then setclipboard(tostring(game.JobId)) end
        notify("Festival Staff","Job ID copied",3)
    end})
    tabStaff:AddButton({Name="Rejoin Server", Callback=function()
        pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
    end})
    tabStaff:AddButton({Name="Server Hop", Callback=function()
        pcall(function()
            local data=HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
            for _,sv in ipairs(data.data) do
                if sv.id~=game.JobId and sv.playing<sv.maxPlayers then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, sv.id, LocalPlayer) break
                end
            end
        end)
    end})
    tabStaff:AddButton({Name="Show Staff In Server", Callback=function()
        local found={}
        for _,p in ipairs(Players:GetPlayers()) do if IsStaff(p.Name) then table.insert(found,p.Name.." ("..GetRoleDisplay(p.Name)..")") end end
        notify("Staff Online", #found>0 and table.concat(found,", ") or "No staff in this server", 6)
    end})

    if GetRole(LocalPlayer.Name)=="Owner" then
        tabStaff:AddSection({Name="Owner Only"})
        tabStaff:AddTextBox({Name="My Tag Text", PlaceholderText="e.g. kutaydox | Owner", Callback=function(t)
            if t == "" then return end
            CustomTagText[string.lower(LocalPlayer.Name)] = t
            applyTag(LocalPlayer)
            pcall(function() re:WaitForChild("1RPNam1eTex1t"):FireServer("RolePlayName", t) end)
            notify("Festival Hub", "Tag updated: "..t, 4)
        end})
        tabStaff:AddButton({Name="Reset My Tag", Callback=function()
            CustomTagText[string.lower(LocalPlayer.Name)] = nil
            applyTag(LocalPlayer)
            pcall(function() re:WaitForChild("1RPNam1eTex1t"):FireServer("RolePlayName", GetRoleDisplay(LocalPlayer.Name)) end)
        end})
        tabStaff:AddButton({Name="Refresh All Tags", Callback=function()
            for _, p in ipairs(Players:GetPlayers()) do applyTag(p) end
        end})
        tabStaff:AddButton({Name="Force Webhook Log", Callback=function() pcall(SendJoinLog) notify("Owner","Webhook sent",3) end})
        tabStaff:AddButton({Name="Print Staff Table", Callback=function()
            print("=== OWNERS ===") for n in pairs(Staff.Owner) do print(n) end
            print("=== ADMINS ===") for n in pairs(Staff.Admin) do print(n) end
        end})
    end
end

-- ==================== HOUSES ====================
local tabHouses = window:MakeTab({"Houses", "home"})
local selectedHouse=nil
local function getHouses()
    local list={}
    local lots=Workspace:FindFirstChild("001_Lots")
    if lots then for _,v in ipairs(lots:GetChildren()) do if v.Name~="For Sale" and v:IsA("Model") then table.insert(list,v.Name) end end end
    return list
end
tabHouses:AddDropdown({Name="Select House", Options=getHouses(), Callback=function(v) selectedHouse=v end})
tabHouses:AddButton({Name="Refresh Houses", Callback=function() notify("Houses", tostring(#getHouses()).." found", 3) end})
tabHouses:AddButton({Name="TP to House", Callback=function()
    if not selectedHouse then return end
    local h=Workspace["001_Lots"]:FindFirstChild(tostring(selectedHouse))
    if h and getHRP() then getHRP().CFrame=CFrame.new(h.WorldPivot.Position) end
end})
tabHouses:AddButton({Name="TP to Safe", Callback=function()
    if not selectedHouse then return end
    local h=Workspace["001_Lots"]:FindFirstChild(tostring(selectedHouse))
    if h and h:FindFirstChild("HousePickedByPlayer") then
        local safe=h.HousePickedByPlayer.HouseModel:FindFirstChild("001_Safe")
        if safe and getHRP() then getHRP().CFrame=CFrame.new(safe.WorldPivot.Position) end
    end
end})
tabHouses:AddButton({Name="Unban All Houses", Callback=function()
    local removed=0
    for i=1,40 do
        local b=Workspace:FindFirstChild("BannedBlock"..i, true)
        if b and pcall(function() b:Destroy() end) then removed=removed+1 end
    end
    for _,d in pairs(Workspace:GetDescendants()) do
        if d.Name:match("BannedBlock") and pcall(function() d:Destroy() end) then removed=removed+1 end
    end
    notify("Festival", "Removed "..removed.." house bans", 4)
end})
local houseRGB=false
local hCols={Color3.new(1,0,0),Color3.new(0,1,0),Color3.new(0,0,1),Color3.new(1,1,0),Color3.new(0,1,1),Color3.new(1,0,1)}
tabHouses:AddToggle({Name="House RGB", Default=false, Callback=function(s)
    houseRGB=s
    if s then task.spawn(function()
        local remote=re:FindFirstChild("1Player1sHous1e")
        if not remote then return end
        while houseRGB do for _,c in ipairs(hCols) do if not houseRGB then break end pcall(function() remote:FireServer("ColorPickHouse",c) end) task.wait(0.7) end end
    end) end
end})

-- ==================== CAR ====================
local tabCar = window:MakeTab({"Car", "car"})
tabCar:AddButton({Name="Bring All Cars", Callback=function()
    for _,v in next, Workspace.Vehicles:GetChildren() do
        if v.PrimaryPart and getHRP() then pcall(function() v:SetPrimaryPartCFrame(LocalPlayer.Character:GetPrimaryPartCFrame()) end) end
    end
end})
tabCar:AddSection({Name="Music"})
local musicIDs={"71373562243752","138129019858244","138480372357526","122199933878670","74187181906707","82793916573031","107421761958790","91394092603440","113198957973421","81452315991527","93786060174790","74752089069476","131592235762789","132081774507495","124394293950763","83381647646350","16190782181","1841682637","3148329638","124928367733395"}
local function setMusic(id)
    if not id or id=="" then return end
    pcall(function() re:FindFirstChild("1Player1sCa1r"):FireServer("PickingCarMusicText", id) end)
    pcall(function() re:WaitForChild("1NoMoto1rVehicle1s"):FireServer("PickingScooterMusicText", id) end)
    pcall(function() re:WaitForChild("1Player1sHous1e"):FireServer("PickHouseMusicText", id) end)
end
tabCar:AddTextBox({Name="Music ID", PlaceholderText="ID", Callback=function(id) setMusic(id) end})
tabCar:AddDropdown({Name="Select Music", Options=musicIDs, Callback=function(id) setMusic(id) end})
local carRGB=false
local cCols={Color3.new(1,0,0),Color3.new(0,1,0),Color3.new(0,0,1),Color3.new(1,1,0),Color3.new(1,0,1),Color3.new(0,1,1)}
tabCar:AddToggle({Name="Car RGB", Default=false, Callback=function(s)
    carRGB=s
    if s then task.spawn(function()
        local remote=re:WaitForChild("1Player1sCa1r")
        while carRGB do for _,c in ipairs(cCols) do if not carRGB then break end remote:FireServer("PickingCarColor",c) task.wait(0.9) end end
    end) end
end})
tabCar:AddSection({Name="RGB Tools"})
local function fireToolCol(col)
    pcall(function()
        local gui=LocalPlayer:FindFirstChild("PlayerGui")
        if not gui then return end
        local tg=gui:FindFirstChild("ToolGui")
        if not tg then return end
        local ts=tg:FindFirstChild("ToolSettings")
        if not ts then return end
        local props=ts:FindFirstChild("Settings") and ts.Settings:FindFirstChild("PropsColor")
        if props and props:FindFirstChild("SetColor") then props.SetColor:FireServer(col) end
    end)
end
local function rndCol() return Color3.fromHSV(math.random(),1,1) end
for _,name in ipairs({"RGB Radio","RGB Megaphone","RGB Donut"}) do
    local flag=false
    tabCar:AddToggle({Name=name, Default=false, Callback=function(s)
        flag=s
        if s then task.spawn(function() while flag do fireToolCol(rndCol()) task.wait(0.08) end end) end
    end})
end

-- ==================== TELEPORTS ====================
local tabTP = window:MakeTab({"Teleports", "tp"})
local tps={
    {"Backstage",CFrame.new(192,4,272)},{"City Center",CFrame.new(136,4,117)},{"Crime Area",CFrame.new(-119,-28,235)},
    {"Abandoned House",CFrame.new(986,4,63)},{"Agency Portal",CFrame.new(672,4,-296)},{"Hideout",CFrame.new(505,-75,143)},
    {"School",CFrame.new(-312,4,211)},{"Brook Cafe",CFrame.new(161,8,52)},{"Spawn",CFrame.new(-26,4,-23)},
    {"Main Arch",CFrame.new(-589,141,-59)},{"Hospital",CFrame.new(-309,4,71)},{"Agency Base",CFrame.new(179,4,-464)},
    {"Secret Workshop",CFrame.new(0,4,-495)},{"Secret Room 2",CFrame.new(-343,4,-613)},{"Isolated Island",CFrame.new(-1925,23,127)},
    {"Hotel Plaza",CFrame.new(182,4,150)},{"Mountain 1",CFrame.new(-670,251,765)},{"Main Bank",CFrame.new(2.28,4.65,254.58)},
    {"Clothing Store",CFrame.new(-46.15,4.65,253.2)},{"Refuge",CFrame.new(-88.48,22.05,262.34)},{"Dental Clinic",CFrame.new(-53.58,22.15,265.61)},
    {"Cafe",CFrame.new(-97.12,4.65,254.99)},
}
local tpNames={} for _,l in ipairs(tps) do table.insert(tpNames,l[1]) end
tabTP:AddDropdown({Name="Location", Options=tpNames, Callback=function(name)
    for _,l in ipairs(tps) do if l[1]==name and getHRP() then getHRP().CFrame=l[2] break end end
end})

-- ==================== ITEMS ====================
local tabItems = window:MakeTab({"Items", "rbxassetid://11345510758"})
for _,n in ipairs({"BankGateKey","DuffleBagDiamonds","AgencyBook","KeyCardDarkGreen","Crystal","SwordGold","OldKey","Couch"}) do
    tabItems:AddButton({Name=n, Callback=function() giveTool(n) end})
end

-- ==================== HEAD SIT ====================
local tabHS = window:MakeTab({"Head Sit", "rbxassetid://14096597501"})
local hsTarget, hsConn = nil, nil
local function allNames() local t={} for _,p in pairs(Players:GetPlayers()) do table.insert(t,p.Name) end return t end
local hsDD=tabHS:AddDropdown({Name="Select Player", Options=allNames(), Callback=function(v) hsTarget=v end})
tabHS:AddToggle({Name="Head Sit", Default=false, Callback=function(s)
    local char=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp=char:WaitForChild("HumanoidRootPart")
    local hum=char:WaitForChild("Humanoid")
    if not hsTarget or hsTarget=="" then return end
    local target=Players:FindFirstChild(hsTarget)
    if s then
        if target and target.Character then
            hum.Sit=true
            if hsConn then hsConn:Disconnect() end
            hsConn=RunService.Heartbeat:Connect(function()
                if target.Character and target.Character:FindFirstChild("Head") and hum.Sit then
                    hrp.CFrame=target.Character.Head.CFrame*CFrame.new(0,1.6,0.4)
                elseif hsConn then hsConn:Disconnect() hsConn=nil hum.Sit=false end
            end)
        end
    else
        if hsConn then hsConn:Disconnect() hsConn=nil end
        hum.Sit=false
    end
end})
tabHS:AddButton({Name="Refresh", Callback=function() pcall(function() hsDD:Refresh(allNames()) end) end})


-- ==================== UI BACKGROUND + OPEN BUTTON ====================
task.spawn(function()
    task.wait(1)
    local function containers()
        local list = {}
        pcall(function() if gethui then table.insert(list, gethui()) end end)
        pcall(function() table.insert(list, game:GetService("CoreGui")) end)
        table.insert(list, LocalPlayer:WaitForChild("PlayerGui"))
        return list
    end

    -- find the library's main ScreenGui (the one that owns the window)
    local libGui
    for _, c in ipairs(containers()) do
        for _, g in ipairs(c:GetChildren()) do
            if g:IsA("ScreenGui") and g.Name ~= "FestivalOpenButton" then
                for _, d in ipairs(g:GetDescendants()) do
                    if d:IsA("TextLabel") and d.Text == "Festival Hub | Brookhaven RP" then libGui = g break end
                end
            end
            if libGui then break end
        end
        if libGui then break end
    end

    -- background: put the banner behind the biggest frame of the window
    if libGui then
        local biggest, area = nil, 0
        for _, d in ipairs(libGui:GetDescendants()) do
            if d:IsA("Frame") and d.AbsoluteSize.X > 250 and d.AbsoluteSize.Y > 200 then
                local a = d.AbsoluteSize.X * d.AbsoluteSize.Y
                if a > area then biggest, area = d, a end
            end
        end
        if biggest then
            biggest.ClipsDescendants = true
            local img = Instance.new("ImageLabel")
            img.Name = "FestivalBanner"
            img.Size = UDim2.new(1, 0, 1, 0)
            img.BackgroundTransparency = 1
            img.Image = BannerAsset
            img.ImageTransparency = 0.55
            img.ScaleType = Enum.ScaleType.Crop
            img.ZIndex = 0
            img.Parent = biggest
            local corner = biggest:FindFirstChildOfClass("UICorner")
            if corner then Instance.new("UICorner", img).CornerRadius = corner.CornerRadius end
        end
    end

    -- open / close button with the Festival logo
    local btnGui = Instance.new("ScreenGui")
    btnGui.Name = "FestivalOpenButton"
    btnGui.ResetOnSpawn = false
    pcall(function() if gethui then btnGui.Parent = gethui() else btnGui.Parent = game:GetService("CoreGui") end end)
    if not btnGui.Parent then btnGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 54, 0, 54)
    btn.Position = UDim2.new(0, 14, 0.5, -27)
    btn.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    btn.Image = LogoAsset
    btn.ScaleType = Enum.ScaleType.Crop
    btn.Active = true
    btn.Draggable = true
    btn.Parent = btnGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(220, 30, 40)
    stroke.Thickness = 2

    local visible = true
    local dragMoved, startPos = false, nil
    btn.MouseButton1Down:Connect(function() startPos = btn.AbsolutePosition end)
    btn.MouseButton1Click:Connect(function()
        if startPos and (btn.AbsolutePosition - startPos).Magnitude > 6 then return end
        visible = not visible
        if libGui then libGui.Enabled = visible end
    end)
end)

-- ==================== AUDIO ====================
local tabAudio = window:MakeTab({"Audio", "radio"})
tabAudio:AddSection({Name="Play by ID (local)"})
local audioId, localSound = "", nil
tabAudio:AddTextBox({Name="Audio ID", PlaceholderText="Enter audio ID", Callback=function(t) audioId=t:gsub("%D","") end})
tabAudio:AddButton({Name="Play", Callback=function()
    if audioId=="" then return end
    if localSound then pcall(function() localSound:Destroy() end) end
    localSound=Instance.new("Sound")
    localSound.SoundId="rbxassetid://"..audioId
    localSound.Volume=1
    localSound.Parent=Workspace
    localSound:Play()
end})
tabAudio:AddButton({Name="Stop", Callback=function() if localSound then pcall(function() localSound:Stop() localSound:Destroy() end) localSound=nil end end})
tabAudio:AddSection({Name="Car / House / Scooter music"})
tabAudio:AddTextBox({Name="Music ID", PlaceholderText="Enter ID", Callback=function(t) pcall(function() setMusic(t) end) end})

-- ==================== CAR EXTRAS ====================
tabCar:AddSection({Name="Speed / Turbo / Drift"})
local carSpeed, carTurbo = 50, 50
tabCar:AddTextBox({Name="Speed", PlaceholderText="50", Callback=function(v) carSpeed=tonumber(v) or carSpeed end})
tabCar:AddTextBox({Name="Turbo", PlaceholderText="50", Callback=function(v) carTurbo=tonumber(v) or carTurbo end})
tabCar:AddTextBox({Name="Drift", PlaceholderText="50", Callback=function(v) fireRE("1Player1sCa1r","DriftingNumber",v) end})
tabCar:AddButton({Name="Apply Speed & Turbo", Callback=function()
    local veh=Workspace:FindFirstChild("Vehicles") and Workspace.Vehicles:FindFirstChild(LocalPlayer.Name.."Car")
    if not veh then notify("Festival Hub","Spawn a car first!",4) return end
    local seat=veh:FindFirstChild("Body") and veh.Body:FindFirstChild("VehicleSeat")
    if not seat then notify("Festival Hub","Sit in the car first!",4) return end
    pcall(function() seat.TopSpeed.Value=carSpeed seat.Turbo.Value=carTurbo end)
    notify("Festival Hub","Speed & turbo applied!",4)
end})
tabCar:AddSection({Name="Spam Horn"})
local hornOn=false
tabCar:AddToggle({Name="Spam Horn", Default=false, Callback=function(s)
    hornOn=s
    if s then task.spawn(function() while hornOn do fireRE("1Player1sCa1r","Horn") task.wait(0.1) end end) end
end})


-- ==================== PORTED FROM BROOKHAVEN SCRIPT: NAMES / RGB / CAR EXTRAS ====================
do
    -- ---------- NAMES ----------
    local tabNames = window:MakeTab({"Names", "paper"})
    tabNames:AddSection({Name="Set RP Name"})
    for _, n in ipairs({"Anonymus","PRO","ERROR 666","DARKNESSS","GHOST","JOKER","ADMIN","TUBERS93","COOLKID","GAME ATTACKED BY MAFIA","INCOMUN","BAD BOY"}) do
        tabNames:AddButton({Name="Name: "..n, Callback=function() fireRE("1RPNam1eTex1t","RolePlayName",n) end})
    end

    -- ---------- RGB ----------
    local tabRGB = window:MakeTab({"RGB", "brush"})
    local rgbSpeed = 3
    tabRGB:AddSlider({Name="RGB Speed", Min=1, Max=5, Default=3, Increment=1, Callback=function(v) rgbSpeed=v end})
    local function rgbColor() return Color3.fromHSV((tick()*rgbSpeed % 5)/5, 1, 1) end
    local function loopToggle(tab, name, delay, fn)
        local on = false
        tab:AddToggle({Name=name, Default=false, Callback=function(s)
            on = s
            if s then task.spawn(function()
                while on do pcall(fn, rgbColor()) task.wait(delay) end
            end) end
        end})
    end

    tabRGB:AddSection({Name="On you"})
    loopToggle(tabRGB, "Name + Bio RGB", 0.03, function(c)
        fireRE("1RPNam1eColo1r","PickingRPNameColor",c)
        fireRE("1RPNam1eColo1r","PickingRPBioColor",c)
    end)
    loopToggle(tabRGB, "Body RGB", 0.1, function(c)
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("ChangeBodyColor") then r.ChangeBodyColor:FireServer({BrickColor.new(c)}) end
    end)

    tabRGB:AddSection({Name="Vehicles & house"})
    loopToggle(tabRGB, "House RGB", 0.1, function(c) fireRE("1Player1sHous1e","ColorPickHouse",c) end)
    loopToggle(tabRGB, "Car RGB (Premium)", 0.03, function(c) fireRE("1Player1sCa1r","PickingCarColor",c) end)
    loopToggle(tabRGB, "Bike RGB", 0.1, function(c) fireRE("1Player1sCa1r","NoMotorColor",c) end)

    tabRGB:AddSection({Name="Items / tools"})
    loopToggle(tabRGB, "Radio RGB", 0.03, function(c)
        local gui = LocalPlayer.PlayerGui:FindFirstChild("ToolGui")
        local ts = gui and gui:FindFirstChild("ToolSettings")
        local setting = ts and ts:FindFirstChild("Settings")
        local remote = setting and setting:FindFirstChild("SetColor")
        if remote then remote:FireServer(c) end
    end)
    loopToggle(tabRGB, "Megaphone RGB", 0.1, function(c)
        local gui = LocalPlayer.PlayerGui:FindFirstChild("ToolGui")
        local ts = gui and gui:FindFirstChild("ToolSettings")
        local pc = ts and ts:FindFirstChild("Settings") and ts.Settings:FindFirstChild("PropsColor")
        if pc and pc:FindFirstChild("SetColor") then pc.SetColor:FireServer(c) end
    end)

    -- ---------- CAR EXTRAS ----------
    tabCar:AddSection({Name="Car RGB (cycle)"})
    local carCycle = false
    local cycleCols = {Color3.new(1,0,0),Color3.new(1,0.5,0),Color3.new(1,1,0),Color3.new(0,1,0),Color3.new(0,1,1),Color3.new(0,0,1),Color3.new(1,0,1)}
    tabCar:AddToggle({Name="Car RGB (cycle)", Default=false, Callback=function(s)
        carCycle = s
        if s then task.spawn(function()
            while carCycle do
                for _, c in ipairs(cycleCols) do
                    if not carCycle then break end
                    fireRE("1Player1sCa1r","PickingCarColor",c) task.wait(1)
                end
            end
        end) end
    end})
    tabCar:AddSection({Name="Spam Cars"})
    local carList = {"SchoolBus","SmartCar","FarmTruck","Cadillac","Excavator","Jeep","NascarTruck","TowTruck","Snowplow","MilitaryTruck","Tank","Limo","FireTruck"}
    local spamCars = false
    tabCar:AddToggle({Name="Spam Cars", Default=false, Callback=function(s)
        spamCars = s
        if s then task.spawn(function()
            while spamCars do
                for _, c in ipairs(carList) do
                    if not spamCars then break end
                    fireRE("1Ca1r","PickingCar",c) task.wait(0.4)
                end
            end
        end) end
    end})
end


-- ==================== BROOKHAVEN MODULES (isolated: an error in one module cannot break the hub) ====================
do
    getgenv().FestivalCtx = { window = window, library = library }
    local PROLOGUE = [=====[
local ctx = getgenv().FestivalCtx
local window, redzHubUi = ctx.window, ctx.library
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local v1 = workspace
local httpService = game:GetService("HttpService")
local marketplaceService = game:GetService("MarketplaceService")
local runService = game:GetService("RunService")
local virtualInputManager = game:GetService("VirtualInputManager")
local userInputService = game:GetService("UserInputService")
local starterGui = game:GetService("StarterGui")
local localPlayer = players.LocalPlayer
localPlayer3, localPlayer4, localPlayer8, localPlayer9, localPlayer10 = localPlayer, localPlayer, localPlayer, localPlayer, localPlayer
]=====]
    local Modules = {
        { "Pull Parts", [=====[
local scriptsTrollsTab = window:MakeTab({ Title = "Pull Parts", Icon = "rbxassetid://13364900349" })
scriptsTrollsTab:AddSection({ "Pull Parts" })

scriptsTrollsTab:AddButton({
Name = "Pull Parts",
Description = "To use: get close to the selected player",
Callback = function()
local gui = Instance.new("ScreenGui")
local main = Instance.new("Frame")
local box = Instance.new("TextBox")
local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
local label = Instance.new("TextLabel")
local uiTextSizeConstraint2 = Instance.new("UITextSizeConstraint")
local button = Instance.new("TextButton")
local uiTextSizeConstraint3 = Instance.new("UITextSizeConstraint")

gui.Name = "Gui"
gui.Parent = gethui()
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

main.Name = "Main"
main.Parent = gui
main.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
main.BorderColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 0

main.Position = UDim2.new(
0.335954279, 0, 0.542361975, 0
)

main.Size = UDim2.new(0.240350261, 0, 0.166880623, 0)
main.Active = true
main.Draggable = true

box.Name = "Box"
box.Parent = main
box.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
box.BorderColor3 = Color3.fromRGB(0, 0, 0)
box.BorderSizePixel = 0

box.Position = UDim2.new(
0.0980926454, 0, 0.218712583, 0
)

box.Size = UDim2.new(0.801089942, 0, 0.364963502, 0)

box.FontFace = Font.new(
"rbxasset://fonts/families/SourceSansSemibold.json",
Enum.FontWeight.Bold, Enum.FontStyle.Normal
)

box.PlaceholderText = "Player here"
box.Text = ""
box.TextColor3 = Color3.fromRGB(255, 255, 255)
box.TextScaled = true
box.TextSize = 31
box.TextWrapped = true

uiTextSizeConstraint.Parent = box
uiTextSizeConstraint.MaxTextSize = 31

label.Name = "Label"
label.Parent = main
label.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
label.BorderColor3 = Color3.fromRGB(0, 0, 0)
label.BorderSizePixel = 0
label.Size = UDim2.new(1, 0, 0.160583943, 0)

label.FontFace = Font.new(
"rbxasset://fonts/families/Nunito.json",
Enum.FontWeight.Bold, Enum.FontStyle.Normal
)

label.Text = "Bring Parts | Made by: Lusquinha_067"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.TextSize = 14
label.TextWrapped = true

uiTextSizeConstraint2.Parent = label
uiTextSizeConstraint2.MaxTextSize = 21

button.Name = "Button"
button.Parent = main
button.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
button.BorderColor3 = Color3.fromRGB(0, 0, 0)
button.BorderSizePixel = 0

button.Position = UDim2.new(
0.183284417, 0, 0.656760991, 0
)

button.Size = UDim2.new(0.629427791, 0, 0.277372271, 0)
button.Font = Enum.Font.Nunito
button.Text = "Bring | Off"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.TextSize = 28
button.TextWrapped = true

uiTextSizeConstraint3.Parent = button
uiTextSizeConstraint3.MaxTextSize = 28

local localPlayer17 = players.LocalPlayer
mainStatus = true

userInputService.InputBegan:Connect(function(input, p24)
if input.KeyCode == Enum.KeyCode.RightControl
and not p24 then
mainStatus = not mainStatus
main.Visible = mainStatus
end
end)

local instance8 = Instance.new("Folder", v1)
local instance9 = Instance.new("Part", instance8)
local instance10 = Instance.new("Attachment", instance9)

instance9.Anchored = true
instance9.CanCollide = false
instance9.Transparency = 1

if not getgenv().Network then
getgenv().Network = {
BaseParts = {},
Velocity = Vector3.new(
14.46262424, 14.46262424, 14.46262424
),
}

function Network.RetainPart(p25)
if p25:IsA("BasePart") and p25:IsDescendantOf(v1) then
table.insert(Network.BaseParts, p25)

p25.CustomPhysicalProperties = PhysicalProperties.new(
0, 0, 0, 0, 0
)

p25.CanCollide = false
end
end

local function f52()
localPlayer17.ReplicationFocus = v1

runService.Heartbeat:Connect(function()
sethiddenproperty(
localPlayer17, "SimulationRadius", math.huge
)

for key9, value45 in pairs(Network.BaseParts) do
if value45:IsDescendantOf(v1) then
value45.Velocity = Network.Velocity
end
end
end)
end

f52()
end

local function f53(p26)
if p26:IsA("BasePart") and not p26.Anchored
and not p26.Parent:FindFirstChildOfClass("Humanoid")
and not p26.Parent:FindFirstChild("Head")
and p26.Name ~= "Handle" then
for index21, value46 in ipairs(p26:GetChildren()) do
if value46:IsA("BodyMover")
or value46:IsA("RocketPropulsion") then
value46:Destroy()
end
end

if p26:FindFirstChild("Attachment") then
p26:FindFirstChild("Attachment"):Destroy()
end

if p26:FindFirstChild("AlignPosition") then
p26:FindFirstChild("AlignPosition"):Destroy()
end

if p26:FindFirstChild("Torque") then
p26:FindFirstChild("Torque"):Destroy()
end

p26.CanCollide = false

local instance11 = Instance.new("Torque", p26)

instance11.Torque = Vector3.new(
100000, 100000, 100000
)

local instance12 = Instance.new(
"AlignPosition", p26
)

local instance13 = Instance.new("Attachment", p26)
instance11.Attachment0 = instance13

instance12.MaxForce = math.huge
instance12.MaxVelocity = math.huge
instance12.Responsiveness = 200
instance12.Attachment0 = instance13
instance12.Attachment1 = instance10
end
end

local v118 = false
local humanoidRootPart4, connect2

local function f54()
v118 = not v118

if v118 then
button.Text = "Bring Parts | On"

for index22, value47 in ipairs(v1:GetDescendants()) do
f53(value47)
end

connect2 = v1.DescendantAdded:Connect(function(descendant2)
if v118 then
f53(descendant2)
end
end)

spawn(function()
while v118 and runService.RenderStepped:Wait() do
instance10.WorldCFrame = humanoidRootPart4.CFrame
end
end)
else
button.Text = "Bring Parts | Off"

if connect2 then
connect2:Disconnect()
end
end
end

local function f55(p27)
local v119 = string.lower(p27)

for key10, value48 in pairs(players:GetPlayers()) do
local v120 = string.lower(value48.Name)

if string.find(v120, v119) then
return value48
elseif string.find(
string.lower(value48.DisplayName), v119
) then
return value48
end
end
end

local v121

coroutine.wrap(function()
Instance.new("Script", box).Parent.FocusLost:Connect(function(p28)
if p28 then
v121 = f55(box.Text)

if v121 then
box.Text = v121.Name
print("Player found:", v121.Name)
else
print("Player not found")
end
end
end)
end)()

coroutine.wrap(function()
Instance.new("Script", button).Parent.MouseButton1Click:Connect(function()
if v121 then
humanoidRootPart4 = (v121.Character
or v121.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")

f54()
else
print("Player is not selected")
end
end)
end)()
end,
})

scriptsTrollsTab:AddSection({ "Invisible" })
]=====] },
        { "Troll Players", [=====[
local trollPlayersTab = window:MakeTab({
Title = "Troll Players",
Icon = "rbxassetid://131153193945220",
})

localPlayer6 = players.LocalPlayer
currentCamera = workspace.CurrentCamera
v43 = nil
v44 = nil
getgenv().Target = nil
character = localPlayer6.Character
humanoid = character and character:WaitForChild("Humanoid")

if character then
character:WaitForChild("HumanoidRootPart")
end

function f32()
local character5 = localPlayer6.Character

if character5 then
local chaosCouch = character5:FindFirstChild("Chaos.Couch")
or localPlayer6.Backpack:FindFirstChild("Chaos.Couch")

if chaosCouch then
chaosCouch:Destroy()
end
end

replicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
end

localPlayer6.CharacterAdded:Connect(function(character6)
character = character6
humanoid = character6:WaitForChild("Humanoid")
character6:WaitForChild("HumanoidRootPart")
f32()
humanoid.Died:Connect(function() f32() end)
end)

if humanoid then
humanoid.Died:Connect(function() f32() end)
end

function f11()
if not v43 then
warn("Erro: No player selected")
return
end

local findFirstChild6 = players:FindFirstChild(v43)

if not findFirstChild6 or not findFirstChild6.Character then
warn("Error: target player not found or has no character")
return
end

local character7 = localPlayer6.Character

local humanoid3, humanoidRootPart5, position,
bringPosition

if not character7 then
warn("Error: local character not found")
return
else
humanoid3 = character7:FindFirstChildOfClass("Humanoid")
humanoidRootPart5 = character7:FindFirstChild("HumanoidRootPart")

local humanoidRootPart6 = findFirstChild6.Character
and findFirstChild6.Character:FindFirstChild("HumanoidRootPart")

if not humanoid3 or not humanoidRootPart5
or not humanoidRootPart6 then
warn("Error: required components not found")
return
else
position = humanoidRootPart5.Position
replicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
task.wait(0.2)

replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(
"PickingTools", "Couch"
)

task.wait(0.3)
local couch = localPlayer6.Backpack:FindFirstChild("Couch")

if couch then
couch.Parent = character7
end

task.wait(0.1)

virtualInputManager:SendKeyEvent(
true, Enum.KeyCode.F, false, game
)

task.wait(0.1)

humanoid3:SetStateEnabled(
Enum.HumanoidStateType.Seated, false
)

humanoid3.PlatformStand = false

currentCamera.CameraSubject = findFirstChild6.Character:FindFirstChild("Head")
or humanoidRootPart6 or humanoid3

bringPosition = Instance.new("BodyPosition")
bringPosition.Name = "BringPosition"

bringPosition.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

bringPosition.D = 10
bringPosition.P = 30000
bringPosition.Position = humanoidRootPart5.Position
bringPosition.Parent = humanoidRootPart6

task.spawn(function()
local total = 0
local v125 = tick()

while tick() - v125 < 5 and findFirstChild6
and findFirstChild6.Character
and findFirstChild6.Character:FindFirstChildOfClass("Humanoid") do
local humanoid4 = findFirstChild6.Character:FindFirstChildOfClass("Humanoid")

if not humanoid4 or humanoid4.Sit then
break
else
local humanoidRootPart7 = findFirstChild6.Character.HumanoidRootPart
total = total + 50

humanoidRootPart5.CFrame = CFrame.new(humanoidRootPart7.Position + humanoidRootPart7.Velocity / 1.5 + Vector3.new(
0, 2, 0
)) * CFrame.Angles(
math.rad(total), 0, 0
)

bringPosition.Position = humanoidRootPart5.Position
+ Vector3.new(2, 0, 0)

task.wait()
end
end

bringPosition:Destroy()

humanoid3:SetStateEnabled(
Enum.HumanoidStateType.Seated, true
)

humanoid3.PlatformStand = false

currentCamera.CameraSubject = humanoid3

for key11, value54 in pairs(character7:GetDescendants()) do
if value54:IsA("BasePart") then
value54.Velocity = Vector3.zero
value54.RotVelocity = Vector3.zero
end
end

task.wait(0.1)

humanoidRootPart5.Anchored = true
humanoidRootPart5.CFrame = CFrame.new(position)

task.wait(0.001)
humanoidRootPart5.Anchored = false
task.wait(0.7)
local couch2 = character7:FindFirstChild("Couch")

if couch2 then
couch2.Parent = localPlayer6.Backpack
end

task.wait(0.001)

replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(
"PickingTools", "Couch"
)
end)

return
end
end
end

function f13()
if not v43 then
warn("Erro: No player selected")
return
end

local findFirstChild7 = players:FindFirstChild(v43)

if not findFirstChild7 or not findFirstChild7.Character then
warn("Error: target player not found or has no character")
return
end

local character8 = localPlayer6.Character

local humanoid5, humanoidRootPart8, position2, vector3,
bringPosition2

if not character8 then
warn("Error: local character not found")
return
else
humanoid5 = character8:FindFirstChildOfClass("Humanoid")
humanoidRootPart8 = character8:FindFirstChild("HumanoidRootPart")

local humanoidRootPart9 = findFirstChild7.Character
and findFirstChild7.Character:FindFirstChild("HumanoidRootPart")

if not humanoid5 or not humanoidRootPart8
or not humanoidRootPart9 then
warn("Error: required components not found")
return
else
position2 = humanoidRootPart8.Position
vector3 = Vector3.new(145.51, -350.09, 21.58)
replicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
task.wait(0.2)

replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(
"PickingTools", "Couch"
)

task.wait(0.3)
local couch3 = localPlayer6.Backpack:FindFirstChild("Couch")

if couch3 then
couch3.Parent = character8
end

task.wait(0.1)

virtualInputManager:SendKeyEvent(
true, Enum.KeyCode.F, false, game
)

task.wait(0.1)

humanoid5:SetStateEnabled(
Enum.HumanoidStateType.Seated, false
)

humanoid5.PlatformStand = false

currentCamera.CameraSubject = findFirstChild7.Character:FindFirstChild("Head")
or humanoidRootPart9 or humanoid5

bringPosition2 = Instance.new("BodyPosition")
bringPosition2.Name = "BringPosition"

bringPosition2.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

bringPosition2.D = 10
bringPosition2.P = 30000
bringPosition2.Position = humanoidRootPart8.Position
bringPosition2.Parent = humanoidRootPart9

task.spawn(function()
local total2 = 0
local v126 = tick()

while tick() - v126 < 5 and findFirstChild7
and findFirstChild7.Character
and findFirstChild7.Character:FindFirstChildOfClass("Humanoid") do
local humanoid6 = findFirstChild7.Character:FindFirstChildOfClass("Humanoid")

if not humanoid6 or humanoid6.Sit then
break
else
local humanoidRootPart10 = findFirstChild7.Character.HumanoidRootPart
total2 = total2 + 50

humanoidRootPart8.CFrame = CFrame.new(humanoidRootPart10.Position + humanoidRootPart10.Velocity / 1.5 + Vector3.new(
0, 2, 0
)) * CFrame.Angles(
math.rad(total2), 0, 0
)

bringPosition2.Position = humanoidRootPart8.Position
+ Vector3.new(2, 0, 0)

task.wait()
end
end

bringPosition2:Destroy()

humanoid5:SetStateEnabled(
Enum.HumanoidStateType.Seated, true
)

humanoid5.PlatformStand = false

currentCamera.CameraSubject = humanoid5

for key12, value55 in pairs(character8:GetDescendants()) do
if value55:IsA("BasePart") then
value55.Velocity = Vector3.zero
value55.RotVelocity = Vector3.zero
end
end

task.wait(0.1)
humanoidRootPart8.CFrame = CFrame.new(vector3)
task.wait(0.3)
local couch4 = character8:FindFirstChild("Couch")

if couch4 then
couch4.Parent = localPlayer6.Backpack
end

task.wait(0.01)

replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(
"PickingTools", "Couch"
)

task.wait(0.2)
humanoidRootPart8.CFrame = CFrame.new(position2)
end)

return
end
end
end

function f12()
local findFirstChild8 = players:FindFirstChild(getgenv().Target)

if not findFirstChild8 then
warn("Error: no target player selected")
return
end

local humanoid7

if not findFirstChild8.Character
or not findFirstChild8.Character:FindFirstChild("HumanoidRootPart") then
warn("Error: target has no character or HumanoidRootPart")
return
else
replicatedStorage.RE["1Clea1rTool1s"]:FireServer(unpack({
[1] = "ClearAllTools",
}))

replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(unpack({
[1] = "PickingTools",
[2] = "Couch",
}))

local chaosCouch2 = localPlayer6.Backpack:WaitForChild(
"Couch", 2
)

if not chaosCouch2 then
warn("Error: couch not found in Backpack")
return
else
chaosCouch2.Name = "Chaos.Couch"
local seat1 = chaosCouch2:FindFirstChild("Seat1")
local seat2 = chaosCouch2:FindFirstChild("Seat2")
local handle2 = chaosCouch2:FindFirstChild("Handle")

if seat1 and seat2 and handle2 then
seat1.Disabled = true
seat2.Disabled = true
handle2.Name = "Handle "
chaosCouch2.Parent = localPlayer6.Character

local mOVOOEPFFGEREVEWVW = Instance.new(
"BodyVelocity", seat1
)

mOVOOEPFFGEREVEWVW.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

mOVOOEPFFGEREVEWVW.P = 1250
mOVOOEPFFGEREVEWVW.Velocity = Vector3.new(0, 0, 0)
mOVOOEPFFGEREVEWVW.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"

repeat
local count2 = 0

while true do
count2 = 1 + count2

if not (count2 <= 35) then
break
end

local v127 = { x = 0, y = 0, z = 0 }

local humanoidRootPart11 = findFirstChild8.Character
and findFirstChild8.Character.HumanoidRootPart

if not humanoidRootPart11 then
break
end

v127.x = humanoidRootPart11.Position.X
+ humanoidRootPart11.Velocity.X / 2

v127.y = humanoidRootPart11.Position.Y
+ humanoidRootPart11.Velocity.Y / 2

v127.z = humanoidRootPart11.Position.Z
+ humanoidRootPart11.Velocity.Z / 2

seat1.CFrame = CFrame.new(Vector3.new(
v127.x, v127.y, v127.z
)) * CFrame.new(-2, 2, 0)

task.wait()
end

mOVOOEPFFGEREVEWVW:Destroy()
chaosCouch2.Parent = localPlayer6.Backpack
task.wait()
chaosCouch2:FindFirstChild("Handle ").Name = "Handle"
task.wait(0.2)
chaosCouch2.Parent = localPlayer6.Character
task.wait()

chaosCouch2.Parent = localPlayer6.Backpack
chaosCouch2.Handle.Name = "Handle "

task.wait(0.2)
chaosCouch2.Parent = localPlayer6.Character

mOVOOEPFFGEREVEWVW = Instance.new(
"BodyVelocity", seat1
)

mOVOOEPFFGEREVEWVW.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

mOVOOEPFFGEREVEWVW.P = 1250
mOVOOEPFFGEREVEWVW.Velocity = Vector3.new(0, 0, 0)
mOVOOEPFFGEREVEWVW.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"

local character9 = findFirstChild8.Character

humanoid7 = character9

humanoid7 = character9
and findFirstChild8.Character.Humanoid
and findFirstChild8.Character.Humanoid.Sit
== true
until humanoid7

task.wait()
chaosCouch2.Parent = localPlayer6.Backpack

seat1.CFrame = CFrame.new(Vector3.new(
9999, -450, 9999
))

seat2.CFrame = CFrame.new(Vector3.new(
9999, -450, 9999
))

chaosCouch2.Parent = localPlayer6.Character
task.wait(0.1)
chaosCouch2.Parent = localPlayer6.Backpack
task.wait(2)
local mOVOOEPFFGEREVEWVW2 = seat1:FindFirstChild("#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W")

if mOVOOEPFFGEREVEWVW2 then
mOVOOEPFFGEREVEWVW2:Destroy()
end

replicatedStorage.RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
return
end

warn("Error: couch components not found")
return
end
end
end

function f33()
local findFirstChild9 = players:FindFirstChild(getgenv().Target)

if not findFirstChild9 then
warn("Error: no target player selected")
return
end

local humanoid8

if not findFirstChild9.Character
or not findFirstChild9.Character:FindFirstChild("HumanoidRootPart") then
warn("Error: target has no character or HumanoidRootPart")
return
else
replicatedStorage.RE["1Clea1rTool1s"]:FireServer(unpack({
[1] = "ClearAllTools",
}))

replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(unpack({
[1] = "PickingTools",
[2] = "Couch",
}))

local chaosCouch3 = localPlayer6.Backpack:WaitForChild(
"Couch", 2
)

if not chaosCouch3 then
warn("Error: couch not found in Backpack")
return
else
chaosCouch3.Name = "Chaos.Couch"
local seat12 = chaosCouch3:FindFirstChild("Seat1")
local seat22 = chaosCouch3:FindFirstChild("Seat2")
local handle3 = chaosCouch3:FindFirstChild("Handle")

if seat12 and seat22 and handle3 then
seat12.Disabled = true
seat22.Disabled = true
handle3.Name = "Handle "
chaosCouch3.Parent = localPlayer6.Character

local mOVOOEPFFGEREVEWVW3 = Instance.new(
"BodyVelocity", seat12
)

mOVOOEPFFGEREVEWVW3.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

mOVOOEPFFGEREVEWVW3.P = 1250
mOVOOEPFFGEREVEWVW3.Velocity = Vector3.new(0, 0, 0)
mOVOOEPFFGEREVEWVW3.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"

repeat
for j = 1, 35 do
local v128 = { x = 0, y = 0, z = 0 }

local humanoidRootPart12 = findFirstChild9.Character
and findFirstChild9.Character.HumanoidRootPart

if not humanoidRootPart12 then
break
end

v128.x = humanoidRootPart12.Position.X
+ humanoidRootPart12.Velocity.X / 2

v128.y = humanoidRootPart12.Position.Y
+ humanoidRootPart12.Velocity.Y / 2

v128.z = humanoidRootPart12.Position.Z
+ humanoidRootPart12.Velocity.Z / 2

seat12.CFrame = CFrame.new(Vector3.new(
v128.x, v128.y, v128.z
)) * CFrame.new(-2, 2, 0)

task.wait()
end

mOVOOEPFFGEREVEWVW3:Destroy()
chaosCouch3.Parent = localPlayer6.Backpack
task.wait()
chaosCouch3:FindFirstChild("Handle ").Name = "Handle"
task.wait(0.2)
chaosCouch3.Parent = localPlayer6.Character
task.wait()

chaosCouch3.Parent = localPlayer6.Backpack
chaosCouch3.Handle.Name = "Handle "

task.wait(0.2)
chaosCouch3.Parent = localPlayer6.Character

mOVOOEPFFGEREVEWVW3 = Instance.new(
"BodyVelocity", seat12
)

mOVOOEPFFGEREVEWVW3.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

mOVOOEPFFGEREVEWVW3.P = 1250

mOVOOEPFFGEREVEWVW3.Velocity = Vector3.new(
0, 0, 0
)

mOVOOEPFFGEREVEWVW3.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"

local character10 = findFirstChild9.Character

humanoid8 = character10

humanoid8 = character10
and findFirstChild9.Character.Humanoid
and findFirstChild9.Character.Humanoid.Sit
== true
until humanoid8

task.wait()
mOVOOEPFFGEREVEWVW3:Destroy()
chaosCouch3.Parent = localPlayer6.Backpack
task.wait()
chaosCouch3:FindFirstChild("Handle ").Name = "Handle"
task.wait(0.3)
chaosCouch3.Parent = localPlayer6.Character
task.wait(0.3)
chaosCouch3.Grip = CFrame.new(Vector3.new(0, 0, 0))
task.wait(0.3)
replicatedStorage.RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
return
end

warn("Error: couch components not found")
return
end
end
end

trollPlayersTab:AddSection({ Name = "Troll Player" })

local function f56()
local v129 = {}

for index26, value56 in ipairs((players:GetPlayers())) do
if value56 ~= localPlayer6 then
table.insert(v129, value56.Name)
end
end

return v129
end

selecionarJogadorAddDropdown = trollPlayersTab:AddDropdown({
Name = "Select Player",
Options = f56(),
Default = "",
Callback = function(value57)
v43 = value57
getgenv().Target = value57
print("Selected player: " .. tostring(value57))
end,
})

trollPlayersTab:AddButton({
Name = "Refresh Player List",
Callback = function()
local getPlayers = players:GetPlayers()
local v130 = {}

if selecionarJogadorAddDropdown and #getPlayers > 0 then
for index27, value58 in ipairs(getPlayers) do
if value58.Name ~= localPlayer6.Name then
table.insert(v130, value58.Name)
end
end

selecionarJogadorAddDropdown:Set(v130)

print(
"Player list updated: ",
table.concat(v130, ", ")
)

if v43 and not players:FindFirstChild(v43) then
v43 = nil
getgenv().Target = nil
selecionarJogadorAddDropdown:SetValue("")
print("Selection reset, player left the server.")
end
else
print("Error: dropdown not found or no players available.")
end
end,
})

trollPlayersTab:AddButton({
Name = "Teleport To Player",
Callback = function()
if not v43 or not players:FindFirstChild(v43) then
print("Error: player not selected or does not exist")
return
else
local character11 = localPlayer6.Character

local humanoidRootPart13 = character11
and character11:FindFirstChild("HumanoidRootPart")

if not humanoidRootPart13 then
warn("Error: local HumanoidRootPart not found")
return
else
local findFirstChild10 = players:FindFirstChild(v43)

if findFirstChild10 and findFirstChild10.Character
and findFirstChild10.Character:FindFirstChild("HumanoidRootPart") then
humanoidRootPart13.CFrame = findFirstChild10.Character.HumanoidRootPart.CFrame
else
print("Error: target not found or has no HumanoidRootPart")
end

return
end
end
end,
})

trollPlayersTab:AddToggle({
Name = "Spectar Player",
Default = false,
Callback = function(value59)
local currentCamera4 = workspace.CurrentCamera

local function f57()
if value59 then
local findFirstChild11 = players:FindFirstChild(v43)

if findFirstChild11 and findFirstChild11.Character then
local humanoid9 = findFirstChild11.Character:FindFirstChild("Humanoid")

if humanoid9 then
currentCamera4.CameraSubject = humanoid9
end
end
elseif localPlayer6.Character then
local humanoid10 = localPlayer6.Character:FindFirstChild("Humanoid")

if humanoid10 then
currentCamera4.CameraSubject = humanoid10
end
end
end

if value59 then
if not getgenv().CameraConnection then
local v131 = getgenv()
v131.CameraConnection = runService.Heartbeat:Connect(f57)
end
else
if getgenv().CameraConnection then
getgenv().CameraConnection:Disconnect()
getgenv().CameraConnection = nil
end

f57()
end
end,
})

trollPlayersTab:AddSection({ Name = "Methods" })

trollPlayersTab:AddDropdown({
Name = "Select Kill Method",
Options = {
"Bus", "Couch", "Couch Without Going To Target [BETA]",
},
Default = "",
Callback = function(value60)
v44 = value60
print("Selected method: " .. tostring(value60))
end,
})

trollPlayersTab:AddButton({
Name = "Kill Player",
Callback = function()
local v132 = not v43 or not players:FindFirstChild(v43)
local sit, character12, cframe, v133

if v132 then
print("Error: player not selected or does not exist")
return
elseif v44 == "Couch" then
f13()
return
elseif v44 == "Couch Without Going To Target [BETA]" then
f12()
return
else
character12 = localPlayer6.Character

local humanoidRootPart14 = character12
and character12:FindFirstChild("HumanoidRootPart")

if not humanoidRootPart14 then
warn("Error: local HumanoidRootPart not found")
return
else
cframe = humanoidRootPart14.CFrame

local function f58()
local vehicles3 = game.Workspace:FindFirstChild("Vehicles")

if vehicles3 then
return vehicles3:FindFirstChild(localPlayer6.Name
.. "Car")
end

return nil
end

v133 = f58()

if not v133 then
humanoidRootPart14.CFrame = CFrame.new(
1118.81, 75.998, -1138.61
)

task.wait(0.5)
local re3 = replicatedStorage:FindFirstChild("RE")

if re3 and re3:FindFirstChild("1Ca1r") then
re3["1Ca1r"]:FireServer(
"PickingCar", "SchoolBus"
)
end

task.wait(1)
v133 = f58()
end

if v133 then
local vehicleSeat = v133:FindFirstChild("Body")
and v133.Body:FindFirstChild("VehicleSeat")

if vehicleSeat
and character12:FindFirstChildOfClass("Humanoid")
and not character12.Humanoid.Sit then
repeat
humanoidRootPart14.CFrame = vehicleSeat.CFrame * CFrame.new(
0, 2, 0
)

task.wait()

sit = character12.Humanoid.Sit
or not v133.Parent
until sit

if character12.Humanoid.Sit or not v133.Parent then
for key13, value61 in pairs(v133.Body:GetChildren()) do
if value61:IsA("Seat") then
value61.CanTouch = false
end
end
end
end
end

spawn(function()
while true do
if v43 then
local findFirstChild12 = players:FindFirstChild(v43)

if findFirstChild12
and findFirstChild12.Character
and findFirstChild12.Character:FindFirstChild("HumanoidRootPart") then
local humanoid11 = findFirstChild12.Character:FindFirstChildOfClass("Humanoid")

if humanoid11 and humanoid11.Sit then
if character12.Humanoid then
v133:SetPrimaryPartCFrame(CFrame.new(Vector3.new(
9999, -450, 9999
)))

print("Player sat down, taking the bus to the void!")
task.wait(0.2)

local function f59()
local humanoid12 = character12
and character12:FindFirstChildWhichIsA("Humanoid")

if humanoid12 then
humanoid12:ChangeState(Enum.HumanoidStateType.Jumping)
end
end

f59()

print("Simulando pulo!")
task.wait(0.5)
humanoidRootPart14.CFrame = cframe
print("Player returned to the start position.")
end

break
end

local v134 = tick() * 35
local v135 = math.sin(v134)
local v136 = math.cos(v134)

v133:SetPrimaryPartCFrame(findFirstChild12.Character.HumanoidRootPart.CFrame * CFrame.new(
v135 * 4, 0, v136 * 20
))
end
end

runService.RenderStepped:Wait()
end
end)

return
end
end
end,
})

trollPlayersTab:AddButton({
Name = "Pull Player",
Callback = function()
local v137 = not v43 or not players:FindFirstChild(v43)
local sit2, character13, cframe2, v138

if v137 then
print("Error: player not selected or does not exist")
return
elseif v44 == "Couch" then
f11()
return
elseif v44 == "Couch Without Going To Target [BETA]" then
f33()
return
else
character13 = localPlayer6.Character

local humanoidRootPart15 = character13
and character13:FindFirstChild("HumanoidRootPart")

if not humanoidRootPart15 then
warn("Error: local HumanoidRootPart not found")
return
else
cframe2 = humanoidRootPart15.CFrame

local function f60()
local vehicles4 = game.Workspace:FindFirstChild("Vehicles")

if vehicles4 then
return vehicles4:FindFirstChild(localPlayer6.Name
.. "Car")
end

return nil
end

v138 = f60()

if not v138 then
humanoidRootPart15.CFrame = CFrame.new(
1118.81, 75.998, -1138.61
)

task.wait(0.5)
local re4 = replicatedStorage:FindFirstChild("RE")

if re4 and re4:FindFirstChild("1Ca1r") then
re4["1Ca1r"]:FireServer(
"PickingCar", "SchoolBus"
)
end

task.wait(1)
v138 = f60()
end

if v138 then
local vehicleSeat2 = v138:FindFirstChild("Body")
and v138.Body:FindFirstChild("VehicleSeat")

if vehicleSeat2
and character13:FindFirstChildOfClass("Humanoid")
and not character13.Humanoid.Sit then
repeat
humanoidRootPart15.CFrame = vehicleSeat2.CFrame * CFrame.new(
0, 2, 0
)

task.wait()

sit2 = character13.Humanoid.Sit
or not v138.Parent
until sit2
end
end

spawn(function()
while true do
if v43 then
local findFirstChild13 = players:FindFirstChild(v43)

if findFirstChild13
and findFirstChild13.Character
and findFirstChild13.Character:FindFirstChild("HumanoidRootPart") then
local humanoid13 = findFirstChild13.Character:FindFirstChildOfClass("Humanoid")

if humanoid13 and humanoid13.Sit then
if character13.Humanoid then
v138:SetPrimaryPartCFrame(cframe2)
task.wait(0.7)

replicatedStorage.RE:FindFirstChild("1Ca1r"):FireServer(unpack({
[1] = "DeleteAllVehicles",
}))
end

break
end

local v139 = tick() * 35
local v140 = math.sin(v139)
local v141 = math.cos(v139)

v138:SetPrimaryPartCFrame(findFirstChild13.Character.HumanoidRootPart.CFrame * CFrame.new(
v140 * 4, 0, v141 * 20
))
end
end

runService.RenderStepped:Wait()
end
end)

return
end
end
end,
})

trollPlayersTab:AddButton({
Name = "House Ban Kill",
Callback = function()
local localPlayer18, character14, humanoid14,
humanoidRootPart16, vehicles5, findFirstChild14

if not v43 then
print("No player selected!")
return
else
localPlayer18 = game.Players.LocalPlayer
local backpack2 = localPlayer18.Backpack
character14 = localPlayer18.Character
humanoid14 = character14:FindFirstChildOfClass("Humanoid")
humanoidRootPart16 = character14:FindFirstChild("HumanoidRootPart")
local findFirstChild15 = game.Workspace:FindFirstChild("001_Lots")
local cframe3 = humanoidRootPart16.CFrame
local total3 = 0
vehicles5 = v1.Vehicles

function Check()
if localPlayer18 and character14 and humanoid14
and humanoidRootPart16 and vehicles5 then
return true
end

return false
end

local findFirstChild16 = game.Players:FindFirstChild(v43)

if findFirstChild16 and findFirstChild16.Character then
if Check() then
if not findFirstChild15:FindFirstChild(localPlayer18.Name
.. "House") then
local v142 = {}

for key14, value62 in pairs(findFirstChild15:GetChildren()) do
if value62.Name == "For Sale" then
for key15, value63 in pairs(value62:GetDescendants()) do
if value63:IsA("NumberValue")
and value63.Name == "Number"
and value63.Value < 25
and value63.Value > 10 then
table.insert(v142, {
Lot = value62,
Number = value63.Value,
})

break
end
end
end
end

if #v142 > 0 then
local v143 = v142[math.random(1, #v142)]
local lot = v143.Lot
local number = v143.Number
local buyHouse = lot:FindFirstChild("BuyHouse")
local position3 = buyHouse.Position

if buyHouse and buyHouse:IsA("BasePart") then
humanoidRootPart16.CFrame = buyHouse.CFrame + Vector3.new(
0, -6, 0
)

task.wait(0.5)
local clickDetector = buyHouse:FindFirstChild("ClickDetector")

if clickDetector then
fireclickdetector(clickDetector)
end
end

task.wait(0.5)

replicatedStorage:WaitForChild("Remotes"):WaitForChild("Lot:BuildProperty"):FireServer(unpack({
number, "056_House",
}))
else
print("No house available to buy!")
return
end
end

task.wait(0.5)

local findFirstChild17 = findFirstChild15:FindFirstChild(localPlayer18.Name
.. "House")

if findFirstChild17 then
task.wait(0.5)
local v144 = nil

for key16, value64 in pairs(findFirstChild17:GetDescendants()) do
if value64.Name == "Number"
and value64:IsA("NumberValue") then
v144 = value64
end
end

task.wait(0.5)

replicatedStorage.RE:FindFirstChild("1Gettin1gHous1e"):FireServer(
"PickingCustomHouse", "049_House", v144.Value
)
end

task.wait(0.5)

if not vehicles5:FindFirstChild(localPlayer18.Name
.. "Car") then
if Check() then
humanoidRootPart16.CFrame = CFrame.new(
1118.81, 75.998, -1138.61
)

task.wait(0.5)

replicatedStorage.RE:FindFirstChild("1Ca1r"):FireServer(
"PickingCar", "SchoolBus"
)

task.wait(0.5)

local findFirstChild18 = vehicles5:FindFirstChild(localPlayer18.Name
.. "Car")

task.wait(0.5)
local body = findFirstChild18:FindFirstChild("Body")

local vehicleSeat3 = body

vehicleSeat3 = body
and findFirstChild18.Body:FindFirstChild("VehicleSeat")

if vehicleSeat3 then
while true do
task.wait()

humanoidRootPart16.CFrame = vehicleSeat3.CFrame * CFrame.new(0, math.random(
-1, 1
), 0)

if humanoid14.Sit then
break
end
end
end
end
end

task.wait(0.5)

findFirstChild14 = vehicles5:FindFirstChild(localPlayer18.Name
.. "Car")

if findFirstChild14 then
if not humanoid14.Sit then
local body2 = findFirstChild14:FindFirstChild("Body")

local vehicleSeat4 = body2

vehicleSeat4 = body2
and findFirstChild14.Body:FindFirstChild("VehicleSeat")

if vehicleSeat4 then
while true do
task.wait()

humanoidRootPart16.CFrame = vehicleSeat4.CFrame * CFrame.new(0, math.random(
-1, 1
), 0)

if humanoid14.Sit then
break
end
end
end
end

local character15 = findFirstChild16.Character
local humanoid15 = character15:FindFirstChildOfClass("Humanoid")
local humanoidRootPart17 = character15:FindFirstChild("HumanoidRootPart")

if character15 and humanoid15
and humanoidRootPart17 then
if not humanoid15.Sit then
while not humanoid15.Sit do
task.wait()

local function f61(p31, p32, p33)
findFirstChild14:SetPrimaryPartCFrame(CFrame.new(p31.Position)
* p32 * p33)
end

total3 = total3 + 100

f61(humanoidRootPart17, CFrame.new(0, 1.5, 0)
+ humanoid15.MoveDirection
* humanoidRootPart17.Velocity.Magnitude
/ 1.1, CFrame.Angles(math.rad(total3), 0, 0))

f61(humanoidRootPart17, CFrame.new(0, -1.5, 0)
+ humanoid15.MoveDirection
* humanoidRootPart17.Velocity.Magnitude
/ 1.1, CFrame.Angles(math.rad(total3), 0, 0))

f61(humanoidRootPart17, CFrame.new(2.25, 1.5, -2.25)
+ humanoid15.MoveDirection
* humanoidRootPart17.Velocity.Magnitude
/ 1.1, CFrame.Angles(math.rad(total3), 0, 0))

f61(humanoidRootPart17, CFrame.new(-2.25, -1.5, 2.25)
+ humanoid15.MoveDirection
* humanoidRootPart17.Velocity.Magnitude
/ 1.1, CFrame.Angles(math.rad(total3), 0, 0))

f61(humanoidRootPart17, CFrame.new(0, 1.5, 0)
+ humanoid15.MoveDirection
* humanoidRootPart17.Velocity.Magnitude
/ 1.1, CFrame.Angles(math.rad(total3), 0, 0))

f61(humanoidRootPart17, CFrame.new(0, -1.5, 0)
+ humanoid15.MoveDirection
* humanoidRootPart17.Velocity.Magnitude
/ 1.1, CFrame.Angles(math.rad(total3), 0, 0))
end

task.wait(0.2)

local findFirstChild19 = findFirstChild15:FindFirstChild(localPlayer18.Name
.. "House")

findFirstChild14:SetPrimaryPartCFrame(CFrame.new(findFirstChild19.HouseSpawnPosition.Position))
task.wait(0.2)

for key17, value65 in pairs((workspace:FindPartsInRegion3(Region3.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(
30, 30, 30
), game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(
30, 30, 30
)), game.Players.LocalPlayer.Character.HumanoidRootPart, math.huge))) do
if value65.Name == "HumanoidRootPart" then
local findFirstChild20 = players:FindFirstChild(value65.Parent.Name)

replicatedStorage.RE:FindFirstChild("1Playe1rTrigge1rEven1t"):FireServer(unpack({
[1] = "BanPlayerFromHouse",
[2] = findFirstChild20,
[3] = value65.Parent,
}))

replicatedStorage.RE:FindFirstChild("1Ca1r"):FireServer(unpack({
[1] = "DeleteAllVehicles",
}))
end
end
end
end
end

return
end

return
end

return
end
end,
})

localPlayer7 = players.LocalPlayer
currentCamera2 = workspace.CurrentCamera
v45 = false

trollPlayersTab:AddToggle({
Name = "Auto Fling ",
Default = false,
Callback = function(value66)
v45 = value66

local findFirstChild21, humanoidRootPart18, character16,
humanoid16, cframe4, v145, flingForce

if value66 and v43 then
findFirstChild21 = players:FindFirstChild(v43)

if not findFirstChild21
or not findFirstChild21.Character then
return
else
humanoidRootPart18 = localPlayer7.Character
and localPlayer7.Character:FindFirstChild("HumanoidRootPart")

local character17 = findFirstChild21.Character

local humanoidRootPart19 = character17

humanoidRootPart19 = character17
and findFirstChild21.Character:FindFirstChild("HumanoidRootPart")

local v146 = not humanoidRootPart18
local v147 = humanoidRootPart19

if v146 or not v147 then
return
end

character16 = localPlayer7.Character
humanoid16 = character16:FindFirstChildOfClass("Humanoid")
cframe4 = humanoidRootPart18.CFrame
replicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
task.wait(0.2)
v145 = { [1] = "PickingTools", [2] = "Couch" }
replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(unpack(v145))
task.wait(0.3)
local couch5 = localPlayer7.Backpack:FindFirstChild("Couch")

if couch5 then
couch5.Parent = character16
end

task.wait(0.2)

virtualInputManager:SendKeyEvent(
true, Enum.KeyCode.F, false, game
)

task.wait(0.25)
workspace.FallenPartsDestroyHeight = (0 / 0)

flingForce = Instance.new("BodyVelocity")
flingForce.Name = "FlingForce"

flingForce.Velocity = Vector3.new(
900000000, 900000000, 900000000
)

flingForce.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

flingForce.Parent = humanoidRootPart18

humanoid16:SetStateEnabled(
Enum.HumanoidStateType.Seated, false
)

humanoid16.PlatformStand = false

currentCamera2.CameraSubject = findFirstChild21.Character:FindFirstChild("Head")
or v147 or humanoid16

task.spawn(function()
local total4 = 0
local v148 = { humanoidRootPart18 }

while v45 and findFirstChild21
and findFirstChild21.Character
and findFirstChild21.Character:FindFirstChildOfClass("Humanoid") do
if findFirstChild21.Character:FindFirstChildOfClass("Humanoid").Sit then
break
end

total4 = total4 + 50

for index28, value67 in ipairs(v148) do
humanoidRootPart18.CFrame = CFrame.new(
findFirstChild21.Character.HumanoidRootPart.Position.X + findFirstChild21.Character.HumanoidRootPart.Velocity.X / 1.5,
findFirstChild21.Character.HumanoidRootPart.Position.Y + findFirstChild21.Character.HumanoidRootPart.Velocity.Y / 1.5,
findFirstChild21.Character.HumanoidRootPart.Position.Z + findFirstChild21.Character.HumanoidRootPart.Velocity.Z / 1.5
) * CFrame.Angles(
math.rad(total4), 0, 0
)
end

humanoidRootPart18.Velocity = Vector3.new(
900000000, 900000000, 900000000
)

humanoidRootPart18.RotVelocity = Vector3.new(
900000000, 900000000, 900000000
)

task.wait()
end

v45 = false
flingForce:Destroy()

humanoid16:SetStateEnabled(
Enum.HumanoidStateType.Seated, true
)

humanoid16.PlatformStand = false

humanoidRootPart18.CFrame = cframe4
currentCamera2.CameraSubject = humanoid16

for key18, value68 in pairs(character16:GetDescendants()) do
if value68:IsA("BasePart") then
value68.Velocity = Vector3.zero
value68.RotVelocity = Vector3.zero
end
end

humanoid16:UnequipTools()
replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(unpack(v145))
end)

return
end
else
return
end
end,
})

function f34(p34)
local localPlayer19 = players.LocalPlayer

local character18 = localPlayer19.Character
or localPlayer19.CharacterAdded:Wait()

local humanoid17 = character18:WaitForChild("Humanoid")
character18:WaitForChild("HumanoidRootPart")
local backpack3 = localPlayer19:WaitForChild("Backpack")
local waitForChild4 = workspace.WorkspaceCom:WaitForChild("001_SoccerBalls")

local function f62()
if not backpack3:FindFirstChild("SoccerBall") then
replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(
"PickingTools", "SoccerBall"
)
end

while true do
task.wait()

if backpack3:FindFirstChild("SoccerBall") then
break
end
end

backpack3.SoccerBall.Parent = character18

while true do
task.wait()

if waitForChild4:FindFirstChild("Soccer"
.. localPlayer19.Name) then
break
end
end

character18.SoccerBall.Parent = backpack3

return waitForChild4:FindFirstChild("Soccer"
.. localPlayer19.Name)
end

local findFirstChild22 = waitForChild4:FindFirstChild("Soccer"
.. localPlayer19.Name)
or f62()

findFirstChild22.CanCollide = false
findFirstChild22.Massless = true

findFirstChild22.CustomPhysicalProperties = PhysicalProperties.new(
0.0001, 0, 0
)

local v149

if p34 ~= localPlayer19 then
local character19 = p34.Character

if character19
and character19:FindFirstChild("HumanoidRootPart")
and character19:FindFirstChild("Humanoid") then
local humanoidRootPart20 = character19.HumanoidRootPart
local humanoid18 = character19.Humanoid
local bodyVelocity = findFirstChild22:FindFirstChildWhichIsA("BodyVelocity")

if bodyVelocity then
bodyVelocity:Destroy()
end

local flingPower = Instance.new("BodyVelocity")
flingPower.Name = "FlingPower"

flingPower.Velocity = Vector3.new(
9000000, 9000000, 9000000
)

flingPower.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

flingPower.P = math.huge
flingPower.Parent = findFirstChild22

workspace.CurrentCamera.CameraSubject = humanoid18

repeat
local vector4 = Vector3.new(humanoidRootPart20.Position.X
+ humanoidRootPart20.Velocity.X * 0.15, humanoidRootPart20.Position.Y
+ humanoidRootPart20.Velocity.Y * 0.15, humanoidRootPart20.Position.Z
+ humanoidRootPart20.Velocity.Z * 0.15)

findFirstChild22.CFrame = CFrame.new(vector4)

findFirstChild22.Orientation = findFirstChild22.Orientation + Vector3.new(
45, 60, 30
)

task.wait()

local v150 = humanoidRootPart20.Velocity.Magnitude
> 1000

v149 = v150

v149 = v150 or humanoid18.Health <= 0
or not character19:IsDescendantOf(workspace)
or p34.Parent ~= players
until v149

workspace.CurrentCamera.CameraSubject = humanoid17
end
end
end

trollPlayersTab:AddButton({
Name = "Fling Ball",
Callback = function()
f34(players[v43])

task.delay(2, function()
localPlayer7.Character.SoccerBall.FootballInteraction:FireServer(CFrame.new(
1, 1, 1
))
end)
end,
})

local localPlayer20 = players.LocalPlayer

trollPlayersTab:AddSection({ Name = "Fling Boat" })

trollPlayersTab:AddButton({
Name = "Fling - Boat",
Callback = function()
local v151 = not v43
or not game.Players:FindFirstChild(v43)

local findFirstChild23, localPlayer21,
humanoidRootPart21, vehicles6, humanoidRootPart22,
spinning, f63

if v151 then
warn("No player selected or does not exist")
return
else
localPlayer21 = game.Players.LocalPlayer
local character20 = localPlayer21.Character

local humanoid19 = character20
and character20:FindFirstChildOfClass("Humanoid")

humanoidRootPart21 = character20
and character20:FindFirstChild("HumanoidRootPart")

local v152 = game.Workspace
local v153 = not humanoid19
vehicles6 = v152:FindFirstChild("Vehicles")

if v153 or not humanoidRootPart21 then
warn("Invalid Humanoid or RootPart")
return
else
local function f64()
humanoidRootPart21.CFrame = CFrame.new(
1754, -2, 58
)

task.wait(0.5)

replicatedStorage.RE:FindFirstChild("1Ca1r"):FireServer(
"PickingBoat", "MilitaryBoatFree"
)

task.wait(1)

return vehicles6:FindFirstChild(localPlayer21.Name
.. "Car")
end

findFirstChild23 = vehicles6:FindFirstChild(localPlayer21.Name
.. "Car")
or f64()

if not findFirstChild23 then
warn("Falha ao spawnar o barco")
return
else
local vehicleSeat5 = findFirstChild23:FindFirstChild("Body")
and findFirstChild23.Body:FindFirstChild("VehicleSeat")

if not vehicleSeat5 then
warn("Seat not found")
return
else
while true do
task.wait(0.1)

humanoidRootPart21.CFrame = vehicleSeat5.CFrame * CFrame.new(
0, 1, 0
)

if humanoid19.SeatPart == vehicleSeat5 then
break
end
end

print("Barco spawnado!")
local findFirstChild24 = game.Players:FindFirstChild(v43)

if not findFirstChild24
or not findFirstChild24.Character then
warn("Player not found")
return
else
local character21 = findFirstChild24.Character
local humanoid20 = character21:FindFirstChildOfClass("Humanoid")
humanoidRootPart22 = character21:FindFirstChild("HumanoidRootPart")

if not humanoidRootPart22 or not humanoid20 then
warn("Target Humanoid or RootPart not found")
return
end

spinning = Instance.new("BodyAngularVelocity")
spinning.Name = "Spinning"
spinning.Parent = findFirstChild23.PrimaryPart

spinning.MaxTorque = Vector3.new(
0, math.huge, 0
)

spinning.AngularVelocity = Vector3.new(
0, 369, 0
)

print("Fling ativo!")

function f63(p35, p36)
if findFirstChild23
and findFirstChild23.PrimaryPart then
findFirstChild23:SetPrimaryPartCFrame(CFrame.new(p35.Position
+ p36))
end
end

task.spawn(function()
while findFirstChild23
and findFirstChild23.Parent
and humanoidRootPart22
and humanoidRootPart22.Parent do
task.wait(0.01)

f63(
humanoidRootPart22, Vector3.new(0, 1, 0)
)

f63(
humanoidRootPart22,
Vector3.new(0, -2.25, 5)
)

f63(
humanoidRootPart22,
Vector3.new(0, 2.25, 0.25)
)

f63(
humanoidRootPart22,
Vector3.new(-2.25, -1.5, 2.25)
)

f63(
humanoidRootPart22,
Vector3.new(0, 1.5, 0)
)

f63(
humanoidRootPart22,
Vector3.new(0, -1.5, 0)
)

if findFirstChild23
and findFirstChild23.PrimaryPart then
local v154 = math.rad(math.random(
-369, 369
))

local v155 = math.rad(math.random(
-369, 369
))

local cframe5 = CFrame.Angles(v154, v155, math.rad(math.random(
-369, 369
)))

findFirstChild23:SetPrimaryPartCFrame(CFrame.new(humanoidRootPart22.Position + Vector3.new(
0, 1.5, 0
)) * cframe5)
end
end

if spinning and spinning.Parent then
spinning:Destroy()
print("Fling desativado")
end
end)

return
end
end
end
end
end
end,
})

print("Fling - Boat button created")

trollPlayersTab:AddButton({
Name = "Desligar Fling - Boat",
Callback = function()
local localPlayer22 = game.Players.LocalPlayer
local character22 = localPlayer22.Character

local humanoidRootPart23 = character22
and character22:FindFirstChild("HumanoidRootPart")

local humanoid21 = character22
and character22:FindFirstChildOfClass("Humanoid")

local vehicles7 = game.Workspace:FindFirstChild("Vehicles")

if not humanoidRootPart23 or not humanoid21 then
warn("No RootPart or Humanoid found!")
return
else
humanoid21.PlatformStand = true
print("Player frozen to reduce spin effects.")

for key19, value69 in pairs(humanoidRootPart23:GetChildren()) do
if value69:IsA("BodyAngularVelocity")
or value69:IsA("BodyVelocity") then
value69:Destroy()
end
end

print("Spin and forces removed from the player.")
replicatedStorage.RE:FindFirstChild("1Ca1r"):FireServer("DeleteAllVehicles")
task.wait(0.5)

local findFirstChild25 = vehicles7

findFirstChild25 = vehicles7
and vehicles7:FindFirstChild(localPlayer22.Name
.. "Car")

if findFirstChild25 and findFirstChild25.PrimaryPart then
for key20, value70 in pairs(findFirstChild25.PrimaryPart:GetChildren()) do
if value70:IsA("BodyAngularVelocity")
or value70:IsA("BodyVelocity") then
value70:Destroy()
end
end

print("Spin removido do barco.")
end

task.wait(1)
local vector5 = Vector3.new(0, 1000, 0)

local instance14 = Instance.new(
"BodyPosition", humanoidRootPart23
)

instance14.Position = vector5

instance14.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

local instance15 = Instance.new(
"BodyGyro", humanoidRootPart23
)

instance15.CFrame = humanoidRootPart23.CFrame

instance15.MaxTorque = Vector3.new(
math.huge, math.huge, math.huge
)

print("Player is held at the safe coordinate.")
task.wait(3)
instance14:Destroy()
instance15:Destroy()
humanoid21.PlatformStand = false
print("Player released, safe in position.")
return
end
end,
})

trollPlayersTab:AddSection({ Name = "Click Kill Methods" })

trollPlayersTab:AddButton({
Name = "Click Fling Portas [Beta]",
Description = "To use: get close to other doors, wait for the door to come to you, then click the player you want to fling",
Callback = function()
local localPlayer23 = players.LocalPlayer

local humanoidRootPart24 = (localPlayer23.Character
or localPlayer23.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")

local blackHoleTarget = Instance.new("Part")

blackHoleTarget.Size = Vector3.new(
100000, 100000, 100000
)

blackHoleTarget.Transparency = 1
blackHoleTarget.Anchored = true
blackHoleTarget.CanCollide = false
blackHoleTarget.Name = "BlackHoleTarget"
blackHoleTarget.Parent = v1

local luscaaBlackHoleAttachment = Instance.new("Attachment")
luscaaBlackHoleAttachment.Name = "Luscaa_BlackHoleAttachment"
luscaaBlackHoleAttachment.Parent = blackHoleTarget

runService.Heartbeat:Connect(function()
blackHoleTarget.CFrame = humanoidRootPart24.CFrame
end)

local v156 = {}

local function f65(p37)
if not p37:IsA("BasePart") or p37.Anchored
or not string.find(p37.Name, "Door") then
return
elseif p37:FindFirstChild("Luscaa_Attached") then
return
else
p37.CanCollide = false

for index29, value71 in ipairs(p37:GetChildren()) do
if value71:IsA("AlignPosition")
or value71:IsA("Torque")
or value71:IsA("Attachment") then
value71:Destroy()
end
end

Instance.new("BoolValue", p37).Name = "Luscaa_Attached"
local instance16 = Instance.new("Attachment", p37)

local instance17 = Instance.new(
"AlignPosition", p37
)

instance17.Attachment0 = instance16
instance17.Attachment1 = luscaaBlackHoleAttachment
instance17.MaxForce = 100000000000000000000
instance17.MaxVelocity = math.huge
instance17.Responsiveness = 99999

local instance18 = Instance.new("Torque", p37)
instance18.Attachment0 = instance16
instance18.RelativeTo = Enum.ActuatorRelativeTo.World

instance18.Torque = Vector3.new(math.random(
-1000000, 1000000
) * 10000, math.random(
-1000000, 1000000
) * 10000, math.random(
-1000000, 1000000
) * 10000)

table.insert(v156, {
Part = p37,
Align = instance17,
})

return
end
end

for index30, value72 in ipairs(v1:GetDescendants()) do
if value72:IsA("BasePart")
and string.find(value72.Name, "Door") then
f65(value72)
end
end

v1.DescendantAdded:Connect(function(descendant3)
if descendant3:IsA("BasePart")
and string.find(descendant3.Name, "Door") then
f65(descendant3)
end
end)

local function f66(p38)
local character23 = p38.Character

if not character23 then
return
else
local humanoidRootPart25 = character23:FindFirstChild("HumanoidRootPart")

if not humanoidRootPart25 then
return
else
local shnmaxTargetAttachment = humanoidRootPart25:FindFirstChild("SHNMAX_TargetAttachment")

if not shnmaxTargetAttachment then
shnmaxTargetAttachment = Instance.new(
"Attachment", humanoidRootPart25
)

shnmaxTargetAttachment.Name = "SHNMAX_TargetAttachment"
end

for index31, value73 in ipairs(v156) do
if value73.Align then
value73.Align.Attachment1 = shnmaxTargetAttachment
end
end

local v157 = tick()

while tick() - v157 < 5 do
if humanoidRootPart25.Velocity.Magnitude >= 20 then
break
end

runService.Heartbeat:Wait()
end

for index32, value74 in ipairs(v156) do
if value74.Align then
value74.Align.Attachment1 = luscaaBlackHoleAttachment
end
end

return
end
end
end

userInputService.TouchTap:Connect(function(p39, p40)
if p40 then
return
else
local v158 = p39[1]

local screenPointToRay = v1.CurrentCamera:ScreenPointToRay(
v158.X, v158.Y
)

local raycast = v1:Raycast(screenPointToRay.Origin, screenPointToRay.Direction
* 1000)

if raycast and raycast.Instance then
local getPlayerFromCharacter = players:GetPlayerFromCharacter(raycast.Instance:FindFirstAncestorOfClass("Model"))

if getPlayerFromCharacter
and getPlayerFromCharacter ~= localPlayer23 then
f66(getPlayerFromCharacter)
end
end

return
end
end)
end,
})

trollPlayersTab:AddButton({
Name = "Click Fling Couch (Tool)",
Callback = function()
local localPlayer24 = players.LocalPlayer
local currentCamera5 = workspace.CurrentCamera
local v159 = true
local v160 = false
local backpack4 = localPlayer24:WaitForChild("Backpack")

if not backpack4:FindFirstChild("Click Fling Couch")
and not (localPlayer24.Character
and localPlayer24.Character:FindFirstChild("Click Fling Couch")) then
local clickFlingCouch = Instance.new("Tool")
clickFlingCouch.Name = "Click Fling Couch"
clickFlingCouch.RequiresHandle = false
clickFlingCouch.CanBeDropped = false

clickFlingCouch.Equipped:Connect(function()
v160 = true
end)

clickFlingCouch.Unequipped:Connect(function()
v160 = false
end)

clickFlingCouch.Parent = backpack4
end

local function f67(p41)
if not v160 then
return
end

local v161, humanoidRootPart26, character24,
humanoid22, cframe6, forcaJogada

if not p41 or not p41.Character
or p41 == localPlayer24 then
return
else
v161 = true

humanoidRootPart26 = localPlayer24.Character
and localPlayer24.Character:FindFirstChild("HumanoidRootPart")

local humanoidRootPart27 = p41.Character
and p41.Character:FindFirstChild("HumanoidRootPart")

if not humanoidRootPart26 or not humanoidRootPart27 then
return
else
character24 = localPlayer24.Character
humanoid22 = character24:FindFirstChildOfClass("Humanoid")
cframe6 = humanoidRootPart26.CFrame
replicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
task.wait(0.2)

replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(
"PickingTools", "Couch"
)

task.wait(0.3)
local couch6 = localPlayer24.Backpack:FindFirstChild("Couch")

if couch6 then
couch6.Parent = character24
end

task.wait(0.1)

virtualInputManager:SendKeyEvent(
true, Enum.KeyCode.F, false, game
)

task.wait(0.25)
workspace.FallenPartsDestroyHeight = (0 / 0)

forcaJogada = Instance.new("BodyVelocity")
forcaJogada.Name = "ForcaJogada"

forcaJogada.Velocity = Vector3.new(
900000000, 900000000, 900000000
)

forcaJogada.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

forcaJogada.Parent = humanoidRootPart26

humanoid22:SetStateEnabled(
Enum.HumanoidStateType.Seated, false
)

humanoid22.PlatformStand = false

currentCamera5.CameraSubject = p41.Character:FindFirstChild("Head")
or humanoidRootPart27 or humanoid22

task.spawn(function()
local total5 = 0
local v162 = { humanoidRootPart26 }

while v161 and p41 and p41.Character
and p41.Character:FindFirstChildOfClass("Humanoid") do
if p41.Character:FindFirstChildOfClass("Humanoid").Sit then
break
end

total5 = total5 + 50

for index33, value75 in ipairs(v162) do
local humanoidRootPart28 = p41.Character.HumanoidRootPart

humanoidRootPart26.CFrame = CFrame.new(humanoidRootPart28.Position + humanoidRootPart28.Velocity / 1.5) * CFrame.Angles(
math.rad(total5), 0, 0
)
end

humanoidRootPart26.Velocity = Vector3.new(
900000000, 900000000, 900000000
)

humanoidRootPart26.RotVelocity = Vector3.new(
900000000, 900000000, 900000000
)

task.wait()
end

v161 = false
forcaJogada:Destroy()

humanoid22:SetStateEnabled(
Enum.HumanoidStateType.Seated, true
)

humanoid22.PlatformStand = false

humanoidRootPart26.CFrame = cframe6
currentCamera5.CameraSubject = humanoid22

for key21, value76 in pairs(character24:GetDescendants()) do
if value76:IsA("BasePart") then
value76.Velocity = Vector3.zero
value76.RotVelocity = Vector3.zero
end
end

humanoid22:UnequipTools()

replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(
"PickingTools", "Couch"
)
end)

while v161 do
task.wait()
end

return
end
end
end

userInputService.TouchTap:Connect(function(p42, p43)
if p43 or not v159 or not v160 then
return
else
local v163 = p42[1]

local screenPointToRay2 = currentCamera5:ScreenPointToRay(
v163.X, v163.Y
)

local raycast2 = workspace:Raycast(screenPointToRay2.Origin, screenPointToRay2.Direction
* 1000)

if raycast2 and raycast2.Instance then
local getPlayerFromCharacter2 = players:GetPlayerFromCharacter(raycast2.Instance:FindFirstAncestorOfClass("Model"))

if getPlayerFromCharacter2
and getPlayerFromCharacter2 ~= localPlayer24 then
v159 = false
f67(getPlayerFromCharacter2)
task.delay(2, function() v159 = true end)
end
end

return
end
end)
end,
})

trollPlayersTab:AddButton({
Name = "Click Fling Ball (Tool)",
Callback = function()
local currentCamera6 = v1.CurrentCamera
local localPlayer25 = players.LocalPlayer
local v164 = false
local backpack5 = localPlayer25:WaitForChild("Backpack")

if not backpack5:FindFirstChild("Click Fling Ball") then
local clickFlingBall = Instance.new("Tool")
clickFlingBall.Name = "Click Fling Ball"
clickFlingBall.RequiresHandle = false
clickFlingBall.CanBeDropped = false

clickFlingBall.Equipped:Connect(function()
v164 = true
end)

clickFlingBall.Unequipped:Connect(function()
v164 = false
end)

clickFlingBall.Parent = backpack5
end

local function f68(p44)
local localPlayer26 = players.LocalPlayer

local character25 = localPlayer26.Character
or localPlayer26.CharacterAdded:Wait()

local humanoid23 = character25:WaitForChild("Humanoid")
character25:WaitForChild("HumanoidRootPart")
local backpack6 = localPlayer26:WaitForChild("Backpack")
local waitForChild5 = workspace.WorkspaceCom:WaitForChild("001_SoccerBalls")

local function f69()
if not backpack6:FindFirstChild("SoccerBall")
and not character25:FindFirstChild("SoccerBall") then
replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(
"PickingTools", "SoccerBall"
)
end

local soccerBall

repeat
task.wait()
local soccerBall2 = backpack6:FindFirstChild("SoccerBall")

soccerBall = soccerBall2

soccerBall = soccerBall2
or character25:FindFirstChild("SoccerBall")
until soccerBall

local soccerBall3 = backpack6:FindFirstChild("SoccerBall")

if soccerBall3 then
soccerBall3.Parent = character25
end

while true do
task.wait()

if waitForChild5:FindFirstChild("Soccer"
.. localPlayer26.Name) then
break
end
end

return waitForChild5:FindFirstChild("Soccer"
.. localPlayer26.Name)
end

local findFirstChild26 = waitForChild5:FindFirstChild("Soccer"
.. localPlayer26.Name)
or f69()

findFirstChild26.CanCollide = false
findFirstChild26.Massless = true

findFirstChild26.CustomPhysicalProperties = PhysicalProperties.new(
0.0001, 0, 0
)

local v165

if p44 ~= localPlayer26 then
local character26 = p44.Character

if character26
and character26:FindFirstChild("HumanoidRootPart")
and character26:FindFirstChild("Humanoid") then
local humanoidRootPart29 = character26.HumanoidRootPart
local humanoid24 = character26.Humanoid

if findFirstChild26:FindFirstChildWhichIsA("BodyVelocity") then
findFirstChild26:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
end

local flingPower2 = Instance.new("BodyVelocity")
flingPower2.Name = "FlingPower"

flingPower2.Velocity = Vector3.new(
900000000, 900000000, 900000000
)

flingPower2.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

flingPower2.P = math.huge
flingPower2.Parent = findFirstChild26

workspace.CurrentCamera.CameraSubject = humanoid24

repeat
if humanoidRootPart29.Velocity.Magnitude > 0 then
findFirstChild26.CFrame = CFrame.new(humanoidRootPart29.Position
+ humanoidRootPart29.Velocity / 1.5)

findFirstChild26.Orientation = findFirstChild26.Orientation + Vector3.new(
45, 60, 30
)
else
for key22, value77 in pairs(character26:GetChildren()) do
if value77:IsA("BasePart")
and value77.CanCollide
and not value77.Anchored then
findFirstChild26.CFrame = value77.CFrame
task.wait(0.00016666666666667)
end
end
end

task.wait(0.00016666666666667)

local v166 = humanoidRootPart29.Velocity.Magnitude
> 1000

v165 = v166

v165 = v166 or humanoid24.Health <= 0
or not character26:IsDescendantOf(workspace)
or p44.Parent ~= players
until v165

workspace.CurrentCamera.CameraSubject = humanoid23
end
end
end

userInputService.TouchTap:Connect(function(p45, p46)
if not v164 or p46 then
return
else
local v167 = p45[1]

local screenPointToRay3 = currentCamera6:ScreenPointToRay(
v167.X, v167.Y
)

local raycast3 = v1:Raycast(screenPointToRay3.Origin, screenPointToRay3.Direction
* 1000)

if raycast3 and raycast3.Instance then
local getPlayerFromCharacter3 = players:GetPlayerFromCharacter((raycast3.Instance:FindFirstAncestorOfClass("Model")))

if getPlayerFromCharacter3
and getPlayerFromCharacter3 ~= localPlayer25 then
f68(getPlayerFromCharacter3)
end
end

return
end
end)
end,
})

trollPlayersTab:AddButton({
Name = "Click Kill Couch (Tool)",
Callback = function()
local localPlayer27 = players.LocalPlayer
local currentCamera7 = v1.CurrentCamera
local v168 = false
local v169 = false
local backpack7 = localPlayer27:WaitForChild("Backpack")
local name4

if not backpack7:FindFirstChild("Click Kill Couch") then
local clickKillCouch = Instance.new("Tool")
clickKillCouch.Name = "Click Kill Couch"
clickKillCouch.RequiresHandle = false
clickKillCouch.CanBeDropped = false

clickKillCouch.Equipped:Connect(function()
v168 = true
end)

clickKillCouch.Unequipped:Connect(function()
v168 = false
name4 = nil
limparSofa()
end)

clickKillCouch.Parent = backpack7
end

local connect3, part, cframe7, humanoidRootPart30

function limparSofa()
if connect3 then
connect3:Disconnect()
connect3 = nil
end

if v169 then
local character27 = localPlayer27.Character

if character27 then
local couch7 = character27:FindFirstChild("Couch")

if couch7 then
couch7.Parent = localPlayer27.Backpack
v169 = false
end
end
end

if part then
part:Destroy()
part = nil
end

if getgenv().AntiSit then
getgenv().AntiSit:Set(false)
end

local humanoid25 = localPlayer27.Character
and localPlayer27.Character:FindFirstChildOfClass("Humanoid")

if humanoid25 then
humanoid25:SetStateEnabled(
Enum.HumanoidStateType.Physics, true
)

humanoid25:ChangeState(Enum.HumanoidStateType.GettingUp)
end

if cframe7 and humanoidRootPart30 then
humanoidRootPart30.CFrame = cframe7
cframe7 = nil
end
end

function pegarSofa()
local character28 = localPlayer27.Character

if not character28 then
return
else
local backpack8 = localPlayer27.Backpack

if not backpack8:FindFirstChild("Couch")
and not character28:FindFirstChild("Couch") then
replicatedStorage.RE["1Too1l"]:InvokeServer(unpack({
"PickingTools", "Couch",
}))

task.wait(0.1)
end

local couch8 = backpack8:FindFirstChild("Couch")
or character28:FindFirstChild("Couch")

if couch8 then
couch8.Parent = character28
v169 = true
end

return
end
end

function posAleatoriaAbaixo(p47)
local humanoidRootPart31 = p47:FindFirstChild("HumanoidRootPart")

if not humanoidRootPart31 then
return Vector3.new()
else
local v170 = math.random(-2, 2)

local vector6 = Vector3.new(
v170, -5.1, math.random(-2, 2)
)

return humanoidRootPart31.Position + vector6
end
end

function tpAbaixo(p48)
if not p48 or not p48.Character
or not p48.Character:FindFirstChild("HumanoidRootPart") then
return
else
local character29 = localPlayer27.Character

local humanoidRootPart32 = character29
and character29:FindFirstChild("HumanoidRootPart")

local humanoid26 = character29
and character29:FindFirstChildOfClass("Humanoid")

if not humanoidRootPart32 or not humanoid26 then
return
else
humanoid26:SetStateEnabled(
Enum.HumanoidStateType.Physics, false
)

if not part then
part = Instance.new("Part")
part.Size = Vector3.new(10, 1, 10)
part.Anchored = true
part.CanCollide = true
part.Transparency = 0.5
part.Parent = v1
end

local v171 = posAleatoriaAbaixo(p48.Character)
part.Position = v171
humanoidRootPart32.CFrame = CFrame.new(v171)

humanoid26:SetStateEnabled(
Enum.HumanoidStateType.Physics, true
)

return
end
end
end

function arremessarComSofa(p49)
if not p49 then
return
else
name4 = p49.Name
local character30 = localPlayer27.Character

if not character30 then
return
end

cframe7 = character30:FindFirstChild("HumanoidRootPart")
and character30.HumanoidRootPart.CFrame

humanoidRootPart30 = character30:FindFirstChild("HumanoidRootPart")
pegarSofa()

connect3 = runService.Heartbeat:Connect(function()
local findFirstChild27 = players:FindFirstChild(name4)

if not findFirstChild27
or not findFirstChild27.Character
or not findFirstChild27.Character:FindFirstChild("Humanoid") then
limparSofa()
return
end

if getgenv().AntiSit then
getgenv().AntiSit:Set(true)
end

tpAbaixo(findFirstChild27)
end)

task.spawn(function()
local findFirstChild28 = players:FindFirstChild(name4)

while findFirstChild28
and findFirstChild28.Character
and findFirstChild28.Character:FindFirstChild("Humanoid") do
task.wait(0.05)

if findFirstChild28.Character.Humanoid.SeatPart then
local cframe8 = CFrame.new(
265.46, -450.83, -59.93
)

findFirstChild28.Character.HumanoidRootPart.CFrame = cframe8
localPlayer27.Character.HumanoidRootPart.CFrame = cframe8
task.wait(0.4)
limparSofa()
task.wait(0.2)

if cframe7 then
localPlayer27.Character.HumanoidRootPart.CFrame = cframe7
end

break
end
end
end)

return
end
end

userInputService.TouchTap:Connect(function(p50, p51)
if not v168 or p51 then
return
else
local v172 = p50[1]

local screenPointToRay4 = currentCamera7:ScreenPointToRay(
v172.X, v172.Y
)

local raycast4 = v1:Raycast(screenPointToRay4.Origin, screenPointToRay4.Direction
* 1000)

if raycast4 and raycast4.Instance then
local getPlayerFromCharacter4 = players:GetPlayerFromCharacter((raycast4.Instance:FindFirstAncestorOfClass("Model")))

if getPlayerFromCharacter4
and getPlayerFromCharacter4 ~= localPlayer27 then
arremessarComSofa(getPlayerFromCharacter4)
end
end

return
end
end)
end,
})

trollPlayersTab:AddSection({ Name = "All methods" })

trollPlayersTab:AddButton({
Name = "Kill All Bus",
Callback = function()
local vector7 = Vector3.new(145.51, -374.09, 21.58)

local function f70()
local vehicles8 = v1:FindFirstChild("Vehicles")

if vehicles8 then
return vehicles8:FindFirstChild(players.LocalPlayer.Name
.. "Car")
end

return nil
end

local cframe9

local function f71(p52, p53)
while true do
if p52 then
local findFirstChild29 = players:FindFirstChild(p52)

if findFirstChild29 and findFirstChild29.Character
and findFirstChild29.Character:FindFirstChild("HumanoidRootPart") then
local humanoid27 = findFirstChild29.Character:FindFirstChildOfClass("Humanoid")

if humanoid27 and humanoid27.Sit then
local v173 = f70()

if v173 then
v173:SetPrimaryPartCFrame(CFrame.new(vector7))
print("Player sat down, taking the bus to the void!")
task.wait(0.2)

local function f72()
local humanoid28 = players.LocalPlayer.Character
and players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")

if humanoid28 then
humanoid28:ChangeState(Enum.HumanoidStateType.Jumping)
end
end

f72()

print("Simulando primeiro pulo!")
task.wait(0.4)
f72()
print("Simulando segundo pulo!")
task.wait(0.5)

if cframe9 then
players.LocalPlayer.Character.HumanoidRootPart.CFrame = cframe9
print("Player returned to the start position")
task.wait(0.1)

replicatedStorage:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack({
[1] = "DeleteAllVehicles",
}))

print("All vehicles were deleted!")
end
end

break
end

local humanoidRootPart33 = findFirstChild29.Character.HumanoidRootPart
local v174 = tick() * 35
math.sin(v174)
local v175 = math.cos(v174) * 20
local v176 = f70()

if v176 then
v176:SetPrimaryPartCFrame(humanoidRootPart33.CFrame * CFrame.new(
0, 0, v175
))
end
end
end

runService.RenderStepped:Wait()
end

if p53 then
p53()
end
end

local function f73(p54, p55)
local localPlayer28 = players.LocalPlayer

local character31 = localPlayer28.Character
or localPlayer28.CharacterAdded:Wait()

local humanoidRootPart34 = character31:WaitForChild("HumanoidRootPart")
cframe9 = humanoidRootPart34.CFrame
local v177 = f70()

if not v177 then
humanoidRootPart34.CFrame = CFrame.new(
1118.81, 75.998, -1138.61
)

task.wait(0.5)
local re5 = replicatedStorage:FindFirstChild("RE")

if re5 and re5:FindFirstChild("1Ca1r") then
re5["1Ca1r"]:FireServer("PickingCar", "SchoolBus")
end

task.wait(1)
v177 = f70()
end

local sit3

if v177 then
local vehicleSeat6 = v177:FindFirstChild("Body")
and v177.Body:FindFirstChild("VehicleSeat")

if vehicleSeat6
and character31:FindFirstChildOfClass("Humanoid")
and not character31.Humanoid.Sit then
repeat
humanoidRootPart34.CFrame = vehicleSeat6.CFrame
* CFrame.new(0, 2, 0)

task.wait()

sit3 = character31.Humanoid.Sit
or not v177.Parent
until sit3
end
end

spawn(function() f71(p54, p55) end)
end

local function f74(p56)
if #p56 == 0 then
return
end

f73(table.remove(p56, 1).Name, function()
task.wait(0.5)
f74(p56)
end)
end

f74(players:GetPlayers())
end,
})

print("Kill All Bus button created")

trollPlayersTab:AddButton({
Name = "House Ban kill All",
Callback = function()
local function f75(p57)
local localPlayer29 = game.Players.LocalPlayer
local backpack9 = localPlayer29.Backpack
local character32 = localPlayer29.Character
local humanoid29 = character32:FindFirstChildOfClass("Humanoid")
local humanoidRootPart35 = character32:FindFirstChild("HumanoidRootPart")
local findFirstChild30 = game.Workspace:FindFirstChild("001_Lots")
local cframe10 = humanoidRootPart35.CFrame
local total6 = 0
local vehicles9 = v1.Vehicles

function Check()
if localPlayer29 and character32 and humanoid29
and humanoidRootPart35 and vehicles9 then
return true
end

return false
end

local findFirstChild31

if Check() then
if not findFirstChild30:FindFirstChild(localPlayer29.Name
.. "House") then
local v178 = nil

for key23, value78 in pairs(findFirstChild30:GetChildren()) do
if value78.Name == "For Sale" then
for key24, value79 in pairs(value78:GetDescendants()) do
if value79:IsA("NumberValue")
and value79.Name == "Number"
and value79.Value < 25
and value79.Value > 10 then
v178 = value78
break
end
end
end
end

local buyHouse2 = v178:FindFirstChild("BuyHouse")
local position4 = buyHouse2.Position

if buyHouse2 and buyHouse2:IsA("BasePart") then
humanoidRootPart35.CFrame = buyHouse2.CFrame + Vector3.new(
0, -6, 0
)

task.wait(0.5)
local clickDetector2 = buyHouse2:FindFirstChild("ClickDetector")

if clickDetector2 then
fireclickdetector(clickDetector2)
end
end
end

task.wait(0.5)

local findFirstChild32 = findFirstChild30:FindFirstChild(localPlayer29.Name
.. "House")

if findFirstChild32 then
task.wait(0.5)
local v179 = nil

for key25, value80 in pairs(findFirstChild32:GetDescendants()) do
if value80.Name == "Number"
and value80:IsA("NumberValue") then
v179 = value80
end
end

task.wait(0.5)

replicatedStorage.RE:FindFirstChild("1Gettin1gHous1e"):FireServer(
"PickingCustomHouse", "049_House", v179.Value
)
end

task.wait(0.5)

if not vehicles9:FindFirstChild(localPlayer29.Name
.. "Car") then
if Check() then
humanoidRootPart35.CFrame = CFrame.new(
1118.81, 75.998, -1138.61
)

task.wait(0.5)

replicatedStorage.RE:FindFirstChild("1Ca1r"):FireServer(
"PickingCar", "SchoolBus"
)

task.wait(0.5)

local findFirstChild33 = vehicles9:FindFirstChild(localPlayer29.Name
.. "Car")

task.wait(0.5)
local body3 = findFirstChild33:FindFirstChild("Body")

local vehicleSeat7 = body3

vehicleSeat7 = body3
and findFirstChild33.Body:FindFirstChild("VehicleSeat")

if vehicleSeat7 then
while true do
task.wait()

humanoidRootPart35.CFrame = vehicleSeat7.CFrame * CFrame.new(0, math.random(
-1, 1
), 0)

if humanoid29.Sit then
break
end
end
end
end
end

task.wait(0.5)

findFirstChild31 = vehicles9:FindFirstChild(localPlayer29.Name
.. "Car")

if findFirstChild31 then
if not humanoid29.Sit then
local body4 = findFirstChild31:FindFirstChild("Body")

local vehicleSeat8 = body4

vehicleSeat8 = body4
and findFirstChild31.Body:FindFirstChild("VehicleSeat")

if vehicleSeat8 then
while true do
task.wait()

humanoidRootPart35.CFrame = vehicleSeat8.CFrame * CFrame.new(0, math.random(
-1, 1
), 0)

if humanoid29.Sit then
break
end
end
end
end

local character33 = p57.Character
local humanoid30 = character33:FindFirstChildOfClass("Humanoid")
local humanoidRootPart36 = character33:FindFirstChild("HumanoidRootPart")

if character33 and humanoid30
and humanoidRootPart36 then
if not humanoid30.Sit then
while not humanoid30.Sit do
task.wait()

local function f76(p58, p59, p60)
findFirstChild31:SetPrimaryPartCFrame(CFrame.new(p58.Position)
* p59 * p60)
end

total6 = total6 + 100

f76(humanoidRootPart36, CFrame.new(0, 1.5, 0)
+ humanoid30.MoveDirection
* humanoidRootPart36.Velocity.Magnitude
/ 1.1, CFrame.Angles(math.rad(total6), 0, 0))

f76(humanoidRootPart36, CFrame.new(0, -1.5, 0)
+ humanoid30.MoveDirection
* humanoidRootPart36.Velocity.Magnitude
/ 1.1, CFrame.Angles(math.rad(total6), 0, 0))

f76(humanoidRootPart36, CFrame.new(2.25, 1.5, -2.25)
+ humanoid30.MoveDirection
* humanoidRootPart36.Velocity.Magnitude
/ 1.1, CFrame.Angles(math.rad(total6), 0, 0))

f76(humanoidRootPart36, CFrame.new(-2.25, -1.5, 2.25)
+ humanoid30.MoveDirection
* humanoidRootPart36.Velocity.Magnitude
/ 1.1, CFrame.Angles(math.rad(total6), 0, 0))

f76(humanoidRootPart36, CFrame.new(0, 1.5, 0)
+ humanoid30.MoveDirection
* humanoidRootPart36.Velocity.Magnitude
/ 1.1, CFrame.Angles(math.rad(total6), 0, 0))

f76(humanoidRootPart36, CFrame.new(0, -1.5, 0)
+ humanoid30.MoveDirection
* humanoidRootPart36.Velocity.Magnitude
/ 1.1, CFrame.Angles(math.rad(total6), 0, 0))
end

task.wait(0.2)

local findFirstChild34 = findFirstChild30:FindFirstChild(localPlayer29.Name
.. "House")

findFirstChild31:SetPrimaryPartCFrame(CFrame.new(findFirstChild34.HouseSpawnPosition.Position))
task.wait(0.2)

for key26, value81 in pairs((workspace:FindPartsInRegion3(Region3.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(
30, 30, 30
), game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(
30, 30, 30
)), game.Players.LocalPlayer.Character.HumanoidRootPart, math.huge))) do
if value81.Name == "HumanoidRootPart" then
local findFirstChild35 = players:FindFirstChild(value81.Parent.Name)

replicatedStorage.RE:FindFirstChild("1Playe1rTrigge1rEven1t"):FireServer(unpack({
[1] = "BanPlayerFromHouse",
[2] = findFirstChild35,
[3] = value81.Parent,
}))
end
end
end
end
end
end

replicatedStorage:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack({
[1] = "DeleteAllVehicles",
}))
end

for key27, value82 in pairs(players:GetPlayers()) do
if value82 ~= localPlayer3 then
f75(value82)
task.wait(2)
end
end
end,
})

print("House Ban kill All button created")

trollPlayersTab:AddButton({
Name = "Fling Boat all",
Callback = function()
local localPlayer30 = game.Players.LocalPlayer
local character34 = localPlayer30.Character
local humanoid31 = character34:FindFirstChildOfClass("Humanoid")
local humanoidRootPart37 = character34:FindFirstChild("HumanoidRootPart")
local vehicles10 = game.Workspace:FindFirstChild("Vehicles")
local cframe11 = humanoidRootPart37.CFrame
local v180 = 0

local findFirstChild36 = vehicles10:FindFirstChild(localPlayer30.Name
.. "Car")

if not findFirstChild36 then
if humanoidRootPart37 then
humanoidRootPart37.CFrame = CFrame.new(1754, -2, 58)
task.wait(0.5)

replicatedStorage.RE:FindFirstChild("1Ca1r"):FireServer(
"PickingBoat", "MilitaryBoatFree"
)

task.wait(0.5)

findFirstChild36 = vehicles10:FindFirstChild(localPlayer30.Name
.. "Car")

task.wait(0.5)

local vehicleSeat9 = findFirstChild36:FindFirstChild("Body")
and findFirstChild36.Body:FindFirstChild("VehicleSeat")

if vehicleSeat9 then
while true do
task.wait()

humanoidRootPart37.CFrame = vehicleSeat9.CFrame * CFrame.new(0, math.random(
-1, 1
), 0)

if humanoid31.Sit then
break
end
end
end
end
end

task.wait(0.5)

findFirstChild36 = vehicles10:FindFirstChild(localPlayer30.Name
.. "Car")

if findFirstChild36 then
if not humanoid31.Sit then
local body5 = findFirstChild36:FindFirstChild("Body")

local vehicleSeat10 = body5

vehicleSeat10 = body5
and findFirstChild36.Body:FindFirstChild("VehicleSeat")

if vehicleSeat10 then
while true do
task.wait()

humanoidRootPart37.CFrame = vehicleSeat10.CFrame * CFrame.new(0, math.random(
-1, 1
), 0)

if humanoid31.Sit then
break
end
end
end
end
end

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.Parent = findFirstChild36.PrimaryPart

bodyGyro.MaxTorque = Vector3.new(
10000000, 10000000, 10000000
)

bodyGyro.P = 10000000

bodyGyro.CFrame = findFirstChild36.PrimaryPart.CFrame
* CFrame.Angles(0, math.rad(90), 0)

local function f77(p61, p62, p63)
v180 = 0
local v181 = tick() + 1

while tick() < v181 do
v180 = v180 + 100
task.wait()

local function f78(p64, p65, p66)
findFirstChild36:SetPrimaryPartCFrame(CFrame.new(p64.Position)
* p65 * p66)
end

f78(
p62, CFrame.new(0, 3, 0),
CFrame.Angles(math.rad(v180), 0, 0)
)

f78(
p62, CFrame.new(0, -1.5, 2),
CFrame.Angles(math.rad(v180), 0, 0)
)

f78(
p62, CFrame.new(2, 1.5, 2.25),
CFrame.Angles(math.rad(50), 0, 0)
)

f78(
p62, CFrame.new(-2.25, -1.5, 2.25),
CFrame.Angles(math.rad(30), 0, 0)
)

f78(
p62, CFrame.new(0, 1.5, 0),
CFrame.Angles(math.rad(v180), 0, 0)
)

f78(
p62, CFrame.new(0, -1.5, 0),
CFrame.Angles(math.rad(v180), 0, 0)
)
end
end

for key28, value83 in pairs(game.Players:GetPlayers()) do
if value83 ~= localPlayer30 then
local character35 = value83.Character

local humanoid32 = character35

humanoid32 = character35
and character35:FindFirstChildOfClass("Humanoid")

local humanoidRootPart38 = character35

humanoidRootPart38 = character35
and character35:FindFirstChild("HumanoidRootPart")

if character35 and humanoid32 and humanoidRootPart38 then
f77(character35, humanoidRootPart38, humanoid32)
end
end
end

task.wait(0.5)
findFirstChild36:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
task.wait(0.5)
humanoid31.Sit = false
task.wait(0.5)
humanoidRootPart37.CFrame = cframe11
bodyGyro:Destroy()
end,
})

print("Fling Boat All button created")

trollPlayersTab:AddButton({
Name = "Auto Fling All",
Callback = function()
local localPlayer31 = players.LocalPlayer
local currentCamera8 = workspace.CurrentCamera

local function f79(p67)
local v182 = not p67 or not p67.Character
or p67 == localPlayer31

local v183, humanoidRootPart39, character36,
humanoid33, cframe12, flingForce2

if v182 then
return
else
v183 = true

humanoidRootPart39 = localPlayer31.Character
and localPlayer31.Character:FindFirstChild("HumanoidRootPart")

local humanoidRootPart40 = p67.Character
and p67.Character:FindFirstChild("HumanoidRootPart")

if not humanoidRootPart39 or not humanoidRootPart40 then
return
else
character36 = localPlayer31.Character
humanoid33 = character36:FindFirstChildOfClass("Humanoid")
cframe12 = humanoidRootPart39.CFrame
replicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
task.wait(0.2)

replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(
"PickingTools", "Couch"
)

task.wait(0.3)
local couch9 = localPlayer31.Backpack:FindFirstChild("Couch")

if couch9 then
couch9.Parent = character36
end

task.wait(0.1)

virtualInputManager:SendKeyEvent(
true, Enum.KeyCode.F, false, game
)

task.wait(0.25)
workspace.FallenPartsDestroyHeight = (0 / 0)

flingForce2 = Instance.new("BodyVelocity")
flingForce2.Name = "FlingForce"

flingForce2.Velocity = Vector3.new(
900000000, 900000000, 900000000
)

flingForce2.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

flingForce2.Parent = humanoidRootPart39

humanoid33:SetStateEnabled(
Enum.HumanoidStateType.Seated, false
)

humanoid33.PlatformStand = false

currentCamera8.CameraSubject = p67.Character:FindFirstChild("Head")
or humanoidRootPart40 or humanoid33

task.spawn(function()
local total7 = 0
local v184 = { humanoidRootPart39 }

while v183 and p67 and p67.Character
and p67.Character:FindFirstChildOfClass("Humanoid") do
if p67.Character:FindFirstChildOfClass("Humanoid").Sit then
break
end

total7 = total7 + 50

for index34, value84 in ipairs(v184) do
local humanoidRootPart41 = p67.Character.HumanoidRootPart

humanoidRootPart39.CFrame = CFrame.new(humanoidRootPart41.Position + humanoidRootPart41.Velocity / 1.5) * CFrame.Angles(
math.rad(total7), 0, 0
)
end

humanoidRootPart39.Velocity = Vector3.new(
900000000, 900000000, 900000000
)

humanoidRootPart39.RotVelocity = Vector3.new(
900000000, 900000000, 900000000
)

task.wait()
end

v183 = false
flingForce2:Destroy()

humanoid33:SetStateEnabled(
Enum.HumanoidStateType.Seated, true
)

humanoid33.PlatformStand = false

humanoidRootPart39.CFrame = cframe12
currentCamera8.CameraSubject = humanoid33

for key29, value85 in pairs(character36:GetDescendants()) do
if value85:IsA("BasePart") then
value85.Velocity = Vector3.zero
value85.RotVelocity = Vector3.zero
end
end

humanoid33:UnequipTools()

replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(
"PickingTools", "Couch"
)
end)

while v183 do
task.wait()
end

return
end
end
end

for index35, value86 in ipairs(players:GetPlayers()) do
f79(value86)
end
end,
})

trollPlayersTab:AddButton({
Name = "Bring All Couch [melhor]",
Callback = function()
replicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer(unpack({
[1] = "ClearAllTools",
}))

wait(0.2)
toolselcted = "Couch"
dupeamot = 25
picktoolremote = replicatedStorage.RE:FindFirstChild("1Too1l")
cleartoolremote = replicatedStorage.RE:FindFirstChild("1Clea1rTool1s")

starterGui:SetCore("SendNotification", {
Title = "Dupando",
Text = "Don't click anything while it is working.",
Button1 = " Eu entendi",
Duration = 5,
})

starterGui:SetCore("SendNotification", {
Title = "Dupe Script",
Text = "Because It will break the script and you will need to rejoin.",
Button1 = "Eu entendi",
Duration = 5,
})

duping = true
oldcf = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame

if game.Players.LocalPlayer.Character.Humanoid.Sit
== true then
task.wait()
game.Players.LocalPlayer.Character.Humanoid.Sit = false
end

wait(0.1)

if v1:FindFirstChild("Camera") then
v1:FindFirstChild("Camera"):Destroy()
end

for k = 1, 2 do
task.wait()

game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
999999999.414, -490, 999999999.414, 0.974360406,
-0.175734088, 0.14049761, -0.133441404,
0.0514053069, 0.989722729, -0.181150302,
-0.983094692, 0.0266370922
)
end

task.wait(0.2)
game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
wait(0.5)

for key30, value87 in pairs(players.LocalPlayer.Character:GetChildren()) do
if value87.Name == toolselcted == false then
if value87:IsA("Tool") then
value87.Parent = game.Players.LocalPlayer.Backpack
end
end
end

for key31, value88 in pairs(players.LocalPlayer.Backpack:GetChildren()) do
if value88:IsA("Tool") then
if value88.Name == toolselcted == false then
value88:Destroy()
end
end
end

for key32, value89 in pairs(players.LocalPlayer.Character:GetChildren()) do
if value89:IsA("Tool") then
if value89.name == toolselcted == false then
value89:Destroy()
end
end
end

for key33, value90 in pairs(players.LocalPlayer.Character:GetChildren()) do
if value90:IsA("Tool") then
if value90.Name == toolselcted then
toollllfoun2 = true

for key34, hANDLE in pairs(value90:GetDescendants()) do
if hANDLE.Name == "Handle" then
hANDLE.Name = "Hâ\194\129¥aâ\194\129¥nâ\194\129¥dâ\194\129¥lâ\194\129¥e"

value90.Parent = game.Players.LocalPlayer.Backpack
value90.Parent = game.Players.LocalPlayer.Character

tollllahhhh = value90
task.wait()
end
end
else
toollllfoun2 = false
end
end
end

for key35, value91 in pairs(players.LocalPlayer.Backpack:GetChildren()) do
if value91:IsA("Tool") then
if value91.Name == toolselcted then
toollllfoun = true

for key36, hANDLE2 in pairs(value91:GetDescendants()) do
if hANDLE2.Name == "Handle" then
value91.Parent = game.Players.LocalPlayer.Character
wait()
hANDLE2.Name = "Hâ\194\129¥aâ\194\129¥nâ\194\129¥dâ\194\129¥lâ\194\129¥e"

value91.Parent = game.Players.LocalPlayer.Backpack
value91.Parent = game.Players.LocalPlayer.Character

toolllffel = value91
end
end
else
toollllfoun = false
end
end
end

if toollllfoun == true then
if game.Players.LocalPlayer.Character:FindFirstChild(toolllffel)
== nil then
toollllfoun = false
end

while true do
wait()

if game.Players.LocalPlayer.Character:FindFirstChild(toolllffel)
== nil then
break
end
end

toollllfoun = false
end

if toollllfoun2 == true then
if game.Players.LocalPlayer.Character:FindFirstChild(tollllahhhh)
== nil then
toollllfoun2 = false
end

while true do
wait()

if game.Players.LocalPlayer.Character:FindFirstChild(tollllahhhh)
== nil then
break
end
end

toollllfoun2 = false
end

wait(0.1)
local v185 = dupeamot
local count3 = 0
local character37

while true do
count3 = 1 + count3

if not (count3 <= v185) then
break
end

local v186 = count3

if duping == false then
game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
return
else
if v1:FindFirstChild("Camera") then
v1:FindFirstChild("Camera"):Destroy()
end

if v186 <= dupeamot then
starterGui:SetCore("SendNotification", {
Title = "Dupando vida",
Text = "Se tem" .. " " .. v186 .. " " .. "Duped"
.. " " .. toolselcted .. "!",
Duration = 0.5,
})
elseif v186 == dupeamot or v186 >= dupeamot - 1 then
starterGui:SetCore("SendNotification", {
Title = "Dupando",
Text = "Se tem" .. " " .. v186 .. " " .. "Duped"
.. " " .. toolselcted
.. "! Duping tools is done now, Please wait a little bit to respawn.",
Duration = 4,
})
end

picktoolremote:InvokeServer(unpack({
[1] = "PickingTools",
[2] = toolselcted,
}))

local backpack10 = players.LocalPlayer.Backpack
backpack10:WaitForChild(toolselcted).Parent = game.Players.LocalPlayer.Character

if duping == false then
game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
return
else
wait()

local v187 = players.LocalPlayer.Character[toolselcted]
v187:FindFirstChild("Handle").Name = "Hâ\194\129¥aâ\194\129¥nâ\194\129¥dâ\194\129¥lâ\194\129¥e"

local character38 = players.LocalPlayer.Character
character38:FindFirstChild(toolselcted).Parent = game.Players.LocalPlayer.Backpack

local backpack11 = players.LocalPlayer.Backpack
backpack11:FindFirstChild(toolselcted).Parent = game.Players.LocalPlayer.Character

repeat
if v1:FindFirstChild("Camera") then
v1:FindFirstChild("Camera"):Destroy()
end

task.wait()
character37 = players.LocalPlayer.Character
until character37:FindFirstChild(toolselcted)
== nil
end
end
end

game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false

while true do
wait()

if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
== nil then
break
end
end

while true do
wait()

if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
break
end
end

game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = oldcf
wait()
duping = false

for key37, value92 in pairs(game.Players:GetPlayers()) do
if value92.Name == game.Players.LocalPlayer.Name
== false then
ewoifjwoifjiwo = key37
end
end

local v188 = ewoifjwoifjiwo
local count4 = 0

while true do
count4 = 1 + count4

if not (count4 <= v188) then
break
end

game.Players.LocalPlayer.Backpack.Couch.Name = "couch"
.. count4
end

wait()

for key38, value93 in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
if value93.Name == "couch" .. key38 then
value93.Handle.Name = "Handle "
end
end

wait(0.2)

local function f80(p68, p69)
if p69 == nil == false then
local v189 = game.Players.LocalPlayer.Backpack["couch" .. p68]
v189:FindFirstChild("Seat1").Disabled = true

local v190 = game.Players.LocalPlayer.Backpack["couch" .. p68]
v190:FindFirstChild("Seat2").Disabled = true

game.Players.LocalPlayer.Backpack["couch" .. p68].Parent = game.Players.LocalPlayer.Character
local v191 = game.Players.LocalPlayer.Character["couch" .. p68]

tet = Instance.new(
"BodyVelocity", v191:FindFirstChild("Handle ")
)

tet.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

tet.P = 1250
tet.Velocity = Vector3.new(0, 0, 0)
tet.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"

repeat
local count5 = 0

while true do
count5 = 1 + count5

if not (35 >= count5) then
break
end

local v192 = { x = 0, y = 0, z = 0 }
v192.x = p69.Character.HumanoidRootPart.Position.X
v192.y = p69.Character.HumanoidRootPart.Position.Y
v192.z = p69.Character.HumanoidRootPart.Position.Z

v192.x = v192.x
+ p69.Character.HumanoidRootPart.Velocity.X
/ 2

v192.y = v192.y
+ p69.Character.HumanoidRootPart.Velocity.Y
/ 2

v192.z = v192.z
+ p69.Character.HumanoidRootPart.Velocity.Z
/ 2

local v193 = game.Players.LocalPlayer.Character["couch" .. p68]

v193:FindFirstChild("Seat1").CFrame = CFrame.new(Vector3.new(
v192.x, v192.y, v192.z
)) * CFrame.new(
-2, 2, 0
)

task.wait()
end

game.Players.LocalPlayer.Character["couch" .. p68].Parent = game.Players.LocalPlayer.Backpack
wait()

local v194 = game.Players.LocalPlayer.Backpack["couch" .. p68]
v194:FindFirstChild("Handle ").Name = "Handle"

wait(0.2)
game.Players.LocalPlayer.Backpack["couch" .. p68].Parent = game.Players.LocalPlayer.Character
wait()

game.Players.LocalPlayer.Character["couch" .. p68].Parent = game.Players.LocalPlayer.Backpack
game.Players.LocalPlayer.Backpack["couch" .. p68].Handle.Name = "Handle "

wait(0.2)
game.Players.LocalPlayer.Backpack["couch" .. p68].Parent = game.Players.LocalPlayer.Character
local v195 = game.Players.LocalPlayer.Character["couch" .. p68]

tet = Instance.new(
"BodyVelocity", v195:FindFirstChild("Seat1")
)

tet.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

tet.P = 1250
tet.Velocity = Vector3.new(0, 0, 0)
tet.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"
until p69.Character.Humanoid.Sit == true

wait()

game.Players.LocalPlayer.Character["couch" .. p68]:FindFirstChild("Handle "):FindFirstChild("#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"):Destroy()
game.Players.LocalPlayer.Character["couch" .. p68].Parent = game.Players.LocalPlayer.Backpack

wait()

local v196 = game.Players.LocalPlayer.Backpack["couch" .. p68]
v196:FindFirstChild("Handle ").Name = "Handle"

wait(0.2)
game.Players.LocalPlayer.Backpack["couch" .. p68].Parent = game.Players.LocalPlayer.Character
wait()
game.Players.LocalPlayer.Character["couch" .. p68].Parent = game.Players.LocalPlayer.Backpack
end
end

for key39, value94 in pairs(game.Players:GetPlayers()) do
local v197 = key39
local v198 = value94

if v198.Name == game.Players.LocalPlayer.Name == false then
spawn(function() f80(v197, v198) end)
end
end
end,
})

print("Bring All Couch button created")

trollPlayersTab:AddButton({
Name = "Kill All Couch [melhor]",
Callback = function()
local v199 = { [1] = "ClearAllTools" }
replicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer(unpack(v199))
wait(0.2)
local position5 = game.Players.LocalPlayer.Character.HumanoidRootPart.Position

local part2 = Instance.new("Part")
part2.Size = Vector3.new(5000, 10, 5000)
part2.Position = Vector3.new(0, -500, 0)
part2.Anchored = true
part2.CanCollide = true
part2.Parent = game.Workspace

task.wait()

game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
0, -500, 0
)

wait(2)
toolselcted = "Couch"
dupeamot = 25
picktoolremote = replicatedStorage.RE:FindFirstChild("1Too1l")
cleartoolremote = replicatedStorage.RE:FindFirstChild("1Clea1rTool1s")

starterGui:SetCore("SendNotification", {
Title = "Dupando",
Text = "Don't click anything",
Button1 = "Eu entendi",
Duration = 5,
})

starterGui:SetCore("SendNotification", {
Title = "Dupando",
Text = "Espere",
Button1 = "Tendeu",
Duration = 5,
})

duping = true
oldcf = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame

if game.Players.LocalPlayer.Character.Humanoid.Sit
== true then
task.wait()
game.Players.LocalPlayer.Character.Humanoid.Sit = false
end

wait(0.1)

if v1:FindFirstChild("Camera") then
v1:FindFirstChild("Camera"):Destroy()
end

local count6 = 0

while true do
count6 = 1 + count6

if not (2 >= count6) then
break
end

task.wait()

game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
999999999.414, -490, 999999999.414, 0.974360406,
-0.175734088, 0.14049761, -0.133441404,
0.0514053069, 0.989722729, -0.181150302,
-0.983094692, 0.0266370922
)
end

task.wait(0.2)
game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
wait(0.5)

for key40, value95 in pairs(players.LocalPlayer.Character:GetChildren()) do
if value95.Name == toolselcted == false then
if value95:IsA("Tool") then
value95.Parent = game.Players.LocalPlayer.Backpack
end
end
end

for key41, value96 in pairs(players.LocalPlayer.Backpack:GetChildren()) do
if value96:IsA("Tool") then
if value96.Name == toolselcted == false then
value96:Destroy()
end
end
end

for key42, value97 in pairs(players.LocalPlayer.Character:GetChildren()) do
if value97:IsA("Tool") then
if value97.Name == toolselcted == false then
value97:Destroy()
end
end
end

for key43, value98 in pairs(players.LocalPlayer.Character:GetChildren()) do
if value98:IsA("Tool") then
if value98.Name == toolselcted then
local getDescendants = value98.GetDescendants
toollllfoun2 = true

for key44, hANDLE3 in pairs(getDescendants(value98)) do
if hANDLE3.Name == "Handle" then
hANDLE3.Name = "HÃ¢Â�Â¥aÃ¢Â�Â¥nÃ¢Â�Â¥dÃ¢Â�Â¥lÃ¢Â�Â¥e"

value98.Parent = game.Players.LocalPlayer.Backpack
value98.Parent = game.Players.LocalPlayer.Character

tollllahhhh = value98
task.wait()
end
end
else
toollllfoun2 = false
end
end
end

for key45, value99 in pairs(players.LocalPlayer.Backpack:GetChildren()) do
if value99:IsA("Tool") then
if value99.Name == toolselcted then
toollllfoun = true

for key46, hANDLE4 in pairs(value99:GetDescendants()) do
if hANDLE4.Name == "Handle" then
value99.Parent = game.Players.LocalPlayer.Character
wait()
hANDLE4.Name = "HÃ¢Â�Â¥aÃ¢Â�Â¥nÃ¢Â�Â¥dÃ¢Â�Â¥lÃ¢Â�Â¥e"

value99.Parent = game.Players.LocalPlayer.Backpack
value99.Parent = game.Players.LocalPlayer.Character

toolllffel = value99
end
end
else
toollllfoun = false
end
end
end

if toollllfoun == true then
if game.Players.LocalPlayer.Character:FindFirstChild(toolllffel)
== nil then
toollllfoun = false
end

while true do
wait()

if game.Players.LocalPlayer.Character:FindFirstChild(toolllffel)
== nil then
break
end
end

toollllfoun = false
end

if toollllfoun2 == true then
if game.Players.LocalPlayer.Character:FindFirstChild(tollllahhhh)
== nil then
toollllfoun2 = false
end

while true do
wait()

if game.Players.LocalPlayer.Character:FindFirstChild(tollllahhhh)
== nil then
break
end
end

toollllfoun2 = false
end

wait(0.1)
local v200 = dupeamot
local count7 = 0
local character39

while true do
count7 = 1 + count7

if not (v200 >= count7) then
break
end

local v201 = count7

if duping == false then
game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
return
else
if v1:FindFirstChild("Camera") then
v1:FindFirstChild("Camera"):Destroy()
end

if v201 <= dupeamot then
starterGui:SetCore("SendNotification", {
Title = "Dupe Script",
Text = "Agora c Tem" .. " " .. v201 .. " "
.. "Duped" .. " " .. toolselcted .. "!",
Duration = 0.5,
})
elseif v201 == dupeamot or v201 >= dupeamot - 1 then
starterGui:SetCore("SendNotification", {
Title = "Dupe Script",
Text = "Agora c tem" .. " " .. v201 .. " "
.. "Duped" .. " " .. toolselcted
.. "! As tools Tao sendo dupada Clica em nada nao fiote",
Duration = 4,
})
end

picktoolremote:InvokeServer(unpack({
[1] = "PickingTools",
[2] = toolselcted,
}))

local backpack12 = players.LocalPlayer.Backpack
backpack12:WaitForChild(toolselcted).Parent = game.Players.LocalPlayer.Character

if duping == false then
game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
return
else
wait()

local v202 = players.LocalPlayer.Character[toolselcted]
v202:FindFirstChild("Handle").Name = "HÃ¢Â�Â¥aÃ¢Â�Â¥nÃ¢Â�Â¥dÃ¢Â�Â¥lÃ¢Â�Â¥e"

local character40 = players.LocalPlayer.Character
character40:FindFirstChild(toolselcted).Parent = game.Players.LocalPlayer.Backpack

local backpack13 = players.LocalPlayer.Backpack
backpack13:FindFirstChild(toolselcted).Parent = game.Players.LocalPlayer.Character

repeat
if v1:FindFirstChild("Camera") then
v1:FindFirstChild("Camera"):Destroy()
end

task.wait()
character39 = players.LocalPlayer.Character
until character39:FindFirstChild(toolselcted)
== nil
end
end
end

game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false

while true do
wait()

if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
== nil then
break
end
end

while true do
wait()

if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
break
end
end

game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = oldcf
wait()
duping = false

for key47, value100 in pairs(game.Players:GetPlayers()) do
if value100.Name == game.Players.LocalPlayer.Name
== false then
ewoifjwoifjiwo = key47
end
end

for m = 1, ewoifjwoifjiwo do
game.Players.LocalPlayer.Backpack.Couch.Name = "Chaos Couch"
.. m
end

wait()

for key48, value101 in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
if value101.Name == "Chaos Couch" .. key48 then
value101.Handle.Name = "Handle "
end
end

wait(0.2)

local function f81(p70, p71)
if p71 == nil == false then
local v203 = game.Players.LocalPlayer.Backpack["Chaos Couch" .. p70]
v203:FindFirstChild("Seat1").Disabled = true

local v204 = game.Players.LocalPlayer.Backpack["Chaos Couch" .. p70]
v204:FindFirstChild("Seat2").Disabled = true

game.Players.LocalPlayer.Backpack["Chaos Couch" .. p70].Parent = game.Players.LocalPlayer.Character
local v205 = game.Players.LocalPlayer.Character["Chaos Couch" .. p70]

tet = Instance.new(
"BodyVelocity", v205:FindFirstChild("Handle ")
)

tet.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

tet.P = 1250
tet.Velocity = Vector3.new(0, 0, 0)
tet.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"

repeat
local count8 = 0

while true do
count8 = 1 + count8

if not (count8 <= 35) then
break
end

local v206 = { x = 0, y = 0, z = 0 }
v206.x = p71.Character.HumanoidRootPart.Position.X
v206.y = p71.Character.HumanoidRootPart.Position.Y
v206.z = p71.Character.HumanoidRootPart.Position.Z

v206.x = v206.x
+ p71.Character.HumanoidRootPart.Velocity.X
/ 2

v206.y = v206.y
+ p71.Character.HumanoidRootPart.Velocity.Y
/ 2

v206.z = v206.z
+ p71.Character.HumanoidRootPart.Velocity.Z
/ 2

local v207 = game.Players.LocalPlayer.Character["Chaos Couch" .. p70]

v207:FindFirstChild("Seat1").CFrame = CFrame.new(Vector3.new(
v206.x, v206.y, v206.z
)) * CFrame.new(
-2, 2, 0
)

task.wait()
end

game.Players.LocalPlayer.Character["Chaos Couch" .. p70].Parent = game.Players.LocalPlayer.Backpack
wait()

local v208 = game.Players.LocalPlayer.Backpack["Chaos Couch" .. p70]
v208:FindFirstChild("Handle ").Name = "Handle"

wait(0.2)
game.Players.LocalPlayer.Backpack["Chaos Couch" .. p70].Parent = game.Players.LocalPlayer.Character
wait()

game.Players.LocalPlayer.Character["Chaos Couch" .. p70].Parent = game.Players.LocalPlayer.Backpack
game.Players.LocalPlayer.Backpack["Chaos Couch" .. p70].Handle.Name = "Handle "

wait(0.2)
game.Players.LocalPlayer.Backpack["Chaos Couch" .. p70].Parent = game.Players.LocalPlayer.Character
local v209 = game.Players.LocalPlayer.Character["Chaos Couch" .. p70]

tet = Instance.new(
"BodyVelocity", v209:FindFirstChild("Seat1")
)

tet.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

tet.P = 1250
tet.Velocity = Vector3.new(0, 0, 0)
tet.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"
until p71.Character.Humanoid.Sit == true

wait()

game.Players.LocalPlayer.Character["Chaos Couch" .. p70]:FindFirstChild("Handle "):FindFirstChild("#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"):Destroy()
game.Players.LocalPlayer.Character["Chaos Couch" .. p70].Parent = game.Players.LocalPlayer.Backpack

wait()

local v210 = game.Players.LocalPlayer.Backpack["Chaos Couch" .. p70]
v210:FindFirstChild("Handle ").Name = "Handle"

wait(0.2)
game.Players.LocalPlayer.Backpack["Chaos Couch" .. p70].Parent = game.Players.LocalPlayer.Character
wait()
game.Players.LocalPlayer.Character["Chaos Couch" .. p70].Parent = game.Players.LocalPlayer.Backpack
end
end

for key49, value102 in pairs(game.Players:GetPlayers()) do
local v211 = key49
local v212 = value102

if v212.Name == game.Players.LocalPlayer.Name == false then
spawn(function() f81(v211, v212) end)
end
end

task.delay(14, function()
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position5)
end)

task.delay(14.1, function()
replicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer(unpack(v199))
end)
end,
})

print("Kill All Couch button created")

trollPlayersTab:AddButton({
Name = "Fling Ball all",
Callback = function()
local localPlayer32 = players.LocalPlayer
local v213 = workspace.WorkspaceCom["001_SoccerBalls"]

local findFirstChild37 = v213:FindFirstChild("Soccer"
.. localPlayer32.Name)

if not findFirstChild37 then
if not localPlayer32.Backpack:FindFirstChild("SoccerBall") then
replicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(unpack({
[1] = "PickingTools",
[2] = "SoccerBall",
}))

task.wait()
localPlayer32.Backpack.SoccerBall.Parent = localPlayer32.Character

while true do
findFirstChild37 = v213:FindFirstChild("Soccer"
.. localPlayer32.Name)

task.wait()

if findFirstChild37 then
break
end
end

localPlayer32.Character.SoccerBall.Parent = localPlayer32.Backpack
task.wait()
else
localPlayer32.Backpack.SoccerBall.Parent = localPlayer32.Character

while true do
findFirstChild37 = v213:FindFirstChild("Soccer"
.. localPlayer32.Name)

task.wait()

if findFirstChild37 then
break
end
end

localPlayer32.Character.SoccerBall.Parent = localPlayer32.Backpack
end
end

local v214

for key50, value103 in pairs(game.Players:GetPlayers()) do
if value103 ~= game.Players.LocalPlayer then
local character41 = value103.Character

local v215 = character41
v215 = character41 or value103.CharacterAdded:Wait()

local v216 = not findFirstChild37
local humanoidRootPart42 = v215:WaitForChild("HumanoidRootPart")

if v216 or not humanoidRootPart42 then
return
end

for key51, value104 in pairs(findFirstChild37:GetChildren()) do
if value104:IsA("BodyMover") then
value104:Destroy()
end
end

local bodyVelocity2 = Instance.new("BodyVelocity")

bodyVelocity2.Velocity = Vector3.new(
900000000, 900000000, 900000000
)

bodyVelocity2.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

bodyVelocity2.P = 10000000000
bodyVelocity2.Parent = findFirstChild37

local bodyVelocity3 = Instance.new("BodyVelocity")

bodyVelocity3.Velocity = Vector3.new(
900000000, 900000000, 900000000
)

bodyVelocity3.MaxForce = Vector3.new(
math.huge, math.huge, math.huge
)

bodyVelocity3.P = 1000000000
bodyVelocity3.Parent = humanoidRootPart42

local position6 = humanoidRootPart42.Position
workspace.CurrentCamera.CameraSubject = humanoidRootPart42

repeat
local magnitude = humanoidRootPart42.Velocity.Magnitude
local v217 = {}

for key52, value105 in pairs(v215:GetDescendants()) do
if value105:IsA("BasePart")
and value105.CanCollide
and not value105.Anchored then
table.insert(v217, value105)
end
end

for index36, value106 in ipairs(v217) do
findFirstChild37.CFrame = CFrame.new(value103.Character.HumanoidRootPart.Position.X
+ value103.Character.HumanoidRootPart.Velocity.X
/ 1.5, value103.Character.HumanoidRootPart.Position.Y
+ value103.Character.HumanoidRootPart.Velocity.Y
/ 1.5, value103.Character.HumanoidRootPart.Position.Z
+ value103.Character.HumanoidRootPart.Velocity.Z
/ 1.5)

task.wait(0.00016666666666667)
end

task.wait(0.00016666666666667)

local v218 = humanoidRootPart42.Velocity.Magnitude
> 5000

v214 = v218

v214 = v218 or v215.Humanoid.Health == 0
or value103.Parent ~= game.Players
or humanoidRootPart42.Parent ~= v215
or v215 ~= value103.Character
until v214
end
end

local character42 = game.Players.LocalPlayer.Character
workspace.CurrentCamera.CameraSubject = character42:WaitForChild("HumanoidRootPart")
end,
})

local tab7 = window:MakeTab({ "Scripts Universais", "plane" })
]=====] },
        { "Houses", [=====[
casasTab = window:MakeTab({ Title = "Houses", Icon = "home" })
v53 = false
v54 = false
v55 = nil

v56 = {
Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0),
Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 0),
Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 0, 255),
}

function f15(p72)
v53 = p72

if p72 then
task.spawn(f35)
print("House RGB ativada")
else
print("House RGB desativada")
end
end

function f16()
local v223 = {}
local findFirstChild39 = v1:FindFirstChild("001_Lots")

if findFirstChild39 then
for index41, value121 in ipairs(findFirstChild39:GetChildren()) do
if value121:IsA("Model")
and value121.Name ~= "For Sale" then
table.insert(v223, value121.Name)
end
end
end

table.sort(v223)
return v223
end

function f35()
local re6 = replicatedStorage:FindFirstChild("RE")

if not re6 then
return
else
local findFirstChild40 = re6:FindFirstChild("1Player1sHous1e")

if not findFirstChild40 then
warn("RemoteEvent 1Player1sHous1e not found")
return
end

while v53 do
for index42, value122 in ipairs(v56) do
if not v53 then
return
end

findFirstChild40:FireServer(
"ColorPickHouse", value122
)

task.wait(0.8)
end
end

return
end
end

function f17()
if not v55 then
return nil
end

return v1["001_Lots"]:FindFirstChild(tostring(v55))
end

casasTab:AddSection({ Name = "Houses" })

selecionarCasaAddDropdown = nil

selecionarCasaAddDropdown = casasTab:AddDropdown({
Name = "Select House",
Options = f16(),
Callback = function(value123)
v55 = value123
print("Selected house:", value123)
end,
})

casasTab:AddButton({
Name = "Refresh House List",
Callback = function()
if not selecionarCasaAddDropdown then
return
end

v55 = nil
selecionarCasaAddDropdown:Set({})
task.wait(0.1)
selecionarCasaAddDropdown:Set(f16())
print("Lista de casas atualizada")
end,
})

casasTab:AddButton({
Name = "Teleport To House",
Callback = function()
local v224 = f17()
local character44 = localPlayer8.Character

if v224 and character44
and character44:FindFirstChild("HumanoidRootPart") then
character44.HumanoidRootPart.CFrame = CFrame.new(v224.WorldPivot.Position)
else
warn("Invalid or no house selected")
end
end,
})

casasTab:AddButton({
Name = "Teleport To Safe",
Callback = function()
local v225 = f17()
local character45 = localPlayer8.Character

if v225 and v225:FindFirstChild("HousePickedByPlayer")
and character45
and character45:FindFirstChild("HumanoidRootPart") then
local findFirstChild41 = v225.HousePickedByPlayer.HouseModel:FindFirstChild("001_Safe")

if findFirstChild41 then
character45.HumanoidRootPart.CFrame = CFrame.new(findFirstChild41.WorldPivot.Position)
else
warn("Safe not found:", v55)
end
else
warn("Invalid house:", v55)
end
end,
})

casasTab:AddToggle({
Name = "Go Through House Door",
Default = false,
Callback = function(value124)
local v226 = f17()

if not (v226 and v226:FindFirstChild("HousePickedByPlayer")) then
return
else
local findFirstChild42 = v226.HousePickedByPlayer.HouseModel:FindFirstChild("001_HouseDoors")

if findFirstChild42
and findFirstChild42:FindFirstChild("HouseDoorFront") then
for index43, value125 in ipairs(findFirstChild42.HouseDoorFront:GetChildren()) do
if value125:IsA("BasePart") then
value125.CanCollide = not value124
end
end
end

return
end
end,
})

casasTab:AddToggle({
Name = "Tocar Campainha",
Default = false,
Callback = function(value126)
getgenv().ChaosHubAutoSpawnDoorbellValue = value126

task.spawn(function()
while getgenv().ChaosHubAutoSpawnDoorbellValue do
local v227 = f17()

if v227
and v227:FindFirstChild("HousePickedByPlayer") then
local findFirstChild43 = v227.HousePickedByPlayer.HouseModel:FindFirstChild("001_DoorBell")

if findFirstChild43
and findFirstChild43:FindFirstChild("TouchBell") then
pcall(function()
fireclickdetector(findFirstChild43.TouchBell.ClickDetector)
end)
end
end

task.wait(0.5)
end
end)
end,
})

pcall(function()
casasTab:AddToggle({
Name = "Bater na Porta",
Description = "",
Default = false,
Callback = function(value127)
getgenv().ChaosHubAutoSpawnDoorValue = value127

task.spawn(function()
while getgenv().ChaosHubAutoSpawnDoorValue do
local findFirstChild44 = v1["001_Lots"]:FindFirstChild(tostring(v55))

if findFirstChild44
and findFirstChild44:FindFirstChild("HousePickedByPlayer") then
local findFirstChild45 = findFirstChild44.HousePickedByPlayer.HouseModel:FindFirstChild("001_HouseDoors")

if findFirstChild45
and findFirstChild45:FindFirstChild("HouseDoorFront")
and findFirstChild45.HouseDoorFront:FindFirstChild("Knock")
and findFirstChild45.HouseDoorFront.Knock:FindFirstChild("TouchBell") then
pcall(function()
fireclickdetector(findFirstChild45.HouseDoorFront.Knock.TouchBell.ClickDetector)
end)
end
end

task.wait(0.5)
end
end)
end,
})
end)

function f36()
while v54 do
pcall(function()
for index44, value128 in ipairs(v1["001_Lots"]:GetDescendants()) do
if value128.Name:match("^BannedBlock") then
value128:Destroy()
end
end
end)

task.wait(1)
end
end

casasTab:AddSection({ Name = "Auto Unban" })

casasTab:AddToggle({
Name = "Auto Unban",
Default = false,
Callback = function(value129)
v54 = value129

if value129 then
task.spawn(f36)
end
end,
})

casasTab:AddSection({ Name = "House RGB" })

casasTab:AddToggle({
Name = "House RGB",
Default = false,
Callback = function(value130) f15(value130) end,
})

localPlayer9 = game.Players.LocalPlayer

function f18()
v57 = {}

for key53, value131 in pairs(game.Players:GetPlayers()) do
table.insert(v57, value131.Name)
end

return v57
end

v57 = {}
f18()

]=====] },
        { "Client / ESP", [=====[
local tab14 = window:MakeTab({ "Cliente", "user" })
tab14:AddSection({ "Unban all houses" })

tab14:AddButton({
Name = "Remover Ban de Todas as Houses",
Description = "Tries to remove the ban from all houses",
Callback = function()
local count9 = 0
local count10 = 0
local count11 = 0

while true do
count11 = 1 + count11

if not (count11 <= 37) then
break
end

local findFirstChild49 = v1:FindFirstChild("BannedBlock"
.. count11, true)

if findFirstChild49 then
if pcall(function() findFirstChild49:Destroy() end) then
count9 = count9 + 1
else
count10 = count10 + 1
end
end
end

for key63, value161 in pairs(v1:GetDescendants()) do
local v274 = value161

if v274.Name:match("BannedBlock") then
if pcall(function() v274:Destroy() end) then
count9 = count9 + 1
else
count10 = count10 + 1
end
end
end

if count9 > 0 then
game.StarterGui:SetCore("SendNotification", {
Title = "Sucesso",
Text = "Bans removidos de " .. count9 .. " casas!",
Duration = 5,
})
end

if count10 > 0 then
game.StarterGui:SetCore("SendNotification", {
Title = "Warning",
Text = "Falha ao remover bans de " .. count10
.. " casas.",
Duration = 5,
})
end

if count9 == 0 and count10 == 0 then
game.StarterGui:SetCore("SendNotification", {
Title = "Warning",
Text = "No bans found to remove.",
Duration = 5,
})
end
end,
})

tab14:AddSection({ "ESPs" })

localPlayer10 = players.LocalPlayer
currentCamera3 = workspace.CurrentCamera

v72 = {
BoxESP = false,
TracerESP = false,
NameESP = false,
DistanceESP = false,
TeamCheck = false,
MaxDistance = 2000,
BoxColor = Color3.fromRGB(255, 255, 255),
TracerColor = Color3.fromRGB(255, 255, 255),
BoxThickness = 1.5,
TracerThickness = 1.5,
TextSize = 13,
}

v73 = {}

function f41(p83)
if p83 == localPlayer10 or v73[p83] then
return
elseif not Drawing then
warn("Your executor does not support the Drawing API.")
return
else
local v275 = {}
v275.Box = Drawing.new("Square")
v275.Box.Visible = false
v275.Box.Filled = false
v275.Box.Thickness = v72.BoxThickness
v275.Box.Color = v72.BoxColor
v275.Tracer = Drawing.new("Line")
v275.Tracer.Visible = false
v275.Tracer.Thickness = v72.TracerThickness
v275.Tracer.Color = v72.TracerColor
v275.Name = Drawing.new("Text")
v275.Name.Visible = false
v275.Name.Center = true
v275.Name.Outline = true
v275.Name.Size = v72.TextSize
v275.Name.Color = Color3.fromRGB(255, 255, 255)
v275.Distance = Drawing.new("Text")
v275.Distance.Visible = false
v275.Distance.Center = true
v275.Distance.Outline = true
v275.Distance.Size = 12
v275.Distance.Color = Color3.fromRGB(200, 200, 200)

v73[p83] = v275
return
end
end

local getPlayers2 = players.GetPlayers

function f23(p84)
local v276 = v73[p84]

if not v276 then
return
end

f42(v276)

for key64, value162 in pairs(v276) do
local v277 = value162
pcall(function() v277:Remove() end)
end

v73[p84] = nil
end

function f42(p85)
if not p85 then
return
end

if p85.Box then
p85.Box.Visible = false
end

if p85.Tracer then
p85.Tracer.Visible = false
end

if p85.Name then
p85.Name.Visible = false
end

if p85.Distance then
p85.Distance.Visible = false
end
end

function f24(p86, p87)
if not p87 then
return
end

local v278

if not v72.BoxESP and not v72.TracerESP
and not v72.NameESP and not v72.DistanceESP then
f42(p87)
return
else
local character46 = p86.Character

if not character46 then
f42(p87)
return
else
local humanoid36 = character46:FindFirstChildOfClass("Humanoid")
local humanoidRootPart45 = character46:FindFirstChild("HumanoidRootPart")
local v279 = not humanoid36
local head = character46:FindFirstChild("Head")

if v279 or not humanoidRootPart45
or humanoid36.Health <= 0 then
f42(p87)
return
end

if v72.TeamCheck and p86.Team and localPlayer10.Team
and p86.Team == localPlayer10.Team then
f42(p87)
return
else
local character47 = localPlayer10.Character

if not character47 then
f42(p87)
return
else
local humanoidRootPart46 = character47:FindFirstChild("HumanoidRootPart")

if not humanoidRootPart46 then
f42(p87)
return
else
local magnitude2 = (humanoidRootPart45.Position
- humanoidRootPart46.Position).Magnitude

if magnitude2 > v72.MaxDistance then
f42(p87)
return
else
local v280, v281 = currentCamera3:WorldToViewportPoint(humanoidRootPart45.Position)

if not v281 then
f42(p87)
return
else
if head then
v278 = head.Position
+ Vector3.new(0, 0.5, 0)
else
v278 = humanoidRootPart45.Position
+ Vector3.new(0, 3, 0)
end

local vector8 = Vector3.new(0, 3, 0)
local v282, v283 = currentCamera3:WorldToViewportPoint(v278)

local v284, v285 = currentCamera3:WorldToViewportPoint(humanoidRootPart45.Position
- vector8)

if not v283 or not v285 then
f42(p87)
return
else
local v286 = math.abs(v284.Y - v282.Y)
local v287 = v286 * 0.55

local vector9 = Vector2.new(v280.X
- v287 / 2, v282.Y)

if v72.BoxESP then
p87.Box.Visible = true
p87.Box.Position = vector9
p87.Box.Size = Vector2.new(v287, v286)
p87.Box.Color = v72.BoxColor
p87.Box.Thickness = v72.BoxThickness
else
p87.Box.Visible = false
end

if v72.TracerESP then
local viewportSize = currentCamera3.ViewportSize

p87.Tracer.Visible = true

p87.Tracer.From = Vector2.new(viewportSize.X
/ 2, viewportSize.Y)

p87.Tracer.To = Vector2.new(
v280.X, v284.Y
)

p87.Tracer.Color = v72.TracerColor
p87.Tracer.Thickness = v72.TracerThickness
else
p87.Tracer.Visible = false
end

if v72.NameESP then
p87.Name.Visible = true

p87.Name.Text = p86.DisplayName .. " (@"
.. p86.Name .. ")"

p87.Name.Position = Vector2.new(v280.X, v282.Y
- 18)
else
p87.Name.Visible = false
end

if v72.DistanceESP then
p87.Distance.Visible = true

p87.Distance.Text = string.format(
"[%dm]", magnitude2
)

p87.Distance.Position = Vector2.new(v280.X, v284.Y
+ 4)
else
p87.Distance.Visible = false
end

return
end
end
end
end
end
end
end
end
end

for index49, value163 in ipairs(getPlayers2(players)) do
f41(value163)
end

players.PlayerAdded:Connect(function(player2)
f41(player2)
end)

players.PlayerRemoving:Connect(function(player3)
f23(player3)
end)

connect = runService.RenderStepped:Connect(function()
for key65, value164 in pairs(v73) do
if key65.Parent then
f24(key65, value164)
else
f23(key65)
end
end
end)

local v288 = getgenv()

v288.FestivalESP = {
ToggleBox = function(p88) v72.BoxESP = p88 == true end,
ToggleTracer = function(p89)
v72.TracerESP = p89 == true
end,
ToggleName = function(p90) v72.NameESP = p90 == true end,
ToggleDistance = function(p91)
v72.DistanceESP = p91 == true
end,
ToggleTeamCheck = function(p92)
v72.TeamCheck = p92 == true
end,
SetColor = function(p93)
if typeof(p93) ~= "Color3" then
return
end

v72.BoxColor = p93
v72.TracerColor = p93
end,
SetMaxDistance = function(p94)
if typeof(p94) == "number" then
v72.MaxDistance = p94
end
end,
Destroy = function()
for key66 in pairs(v73) do
f23(key66)
end

if connect then
connect:Disconnect()
connect = nil
end

getgenv().FestivalESP = nil
end,
}

tab14:AddToggle({
Title = "Esp Box",
Default = false,
Callback = function(value165)
getgenv().FestivalESP.ToggleBox(value165)
end,
})

tab14:AddToggle({
Title = "Esp Tracer",
Default = false,
Callback = function(value166)
getgenv().FestivalESP.ToggleTracer(value166)
end,
})

tab14:AddToggle({
Title = "Esp Name",
Default = false,
Callback = function(value167)
getgenv().FestivalESP.ToggleName(value167)
end,
})

tab14:AddToggle({
Title = "Esp Distance",
Default = false,
Callback = function(value168)
getgenv().FestivalESP.ToggleDistance(value168)
end,
})

]=====] },
    }
    for _, m in ipairs(Modules) do
        task.spawn(function()
            local fn, err = loadstring(PROLOGUE .. m[2], "@Festival_" .. m[1])
            if not fn then warn("[Festival Hub] module '" .. m[1] .. "' failed to compile: " .. tostring(err)) return end
            local ok, e = pcall(fn)
            if not ok then warn("[Festival Hub] module '" .. m[1] .. "' error: " .. tostring(e)) end
        end)
        task.wait(0.15)
    end
end

-- ==================== UNIVERSAL ====================
local tabUni = window:MakeTab({"Universal", "rbxassetid://12285970187"})
tabUni:AddButton({Name="NINJA X ADMIN", Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Lindao10/Kxkckxkxkxkxkxkxlxllxkxkzlxlxx/refs/heads/main/NINJA%20X%20ADMIN.txt"))() end})
tabUni:AddButton({Name="Bring Part", Callback=function() loadstring(game:HttpGet("https://pastebin.com/raw/TihMhyyh"))() end})
tabUni:AddButton({Name="Fly Gui V3", Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))() end})
tabUni:AddButton({Name="Nameless Admin", Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source"))() end})
tabUni:AddButton({Name="Telekinesis", Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/SAZXHUB/Control-update/main/README.md",true))() end})
tabUni:AddButton({Name="TP Tool", Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/err0r129/KptHadesBlair/main/Bao.lua"))() end})

print("[Festival Hub] V7 by kutaydox LOADED | Role: "..GetRoleDisplay(LocalPlayer.Name).." | "..LocalPlayer.Name)
