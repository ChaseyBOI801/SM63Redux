//adapted heavily from https://github.com/steincodes/godot-shader-tutorials/blob/master/Shaders/outline.shader
shader_type canvas_item;
render_mode unshaded;

uniform vec2 atlas_dimensions = vec2(1);
uniform int width = 1;
uniform bool radial;
uniform vec4 outline_color : hint_color;

varying vec2 o;
varying vec2 f;

void vertex()
{
//	vec2 REALUV = vec2(
//		mod(atlas_dimensions.x * UV.x, 1),
//		mod(atlas_dimensions.y * UV.y, 1)
//	);
	o = VERTEX;
	vec2 uv = (UV - 0.5);
	VERTEX += uv * float(width) * 2.;
	f = VERTEX;
}

void fragment(){
	//using capitals here since this is read only
	vec2 REALUV = vec2(
		mod(atlas_dimensions.x * UV.x, 1),
		mod(atlas_dimensions.y * UV.y, 1)
	);
	REALUV = UV;
	REALUV.x = REALUV.x + (f.x - o.x) * TEXTURE_PIXEL_SIZE.x;
	REALUV.y = REALUV.y + (f.y - o.y) * TEXTURE_PIXEL_SIZE.y;
	
	COLOR = texture(TEXTURE, REALUV);
	if(COLOR.a <= 0. || REALUV.x > 1. || REALUV.x < 0. || REALUV.y > 1. || REALUV.y < 0.){
		for(float x = -float(width); x <= float(width); x += 1.){ //idk why this needs to be a float
			for(float y = -float(width); y <= float(width); y += 1.){
				//exclude pixels outside the mask
				if(distance(vec2(0), vec2(float(x), float(y))) > float(width) && radial || abs(x) == abs(y) && !radial)
					continue;
					
				vec2 neighbor_uv = REALUV + vec2(TEXTURE_PIXEL_SIZE.x * float(x), TEXTURE_PIXEL_SIZE.y * float(y)); 
				
				//fail when OoB
				vec4 neighbor_col = texture(TEXTURE, neighbor_uv);
				if((neighbor_uv.x < 0. || neighbor_uv.x > 1.) || (neighbor_uv.y < 0. || neighbor_uv.y > 1.)){
					neighbor_col = vec4(0);
				}
				
				if(neighbor_col.a > 0.){
					COLOR = outline_color;
				}
			}
		}
	}
}