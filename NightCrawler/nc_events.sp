public Action Event_OnRoundPreStart(Event event, const char[] name, bool dontBroadcast)
{
	//Put people in teams according to ratio using GetRandomPlayer(team)
	CS_SwitchTeam(GetRandomPlayer(CS_TEAM_CT), CS_TEAM_T);
	LoopClients(i)
	{
		NC_TeleCount[i] = 0;
	}
	return Plugin_Continue;
}

public Action Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	//Put all in Spec
	LoopClients(i)
	{
		CS_SwitchTeam(i, CS_TEAM_CT);
	}
	return Plugin_Continue;
}

public Action Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	//Give magic powers
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(IsValidClient(client, true))
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client);
		StripWeapons(client);
		if(GetClientTeam(client) == CS_TEAM_CT)
		{
			//CreateTimer(0.2, Timer_CTSpawnPost, client);
			//CreateTimer(1.0, Timer_CTRefillAmmo, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			GivePlayerItem(client, "weapon_flashbang");
			SetEntityGravity(client, 1.0);
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
		else if(GetClientTeam(client) == CS_TEAM_T)
		{
			NC_TeleCount[client] = 3;
			SetEntityRenderMode(client, RENDER_NONE);
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
}