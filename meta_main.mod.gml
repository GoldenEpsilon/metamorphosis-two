#define init
global.sprWaveBig = sprite_add("mutations/sprites/effects/sprBarWave.png", 8, 0, 0);

#define player_hud(_player, _hudIndex, _hudSide)
	if skill_get("wasteland_king"){
		switch(_player.race){
			case "rebel":
			//Just outright disable this if you don't have any brittle hp. No reason to be doing extra drawing
				if "brittle_health" in _player && _player.brittle_health > 0{
					//Health values
				var _my_health = _player.my_health,
					_brittle_health = _player.brittle_health,
					
					_maxhealth = _player.maxhealth,
					
					_current_health = _my_health + _brittle_health,
					_total_health = _maxhealth + _brittle_health,
			
					//Health Bar
				var _x1 = 3,
					_y1 = 4,
					
					_x2 = _x1 + 2,
					_y2 = _y1 + 3,
					_barHeight = _y2 + 7,
					
					_maxBarWidth = 88,
					_mainBarWidth = map_value(_my_health, 0, _total_health, _x2, _maxBarWidth),
					_brittleBarWidth = map_value(_brittle_health, _my_health, _total_health, _mainBarWidth, _maxBarWidth),
					
					_flash = (_player.sprite_index = _player.spr_hurt && _player.image_index < 1),
					
					//Text
					_x3 = _x2 + _maxBarWidth / 2 + 1,
					_y3 = _y2;
					
					//Main Bar
					draw_sprite(sprHealthBar, 0, _x1, _y1);
					
					//Health bar main
					var col = player_get_color(_hudIndex);
					draw_set_color(_flash ? c_white : col);

					if _my_health{ draw_rectangle(_x2, _y2, _mainBarWidth, _barHeight, false); }
					
					//Health bar brittle
					var col2 = merge_colour(make_colour_hsv(colour_get_hue(col), colour_get_saturation(col) * 0.85, colour_get_value(col) * 0.45), $6D4536, 0.25);
					draw_set_color(col2);
					
					draw_rectangle(_mainBarWidth + 1, _y2, _brittleBarWidth + _mainBarWidth - _x2, _barHeight, false);
					
					//Waves
					if _brittle_health{ draw_sprite_ext(global.sprWaveBig, 0.4 * current_frame, _mainBarWidth + 1, _y2, image_xscale, image_yscale, image_angle, _flash ? c_white : player_get_color(_hudIndex), image_alpha); }
					if (_my_health < _maxhealth){ draw_sprite_ext(global.sprWaveBig, 0.4 * (current_frame + 4), _brittleBarWidth + _mainBarWidth - _x2 + 1, _y2, image_xscale, image_yscale, image_angle, col2, image_alpha); }
					
					//Text
					draw_set_alpha(1);
					draw_set_color(c_white)
					draw_set_halign(fa_middle);
					draw_text_nt(_x3, _y3, string(_current_health) + "/" + string(_total_health))
				}
				
				draw_set_alpha(1);
				draw_set_color(c_white);
			break;
		}
	}
	
	if skill_get("molten_flesh"){
		if "moltenflesh" in _player{
			draw_set_font(fntSmall);
			
			var _heal_val = _player.heal_hud_value,
				_damage_val = _player.dmg_hud_value;
			
			draw_set_color(c_white)
			
			 // Damaging
			draw_set_halign(fa_left);
			draw_text_shadow(6, 8, "-" + string(_damage_val));
			
			 // Healing
			draw_set_halign(fa_right);
			draw_text_shadow(88, 8, "+" + string(abs(_heal_val)));
		}
	}
	
#define draw_gui
	 // Player HUD Management:
	if(instance_exists(Player) && !instance_exists(PopoScene) && !instance_exists(MenuGen)){
		if(instance_exists(TopCont) || instance_exists(GenCont) || instance_exists(LevCont)){
			var _hudFade  = 0,
			    _hudIndex = 0,
			    _lastSeed = random_get_seed();
			    
			 // Game Win Fade Out:
			if(array_length(instances_matching(TopCont, "fadeout", true))){
				with(TopCont){
					_hudFade = clamp(fade, 0, 1);
				}
			}
			if(_hudFade > 0){
				 // GMS1 Partial Fix:
				try if(!null){}
				catch(_error){
					_hudFade = min(_hudFade, round(_hudFade));
				}
				
				 // Dim Drawing:
				if(_hudFade > 0){
					draw_set_fog(true, c_black, 0, 16000 / _hudFade);
				}
			}
			
			 // Draw Player HUD:
			for(var _isOnline = 0; _isOnline <= 1; _isOnline++){
				for(var _index = 0; _index < maxp; _index++){
					if(
						player_is_active(_index)
						&& (_hudIndex < 2 || !instance_exists(LevCont))
						&& (player_is_local_nonsync(_index) ^^ _isOnline)
					){
						var _hudVisible = false;
						
						 // HUD Visibility:
						for(var i = 0; true; i++){
							var _local = player_find_local_nonsync(i);
							if(!player_is_active(_local)){
								break;
							}
							if(player_get_show_hud(_index, _local)){
								_hudVisible = true;
								break;
							}
						}
						
						 // Draw HUD:
						if(_hudVisible || _isOnline == 0){
							if(_hudVisible){
								var _player = player_find(_index);
								if(instance_exists(_player)){
									 // Rad Canister / Co-op Offsets:
									var _playerNum = 0;
									for(var i = 0; i < maxp; i++){
										_playerNum += player_is_active(i);
									}
									if(_playerNum <= 1){
										d3d_set_projection_ortho(
											view_xview_nonsync - 17,
											view_yview_nonsync,
											game_width,
											game_height,
											0
										);
									}
									else draw_set_projection(2, _index);
									
									 // Draw:
									player_hud(_player, _hudIndex, _hudIndex % 2);
									
									draw_reset_projection();
								}
							}
							_hudIndex++;
						}
					}
				}
			}
			if(_hudFade > 0){
				draw_set_fog(false, 0, 0, 0);
			}
			random_set_seed(_lastSeed);
		}
	}
	
#define draw_pause
	 // Paused Player HUD Management:
	var _local = player_find_local_nonsync();
	if(player_is_active(_local)){
		 // Store Main Player’s Variables:
		if(instance_exists(Player)){
			global.hud_pause_vars = undefined;
			with(player_find(_local)){
				global.hud_pause_vars = {};
				with(variable_instance_get_names(self)){
					lq_set(global.hud_pause_vars, self, variable_instance_get(other, self));
					
					 // I don't know why I have to do this but for some reason this ^ code doesn't grab these, so
					lq_set(global.hud_pause_vars, "sprite_index", variable_instance_get(other, "sprite_index"))
					lq_set(global.hud_pause_vars, "image_index", variable_instance_get(other, "image_index"))
				}
			}
		}
		
		 // Draw Main Player’s HUD:
		if(!instance_exists(BackMainMenu)){
			var _ref  = script_ref_create(draw_pause),
			    _vars = mod_variable_get(_ref[0], _ref[1], "hud_pause_vars");
			    
			if(!is_undefined(_vars)){
				for(var i = 0; player_is_active(player_find_local_nonsync(i)); i++){
					if(player_get_show_hud(_local, player_find_local_nonsync(i))){
						var _playerNum = 0,
						    _lastSeed  = random_get_seed();
						    
						 // View + Rad Canister Offset:
						for(var i = 0; i < maxp; i++){
							_playerNum += player_is_active(i);
						}
						d3d_set_projection_ortho(
							((_playerNum <= 1) ? -17 : 0),
							0,
							game_width,
							game_height,
							0
						);
						
						 // Draw:
						player_hud(global.hud_pause_vars, 0, false);
						
						draw_reset_projection();
						random_set_seed(_lastSeed);
						break;
					}
				}
			}
		}
	}
	
#define map_value(_value, _current_lower_bound, _current_upper_bound, _desired_lowered_bound, _desired_upper_bound)
return (((_value - _current_lower_bound) / (_current_upper_bound - _current_lower_bound)) * (_desired_upper_bound - _desired_lowered_bound)) + _desired_lowered_bound;