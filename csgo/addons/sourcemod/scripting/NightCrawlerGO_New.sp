#pragma semicolon 1
#pragma newdecls required

EngineVersion g_Game;

Address NC_SpotRadar = view_as<Address>(868);
#define LoopAllClients(%1) for(int %1 = 1;%1 <= MaxClients;%1++)
#define LoopClients(%1) for(int %1 = 1;%1 <= MaxClients;%1++) if(IsValidClient(%1))
#define LoopAliveClients(%1) for(int %1 = 1;%1 <= MaxClients;%1++) if(IsValidClient(%1, true))

#define HEColor 	{255,75,75,255}
#define FreezeColor	{75,75,255,255}

#define PLUGIN_AUTHOR "Simon"
#define PLUGIN_VERSION "1.8"
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
bool NC_IsFrozen[MAXPLAYERS + 1] =  { false, ... };
bool NC_NextRound[MAXPLAYERS + 1] =  { false, ... };
bool NC_IsVisible[MAXPLAYERS + 1] =  { false, ... };
float NC_iTime[MAXPLAYERS + 1] =  { 0.0, ... };
Handle NC_iTimer[MAXPLAYERS + 1];
Handle NC_FreezeTimer[MAXPLAYERS + 1];
float LastTele[MAXPLAYERS + 1];

int NC_GrenadeBeamSprite1;
int NC_GrenadeBeamSprite2;
int NC_GrenadeHaloSprite;
int NC_GrenadeGlowSprite;
int NC_GunLaserSprite;
int NC_GunGlowSprite;
int NC_KnifeModel;

bool NC_LaserAim[MAXPLAYERS + 1] =  { false, ... };
int NC_Adrenaline[MAXPLAYERS + 1];
bool NC_IsAdrenaline[MAXPLAYERS + 1] =  { false, ... };
bool NC_Scout[MAXPLAYERS + 1] =  { false, ... };
bool NC_Suicide[MAXPLAYERS + 1] =  { false, ... };
bool NC_ExplosionSound = true;
int NC_TripMine[MAXPLAYERS + 1];
int NC_TripMineCounter = 0;
int NC_PoisonCounter[MAXPLAYERS + 1];
bool NC_TopPlayer[MAXPLAYERS + 1] =  { false, ... };

ConVar NC_Ratio;
ConVar NC_VisibleDuration;
ConVar NC_HumanMaxHealth;
ConVar NC_NightcrawlerHealth;
ConVar NC_NightcrawlerGravity;
ConVar NC_NightcrawlerSpeed;
ConVar NC_TeleportCount;
ConVar NC_TeleportDelay;
ConVar NC_Lighting;
ConVar NC_AdrenalineCount;
ConVar NC_AdrenalineDuration;
ConVar NC_AdrenalineHealth;
ConVar NC_AdrenalineSpeed;
ConVar NC_SuicideDamage;
ConVar NC_SuicideRadius;
ConVar NC_SuicideDelay;
ConVar NC_PoisonCount;
ConVar NC_PoisonInterval;
ConVar NC_PoisonMaxDamage;
ConVar NC_TripMineCount;
ConVar NC_TripMineBlast;
ConVar NC_FrostNadeCount;
ConVar NC_FrostNadeRadius;
ConVar NC_FrostNadeDuration;
ConVar NC_NapalmNadeCount;
ConVar NC_NapalmNadeRadius;
ConVar NC_NapalmNadeDuration;
ConVar NC_AmmoMode;

char NC_Models[][] = 
{
	"models/tripmine/tripmine.dx90.vtx", 
	"models/tripmine/tripmine.mdl", 
	"models/tripmine/tripmine.phy", 
	"models/tripmine/tripmine.vvd", 
	"models/player/custom_player/kodua/re/birkin/birkin2.mdl", 
	"models/player/custom_player/kodua/re/birkin/birkin2.dx90.vtx", 
	"models/player/custom_player/kodua/re/birkin/birkin2.phy", 
	"models/player/custom_player/kodua/re/birkin/birkin2.vvd", 
	"models/player/custom_player/xlegend/birkin/birkin_arms.dx90.vtx", 
	"models/player/custom_player/xlegend/birkin/birkin_arms.mdl", 
	"models/player/custom_player/xlegend/birkin/birkin_arms.vvd", 
	"models/player/custom_player/kodua/re/birkin/birkin3_f.dx90.vtx", 
	"models/player/custom_player/kodua/re/birkin/birkin3_f.mdl", 
	"models/player/custom_player/kodua/re/birkin/birkin3_f.phy", 
	"models/player/custom_player/kodua/re/birkin/birkin3_f.vvd", 
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
	"models/weapons/ventoz/Abyss_Greatsword/w_abyss_greatsword.vvd", 
	"models/weapons/eminem/ice_cube/ice_cube.phy", 
	"models/weapons/eminem/ice_cube/ice_cube.vvd", 
	"models/weapons/eminem/ice_cube/ice_cube.dx90.vtx", 
	"models/weapons/eminem/ice_cube/ice_cube.mdl"
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
	"materials/models/player/custom_player/kodua/re/birkin/7_GF2Body002.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF2Claw.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF2hakui.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF2kami005.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF2LegArm.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF2LegArm001.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF2LegArm003.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF2LegArm002.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF2LegArm004.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF2Pants.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF2ShoulderEye.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF3Body.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF3Body_n.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF3Body_i.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF3Body001.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF3Body002.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF3Body003.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF3Body008.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF3Claw.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF3Claw.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF3Claw_n.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF3Claw001.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF3ShoulderEye.vmt", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF3ShoulderEye.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/7_GF3ShoulderEye_n.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_Body.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_Body_i.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_Body_n.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_Claw.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_Claw_n.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_hakui.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_hakui_n.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_kami.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_kami_n.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_LegArm.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_LegArm_i.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_LegArm_n.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_Pants.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_Pants_n.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_ShoulderEye.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/EGF2_ShoulderEye_n.vtf", 
	"materials/models/player/custom_player/kodua/re/birkin/gore.vmt", 
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
	"materials/models/weapons/ventoz/Abyss_Greatsword/painted_silver_ldr.vtf", 
	"materials/models/weapons/eminem/ice_cube/ice_cube.vtf", 
	"materials/models/weapons/eminem/ice_cube/ice_cube_normal.vtf", 
	"materials/models/weapons/eminem/ice_cube/ice_cube.vmt"
};

char NC_Sounds[][] = 
{
	"weapons/g3sg1/g3sg1_slideback.wav", 
	"weapons/c4/c4_beep1.wav", 
	"items/nvg_on.wav", 
	"items/healthshot_success_01.wav", 
	"weapons/c4/c4_disarm.wav", 
	"weapons/hegrenade/explode3.wav", 
	"weapons/hegrenade/explode4.wav", 
	"weapons/hegrenade/explode5.wav", 
	"nightcrawler/teleport.mp3", 
	"physics/glass/glass_impact_bullet4.wav", 
	"nightcrawler/freeze_cam.mp3", 
	"nightcrawler/suicide.mp3"
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
	g_Game = GetEngineVersion();
	if (g_Game != Engine_CSGO)
	{
		SetFailState("[NC] This plugin is for CS:GO only.");
	}
	
	CreateConVar("nc_version", PLUGIN_VERSION, "NightCrawlerGO by Simon", FCVAR_NOTIFY | FCVAR_PROTECTED);
	
	NC_Ratio = CreateConVar("nc_ratio", "3", "X:1 Ratio of players that are nightcrawlers where X is the number of Humans per 1 NightCrawler.", FCVAR_NOTIFY, true, 1.0);
	NC_VisibleDuration = CreateConVar("nc_visible_time", "3", "Duration for which NightCrawlers are visible upon taking damage.", FCVAR_NOTIFY, true, 0.0);
	NC_HumanMaxHealth = CreateConVar("nc_human_max_health", "150", "Max health of a Human.", FCVAR_NOTIFY, true, 0.0);
	NC_NightcrawlerHealth = CreateConVar("nc_health", "150", "Base health of a NightCrawler.", FCVAR_NOTIFY, true, 0.0);
	NC_NightcrawlerGravity = CreateConVar("nc_gravity", "0.3", "Base gravity of a NightCrawler.", FCVAR_NOTIFY, true, 0.0);
	NC_NightcrawlerSpeed = CreateConVar("nc_speed", "1.1", "Base speed of a NightCrawler.", FCVAR_NOTIFY, true, 0.0);
	NC_TeleportCount = CreateConVar("nc_teleport_count", "3", "Amount of starting teleports given to a NightCrawler.", FCVAR_NOTIFY, true, 0.0);
	NC_TeleportDelay = CreateConVar("nc_teleport_count", "2", "Minimum required delay between two consecutive teleports.", FCVAR_NOTIFY, true, 0.0);
	NC_Lighting = CreateConVar("nc_lighting", "k", "Level of lighting in the map. a = pitch black, z = bright like a star.", FCVAR_NOTIFY);
	NC_AdrenalineCount = CreateConVar("nc_adrenaline_uses", "3", "Amount of uses of Adrenaline Shot.", FCVAR_NOTIFY, true, 0.0);
	NC_AdrenalineDuration = CreateConVar("nc_adrenaline_time", "10", "Duration for which Adrenaline lasts.", FCVAR_NOTIFY, true, 0.0);
	NC_AdrenalineSpeed = CreateConVar("nc_adrenaline_speed", "1.4", "Speed during Adrenaline use.", FCVAR_NOTIFY, true, 0.0);
	NC_AdrenalineHealth = CreateConVar("nc_adrenaline_health", "100", "Amount of health given by Adrenaline.", FCVAR_NOTIFY, true, 0.0);
	NC_SuicideDamage = CreateConVar("nc_suicide_damage", "160", "Amount of damage done by Suicide Bomber.", FCVAR_NOTIFY, true, 0.0);
	NC_SuicideRadius = CreateConVar("nc_suicide_radius", "200", "Distance / Radius from the player in which damage can be taken.", FCVAR_NOTIFY, true, 0.0);
	NC_SuicideDelay = CreateConVar("nc_suicide_time", "2", "Delay before exploding.", FCVAR_NOTIFY, true, 0.0);
	NC_PoisonCount = CreateConVar("nc_poison_amount", "3", "Number of times a player is affected by poison.", FCVAR_NOTIFY, true, 0.0);
	NC_PoisonInterval = CreateConVar("nc_poison_interval", "1", "Interval between two consecutive poison hurts.", FCVAR_NOTIFY, true, 0.0);
	NC_PoisonMaxDamage = CreateConVar("nc_poison_damage", "5", "Maximum damage done by a poison hurt.", FCVAR_NOTIFY, true, 0.0);
	NC_TripMineCount = CreateConVar("nc_trip_mine_count", "3", "Amount of trip mines.", FCVAR_NOTIFY, true, 0.0);
	NC_TripMineBlast = CreateConVar("nc_trip_mine_mode", "1", "0 = Trip Laser, 1 = Trip Mine.", FCVAR_NOTIFY, true, 0.0);
	NC_FrostNadeCount = CreateConVar("nc_frost_nade_count", "3", "Amount of Frost Nades.", FCVAR_NOTIFY, true, 0.0);
	NC_FrostNadeRadius = CreateConVar("nc_frost_nade_radius", "400", "Distance / Radius from the grenade explosion in which NightCrawlers are frozen.", FCVAR_NOTIFY, true, 0.0);
	NC_FrostNadeDuration = CreateConVar("nc_frost_nade_time", "5", "Duration for which NightCrawlers are frozen.", FCVAR_NOTIFY, true, 0.0);
	NC_NapalmNadeCount = CreateConVar("nc_napalm_nade_count", "3", "Amount of Napalm Nades.", FCVAR_NOTIFY, true, 0.0);
	NC_NapalmNadeRadius = CreateConVar("nc_napalm_nade_radius", "400", "Distance / Radius from the grenade explosion in which NightCrawlers are burnt.", FCVAR_NOTIFY, true, 0.0);
	NC_NapalmNadeDuration = CreateConVar("nc_napalm_nade_time", "5", "Duration for which NightCrawlers are burnt.", FCVAR_NOTIFY, true, 0.0);
	NC_AmmoMode = CreateConVar("nc_ammo_mode", "1", "0 = Limited, 1 = Restock ammo on reload, 2 = Restock ammo only on kill.", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	
	NC_AdrenalineHealth.AddChangeHook(OnConVarChanged);
	
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_Pre);
	HookEvent("round_end", Event_OnRoundEnd);
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("player_hurt", Event_OnPlayerHurt);
	HookEvent("hegrenade_detonate", Event_OnHeDetonate);
	HookEvent("decoy_detonate", Event_OnDecoyDetonate);
	HookEvent("weapon_reload", Event_OnWeaponReload);
	HookEvent("weapon_fire", Event_OnWeaponFire);
	
	AddNormalSoundHook(OnNormalSoundPlayed);
	
	AddCommandListener(Command_LookAtWeapon, "+lookatweapon");
	AddCommandListener(Command_Kill, "kill");
	AddCommandListener(Command_Kill, "explode");
	AddCommandListener(Command_Join, "jointeam");
	
	SetHudTextParams(-1.0, 0.7, 3.0, 0, 255, 0, 255, 0, 0.0, 0.0, 0.0);
}

public void OnConVarChanged(ConVar convar, char[] oldValue, char[] newValue)
{
	if (StringToInt(newValue) != StringToInt(oldValue))
	{
		SetCvarInt("healthshot_health", StringToInt(newValue));
	}
}

public void OnMapStart()
{
	MapSettings();
	
	for (int i = 0; i < sizeof(NC_Models); i++)
	{
		AddFileToDownloadsTable(NC_Models[i]);
		if (StrEqual(NC_Models[i], "models/player/custom_player/xlegend/birkin/birkin_arms.mdl", true))
			NC_KnifeModel = PrecacheModel("models/player/custom_player/xlegend/birkin/birkin_arms.mdl");
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
		if (buttons & IN_USE)
		{
			bool IsNearWall = false;
			bool IsNearCeiling = false;
			
			Handle traceRay;
			float testVector[3];
			float testPosition[3];
			float testEndPosition[3];
			GetClientAbsOrigin(client, testPosition);
			testPosition[2] += 20.0;
			for (int i = 0; i < 360; i += 30)
			{
				testVector[1] = float(i);
				traceRay = TR_TraceRayFilterEx(testPosition, testVector, MASK_SOLID, RayType_Infinite, TRDontHitSelf, client);
				if (TR_DidHit(traceRay))
				{
					TR_GetEndPosition(testEndPosition, traceRay);
					
					if (GetVectorDistance(testEndPosition, testPosition) <= 25.0)
					{
						IsNearWall = true;
						SetEntityGravity(client, 0.5 * GetEntityGravity(client));
						CloseHandle(traceRay);
						break;
					}
				}
				CloseHandle(traceRay);
				
			}
			if (!IsNearWall)
			{
				GetClientEyePosition(client, testPosition);
				testVector = testPosition;
				testVector[2] += 25.0;
				traceRay = TR_TraceRayFilterEx(testPosition, testVector, MASK_SOLID, RayType_EndPoint, TRDontHitSelf, client);
				if (TR_DidHit(traceRay))
				{
					IsNearCeiling = true;
				}
				CloseHandle(traceRay);
			}
			
			if (!IsNearWall && !IsNearCeiling)
			{
				return;
			}
			if (IsNearWall || IsNearCeiling)
			{
				float velocity[3];
				float eyeAngles[3];
				SetEntityMoveType(client, MOVETYPE_WALK);
				GetClientEyeAngles(client, eyeAngles);
				bool noTranslationMade = true;
				if (buttons & IN_FORWARD)
				{
					velocity[0] += (300.0 * Cosine(DegToRad(eyeAngles[1])));
					velocity[1] += (300.0 * Sine(DegToRad(eyeAngles[1])));
					velocity[2] += -(300.0 * Sine(DegToRad(eyeAngles[0])));
					noTranslationMade = false;
				}
				else if (buttons & IN_BACK)
				{
					velocity[0] += -(200.0 * Cosine(DegToRad(eyeAngles[1])));
					velocity[1] += -(200.0 * Sine(DegToRad(eyeAngles[1])));
					velocity[2] += (200.0 * Sine(DegToRad(eyeAngles[0])));
					noTranslationMade = false;
				}
				if (buttons & IN_MOVERIGHT)
				{
					velocity[0] += (200.0 * Cosine(DegToRad(eyeAngles[1] - 90.0)));
					velocity[1] += (200.0 * Sine(DegToRad(eyeAngles[1] - 90.0)));
					noTranslationMade = false;
				}
				else if (buttons & IN_MOVELEFT)
				{
					velocity[0] += (200.0 * Cosine(DegToRad(eyeAngles[1] + 90)));
					velocity[1] += (200.0 * Sine(DegToRad(eyeAngles[1] + 90)));
					noTranslationMade = false;
				}
				if (noTranslationMade)
				{
					SetEntityMoveType(client, MOVETYPE_NONE);
					velocity[0] = velocity[1] = velocity[2] = 0.0;
				}
				SetEntityGravity(client, 1.5e-45);
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
			}
			else
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
				SetEntityGravity(client, NC_NightcrawlerGravity.FloatValue);
			}
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
		SDKHook(entity, SDKHook_SpawnPost, EventSDK_OnHEGrenadeSpawn);
	}
	else if (!strcmp(classname, "decoy_projectile"))
	{
		BeamFollowCreate(entity, FreezeColor);
		CreateTimer(1.3, CreateEvent_DecoyDetonate, entity, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (StrContains(classname, "weapon_", false) != -1)
	{
		SDKHookEx(entity, SDKHook_SpawnPost, EventSDK_OnWeaponSpawnPost);
	}
}

public Action Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	
	CPrintToChatAll("%s {default}Ready or not here they come!", NC_Tag);
	LoopAllClients(client)
	{
		ResetItems(client);
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
		LastTele[client] = GetGameTime();
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
	{
		NC_NextRound[attacker] = true;
		if (NC_AmmoMode.IntValue == 2)
		{
			int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
			if (weapon != -1 && IsValidEdict(weapon))
			{
				int clip = 0;
				if (GetMaxClip1(weapon, clip))
				{
					SetEntProp(weapon, Prop_Send, "m_iClip1", clip);
				}
			}
		}
	}
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
			IgniteEntity(client, NC_NapalmNadeDuration.FloatValue);
		}
	}
	return Plugin_Continue;
}

public Action Event_OnHeDetonate(Event event, const char[] name, bool dontBroadcast)
{
	float origin[3];
	origin[0] = event.GetFloat("x");
	origin[1] = event.GetFloat("y");
	origin[2] = event.GetFloat("z");
	
	TE_SetupBeamRingPoint(origin, 10.0, 400.0, NC_GrenadeBeamSprite2, NC_GrenadeHaloSprite, 1, 1, 0.2, 100.0, 1.0, HEColor, 0, 0);
	TE_SendToAll();
}

public Action Event_OnDecoyDetonate(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	float origin[3];
	origin[0] = event.GetFloat("x");
	origin[1] = event.GetFloat("y");
	origin[2] = event.GetFloat("z");
	
	int index = MaxClients + 1;
	
	float xyz[3];
	
	while ((index = FindEntityByClassname(index, "decoy_projectile")) != -1)
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
		if (GetVectorDistance(origin, targetOrigin) <= NC_FrostNadeRadius.FloatValue)
		{
			Handle trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
			
			if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0))
			{
				Freeze(i, client, NC_FrostNadeDuration.FloatValue);
				CloseHandle(trace);
			}
			
			else
			{
				CloseHandle(trace);
				
				GetClientEyePosition(i, targetOrigin);
				targetOrigin[2] -= 2.0;
				
				trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
				
				if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= NC_FrostNadeRadius.FloatValue - 100.0))
				{
					Freeze(i, client, NC_FrostNadeDuration.FloatValue);
				}
				
				CloseHandle(trace);
			}
		}
	}
	
	TE_SetupBeamRingPoint(origin, 10.0, 200.0, NC_GrenadeBeamSprite2, NC_GrenadeHaloSprite, 1, 1, 0.2, 100.0, 1.0, FreezeColor, 0, 0);
	TE_SendToAll();
	LightCreate(origin);
}

public Action Event_OnWeaponReload(Event event, const char[] name, bool dontBroadcast)
{
	if (NC_AmmoMode.IntValue == 1)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		if (!client || !IsClientInGame(client))
		{
			return;
		}
		
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if (weapon != -1 && IsValidEdict(weapon))
		{
			GivePlayerAmmo(client, 9999, GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType"), true);
		}
	}
}

public Action Event_OnWeaponFire(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	char weapon[32];
	event.GetString("weapon", weapon, sizeof(weapon));
	if ((StrEqual(weapon, "weapon_healthshot", false) || StrEqual(weapon, "healthshot", false)))
	{
		if (NC_IsAdrenaline[client])
		{
			int weaponindex = GetPlayerWeaponSlot(client, CS_SLOT_C4);
			if (weaponindex != -1)
			{
				RemovePlayerItem(client, weaponindex);
				RemoveEdict(weaponindex);
				ClientCommand(client, "slot1");
			}
			return Plugin_Stop;
		}
		else if (GetClientHealth(client) == NC_HumanMaxHealth.IntValue)
		{
			return Plugin_Stop;
		}
		else
		{
			SetEntProp(client, Prop_Send, "m_iDefaultFOV", 110);
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", NC_AdrenalineSpeed.FloatValue);
			SetEntityHealth(client, (GetClientHealth(client) + NC_AdrenalineHealth.IntValue) > NC_HumanMaxHealth.IntValue ? NC_HumanMaxHealth.IntValue : (GetClientHealth(client) + NC_AdrenalineHealth.IntValue));
			--NC_Adrenaline[client];
			NC_IsAdrenaline[client] = true;
			EmitSoundToClientAny(client, "items/healthshot_success_01.wav");
			CreateTimer(NC_AdrenalineDuration.FloatValue, AdrenalineRush, client);
		}
	}
	return Plugin_Continue;
}

public Action EventSDK_OnClientThink(int client)
{
	if (IsValidClient(client))
	{
		if (IsPlayerAlive(client))
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityGravity(client, NC_NightcrawlerGravity.FloatValue);
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", NC_NightcrawlerSpeed.FloatValue);
			}
			if (GetClientTeam(client) == CS_TEAM_CT && NC_IsAdrenaline[client])
			{
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", NC_AdrenalineSpeed.FloatValue);
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if (weapon != -1)
					SetEntProp(weapon, Prop_Send, "m_iClip1", 1);
			}
			if (GetClientTeam(client) == CS_TEAM_CT && !NC_IsAdrenaline[client] && !IsFakeClient(client))
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
				else return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}

public Action EventSDK_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (IsValidClient(attacker) && IsValidClient(victim) && GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_CT && !NC_IsFrozen[victim])
	{
		if (!NC_IsVisible[victim]) {
			NC_iTime[victim] = NC_VisibleDuration.FloatValue;
			SDKUnhook(victim, SDKHook_SetTransmit, Hook_SetTransmit);
			NC_IsVisible[victim] = true;
			NC_iTimer[victim] = CreateTimer(1.0, ResetVisibility, victim, TIMER_REPEAT);
		}
		else
		{
			NC_iTime[victim] = NC_VisibleDuration.FloatValue + 1.0;
		}
		
		if (!IsPlayerAlive(victim))
			return Plugin_Continue;
		char CurrentWeapon[64];
		GetClientWeapon(attacker, CurrentWeapon, sizeof(CurrentWeapon));
		if (strcmp(CurrentWeapon, "weapon_ssg08", false) == 0 && GetClientTeam(victim) == CS_TEAM_T)
		{
			NC_PoisonCounter[victim] = NC_PoisonCount.IntValue;
			CreateTimer(NC_PoisonInterval.FloatValue, PoisonPlayer, victim, TIMER_REPEAT);
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

public Action EventSDK_OnHEGrenadeSpawn(int entity)
{
	CreateTimer(0.01, ChangeGrenadeRadius, entity, TIMER_FLAG_NO_MAPCHANGE);
}

public Action EventSDK_OnWeaponSpawnPost(int entity)
{
	GetMaxClip1(entity, _, true);
}

public Action Command_LookAtWeapon(int client, const char[] command, int argc)
{
	if (GetClientTeam(client) == CS_TEAM_T && NC_TeleCount[client] > 0 && !NC_IsFrozen[client] && GetGameTime() - LastTele[client] > NC_TeleportDelay.IntValue)
	{
		SetTeleportEndPoint(client);
		return Plugin_Handled;
	}
	
	else if (GetClientTeam(client) == CS_TEAM_CT)
	{
		if (NC_TripMine[client] > 0)
		{
			DoMine(client);
		}
		else if (NC_Suicide[client])
		{
			float pos[3];
			GetClientAbsOrigin(client, pos);
			
			CreateTimer(NC_SuicideDelay.FloatValue, CreateDelayedSuicide, client);
			
			EmitSoundToAllAny("nightcrawler/suicide.mp3", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
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
	
	if ((OldTeam == CS_TEAM_T || OldTeam == CS_TEAM_CT) && NewTeam != CS_TEAM_SPECTATOR)
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
		NC_IsFrozen[client] = false;
	}
}

public Action UnfreezeModel(Handle timer, any data)
{
	int ent = EntRefToEntIndex(data);
	if (ent > 0)
		AcceptEntityInput(ent, "Kill");
}

public Action CreateEvent_DecoyDetonate(Handle timer, any entity)
{
	if (!IsValidEdict(entity))
	{
		return Plugin_Stop;
	}
	
	char classname[64];
	GetEdictClassname(entity, classname, sizeof(classname));
	if (!strcmp(classname, "decoy_projectile", false))
	{
		float origin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
		int userid = GetClientUserId(GetEntPropEnt(entity, Prop_Send, "m_hThrower"));
		
		Handle event = CreateEvent("decoy_detonate");
		
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
	CPrintToChat(client, "%s {default}Welcome to the world of {red}NightCrawlers {default}({green}%s {default}by {green}%s{default})", NC_Tag, PLUGIN_VERSION, PLUGIN_AUTHOR);
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
	if (NC_Adrenaline[client] != 0)
	{
		int weaponindex = GetPlayerWeaponSlot(client, CS_SLOT_C4);
		if (weaponindex != -1)
		{
			RemovePlayerItem(client, weaponindex);
			RemoveEdict(weaponindex);
		}
		GivePlayerItem(client, "weapon_healthshot");
	}
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
		int SlapMax = NC_PoisonMaxDamage.IntValue;
		if (SlapMax >= life)
			SlapPlayer(client, GetRandomInt(0, life - 1), true);
		else SlapPlayer(client, GetRandomInt(0, SlapMax), true);
	}
	
	--NC_PoisonCounter[client];
	
	if (NC_PoisonCounter[client] <= 0)
	{
		NC_PoisonCounter[client] = 0;
		return Plugin_Stop;
	}
	return Plugin_Handled;
}

public void DoMine(int client)
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

public Action ChangeGrenadeRadius(Handle timer, int ent)
{
	SetEntPropFloat(ent, Prop_Send, "m_DmgRadius", NC_NapalmNadeRadius.FloatValue);
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
	
	for (int i = 0; i < 3; i++)
	{
		position[i] += normal2[i] * 0.5;
	}
	TeleportEntity(ent, position, angles, NULL_VECTOR);
	
	TR_TraceRayFilter(position, angles, CONTENTS_SOLID, RayType_Infinite, TraceFilter_All, 0);
	
	float beamend[3];
	TR_GetEndPosition(beamend, INVALID_HANDLE);
	
	int ent_laser = CreateLaser(beamend, position, beam_name, GetClientTeam(client));
	PrintToChatAll("%i %i", client, ent_laser);
	
	HookSingleEntityOutput(ent_laser, "OnTouchedByEntity", MineLaser_OnTouch);
	SetEntPropEnt(ent_laser, Prop_Data, "m_hOwnerEntity", client);
	
	DataPack data = new DataPack();
	data.Reset();
	CreateDataTimer(1.0, ActivateTimer, data, TIMER_REPEAT);
	data.WriteCell(0);
	data.WriteCell(ent);
	data.WriteCell(ent_laser);
	
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
		if (GetClientTeam(activator) == CS_TEAM_T && NC_TripMineBlast.IntValue == 0)
		{
			DispatchKeyValue(caller, "rendercolor", "255 0 0");
		}
		else if (GetClientTeam(activator) == CS_TEAM_T && NC_TripMineBlast.IntValue == 1)
		{
			DispatchKeyValue(caller, "rendercolor", "255 0 0");
			detonate = true;
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
		SetEntPropFloat(ent, Prop_Data, "m_fWidth", 1.5);
		SetEntPropFloat(ent, Prop_Data, "m_fEndWidth", 1.5);
		ActivateEntity(ent);
		AcceptEntityInput(ent, "TurnOn");
	}
	return ent;
}

public Action ActivateTimer(Handle timer, DataPack data)
{
	/// IF YOU'RE USING 1.10 SOURCEMOD THEN UNCOMMENT THE BELOW CODE ///
	data.Reset();
	//int ent;
	//int ent_laser;
	int counter = data.ReadCell();
	int ent = data.ReadCell();
	int ent_laser = data.ReadCell();
	/*if (counter == 0)
	{
		ent = data.ReadCell();
		ent_laser = data.ReadCell();
	}
	else if (counter == 1)
	{
		data.ReadCell();
		ent = data.ReadCell();
		ent_laser = data.ReadCell();
	}
	else if (counter == 2)
	{
		data.ReadCell();
		data.ReadCell();
		ent = data.ReadCell();
		ent_laser = data.ReadCell();
	}
	else
	{
		data.ReadCell();
		data.ReadCell();
		data.ReadCell();
		ent = data.ReadCell();
		ent_laser = data.ReadCell();
	}*/
	
	if (!IsValidEntity(ent))
	{
		return Plugin_Stop;
	}
	
	if (counter < 3)
	{
		PlayMineSound(ent, "weapons/c4/c4_beep1.wav");
		counter++;
		ResetPack(data, false);
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
	DataPack data = new DataPack();
	CreateDataTimer(0.1, CreateExplosionDelayedTimer, data);
	
	data.WriteCell(owner);
	data.WriteFloat(vec[0]);
	data.WriteFloat(vec[1]);
	data.WriteFloat(vec[2]);
}

public Action CreateExplosionDelayedTimer(Handle timer, DataPack data)
{
	data.Reset();
	int owner = data.ReadCell();
	
	float vec[3];
	vec[0] = data.ReadFloat();
	vec[1] = data.ReadFloat();
	vec[2] = data.ReadFloat();
	
	CreateExplosion(vec, owner);
	
	return Plugin_Handled;
}

public Action CreateDelayedSuicide(Handle timer, int owner)
{
	float pos[3];
	GetClientAbsOrigin(owner, pos);
	
	if (IsPlayerAlive(owner))
	{
		CreateExplosion(pos, owner);
		ForcePlayerSuicide(owner);
	}
}

public void CreateExplosion(float vec[3], int owner)
{
	int ent = CreateEntityByName("env_explosion");
	DispatchKeyValue(ent, "classname", "env_explosion");
	SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", owner);
	SetEntProp(ent, Prop_Data, "m_iMagnitude", NC_SuicideDamage.IntValue);
	SetEntProp(ent, Prop_Data, "m_iRadiusOverride", NC_SuicideRadius.IntValue);
	SetEntProp(ent, Prop_Send, "m_iTeamNum", CS_TEAM_CT);
	
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
			if (GetRandomInt(0, 1) == 0)
				SetEntityModel(client, "models/player/custom_player/kodua/re/birkin/birkin3_f.mdl");
			else SetEntityModel(client, "models/player/custom_player/kodua/re/birkin/birkin2.mdl");
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
		}
		else if (GetClientTeam(client) == CS_TEAM_CT)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_knife");
			FPVMI_RemoveWorldModelToClient(client, "weapon_knife");
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
	NC_PoisonCounter[client] = 0;
	NC_TopPlayer[client] = false;
	NC_IsFrozen[client] = false;
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
	SetEntProp(client, Prop_Data, "m_iMaxHealth", NC_HumanMaxHealth.IntValue);
	StoreToAddress(GetEntityAddress(client) + NC_SpotRadar, 9, NumberType_Int32);
	if (!IsFakeClient(client))
	{
		SendConVarValue(client, FindConVar("sv_footsteps"), "1");
	}
	WeaponMenu(client);
}

public void NCSettings(int client)
{
	NC_TeleCount[client] = NC_TeleportCount.IntValue;
	SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	StripWeapons(client);
	SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", NC_NightcrawlerSpeed.FloatValue);
	SetEntityGravity(client, NC_NightcrawlerGravity.FloatValue);
	SetEntityHealth(client, NC_NightcrawlerHealth.IntValue);
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
		SendConVarValue(client, FindConVar("sv_footsteps"), "0");
	}
}

public void WeaponMenu(int client)
{
	Menu menu = new Menu(MenuHandler1);
	SetMenuExitButton(menu, false);
	SetMenuPagination(menu, MENU_NO_PAGINATION);
	menu.SetTitle("[NC] Weapon Shop");
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
	menu.SetTitle("[NC] Item Shop");
	char buffer[64];
	if (NC_TopPlayer[client])
		menu.AddItem("1", "Laser Sight");
	else
		menu.AddItem("1", "Laser Sight", ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "Trip %s (x%i)", NC_TripMineBlast.IntValue == 1 ? "Mine" : "Laser", NC_TripMineCount.IntValue);
	menu.AddItem("2", buffer);
	Format(buffer, sizeof(buffer), "Frost Grenade (x%i)", NC_FrostNadeCount.IntValue);
	menu.AddItem("3", buffer);
	Format(buffer, sizeof(buffer), "Napalm Grenade (x%i)", NC_NapalmNadeCount.IntValue);
	menu.AddItem("4", buffer);
	menu.AddItem("5", "Poison Scout");
	menu.AddItem("6", "Suicide Bomber");
	Format(buffer, sizeof(buffer), "Adrenaline Shot (x%i)", NC_AdrenalineCount.IntValue);
	menu.AddItem("7", buffer);
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
				CPrintToChat(client, "%s {default}Got {green}Laser Sight{default}! Turns {red}Red{default} upon aiming at NightCrawlers.", NC_Tag);
			}
			case 1:
			{
				NC_TripMine[client] = NC_TripMineCount.IntValue;
				CPrintToChat(client, "%s {default}Got {green}%ix Trip %s{default}! Set up a trap for the NightCrawlers.", NC_Tag, NC_TripMineCount.IntValue, NC_TripMineBlast.IntValue == 1 ? "Mine" : "Laser");
				CPrintToChat(client, "%s {default}Press {green}F{default} to deploy your item.", NC_Tag);
				//ShowHudText(target, -1, "Press F to deploy your item.", NC_Tag);
			}
			case 2:
			{
				CPrintToChat(client, "%s {default}Got {green}%ix Frost Grenade{default}! Freezes NightCrawlers upon contact for some time.", NC_Tag, NC_FrostNadeCount.IntValue);
				for (int i = 0; i < NC_FrostNadeCount.IntValue; i++)
				{
					GivePlayerItem(client, "weapon_decoy");
				}
			}
			case 3:
			{
				CPrintToChat(client, "%s {default}Got {green}%ix Napalm Grenade{default}! Burns NightCrawlers upon contact for some time.", NC_Tag, NC_NapalmNadeCount.IntValue);
				for (int i = 0; i < NC_NapalmNadeCount.IntValue; i++)
				{
					GivePlayerItem(client, "weapon_hegrenade");
				}
			}
			case 4:
			{
				NC_Scout[client] = true;
				CPrintToChat(client, "%s {default}Got a {green}Scout{default} with {green}Poisonous Bullets{default}! Hear the cries of the NightCrawlers affected.", NC_Tag);
				StripWeapons(client);
				GivePlayerItem(client, "weapon_ssg08");
				GivePlayerItem(client, "weapon_cz75a");
			}
			case 5:
			{
				NC_Suicide[client] = true;
				CPrintToChat(client, "%s {default}You are now a {green}Suicide Bomber{default}! Take NightCrawlers down with you.", NC_Tag);
				CPrintToChat(client, "%s {default}Press {green}F{default} to use your item.", NC_Tag);
			}
			case 6:
			{
				NC_Adrenaline[client] = NC_AdrenalineCount.IntValue;
				CPrintToChat(client, "%s {default}Got {green}%ix Adrenaline Shots{default}! Get unlimited ammo, increased health and run faster.", NC_Tag, NC_AdrenalineCount.IntValue);
				GivePlayerItem(client, "weapon_healthshot");
			}
		}
	}
}

public int MenuHandler1(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		StripWeapons(param1);
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
	char buffer[2];
	NC_Lighting.GetString(buffer, sizeof(buffer));
	SetLightStyle(0, buffer);
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
	SetCvarInt("ammo_grenade_limit_default", 3);
	SetCvarInt("mp_weapons_allow_map_placed", 0);
	SetCvarInt("mp_default_team_winner_no_objective", 3);
	SetCvarInt("weapon_auto_cleanup_time", 5);
	SetCvarInt("mp_death_drop_gun", 0);
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
	
	vec[2] -= 10.0;
	int ent;
	if ((ent = CreateEntityByName("prop_dynamic")) != -1)
	{
		DispatchKeyValue(ent, "model", "models/weapons/eminem/ice_cube/ice_cube.mdl");
		DispatchKeyValue(ent, "solid", "0");
		DispatchKeyValueVector(ent, "origin", vec);
		DispatchSpawn(ent);
		
		ent = EntRefToEntIndex(ent);
		CreateTimer(time, UnfreezeModel, ent, TIMER_FLAG_NO_MAPCHANGE);
	}
	NC_IsFrozen[client] = true;
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
	iCTsToMove = RoundToFloor(float(players) / NC_Ratio.FloatValue);
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
	LastTele[target] = GetGameTime();
	ShowHudText(target, -1, "Teleports Remaining: %i", NC_TeleCount[target]);
}

public void SetTeleportEndPoint(int client)
{
	float vAngles[3];
	float vOrigin[3];
	float vBuffer[3];
	float vStart[3];
	
	bool failed = false;
	int loopLimit = 100;
	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(vBuffer, vBuffer);
	ScaleVector(vBuffer, 10.0);
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(vStart, trace);
		while (IsClientStuck(vStart, client) && !failed)
		{
			SubtractVectors(vStart, vBuffer, vStart);
			if (GetVectorDistance(vOrigin, vStart, false) < 10 || loopLimit-- < 1)
			{
				failed = true;
				vStart = vOrigin;
			}
		}
	}
	CloseHandle(trace);
	if (!failed)
		PerformTeleport(client, vStart);
	else CPrintToChat(client, "%s {default}Couldn\'t find proper place to teleport. Please try again at a different location.", NC_Tag);
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return entity > GetMaxClients() || entity <= 0 || !entity;
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

stock bool IsClientStuck(float pos[3], int client)
{
	float mins[3];
	float maxs[3];
	
	GetClientMins(client, mins);
	GetClientMaxs(client, maxs);
	
	for (new i = 0; i < sizeof(mins); i++)
	{
		mins[i] -= 3;
		maxs[i] += 3;
	}
	
	TR_TraceHullFilter(pos, pos, mins, maxs, MASK_SOLID, TraceEntityFilterPlayer, client);
	
	return TR_DidHit();
}

stock bool GetMaxClip1(int entity, int &clip = -1, bool store = false)
{
	clip = -1;
	
	static Handle trie_ammo = INVALID_HANDLE;
	
	if (trie_ammo == INVALID_HANDLE)trie_ammo = CreateTrie();
	
	if (entity <= MaxClients || !IsValidEntity(entity) || !HasEntProp(entity, Prop_Send, "m_iClip1"))return false;
	
	char clsname[30];
	if (!GetEntityClassname(entity, clsname, sizeof(clsname)))return false;
	
	if (store)
	{
		SetTrieValue(trie_ammo, clsname, GetEntProp(entity, Prop_Send, "m_iClip1"));
		return true;
	}
	
	if (!GetTrieValue(trie_ammo, clsname, clip))return false;
	
	return true;
}
/*   Fin.   */