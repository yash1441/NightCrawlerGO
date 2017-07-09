public Action Command_BlockRadio(int client, const char[] command,int  args)
{
	return Plugin_Handled;
}

public Action Command_Kill(int client, const char[] command,int  args)
{
	return Plugin_Handled;
}

/*public Action Command_NC(int client, int args)
{
	if(IsValidClient(client))
	{
		if(GetClientTeam(client) != CS_TEAM_SPECTATOR)
		{
			Menu_NCMain(client);
		}
	}
}*/

public Action Command_LookAtWeapon(int client, const char[] command, int argc)
{
	if(GetClientTeam(client) != CS_TEAM_T || !NC_TeleCount[client])
	{
		return Plugin_Continue;	
	}
	
	SetTeleportEndPoint(client);
	
	
	return Plugin_Handled;
}

public Action Command_Join(client, const char[] command, argc)
{
	return Plugin_Handled;
}