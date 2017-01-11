#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <clientprefs>


#define VERSION "1.2.2"

#define		PREFIX			"\x01★ \x04[Gloves]\x01"
//#define	LICENSE			"ip"
//#define	VIP_ONLY
#define		DONT_CLOSE		// Don't close menu when you select.

#if defined	VIP_ONLY
#define		VIP_FLAG		Admin_Custom6
#endif

#define 	BLOODHOUND 		5027
#define		BLOODHOUND_MODEL	"models/weapons/v_models/arms/glove_bloodhound/v_glove_bloodhound.mdl"

#define		SPORT			5030
#define		SPORT_MODEL		"models/weapons/v_models/arms/glove_sporty/v_glove_sporty.mdl"

#define		DRIVER			5031
#define		DRIVER_MODEL		"models/weapons/v_models/arms/glove_slick/glove_slick.mdl"

#define 	HAND			5032
#define		HAND_MODEL		"models/weapons/v_models/arms/glove_handwrap_leathery/glove_handwrap_leathery.mdl"

#define		MOTOCYCLE		5033
#define		MOTOCYCLE_MODEL		"models/weapons/v_models/arms/glove_motorcycle/glove_motorcycle.mdl"

#define		SPECIALIST		5034
#define		SPECIALIST_MODEL	"models/weapons/v_models/arms/glove_specialist/glove_specialist.mdl"

Handle g_pSave;

int g_iGlove [ MAXPLAYERS + 1 ];

#if defined LICENSE
char g_Address [ PLATFORM_MAX_PATH ];
#endif

int GlovesTempID[ MAXPLAYERS + 1 ];

public Plugin myinfo =
{
	name = "SM Valve Gloves",
	author = "Franc1sco franug and hadesownage",
	description = "",
	version = VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=291029"
};

public void OnPluginStart() {
    	
	RegConsoleCmd ( "sm_glove", CommandGloves );
	RegConsoleCmd ( "sm_gloves", CommandGloves );
    	
	RegConsoleCmd ( "sm_arm", CommandGloves );
	RegConsoleCmd ( "sm_arms", CommandGloves );
    	
	RegConsoleCmd ( "sm_manusa", CommandGloves );
	RegConsoleCmd ( "sm_manusi", CommandGloves );
    	
	RegConsoleCmd ( "sm_setarms", CommandSetArms );
    
	HookEvent ( "player_spawn", hookPlayerSpawn );
	HookEvent ( "player_death", hookPlayerDeath );
	
	//HookEvent ( "round_start", EventRoundStart );
    	
	g_pSave = RegClientCookie ( "ValveGloves", "Store Valve gloves", CookieAccess_Private );
    	
	for(new client = 1; client <= MaxClients; client++)
	{
		if(IsValidClient(client))
		{
			OnClientCookiesCached(client);
		}
	}
	
	#if defined LICENSE
	GetServerAddress(g_Address, sizeof(g_Address));
	#endif
}

#if defined LICENSE
public void OnMapStart ( ) {
	
	if ( !StrEqual( g_Address, LICENSE, false ) )
		SetFailState("Invalid License.");
	
}
#endif
public Action CommandSetArms ( int client, int args ) {
	
	#if defined VIP_ONLY
	if ( !IsValidClient ( client ) || !IsPlayerAlive( client ) || !g_iGlove [ client ] || !IsUserVip ( client ) )
		return Plugin_Handled;
	#else
	if ( !IsValidClient ( client ) || !IsPlayerAlive( client ) || !g_iGlove [ client ] )
		return Plugin_Handled;
	#endif
	
	//stock_ClearGloveParams(client)
	
	SetUserGloves ( client, g_iGlove [ client ], false );

	return Plugin_Handled;
	
}

public Action EventRoundStart ( Handle event, const char [ ] name, bool dontBroadcast ) {

	for ( new k = 1; k <= MaxClients; k++ ) {

		if ( !IsValidClient ( k ) || !IsPlayerAlive( k ))
			continue;
			
		FakeClientCommandEx(k, "%s", "sm_setarms");
		
	}
	
}

public Action hookPlayerSpawn ( Handle event, const char [ ] name, bool dontBroadcast ) {

	int client = GetClientOfUserId ( GetEventInt ( event, "userid" ) );
	
	#if defined VIP_ONLY
	if ( !IsValidClient ( client ) || !g_iGlove [ client ] || !IsUserVip ( client ) )
		return Plugin_Handled;
	#else
	if ( !IsValidClient ( client ) || !g_iGlove [ client ] )
		return Plugin_Handled;
	#endif
	
	
	//stock_ClearGloveParams(client);
	//FakeClientCommandEx(client, "%s", "sm_setarms");
	
	CreateTimer ( 0.35, Event_SetGlove, GetClientUserId ( client ) );


	return Plugin_Continue;
}

public Action Event_SetGlove ( Handle timer, any user_index ) {

	int client = GetClientOfUserId ( user_index );
	if ( !client || !IsValidClient ( client ) || !g_iGlove [ client ] )
		return;

	FakeClientCommandEx(client, "%s", "sm_setarms");

}

public Action hookPlayerDeath ( Handle event, const char [ ] name, bool dontBroadcast ) {

	int client = GetClientOfUserId ( GetEventInt ( event, "userid" ) );

	stock_ClearGloveParams(client);
	
	return Plugin_Continue;
}

public void OnClientCookiesCached ( int Client ) {

	char Data [ 32 ];

	GetClientCookie ( Client, g_pSave, Data, sizeof ( Data ) );

	g_iGlove [ Client ] = StringToInt ( Data );

}

public void OnClientPutInServer( int client ) {
	stock_ClearGloveParams(client);
}

public void OnClientDisconnect( int client ) {
	
	stock_ClearGloveParams(client);
	
	
}

public Action CommandGloves ( int client, int args ) {
	
	if ( !IsValidClient ( client ) )
		return Plugin_Handled;
		
	#if defined VIP_ONLY
	if ( !IsUserVip ( client ) ) {
		
		PrintToChat ( client, "%s This command is only for \x04VIPs\x01", PREFIX );
		return Plugin_Handled;
	}
	#endif
	
	Handle menu = CreateMenu(GlovesMenu_Handler, MenuAction_Select | MenuAction_End);
	SetMenuTitle(menu, "★ Gloves Menu ★");

	if(g_iGlove [ client ] < 1) AddMenuItem(menu, "default", "Default Gloves", ITEMDRAW_DISABLED);
	else AddMenuItem(menu, "default", "Default Gloves");
	
	AddMenuItem(menu, "Bloodhound", "★ Bloodhound Gloves");
	AddMenuItem(menu, "Driver", "☆ Driver Gloves");
	AddMenuItem(menu, "Hand", "★ Hand Wraps");
	AddMenuItem(menu, "Moto", "☆ Moto Gloves");
	AddMenuItem(menu, "Specialist", "★ Specialist Gloves");
	AddMenuItem(menu, "Sport", "☆ Sport Gloves");
	SetMenuPagination(menu, 	MENU_NO_PAGINATION);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
	
}

public int GlovesMenu_Handler(Handle menu, MenuAction action, int param1, int param2)
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
			
				PrintToChat ( param1, "%s You will have default gloves in your next spawn.", PREFIX );
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
				
				#if defined DONT_CLOSE
				BloodHound_Menu ( param1 );
				#endif
			
				PrintToChat ( param1, "%s Your new glove is \x04BloodHound | Bronzed", PREFIX );
			}
			else if (StrEqual(item, "Charred"))
			{
				SetUserGloves ( param1, 2, true );
				#if defined DONT_CLOSE
				BloodHound_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04BloodHound | Charred", PREFIX );
			}
			else if (StrEqual(item, "Guerrilla"))
			{
				SetUserGloves ( param1, 3, true );
				#if defined DONT_CLOSE
				BloodHound_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04BloodHound | Guerrilla", PREFIX );
			}
			else if (StrEqual(item, "Snakebite"))
			{
				SetUserGloves ( param1, 4, true );
				#if defined DONT_CLOSE
				BloodHound_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04BloodHound | Snakebite", PREFIX );
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
				#if defined DONT_CLOSE
				Driver_Menu ( param1 );
				#endif
			
				PrintToChat ( param1, "%s Your new glove is \x04Driver | Convoy", PREFIX );
			}
			else if (StrEqual(item, "CrimsonWeave"))
			{
				SetUserGloves ( param1, 6, true );
				#if defined DONT_CLOSE
				Driver_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Driver | Crimson Weave", PREFIX );
			}
			else if (StrEqual(item, "Diamondback"))
			{
				SetUserGloves ( param1, 7, true );
				#if defined DONT_CLOSE
				Driver_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Driver | Diamondback", PREFIX );
			}
			else if (StrEqual(item, "LunarWeave"))
			{
				SetUserGloves ( param1, 8, true );
				#if defined DONT_CLOSE
				Driver_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Driver | Lunar Weave", PREFIX );
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
				#if defined DONT_CLOSE
				Hand_Menu ( param1 );
				#endif
			
				PrintToChat ( param1, "%s Your new glove is \x04Hand Wraps | Badlands", PREFIX );
			}
			else if (StrEqual(item, "Leather"))
			{
				SetUserGloves ( param1, 10, true );
				#if defined DONT_CLOSE
				Hand_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Hand Wraps | Leather", PREFIX );
			}
			else if (StrEqual(item, "Slaughter"))
			{
				SetUserGloves ( param1, 11, true );
				#if defined DONT_CLOSE
				Hand_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Hand Wraps | Slaughter", PREFIX );
			}
			else if (StrEqual(item, "SpruceDDPAT"))
			{
				SetUserGloves ( param1, 12, true );
				#if defined DONT_CLOSE
				Hand_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Hand Wraps | Spruce DDPAT", PREFIX );
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
				#if defined DONT_CLOSE
				Moto_Menu ( param1 );
				#endif
			
				PrintToChat ( param1, "%s Your new glove is \x04Moto | Boom!", PREFIX );
			}
			else if (StrEqual(item, "CoolMint"))
			{
				SetUserGloves ( param1, 14, true );
				#if defined DONT_CLOSE
				Moto_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Moto | Cool Mint", PREFIX );
			}
			else if (StrEqual(item, "Eclipse"))
			{
				SetUserGloves ( param1, 15, true );
				#if defined DONT_CLOSE
				Moto_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Moto | Eclipse", PREFIX );
			}
			else if (StrEqual(item, "Spearmint"))
			{
				SetUserGloves ( param1, 16, true );
				#if defined DONT_CLOSE
				Moto_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Moto | Spearmint", PREFIX );
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
				#if defined DONT_CLOSE
				Specialist_Menu ( param1 );
				#endif
			
				PrintToChat ( param1, "%s Your new glove is \x04Specialist | Crimson Kimono", PREFIX );
			}
			else if (StrEqual(item, "EmeraldWeb"))
			{
				SetUserGloves ( param1, 18, true );
				#if defined DONT_CLOSE
				Specialist_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Specialist | Emerald Web", PREFIX );
			}
			else if (StrEqual(item, "ForestDDPAT"))
			{
				SetUserGloves ( param1, 19, true );
				#if defined DONT_CLOSE
				Specialist_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Specialist | Forest DDPAT", PREFIX );
			}
			else if (StrEqual(item, "Foundation"))
			{
				SetUserGloves ( param1, 20, true );
				#if defined DONT_CLOSE
				Specialist_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Specialist | Foundation", PREFIX );
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
				#if defined DONT_CLOSE
				Sport_Menu ( param1 );
				#endif
			
				PrintToChat ( param1, "%s Your new glove is \x04Sport | Arid", PREFIX );
			}
			else if (StrEqual(item, "HedgeMaze"))
			{
				SetUserGloves ( param1, 22, true );
				#if defined DONT_CLOSE
				Sport_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Sport | Hedge Maze", PREFIX );
			}
			else if (StrEqual(item, "PandorasBox"))
			{
				SetUserGloves ( param1, 23, true );
				#if defined DONT_CLOSE
				Sport_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Sport | Pandora's Box", PREFIX );
			}
			else if (StrEqual(item, "Superconductor"))
			{
				SetUserGloves ( param1, 24, true );
				#if defined DONT_CLOSE
				Sport_Menu ( param1 );
				#endif
				
				PrintToChat ( param1, "%s Your new glove is \x04Sport | Superconductor", PREFIX );
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

stock void SetUserGloves ( client, glove, bool bSave ) {
	
	if ( IsValidClient ( client ) && glove > 0 ) {
	
		if ( IsPlayerAlive ( client ) && GameRules_GetProp("m_bWarmupPeriod") != 1) {
			

			int item = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if (item == -1)return;
			
			SetEntPropString(client, Prop_Send, "m_szArmsModel", "");
			stock_ClearGloveParams ( client );
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
       	 		
			int type;
			int skin;
			
			char model [ PLATFORM_MAX_PATH ];

		        GlovesTempID[client] = GivePlayerItem(client, "wearable_item");
		        SetEntityRenderMode(GlovesTempID[client], RENDER_NONE);
		        
		        switch ( glove ) {
		        	
		        	case 1: {
		        		
		        		type = BLOODHOUND;
		        		skin = 10008;
		        		
		        		strcopy ( model, sizeof ( model ), BLOODHOUND_MODEL );
		        		
		        	}
		        	
		        	case 2: {
		        		
		        		type = BLOODHOUND;
		        		skin = 10006;
		        		
		        		strcopy ( model, sizeof ( model ), BLOODHOUND_MODEL );
		        		
		        	}
		        	case 3: {
		        		
		        		type = BLOODHOUND;
		        		skin = 10039;
		        		
		        		strcopy ( model, sizeof ( model ), BLOODHOUND_MODEL );
		        		
		        	}
		        	
		        	case 4: {
		        		
		        		type = BLOODHOUND;
		        		skin = 10007;
		        		
		        		strcopy ( model, sizeof ( model ), BLOODHOUND_MODEL );
		        		
		        	}
		        	
		        	case 5: {
		        		
		        		type = DRIVER;
		        		skin = 10015;
		        		
		        		strcopy ( model, sizeof ( model ), DRIVER_MODEL );
		        		
		        	}
		        	
		        	case 6: {
		        		
		        		type = DRIVER;
		        		skin = 10016;
		        		
		        		strcopy ( model, sizeof ( model ), DRIVER_MODEL );
		        		
		        	}
		        	
		        	case 7: {
		        		
		        		type = DRIVER;
		        		skin = 10040;
		        		
		        		strcopy ( model, sizeof ( model ), DRIVER_MODEL );
		        		
		        	}
		        	
		        	case 8: {
		        		
		        		type = DRIVER;
		        		skin = 10013;
		        		
		        		strcopy ( model, sizeof ( model ), DRIVER_MODEL );
		        		
		        	}
		        	
		        	case 9: {
		        		
		        		type = HAND;
		        		skin = 10036;
		        		
		        		strcopy ( model, sizeof ( model ), HAND_MODEL );
		        		
		        	}
		        	
		        	case 10: {
		        		
		        		type = HAND;
		        		skin = 10009;
		        		
		        		strcopy ( model, sizeof ( model ), HAND_MODEL );
		        		
		        	}
		        	
		        	case 11: {
		        		
		        		type = HAND;
		        		skin = 10021;
		        		
		        		strcopy ( model, sizeof ( model ), HAND_MODEL );
		        		
		        	}
		        	
		        	case 12: {
		        		
		        		type = HAND;
		        		skin = 10010;
		        		
		        		strcopy ( model, sizeof ( model ), HAND_MODEL );
		        		
		        	}
		        	
		        	case 13: {
		        		
		        		type = MOTOCYCLE;
		        		skin = 10027;
		        		
		        		strcopy ( model, sizeof ( model ), MOTOCYCLE_MODEL );
		        		
		        	}
		        	
		        	case 14: {
		        		
		        		type = MOTOCYCLE;
		        		skin = 10028;
		        		
		        		strcopy ( model, sizeof ( model ), MOTOCYCLE_MODEL );
		        		
		        	}
		        	
		        	case 15: {
		        		
		        		type = MOTOCYCLE;
		        		skin = 10024;
		        		
		        		strcopy ( model, sizeof ( model ), MOTOCYCLE_MODEL );
		        		
		        	}
		        	
		        	case 16: {
		        		
		        		type = MOTOCYCLE;
		        		skin = 10026;
		        		
		        		strcopy ( model, sizeof ( model ), MOTOCYCLE_MODEL );
		        		
		        	}
		        	
		        	case 17: {
		        		
		        		type = SPECIALIST;
		        		skin = 10033;
		        		
		        		strcopy ( model, sizeof ( model ), SPECIALIST_MODEL );
		        		
		        	}
		        	
		        	case 18: {
		        		
		        		type = SPECIALIST;
		        		skin = 10034;
		        		
		        		strcopy ( model, sizeof ( model ), SPECIALIST_MODEL );
		        		
		        	}
		        	case 19: {
		        		
		        		type = SPECIALIST;
		        		skin = 10030;
		        		
		        		strcopy ( model, sizeof ( model ), SPECIALIST_MODEL );
		        		
		        	}
		        	
		        	case 20: {
		        		
		        		type = SPECIALIST;
		        		skin = 10035;
		        		
		        		strcopy ( model, sizeof ( model ), SPECIALIST_MODEL );
		        		
		        	}
		        	
		        	case 21: {
		        		
		        		type = SPORT;
		        		skin = 10019;
		        		
		        		strcopy ( model, sizeof ( model ), SPORT_MODEL );
		        		
		        	}
		        	
		        	case 22: {
		        		
		        		type = SPORT;
		        		skin = 10038;
		        		
		        		strcopy ( model, sizeof ( model ), SPORT_MODEL );
		        		
		        	}
		        	
		        	case 23: {
		        		
		        		type = SPORT;
		        		skin = 10037;
		        		
		        		strcopy ( model, sizeof ( model ), SPORT_MODEL );
		        		
		        	}
		        	
		        	case 24: {
		        		
		        		type = SPORT;
		        		skin = 10018;
		        		
		        		strcopy ( model, sizeof ( model ), SPORT_MODEL );
		        		
		        	}
		        	
		        }
		        
		        if(IsValidEdict(GlovesTempID[client]))
		        {
		            
		        	
		            int m_iItemIDHigh = GetEntProp( GlovesTempID[client], Prop_Send, "m_iItemIDHigh" );
		            int m_iItemIDLow = GetEntProp( GlovesTempID[client], Prop_Send, "m_iItemIDLow" );
		            
		            SetEntProp(GlovesTempID[client], Prop_Send, "m_iItemDefinitionIndex", type);
		            SetEntProp(GlovesTempID[client], Prop_Send, "m_iItemIDLow", 8192+client);
		            SetEntProp(GlovesTempID[client], Prop_Send, "m_iItemIDHigh", 0);
		            SetEntProp(GlovesTempID[client], Prop_Send, "m_iEntityQuality", 4);
		            
		            SetEntPropFloat(GlovesTempID[client], Prop_Send, "m_flFallbackWear", 0.00000001);
		            
		            SetEntProp(GlovesTempID[client], Prop_Send,  "m_iAccountID", GetSteamAccountID(client));
		            
		            SetEntProp(GlovesTempID[client], Prop_Send,  "m_nFallbackSeed", 0);
		            SetEntProp(GlovesTempID[client], Prop_Send,  "m_nFallbackStatTrak", GetSteamAccountID(client));
		            SetEntProp(GlovesTempID[client], Prop_Send,  "m_nFallbackPaintKit", skin);
		            
		            if (!IsModelPrecached(model)) PrecacheModel(model);
		            
		            SetEntProp(GlovesTempID[client], Prop_Send, "m_nModelIndex", PrecacheModel(model));
		            SetEntityModel(GlovesTempID[client], model);
		            
		            SetEntPropEnt(client, Prop_Send, "m_hMyWearables", GlovesTempID[client]);
		            
		            DataPack ph1;
		            CreateDataTimer(2.0, AddItemTimer1, ph1);
		            
		            ph1.WriteCell(EntIndexToEntRef(client));
		            ph1.WriteCell(EntIndexToEntRef(GlovesTempID[client]));
		            ph1.WriteCell(m_iItemIDHigh );
		            ph1.WriteCell(m_iItemIDLow );
		            
		            DataPack ph2;
		            CreateDataTimer(0.0, AddItemTimer2, ph2);
		            
		            ph2.WriteCell(EntIndexToEntRef(client));
		            ph2.WriteCell(EntIndexToEntRef(item));
		            ph2.WriteCell(EntIndexToEntRef(GlovesTempID[client]));
		            
		     
		        }
		        
		}
	        
	        if ( bSave ) {
	        	
	        	g_iGlove [ client ] = glove;
	        	
	      		char Data [ 32 ];
			IntToString ( glove, Data, sizeof ( Data ) );
			SetClientCookie ( client, g_pSave, Data );
		}
		
	}
	
}

public Action AddItemTimer1(Handle timer, any ph)
{
    int client;
    int ent;
    int m_iItemIDHigh;
    int m_iItemIDLow;

    ResetPack(ph);

    client = EntRefToEntIndex(ReadPackCell(ph));
    ent = EntRefToEntIndex(ReadPackCell(ph));
    m_iItemIDHigh = ReadPackCell( ph );
    m_iItemIDLow = ReadPackCell( ph );
    
    if (ent < 1 || ent != GlovesTempID[client])return;
    
    if(IsValidEdict(ent))
    {
        SetEntProp(ent, Prop_Send, "m_iItemIDHigh", m_iItemIDHigh);
        SetEntProp(ent, Prop_Send, "m_iItemIDLow", m_iItemIDLow);
    }
    
    //stock_KillWearable(client, ent); // comment this if want to use stock_TeleportPWearable
    
    
}

public Action AddItemTimer2(Handle timer, any ph)
{
    int client;
    int item;
    int ent;
    
    ResetPack(ph);

    client = EntRefToEntIndex(ReadPackCell(ph));
    item = EntRefToEntIndex(ReadPackCell(ph));
    ent = EntRefToEntIndex(ReadPackCell(ph));
    
    if (ent < 1 || ent != GlovesTempID[client])return;
    
    if(IsValidated(client) && IsValidEdict(ent))
        SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", item);
    
    //stock_TeleportPWearable(client, ent); // comment this if want to use stock_KillWearable

}

stock IsValidClient ( client ) {

	if ( !( 1 <= client <= MaxClients ) || !IsClientInGame ( client ) || IsFakeClient( client ) )
		return false;

	return true;
}

#if defined VIP_ONLY
bool IsUserVip ( int client ) {

	if ( GetAdminFlag ( GetUserAdmin ( client ), VIP_FLAG )  )
		return true;

	return false;

}
#endif

#if defined LICENSE
void GetServerAddress(char[] Buffer, int Size)
{
	static int Addr = 0;

	Addr = GetConVarInt(FindConVar("hostip"));

	FormatEx(Buffer, Size, "%d.%d.%d.%d", \
				(Addr >> 24) & 0xFF, \
					(Addr >> 16) & 0xFF, \
						(Addr >> 8) & 0xFF, \
							Addr & 0xFF);
}
#endif

stock bool IsValidated( client )
{
    #define is_valid_player(%1) (1 <= %1 <= 32)
    
    if( !is_valid_player( client ) ) return false;
    if( !IsClientConnected ( client ) ) return false;   
    if( IsFakeClient ( client ) ) return false;
    if( !IsClientInGame ( client ) ) return false;

    return true;
}

stock bool stock_IsEntAsWearable(int ent)
{
    if(!IsValidEdict(ent)) return false;
    char weaponclass[64]; GetEdictClassname(ent, weaponclass, sizeof(weaponclass));
    
    if(StrContains(weaponclass, "wearable", false) == -1) return false;
    
    return true;
}

stock bool stock_KillWearable(int client, int ent)
{
    if(!IsValidEdict(ent)) return false;
    if(!stock_IsEntAsWearable(ent)) return false;
    

    if(AcceptEntityInput(ent, "Kill"))
    {
        GlovesTempID[client] = -1;


        return true;
    }
    
    return false;
}

stock void stock_ClearGloveParams(int client)
{
    stock_KillWearable(client, GlovesTempID[client]);
}