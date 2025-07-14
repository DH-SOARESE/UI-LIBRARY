local ESP = {}
ESP.__index = ESP

ESP.Objects = {}
ESP.Color = Color3.fromRGB(255, 255, 255)
ESP.TextSize = 14

ESP.EnableTracer = true
ESP.EnableBox = true
ESP.EnableName = true
ESP.EnableDistance = true

function ESP:Add(Object, CustomName)
    local DrawingTracer = Drawing.new("Line")
    DrawingTracer.Color = self.Color
    DrawingTracer.Thickness = 1
    DrawingTracer.Visible = false

    local DrawingBox = Drawing.new("Square")
    DrawingBox.Color = self.Color
    DrawingBox.Thickness = 1
    DrawingBox.Filled = false
    DrawingBox.Visible = false

    local DrawingName = Drawing.new("Text")
    DrawingName.Text = CustomName or Object.Name
    DrawingName.Color = self.Color
    DrawingName.Size = self.TextSize
    DrawingName.Center = true
    DrawingName.Outline = true
    DrawingName.Visible = false

    local DrawingDistance = Drawing.new("Text")
    DrawingDistance.Color = self.Color
    DrawingDistance.Size = self.TextSize
    DrawingDistance.Center = true
    DrawingDistance.Outline = true
    DrawingDistance.Visible = false

    table.insert(self.Objects, {
        Object = Object,
        Tracer = DrawingTracer,
        Box = DrawingBox,
        Name = DrawingName,
        Distance = DrawingDistance
    })
end

function ESP:Start()
    local camera = workspace.CurrentCamera
    local player = game.Players.LocalPlayer
    local runService = game:GetService("RunService")

    runService.RenderStepped:Connect(function()
        for i, v in ipairs(self.Objects) do
            local obj = v.Object
            if obj and obj.Parent then
                local pos, visible = camera:WorldToViewportPoint(obj.Position)
                if visible then
                    -- Tracer
                    if self.EnableTracer then
                        v.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        v.Tracer.To = Vector2.new(pos.X, pos.Y)
                        v.Tracer.Visible = true
                    else
                        v.Tracer.Visible = false
                    end

                    -- Box
                    if self.EnableBox then
                        v.Box.Position = Vector2.new(pos.X - 10, pos.Y - 10)
                        v.Box.Size = Vector2.new(20, 20)
                        v.Box.Visible = true
                    else
                        v.Box.Visible = false
                    end

                    -- Name
                    if self.EnableName then
                        v.Name.Position = Vector2.new(pos.X, pos.Y - 25)
                        v.Name.Visible = true
                    else
                        v.Name.Visible = false
                    end

                    -- Distance
                    if self.EnableDistance and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (player.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                        v.Distance.Text = string.format("%.0f m", distance)
                        v.Distance.Position = Vector2.new(pos.X, pos.Y)
                        v.Distance.Visible = true
                    else
                        v.Distance.Visible = false
                    end
                else
                    v.Tracer.Visible = false
                    v.Box.Visible = false
                    v.Name.Visible = false
                    v.Distance.Visible = false
                end
            else
                -- Se objeto não existir mais, remove
                v.Tracer:Remove()
                v.Box:Remove()
                v.Name:Remove()
                v.Distance:Remove()
                table.remove(self.Objects, i)
            end
        end
    end)
end

function ESP:SetColor(newColor)
    self.Color = newColor
end

function ESP.new(settings)
    local self = setmetatable({}, ESP)
    if settings then
        for k, v in pairs(settings) do
            self[k] = v
        end
    end
    return self
end

return ESP
