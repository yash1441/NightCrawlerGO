#pragma semicolon 1
#pragma newdecls required

Address NC_SpotRadar = view_as<Address>(868);
#define LoopAllClients(%1) for(int %1 = 1;%1 <= MaxClients;%1++)
#define LoopClients(%1) for(int %1 = 1;%1 <= MaxClients;%1++) if(IsValidClient(%1))
#define LoopAliveClients(%1) for(int %1 = 1;%1 <= MaxClients;%1++) if(IsValidClient(%1, true))

#define HEColor 	{255,75,75,255}
#define SmokeColor	{75,255,75,255}
#define FreezeColor	{75,75,255,255}

#define PLUGIN_AUTHOR "Simon"
#define PLUGIN_VERSION "1.1"
#define NC_Tag "{green}[NC]"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <overlays>
#include <multicolors>
#include <emitsoundany>
#include <n_arms_fix>
#include <fpvm_interface>

int NC_TeleCount[MAXPLAYERS + 1];
bool NC_NextRound[MAXPLAYERS + 1] =  { false, ... };
bool NC_IsVisible[MAXPLAYERS + 1] =  { false, ... };
float NC_iTime[MAXPLAYERS + 1] =  { 0.0, ... };
Handle NC_iTimer[MAXPLAYERS + 1];
Handle NC_FreezeTimer[MAXPLAYERS + 1];
bool NC_WallClimb[MAXPLAYERS + 1] =  { false, ... };

int NC_GrenadeBeamSprite1;
int NC_GrenadeBeamSprite2;
int NC_GrenadeHaloSprite;
int NC_GrenadeGlowSprite;
int NC_GunLaserSprite;
int NC_GunGlowSprite;
int NC_KnifeModel;
int NC_KnifeWorldModel;

bool NC_LaserAim[MAXPLAYERS + 1] =  { false, ... };
int NC_Adrenaline[MAXPLAYERS + 1] =  { 0, ... };
bool NC_IsAdrenaline[MAXPLAYERS + 1] =  { false, ... };
bool NC_Scout[MAXPLAYERS + 1] =  { false, ... };
bool NC_Suicide[MAXPLAYERS + 1] =  { false, ... };
bool NC_ExplosionSound = true;
int NC_TripMine[MAXPLAYERS + 1] =  { 0, ... };
int NC_TripMineCounter = 0;
int NC_PoisonCount[MAXPLAYERS + 1] =  { 0, ... };
bool NC_TopPlayer[MAXPLAYERS + 1] =  { false, ... };

char NC_Models[][] = 
{
	"models/tripmine/tripmine.dx90.vtx", 
	"models/tripmine/tripmine.mdl", 
	"models/tripmine/tripmine.phy", 
	"models/tripmine/tripmine.vvd", 
	"models/player/custom_player/kodua/eliminator/eliminator.mdl", 
	"models/player/custom_player/kodua/eliminator/eliminator.phy", 
	"models/player/custom_player/kodua/eliminator/eliminator.vvd", 
	"models/player/custom_player/kodua/eliminator/eliminator.dx90.vtx", 
	"models/player/custom_player/kuristaja/cso2/gsg9/gsg9.dx90.vtx", 
	"models/player/custom_player/kuristaja/cso2/gsg9/gsg9.mdl", 
	"models/player/custom_player/kuristaja/cso2/gsg9/gsg9.phy", 
	"models/player/custom_player/kuristaja/cso2/gsg9/gsg9.vvd", 
	"models/player/custom_player/kuristaja/cso2/gsg9/gsg9_arms.vvd", 
	"models/player/custom_player/kuristaja/cso2/gsg9/gsg9_arms.dx90.vtx", 
	"models/player/custom_player/kuristaja/cso2/gsg9/gsg9_arms.mdl", 
	"models/player/custom_player/kuristaja/cso2/helga/helga.dx90.vtx", 
	"models/player/custom_player/kuristaja/cso2/helga/helga.mdl", 
	"models/player/custom_player/kuristaja/cso2/helga/helga.phy", 
	"models/player/custom_player/kuristaja/cso2/helga/helga.vvd", 
	"models/player/custom_player/kuristaja/cso2/helga/helga_arms.mdl", 
	"models/player/custom_player/kuristaja/cso2/helga/helga_arms.vvd", 
	"models/player/custom_player/kuristaja/cso2/helga/helga_arms.dx90.vtx", 
	"models/weapons/ventoz/Abyss_Greatsword/v_abyss_greatsword.dx90.vtx", 
	"models/weapons/ventoz/Abyss_Greatsword/v_abyss_greatsword.mdl", 
	"models/weapons/ventoz/Abyss_Greatsword/v_abyss_greatsword.vvd", 
	"models/weapons/ventoz/Abyss_Greatsword/w_abyss_greatsword.dx90.vtx", 
	"models/weapons/ventoz/Abyss_Greatsword/w_abyss_greatsword.mdl", 
	"models/weapons/ventoz/Abyss_Greatsword/w_abyss_greatsword.vvd"
};

char NC_Materials[][] = 
{
	"materials/models/tripmine/minetexture.vmt", 
	"materials/models/tripmine/minetexture.vtf", 
	"materials/sprites/purplelaser1.vmt", 
	"materials/sprites/purplelaser1.vtf", 
	"materials/sprites/laserbeam.vmt", 
	"materials/sprites/laserbeam.vtf", 
	"materials/sprites/lgtning.vmt", 
	"materials/sprites/lgtning.vtf", 
	"materials/sprites/halo01.vmt", 
	"materials/sprites/halo01.vtf", 
	"materials/sprites/blueglow2.vmt", 
	"materials/sprites/blueglow2.vtf", 
	"materials/sprites/bluelaser1.vmt", 
	"materials/sprites/bluelaser1.vtf", 
	"materials/sprites/redglow1.vmt", 
	"materials/sprites/redglow1.vtf", 
	"materials/models/player/custom_player/kodua/eliminator/7_m3900.vmt", 
	"materials/models/player/custom_player/kodua/eliminator/7_m3901.vmt", 
	"materials/models/player/custom_player/kodua/eliminator/7_m3902.vmt", 
	"materials/models/player/custom_player/kodua/eliminator/7_m3903.vmt", 
	"materials/models/player/custom_player/kodua/eliminator/7_m3904.vmt", 
	"materials/models/player/custom_player/kodua/eliminator/7_m3905.vmt", 
	"materials/models/player/custom_player/kodua/eliminator/7_m3905_b.vmt", 
	"materials/models/player/custom_player/kodua/eliminator/arm.vtf", 
	"materials/models/player/custom_player/kodua/eliminator/arm_nm.vtf", 
	"materials/models/player/custom_player/kodua/eliminator/body.vtf", 
	"materials/models/player/custom_player/kodua/eliminator/body_nm.vtf", 
	"materials/models/player/custom_player/kodua/eliminator/em3905.vtf", 
	"materials/models/player/custom_player/kodua/eliminator/eyes.vmt", 
	"materials/models/player/custom_player/kodua/eliminator/face.vtf", 
	"materials/models/player/custom_player/kodua/eliminator/face_nm.vtf", 
	"materials/models/player/custom_player/kodua/eliminator/fur.vtf", 
	"materials/models/player/custom_player/kodua/eliminator/fur_nm.vtf", 
	"materials/models/player/custom_player/kodua/eliminator/hand.vtf", 
	"materials/models/player/custom_player/kodua/eliminator/hand_nm.vtf", 
	"materials/models/player/custom_player/kodua/eliminator/leg.vtf", 
	"materials/models/player/custom_player/kodua/eliminator/leg_nm.vtf", 
	"materials/models/player/custom_player/kodua/eliminator/teeth.vmt", 
	"materials/models/player/custom_player/kodua/eliminator/throat.vmt", 
	"materials/models/player/custom_player/kodua/eliminator/wound_arm.vmt", 
	"materials/models/player/custom_player/kodua/eliminator/wound_body.vmt", 
	"materials/models/player/custom_player/kodua/eliminator/wound_leg.vmt", 
	"materials/models/player/kuristaja/cso2/gsg9/ct_gsg_glass_normal.vtf", 
	"materials/models/player/kuristaja/cso2/gsg9/ct_gsg_hand.vmt", 
	"materials/models/player/kuristaja/cso2/gsg9/ct_gsg_hand.vtf", 
	"materials/models/player/kuristaja/cso2/gsg9/ct_gsg_hand_normal.vtf", 
	"materials/models/player/kuristaja/cso2/gsg9/ct_gsg_multi.vtf", 
	"materials/models/player/kuristaja/cso2/gsg9/ct_gsg_normal.vtf", 
	"materials/models/player/kuristaja/cso2/gsg9/ct_gsg.vmt", 
	"materials/models/player/kuristaja/cso2/gsg9/ct_gsg.vtf", 
	"materials/models/player/kuristaja/cso2/gsg9/ct_gsg_glass.vmt", 
	"materials/models/player/kuristaja/cso2/gsg9/ct_gsg_glass.vtf", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga_glove_normal.vtf", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga_hair.vmt", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga_hair.vtf", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga_hair_normal.vtf", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga_hand.vmt", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga_hair2.vmt", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga_hand.vtf", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga_hand_normal.vtf", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga_multi.vtf", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga_normal.vtf", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga.vmt", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga.vtf", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga_eyelashes.vmt", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga_eyelashes.vtf", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga_glove.vmt", 
	"materials/models/player/kuristaja/cso2/helga/ct_helga_glove.vtf", 
	"materials/models/weapons/ventoz/Abyss_Greatsword/abyss_greatsword_d.vmt", 
	"materials/models/weapons/ventoz/Abyss_Greatsword/abyss_greatsword_d.vtf", 
	"materials/models/weapons/ventoz/Abyss_Greatsword/abyss_greatsword_n.vtf", 
	"materials/models/weapons/ventoz/Abyss_Greatsword/green.vtf", 
	"materials/models/weapons/ventoz/Abyss_Greatsword/painted_silver_ldr.vtf"
};

char NC_Sounds[][] = 
{
	"weapons/g3sg1/g3sg1_slideback.wav", 
	"weapons/c4/c4_beep1.wav", 
	"items/nvg_on.wav", 
	"weapons/c4/c4_disarm.wav", 
	"weapons/hegrenade/explode3.wav", 
	"weapons/hegrenade/explode4.wav", 
	"weapons/hegrenade/explode5.wav", 
	"nightcrawler/teleport.mp3", 
	"physics/glass/glass_impact_bullet4.wav", 
	"nightcrawler/freeze_cam.mp3"
};

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
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_Pre);
	HookEvent("round_end", Event_OnRoundEnd);
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("player_hurt", Event_OnPlayerHurt);
	HookEvent("hegrenade_detonate", Event_OnHeDetonate);
	HookEvent("smokegrenade_detonate", Event_OnSmokeDetonate);
	
	AddNormalSoundHook(OnNormalSoundPlayed);
	
	AddCommandListener(Command_LookAtWeapon, "+lookatweapon");
	AddCommandListener(Command_Kill, "kill");
	AddCommandListener(Command_Kill, "explode");
	AddCommandListener(Command_Join, "jointeam");
	
	SetHudTextParams(-1.0, 0.7, 3.0, 0, 255, 0, 255, 0, 0.0, 0.0, 0.0);
}

public void OnMapStart()
{
	MapSettings();
	
	for (int i = 0; i < sizeof(NC_Models); i++)
	{
		AddFileToDownloadsTable(NC_Models[i]);
		if (StrEqual(NC_Models[i], "models/weapons/ventoz/Abyss_Greatsword/v_abyss_greatsword.mdl", true))
			NC_KnifeModel = PrecacheModel("models/weapons/ventoz/Abyss_Greatsword/v_abyss_greatsword.mdl");
		else if (StrEqual(NC_Models[i], "models/weapons/ventoz/Abyss_Greatsword/w_abyss_greatsword.mdl", true))
			NC_KnifeWorldModel = PrecacheModel("models/weapons/ventoz/Abyss_Greatsword/w_abyss_greatsword.mdl");
		else PrecacheModel(NC_Models[i], true);
	}
	for (int i = 0; i < sizeof(NC_Materials); i++)
	{
		AddFileToDownloadsTable(NC_Materials[i]);
		if (StrEqual(NC_Materials[i], "materials/sprites/laserbeam.vmt", true))
			NC_GrenadeBeamSprite1 = PrecacheModel("materials/sprites/laserbeam.vmt");
		
		else if (StrEqual(NC_Materials[i], "materials/sprites/lgtning.vmt", true))
			NC_GrenadeBeamSprite1 = PrecacheModel("materials/sprites/lgtning.vmt");
		
		else if (StrEqual(NC_Materials[i], "sprites/blueglow2.vmt", true))
			NC_GrenadeGlowSprite = PrecacheModel("sprites/blueglow2.vmt");
		
		else if (StrEqual(NC_Materials[i], "materials/sprites/halo01.vmt", true))
			NC_GrenadeHaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
		
		else if (StrEqual(NC_Materials[i], "materials/sprites/bluelaser1.vmt", true))
			NC_GunLaserSprite = PrecacheModel("materials/sprites/bluelaser1.vmt");
		
		else if (StrEqual(NC_Materials[i], "materials/sprites/redglow1.vmt", true))
			NC_GunGlowSprite = PrecacheModel("materials/sprites/redglow1.vmt");
		else PrecacheModel(NC_Materials[i], true);
	}
	for (int i = 0; i < sizeof(NC_Sounds); i++)
	{
		char TempSound[128];
		FormatEx(TempSound, sizeof(TempSound), "sound/%s", NC_Sounds[i]);
		AddFileToDownloadsTable(TempSound);
		PrecacheSoundAny(NC_Sounds[i], true);
	}
	
	int ent;
	int FogIndex = -1;
	ent = FindEntityByClassname(-1, "env_fog_controller");
	if (ent != -1)
	{
		FogIndex = ent;
	}
	else
	{
		FogIndex = CreateEntityByName("env_fog_controller");
		DispatchSpawn(FogIndex);
	}
	DoFog(FogIndex);
	AcceptEntityInput(FogIndex, "TurnOn");
}

public void OnClientPutInServer(int client)
{
	if (IsValidClient(client))
	{
		CreateTimer(15.0, Welcome, client);
		HookStuff(client);
	}
}

public void OnClientDisconnect(int client)
{
	CreateTimer(0.0, DeleteOverlay, client);
	if (IsClientInGame(client))
		ExtinguishEntity(client);
	if (NC_FreezeTimer[client] != INVALID_HANDLE)
	{
		KillTimer(NC_FreezeTimer[client]);
		NC_FreezeTimer[client] = INVALID_HANDLE;
	}
}

public Action OnNormalSoundPlayed(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if (StrContains(sample, "land") != -1)
	{
		return Plugin_Stop;
	}
	if (StrContains(sample, "footsteps") != -1 && IsValidClient(entity) && GetClientTeam(entity) == CS_TEAM_T)
	{
		return Plugin_Stop;
	}
	if (!strcmp(sample, "^weapons/smokegrenade/sg_explode.wav"))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (GetClientTeam(client) == CS_TEAM_T)
	{
		if (buttons & IN_USE && NC_WallClimb[client] == false)
		{
			float f_FinallVector[3];
			float f_EyePosition[3];
			float f_EyeViewPoint[3];
			GetClientEyePosition(client, f_EyePosition);
			GetPlayerEyeViewPoint(client, f_EyeViewPoint);
			MakeVectorFromPoints(f_EyeViewPoint, f_EyePosition, f_FinallVector);
			if (GetVectorLength(f_FinallVector) < 50.0)
			{
				NC_WallClimb[client] = true;
			}
		}
		if (NC_WallClimb[client] == true)
		{
			SetEntityMoveType(client, MOVETYPE_ISOMETRIC);
			
			float f_cLoc[3];
			float f_cAng[3];
			float f_cEndPos[3];
			float f_vector[3];
			GetClientEyePosition(client, f_cLoc);
			GetClientEyeAngles(client, f_cAng);
			TR_TraceRayFilter(f_cLoc, f_cAng, MASK_ALL, RayType_Infinite, TraceRayTryToHit);
			TR_GetEndPosition(f_cEndPos);
			MakeVectorFromPoints(f_cLoc, f_cEndPos, f_vector);
			NormalizeVector(f_vector, f_vector);
			ScaleVector(f_vector, 300.0);
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, f_vector);
			NC_WallClimb[client] = false;
		}
	}
}

public void OnGameFrame()
{
	LoopClients(client)
	{
		if (NC_LaserAim[client] && IsPlayerAlive(client) && GetClientTeam(client) == CS_TEAM_CT)
		{
			CreateBeam(client);
		}
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!strcmp(classname, "hegrenade_projectile"))
	{
		BeamFollowCreate(entity, HEColor);
		IgniteEntity(entity, 2.0);
	}
	else if (!strcmp(classname, "smokegrenade_projectile"))
	{
		BeamFollowCreate(entity, FreezeColor);
		CreateTimer(1.3, CreateEvent_SmokeDetonate, entity, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (!strcmp(classname, "env_particlesmokegrenade"))
	{
		AcceptEntityInput(entity, "Kill");
	}
}

public Action Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	CPrintToChatAll("%s {default}Ready or not here they come!", NC_Tag);
	LoopAllClients(client)
	{
		if (NC_FreezeTimer[client] != INVALID_HANDLE)
		{
			KillTimer(NC_FreezeTimer[client]);
			NC_FreezeTimer[client] = INVALID_HANDLE;
		}
	}
	int score = 0;
	int id = -1;
	LoopClients(client)
	{
		if (GetClientTeam(client) == CS_TEAM_CT && CS_GetClientContributionScore(client) > score)
		{
			id = client;
			score = CS_GetClientContributionScore(client);
		}
	}
	if (id == -1)
		id = GetRandomPlayer(CS_TEAM_CT);
	
	NC_TopPlayer[id] = true;
}

public Action Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ChangeTeamStuff();
	int score = 0;
	int id = -1;
	LoopAllClients(client)
	{
		ResetItems(client);
		if (IsValidClient(client) && GetClientTeam(client) == CS_TEAM_CT && CS_GetClientContributionScore(client) > score)
		{
			id = client;
			score = CS_GetClientContributionScore(client);
		}
	}
	if (id == -1)
		id = GetRandomPlayer(CS_TEAM_CT);
	
	NC_TopPlayer[id] = true;
	return Plugin_Continue;
}

public Action Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	CreateTimer(0.1, SpawnSettings, client);
}

public Action Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (GetClientTeam(attacker) == CS_TEAM_T && GetClientTeam(victim) == CS_TEAM_CT)
		++NC_TeleCount[attacker];
	if (GetClientTeam(attacker) == CS_TEAM_CT && GetClientTeam(victim) == CS_TEAM_T)
		NC_NextRound[attacker] = true;
	ResetItems(victim);
}

public Action Event_OnPlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	char weapon[32];
	event.GetString("weapon", weapon, sizeof(weapon));
	if (StrEqual(weapon, "hegrenade", false))
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		int attacker = GetClientOfUserId(event.GetInt("attacker"));
		if (GetClientTeam(client) != GetClientTeam(attacker))
		{
			IgniteEntity(client, 5.0);
		}
	}
	return Plugin_Continue;
}

public void Event_OnHeDetonate(Event event, const char[] name, bool dontBroadcast)
{
	float origin[3];
	origin[0] = event.GetFloat("x");
	origin[1] = event.GetFloat("y");
	origin[2] = event.GetFloat("z");
	
	TE_SetupBeamRingPoint(origin, 10.0, 400.0, NC_GrenadeBeamSprite2, NC_GrenadeHaloSprite, 1, 1, 0.2, 100.0, 1.0, HEColor, 0, 0);
	TE_SendToAll();
}

public void Event_OnSmokeDetonate(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	float origin[3];
	origin[0] = event.GetFloat("x");
	origin[1] = event.GetFloat("y");
	origin[2] = event.GetFloat("z");
	
	int index = MaxClients + 1;
	
	float xyz[3];
	
	while ((index = FindEntityByClassname(index, "smokegrenade_projectile")) != -1)
	{
		GetEntPropVector(index, Prop_Send, "m_vecOrigin", xyz);
		if (xyz[0] == origin[0] && xyz[1] == origin[1] && xyz[2] == origin[2])
		{
			AcceptEntityInput(index, "kill");
		}
	}
	
	origin[2] += 10.0;
	int clientteam = GetClientTeam(client);
	float targetOrigin[3];
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
		{
			continue;
		}
		
		if (GetClientTeam(i) == clientteam)
		{
			continue;
		}
		
		GetClientAbsOrigin(i, targetOrigin);
		targetOrigin[2] += 2.0;
		if (GetVectorDistance(origin, targetOrigin) <= 200.0)
		{
			Handle trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
			
			if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0))
			{
				Freeze(i, client, 5.0);
				CloseHandle(trace);
			}
			
			else
			{
				CloseHandle(trace);
				
				GetClientEyePosition(i, targetOrigin);
				targetOrigin[2] -= 2.0;
				
				trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
				
				if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0))
				{
					Freeze(i, client, 5.0);
				}
				
				CloseHandle(trace);
			}
		}
	}
	
	TE_SetupBeamRingPoint(origin, 10.0, 200.0, NC_GrenadeBeamSprite2, NC_GrenadeHaloSprite, 1, 1, 0.2, 100.0, 1.0, FreezeColor, 0, 0);
	TE_SendToAll();
	LightCreate(origin);
}

public Action EventSDK_OnClientThink(int client)
{
	if (IsValidClient(client))
	{
		if (IsPlayerAlive(client))
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityGravity(client, 0.3);
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.1);
			}
			if (GetClientTeam(client) == CS_TEAM_CT && NC_IsAdrenaline[client])
			{
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.4);
			}
			if (GetClientTeam(client) == CS_TEAM_CT && !NC_IsAdrenaline[client])
			{
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
			}
		}
	}
}

public Action EventSDK_OnWeaponCanUse(int client, int weapon)
{
	if (IsValidClient(client, true))
	{
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			if (IsValidEntity(weapon))
			{
				char s_weapon[128];
				GetEntityClassname(weapon, s_weapon, sizeof(s_weapon));
				if (StrEqual(s_weapon, "weapon_knife"))
				{
					return Plugin_Continue;
				}
				else if (StrEqual(s_weapon, "weapon_healthshot"))
				{
					return Plugin_Continue;
				}
				else return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}

public Action EventSDK_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (IsValidClient(attacker) && IsValidClient(victim) && GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_CT)
	{
		if (!NC_IsVisible[victim]) {
			NC_iTime[victim] = 3.0;
			SDKUnhook(victim, SDKHook_SetTransmit, Hook_SetTransmit);
			NC_IsVisible[victim] = true;
			NC_iTimer[victim] = CreateTimer(1.0, ResetVisibility, victim, TIMER_REPEAT);
		}
		else
		{
			NC_iTime[victim] = 4.0;
		}
		
		if (!IsPlayerAlive(victim))
			return Plugin_Continue;
		char CurrentWeapon[64];
		GetClientWeapon(attacker, CurrentWeapon, sizeof(CurrentWeapon));
		if (strcmp(CurrentWeapon, "weapon_ssg08", false) == 0 && GetClientTeam(victim) == CS_TEAM_T)
		{
			NC_PoisonCount[victim] = 10;
			CreateTimer(5.0, PoisonPlayer, victim, TIMER_REPEAT);
		}
	}
	return Plugin_Continue;
}

public Action EventSDK_OnPostThinkPost(int client)
{
	if (IsValidClient(client, true))
	{
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			SetEntProp(client, Prop_Send, "m_iAddonBits", 0);
		}
		else if (GetClientTeam(client) == CS_TEAM_CT)
		{
			SetEntProp(client, Prop_Send, "m_iAddonBits", 1);
		}
	}
}

public Action Command_LookAtWeapon(int client, const char[] command, int argc)
{
	if (GetClientTeam(client) == CS_TEAM_T && NC_TeleCount[client] > 0)
	{
		SetTeleportEndPoint(client);
		return Plugin_Handled;
	}
	
	else if (GetClientTeam(client) == CS_TEAM_CT)
	{
		if (NC_Adrenaline[client] && !NC_IsAdrenaline[client])
		{
			SetEntProp(client, Prop_Send, "m_iDefaultFOV", 110);
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.4);
			--NC_Adrenaline[client];
			NC_IsAdrenaline[client] = true;
			CreateTimer(6.0, AdrenalineRush, client);
		}
		else if (NC_TripMine[client] > 0)
		{
			DoMine(client);
		}
		else if (NC_Suicide[client])
		{
			float pos[3];
			GetClientAbsOrigin(client, pos);
			CreateExplosion(pos, client);
			ForcePlayerSuicide(client);
			NC_Suicide[client] = false;
		}
	}
	
	return Plugin_Handled;
}

public Action Command_Kill(int client, const char[] command, int args)
{
	return Plugin_Handled;
}

public Action Command_Join(int client, const char[] command, int argc)
{
	char arg[4];
	GetCmdArg(1, arg, sizeof(arg));
	int NewTeam = StringToInt(arg);
	int OldTeam = GetClientTeam(client);
	
	if ((NewTeam == CS_TEAM_CT && OldTeam == CS_TEAM_T) || (NewTeam == CS_TEAM_T && OldTeam == CS_TEAM_CT))
	{
		CPrintToChat(client, "%s {default}You can\'t change teams like that.", NC_Tag);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action SpawnSettings(Handle timer, any client)
{
	if (IsFakeClient(client))
	{
		HookStuff(client);
	}
	if (GetClientTeam(client) == CS_TEAM_T)
	{
		NCSettings(client);
	}
	else if (GetClientTeam(client) == CS_TEAM_CT)
	{
		HumanSettings(client);
	}
	return Plugin_Handled;
}

public Action Hook_SetTransmit(int client, int entity)
{
	if (IsValidClient(client, true))
	{
		if (client != entity)
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action Unfreeze(Handle timer, any client)
{
	if (NC_FreezeTimer[client] != INVALID_HANDLE)
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
		NC_FreezeTimer[client] = INVALID_HANDLE;
		SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	}
}

public Action CreateEvent_SmokeDetonate(Handle timer, any entity)
{
	if (!IsValidEdict(entity))
	{
		return Plugin_Stop;
	}
	
	char classname[64];
	GetEdictClassname(entity, classname, sizeof(classname));
	if (!strcmp(classname, "smokegrenade_projectile", false))
	{
		float origin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
		int userid = GetClientUserId(GetEntPropEnt(entity, Prop_Send, "m_hThrower"));
		
		Handle event = CreateEvent("smokegrenade_detonate");
		
		SetEventInt(event, "userid", userid);
		SetEventFloat(event, "x", origin[0]);
		SetEventFloat(event, "y", origin[1]);
		SetEventFloat(event, "z", origin[2]);
		FireEvent(event);
	}
	
	return Plugin_Stop;
}

public Action Delete(Handle timer, any entity)
{
	if (IsValidEdict(entity))
	{
		AcceptEntityInput(entity, "kill");
	}
}

public Action Welcome(Handle timer, any client)
{
	if (!IsValidClient(client))
		return Plugin_Handled;
	CPrintToChat(client, "%s {default}Welcome to the world of {red}Nightcrawlers {default}({green}%s {default}by {green}%s{default})", NC_Tag, PLUGIN_VERSION, PLUGIN_AUTHOR);
	return Plugin_Handled;
}

public Action ResetVisibility(Handle timer, int client)
{
	--NC_iTime[client];
	if (NC_iTime[client] == 0)
	{
		NC_IsVisible[client] = false;
		SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action CreateBeam(any client)
{
	int target = TraceClientViewEntity(client);
	float f_playerViewOrigin[3];
	GetClientAbsOrigin(client, f_playerViewOrigin);
	if (GetClientButtons(client) & IN_DUCK)
		f_playerViewOrigin[2] += 40;
	else
		f_playerViewOrigin[2] += 60;
	
	float f_playerViewDestination[3];
	GetPlayerEye(client, f_playerViewDestination);
	
	float distance = GetVectorDistance(f_playerViewOrigin, f_playerViewDestination);
	
	float percentage = 0.4 / (distance / 100);
	
	float f_newPlayerViewOrigin[3];
	f_newPlayerViewOrigin[0] = f_playerViewOrigin[0] + ((f_playerViewDestination[0] - f_playerViewOrigin[0]) * percentage);
	f_newPlayerViewOrigin[1] = f_playerViewOrigin[1] + ((f_playerViewDestination[1] - f_playerViewOrigin[1]) * percentage) - 0.08;
	f_newPlayerViewOrigin[2] = f_playerViewOrigin[2] + ((f_playerViewDestination[2] - f_playerViewOrigin[2]) * percentage);
	
	int color[4];
	if (target > 0 && target <= MaxClients && GetClientTeam(target) == CS_TEAM_T)
	{
		color[0] = 255;
		color[1] = 0;
		color[2] = 0;
		color[3] = 200;
	}
	else
	{
		color[0] = 0;
		color[1] = 255;
		color[2] = 0;
		color[3] = 200;
	}
	
	float life;
	life = 0.1;
	
	float width;
	width = 0.48;
	float dotWidth;
	dotWidth = 0.12;
	
	TE_SetupBeamPoints(f_newPlayerViewOrigin, f_playerViewDestination, NC_GunLaserSprite, 0, 0, 0, life, width, 0.0, 1, 0.0, color, 0);
	TE_SendToAll();
	
	TE_SetupGlowSprite(f_playerViewDestination, NC_GunGlowSprite, life, dotWidth, color[3]);
	TE_SendToAll();
	
	return Plugin_Continue;
}

public Action AdrenalineRush(Handle timer, any client)
{
	NC_IsAdrenaline[client] = false;
	SetEntProp(client, Prop_Send, "m_iDefaultFOV", 90);
	return Plugin_Handled;
}

public Action PoisonPlayer(Handle timer, any client)
{
	int life;
	life = GetClientHealth(client);
	if (life == 1)
	{
		return Plugin_Stop;
	}
	else
	{
		int SlapMax = 5;
		if (SlapMax >= life)
			SlapPlayer(client, GetRandomInt(0, life - 1), true);
		else SlapPlayer(client, GetRandomInt(0, SlapMax), true);
	}
	
	--NC_PoisonCount[client];
	
	if (NC_PoisonCount[client] <= 0)
	{
		NC_PoisonCount[client] = 0;
		return Plugin_Stop;
	}
	return Plugin_Handled;
}

public Action DoMine(int client)
{
	if (IsValidClient(client))
	{
		if (IsPlayerAlive(client))
		{
			if (NC_TripMine[client] > 0)
			{
				PlaceMine(client);
			}
		}
	}
}

public void PlaceMine(int client)
{
	float trace_start[3];
	float trace_angle[3];
	float trace_end[3];
	float trace_normal[3];
	GetClientEyePosition(client, trace_start);
	GetClientEyeAngles(client, trace_angle);
	GetAngleVectors(trace_angle, trace_end, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(trace_end, trace_end);
	
	for (int i = 0; i < 3; i++)
	trace_start[i] += trace_end[i] * 1.0;
	
	for (int i = 0; i < 3; i++)
	trace_end[i] = trace_start[i] + trace_end[i] * 80.0;
	
	TR_TraceRayFilter(trace_start, trace_end, CONTENTS_SOLID | CONTENTS_WINDOW, RayType_EndPoint, TraceFilter_All, 0);
	
	if (TR_DidHit(INVALID_HANDLE))
	{
		--NC_TripMine[client];
		
		if (NC_TripMine[client] != 0)
		{
			PrintCenterText(client, "[NC] You have %d mines left!", NC_TripMine[client]);
		}
		else
		{
			PrintCenterText(client, "[NC] That was your last mine!");
		}
		
		TR_GetEndPosition(trace_end, INVALID_HANDLE);
		TR_GetPlaneNormal(INVALID_HANDLE, trace_normal);
		
		SetupMine(client, trace_end, trace_normal);
		
	}
	else
	{
		PrintCenterText(client, "[NC] Invalid mine position.");
	}
}

public void SetupMine(int client, float position[3], float normal2[3])
{
	
	char mine_name[64];
	char beam_name[64];
	char str[128];
	
	Format(mine_name, 64, "NC_Mine_%d", NC_TripMineCounter);
	
	
	float angles[3];
	GetVectorAngles(normal2, angles);
	
	
	int ent = CreateEntityByName("prop_physics_override");
	
	Format(beam_name, 64, "rxgtripmine%d_%d", NC_TripMineCounter, ent);
	
	DispatchKeyValue(ent, "model", "models/tripmine/tripmine.mdl");
	DispatchKeyValue(ent, "physdamagescale", "0.0");
	DispatchKeyValue(ent, "health", "1");
	DispatchKeyValue(ent, "targetname", mine_name);
	DispatchKeyValue(ent, "spawnflags", "256");
	DispatchSpawn(ent);
	
	SetEntityMoveType(ent, MOVETYPE_NONE);
	SetEntProp(ent, Prop_Data, "m_takedamage", 2);
	SetEntPropEnt(ent, Prop_Data, "m_hLastAttacker", client);
	SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
	SetEntityRenderColor(ent, 255, 255, 255, 255);
	SetEntProp(ent, Prop_Send, "m_CollisionGroup", 2);
	
	
	
	Format(str, sizeof(str), "%s,Kill,,0,-1", beam_name);
	DispatchKeyValue(ent, "OnBreak", str);
	
	HookSingleEntityOutput(ent, "OnBreak", MineBreak, true);
	
	for (int i = 0; i < 3; i++) {
		position[i] += normal2[i] * 0.5;
	}
	TeleportEntity(ent, position, angles, NULL_VECTOR);
	
	TR_TraceRayFilter(position, angles, CONTENTS_SOLID, RayType_Infinite, TraceFilter_All, 0);
	
	float beamend[3];
	TR_GetEndPosition(beamend, INVALID_HANDLE);
	
	int ent_laser = CreateLaser(beamend, position, beam_name, GetClientTeam(client));
	
	HookSingleEntityOutput(ent_laser, "OnTouchedByEntity", MineLaser_OnTouch);
	SetEntPropEnt(ent_laser, Prop_Data, "m_hOwnerEntity", client);
	
	Handle data;
	CreateDataTimer(1.0, ActivateTimer, data, TIMER_REPEAT);
	ResetPack(data);
	WritePackCell(data, 0);
	WritePackCell(data, ent);
	WritePackCell(data, ent_laser);
	
	PlayMineSound(ent, "weapons/g3sg1/g3sg1_slideback.wav");
	
	NC_TripMineCounter++;
}

public void PlayMineSound(int entity, const char[] sound)
{
	EmitSoundToAllAny(sound, entity);
}

public void MineLaser_OnTouch(const char[] output, int caller, int activator, float delay)
{
	AcceptEntityInput(caller, "TurnOff");
	AcceptEntityInput(caller, "TurnOn");
	if (!IsPlayerAlive(activator) || !IsClientInGame(activator))return;
	bool detonate = false;
	
	int owner = GetEntPropEnt(caller, Prop_Data, "m_hOwnerEntity");
	
	if (!IsValidClient(owner) || !IsPlayerAlive(owner))
	{
		detonate = true;
	}
	else
	{
		if (GetClientTeam(activator) == CS_TEAM_T)
		{
			DispatchKeyValue(caller, "rendercolor", "255 0 0");
		}
		else
		{
			DispatchKeyValue(caller, "rendercolor", "0 255 0");
		}
	}
	if (detonate)
	{
		char targetname[64];
		GetEntPropString(caller, Prop_Data, "m_iName", targetname, sizeof(targetname));
		
		char buffers[2][32];
		
		ExplodeString(targetname, "_", buffers, 2, 32);
		
		int ent_mine = StringToInt(buffers[1]);
		
		AcceptEntityInput(ent_mine, "break");
	}
	return;
}

public int CreateLaser(float start[3], float end[3], char[] name, int team)
{
	int ent = CreateEntityByName("env_beam");
	if (ent != -1)
	{
		TeleportEntity(ent, start, NULL_VECTOR, NULL_VECTOR);
		SetEntityModel(ent, "materials/sprites/purplelaser1.vmt");
		SetEntPropVector(ent, Prop_Data, "m_vecEndPos", end);
		DispatchKeyValue(ent, "targetname", name);
		DispatchKeyValue(ent, "rendercolor", "0 255 0");
		DispatchKeyValue(ent, "renderamt", "80");
		DispatchKeyValue(ent, "decalname", "Bigshot");
		DispatchKeyValue(ent, "life", "0");
		DispatchKeyValue(ent, "TouchType", "0");
		DispatchSpawn(ent);
		SetEntPropFloat(ent, Prop_Data, "m_fWidth", 1.0);
		SetEntPropFloat(ent, Prop_Data, "m_fEndWidth", 1.0);
		ActivateEntity(ent);
		AcceptEntityInput(ent, "TurnOn");
	}
	return ent;
}

public Action ActivateTimer(Handle timer, Handle data)
{
	ResetPack(data);
	
	int counter = ReadPackCell(data);
	int ent = ReadPackCell(data);
	int ent_laser = ReadPackCell(data);
	
	if (!IsValidEntity(ent))
	{
		return Plugin_Stop;
	}
	
	if (counter < 3)
	{
		PlayMineSound(ent, "weapons/c4/c4_beep1.wav");
		counter++;
		ResetPack(data);
		WritePackCell(data, counter);
	}
	else
	{
		PlayMineSound(ent, "items/nvg_on.wav");
		
		DispatchKeyValue(ent_laser, "TouchType", "4");
		DispatchKeyValue(ent_laser, "renderamt", "220");
		
		
		return Plugin_Stop;
	}
	
	return Plugin_Handled;
}

public void MineBreak(const char[] output, int caller, int activator, float delay)
{
	float pos[3];
	GetEntPropVector(caller, Prop_Send, "m_vecOrigin", pos);
	CreateExplosionDelayed(pos, GetEntPropEnt(caller, Prop_Data, "m_hLastAttacker"));
}

public void CreateExplosionDelayed(float vec[3], int owner)
{
	DataPack data;
	CreateDataTimer(0.1, CreateExplosionDelayedTimer, data);
	
	WritePackCell(data, owner);
	WritePackFloat(data, vec[0]);
	WritePackFloat(data, vec[1]);
	WritePackFloat(data, vec[2]);
}

public Action CreateExplosionDelayedTimer(Handle timer, DataPack data)
{
	ResetPack(data);
	int owner = ReadPackCell(data);
	
	float vec[3];
	vec[0] = ReadPackFloat(data);
	vec[1] = ReadPackFloat(data);
	vec[2] = ReadPackFloat(data);
	
	CreateExplosion(vec, owner);
	
	return Plugin_Handled;
}

public void CreateExplosion(float vec[3], int owner)
{
	int ent = CreateEntityByName("env_explosion");
	DispatchKeyValue(ent, "classname", "env_explosion");
	SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", owner);
	SetEntProp(ent, Prop_Data, "m_iMagnitude", 300);
	
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	char exp_sample[64];
	
	Format(exp_sample, 64, ")weapons/hegrenade/explode%d.wav", GetRandomInt(3, 5));
	
	if (NC_ExplosionSound)
	{
		NC_ExplosionSound = false;
		EmitAmbientSoundAny(exp_sample, vec, _, SNDLEVEL_GUNFIRE);
		CreateTimer(0.1, EnableExplosionSound);
	}
	
	TeleportEntity(ent, vec, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(ent, "explode");
	AcceptEntityInput(ent, "kill");
}

public Action EnableExplosionSound(Handle timer)
{
	NC_ExplosionSound = true;
	return Plugin_Handled;
}

public void ArmsFix_OnModelSafe(int client)
{
	if (IsValidClient(client))
	{
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			SetEntityModel(client, "models/player/custom_player/kodua/eliminator/eliminator.mdl");
		}
		else if (GetClientTeam(client) == CS_TEAM_CT)
		{
			if (NC_TopPlayer[client])
				SetEntityModel(client, "models/player/custom_player/kuristaja/cso2/helga/helga.mdl");
			else SetEntityModel(client, "models/player/custom_player/kuristaja/cso2/gsg9/gsg9.mdl");
		}
	}
}

public void ArmsFix_OnArmsSafe(int client)
{
	if (IsValidClient(client))
	{
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			ArmsFix_SetDefaultArms(client);
			FPVMI_AddViewModelToClient(client, "weapon_knife", NC_KnifeModel);
			FPVMI_AddWorldModelToClient(client, "weapon_knife", NC_KnifeWorldModel);
		}
		else if (GetClientTeam(client) == CS_TEAM_CT)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_knife");
			if (NC_TopPlayer[client])
				SetEntPropString(client, Prop_Send, "m_szArmsModel", "models/player/custom_player/kuristaja/cso2/helga/helga_arms.mdl");
			else SetEntPropString(client, Prop_Send, "m_szArmsModel", "models/player/custom_player/kuristaja/cso2/gsg9/gsg9_arms.mdl");
		}
	}
}

public void ResetItems(int client)
{
	NC_LaserAim[client] = false;
	NC_Adrenaline[client] = 0;
	NC_IsAdrenaline[client] = false;
	NC_Scout[client] = false;
	NC_Suicide[client] = false;
	NC_TripMine[client] = 0;
	NC_PoisonCount[client] = 0;
	NC_TopPlayer[client] = false;
}

public void HumanSettings(int client)
{
	NC_TeleCount[client] = 0;
	SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	StripWeapons(client);
	SetEntityGravity(client, 1.0);
	SetEntityHealth(client, 100);
	SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntProp(client, Prop_Send, "m_bNightVisionOn", 0);
	SetEntProp(client, Prop_Send, "m_iDefaultFOV", 90);
	SetEntData(client, FindSendPropInfo("CCSPlayer", "m_iAccount"), 0);
	StoreToAddress(GetEntityAddress(client) + NC_SpotRadar, 9, NumberType_Int32);
	if (!IsFakeClient(client))
	{
		SendConVarValue(client, FindConVar("sv_min_jump_landing_sound"), "260");
		SendConVarValue(client, FindConVar("sv_footsteps"), "1");
	}
	WeaponMenu(client);
}

public void NCSettings(int client)
{
	NC_TeleCount[client] = 3;
	SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	StripWeapons(client);
	SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.1);
	SetEntityGravity(client, 0.3);
	SetEntityHealth(client, 250);
	SetEntProp(client, Prop_Send, "m_bNightVisionOn", 1);
	SetEntProp(client, Prop_Send, "m_iDefaultFOV", 110);
	SetEntProp(client, Prop_Send, "m_bSpotted", false);
	SetEntProp(client, Prop_Send, "m_bSpottedByMask", 0, 4, 0);
	SetEntProp(client, Prop_Send, "m_bSpottedByMask", 0, 4, 1);
	SetEntData(client, FindSendPropInfo("CCSPlayer", "m_iAccount"), 0);
	StoreToAddress(GetEntityAddress(client) + NC_SpotRadar, 0, NumberType_Int32);
	ShowHudText(client, 1, "Teleports Remaining: %i", NC_TeleCount[client]);
	if (!IsFakeClient(client))
	{
		SendConVarValue(client, FindConVar("sv_min_jump_landing_sound"), "99999");
		SendConVarValue(client, FindConVar("sv_footsteps"), "0");
	}
}

public void WeaponMenu(int client)
{
	Menu menu = new Menu(MenuHandler1);
	SetMenuExitButton(menu, false);
	SetMenuPagination(menu, MENU_NO_PAGINATION);
	menu.SetTitle("[NC] Weapon Menu");
	menu.AddItem("1", "AK-47 + Glock-18");
	menu.AddItem("2", "M4A4/M4A1-S + P2000/USP-S");
	menu.AddItem("3", "Nova + P250");
	menu.AddItem("4", "XM1014 + Tec-9");
	menu.AddItem("5", "UMP-45 + Five-SeveN");
	menu.AddItem("6", "M249 + Dual Berettas");
	menu.AddItem("7", "AWP + Desert Eagle");
	menu.Display(client, MENU_TIME_FOREVER);
}

public void ItemMenu(int client)
{
	Menu menu = new Menu(MenuHandler2);
	SetMenuExitButton(menu, false);
	SetMenuPagination(menu, MENU_NO_PAGINATION);
	menu.SetTitle("[NC] Weapon Menu");
	if (NC_TopPlayer[client])
		menu.AddItem("1", "Laser Sight");
	else
		menu.AddItem("1", "Laser Sight", ITEMDRAW_DISABLED);
	menu.AddItem("2", "Trip Laser (x2)");
	menu.AddItem("3", "Frost Grenade (x2)");
	menu.AddItem("4", "Napalm Grenade (x2)");
	menu.AddItem("5", "Poison Scout");
	menu.AddItem("6", "Suicide Bomber");
	menu.AddItem("7", "Adrenaline (x2)");
	menu.AddItem("8", "Healthshot (x2)");
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler2(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		int client = param1;
		switch (param2)
		{
			case 0:
			{
				NC_LaserAim[client] = true;
				CPrintToChat(client, "%s {default}Got {green}Laser Sight{default}! Turns {red}Red{default} upon aiming at Nightcrawlers.", NC_Tag);
			}
			case 1:
			{
				NC_TripMine[client] = 2;
				CPrintToChat(client, "%s {default}Got {green}2x Trip Laser{default}! Set up a trap for the Nightcrawlers.", NC_Tag);
				CPrintToChat(client, "%s {default}Press {green}F{default} to deploy your item.", NC_Tag);
			}
			case 2:
			{
				CPrintToChat(client, "%s {default}Got {green}2x Frost Grenade{default}! Freezes Nightcrawlers upon contact for some time.", NC_Tag);
				GivePlayerItem(client, "weapon_smokegrenade");
				GivePlayerItem(client, "weapon_smokegrenade");
			}
			case 3:
			{
				CPrintToChat(client, "%s {default}Got {green}2x Napalm Grenade{default}! Burns Nightcrawlers upon contact for some time.", NC_Tag);
				GivePlayerItem(client, "weapon_hegrenade");
				GivePlayerItem(client, "weapon_hegrenade");
			}
			case 4:
			{
				NC_Scout[client] = true;
				CPrintToChat(client, "%s {default}Got a {green}Scout{default} with {green}Poisonous Bullets{default}! Hear the cries of the Nightcrawlers affected.", NC_Tag);
				int slot;
				if ((slot = GetPlayerWeaponSlot(client, 0)) != -1)
				{
					RemovePlayerItem(client, slot);
				}
				GivePlayerItem(client, "weapon_ssg08");
			}
			case 5:
			{
				NC_Suicide[client] = true;
				CPrintToChat(client, "%s {default}You are now a {green}Suicide Bomber{default}! Take Nightcrawlers down with you.", NC_Tag);
				CPrintToChat(client, "%s {default}Press {green}F{default} to use your item.", NC_Tag);
			}
			case 6:
			{
				NC_Adrenaline[client] = 2;
				CPrintToChat(client, "%s {default}Got {green}2x Adrenaline{default} shots! Use them to run faster for some time.", NC_Tag);
				CPrintToChat(client, "%s {default}Press {green}F{default} to use your item.", NC_Tag);
			}
			case 7:
			{
				CPrintToChat(client, "%s {default}Got {green}2x Healthshot{default}! Heal yourself to survive longer.", NC_Tag);
				GivePlayerItem(client, "weapon_healthshot");
				GivePlayerItem(client, "weapon_healthshot");
			}
		}
	}
}

public int MenuHandler1(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:
			{
				GivePlayerItem(param1, "weapon_ak47");
				GivePlayerItem(param1, "weapon_glock");
			}
			case 1:
			{
				GivePlayerItem(param1, "weapon_m4a4");
				GivePlayerItem(param1, "weapon_hkp2000");
				GivePlayerItem(param1, "weapon_m4a1_silencer");
				GivePlayerItem(param1, "weapon_usp_silencer");
			}
			case 2:
			{
				GivePlayerItem(param1, "weapon_nova");
				GivePlayerItem(param1, "weapon_p250");
			}
			case 3:
			{
				GivePlayerItem(param1, "weapon_xm1014");
				GivePlayerItem(param1, "weapon_tec9");
			}
			case 4:
			{
				GivePlayerItem(param1, "weapon_ump45");
				GivePlayerItem(param1, "weapon_fiveseven");
			}
			case 5:
			{
				GivePlayerItem(param1, "weapon_m249");
				GivePlayerItem(param1, "weapon_elite");
			}
			case 6:
			{
				GivePlayerItem(param1, "weapon_awp");
				GivePlayerItem(param1, "weapon_deagle");
			}
		}
		
		ItemMenu(param1);
	}
}

public int TraceClientViewEntity(int client)
{
	float m_vecOrigin[3];
	float m_angRotation[3];
	
	GetClientEyePosition(client, m_vecOrigin);
	GetClientEyeAngles(client, m_angRotation);
	
	Handle tr = TR_TraceRayFilterEx(m_vecOrigin, m_angRotation, MASK_VISIBLE, RayType_Infinite, TRDontHitSelf, client);
	int pEntity = -1;
	
	if (TR_DidHit(tr))
	{
		pEntity = TR_GetEntityIndex(tr);
		CloseHandle(tr);
		return pEntity;
	}
	
	if (tr != INVALID_HANDLE)
	{
		CloseHandle(tr);
	}
	
	return -1;
}

public void MapSettings()
{
	SetCvarStr("mp_teamname_1", "Humans");
	SetCvarStr("mp_teamname_2", "Nightcrawlers");
	SetCvarInt("sv_ignoregrenaderadio", 1);
	SetCvarInt("sv_disable_immunity_alpha", 1);
	SetCvarInt("sv_airaccelerate", 120);
	SetCvarInt("mp_maxrounds", 30);
	SetCvarFloat("mp_roundtime", 2.5);
	SetCvarFloat("mp_roundtime_defuse", 2.5);
	SetCvarInt("mp_defuser_allocation", 0);
	SetCvarInt("mp_solid_teammates", 0);
	SetCvarInt("sv_deadtalk", 0);
	SetCvarInt("sv_talk_enemy_dead", 1);
	SetCvarInt("sv_talk_enemy_living", 1);
	SetCvarInt("mp_autokick", 0);
	SetCvarInt("mp_free_armor", 0);
	SetCvarInt("mp_buytime", 0);
	SetCvarInt("mp_autoteambalance", 0);
	SetCvarInt("mp_limitteams", 0);
	SetCvarInt("mp_do_warmup_period", 0);
	SetCvarInt("mp_give_player_c4", 0);
	SetCvarInt("mp_freezetime", 0);
	SetCvarInt("ammo_grenade_limit_default", 2);
	SetCvarInt("mp_weapons_allow_map_placed", 0);
}

public void HookStuff(int client)
{
	SDKHook(client, SDKHook_PreThink, EventSDK_OnClientThink);
	SDKHook(client, SDKHook_WeaponCanUse, EventSDK_OnWeaponCanUse);
	SDKHook(client, SDKHook_OnTakeDamage, EventSDK_OnTakeDamage);
	SDKHook(client, SDKHook_PostThinkPost, EventSDK_OnPostThinkPost);
}

public void DoFog(int FogIndex)
{
	if (FogIndex != -1)
	{
		DispatchKeyValue(FogIndex, "fogblend", "0");
		DispatchKeyValue(FogIndex, "fogcolor", "0 0 0");
		DispatchKeyValue(FogIndex, "fogcolor2", "0 0 0");
		DispatchKeyValueFloat(FogIndex, "fogstart", 0.0);
		DispatchKeyValueFloat(FogIndex, "fogend", 150.0);
		DispatchKeyValueFloat(FogIndex, "fogmaxdensity", 0.7);
	}
}

public void LightCreate(float pos[3])
{
	int iEntity = CreateEntityByName("light_dynamic");
	DispatchKeyValue(iEntity, "inner_cone", "0");
	DispatchKeyValue(iEntity, "cone", "80");
	DispatchKeyValue(iEntity, "brightness", "1");
	DispatchKeyValueFloat(iEntity, "spotlight_radius", 150.0);
	DispatchKeyValue(iEntity, "pitch", "90");
	DispatchKeyValue(iEntity, "style", "1");
	DispatchKeyValue(iEntity, "_light", "75 75 255 255");
	DispatchKeyValueFloat(iEntity, "distance", 200.0);
	EmitSoundToAllAny("nightcrawler/freeze_cam.mp3", iEntity, SNDCHAN_WEAPON);
	CreateTimer(0.2, Delete, iEntity, TIMER_FLAG_NO_MAPCHANGE);
	DispatchSpawn(iEntity);
	TeleportEntity(iEntity, pos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(iEntity, "TurnOn");
}

public bool Freeze(int client, int attacker, float time)
{
	if (NC_FreezeTimer[client] != INVALID_HANDLE)
	{
		KillTimer(NC_FreezeTimer[client]);
		NC_FreezeTimer[client] = INVALID_HANDLE;
	}
	
	SetEntityMoveType(client, MOVETYPE_NONE);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);
	
	float vec[3];
	GetClientEyePosition(client, vec);
	vec[2] -= 50.0;
	EmitAmbientSoundAny("physics/glass/glass_impact_bullet4.wav", vec, client, SNDLEVEL_RAIDSIREN);
	
	TE_SetupGlowSprite(vec, NC_GrenadeGlowSprite, time, 2.0, 50);
	TE_SendToAll();
	SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	NC_FreezeTimer[client] = CreateTimer(time, Unfreeze, client, TIMER_FLAG_NO_MAPCHANGE);
	return true;
}

public void BeamFollowCreate(int entity, int color[4])
{
	TE_SetupBeamFollow(entity, NC_GrenadeBeamSprite1, 0, 1.0, 10.0, 10.0, 5, color);
	TE_SendToAll();
}

public void ChangeTeamStuff()
{
	int players = 0;
	LoopClients(client)
	{
		if (GetClientTeam(client) != CS_TEAM_CT && GetClientTeam(client) != CS_TEAM_T)
			continue;
		CS_SwitchTeam(client, CS_TEAM_CT);
		players++;
	}
	
	int iCTsToMove = 0;
	iCTsToMove = RoundToFloor(float(players) / 3.0);
	//We need at least one nightcrawler
	if (iCTsToMove < 1 && players > 1)
		iCTsToMove = 1;
	//Only real players can be nightcrawlers, so don't move more than available (infinite loop below)
	if (iCTsToMove > players)
		iCTsToMove = players;
	//Max 6 nightcrawlers no matter how many CTs
	if (iCTsToMove > 6)
		iCTsToMove = 6;
	
	int target, ctCount = 0;
	LoopClients(i)
	{
		if (NC_NextRound[i] && ctCount < iCTsToMove)
		{
			CS_SwitchTeam(i, CS_TEAM_T);
			NC_NextRound[i] = false;
			ctCount++;
		}
	}
	while (ctCount < iCTsToMove)
	{
		target = GetRandomPlayer(CS_TEAM_CT);
		CS_SwitchTeam(target, CS_TEAM_T);
		ctCount++;
	}
	
	LoopClients(i)
	{
		StripAllWeapons(i);
	}
}

public void PerformTeleport(int target, float pos[3])
{
	float partpos[3];
	
	GetClientEyePosition(target, partpos);
	partpos[2] -= 20.0;
	
	TeleportEntity(target, pos, NULL_VECTOR, NULL_VECTOR);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			EmitSoundToAllAny("nightcrawler/teleport.mp3", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
		}
	}
	pos[2] += 40.0;
	--NC_TeleCount[target];
	ShowHudText(target, 1, "Teleports Remaining: %i", NC_TeleCount[target]);
}

public void SetTeleportEndPoint(int client)
{
	float vAngles[3];
	float vOrigin[3];
	float vBuffer[3];
	float vStart[3];
	float Distance;
	float g_pos[3];
	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(vStart, trace);
		GetVectorDistance(vOrigin, vStart, false);
		Distance = -35.0;
		GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		g_pos[0] = vStart[0] + (vBuffer[0] * Distance);
		g_pos[1] = vStart[1] + (vBuffer[1] * Distance);
		g_pos[2] = vStart[2] + (vBuffer[2] * Distance);
	}
	CloseHandle(trace);
	PerformTeleport(client, g_pos);
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return entity > GetMaxClients() || !entity;
}

public bool TRDontHitSelf(int entity, int contentsMask, any client)
{
	return entity != client;
}

public bool TraceRayTryToHit(int entity, int mask)
{
	if (entity > 0 && entity <= MaxClients)
	{
		return false;
	}
	return true;
}

public bool FilterTarget(int entity, int contentsMask, any data)
{
	return (data == entity);
}

public bool TraceFilter_All(int entity, int contentsMask)
{
	return false;
}

stock void SetCvarStr(char[] scvar, char[] svalue)
{
	SetConVarString(FindConVar(scvar), svalue, true);
}

stock void SetCvarInt(char[] scvar, int svalue)
{
	SetConVarInt(FindConVar(scvar), svalue, true);
}

stock void SetCvarFloat(char[] scvar, float svalue)
{
	SetConVarFloat(FindConVar(scvar), svalue, true);
}

stock void StripAllWeapons(int client)
{
	int ent;
	for (int i = 0; i <= 4; i++)
	{
		while ((ent = GetPlayerWeaponSlot(client, i)) != -1)
		{
			RemovePlayerItem(client, ent);
			RemoveEdict(ent);
		}
	}
}

stock void StripWeapons(int client)
{
	int wepIdx;
	for (int x = 0; x <= 5; x++)
	{
		if (x != 2 && (wepIdx = GetPlayerWeaponSlot(client, x)) != -1)
		{
			RemovePlayerItem(client, wepIdx);
			RemoveEdict(wepIdx);
		}
	}
}

stock int CountPlayersInTeam(int team = 0)
{
	int x = 0;
	LoopClients(i)
	{
		if (team != 0)
		{
			if (GetClientTeam(i) == team)
			{
				x++;
			}
		}
		else
		{
			x++;
		}
	}
	return x;
}

stock int CountAlivePlayersInTeam(int team = 0)
{
	int x = 0;
	LoopAliveClients(i)
	{
		if (team != 0)
		{
			if (GetClientTeam(i) == team)
			{
				x++;
			}
		}
		else
		{
			x++;
		}
	}
	return x;
}

stock int GetRandomPlayer(int team)
{
	int clients[MAXPLAYERS + 1];
	int clientCount;
	for (int i = 1; i <= MAXPLAYERS; i++)
	if (IsValidClient(i) && (GetClientTeam(i) == team))
		clients[clientCount++] = i;
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];
}

stock bool IsValidClient(int client, bool alive = false)
{
	if (0 < client && client <= MaxClients && IsClientInGame(client)/*&& IsFakeClient(client) == false*/ && (alive == false || IsPlayerAlive(client)))
	{
		return true;
	}
	return false;
}

stock bool IsClientAdmin(int client)
{
	if (GetAdminFlag(GetUserAdmin(client), Admin_Generic))
	{
		return true;
	}
	return false;
}

stock bool IsClientVIP(int client, AdminFlag type)
{
	if (GetAdminFlag(GetUserAdmin(client), type))
	{
		return true;
	}
	return false;
}

stock bool IsClientInAir(int client, int flags)
{
	return !(flags & FL_ONGROUND || b_ClientWallHang[client]);
}

stock bool IsClientNotMoving(int buttons)
{
	return !IsMoveButtonsPressed(buttons);
}

stock bool IsMoveButtonsPressed(int buttons)
{
	return buttons & IN_FORWARD || buttons & IN_BACK || buttons & IN_MOVELEFT || buttons & IN_MOVERIGHT;
}

stock bool GetPlayerEyeViewPoint(int client, float pos[3])
{
	float f_Angles[3];
	float f_Origin[3];
	GetClientEyeAngles(client, f_Angles);
	GetClientEyePosition(client, f_Origin);
	Handle h_TraceFilter = TR_TraceRayFilterEx(f_Origin, f_Angles, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer);
	if (TR_DidHit(h_TraceFilter))
	{
		TR_GetEndPosition(pos, h_TraceFilter);
		CloseHandle(h_TraceFilter);
		return true;
	}
	CloseHandle(h_TraceFilter);
	return false;
}

stock bool GetPlayerEye(int client, float pos[3])
{
	float vAngles[3];
	float vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TRDontHitSelf, client);
	
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(pos, trace);
		CloseHandle(trace);
		return true;
	}
	CloseHandle(trace);
	return false;
} 