local PathfindingService = game:GetService("PathfindingService")
local module = {}
--[[
	Pathfinding Made By [AQUA#5677 - Discord, frosty_aqua - Roblox]
	To Use Simply Call The Function From The Module Like So:
	local module = require(MODULE HERE)
	*module.pathfind(FOLLOWER'S MAINPART,
	DESTINATION MAINPART,
	FOLLOWER'S HUMANOID,
	THE "FATHER" OBJECT [Which Contains The Humanoid and the Main Object For The Follower),
	[TRUE OR FALSE] WHETHER TO KEEP TRACKING THE TARGET AFTER REACHING IT*
--]]
--[[ Please Note You Need To Wait At Least 5 Seconds Before Using Again
	 On The Same Object To Prevent Lag
--]]
module.pathfind = function(obj, destination, hum, father, keepFollowing)
	local function preIdentification()
		if obj:IsA("Model") then
			obj = obj.PrimaryPart
		end
		if destination:IsA("Model") then
			destination = destination.PrimaryPart
		end
	end
	preIdentification()
	if not script.Running.Value then
	local radiusTable = {}
	for i, part in pairs(father:GetChildren()) do
		if part:IsA("Part") or part:IsA("MeshPart") then
			local x = math.abs(part.Position.X - obj.Position.X)
			table.insert(radiusTable, x)
		end
	end
	table.sort(radiusTable) 
	local agentRadius = (radiusTable[#radiusTable]) * 2
	local heightTable = {}
	for i, part in pairs(father:GetChildren()) do
		if part:IsA("Part") or part:IsA("MeshPart") then
			local y1 = part.Position.Y
			for i, sPart in pairs(father:GetChildren()) do
				if sPart:IsA("Part") or sPart:IsA("MeshPart") then
					if sPart ~= part then
						local y2 = sPart.Position.Y
						local y = math.abs(y1 - y2)
						table.insert(heightTable, y)
					end
				end
			end
		end
	end
	table.sort(heightTable) 
	local agentHeight = (heightTable[#heightTable]) * 2
	local agentParams = {
		["AgentRadius"] = agentRadius,
		["AgentHeight"] = agentHeight,
		["AgentCanJump"] = true
	}
	local path = PathfindingService:CreatePath(agentParams)
	local folder = Instance.new("Folder", workspace)
	folder.Name = father.Name .. " Waypoints"
	local waypoints = {}
	local currentIndex = 1
	local start = obj.Position
	local finish = destination.Position
	local exit = false
	script.Disable:GetPropertyChangedSignal("Value"):Connect(function()
		if script.Disable.Value and not exit then
			exit = true
			local new = father:Clone()
			new.Parent = father.Parent
			father:Destroy()
			folder:Destroy()
			script.Cooldown.Value = 5
			return
		end
	end)
	local function followPath(reCalculate)
		folder:ClearAllChildren()
		waypoints = {}
		path:ComputeAsync(start, finish)
		if not exit then
			if path.Status == Enum.PathStatus.Success then
				script.Running.Value = true
				waypoints = path:GetWaypoints()
				for i, waypoint in pairs(waypoints) do
					local part = Instance.new("Part")
					part.Name = i
					part.Transparency = 1
					part.Shape = "Ball"
					part.Material = "Neon"
					part.Size = Vector3.new(0.6, 0.6, 0.6)
					part.Position = waypoint.Position
					part.Anchored = true
					part.CanCollide = false
					part.Parent = folder
					local val = Instance.new("IntValue", part)
					val.Name = "Number"
					val.Value = part.Name
				end 
				if not reCalculate then
					currentIndex = 1
				end
				hum:MoveTo(folder[currentIndex].Position)
			else
				script.Disable.Value = true
				hum:MoveTo(obj.Position)
				return
			end
		else
			return
		end
	end
	local function reached(status)
		if status then
			if currentIndex < #waypoints then
				currentIndex = currentIndex + 1
				hum:MoveTo(folder[currentIndex].Position)
			end
		end
	end
 
	local function blocked(blockedIndex)
		if blockedIndex > currentIndex then
			script.Disable.Value = true
		end
	end
	path.Blocked:Connect(function(index)
		if not exit then 
			blocked(index)
		end
	end)
	hum.MoveToFinished:Connect(function(status)
		if not exit then
			reached(status)
		end
	end)
	followPath(false)
	destination:GetPropertyChangedSignal("Position"):Connect(function()
		if not exit then
			start = obj.Position
			finish = destination.Position
			followPath(true)
		end
	end)
	obj:GetPropertyChangedSignal("Position"):Connect(function()
		if not exit then
			start = obj.Position
			finish = destination.Position
			followPath(true)
		end
	end)
	obj.Touched:Connect(function(hit)
		wait()
		local oldPosition = obj.Position
		if not exit then
			if script.Running.Value then
				wait(0.075)
				local newPosition = obj.Position
				if (oldPosition - newPosition).magnitude < 1 then
					hum.Jump = true
				end
			end
		end
	end)
	while wait() do
		if not exit then
			local delta = (obj.Position - destination.Position).magnitude
			if delta < 7.5 then
				if not keepFollowing then
					script.Disable.Value = true
					return
				end
			end
		else
			return
		end
	end
end
end

return module
