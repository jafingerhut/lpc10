**********************************************************************
*
*      VQSETUP Stubs Version 55
*
* $Log: vqsetup.f,v $
* Revision 1.1  1996/02/07  14:50:50  jaf
* Initial revision
*
*
**********************************************************************
*
*  These stubs are referenced by subroutine setup.  They are placeholders
* for vector quantization routines used in the 600-1200 bps coder.
*
	subroutine vqgetcl()
	include 'config.fh'
	include 'contrl.fh'

	call getcl_intr('q', quant, 0, 2400)
	call getcl_intr('order', order, 1, MAXORD)
*	call getcl_intr('fr', lframe, 100, MAXFRM)
	return

	entry vqsetup()
	entry vqdone()
	stop 'VQ bit rates not supported in this version'
	end

	subroutine vqusage()
	include 'contrl.fh'

	write(fmsg,*) '   [-q 0/2400]   - bitstream quantization rate'
	return
	end

	subroutine vqversion(str)
	character*(*) str

	return
	end
