#define init
	//Sprites
	global.sprSkillIcon = sprite_add("sprites/select/sprSkill" + string_upper(string(mod_current)) + "Icon.png", 1, 12, 16);
	global.sprSkillHUD  = sprite_add("sprites/hud/sprSkill" + string_upper(string(mod_current)) + "HUD.png",  1,  8,  8);

#define skill_name    return "RUBBER SPIT";
#define skill_text    return "@wEXPLOSIVE PROJECTILES#@yBOUNCE@s OFF WALLS";
#define skill_ttip    return "dont jam your gun";
#define skill_icon    return global.sprSkillHUD;
#define skill_button  sprite_index = global.sprSkillIcon;
#define skill_type    return "offensive";
#define skill_take    
	if(array_length(instances_matching(mutbutton, "skill", mod_current)) > 0) {
		sound_play(sndMut);
	}
	
#define step
	if "rubber_initialized" not in self{
		rubber_initialized = "<|:3"
		
		rubber_step_object = noone;
	}
	
	if !instance_exists(rubber_step_object) with script_bind_step(rubber_step, depth) other.rubber_step_object = self;
	
#define rubber_step
	//Vanilla setup
    with(instances_matching(instances_matching([Grenade, Rocket, Nuke, Flame, FlameBall], "rubber_wallbounce", undefined), "team", 2)){
    	var _is_grenade = object_index == Grenade or object_get_parent(self.object_index) == Grenade,
    		_is_flame = object_index == Flame;
    	
    	rubber_wallbounce = _is_grenade ? 4 : 2;
    	rubber_dofx = _is_flame == true ? false : true;
    }
    
    //Modded setup
    with(instances_matching(instances_matching(instances_matching(CustomProjectile, "ammo_type", 4), "rubber_wallbounce", undefined), "team", 2)){
    	if !is_explosion && !is_meat_explosion{
    		rubber_wallbounce = is_rocket ? 2 : 4;
    		rubber_dofx = is_flame ? false : true;
    	}
    }
    
	//Bounce logic
    with instances_matching(instances_matching_ge(projectile, "rubber_wallbounce", 1), "team", 2){
        if(place_meeting(x + hspeed_raw, y + vspeed_raw, Wall)){
            if rubber_dofx{
            	sound_play_pitch(sndGrenadeHitWall, 1 + orandom(0.1))
            	sound_play_pitch(sndLaserCrystalHit, 0.5 + orandom(0.1));
            
				repeat(random_range(10, 15)) instance_create(x, y, Sweat);
				
				with(instance_create(x, y, ImpactWrists)){ image_speed = 0.8; image_index = 2 }
        	}
            
            var _extra_bounce_timer = 5 * current_time_scale;
            if alarm0 alarm0 += _extra_bounce_timer;
            if "arlm0" in self && alrm0 alrm0 += _extra_bounce_timer;
            
            sleep(1);
            move_bounce_solid(true);
            
            speed *= 0.8;
            speed += rubber_wallbounce;
            
            rubber_wallbounce--;
            
            image_angle = direction;
    	}
    }

#define orandom(n)                      return random_range(-n,n);