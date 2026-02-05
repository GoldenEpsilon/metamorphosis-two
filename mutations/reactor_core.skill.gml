#define init
	//Sprites
	global.sprSkillIcon = sprite_add("sprites/select/sprSkill" + string_upper(string(mod_current)) + "Icon.png", 1, 12, 16);
	//global.sprSkillHUD  = sprite_add("sprites/hud/sprSkill" + string_upper(string(mod_current)) + "HUD.png",  1,  8,  8);
    
    global.level_start          = false;
    global.reactor_draw = script_bind_draw(rad_draw, -10);

#macro highspeed 0.6

#define skill_name    return "REACTOR CORE";
#define skill_text    return "@gRAD COMBO@s#@wBIG ENEMIES@s DROP @gMORE RADS@s";
#define skill_ttip    return "uranium fever";
//#define skill_icon    return global.sprSkillHUD;
#define skill_button  sprite_index = global.sprSkillIcon;
#define skill_type	  return "offensive";
#define skill_take    
	if(array_length(instances_matching(mutbutton, "skill", mod_current)) > 0) {
		sound_play(sndMut);
	}
	
	with(Player) {
		if("radhigh" not in self) {
	        radhigh   = 0;
	        hightimer = 0;
	        highmax   = 20;
	        highgrace = 0;
	    }
	}
    
#define step
	if(!instance_exists(global.reactor_draw)) global.reactor_draw = script_bind_draw(rad_draw, -10);
	
    if(instance_exists(GenCont) || instance_exists(Menu)){
		global.level_start = true;
	} else if(global.level_start) {
	    global.level_start = false;
	    
	    if(instance_exists(GameCont)) {
	    	with(instances_matching_ne(Player, "radhigh", null)) {
	    		highgrace = 60;
	    	}
	    	
	    	 // BIG ENEMIES DROP MORE RADS: 
	        with(instances_matching_ge(enemy, "size", 2)) {
	            if(random(2) < 1) {
	                raddrop = ceil(raddrop * 1.5);
	            }
	        }
	    }
	}

     // More performant and less finnicky option for when the player has less than max rads:
    if(instance_exists(GameCont) and GameCont.rad <= ((GameCont.level * 6) + GameCont.radmaxextra)) {
        with(GameCont) {
            if(rad <= ((level * 6) + radmaxextra)) {
                if("lstreactor" not in self)        lstreactor          = rad;
                if("lstreactor_level" not in self)  lstreactor_level    = level;
                
                if(lstreactor != rad) {
                    if(lstreactor < rad or lstreactor_level < level) {
                         // Calculate the difference in rads; because of leveling up this gets a little annoying:
                        var _diff = 0;
                        
                         // If we haven't leveled up, just check how many rads we've gained:
                        if(lstreactor_level = level) _diff = rad - lstreactor;
                        
                         // Otherwise, calculate the difference based on the previous maximum and the overflow rads:
                        else _diff = ((lstreactor_level * 6) - lstreactor) + rad;
                        
                        with(Player) {
                            add_radhigh(_diff);
                        }
                    }
                    
                    lstreactor = rad;
                }
                
                if(lstreactor_level != level) {
                    lstreactor_level = level;
                }
            }
        }  
    }
    
     // More costly collision checks for when we can't rely on the rads variable:
    else {
        with(Player) {
            if("reactor_rads" not in self) reactor_rads = [];
            
             // Check if the rads are close enough to be worth tracking:
            with(collision_rectangle(x - 64, y - 64, x + 64, y + 64, Rad, 0, 0)) {
    			if(`reactor_${other.index}` not in self) {
    			    variable_instance_set(self, `reactor_${other.index}`, true);
    			    
    			    array_push(other.reactor_rads, [id, alarm0, rad])
    			}
    		}
    		
    		if(array_length(reactor_rads)) {
        		for(var i = 0; i <= array_length(reactor_rads) - 1; i++) {
        		     // Check if the Player has collected the tracked rads:
        		    if(!instance_exists(reactor_rads[i][0])) {
        		         // Mostly just to make sure you actually *collected* it and it didn't just despawn, somehow:
        		        if(reactor_rads[i][1] > current_time_scale) {
        		             // Seems weird, but give radhigh to every player:
        		            with(Player) {
        		                add_radhigh(other.reactor_rads[i][2]);
        		            }
        		        }
        		        
        		         // Stop tracking that we exist:
        		        reactor_rads = array_delete(reactor_rads, i);
        		    }
        		    
        		    else {
        		        reactor_rads[i][1] = reactor_rads[i][0].alarm0;
        		    }
        		}
    		}
        }
    }
    
    with(instances_matching_ne(Player, "radhigh", undefined)) {
        if(hightimer > 0) {
             // If you ACTUALLY have the combo going:
            if(radhigh >= highmax) {
                radhigh = highmax; // Just for cleanliness! .^~^.
                
                if(reload)                          reload  -= (0.6 * current_time_scale);
                if(race = "steroids" and breload)   breload -= (0.6 * current_time_scale);
            } 
            
            if(!highgrace and instance_exists(enemy)) {
	            hightimer -= current_time_scale;
	            if(hightimer <= 0) {
	                hightimer = 0;
	                if(radhigh = highmax) {
	                	maxspeed -= highspeed;
	                	radhigh = 0;
	                }
	                trace(`speed DOWN: ${maxspeed}`);
	            }
            }
        }
        
        else if(radhigh > 0) {
            radhigh -= current_time_scale;
            if(radhigh < 0) radhigh = 0;
        }
        
        if(highgrace > 0) {
        	highgrace -= current_time_scale;
        	if(highgrace < 0) highgrace = 0;
        }
    }

#define add_radhigh(_amt)
    if("radhigh" not in self) {
        radhigh   = 0;
        hightimer = 0;
        highmax   = 20;
        highgrace = 0;
    }
     // Make sure we can't exceed the maximum:
    var _diff = min(_amt, highmax - radhigh);
    
    if(radhigh != highmax and radhigh + _diff >= highmax) {
        maxspeed += highspeed;
        trace(`speed UP: ${maxspeed}`);
    }
    
    radhigh += _diff;
    if(highgrace < 10) highgrace = 10;
    
    hightimer = 90;

#define rad_draw
	with(instances_matching_ne(Player, "radhigh", null)) {
		if(radhigh = highmax) {
			draw_set_color(c_white)
			draw_rectangle(x - 13, y + 11, x + 13, y + 17, 0);
			draw_set_color(c_green);
			draw_rectangle(x - 12, y + 12, x + 12, y + 16, 0);
			draw_set_color(c_lime)
			draw_rectangle(x - 12, y + 12, x - 12 + (24 * (hightimer/90)), y + 16, 0);
		}
		
		else {
			draw_set_color(c_black);
			draw_rectangle(x - 12, y + 12, x + 12, y + 16, 0);
			if(radhigh) {
				draw_set_color(c_green);
				draw_rectangle(x - 12, y + 12, x - 12 + (24 * (radhigh/highmax)), y + 16, 0);
			}
		}
	}

#define cleanup
	with(global.reactor_draw) instance_destroy(); 

#define array_delete(_array, _index)
	/*
	    Credit: Golden Epsilon. Thanks Iris! <3
		Returns a new array with the value at the given index removed
		
		Ex:
			array_delete([1, 2, 3], 1) == [1, 3]
	*/
	
	var _new = array_slice(_array, 0, _index);
	
	array_copy(_new, array_length(_new), _array, _index + 1, array_length(_array) - (_index + 1));
	
	return _new;