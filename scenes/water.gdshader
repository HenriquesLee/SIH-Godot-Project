shader_type canvas_item;


uniform vec4 original_0 : source_color;
uniform vec4 original_1 : source_color;

uniform vec4 replace_0 : source_color;
uniform vec4 replace_1 : source_color;

const float precision =0.1;

void fragment() {
	vec4 color = texture(TEXTURE, UV);

	if(distance(color, original_0)<=0.1){
		color = replace_0;
	}
	COLOR = color;
}
