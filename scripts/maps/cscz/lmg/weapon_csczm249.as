// Counter-Strike Condition Zero FN M249 SAW
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

namespace CSCZ_M249
{

// Animations
enum CSCZ_M249_Animation
{
	IDLE = 0,
	SHOOT1,
	SHOOT2,
	RELOAD,
	DRAW
};

// Models
string W_MODEL  	= "models/csczsven/wpn/m249/w_m249.mdl";
string V_MODEL  	= "models/csczsven/wpn/m249/v_m249.mdl";
string P_MODEL  	= "models/csczsven/wpn/m249/p_m249.mdl";
string A_MODEL  	= "models/csczsven/ammo/mags.mdl";
int MAG_BDYGRP  	= 5;
// Sprites
string SPR_CAT  	= "lmg/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"csczsven/g18/slideback1.wav",
					"csczsven/m249/boxin.wav",
					"csczsven/m249/boxout.wav",
					"csczsven/m249/chain.wav",
					"csczsven/m249/open.wav",
					"csczsven/m249/close.wav"
};
string SHOOT_S  	= "csczsven/m249/shoot.wav";
// Information
int MAX_CARRY   	= 500;
int MAX_CLIP    	= 100;
int DEFAULT_GIVE 	= MAX_CLIP * 2;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 23;
uint SLOT       	= 7;
uint POSITION   	= 4;
uint MAX_SHOOT_DIST	= 8192;
float RPM       	= 0.1f;
string AMMO_TYPE 	= "CSCZ_5.56ap";

//Buy Menu Information
string WPN_NAME 	= "FN M249 SAW";
uint WPN_PRICE  	= 600;
string AMMO_NAME 	= "M249 5.56 NATO Box";
uint AMMO_PRICE  	= 100;

class weapon_csczm249 : ScriptBasePlayerWeaponEntity, CSCZBASE::WeaponBase
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
		m_iShell = g_Game.PrecacheModel( CSCZBASE::SHELL_RIFLE );
		//Entity
		g_Game.PrecacheOther( GetAmmoName() );
		//Sounds
		CSCZBASE::PrecacheSound( SHOOT_S );
		CSCZBASE::PrecacheSound( CSCZBASE::EMPTY_RIFLE_S );
		CSCZBASE::PrecacheSounds( WeaponSoundEvents );
		//Sprites
		CommonSpritePrecache();
		g_Game.PrecacheGeneric( CSCZBASE::MAIN_SPRITE_DIR + CSCZBASE::MAIN_CSTRIKE_DIR + SPR_CAT + self.pev.classname + ".txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= (CSCZBASE::ShouldUseCustomAmmo) ? MAX_CARRY : CSCZBASE::DF_MAX_CARRY_556;
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
		return Deploy( V_MODEL, P_MODEL, DRAW, "saw", GetBodygroup(), (30.0/30.0) );
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
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		Vector vecSpread;

		if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
		{
			vecSpread = VECTOR_CONE_1DEGREES * 3.545f * (m_iShotsFired * 0.5);
		}
		else if( m_pPlayer.pev.velocity.Length2D() > 140 )
		{
			vecSpread = VECTOR_CONE_1DEGREES * 2.14f * (m_iShotsFired * 0.3);
		}
		else
		{
			vecSpread = VECTOR_CONE_1DEGREES * 1.93f * (m_iShotsFired * 0.2);
		}

		vecSpread = vecSpread * (m_iShotsFired * 0.35f);

		if( m_iShotsFired > 7 )
			m_iShotsFired = 7;

		self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0f;

		self.SendWeaponAnim( SHOOT1 + Math.RandomLong( 0, 1 ), 0, GetBodygroup() );

		ShootWeapon( SHOOT_S, 1, vecSpread, MAX_SHOOT_DIST, DAMAGE );

		if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
		{
			KickBack( 1.8, 0.65, 0.45, 0.125, 5.0, 3.5, 8 );
		}
		else if( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 1.1, 0.5, 0.3, 0.06, 4.0, 3.0, 8 );
		}
		else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
		{
			KickBack( 0.75, 0.325, 0.25, 0.025, 3.5, 2.5, 9 );
		}
		else
		{
			KickBack( 0.8, 0.35, 0.3, 0.03, 3.75, 3.0, 9 );
		}

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		ShellEject( m_pPlayer, m_iShell, Vector( 13, 9, -5 ), false, false );
	}

	void Reload()
	{
		if( self.m_iClip == MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		Reload( MAX_CLIP, RELOAD, (140.0/30.0), GetBodygroup() );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flNextPrimaryAttack + 0.2f < g_Engine.time )
			m_iShotsFired = 0;

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( IDLE, 0, GetBodygroup() );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class M249_MAG : ScriptBasePlayerAmmoEntity, CSCZBASE::AmmoBase
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
		return CommonAddAmmo( pOther, MAX_CLIP, (CSCZBASE::ShouldUseCustomAmmo) ? MAX_CARRY : CSCZBASE::DF_MAX_CARRY_556, (CSCZBASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CSCZBASE::DF_AMMO_556 );
	}
}

string GetAmmoName()
{
	return "ammo_csczm249";
}

string GetName()
{
	return "weapon_csczm249";
}

void Register()
{
	CSCZBASE::RegisterCWEntity( "CSCZ_M249::", "weapon_csczm249", GetName(), GetAmmoName(), "M249_MAG", 
		CSCZBASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CSCZBASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CSCZBASE::DF_AMMO_556 );
}

}