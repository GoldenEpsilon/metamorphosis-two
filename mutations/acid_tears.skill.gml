#define init
	//Sprites
	global.sprSkillIcon = sprite_add("sprites/select/sprSkill" + string_upper(string(mod_current)) + "Icon.png", 1, 12, 16);
	global.sprSkillHUD  = sprite_add("sprites/hud/sprSkill" + string_upper(string(mod_current)) + "HUD.png",  1,  8,  8);

#define skill_name    return "ACID TEARS";
#define skill_text    return "@wBULLETS@s CAN DESTROY @wWALLS";
#define skill_ttip    return "nothing is safe";
//#define skill_icon    return global.sprSkillHUD;
#define skill_button  sprite_index = global.sprSkillIcon;
#define skill_type    return "utility";
#define skill_take    
	if(array_length(instances_matching(mutbutton, "skill", mod_current)) > 0) {
		sound_play(sndMut);
	}

#define step
	if "acid_initialized" not in self{
		acid_initialized = ":P"
		
		acid_step_object = noone;
	}
	
	if !instance_exists(acid_step_object) with script_bind_step(acid_step, depth) other.acid_step_object = self;

#define acid_step
	//Projectile setup
    with(instances_matching(instances_matching([Bullet1, UltraBullet, HeavyBullet], "can_wallbreak", undefined), "team", 2)) can_wallbreak = true;
	with(instances_matching(instances_matching(instances_matching(CustomProjectile, "ammo_type", 1), "can_wallbreak", undefined), "team", 2)) can_wallbreak = true;

	var _proj = instances_matching(instances_matching(projectile, "can_wallbreak", true), "team", 2);
	
	//Wallbreak logic
	if(array_length(_proj) && instance_exists(Wall)){
		var _searchDis = 16;
		with(_proj){
			if(distance_to_object(Wall) <= speed_raw + _searchDis){
				motion_step(1);
				
				if(distance_to_object(Wall) <= _searchDis){
					with(Wall) if(distance_to_object(other) <= _searchDis){
						motion_step(1);
						
						//Collision
						if(place_meeting(x, y, other)){
							instance_create(x, y, FloorExplo);
							with(other) event_perform(ev_collision, Wall);
							instance_destroy();	
							
							exit;
						}
						
						motion_step(-1);
					}
				}
				
				motion_step(-1);
			}
		}
	}

#define instances_meeting_rectangle(_x1, _y1, _x2, _y2, _obj)
	/*
		Returns all instances of the given object whose bounding boxes overlap the given rectangle
		Much better performance than checking 'collision_rectangle()' on every instance
		
		Args:
			x1/y1/x2/y2 - The rectangular area to search
			obj         - The object(s) to search
	*/
	
	return (
		instances_matching_le(
		instances_matching_le(
		instances_matching_ge(
		instances_matching_ge(
		_obj,
		"bbox_right",  _x1),
		"bbox_bottom", _y1),
		"bbox_left",   _x2),
		"bbox_top",    _y2)
	);

#define motion_step(_mult)
	/*
		Performs the calling instance’s basic movement code, scaled by a given number
	*/
	
	if(_mult > 0){
		if(friction_raw != 0 && speed_raw != 0){
			speed_raw -= min(abs(speed_raw), friction_raw * _mult) * sign(speed_raw);
		}
		if(gravity_raw != 0){
			hspeed_raw += lengthdir_x(gravity_raw, gravity_direction) * _mult;
			vspeed_raw += lengthdir_y(gravity_raw, gravity_direction) * _mult;
		}
		if(speed_raw != 0){
			x += hspeed_raw * _mult;
			y += vspeed_raw * _mult;
		}
	}
	else{
		if(speed_raw != 0){
			y += vspeed_raw * _mult;
			x += hspeed_raw * _mult;
		}
		if(gravity_raw != 0){
			vspeed_raw += lengthdir_y(gravity_raw, gravity_direction) * _mult;
			hspeed_raw += lengthdir_x(gravity_raw, gravity_direction) * _mult;
		}
		if(friction_raw != 0 && speed_raw != 0){
			speed_raw -= min(abs(speed_raw), friction_raw * _mult) * sign(speed_raw);
		}
	}

#define orandom(n)                      return random_range(-n,n);
#define chance(_numer,_denom)       	return random(_denom) < _numer;
