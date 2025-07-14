local ESP = {}
ESP.__index = ESP

ESP.Objects = {}
ESP.Settings = {
    EnableTracer = true,
    EnableBox = true,
    EnableName = true,
    EnableDistance = true,
    Color = Color3.fromRGB(255,255,255),
    TextSize = 14
}

-- Adiciona ESP em um objeto específico
function ESP:Add(Object, CustomName)
    table.insert(self.Objects, {
        Object = Object,
        Name = CustomName or Object.Name
    })
end

-- Cria tracer, box, textos etc.
function ESP:DrawAll()
    -- Drawing API requer exploit (Synapse, etc.)
    local drawings = {}
    for _, data in ipairs(self.Objects) do
        local obj = data.Object
        if obj and obj:IsA("BasePart") then
            -- Tracer
            local tracer
            if self.Settings.EnableTracer then
                tracer = Drawing.new("Line")
                tracer.Color = self.Settings.Color
                tracer.Thickness = 2
            end

            -- Box
            local box
            if self.Settings.EnableBox then
                box = Drawing.new("Square")
                box.Color = self.Settings.Color
                box.Thickness = 2
                box.Filled = false
                box.Size = Vector2.new(20,20)
            end

            -- Name
            local nameText
            if self.Settings.EnableName then
                nameText = Drawing.new("Text")
                nameText.Text = data.Name
                nameText.Color = self.Settings.Color
                nameText.Size = self.Settings.TextSize
                nameText.Center = true
            end

            -- Distance
            local distanceText
            if self.Settings.EnableDistance then
                distanceText = Drawing.new("Text")
                distanceText.Color = self.Settings.Color
                distanceText.Size = self.Settings.TextSize
                distanceText.Center = true
            end

            table.insert(drawings, {
                Object = obj,
                Tracer = tracer,
                Box = box,
                NameText = nameText,
                DistanceText = distanceText
            })
        end
    end
    return drawings
end

-- Atualiza posições e textos a cada frame
function ESP:Start()
    local camera = workspace.CurrentCamera
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local drawings = self:DrawAll()

    game:GetService("RunService").RenderStepped:Connect(function()
        for _, d in ipairs(drawings) do
            local obj = d.Object
            if obj and obj.Parent then
                local screenPos, onScreen = camera:WorldToViewportPoint(obj.Position)
                if onScreen then
                    -- Box
                    if d.Box then
                        d.Box.Position = Vector2.new(screenPos.X - 10, screenPos.Y - 10)
                        d.Box.Visible = true
                    end

                    -- Tracer
                    if d.Tracer then
                        d.Tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                        d.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        d.Tracer.Visible = true
                    end

                    -- Name
                    if d.NameText then
                        d.NameText.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
                        d.NameText.Visible = true
                    end

                    -- Distance
                    if d.DistanceText and hrp then
                        local distance = (hrp.Position - obj.Position).Magnitude
                        d.DistanceText.Text = string.format("%.0f m", distance)
                        d.DistanceText.Position = Vector2.new(screenPos.X, screenPos.Y)
                        d.DistanceText.Visible = true
                    end
                else
                    -- Se não estiver na tela, esconde tudo
                    if d.Box then d.Box.Visible = false end
                    if d.Tracer then d.Tracer.Visible = false end
                    if d.NameText then d.NameText.Visible = false end
                    if d.DistanceText then d.DistanceText.Visible = false end
                end
            end
        end
    end)
end

-- Cria novo ESP com configs customizadas
function ESP.new(Settings)
    local self = setmetatable({}, ESP)
    if Settings then
        for k,v in pairs(Settings) do
            self.Settings[k] = v
        end
    end
    return self
end

return ESP
