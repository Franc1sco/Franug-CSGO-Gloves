#include <sourcemod>
#include <sdktools>

#define VERSION "1.0"

public Plugin:myinfo = 
{
	name = "[CSGO] Wearable API",
	author = "Powerlord/Mr.Derp",
	description = "",
	version = VERSION,
	url = ""
}

new Handle:hGameConf;
new Handle:hEquipWearable;
new Handle:hRemoveWearable;

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	new EngineVersion:version = GetEngineVersion();
	
	if (version != Engine_CSGO)
	{
		strcopy(error, err_max, "Only supported on CSGO");
		return APLRes_Failure;
	}
	
	RegPluginLibrary("csgowearables");
	
	CreateNative("CSGO_EquipPlayerWearable", Native_EquipWearable);
	CreateNative("CSGO_RemovePlayerWearable", Native_RemoveWearable);
	
	return APLRes_Success;
}

public OnPluginStart()
{
	CreateConVar("csgowearables_version", VERSION, "Version of CSGO Wearables API", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	
	hGameConf = LoadGameConfigFile("csgo.wearables");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CBaseCombatCharacter::EquipWearable");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	hEquipWearable = EndPrepSDKCall();
	if (hEquipWearable == INVALID_HANDLE)
	{
		PrintToServer("ERROR WITH SDKCALL!");
	}
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CBaseCombatCharacter::RemoveWearable");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	hRemoveWearable = EndPrepSDKCall();
}

public Native_EquipWearable(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client %d is invalid", client);
		return;
	}
	
	new wearable = GetNativeCell(2);
	
	if (!Internal_IsWearable(wearable))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%d is not a wearable", wearable);
	}
	
	SDKCall(hEquipWearable, client, wearable);
}

public Native_RemoveWearable(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client %d is invalid", client);
		return;
	}
	
	new wearable = GetNativeCell(2);

	if (!Internal_IsWearable(wearable))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%d is not a wearable", wearable);
	}
	
	SDKCall(hRemoveWearable, client, wearable);
}

bool:Internal_IsWearable(entity)
{
	if (entity <= MaxClients || !IsValidEntity(entity))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%d is an invalid entity", entity);
		return false;
	}
	
	char classname[128];
	GetEntityClassname(entity, classname, sizeof(classname));
	if (StrEqual(classname, "wearable_item", false))
	{
		return true;
	}
	return false;
}
