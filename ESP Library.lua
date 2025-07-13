--// ESP Library by ChatGPT
local ESP = {}
ESP.__index = ESP

function ESP.new()
    local self = setmetatable({}, ESP)
    self.objects = {} -- { obj = Instance, data = { drawings... } }
    self.tracerEnabled = true
    self.boxEnabled = true
    self.box3dEnabled = true
    self.nameEnabled = true
    self.distanceEnabled = true
    self.nameFunc = function(obj) return obj.Name end
    return self
end

function ESP:SetNameFunc(func)
    self.nameFunc = func
end

function ESP:AddObject(obj)
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return end
    local data = {
        tracer = Drawing.new("Line"),
        box = Drawing.new("Square"),
        box3d = Drawing.new("Square"),
        name = Drawing.new("Text"),
        distance = Drawing.new("Text"),
        obj = obj
    }
    data.tracer.Color = Color3.new(1,1,1)
    data.box.Color = Color3.new(1,1,1)
    data.box3d.Color = Color3.new(0,1,0)
    data.name.Color = Color3.new(1,1,0)
    data.distance.Color = Color3.new(1,1,1)
    data.name.Size = 16
    data.distance.Size = 14
    data.name.Center = true
    data.distance.Center = true
    data.box.Thickness = 2
    data.box.Filled = false
    data.box3d.Thickness = 1
    data.box3d.Filled = false
    self.objects[#self.objects+1] = data
end

function ESP:Clear()
    for _, data in ipairs(self.objects) do
        for _, draw in pairs(data) do
            if typeof(draw)=="Instance" and draw.Destroy then
                draw:Destroy()
            end
        end
    end
    self.objects = {}
end

local cam = workspace.CurrentCamera
game:GetService("RunService").RenderStepped:Connect(function()
    if not cam then cam = workspace.CurrentCamera return end
    for _, self in pairs({ESP}) do
        if type(self)=="table" and self.objects then
            for _, data in ipairs(self.objects) do
                local obj = data.obj
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
                        if self.tracerEnabled then
                            data.tracer.Visible = true
                            data.tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                            data.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        else
                            data.tracer.Visible = false
                        end

                        if self.boxEnabled then
                            data.box.Visible = true
                            data.box.Position = Vector2.new(screenPos.X - 20, screenPos.Y - 20)
                            data.box.Size = Vector2.new(40,40)
                        else
                            data.box.Visible = false
                        end

                        if self.box3dEnabled then
                            data.box3d.Visible = true
                            data.box3d.Position = Vector2.new(screenPos.X - 25, screenPos.Y - 25)
                            data.box3d.Size = Vector2.new(50,50)
                        else
                            data.box3d.Visible = false
                        end

                        if self.nameEnabled then
                            data.name.Visible = true
                            data.name.Text = self.nameFunc(obj)
                            data.name.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
                        else
                            data.name.Visible = false
                        end

                        if self.distanceEnabled then
                            data.distance.Visible = true
                            local dist = (cam.CFrame.Position - pos).Magnitude
                            data.distance.Text = string.format("%.0f m", dist)
                            data.distance.Position = Vector2.new(screenPos.X, screenPos.Y + 30)
                        else
                            data.distance.Visible = false
                        end
                    else
                        data.tracer.Visible = false
                        data.box.Visible = false
                        data.box3d.Visible = false
                        data.name.Visible = false
                        data.distance.Visible = false
                    end
                end
            end
        end
    end
end)

return ESP
