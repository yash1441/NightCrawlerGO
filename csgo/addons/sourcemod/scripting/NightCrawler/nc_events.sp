public Action Event_OnRoundPreStart(Event event, const char[] name, bool dontBroadcast)
{
	int TotalPlayers = CountPlayersInTeam(CS_TEAM_CT);
	int NC_Needed = (TotalPlayers / 3);
	LoopClients(i)
	{
		NC_TeleCount[i] = 0;
		if(NC_NextRound[i])
		{
			CS_SwitchTeam(i, CS_TEAM_T);
		}
		NC_NextRound[i] = false;
	}
	while(CountPlayersInTeam(CS_TEAM_T) <= NC_Needed)
		CS_SwitchTeam(GetRandomPlayer(CS_TEAM_CT), CS_TEAM_T);
	return Plugin_Continue;
}

public Action Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	LoopClients(i)
	{
		CS_SwitchTeam(i, CS_TEAM_CT);
	}
	return Plugin_Continue;
}

public Action Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(IsValidClient(client, true))
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client);
		StripWeapons(client);
		if(GetClientTeam(client) == CS_TEAM_CT)
		{
			GivePlayerItem(client, "weapon_flashbang");
			SetEntityGravity(client, 1.0);
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
		else if(GetClientTeam(client) == CS_TEAM_T)
		{
			NC_TeleCount[client] = 3;
			SetEntityModel(client, "models/player/custom_player/kuristaja/vader/vader.mdl");
			SetEntityRenderMode(client, RENDER_NONE);
			SetEntityGravity(client, 0.5);
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.2);
			SetEntProp(client, Prop_Send, "m_ArmorValue", 0);
			SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
		}
	}
	return Plugin_Continue;
}

public Action Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if(GetClientTeam(attacker) == CS_TEAM_T && GetClientTeam(victim) == CS_TEAM_CT)
		++NC_TeleCount[attacker];
	if(GetClientTeam(attacker) == CS_TEAM_CT && GetClientTeam(victim) == CS_TEAM_T)
		NC_NextRound[attacker] = true;
}