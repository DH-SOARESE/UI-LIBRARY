-- ESP Library (v1) by ChatGPT
local ESP = {}
ESP.__index = ESP

function ESP.new()
    local self = setmetatable({}, ESP)
    self.objects = {} -- {obj=Instance, drawings={}}
    self.enabled = {
        tracer = true,
        box = true,
        box3d = true,
        name = true,
        distance = true
    }
    self.nameFunc = function(obj) return obj.Name end
    self.updateConnection = nil
    self:StartUpdate()
    return self
end

function ESP:SetNameFunc(func)
    self.nameFunc = func
end

function ESP:AddObject(obj)
    local data = {
        obj = obj,
        tracer = Drawing.new("Line"),
        box = Drawing.new("Square"),
        box3d = Drawing.new("Square"),
        name = Drawing.new("Text"),
        distance = Drawing.new("Text"),
    }
    data.tracer.Color = Color3.new(1,1,1)
    data.tracer.Thickness = 1
    data.box.Color = Color3.new(1,1,1)
    data.box.Thickness = 2
    data.box.Filled = false
    data.box3d.Color = Color3.new(0,1,0)
    data.box3d.Thickness = 1
    data.box3d.Filled = false
    data.name.Color = Color3.new(1,1,0)
    data.name.Size = 16
    data.name.Center = true
    data.distance.Color = Color3.new(1,1,1)
    data.distance.Size = 14
    data.distance.Center = true

    table.insert(self.objects, data)
end

function ESP:Clear()
    for _, data in ipairs(self.objects) do
        for _, drawing in pairs(data) do
            if typeof(drawing) == "Instance" and drawing.Destroy then
                drawing:Destroy()
            end
        end
    end
    self.objects = {}
end

function ESP:StartUpdate()
    local cam = workspace.CurrentCamera
    self.updateConnection = game:GetService("RunService").RenderStepped:Connect(function()
        for _, data in ipairs(self.objects) do
            local obj = data.obj
            if obj and obj.Parent then
                local pos
                if obj:IsA("Model") then
                    local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if primary then pos = primary.Position end
                elseif obj:IsA("BasePart") then
                    pos = obj.Position
                end

                if pos then
                    local screenPos, onScreen = cam:WorldToViewportPoint(pos)
                    if onScreen then
                        -- Tracer
                        data.tracer.Visible = self.enabled.tracer
                        if data.tracer.Visible then
                            data.tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                            data.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        end

                        -- Box 2D
                        data.box.Visible = self.enabled.box
                        if data.box.Visible then
                            data.box.Size = Vector2.new(40,40)
                            data.box.Position = Vector2.new(screenPos.X - 20, screenPos.Y - 20)
                        end

                        -- Box 3D (fake, só outro quadrado maior)
                        data.box3d.Visible = self.enabled.box3d
                        if data.box3d.Visible then
                            data.box3d.Size = Vector2.new(60,60)
                            data.box3d.Position = Vector2.new(screenPos.X - 30, screenPos.Y - 30)
                        end

                        -- Name
                        data.name.Visible = self.enabled.name
                        if data.name.Visible then
                            data.name.Text = self.nameFunc(obj)
                            data.name.Position = Vector2.new(screenPos.X, screenPos.Y - 35)
                        end

                        -- Distance
                        data.distance.Visible = self.enabled.distance
                        if data.distance.Visible then
                            local dist = (cam.CFrame.Position - pos).Magnitude
                            data.distance.Text = string.format("%.0f m", dist)
                            data.distance.Position = Vector2.new(screenPos.X, screenPos.Y + 35)
                        end
                    else
                        data.tracer.Visible = false
                        data.box.Visible = false
                        data.box3d.Visible = false
                        data.name.Visible = false
                        data.distance.Visible = false
                    end
                end
            else
                -- Objeto não existe mais
                data.tracer.Visible = false
                data.box.Visible = false
                data.box3d.Visible = false
                data.name.Visible = false
                data.distance.Visible = false
            end
        end
    end)
end

return ESP
