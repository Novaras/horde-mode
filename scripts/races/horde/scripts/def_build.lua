
if (modkit == nil and modkit.table == nil) then
	dofilepath("data/scripts/modkit/table_util.lua");
end

print("ok");

local races = {
	"hiigaran",
	"vaygr"
};

local combined = {};
for _, race in races do
	dofilepath("data:scripts/races/" .. race .. "/scripts/def_build.lua");
	for _, v in build do
		combined[modkit.table.length(combined) + 1] = v;
	end
end

-- prints after load!
-- modkit.table.printTbl(combined, "combined hgn + vgr");