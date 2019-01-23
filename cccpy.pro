
FUNCTION CCCPY,RA1,DEC1,RA2,DEC2,IDX1,IDX2,DT
;-----------------------------------------------------------------------
; This IDL program (calling a python function) can be used to match
; two catalogs using their RA and DEC positions. 
; This progam is based on the same principles of cccpro.pro (Written
; by Mattia Vaccari), but the cccpy function works in a much more
; efficient (faster) way when using big catalogs (>100 thousand entries) 
; Ivano Baronchelli 2018
;------------------------------------------- ----------------------------
; RA1=  Ra first set of coordinates  
; DEC1= Dec first set of coordinates 
; RA2=  Ra second set of coordinates 
; DEC2= Dec second set of coordinates
; IDX1= will contain the indexes of the first catalog having a counterpart in the second
; IDX2= will contain the indexes of the second catalog that have a conterpart in the first'
; DT=   Maximum correlation distance in arcseconds
; ------ THE FUNCTION RETURNS: ------
; DIST= will contain the distances between counterparts (always<DT)                      
;------------------------------------------------------------------------
; How to call this function inside IDL:
; > DIST=cccpy(RA1,DEC1,RA2,DEC2,IDX1,IDX2,DT)              
;------------------------------------------------------------------------
; Principle:
; This program writes a python program in a temporary file called
; "cccpy.py". The indexes and coordinates are passed from IDL to
; python and vice-versa through two temporary files: tmp0.txt and
; tmp1.txt. 
; At the end of the process, all the temporary files are deleted.


openw,u1,'cccpy.py',/get_lun

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; Write python program: import python libraries
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

printf, u1,'import os'
printf, u1,'import numpy as np'
printf, u1,'from astropy.coordinates import ICRS'
printf, u1,'from astropy import units as u'
printf, u1,'import astropy.coordinates.representation'
printf, u1,'import math'
printf, u1,'import matplotlib.pyplot as plt # to plot'
printf, u1,'import sys'
printf, u1,'from pdb import set_trace as stop'



; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; Write python class "Readcol" (python equivalent for readcol in IDL
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

printf, u1,'class Readcol(object):'
printf, u1,'    ##################################################################################'
printf, u1,'    # Read specified columns in an ascii file and returns them in the specified format'
printf, u1,'    # Example of use:'
printf, u1,"    # cat=Readcol(path0+'fin_F160.cat','f,f,x,x,x,a',skipline=17,skipcol=7)"
printf, u1,'    # X=cat.col(0)# will be a float numpy array'
printf, u1,'    # Y=cat.col(1) # will be a float numpy array'
printf, u1,'    # Z=cat.col(2) # will be a string numpy array'
printf, u1,'    # # Note that the first 17 lines and the first 7 columns are not considered.'
printf, u1,'    # # For the columns skipped using "skipcol", the format should not be specified.'
printf, u1,'    # # The indexes "n" of the output columns, used in col(n), start from 0 and do not '
printf, u1,"    # # consider skipped columns (skipcol or 'x')."
printf, u1,'    ##################################################################################'
printf, u1,'    def __init__(self, filename, form,skipline=0, skipcol=0, sep="default"):'
printf, u1,'        self.filename=filename # string containing path+filename'
printf, u1,'        self.form=form         # format of the elements in the columns. Example:'
printf, u1,"                               # 'f,f,f,x,a,i' --> first three columns (after the "
printf, u1,'                               # skipped ones, specified using skipcol) will be'
printf, u1,'                               # returned as float, third column is jumped, fourth '
printf, u1,'                               # column is returned as a character, fifth as an integer. '  
printf, u1,'        self.skipline=skipline # number of lines to skip (optional, default=0)'
printf, u1,'        self.skipcol=skipcol   # number of clumns to skip (optional, default=0)'
printf, u1,'        self.sep=sep           # Separator. Default are spaces. Other options '
printf, u1,"                               # are ',' '\t' (tab). It accepts all the options"
printf, u1,'                               # allowed in string.split()'
printf, u1,'        if os.path.isfile(filename)==0:'
printf, u1,"            print 'File '+ filename +' not found'"
printf, u1,'        if os.path.isfile(filename)==True:'
printf, u1,"            FILE=open(filename,'r')"
printf, u1,'            ALL_COL_STR=FILE.readlines()'
printf, u1,'            FILE.close()'
printf, u1,'            '
printf, u1,"            FORMAT=np.array(form.split(',')) # Must be converted otherwise it doesn't work"
printf, u1,"            ncol=len(FORMAT[FORMAT != 'x'])  # Number of output columns "
printf, u1,"            out_format=['' for x in xrange(ncol)]   # Format of output columns"
printf, u1,'            out_format=np.array(out_format, np.str) # numpy array of strings'
printf, u1,'            nlines=len(ALL_COL_STR)-skipline # Number of output lines '
printf, u1,''
printf, u1,"            all_col=[['                              ' for x in xrange(ncol)] for x in xrange(nlines)]"
printf, u1,'            all_col=np.array(all_col, np.str) # numpy array of strings'
printf, u1,"            CN=skipcol # Input Column Number (also 'x' considered here)"
printf, u1,"            RCN=0      # Real (output) Column Number (no 'x')"
printf, u1,'            while CN < len(FORMAT)+skipcol:'
printf, u1,"                if FORMAT[CN-skipcol]!='x':"
printf, u1,'                    LN=skipline # Input line Number'
printf, u1,"                    RLN=0       # Real (output) line Number (no 'x')"
printf, u1,'                    while LN < len(ALL_COL_STR):'
printf, u1,'                        line=ALL_COL_STR[LN]'
printf, u1,"                        if sep=='default':"
printf, u1,'                            linesplit = line.split()'
printf, u1,"                        if sep!='default':"
printf, u1,'                            linesplit = line.split(self.sep)'
printf, u1,'                        #--------------------------------'
printf, u1,'                        all_col[RLN,RCN]=linesplit[CN]'
printf, u1,'                        #--------------------------------'
printf, u1,'                        LN=LN+1'
printf, u1,'                        RLN=RLN+1'
printf, u1,'                    out_format[RCN]=FORMAT[CN-skipcol]'
printf, u1,'                    RCN=RCN+1'
printf, u1,'                CN=CN+1'
printf, u1,'        self.out_format=out_format'
printf, u1,'        self.all_col=all_col       ' 
printf, u1,'    def col(self,coln):'
printf, u1,'        ###################################################'
printf, u1,"        # 'coln' corresponds to the column number on the ascii "
printf, u1,"        # file (start from 0) minus 'skipcol', minus the number"
printf, u1,"        # of 'x' indicated in the input format string 'form'   "
printf, u1,'        ###################################################'
printf, u1,"        if self.out_format[coln].lower()=='a':"
printf, u1,'            OUTCOL=np.array(self.all_col[:,coln], np.str)'
printf, u1,"        if self.out_format[coln].lower()=='i':"
printf, u1,'            OUTCOL=np.array(self.all_col[:,coln], np.int)'
printf, u1,"        if self.out_format[coln].lower()=='f':"
printf, u1,'            OUTCOL=np.array(self.all_col[:,coln], np.float)'
printf, u1,'        return OUTCOL'


; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; Write python class "Match_cat"
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

printf, u1,' '
printf, u1,' '
printf, u1,'class Match_cat(object):'
printf, u1,'################################################'
printf, u1,'# Match coordinates [deg], in two lists of coordinates, '
printf, u1,'# using an user specyfied searching radius dt[arcsec]'
printf, u1,'# For each source in the first catalog, the closest'
printf, u1,'# counterpart in the second catalog is associated.'
printf, u1,'# Input parameters are numpy single dimension arrays.'
printf, u1,'# Example:'
printf, u1,'# > MATCH1=Match_cat(ra1,dec1,ra2,dec2,dist)'
printf, u1,'# > idx1=MATCH1.IDX1 # indexes of first catalog having a counterpart in the second '
printf, u1,'# > idx2=MATCH1.IDX2 # indexes of second catalog that have a conterpart in the first'
printf, u1,'# > DIST=MATCH1.DIST # [arcsec] distance between counterparts (always<dist)'
printf, u1,'################################################'
printf, u1,'    # Class definition'
printf, u1,'    def __init__(self, RA1,DEC1,RA2,DEC2,dist):'
printf, u1,'        # Input definition'
printf, u1,'        self.RA1=RA1   # Ra first set of coordinates   (numpy array single dimension)'
printf, u1,'        self.DEC1=DEC1 # Dec first set of coordinates  (numpy array single dimension)'
printf, u1,'        self.RA2=RA2   # Ra second set of coordinates  (numpy array single dimension)'
printf, u1,'        self.DEC2=DEC2 # Dec second set of coordinates (numpy array single dimension)'
printf, u1,'        self.dist=float(dist) # Maximum correlation distance in arcseconds (float)'
printf, u1,'        # 1) Transform np aray to "Angle" type'
printf, u1,'        RA1_angle=astropy.coordinates.representation.Longitude(self.RA1, unit=u.deg)'
printf, u1,'        DEC1_angle=astropy.coordinates.representation.Latitude(self.DEC1, unit=u.deg)'
printf, u1,'        RA2_angle=astropy.coordinates.representation.Longitude(self.RA2, unit=u.deg)'
printf, u1,'        DEC2_angle=astropy.coordinates.representation.Latitude(self.DEC2, unit=u.deg)'
printf, u1,'        # 2) create catalog classes'
printf, u1,'        cat1=ICRS(RA1_angle,DEC1_angle)#, unit=(u.degree, u.degree))'
printf, u1,'        cat2=ICRS(RA2_angle,DEC2_angle)#, unit=(u.degree, u.degree))'
printf, u1,'        # 3) Match catalogs using astropy.coordinates.match_coordinates_sky"'
printf, u1,'        d1d, d2d, d3d = astropy.coordinates.match_coordinates_sky(cat1,cat2)'
printf, u1,'        # Second catalog indexes of sources closer than "dist" ONLY! '
printf, u1,'        self.IDX2=d1d[(d2d.degree *3600. < self.dist)]'
printf, u1,'        # First catalog indexes of sources closer than "dist" ONLY! '
printf, u1,'        IDX1ALL = list(range(len(RA1)))'
printf, u1,'        IDX1ALL = np.array(IDX1ALL)'
printf, u1,'        self.IDX1=IDX1ALL[(d2d.degree *3600. < self.dist)]'
printf, u1,'        # Distances of sources closer than "dist" ONLY! '
printf, u1,'        self.DIST=3600*d2d.degree[(d2d.degree*3600. < self.dist)]'
printf, u1,'        '
printf, u1,'    def DIST(self):'
printf, u1,'        return self.DIST'
printf, u1,'    def IDX1(self):'
printf, u1,'        return self.IDX1'
printf, u1,'    def IDX2(self):'
printf, u1,'        return self.IDX2'

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; Write python "main", where the match is performed by using the class
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
printf, u1,'def main():'

; Instructions (how to run the python program)

printf, u1,'    if len(sys.argv)-1 != 3:'
printf, u1,'        print "-------------------------------"'
printf, u1,'        print "ERROR (cccpy.py)   "'
printf, u1,'        print "3 INPUT arguments expected:    "'
printf, u1,'        print " -tmp0_A.txt = input file containing:  "'
printf, u1,'        print "    RA1=  Ra first set of coordinates   "'
printf, u1,'        print "    DEC1= Dec first set of coordinates  "'
printf, u1,'        print " -tmp0_B.txt = input file containing:  "'
printf, u1,'        print "    RA2=  Ra second set of coordinates  "'
printf, u1,'        print "    DEC2= Dec second set of coordinates "'
printf, u1,'        print " -DT= Maximum correlation distance in arcseconds  "'
printf, u1,'        print "This function returns:    "'
printf, u1,'        print "  DIST= distance between counterparts (always<DT) "'
printf, u1,'        print "and writes a file: tmp1.txt, containing:"'
printf, u1,'        print "IDX1 =indexes of the first catalog having a counterpart in the second "'
printf, u1,'        print "IDX2 =indexes of the second catalog having a counterpart in the first "'
printf, u1,'        print ""'
printf, u1,'        print "-------------------------------"'

; Read vectors in the input file
printf, u1,'    cat1=Readcol("tmp0_A.txt","f,f")'
printf, u1,'    cat2=Readcol("tmp0_B.txt","f,f")'
printf, u1,'    RA1=cat1.col(0) '
printf, u1,'    DEC1=cat1.col(1)'
printf, u1,'    RA2=cat2.col(0) '
printf, u1,'    DEC2=cat2.col(1)'

printf, u1,'    DT=sys.argv[3] '

printf, u1,'    MATCH_1=Match_cat(RA1,DEC1,RA2,DEC2,DT)'
printf, u1,'    # IDX1=np.array(MATCH_1.IDX1[0])'
printf, u1,'    # IDX2=np.array(MATCH_1.IDX2[0])'
printf, u1,'    # DIST=np.array(MATCH_1.DIST[0])'

printf, u1,'    file = open("tmp1.txt","w")'
printf, u1,'    idx=0'
printf, u1,'    while idx < len(MATCH_1.IDX1):'
printf, u1,'        string=str(MATCH_1.IDX1[idx])+" "+str(MATCH_1.IDX2[idx])+" "+str(MATCH_1.DIST[idx])+"\n"'
printf, u1,'        file.write(string)'
printf, u1,'        idx=idx+1'

printf, u1,'    file.close()'

; Write outputs in a temporary file.

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; Write python command to run the "main"
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
printf, u1," "
printf, u1,"if __name__ == '__main__':"
printf, u1,"    main()"

;-------------------------
CLOSE,u1
FREE_LUN,u1

; -----------------------------------------------------------------------
; IDL PART --------------------------------------------------------------
; -----------------------------------------------------------------------

; WRITE INPUT vectors in a file (no other way to pass them to python)
openw, fo1,'tmp0_A.txt' , /get_lun
nlk=0L
nel=n_elements(RA1)
while nlk lt nel do begin
printf,fo1,RA1[nlk],DEC1[nlk],format='(2(f12.8,1x))'
nlk=nlk+1
endwhile
free_lun, fo1
close, fo1

openw, fo1,'tmp0_B.txt' , /get_lun
nlk=0L
nel=n_elements(RA2)
while nlk lt nel do begin
printf,fo1,RA2[nlk],DEC2[nlk],format='(2(f12.8,1x))'
nlk=nlk+1
endwhile
free_lun, fo1
close, fo1



; NOW THIS IDL PROGRAM CALLS THE PYTHON PROGRAM JUST WRITTEN

DT_string=strcompress(string(DT),/remove_all)
print,"python cccpy.py 'tmp0_A.txt' 'tmp0_B.txt' '"+DT_string+"'"
spawn,"python cccpy.py 'tmp0_A.txt' 'tmp0_B.txt' '"+DT_string+"'"
readcol,"tmp1.txt",IDX1,IDX2,DIST,format='f,f'
print, strcompress(string(n_elements(IDX1)))+ " counterparts found iside "+strcompress(string(DT))+" arcseconds"
print, "This correspond to:"
print, "    "+strcompress(string(100.*float(n_elements(IDX1))/ float(n_elements(RA1))))+' % of the sources in the first catalog'
print, "    "+strcompress(string(100.*float(n_elements(IDX1))/ float(n_elements(RA2))))+' % of the sources in the second catalog'

IDX1=long(IDX1)
IDX2=long(IDX2)

spawn, 'rm tmp0_A.txt'
spawn, 'rm tmp0_B.txt'
spawn, 'rm tmp1.txt'
spawn, 'rm cccpy.py'

; --------------------------
RETURN, DIST
; --------------------------

end

