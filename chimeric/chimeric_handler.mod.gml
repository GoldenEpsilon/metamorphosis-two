#define init
	global.sprChimeric = sprite_add("sprites/select/sprChimeric.png", 1, 12, 16);

    global.chimeric_chance      = 10;
    global.chimeric_mutations   = [];
    
    global.level_start          = false;
    
    var _mod = mod_get_names("skill"),
		_scrt = "skill_chimeric";
    
     // Find all available chimeric mutations and collect them in an array:
    for(var i = 0; i < array_length(_mod); i++){ 
		if(mod_script_exists("skill", _mod[i], _scrt) and mod_script_call("skill", _mod[i], _scrt) > 0) {
			array_push(global.chimeric_mutations, _mod[i]);
		}
	}

	global.drawscr = noone;
	
#define step
    if(instance_exists(GenCont) || instance_exists(Menu)){
		global.level_start = true;
	} else if(global.level_start) {
	    global.level_start = false;
	    
	    if(instance_exists(GameCont)) {
	         // Increase the chance of chimeric mutations appearing if you visit a vault:
	        if(GameCont.area = 100) global.chimeric_chance += 20;
	    }
	}
	
	with(GameCont) {
	    if("lstlevel" not in self) lstlevel = level;
	    
	    if(lstlevel != level) {
	        if(lstlevel < level) {
	            if(level >= 10 and lstlevel < 10) {
	                 // Increase the chance of chimeric mutations appearing when you hit level ultra:
	                global.chimeric_chance += 30;
	            }
	        } else {
	            if(level < 10 and lstlevel >= 10) {
	                 // Remove the chance for chimeric mutations if you lose level ultra somehow:
	                global.chimeric_chance -= 30;
	            }
	        }
	        
	        lstlevel = level;
	    }
	}
	
	with(instances_matching(LevCont, "chimeric_check", null)) {
	    chimeric_check = true;
	    
	    if(array_length(global.chimeric_mutations) and !instance_exists(EGSkillIcon) and chance(global.chimeric_chance, 100)) {
	        var _pot = 0,
	            _val = 1;
	        
	        with(SkillIcon) {
	             // Invalidates a selection from allowing a chimeric mutation if a special mutation would spawn, i.e. Heavy Heart or a custom ultra:
	            if(!skill_get_active(skill)) _val = 0;
	            else if(num > _pot) _pot = num;
	        }
	        
	        if(_val) {
	             // Selects a random mutation from the lineup:
	            var _choice = irandom(_pot),
	                _avail  = [];
	           
	           for(i = 0; i < array_length(global.chimeric_mutations); i++) {
	                // Make sure only mutations you don't have appear in the pool:
	               if(!skill_get(global.chimeric_mutations[i])) array_push(_avail, global.chimeric_mutations[i]);
	           }
	            
	           if(array_length(_avail)) {
	               with(instances_matching(SkillIcon, "num", _choice)) {
	                   skill    = _avail[irandom(array_length(_avail) - 1)];
	                   name     = skill_get_name(skill);
	                   text     = skill_get_text(skill);
					   chimeric = true;
	                   if(is_string(skill)) mod_script_call("skill", skill, "skill_button");
	                   else {
	                       sprite_index = sprSkillIcon;
	                       image_index = skill;
	                       
	                   }
	               }
	           }
	        }
	    }
	}

	if(global.drawscr == noone || !instance_exists(global.drawscr)){
		global.drawscr = script_bind_draw(draw_chimeric, -1001);
	}
	
#define draw_chimeric
with(instances_matching(SkillIcon, "chimeric", true)){
	draw_surface_part_ext(mod_variable_get("mod", "chimeric_visuals", "surface"), 0, 0, 24*4, 32*4, x-12, y-16 + (addy == 2 ? 0 : -1), 0.25, 0.25, addy == 2 ? c_gray : c_white, 1);
	draw_set_alpha(0.5);
	draw_sprite(global.sprChimeric, 0, x, y + (addy == 2 ? 0 : -1));
	draw_set_alpha(1);
}
	
#define game_start
     // Reset chance for chimeric mutations to spawn:
    global.chimeric_chance = 100;

     // Find all available chimeric mutations and collect them in an array:
    var _mod = mod_get_names("skill"),
		_scrt = "skill_chimeric";
    
    global.chimeric_mutations = [];
    
    for(var i = 0; i < array_length(_mod); i++){ 
		if(mod_script_exists("skill", _mod[i], _scrt) and mod_script_call("skill", _mod[i], _scrt) > 0) {
			array_push(global.chimeric_mutations, _mod[i]);
		}
	}


#define orandom(n)                      return random_range(-n,n);
#define chance(_numer,_denom)           return random(_denom) < _numer;
#define chance_ct(_numer,_denom)        return random(_denom) < _numer * current_time_scale;