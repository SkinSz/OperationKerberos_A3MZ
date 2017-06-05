/*
 *  Author: Dorbedo
 *
 *  Description:
 *      initializing the logisic system
 *
 *  Parameter(s):
 *      none
 *
 *  Returns:
 *      none
 *
 */
#define DEBUG_MODE_FULL
#include "script_component.hpp"

If !(canSuspend) exitWith {
    [] spawn FUNC(initialize);
};

waitUntil {time > 60};

ISNILS(EGVAR(player,respawn_fnc),[]);
EGVAR(player,respawn_fnc) pushBack QUOTE(player setVariable [ARR_3('GVAR(isloading)',false,true)];);

private _cfgLog = missionconfigFile >> "logistics" >> "vehicles";
private _mainAction = [
    QGVAR(action_main),
    localize LSTRING(ACTION_MAIN),
    "",
    {true},
    {true}] call ace_interact_menu_fnc_createAction;
private _loadAction = [
    QGVAR(action_load),
    localize LSTRING(ACTION_LOAD),
    "",
    {true},
    {[_target] call FUNC(canload);},
    {[_target] call FUNC(addLoadActions);}
    ] call ace_interact_menu_fnc_createAction;
private _unloadAction = [QGVAR(action_unload), localize LSTRING(ACTION_UNLOAD), "", {[_target] spawn FUNC(dounload);}, {  [_target] call FUNC(canUnload);  }] call ace_interact_menu_fnc_createAction;
private _infoAction = [QGVAR(action_info), localize LSTRING(ACTION_DISP_CARGO),"",{[_target] spawn FUNC(disp_cargo);},{true}] call ace_interact_menu_fnc_createAction;
private _paraAction = [QGVAR(action_paradrop), localize LSTRING(ACTION_PARADROP), "", {[_target,true] spawn FUNC(dounload);}, {[_target] call FUNC(candrop);}] call ace_interact_menu_fnc_createAction;
private _extendAction = [QGVAR(action_extend), localize LSTRING(ACTION_EXTEND), "", {[_target,true] spawn FUNC(changeCargo);}, {[_target,true] call FUNC(canChangeCargo);}] call ace_interact_menu_fnc_createAction;
private _reduceAction = [QGVAR(action_reduce), localize LSTRING(ACTION_REDUCE), "", {[_target,false] spawn FUNC(changeCargo);}, {[_target,false] call FUNC(canChangeCargo);}] call ace_interact_menu_fnc_createAction;
private _towAction = [QGVAR(action_tow), localize LSTRING(ACTION_TOW), "", {[_target] spawn FUNC(simpletowing_doTow);}, {[_target] call FUNC(simpletowing_canTow);}] call ace_interact_menu_fnc_createAction;
private _untowAction = [QGVAR(action_tow), localize LSTRING(ACTION_UNTOW), "", {[_target] spawn FUNC(simpletowing_doUnTow);}, {[_target] call FUNC(simpletowing_canUnTow);}] call ace_interact_menu_fnc_createAction;
private _spareTrack = [QGVAR(action_spareTrack), localize LSTRING(ACTION_SPARETRACK), "", {[_target] spawn FUNC(doRemoveTrack);}, {(_target getVariable [QGVAR(spareTrackAmount),1]) > 0}] call ace_interact_menu_fnc_createAction;

[localize ELSTRING(main,name), QGVAR(keybind_g), [localize LSTRING(ACTION_PARADROP), localize LSTRING(ACTION_PARADROP)], { if ([vehicle ace_player] call FUNC(candrop)) then { [vehicle ace_player,true] spawn FUNC(dounload)}; }, {true}, [0x22, [false, false, false]], false] call CBA_fnc_addKeybind;



private _allVehicles = configProperties [configFile >> "CfgVehicles","((isClass _x)&&{getNumber(_x >> 'scope') > 1})", false];
TRACEV_1(count _allVehicles);
GVAR(initializedVehicles) = LHASH_CREATE;

{
    private _vehicle = configName _x;

    private _canLoad = ( getnumber(missionconfigFile >> "logistics" >> "vehicles" >> _vehicle >> "max_length") ) > 0;
    private _canPara = ((( getnumber(missionconfigFile >> "logistics" >> "vehicles" >> _vehicle >> "max_length") ) > 0)&&(_vehicle isKindOf "Air"));
    private _canCargo = (isClass(missionconfigFile >> "logistics" >> "vehicles" >> _vehicle >> "cargo"));
    If (_canLoad) then {
        If (!HASH_GET_DEF(GVAR(initializedVehicles),_vehicle,false)) then {
            [_vehicle, 0, ["ACE_MainActions"], _mainAction,false] call ace_interact_menu_fnc_addActionToClass;
        };
        HASH_SET(GVAR(initializedVehicles),_vehicle,true);
        [_vehicle, 0, ["ACE_MainActions",QGVAR(action_main)], _loadAction,false] call ace_interact_menu_fnc_addActionToClass;
        [_vehicle, 0, ["ACE_MainActions",QGVAR(action_main)], _unloadAction,false] call ace_interact_menu_fnc_addActionToClass;
        [_vehicle, 0, ["ACE_MainActions",QGVAR(action_main)], _infoAction,false] call ace_interact_menu_fnc_addActionToClass;
        If (_canCargo) then {
            [_vehicle, 0, ["ACE_MainActions",QGVAR(action_main)], _extendAction,false] call ace_interact_menu_fnc_addActionToClass;
            [_vehicle, 0, ["ACE_MainActions",QGVAR(action_main)], _reduceAction,false] call ace_interact_menu_fnc_addActionToClass;
        };
        [_vehicle, 1, ["ACE_SelfActions"], _mainAction] call ace_interact_menu_fnc_addActionToClass;
        [_vehicle, 1, ["ACE_SelfActions",QGVAR(action_main)], _infoAction,false] call ace_interact_menu_fnc_addActionToClass;
        If (_canPara) then {
            [_vehicle, 1, ["ACE_SelfActions",QGVAR(action_main)], _paraAction,false] call ace_interact_menu_fnc_addActionToClass;
        };
    };

    if (_vehicle isKindOf "Quadbike_01_base_F") then {
        If (!HASH_GET_DEF(GVAR(initializedVehicles),_vehicle,false)) then {
            [_vehicle, 0, ["ACE_MainActions"], _mainAction,false] call ace_interact_menu_fnc_addActionToClass;
        };
        HASH_SET(GVAR(initializedVehicles),_vehicle,true);
        [_vehicle, 0, ["ACE_MainActions",QGVAR(action_main)], _untowAction,false] call ace_interact_menu_fnc_addActionToClass;
        [_vehicle, 0, ["ACE_MainActions",QGVAR(action_main)], _towAction,false] call ace_interact_menu_fnc_addActionToClass;
    };

    if (_vehicle isKindOf "Air") then {
        If (!HASH_GET_DEF(GVAR(initializedVehicles),_vehicle,false)) then {
            [_vehicle, 0, ["ACE_MainActions"], _mainAction,false] call ace_interact_menu_fnc_addActionToClass;
        };
        HASH_SET(GVAR(initializedVehicles),_vehicle,true);
        [_vehicle, 0, ["ACE_MainActions",QGVAR(action_main)], _untowAction,false] call ace_interact_menu_fnc_addActionToClass;
    };

    If (isClass(configfile >> "cfgvehicles" >> _vehicle >> "HitPoints" >> "HitRTrack")) then {
        If (!HASH_GET_DEF(GVAR(initializedVehicles),_vehicle,false)) then {
            [_vehicle, 0, ["ACE_MainActions"], _mainAction,false] call ace_interact_menu_fnc_addActionToClass;
        };
        HASH_SET(GVAR(initializedVehicles),_vehicle,true);
        [_vehicle, 0, ["ACE_MainActions",QGVAR(action_main)], _spareTrack,false] call ace_interact_menu_fnc_addActionToClass;
    };

} forEach _allVehicles;

/// Cargo
private _cfgVeh = configFile >> "CfgVehicles";
_loadAction = [
    QGVAR(action_load),
    localize LSTRING(ACTION_LOAD),
    "",
    {true},
    {[_target] call FUNC(canbeload);},
    {[_target] call FUNC(addbeLoadedActions);}
    ] call ace_interact_menu_fnc_createAction;

for "_i" from 0 to ((count _cfgVeh)-1) do {
    private _vehicle = configname(_cfgVeh select _i);
    If (!([_vehicle] call FUNC(getCargoCfg) isEqualTo "")) then {
        If (!HASH_GET_DEF(GVAR(initializedVehicles),_vehicle,false)) then {
            [_vehicle, 0, ["ACE_MainActions"], _mainAction,false] call ace_interact_menu_fnc_addActionToClass;
        };
        HASH_SET(GVAR(initializedVehicles),_vehicle,true);
        [_vehicle, 0, ["ACE_MainActions",QGVAR(action_main)], _loadAction,false] call ace_interact_menu_fnc_addActionToClass;
    };
};
