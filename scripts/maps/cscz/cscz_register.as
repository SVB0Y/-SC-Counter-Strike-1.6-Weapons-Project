#include "weapons"
#include "BuyMenu"

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Original: D.N.I.O. 071/R4to0/KernCore, CSCZ Port by SV BOY/Garompa/Mementocity" );
	g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/0wtJ6aAd7XOGI6vI" );

	//Change each weapon's iPosition here so they don't conflict with Map's weapons
	//Melees
	CSCZ_KNIFE::POSITION 		= 10;
	//Pistols
	CSCZ_GLOCK18::POSITION 		= 10;
	CSCZ_USP::POSITION 			= 11;
	CSCZ_P228::POSITION 		= 12;
	CSCZ_57::POSITION 			= 13;
	CSCZ_ELITES::POSITION 		= 14;
	CSCZ_DEAGLE::POSITION 		= 15;
	//Shotguns
	CSCZ_M3::POSITION 			= 10;
	CSCZ_XM1014::POSITION 		= 11;
	//Submachine Guns
	CSCZ_MAC10::POSITION 		= 10;
	CSCZ_TMP::POSITION 			= 11;
	CSCZ_MP5::POSITION 			= 12;
	CSCZ_UMP45::POSITION 		= 13;
	CSCZ_P90::POSITION 			= 14;
	//Assault Rifles
	CSCZ_FAMAS::POSITION 		= 10;
	CSCZ_GALIL::POSITION 		= 11;
	CSCZ_AK47::POSITION 		= 12;
	CSCZ_M4A1::POSITION 		= 13;
	CSCZ_AUG::POSITION 			= 14;
	CSCZ_SG552::POSITION 		= 15;
	//Sniper Rifles
	CSCZ_SCOUT::POSITION 		= 10;
	CSCZ_AWP::POSITION 			= 11;
	CSCZ_SG550::POSITION 		= 12;
	CSCZ_G3SG1::POSITION 		= 13;
	//Light Machine Guns
	CSCZ_M249::POSITION 		= 10;
	//Misc
	CSCZ_HEGRENADE::POSITION 	= 10;
	CSCZ_C4::POSITION 			= 11;

	//Register Buy menu stuff
	BuyMenu::RegisterBuyMenuCCVars();
}

void MapInit()
{
	g_CSCZMenu.RemoveItems();

	//Helper method to register all weapons
	RegisterAll();

	//Melees
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_KNIFE::WPN_NAME, CSCZ_KNIFE::GetName(), CSCZ_KNIFE::WPN_PRICE, "melee" ) );


	//Pistols and Handguns
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_GLOCK18::WPN_NAME, CSCZ_GLOCK18::GetName(), CSCZ_GLOCK18::WPN_PRICE, "handgun" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_GLOCK18::AMMO_NAME, CSCZ_GLOCK18::GetAmmoName(), CSCZ_GLOCK18::AMMO_PRICE, "ammo", "handgun" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_USP::WPN_NAME, CSCZ_USP::GetName(), CSCZ_USP::WPN_PRICE, "handgun" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_USP::AMMO_NAME, CSCZ_USP::GetAmmoName(), CSCZ_USP::AMMO_PRICE, "ammo", "handgun" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_P228::WPN_NAME, CSCZ_P228::GetName(), CSCZ_P228::WPN_PRICE, "handgun" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_P228::AMMO_NAME, CSCZ_P228::GetAmmoName(), CSCZ_P228::AMMO_PRICE, "ammo", "handgun" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_57::WPN_NAME, CSCZ_57::GetName(), CSCZ_57::WPN_PRICE, "handgun" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_57::AMMO_NAME, CSCZ_57::GetAmmoName(), CSCZ_57::AMMO_PRICE, "ammo", "handgun" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_ELITES::WPN_NAME, CSCZ_ELITES::GetName(), CSCZ_ELITES::WPN_PRICE, "handgun" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_ELITES::AMMO_NAME, CSCZ_ELITES::GetAmmoName(), CSCZ_ELITES::AMMO_PRICE, "ammo", "handgun" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_DEAGLE::WPN_NAME, CSCZ_DEAGLE::GetName(), CSCZ_DEAGLE::WPN_PRICE, "handgun" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_DEAGLE::AMMO_NAME, CSCZ_DEAGLE::GetAmmoName(), CSCZ_DEAGLE::AMMO_PRICE, "ammo", "handgun" ) );


	//Shotguns
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_M3::WPN_NAME, CSCZ_M3::GetName(), CSCZ_M3::WPN_PRICE, "shotgun" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_M3::AMMO_NAME, CSCZ_M3::GetAmmoName(), CSCZ_M3::AMMO_PRICE, "ammo", "shotgun" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_XM1014::WPN_NAME, CSCZ_XM1014::GetName(), CSCZ_XM1014::WPN_PRICE, "shotgun" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_XM1014::AMMO_NAME, CSCZ_XM1014::GetAmmoName(), CSCZ_XM1014::AMMO_PRICE, "ammo", "shotgun" ) );


	//Submachine guns
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_MAC10::WPN_NAME, CSCZ_MAC10::GetName(), CSCZ_MAC10::WPN_PRICE, "smg" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_MAC10::AMMO_NAME, CSCZ_MAC10::GetAmmoName(), CSCZ_MAC10::AMMO_PRICE, "ammo", "smg" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_TMP::WPN_NAME, CSCZ_TMP::GetName(), CSCZ_TMP::WPN_PRICE, "smg" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_TMP::AMMO_NAME, CSCZ_TMP::GetAmmoName(), CSCZ_TMP::AMMO_PRICE, "ammo", "smg" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_MP5::WPN_NAME, CSCZ_MP5::GetName(), CSCZ_MP5::WPN_PRICE, "smg" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_MP5::AMMO_NAME, CSCZ_MP5::GetAmmoName(), CSCZ_MP5::AMMO_PRICE, "ammo", "smg" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_UMP45::WPN_NAME, CSCZ_UMP45::GetName(), CSCZ_UMP45::WPN_PRICE, "smg" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_UMP45::AMMO_NAME, CSCZ_UMP45::GetAmmoName(), CSCZ_UMP45::AMMO_PRICE, "ammo", "smg" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_P90::WPN_NAME, CSCZ_P90::GetName(), CSCZ_P90::WPN_PRICE, "smg" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_P90::AMMO_NAME, CSCZ_P90::GetAmmoName(), CSCZ_P90::AMMO_PRICE, "ammo", "smg" ) );


	//Assault Rifles & Sniper Rifles
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_FAMAS::WPN_NAME, CSCZ_FAMAS::GetName(), CSCZ_FAMAS::WPN_PRICE, "rifle" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_FAMAS::AMMO_NAME, CSCZ_FAMAS::GetAmmoName(), CSCZ_FAMAS::AMMO_PRICE, "ammo", "rifle" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_GALIL::WPN_NAME, CSCZ_GALIL::GetName(), CSCZ_GALIL::WPN_PRICE, "rifle" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_GALIL::AMMO_NAME, CSCZ_GALIL::GetAmmoName(), CSCZ_GALIL::AMMO_PRICE, "ammo", "rifle" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_AK47::WPN_NAME, CSCZ_AK47::GetName(), CSCZ_AK47::WPN_PRICE, "rifle" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_AK47::AMMO_NAME, CSCZ_AK47::GetAmmoName(), CSCZ_AK47::AMMO_PRICE, "ammo", "rifle" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_M4A1::WPN_NAME, CSCZ_M4A1::GetName(), CSCZ_M4A1::WPN_PRICE, "rifle" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_M4A1::AMMO_NAME, CSCZ_M4A1::GetAmmoName(), CSCZ_M4A1::AMMO_PRICE, "ammo", "rifle" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_AUG::WPN_NAME, CSCZ_AUG::GetName(), CSCZ_AUG::WPN_PRICE, "rifle" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_AUG::AMMO_NAME, CSCZ_AUG::GetAmmoName(), CSCZ_AUG::AMMO_PRICE, "ammo", "rifle" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_SG552::WPN_NAME, CSCZ_SG552::GetName(), CSCZ_SG552::WPN_PRICE, "rifle" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_SG552::AMMO_NAME, CSCZ_SG552::GetAmmoName(), CSCZ_SG552::AMMO_PRICE, "ammo", "rifle" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_SCOUT::WPN_NAME, CSCZ_SCOUT::GetName(), CSCZ_SCOUT::WPN_PRICE, "rifle" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_SCOUT::AMMO_NAME, CSCZ_SCOUT::GetAmmoName(), CSCZ_SCOUT::AMMO_PRICE, "ammo", "rifle" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_AWP::WPN_NAME, CSCZ_AWP::GetName(), CSCZ_AWP::WPN_PRICE, "rifle" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_AWP::AMMO_NAME, CSCZ_AWP::GetAmmoName(), CSCZ_AWP::AMMO_PRICE, "ammo", "rifle" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_SG550::WPN_NAME, CSCZ_SG550::GetName(), CSCZ_SG550::WPN_PRICE, "rifle" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_SG550::AMMO_NAME, CSCZ_SG550::GetAmmoName(), CSCZ_SG550::AMMO_PRICE, "ammo", "rifle" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_G3SG1::WPN_NAME, CSCZ_G3SG1::GetName(), CSCZ_G3SG1::WPN_PRICE, "rifle" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_G3SG1::AMMO_NAME, CSCZ_G3SG1::GetAmmoName(), CSCZ_G3SG1::AMMO_PRICE, "ammo", "rifle" ) );


	//Light Machine Guns
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_M249::WPN_NAME, CSCZ_M249::GetName(), CSCZ_M249::WPN_PRICE, "lmg" ) );
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_M249::AMMO_NAME, CSCZ_M249::GetAmmoName(), CSCZ_M249::AMMO_PRICE, "ammo", "lmg" ) );


	//Explosives and Equipment
	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_HEGRENADE::WPN_NAME, CSCZ_HEGRENADE::GetName(), CSCZ_HEGRENADE::WPN_PRICE, "equip" ) );

	g_CSCZMenu.AddItem( BuyMenu::BuyableItem( CSCZ_C4::WPN_NAME, CSCZ_C4::GetName(), CSCZ_C4::WPN_PRICE, "equip" ) );

	//Initializes hooks and precaches used by the Buy Menu Plugin
	BuyMenu::MoneyInit();
}