base_research = nil 
base_research = {
	-- this tech is used so we can tell which race a player is during gametime
	{
		Name = "RaceHorde",
		RequiredResearch = "",
		RequiredSubSystems = "",
		Cost = 0,
		Time = 0,
		DisplayedName = "RaceHorde",
		ShortDisplayedName = "RaceHorde",
		DisplayPriority = 99,
		Description = "Used to indicate race via research",
		Icon = Icon_Tech,
		DoNotGrant = 1,
	}
}

-- Add these items to the research tree!
for _, e in base_research do
	research[res_index] = e;
	res_index = res_index + 1;
end

print("MODKIT INDICATOR TECH DONE FOR HORDE");

base_research = nil;
