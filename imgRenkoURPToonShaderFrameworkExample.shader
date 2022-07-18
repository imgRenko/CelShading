Shader "imgRenkoURPToonShaderFramework/imgRenkoURPToonShaderFramework(Outline)"
{
    Properties
    {
        [Header(Base Color)]
        [MainTexture]_BaseMap("_BaseMap (Albedo)", 2D) = "white" {}
        [HDR][MainColor]_BaseColor("_BaseColor", Color) = (1,1,1,1)
        [Toggle] _IsFace("_IsFace", Range(0.0, 1.0)) = 0.0
        [Header(Alpha)]
        [Toggle(_UseAlphaClipping)]_UseAlphaClipping("_UseAlphaClipping", Float) = 0
        [Toggle(_WithTextureSample)]_WithTextureSample("_WithTextureSample", Float) = 0
        _Cutoff("_Cutoff (Alpha Cutoff)", Range(0.0, 1.0)) = 0.5
        [MainTexture]_AlphaTexture("_AlphaTexture", 2D) = "white" {}
        [Header(Emission)]
        [Toggle]_UseEmission("_UseEmission (on/off Emission completely)", Float) = 0
        [HDR] _EmissionColor("_EmissionColor", Color) = (0,0,0)
        _EmissionMulByBaseColor("_EmissionMulByBaseColor", Range(0,5)) =1
        [NoScaleOffset]_EmissionMap("_EmissionMap", 2D) = "white" {}
        _EmissionMapChannelMask("_EmissionMapChannelMask", Vector) = (1,1,1,0)
        [Header(Occlusion)]
        [Toggle]_UseOcclusion("_UseOcclusion (on/off Occlusion completely)", Float) = 0
        _OcclusionStrength("_OcclusionStrength", Range(0.0, 1.0)) = 1.0
        _OcclusionIndirectStrength("_OcclusionIndirectStrength", Range(0.0, 1.0)) = 0.5
        _OcclusionDirectStrength("_OcclusionDirectStrength", Range(0.0, 1.0)) = 0.75
        [NoScaleOffset]_OcclusionMap("_OcclusionMap", 2D) = "white" {}
        _OcclusionMapChannelMask("_OcclusionMapChannelMask", Vector) = (1,0,0,0)
        _OcclusionRemapStart("_OcclusionRemapStart", Range(0,1)) = 0
        _OcclusionRemapEnd("_OcclusionRemapEnd", Range(0,1)) = 1
        [Header(Direct Lighting)]
        _IndirectLightMinColor("_IndirectLightMinColor", Color) = (0.1,0.1,0.1,1) 
        _IndirectLightMultiplier("_IndirectLightMultiplier", Range(0,1)) = 1
        _DirectLightMultiplier("_DirectLightMultiplier", Range(0,1)) = 0.25
        _CelShadeMixer("_CelShadeMixer", Range(0,1)) = 1
        _CelShadeMidPoint("_CelShadeMidPoint", Range(-1,1)) = -.5
        _MidPointMaskMultiplier("_MidPointMaskMultiplier", Range(0,2)) = 0
        _CelShadeSoftness("_CelShadeSoftness", Range(0,1)) = 0.05
        _MainLightIgnoreCelShade("_MainLightIgnoreCelShade", Range(0,1)) = 0
        _AdditionalLightIgnoreCelShade("_AdditionalLightIgnoreCelShade", Range(0,1)) = 0.9
        _ShadowRampLerp("_ShadowRampLerp", Range(0,1)) = 0
        [Header(Rim Lighting)]
        [Toggle] _UseRimLight("_UseRimLight", Range(0.0, 1.0)) = 0.0
        _FresnelMask("_FresnelMask", Range(0,1)) = 0
        _FresnelMin("_FresnelMin", Range(0,32)) = 1
        _RimColor("_RimColor", Color) = (1,1,1,1) 
         _RimScale("_RimScale", Range(0,32)) = 1
        _OffsetMul("_RimWidth", Range(0, 0.7)) = 0.012
        _Threshold("_Threshold", Range(0, 10)) = 0.09
        [Header(Normal)]
        [MainTexture]_OverrideLightNormal("_OverrideLightNormal", 2D) = "bump" {}
        _LerpBaseNormalOrOverrideNormal("_LerpBaseNormalOrOverrideNormal", Range(0,1)) = 0
        _BumpScale("_BumpScale", Range(0,5)) = 1
        _LightWithNormalHeighten("_LightWithNormalHeighten", Range(0,1)) = 0.5
        [Header(Specular)]
        
        [MainTexture]_SpeculiarMask("_SpeculiarMask", 2D) = "black" {}
        _SpecularIntensity("_SpecularIntensity", Range(0,20)) = 0.5
        _SpecularShininess("_SpecularShininess", Range(0,30)) = 0.5
        _SpecularColor("_SpecularColor", Color) = (1,1,1)
        
        [Header(Kajiya Hair Specular)]
         [Toggle(_IsHair)] _IsHair("_IsHair", Float) = 0.0
        _SpecularShift("Hair Shifted Texture", 2D) = "white" {}

        _ShiftScale("_ShiftScale", Range(0,1)) = 0
        _PrimaryColor("Specular1Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _PrimaryShift("PrimaryShift", Range(-4, 4)) = 0.0
        _SecondaryColor("Specular2Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _SecondaryShift("SecondaryShift", Range(-4, 4)) = 0.5
        
        _specPower("SpecularPower", Range(0, 1000)) = 20
        _SpecularWidth("SpecularWidth", Range(0, 1)) = 0.5
        _SpecularScale("SpecularScale", Range(0, 1)) = 0.3
        [Header(Body Shadow)]
        _ReceiveShadowMappingAmount("_ReceiveShadowMappingAmount", Range(0,1)) = 0.5
        _ReceiveShadowMappingPosOffset("_ReceiveShadowMappingPosOffset", Range(0,1)) = 0.5
        _ShadowColor("_ShadowColor",   Color) = (0,0,0,0)
        _ShadowAlpha("_ShadowAlpha",Range(0,1)) =0
        [Header(FaceShadow Toggle)]
        [Toggle(_IsFaceShadow)] _IsFaceShadow("IsFaceShadow", Float) = 0.0
        [Header(HairShadow HCM)]
        _HeightCorrectMax("HeightCorrectMax", float) = 1.6
        _HeightCorrectMin("HeightCorrectMin", float) = 1.51
        [Header(HairShadow Info)]
        _HairShadowDistace("_HairShadowDistance", Float) = 1
        _HairShadowTexPos("_HairShadowTexPos", Vector) = (0,0,0,0)
         [MainTexture]_HairShadowMask("_HairShadowMask", 2D) = "white" {}
        _BrightColor("BrightColor", Color) = (1, 1, 1, 1)
        [HDR]_MiddleColor("MiddleColor", Color) = (0.8, 0.1, 0.1, 1)
        _DarkColor("DarkColor", Color) = (0.5, 0.5, 0.5, 1)
        [Header(SDF FaceShadow)]
        [Toggle(_UseSDFFaceShadow)] _UseSDFFaceShadow("_UseSDFFaceShadow", Range(0.0, 1.0)) = 0.0
        [MainTexture]_SDF_Sample("_SDF_Sample", 2D) = "white" {}
        _LerpMax("_LerpMax", Range(0, 0.01)) = 0
         _FlipFrom("_FlipFrom", Range(0, 1)) = 1
     [Toggle(_UseSymmetrySDFFaceShadow)] _UseSymmetrySDFFaceShadow("_UseSymmetrySDFFaceShadow", Range(0.0, 1.0)) = 0.0

        [Header(Diffuse Ramp)]
        [MainTexture]_RampTexture("_RampTexture", 2D) = "white" {}
        _RampTextureMappingAmount("_RampTextureMappingAmount", Range(0,1)) = 1
        _RampTextureMappingClamp("_RampTextureMappingClamp", Range(0,1)) = 1
        _LightShadowRampColor("_LightShadowRampColor", Color) = (1,1,1,1)
        _MidstShadowRampColor("_MidstShadowRampColor", Color) = (1,1,1,1)
        _DarkShadowRampColor("_DarkShadowRampColor", Color) = (1,1,1,1)
        [Header(Outline)]
      
        _OutlineWidth("_OutlineWidth (World Space)", Range(0,4)) = 1
        _OutlinePaintedWidth("_OutlineWidth (Paint Tool Weight)", Range(0,1)) = 1

        _OutlineColor("_OutlineColor", Color) = (0.5,0.5,0.5,1)
        _OutlinePaintedColor("_OutlineColor (Paint Tool Weight)", Range(0,1)) = 1
           _OutlineOriginalSurfaceColorMixer("_OutlineOriginalSurfaceColorMixer", Range(0,1)) = 1
        _OutlineZOffset("_OutlineZOffset (View Space)", Range(0,1)) = 0.0001
         _OutlineForTangentOrNormal("_OutlineForTangentOrNormal", Range(0,1)) = 1
        [NoScaleOffset]_OutlineZOffsetMaskTex("_OutlineZOffsetMask (black is apply ZOffset)", 2D) = "black" {}
        _OutlineZOffsetMaskRemapStart("_OutlineZOffsetMaskRemapStart", Range(0,1)) = 0
        _OutlineZOffsetMaskRemapEnd("_OutlineZOffsetMaskRemapEnd", Range(0,1)) = 1

        [Header(Auto)]
        _ShadowAutoAdjustByLight("_ShadowAutoAdjustByLight", Range(0,4)) = 1
    }
    SubShader
    {       
        Tags 
        {
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="Geometry"
        }
        
        // We can extract duplicated hlsl code from all passes into this HLSLINCLUDE section. Less duplicated code = Less error
        HLSLINCLUDE
        // all Passes will need this keyword
        #pragma shader_feature_local_fragment _UseAlphaClipping
        #pragma shader_feature_local_fragment _WithTextureSample

        ENDHLSL
        

        Pass
        {               
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull Back
            ZTest LEqual
            ZWrite On
            Blend One Zero
           
            HLSLPROGRAM

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
   
            #pragma multi_compile_fog
            #pragma shader_feature _UseSDFFaceShadow

            #pragma vertex VertexShaderWork
            #pragma fragment ShadeFinalColor
            #include "imgRenkoURPToonShaderFramework_Shared.hlsl"
            

            ENDHLSL
        }
        Pass
        {
        
            Name "BaseCel"
            Tags { "LightMode" = "HairShadow" }
            Blend DstColor Zero
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
            #include "imgRenkoURPToonShaderFramework_Shared.hlsl"
        
            #pragma vertex HairVert
            #pragma fragment HairFragment
            #pragma shader_feature _IsFaceShadow

            ENDHLSL

        }
        
        Pass 
        {
            Name "Outline"
            Tags 
            {
                // IMPORTANT: don't write this line for any custom pass! else this outline pass will not be rendered by URP!
            }

            Cull Front // Cull Front is a must for extra pass outline method

            HLSLPROGRAM

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
     
            #pragma multi_compile_fog


            #pragma vertex VertexShaderWork
            #pragma fragment ShadeFinalColor

            #define ToonShaderIsOutline

            #include "imgRenkoURPToonShaderFramework_Shared.hlsl"

            ENDHLSL
        }
        Pass{
            Name "HairLight"
            Tags {"LightMode" = "HairLight"}
            Blend DstColor Zero

            HLSLPROGRAM   
            #pragma vertex kajiVert
            #pragma fragment kajiFrag
              #pragma shader_feature _IsHair
        #include "imgRenkoURPToonShaderFramework_Shared.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "RimLight"
            Tags{"LightMode" = "RimLight"}

            Cull Back
        
            ZTest LEqual
            ZWrite On
            Blend DstColor One

            HLSLPROGRAM
            
            #pragma vertex DepthVertexWork
            #pragma fragment RimLightFixed // we only need to do Clip(), no need shading
            #pragma multi_compile _ _USERIMLIGHT_ON
            // because it is a ShadowCaster pass, define "ToonShaderApplyShadowBiasFix" to inject "remove shadow mapping artifact" code into VertexShaderWork()

            // about this shader logic must be saved in the documents.
            
            // all shader logic written inside this .hlsl, remember to write all #define BEFORE writing #include
            #include "imgRenkoURPToonShaderFramework_Shared.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            // more explict render state to avoid confusion
            ZWrite On       // the only goal of this pass is to write depth!
            ZTest LEqual    // early exit at Early-Z stage if possible            
            ColorMask 0     // we don't care about color, we just want to write depth, ColorMask 0 will save some write bandwidth
            Cull Back       // support Cull[_Cull] requires "flip vertex normal" using VFACE in fragment shader, which is maybe beyond the scope of a simple tutorial shader

            HLSLPROGRAM

            #pragma vertex VertexShaderWork
            #pragma fragment BaseColorAlphaClipTest // we only need to do Clip(), no need shading

            // because it is a ShadowCaster pass, define "ToonShaderApplyShadowBiasFix" to inject "remove shadow mapping artifact" code into VertexShaderWork()
            #define ToonShaderApplyShadowBiasFix

            // all shader logic written inside this .hlsl, remember to write all #define BEFORE writing #include
            #include "imgRenkoURPToonShaderFramework_Shared.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Back

            HLSLPROGRAM

            #pragma vertex VertexShaderWork
            #pragma fragment BaseColorAlphaClipTest 
            #define ToonShaderIsOutline
            #include "imgRenkoURPToonShaderFramework_Shared.hlsl"

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
