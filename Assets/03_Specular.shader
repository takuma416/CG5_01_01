Shader "Unlit/03_Specular"
{
    Properties
    {
        _Color ("Color", Color) = (1, 0, 0, 1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 eyeDir = normalize(_WorldSpaceCameraPos - i.worldPosition);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 reflectDir = reflect(-lightDir, i.worldNormal);

                float spec = pow(saturate(dot(reflectDir, eyeDir)), 20);
                fixed4 specular = spec * _LightColor0;

                return specular * _Color;
            }
            ENDCG
        }
    }
}


