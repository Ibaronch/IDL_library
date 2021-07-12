FUNCTION density_map6, x, y, z_axe=z_axe, xbin, ybin, weight=weight,levels_vect,smoothing_scale,color_cont,box=box,HRF=HRF,TYPE_LEVEL=TYPE_LEVEL,z_TYPE=z_TYPE,colorbar=colorbar,CB_x1=CB_x1,CB_y1=CB_y1,CB_x2=CB_x2,CB_y2=CB_y2,CB_DENSITY=CB_DENSITY,CB_title=CB_title,CB_tx_size=CB_tx_size,CB_tx_thick=CB_tx_thick,CB_thick_dist=CB_thick_dist

; overplots (output file) a color density map, given an input list of x, y, datapoints
;
; x= x position of the points
; y= y position of the points
; /z_axe --> if this keyword is set, "weight" is used as z value instead
;            than as a weight.  
; xbin= x resolution of the boxes 
; ybin= y resolution of the boxes
; weight= vector with same dimension of x and y with values from 0 to
;         1, used to weigth the single points. 
; levels_vect= vector containing the levels (unitary fraction)
; smoothing_scale= 0 or 1 no smoothing, >1 increase the smoothing scale
; color_cont= 0 BLACK,
;             1 YELLOW - RED
;             2 RED - GREEN
;             3 GREEN - BLUE
;             4 BLUE - GREEN
;             5 GREEN - YELLOW
; /box --> If this keyword is set, all the boxes will be filled with a
;          a scale of color correspondent to the average level in the
;          box itself. NO CONTOURS ARE DRAWN IN THIS CASE
; HRF= high resolution factor. The output plot will increase the apparent
;      resolution of this factor
;---------------------------------------------------------------------
; TYPE_LEVEL=type of levels to be considered:
;            0 (default) --> the levels specified in levels_vect
;                            correspond to the fraction of the maximum
;                            value reached by the original distribution
;            1           --> the levels specified in levels_vect
;                            correspond to the fraction of data points
;                            included inside the contours (or the
;                            fraction of volume when the /Z keyword is
;                            set) 
;---------------------------------------------------------------------
;Z_TYPE --> decides the way in which the z values in each single x,y
;           box will be combined
;           sum --> the value in (x,y) is the sum of the values of z of
;                   each single data point;
;           min --> minimum 
;           max --> maximum
;           med --> median
;           ave --> mean
;           ran --> when multiple data points are located in the same
;                   box, it randomly selects one of them, otherwise,
;                   it uses the only available datum  
; NOTE: THIS OPTION IS CONSIDERED ONLY WHEN THE /z_axe KEYWORD IS SET
;---------------------------------------------------------------------
; colorbar --> set this keyword to add an automatic colorbar scale
;              with borders set in CB_x1,CB_y1,CB_x2,CB_y2
; CB_x1,CB_y1,CB_x2,CB_y2 --> borders of the colorbar
; [CB_DENSITY] --> density of the colorbar lines. The higher is
;                CB_DENSITY, the denser is the output
;                colorbar. Increase this number in case of gaps in the 
;                colorbar scale - optional.
; CB_title --> title of the colorbar
; CB_tx_size --> size of the colorbar text labels
; CB_tx_thick --> thick of the colorbar text labels
; [CB_thick_dist] --> density of the colorbar thick labels (the higher
;                   this number is, the more distant are the labels).
;                   This number must be smaller than CB_DENSITY -
;                   optional.
; NOTE: if color_cont= 0 , all the colorbar commands are ignored
;---------------------------------------------------------------------

; Ivano Baronchelli 2019
; Last modification: Jul 12 2021
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

if NOT keyword_set(weight) then begin
 weight=fltarr(n_elements(x))
 weight[*]=1.
endif

minx=min(x)-xbin*2.
miny=min(y)-ybin*2.
maxX=max(x)+xbin*2.
maxY=max(y)+ybin*2.

if round((maxX-minX)/Xbin)-(maxX-minX)/Xbin gt 0 then maxx=maxx-xbin
if round((maxX-minX)/Xbin)-(maxX-minX)/Xbin lt 0 then maxx=maxx+xbin
if round((maxY-minY)/Ybin)-(maxY-minY)/Ybin gt 0 then maxy=maxy-ybin
if round((maxY-minY)/Ybin)-(maxY-minY)/Ybin lt 0 then maxy=maxy+ybin

NEL_X=round((maxX-minX)/Xbin)
NEL_Y=round((maxY-minY)/Ybin)

xvect=findgen(NEL_X,NEL_Y)
yvect=findgen(NEL_X,NEL_Y)
Value=findgen(NEL_X,NEL_Y)

XC=0L
xx=minx;+xbin/2. ; from density_map6.pro
;while xx lt maxx do begin
while xx lt maxx and XC lt NEL_X do begin
 yy=miny;+ybin/2. ; from density_map6.pro
 YC=0L
; while yy lt maxy do begin
 while yy lt maxy and YC lt NEL_Y do begin
  INSIDEBOX=where(x ge xx-xbin/2. and x lt xx+xbin/2. and y ge yy-ybin/2. and y lt yy+ybin/2.)
  IF INSIDEBOX[0] ne -1 then begin 
   Value[XC,YC]=float(n_elements(INSIDEBOX))
   IF NOT keyword_set(z_axe) then Value[XC,YC]=Value[XC,YC]*total(weight[INSIDEBOX])
   IF keyword_set(z_axe) then begin
    IF Z_TYPE eq 'min' THEN Value[XC,YC]=min(weight[INSIDEBOX])
    IF Z_TYPE eq 'max' THEN Value[XC,YC]=max(weight[INSIDEBOX])
    IF Z_TYPE eq 'med' THEN Value[XC,YC]=median(weight[INSIDEBOX])
    IF Z_TYPE eq 'ave' THEN Value[XC,YC]=mean(weight[INSIDEBOX])
    IF Z_TYPE eq 'sum' or n_elements(INSIDEBOX) eq 1 THEN Value[XC,YC]=total(weight[INSIDEBOX])
    IF Z_TYPE eq 'ran' and n_elements(INSIDEBOX) gt 1 THEN BEGIN
       RVAL1=randomu(seed,n_elements(INSIDEBOX))
       RIDX=where(RVAL1 eq max(RVAL1))
       Value[XC,YC]=weight[INSIDEBOX[RIDX[0]]]
    ENDIF
   ENDIF
  ENDIF
  IF INSIDEBOX[0] eq -1 then Value[XC,YC]=0.
  xvect[XC,YC]=xx
  yvect[XC,YC]=yy
  YC=YC+1
  yy=yy+ybin
 endwhile
 XC=XC+1
 xx=xx+xbin
endwhile


; LLLLLLLLLLLLLLLLLLLL
; NO SMOOTHING IF smoothing_scale=1
; LLLLLLLLLLLLLLLLLLLL


; LLLLLLLLLLLLLLLLLLLL
; Pre-Smoothing
; LLLLLLLLLLLLLLLLLLLLL
USETHIS='no'
if USETHIS eq 'yes' then begin
SC=0L
WHILE SC LT smoothing_scale do begin
NewValue=Value
nx=0L
while nx lt n_elements(Value[*,0]) do begin
;New
Value[nx,*]=smooth(Value[nx,*],5*smoothing_scale*xbin)
nx=nx+1
endwhile
ny=0L
while ny lt n_elements(Value[0,*]) do begin
;New
Value[*,ny]=smooth(Value[*,ny],5*smoothing_scale*ybin)
ny=ny+1
endwhile
SC=SC+1
ENDWHILE
endif ;if USETHIS eq 'yes' then


; LLLLLLLLLLLLLLLLLLLL
; Smoothing my method
; LLLLLLLLLLLLLLLLLLLLL
SmSc=smoothing_scale

; OPTION NO SMOOTHING
IF SmSc le 1 then begin
HighResValue=Value
xvect_HighRes=xvect
yvect_HighRes=yvect
endif

; SMOOTHING
IF SmSc gt 1 then begin
if not keyword_set(HRF) then HRF=100.
;HRF=100.; Increasing resolution factor
HighResValue=fltarr(HRF*NEL_X,HRF*NEL_Y)
HighResValue_x=fltarr(HRF*NEL_X,HRF*NEL_Y) ; x averaged Value
HighResValue_y=fltarr(HRF*NEL_X,HRF*NEL_Y) ; y averaged Value
xvect_HighRes=fltarr(HRF*NEL_X,HRF*NEL_Y)
yvect_HighRes=fltarr(HRF*NEL_X,HRF*NEL_Y) 

VHRx=indgen(HRF*NEL_X)/HRF
VLRx=indgen(NEL_X)
YH=0L
WHILE YH lt NEL_Y do begin
xval=interpol(xvect[*,YH],VLRx,VHRx) ; x coordinates
ValHRx=smooth(interpol(Value[*,YH],VLRx,VHRx),SmSc) ; smoothed values
YH2=YH*HRF
while YH2 lt (YH+1)*HRF do begin
xvect_HighRes[*,YH2]=xval
HighResValue_x[*,YH2]=ValHRx
YH2=YH2+1
endwhile
YH=YH+1
ENDWHILE
nono=where(HighResValue_x lt 0)
if nono[0] ne -1 then HighResValue_x[nono]=0.


VHRy=indgen(HRF*NEL_Y)/HRF
VLRy=indgen(NEL_Y)
XH=0L
WHILE XH lt NEL_X do begin
yval=interpol(yvect[XH,*],VLRy,VHRy) ; y coordinates
ValHRy=smooth(interpol(Value[XH,*],VLRy,VHRy),SmSc) ; smoothed values
XH2=XH*HRF
while XH2 lt (XH+1)*HRF do begin
yvect_HighRes[XH2,*]=yval
HighResValue_y[XH2,*]=ValHRy
XH2=XH2+1
endwhile
XH=XH+1
ENDWHILE
nono=where(HighResValue_y lt 0.)
if nono[0] ne -1 then HighResValue_y[nono]=0.

; Second passage - smoothing X and Y values in the y direction
YH=0L
WHILE YH lt NEL_Y do begin
YH2=YH*HRF
while YH2 lt (YH+1)*HRF do begin
ST=0L
while ST lt SmSc+1 do begin
HighResValue_y[*,YH2]=smooth(HighResValue_y[*,YH2],HRF/2.)
HighResValue_x[*,YH2]=smooth(HighResValue_x[*,YH2],HRF/2.)
ST=ST+1
endwhile
YH2=YH2+1
endwhile
YH=YH+1
ENDWHILE
nono1=where(HighResValue_y lt 0)
nono2=where(HighResValue_x lt 0)
if nono1[0] ne -1 then HighResValue_y[nono1]=0.
if nono2[0] ne -1 then HighResValue_x[nono2]=0.

; Second passage  - smoothing X and Y values in the x direction
;       AND computing average Value (x+y)
XH=0L
WHILE XH lt NEL_X do begin
XH2=XH*HRF
while XH2 lt (XH+1)*HRF do begin
ST=0L
while ST lt SmSc+1 do begin
HighResValue_x[XH2,*]=smooth(HighResValue_x[XH2,*],HRF/2.)
HighResValue_y[XH2,*]=smooth(HighResValue_y[XH2,*],HRF/2.)
ST=ST+1
endwhile
HighResValue[XH2,*]=HighResValue_x[XH2,*]+HighResValue_y[XH2,*]
XH2=XH2+1
endwhile
XH=XH+1
ENDWHILE
nono1=where(HighResValue_x lt 0)
nono2=where(HighResValue_y lt 0)
if nono1[0] ne -1 then HighResValue_x[nono1]=0.
if nono2[0] ne -1 then HighResValue_y[nono2]=0.

HighResValue=HighResValue/2.
nono=where(HighResValue lt 0)
if nono[0] ne -1 then HighResValue[nono]=0.

ENDIF ;IF SmSc gt 1 then begin



; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
; boxes (/box keyword is set
IF keyword_set(box) then begin
 color_step=255./float(n_elements(levels_vect))
 GG=0L;n_elements(levels_vect)-1
 ;WHILE GG ge 0 do begin
 WHILE GG lt n_elements(levels_vect) do begin
  color1=GG*color_step
  if color1 gt 255 then color1=255.
  if color1 lt 0 then color1=0.


 IF NOT keyword_set(TYPE_LEVEL) then TYPE_LEVEL=0
 IF TYPE_LEVEL eq 0 then NEW_LEVEL=levels_vect[GG]*max(HighResValue)
 IF TYPE_LEVEL eq 1 then begin
  NORM_VECT1=HighResValue/total(HighResValue) ; Normalized vector of volumes
                                              ; (delta x and delta y assumed unitary)
  SORT_IDX1=sort(NORM_VECT1) ; sort Volumes Indexes
  SORT_VECT1=NORM_VECT1[SORT_IDX1] ; new sorted linear vector
  VOL_CUM=total(SORT_VECT1,/cumulative) ; CUMULATIVE VOLUME AFTER SORTING
  MIN1=min(abs(levels_vect[GG]-VOL_CUM))
  LEVEL_IDX=where(abs(VOL_CUM-levels_vect[GG]) eq MIN1 )
  NEW_LEVEL=HighResValue[SORT_IDX1[LEVEL_IDX[0]]]
 ENDIF

  ;IDENTIFY BOX TO FILL
  IF n_elements(levels_vect) eq 1 then BOXID=where(HighResValue gt NEW_LEVEL)
  IF n_elements(levels_vect) gt 1 and GG eq n_elements(levels_vect)-1 then BOXID=where(HighResValue ge NEW_LEVEL and HighResValue le max(HighResValue) ) 
  IF n_elements(levels_vect) gt 1 and GG lt n_elements(levels_vect)-1 then BOXID=where(HighResValue ge NEW_LEVEL and HighResValue lt levels_vect[GG+1]*max(HighResValue) ) 
 
  IF BOXID[0] NE -1 THEN BEGIN
   BN=0L
   WHILE BN lt n_elements(BOXID) DO BEGIN
    XVPOLF=[xvect_HighRes[BOXID[BN]]-xbin/2., xvect_HighRes[BOXID[BN]]+xbin/2., xvect_HighRes[BOXID[BN]]+xbin/2., xvect_HighRes[BOXID[BN]]-xbin/2., xvect_HighRes[BOXID[BN]]-xbin/2.]
    YVPOLF=[yvect_HighRes[BOXID[BN]]-ybin/2., yvect_HighRes[BOXID[BN]]-ybin/2., yvect_HighRes[BOXID[BN]]+ybin/2., yvect_HighRes[BOXID[BN]]+ybin/2., yvect_HighRes[BOXID[BN]]+ybin/2.]
    ; BLACK
    IF color_cont eq 0 then begin
     polyfill,XVPOLF,YVPOLF
    ENDIF
    ; YELLOW-RED
    IF color_cont eq 1 then begin
     TVLCT,[255,255,0,0],[0,255-color1,255,0],[0,0,0,255];tavola dei colori modificata
     polyfill,XVPOLF,YVPOLF,color=1
     TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
    ENDIF
    ; RED-GREEN
    IF color_cont eq 2 then begin
     TVLCT,[255,255,255-color1,0,0],[0,255-color1,color1,0],[0,0,0,255];tavola dei colori modificata
     polyfill,XVPOLF,YVPOLF,color=2
     TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
    ENDIF
    ; GREEN-BLUE
    IF color_cont eq 3 then begin
     TVLCT,[255,255,255,0,0],[0,255,255,255-color1],[0,0,0,color1];tavola dei colori modificata
     polyfill,XVPOLF,YVPOLF,color=3
     TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
    ENDIF
    ; BLUE-GREEN
    IF color_cont eq 4 then begin
     TVLCT,[255,255,255,0,0],[0,255,255,color1],[0,0,0,255-color1];tavola dei colori modificata
     polyfill,XVPOLF,YVPOLF,color=3
     TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
    ENDIF
    ; GREEN-YELLOW
    IF color_cont eq 5 then begin
     TVLCT,[255,255,255,color1,0],[255,255,255,255],[0,0,0,0];tavola dei colori modificata green
     polyfill,XVPOLF,YVPOLF,color=3
     TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
    ENDIF
;    oplot,[xvect_HighRes[BOXID[BN]],xvect_HighRes[BOXID[BN]]],[yvect_HighRes[BOXID[BN]],yvect_HighRes[BOXID[BN]]],psym=1
    BN=BN+1
   ENDWHILE
  ENDIF
  GG=GG+1
 ENDWHILE
ENDIF
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL







; color contour
IF NOT keyword_set(box) then begin
color_step=255./float(n_elements(levels_vect))
GG=0L
WHILE GG lt n_elements(levels_vect) do begin
 color1=GG*color_step
 if color1 gt 255 then color1=255.
 if color1 lt 0 then color1=0.

 IF NOT keyword_set(TYPE_LEVEL) then TYPE_LEVEL=0
 IF TYPE_LEVEL eq 0 then NEW_LEVEL=levels_vect[GG]*max(HighResValue)
 IF TYPE_LEVEL eq 1 then begin
  NORM_VECT1=HighResValue/total(HighResValue) ; Normalized vector of volumes
                                              ; (delta x and delta y assumed unitary)
  SORT_IDX1=sort(NORM_VECT1) ; sort Volumes Indexes
  SORT_VECT1=NORM_VECT1[SORT_IDX1] ; new sorted linear vector
  VOL_CUM=total(SORT_VECT1,/cumulative) ; CUMULATIVE VOLUME AFTER SORTING
  MIN1=min(abs(levels_vect[GG]-VOL_CUM))
  LEVEL_IDX=where(abs(VOL_CUM-levels_vect[GG]) eq MIN1 )
  NEW_LEVEL=HighResValue[SORT_IDX1[LEVEL_IDX[0]]]
 ENDIF

 ; BLACK
 IF color_cont eq 0 then begin
;  contour,HighResValue,xvect_HighRes,yvect_HighRes,/overplot,levels=levels_vect[GG]*max(HighResValue),thick=2

  contour,HighResValue,xvect_HighRes,yvect_HighRes,/overplot,levels=NEW_LEVEL,thick=2
 ENDIF
 ; YELLOW-RED
 IF color_cont eq 1 then begin
  TVLCT,[255,255,0,0],[0,255-color1,255,0],[0,0,0,255];tavola dei colori modificata
  ;contour,HighResValue,xvect_HighRes,yvect_HighRes,/overplot,levels=levels_vect[GG]*max(HighResValue),color=color_cont,thick=2,/fill
  contour,HighResValue,xvect_HighRes,yvect_HighRes,/overplot,levels=NEW_LEVEL,color=color_cont,thick=2,/fill
  TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
 ENDIF
 ; RED-GREEN
 IF color_cont eq 2 then begin
  TVLCT,[255,255,255-color1,0,0],[0,255-color1,color1,0],[0,0,0,255];tavola dei colori modificata
  ;contour,HighResValue,xvect_HighRes,yvect_HighRes,/overplot,levels=levels_vect[GG]*max(HighResValue),color=2,thick=2,/fill
  contour,HighResValue,xvect_HighRes,yvect_HighRes,/overplot,levels=NEW_LEVEL,color=2,thick=2,/fill
  TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
 ENDIF
 ; GREEN-BLUE
 IF color_cont eq 3 then begin
  TVLCT,[255,255,255,0,0],[0,255,255,255-color1],[0,0,0,color1];tavola dei colori modificata
  ;contour,HighResValue,xvect_HighRes,yvect_HighRes,/overplot,levels=levels_vect[GG]*max(HighResValue),color=3,thick=2,/fill
  contour,HighResValue,xvect_HighRes,yvect_HighRes,/overplot,levels=NEW_LEVEL,color=3,thick=2,/fill
  TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
 ENDIF
 ; BLUE-GREEN
 IF color_cont eq 4 then begin
  TVLCT,[255,255,255,0,0],[0,255,255,color1],[0,0,0,255-color1];tavola dei colori modificata
  ;contour,HighResValue,xvect_HighRes,yvect_HighRes,/overplot,levels=levels_vect[GG]*max(HighResValue),color=3,thick=2,/fill
  contour,HighResValue,xvect_HighRes,yvect_HighRes,/overplot,levels=NEW_LEVEL,color=3,thick=2,/fill
  TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
 ENDIF
 ; GREEN-YELLOW
 IF color_cont eq 5 then begin
  TVLCT,[255,255,255,color1,0],[255,255,255,255],[0,0,0,0];tavola dei colori modificata green
  ;contour,HighResValue,xvect_HighRes,yvect_HighRes,/overplot,levels=levels_vect[GG]*max(HighResValue),color=3,thick=2,/fill
  contour,HighResValue,xvect_HighRes,yvect_HighRes,/overplot,levels=NEW_LEVEL,color=3,thick=2,/fill
  TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
 ENDIF

 GG=GG+1
 ENDWHILE
endif

; LLLLLLLLLLLLLLLLLLLL
; Smoothing method 2
; LLLLLLLLLLLLLLLLLLLLL
USETHIS='no'
if USETHIS eq 'yes' then begin
NewValue=Value
nx=0L
while nx lt n_elements(Value[*,0]) do begin
NewValue[nx,*]=smooth(Value[nx,*],smoothing_scale*ybin)
nx=nx+1
endwhile
ny=0L
while ny lt n_elements(Value[0,*]) do begin
NewValue[*,ny]=smooth(Value[*,ny],smoothing_scale*xbin)
ny=ny+1
endwhile

; Black contur
;contour,NewValue,xvect,yvect,/overplot,levels=levels_vect*max(Value),thick=4

; color contour
color_step=255./float(n_elements(levels_vect))
GG=0L
WHILE GG lt n_elements(levels_vect) do begin
color1=GG*color_step
TVLCT,[255,255,0,0],[0,color1,255,0],[0,0,0,255];tavola dei colori modificata
contour,NewValue,xvect,yvect,/overplot,levels=levels_vect[GG]*max(Value),color=1,thick=2
TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
GG=GG+1
ENDWHILE

endif ;if USETHIS eq 'yes' then



; ============================================================
; COLORBAR
; ============================================================
if keyword_set(COLORBAR) and color_cont ne 0 then begin
 if not keyword_set(CB_DENSITY) then begin
  CB_DENSITY=1000
 endif
 NNN=CB_DENSITY ;100 ; Increase if gaps are present in the colorbar shown

 CB_y=CB_y1

 color_step=255./float(n_elements(levels_vect))
 FF=0L
 GG=0L
 PP=0L
 color1=GG*color_step
 WHILE GG lt NNN DO BEGIN
  IF float(PP)/FLOAT(NNN) ge 1./float(n_elements(levels_vect)) THEN BEGIN
   color1=color1+color_step
   PP=0L
  ENDIF 

  ;1 YELLOW-RED
  IF color_cont eq 1 then begin
   TVLCT,[255,255,0,0],[0,255-color1,255,0],[0,0,0,255];tavola dei colori modificata
   oplot,[CB_x1,CB_x2],[CB_y,CB_y],color=1,thick=3
   TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
  ENDIF

  ;2 RED-GREEN
  IF color_cont eq 2 then begin
   TVLCT,[255,255,255-color1,0,0],[0,255-color1,color1,0],[0,0,0,255];tavola dei colori modificata
   oplot,[CB_x1,CB_x2],[CB_y,CB_y],color=2,thick=3
   TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
  ENDIF

  ;3 GREEN-BLUE
  IF color_cont eq 3 then begin
   TVLCT,[255,255,255,0,0],[0,255,255,255-color1],[0,0,0,color1];tavola dei colori modificata
   oplot,[CB_x1,CB_x2],[CB_y,CB_y],color=3,thick=3
   TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
  ENDIF

  ;4 BLUE - GREEN
  IF color_cont eq 4 then begin
   TVLCT,[255,255,255,0,0],[0,255,255,color1],[0,0,0,255-color1];tavola dei colori modificata
   oplot,[CB_x1,CB_x2],[CB_y,CB_y],color=3,thick=3
   TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
  ENDIF

  ;5 GREEN-YELLOW
  IF color_cont eq 5 then begin
   TVLCT,[255,255,255,color1,0],[255,255,255,255],[0,0,0,0];tavola dei colori modificata green
   oplot,[CB_x1,CB_x2],[CB_y,CB_y],color=3,thick=3
   TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
  ENDIF

; Thick labels

  if keyword_set(CB_thick_dist) then begin
   IF FF ge CB_thick_dist or FF eq 0 or GG+1 ge NNN then begin
    string1=' '+strmid(strcompress(string(round(100.*(levels_vect[0]+(levels_vect[n_elements(levels_vect)-1]-levels_vect[0])*float(GG)/float(NNN)))),/remove_all),0,2)+'%'
    xyouts,CB_x2+0.25*(CB_X2-CB_x1),CB_y,string1,charsize=CB_tx_size,charthick=CB_tx_thick
    FF=0L
   ENDIF
  endif

   CB_y=CB_y+(CB_y2-CB_y1)/NNN
   FF=FF+1
   PP=PP+1
   GG=GG+1
 ENDWHILE

; Colorbar title
xyouts,CB_x1,CB_y2+0.05*(CB_y2-CB_y1),strcompress(string(CB_title)),charsize=CB_tx_size,charthick=CB_tx_thick

  if not keyword_set(CB_thick_dist) then begin
   string1=' '+strmid(strcompress(string(round(100.*levels_vect[0])),/remove_all),0,2)+'%'
   string2=' '+strmid(strcompress(string(round(100.*levels_vect[n_elements(levels_vect)/2.-1])),/remove_all),0,2)+'%'
   string3=' '+strmid(strcompress(string(round(100.*levels_vect[n_elements(levels_vect)-1])),/remove_all),0,2)+'%'
   xyouts,CB_x2,CB_y1,string1,charsize=1.1,charthick=3
   xyouts,CB_x2,(CB_y1+CB_y2)/2.,string2,charsize=1.1,charthick=3
   xyouts,CB_x2,CB_y2,string3,charsize=1.1,charthick=3
  endif

endif ; COLORBAR END


END






