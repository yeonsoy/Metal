//
//  Common.h
//  MetalRenderer
//
//  Created by USER on 2022/12/22.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} Uniforms;

typedef struct {
    vector_float3 cameraPosition;
} FragmentUniforms;

typedef  struct {
    vector_float3 baseColor;
    vector_float3 specularColor;
    float shininess;
} Material;

#endif /* Common_h */
