#define init
	//Sprites
	global.sprSkillIcon = sprite_add("sprites/select/sprSkill" + string_upper(string(mod_current)) + "Icon.png", 1, 12, 16);
	global.sprSkillHUD  = sprite_add("sprites/hud/sprSkill" + string_upper(string(mod_current)) + "HUD.png",  1,  8,  8);
	
	//Sounds
	global.sndSkillSlct = sound_add("sounds/sndSkill" + string_upper(string(mod_current)) + ".ogg");

#define skill_name  	return "MOLTEN FLESH";
#define skill_text  	return "@sALL @rHEALTH@s CHANGES#@wHAPPEN OVER TIME";
#define skill_tip   	return "A HORRIBLE AFFLICTION";
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
		if("moltenflesh" not in self){
			moltenflesh = my_health;
			heal_hud_value = 0;
			dmg_hud_value = 0;
		}
		
		if my_health != moltenflesh{
			 // Damage:
			if my_health < moltenflesh{
				var _damage = (moltenflesh - my_health);
				
				 //Reset damage taken:
				my_health += _damage;
				dmg_hud_value += _damage;
				
				if(fork()){
					lsthealth = my_health;
					
					repeat(_damage){
						wait 30;
						
						if instance_exists(self){
							my_health = max(0, my_health - 1);
							dmg_hud_value = max(0, dmg_hud_value - 1);
							moltenflesh = my_health;
							
							 // VFX:
							sound_play_pitchvol(snd_hurt, 0.8, 0.5);
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
			
			 // Healing:
			if my_health > moltenflesh{
				var _healing = (my_health - moltenflesh);
				
				 //Reset healing done:
				my_health -= _healing;
				heal_hud_value -= _healing;
				
				if(fork()){
					repeat(_healing){
						wait 40;
						
						if instance_exists(self){
							my_health = min(my_health + 1, maxhealth);
							heal_hud_value = min(heal_hud_value + 1, maxhealth);
							moltenflesh = my_health;
							
							 // VFX:
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
			
			moltenflesh = my_health;
		}
	}