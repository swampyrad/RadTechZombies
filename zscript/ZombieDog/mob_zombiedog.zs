// ------------------------------------------------------------
// "I call the big one Bitey!"
// ------------------------------------------------------------
class ZombieDog:Babuin{

	void A_CheckFreedoomSprite(){
		sprite=getspriteindex("ZDOG");
	}

    override void CheckFootStepSound(){
		HDHumanoid.FootStepSound(self,0.4,drysound:"zombiedog/step");
	}

	default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "ZombieDog"
		//$Sprite "ZDOGA1"

		+hdmobbase.chasealert
		+cannotpush +pushable
		-hdmobbase.climber
		-hdmobbase.climbpastdropoff
		health 50;radius 12;
		height 32;deathheight 10;
		scale 0.6;
		speed 12;
		mass 70;
		meleerange 40;
		maxtargetrange 420;
		minmissilechance 220;
		painchance 90; pushfactor 0.2;

		maxstepheight 24;maxdropoffheight 64;

		seesound "zombiedog/sight";
		painsound "zombiedog/pain";
		deathsound "zombiedog/death";
		activesound "zombiedog/active";
		hdmobbase.stepsound "zombiedog/step";
		hdmobbase.stepsoundwet "zombiedog/wormstep";

		
		obituary "%o got chewed up by a zombie dog.";
		damagefactor "hot",0.76;
		tag "$ZOMBIE_DOG";
	}

	states{
	spawn:
		ZDOG A 0;
	idle:
		#### A 0 A_JumpIf(bambush,"spawnstill");
	spawnwander:
		#### ABCD random(6,8){
			blookallaround=false;
			hdmobai.wander(self);
		}
		#### A 0{
			if(!random(0,5))setstatelabel("spawnsniff");
			else if(!random(0,9))A_Vocalize(activesound);
		}loop;
	spawnsniff:
		#### A 0{blookallaround=true;}
		#### EEEE 4{
			angle+=frandom(-2,2);
			A_HDLook();
		}
		#### F 2{
			angle+=frandom(-20,20);
			if(!random(0,9))A_Vocalize(activesound);
		}
		#### FFF 2 A_HDLook();
		#### A 0{
			blookallaround=false;
			if(!random(0,6))setstatelabel("spawnwander");
		}loop;
	spawnstill:
		#### AB 8 A_HDLook();
		loop;
	see:
		#### A 0{
			//because babuins come into this state from all sorts of weird shit
			if(
				!checkmove(pos.xy,true)
				&&blockingmobj
			){
				setorigin((pos.xy+(pos.xy-blockingmobj.pos.xy),pos.z+1),true);
			}

			blookallaround=false;
			if(!random(0,127))A_Vocalize(seesound);
			MustUnstick();

			if(CheckClimb())return;

			bnofear=target&&distance3dsquared(target)<65536.;

			if(
				(target&&checksight(target))
				||!random(0,7)
			)setstatelabel("seechase");
			else setstatelabel("roam");
		}
	seechase:
		#### ABCD random(4,6) A_HDChase();
		---- A 0 setstatelabel("seeend");
	roam:
		#### ABCD random(5,7){
			A_HDChase(flags:CHF_WANDER);
			A_HDLook();
		}
		---- A 0 setstatelabel("seeend");
	seeend:
	//#### A 0 givebody(random(2,12));
	//dogs don't regen, they're not magical like demons are
		#### A 0 A_Jump(256,"see");
	melee:
		#### EE 3{
			A_FaceTarget(0,0);
			A_Vocalize("dog/bite");
			A_Changevelocity(cos(pitch)*2,0,sin(-pitch)*2,CVF_RELATIVE);
		}
		#### FF 3 A_Changevelocity(cos(pitch)*3,0,sin(-pitch)*3+2,CVF_RELATIVE);
		#### GG 1 TryLatch();
	postmelee:
		#### G 6 A_CustomMeleeAttack(random(5,15),"","","teeth",true);
		---- A 0 setstatelabel("see");

	latched:
		#### EF random(1,2);
		#### A 0 A_JumpIf(!latchtarget,"pain");
		loop;
		
	missile:
		#### ABCD 4{
			A_FaceTarget(16,16);
			bnodropoff=false;
			A_Changevelocity(1,0,0,CVF_RELATIVE);
			if(A_JumpIfTargetInLOS("null",20,0,128)){
				A_Vocalize(seesound);
				setstatelabel("jump");
			}
		}
		---- A 0 setstatelabel("see");
	jump:
		#### A 3 A_FaceTarget(16,16);
		#### E 3{
			A_Changevelocity(cos(pitch)*3,0,sin(-pitch)*3,CVF_RELATIVE);
		}
		#### E 2 A_FaceTarget(6,6,FAF_TOP);
		#### F 1 A_ChangeVelocity(cos(pitch)*16,0,sin(-pitch-frandom(-4,1))*16,CVF_RELATIVE);
		#### FF 1 TryLatch();
	fly:
		#### F 1{
			TryLatch();
			if(
				bonmobj
				||floorz>=pos.z
				||vel.xy==(0,0)
			)setstatelabel("land");
			else if(max(abs(vel.x),abs(vel.y)<3))vel.xy+=(cos(angle),sin(angle))*0.1;
		}wait;
	land:
		#### FEH 3{vel.xy*=0.8;}
		#### D 4{vel.xy=(0,0);}
		#### ABCD 3 A_HDChase("melee",null);
		---- A 0 setstatelabel("see");
	pain:
		#### H 2 A_SetSolid();
		#### H 6 A_Vocalize(activesound);
		#### ABCD 2 A_HDChase();
		---- A 0 setstatelabel("see");
	death:
		ZDOG I 4{
			A_Vocalize(deathsound);
			bpushable=false;
		}
	deathend:
		#### J 4 A_NoBlocking();
		#### KLM 4;
	dead:
	death.spawndead:
		ZDOG M 3 canraise{
			if(abs(vel.z)<2)frame++;
		}loop;
	raise:
		#### NMLKJI 5;
		#### A 0 A_Jump(256,"see");
	ungib:
		TROO U 6;
		TROO UT 8;
		TROO SRQ 6;
		TROO PO 4;
		ZDOG A 0 A_Jump(256,"see");
	gib:
		TROO O 0 A_XScream();
		TROO OPQ 4 A_GibSplatter();
		TROO RST 4;
		goto gibbed;
	deadgib:
		TROO O 4 A_XScream();
		TROO PQRST 4;
	gibbed:
		TROO T 5 canraise{
			if(abs(vel.z)<2)frame++;
		}loop;
	}
}


class SpecZombieDog:ZombieDog{
	default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Zombie Dog (Cloaked)"
		//$Sprite "ZDOGA1"

		renderstyle "fuzzy";
		dropitem "HDBlurSphere",1;
		tag "$ZOMBIE_DOG_CLOAKED";
	}
	override void Tick(){
		if(
			frame>3
		){
			a_setrenderstyle(1.,STYLE_Normal);
			bspecialfiredamage=false;
		}else if(!(level.time&(2|4))){
			if(bspecialfiredamage){
				a_setrenderstyle(0.9,STYLE_Fuzzy);
				bspecialfiredamage=false;
			}else{
				a_setrenderstyle(0.,STYLE_None);
				bspecialfiredamage=true;
			}
		}
		super.Tick();
	}
	states{
	death:
		TNT1 AAA 0 A_SpawnItemEx("HDSmoke",random(-1,1),random(-1,1),random(2,14),
			vel.x,vel.y,vel.z+random(1,3),0,
			SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION
		);
		TNT1 A 0 A_SetTranslucent(1,0);
		goto super::death;
	gib:
		TNT1 AAA 0 A_SpawnItemEx("HDSmoke",random(-1,1),random(-1,1),random(2,14),
			vel.x,vel.y,vel.z+random(1,3),0,
			SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION
		);
		TNT1 A 0 A_SetTranslucent(1,0);
		goto super::gib;
	}
}
class DeadZombieDog:ZombieDog{
	override void postbeginplay(){
		super.postbeginplay();
		A_Die("spawndead");
	}
}
class DeadSpecZombieDog:SpecZombieDog{
	override void postbeginplay(){
		super.postbeginplay();
		A_NoBlocking();
		A_SetTranslucent(1,0);
		A_Die("spawndead");
	}
}
