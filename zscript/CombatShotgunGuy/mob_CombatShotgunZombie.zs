

class CombatJackboot:HDHumanoid{
	default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Combat Shotgun Guy"
		//$Sprite "SPOSA1"

		seesound "shotguy/sight";
		painsound "shotguy/pain";
		deathsound "shotguy/death";
		activesound "shotguy/active";
		tag "combat jackboot";

		speed 10;
		decal "BulletScratch";
		meleesound "weapons/smack";
		meleedamage 4;
		maxtargetrange 4000;
		painchance 200;
		accuracy 1;

		obituary "%o was mortally wounded by a combat jackboot.";
		hitobituary "%o needs to brush up on their CQC training.";
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

			bhashelmet=true;
			sprite=GetSpriteIndex("PLAYA1");
			A_SetTranslation("BlackRedshirt");
     gunloaded=random(3,6);//5+1=6
     givearmour(1.,0.06,-0.4);
     choke=0;//no choke on combay0t shotgun
  		semi=0;//no semiauto on combat shotgun
	}

	override void deathdrop(){
		A_NoBlocking();
		if(bhasdropped){
			if(!bfriendly){
				DropNewItem("ShellPickup",200);
			}
		}else{
			DropNewItem("HDHandgunRandomDrop");
			bhasdropped=true;
			hdweapon wp=null;

			if(wep==0){
				wp=DropNewWeapon("HDCombatShotgun");
				if(wp){
					wp.weaponstatus[HUNTS_FIREMODE]=semi?0:0;
					if(gunspent)wp.weaponstatus[HUNTS_CHAMBER]=1;
					else if(gunloaded>0){
						wp.weaponstatus[HUNTS_CHAMBER]=2;
						gunloaded--;
					}
					if(gunloaded>0)wp.weaponstatus[HUNTS_TUBE]=gunloaded;
			
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
		SPOS A 0 nodelay A_JumpIf(wep>=0,"spawn2");
		PLAY A 0;
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
		#### A 0 A_Vocalize(activesound);
		---- A 0 setstatelabel("spawn2");
	spawnstill:
		#### C 0{
			A_HDLook();
			vel.xy-=(cos(angle),sin(angle))*frandom(-0.4,0.4);
		}
		#### CD 5{angle+=random(-4,4);}
		#### A 0{
			A_HDLook();
			if(!random(0,15))A_Vocalize(activesound);
		}
		#### AB 5{angle+=random(-4,4);}
		#### B 1 A_SetTics(random(10,40));
		---- A 0 setstatelabel("spawn2");
	spawnwander:
		#### CD 5 A_HDWander();
		#### A 0 {
			if(!random(0,15))A_Vocalize(activesound);
			A_HDLook();
		}
		#### AB 5 A_HDWander();
		#### A 0 A_Jump(64,"spawn2");
		loop;

	see:
		#### A 0{
			//if(jammed)return;
		 if(gunloaded<1)setstatelabel("reload");
			else if(!gunspent>0)setstatelabel("chambersg");
		}
		#### ABCD 4 A_HDChase();
		#### A 0 A_JumpIfTargetInLOS("see");
		#### A 0 A_Jump(16,"roam");
		loop;
	roam:
		#### A 0 A_Jump(60,"roam2");
	roam1:
		#### E 4{bmissileevenmore=true;}
		#### EEEE 3 A_HDChase("melee","turnaround",CHF_DONTMOVE);
		#### A 0{bmissileevenmore=false;}
		#### A 0 A_Jump(60,"roam");
	roam2:
		#### A 0 A_Jump(8,"see");
		#### ABCD 6 A_HDChase();
		#### A 0 A_Jump(200,"Roam");
		#### A 0 A_JumpIfTargetInLOS("see");
		loop;
	turnaround:
		#### A 0 A_FaceTarget(15,0);
		#### E 2 A_JumpIfTargetInLOS("missile2",40);
		#### A 0 A_FaceTarget(15,0);
		#### E 2 A_JumpIfTargetInLOS("missile2",40);
		#### ABCD 3 A_HDChase();
		---- A 0 setstatelabel("see");

	missile:
		#### A 0 A_JumpIfTargetInLOS(3,120);
		#### CD 2 A_FaceTarget(90,90);
		#### E 1 A_SetTics(random(3,7)); //when they just start to aim,not for followup shots!
		#### A 0 A_JumpIf(!hdmobai.tryshoot(self,pradius:5,pheight:5),"see");
	missile2:
		#### A 0{
			if(!target){
				setstatelabel("see");
				return;
			}
			double dist=distance3d(target);
			if(dist<300){
				turnamount=40;
			}else if(dist<800){
				turnamount=30;
			}else{
				turnamount=20;
			}
		}//fallthrough to turntoaim
	turntoaim:
		#### E 2 A_FaceTarget(turnamount,turnamount);
		#### A 0 A_JumpIfTargetInLOS(2);
		---- A 0 setstatelabel("see");
		#### A 0 A_JumpIfTargetInLOS(1,10);
		loop;
		#### A 0 A_FaceTarget(turnamount,turnamount);
		#### E 1 A_SetTics(random(1,100/clamp(1,turnamount,turnamount+1)+6));
		#### E 0{
			if(
				gunloaded<1
			){
				setstatelabel("ohforfuckssake");
				return;
			}
			shotspread=frandom(0.07,0.27)*turnamount;
			setstatelabel("shoot");
		}
	shoot:
		#### E 1 A_JumpIf(jammed,"jammed");
		#### E 0{
			if(gunloaded<1){
				setstatelabel("ohforfuckssake");
				return;
			}
			if(wep==1)shotspread*=0.8;
			angle+=frandom(0,shotspread)-frandom(0,shotspread);
			pitch+=frandom(0,shotspread)-frandom(0,shotspread);

			pitch+=frandom(0,0.3);  //anticipate recoil

    setstatelabel("shootsg");
		}

	shootsg:
		#### F 1 bright light("SHOT"){
			if(gunspent>0){
				setstatelabel("chambersg");
				return;
			}else if(vel dot vel > 400){
				setstatelabel("see");
				return;
			}

			if(Hunter.Fire(self,choke)<=Hunter.HUNTER_MINSHOTPOWER)semi=false;
			gunspent=1;
		}
		#### E 3;
		#### E 1{
			if(gunspent)setstatelabel("chambersg");
			else A_SetTics(random(3,7));
		}
		#### E 0 A_Jump(127,"see");
		#### E 0 A_SpidRefire();
		goto turntoaim;
	chambersg:
		#### E 8{
			if(gunspent){
				A_SetTics(random(3,7));
				A_StartSound("weapons/huntrack",8);
				gunspent=0;
				if(gunloaded>0)gunloaded--;
				A_SpawnItemEx("HDSpentShell",
					cos(pitch)*8,0,height-7-sin(pitch)*8,
					vel.x+cos(pitch)*cos(angle-random(86,90))*6,
					vel.y+cos(pitch)*sin(angle-random(86,90))*6,
					vel.z+sin(pitch)*random(1,3),0,
					SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}
			semi=false;//no semiauto!
		}
		#### E 1 A_SetTics(random(3,7));
		#### E 0 A_Jump(127,"see");
		#### E 0 A_SpidRefire();
		goto turntoaim;

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
		#### A 0{bfrightened=true;}
		#### A 2 A_HDChase("melee",null);
		#### A 0 A_StartSound("weapons/huntopen",8);
		#### BCDA 2 A_HDChase("melee",null);
	reloadsg2:
		#### A 0{if(!threat)threat=target;}
		#### BB 3 A_HDWander(flags:CHF_FLEE);
		#### B 0{
			gunloaded++;
			A_StartSound("weapons/huntreload",8);
			if(gunloaded>5)setstatelabel("reloadsgend");
		}
		#### CC 3 A_HDWander(flags:CHF_FLEE);
		#### C 0{
			gunloaded++;
			A_StartSound("weapons/huntreload",8);
			if(gunloaded>5)setstatelabel("reloadsgend");
		}
		#### DD 3 A_HDChase("melee",null,CHF_FLEE);
		#### D 0{
			gunloaded++;
			A_StartSound("weapons/huntreload",8);
			if(gunloaded>5)setstatelabel("reloadsgend");
		}
		#### A 0 A_StartSound("weapons/pocket",9);
		#### ABCDA 2 A_HDWander();
		loop;
	reloadsgend:
		#### A 0{bfrightened=false;}
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
			bfrightened=true;
		}
		#### ABCD 2 A_HDChase();
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
	xxxdeath:
		#### M 0 A_JumpIf(wep<0,"xxxdeath2");
		#### M 5;
		#### N 5 A_XScream();
		#### OPQRST 5;
		goto xdead;
	xxxdeath2:
		#### O 5;
		#### P 5 A_XScream();
		#### QRSTUV 5;
		goto xdead2;
	xdeath:
		#### M 0 A_JumpIf(wep<0,"xdeath2");
		#### M 5;
		#### N 5{
			spawn("MegaBloodSplatter",pos+(0,0,34),ALLOW_REPLACE);
			A_XScream();
		}
		#### OP 5 spawn("MegaBloodSplatter",pos+(0,0,34),ALLOW_REPLACE);
		#### QRST 5;
		goto xdead;
	xdead:
		#### T 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### U 5 canraise{if(abs(vel.z)>=2.)setstatelabel("xdead");}
		wait;
	xdeath2:
		#### O 5;
		#### P 5{
			spawn("MegaBloodSplatter",pos+(0,0,34),ALLOW_REPLACE);
			A_XScream();
		}
		#### QR 5 spawn("MegaBloodSplatter",pos+(0,0,34),ALLOW_REPLACE);
		#### STUV 5;
		goto xdead2;
	xdead2:
		#### V 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### W 5 canraise{if(abs(vel.z)>=2.)setstatelabel("xdead2");}
		wait;
	raise:
		#### A 0{
			jammed=false;
		}
		#### L 4 spawn("MegaBloodSplatter",pos+(0,0,34),ALLOW_REPLACE);
		#### LK 6;
		#### JIH 4;
		#### A 0 A_Jump(256,"see");
	ungib:
		#### U 12;
		#### T 8;
		#### SRQ 6;
		#### PON 4;
		#### A 0 A_Jump(256,"see");
	}
}


class DeadCombatJackboot:CombatJackboot{
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

