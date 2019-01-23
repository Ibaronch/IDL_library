Useful Idl functions
Ivano Baronchelli 2018

; LIST:
; cccpy.pro
; density_map5.pro
; double_gauss_fit.pro
; plotxyz.pro
; smearer.pro


;-----------------------------------------------------------------------
; cccpy.pro
;-----------------------------------------------------------------------
; This IDL program (calling a python function) can be used to match
; two catalogs using their RA and DEC positions. 
; This progam is based on the same principles of cccpro.pro (Written
; by Mattia Vaccari), but the cccpy function works in a much more
; efficient (faster) way when using big catalogs (>100 thousand entries) 
; Principle:
; This program writes a python program in a temporary file called
; "cccpy.py". The indexes and coordinates are passed from IDL to
; python and vice-versa through two temporary files: tmp0.txt and
; tmp1.txt. 
; At the end of the process, all the temporary files are deleted.
;------------------------------------------------------------------------

;-----------------------------------------------------------------------
; density_map5.pro
;-----------------------------------------------------------------------
; overplots (output file) a color density map, given an input list of x, y, datapoints
;-----------------------------------------------------------------------


;-----------------------------------------------------------------------
; double_gauss_fit.pro
;-----------------------------------------------------------------------
; Given the x and y values of an histogram (xhist, yhist),
; it finds the best fit for a double gaussian distribution trying
; different peak and sigma values.
;-----------------------------------------------------------------------


;-----------------------------------------------------------------------
; plotxyz.pro
;-----------------------------------------------------------------------
; This function works as an "oplot" function. Overimposed to the input
; x,y positions, it draws bigger (and color-scaled) circles for higher 
; values of z. 
;-----------------------------------------------------------------------


;-----------------------------------------------------------------------
; smearer.pro
;-----------------------------------------------------------------------
; It creates a set of x, y, z elements randomly distributed (gaussian) 
; around an input list of x, y, z values.
;--------------------------------------------------------------------




