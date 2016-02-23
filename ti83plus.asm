;; Code Copyright (c) 2016 Scott Morton
;; This is free software, released under the MIT license.
;; See the bundled LICENSE.txt for more information.
;; The framework for this file was generated by the SDCC.
	.module ti83plus
	.optsdcc -mz80

	.globl _CGrBufCpy
	.globl _CClrLCDFull
	.globl _CNewLine
	.globl _CPutC
	.globl _CPutS
	.globl _CPutMap
	.globl _CVPutS
	.globl _CGetKey
	.globl _CGetCSC
	.globl _CTextInvertOn
	.globl _CTextInvertOff
	.globl _CLowerCaseOn
	.globl _CLowerCaseOff
	.globl _CRunIndicatorOn
	.globl _CRunIndicatorOff
	.globl _CEnableAPD
	.globl _CDisableAPD
	.globl _CEnable15MHz
	.globl _CDisable15MHz

	.area _DATA

.include "ti83plus.inc"

	.area _CODE

_CGrBufCpy::
        bcall #_GrBufCpy
	ret

_CClrLCDFull::
        bcall #_ClrLCDFull
	ret


_CNewLine::
	bcall #_newline
	ret

_CPutC::
	push	ix
	ld	ix,#0
	add	ix,sp

	ld a,4(ix)
	bcall #_PutC

	pop	ix
	ret


_CPutS::
	push	ix
	ld	ix,#0
	add	ix,sp

	ld l,4(ix)
	ld h,5(ix)
	bcall #_PutS
	pop	ix
	ret


_CPutMap::
	push	ix
	ld	ix,#0
	add	ix,sp

	ld a,4(ix)
	bcall #_PutMap
	pop	ix
	ret


_CVPutS::
	push	ix
	ld	ix,#0
	add	ix,sp

	ld l,4(ix)
	ld h,5(ix)
	bcall #_VPutS

	pop	ix
	ret


_CGetKey::
	bcall #_getkey
	ld l,a
	ret


_CGetCSC::
        bcall #_GetCSC
	ld l,a
	ret


_CTextInvertOn::
	set textInverse,textFlags(iy)
	ret


_CTextInvertOff::
	res textInverse,textFlags(iy)
	ret


_CLowerCaseOn::
	set lwrCaseActive,appLwrCaseFlag(iy)
	ret


_CLowerCaseOff::
	res lwrCaseActive,appLwrCaseFlag(iy)
	ret


_CRunIndicatorOn::
	bcall #_RunIndicOn
	ret


_CRunIndicatorOff::
	bcall #_RunIndicOff
	ret


_CEnableAPD::
        bcall #_EnableApd
	ret


_CDisableAPD::
	bcall #_DisableApd
	ret


_CEnable15MHz::
	in a,(2)
	and #0x80
	ret z ; No CPU governor on this calc
	rlca
	out (#0x20),a ; port 20 controls CPU speed
	ret

_CDisable15MHz::
	ld a,#0
	out (#0x20),a
	ret

