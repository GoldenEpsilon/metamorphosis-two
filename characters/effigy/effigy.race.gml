#define init
	global.saves = {};
	global.sprPortrait[0] = sprite_add("sprites/sprEFFIGYPortrait.png", 1, 30, 250);
	global.sprIdle[0]     = sprite_add("sprites/sprEFFIGYIdle.png",   1, 16, 20);
	global.sprWalk[0]     = sprite_add("sprites/sprEFFIGYWalk.png",   6, 24, 24);
	global.sprHurt[0]     = sprite_add("sprites/sprEFFIGYHurt.png",   3, 24, 24);
	global.sprDead[0]     = sprite_add("sprites/sprEFFIGYDead.png",   6, 24, 24);
	global.sprSit[0]      = sprite_add("sprites/sprEFFIGYSit.png",    1, 12, 12);
	global.sprGoSit[0]    = sprite_add("sprites/sprEFFIGYGoSit.png",  3, 12, 12);
	global.sprMap[0]      = sprite_add("sprites/sprEFFIGYMapA.png",   1, 10, 10);
	global.sprSkin[0]     = sprite_add("sprites/sprEFFIGYSkinA.png",  1, 16, 16);
	global.sprSkinL[0]    = sprite_add("sprites/sprEFFIGYSkinALocked.png",  1, 16, 16);
	
	global.sprPortrait[1] = sprite_add("sprites/sprEFFIGYBPortrait.png", 1, 40, 236);
	global.sprIdle[1]     = sprite_add("sprites/sprEFFIGYIdleB.png",   4, 24, 24);
	global.sprWalk[1]     = sprite_add("sprites/sprEFFIGYWalkB.png",   6, 24, 24);
	global.sprHurt[1]     = sprite_add("sprites/sprEFFIGYHurtB.png",   3, 24, 24);
	global.sprDead[1]     = sprite_add("sprites/sprEFFIGYDeadB.png",   6, 24, 24);
	global.sprSit[1]      = sprite_add("sprites/sprEFFIGYSitB.png",    1, 12, 12);
	global.sprGoSit[1]    = sprite_add("sprites/sprEFFIGYGoSitB.png",  3, 12, 12);
	global.sprMap[1]      = sprite_add("sprites/sprEFFIGYMapB.png",    1, 10, 10);
	global.sprSkin[1]     = sprite_add("sprites/sprEFFIGYSkinB.png",   1, 16, 16);
	global.sprSkinL[1]    = sprite_add("sprites/sprEFFIGYSkinBLocked.png",   1, 16, 16);
	
	global.sprSelect      = sprite_add("sprites/sprEFFIGYSelect.png",     1, 0, 0);
	global.sprSelectLock  = sprite_add("sprites/sprEFFIGYSelectLock.png", 1, 0, 0);
	global.sprUltraIcon   = sprite_add("sprites/sprUltraEFFIGYIcon.png",       3, 12, 16);
	global.sprUltraHUD[0] = sprite_add("../sprites/sprUltraEIDOLONHUD.png",  1, 8, 8);
	global.sprUltraHUD[1] = sprite_add("../sprites/sprUltraANATHEMAHUD.png", 1, 8, 8);
	
	global.sprParticle	  = sprite_add("sprites/sprEFFIGYParticle.png", 3, 1, 1);

    global.snd = {
        "EffigyHurt"    : sound_add("sounds/Characters/Effigy/sndEffigyHurt.ogg"),
        "EffigyDead"    : sound_add("sounds/Characters/Effigy/sndEffigyDeath.ogg"),
        "EffigyLowHP"   : sound_add("sounds/Characters/Effigy/sndEffigyLowHP.ogg"),
        "EffigyLowAM"   : sound_add("sounds/Characters/Effigy/sndEffigyLowAmmo.ogg"),
        "EffigySelect"  : sound_add("sounds/Characters/Effigy/sndEffigySelect.ogg"),
        "EffigyConfirm" : sound_add("sounds/Characters/Effigy/sndEffigyConfirm.ogg"),
        "EffigyChest"   : sound_add("sounds/Characters/Effigy/sndEffigyChestWeapon.ogg"),
        "EffigyWorld"   : sound_add("sounds/Characters/Effigy/sndEffigyWorld.ogg"),
        "EffigyIDPD"    : sound_add("sounds/Characters/Effigy/sndEffigyIDPD.ogg"),
        "EffigyCaptain" : sound_add("sounds/Characters/Effigy/sndEffigyCaptain.ogg"),
        "EffigyThrone"  : sound_add("sounds/Characters/Effigy/sndEffigyThrone.ogg"),
        "EffigyVault"   : sound_add("sounds/Characters/Effigy/sndEffigyVault.ogg"),
        "EffigyUltraA"  : sound_add("sounds/Ultras/sndUltEIDOLON.ogg"),
        "EffigyUltraB"  : sound_add("sounds/Ultras/sndUltANATHEMA.ogg"),
        "EffigyUltraC"  : sound_add("sounds/Ultras/sndUltDisciple.ogg"),
    }

	 // Reapply sprites if the mod is reloaded. we should add this to our older race mods //
	with(instances_matching(Player, "race", mod_current)) { 
		assign_sprites();
		assign_sounds();
	}

    global.passive_muts = save_load(mod_current, {
        "mut1": 1+irandom(28),
        "mut2": 1+irandom(28),
        "vanillamut1": 1+irandom(28),
        "vanillamut2": 1+irandom(28),
    });

#macro metacolor																`@(color:${make_color_rgb(110, 140, 110)})`
#macro scr																		mod_variable_get("mod", "metamorphosis", "scr")
#macro snd																		global.snd
#macro call																		script_ref_call

#define race_name              return "EFFIGY";
#define race_text
	var mut1 = save_get(mod_current, "mut1", 1+irandom(28));
	var mut2 = save_get(mod_current, "mut2", 1+irandom(28));
	var vanillamut1 = save_get(mod_current, "vanillamut1", 1+irandom(28));
	var vanillamut2 = save_get(mod_current, "vanillamut2", 1+irandom(28));
    if(is_string(mut1) && !mod_exists("skill", mut1)){
        mut1 = vanillamut1;
        if(is_string(mut2) && !mod_exists("skill", mut2)){
            mut2 = vanillamut2;
        }
    } else {
        if(is_string(mut2) && !mod_exists("skill", mut2)){
            mut2 = vanillamut1;
        }
    }
    return `STARTS WITH@3(${skill_get_icon(mut1)[0]}:${skill_get_icon(mut1)[1]})AND@3(${skill_get_icon(mut2)[0]}:${skill_get_icon(mut2)[1]})##${metacolor}SACRIFICE@w MUTATIONS`;

#define create
	assign_sprites();

#define step
	if random(2) < 1 repeat(random_range(1, 3)) with(instance_create(Player.x + 4 * right, Player.y - 7, Curse)){ sprite_index = global.sprParticle; direction = random(360) image_speed = 0.4 }

#define assign_sprites
	if(object_index = Player) {
		spr_idle = global.sprIdle[bskin];
		spr_walk = global.sprIdle[bskin];
		spr_hurt = global.sprHurt[bskin];
		spr_dead = global.sprDead[bskin];
		spr_sit2 = global.sprSit[bskin];
		spr_sit1 = global.sprGoSit[bskin];
	}

#define assign_sounds
	snd_hurt = snd.EffigyHurt;
	snd_dead = snd.EffigyDead;
	snd_lowa = snd.EffigyLowAM;
	snd_lowh = snd.EffigyLowHP;
	snd_wrld = snd.EffigyWorld;
	snd_crwn = snd.EffigyConfirm;
	snd_chst = snd.EffigyChest;
	snd_valt = snd.EffigyVault;
	snd_thrn = snd.EffigyVault;
	snd_spch = snd.EffigyThrone;
	snd_idpd = snd.EffigyIDPD;
	snd_cptn = snd.EffigyCaptain;

    

#define skill_get_icon(_mut)
	/*
		Returns an array containing the [sprite_index, image_index] of a mutation's HUD icon
	*/
	
	if(is_real(_mut)){
		return [sprSkillIconHUD, _mut];
	}
	
	if(is_string(_mut) && mod_script_exists("skill", _mut, "skill_icon")){
		return [mod_script_call("skill", _mut, "skill_icon"), 0];
	}
	
	return [sprEGIconHUD, 2];

#define save_load
	//(_mod, ?default)
	//_mod should be a string, default should be a lwo with all key/value pairs you want set if they are not found.
	wait(file_load("../saves/"+argument[0]+"Save.json"));
	while(!file_loaded("../saves/"+argument[0]+"Save.json")){wait(1);}
	var json = {};
	if(file_exists("../saves/"+argument[0]+"Save.json")){
		json = json_decode(string_load("../saves/"+argument[0]+"Save.json"));
	}
	if(json != json_error){
		if(argument_count == 2){
			for(var i = 0; i < lq_size(argument[1]); i++){
				if(lq_get_key(argument[1], i) not in json){
					lq_set(json, lq_get_key(argument[1], i), lq_get_value(argument[1], i));
				}
			}
		}
		save_reset(argument[0], json);
	}

#define save_get
	//(_mod, _name, ?default)
	if(argument[0] not in global.saves){
		//You really should be calling save_load first, to avoid trouble with waits, but if you don't this'll be a backup.
		save_load(argument[0]);
	}
	if(argument[0] in global.saves && argument[1] in lq_defget(global.saves, argument[0], noone)){
		return lq_get(lq_get(global.saves, argument[0]), argument[1]);
	}
	if(argument_count == 3){
		return argument[2];
	}
	return noone;
	
#define save_set(_mod, _name, _value)
	if(_mod not in global.saves){
		var save = {};
		lq_set(save, _name, _value);
		lq_set(global.saves, _mod, save);
	}else{
		lq_set(lq_get(global.saves, _mod), _name, _value);
	}
	string_save(json_encode(lq_get(global.saves, _mod)), "../saves/"+_mod+"Save.json");
	
#define save_reset(_mod, _lwo)
	lq_set(global.saves, _mod, _lwo);
	string_save(json_encode(lq_get(global.saves, _mod)), "../saves/"+_mod+"Save.json");