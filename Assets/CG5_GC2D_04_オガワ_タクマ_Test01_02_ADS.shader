Shader "Unlit/02_ADS"
{
	Properties
	{
		_Color ("Albedo Color", Color) = (1, 1, 1, 1) 
		_AlphaValue("Alpha Value", float) = 1.0 
		_WaveScale("Wave Scale", Range(0.02, 0.15)) = 0.07
		_ReflDistort("Reflection Distort", Range(0.02, 0.15)) = 0.05
		_RefrColor("Refraction Color", Color) = (0.34, 0.85, 0.92, 1)
		_ReflectionTex("Environment Reflection", 2D) = "white" {}
		
		_Shininess ("Shininess", Range(1, 100)) = 20 
		_SpecularColor ("Specular Color", Color) = (1, 1, 1, 1) 
		
		_AmbientScale ("Ambient Light Scale", Range(0.0, 3.0)) = 1.0 
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc" 

			fixed4 _Color;
			float _AlphaValue;
			float _WaveScale; 
			float _ReflDistort; 
			fixed4 _RefrColor; 
			sampler2D _ReflectionTex; 

			float _Shininess;
			fixed4 _SpecularColor;
			
			float _AmbientScale;
			
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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				
				o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldNormal = normalize(i.worldNormal);

				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float intensity = saturate(dot(worldNormal, lightDir)); 
				
				fixed4 diffuse = _Color * intensity * _LightColor0;
				
				float3 eyeDir = normalize(_WorldSpaceCameraPos - i.worldPosition);
				float3 reflectDir = reflect(-lightDir, worldNormal);
				
				float spec = pow(saturate(dot(reflectDir, eyeDir)), _Shininess);
				
				fixed4 specular = spec * _LightColor0 * _SpecularColor;
				
				fixed4 ambient = UNITY_LIGHTMODEL_AMBIENT;
				
				fixed4 scaledAmbient = ambient * _AmbientScale;
				
				fixed4 finalColor = scaledAmbient + diffuse + specular;

				finalColor.a = _AlphaValue; 
				
				return finalColor;
			}
			ENDCG
		}
	}
}


