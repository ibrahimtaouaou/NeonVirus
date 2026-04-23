shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float grid_spacing = 150.0;
uniform float thickness = 0.02;
uniform vec2 camera_offset;

void fragment() {
    // 1. Calcul de la position (le mouvement est maintenant fluide et infini)
    vec2 pos = (SCREEN_UV * (1.0 / SCREEN_PIXEL_SIZE)) + (camera_offset * 1.0);
    
    // 2. Création de la grille
    vec2 grid = abs(fract(pos / grid_spacing - 0.5) - 0.5);
    
    // 3. Antialiasing (pour que les lignes restent nettes mais sans scintiller)
    vec2 fw = fwidth(pos / grid_spacing);
    vec2 line = smoothstep(vec2(thickness) + fw, vec2(thickness), grid);
    
    // 4. Intensité uniforme (on a supprimé la vignette)
    float alpha = max(line.x, line.y);
    
    // 5. Rendu final avec le glow choisi
    COLOR = vec4(line_color.rgb, alpha * line_color.a);
}