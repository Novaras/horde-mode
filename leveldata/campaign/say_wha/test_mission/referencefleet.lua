-- reference fleet for this level

Fleet = 
{
    -- these are the ships we expect the player to have:
    {
        Type = "Hgn_Mothership",
        Number = 1,
    },
    {
        Type = "Hgn_ResourceCollector",
        Number = 6,
    },
}

-- and we think they should have this much money:
RUs = 3000

--Load expanded options
dofilepath("data:scripts/playerspatch/playerspatch_sp_util.lua")
RefMissionDifficultyScale = GetMissionDifficultyScale()

multiplierForExtraShips = RefMissionDifficultyScale
multiplierForExtraRU = RefMissionDifficultyScale


-- lol, so when you kill enemies, they can drop powerups
-- i.e it makes the units close to where it gets picked up gain some ability or weapon upgrade