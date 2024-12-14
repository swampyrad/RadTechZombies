// ------------------------------------------------------------
// Sten guy, is sneaky and has a silenced weapon
//   ------------------------------------------------------------
class StenZombie:HDHumanoid{
	//tracking ammo
	int chamber;
	int thismag;
 
	int firemode; //based on the old pistol method: -1=semi only, 0=semi selected, 1=full auto

	double spread;

	override void postbeginplay(){
		super.postbeginplay();
  
    givearmour(1.);//wears a vest just like the SS guards
  
		bhasdropped=false;
		aimpoint1=(-1,-1);
		aimpoint2=(-1,-1);

    //random chance to spawn with a Sten or a Hushpuppy
    firemode=randompick(0,0,1,1,0,0);

    if(firemode==0){//silenced pistol
		  thismag=random(7,15);
		}else if(firemode==1){//silenced Sten
		  thismag=random(15,29);
		  firemode=1;//Sten is always full-auto
		}
		
		chamber=2;
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
		if(bhasdropped)//chance to drop ammo if died more than once
		{
		  if(firemode==1)
			  DropNewItem("HD9mMag30",96);
			else if(firemode==0)
			  DropNewItem("HD9mMag15",96);
		}
 		else//drop weapon and ammo on first death
		{
			bhasdropped=true;
			
			//drop a SMG if Sten spawns disabled
			if(firemode==1){
    	  if (sten_clipbox_spawn_bias == -1)
			  {
				  let ppp=DropNewWeapon("HDSMG");
				  ppp.weaponstatus[SMGS_MAG]=thismag;
				  ppp.weaponstatus[SMGS_CHAMBER]=chamber;
				  ppp.weaponstatus[SMGS_AUTO]=2;
    			DropNewItem("HD9mMag30",256);
			  }//otherwise drop a Sten
			  else
			  {
				  let ppp=DropNewWeapon("HDStenMk2");
				  ppp.weaponstatus[STENS_MAG]=thismag+chamber/2;
				  ppp.weaponstatus[STENS_CHAMBER]=0;
				  ppp.weaponstatus[STENS_AUTO]=2;//drop with full-auto enabled
    			DropNewItem("HD9mMag30",256);
			  }//drop a pistol if Hushpuppy spawns are disabled
		  }else if(firemode==0){
			  if(hushpuppy_clipbox_spawn_bias == -1
			      &&hushpuppy_pistol_spawn_bias == -1
			    )
			  {
				  let ppp=DropNewWeapon("HDPistol");
				  ppp.weaponstatus[PISS_MAG]=thismag;
				  ppp.weaponstatus[PISS_CHAMBER]=chamber;
    		  DropNewItem("HD9mMag15",256);
			  }//otherwise drop a Hushpuppy
			  else
			  {
				  let ppp=DropNewWeapon("HushPuppyPistol");
				  ppp.weaponstatus[PUPPY_MAG]=thismag;
				  ppp.weaponstatus[PUPPY_CHAMBER]=chamber;
				  ppp.weaponstatus[0]|=PUPF_FIREMODE;//drop with slidelock disabled
    		  DropNewItem("HD9mMag15",256);
			  }
			}
		}
	}

	void A_StenGuyUnload(int which=0){
		if(thismag>=0)
		{
			actor aaa;int bbb;
			if(firemode==1)//drop an SMG mag if using a Sten
			[bbb,aaa]=A_SpawnItemEx("HD9mMag30",
				cos(pitch)*10,0,height-8-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);//drop a pistol mag if using a Hushpuppy
			else 	if(firemode==0)[bbb,aaa]=A_SpawnItemEx("HD9mMag15",
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
		
		if(firemode==1)//Sten
		  thismag=30;
		else 	if(firemode==0)//Hushpuppy
		  thismag=15;
		  
		A_StartSound("weapons/pismagclick",8);
		return true;
	}

	//defaults and states
	default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Sten Zombie"
		//$Sprite "POSSA1"

    +ambush //don't move until you see the player

		seesound "stenzombie/sight";
		painsound "stenzombie/pain";
		deathsound "stenzombie/death";
		activesound "stenzombie/active";
		tag "$STEN_ZOMBIE";
		
		hdmobbase.stepsound "stenzombie/step";
		//"mein fuhrer, i'm trying to sneak around, but i'm fash and fabulous,
    // and the click from my heels keeps alerting the amerikaner"

		radius 10;
		speed 15;
		mass 100;
		painchance 200;
		obituary "%o was silenced by an elite guard.";
		hitobituary "%o was knocked out by an elite guard.";
		
		translation "192:207=103:111","240:247=5:8";
		//changes blue uniform to black
	}
	states{
	spawn:
		SSEG A 1{
			A_HDLook();
			A_Recoil(frandom(-0.1,0.1));
			if(target)A_ClearTarget();//forget target so they can hide and wait for them to show up again
		}
		#### AAA random(5,17) A_HDLook();
		#### A 1{
			A_Recoil(frandom(-0.1,0.1));
			A_SetTics(random(10,40));
		}
		#### B 0 A_JumpIf(noammo(),"reload");
		#### B 0 A_Jump(132,"spawnswitch");
		#### B 6 A_Recoil(frandom(-0.2,0.2));
		loop;
	spawnswitch:
		#### A 0 A_JumpIf(bambush,"spawnstill");
		goto spawnwander;
	spawnstill:
		#### A 0 A_Look();
		#### A 0 A_Recoil(random(-1,1)*0.4);
		#### CD 6 A_SetAngle(angle+random(-4,4));
		#### A 0 A_Look();
		#### AB 8 A_SetAngle(angle+random(-4,4));
		#### B 1 A_SetTics(random(10,40));
		#### A 0 A_Jump(256,"spawn");
	spawnwander:
		#### CDAB 10 A_HDWander();
		#### A 0 A_Jump(64,"spawn");
		loop;

	see:
		#### ABCD random(5,6) A_HDChase();
		#### A 0 A_JumpIf(noammo(),"reload");
		#### A 0 A_JumpIf(target&&!checksight(target),"spawn");//wait around if target is out of sight
		loop;
	missile:
		#### CD 5 A_TurnTowardsTarget();
		loop;
	shoot:
    #### F 3;//takes a bit longer to start aiming
		#### F 3 A_LeadTarget(1);
		#### F 1 A_LeadTarget(2);
		#### F 2 A_LeadAim(500,3);
	fire:
		#### G 1 bright light("SHOT") A_StenGuyAttack();
	postshot:
		#### F 4 A_SetTics(random(4,5));
		#### E 0 A_JumpIf(thismag<1||!target,"nope");
		#### E 0{
			if(//increase spread if using full-auto
				firemode>0
			){
				pitch+=frandom(-2.4,2);
				angle+=frandom(-2,2);
			}else A_SetTics(random(6,8));
		}//random chance to run away after shooting
		#### E 0 A_JumpIf(!random(0,9), "retreat");
		#### E 0 A_HDMonsterRefire("see",25);
		goto fire;
	nope:
		#### F 10;
	reload:
		SSEG CD 5 A_HDChase("melee",null,CHF_FLEE);
		#### A 7 A_StenGuyUnload();
		#### BC 5 A_HDChase("melee",null,CHF_FLEE);
		#### D 8 A_HDReload();
		---- A 0 setstatelabel("see");

	pain:
		SSEG H 1;
		#### H 4 A_Vocalize(painsound);
		#### H 0{
			A_ShoutAlert(0.1,SAF_SILENT);
			//random chance to dodge and return fire immediately
			if(
				floorz==pos.z
				&&target
				&&(
					!random(0,3)
					||distance3d(target)<128
				)
			){
				double ato=angleto(target)+randompick(-90,90);
				vel+=((cos(ato),sin(ato))*speed,1.);
				setstatelabel("missile");
			}else bfrightened=true;
		}
		#### H 0 A_JumpIf(!random(0,3)||health<=50,"retreat");//chance to retreat after getting hurt
		#### ABCD 3 A_HDChase();
		#### A 0{bfrightened=false;}
		---- A 0 setstatelabel("see");
	retreat:
	  	#### A 0{bfrightened=true;}
			#### AABBCCDD 2 A_HDChase();
			#### A 0 A_JumpIf(!random(0,3), "retreat");
			#### ABCD 3 A_HDChase();
		  #### A 0{bfrightened=false;}
			#### A 0 A_JumpIf(target&&!checksight(target), "spawnstill");//lie in wait until player is visible again
	    ---- A 0 setstatelabel("see");
	    
	death:
		SSEG I 5;
		#### J 5 A_Vocalize(deathsound);
		#### K 5 A_NoBlocking();
		#### L 5;
	dead:
		SSEG L 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### M 5 canraise{if(abs(vel.z)>=2.)setstatelabel("dead");}
		wait;
	deadgib:
		SSEG N 5;
		SSEG O 5{
			A_GibSplatter();
			A_XScream();
		}
		#### PQRSTU 5;
		goto gibbed;
	gib:
		SSEG N 5 A_GibSplatter();
		SSEG O 0 A_GibSplatter();
		SSEG O 5 A_XScream();
		SSEG PQ 5 A_GibSplatter();
		SSEG RSTU 5;
	gibbed:
		SSEG U 3 canraise A_JumpIf(abs(vel.z)<2,1);
		wait;
		SSEG V 5 canraise A_JumpIf(abs(vel.z)>=2,"gibbed");
		wait;
	raise:
		SSEG M 4;
		SSEG MLK 6;
		SSEG JIH 4;
		---- A 0 setstatelabel("see");
	ungib:
		SSEG V 4;
		SSEG VUT 8;
		SSEG SRQ 6;
		SSEG PON 4;
		SSEG A 0;
		---- A 0 setstatelabel("see");
	}
	//heal player if punched to death
	override void die(actor source,actor inflictor,int dmgflags){
		if(
			bplayingid
			&&source
			&&source==inflictor
			&&source.player
			&&HDFist(source.player.readyweapon)
		){
			source.A_StartSound("nazi/punched",19450430,CHANF_OVERLAP);
			let ppp=hdplayerpawn(source);
			if(!ppp)source.givebody(20);
			else{
				let www=HDBleedingWound.FindBiggest(ppp,HDBW_FINDPATCHED|HDBW_FINDhealing);
				if(!!www)www.destroy();
				ppp.bloodloss-=50;
				ppp.aggravateddamage-=max(1,ppp.aggravateddamage>>3);
				ppp.fatigue>>=1;
				ppp.stunned=0;
				ppp.givebody(6);
			}
		}
		super.die(source,inflictor,dmgflags);
	}
}

class StenZombie_Black:StenZombie{
  default{
    translation "192:207=103:111","240:247=5:8","161:163=109:111","164:166=5:7";
		//changes blue uniform and blonde hair to black
	}
}

class StenZombie_Red:StenZombie{
  default{
    translation "192:207=103:111","240:247=5:8","161:163=221:223","164:166=233:235";
		//changes blue uniform to black and blonde hair to red
	}
}

class StenZombie_Brown:StenZombie{
  default{
    translation "192:207=103:111","240:247=5:8","161:166=74:79";
		//changes blue uniform to black and blonde hair to brown
	}
}

//spawn with random hair color, so they don't all look the same
class StenZombieSpawner:RandomSpawner{
	default{
		dropitem "StenZombie",256,10;
		dropitem "StenZombie_Black",256,10;
		dropitem "StenZombie_Red",256,10;
		dropitem "StenZombie_Brown",256,10;
	}
}