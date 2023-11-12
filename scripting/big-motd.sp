#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required


#define PLUGIN_NAME                         "big-motd"
#define PLUGIN_DESCRIPTION                  "When motd is text only, more characters are allowed to display"
#define PLUGIN_VERSION                      "v1.0.1"


public Plugin myinfo =
{
    name        = PLUGIN_NAME,
    author      = "F1F88",
    description = PLUGIN_DESCRIPTION,
    version     = PLUGIN_VERSION,
    url         = "https://github.com/F1F88/"
};



Address g_pAddressMotdSize;                 // 用于记录 motd 容量值的地址

Address g_pAddressCVmotdfile;               // 用于记录 ConVar - motdfile 的地址
Address g_pAddressCVmotdfile_text;          // 用于记录 ConVar - motdfile_text 的地址

Address g_pServerGameDLL;                   // 用于调用 CServerGameDLL::成员函数 时作为 this

Handle  g_hLoadSpecificMOTDMsg;             // 用于加载 motd (修改 motd 容量后如果不重新加载, 则需换图才能使修改生效)

int     cv_iMotdSize;                       // 用于修改 motd 容量, 修改这个参数值, 插件会相应的修改内存里 motd 的容量值


public void OnPluginStart()
{
    LoadGameData();

    CreateConVar("sm_big_motd_version", PLUGIN_VERSION, PLUGIN_DESCRIPTION, FCVAR_SPONLY | FCVAR_DONTRECORD);

    ConVar convar = CreateConVar("sm_big_motd_size", "2048", "motd maximum number of characters.", _, true, 0.0, true, 65535.0);
    convar.AddChangeHook(On_ConVar_Change);
    cv_iMotdSize = convar.IntValue;

    AutoExecConfig(true, PLUGIN_NAME);

    setMotdSize(cv_iMotdSize);
}

void On_ConVar_Change(ConVar convar, const char[] old_value, const char[] new_value)
{
    cv_iMotdSize = convar.IntValue;
    setMotdSize(cv_iMotdSize);
}


void LoadGameData()
{
    GameData gamedata = new GameData("big-motd.games");
    if( ! gamedata )
        SetFailState("Failed to load gamedata. ");

    g_pAddressMotdSize          = GameConfGetAddressOrFail(gamedata, "pAddressMotdSize");

    g_pAddressCVmotdfile        = GameConfGetAddressOrFail(gamedata, "CVmotdfile");
    g_pAddressCVmotdfile_text   = GameConfGetAddressOrFail(gamedata, "CVmotdfile_text");

    g_pServerGameDLL            = GameConfGetAddressOrFail(gamedata, "g_ServerGameDLL");

    StartPrepSDKCall(SDKCall_Raw);
    PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CServerGameDLL::LoadSpecificMOTDMsg");
    PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
    PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
    if( (g_hLoadSpecificMOTDMsg = EndPrepSDKCall()) == INVALID_HANDLE )
        SetFailState("Could not load the \"CServerGameDLL::LoadSpecificMOTDMsg\" gamedata signature.");

    delete gamedata;
}

// int getMotdSize()
// {
//     return LoadFromAddress(g_pAddressMotdSize, NumberType_Int16);
// }

void setMotdSize(int size)
{
    StoreToAddress(g_pAddressMotdSize, size, NumberType_Int16);

    LoadSpecificMOTDMsg(g_pAddressCVmotdfile, "motd");
    LoadSpecificMOTDMsg(g_pAddressCVmotdfile_text, "motd_text");

    PrintToServer("[Big MOTD] Set new MOTD size, ReLoad Message Of The Day!");
}

void LoadSpecificMOTDMsg(Address convar, char[] str="motd")
{
    SDKCall(g_hLoadSpecificMOTDMsg, g_pServerGameDLL, convar, str);
}


/**
 * Retrieve an Address from a game conf or abort the plugin.
 */
stock Address GameConfGetAddressOrFail(GameData gamedata, const char[] key)
{
    Address address = gamedata.GetAddress(key);
    if( address == Address_Null )
        SetFailState("Failed to read gamedata address of %s", key);
    return address;
}

/**
 * Retrieve an offset from a game conf or abort the plugin.
 */
stock int GameConfGetOffsetOrFail(GameData gamedata, const char[] key)
{
    int offset = gamedata.GetOffset(key);
    if( offset == -1 )
        SetFailState("Failed to read gamedata offset of %s", key);
    return offset;
}
