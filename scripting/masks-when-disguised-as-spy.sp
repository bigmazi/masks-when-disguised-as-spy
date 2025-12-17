#include <sourcemod>
#include <tf2_stocks>

#pragma semicolon 1

public Plugin myinfo = {
	name = "[TF2] Select masks when disguised as spy",
	author = "bigmazi",
	description = "Allows to select disguise masks which player's enemies can see when the player is disguised as a Spy",
	version = "1.0.0.0",
	url = "https://steamcommunity.com/id/bmazi"
}

#define INT view_as<int>
#define HANDLE view_as<Handle>

#define TF_FIRST_NORMAL_CLASS 1
#define CLASSES_COUNT 9

#define CONFIG_FILE_NAME "masks-when-disguised-as-spy"
#define CONFIG_FILE_PATH "cfg/sourcemod/" ... CONFIG_FILE_NAME ... ".cfg"

int g_allowedMasksCount;
int g_allowedMasks[CLASSES_COUNT];

bool g_shouldAppendPresetInfoToCfgFile;

ConVar g_cvar_pluginEnabled;
ConVar g_cvars_classMaskAllowed[CLASSES_COUNT];

void CacheCvarValues()
{	
	g_allowedMasksCount = 0;
	
	for (int classIdx = 0; classIdx < CLASSES_COUNT; classIdx++)
	{		
		if (g_cvars_classMaskAllowed[classIdx].BoolValue)
		{
			g_allowedMasks[g_allowedMasksCount] = classIdx + TF_FIRST_NORMAL_CLASS;
			g_allowedMasksCount += 1;
		}
	}
}

Action SetMasksFromPreset(const int preset[CLASSES_COUNT])
{
	int cursor = 0;
	
#define SET_FROM_PRESET(%1) \
SetConVarInt(\
	view_as<Handle>(g_cvars_classMaskAllowed[INT(%1) - TF_FIRST_NORMAL_CLASS]),\
	preset[cursor++]\
)
	
	SET_FROM_PRESET(TFClass_Scout);
	SET_FROM_PRESET(TFClass_Soldier);
	SET_FROM_PRESET(TFClass_Pyro);
	
	SET_FROM_PRESET(TFClass_DemoMan);
	SET_FROM_PRESET(TFClass_Heavy);
	SET_FROM_PRESET(TFClass_Engineer);
	
	SET_FROM_PRESET(TFClass_Medic);
	SET_FROM_PRESET(TFClass_Sniper);
	SET_FROM_PRESET(TFClass_Spy);
	
#undef SET_FROM_PRESET
	
	return Plugin_Handled;
}

#define CMDHANDLER(%1) Action %1(int client, int args)

CMDHANDLER(sm_spymask_preset_at_least_spy_speed)
{ return SetMasksFromPreset({1,0,0, 0,0,0, 1,0,1}); }

CMDHANDLER(sm_spymask_preset_at_least_pyro_speed)
{ return SetMasksFromPreset({1,0,1, 0,0,1, 1,1,1}); }

CMDHANDLER(sm_spymask_preset_at_least_demoman_speed)
{ return SetMasksFromPreset({1,0,1, 1,0,1, 1,1,1}); }

CMDHANDLER(sm_spymask_preset_at_least_soldier_speed)
{ return SetMasksFromPreset({1,1,1, 1,0,1, 1,1,1}); }

CMDHANDLER(sm_spymask_preset_allow_all)
{ return SetMasksFromPreset({1,1,1, 1,1,1, 1,1,1}); }

#undef CMDHANDLER

void OnClassCvarChanged(ConVar cvar, const char[] oldval, const char[] newval)
{	
	CacheCvarValues();
}

public void TF2_OnConditionRemoved(int player, TFCond cond)
{	
	if (!g_cvar_pluginEnabled.BoolValue)
		return;
	
	if (cond != TFCond_Disguising)
		return;
	
	if (!TF2_IsPlayerInCondition(player, TFCond_Disguised))
		return;
	
	if (GetEntProp(player, Prop_Send, "m_nDisguiseClass") != INT(TFClass_Spy))
		return;
	
	if (g_allowedMasksCount <= 0)
		return;
	
	int generatedRandomNumber = GetEntProp(player, Prop_Send, "m_nMaskClass");
	
	if (!(1 <= generatedRandomNumber <= 9))
		return;
	
	int remappedNumber = (generatedRandomNumber - 1) % g_allowedMasksCount;
	int newMask = g_allowedMasks[remappedNumber];
	
	SetEntProp(player, Prop_Send, "m_nMaskClass", newMask);
}

public void OnConfigsExecuted()
{	
	File cfg = g_shouldAppendPresetInfoToCfgFile
		? OpenFile(CONFIG_FILE_PATH, "at")
		: view_as<File>(null);
	
	g_shouldAppendPresetInfoToCfgFile = false;
	
	if (cfg)
	{
		WriteFileLine(cfg, ""
			... "// If you wish to use a preset, uncomment one of the following lines:"
			... "\n"
			... "\n//sm_spymask_preset_at_least_spy_speed     // Disguise masks whitelist: Scout, Medic, Spy"
			... "\n//sm_spymask_preset_at_least_pyro_speed    // Disguise masks blacklist: Soldier, Demoman, Heavy Weapons Guy"
			... "\n//sm_spymask_preset_at_least_demoman_speed // Disguise masks blacklist: Soldier, Heavy Weapons Guy"
			... "\n//sm_spymask_preset_at_least_soldier_speed // Disguise masks blacklist: Heavy Weapons Guy"
			... "\n//sm_spymask_preset_allow_all              // Any class can appear on disguise masks (effectively, no modifications)"
			... "\n"
		);
	}
	
	delete cfg;
}

public void OnPluginStart()
{
#define CLASS_CVAR_NAME_PREFIX "sm_spymask_allow_"
#define CLASS_CVAR_HELP_PREFIX "When a player is disguised as a Spy, is "
#define CLASS_CVAR_HELP_POSTFIX "'s mask allowed to be shown to this player's enemies?"
	
#define MAKE_CLASS_CVAR(%1,%2,%3) \
HookConVarChange(\
	HANDLE(g_cvars_classMaskAllowed[INT(%1) - TF_FIRST_NORMAL_CLASS]) = HANDLE(CreateConVar(\
		CLASS_CVAR_NAME_PREFIX... %2,\
		"1",\
		CLASS_CVAR_HELP_PREFIX ... %3 ... CLASS_CVAR_HELP_POSTFIX,\
		0,\
		true, 0.0,\
		true, 1.0\
	)),\
	OnClassCvarChanged\
)
	
	MAKE_CLASS_CVAR(TFClass_Spy,      "spy",      "Spy");
	MAKE_CLASS_CVAR(TFClass_Sniper,   "sniper",   "Sniper");
	MAKE_CLASS_CVAR(TFClass_Medic,    "medic",    "Medic");
	
	MAKE_CLASS_CVAR(TFClass_Engineer, "engineer", "Engineer");
	MAKE_CLASS_CVAR(TFClass_Heavy,    "heavy",    "Heavy Weapons Guy");
	MAKE_CLASS_CVAR(TFClass_DemoMan,  "demoman",  "Demoman");
	
	MAKE_CLASS_CVAR(TFClass_Pyro,     "pyro",     "Pyro");
	MAKE_CLASS_CVAR(TFClass_Soldier,  "soldier",  "Soldier");
	MAKE_CLASS_CVAR(TFClass_Scout,    "scout",    "Scout");
	
#undef MAKE_CLASS_CVAR
	
	g_cvar_pluginEnabled = CreateConVar(
		"sm_spymask_plugin_enabled",
		"1",
		"Allows to select masks which Spy's enemies can see when disguised as Spy",
		0,
		true, 0.0,
		true, 1.0
	);
		
	CacheCvarValues();
	
#define PRESET_CMD_ARGS(%1) #%1, %1, ADMFLAG_RCON
	
	RegAdminCmd(
		PRESET_CMD_ARGS(sm_spymask_preset_at_least_spy_speed),
		"Disguise masks whitelist: Scout, Medic, Spy");
	
	RegAdminCmd(
		PRESET_CMD_ARGS(sm_spymask_preset_at_least_pyro_speed),
		"Disguise masks blacklist: Soldier, Demoman, Heavy Weapons Guy");
	
	RegAdminCmd(
		PRESET_CMD_ARGS(sm_spymask_preset_at_least_demoman_speed),
		"Disguise masks blacklist: Soldier, Heavy Weapons Guy");
	
	RegAdminCmd(
		PRESET_CMD_ARGS(sm_spymask_preset_at_least_soldier_speed),
		"Disguise masks blacklist: Heavy Weapons Guy");
	
	RegAdminCmd(
		PRESET_CMD_ARGS(sm_spymask_preset_allow_all),
		"Any class can appear on disguise masks (effectively, no modifications)");
	
#undef PRESET_CMD_ARGS
	
	g_shouldAppendPresetInfoToCfgFile = !FileExists(CONFIG_FILE_PATH);	
	AutoExecConfig(true, CONFIG_FILE_NAME);
}
 