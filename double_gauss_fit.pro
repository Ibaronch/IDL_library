FUNCTION double_gauss_fit, XHIST, YHIST, SIGMAY, A1, A2, EE1, EE2, G1, G2, GE1, GE2, IP
;
; Given the x and y values of an histogram (xhist, yhist),
; it finds the best fit for a double gaussian distribution trying
; different peak and sigma values.

; XHIST  = Value of the x-axis
; YHIST  = Value of the distribution correspondent to XHIST positions
; SIGMAY = Y Associated uncertainties
; A1 = Output paramenters for gaussian 1: 
;      A[0] = Normalization
;      A[1] = peak position
;      A[2] = Sigma
; EE = Uncertainty associated to the output parameters
;      EE[0] = Estimated Error associated to Normalization
;      EE[1] = Estimated Error associated to peak position 
;      EE[2] = Estimated Error associated to Sigma 
; G1 = Output paramenters initial estimate for gaussian 1
;       The output parameters will be searched inside a 50% deviation
;       from these initial guesses. Exception for sigma, that is
;       searched inside a larger range
;      G[0] = Normalization Guess
;      G[1] = peak position Guess
;      G[2] = Sigma Guess
; GE = Precisions with which the guessed parameters in G are estimated:
;      GE[0] = Estimated Error on Normalization guess
;      GE[1] = Estimated Error on peak position
;      GE[2] = Estimated Error on Sigma
; IP = Number of Iterations to be run. Increasing this number
;      increases the output precision but also the time required

ITERATIONS=IP
Precision=5.

Norm_step1=GE1[0]/Precision
Norm_step2=GE2[0]/Precision
Center_step1=GE1[1]/Precision
Center_step2=GE2[1]/Precision
Sigma_step1=GE1[2]/Precision
Sigma_step2=GE2[2]/Precision


; MIN NORMALIZATION ESTIMATE
Norm_test_1_min=G1[0]-GE1[0]
Norm_test_2_min=G2[0]-GE2[0]
; MAX NORMALIZATION ESTIMATE
Norm_test_1_max=G1[0]+GE1[0]
Norm_test_2_max=G2[0]+GE2[0]
; MIN POSITION ESTIMATE
Center_test_1_min=G1[1]-GE1[1]
Center_test_2_min=G2[1]-GE2[1]
; MAX POSITION ESTIMATE
Center_test_1_max=G1[1]+GE1[1]
Center_test_2_max=G2[1]+GE2[1]
; MIN SIGMA ESTIMATE
sigma_test_1_min=G1[2]-GE1[2]
sigma_test_2_min=G2[2]-GE2[2]
; MAX SIGMA ESTIMATE
sigma_test_1_max=G1[2]+GE1[2]
sigma_test_2_max=G2[2]+GE2[2]

IF Norm_test_1_min lt 0 then Norm_test_1_min =0.
IF Norm_test_2_min lt 0 then Norm_test_2_min =0.
IF sigma_test_1_min lt 0 then sigma_test_1_min=0.
IF sigma_test_2_min lt 0 then sigma_test_2_min=0.


ITER=0L
WHILE ITER lt ITERATIONS do begin

CHI2=total(((YHIST)/SIGMAY)^2)
Norm_test_2=Norm_test_2_min
WHILE Norm_test_2 lt Norm_test_2_max do begin
Norm_test_1=Norm_test_1_min
WHILE Norm_test_1 lt Norm_test_1_max do begin
Center_test_2=Center_test_2_min
WHILE Center_test_2 lt Center_test_2_max do begin
Center_test_1=Center_test_1_min
WHILE Center_test_1 lt Center_test_1_max do begin
Sigma_test_2=sigma_test_2_min
WHILE Sigma_test_2 lt sigma_test_2_max do begin
Sigma_test_1=sigma_test_1_min
WHILE Sigma_test_1 lt sigma_test_1_max do begin

; Y Value of the first gaussian distrib.
Y1=Norm_test_1*exp(-((XHIST-Center_test_1)^2)/(2*Sigma_test_1^2) )
; Y Value of the second gaussian distrib.
Y2=Norm_test_2*exp(-((XHIST-Center_test_2)^2)/(2*Sigma_test_2^2) )

CHI2_test=total(((YHIST-(Y1+Y2))/SIGMAY)^2)
IF CHI2_test lt CHI2 then begin
CHI2=CHI2_test
NORM1=Norm_test_1
NORM2=Norm_test_2
CENTER1=Center_test_1
CENTER2=Center_test_2
SIGMA1=Sigma_test_1
SIGMA2=Sigma_test_2
ENDIF


Sigma_test_1= Sigma_test_1+Sigma_step1
ENDWHILE ;WHILE Sigma_test_1 lt sigma_max do begin
Sigma_test_2= Sigma_test_2+Sigma_step2
ENDWHILE ;WHILE Sigma_test_2 lt sigma_max do begin
Center_test_1=Center_test_1+Center_step1
ENDWHILE ;WHILE Norm_test_1 lt max(XHIST) do begin
Center_test_2=Center_test_2+Center_step2
ENDWHILE ;WHILE Norm_test_2 lt max(XHIST) do begin
Norm_test_1=Norm_test_1+Norm_step1
ENDWHILE ;WHILE Norm_test_1 lt 3*max(YHIST) do begin
Norm_test_2=Norm_test_2+Norm_step2
ENDWHILE ;WHILE Norm_test_2 lt 3*max(YHIST) do begin


; MIN NORMALIZATION ESTIMATE
Norm_test_1_min=NORM1-Norm_step1
Norm_test_2_min=NORM2-Norm_step2
; MAX NORMALIZATION ESTIMATE
Norm_test_1_max=NORM1+Norm_step1
Norm_test_2_max=NORM2+Norm_step2
; MIN POSITION ESTIMATE
Center_test_1_min=CENTER1-Center_step1
Center_test_2_min=CENTER2-Center_step2
; MAX POSITION ESTIMATE
Center_test_1_max=CENTER1+Center_step1
Center_test_2_max=CENTER2+Center_step2
; MIN SIGMA ESTIMATE
sigma_test_1_min=SIGMA1-Sigma_step1
sigma_test_2_min=SIGMA2-Sigma_step2
; MAX SIGMA ESTIMATE
sigma_test_1_max=SIGMA1+Sigma_step1
sigma_test_2_max=SIGMA2+Sigma_step2

IF Norm_test_1_min lt 0 then Norm_test_1_min =0.
IF Norm_test_2_min lt 0 then Norm_test_2_min =0.
IF sigma_test_1_min lt 0 then sigma_test_1_min=0.
IF sigma_test_2_min lt 0 then sigma_test_2_min=0.

; NEW STEPs
IF ITER lt ITERATIONS-1 THEN BEGIN
Norm_step1=Norm_step1/Precision
Norm_step2=Norm_step2/Precision
Center_step1=Center_step1/Precision
Center_step2=Center_step2/Precision
Sigma_step1=Sigma_step1/Precision
Sigma_step2=Sigma_step2/Precision
ENDIF

ITER=ITER+1
PRINT, 'ITERATION N.',strcompress(ITER), '  of',strcompress(ITERATIONS)
ENDWHILE


; OUTPUTS

A1=[NORM1,CENTER1,SIGMA1]
A2=[NORM2,CENTER2,SIGMA2]

EE1=dblarr(3)
EE2=dblarr(3)

EE1[0]=Norm_step1; Norm_step1/2.
EE1[1]=Center_step1; Center_step1/2.
EE1[2]=Sigma_step1; Sigma_step1/2.

EE2[0]=Norm_step2; Norm_step2/2.
EE2[1]=Center_step2; Center_step2/2.
EE2[2]=Sigma_step2; Sigma_step2/2.



END

