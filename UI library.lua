-- UILibrary.lua
-- Corrigido, melhorado, com organização, comentários e boas práticas.

local UILibrary = {}

local UIS = game:GetService("UserInputService")

-- Cria a janela principal do UI
function UILibrary:CreateWindow(titleText)
    local player = game:GetService("Players").LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "CustomUI"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 540, 0, 420)
    main.Position = UDim2.new(0.5, -270, 0.5, -210)
    main.BackgroundColor3 = Color3.fromRGB(36, 38, 43)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main

    -- Aumentei a espessura e ajustei a cor para um destaque mais vibrante
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 150, 255) -- Cor mais vibrante
    stroke.Thickness = 3 -- Aumentei a espessura
    stroke.Transparency = 0.1 -- Levemente menos transparente
    stroke.Parent = main

    -- A sombra ("aranha") foi ajustada para ser um pouco mais sutil
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 40, 1, 40) -- Levemente maior para um efeito mais espalhado
    shadow.Position = UDim2.new(0, -20, 0, -20) -- Ajuste de posição
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageTransparency = 0.8 -- Mais transparente para ser mais sutil
    shadow.ZIndex = 0
    shadow.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 48)
    title.BackgroundTransparency = 1
    title.Text = titleText or "Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 2
    title.Parent = main

    -- Tabs holder
    local tabsHolder = Instance.new("Frame")
    tabsHolder.Size = UDim2.new(1, -24, 0, 36)
    tabsHolder.Position = UDim2.new(0, 12, 0, 54)
    tabsHolder.BackgroundTransparency = 1
    tabsHolder.ZIndex = 2
    tabsHolder.Parent = main

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = tabsHolder

    -- Conteúdo das abas
    local contentHolder = Instance.new("Frame")
    contentHolder.Position = UDim2.new(0, 0, 0, 96)
    contentHolder.Size = UDim2.new(1, 0, 1, -96)
    contentHolder.BackgroundTransparency = 1
    contentHolder.ZIndex = 2
    contentHolder.Parent = main

    local tabs = {}
    local activeTabButton = nil

    -- Botões laterais externos (esquerda)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(0, 54, 0, 120)
    buttonFrame.AnchorPoint = Vector2.new(0, 0.5)
    buttonFrame.Position = UDim2.new(0, 10, 0.5, 0) -- lado esquerdo, centralizado verticalmente
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.ZIndex = 10
    buttonFrame.Parent = gui

    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Vertical
    buttonLayout.Padding = UDim.new(0, 12)
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    buttonLayout.Parent = buttonFrame

    local function styleSideButton(btn)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false -- Desativar AutoButtonColor para controle total do hover
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.Size = UDim2.new(1, 0, 0, 44)
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end)
    end

    local showBtn = Instance.new("TextButton")
    showBtn.Text = "Hide"
    styleSideButton(showBtn)
    showBtn.Parent = buttonFrame

    local lockBtn = Instance.new("TextButton")
    lockBtn.Text = "Unlocked" -- Texto inicial correto
    styleSideButton(lockBtn)
    lockBtn.Parent = buttonFrame

    local visible, locked = true, false
    showBtn.MouseButton1Click:Connect(function()
        visible = not visible
        main.Visible = visible
        showBtn.Text = visible and "Hide" or "Show"
    end)
    lockBtn.MouseButton1Click:Connect(function()
        locked = not locked
        main.Active = not locked
        main.Draggable = not locked -- Desativa o arrastar se estiver travado
        lockBtn.Text = locked and "Locked" or "Unlocked"
    end)

    -- Criação de aba
    function UILibrary:CreateTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 104, 1, 0)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Cor de fundo padrão da aba
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false -- Desativar AutoButtonColor para controle total do hover
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        local btnStroke = Instance.new("UIStroke") -- Adiciona um stroke para destaque
        btnStroke.Color = Color3.fromRGB(0, 120, 255)
        btnStroke.Thickness = 0
        btnStroke.Transparency = 1
        btnStroke.Parent = btn

        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65) end)
        btn.MouseLeave:Connect(function()
            if btn ~= activeTabButton then
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            end
        end)
        btn.Parent = tabsHolder

        local tabContent = Instance.new("Frame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Visible = false
        tabContent.BackgroundTransparency = 1
        tabContent.ZIndex = 3
        tabContent.Parent = contentHolder

        -- Títulos das colunas (features) - Alinhados à esquerda e com mais padding
        local leftTitle = Instance.new("TextLabel")
        leftTitle.Size = UDim2.new(0.5, -15, 0, 24) -- Ajustei o tamanho e padding
        leftTitle.Position = UDim2.new(0, 15, 0, 0) -- Ajustei a posição
        leftTitle.Text = "Features (Left)" -- Texto descritivo
        leftTitle.TextColor3 = Color3.new(1, 1, 1)
        leftTitle.BackgroundTransparency = 1
        leftTitle.Font = Enum.Font.GothamBold
        leftTitle.TextSize = 15
        leftTitle.TextXAlignment = Enum.TextXAlignment.Left
        leftTitle.Parent = tabContent

        local rightTitle = leftTitle:Clone()
        rightTitle.Parent = tabContent
        rightTitle.Position = UDim2.new(0.5, 10, 0, 0) -- Ajustei a posição para o lado direito
        rightTitle.Text = "Features (Right)" -- Texto descritivo
        rightTitle.TextXAlignment = Enum.TextXAlignment.Left

        local leftScroll = Instance.new("ScrollingFrame")
        leftScroll.Position = UDim2.new(0, 10, 0, 28)
        leftScroll.Size = UDim2.new(0.5, -16, 1, -38)
        leftScroll.CanvasSize = UDim2.new(0, 0, 0, 0) -- CanvasSize será ajustado pelo UIListLayout
        leftScroll.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y -- Ajusta automaticamente o CanvasSize na direção Y
        leftScroll.ScrollBarThickness = 6
        leftScroll.BackgroundColor3 = Color3.fromRGB(40, 41, 47)
        leftScroll.BorderSizePixel = 0
        leftScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 255) -- Cor da scrollbar
        leftScroll.Parent = tabContent
        local leftCorner = Instance.new("UICorner")
        leftCorner.CornerRadius = UDim.new(0, 8)
        leftCorner.Parent = leftScroll

        local rightScroll = leftScroll:Clone()
        rightScroll.Parent = tabContent
        rightScroll.Position = UDim2.new(0.5, 6, 0, 28)
        local rightCorner = Instance.new("UICorner")
        rightCorner.CornerRadius = UDim.new(0, 8)
        rightCorner.Parent = rightScroll
        rightScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 255)

        local leftLayout = Instance.new("UIListLayout")
        leftLayout.Padding = UDim.new(0, 6)
        leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        leftLayout.Parent = leftScroll

        local rightLayout = Instance.new("UIListLayout")
        rightLayout.Padding = UDim.new(0, 6)
        rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        rightLayout.Parent = rightScroll

        btn.MouseButton1Click:Connect(function()
            -- Desativa o stroke do botão ativo anterior
            if activeTabButton then
                activeTabButton.UIStroke.Thickness = 0
                activeTabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            end

            for _, t in pairs(tabs) do t.Visible = false end
            tabContent.Visible = true

            -- Ativa o stroke para o botão da aba clicada
            btnStroke.Thickness = 2
            btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65) -- Cor de fundo para a aba ativa
            activeTabButton = btn
        end)
        table.insert(tabs, tabContent)

        -- Ativa a primeira aba por padrão
        if #tabs == 1 then
            btn.MouseButton1Click:Fire()
        end

        local api = {}

        local function addHover(control)
            local originalColor = control.BackgroundColor3
            control.MouseEnter:Connect(function()
                if control.Name ~= "ToggleState" then -- Evita mudar cor do toggle
                    control.BackgroundColor3 = control.BackgroundColor3:Lerp(Color3.new(1,1,1), 0.1) -- Clareia um pouco
                end
            end)
            control.MouseLeave:Connect(function()
                if control.Name ~= "ToggleState" then
                    control.BackgroundColor3 = originalColor
                end
            end)
        end

        function api:AddButton(text, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -20, 0, 36) -- Aumentei o padding horizontal
            b.Text = text
            b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            b.TextColor3 = Color3.new(1, 1, 1)
            b.BorderSizePixel = 0
            b.AutoButtonColor = false
            b.Font = Enum.Font.Gotham
            b.TextSize = 15
            b.TextXAlignment = Enum.TextXAlignment.Left -- Alinha o texto à esquerda
            b.TextScaled = false -- Desativar TextScaled
            b.TextWrapped = false
            b.TextLabel.Padding = UDim.new(0, 10) -- Adiciona padding ao texto
            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(0, 8)
            bCorner.Parent = b
            addHover(b)
            b.MouseButton1Click:Connect(function()
                if typeof(callback) == "function" then
                    callback()
                end
            end)
            b.Parent = parent
        end

        function api:AddToggle(text, default, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local t = Instance.new("TextButton")
            t.Name = "ToggleState" -- Nome para evitar hover na cor
            t.Size = UDim2.new(1, -20, 0, 36)
            t.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            t.TextColor3 = Color3.new(1, 1, 1)
            t.BorderSizePixel = 0
            t.Font = Enum.Font.Gotham
            t.TextSize = 15
            t.TextXAlignment = Enum.TextXAlignment.Left -- Alinha o texto à esquerda
            t.TextScaled = false
            t.TextWrapped = false
            t.TextLabel.Padding = UDim.new(0, 10)
            local tCorner = Instance.new("UICorner")
            tCorner.CornerRadius = UDim.new(0, 8)
            tCorner.Parent = t
            local state = default or false
            local function update()
                t.Text = text
                if state then
                    t.BackgroundColor3 = Color3.fromRGB(0, 150, 255) -- Cor quando ON
                else
                    t.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Cor quando OFF
                end
            end
            update()
            -- Não usar addHover aqui, pois a cor de fundo muda com o estado
            t.MouseEnter:Connect(function()
                if not state then
                    t.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Hover para OFF
                end
            end)
            t.MouseLeave:Connect(function()
                if not state then
                    t.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Volta para OFF
                end
            end)
            t.MouseButton1Click:Connect(function()
                state = not state
                update()
                if typeof(callback) == "function" then
                    callback(state)
                end
            end)
            t.Parent = parent

            -- Indicador de estado visual (ON/OFF)
            local statusLabel = Instance.new("TextLabel")
            statusLabel.Size = UDim2.new(0, 40, 1, 0)
            statusLabel.Position = UDim2.new(1, -50, 0, 0) -- Posição à direita do botão
            statusLabel.BackgroundTransparency = 1
            statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            statusLabel.Font = Enum.Font.GothamBold
            statusLabel.TextSize = 14
            statusLabel.TextXAlignment = Enum.TextXAlignment.Right
            statusLabel.Parent = t

            local function updateStatusText()
                statusLabel.Text = state and "ON" or "OFF"
                statusLabel.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
            end
            t.MouseButton1Click:Connect(updateStatusText)
            updateStatusText() -- Define o texto inicial
        end

        function api:AddDropdown(text, options, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local d = Instance.new("TextButton")
            d.Size = UDim2.new(1, -20, 0, 36)
            d.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            d.TextColor3 = Color3.new(1, 1, 1)
            d.Text = text .. ": " .. options[1] -- Define o primeiro item como padrão
            d.BorderSizePixel = 0
            d.Font = Enum.Font.Gotham
            d.TextSize = 15
            d.AutoButtonColor = false
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.TextScaled = false
            d.TextWrapped = false
            d.TextLabel.Padding = UDim.new(0, 10)
            local dCorner = Instance.new("UICorner")
            dCorner.CornerRadius = UDim.new(0, 8)
            dCorner.Parent = d
            addHover(d)
            d.Parent = parent

            local open = false
            local dropdownItems = {}

            local function closeAllDropdowns()
                for _, item in ipairs(dropdownItems) do item:Destroy() end
                dropdownItems = {}; open = false
            end

            d.MouseButton1Click:Connect(function()
                if open then closeAllDropdowns() return end

                local yOffset = 36 -- Posição inicial dos itens
                for i, val in ipairs(options) do
                    local opt = Instance.new("TextButton")
                    opt.Size = UDim2.new(1, -20, 0, 28)
                    opt.Position = UDim2.new(0, 0, 0, yOffset)
                    opt.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Cor para os itens do dropdown
                    opt.TextColor3 = Color3.new(1, 1, 1)
                    opt.Text = "› " .. val
                    opt.BorderSizePixel = 0
                    opt.Font = Enum.Font.Gotham
                    opt.TextSize = 14
                    opt.AutoButtonColor = false
                    opt.TextXAlignment = Enum.TextXAlignment.Left
                    opt.TextScaled = false
                    opt.TextWrapped = false
                    opt.TextLabel.Padding = UDim.new(0, 15)
                    local optCorner = Instance.new("UICorner")
                    optCorner.CornerRadius = UDim.new(0, 8)
                    optCorner.Parent = opt
                    addHover(opt)
                    opt.MouseButton1Click:Connect(function()
                        d.Text = text .. ": " .. val
                        closeAllDropdowns()
                        if typeof(callback) == "function" then
                            callback(val)
                        end
                    end)
                    opt.Parent = parent
                    table.insert(dropdownItems, opt)
                    yOffset = yOffset + 28 + 2 -- Espaçamento entre os itens
                end
                open = true
            end)
        end

        function api:AddSlider(text, min, max, default, callback, side)
            local parent = side == "Right" and rightScroll or leftScroll
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, -20, 0, 56)
            holder.BackgroundTransparency = 1
            holder.Parent = parent

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Text = text .. ": " .. tostring(default)
            label.Font = Enum.Font.Gotham
            label.TextSize = 15
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = holder

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, 0, 0, 12)
            bar.Position = UDim2.new(0, 0, 0, 32)
            bar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            bar.BorderSizePixel = 0
            bar.ClipsDescendants = true
            bar.Parent = holder
            local barCorner = Instance.new("UICorner")
            barCorner.CornerRadius = UDim.new(0, 6)
            barCorner.Parent = bar

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            fill.Parent = bar
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 6)
            fillCorner.Parent = fill

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
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, -20, 0, 36)
            holder.BackgroundTransparency = 1
            holder.Parent = parent

            local box = Instance.new("TextButton")
            box.Size = UDim2.new(0, 26, 0, 26)
            box.Position = UDim2.new(0, 0, 0, 5)
            box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            box.BorderSizePixel = 0
            box.AutoButtonColor = false
            box.Text = ""
            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 8)
            boxCorner.Parent = box
            box.Parent = holder

            local tick = Instance.new("Frame")
            tick.Size = default and UDim2.new(1, -8, 1, -8) or UDim2.new(0, 0, 0, 0) -- Levemente menor para um visual mais limpo
            tick.Position = default and UDim2.new(0, 4, 0, 4) or UDim2.new(0, 0, 0, 0)
            tick.BackgroundColor3 = Color3.fromRGB(0, 150, 255) -- Cor do tick
            tick.Parent = box
            local tickCorner = Instance.new("UICorner")
            tickCorner.CornerRadius = UDim.new(0, 6)
            tickCorner.Parent = tick

            local label = Instance.new("TextLabel")
            label.Position = UDim2.new(0, 34, 0, 0)
            label.Size = UDim2.new(1, -34, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Font = Enum.Font.Gotham
            label.TextSize = 15
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = holder

            local state = default or false
            box.MouseButton1Click:Connect(function()
                state = not state
                -- Animação suave para o tick
                if state then
                    tick:TweenSizeAndPosition(UDim2.new(1, -8, 1, -8), UDim2.new(0, 4, 0, 4), "Out", "Quad", 0.2)
                else
                    tick:TweenSizeAndPosition(UDim2.new(0, 0, 0, 0), UDim2.new(0, 13, 0, 13), "Out", "Quad", 0.2) -- Posição central para desaparecer
                end

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

