
#ifndef imgRenkoURPToonShaderFramework_Shared_Include
#define imgRenkoURPToonShaderFramework_Shared_Include

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"

#include "NiloOutlineUtil.hlsl"
#include "NiloZOffset.hlsl"
#include "NiloInvLerpRemap.hlsl"

// note:
// subfix OS means object spaces    (e.g. positionOS = position object space)
// subfix WS means world space      (e.g. positionWS = position world space)
// subfix VS means view space       (e.g. positionVS = position view space)
// subfix CS means clip space       (e.g. positionCS = position clip space)

// all pass will share this Attributes struct (define data needed from Unity app to our vertex shader)
struct Attributes
{
    float4 positionOS   : POSITION;
    half3 normalOS      : NORMAL;
    half4 tangentOS     : TANGENT;
    float2 uv           : TEXCOORD0;
};

// all pass will share this Varyings struct (define data needed from our vertex shader to our fragment shader)
struct Varyings
{
    float2 uv                       : TEXCOORD0;
    float4 positionWSAndFogFactor   : TEXCOORD1;
    half4 positionCS                : SV_POSITION;
    half3 normalWS                  : TEXCOORD2;
    float3 tangentWS                : TEXCOORD3;
    half3 binormal                  : TEXCOORD4;
    half2 uv_BumpTex                : TEXCOORD5;
   
};

struct VaryingsRim
{
    half4 positionCS        : SV_POSITION;
    half4 positionOS        : TEXCOORD0;
    half3 normalWS          : TEXCOORD1;
    half3 normalVS          : TEXCOORD2;
    half3 positionVS        : TEXCOORD3;
    half4 positionNDC       : TEXCOORD4;
    half3 positionWS        : TEXCOORD5;
};
// for hair shadow
 struct ShadowHairVert
{
    float4 positionOS       : POSITION;
    float2 uv               : TEXCOORD0;
    float4 normal           : NORMAL;
    float3 color            : COLOR;
};

struct ShadowHairFrag
{
    float4 positionCS       : SV_POSITION;
    float2 uv               : TEXCOORD0;
    float3 positionWS       : TEXCOORD1;
    float3 normal           : TEXCOORD2;
    #if _IsFaceShadow
        float4 positionSS   : TEXCOORD3;
        float posNDCw       : TEXCOORD4;
        float4 positionOS   : TEXCOORD5;
    #endif

    float3 color: TEXCOORD6;
};

struct kajiVertData
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal: NORMAL;
    float4 tangent: TANGENT;
};

struct kajiFragData
{ 
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float3 tangent : TEXCOORD1;
    float3 normal : TEXCOORD2;
    float3 binormal: TEXCOORD3;
    float3 pos : TEXCOORD4;
    //UNITY_FOG_COORDS(1)
            
};           


///////////////////////////////////////////////////////////////////////////////////////
// CBUFFER and Uniforms 
// (you should put all uniforms of all passes inside this single UnityPerMaterial CBUFFER! else SRP batching is not possible!)
///////////////////////////////////////////////////////////////////////////////////////

// all sampler2D don't need to put inside CBUFFER 
sampler2D _BaseMap; 
sampler2D _EmissionMap;
sampler2D _OcclusionMap;
sampler2D _OutlineZOffsetMaskTex;

// put all your uniforms(usually things inside .shader file's properties{}) inside this CBUFFER, in order to make SRP batcher compatible
// see -> https://blogs.unity3d.com/2019/02/28/srp-batcher-speed-up-your-rendering/

TEXTURE2D(_OverrideLightNormal);
SAMPLER(sampler_OverrideLightNormal);
TEXTURE2D_X_FLOAT(_CameraDepthTexture);
SAMPLER(sampler_CameraDepthTexture);
TEXTURE2D(_HairSoildColor);
SAMPLER(sampler_HairSoildColor);
TEXTURE2D(_HairShadowMask);
SAMPLER(sampler_HairShadowMask);
CBUFFER_START(UnityPerMaterial)
    // base color
    float4  _BaseMap_ST;
    half4   _BaseColor;
    float   _IsFace;
    // alpha
    half    _Cutoff;
    sampler2D _AlphaTexture;
    float4 _AlphaTexture_ST;
    // emission
    float   _UseEmission;
    half3   _EmissionColor;
    half    _EmissionMulByBaseColor;
    half3   _EmissionMapChannelMask;

    // occlusion
    float   _UseOcclusion;
    half    _OcclusionStrength;
    half    _OcclusionIndirectStrength;
    half    _OcclusionDirectStrength;
    half4   _OcclusionMapChannelMask;
    half    _OcclusionRemapStart;
    half    _OcclusionRemapEnd;

    // lighting
    half3   _IndirectLightMinColor;
    half    _IndirectLightMultiplier;
    half    _DirectLightMultiplier;
    half    _CelShadeMidPoint;
    half    _CelShadeMixer;
    half    _MidPointMaskMultiplier;
    half    _CelShadeSoftness;
    half    _MainLightIgnoreCelShade;
    half    _AdditionalLightIgnoreCelShade;
    half    _ShadowRampLerp;
    half    _UseRimLight;
    half4   _RimColor;
    half   _FresnelMask;
    half    _FresnelMin;
    half    _OffsetMul;
    half    _Threshold;
    // specular
    sampler2D  _SpeculiarMask;
    float4  _SpeculiarMask_ST;
    half3   _SpecularColor;
    float   _SpecularShininess;
    float   _SpecularIntensity;
    float4  _OverrideNormalTexture_ST;
    half    _LerpBaseNormalOrOverrideNormal;
    half    _BumpScale;

    half    _LightWithNormalHeighten;
    // hair specular
    sampler2D _SpecularShift;
    float4 _SpecularShift_ST;
   // float4 _DiffuseColor;
    float4 _PrimaryColor;
    float _PrimaryShift;
    float4 _SecondaryColor;
    float _SecondaryShift;
    float _specPower;
    float _SpecularWidth;
    float _SpecularScale;
    float _ShiftScale;

    // shadow mapping
    half    _ReceiveShadowMappingAmount;
    float   _ReceiveShadowMappingPosOffset;
    float4  _ShadowColor;
    float   _ShadowAlpha;
    // shadow hair
    float4 _HairShadowBaseColor;
    // ramp
    sampler2D _RampTexture;
    float4 _RampTexture_ST;

    sampler2D _SDF_Sample;
    float4 _SDF_Sample_ST;
     half    _LerpMax;
 half    _FlipFrom;

    half    _RampTextureMappingAmount;
    half   _RampTextureMappingClamp;
    float4 _DarkShadowRampColor;
    float4 _MidstShadowRampColor;
    float4 _LightShadowRampColor;
    // outline
    float   _OutlineWidth;
    half3   _OutlineColor;
    float   _OutlineZOffset;
    float   _OutlineZOffsetMaskRemapStart;
    float   _OutlineZOffsetMaskRemapEnd;
      // auto
    float _ShadowAutoAdjustByLight;
    // faceshadow
    float4 _BrightColor, _DarkColor,  _MiddleColor;
    float _HairShadowDistace, _HeightCorrectMax, _HeightCorrectMin;
    float4 _HairShadowTexPos;
CBUFFER_END

float3 _LightDirection;

struct ToonSurfaceData
{
    half3   albedo;
    half    alpha;
    half3   emission;
    half    occlusion;
    half2   uv;
};
struct LightingData
{
    half3   normalWS;
    float3  positionWS;
    half3   viewDirectionWS;
    float4  shadowCoord;
    half3  tangentWS;
    half3 binormal;
    float3 finalNormal;
    
};

float4 TransformHClipToViewPortPos(float4 positionCS)
{
    float4 o = positionCS * 0.5f;
    o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w;
    o.zw = positionCS.zw;
    return o / o.w;
}
VaryingsRim DepthVertexWork(Attributes input)
{
    VaryingsRim output;
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.positionVS = vertexInput.positionVS;
    output.positionCS = vertexInput.positionCS;
    output.normalWS = normalInput.normalWS;
    output.positionWS = vertexInput.positionWS;
    output.positionNDC = vertexInput.positionNDC;
    return output;
}

float3 TransformPositionWSToOutlinePositionWS(float3 positionWS, float positionVS_Z, float3 normalWS)
{
    //you can replace it to your own method! Here we will write a simple world space method for tutorial reason, it is not the best method!
 
    // Question : This Out-line method did not do well when used both surface of character.
    float outlineExpandAmount = _OutlineWidth * GetOutlineCameraFovAndDistanceFixMultiplier(positionVS_Z);
    float3 result = positionWS + normalWS * outlineExpandAmount; 
    return result;
}

// if "ToonShaderIsOutline" is not defined    = do regular MVP transform
// if "ToonShaderIsOutline" is defined        = do regular MVP transform + push vertex out a bit according to normal direction
Varyings VertexShaderWork(Attributes input)
{
    Varyings output;

    output.tangentWS = normalize(TransformObjectToWorldDir(input.tangentOS.xyz)); 

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);

    // Similar to VertexPositionInputs, VertexNormalInputs will contain normal, tangent and bitangent
    // in world space. If not used it will be stripped.
    VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    float3 positionWS = vertexInput.positionWS;

#ifdef ToonShaderIsOutline
    positionWS = TransformPositionWSToOutlinePositionWS(vertexInput.positionWS, vertexInput.positionVS.z,   output.tangentWS);
#endif

    // Computes fog factor per-vertex.
    float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

    // TRANSFORM_TEX is the same as the old shader library.
    output.uv = TRANSFORM_TEX(input.uv,_BaseMap);

    // packing positionWS(xyz) & fog(w) into a vector4
    output.positionWSAndFogFactor = float4(positionWS, fogFactor);
    output.normalWS = vertexNormalInput.normalWS; //normlaized already by GetVertexNormalInputs(...)

    output.positionCS = TransformWorldToHClip(positionWS);

#ifdef ToonShaderIsOutline
    // [Read ZOffset mask texture]
    // we can't use tex2D() in vertex shader because ddx & ddy is unknown before rasterization, 
    // so use tex2Dlod() with an explict mip level 0, put explict mip level 0 inside the 4th component of param uv)
    float outlineZOffsetMaskTexExplictMipLevel = 0;
    float outlineZOffsetMask = tex2Dlod(_OutlineZOffsetMaskTex, float4(input.uv,0,outlineZOffsetMaskTexExplictMipLevel)).r; //we assume it is a Black/White texture

    // [Remap ZOffset texture value]
    // flip texture read value so default black area = apply ZOffset, because usually outline mask texture are using this format(black = hide outline)
    outlineZOffsetMask = 1-outlineZOffsetMask;
    outlineZOffsetMask = invLerpClamp(_OutlineZOffsetMaskRemapStart,_OutlineZOffsetMaskRemapEnd,outlineZOffsetMask);// allow user to flip value or remap

    // [Apply ZOffset, Use remapped value as ZOffset mask]
    output.positionCS = NiloGetNewClipPosWithZOffset(output.positionCS, _OutlineZOffset * outlineZOffsetMask);
#endif

    // ShadowCaster pass needs special process to positionCS, else shadow artifact will appear
    //--------------------------------------------------------------------------------------
#ifdef ToonShaderApplyShadowBiasFix
    // see GetShadowPositionHClip() in URP/Shaders/ShadowCasterPass.hlsl
    // https://github.com/Unity-Technologies/Graphics/blob/master/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl
    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, output.normalWS, _LightDirection));

    #if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #else
    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #endif
    output.positionCS = positionCS;
#endif
    
   
    output.binormal = normalize(cross(output.normalWS, output.tangentWS)) * input.tangentOS.w;
    return output;
}

///////////////////////////////////////////////////////////////////////////////////////
// fragment shared functions (Step1: prepare data structs for lighting calculation)
///////////////////////////////////////////////////////////////////////////////////////
half4 GetFinalBaseColor(Varyings input)
{
    return tex2D(_BaseMap, input.uv) * _BaseColor;
}
half3 GetFinalEmissionColor(Varyings input)
{
    half3 result = 0;
    if(_UseEmission)
    {
        result = tex2D(_EmissionMap, input.uv).rgb * _EmissionMapChannelMask *_EmissionMulByBaseColor * _EmissionColor.rgb;
    }

    return result;
}
half GetFinalOcculsion(Varyings input)
{
    half result = 1;
    if(_UseOcclusion)
    {
        half4 texValue = tex2D(_OcclusionMap, input.uv);
        half occlusionValue = dot(texValue, _OcclusionMapChannelMask);
        occlusionValue = lerp(1, occlusionValue, _OcclusionStrength);
        occlusionValue = invLerpClamp(_OcclusionRemapStart, _OcclusionRemapEnd, occlusionValue);
        result = occlusionValue;
    }

    return result;
}
// Hair Shadow Calcator;
ShadowHairFrag HairVert(ShadowHairVert v)
{
    ShadowHairFrag o;

    VertexPositionInputs positionInputs = GetVertexPositionInputs(v.positionOS.xyz);
    o.positionCS = positionInputs.positionCS;
    o.positionWS = positionInputs.positionWS;

    #if _IsFaceShadow
        o.posNDCw = positionInputs.positionNDC.w;
        o.positionSS = ComputeScreenPos(positionInputs.positionCS);
        o.positionOS = v.positionOS;
    #endif

    o.uv = TRANSFORM_TEX(v.uv, _BaseMap);

    VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(v.normal.xyz);
    o.normal = vertexNormalInput.normalWS;

    o.color = v.color;
    return o;
}

void DoClipTestToTargetAlphaValue(half alpha) 
{
#if _UseAlphaClipping

    clip(alpha - _Cutoff);
#endif
}

ToonSurfaceData InitializeSurfaceData(Varyings input)
{
    ToonSurfaceData output;

    // albedo & alpha
    half3 alphaBW = tex2D(_AlphaTexture,input.uv).rgb;
    
    float4 baseColorFinal = GetFinalBaseColor(input);
    output.albedo = baseColorFinal.rgb;
    output.alpha = baseColorFinal.a;
#if _WithTextureSample
   DoClipTestToTargetAlphaValue(alphaBW.r);// early exit if possible
#else
    DoClipTestToTargetAlphaValue(output.alpha);
#endif
    output.uv = input.uv;
    // emission
    output.emission = GetFinalEmissionColor(input);
 
    // occlusion
    output.occlusion = GetFinalOcculsion(input);

    return output;
}
LightingData InitializeLightingData(Varyings input)
{
    LightingData lightingData;
    lightingData.positionWS = input.positionWSAndFogFactor.xyz;
    lightingData.viewDirectionWS = SafeNormalize(GetCameraPositionWS() - lightingData.positionWS);  
    lightingData.normalWS = normalize(input.normalWS); 
    lightingData.tangentWS = input.tangentWS;
    lightingData.binormal = input.binormal;
    
    //interpolated normal is NOT unit vector, we need to normalize it
    return lightingData;

}
///////////////////////////////////////////////////////////////////////////////////////
// fragment shared functions (Step2: calculate lighting & final color)
///////////////////////////////////////////////////////////////////////////////////////

// all lighting equation written inside this .hlsl,
// just by editing this .hlsl can control most of the visual result.
#include "imgRenkoURPToonShaderFramework_LightingEquation.hlsl"

// this function contains no lighting logic, it just pass lighting results data around
// the job done in this function is "do shadow mapping depth test positionWS offset"
half3 ShadeAllLights(ToonSurfaceData surfaceData, LightingData lightingData)
{
    // Indirect lighting
    half3 indirectResult =  ShadeGI(surfaceData, lightingData) ;

  
    float3 UpperNormal =  UnpackNormalScale(SAMPLE_TEXTURE2D(_OverrideLightNormal, sampler_OverrideLightNormal, surfaceData.uv), _BumpScale);
    lightingData.finalNormal =lerp (lightingData.normalWS,UpperNormal, _LerpBaseNormalOrOverrideNormal);// ;

    Light mainLight = GetMainLight();
    half MidPointOffset = (SAMPLE_TEXTURE2D(_HairShadowMask, sampler_HairShadowMask, surfaceData.uv).g) * _MidPointMaskMultiplier;
    float3 shadowTestPosWS = lightingData.positionWS + mainLight.direction * (_ReceiveShadowMappingPosOffset + MidPointOffset);
    half3 emissionResult = ShadeEmission(surfaceData, lightingData, mainLight);
    half shadowAttenuation = 0;
#ifdef _MAIN_LIGHT_SHADOWS
    float4 shadowCoord = TransformWorldToShadowCoord(shadowTestPosWS);
   
    mainLight.shadowAttenuation = MainLightRealtimeShadow(shadowCoord);
    shadowAttenuation = mainLight.shadowAttenuation;
#endif 

    // Main light
    half3 mainLightResult = ShadeMainLight(surfaceData, lightingData, mainLight);
    
    //==============================================================================================
    // All additional lights

    half3 additionalLightSumResult = 0;
    float isAdditionalLight = 0;
#ifdef _ADDITIONAL_LIGHTS
        isAdditionalLight = 1;
    // Returns the amount of lights affecting the object being renderer.
    // These lights are culled per-object in the forward renderer of URP.
    int additionalLightsCount = GetAdditionalLightsCount();
    for (int i = 0; i < additionalLightsCount; ++i)
    {
        // Similar to GetMainLight(), but it takes a for-loop index. This figures out the
        // per-object light index and samples the light buffer accordingly to initialized the
        // Light struct. If ADDITIONAL_LIGHT_CALCULATE_SHADOWS is defined it will also compute shadows.
        int perObjectLightIndex = GetPerObjectLightIndex(i);
        Light light = GetAdditionalPerObjectLight(perObjectLightIndex, lightingData.positionWS); 
        // use original positionWS for lighting
       light.shadowAttenuation = AdditionalLightRealtimeShadow(perObjectLightIndex, shadowTestPosWS); 
       // use offseted positionWS for shadow test
       //shadowAttenuation += light.shadowAttenuation;
        // Different function used to shade additional lights.
        additionalLightSumResult += ShadeAdditionalLight(surfaceData, lightingData, light);
    };
#endif
    //====================================================================================
    // emission
    //====================================================================================
    
    //====================================================================================
    // calculate and blend ramp texture
    //====================================================================================
    float3 rampResult = 1;

    #ifdef _MAIN_LIGHT_SHADOWS
        float d = dot(lightingData.finalNormal, mainLight.direction) * 0.5 + 0.5 ;
        float normalAngle =  d;

        float c = saturate( abs(length(fwidth(lightingData.finalNormal))) / abs(length(fwidth(lightingData.positionWS))));
        
        rampResult = tex2D(_RampTexture,(float2(normalAngle,c) + _RampTexture_ST.zw) * _RampTexture_ST.xy);
        float3 Light = rampResult * _LightShadowRampColor * _LightShadowRampColor.a;
        float3 Dark = (1 - rampResult) * _DarkShadowRampColor * _DarkShadowRampColor.a;
        rampResult= Light + Dark;
     
    #endif 
        half3 N = lightingData.finalNormal;
        half3 L = mainLight.direction;
        half3 V = lightingData.viewDirectionWS;
        half3 H = normalize(L + V);
        // Specular Calculate float2(NoH, _SpecularShininess)
        float3 reflectDir = normalize(reflect(-L, N));
        half3 specRamp = tex2D(_SpeculiarMask, surfaceData.uv).rgb;//* NoL ;
        float3 specular = (_SpecularColor * specRamp * _SpecularShininess) * pow(max(0, dot(reflectDir, V)), _SpecularIntensity) * (isAdditionalLight ? 0 : 1);

    // Compostite All Light Results // CompositeAllLightResults
    half3 rawLightSum = max(indirectResult, mainLightResult + additionalLightSumResult) + specular * (shadowAttenuation) * (mainLightResult + additionalLightSumResult); // pick the highest between indirect and direct light
    half lightLuminance = Luminance(rawLightSum);
    half3 finalLightMulResult = rawLightSum / max(1,(lightLuminance / max(1,log(lightLuminance)))); // allow controlled over bright using log 

    float3 final = lerp(surfaceData.albedo * rampResult,surfaceData.albedo,_RampTextureMappingClamp) * finalLightMulResult + emissionResult;

    return final;
}

half3 ConvertSurfaceColorToOutlineColor(half3 originalSurfaceColor)
{
    return originalSurfaceColor * _OutlineColor;
}
half3 ApplyFog(half3 color, Varyings input)
{
    half fogFactor = input.positionWSAndFogFactor.w;
    // Mix the pixel color with fogColor. You can optionaly use MixFogColor to override the fogColor
    // with a custom one.
    color = MixFog(color, fogFactor);

    return color;  
}

// only the .shader file will call this function by 
// #pragma fragment ShadeFinalColor
half4 ShadeFinalColor(Varyings input) : SV_TARGET
{
    //////////////////////////////////////////////////////////////////////////////////////////
    // first prepare all data for lighting function
    //////////////////////////////////////////////////////////////////////////////////////////

    // fillin ToonSurfaceData struct:
    ToonSurfaceData surfaceData = InitializeSurfaceData(input);

    // fillin LightingData struct:
    LightingData lightingData = InitializeLightingData(input);
 
    // apply all lighting calculation
    half3 color = ShadeAllLights(surfaceData, lightingData) ;

#ifdef ToonShaderIsOutline
    color = ConvertSurfaceColorToOutlineColor(color);
#endif

    color = ApplyFog(color, input);

    return half4(color , surfaceData.alpha);
}

float4 RimLightFixed(VaryingsRim input) : SV_TARGET{
    // See this part also line 344
    #ifdef _USERIMLIGHT_ON
        float3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - input.positionWS);
        float3 normalVS = TransformWorldToViewDir(input.normalWS, true);
        float depth = input.positionNDC.z / input.positionNDC.w;
        float3 samplePositionVS = float3(input.positionVS.xy + normalVS.xy * _OffsetMul*(1- depth), input.positionVS.z);
        float4 samplePositionCS = TransformWViewToHClip(samplePositionVS); 
        float4 samplePositionVP = TransformHClipToViewPortPos(samplePositionCS);
        float linearEyeDepth = LinearEyeDepth(depth, _ZBufferParams); 
        float offsetDepth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, samplePositionVP).r; 
        // _CameraDepthTexture.r = input.positionNDC.z / input.positionNDC.w
        float linearEyeOffsetDepth = LinearEyeDepth(offsetDepth, _ZBufferParams);
        float depthDiff = linearEyeOffsetDepth - linearEyeDepth;
        float rimIntensity = step(_Threshold, depthDiff ) *2 ;
        
        

        Light mainLight = GetMainLight();
        float rimRatio = 1 - saturate(dot(viewDirectionWS, input.normalWS));
        rimRatio = pow(rimRatio, exp2(lerp(_FresnelMin, 0.0, _FresnelMask)));
        rimIntensity = lerp(0, rimIntensity, rimRatio);
        
        return rimIntensity *_RimColor * _ShadowAutoAdjustByLight;
    #else
        return 0;
    #endif

}


//////////////////////////////////////////////////////////////////////////////////////////
// fragment shared functions (for ShadowCaster pass & DepthOnly pass to use only)
//////////////////////////////////////////////////////////////////////////////////////////
void BaseColorAlphaClipTest(Varyings input)
{
    DoClipTestToTargetAlphaValue(GetFinalBaseColor(input).a);
}
half3 NormalShadering (Varyings input) : SV_TARGET{
    return  (half3)normalize(input.normalWS);
}

half4 HairFragment(ShadowHairFrag i) : SV_Target
{ 
    #if _IsFaceShadow
        float4 shadowCoord = TransformWorldToShadowCoord(i.positionWS.xyz);
        Light light = GetMainLight(shadowCoord);
        float3 normal = normalize(i.normal);
        Light mainLight;
            #if _MAIN_LIGHT_SHADOWS
                mainLight = GetMainLight(TransformWorldToShadowCoord(i.positionWS));
            #else
                mainLight = GetMainLight();
            #endif
        real shadow = mainLight.shadowAttenuation * mainLight.distanceAttenuation;
        float CelShadeMidPoint = 0;
        float halfLambert = dot(normal, light.direction) * 0.5 + 0.5;
        half ramp = smoothstep(0, CelShadeMidPoint, pow(saturate(halfLambert - CelShadeMidPoint), _CelShadeSoftness));

        //face shadow
    
        //"heightCorrect" is a easy mask which used to deal with some extreme view angles,
        //you can delete it if you think it's unnecessary.
        //you also can use it to adjust the shadow length, if you want.
        float heightCorrect = smoothstep(_HeightCorrectMax, _HeightCorrectMin, i.positionWS.y);

        //In DirectX, z/w from [0, 1], and use reversed Z
        //So, it means we aren't adapt the sample for OpenGL platform
        float depth = (i.positionCS.z / i.positionCS.w);

        //get linearEyeDepth which we can using easily
        float linearEyeDepth = LinearEyeDepth(depth, _ZBufferParams);
        float2 scrPos = i.positionSS.xy / i.positionSS.w;

        //"min(1, 5/linearEyeDepth)" is a curve to adjust viewLightDir.length by distance
        float3 viewLightDir = normalize(TransformWorldToViewDir(mainLight.direction)) * (1 / min(i.posNDCw, 1)) * min(1, 5 / linearEyeDepth) /** heightCorrect*/;

        //get the final sample point
        float2 samplingPoint = scrPos + _HairShadowDistace * (viewLightDir.xy + _HairShadowTexPos);

        float HairMask = SAMPLE_TEXTURE2D(_HairShadowMask, sampler_HairShadowMask, i.uv).r;

        float hairDepth = SAMPLE_TEXTURE2D(_HairSoildColor, sampler_HairSoildColor, samplingPoint).g * HairMask;
        hairDepth = LinearEyeDepth(hairDepth, _ZBufferParams);

        //0.01 is bias
        float depthContrast = linearEyeDepth > hairDepth * heightCorrect - 0.01 ? 0 : 1;

        //deprecated
        //float hairShadow = 1 - SAMPLE_TEXTURE2D(_HairSoildColor, sampler_HairSoildColor, samplingPoint).r;

        //0 is shadow part, 1 is bright part
        ramp *= depthContrast;
    
        float3 diffuse = lerp(_DarkColor.rgb, _BrightColor.rgb, ramp) * _ShadowAutoAdjustByLight;

        //rim light
        float3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - i.positionWS.xyz);

        return max(float4(diffuse, 1), float4(_IndirectLightMinColor, 1));
    #else
        return 1;
    #endif

   }
    kajiFragData kajiVert (kajiVertData v)
            {
             kajiFragData o;
         //   #if _IsFaceShadow
               
                
                //UNITY_INITIALIZE_OUTPUT(kajiFragData, o);
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.normal = TransformObjectToWorldNormal(v.normal);
                o.tangent = TransformObjectToWorldDir(v.tangent);
                o.binormal = normalize(cross(v.normal,o.tangent));//cross(v.normal, v.tangent) * v.tangent.w * unity_WorldTransformParams.w;

                o.pos = mul(unity_ObjectToWorld, v.vertex);
            //    #endif

//UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
      float4 kajiFrag (kajiFragData i) : SV_Target
            {
            #if _IsHair
                float4 shadowCoord = TransformWorldToShadowCoord(i.pos.xyz);
                Light light = GetMainLight(shadowCoord);
                float3 N = normalize(i.normal);
                float3 T = normalize(i.tangent);
                float3 B = normalize(i.binormal);
                float3 V = SafeNormalize(GetCameraPositionWS() - i.pos.xyz);//normalize(UnityWorldSpaceViewDir(i.pos));
                float3 L = SafeNormalize(GetCameraPositionWS() - i.pos); //normalize(UnityWorldSpaceLightDir(i.pos));
                
                float3 H = normalize(L + V);

               // float4 ambientdiffuse =1;//;getAmbientAndDiffuse((float4)(light.color,1), _DiffuseColor, N, L, i.uv);
                float4 specular = getSpecular((float4)(light.color,1), _PrimaryColor, _PrimaryShift, _SecondaryColor, _SecondaryShift, N, B, V, L, _specPower, i.uv+_SpecularShift_ST,_SpecularShift,_SpecularScale,_SpecularWidth,_ShiftScale) ;
                
                float4 col = (1 + specular);
                col.a = 1.0f;
                
             //   UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            #else
                return 1;
            #endif
            }
#endif
