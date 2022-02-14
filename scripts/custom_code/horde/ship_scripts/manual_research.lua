---@class AttackBomberProto : Ship
local atk_bomber_proto = {
	previous_hp = 1
};

function atk_bomber_proto:update()
	if (Player_HasResearch(0, "Bomber_Cloaking") == 1) then
		if (self:canDoAbility(AB_Cloak) == 0) then
			self:canDoAbility(AB_Cloak, 1);
		end

		if (self:isCloaked() == 0) then
			self:HP(self:HP() + 0.02);
		end
	end
end

modkit.compose:addShipProto("hgn_attackbomber", atk_bomber_proto);


-- ---@class PulsarProto : Ship
-- local pulsar_proto = {};

-- function pulsar_proto:update()
-- 	if (Player_HasResearch(0, "pulsar_emp") == 1) then
-- 		print("")
-- 	end
-- end

-- modkit.compose:addShipProto("hgn_pulsarcorvette", pulsar_proto);