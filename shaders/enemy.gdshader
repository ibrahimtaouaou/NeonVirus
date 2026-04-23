shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float line_thickness = 0.1; // Ajuste l'épaisseur

void fragment() {
    // On récupère les coordonnées UV (0 à 1)
    vec2 uv = UV;
    
    // Calcul de la distance par rapport aux bords du polygone
    float border = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
    
    // Si on est près du bord, on dessine, sinon on rend transparent
    if (border < line_thickness) {
        COLOR = line_color;
        // On booste l'intensité pour le Glow
        COLOR.rgb *= 2.0; 
    } else {
        COLOR = vec4(0.0); // Vide à l'intérieur
    }
}