// ------------------------------------------------------------
// Wither Fireballs
// ------------------------------------------------------------

class ReverseWitherBallTail:IdleDummy{
	default{
		+nointeraction +forcexybillboard -invisible
		renderstyle "add";
		scale 0.6;alpha 0;
	}
	override void Tick(){
		A_SpawnParticle("99 44 11",0,random(30,40),frandom(1.2,2.1),0,frandom(-4,4),frandom(-4,4),frandom(0,2),frandom(-1,1),frandom(-1,1),frandom(0.9,1.3));
		super.Tick();
	}
	states{
		spawn:
			WITB EEDC 2 bright A_FadeIn(0.2);
		death:
			WITB BAB 2 bright A_FadeIn(0.2);
			WITB A 0{
				if(target&&target.health<1)A_Immolate(target,target.target,random(10,25));
			}
			stop;
	}
}

//weaker version of the imp fireball
class HDWitherBall:HDFireball{
	default{
		+seekermissile
		missiletype "HDImpBallTail";
		decal "BrontoScorch";
		speed 12;
		damagetype "electrical";
		gravity 0;
		hdfireball.firefatigue int(HDCONST_MAXFIREFATIGUE*0.15);
	}
	double initangleto;
	double inittangle;
	double inittz;
	vector3 initpos;
	vector3 initvel;
	virtual void A_HDIBFly(){
		let flip=getage()&1;
		if(flip)scale.x=-scale.x;
		if(
			!flip
			||!A_FBSeek()
		){
			vel*=0.99;
			A_FBFloat();

			stamina++;
			switch(stamina){
			case 8:
			case 7:
				A_ChangeVelocity(0,-1,0,CVF_RELATIVE);break;
			case 6:
			case 5:
				A_ChangeVelocity(0,0,-1,CVF_RELATIVE);break;
			case 4:
			case 3:
				A_ChangeVelocity(0,1,0,CVF_RELATIVE);break;
			case 2:
			case 1:
				A_ChangeVelocity(0,0,1,CVF_RELATIVE);break;
			default:
				A_ChangeVelocity(cos(pitch)*0.1,0,-sin(pitch)*0.1,CVF_RELATIVE);
				stamina=0;break;
			}
		}
	}
	void A_WitherSquirt(){
		if(getage()&1)scale.x=-scale.x;
		alpha*=0.92;scale*=frandom(1.,0.96);
		if(!tracer)return;
		double diff=max(
			absangle(initangleto,angleto(tracer)),
			absangle(inittangle,tracer.angle),
			abs(inittz-tracer.pos.z)*0.05
		);
		int dmg=int(max(0,10-diff*0.1));
		if(
			tracer.bismonster
			&&!tracer.bnopain
			&&tracer.health>0
		)tracer.angle+=randompick(-10,10);

		//do it again
		initangleto=angleto(tracer);
		inittangle=tracer.angle;
		inittz=tracer.pos.z;

		setorigin((pos+(tracer.pos-initpos))*0.5,true);
		if(dmg){
			tracer.A_GiveInventory("Heat",dmg);
			tracer.damagemobj(self,target,max(1,dmg>>2),"hot");
		}
	}
	override void postbeginplay(){
		super.postbeginplay();
		if(vel.x||vel.y||vel.z)initvel=vel.unit();
		else{
			double cp=cos(pitch);
			initvel=(cp*cos(angle),cp*sin(angle),-sin(pitch));
		}
		initvel*=0.3;
	}
	void A_FBTailAccelerate(){
		A_FBTail();
		vel+=initvel;
	}
	states{
	spawn:
		WITB ABABABABAB 2 A_FBTailAccelerate();
		WITB A 0 A_ChangeVelocity(0,-1,-1,CVF_RELATIVE);
	spawn2:
		WITB AB 3 A_HDIBFly();
		loop;
	death:
		TNT1 AAA 0 A_SpawnItemEx("HDSmoke",flags:SXF_NOCHECKPOSITION);
		TNT1 A 0{
			A_Scream();
			tracer=null;
			if(blockingmobj){
				if(
					blockingmobj is "FighterImp"
					&&(!target||blockingmobj!=target.target)
				)blockingmobj.givebody(random(1,5));
				else{
					if(!blockingline)tracer=blockingmobj;
					blockingmobj.damagemobj(self,target,random(3,9),"electrical");
				}
			}
			if(tracer){
				initangleto=angleto(tracer);
				inittangle=tracer.angle;
				inittz=tracer.pos.z;
				initpos=tracer.pos-pos;

				let hdt=hdmobbase(tracer);

				//HEAD SHOT
				if(
					pos.z-tracer.pos.z>tracer.height*0.8
					&&(
						!hdt
						||(
							!hdt.bnovitalshots
							&&!hdt.bheadless
						)
					)
				){
					if(hd_debug)A_Log("HEAD SHOT");
					bpiercearmor=true;
				}
			}
			A_SprayDecal("BrontoScorch",radius*2);
		}
		WITB ABCCDDEEEEEEE 3 A_WitherSquirt();
		stop;
	}
}

// ------------------------------------------------------------
// Wither
// ------------------------------------------------------------
class Wither:FighterImp{
	default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Wither"
		//$Sprite "WITHA1"

		+hdmobbase.chasealert
		+hdmobbase.doesntbleed

		mass 80;
		+floorclip
		
		//uses Revenant's "dust" particles
		+noblooddecals
		bloodtype "notquitebloodsplat";
		
		+hdmobbase.climber
		seesound "wither/sight";
		painsound "wither/pain";
		deathsound "wither/death";
		activesound "wither/active";
		meleesound "imp/melee";
		hdmobbase.downedframe 12;
		tag "$WITHER";

    //same damagefactors as Revenants
		damagefactor "hot",1.1;
		damagefactor "cold",1.1;
		damagefactor "slashing",0.8;
		damagefactor "piercing",0.8;
		
		health 50;//half the health of an normal imp

		radius 14;
		height 56;
		hdmobbase.gunheight 36;
		deathheight 15;
		speed 6;//slow due to their weakened state
		maxdropoffheight 128;

		damage 4;
		meleedamage 4;

		painchance 80;
		translation "0";//disable translation
		Obituary "%o was grilled by a Wither.";
		hitobituary "%o got boned by a Wither";
	}
	override void postbeginplay(){
		super.postbeginplay();
		
		bsmallhead=true;
		bbiped=true;
		A_SetSize(13,54);
		
		bonlyscreamondeath=true;
		bnoextremedeath=true;
		bnoincap=true;
		
		resize(0.8,1.1);
		voicepitch=frandom(0.9,1.1);

		maxstepheight=24;
	}
	//always use imp footsteps
	override void CheckFootStepSound(){
		HDHumanoid.FootStepSound(self,0.2,drysound:"imp/step");
	}
	
	//Withers don't drop guns
	override void deathdrop(){}
	
	//Withers don't react to fire damage
	override int damagemobj(
		actor inflictor,actor source,int damage,
		name mod,int flags,double angle
	){
		HDMath.ProcessSynonyms(mod);
		if(mod=="hot"||mod=="cold")flags|=DMG_NO_PAIN;
		return super.damagemobj(
			inflictor,source,damage,mod,flags,angle
		);
	}
	
	states{
	spawn:
		WITH A 0;
	idle:
		#### AAABBCCCDD 8 A_HDLook();
		#### A 0 A_SetAngle(angle+random(-4,4));
		#### A 1 A_SetTics(random(1,3));
		---- A 0 A_Jump(216,2);
		---- A 0 A_Vocalize(activesound);
		#### A 0 A_JumpIf(bambush,"idle");
		#### A 0 A_Jump(32,"spawn2");
		loop;
	spawn2:
		#### ABCD 4 A_HDWander(CHF_LOOK);
		#### A 0 A_Jump(198,"spawn2");
		#### A 0 {vel.xy-=(cos(angle),sin(angle))*0.4;}
		#### A 0 A_Jump(64,"idle");
		loop;

	see:
		#### ABCD 4 A_HDChase();
		#### A 0 A_Jump(116,"roam","roam","roam","roam2","roam2");
		loop;
	roam:
		#### AABB 3 A_Watch();
		#### A 0 A_Jump(60,"roam");
	roam2:
		#### A 0 A_JumpIf(targetinsight||!random(0,31),"see");
		#### ABCD 6 A_HDChase(speedmult:0.6);
		#### A 0 A_Jump(80,"roam");
		loop;

	missile:
		#### ABCD 4{
			A_Strafe();
			A_TurnToAim(40,gunheight);
		}
		loop;
	shoot:
		#### E 0 A_Jump(16,"hork");
		goto lead;

  //takes 2x longer to throw fireballs
	lead:
		#### E 0 A_Strafe();
		#### E 8 A_FaceLastTargetPos(40,gunheight);
		#### E 0 A_Strafe();
		#### E 2 A_FaceLastTargetPos(20,gunheight);
		#### E 0 A_Strafe();
		#### F 8 A_LeadTarget(min(20,lasttargetdist/getdefaultbytype("HDWitherBall").speed));
		#### E 0 A_JumpIf(!hdmobai.TryShoot(self,gunheight,256,10,10,flags:HDMobAI.TS_GEOMETRYOK),"see");
		#### G 12 A_SpawnProjectile("HDWitherBall",34,0,0,CMF_AIMDIRECTION,pitch-frandom(0,0.1));
		#### F 8 A_ChangeVelocity(0,frandom(-3,3),0,CVF_RELATIVE);
		---- A 0 A_JumpIfTargetInsideMeleeRange("melee");
		#### E 0 A_JumpIf(!hdmobai.TryShoot(self,gunheight,512,10,10,flags:HDMobAI.TS_GEOMETRYOK),"see");
		#### E 0 A_Jump(16,"see");
		#### E 0 A_Jump(140,"coverfire");
		---- A 0 setstatelabel("see");
/*
	spam:
		#### E 3 A_SetTics(random(4,6));
		#### EF 2 A_Strafe();
		#### G 6 A_SpawnProjectile("HDWitherBall",gunheight,0,frandom(-3,4),CMF_AIMDIRECTION,pitch+frandom(-2,1.8));
		#### F 4;
		#### F 0 A_JumpIf(firefatigue>HDCONST_MAXFIREFATIGUE,"pain");
*/
		//fall through to more cover fire
	coverfire:
		---- A 0 A_JumpIfTargetInLOS("see");
		#### EEEEE 3 A_Coverfire("coverdecide");
		---- A 0 setstatelabel("see");
	coverdecide:
		#### E 0 A_JumpIf(!hdmobai.TryShoot(self,32,512,10,10,flags:HDMobAI.TS_GEOMETRYOK),"see");
	//	---- A 0 A_Jump(180,"spam");
		---- A 0 A_Jump(90,"hork");
		---- A 0 setstatelabel("missile");

	hork:
	//	#### E 0 A_Jump(156,"spam");
		---- A 0 A_FaceLastTargetPos(40,gunheight);
		#### E 2 A_Strafe();
		#### E 0 A_Vocalize(seesound);
		#### EEEEE 2 A_SpawnItemEx("ReverseWitherBallTail",4,24,gunheight,1,0,0,0,160);
		#### EF 2 A_Strafe();
		#### G 0 A_SpawnProjectile("HDWitherBall",gunheight,0,(frandom(-2,10)),CMF_AIMDIRECTION,pitch+frandom(-4,3.6));
		#### G 0 A_SpawnProjectile("HDWitherBall",gunheight,0,(frandom(-4,4)),CMF_AIMDIRECTION,pitch+frandom(-4,3.6));
		#### G 0 A_SpawnProjectile("HDWitherBall",gunheight,0,(frandom(-2,-10)),CMF_AIMDIRECTION,pitch+frandom(-4,3.6));
		#### GGFE 5 A_SetTics(random(4,6));
		#### E 0 A_JumpIf(!hdmobai.TryShoot(self,32,256,10,10,flags:HDMobAI.TS_GEOMETRYOK),"see");
		#### E 0 A_Watch();
		---- A 0 setstatelabel("see");

  //takes 2x linger to scratch you
	melee:
		#### EE 8 A_FaceLastTargetPos();
		#### F 4;
		#### G 16 A_FireballerScratch("HDWitherBall",random(5,15));
		#### F 8;
		---- A 0 setstatelabel("see");
	
	pain:
		#### H 3 A_GiveInventory("HDFireEnder",3);
		#### H 3 A_Vocalize(painsound);
		---- A 0 A_ShoutAlert(0.4,SAF_SILENT);
		#### A 2 A_FaceTarget();
		#### BCD 2 A_FastChase();
		#### A 0 A_JumpIf(firefatigue>(HDCONST_MAXFIREFATIGUE*1.6),"see");
		goto missile;
	
	//NOINCAP doesn't work got some reason, 
	//so i'm just overriding the
	//falldown state directly
	falldown:
	  goto pain;	
	  
	//falls apart on death, bones fly everywhere
	//doesn't leave a corpse behind
	death:
		TNT1 A 10
		{
			A_Startsound("wither/death",23112,CHANF_OVERLAP);
			BonesParticle("WITHI0",1,18,48);
			BonesParticle("WITHJ0",2,15,28);
			BonesParticle("WITHK0",3,10,random(20,40));
			BonesParticle("WITHL0",2,10,random(20,40));
			BonesParticle("WITHM0",1,18,28);
		}
		TNT1 A 0 A_Startsound("wither/bones");
		Stop;
	}
	
	//bone gibs, spawned on death
	void BonesParticle(string pbone, int pamount, int psize, int pz)
	{
		FSpawnParticleParams bp;
		bp.texture = TexMan.CheckForTexture(pbone);
		bp.flags = SPF_ROLL;
		bp.color1 = "FFFFFF";
		for (int i = 0; i < pamount; i++)
		{
			bp.lifetime = 35;
			bp.size = psize*1.5;
			bp.startalpha = 1.0;
			bp.pos.x = pos.x+random(-5,5);
			bp.pos.y = pos.y+random(-5,5);
			bp.pos.z = pos.z+pz;
			bp.vel.xy = (random(-4,4),random(-4,4));
			bp.vel.z = random(5,10);
			bp.accel.xy = -(bp.vel.xy*0.05);
			bp.accel.z = -1;
			bp.startRoll = random(0,359);
			bp.rollvel = randompick(-25,-15,15,25);
			level.SpawnParticle(bp);
		}
	}
}