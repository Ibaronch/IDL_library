pro antiblooming2

; version 2
; saturated and inverted values are considered: if the saturated areas
; have negative values, set the parameter "NEG" to 'yes' and
; SAT_VAL_STRIP to the appropriate value (with NEG='yes' it is a
; maximum value, and no more a minimum)
; SOURCE_VAL_THRESH parameter is not considered when 'NEG is set to 'yes'.

 
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; ANTIBLOOMING PARAMETERS xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TEST='no' ; if 'yes', a check image will be created, with the cancelled blooming structure enhanced to a value of -10000. One can check if the cancellation is performed correctly. If TEST='no' the blooming is actually corrected.
NEG='yes'; if 'yes', the saturated strips that have to be changed are negative, in the original image.
SAT_VAL_STRIP=-0.4 ; MINIMUM (if NEG=no) OR MAXIMUM (if NEG=yes) VALUE FOR BLOOMING: minimum (maximum) value for which the saturated streeps will be cancelled. It is better to set the value to more then -CONTRAST- times the sigma value of the image.
; NOTE: real sources with fluxes (counts) above this limit will NOT
; be cancelled or modified, unless the CONTRAST parameter (see below)
; is set to a too small value!!!
CONTRAST=3 ; contrast factor betwen saturated strips and the closest pixel.
SOURCE_VAL_THRESH=20000. ; approximative saturation value.
; NOTE: the blooming effect is cancelled only in case the
; adiacent pixel is lower then SOURCE_VAL_THRESH. This parameter is
; used only when NEG='no'. If NEG='no', this means that the pixel
; values in a saturated source will not be changed!
MIN_VAL=0. ; minimum value to be considered: The pixels values will be set usig MIN_VAL as zero value. This is done BEFORE computing the contrast parameter. The final image is reported to the original values after the blooming correction.
;All the thresholds set are modified in the same way.
xyallign='x' ; SELECT BETWEEN "x" and "y" to chose the allignement of the saturated strips: x --> along x axis, y --> along y axis

; INPUT MAP arbitray units (counts)
map_arbitrary_in='tu612290_092_stack.fits'
; OUTPUT MAP arbitray units (counts)
map_arbitrary_out='tu612290_092_stack_BC.fits'


SECONDMAP='no' ; if SECONDMAP is set to "yes", the optional parameters have to be set correctly in order to create a second output map in arbitrary units.

;---------------------------------------------------------------------------
; OPTIONAL PARAMETERS : used only if "SECONDMAP" is set to yes
;---------------------------------------------------------------------------
; OUTPUT MAP other units
map_otherunits_out='SEP_Bfilter_Jy_pix_no_blooming.fits' ; OPTIONAL !!
 ZEROPOINT=30.9254 ; optional: "convers_const" can be set directly
 expo=23.-(ZEROPOINT+48.6)/2.5 ; optional: "convers_const" can be set directly
convers_const=10^(expo) ; This is the moltiplicative factor used below for the conversion from the first output image to the second output image. The conversion is performed as follows: 
;
;  map_otherunits_out=map_arbitrary_out x convers_const
;
; An other example of use is the following:
; conversion_constant= 13.5 ;  
; 
;
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;PARAMETERS END  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


; READ INPUT MAP
imgh=mrdfits(map_arbitrary_in,0,hdh)

 imgh3=imgh
 imgh4=imgh

;-------------------------------------------
imgh=imgh-MIN_VAL
imgh3=imgh3-MIN_VAL
imgh4=imgh4-MIN_VAL
SAT_VAL_STRIP=SAT_VAL_STRIP-MIN_VAL
SOURCE_VAL_THRESH=SOURCE_VAL_THRESH-MIN_VAL
;-------------------------------------------

if xyallign eq "y" then begin
 imgh=imgh
 imgh3=imgh
 imgh4=imgh
endif
if xyallign eq "x" then begin
imgh=transpose(imgh)
imgh3=transpose(imgh3)
imgh4=transpose(imgh4)
endif

imgh1=bytarr(n_elements(imgh[*,0]),n_elements(imgh[0,*]))
imgh2=bytarr(n_elements(imgh[*,0]),n_elements(imgh[0,*]))
imgh1[*,*]=0
imgh2[*,*]=0


; SATURATED STRIPS ALLIGNED WITH Y AXIS
;FROM LEFT TO RIGHT SIDE
xpix=3L
while xpix lt n_elements(imgh[*,0])-4 do begin
if NEG eq 'no' then sat_id=where(imgh3[xpix,*] gt SAT_VAL_STRIP and imgh3[xpix,*] gt CONTRAST*imgh3[xpix-1,*] and imgh3[xpix-1,*] lt SOURCE_VAL_THRESH)
if NEG eq 'yes' then sat_id=where(imgh3[xpix,*] lt SAT_VAL_STRIP and imgh3[xpix,*] lt CONTRAST*imgh3[xpix-1,*] );and imgh3[xpix-1,*] gt SOURCE_VAL_THRESH)
  if sat_id[0] ne -1 then begin
  indice=0L
    while indice lt n_elements(sat_id) do begin
       imgh1[xpix,sat_id[indice]]=1
       imgh3[xpix,sat_id[indice]]=median([imgh3[xpix-1,sat_id[indice]],imgh3[xpix-2,sat_id[indice]],imgh3[xpix-3,sat_id[indice]]])
      indice=indice+1
    endwhile
  endif
xpix=xpix+1
endwhile


;FROM RIGHT TO LEFT SIDE
xpix=n_elements(imgh[*,0])-4
while xpix gt 0 do begin
if NEG eq 'no' then  sat_id=where(imgh4[xpix,*] gt SAT_VAL_STRIP and imgh4[xpix,*] gt CONTRAST*imgh4[xpix+1,*] and imgh4[xpix+1,*] lt SOURCE_VAL_THRESH)
if NEG eq 'yes' then  sat_id=where(imgh4[xpix,*] lt SAT_VAL_STRIP and imgh4[xpix,*] lt CONTRAST*imgh4[xpix+1,*] );and imgh4[xpix+1,*] gt SOURCE_VAL_THRESH)
  if sat_id[0] ne -1 then begin
  indice=0L
    while indice lt n_elements(sat_id) do begin
      imgh2[xpix,sat_id[indice]]=1
      imgh4[xpix,sat_id[indice]]=median([imgh4[xpix+1,sat_id[indice]],imgh4[xpix+2,sat_id[indice]],imgh4[xpix+3,sat_id[indice]]])
      indice=indice+1
    endwhile
  endif
xpix=xpix-1
endwhile


;;;; if TEST eq 'yes' then imgh[where(imgh1 eq 1 AND imgh2 eq 1)]=-10000.
if TEST eq 'yes' then imgh[where(imgh1 eq 1 OR imgh2 eq 1)]=-10000.

if TEST eq 'no' then begin
xpix=1L 
while xpix lt n_elements(imgh[*,0])-4 do begin
;;;;  sat_id=where(imgh1[xpix,*] eq 1 and imgh2[xpix,*] eq 1)
sat_id=where(imgh1[xpix,*] eq 1 OR imgh2[xpix,*] eq 1)

  if sat_id[0] ne -1 then begin
  indice=0L
    while indice lt n_elements(sat_id) do begin
      ;;;;imgh[xpix,sat_id[indice]]=median([imgh3[xpix,sat_id[indice]],imgh4[xpix,sat_id[indice]]])
      imgh [xpix,sat_id[indice]]=mean([imgh3[xpix,sat_id[indice]],imgh4[xpix,sat_id[indice]]])
     indice=indice+1
    endwhile
  endif
xpix=xpix+1
endwhile
endif ;if TEST eq 'no'


if xyallign eq "y" then begin
 imgh=imgh
 imgh3=imgh3
 imgh4=imgh4
endif
if xyallign eq "x" then begin
imgh=transpose(imgh)
imgh3=transpose(imgh3)
imgh4=transpose(imgh4)
endif

;-------------------------------------------
imgh=imgh+MIN_VAL ; image ripristinated
SAT_VAL_STRIP=SAT_VAL_STRIP+MIN_VAL
SOURCE_VAL_THRESH=SOURCE_VAL_THRESH+MIN_VAL
;-------------------------------------------




; WRITE OUTPUTS
writefits,map_arbitrary_out, imgh ,hdh

; OPTIONAL OUTPUT
if SECONDMAP eq 'yes' then begin
imgh=imgh*convers_const
writefits,map_otherunits_out, imgh ,hdh
endif


stop
end
