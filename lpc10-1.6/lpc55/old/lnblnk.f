************************************************************************
*     
*     LNBLNK
*     
*     Return the index of the last non-blank character in the argument
*     string, or 0 if the string is all blanks or empty.
*     
*     Sun Feb 11 13:28:11 CST 1996
*     Andy Fingerhut (jaf@arl.wustl.edu)
*     
*     This function is called many times in the I/O parts of the LPC-10
*     package.  It is probably in a standard library on the authors's
*     home system.
*     
* $Log: lnblnk.f,v $
* Revision 1.2  1996/02/12 15:06:50  jaf
* Fixed a syntax error.  I really should compile these files _before_
* checking them in, to avoid stupid notes like this one.
*
* Revision 1.1  1996/02/11 19:35:03  jaf
* Initial revision
*
*     
************************************************************************

      function lnblnk(str)
      integer lnblnk
      character*(*) str
      integer i
      logical done

      i = len(str)
      done = .false.
      do while (.not. done)
         if (i .gt. 0) then
            if (str(i:i) .eq. ' ') then
               i = i - 1
            else
               done = .true.
            end if
         else
            done = .true.
         end if
      end do

      lnblnk = i
      end
