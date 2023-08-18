---@class AttackBomberProto : Ship
atk_bomber_proto = {};

function atk_bomber_proto:update()
	if (self.player:hasResearch("Bomber_Cloaking")) then
		if (self:canDoAbility(AB_Cloak) == 0) then
			self:canDoAbility(AB_Cloak, 1);
		end

		if (self:isCloaked() == 0) then
			self:HP(self:HP() + 0.02);
		end
	end
end

modkit.compose:addShipProto("hgn_attackbomber", atk_bomber_proto);
