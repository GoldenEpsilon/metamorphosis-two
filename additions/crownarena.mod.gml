#define init
    global.crownhands = sprite_add("sprites/CrownHands.png", 1, 32, 45);
    global.crownhandshurt = sprite_add("sprites/CrownHandsHurt.png", 3, 32, 45);
    global.crownhandsanim = sprite_add("sprites/CrownHandsAnim.png", 5, 32, 45);

    global.lastarea = 1;
    global.lastsubarea = 1;


#define step
    if(GameCont.area == "crownarena" && instance_exists(Portal)){
        GameCont.area = global.lastarea;
        GameCont.subarea = global.lastsubarea;
    }
    if(GameCont.area == 100){
        with(CrownPed){
            if(fork()){
                var _x = x;
                var _y = y;

                //Wait cuz horror spawning doesn't trigger the on_death for some reason
                wait(2);

                with(instance_create(_x, _y, CustomProp)){
                    sprite_index = global.crownhands;
                    spr_idle = global.crownhands;
                    spr_hurt = global.crownhandshurt;
                    spr_dead = global.crownhandsanim;

                    depth = -1;

                    on_draw = pedestal_draw;
                    on_death = pedestal_death;
                    on_pick  = script_ref_create(pedestal_pick);

                    maxhealth = 40;
                    my_health = maxhealth;

                    with(mod_script_call("mod", "prompts", "prompt_create", "TAKE CROWN")){
                        creator = other;
                    }
                }
                exit;
            }
            instance_destroy();
        }
        with(CrownPickup){
            instance_destroy();
        }
    }

#define pedestal_pick
    on_death = pedestal_nodeath;
    with(instance_create(x, y-8, Portal)){
        type = 2;
        GameCont.crownpoints = 1;
        GameCont.area = GameCont.lastarea;
        GameCont.subarea = GameCont.lastsubarea + 1;
    }
    instance_destroy(self);

#define pedestal_draw
    draw_self();
    draw_sprite(sprCrown1Idle, 0, x, y-15+sin(current_frame/15)*2);

#define pedestal_nodeath

#define pedestal_death
    global.lastarea = GameCont.lastarea;
    global.lastsubarea = GameCont.lastsubarea;
    with(instance_create(x, y-8, Portal)){
        type = 2;
        GameCont.pedestalarena = true;
    }