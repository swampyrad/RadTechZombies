// ------------------------------------------------------------
// Sten guy, is sneaky and has a silenced SMG
//   ------------------------------------------------------------
class StenZombie:HDHumanoid{
	//tracking ammo
	int chamber;
	int thismag;
 
	int firemode; //based on the old pistol method: -1=semi only, 0=semi selected, 1=full auto

	double spread;


	//specific to undead homeboy
	int user_weapon; //0 random, 1 semi, 2 auto

	override void postbeginplay(){
		super.postbeginplay();
        A_SetTranslation("StenZombie");
		bhasdropped=false;
		aimpoint1=(-1,-1);
		aimpoint2=(-1,-1);

		//specific to undead homeboy
		thismag=random(15,30);
		chamber=0;
		if(
			user_weapon==2
			||(
				user_weapon!=1
				&&!random(0,8)
			)
		)firemode=randompick(0,0,0,1);
		else firemode=-1;
	}
	virtual bool noammo(){
		return thismag<1;
	}


	/*
	These functions were originally meant to be a prototype for a lot of generalized
	monster attack functions. As of this last review (2021-07) I am abandoning
	that idea since each monster has such specialized attacks that it's better
	to customize each one separately, with a few common specific complex calculations
	like HDMobAI.DropAdjust that are too tedious to repeat.
	*/

	void A_TurnTowardsTarget(
		statelabel shootstate="shoot",
		double maxturn=20,
		double maxvariance=20
	){
		A_FaceTarget(maxturn,maxturn);
		if(
			!target
			||maxvariance>absangle(angle,angleto(target))
			||!checksight(target)
		)setstatelabel(shootstate);
		if(bfloat||floorz>=pos.z)A_ChangeVelocity(0,frandom(-0.1,0.1)*speed,0,CVF_RELATIVE);
	}



	//aiming and leading targets
	vector2 aimpoint1;
	vector2 aimpoint2;
	int aimpointtics;

	void A_LeadTarget(int phase){
		vector2 ap;
		if(target){
			double dist=distance2d(target);
			ap=(
				angleto(target),
				atan2(
					pos.z-target.pos.z,
					distance2d(target)
				)
			);
		}else ap=(angle,pitch);
		if(phase==2)aimpoint2=ap;
		else aimpoint1=ap;
	}
	void A_LeadAim(double missilespeed,int inleadtics=1,vector3 destpos=(-32000,0,0)){
		double dist;
		if(destpos==(-32000,0,0)){
			if(!target)return;
			destpos=target.pos;
		}
		vector2 apadj=(aimpoint2-aimpoint1)/inleadtics;

		dist=(level.vec3offset(pos,destpos)).length();
		double ticstolead=dist/missilespeed;

		//the calcs are typically done while there's a little inertia,
		//so best to re-center a little fore applying them
		A_FaceTarget(1,1);

		//put it all together
		pitch+=apadj.y*ticstolead;
		angle+=apadj.x*ticstolead;

		//fidget with the fire selector
		if(firemode>=0)firemode=randompick(0,0,0,1);
	}

    void A_Eject9mmCasing(){
		HDWeapon.EjectCasing(self,"HDSpent9mm",
      -frandom(89,92),
      (frandom(6,7),0,0),(13,0,0));
	}

	//post-shot checks
	void A_HDMonsterRefire(statelabel jumpto,int chancetocontinue=0){
		if(
			random(1,100)>chancetocontinue
			&&(
				!target
				||!checksight(target)
				||target.health<1
				||absangle(angle,angleto(target))>3
				||!hdmobai.tryshoot(self,flags:hdmobai.TS_GEOMETRYOK)
			)
		)setstatelabel(jumpto);
	}


	//will routinely be overridden
	void A_StenGuyAttack(){
		if(chamber<2){
			if(chamber>0)A_Eject9mmCasing();
			if(thismag>0){
				chamber=2;
				thismag--;
			}
			setstatelabel("postshot");
			return;
		}

		pitch+=frandom(0,spread)-frandom(0,spread);
		angle+=frandom(0,spread)-frandom(0,spread);
		HDBulletActor.FireBullet(self,"HDB_9",spread:3.,speedfactor:frandom(0.83,0.89));

		A_StartSound("weapons/sten",CHAN_WEAPON);
		pitch+=frandom(-0.4,0.3);
		angle+=frandom(-0.4,0.4);

		A_Eject9mmCasing();
		if(thismag>0)thismag--;
		else chamber=0;
	}
	override void deathdrop(){
		if(bhasdropped)
		{
			DropNewItem("HD9mMag30",96);
		}
 		else
		{
			bhasdropped=true;
    		if (sten_clipbox_spawn_bias == -1)
			{
				let ppp=DropNewWeapon("HDSMG");
				ppp.weaponstatus[STENS_MAG]=thismag;
				ppp.weaponstatus[STENS_CHAMBER]=chamber;
    			DropNewItem("HD9mMag30",96);
				if(firemode>=0)
				{
					//ppp.weaponstatus[0]|=PISF_SELECTFIRE;
					if(firemode>0)ppp.weaponstatus[0]|=PISF_FIREMODE;
				}
			}
			else
			{
				let ppp=DropNewWeapon("HDStenMk2");
				ppp.weaponstatus[STENS_MAG]=thismag+chamber/2;
				ppp.weaponstatus[STENS_CHAMBER]=0;
    			DropNewItem("HD9mMag30",96);
				if(firemode>=0)
				{
					//ppp.weaponstatus[0]|=PISF_SELECTFIRE;
					if(firemode>0)ppp.weaponstatus[0]|=PISF_FIREMODE;
				}
			}
		}
	}

	void A_StenGuyUnload(int which=0){
		if(thismag>=0)
		{
			actor aaa;int bbb;
			[bbb,aaa]=A_SpawnItemEx("HD9mMag30",
				cos(pitch)*10,0,height-8-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
			hdmagammo(aaa).mags.clear();
			hdmagammo(aaa).mags.push(thismag);
			A_StartSound("weapons/pismagclick",8);
		}
		thismag=-1;
	}
	bool A_HDReload(int which=0){
		if(thismag>=0)return false;
		thismag=30;
		
		A_StartSound("weapons/pismagclick",8);
		return true;
	}


	//defaults and states
	default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Sten Zombie"
		//$Sprite "POSSA1"

		seesound "stenzombie/sight";
		painsound "stenzombie/pain";
		deathsound "stenzombie/death";
		activesound "stenzombie/active";
		tag "$STEN_ZOMBIE";

		radius 10;
		speed 12;
		mass 100;
		painchance 200;
		obituary "%o was silenced by a Sten zombie.";
		hitobituary "%o was bludgeoned by a Sten zombie.";
	}
	states{
	spawn:
		POSS E 1{
			A_HDLook();
			A_Recoil(frandom(-0.1,0.1));
		}
		#### EEE random(5,17) A_HDLook();
		#### E 1{
			A_Recoil(frandom(-0.1,0.1));
			A_SetTics(random(10,40));
		}
		#### B 0 A_JumpIf(noammo(),"reload");
		#### B 0 A_Jump(28,"spawngrunt");
		#### B 0 A_Jump(132,"spawnswitch");
		#### B 8 A_Recoil(frandom(-0.2,0.2));
		loop;
	spawngrunt:
		POSS G 1{
			A_Recoil(frandom(-0.4,0.4));
			A_SetTics(random(30,80));
			//if(!random(0,7))A_Vocalize(activesound);
		}
		#### A 0 A_Jump(256,"spawn");
	spawnswitch:
		#### A 0 A_JumpIf(bambush,"spawnstill");
		goto spawnwander;
	spawnstill:
		#### A 0 A_Look();
		#### A 0 A_Recoil(random(-1,1)*0.4);
		#### CD 5 A_SetAngle(angle+random(-4,4));
		#### A 0{
			A_Look();
		//if(!random(0,127))A_Vocalize(activesound);
		}
		#### AB 5 A_SetAngle(angle+random(-4,4));
		#### B 1 A_SetTics(random(10,40));
		#### A 0 A_Jump(256,"spawn");
	spawnwander:
		#### CDAB 5 A_HDWander();
		#### A 0 A_Jump(64,"spawn");
		loop;

	see:
		#### ABCD random(3,4) A_HDChase();
		#### A 0 A_JumpIf(noammo(),"reload");
		loop;
	missile:
		#### ABCD 3 A_TurnTowardsTarget();
		loop;
	shoot:
        #### E 3;//takes a bit longer to start aiming
		#### E 3 A_LeadTarget(1);
		#### E 1 A_LeadTarget(2);
		#### E 2 A_LeadAim(500,3);
	fire:
		#### F 1 bright light("SHOT") A_StenGuyAttack();
	postshot:
		#### E 3;//adding a tic here
		#### E 0 A_JumpIf(thismag<1||!target,"nope");
		#### E 0{
			if(
				firemode>0
			){
				pitch+=frandom(-2.4,2);
				angle+=frandom(-2,2);
			}else A_SetTics(random(6,10));
		}
		#### E 0 A_JumpIf(!random(0,9), "retreat");
		#### E 0 A_HDMonsterRefire("see",25);
		goto fire;
	nope:
		#### E 10;
	reload:
		POSS ABCD 2 A_HDChase("melee",null,CHF_FLEE);
		#### A 7 A_StenGuyUnload();
		#### BC 6 A_HDChase("melee",null,CHF_FLEE);
		#### D 8 A_HDReload();
		---- A 0 setstatelabel("see");

	pain:
		POSS G 2;
		#### G 3 A_Vocalize(painsound);
		#### G 0{
			A_ShoutAlert(0.1,SAF_SILENT);
			if(
				floorz==pos.z
				&&target
				&&(
					!random(0,4)
					||distance3d(target)<128
				)
			){
				double ato=angleto(target)+randompick(-90,90);
				vel+=((cos(ato),sin(ato))*speed,1.);
				setstatelabel("missile");
			}else bfrightened=true;
		}
		#### ABCD 2 A_HDChase();
		#### G 0{bfrightened=false;}
		---- A 0 setstatelabel("see");
	retreat:
	  	#### G 0{bfrightened=true;}
			#### ABCDABCD 1 A_HDChase();
			#### G 0 A_JumpIf(!random(0,3), "retreat");
			#### ABCDABCD 1 A_HDChase();
		  #### G 0{bfrightened=false;}
			#### G 0 A_JumpIf(!target, "spawnwander");
	    ---- A 0 setstatelabel("see");
	death:
		POSS H 5;
		POSS I 5 A_Vocalize(deathsound);
		#### J 5 A_NoBlocking();
		#### K 5;
	dead:
		POSS K 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### L 5 canraise{if(abs(vel.z)>=2.)setstatelabel("dead");}
		wait;
	deadgib:
		POSS M 5;
		POSS N 5{
			A_GibSplatter();
			A_XScream();
		}
		#### OPQRST 5;
		goto gibbed;
	gib:
		POSS M 5;
		POSS N 5{
			A_GibSplatter();
			A_XScream();
		}
		#### O 0 A_NoBlocking();
		#### OP 5 A_GibSplatter();
		#### QRST 5;
		goto gibbed;
	gibbed:
		POSS T 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### U 5 canraise A_JumpIf(abs(vel.z)>=2.,"gibbed");
		wait;
	raise:
		POSS L 4;
		#### LK 6;
		#### JI 4;
		POSS H 4;
		#### A 0 A_Jump(256,"see");
	ungib:
		POSS U 12;
		#### T 8;
		#### SRQ 6;
		#### PON 4;
		POSS M 4;
		#### A 0 A_Jump(256,"see");
	}
}
