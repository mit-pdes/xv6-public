
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	3b813103          	ld	sp,952(sp) # 8000a3b8 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	042000ef          	jal	80000058 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000024:	30a027f3          	csrr	a5,0x30a
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | MENVCFG_STCE);
    80000028:	577d                	li	a4,-1
    8000002a:	177e                	slli	a4,a4,0x3f
    8000002c:	8fd9                	or	a5,a5,a4

static inline void
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000002e:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    80000032:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000036:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    8000003a:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000003e:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80000042:	000f4737          	lui	a4,0xf4
    80000046:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000004a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000004c:	14d79073          	csrw	stimecmp,a5
}
    80000050:	60a2                	ld	ra,8(sp)
    80000052:	6402                	ld	s0,0(sp)
    80000054:	0141                	addi	sp,sp,16
    80000056:	8082                	ret

0000000080000058 <start>:
{
    80000058:	1141                	addi	sp,sp,-16
    8000005a:	e406                	sd	ra,8(sp)
    8000005c:	e022                	sd	s0,0(sp)
    8000005e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r"(x));
    80000060:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000064:	7779                	lui	a4,0xffffe
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb0f7>
    8000006a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000006c:	6705                	lui	a4,0x1
    8000006e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000072:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000074:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000078:	00001797          	auipc	a5,0x1
    8000007c:	e2678793          	addi	a5,a5,-474 # 80000e9e <main>
    80000080:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000084:	4781                	li	a5,0
    80000086:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    8000008a:	67c1                	lui	a5,0x10
    8000008c:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000008e:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    80000092:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    80000096:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    8000009a:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r"(x));
    8000009e:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000a2:	57fd                	li	a5,-1
    800000a4:	83a9                	srli	a5,a5,0xa
    800000a6:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000aa:	47bd                	li	a5,15
    800000ac:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    800000b0:	30a027f3          	csrr	a5,0x30a
  w_menvcfg(r_menvcfg() | MENVCFG_ADUE);
    800000b4:	4705                	li	a4,1
    800000b6:	1776                	slli	a4,a4,0x3d
    800000b8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    800000ba:	30a79073          	csrw	0x30a,a5
  timerinit();
    800000be:	f5fff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000c2:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c6:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r"(x));
    800000c8:	823e                	mv	tp,a5
  asm volatile("mret");
    800000ca:	30200073          	mret
}
    800000ce:	60a2                	ld	ra,8(sp)
    800000d0:	6402                	ld	s0,0(sp)
    800000d2:	0141                	addi	sp,sp,16
    800000d4:	8082                	ret

00000000800000d6 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d6:	7119                	addi	sp,sp,-128
    800000d8:	fc86                	sd	ra,120(sp)
    800000da:	f8a2                	sd	s0,112(sp)
    800000dc:	f4a6                	sd	s1,104(sp)
    800000de:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while (i < n) {
    800000e0:	06c05b63          	blez	a2,80000156 <consolewrite+0x80>
    800000e4:	f0ca                	sd	s2,96(sp)
    800000e6:	ecce                	sd	s3,88(sp)
    800000e8:	e8d2                	sd	s4,80(sp)
    800000ea:	e4d6                	sd	s5,72(sp)
    800000ec:	e0da                	sd	s6,64(sp)
    800000ee:	fc5e                	sd	s7,56(sp)
    800000f0:	f862                	sd	s8,48(sp)
    800000f2:	f466                	sd	s9,40(sp)
    800000f4:	f06a                	sd	s10,32(sp)
    800000f6:	8b2a                	mv	s6,a0
    800000f8:	8bae                	mv	s7,a1
    800000fa:	8a32                	mv	s4,a2
  int i = 0;
    800000fc:	4481                	li	s1,0
    int nn = sizeof(buf);
    if (nn > n - i)
    800000fe:	02000c93          	li	s9,32
    80000102:	02000d13          	li	s10,32
      nn = n - i;
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000106:	f8040a93          	addi	s5,s0,-128
    8000010a:	5c7d                	li	s8,-1
    8000010c:	a025                	j	80000134 <consolewrite+0x5e>
    if (nn > n - i)
    8000010e:	0009099b          	sext.w	s3,s2
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000112:	86ce                	mv	a3,s3
    80000114:	01748633          	add	a2,s1,s7
    80000118:	85da                	mv	a1,s6
    8000011a:	8556                	mv	a0,s5
    8000011c:	2b4020ef          	jal	800023d0 <either_copyin>
    80000120:	03850d63          	beq	a0,s8,8000015a <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000124:	85ce                	mv	a1,s3
    80000126:	8556                	mv	a0,s5
    80000128:	7c2000ef          	jal	800008ea <uartwrite>
    i += nn;
    8000012c:	009904bb          	addw	s1,s2,s1
  while (i < n) {
    80000130:	0144d963          	bge	s1,s4,80000142 <consolewrite+0x6c>
    if (nn > n - i)
    80000134:	409a07bb          	subw	a5,s4,s1
    80000138:	893e                	mv	s2,a5
    8000013a:	fcfcdae3          	bge	s9,a5,8000010e <consolewrite+0x38>
    8000013e:	896a                	mv	s2,s10
    80000140:	b7f9                	j	8000010e <consolewrite+0x38>
    80000142:	7906                	ld	s2,96(sp)
    80000144:	69e6                	ld	s3,88(sp)
    80000146:	6a46                	ld	s4,80(sp)
    80000148:	6aa6                	ld	s5,72(sp)
    8000014a:	6b06                	ld	s6,64(sp)
    8000014c:	7be2                	ld	s7,56(sp)
    8000014e:	7c42                	ld	s8,48(sp)
    80000150:	7ca2                	ld	s9,40(sp)
    80000152:	7d02                	ld	s10,32(sp)
    80000154:	a821                	j	8000016c <consolewrite+0x96>
  int i = 0;
    80000156:	4481                	li	s1,0
    80000158:	a811                	j	8000016c <consolewrite+0x96>
    8000015a:	7906                	ld	s2,96(sp)
    8000015c:	69e6                	ld	s3,88(sp)
    8000015e:	6a46                	ld	s4,80(sp)
    80000160:	6aa6                	ld	s5,72(sp)
    80000162:	6b06                	ld	s6,64(sp)
    80000164:	7be2                	ld	s7,56(sp)
    80000166:	7c42                	ld	s8,48(sp)
    80000168:	7ca2                	ld	s9,40(sp)
    8000016a:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016c:	8526                	mv	a0,s1
    8000016e:	70e6                	ld	ra,120(sp)
    80000170:	7446                	ld	s0,112(sp)
    80000172:	74a6                	ld	s1,104(sp)
    80000174:	6109                	addi	sp,sp,128
    80000176:	8082                	ret

0000000080000178 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000178:	711d                	addi	sp,sp,-96
    8000017a:	ec86                	sd	ra,88(sp)
    8000017c:	e8a2                	sd	s0,80(sp)
    8000017e:	e4a6                	sd	s1,72(sp)
    80000180:	e0ca                	sd	s2,64(sp)
    80000182:	fc4e                	sd	s3,56(sp)
    80000184:	f852                	sd	s4,48(sp)
    80000186:	f05a                	sd	s6,32(sp)
    80000188:	ec5e                	sd	s7,24(sp)
    8000018a:	1080                	addi	s0,sp,96
    8000018c:	8b2a                	mv	s6,a0
    8000018e:	8a2e                	mv	s4,a1
    80000190:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000194:	00012517          	auipc	a0,0x12
    80000198:	26c50513          	addi	a0,a0,620 # 80012400 <cons>
    8000019c:	28d000ef          	jal	80000c28 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	26048493          	addi	s1,s1,608 # 80012400 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	2f090913          	addi	s2,s2,752 # 80012498 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	029010ef          	jal	800019e8 <myproc>
    800001c4:	08c020ef          	jal	80002250 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	627010ef          	jal	80001ff2 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	659010ef          	jal	8000202e <sleep>
      acquire(&cons.lock);
    800001da:	8526                	mv	a0,s1
    800001dc:	24d000ef          	jal	80000c28 <acquire>
    while (cons.r == cons.w) {
    800001e0:	0984a783          	lw	a5,152(s1)
    800001e4:	09c4a703          	lw	a4,156(s1)
    800001e8:	fcf70ce3          	beq	a4,a5,800001c0 <consoleread+0x48>
    800001ec:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ee:	00012717          	auipc	a4,0x12
    800001f2:	21270713          	addi	a4,a4,530 # 80012400 <cons>
    800001f6:	0017869b          	addiw	a3,a5,1
    800001fa:	08d72c23          	sw	a3,152(a4)
    800001fe:	07f7f693          	andi	a3,a5,127
    80000202:	9736                	add	a4,a4,a3
    80000204:	01874703          	lbu	a4,24(a4)
    80000208:	00070a9b          	sext.w	s5,a4

    if (c == C('D')) { // end-of-file
    8000020c:	4691                	li	a3,4
    8000020e:	04da8663          	beq	s5,a3,8000025a <consoleread+0xe2>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000212:	fae407a3          	sb	a4,-81(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000216:	4685                	li	a3,1
    80000218:	faf40613          	addi	a2,s0,-81
    8000021c:	85d2                	mv	a1,s4
    8000021e:	855a                	mv	a0,s6
    80000220:	164020ef          	jal	80002384 <either_copyout>
    80000224:	57fd                	li	a5,-1
    80000226:	04f50663          	beq	a0,a5,80000272 <consoleread+0xfa>
      break;

    dst++;
    8000022a:	0a05                	addi	s4,s4,1
    --n;
    8000022c:	39fd                	addiw	s3,s3,-1

    if (c == '\n') {
    8000022e:	47a9                	li	a5,10
    80000230:	04fa8b63          	beq	s5,a5,80000286 <consoleread+0x10e>
    80000234:	7aa2                	ld	s5,40(sp)
    80000236:	bfad                	j	800001b0 <consoleread+0x38>
        release(&cons.lock);
    80000238:	00012517          	auipc	a0,0x12
    8000023c:	1c850513          	addi	a0,a0,456 # 80012400 <cons>
    80000240:	271000ef          	jal	80000cb0 <release>
        return -1;
    80000244:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000246:	60e6                	ld	ra,88(sp)
    80000248:	6446                	ld	s0,80(sp)
    8000024a:	64a6                	ld	s1,72(sp)
    8000024c:	6906                	ld	s2,64(sp)
    8000024e:	79e2                	ld	s3,56(sp)
    80000250:	7a42                	ld	s4,48(sp)
    80000252:	7b02                	ld	s6,32(sp)
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	6125                	addi	sp,sp,96
    80000258:	8082                	ret
      if (n < target) {
    8000025a:	0179fa63          	bgeu	s3,s7,8000026e <consoleread+0xf6>
        cons.r--;
    8000025e:	00012717          	auipc	a4,0x12
    80000262:	22f72d23          	sw	a5,570(a4) # 80012498 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	18c50513          	addi	a0,a0,396 # 80012400 <cons>
    8000027c:	235000ef          	jal	80000cb0 <release>
  return target - n;
    80000280:	413b853b          	subw	a0,s7,s3
    80000284:	b7c9                	j	80000246 <consoleread+0xce>
    80000286:	7aa2                	ld	s5,40(sp)
    80000288:	b7f5                	j	80000274 <consoleread+0xfc>

000000008000028a <consputc>:
{
    8000028a:	1141                	addi	sp,sp,-16
    8000028c:	e406                	sd	ra,8(sp)
    8000028e:	e022                	sd	s0,0(sp)
    80000290:	0800                	addi	s0,sp,16
  if (c == BACKSPACE) {
    80000292:	10000793          	li	a5,256
    80000296:	00f50863          	beq	a0,a5,800002a6 <consputc+0x1c>
    uartputc_sync(c);
    8000029a:	6f6000ef          	jal	80000990 <uartputc_sync>
}
    8000029e:	60a2                	ld	ra,8(sp)
    800002a0:	6402                	ld	s0,0(sp)
    800002a2:	0141                	addi	sp,sp,16
    800002a4:	8082                	ret
    uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	6e8000ef          	jal	80000990 <uartputc_sync>
    uartputc_sync(' ');
    800002ac:	02000513          	li	a0,32
    800002b0:	6e0000ef          	jal	80000990 <uartputc_sync>
    uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	6da000ef          	jal	80000990 <uartputc_sync>
    800002ba:	b7d5                	j	8000029e <consputc+0x14>

00000000800002bc <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002bc:	1101                	addi	sp,sp,-32
    800002be:	ec06                	sd	ra,24(sp)
    800002c0:	e822                	sd	s0,16(sp)
    800002c2:	e426                	sd	s1,8(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00012517          	auipc	a0,0x12
    800002cc:	13850513          	addi	a0,a0,312 # 80012400 <cons>
    800002d0:	159000ef          	jal	80000c28 <acquire>

  switch (c) {
    800002d4:	47d5                	li	a5,21
    800002d6:	08f48d63          	beq	s1,a5,80000370 <consoleintr+0xb4>
    800002da:	0297c563          	blt	a5,s1,80000304 <consoleintr+0x48>
    800002de:	47a1                	li	a5,8
    800002e0:	0ef48263          	beq	s1,a5,800003c4 <consoleintr+0x108>
    800002e4:	47c1                	li	a5,16
    800002e6:	10f49363          	bne	s1,a5,800003ec <consoleintr+0x130>
  case C('P'): // Print process list.
    procdump();
    800002ea:	132020ef          	jal	8000241c <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	11250513          	addi	a0,a0,274 # 80012400 <cons>
    800002f6:	1bb000ef          	jal	80000cb0 <release>
}
    800002fa:	60e2                	ld	ra,24(sp)
    800002fc:	6442                	ld	s0,16(sp)
    800002fe:	64a2                	ld	s1,8(sp)
    80000300:	6105                	addi	sp,sp,32
    80000302:	8082                	ret
  switch (c) {
    80000304:	07f00793          	li	a5,127
    80000308:	0af48e63          	beq	s1,a5,800003c4 <consoleintr+0x108>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    8000030c:	00012717          	auipc	a4,0x12
    80000310:	0f470713          	addi	a4,a4,244 # 80012400 <cons>
    80000314:	0a072783          	lw	a5,160(a4)
    80000318:	09872703          	lw	a4,152(a4)
    8000031c:	9f99                	subw	a5,a5,a4
    8000031e:	07f00713          	li	a4,127
    80000322:	fcf766e3          	bltu	a4,a5,800002ee <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000326:	47b5                	li	a5,13
    80000328:	0cf48563          	beq	s1,a5,800003f2 <consoleintr+0x136>
      consputc(c);
    8000032c:	8526                	mv	a0,s1
    8000032e:	f5dff0ef          	jal	8000028a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000332:	00012717          	auipc	a4,0x12
    80000336:	0ce70713          	addi	a4,a4,206 # 80012400 <cons>
    8000033a:	0a072683          	lw	a3,160(a4)
    8000033e:	0016879b          	addiw	a5,a3,1
    80000342:	863e                	mv	a2,a5
    80000344:	0af72023          	sw	a5,160(a4)
    80000348:	07f6f693          	andi	a3,a3,127
    8000034c:	9736                	add	a4,a4,a3
    8000034e:	00970c23          	sb	s1,24(a4)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE) {
    80000352:	ff648713          	addi	a4,s1,-10
    80000356:	c371                	beqz	a4,8000041a <consoleintr+0x15e>
    80000358:	14f1                	addi	s1,s1,-4
    8000035a:	c0e1                	beqz	s1,8000041a <consoleintr+0x15e>
    8000035c:	00012717          	auipc	a4,0x12
    80000360:	13c72703          	lw	a4,316(a4) # 80012498 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	08e70713          	addi	a4,a4,142 # 80012400 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	07e48493          	addi	s1,s1,126 # 80012400 <cons>
    while (cons.e != cons.w &&
    8000038a:	4929                	li	s2,10
    8000038c:	02f70863          	beq	a4,a5,800003bc <consoleintr+0x100>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000390:	37fd                	addiw	a5,a5,-1
    80000392:	07f7f713          	andi	a4,a5,127
    80000396:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    80000398:	01874703          	lbu	a4,24(a4)
    8000039c:	03270263          	beq	a4,s2,800003c0 <consoleintr+0x104>
      cons.e--;
    800003a0:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a4:	10000513          	li	a0,256
    800003a8:	ee3ff0ef          	jal	8000028a <consputc>
    while (cons.e != cons.w &&
    800003ac:	0a04a783          	lw	a5,160(s1)
    800003b0:	09c4a703          	lw	a4,156(s1)
    800003b4:	fcf71ee3          	bne	a4,a5,80000390 <consoleintr+0xd4>
    800003b8:	6902                	ld	s2,0(sp)
    800003ba:	bf15                	j	800002ee <consoleintr+0x32>
    800003bc:	6902                	ld	s2,0(sp)
    800003be:	bf05                	j	800002ee <consoleintr+0x32>
    800003c0:	6902                	ld	s2,0(sp)
    800003c2:	b735                	j	800002ee <consoleintr+0x32>
    if (cons.e != cons.w) {
    800003c4:	00012717          	auipc	a4,0x12
    800003c8:	03c70713          	addi	a4,a4,60 # 80012400 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	0cf72323          	sw	a5,198(a4) # 800124a0 <cons+0xa0>
      consputc(BACKSPACE);
    800003e2:	10000513          	li	a0,256
    800003e6:	ea5ff0ef          	jal	8000028a <consputc>
    800003ea:	b711                	j	800002ee <consoleintr+0x32>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800003ec:	f00481e3          	beqz	s1,800002ee <consoleintr+0x32>
    800003f0:	bf31                	j	8000030c <consoleintr+0x50>
      consputc(c);
    800003f2:	4529                	li	a0,10
    800003f4:	e97ff0ef          	jal	8000028a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003f8:	00012797          	auipc	a5,0x12
    800003fc:	00878793          	addi	a5,a5,8 # 80012400 <cons>
    80000400:	0a07a703          	lw	a4,160(a5)
    80000404:	0017069b          	addiw	a3,a4,1
    80000408:	8636                	mv	a2,a3
    8000040a:	0ad7a023          	sw	a3,160(a5)
    8000040e:	07f77713          	andi	a4,a4,127
    80000412:	97ba                	add	a5,a5,a4
    80000414:	4729                	li	a4,10
    80000416:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000041a:	00012797          	auipc	a5,0x12
    8000041e:	08c7a123          	sw	a2,130(a5) # 8001249c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	07650513          	addi	a0,a0,118 # 80012498 <cons+0x98>
    8000042a:	435010ef          	jal	8000205e <wakeup>
    8000042e:	b5c1                	j	800002ee <consoleintr+0x32>

0000000080000430 <consoleinit>:

void
consoleinit(void)
{
    80000430:	1141                	addi	sp,sp,-16
    80000432:	e406                	sd	ra,8(sp)
    80000434:	e022                	sd	s0,0(sp)
    80000436:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000438:	00007597          	auipc	a1,0x7
    8000043c:	bc858593          	addi	a1,a1,-1080 # 80007000 <etext>
    80000440:	00012517          	auipc	a0,0x12
    80000444:	fc050513          	addi	a0,a0,-64 # 80012400 <cons>
    80000448:	760000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	12078793          	addi	a5,a5,288 # 80022570 <devsw>
    80000458:	00000717          	auipc	a4,0x0
    8000045c:	d2070713          	addi	a4,a4,-736 # 80000178 <consoleread>
    80000460:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000462:	00000717          	auipc	a4,0x0
    80000466:	c7470713          	addi	a4,a4,-908 # 800000d6 <consolewrite>
    8000046a:	ef98                	sd	a4,24(a5)
}
    8000046c:	60a2                	ld	ra,8(sp)
    8000046e:	6402                	ld	s0,0(sp)
    80000470:	0141                	addi	sp,sp,16
    80000472:	8082                	ret

0000000080000474 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000474:	7139                	addi	sp,sp,-64
    80000476:	fc06                	sd	ra,56(sp)
    80000478:	f822                	sd	s0,48(sp)
    8000047a:	f04a                	sd	s2,32(sp)
    8000047c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if (sign && (sign = (xx < 0)))
    8000047e:	c219                	beqz	a2,80000484 <printint+0x10>
    80000480:	08054163          	bltz	a0,80000502 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000484:	4301                	li	t1,0

  i = 0;
    80000486:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000048a:	86ca                	mv	a3,s2
  i = 0;
    8000048c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000048e:	00007817          	auipc	a6,0x7
    80000492:	31a80813          	addi	a6,a6,794 # 800077a8 <digits>
    80000496:	88ba                	mv	a7,a4
    80000498:	0017061b          	addiw	a2,a4,1
    8000049c:	8732                	mv	a4,a2
    8000049e:	02b577b3          	remu	a5,a0,a1
    800004a2:	97c2                	add	a5,a5,a6
    800004a4:	0007c783          	lbu	a5,0(a5)
    800004a8:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
    800004ac:	87aa                	mv	a5,a0
    800004ae:	02b55533          	divu	a0,a0,a1
    800004b2:	0685                	addi	a3,a3,1
    800004b4:	feb7f1e3          	bgeu	a5,a1,80000496 <printint+0x22>

  if (sign)
    800004b8:	00030c63          	beqz	t1,800004d0 <printint+0x5c>
    buf[i++] = '-';
    800004bc:	fe060793          	addi	a5,a2,-32
    800004c0:	00878633          	add	a2,a5,s0
    800004c4:	02d00793          	li	a5,45
    800004c8:	fef60423          	sb	a5,-24(a2)
    800004cc:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
    800004d0:	02e05463          	blez	a4,800004f8 <printint+0x84>
    800004d4:	f426                	sd	s1,40(sp)
    800004d6:	377d                	addiw	a4,a4,-1
    800004d8:	00e904b3          	add	s1,s2,a4
    800004dc:	197d                	addi	s2,s2,-1
    800004de:	993a                	add	s2,s2,a4
    800004e0:	1702                	slli	a4,a4,0x20
    800004e2:	9301                	srli	a4,a4,0x20
    800004e4:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004e8:	0004c503          	lbu	a0,0(s1)
    800004ec:	d9fff0ef          	jal	8000028a <consputc>
  while (--i >= 0)
    800004f0:	14fd                	addi	s1,s1,-1
    800004f2:	ff249be3          	bne	s1,s2,800004e8 <printint+0x74>
    800004f6:	74a2                	ld	s1,40(sp)
}
    800004f8:	70e2                	ld	ra,56(sp)
    800004fa:	7442                	ld	s0,48(sp)
    800004fc:	7902                	ld	s2,32(sp)
    800004fe:	6121                	addi	sp,sp,64
    80000500:	8082                	ret
    x = -xx;
    80000502:	40a00533          	neg	a0,a0
  if (sign && (sign = (xx < 0)))
    80000506:	4305                	li	t1,1
    x = -xx;
    80000508:	bfbd                	j	80000486 <printint+0x12>

000000008000050a <printk>:
}

// Print to the console.
int
printk(char *fmt, ...)
{
    8000050a:	7131                	addi	sp,sp,-192
    8000050c:	fc86                	sd	ra,120(sp)
    8000050e:	f8a2                	sd	s0,112(sp)
    80000510:	f0ca                	sd	s2,96(sp)
    80000512:	0100                	addi	s0,sp,128
    80000514:	892a                	mv	s2,a0
    80000516:	e40c                	sd	a1,8(s0)
    80000518:	e810                	sd	a2,16(s0)
    8000051a:	ec14                	sd	a3,24(s0)
    8000051c:	f018                	sd	a4,32(s0)
    8000051e:	f41c                	sd	a5,40(s0)
    80000520:	03043823          	sd	a6,48(s0)
    80000524:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if (panicking == 0)
    80000528:	0000a797          	auipc	a5,0xa
    8000052c:	eac7a783          	lw	a5,-340(a5) # 8000a3d4 <panicking>
    80000530:	cf9d                	beqz	a5,8000056e <printk+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000532:	00840793          	addi	a5,s0,8
    80000536:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    8000053a:	00094503          	lbu	a0,0(s2)
    8000053e:	22050663          	beqz	a0,8000076a <printk+0x260>
    80000542:	f4a6                	sd	s1,104(sp)
    80000544:	ecce                	sd	s3,88(sp)
    80000546:	e8d2                	sd	s4,80(sp)
    80000548:	e4d6                	sd	s5,72(sp)
    8000054a:	e0da                	sd	s6,64(sp)
    8000054c:	fc5e                	sd	s7,56(sp)
    8000054e:	f862                	sd	s8,48(sp)
    80000550:	f06a                	sd	s10,32(sp)
    80000552:	ec6e                	sd	s11,24(sp)
    80000554:	4a01                	li	s4,0
    if (cx != '%') {
    80000556:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if (c0 == 'u') {
    8000055a:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if (c0 == 'x') {
    8000055e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if (c0 == 'p') {
    80000562:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000566:	4b29                	li	s6,10
    if (c0 == 'd') {
    80000568:	06400b93          	li	s7,100
    8000056c:	a015                	j	80000590 <printk+0x86>
    acquire(&pr.lock);
    8000056e:	00012517          	auipc	a0,0x12
    80000572:	f3a50513          	addi	a0,a0,-198 # 800124a8 <pr>
    80000576:	6b2000ef          	jal	80000c28 <acquire>
    8000057a:	bf65                	j	80000532 <printk+0x28>
      consputc(cx);
    8000057c:	d0fff0ef          	jal	8000028a <consputc>
      continue;
    80000580:	84d2                	mv	s1,s4
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000582:	2485                	addiw	s1,s1,1
    80000584:	8a26                	mv	s4,s1
    80000586:	94ca                	add	s1,s1,s2
    80000588:	0004c503          	lbu	a0,0(s1)
    8000058c:	1c050663          	beqz	a0,80000758 <printk+0x24e>
    if (cx != '%') {
    80000590:	ff3516e3          	bne	a0,s3,8000057c <printk+0x72>
    i++;
    80000594:	001a079b          	addiw	a5,s4,1
    80000598:	84be                	mv	s1,a5
    c0 = fmt[i + 0] & 0xff;
    8000059a:	00f90733          	add	a4,s2,a5
    8000059e:	00074a83          	lbu	s5,0(a4)
    if (c0)
    800005a2:	200a8963          	beqz	s5,800007b4 <printk+0x2aa>
      c1 = fmt[i + 1] & 0xff;
    800005a6:	00174683          	lbu	a3,1(a4)
    if (c1)
    800005aa:	1e068c63          	beqz	a3,800007a2 <printk+0x298>
    if (c0 == 'd') {
    800005ae:	037a8863          	beq	s5,s7,800005de <printk+0xd4>
    } else if (c0 == 'l' && c1 == 'd') {
    800005b2:	f94a8713          	addi	a4,s5,-108
    800005b6:	00173713          	seqz	a4,a4
    800005ba:	f9c68613          	addi	a2,a3,-100
    800005be:	ee05                	bnez	a2,800005f6 <printk+0xec>
    800005c0:	cb1d                	beqz	a4,800005f6 <printk+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005c2:	f8843783          	ld	a5,-120(s0)
    800005c6:	00878713          	addi	a4,a5,8
    800005ca:	f8e43423          	sd	a4,-120(s0)
    800005ce:	4605                	li	a2,1
    800005d0:	85da                	mv	a1,s6
    800005d2:	6388                	ld	a0,0(a5)
    800005d4:	ea1ff0ef          	jal	80000474 <printint>
      i += 1;
    800005d8:	002a049b          	addiw	s1,s4,2
    800005dc:	b75d                	j	80000582 <printk+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005de:	f8843783          	ld	a5,-120(s0)
    800005e2:	00878713          	addi	a4,a5,8
    800005e6:	f8e43423          	sd	a4,-120(s0)
    800005ea:	4605                	li	a2,1
    800005ec:	85da                	mv	a1,s6
    800005ee:	4388                	lw	a0,0(a5)
    800005f0:	e85ff0ef          	jal	80000474 <printint>
    800005f4:	b779                	j	80000582 <printk+0x78>
      c2 = fmt[i + 2] & 0xff;
    800005f6:	97ca                	add	a5,a5,s2
    800005f8:	8636                	mv	a2,a3
    800005fa:	0027c683          	lbu	a3,2(a5)
    800005fe:	a2c9                	j	800007c0 <printk+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    80000600:	f8843783          	ld	a5,-120(s0)
    80000604:	00878713          	addi	a4,a5,8
    80000608:	f8e43423          	sd	a4,-120(s0)
    8000060c:	4605                	li	a2,1
    8000060e:	45a9                	li	a1,10
    80000610:	6388                	ld	a0,0(a5)
    80000612:	e63ff0ef          	jal	80000474 <printint>
      i += 2;
    80000616:	003a049b          	addiw	s1,s4,3
    8000061a:	b7a5                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000061c:	f8843783          	ld	a5,-120(s0)
    80000620:	00878713          	addi	a4,a5,8
    80000624:	f8e43423          	sd	a4,-120(s0)
    80000628:	4601                	li	a2,0
    8000062a:	85da                	mv	a1,s6
    8000062c:	0007e503          	lwu	a0,0(a5)
    80000630:	e45ff0ef          	jal	80000474 <printint>
    80000634:	b7b9                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000636:	f8843783          	ld	a5,-120(s0)
    8000063a:	00878713          	addi	a4,a5,8
    8000063e:	f8e43423          	sd	a4,-120(s0)
    80000642:	4601                	li	a2,0
    80000644:	85da                	mv	a1,s6
    80000646:	6388                	ld	a0,0(a5)
    80000648:	e2dff0ef          	jal	80000474 <printint>
      i += 1;
    8000064c:	002a049b          	addiw	s1,s4,2
    80000650:	bf0d                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000652:	f8843783          	ld	a5,-120(s0)
    80000656:	00878713          	addi	a4,a5,8
    8000065a:	f8e43423          	sd	a4,-120(s0)
    8000065e:	4601                	li	a2,0
    80000660:	45a9                	li	a1,10
    80000662:	6388                	ld	a0,0(a5)
    80000664:	e11ff0ef          	jal	80000474 <printint>
      i += 2;
    80000668:	003a049b          	addiw	s1,s4,3
    8000066c:	bf19                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    8000066e:	f8843783          	ld	a5,-120(s0)
    80000672:	00878713          	addi	a4,a5,8
    80000676:	f8e43423          	sd	a4,-120(s0)
    8000067a:	4601                	li	a2,0
    8000067c:	45c1                	li	a1,16
    8000067e:	0007e503          	lwu	a0,0(a5)
    80000682:	df3ff0ef          	jal	80000474 <printint>
    80000686:	bdf5                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000688:	f8843783          	ld	a5,-120(s0)
    8000068c:	00878713          	addi	a4,a5,8
    80000690:	f8e43423          	sd	a4,-120(s0)
    80000694:	45c1                	li	a1,16
    80000696:	6388                	ld	a0,0(a5)
    80000698:	dddff0ef          	jal	80000474 <printint>
      i += 1;
    8000069c:	002a049b          	addiw	s1,s4,2
    800006a0:	b5cd                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	4601                	li	a2,0
    800006b0:	45c1                	li	a1,16
    800006b2:	6388                	ld	a0,0(a5)
    800006b4:	dc1ff0ef          	jal	80000474 <printint>
      i += 2;
    800006b8:	003a049b          	addiw	s1,s4,3
    800006bc:	b5d9                	j	80000582 <printk+0x78>
    800006be:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006c0:	f8843783          	ld	a5,-120(s0)
    800006c4:	00878713          	addi	a4,a5,8
    800006c8:	f8e43423          	sd	a4,-120(s0)
    800006cc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006d0:	03000513          	li	a0,48
    800006d4:	bb7ff0ef          	jal	8000028a <consputc>
  consputc('x');
    800006d8:	07800513          	li	a0,120
    800006dc:	bafff0ef          	jal	8000028a <consputc>
    800006e0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006e2:	00007c97          	auipc	s9,0x7
    800006e6:	0c6c8c93          	addi	s9,s9,198 # 800077a8 <digits>
    800006ea:	03cad793          	srli	a5,s5,0x3c
    800006ee:	97e6                	add	a5,a5,s9
    800006f0:	0007c503          	lbu	a0,0(a5)
    800006f4:	b97ff0ef          	jal	8000028a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006f8:	0a92                	slli	s5,s5,0x4
    800006fa:	3a7d                	addiw	s4,s4,-1
    800006fc:	fe0a17e3          	bnez	s4,800006ea <printk+0x1e0>
    80000700:	7ca2                	ld	s9,40(sp)
    80000702:	b541                	j	80000582 <printk+0x78>
    } else if (c0 == 'c') {
      consputc(va_arg(ap, uint));
    80000704:	f8843783          	ld	a5,-120(s0)
    80000708:	00878713          	addi	a4,a5,8
    8000070c:	f8e43423          	sd	a4,-120(s0)
    80000710:	4388                	lw	a0,0(a5)
    80000712:	b79ff0ef          	jal	8000028a <consputc>
    80000716:	b5b5                	j	80000582 <printk+0x78>
    } else if (c0 == 's') {
      if ((s = va_arg(ap, char *)) == 0)
    80000718:	f8843783          	ld	a5,-120(s0)
    8000071c:	00878713          	addi	a4,a5,8
    80000720:	f8e43423          	sd	a4,-120(s0)
    80000724:	0007ba03          	ld	s4,0(a5)
    80000728:	000a0d63          	beqz	s4,80000742 <printk+0x238>
        s = "(null)";
      for (; *s; s++)
    8000072c:	000a4503          	lbu	a0,0(s4)
    80000730:	e40509e3          	beqz	a0,80000582 <printk+0x78>
        consputc(*s);
    80000734:	b57ff0ef          	jal	8000028a <consputc>
      for (; *s; s++)
    80000738:	0a05                	addi	s4,s4,1
    8000073a:	000a4503          	lbu	a0,0(s4)
    8000073e:	f97d                	bnez	a0,80000734 <printk+0x22a>
    80000740:	b589                	j	80000582 <printk+0x78>
        s = "(null)";
    80000742:	00007a17          	auipc	s4,0x7
    80000746:	8c6a0a13          	addi	s4,s4,-1850 # 80007008 <etext+0x8>
      for (; *s; s++)
    8000074a:	02800513          	li	a0,40
    8000074e:	b7dd                	j	80000734 <printk+0x22a>
    } else if (c0 == '%') {
      consputc('%');
    80000750:	8556                	mv	a0,s5
    80000752:	b39ff0ef          	jal	8000028a <consputc>
    80000756:	b535                	j	80000582 <printk+0x78>
    80000758:	74a6                	ld	s1,104(sp)
    8000075a:	69e6                	ld	s3,88(sp)
    8000075c:	6a46                	ld	s4,80(sp)
    8000075e:	6aa6                	ld	s5,72(sp)
    80000760:	6b06                	ld	s6,64(sp)
    80000762:	7be2                	ld	s7,56(sp)
    80000764:	7c42                	ld	s8,48(sp)
    80000766:	7d02                	ld	s10,32(sp)
    80000768:	6de2                	ld	s11,24(sp)
      consputc(c0);
    }
  }
  va_end(ap);

  if (panicking == 0)
    8000076a:	0000a797          	auipc	a5,0xa
    8000076e:	c6a7a783          	lw	a5,-918(a5) # 8000a3d4 <panicking>
    80000772:	c38d                	beqz	a5,80000794 <printk+0x28a>
    release(&pr.lock);

  return 0;
}
    80000774:	4501                	li	a0,0
    80000776:	70e6                	ld	ra,120(sp)
    80000778:	7446                	ld	s0,112(sp)
    8000077a:	7906                	ld	s2,96(sp)
    8000077c:	6129                	addi	sp,sp,192
    8000077e:	8082                	ret
    80000780:	74a6                	ld	s1,104(sp)
    80000782:	69e6                	ld	s3,88(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	6aa6                	ld	s5,72(sp)
    80000788:	6b06                	ld	s6,64(sp)
    8000078a:	7be2                	ld	s7,56(sp)
    8000078c:	7c42                	ld	s8,48(sp)
    8000078e:	7d02                	ld	s10,32(sp)
    80000790:	6de2                	ld	s11,24(sp)
    80000792:	bfe1                	j	8000076a <printk+0x260>
    release(&pr.lock);
    80000794:	00012517          	auipc	a0,0x12
    80000798:	d1450513          	addi	a0,a0,-748 # 800124a8 <pr>
    8000079c:	514000ef          	jal	80000cb0 <release>
  return 0;
    800007a0:	bfd1                	j	80000774 <printk+0x26a>
    if (c0 == 'd') {
    800007a2:	e37a8ee3          	beq	s5,s7,800005de <printk+0xd4>
    } else if (c0 == 'l' && c1 == 'd') {
    800007a6:	f94a8713          	addi	a4,s5,-108
    800007aa:	00173713          	seqz	a4,a4
    800007ae:	8636                	mv	a2,a3
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    800007b0:	4781                	li	a5,0
    800007b2:	a00d                	j	800007d4 <printk+0x2ca>
    } else if (c0 == 'l' && c1 == 'd') {
    800007b4:	f94a8713          	addi	a4,s5,-108
    800007b8:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007bc:	8656                	mv	a2,s5
    800007be:	86d6                	mv	a3,s5
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    800007c0:	f9460793          	addi	a5,a2,-108
    800007c4:	0017b793          	seqz	a5,a5
    800007c8:	8ff9                	and	a5,a5,a4
    800007ca:	f9c68593          	addi	a1,a3,-100
    800007ce:	e199                	bnez	a1,800007d4 <printk+0x2ca>
    800007d0:	e20798e3          	bnez	a5,80000600 <printk+0xf6>
    } else if (c0 == 'u') {
    800007d4:	e58a84e3          	beq	s5,s8,8000061c <printk+0x112>
    } else if (c0 == 'l' && c1 == 'u') {
    800007d8:	f8b60593          	addi	a1,a2,-117
    800007dc:	e199                	bnez	a1,800007e2 <printk+0x2d8>
    800007de:	e4071ce3          	bnez	a4,80000636 <printk+0x12c>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    800007e2:	f8b68593          	addi	a1,a3,-117
    800007e6:	e199                	bnez	a1,800007ec <printk+0x2e2>
    800007e8:	e60795e3          	bnez	a5,80000652 <printk+0x148>
    } else if (c0 == 'x') {
    800007ec:	e9aa81e3          	beq	s5,s10,8000066e <printk+0x164>
    } else if (c0 == 'l' && c1 == 'x') {
    800007f0:	f8860613          	addi	a2,a2,-120
    800007f4:	e219                	bnez	a2,800007fa <printk+0x2f0>
    800007f6:	e80719e3          	bnez	a4,80000688 <printk+0x17e>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    800007fa:	f8868693          	addi	a3,a3,-120
    800007fe:	e299                	bnez	a3,80000804 <printk+0x2fa>
    80000800:	ea0791e3          	bnez	a5,800006a2 <printk+0x198>
    } else if (c0 == 'p') {
    80000804:	ebba8de3          	beq	s5,s11,800006be <printk+0x1b4>
    } else if (c0 == 'c') {
    80000808:	06300793          	li	a5,99
    8000080c:	eefa8ce3          	beq	s5,a5,80000704 <printk+0x1fa>
    } else if (c0 == 's') {
    80000810:	07300793          	li	a5,115
    80000814:	f0fa82e3          	beq	s5,a5,80000718 <printk+0x20e>
    } else if (c0 == '%') {
    80000818:	02500793          	li	a5,37
    8000081c:	f2fa8ae3          	beq	s5,a5,80000750 <printk+0x246>
    } else if (c0 == 0) {
    80000820:	f60a80e3          	beqz	s5,80000780 <printk+0x276>
      consputc('%');
    80000824:	02500513          	li	a0,37
    80000828:	a63ff0ef          	jal	8000028a <consputc>
      consputc(c0);
    8000082c:	8556                	mv	a0,s5
    8000082e:	a5dff0ef          	jal	8000028a <consputc>
    80000832:	bb81                	j	80000582 <printk+0x78>

0000000080000834 <panic>:

void
panic(char *s)
{
    80000834:	1101                	addi	sp,sp,-32
    80000836:	ec06                	sd	ra,24(sp)
    80000838:	e822                	sd	s0,16(sp)
    8000083a:	e426                	sd	s1,8(sp)
    8000083c:	e04a                	sd	s2,0(sp)
    8000083e:	1000                	addi	s0,sp,32
    80000840:	892a                	mv	s2,a0
  panicking = 1;
    80000842:	4485                	li	s1,1
    80000844:	0000a797          	auipc	a5,0xa
    80000848:	b897a823          	sw	s1,-1136(a5) # 8000a3d4 <panicking>
  printk("panic: ");
    8000084c:	00006517          	auipc	a0,0x6
    80000850:	7cc50513          	addi	a0,a0,1996 # 80007018 <etext+0x18>
    80000854:	cb7ff0ef          	jal	8000050a <printk>
  printk("%s\n", s);
    80000858:	85ca                	mv	a1,s2
    8000085a:	00006517          	auipc	a0,0x6
    8000085e:	7c650513          	addi	a0,a0,1990 # 80007020 <etext+0x20>
    80000862:	ca9ff0ef          	jal	8000050a <printk>
  panicked = 1; // freeze uart output from other CPUs
    80000866:	0000a797          	auipc	a5,0xa
    8000086a:	b697a523          	sw	s1,-1174(a5) # 8000a3d0 <panicked>
  for (;;)
    8000086e:	a001                	j	8000086e <panic+0x3a>

0000000080000870 <printkinit>:
    ;
}

void
printkinit(void)
{
    80000870:	1141                	addi	sp,sp,-16
    80000872:	e406                	sd	ra,8(sp)
    80000874:	e022                	sd	s0,0(sp)
    80000876:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000878:	00006597          	auipc	a1,0x6
    8000087c:	7b058593          	addi	a1,a1,1968 # 80007028 <etext+0x28>
    80000880:	00012517          	auipc	a0,0x12
    80000884:	c2850513          	addi	a0,a0,-984 # 800124a8 <pr>
    80000888:	320000ef          	jal	80000ba8 <initlock>
}
    8000088c:	60a2                	ld	ra,8(sp)
    8000088e:	6402                	ld	s0,0(sp)
    80000890:	0141                	addi	sp,sp,16
    80000892:	8082                	ret

0000000080000894 <uartinit>:
extern volatile int panicking; // from printk.c
extern volatile int panicked;  // from printk.c

void
uartinit(void)
{
    80000894:	1141                	addi	sp,sp,-16
    80000896:	e406                	sd	ra,8(sp)
    80000898:	e022                	sd	s0,0(sp)
    8000089a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000089c:	100007b7          	lui	a5,0x10000
    800008a0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800008a4:	10000737          	lui	a4,0x10000
    800008a8:	f8000693          	li	a3,-128
    800008ac:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008b0:	468d                	li	a3,3
    800008b2:	10000637          	lui	a2,0x10000
    800008b6:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008be:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008c2:	8732                	mv	a4,a2
    800008c4:	461d                	li	a2,7
    800008c6:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ca:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008ce:	00006597          	auipc	a1,0x6
    800008d2:	76258593          	addi	a1,a1,1890 # 80007030 <etext+0x30>
    800008d6:	00012517          	auipc	a0,0x12
    800008da:	bea50513          	addi	a0,a0,-1046 # 800124c0 <tx_lock>
    800008de:	2ca000ef          	jal	80000ba8 <initlock>
}
    800008e2:	60a2                	ld	ra,8(sp)
    800008e4:	6402                	ld	s0,0(sp)
    800008e6:	0141                	addi	sp,sp,16
    800008e8:	8082                	ret

00000000800008ea <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008ea:	715d                	addi	sp,sp,-80
    800008ec:	e486                	sd	ra,72(sp)
    800008ee:	e0a2                	sd	s0,64(sp)
    800008f0:	fc26                	sd	s1,56(sp)
    800008f2:	ec56                	sd	s5,24(sp)
    800008f4:	0880                	addi	s0,sp,80
    800008f6:	8aaa                	mv	s5,a0
    800008f8:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008fa:	00012517          	auipc	a0,0x12
    800008fe:	bc650513          	addi	a0,a0,-1082 # 800124c0 <tx_lock>
    80000902:	326000ef          	jal	80000c28 <acquire>

  int i = 0;
  while (i < n) {
    80000906:	06905963          	blez	s1,80000978 <uartwrite+0x8e>
    8000090a:	f84a                	sd	s2,48(sp)
    8000090c:	f44e                	sd	s3,40(sp)
    8000090e:	f052                	sd	s4,32(sp)
    80000910:	e85a                	sd	s6,16(sp)
    80000912:	e45e                	sd	s7,8(sp)
    80000914:	8a56                	mv	s4,s5
    80000916:	9aa6                	add	s5,s5,s1
    while (tx_busy != 0) {
    80000918:	0000a917          	auipc	s2,0xa
    8000091c:	ac490913          	addi	s2,s2,-1340 # 8000a3dc <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	ab898993          	addi	s3,s3,-1352 # 8000a3d8 <tx_chan>
      release(&tx_lock);
    80000928:	00012497          	auipc	s1,0x12
    8000092c:	b9848493          	addi	s1,s1,-1128 # 800124c0 <tx_lock>
      sleep();
      acquire(&tx_lock);
    }
    WriteReg(THR, buf[i]);
    80000930:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000934:	4b05                	li	s6,1
    80000936:	a805                	j	80000966 <uartwrite+0x7c>
      sleep_prepare(&tx_chan);
    80000938:	854e                	mv	a0,s3
    8000093a:	6b8010ef          	jal	80001ff2 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	6ea010ef          	jal	8000202e <sleep>
      acquire(&tx_lock);
    80000948:	8526                	mv	a0,s1
    8000094a:	2de000ef          	jal	80000c28 <acquire>
    while (tx_busy != 0) {
    8000094e:	00092783          	lw	a5,0(s2)
    80000952:	f3fd                	bnez	a5,80000938 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000954:	000a4783          	lbu	a5,0(s4)
    80000958:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    8000095c:	01692023          	sw	s6,0(s2)
  while (i < n) {
    80000960:	0a05                	addi	s4,s4,1
    80000962:	015a0663          	beq	s4,s5,8000096e <uartwrite+0x84>
    while (tx_busy != 0) {
    80000966:	00092783          	lw	a5,0(s2)
    8000096a:	f7f9                	bnez	a5,80000938 <uartwrite+0x4e>
    8000096c:	b7e5                	j	80000954 <uartwrite+0x6a>
    8000096e:	7942                	ld	s2,48(sp)
    80000970:	79a2                	ld	s3,40(sp)
    80000972:	7a02                	ld	s4,32(sp)
    80000974:	6b42                	ld	s6,16(sp)
    80000976:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000978:	00012517          	auipc	a0,0x12
    8000097c:	b4850513          	addi	a0,a0,-1208 # 800124c0 <tx_lock>
    80000980:	330000ef          	jal	80000cb0 <release>
}
    80000984:	60a6                	ld	ra,72(sp)
    80000986:	6406                	ld	s0,64(sp)
    80000988:	74e2                	ld	s1,56(sp)
    8000098a:	6ae2                	ld	s5,24(sp)
    8000098c:	6161                	addi	sp,sp,80
    8000098e:	8082                	ret

0000000080000990 <uartputc_sync>:
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000990:	1101                	addi	sp,sp,-32
    80000992:	ec06                	sd	ra,24(sp)
    80000994:	e822                	sd	s0,16(sp)
    80000996:	e426                	sd	s1,8(sp)
    80000998:	1000                	addi	s0,sp,32
    8000099a:	84aa                	mv	s1,a0
  if (panicking == 0)
    8000099c:	0000a797          	auipc	a5,0xa
    800009a0:	a387a783          	lw	a5,-1480(a5) # 8000a3d4 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	a2a7a783          	lw	a5,-1494(a5) # 8000a3d0 <panicked>
    800009ae:	ef85                	bnez	a5,800009e6 <uartputc_sync+0x56>
    for (;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800009b0:	10000737          	lui	a4,0x10000
    800009b4:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    800009b6:	00074783          	lbu	a5,0(a4)
    800009ba:	0207f793          	andi	a5,a5,32
    800009be:	dfe5                	beqz	a5,800009b6 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    800009c0:	0ff4f513          	zext.b	a0,s1
    800009c4:	100007b7          	lui	a5,0x10000
    800009c8:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if (panicking == 0)
    800009cc:	0000a797          	auipc	a5,0xa
    800009d0:	a087a783          	lw	a5,-1528(a5) # 8000a3d4 <panicking>
    800009d4:	cb91                	beqz	a5,800009e8 <uartputc_sync+0x58>
    pop_off();
}
    800009d6:	60e2                	ld	ra,24(sp)
    800009d8:	6442                	ld	s0,16(sp)
    800009da:	64a2                	ld	s1,8(sp)
    800009dc:	6105                	addi	sp,sp,32
    800009de:	8082                	ret
    push_off();
    800009e0:	20e000ef          	jal	80000bee <push_off>
    800009e4:	b7c9                	j	800009a6 <uartputc_sync+0x16>
    for (;;)
    800009e6:	a001                	j	800009e6 <uartputc_sync+0x56>
    pop_off();
    800009e8:	280000ef          	jal	80000c68 <pop_off>
}
    800009ec:	b7ed                	j	800009d6 <uartputc_sync+0x46>

00000000800009ee <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009ee:	1101                	addi	sp,sp,-32
    800009f0:	ec06                	sd	ra,24(sp)
    800009f2:	e822                	sd	s0,16(sp)
    800009f4:	e426                	sd	s1,8(sp)
    800009f6:	e04a                	sd	s2,0(sp)
    800009f8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009fa:	100007b7          	lui	a5,0x10000
    800009fe:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000a02:	00012517          	auipc	a0,0x12
    80000a06:	abe50513          	addi	a0,a0,-1346 # 800124c0 <tx_lock>
    80000a0a:	21e000ef          	jal	80000c28 <acquire>
  if (ReadReg(LSR) & LSR_TX_IDLE) {
    80000a0e:	100007b7          	lui	a5,0x10000
    80000a12:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a16:	0207f793          	andi	a5,a5,32
    80000a1a:	e78d                	bnez	a5,80000a44 <uartintr+0x56>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a1c:	00012517          	auipc	a0,0x12
    80000a20:	aa450513          	addi	a0,a0,-1372 # 800124c0 <tx_lock>
    80000a24:	28c000ef          	jal	80000cb0 <release>
  if (ReadReg(LSR) & LSR_RX_READY) {
    80000a28:	100004b7          	lui	s1,0x10000
    80000a2c:	0495                	addi	s1,s1,5 # 10000005 <_entry-0x6ffffffb>
    return ReadReg(RHR);
    80000a2e:	10000937          	lui	s2,0x10000
  if (ReadReg(LSR) & LSR_RX_READY) {
    80000a32:	0004c783          	lbu	a5,0(s1)
    80000a36:	8b85                	andi	a5,a5,1
    80000a38:	c38d                	beqz	a5,80000a5a <uartintr+0x6c>
    return ReadReg(RHR);
    80000a3a:	00094503          	lbu	a0,0(s2) # 10000000 <_entry-0x70000000>
  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc();
    if (c == -1)
      break;
    consoleintr(c);
    80000a3e:	87fff0ef          	jal	800002bc <consoleintr>
  while (1) {
    80000a42:	bfc5                	j	80000a32 <uartintr+0x44>
    tx_busy = 0;
    80000a44:	0000a797          	auipc	a5,0xa
    80000a48:	9807ac23          	sw	zero,-1640(a5) # 8000a3dc <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	98c50513          	addi	a0,a0,-1652 # 8000a3d8 <tx_chan>
    80000a54:	60a010ef          	jal	8000205e <wakeup>
    80000a58:	b7d1                	j	80000a1c <uartintr+0x2e>
  }
}
    80000a5a:	60e2                	ld	ra,24(sp)
    80000a5c:	6442                	ld	s0,16(sp)
    80000a5e:	64a2                	ld	s1,8(sp)
    80000a60:	6902                	ld	s2,0(sp)
    80000a62:	6105                	addi	sp,sp,32
    80000a64:	8082                	ret

0000000080000a66 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a66:	1101                	addi	sp,sp,-32
    80000a68:	ec06                	sd	ra,24(sp)
    80000a6a:	e822                	sd	s0,16(sp)
    80000a6c:	e426                	sd	s1,8(sp)
    80000a6e:	e04a                	sd	s2,0(sp)
    80000a70:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a72:	00023797          	auipc	a5,0x23
    80000a76:	c9678793          	addi	a5,a5,-874 # 80023708 <end>
    80000a7a:	00f53733          	sltu	a4,a0,a5
    80000a7e:	47c5                	li	a5,17
    80000a80:	07ee                	slli	a5,a5,0x1b
    80000a82:	17fd                	addi	a5,a5,-1
    80000a84:	00a7b7b3          	sltu	a5,a5,a0
    80000a88:	8fd9                	or	a5,a5,a4
    80000a8a:	ef95                	bnez	a5,80000ac6 <kfree+0x60>
    80000a8c:	84aa                	mv	s1,a0
    80000a8e:	03451793          	slli	a5,a0,0x34
    80000a92:	eb95                	bnez	a5,80000ac6 <kfree+0x60>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a94:	6605                	lui	a2,0x1
    80000a96:	4585                	li	a1,1
    80000a98:	250000ef          	jal	80000ce8 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a9c:	00012917          	auipc	s2,0x12
    80000aa0:	a3c90913          	addi	s2,s2,-1476 # 800124d8 <kmem>
    80000aa4:	854a                	mv	a0,s2
    80000aa6:	182000ef          	jal	80000c28 <acquire>
  r->next = kmem.freelist;
    80000aaa:	01893783          	ld	a5,24(s2)
    80000aae:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ab0:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000ab4:	854a                	mv	a0,s2
    80000ab6:	1fa000ef          	jal	80000cb0 <release>
}
    80000aba:	60e2                	ld	ra,24(sp)
    80000abc:	6442                	ld	s0,16(sp)
    80000abe:	64a2                	ld	s1,8(sp)
    80000ac0:	6902                	ld	s2,0(sp)
    80000ac2:	6105                	addi	sp,sp,32
    80000ac4:	8082                	ret
    panic("kfree");
    80000ac6:	00006517          	auipc	a0,0x6
    80000aca:	57250513          	addi	a0,a0,1394 # 80007038 <etext+0x38>
    80000ace:	d67ff0ef          	jal	80000834 <panic>

0000000080000ad2 <freerange>:
{
    80000ad2:	7179                	addi	sp,sp,-48
    80000ad4:	f406                	sd	ra,40(sp)
    80000ad6:	f022                	sd	s0,32(sp)
    80000ad8:	ec26                	sd	s1,24(sp)
    80000ada:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000adc:	6785                	lui	a5,0x1
    80000ade:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ae2:	00e504b3          	add	s1,a0,a4
    80000ae6:	777d                	lui	a4,0xfffff
    80000ae8:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000aea:	94be                	add	s1,s1,a5
    80000aec:	0295e263          	bltu	a1,s1,80000b10 <freerange+0x3e>
    80000af0:	e84a                	sd	s2,16(sp)
    80000af2:	e44e                	sd	s3,8(sp)
    80000af4:	e052                	sd	s4,0(sp)
    80000af6:	892e                	mv	s2,a1
    kfree(p);
    80000af8:	8a3a                	mv	s4,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000afa:	89be                	mv	s3,a5
    kfree(p);
    80000afc:	01448533          	add	a0,s1,s4
    80000b00:	f67ff0ef          	jal	80000a66 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b04:	94ce                	add	s1,s1,s3
    80000b06:	fe997be3          	bgeu	s2,s1,80000afc <freerange+0x2a>
    80000b0a:	6942                	ld	s2,16(sp)
    80000b0c:	69a2                	ld	s3,8(sp)
    80000b0e:	6a02                	ld	s4,0(sp)
}
    80000b10:	70a2                	ld	ra,40(sp)
    80000b12:	7402                	ld	s0,32(sp)
    80000b14:	64e2                	ld	s1,24(sp)
    80000b16:	6145                	addi	sp,sp,48
    80000b18:	8082                	ret

0000000080000b1a <kinit>:
{
    80000b1a:	1141                	addi	sp,sp,-16
    80000b1c:	e406                	sd	ra,8(sp)
    80000b1e:	e022                	sd	s0,0(sp)
    80000b20:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b22:	00006597          	auipc	a1,0x6
    80000b26:	51e58593          	addi	a1,a1,1310 # 80007040 <etext+0x40>
    80000b2a:	00012517          	auipc	a0,0x12
    80000b2e:	9ae50513          	addi	a0,a0,-1618 # 800124d8 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00023517          	auipc	a0,0x23
    80000b3e:	bce50513          	addi	a0,a0,-1074 # 80023708 <end>
    80000b42:	f91ff0ef          	jal	80000ad2 <freerange>
}
    80000b46:	60a2                	ld	ra,8(sp)
    80000b48:	6402                	ld	s0,0(sp)
    80000b4a:	0141                	addi	sp,sp,16
    80000b4c:	8082                	ret

0000000080000b4e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b4e:	1101                	addi	sp,sp,-32
    80000b50:	ec06                	sd	ra,24(sp)
    80000b52:	e822                	sd	s0,16(sp)
    80000b54:	e426                	sd	s1,8(sp)
    80000b56:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b58:	00012517          	auipc	a0,0x12
    80000b5c:	98050513          	addi	a0,a0,-1664 # 800124d8 <kmem>
    80000b60:	0c8000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b64:	00012497          	auipc	s1,0x12
    80000b68:	98c4b483          	ld	s1,-1652(s1) # 800124f0 <kmem+0x18>
  if (r)
    80000b6c:	c49d                	beqz	s1,80000b9a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00012717          	auipc	a4,0x12
    80000b74:	98f73023          	sd	a5,-1664(a4) # 800124f0 <kmem+0x18>
  release(&kmem.lock);
    80000b78:	00012517          	auipc	a0,0x12
    80000b7c:	96050513          	addi	a0,a0,-1696 # 800124d8 <kmem>
    80000b80:	130000ef          	jal	80000cb0 <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000b84:	6605                	lui	a2,0x1
    80000b86:	4595                	li	a1,5
    80000b88:	8526                	mv	a0,s1
    80000b8a:	15e000ef          	jal	80000ce8 <memset>
  return (void *)r;
}
    80000b8e:	8526                	mv	a0,s1
    80000b90:	60e2                	ld	ra,24(sp)
    80000b92:	6442                	ld	s0,16(sp)
    80000b94:	64a2                	ld	s1,8(sp)
    80000b96:	6105                	addi	sp,sp,32
    80000b98:	8082                	ret
  release(&kmem.lock);
    80000b9a:	00012517          	auipc	a0,0x12
    80000b9e:	93e50513          	addi	a0,a0,-1730 # 800124d8 <kmem>
    80000ba2:	10e000ef          	jal	80000cb0 <release>
  if (r)
    80000ba6:	b7e5                	j	80000b8e <kalloc+0x40>

0000000080000ba8 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000ba8:	1141                	addi	sp,sp,-16
    80000baa:	e406                	sd	ra,8(sp)
    80000bac:	e022                	sd	s0,0(sp)
    80000bae:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bb0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bb2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb6:	00053823          	sd	zero,16(a0)
}
    80000bba:	60a2                	ld	ra,8(sp)
    80000bbc:	6402                	ld	s0,0(sp)
    80000bbe:	0141                	addi	sp,sp,16
    80000bc0:	8082                	ret

0000000080000bc2 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bc2:	411c                	lw	a5,0(a0)
    80000bc4:	e399                	bnez	a5,80000bca <holding+0x8>
    80000bc6:	4501                	li	a0,0
  return r;
}
    80000bc8:	8082                	ret
{
    80000bca:	1101                	addi	sp,sp,-32
    80000bcc:	ec06                	sd	ra,24(sp)
    80000bce:	e822                	sd	s0,16(sp)
    80000bd0:	e426                	sd	s1,8(sp)
    80000bd2:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bd4:	691c                	ld	a5,16(a0)
    80000bd6:	84be                	mv	s1,a5
    80000bd8:	5f1000ef          	jal	800019c8 <mycpu>
    80000bdc:	40a48533          	sub	a0,s1,a0
    80000be0:	00153513          	seqz	a0,a0
}
    80000be4:	60e2                	ld	ra,24(sp)
    80000be6:	6442                	ld	s0,16(sp)
    80000be8:	64a2                	ld	s1,8(sp)
    80000bea:	6105                	addi	sp,sp,32
    80000bec:	8082                	ret

0000000080000bee <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bee:	1101                	addi	sp,sp,-32
    80000bf0:	ec06                	sd	ra,24(sp)
    80000bf2:	e822                	sd	s0,16(sp)
    80000bf4:	e426                	sd	s1,8(sp)
    80000bf6:	1000                	addi	s0,sp,32
  __asm__ __volatile__("csrrc %0, sstatus, %1" : "=r"(x) : "rK"(x) : "memory");
    80000bf8:	100177f3          	csrrci	a5,sstatus,2
    80000bfc:	84be                	mv	s1,a5
  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  uint64 flags = rc_sstatus(SSTATUS_SIE);
  int old = !!(flags & SSTATUS_SIE);

  if (mycpu()->noff == 0)
    80000bfe:	5cb000ef          	jal	800019c8 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x2c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	5c3000ef          	jal	800019c8 <mycpu>
    80000c0a:	5d3c                	lw	a5,120(a0)
    80000c0c:	2785                	addiw	a5,a5,1
    80000c0e:	dd3c                	sw	a5,120(a0)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    mycpu()->intena = old;
    80000c1a:	5af000ef          	jal	800019c8 <mycpu>
  int old = !!(flags & SSTATUS_SIE);
    80000c1e:	0014d793          	srli	a5,s1,0x1
    80000c22:	8b85                	andi	a5,a5,1
    mycpu()->intena = old;
    80000c24:	dd7c                	sw	a5,124(a0)
    80000c26:	b7c5                	j	80000c06 <push_off+0x18>

0000000080000c28 <acquire>:
{
    80000c28:	1101                	addi	sp,sp,-32
    80000c2a:	ec06                	sd	ra,24(sp)
    80000c2c:	e822                	sd	s0,16(sp)
    80000c2e:	e426                	sd	s1,8(sp)
    80000c30:	1000                	addi	s0,sp,32
    80000c32:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c34:	fbbff0ef          	jal	80000bee <push_off>
  if (holding(lk))
    80000c38:	8526                	mv	a0,s1
    80000c3a:	f89ff0ef          	jal	80000bc2 <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000c3e:	4705                	li	a4,1
  if (holding(lk))
    80000c40:	ed11                	bnez	a0,80000c5c <acquire+0x34>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000c42:	87ba                	mv	a5,a4
    80000c44:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c48:	2781                	sext.w	a5,a5
    80000c4a:	ffe5                	bnez	a5,80000c42 <acquire+0x1a>
  lk->cpu = mycpu();
    80000c4c:	57d000ef          	jal	800019c8 <mycpu>
    80000c50:	e888                	sd	a0,16(s1)
}
    80000c52:	60e2                	ld	ra,24(sp)
    80000c54:	6442                	ld	s0,16(sp)
    80000c56:	64a2                	ld	s1,8(sp)
    80000c58:	6105                	addi	sp,sp,32
    80000c5a:	8082                	ret
    panic("acquire");
    80000c5c:	00006517          	auipc	a0,0x6
    80000c60:	3ec50513          	addi	a0,a0,1004 # 80007048 <etext+0x48>
    80000c64:	bd1ff0ef          	jal	80000834 <panic>

0000000080000c68 <pop_off>:

void
pop_off(void)
{
    80000c68:	1141                	addi	sp,sp,-16
    80000c6a:	e406                	sd	ra,8(sp)
    80000c6c:	e022                	sd	s0,0(sp)
    80000c6e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c70:	559000ef          	jal	800019c8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c74:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c78:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000c7a:	ef99                	bnez	a5,80000c98 <pop_off+0x30>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000c7c:	5d3c                	lw	a5,120(a0)
    80000c7e:	02f05363          	blez	a5,80000ca4 <pop_off+0x3c>
    panic("pop_off");
  c->noff -= 1;
    80000c82:	37fd                	addiw	a5,a5,-1
    80000c84:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000c86:	e789                	bnez	a5,80000c90 <pop_off+0x28>
    80000c88:	5d7c                	lw	a5,124(a0)
    80000c8a:	c399                	beqz	a5,80000c90 <pop_off+0x28>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80000c8c:	10016073          	csrsi	sstatus,2
    intr_on();
}
    80000c90:	60a2                	ld	ra,8(sp)
    80000c92:	6402                	ld	s0,0(sp)
    80000c94:	0141                	addi	sp,sp,16
    80000c96:	8082                	ret
    panic("pop_off - interruptible");
    80000c98:	00006517          	auipc	a0,0x6
    80000c9c:	3b850513          	addi	a0,a0,952 # 80007050 <etext+0x50>
    80000ca0:	b95ff0ef          	jal	80000834 <panic>
    panic("pop_off");
    80000ca4:	00006517          	auipc	a0,0x6
    80000ca8:	3c450513          	addi	a0,a0,964 # 80007068 <etext+0x68>
    80000cac:	b89ff0ef          	jal	80000834 <panic>

0000000080000cb0 <release>:
{
    80000cb0:	1101                	addi	sp,sp,-32
    80000cb2:	ec06                	sd	ra,24(sp)
    80000cb4:	e822                	sd	s0,16(sp)
    80000cb6:	e426                	sd	s1,8(sp)
    80000cb8:	1000                	addi	s0,sp,32
    80000cba:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000cbc:	f07ff0ef          	jal	80000bc2 <holding>
    80000cc0:	cd11                	beqz	a0,80000cdc <release+0x2c>
  lk->cpu = 0;
    80000cc2:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000cc6:	0310000f          	fence	rw,w
    80000cca:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cce:	f9bff0ef          	jal	80000c68 <pop_off>
}
    80000cd2:	60e2                	ld	ra,24(sp)
    80000cd4:	6442                	ld	s0,16(sp)
    80000cd6:	64a2                	ld	s1,8(sp)
    80000cd8:	6105                	addi	sp,sp,32
    80000cda:	8082                	ret
    panic("release");
    80000cdc:	00006517          	auipc	a0,0x6
    80000ce0:	39450513          	addi	a0,a0,916 # 80007070 <etext+0x70>
    80000ce4:	b51ff0ef          	jal	80000834 <panic>

0000000080000ce8 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000ce8:	1141                	addi	sp,sp,-16
    80000cea:	e406                	sd	ra,8(sp)
    80000cec:	e022                	sd	s0,0(sp)
    80000cee:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000cf0:	ca19                	beqz	a2,80000d06 <memset+0x1e>
    80000cf2:	87aa                	mv	a5,a0
    80000cf4:	1602                	slli	a2,a2,0x20
    80000cf6:	9201                	srli	a2,a2,0x20
    80000cf8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cfc:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000d00:	0785                	addi	a5,a5,1
    80000d02:	fee79de3          	bne	a5,a4,80000cfc <memset+0x14>
  }
  return dst;
}
    80000d06:	60a2                	ld	ra,8(sp)
    80000d08:	6402                	ld	s0,0(sp)
    80000d0a:	0141                	addi	sp,sp,16
    80000d0c:	8082                	ret

0000000080000d0e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d0e:	1141                	addi	sp,sp,-16
    80000d10:	e406                	sd	ra,8(sp)
    80000d12:	e022                	sd	s0,0(sp)
    80000d14:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000d16:	c61d                	beqz	a2,80000d44 <memcmp+0x36>
    80000d18:	1602                	slli	a2,a2,0x20
    80000d1a:	9201                	srli	a2,a2,0x20
    80000d1c:	00c506b3          	add	a3,a0,a2
    if (*s1 != *s2)
    80000d20:	00054783          	lbu	a5,0(a0)
    80000d24:	0005c703          	lbu	a4,0(a1)
    80000d28:	00e79863          	bne	a5,a4,80000d38 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d2c:	0505                	addi	a0,a0,1
    80000d2e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000d30:	fed518e3          	bne	a0,a3,80000d20 <memcmp+0x12>
  }

  return 0;
    80000d34:	4501                	li	a0,0
    80000d36:	a019                	j	80000d3c <memcmp+0x2e>
      return *s1 - *s2;
    80000d38:	40e7853b          	subw	a0,a5,a4
}
    80000d3c:	60a2                	ld	ra,8(sp)
    80000d3e:	6402                	ld	s0,0(sp)
    80000d40:	0141                	addi	sp,sp,16
    80000d42:	8082                	ret
  return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	bfdd                	j	80000d3c <memcmp+0x2e>

0000000080000d48 <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000d48:	1141                	addi	sp,sp,-16
    80000d4a:	e406                	sd	ra,8(sp)
    80000d4c:	e022                	sd	s0,0(sp)
    80000d4e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000d50:	c205                	beqz	a2,80000d70 <memmove+0x28>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000d52:	02a5e363          	bltu	a1,a0,80000d78 <memmove+0x30>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000d56:	1602                	slli	a2,a2,0x20
    80000d58:	9201                	srli	a2,a2,0x20
    80000d5a:	00c587b3          	add	a5,a1,a2
{
    80000d5e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d60:	0585                	addi	a1,a1,1
    80000d62:	0705                	addi	a4,a4,1
    80000d64:	fff5c683          	lbu	a3,-1(a1)
    80000d68:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000d6c:	feb79ae3          	bne	a5,a1,80000d60 <memmove+0x18>

  return dst;
}
    80000d70:	60a2                	ld	ra,8(sp)
    80000d72:	6402                	ld	s0,0(sp)
    80000d74:	0141                	addi	sp,sp,16
    80000d76:	8082                	ret
  if (s < d && s + n > d) {
    80000d78:	02061693          	slli	a3,a2,0x20
    80000d7c:	9281                	srli	a3,a3,0x20
    80000d7e:	00d58733          	add	a4,a1,a3
    80000d82:	fce57ae3          	bgeu	a0,a4,80000d56 <memmove+0xe>
    d += n;
    80000d86:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000d88:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000d8c:	1782                	slli	a5,a5,0x20
    80000d8e:	9381                	srli	a5,a5,0x20
    80000d90:	fff7c793          	not	a5,a5
    80000d94:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d96:	177d                	addi	a4,a4,-1
    80000d98:	16fd                	addi	a3,a3,-1
    80000d9a:	00074603          	lbu	a2,0(a4)
    80000d9e:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000da2:	fee79ae3          	bne	a5,a4,80000d96 <memmove+0x4e>
    80000da6:	b7e9                	j	80000d70 <memmove+0x28>

0000000080000da8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000da8:	1141                	addi	sp,sp,-16
    80000daa:	e406                	sd	ra,8(sp)
    80000dac:	e022                	sd	s0,0(sp)
    80000dae:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000db0:	f99ff0ef          	jal	80000d48 <memmove>
}
    80000db4:	60a2                	ld	ra,8(sp)
    80000db6:	6402                	ld	s0,0(sp)
    80000db8:	0141                	addi	sp,sp,16
    80000dba:	8082                	ret

0000000080000dbc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dbc:	1141                	addi	sp,sp,-16
    80000dbe:	e406                	sd	ra,8(sp)
    80000dc0:	e022                	sd	s0,0(sp)
    80000dc2:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000dc4:	ce11                	beqz	a2,80000de0 <strncmp+0x24>
    80000dc6:	00054783          	lbu	a5,0(a0)
    80000dca:	cf89                	beqz	a5,80000de4 <strncmp+0x28>
    80000dcc:	0005c703          	lbu	a4,0(a1)
    80000dd0:	00f71a63          	bne	a4,a5,80000de4 <strncmp+0x28>
    n--, p++, q++;
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	0505                	addi	a0,a0,1
    80000dd8:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000dda:	f675                	bnez	a2,80000dc6 <strncmp+0xa>
  if (n == 0)
    return 0;
    80000ddc:	4501                	li	a0,0
    80000dde:	a801                	j	80000dee <strncmp+0x32>
    80000de0:	4501                	li	a0,0
    80000de2:	a031                	j	80000dee <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000de4:	00054503          	lbu	a0,0(a0)
    80000de8:	0005c783          	lbu	a5,0(a1)
    80000dec:	9d1d                	subw	a0,a0,a5
}
    80000dee:	60a2                	ld	ra,8(sp)
    80000df0:	6402                	ld	s0,0(sp)
    80000df2:	0141                	addi	sp,sp,16
    80000df4:	8082                	ret

0000000080000df6 <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000df6:	1141                	addi	sp,sp,-16
    80000df8:	e406                	sd	ra,8(sp)
    80000dfa:	e022                	sd	s0,0(sp)
    80000dfc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000dfe:	87aa                	mv	a5,a0
    80000e00:	a011                	j	80000e04 <strncpy+0xe>
    80000e02:	8636                	mv	a2,a3
    80000e04:	02c05863          	blez	a2,80000e34 <strncpy+0x3e>
    80000e08:	fff6069b          	addiw	a3,a2,-1
    80000e0c:	8836                	mv	a6,a3
    80000e0e:	0785                	addi	a5,a5,1
    80000e10:	0005c703          	lbu	a4,0(a1)
    80000e14:	fee78fa3          	sb	a4,-1(a5)
    80000e18:	0585                	addi	a1,a1,1
    80000e1a:	f765                	bnez	a4,80000e02 <strncpy+0xc>
    ;
  while (n-- > 0)
    80000e1c:	873e                	mv	a4,a5
    80000e1e:	01005b63          	blez	a6,80000e34 <strncpy+0x3e>
    80000e22:	9fb1                	addw	a5,a5,a2
    80000e24:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e26:	0705                	addi	a4,a4,1
    80000e28:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000e2c:	40e786bb          	subw	a3,a5,a4
    80000e30:	fed04be3          	bgtz	a3,80000e26 <strncpy+0x30>
  return os;
}
    80000e34:	60a2                	ld	ra,8(sp)
    80000e36:	6402                	ld	s0,0(sp)
    80000e38:	0141                	addi	sp,sp,16
    80000e3a:	8082                	ret

0000000080000e3c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000e3c:	1141                	addi	sp,sp,-16
    80000e3e:	e406                	sd	ra,8(sp)
    80000e40:	e022                	sd	s0,0(sp)
    80000e42:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000e44:	02c05363          	blez	a2,80000e6a <safestrcpy+0x2e>
    80000e48:	fff6069b          	addiw	a3,a2,-1
    80000e4c:	1682                	slli	a3,a3,0x20
    80000e4e:	9281                	srli	a3,a3,0x20
    80000e50:	96ae                	add	a3,a3,a1
    80000e52:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000e54:	00d58963          	beq	a1,a3,80000e66 <safestrcpy+0x2a>
    80000e58:	0585                	addi	a1,a1,1
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff5c703          	lbu	a4,-1(a1)
    80000e60:	fee78fa3          	sb	a4,-1(a5)
    80000e64:	fb65                	bnez	a4,80000e54 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e66:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e6a:	60a2                	ld	ra,8(sp)
    80000e6c:	6402                	ld	s0,0(sp)
    80000e6e:	0141                	addi	sp,sp,16
    80000e70:	8082                	ret

0000000080000e72 <strlen>:

int
strlen(const char *s)
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000e7a:	00054783          	lbu	a5,0(a0)
    80000e7e:	cf91                	beqz	a5,80000e9a <strlen+0x28>
    80000e80:	00150793          	addi	a5,a0,1
    80000e84:	86be                	mv	a3,a5
    80000e86:	0785                	addi	a5,a5,1
    80000e88:	fff7c703          	lbu	a4,-1(a5)
    80000e8c:	ff65                	bnez	a4,80000e84 <strlen+0x12>
    80000e8e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000e92:	60a2                	ld	ra,8(sp)
    80000e94:	6402                	ld	s0,0(sp)
    80000e96:	0141                	addi	sp,sp,16
    80000e98:	8082                	ret
  for (n = 0; s[n]; n++)
    80000e9a:	4501                	li	a0,0
    80000e9c:	bfdd                	j	80000e92 <strlen+0x20>

0000000080000e9e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e9e:	1141                	addi	sp,sp,-16
    80000ea0:	e406                	sd	ra,8(sp)
    80000ea2:	e022                	sd	s0,0(sp)
    80000ea4:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000ea6:	30f000ef          	jal	800019b4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eaa:	00009717          	auipc	a4,0x9
    80000eae:	53670713          	addi	a4,a4,1334 # 8000a3e0 <started>
  if (cpuid() == 0) {
    80000eb2:	c51d                	beqz	a0,80000ee0 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eb4:	431c                	lw	a5,0(a4)
    80000eb6:	0230000f          	fence	r,rw
    80000eba:	2781                	sext.w	a5,a5
    80000ebc:	dfe5                	beqz	a5,80000eb4 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000ebe:	2f7000ef          	jal	800019b4 <cpuid>
    80000ec2:	85aa                	mv	a1,a0
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1d450513          	addi	a0,a0,468 # 80007098 <etext+0x98>
    80000ecc:	e3eff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000ed0:	082000ef          	jal	80000f52 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000ed4:	67a010ef          	jal	8000254e <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	091040ef          	jal	80005768 <plicinithart>
  }

  scheduler();
    80000edc:	77b000ef          	jal	80001e56 <scheduler>
    consoleinit();
    80000ee0:	d50ff0ef          	jal	80000430 <consoleinit>
    printkinit();
    80000ee4:	98dff0ef          	jal	80000870 <printkinit>
    printk("\n");
    80000ee8:	00006517          	auipc	a0,0x6
    80000eec:	19050513          	addi	a0,a0,400 # 80007078 <etext+0x78>
    80000ef0:	e1aff0ef          	jal	8000050a <printk>
    printk("xv6 kernel is booting\n");
    80000ef4:	00006517          	auipc	a0,0x6
    80000ef8:	18c50513          	addi	a0,a0,396 # 80007080 <etext+0x80>
    80000efc:	e0eff0ef          	jal	8000050a <printk>
    printk("\n");
    80000f00:	00006517          	auipc	a0,0x6
    80000f04:	17850513          	addi	a0,a0,376 # 80007078 <etext+0x78>
    80000f08:	e02ff0ef          	jal	8000050a <printk>
    kinit();            // physical page allocator
    80000f0c:	c0fff0ef          	jal	80000b1a <kinit>
    kvminit();          // create kernel page table
    80000f10:	2ce000ef          	jal	800011de <kvminit>
    kvminithart();      // turn on paging
    80000f14:	03e000ef          	jal	80000f52 <kvminithart>
    procinit();         // process table
    80000f18:	1e7000ef          	jal	800018fe <procinit>
    trapinit();         // trap vectors
    80000f1c:	60e010ef          	jal	8000252a <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	62e010ef          	jal	8000254e <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	02b040ef          	jal	8000574e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	041040ef          	jal	80005768 <plicinithart>
    binit();            // buffer cache
    80000f2c:	4e3010ef          	jal	80002c0e <binit>
    iinit();            // inode table
    80000f30:	234020ef          	jal	80003164 <iinit>
    fileinit();         // file table
    80000f34:	262030ef          	jal	80004196 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	127040ef          	jal	8000585e <virtio_disk_init>
    userinit();         // first user process
    80000f3c:	56f000ef          	jal	80001caa <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f40:	00009797          	auipc	a5,0x9
    80000f44:	4a078793          	addi	a5,a5,1184 # 8000a3e0 <started>
    80000f48:	4705                	li	a4,1
    80000f4a:	0310000f          	fence	rw,w
    80000f4e:	c398                	sw	a4,0(a5)
    80000f50:	b771                	j	80000edc <main+0x3e>

0000000080000f52 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f52:	1141                	addi	sp,sp,-16
    80000f54:	e406                	sd	ra,8(sp)
    80000f56:	e022                	sd	s0,0(sp)
    80000f58:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f5a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f5e:	00009797          	auipc	a5,0x9
    80000f62:	48a7b783          	ld	a5,1162(a5) # 8000a3e8 <kernel_pagetable>
    80000f66:	83b1                	srli	a5,a5,0xc
    80000f68:	577d                	li	a4,-1
    80000f6a:	177e                	slli	a4,a4,0x3f
    80000f6c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000f6e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f72:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f76:	60a2                	ld	ra,8(sp)
    80000f78:	6402                	ld	s0,0(sp)
    80000f7a:	0141                	addi	sp,sp,16
    80000f7c:	8082                	ret

0000000080000f7e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f7e:	7139                	addi	sp,sp,-64
    80000f80:	fc06                	sd	ra,56(sp)
    80000f82:	f822                	sd	s0,48(sp)
    80000f84:	f426                	sd	s1,40(sp)
    80000f86:	f04a                	sd	s2,32(sp)
    80000f88:	ec4e                	sd	s3,24(sp)
    80000f8a:	e852                	sd	s4,16(sp)
    80000f8c:	e456                	sd	s5,8(sp)
    80000f8e:	e05a                	sd	s6,0(sp)
    80000f90:	0080                	addi	s0,sp,64
    80000f92:	84aa                	mv	s1,a0
    80000f94:	89ae                	mv	s3,a1
    80000f96:	8b32                	mv	s6,a2
  if (va >= MAXVA)
    80000f98:	57fd                	li	a5,-1
    80000f9a:	83e9                	srli	a5,a5,0x1a
    80000f9c:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000f9e:	4ab1                	li	s5,12
  if (va >= MAXVA)
    80000fa0:	04b7e263          	bltu	a5,a1,80000fe4 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fa4:	0149d933          	srl	s2,s3,s4
    80000fa8:	1ff97913          	andi	s2,s2,511
    80000fac:	090e                	slli	s2,s2,0x3
    80000fae:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000fb0:	00093483          	ld	s1,0(s2)
    80000fb4:	0014f793          	andi	a5,s1,1
    80000fb8:	cf85                	beqz	a5,80000ff0 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fba:	80a9                	srli	s1,s1,0xa
    80000fbc:	04b2                	slli	s1,s1,0xc
  for (int level = 2; level > 0; level--) {
    80000fbe:	3a5d                	addiw	s4,s4,-9
    80000fc0:	ff5a12e3          	bne	s4,s5,80000fa4 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fc4:	00c9d513          	srli	a0,s3,0xc
    80000fc8:	1ff57513          	andi	a0,a0,511
    80000fcc:	050e                	slli	a0,a0,0x3
    80000fce:	9526                	add	a0,a0,s1
}
    80000fd0:	70e2                	ld	ra,56(sp)
    80000fd2:	7442                	ld	s0,48(sp)
    80000fd4:	74a2                	ld	s1,40(sp)
    80000fd6:	7902                	ld	s2,32(sp)
    80000fd8:	69e2                	ld	s3,24(sp)
    80000fda:	6a42                	ld	s4,16(sp)
    80000fdc:	6aa2                	ld	s5,8(sp)
    80000fde:	6b02                	ld	s6,0(sp)
    80000fe0:	6121                	addi	sp,sp,64
    80000fe2:	8082                	ret
    panic("walk");
    80000fe4:	00006517          	auipc	a0,0x6
    80000fe8:	0cc50513          	addi	a0,a0,204 # 800070b0 <etext+0xb0>
    80000fec:	849ff0ef          	jal	80000834 <panic>
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000ff0:	020b0263          	beqz	s6,80001014 <walk+0x96>
    80000ff4:	b5bff0ef          	jal	80000b4e <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	d979                	beqz	a0,80000fd0 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	ce9ff0ef          	jal	80000ce8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001004:	00c4d793          	srli	a5,s1,0xc
    80001008:	07aa                	slli	a5,a5,0xa
    8000100a:	0017e793          	ori	a5,a5,1
    8000100e:	00f93023          	sd	a5,0(s2)
    80001012:	b775                	j	80000fbe <walk+0x40>
        return 0;
    80001014:	4501                	li	a0,0
    80001016:	bf6d                	j	80000fd0 <walk+0x52>

0000000080001018 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80001018:	57fd                	li	a5,-1
    8000101a:	83e9                	srli	a5,a5,0x1a
    8000101c:	00b7f463          	bgeu	a5,a1,80001024 <walkaddr+0xc>
    return 0;
    80001020:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001022:	8082                	ret
{
    80001024:	1141                	addi	sp,sp,-16
    80001026:	e406                	sd	ra,8(sp)
    80001028:	e022                	sd	s0,0(sp)
    8000102a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000102c:	4601                	li	a2,0
    8000102e:	f51ff0ef          	jal	80000f7e <walk>
  if (pte == 0)
    80001032:	c901                	beqz	a0,80001042 <walkaddr+0x2a>
  if ((*pte & PTE_V) == 0)
    80001034:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    80001036:	0117f693          	andi	a3,a5,17
    8000103a:	4745                	li	a4,17
    return 0;
    8000103c:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    8000103e:	00e68663          	beq	a3,a4,8000104a <walkaddr+0x32>
}
    80001042:	60a2                	ld	ra,8(sp)
    80001044:	6402                	ld	s0,0(sp)
    80001046:	0141                	addi	sp,sp,16
    80001048:	8082                	ret
  pa = PTE2PA(*pte);
    8000104a:	83a9                	srli	a5,a5,0xa
    8000104c:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001050:	bfcd                	j	80001042 <walkaddr+0x2a>

0000000080001052 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001052:	715d                	addi	sp,sp,-80
    80001054:	e486                	sd	ra,72(sp)
    80001056:	e0a2                	sd	s0,64(sp)
    80001058:	fc26                	sd	s1,56(sp)
    8000105a:	f84a                	sd	s2,48(sp)
    8000105c:	f44e                	sd	s3,40(sp)
    8000105e:	f052                	sd	s4,32(sp)
    80001060:	ec56                	sd	s5,24(sp)
    80001062:	e85a                	sd	s6,16(sp)
    80001064:	e45e                	sd	s7,8(sp)
    80001066:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80001068:	03459793          	slli	a5,a1,0x34
    8000106c:	eba1                	bnez	a5,800010bc <mappages+0x6a>
    8000106e:	8a2a                	mv	s4,a0
    80001070:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80001072:	03461793          	slli	a5,a2,0x34
    80001076:	eba9                	bnez	a5,800010c8 <mappages+0x76>
    panic("mappages: size not aligned");

  if (size == 0)
    80001078:	ce31                	beqz	a2,800010d4 <mappages+0x82>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    8000107a:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    8000107e:	80060613          	addi	a2,a2,-2048
    80001082:	00b60933          	add	s2,a2,a1
  a = va;
    80001086:	84ae                	mv	s1,a1
  for (;;) {
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001088:	4b05                	li	s6,1
    8000108a:	40b689b3          	sub	s3,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    8000108e:	6b85                	lui	s7,0x1
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001090:	865a                	mv	a2,s6
    80001092:	85a6                	mv	a1,s1
    80001094:	8552                	mv	a0,s4
    80001096:	ee9ff0ef          	jal	80000f7e <walk>
    8000109a:	c929                	beqz	a0,800010ec <mappages+0x9a>
    if (*pte & PTE_V)
    8000109c:	611c                	ld	a5,0(a0)
    8000109e:	8b85                	andi	a5,a5,1
    800010a0:	e3a1                	bnez	a5,800010e0 <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010a2:	013487b3          	add	a5,s1,s3
    800010a6:	83b1                	srli	a5,a5,0xc
    800010a8:	07aa                	slli	a5,a5,0xa
    800010aa:	0157e7b3          	or	a5,a5,s5
    800010ae:	0017e793          	ori	a5,a5,1
    800010b2:	e11c                	sd	a5,0(a0)
    if (a == last)
    800010b4:	05248863          	beq	s1,s2,80001104 <mappages+0xb2>
    a += PGSIZE;
    800010b8:	94de                	add	s1,s1,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010ba:	bfd9                	j	80001090 <mappages+0x3e>
    panic("mappages: va not aligned");
    800010bc:	00006517          	auipc	a0,0x6
    800010c0:	ffc50513          	addi	a0,a0,-4 # 800070b8 <etext+0xb8>
    800010c4:	f70ff0ef          	jal	80000834 <panic>
    panic("mappages: size not aligned");
    800010c8:	00006517          	auipc	a0,0x6
    800010cc:	01050513          	addi	a0,a0,16 # 800070d8 <etext+0xd8>
    800010d0:	f64ff0ef          	jal	80000834 <panic>
    panic("mappages: size");
    800010d4:	00006517          	auipc	a0,0x6
    800010d8:	02450513          	addi	a0,a0,36 # 800070f8 <etext+0xf8>
    800010dc:	f58ff0ef          	jal	80000834 <panic>
      panic("mappages: remap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	02850513          	addi	a0,a0,40 # 80007108 <etext+0x108>
    800010e8:	f4cff0ef          	jal	80000834 <panic>
      return -1;
    800010ec:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010ee:	60a6                	ld	ra,72(sp)
    800010f0:	6406                	ld	s0,64(sp)
    800010f2:	74e2                	ld	s1,56(sp)
    800010f4:	7942                	ld	s2,48(sp)
    800010f6:	79a2                	ld	s3,40(sp)
    800010f8:	7a02                	ld	s4,32(sp)
    800010fa:	6ae2                	ld	s5,24(sp)
    800010fc:	6b42                	ld	s6,16(sp)
    800010fe:	6ba2                	ld	s7,8(sp)
    80001100:	6161                	addi	sp,sp,80
    80001102:	8082                	ret
  return 0;
    80001104:	4501                	li	a0,0
    80001106:	b7e5                	j	800010ee <mappages+0x9c>

0000000080001108 <kvmmap>:
{
    80001108:	1141                	addi	sp,sp,-16
    8000110a:	e406                	sd	ra,8(sp)
    8000110c:	e022                	sd	s0,0(sp)
    8000110e:	0800                	addi	s0,sp,16
    80001110:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001112:	86b2                	mv	a3,a2
    80001114:	863e                	mv	a2,a5
    80001116:	f3dff0ef          	jal	80001052 <mappages>
    8000111a:	e509                	bnez	a0,80001124 <kvmmap+0x1c>
}
    8000111c:	60a2                	ld	ra,8(sp)
    8000111e:	6402                	ld	s0,0(sp)
    80001120:	0141                	addi	sp,sp,16
    80001122:	8082                	ret
    panic("kvmmap");
    80001124:	00006517          	auipc	a0,0x6
    80001128:	ff450513          	addi	a0,a0,-12 # 80007118 <etext+0x118>
    8000112c:	f08ff0ef          	jal	80000834 <panic>

0000000080001130 <kvmmake>:
{
    80001130:	1101                	addi	sp,sp,-32
    80001132:	ec06                	sd	ra,24(sp)
    80001134:	e822                	sd	s0,16(sp)
    80001136:	e426                	sd	s1,8(sp)
    80001138:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    8000113a:	a15ff0ef          	jal	80000b4e <kalloc>
    8000113e:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001140:	6605                	lui	a2,0x1
    80001142:	4581                	li	a1,0
    80001144:	ba5ff0ef          	jal	80000ce8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001148:	4719                	li	a4,6
    8000114a:	6685                	lui	a3,0x1
    8000114c:	10000637          	lui	a2,0x10000
    80001150:	85b2                	mv	a1,a2
    80001152:	8526                	mv	a0,s1
    80001154:	fb5ff0ef          	jal	80001108 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001158:	4719                	li	a4,6
    8000115a:	6685                	lui	a3,0x1
    8000115c:	10001637          	lui	a2,0x10001
    80001160:	85b2                	mv	a1,a2
    80001162:	8526                	mv	a0,s1
    80001164:	fa5ff0ef          	jal	80001108 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001168:	4719                	li	a4,6
    8000116a:	040006b7          	lui	a3,0x4000
    8000116e:	0c000637          	lui	a2,0xc000
    80001172:	85b2                	mv	a1,a2
    80001174:	8526                	mv	a0,s1
    80001176:	f93ff0ef          	jal	80001108 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    8000117a:	4729                	li	a4,10
    8000117c:	80006697          	auipc	a3,0x80006
    80001180:	e8468693          	addi	a3,a3,-380 # 7000 <_entry-0x7fff9000>
    80001184:	4605                	li	a2,1
    80001186:	067e                	slli	a2,a2,0x1f
    80001188:	85b2                	mv	a1,a2
    8000118a:	8526                	mv	a0,s1
    8000118c:	f7dff0ef          	jal	80001108 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    80001190:	4719                	li	a4,6
    80001192:	00006697          	auipc	a3,0x6
    80001196:	e6e68693          	addi	a3,a3,-402 # 80007000 <etext>
    8000119a:	47c5                	li	a5,17
    8000119c:	07ee                	slli	a5,a5,0x1b
    8000119e:	40d786b3          	sub	a3,a5,a3
    800011a2:	00006617          	auipc	a2,0x6
    800011a6:	e5e60613          	addi	a2,a2,-418 # 80007000 <etext>
    800011aa:	85b2                	mv	a1,a2
    800011ac:	8526                	mv	a0,s1
    800011ae:	f5bff0ef          	jal	80001108 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011b2:	4729                	li	a4,10
    800011b4:	6685                	lui	a3,0x1
    800011b6:	00005617          	auipc	a2,0x5
    800011ba:	e4a60613          	addi	a2,a2,-438 # 80006000 <_trampoline>
    800011be:	040005b7          	lui	a1,0x4000
    800011c2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011c4:	05b2                	slli	a1,a1,0xc
    800011c6:	8526                	mv	a0,s1
    800011c8:	f41ff0ef          	jal	80001108 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011cc:	8526                	mv	a0,s1
    800011ce:	68c000ef          	jal	8000185a <proc_mapstacks>
}
    800011d2:	8526                	mv	a0,s1
    800011d4:	60e2                	ld	ra,24(sp)
    800011d6:	6442                	ld	s0,16(sp)
    800011d8:	64a2                	ld	s1,8(sp)
    800011da:	6105                	addi	sp,sp,32
    800011dc:	8082                	ret

00000000800011de <kvminit>:
{
    800011de:	1141                	addi	sp,sp,-16
    800011e0:	e406                	sd	ra,8(sp)
    800011e2:	e022                	sd	s0,0(sp)
    800011e4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011e6:	f4bff0ef          	jal	80001130 <kvmmake>
    800011ea:	00009797          	auipc	a5,0x9
    800011ee:	1ea7bf23          	sd	a0,510(a5) # 8000a3e8 <kernel_pagetable>
}
    800011f2:	60a2                	ld	ra,8(sp)
    800011f4:	6402                	ld	s0,0(sp)
    800011f6:	0141                	addi	sp,sp,16
    800011f8:	8082                	ret

00000000800011fa <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800011fa:	1101                	addi	sp,sp,-32
    800011fc:	ec06                	sd	ra,24(sp)
    800011fe:	e822                	sd	s0,16(sp)
    80001200:	e426                	sd	s1,8(sp)
    80001202:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80001204:	94bff0ef          	jal	80000b4e <kalloc>
    80001208:	84aa                	mv	s1,a0
  if (pagetable == 0)
    8000120a:	c509                	beqz	a0,80001214 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000120c:	6605                	lui	a2,0x1
    8000120e:	4581                	li	a1,0
    80001210:	ad9ff0ef          	jal	80000ce8 <memset>
  return pagetable;
}
    80001214:	8526                	mv	a0,s1
    80001216:	60e2                	ld	ra,24(sp)
    80001218:	6442                	ld	s0,16(sp)
    8000121a:	64a2                	ld	s1,8(sp)
    8000121c:	6105                	addi	sp,sp,32
    8000121e:	8082                	ret

0000000080001220 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001220:	7139                	addi	sp,sp,-64
    80001222:	fc06                	sd	ra,56(sp)
    80001224:	f822                	sd	s0,48(sp)
    80001226:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80001228:	03459793          	slli	a5,a1,0x34
    8000122c:	e38d                	bnez	a5,8000124e <uvmunmap+0x2e>
    8000122e:	f04a                	sd	s2,32(sp)
    80001230:	ec4e                	sd	s3,24(sp)
    80001232:	e852                	sd	s4,16(sp)
    80001234:	e456                	sd	s5,8(sp)
    80001236:	e05a                	sd	s6,0(sp)
    80001238:	8a2a                	mv	s4,a0
    8000123a:	892e                	mv	s2,a1
    8000123c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    8000123e:	0632                	slli	a2,a2,0xc
    80001240:	00b609b3          	add	s3,a2,a1
    80001244:	6b05                	lui	s6,0x1
    80001246:	0535f963          	bgeu	a1,s3,80001298 <uvmunmap+0x78>
    8000124a:	f426                	sd	s1,40(sp)
    8000124c:	a015                	j	80001270 <uvmunmap+0x50>
    8000124e:	f426                	sd	s1,40(sp)
    80001250:	f04a                	sd	s2,32(sp)
    80001252:	ec4e                	sd	s3,24(sp)
    80001254:	e852                	sd	s4,16(sp)
    80001256:	e456                	sd	s5,8(sp)
    80001258:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000125a:	00006517          	auipc	a0,0x6
    8000125e:	ec650513          	addi	a0,a0,-314 # 80007120 <etext+0x120>
    80001262:	dd2ff0ef          	jal	80000834 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    80001266:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    8000126a:	995a                	add	s2,s2,s6
    8000126c:	03397563          	bgeu	s2,s3,80001296 <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001270:	4601                	li	a2,0
    80001272:	85ca                	mv	a1,s2
    80001274:	8552                	mv	a0,s4
    80001276:	d09ff0ef          	jal	80000f7e <walk>
    8000127a:	84aa                	mv	s1,a0
    8000127c:	d57d                	beqz	a0,8000126a <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    8000127e:	611c                	ld	a5,0(a0)
    80001280:	0017f713          	andi	a4,a5,1
    80001284:	d37d                	beqz	a4,8000126a <uvmunmap+0x4a>
    if (do_free) {
    80001286:	fe0a80e3          	beqz	s5,80001266 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    8000128a:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    8000128c:	00c79513          	slli	a0,a5,0xc
    80001290:	fd6ff0ef          	jal	80000a66 <kfree>
    80001294:	bfc9                	j	80001266 <uvmunmap+0x46>
    80001296:	74a2                	ld	s1,40(sp)
    80001298:	7902                	ld	s2,32(sp)
    8000129a:	69e2                	ld	s3,24(sp)
    8000129c:	6a42                	ld	s4,16(sp)
    8000129e:	6aa2                	ld	s5,8(sp)
    800012a0:	6b02                	ld	s6,0(sp)
  }
}
    800012a2:	70e2                	ld	ra,56(sp)
    800012a4:	7442                	ld	s0,48(sp)
    800012a6:	6121                	addi	sp,sp,64
    800012a8:	8082                	ret

00000000800012aa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012aa:	1101                	addi	sp,sp,-32
    800012ac:	ec06                	sd	ra,24(sp)
    800012ae:	e822                	sd	s0,16(sp)
    800012b0:	e426                	sd	s1,8(sp)
    800012b2:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    800012b4:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    800012b6:	00b67d63          	bgeu	a2,a1,800012d0 <uvmdealloc+0x26>
    800012ba:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    800012bc:	6785                	lui	a5,0x1
    800012be:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012c0:	00f60733          	add	a4,a2,a5
    800012c4:	76fd                	lui	a3,0xfffff
    800012c6:	8f75                	and	a4,a4,a3
    800012c8:	97ae                	add	a5,a5,a1
    800012ca:	8ff5                	and	a5,a5,a3
    800012cc:	00f76863          	bltu	a4,a5,800012dc <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012d0:	8526                	mv	a0,s1
    800012d2:	60e2                	ld	ra,24(sp)
    800012d4:	6442                	ld	s0,16(sp)
    800012d6:	64a2                	ld	s1,8(sp)
    800012d8:	6105                	addi	sp,sp,32
    800012da:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012dc:	8f99                	sub	a5,a5,a4
    800012de:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012e0:	4685                	li	a3,1
    800012e2:	0007861b          	sext.w	a2,a5
    800012e6:	85ba                	mv	a1,a4
    800012e8:	f39ff0ef          	jal	80001220 <uvmunmap>
    800012ec:	b7d5                	j	800012d0 <uvmdealloc+0x26>

00000000800012ee <uvmalloc>:
  if (newsz < oldsz)
    800012ee:	0ab66163          	bltu	a2,a1,80001390 <uvmalloc+0xa2>
{
    800012f2:	715d                	addi	sp,sp,-80
    800012f4:	e486                	sd	ra,72(sp)
    800012f6:	e0a2                	sd	s0,64(sp)
    800012f8:	f84a                	sd	s2,48(sp)
    800012fa:	f052                	sd	s4,32(sp)
    800012fc:	ec56                	sd	s5,24(sp)
    800012fe:	e45e                	sd	s7,8(sp)
    80001300:	0880                	addi	s0,sp,80
    80001302:	8aaa                	mv	s5,a0
    80001304:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001306:	6785                	lui	a5,0x1
    80001308:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000130a:	95be                	add	a1,a1,a5
    8000130c:	77fd                	lui	a5,0xfffff
    8000130e:	00f5f933          	and	s2,a1,a5
    80001312:	8bca                	mv	s7,s2
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001314:	08c97063          	bgeu	s2,a2,80001394 <uvmalloc+0xa6>
    80001318:	fc26                	sd	s1,56(sp)
    8000131a:	f44e                	sd	s3,40(sp)
    8000131c:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    8000131e:	6985                	lui	s3,0x1
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001320:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001324:	82bff0ef          	jal	80000b4e <kalloc>
    80001328:	84aa                	mv	s1,a0
    if (mem == 0) {
    8000132a:	c50d                	beqz	a0,80001354 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    8000132c:	864e                	mv	a2,s3
    8000132e:	4581                	li	a1,0
    80001330:	9b9ff0ef          	jal	80000ce8 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001334:	875a                	mv	a4,s6
    80001336:	86a6                	mv	a3,s1
    80001338:	864e                	mv	a2,s3
    8000133a:	85ca                	mv	a1,s2
    8000133c:	8556                	mv	a0,s5
    8000133e:	d15ff0ef          	jal	80001052 <mappages>
    80001342:	e915                	bnez	a0,80001376 <uvmalloc+0x88>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001344:	994e                	add	s2,s2,s3
    80001346:	fd496fe3          	bltu	s2,s4,80001324 <uvmalloc+0x36>
  return newsz;
    8000134a:	8552                	mv	a0,s4
    8000134c:	74e2                	ld	s1,56(sp)
    8000134e:	79a2                	ld	s3,40(sp)
    80001350:	6b42                	ld	s6,16(sp)
    80001352:	a811                	j	80001366 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001354:	865e                	mv	a2,s7
    80001356:	85ca                	mv	a1,s2
    80001358:	8556                	mv	a0,s5
    8000135a:	f51ff0ef          	jal	800012aa <uvmdealloc>
      return 0;
    8000135e:	4501                	li	a0,0
    80001360:	74e2                	ld	s1,56(sp)
    80001362:	79a2                	ld	s3,40(sp)
    80001364:	6b42                	ld	s6,16(sp)
}
    80001366:	60a6                	ld	ra,72(sp)
    80001368:	6406                	ld	s0,64(sp)
    8000136a:	7942                	ld	s2,48(sp)
    8000136c:	7a02                	ld	s4,32(sp)
    8000136e:	6ae2                	ld	s5,24(sp)
    80001370:	6ba2                	ld	s7,8(sp)
    80001372:	6161                	addi	sp,sp,80
    80001374:	8082                	ret
      kfree(mem);
    80001376:	8526                	mv	a0,s1
    80001378:	eeeff0ef          	jal	80000a66 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000137c:	865e                	mv	a2,s7
    8000137e:	85ca                	mv	a1,s2
    80001380:	8556                	mv	a0,s5
    80001382:	f29ff0ef          	jal	800012aa <uvmdealloc>
      return 0;
    80001386:	4501                	li	a0,0
    80001388:	74e2                	ld	s1,56(sp)
    8000138a:	79a2                	ld	s3,40(sp)
    8000138c:	6b42                	ld	s6,16(sp)
    8000138e:	bfe1                	j	80001366 <uvmalloc+0x78>
    return oldsz;
    80001390:	852e                	mv	a0,a1
}
    80001392:	8082                	ret
  return newsz;
    80001394:	8532                	mv	a0,a2
    80001396:	bfc1                	j	80001366 <uvmalloc+0x78>

0000000080001398 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001398:	7179                	addi	sp,sp,-48
    8000139a:	f406                	sd	ra,40(sp)
    8000139c:	f022                	sd	s0,32(sp)
    8000139e:	ec26                	sd	s1,24(sp)
    800013a0:	e84a                	sd	s2,16(sp)
    800013a2:	e44e                	sd	s3,8(sp)
    800013a4:	1800                	addi	s0,sp,48
    800013a6:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    800013a8:	84aa                	mv	s1,a0
    800013aa:	6905                	lui	s2,0x1
    800013ac:	992a                	add	s2,s2,a0
    800013ae:	a811                	j	800013c2 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if (pte & PTE_V) {
      panic("freewalk: leaf");
    800013b0:	00006517          	auipc	a0,0x6
    800013b4:	d8850513          	addi	a0,a0,-632 # 80007138 <etext+0x138>
    800013b8:	c7cff0ef          	jal	80000834 <panic>
  for (int i = 0; i < 512; i++) {
    800013bc:	04a1                	addi	s1,s1,8
    800013be:	03248163          	beq	s1,s2,800013e0 <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013c2:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013c4:	0017f713          	andi	a4,a5,1
    800013c8:	db75                	beqz	a4,800013bc <freewalk+0x24>
    800013ca:	00e7f713          	andi	a4,a5,14
    800013ce:	f36d                	bnez	a4,800013b0 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800013d0:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013d2:	00c79513          	slli	a0,a5,0xc
    800013d6:	fc3ff0ef          	jal	80001398 <freewalk>
      pagetable[i] = 0;
    800013da:	0004b023          	sd	zero,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013de:	bff9                	j	800013bc <freewalk+0x24>
    }
  }
  kfree((void *)pagetable);
    800013e0:	854e                	mv	a0,s3
    800013e2:	e84ff0ef          	jal	80000a66 <kfree>
}
    800013e6:	70a2                	ld	ra,40(sp)
    800013e8:	7402                	ld	s0,32(sp)
    800013ea:	64e2                	ld	s1,24(sp)
    800013ec:	6942                	ld	s2,16(sp)
    800013ee:	69a2                	ld	s3,8(sp)
    800013f0:	6145                	addi	sp,sp,48
    800013f2:	8082                	ret

00000000800013f4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013f4:	1101                	addi	sp,sp,-32
    800013f6:	ec06                	sd	ra,24(sp)
    800013f8:	e822                	sd	s0,16(sp)
    800013fa:	e426                	sd	s1,8(sp)
    800013fc:	1000                	addi	s0,sp,32
    800013fe:	84aa                	mv	s1,a0
  if (sz > 0)
    80001400:	e989                	bnez	a1,80001412 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80001402:	8526                	mv	a0,s1
    80001404:	f95ff0ef          	jal	80001398 <freewalk>
}
    80001408:	60e2                	ld	ra,24(sp)
    8000140a:	6442                	ld	s0,16(sp)
    8000140c:	64a2                	ld	s1,8(sp)
    8000140e:	6105                	addi	sp,sp,32
    80001410:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001412:	6785                	lui	a5,0x1
    80001414:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001416:	95be                	add	a1,a1,a5
    80001418:	4685                	li	a3,1
    8000141a:	00c5d613          	srli	a2,a1,0xc
    8000141e:	4581                	li	a1,0
    80001420:	e01ff0ef          	jal	80001220 <uvmunmap>
    80001424:	bff9                	j	80001402 <uvmfree+0xe>

0000000080001426 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    80001426:	ca59                	beqz	a2,800014bc <uvmcopy+0x96>
{
    80001428:	715d                	addi	sp,sp,-80
    8000142a:	e486                	sd	ra,72(sp)
    8000142c:	e0a2                	sd	s0,64(sp)
    8000142e:	fc26                	sd	s1,56(sp)
    80001430:	f84a                	sd	s2,48(sp)
    80001432:	f44e                	sd	s3,40(sp)
    80001434:	f052                	sd	s4,32(sp)
    80001436:	ec56                	sd	s5,24(sp)
    80001438:	e85a                	sd	s6,16(sp)
    8000143a:	e45e                	sd	s7,8(sp)
    8000143c:	0880                	addi	s0,sp,80
    8000143e:	8b2a                	mv	s6,a0
    80001440:	8bae                	mv	s7,a1
    80001442:	8ab2                	mv	s5,a2
  for (i = 0; i < sz; i += PGSIZE) {
    80001444:	4481                	li	s1,0
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if ((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    80001446:	6a05                	lui	s4,0x1
    80001448:	a021                	j	80001450 <uvmcopy+0x2a>
  for (i = 0; i < sz; i += PGSIZE) {
    8000144a:	94d2                	add	s1,s1,s4
    8000144c:	0554fc63          	bgeu	s1,s5,800014a4 <uvmcopy+0x7e>
    if ((pte = walk(old, i, 0)) == 0)
    80001450:	4601                	li	a2,0
    80001452:	85a6                	mv	a1,s1
    80001454:	855a                	mv	a0,s6
    80001456:	b29ff0ef          	jal	80000f7e <walk>
    8000145a:	d965                	beqz	a0,8000144a <uvmcopy+0x24>
    if ((*pte & PTE_V) == 0)
    8000145c:	00053983          	ld	s3,0(a0)
    80001460:	0019f793          	andi	a5,s3,1
    80001464:	d3fd                	beqz	a5,8000144a <uvmcopy+0x24>
    if ((mem = kalloc()) == 0)
    80001466:	ee8ff0ef          	jal	80000b4e <kalloc>
    8000146a:	892a                	mv	s2,a0
    8000146c:	c11d                	beqz	a0,80001492 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    8000146e:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char *)pa, PGSIZE);
    80001472:	8652                	mv	a2,s4
    80001474:	05b2                	slli	a1,a1,0xc
    80001476:	8d3ff0ef          	jal	80000d48 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    8000147a:	3ff9f713          	andi	a4,s3,1023
    8000147e:	86ca                	mv	a3,s2
    80001480:	8652                	mv	a2,s4
    80001482:	85a6                	mv	a1,s1
    80001484:	855e                	mv	a0,s7
    80001486:	bcdff0ef          	jal	80001052 <mappages>
    8000148a:	d161                	beqz	a0,8000144a <uvmcopy+0x24>
      kfree(mem);
    8000148c:	854a                	mv	a0,s2
    8000148e:	dd8ff0ef          	jal	80000a66 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001492:	4685                	li	a3,1
    80001494:	00c4d613          	srli	a2,s1,0xc
    80001498:	4581                	li	a1,0
    8000149a:	855e                	mv	a0,s7
    8000149c:	d85ff0ef          	jal	80001220 <uvmunmap>
  return -1;
    800014a0:	557d                	li	a0,-1
    800014a2:	a011                	j	800014a6 <uvmcopy+0x80>
  return 0;
    800014a4:	4501                	li	a0,0
}
    800014a6:	60a6                	ld	ra,72(sp)
    800014a8:	6406                	ld	s0,64(sp)
    800014aa:	74e2                	ld	s1,56(sp)
    800014ac:	7942                	ld	s2,48(sp)
    800014ae:	79a2                	ld	s3,40(sp)
    800014b0:	7a02                	ld	s4,32(sp)
    800014b2:	6ae2                	ld	s5,24(sp)
    800014b4:	6b42                	ld	s6,16(sp)
    800014b6:	6ba2                	ld	s7,8(sp)
    800014b8:	6161                	addi	sp,sp,80
    800014ba:	8082                	ret
  return 0;
    800014bc:	4501                	li	a0,0
}
    800014be:	8082                	ret

00000000800014c0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014c0:	1141                	addi	sp,sp,-16
    800014c2:	e406                	sd	ra,8(sp)
    800014c4:	e022                	sd	s0,0(sp)
    800014c6:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    800014c8:	4601                	li	a2,0
    800014ca:	ab5ff0ef          	jal	80000f7e <walk>
  if (pte == 0)
    800014ce:	c901                	beqz	a0,800014de <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014d0:	611c                	ld	a5,0(a0)
    800014d2:	9bbd                	andi	a5,a5,-17
    800014d4:	e11c                	sd	a5,0(a0)
}
    800014d6:	60a2                	ld	ra,8(sp)
    800014d8:	6402                	ld	s0,0(sp)
    800014da:	0141                	addi	sp,sp,16
    800014dc:	8082                	ret
    panic("uvmclear");
    800014de:	00006517          	auipc	a0,0x6
    800014e2:	c6a50513          	addi	a0,a0,-918 # 80007148 <etext+0x148>
    800014e6:	b4eff0ef          	jal	80000834 <panic>

00000000800014ea <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800014ea:	1141                	addi	sp,sp,-16
    800014ec:	e406                	sd	ra,8(sp)
    800014ee:	e022                	sd	s0,0(sp)
    800014f0:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800014f2:	4601                	li	a2,0
    800014f4:	a8bff0ef          	jal	80000f7e <walk>
  if (pte == 0) {
    800014f8:	c119                	beqz	a0,800014fe <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V) {
    800014fa:	6108                	ld	a0,0(a0)
    800014fc:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800014fe:	60a2                	ld	ra,8(sp)
    80001500:	6402                	ld	s0,0(sp)
    80001502:	0141                	addi	sp,sp,16
    80001504:	8082                	ret

0000000080001506 <vmfault>:
{
    80001506:	7179                	addi	sp,sp,-48
    80001508:	f406                	sd	ra,40(sp)
    8000150a:	f022                	sd	s0,32(sp)
    8000150c:	e052                	sd	s4,0(sp)
    8000150e:	1800                	addi	s0,sp,48
    return 0;
    80001510:	4a01                	li	s4,0
  if (va >= psz)
    80001512:	00b66863          	bltu	a2,a1,80001522 <vmfault+0x1c>
}
    80001516:	8552                	mv	a0,s4
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	6a02                	ld	s4,0(sp)
    8000151e:	6145                	addi	sp,sp,48
    80001520:	8082                	ret
    80001522:	ec26                	sd	s1,24(sp)
    80001524:	e44e                	sd	s3,8(sp)
    80001526:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    80001528:	77fd                	lui	a5,0xfffff
    8000152a:	00f679b3          	and	s3,a2,a5
  if (ismapped(pagetable, va)) {
    8000152e:	85ce                	mv	a1,s3
    80001530:	fbbff0ef          	jal	800014ea <ismapped>
    return 0;
    80001534:	4a01                	li	s4,0
  if (ismapped(pagetable, va)) {
    80001536:	c501                	beqz	a0,8000153e <vmfault+0x38>
    80001538:	64e2                	ld	s1,24(sp)
    8000153a:	69a2                	ld	s3,8(sp)
    8000153c:	bfe9                	j	80001516 <vmfault+0x10>
    8000153e:	e84a                	sd	s2,16(sp)
  mem = (uint64)kalloc();
    80001540:	e0eff0ef          	jal	80000b4e <kalloc>
    80001544:	892a                	mv	s2,a0
  if (mem == 0)
    80001546:	c915                	beqz	a0,8000157a <vmfault+0x74>
  mem = (uint64)kalloc();
    80001548:	8a2a                	mv	s4,a0
  memset((void *)mem, 0, PGSIZE);
    8000154a:	6605                	lui	a2,0x1
    8000154c:	4581                	li	a1,0
    8000154e:	f9aff0ef          	jal	80000ce8 <memset>
  if (mappages(pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    80001552:	4759                	li	a4,22
    80001554:	86ca                	mv	a3,s2
    80001556:	6605                	lui	a2,0x1
    80001558:	85ce                	mv	a1,s3
    8000155a:	8526                	mv	a0,s1
    8000155c:	af7ff0ef          	jal	80001052 <mappages>
    80001560:	e509                	bnez	a0,8000156a <vmfault+0x64>
    80001562:	64e2                	ld	s1,24(sp)
    80001564:	6942                	ld	s2,16(sp)
    80001566:	69a2                	ld	s3,8(sp)
    80001568:	b77d                	j	80001516 <vmfault+0x10>
    kfree((void *)mem);
    8000156a:	854a                	mv	a0,s2
    8000156c:	cfaff0ef          	jal	80000a66 <kfree>
    return 0;
    80001570:	4a01                	li	s4,0
    80001572:	64e2                	ld	s1,24(sp)
    80001574:	6942                	ld	s2,16(sp)
    80001576:	69a2                	ld	s3,8(sp)
    80001578:	bf79                	j	80001516 <vmfault+0x10>
    8000157a:	64e2                	ld	s1,24(sp)
    8000157c:	6942                	ld	s2,16(sp)
    8000157e:	69a2                	ld	s3,8(sp)
    80001580:	bf59                	j	80001516 <vmfault+0x10>

0000000080001582 <copyout>:
  while (len > 0) {
    80001582:	cf49                	beqz	a4,8000161c <copyout+0x9a>
{
    80001584:	7159                	addi	sp,sp,-112
    80001586:	f486                	sd	ra,104(sp)
    80001588:	f0a2                	sd	s0,96(sp)
    8000158a:	eca6                	sd	s1,88(sp)
    8000158c:	e8ca                	sd	s2,80(sp)
    8000158e:	e4ce                	sd	s3,72(sp)
    80001590:	e0d2                	sd	s4,64(sp)
    80001592:	fc56                	sd	s5,56(sp)
    80001594:	f85a                	sd	s6,48(sp)
    80001596:	f45e                	sd	s7,40(sp)
    80001598:	f062                	sd	s8,32(sp)
    8000159a:	ec66                	sd	s9,24(sp)
    8000159c:	e86a                	sd	s10,16(sp)
    8000159e:	e46e                	sd	s11,8(sp)
    800015a0:	1880                	addi	s0,sp,112
    800015a2:	8baa                	mv	s7,a0
    800015a4:	8dae                	mv	s11,a1
    800015a6:	8a32                	mv	s4,a2
    800015a8:	8b36                	mv	s6,a3
    800015aa:	8aba                	mv	s5,a4
    va0 = PGROUNDDOWN(dstva);
    800015ac:	7d7d                	lui	s10,0xfffff
    if (va0 >= MAXVA)
    800015ae:	5cfd                	li	s9,-1
    800015b0:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    800015b4:	6c05                	lui	s8,0x1
    800015b6:	a005                	j	800015d6 <copyout+0x54>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015b8:	409a0533          	sub	a0,s4,s1
    800015bc:	0009061b          	sext.w	a2,s2
    800015c0:	85da                	mv	a1,s6
    800015c2:	954e                	add	a0,a0,s3
    800015c4:	f84ff0ef          	jal	80000d48 <memmove>
    len -= n;
    800015c8:	412a8ab3          	sub	s5,s5,s2
    src += n;
    800015cc:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    800015ce:	01848a33          	add	s4,s1,s8
  while (len > 0) {
    800015d2:	040a8363          	beqz	s5,80001618 <copyout+0x96>
    va0 = PGROUNDDOWN(dstva);
    800015d6:	01aa74b3          	and	s1,s4,s10
    if (va0 >= MAXVA)
    800015da:	049ce363          	bltu	s9,s1,80001620 <copyout+0x9e>
    pa0 = walkaddr(pagetable, va0);
    800015de:	85a6                	mv	a1,s1
    800015e0:	855e                	mv	a0,s7
    800015e2:	a37ff0ef          	jal	80001018 <walkaddr>
    800015e6:	89aa                	mv	s3,a0
    if (pa0 == 0) {
    800015e8:	e909                	bnez	a0,800015fa <copyout+0x78>
      if ((pa0 = vmfault(pagetable, psz, va0, 0)) == 0) {
    800015ea:	4681                	li	a3,0
    800015ec:	8626                	mv	a2,s1
    800015ee:	85ee                	mv	a1,s11
    800015f0:	855e                	mv	a0,s7
    800015f2:	f15ff0ef          	jal	80001506 <vmfault>
    800015f6:	89aa                	mv	s3,a0
    800015f8:	c521                	beqz	a0,80001640 <copyout+0xbe>
    pte = walk(pagetable, va0, 0);
    800015fa:	4601                	li	a2,0
    800015fc:	85a6                	mv	a1,s1
    800015fe:	855e                	mv	a0,s7
    80001600:	97fff0ef          	jal	80000f7e <walk>
    if ((*pte & PTE_W) == 0)
    80001604:	611c                	ld	a5,0(a0)
    80001606:	8b91                	andi	a5,a5,4
    80001608:	cf95                	beqz	a5,80001644 <copyout+0xc2>
    n = PGSIZE - (dstva - va0);
    8000160a:	41448933          	sub	s2,s1,s4
    8000160e:	9962                	add	s2,s2,s8
    if (n > len)
    80001610:	fb2af4e3          	bgeu	s5,s2,800015b8 <copyout+0x36>
    80001614:	8956                	mv	s2,s5
    80001616:	b74d                	j	800015b8 <copyout+0x36>
  return 0;
    80001618:	4501                	li	a0,0
    8000161a:	a021                	j	80001622 <copyout+0xa0>
    8000161c:	4501                	li	a0,0
}
    8000161e:	8082                	ret
      return -1;
    80001620:	557d                	li	a0,-1
}
    80001622:	70a6                	ld	ra,104(sp)
    80001624:	7406                	ld	s0,96(sp)
    80001626:	64e6                	ld	s1,88(sp)
    80001628:	6946                	ld	s2,80(sp)
    8000162a:	69a6                	ld	s3,72(sp)
    8000162c:	6a06                	ld	s4,64(sp)
    8000162e:	7ae2                	ld	s5,56(sp)
    80001630:	7b42                	ld	s6,48(sp)
    80001632:	7ba2                	ld	s7,40(sp)
    80001634:	7c02                	ld	s8,32(sp)
    80001636:	6ce2                	ld	s9,24(sp)
    80001638:	6d42                	ld	s10,16(sp)
    8000163a:	6da2                	ld	s11,8(sp)
    8000163c:	6165                	addi	sp,sp,112
    8000163e:	8082                	ret
        return -1;
    80001640:	557d                	li	a0,-1
    80001642:	b7c5                	j	80001622 <copyout+0xa0>
      return -1;
    80001644:	557d                	li	a0,-1
    80001646:	bff1                	j	80001622 <copyout+0xa0>

0000000080001648 <copyin>:
  while (len > 0) {
    80001648:	cf41                	beqz	a4,800016e0 <copyin+0x98>
{
    8000164a:	711d                	addi	sp,sp,-96
    8000164c:	ec86                	sd	ra,88(sp)
    8000164e:	e8a2                	sd	s0,80(sp)
    80001650:	e4a6                	sd	s1,72(sp)
    80001652:	e0ca                	sd	s2,64(sp)
    80001654:	fc4e                	sd	s3,56(sp)
    80001656:	f852                	sd	s4,48(sp)
    80001658:	f456                	sd	s5,40(sp)
    8000165a:	f05a                	sd	s6,32(sp)
    8000165c:	ec5e                	sd	s7,24(sp)
    8000165e:	e862                	sd	s8,16(sp)
    80001660:	e466                	sd	s9,8(sp)
    80001662:	e06a                	sd	s10,0(sp)
    80001664:	1080                	addi	s0,sp,96
    80001666:	8baa                	mv	s7,a0
    80001668:	8cae                	mv	s9,a1
    8000166a:	8ab2                	mv	s5,a2
    8000166c:	8936                	mv	s2,a3
    8000166e:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    80001670:	7c7d                	lui	s8,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001672:	4d05                	li	s10,1
    n = PGSIZE - (srcva - va0);
    80001674:	6b05                	lui	s6,0x1
    80001676:	a035                	j	800016a2 <copyin+0x5a>
    80001678:	412984b3          	sub	s1,s3,s2
    8000167c:	94da                	add	s1,s1,s6
    if (n > len)
    8000167e:	009a7363          	bgeu	s4,s1,80001684 <copyin+0x3c>
    80001682:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001684:	413905b3          	sub	a1,s2,s3
    80001688:	0004861b          	sext.w	a2,s1
    8000168c:	95aa                	add	a1,a1,a0
    8000168e:	8556                	mv	a0,s5
    80001690:	eb8ff0ef          	jal	80000d48 <memmove>
    len -= n;
    80001694:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001698:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000169a:	01698933          	add	s2,s3,s6
  while (len > 0) {
    8000169e:	020a0263          	beqz	s4,800016c2 <copyin+0x7a>
    va0 = PGROUNDDOWN(srcva);
    800016a2:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    800016a6:	85ce                	mv	a1,s3
    800016a8:	855e                	mv	a0,s7
    800016aa:	96fff0ef          	jal	80001018 <walkaddr>
    if (pa0 == 0) {
    800016ae:	f569                	bnez	a0,80001678 <copyin+0x30>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800016b0:	86ea                	mv	a3,s10
    800016b2:	864e                	mv	a2,s3
    800016b4:	85e6                	mv	a1,s9
    800016b6:	855e                	mv	a0,s7
    800016b8:	e4fff0ef          	jal	80001506 <vmfault>
    800016bc:	fd55                	bnez	a0,80001678 <copyin+0x30>
        return -1;
    800016be:	557d                	li	a0,-1
    800016c0:	a011                	j	800016c4 <copyin+0x7c>
  return 0;
    800016c2:	4501                	li	a0,0
}
    800016c4:	60e6                	ld	ra,88(sp)
    800016c6:	6446                	ld	s0,80(sp)
    800016c8:	64a6                	ld	s1,72(sp)
    800016ca:	6906                	ld	s2,64(sp)
    800016cc:	79e2                	ld	s3,56(sp)
    800016ce:	7a42                	ld	s4,48(sp)
    800016d0:	7aa2                	ld	s5,40(sp)
    800016d2:	7b02                	ld	s6,32(sp)
    800016d4:	6be2                	ld	s7,24(sp)
    800016d6:	6c42                	ld	s8,16(sp)
    800016d8:	6ca2                	ld	s9,8(sp)
    800016da:	6d02                	ld	s10,0(sp)
    800016dc:	6125                	addi	sp,sp,96
    800016de:	8082                	ret
  return 0;
    800016e0:	4501                	li	a0,0
}
    800016e2:	8082                	ret

00000000800016e4 <copyinstr>:
  while (got_null == 0 && max > 0) {
    800016e4:	c769                	beqz	a4,800017ae <copyinstr+0xca>
{
    800016e6:	711d                	addi	sp,sp,-96
    800016e8:	ec86                	sd	ra,88(sp)
    800016ea:	e8a2                	sd	s0,80(sp)
    800016ec:	e4a6                	sd	s1,72(sp)
    800016ee:	e0ca                	sd	s2,64(sp)
    800016f0:	fc4e                	sd	s3,56(sp)
    800016f2:	f852                	sd	s4,48(sp)
    800016f4:	f456                	sd	s5,40(sp)
    800016f6:	f05a                	sd	s6,32(sp)
    800016f8:	ec5e                	sd	s7,24(sp)
    800016fa:	e862                	sd	s8,16(sp)
    800016fc:	e466                	sd	s9,8(sp)
    800016fe:	1080                	addi	s0,sp,96
    80001700:	8b2a                	mv	s6,a0
    80001702:	8c2e                	mv	s8,a1
    80001704:	89b2                	mv	s3,a2
    80001706:	84b6                	mv	s1,a3
    80001708:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    8000170a:	7bfd                	lui	s7,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    8000170c:	4c85                	li	s9,1
    n = PGSIZE - (srcva - va0);
    8000170e:	6a85                	lui	s5,0x1
    80001710:	a881                	j	80001760 <copyinstr+0x7c>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001712:	86e6                	mv	a3,s9
    80001714:	864a                	mv	a2,s2
    80001716:	85e2                	mv	a1,s8
    80001718:	855a                	mv	a0,s6
    8000171a:	dedff0ef          	jal	80001506 <vmfault>
    8000171e:	e921                	bnez	a0,8000176e <copyinstr+0x8a>
        return -1;
    80001720:	557d                	li	a0,-1
    80001722:	a801                	j	80001732 <copyinstr+0x4e>
        *dst = '\0';
    80001724:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb8f8>
        got_null = 1;
    80001728:	4785                	li	a5,1
  if (got_null) {
    8000172a:	0017c793          	xori	a5,a5,1
    8000172e:	40f0053b          	negw	a0,a5
}
    80001732:	60e6                	ld	ra,88(sp)
    80001734:	6446                	ld	s0,80(sp)
    80001736:	64a6                	ld	s1,72(sp)
    80001738:	6906                	ld	s2,64(sp)
    8000173a:	79e2                	ld	s3,56(sp)
    8000173c:	7a42                	ld	s4,48(sp)
    8000173e:	7aa2                	ld	s5,40(sp)
    80001740:	7b02                	ld	s6,32(sp)
    80001742:	6be2                	ld	s7,24(sp)
    80001744:	6c42                	ld	s8,16(sp)
    80001746:	6ca2                	ld	s9,8(sp)
    80001748:	6125                	addi	sp,sp,96
    8000174a:	8082                	ret
    8000174c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80001750:	974e                	add	a4,a4,s3
      --max;
    80001752:	40b70a33          	sub	s4,a4,a1
    srcva = va0 + PGSIZE;
    80001756:	015904b3          	add	s1,s2,s5
  while (got_null == 0 && max > 0) {
    8000175a:	04e58463          	beq	a1,a4,800017a2 <copyinstr+0xbe>
{
    8000175e:	89be                	mv	s3,a5
    va0 = PGROUNDDOWN(srcva);
    80001760:	0174f933          	and	s2,s1,s7
    pa0 = walkaddr(pagetable, va0);
    80001764:	85ca                	mv	a1,s2
    80001766:	855a                	mv	a0,s6
    80001768:	8b1ff0ef          	jal	80001018 <walkaddr>
    if (pa0 == 0) {
    8000176c:	d15d                	beqz	a0,80001712 <copyinstr+0x2e>
    n = PGSIZE - (srcva - va0);
    8000176e:	40990633          	sub	a2,s2,s1
    80001772:	9656                	add	a2,a2,s5
    if (n > max)
    80001774:	00ca7363          	bgeu	s4,a2,8000177a <copyinstr+0x96>
    80001778:	8652                	mv	a2,s4
    while (n > 0) {
    8000177a:	c615                	beqz	a2,800017a6 <copyinstr+0xc2>
    char *p = (char *)(pa0 + (srcva - va0));
    8000177c:	412484b3          	sub	s1,s1,s2
    80001780:	94aa                	add	s1,s1,a0
    80001782:	87ce                	mv	a5,s3
      if (*p == '\0') {
    80001784:	413484b3          	sub	s1,s1,s3
    while (n > 0) {
    80001788:	964e                	add	a2,a2,s3
    8000178a:	85be                	mv	a1,a5
      if (*p == '\0') {
    8000178c:	00f48733          	add	a4,s1,a5
    80001790:	00074683          	lbu	a3,0(a4)
    80001794:	dac1                	beqz	a3,80001724 <copyinstr+0x40>
        *dst = *p;
    80001796:	00d78023          	sb	a3,0(a5)
      dst++;
    8000179a:	0785                	addi	a5,a5,1
    while (n > 0) {
    8000179c:	fec797e3          	bne	a5,a2,8000178a <copyinstr+0xa6>
    800017a0:	b775                	j	8000174c <copyinstr+0x68>
    800017a2:	4781                	li	a5,0
    800017a4:	b759                	j	8000172a <copyinstr+0x46>
    srcva = va0 + PGSIZE;
    800017a6:	6485                	lui	s1,0x1
    800017a8:	94ca                	add	s1,s1,s2
    800017aa:	87ce                	mv	a5,s3
    800017ac:	bf4d                	j	8000175e <copyinstr+0x7a>
  int got_null = 0;
    800017ae:	4781                	li	a5,0
  if (got_null) {
    800017b0:	0017c793          	xori	a5,a5,1
    800017b4:	40f0053b          	negw	a0,a5
}
    800017b8:	8082                	ret

00000000800017ba <walkpgdir>:

// walkpgdir exposes walk() for page table walking
pte_t *
walkpgdir(pagetable_t pagetable, uint64 va, int alloc)
{
    800017ba:	1141                	addi	sp,sp,-16
    800017bc:	e406                	sd	ra,8(sp)
    800017be:	e022                	sd	s0,0(sp)
    800017c0:	0800                	addi	s0,sp,16
  return walk(pagetable, va, alloc);
    800017c2:	fbcff0ef          	jal	80000f7e <walk>
}
    800017c6:	60a2                	ld	ra,8(sp)
    800017c8:	6402                	ld	s0,0(sp)
    800017ca:	0141                	addi	sp,sp,16
    800017cc:	8082                	ret

00000000800017ce <va2pa>:

// va2pa translates virtual address to physical address
// Prints PDE index, PTE index, offset and flag bits (P, W, U)
uint64
va2pa(uint64 va)
{
    800017ce:	7179                	addi	sp,sp,-48
    800017d0:	f406                	sd	ra,40(sp)
    800017d2:	f022                	sd	s0,32(sp)
    800017d4:	ec26                	sd	s1,24(sp)
    800017d6:	e84a                	sd	s2,16(sp)
    800017d8:	1800                	addi	s0,sp,48
    800017da:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800017dc:	20c000ef          	jal	800019e8 <myproc>
  if (va >= MAXVA)
    800017e0:	57fd                	li	a5,-1
    800017e2:	83e9                	srli	a5,a5,0x1a
    return (uint64)-1;
    800017e4:	597d                	li	s2,-1
  if (va >= MAXVA)
    800017e6:	0697e163          	bltu	a5,s1,80001848 <va2pa+0x7a>
  return walk(pagetable, va, alloc);
    800017ea:	4601                	li	a2,0
    800017ec:	85a6                	mv	a1,s1
    800017ee:	6928                	ld	a0,80(a0)
    800017f0:	f8eff0ef          	jal	80000f7e <walk>

  pte_t *pte = walkpgdir(p->pagetable, va, 0);
  if (pte == 0)
    800017f4:	c12d                	beqz	a0,80001856 <va2pa+0x88>
    return (uint64)-1;

  if ((*pte & PTE_V) == 0) // P bit (Present)
    800017f6:	00053883          	ld	a7,0(a0)
    return (uint64)-1;

  if ((*pte & PTE_U) == 0) // U bit (User mode accessible)
    800017fa:	0118f713          	andi	a4,a7,17
    800017fe:	47c5                	li	a5,17
    return (uint64)-1;
    80001800:	597d                	li	s2,-1
  if ((*pte & PTE_U) == 0) // U bit (User mode accessible)
    80001802:	04f71363          	bne	a4,a5,80001848 <va2pa+0x7a>

  uint64 pa = PTE2PA(*pte) | (va & 0xFFF);
    80001806:	03449793          	slli	a5,s1,0x34
    8000180a:	93d1                	srli	a5,a5,0x34
    8000180c:	00a8d913          	srli	s2,a7,0xa
    80001810:	0932                	slli	s2,s2,0xc
    80001812:	00f96933          	or	s2,s2,a5
  uint64 l2_idx = PX(2, va); // Page Directory index (Level 2)
  uint64 l1_idx = PX(1, va); // Middle Directory index (Level 1)
  uint64 l0_idx = PX(0, va); // Page Table index (Level 0)
  uint64 offset = va & 0xFFF;
  int bit_p = (*pte & PTE_V) ? 1 : 0;
  int bit_w = (*pte & PTE_W) ? 1 : 0;
    80001816:	0028d893          	srli	a7,a7,0x2
  uint64 l0_idx = PX(0, va); // Page Table index (Level 0)
    8000181a:	00c4d713          	srli	a4,s1,0xc
  uint64 l1_idx = PX(1, va); // Middle Directory index (Level 1)
    8000181e:	0154d693          	srli	a3,s1,0x15
  int bit_u = (*pte & PTE_U) ? 1 : 0;

  printf("[cprintf/kernel] va2pa: VA 0x%lx -> PDE_idx:[%ld,%ld], PTE_idx:%ld, Offset:0x%lx, Flags:[P=%d, W=%d, U=%d] -> PA:0x%lx\n",
    80001822:	e44a                	sd	s2,8(sp)
    80001824:	4605                	li	a2,1
    80001826:	e032                	sd	a2,0(sp)
    80001828:	00c8f8b3          	and	a7,a7,a2
    8000182c:	8832                	mv	a6,a2
    8000182e:	1ff77713          	andi	a4,a4,511
    80001832:	1ff6f693          	andi	a3,a3,511
    80001836:	01e4d613          	srli	a2,s1,0x1e
    8000183a:	85a6                	mv	a1,s1
    8000183c:	00006517          	auipc	a0,0x6
    80001840:	91c50513          	addi	a0,a0,-1764 # 80007158 <etext+0x158>
    80001844:	cc7fe0ef          	jal	8000050a <printk>
         va, l2_idx, l1_idx, l0_idx, offset, bit_p, bit_w, bit_u, pa);

  return pa;
}
    80001848:	854a                	mv	a0,s2
    8000184a:	70a2                	ld	ra,40(sp)
    8000184c:	7402                	ld	s0,32(sp)
    8000184e:	64e2                	ld	s1,24(sp)
    80001850:	6942                	ld	s2,16(sp)
    80001852:	6145                	addi	sp,sp,48
    80001854:	8082                	ret
    return (uint64)-1;
    80001856:	597d                	li	s2,-1
    80001858:	bfc5                	j	80001848 <va2pa+0x7a>

000000008000185a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000185a:	715d                	addi	sp,sp,-80
    8000185c:	e486                	sd	ra,72(sp)
    8000185e:	e0a2                	sd	s0,64(sp)
    80001860:	fc26                	sd	s1,56(sp)
    80001862:	f84a                	sd	s2,48(sp)
    80001864:	f44e                	sd	s3,40(sp)
    80001866:	f052                	sd	s4,32(sp)
    80001868:	ec56                	sd	s5,24(sp)
    8000186a:	e85a                	sd	s6,16(sp)
    8000186c:	e45e                	sd	s7,8(sp)
    8000186e:	e062                	sd	s8,0(sp)
    80001870:	0880                	addi	s0,sp,80
    80001872:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001874:	00011497          	auipc	s1,0x11
    80001878:	0b448493          	addi	s1,s1,180 # 80012928 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000187c:	8c26                	mv	s8,s1
    8000187e:	000a57b7          	lui	a5,0xa5
    80001882:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001886:	07b2                	slli	a5,a5,0xc
    80001888:	fa578793          	addi	a5,a5,-91
    8000188c:	4fa50937          	lui	s2,0x4fa50
    80001890:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001894:	1902                	slli	s2,s2,0x20
    80001896:	993e                	add	s2,s2,a5
    80001898:	040009b7          	lui	s3,0x4000
    8000189c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000189e:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018a0:	4b99                	li	s7,6
    800018a2:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    800018a4:	00017a97          	auipc	s5,0x17
    800018a8:	a84a8a93          	addi	s5,s5,-1404 # 80018328 <tickslock>
    char *pa = kalloc();
    800018ac:	aa2ff0ef          	jal	80000b4e <kalloc>
    800018b0:	862a                	mv	a2,a0
    if (pa == 0)
    800018b2:	c121                	beqz	a0,800018f2 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    800018b4:	418485b3          	sub	a1,s1,s8
    800018b8:	858d                	srai	a1,a1,0x3
    800018ba:	032585b3          	mul	a1,a1,s2
    800018be:	05b6                	slli	a1,a1,0xd
    800018c0:	6789                	lui	a5,0x2
    800018c2:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018c4:	875e                	mv	a4,s7
    800018c6:	86da                	mv	a3,s6
    800018c8:	40b985b3          	sub	a1,s3,a1
    800018cc:	8552                	mv	a0,s4
    800018ce:	83bff0ef          	jal	80001108 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    800018d2:	16848493          	addi	s1,s1,360
    800018d6:	fd549be3          	bne	s1,s5,800018ac <proc_mapstacks+0x52>
  }
}
    800018da:	60a6                	ld	ra,72(sp)
    800018dc:	6406                	ld	s0,64(sp)
    800018de:	74e2                	ld	s1,56(sp)
    800018e0:	7942                	ld	s2,48(sp)
    800018e2:	79a2                	ld	s3,40(sp)
    800018e4:	7a02                	ld	s4,32(sp)
    800018e6:	6ae2                	ld	s5,24(sp)
    800018e8:	6b42                	ld	s6,16(sp)
    800018ea:	6ba2                	ld	s7,8(sp)
    800018ec:	6c02                	ld	s8,0(sp)
    800018ee:	6161                	addi	sp,sp,80
    800018f0:	8082                	ret
      panic("kalloc");
    800018f2:	00006517          	auipc	a0,0x6
    800018f6:	8de50513          	addi	a0,a0,-1826 # 800071d0 <etext+0x1d0>
    800018fa:	f3bfe0ef          	jal	80000834 <panic>

00000000800018fe <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018fe:	7139                	addi	sp,sp,-64
    80001900:	fc06                	sd	ra,56(sp)
    80001902:	f822                	sd	s0,48(sp)
    80001904:	f426                	sd	s1,40(sp)
    80001906:	f04a                	sd	s2,32(sp)
    80001908:	ec4e                	sd	s3,24(sp)
    8000190a:	e852                	sd	s4,16(sp)
    8000190c:	e456                	sd	s5,8(sp)
    8000190e:	e05a                	sd	s6,0(sp)
    80001910:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001912:	00006597          	auipc	a1,0x6
    80001916:	8c658593          	addi	a1,a1,-1850 # 800071d8 <etext+0x1d8>
    8000191a:	00011517          	auipc	a0,0x11
    8000191e:	bde50513          	addi	a0,a0,-1058 # 800124f8 <pid_lock>
    80001922:	a86ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001926:	00006597          	auipc	a1,0x6
    8000192a:	8ba58593          	addi	a1,a1,-1862 # 800071e0 <etext+0x1e0>
    8000192e:	00011517          	auipc	a0,0x11
    80001932:	be250513          	addi	a0,a0,-1054 # 80012510 <wait_lock>
    80001936:	a72ff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000193a:	00011497          	auipc	s1,0x11
    8000193e:	fee48493          	addi	s1,s1,-18 # 80012928 <proc>
    initlock(&p->lock, "proc");
    80001942:	00006b17          	auipc	s6,0x6
    80001946:	8aeb0b13          	addi	s6,s6,-1874 # 800071f0 <etext+0x1f0>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000194a:	8aa6                	mv	s5,s1
    8000194c:	000a57b7          	lui	a5,0xa5
    80001950:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001954:	07b2                	slli	a5,a5,0xc
    80001956:	fa578793          	addi	a5,a5,-91
    8000195a:	4fa50937          	lui	s2,0x4fa50
    8000195e:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001962:	1902                	slli	s2,s2,0x20
    80001964:	993e                	add	s2,s2,a5
    80001966:	040009b7          	lui	s3,0x4000
    8000196a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000196c:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    8000196e:	00017a17          	auipc	s4,0x17
    80001972:	9baa0a13          	addi	s4,s4,-1606 # 80018328 <tickslock>
    initlock(&p->lock, "proc");
    80001976:	85da                	mv	a1,s6
    80001978:	8526                	mv	a0,s1
    8000197a:	a2eff0ef          	jal	80000ba8 <initlock>
    p->state = UNUSED;
    8000197e:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001982:	415487b3          	sub	a5,s1,s5
    80001986:	878d                	srai	a5,a5,0x3
    80001988:	032787b3          	mul	a5,a5,s2
    8000198c:	07b6                	slli	a5,a5,0xd
    8000198e:	6709                	lui	a4,0x2
    80001990:	9fb9                	addw	a5,a5,a4
    80001992:	40f987b3          	sub	a5,s3,a5
    80001996:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    80001998:	16848493          	addi	s1,s1,360
    8000199c:	fd449de3          	bne	s1,s4,80001976 <procinit+0x78>
  }
}
    800019a0:	70e2                	ld	ra,56(sp)
    800019a2:	7442                	ld	s0,48(sp)
    800019a4:	74a2                	ld	s1,40(sp)
    800019a6:	7902                	ld	s2,32(sp)
    800019a8:	69e2                	ld	s3,24(sp)
    800019aa:	6a42                	ld	s4,16(sp)
    800019ac:	6aa2                	ld	s5,8(sp)
    800019ae:	6b02                	ld	s6,0(sp)
    800019b0:	6121                	addi	sp,sp,64
    800019b2:	8082                	ret

00000000800019b4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019b4:	1141                	addi	sp,sp,-16
    800019b6:	e406                	sd	ra,8(sp)
    800019b8:	e022                	sd	s0,0(sp)
    800019ba:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    800019bc:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019be:	2501                	sext.w	a0,a0
    800019c0:	60a2                	ld	ra,8(sp)
    800019c2:	6402                	ld	s0,0(sp)
    800019c4:	0141                	addi	sp,sp,16
    800019c6:	8082                	ret

00000000800019c8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800019c8:	1141                	addi	sp,sp,-16
    800019ca:	e406                	sd	ra,8(sp)
    800019cc:	e022                	sd	s0,0(sp)
    800019ce:	0800                	addi	s0,sp,16
    800019d0:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019d2:	2781                	sext.w	a5,a5
    800019d4:	079e                	slli	a5,a5,0x7
  return c;
}
    800019d6:	00011517          	auipc	a0,0x11
    800019da:	b5250513          	addi	a0,a0,-1198 # 80012528 <cpus>
    800019de:	953e                	add	a0,a0,a5
    800019e0:	60a2                	ld	ra,8(sp)
    800019e2:	6402                	ld	s0,0(sp)
    800019e4:	0141                	addi	sp,sp,16
    800019e6:	8082                	ret

00000000800019e8 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019e8:	1101                	addi	sp,sp,-32
    800019ea:	ec06                	sd	ra,24(sp)
    800019ec:	e822                	sd	s0,16(sp)
    800019ee:	e426                	sd	s1,8(sp)
    800019f0:	1000                	addi	s0,sp,32
  push_off();
    800019f2:	9fcff0ef          	jal	80000bee <push_off>
    800019f6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019f8:	2781                	sext.w	a5,a5
    800019fa:	079e                	slli	a5,a5,0x7
    800019fc:	00011717          	auipc	a4,0x11
    80001a00:	afc70713          	addi	a4,a4,-1284 # 800124f8 <pid_lock>
    80001a04:	97ba                	add	a5,a5,a4
    80001a06:	7b9c                	ld	a5,48(a5)
    80001a08:	84be                	mv	s1,a5
  pop_off();
    80001a0a:	a5eff0ef          	jal	80000c68 <pop_off>
  return p;
}
    80001a0e:	8526                	mv	a0,s1
    80001a10:	60e2                	ld	ra,24(sp)
    80001a12:	6442                	ld	s0,16(sp)
    80001a14:	64a2                	ld	s1,8(sp)
    80001a16:	6105                	addi	sp,sp,32
    80001a18:	8082                	ret

0000000080001a1a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a1a:	7179                	addi	sp,sp,-48
    80001a1c:	f406                	sd	ra,40(sp)
    80001a1e:	f022                	sd	s0,32(sp)
    80001a20:	ec26                	sd	s1,24(sp)
    80001a22:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001a24:	fc5ff0ef          	jal	800019e8 <myproc>
    80001a28:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001a2a:	a86ff0ef          	jal	80000cb0 <release>

  if (first) {
    80001a2e:	00009797          	auipc	a5,0x9
    80001a32:	9727a783          	lw	a5,-1678(a5) # 8000a3a0 <first.1>
    80001a36:	cf85                	beqz	a5,80001a6e <forkret+0x54>
    first = 0;
    80001a38:	00009797          	auipc	a5,0x9
    80001a3c:	9607a423          	sw	zero,-1688(a5) # 8000a3a0 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001a40:	4505                	li	a0,1
    80001a42:	427010ef          	jal	80003668 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001a46:	00005797          	auipc	a5,0x5
    80001a4a:	7b278793          	addi	a5,a5,1970 # 800071f8 <etext+0x1f8>
    80001a4e:	fcf43823          	sd	a5,-48(s0)
    80001a52:	fc043c23          	sd	zero,-40(s0)
    80001a56:	fd040593          	addi	a1,s0,-48
    80001a5a:	853e                	mv	a0,a5
    80001a5c:	6c1020ef          	jal	8000491c <kexec>
    80001a60:	6cbc                	ld	a5,88(s1)
    80001a62:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001a64:	6cbc                	ld	a5,88(s1)
    80001a66:	7bb8                	ld	a4,112(a5)
    80001a68:	57fd                	li	a5,-1
    80001a6a:	02f70d63          	beq	a4,a5,80001aa4 <forkret+0x8a>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001a6e:	2fd000ef          	jal	8000256a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001a72:	68a8                	ld	a0,80(s1)
    80001a74:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a76:	04000737          	lui	a4,0x4000
    80001a7a:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001a7c:	0732                	slli	a4,a4,0xc
    80001a7e:	00004797          	auipc	a5,0x4
    80001a82:	61e78793          	addi	a5,a5,1566 # 8000609c <userret>
    80001a86:	00004697          	auipc	a3,0x4
    80001a8a:	57a68693          	addi	a3,a3,1402 # 80006000 <_trampoline>
    80001a8e:	8f95                	sub	a5,a5,a3
    80001a90:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a92:	577d                	li	a4,-1
    80001a94:	177e                	slli	a4,a4,0x3f
    80001a96:	8d59                	or	a0,a0,a4
    80001a98:	9782                	jalr	a5
}
    80001a9a:	70a2                	ld	ra,40(sp)
    80001a9c:	7402                	ld	s0,32(sp)
    80001a9e:	64e2                	ld	s1,24(sp)
    80001aa0:	6145                	addi	sp,sp,48
    80001aa2:	8082                	ret
      panic("exec");
    80001aa4:	00005517          	auipc	a0,0x5
    80001aa8:	75c50513          	addi	a0,a0,1884 # 80007200 <etext+0x200>
    80001aac:	d89fe0ef          	jal	80000834 <panic>

0000000080001ab0 <allocpid>:
{
    80001ab0:	1101                	addi	sp,sp,-32
    80001ab2:	ec06                	sd	ra,24(sp)
    80001ab4:	e822                	sd	s0,16(sp)
    80001ab6:	e426                	sd	s1,8(sp)
    80001ab8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001aba:	00011517          	auipc	a0,0x11
    80001abe:	a3e50513          	addi	a0,a0,-1474 # 800124f8 <pid_lock>
    80001ac2:	966ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001ac6:	00009797          	auipc	a5,0x9
    80001aca:	8de78793          	addi	a5,a5,-1826 # 8000a3a4 <nextpid>
    80001ace:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ad0:	0014871b          	addiw	a4,s1,1
    80001ad4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ad6:	00011517          	auipc	a0,0x11
    80001ada:	a2250513          	addi	a0,a0,-1502 # 800124f8 <pid_lock>
    80001ade:	9d2ff0ef          	jal	80000cb0 <release>
}
    80001ae2:	8526                	mv	a0,s1
    80001ae4:	60e2                	ld	ra,24(sp)
    80001ae6:	6442                	ld	s0,16(sp)
    80001ae8:	64a2                	ld	s1,8(sp)
    80001aea:	6105                	addi	sp,sp,32
    80001aec:	8082                	ret

0000000080001aee <proc_pagetable>:
{
    80001aee:	1101                	addi	sp,sp,-32
    80001af0:	ec06                	sd	ra,24(sp)
    80001af2:	e822                	sd	s0,16(sp)
    80001af4:	e426                	sd	s1,8(sp)
    80001af6:	e04a                	sd	s2,0(sp)
    80001af8:	1000                	addi	s0,sp,32
    80001afa:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001afc:	efeff0ef          	jal	800011fa <uvmcreate>
    80001b00:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001b02:	cd05                	beqz	a0,80001b3a <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001b04:	4729                	li	a4,10
    80001b06:	00004697          	auipc	a3,0x4
    80001b0a:	4fa68693          	addi	a3,a3,1274 # 80006000 <_trampoline>
    80001b0e:	6605                	lui	a2,0x1
    80001b10:	040005b7          	lui	a1,0x4000
    80001b14:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b16:	05b2                	slli	a1,a1,0xc
    80001b18:	d3aff0ef          	jal	80001052 <mappages>
    80001b1c:	02054663          	bltz	a0,80001b48 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001b20:	4719                	li	a4,6
    80001b22:	05893683          	ld	a3,88(s2)
    80001b26:	6605                	lui	a2,0x1
    80001b28:	020005b7          	lui	a1,0x2000
    80001b2c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b2e:	05b6                	slli	a1,a1,0xd
    80001b30:	8526                	mv	a0,s1
    80001b32:	d20ff0ef          	jal	80001052 <mappages>
    80001b36:	00054f63          	bltz	a0,80001b54 <proc_pagetable+0x66>
}
    80001b3a:	8526                	mv	a0,s1
    80001b3c:	60e2                	ld	ra,24(sp)
    80001b3e:	6442                	ld	s0,16(sp)
    80001b40:	64a2                	ld	s1,8(sp)
    80001b42:	6902                	ld	s2,0(sp)
    80001b44:	6105                	addi	sp,sp,32
    80001b46:	8082                	ret
    uvmfree(pagetable, 0);
    80001b48:	4581                	li	a1,0
    80001b4a:	8526                	mv	a0,s1
    80001b4c:	8a9ff0ef          	jal	800013f4 <uvmfree>
    return 0;
    80001b50:	4481                	li	s1,0
    80001b52:	b7e5                	j	80001b3a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b54:	4681                	li	a3,0
    80001b56:	4605                	li	a2,1
    80001b58:	040005b7          	lui	a1,0x4000
    80001b5c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b5e:	05b2                	slli	a1,a1,0xc
    80001b60:	8526                	mv	a0,s1
    80001b62:	ebeff0ef          	jal	80001220 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b66:	4581                	li	a1,0
    80001b68:	8526                	mv	a0,s1
    80001b6a:	88bff0ef          	jal	800013f4 <uvmfree>
    return 0;
    80001b6e:	4481                	li	s1,0
    80001b70:	b7e9                	j	80001b3a <proc_pagetable+0x4c>

0000000080001b72 <proc_freepagetable>:
{
    80001b72:	1101                	addi	sp,sp,-32
    80001b74:	ec06                	sd	ra,24(sp)
    80001b76:	e822                	sd	s0,16(sp)
    80001b78:	e426                	sd	s1,8(sp)
    80001b7a:	e04a                	sd	s2,0(sp)
    80001b7c:	1000                	addi	s0,sp,32
    80001b7e:	84aa                	mv	s1,a0
    80001b80:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b82:	4681                	li	a3,0
    80001b84:	4605                	li	a2,1
    80001b86:	040005b7          	lui	a1,0x4000
    80001b8a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b8c:	05b2                	slli	a1,a1,0xc
    80001b8e:	e92ff0ef          	jal	80001220 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b92:	4681                	li	a3,0
    80001b94:	4605                	li	a2,1
    80001b96:	020005b7          	lui	a1,0x2000
    80001b9a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b9c:	05b6                	slli	a1,a1,0xd
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	e80ff0ef          	jal	80001220 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ba4:	85ca                	mv	a1,s2
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	84dff0ef          	jal	800013f4 <uvmfree>
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6902                	ld	s2,0(sp)
    80001bb4:	6105                	addi	sp,sp,32
    80001bb6:	8082                	ret

0000000080001bb8 <freeproc>:
{
    80001bb8:	1101                	addi	sp,sp,-32
    80001bba:	ec06                	sd	ra,24(sp)
    80001bbc:	e822                	sd	s0,16(sp)
    80001bbe:	e426                	sd	s1,8(sp)
    80001bc0:	1000                	addi	s0,sp,32
    80001bc2:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001bc4:	6d28                	ld	a0,88(a0)
    80001bc6:	c119                	beqz	a0,80001bcc <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001bc8:	e9ffe0ef          	jal	80000a66 <kfree>
  p->trapframe = 0;
    80001bcc:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001bd0:	68a8                	ld	a0,80(s1)
    80001bd2:	c501                	beqz	a0,80001bda <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001bd4:	64ac                	ld	a1,72(s1)
    80001bd6:	f9dff0ef          	jal	80001b72 <proc_freepagetable>
  p->pagetable = 0;
    80001bda:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bde:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001be2:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001be6:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bea:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bee:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bf2:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bf6:	0004ac23          	sw	zero,24(s1)
}
    80001bfa:	60e2                	ld	ra,24(sp)
    80001bfc:	6442                	ld	s0,16(sp)
    80001bfe:	64a2                	ld	s1,8(sp)
    80001c00:	6105                	addi	sp,sp,32
    80001c02:	8082                	ret

0000000080001c04 <allocproc>:
{
    80001c04:	1101                	addi	sp,sp,-32
    80001c06:	ec06                	sd	ra,24(sp)
    80001c08:	e822                	sd	s0,16(sp)
    80001c0a:	e426                	sd	s1,8(sp)
    80001c0c:	e04a                	sd	s2,0(sp)
    80001c0e:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001c10:	00011497          	auipc	s1,0x11
    80001c14:	d1848493          	addi	s1,s1,-744 # 80012928 <proc>
    80001c18:	00016917          	auipc	s2,0x16
    80001c1c:	71090913          	addi	s2,s2,1808 # 80018328 <tickslock>
    acquire(&p->lock);
    80001c20:	8526                	mv	a0,s1
    80001c22:	806ff0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001c26:	4c9c                	lw	a5,24(s1)
    80001c28:	cb91                	beqz	a5,80001c3c <allocproc+0x38>
      release(&p->lock);
    80001c2a:	8526                	mv	a0,s1
    80001c2c:	884ff0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001c30:	16848493          	addi	s1,s1,360
    80001c34:	ff2496e3          	bne	s1,s2,80001c20 <allocproc+0x1c>
  return 0;
    80001c38:	4481                	li	s1,0
    80001c3a:	a089                	j	80001c7c <allocproc+0x78>
  p->pid = allocpid();
    80001c3c:	e75ff0ef          	jal	80001ab0 <allocpid>
    80001c40:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c42:	4785                	li	a5,1
    80001c44:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001c46:	f09fe0ef          	jal	80000b4e <kalloc>
    80001c4a:	892a                	mv	s2,a0
    80001c4c:	eca8                	sd	a0,88(s1)
    80001c4e:	cd15                	beqz	a0,80001c8a <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001c50:	8526                	mv	a0,s1
    80001c52:	e9dff0ef          	jal	80001aee <proc_pagetable>
    80001c56:	892a                	mv	s2,a0
    80001c58:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001c5a:	c121                	beqz	a0,80001c9a <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001c5c:	07000613          	li	a2,112
    80001c60:	4581                	li	a1,0
    80001c62:	06048513          	addi	a0,s1,96
    80001c66:	882ff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001c6a:	00000797          	auipc	a5,0x0
    80001c6e:	db078793          	addi	a5,a5,-592 # 80001a1a <forkret>
    80001c72:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c74:	60bc                	ld	a5,64(s1)
    80001c76:	6705                	lui	a4,0x1
    80001c78:	97ba                	add	a5,a5,a4
    80001c7a:	f4bc                	sd	a5,104(s1)
}
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	60e2                	ld	ra,24(sp)
    80001c80:	6442                	ld	s0,16(sp)
    80001c82:	64a2                	ld	s1,8(sp)
    80001c84:	6902                	ld	s2,0(sp)
    80001c86:	6105                	addi	sp,sp,32
    80001c88:	8082                	ret
    freeproc(p);
    80001c8a:	8526                	mv	a0,s1
    80001c8c:	f2dff0ef          	jal	80001bb8 <freeproc>
    release(&p->lock);
    80001c90:	8526                	mv	a0,s1
    80001c92:	81eff0ef          	jal	80000cb0 <release>
    return 0;
    80001c96:	84ca                	mv	s1,s2
    80001c98:	b7d5                	j	80001c7c <allocproc+0x78>
    freeproc(p);
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	f1dff0ef          	jal	80001bb8 <freeproc>
    release(&p->lock);
    80001ca0:	8526                	mv	a0,s1
    80001ca2:	80eff0ef          	jal	80000cb0 <release>
    return 0;
    80001ca6:	84ca                	mv	s1,s2
    80001ca8:	bfd1                	j	80001c7c <allocproc+0x78>

0000000080001caa <userinit>:
{
    80001caa:	1101                	addi	sp,sp,-32
    80001cac:	ec06                	sd	ra,24(sp)
    80001cae:	e822                	sd	s0,16(sp)
    80001cb0:	e426                	sd	s1,8(sp)
    80001cb2:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cb4:	f51ff0ef          	jal	80001c04 <allocproc>
    80001cb8:	84aa                	mv	s1,a0
  initproc = p;
    80001cba:	00008797          	auipc	a5,0x8
    80001cbe:	72a7bb23          	sd	a0,1846(a5) # 8000a3f0 <initproc>
  p->cwd = namei("/");
    80001cc2:	00005517          	auipc	a0,0x5
    80001cc6:	54650513          	addi	a0,a0,1350 # 80007208 <etext+0x208>
    80001cca:	6fd010ef          	jal	80003bc6 <namei>
    80001cce:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cd2:	478d                	li	a5,3
    80001cd4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cd6:	8526                	mv	a0,s1
    80001cd8:	fd9fe0ef          	jal	80000cb0 <release>
}
    80001cdc:	60e2                	ld	ra,24(sp)
    80001cde:	6442                	ld	s0,16(sp)
    80001ce0:	64a2                	ld	s1,8(sp)
    80001ce2:	6105                	addi	sp,sp,32
    80001ce4:	8082                	ret

0000000080001ce6 <growproc>:
{
    80001ce6:	1101                	addi	sp,sp,-32
    80001ce8:	ec06                	sd	ra,24(sp)
    80001cea:	e822                	sd	s0,16(sp)
    80001cec:	e426                	sd	s1,8(sp)
    80001cee:	e04a                	sd	s2,0(sp)
    80001cf0:	1000                	addi	s0,sp,32
    80001cf2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001cf4:	cf5ff0ef          	jal	800019e8 <myproc>
    80001cf8:	892a                	mv	s2,a0
  sz = p->sz;
    80001cfa:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001cfc:	02905963          	blez	s1,80001d2e <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001d00:	00b48633          	add	a2,s1,a1
    80001d04:	020007b7          	lui	a5,0x2000
    80001d08:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001d0a:	07b6                	slli	a5,a5,0xd
    80001d0c:	02c7ea63          	bltu	a5,a2,80001d40 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d10:	4691                	li	a3,4
    80001d12:	6928                	ld	a0,80(a0)
    80001d14:	ddaff0ef          	jal	800012ee <uvmalloc>
    80001d18:	85aa                	mv	a1,a0
    80001d1a:	c50d                	beqz	a0,80001d44 <growproc+0x5e>
  p->sz = sz;
    80001d1c:	04b93423          	sd	a1,72(s2)
  return 0;
    80001d20:	4501                	li	a0,0
}
    80001d22:	60e2                	ld	ra,24(sp)
    80001d24:	6442                	ld	s0,16(sp)
    80001d26:	64a2                	ld	s1,8(sp)
    80001d28:	6902                	ld	s2,0(sp)
    80001d2a:	6105                	addi	sp,sp,32
    80001d2c:	8082                	ret
  } else if (n < 0) {
    80001d2e:	fe04d7e3          	bgez	s1,80001d1c <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d32:	00b48633          	add	a2,s1,a1
    80001d36:	6928                	ld	a0,80(a0)
    80001d38:	d72ff0ef          	jal	800012aa <uvmdealloc>
    80001d3c:	85aa                	mv	a1,a0
    80001d3e:	bff9                	j	80001d1c <growproc+0x36>
      return -1;
    80001d40:	557d                	li	a0,-1
    80001d42:	b7c5                	j	80001d22 <growproc+0x3c>
      return -1;
    80001d44:	557d                	li	a0,-1
    80001d46:	bff1                	j	80001d22 <growproc+0x3c>

0000000080001d48 <kfork>:
{
    80001d48:	7139                	addi	sp,sp,-64
    80001d4a:	fc06                	sd	ra,56(sp)
    80001d4c:	f822                	sd	s0,48(sp)
    80001d4e:	f426                	sd	s1,40(sp)
    80001d50:	e456                	sd	s5,8(sp)
    80001d52:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d54:	c95ff0ef          	jal	800019e8 <myproc>
    80001d58:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001d5a:	eabff0ef          	jal	80001c04 <allocproc>
    80001d5e:	0e050a63          	beqz	a0,80001e52 <kfork+0x10a>
    80001d62:	e852                	sd	s4,16(sp)
    80001d64:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001d66:	048ab603          	ld	a2,72(s5)
    80001d6a:	692c                	ld	a1,80(a0)
    80001d6c:	050ab503          	ld	a0,80(s5)
    80001d70:	eb6ff0ef          	jal	80001426 <uvmcopy>
    80001d74:	04054863          	bltz	a0,80001dc4 <kfork+0x7c>
    80001d78:	f04a                	sd	s2,32(sp)
    80001d7a:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d7c:	048ab783          	ld	a5,72(s5)
    80001d80:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d84:	058ab683          	ld	a3,88(s5)
    80001d88:	87b6                	mv	a5,a3
    80001d8a:	058a3703          	ld	a4,88(s4)
    80001d8e:	12068693          	addi	a3,a3,288
    80001d92:	6388                	ld	a0,0(a5)
    80001d94:	678c                	ld	a1,8(a5)
    80001d96:	6b90                	ld	a2,16(a5)
    80001d98:	e308                	sd	a0,0(a4)
    80001d9a:	e70c                	sd	a1,8(a4)
    80001d9c:	eb10                	sd	a2,16(a4)
    80001d9e:	6f90                	ld	a2,24(a5)
    80001da0:	ef10                	sd	a2,24(a4)
    80001da2:	02078793          	addi	a5,a5,32
    80001da6:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001daa:	fed794e3          	bne	a5,a3,80001d92 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001dae:	058a3783          	ld	a5,88(s4)
    80001db2:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001db6:	0d0a8493          	addi	s1,s5,208
    80001dba:	0d0a0913          	addi	s2,s4,208
    80001dbe:	150a8993          	addi	s3,s5,336
    80001dc2:	a831                	j	80001dde <kfork+0x96>
    freeproc(np);
    80001dc4:	8552                	mv	a0,s4
    80001dc6:	df3ff0ef          	jal	80001bb8 <freeproc>
    release(&np->lock);
    80001dca:	8552                	mv	a0,s4
    80001dcc:	ee5fe0ef          	jal	80000cb0 <release>
    return -1;
    80001dd0:	54fd                	li	s1,-1
    80001dd2:	6a42                	ld	s4,16(sp)
    80001dd4:	a885                	j	80001e44 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001dd6:	04a1                	addi	s1,s1,8
    80001dd8:	0921                	addi	s2,s2,8
    80001dda:	01348963          	beq	s1,s3,80001dec <kfork+0xa4>
    if (p->ofile[i])
    80001dde:	6088                	ld	a0,0(s1)
    80001de0:	d97d                	beqz	a0,80001dd6 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001de2:	436020ef          	jal	80004218 <filedup>
    80001de6:	00a93023          	sd	a0,0(s2)
    80001dea:	b7f5                	j	80001dd6 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001dec:	150ab503          	ld	a0,336(s5)
    80001df0:	506010ef          	jal	800032f6 <idup>
    80001df4:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001df8:	4641                	li	a2,16
    80001dfa:	158a8593          	addi	a1,s5,344
    80001dfe:	158a0513          	addi	a0,s4,344
    80001e02:	83aff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001e06:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001e0a:	8552                	mv	a0,s4
    80001e0c:	ea5fe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001e10:	00010517          	auipc	a0,0x10
    80001e14:	70050513          	addi	a0,a0,1792 # 80012510 <wait_lock>
    80001e18:	e11fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001e1c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e20:	00010517          	auipc	a0,0x10
    80001e24:	6f050513          	addi	a0,a0,1776 # 80012510 <wait_lock>
    80001e28:	e89fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001e2c:	8552                	mv	a0,s4
    80001e2e:	dfbfe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001e32:	478d                	li	a5,3
    80001e34:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e38:	8552                	mv	a0,s4
    80001e3a:	e77fe0ef          	jal	80000cb0 <release>
  return pid;
    80001e3e:	7902                	ld	s2,32(sp)
    80001e40:	69e2                	ld	s3,24(sp)
    80001e42:	6a42                	ld	s4,16(sp)
}
    80001e44:	8526                	mv	a0,s1
    80001e46:	70e2                	ld	ra,56(sp)
    80001e48:	7442                	ld	s0,48(sp)
    80001e4a:	74a2                	ld	s1,40(sp)
    80001e4c:	6aa2                	ld	s5,8(sp)
    80001e4e:	6121                	addi	sp,sp,64
    80001e50:	8082                	ret
    return -1;
    80001e52:	54fd                	li	s1,-1
    80001e54:	bfc5                	j	80001e44 <kfork+0xfc>

0000000080001e56 <scheduler>:
{
    80001e56:	711d                	addi	sp,sp,-96
    80001e58:	ec86                	sd	ra,88(sp)
    80001e5a:	e8a2                	sd	s0,80(sp)
    80001e5c:	e4a6                	sd	s1,72(sp)
    80001e5e:	e0ca                	sd	s2,64(sp)
    80001e60:	fc4e                	sd	s3,56(sp)
    80001e62:	f852                	sd	s4,48(sp)
    80001e64:	f456                	sd	s5,40(sp)
    80001e66:	f05a                	sd	s6,32(sp)
    80001e68:	ec5e                	sd	s7,24(sp)
    80001e6a:	e862                	sd	s8,16(sp)
    80001e6c:	e466                	sd	s9,8(sp)
    80001e6e:	1080                	addi	s0,sp,96
    80001e70:	8792                	mv	a5,tp
  int id = r_tp();
    80001e72:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e74:	00779a93          	slli	s5,a5,0x7
    80001e78:	00010717          	auipc	a4,0x10
    80001e7c:	68070713          	addi	a4,a4,1664 # 800124f8 <pid_lock>
    80001e80:	9756                	add	a4,a4,s5
    80001e82:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001e86:	00010717          	auipc	a4,0x10
    80001e8a:	6aa70713          	addi	a4,a4,1706 # 80012530 <cpus+0x8>
    80001e8e:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001e90:	4c11                	li	s8,4
        c->proc = p;
    80001e92:	00010b17          	auipc	s6,0x10
    80001e96:	666b0b13          	addi	s6,s6,1638 # 800124f8 <pid_lock>
    80001e9a:	079e                	slli	a5,a5,0x7
    80001e9c:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001ea0:	4b85                	li	s7,1
    80001ea2:	a0a9                	j	80001eec <scheduler+0x96>
      release(&p->lock);
    80001ea4:	8526                	mv	a0,s1
    80001ea6:	e0bfe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001eaa:	16848493          	addi	s1,s1,360
    80001eae:	03248b63          	beq	s1,s2,80001ee4 <scheduler+0x8e>
      acquire(&p->lock);
    80001eb2:	8526                	mv	a0,s1
    80001eb4:	d75fe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001eb8:	4c9c                	lw	a5,24(s1)
    80001eba:	ff3795e3          	bne	a5,s3,80001ea4 <scheduler+0x4e>
        p->state = RUNNING;
    80001ebe:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001ec2:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001ec6:	06048593          	addi	a1,s1,96
    80001eca:	8556                	mv	a0,s5
    80001ecc:	5f4000ef          	jal	800024c0 <swtch>
    80001ed0:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001ed2:	2781                	sext.w	a5,a5
    80001ed4:	079e                	slli	a5,a5,0x7
    80001ed6:	97da                	add	a5,a5,s6
    80001ed8:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001edc:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001ee0:	8cde                	mv	s9,s7
    80001ee2:	b7c9                	j	80001ea4 <scheduler+0x4e>
    if (found == 0) {
    80001ee4:	000c9463          	bnez	s9,80001eec <scheduler+0x96>
      asm volatile("wfi");
    80001ee8:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001eec:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001ef0:	10017073          	csrci	sstatus,2
    int found = 0;
    80001ef4:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001ef6:	00011497          	auipc	s1,0x11
    80001efa:	a3248493          	addi	s1,s1,-1486 # 80012928 <proc>
      if (p->state == RUNNABLE) {
    80001efe:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f00:	00016917          	auipc	s2,0x16
    80001f04:	42890913          	addi	s2,s2,1064 # 80018328 <tickslock>
    80001f08:	b76d                	j	80001eb2 <scheduler+0x5c>

0000000080001f0a <sched>:
{
    80001f0a:	7179                	addi	sp,sp,-48
    80001f0c:	f406                	sd	ra,40(sp)
    80001f0e:	f022                	sd	s0,32(sp)
    80001f10:	ec26                	sd	s1,24(sp)
    80001f12:	e84a                	sd	s2,16(sp)
    80001f14:	e44e                	sd	s3,8(sp)
    80001f16:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f18:	ad1ff0ef          	jal	800019e8 <myproc>
    80001f1c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001f1e:	ca5fe0ef          	jal	80000bc2 <holding>
    80001f22:	c935                	beqz	a0,80001f96 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f24:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001f26:	2781                	sext.w	a5,a5
    80001f28:	079e                	slli	a5,a5,0x7
    80001f2a:	00010717          	auipc	a4,0x10
    80001f2e:	5ce70713          	addi	a4,a4,1486 # 800124f8 <pid_lock>
    80001f32:	97ba                	add	a5,a5,a4
    80001f34:	0a87a703          	lw	a4,168(a5)
    80001f38:	4785                	li	a5,1
    80001f3a:	06f71463          	bne	a4,a5,80001fa2 <sched+0x98>
  if (p->state == RUNNING)
    80001f3e:	4c98                	lw	a4,24(s1)
    80001f40:	4791                	li	a5,4
    80001f42:	06f70663          	beq	a4,a5,80001fae <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001f46:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f4a:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001f4c:	e7bd                	bnez	a5,80001fba <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f4e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f50:	00010917          	auipc	s2,0x10
    80001f54:	5a890913          	addi	s2,s2,1448 # 800124f8 <pid_lock>
    80001f58:	2781                	sext.w	a5,a5
    80001f5a:	079e                	slli	a5,a5,0x7
    80001f5c:	97ca                	add	a5,a5,s2
    80001f5e:	0ac7a983          	lw	s3,172(a5)
    80001f62:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f64:	2781                	sext.w	a5,a5
    80001f66:	079e                	slli	a5,a5,0x7
    80001f68:	07a1                	addi	a5,a5,8
    80001f6a:	00010597          	auipc	a1,0x10
    80001f6e:	5be58593          	addi	a1,a1,1470 # 80012528 <cpus>
    80001f72:	95be                	add	a1,a1,a5
    80001f74:	06048513          	addi	a0,s1,96
    80001f78:	548000ef          	jal	800024c0 <swtch>
    80001f7c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f7e:	2781                	sext.w	a5,a5
    80001f80:	079e                	slli	a5,a5,0x7
    80001f82:	993e                	add	s2,s2,a5
    80001f84:	0b392623          	sw	s3,172(s2)
}
    80001f88:	70a2                	ld	ra,40(sp)
    80001f8a:	7402                	ld	s0,32(sp)
    80001f8c:	64e2                	ld	s1,24(sp)
    80001f8e:	6942                	ld	s2,16(sp)
    80001f90:	69a2                	ld	s3,8(sp)
    80001f92:	6145                	addi	sp,sp,48
    80001f94:	8082                	ret
    panic("sched p->lock");
    80001f96:	00005517          	auipc	a0,0x5
    80001f9a:	27a50513          	addi	a0,a0,634 # 80007210 <etext+0x210>
    80001f9e:	897fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80001fa2:	00005517          	auipc	a0,0x5
    80001fa6:	27e50513          	addi	a0,a0,638 # 80007220 <etext+0x220>
    80001faa:	88bfe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80001fae:	00005517          	auipc	a0,0x5
    80001fb2:	28250513          	addi	a0,a0,642 # 80007230 <etext+0x230>
    80001fb6:	87ffe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80001fba:	00005517          	auipc	a0,0x5
    80001fbe:	28650513          	addi	a0,a0,646 # 80007240 <etext+0x240>
    80001fc2:	873fe0ef          	jal	80000834 <panic>

0000000080001fc6 <yield>:
{
    80001fc6:	1101                	addi	sp,sp,-32
    80001fc8:	ec06                	sd	ra,24(sp)
    80001fca:	e822                	sd	s0,16(sp)
    80001fcc:	e426                	sd	s1,8(sp)
    80001fce:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fd0:	a19ff0ef          	jal	800019e8 <myproc>
    80001fd4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001fd6:	c53fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001fda:	478d                	li	a5,3
    80001fdc:	cc9c                	sw	a5,24(s1)
  sched();
    80001fde:	f2dff0ef          	jal	80001f0a <sched>
  release(&p->lock);
    80001fe2:	8526                	mv	a0,s1
    80001fe4:	ccdfe0ef          	jal	80000cb0 <release>
}
    80001fe8:	60e2                	ld	ra,24(sp)
    80001fea:	6442                	ld	s0,16(sp)
    80001fec:	64a2                	ld	s1,8(sp)
    80001fee:	6105                	addi	sp,sp,32
    80001ff0:	8082                	ret

0000000080001ff2 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001ff2:	1101                	addi	sp,sp,-32
    80001ff4:	ec06                	sd	ra,24(sp)
    80001ff6:	e822                	sd	s0,16(sp)
    80001ff8:	e426                	sd	s1,8(sp)
    80001ffa:	e04a                	sd	s2,0(sp)
    80001ffc:	1000                	addi	s0,sp,32
    80001ffe:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002000:	9e9ff0ef          	jal	800019e8 <myproc>
    80002004:	892a                	mv	s2,a0

  acquire(&p->lock);
    80002006:	c23fe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    8000200a:	cc81                	beqz	s1,80002022 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    8000200c:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80002010:	854a                	mv	a0,s2
    80002012:	c9ffe0ef          	jal	80000cb0 <release>
}
    80002016:	60e2                	ld	ra,24(sp)
    80002018:	6442                	ld	s0,16(sp)
    8000201a:	64a2                	ld	s1,8(sp)
    8000201c:	6902                	ld	s2,0(sp)
    8000201e:	6105                	addi	sp,sp,32
    80002020:	8082                	ret
    panic("sleep_prepare: zero chan");
    80002022:	00005517          	auipc	a0,0x5
    80002026:	23650513          	addi	a0,a0,566 # 80007258 <etext+0x258>
    8000202a:	80bfe0ef          	jal	80000834 <panic>

000000008000202e <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    8000202e:	1101                	addi	sp,sp,-32
    80002030:	ec06                	sd	ra,24(sp)
    80002032:	e822                	sd	s0,16(sp)
    80002034:	e426                	sd	s1,8(sp)
    80002036:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002038:	9b1ff0ef          	jal	800019e8 <myproc>
    8000203c:	84aa                	mv	s1,a0

  acquire(&p->lock);
    8000203e:	bebfe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    80002042:	709c                	ld	a5,32(s1)
    80002044:	c789                	beqz	a5,8000204e <sleep+0x20>
    p->state = SLEEPING;
    80002046:	4789                	li	a5,2
    80002048:	cc9c                	sw	a5,24(s1)
    sched();
    8000204a:	ec1ff0ef          	jal	80001f0a <sched>
  }
  release(&p->lock);
    8000204e:	8526                	mv	a0,s1
    80002050:	c61fe0ef          	jal	80000cb0 <release>
}
    80002054:	60e2                	ld	ra,24(sp)
    80002056:	6442                	ld	s0,16(sp)
    80002058:	64a2                	ld	s1,8(sp)
    8000205a:	6105                	addi	sp,sp,32
    8000205c:	8082                	ret

000000008000205e <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    8000205e:	7139                	addi	sp,sp,-64
    80002060:	fc06                	sd	ra,56(sp)
    80002062:	f822                	sd	s0,48(sp)
    80002064:	f426                	sd	s1,40(sp)
    80002066:	f04a                	sd	s2,32(sp)
    80002068:	ec4e                	sd	s3,24(sp)
    8000206a:	e852                	sd	s4,16(sp)
    8000206c:	e456                	sd	s5,8(sp)
    8000206e:	0080                	addi	s0,sp,64
    80002070:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002072:	00011497          	auipc	s1,0x11
    80002076:	8b648493          	addi	s1,s1,-1866 # 80012928 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    8000207a:	4a09                	li	s4,2
        p->state = RUNNABLE;
    8000207c:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    8000207e:	00016997          	auipc	s3,0x16
    80002082:	2aa98993          	addi	s3,s3,682 # 80018328 <tickslock>
    80002086:	a801                	j	80002096 <wakeup+0x38>
      }
    }
    release(&p->lock);
    80002088:	8526                	mv	a0,s1
    8000208a:	c27fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000208e:	16848493          	addi	s1,s1,360
    80002092:	03348063          	beq	s1,s3,800020b2 <wakeup+0x54>
    acquire(&p->lock);
    80002096:	8526                	mv	a0,s1
    80002098:	b91fe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    8000209c:	709c                	ld	a5,32(s1)
    8000209e:	ff2795e3          	bne	a5,s2,80002088 <wakeup+0x2a>
      p->chan = 0;
    800020a2:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    800020a6:	4c9c                	lw	a5,24(s1)
    800020a8:	ff4790e3          	bne	a5,s4,80002088 <wakeup+0x2a>
        p->state = RUNNABLE;
    800020ac:	0154ac23          	sw	s5,24(s1)
    800020b0:	bfe1                	j	80002088 <wakeup+0x2a>
  }
}
    800020b2:	70e2                	ld	ra,56(sp)
    800020b4:	7442                	ld	s0,48(sp)
    800020b6:	74a2                	ld	s1,40(sp)
    800020b8:	7902                	ld	s2,32(sp)
    800020ba:	69e2                	ld	s3,24(sp)
    800020bc:	6a42                	ld	s4,16(sp)
    800020be:	6aa2                	ld	s5,8(sp)
    800020c0:	6121                	addi	sp,sp,64
    800020c2:	8082                	ret

00000000800020c4 <reparent>:
{
    800020c4:	7179                	addi	sp,sp,-48
    800020c6:	f406                	sd	ra,40(sp)
    800020c8:	f022                	sd	s0,32(sp)
    800020ca:	ec26                	sd	s1,24(sp)
    800020cc:	e84a                	sd	s2,16(sp)
    800020ce:	e44e                	sd	s3,8(sp)
    800020d0:	e052                	sd	s4,0(sp)
    800020d2:	1800                	addi	s0,sp,48
    800020d4:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020d6:	00011497          	auipc	s1,0x11
    800020da:	85248493          	addi	s1,s1,-1966 # 80012928 <proc>
      pp->parent = initproc;
    800020de:	00008a17          	auipc	s4,0x8
    800020e2:	312a0a13          	addi	s4,s4,786 # 8000a3f0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020e6:	00016997          	auipc	s3,0x16
    800020ea:	24298993          	addi	s3,s3,578 # 80018328 <tickslock>
    800020ee:	a029                	j	800020f8 <reparent+0x34>
    800020f0:	16848493          	addi	s1,s1,360
    800020f4:	01348b63          	beq	s1,s3,8000210a <reparent+0x46>
    if (pp->parent == p) {
    800020f8:	7c9c                	ld	a5,56(s1)
    800020fa:	ff279be3          	bne	a5,s2,800020f0 <reparent+0x2c>
      pp->parent = initproc;
    800020fe:	000a3503          	ld	a0,0(s4)
    80002102:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002104:	f5bff0ef          	jal	8000205e <wakeup>
    80002108:	b7e5                	j	800020f0 <reparent+0x2c>
}
    8000210a:	70a2                	ld	ra,40(sp)
    8000210c:	7402                	ld	s0,32(sp)
    8000210e:	64e2                	ld	s1,24(sp)
    80002110:	6942                	ld	s2,16(sp)
    80002112:	69a2                	ld	s3,8(sp)
    80002114:	6a02                	ld	s4,0(sp)
    80002116:	6145                	addi	sp,sp,48
    80002118:	8082                	ret

000000008000211a <kexit>:
{
    8000211a:	7179                	addi	sp,sp,-48
    8000211c:	f406                	sd	ra,40(sp)
    8000211e:	f022                	sd	s0,32(sp)
    80002120:	ec26                	sd	s1,24(sp)
    80002122:	e84a                	sd	s2,16(sp)
    80002124:	e44e                	sd	s3,8(sp)
    80002126:	e052                	sd	s4,0(sp)
    80002128:	1800                	addi	s0,sp,48
    8000212a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000212c:	8bdff0ef          	jal	800019e8 <myproc>
    80002130:	89aa                	mv	s3,a0
  if (p == initproc)
    80002132:	00008797          	auipc	a5,0x8
    80002136:	2be7b783          	ld	a5,702(a5) # 8000a3f0 <initproc>
    8000213a:	0d050493          	addi	s1,a0,208
    8000213e:	15050913          	addi	s2,a0,336
    80002142:	00a79b63          	bne	a5,a0,80002158 <kexit+0x3e>
    panic("init exiting");
    80002146:	00005517          	auipc	a0,0x5
    8000214a:	13250513          	addi	a0,a0,306 # 80007278 <etext+0x278>
    8000214e:	ee6fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002152:	04a1                	addi	s1,s1,8
    80002154:	01248963          	beq	s1,s2,80002166 <kexit+0x4c>
    if (p->ofile[fd]) {
    80002158:	6088                	ld	a0,0(s1)
    8000215a:	dd65                	beqz	a0,80002152 <kexit+0x38>
      fileclose(f);
    8000215c:	102020ef          	jal	8000425e <fileclose>
      p->ofile[fd] = 0;
    80002160:	0004b023          	sd	zero,0(s1)
    80002164:	b7fd                	j	80002152 <kexit+0x38>
  begin_op();
    80002166:	43f010ef          	jal	80003da4 <begin_op>
  iput(p->cwd);
    8000216a:	1509b503          	ld	a0,336(s3)
    8000216e:	340010ef          	jal	800034ae <iput>
  end_op();
    80002172:	4bf010ef          	jal	80003e30 <end_op>
  p->cwd = 0;
    80002176:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000217a:	00010517          	auipc	a0,0x10
    8000217e:	39650513          	addi	a0,a0,918 # 80012510 <wait_lock>
    80002182:	aa7fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    80002186:	854e                	mv	a0,s3
    80002188:	f3dff0ef          	jal	800020c4 <reparent>
  wakeup(p->parent);
    8000218c:	0389b503          	ld	a0,56(s3)
    80002190:	ecfff0ef          	jal	8000205e <wakeup>
  acquire(&p->lock);
    80002194:	854e                	mv	a0,s3
    80002196:	a93fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    8000219a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000219e:	4795                	li	a5,5
    800021a0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800021a4:	00010517          	auipc	a0,0x10
    800021a8:	36c50513          	addi	a0,a0,876 # 80012510 <wait_lock>
    800021ac:	b05fe0ef          	jal	80000cb0 <release>
  sched();
    800021b0:	d5bff0ef          	jal	80001f0a <sched>
  panic("zombie exit");
    800021b4:	00005517          	auipc	a0,0x5
    800021b8:	0d450513          	addi	a0,a0,212 # 80007288 <etext+0x288>
    800021bc:	e78fe0ef          	jal	80000834 <panic>

00000000800021c0 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    800021c0:	c525                	beqz	a0,80002228 <kkill+0x68>
{
    800021c2:	7179                	addi	sp,sp,-48
    800021c4:	f406                	sd	ra,40(sp)
    800021c6:	f022                	sd	s0,32(sp)
    800021c8:	ec26                	sd	s1,24(sp)
    800021ca:	e84a                	sd	s2,16(sp)
    800021cc:	e44e                	sd	s3,8(sp)
    800021ce:	1800                	addi	s0,sp,48
    800021d0:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    800021d2:	00010497          	auipc	s1,0x10
    800021d6:	75648493          	addi	s1,s1,1878 # 80012928 <proc>
    800021da:	00016997          	auipc	s3,0x16
    800021de:	14e98993          	addi	s3,s3,334 # 80018328 <tickslock>
    acquire(&p->lock);
    800021e2:	8526                	mv	a0,s1
    800021e4:	a45fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    800021e8:	589c                	lw	a5,48(s1)
    800021ea:	01278b63          	beq	a5,s2,80002200 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800021ee:	8526                	mv	a0,s1
    800021f0:	ac1fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800021f4:	16848493          	addi	s1,s1,360
    800021f8:	ff3495e3          	bne	s1,s3,800021e2 <kkill+0x22>
  }
  return -1;
    800021fc:	557d                	li	a0,-1
    800021fe:	a819                	j	80002214 <kkill+0x54>
      p->killed = 1;
    80002200:	4785                	li	a5,1
    80002202:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002204:	4c98                	lw	a4,24(s1)
    80002206:	4789                	li	a5,2
    80002208:	00f70d63          	beq	a4,a5,80002222 <kkill+0x62>
      release(&p->lock);
    8000220c:	8526                	mv	a0,s1
    8000220e:	aa3fe0ef          	jal	80000cb0 <release>
      return 0;
    80002212:	4501                	li	a0,0
}
    80002214:	70a2                	ld	ra,40(sp)
    80002216:	7402                	ld	s0,32(sp)
    80002218:	64e2                	ld	s1,24(sp)
    8000221a:	6942                	ld	s2,16(sp)
    8000221c:	69a2                	ld	s3,8(sp)
    8000221e:	6145                	addi	sp,sp,48
    80002220:	8082                	ret
        p->state = RUNNABLE;
    80002222:	478d                	li	a5,3
    80002224:	cc9c                	sw	a5,24(s1)
    80002226:	b7dd                	j	8000220c <kkill+0x4c>
    return -1;
    80002228:	557d                	li	a0,-1
}
    8000222a:	8082                	ret

000000008000222c <setkilled>:

void
setkilled(struct proc *p)
{
    8000222c:	1101                	addi	sp,sp,-32
    8000222e:	ec06                	sd	ra,24(sp)
    80002230:	e822                	sd	s0,16(sp)
    80002232:	e426                	sd	s1,8(sp)
    80002234:	1000                	addi	s0,sp,32
    80002236:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002238:	9f1fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    8000223c:	4785                	li	a5,1
    8000223e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002240:	8526                	mv	a0,s1
    80002242:	a6ffe0ef          	jal	80000cb0 <release>
}
    80002246:	60e2                	ld	ra,24(sp)
    80002248:	6442                	ld	s0,16(sp)
    8000224a:	64a2                	ld	s1,8(sp)
    8000224c:	6105                	addi	sp,sp,32
    8000224e:	8082                	ret

0000000080002250 <killed>:

int
killed(struct proc *p)
{
    80002250:	1101                	addi	sp,sp,-32
    80002252:	ec06                	sd	ra,24(sp)
    80002254:	e822                	sd	s0,16(sp)
    80002256:	e426                	sd	s1,8(sp)
    80002258:	e04a                	sd	s2,0(sp)
    8000225a:	1000                	addi	s0,sp,32
    8000225c:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000225e:	9cbfe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80002262:	549c                	lw	a5,40(s1)
    80002264:	893e                	mv	s2,a5
  release(&p->lock);
    80002266:	8526                	mv	a0,s1
    80002268:	a49fe0ef          	jal	80000cb0 <release>
  return k;
}
    8000226c:	854a                	mv	a0,s2
    8000226e:	60e2                	ld	ra,24(sp)
    80002270:	6442                	ld	s0,16(sp)
    80002272:	64a2                	ld	s1,8(sp)
    80002274:	6902                	ld	s2,0(sp)
    80002276:	6105                	addi	sp,sp,32
    80002278:	8082                	ret

000000008000227a <kwait>:
{
    8000227a:	715d                	addi	sp,sp,-80
    8000227c:	e486                	sd	ra,72(sp)
    8000227e:	e0a2                	sd	s0,64(sp)
    80002280:	fc26                	sd	s1,56(sp)
    80002282:	f84a                	sd	s2,48(sp)
    80002284:	f44e                	sd	s3,40(sp)
    80002286:	f052                	sd	s4,32(sp)
    80002288:	ec56                	sd	s5,24(sp)
    8000228a:	e85a                	sd	s6,16(sp)
    8000228c:	e45e                	sd	s7,8(sp)
    8000228e:	0880                	addi	s0,sp,80
    80002290:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002292:	f56ff0ef          	jal	800019e8 <myproc>
    80002296:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002298:	00010517          	auipc	a0,0x10
    8000229c:	27850513          	addi	a0,a0,632 # 80012510 <wait_lock>
    800022a0:	989fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800022a4:	4a15                	li	s4,5
        havekids = 1;
    800022a6:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022a8:	00016997          	auipc	s3,0x16
    800022ac:	08098993          	addi	s3,s3,128 # 80018328 <tickslock>
    release(&wait_lock);
    800022b0:	00010b17          	auipc	s6,0x10
    800022b4:	260b0b13          	addi	s6,s6,608 # 80012510 <wait_lock>
    800022b8:	a845                	j	80002368 <kwait+0xee>
          pid = pp->pid;
    800022ba:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    800022be:	000b8e63          	beqz	s7,800022da <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    800022c2:	4711                	li	a4,4
    800022c4:	02c48693          	addi	a3,s1,44
    800022c8:	865e                	mv	a2,s7
    800022ca:	04893583          	ld	a1,72(s2)
    800022ce:	05093503          	ld	a0,80(s2)
    800022d2:	ab0ff0ef          	jal	80001582 <copyout>
          if (addr != 0 &&
    800022d6:	02054c63          	bltz	a0,8000230e <kwait+0x94>
          pp->parent = 0;
    800022da:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    800022de:	8526                	mv	a0,s1
    800022e0:	8d9ff0ef          	jal	80001bb8 <freeproc>
          release(&pp->lock);
    800022e4:	8526                	mv	a0,s1
    800022e6:	9cbfe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    800022ea:	00010517          	auipc	a0,0x10
    800022ee:	22650513          	addi	a0,a0,550 # 80012510 <wait_lock>
    800022f2:	9bffe0ef          	jal	80000cb0 <release>
}
    800022f6:	854e                	mv	a0,s3
    800022f8:	60a6                	ld	ra,72(sp)
    800022fa:	6406                	ld	s0,64(sp)
    800022fc:	74e2                	ld	s1,56(sp)
    800022fe:	7942                	ld	s2,48(sp)
    80002300:	79a2                	ld	s3,40(sp)
    80002302:	7a02                	ld	s4,32(sp)
    80002304:	6ae2                	ld	s5,24(sp)
    80002306:	6b42                	ld	s6,16(sp)
    80002308:	6ba2                	ld	s7,8(sp)
    8000230a:	6161                	addi	sp,sp,80
    8000230c:	8082                	ret
            release(&pp->lock);
    8000230e:	8526                	mv	a0,s1
    80002310:	9a1fe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    80002314:	00010517          	auipc	a0,0x10
    80002318:	1fc50513          	addi	a0,a0,508 # 80012510 <wait_lock>
    8000231c:	995fe0ef          	jal	80000cb0 <release>
            return -1;
    80002320:	59fd                	li	s3,-1
    80002322:	bfd1                	j	800022f6 <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002324:	16848493          	addi	s1,s1,360
    80002328:	03348063          	beq	s1,s3,80002348 <kwait+0xce>
      if (pp->parent == p) {
    8000232c:	7c9c                	ld	a5,56(s1)
    8000232e:	ff279be3          	bne	a5,s2,80002324 <kwait+0xaa>
        acquire(&pp->lock);
    80002332:	8526                	mv	a0,s1
    80002334:	8f5fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002338:	4c9c                	lw	a5,24(s1)
    8000233a:	f94780e3          	beq	a5,s4,800022ba <kwait+0x40>
        release(&pp->lock);
    8000233e:	8526                	mv	a0,s1
    80002340:	971fe0ef          	jal	80000cb0 <release>
        havekids = 1;
    80002344:	8756                	mv	a4,s5
    80002346:	bff9                	j	80002324 <kwait+0xaa>
    if (!havekids || killed(p)) {
    80002348:	c715                	beqz	a4,80002374 <kwait+0xfa>
    8000234a:	854a                	mv	a0,s2
    8000234c:	f05ff0ef          	jal	80002250 <killed>
    80002350:	e115                	bnez	a0,80002374 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    80002352:	854a                	mv	a0,s2
    80002354:	c9fff0ef          	jal	80001ff2 <sleep_prepare>
    release(&wait_lock);
    80002358:	855a                	mv	a0,s6
    8000235a:	957fe0ef          	jal	80000cb0 <release>
    sleep();
    8000235e:	cd1ff0ef          	jal	8000202e <sleep>
    acquire(&wait_lock);
    80002362:	855a                	mv	a0,s6
    80002364:	8c5fe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    80002368:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000236a:	00010497          	auipc	s1,0x10
    8000236e:	5be48493          	addi	s1,s1,1470 # 80012928 <proc>
    80002372:	bf6d                	j	8000232c <kwait+0xb2>
      release(&wait_lock);
    80002374:	00010517          	auipc	a0,0x10
    80002378:	19c50513          	addi	a0,a0,412 # 80012510 <wait_lock>
    8000237c:	935fe0ef          	jal	80000cb0 <release>
      return -1;
    80002380:	59fd                	li	s3,-1
    80002382:	bf95                	j	800022f6 <kwait+0x7c>

0000000080002384 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002384:	7179                	addi	sp,sp,-48
    80002386:	f406                	sd	ra,40(sp)
    80002388:	f022                	sd	s0,32(sp)
    8000238a:	ec26                	sd	s1,24(sp)
    8000238c:	e84a                	sd	s2,16(sp)
    8000238e:	e44e                	sd	s3,8(sp)
    80002390:	e052                	sd	s4,0(sp)
    80002392:	1800                	addi	s0,sp,48
    80002394:	84aa                	mv	s1,a0
    80002396:	8a2e                	mv	s4,a1
    80002398:	89b2                	mv	s3,a2
    8000239a:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000239c:	e4cff0ef          	jal	800019e8 <myproc>
  if (user_dst) {
    800023a0:	c085                	beqz	s1,800023c0 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    800023a2:	874a                	mv	a4,s2
    800023a4:	86ce                	mv	a3,s3
    800023a6:	8652                	mv	a2,s4
    800023a8:	652c                	ld	a1,72(a0)
    800023aa:	6928                	ld	a0,80(a0)
    800023ac:	9d6ff0ef          	jal	80001582 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800023b0:	70a2                	ld	ra,40(sp)
    800023b2:	7402                	ld	s0,32(sp)
    800023b4:	64e2                	ld	s1,24(sp)
    800023b6:	6942                	ld	s2,16(sp)
    800023b8:	69a2                	ld	s3,8(sp)
    800023ba:	6a02                	ld	s4,0(sp)
    800023bc:	6145                	addi	sp,sp,48
    800023be:	8082                	ret
    memmove((char *)dst, src, len);
    800023c0:	0009061b          	sext.w	a2,s2
    800023c4:	85ce                	mv	a1,s3
    800023c6:	8552                	mv	a0,s4
    800023c8:	981fe0ef          	jal	80000d48 <memmove>
    return 0;
    800023cc:	8526                	mv	a0,s1
    800023ce:	b7cd                	j	800023b0 <either_copyout+0x2c>

00000000800023d0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800023d0:	7179                	addi	sp,sp,-48
    800023d2:	f406                	sd	ra,40(sp)
    800023d4:	f022                	sd	s0,32(sp)
    800023d6:	ec26                	sd	s1,24(sp)
    800023d8:	e84a                	sd	s2,16(sp)
    800023da:	e44e                	sd	s3,8(sp)
    800023dc:	e052                	sd	s4,0(sp)
    800023de:	1800                	addi	s0,sp,48
    800023e0:	8a2a                	mv	s4,a0
    800023e2:	84ae                	mv	s1,a1
    800023e4:	89b2                	mv	s3,a2
    800023e6:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800023e8:	e00ff0ef          	jal	800019e8 <myproc>
  if (user_src) {
    800023ec:	c085                	beqz	s1,8000240c <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    800023ee:	874a                	mv	a4,s2
    800023f0:	86ce                	mv	a3,s3
    800023f2:	8652                	mv	a2,s4
    800023f4:	652c                	ld	a1,72(a0)
    800023f6:	6928                	ld	a0,80(a0)
    800023f8:	a50ff0ef          	jal	80001648 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800023fc:	70a2                	ld	ra,40(sp)
    800023fe:	7402                	ld	s0,32(sp)
    80002400:	64e2                	ld	s1,24(sp)
    80002402:	6942                	ld	s2,16(sp)
    80002404:	69a2                	ld	s3,8(sp)
    80002406:	6a02                	ld	s4,0(sp)
    80002408:	6145                	addi	sp,sp,48
    8000240a:	8082                	ret
    memmove(dst, (char *)src, len);
    8000240c:	0009061b          	sext.w	a2,s2
    80002410:	85ce                	mv	a1,s3
    80002412:	8552                	mv	a0,s4
    80002414:	935fe0ef          	jal	80000d48 <memmove>
    return 0;
    80002418:	8526                	mv	a0,s1
    8000241a:	b7cd                	j	800023fc <either_copyin+0x2c>

000000008000241c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000241c:	715d                	addi	sp,sp,-80
    8000241e:	e486                	sd	ra,72(sp)
    80002420:	e0a2                	sd	s0,64(sp)
    80002422:	fc26                	sd	s1,56(sp)
    80002424:	f84a                	sd	s2,48(sp)
    80002426:	f44e                	sd	s3,40(sp)
    80002428:	f052                	sd	s4,32(sp)
    8000242a:	ec56                	sd	s5,24(sp)
    8000242c:	e85a                	sd	s6,16(sp)
    8000242e:	e45e                	sd	s7,8(sp)
    80002430:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002432:	00005517          	auipc	a0,0x5
    80002436:	c4650513          	addi	a0,a0,-954 # 80007078 <etext+0x78>
    8000243a:	8d0fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000243e:	00010497          	auipc	s1,0x10
    80002442:	64248493          	addi	s1,s1,1602 # 80012a80 <proc+0x158>
    80002446:	00016917          	auipc	s2,0x16
    8000244a:	03a90913          	addi	s2,s2,58 # 80018480 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000244e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002450:	00005997          	auipc	s3,0x5
    80002454:	e4898993          	addi	s3,s3,-440 # 80007298 <etext+0x298>
    printk("%d %s %s", p->pid, state, p->name);
    80002458:	00005a97          	auipc	s5,0x5
    8000245c:	e48a8a93          	addi	s5,s5,-440 # 800072a0 <etext+0x2a0>
    printk("\n");
    80002460:	00005a17          	auipc	s4,0x5
    80002464:	c18a0a13          	addi	s4,s4,-1000 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002468:	00005b97          	auipc	s7,0x5
    8000246c:	358b8b93          	addi	s7,s7,856 # 800077c0 <states.0>
    80002470:	a829                	j	8000248a <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002472:	ed86a583          	lw	a1,-296(a3)
    80002476:	8556                	mv	a0,s5
    80002478:	892fe0ef          	jal	8000050a <printk>
    printk("\n");
    8000247c:	8552                	mv	a0,s4
    8000247e:	88cfe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002482:	16848493          	addi	s1,s1,360
    80002486:	03248263          	beq	s1,s2,800024aa <procdump+0x8e>
    if (p->state == UNUSED)
    8000248a:	86a6                	mv	a3,s1
    8000248c:	ec04a783          	lw	a5,-320(s1)
    80002490:	dbed                	beqz	a5,80002482 <procdump+0x66>
      state = "???";
    80002492:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002494:	fcfb6fe3          	bltu	s6,a5,80002472 <procdump+0x56>
    80002498:	02079713          	slli	a4,a5,0x20
    8000249c:	01d75793          	srli	a5,a4,0x1d
    800024a0:	97de                	add	a5,a5,s7
    800024a2:	6390                	ld	a2,0(a5)
    800024a4:	f679                	bnez	a2,80002472 <procdump+0x56>
      state = "???";
    800024a6:	864e                	mv	a2,s3
    800024a8:	b7e9                	j	80002472 <procdump+0x56>
  }
}
    800024aa:	60a6                	ld	ra,72(sp)
    800024ac:	6406                	ld	s0,64(sp)
    800024ae:	74e2                	ld	s1,56(sp)
    800024b0:	7942                	ld	s2,48(sp)
    800024b2:	79a2                	ld	s3,40(sp)
    800024b4:	7a02                	ld	s4,32(sp)
    800024b6:	6ae2                	ld	s5,24(sp)
    800024b8:	6b42                	ld	s6,16(sp)
    800024ba:	6ba2                	ld	s7,8(sp)
    800024bc:	6161                	addi	sp,sp,80
    800024be:	8082                	ret

00000000800024c0 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800024c0:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800024c4:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800024c8:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800024ca:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800024cc:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800024d0:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800024d4:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800024d8:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800024dc:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800024e0:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800024e4:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800024e8:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800024ec:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800024f0:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800024f4:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800024f8:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800024fc:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800024fe:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002500:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002504:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002508:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000250c:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002510:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002514:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002518:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000251c:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002520:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002524:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002528:	8082                	ret

000000008000252a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000252a:	1141                	addi	sp,sp,-16
    8000252c:	e406                	sd	ra,8(sp)
    8000252e:	e022                	sd	s0,0(sp)
    80002530:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002532:	00005597          	auipc	a1,0x5
    80002536:	dae58593          	addi	a1,a1,-594 # 800072e0 <etext+0x2e0>
    8000253a:	00016517          	auipc	a0,0x16
    8000253e:	dee50513          	addi	a0,a0,-530 # 80018328 <tickslock>
    80002542:	e66fe0ef          	jal	80000ba8 <initlock>
}
    80002546:	60a2                	ld	ra,8(sp)
    80002548:	6402                	ld	s0,0(sp)
    8000254a:	0141                	addi	sp,sp,16
    8000254c:	8082                	ret

000000008000254e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000254e:	1141                	addi	sp,sp,-16
    80002550:	e406                	sd	ra,8(sp)
    80002552:	e022                	sd	s0,0(sp)
    80002554:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002556:	00003797          	auipc	a5,0x3
    8000255a:	19a78793          	addi	a5,a5,410 # 800056f0 <kernelvec>
    8000255e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002562:	60a2                	ld	ra,8(sp)
    80002564:	6402                	ld	s0,0(sp)
    80002566:	0141                	addi	sp,sp,16
    80002568:	8082                	ret

000000008000256a <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000256a:	1141                	addi	sp,sp,-16
    8000256c:	e406                	sd	ra,8(sp)
    8000256e:	e022                	sd	s0,0(sp)
    80002570:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002572:	c76ff0ef          	jal	800019e8 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002576:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000257a:	04000737          	lui	a4,0x4000
    8000257e:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002580:	0732                	slli	a4,a4,0xc
    80002582:	00004797          	auipc	a5,0x4
    80002586:	a7e78793          	addi	a5,a5,-1410 # 80006000 <_trampoline>
    8000258a:	00004697          	auipc	a3,0x4
    8000258e:	a7668693          	addi	a3,a3,-1418 # 80006000 <_trampoline>
    80002592:	8f95                	sub	a5,a5,a3
    80002594:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002596:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000259a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    8000259c:	18002773          	csrr	a4,satp
    800025a0:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800025a2:	6d38                	ld	a4,88(a0)
    800025a4:	613c                	ld	a5,64(a0)
    800025a6:	6685                	lui	a3,0x1
    800025a8:	97b6                	add	a5,a5,a3
    800025aa:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800025ac:	6d3c                	ld	a5,88(a0)
    800025ae:	00000717          	auipc	a4,0x0
    800025b2:	0fc70713          	addi	a4,a4,252 # 800026aa <usertrap>
    800025b6:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800025b8:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    800025ba:	8712                	mv	a4,tp
    800025bc:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800025be:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800025c2:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800025c6:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800025ca:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800025ce:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800025d0:	6f9c                	ld	a5,24(a5)
    800025d2:	14179073          	csrw	sepc,a5
}
    800025d6:	60a2                	ld	ra,8(sp)
    800025d8:	6402                	ld	s0,0(sp)
    800025da:	0141                	addi	sp,sp,16
    800025dc:	8082                	ret

00000000800025de <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800025de:	1141                	addi	sp,sp,-16
    800025e0:	e406                	sd	ra,8(sp)
    800025e2:	e022                	sd	s0,0(sp)
    800025e4:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    800025e6:	bceff0ef          	jal	800019b4 <cpuid>
    800025ea:	cd11                	beqz	a0,80002606 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800025ec:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800025f0:	000f4737          	lui	a4,0xf4
    800025f4:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800025f8:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    800025fa:	14d79073          	csrw	stimecmp,a5
}
    800025fe:	60a2                	ld	ra,8(sp)
    80002600:	6402                	ld	s0,0(sp)
    80002602:	0141                	addi	sp,sp,16
    80002604:	8082                	ret
    acquire(&tickslock);
    80002606:	00016517          	auipc	a0,0x16
    8000260a:	d2250513          	addi	a0,a0,-734 # 80018328 <tickslock>
    8000260e:	e1afe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002612:	00008717          	auipc	a4,0x8
    80002616:	de670713          	addi	a4,a4,-538 # 8000a3f8 <ticks>
    8000261a:	431c                	lw	a5,0(a4)
    8000261c:	2785                	addiw	a5,a5,1
    8000261e:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002620:	853a                	mv	a0,a4
    80002622:	a3dff0ef          	jal	8000205e <wakeup>
    release(&tickslock);
    80002626:	00016517          	auipc	a0,0x16
    8000262a:	d0250513          	addi	a0,a0,-766 # 80018328 <tickslock>
    8000262e:	e82fe0ef          	jal	80000cb0 <release>
    80002632:	bf6d                	j	800025ec <clockintr+0xe>

0000000080002634 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002634:	1101                	addi	sp,sp,-32
    80002636:	ec06                	sd	ra,24(sp)
    80002638:	e822                	sd	s0,16(sp)
    8000263a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    8000263c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002640:	57fd                	li	a5,-1
    80002642:	17fe                	slli	a5,a5,0x3f
    80002644:	07a5                	addi	a5,a5,9
    80002646:	00f70c63          	beq	a4,a5,8000265e <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    8000264a:	57fd                	li	a5,-1
    8000264c:	17fe                	slli	a5,a5,0x3f
    8000264e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002650:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002652:	04f70863          	beq	a4,a5,800026a2 <devintr+0x6e>
  }
}
    80002656:	60e2                	ld	ra,24(sp)
    80002658:	6442                	ld	s0,16(sp)
    8000265a:	6105                	addi	sp,sp,32
    8000265c:	8082                	ret
    8000265e:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002660:	13e030ef          	jal	8000579e <plic_claim>
    80002664:	872a                	mv	a4,a0
    80002666:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002668:	47a9                	li	a5,10
    8000266a:	00f50963          	beq	a0,a5,8000267c <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    8000266e:	4785                	li	a5,1
    80002670:	00f50963          	beq	a0,a5,80002682 <devintr+0x4e>
    return 1;
    80002674:	4505                	li	a0,1
    } else if (irq) {
    80002676:	eb09                	bnez	a4,80002688 <devintr+0x54>
    80002678:	64a2                	ld	s1,8(sp)
    8000267a:	bff1                	j	80002656 <devintr+0x22>
      uartintr();
    8000267c:	b72fe0ef          	jal	800009ee <uartintr>
    if (irq)
    80002680:	a819                	j	80002696 <devintr+0x62>
      virtio_disk_intr();
    80002682:	5d8030ef          	jal	80005c5a <virtio_disk_intr>
    if (irq)
    80002686:	a801                	j	80002696 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    80002688:	85ba                	mv	a1,a4
    8000268a:	00005517          	auipc	a0,0x5
    8000268e:	c5e50513          	addi	a0,a0,-930 # 800072e8 <etext+0x2e8>
    80002692:	e79fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    80002696:	8526                	mv	a0,s1
    80002698:	128030ef          	jal	800057c0 <plic_complete>
    return 1;
    8000269c:	4505                	li	a0,1
    8000269e:	64a2                	ld	s1,8(sp)
    800026a0:	bf5d                	j	80002656 <devintr+0x22>
    clockintr();
    800026a2:	f3dff0ef          	jal	800025de <clockintr>
    return 2;
    800026a6:	4509                	li	a0,2
    800026a8:	b77d                	j	80002656 <devintr+0x22>

00000000800026aa <usertrap>:
{
    800026aa:	1101                	addi	sp,sp,-32
    800026ac:	ec06                	sd	ra,24(sp)
    800026ae:	e822                	sd	s0,16(sp)
    800026b0:	e426                	sd	s1,8(sp)
    800026b2:	e04a                	sd	s2,0(sp)
    800026b4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026b6:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800026ba:	1007f793          	andi	a5,a5,256
    800026be:	eba5                	bnez	a5,8000272e <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800026c0:	00003797          	auipc	a5,0x3
    800026c4:	03078793          	addi	a5,a5,48 # 800056f0 <kernelvec>
    800026c8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800026cc:	b1cff0ef          	jal	800019e8 <myproc>
    800026d0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800026d2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026d4:	14102773          	csrr	a4,sepc
    800026d8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800026da:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800026de:	47a1                	li	a5,8
    800026e0:	04f70d63          	beq	a4,a5,8000273a <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    800026e4:	f51ff0ef          	jal	80002634 <devintr>
    800026e8:	892a                	mv	s2,a0
    800026ea:	e54d                	bnez	a0,80002794 <usertrap+0xea>
    800026ec:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800026f0:	47bd                	li	a5,15
    800026f2:	08f70463          	beq	a4,a5,8000277a <usertrap+0xd0>
    800026f6:	14202773          	csrr	a4,scause
    800026fa:	47b5                	li	a5,13
    800026fc:	06f70f63          	beq	a4,a5,8000277a <usertrap+0xd0>
    80002700:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002704:	5890                	lw	a2,48(s1)
    80002706:	00005517          	auipc	a0,0x5
    8000270a:	c2250513          	addi	a0,a0,-990 # 80007328 <etext+0x328>
    8000270e:	dfdfd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002712:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002716:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000271a:	00005517          	auipc	a0,0x5
    8000271e:	c3e50513          	addi	a0,a0,-962 # 80007358 <etext+0x358>
    80002722:	de9fd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002726:	8526                	mv	a0,s1
    80002728:	b05ff0ef          	jal	8000222c <setkilled>
    8000272c:	a015                	j	80002750 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    8000272e:	00005517          	auipc	a0,0x5
    80002732:	bda50513          	addi	a0,a0,-1062 # 80007308 <etext+0x308>
    80002736:	8fefe0ef          	jal	80000834 <panic>
    if (killed(p))
    8000273a:	b17ff0ef          	jal	80002250 <killed>
    8000273e:	e915                	bnez	a0,80002772 <usertrap+0xc8>
    p->trapframe->epc += 4;
    80002740:	6cb8                	ld	a4,88(s1)
    80002742:	6f1c                	ld	a5,24(a4)
    80002744:	0791                	addi	a5,a5,4
    80002746:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002748:	10016073          	csrsi	sstatus,2
    syscall();
    8000274c:	244000ef          	jal	80002990 <syscall>
  if (killed(p))
    80002750:	8526                	mv	a0,s1
    80002752:	affff0ef          	jal	80002250 <killed>
    80002756:	e521                	bnez	a0,8000279e <usertrap+0xf4>
  prepare_return();
    80002758:	e13ff0ef          	jal	8000256a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000275c:	68a8                	ld	a0,80(s1)
    8000275e:	8131                	srli	a0,a0,0xc
    80002760:	57fd                	li	a5,-1
    80002762:	17fe                	slli	a5,a5,0x3f
    80002764:	8d5d                	or	a0,a0,a5
}
    80002766:	60e2                	ld	ra,24(sp)
    80002768:	6442                	ld	s0,16(sp)
    8000276a:	64a2                	ld	s1,8(sp)
    8000276c:	6902                	ld	s2,0(sp)
    8000276e:	6105                	addi	sp,sp,32
    80002770:	8082                	ret
      kexit(-1);
    80002772:	557d                	li	a0,-1
    80002774:	9a7ff0ef          	jal	8000211a <kexit>
    80002778:	b7e1                	j	80002740 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    8000277a:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    8000277e:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002782:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    80002784:	0016b693          	seqz	a3,a3
    80002788:	64ac                	ld	a1,72(s1)
    8000278a:	68a8                	ld	a0,80(s1)
    8000278c:	d7bfe0ef          	jal	80001506 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002790:	f161                	bnez	a0,80002750 <usertrap+0xa6>
    80002792:	b7bd                	j	80002700 <usertrap+0x56>
  if (killed(p))
    80002794:	8526                	mv	a0,s1
    80002796:	abbff0ef          	jal	80002250 <killed>
    8000279a:	c511                	beqz	a0,800027a6 <usertrap+0xfc>
    8000279c:	a011                	j	800027a0 <usertrap+0xf6>
    8000279e:	4901                	li	s2,0
    kexit(-1);
    800027a0:	557d                	li	a0,-1
    800027a2:	979ff0ef          	jal	8000211a <kexit>
  if (which_dev == 2)
    800027a6:	4789                	li	a5,2
    800027a8:	faf918e3          	bne	s2,a5,80002758 <usertrap+0xae>
    yield();
    800027ac:	81bff0ef          	jal	80001fc6 <yield>
    800027b0:	b765                	j	80002758 <usertrap+0xae>

00000000800027b2 <kerneltrap>:
{
    800027b2:	7179                	addi	sp,sp,-48
    800027b4:	f406                	sd	ra,40(sp)
    800027b6:	f022                	sd	s0,32(sp)
    800027b8:	ec26                	sd	s1,24(sp)
    800027ba:	e84a                	sd	s2,16(sp)
    800027bc:	e44e                	sd	s3,8(sp)
    800027be:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027c0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027c4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800027c8:	142027f3          	csrr	a5,scause
    800027cc:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    800027ce:	1004f793          	andi	a5,s1,256
    800027d2:	c795                	beqz	a5,800027fe <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027d4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800027d8:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800027da:	eb85                	bnez	a5,8000280a <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    800027dc:	e59ff0ef          	jal	80002634 <devintr>
    800027e0:	c91d                	beqz	a0,80002816 <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    800027e2:	4789                	li	a5,2
    800027e4:	04f50a63          	beq	a0,a5,80002838 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    800027e8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800027ec:	10049073          	csrw	sstatus,s1
}
    800027f0:	70a2                	ld	ra,40(sp)
    800027f2:	7402                	ld	s0,32(sp)
    800027f4:	64e2                	ld	s1,24(sp)
    800027f6:	6942                	ld	s2,16(sp)
    800027f8:	69a2                	ld	s3,8(sp)
    800027fa:	6145                	addi	sp,sp,48
    800027fc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800027fe:	00005517          	auipc	a0,0x5
    80002802:	b8250513          	addi	a0,a0,-1150 # 80007380 <etext+0x380>
    80002806:	82efe0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    8000280a:	00005517          	auipc	a0,0x5
    8000280e:	b9e50513          	addi	a0,a0,-1122 # 800073a8 <etext+0x3a8>
    80002812:	822fe0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002816:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000281a:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    8000281e:	85ce                	mv	a1,s3
    80002820:	00005517          	auipc	a0,0x5
    80002824:	ba850513          	addi	a0,a0,-1112 # 800073c8 <etext+0x3c8>
    80002828:	ce3fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    8000282c:	00005517          	auipc	a0,0x5
    80002830:	bc450513          	addi	a0,a0,-1084 # 800073f0 <etext+0x3f0>
    80002834:	800fe0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    80002838:	9b0ff0ef          	jal	800019e8 <myproc>
    8000283c:	d555                	beqz	a0,800027e8 <kerneltrap+0x36>
    yield();
    8000283e:	f88ff0ef          	jal	80001fc6 <yield>
    80002842:	b75d                	j	800027e8 <kerneltrap+0x36>

0000000080002844 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002844:	1101                	addi	sp,sp,-32
    80002846:	ec06                	sd	ra,24(sp)
    80002848:	e822                	sd	s0,16(sp)
    8000284a:	e426                	sd	s1,8(sp)
    8000284c:	1000                	addi	s0,sp,32
    8000284e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002850:	998ff0ef          	jal	800019e8 <myproc>
  switch (n) {
    80002854:	4795                	li	a5,5
    80002856:	0497e163          	bltu	a5,s1,80002898 <argraw+0x54>
    8000285a:	048a                	slli	s1,s1,0x2
    8000285c:	00005717          	auipc	a4,0x5
    80002860:	f9470713          	addi	a4,a4,-108 # 800077f0 <states.0+0x30>
    80002864:	94ba                	add	s1,s1,a4
    80002866:	409c                	lw	a5,0(s1)
    80002868:	97ba                	add	a5,a5,a4
    8000286a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000286c:	6d3c                	ld	a5,88(a0)
    8000286e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002870:	60e2                	ld	ra,24(sp)
    80002872:	6442                	ld	s0,16(sp)
    80002874:	64a2                	ld	s1,8(sp)
    80002876:	6105                	addi	sp,sp,32
    80002878:	8082                	ret
    return p->trapframe->a1;
    8000287a:	6d3c                	ld	a5,88(a0)
    8000287c:	7fa8                	ld	a0,120(a5)
    8000287e:	bfcd                	j	80002870 <argraw+0x2c>
    return p->trapframe->a2;
    80002880:	6d3c                	ld	a5,88(a0)
    80002882:	63c8                	ld	a0,128(a5)
    80002884:	b7f5                	j	80002870 <argraw+0x2c>
    return p->trapframe->a3;
    80002886:	6d3c                	ld	a5,88(a0)
    80002888:	67c8                	ld	a0,136(a5)
    8000288a:	b7dd                	j	80002870 <argraw+0x2c>
    return p->trapframe->a4;
    8000288c:	6d3c                	ld	a5,88(a0)
    8000288e:	6bc8                	ld	a0,144(a5)
    80002890:	b7c5                	j	80002870 <argraw+0x2c>
    return p->trapframe->a5;
    80002892:	6d3c                	ld	a5,88(a0)
    80002894:	6fc8                	ld	a0,152(a5)
    80002896:	bfe9                	j	80002870 <argraw+0x2c>
  panic("argraw");
    80002898:	00005517          	auipc	a0,0x5
    8000289c:	b6850513          	addi	a0,a0,-1176 # 80007400 <etext+0x400>
    800028a0:	f95fd0ef          	jal	80000834 <panic>

00000000800028a4 <fetchaddr>:
{
    800028a4:	1101                	addi	sp,sp,-32
    800028a6:	ec06                	sd	ra,24(sp)
    800028a8:	e822                	sd	s0,16(sp)
    800028aa:	e426                	sd	s1,8(sp)
    800028ac:	e04a                	sd	s2,0(sp)
    800028ae:	1000                	addi	s0,sp,32
    800028b0:	84aa                	mv	s1,a0
    800028b2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800028b4:	934ff0ef          	jal	800019e8 <myproc>
  if (addr >= p->sz ||
    800028b8:	652c                	ld	a1,72(a0)
    800028ba:	02b4f663          	bgeu	s1,a1,800028e6 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800028be:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    800028c2:	02f5e463          	bltu	a1,a5,800028ea <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    800028c6:	4721                	li	a4,8
    800028c8:	86a6                	mv	a3,s1
    800028ca:	864a                	mv	a2,s2
    800028cc:	6928                	ld	a0,80(a0)
    800028ce:	d7bfe0ef          	jal	80001648 <copyin>
    800028d2:	00a03533          	snez	a0,a0
    800028d6:	40a0053b          	negw	a0,a0
}
    800028da:	60e2                	ld	ra,24(sp)
    800028dc:	6442                	ld	s0,16(sp)
    800028de:	64a2                	ld	s1,8(sp)
    800028e0:	6902                	ld	s2,0(sp)
    800028e2:	6105                	addi	sp,sp,32
    800028e4:	8082                	ret
    return -1;
    800028e6:	557d                	li	a0,-1
    800028e8:	bfcd                	j	800028da <fetchaddr+0x36>
    800028ea:	557d                	li	a0,-1
    800028ec:	b7fd                	j	800028da <fetchaddr+0x36>

00000000800028ee <fetchstr>:
{
    800028ee:	7179                	addi	sp,sp,-48
    800028f0:	f406                	sd	ra,40(sp)
    800028f2:	f022                	sd	s0,32(sp)
    800028f4:	ec26                	sd	s1,24(sp)
    800028f6:	e84a                	sd	s2,16(sp)
    800028f8:	e44e                	sd	s3,8(sp)
    800028fa:	1800                	addi	s0,sp,48
    800028fc:	89aa                	mv	s3,a0
    800028fe:	84ae                	mv	s1,a1
    80002900:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002902:	8e6ff0ef          	jal	800019e8 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002906:	874a                	mv	a4,s2
    80002908:	86ce                	mv	a3,s3
    8000290a:	8626                	mv	a2,s1
    8000290c:	652c                	ld	a1,72(a0)
    8000290e:	6928                	ld	a0,80(a0)
    80002910:	dd5fe0ef          	jal	800016e4 <copyinstr>
    80002914:	00054c63          	bltz	a0,8000292c <fetchstr+0x3e>
  return strlen(buf);
    80002918:	8526                	mv	a0,s1
    8000291a:	d58fe0ef          	jal	80000e72 <strlen>
}
    8000291e:	70a2                	ld	ra,40(sp)
    80002920:	7402                	ld	s0,32(sp)
    80002922:	64e2                	ld	s1,24(sp)
    80002924:	6942                	ld	s2,16(sp)
    80002926:	69a2                	ld	s3,8(sp)
    80002928:	6145                	addi	sp,sp,48
    8000292a:	8082                	ret
    return -1;
    8000292c:	557d                	li	a0,-1
    8000292e:	bfc5                	j	8000291e <fetchstr+0x30>

0000000080002930 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002930:	1101                	addi	sp,sp,-32
    80002932:	ec06                	sd	ra,24(sp)
    80002934:	e822                	sd	s0,16(sp)
    80002936:	e426                	sd	s1,8(sp)
    80002938:	1000                	addi	s0,sp,32
    8000293a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000293c:	f09ff0ef          	jal	80002844 <argraw>
    80002940:	c088                	sw	a0,0(s1)
}
    80002942:	60e2                	ld	ra,24(sp)
    80002944:	6442                	ld	s0,16(sp)
    80002946:	64a2                	ld	s1,8(sp)
    80002948:	6105                	addi	sp,sp,32
    8000294a:	8082                	ret

000000008000294c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000294c:	1101                	addi	sp,sp,-32
    8000294e:	ec06                	sd	ra,24(sp)
    80002950:	e822                	sd	s0,16(sp)
    80002952:	e426                	sd	s1,8(sp)
    80002954:	1000                	addi	s0,sp,32
    80002956:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002958:	eedff0ef          	jal	80002844 <argraw>
    8000295c:	e088                	sd	a0,0(s1)
}
    8000295e:	60e2                	ld	ra,24(sp)
    80002960:	6442                	ld	s0,16(sp)
    80002962:	64a2                	ld	s1,8(sp)
    80002964:	6105                	addi	sp,sp,32
    80002966:	8082                	ret

0000000080002968 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002968:	1101                	addi	sp,sp,-32
    8000296a:	ec06                	sd	ra,24(sp)
    8000296c:	e822                	sd	s0,16(sp)
    8000296e:	e426                	sd	s1,8(sp)
    80002970:	e04a                	sd	s2,0(sp)
    80002972:	1000                	addi	s0,sp,32
    80002974:	892e                	mv	s2,a1
    80002976:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002978:	ecdff0ef          	jal	80002844 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    8000297c:	8626                	mv	a2,s1
    8000297e:	85ca                	mv	a1,s2
    80002980:	f6fff0ef          	jal	800028ee <fetchstr>
}
    80002984:	60e2                	ld	ra,24(sp)
    80002986:	6442                	ld	s0,16(sp)
    80002988:	64a2                	ld	s1,8(sp)
    8000298a:	6902                	ld	s2,0(sp)
    8000298c:	6105                	addi	sp,sp,32
    8000298e:	8082                	ret

0000000080002990 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002990:	1101                	addi	sp,sp,-32
    80002992:	ec06                	sd	ra,24(sp)
    80002994:	e822                	sd	s0,16(sp)
    80002996:	e426                	sd	s1,8(sp)
    80002998:	e04a                	sd	s2,0(sp)
    8000299a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000299c:	84cff0ef          	jal	800019e8 <myproc>
    800029a0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800029a2:	05853903          	ld	s2,88(a0)
    800029a6:	0a893783          	ld	a5,168(s2)
    800029aa:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800029ae:	37fd                	addiw	a5,a5,-1
    800029b0:	4759                	li	a4,22
    800029b2:	00f76f63          	bltu	a4,a5,800029d0 <syscall+0x40>
    800029b6:	00369713          	slli	a4,a3,0x3
    800029ba:	00005797          	auipc	a5,0x5
    800029be:	e4e78793          	addi	a5,a5,-434 # 80007808 <syscalls>
    800029c2:	97ba                	add	a5,a5,a4
    800029c4:	639c                	ld	a5,0(a5)
    800029c6:	c789                	beqz	a5,800029d0 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800029c8:	9782                	jalr	a5
    800029ca:	06a93823          	sd	a0,112(s2)
    800029ce:	a829                	j	800029e8 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    800029d0:	15848613          	addi	a2,s1,344
    800029d4:	588c                	lw	a1,48(s1)
    800029d6:	00005517          	auipc	a0,0x5
    800029da:	a3250513          	addi	a0,a0,-1486 # 80007408 <etext+0x408>
    800029de:	b2dfd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    800029e2:	6cbc                	ld	a5,88(s1)
    800029e4:	577d                	li	a4,-1
    800029e6:	fbb8                	sd	a4,112(a5)
  }
}
    800029e8:	60e2                	ld	ra,24(sp)
    800029ea:	6442                	ld	s0,16(sp)
    800029ec:	64a2                	ld	s1,8(sp)
    800029ee:	6902                	ld	s2,0(sp)
    800029f0:	6105                	addi	sp,sp,32
    800029f2:	8082                	ret

00000000800029f4 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800029f4:	1101                	addi	sp,sp,-32
    800029f6:	ec06                	sd	ra,24(sp)
    800029f8:	e822                	sd	s0,16(sp)
    800029fa:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800029fc:	fec40593          	addi	a1,s0,-20
    80002a00:	4501                	li	a0,0
    80002a02:	f2fff0ef          	jal	80002930 <argint>
  kexit(n);
    80002a06:	fec42503          	lw	a0,-20(s0)
    80002a0a:	f10ff0ef          	jal	8000211a <kexit>
  return 0; // not reached
}
    80002a0e:	4501                	li	a0,0
    80002a10:	60e2                	ld	ra,24(sp)
    80002a12:	6442                	ld	s0,16(sp)
    80002a14:	6105                	addi	sp,sp,32
    80002a16:	8082                	ret

0000000080002a18 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a18:	1141                	addi	sp,sp,-16
    80002a1a:	e406                	sd	ra,8(sp)
    80002a1c:	e022                	sd	s0,0(sp)
    80002a1e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a20:	fc9fe0ef          	jal	800019e8 <myproc>
}
    80002a24:	5908                	lw	a0,48(a0)
    80002a26:	60a2                	ld	ra,8(sp)
    80002a28:	6402                	ld	s0,0(sp)
    80002a2a:	0141                	addi	sp,sp,16
    80002a2c:	8082                	ret

0000000080002a2e <sys_fork>:

uint64
sys_fork(void)
{
    80002a2e:	1141                	addi	sp,sp,-16
    80002a30:	e406                	sd	ra,8(sp)
    80002a32:	e022                	sd	s0,0(sp)
    80002a34:	0800                	addi	s0,sp,16
  return kfork();
    80002a36:	b12ff0ef          	jal	80001d48 <kfork>
}
    80002a3a:	60a2                	ld	ra,8(sp)
    80002a3c:	6402                	ld	s0,0(sp)
    80002a3e:	0141                	addi	sp,sp,16
    80002a40:	8082                	ret

0000000080002a42 <sys_wait>:

uint64
sys_wait(void)
{
    80002a42:	1101                	addi	sp,sp,-32
    80002a44:	ec06                	sd	ra,24(sp)
    80002a46:	e822                	sd	s0,16(sp)
    80002a48:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a4a:	fe840593          	addi	a1,s0,-24
    80002a4e:	4501                	li	a0,0
    80002a50:	efdff0ef          	jal	8000294c <argaddr>
  return kwait(p);
    80002a54:	fe843503          	ld	a0,-24(s0)
    80002a58:	823ff0ef          	jal	8000227a <kwait>
}
    80002a5c:	60e2                	ld	ra,24(sp)
    80002a5e:	6442                	ld	s0,16(sp)
    80002a60:	6105                	addi	sp,sp,32
    80002a62:	8082                	ret

0000000080002a64 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a64:	7179                	addi	sp,sp,-48
    80002a66:	f406                	sd	ra,40(sp)
    80002a68:	f022                	sd	s0,32(sp)
    80002a6a:	ec26                	sd	s1,24(sp)
    80002a6c:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a6e:	fd840593          	addi	a1,s0,-40
    80002a72:	4501                	li	a0,0
    80002a74:	ebdff0ef          	jal	80002930 <argint>
  argint(1, &t);
    80002a78:	fdc40593          	addi	a1,s0,-36
    80002a7c:	4505                	li	a0,1
    80002a7e:	eb3ff0ef          	jal	80002930 <argint>
  addr = myproc()->sz;
    80002a82:	f67fe0ef          	jal	800019e8 <myproc>
    80002a86:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002a88:	fdc42703          	lw	a4,-36(s0)
    80002a8c:	4785                	li	a5,1
    80002a8e:	02f70763          	beq	a4,a5,80002abc <sys_sbrk+0x58>
    80002a92:	fd842783          	lw	a5,-40(s0)
    80002a96:	0207c363          	bltz	a5,80002abc <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002a9a:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002a9c:	02000737          	lui	a4,0x2000
    80002aa0:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002aa2:	0736                	slli	a4,a4,0xd
    80002aa4:	02f76a63          	bltu	a4,a5,80002ad8 <sys_sbrk+0x74>
    80002aa8:	0297e863          	bltu	a5,s1,80002ad8 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002aac:	f3dfe0ef          	jal	800019e8 <myproc>
    80002ab0:	fd842703          	lw	a4,-40(s0)
    80002ab4:	653c                	ld	a5,72(a0)
    80002ab6:	97ba                	add	a5,a5,a4
    80002ab8:	e53c                	sd	a5,72(a0)
    80002aba:	a039                	j	80002ac8 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002abc:	fd842503          	lw	a0,-40(s0)
    80002ac0:	a26ff0ef          	jal	80001ce6 <growproc>
    80002ac4:	00054863          	bltz	a0,80002ad4 <sys_sbrk+0x70>
  }
  return addr;
}
    80002ac8:	8526                	mv	a0,s1
    80002aca:	70a2                	ld	ra,40(sp)
    80002acc:	7402                	ld	s0,32(sp)
    80002ace:	64e2                	ld	s1,24(sp)
    80002ad0:	6145                	addi	sp,sp,48
    80002ad2:	8082                	ret
      return -1;
    80002ad4:	54fd                	li	s1,-1
    80002ad6:	bfcd                	j	80002ac8 <sys_sbrk+0x64>
      return -1;
    80002ad8:	54fd                	li	s1,-1
    80002ada:	b7fd                	j	80002ac8 <sys_sbrk+0x64>

0000000080002adc <sys_pause>:

uint64
sys_pause(void)
{
    80002adc:	7139                	addi	sp,sp,-64
    80002ade:	fc06                	sd	ra,56(sp)
    80002ae0:	f822                	sd	s0,48(sp)
    80002ae2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002ae4:	fcc40593          	addi	a1,s0,-52
    80002ae8:	4501                	li	a0,0
    80002aea:	e47ff0ef          	jal	80002930 <argint>
  if (n < 0)
    80002aee:	fcc42783          	lw	a5,-52(s0)
    80002af2:	0807c063          	bltz	a5,80002b72 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002af6:	00016517          	auipc	a0,0x16
    80002afa:	83250513          	addi	a0,a0,-1998 # 80018328 <tickslock>
    80002afe:	92afe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002b02:	fcc42783          	lw	a5,-52(s0)
    80002b06:	cbb9                	beqz	a5,80002b5c <sys_pause+0x80>
    80002b08:	f426                	sd	s1,40(sp)
    80002b0a:	f04a                	sd	s2,32(sp)
    80002b0c:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002b0e:	00008997          	auipc	s3,0x8
    80002b12:	8ea9a983          	lw	s3,-1814(s3) # 8000a3f8 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002b16:	00008917          	auipc	s2,0x8
    80002b1a:	8e290913          	addi	s2,s2,-1822 # 8000a3f8 <ticks>
    release(&tickslock);
    80002b1e:	00016497          	auipc	s1,0x16
    80002b22:	80a48493          	addi	s1,s1,-2038 # 80018328 <tickslock>
    if (killed(myproc())) {
    80002b26:	ec3fe0ef          	jal	800019e8 <myproc>
    80002b2a:	f26ff0ef          	jal	80002250 <killed>
    80002b2e:	e529                	bnez	a0,80002b78 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002b30:	854a                	mv	a0,s2
    80002b32:	cc0ff0ef          	jal	80001ff2 <sleep_prepare>
    release(&tickslock);
    80002b36:	8526                	mv	a0,s1
    80002b38:	978fe0ef          	jal	80000cb0 <release>
    sleep();
    80002b3c:	cf2ff0ef          	jal	8000202e <sleep>
    acquire(&tickslock);
    80002b40:	8526                	mv	a0,s1
    80002b42:	8e6fe0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002b46:	00092783          	lw	a5,0(s2)
    80002b4a:	413787bb          	subw	a5,a5,s3
    80002b4e:	fcc42703          	lw	a4,-52(s0)
    80002b52:	fce7eae3          	bltu	a5,a4,80002b26 <sys_pause+0x4a>
    80002b56:	74a2                	ld	s1,40(sp)
    80002b58:	7902                	ld	s2,32(sp)
    80002b5a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b5c:	00015517          	auipc	a0,0x15
    80002b60:	7cc50513          	addi	a0,a0,1996 # 80018328 <tickslock>
    80002b64:	94cfe0ef          	jal	80000cb0 <release>
  return 0;
    80002b68:	4501                	li	a0,0
}
    80002b6a:	70e2                	ld	ra,56(sp)
    80002b6c:	7442                	ld	s0,48(sp)
    80002b6e:	6121                	addi	sp,sp,64
    80002b70:	8082                	ret
    n = 0;
    80002b72:	fc042623          	sw	zero,-52(s0)
    80002b76:	b741                	j	80002af6 <sys_pause+0x1a>
      release(&tickslock);
    80002b78:	00015517          	auipc	a0,0x15
    80002b7c:	7b050513          	addi	a0,a0,1968 # 80018328 <tickslock>
    80002b80:	930fe0ef          	jal	80000cb0 <release>
      return -1;
    80002b84:	557d                	li	a0,-1
    80002b86:	74a2                	ld	s1,40(sp)
    80002b88:	7902                	ld	s2,32(sp)
    80002b8a:	69e2                	ld	s3,24(sp)
    80002b8c:	bff9                	j	80002b6a <sys_pause+0x8e>

0000000080002b8e <sys_kill>:

uint64
sys_kill(void)
{
    80002b8e:	1101                	addi	sp,sp,-32
    80002b90:	ec06                	sd	ra,24(sp)
    80002b92:	e822                	sd	s0,16(sp)
    80002b94:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b96:	fec40593          	addi	a1,s0,-20
    80002b9a:	4501                	li	a0,0
    80002b9c:	d95ff0ef          	jal	80002930 <argint>
  return kkill(pid);
    80002ba0:	fec42503          	lw	a0,-20(s0)
    80002ba4:	e1cff0ef          	jal	800021c0 <kkill>
}
    80002ba8:	60e2                	ld	ra,24(sp)
    80002baa:	6442                	ld	s0,16(sp)
    80002bac:	6105                	addi	sp,sp,32
    80002bae:	8082                	ret

0000000080002bb0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002bb0:	1101                	addi	sp,sp,-32
    80002bb2:	ec06                	sd	ra,24(sp)
    80002bb4:	e822                	sd	s0,16(sp)
    80002bb6:	e426                	sd	s1,8(sp)
    80002bb8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002bba:	00015517          	auipc	a0,0x15
    80002bbe:	76e50513          	addi	a0,a0,1902 # 80018328 <tickslock>
    80002bc2:	866fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002bc6:	00008797          	auipc	a5,0x8
    80002bca:	8327a783          	lw	a5,-1998(a5) # 8000a3f8 <ticks>
    80002bce:	84be                	mv	s1,a5
  release(&tickslock);
    80002bd0:	00015517          	auipc	a0,0x15
    80002bd4:	75850513          	addi	a0,a0,1880 # 80018328 <tickslock>
    80002bd8:	8d8fe0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002bdc:	02049513          	slli	a0,s1,0x20
    80002be0:	9101                	srli	a0,a0,0x20
    80002be2:	60e2                	ld	ra,24(sp)
    80002be4:	6442                	ld	s0,16(sp)
    80002be6:	64a2                	ld	s1,8(sp)
    80002be8:	6105                	addi	sp,sp,32
    80002bea:	8082                	ret

0000000080002bec <sys_va2pa>:

uint64
sys_va2pa(void)
{
    80002bec:	1101                	addi	sp,sp,-32
    80002bee:	ec06                	sd	ra,24(sp)
    80002bf0:	e822                	sd	s0,16(sp)
    80002bf2:	1000                	addi	s0,sp,32
  uint64 va;
  argaddr(0, &va);
    80002bf4:	fe840593          	addi	a1,s0,-24
    80002bf8:	4501                	li	a0,0
    80002bfa:	d53ff0ef          	jal	8000294c <argaddr>
  return va2pa(va);
    80002bfe:	fe843503          	ld	a0,-24(s0)
    80002c02:	bcdfe0ef          	jal	800017ce <va2pa>
}
    80002c06:	60e2                	ld	ra,24(sp)
    80002c08:	6442                	ld	s0,16(sp)
    80002c0a:	6105                	addi	sp,sp,32
    80002c0c:	8082                	ret

0000000080002c0e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c0e:	7179                	addi	sp,sp,-48
    80002c10:	f406                	sd	ra,40(sp)
    80002c12:	f022                	sd	s0,32(sp)
    80002c14:	ec26                	sd	s1,24(sp)
    80002c16:	e84a                	sd	s2,16(sp)
    80002c18:	e44e                	sd	s3,8(sp)
    80002c1a:	e052                	sd	s4,0(sp)
    80002c1c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c1e:	00005597          	auipc	a1,0x5
    80002c22:	80a58593          	addi	a1,a1,-2038 # 80007428 <etext+0x428>
    80002c26:	00015517          	auipc	a0,0x15
    80002c2a:	71a50513          	addi	a0,a0,1818 # 80018340 <bcache>
    80002c2e:	f7bfd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c32:	0001d797          	auipc	a5,0x1d
    80002c36:	70e78793          	addi	a5,a5,1806 # 80020340 <bcache+0x8000>
    80002c3a:	0001e717          	auipc	a4,0x1e
    80002c3e:	96e70713          	addi	a4,a4,-1682 # 800205a8 <bcache+0x8268>
    80002c42:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002c46:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002c4a:	00015497          	auipc	s1,0x15
    80002c4e:	70e48493          	addi	s1,s1,1806 # 80018358 <bcache+0x18>
    b->next = bcache.head.next;
    80002c52:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002c54:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c56:	00004a17          	auipc	s4,0x4
    80002c5a:	7daa0a13          	addi	s4,s4,2010 # 80007430 <etext+0x430>
    b->next = bcache.head.next;
    80002c5e:	2b893783          	ld	a5,696(s2)
    80002c62:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c64:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002c68:	85d2                	mv	a1,s4
    80002c6a:	01048513          	addi	a0,s1,16
    80002c6e:	41c010ef          	jal	8000408a <initsleeplock>
    bcache.head.next->prev = b;
    80002c72:	2b893783          	ld	a5,696(s2)
    80002c76:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c78:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002c7c:	45848493          	addi	s1,s1,1112
    80002c80:	fd349fe3          	bne	s1,s3,80002c5e <binit+0x50>
  }
}
    80002c84:	70a2                	ld	ra,40(sp)
    80002c86:	7402                	ld	s0,32(sp)
    80002c88:	64e2                	ld	s1,24(sp)
    80002c8a:	6942                	ld	s2,16(sp)
    80002c8c:	69a2                	ld	s3,8(sp)
    80002c8e:	6a02                	ld	s4,0(sp)
    80002c90:	6145                	addi	sp,sp,48
    80002c92:	8082                	ret

0000000080002c94 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002c94:	7179                	addi	sp,sp,-48
    80002c96:	f406                	sd	ra,40(sp)
    80002c98:	f022                	sd	s0,32(sp)
    80002c9a:	ec26                	sd	s1,24(sp)
    80002c9c:	e84a                	sd	s2,16(sp)
    80002c9e:	e44e                	sd	s3,8(sp)
    80002ca0:	1800                	addi	s0,sp,48
    80002ca2:	892a                	mv	s2,a0
    80002ca4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ca6:	00015517          	auipc	a0,0x15
    80002caa:	69a50513          	addi	a0,a0,1690 # 80018340 <bcache>
    80002cae:	f7bfd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002cb2:	0001e497          	auipc	s1,0x1e
    80002cb6:	9464b483          	ld	s1,-1722(s1) # 800205f8 <bcache+0x82b8>
    80002cba:	0001e797          	auipc	a5,0x1e
    80002cbe:	8ee78793          	addi	a5,a5,-1810 # 800205a8 <bcache+0x8268>
    80002cc2:	02f48b63          	beq	s1,a5,80002cf8 <bread+0x64>
    80002cc6:	873e                	mv	a4,a5
    80002cc8:	a021                	j	80002cd0 <bread+0x3c>
    80002cca:	68a4                	ld	s1,80(s1)
    80002ccc:	02e48663          	beq	s1,a4,80002cf8 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002cd0:	449c                	lw	a5,8(s1)
    80002cd2:	ff279ce3          	bne	a5,s2,80002cca <bread+0x36>
    80002cd6:	44dc                	lw	a5,12(s1)
    80002cd8:	ff3799e3          	bne	a5,s3,80002cca <bread+0x36>
      b->refcnt++;
    80002cdc:	40bc                	lw	a5,64(s1)
    80002cde:	2785                	addiw	a5,a5,1
    80002ce0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ce2:	00015517          	auipc	a0,0x15
    80002ce6:	65e50513          	addi	a0,a0,1630 # 80018340 <bcache>
    80002cea:	fc7fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002cee:	01048513          	addi	a0,s1,16
    80002cf2:	3ce010ef          	jal	800040c0 <acquiresleep>
      return b;
    80002cf6:	a889                	j	80002d48 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002cf8:	0001e497          	auipc	s1,0x1e
    80002cfc:	8f84b483          	ld	s1,-1800(s1) # 800205f0 <bcache+0x82b0>
    80002d00:	0001e797          	auipc	a5,0x1e
    80002d04:	8a878793          	addi	a5,a5,-1880 # 800205a8 <bcache+0x8268>
    80002d08:	00f48863          	beq	s1,a5,80002d18 <bread+0x84>
    80002d0c:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002d0e:	40bc                	lw	a5,64(s1)
    80002d10:	cb91                	beqz	a5,80002d24 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002d12:	64a4                	ld	s1,72(s1)
    80002d14:	fee49de3          	bne	s1,a4,80002d0e <bread+0x7a>
  panic("bget: no buffers");
    80002d18:	00004517          	auipc	a0,0x4
    80002d1c:	72050513          	addi	a0,a0,1824 # 80007438 <etext+0x438>
    80002d20:	b15fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002d24:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d28:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d2c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d30:	4785                	li	a5,1
    80002d32:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d34:	00015517          	auipc	a0,0x15
    80002d38:	60c50513          	addi	a0,a0,1548 # 80018340 <bcache>
    80002d3c:	f75fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002d40:	01048513          	addi	a0,s1,16
    80002d44:	37c010ef          	jal	800040c0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002d48:	409c                	lw	a5,0(s1)
    80002d4a:	cb89                	beqz	a5,80002d5c <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d4c:	8526                	mv	a0,s1
    80002d4e:	70a2                	ld	ra,40(sp)
    80002d50:	7402                	ld	s0,32(sp)
    80002d52:	64e2                	ld	s1,24(sp)
    80002d54:	6942                	ld	s2,16(sp)
    80002d56:	69a2                	ld	s3,8(sp)
    80002d58:	6145                	addi	sp,sp,48
    80002d5a:	8082                	ret
    virtio_disk_rw(b, 0);
    80002d5c:	4581                	li	a1,0
    80002d5e:	8526                	mv	a0,s1
    80002d60:	4c7020ef          	jal	80005a26 <virtio_disk_rw>
    b->valid = 1;
    80002d64:	4785                	li	a5,1
    80002d66:	c09c                	sw	a5,0(s1)
  return b;
    80002d68:	b7d5                	j	80002d4c <bread+0xb8>

0000000080002d6a <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002d6a:	1101                	addi	sp,sp,-32
    80002d6c:	ec06                	sd	ra,24(sp)
    80002d6e:	e822                	sd	s0,16(sp)
    80002d70:	e426                	sd	s1,8(sp)
    80002d72:	1000                	addi	s0,sp,32
    80002d74:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002d76:	0541                	addi	a0,a0,16
    80002d78:	3d4010ef          	jal	8000414c <holdingsleep>
    80002d7c:	c911                	beqz	a0,80002d90 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002d7e:	4585                	li	a1,1
    80002d80:	8526                	mv	a0,s1
    80002d82:	4a5020ef          	jal	80005a26 <virtio_disk_rw>
}
    80002d86:	60e2                	ld	ra,24(sp)
    80002d88:	6442                	ld	s0,16(sp)
    80002d8a:	64a2                	ld	s1,8(sp)
    80002d8c:	6105                	addi	sp,sp,32
    80002d8e:	8082                	ret
    panic("bwrite");
    80002d90:	00004517          	auipc	a0,0x4
    80002d94:	6c050513          	addi	a0,a0,1728 # 80007450 <etext+0x450>
    80002d98:	a9dfd0ef          	jal	80000834 <panic>

0000000080002d9c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002d9c:	1101                	addi	sp,sp,-32
    80002d9e:	ec06                	sd	ra,24(sp)
    80002da0:	e822                	sd	s0,16(sp)
    80002da2:	e426                	sd	s1,8(sp)
    80002da4:	e04a                	sd	s2,0(sp)
    80002da6:	1000                	addi	s0,sp,32
    80002da8:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002daa:	01050913          	addi	s2,a0,16
    80002dae:	854a                	mv	a0,s2
    80002db0:	39c010ef          	jal	8000414c <holdingsleep>
    80002db4:	c125                	beqz	a0,80002e14 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002db6:	854a                	mv	a0,s2
    80002db8:	35c010ef          	jal	80004114 <releasesleep>

  acquire(&bcache.lock);
    80002dbc:	00015517          	auipc	a0,0x15
    80002dc0:	58450513          	addi	a0,a0,1412 # 80018340 <bcache>
    80002dc4:	e65fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002dc8:	40bc                	lw	a5,64(s1)
    80002dca:	37fd                	addiw	a5,a5,-1
    80002dcc:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002dce:	e79d                	bnez	a5,80002dfc <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002dd0:	68b8                	ld	a4,80(s1)
    80002dd2:	64bc                	ld	a5,72(s1)
    80002dd4:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002dd6:	68b8                	ld	a4,80(s1)
    80002dd8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002dda:	0001d797          	auipc	a5,0x1d
    80002dde:	56678793          	addi	a5,a5,1382 # 80020340 <bcache+0x8000>
    80002de2:	2b87b703          	ld	a4,696(a5)
    80002de6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002de8:	0001d717          	auipc	a4,0x1d
    80002dec:	7c070713          	addi	a4,a4,1984 # 800205a8 <bcache+0x8268>
    80002df0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002df2:	2b87b703          	ld	a4,696(a5)
    80002df6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002df8:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002dfc:	00015517          	auipc	a0,0x15
    80002e00:	54450513          	addi	a0,a0,1348 # 80018340 <bcache>
    80002e04:	eadfd0ef          	jal	80000cb0 <release>
}
    80002e08:	60e2                	ld	ra,24(sp)
    80002e0a:	6442                	ld	s0,16(sp)
    80002e0c:	64a2                	ld	s1,8(sp)
    80002e0e:	6902                	ld	s2,0(sp)
    80002e10:	6105                	addi	sp,sp,32
    80002e12:	8082                	ret
    panic("brelse");
    80002e14:	00004517          	auipc	a0,0x4
    80002e18:	64450513          	addi	a0,a0,1604 # 80007458 <etext+0x458>
    80002e1c:	a19fd0ef          	jal	80000834 <panic>

0000000080002e20 <bpin>:

void
bpin(struct buf *b)
{
    80002e20:	1101                	addi	sp,sp,-32
    80002e22:	ec06                	sd	ra,24(sp)
    80002e24:	e822                	sd	s0,16(sp)
    80002e26:	e426                	sd	s1,8(sp)
    80002e28:	1000                	addi	s0,sp,32
    80002e2a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e2c:	00015517          	auipc	a0,0x15
    80002e30:	51450513          	addi	a0,a0,1300 # 80018340 <bcache>
    80002e34:	df5fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002e38:	40bc                	lw	a5,64(s1)
    80002e3a:	2785                	addiw	a5,a5,1
    80002e3c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e3e:	00015517          	auipc	a0,0x15
    80002e42:	50250513          	addi	a0,a0,1282 # 80018340 <bcache>
    80002e46:	e6bfd0ef          	jal	80000cb0 <release>
}
    80002e4a:	60e2                	ld	ra,24(sp)
    80002e4c:	6442                	ld	s0,16(sp)
    80002e4e:	64a2                	ld	s1,8(sp)
    80002e50:	6105                	addi	sp,sp,32
    80002e52:	8082                	ret

0000000080002e54 <bunpin>:

void
bunpin(struct buf *b)
{
    80002e54:	1101                	addi	sp,sp,-32
    80002e56:	ec06                	sd	ra,24(sp)
    80002e58:	e822                	sd	s0,16(sp)
    80002e5a:	e426                	sd	s1,8(sp)
    80002e5c:	1000                	addi	s0,sp,32
    80002e5e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e60:	00015517          	auipc	a0,0x15
    80002e64:	4e050513          	addi	a0,a0,1248 # 80018340 <bcache>
    80002e68:	dc1fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002e6c:	40bc                	lw	a5,64(s1)
    80002e6e:	37fd                	addiw	a5,a5,-1
    80002e70:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e72:	00015517          	auipc	a0,0x15
    80002e76:	4ce50513          	addi	a0,a0,1230 # 80018340 <bcache>
    80002e7a:	e37fd0ef          	jal	80000cb0 <release>
}
    80002e7e:	60e2                	ld	ra,24(sp)
    80002e80:	6442                	ld	s0,16(sp)
    80002e82:	64a2                	ld	s1,8(sp)
    80002e84:	6105                	addi	sp,sp,32
    80002e86:	8082                	ret

0000000080002e88 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002e88:	1101                	addi	sp,sp,-32
    80002e8a:	ec06                	sd	ra,24(sp)
    80002e8c:	e822                	sd	s0,16(sp)
    80002e8e:	e426                	sd	s1,8(sp)
    80002e90:	e04a                	sd	s2,0(sp)
    80002e92:	1000                	addi	s0,sp,32
    80002e94:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002e96:	00d5d79b          	srliw	a5,a1,0xd
    80002e9a:	0001e597          	auipc	a1,0x1e
    80002e9e:	b825a583          	lw	a1,-1150(a1) # 80020a1c <sb+0x1c>
    80002ea2:	9dbd                	addw	a1,a1,a5
    80002ea4:	df1ff0ef          	jal	80002c94 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002ea8:	0074f713          	andi	a4,s1,7
    80002eac:	4785                	li	a5,1
    80002eae:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002eb2:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002eb4:	90d9                	srli	s1,s1,0x36
    80002eb6:	00950733          	add	a4,a0,s1
    80002eba:	05874703          	lbu	a4,88(a4)
    80002ebe:	00e7f6b3          	and	a3,a5,a4
    80002ec2:	c29d                	beqz	a3,80002ee8 <bfree+0x60>
    80002ec4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002ec6:	94aa                	add	s1,s1,a0
    80002ec8:	fff7c793          	not	a5,a5
    80002ecc:	8f7d                	and	a4,a4,a5
    80002ece:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002ed2:	080010ef          	jal	80003f52 <log_write>
  brelse(bp);
    80002ed6:	854a                	mv	a0,s2
    80002ed8:	ec5ff0ef          	jal	80002d9c <brelse>
}
    80002edc:	60e2                	ld	ra,24(sp)
    80002ede:	6442                	ld	s0,16(sp)
    80002ee0:	64a2                	ld	s1,8(sp)
    80002ee2:	6902                	ld	s2,0(sp)
    80002ee4:	6105                	addi	sp,sp,32
    80002ee6:	8082                	ret
    panic("freeing free block");
    80002ee8:	00004517          	auipc	a0,0x4
    80002eec:	57850513          	addi	a0,a0,1400 # 80007460 <etext+0x460>
    80002ef0:	945fd0ef          	jal	80000834 <panic>

0000000080002ef4 <balloc>:
{
    80002ef4:	715d                	addi	sp,sp,-80
    80002ef6:	e486                	sd	ra,72(sp)
    80002ef8:	e0a2                	sd	s0,64(sp)
    80002efa:	fc26                	sd	s1,56(sp)
    80002efc:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002efe:	0001e797          	auipc	a5,0x1e
    80002f02:	b067a783          	lw	a5,-1274(a5) # 80020a04 <sb+0x4>
    80002f06:	0e078263          	beqz	a5,80002fea <balloc+0xf6>
    80002f0a:	f84a                	sd	s2,48(sp)
    80002f0c:	f44e                	sd	s3,40(sp)
    80002f0e:	f052                	sd	s4,32(sp)
    80002f10:	ec56                	sd	s5,24(sp)
    80002f12:	e85a                	sd	s6,16(sp)
    80002f14:	e45e                	sd	s7,8(sp)
    80002f16:	e062                	sd	s8,0(sp)
    80002f18:	8baa                	mv	s7,a0
    80002f1a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f1c:	0001eb17          	auipc	s6,0x1e
    80002f20:	ae4b0b13          	addi	s6,s6,-1308 # 80020a00 <sb>
      m = 1 << (bi % 8);
    80002f24:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f26:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002f28:	6c09                	lui	s8,0x2
    80002f2a:	a09d                	j	80002f90 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002f2c:	97ca                	add	a5,a5,s2
    80002f2e:	8e55                	or	a2,a2,a3
    80002f30:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f34:	854a                	mv	a0,s2
    80002f36:	01c010ef          	jal	80003f52 <log_write>
        brelse(bp);
    80002f3a:	854a                	mv	a0,s2
    80002f3c:	e61ff0ef          	jal	80002d9c <brelse>
  bp = bread(dev, bno);
    80002f40:	85a6                	mv	a1,s1
    80002f42:	855e                	mv	a0,s7
    80002f44:	d51ff0ef          	jal	80002c94 <bread>
    80002f48:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f4a:	40000613          	li	a2,1024
    80002f4e:	4581                	li	a1,0
    80002f50:	05850513          	addi	a0,a0,88
    80002f54:	d95fd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    80002f58:	854a                	mv	a0,s2
    80002f5a:	7f9000ef          	jal	80003f52 <log_write>
  brelse(bp);
    80002f5e:	854a                	mv	a0,s2
    80002f60:	e3dff0ef          	jal	80002d9c <brelse>
}
    80002f64:	7942                	ld	s2,48(sp)
    80002f66:	79a2                	ld	s3,40(sp)
    80002f68:	7a02                	ld	s4,32(sp)
    80002f6a:	6ae2                	ld	s5,24(sp)
    80002f6c:	6b42                	ld	s6,16(sp)
    80002f6e:	6ba2                	ld	s7,8(sp)
    80002f70:	6c02                	ld	s8,0(sp)
}
    80002f72:	8526                	mv	a0,s1
    80002f74:	60a6                	ld	ra,72(sp)
    80002f76:	6406                	ld	s0,64(sp)
    80002f78:	74e2                	ld	s1,56(sp)
    80002f7a:	6161                	addi	sp,sp,80
    80002f7c:	8082                	ret
    brelse(bp);
    80002f7e:	854a                	mv	a0,s2
    80002f80:	e1dff0ef          	jal	80002d9c <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002f84:	015c0abb          	addw	s5,s8,s5
    80002f88:	004b2783          	lw	a5,4(s6)
    80002f8c:	04faf863          	bgeu	s5,a5,80002fdc <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002f90:	40dad59b          	sraiw	a1,s5,0xd
    80002f94:	01cb2783          	lw	a5,28(s6)
    80002f98:	9dbd                	addw	a1,a1,a5
    80002f9a:	855e                	mv	a0,s7
    80002f9c:	cf9ff0ef          	jal	80002c94 <bread>
    80002fa0:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002fa2:	004b2503          	lw	a0,4(s6)
    80002fa6:	84d6                	mv	s1,s5
    80002fa8:	4701                	li	a4,0
    80002faa:	fca4fae3          	bgeu	s1,a0,80002f7e <balloc+0x8a>
      m = 1 << (bi % 8);
    80002fae:	00777693          	andi	a3,a4,7
    80002fb2:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002fb6:	41f7579b          	sraiw	a5,a4,0x1f
    80002fba:	01d7d79b          	srliw	a5,a5,0x1d
    80002fbe:	9fb9                	addw	a5,a5,a4
    80002fc0:	4037d79b          	sraiw	a5,a5,0x3
    80002fc4:	00f90633          	add	a2,s2,a5
    80002fc8:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80002fcc:	00c6f5b3          	and	a1,a3,a2
    80002fd0:	ddb1                	beqz	a1,80002f2c <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002fd2:	2705                	addiw	a4,a4,1
    80002fd4:	2485                	addiw	s1,s1,1
    80002fd6:	fd471ae3          	bne	a4,s4,80002faa <balloc+0xb6>
    80002fda:	b755                	j	80002f7e <balloc+0x8a>
    80002fdc:	7942                	ld	s2,48(sp)
    80002fde:	79a2                	ld	s3,40(sp)
    80002fe0:	7a02                	ld	s4,32(sp)
    80002fe2:	6ae2                	ld	s5,24(sp)
    80002fe4:	6b42                	ld	s6,16(sp)
    80002fe6:	6ba2                	ld	s7,8(sp)
    80002fe8:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    80002fea:	00004517          	auipc	a0,0x4
    80002fee:	48e50513          	addi	a0,a0,1166 # 80007478 <etext+0x478>
    80002ff2:	d18fd0ef          	jal	8000050a <printk>
  return 0;
    80002ff6:	4481                	li	s1,0
    80002ff8:	bfad                	j	80002f72 <balloc+0x7e>

0000000080002ffa <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002ffa:	7179                	addi	sp,sp,-48
    80002ffc:	f406                	sd	ra,40(sp)
    80002ffe:	f022                	sd	s0,32(sp)
    80003000:	ec26                	sd	s1,24(sp)
    80003002:	e84a                	sd	s2,16(sp)
    80003004:	e44e                	sd	s3,8(sp)
    80003006:	1800                	addi	s0,sp,48
    80003008:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    8000300a:	47ad                	li	a5,11
    8000300c:	02b7e363          	bltu	a5,a1,80003032 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80003010:	02059793          	slli	a5,a1,0x20
    80003014:	01e7d593          	srli	a1,a5,0x1e
    80003018:	00b509b3          	add	s3,a0,a1
    8000301c:	0509a483          	lw	s1,80(s3)
    80003020:	e0b5                	bnez	s1,80003084 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003022:	4108                	lw	a0,0(a0)
    80003024:	ed1ff0ef          	jal	80002ef4 <balloc>
    80003028:	84aa                	mv	s1,a0
      if (addr == 0)
    8000302a:	cd29                	beqz	a0,80003084 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    8000302c:	04a9a823          	sw	a0,80(s3)
    80003030:	a891                	j	80003084 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003032:	ff45879b          	addiw	a5,a1,-12
    80003036:	873e                	mv	a4,a5
    80003038:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    8000303a:	0ff00793          	li	a5,255
    8000303e:	06e7e763          	bltu	a5,a4,800030ac <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80003042:	08052483          	lw	s1,128(a0)
    80003046:	e891                	bnez	s1,8000305a <bmap+0x60>
      addr = balloc(ip->dev);
    80003048:	4108                	lw	a0,0(a0)
    8000304a:	eabff0ef          	jal	80002ef4 <balloc>
    8000304e:	84aa                	mv	s1,a0
      if (addr == 0)
    80003050:	c915                	beqz	a0,80003084 <bmap+0x8a>
    80003052:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003054:	08a92023          	sw	a0,128(s2)
    80003058:	a011                	j	8000305c <bmap+0x62>
    8000305a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000305c:	85a6                	mv	a1,s1
    8000305e:	00092503          	lw	a0,0(s2)
    80003062:	c33ff0ef          	jal	80002c94 <bread>
    80003066:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80003068:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    8000306c:	02099713          	slli	a4,s3,0x20
    80003070:	01e75593          	srli	a1,a4,0x1e
    80003074:	97ae                	add	a5,a5,a1
    80003076:	89be                	mv	s3,a5
    80003078:	4384                	lw	s1,0(a5)
    8000307a:	cc89                	beqz	s1,80003094 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000307c:	8552                	mv	a0,s4
    8000307e:	d1fff0ef          	jal	80002d9c <brelse>
    return addr;
    80003082:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003084:	8526                	mv	a0,s1
    80003086:	70a2                	ld	ra,40(sp)
    80003088:	7402                	ld	s0,32(sp)
    8000308a:	64e2                	ld	s1,24(sp)
    8000308c:	6942                	ld	s2,16(sp)
    8000308e:	69a2                	ld	s3,8(sp)
    80003090:	6145                	addi	sp,sp,48
    80003092:	8082                	ret
      addr = balloc(ip->dev);
    80003094:	00092503          	lw	a0,0(s2)
    80003098:	e5dff0ef          	jal	80002ef4 <balloc>
    8000309c:	84aa                	mv	s1,a0
      if (addr) {
    8000309e:	dd79                	beqz	a0,8000307c <bmap+0x82>
        a[bn] = addr;
    800030a0:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800030a4:	8552                	mv	a0,s4
    800030a6:	6ad000ef          	jal	80003f52 <log_write>
    800030aa:	bfc9                	j	8000307c <bmap+0x82>
    800030ac:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800030ae:	00004517          	auipc	a0,0x4
    800030b2:	3e250513          	addi	a0,a0,994 # 80007490 <etext+0x490>
    800030b6:	f7efd0ef          	jal	80000834 <panic>

00000000800030ba <iget>:
{
    800030ba:	7179                	addi	sp,sp,-48
    800030bc:	f406                	sd	ra,40(sp)
    800030be:	f022                	sd	s0,32(sp)
    800030c0:	ec26                	sd	s1,24(sp)
    800030c2:	e84a                	sd	s2,16(sp)
    800030c4:	e44e                	sd	s3,8(sp)
    800030c6:	e052                	sd	s4,0(sp)
    800030c8:	1800                	addi	s0,sp,48
    800030ca:	892a                	mv	s2,a0
    800030cc:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800030ce:	0001e517          	auipc	a0,0x1e
    800030d2:	95250513          	addi	a0,a0,-1710 # 80020a20 <itable>
    800030d6:	b53fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    800030da:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800030dc:	0001e497          	auipc	s1,0x1e
    800030e0:	95c48493          	addi	s1,s1,-1700 # 80020a38 <itable+0x18>
    800030e4:	0001f697          	auipc	a3,0x1f
    800030e8:	3e468693          	addi	a3,a3,996 # 800224c8 <log>
    800030ec:	a809                	j	800030fe <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800030ee:	e781                	bnez	a5,800030f6 <iget+0x3c>
    800030f0:	00099363          	bnez	s3,800030f6 <iget+0x3c>
      empty = ip;
    800030f4:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800030f6:	08848493          	addi	s1,s1,136
    800030fa:	02d48563          	beq	s1,a3,80003124 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    800030fe:	449c                	lw	a5,8(s1)
    80003100:	fef057e3          	blez	a5,800030ee <iget+0x34>
    80003104:	4098                	lw	a4,0(s1)
    80003106:	ff2718e3          	bne	a4,s2,800030f6 <iget+0x3c>
    8000310a:	40d8                	lw	a4,4(s1)
    8000310c:	ff4715e3          	bne	a4,s4,800030f6 <iget+0x3c>
      ip->ref++;
    80003110:	2785                	addiw	a5,a5,1
    80003112:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003114:	0001e517          	auipc	a0,0x1e
    80003118:	90c50513          	addi	a0,a0,-1780 # 80020a20 <itable>
    8000311c:	b95fd0ef          	jal	80000cb0 <release>
      return ip;
    80003120:	89a6                	mv	s3,s1
    80003122:	a015                	j	80003146 <iget+0x8c>
  if (empty == 0)
    80003124:	02098a63          	beqz	s3,80003158 <iget+0x9e>
  ip->dev = dev;
    80003128:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000312c:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003130:	4785                	li	a5,1
    80003132:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003136:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000313a:	0001e517          	auipc	a0,0x1e
    8000313e:	8e650513          	addi	a0,a0,-1818 # 80020a20 <itable>
    80003142:	b6ffd0ef          	jal	80000cb0 <release>
}
    80003146:	854e                	mv	a0,s3
    80003148:	70a2                	ld	ra,40(sp)
    8000314a:	7402                	ld	s0,32(sp)
    8000314c:	64e2                	ld	s1,24(sp)
    8000314e:	6942                	ld	s2,16(sp)
    80003150:	69a2                	ld	s3,8(sp)
    80003152:	6a02                	ld	s4,0(sp)
    80003154:	6145                	addi	sp,sp,48
    80003156:	8082                	ret
    panic("iget: no inodes");
    80003158:	00004517          	auipc	a0,0x4
    8000315c:	35050513          	addi	a0,a0,848 # 800074a8 <etext+0x4a8>
    80003160:	ed4fd0ef          	jal	80000834 <panic>

0000000080003164 <iinit>:
{
    80003164:	7179                	addi	sp,sp,-48
    80003166:	f406                	sd	ra,40(sp)
    80003168:	f022                	sd	s0,32(sp)
    8000316a:	ec26                	sd	s1,24(sp)
    8000316c:	e84a                	sd	s2,16(sp)
    8000316e:	e44e                	sd	s3,8(sp)
    80003170:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003172:	00004597          	auipc	a1,0x4
    80003176:	34658593          	addi	a1,a1,838 # 800074b8 <etext+0x4b8>
    8000317a:	0001e517          	auipc	a0,0x1e
    8000317e:	8a650513          	addi	a0,a0,-1882 # 80020a20 <itable>
    80003182:	a27fd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    80003186:	0001e497          	auipc	s1,0x1e
    8000318a:	8c248493          	addi	s1,s1,-1854 # 80020a48 <itable+0x28>
    8000318e:	0001f997          	auipc	s3,0x1f
    80003192:	34a98993          	addi	s3,s3,842 # 800224d8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003196:	00004917          	auipc	s2,0x4
    8000319a:	32a90913          	addi	s2,s2,810 # 800074c0 <etext+0x4c0>
    8000319e:	85ca                	mv	a1,s2
    800031a0:	8526                	mv	a0,s1
    800031a2:	6e9000ef          	jal	8000408a <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    800031a6:	08848493          	addi	s1,s1,136
    800031aa:	ff349ae3          	bne	s1,s3,8000319e <iinit+0x3a>
}
    800031ae:	70a2                	ld	ra,40(sp)
    800031b0:	7402                	ld	s0,32(sp)
    800031b2:	64e2                	ld	s1,24(sp)
    800031b4:	6942                	ld	s2,16(sp)
    800031b6:	69a2                	ld	s3,8(sp)
    800031b8:	6145                	addi	sp,sp,48
    800031ba:	8082                	ret

00000000800031bc <ialloc>:
{
    800031bc:	7139                	addi	sp,sp,-64
    800031be:	fc06                	sd	ra,56(sp)
    800031c0:	f822                	sd	s0,48(sp)
    800031c2:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    800031c4:	0001e717          	auipc	a4,0x1e
    800031c8:	84872703          	lw	a4,-1976(a4) # 80020a0c <sb+0xc>
    800031cc:	4785                	li	a5,1
    800031ce:	06e7f063          	bgeu	a5,a4,8000322e <ialloc+0x72>
    800031d2:	f426                	sd	s1,40(sp)
    800031d4:	f04a                	sd	s2,32(sp)
    800031d6:	ec4e                	sd	s3,24(sp)
    800031d8:	e852                	sd	s4,16(sp)
    800031da:	e456                	sd	s5,8(sp)
    800031dc:	e05a                	sd	s6,0(sp)
    800031de:	8aaa                	mv	s5,a0
    800031e0:	8b2e                	mv	s6,a1
    800031e2:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800031e4:	0001ea17          	auipc	s4,0x1e
    800031e8:	81ca0a13          	addi	s4,s4,-2020 # 80020a00 <sb>
    800031ec:	00495593          	srli	a1,s2,0x4
    800031f0:	018a2783          	lw	a5,24(s4)
    800031f4:	9dbd                	addw	a1,a1,a5
    800031f6:	8556                	mv	a0,s5
    800031f8:	a9dff0ef          	jal	80002c94 <bread>
    800031fc:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    800031fe:	05850993          	addi	s3,a0,88
    80003202:	00f97793          	andi	a5,s2,15
    80003206:	079a                	slli	a5,a5,0x6
    80003208:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    8000320a:	00099783          	lh	a5,0(s3)
    8000320e:	cb9d                	beqz	a5,80003244 <ialloc+0x88>
    brelse(bp);
    80003210:	b8dff0ef          	jal	80002d9c <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003214:	0905                	addi	s2,s2,1
    80003216:	00ca2703          	lw	a4,12(s4)
    8000321a:	0009079b          	sext.w	a5,s2
    8000321e:	fce7e7e3          	bltu	a5,a4,800031ec <ialloc+0x30>
    80003222:	74a2                	ld	s1,40(sp)
    80003224:	7902                	ld	s2,32(sp)
    80003226:	69e2                	ld	s3,24(sp)
    80003228:	6a42                	ld	s4,16(sp)
    8000322a:	6aa2                	ld	s5,8(sp)
    8000322c:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    8000322e:	00004517          	auipc	a0,0x4
    80003232:	29a50513          	addi	a0,a0,666 # 800074c8 <etext+0x4c8>
    80003236:	ad4fd0ef          	jal	8000050a <printk>
  return 0;
    8000323a:	4501                	li	a0,0
}
    8000323c:	70e2                	ld	ra,56(sp)
    8000323e:	7442                	ld	s0,48(sp)
    80003240:	6121                	addi	sp,sp,64
    80003242:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003244:	04000613          	li	a2,64
    80003248:	4581                	li	a1,0
    8000324a:	854e                	mv	a0,s3
    8000324c:	a9dfd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    80003250:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003254:	8526                	mv	a0,s1
    80003256:	4fd000ef          	jal	80003f52 <log_write>
      brelse(bp);
    8000325a:	8526                	mv	a0,s1
    8000325c:	b41ff0ef          	jal	80002d9c <brelse>
      return iget(dev, inum);
    80003260:	0009059b          	sext.w	a1,s2
    80003264:	8556                	mv	a0,s5
    80003266:	e55ff0ef          	jal	800030ba <iget>
    8000326a:	74a2                	ld	s1,40(sp)
    8000326c:	7902                	ld	s2,32(sp)
    8000326e:	69e2                	ld	s3,24(sp)
    80003270:	6a42                	ld	s4,16(sp)
    80003272:	6aa2                	ld	s5,8(sp)
    80003274:	6b02                	ld	s6,0(sp)
    80003276:	b7d9                	j	8000323c <ialloc+0x80>

0000000080003278 <iupdate>:
{
    80003278:	1101                	addi	sp,sp,-32
    8000327a:	ec06                	sd	ra,24(sp)
    8000327c:	e822                	sd	s0,16(sp)
    8000327e:	e426                	sd	s1,8(sp)
    80003280:	e04a                	sd	s2,0(sp)
    80003282:	1000                	addi	s0,sp,32
    80003284:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003286:	415c                	lw	a5,4(a0)
    80003288:	0047d79b          	srliw	a5,a5,0x4
    8000328c:	0001d597          	auipc	a1,0x1d
    80003290:	78c5a583          	lw	a1,1932(a1) # 80020a18 <sb+0x18>
    80003294:	9dbd                	addw	a1,a1,a5
    80003296:	4108                	lw	a0,0(a0)
    80003298:	9fdff0ef          	jal	80002c94 <bread>
    8000329c:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000329e:	05850793          	addi	a5,a0,88
    800032a2:	40d8                	lw	a4,4(s1)
    800032a4:	8b3d                	andi	a4,a4,15
    800032a6:	071a                	slli	a4,a4,0x6
    800032a8:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800032aa:	04449703          	lh	a4,68(s1)
    800032ae:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800032b2:	04649703          	lh	a4,70(s1)
    800032b6:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800032ba:	04849703          	lh	a4,72(s1)
    800032be:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800032c2:	04a49703          	lh	a4,74(s1)
    800032c6:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800032ca:	44f8                	lw	a4,76(s1)
    800032cc:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800032ce:	03400613          	li	a2,52
    800032d2:	05048593          	addi	a1,s1,80
    800032d6:	00c78513          	addi	a0,a5,12
    800032da:	a6ffd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    800032de:	854a                	mv	a0,s2
    800032e0:	473000ef          	jal	80003f52 <log_write>
  brelse(bp);
    800032e4:	854a                	mv	a0,s2
    800032e6:	ab7ff0ef          	jal	80002d9c <brelse>
}
    800032ea:	60e2                	ld	ra,24(sp)
    800032ec:	6442                	ld	s0,16(sp)
    800032ee:	64a2                	ld	s1,8(sp)
    800032f0:	6902                	ld	s2,0(sp)
    800032f2:	6105                	addi	sp,sp,32
    800032f4:	8082                	ret

00000000800032f6 <idup>:
{
    800032f6:	1101                	addi	sp,sp,-32
    800032f8:	ec06                	sd	ra,24(sp)
    800032fa:	e822                	sd	s0,16(sp)
    800032fc:	e426                	sd	s1,8(sp)
    800032fe:	1000                	addi	s0,sp,32
    80003300:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003302:	0001d517          	auipc	a0,0x1d
    80003306:	71e50513          	addi	a0,a0,1822 # 80020a20 <itable>
    8000330a:	91ffd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    8000330e:	449c                	lw	a5,8(s1)
    80003310:	2785                	addiw	a5,a5,1
    80003312:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003314:	0001d517          	auipc	a0,0x1d
    80003318:	70c50513          	addi	a0,a0,1804 # 80020a20 <itable>
    8000331c:	995fd0ef          	jal	80000cb0 <release>
}
    80003320:	8526                	mv	a0,s1
    80003322:	60e2                	ld	ra,24(sp)
    80003324:	6442                	ld	s0,16(sp)
    80003326:	64a2                	ld	s1,8(sp)
    80003328:	6105                	addi	sp,sp,32
    8000332a:	8082                	ret

000000008000332c <ilock>:
{
    8000332c:	1101                	addi	sp,sp,-32
    8000332e:	ec06                	sd	ra,24(sp)
    80003330:	e822                	sd	s0,16(sp)
    80003332:	e426                	sd	s1,8(sp)
    80003334:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003336:	cd19                	beqz	a0,80003354 <ilock+0x28>
    80003338:	84aa                	mv	s1,a0
    8000333a:	451c                	lw	a5,8(a0)
    8000333c:	00f05c63          	blez	a5,80003354 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003340:	0541                	addi	a0,a0,16
    80003342:	57f000ef          	jal	800040c0 <acquiresleep>
  if (ip->valid == 0) {
    80003346:	40bc                	lw	a5,64(s1)
    80003348:	cf89                	beqz	a5,80003362 <ilock+0x36>
}
    8000334a:	60e2                	ld	ra,24(sp)
    8000334c:	6442                	ld	s0,16(sp)
    8000334e:	64a2                	ld	s1,8(sp)
    80003350:	6105                	addi	sp,sp,32
    80003352:	8082                	ret
    80003354:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003356:	00004517          	auipc	a0,0x4
    8000335a:	18a50513          	addi	a0,a0,394 # 800074e0 <etext+0x4e0>
    8000335e:	cd6fd0ef          	jal	80000834 <panic>
    80003362:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003364:	40dc                	lw	a5,4(s1)
    80003366:	0047d79b          	srliw	a5,a5,0x4
    8000336a:	0001d597          	auipc	a1,0x1d
    8000336e:	6ae5a583          	lw	a1,1710(a1) # 80020a18 <sb+0x18>
    80003372:	9dbd                	addw	a1,a1,a5
    80003374:	4088                	lw	a0,0(s1)
    80003376:	91fff0ef          	jal	80002c94 <bread>
    8000337a:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000337c:	05850593          	addi	a1,a0,88
    80003380:	40dc                	lw	a5,4(s1)
    80003382:	8bbd                	andi	a5,a5,15
    80003384:	079a                	slli	a5,a5,0x6
    80003386:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003388:	00059783          	lh	a5,0(a1)
    8000338c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003390:	00259783          	lh	a5,2(a1)
    80003394:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003398:	00459783          	lh	a5,4(a1)
    8000339c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800033a0:	00659783          	lh	a5,6(a1)
    800033a4:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800033a8:	459c                	lw	a5,8(a1)
    800033aa:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800033ac:	03400613          	li	a2,52
    800033b0:	05b1                	addi	a1,a1,12
    800033b2:	05048513          	addi	a0,s1,80
    800033b6:	993fd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    800033ba:	854a                	mv	a0,s2
    800033bc:	9e1ff0ef          	jal	80002d9c <brelse>
    ip->valid = 1;
    800033c0:	4785                	li	a5,1
    800033c2:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    800033c4:	04449783          	lh	a5,68(s1)
    800033c8:	c399                	beqz	a5,800033ce <ilock+0xa2>
    800033ca:	6902                	ld	s2,0(sp)
    800033cc:	bfbd                	j	8000334a <ilock+0x1e>
      panic("ilock: no type");
    800033ce:	00004517          	auipc	a0,0x4
    800033d2:	11a50513          	addi	a0,a0,282 # 800074e8 <etext+0x4e8>
    800033d6:	c5efd0ef          	jal	80000834 <panic>

00000000800033da <iunlock>:
{
    800033da:	1101                	addi	sp,sp,-32
    800033dc:	ec06                	sd	ra,24(sp)
    800033de:	e822                	sd	s0,16(sp)
    800033e0:	e426                	sd	s1,8(sp)
    800033e2:	e04a                	sd	s2,0(sp)
    800033e4:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800033e6:	c505                	beqz	a0,8000340e <iunlock+0x34>
    800033e8:	84aa                	mv	s1,a0
    800033ea:	01050913          	addi	s2,a0,16
    800033ee:	854a                	mv	a0,s2
    800033f0:	55d000ef          	jal	8000414c <holdingsleep>
    800033f4:	cd09                	beqz	a0,8000340e <iunlock+0x34>
    800033f6:	449c                	lw	a5,8(s1)
    800033f8:	00f05b63          	blez	a5,8000340e <iunlock+0x34>
  releasesleep(&ip->lock);
    800033fc:	854a                	mv	a0,s2
    800033fe:	517000ef          	jal	80004114 <releasesleep>
}
    80003402:	60e2                	ld	ra,24(sp)
    80003404:	6442                	ld	s0,16(sp)
    80003406:	64a2                	ld	s1,8(sp)
    80003408:	6902                	ld	s2,0(sp)
    8000340a:	6105                	addi	sp,sp,32
    8000340c:	8082                	ret
    panic("iunlock");
    8000340e:	00004517          	auipc	a0,0x4
    80003412:	0ea50513          	addi	a0,a0,234 # 800074f8 <etext+0x4f8>
    80003416:	c1efd0ef          	jal	80000834 <panic>

000000008000341a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000341a:	7179                	addi	sp,sp,-48
    8000341c:	f406                	sd	ra,40(sp)
    8000341e:	f022                	sd	s0,32(sp)
    80003420:	ec26                	sd	s1,24(sp)
    80003422:	e84a                	sd	s2,16(sp)
    80003424:	e44e                	sd	s3,8(sp)
    80003426:	1800                	addi	s0,sp,48
    80003428:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    8000342a:	05050493          	addi	s1,a0,80
    8000342e:	08050913          	addi	s2,a0,128
    80003432:	a021                	j	8000343a <itrunc+0x20>
    80003434:	0491                	addi	s1,s1,4
    80003436:	01248b63          	beq	s1,s2,8000344c <itrunc+0x32>
    if (ip->addrs[i]) {
    8000343a:	408c                	lw	a1,0(s1)
    8000343c:	dde5                	beqz	a1,80003434 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000343e:	0009a503          	lw	a0,0(s3)
    80003442:	a47ff0ef          	jal	80002e88 <bfree>
      ip->addrs[i] = 0;
    80003446:	0004a023          	sw	zero,0(s1)
    8000344a:	b7ed                	j	80003434 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    8000344c:	0809a583          	lw	a1,128(s3)
    80003450:	ed89                	bnez	a1,8000346a <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003452:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003456:	854e                	mv	a0,s3
    80003458:	e21ff0ef          	jal	80003278 <iupdate>
}
    8000345c:	70a2                	ld	ra,40(sp)
    8000345e:	7402                	ld	s0,32(sp)
    80003460:	64e2                	ld	s1,24(sp)
    80003462:	6942                	ld	s2,16(sp)
    80003464:	69a2                	ld	s3,8(sp)
    80003466:	6145                	addi	sp,sp,48
    80003468:	8082                	ret
    8000346a:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000346c:	0009a503          	lw	a0,0(s3)
    80003470:	825ff0ef          	jal	80002c94 <bread>
    80003474:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    80003476:	05850493          	addi	s1,a0,88
    8000347a:	45850913          	addi	s2,a0,1112
    8000347e:	a021                	j	80003486 <itrunc+0x6c>
    80003480:	0491                	addi	s1,s1,4
    80003482:	01248963          	beq	s1,s2,80003494 <itrunc+0x7a>
      if (a[j])
    80003486:	408c                	lw	a1,0(s1)
    80003488:	dde5                	beqz	a1,80003480 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000348a:	0009a503          	lw	a0,0(s3)
    8000348e:	9fbff0ef          	jal	80002e88 <bfree>
    80003492:	b7fd                	j	80003480 <itrunc+0x66>
    brelse(bp);
    80003494:	8552                	mv	a0,s4
    80003496:	907ff0ef          	jal	80002d9c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000349a:	0809a583          	lw	a1,128(s3)
    8000349e:	0009a503          	lw	a0,0(s3)
    800034a2:	9e7ff0ef          	jal	80002e88 <bfree>
    ip->addrs[NDIRECT] = 0;
    800034a6:	0809a023          	sw	zero,128(s3)
    800034aa:	6a02                	ld	s4,0(sp)
    800034ac:	b75d                	j	80003452 <itrunc+0x38>

00000000800034ae <iput>:
{
    800034ae:	7179                	addi	sp,sp,-48
    800034b0:	f406                	sd	ra,40(sp)
    800034b2:	f022                	sd	s0,32(sp)
    800034b4:	ec26                	sd	s1,24(sp)
    800034b6:	1800                	addi	s0,sp,48
    800034b8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800034ba:	0001d517          	auipc	a0,0x1d
    800034be:	56650513          	addi	a0,a0,1382 # 80020a20 <itable>
    800034c2:	f66fd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800034c6:	449c                	lw	a5,8(s1)
    800034c8:	4705                	li	a4,1
    800034ca:	00e78f63          	beq	a5,a4,800034e8 <iput+0x3a>
  ip->ref--;
    800034ce:	37fd                	addiw	a5,a5,-1
    800034d0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034d2:	0001d517          	auipc	a0,0x1d
    800034d6:	54e50513          	addi	a0,a0,1358 # 80020a20 <itable>
    800034da:	fd6fd0ef          	jal	80000cb0 <release>
}
    800034de:	70a2                	ld	ra,40(sp)
    800034e0:	7402                	ld	s0,32(sp)
    800034e2:	64e2                	ld	s1,24(sp)
    800034e4:	6145                	addi	sp,sp,48
    800034e6:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800034e8:	40b8                	lw	a4,64(s1)
    800034ea:	d375                	beqz	a4,800034ce <iput+0x20>
    800034ec:	e84a                	sd	s2,16(sp)
    800034ee:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    800034f0:	0004aa03          	lw	s4,0(s1)
    800034f4:	0044a903          	lw	s2,4(s1)
  if (last) {
    800034f8:	04a49703          	lh	a4,74(s1)
    800034fc:	ef3d                	bnez	a4,8000357a <iput+0xcc>
    800034fe:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    80003500:	01048793          	addi	a5,s1,16
    80003504:	89be                	mv	s3,a5
    80003506:	853e                	mv	a0,a5
    80003508:	3b9000ef          	jal	800040c0 <acquiresleep>
    release(&itable.lock);
    8000350c:	0001d517          	auipc	a0,0x1d
    80003510:	51450513          	addi	a0,a0,1300 # 80020a20 <itable>
    80003514:	f9cfd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    80003518:	8526                	mv	a0,s1
    8000351a:	f01ff0ef          	jal	8000341a <itrunc>
    ip->valid = 0;
    8000351e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003522:	854e                	mv	a0,s3
    80003524:	3f1000ef          	jal	80004114 <releasesleep>
    acquire(&itable.lock);
    80003528:	0001d517          	auipc	a0,0x1d
    8000352c:	4f850513          	addi	a0,a0,1272 # 80020a20 <itable>
    80003530:	ef8fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    80003534:	449c                	lw	a5,8(s1)
    80003536:	37fd                	addiw	a5,a5,-1
    80003538:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000353a:	0001d517          	auipc	a0,0x1d
    8000353e:	4e650513          	addi	a0,a0,1254 # 80020a20 <itable>
    80003542:	f6efd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003546:	0049579b          	srliw	a5,s2,0x4
    8000354a:	0001d597          	auipc	a1,0x1d
    8000354e:	4ce5a583          	lw	a1,1230(a1) # 80020a18 <sb+0x18>
    80003552:	9dbd                	addw	a1,a1,a5
    80003554:	8552                	mv	a0,s4
    80003556:	f3eff0ef          	jal	80002c94 <bread>
    8000355a:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000355c:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    80003560:	079a                	slli	a5,a5,0x6
    80003562:	97aa                	add	a5,a5,a0
    80003564:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    80003568:	1eb000ef          	jal	80003f52 <log_write>
  brelse(bp);
    8000356c:	8526                	mv	a0,s1
    8000356e:	82fff0ef          	jal	80002d9c <brelse>
}
    80003572:	6942                	ld	s2,16(sp)
    80003574:	69a2                	ld	s3,8(sp)
    80003576:	6a02                	ld	s4,0(sp)
    80003578:	b79d                	j	800034de <iput+0x30>
    8000357a:	6942                	ld	s2,16(sp)
    8000357c:	6a02                	ld	s4,0(sp)
    8000357e:	bf81                	j	800034ce <iput+0x20>

0000000080003580 <iunlockput>:
{
    80003580:	1101                	addi	sp,sp,-32
    80003582:	ec06                	sd	ra,24(sp)
    80003584:	e822                	sd	s0,16(sp)
    80003586:	e426                	sd	s1,8(sp)
    80003588:	1000                	addi	s0,sp,32
    8000358a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000358c:	e4fff0ef          	jal	800033da <iunlock>
  iput(ip);
    80003590:	8526                	mv	a0,s1
    80003592:	f1dff0ef          	jal	800034ae <iput>
}
    80003596:	60e2                	ld	ra,24(sp)
    80003598:	6442                	ld	s0,16(sp)
    8000359a:	64a2                	ld	s1,8(sp)
    8000359c:	6105                	addi	sp,sp,32
    8000359e:	8082                	ret

00000000800035a0 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035a0:	0001d717          	auipc	a4,0x1d
    800035a4:	46c72703          	lw	a4,1132(a4) # 80020a0c <sb+0xc>
    800035a8:	4785                	li	a5,1
    800035aa:	0ae7fe63          	bgeu	a5,a4,80003666 <ireclaim+0xc6>
{
    800035ae:	7139                	addi	sp,sp,-64
    800035b0:	fc06                	sd	ra,56(sp)
    800035b2:	f822                	sd	s0,48(sp)
    800035b4:	f426                	sd	s1,40(sp)
    800035b6:	f04a                	sd	s2,32(sp)
    800035b8:	ec4e                	sd	s3,24(sp)
    800035ba:	e852                	sd	s4,16(sp)
    800035bc:	e456                	sd	s5,8(sp)
    800035be:	e05a                	sd	s6,0(sp)
    800035c0:	0080                	addi	s0,sp,64
    800035c2:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035c4:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035c6:	0001da17          	auipc	s4,0x1d
    800035ca:	43aa0a13          	addi	s4,s4,1082 # 80020a00 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    800035ce:	00004b17          	auipc	s6,0x4
    800035d2:	f32b0b13          	addi	s6,s6,-206 # 80007500 <etext+0x500>
    800035d6:	a099                	j	8000361c <ireclaim+0x7c>
    800035d8:	85ce                	mv	a1,s3
    800035da:	855a                	mv	a0,s6
    800035dc:	f2ffc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    800035e0:	85ce                	mv	a1,s3
    800035e2:	8556                	mv	a0,s5
    800035e4:	ad7ff0ef          	jal	800030ba <iget>
    800035e8:	89aa                	mv	s3,a0
    brelse(bp);
    800035ea:	854a                	mv	a0,s2
    800035ec:	fb0ff0ef          	jal	80002d9c <brelse>
    if (ip) {
    800035f0:	00098f63          	beqz	s3,8000360e <ireclaim+0x6e>
      begin_op();
    800035f4:	7b0000ef          	jal	80003da4 <begin_op>
      ilock(ip);
    800035f8:	854e                	mv	a0,s3
    800035fa:	d33ff0ef          	jal	8000332c <ilock>
      iunlock(ip);
    800035fe:	854e                	mv	a0,s3
    80003600:	ddbff0ef          	jal	800033da <iunlock>
      iput(ip);
    80003604:	854e                	mv	a0,s3
    80003606:	ea9ff0ef          	jal	800034ae <iput>
      end_op();
    8000360a:	027000ef          	jal	80003e30 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000360e:	0485                	addi	s1,s1,1
    80003610:	00ca2703          	lw	a4,12(s4)
    80003614:	0004879b          	sext.w	a5,s1
    80003618:	02e7fd63          	bgeu	a5,a4,80003652 <ireclaim+0xb2>
    8000361c:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003620:	0044d593          	srli	a1,s1,0x4
    80003624:	018a2783          	lw	a5,24(s4)
    80003628:	9dbd                	addw	a1,a1,a5
    8000362a:	8556                	mv	a0,s5
    8000362c:	e68ff0ef          	jal	80002c94 <bread>
    80003630:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003632:	05850793          	addi	a5,a0,88
    80003636:	00f9f713          	andi	a4,s3,15
    8000363a:	071a                	slli	a4,a4,0x6
    8000363c:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    8000363e:	00079703          	lh	a4,0(a5)
    80003642:	c701                	beqz	a4,8000364a <ireclaim+0xaa>
    80003644:	00679783          	lh	a5,6(a5)
    80003648:	dbc1                	beqz	a5,800035d8 <ireclaim+0x38>
    brelse(bp);
    8000364a:	854a                	mv	a0,s2
    8000364c:	f50ff0ef          	jal	80002d9c <brelse>
    if (ip) {
    80003650:	bf7d                	j	8000360e <ireclaim+0x6e>
}
    80003652:	70e2                	ld	ra,56(sp)
    80003654:	7442                	ld	s0,48(sp)
    80003656:	74a2                	ld	s1,40(sp)
    80003658:	7902                	ld	s2,32(sp)
    8000365a:	69e2                	ld	s3,24(sp)
    8000365c:	6a42                	ld	s4,16(sp)
    8000365e:	6aa2                	ld	s5,8(sp)
    80003660:	6b02                	ld	s6,0(sp)
    80003662:	6121                	addi	sp,sp,64
    80003664:	8082                	ret
    80003666:	8082                	ret

0000000080003668 <fsinit>:
{
    80003668:	1101                	addi	sp,sp,-32
    8000366a:	ec06                	sd	ra,24(sp)
    8000366c:	e822                	sd	s0,16(sp)
    8000366e:	e426                	sd	s1,8(sp)
    80003670:	e04a                	sd	s2,0(sp)
    80003672:	1000                	addi	s0,sp,32
    80003674:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003676:	4585                	li	a1,1
    80003678:	e1cff0ef          	jal	80002c94 <bread>
    8000367c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000367e:	02000613          	li	a2,32
    80003682:	05850593          	addi	a1,a0,88
    80003686:	0001d517          	auipc	a0,0x1d
    8000368a:	37a50513          	addi	a0,a0,890 # 80020a00 <sb>
    8000368e:	ebafd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    80003692:	8526                	mv	a0,s1
    80003694:	f08ff0ef          	jal	80002d9c <brelse>
  if (sb.magic != FSMAGIC)
    80003698:	0001d717          	auipc	a4,0x1d
    8000369c:	36872703          	lw	a4,872(a4) # 80020a00 <sb>
    800036a0:	102037b7          	lui	a5,0x10203
    800036a4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036a8:	02f71263          	bne	a4,a5,800036cc <fsinit+0x64>
  initlog(dev, &sb);
    800036ac:	0001d597          	auipc	a1,0x1d
    800036b0:	35458593          	addi	a1,a1,852 # 80020a00 <sb>
    800036b4:	854a                	mv	a0,s2
    800036b6:	66c000ef          	jal	80003d22 <initlog>
  ireclaim(dev);
    800036ba:	854a                	mv	a0,s2
    800036bc:	ee5ff0ef          	jal	800035a0 <ireclaim>
}
    800036c0:	60e2                	ld	ra,24(sp)
    800036c2:	6442                	ld	s0,16(sp)
    800036c4:	64a2                	ld	s1,8(sp)
    800036c6:	6902                	ld	s2,0(sp)
    800036c8:	6105                	addi	sp,sp,32
    800036ca:	8082                	ret
    panic("invalid file system");
    800036cc:	00004517          	auipc	a0,0x4
    800036d0:	e5450513          	addi	a0,a0,-428 # 80007520 <etext+0x520>
    800036d4:	960fd0ef          	jal	80000834 <panic>

00000000800036d8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800036d8:	1141                	addi	sp,sp,-16
    800036da:	e406                	sd	ra,8(sp)
    800036dc:	e022                	sd	s0,0(sp)
    800036de:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800036e0:	411c                	lw	a5,0(a0)
    800036e2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800036e4:	415c                	lw	a5,4(a0)
    800036e6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800036e8:	04451783          	lh	a5,68(a0)
    800036ec:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800036f0:	04a51783          	lh	a5,74(a0)
    800036f4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800036f8:	04c56783          	lwu	a5,76(a0)
    800036fc:	e99c                	sd	a5,16(a1)
}
    800036fe:	60a2                	ld	ra,8(sp)
    80003700:	6402                	ld	s0,0(sp)
    80003702:	0141                	addi	sp,sp,16
    80003704:	8082                	ret

0000000080003706 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003706:	457c                	lw	a5,76(a0)
    80003708:	0ed7e663          	bltu	a5,a3,800037f4 <readi+0xee>
{
    8000370c:	7159                	addi	sp,sp,-112
    8000370e:	f486                	sd	ra,104(sp)
    80003710:	f0a2                	sd	s0,96(sp)
    80003712:	eca6                	sd	s1,88(sp)
    80003714:	e0d2                	sd	s4,64(sp)
    80003716:	fc56                	sd	s5,56(sp)
    80003718:	f85a                	sd	s6,48(sp)
    8000371a:	f45e                	sd	s7,40(sp)
    8000371c:	1880                	addi	s0,sp,112
    8000371e:	8b2a                	mv	s6,a0
    80003720:	8bae                	mv	s7,a1
    80003722:	8a32                	mv	s4,a2
    80003724:	84b6                	mv	s1,a3
    80003726:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003728:	9f35                	addw	a4,a4,a3
    return 0;
    8000372a:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    8000372c:	0ad76b63          	bltu	a4,a3,800037e2 <readi+0xdc>
    80003730:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003732:	00e7f463          	bgeu	a5,a4,8000373a <readi+0x34>
    n = ip->size - off;
    80003736:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000373a:	080a8b63          	beqz	s5,800037d0 <readi+0xca>
    8000373e:	e8ca                	sd	s2,80(sp)
    80003740:	f062                	sd	s8,32(sp)
    80003742:	ec66                	sd	s9,24(sp)
    80003744:	e86a                	sd	s10,16(sp)
    80003746:	e46e                	sd	s11,8(sp)
    80003748:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000374a:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000374e:	5c7d                	li	s8,-1
    80003750:	a80d                	j	80003782 <readi+0x7c>
    80003752:	020d1d93          	slli	s11,s10,0x20
    80003756:	020ddd93          	srli	s11,s11,0x20
    8000375a:	05890613          	addi	a2,s2,88
    8000375e:	86ee                	mv	a3,s11
    80003760:	963e                	add	a2,a2,a5
    80003762:	85d2                	mv	a1,s4
    80003764:	855e                	mv	a0,s7
    80003766:	c1ffe0ef          	jal	80002384 <either_copyout>
    8000376a:	05850363          	beq	a0,s8,800037b0 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000376e:	854a                	mv	a0,s2
    80003770:	e2cff0ef          	jal	80002d9c <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003774:	013d09bb          	addw	s3,s10,s3
    80003778:	009d04bb          	addw	s1,s10,s1
    8000377c:	9a6e                	add	s4,s4,s11
    8000377e:	0559f363          	bgeu	s3,s5,800037c4 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    80003782:	00a4d59b          	srliw	a1,s1,0xa
    80003786:	855a                	mv	a0,s6
    80003788:	873ff0ef          	jal	80002ffa <bmap>
    8000378c:	85aa                	mv	a1,a0
    if (addr == 0)
    8000378e:	c139                	beqz	a0,800037d4 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003790:	000b2503          	lw	a0,0(s6)
    80003794:	d00ff0ef          	jal	80002c94 <bread>
    80003798:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000379a:	3ff4f793          	andi	a5,s1,1023
    8000379e:	40fc873b          	subw	a4,s9,a5
    800037a2:	413a86bb          	subw	a3,s5,s3
    800037a6:	8d3a                	mv	s10,a4
    800037a8:	fae6f5e3          	bgeu	a3,a4,80003752 <readi+0x4c>
    800037ac:	8d36                	mv	s10,a3
    800037ae:	b755                	j	80003752 <readi+0x4c>
      brelse(bp);
    800037b0:	854a                	mv	a0,s2
    800037b2:	deaff0ef          	jal	80002d9c <brelse>
      tot = -1;
    800037b6:	59fd                	li	s3,-1
      break;
    800037b8:	6946                	ld	s2,80(sp)
    800037ba:	7c02                	ld	s8,32(sp)
    800037bc:	6ce2                	ld	s9,24(sp)
    800037be:	6d42                	ld	s10,16(sp)
    800037c0:	6da2                	ld	s11,8(sp)
    800037c2:	a831                	j	800037de <readi+0xd8>
    800037c4:	6946                	ld	s2,80(sp)
    800037c6:	7c02                	ld	s8,32(sp)
    800037c8:	6ce2                	ld	s9,24(sp)
    800037ca:	6d42                	ld	s10,16(sp)
    800037cc:	6da2                	ld	s11,8(sp)
    800037ce:	a801                	j	800037de <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800037d0:	89d6                	mv	s3,s5
    800037d2:	a031                	j	800037de <readi+0xd8>
    800037d4:	6946                	ld	s2,80(sp)
    800037d6:	7c02                	ld	s8,32(sp)
    800037d8:	6ce2                	ld	s9,24(sp)
    800037da:	6d42                	ld	s10,16(sp)
    800037dc:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800037de:	854e                	mv	a0,s3
    800037e0:	69a6                	ld	s3,72(sp)
}
    800037e2:	70a6                	ld	ra,104(sp)
    800037e4:	7406                	ld	s0,96(sp)
    800037e6:	64e6                	ld	s1,88(sp)
    800037e8:	6a06                	ld	s4,64(sp)
    800037ea:	7ae2                	ld	s5,56(sp)
    800037ec:	7b42                	ld	s6,48(sp)
    800037ee:	7ba2                	ld	s7,40(sp)
    800037f0:	6165                	addi	sp,sp,112
    800037f2:	8082                	ret
    return 0;
    800037f4:	4501                	li	a0,0
}
    800037f6:	8082                	ret

00000000800037f8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800037f8:	457c                	lw	a5,76(a0)
    800037fa:	0ed7ee63          	bltu	a5,a3,800038f6 <writei+0xfe>
{
    800037fe:	7159                	addi	sp,sp,-112
    80003800:	f486                	sd	ra,104(sp)
    80003802:	f0a2                	sd	s0,96(sp)
    80003804:	e8ca                	sd	s2,80(sp)
    80003806:	e0d2                	sd	s4,64(sp)
    80003808:	fc56                	sd	s5,56(sp)
    8000380a:	f85a                	sd	s6,48(sp)
    8000380c:	f45e                	sd	s7,40(sp)
    8000380e:	1880                	addi	s0,sp,112
    80003810:	8aaa                	mv	s5,a0
    80003812:	8bae                	mv	s7,a1
    80003814:	8a32                	mv	s4,a2
    80003816:	8936                	mv	s2,a3
    80003818:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    8000381a:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    8000381e:	00043737          	lui	a4,0x43
    80003822:	0cf76c63          	bltu	a4,a5,800038fa <writei+0x102>
    80003826:	0cd7ea63          	bltu	a5,a3,800038fa <writei+0x102>
    8000382a:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000382c:	0a0b0d63          	beqz	s6,800038e6 <writei+0xee>
    80003830:	eca6                	sd	s1,88(sp)
    80003832:	f062                	sd	s8,32(sp)
    80003834:	ec66                	sd	s9,24(sp)
    80003836:	e86a                	sd	s10,16(sp)
    80003838:	e46e                	sd	s11,8(sp)
    8000383a:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000383c:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003840:	5c7d                	li	s8,-1
    80003842:	a825                	j	8000387a <writei+0x82>
    80003844:	020d1d93          	slli	s11,s10,0x20
    80003848:	020ddd93          	srli	s11,s11,0x20
    8000384c:	05848513          	addi	a0,s1,88
    80003850:	86ee                	mv	a3,s11
    80003852:	8652                	mv	a2,s4
    80003854:	85de                	mv	a1,s7
    80003856:	953e                	add	a0,a0,a5
    80003858:	b79fe0ef          	jal	800023d0 <either_copyin>
    8000385c:	05850663          	beq	a0,s8,800038a8 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003860:	8526                	mv	a0,s1
    80003862:	6f0000ef          	jal	80003f52 <log_write>
    brelse(bp);
    80003866:	8526                	mv	a0,s1
    80003868:	d34ff0ef          	jal	80002d9c <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000386c:	013d09bb          	addw	s3,s10,s3
    80003870:	012d093b          	addw	s2,s10,s2
    80003874:	9a6e                	add	s4,s4,s11
    80003876:	0369ff63          	bgeu	s3,s6,800038b4 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    8000387a:	00a9559b          	srliw	a1,s2,0xa
    8000387e:	8556                	mv	a0,s5
    80003880:	f7aff0ef          	jal	80002ffa <bmap>
    80003884:	85aa                	mv	a1,a0
    if (addr == 0)
    80003886:	c51d                	beqz	a0,800038b4 <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003888:	000aa503          	lw	a0,0(s5)
    8000388c:	c08ff0ef          	jal	80002c94 <bread>
    80003890:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003892:	3ff97793          	andi	a5,s2,1023
    80003896:	40fc873b          	subw	a4,s9,a5
    8000389a:	413b06bb          	subw	a3,s6,s3
    8000389e:	8d3a                	mv	s10,a4
    800038a0:	fae6f2e3          	bgeu	a3,a4,80003844 <writei+0x4c>
    800038a4:	8d36                	mv	s10,a3
    800038a6:	bf79                	j	80003844 <writei+0x4c>
      log_write(bp);
    800038a8:	8526                	mv	a0,s1
    800038aa:	6a8000ef          	jal	80003f52 <log_write>
      brelse(bp);
    800038ae:	8526                	mv	a0,s1
    800038b0:	cecff0ef          	jal	80002d9c <brelse>
  }

  if (off > ip->size)
    800038b4:	04caa783          	lw	a5,76(s5)
    800038b8:	0327f963          	bgeu	a5,s2,800038ea <writei+0xf2>
    ip->size = off;
    800038bc:	052aa623          	sw	s2,76(s5)
    800038c0:	64e6                	ld	s1,88(sp)
    800038c2:	7c02                	ld	s8,32(sp)
    800038c4:	6ce2                	ld	s9,24(sp)
    800038c6:	6d42                	ld	s10,16(sp)
    800038c8:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800038ca:	8556                	mv	a0,s5
    800038cc:	9adff0ef          	jal	80003278 <iupdate>

  return tot;
    800038d0:	854e                	mv	a0,s3
    800038d2:	69a6                	ld	s3,72(sp)
}
    800038d4:	70a6                	ld	ra,104(sp)
    800038d6:	7406                	ld	s0,96(sp)
    800038d8:	6946                	ld	s2,80(sp)
    800038da:	6a06                	ld	s4,64(sp)
    800038dc:	7ae2                	ld	s5,56(sp)
    800038de:	7b42                	ld	s6,48(sp)
    800038e0:	7ba2                	ld	s7,40(sp)
    800038e2:	6165                	addi	sp,sp,112
    800038e4:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800038e6:	89da                	mv	s3,s6
    800038e8:	b7cd                	j	800038ca <writei+0xd2>
    800038ea:	64e6                	ld	s1,88(sp)
    800038ec:	7c02                	ld	s8,32(sp)
    800038ee:	6ce2                	ld	s9,24(sp)
    800038f0:	6d42                	ld	s10,16(sp)
    800038f2:	6da2                	ld	s11,8(sp)
    800038f4:	bfd9                	j	800038ca <writei+0xd2>
    return -1;
    800038f6:	557d                	li	a0,-1
}
    800038f8:	8082                	ret
    return -1;
    800038fa:	557d                	li	a0,-1
    800038fc:	bfe1                	j	800038d4 <writei+0xdc>

00000000800038fe <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800038fe:	1141                	addi	sp,sp,-16
    80003900:	e406                	sd	ra,8(sp)
    80003902:	e022                	sd	s0,0(sp)
    80003904:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003906:	4639                	li	a2,14
    80003908:	cb4fd0ef          	jal	80000dbc <strncmp>
}
    8000390c:	60a2                	ld	ra,8(sp)
    8000390e:	6402                	ld	s0,0(sp)
    80003910:	0141                	addi	sp,sp,16
    80003912:	8082                	ret

0000000080003914 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003914:	711d                	addi	sp,sp,-96
    80003916:	ec86                	sd	ra,88(sp)
    80003918:	e8a2                	sd	s0,80(sp)
    8000391a:	e4a6                	sd	s1,72(sp)
    8000391c:	e0ca                	sd	s2,64(sp)
    8000391e:	fc4e                	sd	s3,56(sp)
    80003920:	f852                	sd	s4,48(sp)
    80003922:	f456                	sd	s5,40(sp)
    80003924:	f05a                	sd	s6,32(sp)
    80003926:	ec5e                	sd	s7,24(sp)
    80003928:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    8000392a:	04451703          	lh	a4,68(a0)
    8000392e:	4785                	li	a5,1
    80003930:	00f71f63          	bne	a4,a5,8000394e <dirlookup+0x3a>
    80003934:	892a                	mv	s2,a0
    80003936:	8aae                	mv	s5,a1
    80003938:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000393a:	457c                	lw	a5,76(a0)
    8000393c:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000393e:	fa040a13          	addi	s4,s0,-96
    80003942:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003944:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003948:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000394a:	e39d                	bnez	a5,80003970 <dirlookup+0x5c>
    8000394c:	a8b9                	j	800039aa <dirlookup+0x96>
    panic("dirlookup not DIR");
    8000394e:	00004517          	auipc	a0,0x4
    80003952:	bea50513          	addi	a0,a0,-1046 # 80007538 <etext+0x538>
    80003956:	edffc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    8000395a:	00004517          	auipc	a0,0x4
    8000395e:	bf650513          	addi	a0,a0,-1034 # 80007550 <etext+0x550>
    80003962:	ed3fc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003966:	24c1                	addiw	s1,s1,16
    80003968:	04c92783          	lw	a5,76(s2)
    8000396c:	02f4fe63          	bgeu	s1,a5,800039a8 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003970:	874e                	mv	a4,s3
    80003972:	86a6                	mv	a3,s1
    80003974:	8652                	mv	a2,s4
    80003976:	4581                	li	a1,0
    80003978:	854a                	mv	a0,s2
    8000397a:	d8dff0ef          	jal	80003706 <readi>
    8000397e:	fd351ee3          	bne	a0,s3,8000395a <dirlookup+0x46>
    if (de.inum == 0)
    80003982:	fa045783          	lhu	a5,-96(s0)
    80003986:	d3e5                	beqz	a5,80003966 <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003988:	85da                	mv	a1,s6
    8000398a:	8556                	mv	a0,s5
    8000398c:	f73ff0ef          	jal	800038fe <namecmp>
    80003990:	f979                	bnez	a0,80003966 <dirlookup+0x52>
      if (poff)
    80003992:	000b8463          	beqz	s7,8000399a <dirlookup+0x86>
        *poff = off;
    80003996:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    8000399a:	fa045583          	lhu	a1,-96(s0)
    8000399e:	00092503          	lw	a0,0(s2)
    800039a2:	f18ff0ef          	jal	800030ba <iget>
    800039a6:	a011                	j	800039aa <dirlookup+0x96>
  return 0;
    800039a8:	4501                	li	a0,0
}
    800039aa:	60e6                	ld	ra,88(sp)
    800039ac:	6446                	ld	s0,80(sp)
    800039ae:	64a6                	ld	s1,72(sp)
    800039b0:	6906                	ld	s2,64(sp)
    800039b2:	79e2                	ld	s3,56(sp)
    800039b4:	7a42                	ld	s4,48(sp)
    800039b6:	7aa2                	ld	s5,40(sp)
    800039b8:	7b02                	ld	s6,32(sp)
    800039ba:	6be2                	ld	s7,24(sp)
    800039bc:	6125                	addi	sp,sp,96
    800039be:	8082                	ret

00000000800039c0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    800039c0:	711d                	addi	sp,sp,-96
    800039c2:	ec86                	sd	ra,88(sp)
    800039c4:	e8a2                	sd	s0,80(sp)
    800039c6:	e4a6                	sd	s1,72(sp)
    800039c8:	e0ca                	sd	s2,64(sp)
    800039ca:	fc4e                	sd	s3,56(sp)
    800039cc:	f852                	sd	s4,48(sp)
    800039ce:	f456                	sd	s5,40(sp)
    800039d0:	f05a                	sd	s6,32(sp)
    800039d2:	ec5e                	sd	s7,24(sp)
    800039d4:	e862                	sd	s8,16(sp)
    800039d6:	e466                	sd	s9,8(sp)
    800039d8:	e06a                	sd	s10,0(sp)
    800039da:	1080                	addi	s0,sp,96
    800039dc:	84aa                	mv	s1,a0
    800039de:	8b2e                	mv	s6,a1
    800039e0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    800039e2:	00054703          	lbu	a4,0(a0)
    800039e6:	02f00793          	li	a5,47
    800039ea:	00f70f63          	beq	a4,a5,80003a08 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800039ee:	ffbfd0ef          	jal	800019e8 <myproc>
    800039f2:	15053503          	ld	a0,336(a0)
    800039f6:	901ff0ef          	jal	800032f6 <idup>
    800039fa:	8a2a                	mv	s4,a0
  while (*path == '/')
    800039fc:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003a00:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003a02:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003a04:	4b85                	li	s7,1
    80003a06:	a07d                	j	80003ab4 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003a08:	4585                	li	a1,1
    80003a0a:	852e                	mv	a0,a1
    80003a0c:	eaeff0ef          	jal	800030ba <iget>
    80003a10:	8a2a                	mv	s4,a0
    80003a12:	b7ed                	j	800039fc <namex+0x3c>
      iunlockput(ip);
    80003a14:	8552                	mv	a0,s4
    80003a16:	b6bff0ef          	jal	80003580 <iunlockput>
      return 0;
    80003a1a:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a1c:	8552                	mv	a0,s4
    80003a1e:	60e6                	ld	ra,88(sp)
    80003a20:	6446                	ld	s0,80(sp)
    80003a22:	64a6                	ld	s1,72(sp)
    80003a24:	6906                	ld	s2,64(sp)
    80003a26:	79e2                	ld	s3,56(sp)
    80003a28:	7a42                	ld	s4,48(sp)
    80003a2a:	7aa2                	ld	s5,40(sp)
    80003a2c:	7b02                	ld	s6,32(sp)
    80003a2e:	6be2                	ld	s7,24(sp)
    80003a30:	6c42                	ld	s8,16(sp)
    80003a32:	6ca2                	ld	s9,8(sp)
    80003a34:	6d02                	ld	s10,0(sp)
    80003a36:	6125                	addi	sp,sp,96
    80003a38:	8082                	ret
      iunlockput(ip);
    80003a3a:	8552                	mv	a0,s4
    80003a3c:	b45ff0ef          	jal	80003580 <iunlockput>
      return 0;
    80003a40:	4a01                	li	s4,0
    80003a42:	bfe9                	j	80003a1c <namex+0x5c>
      iunlock(ip);
    80003a44:	8552                	mv	a0,s4
    80003a46:	995ff0ef          	jal	800033da <iunlock>
      return ip;
    80003a4a:	bfc9                	j	80003a1c <namex+0x5c>
      iunlockput(ip);
    80003a4c:	8552                	mv	a0,s4
    80003a4e:	b33ff0ef          	jal	80003580 <iunlockput>
      return 0;
    80003a52:	8a4a                	mv	s4,s2
    80003a54:	b7e1                	j	80003a1c <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003a56:	8926                	mv	s2,s1
  len = path - s;
    80003a58:	4d01                	li	s10,0
    80003a5a:	4601                	li	a2,0
    memmove(name, s, len);
    80003a5c:	2601                	sext.w	a2,a2
    80003a5e:	85a6                	mv	a1,s1
    80003a60:	8556                	mv	a0,s5
    80003a62:	ae6fd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003a66:	9d56                	add	s10,s10,s5
    80003a68:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb8f8>
  while (*path == '/')
    80003a6c:	00094783          	lbu	a5,0(s2)
    80003a70:	09379b63          	bne	a5,s3,80003b06 <namex+0x146>
    80003a74:	84ca                	mv	s1,s2
    path++;
    80003a76:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003a78:	0004c783          	lbu	a5,0(s1)
    80003a7c:	ff378de3          	beq	a5,s3,80003a76 <namex+0xb6>
    ilock(ip);
    80003a80:	8552                	mv	a0,s4
    80003a82:	8abff0ef          	jal	8000332c <ilock>
    if (ip->type != T_DIR) {
    80003a86:	044a1783          	lh	a5,68(s4)
    80003a8a:	f97795e3          	bne	a5,s7,80003a14 <namex+0x54>
    if (ip->nlink == 0) {
    80003a8e:	04aa1783          	lh	a5,74(s4)
    80003a92:	d7c5                	beqz	a5,80003a3a <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003a94:	000b0563          	beqz	s6,80003a9e <namex+0xde>
    80003a98:	0004c783          	lbu	a5,0(s1)
    80003a9c:	d7c5                	beqz	a5,80003a44 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003a9e:	4601                	li	a2,0
    80003aa0:	85d6                	mv	a1,s5
    80003aa2:	8552                	mv	a0,s4
    80003aa4:	e71ff0ef          	jal	80003914 <dirlookup>
    80003aa8:	892a                	mv	s2,a0
    80003aaa:	d14d                	beqz	a0,80003a4c <namex+0x8c>
    iunlockput(ip);
    80003aac:	8552                	mv	a0,s4
    80003aae:	ad3ff0ef          	jal	80003580 <iunlockput>
    ip = next;
    80003ab2:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003ab4:	0004c783          	lbu	a5,0(s1)
    80003ab8:	01379763          	bne	a5,s3,80003ac6 <namex+0x106>
    path++;
    80003abc:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003abe:	0004c783          	lbu	a5,0(s1)
    80003ac2:	ff378de3          	beq	a5,s3,80003abc <namex+0xfc>
  if (*path == 0)
    80003ac6:	c7a1                	beqz	a5,80003b0e <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003ac8:	0004c783          	lbu	a5,0(s1)
    80003acc:	fd178713          	addi	a4,a5,-47
    80003ad0:	d359                	beqz	a4,80003a56 <namex+0x96>
    80003ad2:	d3d1                	beqz	a5,80003a56 <namex+0x96>
    80003ad4:	8926                	mv	s2,s1
    path++;
    80003ad6:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003ad8:	00094783          	lbu	a5,0(s2)
    80003adc:	fd178713          	addi	a4,a5,-47
    80003ae0:	c311                	beqz	a4,80003ae4 <namex+0x124>
    80003ae2:	fbf5                	bnez	a5,80003ad6 <namex+0x116>
  len = path - s;
    80003ae4:	40990633          	sub	a2,s2,s1
    80003ae8:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003aec:	f7ac58e3          	bge	s8,s10,80003a5c <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003af0:	8666                	mv	a2,s9
    80003af2:	85a6                	mv	a1,s1
    80003af4:	8556                	mv	a0,s5
    80003af6:	a52fd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003afa:	00094783          	lbu	a5,0(s2)
    80003afe:	84ca                	mv	s1,s2
    80003b00:	f7378be3          	beq	a5,s3,80003a76 <namex+0xb6>
    80003b04:	bfb5                	j	80003a80 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003b06:	00090463          	beqz	s2,80003b0e <namex+0x14e>
    80003b0a:	84ca                	mv	s1,s2
    80003b0c:	bf95                	j	80003a80 <namex+0xc0>
  if (nameiparent) {
    80003b0e:	f00b07e3          	beqz	s6,80003a1c <namex+0x5c>
    iput(ip);
    80003b12:	8552                	mv	a0,s4
    80003b14:	99bff0ef          	jal	800034ae <iput>
    return 0;
    80003b18:	4a01                	li	s4,0
    80003b1a:	b709                	j	80003a1c <namex+0x5c>

0000000080003b1c <dirlink>:
{
    80003b1c:	715d                	addi	sp,sp,-80
    80003b1e:	e486                	sd	ra,72(sp)
    80003b20:	e0a2                	sd	s0,64(sp)
    80003b22:	f84a                	sd	s2,48(sp)
    80003b24:	ec56                	sd	s5,24(sp)
    80003b26:	e85a                	sd	s6,16(sp)
    80003b28:	0880                	addi	s0,sp,80
    80003b2a:	892a                	mv	s2,a0
    80003b2c:	8aae                	mv	s5,a1
    80003b2e:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003b30:	4601                	li	a2,0
    80003b32:	de3ff0ef          	jal	80003914 <dirlookup>
    80003b36:	ed1d                	bnez	a0,80003b74 <dirlink+0x58>
    80003b38:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003b3a:	04c92483          	lw	s1,76(s2)
    80003b3e:	c4b9                	beqz	s1,80003b8c <dirlink+0x70>
    80003b40:	f44e                	sd	s3,40(sp)
    80003b42:	f052                	sd	s4,32(sp)
    80003b44:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b46:	fb040a13          	addi	s4,s0,-80
    80003b4a:	49c1                	li	s3,16
    80003b4c:	874e                	mv	a4,s3
    80003b4e:	86a6                	mv	a3,s1
    80003b50:	8652                	mv	a2,s4
    80003b52:	4581                	li	a1,0
    80003b54:	854a                	mv	a0,s2
    80003b56:	bb1ff0ef          	jal	80003706 <readi>
    80003b5a:	03351163          	bne	a0,s3,80003b7c <dirlink+0x60>
    if (de.inum == 0)
    80003b5e:	fb045783          	lhu	a5,-80(s0)
    80003b62:	c39d                	beqz	a5,80003b88 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003b64:	24c1                	addiw	s1,s1,16
    80003b66:	04c92783          	lw	a5,76(s2)
    80003b6a:	fef4e1e3          	bltu	s1,a5,80003b4c <dirlink+0x30>
    80003b6e:	79a2                	ld	s3,40(sp)
    80003b70:	7a02                	ld	s4,32(sp)
    80003b72:	a829                	j	80003b8c <dirlink+0x70>
    iput(ip);
    80003b74:	93bff0ef          	jal	800034ae <iput>
    return -1;
    80003b78:	557d                	li	a0,-1
    80003b7a:	a83d                	j	80003bb8 <dirlink+0x9c>
      panic("dirlink read");
    80003b7c:	00004517          	auipc	a0,0x4
    80003b80:	9e450513          	addi	a0,a0,-1564 # 80007560 <etext+0x560>
    80003b84:	cb1fc0ef          	jal	80000834 <panic>
    80003b88:	79a2                	ld	s3,40(sp)
    80003b8a:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003b8c:	4639                	li	a2,14
    80003b8e:	85d6                	mv	a1,s5
    80003b90:	fb240513          	addi	a0,s0,-78
    80003b94:	a62fd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003b98:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b9c:	4741                	li	a4,16
    80003b9e:	86a6                	mv	a3,s1
    80003ba0:	fb040613          	addi	a2,s0,-80
    80003ba4:	4581                	li	a1,0
    80003ba6:	854a                	mv	a0,s2
    80003ba8:	c51ff0ef          	jal	800037f8 <writei>
    80003bac:	1541                	addi	a0,a0,-16
    80003bae:	00a03533          	snez	a0,a0
    80003bb2:	40a0053b          	negw	a0,a0
    80003bb6:	74e2                	ld	s1,56(sp)
}
    80003bb8:	60a6                	ld	ra,72(sp)
    80003bba:	6406                	ld	s0,64(sp)
    80003bbc:	7942                	ld	s2,48(sp)
    80003bbe:	6ae2                	ld	s5,24(sp)
    80003bc0:	6b42                	ld	s6,16(sp)
    80003bc2:	6161                	addi	sp,sp,80
    80003bc4:	8082                	ret

0000000080003bc6 <namei>:

struct inode *
namei(char *path)
{
    80003bc6:	1101                	addi	sp,sp,-32
    80003bc8:	ec06                	sd	ra,24(sp)
    80003bca:	e822                	sd	s0,16(sp)
    80003bcc:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003bce:	fe040613          	addi	a2,s0,-32
    80003bd2:	4581                	li	a1,0
    80003bd4:	dedff0ef          	jal	800039c0 <namex>
}
    80003bd8:	60e2                	ld	ra,24(sp)
    80003bda:	6442                	ld	s0,16(sp)
    80003bdc:	6105                	addi	sp,sp,32
    80003bde:	8082                	ret

0000000080003be0 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003be0:	1141                	addi	sp,sp,-16
    80003be2:	e406                	sd	ra,8(sp)
    80003be4:	e022                	sd	s0,0(sp)
    80003be6:	0800                	addi	s0,sp,16
    80003be8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003bea:	4585                	li	a1,1
    80003bec:	dd5ff0ef          	jal	800039c0 <namex>
}
    80003bf0:	60a2                	ld	ra,8(sp)
    80003bf2:	6402                	ld	s0,0(sp)
    80003bf4:	0141                	addi	sp,sp,16
    80003bf6:	8082                	ret

0000000080003bf8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003bf8:	1101                	addi	sp,sp,-32
    80003bfa:	ec06                	sd	ra,24(sp)
    80003bfc:	e822                	sd	s0,16(sp)
    80003bfe:	e426                	sd	s1,8(sp)
    80003c00:	e04a                	sd	s2,0(sp)
    80003c02:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c04:	0001f917          	auipc	s2,0x1f
    80003c08:	8c490913          	addi	s2,s2,-1852 # 800224c8 <log>
    80003c0c:	01892583          	lw	a1,24(s2)
    80003c10:	02492503          	lw	a0,36(s2)
    80003c14:	880ff0ef          	jal	80002c94 <bread>
    80003c18:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003c1a:	02c92603          	lw	a2,44(s2)
    80003c1e:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c20:	00c05f63          	blez	a2,80003c3e <write_head+0x46>
    80003c24:	0001f717          	auipc	a4,0x1f
    80003c28:	8d470713          	addi	a4,a4,-1836 # 800224f8 <log+0x30>
    80003c2c:	87aa                	mv	a5,a0
    80003c2e:	060a                	slli	a2,a2,0x2
    80003c30:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003c32:	4314                	lw	a3,0(a4)
    80003c34:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003c36:	0711                	addi	a4,a4,4
    80003c38:	0791                	addi	a5,a5,4
    80003c3a:	fec79ce3          	bne	a5,a2,80003c32 <write_head+0x3a>
  }
  bwrite(buf);
    80003c3e:	8526                	mv	a0,s1
    80003c40:	92aff0ef          	jal	80002d6a <bwrite>
  brelse(buf);
    80003c44:	8526                	mv	a0,s1
    80003c46:	956ff0ef          	jal	80002d9c <brelse>
}
    80003c4a:	60e2                	ld	ra,24(sp)
    80003c4c:	6442                	ld	s0,16(sp)
    80003c4e:	64a2                	ld	s1,8(sp)
    80003c50:	6902                	ld	s2,0(sp)
    80003c52:	6105                	addi	sp,sp,32
    80003c54:	8082                	ret

0000000080003c56 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c56:	0001f797          	auipc	a5,0x1f
    80003c5a:	89e7a783          	lw	a5,-1890(a5) # 800224f4 <log+0x2c>
    80003c5e:	0cf05163          	blez	a5,80003d20 <install_trans+0xca>
{
    80003c62:	715d                	addi	sp,sp,-80
    80003c64:	e486                	sd	ra,72(sp)
    80003c66:	e0a2                	sd	s0,64(sp)
    80003c68:	fc26                	sd	s1,56(sp)
    80003c6a:	f84a                	sd	s2,48(sp)
    80003c6c:	f44e                	sd	s3,40(sp)
    80003c6e:	f052                	sd	s4,32(sp)
    80003c70:	ec56                	sd	s5,24(sp)
    80003c72:	e85a                	sd	s6,16(sp)
    80003c74:	e45e                	sd	s7,8(sp)
    80003c76:	e062                	sd	s8,0(sp)
    80003c78:	0880                	addi	s0,sp,80
    80003c7a:	8b2a                	mv	s6,a0
    80003c7c:	0001fa97          	auipc	s5,0x1f
    80003c80:	87ca8a93          	addi	s5,s5,-1924 # 800224f8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c84:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c86:	00004c17          	auipc	s8,0x4
    80003c8a:	8eac0c13          	addi	s8,s8,-1814 # 80007570 <etext+0x570>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003c8e:	0001fa17          	auipc	s4,0x1f
    80003c92:	83aa0a13          	addi	s4,s4,-1990 # 800224c8 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003c96:	40000b93          	li	s7,1024
    80003c9a:	a025                	j	80003cc2 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c9c:	000aa603          	lw	a2,0(s5)
    80003ca0:	85ce                	mv	a1,s3
    80003ca2:	8562                	mv	a0,s8
    80003ca4:	867fc0ef          	jal	8000050a <printk>
    80003ca8:	a839                	j	80003cc6 <install_trans+0x70>
    brelse(lbuf);
    80003caa:	854a                	mv	a0,s2
    80003cac:	8f0ff0ef          	jal	80002d9c <brelse>
    brelse(dbuf);
    80003cb0:	8526                	mv	a0,s1
    80003cb2:	8eaff0ef          	jal	80002d9c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cb6:	2985                	addiw	s3,s3,1
    80003cb8:	0a91                	addi	s5,s5,4
    80003cba:	02ca2783          	lw	a5,44(s4)
    80003cbe:	04f9d563          	bge	s3,a5,80003d08 <install_trans+0xb2>
    if (recovering) {
    80003cc2:	fc0b1de3          	bnez	s6,80003c9c <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003cc6:	018a2583          	lw	a1,24(s4)
    80003cca:	013585bb          	addw	a1,a1,s3
    80003cce:	2585                	addiw	a1,a1,1
    80003cd0:	024a2503          	lw	a0,36(s4)
    80003cd4:	fc1fe0ef          	jal	80002c94 <bread>
    80003cd8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003cda:	000aa583          	lw	a1,0(s5)
    80003cde:	024a2503          	lw	a0,36(s4)
    80003ce2:	fb3fe0ef          	jal	80002c94 <bread>
    80003ce6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003ce8:	865e                	mv	a2,s7
    80003cea:	05890593          	addi	a1,s2,88
    80003cee:	05850513          	addi	a0,a0,88
    80003cf2:	856fd0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003cf6:	8526                	mv	a0,s1
    80003cf8:	872ff0ef          	jal	80002d6a <bwrite>
    if (recovering == 0)
    80003cfc:	fa0b17e3          	bnez	s6,80003caa <install_trans+0x54>
      bunpin(dbuf);
    80003d00:	8526                	mv	a0,s1
    80003d02:	952ff0ef          	jal	80002e54 <bunpin>
    80003d06:	b755                	j	80003caa <install_trans+0x54>
}
    80003d08:	60a6                	ld	ra,72(sp)
    80003d0a:	6406                	ld	s0,64(sp)
    80003d0c:	74e2                	ld	s1,56(sp)
    80003d0e:	7942                	ld	s2,48(sp)
    80003d10:	79a2                	ld	s3,40(sp)
    80003d12:	7a02                	ld	s4,32(sp)
    80003d14:	6ae2                	ld	s5,24(sp)
    80003d16:	6b42                	ld	s6,16(sp)
    80003d18:	6ba2                	ld	s7,8(sp)
    80003d1a:	6c02                	ld	s8,0(sp)
    80003d1c:	6161                	addi	sp,sp,80
    80003d1e:	8082                	ret
    80003d20:	8082                	ret

0000000080003d22 <initlog>:
{
    80003d22:	7179                	addi	sp,sp,-48
    80003d24:	f406                	sd	ra,40(sp)
    80003d26:	f022                	sd	s0,32(sp)
    80003d28:	ec26                	sd	s1,24(sp)
    80003d2a:	e84a                	sd	s2,16(sp)
    80003d2c:	e44e                	sd	s3,8(sp)
    80003d2e:	1800                	addi	s0,sp,48
    80003d30:	84aa                	mv	s1,a0
    80003d32:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d34:	0001e917          	auipc	s2,0x1e
    80003d38:	79490913          	addi	s2,s2,1940 # 800224c8 <log>
    80003d3c:	00004597          	auipc	a1,0x4
    80003d40:	85458593          	addi	a1,a1,-1964 # 80007590 <etext+0x590>
    80003d44:	854a                	mv	a0,s2
    80003d46:	e63fc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003d4a:	0149a583          	lw	a1,20(s3)
    80003d4e:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003d52:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003d56:	8526                	mv	a0,s1
    80003d58:	f3dfe0ef          	jal	80002c94 <bread>
  log.lh.n = lh->n;
    80003d5c:	4d30                	lw	a2,88(a0)
    80003d5e:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003d62:	00c05f63          	blez	a2,80003d80 <initlog+0x5e>
    80003d66:	87aa                	mv	a5,a0
    80003d68:	0001e717          	auipc	a4,0x1e
    80003d6c:	79070713          	addi	a4,a4,1936 # 800224f8 <log+0x30>
    80003d70:	060a                	slli	a2,a2,0x2
    80003d72:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003d74:	4ff4                	lw	a3,92(a5)
    80003d76:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003d78:	0791                	addi	a5,a5,4
    80003d7a:	0711                	addi	a4,a4,4
    80003d7c:	fec79ce3          	bne	a5,a2,80003d74 <initlog+0x52>
  brelse(buf);
    80003d80:	81cff0ef          	jal	80002d9c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d84:	4505                	li	a0,1
    80003d86:	ed1ff0ef          	jal	80003c56 <install_trans>
  log.lh.n = 0;
    80003d8a:	0001e797          	auipc	a5,0x1e
    80003d8e:	7607a523          	sw	zero,1898(a5) # 800224f4 <log+0x2c>
  write_head(); // clear the log
    80003d92:	e67ff0ef          	jal	80003bf8 <write_head>
}
    80003d96:	70a2                	ld	ra,40(sp)
    80003d98:	7402                	ld	s0,32(sp)
    80003d9a:	64e2                	ld	s1,24(sp)
    80003d9c:	6942                	ld	s2,16(sp)
    80003d9e:	69a2                	ld	s3,8(sp)
    80003da0:	6145                	addi	sp,sp,48
    80003da2:	8082                	ret

0000000080003da4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003da4:	1101                	addi	sp,sp,-32
    80003da6:	ec06                	sd	ra,24(sp)
    80003da8:	e822                	sd	s0,16(sp)
    80003daa:	e426                	sd	s1,8(sp)
    80003dac:	e04a                	sd	s2,0(sp)
    80003dae:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003db0:	0001e517          	auipc	a0,0x1e
    80003db4:	71850513          	addi	a0,a0,1816 # 800224c8 <log>
    80003db8:	e71fc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80003dbc:	0001e497          	auipc	s1,0x1e
    80003dc0:	70c48493          	addi	s1,s1,1804 # 800224c8 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003dc4:	4979                	li	s2,30
    80003dc6:	a821                	j	80003dde <begin_op+0x3a>
      sleep_prepare(&log);
    80003dc8:	8526                	mv	a0,s1
    80003dca:	a28fe0ef          	jal	80001ff2 <sleep_prepare>
      release(&log.lock);
    80003dce:	8526                	mv	a0,s1
    80003dd0:	ee1fc0ef          	jal	80000cb0 <release>
      sleep();
    80003dd4:	a5afe0ef          	jal	8000202e <sleep>
      acquire(&log.lock);
    80003dd8:	8526                	mv	a0,s1
    80003dda:	e4ffc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80003dde:	509c                	lw	a5,32(s1)
    80003de0:	f7e5                	bnez	a5,80003dc8 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003de2:	4cd8                	lw	a4,28(s1)
    80003de4:	2705                	addiw	a4,a4,1
    80003de6:	0027179b          	slliw	a5,a4,0x2
    80003dea:	9fb9                	addw	a5,a5,a4
    80003dec:	0017979b          	slliw	a5,a5,0x1
    80003df0:	54d4                	lw	a3,44(s1)
    80003df2:	9fb5                	addw	a5,a5,a3
    80003df4:	00f95e63          	bge	s2,a5,80003e10 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003df8:	8526                	mv	a0,s1
    80003dfa:	9f8fe0ef          	jal	80001ff2 <sleep_prepare>
      release(&log.lock);
    80003dfe:	8526                	mv	a0,s1
    80003e00:	eb1fc0ef          	jal	80000cb0 <release>
      sleep();
    80003e04:	a2afe0ef          	jal	8000202e <sleep>
      acquire(&log.lock);
    80003e08:	8526                	mv	a0,s1
    80003e0a:	e1ffc0ef          	jal	80000c28 <acquire>
    80003e0e:	bfc1                	j	80003dde <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003e10:	0001e797          	auipc	a5,0x1e
    80003e14:	6ce7aa23          	sw	a4,1748(a5) # 800224e4 <log+0x1c>
      release(&log.lock);
    80003e18:	0001e517          	auipc	a0,0x1e
    80003e1c:	6b050513          	addi	a0,a0,1712 # 800224c8 <log>
    80003e20:	e91fc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80003e24:	60e2                	ld	ra,24(sp)
    80003e26:	6442                	ld	s0,16(sp)
    80003e28:	64a2                	ld	s1,8(sp)
    80003e2a:	6902                	ld	s2,0(sp)
    80003e2c:	6105                	addi	sp,sp,32
    80003e2e:	8082                	ret

0000000080003e30 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e30:	7139                	addi	sp,sp,-64
    80003e32:	fc06                	sd	ra,56(sp)
    80003e34:	f822                	sd	s0,48(sp)
    80003e36:	f426                	sd	s1,40(sp)
    80003e38:	f04a                	sd	s2,32(sp)
    80003e3a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e3c:	0001e497          	auipc	s1,0x1e
    80003e40:	68c48493          	addi	s1,s1,1676 # 800224c8 <log>
    80003e44:	8526                	mv	a0,s1
    80003e46:	de3fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003e4a:	4cdc                	lw	a5,28(s1)
    80003e4c:	37fd                	addiw	a5,a5,-1
    80003e4e:	893e                	mv	s2,a5
    80003e50:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003e52:	509c                	lw	a5,32(s1)
    80003e54:	e3b1                	bnez	a5,80003e98 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003e56:	04091a63          	bnez	s2,80003eaa <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003e5a:	0001e497          	auipc	s1,0x1e
    80003e5e:	66e48493          	addi	s1,s1,1646 # 800224c8 <log>
    80003e62:	4785                	li	a5,1
    80003e64:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003e66:	8526                	mv	a0,s1
    80003e68:	e49fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003e6c:	54dc                	lw	a5,44(s1)
    80003e6e:	06f04063          	bgtz	a5,80003ece <end_op+0x9e>
    acquire(&log.lock);
    80003e72:	0001e497          	auipc	s1,0x1e
    80003e76:	65648493          	addi	s1,s1,1622 # 800224c8 <log>
    80003e7a:	8526                	mv	a0,s1
    80003e7c:	dadfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003e80:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003e84:	549c                	lw	a5,40(s1)
    80003e86:	2785                	addiw	a5,a5,1
    80003e88:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003e8a:	8526                	mv	a0,s1
    80003e8c:	9d2fe0ef          	jal	8000205e <wakeup>
    release(&log.lock);
    80003e90:	8526                	mv	a0,s1
    80003e92:	e1ffc0ef          	jal	80000cb0 <release>
}
    80003e96:	a035                	j	80003ec2 <end_op+0x92>
    80003e98:	ec4e                	sd	s3,24(sp)
    80003e9a:	e852                	sd	s4,16(sp)
    80003e9c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003e9e:	00003517          	auipc	a0,0x3
    80003ea2:	6fa50513          	addi	a0,a0,1786 # 80007598 <etext+0x598>
    80003ea6:	98ffc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003eaa:	0001e517          	auipc	a0,0x1e
    80003eae:	61e50513          	addi	a0,a0,1566 # 800224c8 <log>
    80003eb2:	9acfe0ef          	jal	8000205e <wakeup>
  release(&log.lock);
    80003eb6:	0001e517          	auipc	a0,0x1e
    80003eba:	61250513          	addi	a0,a0,1554 # 800224c8 <log>
    80003ebe:	df3fc0ef          	jal	80000cb0 <release>
}
    80003ec2:	70e2                	ld	ra,56(sp)
    80003ec4:	7442                	ld	s0,48(sp)
    80003ec6:	74a2                	ld	s1,40(sp)
    80003ec8:	7902                	ld	s2,32(sp)
    80003eca:	6121                	addi	sp,sp,64
    80003ecc:	8082                	ret
    80003ece:	ec4e                	sd	s3,24(sp)
    80003ed0:	e852                	sd	s4,16(sp)
    80003ed2:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ed4:	0001ea97          	auipc	s5,0x1e
    80003ed8:	624a8a93          	addi	s5,s5,1572 # 800224f8 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003edc:	0001ea17          	auipc	s4,0x1e
    80003ee0:	5eca0a13          	addi	s4,s4,1516 # 800224c8 <log>
    80003ee4:	018a2583          	lw	a1,24(s4)
    80003ee8:	012585bb          	addw	a1,a1,s2
    80003eec:	2585                	addiw	a1,a1,1
    80003eee:	024a2503          	lw	a0,36(s4)
    80003ef2:	da3fe0ef          	jal	80002c94 <bread>
    80003ef6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003ef8:	000aa583          	lw	a1,0(s5)
    80003efc:	024a2503          	lw	a0,36(s4)
    80003f00:	d95fe0ef          	jal	80002c94 <bread>
    80003f04:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f06:	40000613          	li	a2,1024
    80003f0a:	05850593          	addi	a1,a0,88
    80003f0e:	05848513          	addi	a0,s1,88
    80003f12:	e37fc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    80003f16:	8526                	mv	a0,s1
    80003f18:	e53fe0ef          	jal	80002d6a <bwrite>
    brelse(from);
    80003f1c:	854e                	mv	a0,s3
    80003f1e:	e7ffe0ef          	jal	80002d9c <brelse>
    brelse(to);
    80003f22:	8526                	mv	a0,s1
    80003f24:	e79fe0ef          	jal	80002d9c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f28:	2905                	addiw	s2,s2,1
    80003f2a:	0a91                	addi	s5,s5,4
    80003f2c:	02ca2783          	lw	a5,44(s4)
    80003f30:	faf94ae3          	blt	s2,a5,80003ee4 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003f34:	cc5ff0ef          	jal	80003bf8 <write_head>
    install_trans(0); // Now install writes to home locations
    80003f38:	4501                	li	a0,0
    80003f3a:	d1dff0ef          	jal	80003c56 <install_trans>
    log.lh.n = 0;
    80003f3e:	0001e797          	auipc	a5,0x1e
    80003f42:	5a07ab23          	sw	zero,1462(a5) # 800224f4 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003f46:	cb3ff0ef          	jal	80003bf8 <write_head>
    80003f4a:	69e2                	ld	s3,24(sp)
    80003f4c:	6a42                	ld	s4,16(sp)
    80003f4e:	6aa2                	ld	s5,8(sp)
    80003f50:	b70d                	j	80003e72 <end_op+0x42>

0000000080003f52 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f52:	1101                	addi	sp,sp,-32
    80003f54:	ec06                	sd	ra,24(sp)
    80003f56:	e822                	sd	s0,16(sp)
    80003f58:	e426                	sd	s1,8(sp)
    80003f5a:	1000                	addi	s0,sp,32
    80003f5c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003f5e:	0001e517          	auipc	a0,0x1e
    80003f62:	56a50513          	addi	a0,a0,1386 # 800224c8 <log>
    80003f66:	cc3fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003f6a:	0001e617          	auipc	a2,0x1e
    80003f6e:	58a62603          	lw	a2,1418(a2) # 800224f4 <log+0x2c>
    80003f72:	47f5                	li	a5,29
    80003f74:	04c7cd63          	blt	a5,a2,80003fce <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003f78:	0001e797          	auipc	a5,0x1e
    80003f7c:	56c7a783          	lw	a5,1388(a5) # 800224e4 <log+0x1c>
    80003f80:	04f05d63          	blez	a5,80003fda <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003f84:	4781                	li	a5,0
    80003f86:	06c05063          	blez	a2,80003fe6 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003f8a:	44cc                	lw	a1,12(s1)
    80003f8c:	0001e717          	auipc	a4,0x1e
    80003f90:	56c70713          	addi	a4,a4,1388 # 800224f8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003f94:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003f96:	4314                	lw	a3,0(a4)
    80003f98:	04b68763          	beq	a3,a1,80003fe6 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003f9c:	2785                	addiw	a5,a5,1
    80003f9e:	0711                	addi	a4,a4,4
    80003fa0:	fef61be3          	bne	a2,a5,80003f96 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003fa4:	060a                	slli	a2,a2,0x2
    80003fa6:	02060613          	addi	a2,a2,32
    80003faa:	0001e797          	auipc	a5,0x1e
    80003fae:	51e78793          	addi	a5,a5,1310 # 800224c8 <log>
    80003fb2:	97b2                	add	a5,a5,a2
    80003fb4:	44d8                	lw	a4,12(s1)
    80003fb6:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003fb8:	8526                	mv	a0,s1
    80003fba:	e67fe0ef          	jal	80002e20 <bpin>
    log.lh.n++;
    80003fbe:	0001e717          	auipc	a4,0x1e
    80003fc2:	50a70713          	addi	a4,a4,1290 # 800224c8 <log>
    80003fc6:	575c                	lw	a5,44(a4)
    80003fc8:	2785                	addiw	a5,a5,1
    80003fca:	d75c                	sw	a5,44(a4)
    80003fcc:	a815                	j	80004000 <log_write+0xae>
    panic("too big a transaction");
    80003fce:	00003517          	auipc	a0,0x3
    80003fd2:	5da50513          	addi	a0,a0,1498 # 800075a8 <etext+0x5a8>
    80003fd6:	85ffc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    80003fda:	00003517          	auipc	a0,0x3
    80003fde:	5e650513          	addi	a0,a0,1510 # 800075c0 <etext+0x5c0>
    80003fe2:	853fc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    80003fe6:	00279693          	slli	a3,a5,0x2
    80003fea:	02068693          	addi	a3,a3,32
    80003fee:	0001e717          	auipc	a4,0x1e
    80003ff2:	4da70713          	addi	a4,a4,1242 # 800224c8 <log>
    80003ff6:	9736                	add	a4,a4,a3
    80003ff8:	44d4                	lw	a3,12(s1)
    80003ffa:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80003ffc:	faf60ee3          	beq	a2,a5,80003fb8 <log_write+0x66>
  }
  release(&log.lock);
    80004000:	0001e517          	auipc	a0,0x1e
    80004004:	4c850513          	addi	a0,a0,1224 # 800224c8 <log>
    80004008:	ca9fc0ef          	jal	80000cb0 <release>
}
    8000400c:	60e2                	ld	ra,24(sp)
    8000400e:	6442                	ld	s0,16(sp)
    80004010:	64a2                	ld	s1,8(sp)
    80004012:	6105                	addi	sp,sp,32
    80004014:	8082                	ret

0000000080004016 <sys_sync>:

uint64
sys_sync(void)
{
    80004016:	1101                	addi	sp,sp,-32
    80004018:	ec06                	sd	ra,24(sp)
    8000401a:	e822                	sd	s0,16(sp)
    8000401c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000401e:	0001e517          	auipc	a0,0x1e
    80004022:	4aa50513          	addi	a0,a0,1194 # 800224c8 <log>
    80004026:	c03fc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    8000402a:	0001e797          	auipc	a5,0x1e
    8000402e:	4be7a783          	lw	a5,1214(a5) # 800224e8 <log+0x20>
    80004032:	e799                	bnez	a5,80004040 <sys_sync+0x2a>
    80004034:	0001e797          	auipc	a5,0x1e
    80004038:	4b07a783          	lw	a5,1200(a5) # 800224e4 <log+0x1c>
    8000403c:	02f05c63          	blez	a5,80004074 <sys_sync+0x5e>
    80004040:	e426                	sd	s1,8(sp)
    80004042:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80004044:	0001e917          	auipc	s2,0x1e
    80004048:	4ac92903          	lw	s2,1196(s2) # 800224f0 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    8000404c:	0001e497          	auipc	s1,0x1e
    80004050:	47c48493          	addi	s1,s1,1148 # 800224c8 <log>
    80004054:	8526                	mv	a0,s1
    80004056:	f9dfd0ef          	jal	80001ff2 <sleep_prepare>
      release(&log.lock);
    8000405a:	8526                	mv	a0,s1
    8000405c:	c55fc0ef          	jal	80000cb0 <release>
      sleep();
    80004060:	fcffd0ef          	jal	8000202e <sleep>
      acquire(&log.lock);
    80004064:	8526                	mv	a0,s1
    80004066:	bc3fc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    8000406a:	549c                	lw	a5,40(s1)
    8000406c:	fef954e3          	bge	s2,a5,80004054 <sys_sync+0x3e>
    80004070:	64a2                	ld	s1,8(sp)
    80004072:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80004074:	0001e517          	auipc	a0,0x1e
    80004078:	45450513          	addi	a0,a0,1108 # 800224c8 <log>
    8000407c:	c35fc0ef          	jal	80000cb0 <release>
  return 0;
}
    80004080:	4501                	li	a0,0
    80004082:	60e2                	ld	ra,24(sp)
    80004084:	6442                	ld	s0,16(sp)
    80004086:	6105                	addi	sp,sp,32
    80004088:	8082                	ret

000000008000408a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000408a:	1101                	addi	sp,sp,-32
    8000408c:	ec06                	sd	ra,24(sp)
    8000408e:	e822                	sd	s0,16(sp)
    80004090:	e426                	sd	s1,8(sp)
    80004092:	e04a                	sd	s2,0(sp)
    80004094:	1000                	addi	s0,sp,32
    80004096:	84aa                	mv	s1,a0
    80004098:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000409a:	00003597          	auipc	a1,0x3
    8000409e:	54658593          	addi	a1,a1,1350 # 800075e0 <etext+0x5e0>
    800040a2:	0521                	addi	a0,a0,8
    800040a4:	b05fc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    800040a8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800040ac:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040b0:	0204a423          	sw	zero,40(s1)
}
    800040b4:	60e2                	ld	ra,24(sp)
    800040b6:	6442                	ld	s0,16(sp)
    800040b8:	64a2                	ld	s1,8(sp)
    800040ba:	6902                	ld	s2,0(sp)
    800040bc:	6105                	addi	sp,sp,32
    800040be:	8082                	ret

00000000800040c0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800040c0:	1101                	addi	sp,sp,-32
    800040c2:	ec06                	sd	ra,24(sp)
    800040c4:	e822                	sd	s0,16(sp)
    800040c6:	e426                	sd	s1,8(sp)
    800040c8:	e04a                	sd	s2,0(sp)
    800040ca:	1000                	addi	s0,sp,32
    800040cc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800040ce:	00850913          	addi	s2,a0,8
    800040d2:	854a                	mv	a0,s2
    800040d4:	b55fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800040d8:	409c                	lw	a5,0(s1)
    800040da:	cf91                	beqz	a5,800040f6 <acquiresleep+0x36>
    sleep_prepare(lk);
    800040dc:	8526                	mv	a0,s1
    800040de:	f15fd0ef          	jal	80001ff2 <sleep_prepare>
    release(&lk->lk);
    800040e2:	854a                	mv	a0,s2
    800040e4:	bcdfc0ef          	jal	80000cb0 <release>
    sleep();
    800040e8:	f47fd0ef          	jal	8000202e <sleep>
    acquire(&lk->lk);
    800040ec:	854a                	mv	a0,s2
    800040ee:	b3bfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800040f2:	409c                	lw	a5,0(s1)
    800040f4:	f7e5                	bnez	a5,800040dc <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800040f6:	4785                	li	a5,1
    800040f8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800040fa:	8effd0ef          	jal	800019e8 <myproc>
    800040fe:	591c                	lw	a5,48(a0)
    80004100:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004102:	854a                	mv	a0,s2
    80004104:	badfc0ef          	jal	80000cb0 <release>
}
    80004108:	60e2                	ld	ra,24(sp)
    8000410a:	6442                	ld	s0,16(sp)
    8000410c:	64a2                	ld	s1,8(sp)
    8000410e:	6902                	ld	s2,0(sp)
    80004110:	6105                	addi	sp,sp,32
    80004112:	8082                	ret

0000000080004114 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004114:	1101                	addi	sp,sp,-32
    80004116:	ec06                	sd	ra,24(sp)
    80004118:	e822                	sd	s0,16(sp)
    8000411a:	e426                	sd	s1,8(sp)
    8000411c:	e04a                	sd	s2,0(sp)
    8000411e:	1000                	addi	s0,sp,32
    80004120:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004122:	00850913          	addi	s2,a0,8
    80004126:	854a                	mv	a0,s2
    80004128:	b01fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    8000412c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004130:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004134:	8526                	mv	a0,s1
    80004136:	f29fd0ef          	jal	8000205e <wakeup>
  release(&lk->lk);
    8000413a:	854a                	mv	a0,s2
    8000413c:	b75fc0ef          	jal	80000cb0 <release>
}
    80004140:	60e2                	ld	ra,24(sp)
    80004142:	6442                	ld	s0,16(sp)
    80004144:	64a2                	ld	s1,8(sp)
    80004146:	6902                	ld	s2,0(sp)
    80004148:	6105                	addi	sp,sp,32
    8000414a:	8082                	ret

000000008000414c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000414c:	7179                	addi	sp,sp,-48
    8000414e:	f406                	sd	ra,40(sp)
    80004150:	f022                	sd	s0,32(sp)
    80004152:	ec26                	sd	s1,24(sp)
    80004154:	e84a                	sd	s2,16(sp)
    80004156:	1800                	addi	s0,sp,48
    80004158:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    8000415a:	00850913          	addi	s2,a0,8
    8000415e:	854a                	mv	a0,s2
    80004160:	ac9fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004164:	409c                	lw	a5,0(s1)
    80004166:	ef81                	bnez	a5,8000417e <holdingsleep+0x32>
    80004168:	4481                	li	s1,0
  release(&lk->lk);
    8000416a:	854a                	mv	a0,s2
    8000416c:	b45fc0ef          	jal	80000cb0 <release>
  return r;
}
    80004170:	8526                	mv	a0,s1
    80004172:	70a2                	ld	ra,40(sp)
    80004174:	7402                	ld	s0,32(sp)
    80004176:	64e2                	ld	s1,24(sp)
    80004178:	6942                	ld	s2,16(sp)
    8000417a:	6145                	addi	sp,sp,48
    8000417c:	8082                	ret
    8000417e:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004180:	0284a983          	lw	s3,40(s1)
    80004184:	865fd0ef          	jal	800019e8 <myproc>
    80004188:	5904                	lw	s1,48(a0)
    8000418a:	413484b3          	sub	s1,s1,s3
    8000418e:	0014b493          	seqz	s1,s1
    80004192:	69a2                	ld	s3,8(sp)
    80004194:	bfd9                	j	8000416a <holdingsleep+0x1e>

0000000080004196 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004196:	1141                	addi	sp,sp,-16
    80004198:	e406                	sd	ra,8(sp)
    8000419a:	e022                	sd	s0,0(sp)
    8000419c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000419e:	00003597          	auipc	a1,0x3
    800041a2:	45258593          	addi	a1,a1,1106 # 800075f0 <etext+0x5f0>
    800041a6:	0001e517          	auipc	a0,0x1e
    800041aa:	46a50513          	addi	a0,a0,1130 # 80022610 <ftable>
    800041ae:	9fbfc0ef          	jal	80000ba8 <initlock>
}
    800041b2:	60a2                	ld	ra,8(sp)
    800041b4:	6402                	ld	s0,0(sp)
    800041b6:	0141                	addi	sp,sp,16
    800041b8:	8082                	ret

00000000800041ba <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800041ba:	1101                	addi	sp,sp,-32
    800041bc:	ec06                	sd	ra,24(sp)
    800041be:	e822                	sd	s0,16(sp)
    800041c0:	e426                	sd	s1,8(sp)
    800041c2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800041c4:	0001e517          	auipc	a0,0x1e
    800041c8:	44c50513          	addi	a0,a0,1100 # 80022610 <ftable>
    800041cc:	a5dfc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800041d0:	0001e497          	auipc	s1,0x1e
    800041d4:	45848493          	addi	s1,s1,1112 # 80022628 <ftable+0x18>
    800041d8:	0001f717          	auipc	a4,0x1f
    800041dc:	3f070713          	addi	a4,a4,1008 # 800235c8 <disk>
    if (f->ref == 0) {
    800041e0:	40dc                	lw	a5,4(s1)
    800041e2:	cf89                	beqz	a5,800041fc <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800041e4:	02848493          	addi	s1,s1,40
    800041e8:	fee49ce3          	bne	s1,a4,800041e0 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800041ec:	0001e517          	auipc	a0,0x1e
    800041f0:	42450513          	addi	a0,a0,1060 # 80022610 <ftable>
    800041f4:	abdfc0ef          	jal	80000cb0 <release>
  return 0;
    800041f8:	4481                	li	s1,0
    800041fa:	a809                	j	8000420c <filealloc+0x52>
      f->ref = 1;
    800041fc:	4785                	li	a5,1
    800041fe:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004200:	0001e517          	auipc	a0,0x1e
    80004204:	41050513          	addi	a0,a0,1040 # 80022610 <ftable>
    80004208:	aa9fc0ef          	jal	80000cb0 <release>
}
    8000420c:	8526                	mv	a0,s1
    8000420e:	60e2                	ld	ra,24(sp)
    80004210:	6442                	ld	s0,16(sp)
    80004212:	64a2                	ld	s1,8(sp)
    80004214:	6105                	addi	sp,sp,32
    80004216:	8082                	ret

0000000080004218 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004218:	1101                	addi	sp,sp,-32
    8000421a:	ec06                	sd	ra,24(sp)
    8000421c:	e822                	sd	s0,16(sp)
    8000421e:	e426                	sd	s1,8(sp)
    80004220:	1000                	addi	s0,sp,32
    80004222:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004224:	0001e517          	auipc	a0,0x1e
    80004228:	3ec50513          	addi	a0,a0,1004 # 80022610 <ftable>
    8000422c:	9fdfc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    80004230:	40dc                	lw	a5,4(s1)
    80004232:	02f05063          	blez	a5,80004252 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004236:	2785                	addiw	a5,a5,1
    80004238:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000423a:	0001e517          	auipc	a0,0x1e
    8000423e:	3d650513          	addi	a0,a0,982 # 80022610 <ftable>
    80004242:	a6ffc0ef          	jal	80000cb0 <release>
  return f;
}
    80004246:	8526                	mv	a0,s1
    80004248:	60e2                	ld	ra,24(sp)
    8000424a:	6442                	ld	s0,16(sp)
    8000424c:	64a2                	ld	s1,8(sp)
    8000424e:	6105                	addi	sp,sp,32
    80004250:	8082                	ret
    panic("filedup");
    80004252:	00003517          	auipc	a0,0x3
    80004256:	3a650513          	addi	a0,a0,934 # 800075f8 <etext+0x5f8>
    8000425a:	ddafc0ef          	jal	80000834 <panic>

000000008000425e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000425e:	7139                	addi	sp,sp,-64
    80004260:	fc06                	sd	ra,56(sp)
    80004262:	f822                	sd	s0,48(sp)
    80004264:	f426                	sd	s1,40(sp)
    80004266:	0080                	addi	s0,sp,64
    80004268:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000426a:	0001e517          	auipc	a0,0x1e
    8000426e:	3a650513          	addi	a0,a0,934 # 80022610 <ftable>
    80004272:	9b7fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    80004276:	40dc                	lw	a5,4(s1)
    80004278:	04f05a63          	blez	a5,800042cc <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    8000427c:	37fd                	addiw	a5,a5,-1
    8000427e:	c0dc                	sw	a5,4(s1)
    80004280:	06f04063          	bgtz	a5,800042e0 <fileclose+0x82>
    80004284:	f04a                	sd	s2,32(sp)
    80004286:	ec4e                	sd	s3,24(sp)
    80004288:	e852                	sd	s4,16(sp)
    8000428a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000428c:	0004a903          	lw	s2,0(s1)
    80004290:	0094c783          	lbu	a5,9(s1)
    80004294:	89be                	mv	s3,a5
    80004296:	689c                	ld	a5,16(s1)
    80004298:	8a3e                	mv	s4,a5
    8000429a:	6c9c                	ld	a5,24(s1)
    8000429c:	8abe                	mv	s5,a5
  f->ref = 0;
    8000429e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800042a2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800042a6:	0001e517          	auipc	a0,0x1e
    800042aa:	36a50513          	addi	a0,a0,874 # 80022610 <ftable>
    800042ae:	a03fc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    800042b2:	4785                	li	a5,1
    800042b4:	04f90163          	beq	s2,a5,800042f6 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    800042b8:	ffe9079b          	addiw	a5,s2,-2
    800042bc:	4705                	li	a4,1
    800042be:	04f77563          	bgeu	a4,a5,80004308 <fileclose+0xaa>
    800042c2:	7902                	ld	s2,32(sp)
    800042c4:	69e2                	ld	s3,24(sp)
    800042c6:	6a42                	ld	s4,16(sp)
    800042c8:	6aa2                	ld	s5,8(sp)
    800042ca:	a00d                	j	800042ec <fileclose+0x8e>
    800042cc:	f04a                	sd	s2,32(sp)
    800042ce:	ec4e                	sd	s3,24(sp)
    800042d0:	e852                	sd	s4,16(sp)
    800042d2:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800042d4:	00003517          	auipc	a0,0x3
    800042d8:	32c50513          	addi	a0,a0,812 # 80007600 <etext+0x600>
    800042dc:	d58fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    800042e0:	0001e517          	auipc	a0,0x1e
    800042e4:	33050513          	addi	a0,a0,816 # 80022610 <ftable>
    800042e8:	9c9fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800042ec:	70e2                	ld	ra,56(sp)
    800042ee:	7442                	ld	s0,48(sp)
    800042f0:	74a2                	ld	s1,40(sp)
    800042f2:	6121                	addi	sp,sp,64
    800042f4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800042f6:	85ce                	mv	a1,s3
    800042f8:	8552                	mv	a0,s4
    800042fa:	36a000ef          	jal	80004664 <pipeclose>
    800042fe:	7902                	ld	s2,32(sp)
    80004300:	69e2                	ld	s3,24(sp)
    80004302:	6a42                	ld	s4,16(sp)
    80004304:	6aa2                	ld	s5,8(sp)
    80004306:	b7dd                	j	800042ec <fileclose+0x8e>
    begin_op();
    80004308:	a9dff0ef          	jal	80003da4 <begin_op>
    iput(ff.ip);
    8000430c:	8556                	mv	a0,s5
    8000430e:	9a0ff0ef          	jal	800034ae <iput>
    end_op();
    80004312:	b1fff0ef          	jal	80003e30 <end_op>
    80004316:	7902                	ld	s2,32(sp)
    80004318:	69e2                	ld	s3,24(sp)
    8000431a:	6a42                	ld	s4,16(sp)
    8000431c:	6aa2                	ld	s5,8(sp)
    8000431e:	b7f9                	j	800042ec <fileclose+0x8e>

0000000080004320 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004320:	715d                	addi	sp,sp,-80
    80004322:	e486                	sd	ra,72(sp)
    80004324:	e0a2                	sd	s0,64(sp)
    80004326:	fc26                	sd	s1,56(sp)
    80004328:	f052                	sd	s4,32(sp)
    8000432a:	0880                	addi	s0,sp,80
    8000432c:	84aa                	mv	s1,a0
    8000432e:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004330:	eb8fd0ef          	jal	800019e8 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004334:	409c                	lw	a5,0(s1)
    80004336:	37f9                	addiw	a5,a5,-2
    80004338:	4705                	li	a4,1
    8000433a:	04f76963          	bltu	a4,a5,8000438c <filestat+0x6c>
    8000433e:	f84a                	sd	s2,48(sp)
    80004340:	f44e                	sd	s3,40(sp)
    80004342:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    80004344:	fb840993          	addi	s3,s0,-72
    80004348:	4661                	li	a2,24
    8000434a:	4581                	li	a1,0
    8000434c:	854e                	mv	a0,s3
    8000434e:	99bfc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    80004352:	6c88                	ld	a0,24(s1)
    80004354:	fd9fe0ef          	jal	8000332c <ilock>
    stati(f->ip, &st);
    80004358:	85ce                	mv	a1,s3
    8000435a:	6c88                	ld	a0,24(s1)
    8000435c:	b7cff0ef          	jal	800036d8 <stati>
    iunlock(f->ip);
    80004360:	6c88                	ld	a0,24(s1)
    80004362:	878ff0ef          	jal	800033da <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    80004366:	4761                	li	a4,24
    80004368:	86ce                	mv	a3,s3
    8000436a:	8652                	mv	a2,s4
    8000436c:	04893583          	ld	a1,72(s2)
    80004370:	05093503          	ld	a0,80(s2)
    80004374:	a0efd0ef          	jal	80001582 <copyout>
    80004378:	41f5551b          	sraiw	a0,a0,0x1f
    8000437c:	7942                	ld	s2,48(sp)
    8000437e:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004380:	60a6                	ld	ra,72(sp)
    80004382:	6406                	ld	s0,64(sp)
    80004384:	74e2                	ld	s1,56(sp)
    80004386:	7a02                	ld	s4,32(sp)
    80004388:	6161                	addi	sp,sp,80
    8000438a:	8082                	ret
  return -1;
    8000438c:	557d                	li	a0,-1
    8000438e:	bfcd                	j	80004380 <filestat+0x60>

0000000080004390 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004390:	7179                	addi	sp,sp,-48
    80004392:	f406                	sd	ra,40(sp)
    80004394:	f022                	sd	s0,32(sp)
    80004396:	e84a                	sd	s2,16(sp)
    80004398:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    8000439a:	00854783          	lbu	a5,8(a0)
    8000439e:	c3dd                	beqz	a5,80004444 <fileread+0xb4>
    800043a0:	ec26                	sd	s1,24(sp)
    800043a2:	e44e                	sd	s3,8(sp)
    800043a4:	84aa                	mv	s1,a0
    800043a6:	892e                	mv	s2,a1
    800043a8:	89b2                	mv	s3,a2
    800043aa:	01f6579b          	srliw	a5,a2,0x1f
    800043ae:	ebc9                	bnez	a5,80004440 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    800043b0:	411c                	lw	a5,0(a0)
    800043b2:	4705                	li	a4,1
    800043b4:	04e78363          	beq	a5,a4,800043fa <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800043b8:	470d                	li	a4,3
    800043ba:	04e78763          	beq	a5,a4,80004408 <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    800043be:	4709                	li	a4,2
    800043c0:	06e79a63          	bne	a5,a4,80004434 <fileread+0xa4>
    ilock(f->ip);
    800043c4:	6d08                	ld	a0,24(a0)
    800043c6:	f67fe0ef          	jal	8000332c <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800043ca:	874e                	mv	a4,s3
    800043cc:	5094                	lw	a3,32(s1)
    800043ce:	864a                	mv	a2,s2
    800043d0:	4585                	li	a1,1
    800043d2:	6c88                	ld	a0,24(s1)
    800043d4:	b32ff0ef          	jal	80003706 <readi>
    800043d8:	892a                	mv	s2,a0
    800043da:	00a05563          	blez	a0,800043e4 <fileread+0x54>
      f->off += r;
    800043de:	509c                	lw	a5,32(s1)
    800043e0:	9fa9                	addw	a5,a5,a0
    800043e2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800043e4:	6c88                	ld	a0,24(s1)
    800043e6:	ff5fe0ef          	jal	800033da <iunlock>
    800043ea:	64e2                	ld	s1,24(sp)
    800043ec:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800043ee:	854a                	mv	a0,s2
    800043f0:	70a2                	ld	ra,40(sp)
    800043f2:	7402                	ld	s0,32(sp)
    800043f4:	6942                	ld	s2,16(sp)
    800043f6:	6145                	addi	sp,sp,48
    800043f8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800043fa:	6908                	ld	a0,16(a0)
    800043fc:	3e2000ef          	jal	800047de <piperead>
    80004400:	892a                	mv	s2,a0
    80004402:	64e2                	ld	s1,24(sp)
    80004404:	69a2                	ld	s3,8(sp)
    80004406:	b7e5                	j	800043ee <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004408:	02451783          	lh	a5,36(a0)
    8000440c:	03079693          	slli	a3,a5,0x30
    80004410:	92c1                	srli	a3,a3,0x30
    80004412:	4725                	li	a4,9
    80004414:	02d76b63          	bltu	a4,a3,8000444a <fileread+0xba>
    80004418:	0792                	slli	a5,a5,0x4
    8000441a:	0001e717          	auipc	a4,0x1e
    8000441e:	15670713          	addi	a4,a4,342 # 80022570 <devsw>
    80004422:	97ba                	add	a5,a5,a4
    80004424:	639c                	ld	a5,0(a5)
    80004426:	c79d                	beqz	a5,80004454 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    80004428:	4505                	li	a0,1
    8000442a:	9782                	jalr	a5
    8000442c:	892a                	mv	s2,a0
    8000442e:	64e2                	ld	s1,24(sp)
    80004430:	69a2                	ld	s3,8(sp)
    80004432:	bf75                	j	800043ee <fileread+0x5e>
    panic("fileread");
    80004434:	00003517          	auipc	a0,0x3
    80004438:	1dc50513          	addi	a0,a0,476 # 80007610 <etext+0x610>
    8000443c:	bf8fc0ef          	jal	80000834 <panic>
    80004440:	64e2                	ld	s1,24(sp)
    80004442:	69a2                	ld	s3,8(sp)
    return -1;
    80004444:	57fd                	li	a5,-1
    80004446:	893e                	mv	s2,a5
    80004448:	b75d                	j	800043ee <fileread+0x5e>
      return -1;
    8000444a:	57fd                	li	a5,-1
    8000444c:	893e                	mv	s2,a5
    8000444e:	64e2                	ld	s1,24(sp)
    80004450:	69a2                	ld	s3,8(sp)
    80004452:	bf71                	j	800043ee <fileread+0x5e>
    80004454:	57fd                	li	a5,-1
    80004456:	893e                	mv	s2,a5
    80004458:	64e2                	ld	s1,24(sp)
    8000445a:	69a2                	ld	s3,8(sp)
    8000445c:	bf49                	j	800043ee <fileread+0x5e>

000000008000445e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    8000445e:	00954783          	lbu	a5,9(a0)
    80004462:	12078b63          	beqz	a5,80004598 <filewrite+0x13a>
{
    80004466:	711d                	addi	sp,sp,-96
    80004468:	ec86                	sd	ra,88(sp)
    8000446a:	e8a2                	sd	s0,80(sp)
    8000446c:	e0ca                	sd	s2,64(sp)
    8000446e:	f456                	sd	s5,40(sp)
    80004470:	f05a                	sd	s6,32(sp)
    80004472:	1080                	addi	s0,sp,96
    80004474:	892a                	mv	s2,a0
    80004476:	8b2e                	mv	s6,a1
    80004478:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    8000447a:	01f6579b          	srliw	a5,a2,0x1f
    8000447e:	0e079d63          	bnez	a5,80004578 <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    80004482:	411c                	lw	a5,0(a0)
    80004484:	4705                	li	a4,1
    80004486:	02e78a63          	beq	a5,a4,800044ba <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000448a:	470d                	li	a4,3
    8000448c:	02e78b63          	beq	a5,a4,800044c2 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004490:	4709                	li	a4,2
    80004492:	0ce79763          	bne	a5,a4,80004560 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    80004496:	0ec05763          	blez	a2,80004584 <filewrite+0x126>
    8000449a:	e4a6                	sd	s1,72(sp)
    8000449c:	fc4e                	sd	s3,56(sp)
    8000449e:	f852                	sd	s4,48(sp)
    800044a0:	ec5e                	sd	s7,24(sp)
    800044a2:	e862                	sd	s8,16(sp)
    800044a4:	e466                	sd	s9,8(sp)
    int i = 0;
    800044a6:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    800044a8:	6b85                	lui	s7,0x1
    800044aa:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800044ae:	6785                	lui	a5,0x1
    800044b0:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800044b4:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044b6:	4c05                	li	s8,1
    800044b8:	a8ad                	j	80004532 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    800044ba:	6908                	ld	a0,16(a0)
    800044bc:	206000ef          	jal	800046c2 <pipewrite>
    800044c0:	a849                	j	80004552 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800044c2:	02451783          	lh	a5,36(a0)
    800044c6:	03079693          	slli	a3,a5,0x30
    800044ca:	92c1                	srli	a3,a3,0x30
    800044cc:	4725                	li	a4,9
    800044ce:	0ad76763          	bltu	a4,a3,8000457c <filewrite+0x11e>
    800044d2:	0792                	slli	a5,a5,0x4
    800044d4:	0001e717          	auipc	a4,0x1e
    800044d8:	09c70713          	addi	a4,a4,156 # 80022570 <devsw>
    800044dc:	97ba                	add	a5,a5,a4
    800044de:	679c                	ld	a5,8(a5)
    800044e0:	c3c5                	beqz	a5,80004580 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800044e2:	4505                	li	a0,1
    800044e4:	9782                	jalr	a5
    800044e6:	a0b5                	j	80004552 <filewrite+0xf4>
      if (n1 > max)
    800044e8:	2981                	sext.w	s3,s3
      begin_op();
    800044ea:	8bbff0ef          	jal	80003da4 <begin_op>
      ilock(f->ip);
    800044ee:	01893503          	ld	a0,24(s2)
    800044f2:	e3bfe0ef          	jal	8000332c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044f6:	874e                	mv	a4,s3
    800044f8:	02092683          	lw	a3,32(s2)
    800044fc:	016a0633          	add	a2,s4,s6
    80004500:	85e2                	mv	a1,s8
    80004502:	01893503          	ld	a0,24(s2)
    80004506:	af2ff0ef          	jal	800037f8 <writei>
    8000450a:	84aa                	mv	s1,a0
    8000450c:	00a05763          	blez	a0,8000451a <filewrite+0xbc>
        f->off += r;
    80004510:	02092783          	lw	a5,32(s2)
    80004514:	9fa9                	addw	a5,a5,a0
    80004516:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000451a:	01893503          	ld	a0,24(s2)
    8000451e:	ebdfe0ef          	jal	800033da <iunlock>
      end_op();
    80004522:	90fff0ef          	jal	80003e30 <end_op>

      if (r != n1) {
    80004526:	00999d63          	bne	s3,s1,80004540 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    8000452a:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    8000452e:	015a5963          	bge	s4,s5,80004540 <filewrite+0xe2>
      int n1 = n - i;
    80004532:	414a87bb          	subw	a5,s5,s4
    80004536:	89be                	mv	s3,a5
      if (n1 > max)
    80004538:	fafbd8e3          	bge	s7,a5,800044e8 <filewrite+0x8a>
    8000453c:	89e6                	mv	s3,s9
    8000453e:	b76d                	j	800044e8 <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    80004540:	054a9463          	bne	s5,s4,80004588 <filewrite+0x12a>
    80004544:	8556                	mv	a0,s5
    80004546:	64a6                	ld	s1,72(sp)
    80004548:	79e2                	ld	s3,56(sp)
    8000454a:	7a42                	ld	s4,48(sp)
    8000454c:	6be2                	ld	s7,24(sp)
    8000454e:	6c42                	ld	s8,16(sp)
    80004550:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004552:	60e6                	ld	ra,88(sp)
    80004554:	6446                	ld	s0,80(sp)
    80004556:	6906                	ld	s2,64(sp)
    80004558:	7aa2                	ld	s5,40(sp)
    8000455a:	7b02                	ld	s6,32(sp)
    8000455c:	6125                	addi	sp,sp,96
    8000455e:	8082                	ret
    80004560:	e4a6                	sd	s1,72(sp)
    80004562:	fc4e                	sd	s3,56(sp)
    80004564:	f852                	sd	s4,48(sp)
    80004566:	ec5e                	sd	s7,24(sp)
    80004568:	e862                	sd	s8,16(sp)
    8000456a:	e466                	sd	s9,8(sp)
    panic("filewrite");
    8000456c:	00003517          	auipc	a0,0x3
    80004570:	0b450513          	addi	a0,a0,180 # 80007620 <etext+0x620>
    80004574:	ac0fc0ef          	jal	80000834 <panic>
    return -1;
    80004578:	557d                	li	a0,-1
    8000457a:	bfe1                	j	80004552 <filewrite+0xf4>
      return -1;
    8000457c:	557d                	li	a0,-1
    8000457e:	bfd1                	j	80004552 <filewrite+0xf4>
    80004580:	557d                	li	a0,-1
    80004582:	bfc1                	j	80004552 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    80004584:	8532                	mv	a0,a2
    80004586:	b7f1                	j	80004552 <filewrite+0xf4>
    80004588:	557d                	li	a0,-1
    8000458a:	64a6                	ld	s1,72(sp)
    8000458c:	79e2                	ld	s3,56(sp)
    8000458e:	7a42                	ld	s4,48(sp)
    80004590:	6be2                	ld	s7,24(sp)
    80004592:	6c42                	ld	s8,16(sp)
    80004594:	6ca2                	ld	s9,8(sp)
    80004596:	bf75                	j	80004552 <filewrite+0xf4>
    return -1;
    80004598:	557d                	li	a0,-1
}
    8000459a:	8082                	ret

000000008000459c <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000459c:	7179                	addi	sp,sp,-48
    8000459e:	f406                	sd	ra,40(sp)
    800045a0:	f022                	sd	s0,32(sp)
    800045a2:	ec26                	sd	s1,24(sp)
    800045a4:	e052                	sd	s4,0(sp)
    800045a6:	1800                	addi	s0,sp,48
    800045a8:	84aa                	mv	s1,a0
    800045aa:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800045ac:	0005b023          	sd	zero,0(a1)
    800045b0:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800045b4:	c07ff0ef          	jal	800041ba <filealloc>
    800045b8:	e088                	sd	a0,0(s1)
    800045ba:	c549                	beqz	a0,80004644 <pipealloc+0xa8>
    800045bc:	bffff0ef          	jal	800041ba <filealloc>
    800045c0:	00aa3023          	sd	a0,0(s4)
    800045c4:	cd25                	beqz	a0,8000463c <pipealloc+0xa0>
    800045c6:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    800045c8:	d86fc0ef          	jal	80000b4e <kalloc>
    800045cc:	892a                	mv	s2,a0
    800045ce:	c12d                	beqz	a0,80004630 <pipealloc+0x94>
    800045d0:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800045d2:	4985                	li	s3,1
    800045d4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800045d8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800045dc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800045e0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800045e4:	00003597          	auipc	a1,0x3
    800045e8:	04c58593          	addi	a1,a1,76 # 80007630 <etext+0x630>
    800045ec:	dbcfc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    800045f0:	609c                	ld	a5,0(s1)
    800045f2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800045f6:	609c                	ld	a5,0(s1)
    800045f8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800045fc:	609c                	ld	a5,0(s1)
    800045fe:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004602:	609c                	ld	a5,0(s1)
    80004604:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004608:	000a3783          	ld	a5,0(s4)
    8000460c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004610:	000a3783          	ld	a5,0(s4)
    80004614:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004618:	000a3783          	ld	a5,0(s4)
    8000461c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004620:	000a3783          	ld	a5,0(s4)
    80004624:	0127b823          	sd	s2,16(a5)
  return 0;
    80004628:	4501                	li	a0,0
    8000462a:	6942                	ld	s2,16(sp)
    8000462c:	69a2                	ld	s3,8(sp)
    8000462e:	a01d                	j	80004654 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004630:	6088                	ld	a0,0(s1)
    80004632:	c119                	beqz	a0,80004638 <pipealloc+0x9c>
    80004634:	6942                	ld	s2,16(sp)
    80004636:	a029                	j	80004640 <pipealloc+0xa4>
    80004638:	6942                	ld	s2,16(sp)
    8000463a:	a029                	j	80004644 <pipealloc+0xa8>
    8000463c:	6088                	ld	a0,0(s1)
    8000463e:	c10d                	beqz	a0,80004660 <pipealloc+0xc4>
    fileclose(*f0);
    80004640:	c1fff0ef          	jal	8000425e <fileclose>
  if (*f1)
    80004644:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004648:	557d                	li	a0,-1
  if (*f1)
    8000464a:	c789                	beqz	a5,80004654 <pipealloc+0xb8>
    fileclose(*f1);
    8000464c:	853e                	mv	a0,a5
    8000464e:	c11ff0ef          	jal	8000425e <fileclose>
  return -1;
    80004652:	557d                	li	a0,-1
}
    80004654:	70a2                	ld	ra,40(sp)
    80004656:	7402                	ld	s0,32(sp)
    80004658:	64e2                	ld	s1,24(sp)
    8000465a:	6a02                	ld	s4,0(sp)
    8000465c:	6145                	addi	sp,sp,48
    8000465e:	8082                	ret
  return -1;
    80004660:	557d                	li	a0,-1
    80004662:	bfcd                	j	80004654 <pipealloc+0xb8>

0000000080004664 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004664:	1101                	addi	sp,sp,-32
    80004666:	ec06                	sd	ra,24(sp)
    80004668:	e822                	sd	s0,16(sp)
    8000466a:	e426                	sd	s1,8(sp)
    8000466c:	e04a                	sd	s2,0(sp)
    8000466e:	1000                	addi	s0,sp,32
    80004670:	84aa                	mv	s1,a0
    80004672:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004674:	db4fc0ef          	jal	80000c28 <acquire>
  if (writable) {
    80004678:	02090763          	beqz	s2,800046a6 <pipeclose+0x42>
    pi->writeopen = 0;
    8000467c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004680:	21848513          	addi	a0,s1,536
    80004684:	9dbfd0ef          	jal	8000205e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004688:	2204a783          	lw	a5,544(s1)
    8000468c:	e781                	bnez	a5,80004694 <pipeclose+0x30>
    8000468e:	2244a783          	lw	a5,548(s1)
    80004692:	c38d                	beqz	a5,800046b4 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    80004694:	8526                	mv	a0,s1
    80004696:	e1afc0ef          	jal	80000cb0 <release>
}
    8000469a:	60e2                	ld	ra,24(sp)
    8000469c:	6442                	ld	s0,16(sp)
    8000469e:	64a2                	ld	s1,8(sp)
    800046a0:	6902                	ld	s2,0(sp)
    800046a2:	6105                	addi	sp,sp,32
    800046a4:	8082                	ret
    pi->readopen = 0;
    800046a6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800046aa:	21c48513          	addi	a0,s1,540
    800046ae:	9b1fd0ef          	jal	8000205e <wakeup>
    800046b2:	bfd9                	j	80004688 <pipeclose+0x24>
    release(&pi->lock);
    800046b4:	8526                	mv	a0,s1
    800046b6:	dfafc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    800046ba:	8526                	mv	a0,s1
    800046bc:	baafc0ef          	jal	80000a66 <kfree>
    800046c0:	bfe9                	j	8000469a <pipeclose+0x36>

00000000800046c2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800046c2:	7159                	addi	sp,sp,-112
    800046c4:	f486                	sd	ra,104(sp)
    800046c6:	f0a2                	sd	s0,96(sp)
    800046c8:	eca6                	sd	s1,88(sp)
    800046ca:	e8ca                	sd	s2,80(sp)
    800046cc:	e4ce                	sd	s3,72(sp)
    800046ce:	e0d2                	sd	s4,64(sp)
    800046d0:	fc56                	sd	s5,56(sp)
    800046d2:	1880                	addi	s0,sp,112
    800046d4:	84aa                	mv	s1,a0
    800046d6:	8aae                	mv	s5,a1
    800046d8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800046da:	b0efd0ef          	jal	800019e8 <myproc>
    800046de:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800046e0:	8526                	mv	a0,s1
    800046e2:	d46fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    800046e6:	0f405a63          	blez	s4,800047da <pipewrite+0x118>
    800046ea:	f85a                	sd	s6,48(sp)
    800046ec:	f45e                	sd	s7,40(sp)
    800046ee:	f062                	sd	s8,32(sp)
    800046f0:	ec66                	sd	s9,24(sp)
    800046f2:	e86a                	sd	s10,16(sp)
  int i = 0;
    800046f4:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800046f6:	f9f40c13          	addi	s8,s0,-97
    800046fa:	4b85                	li	s7,1
    800046fc:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800046fe:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    80004702:	21c48c93          	addi	s9,s1,540
    80004706:	a0a1                	j	8000474e <pipewrite+0x8c>
      release(&pi->lock);
    80004708:	8526                	mv	a0,s1
    8000470a:	da6fc0ef          	jal	80000cb0 <release>
      return -1;
    8000470e:	597d                	li	s2,-1
    80004710:	7b42                	ld	s6,48(sp)
    80004712:	7ba2                	ld	s7,40(sp)
    80004714:	7c02                	ld	s8,32(sp)
    80004716:	6ce2                	ld	s9,24(sp)
    80004718:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000471a:	854a                	mv	a0,s2
    8000471c:	70a6                	ld	ra,104(sp)
    8000471e:	7406                	ld	s0,96(sp)
    80004720:	64e6                	ld	s1,88(sp)
    80004722:	6946                	ld	s2,80(sp)
    80004724:	69a6                	ld	s3,72(sp)
    80004726:	6a06                	ld	s4,64(sp)
    80004728:	7ae2                	ld	s5,56(sp)
    8000472a:	6165                	addi	sp,sp,112
    8000472c:	8082                	ret
      wakeup(&pi->nread);
    8000472e:	856a                	mv	a0,s10
    80004730:	92ffd0ef          	jal	8000205e <wakeup>
      sleep_prepare(&pi->nwrite);
    80004734:	8566                	mv	a0,s9
    80004736:	8bdfd0ef          	jal	80001ff2 <sleep_prepare>
      release(&pi->lock);
    8000473a:	8526                	mv	a0,s1
    8000473c:	d74fc0ef          	jal	80000cb0 <release>
      sleep();
    80004740:	8effd0ef          	jal	8000202e <sleep>
      acquire(&pi->lock);
    80004744:	8526                	mv	a0,s1
    80004746:	ce2fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    8000474a:	07495b63          	bge	s2,s4,800047c0 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    8000474e:	2204a783          	lw	a5,544(s1)
    80004752:	dbdd                	beqz	a5,80004708 <pipewrite+0x46>
    80004754:	854e                	mv	a0,s3
    80004756:	afbfd0ef          	jal	80002250 <killed>
    8000475a:	f55d                	bnez	a0,80004708 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    8000475c:	2184a783          	lw	a5,536(s1)
    80004760:	21c4a703          	lw	a4,540(s1)
    80004764:	2007879b          	addiw	a5,a5,512
    80004768:	fcf703e3          	beq	a4,a5,8000472e <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    8000476c:	875e                	mv	a4,s7
    8000476e:	015906b3          	add	a3,s2,s5
    80004772:	8662                	mv	a2,s8
    80004774:	0489b583          	ld	a1,72(s3)
    80004778:	0509b503          	ld	a0,80(s3)
    8000477c:	ecdfc0ef          	jal	80001648 <copyin>
    80004780:	03650163          	beq	a0,s6,800047a2 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004784:	21c4a783          	lw	a5,540(s1)
    80004788:	0017871b          	addiw	a4,a5,1
    8000478c:	20e4ae23          	sw	a4,540(s1)
    80004790:	1ff7f793          	andi	a5,a5,511
    80004794:	97a6                	add	a5,a5,s1
    80004796:	f9f44703          	lbu	a4,-97(s0)
    8000479a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000479e:	2905                	addiw	s2,s2,1
    800047a0:	b76d                	j	8000474a <pipewrite+0x88>
        if (i == 0)
    800047a2:	00090863          	beqz	s2,800047b2 <pipewrite+0xf0>
    800047a6:	7b42                	ld	s6,48(sp)
    800047a8:	7ba2                	ld	s7,40(sp)
    800047aa:	7c02                	ld	s8,32(sp)
    800047ac:	6ce2                	ld	s9,24(sp)
    800047ae:	6d42                	ld	s10,16(sp)
    800047b0:	a829                	j	800047ca <pipewrite+0x108>
          i = -1;
    800047b2:	892a                	mv	s2,a0
        break;
    800047b4:	7b42                	ld	s6,48(sp)
    800047b6:	7ba2                	ld	s7,40(sp)
    800047b8:	7c02                	ld	s8,32(sp)
    800047ba:	6ce2                	ld	s9,24(sp)
    800047bc:	6d42                	ld	s10,16(sp)
    800047be:	a031                	j	800047ca <pipewrite+0x108>
    800047c0:	7b42                	ld	s6,48(sp)
    800047c2:	7ba2                	ld	s7,40(sp)
    800047c4:	7c02                	ld	s8,32(sp)
    800047c6:	6ce2                	ld	s9,24(sp)
    800047c8:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800047ca:	21848513          	addi	a0,s1,536
    800047ce:	891fd0ef          	jal	8000205e <wakeup>
  release(&pi->lock);
    800047d2:	8526                	mv	a0,s1
    800047d4:	cdcfc0ef          	jal	80000cb0 <release>
  return i;
    800047d8:	b789                	j	8000471a <pipewrite+0x58>
  int i = 0;
    800047da:	4901                	li	s2,0
    800047dc:	b7fd                	j	800047ca <pipewrite+0x108>

00000000800047de <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800047de:	711d                	addi	sp,sp,-96
    800047e0:	ec86                	sd	ra,88(sp)
    800047e2:	e8a2                	sd	s0,80(sp)
    800047e4:	e4a6                	sd	s1,72(sp)
    800047e6:	e0ca                	sd	s2,64(sp)
    800047e8:	fc4e                	sd	s3,56(sp)
    800047ea:	f852                	sd	s4,48(sp)
    800047ec:	f456                	sd	s5,40(sp)
    800047ee:	1080                	addi	s0,sp,96
    800047f0:	84aa                	mv	s1,a0
    800047f2:	89ae                	mv	s3,a1
    800047f4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800047f6:	9f2fd0ef          	jal	800019e8 <myproc>
    800047fa:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    800047fc:	8526                	mv	a0,s1
    800047fe:	c2afc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004802:	0d505263          	blez	s5,800048c6 <piperead+0xe8>
    80004806:	2184a703          	lw	a4,536(s1)
    8000480a:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    8000480e:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004812:	02f71e63          	bne	a4,a5,8000484e <piperead+0x70>
    80004816:	2244a783          	lw	a5,548(s1)
    8000481a:	c3b9                	beqz	a5,80004860 <piperead+0x82>
    if (killed(pr)) {
    8000481c:	854a                	mv	a0,s2
    8000481e:	a33fd0ef          	jal	80002250 <killed>
    80004822:	e915                	bnez	a0,80004856 <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004824:	8552                	mv	a0,s4
    80004826:	fccfd0ef          	jal	80001ff2 <sleep_prepare>
    release(&pi->lock);
    8000482a:	8526                	mv	a0,s1
    8000482c:	c84fc0ef          	jal	80000cb0 <release>
    sleep();
    80004830:	ffefd0ef          	jal	8000202e <sleep>
    acquire(&pi->lock);
    80004834:	8526                	mv	a0,s1
    80004836:	bf2fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000483a:	2184a703          	lw	a4,536(s1)
    8000483e:	21c4a783          	lw	a5,540(s1)
    80004842:	fcf70ae3          	beq	a4,a5,80004816 <piperead+0x38>
    80004846:	f05a                	sd	s6,32(sp)
    80004848:	ec5e                	sd	s7,24(sp)
    8000484a:	e862                	sd	s8,16(sp)
    8000484c:	a829                	j	80004866 <piperead+0x88>
    8000484e:	f05a                	sd	s6,32(sp)
    80004850:	ec5e                	sd	s7,24(sp)
    80004852:	e862                	sd	s8,16(sp)
    80004854:	a809                	j	80004866 <piperead+0x88>
      release(&pi->lock);
    80004856:	8526                	mv	a0,s1
    80004858:	c58fc0ef          	jal	80000cb0 <release>
      return -1;
    8000485c:	5a7d                	li	s4,-1
    8000485e:	a8a5                	j	800048d6 <piperead+0xf8>
    80004860:	f05a                	sd	s6,32(sp)
    80004862:	ec5e                	sd	s7,24(sp)
    80004864:	e862                	sd	s8,16(sp)
{
    80004866:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004868:	faf40c13          	addi	s8,s0,-81
    8000486c:	4b85                	li	s7,1
    8000486e:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    80004870:	2184a783          	lw	a5,536(s1)
    80004874:	21c4a703          	lw	a4,540(s1)
    80004878:	06f70e63          	beq	a4,a5,800048f4 <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    8000487c:	1ff7f793          	andi	a5,a5,511
    80004880:	97a6                	add	a5,a5,s1
    80004882:	0187c783          	lbu	a5,24(a5)
    80004886:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    8000488a:	875e                	mv	a4,s7
    8000488c:	86e2                	mv	a3,s8
    8000488e:	864e                	mv	a2,s3
    80004890:	04893583          	ld	a1,72(s2)
    80004894:	05093503          	ld	a0,80(s2)
    80004898:	cebfc0ef          	jal	80001582 <copyout>
    8000489c:	01650f63          	beq	a0,s6,800048ba <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800048a0:	2184a783          	lw	a5,536(s1)
    800048a4:	2785                	addiw	a5,a5,1
    800048a6:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800048aa:	2a05                	addiw	s4,s4,1
    800048ac:	0985                	addi	s3,s3,1
    800048ae:	fd4a91e3          	bne	s5,s4,80004870 <piperead+0x92>
    800048b2:	7b02                	ld	s6,32(sp)
    800048b4:	6be2                	ld	s7,24(sp)
    800048b6:	6c42                	ld	s8,16(sp)
    800048b8:	a801                	j	800048c8 <piperead+0xea>
      if (i == 0)
    800048ba:	020a0863          	beqz	s4,800048ea <piperead+0x10c>
    800048be:	7b02                	ld	s6,32(sp)
    800048c0:	6be2                	ld	s7,24(sp)
    800048c2:	6c42                	ld	s8,16(sp)
    800048c4:	a011                	j	800048c8 <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048c6:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    800048c8:	21c48513          	addi	a0,s1,540
    800048cc:	f92fd0ef          	jal	8000205e <wakeup>
  release(&pi->lock);
    800048d0:	8526                	mv	a0,s1
    800048d2:	bdefc0ef          	jal	80000cb0 <release>
  return i;
}
    800048d6:	8552                	mv	a0,s4
    800048d8:	60e6                	ld	ra,88(sp)
    800048da:	6446                	ld	s0,80(sp)
    800048dc:	64a6                	ld	s1,72(sp)
    800048de:	6906                	ld	s2,64(sp)
    800048e0:	79e2                	ld	s3,56(sp)
    800048e2:	7a42                	ld	s4,48(sp)
    800048e4:	7aa2                	ld	s5,40(sp)
    800048e6:	6125                	addi	sp,sp,96
    800048e8:	8082                	ret
        i = -1;
    800048ea:	8a2a                	mv	s4,a0
    800048ec:	7b02                	ld	s6,32(sp)
    800048ee:	6be2                	ld	s7,24(sp)
    800048f0:	6c42                	ld	s8,16(sp)
    800048f2:	bfd9                	j	800048c8 <piperead+0xea>
    800048f4:	7b02                	ld	s6,32(sp)
    800048f6:	6be2                	ld	s7,24(sp)
    800048f8:	6c42                	ld	s8,16(sp)
    800048fa:	b7f9                	j	800048c8 <piperead+0xea>

00000000800048fc <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    800048fc:	1141                	addi	sp,sp,-16
    800048fe:	e406                	sd	ra,8(sp)
    80004900:	e022                	sd	s0,0(sp)
    80004902:	0800                	addi	s0,sp,16
    80004904:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004906:	0035151b          	slliw	a0,a0,0x3
    8000490a:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    8000490c:	8b89                	andi	a5,a5,2
    8000490e:	c399                	beqz	a5,80004914 <flags2perm+0x18>
    perm |= PTE_W;
    80004910:	00456513          	ori	a0,a0,4
  return perm;
}
    80004914:	60a2                	ld	ra,8(sp)
    80004916:	6402                	ld	s0,0(sp)
    80004918:	0141                	addi	sp,sp,16
    8000491a:	8082                	ret

000000008000491c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000491c:	de010113          	addi	sp,sp,-544
    80004920:	20113c23          	sd	ra,536(sp)
    80004924:	20813823          	sd	s0,528(sp)
    80004928:	20913423          	sd	s1,520(sp)
    8000492c:	21213023          	sd	s2,512(sp)
    80004930:	1400                	addi	s0,sp,544
    80004932:	892a                	mv	s2,a0
    80004934:	dea43823          	sd	a0,-528(s0)
    80004938:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000493c:	8acfd0ef          	jal	800019e8 <myproc>
    80004940:	84aa                	mv	s1,a0

  begin_op();
    80004942:	c62ff0ef          	jal	80003da4 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004946:	854a                	mv	a0,s2
    80004948:	a7eff0ef          	jal	80003bc6 <namei>
    8000494c:	cd21                	beqz	a0,800049a4 <kexec+0x88>
    8000494e:	fbd2                	sd	s4,496(sp)
    80004950:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004952:	9dbfe0ef          	jal	8000332c <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004956:	04000713          	li	a4,64
    8000495a:	4681                	li	a3,0
    8000495c:	e5040613          	addi	a2,s0,-432
    80004960:	4581                	li	a1,0
    80004962:	8552                	mv	a0,s4
    80004964:	da3fe0ef          	jal	80003706 <readi>
    80004968:	04000793          	li	a5,64
    8000496c:	00f51a63          	bne	a0,a5,80004980 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004970:	e5042703          	lw	a4,-432(s0)
    80004974:	464c47b7          	lui	a5,0x464c4
    80004978:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000497c:	02f70863          	beq	a4,a5,800049ac <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004980:	8552                	mv	a0,s4
    80004982:	bfffe0ef          	jal	80003580 <iunlockput>
    end_op();
    80004986:	caaff0ef          	jal	80003e30 <end_op>
  }
  return -1;
    8000498a:	557d                	li	a0,-1
    8000498c:	7a5e                	ld	s4,496(sp)
}
    8000498e:	21813083          	ld	ra,536(sp)
    80004992:	21013403          	ld	s0,528(sp)
    80004996:	20813483          	ld	s1,520(sp)
    8000499a:	20013903          	ld	s2,512(sp)
    8000499e:	22010113          	addi	sp,sp,544
    800049a2:	8082                	ret
    end_op();
    800049a4:	c8cff0ef          	jal	80003e30 <end_op>
    return -1;
    800049a8:	557d                	li	a0,-1
    800049aa:	b7d5                	j	8000498e <kexec+0x72>
    800049ac:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    800049ae:	8526                	mv	a0,s1
    800049b0:	93efd0ef          	jal	80001aee <proc_pagetable>
    800049b4:	8b2a                	mv	s6,a0
    800049b6:	26050e63          	beqz	a0,80004c32 <kexec+0x316>
    800049ba:	ffce                	sd	s3,504(sp)
    800049bc:	f7d6                	sd	s5,488(sp)
    800049be:	efde                	sd	s7,472(sp)
    800049c0:	ebe2                	sd	s8,464(sp)
    800049c2:	e7e6                	sd	s9,456(sp)
    800049c4:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800049c6:	e8845783          	lhu	a5,-376(s0)
    800049ca:	14078263          	beqz	a5,80004b0e <kexec+0x1f2>
    800049ce:	ff6e                	sd	s11,440(sp)
    800049d0:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800049d4:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800049d6:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049d8:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    800049dc:	6c85                	lui	s9,0x1
    800049de:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800049e2:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    800049e6:	6a85                	lui	s5,0x1
    800049e8:	a085                	j	80004a48 <kexec+0x12c>
      panic("loadseg: address should exist");
    800049ea:	00003517          	auipc	a0,0x3
    800049ee:	c4e50513          	addi	a0,a0,-946 # 80007638 <etext+0x638>
    800049f2:	e43fb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    800049f6:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    800049f8:	874a                	mv	a4,s2
    800049fa:	009b86bb          	addw	a3,s7,s1
    800049fe:	4581                	li	a1,0
    80004a00:	8552                	mv	a0,s4
    80004a02:	d05fe0ef          	jal	80003706 <readi>
    80004a06:	22a91a63          	bne	s2,a0,80004c3a <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004a0a:	009a84bb          	addw	s1,s5,s1
    80004a0e:	0334f263          	bgeu	s1,s3,80004a32 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004a12:	02049593          	slli	a1,s1,0x20
    80004a16:	9181                	srli	a1,a1,0x20
    80004a18:	95e2                	add	a1,a1,s8
    80004a1a:	855a                	mv	a0,s6
    80004a1c:	dfcfc0ef          	jal	80001018 <walkaddr>
    80004a20:	862a                	mv	a2,a0
    if (pa == 0)
    80004a22:	d561                	beqz	a0,800049ea <kexec+0xce>
    if (sz - i < PGSIZE)
    80004a24:	409987bb          	subw	a5,s3,s1
    80004a28:	893e                	mv	s2,a5
    80004a2a:	fcfcf6e3          	bgeu	s9,a5,800049f6 <kexec+0xda>
    80004a2e:	8956                	mv	s2,s5
    80004a30:	b7d9                	j	800049f6 <kexec+0xda>
    sz = sz1;
    80004a32:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a36:	2d05                	addiw	s10,s10,1
    80004a38:	e0843783          	ld	a5,-504(s0)
    80004a3c:	0387869b          	addiw	a3,a5,56
    80004a40:	e8845783          	lhu	a5,-376(s0)
    80004a44:	06fd5d63          	bge	s10,a5,80004abe <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a48:	e0d43423          	sd	a3,-504(s0)
    80004a4c:	876e                	mv	a4,s11
    80004a4e:	e1840613          	addi	a2,s0,-488
    80004a52:	4581                	li	a1,0
    80004a54:	8552                	mv	a0,s4
    80004a56:	cb1fe0ef          	jal	80003706 <readi>
    80004a5a:	1db51e63          	bne	a0,s11,80004c36 <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004a5e:	e1842783          	lw	a5,-488(s0)
    80004a62:	4705                	li	a4,1
    80004a64:	fce799e3          	bne	a5,a4,80004a36 <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004a68:	e4043483          	ld	s1,-448(s0)
    80004a6c:	e3843783          	ld	a5,-456(s0)
    80004a70:	1ef4e363          	bltu	s1,a5,80004c56 <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004a74:	e2843783          	ld	a5,-472(s0)
    80004a78:	94be                	add	s1,s1,a5
    80004a7a:	1ef4e163          	bltu	s1,a5,80004c5c <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004a7e:	de843703          	ld	a4,-536(s0)
    80004a82:	8ff9                	and	a5,a5,a4
    80004a84:	1c079f63          	bnez	a5,80004c62 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004a88:	e1c42503          	lw	a0,-484(s0)
    80004a8c:	e71ff0ef          	jal	800048fc <flags2perm>
    80004a90:	86aa                	mv	a3,a0
    80004a92:	8626                	mv	a2,s1
    80004a94:	85ca                	mv	a1,s2
    80004a96:	855a                	mv	a0,s6
    80004a98:	857fc0ef          	jal	800012ee <uvmalloc>
    80004a9c:	dea43c23          	sd	a0,-520(s0)
    80004aa0:	1c050463          	beqz	a0,80004c68 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004aa4:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004aa8:	00098863          	beqz	s3,80004ab8 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004aac:	e2843c03          	ld	s8,-472(s0)
    80004ab0:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004ab4:	4481                	li	s1,0
    80004ab6:	bfb1                	j	80004a12 <kexec+0xf6>
    sz = sz1;
    80004ab8:	df843903          	ld	s2,-520(s0)
    80004abc:	bfad                	j	80004a36 <kexec+0x11a>
    80004abe:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004ac0:	8552                	mv	a0,s4
    80004ac2:	abffe0ef          	jal	80003580 <iunlockput>
  end_op();
    80004ac6:	b6aff0ef          	jal	80003e30 <end_op>
  p = myproc();
    80004aca:	f1ffc0ef          	jal	800019e8 <myproc>
    80004ace:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004ad0:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004ad4:	6c05                	lui	s8,0x1
    80004ad6:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004ad8:	9c4a                	add	s8,s8,s2
    80004ada:	77fd                	lui	a5,0xfffff
    80004adc:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004ae0:	4691                	li	a3,4
    80004ae2:	6609                	lui	a2,0x2
    80004ae4:	9662                	add	a2,a2,s8
    80004ae6:	85e2                	mv	a1,s8
    80004ae8:	855a                	mv	a0,s6
    80004aea:	805fc0ef          	jal	800012ee <uvmalloc>
    80004aee:	892a                	mv	s2,a0
    80004af0:	e10d                	bnez	a0,80004b12 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004af2:	85e2                	mv	a1,s8
    80004af4:	855a                	mv	a0,s6
    80004af6:	87cfd0ef          	jal	80001b72 <proc_freepagetable>
  return -1;
    80004afa:	557d                	li	a0,-1
    80004afc:	79fe                	ld	s3,504(sp)
    80004afe:	7a5e                	ld	s4,496(sp)
    80004b00:	7abe                	ld	s5,488(sp)
    80004b02:	7b1e                	ld	s6,480(sp)
    80004b04:	6bfe                	ld	s7,472(sp)
    80004b06:	6c5e                	ld	s8,464(sp)
    80004b08:	6cbe                	ld	s9,456(sp)
    80004b0a:	6d1e                	ld	s10,448(sp)
    80004b0c:	b549                	j	8000498e <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b0e:	4901                	li	s2,0
    80004b10:	bf45                	j	80004ac0 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004b12:	75f9                	lui	a1,0xffffe
    80004b14:	95aa                	add	a1,a1,a0
    80004b16:	855a                	mv	a0,s6
    80004b18:	9a9fc0ef          	jal	800014c0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004b1c:	80090a13          	addi	s4,s2,-2048
    80004b20:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004b24:	e0043783          	ld	a5,-512(s0)
    80004b28:	6388                	ld	a0,0(a5)
    80004b2a:	c545                	beqz	a0,80004bd2 <kexec+0x2b6>
  sp = sz;
    80004b2c:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004b2e:	4481                	li	s1,0
    ustack[argc] = sp;
    80004b30:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004b34:	b3efc0ef          	jal	80000e72 <strlen>
    80004b38:	0015079b          	addiw	a5,a0,1
    80004b3c:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004b40:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004b44:	134c6563          	bltu	s8,s4,80004c6e <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004b48:	e0043d03          	ld	s10,-512(s0)
    80004b4c:	000d3c83          	ld	s9,0(s10)
    80004b50:	8566                	mv	a0,s9
    80004b52:	b20fc0ef          	jal	80000e72 <strlen>
    80004b56:	0015071b          	addiw	a4,a0,1
    80004b5a:	86e6                	mv	a3,s9
    80004b5c:	8662                	mv	a2,s8
    80004b5e:	85ca                	mv	a1,s2
    80004b60:	855a                	mv	a0,s6
    80004b62:	a21fc0ef          	jal	80001582 <copyout>
    80004b66:	10054663          	bltz	a0,80004c72 <kexec+0x356>
    ustack[argc] = sp;
    80004b6a:	00349793          	slli	a5,s1,0x3
    80004b6e:	97de                	add	a5,a5,s7
    80004b70:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb8f8>
  for (argc = 0; argv[argc]; argc++) {
    80004b74:	0485                	addi	s1,s1,1
    80004b76:	008d0793          	addi	a5,s10,8
    80004b7a:	e0f43023          	sd	a5,-512(s0)
    80004b7e:	008d3503          	ld	a0,8(s10)
    80004b82:	f94d                	bnez	a0,80004b34 <kexec+0x218>
  ustack[argc] = 0;
    80004b84:	00349793          	slli	a5,s1,0x3
    80004b88:	f9078793          	addi	a5,a5,-112
    80004b8c:	97a2                	add	a5,a5,s0
    80004b8e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004b92:	00349713          	slli	a4,s1,0x3
    80004b96:	0721                	addi	a4,a4,8
    80004b98:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004b9c:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004ba0:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004ba2:	f54be8e3          	bltu	s7,s4,80004af2 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004ba6:	e9040693          	addi	a3,s0,-368
    80004baa:	865e                	mv	a2,s7
    80004bac:	85ca                	mv	a1,s2
    80004bae:	855a                	mv	a0,s6
    80004bb0:	9d3fc0ef          	jal	80001582 <copyout>
    80004bb4:	f2054fe3          	bltz	a0,80004af2 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004bb8:	0589b783          	ld	a5,88(s3)
    80004bbc:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004bc0:	df043783          	ld	a5,-528(s0)
    80004bc4:	0007c703          	lbu	a4,0(a5)
    80004bc8:	c30d                	beqz	a4,80004bea <kexec+0x2ce>
    80004bca:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004bcc:	02f00693          	li	a3,47
    80004bd0:	a801                	j	80004be0 <kexec+0x2c4>
  sp = sz;
    80004bd2:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004bd4:	4481                	li	s1,0
    80004bd6:	b77d                	j	80004b84 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004bd8:	0785                	addi	a5,a5,1
    80004bda:	fff7c703          	lbu	a4,-1(a5)
    80004bde:	c711                	beqz	a4,80004bea <kexec+0x2ce>
    if (*s == '/')
    80004be0:	fed71ce3          	bne	a4,a3,80004bd8 <kexec+0x2bc>
      last = s + 1;
    80004be4:	def43823          	sd	a5,-528(s0)
    80004be8:	bfc5                	j	80004bd8 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004bea:	4641                	li	a2,16
    80004bec:	df043583          	ld	a1,-528(s0)
    80004bf0:	15898513          	addi	a0,s3,344
    80004bf4:	a48fc0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004bf8:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004bfc:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004c00:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004c04:	0589b783          	ld	a5,88(s3)
    80004c08:	e6843703          	ld	a4,-408(s0)
    80004c0c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004c0e:	0589b783          	ld	a5,88(s3)
    80004c12:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004c16:	85d6                	mv	a1,s5
    80004c18:	f5bfc0ef          	jal	80001b72 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004c1c:	0004851b          	sext.w	a0,s1
    80004c20:	79fe                	ld	s3,504(sp)
    80004c22:	7a5e                	ld	s4,496(sp)
    80004c24:	7abe                	ld	s5,488(sp)
    80004c26:	7b1e                	ld	s6,480(sp)
    80004c28:	6bfe                	ld	s7,472(sp)
    80004c2a:	6c5e                	ld	s8,464(sp)
    80004c2c:	6cbe                	ld	s9,456(sp)
    80004c2e:	6d1e                	ld	s10,448(sp)
    80004c30:	bbb9                	j	8000498e <kexec+0x72>
    80004c32:	7b1e                	ld	s6,480(sp)
    80004c34:	b3b1                	j	80004980 <kexec+0x64>
    80004c36:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004c3a:	df843583          	ld	a1,-520(s0)
    80004c3e:	855a                	mv	a0,s6
    80004c40:	f33fc0ef          	jal	80001b72 <proc_freepagetable>
  if (ip) {
    80004c44:	79fe                	ld	s3,504(sp)
    80004c46:	7abe                	ld	s5,488(sp)
    80004c48:	7b1e                	ld	s6,480(sp)
    80004c4a:	6bfe                	ld	s7,472(sp)
    80004c4c:	6c5e                	ld	s8,464(sp)
    80004c4e:	6cbe                	ld	s9,456(sp)
    80004c50:	6d1e                	ld	s10,448(sp)
    80004c52:	7dfa                	ld	s11,440(sp)
    80004c54:	b335                	j	80004980 <kexec+0x64>
    80004c56:	df243c23          	sd	s2,-520(s0)
    80004c5a:	b7c5                	j	80004c3a <kexec+0x31e>
    80004c5c:	df243c23          	sd	s2,-520(s0)
    80004c60:	bfe9                	j	80004c3a <kexec+0x31e>
    80004c62:	df243c23          	sd	s2,-520(s0)
    80004c66:	bfd1                	j	80004c3a <kexec+0x31e>
    80004c68:	df243c23          	sd	s2,-520(s0)
    80004c6c:	b7f9                	j	80004c3a <kexec+0x31e>
  sz = sz1;
    80004c6e:	8c4a                	mv	s8,s2
    80004c70:	b549                	j	80004af2 <kexec+0x1d6>
    80004c72:	8c4a                	mv	s8,s2
    80004c74:	bdbd                	j	80004af2 <kexec+0x1d6>

0000000080004c76 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004c76:	7179                	addi	sp,sp,-48
    80004c78:	f406                	sd	ra,40(sp)
    80004c7a:	f022                	sd	s0,32(sp)
    80004c7c:	ec26                	sd	s1,24(sp)
    80004c7e:	e84a                	sd	s2,16(sp)
    80004c80:	1800                	addi	s0,sp,48
    80004c82:	892e                	mv	s2,a1
    80004c84:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004c86:	fdc40593          	addi	a1,s0,-36
    80004c8a:	ca7fd0ef          	jal	80002930 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004c8e:	fdc42703          	lw	a4,-36(s0)
    80004c92:	47bd                	li	a5,15
    80004c94:	02e7ea63          	bltu	a5,a4,80004cc8 <argfd+0x52>
    80004c98:	d51fc0ef          	jal	800019e8 <myproc>
    80004c9c:	fdc42703          	lw	a4,-36(s0)
    80004ca0:	00371793          	slli	a5,a4,0x3
    80004ca4:	0d078793          	addi	a5,a5,208
    80004ca8:	953e                	add	a0,a0,a5
    80004caa:	611c                	ld	a5,0(a0)
    80004cac:	c385                	beqz	a5,80004ccc <argfd+0x56>
    return -1;
  if (pfd)
    80004cae:	00090463          	beqz	s2,80004cb6 <argfd+0x40>
    *pfd = fd;
    80004cb2:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004cb6:	4501                	li	a0,0
  if (pf)
    80004cb8:	c091                	beqz	s1,80004cbc <argfd+0x46>
    *pf = f;
    80004cba:	e09c                	sd	a5,0(s1)
}
    80004cbc:	70a2                	ld	ra,40(sp)
    80004cbe:	7402                	ld	s0,32(sp)
    80004cc0:	64e2                	ld	s1,24(sp)
    80004cc2:	6942                	ld	s2,16(sp)
    80004cc4:	6145                	addi	sp,sp,48
    80004cc6:	8082                	ret
    return -1;
    80004cc8:	557d                	li	a0,-1
    80004cca:	bfcd                	j	80004cbc <argfd+0x46>
    80004ccc:	557d                	li	a0,-1
    80004cce:	b7fd                	j	80004cbc <argfd+0x46>

0000000080004cd0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004cd0:	1101                	addi	sp,sp,-32
    80004cd2:	ec06                	sd	ra,24(sp)
    80004cd4:	e822                	sd	s0,16(sp)
    80004cd6:	e426                	sd	s1,8(sp)
    80004cd8:	1000                	addi	s0,sp,32
    80004cda:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004cdc:	d0dfc0ef          	jal	800019e8 <myproc>
    80004ce0:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004ce2:	0d050793          	addi	a5,a0,208
    80004ce6:	4501                	li	a0,0
    80004ce8:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004cea:	6398                	ld	a4,0(a5)
    80004cec:	cb19                	beqz	a4,80004d02 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004cee:	2505                	addiw	a0,a0,1
    80004cf0:	07a1                	addi	a5,a5,8
    80004cf2:	fed51ce3          	bne	a0,a3,80004cea <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004cf6:	557d                	li	a0,-1
}
    80004cf8:	60e2                	ld	ra,24(sp)
    80004cfa:	6442                	ld	s0,16(sp)
    80004cfc:	64a2                	ld	s1,8(sp)
    80004cfe:	6105                	addi	sp,sp,32
    80004d00:	8082                	ret
      p->ofile[fd] = f;
    80004d02:	00351793          	slli	a5,a0,0x3
    80004d06:	0d078793          	addi	a5,a5,208
    80004d0a:	963e                	add	a2,a2,a5
    80004d0c:	e204                	sd	s1,0(a2)
      return fd;
    80004d0e:	b7ed                	j	80004cf8 <fdalloc+0x28>

0000000080004d10 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004d10:	715d                	addi	sp,sp,-80
    80004d12:	e486                	sd	ra,72(sp)
    80004d14:	e0a2                	sd	s0,64(sp)
    80004d16:	fc26                	sd	s1,56(sp)
    80004d18:	f84a                	sd	s2,48(sp)
    80004d1a:	f052                	sd	s4,32(sp)
    80004d1c:	ec56                	sd	s5,24(sp)
    80004d1e:	e85a                	sd	s6,16(sp)
    80004d20:	0880                	addi	s0,sp,80
    80004d22:	8a2e                	mv	s4,a1
    80004d24:	8ab2                	mv	s5,a2
    80004d26:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004d28:	fb040593          	addi	a1,s0,-80
    80004d2c:	eb5fe0ef          	jal	80003be0 <nameiparent>
    80004d30:	84aa                	mv	s1,a0
    80004d32:	12050f63          	beqz	a0,80004e70 <create+0x160>
    return 0;

  ilock(dp);
    80004d36:	df6fe0ef          	jal	8000332c <ilock>

  if (dp->nlink == 0) {
    80004d3a:	04a49783          	lh	a5,74(s1)
    80004d3e:	cbb9                	beqz	a5,80004d94 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004d40:	7761                	lui	a4,0xffff8
    80004d42:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd48f9>
    80004d44:	97ba                	add	a5,a5,a4
    80004d46:	e781                	bnez	a5,80004d4e <create+0x3e>
    80004d48:	fffa0793          	addi	a5,s4,-1
    80004d4c:	cba9                	beqz	a5,80004d9e <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004d4e:	4601                	li	a2,0
    80004d50:	fb040593          	addi	a1,s0,-80
    80004d54:	8526                	mv	a0,s1
    80004d56:	bbffe0ef          	jal	80003914 <dirlookup>
    80004d5a:	892a                	mv	s2,a0
    80004d5c:	c939                	beqz	a0,80004db2 <create+0xa2>
    iunlockput(dp);
    80004d5e:	8526                	mv	a0,s1
    80004d60:	821fe0ef          	jal	80003580 <iunlockput>
    ilock(ip);
    80004d64:	854a                	mv	a0,s2
    80004d66:	dc6fe0ef          	jal	8000332c <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004d6a:	4789                	li	a5,2
    80004d6c:	02fa1e63          	bne	s4,a5,80004da8 <create+0x98>
    80004d70:	04495783          	lhu	a5,68(s2)
    80004d74:	37f9                	addiw	a5,a5,-2
    80004d76:	17c2                	slli	a5,a5,0x30
    80004d78:	93c1                	srli	a5,a5,0x30
    80004d7a:	4705                	li	a4,1
    80004d7c:	02f76663          	bltu	a4,a5,80004da8 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004d80:	854a                	mv	a0,s2
    80004d82:	60a6                	ld	ra,72(sp)
    80004d84:	6406                	ld	s0,64(sp)
    80004d86:	74e2                	ld	s1,56(sp)
    80004d88:	7942                	ld	s2,48(sp)
    80004d8a:	7a02                	ld	s4,32(sp)
    80004d8c:	6ae2                	ld	s5,24(sp)
    80004d8e:	6b42                	ld	s6,16(sp)
    80004d90:	6161                	addi	sp,sp,80
    80004d92:	8082                	ret
    iunlockput(dp);
    80004d94:	8526                	mv	a0,s1
    80004d96:	feafe0ef          	jal	80003580 <iunlockput>
    return 0;
    80004d9a:	4901                	li	s2,0
    80004d9c:	b7d5                	j	80004d80 <create+0x70>
    iunlockput(dp);
    80004d9e:	8526                	mv	a0,s1
    80004da0:	fe0fe0ef          	jal	80003580 <iunlockput>
    return 0;
    80004da4:	4901                	li	s2,0
    80004da6:	bfe9                	j	80004d80 <create+0x70>
    iunlockput(ip);
    80004da8:	854a                	mv	a0,s2
    80004daa:	fd6fe0ef          	jal	80003580 <iunlockput>
    return 0;
    80004dae:	4901                	li	s2,0
    80004db0:	bfc1                	j	80004d80 <create+0x70>
    80004db2:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004db4:	85d2                	mv	a1,s4
    80004db6:	4088                	lw	a0,0(s1)
    80004db8:	c04fe0ef          	jal	800031bc <ialloc>
    80004dbc:	89aa                	mv	s3,a0
    80004dbe:	cd1d                	beqz	a0,80004dfc <create+0xec>
  ilock(ip);
    80004dc0:	d6cfe0ef          	jal	8000332c <ilock>
  ip->major = major;
    80004dc4:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004dc8:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004dcc:	4705                	li	a4,1
    80004dce:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004dd2:	854e                	mv	a0,s3
    80004dd4:	ca4fe0ef          	jal	80003278 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004dd8:	4705                	li	a4,1
    80004dda:	02ea0763          	beq	s4,a4,80004e08 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004dde:	0049a603          	lw	a2,4(s3)
    80004de2:	fb040593          	addi	a1,s0,-80
    80004de6:	8526                	mv	a0,s1
    80004de8:	d35fe0ef          	jal	80003b1c <dirlink>
    80004dec:	06054563          	bltz	a0,80004e56 <create+0x146>
  iunlockput(dp);
    80004df0:	8526                	mv	a0,s1
    80004df2:	f8efe0ef          	jal	80003580 <iunlockput>
  return ip;
    80004df6:	894e                	mv	s2,s3
    80004df8:	79a2                	ld	s3,40(sp)
    80004dfa:	b759                	j	80004d80 <create+0x70>
    iunlockput(dp);
    80004dfc:	8526                	mv	a0,s1
    80004dfe:	f82fe0ef          	jal	80003580 <iunlockput>
    return 0;
    80004e02:	894e                	mv	s2,s3
    80004e04:	79a2                	ld	s3,40(sp)
    80004e06:	bfad                	j	80004d80 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004e08:	0049a603          	lw	a2,4(s3)
    80004e0c:	00003597          	auipc	a1,0x3
    80004e10:	84c58593          	addi	a1,a1,-1972 # 80007658 <etext+0x658>
    80004e14:	854e                	mv	a0,s3
    80004e16:	d07fe0ef          	jal	80003b1c <dirlink>
    80004e1a:	02054e63          	bltz	a0,80004e56 <create+0x146>
    80004e1e:	40d0                	lw	a2,4(s1)
    80004e20:	00003597          	auipc	a1,0x3
    80004e24:	84058593          	addi	a1,a1,-1984 # 80007660 <etext+0x660>
    80004e28:	854e                	mv	a0,s3
    80004e2a:	cf3fe0ef          	jal	80003b1c <dirlink>
    80004e2e:	02054463          	bltz	a0,80004e56 <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004e32:	0049a603          	lw	a2,4(s3)
    80004e36:	fb040593          	addi	a1,s0,-80
    80004e3a:	8526                	mv	a0,s1
    80004e3c:	ce1fe0ef          	jal	80003b1c <dirlink>
    80004e40:	00054b63          	bltz	a0,80004e56 <create+0x146>
    dp->nlink++; // for ".."
    80004e44:	04a4d783          	lhu	a5,74(s1)
    80004e48:	2785                	addiw	a5,a5,1
    80004e4a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e4e:	8526                	mv	a0,s1
    80004e50:	c28fe0ef          	jal	80003278 <iupdate>
    80004e54:	bf71                	j	80004df0 <create+0xe0>
  ip->nlink = 0;
    80004e56:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004e5a:	854e                	mv	a0,s3
    80004e5c:	c1cfe0ef          	jal	80003278 <iupdate>
  iunlockput(ip);
    80004e60:	854e                	mv	a0,s3
    80004e62:	f1efe0ef          	jal	80003580 <iunlockput>
  iunlockput(dp);
    80004e66:	8526                	mv	a0,s1
    80004e68:	f18fe0ef          	jal	80003580 <iunlockput>
  return 0;
    80004e6c:	79a2                	ld	s3,40(sp)
    80004e6e:	bf09                	j	80004d80 <create+0x70>
    return 0;
    80004e70:	892a                	mv	s2,a0
    80004e72:	b739                	j	80004d80 <create+0x70>

0000000080004e74 <sys_dup>:
{
    80004e74:	7179                	addi	sp,sp,-48
    80004e76:	f406                	sd	ra,40(sp)
    80004e78:	f022                	sd	s0,32(sp)
    80004e7a:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004e7c:	fd840613          	addi	a2,s0,-40
    80004e80:	4581                	li	a1,0
    80004e82:	4501                	li	a0,0
    80004e84:	df3ff0ef          	jal	80004c76 <argfd>
    return -1;
    80004e88:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004e8a:	02054363          	bltz	a0,80004eb0 <sys_dup+0x3c>
    80004e8e:	ec26                	sd	s1,24(sp)
    80004e90:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004e92:	fd843483          	ld	s1,-40(s0)
    80004e96:	8526                	mv	a0,s1
    80004e98:	e39ff0ef          	jal	80004cd0 <fdalloc>
    80004e9c:	892a                	mv	s2,a0
    return -1;
    80004e9e:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004ea0:	00054d63          	bltz	a0,80004eba <sys_dup+0x46>
  filedup(f);
    80004ea4:	8526                	mv	a0,s1
    80004ea6:	b72ff0ef          	jal	80004218 <filedup>
  return fd;
    80004eaa:	87ca                	mv	a5,s2
    80004eac:	64e2                	ld	s1,24(sp)
    80004eae:	6942                	ld	s2,16(sp)
}
    80004eb0:	853e                	mv	a0,a5
    80004eb2:	70a2                	ld	ra,40(sp)
    80004eb4:	7402                	ld	s0,32(sp)
    80004eb6:	6145                	addi	sp,sp,48
    80004eb8:	8082                	ret
    80004eba:	64e2                	ld	s1,24(sp)
    80004ebc:	6942                	ld	s2,16(sp)
    80004ebe:	bfcd                	j	80004eb0 <sys_dup+0x3c>

0000000080004ec0 <sys_read>:
{
    80004ec0:	7179                	addi	sp,sp,-48
    80004ec2:	f406                	sd	ra,40(sp)
    80004ec4:	f022                	sd	s0,32(sp)
    80004ec6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ec8:	fd840593          	addi	a1,s0,-40
    80004ecc:	4505                	li	a0,1
    80004ece:	a7ffd0ef          	jal	8000294c <argaddr>
  argint(2, &n);
    80004ed2:	fe440593          	addi	a1,s0,-28
    80004ed6:	4509                	li	a0,2
    80004ed8:	a59fd0ef          	jal	80002930 <argint>
  if (argfd(0, 0, &f) < 0)
    80004edc:	fe840613          	addi	a2,s0,-24
    80004ee0:	4581                	li	a1,0
    80004ee2:	4501                	li	a0,0
    80004ee4:	d93ff0ef          	jal	80004c76 <argfd>
    80004ee8:	87aa                	mv	a5,a0
    return -1;
    80004eea:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004eec:	0007ca63          	bltz	a5,80004f00 <sys_read+0x40>
  return fileread(f, p, n);
    80004ef0:	fe442603          	lw	a2,-28(s0)
    80004ef4:	fd843583          	ld	a1,-40(s0)
    80004ef8:	fe843503          	ld	a0,-24(s0)
    80004efc:	c94ff0ef          	jal	80004390 <fileread>
}
    80004f00:	70a2                	ld	ra,40(sp)
    80004f02:	7402                	ld	s0,32(sp)
    80004f04:	6145                	addi	sp,sp,48
    80004f06:	8082                	ret

0000000080004f08 <sys_write>:
{
    80004f08:	7179                	addi	sp,sp,-48
    80004f0a:	f406                	sd	ra,40(sp)
    80004f0c:	f022                	sd	s0,32(sp)
    80004f0e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f10:	fd840593          	addi	a1,s0,-40
    80004f14:	4505                	li	a0,1
    80004f16:	a37fd0ef          	jal	8000294c <argaddr>
  argint(2, &n);
    80004f1a:	fe440593          	addi	a1,s0,-28
    80004f1e:	4509                	li	a0,2
    80004f20:	a11fd0ef          	jal	80002930 <argint>
  if (argfd(0, 0, &f) < 0)
    80004f24:	fe840613          	addi	a2,s0,-24
    80004f28:	4581                	li	a1,0
    80004f2a:	4501                	li	a0,0
    80004f2c:	d4bff0ef          	jal	80004c76 <argfd>
    80004f30:	87aa                	mv	a5,a0
    return -1;
    80004f32:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004f34:	0007ca63          	bltz	a5,80004f48 <sys_write+0x40>
  return filewrite(f, p, n);
    80004f38:	fe442603          	lw	a2,-28(s0)
    80004f3c:	fd843583          	ld	a1,-40(s0)
    80004f40:	fe843503          	ld	a0,-24(s0)
    80004f44:	d1aff0ef          	jal	8000445e <filewrite>
}
    80004f48:	70a2                	ld	ra,40(sp)
    80004f4a:	7402                	ld	s0,32(sp)
    80004f4c:	6145                	addi	sp,sp,48
    80004f4e:	8082                	ret

0000000080004f50 <sys_close>:
{
    80004f50:	1101                	addi	sp,sp,-32
    80004f52:	ec06                	sd	ra,24(sp)
    80004f54:	e822                	sd	s0,16(sp)
    80004f56:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004f58:	fe040613          	addi	a2,s0,-32
    80004f5c:	fec40593          	addi	a1,s0,-20
    80004f60:	4501                	li	a0,0
    80004f62:	d15ff0ef          	jal	80004c76 <argfd>
    return -1;
    80004f66:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004f68:	02054163          	bltz	a0,80004f8a <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004f6c:	a7dfc0ef          	jal	800019e8 <myproc>
    80004f70:	fec42783          	lw	a5,-20(s0)
    80004f74:	078e                	slli	a5,a5,0x3
    80004f76:	0d078793          	addi	a5,a5,208
    80004f7a:	953e                	add	a0,a0,a5
    80004f7c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f80:	fe043503          	ld	a0,-32(s0)
    80004f84:	adaff0ef          	jal	8000425e <fileclose>
  return 0;
    80004f88:	4781                	li	a5,0
}
    80004f8a:	853e                	mv	a0,a5
    80004f8c:	60e2                	ld	ra,24(sp)
    80004f8e:	6442                	ld	s0,16(sp)
    80004f90:	6105                	addi	sp,sp,32
    80004f92:	8082                	ret

0000000080004f94 <sys_fstat>:
{
    80004f94:	1101                	addi	sp,sp,-32
    80004f96:	ec06                	sd	ra,24(sp)
    80004f98:	e822                	sd	s0,16(sp)
    80004f9a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004f9c:	fe040593          	addi	a1,s0,-32
    80004fa0:	4505                	li	a0,1
    80004fa2:	9abfd0ef          	jal	8000294c <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004fa6:	fe840613          	addi	a2,s0,-24
    80004faa:	4581                	li	a1,0
    80004fac:	4501                	li	a0,0
    80004fae:	cc9ff0ef          	jal	80004c76 <argfd>
    80004fb2:	87aa                	mv	a5,a0
    return -1;
    80004fb4:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004fb6:	0007c863          	bltz	a5,80004fc6 <sys_fstat+0x32>
  return filestat(f, st);
    80004fba:	fe043583          	ld	a1,-32(s0)
    80004fbe:	fe843503          	ld	a0,-24(s0)
    80004fc2:	b5eff0ef          	jal	80004320 <filestat>
}
    80004fc6:	60e2                	ld	ra,24(sp)
    80004fc8:	6442                	ld	s0,16(sp)
    80004fca:	6105                	addi	sp,sp,32
    80004fcc:	8082                	ret

0000000080004fce <sys_link>:
{
    80004fce:	7169                	addi	sp,sp,-304
    80004fd0:	f606                	sd	ra,296(sp)
    80004fd2:	f222                	sd	s0,288(sp)
    80004fd4:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fd6:	08000613          	li	a2,128
    80004fda:	ed040593          	addi	a1,s0,-304
    80004fde:	4501                	li	a0,0
    80004fe0:	989fd0ef          	jal	80002968 <argstr>
    return -1;
    80004fe4:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fe6:	10054163          	bltz	a0,800050e8 <sys_link+0x11a>
    80004fea:	08000613          	li	a2,128
    80004fee:	f5040593          	addi	a1,s0,-176
    80004ff2:	4505                	li	a0,1
    80004ff4:	975fd0ef          	jal	80002968 <argstr>
    return -1;
    80004ff8:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ffa:	0e054763          	bltz	a0,800050e8 <sys_link+0x11a>
    80004ffe:	ee26                	sd	s1,280(sp)
  begin_op();
    80005000:	da5fe0ef          	jal	80003da4 <begin_op>
  if ((ip = namei(old)) == 0) {
    80005004:	ed040513          	addi	a0,s0,-304
    80005008:	bbffe0ef          	jal	80003bc6 <namei>
    8000500c:	84aa                	mv	s1,a0
    8000500e:	cd35                	beqz	a0,8000508a <sys_link+0xbc>
  ilock(ip);
    80005010:	b1cfe0ef          	jal	8000332c <ilock>
  if (ip->type == T_DIR) {
    80005014:	04449703          	lh	a4,68(s1)
    80005018:	4785                	li	a5,1
    8000501a:	06f70d63          	beq	a4,a5,80005094 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    8000501e:	04a49783          	lh	a5,74(s1)
    80005022:	6721                	lui	a4,0x8
    80005024:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80005026:	06e78f63          	beq	a5,a4,800050a4 <sys_link+0xd6>
    8000502a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000502c:	2785                	addiw	a5,a5,1
    8000502e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005032:	8526                	mv	a0,s1
    80005034:	a44fe0ef          	jal	80003278 <iupdate>
  iunlock(ip);
    80005038:	8526                	mv	a0,s1
    8000503a:	ba0fe0ef          	jal	800033da <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    8000503e:	fd040593          	addi	a1,s0,-48
    80005042:	f5040513          	addi	a0,s0,-176
    80005046:	b9bfe0ef          	jal	80003be0 <nameiparent>
    8000504a:	892a                	mv	s2,a0
    8000504c:	c93d                	beqz	a0,800050c2 <sys_link+0xf4>
  ilock(dp);
    8000504e:	adefe0ef          	jal	8000332c <ilock>
  if (dp->nlink == 0) {
    80005052:	04a91783          	lh	a5,74(s2)
    80005056:	cfb9                	beqz	a5,800050b4 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80005058:	854a                	mv	a0,s2
    8000505a:	00092703          	lw	a4,0(s2)
    8000505e:	409c                	lw	a5,0(s1)
    80005060:	04f71e63          	bne	a4,a5,800050bc <sys_link+0xee>
    80005064:	40d0                	lw	a2,4(s1)
    80005066:	fd040593          	addi	a1,s0,-48
    8000506a:	ab3fe0ef          	jal	80003b1c <dirlink>
    8000506e:	04054763          	bltz	a0,800050bc <sys_link+0xee>
  iunlockput(dp);
    80005072:	854a                	mv	a0,s2
    80005074:	d0cfe0ef          	jal	80003580 <iunlockput>
  iput(ip);
    80005078:	8526                	mv	a0,s1
    8000507a:	c34fe0ef          	jal	800034ae <iput>
  end_op();
    8000507e:	db3fe0ef          	jal	80003e30 <end_op>
  return 0;
    80005082:	4781                	li	a5,0
    80005084:	64f2                	ld	s1,280(sp)
    80005086:	6952                	ld	s2,272(sp)
    80005088:	a085                	j	800050e8 <sys_link+0x11a>
    end_op();
    8000508a:	da7fe0ef          	jal	80003e30 <end_op>
    return -1;
    8000508e:	57fd                	li	a5,-1
    80005090:	64f2                	ld	s1,280(sp)
    80005092:	a899                	j	800050e8 <sys_link+0x11a>
    iunlockput(ip);
    80005094:	8526                	mv	a0,s1
    80005096:	ceafe0ef          	jal	80003580 <iunlockput>
    end_op();
    8000509a:	d97fe0ef          	jal	80003e30 <end_op>
    return -1;
    8000509e:	57fd                	li	a5,-1
    800050a0:	64f2                	ld	s1,280(sp)
    800050a2:	a099                	j	800050e8 <sys_link+0x11a>
    iunlockput(ip);
    800050a4:	8526                	mv	a0,s1
    800050a6:	cdafe0ef          	jal	80003580 <iunlockput>
    end_op();
    800050aa:	d87fe0ef          	jal	80003e30 <end_op>
    return -1;
    800050ae:	57fd                	li	a5,-1
    800050b0:	64f2                	ld	s1,280(sp)
    800050b2:	a81d                	j	800050e8 <sys_link+0x11a>
    iunlockput(dp);
    800050b4:	854a                	mv	a0,s2
    800050b6:	ccafe0ef          	jal	80003580 <iunlockput>
    goto bad;
    800050ba:	a021                	j	800050c2 <sys_link+0xf4>
    iunlockput(dp);
    800050bc:	854a                	mv	a0,s2
    800050be:	cc2fe0ef          	jal	80003580 <iunlockput>
  ilock(ip);
    800050c2:	8526                	mv	a0,s1
    800050c4:	a68fe0ef          	jal	8000332c <ilock>
  ip->nlink--;
    800050c8:	04a4d783          	lhu	a5,74(s1)
    800050cc:	37fd                	addiw	a5,a5,-1
    800050ce:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050d2:	8526                	mv	a0,s1
    800050d4:	9a4fe0ef          	jal	80003278 <iupdate>
  iunlockput(ip);
    800050d8:	8526                	mv	a0,s1
    800050da:	ca6fe0ef          	jal	80003580 <iunlockput>
  end_op();
    800050de:	d53fe0ef          	jal	80003e30 <end_op>
  return -1;
    800050e2:	57fd                	li	a5,-1
    800050e4:	64f2                	ld	s1,280(sp)
    800050e6:	6952                	ld	s2,272(sp)
}
    800050e8:	853e                	mv	a0,a5
    800050ea:	70b2                	ld	ra,296(sp)
    800050ec:	7412                	ld	s0,288(sp)
    800050ee:	6155                	addi	sp,sp,304
    800050f0:	8082                	ret

00000000800050f2 <sys_unlink>:
{
    800050f2:	7151                	addi	sp,sp,-240
    800050f4:	f586                	sd	ra,232(sp)
    800050f6:	f1a2                	sd	s0,224(sp)
    800050f8:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    800050fa:	08000613          	li	a2,128
    800050fe:	f3040593          	addi	a1,s0,-208
    80005102:	4501                	li	a0,0
    80005104:	865fd0ef          	jal	80002968 <argstr>
    80005108:	14054d63          	bltz	a0,80005262 <sys_unlink+0x170>
    8000510c:	eda6                	sd	s1,216(sp)
  begin_op();
    8000510e:	c97fe0ef          	jal	80003da4 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80005112:	fb040593          	addi	a1,s0,-80
    80005116:	f3040513          	addi	a0,s0,-208
    8000511a:	ac7fe0ef          	jal	80003be0 <nameiparent>
    8000511e:	84aa                	mv	s1,a0
    80005120:	c955                	beqz	a0,800051d4 <sys_unlink+0xe2>
  ilock(dp);
    80005122:	a0afe0ef          	jal	8000332c <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005126:	00002597          	auipc	a1,0x2
    8000512a:	53258593          	addi	a1,a1,1330 # 80007658 <etext+0x658>
    8000512e:	fb040513          	addi	a0,s0,-80
    80005132:	fccfe0ef          	jal	800038fe <namecmp>
    80005136:	10050b63          	beqz	a0,8000524c <sys_unlink+0x15a>
    8000513a:	00002597          	auipc	a1,0x2
    8000513e:	52658593          	addi	a1,a1,1318 # 80007660 <etext+0x660>
    80005142:	fb040513          	addi	a0,s0,-80
    80005146:	fb8fe0ef          	jal	800038fe <namecmp>
    8000514a:	10050163          	beqz	a0,8000524c <sys_unlink+0x15a>
    8000514e:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005150:	f2c40613          	addi	a2,s0,-212
    80005154:	fb040593          	addi	a1,s0,-80
    80005158:	8526                	mv	a0,s1
    8000515a:	fbafe0ef          	jal	80003914 <dirlookup>
    8000515e:	892a                	mv	s2,a0
    80005160:	0e050563          	beqz	a0,8000524a <sys_unlink+0x158>
    80005164:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005166:	9c6fe0ef          	jal	8000332c <ilock>
  if (ip->nlink < 1)
    8000516a:	04a91783          	lh	a5,74(s2)
    8000516e:	06f05863          	blez	a5,800051de <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    80005172:	04491703          	lh	a4,68(s2)
    80005176:	4785                	li	a5,1
    80005178:	06f70963          	beq	a4,a5,800051ea <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    8000517c:	fc040993          	addi	s3,s0,-64
    80005180:	4641                	li	a2,16
    80005182:	4581                	li	a1,0
    80005184:	854e                	mv	a0,s3
    80005186:	b63fb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000518a:	4741                	li	a4,16
    8000518c:	f2c42683          	lw	a3,-212(s0)
    80005190:	864e                	mv	a2,s3
    80005192:	4581                	li	a1,0
    80005194:	8526                	mv	a0,s1
    80005196:	e62fe0ef          	jal	800037f8 <writei>
    8000519a:	47c1                	li	a5,16
    8000519c:	08f51863          	bne	a0,a5,8000522c <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    800051a0:	04491703          	lh	a4,68(s2)
    800051a4:	4785                	li	a5,1
    800051a6:	08f70963          	beq	a4,a5,80005238 <sys_unlink+0x146>
  iunlockput(dp);
    800051aa:	8526                	mv	a0,s1
    800051ac:	bd4fe0ef          	jal	80003580 <iunlockput>
  ip->nlink--;
    800051b0:	04a95783          	lhu	a5,74(s2)
    800051b4:	37fd                	addiw	a5,a5,-1
    800051b6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800051ba:	854a                	mv	a0,s2
    800051bc:	8bcfe0ef          	jal	80003278 <iupdate>
  iunlockput(ip);
    800051c0:	854a                	mv	a0,s2
    800051c2:	bbefe0ef          	jal	80003580 <iunlockput>
  end_op();
    800051c6:	c6bfe0ef          	jal	80003e30 <end_op>
  return 0;
    800051ca:	4501                	li	a0,0
    800051cc:	64ee                	ld	s1,216(sp)
    800051ce:	694e                	ld	s2,208(sp)
    800051d0:	69ae                	ld	s3,200(sp)
    800051d2:	a061                	j	8000525a <sys_unlink+0x168>
    end_op();
    800051d4:	c5dfe0ef          	jal	80003e30 <end_op>
    return -1;
    800051d8:	557d                	li	a0,-1
    800051da:	64ee                	ld	s1,216(sp)
    800051dc:	a8bd                	j	8000525a <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800051de:	00002517          	auipc	a0,0x2
    800051e2:	48a50513          	addi	a0,a0,1162 # 80007668 <etext+0x668>
    800051e6:	e4efb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800051ea:	04c92703          	lw	a4,76(s2)
    800051ee:	02000793          	li	a5,32
    800051f2:	f8e7f5e3          	bgeu	a5,a4,8000517c <sys_unlink+0x8a>
    800051f6:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051f8:	4741                	li	a4,16
    800051fa:	86ce                	mv	a3,s3
    800051fc:	f1840613          	addi	a2,s0,-232
    80005200:	4581                	li	a1,0
    80005202:	854a                	mv	a0,s2
    80005204:	d02fe0ef          	jal	80003706 <readi>
    80005208:	47c1                	li	a5,16
    8000520a:	00f51b63          	bne	a0,a5,80005220 <sys_unlink+0x12e>
    if (de.inum != 0)
    8000520e:	f1845783          	lhu	a5,-232(s0)
    80005212:	ebb1                	bnez	a5,80005266 <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005214:	29c1                	addiw	s3,s3,16
    80005216:	04c92783          	lw	a5,76(s2)
    8000521a:	fcf9efe3          	bltu	s3,a5,800051f8 <sys_unlink+0x106>
    8000521e:	bfb9                	j	8000517c <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005220:	00002517          	auipc	a0,0x2
    80005224:	46050513          	addi	a0,a0,1120 # 80007680 <etext+0x680>
    80005228:	e0cfb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    8000522c:	00002517          	auipc	a0,0x2
    80005230:	46c50513          	addi	a0,a0,1132 # 80007698 <etext+0x698>
    80005234:	e00fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    80005238:	04a4d783          	lhu	a5,74(s1)
    8000523c:	37fd                	addiw	a5,a5,-1
    8000523e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005242:	8526                	mv	a0,s1
    80005244:	834fe0ef          	jal	80003278 <iupdate>
    80005248:	b78d                	j	800051aa <sys_unlink+0xb8>
    8000524a:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000524c:	8526                	mv	a0,s1
    8000524e:	b32fe0ef          	jal	80003580 <iunlockput>
  end_op();
    80005252:	bdffe0ef          	jal	80003e30 <end_op>
  return -1;
    80005256:	557d                	li	a0,-1
    80005258:	64ee                	ld	s1,216(sp)
}
    8000525a:	70ae                	ld	ra,232(sp)
    8000525c:	740e                	ld	s0,224(sp)
    8000525e:	616d                	addi	sp,sp,240
    80005260:	8082                	ret
    return -1;
    80005262:	557d                	li	a0,-1
    80005264:	bfdd                	j	8000525a <sys_unlink+0x168>
    iunlockput(ip);
    80005266:	854a                	mv	a0,s2
    80005268:	b18fe0ef          	jal	80003580 <iunlockput>
    goto bad;
    8000526c:	694e                	ld	s2,208(sp)
    8000526e:	69ae                	ld	s3,200(sp)
    80005270:	bff1                	j	8000524c <sys_unlink+0x15a>

0000000080005272 <sys_open>:

uint64
sys_open(void)
{
    80005272:	7131                	addi	sp,sp,-192
    80005274:	fd06                	sd	ra,184(sp)
    80005276:	f922                	sd	s0,176(sp)
    80005278:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000527a:	f4c40593          	addi	a1,s0,-180
    8000527e:	4505                	li	a0,1
    80005280:	eb0fd0ef          	jal	80002930 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005284:	08000613          	li	a2,128
    80005288:	f5040593          	addi	a1,s0,-176
    8000528c:	4501                	li	a0,0
    8000528e:	edafd0ef          	jal	80002968 <argstr>
    80005292:	87aa                	mv	a5,a0
    return -1;
    80005294:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005296:	0a07c363          	bltz	a5,8000533c <sys_open+0xca>
    8000529a:	f526                	sd	s1,168(sp)

  begin_op();
    8000529c:	b09fe0ef          	jal	80003da4 <begin_op>

  if (omode & O_CREATE) {
    800052a0:	f4c42783          	lw	a5,-180(s0)
    800052a4:	2007f793          	andi	a5,a5,512
    800052a8:	c3dd                	beqz	a5,8000534e <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800052aa:	4681                	li	a3,0
    800052ac:	4601                	li	a2,0
    800052ae:	4589                	li	a1,2
    800052b0:	f5040513          	addi	a0,s0,-176
    800052b4:	a5dff0ef          	jal	80004d10 <create>
    800052b8:	84aa                	mv	s1,a0
    if (ip == 0) {
    800052ba:	c549                	beqz	a0,80005344 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    800052bc:	04449703          	lh	a4,68(s1)
    800052c0:	478d                	li	a5,3
    800052c2:	00f71763          	bne	a4,a5,800052d0 <sys_open+0x5e>
    800052c6:	0464d703          	lhu	a4,70(s1)
    800052ca:	47a5                	li	a5,9
    800052cc:	0ae7ee63          	bltu	a5,a4,80005388 <sys_open+0x116>
    800052d0:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    800052d2:	ee9fe0ef          	jal	800041ba <filealloc>
    800052d6:	892a                	mv	s2,a0
    800052d8:	c561                	beqz	a0,800053a0 <sys_open+0x12e>
    800052da:	ed4e                	sd	s3,152(sp)
    800052dc:	9f5ff0ef          	jal	80004cd0 <fdalloc>
    800052e0:	89aa                	mv	s3,a0
    800052e2:	0a054b63          	bltz	a0,80005398 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    800052e6:	04449703          	lh	a4,68(s1)
    800052ea:	478d                	li	a5,3
    800052ec:	0cf70363          	beq	a4,a5,800053b2 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800052f0:	4789                	li	a5,2
    800052f2:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800052f6:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800052fa:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800052fe:	f4c42783          	lw	a5,-180(s0)
    80005302:	0017f713          	andi	a4,a5,1
    80005306:	00174713          	xori	a4,a4,1
    8000530a:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000530e:	0037f713          	andi	a4,a5,3
    80005312:	00e03733          	snez	a4,a4
    80005316:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    8000531a:	4007f793          	andi	a5,a5,1024
    8000531e:	c791                	beqz	a5,8000532a <sys_open+0xb8>
    80005320:	04449703          	lh	a4,68(s1)
    80005324:	4789                	li	a5,2
    80005326:	08f70d63          	beq	a4,a5,800053c0 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    8000532a:	8526                	mv	a0,s1
    8000532c:	8aefe0ef          	jal	800033da <iunlock>
  end_op();
    80005330:	b01fe0ef          	jal	80003e30 <end_op>

  return fd;
    80005334:	854e                	mv	a0,s3
    80005336:	74aa                	ld	s1,168(sp)
    80005338:	790a                	ld	s2,160(sp)
    8000533a:	69ea                	ld	s3,152(sp)
}
    8000533c:	70ea                	ld	ra,184(sp)
    8000533e:	744a                	ld	s0,176(sp)
    80005340:	6129                	addi	sp,sp,192
    80005342:	8082                	ret
      end_op();
    80005344:	aedfe0ef          	jal	80003e30 <end_op>
      return -1;
    80005348:	557d                	li	a0,-1
    8000534a:	74aa                	ld	s1,168(sp)
    8000534c:	bfc5                	j	8000533c <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    8000534e:	f5040513          	addi	a0,s0,-176
    80005352:	875fe0ef          	jal	80003bc6 <namei>
    80005356:	84aa                	mv	s1,a0
    80005358:	c11d                	beqz	a0,8000537e <sys_open+0x10c>
    ilock(ip);
    8000535a:	fd3fd0ef          	jal	8000332c <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    8000535e:	04449703          	lh	a4,68(s1)
    80005362:	4785                	li	a5,1
    80005364:	f4f71ce3          	bne	a4,a5,800052bc <sys_open+0x4a>
    80005368:	f4c42783          	lw	a5,-180(s0)
    8000536c:	d3b5                	beqz	a5,800052d0 <sys_open+0x5e>
      iunlockput(ip);
    8000536e:	8526                	mv	a0,s1
    80005370:	a10fe0ef          	jal	80003580 <iunlockput>
      end_op();
    80005374:	abdfe0ef          	jal	80003e30 <end_op>
      return -1;
    80005378:	557d                	li	a0,-1
    8000537a:	74aa                	ld	s1,168(sp)
    8000537c:	b7c1                	j	8000533c <sys_open+0xca>
      end_op();
    8000537e:	ab3fe0ef          	jal	80003e30 <end_op>
      return -1;
    80005382:	557d                	li	a0,-1
    80005384:	74aa                	ld	s1,168(sp)
    80005386:	bf5d                	j	8000533c <sys_open+0xca>
    iunlockput(ip);
    80005388:	8526                	mv	a0,s1
    8000538a:	9f6fe0ef          	jal	80003580 <iunlockput>
    end_op();
    8000538e:	aa3fe0ef          	jal	80003e30 <end_op>
    return -1;
    80005392:	557d                	li	a0,-1
    80005394:	74aa                	ld	s1,168(sp)
    80005396:	b75d                	j	8000533c <sys_open+0xca>
      fileclose(f);
    80005398:	854a                	mv	a0,s2
    8000539a:	ec5fe0ef          	jal	8000425e <fileclose>
    8000539e:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800053a0:	8526                	mv	a0,s1
    800053a2:	9defe0ef          	jal	80003580 <iunlockput>
    end_op();
    800053a6:	a8bfe0ef          	jal	80003e30 <end_op>
    return -1;
    800053aa:	557d                	li	a0,-1
    800053ac:	74aa                	ld	s1,168(sp)
    800053ae:	790a                	ld	s2,160(sp)
    800053b0:	b771                	j	8000533c <sys_open+0xca>
    f->type = FD_DEVICE;
    800053b2:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800053b6:	04649783          	lh	a5,70(s1)
    800053ba:	02f91223          	sh	a5,36(s2)
    800053be:	bf35                	j	800052fa <sys_open+0x88>
    itrunc(ip);
    800053c0:	8526                	mv	a0,s1
    800053c2:	858fe0ef          	jal	8000341a <itrunc>
    800053c6:	b795                	j	8000532a <sys_open+0xb8>

00000000800053c8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800053c8:	7175                	addi	sp,sp,-144
    800053ca:	e506                	sd	ra,136(sp)
    800053cc:	e122                	sd	s0,128(sp)
    800053ce:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800053d0:	9d5fe0ef          	jal	80003da4 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    800053d4:	08000613          	li	a2,128
    800053d8:	f7040593          	addi	a1,s0,-144
    800053dc:	4501                	li	a0,0
    800053de:	d8afd0ef          	jal	80002968 <argstr>
    800053e2:	02054363          	bltz	a0,80005408 <sys_mkdir+0x40>
    800053e6:	4681                	li	a3,0
    800053e8:	4601                	li	a2,0
    800053ea:	4585                	li	a1,1
    800053ec:	f7040513          	addi	a0,s0,-144
    800053f0:	921ff0ef          	jal	80004d10 <create>
    800053f4:	c911                	beqz	a0,80005408 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053f6:	98afe0ef          	jal	80003580 <iunlockput>
  end_op();
    800053fa:	a37fe0ef          	jal	80003e30 <end_op>
  return 0;
    800053fe:	4501                	li	a0,0
}
    80005400:	60aa                	ld	ra,136(sp)
    80005402:	640a                	ld	s0,128(sp)
    80005404:	6149                	addi	sp,sp,144
    80005406:	8082                	ret
    end_op();
    80005408:	a29fe0ef          	jal	80003e30 <end_op>
    return -1;
    8000540c:	557d                	li	a0,-1
    8000540e:	bfcd                	j	80005400 <sys_mkdir+0x38>

0000000080005410 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005410:	7135                	addi	sp,sp,-160
    80005412:	ed06                	sd	ra,152(sp)
    80005414:	e922                	sd	s0,144(sp)
    80005416:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005418:	98dfe0ef          	jal	80003da4 <begin_op>
  argint(1, &major);
    8000541c:	f6c40593          	addi	a1,s0,-148
    80005420:	4505                	li	a0,1
    80005422:	d0efd0ef          	jal	80002930 <argint>
  argint(2, &minor);
    80005426:	f6840593          	addi	a1,s0,-152
    8000542a:	4509                	li	a0,2
    8000542c:	d04fd0ef          	jal	80002930 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005430:	08000613          	li	a2,128
    80005434:	f7040593          	addi	a1,s0,-144
    80005438:	4501                	li	a0,0
    8000543a:	d2efd0ef          	jal	80002968 <argstr>
    8000543e:	02054563          	bltz	a0,80005468 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005442:	f6841683          	lh	a3,-152(s0)
    80005446:	f6c41603          	lh	a2,-148(s0)
    8000544a:	458d                	li	a1,3
    8000544c:	f7040513          	addi	a0,s0,-144
    80005450:	8c1ff0ef          	jal	80004d10 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005454:	c911                	beqz	a0,80005468 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005456:	92afe0ef          	jal	80003580 <iunlockput>
  end_op();
    8000545a:	9d7fe0ef          	jal	80003e30 <end_op>
  return 0;
    8000545e:	4501                	li	a0,0
}
    80005460:	60ea                	ld	ra,152(sp)
    80005462:	644a                	ld	s0,144(sp)
    80005464:	610d                	addi	sp,sp,160
    80005466:	8082                	ret
    end_op();
    80005468:	9c9fe0ef          	jal	80003e30 <end_op>
    return -1;
    8000546c:	557d                	li	a0,-1
    8000546e:	bfcd                	j	80005460 <sys_mknod+0x50>

0000000080005470 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005470:	7135                	addi	sp,sp,-160
    80005472:	ed06                	sd	ra,152(sp)
    80005474:	e922                	sd	s0,144(sp)
    80005476:	e14a                	sd	s2,128(sp)
    80005478:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000547a:	d6efc0ef          	jal	800019e8 <myproc>
    8000547e:	892a                	mv	s2,a0

  begin_op();
    80005480:	925fe0ef          	jal	80003da4 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    80005484:	08000613          	li	a2,128
    80005488:	f6040593          	addi	a1,s0,-160
    8000548c:	4501                	li	a0,0
    8000548e:	cdafd0ef          	jal	80002968 <argstr>
    80005492:	04054363          	bltz	a0,800054d8 <sys_chdir+0x68>
    80005496:	e526                	sd	s1,136(sp)
    80005498:	f6040513          	addi	a0,s0,-160
    8000549c:	f2afe0ef          	jal	80003bc6 <namei>
    800054a0:	84aa                	mv	s1,a0
    800054a2:	c915                	beqz	a0,800054d6 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800054a4:	e89fd0ef          	jal	8000332c <ilock>
  if (ip->type != T_DIR) {
    800054a8:	04449703          	lh	a4,68(s1)
    800054ac:	4785                	li	a5,1
    800054ae:	02f71963          	bne	a4,a5,800054e0 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800054b2:	8526                	mv	a0,s1
    800054b4:	f27fd0ef          	jal	800033da <iunlock>
  iput(p->cwd);
    800054b8:	15093503          	ld	a0,336(s2)
    800054bc:	ff3fd0ef          	jal	800034ae <iput>
  end_op();
    800054c0:	971fe0ef          	jal	80003e30 <end_op>
  p->cwd = ip;
    800054c4:	14993823          	sd	s1,336(s2)
  return 0;
    800054c8:	4501                	li	a0,0
    800054ca:	64aa                	ld	s1,136(sp)
}
    800054cc:	60ea                	ld	ra,152(sp)
    800054ce:	644a                	ld	s0,144(sp)
    800054d0:	690a                	ld	s2,128(sp)
    800054d2:	610d                	addi	sp,sp,160
    800054d4:	8082                	ret
    800054d6:	64aa                	ld	s1,136(sp)
    end_op();
    800054d8:	959fe0ef          	jal	80003e30 <end_op>
    return -1;
    800054dc:	557d                	li	a0,-1
    800054de:	b7fd                	j	800054cc <sys_chdir+0x5c>
    iunlockput(ip);
    800054e0:	8526                	mv	a0,s1
    800054e2:	89efe0ef          	jal	80003580 <iunlockput>
    end_op();
    800054e6:	94bfe0ef          	jal	80003e30 <end_op>
    return -1;
    800054ea:	557d                	li	a0,-1
    800054ec:	64aa                	ld	s1,136(sp)
    800054ee:	bff9                	j	800054cc <sys_chdir+0x5c>

00000000800054f0 <sys_exec>:

uint64
sys_exec(void)
{
    800054f0:	7105                	addi	sp,sp,-480
    800054f2:	ef86                	sd	ra,472(sp)
    800054f4:	eba2                	sd	s0,464(sp)
    800054f6:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800054f8:	e2840593          	addi	a1,s0,-472
    800054fc:	4505                	li	a0,1
    800054fe:	c4efd0ef          	jal	8000294c <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    80005502:	08000613          	li	a2,128
    80005506:	f3040593          	addi	a1,s0,-208
    8000550a:	4501                	li	a0,0
    8000550c:	c5cfd0ef          	jal	80002968 <argstr>
    80005510:	87aa                	mv	a5,a0
    return -1;
    80005512:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005514:	0e07c063          	bltz	a5,800055f4 <sys_exec+0x104>
    80005518:	e7a6                	sd	s1,456(sp)
    8000551a:	e3ca                	sd	s2,448(sp)
    8000551c:	ff4e                	sd	s3,440(sp)
    8000551e:	fb52                	sd	s4,432(sp)
    80005520:	f756                	sd	s5,424(sp)
    80005522:	f35a                	sd	s6,416(sp)
    80005524:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005526:	e3040a13          	addi	s4,s0,-464
    8000552a:	10000613          	li	a2,256
    8000552e:	4581                	li	a1,0
    80005530:	8552                	mv	a0,s4
    80005532:	fb6fb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    80005536:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005538:	89d2                	mv	s3,s4
    8000553a:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000553c:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005540:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    80005542:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005546:	00391513          	slli	a0,s2,0x3
    8000554a:	85d6                	mv	a1,s5
    8000554c:	e2843783          	ld	a5,-472(s0)
    80005550:	953e                	add	a0,a0,a5
    80005552:	b52fd0ef          	jal	800028a4 <fetchaddr>
    80005556:	02054663          	bltz	a0,80005582 <sys_exec+0x92>
    if (uarg == 0) {
    8000555a:	e2043783          	ld	a5,-480(s0)
    8000555e:	c7a1                	beqz	a5,800055a6 <sys_exec+0xb6>
    argv[i] = kalloc();
    80005560:	deefb0ef          	jal	80000b4e <kalloc>
    80005564:	85aa                	mv	a1,a0
    80005566:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    8000556a:	cd01                	beqz	a0,80005582 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000556c:	865a                	mv	a2,s6
    8000556e:	e2043503          	ld	a0,-480(s0)
    80005572:	b7cfd0ef          	jal	800028ee <fetchstr>
    80005576:	00054663          	bltz	a0,80005582 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    8000557a:	0905                	addi	s2,s2,1
    8000557c:	09a1                	addi	s3,s3,8
    8000557e:	fd7914e3          	bne	s2,s7,80005546 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005582:	100a0a13          	addi	s4,s4,256
    80005586:	6088                	ld	a0,0(s1)
    80005588:	cd31                	beqz	a0,800055e4 <sys_exec+0xf4>
    kfree(argv[i]);
    8000558a:	cdcfb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000558e:	04a1                	addi	s1,s1,8
    80005590:	ff449be3          	bne	s1,s4,80005586 <sys_exec+0x96>
  return -1;
    80005594:	557d                	li	a0,-1
    80005596:	64be                	ld	s1,456(sp)
    80005598:	691e                	ld	s2,448(sp)
    8000559a:	79fa                	ld	s3,440(sp)
    8000559c:	7a5a                	ld	s4,432(sp)
    8000559e:	7aba                	ld	s5,424(sp)
    800055a0:	7b1a                	ld	s6,416(sp)
    800055a2:	6bfa                	ld	s7,408(sp)
    800055a4:	a881                	j	800055f4 <sys_exec+0x104>
      argv[i] = 0;
    800055a6:	0009079b          	sext.w	a5,s2
    800055aa:	e3040593          	addi	a1,s0,-464
    800055ae:	078e                	slli	a5,a5,0x3
    800055b0:	97ae                	add	a5,a5,a1
    800055b2:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    800055b6:	f3040513          	addi	a0,s0,-208
    800055ba:	b62ff0ef          	jal	8000491c <kexec>
    800055be:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055c0:	100a0a13          	addi	s4,s4,256
    800055c4:	6088                	ld	a0,0(s1)
    800055c6:	c511                	beqz	a0,800055d2 <sys_exec+0xe2>
    kfree(argv[i]);
    800055c8:	c9efb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055cc:	04a1                	addi	s1,s1,8
    800055ce:	ff449be3          	bne	s1,s4,800055c4 <sys_exec+0xd4>
  return ret;
    800055d2:	854a                	mv	a0,s2
    800055d4:	64be                	ld	s1,456(sp)
    800055d6:	691e                	ld	s2,448(sp)
    800055d8:	79fa                	ld	s3,440(sp)
    800055da:	7a5a                	ld	s4,432(sp)
    800055dc:	7aba                	ld	s5,424(sp)
    800055de:	7b1a                	ld	s6,416(sp)
    800055e0:	6bfa                	ld	s7,408(sp)
    800055e2:	a809                	j	800055f4 <sys_exec+0x104>
  return -1;
    800055e4:	557d                	li	a0,-1
    800055e6:	64be                	ld	s1,456(sp)
    800055e8:	691e                	ld	s2,448(sp)
    800055ea:	79fa                	ld	s3,440(sp)
    800055ec:	7a5a                	ld	s4,432(sp)
    800055ee:	7aba                	ld	s5,424(sp)
    800055f0:	7b1a                	ld	s6,416(sp)
    800055f2:	6bfa                	ld	s7,408(sp)
}
    800055f4:	60fe                	ld	ra,472(sp)
    800055f6:	645e                	ld	s0,464(sp)
    800055f8:	613d                	addi	sp,sp,480
    800055fa:	8082                	ret

00000000800055fc <sys_pipe>:

uint64
sys_pipe(void)
{
    800055fc:	7139                	addi	sp,sp,-64
    800055fe:	fc06                	sd	ra,56(sp)
    80005600:	f822                	sd	s0,48(sp)
    80005602:	f426                	sd	s1,40(sp)
    80005604:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005606:	be2fc0ef          	jal	800019e8 <myproc>
    8000560a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000560c:	fd840593          	addi	a1,s0,-40
    80005610:	4501                	li	a0,0
    80005612:	b3afd0ef          	jal	8000294c <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005616:	fc840593          	addi	a1,s0,-56
    8000561a:	fd040513          	addi	a0,s0,-48
    8000561e:	f7ffe0ef          	jal	8000459c <pipealloc>
    return -1;
    80005622:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005624:	0a054963          	bltz	a0,800056d6 <sys_pipe+0xda>
  fd0 = -1;
    80005628:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    8000562c:	fd043503          	ld	a0,-48(s0)
    80005630:	ea0ff0ef          	jal	80004cd0 <fdalloc>
    80005634:	fca42223          	sw	a0,-60(s0)
    80005638:	08054663          	bltz	a0,800056c4 <sys_pipe+0xc8>
    8000563c:	fc843503          	ld	a0,-56(s0)
    80005640:	e90ff0ef          	jal	80004cd0 <fdalloc>
    80005644:	fca42023          	sw	a0,-64(s0)
    80005648:	06054463          	bltz	a0,800056b0 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    8000564c:	4711                	li	a4,4
    8000564e:	fc440693          	addi	a3,s0,-60
    80005652:	fd843603          	ld	a2,-40(s0)
    80005656:	64ac                	ld	a1,72(s1)
    80005658:	68a8                	ld	a0,80(s1)
    8000565a:	f29fb0ef          	jal	80001582 <copyout>
    8000565e:	00054f63          	bltz	a0,8000567c <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    80005662:	4711                	li	a4,4
    80005664:	fc040693          	addi	a3,s0,-64
    80005668:	fd843603          	ld	a2,-40(s0)
    8000566c:	963a                	add	a2,a2,a4
    8000566e:	64ac                	ld	a1,72(s1)
    80005670:	68a8                	ld	a0,80(s1)
    80005672:	f11fb0ef          	jal	80001582 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005676:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005678:	04055f63          	bgez	a0,800056d6 <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    8000567c:	fc442783          	lw	a5,-60(s0)
    80005680:	078e                	slli	a5,a5,0x3
    80005682:	0d078793          	addi	a5,a5,208
    80005686:	97a6                	add	a5,a5,s1
    80005688:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000568c:	fc042783          	lw	a5,-64(s0)
    80005690:	078e                	slli	a5,a5,0x3
    80005692:	0d078793          	addi	a5,a5,208
    80005696:	94be                	add	s1,s1,a5
    80005698:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000569c:	fd043503          	ld	a0,-48(s0)
    800056a0:	bbffe0ef          	jal	8000425e <fileclose>
    fileclose(wf);
    800056a4:	fc843503          	ld	a0,-56(s0)
    800056a8:	bb7fe0ef          	jal	8000425e <fileclose>
    return -1;
    800056ac:	57fd                	li	a5,-1
    800056ae:	a025                	j	800056d6 <sys_pipe+0xda>
    if (fd0 >= 0)
    800056b0:	fc442783          	lw	a5,-60(s0)
    800056b4:	0007c863          	bltz	a5,800056c4 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    800056b8:	078e                	slli	a5,a5,0x3
    800056ba:	0d078793          	addi	a5,a5,208
    800056be:	97a6                	add	a5,a5,s1
    800056c0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800056c4:	fd043503          	ld	a0,-48(s0)
    800056c8:	b97fe0ef          	jal	8000425e <fileclose>
    fileclose(wf);
    800056cc:	fc843503          	ld	a0,-56(s0)
    800056d0:	b8ffe0ef          	jal	8000425e <fileclose>
    return -1;
    800056d4:	57fd                	li	a5,-1
}
    800056d6:	853e                	mv	a0,a5
    800056d8:	70e2                	ld	ra,56(sp)
    800056da:	7442                	ld	s0,48(sp)
    800056dc:	74a2                	ld	s1,40(sp)
    800056de:	6121                	addi	sp,sp,64
    800056e0:	8082                	ret
	...

00000000800056f0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800056f0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800056f2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800056f4:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    800056f6:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800056f8:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800056fa:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800056fc:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800056fe:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005700:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005702:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005704:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005706:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005708:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000570a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000570c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000570e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005710:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005712:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005714:	89efd0ef          	jal	800027b2 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005718:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000571a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000571c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000571e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005720:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005722:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005724:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005726:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005728:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000572a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000572c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000572e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005730:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005732:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005734:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005736:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005738:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000573a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000573c:	10200073          	sret
    80005740:	0001                	nop
    80005742:	00000013          	nop
    80005746:	00000013          	nop
    8000574a:	00000013          	nop

000000008000574e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000574e:	1141                	addi	sp,sp,-16
    80005750:	e406                	sd	ra,8(sp)
    80005752:	e022                	sd	s0,0(sp)
    80005754:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005756:	0c000737          	lui	a4,0xc000
    8000575a:	4785                	li	a5,1
    8000575c:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000575e:	c35c                	sw	a5,4(a4)
}
    80005760:	60a2                	ld	ra,8(sp)
    80005762:	6402                	ld	s0,0(sp)
    80005764:	0141                	addi	sp,sp,16
    80005766:	8082                	ret

0000000080005768 <plicinithart>:

void
plicinithart(void)
{
    80005768:	1141                	addi	sp,sp,-16
    8000576a:	e406                	sd	ra,8(sp)
    8000576c:	e022                	sd	s0,0(sp)
    8000576e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005770:	a44fc0ef          	jal	800019b4 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    80005774:	0085179b          	slliw	a5,a0,0x8
    80005778:	0c002737          	lui	a4,0xc002
    8000577c:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    80005780:	97ba                	add	a5,a5,a4
    80005782:	40200713          	li	a4,1026
    80005786:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005788:	00d5151b          	slliw	a0,a0,0xd
    8000578c:	0c2017b7          	lui	a5,0xc201
    80005790:	953e                	add	a0,a0,a5
    80005792:	00052023          	sw	zero,0(a0)
}
    80005796:	60a2                	ld	ra,8(sp)
    80005798:	6402                	ld	s0,0(sp)
    8000579a:	0141                	addi	sp,sp,16
    8000579c:	8082                	ret

000000008000579e <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000579e:	1141                	addi	sp,sp,-16
    800057a0:	e406                	sd	ra,8(sp)
    800057a2:	e022                	sd	s0,0(sp)
    800057a4:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800057a6:	a0efc0ef          	jal	800019b4 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    800057aa:	00d5151b          	slliw	a0,a0,0xd
    800057ae:	0c2017b7          	lui	a5,0xc201
    800057b2:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    800057b4:	953e                	add	a0,a0,a5
    800057b6:	4108                	lw	a0,0(a0)
  return irq;
}
    800057b8:	60a2                	ld	ra,8(sp)
    800057ba:	6402                	ld	s0,0(sp)
    800057bc:	0141                	addi	sp,sp,16
    800057be:	8082                	ret

00000000800057c0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800057c0:	1101                	addi	sp,sp,-32
    800057c2:	ec06                	sd	ra,24(sp)
    800057c4:	e822                	sd	s0,16(sp)
    800057c6:	e426                	sd	s1,8(sp)
    800057c8:	1000                	addi	s0,sp,32
    800057ca:	84aa                	mv	s1,a0
  int hart = cpuid();
    800057cc:	9e8fc0ef          	jal	800019b4 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    800057d0:	00d5179b          	slliw	a5,a0,0xd
    800057d4:	0c201737          	lui	a4,0xc201
    800057d8:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    800057da:	97ba                	add	a5,a5,a4
    800057dc:	c384                	sw	s1,0(a5)
}
    800057de:	60e2                	ld	ra,24(sp)
    800057e0:	6442                	ld	s0,16(sp)
    800057e2:	64a2                	ld	s1,8(sp)
    800057e4:	6105                	addi	sp,sp,32
    800057e6:	8082                	ret

00000000800057e8 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800057e8:	1141                	addi	sp,sp,-16
    800057ea:	e406                	sd	ra,8(sp)
    800057ec:	e022                	sd	s0,0(sp)
    800057ee:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800057f0:	479d                	li	a5,7
    800057f2:	04a7ca63          	blt	a5,a0,80005846 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    800057f6:	0001e797          	auipc	a5,0x1e
    800057fa:	dd278793          	addi	a5,a5,-558 # 800235c8 <disk>
    800057fe:	97aa                	add	a5,a5,a0
    80005800:	0187c783          	lbu	a5,24(a5)
    80005804:	e7b9                	bnez	a5,80005852 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005806:	00451693          	slli	a3,a0,0x4
    8000580a:	0001e797          	auipc	a5,0x1e
    8000580e:	dbe78793          	addi	a5,a5,-578 # 800235c8 <disk>
    80005812:	6398                	ld	a4,0(a5)
    80005814:	9736                	add	a4,a4,a3
    80005816:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000581a:	6398                	ld	a4,0(a5)
    8000581c:	9736                	add	a4,a4,a3
    8000581e:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005822:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005826:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000582a:	97aa                	add	a5,a5,a0
    8000582c:	4705                	li	a4,1
    8000582e:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005832:	0001e517          	auipc	a0,0x1e
    80005836:	dae50513          	addi	a0,a0,-594 # 800235e0 <disk+0x18>
    8000583a:	825fc0ef          	jal	8000205e <wakeup>
}
    8000583e:	60a2                	ld	ra,8(sp)
    80005840:	6402                	ld	s0,0(sp)
    80005842:	0141                	addi	sp,sp,16
    80005844:	8082                	ret
    panic("free_desc 1");
    80005846:	00002517          	auipc	a0,0x2
    8000584a:	e6250513          	addi	a0,a0,-414 # 800076a8 <etext+0x6a8>
    8000584e:	fe7fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    80005852:	00002517          	auipc	a0,0x2
    80005856:	e6650513          	addi	a0,a0,-410 # 800076b8 <etext+0x6b8>
    8000585a:	fdbfa0ef          	jal	80000834 <panic>

000000008000585e <virtio_disk_init>:
{
    8000585e:	1101                	addi	sp,sp,-32
    80005860:	ec06                	sd	ra,24(sp)
    80005862:	e822                	sd	s0,16(sp)
    80005864:	e426                	sd	s1,8(sp)
    80005866:	e04a                	sd	s2,0(sp)
    80005868:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000586a:	00002597          	auipc	a1,0x2
    8000586e:	e5e58593          	addi	a1,a1,-418 # 800076c8 <etext+0x6c8>
    80005872:	0001e517          	auipc	a0,0x1e
    80005876:	e7e50513          	addi	a0,a0,-386 # 800236f0 <disk+0x128>
    8000587a:	b2efb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000587e:	100017b7          	lui	a5,0x10001
    80005882:	4398                	lw	a4,0(a5)
    80005884:	2701                	sext.w	a4,a4
    80005886:	747277b7          	lui	a5,0x74727
    8000588a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000588e:	14f71863          	bne	a4,a5,800059de <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005892:	100017b7          	lui	a5,0x10001
    80005896:	43dc                	lw	a5,4(a5)
    80005898:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000589a:	4709                	li	a4,2
    8000589c:	14e79163          	bne	a5,a4,800059de <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058a0:	100017b7          	lui	a5,0x10001
    800058a4:	479c                	lw	a5,8(a5)
    800058a6:	2781                	sext.w	a5,a5
    800058a8:	12e79b63          	bne	a5,a4,800059de <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    800058ac:	100017b7          	lui	a5,0x10001
    800058b0:	47d8                	lw	a4,12(a5)
    800058b2:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058b4:	554d47b7          	lui	a5,0x554d4
    800058b8:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800058bc:	12f71163          	bne	a4,a5,800059de <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    800058c0:	100017b7          	lui	a5,0x10001
    800058c4:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800058c8:	4705                	li	a4,1
    800058ca:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058cc:	470d                	li	a4,3
    800058ce:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800058d0:	10001737          	lui	a4,0x10001
    800058d4:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800058d6:	c7ffe6b7          	lui	a3,0xc7ffe
    800058da:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdae57>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800058de:	8f75                	and	a4,a4,a3
    800058e0:	100016b7          	lui	a3,0x10001
    800058e4:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058e6:	472d                	li	a4,11
    800058e8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058ea:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800058ee:	439c                	lw	a5,0(a5)
    800058f0:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800058f4:	8ba1                	andi	a5,a5,8
    800058f6:	0e078a63          	beqz	a5,800059ea <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800058fa:	100017b7          	lui	a5,0x10001
    800058fe:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005902:	43fc                	lw	a5,68(a5)
    80005904:	2781                	sext.w	a5,a5
    80005906:	0e079863          	bnez	a5,800059f6 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000590a:	100017b7          	lui	a5,0x10001
    8000590e:	5bdc                	lw	a5,52(a5)
    80005910:	2781                	sext.w	a5,a5
  if (max == 0)
    80005912:	0e078863          	beqz	a5,80005a02 <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005916:	471d                	li	a4,7
    80005918:	0ef77b63          	bgeu	a4,a5,80005a0e <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    8000591c:	a32fb0ef          	jal	80000b4e <kalloc>
    80005920:	0001e497          	auipc	s1,0x1e
    80005924:	ca848493          	addi	s1,s1,-856 # 800235c8 <disk>
    80005928:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    8000592a:	a24fb0ef          	jal	80000b4e <kalloc>
    8000592e:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005930:	a1efb0ef          	jal	80000b4e <kalloc>
    80005934:	87aa                	mv	a5,a0
    80005936:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005938:	6088                	ld	a0,0(s1)
    8000593a:	0e050063          	beqz	a0,80005a1a <virtio_disk_init+0x1bc>
    8000593e:	0001e717          	auipc	a4,0x1e
    80005942:	c9273703          	ld	a4,-878(a4) # 800235d0 <disk+0x8>
    80005946:	cb71                	beqz	a4,80005a1a <virtio_disk_init+0x1bc>
    80005948:	cbe9                	beqz	a5,80005a1a <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    8000594a:	6605                	lui	a2,0x1
    8000594c:	4581                	li	a1,0
    8000594e:	b9afb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005952:	0001e497          	auipc	s1,0x1e
    80005956:	c7648493          	addi	s1,s1,-906 # 800235c8 <disk>
    8000595a:	6605                	lui	a2,0x1
    8000595c:	4581                	li	a1,0
    8000595e:	6488                	ld	a0,8(s1)
    80005960:	b88fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005964:	6605                	lui	a2,0x1
    80005966:	4581                	li	a1,0
    80005968:	6888                	ld	a0,16(s1)
    8000596a:	b7efb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000596e:	100017b7          	lui	a5,0x10001
    80005972:	4721                	li	a4,8
    80005974:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005976:	4098                	lw	a4,0(s1)
    80005978:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000597c:	40d8                	lw	a4,4(s1)
    8000597e:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005982:	649c                	ld	a5,8(s1)
    80005984:	0007869b          	sext.w	a3,a5
    80005988:	10001737          	lui	a4,0x10001
    8000598c:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005990:	9781                	srai	a5,a5,0x20
    80005992:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005996:	689c                	ld	a5,16(s1)
    80005998:	0007869b          	sext.w	a3,a5
    8000599c:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800059a0:	9781                	srai	a5,a5,0x20
    800059a2:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800059a6:	4785                	li	a5,1
    800059a8:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800059aa:	00f48c23          	sb	a5,24(s1)
    800059ae:	00f48ca3          	sb	a5,25(s1)
    800059b2:	00f48d23          	sb	a5,26(s1)
    800059b6:	00f48da3          	sb	a5,27(s1)
    800059ba:	00f48e23          	sb	a5,28(s1)
    800059be:	00f48ea3          	sb	a5,29(s1)
    800059c2:	00f48f23          	sb	a5,30(s1)
    800059c6:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800059ca:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800059ce:	07272823          	sw	s2,112(a4)
}
    800059d2:	60e2                	ld	ra,24(sp)
    800059d4:	6442                	ld	s0,16(sp)
    800059d6:	64a2                	ld	s1,8(sp)
    800059d8:	6902                	ld	s2,0(sp)
    800059da:	6105                	addi	sp,sp,32
    800059dc:	8082                	ret
    panic("could not find virtio disk");
    800059de:	00002517          	auipc	a0,0x2
    800059e2:	cfa50513          	addi	a0,a0,-774 # 800076d8 <etext+0x6d8>
    800059e6:	e4ffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    800059ea:	00002517          	auipc	a0,0x2
    800059ee:	d0e50513          	addi	a0,a0,-754 # 800076f8 <etext+0x6f8>
    800059f2:	e43fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    800059f6:	00002517          	auipc	a0,0x2
    800059fa:	d2250513          	addi	a0,a0,-734 # 80007718 <etext+0x718>
    800059fe:	e37fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005a02:	00002517          	auipc	a0,0x2
    80005a06:	d3650513          	addi	a0,a0,-714 # 80007738 <etext+0x738>
    80005a0a:	e2bfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005a0e:	00002517          	auipc	a0,0x2
    80005a12:	d4a50513          	addi	a0,a0,-694 # 80007758 <etext+0x758>
    80005a16:	e1ffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005a1a:	00002517          	auipc	a0,0x2
    80005a1e:	d5e50513          	addi	a0,a0,-674 # 80007778 <etext+0x778>
    80005a22:	e13fa0ef          	jal	80000834 <panic>

0000000080005a26 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005a26:	711d                	addi	sp,sp,-96
    80005a28:	ec86                	sd	ra,88(sp)
    80005a2a:	e8a2                	sd	s0,80(sp)
    80005a2c:	e4a6                	sd	s1,72(sp)
    80005a2e:	e0ca                	sd	s2,64(sp)
    80005a30:	fc4e                	sd	s3,56(sp)
    80005a32:	f852                	sd	s4,48(sp)
    80005a34:	f456                	sd	s5,40(sp)
    80005a36:	f05a                	sd	s6,32(sp)
    80005a38:	ec5e                	sd	s7,24(sp)
    80005a3a:	e862                	sd	s8,16(sp)
    80005a3c:	1080                	addi	s0,sp,96
    80005a3e:	89aa                	mv	s3,a0
    80005a40:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005a42:	00c52b83          	lw	s7,12(a0)
    80005a46:	001b9b9b          	slliw	s7,s7,0x1
    80005a4a:	1b82                	slli	s7,s7,0x20
    80005a4c:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005a50:	0001e517          	auipc	a0,0x1e
    80005a54:	ca050513          	addi	a0,a0,-864 # 800236f0 <disk+0x128>
    80005a58:	9d0fb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005a5c:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005a5e:	0001ea97          	auipc	s5,0x1e
    80005a62:	b6aa8a93          	addi	s5,s5,-1174 # 800235c8 <disk>
  for (int i = 0; i < 3; i++) {
    80005a66:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005a68:	5c7d                	li	s8,-1
    80005a6a:	a8a5                	j	80005ae2 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005a6c:	00fa8733          	add	a4,s5,a5
    80005a70:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005a74:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005a76:	0207c563          	bltz	a5,80005aa0 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005a7a:	2905                	addiw	s2,s2,1
    80005a7c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005a7e:	07490663          	beq	s2,s4,80005aea <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005a82:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005a84:	0001e717          	auipc	a4,0x1e
    80005a88:	b4470713          	addi	a4,a4,-1212 # 800235c8 <disk>
    80005a8c:	4781                	li	a5,0
    if (disk.free[i]) {
    80005a8e:	01874683          	lbu	a3,24(a4)
    80005a92:	fee9                	bnez	a3,80005a6c <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005a94:	2785                	addiw	a5,a5,1
    80005a96:	0705                	addi	a4,a4,1
    80005a98:	fe979be3          	bne	a5,s1,80005a8e <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005a9c:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005aa0:	01205d63          	blez	s2,80005aba <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005aa4:	fa042503          	lw	a0,-96(s0)
    80005aa8:	d41ff0ef          	jal	800057e8 <free_desc>
      for (int j = 0; j < i; j++)
    80005aac:	4785                	li	a5,1
    80005aae:	0127d663          	bge	a5,s2,80005aba <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005ab2:	fa442503          	lw	a0,-92(s0)
    80005ab6:	d33ff0ef          	jal	800057e8 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005aba:	0001e517          	auipc	a0,0x1e
    80005abe:	b2650513          	addi	a0,a0,-1242 # 800235e0 <disk+0x18>
    80005ac2:	d30fc0ef          	jal	80001ff2 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005ac6:	0001e517          	auipc	a0,0x1e
    80005aca:	c2a50513          	addi	a0,a0,-982 # 800236f0 <disk+0x128>
    80005ace:	9e2fb0ef          	jal	80000cb0 <release>
    sleep();
    80005ad2:	d5cfc0ef          	jal	8000202e <sleep>
    acquire(&disk.vdisk_lock);
    80005ad6:	0001e517          	auipc	a0,0x1e
    80005ada:	c1a50513          	addi	a0,a0,-998 # 800236f0 <disk+0x128>
    80005ade:	94afb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005ae2:	fa040613          	addi	a2,s0,-96
    80005ae6:	4901                	li	s2,0
    80005ae8:	bf69                	j	80005a82 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005aea:	fa042503          	lw	a0,-96(s0)
    80005aee:	00451693          	slli	a3,a0,0x4

  if (write)
    80005af2:	0001e797          	auipc	a5,0x1e
    80005af6:	ad678793          	addi	a5,a5,-1322 # 800235c8 <disk>
    80005afa:	00451713          	slli	a4,a0,0x4
    80005afe:	0a070713          	addi	a4,a4,160
    80005b02:	973e                	add	a4,a4,a5
    80005b04:	01603633          	snez	a2,s6
    80005b08:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005b0a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005b0e:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005b12:	6398                	ld	a4,0(a5)
    80005b14:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b16:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005b1a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005b1c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005b1e:	6390                	ld	a2,0(a5)
    80005b20:	00d60833          	add	a6,a2,a3
    80005b24:	4741                	li	a4,16
    80005b26:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005b2a:	4585                	li	a1,1
    80005b2c:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005b30:	fa442703          	lw	a4,-92(s0)
    80005b34:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005b38:	0712                	slli	a4,a4,0x4
    80005b3a:	963a                	add	a2,a2,a4
    80005b3c:	05898813          	addi	a6,s3,88
    80005b40:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005b44:	0007b883          	ld	a7,0(a5)
    80005b48:	9746                	add	a4,a4,a7
    80005b4a:	40000613          	li	a2,1024
    80005b4e:	c710                	sw	a2,8(a4)
  if (write)
    80005b50:	001b3613          	seqz	a2,s6
    80005b54:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005b58:	8e4d                	or	a2,a2,a1
    80005b5a:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005b5e:	fa842603          	lw	a2,-88(s0)
    80005b62:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005b66:	00451813          	slli	a6,a0,0x4
    80005b6a:	02080813          	addi	a6,a6,32
    80005b6e:	983e                	add	a6,a6,a5
    80005b70:	577d                	li	a4,-1
    80005b72:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005b76:	0612                	slli	a2,a2,0x4
    80005b78:	98b2                	add	a7,a7,a2
    80005b7a:	03068713          	addi	a4,a3,48
    80005b7e:	973e                	add	a4,a4,a5
    80005b80:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005b84:	6398                	ld	a4,0(a5)
    80005b86:	9732                	add	a4,a4,a2
    80005b88:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005b8a:	4689                	li	a3,2
    80005b8c:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005b90:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005b94:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005b98:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005b9c:	6794                	ld	a3,8(a5)
    80005b9e:	0026d703          	lhu	a4,2(a3)
    80005ba2:	8b1d                	andi	a4,a4,7
    80005ba4:	0706                	slli	a4,a4,0x1
    80005ba6:	96ba                	add	a3,a3,a4
    80005ba8:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005bac:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005bb0:	6798                	ld	a4,8(a5)
    80005bb2:	00275783          	lhu	a5,2(a4)
    80005bb6:	2785                	addiw	a5,a5,1
    80005bb8:	00f71123          	sh	a5,2(a4)
    80005bbc:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005bc0:	100017b7          	lui	a5,0x10001
    80005bc4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005bc8:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005bcc:	0001e497          	auipc	s1,0x1e
    80005bd0:	b2448493          	addi	s1,s1,-1244 # 800236f0 <disk+0x128>
  while (b->disk == 1) {
    80005bd4:	892e                	mv	s2,a1
    80005bd6:	02b79163          	bne	a5,a1,80005bf8 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005bda:	854e                	mv	a0,s3
    80005bdc:	c16fc0ef          	jal	80001ff2 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005be0:	8526                	mv	a0,s1
    80005be2:	8cefb0ef          	jal	80000cb0 <release>
    sleep();
    80005be6:	c48fc0ef          	jal	8000202e <sleep>
    acquire(&disk.vdisk_lock);
    80005bea:	8526                	mv	a0,s1
    80005bec:	83cfb0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005bf0:	0049a783          	lw	a5,4(s3)
    80005bf4:	ff2783e3          	beq	a5,s2,80005bda <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005bf8:	fa042903          	lw	s2,-96(s0)
    80005bfc:	00491713          	slli	a4,s2,0x4
    80005c00:	02070713          	addi	a4,a4,32
    80005c04:	0001e797          	auipc	a5,0x1e
    80005c08:	9c478793          	addi	a5,a5,-1596 # 800235c8 <disk>
    80005c0c:	97ba                	add	a5,a5,a4
    80005c0e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c12:	0001e997          	auipc	s3,0x1e
    80005c16:	9b698993          	addi	s3,s3,-1610 # 800235c8 <disk>
    80005c1a:	00491713          	slli	a4,s2,0x4
    80005c1e:	0009b783          	ld	a5,0(s3)
    80005c22:	97ba                	add	a5,a5,a4
    80005c24:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005c28:	854a                	mv	a0,s2
    80005c2a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005c2e:	bbbff0ef          	jal	800057e8 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005c32:	8885                	andi	s1,s1,1
    80005c34:	f0fd                	bnez	s1,80005c1a <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005c36:	0001e517          	auipc	a0,0x1e
    80005c3a:	aba50513          	addi	a0,a0,-1350 # 800236f0 <disk+0x128>
    80005c3e:	872fb0ef          	jal	80000cb0 <release>
}
    80005c42:	60e6                	ld	ra,88(sp)
    80005c44:	6446                	ld	s0,80(sp)
    80005c46:	64a6                	ld	s1,72(sp)
    80005c48:	6906                	ld	s2,64(sp)
    80005c4a:	79e2                	ld	s3,56(sp)
    80005c4c:	7a42                	ld	s4,48(sp)
    80005c4e:	7aa2                	ld	s5,40(sp)
    80005c50:	7b02                	ld	s6,32(sp)
    80005c52:	6be2                	ld	s7,24(sp)
    80005c54:	6c42                	ld	s8,16(sp)
    80005c56:	6125                	addi	sp,sp,96
    80005c58:	8082                	ret

0000000080005c5a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005c5a:	1101                	addi	sp,sp,-32
    80005c5c:	ec06                	sd	ra,24(sp)
    80005c5e:	e822                	sd	s0,16(sp)
    80005c60:	e426                	sd	s1,8(sp)
    80005c62:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005c64:	0001e497          	auipc	s1,0x1e
    80005c68:	96448493          	addi	s1,s1,-1692 # 800235c8 <disk>
    80005c6c:	0001e517          	auipc	a0,0x1e
    80005c70:	a8450513          	addi	a0,a0,-1404 # 800236f0 <disk+0x128>
    80005c74:	fb5fa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005c78:	100017b7          	lui	a5,0x10001
    80005c7c:	53bc                	lw	a5,96(a5)
    80005c7e:	8b8d                	andi	a5,a5,3
    80005c80:	10001737          	lui	a4,0x10001
    80005c84:	d37c                	sw	a5,100(a4)
    80005c86:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005c8a:	689c                	ld	a5,16(s1)
    80005c8c:	0204d703          	lhu	a4,32(s1)
    80005c90:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005c94:	04f70863          	beq	a4,a5,80005ce4 <virtio_disk_intr+0x8a>
    80005c98:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005c9c:	6898                	ld	a4,16(s1)
    80005c9e:	0204d783          	lhu	a5,32(s1)
    80005ca2:	8b9d                	andi	a5,a5,7
    80005ca4:	078e                	slli	a5,a5,0x3
    80005ca6:	97ba                	add	a5,a5,a4
    80005ca8:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005caa:	00479713          	slli	a4,a5,0x4
    80005cae:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005cb2:	9726                	add	a4,a4,s1
    80005cb4:	01074703          	lbu	a4,16(a4)
    80005cb8:	e329                	bnez	a4,80005cfa <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005cba:	0792                	slli	a5,a5,0x4
    80005cbc:	02078793          	addi	a5,a5,32
    80005cc0:	97a6                	add	a5,a5,s1
    80005cc2:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005cc4:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005cc8:	b96fc0ef          	jal	8000205e <wakeup>

    disk.used_idx += 1;
    80005ccc:	0204d783          	lhu	a5,32(s1)
    80005cd0:	2785                	addiw	a5,a5,1
    80005cd2:	17c2                	slli	a5,a5,0x30
    80005cd4:	93c1                	srli	a5,a5,0x30
    80005cd6:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005cda:	6898                	ld	a4,16(s1)
    80005cdc:	00275703          	lhu	a4,2(a4)
    80005ce0:	faf71ce3          	bne	a4,a5,80005c98 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005ce4:	0001e517          	auipc	a0,0x1e
    80005ce8:	a0c50513          	addi	a0,a0,-1524 # 800236f0 <disk+0x128>
    80005cec:	fc5fa0ef          	jal	80000cb0 <release>
}
    80005cf0:	60e2                	ld	ra,24(sp)
    80005cf2:	6442                	ld	s0,16(sp)
    80005cf4:	64a2                	ld	s1,8(sp)
    80005cf6:	6105                	addi	sp,sp,32
    80005cf8:	8082                	ret
      panic("virtio_disk_intr status");
    80005cfa:	00002517          	auipc	a0,0x2
    80005cfe:	a9650513          	addi	a0,a0,-1386 # 80007790 <etext+0x790>
    80005d02:	b33fa0ef          	jal	80000834 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	0000100f          	fence.i
    800060a0:	12000073          	sfence.vma
    800060a4:	18051073          	csrw	satp,a0
    800060a8:	12000073          	sfence.vma
    800060ac:	02000537          	lui	a0,0x2000
    800060b0:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060b2:	0536                	slli	a0,a0,0xd
    800060b4:	02853083          	ld	ra,40(a0)
    800060b8:	03053103          	ld	sp,48(a0)
    800060bc:	03853183          	ld	gp,56(a0)
    800060c0:	04053203          	ld	tp,64(a0)
    800060c4:	04853283          	ld	t0,72(a0)
    800060c8:	05053303          	ld	t1,80(a0)
    800060cc:	05853383          	ld	t2,88(a0)
    800060d0:	7120                	ld	s0,96(a0)
    800060d2:	7524                	ld	s1,104(a0)
    800060d4:	7d2c                	ld	a1,120(a0)
    800060d6:	6150                	ld	a2,128(a0)
    800060d8:	6554                	ld	a3,136(a0)
    800060da:	6958                	ld	a4,144(a0)
    800060dc:	6d5c                	ld	a5,152(a0)
    800060de:	0a053803          	ld	a6,160(a0)
    800060e2:	0a853883          	ld	a7,168(a0)
    800060e6:	0b053903          	ld	s2,176(a0)
    800060ea:	0b853983          	ld	s3,184(a0)
    800060ee:	0c053a03          	ld	s4,192(a0)
    800060f2:	0c853a83          	ld	s5,200(a0)
    800060f6:	0d053b03          	ld	s6,208(a0)
    800060fa:	0d853b83          	ld	s7,216(a0)
    800060fe:	0e053c03          	ld	s8,224(a0)
    80006102:	0e853c83          	ld	s9,232(a0)
    80006106:	0f053d03          	ld	s10,240(a0)
    8000610a:	0f853d83          	ld	s11,248(a0)
    8000610e:	10053e03          	ld	t3,256(a0)
    80006112:	10853e83          	ld	t4,264(a0)
    80006116:	11053f03          	ld	t5,272(a0)
    8000611a:	11853f83          	ld	t6,280(a0)
    8000611e:	7928                	ld	a0,112(a0)
    80006120:	10200073          	sret
	...
