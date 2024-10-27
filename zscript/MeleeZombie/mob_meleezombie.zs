// ------------------------------------------------------------
// Melee Zombie, want to kill fast but bullets too slow
//   ------------------------------------------------------------
class MeleeZombie:UndeadHomeboy{
	
    override void postbeginplay(){
		super.postbeginplay();
   
		bhasdropped=false;

	thismag=0;
	chamber=0;
	firemode=-1;
	}

	default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Melee Zombie"
		//$Sprite "POSSA1"

		seesound "meleezombie/sight";
		painsound "meleezombie/pain";
		deathsound "meleezombie/death";
		activesound "meleezombie/active";
		meleesound "meleezombie/bite";
		hdmobbase.stepsound "meleezombie/step";
		hdmobbase.stepsoundwet "meleezombie/wormstep";
		
		tag "$melee_zombie";//"...brrrraaaaaiiiiiinnnnssssss..."
        
        +nofear //zombies have no sense of self preservation     
        +ambush //zombies wait in silence
		-nodropoff//zombies are too dumb not to walk off cliffs
		+SLIDESONWALLS

    	scale 1.2;
		radius 10;
		speed 3;
		mass 100;
		painchance 200;
		obituary "%o became zombie chow.";
		hitobituary "%o became zombie chow.";
		meleerange 36;//the default of 44 gives them too much reach
	}

override void deathdrop(){}

	states{
	spawn:
		ZOMB F 1{
		    switch(random(0,5)){//rolls a random color
		    
		    case 0://defaults to green
		    break;
		    
		    case 1:
		    A_SetTranslation("Zombie_RedSuit");
		    break;
		    
		    case 2:
		    A_SetTranslation("Zombie_YellowSuit");
		    break;
		    
		    case 3:
		    A_SetTranslation("Zombie_OrangeSuit");
		    break;
		    
		    case 4:
		    A_SetTranslation("Zombie_BlueSuit");
		    break;
		    
		    case 5:
		    A_SetTranslation("Zombie_PinkSuit");
		    break;
		    
		    }
			A_HDLook();
		}
		#### FFF random(5,17) A_HDLook();
		#### F 1{
			//A_Recoil(frandom(-0.1,0.1));
			A_SetTics(random(10,40));
		}
		#### B 0 A_Jump(132,"spawnswitch");
		#### B 8 A_Recoil(frandom(-0.2,0.2));
		loop;
	spawnswitch:
		#### A 0 A_JumpIf(bambush,"spawnstill");
		goto spawnwander;
	spawnstill:
		#### A 0 A_Look();
		//#### A 0 A_Recoil(random(-1,1)*0.4);
		#### CD 5 A_SetAngle(angle+random(-4,4));
		#### A 0{
			A_Look();
			//if(!random(0,127))A_Vocalize(activesound);
		}
		#### AB 5 A_SetAngle(angle+random(-4,4));
		#### B 1 A_SetTics(random(10,40));
		loop;
	spawnwander:
		#### CDAB 5 A_HDWander();
		#### A 0 A_Jump(64,"spawnswitch");
		loop;

	see:
		#### ABCD random(9,10) A_HDChase();
		loop;

    missile://lunge code borrowed from babuin latch attack 
		#### ABCD 10{
			A_FaceTarget(16,16);
			bnodropoff=false;
			A_Changevelocity(1,0,0,CVF_RELATIVE);
			if(A_JumpIfTargetInLOS("null",20,0,128)){
				//A_Vocalize(seesound);
				setstatelabel("hunger");
			}
		}
		---- A 0 setstatelabel("see");
	hunger:
	    #### FFEEEF 4 A_HDChase();
		---- A 0 setstatelabel("missile");
    
	meleebody:
		#### FE 3;//randomizes between scratching or punching
		#### G 5 {if(!random(0,2))A_HumanoidMeleeAttack(height*0.6);
		          else A_CustomMeleeAttack(random(10,20),"bandage/rip","","nails",true);
                 }
        #### EF 3;
		#### A 0 setstatelabel("meleeend");

    meleehead://zombie bite attack
    	#### FE 5;
		#### G 6 {
			pitch+=frandom(-40,-8);
			A_HumanoidMeleeAttack(height*0.7);
			meleerange=16;//has to be really close to bite you
			A_CustomMeleeAttack(random(20,40),meleesound,"","teeth",true);
		    meleerange=36;
		}
		#### EF 5;
		#### A 0 setstatelabel("meleeend");

	pain:
		ZOMB G 2;
		#### G 5 A_Vocalize(painsound);
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
		}//zombie staggers a bit after being attacked
		#### ABCD 3 A_HDChase();
		#### G 0{bfrightened=false;}
		---- A 0 setstatelabel("see");
		
	falldown:
		#### H 5;
		#### I 5 A_Vocalize(deathsound);
		#### JJKKK 2 A_SetSize(-1,max(deathheight,height-10));
		#### L 0 A_SetSize(-1,deathheight);
		#### L 5;
		#### M 10 A_KnockedDown();
		wait;
	standup:
		#### LK 6;
		#### J 0 A_Jump(160,2);
		#### J 0 A_Vocalize(seesound);
		#### JI 4 A_Recoil(-0.3);
		#### HE 6;
		#### A 0 setstatelabel("see");
		
	death:
		#### H 5;
		#### I 5 A_Vocalize(deathsound);
		#### J 5 A_NoBlocking();
		#### K 5;
	dead:
		#### L 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### M 5 canraise{if(abs(vel.z)>=2.)setstatelabel("dead");}
		wait;
	deadgib:
		POSS M 5;
		#### M 5{
			A_GibSplatter();
			A_XScream();
		}
		#### OPQRST 5;
		goto gibbed;
	gib:
		POSS M 5;
		#### M 5{
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
		ZOMB L 4;
		#### LK 6;
		#### JIH 4;
		#### A 0 A_Jump(256,"see");
	ungib:
		POSS U 12;
		#### T 8;
		#### SRQ 6;
		#### PONM 4;
		ZOMB A 0 A_Jump(256,"see");
	}

}

// color variations
class MeleeZombie_Red:MeleeZombie{default{translation "Zombie_RedSuit";}}
class MeleeZombie_Blue:MeleeZombie{default{translation "Zombie_BlueSuit";}}
class MeleeZombie_Yellow:MeleeZombie{default{translation "Zombie_YellowSuit";}}
class MeleeZombie_Orange:MeleeZombie{default{translation "Zombie_OrangeSuit";}}
class MeleeZombie_Pink:MeleeZombie{default{translation "Zombie_PinkSuit";}}

class MeleeZombieDropper:RandomSpawner{
    default{
    dropitem "MeleeZombie",255,10;
    dropitem "MeleeZombie_Red",255, 8;
    dropitem "MeleeZombie_Orange",255,6;
    dropitem "MeleeZombie_Yellow",255,4;
    dropitem "MeleeZombie_Blue",255,2;
    dropitem "MeleeZombie_Pink",255,1;
    }
}

