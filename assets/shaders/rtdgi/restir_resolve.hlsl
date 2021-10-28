#include "../inc/color.hlsl"
#include "../inc/samplers.hlsl"
#include "../inc/frame_constants.hlsl"
#include "../inc/pack_unpack.hlsl"
#include "../inc/brdf.hlsl"
#include "../inc/brdf_lut.hlsl"
#include "../inc/layered_brdf.hlsl"
#include "../inc/uv.hlsl"
#include "../inc/hash.hlsl"
#include "../inc/reservoir.hlsl"
#include "restir_settings.hlsl"

[[vk::binding(0)]] Texture2D<float4> irradiance_tex;
[[vk::binding(1)]] Texture2D<float4> hit_normal_tex;
[[vk::binding(2)]] Texture2D<float4> ray_tex;
[[vk::binding(3)]] Texture2D<float4> reservoir_input_tex;
[[vk::binding(4)]] Texture2D<float4> gbuffer_tex;
[[vk::binding(5)]] Texture2D<float4> half_view_normal_tex;
[[vk::binding(6)]] Texture2D<float> half_depth_tex;
[[vk::binding(7)]] Texture2D<float4> ssao_tex;
[[vk::binding(8)]] RWTexture2D<float4> irradiance_output_tex;
[[vk::binding(9)]] cbuffer _ {
    float4 gbuffer_tex_size;
    float4 output_tex_size;
};

uint2 reservoir_payload_to_px(uint payload) {
    return uint2(payload & 0xffff, payload >> 16);
}

[numthreads(8, 8, 1)]
void main(uint2 px : SV_DispatchThreadID) {
    const uint2 hi_px_subpixels[4] = {
        uint2(0, 0),
        uint2(1, 1),
        uint2(1, 0),
        uint2(0, 1),
    };
    const uint2 hi_px = px * 2 + hi_px_subpixels[frame_constants.frame_index & 3];
    float depth = half_depth_tex[px];

    const uint seed = frame_constants.frame_index;
    uint rng = hash3(uint3(px, seed));

    const float2 uv = get_uv(hi_px, gbuffer_tex_size);
    const ViewRayContext view_ray_context = ViewRayContext::from_uv_and_depth(uv, depth);

    const float3 center_normal_vs = half_view_normal_tex[px].rgb;
    const float3 center_normal_ws = direction_view_to_world(center_normal_vs);
    const float center_depth = half_depth_tex[px];
    const float center_ssao = ssao_tex[px * 2].r;

    float3 irradiance_sum = 0;
    float w_sum = 0;

    const int2 reservoir_offsets[5] = {
        int2(0, 0),
        int2(1, 0),
        int2(-1, 0),
        int2(0, 1),
        int2(0, -1),
    };

    for (uint sample_i = 0; sample_i < 1; ++sample_i) {
        const int2 reservoir_px_offset = reservoir_offsets[sample_i] * 2;
        const int2 rpx = px + reservoir_px_offset;

        Reservoir1spp r = Reservoir1spp::from_raw(reservoir_input_tex[rpx]);
        const uint2 spx = reservoir_payload_to_px(r.payload);

        const float3 hit_ws = ray_tex[spx].xyz;
        const float3 sample_dir = normalize(hit_ws - view_ray_context.ray_hit_ws());

        float3 radiance = irradiance_tex[spx].rgb;
        float w = max(0.0, dot(center_normal_ws, sample_dir));
        //w *= w * w * w;
        //w = pow(w, 5);

        irradiance_sum += radiance * r.W * w;
        w_sum += w;
    }

    irradiance_sum /= max(1e-20, w_sum);

    irradiance_output_tex[px] = float4(irradiance_sum, 1);
}