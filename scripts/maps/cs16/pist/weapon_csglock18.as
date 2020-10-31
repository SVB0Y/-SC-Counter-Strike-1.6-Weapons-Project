// Counter-Strike 1.6 Glock 18
/* Model Credits
/ Model: Valve
/ Textures: Valve
/ Animations: Valve
/ Sounds: Valve
/ Sprites: Valve
/ Misc: Valve
/ Script: KernCore
*/

#include "../base"

namespace CS16_GLOCK18
{

// Animations
enum CS16_Glock18_Animations
{
	IDLE1 = 0,
	IDLE2, //Unused
	IDLE3, //Unused
	SHOOT1, //Unused
	SHOOT2, //Unused
	SHOOT3,
	SHOOTEMPTY,
	RELOAD,
	DRAW,
	HOLSTER,
	ADDSILENCER, //Unused
	DRAW2, //Unused
	RELOAD2 //Unused
};

// Models
string W_MODEL  	= "models/cs16/wpn/g18/w_glock18.mdl";
string V_MODEL  	= "models/cs16/wpn/g18/v_glock18.mdl";
string P_MODEL  	= "models/cs16/wpn/g18/p_glock18.mdl";
string A_MODEL  	= "models/cs16/ammo/mags.mdl";
int MAG_BDYGRP  	= 0;
// Sprites
string SPR_CAT  	= "pist/"; //Weapon category used to get the sprite's location
// Sounds
string SHOOT_S  	= "cs16/glock18-2.wav";
// Information
int MAX_CARRY   	= 120;
int MAX_CLIP    	= 20;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= 0;
uint DAMAGE     	= 39;
uint SLOT       	= 1;
uint POSITION   	= 5;
float RPM_SINGLE 	= 0.1f;
float RPM_BURST 	= 0.05f;
string AMMO_TYPE 	= "cs16_9x19mm";

class weapon_csglock18 : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int m_iShell;
	private int m_iBurstCount = 0, m_iBurstLeft = 0;
	private float m_flNextBurstFireTime = 0;
	private int GetBodygroup()
	{
		return 0;
	}

	void Spawn()
	{
		Precache();
		CommonSpawn( W_MODEL, DEFAULT_GIVE );
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		//Models
		g_Game.PrecacheModel( W_MODEL );
		g_Game.PrecacheModel( V_MODEL );
		g_Game.PrecacheModel( P_MODEL );
		g_Game.PrecacheModel( A_MODEL );
		m_iShell = g_Game.PrecacheModel( CS16BASE::SHELL_PISTOL );
		//Entity
		g_Game.PrecacheOther( GetAmmoName() );
		//Sounds
		CS16BASE::PrecacheSound( SHOOT_S );
		CS16BASE::PrecacheSound( CS16BASE::EMPTY_PISTOL_S );
		//Sprites
		CommonSpritePrecache();
		g_Game.PrecacheGeneric( CS16BASE::MAIN_SPRITE_DIR + CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT + self.pev.classname + ".txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= (CS16BASE::ShouldUseCustomAmmo) ? MAX_CARRY : CS16BASE::DF_MAX_CARRY_9MM;
		info.iAmmo1Drop	= MAX_CLIP;
		info.iMaxAmmo2 	= -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip 	= MAX_CLIP;
		info.iSlot  	= SLOT;
		info.iPosition 	= POSITION;
		info.iId     	= g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iFlags 	= FLAGS;
		info.iWeight 	= WEIGHT;

		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		return CommonAddToPlayer( pPlayer );
	}

	bool Deploy()
	{
		return Deploy( V_MODEL, P_MODEL, DRAW, "onehanded", GetBodygroup(), (49.0/45.0) );
	}

	bool PlayEmptySound()
	{
		return CommonPlayEmptySound( CS16BASE::EMPTY_PISTOL_S );
	}

	void Holster( int skiplocal = 0 )
	{
		m_iBurstLeft = 0;
		CommonHolster();

		BaseClass.Holster( skiplocal );
	}

	private void FireWeapon()
	{
		ShootWeapon( SHOOT_S, 1, VECTOR_CONE_1DEGREES, 8192, DAMAGE );

		self.SendWeaponAnim( (self.m_iClip > 0) ? SHOOT3 : SHOOTEMPTY, 0, GetBodygroup() );

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		ShellEject( m_pPlayer, m_iShell, Vector( 21, 10, -7 ), true, false );
	}

	void PrimaryAttack()
	{
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM_SINGLE;
			return;
		}

		if( WeaponFireMode == CS16BASE::MODE_NORMAL && m_pPlayer.m_afButtonPressed & IN_ATTACK == 0 )
		{
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + RPM_SINGLE;
			return;
		}
		else if( WeaponFireMode == CS16BASE::MODE_BURST )
		{
			//Fire at most 3 bullets.
			m_iBurstCount = Math.min( 3, self.m_iClip );
			m_iBurstLeft = m_iBurstCount - 1;

			m_flNextBurstFireTime = WeaponTimeBase() + RPM_BURST;
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.5;
		}

		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0f;
		FireWeapon();
	}

	void SecondaryAttack()
	{
		switch( WeaponFireMode )
		{
			case CS16BASE::MODE_NORMAL:
			{
				WeaponFireMode = CS16BASE::MODE_BURST;
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "Switched to Burst Fire\n" );
				break;
			}
			case CS16BASE::MODE_BURST:
			{
				WeaponFireMode = CS16BASE::MODE_NORMAL;
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "Switched to Semi Auto\n" );
				break;
			}
		}
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.3f;
	}

	void ItemPostFrame()
	{
		if( WeaponFireMode == CS16BASE::MODE_BURST )
		{
			if( m_iBurstLeft > 0 )
			{
				if( m_flNextBurstFireTime < WeaponTimeBase() )
				{
					if( self.m_iClip <= 0 )
					{
						m_iBurstLeft = 0;
						return;
					}
					else
						--m_iBurstLeft;

					FireWeapon();

					if( m_iBurstLeft > 0 )
						m_flNextBurstFireTime = WeaponTimeBase() + RPM_BURST;
					else
						m_flNextBurstFireTime = 0;
				}

				//While firing a burst, don't allow reload or any other weapon actions. Might be best to let some things run though.
				return;
			}
		}

		BaseClass.ItemPostFrame();
	}

	void Reload()
	{
		if( self.m_iClip == MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		Reload( MAX_CLIP, RELOAD, (75.0/35.0), GetBodygroup() );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flNextPrimaryAttack < g_Engine.time )
			m_iShotsFired = 0;

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( IDLE1, 0, GetBodygroup() );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class CSGLOCK18_MAG : ScriptBasePlayerAmmoEntity, CS16BASE::AmmoBase
{
	void Spawn()
	{
		Precache();

		CommonSpawn( A_MODEL, MAG_BDYGRP );
	}

	void Precache()
	{
		//Models
		g_Game.PrecacheModel( A_MODEL );
		//Sounds
		CommonPrecache();
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return CommonAddAmmo( pOther, MAX_CLIP, (CS16BASE::ShouldUseCustomAmmo) ? MAX_CARRY : CS16BASE::DF_MAX_CARRY_9MM, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_9MM );
	}
}

string GetAmmoName()
{
	return "ammo_csglock18";
}

string GetName()
{
	return "weapon_csglock18";
}

void Register()
{
	CS16BASE::RegisterCWEntity( "CS16_GLOCK18::", "weapon_csglock18", GetName(), GetAmmoName(), "CSGLOCK18_MAG", 
		CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_9MM );
}

}