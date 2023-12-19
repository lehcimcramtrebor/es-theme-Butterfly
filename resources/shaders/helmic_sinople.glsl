// Parameter lines go here:
#pragma parameter SCANTHICK "SCANLINE THICKNESS" 2.0 2.0 4.0 1.0
#pragma parameter INTENSITY "SCANLINE INTENSITY" 0.6 0.0 1.0 0.02
#pragma parameter BRIGHTBOOST "LUMINANCE BOOST" 0.25 0.0 1.0 0.01
#pragma parameter shadowmask "MASK TYPE 0:CGWG, 1:LOTTES" 0.0 -1.0 1.0 1.0
#pragma parameter msk_size "MASK SIZE" 1.0 1.0 2.0 1.0
#pragma parameter CGWG "MASK STRENGTH" 0.3 0.0 1.0 0.1
#pragma parameter BLUR "BLUR STRENGTH" 0.6 0.0 1.0 0.1
#pragma parameter GAMMA "GAMMA" 0.45 0.0 0.80 0.01
#pragma parameter SATURATION "SATURATION" 1.0 0.0 2.0 0.05 

#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying 
#define COMPAT_ATTRIBUTE attribute 
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec2 invDims;

vec4 _oPosition1; 
uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

void main()
{
    gl_Position = MVPMatrix * VertexCoord;
    COL0 = COLOR;
    TEX0.xy = TexCoord.xy * 1.00001;
    invDims=1.0/TextureSize.xy;
}

#elif defined(FRAGMENT)

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform sampler2D Texture;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec2 invDims;

// compatibility #defines
#define Source Texture
#define vTexCoord TEX0.xy

#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define OutputSize vec4(OutputSize, 1.0 / OutputSize)

#ifdef PARAMETER_UNIFORM
// All parameter floats need to have COMPAT_PRECISION in front of them
uniform COMPAT_PRECISION float SCANTHICK;
uniform COMPAT_PRECISION float INTENSITY;
uniform COMPAT_PRECISION float BRIGHTBOOST;
uniform COMPAT_PRECISION float CGWG;
uniform COMPAT_PRECISION float BLUR;
uniform COMPAT_PRECISION float GAMMA;
uniform COMPAT_PRECISION float SATURATION;
uniform COMPAT_PRECISION float shadowmask;
uniform COMPAT_PRECISION float msk_size;

#else
#define SCANTHICK 0.0
#define INTENSITY 0.15
#define BRIGHTBOOST 0.25
#define CGWG 0.3
#define BLUR 0.6
#define GAMMA 0.45
#define SATURATION 1.0
#define shadowmask 1.0
#define msk_size 1.0

#endif

vec3 mask(float p)
{
    p = floor(p/msk_size);

    vec3 Mask = vec3(1.0);
    float m=1.0-CGWG;

    if (shadowmask == 0.0)
    {
    float pos = fract (p*0.5);

    if (pos < 0.5) {Mask.r=1.0, Mask.g=m, Mask.b=1.0;}
    else {Mask.r=m, Mask.g=1.0, Mask.b=m;}
    }

    if (shadowmask == 1.0)
    {
    float pos = fract (p*0.3333);

    if (pos<0.333) {Mask.r=1.0, Mask.g=m, Mask.b=m;}
    else if (pos<0.666) {Mask.r=m, Mask.g=1.0, Mask.b=m;}
    else {Mask.r=m, Mask.g=m, Mask.b=1.0;}
    }
    
    return Mask;
}


//SIMPLE AND FAST SATURATION
vec3 saturation (vec3 textureColor)

{
    vec3 luminanceWeighting = vec3(0.3, 0.6, 0.1);
    float luminance = dot(textureColor.rgb, luminanceWeighting);
    vec3 greyScaleColor = vec3(luminance);

    vec3 res = vec3(mix(greyScaleColor, textureColor.rgb, SATURATION));
    return res;
}


void main()
{
    vec2 pos = TEX0.xy * 0.995+0.0025;
    vec2 p = pos * TextureSize; 
    vec2 i = floor(p)*1.0001 + 0.5;
    vec2 f = p - i;
    p = (i + 4.0*f*f*f)*invDims;
    p.x = mix(p.x, pos.x, BLUR);
    
    vec3 texel = COMPAT_TEXTURE(Texture, p).rgb;
    vec3 pixelHigh = ((1.0 + BRIGHTBOOST) - (0.2 * texel)) * texel;
    vec3 pixelLow  = ((1.0 - INTENSITY) + (0.1 * texel)) * texel;
    float selectY = mod(TEX0.y * SCANTHICK * TextureSize.y, 2.0);
    float selectHigh = step(1.0, selectY);
    float selectLow = 1.0 - selectHigh;
    vec3 pixelColor = (selectLow * pixelLow) + (selectHigh * pixelHigh);
    pixelColor*=pixelColor;
    pixelColor*= mask(gl_FragCoord.x);

    pixelColor = pow(pixelColor,vec3(GAMMA));
    pixelColor= saturation(pixelColor);
    FragColor = vec4(pixelColor, 1.0);




// Définissez les couleurs de la bordure intérieure, médiane, extérieure et la nouvelle bordure
vec3 outerBorderColor = vec3(0.0, 0.0, 0.0); // Couleur extérieure (blanc dans cet exemple)
vec3 newBorderColor = vec3(0.0, 0.0, 0.0); // Couleur de la nouvelle bordure (rouge dans cet exemple)
vec3 middleBorderColor = vec3(0.1882, 0.8667, 0.1882); // Couleur médiane (gris dans cet exemple)
vec3 innerBorderColor = vec3(0.0, 0.0, 0.0); // Couleur intérieure (noir dans cet exemple)

float outerBorderSize = 0.005; // Taille de la bordure extérieure
float newBorderSize = 0.010; // Taille de la nouvelle bordure
float middleBorderSize = 0.014; // Taille de la bordure médiane
float innerBorderSize = 0.019; // Taille de la bordure intérieure

// Créez la bordure extérieure
if (pos.x < outerBorderSize || pos.x > 1.0 - outerBorderSize || pos.y < outerBorderSize || pos.y > 1.0 - outerBorderSize) {
    FragColor = vec4(outerBorderColor, 0.05);
    return;
}

// Créez la nouvelle bordure
if (pos.x < newBorderSize || pos.x > 1.0 - newBorderSize || pos.y < newBorderSize || pos.y > 1.0 - newBorderSize) {
    FragColor = vec4(newBorderColor, 0.1);
    return;
}

// Créez la bordure médiane
if (pos.x < middleBorderSize || pos.x > 1.0 - middleBorderSize || pos.y < middleBorderSize || pos.y > 1.0 - middleBorderSize) {
    FragColor = vec4(middleBorderColor, 0.9);
    return;
}

// Créez la bordure intérieure
if (pos.x < innerBorderSize || pos.x > 1.0 - innerBorderSize || pos.y < innerBorderSize || pos.y > 1.0 - innerBorderSize) {
    FragColor = vec4(innerBorderColor, 1.0);
    return;
}



} 
#endif
