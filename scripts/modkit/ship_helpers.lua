if (modkit == nil) then
	modkit = {};
end

if (modkit.shipGroup == nil) then
	---@class ShipsLib : GLOBAL_SHIPS
	local lib = modkit.table.clone(GLOBAL_SHIPS);

	--- Returns the avg position of `ships` or `GLOBAL_SHIPS`.
	---
	---@param ships Ship[]
	---@return Position
	function lib:avgPosition(ships)
		-- we could use the ship:position, but the game provides group position averaging already so we'll just use that
		-- print(self._entities);
		-- print(modkit.table.length(self._entities));
		-- print("so..");
		local group = SobGroup_FromShips(ships or self._entities);
		return SobGroup_GetPosition(group);
	end

	local _ships = function (ships)
		%lib._entities = ships or GLOBAL_SHIPS._entities;
		return %lib;
	end;

	---@type fun(ships: Ship[]): ShipsLib
	modkit.ships = _ships;
end