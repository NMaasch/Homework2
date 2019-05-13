Shader "Outlined/Uniform"
{
	Properties
	{
		_Color("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Texture", 2D) = "white" {}
        _EmissiveColor( "Emissision Color",Color) = (1,1,1,1)
        _Emission("Emission", Range(0,10)) = 10
		_OutlineColor ("Outline color", Color) = (0,0,0,1)
		_OutlineWidth ("Outlines width", Range (0.0, 2.0)) = 1.1
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
	};

	struct v2f
	{
		float4 pos : POSITION;
	};

	uniform float _OutlineWidth;
	uniform float4 _OutlineColor;
	uniform sampler2D _MainTex;
	uniform float4 _Color;
    uniform float4 _EmissiveColor;
    uniform float _Emission;
	ENDCG

	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" }

		Pass //Outline
		{
			ZWrite Off
			Cull Back
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			v2f vert(appdata v)
			{
				appdata original = v;
				v.vertex.xyz += _OutlineWidth * normalize(v.vertex.xyz);

				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;

			}

			half4 frag(v2f i) : COLOR
			{
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				return float4(_Emission * _EmissiveColor + ambient, 1.0)*_OutlineColor;
			}

			ENDCG
		}

		Tags{ "Queue" = "Geometry"}

		CGPROGRAM
		#pragma surface surf Lambert
		 
		struct Input {
			float2 uv_MainTex;
		};
		 
		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	Fallback "Diffuse"
}