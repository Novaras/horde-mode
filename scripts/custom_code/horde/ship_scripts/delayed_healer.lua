-- Delayed healer
-- A delayed healer will begin healing back some lost HP after a period of taking no damage.
-- If interrupted while healing, the heal is cancelled and the process begins again from whatever
-- HP the interruption occured at (so it's effective to interrupt the healing process).

---@class DelayedHealerProto : Ship
delayed_healer_proto = {
	previous_hp = 1,
	damage_data = nil,
	healing_data = nil,
	debounce_period = 10,
	heal_proportion = 0.5,
	heal_steps = 8,
	activation_threshold = 0.1
};

function delayed_healer_proto:playerHasHealerResearch()
	return self.player:hasResearch("Delayed_Healing");
end

-- DAMAGE PHASE
-- When we start losing HP, we want to track how much we've lost in addition to the latest
-- tick where we were still taking damage.

function delayed_healer_proto:initTrackingDamage()
	self.damage_data = {
		initial_damaged_hp = self.previous_hp,
		latest_tick = self:tick()
	};
end

function delayed_healer_proto:updateTrackingDamage()
	self.damage_data.latest_tick = self:tick();
	self.damage_data.hp_lost = self.damage_data.initial_damaged_hp - self:HP();
end


function delayed_healer_proto:finishTrackingDamage()
	self.damage_data = nil;
end

-- HEALING PHASE
-- If we went through a damage phase, we can now start a healing phase.
-- Only begin after a certain debounce period.

function delayed_healer_proto:initHealing()
	self.healing_data = {
		heal_target =  self:HP() + self.damage_data.hp_lost * self.heal_proportion,
		initial_healing_hp = self:HP()
	};
end

function delayed_healer_proto:doHealing()
	local hp_to_heal = ((self.healing_data.heal_target - self.healing_data.initial_healing_hp) / self.heal_steps);
	self:HP(self:HP() + hp_to_heal);

	self:playEffect("blue_flash", 4);
end

function delayed_healer_proto:finishHealing()
	self.healing_data = nil;
end

function delayed_healer_proto:finishAll(effect)
	self:finishTrackingDamage();
	self:finishHealing();
	if (effect) then
		self:playEffect(effect, 5);
	end
end

function delayed_healer_proto:update()
	if (self:playerHasHealerResearch() and self:HP() < 0.98) then
		if (self:HP() < self.previous_hp) then -- we took damage since last tick
			if (self.healing_data) then -- if we were healing, clear the entire process and any tracking data
				self:finishAll("red_flash");
			end

			if (self.damage_data == nil) then
				self:initTrackingDamage();
			else
				self:updateTrackingDamage();
			end
		elseif (self.damage_data) then -- we took damage recently, but at least more than a tick ago
			local debounce_period_ended = self:tick() >= self.damage_data.latest_tick + self.debounce_period;
			if (debounce_period_ended) then -- if it was long enough ago that the debounce period is over
				local pass_threshold = self.damage_data.hp_lost > self.activation_threshold;
				if (pass_threshold) then -- and we took enough to pass threshold
					if (self.healing_data == nil) then
						self:initHealing();
					end
					if (self:HP() < self.healing_data.heal_target) then -- still need to heal...
						self:doHealing();
					else -- all done
						self:finishAll("green_flash");
					end
				else -- otherwise, pretend nothing happened
					self:finishAll();
				end
			end
		end

		-- if (self.tracking_data) then
		-- 	print("TRACKING DATA - " .. self:tick());
		-- 	modkit.table.printTbl(self.tracking_data);
		-- 	print("cur hp: " .. self:HP());
		-- end
		self.previous_hp = self:HP();
	end
end

modkit.compose:addShipProto("hgn_destroyer", delayed_healer_proto);