#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Simon"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <n_arms_fix>

#include "NightCrawler/nc_callbacks.sp"
#include "NightCrawler/nc_functions.sp"
#include "NightCrawler/nc_client.sp"
#include "NightCrawler/nc_hooks.sp"
#include "NightCrawler/nc_events.sp"
#include "NightCrawler/nc_downloads.sp"

#pragma newdecls required

int NC_TeleCount[MAXPLAYERS + 1];

EngineVersion g_Game;

public Plugin myinfo = 
{
	name = "NightCrawlerGO",
	author = PLUGIN_AUTHOR,
	description = "NightCrawler Mod for CS:GO",
	version = PLUGIN_VERSION,
	url = "yash1441@yahoo.com"
};

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	
	HookEvent("round_prestart", Event_OnRoundPreStart);
	HookEvent("round_end", Event_OnRoundEnd);
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeath);

	AddCommandListener(Command_LookAtWeapon, "+lookatweapon");
	AddCommandListener(Command_Kill, "kill");
	AddCommandListener(Command_Kill, "explode");
	AddCommandListener(Command_Join, "jointeam");
	AddNormalSoundHook(OnNormalSoundPlayed);
}

public void OnMapStart()
{
	SetCvarStr("mp_teamname_1", "Humans");
	SetCvarStr("mp_teamname_2", "NightCrawlers");
	SetCvarInt("sv_ignoregrenaderadio", 1);
	SetCvarInt("sv_disable_immunity_alpha", 1);
	SetCvarInt("sv_airaccelerate", 120);
	SetCvarInt("mp_maxrounds", 30);
	SetCvarFloat("mp_roundtime", 2.5);
	SetCvarFloat("mp_roundtime_defuse", 2.5);
	SetCvarInt("mp_defuser_allocation", 0);
	SetCvarInt("mp_solid_teammates", 0);
	SetCvarInt("sv_deadtalk", 0);
	SetCvarInt("mp_autokick", 0);
	SetCvarInt("mp_free_armor", 0);
	SetCvarInt("mp_buytime", 0);
	for(int i; i < sizeof(NC_Models); i++)
	{
		PrecacheModel(NC_Models[i]);
		AddFileToDownloadsTable(NC_Models[i]);
	}
	for(int i; i < sizeof(NC_Material); i++)
	{
		AddFileToDownloadsTable(NC_Materials[i]);
	}

}

public void OnClientPutInServer(int client)
{
	if(IsValidClient(client))
	{
		SendConVarValue(client, FindConVar("sv_footsteps"), "0");
		SDKHook(client, SDKHook_PreThink, EventSDK_OnClientThink);
		//SDKHook(client, SDKHook_PostThinkPost, EventSDK_OnPostThinkPost);
		SDKHook(client, SDKHook_WeaponCanUse, EventSDK_OnWeaponCanUse);
		SDKHook(client, SDKHook_SetTransmit, EventSDK_SetTransmit);
		SDKHook(client, SDKHook_OnTakeDamage, EventSDK_OnTakeDamage);
		//SDKHook(client, SDKHook_TraceAttack, EventSDK_OnTraceAttack);*/
	}
}

public void ArmsFix_OnArmsSafe(int client)
{
	NCArms(client);
}

public Action OnNormalSoundPlayed(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if(StrContains(sample, "land") != -1)
	{
		return Plugin_Stop;
	}
	if (entity && entity <= MaxClients && StrContains(sample, "footsteps") != -1)
	{
		if(GetClientTeam(entity) == CS_TEAM_CT)
		{
			EmitSoundToAll(sample, entity, SNDCHAN_AUTO,SNDLEVEL_NORMAL,SND_NOFLAGS,0.5);
			return Plugin_Handled;
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}