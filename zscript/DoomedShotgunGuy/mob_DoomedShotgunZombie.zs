// ------------------------------------------------------------
// Former Human Sergeant
// ------------------------------------------------------------
class HideousDoomedJackbootReplacer:RandomSpawner{
	default{
		//dropitem "DoomedJackAndJillboot",256,40;
		dropitem "DoomedJackboot",256,120;
	}
}

class DoomedJackboot:DoomedZombieShotgunner{default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Shotgun Guy (Pump)"
		//$Sprite "SPOSA1"
		accuracy 1;
}}
class DoomedJackAndJillboot:DoomedZombieShotgunner{default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Shotgun Guy (Side-By-Side)"
		//$Sprite "SPOSA1"
		accuracy 2;
}}

class DoomedZombieShotgunner:HDHumanoid{
	default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "DoomedShotgun Guy"
		//$Sprite "SPOSA1"

		seesound "doomshotguy/sight";
		painsound "doomshotguy/pain";
		deathsound "doomshotguy/death";
		activesound "doomeshotguy/active";
		tag "doomed jackboot";

		speed 10;
		decal "BulletScratch";
		meleesound "weapons/smack";
		meleedamage 4;
		maxtargetrange 4000;
		painchance 200;
		accuracy 0;

		//placeholder
		obituary "%o was shot up by the Tyrant's jack-booted thugs.";
		hitobituary "%o was beaten up by the Tyrant's jack-booted thugs.";
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

		//-1 zm66, 0 sg, 1 ssg
		if(!accuracy) wep=random(0,1)-random(0,1);
		else if(accuracy==1)wep=0;
		else if(accuracy==2)wep=1;
		else if(accuracy==3)wep=-1;

		//if no ssg, sg
		if(Wads.CheckNumForName("SHT2B0",wads.ns_sprites,-1,false)<0&&wep==1)wep=0;
	}
	override void postbeginplay(){
		super.postbeginplay();
		if(wep<0){
			bhashelmet=true;
			sprite=GetSpriteIndex("PLAYA1");
			A_SetTranslation("HattedJackboot");
			gunloaded=random(10,50);
			givearmour(1.,0.06,-0.4);
		}else{
			sprite=GetSpriteIndex("SPOSA1");
			A_SetTranslation("ShotgunGuy");
			gunloaded=wep?random(1,2):random(3,8);
			if(random(0,7))choke=(wep?(7+8*7):1);else{
				choke=random(0,7);
				//set second barrel
				if(wep)choke+=8*random(0,7);
			}
		}
		semi=randompick(0,0,1);
	}
	override void deathdrop(){
		A_NoBlocking();
		if(bhasdropped){
			if(!bfriendly){
				if(wep<0)DropNewItem("HD4mMag",96);
				else DropNewItem("ShellPickup",200);
			}
		}else{
			DropNewItem("HDHandgunRandomDrop");
			bhasdropped=true;
			hdweapon wp=null;
			if(wep==-1){
				wp=DropNewWeapon("ZM66AssaultRifle");
				if(wp){
					wp.weaponstatus[0]=
						ZM66F_NOLAUNCHER|(randompick(0,1,1,1,1)*ZM66F_CHAMBER);
					if(gunloaded>=50)wp.weaponstatus[ZM66S_MAG]=51;
					else wp.weaponstatus[ZM66S_MAG]=gunloaded;
					wp.weaponstatus[ZM66S_AUTO]=2;
					wp.weaponstatus[ZM66S_ZOOM]=random(16,70);
					if(jammed||!random(0,7))wp.weaponstatus[0]|=ZM66F_CHAMBERBROKEN;
					wp.weaponstatus[ZM66S_DOT]=random(-1,5);

					gunloaded=50;
				}
			}
			if(wep==0 && dHunt_hunter_spawn_bias > -1){
				wp=DropNewWeapon("DoomHunter");
				if(wp){
					wp.weaponstatus[HUNTS_FIREMODE]=semi?1:0;
					if(gunspent)wp.weaponstatus[HUNTS_CHAMBER]=1;
					else if(gunloaded>0){
						wp.weaponstatus[HUNTS_CHAMBER]=2;
						gunloaded--;
					}
					if(gunloaded>0)wp.weaponstatus[HUNTS_TUBE]=gunloaded;
					wp.weaponstatus[SHOTS_SIDESADDLE]=random(0,12);
					wp.weaponstatus[0]&=~HUNTF_CANFULLAUTO;
					wp.weaponstatus[HUNTS_CHOKE]=choke;

					gunloaded=8;
				}
			}
			if(wep==0 && dHunt_hunter_spawn_bias == -1){
				wp=DropNewWeapon("Hunter");
				if(wp){
					wp.weaponstatus[HUNTS_FIREMODE]=semi?1:0;
					if(gunspent)wp.weaponstatus[HUNTS_CHAMBER]=1;
					else if(gunloaded>0){
						wp.weaponstatus[HUNTS_CHAMBER]=2;
						gunloaded--;
					}
					if(gunloaded>0)wp.weaponstatus[HUNTS_TUBE]=gunloaded;
					wp.weaponstatus[SHOTS_SIDESADDLE]=random(0,12);
					wp.weaponstatus[0]&=~HUNTF_CANFULLAUTO;
					wp.weaponstatus[HUNTS_CHOKE]=choke;

					gunloaded=8;
				}
			}
			if(wep==1){
				wp=DropNewWeapon("Slayer");
				if(wp){
					if(gunloaded==2)wp.weaponstatus[SLAYS_CHAMBER2]=2;
					else if(gunspent==2)wp.weaponstatus[SLAYS_CHAMBER2]=1;
					if(gunloaded>0)wp.weaponstatus[SLAYS_CHAMBER1]=2;
					else if(gunspent>0)wp.weaponstatus[SLAYS_CHAMBER1]=1;
					wp.weaponstatus[SHOTS_SIDESADDLE]=random(0,12);
					wp.weaponstatus[SLAYS_CHOKE1]=(choke&(1|2|4));
					wp.weaponstatus[SLAYS_CHOKE2]=(choke>>3);

					gunloaded=2;
				}
			}
		}
		gunspent=0;
		if(wep==-1){
			gunloaded=50;
		}
		if(wep==0){
			gunloaded=8;
		}
		if(wep==1){
			gunloaded=2;
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
			if(jammed)return;
			else if(gunloaded<1)setstatelabel("reload");
			else if(!wep&&gunspent>0)setstatelabel("chambersg");
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
		#### E 1 A_SetTics(random(4,10)); //when they just start to aim,not for followup shots!
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

			if(wep==-1)setstatelabel("shootzm66");
			else if(wep==1)setstatelabel("shootssg");
			else setstatelabel("shootsg");
		}


	shootzm66:
		#### E 1{
			gunspent=0;
		}
	shootzm662:
		#### F 1 bright light("SHOT"){
			if(!random(0,999)){
				A_StartSound("weapons/rifleclick",8);
				gunloaded=-gunloaded;
				setstatelabel("ohforfuckssake");
				return;
			}

			angle+=frandom(-0.2,0.1)*shotspread;
			pitch+=frandom(-0.2,0.1)*shotspread;

			A_StartSound("weapons/rifle",CHAN_WEAPON);

			gunspent++;
			gunloaded--;
			HDBulletActor.FireBullet(self,"HDB_426");
			if(random(0,2000)<gunspent+2){
				jammed=true;
				A_StartSound("weapons/rifleclick",8);
				setstatelabel("jammed");
			}
		}
		#### E 1{
			if(gunspent<3&&gunloaded>0)setstatelabel("shootzm662");
			else A_SetTics(random(4,12));
		}
		#### E 0 A_Jump(127,"see");
		#### E 0 A_SpidRefire();
		goto turntoaim;

	shootssg:
		#### F 1 bright light("SHOT"){
			if(vel dot vel > 900){
				setstatelabel("see");
				return;
			}

			A_StartSound("weapons/slayersingle",CHAN_WEAPON);
			if(gunloaded>1&&!random(0,5)){
				//both barrels
				A_StartSound("weapons/slayersingle",CHAN_WEAPON,CHANF_OVERLAP);
				gunspent=2;
				gunloaded=0;
				Slayer.Fire(self,0,(choke&(1|2|4)));
				Slayer.Fire(self,1,(choke>>3));
			}else{
				//single barrel
				gunspent++;
				gunloaded--;
				if(gunspent)Slayer.Fire(self,1,(choke>>3));
				else Slayer.Fire(self,0,(choke&(1|2|4)));
			}
		}
		#### E 1 A_SetTics(random(2,4));
		#### E 0 A_Jump(192,"see");
		#### E 0 A_SpidRefire();
		goto turntoaim;

	shootsg:
		#### F 1 bright light("SHOT"){
			if(gunspent>0){
				setstatelabel("chambersg");
				return;
			}else if(vel dot vel > 400){
				setstatelabel("see");
				return;
			}

			if(DoomHunter.Fire(self,choke)<=DoomHunter.HUNTER_MINSHOTPOWER)semi=false;
			gunspent=1;
		}
		#### E 3{
			if(semi){
				A_SetTics(0);
				if(gunloaded>0)gunloaded--;
				gunspent=0;
				A_SpawnItemEx("HDSpentShell",
					cos(pitch)*8,0,height-7-sin(pitch)*8,
					vel.x+cos(pitch)*cos(angle-random(86,90))*6,
					vel.y+cos(pitch)*sin(angle-random(86,90))*6,
					vel.z+sin(pitch)*random(5,7),0,
					SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
				if(!random(0,7))semi=false;
			}
		}
		#### E 1{
			if(gunspent)setstatelabel("chambersg");
			else A_SetTics(random(3,8));
		}
		#### E 0 A_Jump(127,"see");
		#### E 0 A_SpidRefire();
		goto turntoaim;
	chambersg:
		#### E 8{
			if(gunspent){
				A_SetTics(random(3,10));
				A_StartSound("weapons/huntrack",8);
				gunspent=0;
				if(gunloaded>0)gunloaded--;
				A_SpawnItemEx("HDSpentShell",
					cos(pitch)*8,0,height-7-sin(pitch)*8,
					vel.x+cos(pitch)*cos(angle-random(86,90))*6,
					vel.y+cos(pitch)*sin(angle-random(86,90))*6,
					vel.z+sin(pitch)*random(5,7),0,
					SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}
			if(!random(0,7))semi=true;
		}
		#### E 1 A_SetTics(random(3,8));
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
		#### A 0{
			if(wep==-1)setstatelabel("reloadzm66");
			else if(wep==1)setstatelabel("reloadssg");
			else setstatelabel("reloadsg");
		}


	reloadzm66:
		#### A 2 A_HDChase("melee",null,CHF_FLEE);
		#### A 0 A_StartSound("weapons/rifleclick2",8);
		#### BCD 2 A_HDWander(flags:CHF_FLEE);
		#### A 2{
			A_HDWander();
			if(gunspent==999)return;

			A_StartSound("weapons/rifleunload",8);
			if(!gunloaded)A_SpawnProjectile("HD4mmMagEmpty",38,0,random(90,120));
			else{
				HDMagAmmo.SpawnMag(self,"HD4mMag",gunloaded);
				gunspent=999;
			}
		}
		#### BCD 2 A_HDWander(flags:CHF_FLEE);
		#### A 4 A_StartSound("weapons/pocket",9);
		#### BC 4 A_HDWander(flags:CHF_FLEE);
		#### E 6 A_StartSound("weapons/rifleload",8);
		#### E 2{
			A_StartSound("weapons/rifleclick2");
			gunloaded=50;
			gunspent=0;
			bfrightened=false;
			A_HDChase();
		}
		#### CB 4 A_HDChase("melee",null);
		goto turntoaim;

	reloadssg:
		#### E 2;
		#### E 2 A_StartSound("weapons/sshoto",8);
		#### E 0{
			while(gunspent>0){
				gunspent--;
				A_SpawnItemEx("HDSpentShell",
					cos(pitch)*5,-1,height-7-sin(pitch)*5,
					cos(pitch-45)*cos(angle)*random(1,4)+vel.x,
					cos(pitch-45)*sin(angle)*random(1,4)+vel.y,
					-sin(pitch-45)*random(1,4)+vel.z,0,
					SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}
		}

		#### ED 2 A_HDChase("melee",null,flags:CHF_FLEE);
		#### DAAB 3 A_HDChase("melee",null,flags:CHF_FLEE,speedmult:0.5);
		#### B 1 A_StartSound("weapons/sshotl",8);
		#### CCD 4;
		#### E 6{
			A_StartSound("weapons/sshotc",8);
			gunloaded=2;
		}
		---- A 0 setstatelabel("see");

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
			if(gunloaded>=8)setstatelabel("reloadsgend");
		}
		#### CC 3 A_HDWander(flags:CHF_FLEE);
		#### C 0{
			gunloaded++;
			A_StartSound("weapons/huntreload",8);
			if(gunloaded>=8)setstatelabel("reloadsgend");
		}
		#### DD 3 A_HDChase("melee",null,CHF_FLEE);
		#### D 0{
			gunloaded++;
			A_StartSound("weapons/huntreload",8);
			if(gunloaded>=8)setstatelabel("reloadsgend");
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
	deadgib:
		#### M 0 A_JumpIf(wep<0,"xxxdeath2");
		#### M 5;
		#### N 5 A_XScream();
		#### OPQRST 5;
		goto gibbed;
	xxxdeath2:
		#### O 5;
		#### P 5 A_XScream();
		#### QRSTUV 5;
		goto xdead2;
	gib:
		#### M 0 A_JumpIf(wep<0,"xdeath2");
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
		#### O 5;
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
		#### A 0{
			jammed=false;
		}
		#### L 4 A_GibSplatter();
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

class DeadDoomedJackboot:DeadDoomedZombieShotgunner{default{accuracy 1;}}
class DeadDoomedJackAndJillboot:DeadDoomedZombieShotgunner{default{accuracy 2;}}

class DeadDoomedZombieShotgunner:DoomedZombieShotgunner{
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

