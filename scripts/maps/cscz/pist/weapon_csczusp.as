// Counter-Strike Condition Zero K&M .45 Tactical (H&K USP .45 Tactical)
/* Model Credits
/ Model: Valve
/ Textures: Valve
/ Animations: Valve
/ Sounds: Valve
/ Sprites: Valve, R4to0
/ Misc: Valve, D.N.I.O. 071 (Magazine Model Rip), SV BOY
/ Script: KernCore
/ Hand Rig: Mementocity, Garompa (Fixing, merging, additional rigs), Norman and DNIO071 (Remappable hands)
*/

#include "../base"

namespace CSCZ_USP
{

// Animations
enum CSCZ_Usp_Animation
{
	IDLE = 0,
	SHOOT1,
	SHOOT2,
	SHOOT3,
	SHOOT_EMPTY,
	RELOAD,
	DRAW,
	ADD_SILENCER,
	IDLE_UNSIL,
	SHOOT1_UNSIL,
	SHOOT2_UNSIL,
	SHOOT3_UNSIL,
	SHOOT_EMPTY_UNSIL,
	RELOAD_UNSIL,
	DRAW_UNSIL,
	DETACH_SILENCER
};

// Models
string W_MODEL  	= "models/csczsven/wpn/usp/w_usp.mdl";
string V_MODEL  	= "models/csczsven/wpn/usp/v_usp.mdl";
string P_MODEL  	= "models/csczsven/wpn/usp/p_usp.mdl";
string A_MODEL  	= "models/csczsven/ammo/mags.mdl";
int MAG_BDYGRP  	= 6;
// Sprites
string SPR_CAT  	= "pist/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"csczsven/usp/magout.wav",
					"csczsven/usp/magin.wav",
					"csczsven/usp/sldrl.wav",
					"csczsven/usp/sldbk.wav",
					"csczsven/usp/siloff.wav",
					"csczsven/usp/silon.wav"
};
string SHOOT_S  	= "csczsven/usp/shoot.wav";
string SHOOT_S2 	= "csczsven/usp/shoot2.wav";
// Information
int MAX_CARRY   	= 240;
int MAX_CLIP    	= 12;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 18;
uint DAMAGE2     	= 16;
uint SLOT       	= 1;
uint POSITION   	= 5;
float RPM       	= 0.155f;
uint MAX_SHOOT_DIST	= 4096;
string AMMO_TYPE 	= "CSCZ_45acp";

//Buy Menu Information
string WPN_NAME 	= "H&K USP .45 Tactical";
uint WPN_PRICE  	= 160;
string AMMO_NAME 	= "USP .45ACP Magazine";
uint AMMO_PRICE  	= 10;

class weapon_csczusp : ScriptBasePlayerWeaponEntity, CSCZBASE::WeaponBase
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int m_iShell;
	private int GetBodygroup()
	{
		return 0;
	}

	void Spawn()
	{
		Precache();
		WeaponSilMode = CSCZBASE::MODE_SUP_OFF;
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
		CSCZBASE::PrecacheSound( SHOOT_S2 );
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
		return Deploy( V_MODEL, P_MODEL, (WeaponSilMode == CSCZBASE::MODE_SUP_OFF) ? DRAW_UNSIL : DRAW, "onehanded", GetBodygroup(), (48.0/48.0) );
	}

	bool PlayEmptySound()
	{
		return CommonPlayEmptySound( CSCZBASE::EMPTY_PISTOL_S );
	}

	void Holster( int skiplocal = 0 )
	{
		CommonHolster();

		BaseClass.Holster( skiplocal );
	}

	void PrimaryAttack()
	{
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM;
			return;
		}

		if( m_pPlayer.m_afButtonPressed & IN_ATTACK == 0 )
			return;

		Vector vecSpread;

		if( WeaponFireMode == CSCZBASE::MODE_SUP_OFF )
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
		else
		{
			if( m_pPlayer.pev.velocity.Length2D() > 0 )
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.15f;
			}
			else if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
			{
				vecSpread = VECTOR_CONE_2DEGREES * 1.85f;
			}
			else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.0f;
			}
			else
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.05f;
			}
		}

		vecSpread = vecSpread * (m_iShotsFired * 0.2); // do vector math calculations here to make the Spread worse

		self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM;

		if( WeaponSilMode == CSCZBASE::MODE_SUP_ON )
		{
			ShootWeapon( SHOOT_S2, 1, vecSpread, MAX_SHOOT_DIST, DAMAGE2, DMG_GENERIC, true );
			self.SendWeaponAnim( (self.m_iClip > 0) ? SHOOT1 + Math.RandomLong( 0, 2 ) : SHOOT_EMPTY, 0, GetBodygroup() );
		}
		else
		{
			ShootWeapon( SHOOT_S, 1, vecSpread, MAX_SHOOT_DIST, DAMAGE );
			self.SendWeaponAnim( (self.m_iClip > 0) ? SHOOT1_UNSIL + Math.RandomLong( 0, 2 ) : SHOOT_EMPTY_UNSIL, 0, GetBodygroup() );
		}

		self.m_flTimeWeaponIdle = (self.m_iClip > 0) ? WeaponTimeBase() + 1.0f : WeaponTimeBase() + 20.0f;

		m_pPlayer.m_iWeaponVolume = (WeaponSilMode == CSCZBASE::MODE_SUP_OFF) ? NORMAL_GUN_VOLUME : 0;
		m_pPlayer.m_iWeaponFlash = (WeaponSilMode == CSCZBASE::MODE_SUP_OFF) ? DIM_GUN_FLASH : 0;

		m_pPlayer.pev.punchangle.x -= 2;

		ShellEject( m_pPlayer, m_iShell, Vector( 16, 7, -6 ), true, false );
	}

	void SecondaryAttack()
	{
		self.m_flTimeWeaponIdle = self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + (115.0/37.0);
		switch( WeaponSilMode )
		{
			case CSCZBASE::MODE_SUP_OFF:
			{
				WeaponSilMode = CSCZBASE::MODE_SUP_ON;
				self.SendWeaponAnim( ADD_SILENCER, 0, GetBodygroup() );
				break;
			}
			case CSCZBASE::MODE_SUP_ON:
			{
				WeaponSilMode = CSCZBASE::MODE_SUP_OFF;
				self.SendWeaponAnim( DETACH_SILENCER, 0, GetBodygroup() );
				break;
			}
		}
	}

	void Reload()
	{
		if( self.m_iClip == MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		Reload( MAX_CLIP, (WeaponSilMode == CSCZBASE::MODE_SUP_OFF) ? RELOAD_UNSIL : RELOAD, (100.0/37.0), GetBodygroup() );

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

		self.SendWeaponAnim( (WeaponSilMode == CSCZBASE::MODE_SUP_OFF) ? IDLE_UNSIL : IDLE, 0, GetBodygroup() );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class USP_MAG : ScriptBasePlayerAmmoEntity, CSCZBASE::AmmoBase
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
	return "ammo_csczusp";
}

string GetName()
{
	return "weapon_csczusp";
}

void Register()
{
	CSCZBASE::RegisterCWEntity( "CSCZ_USP::", "weapon_csczusp", GetName(), GetAmmoName(), "USP_MAG", 
		CSCZBASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CSCZBASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CSCZBASE::DF_AMMO_9MM );
}

}