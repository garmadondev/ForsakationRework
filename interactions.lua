--[[
	🔧 interactions.lua (unified system - legacy-compatible + modern handlers)
	📦 Roblox Studio 2021 совместимость
--]]

local interactions = {}

local playerService = game:GetService("Players")
local serverScriptService = game:GetService("ServerScriptService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local runService = game:GetService("RunService")

local remotes = replicatedStorage:WaitForChild("rems")
local clientRemotes = remotes:WaitForChild("events"):WaitForChild("client")
local serverRemotes = remotes:WaitForChild("events"):WaitForChild("server")
local MainKeyInteraction = Enum.KeyCode.E

-- Legacy support
if not remotes:FindFirstChild("events") then
	clientRemotes = remotes:WaitForChild("client")
	serverRemotes = remotes:WaitForChild("server")
end

-- Libraries
local SC_Handcuffs = require(replicatedStorage.Modules.SC_Handcuffs)

-- Game modules (with error handling for legacy compatibility)
local gameSettings = serverStorage:FindFirstChild("GameSettings") and require(serverStorage.GameSettings)
local roundModule = serverScriptService:FindFirstChild("RoundModule") and require(serverScriptService.RoundModule)
local timeModule = serverScriptService:FindFirstChild("TimeModule") and require(serverScriptService.TimeModule)
local recordModule = serverScriptService:FindFirstChild("RecordModule") and require(serverScriptService.RecordModule)
local mapService = serverScriptService:FindFirstChild("MapService") and require(serverScriptService.MapService)
local damageService = serverScriptService:FindFirstChild("DamageService") and require(serverScriptService.DamageService)

-- 🧠 Локальное состояние
local fakeServerState = {
	interactedObjects = {},
}

-- 🔄 Локальные имитации "InvokeServer" (legacy support)
local function fakeCanInteractWith(player, obj)
	if not player or not obj then return false end
	local tag = obj:FindFirstChild("Tag")
	if not tag then return false end
	if tag.Value == "Terminal" and not fakeServerState.interactedObjects[obj] then
		return true
	end
	return false
end

local function fakeGetObjectInfo(player, obj)
	if not obj then return nil end
	local info = {
		Name = obj.Name,
		Position = obj.Position,
		Distance = (obj.Position - player.Character.HumanoidRootPart.Position).Magnitude
	}
	if obj:FindFirstChild("Tag") then
		info.Type = obj.Tag.Value
	end
	return info
end

local function fakeTriggerInteraction(player, obj)
	if not fakeCanInteractWith(player, obj) then return end
	fakeServerState.interactedObjects[obj] = true
	local tag = obj:FindFirstChild("Tag")
	if tag then
		print("[FakeServer] Игрок " .. player.Name .. " активировал: " .. tag.Value)
	end
	clientRemotes:WaitForChild("InteractionResult"):FireClient(player, {
		success = true,
		object = obj.Name
	})
end

-- Client-side helper functions
local function client_dialog(obj)
	local m = obj:FindFirstChild("DialogModule")
	if not m then return end
	
	if remotes:FindFirstChild("functions") then
		remotes.functions.GameplayAction:InvokeServer(9, "Dialog", m)
	else
		-- Legacy fallback
		print("[Legacy] Dialog interaction with:", obj.Name)
	end
end

local function client_seek(model)
	if remotes:FindFirstChild("functions") then
		local callback, t = remotes.functions.LootAction:InvokeServer(1, model)
		local inventorySC = require(replicatedStorage.Modules.InventorySC)

		if callback then
			for i=1, #callback do
				local getSetting = callback[i]
				local temp_frame = inventorySC:CreateTempFrame(getSetting)
				inventorySC:ClientInitGrid(getSetting.GridRef, temp_frame, getSetting)
			end
		end
	else
		-- Legacy fallback
		print("[Legacy] Seek interaction with:", model.Name)
	end
end

-- Food Serve Stuff
local MAX_SERVE_PRODUCTS = 3

local function GetWorldSize(FullCFrame, LocalSize)
	local WorldSize = FullCFrame:VectorToWorldSpace(LocalSize)
	return Vector3.new(math.abs(LocalSize.X), math.abs(LocalSize.Y), math.abs(LocalSize.Z))
end

local function GetClosestServeAttachment(Character, Object)
	local Children = Object:GetChildren()
	local Origin = Character.Torso.Position

	local Distance = math.huge
	local Selected = nil

	for i=1, #Children do
		local Object = Children[i]

		if Object.Name == "ServeFoodAttach" then
			local TargetDistance = (Object.WorldPosition-Origin).Magnitude

			if TargetDistance < Distance then
				Distance = TargetDistance
				Selected = Object
			end
		end
	end

	return Selected
end

local function GetOffset(TargetTool)
	local Servable = TargetTool:GetAttribute("Servable")

	if typeof(Servable) == "CFrame" then
		return Servable
	end

	if typeof(Servable) == "Vector3" then
		return CFrame.new(Servable)
	end

	return CFrame.new(0, 0, 0)
end

local function CenterStuff(ServeAttachment)
	local OffsetX = 0
	local Children = ServeAttachment:GetChildren()
	local Iterations = #Children

	if Iterations > 1 then
		for i=1, Iterations do
			local Tool = Children[i]
			local RealSize = GetWorldSize(Tool:GetPivot() * GetOffset(Tool), Tool:GetExtentsSize())
			OffsetX = OffsetX + RealSize.X
		end
	end

	OffsetX = OffsetX / 2

	-- In order of size.
	for i=1, Iterations do
		for x=1, Iterations - 1 do
			local Current = Children[x]
			local Next = Children[x + 1]
			local Width1, Width2 = GetWorldSize(Current:GetPivot() * GetOffset(Current), Current:GetExtentsSize()), GetWorldSize(Next:GetPivot() * GetOffset(Next), Next:GetExtentsSize())

			if Width2.X > Width1.X then
				Children[x] = Next
				Children[x + 1] = Current
			end
		end
	end

	-- Transforming.
	local RelativePoint = ServeAttachment.WorldCFrame

	for i=1, Iterations do
		local Tool = Children[i]
		local RealSize = GetWorldSize(Tool:GetPivot() * GetOffset(Tool), Tool:GetExtentsSize())
		local Offset = Tool:GetAttribute("Servable")

		Tool:PivotTo(RelativePoint * CFrame.new(OffsetX, RealSize.Y/3, RealSize.Z/3) * GetOffset(Tool))
		OffsetX = OffsetX - RealSize.X
	end
end

-- 🌐 Публичный API (Legacy compatibility)
function interactions.CanInteractWith(player, obj)
	return fakeCanInteractWith(player, obj)
end

function interactions.GetObjectInfo(player, obj)
	return fakeGetObjectInfo(player, obj)
end

function interactions.TriggerInteraction(player, obj)
	return fakeTriggerInteraction(player, obj)
end

------------------------------------------
-- Modern Interaction Handlers
------------------------------------------

-- [1] Handcuffs/Detain interaction
interactions[1] = function(Player, Parts, IsCheck, ...)
	local Character = Player.Character
	local Cuffs = SC_Handcuffs:GetCuffs(Character)

	if Cuffs then
		for i=1, #Parts do
			local Object = Parts[i]
			local Parent = Object.Parent

			if Parent:FindFirstChild("Humanoid") then
				local TargetPlayer = game.Players:GetPlayerFromCharacter(Parent)

				if TargetPlayer and SC_Handcuffs:CanDetain(Player, TargetPlayer) then
					local Config = require(Cuffs.CuffsConfig)

					if IsCheck then
						return {Config.DetainTime or 1, "Задержать"}, Parent.Torso
					end

					if serverScriptService:FindFirstChild("GameplayModules") then
						require(serverScriptService.GameplayModules.HandcuffsLibrary):Detain(Player, TargetPlayer)
					else
						print("[Legacy] Detain interaction:", Player.Name, "->", TargetPlayer.Name)
					end
				end
			end
		end
	end
end

-- [2] Keycard stealing interaction
interactions[2] = function(Player, Parts, IsCheck, ...)
	if Player.Backpack:FindFirstChild("Карта охраника") or Player.Character:FindFirstChild("Карта охраника") then
		return
	end

	if IsCheck then
		for i=1, #Parts do
			local Object = Parts[i]
			local Humanoid = Object.Parent:FindFirstChild("Humanoid")

			if Humanoid and Humanoid.Health > 1 and Object.Name == "Torso" then
				local isPlayer = playerService:GetPlayerFromCharacter(Object.Parent)

				if isPlayer then
					local tool = isPlayer.Backpack:FindFirstChild("Карта охраника")

					if tool then
						if isPlayer:GetAttribute("Government") and Player:GetAttribute("Government") then
							return
						end

						local NotVisible = (Player.Character.Head.Position-isPlayer.Character.Head.Position).Unit:Dot(isPlayer.Character.Head.CFrame.LookVector) < 0

						if NotVisible then
							return {10, "Своровать", isPlayer}, Object
						end
					end
				end
			end
		end
	else
		local Who = ...
		local Keycard = Who.Backpack:FindFirstChild("Карта охраника")

		if Keycard then
			Keycard.Parent = Player.Backpack
			clientRemotes.ClientSynchronization:FireClient(Player, 2, "play", Player.Character.Humanoid, replicatedStorage.Debris.Pickup)
			clientRemotes.GunActionClient:FireAllClients("sound", {SoundId = "rbxassetid://2034189546", RollOffMaxDistance = 150, RollOffMinDistance = 1.5, Parent = Player.Character.Head})	
			clientRemotes.ClientSynchronization:FireClient(Who, 3, "КАРТОЧКА", "У вас своровали ключ-карту!", 10)

			local val = Instance.new("BoolValue")
			val.Name = "CanBeDropped"
			val.Value = true
			val.Parent = Keycard
		end
	end
end

-- [3] Gun box stealing interaction
interactions[3] = function(Player, Parts, IsCheck, ...)
	if Player.Team == game.Teams["Шизойды"] then
		if IsCheck then
			for i=1, #Parts do
				local obj = Parts[i]

				if obj.Name == "gunbox" then
					return {10, "Украсть", obj}, obj
				end 
			end
		else
			local Box = ...
			local GunsAble = {}
			local Children = serverStorage:GetChildren()

			for i=1, #Children do
				local obj = Children[i]

				if obj:IsA("Tool") and obj:FindFirstChild("ConfigGun") then
					table.insert(GunsAble, obj)
				end
			end

			local Gun = GunsAble[math.random(1, #GunsAble)]:Clone()
			Gun.Parent = Player.Backpack			

			clientRemotes.GunActionClient:FireAllClients("sound",{SoundId = "rbxassetid://2034189546", RollOffMaxDistance = 250, RollOffMinDistance = 2.5, Parent = Player.Character.Head})
			clientRemotes.ClientSynchronization:FireClient(Player, 2, "play", Player.Character.Humanoid, replicatedStorage.Debris.Pickup)

			-- Cleared.
			Box:Destroy()
		end
	end
end

-- [4] General interactions (doors, seats, dialog, storage)
interactions[4] = function(Player, Parts, IsCheck, ...)
	if IsCheck then		
		for i=1, #Parts do
			local Object = Parts[i]

			if Object.Parent:GetAttribute("Storage") then
				return {0, "Обыскать (E)", Object, MainKeyInteraction, client_seek}, Object.Parent
			end

			if Object:IsDescendantOf(workspace["дурка"].a1.doors) then
				return {0, "Дверь (E)", {Object, 1}, MainKeyInteraction}, Object
			end

			if Object:FindFirstChild("DialogModule") then
				return {0, "Побазарить (E)", Object, MainKeyInteraction, client_dialog}, Object
			end

			if Object:IsA("Seat") and not Object.Occupant and not Player.Character.Humanoid.SeatPart then
				return {0, "Присесть (E)", {Object, 2}, MainKeyInteraction}, Object
			end
		end
	else
		local FullConfig = ...
		local Model, Type = unpack(FullConfig)

		if Type == 1 then
			if serverScriptService:FindFirstChild("Modules") then
				local Module = require(serverScriptService.Modules.DoorModule)
				local DoorClass, Index = Module:FindDoor(Model.Parent)

				if not Index then
					DoorClass, Index = Module:FindDoor(Model.Parent.Parent)
				end

				if Index then
					Module.Types[DoorClass.Type](Player.Character, DoorClass)
				end
			else
				print("[Legacy] Door interaction")
			end
		elseif Type == 2 then
			Model:Sit(Player.Character.Humanoid)
		end
	end
end

-- [5] Extra flags and serve table interactions
interactions[5] = function(Player, Parts, IsCheck, ...) 
	for i=1, #Parts do
		local obj = Parts[i]
		local m = obj:FindFirstChild("Interact_Module")

		if m then
			local thing = require(m)

			if typeof(thing) == "function" then
				return thing(Player, obj, IsCheck, ...), obj
			end

			if runService:IsClient() then
				return {1, "Использовать"}, obj
			end

			return thing[1](Player, obj, IsCheck, ...), obj
		end

		-- Serve Table Attach.
		local Character = Player.Character
		local Humanoid = Character:FindFirstChild("Humanoid")

		if obj:FindFirstChild("ServeFoodAttach") then
			local ClosestAttachment = GetClosestServeAttachment(Character, obj)
			local Tool = Character:FindFirstChildOfClass("Tool")
			local Children = ClosestAttachment:GetChildren()
			local Iterations = #Children

			if not Humanoid.Sit and (Tool and Tool:GetAttribute("Servable")) and Iterations < MAX_SERVE_PRODUCTS then
				if IsCheck then
					return {1, "Поставить сюда "..Tool.Name}, ClosestAttachment
				end

				-- Placing at attachment.
				Character.Humanoid:UnequipTools()
				Tool.Handle.Anchored = true
				Tool.Parent = ClosestAttachment

				-- Updating Velocity and Collision.
				for _, Object in pairs(Tool:GetDescendants()) do
					if Object:IsA("BasePart") then
						Object.CanCollide = false
						Object.CanQuery = false
						Object.CanTouch = false

						Object.AssemblyLinearVelocity = Vector3.new(0,0,0) -- 2021 fix
						Object.AssemblyAngularVelocity = Vector3.new(0,0,0) -- 2021 fix
					end
				end

				-- Offsetting.
				return CenterStuff(ClosestAttachment)
			end

			if Iterations > 0 then
				if IsCheck then
					return {Iterations, "Взять всё"}, ClosestAttachment
				end

				-- Taking off.
				clientRemotes.GunActionClient:FireAllClients("sound", {SoundId = "rbxassetid://2034189546", RollOffMaxDistance = 150, RollOffMinDistance = 1.5, Parent = Character.Head})	

				for _, Tool in pairs(Children) do
					Tool.Handle.Anchored = false
					Tool.Parent = Player.Backpack
				end
			end
		end
	end
end

----------------------------------------------------------
-- Legacy server-side interactions (preserved)
----------------------------------------------------------

function interactions.ActivateTrap(trapModel)
	if trapModel:FindFirstChild("TrapScript") then
		local scriptFunc = require(trapModel.TrapScript)
		scriptFunc.Activate(trapModel)
	end
end

function interactions.SpawnLootCrate(pos, lootType)
	local lootCrateTemplate = serverStorage:FindFirstChild("LootCrate")
	if lootCrateTemplate then
		local clone = lootCrateTemplate:Clone()
		clone.Position = pos
		clone.LootType.Value = lootType or "Basic"
		clone.Parent = workspace
	end
end

function interactions.AwardPlayer(player, rewardType)
	if timeModule and rewardType == "TimeBonus" then
		timeModule.AddTime(player, 10)
	elseif recordModule and rewardType == "ScoreBoost" then
		recordModule.AddScore(player, 100)
	end
end

function interactions.DamagePlayer(player, amount)
	if damageService then
		damageService.ApplyDamage(player, amount or 10)
	end
end

function interactions.StartRound(mapName)
	if mapService and roundModule then
		mapService.LoadMap(mapName)
		roundModule.Begin()
	end
end

function interactions.EndRound()
	if roundModule then
		roundModule.End()
	end
end

function interactions.ResetInteractions()
	for obj, _ in pairs(fakeServerState.interactedObjects) do
		fakeServerState.interactedObjects[obj] = nil
	end
end

-- 🔔 Обработка попыток взаимодействия с клиента
if clientRemotes:FindFirstChild("TryInteract") then
	clientRemotes:WaitForChild("TryInteract").OnServerEvent:Connect(function(player, obj)
		if obj then
			interactions.TriggerInteraction(player, obj)
		end
	end)
end

-- Configuration for interaction system
table.insert(interactions, Vector3.new(2.5, 1.25, 2.5)) -- offset region
table.insert(interactions, 10) -- max distance to interact other objects, if above, then return

return interactions