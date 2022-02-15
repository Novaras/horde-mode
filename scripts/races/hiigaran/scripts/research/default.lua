base_research = nil 
base_research = {
	
	{ 
		Name =			"InstaAdvancedFrigateTech",
		RequiredResearch =	"",                                               
		RequiredSubSystems =	"AdvancedResearch",                             
		Cost = 			0,
		Time = 			0,
		DisplayedName =		"",
		DisplayPriority =	1,                                                    
		Description =		"Instant Tech",			-- To Localize?
		TargetName = 		"Hgn_Mothership",
	},
	
	
	{
		Name =					"GraviticAttractionMines",
		RequiredResearch =		"",
		RequiredSubSystems =	"AdvancedResearch & CorvetteProduction",
		Cost = 					750,
		Time = 					40,
		DisplayedName =			"$7500",
		DisplayPriority =		2,
		Description =			"$7501",
		TargetName = 		"Hgn_MinelayerCorvette",
		Icon = Icon_Tech,
		ShortDisplayedName = "$7200",
	},

	{
		Name =					"PlatformIonWeapons",
		Required =		"",
		RequiredSubSystems =	"Research | AdvancedResearch & PlatformProduction",
		Cost = 					600,
		Time = 					100,
		DisplayedName =			"$7502",
		DisplayPriority =		24,
		Description =			"$7503",
		TargetName = 		"Hgn_IonTurret",
		Icon = Icon_Tech,
		ShortDisplayedName = "$7201",
	},
		
	{
		Name =					"DestroyerTech",
		RequiredResearch =		"",
		RequiredSubSystems =	"Research | AdvancedResearch & CapShipProduction",
		Cost = 					1500,
		Time = 					105,
		DisplayedName =			"$7507",
		DisplayPriority =		3,
		Description =			"$7508",
		TargetName = 		"Hgn_Destroyer",
		Icon = Icon_Tech,
		ShortDisplayedName = "$7203",
	},

	{
		Name =					"BattlecruiserIonWeapons",
		RequiredResearch =		"",
		RequiredSubSystems =	"AdvancedResearch & CapShipProduction",
		Cost = 					1800,
		Time = 					140,
		DisplayedName =			"$7504",
		DisplayPriority =		1,
		Description =			"$7505",
		TargetName = 		"Hgn_BattleCruiser",
		Icon = Icon_Tech,
		ShortDisplayedName = "$7202",
	},
	
	{
		Name =					"ECMProbe",
		RequiredResearch =		"",
		RequiredSubSystems =	"AdvancedResearch",
		Cost = 					400,
		Time = 					45,
		DisplayedName =			"$7509",
		DisplayPriority =		4,
		Description =			"$7510",
		TargetName = 		"Hgn_ECMProbe",
		Icon = Icon_Tech,
		ShortDisplayedName = "$7204",
	},
	
	{
		Name =					"SensDisProbe", --ProximitySensor
		RequiredResearch =		"",
		RequiredSubSystems =	"Research",
		Cost = 					500,
		Time = 					35,
		DisplayedName =			"$7650",
		DisplayPriority =		5,
		Description =			"$7651",
		TargetName = 		"Hgn_ProximitySensor",
		Icon = Icon_Tech,
		ShortDisplayedName = "$7214",
	},
	
	{
		Name = "HyperspaceDamageReductionUpgrade", 
		RequiredResearch = "", 
		RequiredSubSystems = "", 
		Cost = 0, 
		Time = 0, 
		DisplayedName = "Hyperspace Damage Reduction", 
		DisplayPriority = 950, 
		Description = "Enhances the fleet's hyperspace drive systems, reducing the hyperspace damage caused by gravity wells. Ships Only Take 10% damage when forced out of hyperspace.", 
		UpgradeType = Modifier, 
		TargetType = AllShips, 
		UpgradeName = "HyperSpaceAbortDamage", 
		UpgradeValue = 0.4, 
		TargetName = "Hgn_fleet", 
		Icon = Icon_Hyperspace, 
		ShortDisplayedName = "10% Hyperspace Exit Damage", 
		DoNotGrant = 1,
	},
	-- horde stuff
	{
		Name = "HordeShipYardBuffs_MaxHealth",
		RequiredResearch = "NOGRANT",
		RequiredSubSystems = "",
		Cost = 0,
		Time = 0,
		DisplayedName = "Horde: Shipyard Buffs Reward MaxHealth",
		ShortDisplayedName = "Horde: SY MaxHealth",
		DisplayPriority = 1000,
		Description = "Horde: Shipyard Buffs Reward MaxHealth",
		UpgradeType = Modifier,
		UpgradeName = "MaxHealth",
		UpgradeValue = 1.5,
		TargetName = "horde_shipyard",
		Icon = Icon_Tech
	},
	{
		Name = "HordeShipYardBuffs_ProdSpeed",
		RequiredResearch = "NOGRANT",
		RequiredSubSystems = "",
		Cost = 0,
		Time = 0,
		DisplayedName = "Horde: Shipyard Buffs Reward ProdSpeed",
		ShortDisplayedName = "Horde: SY ProdSpeed",
		DisplayPriority = 1001,
		Description = "Horde: Shipyard Buffs Reward ProdSpeed",
		UpgradeType = Modifier,
		UpgradeName = "BuildSpeed",
		UpgradeValue = 1.5,
		TargetType = Ship,
		TargetName = "horde_shipyard",
		Icon = Icon_Tech
	},
	{
		Name = "Fighter_FlakWeapons",
		RequiredResearch = "NOGRANT",
		RequiredSubSystems = "",
		Cost = 0,
		Time = 0,
		DisplayedName = "Horde: Fighter Strike Flak Weapons",
		ShortDisplayedName = "Horde: Fighter Strike Flak",
		DisplayPriority = 1002,
		Description = "Horde: Fighter Strike Flak Weapons",
		UpgradeType = Ability,
		UpgradeName = "UseSpecialWeaponsInNormalAttack",
		TargetType = Ship,
		TargetName = "hgn_interceptor",
		Icon = Icon_Ability
	},
	{
		Name = "Corvette_FlakWeapons",
		RequiredResearch = "NOGRANT",
		RequiredSubSystems = "",
		Cost = 0,
		Time = 0,
		DisplayedName = "Horde: Corvette Strike Flak Weapons",
		ShortDisplayedName = "Horde: Vette Strike Flak",
		DisplayPriority = 1003,
		Description = "Horde: Corvette Strike Flak Weapons",
		UpgradeType = Ability,
		UpgradeName = "UseSpecialWeaponsInNormalAttack",
		TargetType = Ship,
		TargetName = "hgn_assaultcorvette",
		Icon = Icon_Ability
	},
	{ -- this one we just check if done, so we can do a callback (`custom_code/../horde/..`)
		Name = "Bomber_Cloaking",
		RequiredResearch = "NOGRANT"
	},
	{
		Name = "Pulsar_EMP",
		RequiredResearch = "NOGRANT",
		UpgradeType = Ability,
		UpgradeName = "UseSpecialWeaponsInNormalAttack",
		TargetType = Ship,
		TargetName = "hgn_pulsarcorvette"
	},
	{
		Name = "Delayed_Healing",
		RequiredResearch = "NOGRANT"
	}
}

-- Add these items to the research tree!
for i,e in base_research do
	research[res_index] = e
	res_index = res_index+1
end


base_research = nil 
