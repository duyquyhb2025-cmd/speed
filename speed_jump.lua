-- ===== CẤU HÌNH (chỉnh số ở đây hoặc trong GUI) =====
local CFG = {
	Speed = 32,    -- mặc định của game là 16
	Jump = 60,     -- mặc định của game là 50
	Enabled = true,
}
local DEFAULT = {Speed = 16, Jump = 50}
-- =====================================================

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G
if env.SJ_Stop then pcall(env.SJ_Stop) end

local humanoid
local conns = {}
local guiConns = {}

local function apply()
	if not humanoid or not humanoid.Parent then return end
	pcall(function()
		if CFG.Enabled then
			humanoid.UseJumpPower = true
			humanoid.WalkSpeed = CFG.Speed
			humanoid.JumpPower = CFG.Jump
		else
			humanoid.WalkSpeed = DEFAULT.Speed
			humanoid.JumpPower = DEFAULT.Jump
		end
	end)
end

local function bind(char)
	for _, c in ipairs(conns) do c:Disconnect() end
	conns = {}
	humanoid = char:WaitForChild("Humanoid", 10)
	if not humanoid then return end
	apply()
	-- Chỉ áp lại khi game đổi chỉ số, không chạy mỗi khung hình
	table.insert(conns, humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if CFG.Enabled and humanoid.WalkSpeed ~= CFG.Speed then apply() end
	end))
	table.insert(conns, humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
		if CFG.Enabled and humanoid.JumpPower ~= CFG.Jump then apply() end
	end))
end

if lp.Character then task.spawn(bind, lp.Character) end
table.insert(guiConns, lp.CharacterAdded:Connect(bind))

-- ===== GUI nhỏ =====
local gui = Instance.new("ScreenGui")
gui.Name = "SpeedJumpGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
local ok = false
if gethui then ok = pcall(function() gui.Parent = gethui() end) end
if not ok then gui.Parent = lp:WaitForChild("PlayerGui") end

local function make(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end

local F = make("Frame", {
	Size = UDim2.fromOffset(210, 150),
	Position = UDim2.new(0, 20, 0.4, 0),
	BackgroundColor3 = Color3.fromRGB(15, 12, 25),
	Active = true,
	Draggable = true,
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 10)}, F)

make("TextLabel", {
	Size = UDim2.new(1, -40, 0, 26), Position = UDim2.new(0, 10, 0, 2),
	BackgroundTransparency = 1, Text = "Speed / Jump",
	Font = Enum.Font.GothamBold, TextSize = 13,
	TextColor3 = Color3.fromRGB(0, 230, 255), TextXAlignment = Enum.TextXAlignment.Left,
}, F)

local X = make("TextButton", {
	Size = UDim2.fromOffset(22, 22), Position = UDim2.new(1, -28, 0, 4),
	Text = "X", Font = Enum.Font.GothamBold, TextSize = 11,
	BackgroundColor3 = Color3.fromRGB(220, 50, 70), TextColor3 = Color3.new(1, 1, 1),
}, F)
make("UICorner", {CornerRadius = UDim.new(0, 6)}, X)

local function row(label, y, value)
	make("TextLabel", {
		Size = UDim2.fromOffset(70, 28), Position = UDim2.new(0, 10, 0, y),
		BackgroundTransparency = 1, Text = label, Font = Enum.Font.GothamMedium,
		TextSize = 12, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left,
	}, F)
	local box = make("TextBox", {
		Size = UDim2.fromOffset(110, 28), Position = UDim2.new(0, 90, 0, y),
		BackgroundColor3 = Color3.fromRGB(24, 20, 40), Text = tostring(value),
		Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.new(1, 1, 1),
		ClearTextOnFocus = false,
	}, F)
	make("UICorner", {CornerRadius = UDim.new(0, 6)}, box)
	return box
end

local speedBox = row("Speed", 34, CFG.Speed)
local jumpBox = row("Jump", 68, CFG.Jump)

local T = make("TextButton", {
	Size = UDim2.new(1, -20, 0, 34), Position = UDim2.new(0, 10, 0, 106),
	Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.new(1, 1, 1),
}, F)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, T)

local function refresh()
	T.Text = CFG.Enabled and "ON" or "OFF"
	T.BackgroundColor3 = CFG.Enabled and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(60, 50, 80)
end
refresh()

speedBox.FocusLost:Connect(function()
	local n = tonumber(speedBox.Text)
	if n then CFG.Speed = math.clamp(n, 0, 120) end
	speedBox.Text = tostring(CFG.Speed)
	apply()
end)
jumpBox.FocusLost:Connect(function()
	local n = tonumber(jumpBox.Text)
	if n then CFG.Jump = math.clamp(n, 0, 200) end
	jumpBox.Text = tostring(CFG.Jump)
	apply()
end)
T.MouseButton1Click:Connect(function()
	CFG.Enabled = not CFG.Enabled
	refresh()
	apply()
end)

local function stop()
	CFG.Enabled = false
	apply()
	for _, c in ipairs(conns) do c:Disconnect() end
	for _, c in ipairs(guiConns) do c:Disconnect() end
	gui:Destroy()
end
env.SJ_Stop = stop
X.MouseButton1Click:Connect(stop)
