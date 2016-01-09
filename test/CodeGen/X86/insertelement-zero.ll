; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+sse3 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+ssse3 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+sse4.1 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE41
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+avx | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX2

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-unknown"

define <2 x double> @insert_v2f64_z1(<2 x double> %a) {
; SSE-LABEL: insert_v2f64_z1:
; SSE:       # BB#0:
; SSE-NEXT:    xorpd %xmm1, %xmm1
; SSE-NEXT:    movsd {{.*#+}} xmm0 = xmm1[0],xmm0[1]
; SSE-NEXT:    retq
;
; AVX-LABEL: insert_v2f64_z1:
; AVX:       # BB#0:
; AVX-NEXT:    vxorpd %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vmovsd {{.*#+}} xmm0 = xmm1[0],xmm0[1]
; AVX-NEXT:    retq
  %1 = insertelement <2 x double> %a, double 0.0, i32 0
  ret <2 x double> %1
}

define <4 x double> @insert_v4f64_0zz3(<4 x double> %a) {
; SSE-LABEL: insert_v4f64_0zz3:
; SSE:       # BB#0:
; SSE-NEXT:    xorpd %xmm2, %xmm2
; SSE-NEXT:    unpcklpd {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; SSE-NEXT:    movsd {{.*#+}} xmm1 = xmm2[0],xmm1[1]
; SSE-NEXT:    retq
;
; AVX-LABEL: insert_v4f64_0zz3:
; AVX:       # BB#0:
; AVX-NEXT:    vxorpd %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vunpcklpd {{.*#+}} xmm2 = xmm0[0],xmm1[0]
; AVX-NEXT:    vblendpd {{.*#+}} ymm0 = ymm2[0,1],ymm0[2,3]
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX-NEXT:    vmovsd {{.*#+}} xmm1 = xmm1[0],xmm2[1]
; AVX-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX-NEXT:    retq
  %1 = insertelement <4 x double> %a, double 0.0, i32 1
  %2 = insertelement <4 x double> %1, double 0.0, i32 2
  ret <4 x double> %2
}

define <2 x i64> @insert_v2i64_z1(<2 x i64> %a) {
; SSE2-LABEL: insert_v2i64_z1:
; SSE2:       # BB#0:
; SSE2-NEXT:    xorpd %xmm1, %xmm1
; SSE2-NEXT:    movsd {{.*#+}} xmm0 = xmm1[0],xmm0[1]
; SSE2-NEXT:    retq
;
; SSE3-LABEL: insert_v2i64_z1:
; SSE3:       # BB#0:
; SSE3-NEXT:    xorpd %xmm1, %xmm1
; SSE3-NEXT:    movsd {{.*#+}} xmm0 = xmm1[0],xmm0[1]
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: insert_v2i64_z1:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    xorpd %xmm1, %xmm1
; SSSE3-NEXT:    movsd {{.*#+}} xmm0 = xmm1[0],xmm0[1]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: insert_v2i64_z1:
; SSE41:       # BB#0:
; SSE41-NEXT:    xorl %eax, %eax
; SSE41-NEXT:    pinsrq $0, %rax, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: insert_v2i64_z1:
; AVX:       # BB#0:
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vpinsrq $0, %rax, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = insertelement <2 x i64> %a, i64 0, i32 0
  ret <2 x i64> %1
}

define <4 x i64> @insert_v4i64_01z3(<4 x i64> %a) {
; SSE2-LABEL: insert_v4i64_01z3:
; SSE2:       # BB#0:
; SSE2-NEXT:    xorpd %xmm2, %xmm2
; SSE2-NEXT:    movsd {{.*#+}} xmm1 = xmm2[0],xmm1[1]
; SSE2-NEXT:    retq
;
; SSE3-LABEL: insert_v4i64_01z3:
; SSE3:       # BB#0:
; SSE3-NEXT:    xorpd %xmm2, %xmm2
; SSE3-NEXT:    movsd {{.*#+}} xmm1 = xmm2[0],xmm1[1]
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: insert_v4i64_01z3:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    xorpd %xmm2, %xmm2
; SSSE3-NEXT:    movsd {{.*#+}} xmm1 = xmm2[0],xmm1[1]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: insert_v4i64_01z3:
; SSE41:       # BB#0:
; SSE41-NEXT:    xorl %eax, %eax
; SSE41-NEXT:    pinsrq $0, %rax, %xmm1
; SSE41-NEXT:    retq
;
; AVX1-LABEL: insert_v4i64_01z3:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    xorl %eax, %eax
; AVX1-NEXT:    vpinsrq $0, %rax, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: insert_v4i64_01z3:
; AVX2:       # BB#0:
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    xorl %eax, %eax
; AVX2-NEXT:    vpinsrq $0, %rax, %xmm1, %xmm1
; AVX2-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %1 = insertelement <4 x i64> %a, i64 0, i32 2
  ret <4 x i64> %1
}

define <4 x float> @insert_v4f32_01z3(<4 x float> %a) {
; SSE2-LABEL: insert_v4f32_01z3:
; SSE2:       # BB#0:
; SSE2-NEXT:    xorps %xmm1, %xmm1
; SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,0],xmm0[3,0]
; SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[0,2]
; SSE2-NEXT:    retq
;
; SSE3-LABEL: insert_v4f32_01z3:
; SSE3:       # BB#0:
; SSE3-NEXT:    xorps %xmm1, %xmm1
; SSE3-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,0],xmm0[3,0]
; SSE3-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[0,2]
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: insert_v4f32_01z3:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    xorps %xmm1, %xmm1
; SSSE3-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,0],xmm0[3,0]
; SSSE3-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[0,2]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: insert_v4f32_01z3:
; SSE41:       # BB#0:
; SSE41-NEXT:    xorps %xmm1, %xmm1
; SSE41-NEXT:    insertps {{.*#+}} xmm0 = xmm0[0,1],xmm1[0],xmm0[3]
; SSE41-NEXT:    retq
;
; AVX-LABEL: insert_v4f32_01z3:
; AVX:       # BB#0:
; AVX-NEXT:    vxorps %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1],xmm1[0],xmm0[3]
; AVX-NEXT:    retq
  %1 = insertelement <4 x float> %a, float 0.0, i32 2
  ret <4 x float> %1
}

define <8 x float> @insert_v8f32_z12345z7(<8 x float> %a) {
; SSE2-LABEL: insert_v8f32_z12345z7:
; SSE2:       # BB#0:
; SSE2-NEXT:    xorps %xmm2, %xmm2
; SSE2-NEXT:    movss {{.*#+}} xmm0 = xmm2[0],xmm0[1,2,3]
; SSE2-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,0],xmm1[3,0]
; SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,1],xmm2[0,2]
; SSE2-NEXT:    retq
;
; SSE3-LABEL: insert_v8f32_z12345z7:
; SSE3:       # BB#0:
; SSE3-NEXT:    xorps %xmm2, %xmm2
; SSE3-NEXT:    movss {{.*#+}} xmm0 = xmm2[0],xmm0[1,2,3]
; SSE3-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,0],xmm1[3,0]
; SSE3-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,1],xmm2[0,2]
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: insert_v8f32_z12345z7:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    xorps %xmm2, %xmm2
; SSSE3-NEXT:    movss {{.*#+}} xmm0 = xmm2[0],xmm0[1,2,3]
; SSSE3-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,0],xmm1[3,0]
; SSSE3-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,1],xmm2[0,2]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: insert_v8f32_z12345z7:
; SSE41:       # BB#0:
; SSE41-NEXT:    xorps %xmm2, %xmm2
; SSE41-NEXT:    blendps {{.*#+}} xmm0 = xmm2[0],xmm0[1,2,3]
; SSE41-NEXT:    insertps {{.*#+}} xmm1 = xmm1[0,1],xmm2[0],xmm1[3]
; SSE41-NEXT:    retq
;
; AVX-LABEL: insert_v8f32_z12345z7:
; AVX:       # BB#0:
; AVX-NEXT:    vxorps %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0],ymm0[1,2,3,4,5,6,7]
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX-NEXT:    vinsertps {{.*#+}} xmm1 = xmm2[0,1],xmm1[0],xmm2[3]
; AVX-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX-NEXT:    retq
  %1 = insertelement <8 x float> %a, float 0.0, i32 0
  %2 = insertelement <8 x float> %1, float 0.0, i32 6
  ret <8 x float> %2
}

define <4 x i32> @insert_v4i32_01z3(<4 x i32> %a) {
; SSE2-LABEL: insert_v4i32_01z3:
; SSE2:       # BB#0:
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    movd %eax, %xmm1
; SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,0],xmm0[3,0]
; SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[0,2]
; SSE2-NEXT:    retq
;
; SSE3-LABEL: insert_v4i32_01z3:
; SSE3:       # BB#0:
; SSE3-NEXT:    xorl %eax, %eax
; SSE3-NEXT:    movd %eax, %xmm1
; SSE3-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,0],xmm0[3,0]
; SSE3-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[0,2]
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: insert_v4i32_01z3:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    xorl %eax, %eax
; SSSE3-NEXT:    movd %eax, %xmm1
; SSSE3-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,0],xmm0[3,0]
; SSSE3-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[0,2]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: insert_v4i32_01z3:
; SSE41:       # BB#0:
; SSE41-NEXT:    xorl %eax, %eax
; SSE41-NEXT:    pinsrd $2, %eax, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: insert_v4i32_01z3:
; AVX:       # BB#0:
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vpinsrd $2, %eax, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = insertelement <4 x i32> %a, i32 0, i32 2
  ret <4 x i32> %1
}

define <8 x i32> @insert_v8i32_z12345z7(<8 x i32> %a) {
; SSE2-LABEL: insert_v8i32_z12345z7:
; SSE2:       # BB#0:
; SSE2-NEXT:    xorps %xmm2, %xmm2
; SSE2-NEXT:    movss {{.*#+}} xmm0 = xmm2[0],xmm0[1,2,3]
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    movd %eax, %xmm2
; SSE2-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,0],xmm1[3,0]
; SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,1],xmm2[0,2]
; SSE2-NEXT:    retq
;
; SSE3-LABEL: insert_v8i32_z12345z7:
; SSE3:       # BB#0:
; SSE3-NEXT:    xorps %xmm2, %xmm2
; SSE3-NEXT:    movss {{.*#+}} xmm0 = xmm2[0],xmm0[1,2,3]
; SSE3-NEXT:    xorl %eax, %eax
; SSE3-NEXT:    movd %eax, %xmm2
; SSE3-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,0],xmm1[3,0]
; SSE3-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,1],xmm2[0,2]
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: insert_v8i32_z12345z7:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    xorps %xmm2, %xmm2
; SSSE3-NEXT:    movss {{.*#+}} xmm0 = xmm2[0],xmm0[1,2,3]
; SSSE3-NEXT:    xorl %eax, %eax
; SSSE3-NEXT:    movd %eax, %xmm2
; SSSE3-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,0],xmm1[3,0]
; SSSE3-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,1],xmm2[0,2]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: insert_v8i32_z12345z7:
; SSE41:       # BB#0:
; SSE41-NEXT:    xorl %eax, %eax
; SSE41-NEXT:    pinsrd $0, %eax, %xmm0
; SSE41-NEXT:    pinsrd $2, %eax, %xmm1
; SSE41-NEXT:    retq
;
; AVX1-LABEL: insert_v8i32_z12345z7:
; AVX1:       # BB#0:
; AVX1-NEXT:    xorl %eax, %eax
; AVX1-NEXT:    vpinsrd $0, %eax, %xmm0, %xmm1
; AVX1-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpinsrd $2, %eax, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: insert_v8i32_z12345z7:
; AVX2:       # BB#0:
; AVX2-NEXT:    xorl %eax, %eax
; AVX2-NEXT:    vmovd %eax, %xmm1
; AVX2-NEXT:    vpblendd {{.*#+}} ymm0 = ymm1[0],ymm0[1,2,3,4,5,6,7]
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpinsrd $2, %eax, %xmm1, %xmm1
; AVX2-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %1 = insertelement <8 x i32> %a, i32 0, i32 0
  %2 = insertelement <8 x i32> %1, i32 0, i32 6
  ret <8 x i32> %2
}

define <8 x i16> @insert_v8i16_z12345z7(<8 x i16> %a) {
; SSE-LABEL: insert_v8i16_z12345z7:
; SSE:       # BB#0:
; SSE-NEXT:    xorl %eax, %eax
; SSE-NEXT:    pinsrw $0, %eax, %xmm0
; SSE-NEXT:    pinsrw $6, %eax, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: insert_v8i16_z12345z7:
; AVX:       # BB#0:
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vpinsrw $0, %eax, %xmm0, %xmm0
; AVX-NEXT:    vpinsrw $6, %eax, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = insertelement <8 x i16> %a, i16 0, i32 0
  %2 = insertelement <8 x i16> %1, i16 0, i32 6
  ret <8 x i16> %2
}

define <16 x i16> @insert_v16i16_z12345z789ABZDEz(<16 x i16> %a) {
; SSE-LABEL: insert_v16i16_z12345z789ABZDEz:
; SSE:       # BB#0:
; SSE-NEXT:    xorl %eax, %eax
; SSE-NEXT:    pinsrw $0, %eax, %xmm0
; SSE-NEXT:    pinsrw $6, %eax, %xmm0
; SSE-NEXT:    pinsrw $7, %eax, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: insert_v16i16_z12345z789ABZDEz:
; AVX1:       # BB#0:
; AVX1-NEXT:    xorl %eax, %eax
; AVX1-NEXT:    vpinsrw $0, %eax, %xmm0, %xmm1
; AVX1-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX1-NEXT:    vpinsrw $6, %eax, %xmm0, %xmm1
; AVX1-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpinsrw $7, %eax, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: insert_v16i16_z12345z789ABZDEz:
; AVX2:       # BB#0:
; AVX2-NEXT:    xorl %eax, %eax
; AVX2-NEXT:    vpinsrw $0, %eax, %xmm0, %xmm1
; AVX2-NEXT:    vpblendd {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX2-NEXT:    vpinsrw $6, %eax, %xmm0, %xmm1
; AVX2-NEXT:    vpblendd {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpinsrw $7, %eax, %xmm1, %xmm1
; AVX2-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %1 = insertelement <16 x i16> %a, i16 0, i32 0
  %2 = insertelement <16 x i16> %1, i16 0, i32 6
  %3 = insertelement <16 x i16> %2, i16 0, i32 15
  ret <16 x i16> %3
}

define <16 x i8> @insert_v16i8_z123456789ABZDEz(<16 x i8> %a) {
; SSE2-LABEL: insert_v16i8_z123456789ABZDEz:
; SSE2:       # BB#0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm1 = [0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
; SSE2-NEXT:    pand %xmm1, %xmm0
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    movd %eax, %xmm2
; SSE2-NEXT:    pandn %xmm2, %xmm1
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    movdqa {{.*#+}} xmm1 = [255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0]
; SSE2-NEXT:    pand %xmm1, %xmm0
; SSE2-NEXT:    pslldq {{.*#+}} xmm2 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm2[0]
; SSE2-NEXT:    pandn %xmm2, %xmm1
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE3-LABEL: insert_v16i8_z123456789ABZDEz:
; SSE3:       # BB#0:
; SSE3-NEXT:    movdqa {{.*#+}} xmm1 = [0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
; SSE3-NEXT:    pand %xmm1, %xmm0
; SSE3-NEXT:    xorl %eax, %eax
; SSE3-NEXT:    movd %eax, %xmm2
; SSE3-NEXT:    pandn %xmm2, %xmm1
; SSE3-NEXT:    por %xmm1, %xmm0
; SSE3-NEXT:    movdqa {{.*#+}} xmm1 = [255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0]
; SSE3-NEXT:    pand %xmm1, %xmm0
; SSE3-NEXT:    pslldq {{.*#+}} xmm2 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm2[0]
; SSE3-NEXT:    pandn %xmm2, %xmm1
; SSE3-NEXT:    por %xmm1, %xmm0
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: insert_v16i8_z123456789ABZDEz:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = zero,xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
; SSSE3-NEXT:    xorl %eax, %eax
; SSSE3-NEXT:    movd %eax, %xmm1
; SSSE3-NEXT:    movdqa %xmm1, %xmm2
; SSSE3-NEXT:    pshufb {{.*#+}} xmm2 = xmm2[0],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    por %xmm2, %xmm0
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],zero
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm1[0]
; SSSE3-NEXT:    por %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: insert_v16i8_z123456789ABZDEz:
; SSE41:       # BB#0:
; SSE41-NEXT:    xorl %eax, %eax
; SSE41-NEXT:    pinsrb $0, %eax, %xmm0
; SSE41-NEXT:    pinsrb $15, %eax, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: insert_v16i8_z123456789ABZDEz:
; AVX:       # BB#0:
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vpinsrb $0, %eax, %xmm0, %xmm0
; AVX-NEXT:    vpinsrb $15, %eax, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = insertelement <16 x i8> %a, i8 0, i32 0
  %2 = insertelement <16 x i8> %1, i8 0, i32 15
  ret <16 x i8> %2
}

define <32 x i8> @insert_v32i8_z123456789ABCDEzGHIJKLMNOPQRSTzz(<32 x i8> %a) {
; SSE2-LABEL: insert_v32i8_z123456789ABCDEzGHIJKLMNOPQRSTzz:
; SSE2:       # BB#0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    movd %eax, %xmm3
; SSE2-NEXT:    pandn %xmm3, %xmm2
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0]
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pslldq {{.*#+}} xmm4 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm4[0]
; SSE2-NEXT:    movdqa {{.*#+}} xmm5 = [255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,255]
; SSE2-NEXT:    pand %xmm5, %xmm1
; SSE2-NEXT:    pslldq {{.*#+}} xmm3 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm3[0,1]
; SSE2-NEXT:    pandn %xmm3, %xmm5
; SSE2-NEXT:    por %xmm5, %xmm1
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm4, %xmm2
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    por %xmm2, %xmm1
; SSE2-NEXT:    retq
;
; SSE3-LABEL: insert_v32i8_z123456789ABCDEzGHIJKLMNOPQRSTzz:
; SSE3:       # BB#0:
; SSE3-NEXT:    movdqa {{.*#+}} xmm2 = [0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
; SSE3-NEXT:    pand %xmm2, %xmm0
; SSE3-NEXT:    xorl %eax, %eax
; SSE3-NEXT:    movd %eax, %xmm3
; SSE3-NEXT:    pandn %xmm3, %xmm2
; SSE3-NEXT:    por %xmm2, %xmm0
; SSE3-NEXT:    movdqa {{.*#+}} xmm2 = [255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0]
; SSE3-NEXT:    pand %xmm2, %xmm0
; SSE3-NEXT:    movdqa %xmm3, %xmm4
; SSE3-NEXT:    pslldq {{.*#+}} xmm4 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm4[0]
; SSE3-NEXT:    movdqa {{.*#+}} xmm5 = [255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,255]
; SSE3-NEXT:    pand %xmm5, %xmm1
; SSE3-NEXT:    pslldq {{.*#+}} xmm3 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm3[0,1]
; SSE3-NEXT:    pandn %xmm3, %xmm5
; SSE3-NEXT:    por %xmm5, %xmm1
; SSE3-NEXT:    pand %xmm2, %xmm1
; SSE3-NEXT:    pandn %xmm4, %xmm2
; SSE3-NEXT:    por %xmm2, %xmm0
; SSE3-NEXT:    por %xmm2, %xmm1
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: insert_v32i8_z123456789ABCDEzGHIJKLMNOPQRSTzz:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = zero,xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
; SSSE3-NEXT:    xorl %eax, %eax
; SSSE3-NEXT:    movd %eax, %xmm2
; SSSE3-NEXT:    movdqa %xmm2, %xmm3
; SSSE3-NEXT:    pshufb {{.*#+}} xmm3 = xmm3[0],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    por %xmm3, %xmm0
; SSSE3-NEXT:    movdqa {{.*#+}} xmm3 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,128]
; SSSE3-NEXT:    pshufb %xmm3, %xmm0
; SSSE3-NEXT:    movdqa %xmm2, %xmm4
; SSSE3-NEXT:    pshufb {{.*#+}} xmm4 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm4[0]
; SSSE3-NEXT:    por %xmm4, %xmm0
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[0,1,2,3,4,5,6,7,8,9,10,11,12,13],zero,xmm1[15]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm2 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm2[0],zero
; SSSE3-NEXT:    por %xmm2, %xmm1
; SSSE3-NEXT:    pshufb %xmm3, %xmm1
; SSSE3-NEXT:    por %xmm4, %xmm1
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: insert_v32i8_z123456789ABCDEzGHIJKLMNOPQRSTzz:
; SSE41:       # BB#0:
; SSE41-NEXT:    xorl %eax, %eax
; SSE41-NEXT:    pinsrb $0, %eax, %xmm0
; SSE41-NEXT:    pinsrb $15, %eax, %xmm0
; SSE41-NEXT:    pinsrb $14, %eax, %xmm1
; SSE41-NEXT:    pinsrb $15, %eax, %xmm1
; SSE41-NEXT:    retq
;
; AVX1-LABEL: insert_v32i8_z123456789ABCDEzGHIJKLMNOPQRSTzz:
; AVX1:       # BB#0:
; AVX1-NEXT:    xorl %eax, %eax
; AVX1-NEXT:    vpinsrb $0, %eax, %xmm0, %xmm1
; AVX1-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX1-NEXT:    vpinsrb $15, %eax, %xmm0, %xmm1
; AVX1-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpinsrb $14, %eax, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    vpinsrb $15, %eax, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: insert_v32i8_z123456789ABCDEzGHIJKLMNOPQRSTzz:
; AVX2:       # BB#0:
; AVX2-NEXT:    xorl %eax, %eax
; AVX2-NEXT:    vpinsrb $0, %eax, %xmm0, %xmm1
; AVX2-NEXT:    vpblendd {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX2-NEXT:    vpinsrb $15, %eax, %xmm0, %xmm1
; AVX2-NEXT:    vpblendd {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpinsrb $14, %eax, %xmm1, %xmm1
; AVX2-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX2-NEXT:    vpinsrb $15, %eax, %xmm1, %xmm1
; AVX2-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %1 = insertelement <32 x i8> %a, i8 0, i32 0
  %2 = insertelement <32 x i8> %1, i8 0, i32 15
  %3 = insertelement <32 x i8> %2, i8 0, i32 30
  %4 = insertelement <32 x i8> %3, i8 0, i32 31
  ret <32 x i8> %4
}
