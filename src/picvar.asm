;; This file implements functions for creating and modifying picture variables.
;;
;; Copyright (C) 2016 Scott Morton (mortonsc@umich.edu)
;;
;; This library is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This library is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this library  If not, see <http://www.gnu.org/licenses/>.
;;
;; As a special exception, if you link this library in unmodified form with
;; other files to produce an executable, this library does not by itself cause
;; the resulting executable to be covered by the GNU General Public License.
;; This exception does not however invalidate any other reasons why
;; the executable file might be covered by the GNU General Public License.

        .module picvars

        .area _DATA

.nlist
.include "ti83plus.inc"
.list

        .area _CODE

;; finds a picture variable
;; Inputs: a = picNo (1 for Pic1, etc)
;; Outputs: same as FindSym
;; destroys: all
FindPicH:
        dec a ; Pic1 is 0x00, Pic2 is 0x01, etc.
        ld (#PicName+2),a ; set which picture we want to load
        ld hl,#PicName
        rst rMOV9TOOP1
        rst rFINDSYM
        ret
PicName:
        .db PictObj,tVarPict,0,0 ; pic number goes in 3rd byte

;; unsigned char *CRecallPic(unsigned char picNo);
_CRecallPic::
	push	ix
	ld	ix,#0
	add	ix,sp
        ld a,4(ix)
        call FindPicH
        jr c,PicFailed
        ld a,b
        or a ; check if pic is in RAM (not archived)
        jr z,PicInRam
        AppOnErr UnarchivePicFailed
        push ix ; ArcUnarc destorys all regs, including OP1
        bcall _PushRealO1
        bcall _Arc_Unarc
        bcall _PopRealO1
        pop ix
        AppOffErr
        rst rFINDSYM ; find the unarchived pic again using the name in OP1
PicInRam:
        ex de,hl    ; move address of pic to hl
        inc hl
        inc hl  ; first 2 bytes are the size of the image
        pop ix
        ret
UnarchivePicFailed:
        bcall _PopRealO1
        pop ix
PicFailed:
        ld hl,#0
        pop ix
        ret

;; unsigned char *CCreatePic(unsigned char picNo);
_CCreatePic::
        push ix
        ld ix,#0
        add ix,sp

        ld a,4(ix)
        call FindPicH
        jr c,CreatePic
        push ix
        bcall _DelVarArc ; delete the var if it exists
        pop ix
CreatePic:
        AppOnErr InsufficientMem
        bcall _CreatePict ; name is still stored in OP1
        AppOffErr
        ex de,hl
        ld a,#0xF4 ; store size of image in first 2 bytes
        ld (hl),a
        inc hl
        ld a,#0x02
        ld (hl),a
        inc hl
        pop ix
        ret
InsufficientMem:
        ld hl,#0
        pop ix
        ret

;; void CArchivePic(unsigned char picNo);
_CArchivePic::
        push ix
        ld ix,#0
        add ix,sp
        ld a,4(ix)
        call FindPicH
        jr c,ArchivePicRet ; pic doesn't exist
        ld a,b
        or a
        jr nz,ArchivePicRet ; pic already archived
        AppOnErr ArchivePicRet
        bcall _Arc_Unarc
        AppOffErr
ArchivePicRet:
        pop ix
        ret

;; void CDeletePic(unsigned char picNo)
_CDeletePic::
        push ix
        ld ix,#0
        add ix,sp
        ld a,4(ix)
        call FindPicH
        jr c,DeletePicRet ; pic doesn't exist
        bcall _DelVarArc
DeletePicRet:
        pop ix
        ret

