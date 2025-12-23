#define init
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
	            if(level <= 10) {
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
	                   skill   = _avail[irandom(array_length(_avail) - 1)];
	                   name    = skill_get_name(skill);
	                   text    = skill_get_text(skill);
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
	
	
#define game_start
     // Reset chance for chimeric mutations to spawn:
    global.chimeric_chance = 10;

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