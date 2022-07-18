Shader "imgRenkoRenderFramework/PainterVertexColor"
{

        SubShader
        {
            Tags { "RenderType" = "Transparent" "Queue"="Transparent"}
            LOD 100

            Pass
            {
              ZWrite Off
              Blend SrcAlpha OneMinusSrcAlpha
                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
              
                struct vect {
                     float4 vertex : POSITION;
                    float4 color : COLOR;
                };

                struct v2f
                {
                    float4 vertex : SV_POSITION;
                    float4 vcolor :COLOR;
                };

        
                v2f vert(vect v) 
                {
                    v2f o;
                    o.vertex = TransformObjectToHClip(v.vertex);
                    o.vcolor = v.color;
                    return o;
                }

                half4 frag(v2f i) : SV_Target
                {
                   
                    return half4(i.vcolor);
                }
                ENDHLSL
            }
        }
}