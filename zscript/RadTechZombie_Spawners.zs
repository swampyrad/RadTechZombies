class RadTechZombie_Spawner : EventHandler
{

override void CheckReplacement(ReplaceEvent RadTech) {
	switch (RadTech.Replacee.GetClassName()) {

   case 'UndeadHomeboy' 		   	: 
    if (Allow_10mmHomeboys&&!random(0, 3)){
      RadTech.Replacement = "TenMilHomeboy";} break;
    if (Allow_MeleeZombies&&!random(0, 9)){
      RadTech.Replacement = "MeleeZombie";} break;


   case 'ZombieSemiStormtrooper' 	: 
    if (Allow_10mmHomeboys&&!random(0, 3)){
      RadTech.Replacement = "TenMilHomeboy";}
    if (Allow_10mmRiflemen&&!random(0, 7)){
     RadTech.Replacement = "TenMilRifleman";}
    if (Allow_BayonetRiflemen&&!random(0, 3)){
     RadTech.Replacement = "BayonetRifleman";} break;
        if (Allow_MeleeZombies&&!random(0, 9)){
      RadTech.Replacement = "MeleeZombie";} break;


   case 'ZombieAutoStormtrooper' 	: 
    if (Allow_10mmRiflemen&&!random(0, 5)){
      RadTech.Replacement = "TenMilRifleman";} 
    if (Allow_BayonetRiflemen&&!random(0, 3)){
     RadTech.Replacement = "BayonetRifleman";} break;
    if (Allow_MeleeZombies&&!random(0, 9)){
      RadTech.Replacement = "MeleeZombie";} break;



   case 'Jackboot'            : 
    if (Allow_BrawlerJackboots&&!random(0, 3)){
      RadTech.Replacement = "BrawlerJackboot";}  
	if (Allow_CombatJackboots&&!random(0, 3)){
      RadTech.Replacement = "CombatJackboot";}  
    if (Allow_DoomedJackboots&&!random(0, 5)){
      RadTech.Replacement = "DoomedJackboot";} 
    if (Allow_RiotJackboots&&!random(0, 5)){
      RadTech.Replacement = "RiotCopZombie";} break;


   case 'UndeadJackbootman'   : 
    if (Allow_CombatJackboots&&!random(0, 3)){
      RadTech.Replacement = "CombatJackboot";}  
    if (Allow_DoomedJackboots&&!random(0, 5)){
      RadTech.Replacement = "DoomedJackboot";} 
    if (Allow_RiotJackboots&&!random(0, 5)){
      RadTech.Replacement = "RiotCopZombie";} 
    if (Allow_10mmHomeboys&&!random(0, 3)){
      RadTech.Replacement = "TenMilHomeboy";} break;
        if (Allow_MeleeZombies&&!random(0, 9)){
      RadTech.Replacement = "MeleeZombie";} break;


   case 'DeadJackboot'        : 
    if (Allow_CombatJackboots&&!random(0, 3)){
      RadTech.Replacement = "DeadCombatJackboot";} 
    if (Allow_DoomedJackboots&&!random(0, 5)){
      RadTech.Replacement = "DeadDoomedJackboot";} 
    if (Allow_RiotJackboots&&!random(0, 5)){
      RadTech.Replacement = "DeadRiotCopZombie";} break;
    if (Allow_BrawlerJackboots&&!random(0, 15)){
      RadTech.Replacement = "BrawlerJackboot";}  
    if (Allow_MeleeZombies&&!random(0, 19)){
      RadTech.Replacement = "MeleeZombie";} break;


// Minerva Zombies	
   case 'VulcanetteZombie'    : 
    if (Allow_MinervaGunners&&!random(0, 3)){
      RadTech.Replacement = "MinervaZombie";} break;
    if (Allow_MeleeZombies&&!random(0, 9)){
      RadTech.Replacement = "MeleeZombie";} break;


  // because i hate HERPs so, so much >:(
   case 'EnemyHERP'           :  
    if (Allow_MinervaGunners&&!random(0, 1)){
      RadTech.Replacement = "MinervaZombie";} break;

//no more zombies to add (yet)

		}

	RadTech.IsFinal = false;
	}
}


