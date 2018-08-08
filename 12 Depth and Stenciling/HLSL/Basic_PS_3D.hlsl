#include "Basic.fx"

// ������ɫ��(3D)
float4 PS_3D(VertexOut pIn) : SV_Target
{
	// ��ǰ���вü����Բ�����Ҫ������ؿ��Ա����������
    float4 texColor = tex.Sample(samLinear, pIn.Tex);
    clip(texColor.a - 0.1f);

    // ��׼��������
    pIn.NormalW = normalize(pIn.NormalW);

    // ����ָ���۾�������
    float3 toEyeW = normalize(gEyePosW - pIn.PosW);

    // ��ʼ��Ϊ0 
    float4 ambient = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 diffuse = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 spec = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 A = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 D = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 S = float4(0.0f, 0.0f, 0.0f, 0.0f);
    int i;


	// ǿ��չ��ѭ���Լ���ָ����
	[unroll]
    for (i = 0; i < gNumDirLight; ++i)
    {
        ComputeDirectionalLight(gMaterial, gDirLight[i], pIn.NormalW, toEyeW, A, D, S);
        ambient += A;
        diffuse += D;
        spec += S;
    }
    
	[unroll]
    for (i = 0; i < gNumPointLight; ++i)
    {
        PointLight pointLight = gPointLight[i];
        // ����ǰ�ڻ��Ʒ������壬��Ҫ�Թ��ս��з������任
        [flatten]
        if (gIsReflection)
        {
            pointLight.Position = (float3) mul(float4(pointLight.Position, 1.0f), gReflection);
        }

        ComputePointLight(gMaterial, pointLight, pIn.PosW, pIn.NormalW, toEyeW, A, D, S);
        ambient += A;
        diffuse += D;
        spec += S;
    }
    
	[unroll]
    for (i = 0; i < gNumSpotLight; ++i)
    {
        SpotLight spotLight = gSpotLight[i];
        // ����ǰ�ڻ��Ʒ������壬��Ҫ�Թ��ս��з������任
        [flatten]
        if (gIsReflection)
        {
            spotLight.Position = (float3) mul(float4(spotLight.Position, 1.0f), gReflection);
        }

        ComputeSpotLight(gMaterial, spotLight, pIn.PosW, pIn.NormalW, toEyeW, A, D, S);
        ambient += A;
        diffuse += D;
        spec += S;
    }
    

	
    float4 litColor = texColor * (ambient + diffuse) + spec;
    litColor.a = texColor.a * gMaterial.Diffuse.a;
    return litColor;
}