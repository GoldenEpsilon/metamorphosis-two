#define init
	global.sprSkillIcon = sprite_add("../sprites/Icons/Cursed/sprSkill" + string_upper(string(mod_current)) + "Icon.png", 1, 12, 16);
	global.sprSkillHUD  = sprite_add("../sprites/HUD/Cursed/sprSkill" + string_upper(string(mod_current)) + "HUD.png",  1,  9,  9);

	global.sndSkillSlct = sound_add("../sounds/Cursed/sndCurse" + string_upper(string(mod_current)) + ".ogg");

	#macro atract_rad 28
#define skill_name    return "VACUUM VACUOLES";
#define skill_text    return "@rALL@s PROJECTILES ARE @wHOMING";
#define skill_tip     return "BOTTOMLESS SOUL";
#define skill_icon    return global.sprSkillHUD;
#define skill_button  sprite_index = global.sprSkillIcon;
#define skill_avail		return false;
#define skill_chimeric	return true;
#define skill_take    
	if(array_length(instances_matching(mutbutton, "skill", mod_current)) > 0) {
		sound_play(sndMut);
		sound_play(global.sndSkillSlct);
	}

#define step
	with(instances_matching([Player,enemy],"",null)) {
		var i = instances_in_circle(instances_matching_ne(projectile,"team",team),x,y,atract_rad * skill_get(mod_current));
		if array_length(i) with i {
			var lstspd = speed;
			var rotate = (image_angle ==  direction);
			motion_add(point_direction(x, y, other.x, other.y), speed * 0.2);
			speed = lstspd;
			if rotate image_angle = direction;
			image_blend = c_red //for testing purposes
		}
	}

