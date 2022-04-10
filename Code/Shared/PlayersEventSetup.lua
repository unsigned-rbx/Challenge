local PlayersEventSetup = {}

function PlayersEventSetup.Initialize(events)
	for event, func in pairs(events) do
		event:Connect(func)
	end
end

return PlayersEventSetup
