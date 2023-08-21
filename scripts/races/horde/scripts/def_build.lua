
if (modkit == nil or modkit.table == nil) then
	dofilepath("data:scripts/modkit/table_util.lua");
end

print("ok");

local races = {
	"hiigaran",
	"vaygr"
};

local combined = {};
for _, race in races do
	build = nil;
	dofilepath("data:scripts/races/" .. race .. "/scripts/def_build.lua");
	for _, v in build do
		combined[modkit.table.length(combined) + 1] = v;
	end
end

-- prints after load!
modkit.table.printTbl(combined, "combined def_build files", 1);

-- engine defines

Ship = 0;
SubSystem = 1;
build = combined;
