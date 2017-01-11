native CSGO_EquipPlayerWearable(client, wearable);
native CSGO_RemovePlayerWearable(client, wearable);

public __pl_csgowearables_SetNTVOptional()
{
	MarkNativeAsOptional("EquipPlayerWearable");
	MarkNativeAsOptional("RemovePlayerWearable");
}