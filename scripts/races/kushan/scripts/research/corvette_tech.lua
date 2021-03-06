base_research = nil 
base_research = {
	{
		Name = "CorvetteDamageLevel1", 
		RequiredResearch = "", 
		RequiredSubSystems = "Research", 
		Cost = 1200, 
		Time = 60, 
		DisplayedName = "Upgradable base damage for HW1 corvettes", 
		DisplayPriority = 1, 
		Description = "+16% corvette damage", 
		UpgradeName = "WeaponDamage", 
		UpgradeValue = 0.875,
		UpgradeType = Modifier,
		TargetName = "Corvette", 
		TargetType = Family,
		Icon = Icon_Tech, 
		ShortDisplayedName = "Corvette Damage lvl 1",
	},
	{
		Name = "CorvetteDamageLevel2", 
		RequiredResearch = "CorvetteDamageLevel1", 
		RequiredSubSystems = "Research", 
		Cost = 1200, 
		Time = 65, 
		DisplayedName = "Upgradable base damage for HW1 corvettes", 
		DisplayPriority = 2, 
		Description = "+14% corvette damage", 
		UpgradeName = "WeaponDamage", 
		UpgradeValue = 1,
		UpgradeType = Modifier,
		TargetName = "Corvette",
		TargetType = Family,
		Icon = Icon_Tech, 
		ShortDisplayedName = "Corvette Damage lvl 2",
	},
	{
		Name =			"CorvetteDrive",
		RequiredResearch =	"",
		RequiredSubSystems =	"Research",
		Cost = 			1000,
		Time = 			75,
		DisplayedName =		"$11516",
		ShortDisplayedName =	"$11516",
		DisplayPriority =		21,
		Description =		"$11517",
		Icon = 			Icon_Build,
		TargetName =		"Kus_LightCorvette",
	},
	{
		Name =			"CorvetteChassis",
		RequiredResearch =	"CorvetteDrive",
		RequiredSubSystems =	"Research",
		Cost = 			700,
		Time = 			60,
		DisplayedName =		"$11522",
		ShortDisplayedName =	"$11522",
		DisplayPriority =		22,
		Description =		"$11523",
		Icon = 			Icon_Build,
		TargetName =		"Kus_SalvageCorvette",
	},
	{
		Name =			"HeavyCorvetteUpgrade",
		RequiredResearch =	"CorvetteChassis",
		RequiredSubSystems =	"Research",
		Cost = 			400,
		Time = 			30,
		DisplayedName =		"$11518",
		ShortDisplayedName =	"$11518",
		DisplayPriority =		23,
		Description =		"$11519",
		Icon = 			Icon_Build,
		TargetName =		"Kus_HeavyCorvette",
	},
	{
		Name =			"FastTrackingTurrets",
		RequiredResearch =	"CorvetteChassis",
		RequiredSubSystems =	"Research",
		Cost = 			500,
		Time = 			40,
		DisplayedName =		"$11510",
		ShortDisplayedName =	"$11510",
		DisplayPriority =		24,
		Description =		"$11511",
		Icon = 			Icon_Build,
		TargetName =		"Kus_MultiGunCorvette",
	},
	{
		Name =			"MinelayingTech",
		RequiredResearch =	"CorvetteChassis",
		RequiredSubSystems =	"Research",
		Cost = 			1100,
		Time = 			80,
		DisplayedName =		"$11520",
		ShortDisplayedName =	"$11520",
		DisplayPriority =		25,
		Description =		"$11521",
		Icon = 			Icon_Build,
		TargetName =		"Kus_MinelayerCorvette",
	},	

}

-- Add these items to the research tree!
for i,e in base_research do
	research[res_index] = e
	res_index = res_index+1
end

base_research = nil 
