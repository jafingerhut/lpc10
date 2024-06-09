************************************************************************
*
*	SETUP Version 55
*
* $Log: setup.f,v $
* Revision 1.1  1996/02/07  14:49:16  jaf
* Initial revision
*
*
************************************************************************
*
*	Set processing options
*
	subroutine setup()
	include 'config.fh'
	include 'contrl.fh'
	logical usage
	integer lnblnk, ni, no, tarray(3), farray(3), t1, time
	integer spd_open, getcl_prerr
	real etime, t, rarray(2)
	character fdate*24, date*24, fname*80, fname2*80, framefile*40
	character lpcver*4, lpcdat*20, itype*10, otype*10
	data lpcver /'55'/, lpcdat /'20 March 1992'/
	data framefile /'/tmp/lpcsim.frame'/

	call vqversion(lpcver)
	date = fdate()
	order = 10
	lframe = MAXFRM
	corrp = .true.
	fmsg = FSTDERR
	fdebug = 1
	usage = .false.
	listl = 1
	quant = 2400
	nbits = 54
	pbin = 0
	fname = ' '
	fname2 = ' '
	call getcl()
	call vqgetcl
	call getcl_intr('l', listl, -1, 7)
	call getcl_bit('pb', pbin, 1)

	ni = 0
	no = 0
	call getcl_bit('is', ni, 1)
	call getcl_bit('ip', ni, 2)
	call getcl_bit('ib', ni, 4)
	call getcl_bit('os', no, 1)
	call getcl_bit('op', no, 2)
	call getcl_bit('ob', no, 4)

	call getcl_parm(1, fname)
	call getcl_parm(2, fname2)
	if (fname .eq. ' ') usage = .true.
	if (ni .eq. 0) ni = 1
	if (no .ne. 0 .and. fname2 .eq. ' ') usage = .true.
	if (no .eq. 0 .and. fname2 .ne. ' ') no = 1
	if (ni.ne.1 .and. ni.ne.2 .and. ni.ne.4) stop 'bad input options'
	if (no.ne.1 .and. no.ne.2 .and. no.ne.4 .and. no.ne.0)
     1     stop 'bad output options'
	if ((ni.eq.4 .or. no.eq.4) .and. quant.eq.0)
     1     stop 'need quantization rate for bitstream i/o'
*	if (ni .eq. 2) quant = 0

	if (getcl_prerr(fmsg) .ne. 0) usage = .true.

	if (usage) then
	    write(fmsg,1000) ' ', lpcver, lpcdat(1:lnblnk(lpcdat)), date
	    write(fmsg,*) 'Usage: lpcsim ifile ofile'
	    write(fmsg,*) '   [-is/ip/ib]   - input speech/params/bits'
	    write(fmsg,*) '   [-os/op/ob]   - output speech/params/bits'
            write(fmsg,*) '   [-pb]         - binary parameter file'
	    write(fmsg,*) '   [-l #]        - verbosity level (# = 0-6)'
	    write(fmsg,*) '   [-order #]    - LPC order'
*	    write(fmsg,*) '   [-fr #]       - frame size in samples'
	    call vqusage()
	    call exit(1)
	end if

**********************************************************************
*    Initialize i/o, open files
**********************************************************************

	fsi = -1
	fpi = -1
	fbi = -1
	if (fname .eq. '-') then
	    fname = 'stdin'
	    if (ni .eq. 1) fsi =  STDIN
	    if (ni .eq. 2) then
	        fpi = STDIN
	        if (pbin .eq. 0) fpi = FSTDIN
	    end if
	    if (ni .eq. 4) fbi = FSTDIN
	else
	    if (ni .eq. 1) then
	        fsi = spd_open(fname, O_RDONLY)
	    elseif (ni .eq. 2) then
	        if (pbin .eq. 0) then
	            fpi = 3
	            open(unit=fpi, file=fname, status='old')
	        else
	            fpi = spd_open(fname, O_RDONLY)
	        endif
	    elseif (ni .eq. 4) then
	        fbi = 3
	        open(unit=fbi, file=fname, status='old')
	    endif
	endif
	if (pbin .ne. 0) then
	    pbin = 8
	    open(unit=pbin, file=framefile, status='unknown',
     1          form='unformatted', access='direct', recl=4)
	    write(pbin, rec=1) -1
	    call flush(pbin)
	endif

	fso = -1
	fpo = -1
	fbo = -1
	if (fname2 .eq. '-') then
	    fname2 = 'stdout'
	    if (no .eq. 1) fso =  STDOUT
	    if (no .eq. 2) then
	        fpo = STDOUT
	        if (pbin .eq. 0) fpo = FSTDOUT
	    end if
	    if (no .eq. 4) fbo = FSTDOUT
	else
	    if (no .eq. 1) then
	        fso = spd_open(fname2, O_WRONLY)
	    elseif (no .eq. 2) then
	        if (pbin .eq. 0) then
	            fpo = 4
	            open(unit=fpo, file=fname2, status='unknown')
	        else
	            fpo = spd_open(fname2, O_WRONLY)
	        endif
	    elseif (no .eq. 4) then
	        fbo = 4
	        open(unit=fbo, file=fname2, status='unknown')
	    endif
	endif

	nframe = 0
	nunsfm = 0
	iclip = 0
	call itime(farray)
	t1 = time()
	if (listl .ge. 1) then
	    write(fmsg,1000) ' ', lpcver, lpcdat(1:lnblnk(lpcdat)), date
	    if (listl.ge.2) then
	        open(unit=fdebug, file='lpcdata', status='unknown')
	        write(fmsg,*) 'Writing debug data to file "lpcdata"'
	    end if

	    if (fsi.ge.0) itype = 'Speech'
	    if (fpi.ge.0) then
	        itype = 'LPC'
	        if (pbin .ne. 0) itype = 'Binary LPC'
	    end if
	    if (fbi.ge.0) itype = 'Bitstream'
	    write(fmsg,1005) itype(1:lnblnk(itype)), 'Input',
     1                 fname(1:lnblnk(fname))

	    otype = ' '
	    if (fname2 .eq. ' ') fname2 = 'None'
	    if (fso.ge.0) otype = 'Speech'
	    if (fpo.ge.0) then
	        otype = 'LPC'
	        if (pbin .ne. 0) otype = 'Binary LPC'
	    end if
	    if (fbo.ge.0) otype = 'Bitstream'
	    write(fmsg,1005) otype(1:lnblnk(otype)), 'Output',
     1                 fname2(1:lnblnk(fname2))

	    write(fmsg,1004) order, lframe, lframe/8.0

	    if (quant.le.0) then
	        write(fmsg,1006) 'Unquantized'
	    else
	        write(fmsg,1007) quant
	    end if
	end if

	if (quant .gt. 0 .and. quant .lt. 2400) call vqsetup
	return

1000	format(a,'NSA LPC-10 Unix Ver. ', a, ' (', a, ') ',a)
1004	format(' LPC order:', i3, ', Frame size:', i4,
     1         ' samples (', f4.1, ' ms)')
1005	format(1x, a10, a7,' file = ', a)
1006	format(' Parameter Quantization: ', a)
1007	format(' Parameter Quantization: ', i5)

**********************************************************************
*     Print summary and close files
**********************************************************************

	entry wrapup()

	nframe = nframe - 1
	if (quant .gt. 0 .and. quant .lt. 2400) call vqdone
	if(listl.ge.1) then
	   call itime(tarray)
	   t = etime(rarray)
	   t1 = time() - t1
	   write(fmsg,1010) farray, tarray, rarray
1010	   format(3x,'Start: ', i2,':',i2.2,':',i2.2,
     1            3x,'  End: ', i2,':',i2.2,':',i2.2,
     1            3x,'Etime:', f8.2, ' user +', f6.2, ' sys')
	   if (nframe .gt. 0) then
	      write(fmsg,1015) nframe, t, nframe/max(t,.0001),
     1          (8000.*t)/(lframe*nframe)
1015	      format(1x, i6, ' Frames in', f8.2, ' CPU sec,', f6.2,
     1        ' frames/sec,', f6.2, 'x realtime')
	      write(fmsg,1018) t1, 100.*t/max(t1,.0001),
     1           (8000.*t1)/(lframe*nframe)
1018	      format(1x, i6, ' sec wall time,', f6.2, '% CPU utilization,',
     1        f6.2, 'x realtime (wall)')
	   end if
	   write(fmsg,1020) nunsfm, iclip
1020	   format( 1x,'       Number of unstable frames =', i6,/,
     1             1x,'Number of times output saturated =', i6)
	   write(fmsg,1030)
1030	   format( 1x, 72('-'))
	end if
	if (fsi.ge.0) call spd_close(fsi)
	if (fso.ge.0) call spd_close(fso)
	if (pbin .eq. 0) then
	    if (fpi.ge.0) close(fpi)
	    if (fpo.ge.0) close(fpo)
	else
	    if (fpi.ge.0) call spd_close(fpi)
	    if (fpo.ge.0) call spd_close(fpo)
	    close(pbin, status='delete')
	end if
	if (fbi.ge.0) close(fbi)
	if (fbo.ge.0) close(fbo)
	return
	end
