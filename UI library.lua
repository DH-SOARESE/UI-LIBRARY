local UILibrary = {}

local UIS = game:GetService("UserInputService")

function UILibrary:CreateWindow(titleText)
    local player = game:GetService("Players").LocalPlayer
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "CustomUI"
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 540, 0, 420)
    main.Position = UDim2.new(0.5, -270, 0.5, -210)
    main.BackgroundColor3 = Color3.fromRGB(36, 38, 43)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true

    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(0, 120, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.2

    local shadow = Instance.new("ImageLabel", main)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageTransparency = 0.7
    shadow.ZIndex = 0

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 48)
    title.BackgroundTransparency = 1
    title.Text = titleText or "Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 2

    -- Tabs
    local tabsHolder = Instance.new("Frame", main)
    tabsHolder.Size = UDim2.new(1, -24, 0, 36)
    tabsHolder.Position = UDim2.new(0, 12, 0, 54)
    tabsHolder.BackgroundTransparency = 1
    tabsHolder.ZIndex = 2
    local tabLayout = Instance.new("UIListLayout", tabsHolder)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local contentHolder = Instance.new("Frame", main)
    contentHolder.Position = UDim2.new(0, 0, 0, 96)
    contentHolder.Size = UDim2.new(1, 0, 1, -96)
    contentHolder.BackgroundTransparency = 1
    contentHolder.ZIndex = 2

    local tabs = {}

    -- Botões externos (centralizados verticalmente à esquerda do menu)
    local buttonFrame = Instance.new("Frame", gui)
    buttonFrame.Size = UDim2.new(0, 54, 0, 120)
    buttonFrame.AnchorPoint = Vector2.new(0, 0.5)
    buttonFrame.Position = UDim2.new(0.5, -290, 0.5, 0) -- ao lado esquerdo do menu, central verticalmente
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.ZIndex = 10

    local buttonLayout = Instance.new("UIListLayout", buttonFrame)
    buttonLayout.FillDirection = Enum.FillDirection.Vertical
    buttonLayout.Padding = UDim.new(0, 12)
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local function styleSideButton(btn)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = true
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.Size = UDim2.new(1, 0, 0, 44)
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 8)
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end)
    end

    local showBtn = Instance.new("TextButton", buttonFrame)
    showBtn.Text = "Hide"
    styleSideButton(showBtn)

    local lockBtn = Instance.new("TextButton", buttonFrame)
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
        btn.Size = UDim2.new(0, 104, 1, 0)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = true
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 8)
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) end)

        local tabContent = Instance.new("Frame", contentHolder)
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Visible = false
        tabContent.BackgroundTransparency = 1
        tabContent.ZIndex = 3

        local leftTitle = Instance.new("TextLabel", tabContent)
        leftTitle.Size = UDim2.new(0.5, -10, 0, 24)
        leftTitle.Position = UDim2.new(0, 10, 0, 0)
        leftTitle.Text = "Seção Esquerda"
        leftTitle.TextColor3 = Color3.new(1, 1, 1)
        leftTitle.BackgroundTransparency = 1
        leftTitle.Font = Enum.Font.GothamBold
        leftTitle.TextSize = 15
        leftTitle.TextXAlignment = Enum.TextXAlignment.Left

        local rightTitle = leftTitle:Clone()
        rightTitle.Parent = tabContent
        rightTitle.Position = UDim2.new(0.5, 0, 0, 0)
        rightTitle.Text = "Seção Direita"
        rightTitle.TextXAlignment = Enum.TextXAlignment.Left

        local leftScroll = Instance.new("ScrollingFrame", tabContent)
        leftScroll.Position = UDim2.new(0, 10, 0, 28)
        leftScroll.Size = UDim2.new(0.5, -16, 1, -38)
        leftScroll.CanvasSize = UDim2.new(0, 0, 5, 0)
        leftScroll.ScrollBarThickness = 6
        leftScroll.BackgroundColor3 = Color3.fromRGB(40, 41, 47)
        leftScroll.BorderSizePixel = 0
        local leftCorner = Instance.new("UICorner", leftScroll)
        leftCorner.CornerRadius = UDim.new(0, 8)

        local rightScroll = leftScroll:Clone()
        rightScroll.Parent = tabContent
        rightScroll.Position = UDim2.new(0.5, 6, 0, 28)
        local rightCorner = Instance.new("UICorner", rightScroll)
        rightCorner.CornerRadius = UDim.new(0, 8)

        local leftLayout = Instance.new("UIListLayout", leftScroll); leftLayout.Padding = UDim.new(0, 6)
        local rightLayout = Instance.new("UIListLayout", rightScroll); rightLayout.Padding = UDim.new(0, 6)
        leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

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
            b.Size = UDim2.new(1, -10, 0, 36); b.Text = text
            b.BackgroundColor3 = Color3.fromRGB(60, 60, 60); b.TextColor3 = Color3.new(1, 1, 1)
            b.BorderSizePixel = 0; b.AutoButtonColor = true; b.Font = Enum.Font.Gotham; b.TextSize = 15
            local bCorner = Instance.new("UICorner", b); bCorner.CornerRadius = UDim.new(0, 8)
            addHover(b); b.MouseButton1Click:Connect(function()
                if typeof(callback) == "function" then
                    callback()
                end
            end)
        end

        function api:AddToggle(text, default, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local t = Instance.new("TextButton", parent)
            t.Size = UDim2.new(1, -10, 0, 36); t.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            t.TextColor3 = Color3.new(1, 1, 1); t.BorderSizePixel = 0
            t.Font = Enum.Font.Gotham; t.TextSize = 15
            local tCorner = Instance.new("UICorner", t); tCorner.CornerRadius = UDim.new(0, 8)
            local state = default or false
            local function update() t.Text = text .. ": " .. (state and "ON" or "OFF") end
            update(); addHover(t)
            t.MouseButton1Click:Connect(function()
                state = not state
                update()
                if typeof(callback) == "function" then
                    callback(state)
                end
            end)
        end

        function api:AddDropdown(text, options, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local d = Instance.new("TextButton", parent)
            d.Size = UDim2.new(1, -10, 0, 36); d.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            d.TextColor3 = Color3.new(1, 1, 1); d.Text = text
            d.BorderSizePixel = 0; d.Font = Enum.Font.Gotham; d.TextSize = 15
            d.AutoButtonColor = true; local dCorner = Instance.new("UICorner", d); dCorner.CornerRadius = UDim.new(0, 8)
            addHover(d)

            local open = false
            local dropdowns = {}

            local function closeAll()
                for _, o in ipairs(dropdowns) do o:Destroy() end
                dropdowns = {}; open = false
            end

            d.MouseButton1Click:Connect(function()
                if open then closeAll() return end
                for i, val in ipairs(options) do
                    local opt = Instance.new("TextButton", parent)
                    opt.Size = UDim2.new(1, -10, 0, 28); opt.Position = UDim2.new(0, 0, 0, 36 * i)
                    opt.BackgroundColor3 = Color3.fromRGB(40, 40, 40); opt.TextColor3 = Color3.new(1, 1, 1)
                    opt.Text = "› " .. val; opt.BorderSizePixel = 0
                    opt.Font = Enum.Font.Gotham; opt.TextSize = 15; opt.AutoButtonColor = true
                    local optCorner = Instance.new("UICorner", opt); optCorner.CornerRadius = UDim.new(0, 8)
                    addHover(opt)
                    opt.MouseButton1Click:Connect(function()
                        d.Text = text .. ": " .. val
                        closeAll()
                        if typeof(callback) == "function" then
                            callback(val)
                        end
                    end)
                    table.insert(dropdowns, opt)
                end
                open = true
            end)
        end

        function api:AddDropdownToggle(text, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local dt = Instance.new("TextButton", parent)
            dt.Size = UDim2.new(1, -10, 0, 36); dt.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            dt.TextColor3 = Color3.new(1, 1, 1); local state = false
            dt.Text = text .. ": OFF"; dt.BorderSizePixel = 0; dt.Font = Enum.Font.Gotham; dt.TextSize = 15
            dt.AutoButtonColor = true; local dtCorner = Instance.new("UICorner", dt); dtCorner.CornerRadius = UDim.new(0, 8)
            addHover(dt)
            dt.MouseButton1Click:Connect(function()
                state = not state
                dt.Text = text .. ": " .. (state and "ON" or "OFF")
                if typeof(callback) == "function" then
                    callback(state)
                end
            end)
        end

        function api:AddSlider(text, min, max, default, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local holder = Instance.new("Frame", parent)
            holder.Size = UDim2.new(1, -10, 0, 56); holder.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", holder)
            label.Size = UDim2.new(1, 0, 0, 20); label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1; label.TextColor3 = Color3.new(1, 1, 1)
            label.Text = text .. ": " .. tostring(default); label.Font = Enum.Font.Gotham; label.TextSize = 15

            local bar = Instance.new("Frame", holder)
            bar.Size = UDim2.new(1, 0, 0, 12); bar.Position = UDim2.new(0, 0, 0, 32)
            bar.BackgroundColor3 = Color3.fromRGB(70, 70, 70); bar.BorderSizePixel = 0
            local barCorner = Instance.new("UICorner", bar); barCorner.CornerRadius = UDim.new(0, 6)
            bar.ClipsDescendants = true

            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            local fillCorner = Instance.new("UICorner", fill); fillCorner.CornerRadius = UDim.new(0, 6)

            local dragging = false
            local function update(x)
                local rel = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
                local pct = rel / bar.AbsoluteSize.X
                local val = math.floor(min + (max - min) * pct)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                label.Text = text .. ": " .. val
                if typeof(callback) == "function" then
                    callback(val)
                end
            end

            bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(i.Position.X)
                end
            end)
            bar.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    update(i.Position.X)
                end
            end)
            bar.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end

        function api:AddCheckBox(text, default, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local holder = Instance.new("Frame", parent)
            holder.Size = UDim2.new(1, -10, 0, 36); holder.BackgroundTransparency = 1

            local box = Instance.new("TextButton", holder)
            box.Size = UDim2.new(0, 26, 0, 26); box.Position = UDim2.new(0, 0, 0, 5)
            box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            box.BorderSizePixel = 0; box.AutoButtonColor = true
            local boxCorner = Instance.new("UICorner", box); boxCorner.CornerRadius = UDim.new(0, 8)

            local tick = Instance.new("Frame", box)
            tick.Size = default and UDim2.new(1, -6, 1, -6) or UDim2.new(0, 0, 0, 0)
            tick.Position = default and UDim2.new(0, 3, 0, 3) or UDim2.new(0, 0, 0, 0)
            tick.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            local tickCorner = Instance.new("UICorner", tick); tickCorner.CornerRadius = UDim.new(0, 6)

            local label = Instance.new("TextLabel", holder)
            label.Position = UDim2.new(0, 34, 0, 0); label.Size = UDim2.new(1, -34, 1, 0)
            label.BackgroundTransparency = 1; label.Text = text
            label.TextColor3 = Color3.new(1, 1, 1); label.Font = Enum.Font.Gotham; label.TextSize = 15

            local state = default or false
            box.MouseButton1Click:Connect(function()
                state = not state
                tick.Size = state and UDim2.new(1, -6, 1, -6) or UDim2.new(0, 0, 0, 0)
                tick.Position = state and UDim2.new(0, 3, 0, 3) or UDim2.new(0, 0, 0, 0)
                if typeof(callback) == "function" then
                    callback(state)
                end
            end)
        end

        return api
    end

    return UILibrary
end

return UILibrary
