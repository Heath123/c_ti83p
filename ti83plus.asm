;; Code Copyright (c) 2016 Scott Morton
;; This is free software, released under the MIT license.
;; See the bundled LICENSE.txt for more information.
;; The framework for this file was generated by the SDCC.

;; This file contains C wrappers for simple calculator functions.
;; Most of them are either ROM calls or else set a system flag.

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
        .globl _CGetAnsFP
        .globl _CRecallPic
        .globl _CStorePic

	.area _DATA

.include "ti83plus.inc"

.macro findsym
        rst #0x10
.endm

.macro mov9toOP1
        rst #0x20
.endm

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

_CGetAnsFP::
        bcall #_AnsName ; stores the name of Ans in OP1
        findsym
        and #0x1f  ; FindSym stores the type in a, but bits 5-7 are garbage
        jr nz,AnsNotFP ; 0x00 is type code for real floating point
        push de ; de stores the address, which is what we want
        pop hl
        ret
AnsNotFP:
        ld h,#0 ; return null if ans is not real fp
        ld l,#0
        ret

;; finds a picture variable
;; Inputs: a = picNo (1 for Pic1, etc)
;; Outputs: same as _FindSym
;; destroys: all
FindPicH:
        dec a ; Pic1 is 0x00, Pic2 is 0x01, etc.
        ld (#PicName+2),a ; set which picture we want to load
        ld hl,#PicName
        mov9toOP1
        findsym
        ret
PicName:
        .db #PictObj,#tVarPict,#0,#0

_CRecallPic::
	push	ix
	ld	ix,#0
	add	ix,sp
        ld a,4(ix)
        call FindPicH
        jr c,PicNotFound
        ld a,b
        or a ; check if pic is in RAM (not archived)
        jr z,PicInRam
        bcall #_Arc_Unarc
PicInRam:
        ex de,hl    ; move address of pic to hl
        inc hl
        inc hl  ; first 2 bytes are the size of the image
        jr CRecallPicRet
PicNotFound:
        ld h,#0
        ld l,#0
CRecallPicRet:
        pop ix
        ret

