class MinervaZombie_Spawner : EventHandler
{

override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
		case 'VulcanetteZombie': if (!random(0, 2)){
   e.Replacement = "MinervaZombie";}
   break;

		}

	e.IsFinal = false;
	}
}
