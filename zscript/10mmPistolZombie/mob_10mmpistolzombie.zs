// ------------------------------------------------------------
// 10mm Pistol guy
//   ------------------------------------------------------------
class TenMilHomeboy:HDHumanoid{
	//tracking ammo
	int chamber;
	int thismag;
 
	int firemode; //based on the old pistol method: -1=semi only, 0=semi selected, 1=full auto

	double spread;


	//specific to undead homeboy
	int user_weapon; //0 random, 1 semi, 2 auto

	override void postbeginplay(){
		super.postbeginplay();
        A_SetTranslation("TenMilZombie");
		bhasdropped=false;
		aimpoint1=(-1,-1);
		aimpoint2=(-1,-1);

		//specific to undead homeboy
		thismag=random(1,8);
		chamber=2;
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
		return chamber<1&&thismag<1;
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

    void A_Eject10mmPistolCasing(){
		HDWeapon.EjectCasing(self,"TenMilBrass",
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
	void A_PistolGuyAttack(){
		if(chamber<2){
			if(chamber>0)A_Eject10mmPistolCasing();
			if(thismag>0){
				chamber=2;
				thismag--;
			}
			setstatelabel("postshot");
			return;
		}

		pitch+=frandom(0,spread)-frandom(0,spread);
		angle+=frandom(0,spread)-frandom(0,spread);
		HDBulletActor.FireBullet(self,"HDB_10",spread:15.,speedfactor:frandom(0.97,1.03));

		A_StartSound("weapons/delta10mm",CHAN_WEAPON);
		pitch+=frandom(-0.4,0.3);
		angle+=frandom(-0.4,0.4);

		A_Eject10mmPistolCasing();
		if(thismag>0)thismag--;
		else chamber=0;
	}
	override void deathdrop(){
		if(bhasdropped && tenpis_pistol_spawn_bias == -1)
		{
			DropNewItem("HD9mMag15",96);
		}
		if (bhasdropped && tenpis_pistol_spawn_bias > -1)
		{
			DropNewItem("HD10mMag8", 96);
		}
 		else
		{
			bhasdropped=true;
    		if (tenpis_pistol_spawn_bias == -1)
			{
				let ppp=DropNewWeapon("HDPistol");
				ppp.weaponstatus[PISS_MAG]=thismag;
				ppp.weaponstatus[PISS_CHAMBER]=chamber;
    			DropNewItem("HD9mMag15",96);
				if(firemode>=0)
				{
					ppp.weaponstatus[0]|=PISF_SELECTFIRE;
					if(firemode>0)ppp.weaponstatus[0]|=PISF_FIREMODE;
				}
			}
			else
			{
				let ppp=DropNewWeapon("HD10mmPistol");
				ppp.weaponstatus[PISS_MAG]=thismag;
				ppp.weaponstatus[PISS_CHAMBER]=chamber;
    			DropNewItem("HD10mMag8",96);
				if(firemode>=0)
				{
					ppp.weaponstatus[0]|=PISF_SELECTFIRE;
					if(firemode>0)ppp.weaponstatus[0]|=PISF_FIREMODE;
				}
			}
		}
	}

	void A_PistolGuyUnload(int which=0){
		if(thismag>=0 && tenpis_pistol_spawn_bias == -1)
		{
			actor aaa;int bbb;
			[bbb,aaa]=A_SpawnItemEx("HD9mMag15",
				cos(pitch)*10,0,height-8-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
			hdmagammo(aaa).mags.clear();
			hdmagammo(aaa).mags.push(thismag);
			A_StartSound("weapons/pismagclick",8);
		}
		if(thismag>=0&& tenpis_pistol_spawn_bias < -1)
		{
			actor aaa;int bbb;
			[bbb,aaa]=A_SpawnItemEx("HD10mMag8",
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
		thismag=8;
		if(chamber<2){
			if(chamber>0)A_Eject10mmPistolCasing();
			chamber=2;
			thismag--;
		}
		A_StartSound("weapons/pismagclick",8);
		return true;
	}


	//defaults and states
	default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "10mm Pistol Zombie"
		//$Sprite "ZPISA1"

		seesound "tenmilhomeboy/sight";
		painsound "tenmilhomeboy/pain";
		deathsound "tenmilhomeboy/death";
		activesound "tenmilhomeboy/active";
		tag "$10MMZOMBIE_PISTOL";

		radius 10;
		speed 12;
		mass 100;
		painchance 200;
		obituary "%o got capped by a 10mm pistol zombie.";
		hitobituary "%o was gobsmacked by a 10mm pistol zombie.";
	}
	states{
	spawn:
		ZPIS E 1{
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
		ZPIS G 1{
			A_Recoil(frandom(-0.4,0.4));
			A_SetTics(random(30,80));
			if(!random(0,7))A_Vocalize(activesound);
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
			if(!random(0,127))A_Vocalize(activesound);
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
		#### F 1 bright light("SHOT") A_PistolGuyAttack();
	postshot:
		#### E 2;//adding a tic here
		#### E 0 A_JumpIf(chamber!=2||!target,"nope");
		#### E 0{
			if(
				firemode>0
			){
				pitch+=frandom(-2.4,2);
				angle+=frandom(-2,2);
				setstatelabel("shoot");//needs to aim after every shot
			}else A_SetTics(random(8,12));//raising this to lower magdump firerate
		}
		#### E 0 A_HDMonsterRefire("see",25);
		goto fire;
	nope:
		#### E 10;
	reload:
		ZPIS ABCD 4 A_HDChase("melee",null,CHF_FLEE);
		#### A 7 A_PistolGuyUnload();
		#### BC 6 A_HDChase("melee",null,CHF_FLEE);
		#### D 8 A_HDReload();
		---- A 0 setstatelabel("see");

	pain:
		ZPIS G 2;
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
	death:
		ZPIS H 5;
		ZPIS I 5 A_Vocalize(deathsound);
		#### J 5 A_NoBlocking();
		#### K 5;
	dead:
		ZPIS K 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### L 5 canraise{if(abs(vel.z)>=2.)setstatelabel("dead");}
		wait;
	deadgib:
		ZPIS M 5;
		ZPIS N 5{
			A_GibSplatter();
			A_XScream();
		}
		#### OPQRST 5;
		goto gibbed;
	gib:
		ZPIS M 5;
		ZPIS N 5{
			A_GibSplatter();
			A_XScream();
		}
		#### O 0 A_NoBlocking();
		#### OP 5 A_GibSplatter();
		#### QRST 5;
		goto gibbed;
	gibbed:
		ZPIS T 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### U 5 canraise A_JumpIf(abs(vel.z)>=2.,"gibbed");
		wait;
	raise:
		ZPIS L 4;
		#### LK 6;
		#### JI 4;
		ZPIS H 4;
		#### A 0 A_Jump(256,"see");
	ungib:
		ZPIS U 12;
		#### T 8;
		#### SRQ 6;
		#### PON 4;
		ZPIS M 4;
		#### A 0 A_Jump(256,"see");
	}
}
