// ------------------------------------------------------------
// A.C.A.B.
// ------------------------------------------------------------
class RiotCopZombieReplacer:RandomSpawner{
	default{
		dropitem "RiotCopZombie",256,120;
	}
}

class RiotCopZombie:HDHumanoid{
	default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Riot Cop Shotgun Zombie"
		//$Sprite "RCOPA1"

    +ambush

		seesound "lesslethalcop/sight";
		painsound "lesslethalcop/pain";
		deathsound "lesslethalcop/death";
		activesound "lesslethalcop/active";
		tag "$UAC_POLICE_LESSLETHAL";

		speed 10;
		decal "BulletScratch";
		meleesound "weapons/smack";
		meleedamage 4;
		maxtargetrange 4000;
		painchance 200;
		accuracy 1;
		
		translation "112:116=194:196";

		obituary "%o thought less-lethal meant non-lethal.";
		hitobituary "%o was a victim of police brutality.";
	}
	bool semi;
	int gunloaded;
	int gunspent;
	int wep;
	int turnamount;
	int choke; //record here because the gun should only drop once
	double shotspread; //related to aim, NOT choke. Sorry about shitty names
	
	override void beginplay(){
		super.beginplay();
		bhasdropped=0;
  	wep=0;
	}
	
	override void postbeginplay(){
		super.postbeginplay();

		bhashelmet=false;
		sprite=GetSpriteIndex("RCOPA1");
		//A_SetTranslation("BlueBadge");
			
    gunloaded=random(2,6);
    givearmour(1.,0.06,-0.4);
    choke=0;//no choke 
  	semi=0;//no semiauto
  	jammed=false;//just in case
	}

	override void deathdrop(){
		A_NoBlocking();
		if(bhasdropped){
			if(!bfriendly && llh_hunter_spawn_bias > -1)
			{
				DropNewItem("LLShellPickup",200);
			}
			if(!bfriendly && llh_hunter_spawn_bias == -1)
			{
				DropNewItem("ShellPickup",200);
			}
		}else{
			DropNewItem("HDHandgunRandomDrop");
			bhasdropped=true;
			hdweapon wp=null;

			if(wep==0 && llh_hunter_spawn_bias == -1)
			{
				DropNewItem("ShellPickup");
			}
			if(wep==0 && llh_hunter_spawn_bias > -1)
			{
				wp=DropNewWeapon("LLHunter");
				if(wp){
					wp.weaponstatus[HUNTS_FIREMODE]=0;
					if(gunspent)wp.weaponstatus[HUNTS_CHAMBER]=1;
					else if(gunloaded>0){
						wp.weaponstatus[HUNTS_CHAMBER]=2;
						gunloaded--;
					}
					if(gunloaded>0)wp.weaponstatus[HUNTS_TUBE]=gunloaded;
					wp.weaponstatus[SHOTS_SIDESADDLE]=random(0,12);
					wp.weaponstatus[0]&=~HUNTF_CANFULLAUTO;
					wp.weaponstatus[HUNTS_CHOKE]=choke;

					gunloaded=6;
				}
			}
		}
		if(wep==0){
			gunloaded=6;//5+1
		}
	}
states{
	spawn:
		RCOP A 0;
	idle:
	spawn2:
		#### EEEEEE 1{
			A_HDLook();
			vel.xy-=(cos(angle),sin(angle))*frandom(-0.1,0.1);
			A_SetTics(random(1,10));
		}
		#### B 0 A_Jump(132,2,5,5,5,5);
		#### B 8{
			if(!random(0,1)){
				if(!random(0,4)){
					setstatelabel("spawnstretch");
				}else{
					if(bambush)setstatelabel("spawnstill");
					else setstatelabel("spawnwander");
				}
			}else vel.xy-=(cos(angle),sin(angle))*frandom(-0.2,0.2);
		}loop;
	spawnstretch:
		#### G 1{
			vel.xy-=(cos(angle),sin(angle))*frandom(-0.4,0.4);
			A_SetTics(random(30,80));
		}
	//	#### A 0 A_Vocalize(activesound);
		---- A 0 setstatelabel("spawn2");
	spawnstill:
		#### C 0{
			A_HDLook();
			vel.xy-=(cos(angle),sin(angle))*frandom(-0.4,0.4);
		}
		#### CD 5{angle+=random(-4,4);}
		#### A 0{
			A_HDLook();
		//	if(!random(0,15))A_Vocalize(activesound);
		}
		#### AB 5{angle+=random(-4,4);}
		#### B 1 A_SetTics(random(10,40));
		---- A 0 setstatelabel("spawn2");
	spawnwander:
		#### CD 5 A_HDWander();
		#### A 0 {
		//	if(!random(0,15))A_Vocalize(activesound);
			A_HDLook();
		}
		#### AB 5 A_HDWander();
		#### A 0 A_Jump(64,"spawn2");
		loop;

	see:
		#### A 0{
			if(jammed)return;
			else if(gunloaded<1)setstatelabel("reload");
			else if(!wep&&gunspent>0)setstatelabel("chambersg");
		}
		#### ABCD 4 A_HDChase();
		#### A 0 A_Jump(116,"roam","roam","roam","roam2","roam2");
		loop;
	roam:
		#### EEEE 3 A_Watch();
		#### A 0 A_Jump(60,"roam");
	roam2:
		#### A 0 A_JumpIf(targetinsight||!random(0,31),"see");
		#### ABCD 6 A_HDChase(speedmult:0.6);
		#### A 0 A_Jump(80,"roam");
		loop;

	missile:
		#### ABCD 3 A_TurnToAim(40,shootstate:"aiming");
		loop;
	aiming:
		#### E 1 A_StartAim(rate:0.88,maxtics:random(10,40));
		//fallthrough to shoot
	shoot:
		#### E 2 A_LeadTarget(tics);
		#### E 0{
			if(gunloaded<1){
				setstatelabel("ohforfuckssake");
				return;
			}
			angle+=frandom(0,spread)-frandom(0,spread);
			pitch+=frandom(0,spread)-frandom(0,spread);

			setstatelabel("shootsg");
		}

	
	shootsg:
		#### F 1 bright light("SHOT"){
			if(gunspent>0){
				setstatelabel("chambersg");
				return;
			}
			LLHunter.Fire(self,choke);
			semi=false;
			gunspent=1;
		}
		#### E 3;
		#### E 1{
			if(gunspent)setstatelabel("chambersg");
			else A_SetTics(random(3,8));
		}
		#### E 0 A_Jump(127,"see");
		#### E 0 A_Jump(32,"missile");
		---- A 0 setstatelabel("roam");
	chambersg:
		#### D 6{
			if(gunspent){
				A_SetTics(random(3,10));
				A_StartSound("weapons/huntrack",8);
				gunspent=0;
				if(gunloaded>0)gunloaded--;
				A_SpawnItemEx("HDLLSpentShell",
					cos(pitch)*8,0,height-7-sin(pitch)*8,
					vel.x+cos(pitch)*cos(angle-random(86,90))*6,
					vel.y+cos(pitch)*sin(angle-random(86,90))*6,
					vel.z+sin(pitch)*random(5,7),0,
					SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}
			
		}
		#### C 4;
		#### E 1 A_SetTics(random(3,8));
		#### E 0 A_Jump(127,"see");
		goto roam;

	jammed:
		#### E 8;
		#### E 0 A_Jump(128,"see");
		#### E 4 A_Vocalize(random(0,2)?seesound:painsound);
		---- A 0 setstatelabel("see");

	ohforfuckssake:
		#### E 6;
	reload:
		#### A 0 setstatelabel("reloadsg");
	
	reloadsg:
		#### A 2 A_HDChase("melee",null);
		#### A 0 A_StartSound("weapons/huntopen",8);
		#### BCDA 2 A_HDChase("melee",null,flags:CHF_FLEE);
	reloadsg2:
		#### BB 3 A_HDWander(flags:CHF_FLEE);
		#### B 0{
			gunloaded++;
			A_StartSound("weapons/huntreload",8);
			if(gunloaded>=6)setstatelabel("reloadsgend");
		}
		#### CC 3 A_HDWander(flags:CHF_FLEE);
		#### C 0{
			gunloaded++;
			A_StartSound("weapons/huntreload",8);
			if(gunloaded>=6)setstatelabel("reloadsgend");
		}
		#### DD 3 A_HDChase("melee",null,CHF_FLEE);
		#### D 0{
			gunloaded++;
			A_StartSound("weapons/huntreload",8);
			if(gunloaded>=6)setstatelabel("reloadsgend");
		}
		#### A 0 A_StartSound("weapons/pocket",9);
		#### ABCDA 2 A_HDWander();
		loop;
	reloadsgend:
		#### BCD 3 A_HDWander(flags:CHF_FLEE);
		#### A 0 A_StartSound("weapons/huntopen",8);
		#### E 4 A_HDChase("melee","missile",CHF_DONTMOVE);
		---- A 0 setstatelabel("see");

	pain:
		#### G 3 A_Jump(12,1);
		#### G 3 A_Vocalize(painsound);
		#### G 0{
			A_ShoutAlert(0.2,SAF_SILENT);
			if(target&&distance3d(target)<100)setstatelabel("see");
		}
		#### ABCD 2 A_HDChase(flags:CHF_FLEE);
		#### G 0{bfrightened=false;}
		---- A 0 setstatelabel("see");

	death:
		#### H 5;
		#### I 5 A_Vocalize(deathsound);
		#### JK 5;
	dead:
		#### K 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### L 5 canraise{if(abs(vel.z)>=2.)setstatelabel("dead");}
		wait;
	deadgib:
		SPOS M 0 A_JumpIf(wep<0,"xxxdeath2");
		#### M 5;
		#### N 5 A_XScream();
		#### OPQRST 5;
		goto gibbed;
	xxxdeath2:
		SPOS O 5;
		#### P 5 A_XScream();
		#### QRSTUV 5;
		goto xdead2;
	gib:
		SPOS M 0 A_JumpIf(wep<0,"xdeath2");
		#### M 5;
		#### N 5{
			A_GibSplatter();
			A_XScream();
		}
		#### OP 5 A_GibSplatter();
		#### QRST 5;
		goto gibbed;
	gibbed:
		#### T 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### U 5 canraise{if(abs(vel.z)>=2.)setstatelabel("gibbed");}
		wait;
	xdeath2:
		SPOS O 5;
		#### P 5{
			A_GibSplatter();
			A_XScream();
		}
		#### QR 5 A_GibSplatter();
		#### STUV 5;
		goto xdead2;
	xdead2:
		#### V 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### W 5 canraise{if(abs(vel.z)>=2.)setstatelabel("xdead2");}
		wait;
	raise:
		RCOP A 0{
			jammed=false;
		}
		#### L 4 A_GibSplatter();
		#### LK 6;
		#### JIH 4;
		#### A 0 A_Jump(256,"see");
	ungib:
		SPOS U 12;
		#### T 8;
		#### SRQ 6;
		#### PON 4;
		RCOP A 0 A_Jump(256,"see");
	}
}

class DeadRiotCopZombie:RiotCopZombie{
	override void postbeginplay(){
		super.postbeginplay();
		A_Die("spawndead");
	}
	states{
	death.spawndead:
		---- A 0;
		goto dead;
	}
}
