#define init
	//Sprites
	global.sprSkillIcon = sprite_add("sprites/select/sprSkill" + string_upper(string(mod_current)) + "Icon.png", 1, 12, 16);
	global.sprSkillHUD  = sprite_add("sprites/hud/sprSkill" + string_upper(string(mod_current)) + "HUD.png",  1,  8,  8);
	
	//Sounds
	global.sndSkillSlct = sound_add("sounds/sndSkill" + string_upper(string(mod_current)) + ".ogg");

#define skill_name  	return "SCAR TISSUE";
#define skill_text  	return "DOUBLED @rHEALING@s#@rHEAL@s OVER TIME";
#define skill_tip   	return "TAKE IT";
#define skill_icon  	return global.sprSkillHUD;
#define skill_button	sprite_index = global.sprSkillIcon;
#define skill_type  	return "chimeric";
#define skill_avail		return false;
#define skill_chimeric	return true;
#define skill_take    
	if(array_length(instances_matching(mutbutton, "skill", mod_current)) > 0) {
		sound_play(sndMut);
		sound_play(global.sndSkillSlct);
	}

#define step
	with(Player) {
		if("scartissue" not in self) scartissue = my_health;
		
		if(scartissue != my_health) {
			if(instance_exists(enemy) and scartissue < my_health) {
				var healamt = my_health - scartissue;
				
				my_health -= healamt;
				
				if(fork()) {
					repeat(healamt * 2) {
						wait 45;
						if(instance_exists(self)) {
							my_health += min(1, maxhealth - my_health);
							scartissue = my_health;
							sound_play_pitch(sndHPPickup, 1.7 + random(0.1));
							sound_play_pitch(sndMaggotSpawnDie, 1.8 + random(0.2));
							
							with(instance_create(x, y, BloodStreak)) {
								image_xscale = 0.40;
								image_yscale = 0.75;
							}
						}
					}
					
					exit;
				}
			}
			
			scartissue = my_health;
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	