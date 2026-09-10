local StudioTestService = game:GetService("StudioTestService")

local result = StudioTestService:ExecuteMultiplayerTestAsync(2, "GATE2_AR")
print("GATE2_PARENT_RESULT", result)
return {
    result = result,
    type = "GATE2_PARENT_RESULT",
}
