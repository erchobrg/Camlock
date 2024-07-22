local CoreGui = game:GetService("StarterGui")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local isMouseLocked = false
local targetPlayer = nil

-- Variable to track the visibility state of the frame
local frameVisible = true

-- Function to toggle the visibility of the frame
local function toggleFrameVisibility()
	frameVisible = not frameVisible
	for _, player in ipairs(Players:GetPlayers()) do
		local highlight = player.Character:FindFirstChild("HighlightBillboard")
		if highlight then
			highlight.Frame.Visible = frameVisible
		end
	end
end

-- Function to lock the mouse to a player's head
local function lockMouseToPlayerHead(player)
	targetPlayer = player
	isMouseLocked = true
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

-- Function to unlock the mouse
local function unlockMouse()
	targetPlayer = nil
	isMouseLocked = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

-- Function to find the nearest player's head to the mouse position
local function findNearestPlayerHead(mousePosition)
	local nearestPlayer = nil
	local minDistance = math.huge
	local camera = workspace.CurrentCamera

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local character = player.Character
			local head = character:FindFirstChild("Head")

			if head then
				local headPosition = head.Position
				local headScreenPosition = camera:WorldToViewportPoint(headPosition)

				if headScreenPosition.Z > 0 then -- Check if head is in front of the camera
					local distance = (Vector2.new(headScreenPosition.X, headScreenPosition.Y) - mousePosition).magnitude

					if distance < minDistance then
						minDistance = distance
						nearestPlayer = player
					end
				end
			end
		end
	end

	return nearestPlayer
end

-- Function to continuously update the camera position and rotation to match the player's movement
local function updateCamera()
	if isMouseLocked and targetPlayer then
		local character = targetPlayer.Character
		if character and character:FindFirstChild("Head") then
			local head = character.Head
			if head then
				local camera = workspace.CurrentCamera
				local currentCameraCFrame = camera.CFrame
				local newCameraCFrame = CFrame.new(
					currentCameraCFrame.Position,
					head.Position
				)
				camera.CFrame = newCameraCFrame
			else
				unlockMouse() -- Unlock mouse if the player's head is missing
			end
		end
	end
end

-- Bind the lockMouseToPlayerHead function to the 'G' key press
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Z then
		if not isMouseLocked then
			local mouse = LocalPlayer:GetMouse()
			local mousePosition = Vector2.new(mouse.X, mouse.Y)
			local nearestPlayer = findNearestPlayerHead(mousePosition)
			if nearestPlayer then
				lockMouseToPlayerHead(nearestPlayer)
			end
		else
			unlockMouse()
		end
	end
end)

-- Update the camera position and rotation every frame
game:GetService("RunService").RenderStepped:Connect(updateCamera)
