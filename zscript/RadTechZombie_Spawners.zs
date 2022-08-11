class RadTechZombie_Spawner : EventHandler
{

override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {

// 10mm Pistol Zombies
   case 'UndeadHomeboy' 			: if (!random(0, 3)) 
    {e.Replacement = "TenMilHomeboy";} break;

   case 'ZombieSMGStormtrooper'   : if (!random(0, 5)) 
    {e.Replacement = "TenMilHomeboy";} break;

   case 'ZombieSemiStormtrooper'  : if (!random(0, 7)) 
    {e.Replacement = "TenMilHomeboy";} break;

   case 'ZombieAutoStormtrooper'  : if (!random(0, 9)) 
    {e.Replacement = "TenMilHomeboy";} break;

// SigCow Zombies
   case 'UndeadHomeboy' 			      : if (!random(0, 3)) 
    {e.Replacement = "TenMilRifleman";} break;

   case 'ZombieSMGStormtrooper'  	: if (!random(0, 3)) 
    {e.Replacement = "TenMilRifleman";} break;

   case 'ZombieSemiStormtrooper' 	: if (!random(0, 4)) 
    {e.Replacement = "TenMilRifleman";} break;

   case 'ZombieAutoStormtrooper' 	: if (!random(0, 5)) 
    {e.Replacement = "TenMilRifleman";} break;

// Doomed Shotgun Zombies

 		case 'HideousJackbootReplacer' : if (!random(0, 3)) 
    {e.Replacement = "DoomedJackboot";} break;

   case 'DeadJackboot' 		        	: if (!random(0, 3))    
    {e.Replacement = "DeadDoomedJackboot";} break;

// Combat Shotgun Jackboots
   case 'HideousJackbootReplacer' : if (!random(0, 3)) 
    {e.Replacement = "CombatJackboot";} break;

   case 'DeadJackboot'      : if (!random(0, 3))        
    {e.Replacement = "DeadCombatJackboot";} break;

// Riot Cop Zombies
   case 'HideousJackbootReplacer' : if (!random(0, 3)) 
    {e.Replacement = "RiotCopZombie";} break;

   case 'DeadJackboot'      : if (!random(0, 3))        
    {e.Replacement = "DeadRiotCopZombie";} break;

// Minerva Zombies	
   case 'VulcanetteZombie' : if (!random(0, 3))
    {e.Replacement = "MinervaZombie";} break;

  // because i hate HERPs so, so much >:(
   case 'EnemyHERP'        : if (!random(0, 1))
    {e.Replacement = "MinervaZombie";} break;

//no more zombies to add (yet)

		}

	e.IsFinal = false;
	}
}
