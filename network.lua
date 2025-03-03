local players = game:GetService("Players")
local plr = players.LocalPlayer

local mode = "y"
local active = false
local range = 0
local count = 0
local speed = 0
local net = {}
local claimForce = Vector3.new(0, 36 * 5, 0)

local gui = game:GetObjects("rbxassetid://118292817263083")[1]
gui.Parent = game:GetService("CoreGui")


---  FUNCTIONS  ---


local function check(v)
	return v:IsA("BasePart") and
		not v.Anchored and
		not players:GetPlayerFromCharacter(v.Parent) and
		not players:GetPlayerFromCharacter(v.Parent.Parent)
end

local function clearNet()
	for _, v in net do
		if not v.part then continue end
		
		v.partatt:Destroy()
		v.bppart:Destroy()
		v.align:Destroy()
		v.torque:Destroy()
	end
	
	table.clear(net)
end

local function addNet()
	clearNet()

	for _, v in workspace:GetDescendants() do
		if not check(v) then continue end
		
		local bp = Instance.new("Part")
		bp.Name = "AttachmentPart"
		bp.Transparency = 1
		bp.CanCollide = false
		bp.Anchored = true
		bp.Size = Vector3.new(0.1, 0.1, 0.1)
		bp.Parent = v

		local patt = Instance.new("Attachment")
		patt.Parent = v
		
		local bpatt = Instance.new("Attachment")
		bpatt.Parent = bp

		local alignp = Instance.new("AlignPosition")
		alignp.Attachment0 = patt
		alignp.Attachment1 = bpatt
		alignp.MaxForce = math.huge
		alignp.MaxVelocity = math.huge
		alignp.Responsiveness = 200
		alignp.ReactionForceEnabled = false
		alignp.ApplyAtCenterOfMass = true
		alignp.Parent = v
		
		local tq = Instance.new("Torque")
		tq.Torque = Vector3.new(1e5, 1e5, 1e5)
		tq.Parent = v

		table.insert(net, {
			part = v,
			partatt = patt,
			bppart = bp,
			align = alignp,
			torque = tq
		})
		
		v.CanCollide = false
	end
end

local function op(fn)
	for _, v in net do
		if not v.part then continue end
		
		fn(v)
	end
end


---  CHAR CONNECTIONS  ---


local con1
local con2
local con3

con1 = plr.CharacterAdded:Connect(function()
	active = false
	clearNet()
	con2:Disconnect()
	
	gui.Frame.Title.Text = "   Funny Network Gui Thingy | INACTIVE"

	con2 = plr.Character:WaitForChild("Humanoid").Died:Connect(function()
		active = false
		clearNet()
		
		gui.Frame.Title.Text = "   Funny Network Gui Thingy | INACTIVE"
	end)
end)

con2 = plr.Character:WaitForChild("Humanoid").Died:Connect(function()
	active = false
	clearNet()
	
	gui.Frame.Title.Text = "   Funny Network Gui Thingy | INACTIVE"
end)


---  GUI HANDLING  ---


gui.Frame.Range.FocusLost:Connect(function()
	range = tonumber(gui.Frame.Range.Text)
end)

gui.Frame.Speed.FocusLost:Connect(function()
	speed = tonumber(gui.Frame.Speed.Text) / 1000
end)

gui.Frame.Stop.MouseButton1Click:Connect(function()
	active = false
	clearNet()

	gui.Frame.Title.Text = "   Funny Network Gui Thingy | INACTIVE"
end)

for _, v in gui.Frame.Container:GetChildren() do
	if v:IsA("TextButton") then
		v.MouseButton1Click:Connect(function()
			active = true
			mode = string.lower(v.Name)
			
			addNet()
			
			gui.Frame.Title.Text = "   Funny Network Gui Thingy | ACTIVE"
		end)
	end
end

--- LOOPS ---

task.spawn(function()
	while task.wait() do
		sethiddenproperty(plr, "MaximumSimulationRadius", 10000000000)
		sethiddenproperty(plr, "SimulationRadius", 9000000000)
		plr.ReplicationFocus = workspace
		
		local toremove = {}
		
		for i, v in net do
			if v.part and v.part.Parent ~= nil then
				v.part.Velocity = claimForce
			else
				table.insert(toremove, i)
			end
		end
		
		for _, v in toremove do
			net[v].partatt:Destroy()
			net[v].bppart:Destroy()
			net[v].align:Destroy()
			net[v].torque:Destroy()
			table.remove(net, v)
		end
	end
end)

task.spawn(function()
	while task.wait(1 / 8) do
		if not active then continue end
		if not plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then continue end
		
		count += speed
		
		if mode == "x" then
			
			local pos = plr.Character.HumanoidRootPart.Position + Vector3.new(range, 0, 0)
			
			op(function(v)
				v.bppart.Position = pos
			end)
			
		elseif mode == "y" then
			
			local pos = plr.Character.HumanoidRootPart.Position + Vector3.new(0, range, 0)
			
			op(function(v)
				v.bppart.Position = pos
			end)
			
		elseif mode == "z" then
			
			local pos = plr.Character.HumanoidRootPart.Position + Vector3.new(0, 0, range)
			
			op(function(v)
				v.bppart.Position = pos
			end)
			
		elseif mode == "crazy" then
			
			op(function(v)
				v.bppart.Position = plr.Character.HumanoidRootPart.Position + Vector3.new(
					math.random(-range, range),
					math.random(-10, 10),
					math.random(-range, range)
				)
			end)
			
		elseif mode == "orbit" then
			
			local pos = plr.Character.HumanoidRootPart.Position + Vector3.new(
				math.sin(count) * range,
				0,
				math.cos(count) * range
			)
			
			op(function(v)
				v.bppart.Position = pos
			end)
			
		end
	end
end)
