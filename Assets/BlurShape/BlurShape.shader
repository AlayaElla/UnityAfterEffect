Shader "Custom/BlurShape" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurSize ("Blur Size", Float) = 1.0
		_ScopeTexture("Base (RGB)", 2D) = "white" {}
		_OriginTexture("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		CGINCLUDE
		
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;  
		half4 _MainTex_TexelSize;
		float _BlurSize;
		sampler2D _ScopeTexture;
		half4 _ScopeTexture_TexelSize;
		sampler2D _OriginTexture;
		half4 _OriginTexture_TexelSize;
		  
		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv[5]: TEXCOORD0;
		};
		  
		v2f vertBlurVertical(appdata_img v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			
			half2 uv = v.texcoord;
			
			o.uv[0] = uv;
			o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
			o.uv[2] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
			o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
			o.uv[4] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
					 
			return o;
		}
		
		v2f vertBlurHorizontal(appdata_img v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);	
			half2 uv = v.texcoord;	
			o.uv[0] = uv;
			o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
			o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
			o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
			o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;		 
			return o;
		}	

		fixed4 fragBlur(v2f i) : SV_Target {
			float weight[3] = {0.4026, 0.2442, 0.0545};
			fixed3 blur = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
			
			for (int it = 1; it < 3; it++) {
				blur += tex2D(_MainTex, i.uv[it*2-1]).rgb * weight[it];
				blur += tex2D(_MainTex, i.uv[it*2]).rgb * weight[it];
			}
			return fixed4(blur, 1.0);
		}

		fixed4 fragFinal(v2f i) : SV_Target{
			fixed3 Blurcolor = tex2D(_MainTex, i.uv[0]);
			fixed4 mask = tex2D(_ScopeTexture, i.uv[0]);
			fixed3 Origincolor = tex2D(_OriginTexture, i.uv[0]);
			fixed3 finalColor = lerp(Origincolor, Blurcolor, mask.a);
			return fixed4(finalColor, 1.0);
		}	    
		ENDCG	

		ZTest Always Cull Off ZWrite Off		

		Pass {			
			CGPROGRAM		  
			#pragma vertex vertBlurVertical  
			#pragma fragment fragBlur			  
			ENDCG  
		}
		
		Pass {  			
			CGPROGRAM  	
			#pragma vertex vertBlurHorizontal  
			#pragma fragment fragBlur	
			ENDCG
		}

		Pass {
				CGPROGRAM
				#pragma vertex vert_img  
				#pragma fragment fragFinal
				ENDCG
		}
	} 
	FallBack "Diffuse"
}
