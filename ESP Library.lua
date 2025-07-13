-- File: esp_library.lua
local ESP = {}
ESP.__index = ESP

-- Configurações padrão
ESP.Settings = {
    Color = Color3.fromRGB(255, 255, 255),
    Thickness = 1,
    Box2D = true,
    Box3D = true,
    Tracer = true,
    Name = true,
    Distance = true,
    TracerOrigin = "Bottom", -- "Center" ou "Bottom"
}

ESP.Objects = {}

local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Função para criar nova ESP
function ESP.new(target, options)
    local self = setmetatable({}, ESP)
    self.Target = target
    self.Name = options.Name or target.Name
    self.Color = options.Color or ESP.Settings.Color
    self.Thickness = options.Thickness or ESP.Settings.Thickness
    self.Box2D = options.Box2D ~= nil and options.Box2D or ESP.Settings.Box2D
    self.Box3D = options.Box3D ~= nil and options.Box3D or ESP.Settings.Box3D
    self.Tracer = options.Tracer ~= nil and options.Tracer or ESP.Settings.Tracer
    self.ShowName = options.Name ~= nil and ESP.Settings.Name
    self.ShowDistance = options.Distance ~= nil and ESP.Settings.Distance

    -- Desenhos
    self.Drawings = {
        Tracer = Drawing.new("Line"),
        Box2D = Drawing.new("Square"),
        Box3D = Drawing.new("Quad"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }

    for _, drawing in pairs(self.Drawings) do
        drawing.Visible = false
        drawing.Color = self.Color
        if drawing.__type == "Text" then
            drawing.Size = 13
            drawing.Center = true
            drawing.Outline = true
        else
            drawing.Thickness = self.Thickness
        end
    end

    table.insert(ESP.Objects, self)
    return self
end

-- Atualizar ESP
function ESP:Update()
    if not self.Target or not self.Target:IsDescendantOf(workspace) then
        self:Remove()
        return
    end

    local pos, onScreen = camera:WorldToViewportPoint(self.Target.Position)
    if not onScreen then
        self:SetVisible(false)
        return
    end

    local distance = (camera.CFrame.Position - self.Target.Position).Magnitude

    -- Tracer
    if self.Tracer then
        local originY = (ESP.Settings.TracerOrigin == "Bottom") and camera.ViewportSize.Y or camera.ViewportSize.Y/2
        local tracer = self.Drawings.Tracer
        tracer.From = Vector2.new(camera.ViewportSize.X/2, originY)
        tracer.To = Vector2.new(pos.X, pos.Y)
        tracer.Visible = true
    else
        self.Drawings.Tracer.Visible = false
    end

    -- Name
    if self.ShowName then
        local nameTag = self.Drawings.Name
        nameTag.Text = self.Name
        nameTag.Position = Vector2.new(pos.X, pos.Y - 20)
        nameTag.Visible = true
    else
        self.Drawings.Name.Visible = false
    end

    -- Distance
    if self.ShowDistance then
        local distTag = self.Drawings.Distance
        distTag.Text = string.format("%.1f m", distance)
        distTag.Position = Vector2.new(pos.X, pos.Y + 20)
        distTag.Visible = true
    else
        self.Drawings.Distance.Visible = false
    end

    -- Box2D otimizada (agrupando múltiplas partes)
    if self.Box2D and self.Target:IsA("Model") then
        local parts = self.Target:GetDescendants()
        local points = {}

        for _, part in ipairs(parts) do
            if part:IsA("BasePart") then
                local cpos = camera:WorldToViewportPoint(part.Position)
                table.insert(points, Vector2.new(cpos.X, cpos.Y))
            end
        end

        if #points > 0 then
            local minX, minY, maxX, maxY = points[1].X, points[1].Y, points[1].X, points[1].Y
            for _, p in ipairs(points) do
                minX = math.min(minX, p.X)
                minY = math.min(minY, p.Y)
                maxX = math.max(maxX, p.X)
                maxY = math.max(maxY, p.Y)
            end
            local box = self.Drawings.Box2D
            box.Position = Vector2.new(minX, minY)
            box.Size = Vector2.new(maxX - minX, maxY - minY)
            box.Visible = true
        end
    else
        self.Drawings.Box2D.Visible = false
    end

    -- Box3D simplificada (desenha quad no centro)
    if self.Box3D then
        local size = self.Target.Size or Vector3.new(4,4,4)
        local cframe = self.Target.CFrame
        local points3D = {
            cframe * Vector3.new(size.X/2, size.Y/2, size.Z/2),
            cframe * Vector3.new(-size.X/2, size.Y/2, size.Z/2),
            cframe * Vector3.new(-size.X/2, -size.Y/2, size.Z/2),
            cframe * Vector3.new(size.X/2, -size.Y/2, size.Z/2),
        }
        local quad = self.Drawings.Box3D
        for i, point in ipairs(points3D) do
            local viewportPoint = camera:WorldToViewportPoint(point)
            quad["Point"..i] = Vector2.new(viewportPoint.X, viewportPoint.Y)
        end
        quad.Visible = true
    else
        self.Drawings.Box3D.Visible = false
    end
end

-- Remover ESP
function ESP:Remove()
    for _, drawing in pairs(self.Drawings) do
        drawing:Remove()
    end
    for i, obj in ipairs(ESP.Objects) do
        if obj == self then
            table.remove(ESP.Objects, i)
            break
        end
    end
end

-- Ocultar todos
function ESP:SetVisible(state)
    for _, drawing in pairs(self.Drawings) do
        drawing.Visible = state
    end
end

-- Loop para atualizar tudo
RunService.RenderStepped:Connect(function()
    for _, esp in ipairs(ESP.Objects) do
        esp:Update()
    end
end)

return ESP
