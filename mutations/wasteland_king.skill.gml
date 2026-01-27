#define init
	//Sprites
	global.sprSkillIcon = sprite_add("sprites/select/sprSkill" + string_upper(string(mod_current)) + "Icon.png", 1, 12, 16);
	global.sprSkillHUD  = sprite_add("sprites/HUD/sprSkill" + string_upper(string(mod_current)) + "HUD.png",  1,  8,  8);
	
	//Sounds
	global.sndSkillSlct = sound_add("sounds/sndSkill" + string_upper(string(mod_current)) + ".ogg");
	
	//Other
	global.sprMoneyBright = sprite_add("sprites/effects/sprMoneyBright.png",1,4,2);
	/* NOTES:
		-YV WK uses it's own draw function, i can make this a single draw event if more races use draw functions
	*/
	
	global.newLevel = false;

#macro yv_max_preload		3 

#define skill_name    return "WASTELAND KING";
#define skill_text    return desc_decide();
#define skill_tip     return (chance(99,100) ? "HAIL TO THE KING" : choose("T-GIRL REP","THIS MUTATION MAKES ME FEEL#LIKE THE @wWASTELAND KING!##@s...SAY THAT AGAIN..."));
#define skill_icon    return global.sprSkillHUD;
#define skill_button  sprite_index = global.sprSkillIcon;
#define skill_type    return "utility";
#define skill_avail   
	with Player { //if any player has a valid WK, return true. Otherwise return false
		if race_id < 17 || mod_script_exists("race", race, "race_wk_text") {
			return 1;
		}
	}
	return 0;

#define desc_decide
	var t = ""; // base blank text
	
	with(Player) {
		if(instance_number(Player) > 1) {
			var str;
			if race_id >= 17 {
				str = string_replace_all(mod_script_call("race", race, "race_name"),"#"," "); //remove line breaks
			} else str = race_get_alias(race_id); //race_get_alias works differently in v100 it seems.
			t += "@s" + string_upper(str) + " -@w ";
		}
		if(race_id > 16 and mod_script_exists("race", race, "race_wk_text")) {
			t += mod_script_call("race", race, "race_wk_text")
		}
		else {
			switch(race) {
				case "fish":	 t += "@rNYI"; break;
				case "crystal":  t += "@wLASER CRYSTAL RETALIATION"; break;
				case "eyes":     t += "@rNYI"; break;
				case "melting":  t += "@rNYI"; break;
				case "plant":    t += "@rNYI"; break;
				case "venuz":    t += "@wPRE-LOAD @sWHILE @wNOT FIRING"; break;
				case "steroids": t += "@rNYI"; break;
				case "robot":    t += "@rNYI"; break;
				case "chicken":  t += "@rNYI"; break;
				case "rebel":    t += "@sPORTALS GRANT @w2 @rBRITTLE HP"; break;
				case "horror":   t += "@rNYI"; break;
				case "rogue":    t += "@rNYI"; break;
				case "skeleton": t += "@rNYI"; break;
				case "frog":     t += "@rNYI"; break;
				case "cuz":		 t += "@rNYI"; break;
				default: t += "ALL STATS UP"; break;
			}
		}
		
		t += "#";
	}
	//if(t = "") t += "UPGRADES YOUR PASSIVE ABILITY";
	
	return t;

#define skill_take    
	if(array_length(instances_matching(mutbutton, "skill", mod_current)) > 0) {
		sound_play(sndMut);
		sound_play(global.sndSkillSlct);
	}
	var raceList = [];
	with(Player) {
		if(array_find_index(raceList, race) == -1){
			array_push(raceList, race);
		}
	}

	for(var i = 0; i < array_length(raceList); i++){
		switch(raceList[i]){
			case "rebel":
				wk_rebel_brittle_grant();
			break;
			
			default:
				with(instances_matching_gt(instances_matching(Player, "race", raceList[i]), "race_id", 16)) {
					if(mod_script_exists("race", raceList[i], "race_wk_take")) mod_script_call("race", raceList[i], "race_wk_take");
				}
			break;
		}
	}

#define step
	var raceList = [];
	with(Player) {
		if(array_find_index(raceList, race) == -1){
			array_push(raceList, race);
		}
	}
	for(var i = 0; i < array_length(raceList); i++){
		switch(raceList[i]){
			case "fish":
				break;
				
			case "crystal":
				with(instances_matching(Player, "race", "crystal")) {
					//initialize
					if "wk_initialized" not in self {
						wk_initialized = ":3";
						
						wk_crystal_orbitals = [];
						wk_orbital_rotation = 0;
						wk_orbital_timer = 20;
						wk_orbital_tmax = 275;
						wk_track_hp = my_health;
						wk_burst_hp = -1;
					}
					
					//track HP loss and reset orbital timer, also destroy orbitals
					if wk_track_hp > my_health {
						repeat wk_track_hp - my_health {
							if array_length(wk_crystal_orbitals) == 0 break;
							var inst = wk_crystal_orbitals[@0];
							if instance_exists(inst) {
								//NOTE: There is code to make orbitals take 2HP worth of damage before breaking.
								//I removed it because it felt low impact, but it can be added back as needed.
								with inst { 
									if 0 { //!inst.damaged {
										inst.damaged = true;
										repeat 4 with instance_create(inst.x,inst.y,PlasmaTrail) {
										sprite_index = sprLaserCharge;
										image_speed += random(0.6);
											motion_add(irandom(360),2 + random(3));
										}
										sound_play_pitchvol(sndLaserCrystalHit,1.3 + random(0.1),0.6);
										view_shake_at(inst.x,inst.y,7);
									}
									else {
										instance_destroy();
										array_shift(other.wk_crystal_orbitals);
									}
								}
							}
						}
						wk_orbital_timer = wk_orbital_tmax;
					}
					wk_track_hp = my_health;
					
					//remove dead orbitals
					wk_crystal_orbitals = array_prune(wk_crystal_orbitals);
					
					//increment rotation: orbitals rotate faster when you move faster cause its awesome
					wk_orbital_rotation += current_time_scale * (2 * speed + 3);
					
					//spawn new orbitals
					if array_length(wk_crystal_orbitals) < 3 * skill_get(mod_current) {
						wk_orbital_timer -= current_time_scale;
						if wk_orbital_timer <= 0 {
							wk_orbital_timer = 50;
							with wk_crystal_orbital_create(x,y) {
								creator 	= other;
								team		= other.team;
								array_push(other.wk_crystal_orbitals,self);
							}
							
							sound_play_pitchvol(sndCrystalShield,1.3 + array_length(wk_crystal_orbitals) * 0.2,0.4);
							sound_play_pitchvol(sndCrystalRicochet,1.3 + array_length(wk_crystal_orbitals) * 0.2,0.4);
						}
					}
				}
				break;
				
			case "eyes":
				break;
				
			case "plant":
				break;
				
			case "venuz":
				with(instances_matching(Player, "race", "venuz")) {
					//initialize
					if "wk_initialized" not in self {
						wk_initialized = ">:#";
						
						wk_yv_preload = 0;
						wk_yv_draw = noone;
					}
					
					//draw controller
					if !instance_exists(wk_yv_draw) {
						with script_bind_draw(wk_yv_draw_script,-7,self) {
							other.wk_yv_draw = self;
							goal = 0;
							current = 0;
							lastx = 0;
							lasty = 0;
							lasta = 0;
						}
					};
					
					//load up to 3 extra shots
					var load = weapon_get_load(wep);
					var lmax = load * yv_max_preload * skill_get(mod_current) * -1;
					if reload <= 0 && reload > lmax && load > 0 {
						wk_yv_preload += current_time_scale * 0.5;
						if reload == 0 reload = 0; //TRUST ME this is neccesary
						else if reload < 0 reload = ceil(reload/load) * load;
						if wk_yv_preload >= load {
							wk_yv_preload -= load;
							reload = max(reload - load, lmax);
							sound_play_pitchvol(sndMenuCredits,0.7 + 0.3 * abs(ceil(reload/load)),1)
						}
					}
					else wk_yv_preload = 0;
					
					if canswap && button_pressed(self.index,"swap") && bwep != 0 {
						breload = max(breload,0);
						wk_yv_preload = 0;
					}
					
				}
			break;
				
			case "robot":
				break;
				
			case "chicken":
				break;
				
			case "rebel":
				if(instance_exists(GenCont)) global.newLevel = true;
				
				/* Dragonstrive here:
					I'm making a note of this for later. It's fine *now*, 
					but if more races end up needing script binds or level starts,
					I'm gonna probably modularize this so it's easier to expand on.
				*/
				else if(global.newLevel){
					global.newLevel = false;
					wk_level_start("rebel");
				}
				
				with(instances_matching(Player, "race", "rebel")){
					//initialize
					if "wk_initialized" not in self {
						wk_initialized = ";)";
						
						wk_begin_step_object	= noone;
						brittle_health			= 0;
						pass_health 			= my_health;
					}
				
					if brittle_health > 0 {
						if my_health != pass_health{
							if my_health < pass_health{
								if !button_check(index, "spec"){
									var _damage = pass_health - my_health,
										_last_brittle_health = brittle_health;
									
									//Reset damage taken
									my_health = pass_health;
									
									//Subtract relevant brittle health
									brittle_health = max(brittle_health - _damage, 0);
									
									//If brittle health all gone, do remainder of proper damage
									if brittle_health <= 0 my_health -= _damage - _last_brittle_health;
								}
							}
							pass_health = my_health;
						}
					}
				}
			break;
				
			case "rogue":
				break;
				
			case "skeleton":
				break;
				
			case "frog":
				break;
				
			case "cuz":
				break;
				
			default:
				with instances_matching(Player,"wk_modded_race_check",null) {
					wk_modded_race_check = true;
					if !mod_script_exists("race", race, "race_wk_take") {
						reloadspeed += 0.1;
						accuracy -= 0.1;
						maxspeed += 0.1;
						maxhealth ++;
						my_health ++;
					}
				}
			break;
		}
	}
#define wk_crystal_orbital_create(xx,yy)
	with instance_create(xx,yy,CustomObject) {
		sprite_index	= sprFlakBullet;
		orbitspeed		= 3; //in degrees
		orbitrad		= 32; //in pixels
		orbitlerp		= 0.20;
		rot				= GameCont.timer;
		goalx			= xx;
		goaly			= yy;
		team			= -1;
		targetrad		= 250;
		damaged			= false;
		on_step 		= script_ref_create(crystal_orbital_step);
		on_destroy		= script_ref_create(crystal_orbital_destroy);
		
		return self;
	}

#define crystal_orbital_step	
	if !instance_exists(creator) {
		instance_destroy();
		exit;
	}
	
	var num = array_length(creator.wk_crystal_orbitals);
	var	ind = array_find_index(creator.wk_crystal_orbitals,self);
	var	off = 360/num * ind;
	var	ang = creator.wk_orbital_rotation + off;  
	var	gol = collision_line_point(
			creator.x,
			creator.y,
			creator.x + lengthdir_x(orbitrad - creator.speed * 3,ang),
			creator.y + lengthdir_y(orbitrad - creator.speed * 3,ang),
			Wall,
			false,
			true
		);
		
		x = lerp(x,gol.x,orbitlerp);
		y = lerp(y,gol.y,orbitlerp);
	
	//target tracking move to distroy


//DEV
//REMOVE THESE WHEN BEA MAKES PROPER SPRITES;
	image_xscale = 0.4;
	image_yscale = 0.4;
	switch ind {
		case 0: image_blend = c_red; break;
		case 1: image_blend = c_orange; break;
		case 2: image_blend = c_yellow; break;
		case 3: image_blend = c_green; break;
	}
	
	if damaged {
		x += orandom(2);
		y += orandom(2);
		with instance_create(x,y,Smoke) {
			image_xscale = 0.15;
			image_yscale = 0.15;
		}
	}
	

#define crystal_orbital_destroy
	var targets = instances_in_circle(instances_matching_ne([enemy,Player],"team",team),x,y,targetrad);
	var	nearest = noone;
	var	ndist	= infinity;

	with targets {
		if collision_line(other.x,other.y,x,y,Wall,false,true) continue; //line of sight
		var d = point_distance(other.x,other.y,x,y);
		if d < ndist {
			nearest = self;
			ndist	= d;
		}
	}
	
	with instance_create(x,y,EnemyLaser){
		creator 		= other.creator;
		team			= other.team;
		direction		= instance_exists(nearest) ? point_direction(other.x,other.y,nearest.x,nearest.y) : random(360);
		image_angle 	= direction;
		image_yscale	*= 1.5;
		alarm0			= 1;
		damage			= 5;
	}
	
	view_shake_at(x,y,15);
	
	sound_play_pitchvol(sndHyperCrystalHurt,1.4 + random(0.15),0.8);
	sound_play_pitchvol(sndLaserCrystalDeath,1.2 + random(0.1),0.5);
	sound_play_pitchvol(sndLaser,0.6 + random(0.1),1);
	sound_play_pitchvol(sndWallBreakCrystal,2.5 + random(0.2),0.6);
	
	repeat 8 with instance_create(x,y,PlasmaTrail) {
		sprite_index = sprLaserCharge;
		image_speed += random(0.6);
		motion_add(irandom(360),0.5 + random(4));
	}

#define crystal_orbital_cleanup
#define wk_level_start(race)
	switch(race){
		case "rebel":
			wk_rebel_brittle_grant();
			break;
	}

#define wk_rebel_brittle_grant
	with(instances_matching(Player, "race", "rebel")){
        brittle_health = 2 + (skill_get(mod_current) - 1);
        lstbrittle_health = brittle_health;
        
    	pass_health = my_health;
	}

#define wk_yv_draw_script(_inst)
	if !instance_exists(_inst) {
		instance_destroy();
		exit;
	}
	
	//variables
	var rad = 13;
	var ang = 50;
	var tot = ang * goal;
	var bob = 2.5;
	var yoff = -6

	//draw moni
	for (var i = 0; i < goal; i ++) {
		var _o = i - max(0,(goal * 0.5) - 0.5);
		var _a = 90 + ang * _o;
		var _x = _inst.x + lengthdir_x(rad + (bob * sin(current_frame/10 + i)),_a);
		var _y = _inst.y + lengthdir_y(rad + (bob * sin(current_frame/10 + i)),_a) + yoff;
		
		draw_sprite_ext(
			global.sprMoneyBright,
			0,
			_x,
			_y, 
			1,
			1,
			90 + ang * _o,
			c_white,
			1
		);
	}
	
	//set new goal
	goal = abs(ceil(min(0,_inst.reload)/weapon_get_load(_inst.wep)));
	
	//spawn cosmetics
	if goal > current {
		var _x = _inst.x + lengthdir_x(rad + (bob * sin(current_frame/10 + i)),90 + ang * max(0,(goal * 0.5) - 0.5));
		var _y = _inst.y + lengthdir_y(rad + (bob * sin(current_frame/10 + i)),90 + ang * max(0,(goal * 0.5) - 0.5)) + yoff;
		with instance_create(_x,_y,PlasmaTrail) {
			depth			= -8;
			sprite_index	= sprCaveSparkle;
			image_speed		= 1;
		}
	}
	else if goal < current {
		for (var i = goal; i < current; i ++) {
			var _o = i - max(0,(current * 0.5) - 0.5);
			var _a = 90 + ang * _o;
			var _x = _inst.x + lengthdir_x(rad + (bob * sin(current_frame/10 + i)),_a);
			var _y = _inst.y + lengthdir_y(rad + (bob * sin(current_frame/10 + i)),_a) + yoff;
			
			with instance_create(_x,_y,Feather) {
				sprite_index	= sprMoney;
				depth			= -1;
				image_angle		= _a;
				direction		= 270;
			}
		}
		sound_play_pitchvol(sndPopPopUpg,1.65 + random(0.1),0.6);
		sound_play_pitchvol(sndEmpty,1.65 + random(0.1),0.6);
	}
	
	//store current drawn bills
	current = goal;
	
#define orandom(n)                      return random_range(-n,n);
#define chance(_numer,_denom)           return random(_denom) < _numer;
#define chance_ct(_numer,_denom)        return random(_denom) < _numer * current_time_scale;
#define array_prune(_array)				return instances_matching_ne(_array, "id"); //prunes nonexistant instances from an array;