--[[
ESP Library (Orientada a Objetos)
Feito para ser hospedado no GitHub e usado via loadstring
]]--


local ESP = {}
ESP.__index = ESP

-- Lista global de instâncias ESP ativas
local instances = {}

-- Serviços
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Cria uma nova instância ESP
function ESP.New(target, displayName)
    local self = setmetatable({}, ESP)
    self.Target = target                -- Model, BasePart, etc
    self.DisplayName = displayName or target.Name
    self.Enabled = true

    self.ShowTracer = true
    self.ShowBox2D = true
    self.ShowBox3D = true
    self.ShowName = true
    self.ShowDistance = true

    -- Drawing objects
    self.Tracer = Drawing.new("Line")
    self.Box2D = Drawing.new("Square")
    self.Box3D = Drawing.new("Quad")
    self.NameText = Drawing.new("Text")
    self.DistanceText = Drawing.new("Text")

    -- Configura textos
    self.NameText.Size = 13
    self.NameText.Center = true
    self.NameText.Outline = true

    self.DistanceText.Size = 13
    self.DistanceText.Center = true
    self.DistanceText.Outline = true

    table.insert(instances, self)

    return self
end

-- Atualiza uma única instância ESP
function ESP:Update()
    if not self.Enabled or not self.Target or not self.Target:IsDescendantOf(workspace) then
        self:Hide()
        return
    end

    local parts = {}
    if self.Target:IsA("Model") then
        for _, v in ipairs(self.Target:GetDescendants()) do
            if v:IsA("BasePart") then
                table.insert(parts, v)
            end
        end
    elseif self.Target:IsA("BasePart") then
        parts = { self.Target }
    end

    if #parts == 0 then
        self:Hide()
        return
    end

    local min, max = nil, nil
    for _, part in ipairs(parts) do
        local cf, size = part.CFrame, part.Size
        local half = size / 2
        local corners = {
            cf.Position + (cf.RightVector * half.X) + (cf.UpVector * half.Y) + (cf.LookVector * half.Z),
            cf.Position - (cf.RightVector * half.X) + (cf.UpVector * half.Y) + (cf.LookVector * half.Z),
            cf.Position + (cf.RightVector * half.X) - (cf.UpVector * half.Y) + (cf.LookVector * half.Z),
            cf.Position + (cf.RightVector * half.X) + (cf.UpVector * half.Y) - (cf.LookVector * half.Z),
            cf.Position - (cf.RightVector * half.X) - (cf.UpVector * half.Y) - (cf.LookVector * half.Z),
            cf.Position + (cf.RightVector * half.X) - (cf.UpVector * half.Y) - (cf.LookVector * half.Z),
            cf.Position - (cf.RightVector * half.X) + (cf.UpVector * half.Y) - (cf.LookVector * half.Z),
            cf.Position - (cf.RightVector * half.X) - (cf.UpVector * half.Y) + (cf.LookVector * half.Z),
        }

        for _, corner in ipairs(corners) do
            if not min then
                min = corner
                max = corner
            else
                min = Vector3.new(math.min(min.X, corner.X), math.min(min.Y, corner.Y), math.min(min.Z, corner.Z))
                max = Vector3.new(math.max(max.X, corner.X), math.max(max.Y, corner.Y), math.max(max.Z, corner.Z))
            end
        end
    end

    -- Centro e distância
    local center = (min + max) / 2
    local screenPos, onScreen = Camera:WorldToViewportPoint(center)
    local distance = (Camera.CFrame.Position - center).Magnitude

    -- Tracer
    self.Tracer.Visible = self.ShowTracer and onScreen
    if self.Tracer.Visible then
        self.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        self.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
        self.Tracer.Color = Color3.fromRGB(255, 0, 0)
        self.Tracer.Thickness = 1
    end

    -- Box2D
    local topLeft, _ = Camera:WorldToViewportPoint(Vector3.new(min.X, max.Y, min.Z))
    local bottomRight, _ = Camera:WorldToViewportPoint(Vector3.new(max.X, min.Y, max.Z))
    self.Box2D.Visible = self.ShowBox2D and onScreen
    if self.Box2D.Visible then
        self.Box2D.Position = Vector2.new(topLeft.X, topLeft.Y)
        self.Box2D.Size = Vector2.new(bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y)
        self.Box2D.Color = Color3.fromRGB(0, 255, 0)
        self.Box2D.Thickness = 1
    end

    -- Name
    self.NameText.Visible = self.ShowName and onScreen
    if self.NameText.Visible then
        self.NameText.Text = self.DisplayName
        self.NameText.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
        self.NameText.Color = Color3.fromRGB(255, 255, 255)
    end

    -- Distance
    self.DistanceText.Visible = self.ShowDistance and onScreen
    if self.DistanceText.Visible then
        self.DistanceText.Text = string.format("%.1fm", distance)
        self.DistanceText.Position = Vector2.new(screenPos.X, screenPos.Y + 10)
        self.DistanceText.Color = Color3.fromRGB(255, 255, 0)
    end

    -- Box3D (simplificado: só desenha uma quad no plano frontal)
    self.Box3D.Visible = self.ShowBox3D and onScreen
    if self.Box3D.Visible then
        local frontTopLeft = Camera:WorldToViewportPoint(Vector3.new(min.X, max.Y, max.Z))
        local frontTopRight = Camera:WorldToViewportPoint(Vector3.new(max.X, max.Y, max.Z))
        local frontBottomLeft = Camera:WorldToViewportPoint(Vector3.new(min.X, min.Y, max.Z))
        local frontBottomRight = Camera:WorldToViewportPoint(Vector3.new(max.X, min.Y, max.Z))

        self.Box3D.PointA = Vector2.new(frontTopLeft.X, frontTopLeft.Y)
        self.Box3D.PointB = Vector2.new(frontTopRight.X, frontTopRight.Y)
        self.Box3D.PointC = Vector2.new(frontBottomRight.X, frontBottomRight.Y)
        self.Box3D.PointD = Vector2.new(frontBottomLeft.X, frontBottomLeft.Y)
        self.Box3D.Color = Color3.fromRGB(0, 0, 255)
        self.Box3D.Thickness = 1
    end
end

-- Esconde todos os elementos da ESP
function ESP:Hide()
    self.Tracer.Visible = false
    self.Box2D.Visible = false
    self.Box3D.Visible = false
    self.NameText.Visible = false
    self.DistanceText.Visible = false
end

-- Loop global para atualizar todas as instâncias
RunService.RenderStepped:Connect(function()
    for _, esp in ipairs(instances) do
        esp:Update()
    end
end)

return ESP

--[[ESP LIBRARY]]--
