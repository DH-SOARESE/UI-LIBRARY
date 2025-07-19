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
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.ClipsDescendants = true
    main.AnchorPoint = Vector2.new(0.5, 0.5)

    -- Sombra suave atrás do frame principal
    local shadow = Instance.new("ImageLabel", gui)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = main.Position
    shadow.Size = main.Size + UDim2.new(0, 12, 0, 12)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217" -- sombra desfocada circular padrão Roblox
    shadow.ImageColor3 = Color3.new(0,0,0)
    shadow.ImageTransparency = 0.75
    shadow.ZIndex = main.ZIndex - 1

    -- Atualiza sombra junto com a janela ao mover
    main:GetPropertyChangedSignal("Position"):Connect(function()
        shadow.Position = main.Position
    end)

    -- Contorno azul elegante com UIStroke
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(0, 120, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = titleText or "Menu"
    title.TextColor3 = Color3.fromRGB(230, 230, 230)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextStrokeTransparency = 0.8
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Position = UDim2.new(0, 16, 0, 0)

    -- Tabs Holder
    local tabsHolder = Instance.new("Frame", main)
    tabsHolder.Size = UDim2.new(1, -32, 0, 36)
    tabsHolder.Position = UDim2.new(0, 16, 0, 44)
    tabsHolder.BackgroundTransparency = 1
    local tabLayout = Instance.new("UIListLayout", tabsHolder)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    local contentHolder = Instance.new("Frame", main)
    contentHolder.Position = UDim2.new(0, 16, 0, 84)
    contentHolder.Size = UDim2.new(1, -32, 1, -84)
    contentHolder.BackgroundTransparency = 1

    local tabs = {}

    -- Botões laterais (mostrar/ocultar e travar)
    local buttonFrame = Instance.new("Frame", gui)
    buttonFrame.Size = UDim2.new(0, 110, 0, 100)
    buttonFrame.Position = UDim2.new(0, 10, 0.5, -50)
    buttonFrame.BackgroundTransparency = 1

    local function styleSideButton(btn)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(0, 120, 255)
        btn.AutoButtonColor = true
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.ClipsDescendants = true
        btn.AnchorPoint = Vector2.new(0.5, 0.5)
        btn.BackgroundTransparency = 0.05

        -- Cantos arredondados
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 6)

        -- Sombra leve
        local shadow = Instance.new("UIStroke", btn)
        shadow.Color = Color3.fromRGB(0, 120, 255)
        shadow.Thickness = 1
        shadow.Transparency = 0.6

        btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0 end)
        btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 0.05 end)
    end

    local showBtn = Instance.new("TextButton", buttonFrame)
    showBtn.Size = UDim2.new(1, 0, 0.5, -6)
    showBtn.Position = UDim2.new(0, 0, 0, 0)
    showBtn.Text = "Hide"
    styleSideButton(showBtn)

    local lockBtn = Instance.new("TextButton", buttonFrame)
    lockBtn.Size = UDim2.new(1, 0, 0.5, -6)
    lockBtn.Position = UDim2.new(0, 0, 0.5, 6)
    lockBtn.Text = "Unlocked"
    styleSideButton(lockBtn)

    local visible, locked = true, false
    showBtn.MouseButton1Click:Connect(function()
        visible = not visible
        main.Visible = visible
        showBtn.Text = visible and "Hide" or "Show"
        shadow.Visible = visible
    end)
    lockBtn.MouseButton1Click:Connect(function()
        locked = not locked
        main.Active = not locked
        lockBtn.Text = locked and "Locked" or "Unlocked"
    end)

    -- Criação da aba
    function UILibrary:CreateTab(name)
        local btn = Instance.new("TextButton", tabsHolder)
        btn.Size = UDim2.new(0, 110, 1, 0)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = true
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16

        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 6)

        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) end)

        local tabContent = Instance.new("Frame", contentHolder)
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Visible = false
        tabContent.BackgroundTransparency = 1

        -- Títulos das seções com margem e estilo
        local leftTitle = Instance.new("TextLabel", tabContent)
        leftTitle.Size = UDim2.new(0.5, -12, 0, 24)
        leftTitle.Position = UDim2.new(0, 0, 0, 0)
        leftTitle.Text = "Seção Esquerda"
        leftTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
        leftTitle.BackgroundTransparency = 1
        leftTitle.Font = Enum.Font.GothamBold
        leftTitle.TextSize = 16
        leftTitle.TextXAlignment = Enum.TextXAlignment.Left
        leftTitle.TextStrokeTransparency = 0.9
        leftTitle.Position = UDim2.new(0, 12, 0, 0)

        local rightTitle = leftTitle:Clone()
        rightTitle.Parent = tabContent
        rightTitle.Position = UDim2.new(0.5, 12, 0, 0)
        rightTitle.Text = "Seção Direita"

        -- ScrollViews com margem lateral interna
        local leftScroll = Instance.new("ScrollingFrame", tabContent)
        leftScroll.Position = UDim2.new(0, 0, 0, 28)
        leftScroll.Size = UDim2.new(0.5, -14, 1, -28)
        leftScroll.CanvasSize = UDim2.new(0, 0, 5, 0)
        leftScroll.ScrollBarThickness = 6
        leftScroll.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
        leftScroll.BorderSizePixel = 0
        leftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local rightScroll = leftScroll:Clone()
        rightScroll.Parent = tabContent
        rightScroll.Position = UDim2.new(0.5, 14, 0, 28)

        local leftLayout = Instance.new("UIListLayout", leftScroll)
        leftLayout.Padding = UDim.new(0, 8)
        leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local rightLayout = Instance.new("UIListLayout", rightScroll)
        rightLayout.Padding = UDim.new(0, 8)
        rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                t.Visible = false
            end
            tabContent.Visible = true
        end)
        table.insert(tabs, tabContent)

        local api = {}

        -- Função padrão para hover suave
        local function addHover(btn)
            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            end)
        end

        local sideMargin = 12

        function api:AddButton(text, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local b = Instance.new("TextButton", parent)
            b.Size = UDim2.new(1, -2 * sideMargin, 0, 32)
            b.Position = UDim2.new(0, sideMargin, 0, 0)
            b.Text = text
            b.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            b.TextColor3 = Color3.fromRGB(230, 230, 230)
            b.BorderSizePixel = 0
            b.Font = Enum.Font.Gotham
            b.TextSize = 15
            b.AutoButtonColor = true

            local corner = Instance.new("UICorner", b)
            corner.CornerRadius = UDim.new(0, 6)

            addHover(b)
            b.MouseButton1Click:Connect(callback)
        end

        function api:AddToggle(text, default, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local t = Instance.new("TextButton", parent)
            t.Size = UDim2.new(1, -2 * sideMargin, 0, 32)
            t.Position = UDim2.new(0, sideMargin, 0, 0)
            t.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            t.TextColor3 = Color3.fromRGB(230, 230, 230)
            t.Font = Enum.Font.Gotham
            t.TextSize = 15
            t.BorderSizePixel = 0
            t.AutoButtonColor = true

            local corner = Instance.new("UICorner", t)
            corner.CornerRadius = UDim.new(0, 6)

            local state = default or false
            local function update()
                t.Text = text .. ": " .. (state and "ON" or "OFF")
            end
            update()
            addHover(t)
            t.MouseButton1Click:Connect(function()
                state = not state
                update()
                callback(state)
            end)
        end

        function api:AddDropdown(text, options, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local d = Instance.new("TextButton", parent)
            d.Size = UDim2.new(1, -2 * sideMargin, 0, 32)
            d.Position = UDim2.new(0, sideMargin, 0, 0)
            d.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            d.TextColor3 = Color3.fromRGB(230, 230, 230)
            d.Text = text
            d.Font = Enum.Font.Gotham
            d.TextSize = 15
            d.BorderSizePixel = 0
            d.AutoButtonColor = true

            local corner = Instance.new("UICorner", d)
            corner.CornerRadius = UDim.new(0, 6)

            addHover(d)

            local open = false
            local dropdowns = {}

            local function closeAll()
                for _, o in ipairs(dropdowns) do
                    o:Destroy()
                end
                dropdowns = {}
                open = false
            end

            d.MouseButton1Click:Connect(function()
                if open then
                    closeAll()
                    return
                end
                for i, val in ipairs(options) do
                    local opt = Instance.new("TextButton", parent)
                    opt.Size = UDim2.new(1, -2 * sideMargin, 0, 26)
                    opt.Position = UDim2.new(0, sideMargin, 0, 32 * i)
                    opt.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    opt.TextColor3 = Color3.fromRGB(230, 230, 230)
                    opt.Text = "› " .. val
                    opt.Font = Enum.Font.Gotham
                    opt.TextSize = 15
                    opt.BorderSizePixel = 0
                    opt.AutoButtonColor = true

                    local cornerOpt = Instance.new("UICorner", opt)
                    cornerOpt.CornerRadius = UDim.new(0, 6)

                    addHover(opt)

                    opt.MouseButton1Click:Connect(function()
                        d.Text = text .. ": " .. val
                        closeAll()
                        callback(val)
                    end)
                    table.insert(dropdowns, opt)
                end
                open = true
            end)
        end

        function api:AddDropdownToggle(text, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local dt = Instance.new("TextButton", parent)
            dt.Size = UDim2.new(1, -2 * sideMargin, 0, 32)
            dt.Position = UDim2.new(0, sideMargin, 0, 0)
            dt.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            dt.TextColor3 = Color3.fromRGB(230, 230, 230)
            local state = false
            dt.Text = text .. ": OFF"
            dt.Font = Enum.Font.Gotham
            dt.TextSize = 15
            dt.BorderSizePixel = 0
            dt.AutoButtonColor = true

            local corner = Instance.new("UICorner", dt)
            corner.CornerRadius = UDim.new(0, 6)

            addHover(dt)
            dt.MouseButton1Click:Connect(function()
                state = not state
                dt.Text = text .. ": " .. (state and "ON" or "OFF")
                callback(state)
            end)
        end

        function api:AddSlider(text, min, max, default, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local sideMargin = 12
            local holder = Instance.new("Frame", parent)
            holder.Size = UDim2.new(1, -2 * sideMargin, 0, 56)
            holder.Position = UDim2.new(0, sideMargin, 0, 0)
            holder.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", holder)
            label.Size = UDim2.new(1, 0, 0, 24)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(230, 230, 230)
            label.Text = text .. ": " .. tostring(default)
            label.Font = Enum.Font.Gotham
            label.TextSize = 15
            label.TextXAlignment = Enum.TextXAlignment.Left

            local bar = Instance.new("Frame", holder)
            bar.Size = UDim2.new(1, 0, 0, 12)
            bar.Position = UDim2.new(0, 0, 0, 32)
            bar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            bar.BorderSizePixel = 0
            bar.ClipsDescendants = true
            bar.AnchorPoint = Vector2.new(0, 0)

            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            fill.AnchorPoint = Vector2.new(0, 0)

            local dragging = false
            local function update(x)
                local rel = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
                local pct = rel / bar.AbsoluteSize.X
                local val = math.floor(min + (max - min) * pct)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                label.Text = text .. ": " .. val
                callback(val)
            end

            bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or
