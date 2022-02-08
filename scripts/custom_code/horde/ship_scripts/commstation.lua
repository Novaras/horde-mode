---@class CommStationProto : Ship
commstation_proto = {};

modkit.compose:addShipProto("horde_commstation", commstation_proto);

print("commstation should be loaded");