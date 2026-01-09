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
			var nearest = instance_nearest_from(x,y,instances_in_circle(instances_matching_ne([Player,enemy],"team",team),x,y,attract_range * skill_get(mod_current)));
			if instance_exists(nearest) {
				var _dir = point_direction(x,y,nearest.x,nearest.y)
				if(abs(angle_difference(_dir, direction)) <= current_time_scale*10){
					direction = _dir;
					image_angle = _dir;
				}
				else if(angle_difference(_dir, direction) > 0){
					direction+=current_time_scale*speed/2*skill_get(mod_current);
					image_angle+=current_time_scale*speed/2*skill_get(mod_current);
				}
				else{
					direction-=current_time_scale*speed/2*skill_get(mod_current);
					image_angle-=current_time_scale*speed/2*skill_get(mod_current);
				}
				image_blend = c_red //for testing purposes
			}
		}
	}