// Counter-Strike Condition Zero Schmidt Scout (Steyr Scout)
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

namespace CSCZ_SCOUT
{

// Animations
enum CSCZ_Scout_Animations
{
	IDLE = 0,
	SHOOT1,
	SHOOT2,
	RELOAD,
	DRAW
};

// Models
string W_MODEL  	= "models/csczsven/wpn/scout/w_scout.mdl";
string V_MODEL  	= "models/csczsven/wpn/scout/v_scout.mdl";
string P_MODEL  	= "models/csczsven/wpn/scout/p_scout.mdl";
string A_MODEL  	= "models/csczsven/ammo/mags.mdl";
int MAG_BDYGRP  	= 4;
// Sprites
string SPR_CAT  	= "snip/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"csczsven/scout/blt.wav",
					"csczsven/scout/magout.wav",
					"csczsven/scout/magin.wav"
};
string SHOOT_S  	= "csczsven/scout/shoot.wav";
// Information
int MAX_CARRY   	= 300;
int MAX_CLIP    	= 10;
int DEFAULT_GIVE 	= MAX_CLIP * 4;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 56;
uint SLOT       	= 6;
uint POSITION   	= 4;
uint MAX_SHOOT_DIST	= 8192;
float RPM       	= 1.25f;
string AMMO_TYPE 	= "CSCZ_7.62nato";
float AIM_SPEED 	= 220;

//Buy Menu Information
string WPN_NAME 	= "Steyr Scout";
uint WPN_PRICE  	= 335;
string AMMO_NAME 	= "Scout 7.62 NATO Magazine";
uint AMMO_PRICE  	= 20;

class weapon_csczscout : ScriptBasePlayerWeaponEntity, CSCZBASE::WeaponBase
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int m_iShell;
	private CScheduledFunction@ CSRemoveBullet = null; //2 think functions can't work at the same time on the same object
	private int GetBodygroup()
	{
		return 0;
	}

	void Spawn()
	{
		Precache();
		CommonSpawn( W_MODEL, DEFAULT_GIVE );
		self.pev.scale = 1.15;
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		//Models
		g_Game.PrecacheModel( W_MODEL );
		g_Game.PrecacheModel( V_MODEL );
		g_Game.PrecacheModel( P_MODEL );
		g_Game.PrecacheModel( CSCZBASE::SCOPE_MODEL );
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
		info.iMaxAmmo1 	= (CSCZBASE::ShouldUseCustomAmmo) ? MAX_CARRY : CSCZBASE::DF_MAX_CARRY_M40A1;
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

	bool PlayEmptySound()
	{
		return CommonPlayEmptySound( CSCZBASE::EMPTY_RIFLE_S );
	}

	bool Deploy()
	{
		return Deploy( V_MODEL, P_MODEL, DRAW, "sniper", GetBodygroup(), (30.0/30.0) );
	}

	void Holster( int skiplocal = 0 )
	{
		g_Scheduler.RemoveTimer( CSRemoveBullet );
		@CSRemoveBullet = @null;

		CommonHolster();

		BaseClass.Holster( skiplocal );
	}

	void ReApplyFoVThink()
	{
		SetThink( null );

		if( self.m_iClip <= 0 || WeaponZoomMode == CSCZBASE::MODE_FOV_NORMAL )
			return;

		m_pPlayer.pev.viewmodel = CSCZBASE::SCOPE_MODEL;

		if( WeaponZoomMode == CSCZBASE::MODE_FOV_ZOOM )
		{
			ApplyFoVSniper( CSCZBASE::DEFAULT_ZOOM_VALUE, AIM_SPEED );
			self.SendWeaponAnim( CSCZBASE::SCP_IDLE_FOV40, 0, GetBodygroup() );
		}
		else if( WeaponZoomMode == CSCZBASE::MODE_FOV_2X_ZOOM )
		{
			ApplyFoVSniper( CSCZBASE::DEFAULT_2X_ZOOM_VALUE, AIM_SPEED );
			self.SendWeaponAnim( CSCZBASE::SCP_IDLE_FOV15, 0, GetBodygroup() );
		}
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
			vecSpread = VECTOR_CONE_4DEGREES * 2.2f * (m_iShotsFired * 0.75f);
		}
		else if( m_pPlayer.pev.velocity.Length2D() > 170 )
		{
			vecSpread = VECTOR_CONE_1DEGREES * 2.075f * (m_iShotsFired * 0.45f);
		}
		else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
		{
			vecSpread = VECTOR_CONE_1DEGREES;
		}
		else
		{
			vecSpread = VECTOR_CONE_1DEGREES * 1.07f * (m_iShotsFired * 0.4f);
		}

		vecSpread = (WeaponZoomMode != CSCZBASE::MODE_FOV_NORMAL) ? vecSpread * (m_iShotsFired * 0.225f) : vecSpread * (m_iShotsFired * 0.15f);

		if( WeaponZoomMode != CSCZBASE::MODE_FOV_NORMAL && self.m_iClip > 0 )
		{
			SetThink( null );

			m_pPlayer.pev.viewmodel = V_MODEL;
			ResetFoV();
			SetThink( ThinkFunction( this.ReApplyFoVThink ) );
			self.pev.nextthink = g_Engine.time + (45.0/35.0);
		}

		ShootWeapon( SHOOT_S, 1, vecSpread, MAX_SHOOT_DIST, DAMAGE, DMG_SNIPER );
		self.SendWeaponAnim( SHOOT1 + Math.RandomLong( 0, 1 ), 0, GetBodygroup() );

		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + RPM;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0f;

		m_pPlayer.m_iWeaponVolume = BIG_EXPLOSION_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		m_pPlayer.pev.punchangle.x -= 2;

		@CSRemoveBullet = @g_Scheduler.SetTimeout( @this, "BrassEjectThink", 0.56f );
	}

	void BrassEjectThink()
	{
		g_Scheduler.RemoveTimer( CSRemoveBullet );
		@CSRemoveBullet = @null;
		ShellEject( m_pPlayer, m_iShell, Vector( 13, 9, -8 ), true, false );
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

		Reload( MAX_CLIP, RELOAD, (60.0/30.0), GetBodygroup() );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flNextPrimaryAttack + 1.0f < g_Engine.time )
			m_iShotsFired = 0;

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if( WeaponZoomMode == CSCZBASE::MODE_FOV_NORMAL )
			self.SendWeaponAnim( IDLE, 0, GetBodygroup() );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class SCOUT_MAG : ScriptBasePlayerAmmoEntity, CSCZBASE::AmmoBase
{
	void Spawn()
	{
		Precache();

		CommonSpawn( A_MODEL, MAG_BDYGRP );
		self.pev.scale = 1.1;
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
		return CommonAddAmmo( pOther, MAX_CLIP, (CSCZBASE::ShouldUseCustomAmmo) ? MAX_CARRY : CSCZBASE::DF_MAX_CARRY_M40A1, (CSCZBASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CSCZBASE::DF_AMMO_M40A1 );
	}
}

string GetAmmoName()
{
	return "ammo_csczscout";
}

string GetName()
{
	return "weapon_csczscout";
}

void Register()
{
	CSCZBASE::RegisterCWEntity( "CSCZ_SCOUT::", "weapon_csczscout", GetName(), GetAmmoName(), "SCOUT_MAG", 
		CSCZBASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CSCZBASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CSCZBASE::DF_AMMO_M40A1 );
}

}