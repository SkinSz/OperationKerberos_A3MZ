#include "script_component.hpp"

ADDON = false;

PREP(EH_killed);

PREPS(drones,attack);
PREPS(drones,createWaypoint);
PREPS(drones,doAirstrike);
PREPS(drones,doReconnaissance);
PREPS(drones,init);
PREPS(drones,requestAirstrike);
PREPS(drones,requestReconnaissance);
PREPS(drones,scan);

PREPS(fdc,defend_artypos);
PREPS(fdc,handle);
PREPS(fdc,init);
PREPS(fdc,observer);
PREPS(fdc,placeOrder);
PREPS(fdc,register);

PREPS(hq,check_radars);
PREPS(hq,dangerzone_buffer);
PREPS(hq,handle);
PREPS(hq,init);
PREPS(hq,init_mission);
PREPS(hq,killed);
PREPS(hq,recon);
PREPS(hq,registerALLGroups);
PREPS(hq,registerGroup);
PREPS(hq,reset);
ADDON = true;
