#define init

	global.objects = ds_map_create();
    obj_setup(mod_current, "LibPrompt");
    global.late_step    = noone;


#define testprompt_create(_x, _y)
    with(instance_create(_x, _y, CustomObject)){
        sprite_index    = sprPlasmaBall;
        image_speed     = 0;
        
        with(prompt_create("TEST!")){
            on_step     = testprompt_step;
            creator     = other;
        }
    }

#define testprompt_step
    if(pick != -1 ){
        trace("PICK!")
    }

#define step
     // Bind Late Step:
    if(!instance_exists(global.late_step)){
        global.late_step = script_bind_step(late_step, 0);
    }

    // if(button_pressed(0, "horn")){
    //     testprompt_create(mouse_x, mouse_y);
    // }
    
#define late_step
	 // Prompts:
	//Note: This code IS basically just taken from TE, but it means that it works alongside TE prompts.
	var _inst = instances_matching(CustomObject, "name", "LibPrompt");
	if(array_length(_inst)){
		 // Reset:
		var _instReset = instances_matching_ne(_inst, "pick", -1);
		if(array_length(_instReset)){
			with(_instReset){
				pick = -1;
			}
		}
		
		 // Player Collision:
		if(instance_exists(Player)){
			_inst = instances_matching(_inst, "visible", true);
			if(array_length(_inst)){
				with(instances_matching(Player, "visible", true)){
					var _id = id;
					if(
						place_meeting(x, y, CustomObject)
						&& !place_meeting(x, y, IceFlower)
						&& !place_meeting(x, y, CarVenusFixed)
					){
						var _noVan = true;
						
						 // Van Check:
						if(instance_exists(Van) && place_meeting(x, y, Van)){
							with(instances_meeting(x, y, instances_matching(Van, "drawspr", sprVanOpenIdle))){
								if(place_meeting(x, y, other)){
									_noVan = false;
									break;
								}
							}
						}
						
						if(_noVan){
							var	_nearest  = noone,
								_maxDis   = null,
								_maxDepth = null;
								
							// Find Nearest Touching Indicator:
							if(instance_exists(nearwep)){
								_maxDis   = point_distance(x, y, nearwep.x, nearwep.y);
								_maxDepth = nearwep.depth;
							}
							with(instances_meeting(x, y, _inst)){
								if(place_meeting(x, y, other)){
									if(!instance_exists(creator) || creator.visible){
										if(!is_array(on_meet) || mod_script_call(on_meet[0], on_meet[1], on_meet[2])){
											if(_maxDepth == null || depth < _maxDepth){
												_maxDepth = depth;
												_maxDis   = null;
											}
											if(depth == _maxDepth){
												var _dis = point_distance(x, y, other.x, other.y);
												if(_maxDis == null || _dis < _maxDis){
													_maxDis  = _dis;
													_nearest = self;
												}
											}
										}
									}
								}
							}
							
							 // Secret IceFlower:
							with(_nearest){
								nearwep = instance_create(x + xoff, y + yoff, IceFlower);
								with(nearwep){
									name         = _nearest.text;
									x            = xstart;
									y            = ystart;
									xprevious    = x;
									yprevious    = y;
									visible      = false;
									mask_index   = mskNone;
									sprite_index = mskNone;
									spr_idle     = mskNone;
									spr_walk     = mskNone;
									spr_hurt     = mskNone;
									spr_dead     = mskNone;
									spr_shadow   = -1;
									snd_hurt     = -1;
									snd_dead     = -1;
									size         = 0;
									team         = 0;
									my_health    = 99999;
									nexthurt     = current_frame + 99999;
								}
								with(_id){
									nearwep = _nearest.nearwep;
									if(button_pressed(index, "pick")){
										_nearest.pick = index;
										if(instance_exists(_nearest.creator) && "on_pick" in _nearest.creator){
											with(_nearest.creator){
												if(!is_array(on_pick)){
													trace("on_pick needs to use script_ref_create");
												}
												script_ref_call(on_pick, _id.index, _nearest.creator, _nearest);
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
#define prompt_create(_text)
	/*
		Creates an E key prompt with the given text that targets the current instance
	*/
	
	with(obj_create(x, y, "LibPrompt")){
		text    = _text;
		creator = other;
		depth   = other.depth;
		
		return self;
	}
	
	return noone;
	
#define LibPrompt_create(_x, _y)
	with(instance_create(_x, _y, CustomObject)){
		 // Vars:
		mask_index = mskWepPickup;
		persistent = true;
		creator    = noone;
		nearwep    = noone;
		depth      = 0; // Priority (0==WepPickup)
		pick       = -1;
		xoff       = 0;
		yoff       = 0;
		
		 // Events:
		on_meet = null;
		
		return self;
	}
	
#define LibPrompt_begin_step
	with(nearwep){
		instance_delete(self);
	}
	
#define LibPrompt_end_step
	 // Follow Creator:
	if(creator != noone){
		if(instance_exists(creator)){
			if(instance_exists(nearwep)){
				with(nearwep){
					x += other.creator.x - other.x;
					y += other.creator.y - other.y;
					visible = true;
				}
			}
			x = creator.x;
			y = creator.y;
		}
		else instance_destroy();
	}
	
#define LibPrompt_cleanup
	with(nearwep){
		instance_delete(self);
	}
	
#define obj_setup(_mod, _name)
/* Creator: Golden Epsilon
Description: 
	Sets up a custom object to be created using obj_create.
	Should only be run from .mod.gml-style mods
Arguments:
	_mod : the name of the mod that has the relevant scripts
	_name : the name of the object (make sure this is unique) (can be an array)
*/
	if(is_array(_name)){
		for(var i = 0; i < array_length(_name); i++){
			obj_setup(_mod, _name[i]);
		}
		return;
	}
	global.objects[? _name] = {
		setup : false,
		type : "mod", 
		modName : _mod, 
		name : _name
	};

#define obj_create(_x, _y, _name)
/* Creator: Yokin (modified by Golden Epsilon)
Description: 
	Creates an object, vanilla or custom, and sets up scripts for it automatically.
	If it is a custom object, run obj_setup for it before running obj_create 
	(you only need to run obj_setup once for each object, though)
Arguments:
	_x : the x position of the object when created
	_y : the y position of the object when created
	_name : the name/id of the object to create (can be an array bcuz wynaut)
New Script Hooks: (in other words, stuff like Bandit_create)
	*_create(_x, _y) : This function will be run as the object is created. Should return the created object.
	*_pick(_index) : if you run create_prompt on this object and the player presses E to activate it, this script will run.
Returns:
	The created object.
*/
	if(is_array(_name)){
		var _insts = [];
		for(var i = 0; i < array_length(_name); i++){
			array_push(_insts, obj_create(_x, _y, _name[i]));
		}
		return _insts;
	}
    
     // Normal Object:
    if(is_real(_name) && object_exists(_name)){
        return instance_create(_x, _y, _name);
    }
	
     // Custom Object:
    if(ds_map_exists(global.objects, _name)){
		var obj = global.objects[? _name];
		if(!obj.setup){
			global.objects[? _name].setup = true;
			 // Auto Script Binding (thanks bee):
			with([
				
				 // General:
				"_begin_step",
				"_step",
				"_end_step",
				"_draw",
				"_destroy",
				"_cleanup",
				
				 // Hitme/Enemy:
				"_hurt",
				"_death",
				
				 // Projectile:
				"_anim",
				"_wall",
				"_hit",
				
				 // Slash:
				"_grenade",
				"_projectile",
				
				 // Lib stuff
				"_pick"// When there's an E prompt picked on this object
			]){
				var _var =  "on" + self,
					_scr = _name + self;
				
				if(mod_script_exists(obj.type, obj.modName, _scr)){
					var _ref = script_ref_create_ext(obj.type, obj.modName, _scr);
					variable_instance_set(global.objects[? _name], _var, _ref);
				} else {
					variable_instance_set(global.objects[? _name], _var, undefined);
				}
			}
		
			for(var i = 0; i <= 11; i++) {
				var _alrm = "_alrm" + string(i);
				
				if(mod_script_exists(obj.type, obj.modName, string(_name) + _alrm)){
					var _ref = script_ref_create_ext(obj.type, obj.modName, string(_name) + _alrm);
					variable_instance_set(global.objects[? _name], "on" + _alrm, _ref);
				} else {
					variable_instance_set(global.objects[? _name], "on" + _alrm, undefined);
				}
			}
			
			//need to update obj because setup probably added stuff to the variable behind it
			obj = global.objects[? _name];
		}
		
		var _inst = script_ref_call([obj.type, obj.modName, obj.name + "_create"], _x, _y);
            
		
         // No Return Value:
        if(is_undefined(_inst) || _inst == 0){
            _inst = noone;
        }
        
         // Auto Assign Things:
        if(instance_exists(_inst)){
			with([
				
				 // General:
				"_begin_step",
				"_step",
				"_end_step",
				"_draw",
				"_destroy",
				"_cleanup",
				
				 // Hitme/Enemy:
				"_hurt",
				"_death",
				
				 // Projectile:
				"_anim",
				"_wall",
				"_hit",
				
				 // Slash:
				"_grenade",
				"_projectile",
				
				 // Lib stuff
				"_pick"// When there's an E prompt picked on this object
			]){
				var _var =  "on" + self;
				if(variable_instance_get(_inst, _var) != undefined){
				}else if(variable_instance_get(global.objects[? _name], _var) != undefined){
					variable_instance_set(_inst, _var, variable_instance_get(global.objects[? _name], _var));
				} else {
					switch(self) {
						case "_step": 
							if(instance_is(_inst, CustomEnemy)) _inst.on_step = script_ref_create_ext(obj.type, obj.modName, "enemy_step"); 
							else if(instance_is(_inst, CustomHitme)) _inst.on_step = script_ref_create_ext(obj.type, obj.modName, "hitme_step"); 
						break;
						case "_hurt": if(instance_is(_inst, hitme)) _inst.on_hurt = script_ref_create_ext(obj.type, obj.modName, "enemy_hurt"); break;
						case "_death": if(instance_is(_inst, CustomEnemy)) _inst.on_death = script_ref_create_ext(obj.type, obj.modName, "enemy_death"); break;
						case "_draw": if(instance_is(_inst, CustomEnemy)) _inst.on_draw = script_ref_create_ext(obj.type, obj.modName, "draw_self_enemy"); break;
					}
				}
			}
			
			for(var i = 0; i <= 11; i++) {
				var _alrm = "_alrm" + string(i);
				
				if(variable_instance_get(global.objects[? _name], "on" + _alrm) != undefined){
					variable_instance_set(_inst, "on" + _alrm, variable_instance_get(global.objects[? _name], "on" + _alrm));
				}
			}
					
			if(instance_is(_inst, hitme)) {
				if(variable_instance_exists(_inst, "spr_idle")) _inst.sprite_index = _inst.spr_idle;
				if(instance_is(_inst, CustomEnemy)) _inst.target = noone;
			}
			
			_inst.name = _name;
		}
        
        return _inst;
    }
    
     // Return List of Objects:
    if(is_undefined(_name)){
        return ds_map_keys(global.objects);
    }
    
    return noone;
    
#define instances_meeting(_x, _y, _obj)
	/*
		Returns all instances whose bounding boxes overlap the calling instance's bounding box at the given position
		Much better performance than manually performing 'place_meeting(x, y, other)' on every instance
	*/
	
	var	_tx = x,
		_ty = y;
		
	x = _x;
	y = _y;
	
	var _inst = instances_matching_ne(instances_matching_le(instances_matching_ge(instances_matching_le(instances_matching_ge(_obj, "bbox_right", bbox_left), "bbox_left", bbox_right), "bbox_bottom", bbox_top), "bbox_top", bbox_bottom), "id", id);
	
	x = _tx;
	y = _ty;
	
	return _inst;