class DoomedShotgunner_Spawner : EventHandler
{

override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
		case 'HideousJackbootReplacer' 			: if (!random(0, 2)) {e.Replacement = "DoomedJackboot";} break;

  case 'DeadJackboot' 			: if (!random(0, 2))        {e.Replacement = "DeadDoomedJackboot";} break;

		}

	e.IsFinal = false;
	}
}
