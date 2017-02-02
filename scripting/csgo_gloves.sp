#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <clientprefs>

#define		PREFIX			"\x01★ \x04[Gloves]\x01"

#define		VALVE_TOTAL_GLOVES	24

#define 	BLOODHOUND 		5027
#define		SPORT			5030
#define		DRIVER			5031
#define 	HAND			5032
#define		MOTOCYCLE		5033
#define		SPECIALIST		5034

Handle g_pSave;
Handle g_pSaveQ;

ConVar g_cvVipOnly, g_cvVipFlags, g_cvCloseMenu;

int g_iGlove [ MAXPLAYERS + 1 ];
int gloves[ MAXPLAYERS + 1 ];
int g_iChangeLimit [ MAXPLAYERS + 1 ];

float g_fUserQuality [ MAXPLAYERS + 1 ];

Handle cvar_thirdperson;


public Plugin myinfo =
{
	name = "SM Valve Gloves",
	author = "Franc1sco franug and hadesownage",
	description = "",
	version = "1.2.8",
	url = ""
};

public void OnPluginStart() {

	RegConsoleCmd ( "sm_gl", CommandGloves );
	RegConsoleCmd ( "sm_gls", CommandGloves );
    	
	RegConsoleCmd ( "sm_glove", CommandGloves );
	RegConsoleCmd ( "sm_gloves", CommandGloves );
    	
	RegConsoleCmd ( "sm_arm", CommandGloves );
	RegConsoleCmd ( "sm_arms", CommandGloves );
    	
	RegConsoleCmd ( "sm_manusa", CommandGloves );
	RegConsoleCmd ( "sm_manusi", CommandGloves );
 
	HookEvent ( "player_spawn", hookPlayerSpawn );
	//HookEvent ( "player_death", hookPlayerDeath );
	

	g_cvVipOnly = CreateConVar ( "sm_csgogloves_viponly", "0", "Set gloves only for VIPs", FCVAR_NOTIFY, true, 0.0, true, 1.0 );
	g_cvVipFlags = CreateConVar ( "sm_csgogloves_vipflags", "t", "Set gloves only for VIPs", FCVAR_NOTIFY );
	g_cvCloseMenu = CreateConVar ( "sm_csgogloves_closemenu", "0", "Close menu after selection", FCVAR_NOTIFY, true, 0.0, true, 1.0 );
	
	cvar_thirdperson = CreateConVar ( "sm_csgogloves_thirdperson", "1", "Enable thirdperson view for gloves", FCVAR_NOTIFY, true, 0.0, true, 1.0 );
	
	g_pSave = RegClientCookie ( "ValveGloveszzz", "Store Valve gloves", CookieAccess_Private );
	g_pSaveQ = RegClientCookie ( "ValveGlovesQ", "Store Valve gloves quality", CookieAccess_Private );

	for ( int client = 1; client <= MaxClients; client++ )
		if ( IsValidClient ( client ) )
		{
			OnClientCookiesCached ( client );
			if(IsPlayerAlive(client)) SetUserGloves(client, g_iGlove [ client ], false);
		}
			
	AutoExecConfig ( true, "csgo_gloves" );
	
}

public void OnPluginEnd() {
	for(int i = 1; i <= MaxClients; i++)
		if(gloves[i] != -1 && IsWearable(gloves[i])) {
			if(IsClientConnected(i) && IsPlayerAlive(i)) {
				SetEntPropEnt(i, Prop_Send, "m_hMyWearables", -1);
				SetEntProp(i, Prop_Send, "m_nBody", 0);
			}
			AcceptEntityInput(gloves[i], "Kill");
		}
}

public Action hookPlayerSpawn ( Handle event, const char [ ] name, bool dontBroadcast ) {

	int client = GetClientOfUserId ( GetEventInt ( event, "userid" ) );
	
	if ( GetConVarInt ( g_cvVipOnly ) ) {
		
		if ( !IsValidClient ( client ) || !g_iGlove [ client ] || !IsUserVip ( client ) )
			return;
			
	}
	
	if(!IsFakeClient(client) && GetEntProp(client, Prop_Send, "m_bIsControllingBot") != 1) {

		int wear = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
		if(wear == -1) {
			SetUserGloves ( client, g_iGlove [ client ], false );
		} else {
			if(GetConVarBool(cvar_thirdperson)) SetEntProp(client, Prop_Send, "m_nBody", 1);
		}
	}
}

/*
public Action hookPlayerDeath ( Handle event, const char [ ] name, bool dontBroadcast ) {

	int client = GetClientOfUserId ( GetEventInt ( event, "userid" ) );

	int wear = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
	
	if(wear == -1) 
		SetEntProp(client, Prop_Send, "m_nBody", 0);
	
	return Plugin_Continue;
}*/

public void OnClientCookiesCached ( int Client ) {

	char Data [ 32 ];

	GetClientCookie ( Client, g_pSave, Data, sizeof ( Data ) );

	g_iGlove [ Client ] = StringToInt ( Data );
	
	GetClientCookie ( Client, g_pSaveQ, Data, sizeof ( Data ) );
	
	g_fUserQuality [ Client ] = StringToFloat ( Data );
}

public Action CommandGloves ( int client, int args ) {
	
	if ( !IsValidClient ( client ) )
		return Plugin_Handled;
		
	if ( GetConVarInt ( g_cvVipOnly ) ) {
		
		if ( !IsUserVip ( client ) ) {
			
			PrintToChat ( client, "%s This command is only for \x04VIPs\x01", PREFIX );
			return Plugin_Handled;
		}
	}
	
	ValveGlovesMenu ( client );

	return Plugin_Handled;
	
}

public void ValveGlovesMenu ( int client ) {
	
	Handle menu = CreateMenu(ValveGlovesMenu_Handler, MenuAction_Select | MenuAction_End);
	SetMenuTitle(menu, "★ Valve Gloves Menu ★");

	if(g_iGlove [ client ] < 1) AddMenuItem(menu, "default", "Default Gloves", ITEMDRAW_DISABLED);
	else AddMenuItem(menu, "default", "Default Gloves");
	
	AddMenuItem(menu, "Bloodhound", "★ Bloodhound Gloves");
	AddMenuItem(menu, "Driver", "☆ Driver Gloves");
	AddMenuItem(menu, "Hand", "★ Hand Wraps");
	AddMenuItem(menu, "Moto", "☆ Moto Gloves");
	AddMenuItem(menu, "Specialist", "★ Specialist Gloves");
	AddMenuItem(menu, "Sport", "☆ Sport Gloves");
	AddMenuItem(menu, "Quality", "✦ Quality");
	SetMenuPagination(menu, 	MENU_NO_PAGINATION);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int ValveGlovesMenu_Handler(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			char item[64];
			GetMenuItem(menu, param2, item, sizeof(item));
			if (StrEqual(item, "default"))
			{
				g_iGlove [ param1 ] = 0;
	        	
				char Data [ 32 ];
				IntToString ( g_iGlove [ param1 ], Data, sizeof ( Data ) );
				SetClientCookie ( param1, g_pSave, Data );
			
				PrintToChat ( param1, "%s You have default gloves now.", PREFIX );
				SetUserGloves(param1, 0, false);
				CommandGloves(param1, 0);
				
			}
			if (StrEqual(item, "Bloodhound"))
			{
				BloodHound_Menu ( param1 );
			}
			else if (StrEqual(item, "Driver"))
			{
				Driver_Menu ( param1 );
			}
			else if (StrEqual(item, "Hand"))
			{
				Hand_Menu ( param1 );
			}
			else if (StrEqual(item, "Moto"))
			{
				Moto_Menu ( param1 );
			}
			else if (StrEqual(item, "Specialist"))
			{
				Specialist_Menu ( param1 );
			}
			else if (StrEqual(item, "Sport"))
			{
				Sport_Menu ( param1 );
			}
			else if (StrEqual(item, "Quality"))
			{
				Quality_Menu ( param1 );
			}
		}
		case MenuAction_Cancel:
		{
			if(param2==MenuCancel_ExitBack)
			{
				CommandGloves(param1, 0);
			}
		}
		case MenuAction_End:
		{
			//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
			CloseHandle(menu);

		}

	}
}

public void Quality_Menu ( client ) {
	
	Handle menu = CreateMenu(Quality_Handler, MenuAction_Select | MenuAction_End);
	SetMenuTitle(menu, "✦ Quality Menu ✦");
	
	if ( g_fUserQuality [ client ] == 0.0 )
		AddMenuItem(menu, "FactoryNew", "Factory New", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "FactoryNew", "Factory New");
		
	if ( g_fUserQuality [ client ] == 0.25 )
		AddMenuItem(menu, "MinimalWear", "Minimal Wear", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "MinimalWear", "Minimal Wear");
		
	if ( g_fUserQuality [ client ] == 0.50 )
		AddMenuItem(menu, "FieldTested", "Field-Tested", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "FieldTested", "Field-Tested");
	
	if ( g_fUserQuality [ client ] == 1.0 )
		AddMenuItem(menu, "BattleScared", "Battle-Scarred", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "BattleScared", "Battle-Scarred");	
		
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
				
}

public Quality_Handler(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			char item[64];
			GetMenuItem(menu, param2, item, sizeof(item));

			if (StrEqual(item, "FactoryNew"))
			{
				g_fUserQuality [ param1 ] = 0.0;
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Quality_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new \x06Glove Quality\x01 is \x07Factory New\x01.", PREFIX );
			}
			else if (StrEqual(item, "MinimalWear"))
			{
				g_fUserQuality [ param1 ] = 0.25;
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Quality_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new \x06Glove Quality\x01 is \x07Minimal Wear\x01.", PREFIX );
			}
			else if (StrEqual(item, "FieldTested"))
			{
				g_fUserQuality [ param1 ] = 0.50;
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Quality_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new \x06Glove Quality\x01 is \x07Field-Tested\x01.", PREFIX );
			}
			else if (StrEqual(item, "BattleScared"))
			{
				g_fUserQuality [ param1 ] = 1.0;
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Quality_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new \x06Glove Quality\x01 is \x07Battle-Scarred\x01.", PREFIX );
			}
			
			char Data [ 32 ];
			
			FloatToString ( g_fUserQuality [ param1 ], Data, sizeof ( Data ) );
			SetClientCookie ( param1, g_pSaveQ, Data );
			
			SetUserGloves ( param1, g_iGlove [ param1 ], false );
			
			
		}
		case MenuAction_Cancel:
		{
			if(param2==MenuCancel_ExitBack)
			{
				ValveGlovesMenu(param1);
			}
		}
		case MenuAction_End:
		{
			//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
			CloseHandle(menu);

		}

	}
}

public void BloodHound_Menu ( client ) {
	
	Handle menu = CreateMenu(Bloodhound_Handler, MenuAction_Select | MenuAction_End);
	SetMenuTitle(menu, "★ Bloodhound Gloves ★");
	
	if ( g_iGlove [ client ] == 1 )
		AddMenuItem(menu, "Bronzed", "Bronzed", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Bronzed", "Bronzed");
		
	if ( g_iGlove [ client ] == 2 )
		AddMenuItem(menu, "Charred", "Charred", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Charred", "Charred");
		
	if ( g_iGlove [ client ] == 3 )
		AddMenuItem(menu, "Guerrilla", "Guerrilla", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Guerrilla", "Guerrilla");
	
	if ( g_iGlove [ client ] == 4 )
		AddMenuItem(menu, "Snakebite", "Snakebite", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Snakebite", "Snakebite");	
		
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
				
}

public Bloodhound_Handler(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			char item[64];
			GetMenuItem(menu, param2, item, sizeof(item));

			if (StrEqual(item, "Bronzed"))
			{
				SetUserGloves ( param1, 1, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					BloodHound_Menu ( param1 );
				
			
				PrintToChat ( param1, "%s Your new glove is \x04BloodHound | Bronzed", PREFIX );
			}
			else if (StrEqual(item, "Charred"))
			{
				SetUserGloves ( param1, 2, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					BloodHound_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04BloodHound | Charred", PREFIX );
			}
			else if (StrEqual(item, "Guerrilla"))
			{
				SetUserGloves ( param1, 3, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					BloodHound_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04BloodHound | Guerrilla", PREFIX );
			}
			else if (StrEqual(item, "Snakebite"))
			{
				SetUserGloves ( param1, 4, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					BloodHound_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04BloodHound | Snakebite", PREFIX );
			}
		}
		case MenuAction_Cancel:
		{
			if(param2==MenuCancel_ExitBack)
			{
				ValveGlovesMenu(param1);
			}
		}
		case MenuAction_End:
		{
			//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
			CloseHandle(menu);

		}

	}
}

public void Driver_Menu ( client ) {
	
	Handle menu = CreateMenu(Driver_Handler, MenuAction_Select | MenuAction_End);
	SetMenuTitle(menu, "★ Driver Gloves ★");
	
	if ( g_iGlove [ client ] == 5 )
		AddMenuItem(menu, "Convoy", "Convoy", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Convoy", "Convoy");
		
	if ( g_iGlove [ client ] == 6 )
		AddMenuItem(menu, "CrimsonWeave", "Crimson Weave", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "CrimsonWeave", "Crimson Weave");
		
	if ( g_iGlove [ client ] == 7 )
		AddMenuItem(menu, "Diamondback", "Diamondback", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Diamondback", "Diamondback");
	
	if ( g_iGlove [ client ] == 8 )
		AddMenuItem(menu, "LunarWeave", "Lunar Weave", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "LunarWeave", "Lunar Weave");	
		
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
				
}

public Driver_Handler(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			char item[64];
			GetMenuItem(menu, param2, item, sizeof(item));

			if (StrEqual(item, "Convoy"))
			{
				SetUserGloves ( param1, 5, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Driver_Menu ( param1 );
				
			
				PrintToChat ( param1, "%s Your new glove is \x04Driver | Convoy", PREFIX );
			}
			else if (StrEqual(item, "CrimsonWeave"))
			{
				SetUserGloves ( param1, 6, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Driver_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Driver | Crimson Weave", PREFIX );
			}
			else if (StrEqual(item, "Diamondback"))
			{
				SetUserGloves ( param1, 7, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Driver_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Driver | Diamondback", PREFIX );
			}
			else if (StrEqual(item, "LunarWeave"))
			{
				SetUserGloves ( param1, 8, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Driver_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Driver | Lunar Weave", PREFIX );
			}
		}
		case MenuAction_Cancel:
		{
			if(param2==MenuCancel_ExitBack)
			{
				ValveGlovesMenu(param1);
			}
		}
		case MenuAction_End:
		{
			//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
			CloseHandle(menu);

		}

	}
}

public void Hand_Menu ( client ) {
	
	Handle menu = CreateMenu(Hand_Handler, MenuAction_Select | MenuAction_End);
	SetMenuTitle(menu, "★ Hand Wraps Gloves ★");
	
	if ( g_iGlove [ client ] == 9 )
		AddMenuItem(menu, "Badlands", "Badlands", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Badlands", "Badlands");
		
	if ( g_iGlove [ client ] == 10 )
		AddMenuItem(menu, "Leather", "Leather", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Leather", "Leather");
		
	if ( g_iGlove [ client ] == 11 )
		AddMenuItem(menu, "Slaughter", "Slaughter", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Slaughter", "Slaughter");
	
	if ( g_iGlove [ client ] == 12 )
		AddMenuItem(menu, "SpruceDDPAT", "Spruce DDPAT", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "SpruceDDPAT", "Spruce DDPAT");	
		
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
				
}

public Hand_Handler(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			char item[64];
			GetMenuItem(menu, param2, item, sizeof(item));

			if (StrEqual(item, "Badlands"))
			{
				SetUserGloves ( param1, 9, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Hand_Menu ( param1 );
			
				PrintToChat ( param1, "%s Your new glove is \x04Hand Wraps | Badlands", PREFIX );
			}
			else if (StrEqual(item, "Leather"))
			{
				SetUserGloves ( param1, 10, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Hand_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Hand Wraps | Leather", PREFIX );
			}
			else if (StrEqual(item, "Slaughter"))
			{
				SetUserGloves ( param1, 11, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Hand_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Hand Wraps | Slaughter", PREFIX );
			}
			else if (StrEqual(item, "SpruceDDPAT"))
			{
				SetUserGloves ( param1, 12, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Hand_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Hand Wraps | Spruce DDPAT", PREFIX );
			}
		}
		case MenuAction_Cancel:
		{
			if(param2==MenuCancel_ExitBack)
			{
				ValveGlovesMenu(param1);
			}
		}
		case MenuAction_End:
		{
			//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
			CloseHandle(menu);

		}

	}
}

public void Moto_Menu ( client ) {
	
	Handle menu = CreateMenu(Moto_Handler, MenuAction_Select | MenuAction_End);
	SetMenuTitle(menu, "★ Moto Gloves ★");
	
	if ( g_iGlove [ client ] == 13 )
		AddMenuItem(menu, "Boom", "Boom!", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Boom", "Boom!");
		
	if ( g_iGlove [ client ] == 14 )
		AddMenuItem(menu, "CoolMint", "Cool Mint", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "CoolMint", "Cool Mint");
		
	if ( g_iGlove [ client ] == 15 )
		AddMenuItem(menu, "Eclipse", "Eclipse", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Eclipse", "Eclipse");
	
	if ( g_iGlove [ client ] == 16 )
		AddMenuItem(menu, "Spearmint", "Spearmint", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Spearmint", "Spearmint");	
		
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
				
}

public Moto_Handler(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			char item[64];
			GetMenuItem(menu, param2, item, sizeof(item));

			if (StrEqual(item, "Boom"))
			{
				SetUserGloves ( param1, 13, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Moto_Menu ( param1 );
			
				PrintToChat ( param1, "%s Your new glove is \x04Moto | Boom!", PREFIX );
			}
			else if (StrEqual(item, "CoolMint"))
			{
				SetUserGloves ( param1, 14, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Moto_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Moto | Cool Mint", PREFIX );
			}
			else if (StrEqual(item, "Eclipse"))
			{
				SetUserGloves ( param1, 15, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Moto_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Moto | Eclipse", PREFIX );
			}
			else if (StrEqual(item, "Spearmint"))
			{
				SetUserGloves ( param1, 16, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Moto_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Moto | Spearmint", PREFIX );
			}
		}
		case MenuAction_Cancel:
		{
			if(param2==MenuCancel_ExitBack)
			{
				ValveGlovesMenu(param1);
			}
		}
		case MenuAction_End:
		{
			//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
			CloseHandle(menu);

		}

	}
}

public void Specialist_Menu ( client ) {
	
	Handle menu = CreateMenu(Specialist_Handler, MenuAction_Select | MenuAction_End);
	SetMenuTitle(menu, "★ Specialist Gloves ★");
	
	if ( g_iGlove [ client ] == 17 )
		AddMenuItem(menu, "CrimsonKimono", "Crimson Kimono", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "CrimsonKimono", "Crimson Kimono");
		
	if ( g_iGlove [ client ] == 18 )
		AddMenuItem(menu, "EmeraldWeb", "Emerald Web", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "EmeraldWeb", "Emerald Web");
		
	if ( g_iGlove [ client ] == 19 )
		AddMenuItem(menu, "ForestDDPAT", "Forest DDPAT", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "ForestDDPAT", "Forest DDPAT");
	
	if ( g_iGlove [ client ] == 20 )
		AddMenuItem(menu, "Foundation", "Foundation", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Foundation", "Foundation");	
		
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
				
}

public Specialist_Handler(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			char item[64];
			GetMenuItem(menu, param2, item, sizeof(item));

			if (StrEqual(item, "CrimsonKimono"))
			{
				SetUserGloves ( param1, 17, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Specialist_Menu ( param1 );
			
				PrintToChat ( param1, "%s Your new glove is \x04Specialist | Crimson Kimono", PREFIX );
			}
			else if (StrEqual(item, "EmeraldWeb"))
			{
				SetUserGloves ( param1, 18, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Specialist_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Specialist | Emerald Web", PREFIX );
			}
			else if (StrEqual(item, "ForestDDPAT"))
			{
				SetUserGloves ( param1, 19, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Specialist_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Specialist | Forest DDPAT", PREFIX );
			}
			else if (StrEqual(item, "Foundation"))
			{
				SetUserGloves ( param1, 20, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Specialist_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Specialist | Foundation", PREFIX );
			}
		}
		case MenuAction_Cancel:
		{
			if(param2==MenuCancel_ExitBack)
			{
				ValveGlovesMenu(param1);
			}
		}
		case MenuAction_End:
		{
			//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
			CloseHandle(menu);

		}

	}
}

public void Sport_Menu ( client ) {
	
	Handle menu = CreateMenu(Sport_Handler, MenuAction_Select | MenuAction_End);
	SetMenuTitle(menu, "★ Sport Gloves ★");
	
	if ( g_iGlove [ client ] == 21 )
		AddMenuItem(menu, "Arid", "Arid", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Arid", "Arid");
		
	if ( g_iGlove [ client ] == 22 )
		AddMenuItem(menu, "HedgeMaze", "Hedge Maze", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "HedgeMaze", "Hedge Maze");
		
	if ( g_iGlove [ client ] == 23 )
		AddMenuItem(menu, "PandorasBox", "Pandora's Box", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "PandorasBox", "Pandora's Box");
	
	if ( g_iGlove [ client ] == 24 )
		AddMenuItem(menu, "Superconductor", "Superconductor", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "Superconductor", "Superconductor");	
		
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
				
}

public Sport_Handler(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			char item[64];
			GetMenuItem(menu, param2, item, sizeof(item));

			if (StrEqual(item, "Arid"))
			{
				SetUserGloves ( param1, 21, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Sport_Menu ( param1 );
			
				PrintToChat ( param1, "%s Your new glove is \x04Sport | Arid", PREFIX );
			}
			else if (StrEqual(item, "HedgeMaze"))
			{
				SetUserGloves ( param1, 22, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Sport_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Sport | Hedge Maze", PREFIX );
			}
			else if (StrEqual(item, "PandorasBox"))
			{
				SetUserGloves ( param1, 23, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Sport_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Sport | Pandora's Box", PREFIX );
			}
			else if (StrEqual(item, "Superconductor"))
			{
				SetUserGloves ( param1, 24, true );
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Sport_Menu ( param1 );
				
				PrintToChat ( param1, "%s Your new glove is \x04Sport | Superconductor", PREFIX );
			}
		}
		case MenuAction_Cancel:
		{
			if(param2==MenuCancel_ExitBack)
			{
				ValveGlovesMenu(param1);
			}
		}
		case MenuAction_End:
		{
			//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
			CloseHandle(menu);

		}

	}
}

stock void SetUserGloves ( client, glove, bool bSave ) {
	
	if ( IsValidClient ( client )) {
	
		if ( IsPlayerAlive ( client ) ) {

			int type;
			int skin;
		
			if ( !g_fUserQuality [ client ] )
				g_fUserQuality [ client ] = 0.0;

		        switch ( glove ) {
		        	
		        	case 1: {
		        		
		        		type = BLOODHOUND;
		        		skin = 10008;
		
		        	}
		        	
		        	case 2: {
		        		
		        		type = BLOODHOUND;
		        		skin = 10006;
		
		        	}
		        	
		        	case 3: {
		        		
		        		type = BLOODHOUND;
		        		skin = 10039;

		        	}
		        	
		        	case 4: {
		        		
		        		type = BLOODHOUND;
		        		skin = 10007;
	
		        	}
		        	
		        	case 5: {
		        		
		        		type = DRIVER;
		        		skin = 10015;
	
		        	}
		        	
		        	case 6: {
		        		
		        		type = DRIVER;
		        		skin = 10016;
		
		        	}
		        	
		        	case 7: {
		        		
		        		type = DRIVER;
		        		skin = 10040;
		
		        	}
		        	
		        	case 8: {
		        		
		        		type = DRIVER;
		        		skin = 10013;
		 
		        	}
		        	
		        	case 9: {
		        		
		        		type = HAND;
		        		skin = 10036;
		  
		        	}
		        	
		        	case 10: {
		        		
		        		type = HAND;
		        		skin = 10009;
		    
		        	}
		        	
		        	case 11: {
		        		
		        		type = HAND;
		        		skin = 10021;
		     
		        	}
		        	
		        	case 12: {
		        		
		        		type = HAND;
		        		skin = 10010;
		     
		        	}
		        	
		        	case 13: {
		        		
		        		type = MOTOCYCLE;
		        		skin = 10027;
		  
		        	}
		        	
		        	case 14: {
		        		
		        		type = MOTOCYCLE;
		        		skin = 10028;
		  
		        	}
		        	
		        	case 15: {
		        		
		        		type = MOTOCYCLE;
		        		skin = 10024;
	
		        	}
		        	
		        	case 16: {
		        		
		        		type = MOTOCYCLE;
		        		skin = 10026;
	
		        	}
		        	
		        	case 17: {
		        		
		        		type = SPECIALIST;
		        		skin = 10033;
	
		        	}
		        	
		        	case 18: {
		        		
		        		type = SPECIALIST;
		        		skin = 10034;
		      
		        	}
		        	
		        	case 19: {
		        		
		        		type = SPECIALIST;
		        		skin = 10030;
		        		
		        	}
		        	
		        	case 20: {
		        		
		        		type = SPECIALIST;
		        		skin = 10035;
		  
		        	}
		        	
		        	case 21: {
		        		
		        		type = SPORT;
		        		skin = 10019;
		        
		        	}
		        	
		        	case 22: {
		        		
		        		type = SPORT;
		        		skin = 10038;

		        	}
		        	
		        	case 23: {
		        		
		        		type = SPORT;
		        		skin = 10037;

		        	}
		        	
		        	case 24: {
		        		
		        		type = SPORT;
		        		skin = 10018;
	
		        	}
		        	
		        	default:
		        	{
		        		type = -1;
		        	}
		        	
		        }
			int current = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
			if(current != -1 && IsWearable(current)) {
				AcceptEntityInput(current, "Kill");
				if (current == gloves[client]) gloves[client] = -1;
				
			}
			if(gloves[client] != -1 && IsWearable(gloves[client])) {
				AcceptEntityInput(gloves[client], "Kill");
				gloves[client] = -1;
			}
			if(type != -1 && type != -3) {
				int ent = CreateEntityByName("wearable_item");
				if(ent != -1 && IsValidEdict(ent)) {
					SetEntPropString(client, Prop_Send, "m_szArmsModel", "");
					gloves[client] = ent;
					SetEntPropEnt(client, Prop_Send, "m_hMyWearables", ent);
					SetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex", type);
					SetEntProp(ent, Prop_Send,  "m_nFallbackPaintKit", skin);
					SetEntPropFloat(ent, Prop_Send, "m_flFallbackWear", g_fUserQuality [ client ]);
					SetEntProp(ent, Prop_Send, "m_iItemIDLow", 2048);
					SetEntProp(ent, Prop_Send, "m_bInitialized", 1);
					SetEntPropEnt(ent, Prop_Data, "m_hParent", client);
					SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
					if(GetConVarBool(cvar_thirdperson))
					{
						SetEntPropEnt(ent, Prop_Data, "m_hMoveParent", client);
						SetEntProp(client, Prop_Send, "m_nBody", 1);
					}
					DispatchSpawn(ent);
					//ChangeEdictState(ent);
				}
			} else {
				SetEntProp(client, Prop_Send, "m_nBody", 0);
			}
			int item = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1); 
			DataPack ph = new DataPack();
			WritePackCell(ph, EntIndexToEntRef(client));
			if(IsValidEntity(item))	WritePackCell(ph, EntIndexToEntRef(item));
			else WritePackCell(ph, -1);
			CreateTimer(0.0, AddItemTimer, ph, TIMER_FLAG_NO_MAPCHANGE); 
		}
	        
		if ( bSave ) {
	        	
	        	g_iGlove [ client ] = glove;
	        	
	      		char Data [ 32 ];
			IntToString ( glove, Data, sizeof ( Data ) );
			SetClientCookie ( client, g_pSave, Data );
			
			FloatToString ( g_fUserQuality [ client ], Data, sizeof ( Data ) );
			SetClientCookie ( client, g_pSaveQ, Data );
		}
		
	}
	
}

public Action AddItemTimer(Handle timer, DataPack ph) {
    int client, item;
    ResetPack(ph);
    client = EntRefToEntIndex(ReadPackCell(ph));
    item = EntRefToEntIndex(ReadPackCell(ph));
    if (client != INVALID_ENT_REFERENCE && item != INVALID_ENT_REFERENCE) {
        SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", item);
    }    
    return Plugin_Stop;
}
stock bool IsWearable(int ent) {
	if(!IsValidEdict(ent)) return false;
	char weaponclass[32]; GetEdictClassname(ent, weaponclass, sizeof(weaponclass));
	if(StrContains(weaponclass, "wearable", false) == -1) return false;
	return true;
}

public Action Timer_CheckLimit ( Handle timer, any user_index ) {

	int client = GetClientOfUserId ( user_index );
	if ( !client || !IsValidClient ( client ) || !g_iChangeLimit [ client ] )
		return;

	g_iChangeLimit [ client ]--;
	CreateTimer ( 1.0, Timer_CheckLimit, user_index );

}

stock IsValidClient ( client ) {

	if ( !( 1 <= client <= MaxClients ) || !IsClientInGame ( client ) || IsFakeClient( client ) || GetEntProp(client, Prop_Send, "m_bIsControllingBot") == 1 )
		return false;

	return true;
}

bool IsUserVip ( int client ) {
	
	char szFlags [ 32 ];
	GetConVarString ( g_cvVipFlags, szFlags, sizeof ( szFlags ) );

	AdminId admin = GetUserAdmin ( client );
	if ( admin != INVALID_ADMIN_ID ) {

		int count, found, flags = ReadFlagString ( szFlags );
		for ( int i = 0; i <= 20; i++ ) {

			if ( flags & ( 1<<i ) ) {

				count++;

				if ( GetAdminFlag ( admin, AdminFlag: i ) )
					found++;

			}
		}

		if ( count == found )
			return true;

	}

	return false;
}

stock bool IsValidated( client )
{
    #define is_valid_player(%1) (1 <= %1 <= 32)
    
    if( !is_valid_player( client ) ) return false;
    if( !IsClientConnected ( client ) ) return false;   
    if( IsFakeClient ( client ) ) return false;
    if( !IsClientInGame ( client ) ) return false;

    return true;
}

