//Melees
#include "melee/weapon_csczknife"
#include "melee/weapon_csczmachete"
//Pistols and Handguns
#include "pist/weapon_csczglock18"
#include "pist/weapon_csczusp"
#include "pist/weapon_csczp228"
#include "pist/weapon_csczfiveseven"
#include "pist/weapon_csczdualelites"
#include "pist/weapon_csczdeagle"
//Shotguns
#include "shot/weapon_csczm3"
#include "shot/weapon_csczxm1014"
//Submachine guns
#include "smg/weapon_csczmac10"
#include "smg/weapon_cscztmp"
#include "smg/weapon_csczmp5navy"
#include "smg/weapon_csczump45"
#include "smg/weapon_csczp90"
//Explosives and Equipment
#include "misc/weapon_csczhegrenade"
#include "misc/weapon_csczc4"
//Assault Rifles
#include "rifl/weapon_csczfamas"
#include "rifl/weapon_csczgalil"
#include "rifl/weapon_csczak47"
#include "rifl/weapon_csczm4a1"
#include "rifl/weapon_csczaug"
#include "rifl/weapon_csczsg552"
//Sniper Rifles
#include "snip/weapon_csczscout"
#include "snip/weapon_csczawp"
#include "snip/weapon_csczsg550"
#include "snip/weapon_csczg3sg1"
//Light Machine Guns
#include "lmg/weapon_csczm60"
#include "lmg/weapon_csczm249"

void RegisterAll()
{
	//Melees
	CSCZ_KNIFE::Register();
	CSCZ_MACHETE::Register();
	//Pistols and Handguns
	CSCZ_GLOCK18::Register();
	CSCZ_USP::Register();
	CSCZ_P228::Register();
	CSCZ_57::Register();
	CSCZ_ELITES::Register();
	CSCZ_DEAGLE::Register();
	//Shotguns
	CSCZ_M3::Register();
	CSCZ_XM1014::Register();
	//Submachine guns
	CSCZ_MAC10::Register();
	CSCZ_TMP::Register();
	CSCZ_MP5::Register();
	CSCZ_UMP45::Register();
	CSCZ_P90::Register();
	//Explosives and Equipment
	CSCZ_HEGRENADE::Register();
	CSCZ_C4::Register();
	//Assault Rifles
	CSCZ_FAMAS::Register();
	CSCZ_GALIL::Register();
	CSCZ_AK47::Register();
	CSCZ_M4A1::Register();
	CSCZ_AUG::Register();
	CSCZ_SG552::Register();
	//Sniper Rifles
	CSCZ_SCOUT::Register();
	CSCZ_AWP::Register();
	CSCZ_SG550::Register();
	CSCZ_G3SG1::Register();
	//Light Machine Guns
	CSCZ_M60::Register();
	CSCZ_M249::Register();
}
