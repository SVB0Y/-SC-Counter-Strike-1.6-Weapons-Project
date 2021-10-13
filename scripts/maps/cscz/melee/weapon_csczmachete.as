// Counter-Strike Condition Zero Machete
/* Model Credits
/ Model: Valve
/ Textures: Valve
/ Animations: Valve
/ Sounds: Valve
/ Sprites: Valve, SV BOY
/ Misc: Valve, D.N.I.O. 071, SV BOY
/ Script: KernCore 
/ Hand Rig: Mementocity, Garompa (Fixing, merging, additional rigs), Norman and DNIO071 (Remappable hands)
*/

#include "../base"

namespace CSCZ_MACHETE
{

// Animations
enum CSCZ_Machete_Animation
{
	IDLE = 0,
	SLASH1,
	SLASH2,
	DRAW,
	STAB,
	STABMISS,
	MIDSLASH1,
	MIDSLASH2
};

// Models
string W_MODEL  	= "models/csczsven/wpn/machete/w_machete.mdl";
string V_MODEL  	= "models/csczsven/wpn/machete/v_machete.mdl";
string P_MODEL  	= "models/csczsven/wpn/machete/p_machete.mdl";
// Sprites
string SPR_CAT  	= "melee/"; //Weapon category used to get the sprite's location
// Sounds
string STAB_S   	= "csczsven/machete/machete_stab.wav"; //stab
string DEPLOY_S 	= "csczsven/machete/machete_deploy1.wav"; //deploy1
string HITWALL_S 	= "csczsven/machete/machete_hitwall1.wav"; //hitwall1
array<string> 		KnifeHitFleshSounds = {
					"csczsven/machete/machete_hit1.wav",
					"csczsven/machete/machete_hit2.wav",
					"csczsven/machete/machete_hit3.wav",
					"csczsven/machete/machete_hit4.wav"
};
array<string> 		KnifeSlashSounds = {
					"csczsven/machete/machete_slash1.wav", //slash1
					"csczsven/machete/machete_slash2.wav"  //slash2
};
// Information
int MAX_CARRY   	= -1;
int MAX_CLIP    	= WEAPON_NOCLIP;
int DEFAULT_GIVE 	= 0;
int WEIGHT      	= 5;
int FLAGS       	= -1;
uint DAMAGE_SLASH 	= 40;
uint DAMAGE_STAB 	= 90;
uint SLOT       	= 0;
uint POSITION   	= 6;
string AMMO_TYPE 	= "";
float SLASH_DIST 	= 64.0f;
float STAB_DIST  	= 48.0f;

//Buy Menu Information
string WPN_NAME 	= "Machete";
uint WPN_PRICE  	= 300;

class weapon_csczmachete : ScriptBasePlayerWeaponEntity, CSCZBASE::WeaponBase, CSCZBASE::MeleeWeaponBase2
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int GetBodygroup()
	{
		return 0;
	}

	void Spawn()
	{
		Precache();
		//self.m_iClip = -1;
		self.m_flCustomDmg = self.pev.dmg;
		CommonSpawn( W_MODEL, DEFAULT_GIVE );
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		//Models
		g_Game.PrecacheModel( W_MODEL );
		g_Game.PrecacheModel( V_MODEL );
		g_Game.PrecacheModel( P_MODEL );
		//Sounds
		CSCZBASE::PrecacheSound( STAB_S );
		CSCZBASE::PrecacheSound( DEPLOY_S );
		CSCZBASE::PrecacheSound( HITWALL_S );
		CSCZBASE::PrecacheSounds( KnifeHitFleshSounds );
		CSCZBASE::PrecacheSounds( KnifeSlashSounds );
		//Sprites
		CommonSpritePrecache();
		g_Game.PrecacheGeneric( CSCZBASE::MAIN_SPRITE_DIR + CSCZBASE::MAIN_CSTRIKE_DIR + SPR_CAT + self.pev.classname + ".txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= MAX_CARRY;
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
		g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_ITEM, DEPLOY_S, 1, ATTN_NORM );
		return Deploy( V_MODEL, P_MODEL, DRAW, "crowbar", GetBodygroup(), (45.0/45.0) );
	}

	void Holster( int skiplocal = 0 )
	{
		CommonHolster();

		BaseClass.Holster( skiplocal );
	}

	void PrimaryAttack()
	{
		Swing( DAMAGE_SLASH, KnifeSlashSounds[Math.RandomLong( 0, KnifeSlashSounds.length() - 1)], KnifeHitFleshSounds[Math.RandomLong( 0, KnifeHitFleshSounds.length() - 1)], HITWALL_S,
			MIDSLASH1, MIDSLASH2, GetBodygroup(), SLASH_DIST );
	}

	void SecondaryAttack()
	{
		Stab( DAMAGE_STAB, KnifeSlashSounds[Math.RandomLong( 0, KnifeSlashSounds.length() - 1)], STAB_S, HITWALL_S, STABMISS, STAB, GetBodygroup(), STAB_DIST );
	}

	void WeaponIdle()
	{
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( IDLE, 0, GetBodygroup() );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + (150.0/12.0);
	}
}

string GetName()
{
	return "weapon_csczmachete";
}

void Register()
{
	CSCZBASE::RegisterCWEntityEX( "CSCZ_MACHETE::", "weapon_csczmachete", GetName(), "", CSCZBASE::MAIN_CSTRIKE_DIR + SPR_CAT, AMMO_TYPE );
}

}