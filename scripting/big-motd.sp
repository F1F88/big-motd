#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_NAME                         "big-motd"
#define PLUGIN_DESCRIPTION                  "Crack the MOTD size limit"
#define PLUGIN_VERSION                      "v2.0.1"

public Plugin myinfo =
{
    name        = PLUGIN_NAME,
    author      = "F1F88",
    description = PLUGIN_DESCRIPTION,
    version     = PLUGIN_VERSION,
    url         = "https://github.com/F1F88/big-motd"
//  reference   = "https://github.com/dysphie/sm-vphysics-mayhem-fix"
};


#define JLZ     0x7E
#define JMP     0xEB


Address addr;

public void OnPluginStart()
{
    GameData gamedata = new GameData("big-motd.games");
    if (!gamedata)
    {
        SetFailState("Failed to read gamedata/big-motd.games.txt");
    }

    addr = gamedata.GetAddress("CServerGameDLL::LoadSpecificMOTDMsg");
    if (!addr)
    {
        SetFailState("Failed to get address to CServerGameDLL::LoadSpecificMOTDMsg");
    }

    delete gamedata;

    int val = LoadFromAddress(addr, NumberType_Int8);
    if (val != JLZ)
    {
        SetFailState("Failed to verify byte (expected %x, got %x)", JLZ, val);
    }

    StoreToAddress(addr, JMP, NumberType_Int8);

    CreateConVar("sm_big_motd_version", PLUGIN_VERSION, PLUGIN_DESCRIPTION, FCVAR_SPONLY | FCVAR_DONTRECORD);

    PrintToServer("[Big MOTD] Cracking big MOTD successfully");
}

public void OnPluginEnd()
{
    PrintToServer("[Big MOTD] Restore cracked big MOTD due to unload plugin");

    StoreToAddress(addr, JLZ, NumberType_Int8);
}
