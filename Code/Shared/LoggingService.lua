local LoggingService = {}

function LoggingService.GetLoggingType(loggingLevel)
	if loggingLevel then
		return print
	else
		return warn
	end
end

function LoggingService.Log(message, category, loggingLevel)
	local loggingType = LoggingService.GetLoggingType(loggingLevel)
	--loggingType(string.format("[%s]: %s", category, message))
end

return LoggingService
