// ------------------------------------------------------------
// Minerva Guy
// ------------------------------------------------------------

class MinervaZombie:HDHumanoid{
	default{
		radius 14;
		height 54;
		painchance 170;
		monster;
		+floorclip
		seesound "minervazombie/sight";
		painsound "minervazombie/pain";
		deathsound "minervazombie/death";
		activesound "minervazombie/active";
		tag "massive firearms person";

		health 120;
		speed 9;
		mass 200;
		maxtargetrange 6000;
		obituary "%o heard Minnie's yoo-hoo.";
		hitobituary "%o got cheesed by a Minnie-gunner.";
		hdmobbase.downedframe 11;
	}
	bool turnleft;
	bool superauto;
	int thismag;
	int mags;
	int chambers;
	int burstcount;
	vector2 coverdir;
	override void postbeginplay(){
		super.postbeginplay();
		chambers=5;
		burstcount=random(4,20);
		superauto=randompick(0,0,0,1);
		mags=4;
		thismag=30;
		bhashelmet=false;
		bnoincap=false;

		givearmour(1.,0.2,-0.4);
	}
	void A_ScanForTargets(){
		if(noammo()){
			setstatelabel("reload");
			return;
		}

		int c=-2;
		double oldangle=angle;
		double oldpitch=pitch;
		while(
			c<=1
		){
			c++;
			//shoot a line out
			flinetracedata hlt;
			int ccc=0;
			double aimangle=oldangle+frandom(-4,4);
			double aimpitch=oldpitch+c*2+frandom(-4,4);
			do{
				ccc++;
				linetrace(
					aimangle+frandom(-2,2),16384,aimpitch+frandom(-2,2),
					flags:TRF_NOSKY,
					offsetz:40,
					data:hlt
				);
			}while(!hlt.hitactor&&ccc<4);

			//if the line hits a valid target, go into shooting state
			actor hitactor=hlt.hitactor;
			if(hitactor&&(
				hitactor==target
				||(
					isHostile(hitactor)
					&&hitactor.bshootable
					&&!hitactor.bnotarget
					&&!hitactor.bnevertarget
					&&(hitactor.bismonster||hitactor.player)
					&&(!hitactor.player||!(hitactor.player.cheats&CF_NOTARGET))
					&&hitactor.health>random(-4,5)
				)
			)){
				if(!target||target.health<1)target=hitactor;
				angle=aimangle+frandom(-1,1);
				pitch=aimpitch+frandom(-1,1);
				burstcount=random(3,max(8,hitactor.health/10));
				setstatelabel("scanshoot");
				return;
			}
		}
		if(turnleft)angle+=frandom(3,4);
		else angle-=frandom(3,4);
	}
	bool noammo(){
		return chambers<1&&thismag<1&&mags<1;
	}
	void A_VulcGuyShot(){
		//abort if burst is over
		if(
			burstcount<1
			||noammo()
		){
			burstcount=random(3,5);
			setstatelabel("postshot");
			return;
		}

		//check for ammo
		if(
			thismag<1
			&&mags>0
		){
			setstatelabel("shuntmag");
			return;
		}
		if(chambers<1)setstatelabel("chamber");

		//shoot the bullet
		A_StartSound("weapons/pistol",CHAN_WEAPON,CHANF_OVERLAP);
		HDBulletActor.FireBullet(self,"HDB_9",spread:2,distantsound:"world/vulcfar");
		pitch+=frandom(-0.4,0.3);angle+=frandom(-0.3,0.3);
		burstcount--;
		chambers--;

		//cycle the next round
		if(chambers<5 && thismag){
			thismag--;
			chambers++;
			A_StartSound("weapons/rifleclick2",8);
		}
	}
	void A_TurnTowardsTarget(
		statelabel shootstate="shoot",
		double maxturn=13,
		double maxvariance=10
	){
		A_FaceTarget(maxturn,maxturn);
		if(
			!target
			||maxvariance>absangle(angle,angleto(target))
			||!checksight(target)
		)setstatelabel(shootstate);
		if(bfloat||floorz>=pos.z)A_ChangeVelocity(0,frandom(-0.1,0.1)*speed,0,CVF_RELATIVE);
	}
	override void deathdrop(){
		if(!bhasdropped){
			bhasdropped=true;
			DropNewItem("HDBattery",16);
			DropNewItem("HDHandgunRandomDrop");
			if(minerva_chaingun_spawn_bias == -1)
			{
			let vvv=DropNewWeapon("Vulcanette");
			if(!vvv)return;
			vvv.weaponstatus[VULCS_MAG1]=thismag;
			for(int i=VULCS_MAG2;i<=VULCS_MAG5;i++){
				if(mags>0){
					vvv.weaponstatus[i]=30;
					mags--;
				}else vvv.weaponstatus[i]=-1;
			}
			vvv.weaponstatus[VULCS_CHAMBER1]=(!random(0,3))?2:1;
			vvv.weaponstatus[VULCS_CHAMBER2]=(!random(0,3))?2:1;
			vvv.weaponstatus[VULCS_CHAMBER3]=(!random(0,3))?2:1;
			vvv.weaponstatus[VULCS_CHAMBER4]=(!random(0,3))?2:1;
			vvv.weaponstatus[VULCS_CHAMBER5]=(!random(0,3))?2:1;
			if(superauto)vvv.weaponstatus[0]|=VULCF_FAST;
			vvv.weaponstatus[VULCS_BATTERY]=random(1,20);
			vvv.weaponstatus[VULCS_BREAKCHANCE]=random(0,random(1,500));
			vvv.weaponstatus[VULCS_ZOOM]=random(16,70);
			}
			else
			{
			let vvv=DropNewWeapon("MinervaChaingun");
			if(!vvv)return;
			vvv.weaponstatus[VULCS_MAG1]=thismag;
			for(int i=VULCS_MAG2;i<=VULCS_MAG5;i++){
				if(mags>0){
					vvv.weaponstatus[i]=30;
					mags--;
				}else vvv.weaponstatus[i]=-1;
			}
			vvv.weaponstatus[VULCS_CHAMBER1]=(!random(0,3))?2:1;
			vvv.weaponstatus[VULCS_CHAMBER2]=(!random(0,3))?2:1;
			vvv.weaponstatus[VULCS_CHAMBER3]=(!random(0,3))?2:1;
			vvv.weaponstatus[VULCS_CHAMBER4]=(!random(0,3))?2:1;
			vvv.weaponstatus[VULCS_CHAMBER5]=(!random(0,3))?2:1;
			if(superauto)vvv.weaponstatus[0]|=VULCF_FAST;
			vvv.weaponstatus[VULCS_BATTERY]=random(1,20);
			vvv.weaponstatus[VULCS_BREAKCHANCE]=random(0,random(1,500));
			vvv.weaponstatus[VULCS_ZOOM]=random(16,70);
			}
		}else if(!bfriendly){
			DropNewItem("HD9mMag30",96);
			DropNewItem("HD9mMag30",96);
			DropNewItem("HDBattery",8);
		}
	}
	states{
	spawn:
		MINZ B 1 nodelay{
			A_HDLook();
			A_Recoil(random(-1,1)*0.1);
			A_SetTics(random(10,40));
		}
		MINZ BB 1{
			A_HDLook();
			A_SetTics(random(10,40));
		}
		MINZ A 8{
			if(bambush)setstatelabel("spawnhold");
			else if(!random(0,1))setstatelabel("spawnstill");
			else A_Recoil(random(-1,1)*0.2);
		}loop;
	spawnhold:
		MINZ G 1{
			A_HDLook();
			if(!random(0,8))A_Recoil(random(-1,1)*0.4);
			A_SetTics(random(10,30));
			if(!random(0,8))A_Vocalize(activesound);
		}wait;
	spawnstill:
		MINZ C 0 A_Jump(128,"scan","scan","spawnwander");
		MINZ C 0{
			A_HDLook();
			A_Recoil(random(-1,1)*0.4);
		}
		MINZ CD 5{angle+=random(-4,4);}
		MINZ AB 5{
			A_HDLook();
			if(!random(0,15))A_Vocalize(activesound);
			angle+=random(-4,4);
		}
		MINZ B 1 A_SetTics(random(10,40));
		---- A 0 setstatelabel("spawn");
	spawnwander:
		MINZ A 0 A_HDLook();
		MINZ CD 5 A_HDWander();
		MINZ AB 5{
			A_HDLook();
			if(!random(0,15))A_Vocalize(activesound);
			A_HDWander();
		}
		MINZ A 0 A_Jump(196,"spawn");
		loop;
	see2:
		MINZ A 0{
			if(!mags&&thismag<1)setstatelabel("reload");
			else bfrightened=0;
		}
		MINZ ABCD 5 A_HDChase();
		MINZ A 0 A_Jump(196,"see2");
		---- A 0 setstatelabel("scan");
	missile:
		MINZ ABCD 3 A_TurnTowardsTarget("aim");
		loop;
	aim:
		MINZ E 4{
			if(target){
				coverdir=(angleto(target),atan2(pos.z-target.pos.z,distance2d(target)));
				if(target.spawnhealth()>random(50,1000))superauto=true;
			}
		}
		MINZ E 0 A_TurnTowardsTarget("scanshoot",5,5);
		loop;
	see:
	scan:
		MINZ E 2{
			turnleft=randompick(0,0,0,1);
			if(turnleft)angle-=frandom(18,24);
			else angle+=frandom(18,24);
		}
	scanturn:
		MINZ EEEEEE 3 A_ScanForTargets();
		MINZ E 0 A_Jump(32,"scanturn","scanturn","scan");
		---- A 0 setstatelabel("see2");
	scanshoot:
		MINZ E 1{
			angle+=frandom(-2,2);
			pitch+=frandom(-2,2);
		}
		//fallthrough to shoot
	shoot:
		MINZ F 1 bright light("SHOT") A_VulcGuyShot();
   MINZ F 1 bright light("SHOT");//extra frame to mimic weapon delay
		MINZ E 2 A_JumpIf(superauto,"shoot");
		loop;
	postshot:
		MINZ E 1{
			turnleft=randompick(0,0,0,1);
			if(turnleft)angle-=frandom(3,6);
			else angle+=frandom(3,6);
		}
	considercover:
		MINZ E 0 A_JumpIf(thismag<1&&mags<1,"reload");
		MINZ E 0 A_JumpIf(target&&target.health>0&&!checksight(target),"cover");
		MINZ E 3 A_ScanForTargets();
		---- A 0 setstatelabel("scan");
	cover:
		MINZ E 0 A_JumpIf(
			!target
			||target.health<1
			||hdmobai.tryshoot(self,pradius:6,pheight:6,flags:hdmobai.TS_GEOMETRYOK),
			"see"
		);
		MINZ E 0{
			superauto=randompick(0,0,0,0,0,0,1);
			angle+=clamp(coverdir.x-angle,-20,20);
			pitch=clamp(coverdir.y-angle,-20,20);
			if(!random(0,99))setstatelabel("see");
		}
		MINZ EEEEEE 2 A_JumpIf(
			!target
			||checksight(target)
			||!random(0,20)
		,"scanshoot");
		loop;
	shuntmag:
		MINZ E 1;
		MINZ E 3{
			A_StartSound("weapons/vulcshunt",8);
			if(thismag>=0){
				actor mmm=HDMagAmmo.SpawnMag(self,"HD9mMag30",0);
				mmm.A_ChangeVelocity(3,frandom(-3,2),frandom(0,-2),CVF_RELATIVE|CVF_REPLACE);
			}
			thismag=-1;
			if(mags>0){
				mags--;
				thismag=30;
			}
		}
		---- A 0 setstatelabel("shoot");
	chamber:
		MINZ E 3{
			if(chambers<5&&thismag>0){
				thismag--;
				chambers++;
				A_StartSound("weapons/rifleclick2",8,CHANF_OVERLAP);
			}
		}
		---- A 0 setstatelabel("shoot");

	reload:
		MINZ A 0{
			if(!target||!checksight(target))setstatelabel("loadamag");
			bfrightened=true;
		}
		MINZ ABCD 5 A_Chase(null,null);
	loadamag:
		MINZ E 9 A_StartSound("weapons/pocket",9);
		MINZ E 7 A_StartSound("weapons/vulcmag",8);
		MINZ E 10{
			if(thismag<0)thismag=30;
			else if(mags<4)mags++;
			else{
				setstatelabel("see2");
				return;
			}A_StartSound("weapons/rifleclick2",8);
		}loop;

	melee:
		MINZ DAB 2 A_FaceTarget(10,10);
		MINZ C 6 A_FaceTarget();
		MINZ D 2;
		MINZ E 3 A_CustomMeleeAttack(
			random(9,99),"weapons/smack","","none",randompick(0,0,0,1)
		);
		MINZ E 2 A_JumpIfTargetInsideMeleeRange(2);
		---- A 0 setstatelabel("considercover");
		MINZ E 0 A_JumpIf(target.health<random(-3,1),"see");
		MINZ EC 2;
		---- A 0 setstatelabel("melee");

	pain:
		MINZ G 3;
		MINZ G 3 A_Vocalize(painsound);
		MINZ G 0 A_Jump(196,"see","scan");
		---- A 0 setstatelabel("missile");


	death:
		MINZ H 5;
		MINZ I 5{
			A_GibSplatter();
			A_Vocalize(deathsound);
		}
		MINZ J 5 A_GibSplatter();
		MINZ KL 5;
		MINZ M 5;
	dead:
		MINZ M 3;
		MINZ N 5 canraise{
			if(abs(vel.z)>1)setstatelabel("dead");
		}wait;
	deadgib:
		MINZ LKO 3;
		MINZ P 3{
		 A_GibSplatter();
			A_XScream();
		}
		MINZ R 2;
		MINZ QRS 5;
		---- A 0 setstatelabel("gibbed");

	gib:
		MINZ O 5;
		MINZ P 3{
		 A_GibSplatter();
			A_XScream();
		}
		MINZ R 2 A_GibSplatter();
		MINZ Q 5;
		MINZ Q 0 A_GibSplatter();
		MINZ RS 5 A_GibSplatter();
	gibbed:
		MINZ STUV 3;
		MINZ W 5 canraise{
			if(abs(vel.z)>1)setstatelabel("dead");    
		}wait;
	raise:
		MINZ N 2 A_GibSplatter();
		MINZ NML 6;
		MINZ KJIH 4;
		#### A 0 A_Jump(256,"see");
	ungib:
		MINZ W 6 A_GibSplatter();
		MINZ WV 12 A_GibSplatter();
		MINZ UTSR 7;
		MINZ QPOH 5;
		#### A 0 A_Jump(256,"see");
	}
}
