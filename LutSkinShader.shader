Shader "imgRenkoURPToonShaderFramework/LutSkinRampGenerate"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            // sampler2D _MainTex;
            // float4 _MainTex_ST;
            float3 _Color;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            #define PI 3.141592654

            float3 Tonemap(float3 x)
            {
                float A = 0.15;
                float B = 0.50;
                float C = 0.10;
                float D = 0.20;
                float E = 0.02;
                float F = 0.30;
                float W = 11.2;

                return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
            }

            float3 ACESToneMapping(float3 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
            }

            float G1(float Neg_r_2, float v)
            {
                 return exp(Neg_r_2 / v);
            }


            float G2(float Neg_r_2, float v)
            {
                float v2 = 2.0 * v;
                return 1.0 / (v2 * PI * v) * exp(Neg_r_2 / v2);
            }

            #define USEG1 1

            float G(float Neg_r_2, float v)
            {
                #ifdef USEG1
                    return G1(Neg_r_2,v);
                #else 
                    return G2(Neg_r_2,v);
                #endif
            }

            float3 CalcGuss(float distance)
            {
                float Neg_r_2 = -distance * distance;
                float3 rgb = float3(0.233,0.455,0.649) * G(Neg_r_2 , 0.0064) + \
                    float3(0.100,0.336,0.344) * G(Neg_r_2 , 0.0484) + \
                    float3(0.118,0.198,0.000) * G(Neg_r_2 , 0.1870) + \
                    float3(0.113,0.007,0.007) * G(Neg_r_2 , 0.5670) + \
                    float3(0.358,0.004,0.000) * G(Neg_r_2 , 1.9900) + \
                    float3(0.078,0.000,0.000) * G(Neg_r_2 , 7.4100);
                return rgb;
            }

            float3 IntegrateDiffuseScatteringOnRing(float uvx,float Radius)
            {
                float theta = acos(uvx);
                // float theta = PI * (1 - uvx);
                float x = -PI;
                float3 totalWeights = float3(0,0,0);
                float3 totalLight = float3(0,0,0);

                while (x <= PI)
                {
                    float sampleAngle = theta + x;
                    float sampleDist = abs(2.0 * Radius * sin(x * 0.5));

                    // float diffuse = max(cos(theta + x),0);
                    float diffuse = saturate(cos(theta + x));

                    float3 weight = CalcGuss(sampleDist);
                    totalLight += weight * diffuse;
                    totalWeights += weight;
                    x += 0.001;
                }
                // float3 rgb = (totalLight/totalWeights);

                float3 rgb = ACESToneMapping(totalLight / totalWeights);

                // rgb = pow(rgb, 1/2.2);//转换到Gamma空间
                //不转换也行，读取的时候直接当作线性的就ok
                return rgb;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);

                float distance = length(i.uv - float2(0.5,0.5));

            // return float4(CalcGuss(distance),1);

            // float cuv = 1.0/(max(i.uv.y,0.0001));
            float radians = 1.0 / ((i.uv.y + 0.0001));

            float3 rgb = IntegrateDiffuseScatteringOnRing(lerp(-1,1,i.uv.x),radians);

            // rgb = pow(rgb,1/2.2);

            // float3 rgb = IntegrateDiffuseScatteringOnRing(i.uv.x,cuv);

            return float4(rgb * _Color,1);
            // return float4(lerp(_Color,float3(1,1,1),rgb),1);
            // return float4(rgb*float3(1,0,0),1);
        }
        ENDCG
    }
    }
}