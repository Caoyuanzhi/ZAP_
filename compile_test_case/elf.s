
build/arm_test/arm_test.elf:     file format elf32-littlearm


Disassembly of section .text:

00000000 <_Reset>:
        .global test_cond, test_fwd, test_bshift, test_logic, test_adder, test_bshift_reg, test_load
        .global test_store, test_byte, test_cpsr, test_mul, test_ldmstm, test_r15jumps, test_rti
        .global test_clz, test_sat

_Reset:
        b enable_cache
       0:	ea000005 	b	1c <enable_cache>
       4:	00001004 	.word	0x00001004
       8:	00003ffc 	.word	0x00003ffc
       c:	fff00002 	.word	0xfff00002
      10:	00001005 	.word	0x00001005
      14:	7fffffff 	.word	0x7fffffff
      18:	ffffffff 	.word	0xffffffff

0000001c <enable_cache>:
.word 0xffffffff

enable_cache:
   // Enable cache (Uses a single bit to enable both caches).
   .set ENABLE_CP_WORD, 4100
   mov r0, #4
      1c:	e3a00004 	mov	r0, #4
   ldr r1, [r0]
      20:	e5901000 	ldr	r1, [r0]
   mcr p15, 0, r1, c1, c1, 0
      24:	ee011f11 	mcr	15, 0, r1, cr1, cr1, {0}
   
   // Write out identitiy section mapping. Write 16KB to register 2.
   mov r1, #1
      28:	e3a01001 	mov	r1, #1
   mov r1, r1, lsl #14
      2c:	e1a01701 	lsl	r1, r1, #14
   mcr p15, 0, r1, c2, c0, 1
      30:	ee021f30 	mcr	15, 0, r1, cr2, cr0, {1}
   
   // Set domain access control to all 1s.
   mvn r1, #0
      34:	e3e01000 	mvn	r1, #0
   mcr p15, 0, r1, c3, c0, 0
      38:	ee031f10 	mcr	15, 0, r1, cr3, cr0, {0}
   
   // Set up a section desctiptor for identity mapping that is Cachaeable.
   mov r1, #1
      3c:	e3a01001 	mov	r1, #1
   mov r1, r1, lsl #14     // 16KB
      40:	e1a01701 	lsl	r1, r1, #14
   mov r2, #14             // Cacheable identity descriptor.
      44:	e3a0200e 	mov	r2, #14
   str r2, [r1]            // Write identity section desctiptor to 16KB location.
      48:	e5812000 	str	r2, [r1]
   ldr r6, [r1]            // R6 holds the descriptor.
      4c:	e5916000 	ldr	r6, [r1]
   mov r7, r1              // R7 holds the address.
      50:	e1a07001 	mov	r7, r1
   
   // Set up a section descriptor for upper 1MB of virtual address space.
   // This is identity mapping. Uncacheable.
   mov r1, #1
      54:	e3a01001 	mov	r1, #1
   mov r1, r1, lsl #14     // 16KB. This is descriptor 0.
      58:	e1a01701 	lsl	r1, r1, #14
   
   // Go to descriptor 4095. This is the address BASE + (#DESC * 4).
   .set DESCRIPTOR_IO_SECTION_OFFSET, 16380 // 4095 x 4
   mov r0, #8
      5c:	e3a00008 	mov	r0, #8
   ldr r2,[r0]
      60:	e5902000 	ldr	r2, [r0]
   add r1, r1, r2
      64:	e0811002 	add	r1, r1, r2
   
   // Prepare a descriptor. Descriptor = 0xFFF00002 (Uncacheable section descriptor).
   .set DESCRIPTOR_IO_SECTION, 0xFFF00002
   mov r0, #0xC
      68:	e3a0000c 	mov	r0, #12
   ldr r2 ,[r0]
      6c:	e5902000 	ldr	r2, [r0]
   str r2, [r1]
      70:	e5812000 	str	r2, [r1]
   ldr r6, [r1]
      74:	e5916000 	ldr	r6, [r1]
   mov r7, r1
      78:	e1a07001 	mov	r7, r1
   
   // ENABLE MMU
   .set ENABLE_MMU_CP_WORD, 4101
   mov r0, #0x10
      7c:	e3a00010 	mov	r0, #16
   ldr r1, [r0]
      80:	e5901000 	ldr	r1, [r0]
   mcr p15, 0, r1, c1, c1, 0
      84:	ee011f11 	mcr	15, 0, r1, cr1, cr1, {0}

00000088 <disable_cache>:

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

disable_cache:

        msr cpsr, #0x1f         @ Enter SYS mode.
      88:	e329f01f 	msr	CPSR_fc, #31

0000008c <fail_teq>:

// Must check TEQ first.
fail_teq:
        mov r0, #1
      8c:	e3a00001 	mov	r0, #1
        teq r0, #0
      90:	e3300000 	teq	r0, #0
        beq fail_teq
      94:	0afffffc 	beq	8c <fail_teq>
        teq r0, #1
      98:	e3300001 	teq	r0, #1
        bne fail_teq
      9c:	1afffffa 	bne	8c <fail_teq>
        
        bl test_sat
      a0:	eb00004d 	bl	1dc <test_sat>

000000a4 <fail_sat>:

fail_sat:
        teq r0, #0
      a4:	e3300000 	teq	r0, #0
        mov r1, #0
      a8:	e3a01000 	mov	r1, #0
        bne fail_sat
      ac:	1afffffc 	bne	a4 <fail_sat>

        bl test_clz
      b0:	eb0000a3 	bl	344 <test_clz>

000000b4 <fail0>:
fail0:
        teq r0, #0
      b4:	e3300000 	teq	r0, #0
        mov r1, #0
      b8:	e3a01000 	mov	r1, #0
        bne fail0
      bc:	1afffffc 	bne	b4 <fail0>

        bl test_cond
      c0:	eb0000a5 	bl	35c <test_cond>

000000c4 <fail1>:
fail1:
        teq r0, #0
      c4:	e3300000 	teq	r0, #0
        mov r1, #1
      c8:	e3a01001 	mov	r1, #1
        bne fail1
      cc:	1afffffc 	bne	c4 <fail1>

        bl test_fwd
      d0:	eb0000c0 	bl	3d8 <test_fwd>

000000d4 <fail2>:
fail2:
        teq r0, #0
      d4:	e3300000 	teq	r0, #0
        mov r1, #2
      d8:	e3a01002 	mov	r1, #2
        bne fail2
      dc:	1afffffc 	bne	d4 <fail2>

        bl test_bshift
      e0:	eb0000d0 	bl	428 <test_bshift>

000000e4 <fail3>:
fail3:
        teq r0, #0
      e4:	e3300000 	teq	r0, #0
        mov r1, #3
      e8:	e3a01003 	mov	r1, #3
        bne fail3
      ec:	1afffffc 	bne	e4 <fail3>

        bl test_logic
      f0:	eb000112 	bl	540 <test_logic>

000000f4 <fail4>:
fail4:
        teq r0, #0
      f4:	e3300000 	teq	r0, #0
        mov r1, #4
      f8:	e3a01004 	mov	r1, #4
        bne fail4
      fc:	1afffffc 	bne	f4 <fail4>

        bl test_adder
     100:	eb00012e 	bl	5c0 <test_adder>

00000104 <fail5>:
fail5:
        teq r0, #0
     104:	e3300000 	teq	r0, #0
        mov r1, #5
     108:	e3a01005 	mov	r1, #5
        bne fail5
     10c:	1afffffc 	bne	104 <fail5>

        bl test_bshift_reg
     110:	eb00016a 	bl	6c0 <test_bshift_reg>

00000114 <fail6>:
fail6:
        teq r0, #0
     114:	e3300000 	teq	r0, #0
        mov r1, #6
     118:	e3a01006 	mov	r1, #6
        bne fail6
     11c:	1afffffc 	bne	114 <fail6>

        bl test_load
     120:	eb0001c8 	bl	848 <test_load>

00000124 <fail7>:
fail7:
        teq r0, #0
     124:	e3300000 	teq	r0, #0
        mov r1, #7
     128:	e3a01007 	mov	r1, #7
        bne fail7
     12c:	1afffffc 	bne	124 <fail7>

        bl test_store
     130:	eb000228 	bl	9d8 <test_store>

00000134 <fail8>:
fail8:
        teq r0, #0
     134:	e3300000 	teq	r0, #0
        mov r1, #8
     138:	e3a01008 	mov	r1, #8
        bne fail8
     13c:	1afffffc 	bne	134 <fail8>

        bl test_byte
     140:	eb000247 	bl	a64 <test_byte>

00000144 <fail9>:
fail9:
        teq r0, #0
     144:	e3300000 	teq	r0, #0
        mov r1, #9
     148:	e3a01009 	mov	r1, #9
        bne fail9
     14c:	1afffffc 	bne	144 <fail9>

        bl test_cpsr
     150:	eb00025c 	bl	ac8 <test_cpsr>

00000154 <fail10>:
fail10:
        teq r0, #0
     154:	e3300000 	teq	r0, #0
        mov r1, #10
     158:	e3a0100a 	mov	r1, #10
        bne fail10
     15c:	1afffffc 	bne	154 <fail10>

        bl test_mul
     160:	eb0002f8 	bl	d48 <test_mul>

00000164 <fail11>:
fail11:
        teq r0, #0
     164:	e3300000 	teq	r0, #0
        mov r1, #11
     168:	e3a0100b 	mov	r1, #11
        bne fail11
     16c:	1afffffc 	bne	164 <fail11>

        bl test_ldmstm
     170:	eb00032a 	bl	e20 <test_ldmstm>

00000174 <fail12>:
fail12:
        teq r0, #0
     174:	e3300000 	teq	r0, #0
        mov r1, #12
     178:	e3a0100c 	mov	r1, #12
        bne fail12
     17c:	1afffffc 	bne	174 <fail12>

        bl test_r15jumps
     180:	eb000387 	bl	fa4 <test_r15jumps>

00000184 <fail13>:
fail13:
        teq r0, #0
     184:	e3300000 	teq	r0, #0
        mov r12, #13
     188:	e3a0c00d 	mov	ip, #13
        bne fail13
     18c:	1afffffc 	bne	184 <fail13>

        bl test_rti
     190:	eb0003e1 	bl	111c <test_rti>

00000194 <passed>:
passed:
        mvn  r0, #0
     194:	e3e00000 	mvn	r0, #0
        mov  r1, r0
     198:	e1a01000 	mov	r1, r0
        mov  r2, r0
     19c:	e1a02000 	mov	r2, r0
        mov  r3, r0
     1a0:	e1a03000 	mov	r3, r0
        mov  r4, r0
     1a4:	e1a04000 	mov	r4, r0
        mov  r5, r0
     1a8:	e1a05000 	mov	r5, r0
        mov  r6, r0
     1ac:	e1a06000 	mov	r6, r0
        mov  r7, r0
     1b0:	e1a07000 	mov	r7, r0

        mov  r0, #0x18
     1b4:	e3a00018 	mov	r0, #24
        ldr  r8, [r0]
     1b8:	e5908000 	ldr	r8, [r0]
        mov  r9, r8
     1bc:	e1a09008 	mov	r9, r8
        mov r10, r8
     1c0:	e1a0a008 	mov	sl, r8
        mov r11, r8
     1c4:	e1a0b008 	mov	fp, r8
        mov r12, r8
     1c8:	e1a0c008 	mov	ip, r8
        mov r13, r8
     1cc:	e1a0d008 	mov	sp, r8
        mov r14, r8
     1d0:	e1a0e008 	mov	lr, r8
        mvn  r0, #0
     1d4:	e3e00000 	mvn	r0, #0

000001d8 <passed_here>:

passed_here:
        b passed_here
     1d8:	eafffffe 	b	1d8 <passed_here>

000001dc <test_sat>:

        @ test sat
test_sat:
        mov r0, #0x1
     1dc:	e3a00001 	mov	r0, #1
        mov r6, #0x14
     1e0:	e3a06014 	mov	r6, #20
        ldr r6, [r6]
     1e4:	e5966000 	ldr	r6, [r6]

        @ Test 1 - test bit 27 of CPSR is set after QADD.

        mov r1, #0xffffffff
     1e8:	e3e01000 	mvn	r1, #0
        mov r5, #0x80000000
     1ec:	e3a05102 	mov	r5, #-2147483648	; 0x80000000

        qadd r2, r1, r5
     1f0:	e1052051 	qadd	r2, r1, r5
        mrs r3, cpsr
     1f4:	e10f3000 	mrs	r3, CPSR
        and r3, r3, #0x08000000
     1f8:	e2033302 	and	r3, r3, #134217728	; 0x8000000
        teq r3, #0x08000000
     1fc:	e3330302 	teq	r3, #134217728	; 0x8000000
        bne fail
     200:	1a000073 	bne	3d4 <fail>

        add r0, r0, #1
     204:	e2800001 	add	r0, r0, #1

        @ Test 2 - test result of saturating add to be smallest negative number.

        qadd r2, r5, r1
     208:	e1012055 	qadd	r2, r5, r1
        teq r2, #0x80000000
     20c:	e3320102 	teq	r2, #-2147483648	; 0x80000000
        bne fail
     210:	1a00006f 	bne	3d4 <fail>

        add r0, r0, #1
     214:	e2800001 	add	r0, r0, #1

        @ Test 3 - Ensure bit 27 of CPSR remains set after non saturating ADD.

        adds r2, r5, r1
     218:	e0952001 	adds	r2, r5, r1
        mrs r3, cpsr
     21c:	e10f3000 	mrs	r3, CPSR
        and r3, r3, #0x08000000
     220:	e2033302 	and	r3, r3, #134217728	; 0x8000000
        teq r3, #0x08000000
     224:	e3330302 	teq	r3, #134217728	; 0x8000000
        bne fail
     228:	1a000069 	bne	3d4 <fail>

        add r0, r0, #1
     22c:	e2800001 	add	r0, r0, #1

        //////////////////////////////////////////////////////////////////////////

        mov r7, #0
     230:	e3a07000 	mov	r7, #0
        msr cpsr_flg, r7
     234:	e128f007 	msr	CPSR_f, r7

        @ Test 4 - test bit 27 of CPSR is set after QADD

        mov r1, #0x40000000
     238:	e3a01101 	mov	r1, #1073741824	; 0x40000000
        mov r5, #0x40000000
     23c:	e3a05101 	mov	r5, #1073741824	; 0x40000000

        qadd r2, r1, r5
     240:	e1052051 	qadd	r2, r1, r5
        mrs r3, cpsr
     244:	e10f3000 	mrs	r3, CPSR
        and r3, r3, #0x08000000
     248:	e2033302 	and	r3, r3, #134217728	; 0x8000000
        teq r3, #0x08000000
     24c:	e3330302 	teq	r3, #134217728	; 0x8000000
        bne fail
     250:	1a00005f 	bne	3d4 <fail>

        add r0, r0, #1
     254:	e2800001 	add	r0, r0, #1

        @ Test 5 - test result of saturating add to be the largest positive number.

        qadd r2, r5, r1
     258:	e1012055 	qadd	r2, r5, r1
        teq r2, r6
     25c:	e1320006 	teq	r2, r6
        bne fail
     260:	1a00005b 	bne	3d4 <fail>

        add r0, r0, #1
     264:	e2800001 	add	r0, r0, #1

        @ Test 6 - Ensure bit 27 of CPSR remains set after non saturating ADD.

        adds r3, r5, r1
     268:	e0953001 	adds	r3, r5, r1
        mrs r3, cpsr
     26c:	e10f3000 	mrs	r3, CPSR
        and r3, r3, #0x08000000
     270:	e2033302 	and	r3, r3, #134217728	; 0x8000000
        teq r3, #0x08000000
     274:	e3330302 	teq	r3, #134217728	; 0x8000000
        bne fail
     278:	1a000055 	bne	3d4 <fail>

        add r0, r0, #1
     27c:	e2800001 	add	r0, r0, #1

        ////////////////////////////////////////////////////////////////////////////

        msr cpsr_flg, r7
     280:	e128f007 	msr	CPSR_f, r7

        @ Test 7 - test bit 27 of CPSR is set after QSUB

        mov r1, #0x80000000
     284:	e3a01102 	mov	r1, #-2147483648	; 0x80000000
        mov r5, #0x1
     288:	e3a05001 	mov	r5, #1

        qsub r2, r1, r5
     28c:	e1252051 	qsub	r2, r1, r5
        mrs r3, cpsr
     290:	e10f3000 	mrs	r3, CPSR
        and r3, r3, #0x08000000
     294:	e2033302 	and	r3, r3, #134217728	; 0x8000000
        teq r3, #0x08000000
     298:	e3330302 	teq	r3, #134217728	; 0x8000000
        bne fail
     29c:	1a00004c 	bne	3d4 <fail>

        add r0, r0, #1
     2a0:	e2800001 	add	r0, r0, #1

        @ Test 8 - test result of saturating subtract to be the largest positive number.

        qsub r2, r5, r1
     2a4:	e1212055 	qsub	r2, r5, r1
        teq r2, r6
     2a8:	e1320006 	teq	r2, r6
        bne fail
     2ac:	1a000048 	bne	3d4 <fail>

        add r0, r0, #1
     2b0:	e2800001 	add	r0, r0, #1

        @ Test 9 - test result of saturating subtract to be the smallest negative number.

        qsub r2, r1, r5
     2b4:	e1252051 	qsub	r2, r1, r5
        teq r2, #0x80000000
     2b8:	e3320102 	teq	r2, #-2147483648	; 0x80000000
        bne fail
     2bc:	1a000044 	bne	3d4 <fail>

        add r0, r0, #1
     2c0:	e2800001 	add	r0, r0, #1

        @ Test 10 - Ensure bit 27 of CPSR remains set after non saturating SUB.

        subs r2, r5, r1
     2c4:	e0552001 	subs	r2, r5, r1
        mrs r2, cpsr
     2c8:	e10f2000 	mrs	r2, CPSR
        and r2, r2, #0x08000000
     2cc:	e2022302 	and	r2, r2, #134217728	; 0x8000000
        teq r2, #0x08000000
     2d0:	e3320302 	teq	r2, #134217728	; 0x8000000
        bne fail
     2d4:	1a00003e 	bne	3d4 <fail>

        add r0, r0, #1
     2d8:	e2800001 	add	r0, r0, #1

        ///////////////////////////////////////////////////////////////////////////////

        msr cpsr_flg, r7
     2dc:	e128f007 	msr	CPSR_f, r7

        @ Test 11 - test bit 27 of CPSR is set after QSUB

        mov r1, #0x7ffffffe  // MAX - 1
     2e0:	e3e01106 	mvn	r1, #-2147483647	; 0x80000001
        mov r5, #0xfffffffe  // -2
     2e4:	e3e05001 	mvn	r5, #1
        // Result =  MAX - 1 + 2 = MAX + 1 = Saturate to MAX.

        qsub r2, r1, r5
     2e8:	e1252051 	qsub	r2, r1, r5
        mrs r3, cpsr
     2ec:	e10f3000 	mrs	r3, CPSR
        and r3, r3, #0x08000000
     2f0:	e2033302 	and	r3, r3, #134217728	; 0x8000000
        teq r3, #0x08000000
     2f4:	e3330302 	teq	r3, #134217728	; 0x8000000
        bne fail
     2f8:	1a000035 	bne	3d4 <fail>

        add r0, r0, #1
     2fc:	e2800001 	add	r0, r0, #1

        @ Test 12 - test result of saturating subtract to be the smallest -ve number.

        // - 2 - MAX + 1 = - MAX - 1 
        qsub r2, r5, r1
     300:	e1212055 	qsub	r2, r5, r1
        teq r2, #0x80000000
     304:	e3320102 	teq	r2, #-2147483648	; 0x80000000
        bne fail
     308:	1a000031 	bne	3d4 <fail>

        add r0, r0, #1
     30c:	e2800001 	add	r0, r0, #1

        @ Test 13 - test result of saturating subtract to be the largest +ve number.

        qsub r2, r1, r5
     310:	e1252051 	qsub	r2, r1, r5
        teq r2, r6
     314:	e1320006 	teq	r2, r6
        bne fail
     318:	1a00002d 	bne	3d4 <fail>

        add r0, r0, #1
     31c:	e2800001 	add	r0, r0, #1

        @ Test 14 - Ensure bit 27 of CPSR remains set after non saturating SUB.

        subs r2, r5, r1
     320:	e0552001 	subs	r2, r5, r1
        mrs r4, cpsr
     324:	e10f4000 	mrs	r4, CPSR
        and r4, r4, #0x08000000
     328:	e2044302 	and	r4, r4, #134217728	; 0x8000000
        teq r4, #0x08000000
     32c:	e3340302 	teq	r4, #134217728	; 0x8000000
        bne fail
     330:	1a000027 	bne	3d4 <fail>

        add r0, r0, #1
     334:	e2800001 	add	r0, r0, #1

        ///////////////////////////////////////////////////////////////////////////////

        mov r0, #0
     338:	e3a00000 	mov	r0, #0
        msr cpsr_flg, r0        // Clear out flags to keep in sync with the rest of the test program.
     33c:	e128f000 	msr	CPSR_f, r0

        bx lr
     340:	e12fff1e 	bx	lr

00000344 <test_clz>:

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        @ test CLZ
test_clz:
        mov r0, #1
     344:	e3a00001 	mov	r0, #1
        clz r1, r0
     348:	e16f1f10 	clz	r1, r0
        teq r1, #31
     34c:	e331001f 	teq	r1, #31
        bne fail
     350:	1a00001f 	bne	3d4 <fail>
        mov r0, #0
     354:	e3a00000 	mov	r0, #0
        bx lr
     358:	e12fff1e 	bx	lr

0000035c <test_cond>:

        @test N and Z flags conditional execution
test_cond:
        mov r0, #1
     35c:	e3a00001 	mov	r0, #1

        @ test 1 - test that the Z flag is set properly, and N flag clear properly
        movs r5, #0
     360:	e3b05000 	movs	r5, #0
        bne fail
     364:	1a00001a 	bne	3d4 <fail>
        bmi fail
     368:	4a000019 	bmi	3d4 <fail>
        add r0, #1
     36c:	e2800001 	add	r0, r0, #1

        @test 2 - test that an instruction without 'S' does not affect the flags
        movs r5, #1
     370:	e3b05001 	movs	r5, #1
        mov r5, #0
     374:	e3a05000 	mov	r5, #0
        beq fail
     378:	0a000015 	beq	3d4 <fail>
        bmi fail
     37c:	4a000014 	bmi	3d4 <fail>
        add r0, #1
     380:	e2800001 	add	r0, r0, #1

        @test 3 - test that the N flag is set properly
        movs r5, #-2
     384:	e3f05001 	mvns	r5, #1
        mov r5, #0
     388:	e3a05000 	mov	r5, #0
        beq fail
     38c:	0a000010 	beq	3d4 <fail>
        bpl fail
     390:	5a00000f 	bpl	3d4 <fail>
        add r0, #1
     394:	e2800001 	add	r0, r0, #1

        @test4 - make sure conditional MOV are skipped, and that flags are not updated on a skipped instruction
        movs r5, #1
     398:	e3b05001 	movs	r5, #1
        movpls r5, #0   @valid
     39c:	53b05000 	movspl	r5, #0
        movnes r5, #1   @invalid
     3a0:	13b05001 	movsne	r5, #1
        movmis r5, #2   @invalid
     3a4:	43b05002 	movsmi	r5, #2
        bne fail
     3a8:	1a000009 	bne	3d4 <fail>
        cmp r5, #0
     3ac:	e3550000 	cmp	r5, #0
        bne fail
     3b0:	1a000007 	bne	3d4 <fail>
        add r0, #1
     3b4:	e2800001 	add	r0, r0, #1

        @ test 5 - make sure instructions after a branch are skipped completely
        b .dummy
     3b8:	ea000002 	b	3c8 <.dummy>
        movs r5, #-1
     3bc:	e3f05000 	mvns	r5, #0
        movs r5, #-2
     3c0:	e3f05001 	mvns	r5, #1
        movs r5, #-3
     3c4:	e3f05002 	mvns	r5, #2

000003c8 <.dummy>:
.dummy:
        bne fail
     3c8:	1a000001 	bne	3d4 <fail>
        bmi fail
     3cc:	4a000000 	bmi	3d4 <fail>

        @condition test passed
        mov r0, #0
     3d0:	e3a00000 	mov	r0, #0

000003d4 <fail>:
fail:
        bx lr
     3d4:	e12fff1e 	bx	lr

000003d8 <test_fwd>:

test_fwd:
        mov r0, #1
     3d8:	e3a00001 	mov	r0, #1

        @test forwarding and register file for OPA
        mov r1, #1
     3dc:	e3a01001 	mov	r1, #1
        add r1, r1, #1
     3e0:	e2811001 	add	r1, r1, #1
        add r1, r1, #1
     3e4:	e2811001 	add	r1, r1, #1
        add r1, r1, #1
     3e8:	e2811001 	add	r1, r1, #1
        add r1, r1, #1
     3ec:	e2811001 	add	r1, r1, #1
        add r1, r1, #1
     3f0:	e2811001 	add	r1, r1, #1
        cmp r1, #6
     3f4:	e3510006 	cmp	r1, #6
        bne fail
     3f8:	1afffff5 	bne	3d4 <fail>
        add r0, #1
     3fc:	e2800001 	add	r0, r0, #1

        @test forwarding priority for opb
        mov r1, #1
     400:	e3a01001 	mov	r1, #1
        mov r1, #2
     404:	e3a01002 	mov	r1, #2
        mov r1, #3
     408:	e3a01003 	mov	r1, #3
        mov r1, #4
     40c:	e3a01004 	mov	r1, #4
        mov r1, #5
     410:	e3a01005 	mov	r1, #5
        cmp r1, #5
     414:	e3510005 	cmp	r1, #5
        bne fail
     418:	1affffed 	bne	3d4 <fail>
        add r0, #1
     41c:	e2800001 	add	r0, r0, #1

        @forwarding test passed
        mov r0, #0
     420:	e3a00000 	mov	r0, #0
        bx lr
     424:	e12fff1e 	bx	lr

00000428 <test_bshift>:

test_bshift:
        @test barrel shifter all modes (shift by literal const. only for now)
        mov r0, #1
     428:	e3a00001 	mov	r0, #1

        @test 1 - test LSL output
        movs r5, #0xf0000000
     42c:	e3b0520f 	movs	r5, #-268435456	; 0xf0000000
        mov r1, #0x0f
     430:	e3a0100f 	mov	r1, #15
        mov r2, r1, lsl #28
     434:	e1a02e01 	lsl	r2, r1, #28
        cmp r5, r2
     438:	e1550002 	cmp	r5, r2
        bne fail
     43c:	1affffe4 	bne	3d4 <fail>
        add r0, #1
     440:	e2800001 	add	r0, r0, #1

        @test 2 - test ROR output
        mov r3, r1, ror #4
     444:	e1a03261 	ror	r3, r1, #4
        cmp r5, r3
     448:	e1550003 	cmp	r5, r3
        bne fail
     44c:	1affffe0 	bne	3d4 <fail>
        add r0, #1
     450:	e2800001 	add	r0, r0, #1

        @test 3 - test LSR output
        mov r4, r5, lsr #28
     454:	e1a04e25 	lsr	r4, r5, #28
        cmp r4, r1
     458:	e1540001 	cmp	r4, r1
        bne fail
     45c:	1affffdc 	bne	3d4 <fail>
        add r0, #1
     460:	e2800001 	add	r0, r0, #1

        @test 4 - test ASR output
        mov r1, #0x80000000
     464:	e3a01102 	mov	r1, #-2147483648	; 0x80000000
        mov r2, r1, asr #3
     468:	e1a021c1 	asr	r2, r1, #3
        cmp r5 ,r2
     46c:	e1550002 	cmp	r5, r2
        bne fail
     470:	1affffd7 	bne	3d4 <fail>
        add r0, #1
     474:	e2800001 	add	r0, r0, #1

        @test 5 - test RRX output and carry
        mov r1, #1
     478:	e3a01001 	mov	r1, #1
        movs r1, r1, rrx
     47c:	e1b01061 	rrxs	r1, r1
        bcc fail
     480:	3affffd3 	bcc	3d4 <fail>
        movs r1, r1, rrx
     484:	e1b01061 	rrxs	r1, r1
        beq fail
     488:	0affffd1 	beq	3d4 <fail>
        bcs fail
     48c:	2affffd0 	bcs	3d4 <fail>
        add r0, #1
     490:	e2800001 	add	r0, r0, #1

        @test 6 - test carry output from rotated constant
        movs r5, #0xf0000000
     494:	e3b0520f 	movs	r5, #-268435456	; 0xf0000000
        bcc fail
     498:	3affffcd 	bcc	3d4 <fail>
        movs r5, #0xf
     49c:	e3b0500f 	movs	r5, #15
        bcc fail
     4a0:	3affffcb 	bcc	3d4 <fail>
        movs r5, #0x100
     4a4:	e3b05c01 	movs	r5, #256	; 0x100
        bcs fail
     4a8:	2affffc9 	bcs	3d4 <fail>
        add r0, #1
     4ac:	e2800001 	add	r0, r0, #1

        @test 7 - test carry output from LSL
        mov r5, #0x1
     4b0:	e3a05001 	mov	r5, #1
        movs r5, r5, lsl #1
     4b4:	e1b05085 	lsls	r5, r5, #1
        bcs fail
     4b8:	2affffc5 	bcs	3d4 <fail>
        mov r5, #0x80000000
     4bc:	e3a05102 	mov	r5, #-2147483648	; 0x80000000
        movs r5, r5, lsl #1
     4c0:	e1b05085 	lsls	r5, r5, #1
        bcc fail
     4c4:	3affffc2 	bcc	3d4 <fail>
        add r0, #1
     4c8:	e2800001 	add	r0, r0, #1

        @test 8 - test carry output from LSR
        mov r5, #2
     4cc:	e3a05002 	mov	r5, #2
        movs r5, r5, lsr #1
     4d0:	e1b050a5 	lsrs	r5, r5, #1
        bcs fail
     4d4:	2affffbe 	bcs	3d4 <fail>
        movs r5, r5, lsr #1
     4d8:	e1b050a5 	lsrs	r5, r5, #1
        bcc fail
     4dc:	3affffbc 	bcc	3d4 <fail>
        bne fail
     4e0:	1affffbb 	bne	3d4 <fail>
        add r0, #1
     4e4:	e2800001 	add	r0, r0, #1

        @test 9 - test carry output from ASR
        mvn r5, #0x01
     4e8:	e3e05001 	mvn	r5, #1
        movs r5, r5, asr #1
     4ec:	e1b050c5 	asrs	r5, r5, #1
        bcs fail
     4f0:	2affffb7 	bcs	3d4 <fail>
        movs r5, r5, asr #1
     4f4:	e1b050c5 	asrs	r5, r5, #1
        bcc fail
     4f8:	3affffb5 	bcc	3d4 <fail>
        add r0, #1
     4fc:	e2800001 	add	r0, r0, #1

        @test 10 - check for LSR #32 to behave correctly
        mov r1, #0xa5000000
     500:	e3a014a5 	mov	r1, #-1526726656	; 0xa5000000
        mvn r2, r1
     504:	e1e02001 	mvn	r2, r1
        lsrs r3, r1, #32
     508:	e1b03021 	lsrs	r3, r1, #32
        bcc fail
     50c:	3affffb0 	bcc	3d4 <fail>
        lsrs r3, r2, #32
     510:	e1b03022 	lsrs	r3, r2, #32
        bcs fail
     514:	2affffae 	bcs	3d4 <fail>
        add r0, #1
     518:	e2800001 	add	r0, r0, #1

        @test 11 - check for ASR #32 to behave correctly
        asrs r3, r1, #32
     51c:	e1b03041 	asrs	r3, r1, #32
        bcc fail
     520:	3affffab 	bcc	3d4 <fail>
        cmp r3, #-1
     524:	e3730001 	cmn	r3, #1
        bne fail
     528:	1affffa9 	bne	3d4 <fail>
        asrs r3, r2, #32
     52c:	e1b03042 	asrs	r3, r2, #32
        bcs fail
     530:	2affffa7 	bcs	3d4 <fail>
        bne fail
     534:	1affffa6 	bne	3d4 <fail>

        @barrelshift test passed
        mov r0, #0
     538:	e3a00000 	mov	r0, #0
        bx lr
     53c:	e12fff1e 	bx	lr

00000540 <test_logic>:

        @test logical operations
test_logic:
        mov r0, #1
     540:	e3a00001 	mov	r0, #1

        @test 1 - NOT operation
        mov r5, #-1
     544:	e3e05000 	mvn	r5, #0
        mvns r5, r5
     548:	e1f05005 	mvns	r5, r5
        bne fail
     54c:	1affffa0 	bne	3d4 <fail>
        add r0, #1
     550:	e2800001 	add	r0, r0, #1

        @test 2 - AND operation
        mov r5, #0xa0
     554:	e3a050a0 	mov	r5, #160	; 0xa0
        mov r1, #0x0b
     558:	e3a0100b 	mov	r1, #11
        mov r2, #0xab
     55c:	e3a020ab 	mov	r2, #171	; 0xab
        mov r3, #0xba
     560:	e3a030ba 	mov	r3, #186	; 0xba

        ands r4, r5, r1
     564:	e0154001 	ands	r4, r5, r1
        bne fail
     568:	1affff99 	bne	3d4 <fail>
        ands r4, r5, r2
     56c:	e0154002 	ands	r4, r5, r2
        cmp r4, r5
     570:	e1540005 	cmp	r4, r5
        bne fail
     574:	1affff96 	bne	3d4 <fail>
        add r0, #1
     578:	e2800001 	add	r0, r0, #1

        @test 3 - ORR and EOR operations
        orr r4, r5, r1
     57c:	e1854001 	orr	r4, r5, r1
        eors r4, r2, r4
     580:	e0324004 	eors	r4, r2, r4
        bne fail
     584:	1affff92 	bne	3d4 <fail>
        orr r4, r1, r5
     588:	e1814005 	orr	r4, r1, r5
        teq     r4, r2
     58c:	e1340002 	teq	r4, r2
        bne fail
     590:	1affff8f 	bne	3d4 <fail>
        add r0, #1
     594:	e2800001 	add	r0, r0, #1

        @test 4 - TST opcode
        tst r1, r5
     598:	e1110005 	tst	r1, r5
        bne fail
     59c:	1affff8c 	bne	3d4 <fail>
        tst r4, r2
     5a0:	e1140002 	tst	r4, r2
        beq fail
     5a4:	0affff8a 	beq	3d4 <fail>
        add r0, #1
     5a8:	e2800001 	add	r0, r0, #1

        @test 5 - BIC opcode
        bics r4, r2, r3
     5ac:	e1d24003 	bics	r4, r2, r3
        cmp r4, #1
     5b0:	e3540001 	cmp	r4, #1
        bne fail
     5b4:	1affff86 	bne	3d4 <fail>

        @logical test passed
        mov r0, #0
     5b8:	e3a00000 	mov	r0, #0
        bx lr
     5bc:	e12fff1e 	bx	lr

000005c0 <test_adder>:

        @test adder, substracter, C and V flags
test_adder:
        mov r0, #1
     5c0:	e3a00001 	mov	r0, #1

        @test 1 - check for carry when adding
        mov r5, #0xf0000000
     5c4:	e3a0520f 	mov	r5, #-268435456	; 0xf0000000
        mvn r1, r5                      @0x0fffffff
     5c8:	e1e01005 	mvn	r1, r5
        adds r2, r1, r5
     5cc:	e0912005 	adds	r2, r1, r5
        bcs fail
     5d0:	2affff7f 	bcs	3d4 <fail>
        bvs fail
     5d4:	6affff7e 	bvs	3d4 <fail>

        adds r2, #1
     5d8:	e2922001 	adds	r2, r2, #1
        bcc fail
     5dc:	3affff7c 	bcc	3d4 <fail>
        bvs fail
     5e0:	6affff7b 	bvs	3d4 <fail>

        adc r2, #120
     5e4:	e2a22078 	adc	r2, r2, #120	; 0x78
        cmp r2, #121
     5e8:	e3520079 	cmp	r2, #121	; 0x79
        bne fail
     5ec:	1affff78 	bne	3d4 <fail>
        bvs fail
     5f0:	6affff77 	bvs	3d4 <fail>
        add r0, #1
     5f4:	e2800001 	add	r0, r0, #1

        @test 2 - check for overflow when adding
        mov r3, #0x8fffffff             @two large negative numbers become positive
     5f8:	e3e03207 	mvn	r3, #1879048192	; 0x70000000
        adds r3, r5
     5fc:	e0933005 	adds	r3, r3, r5
        bvc fail
     600:	7affff73 	bvc	3d4 <fail>
        bcc fail
     604:	3affff72 	bcc	3d4 <fail>
        bmi fail
     608:	4affff71 	bmi	3d4 <fail>

        mov r3, #0x10000000
     60c:	e3a03201 	mov	r3, #268435456	; 0x10000000
        adds r3, r1                             @r3 = 0x1fffffff
     610:	e0933001 	adds	r3, r3, r1
        bvs fail
     614:	6affff6e 	bvs	3d4 <fail>
        bcs fail
     618:	2affff6d 	bcs	3d4 <fail>

        adds r3, #0x60000001    @two large positive numbers become negative
     61c:	e2933216 	adds	r3, r3, #1610612737	; 0x60000001
        bvc fail
     620:	7affff6b 	bvc	3d4 <fail>
        bpl fail
     624:	5affff6a 	bpl	3d4 <fail>

        add r0, #1
     628:	e2800001 	add	r0, r0, #1

        @test 3 - check for carry when substracting
        mov r5, #0x10000000
     62c:	e3a05201 	mov	r5, #268435456	; 0x10000000
        subs r2, r5, r1
     630:	e0552001 	subs	r2, r5, r1
        bcc fail
     634:	3affff66 	bcc	3d4 <fail>
        bvs fail
     638:	6affff65 	bvs	3d4 <fail>

        subs r2, #1
     63c:	e2522001 	subs	r2, r2, #1
        bcc fail
     640:	3affff63 	bcc	3d4 <fail>
        bvs fail
     644:	6affff62 	bvs	3d4 <fail>

        subs r2, #1
     648:	e2522001 	subs	r2, r2, #1
        bcs fail
     64c:	2affff60 	bcs	3d4 <fail>
        bvs fail
     650:	6affff5f 	bvs	3d4 <fail>

        add r0, #1
     654:	e2800001 	add	r0, r0, #1

        @test 4 - check for overflow when substracting
        mov r3, #0x90000000
     658:	e3a03209 	mov	r3, #-1879048192	; 0x90000000
        subs r3, r5
     65c:	e0533005 	subs	r3, r3, r5
        bvs fail
     660:	6affff5b 	bvs	3d4 <fail>
        bcc fail
     664:	3affff5a 	bcc	3d4 <fail>

        subs r3, #1             @substract a positive num from a large negative make the result positive
     668:	e2533001 	subs	r3, r3, #1
        bvc fail
     66c:	7affff58 	bvc	3d4 <fail>
        bcc fail
     670:	3affff57 	bcc	3d4 <fail>

        @test 5 - check for carry when reverse substracting
        mov r3, #1
     674:	e3a03001 	mov	r3, #1
        rsbs r2, r1, r5
     678:	e0712005 	rsbs	r2, r1, r5
        bcc fail
     67c:	3affff54 	bcc	3d4 <fail>
        bvs fail
     680:	6affff53 	bvs	3d4 <fail>
        rsbs r2, r3, r2
     684:	e0732002 	rsbs	r2, r3, r2
        bcc fail
     688:	3affff51 	bcc	3d4 <fail>
        bvs fail
     68c:	6affff50 	bvs	3d4 <fail>
        rscs r2, r3, r2
     690:	e0f32002 	rscs	r2, r3, r2
        bcs fail
     694:	2affff4e 	bcs	3d4 <fail>
        bvs fail
     698:	6affff4d 	bvs	3d4 <fail>

        add r0, #1
     69c:	e2800001 	add	r0, r0, #1

        @test 6 - check for overflow when reverse substracting
        mov r2, #0x80000000
     6a0:	e3a02102 	mov	r2, #-2147483648	; 0x80000000
        mov r1, #-1
     6a4:	e3e01000 	mvn	r1, #0
        rsbs r2, r1
     6a8:	e0722001 	rsbs	r2, r2, r1
        bvs fail
     6ac:	6affff48 	bvs	3d4 <fail>
        bmi fail
     6b0:	4affff47 	bmi	3d4 <fail>
        bcc fail
     6b4:	3affff46 	bcc	3d4 <fail>

        mov r0, #0
     6b8:	e3a00000 	mov	r0, #0
        bx lr
     6bc:	e12fff1e 	bx	lr

000006c0 <test_bshift_reg>:

@test barrelshift with register controler rotates
test_bshift_reg:
        mov r0, #1
     6c0:	e3a00001 	mov	r0, #1

        mov r1, #0
     6c4:	e3a01000 	mov	r1, #0
        mov r2, #7
     6c8:	e3a02007 	mov	r2, #7
        mov r3, #32
     6cc:	e3a03020 	mov	r3, #32
        mov r4, #33
     6d0:	e3a04021 	mov	r4, #33	; 0x21
        mov r5, #127
     6d4:	e3a0507f 	mov	r5, #127	; 0x7f
        mov r6, #256
     6d8:	e3a06c01 	mov	r6, #256	; 0x100
        add r7, r6, #7
     6dc:	e2867007 	add	r7, r6, #7
        mov r8, #0xff000000
     6e0:	e3a084ff 	mov	r8, #-16777216	; 0xff000000

        @test 1 LSL mode with register shift
        movs r9, r8, lsl r2
     6e4:	e1b09218 	lsls	r9, r8, r2
        bpl fail
     6e8:	5affff39 	bpl	3d4 <fail>
        bcc fail
     6ec:	3affff38 	bcc	3d4 <fail>
        @make sure lsl #0 does not affect carry
        movs r9, r2, lsl r1
     6f0:	e1b09112 	lsls	r9, r2, r1
        bcc fail
     6f4:	3affff36 	bcc	3d4 <fail>
        @test using the same register twice
        mov r9, r2, lsl r2
     6f8:	e1a09212 	lsl	r9, r2, r2
        cmp r9, #0x380
     6fc:	e3590d0e 	cmp	r9, #896	; 0x380
        bne fail
     700:	1affff33 	bne	3d4 <fail>

        add r0, #1
     704:	e2800001 	add	r0, r0, #1

        @test 2 - LSL mode with barrelshift > 31
        movs r9, r2, lsl r3
     708:	e1b09312 	lsls	r9, r2, r3
        bcc fail
     70c:	3affff30 	bcc	3d4 <fail>
        bne fail
     710:	1affff2f 	bne	3d4 <fail>
        movs r9, r2, lsl r4
     714:	e1b09412 	lsls	r9, r2, r4
        bcs fail
     718:	2affff2d 	bcs	3d4 <fail>
        bne fail
     71c:	1affff2c 	bne	3d4 <fail>
        add r0, #1
     720:	e2800001 	add	r0, r0, #1

        @test 3 - LSL mode with barrelshift >= 256 (only 8 bits used)
        movs r9, r2, lsl r6
     724:	e1b09612 	lsls	r9, r2, r6
        bcs fail
     728:	2affff29 	bcs	3d4 <fail>
        cmp r9, #7
     72c:	e3590007 	cmp	r9, #7
        bne fail
     730:	1affff27 	bne	3d4 <fail>

        mov r9, r2, lsl r7
     734:	e1a09712 	lsl	r9, r2, r7
        cmp r9, #0x380
     738:	e3590d0e 	cmp	r9, #896	; 0x380
        bne fail
     73c:	1affff24 	bne	3d4 <fail>

        movs r9, r8, lsl r7
     740:	e1b09718 	lsls	r9, r8, r7
        bpl fail
     744:	5affff22 	bpl	3d4 <fail>
        bcc fail
     748:	3affff21 	bcc	3d4 <fail>

        add r0, #1
     74c:	e2800001 	add	r0, r0, #1

        @test 4 - LSR mode with register shift
        mov r2, #4
     750:	e3a02004 	mov	r2, #4
        add r7, r6, #4
     754:	e2867004 	add	r7, r6, #4

        movs r9, r8, lsr r2
     758:	e1b09238 	lsrs	r9, r8, r2
        bmi fail
     75c:	4affff1c 	bmi	3d4 <fail>
        bcs fail
     760:	2affff1b 	bcs	3d4 <fail>
        @make sure lsr #0 does not affect carry
        movs r9, r2, lsr r1
     764:	e1b09132 	lsrs	r9, r2, r1
        bcs fail
     768:	2affff19 	bcs	3d4 <fail>
        cmp r9, #4
     76c:	e3590004 	cmp	r9, #4
        bne fail
     770:	1affff17 	bne	3d4 <fail>

        movs r9, r8, lsr r2
     774:	e1b09238 	lsrs	r9, r8, r2
        bcs fail
     778:	2affff15 	bcs	3d4 <fail>
        cmp r9, #0xff00000
     77c:	e35906ff 	cmp	r9, #267386880	; 0xff00000
        bne fail
     780:	1affff13 	bne	3d4 <fail>

        add r0, #1
     784:	e2800001 	add	r0, r0, #1

        @test 5 - LSR mode with barrelshift > 31
        movs r9, r8, lsr r3
     788:	e1b09338 	lsrs	r9, r8, r3
        bcc fail
     78c:	3affff10 	bcc	3d4 <fail>
        bne fail
     790:	1affff0f 	bne	3d4 <fail>
        movs r9, r8, lsr r4
     794:	e1b09438 	lsrs	r9, r8, r4
        bcs fail
     798:	2affff0d 	bcs	3d4 <fail>
        bne fail
     79c:	1affff0c 	bne	3d4 <fail>
        add r0, #1
     7a0:	e2800001 	add	r0, r0, #1

        @test 6 - LSR mode with barrelshift >= 256 (only 8 bits used)
        movs r9, r8, lsr r6
     7a4:	e1b09638 	lsrs	r9, r8, r6
        bcs fail
     7a8:	2affff09 	bcs	3d4 <fail>
        cmp r9, #0xff000000
     7ac:	e35904ff 	cmp	r9, #-16777216	; 0xff000000
        bne fail
     7b0:	1affff07 	bne	3d4 <fail>

        movs r9, r8, lsr r7
     7b4:	e1b09738 	lsrs	r9, r8, r7
        cmp r9, #0xff00000
     7b8:	e35906ff 	cmp	r9, #267386880	; 0xff00000
        bne fail
     7bc:	1affff04 	bne	3d4 <fail>

        mov r0, #0
     7c0:	e3a00000 	mov	r0, #0
        bx lr
     7c4:	e12fff1e 	bx	lr

000007c8 <array>:
     7c8:	00000000 	.word	0x00000000
     7cc:	00000001 	.word	0x00000001
     7d0:	00000002 	.word	0x00000002
     7d4:	00000003 	.word	0x00000003
     7d8:	00000004 	.word	0x00000004
     7dc:	00000005 	.word	0x00000005
     7e0:	00000006 	.word	0x00000006
     7e4:	00000007 	.word	0x00000007
     7e8:	00000008 	.word	0x00000008
     7ec:	00000009 	.word	0x00000009
     7f0:	0000000a 	.word	0x0000000a
     7f4:	0000000b 	.word	0x0000000b
     7f8:	0000000c 	.word	0x0000000c
     7fc:	0000000d 	.word	0x0000000d
     800:	0000000e 	.word	0x0000000e
     804:	0000000f 	.word	0x0000000f

00000808 <array2>:
     808:	00000010 	.word	0x00000010
     80c:	00000011 	.word	0x00000011
     810:	00000012 	.word	0x00000012
     814:	00000013 	.word	0x00000013
     818:	00000014 	.word	0x00000014
     81c:	00000015 	.word	0x00000015
     820:	00000016 	.word	0x00000016
     824:	00000017 	.word	0x00000017
     828:	00000018 	.word	0x00000018
     82c:	00000019 	.word	0x00000019
     830:	0000001a 	.word	0x0000001a
     834:	0000001b 	.word	0x0000001b
     838:	0000001c 	.word	0x0000001c
     83c:	0000001d 	.word	0x0000001d
     840:	0000001e 	.word	0x0000001e
     844:	0000001f 	.word	0x0000001f

00000848 <test_load>:
        .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
array2:
        .word 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
        
test_load:
        mov r0, #1
     848:	e3a00001 	mov	r0, #1

        @ Test1 basic load operations
        ldr r1, .larray1
     84c:	e59f117c 	ldr	r1, [pc, #380]	; 9d0 <.larray1>
        ldr r2, .larray2
     850:	e59f217c 	ldr	r2, [pc, #380]	; 9d4 <.larray2>

        ldr r3, [r1]
     854:	e5913000 	ldr	r3, [r1]
        teq r3, #0
     858:	e3330000 	teq	r3, #0
        bne fail
     85c:	1afffedc 	bne	3d4 <fail>

        ldr r3, [r2]
     860:	e5923000 	ldr	r3, [r2]
        teq r3, #16
     864:	e3330010 	teq	r3, #16
        bne fail
     868:	1afffed9 	bne	3d4 <fail>
        add r0, #1
     86c:	e2800001 	add	r0, r0, #1

        @ Test 2 load operations with offsets
        ldr r3, [r2, #-60]
     870:	e512303c 	ldr	r3, [r2, #-60]	; 0xffffffc4
        teq r3, #1
     874:	e3330001 	teq	r3, #1
        bne fail
     878:	1afffed5 	bne	3d4 <fail>

        ldr r3, [r1, #20]
     87c:	e5913014 	ldr	r3, [r1, #20]
        teq r3, #5
     880:	e3330005 	teq	r3, #5
        bne fail
     884:	1afffed2 	bne	3d4 <fail>
        add r0, #1
     888:	e2800001 	add	r0, r0, #1

        ldr r3, [r1, #20]
     88c:	e5913014 	ldr	r3, [r1, #20]
        mov r3, #0
     890:	e3a03000 	mov	r3, #0
        teq r3, #0
     894:	e3330000 	teq	r3, #0
        bne fail
     898:	1afffecd 	bne	3d4 <fail>
        add r0, #1
     89c:	e2800001 	add	r0, r0, #1

        @ Test 3 - test positive register offset addressing
        mov r3, #124
     8a0:	e3a0307c 	mov	r3, #124	; 0x7c

000008a4 <.lloop>:
.lloop:
        ldr r4, [r1, r3]
     8a4:	e7914003 	ldr	r4, [r1, r3]
        cmp r4, r3, lsr #2
     8a8:	e1540123 	cmp	r4, r3, lsr #2
        bne fail
     8ac:	1afffec8 	bne	3d4 <fail>
        subs r3, #4
     8b0:	e2533004 	subs	r3, r3, #4
        bpl .lloop
     8b4:	5afffffa 	bpl	8a4 <.lloop>
        add r0, #1
     8b8:	e2800001 	add	r0, r0, #1

        @ Test 4 - test negative register offset addressing
        mov r3, #64
     8bc:	e3a03040 	mov	r3, #64	; 0x40

000008c0 <.lloop2>:
.lloop2:
        ldr r4, [r2, -r3]
     8c0:	e7124003 	ldr	r4, [r2, -r3]
        rsb r4, #0x10
     8c4:	e2644010 	rsb	r4, r4, #16
        cmp r4, r3, lsr #2
     8c8:	e1540123 	cmp	r4, r3, lsr #2
        bne fail
     8cc:	1afffec0 	bne	3d4 <fail>
        subs r3, #4
     8d0:	e2533004 	subs	r3, r3, #4
        bne .lloop2
     8d4:	1afffff9 	bne	8c0 <.lloop2>
        add r0, #1
     8d8:	e2800001 	add	r0, r0, #1

        @ Test 5 - test positive register offset addressing with shift
        mov r3, #0
     8dc:	e3a03000 	mov	r3, #0

000008e0 <.lloop3>:
.lloop3:
        ldr r4, [r1, r3, lsl #2]
     8e0:	e7914103 	ldr	r4, [r1, r3, lsl #2]
        cmp r4, r3
     8e4:	e1540003 	cmp	r4, r3
        bne fail
     8e8:	1afffeb9 	bne	3d4 <fail>
        add r3, #1
     8ec:	e2833001 	add	r3, r3, #1
        cmp r3, #32
     8f0:	e3530020 	cmp	r3, #32
        bne .lloop3
     8f4:	1afffff9 	bne	8e0 <.lloop3>
        add r0, #1
     8f8:	e2800001 	add	r0, r0, #1

        @ Test 6 - test negative register offset addressing with shift
        mov r3, #0
     8fc:	e3a03000 	mov	r3, #0

00000900 <.lloop4>:
.lloop4:
        ldr r4, [r2, -r3, lsl #2]
     900:	e7124103 	ldr	r4, [r2, -r3, lsl #2]
        rsb r4, #0x10
     904:	e2644010 	rsb	r4, r4, #16
        cmp r4, r3
     908:	e1540003 	cmp	r4, r3
        bne fail
     90c:	1afffeb0 	bne	3d4 <fail>
        add r3, #1
     910:	e2833001 	add	r3, r3, #1
        cmp r3, #16
     914:	e3530010 	cmp	r3, #16
        bne .lloop4
     918:	1afffff8 	bne	900 <.lloop4>
        add r0, #1
     91c:	e2800001 	add	r0, r0, #1

        @ Test 7 - test offset with pre-increment
        mov r3, #31
     920:	e3a0301f 	mov	r3, #31
        mov r5, r1
     924:	e1a05001 	mov	r5, r1

00000928 <.lloop5>:
.lloop5:
        ldr r4, [r5, #4]!
     928:	e5b54004 	ldr	r4, [r5, #4]!
        rsb r4, #32
     92c:	e2644020 	rsb	r4, r4, #32
        cmp r4, r3
     930:	e1540003 	cmp	r4, r3
        bne fail
     934:	1afffea6 	bne	3d4 <fail>
        subs r3, #1
     938:	e2533001 	subs	r3, r3, #1
        bne .lloop5
     93c:	1afffff9 	bne	928 <.lloop5>
        add r0, #1
     940:	e2800001 	add	r0, r0, #1

        @ Test 8 - test offset with pre-degrement
        mov r3, #31
     944:	e3a0301f 	mov	r3, #31
        add r5, r1, #128
     948:	e2815080 	add	r5, r1, #128	; 0x80

0000094c <.lloop6>:
.lloop6:
        ldr r4, [r5, #-4]!
     94c:	e5354004 	ldr	r4, [r5, #-4]!
        cmp r4, r3
     950:	e1540003 	cmp	r4, r3
        bne fail
     954:	1afffe9e 	bne	3d4 <fail>
        subs r3, #1
     958:	e2533001 	subs	r3, r3, #1
        bpl .lloop6
     95c:	5afffffa 	bpl	94c <.lloop6>
        add r0, #1
     960:	e2800001 	add	r0, r0, #1

        @ Test 9 - test offset with post-increment
        mov r3, #32
     964:	e3a03020 	mov	r3, #32
        mov r5, r1
     968:	e1a05001 	mov	r5, r1

0000096c <.lloop7>:
.lloop7:
        ldr r4, [r5], #4
     96c:	e4954004 	ldr	r4, [r5], #4
        rsb r4, #32
     970:	e2644020 	rsb	r4, r4, #32
        cmp r4, r3
     974:	e1540003 	cmp	r4, r3
        bne fail
     978:	1afffe95 	bne	3d4 <fail>
        subs r3, #1
     97c:	e2533001 	subs	r3, r3, #1
        bne .lloop7
     980:	1afffff9 	bne	96c <.lloop7>
        add r0, #1
     984:	e2800001 	add	r0, r0, #1

        @ Test 10 - test offset with post-decrement
        mov r3, #31
     988:	e3a0301f 	mov	r3, #31
        add r5, r1, #124
     98c:	e281507c 	add	r5, r1, #124	; 0x7c

00000990 <.lloop8>:
.lloop8:
        ldr r4, [r5], #-4
     990:	e4154004 	ldr	r4, [r5], #-4
        cmp r3, r4
     994:	e1530004 	cmp	r3, r4
        bne fail
     998:	1afffe8d 	bne	3d4 <fail>
        subs r3, #1
     99c:	e2533001 	subs	r3, r3, #1
        bpl .lloop8
     9a0:	5afffffa 	bpl	990 <.lloop8>
        add r0, #1
     9a4:	e2800001 	add	r0, r0, #1

        @ Test 11 - test register post-increment with a negative value
        mov r6, #0xfffffff0
     9a8:	e3e0600f 	mvn	r6, #15
        mov r5, r2
     9ac:	e1a05002 	mov	r5, r2
        mov r3, #16
     9b0:	e3a03010 	mov	r3, #16

000009b4 <.lloop9>:
.lloop9:
        ldr r4, [r5], r6, asr #2
     9b4:	e6954146 	ldr	r4, [r5], r6, asr #2
        cmp r4, r3
     9b8:	e1540003 	cmp	r4, r3
        bne fail
     9bc:	1afffe84 	bne	3d4 <fail>
        subs r3, #1
     9c0:	e2533001 	subs	r3, r3, #1
        bpl .lloop9
     9c4:	5afffffa 	bpl	9b4 <.lloop9>

        mov r0, #0
     9c8:	e3a00000 	mov	r0, #0
        bx lr
     9cc:	e12fff1e 	bx	lr

000009d0 <.larray1>:
     9d0:	000007c8 	.word	0x000007c8

000009d4 <.larray2>:
     9d4:	00000808 	.word	0x00000808

000009d8 <test_store>:
        .word array
.larray2:
        .word array2

test_store:
        mov r0, #1
     9d8:	e3a00001 	mov	r0, #1

        @ Test 1 - test basic store opperation
        ldr r1, .larray1
     9dc:	e51f1014 	ldr	r1, [pc, #-20]	; 9d0 <.larray1>
        mov r2, #0x24
     9e0:	e3a02024 	mov	r2, #36	; 0x24
        str r2, [r1]
     9e4:	e5812000 	str	r2, [r1]
        ldr r2, [r1]
     9e8:	e5912000 	ldr	r2, [r1]
        cmp r2, #0x24
     9ec:	e3520024 	cmp	r2, #36	; 0x24
        bne fail
     9f0:	1afffe77 	bne	3d4 <fail>
        add r0, #1
     9f4:	e2800001 	add	r0, r0, #1

        @ Test 2 - check for post-increment and pre-decrement writes
        mov r2, #0xab
     9f8:	e3a020ab 	mov	r2, #171	; 0xab
        mov r3, #0xbc
     9fc:	e3a030bc 	mov	r3, #188	; 0xbc
        str r2, [r1, #4]!               @ array[1] = 0xab
     a00:	e5a12004 	str	r2, [r1, #4]!
        str r3, [r1], #4                @ array[1] = 0xbc
     a04:	e4813004 	str	r3, [r1], #4
        ldr r2, [r1, #-4]!              @ read 0xbc
     a08:	e5312004 	ldr	r2, [r1, #-4]!
        ldr r3, [r1, #-4]!              @ read 0x24
     a0c:	e5313004 	ldr	r3, [r1, #-4]!
        cmp r3, #0x24
     a10:	e3530024 	cmp	r3, #36	; 0x24
        bne fail
     a14:	1afffe6e 	bne	3d4 <fail>
        cmp r2, #0xbc
     a18:	e35200bc 	cmp	r2, #188	; 0xbc
        bne fail
     a1c:	1afffe6c 	bne	3d4 <fail>
        add r0, #1
     a20:	e2800001 	add	r0, r0, #1

        @ Test 3 - check for register post-increment addressing
        mov r2, #8
     a24:	e3a02008 	mov	r2, #8
        mov r3, #20
     a28:	e3a03014 	mov	r3, #20
        mov r4, r1
     a2c:	e1a04001 	mov	r4, r1
        str r2, [r4], r2
     a30:	e6842002 	str	r2, [r4], r2
        str r3, [r4], r2
     a34:	e6843002 	str	r3, [r4], r2
        sub r4, #16
     a38:	e2444010 	sub	r4, r4, #16
        cmp r4, r1
     a3c:	e1540001 	cmp	r4, r1
        bne fail
     a40:	1afffe63 	bne	3d4 <fail>
        ldr r2, [r1]
     a44:	e5912000 	ldr	r2, [r1]
        cmp r2, #8
     a48:	e3520008 	cmp	r2, #8
        bne fail
     a4c:	1afffe60 	bne	3d4 <fail>
        ldr r2, [r1, #8]
     a50:	e5912008 	ldr	r2, [r1, #8]
        cmp r2, #20
     a54:	e3520014 	cmp	r2, #20
        bne fail
     a58:	1afffe5d 	bne	3d4 <fail>

        mov r0, #0
     a5c:	e3a00000 	mov	r0, #0
        bx lr
     a60:	e12fff1e 	bx	lr

00000a64 <test_byte>:

        @ Tests byte loads and store
test_byte:
        mov r0, #1
     a64:	e3a00001 	mov	r0, #1

        @ test 1 - test store bytes
        ldr r1, .larray1
     a68:	e51f10a0 	ldr	r1, [pc, #-160]	; 9d0 <.larray1>
        mov r2, #8
     a6c:	e3a02008 	mov	r2, #8

00000a70 <.bloop>:
.bloop:
        strb r2, [r1], #1
     a70:	e4c12001 	strb	r2, [r1], #1
        subs r2, #1
     a74:	e2522001 	subs	r2, r2, #1
        bne .bloop
     a78:	1afffffc 	bne	a70 <.bloop>

        ldr r2, .ref_words+4
     a7c:	e59f2040 	ldr	r2, [pc, #64]	; ac4 <.ref_words+0x4>
        ldr r3, [r1, #-4]!
     a80:	e5313004 	ldr	r3, [r1, #-4]!
        cmp r2, r3
     a84:	e1520003 	cmp	r2, r3
        bne fail
     a88:	1afffe51 	bne	3d4 <fail>

        ldr r2, .ref_words
     a8c:	e59f202c 	ldr	r2, [pc, #44]	; ac0 <.ref_words>
        ldr r3, [r1, #-4]!
     a90:	e5313004 	ldr	r3, [r1, #-4]!
        cmp r2, r3
     a94:	e1520003 	cmp	r2, r3
        bne fail
     a98:	1afffe4d 	bne	3d4 <fail>
        add r0, #1
     a9c:	e2800001 	add	r0, r0, #1

        @ test 2 - test load bytes
        mov r2, #8
     aa0:	e3a02008 	mov	r2, #8

00000aa4 <.bloop2>:
.bloop2:
        ldrb r3, [r1], #1
     aa4:	e4d13001 	ldrb	r3, [r1], #1
        cmp r3, r2
     aa8:	e1530002 	cmp	r3, r2
        bne fail
     aac:	1afffe48 	bne	3d4 <fail>
        subs r2, #1
     ab0:	e2522001 	subs	r2, r2, #1
        bne .bloop2
     ab4:	1afffffa 	bne	aa4 <.bloop2>

        mov r0, #0
     ab8:	e3a00000 	mov	r0, #0
        bx lr
     abc:	e12fff1e 	bx	lr

00000ac0 <.ref_words>:
     ac0:	05060708 	.word	0x05060708
     ac4:	01020304 	.word	0x01020304

00000ac8 <test_cpsr>:

        @ Good source for flags info :
        @ http://blogs.arm.com/software-enablement/206-condition-codes-1-condition-flags-and-codes/

test_cpsr:
        mov r0, #1
     ac8:	e3a00001 	mov	r0, #1

        @ Test 1 - in depth test for the condition flags
        mrs r1, cpsr
     acc:	e10f1000 	mrs	r1, CPSR
        and r1, #0x000000ff
     ad0:	e20110ff 	and	r1, r1, #255	; 0xff
        msr cpsr_flg, r1
     ad4:	e128f001 	msr	CPSR_f, r1
        @ NZCV = {0000}
        bvs fail
     ad8:	6afffe3d 	bvs	3d4 <fail>
        bcs fail
     adc:	2afffe3c 	bcs	3d4 <fail>
        beq fail
     ae0:	0afffe3b 	beq	3d4 <fail>
        bmi fail
     ae4:	4afffe3a 	bmi	3d4 <fail>
        bhi fail                @ bhi <-> bls
     ae8:	8afffe39 	bhi	3d4 <fail>
        blt fail                @ blt <-> bge
     aec:	bafffe38 	blt	3d4 <fail>
        ble fail                @ ble <-> bgt
     af0:	dafffe37 	ble	3d4 <fail>

        add r1, #0x10000000
     af4:	e2811201 	add	r1, r1, #268435456	; 0x10000000
        msr cpsr, r1
     af8:	e129f001 	msr	CPSR_fc, r1
        @ NZCV = {0001}
        bvc fail
     afc:	7afffe34 	bvc	3d4 <fail>
        bhi fail
     b00:	8afffe33 	bhi	3d4 <fail>
        bge fail
     b04:	aafffe32 	bge	3d4 <fail>
        bgt fail
     b08:	cafffe31 	bgt	3d4 <fail>

        add r1, #0x10000000
     b0c:	e2811201 	add	r1, r1, #268435456	; 0x10000000
        msr cpsr, r1
     b10:	e129f001 	msr	CPSR_fc, r1
        @ NZCV = {0010}
        bvs fail
     b14:	6afffe2e 	bvs	3d4 <fail>
        bcc fail
     b18:	3afffe2d 	bcc	3d4 <fail>
        bls fail
     b1c:	9afffe2c 	bls	3d4 <fail>

        add r1, #0x10000000
     b20:	e2811201 	add	r1, r1, #268435456	; 0x10000000
        msr cpsr, r1
     b24:	e129f001 	msr	CPSR_fc, r1
        @ NZCV = {0011}
        bls fail
     b28:	9afffe29 	bls	3d4 <fail>
        bge fail
     b2c:	aafffe28 	bge	3d4 <fail>
        bgt fail
     b30:	cafffe27 	bgt	3d4 <fail>

        add r1, #0x10000000
     b34:	e2811201 	add	r1, r1, #268435456	; 0x10000000
        msr cpsr, r1
     b38:	e129f001 	msr	CPSR_fc, r1
        @ NZCV = {0100}
        bne fail
     b3c:	1afffe24 	bne	3d4 <fail>
        bhi fail
     b40:	8afffe23 	bhi	3d4 <fail>
        bgt fail
     b44:	cafffe22 	bgt	3d4 <fail>

        add r1, #0x10000000
     b48:	e2811201 	add	r1, r1, #268435456	; 0x10000000
        msr cpsr, r1
     b4c:	e129f001 	msr	CPSR_fc, r1
        @ NZCV = {0101}
        bgt fail
     b50:	cafffe1f 	bgt	3d4 <fail>

        add r1, #0x10000000
     b54:	e2811201 	add	r1, r1, #268435456	; 0x10000000
        msr cpsr, r1
     b58:	e129f001 	msr	CPSR_fc, r1
        @ NZCV = {0110}
        bhi fail
     b5c:	8afffe1c 	bhi	3d4 <fail>

        add r1, #0x20000000
     b60:	e2811202 	add	r1, r1, #536870912	; 0x20000000
        msr cpsr, r1
     b64:	e129f001 	msr	CPSR_fc, r1
        @ NZCV = {1000}
        bpl fail
     b68:	5afffe19 	bpl	3d4 <fail>
        bge fail
     b6c:	aafffe18 	bge	3d4 <fail>
        bgt fail
     b70:	cafffe17 	bgt	3d4 <fail>

        add r1, #0x10000000
     b74:	e2811201 	add	r1, r1, #268435456	; 0x10000000
        msr cpsr, r1
     b78:	e129f001 	msr	CPSR_fc, r1
        @ NZCV = {1001}
        blt fail
     b7c:	bafffe14 	blt	3d4 <fail>

        add r1, #0x30000000
     b80:	e2811203 	add	r1, r1, #805306368	; 0x30000000
        msr cpsr, r1
     b84:	e129f001 	msr	CPSR_fc, r1
        @ NZCV = {1100}
        bgt fail
     b88:	cafffe11 	bgt	3d4 <fail>

        add r0, #1
     b8c:	e2800001 	add	r0, r0, #1

        @ Test 2 - test for the FIQ processor mode
        mov r1, r14                     @ save our link register and stack pointer
     b90:	e1a0100e 	mov	r1, lr
        mov r2, r13
     b94:	e1a0200d 	mov	r2, sp
        mov r3, #30
     b98:	e3a0301e 	mov	r3, #30
        mov r4, #40
     b9c:	e3a04028 	mov	r4, #40	; 0x28
        mov r5, #50
     ba0:	e3a05032 	mov	r5, #50	; 0x32
        mov r6, #60
     ba4:	e3a0603c 	mov	r6, #60	; 0x3c
        mov r7, #70
     ba8:	e3a07046 	mov	r7, #70	; 0x46
        mov r8, #80
     bac:	e3a08050 	mov	r8, #80	; 0x50
        mov r9, #90
     bb0:	e3a0905a 	mov	r9, #90	; 0x5a
        mov r10, #100
     bb4:	e3a0a064 	mov	sl, #100	; 0x64
        mov r11, #110
     bb8:	e3a0b06e 	mov	fp, #110	; 0x6e
        mov r12, #120
     bbc:	e3a0c078 	mov	ip, #120	; 0x78
        mov r13, #130
     bc0:	e3a0d082 	mov	sp, #130	; 0x82
        mov r14, #140
     bc4:	e3a0e08c 	mov	lr, #140	; 0x8c

        msr cpsr, #0xd1         @ go into FIQ mode, disable all interrupts (F and I bits set)
     bc8:	e329f0d1 	msr	CPSR_fc, #209	; 0xd1
        cmp r3, #30
     bcc:	e353001e 	cmp	r3, #30
        bne .fail
     bd0:	1a00005a 	bne	d40 <.fail>
        mov r8, #8                      @ overwrite fiq regs...
     bd4:	e3a08008 	mov	r8, #8
        mov r9, #9
     bd8:	e3a09009 	mov	r9, #9
        mov r10, #10
     bdc:	e3a0a00a 	mov	sl, #10
        mov r11, #11
     be0:	e3a0b00b 	mov	fp, #11
        mov r12, #12
     be4:	e3a0c00c 	mov	ip, #12
        mov r13, #13
     be8:	e3a0d00d 	mov	sp, #13
        mov r14, #14
     bec:	e3a0e00e 	mov	lr, #14
        mov r3, #3                      @ also overwrite some user regs
     bf0:	e3a03003 	mov	r3, #3
        mov r4, #4
     bf4:	e3a04004 	mov	r4, #4
        mov r5, #5
     bf8:	e3a05005 	mov	r5, #5
        mov r6, #6
     bfc:	e3a06006 	mov	r6, #6
        mov r7, #7
     c00:	e3a07007 	mov	r7, #7
        msr cpsr, #0x1f         @ back to SYS mode
     c04:	e329f01f 	msr	CPSR_fc, #31
        cmp r3, #3                      @ r3-7 should have been affected, but not r8-r14
     c08:	e3530003 	cmp	r3, #3
        bne .fail
     c0c:	1a00004b 	bne	d40 <.fail>
        cmp r4, #4
     c10:	e3540004 	cmp	r4, #4
        bne .fail
     c14:	1a000049 	bne	d40 <.fail>
        cmp r5, #5
     c18:	e3550005 	cmp	r5, #5
        bne .fail
     c1c:	1a000047 	bne	d40 <.fail>
        cmp r6, #6
     c20:	e3560006 	cmp	r6, #6
        bne .fail
     c24:	1a000045 	bne	d40 <.fail>
        cmp r7, #7
     c28:	e3570007 	cmp	r7, #7
        bne .fail
     c2c:	1a000043 	bne	d40 <.fail>
        cmp r8, #80
     c30:	e3580050 	cmp	r8, #80	; 0x50
        bne .fail
     c34:	1a000041 	bne	d40 <.fail>
        cmp r9, #90
     c38:	e359005a 	cmp	r9, #90	; 0x5a
        bne .fail
     c3c:	1a00003f 	bne	d40 <.fail>
        cmp r10, #100
     c40:	e35a0064 	cmp	sl, #100	; 0x64
        bne .fail
     c44:	1a00003d 	bne	d40 <.fail>
        cmp r11, #110
     c48:	e35b006e 	cmp	fp, #110	; 0x6e
        bne .fail
     c4c:	1a00003b 	bne	d40 <.fail>
        cmp r12, #120
     c50:	e35c0078 	cmp	ip, #120	; 0x78
        bne .fail
     c54:	1a000039 	bne	d40 <.fail>
        cmp r13, #130
     c58:	e35d0082 	cmp	sp, #130	; 0x82
        bne .fail
     c5c:	1a000037 	bne	d40 <.fail>
        cmp r14, #140
     c60:	e35e008c 	cmp	lr, #140	; 0x8c
        bne .fail
     c64:	1a000035 	bne	d40 <.fail>
        add r0, #1
     c68:	e2800001 	add	r0, r0, #1

        @ Test 3 - test for the SVC processor mode
        mov r12, #120
     c6c:	e3a0c078 	mov	ip, #120	; 0x78
        mov r13, #130
     c70:	e3a0d082 	mov	sp, #130	; 0x82
        mov r14, #140
     c74:	e3a0e08c 	mov	lr, #140	; 0x8c
        msr cpsr, #0x13         @ enter SVC mode
     c78:	e329f013 	msr	CPSR_fc, #19
        cmp r12, #120
     c7c:	e35c0078 	cmp	ip, #120	; 0x78
        bne .fail
     c80:	1a00002e 	bne	d40 <.fail>
        mov r12, #12
     c84:	e3a0c00c 	mov	ip, #12
        mov r13, #13
     c88:	e3a0d00d 	mov	sp, #13
        mov r14, #14
     c8c:	e3a0e00e 	mov	lr, #14
        msr cpsr, #0x1f         @ back into SYS mode
     c90:	e329f01f 	msr	CPSR_fc, #31
        cmp r12, #12
     c94:	e35c000c 	cmp	ip, #12
        bne .fail
     c98:	1a000028 	bne	d40 <.fail>
        cmp r13, #130
     c9c:	e35d0082 	cmp	sp, #130	; 0x82
        bne .fail
     ca0:	1a000026 	bne	d40 <.fail>
        cmp r14, #140
     ca4:	e35e008c 	cmp	lr, #140	; 0x8c
        bne .fail
     ca8:	1a000024 	bne	d40 <.fail>
        add r0, #1
     cac:	e2800001 	add	r0, r0, #1

        @ Test 4 - test for the UND processor mode
        mov r12, #120
     cb0:	e3a0c078 	mov	ip, #120	; 0x78
        mov r13, #130
     cb4:	e3a0d082 	mov	sp, #130	; 0x82
        mov r14, #140
     cb8:	e3a0e08c 	mov	lr, #140	; 0x8c
        msr cpsr, #0x1b         @ enter UND mode
     cbc:	e329f01b 	msr	CPSR_fc, #27
        cmp r12, #120
     cc0:	e35c0078 	cmp	ip, #120	; 0x78
        bne .fail
     cc4:	1a00001d 	bne	d40 <.fail>
        mov r12, #12
     cc8:	e3a0c00c 	mov	ip, #12
        mov r13, #13
     ccc:	e3a0d00d 	mov	sp, #13
        mov r14, #14
     cd0:	e3a0e00e 	mov	lr, #14
        msr cpsr, #0x1f         @ back into SYS mode
     cd4:	e329f01f 	msr	CPSR_fc, #31
        cmp r12, #12
     cd8:	e35c000c 	cmp	ip, #12
        bne .fail
     cdc:	1a000017 	bne	d40 <.fail>
        cmp r13, #130
     ce0:	e35d0082 	cmp	sp, #130	; 0x82
        bne .fail
     ce4:	1a000015 	bne	d40 <.fail>
        cmp r14, #140
     ce8:	e35e008c 	cmp	lr, #140	; 0x8c
        bne .fail
     cec:	1a000013 	bne	d40 <.fail>
        add r0, #1
     cf0:	e2800001 	add	r0, r0, #1

        @ Test 5 - test for the IRQ processor mode
        mov r12, #120
     cf4:	e3a0c078 	mov	ip, #120	; 0x78
        mov r13, #130
     cf8:	e3a0d082 	mov	sp, #130	; 0x82
        mov r14, #140
     cfc:	e3a0e08c 	mov	lr, #140	; 0x8c
        msr cpsr, #0x92         @ enter IRQ mode, IRQ disabled
     d00:	e329f092 	msr	CPSR_fc, #146	; 0x92
        cmp r12, #120
     d04:	e35c0078 	cmp	ip, #120	; 0x78
        bne .fail
     d08:	1a00000c 	bne	d40 <.fail>
        mov r12, #12
     d0c:	e3a0c00c 	mov	ip, #12
        mov r13, #13
     d10:	e3a0d00d 	mov	sp, #13
        mov r14, #14
     d14:	e3a0e00e 	mov	lr, #14
        msr cpsr, #0x1F         @ back into SYS mode
     d18:	e329f01f 	msr	CPSR_fc, #31
        cmp r12, #12
     d1c:	e35c000c 	cmp	ip, #12
        bne .fail
     d20:	1a000006 	bne	d40 <.fail>
        cmp r13, #130
     d24:	e35d0082 	cmp	sp, #130	; 0x82
        bne .fail
     d28:	1a000004 	bne	d40 <.fail>
        cmp r14, #140
     d2c:	e35e008c 	cmp	lr, #140	; 0x8c
        bne .fail
     d30:	1a000002 	bne	d40 <.fail>

        mov r0, #0
     d34:	e3a00000 	mov	r0, #0
        mov r13, r2
     d38:	e1a0d002 	mov	sp, r2
        bx r1
     d3c:	e12fff11 	bx	r1

00000d40 <.fail>:

.fail:
        msr cpsr, #0x1F         @ back into SYS mode
     d40:	e329f01f 	msr	CPSR_fc, #31
        b fail10
     d44:	eafffd02 	b	154 <fail10>

00000d48 <test_mul>:

        @ Test multiplier and how it affects the flags
test_mul:
        mov r0, #1
     d48:	e3a00001 	mov	r0, #1

        @ Test 1 - MUL instruction
        mov r1, #0
     d4c:	e3a01000 	mov	r1, #0
        mov r2, #2
     d50:	e3a02002 	mov	r2, #2
        mov r3, #3
     d54:	e3a03003 	mov	r3, #3
        mul r4, r2, r3
     d58:	e0040392 	mul	r4, r2, r3
        cmp r4, #6
     d5c:	e3540006 	cmp	r4, #6
        bne fail
     d60:	1afffd9b 	bne	3d4 <fail>
        bmi fail
     d64:	4afffd9a 	bmi	3d4 <fail>

        muls r5, r1, r2
     d68:	e0150291 	muls	r5, r1, r2
        bne fail
     d6c:	1afffd98 	bne	3d4 <fail>
        bmi fail
     d70:	4afffd97 	bmi	3d4 <fail>

        muls r4, r2
     d74:	e0140492 	muls	r4, r2, r4
        cmp r4, #12
     d78:	e354000c 	cmp	r4, #12
        bne fail
     d7c:	1afffd94 	bne	3d4 <fail>
        bmi fail
     d80:	4afffd93 	bmi	3d4 <fail>

@       mul r3, r3, r4          @ no joke, verified to fail on a real ARM !
@       cmp r4, #36
@       bne fail

        mov r3, #-3                     @ multiply positive * negative
     d84:	e3e03002 	mvn	r3, #2
        muls r5, r2, r3
     d88:	e0150392 	muls	r5, r2, r3
        bpl fail        
     d8c:	5afffd90 	bpl	3d4 <fail>
        cmp r5, #-6
     d90:	e3750006 	cmn	r5, #6
        bne fail
     d94:	1afffd8e 	bne	3d4 <fail>

        mov r2, #-2                     @ multiply negative * negative
     d98:	e3e02001 	mvn	r2, #1
        muls r5, r2, r3
     d9c:	e0150392 	muls	r5, r2, r3
        bmi fail
     da0:	4afffd8b 	bmi	3d4 <fail>
        cmp r5, #6
     da4:	e3550006 	cmp	r5, #6
        bne fail
     da8:	1afffd89 	bne	3d4 <fail>
        add r0, #1
     dac:	e2800001 	add	r0, r0, #1

        @ Test 2 - MLA instruction
        mov r1, #10
     db0:	e3a0100a 	mov	r1, #10
        mov r2, #2
     db4:	e3a02002 	mov	r2, #2
        mov r3, #5
     db8:	e3a03005 	mov	r3, #5
        mlas r4, r1, r2, r3             @ 2*10 + 5 = 25
     dbc:	e0343291 	mlas	r4, r1, r2, r3
        bmi fail
     dc0:	4afffd83 	bmi	3d4 <fail>
@       bcs fail                        @ on a real ARM, C flag after MLA is unpredictable
        bvs fail
     dc4:	6afffd82 	bvs	3d4 <fail>
        cmp r4, #25
     dc8:	e3540019 	cmp	r4, #25
        bne fail
     dcc:	1afffd80 	bne	3d4 <fail>

        mov r1, #-10
     dd0:	e3e01009 	mvn	r1, #9
        mlas r4, r1, r2, r3             @ 2*-10 + 5 = -15
     dd4:	e0343291 	mlas	r4, r1, r2, r3
        bpl fail
     dd8:	5afffd7d 	bpl	3d4 <fail>
        bvs fail
     ddc:	6afffd7c 	bvs	3d4 <fail>
        cmp r4, #-15
     de0:	e374000f 	cmn	r4, #15
        bne fail
     de4:	1afffd7a 	bne	3d4 <fail>

        mov r3, #0x80000001             @ causes addition overflow
     de8:	e3a03106 	mov	r3, #-2147483647	; 0x80000001
        mlas r4, r1, r2, r3
     dec:	e0343291 	mlas	r4, r1, r2, r3
        bmi fail
     df0:	4afffd77 	bmi	3d4 <fail>
@       bvc fail                        @ on a real ARM, V flag is not updated ?
        add r0, #1
     df4:	e2800001 	add	r0, r0, #1

        @ Test 3 - SMALTB test.
        mov r1, #0x20000001
     df8:	e3a01212 	mov	r1, #536870913	; 0x20000001
        mov r2, r1
     dfc:	e1a02001 	mov	r2, r1
        mov r3, #0x4
     e00:	e3a03004 	mov	r3, #4
        smlatb r4, r1, r2, r3
     e04:	e10432a1 	smlatb	r4, r1, r2, r3
        mov r5, #0x2000
     e08:	e3a05a02 	mov	r5, #8192	; 0x2000
        add r5, #4
     e0c:	e2855004 	add	r5, r5, #4
        cmp r4, r5
     e10:	e1540005 	cmp	r4, r5
        bne fail
     e14:	1afffd6e 	bne	3d4 <fail>

        mov r0, #0
     e18:	e3a00000 	mov	r0, #0
        bx lr
     e1c:	e12fff1e 	bx	lr

00000e20 <test_ldmstm>:

        @ Test load multiple and store multiple instructions
test_ldmstm:
        mov r0, #1
     e20:	e3a00001 	mov	r0, #1

        @ Test 1 - STMIA
        mov r1, #1
     e24:	e3a01001 	mov	r1, #1
        mov r2, #2
     e28:	e3a02002 	mov	r2, #2
        mov r3, #3
     e2c:	e3a03003 	mov	r3, #3
        mov r4, #4
     e30:	e3a04004 	mov	r4, #4
        ldr r5, .larray1
     e34:	e51f546c 	ldr	r5, [pc, #-1132]	; 9d0 <.larray1>
        mov r6, r5
     e38:	e1a06005 	mov	r6, r5

        stmia r6!, {r1-r4}
     e3c:	e8a6001e 	stmia	r6!, {r1, r2, r3, r4}
        sub r6, r5
     e40:	e0466005 	sub	r6, r6, r5
        cmp r6, #16
     e44:	e3560010 	cmp	r6, #16
        bne fail
     e48:	1afffd61 	bne	3d4 <fail>

        ldr r6, [r5]
     e4c:	e5956000 	ldr	r6, [r5]
        cmp r6, #1
     e50:	e3560001 	cmp	r6, #1
        bne fail
     e54:	1afffd5e 	bne	3d4 <fail>
        ldr r6, [r5, #4]
     e58:	e5956004 	ldr	r6, [r5, #4]
        cmp r6, #2
     e5c:	e3560002 	cmp	r6, #2
        bne fail
     e60:	1afffd5b 	bne	3d4 <fail>
        ldr r6, [r5, #8]
     e64:	e5956008 	ldr	r6, [r5, #8]
        cmp r6, #3
     e68:	e3560003 	cmp	r6, #3
        bne fail
     e6c:	1afffd58 	bne	3d4 <fail>
        ldr r6, [r5, #12]
     e70:	e595600c 	ldr	r6, [r5, #12]
        cmp r6, #4
     e74:	e3560004 	cmp	r6, #4
        bne fail
     e78:	1afffd55 	bne	3d4 <fail>
        add r0, #1
     e7c:	e2800001 	add	r0, r0, #1

        @ Test 2 - STMIB
        mov r6, r5
     e80:	e1a06005 	mov	r6, r5
        stmib r6!, {r1-r3}
     e84:	e9a6000e 	stmib	r6!, {r1, r2, r3}
        sub r6, r5
     e88:	e0466005 	sub	r6, r6, r5
        cmp r6, #12
     e8c:	e356000c 	cmp	r6, #12
        bne fail
     e90:	1afffd4f 	bne	3d4 <fail>

        ldr r6, [r5, #4]
     e94:	e5956004 	ldr	r6, [r5, #4]
        cmp r6, #1
     e98:	e3560001 	cmp	r6, #1
        bne fail
     e9c:	1afffd4c 	bne	3d4 <fail>
        ldr r6, [r5, #8]
     ea0:	e5956008 	ldr	r6, [r5, #8]
        cmp r6, #2
     ea4:	e3560002 	cmp	r6, #2
        bne fail
     ea8:	1afffd49 	bne	3d4 <fail>
        ldr r6, [r5, #12]
     eac:	e595600c 	ldr	r6, [r5, #12]
        cmp r6, #3
     eb0:	e3560003 	cmp	r6, #3
        bne fail
     eb4:	1afffd46 	bne	3d4 <fail>
        add r0, #1
     eb8:	e2800001 	add	r0, r0, #1

        @ Test 3 - STMDB
        add r6, r5, #12
     ebc:	e285600c 	add	r6, r5, #12
        stmdb r6!, {r1-r3}
     ec0:	e926000e 	stmdb	r6!, {r1, r2, r3}
        cmp r6, r5
     ec4:	e1560005 	cmp	r6, r5
        bne fail
     ec8:	1afffd41 	bne	3d4 <fail>

        ldr r6, [r5]
     ecc:	e5956000 	ldr	r6, [r5]
        cmp r6, #1
     ed0:	e3560001 	cmp	r6, #1
        bne fail
     ed4:	1afffd3e 	bne	3d4 <fail>
        ldr r6, [r5, #8]
     ed8:	e5956008 	ldr	r6, [r5, #8]
        cmp r6, #3
     edc:	e3560003 	cmp	r6, #3
        bne fail
     ee0:	1afffd3b 	bne	3d4 <fail>
        add r0, #1
     ee4:	e2800001 	add	r0, r0, #1

        @ Test 4 - STMDA
        add r6, r5, #12
     ee8:	e285600c 	add	r6, r5, #12
        stmda r6!, {r1-r3}
     eec:	e826000e 	stmda	r6!, {r1, r2, r3}
        cmp r6, r5
     ef0:	e1560005 	cmp	r6, r5
        bne fail
     ef4:	1afffd36 	bne	3d4 <fail>
        ldr r6, [r5, #4]
     ef8:	e5956004 	ldr	r6, [r5, #4]
        cmp r6, #1
     efc:	e3560001 	cmp	r6, #1
        bne fail
     f00:	1afffd33 	bne	3d4 <fail>
        ldr r6, [r5, #12]
     f04:	e595600c 	ldr	r6, [r5, #12]
        cmp r6, #3
     f08:	e3560003 	cmp	r6, #3
        bne fail
     f0c:	1afffd30 	bne	3d4 <fail>
        add r0, #1
     f10:	e2800001 	add	r0, r0, #1

        @ Test 5 - LDMIA
        ldr r5, .larray2
     f14:	e51f5548 	ldr	r5, [pc, #-1352]	; 9d4 <.larray2>
        ldmia r5, {r1-r4}
     f18:	e895001e 	ldm	r5, {r1, r2, r3, r4}
        cmp r1, #16
     f1c:	e3510010 	cmp	r1, #16
        bne fail
     f20:	1afffd2b 	bne	3d4 <fail>
        cmp r2, #17
     f24:	e3520011 	cmp	r2, #17
        bne fail
     f28:	1afffd29 	bne	3d4 <fail>
        cmp r3, #18
     f2c:	e3530012 	cmp	r3, #18
        bne fail
     f30:	1afffd27 	bne	3d4 <fail>
        cmp r4, #19
     f34:	e3540013 	cmp	r4, #19
        bne fail
     f38:	1afffd25 	bne	3d4 <fail>
        add r0, #1
     f3c:	e2800001 	add	r0, r0, #1

        @ Test 6 - LDMIB
        ldmib r5!, {r1-r4}
     f40:	e9b5001e 	ldmib	r5!, {r1, r2, r3, r4}
        cmp r1, #17
     f44:	e3510011 	cmp	r1, #17
        bne fail
     f48:	1afffd21 	bne	3d4 <fail>
        cmp r2, #18
     f4c:	e3520012 	cmp	r2, #18
        bne fail
     f50:	1afffd1f 	bne	3d4 <fail>
        cmp r3, #19
     f54:	e3530013 	cmp	r3, #19
        bne fail
     f58:	1afffd1d 	bne	3d4 <fail>
        cmp r4, #20
     f5c:	e3540014 	cmp	r4, #20
        bne fail
     f60:	1afffd1b 	bne	3d4 <fail>
        add r0, #1
     f64:	e2800001 	add	r0, r0, #1

        @ Test 7 - LDMDB
        ldmdb r5!, {r1-r3}
     f68:	e935000e 	ldmdb	r5!, {r1, r2, r3}
        cmp r3, #19
     f6c:	e3530013 	cmp	r3, #19
        bne fail
     f70:	1afffd17 	bne	3d4 <fail>
        cmp r2, #18
     f74:	e3520012 	cmp	r2, #18
        bne fail
     f78:	1afffd15 	bne	3d4 <fail>
        cmp r1, #17
     f7c:	e3510011 	cmp	r1, #17
        bne fail
     f80:	1afffd13 	bne	3d4 <fail>
        add r0, #1
     f84:	e2800001 	add	r0, r0, #1

        @ Test 8 - LDMDA
        ldmda r5, {r1-r2}
     f88:	e8150006 	ldmda	r5, {r1, r2}
        cmp r1, #16
     f8c:	e3510010 	cmp	r1, #16
        bne fail
     f90:	1afffd0f 	bne	3d4 <fail>
        cmp r2, #17
     f94:	e3520011 	cmp	r2, #17
        bne fail
     f98:	1afffd0d 	bne	3d4 <fail>

        mov r0, #0
     f9c:	e3a00000 	mov	r0, #0
        bx lr
     fa0:	e12fff1e 	bx	lr

00000fa4 <test_r15jumps>:

        @ Test proper jumping on instructions that affect R15
test_r15jumps:
        mov r0, #1
     fa4:	e3a00001 	mov	r0, #1

        @ Test 1 - a standard, conditional jump instruction
        ldr r3, .llabels
     fa8:	e59f3150 	ldr	r3, [pc, #336]	; 1100 <.llabels>
        mov r1, #0
     fac:	e3a01000 	mov	r1, #0
        movs r2, #0
     fb0:	e3b02000 	movs	r2, #0
        moveq r15, r3            @ jump to label 1
     fb4:	01a0f003 	moveq	pc, r3
        movs r2, #12
     fb8:	e3b0200c 	movs	r2, #12
        movs r1, #13            @ make sure fetched/decoded instructions do no execute
     fbc:	e3b0100d 	movs	r1, #13

00000fc0 <.label1>:
.label1:
        bne fail
     fc0:	1afffd03 	bne	3d4 <fail>
        cmp r1, #0
     fc4:	e3510000 	cmp	r1, #0
        bne fail
     fc8:	1afffd01 	bne	3d4 <fail>
        cmp r2, #0
     fcc:	e3520000 	cmp	r2, #0
        bne fail
     fd0:	1afffcff 	bne	3d4 <fail>
        add r0, #1
     fd4:	e2800001 	add	r0, r0, #1

        @ Test 2 - a jump instruction is not executed
        ldr r3, .llabels+4
     fd8:	e59f3124 	ldr	r3, [pc, #292]	; 1104 <.llabels+0x4>
        movs r2, #12
     fdc:	e3b0200c 	movs	r2, #12
        moveq r15, r3
     fe0:	01a0f003 	moveq	pc, r3
        movs r2, #0
     fe4:	e3b02000 	movs	r2, #0

00000fe8 <.label2>:
.label2:
        cmp r2, #0
     fe8:	e3520000 	cmp	r2, #0
        bne fail
     fec:	1afffcf8 	bne	3d4 <fail>
        add r0, #1
     ff0:	e2800001 	add	r0, r0, #1

        @ Test 3 - add instruction to calculate new address
        ldr r3, .llabels+8
     ff4:	e59f310c 	ldr	r3, [pc, #268]	; 1108 <.llabels+0x8>
        movs r1, #0
     ff8:	e3b01000 	movs	r1, #0
        movs r2, #0
     ffc:	e3b02000 	movs	r2, #0
        add r15, r3, #8         @go 2 instructions after label 3
    1000:	e283f008 	add	pc, r3, #8

00001004 <.label3>:
.label3:
        movs r1, #12
    1004:	e3b0100c 	movs	r1, #12
        movs r2, #13
    1008:	e3b0200d 	movs	r2, #13
        bne fail                @ program executions continues here
    100c:	1afffcf0 	bne	3d4 <fail>
        bne fail
    1010:	1afffcef 	bne	3d4 <fail>
        add r0, #1
    1014:	e2800001 	add	r0, r0, #1

        @ Test 4 - use an addition directly from PC+8 (r15)
        movs r2, #0
    1018:	e3b02000 	movs	r2, #0
        movs r1, #0
    101c:	e3b01000 	movs	r1, #0
        add r15, r15, #4        @ Skip 2 instructions This could actually be used for a nice jump table if a register were used instead of #4
    1020:	e28ff004 	add	pc, pc, #4
        movs r1, #1
    1024:	e3b01001 	movs	r1, #1
        movs r2, #2
    1028:	e3b02002 	movs	r2, #2
        bne fail
    102c:	1afffce8 	bne	3d4 <fail>
        bne fail
    1030:	1afffce7 	bne	3d4 <fail>
        add r0, #1
    1034:	e2800001 	add	r0, r0, #1

        @ Test 5 - load r15 directly from memory
        movs r1, #1
    1038:	e3b01001 	movs	r1, #1
        movs r2, #2
    103c:	e3b02002 	movs	r2, #2
        ldrne r15, .llabels+12          @ Makes sure code after a ldr r15 is not executed
    1040:	159ff0c4 	ldrne	pc, [pc, #196]	; 110c <.llabels+0xc>
        movs r1, #0
    1044:	e3b01000 	movs	r1, #0
        movs r2, #0
    1048:	e3b02000 	movs	r2, #0

0000104c <.label4>:
.label4:
        beq fail
    104c:	0afffce0 	beq	3d4 <fail>
        beq fail
    1050:	0afffcdf 	beq	3d4 <fail>

        ldreq r15, .llabels+16          @ Makes sure everything is right when a ldr r15 is not taken
    1054:	059ff0b4 	ldreq	pc, [pc, #180]	; 1110 <.llabels+0x10>
        movs r2, #-2
    1058:	e3f02001 	mvns	r2, #1

0000105c <.label5>:
.label5:
        bpl fail
    105c:	5afffcdc 	bpl	3d4 <fail>
        cmp r2, #-2
    1060:	e3720002 	cmn	r2, #2
        bne fail
    1064:	1afffcda 	bne	3d4 <fail>
        add r0, #1
    1068:	e2800001 	add	r0, r0, #1

        @ Test 6 - load r15 as the last step of a LDM instruction
        ldr r3, .llabels + 6*4
    106c:	e59f30a4 	ldr	r3, [pc, #164]	; 1118 <.llabels+0x18>
        movs r1, #0
    1070:	e3b01000 	movs	r1, #0
        movs r2, #0
    1074:	e3b02000 	movs	r2, #0
        ldmia r3, {r4-r8, r15}          @jump to label6
    1078:	e89381f0 	ldm	r3, {r4, r5, r6, r7, r8, pc}
        movs r1, #4
    107c:	e3b01004 	movs	r1, #4
        movs r2, #2
    1080:	e3b02002 	movs	r2, #2

00001084 <.label6>:
.label6:
        bne fail
    1084:	1afffcd2 	bne	3d4 <fail>
        bne fail
    1088:	1afffcd1 	bne	3d4 <fail>

        mov r0, #0
    108c:	e3a00000 	mov	r0, #0
        bx lr
    1090:	e12fff1e 	bx	lr
    1094:	e1a00000 	nop			; (mov r0, r0)
    1098:	e1a00000 	nop			; (mov r0, r0)
    109c:	e1a00000 	nop			; (mov r0, r0)
    10a0:	e1a00000 	nop			; (mov r0, r0)
    10a4:	e1a00000 	nop			; (mov r0, r0)
    10a8:	e1a00000 	nop			; (mov r0, r0)
    10ac:	e1a00000 	nop			; (mov r0, r0)
    10b0:	e1a00000 	nop			; (mov r0, r0)
    10b4:	e1a00000 	nop			; (mov r0, r0)
    10b8:	e1a00000 	nop			; (mov r0, r0)
    10bc:	e1a00000 	nop			; (mov r0, r0)
	...

00001100 <.llabels>:
    1100:	00000fc0 	.word	0x00000fc0
    1104:	00000fe8 	.word	0x00000fe8
    1108:	00001004 	.word	0x00001004
    110c:	0000104c 	.word	0x0000104c
    1110:	0000105c 	.word	0x0000105c
    1114:	00001084 	.word	0x00001084
    1118:	00001100 	.word	0x00001100

0000111c <test_rti>:
.align 8
.llabels:
        .word .label1, .label2, .label3, .label4, .label5, .label6, .llabels

test_rti:
        mov r0, #1
    111c:	e3a00001 	mov	r0, #1
        mov r12, #14
    1120:	e3a0c00e 	mov	ip, #14

        @ Test 1 - test normal RTI
        msr cpsr, #0xd1                 @ enter into FIQ mode (interrupt disabled)
    1124:	e329f0d1 	msr	CPSR_fc, #209	; 0xd1
        msr spsr, #0x4000001f   @ emulate a saved CPSR in SYS mode, with NZCV = {0100}
    1128:	e369f17d 	msr	SPSR_fc, #1073741855	; 0x4000001f

        movs r8, #-12                   @ now the FIQ sets it's CPSR to NZCV = {1000}
    112c:	e3f0800b 	mvns	r8, #11
        ldr r8, .rtilabels              @ simulate an interrupt return
    1130:	e59f8084 	ldr	r8, [pc, #132]	; 11bc <.rtilabels>
        movs r15, r8                    @ return from interrupt and move SPSR to CPSR
    1134:	e1b0f008 	movs	pc, r8

00001138 <.rtilabel1>:

.rtilabel1:
        mov r12, #1000
    1138:	e3a0cffa 	mov	ip, #1000	; 0x3e8
        bmi .rtifail                    @ ?!? WTF !?!
    113c:	4a00001a 	bmi	11ac <.rtifail>
        bne .rtifail
    1140:	1a000019 	bne	11ac <.rtifail>
        mov r12, #2000
    1144:	e3a0ce7d 	mov	ip, #2000	; 0x7d0
        add r0, #1
    1148:	e2800001 	add	r0, r0, #1

        @ Test 2 - test LDM instruction with S flag
        msr cpsr, #0xd1
    114c:	e329f0d1 	msr	CPSR_fc, #209	; 0xd1
        ldr r8, .rtilabels + 20
    1150:	e59f8078 	ldr	r8, [pc, #120]	; 11d0 <.rtilabels+0x14>
        ldmib r8!, {r9, r10}            @ fiq_r9 = 1, fiq_r10 = 2
    1154:	e9b80600 	ldmib	r8!, {r9, sl}
        ldmib r8, {r9, r10}^            @ r8 = 3, r9 = 4 ( ^ => load to user registers )
    1158:	e9d80600 	ldmib	r8, {r9, sl}^
        cmp r9, #1
    115c:	e3590001 	cmp	r9, #1
        bne .rtifail
    1160:	1a000011 	bne	11ac <.rtifail>
        cmp r10, #2
    1164:	e35a0002 	cmp	sl, #2
        bne .rtifail
    1168:	1a00000f 	bne	11ac <.rtifail>
        msr cpsr, #0x1f
    116c:	e329f01f 	msr	CPSR_fc, #31
        cmp r9, #3
    1170:	e3590003 	cmp	r9, #3
        bne .rtifail
    1174:	1a00000c 	bne	11ac <.rtifail>
        cmp r10, #4
    1178:	e35a0004 	cmp	sl, #4
        bne .rtifail
    117c:	1a00000a 	bne	11ac <.rtifail>
        add r0, #1
    1180:	e2800001 	add	r0, r0, #1

        mov r12, #4000
    1184:	e3a0cefa 	mov	ip, #4000	; 0xfa0

        @ Test 3 - test LDM instruction with S flag for returning from an interrupt
        msr cpsr, #0xd1                         @ FIQ mode, NZCV = {0000}
    1188:	e329f0d1 	msr	CPSR_fc, #209	; 0xd1
        msr spsr, #0x80000010           @ saved is normal mode with NZCV = {1000}
    118c:	e369f142 	msr	SPSR_fc, #-2147483632	; 0x80000010

        ldr r8, .rtilabels + 20
    1190:	e59f8038 	ldr	r8, [pc, #56]	; 11d0 <.rtilabels+0x14>
        add r8, #8
    1194:	e2888008 	add	r8, r8, #8

        movs r9, #0                                     @ NZCV = {0100}
    1198:	e3b09000 	movs	r9, #0
        ldmib r8, {r9-r11, r15}^        @ This should return to user mode and restore CPSR to NZCV = {1000}
    119c:	e9d88e00 	ldmib	r8, {r9, sl, fp, pc}^

000011a0 <.rtilabel2>:

.rtilabel2:
        bpl .rtifail
    11a0:	5a000001 	bpl	11ac <.rtifail>
        beq .rtifail
    11a4:	0a000000 	beq	11ac <.rtifail>
        b passed
    11a8:	eafffbf9 	b	194 <passed>

000011ac <.rtifail>:

.rtifail:
        msr cpsr, #0x10
    11ac:	e329f010 	msr	CPSR_fc, #16
        mov r12, #100
    11b0:	e3a0c064 	mov	ip, #100	; 0x64
        b .rtifail
    11b4:	eafffffc 	b	11ac <.rtifail>
        bx lr
    11b8:	e12fff1e 	bx	lr

000011bc <.rtilabels>:
    11bc:	00001138 	.word	0x00001138
    11c0:	00000001 	.word	0x00000001
    11c4:	00000002 	.word	0x00000002
    11c8:	00000003 	.word	0x00000003
    11cc:	00000004 	.word	0x00000004
    11d0:	000011bc 	.word	0x000011bc
    11d4:	000011a0 	.word	0x000011a0

000011d8 <main>:
// -- 02110-1301, USA.                                                        --
// --                                                                         --
// -----------------------------------------------------------------------------

void main()
{
    11d8:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
    11dc:	e28db000 	add	fp, sp, #0

}
    11e0:	e1a00000 	nop			; (mov r0, r0)
    11e4:	e24bd000 	sub	sp, fp, #0
    11e8:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
    11ec:	e12fff1e 	bx	lr
