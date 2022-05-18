class TenMilHomeboy_Spawner : EventHandler
{

override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
		case 'UndeadHomeboy' 			: if (!random(0, 2)) {e.Replacement = "TenMilHomeboy";} break;

	case 'ZombieSMGStormtrooper' 			: if (!random(0, 5)) {e.Replacement = "TenMilHomeboy";} break;

  case 'ZombieSemiStormtrooper' 			: if (!random(0, 7)) {e.Replacement = "TenMilHomeboy";} break;

  case 'ZombieAutoStormtrooper' 			: if (!random(0, 9)) {e.Replacement = "TenMilHomeboy";} break;

		}

	e.IsFinal = false;
	}
}
