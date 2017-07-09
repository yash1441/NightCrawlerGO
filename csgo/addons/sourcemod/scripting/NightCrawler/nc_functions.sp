public void PerformTeleport(target, float pos[3])
{
	float partpos[3];
	
	GetClientEyePosition(target, partpos);
	partpos[2]-=20.0;	
	
	TeleportEntity(target, pos, NULL_VECTOR, NULL_VECTOR);
	pos[2]+=40.0;
	--NC_TeleCount[target];
}

public void SetTeleportEndPoint(client)
{
	float vAngles[3];
	float vOrigin[3];
	float vBuffer[3];
	float vStart[3];
	float Distance;
	float g_pos[3];
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
    	
	if(TR_DidHit(trace))
	{   	 
   	 	TR_GetEndPosition(vStart, trace);
		GetVectorDistance(vOrigin, vStart, false);
		Distance = -35.0;
   	 	GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		g_pos[0] = vStart[0] + (vBuffer[0]*Distance);
		g_pos[1] = vStart[1] + (vBuffer[1]*Distance);
		g_pos[2] = vStart[2] + (vBuffer[2]*Distance);
	}
	CloseHandle(trace);
	PerformTeleport(client, g_pos);
}

public bool TraceEntityFilterPlayer(entity, contentsMask)
{
	return entity > GetMaxClients() || !entity;
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

/*public void DownloadModels(int client)
{
	for(int i; i < sizeof(s_FurienModelList); i++)
	{
		AddFileToDownloadsTable(s_FurienModelList[i]);
	}
	for(int i; i < sizeof(s_AntiFurienModelList); i++)
	{
		AddFileToDownloadsTable(s_AntiFurienModelList[i]);
	}
}*/

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
		if(team != 0)
		{
			if(GetClientTeam(i) == team)
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
		if(team != 0)
		{
			if(GetClientTeam(i) == team)
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

stock GetRandomPlayer(team)
{
    int clients[MAXPLAYERS + 1];
    int clientCount;
    for (int i = 1; i <= MAXPLAYERS; i++)
        if (IsValidClient(i) && (GetClientTeam(i) == team))
            clients[clientCount++] = i;
    return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}  

public Action MakeInvisibleAgain(Handle timer, client)
{
	SetEntityRenderMode(client, RENDER_NONE);
}

NCArms(client)
{
	if(!IsPlayerAlive(client)) return;
	if(GetClientTeam(client) == CS_TEAM_CT)
		ArmsFix_SetDefaults(client)
	else if (GetClientTeam(client) == CS_TEAM_T)
		SetEntPropString(client, Prop_Send, "m_szArmsModel", "models/player/custom_player/kuristaja/vader/vader_arms.mdl");
}