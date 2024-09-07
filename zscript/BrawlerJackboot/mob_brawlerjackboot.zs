// ------------------------------------------------------------
// Shotgun Zombie, but their gun can't shot
//   ------------------------------------------------------------
class BrawlerJackboot:Jackboot{
	
  override void postbeginplay(){
		super.postbeginplay();
   
		bhasdropped=false;
        gunloaded=0;
	}

	default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Brawler Zombie"
		//$Sprite "POSSA1"

		seesound "grunt/sight";
		painsound "grunt/pain";
		deathsound "grunt/death";
		activesound "grunt/active";
		tag "brawler zombie";

		+dropoff
		+SLIDESONWALLS

		radius 10;
		speed 8;
		mass 100;
		painchance 200;
		hitobituary "%o got headbutted by a brawler zombie.";
	}

override void deathdrop(){}

	states{
	spawn:
		SPOS E 1{
			A_HDLook();
			A_Recoil(frandom(-0.1,0.1));
		}
		#### EEE random(5,17) A_HDLook();
		#### E 1{
			A_Recoil(frandom(-0.1,0.1));
			A_SetTics(random(10,40));
		}
		#### B 0 A_Jump(28,"spawngrunt");
		#### B 0 A_Jump(132,"spawnswitch");
		#### B 8 A_Recoil(frandom(-0.2,0.2));
		loop;
	spawngrunt:
		SPOS G 1{
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
		loop;

	missile://lunge code borrowed from babuin latch attack 
		#### ABCD 2{
			A_FaceTarget(16,16);
			bnodropoff=false;
			A_Changevelocity(1,0,0,CVF_RELATIVE);
			if(A_JumpIfTargetInLOS("null",20,0,128)){
				A_Vocalize(seesound);
				setstatelabel("jump");
			}
		}
		---- A 0 setstatelabel("see");
	
	//brawler should never interact with shotgun
	reloadsg:
	aiming:
	shootsg:
	chambersg:
		goto roam;
		
	jump:
		#### E 3 A_FaceTarget(16,16);
		#### E 3{
			A_Changevelocity(cos(pitch)*2,0,sin(-pitch)*2,CVF_RELATIVE);
		}
		#### E 2 A_FaceTarget(6,6,FAF_TOP);
		#### E 1 A_ChangeVelocity(cos(pitch)*8,0,sin(-pitch-frandom(-4,1))*8,CVF_RELATIVE);
  	  #### ABCD 2 A_HDChase();
		---- A 0 setstatelabel("missile");

	pain:
		SPOS G 2;
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
		SPOS H 5;
		#### I 5 A_Vocalize(deathsound);
		#### J 5 A_NoBlocking();
		#### K 5;
	dead:
		SPOS K 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### L 5 canraise{if(abs(vel.z)>=2.)setstatelabel("dead");}
		wait;
	deadgib:
		SPOS M 5;
		#### N 5{
			A_GibSplatter();
			A_XScream();
		}
		#### OPQRST 5;
		goto gibbed;
	gib:
		SPOS M 5;
		#### N 5{
			A_GibSplatter();
			A_XScream();
		}
		#### O 0 A_NoBlocking();
		#### OP 5 A_GibSplatter();
		#### QRST 5;
		goto gibbed;
	gibbed:
		SPOS T 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### U 5 canraise A_JumpIf(abs(vel.z)>=2.,"gibbed");
		wait;
	raise:
		SPOS L 4;
		#### LK 6;
		#### JIH 4;
		#### A 0 A_Jump(256,"see");
	ungib:
		SPOS U 12;
		#### T 8;
		#### SRQ 6;
		#### PONM 4;
		SPOS A 0 A_Jump(256,"see");
	}

}