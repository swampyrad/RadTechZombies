class MinervaZombie_Spawner : EventHandler
{

override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
case 'VulcanetteZombie': if (!random(0, 2)){
   e.Replacement = "MinervaZombie";}
   break;

//because i hate HERPs so, so much >:(
case 'EnemyHERP': if (!random(0, 1)){
   e.Replacement = "MinervaZombie";}
   break;


		}

	e.IsFinal = false;
	}
}
