--[[
ESP Library (Orientada a Objetos)
Projetada para Roblox exploits (executores como Delta) via loadstring
Oferece: Tracer, Box 2D, Box 3D, Nome, Distância
Agrupamento otimizado para objetos compostos
]]

local ESP = {}
ESP.__index = ESP

-- Serviços Roblox
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Camera = Workspace.CurrentCamera

-- Utilidades
local function WorldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function getBoundingBox(parts)
    local cf, size = nil, nil
    for _, p in ipairs(parts) do
        local bcf, bsize = p.CFrame, p.Size
        if not cf then
            cf = bcf
            size = bsize
        else
            local min = (cf.Position - size/2):min(bcf.Position - bsize/2)
            local max = (cf.Position + size/2):max(bcf.Position + bsize/2)
            cf = CFrame.new((min+max)/2)
            size = max-min
        end
    end
    return cf, size
end

-- Desenho (DrawingAPI, compatível com Delta e similares)
local Drawing = Drawing or getgenv().Drawing

-- ESPObject Class
local ESPObject = {}
ESPObject.__index = ESPObject

function ESPObject.new(obj, opts)
    local self = setmetatable({}, ESPObject)
    self.Object = obj
    self.Options = opts or {}
    self.Parts = {}
    self.GroupedParts = {}
    self.Name = opts.Name or obj.Name
    self.Color = opts.Color or Color3.new(1,1,0)
    self.TracerFrom = opts.TracerFrom or "Bottom" -- "Top", "Center"
    self:CollectParts()
    self:CreateDrawings()
    return self
end

function ESPObject:CollectParts()
    self.Parts = {}
    if self.Object:IsA("BasePart") then
        table.insert(self.Parts, self.Object)
    elseif self.Object:IsA("Model") then
        for _, v in ipairs(self.Object:GetDescendants()) do
            if v:IsA("BasePart") then
                table.insert(self.Parts, v)
            end
        end
    end
end

function ESPObject:CreateDrawings()
    -- Tracer
    self.Tracer = Drawing.new("Line")
    self.Tracer.Visible = false
    self.Tracer.Color = self.Color
    self.Tracer.Thickness = 2

    -- Box2D
    self.Box2D = {}
    for i=1,4 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = self.Color
        line.Thickness = 2
        self.Box2D[i] = line
    end

    -- Box3D
    self.Box3D = {}
    for i=1,12 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = self.Color
        line.Thickness = 1
        self.Box3D[i] = line
    end

    -- Name
    self.NameLabel = Drawing.new("Text")
    self.NameLabel.Visible = false
    self.NameLabel.Color = self.Color
    self.NameLabel.Size = 18
    self.NameLabel.Center = true
    self.NameLabel.Outline = true

    -- Distance
    self.DistanceLabel = Drawing.new("Text")
    self.DistanceLabel.Visible = false
    self.DistanceLabel.Color = Color3.new(1,1,1)
    self.DistanceLabel.Size = 16
    self.DistanceLabel.Center = true
    self.DistanceLabel.Outline = true
end

function ESPObject:UpdateDrawings()
    self:CollectParts()
    if #self.Parts == 0 then
        self:Hide()
        return
    end

    -- Agrupamento de partes para bounding box
    local cf, size = getBoundingBox(self.Parts)
    local corners = {}
    for x=-1,1,2 do
        for y=-1,1,2 do
            for z=-1,1,2 do
                table.insert(corners, (cf * CFrame.new(size.X/2*x, size.Y/2*y, size.Z/2*z)).Position)
            end
        end
    end

    -- 3D Box: 12 arestas
    local edges = {
        {1,2},{1,3},{1,5},
        {2,4},{2,6},
        {3,4},{3,7},
        {4,8},
        {5,6},{5,7},
        {6,8},
        {7,8}
    }
    for i, edge in ipairs(edges) do
        local p1, on1 = WorldToScreen(corners[edge[1]])
        local p2, on2 = WorldToScreen(corners[edge[2]])
        local line = self.Box3D[i]
        if on1 and on2 then
            line.Visible = true
            line.From = p1
            line.To = p2
            line.Color = self.Color
        else
            line.Visible = false
        end
    end

    -- 2D Box (Screen bounds)
    local min, max = Vector2.new(math.huge,math.huge), Vector2.new(-math.huge,-math.huge)
    local onscreen = false
    for _, pos in ipairs(corners) do
        local screen, on, _ = WorldToScreen(pos)
        if on then
            onscreen = true
            min = Vector2.new(math.min(min.X,screen.X), math.min(min.Y,screen.Y))
            max = Vector2.new(math.max(max.X,screen.X), math.max(max.Y,screen.Y))
        end
    end
    if onscreen then
        self.Box2D[1].From = Vector2.new(min.X, min.Y)
        self.Box2D[1].To = Vector2.new(max.X, min.Y)
        self.Box2D[2].From = Vector2.new(max.X, min.Y)
        self.Box2D[2].To = Vector2.new(max.X, max.Y)
        self.Box2D[3].From = Vector2.new(max.X, max.Y)
        self.Box2D[3].To = Vector2.new(min.X, max.Y)
        self.Box2D[4].From = Vector2.new(min.X, max.Y)
        self.Box2D[4].To = Vector2.new(min.X, min.Y)
        for i=1,4 do
            self.Box2D[i].Visible = true
            self.Box2D[i].Color = self.Color
        end
    else
        for i=1,4 do self.Box2D[i].Visible = false end
    end

    -- Tracer
    local tracerPos
    if self.TracerFrom == "Bottom" then
        tracerPos = Vector2.new((min.X+max.X)/2, max.Y)
    elseif self.TracerFrom == "Top" then
        tracerPos = Vector2.new((min.X+max.X)/2, min.Y)
    else
        tracerPos = Vector2.new((min.X+max.X)/2, (min.Y+max.Y)/2)
    end
    local screenSize = Camera.ViewportSize
    self.Tracer.From = Vector2.new(screenSize.X/2, screenSize.Y)
    self.Tracer.To = tracerPos
    self.Tracer.Color = self.Color
    self.Tracer.Visible = onscreen

    -- ESP Name
    self.NameLabel.Position = Vector2.new((min.X+max.X)/2, min.Y-20)
    self.NameLabel.Text = self.Name
    self.NameLabel.Visible = onscreen

    -- ESP Distance
    local char = Players.LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    if head then
        local dist = (cf.Position - head.Position).Magnitude
        self.DistanceLabel.Text = ("%dm"):format(math.floor(dist+0.5))
        self.DistanceLabel.Position = Vector2.new((min.X+max.X)/2, max.Y+5)
        self.DistanceLabel.Visible = onscreen
    else
        self.DistanceLabel.Visible = false
    end
end

function ESPObject:Hide()
    self.Tracer.Visible = false
    for _,v in ipairs(self.Box2D) do v.Visible = false end
    for _,v in ipairs(self.Box3D) do v.Visible = false end
    self.NameLabel.Visible = false
    self.DistanceLabel.Visible = false
end

function ESPObject:Remove()
    self:Hide()
    self.Tracer:Remove()
    for _,v in ipairs(self.Box2D) do v:Remove() end
    for _,v in ipairs(self.Box3D) do v:Remove() end
    self.NameLabel:Remove()
    self.DistanceLabel:Remove()
end

-- ESP Manager
function ESP.new()
    local self = setmetatable({}, ESP)
    self.Objects = {}
    self.Enabled = true
    self.Connection = RunService.RenderStepped:Connect(function()
        if self.Enabled then
            for k, obj in pairs(self.Objects) do
                obj:UpdateDrawings()
            end
        end
    end)
    return self
end

function ESP:Add(obj, opts)
    local espObj = ESPObject.new(obj, opts)
    self.Objects[obj] = espObj
    return espObj
end

function ESP:Remove(obj)
    if self.Objects[obj] then
        self.Objects[obj]:Remove()
        self.Objects[obj] = nil
    end
end

function ESP:Clear()
    for _, espObj in pairs(self.Objects) do
        espObj:Remove()
    end
    self.Objects = {}
end

function ESP:Destroy()
    self:Clear()
    if self.Connection then
        self.Connection:Disconnect()
    end
end

return ESP
