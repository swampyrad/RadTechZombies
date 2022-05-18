class TenMilRifleman_Spawner : EventHandler
{

override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
		case 'UndeadHomeboy' 			: if (!random(0, 2)) {e.Replacement = "TenMilRifleman";} break;

	case 'ZombieSMGStormtrooper' 			: if (!random(0, 3)) {e.Replacement = "TenMilRifleman";} break;

  case 'ZombieSemiStormtrooper' 			: if (!random(0, 4)) {e.Replacement = "TenMilRifleman";} break;

  case 'ZombieAutoStormtrooper' 			: if (!random(0, 5)) {e.Replacement = "TenMilRifleman";} break;

		}

	e.IsFinal = false;
	}
}
