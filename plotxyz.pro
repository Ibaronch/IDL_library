FUNCTION PLOTXYZ, x, y, z, zmin, zmax, symsize, cBAR=cBAR, BARPOS=BARPOS , CBTITLE=CBTITLE

; This function works as an "oplot" function and draws bigger points
; (and different colors) for bigger z values

; x=      vector x
; y=      vector y
; z=      vector z
; zmin=   minimum z corresponding to a symbol-size variation (upper saturation)
; zmax=   maximum z corresponding to a symbol-size variation (lower saturation)
; symsize= dimension of the symbol used
; CBAR=   if ='CBAR', a colorbar is plotted (and the following parameters are considered)
; BARPOS= position and dimension of the (optional) bar [x1,y1,x2,y2]
; CBTITLE= color bar title


xvect=x
yvect=y
zvect=z


; --------------------------------------
; Symbol used - DEFINITION OF THE CIRCLE
xx1=(indgen(21)-10.)/10.
xx2=-1*xx1[sort(xx1)]
yy1=sqrt(1-(xx1*xx1))
yy2=-sqrt(1-(xx1*xx1))
xx=[xx1,xx2]
yy=[yy1,yy2]
usersym,xx,yy,/fill
; --------------------------------------


; SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
;   Symbols colors and dimensions
; SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
z_dif=zmax-zmin
NEW_size=symsize/250. ; Enlarge to amplify the point dimension
PP=0
SS=zmin
color1=0.
ss_step=z_dif/250.

while SS le zmax do begin
 TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
 IDXZ_FR=where(zvect ge SS and zvect lt SS+ss_step)
 if SS eq zmin then IDXZ_FR=where(zvect lt SS+ss_step)
 if SS+ss_step gt zmax then IDXZ_FR=where(zvect ge SS)

 if IDXZ_FR[0] ne -1 then begin
  XVAL=xvect[IDXZ_FR]
  YVAL=yvect[IDXZ_FR]
  if n_elements(IDXZ_FR) eq 1 then begin
   XVAL=[XVAL,XVAL]
   YVAL=[YVAL,YVAL]
  endif
 endif

 if IDXZ_FR[0] ne -1 then oplot,XVAL,YVAL,psym=8,symsize=0.45+PP*NEW_size
 TVLCT,[255,255,0,0],[0,color1,255,0],[0,0,0,255];tavola dei colori modificata
 if IDXZ_FR[0] ne -1 and SS ne 0 then oplot,XVAL,YVAL,psym=8,color=1,symsize=0.2+PP*NEW_size

color1=color1+1.
SS=SS+ss_step
PP=PP+1
endwhile
TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale

; SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
; Symbols colors and dimensions -  F+R (END)
; SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS

if CBAR eq 1 then begin
;CBX1=BARPOS[0]
;CBY1=BARPOS[1]
;CBX2=BARPOS[2]
;CBY2=BARPOS[3]
; CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
; COLORBAR  COLORBAR  COLORBAR  COLORBAR  COLORBAR 
; CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

plot,[-1,-1],[-1,-1],/noerase,pos=BARPOS,yrange=[0,10],xrange=[0,30],title=CBTITLE,charthick=3,charsize=0.9,yst=6,xst=6
oplot,[0,10,10,0,0],[0,0,10,10,0],thick=6

PP=0.
TT=0.
SS=zmin
color1=0.
NEW_size=symsize/250.
while SS le zmax do begin
 YNOW=(10./250.)*PP
 TVLCT,[255,255,0,0],[0,color1,255,0],[0,0,0,255];tavola dei colori modificata
 oplot,[0,10],[YNOW,YNOW],thick=5,color=1
 TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
 IF TT eq 0 or TT eq 50 or SS+ss_step gt zmax then begin
 ;Symbols + colors + label
 oplot,[20,20],[YNOW,YNOW],psym=8,symsize=0.45+PP*NEW_size
 TVLCT,[255,255,0,0],[0,color1,255,0],[0,0,0,255];tavola dei colori modificata
 oplot,[20,20],[YNOW,YNOW],psym=8,color=1,symsize=0.2+PP*NEW_size
 TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale
 NUM1=SS
 NUM=round(NUM1*100.)/100.
 xyouts,25.,YNOW-0.1,strmid(strcompress(string(NUM)),0,5),charthick=4
 TT=0.
 endif

 IF PP eq 0 or SS+ss_step ge zmax then oplot,[0,10],[YNOW,YNOW],thick=5

 TT=TT+1
 color1=color1+1.
 SS=SS+ss_step
 PP=PP+1.
endwhile
TVLCT,[0,255,0,0],[0,0,255,0],[0,0,0,255] ;tavola dei colori originale


; CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
; COLORBAR  COLORBAR  COLORBAR  COLORBAR  COLORBAR 
; CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
ENDIF   ;if cBAR eq 1 then begin
END


