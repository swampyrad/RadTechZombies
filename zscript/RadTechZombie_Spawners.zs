// Struct for Enemyspawn information. 
class RTZSpawnEnemy play
{
	string spawnname; // ID by string for spawner
	Array<RTZSpawnEnemyEntry> spawnreplaces; // ID by string for spawnees
	int spawnreplacessize; // Cached size of the above array
	bool isPersistent; // Whether or not to persistently spawn.
	bool replaceEnemy;
}

class RTZSpawnEnemyEntry play
{
	string name;
	int    chance;
}

// One handler to rule them all. 
class RadtechZombiesHandler : EventHandler
{
	// List of persistent classes to completely ignore. 
	// This -should- mean this mod has no performance impact. 
	static const class<actor> blacklist[] =
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
	array<RTZSpawnEnemy> Enemyspawnlist;
	int Enemyspawnlistsize;
	
	// appends an entry to Enemyspawnlist;
	void addEnemy(string name, Array<RTZSpawnEnemyEntry> replacees, bool persists, bool rep=true)
	{
		// Creates a new struct;
		RTZSpawnEnemy spawnee = RTZSpawnEnemy(new('RTZSpawnEnemy'));
		
		// Populates the struct with relevant information,
		spawnee.spawnname = name;
		spawnee.isPersistent = persists;
		spawnee.replaceEnemy = rep;
		for(int i = 0; i < replacees.size(); i++)
		{
			spawnee.spawnreplaces.push(replacees[i]);
			spawnee.spawnreplacessize++;
		}
		
		// Pushes the finished struct to the array. 
		Enemyspawnlist.push(spawnee);
		Enemyspawnlistsize++;
	}

	RTZSpawnEnemyEntry addEnemyentry(string name, int chance)
	{
		// Creates a new struct;
		RTZSpawnEnemyEntry spawnee = RTZSpawnEnemyEntry(new('RTZSpawnEnemyEntry'));
		spawnee.name = name.makelower();
		spawnee.chance = chance;
		return spawnee;
		
	}
	bool cvarsAvailable;
	
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
		addEnemy('SpecZombieDog', spawns_cloaked_zombiedog, cloaked_zombiedog_persistent_spawning);

    // Dead Zombie Dog
		Array<RTZSpawnEnemyEntry> spawns_dead_zombiedog;  
		spawns_dead_zombiedog.push(addEnemyentry('DeadBabuin', zombiedog_spawn_bias));
		addEnemy('DeadZombieDog', spawns_dead_zombiedog, zombiedog_persistent_spawning);

    // Dead Cloaked Zombie Dog 
		Array<RTZSpawnEnemyEntry> spawns_dead_cloaked_zombiedog;  
		spawns_dead_cloaked_zombiedog.push(addEnemyentry('DeadSpecBabuin', cloaked_zombiedog_spawn_bias));
		addEnemy('DeadSpecZombieDog', spawns_dead_cloaked_zombiedog, cloaked_zombiedog_persistent_spawning);


    // 10mm Rifleman
		Array<RTZSpawnEnemyEntry> spawns_TenMilRifleman;  
		spawns_TenMilRifleman.push(addEnemyentry('ZombieSemiStormtrooper', tenmilrifl_zombieman_spawn_bias));
		spawns_TenMilRifleman.push(addEnemyentry('ZombieAutoStormtrooper', tenmilrifl_zombieman_spawn_bias));
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
		addEnemy('BayonetRifleman', spawns_Bayonetta, bayonetta_persistent_spawning);

    // Melee Zombiemen (God damn these dudes are everywhere - [Ted])
		Array<RTZSpawnEnemyEntry> spawns_meleezombie;  
		spawns_meleezombie.push(addEnemyentry('UndeadHomeboy', meleezomb_homeboy_spawn_bias));
		spawns_meleezombie.push(addEnemyentry('ZombieSemiStormtrooper', meleezomb_zombieman_spawn_bias));
		spawns_meleezombie.push(addEnemyentry('ZombieAutoStormtrooper', meleezomb_zombieman_spawn_bias));
		spawns_meleezombie.push(addEnemyentry('UndeadJackbootman', meleezomb_jackboot_spawn_bias));
		spawns_meleezombie.push(addEnemyentry('VulcanetteZombie', meleezomb_chaingunner_spawn_bias));
		addEnemy('MeleeZombie', spawns_meleezombie, meleezomb_persistent_spawning);

    // Brawler Jackboot
		Array<RTZSpawnEnemyEntry> spawns_brawler;  
		spawns_brawler.push(addEnemyentry('Jackboot', brawler_jackboot_spawn_bias));
		spawns_brawler.push(addEnemyentry('DeadJackboot', brawler_jackboot_spawn_bias));
		addEnemy('BrawlerJackboot', spawns_brawler, brawler_persistent_spawning);

    // Combat Shotgunner
		Array<RTZSpawnEnemyEntry> spawns_combatjackboot;  
		spawns_combatjackboot.push(addEnemyentry('Jackboot', combshot_jackboot_spawn_bias));
		spawns_combatjackboot.push(addEnemyentry('UndeadJackbootman', combshot_jackboot_spawn_bias));
		addEnemy('CombatJackboot', spawns_combatjackboot, combshot_persistent_spawning);

    // Doomed Jackboot
		Array<RTZSpawnEnemyEntry> spawns_doomjackboot;  
		spawns_doomjackboot.push(addEnemyentry('Jackboot', doomjack_jackboot_spawn_bias));
		spawns_doomjackboot.push(addEnemyentry('UndeadJackbootman', doomjack_jackboot_spawn_bias));
		addEnemy('DoomedJackboot', spawns_doomjackboot, doomjack_persistent_spawning);

    // Riot Police Zombie
		Array<RTZSpawnEnemyEntry> spawns_riotcop;  
		spawns_riotcop.push(addEnemyentry('Jackboot', riot_jackboot_spawn_bias));
		spawns_riotcop.push(addEnemyentry('UndeadJackbootman', riot_jackboot_spawn_bias));
		addEnemy('RiotCopZombie', spawns_riotcop, riot_persistent_spawning);

    // Minerva Chaingunner
		Array<RTZSpawnEnemyEntry> spawns_minervazomb;  
		spawns_minervazomb.push(addEnemyentry('VulcanetteZombie', minervazomb_chaingunner_spawn_bias));
		spawns_minervazomb.push(addEnemyentry('EnemyHERP', minervazomb_herp_spawn_bias));
		addEnemy('MinervaZombie', spawns_minervazomb, minervazomb_persistent_spawning);
}
	
	// Random stuff, stores it and forces negative values just to be 0.
	bool giverandom(int chance)
	{
		bool result = false;
		int iii = random(0, chance);
		if(iii < 0)
			iii = 0;
		if (iii == 0)
		{
			if(chance > -1)
				result = true;
		}
		
		return result;
	}

	// Tries to create the Enemy via random spawning.
	bool trycreateEnemy(worldevent e, RTZSpawnEnemy f, int g, bool rep)
	{
		bool result = false;
		if(giverandom(f.spawnreplaces[g].chance))
		{
			vector3 spawnpos = e.thing.pos;
			let spawnEnemy = Actor.Spawn(f.spawnname, (spawnpos.x, spawnpos.y, spawnpos.z));
			if(spawnEnemy)
			{
				if(rep)
				{
					e.thing.destroy();
					result = true;
				}
			}
		}
		return result;
	}
	
	override void worldthingspawned(worldevent e)
	 {
		string candidatename;
		
		// loop controls.
		int i, j;
		
		// Populates the main arrays if they haven't been already. 
		if(!cvarsAvailable)
			init();
		
		
		for(i = 0; i < blacklist.size(); i++)
		{
			if (e.thing is blacklist[i])
				return;
		}
		
		// Checks for null events. 
		if(!e.Thing)
		{
			return;
		}

		candidatename  = e.Thing.GetClassName();
		candidatename = candidatename.makelower();
		
		// Iterates through the list of Enemy candidates for e.thing.
		for(i = 0; i < Enemyspawnlistsize; i++)
		{
			// Tries to cast the Enemy as an inventory. 
			let thing_inv_ptr = Inventory(e.thing);
		
			// Checks if the Enemy in question is owned.
			bool owned = thing_inv_ptr && (thing_inv_ptr.owner);

			// Checks if the level has been loaded more than 1 tic.
			bool prespawn = !(level.maptime > 1);
			
			// Checks if persistent spawning is on.
			bool persist = (Enemyspawnlist[i].isPersistent);
			
			// if an Enemy is owned or is an ammo (doesn't retain owner ptr), 
			// do not replace it. 
			if ((prespawn || persist) && (!owned && prespawn))
			{
				int original_i = i;
				for(j = 0; j < Enemyspawnlist[original_i].spawnreplacessize; j++)
				{
					if(Enemyspawnlist[i].spawnreplaces[j].name == candidatename)
					{
						if(trycreateEnemy(e, Enemyspawnlist[i], j, Enemyspawnlist[i].replaceEnemy))
						{
							j = Enemyspawnlist[i].spawnreplacessize;
							i = Enemyspawnlistsize;
						}
					}
				}
			}
		}
	}
}