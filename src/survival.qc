// director's floats
//
// director.state =
// director.delay =
// director.max_health = number of monster types
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
	e.think = e.th_run;
	e.nextthink = time + random ()*0.5;
};

// ==== ====

void () SpawnDog = {
    local entity e;
    e = spawn ();

    e.classname = "monster_dog";
	setmodel (e, "progs/dog.mdl");
	setsize (e, '-32 -32 -24', '32 32 40');
	e.health = 25;

	e.th_stand = dog_stand1;
	e.th_walk = dog_walk1;
	e.th_run = dog_run1;
	e.th_pain = dog_pain;
	e.th_die = dog_die;
	e.th_melee = dog_atta1;
	e.th_missile = dog_leap1;

	DirectorSpawnWalker(e);
};

void () SpawnSoldier = {
    local entity e;
    e = spawn ();

    e.classname = "monster_soldier";
	setmodel (e, "progs/soldier.mdl");
	setsize (e, '-16 -16 -24', '16 16 40');
	e.health = 30;

	e.th_stand = army_stand1;
	e.th_walk = army_walk1;
	e.th_run = army_run1;
	e.th_missile = army_atk1;
	e.th_pain = army_pain;
	e.th_die = army_die;

	DirectorSpawnWalker(e);
};

void () SpawnKnight = {
    local entity e;
    e = spawn ();

    e.classname = "monster_knight";
	setmodel (e, "progs/knight.mdl");

	setsize (e, '-16 -16 -24', '16 16 40');
	e.health = 75;

	e.th_stand = knight_stand1;
	e.th_walk = knight_walk1;
	e.th_run = knight_run1;
	e.th_melee = knight_atk1;
	e.th_pain = knight_pain;
	e.th_die = knight_die;

	DirectorSpawnWalker(e);
};

void () SpawnEnforcer = {
    local entity e;
    e = spawn ();

    e.classname = "monster_enforcer";
	setmodel (e, "progs/enforcer.mdl");

	setsize (e, '-16 -16 -24', '16 16 40');
	e.health = 80;

	e.th_stand = enf_stand1;
	e.th_walk = enf_walk1;
	e.th_run = enf_run1;
	e.th_pain = enf_pain;
	e.th_die = enf_die;
	e.th_missile = enf_atk1;

	DirectorSpawnWalker(e);
};

void () SpawnOgre = {
    local entity e;
    e = spawn ();

    e.classname = "monster_ogre";
	setmodel (e, "progs/ogre.mdl");

	setsize (e, VEC_HULL2_MIN, VEC_HULL2_MAX);
	e.health = 200;

	e.th_stand = ogre_stand1;
	e.th_walk = ogre_walk1;
	e.th_run = ogre_run1;
	e.th_die = ogre_die;
	e.th_melee = ogre_melee;
	e.th_missile = ogre_nail1;
	e.th_pain = ogre_pain;

	DirectorSpawnWalker(e);
};

// ===== =====

void () SpawnSomething = {
    local float i;

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
    else
        // shouldn't happen
        return;

    total_monsters = total_monsters + 1;
    WriteByte (MSG_ALL, 3); // 3 = svc_updatestat
    WriteByte (MSG_ALL, 12); // 12 = STAT_TOTALMONSTERS
    WriteLong (MSG_ALL, total_monsters);

    if (self.aqstate & 1)
    {
        self.goalentity = find (self.goalentity, classname, "info_player_start");
        if (self.goalentity == world)
            self.goalentity = find (self.goalentity, classname, "info_player_start");
    } else
    {
        self.goalentity = find (self.goalentity, classname, "info_player_deathmatch");
        if (self.goalentity == world)
            self.goalentity = find (self.goalentity, classname, "info_player_deathmatch");
    }

    self.enemy = find (self.enemy, classname, "player");
    if (self.enemy == world)
        self.enemy = find (self.enemy, classname, "player");
};

// ==== Thinks ====

void () DirectorThink = {
    self.nextthink = time + 0.5;

    if (!is_valid_player_e(self.enemy))
        self.enemy = find (self.enemy, classname, "player");

    // no players in game
    if (self.enemy == world)
    {
        dprint ("No enemies\n");
        return;
    }

    if (killed_monsters == total_monsters)
    {
        SpawnSomething ();
    }
};

void () DirectorFirstThink = {
    self.max_health = 5; // number of valid monsters coded

    self.goalentity = find (world, classname, "info_player_deathmatch");
    if (self.goalentity == world)
    {
        bprint("Director: No dm spawns found.\n");
        self.aqstate = 1;
        self.goalentity = find(world, classname, "info_player_start");
        if (self.goalentity == world)
        {
            bprint("Director: No start spawns found??\n");
            remove (self);
            return;
        }
    }

    self.think = DirectorThink;
    self.nextthink = time + 1;
};

void () DirectorPrecaches = {
    PrecacheBoss ();
    PrecacheDemon ();
    PrecacheDog ();
    PrecacheEnforcer ();
    PrecacheFish ();
    PrecacheHellKnight ();
    PrecacheKnight ();
    PrecacheOgre ();
    PrecacheShalrath ();
    PrecacheShub ();
	PrecacheSoldier ();
    PrecacheTarbaby ();
};
