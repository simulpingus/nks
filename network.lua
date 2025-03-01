_G.NETACTIVE = not _G.NETACTIVE

pcall(function()
	_G.NETCON1:Disconnect()
	_G.NETCON2:Disconnect()
	_G.NETCON3:Disconnect()
	_G.NETCON1 = nil
	_G.NETCON2 = nil
	_G.NETCON3 = nil
end)

local function mss(tx)
	local msg = Instance.new("Hint")
	msg.Text = tx
	msg.Parent = workspace
	game:GetService("Debris"):AddItem(msg, 1)
end

mss("Net Nigga Activated? " .. (_G.NETACTIVE and "Yes!" or "No..."))

if not _G.NETACTIVE then
	return
end

local players = game:GetService("Players")
local plr = players.LocalPlayer
local ms = plr:GetMouse()

local moder = false
local offset = 2
local ct = 0
local parts = {}
local alignments = {}
local bp

local function check(inst)
	return inst:IsA("BasePart") and
		not inst.Anchored and
		not Players:GetPlayerFromCharacter(inst.Parent) and
		not Players:GetPlayerFromCharacter(inst.Parent.Parent)
end

local function clearAlignments()
	for i, v in next, alignments do
		v:Destroy()
	end
	
	for i, v in next, parts do
		i.CanCollide = v
	end
	
	table.clear(alignments)
	table.clear(parts)
end

local function addAlignments()
	clearAlignments()
	
	for i, v in next, workspace:GetDescendants() do
		if check(v) then
			parts[v] = v.CanCollide
			v.CanCollide = false
			
			local att = Instance.new("Attachment")
			att.Parent = v
			
			local alignp = Instance.new("AlignPosition")
			alignp.Attachment0 = att
			alignp.Attachment1 = bp.Attachment
			alignp.MaxForce = math.huge
			alignp.MaxVelocity = math.huge
			alignp.Responsiveness = math.huge
			alignp.ReactionForceEnabled = false
			alignp.ApplyAtCenterOfMass = true
			alignp.Parent = v
			
			table.insert(alignments, alignp)
		end
	end
end

---------------------

settings().Physics.AllowSleep = false

---------------------

_G.NETCON1 = plr.CharacterAdded:Connect(function()
	moder = false
	clearAlignments()
	mss("Disabled")
	
	_G.NETCON2:Disconnect()
	_G.NETCON2 = plr.Character:WaitForChild("Humanoid").Died:Connect(function()
		moder = false
		clearAlignments()
		mss("Disabled")
	end)
end)

_G.NETCON2 = plr.Character.Humanoid.Died:Connect(function()
	moder = false
	clearAlignments()
	mss("Disabled")
end)

_G.NETCON3 = ms.KeyDown:Connect(function(k)
	if k == "[" then
		if not bp or bp.Parent == nil then
			bp = Instance.new("Part")
			bp.Name = "AttachmentPart"
			bp.Transparency = 1
			bp.CanCollide = false
			bp.Anchored = true
			bp.Size = Vector3.new(0.1, 0.1, 0.1)
			bp.Parent = workspace
			
			local bodyatt = Instance.new("Attachment")
			bodyatt.Parent = bp
		end
		
		moder = not moder
		
		if moder then
			mss("Enabled")
			addAlignments()
		else
			mss("Disabled")
			clearAlignments()
		end
	end
end)

task.spawn(function()
	while task.wait() and _G.NETACTIVE do
		ct += 0.01
		
		sethiddenproperty(plr, "MaximumSimulationRadius", 10000000000)
		sethiddenproperty(plr, "SimulationRadius", 9000000000)
		plr.ReplicationFocus = workspace
		
		if bp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			bp.CFrame = (CFrame.new(plr.Character.HumanoidRootPart.Position) * CFrame.new(
				0,
				offset,
				0
			))
		end
	end
end)

task.spawn(function()
	while task.wait() and _G.NETACTIVE do
		for i, v in next, parts do
			if i then
				i.Velocity = Vector3.new(0, -36, 0)
			end
		end
	end
end)

repeat task.wait(.1) until not _G.NETACTIVE

pcall(function()
	_G.NETCON1:Disconnect()
	_G.NETCON2:Disconnect()
	_G.NETCON3:Disconnect()
	_G.NETCON1 = nil
	_G.NETCON2 = nil
	_G.NETCON3 = nil
end)

clearAlignments()
