// director's floats
//
// director.state = number of spawnpoints
// director.delay =
// director.max_health = number of monster types coded
// director.armortype =
// director.armorvalue =
// director.runevar =
// director.runevector =
// director.aqflags = 1: use info_player_start
// director.rqflags =
// director.aqstate =
// director.rqstate =
//
// director's entities
//
// director.owner =
// director.runent =
// director.enemy = next monster enemy
// director.oldenemy =
// director.aiment =
// director.goalentity = next monster spawn location
// director.movetarget =

// total_monsters = total_monsters + 1;
// killed_monsters = killed_monsters + 1;
// WriteByte (MSG_ALL, SVC_KILLEDMONSTER);

// ==== Spawns ====

void (entity e) DirectorSpawnWalker = {

	setsize (e, '-16 -16 -24', '16 16 40'); // some spawnpoints would put ogres in walls
	e.solid = SOLID_SLIDEBOX;
	e.movetype = MOVETYPE_STEP;
	e.takedamage = DAMAGE_AIM;
	e.ideal_yaw	= e.angles * '0 1 0';
	e.yaw_speed = 20;
	e.view_ofs = '0 0 25';
	e.use = monster_use;
	e.flags	= self.flags | FL_MONSTER;
    setorigin (e, director.goalentity.origin);
    e.angles = director.goalentity.angles;

	e.enemy = director.enemy;
	e.think = HuntTarget;
	e.nextthink = time;
};

void (entity e) DirectorSpawnFlyer = {
	setsize (e, '-16 -16 -24', '16 16 40');
	e.solid = SOLID_SLIDEBOX;
	e.movetype = MOVETYPE_STEP;
	e.takedamage = DAMAGE_AIM;
	e.ideal_yaw	= e.angles * '0 1 0';
	e.yaw_speed = 20;
	e.view_ofs = '0 0 25';
	e.use = monster_use;
	e.flags	= self.flags | FL_MONSTER | FL_FLY;
    setorigin (e, director.goalentity.origin);
    e.angles = director.goalentity.angles;

	e.enemy = director.enemy;
	e.think = HuntTarget;
	e.nextthink = time;
};

void () SpawnHydras = {
    local float z;

    director.goalentity = self;

    self.think1 (); // spawn a clone

    if (random () > 0.5)
        self.origin = self.origin + '0 40 0';
    else
        self.origin = self.origin - '0 40 0';
    if (random () > 0.5)
        self.origin = self.origin + '40 0 0';
    else
        self.origin = self.origin - '40 0 0';

    self.think1 ();

    total_monsters = total_monsters + 2;
    WriteByte (MSG_ALL, 3); // 3 = svc_updatestat
    WriteByte (MSG_ALL, 12); // 12 = STAT_TOTALMONSTERS
    WriteLong (MSG_ALL, total_monsters);

    remove (self);
};

// ==== ====

void () SpawnDog = {
    local entity e;
    e = spawn ();

    e.frags = 1;
    e.classname = "monster_dog";
	setmodel (e, "progs/dog.mdl");
	e.health = 25;

	e.th_stand = dog_stand1;
	e.th_walk = dog_walk1;
	e.th_run = dog_run1;
	e.th_pain = dog_pain;
	e.th_die = dog_die;
	e.th_melee = dog_atta1;
	e.th_missile = dog_leap1;
	e.think1 = SpawnDog;

	DirectorSpawnWalker(e);
};

void () SpawnSoldier = {
    local entity e;
    e = spawn ();

    e.frags = 2;
    e.classname = "monster_army";
	setmodel (e, "progs/soldier.mdl");
	e.health = 30;

	e.th_stand = army_stand1;
	e.th_walk = army_walk1;
	e.th_run = army_run1;
	e.th_missile = army_atk1;
	e.th_pain = army_pain;
	e.th_die = army_die;
	e.think1 = SpawnSoldier;

	DirectorSpawnWalker(e);
};

void () SpawnKnight = {
    local entity e;
    e = spawn ();

    e.frags = 1;
    e.classname = "monster_knight";
	setmodel (e, "progs/knight.mdl");
	e.health = 75;

	e.th_stand = knight_stand1;
	e.th_walk = knight_walk1;
	e.th_run = knight_run1;
	e.th_melee = knight_atk1;
	e.th_pain = knight_pain;
	e.th_die = knight_die;
	e.think1 = SpawnKnight;

	DirectorSpawnWalker(e);
};

void () SpawnEnforcer = {
    local entity e;
    e = spawn ();

    e.frags = 2;
    e.classname = "monster_enforcer";
	setmodel (e, "progs/enforcer.mdl");
	e.health = 80;

	e.th_stand = enf_stand1;
	e.th_walk = enf_walk1;
	e.th_run = enf_run1;
	e.th_pain = enf_pain;
	e.th_die = enf_die;
	e.th_missile = enf_atk1;
	e.think1 = SpawnEnforcer;

	DirectorSpawnWalker(e);
};

void () SpawnOgre = {
    local entity e;
    e = spawn ();

    e.frags = 5;
    e.classname = "monster_ogre";
	setmodel (e, "progs/ogre.mdl");
	e.health = 200;

	e.th_stand = ogre_stand1;
	e.th_walk = ogre_walk1;
	e.th_run = ogre_run1;
	e.th_die = ogre_die;
	e.th_melee = ogre_melee;
	e.th_missile = ogre_nail1;
	e.th_pain = ogre_pain;
	e.think1 = SpawnOgre;

	DirectorSpawnWalker(e);
};

void () SpawnDemon = {
    local entity e;
    e = spawn ();

    e.frags = 6;
    e.classname = "monster_demon1";
	setmodel (e, "progs/demon.mdl");
	e.health = 300;

	e.th_stand = demon1_stand1;
	e.th_walk = demon1_walk1;
	e.th_run = demon1_run1;
	e.th_die = demon_die;
	e.th_melee = Demon_MeleeAttack;
	e.th_missile = demon1_jump1;
	e.th_pain = demon1_pain;
	e.think1 = SpawnDemon;

	DirectorSpawnWalker(e);
};

void () SpawnTarbaby = {
    local entity e;
    e = spawn ();

    e.frags = 4;
    e.classname = "monster_tarbaby";
	setmodel (e, "progs/tarbaby.mdl");
	e.health = 80;

	e.th_stand = tbaby_stand1;
	e.th_walk = tbaby_walk1;
	e.th_run = tbaby_run1;
	e.th_missile = tbaby_jump1;
	e.th_melee = tbaby_jump1;
	e.th_die = tbaby_die1;
	// e.think1 = SpawnTarbaby; // this can theoretically crash

	DirectorSpawnWalker(e);
};

void () SpawnWizard = {
    local entity e;
    e = spawn ();

    e.frags = 4;
    e.classname = "monster_wizard";
	setmodel (e, "progs/wizard.mdl");
	e.health = 80;

	e.th_stand = wiz_stand1;
	e.th_walk = wiz_walk1;
	e.th_run = wiz_run1;
	e.th_missile = Wiz_Missile;
	e.th_pain = Wiz_Pain;
	e.th_die = wiz_die;
	e.think1 = SpawnWizard;

	DirectorSpawnFlyer(e);
};

void () SpawnFish = {
    local entity e;
    e = spawn ();

    e.frags = 1;
    e.classname = "monster_fish";
	setmodel (e, "progs/fish.mdl");

	e.health = 25;

	e.th_stand = f_stand1;
	e.th_walk = f_walk1;
	e.th_run = f_run1;
	e.th_die = f_death1;
	e.th_pain = fish_pain;
	e.th_melee = f_attack1;
	e.think1 = SpawnFish;

	DirectorSpawnFlyer(e);
	setsize (e, '-16 -16 -24', '16 16 24');
};

void () SpawnHellKnight = {
    local entity e;
    e = spawn ();

    e.frags = 5;
    e.classname = "monster_hell_knight";
	setmodel (e, "progs/hknight.mdl");
	e.health = 250;

	e.th_stand = hknight_stand1;
	e.th_walk = hknight_walk1;
	e.th_run = hknight_run1;
	e.th_melee = hknight_melee;
	e.th_missile = hknight_missile;
	e.th_pain = hknight_pain;
	e.th_die = hknight_die;
	e.think1 = SpawnHellKnight;

	DirectorSpawnWalker(e);
};

void () SpawnZombie = {
    local entity e;
    e = spawn ();

    e.frags = 1;
    e.classname = "monster_zombie";
	setmodel (e, "progs/zombie.mdl");
	e.max_health = 60;
	e.health = 60;
	e.owner = e; // zombie chunks check owners to prevent rune pet damage

	e.th_stand = zombie_stand1;
	e.th_walk = zombie_walk1;
	e.th_run = zombie_run1;
	e.th_pain = zombie_pain;
	e.th_die = zombie_die;
	e.th_missile = zombie_missile;
	e.think1 = SpawnZombie;

	DirectorSpawnWalker(e);
};

void () SpawnShalrath = {
    local entity e;
    e = spawn ();

    e.frags = 8;
    e.classname = "monster_shalrath";
	setmodel (e, "progs/shalrath.mdl");
	e.health = 400;

	e.th_stand = shal_stand;
	e.th_walk = shal_walk1;
	e.th_run = shal_run1;
	e.th_die = shalrath_die;
	e.th_pain = shalrath_pain;
	e.th_missile = shal_attack1;
	e.think1 = SpawnShalrath;

	DirectorSpawnWalker(e);
};

void () SpawnShambler = {
    local entity e;
    e = spawn ();

    e.frags = 12;
    e.classname = "monster_shambler";
	setmodel (e, "progs/shambler.mdl");
    e.health = 600;

	e.th_stand = sham_stand1;
	e.th_walk = sham_walk1;
	e.th_run = sham_run1;
	e.th_die = sham_die;
	e.th_melee = sham_melee;
	e.th_missile = sham_magic1;
	e.th_pain = sham_pain;
	e.think1 = SpawnShambler;

	DirectorSpawnWalker(e);
};

// ===== =====

void () SpawnSomething = {
    local float i;
    local entity e;

    // find next spawnpoint
    if (self.aqstate & 1)
    {
        self.goalentity = find (self.goalentity, classname, "info_player_start");
        if (self.goalentity == world)
            self.goalentity = find (self.goalentity, classname, "info_player_start");

        // anything in the way?
        e = findradius (self.goalentity.origin, 48);
        while (e != world)
        {
            if (e.health)
                if (!(e.flags & FL_ITEM))
                    return;
            e = e.chain;
        }
    } else
    {
        self.goalentity = find (self.goalentity, classname, "info_player_deathmatch");
        if (self.goalentity == world)
            self.goalentity = find (self.goalentity, classname, "info_player_deathmatch");

        // anything in the way?
        e = findradius (self.goalentity.origin, 48);
        while (e != world)
        {
            if (e.health)
                if (!(e.flags & FL_ITEM))
                    return;
            e = e.chain;
        }
    }

    self.enemy = find (self.enemy, classname, "player");
    if (self.enemy == world)
        self.enemy = find (self.enemy, classname, "player");

    i = floor(random () * self.max_health);

    if (i == 0)
        SpawnDog ();
    else if (i == 1)
        SpawnSoldier ();
    else if (i == 2)
        SpawnEnforcer ();
    else if (i == 3)
        SpawnKnight ();
    else if (i == 4)
        SpawnOgre ();
    else if (i == 5)
        SpawnDemon ();
    else if (i == 6)
        SpawnTarbaby ();
    else if (i == 7)
        SpawnWizard ();
    else if (i == 8)
        SpawnFish ();
    else if (i == 9)
        SpawnHellKnight ();
    else if (i == 10)
        SpawnZombie ();
    else if (i == 11)
    {
        if (random () > 0.5)
            SpawnShalrath ();
        else
            SpawnHellKnight ();
    }
    else if (i == 12)
    {
        if (random () > 0.5)
            SpawnShambler ();
        else
            SpawnOgre ();
    }
    else
        // shouldn't happen
        return;

    total_monsters = total_monsters + 1;
    WriteByte (MSG_ALL, 3); // 3 = svc_updatestat
    WriteByte (MSG_ALL, 12); // 12 = STAT_TOTALMONSTERS
    WriteLong (MSG_ALL, total_monsters);
};

// ==== Thinks ====

void () DirectorThink = {
    if (!is_valid_player_e(self.enemy))
        self.enemy = find (self.enemy, classname, "player");

    // no players in game
    if (self.enemy == world)
    {
        self.nextthink = time + 5;
        // dprint ("No player enemies\n");
        return;
    }

    if (total_monsters - killed_monsters < self.delay)
    {
        SpawnSomething ();
    }

    self.nextthink = time + 0.5;
};

void () DirectorFirstThink = {
    local float i;

    self.max_health = 13; // number of valid monsters coded
    self.delay = map_size(mapname); // store max monster count based on size
    if (self.delay) //
        self.delay = self.delay * 30;
    else
        self.delay = 50; // 0 means custom level

    self.goalentity = find (world, classname, "info_player_deathmatch");
    if (self.goalentity == world)
    {
        dprint("Director: No dm spawns found.\n");
        self.aqstate = 1;
        self.goalentity = find(world, classname, "info_player_start");
        if (self.goalentity == world)
        {
            bprint("Director: No start spawns found??\n");
            remove (self);
            return;
        }
    } else
    {
        while (self.goalentity != world)
        {
            i = i + 1;
            self.goalentity = find (self.goalentity, classname, "info_player_deathmatch");
        }

        self.state = i;
        // self.goalentity is now world, but it will be skipped on the next search
        // self.goalentity = find (self.goalentity, classname, "info_player_deathmatch");
    }
    self.think = DirectorThink;
    self.nextthink = time + 1;
};

void () DirectorPrecaches = {
    // PrecacheBoss ();
    PrecacheDemon ();
    PrecacheDog ();
    PrecacheEnforcer ();
    PrecacheFish ();
    PrecacheHellKnight ();
    PrecacheKnight ();
    PrecacheOgre ();
    PrecacheShalrath ();
    // PrecacheShambler (); // already done by RuneQuake
    // PrecacheShub ();
	PrecacheSoldier ();
    PrecacheTarbaby ();
    PrecacheWizard ();
};
