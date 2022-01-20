if (modkit == nil) then dofilepath("data:scripts/modkit.lua"); end

rules = modkit.campaign.rules;

local rule_a = rules:make(
	"A",
	function (self)
		local gametime = Universe_GameTime();
		print("hello from rule fn A! (" .. gametime .. ")");

		if (gametime > 10) then
			return "done bruh";
		end
	end,
	1
);

local rule_b = rules:make(
	"my_rule",
	function (self)
		local gametime = Universe_GameTime();
		print("hello from rule fn my_rule! (" .. gametime .. ")");

		if (random() < 0.5) then
			return "my_rule fin";
		end
	end,
	1
);

local rule_c = rules:make(
	"C2",
	function (self)
		local gametime = Universe_GameTime();
		print("hello from rule fn C2! (" .. gametime .. ")");

		if (random() < 0.1) then
			return "C2 finish";
		end
	end,
	1
);

rules:begin(rule_a);
rules:begin(rule_b);
rules:begin(rule_c);

rules:on("A and (my_rule or C2)", function (rules)
	print("first listener!");
end);

rules:on("(A and my_rule) or C2", function (rules)
	print("second listener!");
end);
