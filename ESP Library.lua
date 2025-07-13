-- ESP Library (Orientada a Objetos) - Melhorada
-- Feito para ser hospedado no GitHub e usado via loadstring

local ESP = {}
ESP.__index = ESP

-- Lista global de instâncias ESP ativas
local instances = {}

-- Ativar/desativar ESP global
ESP.Enabled = true

-- Serviços
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Toggle global
function ESP.Toggle(value)
    ESP.Enabled = value
    for _, esp in ipairs(instances) do
        esp.Enabled = value
    end
end

-- Cria uma nova instância ESP
function ESP.New(target, displayName)
    local self = setmetatable({}, ESP)
    self.Target = target
    self.DisplayName = displayName or target.Name
    self.Enabled = ESP.Enabled

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

    -- Estilo
    self.Tracer.Color = Color3.fromRGB(255, 80, 80)
    self.Tracer.Thickness = 1

    self.Box2D.Color = Color3.fromRGB(80, 255, 80)
    self.Box2D.Thickness = 1

    self.Box3D.Color = Color3.fromRGB(80, 80, 255)
    self.Box3D.Thickness = 1

    self.NameText.Size = 14
    self.NameText.Center = true
    self.NameText.Outline = true
    self.NameText.Color = Color3.fromRGB(255, 255, 255)

    self.DistanceText.Size = 14
    self.DistanceText.Center = true
    self.DistanceText.Outline = true
    self.DistanceText.Color = Color3.fromRGB(255, 255, 100)

    table.insert(instances, self)

    return self
end

-- Atualiza uma única instância ESP
function ESP:Update()
    if not ESP.Enabled or not self.Enabled or not self.Target or not self.Target:IsDescendantOf(workspace) then
        self:Hide()
        return
    end

    local parts = {}
    if self.Target:IsA("Model") then
        for _, v in ipairs(self.Target:GetDescendants()) do
            if v:IsA("BasePart") then table.insert(parts, v) end
        end
    elseif self.Target:IsA("BasePart") then
        parts = { self.Target }
    end
    if #parts == 0 then self:Hide() return end

    -- Bounds
    local min, max
    for _, part in ipairs(parts) do
        local cf, size = part.CFrame, part.Size / 2
        local corners = {
            cf.Position + cf.RightVector*size.X + cf.UpVector*size.Y + cf.LookVector*size.Z,
            cf.Position - cf.RightVector*size.X + cf.UpVector*size.Y + cf.LookVector*size.Z,
            cf.Position + cf.RightVector*size.X - cf.UpVector*size.Y + cf.LookVector*size.Z,
            cf.Position + cf.RightVector*size.X + cf.UpVector*size.Y - cf.LookVector*size.Z,
            cf.Position - cf.RightVector*size.X - cf.UpVector*size.Y - cf.LookVector*size.Z,
            cf.Position + cf.RightVector*size.X - cf.UpVector*size.Y - cf.LookVector*size.Z,
            cf.Position - cf.RightVector*size.X + cf.UpVector*size.Y - cf.LookVector*size.Z,
            cf.Position - cf.RightVector*size.X - cf.UpVector*size.Y + cf.LookVector*size.Z,
        }
        for _, c in ipairs(corners) do
            min = min and Vector3.new(math.min(min.X, c.X), math.min(min.Y, c.Y), math.min(min.Z, c.Z)) or c
            max = max and Vector3.new(math.max(max.X, c.X), math.max(max.Y, c.Y), math.max(max.Z, c.Z)) or c
        end
    end

    local center = (min + max) / 2
    local screenPos, onScreen = Camera:WorldToViewportPoint(center)
    if not onScreen then self:Hide() return end

    local dist = (Camera.CFrame.Position - center).Magnitude

    -- Tracer
    self.Tracer.Visible = self.ShowTracer
    if self.Tracer.Visible then
        self.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        self.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
    end

    -- Box2D
    local topLeft = Camera:WorldToViewportPoint(Vector3.new(min.X, max.Y, min.Z))
    local bottomRight = Camera:WorldToViewportPoint(Vector3.new(max.X, min.Y, max.Z))
    self.Box2D.Visible = self.ShowBox2D
    if self.Box2D.Visible then
        self.Box2D.Position = Vector2.new(topLeft.X, topLeft.Y)
        self.Box2D.Size = Vector2.new(bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y)
    end

    -- Box3D (simplificado)
    self.Box3D.Visible = self.ShowBox3D
    if self.Box3D.Visible then
        local ftl = Camera:WorldToViewportPoint(Vector3.new(min.X, max.Y, max.Z))
        local ftr = Camera:WorldToViewportPoint(Vector3.new(max.X, max.Y, max.Z))
        local fbr = Camera:WorldToViewportPoint(Vector3.new(max.X, min.Y, max.Z))
        local fbl = Camera:WorldToViewportPoint(Vector3.new(min.X, min.Y, max.Z))
        self.Box3D.PointA = Vector2.new(ftl.X, ftl.Y)
        self.Box3D.PointB = Vector2.new(ftr.X, ftr.Y)
        self.Box3D.PointC = Vector2.new(fbr.X, fbr.Y)
        self.Box3D.PointD = Vector2.new(fbl.X, fbl.Y)
    end

    -- Name
    self.NameText.Visible = self.ShowName
    if self.NameText.Visible then
        self.NameText.Text = self.DisplayName
        self.NameText.Position = Vector2.new(screenPos.X, screenPos.Y - 16)
    end

    -- Distance
    self.DistanceText.Visible = self.ShowDistance
    if self.DistanceText.Visible then
        self.DistanceText.Text = string.format("%.1fm", dist)
        self.DistanceText.Position = Vector2.new(screenPos.X, screenPos.Y + 12)
    end
end

-- Esconde os elementos
function ESP:Hide()
    self.Tracer.Visible = false
    self.Box2D.Visible = false
    self.Box3D.Visible = false
    self.NameText.Visible = false
    self.DistanceText.Visible = false
end

-- Loop global
RunService.RenderStepped:Connect(function()
    for _, esp in ipairs(instances) do
        esp:Update()
    end
end)

return ESP
