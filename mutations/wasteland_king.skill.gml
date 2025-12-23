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
				case "venuz":    t += "@wPRE-LOAD @sUP TO THREE SHOTS#@sWHILE @wNOT FIRING"; break;
				case "steroids": t += "@rNYI"; break;
				case "robot":    t += "@rNYI"; break;
				case "chicken":  t += "@rNYI"; break;
				case "rebel":    t += "@sPORTALS GRANT @w2 @rBRITTLE HP@s"; break;
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
				break;
				
			case "eyes":
				break;
				
			case "plant":
				break;
				
			case "venuz":
				with(instances_matching(Player, "race", "venuz")) {
					//initialize
					if "wk_yv_preload" not in self {
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
				
				else if(global.newLevel){
					global.newLevel = false;
					wk_level_start("rebel");
				}
				
				with(instances_matching(Player, "race", "rebel")){
					//initialize
					if "wk_rebel_preload" not in self {
						wk_rebel_preload = 0;
						wk_begin_step_object = noone;
					}
					
					//begin step controller
					if !instance_exists(wk_begin_step_object) {
						with script_bind_draw(wk_begin_step, 0, self) other.wk_begin_step_object = self;
					}
					
					if "brittle_health" not in self brittle_health = 0;
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

#define wk_level_start(race)
	switch(race){
		case "rebel":
			wk_rebel_brittle_grant();
			break;
	}

#define wk_begin_step(_inst)
	if !instance_exists(_inst) {
		instance_destroy();
		exit;
	}

	switch(_inst.race){
		case "rebel":
			with(_inst){
				if brittle_health > 0{
					if my_health != pass_health{
						if my_health < pass_health{
							flash = true;
							
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
	}

#define wk_rebel_brittle_grant
	with(instances_matching(Player, "race", "rebel")){
        brittle_health = 2 + (skill_get(mod_current) - 1);
        lstbrittle_health = brittle_health;
        
    	pass_health = my_health;
    	
    	flash = false;
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