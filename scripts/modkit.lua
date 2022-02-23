-- Entry point - bootstraps the other files

if (H_MODKIT == nil) then
	print("\n\nmodkit.lua init...");

	modkit = modkit or {};

	doscanpath("data:scripts/modkit", "*.lua");

	print("modkit.lua loaded successfully!\n\n");

	H_MODKIT = 1;
end
