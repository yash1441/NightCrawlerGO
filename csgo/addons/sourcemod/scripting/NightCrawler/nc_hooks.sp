public void EventSDK_OnClientThink(int client)
{
	if(IsValidClient(client))
	{
		if(IsPlayerAlive(client))
		{
			if(GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityGravity(client, 0.1);
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.1);
			}
		}
	}
}

public Action EventSDK_OnWeaponCanUse(int client, int weapon)
{
	if(IsValidClient(client, true))
	{
		if(GetClientTeam(client) == CS_TEAM_T)
		{
			if(IsValidEntity(weapon))
			{
				char s_weapon[128];
				GetEntityClassname(weapon, s_weapon, sizeof(s_weapon));
				if(StrEqual(s_weapon, "weapon_knife"))
				{
					return Plugin_Continue;
				}
				else if(StrEqual(s_weapon, "weapon_healthshot"))
				{
					return Plugin_Continue;
				}
				else return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}

public Action EventSDK_SetTransmit(int entity, int client)
{
	if(IsValidClient(entity, true))
	{
		if (client != entity /*&& b_IsClientInvisible[entity]*/)
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action EventSDK_OnTakeDamage(int victim,int &attacker,int &inflictor, float &damage,int &damagetype,int &weapon, float damageForce[3], float damagePosition[3])
{
	if(IsValidClient(victim))
	{
		if(IsValidClient(attacker))
		{
			if(GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_CT)
			{
				if(NC_VisibleTimer[victim])
				{
					TriggerTimer(NC_VisibleTimer[victim], true);
					SetEntityRenderMode(victim, RENDER_TRANSCOLOR);
				}
				else
				{
					SetEntityRenderMode(victim, RENDER_TRANSCOLOR);
					NC_VisibleTimer[victim] = CreateTimer(3.0, MakeInvisibleAgain, victim);
				}
			}
			else if(GetClientTeam(attacker) == CS_TEAM_T && GetClientTeam(victim) == CS_TEAM_CT)
			{
				++NC_TeleCount[attacker];
			}
		}
	}
	return Plugin_Continue;
}