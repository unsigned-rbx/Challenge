local serverScriptService = game:GetService("ServerScriptService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

-- folders
local sharedModules = replicatedStorage.Modules.Shared
local assets = replicatedStorage.Assets
local remote = replicatedStorage.Remote
local modules = serverScriptService.Modules

local stageObj = require(modules.Objects.Stage)

-- modules
local remoteSetup = require(sharedModules.RemoteSetup)
local playersEventSetup = require(sharedModules.PlayersEventSetup)
local playersManager = require(modules.PlayersManager)
local config = require(sharedModules.Configuration)
local dataHandler = require(modules.DataHandler)

local events = {
	Remote = {
		Combat = {
			RequestAttack = function(player: Player)
				local playerObject = playersManager.Players[player.UserId]
				if playerObject.Stage then
					local position = playerObject:GetCharacterPosition()
					local damage = playerObject:GetDamage()
					local nearestMob = playerObject.Stage:FindNearestMob(position)
					
					if nearestMob and nearestMob.CurrentHealth > 0 then
						local result = nearestMob:Damage(damage)
						
						-- generate loot if mob is dead
						if result.Object.IsDead then
							result["Loot"] = playerObject:GenerateLoot()
							result["MobsLeft"] = playerObject.Stage:MobCount() - 1
							
							coroutine.wrap(function()
								task.wait(1)
								playerObject.Stage.Mobs[nearestMob.Id] = nil
							end)()
						end
						
						return result
					end
				end
			end,
		},
		Stage = {
			RequestStart = function(player: Player)
				local playerObject = playersManager.Players[player.UserId]
				if playerObject.InStage then return nil end
				playerObject.InStage = true
				
				playerObject.Stage = stageObj.new(1, playerObject)
				playerObject.Stage:SpawnMobs()
				
				remote.Stage.Client.SetupStage:FireClient(player, playerObject.Stage, false)
			end,
			
			RequestQuit = function(player: Player)
				local playerObject = playersManager.Players[player.UserId]
				
				if playerObject.Stage then
					playerObject.Stage:Dispose()
					playerObject.Stage = nil
					playerObject.InStage = false
					
					remote.Stage.Client.Dispose:FireClient(player)
				end
			end,
			
			RequestNext = function(player: Player)
				local playerObject = playersManager.Players[player.UserId]
				
				-- dungeon cleared				
				if playerObject.Stage and playerObject.Stage:MobCount() == 0 then
					local newIndex = playerObject.Stage.Index+1

					-- dispose old map
					playerObject.Stage:Dispose()
					
					if (newIndex > 5) then
						playerObject.Stage = nil
						playerObject.InStage = false

						remote.Stage.Client.Dispose:FireClient(player, true)
						return
					end
					
					-- create new stage
					playerObject.Stage = stageObj.new(newIndex, playerObject)
					playerObject.Stage:SpawnMobs()
					
					remote.Stage.Client.SetupStage:FireClient(player, playerObject.Stage, true)
				end
			end,
		},
		Loot = {
			ClaimLoot = function(player: Player, identifier)
				local playerObject = playersManager.Players[player.UserId]
				return playerObject:ClaimLoot(identifier)
			end,
		},
		Player = {
			UpdateHealth = function(player, damage)
				local playerObject = playersManager.Players[player.UserId]
				local result = playerObject:UpdateHealth(damage)
				print("From server HP:", result)	
				
				remote.Player.Client.Damage:FireClient(player, result)
			end,
		}
	},
	Players = {
		[players.PlayerAdded] = function(player: Player)
			local playerData = playersManager.SetupPlayer(player)
			
			-- set collisionGroup of other players
			for _, plr in pairs(players:GetPlayers()) do
				remote.Player.Client.SetCollisionGroup:FireClient(player, plr)
			end
			
			player.CharacterAdded:Connect(function(character)
				playerData:ResetCharacterData()
				local startPosition = nil
				
				if playerData.Stage then
					local stageData = config.Maps[playerData.Stage.Index]
					remote.Player.Client.Died:FireClient(player, stageData.StartPosition)
				end
					
				remote.Player.Client.SetCollisionGroup:FireAllClients(player)
				remote.Player.Client.UpdateData:FireClient(player, {
					CurrentHealth = playerData.CurrentHealth,
					MaxHealth = playerData.MaxHealth
				})
				
				task.wait(2)
				remote.Player.Client.EquipWeapon:FireClient(player, playerData.EquippedWeapon)
			end)
		end,
		[players.PlayerRemoving] = function(player: Player)
			local playerObject = playersManager.Players[player.UserId]
			dataHandler.SetData(player, playerObject)
		end,
	}
}
	
local ServerEvent = {}

-- set up all of the events
function ServerEvent.Initialize()
	remoteSetup.Initialize(events.Remote)
	playersEventSetup.Initialize(events.Players)
end

return ServerEvent
