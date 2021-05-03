// Counter-Strike Condition Zero Krieg 550 Commando (SIG SG 550 Sniper)
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

namespace CSCZ_SG550
{

// Animations
enum CSCZ_Sg550_Animations
{
	IDLE = 0,
	SHOOT1,
	SHOOT2,
	RELOAD,
	DRAW
};

// Models
string W_MODEL  	= "models/csczsven/wpn/sg550/w_sg550.mdl";
string V_MODEL  	= "models/csczsven/wpn/sg550/v_sg550.mdl";
string P_MODEL  	= "models/csczsven/wpn/sg550/p_sg550.mdl";
string A_MODEL  	= "models/csczsven/ammo/mags.mdl";
int MAG_BDYGRP  	= 13;
// Sprites
string SPR_CAT  	= "snip/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"csczsven/sg550/magout.wav",
					"csczsven/sg550/magin.wav",
					"csczsven/sg550/bltbk.wav"
};
string SHOOT_S  	= "csczsven/sg550/shoot.wav";
// Information
int MAX_CARRY   	= 300;
int MAX_CLIP    	= 30;
int DEFAULT_GIVE 	= MAX_CLIP * 4;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 50;
uint SLOT       	= 6;
uint POSITION   	= 6;
float RPM       	= 0.25f;
uint MAX_SHOOT_DIST	= 8192;
string AMMO_TYPE 	= "CSCZ_5.56nato";
float AIM_SPEED 	= 200;

//Buy Menu Information
string WPN_NAME 	= "SIG SG550";
uint WPN_PRICE  	= 460;
string AMMO_NAME 	= "SG550 5.56 NATO Magazine";
uint AMMO_PRICE  	= 30;

class weapon_csczsg550 : ScriptBasePlayerWeaponEntity, CSCZBASE::WeaponBase
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
		m_iShell = g_Game.PrecacheModel( CSCZBASE::SHELL_SNIPER );
		//Entity
		g_Game.PrecacheOther( GetAmmoName() );
		//Sounds
		CSCZBASE::PrecacheSound( SHOOT_S );
		CSCZBASE::PrecacheSound( CSCZBASE::ZOOM_SOUND );
		CSCZBASE::PrecacheSound( CSCZBASE::EMPTY_RIFLE_S );
		CSCZBASE::PrecacheSounds( WeaponSoundEvents );
		//Sprites
		CommonSpritePrecache();
		g_Game.PrecacheGeneric( CSCZBASE::MAIN_SPRITE_DIR + CSCZBASE::MAIN_CSTRIKE_DIR + SPR_CAT + self.pev.classname + ".txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= (CSCZBASE::ShouldUseCustomAmmo) ? MAX_CARRY : CSCZBASE::DF_MAX_CARRY_357;
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
		return Deploy( V_MODEL, P_MODEL, DRAW, "sniper", GetBodygroup(), (30.0/30.0) );
	}

	bool PlayEmptySound()
	{
		return CommonPlayEmptySound( CSCZBASE::EMPTY_RIFLE_S );
	}

	void Holster( int skiplocal = 0 )
	{
		CommonHolster();

		BaseClass.Holster( skiplocal );
	}

	void PrimaryAttack()
	{
		if( self.m_iClip <= 0 || m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		Vector vecSpread;

		if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
		{
			vecSpread = VECTOR_CONE_2DEGREES * 2.45f * (m_iShotsFired * 0.35f);
		}
		else if( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			vecSpread = VECTOR_CONE_1DEGREES * 2.15f * (m_iShotsFired * 0.3f);
		}
		else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
		{
			vecSpread = VECTOR_CONE_1DEGREES * 1.04f;
		}
		else
		{
			vecSpread = VECTOR_CONE_1DEGREES * 1.05f * (m_iShotsFired * 0.4f);
		}

		vecSpread = (WeaponZoomMode != CSCZBASE::MODE_FOV_NORMAL) ? vecSpread * (m_iShotsFired * 0.22f) : vecSpread * (m_iShotsFired * 0.17f); // do vector math calculations here to make the Spread worse

		if( m_iShotsFired > 9 )
			m_iShotsFired = 9;

		self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0f;

		ShootWeapon( SHOOT_S, 1, vecSpread, MAX_SHOOT_DIST, DAMAGE );

		if( WeaponZoomMode == CSCZBASE::MODE_FOV_NORMAL )
			self.SendWeaponAnim( SHOOT1 + Math.RandomLong( 0, 1 ), 0, GetBodygroup() );

		m_pPlayer.m_iWeaponVolume = BIG_EXPLOSION_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		m_pPlayer.pev.punchangle.x -= g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed + 4, 0.75, 1.25 ) + m_pPlayer.pev.punchangle.x * 0.25;
		m_pPlayer.pev.punchangle.y += g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed + 5, -0.75, 0.75 );

		ShellEject( m_pPlayer, m_iShell, Vector( 21, 12, -9 ), true, false );
	}

	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.3f;
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, CSCZBASE::ZOOM_SOUND, 0.9, ATTN_NORM, 0, PITCH_NORM );

		switch( WeaponZoomMode )
		{
			case CSCZBASE::MODE_FOV_NORMAL:
			{
				WeaponZoomMode = CSCZBASE::MODE_FOV_ZOOM;

				ApplyFoVSniper( CSCZBASE::DEFAULT_ZOOM_VALUE, AIM_SPEED );

				m_pPlayer.pev.viewmodel = CSCZBASE::SCOPE_MODEL;
				self.SendWeaponAnim( CSCZBASE::SCP_IDLE_FOV40, 0, GetBodygroup() );
				break;
			}
			case CSCZBASE::MODE_FOV_ZOOM:
			{
				WeaponZoomMode = CSCZBASE::MODE_FOV_2X_ZOOM;

				ApplyFoVSniper( CSCZBASE::DEFAULT_2X_ZOOM_VALUE, AIM_SPEED );

				m_pPlayer.pev.viewmodel = CSCZBASE::SCOPE_MODEL;
				self.SendWeaponAnim( CSCZBASE::SCP_IDLE_FOV15, 0, GetBodygroup() );
				break;
			}
			case CSCZBASE::MODE_FOV_2X_ZOOM:
			{
				WeaponZoomMode = CSCZBASE::MODE_FOV_NORMAL;

				m_pPlayer.pev.viewmodel = V_MODEL;
				self.SendWeaponAnim( IDLE, 0, GetBodygroup() );
				ResetFoV();
				break;
			}
		}
	}

	void Reload()
	{
		if( self.m_iClip == MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		if( WeaponZoomMode != CSCZBASE::MODE_FOV_NORMAL )
		{
			WeaponZoomMode = CSCZBASE::MODE_FOV_NORMAL;
			m_pPlayer.pev.viewmodel = V_MODEL;
			ResetFoV();
		}

		Reload( MAX_CLIP, RELOAD, (106.0/28.0), GetBodygroup() );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flNextPrimaryAttack + 0.4f < g_Engine.time )
			m_iShotsFired = 0;

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if( WeaponZoomMode == CSCZBASE::MODE_FOV_NORMAL )
			self.SendWeaponAnim( IDLE, 0, GetBodygroup() );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class SG550_MAG : ScriptBasePlayerAmmoEntity, CSCZBASE::AmmoBase
{
	void Spawn()
	{
		Precache();

		CommonSpawn( A_MODEL, MAG_BDYGRP );
		self.pev.scale = 1;
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
		return CommonAddAmmo( pOther, MAX_CLIP, (CSCZBASE::ShouldUseCustomAmmo) ? MAX_CARRY : CSCZBASE::DF_MAX_CARRY_357, (CSCZBASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CSCZBASE::DF_AMMO_357 );
	}
}

string GetAmmoName()
{
	return "ammo_csczsg550";
}

string GetName()
{
	return "weapon_csczsg550";
}

void Register()
{
	CSCZBASE::RegisterCWEntity( "CSCZ_SG550::", "weapon_csczsg550", GetName(), GetAmmoName(), "SG550_MAG", 
		CSCZBASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CSCZBASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CSCZBASE::DF_AMMO_357 );
}

}