
FUNCTION smearer, xv=xv, yv=yv, zv=zv, xsigma=xsigma, ysigma=ysigma, zsigma=zsigma, NCYCLES=NCYCLES, XRAN=XRAN, YRAN=YRAN, ZRAN=ZRAN

; Input
; x = input x vector
; y = input y vector (optional)
; z = input z vector (optional)
; xsigma = smoothing sigma along x axes
; ysigma = smoothing sigma along y axes
; zsigma = smoothing sigma along y axes
; NCYCLES = multiplicative factor for the output number of elements;
;          The number of elements in XRAN and YRAN will be
;          CYCLES * n_elements(x) = n_elements(XRAN)
;          Default value is 1.
; XRAN= output vector containing the randomized elements along x
; YRAN= output vector containing the randomized elements along y
; ZRAN= output vector containing the randomized elements along z

;NOTE:
; x, y and z must have similar number of elements;
; output are float numbers

; Written by Ivano Baronchelli 2018
;--------------------------------------------------------------------
if NOT keyword_set(NCYCLES) then NCYCLES=1
XRAN=fltarr(n_elements(xv)*NCYCLES)
YRAN=fltarr(n_elements(xv)*NCYCLES)
ZRAN=fltarr(n_elements(xv)*NCYCLES)
NCYCLES=long(NCYCLES)

; Smoothing scale for simulated data (sigma)
; Along x
smooth_x_sigma=xsigma
; Along y
smooth_y_sigma=ysigma
; Along z
smooth_z_sigma=zsigma

RR=0L
WHILE RR lt NCYCLES do begin
 ran1=fltarr(n_elements(xv))
 ran2=fltarr(n_elements(xv))
 ran3=fltarr(n_elements(xv))
 NN=0L
 while NN lt n_elements(xv) do begin
  ran1[NN]=smooth_x_sigma*randomu(seed,/normal) ; along x
  ran2[NN]=smooth_y_sigma*randomu(seed,/normal) ; along y
  ran3[NN]=smooth_z_sigma*randomu(seed,/normal) ; along z
  XRAN[RR*n_elements(xv)+NN]=xv[NN]+ran1[NN]
  YRAN[RR*n_elements(xv)+NN]=yv[NN]+ran2[NN]
  ZRAN[RR*n_elements(xv)+NN]=zv[NN]+ran3[NN]
  NN=NN+1
 endwhile
RR=RR+1
ENDWHILE

;return

END
