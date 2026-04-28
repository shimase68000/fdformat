******************************************************
*
*	fd formatter
*
******************************************************

	.include	iocscall.mac
	.include	doscall.mac

********************************************************

NUM_OF_TRACK	.equ	154

********************************************************
*	program entry
********************************************************
start:
	bsr	print_title

	tst.b	(a2)
	bne	print_usage

	bsr	ejectall
	bsr	init_format
	bsr	formatall

	clr.l	-(sp)
	DOS	_KFLUSH
	DOS	_EXIT

********************************************************
*	init. for format
********************************************************
init_format
	lea	drivework(pc),a6
	move.w	#4-1,d7
1:
	move.w	#-1,(a6)+
	dbra	d7,1b

	lea	id_buf-2(pc),a6
	clr.w	(a6)

	rts

********************************************************
*	format all drive
********************************************************
formatall
	pea	mes_default(pc)
	DOS	_PRINT
	addq.l	#4,sp
2:
	pea	mes_nextdrive1(pc)
	DOS	_PRINT
	addq.l	#4,sp

	lea	drivework(pc),a6
	lea	driveno(pc),a5
	move.w	#4-1,d6
1:
	move.w	d6,d0
	eor.w	#%11,d0
	lsl.w	#8,d0
	or.w	#$9070,d0
	move.w	d0,(a5)		* drive no.

	tst.w	(a6)
	bpl	trackformat

	move.w	(a5),d1
	move.w	#0,d2
	IOCS	_B_DRVCHK
	btst.l	#1,d0
	beq	nextdrive

	move.w	#NUM_OF_TRACK-1,(a6)

trackformat
	moveq	#0,d7
	move.w	(a6),d7		* track
	bsr	disk_format
	beq	4f

	clr.w	(a6)		* format error
4:
	subq.w	#1,(a6)
	bpl	nextdrive
	bsr	ejectc

nextdrive
	pea	mes_track(pc)
	DOS	_PRINT
	addq.l	#4,sp

	move.w	(a6),d7
	bsr	print_track

	pea	mes_nextdrive0(pc)
	DOS	_PRINT
	addq.l	#4,sp

	addq.l	#2,a6

	move.w	#0,d1
	IOCS	_BITSNS
	btst.l	#1,d0

	dbne	d6,1b
	beq	2b

	pea	mes_nextdrive0(pc)
3:
	DOS	_PRINT
	dbra	d6,3b

	addq.l	#4,sp
	rts

********************************************************
*	eject current drive
********************************************************
ejectc
	move.w	driveno(pc),d1
	and.w	#$ff00,d1
1:
	IOCS	_B_EJECT

	move.w	#0,d2
	IOCS	_B_DRVCHK
	btst.l	#1,d0
	bne	1b

	rts

********************************************************
*	eject all disk drive
********************************************************
ejectall
	move.w	#4-1,d7
	move.w	#$9000,d1
1:
	IOCS	_B_EJECT
	add.w	#$100,d1
	dbra	d7,1b

	move.w	#4-1,d7
	move.w	#$9000,d1
	move.w	#0,d2
2:
	IOCS	_B_DRVCHK
	btst.l	#1,d0
	dbne	d7,2b
	bne	ejectall

	rts

********************************************************
*	format for 1sector
*		d7.l: track (0..153)
********************************************************
disk_format:
	movem.l	d0-d7/a0-a6,-(sp)

	move.w	driveno(pc),d0	* drive check
	cmp.w	#$9000,d0
	bcs	disk_format_exit

disk_format1
	move.l	d7,d4		* track/side

	lea	id_buf(pc),a0
	move.w	d4,d7
	lsl.w	#7,d7		* track
	move.b	d4,d7
	and.b	#1,d7		* side
	move.b	-1(a0),d3	* start sector
	and.b	#7,d3
	addq.b	#1,d3
	moveq	#8-1,d6		* number of sector
lp2
	move.w	d7,(a0)+
	move.b	d3,(a0)+
	move.b	#3,(a0)+

	addq.b	#1,d3
	cmp.b	#8+1,d3		* cyclick
	bne	lp3
	move.b	#1,d3
lp3
	dbra	d6,lp2

	btst	#0,d7
	beq	disk_format_start

	lea	id_buf-2(pc),a1	 * sector shift
	move.b	1(a1),d0
	add.b	(a1),d0
	move.b	d0,1(a1)

disk_format_start
	move.w	driveno(pc),d1
	move.l	#$030000E5,d2	* const.
	ror.l	#8,d2
	move.w	d7,d2
	rol.l	#8,d2
	move.l	#8*4,d3		* size of id_buf
	lea	id_buf(pc),a1
	IOCS	_B_FORMAT
	and.l	#$C000_0000,d0	* status = normally ?

disk_format_exit
	movem.l	(sp)+,d0-d7/a0-a6
	rts

********************************************************
*	print track (hex)
********************************************************
print_track:
	movem.l	d0-d1,-(sp)

	moveq	#0,d1
	move.b	d7,d1
	lsr.b	#4,d1

	or.b	#$30,d1
	cmp.b	#$3A,d1
	bcs	print_hex_1
	addq.b	#7,d1
print_hex_1
	IOCS	_B_PUTC

	move.b	d7,d1
	and.w	#$F,d1

	or.b	#$30,d1
	cmp.b	#$3A,d1
	bcs	print_hex_2
	addq.b	#7,d1
print_hex_2
	IOCS	_B_PUTC

	movem.l	(sp)+,d0-d1
	rts

********************************************************
*	print message
********************************************************
print_title
	pea	mes_title(pc)
	DOS	_PRINT
	addq.l	#4,sp
	rts
*--------------------------------------------------
print_usage
	pea	mes_usage(pc)
	DOS	_PRINT
	DOS	_EXIT
*-----------------------------------------------------
		.data

mes_title	.dc.b	'FD Format version 0.01 Copyright 1994 UG.',13,10,0
mes_usage	.dc.b	'usage: FDFORMAT',13,10,0
mes_default	.dc.b	'Drive 0: Track $',13,10
		.dc.b	'Drive 1: Track $',13,10
		.dc.b	'Drive 2: Track $',13,10
		.dc.b	'Drive 3: Track $',13,10
		.dc.b	0
mes_track	.dc.b	$1b,'[16C',0
mes_nextdrive0	.dc.b	13,10,0
mes_nextdrive1	.dc.b	11,11,11,11,0

*-----------------------------------------------------

		.bss

drivework	.ds.w	4

driveno		.ds.w	1	* drive no.
slide_sector	.ds.b	1	* sector slide’l (0..7)
start_sector	.ds.b	1	* start sector (0..7)
id_buf		.ds.b	8*4	* formatter work


