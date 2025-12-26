#define init
	//Sprites
	global.sprSkillIcon = sprite_add("sprites/select/sprSkill" + string_upper(string(mod_current)) + "Icon.png", 1, 12, 16);
	global.sprSkillHUD  = sprite_add("sprites/hud/sprSkill" + string_upper(string(mod_current)) + "HUD.png",  1,  8,  8);
	
	//Other
    //global.frigid = script_bind_draw(draw_frigid, 0);
    breath_timer = 1;

#define skill_name    return "FRIGID BREATH";
#define skill_text    return "ALL @wPICKUPS@s LAST LONGER";
#define skill_ttip    return "keep your cool";
#define skill_icon    return global.sprSkillHUD;
#define skill_button  sprite_index = global.sprSkillIcon;
#define skill_type    return "utility";
#define skill_take    
	if(array_length(instances_matching(mutbutton, "skill", mod_current)) > 0) {
		sound_play(sndMut);
	}
    
#define step
    with(Pickup) {
        if("frigid_breath" not in self) {
            frigid_breath = alarm0;
            alarm0 *= 1 + (2 * skill_get(mod_current));
        }
        
        if(object_index != Rad and object_index != BigRad and alarm0 > frigid_breath and chance_ct(1, 4)) {
            with(instance_create(x + orandom(3), y - random(6), Breath)) {
                depth = 0;
                image_angle = random(360);
                var _s = 0.5 + random(0.25);
                image_xscale = _s;
                image_yscale = _s;
                vspeed = -0.8 + random(0.4);
            }
        }
    }
	
	//Frocity breathing for all mutants everywhere!
	if breath_timer > 0 breath_timer--;
	
	if breath_timer <= 0{
		if (random(50) < 1){
			if (instance_exists(Player)){
				with (Player){
					if GameCont.area != 5 or (race = "plant" || race = "robot"){
								//fucked ass plant position fix VVVV
						with(instance_create(x + (race == "plant" ? 3 : 0), y - (race == "plant" ? 5 : 0), Breath)) image_xscale = other.right;
					}
				}
			}
		}
		
		breath_timer = 2;
	}

#define orandom(n)                      return random_range(-n,n);
#define chance_ct(_numer,_denom)        return random(_denom) < _numer * current_time_scale;
