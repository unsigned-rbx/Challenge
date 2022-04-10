local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

-- constants
local LOGGING_GROUP = "Scheduler"
local sharedModules = replicatedStorage.Modules.Shared
local loggingService = require(sharedModules.LoggingService)

local Scheduler = {}
Scheduler.Connection = nil
Scheduler.Jobs = {}

function Scheduler.Connect(identifier, call, intervalInMinutes, maxCalls)
	Scheduler.Jobs[identifier] = {
		Call = call,
		IntervalInMinutes = intervalInMinutes or -1,
		MaxCalls = maxCalls or -1,
		PreviousCall = 0
	}
	
	if Scheduler.Jobs[identifier] then
		loggingService.Log(string.format("Connected %s to jobs pool", identifier), LOGGING_GROUP)
	end
end

function Scheduler.Disconnect(identifier)
	Scheduler.Jobs[identifier] = nil
	loggingService.Log(string.format("Disconnected %s from jobs pool", identifier), LOGGING_GROUP)
end

function Scheduler.Execute(identifier, job)
	if (job.MaxCalls == 0) then
		Scheduler.Jobs[identifier] = nil
		loggingService.Log(string.format("Lifetime ended for: %s", identifier), LOGGING_GROUP)
	elseif (os.clock() > (job.PreviousCall + job.IntervalInMinutes)) then
		job.PreviousCall = os.clock()
		job.Call()

		if job.MaxCalls > 0 then job.MaxCalls -= 1 end	
		loggingService.Log(string.format("Executing %s", identifier), LOGGING_GROUP)
	end
end

function Scheduler.Run(identifier)
	if identifier and Scheduler.Jobs[identifier] then
		Scheduler.Jobs[identifier].Call()	
	else
		for identifier, job in pairs(Scheduler.Jobs) do
			Scheduler.Execute(identifier, job)
		end
	end
end

function Scheduler.Start()
	loggingService.Log("Starting", LOGGING_GROUP)
	Scheduler.Connection = runService.Heartbeat:Connect(Scheduler.Run)
end

function Scheduler.Stop()
	loggingService.Log("Stopping", LOGGING_GROUP)
	if Scheduler.Connection and Scheduler.Connection.Connected then
		Scheduler.Connection:Disconnect()
	end
end

function Scheduler.Dispose()
	Scheduler.Stop()
	Scheduler.Connection = nil
	Scheduler.Jobs = nil
	loggingService.Log("Disposed", LOGGING_GROUP)
end

return Scheduler
