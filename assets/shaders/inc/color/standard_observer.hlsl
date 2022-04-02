#ifndef NOTORIOUS6_STANDARD_OBSERVER_HLSL
#define NOTORIOUS6_STANDARD_OBSERVER_HLSL

#include "xyz.hlsl"

// https://www.site.uottawa.ca/~edubois/mdsp/data/ciexyz31.txt
#define standard_observer_1931_length 95
static const float standard_observer_1931_w_min = 360.0;
static const float standard_observer_1931_w_max = 830.0;
static const float3 standard_observer_1931[standard_observer_1931_length] = {
    float3(0.000129900000, 0.000003917000, 0.000606100000),   // 360 nm
    float3(0.000232100000, 0.000006965000, 0.001086000000),   // 365 nm
    float3(0.000414900000, 0.000012390000, 0.001946000000),   // 370 nm
    float3(0.000741600000, 0.000022020000, 0.003486000000),   // 375 nm
    float3(0.001368000000, 0.000039000000, 0.006450001000),   // 380 nm
    float3(0.002236000000, 0.000064000000, 0.010549990000),   // 385 nm
    float3(0.004243000000, 0.000120000000, 0.020050010000),   // 390 nm
    float3(0.007650000000, 0.000217000000, 0.036210000000),   // 395 nm
    float3(0.014310000000, 0.000396000000, 0.067850010000),   // 400 nm
    float3(0.023190000000, 0.000640000000, 0.110200000000),   // 405 nm
    float3(0.043510000000, 0.001210000000, 0.207400000000),   // 410 nm
    float3(0.077630000000, 0.002180000000, 0.371300000000),   // 415 nm
    float3(0.134380000000, 0.004000000000, 0.645600000000),   // 420 nm
    float3(0.214770000000, 0.007300000000, 1.039050100000),   // 425 nm
    float3(0.283900000000, 0.011600000000, 1.385600000000),   // 430 nm
    float3(0.328500000000, 0.016840000000, 1.622960000000),   // 435 nm
    float3(0.348280000000, 0.023000000000, 1.747060000000),   // 440 nm
    float3(0.348060000000, 0.029800000000, 1.782600000000),   // 445 nm
    float3(0.336200000000, 0.038000000000, 1.772110000000),   // 450 nm
    float3(0.318700000000, 0.048000000000, 1.744100000000),   // 455 nm
    float3(0.290800000000, 0.060000000000, 1.669200000000),   // 460 nm
    float3(0.251100000000, 0.073900000000, 1.528100000000),   // 465 nm
    float3(0.195360000000, 0.090980000000, 1.287640000000),   // 470 nm
    float3(0.142100000000, 0.112600000000, 1.041900000000),   // 475 nm
    float3(0.095640000000, 0.139020000000, 0.812950100000),   // 480 nm
    float3(0.057950010000, 0.169300000000, 0.616200000000),   // 485 nm
    float3(0.032010000000, 0.208020000000, 0.465180000000),   // 490 nm
    float3(0.014700000000, 0.258600000000, 0.353300000000),   // 495 nm
    float3(0.004900000000, 0.323000000000, 0.272000000000),   // 500 nm
    float3(0.002400000000, 0.407300000000, 0.212300000000),   // 505 nm
    float3(0.009300000000, 0.503000000000, 0.158200000000),   // 510 nm
    float3(0.029100000000, 0.608200000000, 0.111700000000),   // 515 nm
    float3(0.063270000000, 0.710000000000, 0.078249990000),   // 520 nm
    float3(0.109600000000, 0.793200000000, 0.057250010000),   // 525 nm
    float3(0.165500000000, 0.862000000000, 0.042160000000),   // 530 nm
    float3(0.225749900000, 0.914850100000, 0.029840000000),   // 535 nm
    float3(0.290400000000, 0.954000000000, 0.020300000000),   // 540 nm
    float3(0.359700000000, 0.980300000000, 0.013400000000),   // 545 nm
    float3(0.433449900000, 0.994950100000, 0.008749999000),   // 550 nm
    float3(0.512050100000, 1.000000000000, 0.005749999000),   // 555 nm
    float3(0.594500000000, 0.995000000000, 0.003900000000),   // 560 nm
    float3(0.678400000000, 0.978600000000, 0.002749999000),   // 565 nm
    float3(0.762100000000, 0.952000000000, 0.002100000000),   // 570 nm
    float3(0.842500000000, 0.915400000000, 0.001800000000),   // 575 nm
    float3(0.916300000000, 0.870000000000, 0.001650001000),   // 580 nm
    float3(0.978600000000, 0.816300000000, 0.001400000000),   // 585 nm
    float3(1.026300000000, 0.757000000000, 0.001100000000),   // 590 nm
    float3(1.056700000000, 0.694900000000, 0.001000000000),   // 595 nm
    float3(1.062200000000, 0.631000000000, 0.000800000000),   // 600 nm
    float3(1.045600000000, 0.566800000000, 0.000600000000),   // 605 nm
    float3(1.002600000000, 0.503000000000, 0.000340000000),   // 610 nm
    float3(0.938400000000, 0.441200000000, 0.000240000000),   // 615 nm
    float3(0.854449900000, 0.381000000000, 0.000190000000),   // 620 nm
    float3(0.751400000000, 0.321000000000, 0.000100000000),   // 625 nm
    float3(0.642400000000, 0.265000000000, 0.000049999990),   // 630 nm
    float3(0.541900000000, 0.217000000000, 0.000030000000),   // 635 nm
    float3(0.447900000000, 0.175000000000, 0.000020000000),   // 640 nm
    float3(0.360800000000, 0.138200000000, 0.000010000000),   // 645 nm
    float3(0.283500000000, 0.107000000000, 0.000000000000),   // 650 nm
    float3(0.218700000000, 0.081600000000, 0.000000000000),   // 655 nm
    float3(0.164900000000, 0.061000000000, 0.000000000000),   // 660 nm
    float3(0.121200000000, 0.044580000000, 0.000000000000),   // 665 nm
    float3(0.087400000000, 0.032000000000, 0.000000000000),   // 670 nm
    float3(0.063600000000, 0.023200000000, 0.000000000000),   // 675 nm
    float3(0.046770000000, 0.017000000000, 0.000000000000),   // 680 nm
    float3(0.032900000000, 0.011920000000, 0.000000000000),   // 685 nm
    float3(0.022700000000, 0.008210000000, 0.000000000000),   // 690 nm
    float3(0.015840000000, 0.005723000000, 0.000000000000),   // 695 nm
    float3(0.011359160000, 0.004102000000, 0.000000000000),   // 700 nm
    float3(0.008110916000, 0.002929000000, 0.000000000000),   // 705 nm
    float3(0.005790346000, 0.002091000000, 0.000000000000),   // 710 nm
    float3(0.004106457000, 0.001484000000, 0.000000000000),   // 715 nm
    float3(0.002899327000, 0.001047000000, 0.000000000000),   // 720 nm
    float3(0.002049190000, 0.000740000000, 0.000000000000),   // 725 nm
    float3(0.001439971000, 0.000520000000, 0.000000000000),   // 730 nm
    float3(0.000999949300, 0.000361100000, 0.000000000000),   // 735 nm
    float3(0.000690078600, 0.000249200000, 0.000000000000),   // 740 nm
    float3(0.000476021300, 0.000171900000, 0.000000000000),   // 745 nm
    float3(0.000332301100, 0.000120000000, 0.000000000000),   // 750 nm
    float3(0.000234826100, 0.000084800000, 0.000000000000),   // 755 nm
    float3(0.000166150500, 0.000060000000, 0.000000000000),   // 760 nm
    float3(0.000117413000, 0.000042400000, 0.000000000000),   // 765 nm
    float3(0.000083075270, 0.000030000000, 0.000000000000),   // 770 nm
    float3(0.000058706520, 0.000021200000, 0.000000000000),   // 775 nm
    float3(0.000041509940, 0.000014990000, 0.000000000000),   // 780 nm
    float3(0.000029353260, 0.000010600000, 0.000000000000),   // 785 nm
    float3(0.000020673830, 0.000007465700, 0.000000000000),   // 790 nm
    float3(0.000014559770, 0.000005257800, 0.000000000000),   // 795 nm
    float3(0.000010253980, 0.000003702900, 0.000000000000),   // 800 nm
    float3(0.000007221456, 0.000002607800, 0.000000000000),   // 805 nm
    float3(0.000005085868, 0.000001836600, 0.000000000000),   // 810 nm
    float3(0.000003581652, 0.000001293400, 0.000000000000),   // 815 nm
    float3(0.000002522525, 0.000000910930, 0.000000000000),   // 820 nm
    float3(0.000001776509, 0.000000641530, 0.000000000000),   // 825 nm
    float3(0.000001251141, 0.000000451810, 0.000000000000)   // 830 nm
};

// From Paul Malin (https://www.shadertoy.com/view/MstcD7)
// Modified to output xyY as XYZ can be misleading
// (does not interpolate linearly in chromaticity space)
float3 wavelength_to_xyY(float wavelength) {
    float pos = (wavelength - standard_observer_1931_w_min) / (standard_observer_1931_w_max - standard_observer_1931_w_min);
    float index = pos * float(standard_observer_1931_length - 1); // -1 is a change from Paul's version.
    float floor_index = floor(index);
    float blend = clamp(index - floor_index, 0.0, 1.0);
    int index0 = int(floor_index);
    int index1 = index0 + 1;
    index1 = min(index1, standard_observer_1931_length - 1);
    return lerp(CIE_XYZ_to_xyY(standard_observer_1931[index0]), CIE_XYZ_to_xyY(standard_observer_1931[index1]), blend);
}

// Returns a lerp factor over p2 and p3 or -1 on miss
float intersect_line_segment_2d(float2 p0, float2 dir, float2 p2, float2 p3) {
    float2 P = p2;
    float2 R = p3 - p2;  
    float2 Q = p0;
    float2 S = dir;

    float2 N = float2(S.y, -S.x);
    float t = dot(Q-P, N) / dot(R, N);

    if (t == clamp(t, 0.0, 1.0) && dot(dir, p2 - p0) >= 0.0) {
        return t;
    } else {
        return -1.0;
    }
}

// Returns -1 for non-spectrals
float CIE_xy_to_dominant_wavelength(float2 xy) {
    float2 white = white_D65_xy;
    float2 dir = xy - white;

    for (int i = 0; i + 1 < standard_observer_1931_length; ++i) {
        float2 locus_xy0 = CIE_XYZ_to_xyY(standard_observer_1931[i]).xy;
        float2 locus_xy1 = CIE_XYZ_to_xyY(standard_observer_1931[i + 1]).xy;

        float hit = intersect_line_segment_2d(white, dir, locus_xy0, locus_xy1);
        if (hit != -1.0) {
            return standard_observer_1931_w_min
                + (standard_observer_1931_w_max - standard_observer_1931_w_min) / float(standard_observer_1931_length - 1)
                * (float(i) + hit);
        }
    }

    return -1.0;
}

#endif  // NOTORIOUS6_STANDARD_OBSERVER_HLSL