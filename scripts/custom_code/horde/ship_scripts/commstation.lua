---@class CommStationProto : Ship
commstation_proto = {};

function commstation_proto:update()

end

modkit.compose:addShipProto("vgr_commstation", commstation_proto);

print("commstation should be loaded");