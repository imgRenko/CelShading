Shader "imgRenkoURPToonShaderFramework/PostProcessing/FlatImage"
{    Properties
    {
        [HideInInspector] _MainTex("Albedo (RGB)", 2D) = "white" {}
        _brightness("Brightness", Range(0,1)) = 0.5
        _saturate("Saturate", Range(0,1)) = 0.0
        _contranst("Constrast", Range(-1,2)) = 0.0
        _target("Target", Vector) = (-1,1,1,1)
   _center("Center", Vector) = (0.5,0.5,1,1)
        _color1("Color 1", Color) = (1,1,1,1)
        _color2("Color 2", Color) = (1,1,1,1)
        _lerpAmouth("Lerp Amouth", Range(-1,1)) = 1
         _lerpAlpha("Lerp Alpha", Range(0,1)) = 1
        _SmoothStep("_Smooth Step", Range(0,4)) = 1
}
SubShader
        {
            Tags
            {
                "RenderPipeline" = "UniversalRenderPipeline"
            }
           
            pass
            {
                Cull Off
                ZWrite Off
                ZTest Always

                HLSLPROGRAM
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                CBUFFER_START(UnityPerMaterial)
                float _brightness;
                float _saturate;
                float _contranst;
                float4 _color1;
                float4 _color2;
                float _lerpAmouth;
                float _lerpAlpha;
                float2 _target;
                float2 _center;

                float _SmoothStep;

                CBUFFER_END
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
                struct a2v {
                    float4 positionOS:POSITION;
                    float2 texcoord:TEXCOORD;
                };
                struct v2f
                {
                    float4 positionCS:SV_POSITION;
                    float2 texcoord:TEXCOORD;
                };
                #pragma vertex Vert
                #pragma fragment Frag
                float getPointLineDist (float2 p,float2 lp,float2 ln){
                    float dist;
                    float2 p2p = p - lp;
                    dist = length (dot(p,ln) * ln/length(ln) -p2p);
                    return dist;
                }

                v2f Vert(a2v i)
                {
                    v2f o;
                    o.positionCS = TransformObjectToHClip(i.positionOS.xyz);
                    o.texcoord = i.texcoord;
                    return o;
                }
                float4 Frag(v2f i) :SV_TARGET
                {
                    float4 tex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.texcoord);
                    float gray = 0.21 * tex.x + 0.72 * tex.y + 0.072 * tex.z;
                    tex.xyz *= _brightness;
                    tex.xyz = lerp(float3(gray,gray,gray), tex.xyz, _saturate);
                    tex.xyz = lerp(float3(0.5,0.5,0.5), tex.xyz, _contranst);

                    float2 p = i.texcoord;
                    float2 lp = _center;
                    float2 ln = _target;
                    float pld = getPointLineDist (p,lp,ln);
                    float max_pld = getPointLineDist(float2(0,0), lp, ln);
                    float dp = pld / max_pld * _lerpAmouth;
                   // float2 rotated_normal = normalize(_rotated);
                    float4 lerptex = lerp(_color1, _color2, dp) * _lerpAlpha;
                   

                    float4 rotatedTex= lerptex;
                       // 1 - ((1 - tex) * (1 - lerptex * (1.5-i.texcoord.y) * _lerpAlpha));
                    float4 PicA = tex;
                    float4 PicB = rotatedTex;
                    float4 A  = PicA *(PicB + 0.5);
                    float4 B =1- ((1- PicA)*(1-(PicB - 0.5)));
                    
                    return lerp(A,B,step(0.5, PicB));//tex + lerptex;
                }
                ENDHLSL
            }

        
        }
       
}