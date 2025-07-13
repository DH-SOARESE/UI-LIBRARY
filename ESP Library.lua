-- ESP Library
local ESP = {}
ESP.__index = ESP

-- Configuração padrão (pode ser customizada)
ESP.Settings = {
    Tracer = true,
    Box2D = true,
    Box3D = true,
    ShowName = true,
    ShowDistance = true,
    NameFromLoadstring = loadstring("return 'Objeto'")() -- Altere isso se quiser
}

ESP.Instances = {} -- Guardar todos os Drawing criados

-- Função para criar um objeto ESP para um target específico
function ESP.new(target)
    local self = setmetatable({}, ESP)
    self.Target = target
    self:CreateDrawings()
    table.insert(ESP.Instances, self)
    return self
end

-- Cria os desenhos (tracer, box, nome, distância)
function ESP:CreateDrawings()
    self.Tracer = Drawing.new("Line")
    self.Box2D = Drawing.new("Square")
    self.Box3D = Drawing.new("Quad")
    self.NameText = Drawing.new("Text")
    self.DistanceText = Drawing.new("Text")

    -- Configuração visual
    self.Tracer.Color = Color3.fromRGB(255, 0, 0)
    self.Tracer.Thickness = 1

    self.Box2D.Color = Color3.fromRGB(0, 255, 0)
    self.Box2D.Thickness = 1
    self.Box2D.Filled = false

    self.Box3D.Color = Color3.fromRGB(0, 0, 255)
    self.Box3D.Thickness = 1
    self.Box3D.Filled = false

    self.NameText.Color = Color3.fromRGB(255, 255, 255)
    self.NameText.Size = 13
    self.NameText.Center = true
    self.NameText.Outline = true

    self.DistanceText.Color = Color3.fromRGB(255, 255, 0)
    self.DistanceText.Size = 13
    self.DistanceText.Center = true
    self.DistanceText.Outline = true
end

-- Atualiza a posição e visibilidade dos ESPs
function ESP:Update(camera)
    if not self.Target or not self.Target.Parent then return end

    local cf, size = self.Target:GetBoundingBox()
    local pos, onscreen = camera:WorldToViewportPoint(cf.Position)

    if onscreen then
        -- Tracer
        if ESP.Settings.Tracer then
            self.Tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
            self.Tracer.To = Vector2.new(pos.X, pos.Y)
            self.Tracer.Visible = true
        else
            self.Tracer.Visible = false
        end

        -- Box2D (simplificado)
        if ESP.Settings.Box2D then
            self.Box2D.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
            self.Box2D.Size = Vector2.new(size.X, size.Y)
            self.Box2D.Visible = true
        else
            self.Box2D.Visible = false
        end

        -- Box3D (simplificado em 2D)
        if ESP.Settings.Box3D then
            -- Desenhar um Quad (exemplo simples, use projeção real para ser exato)
            local halfSize = size / 2
            local corners = {
                cf.Position + cf.RightVector * halfSize.X + cf.UpVector * halfSize.Y,
                cf.Position - cf.RightVector * halfSize.X + cf.UpVector * halfSize.Y,
                cf.Position - cf.RightVector * halfSize.X - cf.UpVector * halfSize.Y,
                cf.Position + cf.RightVector * halfSize.X - cf.UpVector * halfSize.Y,
            }
            for i, corner in ipairs(corners) do
                local screen, vis = camera:WorldToViewportPoint(corner)
                corners[i] = Vector2.new(screen.X, screen.Y)
            end
            self.Box3D.PointA = corners[1]
            self.Box3D.PointB = corners[2]
            self.Box3D.PointC = corners[3]
            self.Box3D.PointD = corners[4]
            self.Box3D.Visible = true
        else
            self.Box3D.Visible = false
        end

        -- Nome
        if ESP.Settings.ShowName then
            self.NameText.Text = ESP.Settings.NameFromLoadstring
            self.NameText.Position = Vector2.new(pos.X, pos.Y - 20)
            self.NameText.Visible = true
        else
            self.NameText.Visible = false
        end

        -- Distância
        if ESP.Settings.ShowDistance then
            local distance = (camera.CFrame.Position - cf.Position).Magnitude
            self.DistanceText.Text = string.format("%.1f m", distance)
            self.DistanceText.Position = Vector2.new(pos.X, pos.Y + 20)
            self.DistanceText.Visible = true
        else
            self.DistanceText.Visible = false
        end
    else
        self.Tracer.Visible = false
        self.Box2D.Visible = false
        self.Box3D.Visible = false
        self.NameText.Visible = false
        self.DistanceText.Visible = false
    end
end

-- Loop para atualizar todos os ESPs
task.spawn(function()
    local camera = workspace.CurrentCamera
    while true do
        for _, esp in ipairs(ESP.Instances) do
            esp:Update(camera)
        end
        task.wait()
    end
end)

-- Exemplo de uso:
local objects = { -- Substitua pelos endereços reais dos objetos
    workspace.Part,
    -- workspace.CurrentRooms["n"].Parts:GetChildren()[1], etc.
}

for _, obj in ipairs(objects) do
    ESP.new(obj)
end

return ESP
