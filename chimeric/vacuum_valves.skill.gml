#define init
	global.sprSkillIcon = sprite_add("sprites/select/sprSkill" + string_upper(string(mod_current)) + "Icon.png", 1, 12, 16);
	global.sprSkillHUD  = sprite_add("sprites/hud/sprSkill" + string_upper(string(mod_current)) + "HUD.png",  1,  9,  9);

	global.sndSkillSlct = sound_add("sounds/sndSkill" + string_upper(string(mod_current)) + ".ogg");

#macro attract_range 56

#define skill_name    return "VACUUM VALVES";
#define skill_text    return "@rALL@s PROJECTILES ARE @wHOMING";
#define skill_tip     return "BOTTOMLESS SOUL";
//#define skill_icon    return global.sprSkillHUD;
#define skill_button  sprite_index = global.sprSkillIcon;
#define skill_avail		return false;
#define skill_chimeric	return true;
#define skill_take    
	if(array_length(instances_matching(mutbutton, "skill", mod_current)) > 0) {
		sound_play(sndMut);
		sound_play(global.sndSkillSlct);
	}

#define step
	if instance_exists(hitme) {
		with instances_matching_ne(instances_matching_gt(projectile,"speed",0),"ammo_type",-1) {
			var is_enemy = true;
			with(Player){
				if team == other.team {
					is_enemy = false;
					break;
				}
			}
			var nearest = instance_nearest_from(x,y,instances_in_circle(instances_matching_ne([Player,enemy],"team",team),x,y,attract_range * skill_get(mod_current)));
			if instance_exists(nearest) {
				var _dir = point_direction(x,y,nearest.x,nearest.y)

				var rotationspeed = current_time_scale*2*skill_get(mod_current);
				if(!is_enemy){
					rotationspeed = current_time_scale*16*skill_get(mod_current);
				}

				if(abs(angle_difference(_dir, direction)) <= rotationspeed){
					direction = _dir;
					image_angle = _dir;
				}
				else if(angle_difference(_dir, direction) > 0){
					direction += rotationspeed;
					image_angle += rotationspeed;
				}
				else{
					direction -= rotationspeed;
					image_angle -= rotationspeed;
				}

				//WIP visuals, base idea taken from superforce
				if(chance_ct(1, 1)){
					with instance_create(x, y, Dust){motion_add(other.direction + random_range(-4, 4), choose(1, 2, 2, 3)); sprite_index = sprExtraFeet}
				}
				// image_blend = c_red //for testing purposes
			}
		}
	}

#define chance_ct(_numer, _denom)
	/*
		Like 'chance()', but used when being called every frame (for timescale support)
	*/
	
	return (random(_denom) < _numer * current_time_scale);