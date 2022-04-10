local uis = game:GetService("UserInputService")

local UserInput = {}

function UserInput.Initialize(events)
	for inputType, category in pairs(events) do
		local event = uis[inputType]
		if not event then return end

		event:Connect(function(input, gameProcessed)
			if gameProcessed then return end

			local inputType = category[input.UserInputType]		
			if inputType then inputType(input) end							
		end)
	end
end

return UserInput
