************************************************************************
*
*	LPFILT Version 55
*
* $Log: lpfilt.f,v $
* Revision 1.3  1996/03/15  16:53:49  jaf
* Just put comment header in standard form.
*
* Revision 1.2  1996/03/12  23:58:06  jaf
* Comments added explaining that none of the local variables of this
* subroutine need to be saved from one invocation to the next.
*
* Revision 1.1  1996/02/07 14:47:44  jaf
* Initial revision
*
*
************************************************************************
*
*   31 Point Equiripple FIR Low-Pass Filter
*     Linear phase, delay = 15 samples
*
*	Passband:  ripple = 0.25 dB, cutoff =  800 Hz
*	Stopband:  atten. =  40. dB, cutoff = 1240 Hz
*
* Inputs:
*  LEN    - Length of speech buffers
*  NSAMP  - Number of samples to filter
*  INBUF  - Input speech buffer
*           Indices len-nsamp-29 through len are read.
* Output:
*  LPBUF  - Low passed speech buffer (must be different array than INBUF)
*           Indices len+1-nsamp through len are written.
*
* This subroutine has no local state.
*
	subroutine lpfilt(inbuf, lpbuf, len, nsamp)

*	Arguments

	integer len, nsamp
	real inbuf(len), lpbuf(len)

*	Parameters/constants

	real h0,h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13,h14,h15
	parameter (h0  = -0.0097201988,
     1             h1  = -0.0105179986,
     1             h2  = -0.0083479648,
     1             h3  =  0.0005860774,
     1             h4  =  0.0130892089,
     1             h5  =  0.0217052232,
     1             h6  =  0.0184161253,
     1             h7  =  0.0003397230,
     1             h8  = -0.0260797087,
     1             h9  = -0.0455563702,
     1             h10 = -0.0403068550,
     1             h11 =  0.0005029835,
     1             h12 =  0.0729262903,
     1             h13 =  0.1572008878,
     1             h14 =  0.2247288674,
     1             h15 =  0.2505359650 )

*       Local variables that need not be saved

	integer j
	real t

*       Local state

*       None

	do j = len+1-nsamp,len
	    t =     h0 * (inbuf(j)    + inbuf(j-30))
	    t = t + h1 * (inbuf(j-1)  + inbuf(j-29))
	    t = t + h2 * (inbuf(j-2)  + inbuf(j-28))
	    t = t + h3 * (inbuf(j-3)  + inbuf(j-27))
	    t = t + h4 * (inbuf(j-4)  + inbuf(j-26))
	    t = t + h5 * (inbuf(j-5)  + inbuf(j-25))
	    t = t + h6 * (inbuf(j-6)  + inbuf(j-24))
	    t = t + h7 * (inbuf(j-7)  + inbuf(j-23))
	    t = t + h8 * (inbuf(j-8)  + inbuf(j-22))
	    t = t + h9 * (inbuf(j-9)  + inbuf(j-21))
	    t = t + h10* (inbuf(j-10) + inbuf(j-20))
	    t = t + h11* (inbuf(j-11) + inbuf(j-19))
	    t = t + h12* (inbuf(j-12) + inbuf(j-18))
	    t = t + h13* (inbuf(j-13) + inbuf(j-17))
	    t = t + h14* (inbuf(j-14) + inbuf(j-16))
	    t = t + h15 * inbuf(j-15)
	    lpbuf(j) = t
	end do

	return
	end	
