--[[
    Notify Library
    Exemplo de uso:
    loadstring(game:HttpGet("URL_DO_SCRIPT"))()
    Notify({
        title = "Título da Notificação",
        description = "Descrição detalhada aqui...",
        image = "rbxassetid://123456789", -- opcional
        sound = "rbxassetid://987654321", -- opcional
        duration = 5 -- segundos (opcional)
    })
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local GuiService = game:GetService("GuiService")

if not getgenv then getgenv = function() return _G end end

local LIB_TAG = "__NOTIFY_LIB_SINGLETON_V1__"

if getgenv()[LIB_TAG] then
    return getgenv()[LIB_TAG]
end

local function Notify(options)
    options = options or {}
    local title = options.title or "Notificação"
    local description = options.description or ""
    local image = options.image or ""
    local soundId = options.sound or ""
    local duration = options.duration or 5

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NotifyLibrary"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    if syn and syn.protect_gui then pcall(syn.protect_gui, ScreenGui) end
    ScreenGui.Parent = game:GetService("CoreGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.AnchorPoint = Vector2.new(0.5, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.1, 0)
    MainFrame.Size = UDim2.new(0, 390, 0, 100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 8)

    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame

    -- Imagem
    local Image = Instance.new("ImageLabel")
    Image.Name = "NotifyImage"
    Image.BackgroundTransparency = 1
    Image.Size = UDim2.new(0, 64, 0, 64)
    Image.Position = UDim2.new(0, 16, 0.5, -32)
    Image.Image = image ~= "" and image or "rbxassetid://7733960981" -- imagem padrão
    Image.Parent = MainFrame

    -- Título
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = title
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.TextSize = 20
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -110, 0, 28)
    Title.Position = UDim2.new(0, 90, 0, 18)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = MainFrame

    -- Descrição
    local Desc = Instance.new("TextLabel")
    Desc.Name = "Description"
    Desc.Text = description
    Desc.Font = Enum.Font.Gotham
    Desc.TextColor3 = Color3.fromRGB(200,200,200)
    Desc.TextSize = 16
    Desc.BackgroundTransparency = 1
    Desc.Size = UDim2.new(1, -110, 0, 44)
    Desc.Position = UDim2.new(0, 90, 0, 46)
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.TextYAlignment = Enum.TextYAlignment.Top
    Desc.TextWrapped = true
    Desc.Parent = MainFrame

    -- Botão Fechar
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBlack
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 26
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -38, 0, 0)
    CloseBtn.ZIndex = 2
    CloseBtn.Parent = MainFrame

    -- Som
    local Sound
    if soundId ~= "" then
        Sound = Instance.new("Sound")
        Sound.SoundId = soundId
        Sound.Volume = 1
        Sound.Parent = MainFrame
        pcall(function()
            Sound:Play()
        end)
    end

    -- Animação de entrada
    MainFrame.Position = UDim2.new(0.5, 0, 0, -120)
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.1, 0)
    }):Play()

    -- Fechar função
    local function CloseNotify()
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 0, -120)
        }):Play()
        task.wait(0.32)
        if Sound then
            Sound:Destroy()
        end
        ScreenGui:Destroy()
    end

    CloseBtn.MouseButton1Click:Connect(CloseNotify)
    -- Fechar após duration
    task.spawn(function()
        if duration > 0 then
            task.wait(duration)
            pcall(CloseNotify)
        end
    end)
end

getgenv()[LIB_TAG] = Notify
return Notify
