
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
    80000004:	42813103          	ld	sp,1064(sp) # 8000a428 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb087>
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
    8000011c:	2e4020ef          	jal	80002400 <either_copyin>
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
    80000198:	2dc50513          	addi	a0,a0,732 # 80012470 <cons>
    8000019c:	28d000ef          	jal	80000c28 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	2d048493          	addi	s1,s1,720 # 80012470 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	36090913          	addi	s2,s2,864 # 80012508 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	059010ef          	jal	80001a18 <myproc>
    800001c4:	0bc020ef          	jal	80002280 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	657010ef          	jal	80002022 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	689010ef          	jal	8000205e <sleep>
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
    800001f2:	28270713          	addi	a4,a4,642 # 80012470 <cons>
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
    80000220:	194020ef          	jal	800023b4 <either_copyout>
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
    8000023c:	23850513          	addi	a0,a0,568 # 80012470 <cons>
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
    80000262:	2af72523          	sw	a5,682(a4) # 80012508 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	1fc50513          	addi	a0,a0,508 # 80012470 <cons>
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
    800002cc:	1a850513          	addi	a0,a0,424 # 80012470 <cons>
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
    800002ea:	162020ef          	jal	8000244c <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	18250513          	addi	a0,a0,386 # 80012470 <cons>
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
    80000310:	16470713          	addi	a4,a4,356 # 80012470 <cons>
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
    80000336:	13e70713          	addi	a4,a4,318 # 80012470 <cons>
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
    80000360:	1ac72703          	lw	a4,428(a4) # 80012508 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	0fe70713          	addi	a4,a4,254 # 80012470 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	0ee48493          	addi	s1,s1,238 # 80012470 <cons>
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
    800003c8:	0ac70713          	addi	a4,a4,172 # 80012470 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	12f72b23          	sw	a5,310(a4) # 80012510 <cons+0xa0>
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
    800003fc:	07878793          	addi	a5,a5,120 # 80012470 <cons>
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
    8000041e:	0ec7a923          	sw	a2,242(a5) # 8001250c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	0e650513          	addi	a0,a0,230 # 80012508 <cons+0x98>
    8000042a:	465010ef          	jal	8000208e <wakeup>
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
    80000444:	03050513          	addi	a0,a0,48 # 80012470 <cons>
    80000448:	760000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	19078793          	addi	a5,a5,400 # 800225e0 <devsw>
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
    80000492:	35280813          	addi	a6,a6,850 # 800077e0 <digits>
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
    8000052c:	f1c7a783          	lw	a5,-228(a5) # 8000a444 <panicking>
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
    80000572:	faa50513          	addi	a0,a0,-86 # 80012518 <pr>
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
    800006e6:	0fec8c93          	addi	s9,s9,254 # 800077e0 <digits>
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
    8000076e:	cda7a783          	lw	a5,-806(a5) # 8000a444 <panicking>
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
    80000798:	d8450513          	addi	a0,a0,-636 # 80012518 <pr>
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
    80000848:	c097a023          	sw	s1,-1024(a5) # 8000a444 <panicking>
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
    8000086a:	bc97ad23          	sw	s1,-1062(a5) # 8000a440 <panicked>
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
    80000884:	c9850513          	addi	a0,a0,-872 # 80012518 <pr>
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
    800008da:	c5a50513          	addi	a0,a0,-934 # 80012530 <tx_lock>
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
    800008fe:	c3650513          	addi	a0,a0,-970 # 80012530 <tx_lock>
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
    8000091c:	b3490913          	addi	s2,s2,-1228 # 8000a44c <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	b2898993          	addi	s3,s3,-1240 # 8000a448 <tx_chan>
      release(&tx_lock);
    80000928:	00012497          	auipc	s1,0x12
    8000092c:	c0848493          	addi	s1,s1,-1016 # 80012530 <tx_lock>
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
    8000093a:	6e8010ef          	jal	80002022 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	71a010ef          	jal	8000205e <sleep>
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
    8000097c:	bb850513          	addi	a0,a0,-1096 # 80012530 <tx_lock>
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
    800009a0:	aa87a783          	lw	a5,-1368(a5) # 8000a444 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	a9a7a783          	lw	a5,-1382(a5) # 8000a440 <panicked>
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
    800009d0:	a787a783          	lw	a5,-1416(a5) # 8000a444 <panicking>
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
    80000a06:	b2e50513          	addi	a0,a0,-1234 # 80012530 <tx_lock>
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
    80000a20:	b1450513          	addi	a0,a0,-1260 # 80012530 <tx_lock>
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
    80000a48:	a007a423          	sw	zero,-1528(a5) # 8000a44c <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	9fc50513          	addi	a0,a0,-1540 # 8000a448 <tx_chan>
    80000a54:	63a010ef          	jal	8000208e <wakeup>
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
    80000a76:	d0678793          	addi	a5,a5,-762 # 80023778 <end>
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
    80000aa0:	aac90913          	addi	s2,s2,-1364 # 80012548 <kmem>
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
    80000b2e:	a1e50513          	addi	a0,a0,-1506 # 80012548 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00023517          	auipc	a0,0x23
    80000b3e:	c3e50513          	addi	a0,a0,-962 # 80023778 <end>
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
    80000b5c:	9f050513          	addi	a0,a0,-1552 # 80012548 <kmem>
    80000b60:	0c8000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b64:	00012497          	auipc	s1,0x12
    80000b68:	9fc4b483          	ld	s1,-1540(s1) # 80012560 <kmem+0x18>
  if (r)
    80000b6c:	c49d                	beqz	s1,80000b9a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00012717          	auipc	a4,0x12
    80000b74:	9ef73823          	sd	a5,-1552(a4) # 80012560 <kmem+0x18>
  release(&kmem.lock);
    80000b78:	00012517          	auipc	a0,0x12
    80000b7c:	9d050513          	addi	a0,a0,-1584 # 80012548 <kmem>
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
    80000b9e:	9ae50513          	addi	a0,a0,-1618 # 80012548 <kmem>
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
    80000bd8:	621000ef          	jal	800019f8 <mycpu>
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
    80000bfe:	5fb000ef          	jal	800019f8 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x2c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	5f3000ef          	jal	800019f8 <mycpu>
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
    80000c1a:	5df000ef          	jal	800019f8 <mycpu>
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
    80000c4c:	5ad000ef          	jal	800019f8 <mycpu>
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
    80000c70:	589000ef          	jal	800019f8 <mycpu>
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
    80000ea6:	33f000ef          	jal	800019e4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eaa:	00009717          	auipc	a4,0x9
    80000eae:	5a670713          	addi	a4,a4,1446 # 8000a450 <started>
  if (cpuid() == 0) {
    80000eb2:	c51d                	beqz	a0,80000ee0 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eb4:	431c                	lw	a5,0(a4)
    80000eb6:	0230000f          	fence	r,rw
    80000eba:	2781                	sext.w	a5,a5
    80000ebc:	dfe5                	beqz	a5,80000eb4 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000ebe:	327000ef          	jal	800019e4 <cpuid>
    80000ec2:	85aa                	mv	a1,a0
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1d450513          	addi	a0,a0,468 # 80007098 <etext+0x98>
    80000ecc:	e3eff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000ed0:	082000ef          	jal	80000f52 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000ed4:	6aa010ef          	jal	8000257e <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	0e1040ef          	jal	800057b8 <plicinithart>
  }

  scheduler();
    80000edc:	7ab000ef          	jal	80001e86 <scheduler>
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
    80000f18:	217000ef          	jal	8000192e <procinit>
    trapinit();         // trap vectors
    80000f1c:	63e010ef          	jal	8000255a <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	65e010ef          	jal	8000257e <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	07b040ef          	jal	8000579e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	091040ef          	jal	800057b8 <plicinithart>
    binit();            // buffer cache
    80000f2c:	535010ef          	jal	80002c60 <binit>
    iinit();            // inode table
    80000f30:	286020ef          	jal	800031b6 <iinit>
    fileinit();         // file table
    80000f34:	2b4030ef          	jal	800041e8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	177040ef          	jal	800058ae <virtio_disk_init>
    userinit();         // first user process
    80000f3c:	59f000ef          	jal	80001cda <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f40:	00009797          	auipc	a5,0x9
    80000f44:	51078793          	addi	a5,a5,1296 # 8000a450 <started>
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
    80000f62:	4fa7b783          	ld	a5,1274(a5) # 8000a458 <kernel_pagetable>
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
    800011ce:	6bc000ef          	jal	8000188a <proc_mapstacks>
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
    800011ee:	26a7b723          	sd	a0,622(a5) # 8000a458 <kernel_pagetable>
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
    80001724:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb888>
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

00000000800017ba <pageinfo>:

// pageinfo displays mapping status, PFN, and protection bits (P, W, U)
int
pageinfo(uint64 va)
{
    800017ba:	1101                	addi	sp,sp,-32
    800017bc:	ec06                	sd	ra,24(sp)
    800017be:	e822                	sd	s0,16(sp)
    800017c0:	e426                	sd	s1,8(sp)
    800017c2:	1000                	addi	s0,sp,32
    800017c4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800017c6:	252000ef          	jal	80001a18 <myproc>
  if (va >= MAXVA) {
    800017ca:	57fd                	li	a5,-1
    800017cc:	83e9                	srli	a5,a5,0x1a
    800017ce:	0497e663          	bltu	a5,s1,8000181a <pageinfo+0x60>
    printk("[pageinfo] VA: 0x%lx exceeds MAXVA (unmapped)\n", va);
    return -1;
  }
  pte_t *pte = walk(p->pagetable, va, 0);
    800017d2:	4601                	li	a2,0
    800017d4:	85a6                	mv	a1,s1
    800017d6:	6928                	ld	a0,80(a0)
    800017d8:	fa6ff0ef          	jal	80000f7e <walk>
  if (pte == 0 || (*pte & PTE_V) == 0) {
    800017dc:	c921                	beqz	a0,8000182c <pageinfo+0x72>
    800017de:	611c                	ld	a5,0(a0)
    800017e0:	0017f713          	andi	a4,a5,1
    800017e4:	c721                	beqz	a4,8000182c <pageinfo+0x72>
    printk("[pageinfo] VA: 0x%lx is NOT MAPPED\n", va);
    return -1;
  }
  uint64 pa = PTE2PA(*pte);
    800017e6:	00a7d693          	srli	a3,a5,0xa
  uint64 pfn = pa / PGSIZE;
  int present = (*pte & PTE_V) ? 1 : 0;
  int writable = (*pte & PTE_W) ? 1 : 0;
  int user = (*pte & PTE_U) ? 1 : 0;
    800017ea:	0047d813          	srli	a6,a5,0x4
  int writable = (*pte & PTE_W) ? 1 : 0;
    800017ee:	8389                	srli	a5,a5,0x2
  uint64 pfn = pa / PGSIZE;
    800017f0:	00c69613          	slli	a2,a3,0xc

  printk("[pageinfo] VA: 0x%lx -> PFN: 0x%lx (PA: 0x%lx) | Present: %d, Writable: %d, User: %d\n",
    800017f4:	00187813          	andi	a6,a6,1
    800017f8:	8b85                	andi	a5,a5,1
    800017fa:	4705                	li	a4,1
    800017fc:	86b2                	mv	a3,a2
    800017fe:	8231                	srli	a2,a2,0xc
    80001800:	85a6                	mv	a1,s1
    80001802:	00006517          	auipc	a0,0x6
    80001806:	9ae50513          	addi	a0,a0,-1618 # 800071b0 <etext+0x1b0>
    8000180a:	d01fe0ef          	jal	8000050a <printk>
         va, pfn, pa, present, writable, user);
  return 0;
    8000180e:	4501                	li	a0,0
}
    80001810:	60e2                	ld	ra,24(sp)
    80001812:	6442                	ld	s0,16(sp)
    80001814:	64a2                	ld	s1,8(sp)
    80001816:	6105                	addi	sp,sp,32
    80001818:	8082                	ret
    printk("[pageinfo] VA: 0x%lx exceeds MAXVA (unmapped)\n", va);
    8000181a:	85a6                	mv	a1,s1
    8000181c:	00006517          	auipc	a0,0x6
    80001820:	93c50513          	addi	a0,a0,-1732 # 80007158 <etext+0x158>
    80001824:	ce7fe0ef          	jal	8000050a <printk>
    return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	b7dd                	j	80001810 <pageinfo+0x56>
    printk("[pageinfo] VA: 0x%lx is NOT MAPPED\n", va);
    8000182c:	85a6                	mv	a1,s1
    8000182e:	00006517          	auipc	a0,0x6
    80001832:	95a50513          	addi	a0,a0,-1702 # 80007188 <etext+0x188>
    80001836:	cd5fe0ef          	jal	8000050a <printk>
    return -1;
    8000183a:	557d                	li	a0,-1
    8000183c:	bfd1                	j	80001810 <pageinfo+0x56>

000000008000183e <setreadonly>:

// setreadonly clears the write permission bit in the PTE and flushes the TLB
int
setreadonly(uint64 va)
{
    8000183e:	1101                	addi	sp,sp,-32
    80001840:	ec06                	sd	ra,24(sp)
    80001842:	e822                	sd	s0,16(sp)
    80001844:	e426                	sd	s1,8(sp)
    80001846:	1000                	addi	s0,sp,32
    80001848:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000184a:	1ce000ef          	jal	80001a18 <myproc>
  if (va >= MAXVA)
    8000184e:	57fd                	li	a5,-1
    80001850:	83e9                	srli	a5,a5,0x1a
    80001852:	0297e663          	bltu	a5,s1,8000187e <setreadonly+0x40>
    return -1;
  pte_t *pte = walk(p->pagetable, va, 0);
    80001856:	4601                	li	a2,0
    80001858:	85a6                	mv	a1,s1
    8000185a:	6928                	ld	a0,80(a0)
    8000185c:	f22ff0ef          	jal	80000f7e <walk>
  if (pte == 0 || (*pte & PTE_V) == 0)
    80001860:	c10d                	beqz	a0,80001882 <setreadonly+0x44>
    80001862:	611c                	ld	a5,0(a0)
    80001864:	0017f713          	andi	a4,a5,1
    80001868:	cf19                	beqz	a4,80001886 <setreadonly+0x48>
    return -1;

  // Clear writable bit
  *pte &= ~PTE_W;
    8000186a:	9bed                	andi	a5,a5,-5
    8000186c:	e11c                	sd	a5,0(a0)
    8000186e:	12000073          	sfence.vma

  // Flush the TLB so the change takes effect immediately
  sfence_vma();
  return 0;
    80001872:	4501                	li	a0,0
}
    80001874:	60e2                	ld	ra,24(sp)
    80001876:	6442                	ld	s0,16(sp)
    80001878:	64a2                	ld	s1,8(sp)
    8000187a:	6105                	addi	sp,sp,32
    8000187c:	8082                	ret
    return -1;
    8000187e:	557d                	li	a0,-1
    80001880:	bfd5                	j	80001874 <setreadonly+0x36>
    return -1;
    80001882:	557d                	li	a0,-1
    80001884:	bfc5                	j	80001874 <setreadonly+0x36>
    80001886:	557d                	li	a0,-1
    80001888:	b7f5                	j	80001874 <setreadonly+0x36>

000000008000188a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000188a:	715d                	addi	sp,sp,-80
    8000188c:	e486                	sd	ra,72(sp)
    8000188e:	e0a2                	sd	s0,64(sp)
    80001890:	fc26                	sd	s1,56(sp)
    80001892:	f84a                	sd	s2,48(sp)
    80001894:	f44e                	sd	s3,40(sp)
    80001896:	f052                	sd	s4,32(sp)
    80001898:	ec56                	sd	s5,24(sp)
    8000189a:	e85a                	sd	s6,16(sp)
    8000189c:	e45e                	sd	s7,8(sp)
    8000189e:	e062                	sd	s8,0(sp)
    800018a0:	0880                	addi	s0,sp,80
    800018a2:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800018a4:	00011497          	auipc	s1,0x11
    800018a8:	0f448493          	addi	s1,s1,244 # 80012998 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800018ac:	8c26                	mv	s8,s1
    800018ae:	000a57b7          	lui	a5,0xa5
    800018b2:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800018b6:	07b2                	slli	a5,a5,0xc
    800018b8:	fa578793          	addi	a5,a5,-91
    800018bc:	4fa50937          	lui	s2,0x4fa50
    800018c0:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800018c4:	1902                	slli	s2,s2,0x20
    800018c6:	993e                	add	s2,s2,a5
    800018c8:	040009b7          	lui	s3,0x4000
    800018cc:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018ce:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018d0:	4b99                	li	s7,6
    800018d2:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    800018d4:	00017a97          	auipc	s5,0x17
    800018d8:	ac4a8a93          	addi	s5,s5,-1340 # 80018398 <tickslock>
    char *pa = kalloc();
    800018dc:	a72ff0ef          	jal	80000b4e <kalloc>
    800018e0:	862a                	mv	a2,a0
    if (pa == 0)
    800018e2:	c121                	beqz	a0,80001922 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    800018e4:	418485b3          	sub	a1,s1,s8
    800018e8:	858d                	srai	a1,a1,0x3
    800018ea:	032585b3          	mul	a1,a1,s2
    800018ee:	05b6                	slli	a1,a1,0xd
    800018f0:	6789                	lui	a5,0x2
    800018f2:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018f4:	875e                	mv	a4,s7
    800018f6:	86da                	mv	a3,s6
    800018f8:	40b985b3          	sub	a1,s3,a1
    800018fc:	8552                	mv	a0,s4
    800018fe:	80bff0ef          	jal	80001108 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001902:	16848493          	addi	s1,s1,360
    80001906:	fd549be3          	bne	s1,s5,800018dc <proc_mapstacks+0x52>
  }
}
    8000190a:	60a6                	ld	ra,72(sp)
    8000190c:	6406                	ld	s0,64(sp)
    8000190e:	74e2                	ld	s1,56(sp)
    80001910:	7942                	ld	s2,48(sp)
    80001912:	79a2                	ld	s3,40(sp)
    80001914:	7a02                	ld	s4,32(sp)
    80001916:	6ae2                	ld	s5,24(sp)
    80001918:	6b42                	ld	s6,16(sp)
    8000191a:	6ba2                	ld	s7,8(sp)
    8000191c:	6c02                	ld	s8,0(sp)
    8000191e:	6161                	addi	sp,sp,80
    80001920:	8082                	ret
      panic("kalloc");
    80001922:	00006517          	auipc	a0,0x6
    80001926:	8e650513          	addi	a0,a0,-1818 # 80007208 <etext+0x208>
    8000192a:	f0bfe0ef          	jal	80000834 <panic>

000000008000192e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000192e:	7139                	addi	sp,sp,-64
    80001930:	fc06                	sd	ra,56(sp)
    80001932:	f822                	sd	s0,48(sp)
    80001934:	f426                	sd	s1,40(sp)
    80001936:	f04a                	sd	s2,32(sp)
    80001938:	ec4e                	sd	s3,24(sp)
    8000193a:	e852                	sd	s4,16(sp)
    8000193c:	e456                	sd	s5,8(sp)
    8000193e:	e05a                	sd	s6,0(sp)
    80001940:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001942:	00006597          	auipc	a1,0x6
    80001946:	8ce58593          	addi	a1,a1,-1842 # 80007210 <etext+0x210>
    8000194a:	00011517          	auipc	a0,0x11
    8000194e:	c1e50513          	addi	a0,a0,-994 # 80012568 <pid_lock>
    80001952:	a56ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001956:	00006597          	auipc	a1,0x6
    8000195a:	8c258593          	addi	a1,a1,-1854 # 80007218 <etext+0x218>
    8000195e:	00011517          	auipc	a0,0x11
    80001962:	c2250513          	addi	a0,a0,-990 # 80012580 <wait_lock>
    80001966:	a42ff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000196a:	00011497          	auipc	s1,0x11
    8000196e:	02e48493          	addi	s1,s1,46 # 80012998 <proc>
    initlock(&p->lock, "proc");
    80001972:	00006b17          	auipc	s6,0x6
    80001976:	8b6b0b13          	addi	s6,s6,-1866 # 80007228 <etext+0x228>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000197a:	8aa6                	mv	s5,s1
    8000197c:	000a57b7          	lui	a5,0xa5
    80001980:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001984:	07b2                	slli	a5,a5,0xc
    80001986:	fa578793          	addi	a5,a5,-91
    8000198a:	4fa50937          	lui	s2,0x4fa50
    8000198e:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001992:	1902                	slli	s2,s2,0x20
    80001994:	993e                	add	s2,s2,a5
    80001996:	040009b7          	lui	s3,0x4000
    8000199a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000199c:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    8000199e:	00017a17          	auipc	s4,0x17
    800019a2:	9faa0a13          	addi	s4,s4,-1542 # 80018398 <tickslock>
    initlock(&p->lock, "proc");
    800019a6:	85da                	mv	a1,s6
    800019a8:	8526                	mv	a0,s1
    800019aa:	9feff0ef          	jal	80000ba8 <initlock>
    p->state = UNUSED;
    800019ae:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800019b2:	415487b3          	sub	a5,s1,s5
    800019b6:	878d                	srai	a5,a5,0x3
    800019b8:	032787b3          	mul	a5,a5,s2
    800019bc:	07b6                	slli	a5,a5,0xd
    800019be:	6709                	lui	a4,0x2
    800019c0:	9fb9                	addw	a5,a5,a4
    800019c2:	40f987b3          	sub	a5,s3,a5
    800019c6:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    800019c8:	16848493          	addi	s1,s1,360
    800019cc:	fd449de3          	bne	s1,s4,800019a6 <procinit+0x78>
  }
}
    800019d0:	70e2                	ld	ra,56(sp)
    800019d2:	7442                	ld	s0,48(sp)
    800019d4:	74a2                	ld	s1,40(sp)
    800019d6:	7902                	ld	s2,32(sp)
    800019d8:	69e2                	ld	s3,24(sp)
    800019da:	6a42                	ld	s4,16(sp)
    800019dc:	6aa2                	ld	s5,8(sp)
    800019de:	6b02                	ld	s6,0(sp)
    800019e0:	6121                	addi	sp,sp,64
    800019e2:	8082                	ret

00000000800019e4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019e4:	1141                	addi	sp,sp,-16
    800019e6:	e406                	sd	ra,8(sp)
    800019e8:	e022                	sd	s0,0(sp)
    800019ea:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    800019ec:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019ee:	2501                	sext.w	a0,a0
    800019f0:	60a2                	ld	ra,8(sp)
    800019f2:	6402                	ld	s0,0(sp)
    800019f4:	0141                	addi	sp,sp,16
    800019f6:	8082                	ret

00000000800019f8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800019f8:	1141                	addi	sp,sp,-16
    800019fa:	e406                	sd	ra,8(sp)
    800019fc:	e022                	sd	s0,0(sp)
    800019fe:	0800                	addi	s0,sp,16
    80001a00:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a02:	2781                	sext.w	a5,a5
    80001a04:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a06:	00011517          	auipc	a0,0x11
    80001a0a:	b9250513          	addi	a0,a0,-1134 # 80012598 <cpus>
    80001a0e:	953e                	add	a0,a0,a5
    80001a10:	60a2                	ld	ra,8(sp)
    80001a12:	6402                	ld	s0,0(sp)
    80001a14:	0141                	addi	sp,sp,16
    80001a16:	8082                	ret

0000000080001a18 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001a18:	1101                	addi	sp,sp,-32
    80001a1a:	ec06                	sd	ra,24(sp)
    80001a1c:	e822                	sd	s0,16(sp)
    80001a1e:	e426                	sd	s1,8(sp)
    80001a20:	1000                	addi	s0,sp,32
  push_off();
    80001a22:	9ccff0ef          	jal	80000bee <push_off>
    80001a26:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a28:	2781                	sext.w	a5,a5
    80001a2a:	079e                	slli	a5,a5,0x7
    80001a2c:	00011717          	auipc	a4,0x11
    80001a30:	b3c70713          	addi	a4,a4,-1220 # 80012568 <pid_lock>
    80001a34:	97ba                	add	a5,a5,a4
    80001a36:	7b9c                	ld	a5,48(a5)
    80001a38:	84be                	mv	s1,a5
  pop_off();
    80001a3a:	a2eff0ef          	jal	80000c68 <pop_off>
  return p;
}
    80001a3e:	8526                	mv	a0,s1
    80001a40:	60e2                	ld	ra,24(sp)
    80001a42:	6442                	ld	s0,16(sp)
    80001a44:	64a2                	ld	s1,8(sp)
    80001a46:	6105                	addi	sp,sp,32
    80001a48:	8082                	ret

0000000080001a4a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a4a:	7179                	addi	sp,sp,-48
    80001a4c:	f406                	sd	ra,40(sp)
    80001a4e:	f022                	sd	s0,32(sp)
    80001a50:	ec26                	sd	s1,24(sp)
    80001a52:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001a54:	fc5ff0ef          	jal	80001a18 <myproc>
    80001a58:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001a5a:	a56ff0ef          	jal	80000cb0 <release>

  if (first) {
    80001a5e:	00009797          	auipc	a5,0x9
    80001a62:	9b27a783          	lw	a5,-1614(a5) # 8000a410 <first.1>
    80001a66:	cf85                	beqz	a5,80001a9e <forkret+0x54>
    first = 0;
    80001a68:	00009797          	auipc	a5,0x9
    80001a6c:	9a07a423          	sw	zero,-1624(a5) # 8000a410 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001a70:	4505                	li	a0,1
    80001a72:	449010ef          	jal	800036ba <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001a76:	00005797          	auipc	a5,0x5
    80001a7a:	7ba78793          	addi	a5,a5,1978 # 80007230 <etext+0x230>
    80001a7e:	fcf43823          	sd	a5,-48(s0)
    80001a82:	fc043c23          	sd	zero,-40(s0)
    80001a86:	fd040593          	addi	a1,s0,-48
    80001a8a:	853e                	mv	a0,a5
    80001a8c:	6e3020ef          	jal	8000496e <kexec>
    80001a90:	6cbc                	ld	a5,88(s1)
    80001a92:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001a94:	6cbc                	ld	a5,88(s1)
    80001a96:	7bb8                	ld	a4,112(a5)
    80001a98:	57fd                	li	a5,-1
    80001a9a:	02f70d63          	beq	a4,a5,80001ad4 <forkret+0x8a>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001a9e:	2fd000ef          	jal	8000259a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001aa2:	68a8                	ld	a0,80(s1)
    80001aa4:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001aa6:	04000737          	lui	a4,0x4000
    80001aaa:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001aac:	0732                	slli	a4,a4,0xc
    80001aae:	00004797          	auipc	a5,0x4
    80001ab2:	5ee78793          	addi	a5,a5,1518 # 8000609c <userret>
    80001ab6:	00004697          	auipc	a3,0x4
    80001aba:	54a68693          	addi	a3,a3,1354 # 80006000 <_trampoline>
    80001abe:	8f95                	sub	a5,a5,a3
    80001ac0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001ac2:	577d                	li	a4,-1
    80001ac4:	177e                	slli	a4,a4,0x3f
    80001ac6:	8d59                	or	a0,a0,a4
    80001ac8:	9782                	jalr	a5
}
    80001aca:	70a2                	ld	ra,40(sp)
    80001acc:	7402                	ld	s0,32(sp)
    80001ace:	64e2                	ld	s1,24(sp)
    80001ad0:	6145                	addi	sp,sp,48
    80001ad2:	8082                	ret
      panic("exec");
    80001ad4:	00005517          	auipc	a0,0x5
    80001ad8:	76450513          	addi	a0,a0,1892 # 80007238 <etext+0x238>
    80001adc:	d59fe0ef          	jal	80000834 <panic>

0000000080001ae0 <allocpid>:
{
    80001ae0:	1101                	addi	sp,sp,-32
    80001ae2:	ec06                	sd	ra,24(sp)
    80001ae4:	e822                	sd	s0,16(sp)
    80001ae6:	e426                	sd	s1,8(sp)
    80001ae8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001aea:	00011517          	auipc	a0,0x11
    80001aee:	a7e50513          	addi	a0,a0,-1410 # 80012568 <pid_lock>
    80001af2:	936ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001af6:	00009797          	auipc	a5,0x9
    80001afa:	91e78793          	addi	a5,a5,-1762 # 8000a414 <nextpid>
    80001afe:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b00:	0014871b          	addiw	a4,s1,1
    80001b04:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b06:	00011517          	auipc	a0,0x11
    80001b0a:	a6250513          	addi	a0,a0,-1438 # 80012568 <pid_lock>
    80001b0e:	9a2ff0ef          	jal	80000cb0 <release>
}
    80001b12:	8526                	mv	a0,s1
    80001b14:	60e2                	ld	ra,24(sp)
    80001b16:	6442                	ld	s0,16(sp)
    80001b18:	64a2                	ld	s1,8(sp)
    80001b1a:	6105                	addi	sp,sp,32
    80001b1c:	8082                	ret

0000000080001b1e <proc_pagetable>:
{
    80001b1e:	1101                	addi	sp,sp,-32
    80001b20:	ec06                	sd	ra,24(sp)
    80001b22:	e822                	sd	s0,16(sp)
    80001b24:	e426                	sd	s1,8(sp)
    80001b26:	e04a                	sd	s2,0(sp)
    80001b28:	1000                	addi	s0,sp,32
    80001b2a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b2c:	eceff0ef          	jal	800011fa <uvmcreate>
    80001b30:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001b32:	cd05                	beqz	a0,80001b6a <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001b34:	4729                	li	a4,10
    80001b36:	00004697          	auipc	a3,0x4
    80001b3a:	4ca68693          	addi	a3,a3,1226 # 80006000 <_trampoline>
    80001b3e:	6605                	lui	a2,0x1
    80001b40:	040005b7          	lui	a1,0x4000
    80001b44:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b46:	05b2                	slli	a1,a1,0xc
    80001b48:	d0aff0ef          	jal	80001052 <mappages>
    80001b4c:	02054663          	bltz	a0,80001b78 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001b50:	4719                	li	a4,6
    80001b52:	05893683          	ld	a3,88(s2)
    80001b56:	6605                	lui	a2,0x1
    80001b58:	020005b7          	lui	a1,0x2000
    80001b5c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b5e:	05b6                	slli	a1,a1,0xd
    80001b60:	8526                	mv	a0,s1
    80001b62:	cf0ff0ef          	jal	80001052 <mappages>
    80001b66:	00054f63          	bltz	a0,80001b84 <proc_pagetable+0x66>
}
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	60e2                	ld	ra,24(sp)
    80001b6e:	6442                	ld	s0,16(sp)
    80001b70:	64a2                	ld	s1,8(sp)
    80001b72:	6902                	ld	s2,0(sp)
    80001b74:	6105                	addi	sp,sp,32
    80001b76:	8082                	ret
    uvmfree(pagetable, 0);
    80001b78:	4581                	li	a1,0
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	879ff0ef          	jal	800013f4 <uvmfree>
    return 0;
    80001b80:	4481                	li	s1,0
    80001b82:	b7e5                	j	80001b6a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b84:	4681                	li	a3,0
    80001b86:	4605                	li	a2,1
    80001b88:	040005b7          	lui	a1,0x4000
    80001b8c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b8e:	05b2                	slli	a1,a1,0xc
    80001b90:	8526                	mv	a0,s1
    80001b92:	e8eff0ef          	jal	80001220 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b96:	4581                	li	a1,0
    80001b98:	8526                	mv	a0,s1
    80001b9a:	85bff0ef          	jal	800013f4 <uvmfree>
    return 0;
    80001b9e:	4481                	li	s1,0
    80001ba0:	b7e9                	j	80001b6a <proc_pagetable+0x4c>

0000000080001ba2 <proc_freepagetable>:
{
    80001ba2:	1101                	addi	sp,sp,-32
    80001ba4:	ec06                	sd	ra,24(sp)
    80001ba6:	e822                	sd	s0,16(sp)
    80001ba8:	e426                	sd	s1,8(sp)
    80001baa:	e04a                	sd	s2,0(sp)
    80001bac:	1000                	addi	s0,sp,32
    80001bae:	84aa                	mv	s1,a0
    80001bb0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bb2:	4681                	li	a3,0
    80001bb4:	4605                	li	a2,1
    80001bb6:	040005b7          	lui	a1,0x4000
    80001bba:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bbc:	05b2                	slli	a1,a1,0xc
    80001bbe:	e62ff0ef          	jal	80001220 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bc2:	4681                	li	a3,0
    80001bc4:	4605                	li	a2,1
    80001bc6:	020005b7          	lui	a1,0x2000
    80001bca:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bcc:	05b6                	slli	a1,a1,0xd
    80001bce:	8526                	mv	a0,s1
    80001bd0:	e50ff0ef          	jal	80001220 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bd4:	85ca                	mv	a1,s2
    80001bd6:	8526                	mv	a0,s1
    80001bd8:	81dff0ef          	jal	800013f4 <uvmfree>
}
    80001bdc:	60e2                	ld	ra,24(sp)
    80001bde:	6442                	ld	s0,16(sp)
    80001be0:	64a2                	ld	s1,8(sp)
    80001be2:	6902                	ld	s2,0(sp)
    80001be4:	6105                	addi	sp,sp,32
    80001be6:	8082                	ret

0000000080001be8 <freeproc>:
{
    80001be8:	1101                	addi	sp,sp,-32
    80001bea:	ec06                	sd	ra,24(sp)
    80001bec:	e822                	sd	s0,16(sp)
    80001bee:	e426                	sd	s1,8(sp)
    80001bf0:	1000                	addi	s0,sp,32
    80001bf2:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001bf4:	6d28                	ld	a0,88(a0)
    80001bf6:	c119                	beqz	a0,80001bfc <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001bf8:	e6ffe0ef          	jal	80000a66 <kfree>
  p->trapframe = 0;
    80001bfc:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001c00:	68a8                	ld	a0,80(s1)
    80001c02:	c501                	beqz	a0,80001c0a <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001c04:	64ac                	ld	a1,72(s1)
    80001c06:	f9dff0ef          	jal	80001ba2 <proc_freepagetable>
  p->pagetable = 0;
    80001c0a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c0e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c12:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001c16:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c1a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c1e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c22:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c26:	0004ac23          	sw	zero,24(s1)
}
    80001c2a:	60e2                	ld	ra,24(sp)
    80001c2c:	6442                	ld	s0,16(sp)
    80001c2e:	64a2                	ld	s1,8(sp)
    80001c30:	6105                	addi	sp,sp,32
    80001c32:	8082                	ret

0000000080001c34 <allocproc>:
{
    80001c34:	1101                	addi	sp,sp,-32
    80001c36:	ec06                	sd	ra,24(sp)
    80001c38:	e822                	sd	s0,16(sp)
    80001c3a:	e426                	sd	s1,8(sp)
    80001c3c:	e04a                	sd	s2,0(sp)
    80001c3e:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001c40:	00011497          	auipc	s1,0x11
    80001c44:	d5848493          	addi	s1,s1,-680 # 80012998 <proc>
    80001c48:	00016917          	auipc	s2,0x16
    80001c4c:	75090913          	addi	s2,s2,1872 # 80018398 <tickslock>
    acquire(&p->lock);
    80001c50:	8526                	mv	a0,s1
    80001c52:	fd7fe0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001c56:	4c9c                	lw	a5,24(s1)
    80001c58:	cb91                	beqz	a5,80001c6c <allocproc+0x38>
      release(&p->lock);
    80001c5a:	8526                	mv	a0,s1
    80001c5c:	854ff0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001c60:	16848493          	addi	s1,s1,360
    80001c64:	ff2496e3          	bne	s1,s2,80001c50 <allocproc+0x1c>
  return 0;
    80001c68:	4481                	li	s1,0
    80001c6a:	a089                	j	80001cac <allocproc+0x78>
  p->pid = allocpid();
    80001c6c:	e75ff0ef          	jal	80001ae0 <allocpid>
    80001c70:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c72:	4785                	li	a5,1
    80001c74:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001c76:	ed9fe0ef          	jal	80000b4e <kalloc>
    80001c7a:	892a                	mv	s2,a0
    80001c7c:	eca8                	sd	a0,88(s1)
    80001c7e:	cd15                	beqz	a0,80001cba <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001c80:	8526                	mv	a0,s1
    80001c82:	e9dff0ef          	jal	80001b1e <proc_pagetable>
    80001c86:	892a                	mv	s2,a0
    80001c88:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001c8a:	c121                	beqz	a0,80001cca <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001c8c:	07000613          	li	a2,112
    80001c90:	4581                	li	a1,0
    80001c92:	06048513          	addi	a0,s1,96
    80001c96:	852ff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001c9a:	00000797          	auipc	a5,0x0
    80001c9e:	db078793          	addi	a5,a5,-592 # 80001a4a <forkret>
    80001ca2:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ca4:	60bc                	ld	a5,64(s1)
    80001ca6:	6705                	lui	a4,0x1
    80001ca8:	97ba                	add	a5,a5,a4
    80001caa:	f4bc                	sd	a5,104(s1)
}
    80001cac:	8526                	mv	a0,s1
    80001cae:	60e2                	ld	ra,24(sp)
    80001cb0:	6442                	ld	s0,16(sp)
    80001cb2:	64a2                	ld	s1,8(sp)
    80001cb4:	6902                	ld	s2,0(sp)
    80001cb6:	6105                	addi	sp,sp,32
    80001cb8:	8082                	ret
    freeproc(p);
    80001cba:	8526                	mv	a0,s1
    80001cbc:	f2dff0ef          	jal	80001be8 <freeproc>
    release(&p->lock);
    80001cc0:	8526                	mv	a0,s1
    80001cc2:	feffe0ef          	jal	80000cb0 <release>
    return 0;
    80001cc6:	84ca                	mv	s1,s2
    80001cc8:	b7d5                	j	80001cac <allocproc+0x78>
    freeproc(p);
    80001cca:	8526                	mv	a0,s1
    80001ccc:	f1dff0ef          	jal	80001be8 <freeproc>
    release(&p->lock);
    80001cd0:	8526                	mv	a0,s1
    80001cd2:	fdffe0ef          	jal	80000cb0 <release>
    return 0;
    80001cd6:	84ca                	mv	s1,s2
    80001cd8:	bfd1                	j	80001cac <allocproc+0x78>

0000000080001cda <userinit>:
{
    80001cda:	1101                	addi	sp,sp,-32
    80001cdc:	ec06                	sd	ra,24(sp)
    80001cde:	e822                	sd	s0,16(sp)
    80001ce0:	e426                	sd	s1,8(sp)
    80001ce2:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ce4:	f51ff0ef          	jal	80001c34 <allocproc>
    80001ce8:	84aa                	mv	s1,a0
  initproc = p;
    80001cea:	00008797          	auipc	a5,0x8
    80001cee:	76a7bb23          	sd	a0,1910(a5) # 8000a460 <initproc>
  p->cwd = namei("/");
    80001cf2:	00005517          	auipc	a0,0x5
    80001cf6:	54e50513          	addi	a0,a0,1358 # 80007240 <etext+0x240>
    80001cfa:	71f010ef          	jal	80003c18 <namei>
    80001cfe:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d02:	478d                	li	a5,3
    80001d04:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d06:	8526                	mv	a0,s1
    80001d08:	fa9fe0ef          	jal	80000cb0 <release>
}
    80001d0c:	60e2                	ld	ra,24(sp)
    80001d0e:	6442                	ld	s0,16(sp)
    80001d10:	64a2                	ld	s1,8(sp)
    80001d12:	6105                	addi	sp,sp,32
    80001d14:	8082                	ret

0000000080001d16 <growproc>:
{
    80001d16:	1101                	addi	sp,sp,-32
    80001d18:	ec06                	sd	ra,24(sp)
    80001d1a:	e822                	sd	s0,16(sp)
    80001d1c:	e426                	sd	s1,8(sp)
    80001d1e:	e04a                	sd	s2,0(sp)
    80001d20:	1000                	addi	s0,sp,32
    80001d22:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d24:	cf5ff0ef          	jal	80001a18 <myproc>
    80001d28:	892a                	mv	s2,a0
  sz = p->sz;
    80001d2a:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001d2c:	02905963          	blez	s1,80001d5e <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001d30:	00b48633          	add	a2,s1,a1
    80001d34:	020007b7          	lui	a5,0x2000
    80001d38:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001d3a:	07b6                	slli	a5,a5,0xd
    80001d3c:	02c7ea63          	bltu	a5,a2,80001d70 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d40:	4691                	li	a3,4
    80001d42:	6928                	ld	a0,80(a0)
    80001d44:	daaff0ef          	jal	800012ee <uvmalloc>
    80001d48:	85aa                	mv	a1,a0
    80001d4a:	c50d                	beqz	a0,80001d74 <growproc+0x5e>
  p->sz = sz;
    80001d4c:	04b93423          	sd	a1,72(s2)
  return 0;
    80001d50:	4501                	li	a0,0
}
    80001d52:	60e2                	ld	ra,24(sp)
    80001d54:	6442                	ld	s0,16(sp)
    80001d56:	64a2                	ld	s1,8(sp)
    80001d58:	6902                	ld	s2,0(sp)
    80001d5a:	6105                	addi	sp,sp,32
    80001d5c:	8082                	ret
  } else if (n < 0) {
    80001d5e:	fe04d7e3          	bgez	s1,80001d4c <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d62:	00b48633          	add	a2,s1,a1
    80001d66:	6928                	ld	a0,80(a0)
    80001d68:	d42ff0ef          	jal	800012aa <uvmdealloc>
    80001d6c:	85aa                	mv	a1,a0
    80001d6e:	bff9                	j	80001d4c <growproc+0x36>
      return -1;
    80001d70:	557d                	li	a0,-1
    80001d72:	b7c5                	j	80001d52 <growproc+0x3c>
      return -1;
    80001d74:	557d                	li	a0,-1
    80001d76:	bff1                	j	80001d52 <growproc+0x3c>

0000000080001d78 <kfork>:
{
    80001d78:	7139                	addi	sp,sp,-64
    80001d7a:	fc06                	sd	ra,56(sp)
    80001d7c:	f822                	sd	s0,48(sp)
    80001d7e:	f426                	sd	s1,40(sp)
    80001d80:	e456                	sd	s5,8(sp)
    80001d82:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d84:	c95ff0ef          	jal	80001a18 <myproc>
    80001d88:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001d8a:	eabff0ef          	jal	80001c34 <allocproc>
    80001d8e:	0e050a63          	beqz	a0,80001e82 <kfork+0x10a>
    80001d92:	e852                	sd	s4,16(sp)
    80001d94:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001d96:	048ab603          	ld	a2,72(s5)
    80001d9a:	692c                	ld	a1,80(a0)
    80001d9c:	050ab503          	ld	a0,80(s5)
    80001da0:	e86ff0ef          	jal	80001426 <uvmcopy>
    80001da4:	04054863          	bltz	a0,80001df4 <kfork+0x7c>
    80001da8:	f04a                	sd	s2,32(sp)
    80001daa:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001dac:	048ab783          	ld	a5,72(s5)
    80001db0:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001db4:	058ab683          	ld	a3,88(s5)
    80001db8:	87b6                	mv	a5,a3
    80001dba:	058a3703          	ld	a4,88(s4)
    80001dbe:	12068693          	addi	a3,a3,288
    80001dc2:	6388                	ld	a0,0(a5)
    80001dc4:	678c                	ld	a1,8(a5)
    80001dc6:	6b90                	ld	a2,16(a5)
    80001dc8:	e308                	sd	a0,0(a4)
    80001dca:	e70c                	sd	a1,8(a4)
    80001dcc:	eb10                	sd	a2,16(a4)
    80001dce:	6f90                	ld	a2,24(a5)
    80001dd0:	ef10                	sd	a2,24(a4)
    80001dd2:	02078793          	addi	a5,a5,32
    80001dd6:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001dda:	fed794e3          	bne	a5,a3,80001dc2 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001dde:	058a3783          	ld	a5,88(s4)
    80001de2:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001de6:	0d0a8493          	addi	s1,s5,208
    80001dea:	0d0a0913          	addi	s2,s4,208
    80001dee:	150a8993          	addi	s3,s5,336
    80001df2:	a831                	j	80001e0e <kfork+0x96>
    freeproc(np);
    80001df4:	8552                	mv	a0,s4
    80001df6:	df3ff0ef          	jal	80001be8 <freeproc>
    release(&np->lock);
    80001dfa:	8552                	mv	a0,s4
    80001dfc:	eb5fe0ef          	jal	80000cb0 <release>
    return -1;
    80001e00:	54fd                	li	s1,-1
    80001e02:	6a42                	ld	s4,16(sp)
    80001e04:	a885                	j	80001e74 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001e06:	04a1                	addi	s1,s1,8
    80001e08:	0921                	addi	s2,s2,8
    80001e0a:	01348963          	beq	s1,s3,80001e1c <kfork+0xa4>
    if (p->ofile[i])
    80001e0e:	6088                	ld	a0,0(s1)
    80001e10:	d97d                	beqz	a0,80001e06 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e12:	458020ef          	jal	8000426a <filedup>
    80001e16:	00a93023          	sd	a0,0(s2)
    80001e1a:	b7f5                	j	80001e06 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001e1c:	150ab503          	ld	a0,336(s5)
    80001e20:	528010ef          	jal	80003348 <idup>
    80001e24:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e28:	4641                	li	a2,16
    80001e2a:	158a8593          	addi	a1,s5,344
    80001e2e:	158a0513          	addi	a0,s4,344
    80001e32:	80aff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001e36:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001e3a:	8552                	mv	a0,s4
    80001e3c:	e75fe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001e40:	00010517          	auipc	a0,0x10
    80001e44:	74050513          	addi	a0,a0,1856 # 80012580 <wait_lock>
    80001e48:	de1fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001e4c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e50:	00010517          	auipc	a0,0x10
    80001e54:	73050513          	addi	a0,a0,1840 # 80012580 <wait_lock>
    80001e58:	e59fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001e5c:	8552                	mv	a0,s4
    80001e5e:	dcbfe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001e62:	478d                	li	a5,3
    80001e64:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e68:	8552                	mv	a0,s4
    80001e6a:	e47fe0ef          	jal	80000cb0 <release>
  return pid;
    80001e6e:	7902                	ld	s2,32(sp)
    80001e70:	69e2                	ld	s3,24(sp)
    80001e72:	6a42                	ld	s4,16(sp)
}
    80001e74:	8526                	mv	a0,s1
    80001e76:	70e2                	ld	ra,56(sp)
    80001e78:	7442                	ld	s0,48(sp)
    80001e7a:	74a2                	ld	s1,40(sp)
    80001e7c:	6aa2                	ld	s5,8(sp)
    80001e7e:	6121                	addi	sp,sp,64
    80001e80:	8082                	ret
    return -1;
    80001e82:	54fd                	li	s1,-1
    80001e84:	bfc5                	j	80001e74 <kfork+0xfc>

0000000080001e86 <scheduler>:
{
    80001e86:	711d                	addi	sp,sp,-96
    80001e88:	ec86                	sd	ra,88(sp)
    80001e8a:	e8a2                	sd	s0,80(sp)
    80001e8c:	e4a6                	sd	s1,72(sp)
    80001e8e:	e0ca                	sd	s2,64(sp)
    80001e90:	fc4e                	sd	s3,56(sp)
    80001e92:	f852                	sd	s4,48(sp)
    80001e94:	f456                	sd	s5,40(sp)
    80001e96:	f05a                	sd	s6,32(sp)
    80001e98:	ec5e                	sd	s7,24(sp)
    80001e9a:	e862                	sd	s8,16(sp)
    80001e9c:	e466                	sd	s9,8(sp)
    80001e9e:	1080                	addi	s0,sp,96
    80001ea0:	8792                	mv	a5,tp
  int id = r_tp();
    80001ea2:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ea4:	00779a93          	slli	s5,a5,0x7
    80001ea8:	00010717          	auipc	a4,0x10
    80001eac:	6c070713          	addi	a4,a4,1728 # 80012568 <pid_lock>
    80001eb0:	9756                	add	a4,a4,s5
    80001eb2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001eb6:	00010717          	auipc	a4,0x10
    80001eba:	6ea70713          	addi	a4,a4,1770 # 800125a0 <cpus+0x8>
    80001ebe:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001ec0:	4c11                	li	s8,4
        c->proc = p;
    80001ec2:	00010b17          	auipc	s6,0x10
    80001ec6:	6a6b0b13          	addi	s6,s6,1702 # 80012568 <pid_lock>
    80001eca:	079e                	slli	a5,a5,0x7
    80001ecc:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001ed0:	4b85                	li	s7,1
    80001ed2:	a0a9                	j	80001f1c <scheduler+0x96>
      release(&p->lock);
    80001ed4:	8526                	mv	a0,s1
    80001ed6:	ddbfe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001eda:	16848493          	addi	s1,s1,360
    80001ede:	03248b63          	beq	s1,s2,80001f14 <scheduler+0x8e>
      acquire(&p->lock);
    80001ee2:	8526                	mv	a0,s1
    80001ee4:	d45fe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001ee8:	4c9c                	lw	a5,24(s1)
    80001eea:	ff3795e3          	bne	a5,s3,80001ed4 <scheduler+0x4e>
        p->state = RUNNING;
    80001eee:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001ef2:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001ef6:	06048593          	addi	a1,s1,96
    80001efa:	8556                	mv	a0,s5
    80001efc:	5f4000ef          	jal	800024f0 <swtch>
    80001f00:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001f02:	2781                	sext.w	a5,a5
    80001f04:	079e                	slli	a5,a5,0x7
    80001f06:	97da                	add	a5,a5,s6
    80001f08:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001f0c:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001f10:	8cde                	mv	s9,s7
    80001f12:	b7c9                	j	80001ed4 <scheduler+0x4e>
    if (found == 0) {
    80001f14:	000c9463          	bnez	s9,80001f1c <scheduler+0x96>
      asm volatile("wfi");
    80001f18:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001f1c:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001f20:	10017073          	csrci	sstatus,2
    int found = 0;
    80001f24:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f26:	00011497          	auipc	s1,0x11
    80001f2a:	a7248493          	addi	s1,s1,-1422 # 80012998 <proc>
      if (p->state == RUNNABLE) {
    80001f2e:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f30:	00016917          	auipc	s2,0x16
    80001f34:	46890913          	addi	s2,s2,1128 # 80018398 <tickslock>
    80001f38:	b76d                	j	80001ee2 <scheduler+0x5c>

0000000080001f3a <sched>:
{
    80001f3a:	7179                	addi	sp,sp,-48
    80001f3c:	f406                	sd	ra,40(sp)
    80001f3e:	f022                	sd	s0,32(sp)
    80001f40:	ec26                	sd	s1,24(sp)
    80001f42:	e84a                	sd	s2,16(sp)
    80001f44:	e44e                	sd	s3,8(sp)
    80001f46:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f48:	ad1ff0ef          	jal	80001a18 <myproc>
    80001f4c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001f4e:	c75fe0ef          	jal	80000bc2 <holding>
    80001f52:	c935                	beqz	a0,80001fc6 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f54:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001f56:	2781                	sext.w	a5,a5
    80001f58:	079e                	slli	a5,a5,0x7
    80001f5a:	00010717          	auipc	a4,0x10
    80001f5e:	60e70713          	addi	a4,a4,1550 # 80012568 <pid_lock>
    80001f62:	97ba                	add	a5,a5,a4
    80001f64:	0a87a703          	lw	a4,168(a5)
    80001f68:	4785                	li	a5,1
    80001f6a:	06f71463          	bne	a4,a5,80001fd2 <sched+0x98>
  if (p->state == RUNNING)
    80001f6e:	4c98                	lw	a4,24(s1)
    80001f70:	4791                	li	a5,4
    80001f72:	06f70663          	beq	a4,a5,80001fde <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001f76:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f7a:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001f7c:	e7bd                	bnez	a5,80001fea <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f7e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f80:	00010917          	auipc	s2,0x10
    80001f84:	5e890913          	addi	s2,s2,1512 # 80012568 <pid_lock>
    80001f88:	2781                	sext.w	a5,a5
    80001f8a:	079e                	slli	a5,a5,0x7
    80001f8c:	97ca                	add	a5,a5,s2
    80001f8e:	0ac7a983          	lw	s3,172(a5)
    80001f92:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f94:	2781                	sext.w	a5,a5
    80001f96:	079e                	slli	a5,a5,0x7
    80001f98:	07a1                	addi	a5,a5,8
    80001f9a:	00010597          	auipc	a1,0x10
    80001f9e:	5fe58593          	addi	a1,a1,1534 # 80012598 <cpus>
    80001fa2:	95be                	add	a1,a1,a5
    80001fa4:	06048513          	addi	a0,s1,96
    80001fa8:	548000ef          	jal	800024f0 <swtch>
    80001fac:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fae:	2781                	sext.w	a5,a5
    80001fb0:	079e                	slli	a5,a5,0x7
    80001fb2:	993e                	add	s2,s2,a5
    80001fb4:	0b392623          	sw	s3,172(s2)
}
    80001fb8:	70a2                	ld	ra,40(sp)
    80001fba:	7402                	ld	s0,32(sp)
    80001fbc:	64e2                	ld	s1,24(sp)
    80001fbe:	6942                	ld	s2,16(sp)
    80001fc0:	69a2                	ld	s3,8(sp)
    80001fc2:	6145                	addi	sp,sp,48
    80001fc4:	8082                	ret
    panic("sched p->lock");
    80001fc6:	00005517          	auipc	a0,0x5
    80001fca:	28250513          	addi	a0,a0,642 # 80007248 <etext+0x248>
    80001fce:	867fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80001fd2:	00005517          	auipc	a0,0x5
    80001fd6:	28650513          	addi	a0,a0,646 # 80007258 <etext+0x258>
    80001fda:	85bfe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80001fde:	00005517          	auipc	a0,0x5
    80001fe2:	28a50513          	addi	a0,a0,650 # 80007268 <etext+0x268>
    80001fe6:	84ffe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80001fea:	00005517          	auipc	a0,0x5
    80001fee:	28e50513          	addi	a0,a0,654 # 80007278 <etext+0x278>
    80001ff2:	843fe0ef          	jal	80000834 <panic>

0000000080001ff6 <yield>:
{
    80001ff6:	1101                	addi	sp,sp,-32
    80001ff8:	ec06                	sd	ra,24(sp)
    80001ffa:	e822                	sd	s0,16(sp)
    80001ffc:	e426                	sd	s1,8(sp)
    80001ffe:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002000:	a19ff0ef          	jal	80001a18 <myproc>
    80002004:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002006:	c23fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    8000200a:	478d                	li	a5,3
    8000200c:	cc9c                	sw	a5,24(s1)
  sched();
    8000200e:	f2dff0ef          	jal	80001f3a <sched>
  release(&p->lock);
    80002012:	8526                	mv	a0,s1
    80002014:	c9dfe0ef          	jal	80000cb0 <release>
}
    80002018:	60e2                	ld	ra,24(sp)
    8000201a:	6442                	ld	s0,16(sp)
    8000201c:	64a2                	ld	s1,8(sp)
    8000201e:	6105                	addi	sp,sp,32
    80002020:	8082                	ret

0000000080002022 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80002022:	1101                	addi	sp,sp,-32
    80002024:	ec06                	sd	ra,24(sp)
    80002026:	e822                	sd	s0,16(sp)
    80002028:	e426                	sd	s1,8(sp)
    8000202a:	e04a                	sd	s2,0(sp)
    8000202c:	1000                	addi	s0,sp,32
    8000202e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002030:	9e9ff0ef          	jal	80001a18 <myproc>
    80002034:	892a                	mv	s2,a0

  acquire(&p->lock);
    80002036:	bf3fe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    8000203a:	cc81                	beqz	s1,80002052 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    8000203c:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80002040:	854a                	mv	a0,s2
    80002042:	c6ffe0ef          	jal	80000cb0 <release>
}
    80002046:	60e2                	ld	ra,24(sp)
    80002048:	6442                	ld	s0,16(sp)
    8000204a:	64a2                	ld	s1,8(sp)
    8000204c:	6902                	ld	s2,0(sp)
    8000204e:	6105                	addi	sp,sp,32
    80002050:	8082                	ret
    panic("sleep_prepare: zero chan");
    80002052:	00005517          	auipc	a0,0x5
    80002056:	23e50513          	addi	a0,a0,574 # 80007290 <etext+0x290>
    8000205a:	fdafe0ef          	jal	80000834 <panic>

000000008000205e <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    8000205e:	1101                	addi	sp,sp,-32
    80002060:	ec06                	sd	ra,24(sp)
    80002062:	e822                	sd	s0,16(sp)
    80002064:	e426                	sd	s1,8(sp)
    80002066:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002068:	9b1ff0ef          	jal	80001a18 <myproc>
    8000206c:	84aa                	mv	s1,a0

  acquire(&p->lock);
    8000206e:	bbbfe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    80002072:	709c                	ld	a5,32(s1)
    80002074:	c789                	beqz	a5,8000207e <sleep+0x20>
    p->state = SLEEPING;
    80002076:	4789                	li	a5,2
    80002078:	cc9c                	sw	a5,24(s1)
    sched();
    8000207a:	ec1ff0ef          	jal	80001f3a <sched>
  }
  release(&p->lock);
    8000207e:	8526                	mv	a0,s1
    80002080:	c31fe0ef          	jal	80000cb0 <release>
}
    80002084:	60e2                	ld	ra,24(sp)
    80002086:	6442                	ld	s0,16(sp)
    80002088:	64a2                	ld	s1,8(sp)
    8000208a:	6105                	addi	sp,sp,32
    8000208c:	8082                	ret

000000008000208e <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    8000208e:	7139                	addi	sp,sp,-64
    80002090:	fc06                	sd	ra,56(sp)
    80002092:	f822                	sd	s0,48(sp)
    80002094:	f426                	sd	s1,40(sp)
    80002096:	f04a                	sd	s2,32(sp)
    80002098:	ec4e                	sd	s3,24(sp)
    8000209a:	e852                	sd	s4,16(sp)
    8000209c:	e456                	sd	s5,8(sp)
    8000209e:	0080                	addi	s0,sp,64
    800020a0:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800020a2:	00011497          	auipc	s1,0x11
    800020a6:	8f648493          	addi	s1,s1,-1802 # 80012998 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    800020aa:	4a09                	li	s4,2
        p->state = RUNNABLE;
    800020ac:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    800020ae:	00016997          	auipc	s3,0x16
    800020b2:	2ea98993          	addi	s3,s3,746 # 80018398 <tickslock>
    800020b6:	a801                	j	800020c6 <wakeup+0x38>
      }
    }
    release(&p->lock);
    800020b8:	8526                	mv	a0,s1
    800020ba:	bf7fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800020be:	16848493          	addi	s1,s1,360
    800020c2:	03348063          	beq	s1,s3,800020e2 <wakeup+0x54>
    acquire(&p->lock);
    800020c6:	8526                	mv	a0,s1
    800020c8:	b61fe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    800020cc:	709c                	ld	a5,32(s1)
    800020ce:	ff2795e3          	bne	a5,s2,800020b8 <wakeup+0x2a>
      p->chan = 0;
    800020d2:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    800020d6:	4c9c                	lw	a5,24(s1)
    800020d8:	ff4790e3          	bne	a5,s4,800020b8 <wakeup+0x2a>
        p->state = RUNNABLE;
    800020dc:	0154ac23          	sw	s5,24(s1)
    800020e0:	bfe1                	j	800020b8 <wakeup+0x2a>
  }
}
    800020e2:	70e2                	ld	ra,56(sp)
    800020e4:	7442                	ld	s0,48(sp)
    800020e6:	74a2                	ld	s1,40(sp)
    800020e8:	7902                	ld	s2,32(sp)
    800020ea:	69e2                	ld	s3,24(sp)
    800020ec:	6a42                	ld	s4,16(sp)
    800020ee:	6aa2                	ld	s5,8(sp)
    800020f0:	6121                	addi	sp,sp,64
    800020f2:	8082                	ret

00000000800020f4 <reparent>:
{
    800020f4:	7179                	addi	sp,sp,-48
    800020f6:	f406                	sd	ra,40(sp)
    800020f8:	f022                	sd	s0,32(sp)
    800020fa:	ec26                	sd	s1,24(sp)
    800020fc:	e84a                	sd	s2,16(sp)
    800020fe:	e44e                	sd	s3,8(sp)
    80002100:	e052                	sd	s4,0(sp)
    80002102:	1800                	addi	s0,sp,48
    80002104:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002106:	00011497          	auipc	s1,0x11
    8000210a:	89248493          	addi	s1,s1,-1902 # 80012998 <proc>
      pp->parent = initproc;
    8000210e:	00008a17          	auipc	s4,0x8
    80002112:	352a0a13          	addi	s4,s4,850 # 8000a460 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002116:	00016997          	auipc	s3,0x16
    8000211a:	28298993          	addi	s3,s3,642 # 80018398 <tickslock>
    8000211e:	a029                	j	80002128 <reparent+0x34>
    80002120:	16848493          	addi	s1,s1,360
    80002124:	01348b63          	beq	s1,s3,8000213a <reparent+0x46>
    if (pp->parent == p) {
    80002128:	7c9c                	ld	a5,56(s1)
    8000212a:	ff279be3          	bne	a5,s2,80002120 <reparent+0x2c>
      pp->parent = initproc;
    8000212e:	000a3503          	ld	a0,0(s4)
    80002132:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002134:	f5bff0ef          	jal	8000208e <wakeup>
    80002138:	b7e5                	j	80002120 <reparent+0x2c>
}
    8000213a:	70a2                	ld	ra,40(sp)
    8000213c:	7402                	ld	s0,32(sp)
    8000213e:	64e2                	ld	s1,24(sp)
    80002140:	6942                	ld	s2,16(sp)
    80002142:	69a2                	ld	s3,8(sp)
    80002144:	6a02                	ld	s4,0(sp)
    80002146:	6145                	addi	sp,sp,48
    80002148:	8082                	ret

000000008000214a <kexit>:
{
    8000214a:	7179                	addi	sp,sp,-48
    8000214c:	f406                	sd	ra,40(sp)
    8000214e:	f022                	sd	s0,32(sp)
    80002150:	ec26                	sd	s1,24(sp)
    80002152:	e84a                	sd	s2,16(sp)
    80002154:	e44e                	sd	s3,8(sp)
    80002156:	e052                	sd	s4,0(sp)
    80002158:	1800                	addi	s0,sp,48
    8000215a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000215c:	8bdff0ef          	jal	80001a18 <myproc>
    80002160:	89aa                	mv	s3,a0
  if (p == initproc)
    80002162:	00008797          	auipc	a5,0x8
    80002166:	2fe7b783          	ld	a5,766(a5) # 8000a460 <initproc>
    8000216a:	0d050493          	addi	s1,a0,208
    8000216e:	15050913          	addi	s2,a0,336
    80002172:	00a79b63          	bne	a5,a0,80002188 <kexit+0x3e>
    panic("init exiting");
    80002176:	00005517          	auipc	a0,0x5
    8000217a:	13a50513          	addi	a0,a0,314 # 800072b0 <etext+0x2b0>
    8000217e:	eb6fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002182:	04a1                	addi	s1,s1,8
    80002184:	01248963          	beq	s1,s2,80002196 <kexit+0x4c>
    if (p->ofile[fd]) {
    80002188:	6088                	ld	a0,0(s1)
    8000218a:	dd65                	beqz	a0,80002182 <kexit+0x38>
      fileclose(f);
    8000218c:	124020ef          	jal	800042b0 <fileclose>
      p->ofile[fd] = 0;
    80002190:	0004b023          	sd	zero,0(s1)
    80002194:	b7fd                	j	80002182 <kexit+0x38>
  begin_op();
    80002196:	461010ef          	jal	80003df6 <begin_op>
  iput(p->cwd);
    8000219a:	1509b503          	ld	a0,336(s3)
    8000219e:	362010ef          	jal	80003500 <iput>
  end_op();
    800021a2:	4e1010ef          	jal	80003e82 <end_op>
  p->cwd = 0;
    800021a6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800021aa:	00010517          	auipc	a0,0x10
    800021ae:	3d650513          	addi	a0,a0,982 # 80012580 <wait_lock>
    800021b2:	a77fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    800021b6:	854e                	mv	a0,s3
    800021b8:	f3dff0ef          	jal	800020f4 <reparent>
  wakeup(p->parent);
    800021bc:	0389b503          	ld	a0,56(s3)
    800021c0:	ecfff0ef          	jal	8000208e <wakeup>
  acquire(&p->lock);
    800021c4:	854e                	mv	a0,s3
    800021c6:	a63fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    800021ca:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800021ce:	4795                	li	a5,5
    800021d0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800021d4:	00010517          	auipc	a0,0x10
    800021d8:	3ac50513          	addi	a0,a0,940 # 80012580 <wait_lock>
    800021dc:	ad5fe0ef          	jal	80000cb0 <release>
  sched();
    800021e0:	d5bff0ef          	jal	80001f3a <sched>
  panic("zombie exit");
    800021e4:	00005517          	auipc	a0,0x5
    800021e8:	0dc50513          	addi	a0,a0,220 # 800072c0 <etext+0x2c0>
    800021ec:	e48fe0ef          	jal	80000834 <panic>

00000000800021f0 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    800021f0:	c525                	beqz	a0,80002258 <kkill+0x68>
{
    800021f2:	7179                	addi	sp,sp,-48
    800021f4:	f406                	sd	ra,40(sp)
    800021f6:	f022                	sd	s0,32(sp)
    800021f8:	ec26                	sd	s1,24(sp)
    800021fa:	e84a                	sd	s2,16(sp)
    800021fc:	e44e                	sd	s3,8(sp)
    800021fe:	1800                	addi	s0,sp,48
    80002200:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002202:	00010497          	auipc	s1,0x10
    80002206:	79648493          	addi	s1,s1,1942 # 80012998 <proc>
    8000220a:	00016997          	auipc	s3,0x16
    8000220e:	18e98993          	addi	s3,s3,398 # 80018398 <tickslock>
    acquire(&p->lock);
    80002212:	8526                	mv	a0,s1
    80002214:	a15fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    80002218:	589c                	lw	a5,48(s1)
    8000221a:	01278b63          	beq	a5,s2,80002230 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000221e:	8526                	mv	a0,s1
    80002220:	a91fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002224:	16848493          	addi	s1,s1,360
    80002228:	ff3495e3          	bne	s1,s3,80002212 <kkill+0x22>
  }
  return -1;
    8000222c:	557d                	li	a0,-1
    8000222e:	a819                	j	80002244 <kkill+0x54>
      p->killed = 1;
    80002230:	4785                	li	a5,1
    80002232:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002234:	4c98                	lw	a4,24(s1)
    80002236:	4789                	li	a5,2
    80002238:	00f70d63          	beq	a4,a5,80002252 <kkill+0x62>
      release(&p->lock);
    8000223c:	8526                	mv	a0,s1
    8000223e:	a73fe0ef          	jal	80000cb0 <release>
      return 0;
    80002242:	4501                	li	a0,0
}
    80002244:	70a2                	ld	ra,40(sp)
    80002246:	7402                	ld	s0,32(sp)
    80002248:	64e2                	ld	s1,24(sp)
    8000224a:	6942                	ld	s2,16(sp)
    8000224c:	69a2                	ld	s3,8(sp)
    8000224e:	6145                	addi	sp,sp,48
    80002250:	8082                	ret
        p->state = RUNNABLE;
    80002252:	478d                	li	a5,3
    80002254:	cc9c                	sw	a5,24(s1)
    80002256:	b7dd                	j	8000223c <kkill+0x4c>
    return -1;
    80002258:	557d                	li	a0,-1
}
    8000225a:	8082                	ret

000000008000225c <setkilled>:

void
setkilled(struct proc *p)
{
    8000225c:	1101                	addi	sp,sp,-32
    8000225e:	ec06                	sd	ra,24(sp)
    80002260:	e822                	sd	s0,16(sp)
    80002262:	e426                	sd	s1,8(sp)
    80002264:	1000                	addi	s0,sp,32
    80002266:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002268:	9c1fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    8000226c:	4785                	li	a5,1
    8000226e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002270:	8526                	mv	a0,s1
    80002272:	a3ffe0ef          	jal	80000cb0 <release>
}
    80002276:	60e2                	ld	ra,24(sp)
    80002278:	6442                	ld	s0,16(sp)
    8000227a:	64a2                	ld	s1,8(sp)
    8000227c:	6105                	addi	sp,sp,32
    8000227e:	8082                	ret

0000000080002280 <killed>:

int
killed(struct proc *p)
{
    80002280:	1101                	addi	sp,sp,-32
    80002282:	ec06                	sd	ra,24(sp)
    80002284:	e822                	sd	s0,16(sp)
    80002286:	e426                	sd	s1,8(sp)
    80002288:	e04a                	sd	s2,0(sp)
    8000228a:	1000                	addi	s0,sp,32
    8000228c:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000228e:	99bfe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80002292:	549c                	lw	a5,40(s1)
    80002294:	893e                	mv	s2,a5
  release(&p->lock);
    80002296:	8526                	mv	a0,s1
    80002298:	a19fe0ef          	jal	80000cb0 <release>
  return k;
}
    8000229c:	854a                	mv	a0,s2
    8000229e:	60e2                	ld	ra,24(sp)
    800022a0:	6442                	ld	s0,16(sp)
    800022a2:	64a2                	ld	s1,8(sp)
    800022a4:	6902                	ld	s2,0(sp)
    800022a6:	6105                	addi	sp,sp,32
    800022a8:	8082                	ret

00000000800022aa <kwait>:
{
    800022aa:	715d                	addi	sp,sp,-80
    800022ac:	e486                	sd	ra,72(sp)
    800022ae:	e0a2                	sd	s0,64(sp)
    800022b0:	fc26                	sd	s1,56(sp)
    800022b2:	f84a                	sd	s2,48(sp)
    800022b4:	f44e                	sd	s3,40(sp)
    800022b6:	f052                	sd	s4,32(sp)
    800022b8:	ec56                	sd	s5,24(sp)
    800022ba:	e85a                	sd	s6,16(sp)
    800022bc:	e45e                	sd	s7,8(sp)
    800022be:	0880                	addi	s0,sp,80
    800022c0:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800022c2:	f56ff0ef          	jal	80001a18 <myproc>
    800022c6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800022c8:	00010517          	auipc	a0,0x10
    800022cc:	2b850513          	addi	a0,a0,696 # 80012580 <wait_lock>
    800022d0:	959fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800022d4:	4a15                	li	s4,5
        havekids = 1;
    800022d6:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022d8:	00016997          	auipc	s3,0x16
    800022dc:	0c098993          	addi	s3,s3,192 # 80018398 <tickslock>
    release(&wait_lock);
    800022e0:	00010b17          	auipc	s6,0x10
    800022e4:	2a0b0b13          	addi	s6,s6,672 # 80012580 <wait_lock>
    800022e8:	a845                	j	80002398 <kwait+0xee>
          pid = pp->pid;
    800022ea:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    800022ee:	000b8e63          	beqz	s7,8000230a <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    800022f2:	4711                	li	a4,4
    800022f4:	02c48693          	addi	a3,s1,44
    800022f8:	865e                	mv	a2,s7
    800022fa:	04893583          	ld	a1,72(s2)
    800022fe:	05093503          	ld	a0,80(s2)
    80002302:	a80ff0ef          	jal	80001582 <copyout>
          if (addr != 0 &&
    80002306:	02054c63          	bltz	a0,8000233e <kwait+0x94>
          pp->parent = 0;
    8000230a:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    8000230e:	8526                	mv	a0,s1
    80002310:	8d9ff0ef          	jal	80001be8 <freeproc>
          release(&pp->lock);
    80002314:	8526                	mv	a0,s1
    80002316:	99bfe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    8000231a:	00010517          	auipc	a0,0x10
    8000231e:	26650513          	addi	a0,a0,614 # 80012580 <wait_lock>
    80002322:	98ffe0ef          	jal	80000cb0 <release>
}
    80002326:	854e                	mv	a0,s3
    80002328:	60a6                	ld	ra,72(sp)
    8000232a:	6406                	ld	s0,64(sp)
    8000232c:	74e2                	ld	s1,56(sp)
    8000232e:	7942                	ld	s2,48(sp)
    80002330:	79a2                	ld	s3,40(sp)
    80002332:	7a02                	ld	s4,32(sp)
    80002334:	6ae2                	ld	s5,24(sp)
    80002336:	6b42                	ld	s6,16(sp)
    80002338:	6ba2                	ld	s7,8(sp)
    8000233a:	6161                	addi	sp,sp,80
    8000233c:	8082                	ret
            release(&pp->lock);
    8000233e:	8526                	mv	a0,s1
    80002340:	971fe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    80002344:	00010517          	auipc	a0,0x10
    80002348:	23c50513          	addi	a0,a0,572 # 80012580 <wait_lock>
    8000234c:	965fe0ef          	jal	80000cb0 <release>
            return -1;
    80002350:	59fd                	li	s3,-1
    80002352:	bfd1                	j	80002326 <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002354:	16848493          	addi	s1,s1,360
    80002358:	03348063          	beq	s1,s3,80002378 <kwait+0xce>
      if (pp->parent == p) {
    8000235c:	7c9c                	ld	a5,56(s1)
    8000235e:	ff279be3          	bne	a5,s2,80002354 <kwait+0xaa>
        acquire(&pp->lock);
    80002362:	8526                	mv	a0,s1
    80002364:	8c5fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002368:	4c9c                	lw	a5,24(s1)
    8000236a:	f94780e3          	beq	a5,s4,800022ea <kwait+0x40>
        release(&pp->lock);
    8000236e:	8526                	mv	a0,s1
    80002370:	941fe0ef          	jal	80000cb0 <release>
        havekids = 1;
    80002374:	8756                	mv	a4,s5
    80002376:	bff9                	j	80002354 <kwait+0xaa>
    if (!havekids || killed(p)) {
    80002378:	c715                	beqz	a4,800023a4 <kwait+0xfa>
    8000237a:	854a                	mv	a0,s2
    8000237c:	f05ff0ef          	jal	80002280 <killed>
    80002380:	e115                	bnez	a0,800023a4 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    80002382:	854a                	mv	a0,s2
    80002384:	c9fff0ef          	jal	80002022 <sleep_prepare>
    release(&wait_lock);
    80002388:	855a                	mv	a0,s6
    8000238a:	927fe0ef          	jal	80000cb0 <release>
    sleep();
    8000238e:	cd1ff0ef          	jal	8000205e <sleep>
    acquire(&wait_lock);
    80002392:	855a                	mv	a0,s6
    80002394:	895fe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    80002398:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000239a:	00010497          	auipc	s1,0x10
    8000239e:	5fe48493          	addi	s1,s1,1534 # 80012998 <proc>
    800023a2:	bf6d                	j	8000235c <kwait+0xb2>
      release(&wait_lock);
    800023a4:	00010517          	auipc	a0,0x10
    800023a8:	1dc50513          	addi	a0,a0,476 # 80012580 <wait_lock>
    800023ac:	905fe0ef          	jal	80000cb0 <release>
      return -1;
    800023b0:	59fd                	li	s3,-1
    800023b2:	bf95                	j	80002326 <kwait+0x7c>

00000000800023b4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800023b4:	7179                	addi	sp,sp,-48
    800023b6:	f406                	sd	ra,40(sp)
    800023b8:	f022                	sd	s0,32(sp)
    800023ba:	ec26                	sd	s1,24(sp)
    800023bc:	e84a                	sd	s2,16(sp)
    800023be:	e44e                	sd	s3,8(sp)
    800023c0:	e052                	sd	s4,0(sp)
    800023c2:	1800                	addi	s0,sp,48
    800023c4:	84aa                	mv	s1,a0
    800023c6:	8a2e                	mv	s4,a1
    800023c8:	89b2                	mv	s3,a2
    800023ca:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800023cc:	e4cff0ef          	jal	80001a18 <myproc>
  if (user_dst) {
    800023d0:	c085                	beqz	s1,800023f0 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    800023d2:	874a                	mv	a4,s2
    800023d4:	86ce                	mv	a3,s3
    800023d6:	8652                	mv	a2,s4
    800023d8:	652c                	ld	a1,72(a0)
    800023da:	6928                	ld	a0,80(a0)
    800023dc:	9a6ff0ef          	jal	80001582 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800023e0:	70a2                	ld	ra,40(sp)
    800023e2:	7402                	ld	s0,32(sp)
    800023e4:	64e2                	ld	s1,24(sp)
    800023e6:	6942                	ld	s2,16(sp)
    800023e8:	69a2                	ld	s3,8(sp)
    800023ea:	6a02                	ld	s4,0(sp)
    800023ec:	6145                	addi	sp,sp,48
    800023ee:	8082                	ret
    memmove((char *)dst, src, len);
    800023f0:	0009061b          	sext.w	a2,s2
    800023f4:	85ce                	mv	a1,s3
    800023f6:	8552                	mv	a0,s4
    800023f8:	951fe0ef          	jal	80000d48 <memmove>
    return 0;
    800023fc:	8526                	mv	a0,s1
    800023fe:	b7cd                	j	800023e0 <either_copyout+0x2c>

0000000080002400 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002400:	7179                	addi	sp,sp,-48
    80002402:	f406                	sd	ra,40(sp)
    80002404:	f022                	sd	s0,32(sp)
    80002406:	ec26                	sd	s1,24(sp)
    80002408:	e84a                	sd	s2,16(sp)
    8000240a:	e44e                	sd	s3,8(sp)
    8000240c:	e052                	sd	s4,0(sp)
    8000240e:	1800                	addi	s0,sp,48
    80002410:	8a2a                	mv	s4,a0
    80002412:	84ae                	mv	s1,a1
    80002414:	89b2                	mv	s3,a2
    80002416:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002418:	e00ff0ef          	jal	80001a18 <myproc>
  if (user_src) {
    8000241c:	c085                	beqz	s1,8000243c <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    8000241e:	874a                	mv	a4,s2
    80002420:	86ce                	mv	a3,s3
    80002422:	8652                	mv	a2,s4
    80002424:	652c                	ld	a1,72(a0)
    80002426:	6928                	ld	a0,80(a0)
    80002428:	a20ff0ef          	jal	80001648 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000242c:	70a2                	ld	ra,40(sp)
    8000242e:	7402                	ld	s0,32(sp)
    80002430:	64e2                	ld	s1,24(sp)
    80002432:	6942                	ld	s2,16(sp)
    80002434:	69a2                	ld	s3,8(sp)
    80002436:	6a02                	ld	s4,0(sp)
    80002438:	6145                	addi	sp,sp,48
    8000243a:	8082                	ret
    memmove(dst, (char *)src, len);
    8000243c:	0009061b          	sext.w	a2,s2
    80002440:	85ce                	mv	a1,s3
    80002442:	8552                	mv	a0,s4
    80002444:	905fe0ef          	jal	80000d48 <memmove>
    return 0;
    80002448:	8526                	mv	a0,s1
    8000244a:	b7cd                	j	8000242c <either_copyin+0x2c>

000000008000244c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000244c:	715d                	addi	sp,sp,-80
    8000244e:	e486                	sd	ra,72(sp)
    80002450:	e0a2                	sd	s0,64(sp)
    80002452:	fc26                	sd	s1,56(sp)
    80002454:	f84a                	sd	s2,48(sp)
    80002456:	f44e                	sd	s3,40(sp)
    80002458:	f052                	sd	s4,32(sp)
    8000245a:	ec56                	sd	s5,24(sp)
    8000245c:	e85a                	sd	s6,16(sp)
    8000245e:	e45e                	sd	s7,8(sp)
    80002460:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002462:	00005517          	auipc	a0,0x5
    80002466:	c1650513          	addi	a0,a0,-1002 # 80007078 <etext+0x78>
    8000246a:	8a0fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000246e:	00010497          	auipc	s1,0x10
    80002472:	68248493          	addi	s1,s1,1666 # 80012af0 <proc+0x158>
    80002476:	00016917          	auipc	s2,0x16
    8000247a:	07a90913          	addi	s2,s2,122 # 800184f0 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000247e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002480:	00005997          	auipc	s3,0x5
    80002484:	e5098993          	addi	s3,s3,-432 # 800072d0 <etext+0x2d0>
    printk("%d %s %s", p->pid, state, p->name);
    80002488:	00005a97          	auipc	s5,0x5
    8000248c:	e50a8a93          	addi	s5,s5,-432 # 800072d8 <etext+0x2d8>
    printk("\n");
    80002490:	00005a17          	auipc	s4,0x5
    80002494:	be8a0a13          	addi	s4,s4,-1048 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002498:	00005b97          	auipc	s7,0x5
    8000249c:	360b8b93          	addi	s7,s7,864 # 800077f8 <states.0>
    800024a0:	a829                	j	800024ba <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    800024a2:	ed86a583          	lw	a1,-296(a3)
    800024a6:	8556                	mv	a0,s5
    800024a8:	862fe0ef          	jal	8000050a <printk>
    printk("\n");
    800024ac:	8552                	mv	a0,s4
    800024ae:	85cfe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800024b2:	16848493          	addi	s1,s1,360
    800024b6:	03248263          	beq	s1,s2,800024da <procdump+0x8e>
    if (p->state == UNUSED)
    800024ba:	86a6                	mv	a3,s1
    800024bc:	ec04a783          	lw	a5,-320(s1)
    800024c0:	dbed                	beqz	a5,800024b2 <procdump+0x66>
      state = "???";
    800024c2:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024c4:	fcfb6fe3          	bltu	s6,a5,800024a2 <procdump+0x56>
    800024c8:	02079713          	slli	a4,a5,0x20
    800024cc:	01d75793          	srli	a5,a4,0x1d
    800024d0:	97de                	add	a5,a5,s7
    800024d2:	6390                	ld	a2,0(a5)
    800024d4:	f679                	bnez	a2,800024a2 <procdump+0x56>
      state = "???";
    800024d6:	864e                	mv	a2,s3
    800024d8:	b7e9                	j	800024a2 <procdump+0x56>
  }
}
    800024da:	60a6                	ld	ra,72(sp)
    800024dc:	6406                	ld	s0,64(sp)
    800024de:	74e2                	ld	s1,56(sp)
    800024e0:	7942                	ld	s2,48(sp)
    800024e2:	79a2                	ld	s3,40(sp)
    800024e4:	7a02                	ld	s4,32(sp)
    800024e6:	6ae2                	ld	s5,24(sp)
    800024e8:	6b42                	ld	s6,16(sp)
    800024ea:	6ba2                	ld	s7,8(sp)
    800024ec:	6161                	addi	sp,sp,80
    800024ee:	8082                	ret

00000000800024f0 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800024f0:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800024f4:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800024f8:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800024fa:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800024fc:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002500:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002504:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002508:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000250c:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002510:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002514:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002518:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000251c:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002520:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002524:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002528:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000252c:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000252e:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002530:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002534:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002538:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000253c:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002540:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002544:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002548:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000254c:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002550:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002554:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002558:	8082                	ret

000000008000255a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000255a:	1141                	addi	sp,sp,-16
    8000255c:	e406                	sd	ra,8(sp)
    8000255e:	e022                	sd	s0,0(sp)
    80002560:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002562:	00005597          	auipc	a1,0x5
    80002566:	db658593          	addi	a1,a1,-586 # 80007318 <etext+0x318>
    8000256a:	00016517          	auipc	a0,0x16
    8000256e:	e2e50513          	addi	a0,a0,-466 # 80018398 <tickslock>
    80002572:	e36fe0ef          	jal	80000ba8 <initlock>
}
    80002576:	60a2                	ld	ra,8(sp)
    80002578:	6402                	ld	s0,0(sp)
    8000257a:	0141                	addi	sp,sp,16
    8000257c:	8082                	ret

000000008000257e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000257e:	1141                	addi	sp,sp,-16
    80002580:	e406                	sd	ra,8(sp)
    80002582:	e022                	sd	s0,0(sp)
    80002584:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002586:	00003797          	auipc	a5,0x3
    8000258a:	1ba78793          	addi	a5,a5,442 # 80005740 <kernelvec>
    8000258e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002592:	60a2                	ld	ra,8(sp)
    80002594:	6402                	ld	s0,0(sp)
    80002596:	0141                	addi	sp,sp,16
    80002598:	8082                	ret

000000008000259a <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000259a:	1141                	addi	sp,sp,-16
    8000259c:	e406                	sd	ra,8(sp)
    8000259e:	e022                	sd	s0,0(sp)
    800025a0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800025a2:	c76ff0ef          	jal	80001a18 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    800025a6:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800025aa:	04000737          	lui	a4,0x4000
    800025ae:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800025b0:	0732                	slli	a4,a4,0xc
    800025b2:	00004797          	auipc	a5,0x4
    800025b6:	a4e78793          	addi	a5,a5,-1458 # 80006000 <_trampoline>
    800025ba:	00004697          	auipc	a3,0x4
    800025be:	a4668693          	addi	a3,a3,-1466 # 80006000 <_trampoline>
    800025c2:	8f95                	sub	a5,a5,a3
    800025c4:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    800025c6:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800025ca:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    800025cc:	18002773          	csrr	a4,satp
    800025d0:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800025d2:	6d38                	ld	a4,88(a0)
    800025d4:	613c                	ld	a5,64(a0)
    800025d6:	6685                	lui	a3,0x1
    800025d8:	97b6                	add	a5,a5,a3
    800025da:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800025dc:	6d3c                	ld	a5,88(a0)
    800025de:	00000717          	auipc	a4,0x0
    800025e2:	0fc70713          	addi	a4,a4,252 # 800026da <usertrap>
    800025e6:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800025e8:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    800025ea:	8712                	mv	a4,tp
    800025ec:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800025ee:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800025f2:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800025f6:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800025fa:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800025fe:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002600:	6f9c                	ld	a5,24(a5)
    80002602:	14179073          	csrw	sepc,a5
}
    80002606:	60a2                	ld	ra,8(sp)
    80002608:	6402                	ld	s0,0(sp)
    8000260a:	0141                	addi	sp,sp,16
    8000260c:	8082                	ret

000000008000260e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000260e:	1141                	addi	sp,sp,-16
    80002610:	e406                	sd	ra,8(sp)
    80002612:	e022                	sd	s0,0(sp)
    80002614:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80002616:	bceff0ef          	jal	800019e4 <cpuid>
    8000261a:	cd11                	beqz	a0,80002636 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    8000261c:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002620:	000f4737          	lui	a4,0xf4
    80002624:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002628:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000262a:	14d79073          	csrw	stimecmp,a5
}
    8000262e:	60a2                	ld	ra,8(sp)
    80002630:	6402                	ld	s0,0(sp)
    80002632:	0141                	addi	sp,sp,16
    80002634:	8082                	ret
    acquire(&tickslock);
    80002636:	00016517          	auipc	a0,0x16
    8000263a:	d6250513          	addi	a0,a0,-670 # 80018398 <tickslock>
    8000263e:	deafe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002642:	00008717          	auipc	a4,0x8
    80002646:	e2670713          	addi	a4,a4,-474 # 8000a468 <ticks>
    8000264a:	431c                	lw	a5,0(a4)
    8000264c:	2785                	addiw	a5,a5,1
    8000264e:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002650:	853a                	mv	a0,a4
    80002652:	a3dff0ef          	jal	8000208e <wakeup>
    release(&tickslock);
    80002656:	00016517          	auipc	a0,0x16
    8000265a:	d4250513          	addi	a0,a0,-702 # 80018398 <tickslock>
    8000265e:	e52fe0ef          	jal	80000cb0 <release>
    80002662:	bf6d                	j	8000261c <clockintr+0xe>

0000000080002664 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002664:	1101                	addi	sp,sp,-32
    80002666:	ec06                	sd	ra,24(sp)
    80002668:	e822                	sd	s0,16(sp)
    8000266a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    8000266c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002670:	57fd                	li	a5,-1
    80002672:	17fe                	slli	a5,a5,0x3f
    80002674:	07a5                	addi	a5,a5,9
    80002676:	00f70c63          	beq	a4,a5,8000268e <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    8000267a:	57fd                	li	a5,-1
    8000267c:	17fe                	slli	a5,a5,0x3f
    8000267e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002680:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002682:	04f70863          	beq	a4,a5,800026d2 <devintr+0x6e>
  }
}
    80002686:	60e2                	ld	ra,24(sp)
    80002688:	6442                	ld	s0,16(sp)
    8000268a:	6105                	addi	sp,sp,32
    8000268c:	8082                	ret
    8000268e:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002690:	15e030ef          	jal	800057ee <plic_claim>
    80002694:	872a                	mv	a4,a0
    80002696:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002698:	47a9                	li	a5,10
    8000269a:	00f50963          	beq	a0,a5,800026ac <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    8000269e:	4785                	li	a5,1
    800026a0:	00f50963          	beq	a0,a5,800026b2 <devintr+0x4e>
    return 1;
    800026a4:	4505                	li	a0,1
    } else if (irq) {
    800026a6:	eb09                	bnez	a4,800026b8 <devintr+0x54>
    800026a8:	64a2                	ld	s1,8(sp)
    800026aa:	bff1                	j	80002686 <devintr+0x22>
      uartintr();
    800026ac:	b42fe0ef          	jal	800009ee <uartintr>
    if (irq)
    800026b0:	a819                	j	800026c6 <devintr+0x62>
      virtio_disk_intr();
    800026b2:	5f8030ef          	jal	80005caa <virtio_disk_intr>
    if (irq)
    800026b6:	a801                	j	800026c6 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    800026b8:	85ba                	mv	a1,a4
    800026ba:	00005517          	auipc	a0,0x5
    800026be:	c6650513          	addi	a0,a0,-922 # 80007320 <etext+0x320>
    800026c2:	e49fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    800026c6:	8526                	mv	a0,s1
    800026c8:	148030ef          	jal	80005810 <plic_complete>
    return 1;
    800026cc:	4505                	li	a0,1
    800026ce:	64a2                	ld	s1,8(sp)
    800026d0:	bf5d                	j	80002686 <devintr+0x22>
    clockintr();
    800026d2:	f3dff0ef          	jal	8000260e <clockintr>
    return 2;
    800026d6:	4509                	li	a0,2
    800026d8:	b77d                	j	80002686 <devintr+0x22>

00000000800026da <usertrap>:
{
    800026da:	1101                	addi	sp,sp,-32
    800026dc:	ec06                	sd	ra,24(sp)
    800026de:	e822                	sd	s0,16(sp)
    800026e0:	e426                	sd	s1,8(sp)
    800026e2:	e04a                	sd	s2,0(sp)
    800026e4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026e6:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800026ea:	1007f793          	andi	a5,a5,256
    800026ee:	eba5                	bnez	a5,8000275e <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800026f0:	00003797          	auipc	a5,0x3
    800026f4:	05078793          	addi	a5,a5,80 # 80005740 <kernelvec>
    800026f8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800026fc:	b1cff0ef          	jal	80001a18 <myproc>
    80002700:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002702:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002704:	14102773          	csrr	a4,sepc
    80002708:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    8000270a:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    8000270e:	47a1                	li	a5,8
    80002710:	04f70d63          	beq	a4,a5,8000276a <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    80002714:	f51ff0ef          	jal	80002664 <devintr>
    80002718:	892a                	mv	s2,a0
    8000271a:	e54d                	bnez	a0,800027c4 <usertrap+0xea>
    8000271c:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002720:	47bd                	li	a5,15
    80002722:	08f70463          	beq	a4,a5,800027aa <usertrap+0xd0>
    80002726:	14202773          	csrr	a4,scause
    8000272a:	47b5                	li	a5,13
    8000272c:	06f70f63          	beq	a4,a5,800027aa <usertrap+0xd0>
    80002730:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002734:	5890                	lw	a2,48(s1)
    80002736:	00005517          	auipc	a0,0x5
    8000273a:	c2a50513          	addi	a0,a0,-982 # 80007360 <etext+0x360>
    8000273e:	dcdfd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002742:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002746:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000274a:	00005517          	auipc	a0,0x5
    8000274e:	c4650513          	addi	a0,a0,-954 # 80007390 <etext+0x390>
    80002752:	db9fd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002756:	8526                	mv	a0,s1
    80002758:	b05ff0ef          	jal	8000225c <setkilled>
    8000275c:	a015                	j	80002780 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    8000275e:	00005517          	auipc	a0,0x5
    80002762:	be250513          	addi	a0,a0,-1054 # 80007340 <etext+0x340>
    80002766:	8cefe0ef          	jal	80000834 <panic>
    if (killed(p))
    8000276a:	b17ff0ef          	jal	80002280 <killed>
    8000276e:	e915                	bnez	a0,800027a2 <usertrap+0xc8>
    p->trapframe->epc += 4;
    80002770:	6cb8                	ld	a4,88(s1)
    80002772:	6f1c                	ld	a5,24(a4)
    80002774:	0791                	addi	a5,a5,4
    80002776:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002778:	10016073          	csrsi	sstatus,2
    syscall();
    8000277c:	244000ef          	jal	800029c0 <syscall>
  if (killed(p))
    80002780:	8526                	mv	a0,s1
    80002782:	affff0ef          	jal	80002280 <killed>
    80002786:	e521                	bnez	a0,800027ce <usertrap+0xf4>
  prepare_return();
    80002788:	e13ff0ef          	jal	8000259a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000278c:	68a8                	ld	a0,80(s1)
    8000278e:	8131                	srli	a0,a0,0xc
    80002790:	57fd                	li	a5,-1
    80002792:	17fe                	slli	a5,a5,0x3f
    80002794:	8d5d                	or	a0,a0,a5
}
    80002796:	60e2                	ld	ra,24(sp)
    80002798:	6442                	ld	s0,16(sp)
    8000279a:	64a2                	ld	s1,8(sp)
    8000279c:	6902                	ld	s2,0(sp)
    8000279e:	6105                	addi	sp,sp,32
    800027a0:	8082                	ret
      kexit(-1);
    800027a2:	557d                	li	a0,-1
    800027a4:	9a7ff0ef          	jal	8000214a <kexit>
    800027a8:	b7e1                	j	80002770 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    800027aa:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    800027ae:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    800027b2:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    800027b4:	0016b693          	seqz	a3,a3
    800027b8:	64ac                	ld	a1,72(s1)
    800027ba:	68a8                	ld	a0,80(s1)
    800027bc:	d4bfe0ef          	jal	80001506 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800027c0:	f161                	bnez	a0,80002780 <usertrap+0xa6>
    800027c2:	b7bd                	j	80002730 <usertrap+0x56>
  if (killed(p))
    800027c4:	8526                	mv	a0,s1
    800027c6:	abbff0ef          	jal	80002280 <killed>
    800027ca:	c511                	beqz	a0,800027d6 <usertrap+0xfc>
    800027cc:	a011                	j	800027d0 <usertrap+0xf6>
    800027ce:	4901                	li	s2,0
    kexit(-1);
    800027d0:	557d                	li	a0,-1
    800027d2:	979ff0ef          	jal	8000214a <kexit>
  if (which_dev == 2)
    800027d6:	4789                	li	a5,2
    800027d8:	faf918e3          	bne	s2,a5,80002788 <usertrap+0xae>
    yield();
    800027dc:	81bff0ef          	jal	80001ff6 <yield>
    800027e0:	b765                	j	80002788 <usertrap+0xae>

00000000800027e2 <kerneltrap>:
{
    800027e2:	7179                	addi	sp,sp,-48
    800027e4:	f406                	sd	ra,40(sp)
    800027e6:	f022                	sd	s0,32(sp)
    800027e8:	ec26                	sd	s1,24(sp)
    800027ea:	e84a                	sd	s2,16(sp)
    800027ec:	e44e                	sd	s3,8(sp)
    800027ee:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027f0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027f4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800027f8:	142027f3          	csrr	a5,scause
    800027fc:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    800027fe:	1004f793          	andi	a5,s1,256
    80002802:	c795                	beqz	a5,8000282e <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002804:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002808:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000280a:	eb85                	bnez	a5,8000283a <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    8000280c:	e59ff0ef          	jal	80002664 <devintr>
    80002810:	c91d                	beqz	a0,80002846 <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    80002812:	4789                	li	a5,2
    80002814:	04f50a63          	beq	a0,a5,80002868 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002818:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000281c:	10049073          	csrw	sstatus,s1
}
    80002820:	70a2                	ld	ra,40(sp)
    80002822:	7402                	ld	s0,32(sp)
    80002824:	64e2                	ld	s1,24(sp)
    80002826:	6942                	ld	s2,16(sp)
    80002828:	69a2                	ld	s3,8(sp)
    8000282a:	6145                	addi	sp,sp,48
    8000282c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000282e:	00005517          	auipc	a0,0x5
    80002832:	b8a50513          	addi	a0,a0,-1142 # 800073b8 <etext+0x3b8>
    80002836:	ffffd0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    8000283a:	00005517          	auipc	a0,0x5
    8000283e:	ba650513          	addi	a0,a0,-1114 # 800073e0 <etext+0x3e0>
    80002842:	ff3fd0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002846:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000284a:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    8000284e:	85ce                	mv	a1,s3
    80002850:	00005517          	auipc	a0,0x5
    80002854:	bb050513          	addi	a0,a0,-1104 # 80007400 <etext+0x400>
    80002858:	cb3fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    8000285c:	00005517          	auipc	a0,0x5
    80002860:	bcc50513          	addi	a0,a0,-1076 # 80007428 <etext+0x428>
    80002864:	fd1fd0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    80002868:	9b0ff0ef          	jal	80001a18 <myproc>
    8000286c:	d555                	beqz	a0,80002818 <kerneltrap+0x36>
    yield();
    8000286e:	f88ff0ef          	jal	80001ff6 <yield>
    80002872:	b75d                	j	80002818 <kerneltrap+0x36>

0000000080002874 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002874:	1101                	addi	sp,sp,-32
    80002876:	ec06                	sd	ra,24(sp)
    80002878:	e822                	sd	s0,16(sp)
    8000287a:	e426                	sd	s1,8(sp)
    8000287c:	1000                	addi	s0,sp,32
    8000287e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002880:	998ff0ef          	jal	80001a18 <myproc>
  switch (n) {
    80002884:	4795                	li	a5,5
    80002886:	0497e163          	bltu	a5,s1,800028c8 <argraw+0x54>
    8000288a:	048a                	slli	s1,s1,0x2
    8000288c:	00005717          	auipc	a4,0x5
    80002890:	f9c70713          	addi	a4,a4,-100 # 80007828 <states.0+0x30>
    80002894:	94ba                	add	s1,s1,a4
    80002896:	409c                	lw	a5,0(s1)
    80002898:	97ba                	add	a5,a5,a4
    8000289a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000289c:	6d3c                	ld	a5,88(a0)
    8000289e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800028a0:	60e2                	ld	ra,24(sp)
    800028a2:	6442                	ld	s0,16(sp)
    800028a4:	64a2                	ld	s1,8(sp)
    800028a6:	6105                	addi	sp,sp,32
    800028a8:	8082                	ret
    return p->trapframe->a1;
    800028aa:	6d3c                	ld	a5,88(a0)
    800028ac:	7fa8                	ld	a0,120(a5)
    800028ae:	bfcd                	j	800028a0 <argraw+0x2c>
    return p->trapframe->a2;
    800028b0:	6d3c                	ld	a5,88(a0)
    800028b2:	63c8                	ld	a0,128(a5)
    800028b4:	b7f5                	j	800028a0 <argraw+0x2c>
    return p->trapframe->a3;
    800028b6:	6d3c                	ld	a5,88(a0)
    800028b8:	67c8                	ld	a0,136(a5)
    800028ba:	b7dd                	j	800028a0 <argraw+0x2c>
    return p->trapframe->a4;
    800028bc:	6d3c                	ld	a5,88(a0)
    800028be:	6bc8                	ld	a0,144(a5)
    800028c0:	b7c5                	j	800028a0 <argraw+0x2c>
    return p->trapframe->a5;
    800028c2:	6d3c                	ld	a5,88(a0)
    800028c4:	6fc8                	ld	a0,152(a5)
    800028c6:	bfe9                	j	800028a0 <argraw+0x2c>
  panic("argraw");
    800028c8:	00005517          	auipc	a0,0x5
    800028cc:	b7050513          	addi	a0,a0,-1168 # 80007438 <etext+0x438>
    800028d0:	f65fd0ef          	jal	80000834 <panic>

00000000800028d4 <fetchaddr>:
{
    800028d4:	1101                	addi	sp,sp,-32
    800028d6:	ec06                	sd	ra,24(sp)
    800028d8:	e822                	sd	s0,16(sp)
    800028da:	e426                	sd	s1,8(sp)
    800028dc:	e04a                	sd	s2,0(sp)
    800028de:	1000                	addi	s0,sp,32
    800028e0:	84aa                	mv	s1,a0
    800028e2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800028e4:	934ff0ef          	jal	80001a18 <myproc>
  if (addr >= p->sz ||
    800028e8:	652c                	ld	a1,72(a0)
    800028ea:	02b4f663          	bgeu	s1,a1,80002916 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800028ee:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    800028f2:	02f5e463          	bltu	a1,a5,8000291a <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    800028f6:	4721                	li	a4,8
    800028f8:	86a6                	mv	a3,s1
    800028fa:	864a                	mv	a2,s2
    800028fc:	6928                	ld	a0,80(a0)
    800028fe:	d4bfe0ef          	jal	80001648 <copyin>
    80002902:	00a03533          	snez	a0,a0
    80002906:	40a0053b          	negw	a0,a0
}
    8000290a:	60e2                	ld	ra,24(sp)
    8000290c:	6442                	ld	s0,16(sp)
    8000290e:	64a2                	ld	s1,8(sp)
    80002910:	6902                	ld	s2,0(sp)
    80002912:	6105                	addi	sp,sp,32
    80002914:	8082                	ret
    return -1;
    80002916:	557d                	li	a0,-1
    80002918:	bfcd                	j	8000290a <fetchaddr+0x36>
    8000291a:	557d                	li	a0,-1
    8000291c:	b7fd                	j	8000290a <fetchaddr+0x36>

000000008000291e <fetchstr>:
{
    8000291e:	7179                	addi	sp,sp,-48
    80002920:	f406                	sd	ra,40(sp)
    80002922:	f022                	sd	s0,32(sp)
    80002924:	ec26                	sd	s1,24(sp)
    80002926:	e84a                	sd	s2,16(sp)
    80002928:	e44e                	sd	s3,8(sp)
    8000292a:	1800                	addi	s0,sp,48
    8000292c:	89aa                	mv	s3,a0
    8000292e:	84ae                	mv	s1,a1
    80002930:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002932:	8e6ff0ef          	jal	80001a18 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002936:	874a                	mv	a4,s2
    80002938:	86ce                	mv	a3,s3
    8000293a:	8626                	mv	a2,s1
    8000293c:	652c                	ld	a1,72(a0)
    8000293e:	6928                	ld	a0,80(a0)
    80002940:	da5fe0ef          	jal	800016e4 <copyinstr>
    80002944:	00054c63          	bltz	a0,8000295c <fetchstr+0x3e>
  return strlen(buf);
    80002948:	8526                	mv	a0,s1
    8000294a:	d28fe0ef          	jal	80000e72 <strlen>
}
    8000294e:	70a2                	ld	ra,40(sp)
    80002950:	7402                	ld	s0,32(sp)
    80002952:	64e2                	ld	s1,24(sp)
    80002954:	6942                	ld	s2,16(sp)
    80002956:	69a2                	ld	s3,8(sp)
    80002958:	6145                	addi	sp,sp,48
    8000295a:	8082                	ret
    return -1;
    8000295c:	557d                	li	a0,-1
    8000295e:	bfc5                	j	8000294e <fetchstr+0x30>

0000000080002960 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002960:	1101                	addi	sp,sp,-32
    80002962:	ec06                	sd	ra,24(sp)
    80002964:	e822                	sd	s0,16(sp)
    80002966:	e426                	sd	s1,8(sp)
    80002968:	1000                	addi	s0,sp,32
    8000296a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000296c:	f09ff0ef          	jal	80002874 <argraw>
    80002970:	c088                	sw	a0,0(s1)
}
    80002972:	60e2                	ld	ra,24(sp)
    80002974:	6442                	ld	s0,16(sp)
    80002976:	64a2                	ld	s1,8(sp)
    80002978:	6105                	addi	sp,sp,32
    8000297a:	8082                	ret

000000008000297c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000297c:	1101                	addi	sp,sp,-32
    8000297e:	ec06                	sd	ra,24(sp)
    80002980:	e822                	sd	s0,16(sp)
    80002982:	e426                	sd	s1,8(sp)
    80002984:	1000                	addi	s0,sp,32
    80002986:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002988:	eedff0ef          	jal	80002874 <argraw>
    8000298c:	e088                	sd	a0,0(s1)
}
    8000298e:	60e2                	ld	ra,24(sp)
    80002990:	6442                	ld	s0,16(sp)
    80002992:	64a2                	ld	s1,8(sp)
    80002994:	6105                	addi	sp,sp,32
    80002996:	8082                	ret

0000000080002998 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002998:	1101                	addi	sp,sp,-32
    8000299a:	ec06                	sd	ra,24(sp)
    8000299c:	e822                	sd	s0,16(sp)
    8000299e:	e426                	sd	s1,8(sp)
    800029a0:	e04a                	sd	s2,0(sp)
    800029a2:	1000                	addi	s0,sp,32
    800029a4:	892e                	mv	s2,a1
    800029a6:	84b2                	mv	s1,a2
  *ip = argraw(n);
    800029a8:	ecdff0ef          	jal	80002874 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800029ac:	8626                	mv	a2,s1
    800029ae:	85ca                	mv	a1,s2
    800029b0:	f6fff0ef          	jal	8000291e <fetchstr>
}
    800029b4:	60e2                	ld	ra,24(sp)
    800029b6:	6442                	ld	s0,16(sp)
    800029b8:	64a2                	ld	s1,8(sp)
    800029ba:	6902                	ld	s2,0(sp)
    800029bc:	6105                	addi	sp,sp,32
    800029be:	8082                	ret

00000000800029c0 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    800029c0:	1101                	addi	sp,sp,-32
    800029c2:	ec06                	sd	ra,24(sp)
    800029c4:	e822                	sd	s0,16(sp)
    800029c6:	e426                	sd	s1,8(sp)
    800029c8:	e04a                	sd	s2,0(sp)
    800029ca:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800029cc:	84cff0ef          	jal	80001a18 <myproc>
    800029d0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800029d2:	05853903          	ld	s2,88(a0)
    800029d6:	0a893783          	ld	a5,168(s2)
    800029da:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800029de:	37fd                	addiw	a5,a5,-1
    800029e0:	475d                	li	a4,23
    800029e2:	00f76f63          	bltu	a4,a5,80002a00 <syscall+0x40>
    800029e6:	00369713          	slli	a4,a3,0x3
    800029ea:	00005797          	auipc	a5,0x5
    800029ee:	e5678793          	addi	a5,a5,-426 # 80007840 <syscalls>
    800029f2:	97ba                	add	a5,a5,a4
    800029f4:	639c                	ld	a5,0(a5)
    800029f6:	c789                	beqz	a5,80002a00 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800029f8:	9782                	jalr	a5
    800029fa:	06a93823          	sd	a0,112(s2)
    800029fe:	a829                	j	80002a18 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002a00:	15848613          	addi	a2,s1,344
    80002a04:	588c                	lw	a1,48(s1)
    80002a06:	00005517          	auipc	a0,0x5
    80002a0a:	a3a50513          	addi	a0,a0,-1478 # 80007440 <etext+0x440>
    80002a0e:	afdfd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002a12:	6cbc                	ld	a5,88(s1)
    80002a14:	577d                	li	a4,-1
    80002a16:	fbb8                	sd	a4,112(a5)
  }
}
    80002a18:	60e2                	ld	ra,24(sp)
    80002a1a:	6442                	ld	s0,16(sp)
    80002a1c:	64a2                	ld	s1,8(sp)
    80002a1e:	6902                	ld	s2,0(sp)
    80002a20:	6105                	addi	sp,sp,32
    80002a22:	8082                	ret

0000000080002a24 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002a24:	1101                	addi	sp,sp,-32
    80002a26:	ec06                	sd	ra,24(sp)
    80002a28:	e822                	sd	s0,16(sp)
    80002a2a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002a2c:	fec40593          	addi	a1,s0,-20
    80002a30:	4501                	li	a0,0
    80002a32:	f2fff0ef          	jal	80002960 <argint>
  kexit(n);
    80002a36:	fec42503          	lw	a0,-20(s0)
    80002a3a:	f10ff0ef          	jal	8000214a <kexit>
  return 0; // not reached
}
    80002a3e:	4501                	li	a0,0
    80002a40:	60e2                	ld	ra,24(sp)
    80002a42:	6442                	ld	s0,16(sp)
    80002a44:	6105                	addi	sp,sp,32
    80002a46:	8082                	ret

0000000080002a48 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a48:	1141                	addi	sp,sp,-16
    80002a4a:	e406                	sd	ra,8(sp)
    80002a4c:	e022                	sd	s0,0(sp)
    80002a4e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a50:	fc9fe0ef          	jal	80001a18 <myproc>
}
    80002a54:	5908                	lw	a0,48(a0)
    80002a56:	60a2                	ld	ra,8(sp)
    80002a58:	6402                	ld	s0,0(sp)
    80002a5a:	0141                	addi	sp,sp,16
    80002a5c:	8082                	ret

0000000080002a5e <sys_fork>:

uint64
sys_fork(void)
{
    80002a5e:	1141                	addi	sp,sp,-16
    80002a60:	e406                	sd	ra,8(sp)
    80002a62:	e022                	sd	s0,0(sp)
    80002a64:	0800                	addi	s0,sp,16
  return kfork();
    80002a66:	b12ff0ef          	jal	80001d78 <kfork>
}
    80002a6a:	60a2                	ld	ra,8(sp)
    80002a6c:	6402                	ld	s0,0(sp)
    80002a6e:	0141                	addi	sp,sp,16
    80002a70:	8082                	ret

0000000080002a72 <sys_wait>:

uint64
sys_wait(void)
{
    80002a72:	1101                	addi	sp,sp,-32
    80002a74:	ec06                	sd	ra,24(sp)
    80002a76:	e822                	sd	s0,16(sp)
    80002a78:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a7a:	fe840593          	addi	a1,s0,-24
    80002a7e:	4501                	li	a0,0
    80002a80:	efdff0ef          	jal	8000297c <argaddr>
  return kwait(p);
    80002a84:	fe843503          	ld	a0,-24(s0)
    80002a88:	823ff0ef          	jal	800022aa <kwait>
}
    80002a8c:	60e2                	ld	ra,24(sp)
    80002a8e:	6442                	ld	s0,16(sp)
    80002a90:	6105                	addi	sp,sp,32
    80002a92:	8082                	ret

0000000080002a94 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a94:	7179                	addi	sp,sp,-48
    80002a96:	f406                	sd	ra,40(sp)
    80002a98:	f022                	sd	s0,32(sp)
    80002a9a:	ec26                	sd	s1,24(sp)
    80002a9c:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a9e:	fd840593          	addi	a1,s0,-40
    80002aa2:	4501                	li	a0,0
    80002aa4:	ebdff0ef          	jal	80002960 <argint>
  argint(1, &t);
    80002aa8:	fdc40593          	addi	a1,s0,-36
    80002aac:	4505                	li	a0,1
    80002aae:	eb3ff0ef          	jal	80002960 <argint>
  addr = myproc()->sz;
    80002ab2:	f67fe0ef          	jal	80001a18 <myproc>
    80002ab6:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002ab8:	fdc42703          	lw	a4,-36(s0)
    80002abc:	4785                	li	a5,1
    80002abe:	02f70763          	beq	a4,a5,80002aec <sys_sbrk+0x58>
    80002ac2:	fd842783          	lw	a5,-40(s0)
    80002ac6:	0207c363          	bltz	a5,80002aec <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002aca:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002acc:	02000737          	lui	a4,0x2000
    80002ad0:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002ad2:	0736                	slli	a4,a4,0xd
    80002ad4:	02f76a63          	bltu	a4,a5,80002b08 <sys_sbrk+0x74>
    80002ad8:	0297e863          	bltu	a5,s1,80002b08 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002adc:	f3dfe0ef          	jal	80001a18 <myproc>
    80002ae0:	fd842703          	lw	a4,-40(s0)
    80002ae4:	653c                	ld	a5,72(a0)
    80002ae6:	97ba                	add	a5,a5,a4
    80002ae8:	e53c                	sd	a5,72(a0)
    80002aea:	a039                	j	80002af8 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002aec:	fd842503          	lw	a0,-40(s0)
    80002af0:	a26ff0ef          	jal	80001d16 <growproc>
    80002af4:	00054863          	bltz	a0,80002b04 <sys_sbrk+0x70>
  }
  return addr;
}
    80002af8:	8526                	mv	a0,s1
    80002afa:	70a2                	ld	ra,40(sp)
    80002afc:	7402                	ld	s0,32(sp)
    80002afe:	64e2                	ld	s1,24(sp)
    80002b00:	6145                	addi	sp,sp,48
    80002b02:	8082                	ret
      return -1;
    80002b04:	54fd                	li	s1,-1
    80002b06:	bfcd                	j	80002af8 <sys_sbrk+0x64>
      return -1;
    80002b08:	54fd                	li	s1,-1
    80002b0a:	b7fd                	j	80002af8 <sys_sbrk+0x64>

0000000080002b0c <sys_pause>:

uint64
sys_pause(void)
{
    80002b0c:	7139                	addi	sp,sp,-64
    80002b0e:	fc06                	sd	ra,56(sp)
    80002b10:	f822                	sd	s0,48(sp)
    80002b12:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002b14:	fcc40593          	addi	a1,s0,-52
    80002b18:	4501                	li	a0,0
    80002b1a:	e47ff0ef          	jal	80002960 <argint>
  if (n < 0)
    80002b1e:	fcc42783          	lw	a5,-52(s0)
    80002b22:	0807c063          	bltz	a5,80002ba2 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002b26:	00016517          	auipc	a0,0x16
    80002b2a:	87250513          	addi	a0,a0,-1934 # 80018398 <tickslock>
    80002b2e:	8fafe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002b32:	fcc42783          	lw	a5,-52(s0)
    80002b36:	cbb9                	beqz	a5,80002b8c <sys_pause+0x80>
    80002b38:	f426                	sd	s1,40(sp)
    80002b3a:	f04a                	sd	s2,32(sp)
    80002b3c:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002b3e:	00008997          	auipc	s3,0x8
    80002b42:	92a9a983          	lw	s3,-1750(s3) # 8000a468 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002b46:	00008917          	auipc	s2,0x8
    80002b4a:	92290913          	addi	s2,s2,-1758 # 8000a468 <ticks>
    release(&tickslock);
    80002b4e:	00016497          	auipc	s1,0x16
    80002b52:	84a48493          	addi	s1,s1,-1974 # 80018398 <tickslock>
    if (killed(myproc())) {
    80002b56:	ec3fe0ef          	jal	80001a18 <myproc>
    80002b5a:	f26ff0ef          	jal	80002280 <killed>
    80002b5e:	e529                	bnez	a0,80002ba8 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002b60:	854a                	mv	a0,s2
    80002b62:	cc0ff0ef          	jal	80002022 <sleep_prepare>
    release(&tickslock);
    80002b66:	8526                	mv	a0,s1
    80002b68:	948fe0ef          	jal	80000cb0 <release>
    sleep();
    80002b6c:	cf2ff0ef          	jal	8000205e <sleep>
    acquire(&tickslock);
    80002b70:	8526                	mv	a0,s1
    80002b72:	8b6fe0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002b76:	00092783          	lw	a5,0(s2)
    80002b7a:	413787bb          	subw	a5,a5,s3
    80002b7e:	fcc42703          	lw	a4,-52(s0)
    80002b82:	fce7eae3          	bltu	a5,a4,80002b56 <sys_pause+0x4a>
    80002b86:	74a2                	ld	s1,40(sp)
    80002b88:	7902                	ld	s2,32(sp)
    80002b8a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b8c:	00016517          	auipc	a0,0x16
    80002b90:	80c50513          	addi	a0,a0,-2036 # 80018398 <tickslock>
    80002b94:	91cfe0ef          	jal	80000cb0 <release>
  return 0;
    80002b98:	4501                	li	a0,0
}
    80002b9a:	70e2                	ld	ra,56(sp)
    80002b9c:	7442                	ld	s0,48(sp)
    80002b9e:	6121                	addi	sp,sp,64
    80002ba0:	8082                	ret
    n = 0;
    80002ba2:	fc042623          	sw	zero,-52(s0)
    80002ba6:	b741                	j	80002b26 <sys_pause+0x1a>
      release(&tickslock);
    80002ba8:	00015517          	auipc	a0,0x15
    80002bac:	7f050513          	addi	a0,a0,2032 # 80018398 <tickslock>
    80002bb0:	900fe0ef          	jal	80000cb0 <release>
      return -1;
    80002bb4:	557d                	li	a0,-1
    80002bb6:	74a2                	ld	s1,40(sp)
    80002bb8:	7902                	ld	s2,32(sp)
    80002bba:	69e2                	ld	s3,24(sp)
    80002bbc:	bff9                	j	80002b9a <sys_pause+0x8e>

0000000080002bbe <sys_kill>:

uint64
sys_kill(void)
{
    80002bbe:	1101                	addi	sp,sp,-32
    80002bc0:	ec06                	sd	ra,24(sp)
    80002bc2:	e822                	sd	s0,16(sp)
    80002bc4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002bc6:	fec40593          	addi	a1,s0,-20
    80002bca:	4501                	li	a0,0
    80002bcc:	d95ff0ef          	jal	80002960 <argint>
  return kkill(pid);
    80002bd0:	fec42503          	lw	a0,-20(s0)
    80002bd4:	e1cff0ef          	jal	800021f0 <kkill>
}
    80002bd8:	60e2                	ld	ra,24(sp)
    80002bda:	6442                	ld	s0,16(sp)
    80002bdc:	6105                	addi	sp,sp,32
    80002bde:	8082                	ret

0000000080002be0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002be0:	1101                	addi	sp,sp,-32
    80002be2:	ec06                	sd	ra,24(sp)
    80002be4:	e822                	sd	s0,16(sp)
    80002be6:	e426                	sd	s1,8(sp)
    80002be8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002bea:	00015517          	auipc	a0,0x15
    80002bee:	7ae50513          	addi	a0,a0,1966 # 80018398 <tickslock>
    80002bf2:	836fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002bf6:	00008797          	auipc	a5,0x8
    80002bfa:	8727a783          	lw	a5,-1934(a5) # 8000a468 <ticks>
    80002bfe:	84be                	mv	s1,a5
  release(&tickslock);
    80002c00:	00015517          	auipc	a0,0x15
    80002c04:	79850513          	addi	a0,a0,1944 # 80018398 <tickslock>
    80002c08:	8a8fe0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002c0c:	02049513          	slli	a0,s1,0x20
    80002c10:	9101                	srli	a0,a0,0x20
    80002c12:	60e2                	ld	ra,24(sp)
    80002c14:	6442                	ld	s0,16(sp)
    80002c16:	64a2                	ld	s1,8(sp)
    80002c18:	6105                	addi	sp,sp,32
    80002c1a:	8082                	ret

0000000080002c1c <sys_pageinfo>:

uint64
sys_pageinfo(void)
{
    80002c1c:	1101                	addi	sp,sp,-32
    80002c1e:	ec06                	sd	ra,24(sp)
    80002c20:	e822                	sd	s0,16(sp)
    80002c22:	1000                	addi	s0,sp,32
  uint64 va;
  argaddr(0, &va);
    80002c24:	fe840593          	addi	a1,s0,-24
    80002c28:	4501                	li	a0,0
    80002c2a:	d53ff0ef          	jal	8000297c <argaddr>
  return pageinfo(va);
    80002c2e:	fe843503          	ld	a0,-24(s0)
    80002c32:	b89fe0ef          	jal	800017ba <pageinfo>
}
    80002c36:	60e2                	ld	ra,24(sp)
    80002c38:	6442                	ld	s0,16(sp)
    80002c3a:	6105                	addi	sp,sp,32
    80002c3c:	8082                	ret

0000000080002c3e <sys_setreadonly>:

uint64
sys_setreadonly(void)
{
    80002c3e:	1101                	addi	sp,sp,-32
    80002c40:	ec06                	sd	ra,24(sp)
    80002c42:	e822                	sd	s0,16(sp)
    80002c44:	1000                	addi	s0,sp,32
  uint64 va;
  argaddr(0, &va);
    80002c46:	fe840593          	addi	a1,s0,-24
    80002c4a:	4501                	li	a0,0
    80002c4c:	d31ff0ef          	jal	8000297c <argaddr>
  return setreadonly(va);
    80002c50:	fe843503          	ld	a0,-24(s0)
    80002c54:	bebfe0ef          	jal	8000183e <setreadonly>
}
    80002c58:	60e2                	ld	ra,24(sp)
    80002c5a:	6442                	ld	s0,16(sp)
    80002c5c:	6105                	addi	sp,sp,32
    80002c5e:	8082                	ret

0000000080002c60 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c60:	7179                	addi	sp,sp,-48
    80002c62:	f406                	sd	ra,40(sp)
    80002c64:	f022                	sd	s0,32(sp)
    80002c66:	ec26                	sd	s1,24(sp)
    80002c68:	e84a                	sd	s2,16(sp)
    80002c6a:	e44e                	sd	s3,8(sp)
    80002c6c:	e052                	sd	s4,0(sp)
    80002c6e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c70:	00004597          	auipc	a1,0x4
    80002c74:	7f058593          	addi	a1,a1,2032 # 80007460 <etext+0x460>
    80002c78:	00015517          	auipc	a0,0x15
    80002c7c:	73850513          	addi	a0,a0,1848 # 800183b0 <bcache>
    80002c80:	f29fd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c84:	0001d797          	auipc	a5,0x1d
    80002c88:	72c78793          	addi	a5,a5,1836 # 800203b0 <bcache+0x8000>
    80002c8c:	0001e717          	auipc	a4,0x1e
    80002c90:	98c70713          	addi	a4,a4,-1652 # 80020618 <bcache+0x8268>
    80002c94:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002c98:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002c9c:	00015497          	auipc	s1,0x15
    80002ca0:	72c48493          	addi	s1,s1,1836 # 800183c8 <bcache+0x18>
    b->next = bcache.head.next;
    80002ca4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ca6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ca8:	00004a17          	auipc	s4,0x4
    80002cac:	7c0a0a13          	addi	s4,s4,1984 # 80007468 <etext+0x468>
    b->next = bcache.head.next;
    80002cb0:	2b893783          	ld	a5,696(s2)
    80002cb4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002cb6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002cba:	85d2                	mv	a1,s4
    80002cbc:	01048513          	addi	a0,s1,16
    80002cc0:	41c010ef          	jal	800040dc <initsleeplock>
    bcache.head.next->prev = b;
    80002cc4:	2b893783          	ld	a5,696(s2)
    80002cc8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002cca:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002cce:	45848493          	addi	s1,s1,1112
    80002cd2:	fd349fe3          	bne	s1,s3,80002cb0 <binit+0x50>
  }
}
    80002cd6:	70a2                	ld	ra,40(sp)
    80002cd8:	7402                	ld	s0,32(sp)
    80002cda:	64e2                	ld	s1,24(sp)
    80002cdc:	6942                	ld	s2,16(sp)
    80002cde:	69a2                	ld	s3,8(sp)
    80002ce0:	6a02                	ld	s4,0(sp)
    80002ce2:	6145                	addi	sp,sp,48
    80002ce4:	8082                	ret

0000000080002ce6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002ce6:	7179                	addi	sp,sp,-48
    80002ce8:	f406                	sd	ra,40(sp)
    80002cea:	f022                	sd	s0,32(sp)
    80002cec:	ec26                	sd	s1,24(sp)
    80002cee:	e84a                	sd	s2,16(sp)
    80002cf0:	e44e                	sd	s3,8(sp)
    80002cf2:	1800                	addi	s0,sp,48
    80002cf4:	892a                	mv	s2,a0
    80002cf6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002cf8:	00015517          	auipc	a0,0x15
    80002cfc:	6b850513          	addi	a0,a0,1720 # 800183b0 <bcache>
    80002d00:	f29fd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002d04:	0001e497          	auipc	s1,0x1e
    80002d08:	9644b483          	ld	s1,-1692(s1) # 80020668 <bcache+0x82b8>
    80002d0c:	0001e797          	auipc	a5,0x1e
    80002d10:	90c78793          	addi	a5,a5,-1780 # 80020618 <bcache+0x8268>
    80002d14:	02f48b63          	beq	s1,a5,80002d4a <bread+0x64>
    80002d18:	873e                	mv	a4,a5
    80002d1a:	a021                	j	80002d22 <bread+0x3c>
    80002d1c:	68a4                	ld	s1,80(s1)
    80002d1e:	02e48663          	beq	s1,a4,80002d4a <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002d22:	449c                	lw	a5,8(s1)
    80002d24:	ff279ce3          	bne	a5,s2,80002d1c <bread+0x36>
    80002d28:	44dc                	lw	a5,12(s1)
    80002d2a:	ff3799e3          	bne	a5,s3,80002d1c <bread+0x36>
      b->refcnt++;
    80002d2e:	40bc                	lw	a5,64(s1)
    80002d30:	2785                	addiw	a5,a5,1
    80002d32:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d34:	00015517          	auipc	a0,0x15
    80002d38:	67c50513          	addi	a0,a0,1660 # 800183b0 <bcache>
    80002d3c:	f75fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002d40:	01048513          	addi	a0,s1,16
    80002d44:	3ce010ef          	jal	80004112 <acquiresleep>
      return b;
    80002d48:	a889                	j	80002d9a <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002d4a:	0001e497          	auipc	s1,0x1e
    80002d4e:	9164b483          	ld	s1,-1770(s1) # 80020660 <bcache+0x82b0>
    80002d52:	0001e797          	auipc	a5,0x1e
    80002d56:	8c678793          	addi	a5,a5,-1850 # 80020618 <bcache+0x8268>
    80002d5a:	00f48863          	beq	s1,a5,80002d6a <bread+0x84>
    80002d5e:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002d60:	40bc                	lw	a5,64(s1)
    80002d62:	cb91                	beqz	a5,80002d76 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002d64:	64a4                	ld	s1,72(s1)
    80002d66:	fee49de3          	bne	s1,a4,80002d60 <bread+0x7a>
  panic("bget: no buffers");
    80002d6a:	00004517          	auipc	a0,0x4
    80002d6e:	70650513          	addi	a0,a0,1798 # 80007470 <etext+0x470>
    80002d72:	ac3fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002d76:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d7a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d7e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d82:	4785                	li	a5,1
    80002d84:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d86:	00015517          	auipc	a0,0x15
    80002d8a:	62a50513          	addi	a0,a0,1578 # 800183b0 <bcache>
    80002d8e:	f23fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002d92:	01048513          	addi	a0,s1,16
    80002d96:	37c010ef          	jal	80004112 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002d9a:	409c                	lw	a5,0(s1)
    80002d9c:	cb89                	beqz	a5,80002dae <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d9e:	8526                	mv	a0,s1
    80002da0:	70a2                	ld	ra,40(sp)
    80002da2:	7402                	ld	s0,32(sp)
    80002da4:	64e2                	ld	s1,24(sp)
    80002da6:	6942                	ld	s2,16(sp)
    80002da8:	69a2                	ld	s3,8(sp)
    80002daa:	6145                	addi	sp,sp,48
    80002dac:	8082                	ret
    virtio_disk_rw(b, 0);
    80002dae:	4581                	li	a1,0
    80002db0:	8526                	mv	a0,s1
    80002db2:	4c5020ef          	jal	80005a76 <virtio_disk_rw>
    b->valid = 1;
    80002db6:	4785                	li	a5,1
    80002db8:	c09c                	sw	a5,0(s1)
  return b;
    80002dba:	b7d5                	j	80002d9e <bread+0xb8>

0000000080002dbc <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002dbc:	1101                	addi	sp,sp,-32
    80002dbe:	ec06                	sd	ra,24(sp)
    80002dc0:	e822                	sd	s0,16(sp)
    80002dc2:	e426                	sd	s1,8(sp)
    80002dc4:	1000                	addi	s0,sp,32
    80002dc6:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002dc8:	0541                	addi	a0,a0,16
    80002dca:	3d4010ef          	jal	8000419e <holdingsleep>
    80002dce:	c911                	beqz	a0,80002de2 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002dd0:	4585                	li	a1,1
    80002dd2:	8526                	mv	a0,s1
    80002dd4:	4a3020ef          	jal	80005a76 <virtio_disk_rw>
}
    80002dd8:	60e2                	ld	ra,24(sp)
    80002dda:	6442                	ld	s0,16(sp)
    80002ddc:	64a2                	ld	s1,8(sp)
    80002dde:	6105                	addi	sp,sp,32
    80002de0:	8082                	ret
    panic("bwrite");
    80002de2:	00004517          	auipc	a0,0x4
    80002de6:	6a650513          	addi	a0,a0,1702 # 80007488 <etext+0x488>
    80002dea:	a4bfd0ef          	jal	80000834 <panic>

0000000080002dee <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002dee:	1101                	addi	sp,sp,-32
    80002df0:	ec06                	sd	ra,24(sp)
    80002df2:	e822                	sd	s0,16(sp)
    80002df4:	e426                	sd	s1,8(sp)
    80002df6:	e04a                	sd	s2,0(sp)
    80002df8:	1000                	addi	s0,sp,32
    80002dfa:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002dfc:	01050913          	addi	s2,a0,16
    80002e00:	854a                	mv	a0,s2
    80002e02:	39c010ef          	jal	8000419e <holdingsleep>
    80002e06:	c125                	beqz	a0,80002e66 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002e08:	854a                	mv	a0,s2
    80002e0a:	35c010ef          	jal	80004166 <releasesleep>

  acquire(&bcache.lock);
    80002e0e:	00015517          	auipc	a0,0x15
    80002e12:	5a250513          	addi	a0,a0,1442 # 800183b0 <bcache>
    80002e16:	e13fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002e1a:	40bc                	lw	a5,64(s1)
    80002e1c:	37fd                	addiw	a5,a5,-1
    80002e1e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e20:	e79d                	bnez	a5,80002e4e <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e22:	68b8                	ld	a4,80(s1)
    80002e24:	64bc                	ld	a5,72(s1)
    80002e26:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002e28:	68b8                	ld	a4,80(s1)
    80002e2a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e2c:	0001d797          	auipc	a5,0x1d
    80002e30:	58478793          	addi	a5,a5,1412 # 800203b0 <bcache+0x8000>
    80002e34:	2b87b703          	ld	a4,696(a5)
    80002e38:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e3a:	0001d717          	auipc	a4,0x1d
    80002e3e:	7de70713          	addi	a4,a4,2014 # 80020618 <bcache+0x8268>
    80002e42:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e44:	2b87b703          	ld	a4,696(a5)
    80002e48:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e4a:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002e4e:	00015517          	auipc	a0,0x15
    80002e52:	56250513          	addi	a0,a0,1378 # 800183b0 <bcache>
    80002e56:	e5bfd0ef          	jal	80000cb0 <release>
}
    80002e5a:	60e2                	ld	ra,24(sp)
    80002e5c:	6442                	ld	s0,16(sp)
    80002e5e:	64a2                	ld	s1,8(sp)
    80002e60:	6902                	ld	s2,0(sp)
    80002e62:	6105                	addi	sp,sp,32
    80002e64:	8082                	ret
    panic("brelse");
    80002e66:	00004517          	auipc	a0,0x4
    80002e6a:	62a50513          	addi	a0,a0,1578 # 80007490 <etext+0x490>
    80002e6e:	9c7fd0ef          	jal	80000834 <panic>

0000000080002e72 <bpin>:

void
bpin(struct buf *b)
{
    80002e72:	1101                	addi	sp,sp,-32
    80002e74:	ec06                	sd	ra,24(sp)
    80002e76:	e822                	sd	s0,16(sp)
    80002e78:	e426                	sd	s1,8(sp)
    80002e7a:	1000                	addi	s0,sp,32
    80002e7c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e7e:	00015517          	auipc	a0,0x15
    80002e82:	53250513          	addi	a0,a0,1330 # 800183b0 <bcache>
    80002e86:	da3fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002e8a:	40bc                	lw	a5,64(s1)
    80002e8c:	2785                	addiw	a5,a5,1
    80002e8e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e90:	00015517          	auipc	a0,0x15
    80002e94:	52050513          	addi	a0,a0,1312 # 800183b0 <bcache>
    80002e98:	e19fd0ef          	jal	80000cb0 <release>
}
    80002e9c:	60e2                	ld	ra,24(sp)
    80002e9e:	6442                	ld	s0,16(sp)
    80002ea0:	64a2                	ld	s1,8(sp)
    80002ea2:	6105                	addi	sp,sp,32
    80002ea4:	8082                	ret

0000000080002ea6 <bunpin>:

void
bunpin(struct buf *b)
{
    80002ea6:	1101                	addi	sp,sp,-32
    80002ea8:	ec06                	sd	ra,24(sp)
    80002eaa:	e822                	sd	s0,16(sp)
    80002eac:	e426                	sd	s1,8(sp)
    80002eae:	1000                	addi	s0,sp,32
    80002eb0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002eb2:	00015517          	auipc	a0,0x15
    80002eb6:	4fe50513          	addi	a0,a0,1278 # 800183b0 <bcache>
    80002eba:	d6ffd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002ebe:	40bc                	lw	a5,64(s1)
    80002ec0:	37fd                	addiw	a5,a5,-1
    80002ec2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ec4:	00015517          	auipc	a0,0x15
    80002ec8:	4ec50513          	addi	a0,a0,1260 # 800183b0 <bcache>
    80002ecc:	de5fd0ef          	jal	80000cb0 <release>
}
    80002ed0:	60e2                	ld	ra,24(sp)
    80002ed2:	6442                	ld	s0,16(sp)
    80002ed4:	64a2                	ld	s1,8(sp)
    80002ed6:	6105                	addi	sp,sp,32
    80002ed8:	8082                	ret

0000000080002eda <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002eda:	1101                	addi	sp,sp,-32
    80002edc:	ec06                	sd	ra,24(sp)
    80002ede:	e822                	sd	s0,16(sp)
    80002ee0:	e426                	sd	s1,8(sp)
    80002ee2:	e04a                	sd	s2,0(sp)
    80002ee4:	1000                	addi	s0,sp,32
    80002ee6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ee8:	00d5d79b          	srliw	a5,a1,0xd
    80002eec:	0001e597          	auipc	a1,0x1e
    80002ef0:	ba05a583          	lw	a1,-1120(a1) # 80020a8c <sb+0x1c>
    80002ef4:	9dbd                	addw	a1,a1,a5
    80002ef6:	df1ff0ef          	jal	80002ce6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002efa:	0074f713          	andi	a4,s1,7
    80002efe:	4785                	li	a5,1
    80002f00:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002f04:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002f06:	90d9                	srli	s1,s1,0x36
    80002f08:	00950733          	add	a4,a0,s1
    80002f0c:	05874703          	lbu	a4,88(a4)
    80002f10:	00e7f6b3          	and	a3,a5,a4
    80002f14:	c29d                	beqz	a3,80002f3a <bfree+0x60>
    80002f16:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002f18:	94aa                	add	s1,s1,a0
    80002f1a:	fff7c793          	not	a5,a5
    80002f1e:	8f7d                	and	a4,a4,a5
    80002f20:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002f24:	080010ef          	jal	80003fa4 <log_write>
  brelse(bp);
    80002f28:	854a                	mv	a0,s2
    80002f2a:	ec5ff0ef          	jal	80002dee <brelse>
}
    80002f2e:	60e2                	ld	ra,24(sp)
    80002f30:	6442                	ld	s0,16(sp)
    80002f32:	64a2                	ld	s1,8(sp)
    80002f34:	6902                	ld	s2,0(sp)
    80002f36:	6105                	addi	sp,sp,32
    80002f38:	8082                	ret
    panic("freeing free block");
    80002f3a:	00004517          	auipc	a0,0x4
    80002f3e:	55e50513          	addi	a0,a0,1374 # 80007498 <etext+0x498>
    80002f42:	8f3fd0ef          	jal	80000834 <panic>

0000000080002f46 <balloc>:
{
    80002f46:	715d                	addi	sp,sp,-80
    80002f48:	e486                	sd	ra,72(sp)
    80002f4a:	e0a2                	sd	s0,64(sp)
    80002f4c:	fc26                	sd	s1,56(sp)
    80002f4e:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002f50:	0001e797          	auipc	a5,0x1e
    80002f54:	b247a783          	lw	a5,-1244(a5) # 80020a74 <sb+0x4>
    80002f58:	0e078263          	beqz	a5,8000303c <balloc+0xf6>
    80002f5c:	f84a                	sd	s2,48(sp)
    80002f5e:	f44e                	sd	s3,40(sp)
    80002f60:	f052                	sd	s4,32(sp)
    80002f62:	ec56                	sd	s5,24(sp)
    80002f64:	e85a                	sd	s6,16(sp)
    80002f66:	e45e                	sd	s7,8(sp)
    80002f68:	e062                	sd	s8,0(sp)
    80002f6a:	8baa                	mv	s7,a0
    80002f6c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f6e:	0001eb17          	auipc	s6,0x1e
    80002f72:	b02b0b13          	addi	s6,s6,-1278 # 80020a70 <sb>
      m = 1 << (bi % 8);
    80002f76:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f78:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002f7a:	6c09                	lui	s8,0x2
    80002f7c:	a09d                	j	80002fe2 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002f7e:	97ca                	add	a5,a5,s2
    80002f80:	8e55                	or	a2,a2,a3
    80002f82:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f86:	854a                	mv	a0,s2
    80002f88:	01c010ef          	jal	80003fa4 <log_write>
        brelse(bp);
    80002f8c:	854a                	mv	a0,s2
    80002f8e:	e61ff0ef          	jal	80002dee <brelse>
  bp = bread(dev, bno);
    80002f92:	85a6                	mv	a1,s1
    80002f94:	855e                	mv	a0,s7
    80002f96:	d51ff0ef          	jal	80002ce6 <bread>
    80002f9a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f9c:	40000613          	li	a2,1024
    80002fa0:	4581                	li	a1,0
    80002fa2:	05850513          	addi	a0,a0,88
    80002fa6:	d43fd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    80002faa:	854a                	mv	a0,s2
    80002fac:	7f9000ef          	jal	80003fa4 <log_write>
  brelse(bp);
    80002fb0:	854a                	mv	a0,s2
    80002fb2:	e3dff0ef          	jal	80002dee <brelse>
}
    80002fb6:	7942                	ld	s2,48(sp)
    80002fb8:	79a2                	ld	s3,40(sp)
    80002fba:	7a02                	ld	s4,32(sp)
    80002fbc:	6ae2                	ld	s5,24(sp)
    80002fbe:	6b42                	ld	s6,16(sp)
    80002fc0:	6ba2                	ld	s7,8(sp)
    80002fc2:	6c02                	ld	s8,0(sp)
}
    80002fc4:	8526                	mv	a0,s1
    80002fc6:	60a6                	ld	ra,72(sp)
    80002fc8:	6406                	ld	s0,64(sp)
    80002fca:	74e2                	ld	s1,56(sp)
    80002fcc:	6161                	addi	sp,sp,80
    80002fce:	8082                	ret
    brelse(bp);
    80002fd0:	854a                	mv	a0,s2
    80002fd2:	e1dff0ef          	jal	80002dee <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002fd6:	015c0abb          	addw	s5,s8,s5
    80002fda:	004b2783          	lw	a5,4(s6)
    80002fde:	04faf863          	bgeu	s5,a5,8000302e <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002fe2:	40dad59b          	sraiw	a1,s5,0xd
    80002fe6:	01cb2783          	lw	a5,28(s6)
    80002fea:	9dbd                	addw	a1,a1,a5
    80002fec:	855e                	mv	a0,s7
    80002fee:	cf9ff0ef          	jal	80002ce6 <bread>
    80002ff2:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002ff4:	004b2503          	lw	a0,4(s6)
    80002ff8:	84d6                	mv	s1,s5
    80002ffa:	4701                	li	a4,0
    80002ffc:	fca4fae3          	bgeu	s1,a0,80002fd0 <balloc+0x8a>
      m = 1 << (bi % 8);
    80003000:	00777693          	andi	a3,a4,7
    80003004:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80003008:	41f7579b          	sraiw	a5,a4,0x1f
    8000300c:	01d7d79b          	srliw	a5,a5,0x1d
    80003010:	9fb9                	addw	a5,a5,a4
    80003012:	4037d79b          	sraiw	a5,a5,0x3
    80003016:	00f90633          	add	a2,s2,a5
    8000301a:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000301e:	00c6f5b3          	and	a1,a3,a2
    80003022:	ddb1                	beqz	a1,80002f7e <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003024:	2705                	addiw	a4,a4,1
    80003026:	2485                	addiw	s1,s1,1
    80003028:	fd471ae3          	bne	a4,s4,80002ffc <balloc+0xb6>
    8000302c:	b755                	j	80002fd0 <balloc+0x8a>
    8000302e:	7942                	ld	s2,48(sp)
    80003030:	79a2                	ld	s3,40(sp)
    80003032:	7a02                	ld	s4,32(sp)
    80003034:	6ae2                	ld	s5,24(sp)
    80003036:	6b42                	ld	s6,16(sp)
    80003038:	6ba2                	ld	s7,8(sp)
    8000303a:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    8000303c:	00004517          	auipc	a0,0x4
    80003040:	47450513          	addi	a0,a0,1140 # 800074b0 <etext+0x4b0>
    80003044:	cc6fd0ef          	jal	8000050a <printk>
  return 0;
    80003048:	4481                	li	s1,0
    8000304a:	bfad                	j	80002fc4 <balloc+0x7e>

000000008000304c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000304c:	7179                	addi	sp,sp,-48
    8000304e:	f406                	sd	ra,40(sp)
    80003050:	f022                	sd	s0,32(sp)
    80003052:	ec26                	sd	s1,24(sp)
    80003054:	e84a                	sd	s2,16(sp)
    80003056:	e44e                	sd	s3,8(sp)
    80003058:	1800                	addi	s0,sp,48
    8000305a:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    8000305c:	47ad                	li	a5,11
    8000305e:	02b7e363          	bltu	a5,a1,80003084 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80003062:	02059793          	slli	a5,a1,0x20
    80003066:	01e7d593          	srli	a1,a5,0x1e
    8000306a:	00b509b3          	add	s3,a0,a1
    8000306e:	0509a483          	lw	s1,80(s3)
    80003072:	e0b5                	bnez	s1,800030d6 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003074:	4108                	lw	a0,0(a0)
    80003076:	ed1ff0ef          	jal	80002f46 <balloc>
    8000307a:	84aa                	mv	s1,a0
      if (addr == 0)
    8000307c:	cd29                	beqz	a0,800030d6 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    8000307e:	04a9a823          	sw	a0,80(s3)
    80003082:	a891                	j	800030d6 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003084:	ff45879b          	addiw	a5,a1,-12
    80003088:	873e                	mv	a4,a5
    8000308a:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    8000308c:	0ff00793          	li	a5,255
    80003090:	06e7e763          	bltu	a5,a4,800030fe <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80003094:	08052483          	lw	s1,128(a0)
    80003098:	e891                	bnez	s1,800030ac <bmap+0x60>
      addr = balloc(ip->dev);
    8000309a:	4108                	lw	a0,0(a0)
    8000309c:	eabff0ef          	jal	80002f46 <balloc>
    800030a0:	84aa                	mv	s1,a0
      if (addr == 0)
    800030a2:	c915                	beqz	a0,800030d6 <bmap+0x8a>
    800030a4:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800030a6:	08a92023          	sw	a0,128(s2)
    800030aa:	a011                	j	800030ae <bmap+0x62>
    800030ac:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800030ae:	85a6                	mv	a1,s1
    800030b0:	00092503          	lw	a0,0(s2)
    800030b4:	c33ff0ef          	jal	80002ce6 <bread>
    800030b8:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    800030ba:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    800030be:	02099713          	slli	a4,s3,0x20
    800030c2:	01e75593          	srli	a1,a4,0x1e
    800030c6:	97ae                	add	a5,a5,a1
    800030c8:	89be                	mv	s3,a5
    800030ca:	4384                	lw	s1,0(a5)
    800030cc:	cc89                	beqz	s1,800030e6 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800030ce:	8552                	mv	a0,s4
    800030d0:	d1fff0ef          	jal	80002dee <brelse>
    return addr;
    800030d4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800030d6:	8526                	mv	a0,s1
    800030d8:	70a2                	ld	ra,40(sp)
    800030da:	7402                	ld	s0,32(sp)
    800030dc:	64e2                	ld	s1,24(sp)
    800030de:	6942                	ld	s2,16(sp)
    800030e0:	69a2                	ld	s3,8(sp)
    800030e2:	6145                	addi	sp,sp,48
    800030e4:	8082                	ret
      addr = balloc(ip->dev);
    800030e6:	00092503          	lw	a0,0(s2)
    800030ea:	e5dff0ef          	jal	80002f46 <balloc>
    800030ee:	84aa                	mv	s1,a0
      if (addr) {
    800030f0:	dd79                	beqz	a0,800030ce <bmap+0x82>
        a[bn] = addr;
    800030f2:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800030f6:	8552                	mv	a0,s4
    800030f8:	6ad000ef          	jal	80003fa4 <log_write>
    800030fc:	bfc9                	j	800030ce <bmap+0x82>
    800030fe:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003100:	00004517          	auipc	a0,0x4
    80003104:	3c850513          	addi	a0,a0,968 # 800074c8 <etext+0x4c8>
    80003108:	f2cfd0ef          	jal	80000834 <panic>

000000008000310c <iget>:
{
    8000310c:	7179                	addi	sp,sp,-48
    8000310e:	f406                	sd	ra,40(sp)
    80003110:	f022                	sd	s0,32(sp)
    80003112:	ec26                	sd	s1,24(sp)
    80003114:	e84a                	sd	s2,16(sp)
    80003116:	e44e                	sd	s3,8(sp)
    80003118:	e052                	sd	s4,0(sp)
    8000311a:	1800                	addi	s0,sp,48
    8000311c:	892a                	mv	s2,a0
    8000311e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003120:	0001e517          	auipc	a0,0x1e
    80003124:	97050513          	addi	a0,a0,-1680 # 80020a90 <itable>
    80003128:	b01fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    8000312c:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000312e:	0001e497          	auipc	s1,0x1e
    80003132:	97a48493          	addi	s1,s1,-1670 # 80020aa8 <itable+0x18>
    80003136:	0001f697          	auipc	a3,0x1f
    8000313a:	40268693          	addi	a3,a3,1026 # 80022538 <log>
    8000313e:	a809                	j	80003150 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003140:	e781                	bnez	a5,80003148 <iget+0x3c>
    80003142:	00099363          	bnez	s3,80003148 <iget+0x3c>
      empty = ip;
    80003146:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003148:	08848493          	addi	s1,s1,136
    8000314c:	02d48563          	beq	s1,a3,80003176 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80003150:	449c                	lw	a5,8(s1)
    80003152:	fef057e3          	blez	a5,80003140 <iget+0x34>
    80003156:	4098                	lw	a4,0(s1)
    80003158:	ff2718e3          	bne	a4,s2,80003148 <iget+0x3c>
    8000315c:	40d8                	lw	a4,4(s1)
    8000315e:	ff4715e3          	bne	a4,s4,80003148 <iget+0x3c>
      ip->ref++;
    80003162:	2785                	addiw	a5,a5,1
    80003164:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003166:	0001e517          	auipc	a0,0x1e
    8000316a:	92a50513          	addi	a0,a0,-1750 # 80020a90 <itable>
    8000316e:	b43fd0ef          	jal	80000cb0 <release>
      return ip;
    80003172:	89a6                	mv	s3,s1
    80003174:	a015                	j	80003198 <iget+0x8c>
  if (empty == 0)
    80003176:	02098a63          	beqz	s3,800031aa <iget+0x9e>
  ip->dev = dev;
    8000317a:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000317e:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003182:	4785                	li	a5,1
    80003184:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003188:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000318c:	0001e517          	auipc	a0,0x1e
    80003190:	90450513          	addi	a0,a0,-1788 # 80020a90 <itable>
    80003194:	b1dfd0ef          	jal	80000cb0 <release>
}
    80003198:	854e                	mv	a0,s3
    8000319a:	70a2                	ld	ra,40(sp)
    8000319c:	7402                	ld	s0,32(sp)
    8000319e:	64e2                	ld	s1,24(sp)
    800031a0:	6942                	ld	s2,16(sp)
    800031a2:	69a2                	ld	s3,8(sp)
    800031a4:	6a02                	ld	s4,0(sp)
    800031a6:	6145                	addi	sp,sp,48
    800031a8:	8082                	ret
    panic("iget: no inodes");
    800031aa:	00004517          	auipc	a0,0x4
    800031ae:	33650513          	addi	a0,a0,822 # 800074e0 <etext+0x4e0>
    800031b2:	e82fd0ef          	jal	80000834 <panic>

00000000800031b6 <iinit>:
{
    800031b6:	7179                	addi	sp,sp,-48
    800031b8:	f406                	sd	ra,40(sp)
    800031ba:	f022                	sd	s0,32(sp)
    800031bc:	ec26                	sd	s1,24(sp)
    800031be:	e84a                	sd	s2,16(sp)
    800031c0:	e44e                	sd	s3,8(sp)
    800031c2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800031c4:	00004597          	auipc	a1,0x4
    800031c8:	32c58593          	addi	a1,a1,812 # 800074f0 <etext+0x4f0>
    800031cc:	0001e517          	auipc	a0,0x1e
    800031d0:	8c450513          	addi	a0,a0,-1852 # 80020a90 <itable>
    800031d4:	9d5fd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    800031d8:	0001e497          	auipc	s1,0x1e
    800031dc:	8e048493          	addi	s1,s1,-1824 # 80020ab8 <itable+0x28>
    800031e0:	0001f997          	auipc	s3,0x1f
    800031e4:	36898993          	addi	s3,s3,872 # 80022548 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800031e8:	00004917          	auipc	s2,0x4
    800031ec:	31090913          	addi	s2,s2,784 # 800074f8 <etext+0x4f8>
    800031f0:	85ca                	mv	a1,s2
    800031f2:	8526                	mv	a0,s1
    800031f4:	6e9000ef          	jal	800040dc <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    800031f8:	08848493          	addi	s1,s1,136
    800031fc:	ff349ae3          	bne	s1,s3,800031f0 <iinit+0x3a>
}
    80003200:	70a2                	ld	ra,40(sp)
    80003202:	7402                	ld	s0,32(sp)
    80003204:	64e2                	ld	s1,24(sp)
    80003206:	6942                	ld	s2,16(sp)
    80003208:	69a2                	ld	s3,8(sp)
    8000320a:	6145                	addi	sp,sp,48
    8000320c:	8082                	ret

000000008000320e <ialloc>:
{
    8000320e:	7139                	addi	sp,sp,-64
    80003210:	fc06                	sd	ra,56(sp)
    80003212:	f822                	sd	s0,48(sp)
    80003214:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003216:	0001e717          	auipc	a4,0x1e
    8000321a:	86672703          	lw	a4,-1946(a4) # 80020a7c <sb+0xc>
    8000321e:	4785                	li	a5,1
    80003220:	06e7f063          	bgeu	a5,a4,80003280 <ialloc+0x72>
    80003224:	f426                	sd	s1,40(sp)
    80003226:	f04a                	sd	s2,32(sp)
    80003228:	ec4e                	sd	s3,24(sp)
    8000322a:	e852                	sd	s4,16(sp)
    8000322c:	e456                	sd	s5,8(sp)
    8000322e:	e05a                	sd	s6,0(sp)
    80003230:	8aaa                	mv	s5,a0
    80003232:	8b2e                	mv	s6,a1
    80003234:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003236:	0001ea17          	auipc	s4,0x1e
    8000323a:	83aa0a13          	addi	s4,s4,-1990 # 80020a70 <sb>
    8000323e:	00495593          	srli	a1,s2,0x4
    80003242:	018a2783          	lw	a5,24(s4)
    80003246:	9dbd                	addw	a1,a1,a5
    80003248:	8556                	mv	a0,s5
    8000324a:	a9dff0ef          	jal	80002ce6 <bread>
    8000324e:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003250:	05850993          	addi	s3,a0,88
    80003254:	00f97793          	andi	a5,s2,15
    80003258:	079a                	slli	a5,a5,0x6
    8000325a:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    8000325c:	00099783          	lh	a5,0(s3)
    80003260:	cb9d                	beqz	a5,80003296 <ialloc+0x88>
    brelse(bp);
    80003262:	b8dff0ef          	jal	80002dee <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003266:	0905                	addi	s2,s2,1
    80003268:	00ca2703          	lw	a4,12(s4)
    8000326c:	0009079b          	sext.w	a5,s2
    80003270:	fce7e7e3          	bltu	a5,a4,8000323e <ialloc+0x30>
    80003274:	74a2                	ld	s1,40(sp)
    80003276:	7902                	ld	s2,32(sp)
    80003278:	69e2                	ld	s3,24(sp)
    8000327a:	6a42                	ld	s4,16(sp)
    8000327c:	6aa2                	ld	s5,8(sp)
    8000327e:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    80003280:	00004517          	auipc	a0,0x4
    80003284:	28050513          	addi	a0,a0,640 # 80007500 <etext+0x500>
    80003288:	a82fd0ef          	jal	8000050a <printk>
  return 0;
    8000328c:	4501                	li	a0,0
}
    8000328e:	70e2                	ld	ra,56(sp)
    80003290:	7442                	ld	s0,48(sp)
    80003292:	6121                	addi	sp,sp,64
    80003294:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003296:	04000613          	li	a2,64
    8000329a:	4581                	li	a1,0
    8000329c:	854e                	mv	a0,s3
    8000329e:	a4bfd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    800032a2:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800032a6:	8526                	mv	a0,s1
    800032a8:	4fd000ef          	jal	80003fa4 <log_write>
      brelse(bp);
    800032ac:	8526                	mv	a0,s1
    800032ae:	b41ff0ef          	jal	80002dee <brelse>
      return iget(dev, inum);
    800032b2:	0009059b          	sext.w	a1,s2
    800032b6:	8556                	mv	a0,s5
    800032b8:	e55ff0ef          	jal	8000310c <iget>
    800032bc:	74a2                	ld	s1,40(sp)
    800032be:	7902                	ld	s2,32(sp)
    800032c0:	69e2                	ld	s3,24(sp)
    800032c2:	6a42                	ld	s4,16(sp)
    800032c4:	6aa2                	ld	s5,8(sp)
    800032c6:	6b02                	ld	s6,0(sp)
    800032c8:	b7d9                	j	8000328e <ialloc+0x80>

00000000800032ca <iupdate>:
{
    800032ca:	1101                	addi	sp,sp,-32
    800032cc:	ec06                	sd	ra,24(sp)
    800032ce:	e822                	sd	s0,16(sp)
    800032d0:	e426                	sd	s1,8(sp)
    800032d2:	e04a                	sd	s2,0(sp)
    800032d4:	1000                	addi	s0,sp,32
    800032d6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032d8:	415c                	lw	a5,4(a0)
    800032da:	0047d79b          	srliw	a5,a5,0x4
    800032de:	0001d597          	auipc	a1,0x1d
    800032e2:	7aa5a583          	lw	a1,1962(a1) # 80020a88 <sb+0x18>
    800032e6:	9dbd                	addw	a1,a1,a5
    800032e8:	4108                	lw	a0,0(a0)
    800032ea:	9fdff0ef          	jal	80002ce6 <bread>
    800032ee:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    800032f0:	05850793          	addi	a5,a0,88
    800032f4:	40d8                	lw	a4,4(s1)
    800032f6:	8b3d                	andi	a4,a4,15
    800032f8:	071a                	slli	a4,a4,0x6
    800032fa:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800032fc:	04449703          	lh	a4,68(s1)
    80003300:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003304:	04649703          	lh	a4,70(s1)
    80003308:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000330c:	04849703          	lh	a4,72(s1)
    80003310:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003314:	04a49703          	lh	a4,74(s1)
    80003318:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000331c:	44f8                	lw	a4,76(s1)
    8000331e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003320:	03400613          	li	a2,52
    80003324:	05048593          	addi	a1,s1,80
    80003328:	00c78513          	addi	a0,a5,12
    8000332c:	a1dfd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    80003330:	854a                	mv	a0,s2
    80003332:	473000ef          	jal	80003fa4 <log_write>
  brelse(bp);
    80003336:	854a                	mv	a0,s2
    80003338:	ab7ff0ef          	jal	80002dee <brelse>
}
    8000333c:	60e2                	ld	ra,24(sp)
    8000333e:	6442                	ld	s0,16(sp)
    80003340:	64a2                	ld	s1,8(sp)
    80003342:	6902                	ld	s2,0(sp)
    80003344:	6105                	addi	sp,sp,32
    80003346:	8082                	ret

0000000080003348 <idup>:
{
    80003348:	1101                	addi	sp,sp,-32
    8000334a:	ec06                	sd	ra,24(sp)
    8000334c:	e822                	sd	s0,16(sp)
    8000334e:	e426                	sd	s1,8(sp)
    80003350:	1000                	addi	s0,sp,32
    80003352:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003354:	0001d517          	auipc	a0,0x1d
    80003358:	73c50513          	addi	a0,a0,1852 # 80020a90 <itable>
    8000335c:	8cdfd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003360:	449c                	lw	a5,8(s1)
    80003362:	2785                	addiw	a5,a5,1
    80003364:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003366:	0001d517          	auipc	a0,0x1d
    8000336a:	72a50513          	addi	a0,a0,1834 # 80020a90 <itable>
    8000336e:	943fd0ef          	jal	80000cb0 <release>
}
    80003372:	8526                	mv	a0,s1
    80003374:	60e2                	ld	ra,24(sp)
    80003376:	6442                	ld	s0,16(sp)
    80003378:	64a2                	ld	s1,8(sp)
    8000337a:	6105                	addi	sp,sp,32
    8000337c:	8082                	ret

000000008000337e <ilock>:
{
    8000337e:	1101                	addi	sp,sp,-32
    80003380:	ec06                	sd	ra,24(sp)
    80003382:	e822                	sd	s0,16(sp)
    80003384:	e426                	sd	s1,8(sp)
    80003386:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003388:	cd19                	beqz	a0,800033a6 <ilock+0x28>
    8000338a:	84aa                	mv	s1,a0
    8000338c:	451c                	lw	a5,8(a0)
    8000338e:	00f05c63          	blez	a5,800033a6 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003392:	0541                	addi	a0,a0,16
    80003394:	57f000ef          	jal	80004112 <acquiresleep>
  if (ip->valid == 0) {
    80003398:	40bc                	lw	a5,64(s1)
    8000339a:	cf89                	beqz	a5,800033b4 <ilock+0x36>
}
    8000339c:	60e2                	ld	ra,24(sp)
    8000339e:	6442                	ld	s0,16(sp)
    800033a0:	64a2                	ld	s1,8(sp)
    800033a2:	6105                	addi	sp,sp,32
    800033a4:	8082                	ret
    800033a6:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800033a8:	00004517          	auipc	a0,0x4
    800033ac:	17050513          	addi	a0,a0,368 # 80007518 <etext+0x518>
    800033b0:	c84fd0ef          	jal	80000834 <panic>
    800033b4:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033b6:	40dc                	lw	a5,4(s1)
    800033b8:	0047d79b          	srliw	a5,a5,0x4
    800033bc:	0001d597          	auipc	a1,0x1d
    800033c0:	6cc5a583          	lw	a1,1740(a1) # 80020a88 <sb+0x18>
    800033c4:	9dbd                	addw	a1,a1,a5
    800033c6:	4088                	lw	a0,0(s1)
    800033c8:	91fff0ef          	jal	80002ce6 <bread>
    800033cc:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    800033ce:	05850593          	addi	a1,a0,88
    800033d2:	40dc                	lw	a5,4(s1)
    800033d4:	8bbd                	andi	a5,a5,15
    800033d6:	079a                	slli	a5,a5,0x6
    800033d8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800033da:	00059783          	lh	a5,0(a1)
    800033de:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800033e2:	00259783          	lh	a5,2(a1)
    800033e6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800033ea:	00459783          	lh	a5,4(a1)
    800033ee:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800033f2:	00659783          	lh	a5,6(a1)
    800033f6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800033fa:	459c                	lw	a5,8(a1)
    800033fc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800033fe:	03400613          	li	a2,52
    80003402:	05b1                	addi	a1,a1,12
    80003404:	05048513          	addi	a0,s1,80
    80003408:	941fd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    8000340c:	854a                	mv	a0,s2
    8000340e:	9e1ff0ef          	jal	80002dee <brelse>
    ip->valid = 1;
    80003412:	4785                	li	a5,1
    80003414:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003416:	04449783          	lh	a5,68(s1)
    8000341a:	c399                	beqz	a5,80003420 <ilock+0xa2>
    8000341c:	6902                	ld	s2,0(sp)
    8000341e:	bfbd                	j	8000339c <ilock+0x1e>
      panic("ilock: no type");
    80003420:	00004517          	auipc	a0,0x4
    80003424:	10050513          	addi	a0,a0,256 # 80007520 <etext+0x520>
    80003428:	c0cfd0ef          	jal	80000834 <panic>

000000008000342c <iunlock>:
{
    8000342c:	1101                	addi	sp,sp,-32
    8000342e:	ec06                	sd	ra,24(sp)
    80003430:	e822                	sd	s0,16(sp)
    80003432:	e426                	sd	s1,8(sp)
    80003434:	e04a                	sd	s2,0(sp)
    80003436:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003438:	c505                	beqz	a0,80003460 <iunlock+0x34>
    8000343a:	84aa                	mv	s1,a0
    8000343c:	01050913          	addi	s2,a0,16
    80003440:	854a                	mv	a0,s2
    80003442:	55d000ef          	jal	8000419e <holdingsleep>
    80003446:	cd09                	beqz	a0,80003460 <iunlock+0x34>
    80003448:	449c                	lw	a5,8(s1)
    8000344a:	00f05b63          	blez	a5,80003460 <iunlock+0x34>
  releasesleep(&ip->lock);
    8000344e:	854a                	mv	a0,s2
    80003450:	517000ef          	jal	80004166 <releasesleep>
}
    80003454:	60e2                	ld	ra,24(sp)
    80003456:	6442                	ld	s0,16(sp)
    80003458:	64a2                	ld	s1,8(sp)
    8000345a:	6902                	ld	s2,0(sp)
    8000345c:	6105                	addi	sp,sp,32
    8000345e:	8082                	ret
    panic("iunlock");
    80003460:	00004517          	auipc	a0,0x4
    80003464:	0d050513          	addi	a0,a0,208 # 80007530 <etext+0x530>
    80003468:	bccfd0ef          	jal	80000834 <panic>

000000008000346c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000346c:	7179                	addi	sp,sp,-48
    8000346e:	f406                	sd	ra,40(sp)
    80003470:	f022                	sd	s0,32(sp)
    80003472:	ec26                	sd	s1,24(sp)
    80003474:	e84a                	sd	s2,16(sp)
    80003476:	e44e                	sd	s3,8(sp)
    80003478:	1800                	addi	s0,sp,48
    8000347a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    8000347c:	05050493          	addi	s1,a0,80
    80003480:	08050913          	addi	s2,a0,128
    80003484:	a021                	j	8000348c <itrunc+0x20>
    80003486:	0491                	addi	s1,s1,4
    80003488:	01248b63          	beq	s1,s2,8000349e <itrunc+0x32>
    if (ip->addrs[i]) {
    8000348c:	408c                	lw	a1,0(s1)
    8000348e:	dde5                	beqz	a1,80003486 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003490:	0009a503          	lw	a0,0(s3)
    80003494:	a47ff0ef          	jal	80002eda <bfree>
      ip->addrs[i] = 0;
    80003498:	0004a023          	sw	zero,0(s1)
    8000349c:	b7ed                	j	80003486 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    8000349e:	0809a583          	lw	a1,128(s3)
    800034a2:	ed89                	bnez	a1,800034bc <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800034a4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800034a8:	854e                	mv	a0,s3
    800034aa:	e21ff0ef          	jal	800032ca <iupdate>
}
    800034ae:	70a2                	ld	ra,40(sp)
    800034b0:	7402                	ld	s0,32(sp)
    800034b2:	64e2                	ld	s1,24(sp)
    800034b4:	6942                	ld	s2,16(sp)
    800034b6:	69a2                	ld	s3,8(sp)
    800034b8:	6145                	addi	sp,sp,48
    800034ba:	8082                	ret
    800034bc:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800034be:	0009a503          	lw	a0,0(s3)
    800034c2:	825ff0ef          	jal	80002ce6 <bread>
    800034c6:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    800034c8:	05850493          	addi	s1,a0,88
    800034cc:	45850913          	addi	s2,a0,1112
    800034d0:	a021                	j	800034d8 <itrunc+0x6c>
    800034d2:	0491                	addi	s1,s1,4
    800034d4:	01248963          	beq	s1,s2,800034e6 <itrunc+0x7a>
      if (a[j])
    800034d8:	408c                	lw	a1,0(s1)
    800034da:	dde5                	beqz	a1,800034d2 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800034dc:	0009a503          	lw	a0,0(s3)
    800034e0:	9fbff0ef          	jal	80002eda <bfree>
    800034e4:	b7fd                	j	800034d2 <itrunc+0x66>
    brelse(bp);
    800034e6:	8552                	mv	a0,s4
    800034e8:	907ff0ef          	jal	80002dee <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800034ec:	0809a583          	lw	a1,128(s3)
    800034f0:	0009a503          	lw	a0,0(s3)
    800034f4:	9e7ff0ef          	jal	80002eda <bfree>
    ip->addrs[NDIRECT] = 0;
    800034f8:	0809a023          	sw	zero,128(s3)
    800034fc:	6a02                	ld	s4,0(sp)
    800034fe:	b75d                	j	800034a4 <itrunc+0x38>

0000000080003500 <iput>:
{
    80003500:	7179                	addi	sp,sp,-48
    80003502:	f406                	sd	ra,40(sp)
    80003504:	f022                	sd	s0,32(sp)
    80003506:	ec26                	sd	s1,24(sp)
    80003508:	1800                	addi	s0,sp,48
    8000350a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000350c:	0001d517          	auipc	a0,0x1d
    80003510:	58450513          	addi	a0,a0,1412 # 80020a90 <itable>
    80003514:	f14fd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003518:	449c                	lw	a5,8(s1)
    8000351a:	4705                	li	a4,1
    8000351c:	00e78f63          	beq	a5,a4,8000353a <iput+0x3a>
  ip->ref--;
    80003520:	37fd                	addiw	a5,a5,-1
    80003522:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003524:	0001d517          	auipc	a0,0x1d
    80003528:	56c50513          	addi	a0,a0,1388 # 80020a90 <itable>
    8000352c:	f84fd0ef          	jal	80000cb0 <release>
}
    80003530:	70a2                	ld	ra,40(sp)
    80003532:	7402                	ld	s0,32(sp)
    80003534:	64e2                	ld	s1,24(sp)
    80003536:	6145                	addi	sp,sp,48
    80003538:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    8000353a:	40b8                	lw	a4,64(s1)
    8000353c:	d375                	beqz	a4,80003520 <iput+0x20>
    8000353e:	e84a                	sd	s2,16(sp)
    80003540:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    80003542:	0004aa03          	lw	s4,0(s1)
    80003546:	0044a903          	lw	s2,4(s1)
  if (last) {
    8000354a:	04a49703          	lh	a4,74(s1)
    8000354e:	ef3d                	bnez	a4,800035cc <iput+0xcc>
    80003550:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    80003552:	01048793          	addi	a5,s1,16
    80003556:	89be                	mv	s3,a5
    80003558:	853e                	mv	a0,a5
    8000355a:	3b9000ef          	jal	80004112 <acquiresleep>
    release(&itable.lock);
    8000355e:	0001d517          	auipc	a0,0x1d
    80003562:	53250513          	addi	a0,a0,1330 # 80020a90 <itable>
    80003566:	f4afd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    8000356a:	8526                	mv	a0,s1
    8000356c:	f01ff0ef          	jal	8000346c <itrunc>
    ip->valid = 0;
    80003570:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003574:	854e                	mv	a0,s3
    80003576:	3f1000ef          	jal	80004166 <releasesleep>
    acquire(&itable.lock);
    8000357a:	0001d517          	auipc	a0,0x1d
    8000357e:	51650513          	addi	a0,a0,1302 # 80020a90 <itable>
    80003582:	ea6fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    80003586:	449c                	lw	a5,8(s1)
    80003588:	37fd                	addiw	a5,a5,-1
    8000358a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000358c:	0001d517          	auipc	a0,0x1d
    80003590:	50450513          	addi	a0,a0,1284 # 80020a90 <itable>
    80003594:	f1cfd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003598:	0049579b          	srliw	a5,s2,0x4
    8000359c:	0001d597          	auipc	a1,0x1d
    800035a0:	4ec5a583          	lw	a1,1260(a1) # 80020a88 <sb+0x18>
    800035a4:	9dbd                	addw	a1,a1,a5
    800035a6:	8552                	mv	a0,s4
    800035a8:	f3eff0ef          	jal	80002ce6 <bread>
    800035ac:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800035ae:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    800035b2:	079a                	slli	a5,a5,0x6
    800035b4:	97aa                	add	a5,a5,a0
    800035b6:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    800035ba:	1eb000ef          	jal	80003fa4 <log_write>
  brelse(bp);
    800035be:	8526                	mv	a0,s1
    800035c0:	82fff0ef          	jal	80002dee <brelse>
}
    800035c4:	6942                	ld	s2,16(sp)
    800035c6:	69a2                	ld	s3,8(sp)
    800035c8:	6a02                	ld	s4,0(sp)
    800035ca:	b79d                	j	80003530 <iput+0x30>
    800035cc:	6942                	ld	s2,16(sp)
    800035ce:	6a02                	ld	s4,0(sp)
    800035d0:	bf81                	j	80003520 <iput+0x20>

00000000800035d2 <iunlockput>:
{
    800035d2:	1101                	addi	sp,sp,-32
    800035d4:	ec06                	sd	ra,24(sp)
    800035d6:	e822                	sd	s0,16(sp)
    800035d8:	e426                	sd	s1,8(sp)
    800035da:	1000                	addi	s0,sp,32
    800035dc:	84aa                	mv	s1,a0
  iunlock(ip);
    800035de:	e4fff0ef          	jal	8000342c <iunlock>
  iput(ip);
    800035e2:	8526                	mv	a0,s1
    800035e4:	f1dff0ef          	jal	80003500 <iput>
}
    800035e8:	60e2                	ld	ra,24(sp)
    800035ea:	6442                	ld	s0,16(sp)
    800035ec:	64a2                	ld	s1,8(sp)
    800035ee:	6105                	addi	sp,sp,32
    800035f0:	8082                	ret

00000000800035f2 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035f2:	0001d717          	auipc	a4,0x1d
    800035f6:	48a72703          	lw	a4,1162(a4) # 80020a7c <sb+0xc>
    800035fa:	4785                	li	a5,1
    800035fc:	0ae7fe63          	bgeu	a5,a4,800036b8 <ireclaim+0xc6>
{
    80003600:	7139                	addi	sp,sp,-64
    80003602:	fc06                	sd	ra,56(sp)
    80003604:	f822                	sd	s0,48(sp)
    80003606:	f426                	sd	s1,40(sp)
    80003608:	f04a                	sd	s2,32(sp)
    8000360a:	ec4e                	sd	s3,24(sp)
    8000360c:	e852                	sd	s4,16(sp)
    8000360e:	e456                	sd	s5,8(sp)
    80003610:	e05a                	sd	s6,0(sp)
    80003612:	0080                	addi	s0,sp,64
    80003614:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003616:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003618:	0001da17          	auipc	s4,0x1d
    8000361c:	458a0a13          	addi	s4,s4,1112 # 80020a70 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    80003620:	00004b17          	auipc	s6,0x4
    80003624:	f18b0b13          	addi	s6,s6,-232 # 80007538 <etext+0x538>
    80003628:	a099                	j	8000366e <ireclaim+0x7c>
    8000362a:	85ce                	mv	a1,s3
    8000362c:	855a                	mv	a0,s6
    8000362e:	eddfc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    80003632:	85ce                	mv	a1,s3
    80003634:	8556                	mv	a0,s5
    80003636:	ad7ff0ef          	jal	8000310c <iget>
    8000363a:	89aa                	mv	s3,a0
    brelse(bp);
    8000363c:	854a                	mv	a0,s2
    8000363e:	fb0ff0ef          	jal	80002dee <brelse>
    if (ip) {
    80003642:	00098f63          	beqz	s3,80003660 <ireclaim+0x6e>
      begin_op();
    80003646:	7b0000ef          	jal	80003df6 <begin_op>
      ilock(ip);
    8000364a:	854e                	mv	a0,s3
    8000364c:	d33ff0ef          	jal	8000337e <ilock>
      iunlock(ip);
    80003650:	854e                	mv	a0,s3
    80003652:	ddbff0ef          	jal	8000342c <iunlock>
      iput(ip);
    80003656:	854e                	mv	a0,s3
    80003658:	ea9ff0ef          	jal	80003500 <iput>
      end_op();
    8000365c:	027000ef          	jal	80003e82 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003660:	0485                	addi	s1,s1,1
    80003662:	00ca2703          	lw	a4,12(s4)
    80003666:	0004879b          	sext.w	a5,s1
    8000366a:	02e7fd63          	bgeu	a5,a4,800036a4 <ireclaim+0xb2>
    8000366e:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003672:	0044d593          	srli	a1,s1,0x4
    80003676:	018a2783          	lw	a5,24(s4)
    8000367a:	9dbd                	addw	a1,a1,a5
    8000367c:	8556                	mv	a0,s5
    8000367e:	e68ff0ef          	jal	80002ce6 <bread>
    80003682:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003684:	05850793          	addi	a5,a0,88
    80003688:	00f9f713          	andi	a4,s3,15
    8000368c:	071a                	slli	a4,a4,0x6
    8000368e:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    80003690:	00079703          	lh	a4,0(a5)
    80003694:	c701                	beqz	a4,8000369c <ireclaim+0xaa>
    80003696:	00679783          	lh	a5,6(a5)
    8000369a:	dbc1                	beqz	a5,8000362a <ireclaim+0x38>
    brelse(bp);
    8000369c:	854a                	mv	a0,s2
    8000369e:	f50ff0ef          	jal	80002dee <brelse>
    if (ip) {
    800036a2:	bf7d                	j	80003660 <ireclaim+0x6e>
}
    800036a4:	70e2                	ld	ra,56(sp)
    800036a6:	7442                	ld	s0,48(sp)
    800036a8:	74a2                	ld	s1,40(sp)
    800036aa:	7902                	ld	s2,32(sp)
    800036ac:	69e2                	ld	s3,24(sp)
    800036ae:	6a42                	ld	s4,16(sp)
    800036b0:	6aa2                	ld	s5,8(sp)
    800036b2:	6b02                	ld	s6,0(sp)
    800036b4:	6121                	addi	sp,sp,64
    800036b6:	8082                	ret
    800036b8:	8082                	ret

00000000800036ba <fsinit>:
{
    800036ba:	1101                	addi	sp,sp,-32
    800036bc:	ec06                	sd	ra,24(sp)
    800036be:	e822                	sd	s0,16(sp)
    800036c0:	e426                	sd	s1,8(sp)
    800036c2:	e04a                	sd	s2,0(sp)
    800036c4:	1000                	addi	s0,sp,32
    800036c6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036c8:	4585                	li	a1,1
    800036ca:	e1cff0ef          	jal	80002ce6 <bread>
    800036ce:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036d0:	02000613          	li	a2,32
    800036d4:	05850593          	addi	a1,a0,88
    800036d8:	0001d517          	auipc	a0,0x1d
    800036dc:	39850513          	addi	a0,a0,920 # 80020a70 <sb>
    800036e0:	e68fd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    800036e4:	8526                	mv	a0,s1
    800036e6:	f08ff0ef          	jal	80002dee <brelse>
  if (sb.magic != FSMAGIC)
    800036ea:	0001d717          	auipc	a4,0x1d
    800036ee:	38672703          	lw	a4,902(a4) # 80020a70 <sb>
    800036f2:	102037b7          	lui	a5,0x10203
    800036f6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036fa:	02f71263          	bne	a4,a5,8000371e <fsinit+0x64>
  initlog(dev, &sb);
    800036fe:	0001d597          	auipc	a1,0x1d
    80003702:	37258593          	addi	a1,a1,882 # 80020a70 <sb>
    80003706:	854a                	mv	a0,s2
    80003708:	66c000ef          	jal	80003d74 <initlog>
  ireclaim(dev);
    8000370c:	854a                	mv	a0,s2
    8000370e:	ee5ff0ef          	jal	800035f2 <ireclaim>
}
    80003712:	60e2                	ld	ra,24(sp)
    80003714:	6442                	ld	s0,16(sp)
    80003716:	64a2                	ld	s1,8(sp)
    80003718:	6902                	ld	s2,0(sp)
    8000371a:	6105                	addi	sp,sp,32
    8000371c:	8082                	ret
    panic("invalid file system");
    8000371e:	00004517          	auipc	a0,0x4
    80003722:	e3a50513          	addi	a0,a0,-454 # 80007558 <etext+0x558>
    80003726:	90efd0ef          	jal	80000834 <panic>

000000008000372a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000372a:	1141                	addi	sp,sp,-16
    8000372c:	e406                	sd	ra,8(sp)
    8000372e:	e022                	sd	s0,0(sp)
    80003730:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003732:	411c                	lw	a5,0(a0)
    80003734:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003736:	415c                	lw	a5,4(a0)
    80003738:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000373a:	04451783          	lh	a5,68(a0)
    8000373e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003742:	04a51783          	lh	a5,74(a0)
    80003746:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000374a:	04c56783          	lwu	a5,76(a0)
    8000374e:	e99c                	sd	a5,16(a1)
}
    80003750:	60a2                	ld	ra,8(sp)
    80003752:	6402                	ld	s0,0(sp)
    80003754:	0141                	addi	sp,sp,16
    80003756:	8082                	ret

0000000080003758 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003758:	457c                	lw	a5,76(a0)
    8000375a:	0ed7e663          	bltu	a5,a3,80003846 <readi+0xee>
{
    8000375e:	7159                	addi	sp,sp,-112
    80003760:	f486                	sd	ra,104(sp)
    80003762:	f0a2                	sd	s0,96(sp)
    80003764:	eca6                	sd	s1,88(sp)
    80003766:	e0d2                	sd	s4,64(sp)
    80003768:	fc56                	sd	s5,56(sp)
    8000376a:	f85a                	sd	s6,48(sp)
    8000376c:	f45e                	sd	s7,40(sp)
    8000376e:	1880                	addi	s0,sp,112
    80003770:	8b2a                	mv	s6,a0
    80003772:	8bae                	mv	s7,a1
    80003774:	8a32                	mv	s4,a2
    80003776:	84b6                	mv	s1,a3
    80003778:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    8000377a:	9f35                	addw	a4,a4,a3
    return 0;
    8000377c:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    8000377e:	0ad76b63          	bltu	a4,a3,80003834 <readi+0xdc>
    80003782:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003784:	00e7f463          	bgeu	a5,a4,8000378c <readi+0x34>
    n = ip->size - off;
    80003788:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000378c:	080a8b63          	beqz	s5,80003822 <readi+0xca>
    80003790:	e8ca                	sd	s2,80(sp)
    80003792:	f062                	sd	s8,32(sp)
    80003794:	ec66                	sd	s9,24(sp)
    80003796:	e86a                	sd	s10,16(sp)
    80003798:	e46e                	sd	s11,8(sp)
    8000379a:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000379c:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800037a0:	5c7d                	li	s8,-1
    800037a2:	a80d                	j	800037d4 <readi+0x7c>
    800037a4:	020d1d93          	slli	s11,s10,0x20
    800037a8:	020ddd93          	srli	s11,s11,0x20
    800037ac:	05890613          	addi	a2,s2,88
    800037b0:	86ee                	mv	a3,s11
    800037b2:	963e                	add	a2,a2,a5
    800037b4:	85d2                	mv	a1,s4
    800037b6:	855e                	mv	a0,s7
    800037b8:	bfdfe0ef          	jal	800023b4 <either_copyout>
    800037bc:	05850363          	beq	a0,s8,80003802 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800037c0:	854a                	mv	a0,s2
    800037c2:	e2cff0ef          	jal	80002dee <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800037c6:	013d09bb          	addw	s3,s10,s3
    800037ca:	009d04bb          	addw	s1,s10,s1
    800037ce:	9a6e                	add	s4,s4,s11
    800037d0:	0559f363          	bgeu	s3,s5,80003816 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    800037d4:	00a4d59b          	srliw	a1,s1,0xa
    800037d8:	855a                	mv	a0,s6
    800037da:	873ff0ef          	jal	8000304c <bmap>
    800037de:	85aa                	mv	a1,a0
    if (addr == 0)
    800037e0:	c139                	beqz	a0,80003826 <readi+0xce>
    bp = bread(ip->dev, addr);
    800037e2:	000b2503          	lw	a0,0(s6)
    800037e6:	d00ff0ef          	jal	80002ce6 <bread>
    800037ea:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800037ec:	3ff4f793          	andi	a5,s1,1023
    800037f0:	40fc873b          	subw	a4,s9,a5
    800037f4:	413a86bb          	subw	a3,s5,s3
    800037f8:	8d3a                	mv	s10,a4
    800037fa:	fae6f5e3          	bgeu	a3,a4,800037a4 <readi+0x4c>
    800037fe:	8d36                	mv	s10,a3
    80003800:	b755                	j	800037a4 <readi+0x4c>
      brelse(bp);
    80003802:	854a                	mv	a0,s2
    80003804:	deaff0ef          	jal	80002dee <brelse>
      tot = -1;
    80003808:	59fd                	li	s3,-1
      break;
    8000380a:	6946                	ld	s2,80(sp)
    8000380c:	7c02                	ld	s8,32(sp)
    8000380e:	6ce2                	ld	s9,24(sp)
    80003810:	6d42                	ld	s10,16(sp)
    80003812:	6da2                	ld	s11,8(sp)
    80003814:	a831                	j	80003830 <readi+0xd8>
    80003816:	6946                	ld	s2,80(sp)
    80003818:	7c02                	ld	s8,32(sp)
    8000381a:	6ce2                	ld	s9,24(sp)
    8000381c:	6d42                	ld	s10,16(sp)
    8000381e:	6da2                	ld	s11,8(sp)
    80003820:	a801                	j	80003830 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003822:	89d6                	mv	s3,s5
    80003824:	a031                	j	80003830 <readi+0xd8>
    80003826:	6946                	ld	s2,80(sp)
    80003828:	7c02                	ld	s8,32(sp)
    8000382a:	6ce2                	ld	s9,24(sp)
    8000382c:	6d42                	ld	s10,16(sp)
    8000382e:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003830:	854e                	mv	a0,s3
    80003832:	69a6                	ld	s3,72(sp)
}
    80003834:	70a6                	ld	ra,104(sp)
    80003836:	7406                	ld	s0,96(sp)
    80003838:	64e6                	ld	s1,88(sp)
    8000383a:	6a06                	ld	s4,64(sp)
    8000383c:	7ae2                	ld	s5,56(sp)
    8000383e:	7b42                	ld	s6,48(sp)
    80003840:	7ba2                	ld	s7,40(sp)
    80003842:	6165                	addi	sp,sp,112
    80003844:	8082                	ret
    return 0;
    80003846:	4501                	li	a0,0
}
    80003848:	8082                	ret

000000008000384a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    8000384a:	457c                	lw	a5,76(a0)
    8000384c:	0ed7ee63          	bltu	a5,a3,80003948 <writei+0xfe>
{
    80003850:	7159                	addi	sp,sp,-112
    80003852:	f486                	sd	ra,104(sp)
    80003854:	f0a2                	sd	s0,96(sp)
    80003856:	e8ca                	sd	s2,80(sp)
    80003858:	e0d2                	sd	s4,64(sp)
    8000385a:	fc56                	sd	s5,56(sp)
    8000385c:	f85a                	sd	s6,48(sp)
    8000385e:	f45e                	sd	s7,40(sp)
    80003860:	1880                	addi	s0,sp,112
    80003862:	8aaa                	mv	s5,a0
    80003864:	8bae                	mv	s7,a1
    80003866:	8a32                	mv	s4,a2
    80003868:	8936                	mv	s2,a3
    8000386a:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    8000386c:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003870:	00043737          	lui	a4,0x43
    80003874:	0cf76c63          	bltu	a4,a5,8000394c <writei+0x102>
    80003878:	0cd7ea63          	bltu	a5,a3,8000394c <writei+0x102>
    8000387c:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000387e:	0a0b0d63          	beqz	s6,80003938 <writei+0xee>
    80003882:	eca6                	sd	s1,88(sp)
    80003884:	f062                	sd	s8,32(sp)
    80003886:	ec66                	sd	s9,24(sp)
    80003888:	e86a                	sd	s10,16(sp)
    8000388a:	e46e                	sd	s11,8(sp)
    8000388c:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000388e:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003892:	5c7d                	li	s8,-1
    80003894:	a825                	j	800038cc <writei+0x82>
    80003896:	020d1d93          	slli	s11,s10,0x20
    8000389a:	020ddd93          	srli	s11,s11,0x20
    8000389e:	05848513          	addi	a0,s1,88
    800038a2:	86ee                	mv	a3,s11
    800038a4:	8652                	mv	a2,s4
    800038a6:	85de                	mv	a1,s7
    800038a8:	953e                	add	a0,a0,a5
    800038aa:	b57fe0ef          	jal	80002400 <either_copyin>
    800038ae:	05850663          	beq	a0,s8,800038fa <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    800038b2:	8526                	mv	a0,s1
    800038b4:	6f0000ef          	jal	80003fa4 <log_write>
    brelse(bp);
    800038b8:	8526                	mv	a0,s1
    800038ba:	d34ff0ef          	jal	80002dee <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800038be:	013d09bb          	addw	s3,s10,s3
    800038c2:	012d093b          	addw	s2,s10,s2
    800038c6:	9a6e                	add	s4,s4,s11
    800038c8:	0369ff63          	bgeu	s3,s6,80003906 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    800038cc:	00a9559b          	srliw	a1,s2,0xa
    800038d0:	8556                	mv	a0,s5
    800038d2:	f7aff0ef          	jal	8000304c <bmap>
    800038d6:	85aa                	mv	a1,a0
    if (addr == 0)
    800038d8:	c51d                	beqz	a0,80003906 <writei+0xbc>
    bp = bread(ip->dev, addr);
    800038da:	000aa503          	lw	a0,0(s5)
    800038de:	c08ff0ef          	jal	80002ce6 <bread>
    800038e2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800038e4:	3ff97793          	andi	a5,s2,1023
    800038e8:	40fc873b          	subw	a4,s9,a5
    800038ec:	413b06bb          	subw	a3,s6,s3
    800038f0:	8d3a                	mv	s10,a4
    800038f2:	fae6f2e3          	bgeu	a3,a4,80003896 <writei+0x4c>
    800038f6:	8d36                	mv	s10,a3
    800038f8:	bf79                	j	80003896 <writei+0x4c>
      log_write(bp);
    800038fa:	8526                	mv	a0,s1
    800038fc:	6a8000ef          	jal	80003fa4 <log_write>
      brelse(bp);
    80003900:	8526                	mv	a0,s1
    80003902:	cecff0ef          	jal	80002dee <brelse>
  }

  if (off > ip->size)
    80003906:	04caa783          	lw	a5,76(s5)
    8000390a:	0327f963          	bgeu	a5,s2,8000393c <writei+0xf2>
    ip->size = off;
    8000390e:	052aa623          	sw	s2,76(s5)
    80003912:	64e6                	ld	s1,88(sp)
    80003914:	7c02                	ld	s8,32(sp)
    80003916:	6ce2                	ld	s9,24(sp)
    80003918:	6d42                	ld	s10,16(sp)
    8000391a:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000391c:	8556                	mv	a0,s5
    8000391e:	9adff0ef          	jal	800032ca <iupdate>

  return tot;
    80003922:	854e                	mv	a0,s3
    80003924:	69a6                	ld	s3,72(sp)
}
    80003926:	70a6                	ld	ra,104(sp)
    80003928:	7406                	ld	s0,96(sp)
    8000392a:	6946                	ld	s2,80(sp)
    8000392c:	6a06                	ld	s4,64(sp)
    8000392e:	7ae2                	ld	s5,56(sp)
    80003930:	7b42                	ld	s6,48(sp)
    80003932:	7ba2                	ld	s7,40(sp)
    80003934:	6165                	addi	sp,sp,112
    80003936:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003938:	89da                	mv	s3,s6
    8000393a:	b7cd                	j	8000391c <writei+0xd2>
    8000393c:	64e6                	ld	s1,88(sp)
    8000393e:	7c02                	ld	s8,32(sp)
    80003940:	6ce2                	ld	s9,24(sp)
    80003942:	6d42                	ld	s10,16(sp)
    80003944:	6da2                	ld	s11,8(sp)
    80003946:	bfd9                	j	8000391c <writei+0xd2>
    return -1;
    80003948:	557d                	li	a0,-1
}
    8000394a:	8082                	ret
    return -1;
    8000394c:	557d                	li	a0,-1
    8000394e:	bfe1                	j	80003926 <writei+0xdc>

0000000080003950 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003950:	1141                	addi	sp,sp,-16
    80003952:	e406                	sd	ra,8(sp)
    80003954:	e022                	sd	s0,0(sp)
    80003956:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003958:	4639                	li	a2,14
    8000395a:	c62fd0ef          	jal	80000dbc <strncmp>
}
    8000395e:	60a2                	ld	ra,8(sp)
    80003960:	6402                	ld	s0,0(sp)
    80003962:	0141                	addi	sp,sp,16
    80003964:	8082                	ret

0000000080003966 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003966:	711d                	addi	sp,sp,-96
    80003968:	ec86                	sd	ra,88(sp)
    8000396a:	e8a2                	sd	s0,80(sp)
    8000396c:	e4a6                	sd	s1,72(sp)
    8000396e:	e0ca                	sd	s2,64(sp)
    80003970:	fc4e                	sd	s3,56(sp)
    80003972:	f852                	sd	s4,48(sp)
    80003974:	f456                	sd	s5,40(sp)
    80003976:	f05a                	sd	s6,32(sp)
    80003978:	ec5e                	sd	s7,24(sp)
    8000397a:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    8000397c:	04451703          	lh	a4,68(a0)
    80003980:	4785                	li	a5,1
    80003982:	00f71f63          	bne	a4,a5,800039a0 <dirlookup+0x3a>
    80003986:	892a                	mv	s2,a0
    80003988:	8aae                	mv	s5,a1
    8000398a:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000398c:	457c                	lw	a5,76(a0)
    8000398e:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003990:	fa040a13          	addi	s4,s0,-96
    80003994:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003996:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000399a:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000399c:	e39d                	bnez	a5,800039c2 <dirlookup+0x5c>
    8000399e:	a8b9                	j	800039fc <dirlookup+0x96>
    panic("dirlookup not DIR");
    800039a0:	00004517          	auipc	a0,0x4
    800039a4:	bd050513          	addi	a0,a0,-1072 # 80007570 <etext+0x570>
    800039a8:	e8dfc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    800039ac:	00004517          	auipc	a0,0x4
    800039b0:	bdc50513          	addi	a0,a0,-1060 # 80007588 <etext+0x588>
    800039b4:	e81fc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039b8:	24c1                	addiw	s1,s1,16
    800039ba:	04c92783          	lw	a5,76(s2)
    800039be:	02f4fe63          	bgeu	s1,a5,800039fa <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039c2:	874e                	mv	a4,s3
    800039c4:	86a6                	mv	a3,s1
    800039c6:	8652                	mv	a2,s4
    800039c8:	4581                	li	a1,0
    800039ca:	854a                	mv	a0,s2
    800039cc:	d8dff0ef          	jal	80003758 <readi>
    800039d0:	fd351ee3          	bne	a0,s3,800039ac <dirlookup+0x46>
    if (de.inum == 0)
    800039d4:	fa045783          	lhu	a5,-96(s0)
    800039d8:	d3e5                	beqz	a5,800039b8 <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    800039da:	85da                	mv	a1,s6
    800039dc:	8556                	mv	a0,s5
    800039de:	f73ff0ef          	jal	80003950 <namecmp>
    800039e2:	f979                	bnez	a0,800039b8 <dirlookup+0x52>
      if (poff)
    800039e4:	000b8463          	beqz	s7,800039ec <dirlookup+0x86>
        *poff = off;
    800039e8:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800039ec:	fa045583          	lhu	a1,-96(s0)
    800039f0:	00092503          	lw	a0,0(s2)
    800039f4:	f18ff0ef          	jal	8000310c <iget>
    800039f8:	a011                	j	800039fc <dirlookup+0x96>
  return 0;
    800039fa:	4501                	li	a0,0
}
    800039fc:	60e6                	ld	ra,88(sp)
    800039fe:	6446                	ld	s0,80(sp)
    80003a00:	64a6                	ld	s1,72(sp)
    80003a02:	6906                	ld	s2,64(sp)
    80003a04:	79e2                	ld	s3,56(sp)
    80003a06:	7a42                	ld	s4,48(sp)
    80003a08:	7aa2                	ld	s5,40(sp)
    80003a0a:	7b02                	ld	s6,32(sp)
    80003a0c:	6be2                	ld	s7,24(sp)
    80003a0e:	6125                	addi	sp,sp,96
    80003a10:	8082                	ret

0000000080003a12 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003a12:	711d                	addi	sp,sp,-96
    80003a14:	ec86                	sd	ra,88(sp)
    80003a16:	e8a2                	sd	s0,80(sp)
    80003a18:	e4a6                	sd	s1,72(sp)
    80003a1a:	e0ca                	sd	s2,64(sp)
    80003a1c:	fc4e                	sd	s3,56(sp)
    80003a1e:	f852                	sd	s4,48(sp)
    80003a20:	f456                	sd	s5,40(sp)
    80003a22:	f05a                	sd	s6,32(sp)
    80003a24:	ec5e                	sd	s7,24(sp)
    80003a26:	e862                	sd	s8,16(sp)
    80003a28:	e466                	sd	s9,8(sp)
    80003a2a:	e06a                	sd	s10,0(sp)
    80003a2c:	1080                	addi	s0,sp,96
    80003a2e:	84aa                	mv	s1,a0
    80003a30:	8b2e                	mv	s6,a1
    80003a32:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003a34:	00054703          	lbu	a4,0(a0)
    80003a38:	02f00793          	li	a5,47
    80003a3c:	00f70f63          	beq	a4,a5,80003a5a <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a40:	fd9fd0ef          	jal	80001a18 <myproc>
    80003a44:	15053503          	ld	a0,336(a0)
    80003a48:	901ff0ef          	jal	80003348 <idup>
    80003a4c:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003a4e:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003a52:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003a54:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003a56:	4b85                	li	s7,1
    80003a58:	a07d                	j	80003b06 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003a5a:	4585                	li	a1,1
    80003a5c:	852e                	mv	a0,a1
    80003a5e:	eaeff0ef          	jal	8000310c <iget>
    80003a62:	8a2a                	mv	s4,a0
    80003a64:	b7ed                	j	80003a4e <namex+0x3c>
      iunlockput(ip);
    80003a66:	8552                	mv	a0,s4
    80003a68:	b6bff0ef          	jal	800035d2 <iunlockput>
      return 0;
    80003a6c:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a6e:	8552                	mv	a0,s4
    80003a70:	60e6                	ld	ra,88(sp)
    80003a72:	6446                	ld	s0,80(sp)
    80003a74:	64a6                	ld	s1,72(sp)
    80003a76:	6906                	ld	s2,64(sp)
    80003a78:	79e2                	ld	s3,56(sp)
    80003a7a:	7a42                	ld	s4,48(sp)
    80003a7c:	7aa2                	ld	s5,40(sp)
    80003a7e:	7b02                	ld	s6,32(sp)
    80003a80:	6be2                	ld	s7,24(sp)
    80003a82:	6c42                	ld	s8,16(sp)
    80003a84:	6ca2                	ld	s9,8(sp)
    80003a86:	6d02                	ld	s10,0(sp)
    80003a88:	6125                	addi	sp,sp,96
    80003a8a:	8082                	ret
      iunlockput(ip);
    80003a8c:	8552                	mv	a0,s4
    80003a8e:	b45ff0ef          	jal	800035d2 <iunlockput>
      return 0;
    80003a92:	4a01                	li	s4,0
    80003a94:	bfe9                	j	80003a6e <namex+0x5c>
      iunlock(ip);
    80003a96:	8552                	mv	a0,s4
    80003a98:	995ff0ef          	jal	8000342c <iunlock>
      return ip;
    80003a9c:	bfc9                	j	80003a6e <namex+0x5c>
      iunlockput(ip);
    80003a9e:	8552                	mv	a0,s4
    80003aa0:	b33ff0ef          	jal	800035d2 <iunlockput>
      return 0;
    80003aa4:	8a4a                	mv	s4,s2
    80003aa6:	b7e1                	j	80003a6e <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003aa8:	8926                	mv	s2,s1
  len = path - s;
    80003aaa:	4d01                	li	s10,0
    80003aac:	4601                	li	a2,0
    memmove(name, s, len);
    80003aae:	2601                	sext.w	a2,a2
    80003ab0:	85a6                	mv	a1,s1
    80003ab2:	8556                	mv	a0,s5
    80003ab4:	a94fd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003ab8:	9d56                	add	s10,s10,s5
    80003aba:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb888>
  while (*path == '/')
    80003abe:	00094783          	lbu	a5,0(s2)
    80003ac2:	09379b63          	bne	a5,s3,80003b58 <namex+0x146>
    80003ac6:	84ca                	mv	s1,s2
    path++;
    80003ac8:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003aca:	0004c783          	lbu	a5,0(s1)
    80003ace:	ff378de3          	beq	a5,s3,80003ac8 <namex+0xb6>
    ilock(ip);
    80003ad2:	8552                	mv	a0,s4
    80003ad4:	8abff0ef          	jal	8000337e <ilock>
    if (ip->type != T_DIR) {
    80003ad8:	044a1783          	lh	a5,68(s4)
    80003adc:	f97795e3          	bne	a5,s7,80003a66 <namex+0x54>
    if (ip->nlink == 0) {
    80003ae0:	04aa1783          	lh	a5,74(s4)
    80003ae4:	d7c5                	beqz	a5,80003a8c <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003ae6:	000b0563          	beqz	s6,80003af0 <namex+0xde>
    80003aea:	0004c783          	lbu	a5,0(s1)
    80003aee:	d7c5                	beqz	a5,80003a96 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003af0:	4601                	li	a2,0
    80003af2:	85d6                	mv	a1,s5
    80003af4:	8552                	mv	a0,s4
    80003af6:	e71ff0ef          	jal	80003966 <dirlookup>
    80003afa:	892a                	mv	s2,a0
    80003afc:	d14d                	beqz	a0,80003a9e <namex+0x8c>
    iunlockput(ip);
    80003afe:	8552                	mv	a0,s4
    80003b00:	ad3ff0ef          	jal	800035d2 <iunlockput>
    ip = next;
    80003b04:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003b06:	0004c783          	lbu	a5,0(s1)
    80003b0a:	01379763          	bne	a5,s3,80003b18 <namex+0x106>
    path++;
    80003b0e:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b10:	0004c783          	lbu	a5,0(s1)
    80003b14:	ff378de3          	beq	a5,s3,80003b0e <namex+0xfc>
  if (*path == 0)
    80003b18:	c7a1                	beqz	a5,80003b60 <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003b1a:	0004c783          	lbu	a5,0(s1)
    80003b1e:	fd178713          	addi	a4,a5,-47
    80003b22:	d359                	beqz	a4,80003aa8 <namex+0x96>
    80003b24:	d3d1                	beqz	a5,80003aa8 <namex+0x96>
    80003b26:	8926                	mv	s2,s1
    path++;
    80003b28:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003b2a:	00094783          	lbu	a5,0(s2)
    80003b2e:	fd178713          	addi	a4,a5,-47
    80003b32:	c311                	beqz	a4,80003b36 <namex+0x124>
    80003b34:	fbf5                	bnez	a5,80003b28 <namex+0x116>
  len = path - s;
    80003b36:	40990633          	sub	a2,s2,s1
    80003b3a:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003b3e:	f7ac58e3          	bge	s8,s10,80003aae <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003b42:	8666                	mv	a2,s9
    80003b44:	85a6                	mv	a1,s1
    80003b46:	8556                	mv	a0,s5
    80003b48:	a00fd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003b4c:	00094783          	lbu	a5,0(s2)
    80003b50:	84ca                	mv	s1,s2
    80003b52:	f7378be3          	beq	a5,s3,80003ac8 <namex+0xb6>
    80003b56:	bfb5                	j	80003ad2 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003b58:	00090463          	beqz	s2,80003b60 <namex+0x14e>
    80003b5c:	84ca                	mv	s1,s2
    80003b5e:	bf95                	j	80003ad2 <namex+0xc0>
  if (nameiparent) {
    80003b60:	f00b07e3          	beqz	s6,80003a6e <namex+0x5c>
    iput(ip);
    80003b64:	8552                	mv	a0,s4
    80003b66:	99bff0ef          	jal	80003500 <iput>
    return 0;
    80003b6a:	4a01                	li	s4,0
    80003b6c:	b709                	j	80003a6e <namex+0x5c>

0000000080003b6e <dirlink>:
{
    80003b6e:	715d                	addi	sp,sp,-80
    80003b70:	e486                	sd	ra,72(sp)
    80003b72:	e0a2                	sd	s0,64(sp)
    80003b74:	f84a                	sd	s2,48(sp)
    80003b76:	ec56                	sd	s5,24(sp)
    80003b78:	e85a                	sd	s6,16(sp)
    80003b7a:	0880                	addi	s0,sp,80
    80003b7c:	892a                	mv	s2,a0
    80003b7e:	8aae                	mv	s5,a1
    80003b80:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003b82:	4601                	li	a2,0
    80003b84:	de3ff0ef          	jal	80003966 <dirlookup>
    80003b88:	ed1d                	bnez	a0,80003bc6 <dirlink+0x58>
    80003b8a:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003b8c:	04c92483          	lw	s1,76(s2)
    80003b90:	c4b9                	beqz	s1,80003bde <dirlink+0x70>
    80003b92:	f44e                	sd	s3,40(sp)
    80003b94:	f052                	sd	s4,32(sp)
    80003b96:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b98:	fb040a13          	addi	s4,s0,-80
    80003b9c:	49c1                	li	s3,16
    80003b9e:	874e                	mv	a4,s3
    80003ba0:	86a6                	mv	a3,s1
    80003ba2:	8652                	mv	a2,s4
    80003ba4:	4581                	li	a1,0
    80003ba6:	854a                	mv	a0,s2
    80003ba8:	bb1ff0ef          	jal	80003758 <readi>
    80003bac:	03351163          	bne	a0,s3,80003bce <dirlink+0x60>
    if (de.inum == 0)
    80003bb0:	fb045783          	lhu	a5,-80(s0)
    80003bb4:	c39d                	beqz	a5,80003bda <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003bb6:	24c1                	addiw	s1,s1,16
    80003bb8:	04c92783          	lw	a5,76(s2)
    80003bbc:	fef4e1e3          	bltu	s1,a5,80003b9e <dirlink+0x30>
    80003bc0:	79a2                	ld	s3,40(sp)
    80003bc2:	7a02                	ld	s4,32(sp)
    80003bc4:	a829                	j	80003bde <dirlink+0x70>
    iput(ip);
    80003bc6:	93bff0ef          	jal	80003500 <iput>
    return -1;
    80003bca:	557d                	li	a0,-1
    80003bcc:	a83d                	j	80003c0a <dirlink+0x9c>
      panic("dirlink read");
    80003bce:	00004517          	auipc	a0,0x4
    80003bd2:	9ca50513          	addi	a0,a0,-1590 # 80007598 <etext+0x598>
    80003bd6:	c5ffc0ef          	jal	80000834 <panic>
    80003bda:	79a2                	ld	s3,40(sp)
    80003bdc:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003bde:	4639                	li	a2,14
    80003be0:	85d6                	mv	a1,s5
    80003be2:	fb240513          	addi	a0,s0,-78
    80003be6:	a10fd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003bea:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bee:	4741                	li	a4,16
    80003bf0:	86a6                	mv	a3,s1
    80003bf2:	fb040613          	addi	a2,s0,-80
    80003bf6:	4581                	li	a1,0
    80003bf8:	854a                	mv	a0,s2
    80003bfa:	c51ff0ef          	jal	8000384a <writei>
    80003bfe:	1541                	addi	a0,a0,-16
    80003c00:	00a03533          	snez	a0,a0
    80003c04:	40a0053b          	negw	a0,a0
    80003c08:	74e2                	ld	s1,56(sp)
}
    80003c0a:	60a6                	ld	ra,72(sp)
    80003c0c:	6406                	ld	s0,64(sp)
    80003c0e:	7942                	ld	s2,48(sp)
    80003c10:	6ae2                	ld	s5,24(sp)
    80003c12:	6b42                	ld	s6,16(sp)
    80003c14:	6161                	addi	sp,sp,80
    80003c16:	8082                	ret

0000000080003c18 <namei>:

struct inode *
namei(char *path)
{
    80003c18:	1101                	addi	sp,sp,-32
    80003c1a:	ec06                	sd	ra,24(sp)
    80003c1c:	e822                	sd	s0,16(sp)
    80003c1e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c20:	fe040613          	addi	a2,s0,-32
    80003c24:	4581                	li	a1,0
    80003c26:	dedff0ef          	jal	80003a12 <namex>
}
    80003c2a:	60e2                	ld	ra,24(sp)
    80003c2c:	6442                	ld	s0,16(sp)
    80003c2e:	6105                	addi	sp,sp,32
    80003c30:	8082                	ret

0000000080003c32 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003c32:	1141                	addi	sp,sp,-16
    80003c34:	e406                	sd	ra,8(sp)
    80003c36:	e022                	sd	s0,0(sp)
    80003c38:	0800                	addi	s0,sp,16
    80003c3a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003c3c:	4585                	li	a1,1
    80003c3e:	dd5ff0ef          	jal	80003a12 <namex>
}
    80003c42:	60a2                	ld	ra,8(sp)
    80003c44:	6402                	ld	s0,0(sp)
    80003c46:	0141                	addi	sp,sp,16
    80003c48:	8082                	ret

0000000080003c4a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c4a:	1101                	addi	sp,sp,-32
    80003c4c:	ec06                	sd	ra,24(sp)
    80003c4e:	e822                	sd	s0,16(sp)
    80003c50:	e426                	sd	s1,8(sp)
    80003c52:	e04a                	sd	s2,0(sp)
    80003c54:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c56:	0001f917          	auipc	s2,0x1f
    80003c5a:	8e290913          	addi	s2,s2,-1822 # 80022538 <log>
    80003c5e:	01892583          	lw	a1,24(s2)
    80003c62:	02492503          	lw	a0,36(s2)
    80003c66:	880ff0ef          	jal	80002ce6 <bread>
    80003c6a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003c6c:	02c92603          	lw	a2,44(s2)
    80003c70:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c72:	00c05f63          	blez	a2,80003c90 <write_head+0x46>
    80003c76:	0001f717          	auipc	a4,0x1f
    80003c7a:	8f270713          	addi	a4,a4,-1806 # 80022568 <log+0x30>
    80003c7e:	87aa                	mv	a5,a0
    80003c80:	060a                	slli	a2,a2,0x2
    80003c82:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003c84:	4314                	lw	a3,0(a4)
    80003c86:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003c88:	0711                	addi	a4,a4,4
    80003c8a:	0791                	addi	a5,a5,4
    80003c8c:	fec79ce3          	bne	a5,a2,80003c84 <write_head+0x3a>
  }
  bwrite(buf);
    80003c90:	8526                	mv	a0,s1
    80003c92:	92aff0ef          	jal	80002dbc <bwrite>
  brelse(buf);
    80003c96:	8526                	mv	a0,s1
    80003c98:	956ff0ef          	jal	80002dee <brelse>
}
    80003c9c:	60e2                	ld	ra,24(sp)
    80003c9e:	6442                	ld	s0,16(sp)
    80003ca0:	64a2                	ld	s1,8(sp)
    80003ca2:	6902                	ld	s2,0(sp)
    80003ca4:	6105                	addi	sp,sp,32
    80003ca6:	8082                	ret

0000000080003ca8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ca8:	0001f797          	auipc	a5,0x1f
    80003cac:	8bc7a783          	lw	a5,-1860(a5) # 80022564 <log+0x2c>
    80003cb0:	0cf05163          	blez	a5,80003d72 <install_trans+0xca>
{
    80003cb4:	715d                	addi	sp,sp,-80
    80003cb6:	e486                	sd	ra,72(sp)
    80003cb8:	e0a2                	sd	s0,64(sp)
    80003cba:	fc26                	sd	s1,56(sp)
    80003cbc:	f84a                	sd	s2,48(sp)
    80003cbe:	f44e                	sd	s3,40(sp)
    80003cc0:	f052                	sd	s4,32(sp)
    80003cc2:	ec56                	sd	s5,24(sp)
    80003cc4:	e85a                	sd	s6,16(sp)
    80003cc6:	e45e                	sd	s7,8(sp)
    80003cc8:	e062                	sd	s8,0(sp)
    80003cca:	0880                	addi	s0,sp,80
    80003ccc:	8b2a                	mv	s6,a0
    80003cce:	0001fa97          	auipc	s5,0x1f
    80003cd2:	89aa8a93          	addi	s5,s5,-1894 # 80022568 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cd6:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003cd8:	00004c17          	auipc	s8,0x4
    80003cdc:	8d0c0c13          	addi	s8,s8,-1840 # 800075a8 <etext+0x5a8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003ce0:	0001fa17          	auipc	s4,0x1f
    80003ce4:	858a0a13          	addi	s4,s4,-1960 # 80022538 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003ce8:	40000b93          	li	s7,1024
    80003cec:	a025                	j	80003d14 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003cee:	000aa603          	lw	a2,0(s5)
    80003cf2:	85ce                	mv	a1,s3
    80003cf4:	8562                	mv	a0,s8
    80003cf6:	815fc0ef          	jal	8000050a <printk>
    80003cfa:	a839                	j	80003d18 <install_trans+0x70>
    brelse(lbuf);
    80003cfc:	854a                	mv	a0,s2
    80003cfe:	8f0ff0ef          	jal	80002dee <brelse>
    brelse(dbuf);
    80003d02:	8526                	mv	a0,s1
    80003d04:	8eaff0ef          	jal	80002dee <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d08:	2985                	addiw	s3,s3,1
    80003d0a:	0a91                	addi	s5,s5,4
    80003d0c:	02ca2783          	lw	a5,44(s4)
    80003d10:	04f9d563          	bge	s3,a5,80003d5a <install_trans+0xb2>
    if (recovering) {
    80003d14:	fc0b1de3          	bnez	s6,80003cee <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003d18:	018a2583          	lw	a1,24(s4)
    80003d1c:	013585bb          	addw	a1,a1,s3
    80003d20:	2585                	addiw	a1,a1,1
    80003d22:	024a2503          	lw	a0,36(s4)
    80003d26:	fc1fe0ef          	jal	80002ce6 <bread>
    80003d2a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003d2c:	000aa583          	lw	a1,0(s5)
    80003d30:	024a2503          	lw	a0,36(s4)
    80003d34:	fb3fe0ef          	jal	80002ce6 <bread>
    80003d38:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003d3a:	865e                	mv	a2,s7
    80003d3c:	05890593          	addi	a1,s2,88
    80003d40:	05850513          	addi	a0,a0,88
    80003d44:	804fd0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003d48:	8526                	mv	a0,s1
    80003d4a:	872ff0ef          	jal	80002dbc <bwrite>
    if (recovering == 0)
    80003d4e:	fa0b17e3          	bnez	s6,80003cfc <install_trans+0x54>
      bunpin(dbuf);
    80003d52:	8526                	mv	a0,s1
    80003d54:	952ff0ef          	jal	80002ea6 <bunpin>
    80003d58:	b755                	j	80003cfc <install_trans+0x54>
}
    80003d5a:	60a6                	ld	ra,72(sp)
    80003d5c:	6406                	ld	s0,64(sp)
    80003d5e:	74e2                	ld	s1,56(sp)
    80003d60:	7942                	ld	s2,48(sp)
    80003d62:	79a2                	ld	s3,40(sp)
    80003d64:	7a02                	ld	s4,32(sp)
    80003d66:	6ae2                	ld	s5,24(sp)
    80003d68:	6b42                	ld	s6,16(sp)
    80003d6a:	6ba2                	ld	s7,8(sp)
    80003d6c:	6c02                	ld	s8,0(sp)
    80003d6e:	6161                	addi	sp,sp,80
    80003d70:	8082                	ret
    80003d72:	8082                	ret

0000000080003d74 <initlog>:
{
    80003d74:	7179                	addi	sp,sp,-48
    80003d76:	f406                	sd	ra,40(sp)
    80003d78:	f022                	sd	s0,32(sp)
    80003d7a:	ec26                	sd	s1,24(sp)
    80003d7c:	e84a                	sd	s2,16(sp)
    80003d7e:	e44e                	sd	s3,8(sp)
    80003d80:	1800                	addi	s0,sp,48
    80003d82:	84aa                	mv	s1,a0
    80003d84:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d86:	0001e917          	auipc	s2,0x1e
    80003d8a:	7b290913          	addi	s2,s2,1970 # 80022538 <log>
    80003d8e:	00004597          	auipc	a1,0x4
    80003d92:	83a58593          	addi	a1,a1,-1990 # 800075c8 <etext+0x5c8>
    80003d96:	854a                	mv	a0,s2
    80003d98:	e11fc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003d9c:	0149a583          	lw	a1,20(s3)
    80003da0:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003da4:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003da8:	8526                	mv	a0,s1
    80003daa:	f3dfe0ef          	jal	80002ce6 <bread>
  log.lh.n = lh->n;
    80003dae:	4d30                	lw	a2,88(a0)
    80003db0:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003db4:	00c05f63          	blez	a2,80003dd2 <initlog+0x5e>
    80003db8:	87aa                	mv	a5,a0
    80003dba:	0001e717          	auipc	a4,0x1e
    80003dbe:	7ae70713          	addi	a4,a4,1966 # 80022568 <log+0x30>
    80003dc2:	060a                	slli	a2,a2,0x2
    80003dc4:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003dc6:	4ff4                	lw	a3,92(a5)
    80003dc8:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003dca:	0791                	addi	a5,a5,4
    80003dcc:	0711                	addi	a4,a4,4
    80003dce:	fec79ce3          	bne	a5,a2,80003dc6 <initlog+0x52>
  brelse(buf);
    80003dd2:	81cff0ef          	jal	80002dee <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003dd6:	4505                	li	a0,1
    80003dd8:	ed1ff0ef          	jal	80003ca8 <install_trans>
  log.lh.n = 0;
    80003ddc:	0001e797          	auipc	a5,0x1e
    80003de0:	7807a423          	sw	zero,1928(a5) # 80022564 <log+0x2c>
  write_head(); // clear the log
    80003de4:	e67ff0ef          	jal	80003c4a <write_head>
}
    80003de8:	70a2                	ld	ra,40(sp)
    80003dea:	7402                	ld	s0,32(sp)
    80003dec:	64e2                	ld	s1,24(sp)
    80003dee:	6942                	ld	s2,16(sp)
    80003df0:	69a2                	ld	s3,8(sp)
    80003df2:	6145                	addi	sp,sp,48
    80003df4:	8082                	ret

0000000080003df6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003df6:	1101                	addi	sp,sp,-32
    80003df8:	ec06                	sd	ra,24(sp)
    80003dfa:	e822                	sd	s0,16(sp)
    80003dfc:	e426                	sd	s1,8(sp)
    80003dfe:	e04a                	sd	s2,0(sp)
    80003e00:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e02:	0001e517          	auipc	a0,0x1e
    80003e06:	73650513          	addi	a0,a0,1846 # 80022538 <log>
    80003e0a:	e1ffc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80003e0e:	0001e497          	auipc	s1,0x1e
    80003e12:	72a48493          	addi	s1,s1,1834 # 80022538 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003e16:	4979                	li	s2,30
    80003e18:	a821                	j	80003e30 <begin_op+0x3a>
      sleep_prepare(&log);
    80003e1a:	8526                	mv	a0,s1
    80003e1c:	a06fe0ef          	jal	80002022 <sleep_prepare>
      release(&log.lock);
    80003e20:	8526                	mv	a0,s1
    80003e22:	e8ffc0ef          	jal	80000cb0 <release>
      sleep();
    80003e26:	a38fe0ef          	jal	8000205e <sleep>
      acquire(&log.lock);
    80003e2a:	8526                	mv	a0,s1
    80003e2c:	dfdfc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80003e30:	509c                	lw	a5,32(s1)
    80003e32:	f7e5                	bnez	a5,80003e1a <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003e34:	4cd8                	lw	a4,28(s1)
    80003e36:	2705                	addiw	a4,a4,1
    80003e38:	0027179b          	slliw	a5,a4,0x2
    80003e3c:	9fb9                	addw	a5,a5,a4
    80003e3e:	0017979b          	slliw	a5,a5,0x1
    80003e42:	54d4                	lw	a3,44(s1)
    80003e44:	9fb5                	addw	a5,a5,a3
    80003e46:	00f95e63          	bge	s2,a5,80003e62 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003e4a:	8526                	mv	a0,s1
    80003e4c:	9d6fe0ef          	jal	80002022 <sleep_prepare>
      release(&log.lock);
    80003e50:	8526                	mv	a0,s1
    80003e52:	e5ffc0ef          	jal	80000cb0 <release>
      sleep();
    80003e56:	a08fe0ef          	jal	8000205e <sleep>
      acquire(&log.lock);
    80003e5a:	8526                	mv	a0,s1
    80003e5c:	dcdfc0ef          	jal	80000c28 <acquire>
    80003e60:	bfc1                	j	80003e30 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003e62:	0001e797          	auipc	a5,0x1e
    80003e66:	6ee7a923          	sw	a4,1778(a5) # 80022554 <log+0x1c>
      release(&log.lock);
    80003e6a:	0001e517          	auipc	a0,0x1e
    80003e6e:	6ce50513          	addi	a0,a0,1742 # 80022538 <log>
    80003e72:	e3ffc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80003e76:	60e2                	ld	ra,24(sp)
    80003e78:	6442                	ld	s0,16(sp)
    80003e7a:	64a2                	ld	s1,8(sp)
    80003e7c:	6902                	ld	s2,0(sp)
    80003e7e:	6105                	addi	sp,sp,32
    80003e80:	8082                	ret

0000000080003e82 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e82:	7139                	addi	sp,sp,-64
    80003e84:	fc06                	sd	ra,56(sp)
    80003e86:	f822                	sd	s0,48(sp)
    80003e88:	f426                	sd	s1,40(sp)
    80003e8a:	f04a                	sd	s2,32(sp)
    80003e8c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e8e:	0001e497          	auipc	s1,0x1e
    80003e92:	6aa48493          	addi	s1,s1,1706 # 80022538 <log>
    80003e96:	8526                	mv	a0,s1
    80003e98:	d91fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003e9c:	4cdc                	lw	a5,28(s1)
    80003e9e:	37fd                	addiw	a5,a5,-1
    80003ea0:	893e                	mv	s2,a5
    80003ea2:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003ea4:	509c                	lw	a5,32(s1)
    80003ea6:	e3b1                	bnez	a5,80003eea <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003ea8:	04091a63          	bnez	s2,80003efc <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003eac:	0001e497          	auipc	s1,0x1e
    80003eb0:	68c48493          	addi	s1,s1,1676 # 80022538 <log>
    80003eb4:	4785                	li	a5,1
    80003eb6:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003eb8:	8526                	mv	a0,s1
    80003eba:	df7fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ebe:	54dc                	lw	a5,44(s1)
    80003ec0:	06f04063          	bgtz	a5,80003f20 <end_op+0x9e>
    acquire(&log.lock);
    80003ec4:	0001e497          	auipc	s1,0x1e
    80003ec8:	67448493          	addi	s1,s1,1652 # 80022538 <log>
    80003ecc:	8526                	mv	a0,s1
    80003ece:	d5bfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003ed2:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003ed6:	549c                	lw	a5,40(s1)
    80003ed8:	2785                	addiw	a5,a5,1
    80003eda:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003edc:	8526                	mv	a0,s1
    80003ede:	9b0fe0ef          	jal	8000208e <wakeup>
    release(&log.lock);
    80003ee2:	8526                	mv	a0,s1
    80003ee4:	dcdfc0ef          	jal	80000cb0 <release>
}
    80003ee8:	a035                	j	80003f14 <end_op+0x92>
    80003eea:	ec4e                	sd	s3,24(sp)
    80003eec:	e852                	sd	s4,16(sp)
    80003eee:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003ef0:	00003517          	auipc	a0,0x3
    80003ef4:	6e050513          	addi	a0,a0,1760 # 800075d0 <etext+0x5d0>
    80003ef8:	93dfc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003efc:	0001e517          	auipc	a0,0x1e
    80003f00:	63c50513          	addi	a0,a0,1596 # 80022538 <log>
    80003f04:	98afe0ef          	jal	8000208e <wakeup>
  release(&log.lock);
    80003f08:	0001e517          	auipc	a0,0x1e
    80003f0c:	63050513          	addi	a0,a0,1584 # 80022538 <log>
    80003f10:	da1fc0ef          	jal	80000cb0 <release>
}
    80003f14:	70e2                	ld	ra,56(sp)
    80003f16:	7442                	ld	s0,48(sp)
    80003f18:	74a2                	ld	s1,40(sp)
    80003f1a:	7902                	ld	s2,32(sp)
    80003f1c:	6121                	addi	sp,sp,64
    80003f1e:	8082                	ret
    80003f20:	ec4e                	sd	s3,24(sp)
    80003f22:	e852                	sd	s4,16(sp)
    80003f24:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f26:	0001ea97          	auipc	s5,0x1e
    80003f2a:	642a8a93          	addi	s5,s5,1602 # 80022568 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003f2e:	0001ea17          	auipc	s4,0x1e
    80003f32:	60aa0a13          	addi	s4,s4,1546 # 80022538 <log>
    80003f36:	018a2583          	lw	a1,24(s4)
    80003f3a:	012585bb          	addw	a1,a1,s2
    80003f3e:	2585                	addiw	a1,a1,1
    80003f40:	024a2503          	lw	a0,36(s4)
    80003f44:	da3fe0ef          	jal	80002ce6 <bread>
    80003f48:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003f4a:	000aa583          	lw	a1,0(s5)
    80003f4e:	024a2503          	lw	a0,36(s4)
    80003f52:	d95fe0ef          	jal	80002ce6 <bread>
    80003f56:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f58:	40000613          	li	a2,1024
    80003f5c:	05850593          	addi	a1,a0,88
    80003f60:	05848513          	addi	a0,s1,88
    80003f64:	de5fc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    80003f68:	8526                	mv	a0,s1
    80003f6a:	e53fe0ef          	jal	80002dbc <bwrite>
    brelse(from);
    80003f6e:	854e                	mv	a0,s3
    80003f70:	e7ffe0ef          	jal	80002dee <brelse>
    brelse(to);
    80003f74:	8526                	mv	a0,s1
    80003f76:	e79fe0ef          	jal	80002dee <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f7a:	2905                	addiw	s2,s2,1
    80003f7c:	0a91                	addi	s5,s5,4
    80003f7e:	02ca2783          	lw	a5,44(s4)
    80003f82:	faf94ae3          	blt	s2,a5,80003f36 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003f86:	cc5ff0ef          	jal	80003c4a <write_head>
    install_trans(0); // Now install writes to home locations
    80003f8a:	4501                	li	a0,0
    80003f8c:	d1dff0ef          	jal	80003ca8 <install_trans>
    log.lh.n = 0;
    80003f90:	0001e797          	auipc	a5,0x1e
    80003f94:	5c07aa23          	sw	zero,1492(a5) # 80022564 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003f98:	cb3ff0ef          	jal	80003c4a <write_head>
    80003f9c:	69e2                	ld	s3,24(sp)
    80003f9e:	6a42                	ld	s4,16(sp)
    80003fa0:	6aa2                	ld	s5,8(sp)
    80003fa2:	b70d                	j	80003ec4 <end_op+0x42>

0000000080003fa4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003fa4:	1101                	addi	sp,sp,-32
    80003fa6:	ec06                	sd	ra,24(sp)
    80003fa8:	e822                	sd	s0,16(sp)
    80003faa:	e426                	sd	s1,8(sp)
    80003fac:	1000                	addi	s0,sp,32
    80003fae:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003fb0:	0001e517          	auipc	a0,0x1e
    80003fb4:	58850513          	addi	a0,a0,1416 # 80022538 <log>
    80003fb8:	c71fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003fbc:	0001e617          	auipc	a2,0x1e
    80003fc0:	5a862603          	lw	a2,1448(a2) # 80022564 <log+0x2c>
    80003fc4:	47f5                	li	a5,29
    80003fc6:	04c7cd63          	blt	a5,a2,80004020 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003fca:	0001e797          	auipc	a5,0x1e
    80003fce:	58a7a783          	lw	a5,1418(a5) # 80022554 <log+0x1c>
    80003fd2:	04f05d63          	blez	a5,8000402c <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003fd6:	4781                	li	a5,0
    80003fd8:	06c05063          	blez	a2,80004038 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003fdc:	44cc                	lw	a1,12(s1)
    80003fde:	0001e717          	auipc	a4,0x1e
    80003fe2:	58a70713          	addi	a4,a4,1418 # 80022568 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003fe6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003fe8:	4314                	lw	a3,0(a4)
    80003fea:	04b68763          	beq	a3,a1,80004038 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003fee:	2785                	addiw	a5,a5,1
    80003ff0:	0711                	addi	a4,a4,4
    80003ff2:	fef61be3          	bne	a2,a5,80003fe8 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003ff6:	060a                	slli	a2,a2,0x2
    80003ff8:	02060613          	addi	a2,a2,32
    80003ffc:	0001e797          	auipc	a5,0x1e
    80004000:	53c78793          	addi	a5,a5,1340 # 80022538 <log>
    80004004:	97b2                	add	a5,a5,a2
    80004006:	44d8                	lw	a4,12(s1)
    80004008:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    8000400a:	8526                	mv	a0,s1
    8000400c:	e67fe0ef          	jal	80002e72 <bpin>
    log.lh.n++;
    80004010:	0001e717          	auipc	a4,0x1e
    80004014:	52870713          	addi	a4,a4,1320 # 80022538 <log>
    80004018:	575c                	lw	a5,44(a4)
    8000401a:	2785                	addiw	a5,a5,1
    8000401c:	d75c                	sw	a5,44(a4)
    8000401e:	a815                	j	80004052 <log_write+0xae>
    panic("too big a transaction");
    80004020:	00003517          	auipc	a0,0x3
    80004024:	5c050513          	addi	a0,a0,1472 # 800075e0 <etext+0x5e0>
    80004028:	80dfc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    8000402c:	00003517          	auipc	a0,0x3
    80004030:	5cc50513          	addi	a0,a0,1484 # 800075f8 <etext+0x5f8>
    80004034:	801fc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    80004038:	00279693          	slli	a3,a5,0x2
    8000403c:	02068693          	addi	a3,a3,32
    80004040:	0001e717          	auipc	a4,0x1e
    80004044:	4f870713          	addi	a4,a4,1272 # 80022538 <log>
    80004048:	9736                	add	a4,a4,a3
    8000404a:	44d4                	lw	a3,12(s1)
    8000404c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    8000404e:	faf60ee3          	beq	a2,a5,8000400a <log_write+0x66>
  }
  release(&log.lock);
    80004052:	0001e517          	auipc	a0,0x1e
    80004056:	4e650513          	addi	a0,a0,1254 # 80022538 <log>
    8000405a:	c57fc0ef          	jal	80000cb0 <release>
}
    8000405e:	60e2                	ld	ra,24(sp)
    80004060:	6442                	ld	s0,16(sp)
    80004062:	64a2                	ld	s1,8(sp)
    80004064:	6105                	addi	sp,sp,32
    80004066:	8082                	ret

0000000080004068 <sys_sync>:

uint64
sys_sync(void)
{
    80004068:	1101                	addi	sp,sp,-32
    8000406a:	ec06                	sd	ra,24(sp)
    8000406c:	e822                	sd	s0,16(sp)
    8000406e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004070:	0001e517          	auipc	a0,0x1e
    80004074:	4c850513          	addi	a0,a0,1224 # 80022538 <log>
    80004078:	bb1fc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    8000407c:	0001e797          	auipc	a5,0x1e
    80004080:	4dc7a783          	lw	a5,1244(a5) # 80022558 <log+0x20>
    80004084:	e799                	bnez	a5,80004092 <sys_sync+0x2a>
    80004086:	0001e797          	auipc	a5,0x1e
    8000408a:	4ce7a783          	lw	a5,1230(a5) # 80022554 <log+0x1c>
    8000408e:	02f05c63          	blez	a5,800040c6 <sys_sync+0x5e>
    80004092:	e426                	sd	s1,8(sp)
    80004094:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80004096:	0001e917          	auipc	s2,0x1e
    8000409a:	4ca92903          	lw	s2,1226(s2) # 80022560 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    8000409e:	0001e497          	auipc	s1,0x1e
    800040a2:	49a48493          	addi	s1,s1,1178 # 80022538 <log>
    800040a6:	8526                	mv	a0,s1
    800040a8:	f7bfd0ef          	jal	80002022 <sleep_prepare>
      release(&log.lock);
    800040ac:	8526                	mv	a0,s1
    800040ae:	c03fc0ef          	jal	80000cb0 <release>
      sleep();
    800040b2:	fadfd0ef          	jal	8000205e <sleep>
      acquire(&log.lock);
    800040b6:	8526                	mv	a0,s1
    800040b8:	b71fc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    800040bc:	549c                	lw	a5,40(s1)
    800040be:	fef954e3          	bge	s2,a5,800040a6 <sys_sync+0x3e>
    800040c2:	64a2                	ld	s1,8(sp)
    800040c4:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    800040c6:	0001e517          	auipc	a0,0x1e
    800040ca:	47250513          	addi	a0,a0,1138 # 80022538 <log>
    800040ce:	be3fc0ef          	jal	80000cb0 <release>
  return 0;
}
    800040d2:	4501                	li	a0,0
    800040d4:	60e2                	ld	ra,24(sp)
    800040d6:	6442                	ld	s0,16(sp)
    800040d8:	6105                	addi	sp,sp,32
    800040da:	8082                	ret

00000000800040dc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800040dc:	1101                	addi	sp,sp,-32
    800040de:	ec06                	sd	ra,24(sp)
    800040e0:	e822                	sd	s0,16(sp)
    800040e2:	e426                	sd	s1,8(sp)
    800040e4:	e04a                	sd	s2,0(sp)
    800040e6:	1000                	addi	s0,sp,32
    800040e8:	84aa                	mv	s1,a0
    800040ea:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800040ec:	00003597          	auipc	a1,0x3
    800040f0:	52c58593          	addi	a1,a1,1324 # 80007618 <etext+0x618>
    800040f4:	0521                	addi	a0,a0,8
    800040f6:	ab3fc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    800040fa:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800040fe:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004102:	0204a423          	sw	zero,40(s1)
}
    80004106:	60e2                	ld	ra,24(sp)
    80004108:	6442                	ld	s0,16(sp)
    8000410a:	64a2                	ld	s1,8(sp)
    8000410c:	6902                	ld	s2,0(sp)
    8000410e:	6105                	addi	sp,sp,32
    80004110:	8082                	ret

0000000080004112 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004112:	1101                	addi	sp,sp,-32
    80004114:	ec06                	sd	ra,24(sp)
    80004116:	e822                	sd	s0,16(sp)
    80004118:	e426                	sd	s1,8(sp)
    8000411a:	e04a                	sd	s2,0(sp)
    8000411c:	1000                	addi	s0,sp,32
    8000411e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004120:	00850913          	addi	s2,a0,8
    80004124:	854a                	mv	a0,s2
    80004126:	b03fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    8000412a:	409c                	lw	a5,0(s1)
    8000412c:	cf91                	beqz	a5,80004148 <acquiresleep+0x36>
    sleep_prepare(lk);
    8000412e:	8526                	mv	a0,s1
    80004130:	ef3fd0ef          	jal	80002022 <sleep_prepare>
    release(&lk->lk);
    80004134:	854a                	mv	a0,s2
    80004136:	b7bfc0ef          	jal	80000cb0 <release>
    sleep();
    8000413a:	f25fd0ef          	jal	8000205e <sleep>
    acquire(&lk->lk);
    8000413e:	854a                	mv	a0,s2
    80004140:	ae9fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004144:	409c                	lw	a5,0(s1)
    80004146:	f7e5                	bnez	a5,8000412e <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004148:	4785                	li	a5,1
    8000414a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000414c:	8cdfd0ef          	jal	80001a18 <myproc>
    80004150:	591c                	lw	a5,48(a0)
    80004152:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004154:	854a                	mv	a0,s2
    80004156:	b5bfc0ef          	jal	80000cb0 <release>
}
    8000415a:	60e2                	ld	ra,24(sp)
    8000415c:	6442                	ld	s0,16(sp)
    8000415e:	64a2                	ld	s1,8(sp)
    80004160:	6902                	ld	s2,0(sp)
    80004162:	6105                	addi	sp,sp,32
    80004164:	8082                	ret

0000000080004166 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004166:	1101                	addi	sp,sp,-32
    80004168:	ec06                	sd	ra,24(sp)
    8000416a:	e822                	sd	s0,16(sp)
    8000416c:	e426                	sd	s1,8(sp)
    8000416e:	e04a                	sd	s2,0(sp)
    80004170:	1000                	addi	s0,sp,32
    80004172:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004174:	00850913          	addi	s2,a0,8
    80004178:	854a                	mv	a0,s2
    8000417a:	aaffc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    8000417e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004182:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004186:	8526                	mv	a0,s1
    80004188:	f07fd0ef          	jal	8000208e <wakeup>
  release(&lk->lk);
    8000418c:	854a                	mv	a0,s2
    8000418e:	b23fc0ef          	jal	80000cb0 <release>
}
    80004192:	60e2                	ld	ra,24(sp)
    80004194:	6442                	ld	s0,16(sp)
    80004196:	64a2                	ld	s1,8(sp)
    80004198:	6902                	ld	s2,0(sp)
    8000419a:	6105                	addi	sp,sp,32
    8000419c:	8082                	ret

000000008000419e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000419e:	7179                	addi	sp,sp,-48
    800041a0:	f406                	sd	ra,40(sp)
    800041a2:	f022                	sd	s0,32(sp)
    800041a4:	ec26                	sd	s1,24(sp)
    800041a6:	e84a                	sd	s2,16(sp)
    800041a8:	1800                	addi	s0,sp,48
    800041aa:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800041ac:	00850913          	addi	s2,a0,8
    800041b0:	854a                	mv	a0,s2
    800041b2:	a77fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800041b6:	409c                	lw	a5,0(s1)
    800041b8:	ef81                	bnez	a5,800041d0 <holdingsleep+0x32>
    800041ba:	4481                	li	s1,0
  release(&lk->lk);
    800041bc:	854a                	mv	a0,s2
    800041be:	af3fc0ef          	jal	80000cb0 <release>
  return r;
}
    800041c2:	8526                	mv	a0,s1
    800041c4:	70a2                	ld	ra,40(sp)
    800041c6:	7402                	ld	s0,32(sp)
    800041c8:	64e2                	ld	s1,24(sp)
    800041ca:	6942                	ld	s2,16(sp)
    800041cc:	6145                	addi	sp,sp,48
    800041ce:	8082                	ret
    800041d0:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800041d2:	0284a983          	lw	s3,40(s1)
    800041d6:	843fd0ef          	jal	80001a18 <myproc>
    800041da:	5904                	lw	s1,48(a0)
    800041dc:	413484b3          	sub	s1,s1,s3
    800041e0:	0014b493          	seqz	s1,s1
    800041e4:	69a2                	ld	s3,8(sp)
    800041e6:	bfd9                	j	800041bc <holdingsleep+0x1e>

00000000800041e8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800041e8:	1141                	addi	sp,sp,-16
    800041ea:	e406                	sd	ra,8(sp)
    800041ec:	e022                	sd	s0,0(sp)
    800041ee:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800041f0:	00003597          	auipc	a1,0x3
    800041f4:	43858593          	addi	a1,a1,1080 # 80007628 <etext+0x628>
    800041f8:	0001e517          	auipc	a0,0x1e
    800041fc:	48850513          	addi	a0,a0,1160 # 80022680 <ftable>
    80004200:	9a9fc0ef          	jal	80000ba8 <initlock>
}
    80004204:	60a2                	ld	ra,8(sp)
    80004206:	6402                	ld	s0,0(sp)
    80004208:	0141                	addi	sp,sp,16
    8000420a:	8082                	ret

000000008000420c <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    8000420c:	1101                	addi	sp,sp,-32
    8000420e:	ec06                	sd	ra,24(sp)
    80004210:	e822                	sd	s0,16(sp)
    80004212:	e426                	sd	s1,8(sp)
    80004214:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004216:	0001e517          	auipc	a0,0x1e
    8000421a:	46a50513          	addi	a0,a0,1130 # 80022680 <ftable>
    8000421e:	a0bfc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004222:	0001e497          	auipc	s1,0x1e
    80004226:	47648493          	addi	s1,s1,1142 # 80022698 <ftable+0x18>
    8000422a:	0001f717          	auipc	a4,0x1f
    8000422e:	40e70713          	addi	a4,a4,1038 # 80023638 <disk>
    if (f->ref == 0) {
    80004232:	40dc                	lw	a5,4(s1)
    80004234:	cf89                	beqz	a5,8000424e <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004236:	02848493          	addi	s1,s1,40
    8000423a:	fee49ce3          	bne	s1,a4,80004232 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000423e:	0001e517          	auipc	a0,0x1e
    80004242:	44250513          	addi	a0,a0,1090 # 80022680 <ftable>
    80004246:	a6bfc0ef          	jal	80000cb0 <release>
  return 0;
    8000424a:	4481                	li	s1,0
    8000424c:	a809                	j	8000425e <filealloc+0x52>
      f->ref = 1;
    8000424e:	4785                	li	a5,1
    80004250:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004252:	0001e517          	auipc	a0,0x1e
    80004256:	42e50513          	addi	a0,a0,1070 # 80022680 <ftable>
    8000425a:	a57fc0ef          	jal	80000cb0 <release>
}
    8000425e:	8526                	mv	a0,s1
    80004260:	60e2                	ld	ra,24(sp)
    80004262:	6442                	ld	s0,16(sp)
    80004264:	64a2                	ld	s1,8(sp)
    80004266:	6105                	addi	sp,sp,32
    80004268:	8082                	ret

000000008000426a <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    8000426a:	1101                	addi	sp,sp,-32
    8000426c:	ec06                	sd	ra,24(sp)
    8000426e:	e822                	sd	s0,16(sp)
    80004270:	e426                	sd	s1,8(sp)
    80004272:	1000                	addi	s0,sp,32
    80004274:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004276:	0001e517          	auipc	a0,0x1e
    8000427a:	40a50513          	addi	a0,a0,1034 # 80022680 <ftable>
    8000427e:	9abfc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    80004282:	40dc                	lw	a5,4(s1)
    80004284:	02f05063          	blez	a5,800042a4 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004288:	2785                	addiw	a5,a5,1
    8000428a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000428c:	0001e517          	auipc	a0,0x1e
    80004290:	3f450513          	addi	a0,a0,1012 # 80022680 <ftable>
    80004294:	a1dfc0ef          	jal	80000cb0 <release>
  return f;
}
    80004298:	8526                	mv	a0,s1
    8000429a:	60e2                	ld	ra,24(sp)
    8000429c:	6442                	ld	s0,16(sp)
    8000429e:	64a2                	ld	s1,8(sp)
    800042a0:	6105                	addi	sp,sp,32
    800042a2:	8082                	ret
    panic("filedup");
    800042a4:	00003517          	auipc	a0,0x3
    800042a8:	38c50513          	addi	a0,a0,908 # 80007630 <etext+0x630>
    800042ac:	d88fc0ef          	jal	80000834 <panic>

00000000800042b0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800042b0:	7139                	addi	sp,sp,-64
    800042b2:	fc06                	sd	ra,56(sp)
    800042b4:	f822                	sd	s0,48(sp)
    800042b6:	f426                	sd	s1,40(sp)
    800042b8:	0080                	addi	s0,sp,64
    800042ba:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800042bc:	0001e517          	auipc	a0,0x1e
    800042c0:	3c450513          	addi	a0,a0,964 # 80022680 <ftable>
    800042c4:	965fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800042c8:	40dc                	lw	a5,4(s1)
    800042ca:	04f05a63          	blez	a5,8000431e <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    800042ce:	37fd                	addiw	a5,a5,-1
    800042d0:	c0dc                	sw	a5,4(s1)
    800042d2:	06f04063          	bgtz	a5,80004332 <fileclose+0x82>
    800042d6:	f04a                	sd	s2,32(sp)
    800042d8:	ec4e                	sd	s3,24(sp)
    800042da:	e852                	sd	s4,16(sp)
    800042dc:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800042de:	0004a903          	lw	s2,0(s1)
    800042e2:	0094c783          	lbu	a5,9(s1)
    800042e6:	89be                	mv	s3,a5
    800042e8:	689c                	ld	a5,16(s1)
    800042ea:	8a3e                	mv	s4,a5
    800042ec:	6c9c                	ld	a5,24(s1)
    800042ee:	8abe                	mv	s5,a5
  f->ref = 0;
    800042f0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800042f4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800042f8:	0001e517          	auipc	a0,0x1e
    800042fc:	38850513          	addi	a0,a0,904 # 80022680 <ftable>
    80004300:	9b1fc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    80004304:	4785                	li	a5,1
    80004306:	04f90163          	beq	s2,a5,80004348 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    8000430a:	ffe9079b          	addiw	a5,s2,-2
    8000430e:	4705                	li	a4,1
    80004310:	04f77563          	bgeu	a4,a5,8000435a <fileclose+0xaa>
    80004314:	7902                	ld	s2,32(sp)
    80004316:	69e2                	ld	s3,24(sp)
    80004318:	6a42                	ld	s4,16(sp)
    8000431a:	6aa2                	ld	s5,8(sp)
    8000431c:	a00d                	j	8000433e <fileclose+0x8e>
    8000431e:	f04a                	sd	s2,32(sp)
    80004320:	ec4e                	sd	s3,24(sp)
    80004322:	e852                	sd	s4,16(sp)
    80004324:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004326:	00003517          	auipc	a0,0x3
    8000432a:	31250513          	addi	a0,a0,786 # 80007638 <etext+0x638>
    8000432e:	d06fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    80004332:	0001e517          	auipc	a0,0x1e
    80004336:	34e50513          	addi	a0,a0,846 # 80022680 <ftable>
    8000433a:	977fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000433e:	70e2                	ld	ra,56(sp)
    80004340:	7442                	ld	s0,48(sp)
    80004342:	74a2                	ld	s1,40(sp)
    80004344:	6121                	addi	sp,sp,64
    80004346:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004348:	85ce                	mv	a1,s3
    8000434a:	8552                	mv	a0,s4
    8000434c:	36a000ef          	jal	800046b6 <pipeclose>
    80004350:	7902                	ld	s2,32(sp)
    80004352:	69e2                	ld	s3,24(sp)
    80004354:	6a42                	ld	s4,16(sp)
    80004356:	6aa2                	ld	s5,8(sp)
    80004358:	b7dd                	j	8000433e <fileclose+0x8e>
    begin_op();
    8000435a:	a9dff0ef          	jal	80003df6 <begin_op>
    iput(ff.ip);
    8000435e:	8556                	mv	a0,s5
    80004360:	9a0ff0ef          	jal	80003500 <iput>
    end_op();
    80004364:	b1fff0ef          	jal	80003e82 <end_op>
    80004368:	7902                	ld	s2,32(sp)
    8000436a:	69e2                	ld	s3,24(sp)
    8000436c:	6a42                	ld	s4,16(sp)
    8000436e:	6aa2                	ld	s5,8(sp)
    80004370:	b7f9                	j	8000433e <fileclose+0x8e>

0000000080004372 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004372:	715d                	addi	sp,sp,-80
    80004374:	e486                	sd	ra,72(sp)
    80004376:	e0a2                	sd	s0,64(sp)
    80004378:	fc26                	sd	s1,56(sp)
    8000437a:	f052                	sd	s4,32(sp)
    8000437c:	0880                	addi	s0,sp,80
    8000437e:	84aa                	mv	s1,a0
    80004380:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004382:	e96fd0ef          	jal	80001a18 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004386:	409c                	lw	a5,0(s1)
    80004388:	37f9                	addiw	a5,a5,-2
    8000438a:	4705                	li	a4,1
    8000438c:	04f76963          	bltu	a4,a5,800043de <filestat+0x6c>
    80004390:	f84a                	sd	s2,48(sp)
    80004392:	f44e                	sd	s3,40(sp)
    80004394:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    80004396:	fb840993          	addi	s3,s0,-72
    8000439a:	4661                	li	a2,24
    8000439c:	4581                	li	a1,0
    8000439e:	854e                	mv	a0,s3
    800043a0:	949fc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    800043a4:	6c88                	ld	a0,24(s1)
    800043a6:	fd9fe0ef          	jal	8000337e <ilock>
    stati(f->ip, &st);
    800043aa:	85ce                	mv	a1,s3
    800043ac:	6c88                	ld	a0,24(s1)
    800043ae:	b7cff0ef          	jal	8000372a <stati>
    iunlock(f->ip);
    800043b2:	6c88                	ld	a0,24(s1)
    800043b4:	878ff0ef          	jal	8000342c <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    800043b8:	4761                	li	a4,24
    800043ba:	86ce                	mv	a3,s3
    800043bc:	8652                	mv	a2,s4
    800043be:	04893583          	ld	a1,72(s2)
    800043c2:	05093503          	ld	a0,80(s2)
    800043c6:	9bcfd0ef          	jal	80001582 <copyout>
    800043ca:	41f5551b          	sraiw	a0,a0,0x1f
    800043ce:	7942                	ld	s2,48(sp)
    800043d0:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800043d2:	60a6                	ld	ra,72(sp)
    800043d4:	6406                	ld	s0,64(sp)
    800043d6:	74e2                	ld	s1,56(sp)
    800043d8:	7a02                	ld	s4,32(sp)
    800043da:	6161                	addi	sp,sp,80
    800043dc:	8082                	ret
  return -1;
    800043de:	557d                	li	a0,-1
    800043e0:	bfcd                	j	800043d2 <filestat+0x60>

00000000800043e2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800043e2:	7179                	addi	sp,sp,-48
    800043e4:	f406                	sd	ra,40(sp)
    800043e6:	f022                	sd	s0,32(sp)
    800043e8:	e84a                	sd	s2,16(sp)
    800043ea:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    800043ec:	00854783          	lbu	a5,8(a0)
    800043f0:	c3dd                	beqz	a5,80004496 <fileread+0xb4>
    800043f2:	ec26                	sd	s1,24(sp)
    800043f4:	e44e                	sd	s3,8(sp)
    800043f6:	84aa                	mv	s1,a0
    800043f8:	892e                	mv	s2,a1
    800043fa:	89b2                	mv	s3,a2
    800043fc:	01f6579b          	srliw	a5,a2,0x1f
    80004400:	ebc9                	bnez	a5,80004492 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    80004402:	411c                	lw	a5,0(a0)
    80004404:	4705                	li	a4,1
    80004406:	04e78363          	beq	a5,a4,8000444c <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000440a:	470d                	li	a4,3
    8000440c:	04e78763          	beq	a5,a4,8000445a <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004410:	4709                	li	a4,2
    80004412:	06e79a63          	bne	a5,a4,80004486 <fileread+0xa4>
    ilock(f->ip);
    80004416:	6d08                	ld	a0,24(a0)
    80004418:	f67fe0ef          	jal	8000337e <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000441c:	874e                	mv	a4,s3
    8000441e:	5094                	lw	a3,32(s1)
    80004420:	864a                	mv	a2,s2
    80004422:	4585                	li	a1,1
    80004424:	6c88                	ld	a0,24(s1)
    80004426:	b32ff0ef          	jal	80003758 <readi>
    8000442a:	892a                	mv	s2,a0
    8000442c:	00a05563          	blez	a0,80004436 <fileread+0x54>
      f->off += r;
    80004430:	509c                	lw	a5,32(s1)
    80004432:	9fa9                	addw	a5,a5,a0
    80004434:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004436:	6c88                	ld	a0,24(s1)
    80004438:	ff5fe0ef          	jal	8000342c <iunlock>
    8000443c:	64e2                	ld	s1,24(sp)
    8000443e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004440:	854a                	mv	a0,s2
    80004442:	70a2                	ld	ra,40(sp)
    80004444:	7402                	ld	s0,32(sp)
    80004446:	6942                	ld	s2,16(sp)
    80004448:	6145                	addi	sp,sp,48
    8000444a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000444c:	6908                	ld	a0,16(a0)
    8000444e:	3e2000ef          	jal	80004830 <piperead>
    80004452:	892a                	mv	s2,a0
    80004454:	64e2                	ld	s1,24(sp)
    80004456:	69a2                	ld	s3,8(sp)
    80004458:	b7e5                	j	80004440 <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000445a:	02451783          	lh	a5,36(a0)
    8000445e:	03079693          	slli	a3,a5,0x30
    80004462:	92c1                	srli	a3,a3,0x30
    80004464:	4725                	li	a4,9
    80004466:	02d76b63          	bltu	a4,a3,8000449c <fileread+0xba>
    8000446a:	0792                	slli	a5,a5,0x4
    8000446c:	0001e717          	auipc	a4,0x1e
    80004470:	17470713          	addi	a4,a4,372 # 800225e0 <devsw>
    80004474:	97ba                	add	a5,a5,a4
    80004476:	639c                	ld	a5,0(a5)
    80004478:	c79d                	beqz	a5,800044a6 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    8000447a:	4505                	li	a0,1
    8000447c:	9782                	jalr	a5
    8000447e:	892a                	mv	s2,a0
    80004480:	64e2                	ld	s1,24(sp)
    80004482:	69a2                	ld	s3,8(sp)
    80004484:	bf75                	j	80004440 <fileread+0x5e>
    panic("fileread");
    80004486:	00003517          	auipc	a0,0x3
    8000448a:	1c250513          	addi	a0,a0,450 # 80007648 <etext+0x648>
    8000448e:	ba6fc0ef          	jal	80000834 <panic>
    80004492:	64e2                	ld	s1,24(sp)
    80004494:	69a2                	ld	s3,8(sp)
    return -1;
    80004496:	57fd                	li	a5,-1
    80004498:	893e                	mv	s2,a5
    8000449a:	b75d                	j	80004440 <fileread+0x5e>
      return -1;
    8000449c:	57fd                	li	a5,-1
    8000449e:	893e                	mv	s2,a5
    800044a0:	64e2                	ld	s1,24(sp)
    800044a2:	69a2                	ld	s3,8(sp)
    800044a4:	bf71                	j	80004440 <fileread+0x5e>
    800044a6:	57fd                	li	a5,-1
    800044a8:	893e                	mv	s2,a5
    800044aa:	64e2                	ld	s1,24(sp)
    800044ac:	69a2                	ld	s3,8(sp)
    800044ae:	bf49                	j	80004440 <fileread+0x5e>

00000000800044b0 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    800044b0:	00954783          	lbu	a5,9(a0)
    800044b4:	12078b63          	beqz	a5,800045ea <filewrite+0x13a>
{
    800044b8:	711d                	addi	sp,sp,-96
    800044ba:	ec86                	sd	ra,88(sp)
    800044bc:	e8a2                	sd	s0,80(sp)
    800044be:	e0ca                	sd	s2,64(sp)
    800044c0:	f456                	sd	s5,40(sp)
    800044c2:	f05a                	sd	s6,32(sp)
    800044c4:	1080                	addi	s0,sp,96
    800044c6:	892a                	mv	s2,a0
    800044c8:	8b2e                	mv	s6,a1
    800044ca:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    800044cc:	01f6579b          	srliw	a5,a2,0x1f
    800044d0:	0e079d63          	bnez	a5,800045ca <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    800044d4:	411c                	lw	a5,0(a0)
    800044d6:	4705                	li	a4,1
    800044d8:	02e78a63          	beq	a5,a4,8000450c <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800044dc:	470d                	li	a4,3
    800044de:	02e78b63          	beq	a5,a4,80004514 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    800044e2:	4709                	li	a4,2
    800044e4:	0ce79763          	bne	a5,a4,800045b2 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    800044e8:	0ec05763          	blez	a2,800045d6 <filewrite+0x126>
    800044ec:	e4a6                	sd	s1,72(sp)
    800044ee:	fc4e                	sd	s3,56(sp)
    800044f0:	f852                	sd	s4,48(sp)
    800044f2:	ec5e                	sd	s7,24(sp)
    800044f4:	e862                	sd	s8,16(sp)
    800044f6:	e466                	sd	s9,8(sp)
    int i = 0;
    800044f8:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    800044fa:	6b85                	lui	s7,0x1
    800044fc:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004500:	6785                	lui	a5,0x1
    80004502:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004506:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004508:	4c05                	li	s8,1
    8000450a:	a8ad                	j	80004584 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    8000450c:	6908                	ld	a0,16(a0)
    8000450e:	206000ef          	jal	80004714 <pipewrite>
    80004512:	a849                	j	800045a4 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004514:	02451783          	lh	a5,36(a0)
    80004518:	03079693          	slli	a3,a5,0x30
    8000451c:	92c1                	srli	a3,a3,0x30
    8000451e:	4725                	li	a4,9
    80004520:	0ad76763          	bltu	a4,a3,800045ce <filewrite+0x11e>
    80004524:	0792                	slli	a5,a5,0x4
    80004526:	0001e717          	auipc	a4,0x1e
    8000452a:	0ba70713          	addi	a4,a4,186 # 800225e0 <devsw>
    8000452e:	97ba                	add	a5,a5,a4
    80004530:	679c                	ld	a5,8(a5)
    80004532:	c3c5                	beqz	a5,800045d2 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004534:	4505                	li	a0,1
    80004536:	9782                	jalr	a5
    80004538:	a0b5                	j	800045a4 <filewrite+0xf4>
      if (n1 > max)
    8000453a:	2981                	sext.w	s3,s3
      begin_op();
    8000453c:	8bbff0ef          	jal	80003df6 <begin_op>
      ilock(f->ip);
    80004540:	01893503          	ld	a0,24(s2)
    80004544:	e3bfe0ef          	jal	8000337e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004548:	874e                	mv	a4,s3
    8000454a:	02092683          	lw	a3,32(s2)
    8000454e:	016a0633          	add	a2,s4,s6
    80004552:	85e2                	mv	a1,s8
    80004554:	01893503          	ld	a0,24(s2)
    80004558:	af2ff0ef          	jal	8000384a <writei>
    8000455c:	84aa                	mv	s1,a0
    8000455e:	00a05763          	blez	a0,8000456c <filewrite+0xbc>
        f->off += r;
    80004562:	02092783          	lw	a5,32(s2)
    80004566:	9fa9                	addw	a5,a5,a0
    80004568:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000456c:	01893503          	ld	a0,24(s2)
    80004570:	ebdfe0ef          	jal	8000342c <iunlock>
      end_op();
    80004574:	90fff0ef          	jal	80003e82 <end_op>

      if (r != n1) {
    80004578:	00999d63          	bne	s3,s1,80004592 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    8000457c:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    80004580:	015a5963          	bge	s4,s5,80004592 <filewrite+0xe2>
      int n1 = n - i;
    80004584:	414a87bb          	subw	a5,s5,s4
    80004588:	89be                	mv	s3,a5
      if (n1 > max)
    8000458a:	fafbd8e3          	bge	s7,a5,8000453a <filewrite+0x8a>
    8000458e:	89e6                	mv	s3,s9
    80004590:	b76d                	j	8000453a <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    80004592:	054a9463          	bne	s5,s4,800045da <filewrite+0x12a>
    80004596:	8556                	mv	a0,s5
    80004598:	64a6                	ld	s1,72(sp)
    8000459a:	79e2                	ld	s3,56(sp)
    8000459c:	7a42                	ld	s4,48(sp)
    8000459e:	6be2                	ld	s7,24(sp)
    800045a0:	6c42                	ld	s8,16(sp)
    800045a2:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800045a4:	60e6                	ld	ra,88(sp)
    800045a6:	6446                	ld	s0,80(sp)
    800045a8:	6906                	ld	s2,64(sp)
    800045aa:	7aa2                	ld	s5,40(sp)
    800045ac:	7b02                	ld	s6,32(sp)
    800045ae:	6125                	addi	sp,sp,96
    800045b0:	8082                	ret
    800045b2:	e4a6                	sd	s1,72(sp)
    800045b4:	fc4e                	sd	s3,56(sp)
    800045b6:	f852                	sd	s4,48(sp)
    800045b8:	ec5e                	sd	s7,24(sp)
    800045ba:	e862                	sd	s8,16(sp)
    800045bc:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800045be:	00003517          	auipc	a0,0x3
    800045c2:	09a50513          	addi	a0,a0,154 # 80007658 <etext+0x658>
    800045c6:	a6efc0ef          	jal	80000834 <panic>
    return -1;
    800045ca:	557d                	li	a0,-1
    800045cc:	bfe1                	j	800045a4 <filewrite+0xf4>
      return -1;
    800045ce:	557d                	li	a0,-1
    800045d0:	bfd1                	j	800045a4 <filewrite+0xf4>
    800045d2:	557d                	li	a0,-1
    800045d4:	bfc1                	j	800045a4 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    800045d6:	8532                	mv	a0,a2
    800045d8:	b7f1                	j	800045a4 <filewrite+0xf4>
    800045da:	557d                	li	a0,-1
    800045dc:	64a6                	ld	s1,72(sp)
    800045de:	79e2                	ld	s3,56(sp)
    800045e0:	7a42                	ld	s4,48(sp)
    800045e2:	6be2                	ld	s7,24(sp)
    800045e4:	6c42                	ld	s8,16(sp)
    800045e6:	6ca2                	ld	s9,8(sp)
    800045e8:	bf75                	j	800045a4 <filewrite+0xf4>
    return -1;
    800045ea:	557d                	li	a0,-1
}
    800045ec:	8082                	ret

00000000800045ee <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800045ee:	7179                	addi	sp,sp,-48
    800045f0:	f406                	sd	ra,40(sp)
    800045f2:	f022                	sd	s0,32(sp)
    800045f4:	ec26                	sd	s1,24(sp)
    800045f6:	e052                	sd	s4,0(sp)
    800045f8:	1800                	addi	s0,sp,48
    800045fa:	84aa                	mv	s1,a0
    800045fc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800045fe:	0005b023          	sd	zero,0(a1)
    80004602:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004606:	c07ff0ef          	jal	8000420c <filealloc>
    8000460a:	e088                	sd	a0,0(s1)
    8000460c:	c549                	beqz	a0,80004696 <pipealloc+0xa8>
    8000460e:	bffff0ef          	jal	8000420c <filealloc>
    80004612:	00aa3023          	sd	a0,0(s4)
    80004616:	cd25                	beqz	a0,8000468e <pipealloc+0xa0>
    80004618:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    8000461a:	d34fc0ef          	jal	80000b4e <kalloc>
    8000461e:	892a                	mv	s2,a0
    80004620:	c12d                	beqz	a0,80004682 <pipealloc+0x94>
    80004622:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004624:	4985                	li	s3,1
    80004626:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000462a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000462e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004632:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004636:	00003597          	auipc	a1,0x3
    8000463a:	03258593          	addi	a1,a1,50 # 80007668 <etext+0x668>
    8000463e:	d6afc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004642:	609c                	ld	a5,0(s1)
    80004644:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004648:	609c                	ld	a5,0(s1)
    8000464a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000464e:	609c                	ld	a5,0(s1)
    80004650:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004654:	609c                	ld	a5,0(s1)
    80004656:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000465a:	000a3783          	ld	a5,0(s4)
    8000465e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004662:	000a3783          	ld	a5,0(s4)
    80004666:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000466a:	000a3783          	ld	a5,0(s4)
    8000466e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004672:	000a3783          	ld	a5,0(s4)
    80004676:	0127b823          	sd	s2,16(a5)
  return 0;
    8000467a:	4501                	li	a0,0
    8000467c:	6942                	ld	s2,16(sp)
    8000467e:	69a2                	ld	s3,8(sp)
    80004680:	a01d                	j	800046a6 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004682:	6088                	ld	a0,0(s1)
    80004684:	c119                	beqz	a0,8000468a <pipealloc+0x9c>
    80004686:	6942                	ld	s2,16(sp)
    80004688:	a029                	j	80004692 <pipealloc+0xa4>
    8000468a:	6942                	ld	s2,16(sp)
    8000468c:	a029                	j	80004696 <pipealloc+0xa8>
    8000468e:	6088                	ld	a0,0(s1)
    80004690:	c10d                	beqz	a0,800046b2 <pipealloc+0xc4>
    fileclose(*f0);
    80004692:	c1fff0ef          	jal	800042b0 <fileclose>
  if (*f1)
    80004696:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000469a:	557d                	li	a0,-1
  if (*f1)
    8000469c:	c789                	beqz	a5,800046a6 <pipealloc+0xb8>
    fileclose(*f1);
    8000469e:	853e                	mv	a0,a5
    800046a0:	c11ff0ef          	jal	800042b0 <fileclose>
  return -1;
    800046a4:	557d                	li	a0,-1
}
    800046a6:	70a2                	ld	ra,40(sp)
    800046a8:	7402                	ld	s0,32(sp)
    800046aa:	64e2                	ld	s1,24(sp)
    800046ac:	6a02                	ld	s4,0(sp)
    800046ae:	6145                	addi	sp,sp,48
    800046b0:	8082                	ret
  return -1;
    800046b2:	557d                	li	a0,-1
    800046b4:	bfcd                	j	800046a6 <pipealloc+0xb8>

00000000800046b6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800046b6:	1101                	addi	sp,sp,-32
    800046b8:	ec06                	sd	ra,24(sp)
    800046ba:	e822                	sd	s0,16(sp)
    800046bc:	e426                	sd	s1,8(sp)
    800046be:	e04a                	sd	s2,0(sp)
    800046c0:	1000                	addi	s0,sp,32
    800046c2:	84aa                	mv	s1,a0
    800046c4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800046c6:	d62fc0ef          	jal	80000c28 <acquire>
  if (writable) {
    800046ca:	02090763          	beqz	s2,800046f8 <pipeclose+0x42>
    pi->writeopen = 0;
    800046ce:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800046d2:	21848513          	addi	a0,s1,536
    800046d6:	9b9fd0ef          	jal	8000208e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    800046da:	2204a783          	lw	a5,544(s1)
    800046de:	e781                	bnez	a5,800046e6 <pipeclose+0x30>
    800046e0:	2244a783          	lw	a5,548(s1)
    800046e4:	c38d                	beqz	a5,80004706 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    800046e6:	8526                	mv	a0,s1
    800046e8:	dc8fc0ef          	jal	80000cb0 <release>
}
    800046ec:	60e2                	ld	ra,24(sp)
    800046ee:	6442                	ld	s0,16(sp)
    800046f0:	64a2                	ld	s1,8(sp)
    800046f2:	6902                	ld	s2,0(sp)
    800046f4:	6105                	addi	sp,sp,32
    800046f6:	8082                	ret
    pi->readopen = 0;
    800046f8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800046fc:	21c48513          	addi	a0,s1,540
    80004700:	98ffd0ef          	jal	8000208e <wakeup>
    80004704:	bfd9                	j	800046da <pipeclose+0x24>
    release(&pi->lock);
    80004706:	8526                	mv	a0,s1
    80004708:	da8fc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    8000470c:	8526                	mv	a0,s1
    8000470e:	b58fc0ef          	jal	80000a66 <kfree>
    80004712:	bfe9                	j	800046ec <pipeclose+0x36>

0000000080004714 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004714:	7159                	addi	sp,sp,-112
    80004716:	f486                	sd	ra,104(sp)
    80004718:	f0a2                	sd	s0,96(sp)
    8000471a:	eca6                	sd	s1,88(sp)
    8000471c:	e8ca                	sd	s2,80(sp)
    8000471e:	e4ce                	sd	s3,72(sp)
    80004720:	e0d2                	sd	s4,64(sp)
    80004722:	fc56                	sd	s5,56(sp)
    80004724:	1880                	addi	s0,sp,112
    80004726:	84aa                	mv	s1,a0
    80004728:	8aae                	mv	s5,a1
    8000472a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000472c:	aecfd0ef          	jal	80001a18 <myproc>
    80004730:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004732:	8526                	mv	a0,s1
    80004734:	cf4fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    80004738:	0f405a63          	blez	s4,8000482c <pipewrite+0x118>
    8000473c:	f85a                	sd	s6,48(sp)
    8000473e:	f45e                	sd	s7,40(sp)
    80004740:	f062                	sd	s8,32(sp)
    80004742:	ec66                	sd	s9,24(sp)
    80004744:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004746:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004748:	f9f40c13          	addi	s8,s0,-97
    8000474c:	4b85                	li	s7,1
    8000474e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004750:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    80004754:	21c48c93          	addi	s9,s1,540
    80004758:	a0a1                	j	800047a0 <pipewrite+0x8c>
      release(&pi->lock);
    8000475a:	8526                	mv	a0,s1
    8000475c:	d54fc0ef          	jal	80000cb0 <release>
      return -1;
    80004760:	597d                	li	s2,-1
    80004762:	7b42                	ld	s6,48(sp)
    80004764:	7ba2                	ld	s7,40(sp)
    80004766:	7c02                	ld	s8,32(sp)
    80004768:	6ce2                	ld	s9,24(sp)
    8000476a:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000476c:	854a                	mv	a0,s2
    8000476e:	70a6                	ld	ra,104(sp)
    80004770:	7406                	ld	s0,96(sp)
    80004772:	64e6                	ld	s1,88(sp)
    80004774:	6946                	ld	s2,80(sp)
    80004776:	69a6                	ld	s3,72(sp)
    80004778:	6a06                	ld	s4,64(sp)
    8000477a:	7ae2                	ld	s5,56(sp)
    8000477c:	6165                	addi	sp,sp,112
    8000477e:	8082                	ret
      wakeup(&pi->nread);
    80004780:	856a                	mv	a0,s10
    80004782:	90dfd0ef          	jal	8000208e <wakeup>
      sleep_prepare(&pi->nwrite);
    80004786:	8566                	mv	a0,s9
    80004788:	89bfd0ef          	jal	80002022 <sleep_prepare>
      release(&pi->lock);
    8000478c:	8526                	mv	a0,s1
    8000478e:	d22fc0ef          	jal	80000cb0 <release>
      sleep();
    80004792:	8cdfd0ef          	jal	8000205e <sleep>
      acquire(&pi->lock);
    80004796:	8526                	mv	a0,s1
    80004798:	c90fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    8000479c:	07495b63          	bge	s2,s4,80004812 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    800047a0:	2204a783          	lw	a5,544(s1)
    800047a4:	dbdd                	beqz	a5,8000475a <pipewrite+0x46>
    800047a6:	854e                	mv	a0,s3
    800047a8:	ad9fd0ef          	jal	80002280 <killed>
    800047ac:	f55d                	bnez	a0,8000475a <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    800047ae:	2184a783          	lw	a5,536(s1)
    800047b2:	21c4a703          	lw	a4,540(s1)
    800047b6:	2007879b          	addiw	a5,a5,512
    800047ba:	fcf703e3          	beq	a4,a5,80004780 <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800047be:	875e                	mv	a4,s7
    800047c0:	015906b3          	add	a3,s2,s5
    800047c4:	8662                	mv	a2,s8
    800047c6:	0489b583          	ld	a1,72(s3)
    800047ca:	0509b503          	ld	a0,80(s3)
    800047ce:	e7bfc0ef          	jal	80001648 <copyin>
    800047d2:	03650163          	beq	a0,s6,800047f4 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800047d6:	21c4a783          	lw	a5,540(s1)
    800047da:	0017871b          	addiw	a4,a5,1
    800047de:	20e4ae23          	sw	a4,540(s1)
    800047e2:	1ff7f793          	andi	a5,a5,511
    800047e6:	97a6                	add	a5,a5,s1
    800047e8:	f9f44703          	lbu	a4,-97(s0)
    800047ec:	00e78c23          	sb	a4,24(a5)
      i++;
    800047f0:	2905                	addiw	s2,s2,1
    800047f2:	b76d                	j	8000479c <pipewrite+0x88>
        if (i == 0)
    800047f4:	00090863          	beqz	s2,80004804 <pipewrite+0xf0>
    800047f8:	7b42                	ld	s6,48(sp)
    800047fa:	7ba2                	ld	s7,40(sp)
    800047fc:	7c02                	ld	s8,32(sp)
    800047fe:	6ce2                	ld	s9,24(sp)
    80004800:	6d42                	ld	s10,16(sp)
    80004802:	a829                	j	8000481c <pipewrite+0x108>
          i = -1;
    80004804:	892a                	mv	s2,a0
        break;
    80004806:	7b42                	ld	s6,48(sp)
    80004808:	7ba2                	ld	s7,40(sp)
    8000480a:	7c02                	ld	s8,32(sp)
    8000480c:	6ce2                	ld	s9,24(sp)
    8000480e:	6d42                	ld	s10,16(sp)
    80004810:	a031                	j	8000481c <pipewrite+0x108>
    80004812:	7b42                	ld	s6,48(sp)
    80004814:	7ba2                	ld	s7,40(sp)
    80004816:	7c02                	ld	s8,32(sp)
    80004818:	6ce2                	ld	s9,24(sp)
    8000481a:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000481c:	21848513          	addi	a0,s1,536
    80004820:	86ffd0ef          	jal	8000208e <wakeup>
  release(&pi->lock);
    80004824:	8526                	mv	a0,s1
    80004826:	c8afc0ef          	jal	80000cb0 <release>
  return i;
    8000482a:	b789                	j	8000476c <pipewrite+0x58>
  int i = 0;
    8000482c:	4901                	li	s2,0
    8000482e:	b7fd                	j	8000481c <pipewrite+0x108>

0000000080004830 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004830:	711d                	addi	sp,sp,-96
    80004832:	ec86                	sd	ra,88(sp)
    80004834:	e8a2                	sd	s0,80(sp)
    80004836:	e4a6                	sd	s1,72(sp)
    80004838:	e0ca                	sd	s2,64(sp)
    8000483a:	fc4e                	sd	s3,56(sp)
    8000483c:	f852                	sd	s4,48(sp)
    8000483e:	f456                	sd	s5,40(sp)
    80004840:	1080                	addi	s0,sp,96
    80004842:	84aa                	mv	s1,a0
    80004844:	89ae                	mv	s3,a1
    80004846:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004848:	9d0fd0ef          	jal	80001a18 <myproc>
    8000484c:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    8000484e:	8526                	mv	a0,s1
    80004850:	bd8fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004854:	0d505263          	blez	s5,80004918 <piperead+0xe8>
    80004858:	2184a703          	lw	a4,536(s1)
    8000485c:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004860:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004864:	02f71e63          	bne	a4,a5,800048a0 <piperead+0x70>
    80004868:	2244a783          	lw	a5,548(s1)
    8000486c:	c3b9                	beqz	a5,800048b2 <piperead+0x82>
    if (killed(pr)) {
    8000486e:	854a                	mv	a0,s2
    80004870:	a11fd0ef          	jal	80002280 <killed>
    80004874:	e915                	bnez	a0,800048a8 <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004876:	8552                	mv	a0,s4
    80004878:	faafd0ef          	jal	80002022 <sleep_prepare>
    release(&pi->lock);
    8000487c:	8526                	mv	a0,s1
    8000487e:	c32fc0ef          	jal	80000cb0 <release>
    sleep();
    80004882:	fdcfd0ef          	jal	8000205e <sleep>
    acquire(&pi->lock);
    80004886:	8526                	mv	a0,s1
    80004888:	ba0fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000488c:	2184a703          	lw	a4,536(s1)
    80004890:	21c4a783          	lw	a5,540(s1)
    80004894:	fcf70ae3          	beq	a4,a5,80004868 <piperead+0x38>
    80004898:	f05a                	sd	s6,32(sp)
    8000489a:	ec5e                	sd	s7,24(sp)
    8000489c:	e862                	sd	s8,16(sp)
    8000489e:	a829                	j	800048b8 <piperead+0x88>
    800048a0:	f05a                	sd	s6,32(sp)
    800048a2:	ec5e                	sd	s7,24(sp)
    800048a4:	e862                	sd	s8,16(sp)
    800048a6:	a809                	j	800048b8 <piperead+0x88>
      release(&pi->lock);
    800048a8:	8526                	mv	a0,s1
    800048aa:	c06fc0ef          	jal	80000cb0 <release>
      return -1;
    800048ae:	5a7d                	li	s4,-1
    800048b0:	a8a5                	j	80004928 <piperead+0xf8>
    800048b2:	f05a                	sd	s6,32(sp)
    800048b4:	ec5e                	sd	s7,24(sp)
    800048b6:	e862                	sd	s8,16(sp)
{
    800048b8:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    800048ba:	faf40c13          	addi	s8,s0,-81
    800048be:	4b85                	li	s7,1
    800048c0:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    800048c2:	2184a783          	lw	a5,536(s1)
    800048c6:	21c4a703          	lw	a4,540(s1)
    800048ca:	06f70e63          	beq	a4,a5,80004946 <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    800048ce:	1ff7f793          	andi	a5,a5,511
    800048d2:	97a6                	add	a5,a5,s1
    800048d4:	0187c783          	lbu	a5,24(a5)
    800048d8:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    800048dc:	875e                	mv	a4,s7
    800048de:	86e2                	mv	a3,s8
    800048e0:	864e                	mv	a2,s3
    800048e2:	04893583          	ld	a1,72(s2)
    800048e6:	05093503          	ld	a0,80(s2)
    800048ea:	c99fc0ef          	jal	80001582 <copyout>
    800048ee:	01650f63          	beq	a0,s6,8000490c <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800048f2:	2184a783          	lw	a5,536(s1)
    800048f6:	2785                	addiw	a5,a5,1
    800048f8:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800048fc:	2a05                	addiw	s4,s4,1
    800048fe:	0985                	addi	s3,s3,1
    80004900:	fd4a91e3          	bne	s5,s4,800048c2 <piperead+0x92>
    80004904:	7b02                	ld	s6,32(sp)
    80004906:	6be2                	ld	s7,24(sp)
    80004908:	6c42                	ld	s8,16(sp)
    8000490a:	a801                	j	8000491a <piperead+0xea>
      if (i == 0)
    8000490c:	020a0863          	beqz	s4,8000493c <piperead+0x10c>
    80004910:	7b02                	ld	s6,32(sp)
    80004912:	6be2                	ld	s7,24(sp)
    80004914:	6c42                	ld	s8,16(sp)
    80004916:	a011                	j	8000491a <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004918:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    8000491a:	21c48513          	addi	a0,s1,540
    8000491e:	f70fd0ef          	jal	8000208e <wakeup>
  release(&pi->lock);
    80004922:	8526                	mv	a0,s1
    80004924:	b8cfc0ef          	jal	80000cb0 <release>
  return i;
}
    80004928:	8552                	mv	a0,s4
    8000492a:	60e6                	ld	ra,88(sp)
    8000492c:	6446                	ld	s0,80(sp)
    8000492e:	64a6                	ld	s1,72(sp)
    80004930:	6906                	ld	s2,64(sp)
    80004932:	79e2                	ld	s3,56(sp)
    80004934:	7a42                	ld	s4,48(sp)
    80004936:	7aa2                	ld	s5,40(sp)
    80004938:	6125                	addi	sp,sp,96
    8000493a:	8082                	ret
        i = -1;
    8000493c:	8a2a                	mv	s4,a0
    8000493e:	7b02                	ld	s6,32(sp)
    80004940:	6be2                	ld	s7,24(sp)
    80004942:	6c42                	ld	s8,16(sp)
    80004944:	bfd9                	j	8000491a <piperead+0xea>
    80004946:	7b02                	ld	s6,32(sp)
    80004948:	6be2                	ld	s7,24(sp)
    8000494a:	6c42                	ld	s8,16(sp)
    8000494c:	b7f9                	j	8000491a <piperead+0xea>

000000008000494e <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    8000494e:	1141                	addi	sp,sp,-16
    80004950:	e406                	sd	ra,8(sp)
    80004952:	e022                	sd	s0,0(sp)
    80004954:	0800                	addi	s0,sp,16
    80004956:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004958:	0035151b          	slliw	a0,a0,0x3
    8000495c:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    8000495e:	8b89                	andi	a5,a5,2
    80004960:	c399                	beqz	a5,80004966 <flags2perm+0x18>
    perm |= PTE_W;
    80004962:	00456513          	ori	a0,a0,4
  return perm;
}
    80004966:	60a2                	ld	ra,8(sp)
    80004968:	6402                	ld	s0,0(sp)
    8000496a:	0141                	addi	sp,sp,16
    8000496c:	8082                	ret

000000008000496e <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000496e:	de010113          	addi	sp,sp,-544
    80004972:	20113c23          	sd	ra,536(sp)
    80004976:	20813823          	sd	s0,528(sp)
    8000497a:	20913423          	sd	s1,520(sp)
    8000497e:	21213023          	sd	s2,512(sp)
    80004982:	1400                	addi	s0,sp,544
    80004984:	892a                	mv	s2,a0
    80004986:	dea43823          	sd	a0,-528(s0)
    8000498a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000498e:	88afd0ef          	jal	80001a18 <myproc>
    80004992:	84aa                	mv	s1,a0

  begin_op();
    80004994:	c62ff0ef          	jal	80003df6 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004998:	854a                	mv	a0,s2
    8000499a:	a7eff0ef          	jal	80003c18 <namei>
    8000499e:	cd21                	beqz	a0,800049f6 <kexec+0x88>
    800049a0:	fbd2                	sd	s4,496(sp)
    800049a2:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800049a4:	9dbfe0ef          	jal	8000337e <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800049a8:	04000713          	li	a4,64
    800049ac:	4681                	li	a3,0
    800049ae:	e5040613          	addi	a2,s0,-432
    800049b2:	4581                	li	a1,0
    800049b4:	8552                	mv	a0,s4
    800049b6:	da3fe0ef          	jal	80003758 <readi>
    800049ba:	04000793          	li	a5,64
    800049be:	00f51a63          	bne	a0,a5,800049d2 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    800049c2:	e5042703          	lw	a4,-432(s0)
    800049c6:	464c47b7          	lui	a5,0x464c4
    800049ca:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800049ce:	02f70863          	beq	a4,a5,800049fe <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    800049d2:	8552                	mv	a0,s4
    800049d4:	bfffe0ef          	jal	800035d2 <iunlockput>
    end_op();
    800049d8:	caaff0ef          	jal	80003e82 <end_op>
  }
  return -1;
    800049dc:	557d                	li	a0,-1
    800049de:	7a5e                	ld	s4,496(sp)
}
    800049e0:	21813083          	ld	ra,536(sp)
    800049e4:	21013403          	ld	s0,528(sp)
    800049e8:	20813483          	ld	s1,520(sp)
    800049ec:	20013903          	ld	s2,512(sp)
    800049f0:	22010113          	addi	sp,sp,544
    800049f4:	8082                	ret
    end_op();
    800049f6:	c8cff0ef          	jal	80003e82 <end_op>
    return -1;
    800049fa:	557d                	li	a0,-1
    800049fc:	b7d5                	j	800049e0 <kexec+0x72>
    800049fe:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004a00:	8526                	mv	a0,s1
    80004a02:	91cfd0ef          	jal	80001b1e <proc_pagetable>
    80004a06:	8b2a                	mv	s6,a0
    80004a08:	26050e63          	beqz	a0,80004c84 <kexec+0x316>
    80004a0c:	ffce                	sd	s3,504(sp)
    80004a0e:	f7d6                	sd	s5,488(sp)
    80004a10:	efde                	sd	s7,472(sp)
    80004a12:	ebe2                	sd	s8,464(sp)
    80004a14:	e7e6                	sd	s9,456(sp)
    80004a16:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a18:	e8845783          	lhu	a5,-376(s0)
    80004a1c:	14078263          	beqz	a5,80004b60 <kexec+0x1f2>
    80004a20:	ff6e                	sd	s11,440(sp)
    80004a22:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a26:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a28:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a2a:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004a2e:	6c85                	lui	s9,0x1
    80004a30:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004a34:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004a38:	6a85                	lui	s5,0x1
    80004a3a:	a085                	j	80004a9a <kexec+0x12c>
      panic("loadseg: address should exist");
    80004a3c:	00003517          	auipc	a0,0x3
    80004a40:	c3450513          	addi	a0,a0,-972 # 80007670 <etext+0x670>
    80004a44:	df1fb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004a48:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004a4a:	874a                	mv	a4,s2
    80004a4c:	009b86bb          	addw	a3,s7,s1
    80004a50:	4581                	li	a1,0
    80004a52:	8552                	mv	a0,s4
    80004a54:	d05fe0ef          	jal	80003758 <readi>
    80004a58:	22a91a63          	bne	s2,a0,80004c8c <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004a5c:	009a84bb          	addw	s1,s5,s1
    80004a60:	0334f263          	bgeu	s1,s3,80004a84 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004a64:	02049593          	slli	a1,s1,0x20
    80004a68:	9181                	srli	a1,a1,0x20
    80004a6a:	95e2                	add	a1,a1,s8
    80004a6c:	855a                	mv	a0,s6
    80004a6e:	daafc0ef          	jal	80001018 <walkaddr>
    80004a72:	862a                	mv	a2,a0
    if (pa == 0)
    80004a74:	d561                	beqz	a0,80004a3c <kexec+0xce>
    if (sz - i < PGSIZE)
    80004a76:	409987bb          	subw	a5,s3,s1
    80004a7a:	893e                	mv	s2,a5
    80004a7c:	fcfcf6e3          	bgeu	s9,a5,80004a48 <kexec+0xda>
    80004a80:	8956                	mv	s2,s5
    80004a82:	b7d9                	j	80004a48 <kexec+0xda>
    sz = sz1;
    80004a84:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a88:	2d05                	addiw	s10,s10,1
    80004a8a:	e0843783          	ld	a5,-504(s0)
    80004a8e:	0387869b          	addiw	a3,a5,56
    80004a92:	e8845783          	lhu	a5,-376(s0)
    80004a96:	06fd5d63          	bge	s10,a5,80004b10 <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a9a:	e0d43423          	sd	a3,-504(s0)
    80004a9e:	876e                	mv	a4,s11
    80004aa0:	e1840613          	addi	a2,s0,-488
    80004aa4:	4581                	li	a1,0
    80004aa6:	8552                	mv	a0,s4
    80004aa8:	cb1fe0ef          	jal	80003758 <readi>
    80004aac:	1db51e63          	bne	a0,s11,80004c88 <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004ab0:	e1842783          	lw	a5,-488(s0)
    80004ab4:	4705                	li	a4,1
    80004ab6:	fce799e3          	bne	a5,a4,80004a88 <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004aba:	e4043483          	ld	s1,-448(s0)
    80004abe:	e3843783          	ld	a5,-456(s0)
    80004ac2:	1ef4e363          	bltu	s1,a5,80004ca8 <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004ac6:	e2843783          	ld	a5,-472(s0)
    80004aca:	94be                	add	s1,s1,a5
    80004acc:	1ef4e163          	bltu	s1,a5,80004cae <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004ad0:	de843703          	ld	a4,-536(s0)
    80004ad4:	8ff9                	and	a5,a5,a4
    80004ad6:	1c079f63          	bnez	a5,80004cb4 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004ada:	e1c42503          	lw	a0,-484(s0)
    80004ade:	e71ff0ef          	jal	8000494e <flags2perm>
    80004ae2:	86aa                	mv	a3,a0
    80004ae4:	8626                	mv	a2,s1
    80004ae6:	85ca                	mv	a1,s2
    80004ae8:	855a                	mv	a0,s6
    80004aea:	805fc0ef          	jal	800012ee <uvmalloc>
    80004aee:	dea43c23          	sd	a0,-520(s0)
    80004af2:	1c050463          	beqz	a0,80004cba <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004af6:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004afa:	00098863          	beqz	s3,80004b0a <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004afe:	e2843c03          	ld	s8,-472(s0)
    80004b02:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004b06:	4481                	li	s1,0
    80004b08:	bfb1                	j	80004a64 <kexec+0xf6>
    sz = sz1;
    80004b0a:	df843903          	ld	s2,-520(s0)
    80004b0e:	bfad                	j	80004a88 <kexec+0x11a>
    80004b10:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004b12:	8552                	mv	a0,s4
    80004b14:	abffe0ef          	jal	800035d2 <iunlockput>
  end_op();
    80004b18:	b6aff0ef          	jal	80003e82 <end_op>
  p = myproc();
    80004b1c:	efdfc0ef          	jal	80001a18 <myproc>
    80004b20:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004b22:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004b26:	6c05                	lui	s8,0x1
    80004b28:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004b2a:	9c4a                	add	s8,s8,s2
    80004b2c:	77fd                	lui	a5,0xfffff
    80004b2e:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004b32:	4691                	li	a3,4
    80004b34:	6609                	lui	a2,0x2
    80004b36:	9662                	add	a2,a2,s8
    80004b38:	85e2                	mv	a1,s8
    80004b3a:	855a                	mv	a0,s6
    80004b3c:	fb2fc0ef          	jal	800012ee <uvmalloc>
    80004b40:	892a                	mv	s2,a0
    80004b42:	e10d                	bnez	a0,80004b64 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004b44:	85e2                	mv	a1,s8
    80004b46:	855a                	mv	a0,s6
    80004b48:	85afd0ef          	jal	80001ba2 <proc_freepagetable>
  return -1;
    80004b4c:	557d                	li	a0,-1
    80004b4e:	79fe                	ld	s3,504(sp)
    80004b50:	7a5e                	ld	s4,496(sp)
    80004b52:	7abe                	ld	s5,488(sp)
    80004b54:	7b1e                	ld	s6,480(sp)
    80004b56:	6bfe                	ld	s7,472(sp)
    80004b58:	6c5e                	ld	s8,464(sp)
    80004b5a:	6cbe                	ld	s9,456(sp)
    80004b5c:	6d1e                	ld	s10,448(sp)
    80004b5e:	b549                	j	800049e0 <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b60:	4901                	li	s2,0
    80004b62:	bf45                	j	80004b12 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004b64:	75f9                	lui	a1,0xffffe
    80004b66:	95aa                	add	a1,a1,a0
    80004b68:	855a                	mv	a0,s6
    80004b6a:	957fc0ef          	jal	800014c0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004b6e:	80090a13          	addi	s4,s2,-2048
    80004b72:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004b76:	e0043783          	ld	a5,-512(s0)
    80004b7a:	6388                	ld	a0,0(a5)
    80004b7c:	c545                	beqz	a0,80004c24 <kexec+0x2b6>
  sp = sz;
    80004b7e:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004b80:	4481                	li	s1,0
    ustack[argc] = sp;
    80004b82:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004b86:	aecfc0ef          	jal	80000e72 <strlen>
    80004b8a:	0015079b          	addiw	a5,a0,1
    80004b8e:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004b92:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004b96:	134c6563          	bltu	s8,s4,80004cc0 <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004b9a:	e0043d03          	ld	s10,-512(s0)
    80004b9e:	000d3c83          	ld	s9,0(s10)
    80004ba2:	8566                	mv	a0,s9
    80004ba4:	acefc0ef          	jal	80000e72 <strlen>
    80004ba8:	0015071b          	addiw	a4,a0,1
    80004bac:	86e6                	mv	a3,s9
    80004bae:	8662                	mv	a2,s8
    80004bb0:	85ca                	mv	a1,s2
    80004bb2:	855a                	mv	a0,s6
    80004bb4:	9cffc0ef          	jal	80001582 <copyout>
    80004bb8:	10054663          	bltz	a0,80004cc4 <kexec+0x356>
    ustack[argc] = sp;
    80004bbc:	00349793          	slli	a5,s1,0x3
    80004bc0:	97de                	add	a5,a5,s7
    80004bc2:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb888>
  for (argc = 0; argv[argc]; argc++) {
    80004bc6:	0485                	addi	s1,s1,1
    80004bc8:	008d0793          	addi	a5,s10,8
    80004bcc:	e0f43023          	sd	a5,-512(s0)
    80004bd0:	008d3503          	ld	a0,8(s10)
    80004bd4:	f94d                	bnez	a0,80004b86 <kexec+0x218>
  ustack[argc] = 0;
    80004bd6:	00349793          	slli	a5,s1,0x3
    80004bda:	f9078793          	addi	a5,a5,-112
    80004bde:	97a2                	add	a5,a5,s0
    80004be0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004be4:	00349713          	slli	a4,s1,0x3
    80004be8:	0721                	addi	a4,a4,8
    80004bea:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004bee:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004bf2:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004bf4:	f54be8e3          	bltu	s7,s4,80004b44 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004bf8:	e9040693          	addi	a3,s0,-368
    80004bfc:	865e                	mv	a2,s7
    80004bfe:	85ca                	mv	a1,s2
    80004c00:	855a                	mv	a0,s6
    80004c02:	981fc0ef          	jal	80001582 <copyout>
    80004c06:	f2054fe3          	bltz	a0,80004b44 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004c0a:	0589b783          	ld	a5,88(s3)
    80004c0e:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004c12:	df043783          	ld	a5,-528(s0)
    80004c16:	0007c703          	lbu	a4,0(a5)
    80004c1a:	c30d                	beqz	a4,80004c3c <kexec+0x2ce>
    80004c1c:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004c1e:	02f00693          	li	a3,47
    80004c22:	a801                	j	80004c32 <kexec+0x2c4>
  sp = sz;
    80004c24:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004c26:	4481                	li	s1,0
    80004c28:	b77d                	j	80004bd6 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004c2a:	0785                	addi	a5,a5,1
    80004c2c:	fff7c703          	lbu	a4,-1(a5)
    80004c30:	c711                	beqz	a4,80004c3c <kexec+0x2ce>
    if (*s == '/')
    80004c32:	fed71ce3          	bne	a4,a3,80004c2a <kexec+0x2bc>
      last = s + 1;
    80004c36:	def43823          	sd	a5,-528(s0)
    80004c3a:	bfc5                	j	80004c2a <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004c3c:	4641                	li	a2,16
    80004c3e:	df043583          	ld	a1,-528(s0)
    80004c42:	15898513          	addi	a0,s3,344
    80004c46:	9f6fc0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004c4a:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004c4e:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004c52:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004c56:	0589b783          	ld	a5,88(s3)
    80004c5a:	e6843703          	ld	a4,-408(s0)
    80004c5e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004c60:	0589b783          	ld	a5,88(s3)
    80004c64:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004c68:	85d6                	mv	a1,s5
    80004c6a:	f39fc0ef          	jal	80001ba2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004c6e:	0004851b          	sext.w	a0,s1
    80004c72:	79fe                	ld	s3,504(sp)
    80004c74:	7a5e                	ld	s4,496(sp)
    80004c76:	7abe                	ld	s5,488(sp)
    80004c78:	7b1e                	ld	s6,480(sp)
    80004c7a:	6bfe                	ld	s7,472(sp)
    80004c7c:	6c5e                	ld	s8,464(sp)
    80004c7e:	6cbe                	ld	s9,456(sp)
    80004c80:	6d1e                	ld	s10,448(sp)
    80004c82:	bbb9                	j	800049e0 <kexec+0x72>
    80004c84:	7b1e                	ld	s6,480(sp)
    80004c86:	b3b1                	j	800049d2 <kexec+0x64>
    80004c88:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004c8c:	df843583          	ld	a1,-520(s0)
    80004c90:	855a                	mv	a0,s6
    80004c92:	f11fc0ef          	jal	80001ba2 <proc_freepagetable>
  if (ip) {
    80004c96:	79fe                	ld	s3,504(sp)
    80004c98:	7abe                	ld	s5,488(sp)
    80004c9a:	7b1e                	ld	s6,480(sp)
    80004c9c:	6bfe                	ld	s7,472(sp)
    80004c9e:	6c5e                	ld	s8,464(sp)
    80004ca0:	6cbe                	ld	s9,456(sp)
    80004ca2:	6d1e                	ld	s10,448(sp)
    80004ca4:	7dfa                	ld	s11,440(sp)
    80004ca6:	b335                	j	800049d2 <kexec+0x64>
    80004ca8:	df243c23          	sd	s2,-520(s0)
    80004cac:	b7c5                	j	80004c8c <kexec+0x31e>
    80004cae:	df243c23          	sd	s2,-520(s0)
    80004cb2:	bfe9                	j	80004c8c <kexec+0x31e>
    80004cb4:	df243c23          	sd	s2,-520(s0)
    80004cb8:	bfd1                	j	80004c8c <kexec+0x31e>
    80004cba:	df243c23          	sd	s2,-520(s0)
    80004cbe:	b7f9                	j	80004c8c <kexec+0x31e>
  sz = sz1;
    80004cc0:	8c4a                	mv	s8,s2
    80004cc2:	b549                	j	80004b44 <kexec+0x1d6>
    80004cc4:	8c4a                	mv	s8,s2
    80004cc6:	bdbd                	j	80004b44 <kexec+0x1d6>

0000000080004cc8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004cc8:	7179                	addi	sp,sp,-48
    80004cca:	f406                	sd	ra,40(sp)
    80004ccc:	f022                	sd	s0,32(sp)
    80004cce:	ec26                	sd	s1,24(sp)
    80004cd0:	e84a                	sd	s2,16(sp)
    80004cd2:	1800                	addi	s0,sp,48
    80004cd4:	892e                	mv	s2,a1
    80004cd6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004cd8:	fdc40593          	addi	a1,s0,-36
    80004cdc:	c85fd0ef          	jal	80002960 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004ce0:	fdc42703          	lw	a4,-36(s0)
    80004ce4:	47bd                	li	a5,15
    80004ce6:	02e7ea63          	bltu	a5,a4,80004d1a <argfd+0x52>
    80004cea:	d2ffc0ef          	jal	80001a18 <myproc>
    80004cee:	fdc42703          	lw	a4,-36(s0)
    80004cf2:	00371793          	slli	a5,a4,0x3
    80004cf6:	0d078793          	addi	a5,a5,208
    80004cfa:	953e                	add	a0,a0,a5
    80004cfc:	611c                	ld	a5,0(a0)
    80004cfe:	c385                	beqz	a5,80004d1e <argfd+0x56>
    return -1;
  if (pfd)
    80004d00:	00090463          	beqz	s2,80004d08 <argfd+0x40>
    *pfd = fd;
    80004d04:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004d08:	4501                	li	a0,0
  if (pf)
    80004d0a:	c091                	beqz	s1,80004d0e <argfd+0x46>
    *pf = f;
    80004d0c:	e09c                	sd	a5,0(s1)
}
    80004d0e:	70a2                	ld	ra,40(sp)
    80004d10:	7402                	ld	s0,32(sp)
    80004d12:	64e2                	ld	s1,24(sp)
    80004d14:	6942                	ld	s2,16(sp)
    80004d16:	6145                	addi	sp,sp,48
    80004d18:	8082                	ret
    return -1;
    80004d1a:	557d                	li	a0,-1
    80004d1c:	bfcd                	j	80004d0e <argfd+0x46>
    80004d1e:	557d                	li	a0,-1
    80004d20:	b7fd                	j	80004d0e <argfd+0x46>

0000000080004d22 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004d22:	1101                	addi	sp,sp,-32
    80004d24:	ec06                	sd	ra,24(sp)
    80004d26:	e822                	sd	s0,16(sp)
    80004d28:	e426                	sd	s1,8(sp)
    80004d2a:	1000                	addi	s0,sp,32
    80004d2c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004d2e:	cebfc0ef          	jal	80001a18 <myproc>
    80004d32:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004d34:	0d050793          	addi	a5,a0,208
    80004d38:	4501                	li	a0,0
    80004d3a:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004d3c:	6398                	ld	a4,0(a5)
    80004d3e:	cb19                	beqz	a4,80004d54 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004d40:	2505                	addiw	a0,a0,1
    80004d42:	07a1                	addi	a5,a5,8
    80004d44:	fed51ce3          	bne	a0,a3,80004d3c <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004d48:	557d                	li	a0,-1
}
    80004d4a:	60e2                	ld	ra,24(sp)
    80004d4c:	6442                	ld	s0,16(sp)
    80004d4e:	64a2                	ld	s1,8(sp)
    80004d50:	6105                	addi	sp,sp,32
    80004d52:	8082                	ret
      p->ofile[fd] = f;
    80004d54:	00351793          	slli	a5,a0,0x3
    80004d58:	0d078793          	addi	a5,a5,208
    80004d5c:	963e                	add	a2,a2,a5
    80004d5e:	e204                	sd	s1,0(a2)
      return fd;
    80004d60:	b7ed                	j	80004d4a <fdalloc+0x28>

0000000080004d62 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004d62:	715d                	addi	sp,sp,-80
    80004d64:	e486                	sd	ra,72(sp)
    80004d66:	e0a2                	sd	s0,64(sp)
    80004d68:	fc26                	sd	s1,56(sp)
    80004d6a:	f84a                	sd	s2,48(sp)
    80004d6c:	f052                	sd	s4,32(sp)
    80004d6e:	ec56                	sd	s5,24(sp)
    80004d70:	e85a                	sd	s6,16(sp)
    80004d72:	0880                	addi	s0,sp,80
    80004d74:	8a2e                	mv	s4,a1
    80004d76:	8ab2                	mv	s5,a2
    80004d78:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004d7a:	fb040593          	addi	a1,s0,-80
    80004d7e:	eb5fe0ef          	jal	80003c32 <nameiparent>
    80004d82:	84aa                	mv	s1,a0
    80004d84:	12050f63          	beqz	a0,80004ec2 <create+0x160>
    return 0;

  ilock(dp);
    80004d88:	df6fe0ef          	jal	8000337e <ilock>

  if (dp->nlink == 0) {
    80004d8c:	04a49783          	lh	a5,74(s1)
    80004d90:	cbb9                	beqz	a5,80004de6 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004d92:	7761                	lui	a4,0xffff8
    80004d94:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd4889>
    80004d96:	97ba                	add	a5,a5,a4
    80004d98:	e781                	bnez	a5,80004da0 <create+0x3e>
    80004d9a:	fffa0793          	addi	a5,s4,-1
    80004d9e:	cba9                	beqz	a5,80004df0 <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004da0:	4601                	li	a2,0
    80004da2:	fb040593          	addi	a1,s0,-80
    80004da6:	8526                	mv	a0,s1
    80004da8:	bbffe0ef          	jal	80003966 <dirlookup>
    80004dac:	892a                	mv	s2,a0
    80004dae:	c939                	beqz	a0,80004e04 <create+0xa2>
    iunlockput(dp);
    80004db0:	8526                	mv	a0,s1
    80004db2:	821fe0ef          	jal	800035d2 <iunlockput>
    ilock(ip);
    80004db6:	854a                	mv	a0,s2
    80004db8:	dc6fe0ef          	jal	8000337e <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004dbc:	4789                	li	a5,2
    80004dbe:	02fa1e63          	bne	s4,a5,80004dfa <create+0x98>
    80004dc2:	04495783          	lhu	a5,68(s2)
    80004dc6:	37f9                	addiw	a5,a5,-2
    80004dc8:	17c2                	slli	a5,a5,0x30
    80004dca:	93c1                	srli	a5,a5,0x30
    80004dcc:	4705                	li	a4,1
    80004dce:	02f76663          	bltu	a4,a5,80004dfa <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004dd2:	854a                	mv	a0,s2
    80004dd4:	60a6                	ld	ra,72(sp)
    80004dd6:	6406                	ld	s0,64(sp)
    80004dd8:	74e2                	ld	s1,56(sp)
    80004dda:	7942                	ld	s2,48(sp)
    80004ddc:	7a02                	ld	s4,32(sp)
    80004dde:	6ae2                	ld	s5,24(sp)
    80004de0:	6b42                	ld	s6,16(sp)
    80004de2:	6161                	addi	sp,sp,80
    80004de4:	8082                	ret
    iunlockput(dp);
    80004de6:	8526                	mv	a0,s1
    80004de8:	feafe0ef          	jal	800035d2 <iunlockput>
    return 0;
    80004dec:	4901                	li	s2,0
    80004dee:	b7d5                	j	80004dd2 <create+0x70>
    iunlockput(dp);
    80004df0:	8526                	mv	a0,s1
    80004df2:	fe0fe0ef          	jal	800035d2 <iunlockput>
    return 0;
    80004df6:	4901                	li	s2,0
    80004df8:	bfe9                	j	80004dd2 <create+0x70>
    iunlockput(ip);
    80004dfa:	854a                	mv	a0,s2
    80004dfc:	fd6fe0ef          	jal	800035d2 <iunlockput>
    return 0;
    80004e00:	4901                	li	s2,0
    80004e02:	bfc1                	j	80004dd2 <create+0x70>
    80004e04:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004e06:	85d2                	mv	a1,s4
    80004e08:	4088                	lw	a0,0(s1)
    80004e0a:	c04fe0ef          	jal	8000320e <ialloc>
    80004e0e:	89aa                	mv	s3,a0
    80004e10:	cd1d                	beqz	a0,80004e4e <create+0xec>
  ilock(ip);
    80004e12:	d6cfe0ef          	jal	8000337e <ilock>
  ip->major = major;
    80004e16:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004e1a:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004e1e:	4705                	li	a4,1
    80004e20:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004e24:	854e                	mv	a0,s3
    80004e26:	ca4fe0ef          	jal	800032ca <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004e2a:	4705                	li	a4,1
    80004e2c:	02ea0763          	beq	s4,a4,80004e5a <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004e30:	0049a603          	lw	a2,4(s3)
    80004e34:	fb040593          	addi	a1,s0,-80
    80004e38:	8526                	mv	a0,s1
    80004e3a:	d35fe0ef          	jal	80003b6e <dirlink>
    80004e3e:	06054563          	bltz	a0,80004ea8 <create+0x146>
  iunlockput(dp);
    80004e42:	8526                	mv	a0,s1
    80004e44:	f8efe0ef          	jal	800035d2 <iunlockput>
  return ip;
    80004e48:	894e                	mv	s2,s3
    80004e4a:	79a2                	ld	s3,40(sp)
    80004e4c:	b759                	j	80004dd2 <create+0x70>
    iunlockput(dp);
    80004e4e:	8526                	mv	a0,s1
    80004e50:	f82fe0ef          	jal	800035d2 <iunlockput>
    return 0;
    80004e54:	894e                	mv	s2,s3
    80004e56:	79a2                	ld	s3,40(sp)
    80004e58:	bfad                	j	80004dd2 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004e5a:	0049a603          	lw	a2,4(s3)
    80004e5e:	00003597          	auipc	a1,0x3
    80004e62:	83258593          	addi	a1,a1,-1998 # 80007690 <etext+0x690>
    80004e66:	854e                	mv	a0,s3
    80004e68:	d07fe0ef          	jal	80003b6e <dirlink>
    80004e6c:	02054e63          	bltz	a0,80004ea8 <create+0x146>
    80004e70:	40d0                	lw	a2,4(s1)
    80004e72:	00003597          	auipc	a1,0x3
    80004e76:	82658593          	addi	a1,a1,-2010 # 80007698 <etext+0x698>
    80004e7a:	854e                	mv	a0,s3
    80004e7c:	cf3fe0ef          	jal	80003b6e <dirlink>
    80004e80:	02054463          	bltz	a0,80004ea8 <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004e84:	0049a603          	lw	a2,4(s3)
    80004e88:	fb040593          	addi	a1,s0,-80
    80004e8c:	8526                	mv	a0,s1
    80004e8e:	ce1fe0ef          	jal	80003b6e <dirlink>
    80004e92:	00054b63          	bltz	a0,80004ea8 <create+0x146>
    dp->nlink++; // for ".."
    80004e96:	04a4d783          	lhu	a5,74(s1)
    80004e9a:	2785                	addiw	a5,a5,1
    80004e9c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ea0:	8526                	mv	a0,s1
    80004ea2:	c28fe0ef          	jal	800032ca <iupdate>
    80004ea6:	bf71                	j	80004e42 <create+0xe0>
  ip->nlink = 0;
    80004ea8:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004eac:	854e                	mv	a0,s3
    80004eae:	c1cfe0ef          	jal	800032ca <iupdate>
  iunlockput(ip);
    80004eb2:	854e                	mv	a0,s3
    80004eb4:	f1efe0ef          	jal	800035d2 <iunlockput>
  iunlockput(dp);
    80004eb8:	8526                	mv	a0,s1
    80004eba:	f18fe0ef          	jal	800035d2 <iunlockput>
  return 0;
    80004ebe:	79a2                	ld	s3,40(sp)
    80004ec0:	bf09                	j	80004dd2 <create+0x70>
    return 0;
    80004ec2:	892a                	mv	s2,a0
    80004ec4:	b739                	j	80004dd2 <create+0x70>

0000000080004ec6 <sys_dup>:
{
    80004ec6:	7179                	addi	sp,sp,-48
    80004ec8:	f406                	sd	ra,40(sp)
    80004eca:	f022                	sd	s0,32(sp)
    80004ecc:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004ece:	fd840613          	addi	a2,s0,-40
    80004ed2:	4581                	li	a1,0
    80004ed4:	4501                	li	a0,0
    80004ed6:	df3ff0ef          	jal	80004cc8 <argfd>
    return -1;
    80004eda:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004edc:	02054363          	bltz	a0,80004f02 <sys_dup+0x3c>
    80004ee0:	ec26                	sd	s1,24(sp)
    80004ee2:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004ee4:	fd843483          	ld	s1,-40(s0)
    80004ee8:	8526                	mv	a0,s1
    80004eea:	e39ff0ef          	jal	80004d22 <fdalloc>
    80004eee:	892a                	mv	s2,a0
    return -1;
    80004ef0:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004ef2:	00054d63          	bltz	a0,80004f0c <sys_dup+0x46>
  filedup(f);
    80004ef6:	8526                	mv	a0,s1
    80004ef8:	b72ff0ef          	jal	8000426a <filedup>
  return fd;
    80004efc:	87ca                	mv	a5,s2
    80004efe:	64e2                	ld	s1,24(sp)
    80004f00:	6942                	ld	s2,16(sp)
}
    80004f02:	853e                	mv	a0,a5
    80004f04:	70a2                	ld	ra,40(sp)
    80004f06:	7402                	ld	s0,32(sp)
    80004f08:	6145                	addi	sp,sp,48
    80004f0a:	8082                	ret
    80004f0c:	64e2                	ld	s1,24(sp)
    80004f0e:	6942                	ld	s2,16(sp)
    80004f10:	bfcd                	j	80004f02 <sys_dup+0x3c>

0000000080004f12 <sys_read>:
{
    80004f12:	7179                	addi	sp,sp,-48
    80004f14:	f406                	sd	ra,40(sp)
    80004f16:	f022                	sd	s0,32(sp)
    80004f18:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f1a:	fd840593          	addi	a1,s0,-40
    80004f1e:	4505                	li	a0,1
    80004f20:	a5dfd0ef          	jal	8000297c <argaddr>
  argint(2, &n);
    80004f24:	fe440593          	addi	a1,s0,-28
    80004f28:	4509                	li	a0,2
    80004f2a:	a37fd0ef          	jal	80002960 <argint>
  if (argfd(0, 0, &f) < 0)
    80004f2e:	fe840613          	addi	a2,s0,-24
    80004f32:	4581                	li	a1,0
    80004f34:	4501                	li	a0,0
    80004f36:	d93ff0ef          	jal	80004cc8 <argfd>
    80004f3a:	87aa                	mv	a5,a0
    return -1;
    80004f3c:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004f3e:	0007ca63          	bltz	a5,80004f52 <sys_read+0x40>
  return fileread(f, p, n);
    80004f42:	fe442603          	lw	a2,-28(s0)
    80004f46:	fd843583          	ld	a1,-40(s0)
    80004f4a:	fe843503          	ld	a0,-24(s0)
    80004f4e:	c94ff0ef          	jal	800043e2 <fileread>
}
    80004f52:	70a2                	ld	ra,40(sp)
    80004f54:	7402                	ld	s0,32(sp)
    80004f56:	6145                	addi	sp,sp,48
    80004f58:	8082                	ret

0000000080004f5a <sys_write>:
{
    80004f5a:	7179                	addi	sp,sp,-48
    80004f5c:	f406                	sd	ra,40(sp)
    80004f5e:	f022                	sd	s0,32(sp)
    80004f60:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f62:	fd840593          	addi	a1,s0,-40
    80004f66:	4505                	li	a0,1
    80004f68:	a15fd0ef          	jal	8000297c <argaddr>
  argint(2, &n);
    80004f6c:	fe440593          	addi	a1,s0,-28
    80004f70:	4509                	li	a0,2
    80004f72:	9effd0ef          	jal	80002960 <argint>
  if (argfd(0, 0, &f) < 0)
    80004f76:	fe840613          	addi	a2,s0,-24
    80004f7a:	4581                	li	a1,0
    80004f7c:	4501                	li	a0,0
    80004f7e:	d4bff0ef          	jal	80004cc8 <argfd>
    80004f82:	87aa                	mv	a5,a0
    return -1;
    80004f84:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004f86:	0007ca63          	bltz	a5,80004f9a <sys_write+0x40>
  return filewrite(f, p, n);
    80004f8a:	fe442603          	lw	a2,-28(s0)
    80004f8e:	fd843583          	ld	a1,-40(s0)
    80004f92:	fe843503          	ld	a0,-24(s0)
    80004f96:	d1aff0ef          	jal	800044b0 <filewrite>
}
    80004f9a:	70a2                	ld	ra,40(sp)
    80004f9c:	7402                	ld	s0,32(sp)
    80004f9e:	6145                	addi	sp,sp,48
    80004fa0:	8082                	ret

0000000080004fa2 <sys_close>:
{
    80004fa2:	1101                	addi	sp,sp,-32
    80004fa4:	ec06                	sd	ra,24(sp)
    80004fa6:	e822                	sd	s0,16(sp)
    80004fa8:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004faa:	fe040613          	addi	a2,s0,-32
    80004fae:	fec40593          	addi	a1,s0,-20
    80004fb2:	4501                	li	a0,0
    80004fb4:	d15ff0ef          	jal	80004cc8 <argfd>
    return -1;
    80004fb8:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004fba:	02054163          	bltz	a0,80004fdc <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004fbe:	a5bfc0ef          	jal	80001a18 <myproc>
    80004fc2:	fec42783          	lw	a5,-20(s0)
    80004fc6:	078e                	slli	a5,a5,0x3
    80004fc8:	0d078793          	addi	a5,a5,208
    80004fcc:	953e                	add	a0,a0,a5
    80004fce:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004fd2:	fe043503          	ld	a0,-32(s0)
    80004fd6:	adaff0ef          	jal	800042b0 <fileclose>
  return 0;
    80004fda:	4781                	li	a5,0
}
    80004fdc:	853e                	mv	a0,a5
    80004fde:	60e2                	ld	ra,24(sp)
    80004fe0:	6442                	ld	s0,16(sp)
    80004fe2:	6105                	addi	sp,sp,32
    80004fe4:	8082                	ret

0000000080004fe6 <sys_fstat>:
{
    80004fe6:	1101                	addi	sp,sp,-32
    80004fe8:	ec06                	sd	ra,24(sp)
    80004fea:	e822                	sd	s0,16(sp)
    80004fec:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004fee:	fe040593          	addi	a1,s0,-32
    80004ff2:	4505                	li	a0,1
    80004ff4:	989fd0ef          	jal	8000297c <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004ff8:	fe840613          	addi	a2,s0,-24
    80004ffc:	4581                	li	a1,0
    80004ffe:	4501                	li	a0,0
    80005000:	cc9ff0ef          	jal	80004cc8 <argfd>
    80005004:	87aa                	mv	a5,a0
    return -1;
    80005006:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005008:	0007c863          	bltz	a5,80005018 <sys_fstat+0x32>
  return filestat(f, st);
    8000500c:	fe043583          	ld	a1,-32(s0)
    80005010:	fe843503          	ld	a0,-24(s0)
    80005014:	b5eff0ef          	jal	80004372 <filestat>
}
    80005018:	60e2                	ld	ra,24(sp)
    8000501a:	6442                	ld	s0,16(sp)
    8000501c:	6105                	addi	sp,sp,32
    8000501e:	8082                	ret

0000000080005020 <sys_link>:
{
    80005020:	7169                	addi	sp,sp,-304
    80005022:	f606                	sd	ra,296(sp)
    80005024:	f222                	sd	s0,288(sp)
    80005026:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005028:	08000613          	li	a2,128
    8000502c:	ed040593          	addi	a1,s0,-304
    80005030:	4501                	li	a0,0
    80005032:	967fd0ef          	jal	80002998 <argstr>
    return -1;
    80005036:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005038:	10054163          	bltz	a0,8000513a <sys_link+0x11a>
    8000503c:	08000613          	li	a2,128
    80005040:	f5040593          	addi	a1,s0,-176
    80005044:	4505                	li	a0,1
    80005046:	953fd0ef          	jal	80002998 <argstr>
    return -1;
    8000504a:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000504c:	0e054763          	bltz	a0,8000513a <sys_link+0x11a>
    80005050:	ee26                	sd	s1,280(sp)
  begin_op();
    80005052:	da5fe0ef          	jal	80003df6 <begin_op>
  if ((ip = namei(old)) == 0) {
    80005056:	ed040513          	addi	a0,s0,-304
    8000505a:	bbffe0ef          	jal	80003c18 <namei>
    8000505e:	84aa                	mv	s1,a0
    80005060:	cd35                	beqz	a0,800050dc <sys_link+0xbc>
  ilock(ip);
    80005062:	b1cfe0ef          	jal	8000337e <ilock>
  if (ip->type == T_DIR) {
    80005066:	04449703          	lh	a4,68(s1)
    8000506a:	4785                	li	a5,1
    8000506c:	06f70d63          	beq	a4,a5,800050e6 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80005070:	04a49783          	lh	a5,74(s1)
    80005074:	6721                	lui	a4,0x8
    80005076:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80005078:	06e78f63          	beq	a5,a4,800050f6 <sys_link+0xd6>
    8000507c:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000507e:	2785                	addiw	a5,a5,1
    80005080:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005084:	8526                	mv	a0,s1
    80005086:	a44fe0ef          	jal	800032ca <iupdate>
  iunlock(ip);
    8000508a:	8526                	mv	a0,s1
    8000508c:	ba0fe0ef          	jal	8000342c <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80005090:	fd040593          	addi	a1,s0,-48
    80005094:	f5040513          	addi	a0,s0,-176
    80005098:	b9bfe0ef          	jal	80003c32 <nameiparent>
    8000509c:	892a                	mv	s2,a0
    8000509e:	c93d                	beqz	a0,80005114 <sys_link+0xf4>
  ilock(dp);
    800050a0:	adefe0ef          	jal	8000337e <ilock>
  if (dp->nlink == 0) {
    800050a4:	04a91783          	lh	a5,74(s2)
    800050a8:	cfb9                	beqz	a5,80005106 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    800050aa:	854a                	mv	a0,s2
    800050ac:	00092703          	lw	a4,0(s2)
    800050b0:	409c                	lw	a5,0(s1)
    800050b2:	04f71e63          	bne	a4,a5,8000510e <sys_link+0xee>
    800050b6:	40d0                	lw	a2,4(s1)
    800050b8:	fd040593          	addi	a1,s0,-48
    800050bc:	ab3fe0ef          	jal	80003b6e <dirlink>
    800050c0:	04054763          	bltz	a0,8000510e <sys_link+0xee>
  iunlockput(dp);
    800050c4:	854a                	mv	a0,s2
    800050c6:	d0cfe0ef          	jal	800035d2 <iunlockput>
  iput(ip);
    800050ca:	8526                	mv	a0,s1
    800050cc:	c34fe0ef          	jal	80003500 <iput>
  end_op();
    800050d0:	db3fe0ef          	jal	80003e82 <end_op>
  return 0;
    800050d4:	4781                	li	a5,0
    800050d6:	64f2                	ld	s1,280(sp)
    800050d8:	6952                	ld	s2,272(sp)
    800050da:	a085                	j	8000513a <sys_link+0x11a>
    end_op();
    800050dc:	da7fe0ef          	jal	80003e82 <end_op>
    return -1;
    800050e0:	57fd                	li	a5,-1
    800050e2:	64f2                	ld	s1,280(sp)
    800050e4:	a899                	j	8000513a <sys_link+0x11a>
    iunlockput(ip);
    800050e6:	8526                	mv	a0,s1
    800050e8:	ceafe0ef          	jal	800035d2 <iunlockput>
    end_op();
    800050ec:	d97fe0ef          	jal	80003e82 <end_op>
    return -1;
    800050f0:	57fd                	li	a5,-1
    800050f2:	64f2                	ld	s1,280(sp)
    800050f4:	a099                	j	8000513a <sys_link+0x11a>
    iunlockput(ip);
    800050f6:	8526                	mv	a0,s1
    800050f8:	cdafe0ef          	jal	800035d2 <iunlockput>
    end_op();
    800050fc:	d87fe0ef          	jal	80003e82 <end_op>
    return -1;
    80005100:	57fd                	li	a5,-1
    80005102:	64f2                	ld	s1,280(sp)
    80005104:	a81d                	j	8000513a <sys_link+0x11a>
    iunlockput(dp);
    80005106:	854a                	mv	a0,s2
    80005108:	ccafe0ef          	jal	800035d2 <iunlockput>
    goto bad;
    8000510c:	a021                	j	80005114 <sys_link+0xf4>
    iunlockput(dp);
    8000510e:	854a                	mv	a0,s2
    80005110:	cc2fe0ef          	jal	800035d2 <iunlockput>
  ilock(ip);
    80005114:	8526                	mv	a0,s1
    80005116:	a68fe0ef          	jal	8000337e <ilock>
  ip->nlink--;
    8000511a:	04a4d783          	lhu	a5,74(s1)
    8000511e:	37fd                	addiw	a5,a5,-1
    80005120:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005124:	8526                	mv	a0,s1
    80005126:	9a4fe0ef          	jal	800032ca <iupdate>
  iunlockput(ip);
    8000512a:	8526                	mv	a0,s1
    8000512c:	ca6fe0ef          	jal	800035d2 <iunlockput>
  end_op();
    80005130:	d53fe0ef          	jal	80003e82 <end_op>
  return -1;
    80005134:	57fd                	li	a5,-1
    80005136:	64f2                	ld	s1,280(sp)
    80005138:	6952                	ld	s2,272(sp)
}
    8000513a:	853e                	mv	a0,a5
    8000513c:	70b2                	ld	ra,296(sp)
    8000513e:	7412                	ld	s0,288(sp)
    80005140:	6155                	addi	sp,sp,304
    80005142:	8082                	ret

0000000080005144 <sys_unlink>:
{
    80005144:	7151                	addi	sp,sp,-240
    80005146:	f586                	sd	ra,232(sp)
    80005148:	f1a2                	sd	s0,224(sp)
    8000514a:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    8000514c:	08000613          	li	a2,128
    80005150:	f3040593          	addi	a1,s0,-208
    80005154:	4501                	li	a0,0
    80005156:	843fd0ef          	jal	80002998 <argstr>
    8000515a:	14054d63          	bltz	a0,800052b4 <sys_unlink+0x170>
    8000515e:	eda6                	sd	s1,216(sp)
  begin_op();
    80005160:	c97fe0ef          	jal	80003df6 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80005164:	fb040593          	addi	a1,s0,-80
    80005168:	f3040513          	addi	a0,s0,-208
    8000516c:	ac7fe0ef          	jal	80003c32 <nameiparent>
    80005170:	84aa                	mv	s1,a0
    80005172:	c955                	beqz	a0,80005226 <sys_unlink+0xe2>
  ilock(dp);
    80005174:	a0afe0ef          	jal	8000337e <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005178:	00002597          	auipc	a1,0x2
    8000517c:	51858593          	addi	a1,a1,1304 # 80007690 <etext+0x690>
    80005180:	fb040513          	addi	a0,s0,-80
    80005184:	fccfe0ef          	jal	80003950 <namecmp>
    80005188:	10050b63          	beqz	a0,8000529e <sys_unlink+0x15a>
    8000518c:	00002597          	auipc	a1,0x2
    80005190:	50c58593          	addi	a1,a1,1292 # 80007698 <etext+0x698>
    80005194:	fb040513          	addi	a0,s0,-80
    80005198:	fb8fe0ef          	jal	80003950 <namecmp>
    8000519c:	10050163          	beqz	a0,8000529e <sys_unlink+0x15a>
    800051a0:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    800051a2:	f2c40613          	addi	a2,s0,-212
    800051a6:	fb040593          	addi	a1,s0,-80
    800051aa:	8526                	mv	a0,s1
    800051ac:	fbafe0ef          	jal	80003966 <dirlookup>
    800051b0:	892a                	mv	s2,a0
    800051b2:	0e050563          	beqz	a0,8000529c <sys_unlink+0x158>
    800051b6:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800051b8:	9c6fe0ef          	jal	8000337e <ilock>
  if (ip->nlink < 1)
    800051bc:	04a91783          	lh	a5,74(s2)
    800051c0:	06f05863          	blez	a5,80005230 <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    800051c4:	04491703          	lh	a4,68(s2)
    800051c8:	4785                	li	a5,1
    800051ca:	06f70963          	beq	a4,a5,8000523c <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    800051ce:	fc040993          	addi	s3,s0,-64
    800051d2:	4641                	li	a2,16
    800051d4:	4581                	li	a1,0
    800051d6:	854e                	mv	a0,s3
    800051d8:	b11fb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051dc:	4741                	li	a4,16
    800051de:	f2c42683          	lw	a3,-212(s0)
    800051e2:	864e                	mv	a2,s3
    800051e4:	4581                	li	a1,0
    800051e6:	8526                	mv	a0,s1
    800051e8:	e62fe0ef          	jal	8000384a <writei>
    800051ec:	47c1                	li	a5,16
    800051ee:	08f51863          	bne	a0,a5,8000527e <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    800051f2:	04491703          	lh	a4,68(s2)
    800051f6:	4785                	li	a5,1
    800051f8:	08f70963          	beq	a4,a5,8000528a <sys_unlink+0x146>
  iunlockput(dp);
    800051fc:	8526                	mv	a0,s1
    800051fe:	bd4fe0ef          	jal	800035d2 <iunlockput>
  ip->nlink--;
    80005202:	04a95783          	lhu	a5,74(s2)
    80005206:	37fd                	addiw	a5,a5,-1
    80005208:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000520c:	854a                	mv	a0,s2
    8000520e:	8bcfe0ef          	jal	800032ca <iupdate>
  iunlockput(ip);
    80005212:	854a                	mv	a0,s2
    80005214:	bbefe0ef          	jal	800035d2 <iunlockput>
  end_op();
    80005218:	c6bfe0ef          	jal	80003e82 <end_op>
  return 0;
    8000521c:	4501                	li	a0,0
    8000521e:	64ee                	ld	s1,216(sp)
    80005220:	694e                	ld	s2,208(sp)
    80005222:	69ae                	ld	s3,200(sp)
    80005224:	a061                	j	800052ac <sys_unlink+0x168>
    end_op();
    80005226:	c5dfe0ef          	jal	80003e82 <end_op>
    return -1;
    8000522a:	557d                	li	a0,-1
    8000522c:	64ee                	ld	s1,216(sp)
    8000522e:	a8bd                	j	800052ac <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005230:	00002517          	auipc	a0,0x2
    80005234:	47050513          	addi	a0,a0,1136 # 800076a0 <etext+0x6a0>
    80005238:	dfcfb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000523c:	04c92703          	lw	a4,76(s2)
    80005240:	02000793          	li	a5,32
    80005244:	f8e7f5e3          	bgeu	a5,a4,800051ce <sys_unlink+0x8a>
    80005248:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000524a:	4741                	li	a4,16
    8000524c:	86ce                	mv	a3,s3
    8000524e:	f1840613          	addi	a2,s0,-232
    80005252:	4581                	li	a1,0
    80005254:	854a                	mv	a0,s2
    80005256:	d02fe0ef          	jal	80003758 <readi>
    8000525a:	47c1                	li	a5,16
    8000525c:	00f51b63          	bne	a0,a5,80005272 <sys_unlink+0x12e>
    if (de.inum != 0)
    80005260:	f1845783          	lhu	a5,-232(s0)
    80005264:	ebb1                	bnez	a5,800052b8 <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005266:	29c1                	addiw	s3,s3,16
    80005268:	04c92783          	lw	a5,76(s2)
    8000526c:	fcf9efe3          	bltu	s3,a5,8000524a <sys_unlink+0x106>
    80005270:	bfb9                	j	800051ce <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005272:	00002517          	auipc	a0,0x2
    80005276:	44650513          	addi	a0,a0,1094 # 800076b8 <etext+0x6b8>
    8000527a:	dbafb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    8000527e:	00002517          	auipc	a0,0x2
    80005282:	45250513          	addi	a0,a0,1106 # 800076d0 <etext+0x6d0>
    80005286:	daefb0ef          	jal	80000834 <panic>
    dp->nlink--;
    8000528a:	04a4d783          	lhu	a5,74(s1)
    8000528e:	37fd                	addiw	a5,a5,-1
    80005290:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005294:	8526                	mv	a0,s1
    80005296:	834fe0ef          	jal	800032ca <iupdate>
    8000529a:	b78d                	j	800051fc <sys_unlink+0xb8>
    8000529c:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000529e:	8526                	mv	a0,s1
    800052a0:	b32fe0ef          	jal	800035d2 <iunlockput>
  end_op();
    800052a4:	bdffe0ef          	jal	80003e82 <end_op>
  return -1;
    800052a8:	557d                	li	a0,-1
    800052aa:	64ee                	ld	s1,216(sp)
}
    800052ac:	70ae                	ld	ra,232(sp)
    800052ae:	740e                	ld	s0,224(sp)
    800052b0:	616d                	addi	sp,sp,240
    800052b2:	8082                	ret
    return -1;
    800052b4:	557d                	li	a0,-1
    800052b6:	bfdd                	j	800052ac <sys_unlink+0x168>
    iunlockput(ip);
    800052b8:	854a                	mv	a0,s2
    800052ba:	b18fe0ef          	jal	800035d2 <iunlockput>
    goto bad;
    800052be:	694e                	ld	s2,208(sp)
    800052c0:	69ae                	ld	s3,200(sp)
    800052c2:	bff1                	j	8000529e <sys_unlink+0x15a>

00000000800052c4 <sys_open>:

uint64
sys_open(void)
{
    800052c4:	7131                	addi	sp,sp,-192
    800052c6:	fd06                	sd	ra,184(sp)
    800052c8:	f922                	sd	s0,176(sp)
    800052ca:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800052cc:	f4c40593          	addi	a1,s0,-180
    800052d0:	4505                	li	a0,1
    800052d2:	e8efd0ef          	jal	80002960 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800052d6:	08000613          	li	a2,128
    800052da:	f5040593          	addi	a1,s0,-176
    800052de:	4501                	li	a0,0
    800052e0:	eb8fd0ef          	jal	80002998 <argstr>
    800052e4:	87aa                	mv	a5,a0
    return -1;
    800052e6:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800052e8:	0a07c363          	bltz	a5,8000538e <sys_open+0xca>
    800052ec:	f526                	sd	s1,168(sp)

  begin_op();
    800052ee:	b09fe0ef          	jal	80003df6 <begin_op>

  if (omode & O_CREATE) {
    800052f2:	f4c42783          	lw	a5,-180(s0)
    800052f6:	2007f793          	andi	a5,a5,512
    800052fa:	c3dd                	beqz	a5,800053a0 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800052fc:	4681                	li	a3,0
    800052fe:	4601                	li	a2,0
    80005300:	4589                	li	a1,2
    80005302:	f5040513          	addi	a0,s0,-176
    80005306:	a5dff0ef          	jal	80004d62 <create>
    8000530a:	84aa                	mv	s1,a0
    if (ip == 0) {
    8000530c:	c549                	beqz	a0,80005396 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    8000530e:	04449703          	lh	a4,68(s1)
    80005312:	478d                	li	a5,3
    80005314:	00f71763          	bne	a4,a5,80005322 <sys_open+0x5e>
    80005318:	0464d703          	lhu	a4,70(s1)
    8000531c:	47a5                	li	a5,9
    8000531e:	0ae7ee63          	bltu	a5,a4,800053da <sys_open+0x116>
    80005322:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    80005324:	ee9fe0ef          	jal	8000420c <filealloc>
    80005328:	892a                	mv	s2,a0
    8000532a:	c561                	beqz	a0,800053f2 <sys_open+0x12e>
    8000532c:	ed4e                	sd	s3,152(sp)
    8000532e:	9f5ff0ef          	jal	80004d22 <fdalloc>
    80005332:	89aa                	mv	s3,a0
    80005334:	0a054b63          	bltz	a0,800053ea <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    80005338:	04449703          	lh	a4,68(s1)
    8000533c:	478d                	li	a5,3
    8000533e:	0cf70363          	beq	a4,a5,80005404 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005342:	4789                	li	a5,2
    80005344:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005348:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000534c:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005350:	f4c42783          	lw	a5,-180(s0)
    80005354:	0017f713          	andi	a4,a5,1
    80005358:	00174713          	xori	a4,a4,1
    8000535c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005360:	0037f713          	andi	a4,a5,3
    80005364:	00e03733          	snez	a4,a4
    80005368:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    8000536c:	4007f793          	andi	a5,a5,1024
    80005370:	c791                	beqz	a5,8000537c <sys_open+0xb8>
    80005372:	04449703          	lh	a4,68(s1)
    80005376:	4789                	li	a5,2
    80005378:	08f70d63          	beq	a4,a5,80005412 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    8000537c:	8526                	mv	a0,s1
    8000537e:	8aefe0ef          	jal	8000342c <iunlock>
  end_op();
    80005382:	b01fe0ef          	jal	80003e82 <end_op>

  return fd;
    80005386:	854e                	mv	a0,s3
    80005388:	74aa                	ld	s1,168(sp)
    8000538a:	790a                	ld	s2,160(sp)
    8000538c:	69ea                	ld	s3,152(sp)
}
    8000538e:	70ea                	ld	ra,184(sp)
    80005390:	744a                	ld	s0,176(sp)
    80005392:	6129                	addi	sp,sp,192
    80005394:	8082                	ret
      end_op();
    80005396:	aedfe0ef          	jal	80003e82 <end_op>
      return -1;
    8000539a:	557d                	li	a0,-1
    8000539c:	74aa                	ld	s1,168(sp)
    8000539e:	bfc5                	j	8000538e <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    800053a0:	f5040513          	addi	a0,s0,-176
    800053a4:	875fe0ef          	jal	80003c18 <namei>
    800053a8:	84aa                	mv	s1,a0
    800053aa:	c11d                	beqz	a0,800053d0 <sys_open+0x10c>
    ilock(ip);
    800053ac:	fd3fd0ef          	jal	8000337e <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    800053b0:	04449703          	lh	a4,68(s1)
    800053b4:	4785                	li	a5,1
    800053b6:	f4f71ce3          	bne	a4,a5,8000530e <sys_open+0x4a>
    800053ba:	f4c42783          	lw	a5,-180(s0)
    800053be:	d3b5                	beqz	a5,80005322 <sys_open+0x5e>
      iunlockput(ip);
    800053c0:	8526                	mv	a0,s1
    800053c2:	a10fe0ef          	jal	800035d2 <iunlockput>
      end_op();
    800053c6:	abdfe0ef          	jal	80003e82 <end_op>
      return -1;
    800053ca:	557d                	li	a0,-1
    800053cc:	74aa                	ld	s1,168(sp)
    800053ce:	b7c1                	j	8000538e <sys_open+0xca>
      end_op();
    800053d0:	ab3fe0ef          	jal	80003e82 <end_op>
      return -1;
    800053d4:	557d                	li	a0,-1
    800053d6:	74aa                	ld	s1,168(sp)
    800053d8:	bf5d                	j	8000538e <sys_open+0xca>
    iunlockput(ip);
    800053da:	8526                	mv	a0,s1
    800053dc:	9f6fe0ef          	jal	800035d2 <iunlockput>
    end_op();
    800053e0:	aa3fe0ef          	jal	80003e82 <end_op>
    return -1;
    800053e4:	557d                	li	a0,-1
    800053e6:	74aa                	ld	s1,168(sp)
    800053e8:	b75d                	j	8000538e <sys_open+0xca>
      fileclose(f);
    800053ea:	854a                	mv	a0,s2
    800053ec:	ec5fe0ef          	jal	800042b0 <fileclose>
    800053f0:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800053f2:	8526                	mv	a0,s1
    800053f4:	9defe0ef          	jal	800035d2 <iunlockput>
    end_op();
    800053f8:	a8bfe0ef          	jal	80003e82 <end_op>
    return -1;
    800053fc:	557d                	li	a0,-1
    800053fe:	74aa                	ld	s1,168(sp)
    80005400:	790a                	ld	s2,160(sp)
    80005402:	b771                	j	8000538e <sys_open+0xca>
    f->type = FD_DEVICE;
    80005404:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005408:	04649783          	lh	a5,70(s1)
    8000540c:	02f91223          	sh	a5,36(s2)
    80005410:	bf35                	j	8000534c <sys_open+0x88>
    itrunc(ip);
    80005412:	8526                	mv	a0,s1
    80005414:	858fe0ef          	jal	8000346c <itrunc>
    80005418:	b795                	j	8000537c <sys_open+0xb8>

000000008000541a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000541a:	7175                	addi	sp,sp,-144
    8000541c:	e506                	sd	ra,136(sp)
    8000541e:	e122                	sd	s0,128(sp)
    80005420:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005422:	9d5fe0ef          	jal	80003df6 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    80005426:	08000613          	li	a2,128
    8000542a:	f7040593          	addi	a1,s0,-144
    8000542e:	4501                	li	a0,0
    80005430:	d68fd0ef          	jal	80002998 <argstr>
    80005434:	02054363          	bltz	a0,8000545a <sys_mkdir+0x40>
    80005438:	4681                	li	a3,0
    8000543a:	4601                	li	a2,0
    8000543c:	4585                	li	a1,1
    8000543e:	f7040513          	addi	a0,s0,-144
    80005442:	921ff0ef          	jal	80004d62 <create>
    80005446:	c911                	beqz	a0,8000545a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005448:	98afe0ef          	jal	800035d2 <iunlockput>
  end_op();
    8000544c:	a37fe0ef          	jal	80003e82 <end_op>
  return 0;
    80005450:	4501                	li	a0,0
}
    80005452:	60aa                	ld	ra,136(sp)
    80005454:	640a                	ld	s0,128(sp)
    80005456:	6149                	addi	sp,sp,144
    80005458:	8082                	ret
    end_op();
    8000545a:	a29fe0ef          	jal	80003e82 <end_op>
    return -1;
    8000545e:	557d                	li	a0,-1
    80005460:	bfcd                	j	80005452 <sys_mkdir+0x38>

0000000080005462 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005462:	7135                	addi	sp,sp,-160
    80005464:	ed06                	sd	ra,152(sp)
    80005466:	e922                	sd	s0,144(sp)
    80005468:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000546a:	98dfe0ef          	jal	80003df6 <begin_op>
  argint(1, &major);
    8000546e:	f6c40593          	addi	a1,s0,-148
    80005472:	4505                	li	a0,1
    80005474:	cecfd0ef          	jal	80002960 <argint>
  argint(2, &minor);
    80005478:	f6840593          	addi	a1,s0,-152
    8000547c:	4509                	li	a0,2
    8000547e:	ce2fd0ef          	jal	80002960 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005482:	08000613          	li	a2,128
    80005486:	f7040593          	addi	a1,s0,-144
    8000548a:	4501                	li	a0,0
    8000548c:	d0cfd0ef          	jal	80002998 <argstr>
    80005490:	02054563          	bltz	a0,800054ba <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005494:	f6841683          	lh	a3,-152(s0)
    80005498:	f6c41603          	lh	a2,-148(s0)
    8000549c:	458d                	li	a1,3
    8000549e:	f7040513          	addi	a0,s0,-144
    800054a2:	8c1ff0ef          	jal	80004d62 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800054a6:	c911                	beqz	a0,800054ba <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054a8:	92afe0ef          	jal	800035d2 <iunlockput>
  end_op();
    800054ac:	9d7fe0ef          	jal	80003e82 <end_op>
  return 0;
    800054b0:	4501                	li	a0,0
}
    800054b2:	60ea                	ld	ra,152(sp)
    800054b4:	644a                	ld	s0,144(sp)
    800054b6:	610d                	addi	sp,sp,160
    800054b8:	8082                	ret
    end_op();
    800054ba:	9c9fe0ef          	jal	80003e82 <end_op>
    return -1;
    800054be:	557d                	li	a0,-1
    800054c0:	bfcd                	j	800054b2 <sys_mknod+0x50>

00000000800054c2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800054c2:	7135                	addi	sp,sp,-160
    800054c4:	ed06                	sd	ra,152(sp)
    800054c6:	e922                	sd	s0,144(sp)
    800054c8:	e14a                	sd	s2,128(sp)
    800054ca:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800054cc:	d4cfc0ef          	jal	80001a18 <myproc>
    800054d0:	892a                	mv	s2,a0

  begin_op();
    800054d2:	925fe0ef          	jal	80003df6 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    800054d6:	08000613          	li	a2,128
    800054da:	f6040593          	addi	a1,s0,-160
    800054de:	4501                	li	a0,0
    800054e0:	cb8fd0ef          	jal	80002998 <argstr>
    800054e4:	04054363          	bltz	a0,8000552a <sys_chdir+0x68>
    800054e8:	e526                	sd	s1,136(sp)
    800054ea:	f6040513          	addi	a0,s0,-160
    800054ee:	f2afe0ef          	jal	80003c18 <namei>
    800054f2:	84aa                	mv	s1,a0
    800054f4:	c915                	beqz	a0,80005528 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800054f6:	e89fd0ef          	jal	8000337e <ilock>
  if (ip->type != T_DIR) {
    800054fa:	04449703          	lh	a4,68(s1)
    800054fe:	4785                	li	a5,1
    80005500:	02f71963          	bne	a4,a5,80005532 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005504:	8526                	mv	a0,s1
    80005506:	f27fd0ef          	jal	8000342c <iunlock>
  iput(p->cwd);
    8000550a:	15093503          	ld	a0,336(s2)
    8000550e:	ff3fd0ef          	jal	80003500 <iput>
  end_op();
    80005512:	971fe0ef          	jal	80003e82 <end_op>
  p->cwd = ip;
    80005516:	14993823          	sd	s1,336(s2)
  return 0;
    8000551a:	4501                	li	a0,0
    8000551c:	64aa                	ld	s1,136(sp)
}
    8000551e:	60ea                	ld	ra,152(sp)
    80005520:	644a                	ld	s0,144(sp)
    80005522:	690a                	ld	s2,128(sp)
    80005524:	610d                	addi	sp,sp,160
    80005526:	8082                	ret
    80005528:	64aa                	ld	s1,136(sp)
    end_op();
    8000552a:	959fe0ef          	jal	80003e82 <end_op>
    return -1;
    8000552e:	557d                	li	a0,-1
    80005530:	b7fd                	j	8000551e <sys_chdir+0x5c>
    iunlockput(ip);
    80005532:	8526                	mv	a0,s1
    80005534:	89efe0ef          	jal	800035d2 <iunlockput>
    end_op();
    80005538:	94bfe0ef          	jal	80003e82 <end_op>
    return -1;
    8000553c:	557d                	li	a0,-1
    8000553e:	64aa                	ld	s1,136(sp)
    80005540:	bff9                	j	8000551e <sys_chdir+0x5c>

0000000080005542 <sys_exec>:

uint64
sys_exec(void)
{
    80005542:	7105                	addi	sp,sp,-480
    80005544:	ef86                	sd	ra,472(sp)
    80005546:	eba2                	sd	s0,464(sp)
    80005548:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000554a:	e2840593          	addi	a1,s0,-472
    8000554e:	4505                	li	a0,1
    80005550:	c2cfd0ef          	jal	8000297c <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    80005554:	08000613          	li	a2,128
    80005558:	f3040593          	addi	a1,s0,-208
    8000555c:	4501                	li	a0,0
    8000555e:	c3afd0ef          	jal	80002998 <argstr>
    80005562:	87aa                	mv	a5,a0
    return -1;
    80005564:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005566:	0e07c063          	bltz	a5,80005646 <sys_exec+0x104>
    8000556a:	e7a6                	sd	s1,456(sp)
    8000556c:	e3ca                	sd	s2,448(sp)
    8000556e:	ff4e                	sd	s3,440(sp)
    80005570:	fb52                	sd	s4,432(sp)
    80005572:	f756                	sd	s5,424(sp)
    80005574:	f35a                	sd	s6,416(sp)
    80005576:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005578:	e3040a13          	addi	s4,s0,-464
    8000557c:	10000613          	li	a2,256
    80005580:	4581                	li	a1,0
    80005582:	8552                	mv	a0,s4
    80005584:	f64fb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    80005588:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    8000558a:	89d2                	mv	s3,s4
    8000558c:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000558e:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005592:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    80005594:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005598:	00391513          	slli	a0,s2,0x3
    8000559c:	85d6                	mv	a1,s5
    8000559e:	e2843783          	ld	a5,-472(s0)
    800055a2:	953e                	add	a0,a0,a5
    800055a4:	b30fd0ef          	jal	800028d4 <fetchaddr>
    800055a8:	02054663          	bltz	a0,800055d4 <sys_exec+0x92>
    if (uarg == 0) {
    800055ac:	e2043783          	ld	a5,-480(s0)
    800055b0:	c7a1                	beqz	a5,800055f8 <sys_exec+0xb6>
    argv[i] = kalloc();
    800055b2:	d9cfb0ef          	jal	80000b4e <kalloc>
    800055b6:	85aa                	mv	a1,a0
    800055b8:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    800055bc:	cd01                	beqz	a0,800055d4 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800055be:	865a                	mv	a2,s6
    800055c0:	e2043503          	ld	a0,-480(s0)
    800055c4:	b5afd0ef          	jal	8000291e <fetchstr>
    800055c8:	00054663          	bltz	a0,800055d4 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    800055cc:	0905                	addi	s2,s2,1
    800055ce:	09a1                	addi	s3,s3,8
    800055d0:	fd7914e3          	bne	s2,s7,80005598 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055d4:	100a0a13          	addi	s4,s4,256
    800055d8:	6088                	ld	a0,0(s1)
    800055da:	cd31                	beqz	a0,80005636 <sys_exec+0xf4>
    kfree(argv[i]);
    800055dc:	c8afb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055e0:	04a1                	addi	s1,s1,8
    800055e2:	ff449be3          	bne	s1,s4,800055d8 <sys_exec+0x96>
  return -1;
    800055e6:	557d                	li	a0,-1
    800055e8:	64be                	ld	s1,456(sp)
    800055ea:	691e                	ld	s2,448(sp)
    800055ec:	79fa                	ld	s3,440(sp)
    800055ee:	7a5a                	ld	s4,432(sp)
    800055f0:	7aba                	ld	s5,424(sp)
    800055f2:	7b1a                	ld	s6,416(sp)
    800055f4:	6bfa                	ld	s7,408(sp)
    800055f6:	a881                	j	80005646 <sys_exec+0x104>
      argv[i] = 0;
    800055f8:	0009079b          	sext.w	a5,s2
    800055fc:	e3040593          	addi	a1,s0,-464
    80005600:	078e                	slli	a5,a5,0x3
    80005602:	97ae                	add	a5,a5,a1
    80005604:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005608:	f3040513          	addi	a0,s0,-208
    8000560c:	b62ff0ef          	jal	8000496e <kexec>
    80005610:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005612:	100a0a13          	addi	s4,s4,256
    80005616:	6088                	ld	a0,0(s1)
    80005618:	c511                	beqz	a0,80005624 <sys_exec+0xe2>
    kfree(argv[i]);
    8000561a:	c4cfb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000561e:	04a1                	addi	s1,s1,8
    80005620:	ff449be3          	bne	s1,s4,80005616 <sys_exec+0xd4>
  return ret;
    80005624:	854a                	mv	a0,s2
    80005626:	64be                	ld	s1,456(sp)
    80005628:	691e                	ld	s2,448(sp)
    8000562a:	79fa                	ld	s3,440(sp)
    8000562c:	7a5a                	ld	s4,432(sp)
    8000562e:	7aba                	ld	s5,424(sp)
    80005630:	7b1a                	ld	s6,416(sp)
    80005632:	6bfa                	ld	s7,408(sp)
    80005634:	a809                	j	80005646 <sys_exec+0x104>
  return -1;
    80005636:	557d                	li	a0,-1
    80005638:	64be                	ld	s1,456(sp)
    8000563a:	691e                	ld	s2,448(sp)
    8000563c:	79fa                	ld	s3,440(sp)
    8000563e:	7a5a                	ld	s4,432(sp)
    80005640:	7aba                	ld	s5,424(sp)
    80005642:	7b1a                	ld	s6,416(sp)
    80005644:	6bfa                	ld	s7,408(sp)
}
    80005646:	60fe                	ld	ra,472(sp)
    80005648:	645e                	ld	s0,464(sp)
    8000564a:	613d                	addi	sp,sp,480
    8000564c:	8082                	ret

000000008000564e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000564e:	7139                	addi	sp,sp,-64
    80005650:	fc06                	sd	ra,56(sp)
    80005652:	f822                	sd	s0,48(sp)
    80005654:	f426                	sd	s1,40(sp)
    80005656:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005658:	bc0fc0ef          	jal	80001a18 <myproc>
    8000565c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000565e:	fd840593          	addi	a1,s0,-40
    80005662:	4501                	li	a0,0
    80005664:	b18fd0ef          	jal	8000297c <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005668:	fc840593          	addi	a1,s0,-56
    8000566c:	fd040513          	addi	a0,s0,-48
    80005670:	f7ffe0ef          	jal	800045ee <pipealloc>
    return -1;
    80005674:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005676:	0a054963          	bltz	a0,80005728 <sys_pipe+0xda>
  fd0 = -1;
    8000567a:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    8000567e:	fd043503          	ld	a0,-48(s0)
    80005682:	ea0ff0ef          	jal	80004d22 <fdalloc>
    80005686:	fca42223          	sw	a0,-60(s0)
    8000568a:	08054663          	bltz	a0,80005716 <sys_pipe+0xc8>
    8000568e:	fc843503          	ld	a0,-56(s0)
    80005692:	e90ff0ef          	jal	80004d22 <fdalloc>
    80005696:	fca42023          	sw	a0,-64(s0)
    8000569a:	06054463          	bltz	a0,80005702 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    8000569e:	4711                	li	a4,4
    800056a0:	fc440693          	addi	a3,s0,-60
    800056a4:	fd843603          	ld	a2,-40(s0)
    800056a8:	64ac                	ld	a1,72(s1)
    800056aa:	68a8                	ld	a0,80(s1)
    800056ac:	ed7fb0ef          	jal	80001582 <copyout>
    800056b0:	00054f63          	bltz	a0,800056ce <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    800056b4:	4711                	li	a4,4
    800056b6:	fc040693          	addi	a3,s0,-64
    800056ba:	fd843603          	ld	a2,-40(s0)
    800056be:	963a                	add	a2,a2,a4
    800056c0:	64ac                	ld	a1,72(s1)
    800056c2:	68a8                	ld	a0,80(s1)
    800056c4:	ebffb0ef          	jal	80001582 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800056c8:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800056ca:	04055f63          	bgez	a0,80005728 <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    800056ce:	fc442783          	lw	a5,-60(s0)
    800056d2:	078e                	slli	a5,a5,0x3
    800056d4:	0d078793          	addi	a5,a5,208
    800056d8:	97a6                	add	a5,a5,s1
    800056da:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800056de:	fc042783          	lw	a5,-64(s0)
    800056e2:	078e                	slli	a5,a5,0x3
    800056e4:	0d078793          	addi	a5,a5,208
    800056e8:	94be                	add	s1,s1,a5
    800056ea:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800056ee:	fd043503          	ld	a0,-48(s0)
    800056f2:	bbffe0ef          	jal	800042b0 <fileclose>
    fileclose(wf);
    800056f6:	fc843503          	ld	a0,-56(s0)
    800056fa:	bb7fe0ef          	jal	800042b0 <fileclose>
    return -1;
    800056fe:	57fd                	li	a5,-1
    80005700:	a025                	j	80005728 <sys_pipe+0xda>
    if (fd0 >= 0)
    80005702:	fc442783          	lw	a5,-60(s0)
    80005706:	0007c863          	bltz	a5,80005716 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    8000570a:	078e                	slli	a5,a5,0x3
    8000570c:	0d078793          	addi	a5,a5,208
    80005710:	97a6                	add	a5,a5,s1
    80005712:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005716:	fd043503          	ld	a0,-48(s0)
    8000571a:	b97fe0ef          	jal	800042b0 <fileclose>
    fileclose(wf);
    8000571e:	fc843503          	ld	a0,-56(s0)
    80005722:	b8ffe0ef          	jal	800042b0 <fileclose>
    return -1;
    80005726:	57fd                	li	a5,-1
}
    80005728:	853e                	mv	a0,a5
    8000572a:	70e2                	ld	ra,56(sp)
    8000572c:	7442                	ld	s0,48(sp)
    8000572e:	74a2                	ld	s1,40(sp)
    80005730:	6121                	addi	sp,sp,64
    80005732:	8082                	ret
	...

0000000080005740 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005740:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005742:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005744:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005746:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005748:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000574a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000574c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000574e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005750:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005752:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005754:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005756:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005758:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000575a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000575c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000575e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005760:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005762:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005764:	87efd0ef          	jal	800027e2 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005768:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000576a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000576c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000576e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005770:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005772:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005774:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005776:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005778:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000577a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000577c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000577e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005780:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005782:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005784:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005786:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005788:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000578a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000578c:	10200073          	sret
    80005790:	0001                	nop
    80005792:	00000013          	nop
    80005796:	00000013          	nop
    8000579a:	00000013          	nop

000000008000579e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000579e:	1141                	addi	sp,sp,-16
    800057a0:	e406                	sd	ra,8(sp)
    800057a2:	e022                	sd	s0,0(sp)
    800057a4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    800057a6:	0c000737          	lui	a4,0xc000
    800057aa:	4785                	li	a5,1
    800057ac:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    800057ae:	c35c                	sw	a5,4(a4)
}
    800057b0:	60a2                	ld	ra,8(sp)
    800057b2:	6402                	ld	s0,0(sp)
    800057b4:	0141                	addi	sp,sp,16
    800057b6:	8082                	ret

00000000800057b8 <plicinithart>:

void
plicinithart(void)
{
    800057b8:	1141                	addi	sp,sp,-16
    800057ba:	e406                	sd	ra,8(sp)
    800057bc:	e022                	sd	s0,0(sp)
    800057be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800057c0:	a24fc0ef          	jal	800019e4 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    800057c4:	0085179b          	slliw	a5,a0,0x8
    800057c8:	0c002737          	lui	a4,0xc002
    800057cc:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    800057d0:	97ba                	add	a5,a5,a4
    800057d2:	40200713          	li	a4,1026
    800057d6:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    800057d8:	00d5151b          	slliw	a0,a0,0xd
    800057dc:	0c2017b7          	lui	a5,0xc201
    800057e0:	953e                	add	a0,a0,a5
    800057e2:	00052023          	sw	zero,0(a0)
}
    800057e6:	60a2                	ld	ra,8(sp)
    800057e8:	6402                	ld	s0,0(sp)
    800057ea:	0141                	addi	sp,sp,16
    800057ec:	8082                	ret

00000000800057ee <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800057ee:	1141                	addi	sp,sp,-16
    800057f0:	e406                	sd	ra,8(sp)
    800057f2:	e022                	sd	s0,0(sp)
    800057f4:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800057f6:	9eefc0ef          	jal	800019e4 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    800057fa:	00d5151b          	slliw	a0,a0,0xd
    800057fe:	0c2017b7          	lui	a5,0xc201
    80005802:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80005804:	953e                	add	a0,a0,a5
    80005806:	4108                	lw	a0,0(a0)
  return irq;
}
    80005808:	60a2                	ld	ra,8(sp)
    8000580a:	6402                	ld	s0,0(sp)
    8000580c:	0141                	addi	sp,sp,16
    8000580e:	8082                	ret

0000000080005810 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005810:	1101                	addi	sp,sp,-32
    80005812:	ec06                	sd	ra,24(sp)
    80005814:	e822                	sd	s0,16(sp)
    80005816:	e426                	sd	s1,8(sp)
    80005818:	1000                	addi	s0,sp,32
    8000581a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000581c:	9c8fc0ef          	jal	800019e4 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    80005820:	00d5179b          	slliw	a5,a0,0xd
    80005824:	0c201737          	lui	a4,0xc201
    80005828:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    8000582a:	97ba                	add	a5,a5,a4
    8000582c:	c384                	sw	s1,0(a5)
}
    8000582e:	60e2                	ld	ra,24(sp)
    80005830:	6442                	ld	s0,16(sp)
    80005832:	64a2                	ld	s1,8(sp)
    80005834:	6105                	addi	sp,sp,32
    80005836:	8082                	ret

0000000080005838 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005838:	1141                	addi	sp,sp,-16
    8000583a:	e406                	sd	ra,8(sp)
    8000583c:	e022                	sd	s0,0(sp)
    8000583e:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005840:	479d                	li	a5,7
    80005842:	04a7ca63          	blt	a5,a0,80005896 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005846:	0001e797          	auipc	a5,0x1e
    8000584a:	df278793          	addi	a5,a5,-526 # 80023638 <disk>
    8000584e:	97aa                	add	a5,a5,a0
    80005850:	0187c783          	lbu	a5,24(a5)
    80005854:	e7b9                	bnez	a5,800058a2 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005856:	00451693          	slli	a3,a0,0x4
    8000585a:	0001e797          	auipc	a5,0x1e
    8000585e:	dde78793          	addi	a5,a5,-546 # 80023638 <disk>
    80005862:	6398                	ld	a4,0(a5)
    80005864:	9736                	add	a4,a4,a3
    80005866:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000586a:	6398                	ld	a4,0(a5)
    8000586c:	9736                	add	a4,a4,a3
    8000586e:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005872:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005876:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000587a:	97aa                	add	a5,a5,a0
    8000587c:	4705                	li	a4,1
    8000587e:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005882:	0001e517          	auipc	a0,0x1e
    80005886:	dce50513          	addi	a0,a0,-562 # 80023650 <disk+0x18>
    8000588a:	805fc0ef          	jal	8000208e <wakeup>
}
    8000588e:	60a2                	ld	ra,8(sp)
    80005890:	6402                	ld	s0,0(sp)
    80005892:	0141                	addi	sp,sp,16
    80005894:	8082                	ret
    panic("free_desc 1");
    80005896:	00002517          	auipc	a0,0x2
    8000589a:	e4a50513          	addi	a0,a0,-438 # 800076e0 <etext+0x6e0>
    8000589e:	f97fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    800058a2:	00002517          	auipc	a0,0x2
    800058a6:	e4e50513          	addi	a0,a0,-434 # 800076f0 <etext+0x6f0>
    800058aa:	f8bfa0ef          	jal	80000834 <panic>

00000000800058ae <virtio_disk_init>:
{
    800058ae:	1101                	addi	sp,sp,-32
    800058b0:	ec06                	sd	ra,24(sp)
    800058b2:	e822                	sd	s0,16(sp)
    800058b4:	e426                	sd	s1,8(sp)
    800058b6:	e04a                	sd	s2,0(sp)
    800058b8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800058ba:	00002597          	auipc	a1,0x2
    800058be:	e4658593          	addi	a1,a1,-442 # 80007700 <etext+0x700>
    800058c2:	0001e517          	auipc	a0,0x1e
    800058c6:	e9e50513          	addi	a0,a0,-354 # 80023760 <disk+0x128>
    800058ca:	adefb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058ce:	100017b7          	lui	a5,0x10001
    800058d2:	4398                	lw	a4,0(a5)
    800058d4:	2701                	sext.w	a4,a4
    800058d6:	747277b7          	lui	a5,0x74727
    800058da:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800058de:	14f71863          	bne	a4,a5,80005a2e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058e2:	100017b7          	lui	a5,0x10001
    800058e6:	43dc                	lw	a5,4(a5)
    800058e8:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058ea:	4709                	li	a4,2
    800058ec:	14e79163          	bne	a5,a4,80005a2e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058f0:	100017b7          	lui	a5,0x10001
    800058f4:	479c                	lw	a5,8(a5)
    800058f6:	2781                	sext.w	a5,a5
    800058f8:	12e79b63          	bne	a5,a4,80005a2e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    800058fc:	100017b7          	lui	a5,0x10001
    80005900:	47d8                	lw	a4,12(a5)
    80005902:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005904:	554d47b7          	lui	a5,0x554d4
    80005908:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000590c:	12f71163          	bne	a4,a5,80005a2e <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005910:	100017b7          	lui	a5,0x10001
    80005914:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005918:	4705                	li	a4,1
    8000591a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000591c:	470d                	li	a4,3
    8000591e:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005920:	10001737          	lui	a4,0x10001
    80005924:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005926:	c7ffe6b7          	lui	a3,0xc7ffe
    8000592a:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdade7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000592e:	8f75                	and	a4,a4,a3
    80005930:	100016b7          	lui	a3,0x10001
    80005934:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005936:	472d                	li	a4,11
    80005938:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000593a:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000593e:	439c                	lw	a5,0(a5)
    80005940:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005944:	8ba1                	andi	a5,a5,8
    80005946:	0e078a63          	beqz	a5,80005a3a <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000594a:	100017b7          	lui	a5,0x10001
    8000594e:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005952:	43fc                	lw	a5,68(a5)
    80005954:	2781                	sext.w	a5,a5
    80005956:	0e079863          	bnez	a5,80005a46 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000595a:	100017b7          	lui	a5,0x10001
    8000595e:	5bdc                	lw	a5,52(a5)
    80005960:	2781                	sext.w	a5,a5
  if (max == 0)
    80005962:	0e078863          	beqz	a5,80005a52 <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005966:	471d                	li	a4,7
    80005968:	0ef77b63          	bgeu	a4,a5,80005a5e <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    8000596c:	9e2fb0ef          	jal	80000b4e <kalloc>
    80005970:	0001e497          	auipc	s1,0x1e
    80005974:	cc848493          	addi	s1,s1,-824 # 80023638 <disk>
    80005978:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    8000597a:	9d4fb0ef          	jal	80000b4e <kalloc>
    8000597e:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005980:	9cefb0ef          	jal	80000b4e <kalloc>
    80005984:	87aa                	mv	a5,a0
    80005986:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005988:	6088                	ld	a0,0(s1)
    8000598a:	0e050063          	beqz	a0,80005a6a <virtio_disk_init+0x1bc>
    8000598e:	0001e717          	auipc	a4,0x1e
    80005992:	cb273703          	ld	a4,-846(a4) # 80023640 <disk+0x8>
    80005996:	cb71                	beqz	a4,80005a6a <virtio_disk_init+0x1bc>
    80005998:	cbe9                	beqz	a5,80005a6a <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    8000599a:	6605                	lui	a2,0x1
    8000599c:	4581                	li	a1,0
    8000599e:	b4afb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800059a2:	0001e497          	auipc	s1,0x1e
    800059a6:	c9648493          	addi	s1,s1,-874 # 80023638 <disk>
    800059aa:	6605                	lui	a2,0x1
    800059ac:	4581                	li	a1,0
    800059ae:	6488                	ld	a0,8(s1)
    800059b0:	b38fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    800059b4:	6605                	lui	a2,0x1
    800059b6:	4581                	li	a1,0
    800059b8:	6888                	ld	a0,16(s1)
    800059ba:	b2efb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800059be:	100017b7          	lui	a5,0x10001
    800059c2:	4721                	li	a4,8
    800059c4:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800059c6:	4098                	lw	a4,0(s1)
    800059c8:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800059cc:	40d8                	lw	a4,4(s1)
    800059ce:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800059d2:	649c                	ld	a5,8(s1)
    800059d4:	0007869b          	sext.w	a3,a5
    800059d8:	10001737          	lui	a4,0x10001
    800059dc:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800059e0:	9781                	srai	a5,a5,0x20
    800059e2:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800059e6:	689c                	ld	a5,16(s1)
    800059e8:	0007869b          	sext.w	a3,a5
    800059ec:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800059f0:	9781                	srai	a5,a5,0x20
    800059f2:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800059f6:	4785                	li	a5,1
    800059f8:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800059fa:	00f48c23          	sb	a5,24(s1)
    800059fe:	00f48ca3          	sb	a5,25(s1)
    80005a02:	00f48d23          	sb	a5,26(s1)
    80005a06:	00f48da3          	sb	a5,27(s1)
    80005a0a:	00f48e23          	sb	a5,28(s1)
    80005a0e:	00f48ea3          	sb	a5,29(s1)
    80005a12:	00f48f23          	sb	a5,30(s1)
    80005a16:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005a1a:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a1e:	07272823          	sw	s2,112(a4)
}
    80005a22:	60e2                	ld	ra,24(sp)
    80005a24:	6442                	ld	s0,16(sp)
    80005a26:	64a2                	ld	s1,8(sp)
    80005a28:	6902                	ld	s2,0(sp)
    80005a2a:	6105                	addi	sp,sp,32
    80005a2c:	8082                	ret
    panic("could not find virtio disk");
    80005a2e:	00002517          	auipc	a0,0x2
    80005a32:	ce250513          	addi	a0,a0,-798 # 80007710 <etext+0x710>
    80005a36:	dfffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005a3a:	00002517          	auipc	a0,0x2
    80005a3e:	cf650513          	addi	a0,a0,-778 # 80007730 <etext+0x730>
    80005a42:	df3fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005a46:	00002517          	auipc	a0,0x2
    80005a4a:	d0a50513          	addi	a0,a0,-758 # 80007750 <etext+0x750>
    80005a4e:	de7fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005a52:	00002517          	auipc	a0,0x2
    80005a56:	d1e50513          	addi	a0,a0,-738 # 80007770 <etext+0x770>
    80005a5a:	ddbfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005a5e:	00002517          	auipc	a0,0x2
    80005a62:	d3250513          	addi	a0,a0,-718 # 80007790 <etext+0x790>
    80005a66:	dcffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005a6a:	00002517          	auipc	a0,0x2
    80005a6e:	d4650513          	addi	a0,a0,-698 # 800077b0 <etext+0x7b0>
    80005a72:	dc3fa0ef          	jal	80000834 <panic>

0000000080005a76 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005a76:	711d                	addi	sp,sp,-96
    80005a78:	ec86                	sd	ra,88(sp)
    80005a7a:	e8a2                	sd	s0,80(sp)
    80005a7c:	e4a6                	sd	s1,72(sp)
    80005a7e:	e0ca                	sd	s2,64(sp)
    80005a80:	fc4e                	sd	s3,56(sp)
    80005a82:	f852                	sd	s4,48(sp)
    80005a84:	f456                	sd	s5,40(sp)
    80005a86:	f05a                	sd	s6,32(sp)
    80005a88:	ec5e                	sd	s7,24(sp)
    80005a8a:	e862                	sd	s8,16(sp)
    80005a8c:	1080                	addi	s0,sp,96
    80005a8e:	89aa                	mv	s3,a0
    80005a90:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005a92:	00c52b83          	lw	s7,12(a0)
    80005a96:	001b9b9b          	slliw	s7,s7,0x1
    80005a9a:	1b82                	slli	s7,s7,0x20
    80005a9c:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005aa0:	0001e517          	auipc	a0,0x1e
    80005aa4:	cc050513          	addi	a0,a0,-832 # 80023760 <disk+0x128>
    80005aa8:	980fb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005aac:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005aae:	0001ea97          	auipc	s5,0x1e
    80005ab2:	b8aa8a93          	addi	s5,s5,-1142 # 80023638 <disk>
  for (int i = 0; i < 3; i++) {
    80005ab6:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005ab8:	5c7d                	li	s8,-1
    80005aba:	a8a5                	j	80005b32 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005abc:	00fa8733          	add	a4,s5,a5
    80005ac0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005ac4:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005ac6:	0207c563          	bltz	a5,80005af0 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005aca:	2905                	addiw	s2,s2,1
    80005acc:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005ace:	07490663          	beq	s2,s4,80005b3a <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005ad2:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005ad4:	0001e717          	auipc	a4,0x1e
    80005ad8:	b6470713          	addi	a4,a4,-1180 # 80023638 <disk>
    80005adc:	4781                	li	a5,0
    if (disk.free[i]) {
    80005ade:	01874683          	lbu	a3,24(a4)
    80005ae2:	fee9                	bnez	a3,80005abc <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005ae4:	2785                	addiw	a5,a5,1
    80005ae6:	0705                	addi	a4,a4,1
    80005ae8:	fe979be3          	bne	a5,s1,80005ade <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005aec:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005af0:	01205d63          	blez	s2,80005b0a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005af4:	fa042503          	lw	a0,-96(s0)
    80005af8:	d41ff0ef          	jal	80005838 <free_desc>
      for (int j = 0; j < i; j++)
    80005afc:	4785                	li	a5,1
    80005afe:	0127d663          	bge	a5,s2,80005b0a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b02:	fa442503          	lw	a0,-92(s0)
    80005b06:	d33ff0ef          	jal	80005838 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005b0a:	0001e517          	auipc	a0,0x1e
    80005b0e:	b4650513          	addi	a0,a0,-1210 # 80023650 <disk+0x18>
    80005b12:	d10fc0ef          	jal	80002022 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005b16:	0001e517          	auipc	a0,0x1e
    80005b1a:	c4a50513          	addi	a0,a0,-950 # 80023760 <disk+0x128>
    80005b1e:	992fb0ef          	jal	80000cb0 <release>
    sleep();
    80005b22:	d3cfc0ef          	jal	8000205e <sleep>
    acquire(&disk.vdisk_lock);
    80005b26:	0001e517          	auipc	a0,0x1e
    80005b2a:	c3a50513          	addi	a0,a0,-966 # 80023760 <disk+0x128>
    80005b2e:	8fafb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005b32:	fa040613          	addi	a2,s0,-96
    80005b36:	4901                	li	s2,0
    80005b38:	bf69                	j	80005ad2 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b3a:	fa042503          	lw	a0,-96(s0)
    80005b3e:	00451693          	slli	a3,a0,0x4

  if (write)
    80005b42:	0001e797          	auipc	a5,0x1e
    80005b46:	af678793          	addi	a5,a5,-1290 # 80023638 <disk>
    80005b4a:	00451713          	slli	a4,a0,0x4
    80005b4e:	0a070713          	addi	a4,a4,160
    80005b52:	973e                	add	a4,a4,a5
    80005b54:	01603633          	snez	a2,s6
    80005b58:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005b5a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005b5e:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005b62:	6398                	ld	a4,0(a5)
    80005b64:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b66:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005b6a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005b6c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005b6e:	6390                	ld	a2,0(a5)
    80005b70:	00d60833          	add	a6,a2,a3
    80005b74:	4741                	li	a4,16
    80005b76:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005b7a:	4585                	li	a1,1
    80005b7c:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005b80:	fa442703          	lw	a4,-92(s0)
    80005b84:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005b88:	0712                	slli	a4,a4,0x4
    80005b8a:	963a                	add	a2,a2,a4
    80005b8c:	05898813          	addi	a6,s3,88
    80005b90:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005b94:	0007b883          	ld	a7,0(a5)
    80005b98:	9746                	add	a4,a4,a7
    80005b9a:	40000613          	li	a2,1024
    80005b9e:	c710                	sw	a2,8(a4)
  if (write)
    80005ba0:	001b3613          	seqz	a2,s6
    80005ba4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005ba8:	8e4d                	or	a2,a2,a1
    80005baa:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005bae:	fa842603          	lw	a2,-88(s0)
    80005bb2:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005bb6:	00451813          	slli	a6,a0,0x4
    80005bba:	02080813          	addi	a6,a6,32
    80005bbe:	983e                	add	a6,a6,a5
    80005bc0:	577d                	li	a4,-1
    80005bc2:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005bc6:	0612                	slli	a2,a2,0x4
    80005bc8:	98b2                	add	a7,a7,a2
    80005bca:	03068713          	addi	a4,a3,48
    80005bce:	973e                	add	a4,a4,a5
    80005bd0:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005bd4:	6398                	ld	a4,0(a5)
    80005bd6:	9732                	add	a4,a4,a2
    80005bd8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005bda:	4689                	li	a3,2
    80005bdc:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005be0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005be4:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005be8:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005bec:	6794                	ld	a3,8(a5)
    80005bee:	0026d703          	lhu	a4,2(a3)
    80005bf2:	8b1d                	andi	a4,a4,7
    80005bf4:	0706                	slli	a4,a4,0x1
    80005bf6:	96ba                	add	a3,a3,a4
    80005bf8:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005bfc:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c00:	6798                	ld	a4,8(a5)
    80005c02:	00275783          	lhu	a5,2(a4)
    80005c06:	2785                	addiw	a5,a5,1
    80005c08:	00f71123          	sh	a5,2(a4)
    80005c0c:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005c10:	100017b7          	lui	a5,0x10001
    80005c14:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005c18:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005c1c:	0001e497          	auipc	s1,0x1e
    80005c20:	b4448493          	addi	s1,s1,-1212 # 80023760 <disk+0x128>
  while (b->disk == 1) {
    80005c24:	892e                	mv	s2,a1
    80005c26:	02b79163          	bne	a5,a1,80005c48 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005c2a:	854e                	mv	a0,s3
    80005c2c:	bf6fc0ef          	jal	80002022 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005c30:	8526                	mv	a0,s1
    80005c32:	87efb0ef          	jal	80000cb0 <release>
    sleep();
    80005c36:	c28fc0ef          	jal	8000205e <sleep>
    acquire(&disk.vdisk_lock);
    80005c3a:	8526                	mv	a0,s1
    80005c3c:	fedfa0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005c40:	0049a783          	lw	a5,4(s3)
    80005c44:	ff2783e3          	beq	a5,s2,80005c2a <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005c48:	fa042903          	lw	s2,-96(s0)
    80005c4c:	00491713          	slli	a4,s2,0x4
    80005c50:	02070713          	addi	a4,a4,32
    80005c54:	0001e797          	auipc	a5,0x1e
    80005c58:	9e478793          	addi	a5,a5,-1564 # 80023638 <disk>
    80005c5c:	97ba                	add	a5,a5,a4
    80005c5e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c62:	0001e997          	auipc	s3,0x1e
    80005c66:	9d698993          	addi	s3,s3,-1578 # 80023638 <disk>
    80005c6a:	00491713          	slli	a4,s2,0x4
    80005c6e:	0009b783          	ld	a5,0(s3)
    80005c72:	97ba                	add	a5,a5,a4
    80005c74:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005c78:	854a                	mv	a0,s2
    80005c7a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005c7e:	bbbff0ef          	jal	80005838 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005c82:	8885                	andi	s1,s1,1
    80005c84:	f0fd                	bnez	s1,80005c6a <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005c86:	0001e517          	auipc	a0,0x1e
    80005c8a:	ada50513          	addi	a0,a0,-1318 # 80023760 <disk+0x128>
    80005c8e:	822fb0ef          	jal	80000cb0 <release>
}
    80005c92:	60e6                	ld	ra,88(sp)
    80005c94:	6446                	ld	s0,80(sp)
    80005c96:	64a6                	ld	s1,72(sp)
    80005c98:	6906                	ld	s2,64(sp)
    80005c9a:	79e2                	ld	s3,56(sp)
    80005c9c:	7a42                	ld	s4,48(sp)
    80005c9e:	7aa2                	ld	s5,40(sp)
    80005ca0:	7b02                	ld	s6,32(sp)
    80005ca2:	6be2                	ld	s7,24(sp)
    80005ca4:	6c42                	ld	s8,16(sp)
    80005ca6:	6125                	addi	sp,sp,96
    80005ca8:	8082                	ret

0000000080005caa <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005caa:	1101                	addi	sp,sp,-32
    80005cac:	ec06                	sd	ra,24(sp)
    80005cae:	e822                	sd	s0,16(sp)
    80005cb0:	e426                	sd	s1,8(sp)
    80005cb2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005cb4:	0001e497          	auipc	s1,0x1e
    80005cb8:	98448493          	addi	s1,s1,-1660 # 80023638 <disk>
    80005cbc:	0001e517          	auipc	a0,0x1e
    80005cc0:	aa450513          	addi	a0,a0,-1372 # 80023760 <disk+0x128>
    80005cc4:	f65fa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005cc8:	100017b7          	lui	a5,0x10001
    80005ccc:	53bc                	lw	a5,96(a5)
    80005cce:	8b8d                	andi	a5,a5,3
    80005cd0:	10001737          	lui	a4,0x10001
    80005cd4:	d37c                	sw	a5,100(a4)
    80005cd6:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005cda:	689c                	ld	a5,16(s1)
    80005cdc:	0204d703          	lhu	a4,32(s1)
    80005ce0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005ce4:	04f70863          	beq	a4,a5,80005d34 <virtio_disk_intr+0x8a>
    80005ce8:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005cec:	6898                	ld	a4,16(s1)
    80005cee:	0204d783          	lhu	a5,32(s1)
    80005cf2:	8b9d                	andi	a5,a5,7
    80005cf4:	078e                	slli	a5,a5,0x3
    80005cf6:	97ba                	add	a5,a5,a4
    80005cf8:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005cfa:	00479713          	slli	a4,a5,0x4
    80005cfe:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005d02:	9726                	add	a4,a4,s1
    80005d04:	01074703          	lbu	a4,16(a4)
    80005d08:	e329                	bnez	a4,80005d4a <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d0a:	0792                	slli	a5,a5,0x4
    80005d0c:	02078793          	addi	a5,a5,32
    80005d10:	97a6                	add	a5,a5,s1
    80005d12:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005d14:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d18:	b76fc0ef          	jal	8000208e <wakeup>

    disk.used_idx += 1;
    80005d1c:	0204d783          	lhu	a5,32(s1)
    80005d20:	2785                	addiw	a5,a5,1
    80005d22:	17c2                	slli	a5,a5,0x30
    80005d24:	93c1                	srli	a5,a5,0x30
    80005d26:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005d2a:	6898                	ld	a4,16(s1)
    80005d2c:	00275703          	lhu	a4,2(a4)
    80005d30:	faf71ce3          	bne	a4,a5,80005ce8 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005d34:	0001e517          	auipc	a0,0x1e
    80005d38:	a2c50513          	addi	a0,a0,-1492 # 80023760 <disk+0x128>
    80005d3c:	f75fa0ef          	jal	80000cb0 <release>
}
    80005d40:	60e2                	ld	ra,24(sp)
    80005d42:	6442                	ld	s0,16(sp)
    80005d44:	64a2                	ld	s1,8(sp)
    80005d46:	6105                	addi	sp,sp,32
    80005d48:	8082                	ret
      panic("virtio_disk_intr status");
    80005d4a:	00002517          	auipc	a0,0x2
    80005d4e:	a7e50513          	addi	a0,a0,-1410 # 800077c8 <etext+0x7c8>
    80005d52:	ae3fa0ef          	jal	80000834 <panic>
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
