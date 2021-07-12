# IDL_library V1.1
Library of useful Idl functions
Ivano Baronchelli 2018 - 2021

LIST:     
antiblooming2.pro     
cccpy.pro     
density_map6.pro     
double_gauss_fit.pro     
plotxyz.pro     
smearer.pro     



antiblooming2.pro    
This program corrects astronomical images from blooming effects (saturation)

cccpy.pro    
This IDL program (calling a python function) can be used to match
two catalogs using their RA and DEC positions. 
This progam is based on the same principles of cccpro.pro (Written
by Mattia Vaccari), but the cccpy function works in a much more
efficient (faster) way when using big catalogs (>100 thousand entries) 
Principle:
This program writes a python program in a temporary file called
"cccpy.py". The indexes and coordinates are passed from IDL to
python and vice-versa through two temporary files: tmp0.txt and
tmp1.txt. 
At the end of the process, all the temporary files are deleted.


density_map6.pro    
overplots (output file) a color density map, given an input list of x, y, datapoints

double_gauss_fit.pro    
Given the x and y values of an histogram (xhist, yhist),
it finds the best fit for a double gaussian distribution trying
different peak and sigma values.

plotxyz.pro    
This function works as an "oplot" function. Overimposed to the input
x,y positions, it draws bigger (and color-scaled) circles for higher 
values of z. 

smearer.pro    
It creates a set of x, y, z elements randomly distributed (gaussian) 
around an input list of x, y, z values.

----------------------------------------------------
Differences with respect to previous versions (1.0):
----------------------------------------------------
    density_map5.pro is replaced by density_map6.pro.

    some minor bugs of the previous version are now corrected;
    Z_TYPE "ran" option is added.

 > density_map5.pro is replaced by density_map6.pro.
   - some minor bugs of the previous version are now corrected;
   - Z_TYPE "ran" option is added.



