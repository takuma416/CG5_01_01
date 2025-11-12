Shader "Unlit/02_ADS"
{
	Properties
	{
		// 01_Simple からの統合プロパティ
		_Color ("Albedo Color", Color) = (1, 1, 1, 1) // 基本色として使用
		_AlphaValue("Alpha Value", float) = 1.0 // 今後の透明度設定のために残す
		_WaveScale("Wave Scale", Range(0.02, 0.15)) = 0.07
		_ReflDistort("Reflection Distort", Range(0.02, 0.15)) = 0.05
		_RefrColor("Refraction Color", Color) = (0.34, 0.85, 0.92, 1)
		_ReflectionTex("Environment Reflection", 2D) = "white" {}
		
		// 鏡面反射のためのパラメータ (03_Specular の強化)
		_Shininess ("Shininess", Range(1, 100)) = 20 // スペキュラの強さ/鋭さ
		_SpecularColor ("Specular Color", Color) = (1, 1, 1, 1) // スペキュラの色

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
			#include "Lighting.cginc" // LambertとSpecularのために必須

			// プロパティ変数の宣言
			fixed4 _Color;
			float _AlphaValue;
			float _WaveScale; // 現状未使用だが定義
			float _ReflDistort; // 現状未使用だが定義
			fixed4 _RefrColor; // 現状未使用だが定義
			sampler2D _ReflectionTex; // 現状未使用だが定義

			// 鏡面反射のための追加パラメータ
			float _Shininess;
			fixed4 _SpecularColor;
			
			// 02_Lambert, 03_Specular から統合したデータ構造
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldPosition : TEXCOORD0; // 視線計算に必要
				float3 worldNormal : TEXCOORD1; // ライティング計算に必要
			};

			// 03_Specular をベースに、必要な情報をすべて渡す Vertex Shader
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				
				// ワールド座標の計算 (03_Specular)
				o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				// ワールド法線の計算 (02_Lambert, 03_Specular)
				o.worldNormal = UnityObjectToWorldNormal(v.normal); // より一般的な関数を使用
				
				return o;
			}
			
			// すべてのライティングを合成する Fragment Shader
			fixed4 frag (v2f i) : SV_Target
			{
				// 法線を正規化 (補間後の法線は長さが変わる可能性があるため)
				float3 worldNormal = normalize(i.worldNormal);

				// ----------------------
				// 1. ディフューズ（拡散反射）計算 (02_Lambert のロジック)
				// ----------------------
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz); // メインライトの方向
				float intensity = saturate(dot(worldNormal, lightDir)); // N・L の内積
				
				// ディフューズ色 = 基本色 * 光の強さ * ライトの色
				fixed4 diffuse = _Color * intensity * _LightColor0;
				
				// ----------------------
				// 2. スペキュラ（鏡面反射）計算 (03_Specular のロジック)
				// ----------------------
				float3 eyeDir = normalize(_WorldSpaceCameraPos - i.worldPosition); // 視線の方向
				float3 reflectDir = reflect(-lightDir, worldNormal); // 反射方向
				
				// スペキュラ値 = (R・V)^Shininess
				float spec = pow(saturate(dot(reflectDir, eyeDir)), _Shininess);
				
				// スペキュラ色 = スペキュラ値 * ライトの色 * スペキュラの色
				fixed4 specular = spec * _LightColor0 * _SpecularColor;
				
				// ----------------------
				// 3. 最終色の合成
				// ----------------------
				// 環境光 (Ambient) + ディフューズ + スペキュラ で最終色を構成
				// Unityの標準的なAmbient Lightも追加して、暗い部分も完全に黒にならないようにします
				fixed4 ambient = UNITY_LIGHTMODEL_AMBIENT;
				
				fixed4 finalColor = ambient + diffuse + specular;

				// 01_Simple の AlphaValue を最終アルファに適用
				finalColor.a = _AlphaValue; 
				
				return finalColor;
			}
			ENDCG
		}
	}
}


