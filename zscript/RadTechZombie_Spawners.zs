// Struct for Enemyspawn information. 
class RTZSpawnEnemy play
{
	// ID by string for spawner
	string spawnName;

	// ID by string for spawnees
	Array<RTZSpawnEnemyEntry> spawnReplaces;
	
	// Whether or not to persistently spawn.
	bool isPersistent;
	
	bool replaceEnemy;

	string toString()
	{

		let replacements = "[";
		if (spawnReplaces.size()) {
			replacements = replacements..spawnReplaces[0].toString();

			foreach (spawnReplace : spawnReplaces) replacements = replacements..", "..spawnReplace.toString();
		}
		replacements = replacements.."]";


		return String.format("{ spawnName=%s, spawnReplaces=%s, isPersistent=%b, replaceEnemy=%b }", spawnName, replacements, isPersistent, replaceEnemy);
	}
}

class RTZSpawnEnemyEntry play
{
	string name;
	int    chance;

	string toString()
	{
		return String.format("{ name=%s, chance=%s }", name, chance >= 0 ? "1/"..(chance + 1) : "never");
	}
}

// One handler to rule them all. 
class RadtechZombiesHandler : EventHandler
{
	// List of persistent classes to completely ignore. 
	// This -should- mean this mod has no performance impact. 
	static const string blacklist[] =
	{
		"HDSmoke",
		"BloodTrail",
		"CheckPuff",
		"WallChunk",
		"HDBulletPuff",
		"HDFireballTail",
		"ReverseImpBallTail",
		"HDSmokeChunk",
		"ShieldSpark",
		"HDFlameRed",
		"HDMasterBlood",
		"PlantBit",
		"HDBulletActor",
		"HDLadderSection"
	};
	
	// List of Enemy-spawn associations.
	// used for Enemy-replacement on mapload. 
	array<RTZSpawnEnemy> EnemySpawnList;
	
	bool cvarsAvailable;
	
	// appends an entry to Enemyspawnlist;
	void addEnemy(string name, Array<RTZSpawnEnemyEntry> replacees, bool persists, bool rep=true)
	{
		if (hd_debug) {
			let msg = "Adding "..(persists ? "Persistent" : "Non-Persistent").." Replacement Entry for "..name..": ["..replacees[0].toString();

			if (replacees.size() > 1) foreach (replacee : replacees) msg = msg..", "..replacee.toString();

			console.printf(msg.."]");
		}

		// Creates a new struct;
		RTZSpawnEnemy spawnee = RTZSpawnEnemy(new('RTZSpawnEnemy'));
		
		// Populates the struct with relevant information,
		spawnee.spawnName = name;
		spawnee.isPersistent = persists;
		spawnee.replaceEnemy = rep;
		
		foreach (replacee : replacees) spawnee.spawnReplaces.push(replacee);
		
		// Pushes the finished struct to the array. 
		enemySpawnList.push(spawnee);
	}

	RTZSpawnEnemyEntry addEnemyEntry(string name, int chance)
	{
		// Creates a new struct;
		RTZSpawnEnemyEntry spawnee = RTZSpawnEnemyEntry(new('RTZSpawnEnemyEntry'));
		spawnee.name = name.makeLower();
		spawnee.chance = chance;
		return spawnee;
	}
	
	// Populates the replacement and association arrays. 
	void init()
	{
		cvarsAvailable = true;
		
    // --------------------
		// Enemy spawn lists.
    // --------------------

    // Zombie Dog
		Array<RTZSpawnEnemyEntry> spawns_zombiedog;  
		spawns_zombiedog.push(addEnemyentry('Babuin', zombiedog_spawn_bias));
		addEnemy('ZombieDog', spawns_zombiedog, zombiedog_persistent_spawning);

    // Cloaked Zombie Dog 
		Array<RTZSpawnEnemyEntry> spawns_cloaked_zombiedog;  
		spawns_cloaked_zombiedog.push(addEnemyentry('SpecBabuin', cloaked_zombiedog_spawn_bias));
		spawns_cloaked_zombiedog.push(addEnemyentry('NinjaPirate', cloaked_zombiedog_spawn_bias));
		addEnemy('SpecZombieDog', spawns_cloaked_zombiedog, cloaked_zombiedog_persistent_spawning);


    // Dead Zombie Dog
		Array<RTZSpawnEnemyEntry> spawns_dead_zombiedog;  
		spawns_dead_zombiedog.push(addEnemyentry('DeadBabuin', zombiedog_spawn_bias));
		addEnemy('DeadZombieDog', spawns_dead_zombiedog, zombiedog_persistent_spawning);

    // Dead Cloaked Zombie Dog 
		Array<RTZSpawnEnemyEntry> spawns_dead_cloaked_zombiedog;  
		spawns_dead_cloaked_zombiedog.push(addEnemyentry('DeadSpecBabuin', cloaked_zombiedog_spawn_bias));
	    spawns_dead_cloaked_zombiedog.push(addEnemyentry('DeadNinjaPirate', cloaked_zombiedog_spawn_bias));
		addEnemy('DeadSpecZombieDog', spawns_dead_cloaked_zombiedog, cloaked_zombiedog_persistent_spawning);


    // 10mm Rifleman
		Array<RTZSpawnEnemyEntry> spawns_TenMilRifleman;  
		spawns_TenMilRifleman.push(addEnemyentry('ZombieSemiStormtrooper', tenmilrifl_zombieman_spawn_bias));
		spawns_TenMilRifleman.push(addEnemyentry('ZombieAutoStormtrooper', tenmilrifl_zombieman_spawn_bias));
		spawns_TenMilRifleman.push(addEnemyentry('ZombieSMGStormtrooper', tenmilrifl_zombieman_spawn_bias));
		addEnemy('TenMilRifleman', spawns_TenMilRifleman, tenmilrifl_persistent_spawning);

    // 10mm Pistol Zombie
		Array<RTZSpawnEnemyEntry> spawns_TenMilHomeboy;  
		spawns_TenMilHomeboy.push(addEnemyentry('UndeadHomeboy', tenmilpis_zombieman_spawn_bias));
		spawns_TenMilHomeboy.push(addEnemyentry('ZombieSemiStormtrooper', tenmilpis_zombieman_spawn_bias));
		spawns_TenMilHomeboy.push(addEnemyentry('UndeadJackbootman', tenmilpis_zombieman_spawn_bias));
		addEnemy('TenMilHomeboy', spawns_TenMilHomeboy, tenmilpis_persistent_spawning);

    // Sig-cow Bayonet Rifleman
		Array<RTZSpawnEnemyEntry> spawns_Bayonetta;  
		spawns_Bayonetta.push(addEnemyentry('ZombieSemiStormtrooper', bayonetta_zombieman_spawn_bias));
		spawns_Bayonetta.push(addEnemyentry('ZombieAutoStormtrooper', bayonetta_zombieman_spawn_bias));
		spawns_Bayonetta.push(addEnemyentry('ZombieSMGStormtrooper', bayonetta_zombieman_spawn_bias));
		addEnemy('BayonetRifleman', spawns_Bayonetta, bayonetta_persistent_spawning);

    // Melee Zombiemen (God damn these dudes are everywhere - [Ted])
		Array<RTZSpawnEnemyEntry> spawns_meleezombie;  
		spawns_meleezombie.push(addEnemyentry('UndeadHomeboy', meleezomb_homeboy_spawn_bias));
		spawns_meleezombie.push(addEnemyentry('ZombieSemiStormtrooper', meleezomb_zombieman_spawn_bias));
		spawns_meleezombie.push(addEnemyentry('ZombieAutoStormtrooper', meleezomb_zombieman_spawn_bias));
		spawns_meleezombie.push(addEnemyentry('ZombieSMGStormtrooper', meleezomb_zombieman_spawn_bias));
		spawns_meleezombie.push(addEnemyentry('Jackboot', meleezomb_jackboot_spawn_bias));
		spawns_meleezombie.push(addEnemyentry('JackAndJillboot', meleezomb_jackboot_spawn_bias));
		spawns_meleezombie.push(addEnemyentry('UndeadJackbootman', meleezomb_jackboot_spawn_bias));
		spawns_meleezombie.push(addEnemyentry('VulcanetteZombie', meleezomb_chaingunner_spawn_bias));
		addEnemy('MeleeZombie', spawns_meleezombie, meleezomb_persistent_spawning);

    // Brawler Jackboot
		Array<RTZSpawnEnemyEntry> spawns_brawler;  
		spawns_brawler.push(addEnemyentry('Jackboot', brawler_jackboot_spawn_bias));
		spawns_brawler.push(addEnemyentry('JackAndJillboot', brawler_jackboot_spawn_bias));
		spawns_brawler.push(addEnemyentry('UneadJackbootman', brawler_jackboot_spawn_bias));
		addEnemy('BrawlerJackboot', spawns_brawler, brawler_persistent_spawning);

    // Combat Shotgunner
		Array<RTZSpawnEnemyEntry> spawns_combatjackboot;  
		spawns_combatjackboot.push(addEnemyentry('Jackboot', combshot_jackboot_spawn_bias));
	    spawns_combatjackboot.push(addEnemyentry('JackAndJillboot', combshot_jackboot_spawn_bias));
		spawns_combatjackboot.push(addEnemyentry('UndeadJackbootman', combshot_jackboot_spawn_bias));
		addEnemy('CombatJackboot', spawns_combatjackboot, combshot_persistent_spawning);

    // Doomed Jackboot
		Array<RTZSpawnEnemyEntry> spawns_doomjackboot;  
		spawns_doomjackboot.push(addEnemyentry('Jackboot', doomjack_jackboot_spawn_bias));
		spawns_doomjackboot.push(addEnemyentry('JackAndJillboot', doomjack_jackboot_spawn_bias));
		spawns_doomjackboot.push(addEnemyentry('UndeadJackbootman', doomjack_jackboot_spawn_bias));
		addEnemy('DoomedJackboot', spawns_doomjackboot, doomjack_persistent_spawning);

    // Riot Police Zombie
		Array<RTZSpawnEnemyEntry> spawns_riotcop;  
		spawns_riotcop.push(addEnemyentry('Jackboot', riot_jackboot_spawn_bias));
	    spawns_riotcop.push(addEnemyentry('JackAndJillboot', riot_jackboot_spawn_bias));
		spawns_riotcop.push(addEnemyentry('UndeadJackbootman', riot_jackboot_spawn_bias));
		addEnemy('RiotCopZombie', spawns_riotcop, riot_persistent_spawning);

    // Minerva Chaingunner
		Array<RTZSpawnEnemyEntry> spawns_minervazomb;  
		spawns_minervazomb.push(addEnemyentry('VulcanetteZombie', minervazomb_chaingunner_spawn_bias));
		spawns_minervazomb.push(addEnemyentry('EnemyHERP', minervazomb_herp_spawn_bias));
		addEnemy('MinervaZombie', spawns_minervazomb, minervazomb_persistent_spawning);
}
	
	// Random stuff, stores it and forces negative values just to be 0.
	bool giveRandom(int chance)
	{
		if (chance > -1)
		{
			let result = random(0, chance);

			if (hd_debug) console.printf("Rolled a "..(result + 1).." out of "..(chance + 1));

			return result == 0;
		}
		
		return false;
	}

	// Tries to create the Enemy via random spawning.
	bool tryCreateEnemy(Actor thing, string spawnName, int chance, bool rep)
	{
		if (giveRandom(chance))
		{
			if (Actor.Spawn(spawnName, thing.pos) && rep)
			{
                if (hd_debug) console.printf(thing.getClassName().." -> "..spawnName);

				thing.destroy();

				return true;
			}
		}

		return false;
	}
	
	override void worldThingSpawned(WorldEvent e)
	 {
		// Populates the main arrays if they haven't been already. 
		if (!cvarsAvailable) init();
		
		// If thing spawned doesn't exist, quit
		if (!e.thing) return;

		// If thing spawned is blacklisted, quit
		foreach (bl : blacklist) if (e.thing is bl) return;

		string candidateName = e.thing.getClassName();
		candidateName = candidateName.makeLower();

		handleEnemyReplacements(e.thing, candidateName);
	}

	private void handleEnemyReplacements(Actor thing, string candidateName)
	{
		// Checks if the level has been loaded more than 1 tic.
		bool prespawn = !(level.maptime > 1);

		// Iterates through the list of Enemy candidates for e.thing.
		foreach (enemySpawn : enemySpawnList)
		{
			// if an Enemy is owned or is an ammo (doesn't retain owner ptr), 
			// do not replace it. 
			let item = Inventory(thing);
			if ((prespawn || enemySpawn.isPersistent) && (!(item && item.owner) && prespawn))
			{
				foreach (spawnReplace : enemySpawn.spawnReplaces)
				{
					if (spawnReplace.name == candidateName)
					{
						if (hd_debug) console.printf("Attempting to replace "..candidateName.." with "..enemySpawn.spawnName.."...");

						if (tryCreateEnemy(thing, enemySpawn.spawnName, spawnReplace.chance, enemySpawn.replaceEnemy)) return;
					}
				}
			}
		}
	}
}
