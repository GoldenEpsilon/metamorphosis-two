#define init
global.permutation = ds_list_create();
for(var i = 0; i < 128; i++) {
	ds_list_add(global.permutation, i);
}
ds_list_shuffle(global.permutation);
global.permutation = ds_list_to_array(global.permutation);
for(var i = 0; i < 128; i++) {
    array_push(global.permutation, global.permutation[i]);
}


//VARIABLES FOR TWEAKING
global.multi_object = false;
global.surface_size_x = 24;
global.surface_size_y = 32;
global.surface_mult = 1;
global.perlin_mult = 0.01 * 2;
global.size = 5 * global.surface_mult;

global.surface = surface_create(global.surface_size_x * global.surface_mult, global.surface_size_y * global.surface_mult);

#define draw_chimeric
// trace_time();

surface_set_target(global.surface);
draw_clear(c_black);

draw_set_blend_mode(bm_add);
var size = global.size;
var surface_mult = global.surface_mult;
var perlin_mult = global.perlin_mult;
var time = current_frame/60;
for(var x = -size/2; x < global.surface_size_x * surface_mult+size/2; x+=size) {
    for(var y = -size/2; y < global.surface_size_y * surface_mult+size/2; y+=size) {
        // var val = ((perlin(x * 0.01, y * 0.01)) + 1) / 2;
        var val = ((perlin3d(((x+size)/surface_mult) * perlin_mult, ((y+size)/surface_mult) * perlin_mult, time)) + 1) % 1;
        draw_set_color(make_color_hsv(val*255, 255, 65))

        
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex(x-size * 1.25+size * 0.5, y+size * 0.5);
        draw_vertex(x+size * 0.5, y - size * 1.25+size * 0.5);
        draw_vertex(x + size * 1.25+size * 0.5, y+size * 0.5);
        draw_vertex(x+size * 0.5, y + size * 1.25+size * 0.5);
        draw_vertex(x-size * 1.25+size * 0.5, y+size * 0.5);
        draw_vertex(x+size * 0.5, y - size * 1.25+size * 0.5);
        draw_primitive_end()
    }
}
draw_set_blend_mode(bm_normal);
draw_set_alpha(1)
surface_reset_target();
// trace_time("chimeric draw");

// #define draw_gui
// draw_surface_stretched(global.surface, 100, 100, 100, 100);

#define cleanup
surface_destroy(global.surface);

#define perlin(x, y)

var X = floor(x) % 256
var Y = floor(y) % 256
var xf = x-floor(x);
var yf = y-floor(y);

var topRight = [xf-1, yf-1];
var topLeft = [xf, yf-1];
var bottomRight = [xf-1, yf];
var bottomLeft = [xf, yf];

var valueTopRight = global.permutation[global.permutation[X+1]+Y+1];
var valueTopLeft = global.permutation[global.permutation[X]+Y+1];
var valueBottomRight = global.permutation[global.permutation[X+1]+Y];
var valueBottomLeft = global.permutation[global.permutation[X]+Y];

var dotTopRight = dot_product(topRight[0], topRight[1], GetConstantVector(valueTopRight)[0], GetConstantVector(valueTopRight)[1]);
var dotTopLeft = dot_product(topLeft[0], topLeft[1], GetConstantVector(valueTopLeft)[0], GetConstantVector(valueTopLeft)[1]);
var dotBottomRight = dot_product(bottomRight[0], bottomRight[1], GetConstantVector(valueBottomRight)[0], GetConstantVector(valueBottomRight)[1]);
var dotBottomLeft = dot_product(bottomLeft[0], bottomLeft[1], GetConstantVector(valueBottomLeft)[0], GetConstantVector(valueBottomLeft)[1]);

var u = Fade(xf);
var v = Fade(yf);

return lerp(
		lerp(dotBottomLeft, dotTopLeft, v),
		lerp(dotBottomRight, dotTopRight, v),
        u
	);

#define perlin3d(x, y, z)

var X = floor(x) % 128
var Y = floor(y) % 128
var Z = floor(z) % 128
var xf = x-floor(x);
var yf = y-floor(y);
var zf = z-floor(z);

var P = global.permutation;

var P1 = P[P[P[X+1]+Y+1]+Z+1];
var P2 = P[P[P[X]+Y+1]+Z+1];
var P3 = P[P[P[X+1]+Y]+Z+1];
var P4 = P[P[P[X]+Y]+Z+1];
var P5 = P[P[P[X+1]+Y+1]+Z];
var P6 = P[P[P[X]+Y+1]+Z];
var P7 = P[P[P[X+1]+Y]+Z];
var P8 = P[P[P[X]+Y]+Z];

var dotTopRightFront = dot_product_3d(xf-1, yf-1, zf-1, (P1 << 1 & 2) - 1, (P1 & 2) - 1, (P1 >> 1 & 2) - 1);
var dotTopLeftFront = dot_product_3d(xf, yf-1, zf-1, (P2 << 1 & 2) - 1, (P2 & 2) - 1, (P2 >> 1 & 2) - 1);
var dotBottomRightFront = dot_product_3d(xf-1, yf, zf-1, (P3 << 1 & 2) - 1, (P3 & 2) - 1, (P3 >> 1 & 2) - 1);
var dotBottomLeftFront = dot_product_3d(xf, yf, zf-1, (P4 << 1 & 2) - 1, (P4 & 2) - 1, (P4 >> 1 & 2) - 1);
var dotTopRightBack = dot_product_3d(xf-1, yf-1, zf, (P5 << 1 & 2) - 1, (P5 & 2) - 1, (P5 >> 1 & 2) - 1);
var dotTopLeftBack = dot_product_3d(xf, yf-1, zf, (P6 << 1 & 2) - 1, (P6 & 2) - 1, (P6 >> 1 & 2) - 1);
var dotBottomRightBack = dot_product_3d(xf-1, yf, zf, (P7 << 1 & 2) - 1, (P7 & 2) - 1, (P7 >> 1 & 2) - 1);
var dotBottomLeftBack = dot_product_3d(xf, yf, zf, (P8 << 1 & 2) - 1, (P8 & 2) - 1, (P8 >> 1 & 2) - 1);

var u = clamp(Fade(xf), 0, 1);
var v = clamp(Fade(yf), 0, 1);
var w = clamp(Fade(zf), 0, 1);

return lerp(
        lerp(
            lerp(dotBottomLeftBack, dotTopLeftBack, v),
            lerp(dotBottomRightBack, dotTopRightBack, v),
            u
        ),
        lerp(
            lerp(dotBottomLeftFront, dotTopLeftFront, v),
            lerp(dotBottomRightFront, dotTopRightFront, v),
            u
        ),
        w
	);

#define GetConstantVector(v)
    switch(v % 8){
        case 0:
            return [1.0, 1.0, 1.0];
            break;
        case 1:
            return [-1.0, 1.0, 1.0];
            break;
        case 2:
            return [1.0, -1.0, 1.0];
            break;
        case 3:
            return [-1.0, -1.0, 1.0];
            break;
        case 4:
            return [1.0, 1.0, -1.0];
            break;
        case 5:
            return [-1.0, 1.0, -1.0];
            break;
        case 6:
            return [1.0, -1.0, -1.0];
            break;
        case 7:
            return [-1.0, -1.0, -1.0];
            break;
    }

#define Fade(t)
    return ((6*t - 15)*t + 10)*power(t, 3);

#define generate(modulus, a, c, iterations, seed)
    var val = seed;
    repeat(iterations) {
        seed = (a * seed + c) % modulus
    }
    return seed;