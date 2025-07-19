local UILibrary = {}

local UIS = game:GetService("UserInputService")

function UILibrary:CreateWindow(titleText)
    local player = game:GetService("Players").LocalPlayer
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "CustomUI"
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 500, 0, 400)
    main.Position = UDim2.new(0.5, -250, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    main.BorderSizePixel = 1
    main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    main.Active = true
    main.Draggable = true

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(0, 120, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.4

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = titleText or "Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22

    -- Tabs
    local tabsHolder = Instance.new("Frame", main)
    tabsHolder.Size = UDim2.new(1, -16, 0, 30)
    tabsHolder.Position = UDim2.new(0, 8, 0, 40)
    tabsHolder.BackgroundTransparency = 1
    local tabLayout = Instance.new("UIListLayout", tabsHolder)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    local contentHolder = Instance.new("Frame", main)
    contentHolder.Position = UDim2.new(0, 0, 0, 70)
    contentHolder.Size = UDim2.new(1, 0, 1, -70)
    contentHolder.BackgroundTransparency = 1

    local tabs = {}

    -- Estilo botões externos
    local buttonFrame = Instance.new("Frame", gui)
    buttonFrame.Size = UDim2.new(0, 100, 0, 100)
    buttonFrame.Position = UDim2.new(0, 10, 0.5, -50)
    buttonFrame.BackgroundTransparency = 1

    local function styleSideButton(btn)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(0, 120, 255)
        btn.AutoButtonColor = true
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.ClipsDescendants = true
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end)
    end

    local showBtn = Instance.new("TextButton", buttonFrame)
    showBtn.Size = UDim2.new(1, 0, 0.5, -4)
    showBtn.Position = UDim2.new(0, 0, 0, 0)
    showBtn.Text = "Hide"
    styleSideButton(showBtn)

    local lockBtn = Instance.new("TextButton", buttonFrame)
    lockBtn.Size = UDim2.new(1, 0, 0.5, -4)
    lockBtn.Position = UDim2.new(0, 0, 0.5, 4)
    lockBtn.Text = "Unlocked"
    styleSideButton(lockBtn)

    local visible, locked = true, false
    showBtn.MouseButton1Click:Connect(function()
        visible = not visible
        main.Visible = visible
        showBtn.Text = visible and "Hide" or "Show"
    end)
    lockBtn.MouseButton1Click:Connect(function()
        locked = not locked
        main.Active = not locked
        lockBtn.Text = locked and "Locked" or "Unlocked"
    end)

    -- Criação de aba
    function UILibrary:CreateTab(name)
        local btn = Instance.new("TextButton", tabsHolder)
        btn.Size = UDim2.new(0, 100, 1, 0)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(0, 120, 255)
        btn.AutoButtonColor = true
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 15
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) end)

        local tabContent = Instance.new("Frame", contentHolder)
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Visible = false
        tabContent.BackgroundTransparency = 1

        local leftTitle = Instance.new("TextLabel", tabContent)
        leftTitle.Size = UDim2.new(0.5, -5, 0, 20)
        leftTitle.Position = UDim2.new(0, 0, 0, 0)
        leftTitle.Text = "Seção Esquerda"
        leftTitle.TextColor3 = Color3.new(1, 1, 1)
        leftTitle.BackgroundTransparency = 1
        leftTitle.Font = Enum.Font.GothamBold
        leftTitle.TextSize = 14

        local rightTitle = leftTitle:Clone()
        rightTitle.Parent = tabContent
        rightTitle.Position = UDim2.new(0.5, 5, 0, 0)
        rightTitle.Text = "Seção Direita"

        local leftScroll = Instance.new("ScrollingFrame", tabContent)
        leftScroll.Position = UDim2.new(0, 0, 0, 20)
        leftScroll.Size = UDim2.new(0.5, -5, 1, -20)
        leftScroll.CanvasSize = UDim2.new(0, 0, 5, 0)
        leftScroll.ScrollBarThickness = 4
        leftScroll.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        leftScroll.BorderSizePixel = 1
        leftScroll.BorderColor3 = Color3.fromRGB(0, 120, 255)

        local rightScroll = leftScroll:Clone()
        rightScroll.Parent = tabContent
        rightScroll.Position = UDim2.new(0.5, 5, 0, 20)

        local leftLayout = Instance.new("UIListLayout", leftScroll); leftLayout.Padding = UDim.new(0, 4)
        local rightLayout = Instance.new("UIListLayout", rightScroll); rightLayout.Padding = UDim.new(0, 4)

        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do t.Visible = false end
            tabContent.Visible = true
        end)
        table.insert(tabs, tabContent)

        local api = {}

        local function addHover(btn)
            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end)
        end

        function api:AddButton(text, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local b = Instance.new("TextButton", parent)
            b.Size = UDim2.new(1, -10, 0, 30); b.Text = text
            b.BackgroundColor3 = Color3.fromRGB(60, 60, 60); b.TextColor3 = Color3.new(1, 1, 1)
            b.BorderSizePixel = 1; b.BorderColor3 = Color3.fromRGB(0, 120, 255)
            b.AutoButtonColor = true; b.Font = Enum.Font.Gotham; b.TextSize = 14
            addHover(b); b.MouseButton1Click:Connect(callback)
        end

        function api:AddToggle(text, default, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local t = Instance.new("TextButton", parent)
            t.Size = UDim2.new(1, -10, 0, 30); t.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            t.TextColor3 = Color3.new(1, 1, 1); t.BorderSizePixel=1; t.BorderColor3=Color3.fromRGB(0,120,255)
            t.Font=Enum.Font.Gotham; t.TextSize=14
            local state = default or false
            local function update() t.Text = text..": "..(state and "ON" or "OFF") end
            update(); addHover(t)
            t.MouseButton1Click:Connect(function() state = not state; update(); callback(state) end)
        end

        function api:AddDropdown(text, options, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local d = Instance.new("TextButton", parent)
            d.Size = UDim2.new(1, -10, 0, 30); d.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            d.TextColor3 = Color3.new(1, 1, 1); d.Text = text
            d.BorderSizePixel=1; d.BorderColor3=Color3.fromRGB(0,120,255)
            d.Font=Enum.Font.Gotham; d.TextSize=14
            d.AutoButtonColor=true; addHover(d)

            local open = false
            local dropdowns = {}

            local function closeAll()
                for _, o in ipairs(dropdowns) do o:Destroy() end
                dropdowns = {} open = false
            end

            d.MouseButton1Click:Connect(function()
                if open then closeAll() return end
                for i,val in ipairs(options) do
                    local opt = Instance.new("TextButton", parent)
                    opt.Size = UDim2.new(1, -10, 0, 25); opt.Position = UDim2.new(0, 0, 0, 30*i)
                    opt.BackgroundColor3=Color3.fromRGB(40,40,40); opt.TextColor3=Color3.new(1,1,1)
                    opt.Text="› "..val; opt.BorderSizePixel=1; opt.BorderColor3=Color3.fromRGB(0,120,255)
                    opt.Font=Enum.Font.Gotham; opt.TextSize=14; opt.AutoButtonColor=true
                    addHover(opt)
                    opt.MouseButton1Click:Connect(function()
                        d.Text = text..": "..val
                        closeAll()
                        callback(val)
                    end)
                    table.insert(dropdowns,opt)
                end
                open = true
            end)
        end

        function api:AddDropdownToggle(text, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local dt = Instance.new("TextButton", parent)
            dt.Size=UDim2.new(1,-10,0,30); dt.BackgroundColor3=Color3.fromRGB(60,60,60)
            dt.TextColor3=Color3.new(1,1,1); local state=false
            dt.Text=text..": OFF"; dt.BorderSizePixel=1; dt.BorderColor3=Color3.fromRGB(0,120,255)
            dt.Font=Enum.Font.Gotham; dt.TextSize=14; dt.AutoButtonColor=true; addHover(dt)
            dt.MouseButton1Click:Connect(function() state = not state; dt.Text = text..": "..(state and "ON" or "OFF"); callback(state) end)
        end

        function api:AddSlider(text,min,max,default,callback,side)
            local parent = side=="Right" and rightScroll or leftScroll
            local holder = Instance.new("Frame", parent)
            holder.Size=UDim2.new(1,-10,0,50); holder.BackgroundTransparency=1
            local label = Instance.new("TextLabel", holder)
            label.Size=UDim2.new(1,0,0,20); label.Position=UDim2.new(0,0,0,0)
            label.BackgroundTransparency=1; label.TextColor3=Color3.new(1,1,1)
            label.Text=text..": "..tostring(default); label.Font=Enum.Font.Gotham; label.TextSize=14

            local bar = Instance.new("Frame", holder)
            bar.Size=UDim2.new(1,0,0,10); bar.Position=UDim2.new(0,0,0,30)
            bar.BackgroundColor3=Color3.fromRGB(70,70,70); bar.BorderSizePixel=1; bar.BorderColor3=Color3.fromRGB(0,120,255)
            bar.ClipsDescendants=true

            local fill = Instance.new("Frame", bar)
            fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3=Color3.fromRGB(0,120,255)

            local dragging=false
            local function update(x)
                local rel = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
                local pct = rel / bar.AbsoluteSize.X
                local val = math.floor(min + (max-min)*pct)
                fill.Size=UDim2.new(pct,0,1,0)
                label.Text=text..": "..val
                callback(val)
            end

            bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; update(i.Position.X) end end)
            bar.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then update(i.Position.X) end end)
            bar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
        end

        function api:AddCheckBox(text, default, callback, side)
            local parent = side=="Right" and rightScroll or leftScroll
            local holder = Instance.new("Frame", parent)
            holder.Size = UDim2.new(1,-10,0,30); holder.BackgroundTransparency=1

            local box = Instance.new("TextButton", holder)
            box.Size = UDim2.new(0, 24, 0, 24); box.Position = UDim2.new(0,0,0,3)
            box.BackgroundColor3 = Color3.fromRGB(60,60,60)
            box.BorderSizePixel = 1; box.BorderColor3 = Color3.fromRGB(0,120,255)
            box.AutoButtonColor = true

            local tick = Instance.new("Frame", box)
            tick.Size = default and UDim2.new(1,1,1,1) or UDim2.new(0,0,0,0)
            tick.BackgroundColor3 = Color3.fromRGB(0,120,255)

            local label = Instance.new("TextLabel", holder)
            label.Position = UDim2.new(0,30,0,0); label.Size = UDim2.new(1,-30,1,0)
            label.BackgroundTransparency = 1; label.Text = text
            label.TextColor3 = Color3.new(1,1,1); label.Font = Enum.Font.Gotham; label.TextSize = 14

            local state = default or false
            box.MouseButton1Click:Connect(function()
                state = not state
                tick.Size = state and UDim2.new(1,1,1,1) or UDim2.new(0,0,0,0)
                callback(state)
            end)
        end

        return api
    end

    return UILibrary
end

return UILibrary
