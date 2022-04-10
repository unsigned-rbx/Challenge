local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

local modules = replicatedStorage.Modules
local animation = modules.Animations
local assets = replicatedStorage.Assets

local playerModule = require(modules.Player)
local guiModule = require(modules.GUI)
local userInput = require(script.UserInput)
local mobsAnimation = require(animation.Mobs)

local sharedModules = modules.Shared
local playersEventSetup = require(sharedModules.PlayersEventSetup)
local funcLib = require(sharedModules.FunctionLibrary)
local remoteSetup = require(sharedModules.RemoteSetup)
local config = require(sharedModules.Configuration)
local stageHandler = require(modules.StageHandler)

local player = players.LocalPlayer

local remote = replicatedStorage.Remote
local events = {
	Remote = {
		Combat = {
			
		},
		Stage = {
			SetupStage = function(stageObject, disposePrevious)
				if disposePrevious then
					stageHandler.Dispose()					
				end
				stageHandler.RequestStart(stageObject)
			end,
			Dispose = function(finished)
				local message = "Leaving Dungeon"
				
				if finished then
					message = "Congratulations on clearing the dungeon!"
				end
				
				guiModule.ShowLoadingScreen("Game")
				guiModule.UpdateLoadingScreenTask(message) task.wait(3)
				player.Character:PivotTo(CFrame.new(Vector3.new(15,15,15))) task.wait(2.5)
				stageHandler.Dispose(true)
				guiModule.HideLoadingScreen()	
			end,
			Progress = function(updateType, value)
				if updateType == "UpdateMobCount" then
					guiModule.UpdateRunDetails("MobsLeft", value)	
				end
			end,
		},
		Animation = {
			Mob = function(data, action)
				coroutine.wrap(function()
					if action == "Setup" then
						mobsAnimation.Spawn(data)
					elseif action == "Move" then
						mobsAnimation.MoveTo(data)
					elseif action == "Kill" then
						mobsAnimation.Kill(data)
					elseif action == "Damage" then
						mobsAnimation.Damage(data)
					end
				end)()
			end
		},
		Player = {
			UpdateData = function(data)
				playerModule.Data = data
				guiModule.SetupNameplate(nil, player.DisplayName, data.MaxHealth)
			end,
			Died = function(position)
				guiModule.ShowLoadingScreen(stageHandler.CurrentIndex)
				guiModule.UpdateLoadingScreenTask("Respawning Character") task.wait(3)
				player.Character:PivotTo(CFrame.new(position)) task.wait(2.5)
				guiModule.HideLoadingScreen()	
			end,
			SetCollisionGroup = function(plr)
				coroutine.wrap(function()
					task.wait(2)
					funcLib.SetCollisionGroup(plr.Character, "Players")
				end)()
			end,
			Damage = function(newHealth)
				if player.Character then
					local data = playerModule.Data
					
					funcLib.TweenModel(player.Character, "Color", 
						Color3.new(1, 0.435294, 0.443137), 0.15, true, false)	
					guiModule.UpdateNameplate(nil, newHealth, data.MaxHealth)
					guiModule.AddNotification(
						false, 
						string.format("Hit you: %s HP", tostring(newHealth-data.CurrentHealth)), 
						"Damage"
					)
					
					data.CurrentHealth = newHealth
				end
			end,
			
			UnequipWeapon = function()
				playerModule.UnequipWeapon()
			end,
			EquipWeapon = function(swordData)
				playerModule.EquipWeapon(swordData)
			end,
		}
	},
	UserInput = { -- UserInputEvents
		InputBegan = {
			[Enum.UserInputType.MouseButton1] = function()
				local result = remote.Combat.Server.RequestAttack:InvokeServer()
				if not result then return end
				
				local mobObject = result.Object
				
				mobsAnimation.Damage(mobObject, result.PreviousHealth, result.Damage)	
								
				if mobObject.IsDead then
					guiModule.UpdateRunDetails("MobsLeft", result.MobsLeft)
					mobsAnimation.Kill(mobObject.Id, result.Loot)
				end
				
			end,
			[Enum.UserInputType.Keyboard] = function(input: InputObject)
				if (input.KeyCode == Enum.KeyCode.E) then
					
				end	
			end,
		},
		InputEnded = {
			[Enum.UserInputType.MouseButton1] = function()
				playerModule.Holding = false
			end,
		}
	},

}


local ClientEvent = {}

function ClientEvent.Initialize()
	remoteSetup.Initialize(events.Remote)
	userInput.Initialize(events.UserInput)
	guiModule.InitializeButtons()
end

return ClientEvent
