// Counter-Strike Condition Zero 9×19mm Sidearm (Glock 18)
/* Model Credits
/ Model: Valve
/ Textures: Valve
/ Animations: Valve
/ Sounds: Valve
/ Sprites: Valve, R4to0
/ Misc: Valve, D.N.I.O. 071 (Magazine Model Rip), SV BOY
/ Hand Rig: Mementocity, Garompa (Fixing, merging, additional rigs), Norman and DNIO071 (Remappable hands)
*/

#include "../base"

namespace CSCZ_GLOCK18
{

// Animations
enum CSCZ_Glock18_Animations
{
	IDLE1 = 0,
	IDLE2, //Unused
	IDLE3, //Unused
	SHOOT1, //Unused
	SHOOT2, //Unused
	SHOOT3,
	SHOOT_EMPTY,
	RELOAD,
	DRAW,
	HOLSTER,
	ADDSILENCER, //Unused
	DRAW2, //Unused
	RELOAD2 //Unused
};

// Models
string W_MODEL  	= "models/csczsven/wpn/g18/w_glock18.mdl";
string V_MODEL  	= "models/csczsven/wpn/g18/v_glock18.mdl";
string P_MODEL  	= "models/csczsven/wpn/g18/p_glock18.mdl";
string A_MODEL  	= "models/csczsven/ammo/mags.mdl";
int MAG_BDYGRP  	= 0;
// Sprites
string SPR_CAT  	= "pist/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"csczsven/g18/clipout1.wav",
					"csczsven/g18/clipin1.wav",
					"csczsven/g18/sliderelease1.wav",
					"csczsven/g18/slideback1.wav"
};
string SHOOT_S  	= "csczsven/g18/shoot.wav";
// Information
int MAX_CARRY   	= 500;
int MAX_CLIP    	= 20;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 14;
uint SLOT       	= 1;
uint POSITION   	= 4;
float RPM_SINGLE 	= 0.1f;
float RPM_BURST 	= 0.05f;
uint MAX_SHOOT_DIST	= 8192;
string AMMO_TYPE 	= "CSCZ_9mm";

//Buy Menu Information
string WPN_NAME 	= "Glock 18";
uint WPN_PRICE  	= 150;
string AMMO_NAME 	= "Glock 18 9mm Magazine";
uint AMMO_PRICE  	= 10;

class weapon_csczglock18 : ScriptBasePlayerWeaponEntity, CSCZBASE::WeaponBase
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
		m_iShell = g_Game.PrecacheModel( CSCZBASE::SHELL_PISTOL );
		//Entity
		g_Game.PrecacheOther( GetAmmoName() );
		//Sounds
		CSCZBASE::PrecacheSound( SHOOT_S );
		CSCZBASE::PrecacheSound( CSCZBASE::EMPTY_PISTOL_S );
		CSCZBASE::PrecacheSounds( WeaponSoundEvents );
		//Sprites
		CommonSpritePrecache();
		g_Game.PrecacheGeneric( CSCZBASE::MAIN_SPRITE_DIR + CSCZBASE::MAIN_CSTRIKE_DIR + SPR_CAT + self.pev.classname + ".txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= (CSCZBASE::ShouldUseCustomAmmo) ? MAX_CARRY : CSCZBASE::DF_MAX_CARRY_9MM;
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
		return CommonPlayEmptySound( CSCZBASE::EMPTY_PISTOL_S );
	}

	void Holster( int skiplocal = 0 )
	{
		m_iBurstLeft = 0;
		CommonHolster();

		BaseClass.Holster( skiplocal );
	}

	private void FireWeapon()
	{
		Vector vecSpread;
		if( WeaponFireMode == CSCZBASE::MODE_BURST )
		{
			if( m_pPlayer.pev.velocity.Length2D() > 0 )
			{
				vecSpread = VECTOR_CONE_2DEGREES * 1.185f;
			}
			else if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
			{
				vecSpread = VECTOR_CONE_2DEGREES * 2.2f;
			}
			else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
			{
				vecSpread = VECTOR_CONE_2DEGREES * 1.095f;
			}
			else
			{
				vecSpread = VECTOR_CONE_2DEGREES * 1.3f;
			}
		}
		else
		{
			if( m_pPlayer.pev.velocity.Length2D() > 0 )
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.165f;
			}
			else if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
			{
				vecSpread = VECTOR_CONE_2DEGREES * 2.0f;
			}
			else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.075f;
			}
			else
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.1f;
			}
		}

		vecSpread = vecSpread * (m_iShotsFired * 0.2); // do vector math calculations here to make the Spread worse

		ShootWeapon( SHOOT_S, 1, vecSpread, MAX_SHOOT_DIST, DAMAGE );

		self.SendWeaponAnim( (self.m_iClip > 0) ? SHOOT3 : SHOOT_EMPTY, 0, GetBodygroup() );

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		ShellEject( m_pPlayer, m_iShell, Vector( 21, 10, -7 ), true, false );

		self.m_flTimeWeaponIdle = (self.m_iClip > 0) ? WeaponTimeBase() + 1.0f : WeaponTimeBase() + 20.0f;
	}

	void PrimaryAttack()
	{
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM_SINGLE;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 10.0f;
			return;
		}

		if( WeaponFireMode == CSCZBASE::MODE_BURST )
		{
			//Fire at most 3 bullets.
			m_iBurstCount = Math.min( 3, self.m_iClip );
			m_iBurstLeft = m_iBurstCount - 1;

			m_flNextBurstFireTime = WeaponTimeBase() + RPM_BURST;
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.5;
		}
		else
		{
			if( m_pPlayer.m_afButtonPressed & IN_ATTACK == 0 )
				return;

			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + RPM_SINGLE;
		}

		FireWeapon();
	}

	void SecondaryAttack()
	{
		switch( WeaponFireMode )
		{
			case CSCZBASE::MODE_NORMAL:
			{
				WeaponFireMode = CSCZBASE::MODE_BURST;
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "Switched to Burst Fire\n" );
				break;
			}
			case CSCZBASE::MODE_BURST:
			{
				WeaponFireMode = CSCZBASE::MODE_NORMAL;
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "Switched to Semi Auto\n" );
				break;
			}
		}
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.3f;
	}

	void ItemPostFrame()
	{
		if( WeaponFireMode == CSCZBASE::MODE_BURST )
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

		if( self.m_flNextPrimaryAttack + 0.2 < g_Engine.time ) // wait 0.2 seconds before reseting how many shots the player fired
			m_iShotsFired = 0;

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( IDLE1, 0, GetBodygroup() );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class CSGLOCK18_MAG : ScriptBasePlayerAmmoEntity, CSCZBASE::AmmoBase
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
		return CommonAddAmmo( pOther, MAX_CLIP, (CSCZBASE::ShouldUseCustomAmmo) ? MAX_CARRY : CSCZBASE::DF_MAX_CARRY_9MM, (CSCZBASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CSCZBASE::DF_AMMO_9MM );
	}
}

string GetAmmoName()
{
	return "ammo_csczglock18";
}

string GetName()
{
	return "weapon_csczglock18";
}

void Register()
{
	CSCZBASE::RegisterCWEntity( "CSCZ_GLOCK18::", "weapon_csczglock18", GetName(), GetAmmoName(), "CSGLOCK18_MAG", 
		CSCZBASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CSCZBASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CSCZBASE::DF_AMMO_9MM );
}

}