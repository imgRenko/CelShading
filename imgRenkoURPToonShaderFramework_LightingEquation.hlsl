// For more information, visit -> https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample

// This file is intented for you to edit and experiment with different lighting equation.
// Add or edit whatever code you want here

// #ifndef XXX + #define XXX + #endif is a safe guard best practice in almost every .hlsl, 
// doing this can make sure your .hlsl's user can include this .hlsl anywhere anytime without producing any multi include conflict
#ifndef imgRenkoURPToonShaderFramework_LightingEquation_Include
#define imgRenkoURPToonShaderFramework_LightingEquation_Include

half3 ShadeGIDefaultMethod(ToonSurfaceData surfaceData, LightingData lightingData)
{
    // hide 3D feeling by ignoring all detail SH
    // SH 1 (only use this)
    // SH 234 (ignored)
    // SH 56789 (ignored)
    // we just want to tint some average envi color only
    half3 averageSH = SampleSH(0);
    // occlusion
    // separated control for indirect occlusion
    half indirectOcclusion = lerp(1, surfaceData.occlusion, _OcclusionIndirectStrength);
    half3 indirectLight = (averageSH) * (_IndirectLightMultiplier * indirectOcclusion )  ;
    return max(indirectLight, _IndirectLightMinColor); // can prevent completely black if lightprobe was not baked
}
half3 GetLightAttenuation(Light light,half NoL,bool isAdditionalLight){
    half3 lightAttenuation = 1;
    // light's shadow map. If you prefer hard shadow, you can smoothstep() light.shadowAttenuation to make it sharp.
    lightAttenuation *= lerp(1,light.shadowAttenuation,_ReceiveShadowMappingAmount) ;

    // light's distance & angle fade for point light & spot light (see GetAdditionalPerObjectLight() in Lighting.hlsl)
    // Lighting.hlsl -> https://github.com/Unity-Technologies/Graphics/blob/master/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl


    lightAttenuation *= min(4,light.distanceAttenuation); //prevent light over bright if point/spot light too close to vertex

    // N dot L
    // simplest 1 line cel shade, you can always replace this line by your own better method !
    half celShadeResult = smoothstep((_CelShadeMidPoint-_CelShadeSoftness),(_CelShadeMidPoint+_CelShadeSoftness), NoL);

    // don't want direct lighting's cel shade effect looks too strong? set ignoreValue to a higher value
    lightAttenuation *= lerp(celShadeResult,1, isAdditionalLight? _AdditionalLightIgnoreCelShade : _MainLightIgnoreCelShade);

    // don't want direct lighting becomes too bright for toon lit characters? set this value to a lower value 
    lightAttenuation *= _DirectLightMultiplier* (isAdditionalLight ? 1:_ShadowAutoAdjustByLight);

    return lightAttenuation;
}
// Most important part: lighting equation, edit it according to your needs, write whatever you want here, be creative!
// this function will be used by all direct lights (directional/point/spot)
 half3 ShadeSingleLightDefaultMethod(ToonSurfaceData surfaceData, LightingData lightingData, Light light, bool isAdditionalLight)
{
     half3 N = lightingData.finalNormal;
     half3 L = light.direction;
     half3 V = lightingData.viewDirectionWS;
     half3 H = normalize(L + V);

     half NoL = dot(N, L);
     float NoH = max(0, dot(N, H));
     half3 lightAttenuation = 1;
    //lightAttenuation = GetLightAttenuation(light, NoL, isAdditionalLight);
     // light's distance & angle fade for point light & spot light (see GetAdditionalPerObjectLight(...) in Lighting.hlsl)
     // Lighting.hlsl -> https://github.com/Unity-Technologies/Graphics/blob/master/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl
    half distanceAttenuation = min(4, light.distanceAttenuation); //clamp to prevent light over bright if point/spot light too close to vertex

     //half MidPointOffseted = _CelShadeMidPoint +lerp(-0.5,0.5, MidOffset);
         // N dot L
        // simplest 1 line cel shade, you can always replace this line by your own method!
    half litOrShadowArea = smoothstep(_CelShadeMidPoint - _CelShadeSoftness, _CelShadeMidPoint + _CelShadeSoftness, NoL);

            // occlusion
    litOrShadowArea *= surfaceData.occlusion;

            // face ignore celshade since it is usually very ugly using NoL method
    litOrShadowArea = _IsFace ? lerp(0.5, 1, litOrShadowArea) : litOrShadowArea;

            // light's shadow map
    litOrShadowArea *= lerp(1, light.shadowAttenuation, _ReceiveShadowMappingAmount) ;

            
        

    half3 litOrShadowColor = lerp(_ShadowColor, 1, litOrShadowArea);

    half3 lightAttenuationRGB = litOrShadowColor * distanceAttenuation;

    // saturate() light.color to prevent over bright
    // additional light reduce intensity since it is additive
     #if _UseSDFFaceShadow
        float isSahdow = 0;
        //这张阈值图代表的是阴影在灯光从正前方移动到左后方的变化
        half4 ilmTex = tex2D(_SDF_Sample, surfaceData.uv);

        if (ilmTex.g == 1)
            return saturate(light.color) * lightAttenuationRGB * (isAdditionalLight ? 0.25 : 1) ;

        //这张阈值图代表的是阴影在灯光从正前方移动到右后方的变化
        half4 r_ilmTex = tex2D(_SDF_Sample, float2(_FlipFrom - surfaceData.uv.x, surfaceData.uv.y)) ;

        float2 Left = normalize(TransformObjectToWorldDir(float3(1, 0, 0)).xz);	//世界空间角色正左侧方向向量
        float2 Front = normalize(TransformObjectToWorldDir(float3(0, 0, 1)).xz);	//世界空间角色正前方向向量
        float2 LightDir = normalize(light.direction.xz);
        float ctrl = 1 - clamp(0, 1, dot(Front, LightDir) * 0.5 + 0.5);//计算前向与灯光的角度差（0-1），0代表重合
        float ilm = dot(LightDir, Left) < 0 ? ilmTex.r : r_ilmTex.r;//确定采样的贴图
        //ctrl值越大代表越远离灯光，所以阴影面积会更大，光亮的部分会减少-阈值要大一点，所以ctrl=阈值
        //ctrl大于采样，说明是阴影点
        isSahdow = step(ilm, ctrl);
        float bias = smoothstep(0, _LerpMax, abs(ctrl - ilm));//平滑边界
        float diffuse = 1;
        if (ctrl > 0.99 || isSahdow == 1)
            diffuse = lerp(diffuse , diffuse * _ShadowColor.xyz ,bias);
       
        float final = saturate(light.color) * diffuse * distanceAttenuation;
        return final;
     #else

         return saturate(light.color) * lightAttenuationRGB * (isAdditionalLight ? 0.25 : 1) ;
     #endif
   
}

half3 ShadeEmissionDefaultMethod(ToonSurfaceData surfaceData, LightingData lightingData,Light light)
{
    half3 N = lightingData.finalNormal;
    half3 L = light.direction;
    half3 V = lightingData.viewDirectionWS;
    half3 H = normalize(L + V);

    
    float NoH = max(0, dot(N, H));
    half3 emissionResult = lerp(surfaceData.emission, surfaceData.emission * surfaceData.albedo, _EmissionMulByBaseColor) * pow (NoH, _SpecularIntensity); 
    // optional mul albedo
    return emissionResult;
}



half3 CompositeAllLightResultsDefaultMethod(half3 indirectResult, half3 mainLightResult, half3 additionalLightSumResult, half3 emissionResult, ToonSurfaceData surfaceData, LightingData lightingData)
{
    // [remember you can write anything here, this is just a simple tutorial method]
    // here we prevent light over bright,
    // while still want to preserve light color's hue
    half3 rawLightSum = max(indirectResult, mainLightResult + additionalLightSumResult) ; // pick the highest between indirect and direct light
    half lightLuminance = Luminance(rawLightSum);
    half3 finalLightMulResult = rawLightSum / max(1,lightLuminance / max(1,log(lightLuminance))); // allow controlled over bright using log
    return surfaceData.albedo * finalLightMulResult + emissionResult;
}



// We split lighting functions into: 
// - indirect
// - main light 
// - additional lights (point lights/spot lights)
// - emission

half3 ShadeGI(ToonSurfaceData surfaceData, LightingData lightingData)
{
    //you can switch to ShadeGIYourMethod(...) !
    return ShadeGIDefaultMethod(surfaceData, lightingData); 
}
half3 ShadeMainLight(ToonSurfaceData surfaceData, LightingData lightingData, Light light)
{
    //you can switch to ShadeMainLightYourMethod(...) !
    return ShadeSingleLightDefaultMethod(surfaceData, lightingData, light, false);
}
half3 ShadeAdditionalLight(ToonSurfaceData surfaceData, LightingData lightingData, Light light)
{
    //you can switch to ShadeAllAdditionalLightsYourMethod(...) !
    return ShadeSingleLightDefaultMethod(surfaceData, lightingData, light, true);
}
half3 ShadeEmissionNoMainLight(ToonSurfaceData surfaceData, LightingData lightingData)
{
    half3 emissionResult = lerp(surfaceData.emission, surfaceData.emission * surfaceData.albedo, _EmissionMulByBaseColor); // optional mul albedo
    return emissionResult;
}
half3 ShadeEmission(ToonSurfaceData surfaceData, LightingData lightingData,Light MainLight)
{

    #ifdef _MAIN_LIGHT_SHADOWS

    //you can switch to ShadeEmissionYourMethod(...) !
    return ShadeEmissionDefaultMethod(surfaceData, lightingData, MainLight);
    #else
    return ShadeEmissionNoMainLight(surfaceData, lightingData);
    #endif
}


half3 CompositeAllLightResults(half3 indirectResult, half3 mainLightResult, half3 additionalLightSumResult, half3 emissionResult, ToonSurfaceData surfaceData, LightingData lightingData)
{
    //you can switch to CompositeAllLightResultsYourMethod(...) !
    return CompositeAllLightResultsDefaultMethod(indirectResult,mainLightResult,additionalLightSumResult,emissionResult, surfaceData, lightingData); 
}

half3 shiftTangent(float3 T, float3 N, float shift)
{
    return normalize(T + shift * N);
}

float hairStrand(float3 T, float3 V, float3 L, float specPower,float specularWidth,float specularScale)
{
    float3 H = normalize(V + L);

    float HdotT = dot(T, H);
    float sinTH = sqrt(1 - HdotT * HdotT);
    float dirAtten = smoothstep(-specularWidth, 0, HdotT);
    
    return dirAtten * saturate(pow(sinTH, specPower)) * specularScale;
}

float4 getAmbientAndDiffuse(float4 lightColor0, float4 diffuseColor, float3 N, float3 L, float2 uv)
{
    return (lightColor0 * diffuseColor * saturate(dot(N, L)) + float4(0.2, 0.2, 0.2, 1.0));
}

float4 getSpecular(float4 lightColor0, 
       float4 primaryColor, float primaryShift,
       float4 secondaryColor, float secondaryShift,
       float3 N, float3 T, float3 V, float3 L, float specPower, float2 uv,sampler2D  specularShift,float specularScale,float specularWidth,float ShiftScale)
{
    float shiftTex = tex2D(specularShift, uv) - 0.5;

    float3 t1 = shiftTangent(T, N, primaryShift + shiftTex*(1+_ShiftScale));
    float3 t2 = shiftTangent(T, N, secondaryShift + shiftTex*(1+_ShiftScale));

    float4 specular = float4(0.0, 0.0, 0.0, 0.0);
    specular += primaryColor * hairStrand(t1, V, L, specPower,specularWidth,specularScale) * specularScale;
    specular += secondaryColor * hairStrand(t2, V, L, specPower,specularWidth,specularScale) * specularScale;

    return specular;
}

#endif
