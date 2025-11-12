Shader "Unlit/04_Texture"
{
	Properties
	{
		_MainTex ("Texture (RGB)", 2D) = "white" {}
		_Color ("Color (Tint)", Color) = (1, 1, 1, 1) 
		_AmbientColor ("Ambient Color", Color) = (0.2, 0.2, 0.2, 1)
		_SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
		_Shininess ("Shininess", Range(1, 100)) = 10
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc" 

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL; 
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD0; 
				float3 worldPos : TEXCOORD1; 
				float2 uv : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _Color;
			float4 _AmbientColor;
			float4 _SpecularColor;
			float _Shininess;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = v.uv;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 N = normalize(i.worldNormal);
				float3 P = i.worldPos;

				float3 L = normalize(_WorldSpaceLightPos0.xyz);

				float3 V = normalize(_WorldSpaceCameraPos.xyz - P);

				fixed4 texColor = tex2D(_MainTex, i.uv) * _Color;
				fixed4 finalColor;

				fixed3 ambient = _AmbientColor.rgb * texColor.rgb;

				float diff = max(0, dot(N, L));
				fixed3 diffuse = diff * _LightColor0.rgb * texColor.rgb;

				float3 R = normalize(reflect(-L, N)); 
				
				float spec = pow(max(0, dot(R, V)), _Shininess);
				fixed3 specular = spec * _LightColor0.rgb * _SpecularColor.rgb;

				finalColor.rgb = ambient + diffuse + specular;
				finalColor.a = texColor.a;

				return finalColor;
			}
			ENDCG
		}
	}
}
