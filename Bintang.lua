-- Services.
local playersService = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local workspaceService = game:GetService("Workspace")

-- Config.
local HUB_NAME = "BintangHub"
local OWNER_NAME = "BintangHub"
local TOGGLE_KEY = Enum.KeyCode.RightShift

if shared.BintangX6LoccHub then pcall(shared.BintangX6LoccHub.destroy) end

-- State.
local localPlayer = playersService.LocalPlayer
local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
local flags, callbacks, elements = {}, {}, {}
local connections, pages, registries, tabButtons = {}, {}, {}, {}
local activeRegistry, currentTab, activeSlider = {}, "ESP", nil

local autoY = Enum.AutomaticSize.Y
local layoutOrder = Enum.SortOrder.LayoutOrder
local Hub = { flags = flags }

-- Theme
local colors = {
	window = Color3.fromRGB(13, 9, 9), row = Color3.fromRGB(26, 17, 17), line = Color3.fromRGB(46, 30, 30),
	border = Color3.fromRGB(90, 35, 38), off = Color3.fromRGB(47, 34, 34), accent = Color3.fromRGB(193, 39, 45),
	text = Color3.fromRGB(238, 238, 238), bright = Color3.fromRGB(241, 222, 222), muted = Color3.fromRGB(167, 154, 154),
	dim = Color3.fromRGB(127, 112, 112),
}

local palette = {
	Color3.fromRGB(255, 59, 59), Color3.fromRGB(255, 154, 0), Color3.fromRGB(255, 230, 0),
	Color3.fromRGB(18, 184, 74), Color3.fromRGB(0, 200, 200), Color3.fromRGB(59, 156, 255),
	Color3.fromRGB(139, 92, 246), Color3.fromRGB(255, 120, 220), Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(150, 150, 150),
}

local function create(className, properties, parent)
	local instance = Instance.new(className)
	for key, value in pairs(properties) do instance[key] = value end
	instance.Parent = parent
	return instance
end
local function round(instance, radius) create("UICorner", { CornerRadius = UDim.new(0, radius) }, instance) end
local function stroke(instance, color, thickness) create("UIStroke", { Color = color, Thickness = thickness or 1 }, instance) end
local function fire(key, value)
	flags[key] = value
	if callbacks[key] then task.spawn(callbacks[key], value) end
end

-- GUI Setup
local gui = create("ScreenGui", { Name = HUB_NAME, ResetOnSpawn = false, DisplayOrder = 100, IgnoreGuiInset = true }, parentGui)
pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)

local windowWidth, windowHeight = 520, 320
local window = create("Frame", {
	Size = UDim2.fromOffset(windowWidth, windowHeight), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	BackgroundColor3 = colors.window, BorderSizePixel = 0, ClipsDescendants = true,
}, gui)
round(window, 10); stroke(window, colors.border, 1.5)

local sidebar = create("Frame", { Size = UDim2.new(0, 130, 1, 0), BackgroundTransparency = 1 }, window)
create("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = colors.line, BorderSizePixel = 0 }, sidebar)
create("TextLabel", { Size = UDim2.new(1, -16, 0, 24), Position = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = colors.text, TextXAlignment = Enum.TextXAlignment.Left, Text = HUB_NAME }, sidebar)

local nav = create("ScrollingFrame", { Size = UDim2.new(1, -12, 1, -50), Position = UDim2.fromOffset(6, 40), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = autoY }, sidebar)
create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = layoutOrder }, nav)

local footer = create("Frame", { Size = UDim2.new(1, 0, 0, 36), Position = UDim2.new(0, 0, 1, -36), BackgroundTransparency = 1 }, sidebar)
create("Frame", { Size = UDim2.new(1, -16, 0, 1), Position = UDim2.fromOffset(8, 0), BackgroundColor3 = colors.line, BorderSizePixel = 0 }, footer)
create("TextLabel", { Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = colors.dim, TextXAlignment = Enum.TextXAlignment.Left, Text = "Owner: " .. OWNER_NAME }, footer)

local header = create("Frame", { Size = UDim2.new(1, -130, 0, 30), Position = UDim2.fromOffset(130, 0), BackgroundTransparency = 1 }, window)
create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = colors.line, BorderSizePixel = 0 }, header)
local headerTitle = create("TextLabel", { Size = UDim2.new(1, -80, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = colors.text, TextXAlignment = Enum.TextXAlignment.Left, Text = "ESP" }, header)

local function createHeaderButton(text, offsetX, callback)
	local button = create("TextButton", { Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, offsetX, 0.5, -10), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = colors.muted, Text = text }, header)
	button.MouseButton1Click:Connect(callback)
end
createHeaderButton("-", -46, function() window.Visible = false end)
createHeaderButton("x", -24, function() Hub.destroy() end)

local pagesHolder = create("Frame", { Size = UDim2.new(1, -130, 1, -30), Position = UDim2.fromOffset(130, 30), BackgroundTransparency = 1, ClipsDescendants = true }, window)
local floatBtn = create("TextButton", { Size = UDim2.fromOffset(32, 32), Position = UDim2.fromOffset(56, 56), BackgroundColor3 = colors.window, BorderSizePixel = 0, Text = "Bh", TextColor3 = colors.text, Font = Enum.Font.GothamBold, TextSize = 12 }, gui)
round(floatBtn, 8); stroke(floatBtn, colors.border, 1.5)
floatBtn.MouseButton1Click:Connect(function() window.Visible = not window.Visible end)

local dragging, dragStart, startPosition = false, nil, nil
local function isPointerInput(input) return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch end
local function setScrollLocked(locked) for _, page in pairs(pages) do if page:IsA("ScrollingFrame") then page.ScrollingEnabled = not locked end end end

header.InputBegan:Connect(function(input) if isPointerInput(input) then dragging, dragStart, startPosition = true, input.Position, window.Position end end)
table.insert(connections, userInputService.InputChanged:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
	if activeSlider then activeSlider(input) end
	if dragging then
		local delta = input.Position - dragStart
		window.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
	end
end))
table.insert(connections, userInputService.InputEnded:Connect(function(input) if isPointerInput(input) then dragging = false; activeSlider = nil; setScrollLocked(false) end end))
table.insert(connections, userInputService.InputBegan:Connect(function(input, processed) if not processed and input.KeyCode == TOGGLE_KEY then window.Visible = not window.Visible end end))

-- Builders
local builders = {}
local function registerRow(frame, text) table.insert(activeRegistry, { frame = frame, text = text:lower() }) end
local function createLabel(parent, text, size, color) return create("TextLabel", { Size = size, BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = color or colors.text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = text }, parent) end

builders.toggle = function(body, row, key)
	local frame = create("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1 }, body)
	registerRow(frame, row.text)
	createLabel(frame, row.text, UDim2.new(1, -40, 1, 0))
	local track = create("Frame", { Size = UDim2.fromOffset(30, 16), Position = UDim2.new(1, -30, 0.5, -8), BackgroundColor3 = colors.off, BorderSizePixel = 0 }, frame)
	round(track, 8)
	local knob = create("Frame", { Size = UDim2.fromOffset(10, 10), Position = UDim2.fromOffset(3, 3), BackgroundColor3 = colors.muted, BorderSizePixel = 0 }, track)
	round(knob, 5)
	local value = row.default
	local function render(animate)
		local trackColor = value and colors.accent or colors.off
		local knobColor = value and Color3.new(1, 1, 1) or colors.muted
		local knobPosition = UDim2.fromOffset(value and 17 or 3, 3)
		if animate then
			local info = TweenInfo.new(0.12)
			tweenService:Create(track, info, { BackgroundColor3 = trackColor }):Play()
			tweenService:Create(knob, info, { BackgroundColor3 = knobColor, Position = knobPosition }):Play()
		else
			track.BackgroundColor3, knob.BackgroundColor3, knob.Position = trackColor, knobColor, knobPosition
		end
	end
	local function set(newValue, silent) value = newValue and true or false; render(true); if silent then flags[key] = value else fire(key, value) end end
	local click = create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "" }, frame)
	click.MouseButton1Click:Connect(function() set(not value) end)
	flags[key] = value; render(false); elements[key] = { set = set }
end

builders.slider = function(body, row, key)
	local frame = create("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1 }, body)
	registerRow(frame, row.text)
	createLabel(frame, row.text, UDim2.new(1, -50, 0, 16))
	local valueLabel = create("TextLabel", { Size = UDim2.fromOffset(46, 16), Position = UDim2.new(1, -46, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = colors.muted, TextXAlignment = Enum.TextXAlignment.Right }, frame)
	local track = create("Frame", { Size = UDim2.new(1, 0, 0, 4), Position = UDim2.fromOffset(0, 20), BackgroundColor3 = colors.off, BorderSizePixel = 0 }, frame)
	round(track, 2)
	local fill = create("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = colors.accent, BorderSizePixel = 0 }, track)
	round(fill, 2)
	local knob = create("Frame", { Size = UDim2.fromOffset(10, 10), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }, track)
	round(knob, 5)
	local value, range = row.default, row.max - row.min
	local function render()
		local alpha = (value - row.min) / range
		fill.Size = UDim2.fromScale(alpha, 1); knob.Position = UDim2.fromScale(alpha, 0.5); valueLabel.Text = tostring(value)
	end
	local function set(newValue, silent) value = math.clamp(math.floor(newValue / row.step + 0.5) * row.step, row.min, row.max); render(); if silent then flags[key] = value else fire(key, value) end end
	local function update(input) local alpha = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1); set(row.min + alpha * range) end
	frame.InputBegan:Connect(function(input) if isPointerInput(input) then activeSlider = update; setScrollLocked(true); update(input) end end)
	flags[key] = value; render(); elements[key] = { set = set }
end

builders.dropdown = function(body, row, key)
	local frame = create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = autoY, BackgroundTransparency = 1 }, body)
	create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = layoutOrder }, frame)
	registerRow(frame, row.text)
	local label = createLabel(frame, row.text, UDim2.new(1, 0, 0, 14), colors.muted); label.LayoutOrder = 1
	local box = create("TextButton", { Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 2, BackgroundColor3 = colors.row, AutoButtonColor = false, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = colors.text, TextXAlignment = Enum.TextXAlignment.Left }, frame)
	round(box, 4); stroke(box, colors.line); create("UIPadding", { PaddingLeft = UDim.new(0, 6) }, box)
	local optionsFrame = create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = autoY, LayoutOrder = 3, BackgroundTransparency = 1, Visible = false }, frame)
	create("UIListLayout", { Padding = UDim.new(0, 2) }, optionsFrame)
	local value = row.default
	local function set(newValue, silent) value = newValue; box.Text = tostring(value) .. "  v"; if silent then flags[key] = value else fire(key, value) end end
	local function setOptions(list)
		for _, child in ipairs(optionsFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
		for _, option in ipairs(list) do
			local optionButton = create("TextButton", { Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = colors.window, AutoButtonColor = false, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = colors.muted, Text = tostring(option) }, optionsFrame)
			round(optionButton, 4); optionButton.MouseButton1Click:Connect(function() set(option); optionsFrame.Visible = false end)
		end
	end
	box.MouseButton1Click:Connect(function() optionsFrame.Visible = not optionsFrame.Visible end)
	setOptions(row.options); flags[key] = value; set(value, true); elements[key] = { set = set, setOptions = setOptions }
end

builders.colorPick = function(body, row, key)
	local frame = create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = autoY, BackgroundTransparency = 1 }, body)
	create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = layoutOrder }, frame)
	registerRow(frame, row.text)
	local top = create("Frame", { Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 1, BackgroundTransparency = 1 }, frame)
	createLabel(top, row.text, UDim2.new(1, -40, 1, 0), colors.muted)
	local swatch = create("TextButton", { Size = UDim2.fromOffset(30, 14), Position = UDim2.new(1, -30, 0.5, -7), BackgroundColor3 = row.default, AutoButtonColor = false, Text = "" }, top)
	round(swatch, 3); stroke(swatch, colors.border)
	local palettePanel = create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = autoY, LayoutOrder = 2, BackgroundTransparency = 1, Visible = false }, frame)
	create("UIGridLayout", { CellSize = UDim2.fromOffset(20, 20), CellPadding = UDim2.fromOffset(4, 4) }, palettePanel)
	local value = row.default
	local function set(newValue, silent) value = newValue; swatch.BackgroundColor3 = value; if silent then flags[key] = value else fire(key, value) end end
	for _, presetColor in ipairs(palette) do
		local presetButton = create("TextButton", { BackgroundColor3 = presetColor, AutoButtonColor = false, Text = "" }, palettePanel)
		round(presetButton, 3); presetButton.MouseButton1Click:Connect(function() set(presetColor); palettePanel.Visible = false end)
	end
	swatch.MouseButton1Click:Connect(function() palettePanel.Visible = not palettePanel.Visible end)
	flags[key] = value; elements[key] = { set = set }
end

builders.button = function(body, row, key)
	local button = create("TextButton", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = colors.row, BorderSizePixel = 0, AutoButtonColor = false, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = colors.bright, Text = row.text:upper() }, body)
	round(button, 4); stroke(button, colors.line); registerRow(button, row.text)
	button.MouseButton1Click:Connect(function()
		button.BackgroundColor3 = colors.accent; tweenService:Create(button, TweenInfo.new(0.25), { BackgroundColor3 = colors.row }):Play()
		if callbacks[key] then task.spawn(callbacks[key]) end
	end)
	elements[key] = {}
end

local function toggle(text, default) return { kind = "toggle", text = text, default = default or false } end
local function slider(text, min, max, default, step) return { kind = "slider", text = text, min = min, max = max, default = default, step = step or 1 } end
local function dropdown(text, options, default) return { kind = "dropdown", text = text, options = options, default = default or options[1] } end
local function colorPick(text, value) return { kind = "colorPick", text = text, default = value } end
local function button(text) return { kind = "button", text = text } end
local function card(title, rows) return { title = title, rows = rows } end

local tabs = {
	{
		name = "ESP",
		left = {
			card("Player ESP", {
				toggle("Killer ESP", false), colorPick("Killer Color", Color3.fromRGB(255, 0, 0)),
				toggle("Survivor ESP", false), colorPick("Survivor Color", Color3.fromRGB(0, 255, 0)),
			}),
		},
		right = {
			card("Map Objects", {
				toggle("Generator", false), colorPick("Gen Color", Color3.fromRGB(0, 210, 255)),
				toggle("Pallet", false), colorPick("Pallet Color", Color3.fromRGB(200, 160, 80)),
				toggle("Vault / Window", false), colorPick("Vault Color", Color3.fromRGB(180, 180, 180)),
				toggle("Hook", false), colorPick("Hook Color", Color3.fromRGB(255, 150, 0)),
				toggle("Exit Gate", false), colorPick("Gate Color", Color3.fromRGB(255, 255, 0)),
				toggle("Bear Trap", false), colorPick("Trap Color", Color3.fromRGB(190, 100, 255)),
				toggle("Pumpkin", false), colorPick("Pumpkin Color", Color3.fromRGB(255, 140, 0)),
			}),
		},
	},
	{
		name = "Farm",
		left = {
			card("Skill Check Generator", { toggle("Auto Skill Check", false), dropdown("Mode Gen", { "Legit", "Normal", "Instant", "Perfect" }, "Perfect") }),
		},
		right = {
			card("Skill Check Trap Bear", { toggle("Auto Trap Skill Check", false) }),
		},
	},
	{
		name = "Combat",
		left = {
			card("Auto Parry", { toggle("Enable Auto Parry", false), slider("Parry Range", 6, 25, 14), toggle("Facing Check", true) }),
		},
	},
}

local function createScrollPage()
	local page = create("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = colors.accent, VerticalScrollBarInset = Enum.ScrollBarInset.None, CanvasSize = UDim2.new(), AutomaticCanvasSize = autoY, Visible = false }, pagesHolder)
	create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, page)
	return page
end

local function createColumns(page)
	local holder = create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = autoY, BackgroundTransparency = 1 }, page)
	create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Top, Padding = UDim.new(0, 8), SortOrder = layoutOrder }, holder)
	local cols = {}
	for i = 1, 2 do
		local col = create("Frame", { Size = UDim2.new(0.5, -4, 0, 0), AutomaticSize = autoY, BackgroundTransparency = 1, LayoutOrder = i }, holder)
		create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = layoutOrder }, col)
		cols[i] = col
	end
	return cols[1], cols[2]
end

local function buildCard(col, tabName, cardData)
	local frame = create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = autoY, BackgroundColor3 = colors.window, BackgroundTransparency = 0.4, BorderSizePixel = 0 }, col)
	round(frame, 6); stroke(frame, colors.line); create("UIListLayout", { SortOrder = layoutOrder }, frame)
	local btn = create("TextButton", { Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 1, BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, frame)
	local title = createLabel(btn, cardData.title, UDim2.new(1, -20, 1, 0)); title.Position = UDim2.fromOffset(8, 0); title.Font = Enum.Font.GothamBold
	local arrow = create("TextLabel", { Size = UDim2.fromOffset(16, 24), Position = UDim2.new(1, -20, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = colors.muted, Text = "v" }, btn)
	create("Frame", { Size = UDim2.new(1, 0, 0, 1), LayoutOrder = 2, BackgroundColor3 = colors.line, BorderSizePixel = 0 }, frame)
	local body = create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = autoY, LayoutOrder = 3, BackgroundTransparency = 1 }, frame)
	create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, body)
	create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = layoutOrder }, body)
	btn.MouseButton1Click:Connect(function() body.Visible = not body.Visible; arrow.Text = body.Visible and "v" or ">" end)
	for _, row in ipairs(cardData.rows) do builders[row.kind](body, row, row.key or (tabName .. "." .. row.text)) end
end

local function selectTab(name)
	currentTab = name; headerTitle.Text = name
	for pageName, page in pairs(pages) do page.Visible = pageName == name end
	for tabName, entry in pairs(tabButtons) do
		local active = tabName == name
		entry.button.BackgroundTransparency = active and 0 or 1
		entry.button.TextColor3 = active and colors.text or colors.muted
		entry.bar.Visible = active
	end
end

for i, tab in ipairs(tabs) do
	activeRegistry = {}; registries[tab.name] = activeRegistry
	local page = createScrollPage()
	local l, r = createColumns(page)
	for _, c in ipairs(tab.left or {}) do buildCard(l, tab.name, c) end
	for _, c in ipairs(tab.right or {}) do buildCard(r, tab.name, c) end
	pages[tab.name] = page
	local btn = create("TextButton", { Size = UDim2.new(1, 0, 0, 24), LayoutOrder = i, BackgroundColor3 = colors.row, BackgroundTransparency = 1, AutoButtonColor = false, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = colors.muted, TextXAlignment = Enum.TextXAlignment.Left, Text = tab.name }, nav)
	round(btn, 4); create("UIPadding", { PaddingLeft = UDim.new(0, 10) }, btn)
	local bar = create("Frame", { Size = UDim2.new(0, 2, 1, -8), Position = UDim2.fromOffset(-8, 4), BackgroundColor3 = colors.accent, BorderSizePixel = 0, Visible = false }, btn)
	tabButtons[tab.name] = { button = btn, bar = bar }
	btn.MouseButton1Click:Connect(function() selectTab(tab.name) end)
end
selectTab("ESP")

function Hub.on(key, cb, runNow) if elements[key] then callbacks[key] = cb; if runNow and flags[key] ~= nil then task.spawn(cb, flags[key]) end end end
function Hub.set(key, val, silent) local e = elements[key]; if e and e.set then e.set(val, silent) end end
function Hub.destroy() for _, c in ipairs(connections) do c:Disconnect() end; gui:Destroy(); shared.BintangX6LoccHub = nil end
shared.BintangX6LoccHub = Hub

-- ==========================================
-- LOGIC
-- ==========================================
local mapESPs = {}
local playerESPs = {}

local function isKiller(plr)
	if plr.Team and (plr.Team.Name:lower():find("killer") or plr.Team.Name:lower():find("slasher")) then return true end
	if plr:GetAttribute("Role") == "Killer" or plr:GetAttribute("IsKiller") == true then return true end
	return false
end

local function getObjType(obj, map)
	if not obj or not obj.Parent then return nil end
	local n = obj.Name:lower()
	if map and not obj:IsDescendantOf(map) then return nil end
	
	if n == "window" or n:find("window") or n == "vault" or n:find("vault") then
		local bottom = obj:FindFirstChild("bottom") or obj:FindFirstChild("Bottom")
		local inviswall = obj:FindFirstChild("inviswall") or obj:FindFirstChild("Inviswall")
		local vaulttrigger = obj:FindFirstChild("vaulttrigger") or obj:FindFirstChild("VaultTrigger")
		if bottom and inviswall and vaulttrigger then return "Vault" end
		return nil
	end
	
	if n == "exitlever" or obj:FindFirstChild("ExitLever", true) or obj:FindFirstChild("ExitLever") then
		if not (n:find("spot") or n:find("spawn") or n:find("marker") or n:find("point")) then return "Gate" end
		return nil
	end

	if obj:IsA("Model") and (n == "pallet" or n:find("pallet") or (obj.Parent and obj.Parent.Name == "Pallets")) then
		if obj:FindFirstChild("Intact") and obj:GetAttribute("Intact") ~= false then return "Pallet" end
		return nil
	end

	if n:find("generator") and not n:find("gui") then return "Gen" 
	elseif n:find("hook") then return "Hook" 
	elseif n:find("trap") or n:find("beartrap") then return "Trap" 
	elseif n:find("pumpkin") then return "Pumpkin" end
	return nil
end

local function getColor(keyName, defaultColor) return flags["ESP." .. keyName] or defaultColor end

task.spawn(function()
	while gui.Parent do
		task.wait(1)
		pcall(function()
			local map = workspaceService:FindFirstChild("Map") or workspaceService:FindFirstChild("Game") or workspaceService
			for _, obj in ipairs(map:GetDescendants()) do
				if obj and obj.Parent and (obj:IsA("Model") or obj:IsA("BasePart")) and not mapESPs[obj] then
					local t = getObjType(obj, map)
					if t then
						local en = false
						if t == "Gen" and flags["ESP.Generator"] then en = true 
						elseif t == "Pallet" and flags["ESP.Pallet"] then en = true 
						elseif t == "Vault" and flags["ESP.Vault / Window"] then en = true 
						elseif t == "Hook" and flags["ESP.Hook"] then en = true 
						elseif t == "Gate" and flags["ESP.Exit Gate"] then en = true 
						elseif t == "Trap" and flags["ESP.Bear Trap"] then en = true 
						elseif t == "Pumpkin" and flags["ESP.Pumpkin"] then en = true end
						
						if en then
							local hl = create("Highlight", { Name = "BintangESP", FillColor = getColor(t .. " Color", Color3.new(1,1,1)), OutlineColor = Color3.new(1,1,1), FillTransparency = 0.5, OutlineTransparency = 0 }, obj)
							mapESPs[obj] = { Highlight = hl, Type = t }
						end
					end
				end
			end
		end)
	end
end)

runService.Heartbeat:Connect(function()
	pcall(function()
		for obj, data in pairs(mapESPs) do
			if not obj or not obj.Parent then
				if data and data.Highlight then data.Highlight:Destroy() end
				mapESPs[obj] = nil
			else
				local keep = false
				if data.Type == "Gen" and flags["ESP.Generator"] then keep = true 
				elseif data.Type == "Pallet" and flags["ESP.Pallet"] then keep = true 
				elseif data.Type == "Vault" and flags["ESP.Vault / Window"] then keep = true 
				elseif data.Type == "Hook" and flags["ESP.Hook"] then keep = true 
				elseif data.Type == "Gate" and flags["ESP.Exit Gate"] then keep = true 
				elseif data.Type == "Trap" and flags["ESP.Bear Trap"] then keep = true 
				elseif data.Type == "Pumpkin" and flags["ESP.Pumpkin"] then keep = true end
				
				if not keep then 
					if data.Highlight then data.Highlight:Destroy() end 
					mapESPs[obj] = nil 
				else
					if data.Highlight then 
						local cKey = data.Type == "Gen" and "Gen Color" or data.Type == "Vault" and "Vault Color" or data.Type == "Gate" and "Gate Color" or data.Type == "Trap" and "Trap Color" or data.Type == "Pumpkin" and "Pumpkin Color" or data.Type .. " Color"
						data.Highlight.FillColor = getColor(cKey, data.Highlight.FillColor)
						data.Highlight.OutlineColor = getColor(cKey, data.Highlight.OutlineColor)
					end
				end
			end
		end

		for _, plr in ipairs(playersService:GetPlayers()) do
			if plr ~= localPlayer and plr.Character then
				local char = plr.Character
				local killer = isKiller(plr)
				local show = (killer and flags["ESP.Killer ESP"]) or (not killer and flags["ESP.Survivor ESP"])

				if show then
					if not playerESPs[char] or not playerESPs[char].Parent then
						local hl = create("Highlight", { FillTransparency = 0.5, OutlineTransparency = 0 }, char)
						playerESPs[char] = hl
					end
					local cKey = killer and "Killer Color" or "Survivor Color"
					local col = getColor(cKey, killer and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0))
					playerESPs[char].FillColor = col
					playerESPs[char].OutlineColor = col
				else
					if playerESPs[char] then playerESPs[char]:Destroy(); playerESPs[char] = nil end
				end
			end
		end
	end)
end)

-- SKILL CHECK
local randomValue, sum = 104, 114
local check, line, trapPerfect = nil, nil, nil
local resultValue4, timestamp2, rotation = nil, nil, nil
local enabled2, timestamp3, enabled3, rotation2, matchesCondition, enabled4 = false, 0, false, nil, false, false

local function getSkillCheckGui()
    local pg = localPlayer:FindFirstChildOfClass("PlayerGui")
    if not pg then return nil end
    local gui1 = pg:FindFirstChild("SkillCheckPromptGui") or pg:FindFirstChild("SkillCheckPromptGui-con")
    if gui1 then local c = gui1:FindFirstChild("Check"); if c and c.Visible then return gui1 end end
    return nil
end

local function checkKingsScourge()
    for _, player in ipairs(playersService:GetPlayers()) do
        if player:GetAttribute("Role") == "Killer" or player:GetAttribute("IsKiller") == true or (player.Team and player.Team.Name:lower():find("killer")) then
            if player.Character then
                for _, descendant in ipairs(player.Character:GetDescendants()) do
                    if string.find(descendant.Name, "King's Scourge") then return true end
                end
            end
        end
    end
    for _, child in ipairs(workspaceService:GetChildren()) do
        if child:IsA("Model") and child ~= localPlayer.Character then
            for _, child2 in ipairs(child:GetChildren()) do
                if string.find(child2.Name, "King's Scourge") then return true end
            end
        end
    end
    return false
end

local function handleAction4(isTrap)
    if matchesCondition then randomValue = 104; sum = 114; return end
    if not isTrap and checkKingsScourge() then
        if math.random(1, 100) <= 30 then randomValue = 104; sum = 114
        else local r = math.random(125, 155); randomValue = r; sum = r + 10 end
        return
    end
    if isTrap then randomValue = 104; sum = 114; return end
    
    local mode = flags["Farm.Mode Gen"] or "Perfect"
    if mode == "Normal" then local r = math.random(125, 155); randomValue = r; sum = r + 10
    elseif mode == "Perfect" then randomValue = 104; sum = 114
    else randomValue = 104; sum = 114 end
end

local function fireSkillCheck()
    task.spawn(function()
        local pg = localPlayer:FindFirstChildOfClass("PlayerGui")
        local sm = pg and (pg:FindFirstChild("Survivor-mob") or pg:FindFirstChild("Survivor") or pg:FindFirstChild("Survivor-con"))
        if userInputService.TouchEnabled then
            pcall(function()
                if sm then
                    local controls = sm:FindFirstChild("Controls"); local action = controls and controls:FindFirstChild("action")
                    if action then
                        if firesignal then pcall(firesignal, action.MouseButton1Down); pcall(firesignal, action.MouseButton1Click) end
                        if getconnections then for _, c in ipairs(getconnections(action.MouseButton1Down)) do pcall(function() c:Fire() end) end end
                    end
                end
                local gui1 = getSkillCheckGui()
                if gui1 then
                    for _, desc in ipairs(gui1:GetDescendants()) do
                        if desc:IsA("GuiButton") and desc.Visible then
                            if firesignal then pcall(firesignal, desc.MouseButton1Down) end
                            if getconnections then for _, c in ipairs(getconnections(desc.MouseButton1Down)) do pcall(function() c:Fire() end) end end
                        end
                    end
                end
            end)
            pcall(function() if userInputService.MouseBehavior ~= Enum.MouseBehavior.Default then userInputService.MouseBehavior = Enum.MouseBehavior.Default end end)
        else
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                if vim then vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game); task.wait(0.02); vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end
            end)
        end
    end)
end

local function handleAction9()
    local gui1 = getSkillCheckGui()
    if not gui1 then check, line, trapPerfect = nil, nil, nil; matchesCondition = false; resultValue4 = nil; return false end
    resultValue4 = gui1; check = gui1:FindFirstChild("Check"); if not check then return false end
    line = check:FindFirstChild("Line")
    local trapPerfect2 = check:FindFirstChild("TrapPerfect"); local trapGoal = check:FindFirstChild("TrapGoal"); local goal = check:FindFirstChild("Goal")
    if trapPerfect2 and trapPerfect2.Visible then trapPerfect = trapPerfect2; matchesCondition = true
    elseif trapGoal and trapGoal.Visible then trapPerfect = trapGoal; matchesCondition = true
    elseif trapPerfect2 then trapPerfect = trapPerfect2; matchesCondition = true
    elseif goal then trapPerfect = goal; matchesCondition = false
    else trapPerfect = nil; matchesCondition = false end
    if line and trapPerfect then timestamp3 = 0; return true end
    return false
end

local function handleAction10()
    local gui1 = getSkillCheckGui()
    if not gui1 or not gui1:IsA("ScreenGui") then return false end
    local check2 = gui1:FindFirstChild("Check"); if not check2 or not check2.Visible then return false end
    if resultValue4 ~= gui1 then handleAction9() end
    return true
end
handleAction9()

runService.RenderStepped:Connect(function()
    if not handleAction10() then
        check, line, trapPerfect = nil, nil, nil; timestamp2, rotation = nil, nil
        enabled2, enabled3, rotation2, enabled4 = false, false, nil, false
        return
    end
    
    local isTrap = matchesCondition
    if isTrap then
        if not flags["Farm.Auto Trap Skill Check"] then timestamp2 = nil; return end
    else
        if not flags["Farm.Auto Skill Check"] then timestamp2 = nil; return end
    end
    
    local trapGoal = nil; local matchesCondition2 = false
    if check then
        local trapGoal2 = check:FindFirstChild("TrapGoal"); local trapPerfect2 = check:FindFirstChild("TrapPerfect")
        if trapGoal2 and trapGoal2.Visible then trapGoal = trapGoal2; matchesCondition2 = true
        elseif trapPerfect2 and trapPerfect2.Visible then trapGoal = trapPerfect2; matchesCondition2 = true
        else
            local goal = check:FindFirstChild("Goal")
            if goal and goal.Visible then trapGoal = goal; matchesCondition2 = false
            else trapGoal = trapGoal2 or trapPerfect2 or goal; matchesCondition2 = trapGoal == trapGoal2 or trapGoal == trapPerfect2 end
        end
    end
    
    if trapGoal and (trapGoal ~= trapPerfect or matchesCondition ~= matchesCondition2) then trapPerfect = trapGoal; matchesCondition = matchesCondition2; rotation2 = nil end
    if not check or not line or not trapPerfect then handleAction9(); return end
    
    local rotation3 = trapPerfect.Rotation
    if rotation2 == nil or math.abs(rotation2 - rotation3) > 0.05 then
        rotation2 = rotation3; enabled3, enabled4, timestamp2, rotation, enabled2 = false, false, tick(), nil, false
        handleAction4(isTrap)
    end
    
    local isInstant = (not isTrap) and (flags["Farm.Mode Gen"] == "Instant")
    if isInstant then
        if not enabled3 and not enabled4 then
            enabled3, enabled4 = true, true
            task.spawn(function()
                task.wait(0.1)
                if handleAction10() and check and line and trapPerfect then
                    local remainder = trapPerfect.Rotation % 360; if remainder < 0 then remainder = remainder + 360 end
                    local rotation4 = (remainder + (randomValue + sum) / 2) % 360; local sum2 = tick() + 0.25
                    task.spawn(function() while tick() < sum2 and handleAction10() and line do line.Rotation = rotation4; runService.RenderStepped:Wait() end end)
                    fireSkillCheck()
                end
            end)
        end
        return
    end
    
    if not timestamp2 then timestamp2 = tick(); enabled4 = false; handleAction4(isTrap) end
    if tick() - timestamp2 < 0.1 then return end
    
    local rotation4 = line.Rotation; local remainder = rotation4 % 360; local remainder2 = trapPerfect.Rotation % 360
    if remainder < 0 then remainder = remainder + 360 end; if remainder2 < 0 then remainder2 = remainder2 + 360 end
    local remainder3 = (remainder2 + randomValue) % 360; local remainder4 = (remainder2 + sum) % 360
    
    local matchesCondition3
    if remainder3 > remainder4 then matchesCondition3 = remainder >= remainder3 or remainder <= remainder4
    else matchesCondition3 = remainder >= remainder3 and remainder <= remainder4 end
    
    local matchesCondition4 = matchesCondition3
    if rotation then
        local remainder5 = rotation % 360; if remainder5 < 0 then remainder5 = remainder5 + 360 end
        local difference = rotation4 - rotation
        if difference < -180 then difference = difference + 360 elseif difference > 180 then difference = difference - 360 end
        if math.abs(difference) > 0.05 and math.abs(difference) < 100 then
            enabled2 = true; local enabled = false
            if difference > 0 then
                local remainder6 = (remainder3 - remainder5) % 360; local remainder7 = (remainder3 - remainder) % 360
                if remainder6 < 180 and remainder7 > 180 then enabled = true end
            else
                local remainder6 = (remainder5 - remainder4) % 360; local remainder7 = (remainder - remainder4) % 360
                if remainder6 < 180 and remainder7 > 180 then enabled = true end
            end
            if enabled then matchesCondition4 = true end
        end
    end
    rotation = rotation4; if not enabled2 then return end
    if enabled4 and matchesCondition and tick() - (timestamp3 or 0) > 0.18 and not matchesCondition3 then enabled4 = false end
    if matchesCondition4 and not enabled4 then enabled4 = true; timestamp3 = tick(); fireSkillCheck() end
end)

-- AUTO PARRY
local lastParry = 0
local function doParry()
	pcall(function()
		local pg = localPlayer:FindFirstChildOfClass("PlayerGui"); local sm = pg and (pg:FindFirstChild("Survivor-mob") or pg:FindFirstChild("Survivor")); local act = sm and sm:FindFirstChild("Controls") and (sm.Controls:FindFirstChild("Gui-mob") or sm.Controls:FindFirstChild("action"))
		if act then if firesignal then pcall(firesignal, act.MouseButton1Down) end; if getconnections then for _, c in ipairs(getconnections(act.MouseButton1Down)) do pcall(function() c:Fire() end) end end end
	end)
end
workspaceService.DescendantAdded:Connect(function(part)
	pcall(function()
		if not flags["Combat.Enable Auto Parry"] or not part or not part.Parent then return end
		if part:IsA("BasePart") and (part.Name:lower():find("hitbox") or part.Name:lower():find("slash")) then
			local model = part:FindFirstAncestorOfClass("Model")
			if model and model ~= localPlayer.Character then
				local killerHrp = model:FindFirstChild("HumanoidRootPart"); local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
				if killerHrp and myHrp then
					local dist = (killerHrp.Position - myHrp.Position).Magnitude; local facing = true
					if flags["Combat.Facing Check"] then local look = myHrp.CFrame.LookVector; local dir = (killerHrp.Position - myHrp.Position).Unit; facing = look:Dot(dir) > -0.1 end
					local range = flags["Combat.Parry Range"] or 14
					if dist <= range and facing and tick() - lastParry > 0.2 then lastParry = tick(); doParry() end
				end
			end
		end
	end)
end)