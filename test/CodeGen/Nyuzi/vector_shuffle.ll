; RUN: llc -mtriple nyuzi-elf %s -o - | FileCheck %s

target triple = "nyuzi"

;
; This test validates NyuziISelLowering::LowerVECTOR_SHUFFLE
;

define <16 x i32> @test_insertelement_splat0(i32 %a) { ; CHECK-LABEL: test_insertelement_splat0:
  %single = insertelement <16 x i32> undef, i32 %a, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer

  ; CHECK: move v0, s0
  ; CHECK-NOT: shuffle

  ret <16 x i32> %splat
}

define <16 x i32> @test_insertelement_splat7(i32 %a) { ; CHECK-LABEL: test_insertelement_splat7:
  %single = insertelement <16 x i32> undef, i32 %a, i32 7
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> <i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7>

  ; CHECK: move v0, s0
  ; CHECK-NOT: shuffle

  ret <16 x i32> %splat
}


; XXX need to test scalar_to_vector


; Test where the result is a splat because all elements are the same
define <16 x i32> @test_splat_elem1(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: test_splat_elem1:
  %res = shufflevector <16 x i32> %a, <16 x i32> %b, <16 x i32> <i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7>

  ; CHECK: getlane s0, v0, 7
  ; CHECK: move v0, s0

  ret <16 x i32> %res
}

; Same as test_splat_elem1, but with second parameter
define <16 x i32> @test_splat_elem2(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: test_splat_elem2:
  %res = shufflevector <16 x i32> %a, <16 x i32> %b, <16 x i32> <i32 17, i32 17, i32 17, i32 17, i32 17, i32 17, i32 17, i32 17, i32 17, i32 17, i32 17, i32 17, i32 17, i32 17, i32 17, i32 17>

  ; CHECK: getlane s0, v1, 1
  ; CHECK: move v0, s0

  ret <16 x i32> %res
}

; Perform a shuffle where both arguments are the same. Ensure this detects that.
define <16 x i32> @identity_shuffle_same_ops(<16 x i32> %a) { ; CHECK-LABEL: identity_shuffle_same_ops:
  %res = shufflevector <16 x i32> %a, <16 x i32> %a, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>

  ; CHECK-NOT: shuffle {{v[0-9]+}}
  ; CHECK-NOT: move
  ; CHECK: ret

  ret <16 x i32> %res
}

; Only select items from the first vector. This will be a move.
define <16 x i32> @test1(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: test1:
  %res = shufflevector <16 x i32> %a, <16 x i32> %b, <16 x i32> < i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15 >

  ; CHECK-NOT: shuffle
  ; CHECK-NOT: move
  ; CHECK: ret

  ret <16 x i32> %res
}

; Only select items from the second vector. This will be a move.
define <16 x i32> @test2(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: test2:
  %res = shufflevector <16 x i32> %a, <16 x i32> %b, <16 x i32> < i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>

  ; CHECK-NOT: shuffle
  ; CHECK: move v0, v1

  ret <16 x i32> %res
}

; Select items from both vectors, but same lanes. Will be masked move
; CHECK: [[MM_CPE:.LCPI[0-9]+_[0-9]+]]
; CHECK: .long 21845
define <16 x i32> @masked_move(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: masked_move:
  %res = shufflevector <16 x i32> %a, <16 x i32> %b, <16 x i32> < i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>

  ; CHECK: load_32 [[MM_SREG:s[0-9]+]], [[MM_CPE]]
  ; CHECK-NEXT: move_mask {{v[0-9]+}}, [[MM_SREG]], v0
  ; CHECK-NOT: shuffle

  ret <16 x i32> %res
}

; Shuffle only vector 1
; CHECK: [[SO1_SHUFFLEVECCP:.LCPI[0-9]+_[0-9]+]]
; CHECK: .long 15
; CHECK: .long 14
; CHECK: .long 13
; CHECK: .long 12
; CHECK: .long 11
; CHECK: .long 10
; CHECK: .long 9
; CHECK: .long 8
; CHECK: .long 7
; CHECK: .long 6
; CHECK: .long 5
; CHECK: .long 4
; CHECK: .long 3
; CHECK: .long 2
; CHECK: .long 1
; CHECK: .long 0

define <16 x i32> @shuffle_only1(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: shuffle_only1:
  %res = shufflevector <16 x i32> %a, <16 x i32> %b, <16 x i32> < i32 15, i32 14, i32 13, i32 12, i32 11, i32 10, i32 9, i32 8, i32 7, i32 6, i32 5, i32 4, i32 3, i32 2, i32 1, i32 0 >

  ; CHECK: load_v [[SO1_SHUFFLEVEC:v[0-9]+]], [[SO1_SHUFFLEVECCP]]
  ; CHECK-NEXT: shuffle v0, v0, [[SO1_SHUFFLEVEC]]
  ; CHECK-NEXT: ret

  ret <16 x i32> %res
}

; Shuffle only vector 2
; CHECK: [[SO2_SHUFFLEVECCP:.LCPI[0-9]+_[0-9]+]]
; CHECK: .long 15
; CHECK: .long 14
; CHECK: .long 13
; CHECK: .long 12
; CHECK: .long 11
; CHECK: .long 10
; CHECK: .long 9
; CHECK: .long 8
; CHECK: .long 7
; CHECK: .long 6
; CHECK: .long 5
; CHECK: .long 4
; CHECK: .long 3
; CHECK: .long 2
; CHECK: .long 1
; CHECK: .long 0
define <16 x i32> @shuffle_only2(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: shuffle_only2:
  %res = shufflevector <16 x i32> %a, <16 x i32> %b, <16 x i32> < i32 31, i32 30, i32 29, i32 28, i32 27, i32 26, i32 25, i32 24, i32 23, i32 22, i32 21, i32 20, i32 19, i32 18, i32 17, i32 16 >

  ; CHECK: load_v [[SO2_SHUFFLEVEC:v[0-9]+]], [[SO2_SHUFFLEVECCP]]
  ; CHECK-NEXT: shuffle v0, v1, [[SO2_SHUFFLEVEC]]
  ; CHECK-NEXT: ret

  ret <16 x i32> %res
}

; Shuffle and mix vectors
; CHECK: [[SM_SHUFFLEVECCP:.LCPI[0-9]+_[0-9]+]]
; CHECK: .long 15
; CHECK: .long 14
; CHECK: .long 13
; CHECK: .long 12
; CHECK: .long 11
; CHECK: .long 10
; CHECK: .long 9
; CHECK: .long 8
; CHECK: .long 7
; CHECK: .long 6
; CHECK: .long 5
; CHECK: .long 4
; CHECK: .long 3
; CHECK: .long 2
; CHECK: .long 1
; CHECK: .long 0
; CHECK: [[SM_MASKCP:.LCPI[0-9]+_[0-9]+]]
; CHECK: .long 43690

define <16 x i32> @test_shuffle_mix(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: test_shuffle_mix:
  %res = shufflevector <16 x i32> %a, <16 x i32> %b, <16 x i32> < i32 31, i32 14, i32 29, i32 12, i32 27, i32 10, i32 25, i32 8, i32 23, i32 6, i32 21, i32 4, i32 19, i32 2, i32 17, i32 0 >

  ; CHECK: load_v [[SM_SHUFFLEVEC:v[0-9]+]], [[SM_SHUFFLEVECCP]]
  ; CHECK: shuffle v1, v1, [[SM_SHUFFLEVEC]]
  ; CHECK: load_32 [[SM_MASK:s[0-9]+]], [[SM_MASKCP]]
  ; CHECK: shuffle_mask {{v[0-9]+}}, [[SM_MASK]], v0, [[SM_SHUFFLEVEC]]

  ret <16 x i32> %res
}
