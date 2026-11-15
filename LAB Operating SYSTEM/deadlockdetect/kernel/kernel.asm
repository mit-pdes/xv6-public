
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
    80000004:	2b813103          	ld	sp,696(sp) # 8000a2b8 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb1f7>
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
    8000011c:	214020ef          	jal	80002330 <either_copyin>
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
    80000198:	16c50513          	addi	a0,a0,364 # 80012300 <cons>
    8000019c:	28d000ef          	jal	80000c28 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	16048493          	addi	s1,s1,352 # 80012300 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	1f090913          	addi	s2,s2,496 # 80012398 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	788010ef          	jal	80001948 <myproc>
    800001c4:	7ed010ef          	jal	800021b0 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	587010ef          	jal	80001f52 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	5b9010ef          	jal	80001f8e <sleep>
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
    800001f2:	11270713          	addi	a4,a4,274 # 80012300 <cons>
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
    80000220:	0c4020ef          	jal	800022e4 <either_copyout>
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
    8000023c:	0c850513          	addi	a0,a0,200 # 80012300 <cons>
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
    80000262:	12f72d23          	sw	a5,314(a4) # 80012398 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	08c50513          	addi	a0,a0,140 # 80012300 <cons>
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
    800002cc:	03850513          	addi	a0,a0,56 # 80012300 <cons>
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
    800002ea:	092020ef          	jal	8000237c <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	01250513          	addi	a0,a0,18 # 80012300 <cons>
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
    80000310:	ff470713          	addi	a4,a4,-12 # 80012300 <cons>
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
    80000336:	fce70713          	addi	a4,a4,-50 # 80012300 <cons>
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
    80000360:	03c72703          	lw	a4,60(a4) # 80012398 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	f8e70713          	addi	a4,a4,-114 # 80012300 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	f7e48493          	addi	s1,s1,-130 # 80012300 <cons>
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
    800003c8:	f3c70713          	addi	a4,a4,-196 # 80012300 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	fcf72323          	sw	a5,-58(a4) # 800123a0 <cons+0xa0>
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
    800003fc:	f0878793          	addi	a5,a5,-248 # 80012300 <cons>
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
    8000041e:	f8c7a123          	sw	a2,-126(a5) # 8001239c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	f7650513          	addi	a0,a0,-138 # 80012398 <cons+0x98>
    8000042a:	395010ef          	jal	80001fbe <wakeup>
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
    80000444:	ec050513          	addi	a0,a0,-320 # 80012300 <cons>
    80000448:	760000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	02078793          	addi	a5,a5,32 # 80022470 <devsw>
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
    80000492:	2a280813          	addi	a6,a6,674 # 80007730 <digits>
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
    8000052c:	dac7a783          	lw	a5,-596(a5) # 8000a2d4 <panicking>
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
    80000572:	e3a50513          	addi	a0,a0,-454 # 800123a8 <pr>
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
    800006e6:	04ec8c93          	addi	s9,s9,78 # 80007730 <digits>
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
    8000076e:	b6a7a783          	lw	a5,-1174(a5) # 8000a2d4 <panicking>
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
    80000798:	c1450513          	addi	a0,a0,-1004 # 800123a8 <pr>
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
    80000848:	a897a823          	sw	s1,-1392(a5) # 8000a2d4 <panicking>
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
    8000086a:	a697a523          	sw	s1,-1430(a5) # 8000a2d0 <panicked>
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
    80000884:	b2850513          	addi	a0,a0,-1240 # 800123a8 <pr>
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
    800008da:	aea50513          	addi	a0,a0,-1302 # 800123c0 <tx_lock>
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
    800008fe:	ac650513          	addi	a0,a0,-1338 # 800123c0 <tx_lock>
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
    8000091c:	9c490913          	addi	s2,s2,-1596 # 8000a2dc <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	9b898993          	addi	s3,s3,-1608 # 8000a2d8 <tx_chan>
      release(&tx_lock);
    80000928:	00012497          	auipc	s1,0x12
    8000092c:	a9848493          	addi	s1,s1,-1384 # 800123c0 <tx_lock>
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
    8000093a:	618010ef          	jal	80001f52 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	64a010ef          	jal	80001f8e <sleep>
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
    8000097c:	a4850513          	addi	a0,a0,-1464 # 800123c0 <tx_lock>
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
    800009a0:	9387a783          	lw	a5,-1736(a5) # 8000a2d4 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	92a7a783          	lw	a5,-1750(a5) # 8000a2d0 <panicked>
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
    800009d0:	9087a783          	lw	a5,-1784(a5) # 8000a2d4 <panicking>
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
    80000a06:	9be50513          	addi	a0,a0,-1602 # 800123c0 <tx_lock>
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
    80000a20:	9a450513          	addi	a0,a0,-1628 # 800123c0 <tx_lock>
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
    80000a48:	8807ac23          	sw	zero,-1896(a5) # 8000a2dc <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	88c50513          	addi	a0,a0,-1908 # 8000a2d8 <tx_chan>
    80000a54:	56a010ef          	jal	80001fbe <wakeup>
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
    80000a76:	b9678793          	addi	a5,a5,-1130 # 80023608 <end>
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
    80000aa0:	93c90913          	addi	s2,s2,-1732 # 800123d8 <kmem>
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
    80000b2e:	8ae50513          	addi	a0,a0,-1874 # 800123d8 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00023517          	auipc	a0,0x23
    80000b3e:	ace50513          	addi	a0,a0,-1330 # 80023608 <end>
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
    80000b5c:	88050513          	addi	a0,a0,-1920 # 800123d8 <kmem>
    80000b60:	0c8000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b64:	00012497          	auipc	s1,0x12
    80000b68:	88c4b483          	ld	s1,-1908(s1) # 800123f0 <kmem+0x18>
  if (r)
    80000b6c:	c49d                	beqz	s1,80000b9a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00012717          	auipc	a4,0x12
    80000b74:	88f73023          	sd	a5,-1920(a4) # 800123f0 <kmem+0x18>
  release(&kmem.lock);
    80000b78:	00012517          	auipc	a0,0x12
    80000b7c:	86050513          	addi	a0,a0,-1952 # 800123d8 <kmem>
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
    80000b9e:	83e50513          	addi	a0,a0,-1986 # 800123d8 <kmem>
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
    80000bd8:	551000ef          	jal	80001928 <mycpu>
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
    80000bfe:	52b000ef          	jal	80001928 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x2c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	523000ef          	jal	80001928 <mycpu>
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
    80000c1a:	50f000ef          	jal	80001928 <mycpu>
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
    80000c4c:	4dd000ef          	jal	80001928 <mycpu>
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
    80000c70:	4b9000ef          	jal	80001928 <mycpu>
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
    80000ea6:	26f000ef          	jal	80001914 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eaa:	00009717          	auipc	a4,0x9
    80000eae:	43670713          	addi	a4,a4,1078 # 8000a2e0 <started>
  if (cpuid() == 0) {
    80000eb2:	c51d                	beqz	a0,80000ee0 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eb4:	431c                	lw	a5,0(a4)
    80000eb6:	0230000f          	fence	r,rw
    80000eba:	2781                	sext.w	a5,a5
    80000ebc:	dfe5                	beqz	a5,80000eb4 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000ebe:	257000ef          	jal	80001914 <cpuid>
    80000ec2:	85aa                	mv	a1,a0
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1d450513          	addi	a0,a0,468 # 80007098 <etext+0x98>
    80000ecc:	e3eff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000ed0:	082000ef          	jal	80000f52 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000ed4:	5da010ef          	jal	800024ae <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	7c0040ef          	jal	80005698 <plicinithart>
  }

  scheduler();
    80000edc:	6db000ef          	jal	80001db6 <scheduler>
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
    80000f18:	147000ef          	jal	8000185e <procinit>
    trapinit();         // trap vectors
    80000f1c:	56e010ef          	jal	8000248a <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	58e010ef          	jal	800024ae <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	75a040ef          	jal	8000567e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	770040ef          	jal	80005698 <plicinithart>
    binit();            // buffer cache
    80000f2c:	421010ef          	jal	80002b4c <binit>
    iinit();            // inode table
    80000f30:	172020ef          	jal	800030a2 <iinit>
    fileinit();         // file table
    80000f34:	1a0030ef          	jal	800040d4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	057040ef          	jal	8000578e <virtio_disk_init>
    userinit();         // first user process
    80000f3c:	4cf000ef          	jal	80001c0a <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f40:	00009797          	auipc	a5,0x9
    80000f44:	3a078793          	addi	a5,a5,928 # 8000a2e0 <started>
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
    80000f62:	38a7b783          	ld	a5,906(a5) # 8000a2e8 <kernel_pagetable>
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
    800011ce:	5ec000ef          	jal	800017ba <proc_mapstacks>
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
    800011ee:	0ea7bf23          	sd	a0,254(a5) # 8000a2e8 <kernel_pagetable>
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
    80001724:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb9f8>
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

00000000800017ba <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017ba:	715d                	addi	sp,sp,-80
    800017bc:	e486                	sd	ra,72(sp)
    800017be:	e0a2                	sd	s0,64(sp)
    800017c0:	fc26                	sd	s1,56(sp)
    800017c2:	f84a                	sd	s2,48(sp)
    800017c4:	f44e                	sd	s3,40(sp)
    800017c6:	f052                	sd	s4,32(sp)
    800017c8:	ec56                	sd	s5,24(sp)
    800017ca:	e85a                	sd	s6,16(sp)
    800017cc:	e45e                	sd	s7,8(sp)
    800017ce:	e062                	sd	s8,0(sp)
    800017d0:	0880                	addi	s0,sp,80
    800017d2:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800017d4:	00011497          	auipc	s1,0x11
    800017d8:	05448493          	addi	s1,s1,84 # 80012828 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017dc:	8c26                	mv	s8,s1
    800017de:	000a57b7          	lui	a5,0xa5
    800017e2:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800017e6:	07b2                	slli	a5,a5,0xc
    800017e8:	fa578793          	addi	a5,a5,-91
    800017ec:	4fa50937          	lui	s2,0x4fa50
    800017f0:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800017f4:	1902                	slli	s2,s2,0x20
    800017f6:	993e                	add	s2,s2,a5
    800017f8:	040009b7          	lui	s3,0x4000
    800017fc:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017fe:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001800:	4b99                	li	s7,6
    80001802:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001804:	00017a97          	auipc	s5,0x17
    80001808:	a24a8a93          	addi	s5,s5,-1500 # 80018228 <tickslock>
    char *pa = kalloc();
    8000180c:	b42ff0ef          	jal	80000b4e <kalloc>
    80001810:	862a                	mv	a2,a0
    if (pa == 0)
    80001812:	c121                	beqz	a0,80001852 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    80001814:	418485b3          	sub	a1,s1,s8
    80001818:	858d                	srai	a1,a1,0x3
    8000181a:	032585b3          	mul	a1,a1,s2
    8000181e:	05b6                	slli	a1,a1,0xd
    80001820:	6789                	lui	a5,0x2
    80001822:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001824:	875e                	mv	a4,s7
    80001826:	86da                	mv	a3,s6
    80001828:	40b985b3          	sub	a1,s3,a1
    8000182c:	8552                	mv	a0,s4
    8000182e:	8dbff0ef          	jal	80001108 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001832:	16848493          	addi	s1,s1,360
    80001836:	fd549be3          	bne	s1,s5,8000180c <proc_mapstacks+0x52>
  }
}
    8000183a:	60a6                	ld	ra,72(sp)
    8000183c:	6406                	ld	s0,64(sp)
    8000183e:	74e2                	ld	s1,56(sp)
    80001840:	7942                	ld	s2,48(sp)
    80001842:	79a2                	ld	s3,40(sp)
    80001844:	7a02                	ld	s4,32(sp)
    80001846:	6ae2                	ld	s5,24(sp)
    80001848:	6b42                	ld	s6,16(sp)
    8000184a:	6ba2                	ld	s7,8(sp)
    8000184c:	6c02                	ld	s8,0(sp)
    8000184e:	6161                	addi	sp,sp,80
    80001850:	8082                	ret
      panic("kalloc");
    80001852:	00006517          	auipc	a0,0x6
    80001856:	90650513          	addi	a0,a0,-1786 # 80007158 <etext+0x158>
    8000185a:	fdbfe0ef          	jal	80000834 <panic>

000000008000185e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000185e:	7139                	addi	sp,sp,-64
    80001860:	fc06                	sd	ra,56(sp)
    80001862:	f822                	sd	s0,48(sp)
    80001864:	f426                	sd	s1,40(sp)
    80001866:	f04a                	sd	s2,32(sp)
    80001868:	ec4e                	sd	s3,24(sp)
    8000186a:	e852                	sd	s4,16(sp)
    8000186c:	e456                	sd	s5,8(sp)
    8000186e:	e05a                	sd	s6,0(sp)
    80001870:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001872:	00006597          	auipc	a1,0x6
    80001876:	8ee58593          	addi	a1,a1,-1810 # 80007160 <etext+0x160>
    8000187a:	00011517          	auipc	a0,0x11
    8000187e:	b7e50513          	addi	a0,a0,-1154 # 800123f8 <pid_lock>
    80001882:	b26ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001886:	00006597          	auipc	a1,0x6
    8000188a:	8e258593          	addi	a1,a1,-1822 # 80007168 <etext+0x168>
    8000188e:	00011517          	auipc	a0,0x11
    80001892:	b8250513          	addi	a0,a0,-1150 # 80012410 <wait_lock>
    80001896:	b12ff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000189a:	00011497          	auipc	s1,0x11
    8000189e:	f8e48493          	addi	s1,s1,-114 # 80012828 <proc>
    initlock(&p->lock, "proc");
    800018a2:	00006b17          	auipc	s6,0x6
    800018a6:	8d6b0b13          	addi	s6,s6,-1834 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018aa:	8aa6                	mv	s5,s1
    800018ac:	000a57b7          	lui	a5,0xa5
    800018b0:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800018b4:	07b2                	slli	a5,a5,0xc
    800018b6:	fa578793          	addi	a5,a5,-91
    800018ba:	4fa50937          	lui	s2,0x4fa50
    800018be:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800018c2:	1902                	slli	s2,s2,0x20
    800018c4:	993e                	add	s2,s2,a5
    800018c6:	040009b7          	lui	s3,0x4000
    800018ca:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018cc:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    800018ce:	00017a17          	auipc	s4,0x17
    800018d2:	95aa0a13          	addi	s4,s4,-1702 # 80018228 <tickslock>
    initlock(&p->lock, "proc");
    800018d6:	85da                	mv	a1,s6
    800018d8:	8526                	mv	a0,s1
    800018da:	aceff0ef          	jal	80000ba8 <initlock>
    p->state = UNUSED;
    800018de:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800018e2:	415487b3          	sub	a5,s1,s5
    800018e6:	878d                	srai	a5,a5,0x3
    800018e8:	032787b3          	mul	a5,a5,s2
    800018ec:	07b6                	slli	a5,a5,0xd
    800018ee:	6709                	lui	a4,0x2
    800018f0:	9fb9                	addw	a5,a5,a4
    800018f2:	40f987b3          	sub	a5,s3,a5
    800018f6:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    800018f8:	16848493          	addi	s1,s1,360
    800018fc:	fd449de3          	bne	s1,s4,800018d6 <procinit+0x78>
  }
}
    80001900:	70e2                	ld	ra,56(sp)
    80001902:	7442                	ld	s0,48(sp)
    80001904:	74a2                	ld	s1,40(sp)
    80001906:	7902                	ld	s2,32(sp)
    80001908:	69e2                	ld	s3,24(sp)
    8000190a:	6a42                	ld	s4,16(sp)
    8000190c:	6aa2                	ld	s5,8(sp)
    8000190e:	6b02                	ld	s6,0(sp)
    80001910:	6121                	addi	sp,sp,64
    80001912:	8082                	ret

0000000080001914 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001914:	1141                	addi	sp,sp,-16
    80001916:	e406                	sd	ra,8(sp)
    80001918:	e022                	sd	s0,0(sp)
    8000191a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    8000191c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000191e:	2501                	sext.w	a0,a0
    80001920:	60a2                	ld	ra,8(sp)
    80001922:	6402                	ld	s0,0(sp)
    80001924:	0141                	addi	sp,sp,16
    80001926:	8082                	ret

0000000080001928 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001928:	1141                	addi	sp,sp,-16
    8000192a:	e406                	sd	ra,8(sp)
    8000192c:	e022                	sd	s0,0(sp)
    8000192e:	0800                	addi	s0,sp,16
    80001930:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001932:	2781                	sext.w	a5,a5
    80001934:	079e                	slli	a5,a5,0x7
  return c;
}
    80001936:	00011517          	auipc	a0,0x11
    8000193a:	af250513          	addi	a0,a0,-1294 # 80012428 <cpus>
    8000193e:	953e                	add	a0,a0,a5
    80001940:	60a2                	ld	ra,8(sp)
    80001942:	6402                	ld	s0,0(sp)
    80001944:	0141                	addi	sp,sp,16
    80001946:	8082                	ret

0000000080001948 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001948:	1101                	addi	sp,sp,-32
    8000194a:	ec06                	sd	ra,24(sp)
    8000194c:	e822                	sd	s0,16(sp)
    8000194e:	e426                	sd	s1,8(sp)
    80001950:	1000                	addi	s0,sp,32
  push_off();
    80001952:	a9cff0ef          	jal	80000bee <push_off>
    80001956:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001958:	2781                	sext.w	a5,a5
    8000195a:	079e                	slli	a5,a5,0x7
    8000195c:	00011717          	auipc	a4,0x11
    80001960:	a9c70713          	addi	a4,a4,-1380 # 800123f8 <pid_lock>
    80001964:	97ba                	add	a5,a5,a4
    80001966:	7b9c                	ld	a5,48(a5)
    80001968:	84be                	mv	s1,a5
  pop_off();
    8000196a:	afeff0ef          	jal	80000c68 <pop_off>
  return p;
}
    8000196e:	8526                	mv	a0,s1
    80001970:	60e2                	ld	ra,24(sp)
    80001972:	6442                	ld	s0,16(sp)
    80001974:	64a2                	ld	s1,8(sp)
    80001976:	6105                	addi	sp,sp,32
    80001978:	8082                	ret

000000008000197a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000197a:	7179                	addi	sp,sp,-48
    8000197c:	f406                	sd	ra,40(sp)
    8000197e:	f022                	sd	s0,32(sp)
    80001980:	ec26                	sd	s1,24(sp)
    80001982:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001984:	fc5ff0ef          	jal	80001948 <myproc>
    80001988:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    8000198a:	b26ff0ef          	jal	80000cb0 <release>

  if (first) {
    8000198e:	00009797          	auipc	a5,0x9
    80001992:	9127a783          	lw	a5,-1774(a5) # 8000a2a0 <first.1>
    80001996:	cf85                	beqz	a5,800019ce <forkret+0x54>
    first = 0;
    80001998:	00009797          	auipc	a5,0x9
    8000199c:	9007a423          	sw	zero,-1784(a5) # 8000a2a0 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019a0:	4505                	li	a0,1
    800019a2:	405010ef          	jal	800035a6 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019a6:	00005797          	auipc	a5,0x5
    800019aa:	7da78793          	addi	a5,a5,2010 # 80007180 <etext+0x180>
    800019ae:	fcf43823          	sd	a5,-48(s0)
    800019b2:	fc043c23          	sd	zero,-40(s0)
    800019b6:	fd040593          	addi	a1,s0,-48
    800019ba:	853e                	mv	a0,a5
    800019bc:	69f020ef          	jal	8000485a <kexec>
    800019c0:	6cbc                	ld	a5,88(s1)
    800019c2:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019c4:	6cbc                	ld	a5,88(s1)
    800019c6:	7bb8                	ld	a4,112(a5)
    800019c8:	57fd                	li	a5,-1
    800019ca:	02f70d63          	beq	a4,a5,80001a04 <forkret+0x8a>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019ce:	2fd000ef          	jal	800024ca <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019d2:	68a8                	ld	a0,80(s1)
    800019d4:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019d6:	04000737          	lui	a4,0x4000
    800019da:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019dc:	0732                	slli	a4,a4,0xc
    800019de:	00004797          	auipc	a5,0x4
    800019e2:	6be78793          	addi	a5,a5,1726 # 8000609c <userret>
    800019e6:	00004697          	auipc	a3,0x4
    800019ea:	61a68693          	addi	a3,a3,1562 # 80006000 <_trampoline>
    800019ee:	8f95                	sub	a5,a5,a3
    800019f0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019f2:	577d                	li	a4,-1
    800019f4:	177e                	slli	a4,a4,0x3f
    800019f6:	8d59                	or	a0,a0,a4
    800019f8:	9782                	jalr	a5
}
    800019fa:	70a2                	ld	ra,40(sp)
    800019fc:	7402                	ld	s0,32(sp)
    800019fe:	64e2                	ld	s1,24(sp)
    80001a00:	6145                	addi	sp,sp,48
    80001a02:	8082                	ret
      panic("exec");
    80001a04:	00005517          	auipc	a0,0x5
    80001a08:	78450513          	addi	a0,a0,1924 # 80007188 <etext+0x188>
    80001a0c:	e29fe0ef          	jal	80000834 <panic>

0000000080001a10 <allocpid>:
{
    80001a10:	1101                	addi	sp,sp,-32
    80001a12:	ec06                	sd	ra,24(sp)
    80001a14:	e822                	sd	s0,16(sp)
    80001a16:	e426                	sd	s1,8(sp)
    80001a18:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a1a:	00011517          	auipc	a0,0x11
    80001a1e:	9de50513          	addi	a0,a0,-1570 # 800123f8 <pid_lock>
    80001a22:	a06ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a26:	00009797          	auipc	a5,0x9
    80001a2a:	87e78793          	addi	a5,a5,-1922 # 8000a2a4 <nextpid>
    80001a2e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a30:	0014871b          	addiw	a4,s1,1
    80001a34:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a36:	00011517          	auipc	a0,0x11
    80001a3a:	9c250513          	addi	a0,a0,-1598 # 800123f8 <pid_lock>
    80001a3e:	a72ff0ef          	jal	80000cb0 <release>
}
    80001a42:	8526                	mv	a0,s1
    80001a44:	60e2                	ld	ra,24(sp)
    80001a46:	6442                	ld	s0,16(sp)
    80001a48:	64a2                	ld	s1,8(sp)
    80001a4a:	6105                	addi	sp,sp,32
    80001a4c:	8082                	ret

0000000080001a4e <proc_pagetable>:
{
    80001a4e:	1101                	addi	sp,sp,-32
    80001a50:	ec06                	sd	ra,24(sp)
    80001a52:	e822                	sd	s0,16(sp)
    80001a54:	e426                	sd	s1,8(sp)
    80001a56:	e04a                	sd	s2,0(sp)
    80001a58:	1000                	addi	s0,sp,32
    80001a5a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a5c:	f9eff0ef          	jal	800011fa <uvmcreate>
    80001a60:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a62:	cd05                	beqz	a0,80001a9a <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a64:	4729                	li	a4,10
    80001a66:	00004697          	auipc	a3,0x4
    80001a6a:	59a68693          	addi	a3,a3,1434 # 80006000 <_trampoline>
    80001a6e:	6605                	lui	a2,0x1
    80001a70:	040005b7          	lui	a1,0x4000
    80001a74:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a76:	05b2                	slli	a1,a1,0xc
    80001a78:	ddaff0ef          	jal	80001052 <mappages>
    80001a7c:	02054663          	bltz	a0,80001aa8 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001a80:	4719                	li	a4,6
    80001a82:	05893683          	ld	a3,88(s2)
    80001a86:	6605                	lui	a2,0x1
    80001a88:	020005b7          	lui	a1,0x2000
    80001a8c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a8e:	05b6                	slli	a1,a1,0xd
    80001a90:	8526                	mv	a0,s1
    80001a92:	dc0ff0ef          	jal	80001052 <mappages>
    80001a96:	00054f63          	bltz	a0,80001ab4 <proc_pagetable+0x66>
}
    80001a9a:	8526                	mv	a0,s1
    80001a9c:	60e2                	ld	ra,24(sp)
    80001a9e:	6442                	ld	s0,16(sp)
    80001aa0:	64a2                	ld	s1,8(sp)
    80001aa2:	6902                	ld	s2,0(sp)
    80001aa4:	6105                	addi	sp,sp,32
    80001aa6:	8082                	ret
    uvmfree(pagetable, 0);
    80001aa8:	4581                	li	a1,0
    80001aaa:	8526                	mv	a0,s1
    80001aac:	949ff0ef          	jal	800013f4 <uvmfree>
    return 0;
    80001ab0:	4481                	li	s1,0
    80001ab2:	b7e5                	j	80001a9a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ab4:	4681                	li	a3,0
    80001ab6:	4605                	li	a2,1
    80001ab8:	040005b7          	lui	a1,0x4000
    80001abc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001abe:	05b2                	slli	a1,a1,0xc
    80001ac0:	8526                	mv	a0,s1
    80001ac2:	f5eff0ef          	jal	80001220 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ac6:	4581                	li	a1,0
    80001ac8:	8526                	mv	a0,s1
    80001aca:	92bff0ef          	jal	800013f4 <uvmfree>
    return 0;
    80001ace:	4481                	li	s1,0
    80001ad0:	b7e9                	j	80001a9a <proc_pagetable+0x4c>

0000000080001ad2 <proc_freepagetable>:
{
    80001ad2:	1101                	addi	sp,sp,-32
    80001ad4:	ec06                	sd	ra,24(sp)
    80001ad6:	e822                	sd	s0,16(sp)
    80001ad8:	e426                	sd	s1,8(sp)
    80001ada:	e04a                	sd	s2,0(sp)
    80001adc:	1000                	addi	s0,sp,32
    80001ade:	84aa                	mv	s1,a0
    80001ae0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae2:	4681                	li	a3,0
    80001ae4:	4605                	li	a2,1
    80001ae6:	040005b7          	lui	a1,0x4000
    80001aea:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aec:	05b2                	slli	a1,a1,0xc
    80001aee:	f32ff0ef          	jal	80001220 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001af2:	4681                	li	a3,0
    80001af4:	4605                	li	a2,1
    80001af6:	020005b7          	lui	a1,0x2000
    80001afa:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001afc:	05b6                	slli	a1,a1,0xd
    80001afe:	8526                	mv	a0,s1
    80001b00:	f20ff0ef          	jal	80001220 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b04:	85ca                	mv	a1,s2
    80001b06:	8526                	mv	a0,s1
    80001b08:	8edff0ef          	jal	800013f4 <uvmfree>
}
    80001b0c:	60e2                	ld	ra,24(sp)
    80001b0e:	6442                	ld	s0,16(sp)
    80001b10:	64a2                	ld	s1,8(sp)
    80001b12:	6902                	ld	s2,0(sp)
    80001b14:	6105                	addi	sp,sp,32
    80001b16:	8082                	ret

0000000080001b18 <freeproc>:
{
    80001b18:	1101                	addi	sp,sp,-32
    80001b1a:	ec06                	sd	ra,24(sp)
    80001b1c:	e822                	sd	s0,16(sp)
    80001b1e:	e426                	sd	s1,8(sp)
    80001b20:	1000                	addi	s0,sp,32
    80001b22:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b24:	6d28                	ld	a0,88(a0)
    80001b26:	c119                	beqz	a0,80001b2c <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001b28:	f3ffe0ef          	jal	80000a66 <kfree>
  p->trapframe = 0;
    80001b2c:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b30:	68a8                	ld	a0,80(s1)
    80001b32:	c501                	beqz	a0,80001b3a <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b34:	64ac                	ld	a1,72(s1)
    80001b36:	f9dff0ef          	jal	80001ad2 <proc_freepagetable>
  p->pagetable = 0;
    80001b3a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b3e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b42:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001b46:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b4a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b4e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b52:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b56:	0004ac23          	sw	zero,24(s1)
}
    80001b5a:	60e2                	ld	ra,24(sp)
    80001b5c:	6442                	ld	s0,16(sp)
    80001b5e:	64a2                	ld	s1,8(sp)
    80001b60:	6105                	addi	sp,sp,32
    80001b62:	8082                	ret

0000000080001b64 <allocproc>:
{
    80001b64:	1101                	addi	sp,sp,-32
    80001b66:	ec06                	sd	ra,24(sp)
    80001b68:	e822                	sd	s0,16(sp)
    80001b6a:	e426                	sd	s1,8(sp)
    80001b6c:	e04a                	sd	s2,0(sp)
    80001b6e:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b70:	00011497          	auipc	s1,0x11
    80001b74:	cb848493          	addi	s1,s1,-840 # 80012828 <proc>
    80001b78:	00016917          	auipc	s2,0x16
    80001b7c:	6b090913          	addi	s2,s2,1712 # 80018228 <tickslock>
    acquire(&p->lock);
    80001b80:	8526                	mv	a0,s1
    80001b82:	8a6ff0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001b86:	4c9c                	lw	a5,24(s1)
    80001b88:	cb91                	beqz	a5,80001b9c <allocproc+0x38>
      release(&p->lock);
    80001b8a:	8526                	mv	a0,s1
    80001b8c:	924ff0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b90:	16848493          	addi	s1,s1,360
    80001b94:	ff2496e3          	bne	s1,s2,80001b80 <allocproc+0x1c>
  return 0;
    80001b98:	4481                	li	s1,0
    80001b9a:	a089                	j	80001bdc <allocproc+0x78>
  p->pid = allocpid();
    80001b9c:	e75ff0ef          	jal	80001a10 <allocpid>
    80001ba0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ba2:	4785                	li	a5,1
    80001ba4:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001ba6:	fa9fe0ef          	jal	80000b4e <kalloc>
    80001baa:	892a                	mv	s2,a0
    80001bac:	eca8                	sd	a0,88(s1)
    80001bae:	cd15                	beqz	a0,80001bea <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	e9dff0ef          	jal	80001a4e <proc_pagetable>
    80001bb6:	892a                	mv	s2,a0
    80001bb8:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001bba:	c121                	beqz	a0,80001bfa <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001bbc:	07000613          	li	a2,112
    80001bc0:	4581                	li	a1,0
    80001bc2:	06048513          	addi	a0,s1,96
    80001bc6:	922ff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001bca:	00000797          	auipc	a5,0x0
    80001bce:	db078793          	addi	a5,a5,-592 # 8000197a <forkret>
    80001bd2:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bd4:	60bc                	ld	a5,64(s1)
    80001bd6:	6705                	lui	a4,0x1
    80001bd8:	97ba                	add	a5,a5,a4
    80001bda:	f4bc                	sd	a5,104(s1)
}
    80001bdc:	8526                	mv	a0,s1
    80001bde:	60e2                	ld	ra,24(sp)
    80001be0:	6442                	ld	s0,16(sp)
    80001be2:	64a2                	ld	s1,8(sp)
    80001be4:	6902                	ld	s2,0(sp)
    80001be6:	6105                	addi	sp,sp,32
    80001be8:	8082                	ret
    freeproc(p);
    80001bea:	8526                	mv	a0,s1
    80001bec:	f2dff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001bf0:	8526                	mv	a0,s1
    80001bf2:	8beff0ef          	jal	80000cb0 <release>
    return 0;
    80001bf6:	84ca                	mv	s1,s2
    80001bf8:	b7d5                	j	80001bdc <allocproc+0x78>
    freeproc(p);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	f1dff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001c00:	8526                	mv	a0,s1
    80001c02:	8aeff0ef          	jal	80000cb0 <release>
    return 0;
    80001c06:	84ca                	mv	s1,s2
    80001c08:	bfd1                	j	80001bdc <allocproc+0x78>

0000000080001c0a <userinit>:
{
    80001c0a:	1101                	addi	sp,sp,-32
    80001c0c:	ec06                	sd	ra,24(sp)
    80001c0e:	e822                	sd	s0,16(sp)
    80001c10:	e426                	sd	s1,8(sp)
    80001c12:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c14:	f51ff0ef          	jal	80001b64 <allocproc>
    80001c18:	84aa                	mv	s1,a0
  initproc = p;
    80001c1a:	00008797          	auipc	a5,0x8
    80001c1e:	6ca7bb23          	sd	a0,1750(a5) # 8000a2f0 <initproc>
  p->cwd = namei("/");
    80001c22:	00005517          	auipc	a0,0x5
    80001c26:	56e50513          	addi	a0,a0,1390 # 80007190 <etext+0x190>
    80001c2a:	6db010ef          	jal	80003b04 <namei>
    80001c2e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c32:	478d                	li	a5,3
    80001c34:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c36:	8526                	mv	a0,s1
    80001c38:	878ff0ef          	jal	80000cb0 <release>
}
    80001c3c:	60e2                	ld	ra,24(sp)
    80001c3e:	6442                	ld	s0,16(sp)
    80001c40:	64a2                	ld	s1,8(sp)
    80001c42:	6105                	addi	sp,sp,32
    80001c44:	8082                	ret

0000000080001c46 <growproc>:
{
    80001c46:	1101                	addi	sp,sp,-32
    80001c48:	ec06                	sd	ra,24(sp)
    80001c4a:	e822                	sd	s0,16(sp)
    80001c4c:	e426                	sd	s1,8(sp)
    80001c4e:	e04a                	sd	s2,0(sp)
    80001c50:	1000                	addi	s0,sp,32
    80001c52:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c54:	cf5ff0ef          	jal	80001948 <myproc>
    80001c58:	892a                	mv	s2,a0
  sz = p->sz;
    80001c5a:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c5c:	02905963          	blez	s1,80001c8e <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c60:	00b48633          	add	a2,s1,a1
    80001c64:	020007b7          	lui	a5,0x2000
    80001c68:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c6a:	07b6                	slli	a5,a5,0xd
    80001c6c:	02c7ea63          	bltu	a5,a2,80001ca0 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c70:	4691                	li	a3,4
    80001c72:	6928                	ld	a0,80(a0)
    80001c74:	e7aff0ef          	jal	800012ee <uvmalloc>
    80001c78:	85aa                	mv	a1,a0
    80001c7a:	c50d                	beqz	a0,80001ca4 <growproc+0x5e>
  p->sz = sz;
    80001c7c:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c80:	4501                	li	a0,0
}
    80001c82:	60e2                	ld	ra,24(sp)
    80001c84:	6442                	ld	s0,16(sp)
    80001c86:	64a2                	ld	s1,8(sp)
    80001c88:	6902                	ld	s2,0(sp)
    80001c8a:	6105                	addi	sp,sp,32
    80001c8c:	8082                	ret
  } else if (n < 0) {
    80001c8e:	fe04d7e3          	bgez	s1,80001c7c <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c92:	00b48633          	add	a2,s1,a1
    80001c96:	6928                	ld	a0,80(a0)
    80001c98:	e12ff0ef          	jal	800012aa <uvmdealloc>
    80001c9c:	85aa                	mv	a1,a0
    80001c9e:	bff9                	j	80001c7c <growproc+0x36>
      return -1;
    80001ca0:	557d                	li	a0,-1
    80001ca2:	b7c5                	j	80001c82 <growproc+0x3c>
      return -1;
    80001ca4:	557d                	li	a0,-1
    80001ca6:	bff1                	j	80001c82 <growproc+0x3c>

0000000080001ca8 <kfork>:
{
    80001ca8:	7139                	addi	sp,sp,-64
    80001caa:	fc06                	sd	ra,56(sp)
    80001cac:	f822                	sd	s0,48(sp)
    80001cae:	f426                	sd	s1,40(sp)
    80001cb0:	e456                	sd	s5,8(sp)
    80001cb2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cb4:	c95ff0ef          	jal	80001948 <myproc>
    80001cb8:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001cba:	eabff0ef          	jal	80001b64 <allocproc>
    80001cbe:	0e050a63          	beqz	a0,80001db2 <kfork+0x10a>
    80001cc2:	e852                	sd	s4,16(sp)
    80001cc4:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001cc6:	048ab603          	ld	a2,72(s5)
    80001cca:	692c                	ld	a1,80(a0)
    80001ccc:	050ab503          	ld	a0,80(s5)
    80001cd0:	f56ff0ef          	jal	80001426 <uvmcopy>
    80001cd4:	04054863          	bltz	a0,80001d24 <kfork+0x7c>
    80001cd8:	f04a                	sd	s2,32(sp)
    80001cda:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001cdc:	048ab783          	ld	a5,72(s5)
    80001ce0:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ce4:	058ab683          	ld	a3,88(s5)
    80001ce8:	87b6                	mv	a5,a3
    80001cea:	058a3703          	ld	a4,88(s4)
    80001cee:	12068693          	addi	a3,a3,288
    80001cf2:	6388                	ld	a0,0(a5)
    80001cf4:	678c                	ld	a1,8(a5)
    80001cf6:	6b90                	ld	a2,16(a5)
    80001cf8:	e308                	sd	a0,0(a4)
    80001cfa:	e70c                	sd	a1,8(a4)
    80001cfc:	eb10                	sd	a2,16(a4)
    80001cfe:	6f90                	ld	a2,24(a5)
    80001d00:	ef10                	sd	a2,24(a4)
    80001d02:	02078793          	addi	a5,a5,32
    80001d06:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d0a:	fed794e3          	bne	a5,a3,80001cf2 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d0e:	058a3783          	ld	a5,88(s4)
    80001d12:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d16:	0d0a8493          	addi	s1,s5,208
    80001d1a:	0d0a0913          	addi	s2,s4,208
    80001d1e:	150a8993          	addi	s3,s5,336
    80001d22:	a831                	j	80001d3e <kfork+0x96>
    freeproc(np);
    80001d24:	8552                	mv	a0,s4
    80001d26:	df3ff0ef          	jal	80001b18 <freeproc>
    release(&np->lock);
    80001d2a:	8552                	mv	a0,s4
    80001d2c:	f85fe0ef          	jal	80000cb0 <release>
    return -1;
    80001d30:	54fd                	li	s1,-1
    80001d32:	6a42                	ld	s4,16(sp)
    80001d34:	a885                	j	80001da4 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d36:	04a1                	addi	s1,s1,8
    80001d38:	0921                	addi	s2,s2,8
    80001d3a:	01348963          	beq	s1,s3,80001d4c <kfork+0xa4>
    if (p->ofile[i])
    80001d3e:	6088                	ld	a0,0(s1)
    80001d40:	d97d                	beqz	a0,80001d36 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d42:	414020ef          	jal	80004156 <filedup>
    80001d46:	00a93023          	sd	a0,0(s2)
    80001d4a:	b7f5                	j	80001d36 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d4c:	150ab503          	ld	a0,336(s5)
    80001d50:	4e4010ef          	jal	80003234 <idup>
    80001d54:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d58:	4641                	li	a2,16
    80001d5a:	158a8593          	addi	a1,s5,344
    80001d5e:	158a0513          	addi	a0,s4,344
    80001d62:	8daff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001d66:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d6a:	8552                	mv	a0,s4
    80001d6c:	f45fe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001d70:	00010517          	auipc	a0,0x10
    80001d74:	6a050513          	addi	a0,a0,1696 # 80012410 <wait_lock>
    80001d78:	eb1fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001d7c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d80:	00010517          	auipc	a0,0x10
    80001d84:	69050513          	addi	a0,a0,1680 # 80012410 <wait_lock>
    80001d88:	f29fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001d8c:	8552                	mv	a0,s4
    80001d8e:	e9bfe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001d92:	478d                	li	a5,3
    80001d94:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d98:	8552                	mv	a0,s4
    80001d9a:	f17fe0ef          	jal	80000cb0 <release>
  return pid;
    80001d9e:	7902                	ld	s2,32(sp)
    80001da0:	69e2                	ld	s3,24(sp)
    80001da2:	6a42                	ld	s4,16(sp)
}
    80001da4:	8526                	mv	a0,s1
    80001da6:	70e2                	ld	ra,56(sp)
    80001da8:	7442                	ld	s0,48(sp)
    80001daa:	74a2                	ld	s1,40(sp)
    80001dac:	6aa2                	ld	s5,8(sp)
    80001dae:	6121                	addi	sp,sp,64
    80001db0:	8082                	ret
    return -1;
    80001db2:	54fd                	li	s1,-1
    80001db4:	bfc5                	j	80001da4 <kfork+0xfc>

0000000080001db6 <scheduler>:
{
    80001db6:	711d                	addi	sp,sp,-96
    80001db8:	ec86                	sd	ra,88(sp)
    80001dba:	e8a2                	sd	s0,80(sp)
    80001dbc:	e4a6                	sd	s1,72(sp)
    80001dbe:	e0ca                	sd	s2,64(sp)
    80001dc0:	fc4e                	sd	s3,56(sp)
    80001dc2:	f852                	sd	s4,48(sp)
    80001dc4:	f456                	sd	s5,40(sp)
    80001dc6:	f05a                	sd	s6,32(sp)
    80001dc8:	ec5e                	sd	s7,24(sp)
    80001dca:	e862                	sd	s8,16(sp)
    80001dcc:	e466                	sd	s9,8(sp)
    80001dce:	1080                	addi	s0,sp,96
    80001dd0:	8792                	mv	a5,tp
  int id = r_tp();
    80001dd2:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001dd4:	00779a93          	slli	s5,a5,0x7
    80001dd8:	00010717          	auipc	a4,0x10
    80001ddc:	62070713          	addi	a4,a4,1568 # 800123f8 <pid_lock>
    80001de0:	9756                	add	a4,a4,s5
    80001de2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001de6:	00010717          	auipc	a4,0x10
    80001dea:	64a70713          	addi	a4,a4,1610 # 80012430 <cpus+0x8>
    80001dee:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001df0:	4c11                	li	s8,4
        c->proc = p;
    80001df2:	00010b17          	auipc	s6,0x10
    80001df6:	606b0b13          	addi	s6,s6,1542 # 800123f8 <pid_lock>
    80001dfa:	079e                	slli	a5,a5,0x7
    80001dfc:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001e00:	4b85                	li	s7,1
    80001e02:	a0a9                	j	80001e4c <scheduler+0x96>
      release(&p->lock);
    80001e04:	8526                	mv	a0,s1
    80001e06:	eabfe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e0a:	16848493          	addi	s1,s1,360
    80001e0e:	03248b63          	beq	s1,s2,80001e44 <scheduler+0x8e>
      acquire(&p->lock);
    80001e12:	8526                	mv	a0,s1
    80001e14:	e15fe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001e18:	4c9c                	lw	a5,24(s1)
    80001e1a:	ff3795e3          	bne	a5,s3,80001e04 <scheduler+0x4e>
        p->state = RUNNING;
    80001e1e:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e22:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001e26:	06048593          	addi	a1,s1,96
    80001e2a:	8556                	mv	a0,s5
    80001e2c:	5f4000ef          	jal	80002420 <swtch>
    80001e30:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001e32:	2781                	sext.w	a5,a5
    80001e34:	079e                	slli	a5,a5,0x7
    80001e36:	97da                	add	a5,a5,s6
    80001e38:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001e3c:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001e40:	8cde                	mv	s9,s7
    80001e42:	b7c9                	j	80001e04 <scheduler+0x4e>
    if (found == 0) {
    80001e44:	000c9463          	bnez	s9,80001e4c <scheduler+0x96>
      asm volatile("wfi");
    80001e48:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001e4c:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001e50:	10017073          	csrci	sstatus,2
    int found = 0;
    80001e54:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e56:	00011497          	auipc	s1,0x11
    80001e5a:	9d248493          	addi	s1,s1,-1582 # 80012828 <proc>
      if (p->state == RUNNABLE) {
    80001e5e:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e60:	00016917          	auipc	s2,0x16
    80001e64:	3c890913          	addi	s2,s2,968 # 80018228 <tickslock>
    80001e68:	b76d                	j	80001e12 <scheduler+0x5c>

0000000080001e6a <sched>:
{
    80001e6a:	7179                	addi	sp,sp,-48
    80001e6c:	f406                	sd	ra,40(sp)
    80001e6e:	f022                	sd	s0,32(sp)
    80001e70:	ec26                	sd	s1,24(sp)
    80001e72:	e84a                	sd	s2,16(sp)
    80001e74:	e44e                	sd	s3,8(sp)
    80001e76:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e78:	ad1ff0ef          	jal	80001948 <myproc>
    80001e7c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001e7e:	d45fe0ef          	jal	80000bc2 <holding>
    80001e82:	c935                	beqz	a0,80001ef6 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e84:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001e86:	2781                	sext.w	a5,a5
    80001e88:	079e                	slli	a5,a5,0x7
    80001e8a:	00010717          	auipc	a4,0x10
    80001e8e:	56e70713          	addi	a4,a4,1390 # 800123f8 <pid_lock>
    80001e92:	97ba                	add	a5,a5,a4
    80001e94:	0a87a703          	lw	a4,168(a5)
    80001e98:	4785                	li	a5,1
    80001e9a:	06f71463          	bne	a4,a5,80001f02 <sched+0x98>
  if (p->state == RUNNING)
    80001e9e:	4c98                	lw	a4,24(s1)
    80001ea0:	4791                	li	a5,4
    80001ea2:	06f70663          	beq	a4,a5,80001f0e <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001ea6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001eaa:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001eac:	e7bd                	bnez	a5,80001f1a <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001eae:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001eb0:	00010917          	auipc	s2,0x10
    80001eb4:	54890913          	addi	s2,s2,1352 # 800123f8 <pid_lock>
    80001eb8:	2781                	sext.w	a5,a5
    80001eba:	079e                	slli	a5,a5,0x7
    80001ebc:	97ca                	add	a5,a5,s2
    80001ebe:	0ac7a983          	lw	s3,172(a5)
    80001ec2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001ec4:	2781                	sext.w	a5,a5
    80001ec6:	079e                	slli	a5,a5,0x7
    80001ec8:	07a1                	addi	a5,a5,8
    80001eca:	00010597          	auipc	a1,0x10
    80001ece:	55e58593          	addi	a1,a1,1374 # 80012428 <cpus>
    80001ed2:	95be                	add	a1,a1,a5
    80001ed4:	06048513          	addi	a0,s1,96
    80001ed8:	548000ef          	jal	80002420 <swtch>
    80001edc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001ede:	2781                	sext.w	a5,a5
    80001ee0:	079e                	slli	a5,a5,0x7
    80001ee2:	993e                	add	s2,s2,a5
    80001ee4:	0b392623          	sw	s3,172(s2)
}
    80001ee8:	70a2                	ld	ra,40(sp)
    80001eea:	7402                	ld	s0,32(sp)
    80001eec:	64e2                	ld	s1,24(sp)
    80001eee:	6942                	ld	s2,16(sp)
    80001ef0:	69a2                	ld	s3,8(sp)
    80001ef2:	6145                	addi	sp,sp,48
    80001ef4:	8082                	ret
    panic("sched p->lock");
    80001ef6:	00005517          	auipc	a0,0x5
    80001efa:	2a250513          	addi	a0,a0,674 # 80007198 <etext+0x198>
    80001efe:	937fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80001f02:	00005517          	auipc	a0,0x5
    80001f06:	2a650513          	addi	a0,a0,678 # 800071a8 <etext+0x1a8>
    80001f0a:	92bfe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80001f0e:	00005517          	auipc	a0,0x5
    80001f12:	2aa50513          	addi	a0,a0,682 # 800071b8 <etext+0x1b8>
    80001f16:	91ffe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80001f1a:	00005517          	auipc	a0,0x5
    80001f1e:	2ae50513          	addi	a0,a0,686 # 800071c8 <etext+0x1c8>
    80001f22:	913fe0ef          	jal	80000834 <panic>

0000000080001f26 <yield>:
{
    80001f26:	1101                	addi	sp,sp,-32
    80001f28:	ec06                	sd	ra,24(sp)
    80001f2a:	e822                	sd	s0,16(sp)
    80001f2c:	e426                	sd	s1,8(sp)
    80001f2e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f30:	a19ff0ef          	jal	80001948 <myproc>
    80001f34:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f36:	cf3fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001f3a:	478d                	li	a5,3
    80001f3c:	cc9c                	sw	a5,24(s1)
  sched();
    80001f3e:	f2dff0ef          	jal	80001e6a <sched>
  release(&p->lock);
    80001f42:	8526                	mv	a0,s1
    80001f44:	d6dfe0ef          	jal	80000cb0 <release>
}
    80001f48:	60e2                	ld	ra,24(sp)
    80001f4a:	6442                	ld	s0,16(sp)
    80001f4c:	64a2                	ld	s1,8(sp)
    80001f4e:	6105                	addi	sp,sp,32
    80001f50:	8082                	ret

0000000080001f52 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001f52:	1101                	addi	sp,sp,-32
    80001f54:	ec06                	sd	ra,24(sp)
    80001f56:	e822                	sd	s0,16(sp)
    80001f58:	e426                	sd	s1,8(sp)
    80001f5a:	e04a                	sd	s2,0(sp)
    80001f5c:	1000                	addi	s0,sp,32
    80001f5e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f60:	9e9ff0ef          	jal	80001948 <myproc>
    80001f64:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001f66:	cc3fe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    80001f6a:	cc81                	beqz	s1,80001f82 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001f6c:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001f70:	854a                	mv	a0,s2
    80001f72:	d3ffe0ef          	jal	80000cb0 <release>
}
    80001f76:	60e2                	ld	ra,24(sp)
    80001f78:	6442                	ld	s0,16(sp)
    80001f7a:	64a2                	ld	s1,8(sp)
    80001f7c:	6902                	ld	s2,0(sp)
    80001f7e:	6105                	addi	sp,sp,32
    80001f80:	8082                	ret
    panic("sleep_prepare: zero chan");
    80001f82:	00005517          	auipc	a0,0x5
    80001f86:	25e50513          	addi	a0,a0,606 # 800071e0 <etext+0x1e0>
    80001f8a:	8abfe0ef          	jal	80000834 <panic>

0000000080001f8e <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80001f8e:	1101                	addi	sp,sp,-32
    80001f90:	ec06                	sd	ra,24(sp)
    80001f92:	e822                	sd	s0,16(sp)
    80001f94:	e426                	sd	s1,8(sp)
    80001f96:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f98:	9b1ff0ef          	jal	80001948 <myproc>
    80001f9c:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80001f9e:	c8bfe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    80001fa2:	709c                	ld	a5,32(s1)
    80001fa4:	c789                	beqz	a5,80001fae <sleep+0x20>
    p->state = SLEEPING;
    80001fa6:	4789                	li	a5,2
    80001fa8:	cc9c                	sw	a5,24(s1)
    sched();
    80001faa:	ec1ff0ef          	jal	80001e6a <sched>
  }
  release(&p->lock);
    80001fae:	8526                	mv	a0,s1
    80001fb0:	d01fe0ef          	jal	80000cb0 <release>
}
    80001fb4:	60e2                	ld	ra,24(sp)
    80001fb6:	6442                	ld	s0,16(sp)
    80001fb8:	64a2                	ld	s1,8(sp)
    80001fba:	6105                	addi	sp,sp,32
    80001fbc:	8082                	ret

0000000080001fbe <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80001fbe:	7139                	addi	sp,sp,-64
    80001fc0:	fc06                	sd	ra,56(sp)
    80001fc2:	f822                	sd	s0,48(sp)
    80001fc4:	f426                	sd	s1,40(sp)
    80001fc6:	f04a                	sd	s2,32(sp)
    80001fc8:	ec4e                	sd	s3,24(sp)
    80001fca:	e852                	sd	s4,16(sp)
    80001fcc:	e456                	sd	s5,8(sp)
    80001fce:	0080                	addi	s0,sp,64
    80001fd0:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001fd2:	00011497          	auipc	s1,0x11
    80001fd6:	85648493          	addi	s1,s1,-1962 # 80012828 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80001fda:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80001fdc:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001fde:	00016997          	auipc	s3,0x16
    80001fe2:	24a98993          	addi	s3,s3,586 # 80018228 <tickslock>
    80001fe6:	a801                	j	80001ff6 <wakeup+0x38>
      }
    }
    release(&p->lock);
    80001fe8:	8526                	mv	a0,s1
    80001fea:	cc7fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001fee:	16848493          	addi	s1,s1,360
    80001ff2:	03348063          	beq	s1,s3,80002012 <wakeup+0x54>
    acquire(&p->lock);
    80001ff6:	8526                	mv	a0,s1
    80001ff8:	c31fe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    80001ffc:	709c                	ld	a5,32(s1)
    80001ffe:	ff2795e3          	bne	a5,s2,80001fe8 <wakeup+0x2a>
      p->chan = 0;
    80002002:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80002006:	4c9c                	lw	a5,24(s1)
    80002008:	ff4790e3          	bne	a5,s4,80001fe8 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000200c:	0154ac23          	sw	s5,24(s1)
    80002010:	bfe1                	j	80001fe8 <wakeup+0x2a>
  }
}
    80002012:	70e2                	ld	ra,56(sp)
    80002014:	7442                	ld	s0,48(sp)
    80002016:	74a2                	ld	s1,40(sp)
    80002018:	7902                	ld	s2,32(sp)
    8000201a:	69e2                	ld	s3,24(sp)
    8000201c:	6a42                	ld	s4,16(sp)
    8000201e:	6aa2                	ld	s5,8(sp)
    80002020:	6121                	addi	sp,sp,64
    80002022:	8082                	ret

0000000080002024 <reparent>:
{
    80002024:	7179                	addi	sp,sp,-48
    80002026:	f406                	sd	ra,40(sp)
    80002028:	f022                	sd	s0,32(sp)
    8000202a:	ec26                	sd	s1,24(sp)
    8000202c:	e84a                	sd	s2,16(sp)
    8000202e:	e44e                	sd	s3,8(sp)
    80002030:	e052                	sd	s4,0(sp)
    80002032:	1800                	addi	s0,sp,48
    80002034:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002036:	00010497          	auipc	s1,0x10
    8000203a:	7f248493          	addi	s1,s1,2034 # 80012828 <proc>
      pp->parent = initproc;
    8000203e:	00008a17          	auipc	s4,0x8
    80002042:	2b2a0a13          	addi	s4,s4,690 # 8000a2f0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002046:	00016997          	auipc	s3,0x16
    8000204a:	1e298993          	addi	s3,s3,482 # 80018228 <tickslock>
    8000204e:	a029                	j	80002058 <reparent+0x34>
    80002050:	16848493          	addi	s1,s1,360
    80002054:	01348b63          	beq	s1,s3,8000206a <reparent+0x46>
    if (pp->parent == p) {
    80002058:	7c9c                	ld	a5,56(s1)
    8000205a:	ff279be3          	bne	a5,s2,80002050 <reparent+0x2c>
      pp->parent = initproc;
    8000205e:	000a3503          	ld	a0,0(s4)
    80002062:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002064:	f5bff0ef          	jal	80001fbe <wakeup>
    80002068:	b7e5                	j	80002050 <reparent+0x2c>
}
    8000206a:	70a2                	ld	ra,40(sp)
    8000206c:	7402                	ld	s0,32(sp)
    8000206e:	64e2                	ld	s1,24(sp)
    80002070:	6942                	ld	s2,16(sp)
    80002072:	69a2                	ld	s3,8(sp)
    80002074:	6a02                	ld	s4,0(sp)
    80002076:	6145                	addi	sp,sp,48
    80002078:	8082                	ret

000000008000207a <kexit>:
{
    8000207a:	7179                	addi	sp,sp,-48
    8000207c:	f406                	sd	ra,40(sp)
    8000207e:	f022                	sd	s0,32(sp)
    80002080:	ec26                	sd	s1,24(sp)
    80002082:	e84a                	sd	s2,16(sp)
    80002084:	e44e                	sd	s3,8(sp)
    80002086:	e052                	sd	s4,0(sp)
    80002088:	1800                	addi	s0,sp,48
    8000208a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000208c:	8bdff0ef          	jal	80001948 <myproc>
    80002090:	89aa                	mv	s3,a0
  if (p == initproc)
    80002092:	00008797          	auipc	a5,0x8
    80002096:	25e7b783          	ld	a5,606(a5) # 8000a2f0 <initproc>
    8000209a:	0d050493          	addi	s1,a0,208
    8000209e:	15050913          	addi	s2,a0,336
    800020a2:	00a79b63          	bne	a5,a0,800020b8 <kexit+0x3e>
    panic("init exiting");
    800020a6:	00005517          	auipc	a0,0x5
    800020aa:	15a50513          	addi	a0,a0,346 # 80007200 <etext+0x200>
    800020ae:	f86fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    800020b2:	04a1                	addi	s1,s1,8
    800020b4:	01248963          	beq	s1,s2,800020c6 <kexit+0x4c>
    if (p->ofile[fd]) {
    800020b8:	6088                	ld	a0,0(s1)
    800020ba:	dd65                	beqz	a0,800020b2 <kexit+0x38>
      fileclose(f);
    800020bc:	0e0020ef          	jal	8000419c <fileclose>
      p->ofile[fd] = 0;
    800020c0:	0004b023          	sd	zero,0(s1)
    800020c4:	b7fd                	j	800020b2 <kexit+0x38>
  begin_op();
    800020c6:	41d010ef          	jal	80003ce2 <begin_op>
  iput(p->cwd);
    800020ca:	1509b503          	ld	a0,336(s3)
    800020ce:	31e010ef          	jal	800033ec <iput>
  end_op();
    800020d2:	49d010ef          	jal	80003d6e <end_op>
  p->cwd = 0;
    800020d6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800020da:	00010517          	auipc	a0,0x10
    800020de:	33650513          	addi	a0,a0,822 # 80012410 <wait_lock>
    800020e2:	b47fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    800020e6:	854e                	mv	a0,s3
    800020e8:	f3dff0ef          	jal	80002024 <reparent>
  wakeup(p->parent);
    800020ec:	0389b503          	ld	a0,56(s3)
    800020f0:	ecfff0ef          	jal	80001fbe <wakeup>
  acquire(&p->lock);
    800020f4:	854e                	mv	a0,s3
    800020f6:	b33fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    800020fa:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800020fe:	4795                	li	a5,5
    80002100:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002104:	00010517          	auipc	a0,0x10
    80002108:	30c50513          	addi	a0,a0,780 # 80012410 <wait_lock>
    8000210c:	ba5fe0ef          	jal	80000cb0 <release>
  sched();
    80002110:	d5bff0ef          	jal	80001e6a <sched>
  panic("zombie exit");
    80002114:	00005517          	auipc	a0,0x5
    80002118:	0fc50513          	addi	a0,a0,252 # 80007210 <etext+0x210>
    8000211c:	f18fe0ef          	jal	80000834 <panic>

0000000080002120 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    80002120:	c525                	beqz	a0,80002188 <kkill+0x68>
{
    80002122:	7179                	addi	sp,sp,-48
    80002124:	f406                	sd	ra,40(sp)
    80002126:	f022                	sd	s0,32(sp)
    80002128:	ec26                	sd	s1,24(sp)
    8000212a:	e84a                	sd	s2,16(sp)
    8000212c:	e44e                	sd	s3,8(sp)
    8000212e:	1800                	addi	s0,sp,48
    80002130:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002132:	00010497          	auipc	s1,0x10
    80002136:	6f648493          	addi	s1,s1,1782 # 80012828 <proc>
    8000213a:	00016997          	auipc	s3,0x16
    8000213e:	0ee98993          	addi	s3,s3,238 # 80018228 <tickslock>
    acquire(&p->lock);
    80002142:	8526                	mv	a0,s1
    80002144:	ae5fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    80002148:	589c                	lw	a5,48(s1)
    8000214a:	01278b63          	beq	a5,s2,80002160 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000214e:	8526                	mv	a0,s1
    80002150:	b61fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002154:	16848493          	addi	s1,s1,360
    80002158:	ff3495e3          	bne	s1,s3,80002142 <kkill+0x22>
  }
  return -1;
    8000215c:	557d                	li	a0,-1
    8000215e:	a819                	j	80002174 <kkill+0x54>
      p->killed = 1;
    80002160:	4785                	li	a5,1
    80002162:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002164:	4c98                	lw	a4,24(s1)
    80002166:	4789                	li	a5,2
    80002168:	00f70d63          	beq	a4,a5,80002182 <kkill+0x62>
      release(&p->lock);
    8000216c:	8526                	mv	a0,s1
    8000216e:	b43fe0ef          	jal	80000cb0 <release>
      return 0;
    80002172:	4501                	li	a0,0
}
    80002174:	70a2                	ld	ra,40(sp)
    80002176:	7402                	ld	s0,32(sp)
    80002178:	64e2                	ld	s1,24(sp)
    8000217a:	6942                	ld	s2,16(sp)
    8000217c:	69a2                	ld	s3,8(sp)
    8000217e:	6145                	addi	sp,sp,48
    80002180:	8082                	ret
        p->state = RUNNABLE;
    80002182:	478d                	li	a5,3
    80002184:	cc9c                	sw	a5,24(s1)
    80002186:	b7dd                	j	8000216c <kkill+0x4c>
    return -1;
    80002188:	557d                	li	a0,-1
}
    8000218a:	8082                	ret

000000008000218c <setkilled>:

void
setkilled(struct proc *p)
{
    8000218c:	1101                	addi	sp,sp,-32
    8000218e:	ec06                	sd	ra,24(sp)
    80002190:	e822                	sd	s0,16(sp)
    80002192:	e426                	sd	s1,8(sp)
    80002194:	1000                	addi	s0,sp,32
    80002196:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002198:	a91fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    8000219c:	4785                	li	a5,1
    8000219e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800021a0:	8526                	mv	a0,s1
    800021a2:	b0ffe0ef          	jal	80000cb0 <release>
}
    800021a6:	60e2                	ld	ra,24(sp)
    800021a8:	6442                	ld	s0,16(sp)
    800021aa:	64a2                	ld	s1,8(sp)
    800021ac:	6105                	addi	sp,sp,32
    800021ae:	8082                	ret

00000000800021b0 <killed>:

int
killed(struct proc *p)
{
    800021b0:	1101                	addi	sp,sp,-32
    800021b2:	ec06                	sd	ra,24(sp)
    800021b4:	e822                	sd	s0,16(sp)
    800021b6:	e426                	sd	s1,8(sp)
    800021b8:	e04a                	sd	s2,0(sp)
    800021ba:	1000                	addi	s0,sp,32
    800021bc:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800021be:	a6bfe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    800021c2:	549c                	lw	a5,40(s1)
    800021c4:	893e                	mv	s2,a5
  release(&p->lock);
    800021c6:	8526                	mv	a0,s1
    800021c8:	ae9fe0ef          	jal	80000cb0 <release>
  return k;
}
    800021cc:	854a                	mv	a0,s2
    800021ce:	60e2                	ld	ra,24(sp)
    800021d0:	6442                	ld	s0,16(sp)
    800021d2:	64a2                	ld	s1,8(sp)
    800021d4:	6902                	ld	s2,0(sp)
    800021d6:	6105                	addi	sp,sp,32
    800021d8:	8082                	ret

00000000800021da <kwait>:
{
    800021da:	715d                	addi	sp,sp,-80
    800021dc:	e486                	sd	ra,72(sp)
    800021de:	e0a2                	sd	s0,64(sp)
    800021e0:	fc26                	sd	s1,56(sp)
    800021e2:	f84a                	sd	s2,48(sp)
    800021e4:	f44e                	sd	s3,40(sp)
    800021e6:	f052                	sd	s4,32(sp)
    800021e8:	ec56                	sd	s5,24(sp)
    800021ea:	e85a                	sd	s6,16(sp)
    800021ec:	e45e                	sd	s7,8(sp)
    800021ee:	0880                	addi	s0,sp,80
    800021f0:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800021f2:	f56ff0ef          	jal	80001948 <myproc>
    800021f6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021f8:	00010517          	auipc	a0,0x10
    800021fc:	21850513          	addi	a0,a0,536 # 80012410 <wait_lock>
    80002200:	a29fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002204:	4a15                	li	s4,5
        havekids = 1;
    80002206:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002208:	00016997          	auipc	s3,0x16
    8000220c:	02098993          	addi	s3,s3,32 # 80018228 <tickslock>
    release(&wait_lock);
    80002210:	00010b17          	auipc	s6,0x10
    80002214:	200b0b13          	addi	s6,s6,512 # 80012410 <wait_lock>
    80002218:	a845                	j	800022c8 <kwait+0xee>
          pid = pp->pid;
    8000221a:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    8000221e:	000b8e63          	beqz	s7,8000223a <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    80002222:	4711                	li	a4,4
    80002224:	02c48693          	addi	a3,s1,44
    80002228:	865e                	mv	a2,s7
    8000222a:	04893583          	ld	a1,72(s2)
    8000222e:	05093503          	ld	a0,80(s2)
    80002232:	b50ff0ef          	jal	80001582 <copyout>
          if (addr != 0 &&
    80002236:	02054c63          	bltz	a0,8000226e <kwait+0x94>
          pp->parent = 0;
    8000223a:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    8000223e:	8526                	mv	a0,s1
    80002240:	8d9ff0ef          	jal	80001b18 <freeproc>
          release(&pp->lock);
    80002244:	8526                	mv	a0,s1
    80002246:	a6bfe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    8000224a:	00010517          	auipc	a0,0x10
    8000224e:	1c650513          	addi	a0,a0,454 # 80012410 <wait_lock>
    80002252:	a5ffe0ef          	jal	80000cb0 <release>
}
    80002256:	854e                	mv	a0,s3
    80002258:	60a6                	ld	ra,72(sp)
    8000225a:	6406                	ld	s0,64(sp)
    8000225c:	74e2                	ld	s1,56(sp)
    8000225e:	7942                	ld	s2,48(sp)
    80002260:	79a2                	ld	s3,40(sp)
    80002262:	7a02                	ld	s4,32(sp)
    80002264:	6ae2                	ld	s5,24(sp)
    80002266:	6b42                	ld	s6,16(sp)
    80002268:	6ba2                	ld	s7,8(sp)
    8000226a:	6161                	addi	sp,sp,80
    8000226c:	8082                	ret
            release(&pp->lock);
    8000226e:	8526                	mv	a0,s1
    80002270:	a41fe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    80002274:	00010517          	auipc	a0,0x10
    80002278:	19c50513          	addi	a0,a0,412 # 80012410 <wait_lock>
    8000227c:	a35fe0ef          	jal	80000cb0 <release>
            return -1;
    80002280:	59fd                	li	s3,-1
    80002282:	bfd1                	j	80002256 <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002284:	16848493          	addi	s1,s1,360
    80002288:	03348063          	beq	s1,s3,800022a8 <kwait+0xce>
      if (pp->parent == p) {
    8000228c:	7c9c                	ld	a5,56(s1)
    8000228e:	ff279be3          	bne	a5,s2,80002284 <kwait+0xaa>
        acquire(&pp->lock);
    80002292:	8526                	mv	a0,s1
    80002294:	995fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002298:	4c9c                	lw	a5,24(s1)
    8000229a:	f94780e3          	beq	a5,s4,8000221a <kwait+0x40>
        release(&pp->lock);
    8000229e:	8526                	mv	a0,s1
    800022a0:	a11fe0ef          	jal	80000cb0 <release>
        havekids = 1;
    800022a4:	8756                	mv	a4,s5
    800022a6:	bff9                	j	80002284 <kwait+0xaa>
    if (!havekids || killed(p)) {
    800022a8:	c715                	beqz	a4,800022d4 <kwait+0xfa>
    800022aa:	854a                	mv	a0,s2
    800022ac:	f05ff0ef          	jal	800021b0 <killed>
    800022b0:	e115                	bnez	a0,800022d4 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    800022b2:	854a                	mv	a0,s2
    800022b4:	c9fff0ef          	jal	80001f52 <sleep_prepare>
    release(&wait_lock);
    800022b8:	855a                	mv	a0,s6
    800022ba:	9f7fe0ef          	jal	80000cb0 <release>
    sleep();
    800022be:	cd1ff0ef          	jal	80001f8e <sleep>
    acquire(&wait_lock);
    800022c2:	855a                	mv	a0,s6
    800022c4:	965fe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    800022c8:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022ca:	00010497          	auipc	s1,0x10
    800022ce:	55e48493          	addi	s1,s1,1374 # 80012828 <proc>
    800022d2:	bf6d                	j	8000228c <kwait+0xb2>
      release(&wait_lock);
    800022d4:	00010517          	auipc	a0,0x10
    800022d8:	13c50513          	addi	a0,a0,316 # 80012410 <wait_lock>
    800022dc:	9d5fe0ef          	jal	80000cb0 <release>
      return -1;
    800022e0:	59fd                	li	s3,-1
    800022e2:	bf95                	j	80002256 <kwait+0x7c>

00000000800022e4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800022e4:	7179                	addi	sp,sp,-48
    800022e6:	f406                	sd	ra,40(sp)
    800022e8:	f022                	sd	s0,32(sp)
    800022ea:	ec26                	sd	s1,24(sp)
    800022ec:	e84a                	sd	s2,16(sp)
    800022ee:	e44e                	sd	s3,8(sp)
    800022f0:	e052                	sd	s4,0(sp)
    800022f2:	1800                	addi	s0,sp,48
    800022f4:	84aa                	mv	s1,a0
    800022f6:	8a2e                	mv	s4,a1
    800022f8:	89b2                	mv	s3,a2
    800022fa:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800022fc:	e4cff0ef          	jal	80001948 <myproc>
  if (user_dst) {
    80002300:	c085                	beqz	s1,80002320 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    80002302:	874a                	mv	a4,s2
    80002304:	86ce                	mv	a3,s3
    80002306:	8652                	mv	a2,s4
    80002308:	652c                	ld	a1,72(a0)
    8000230a:	6928                	ld	a0,80(a0)
    8000230c:	a76ff0ef          	jal	80001582 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002310:	70a2                	ld	ra,40(sp)
    80002312:	7402                	ld	s0,32(sp)
    80002314:	64e2                	ld	s1,24(sp)
    80002316:	6942                	ld	s2,16(sp)
    80002318:	69a2                	ld	s3,8(sp)
    8000231a:	6a02                	ld	s4,0(sp)
    8000231c:	6145                	addi	sp,sp,48
    8000231e:	8082                	ret
    memmove((char *)dst, src, len);
    80002320:	0009061b          	sext.w	a2,s2
    80002324:	85ce                	mv	a1,s3
    80002326:	8552                	mv	a0,s4
    80002328:	a21fe0ef          	jal	80000d48 <memmove>
    return 0;
    8000232c:	8526                	mv	a0,s1
    8000232e:	b7cd                	j	80002310 <either_copyout+0x2c>

0000000080002330 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002330:	7179                	addi	sp,sp,-48
    80002332:	f406                	sd	ra,40(sp)
    80002334:	f022                	sd	s0,32(sp)
    80002336:	ec26                	sd	s1,24(sp)
    80002338:	e84a                	sd	s2,16(sp)
    8000233a:	e44e                	sd	s3,8(sp)
    8000233c:	e052                	sd	s4,0(sp)
    8000233e:	1800                	addi	s0,sp,48
    80002340:	8a2a                	mv	s4,a0
    80002342:	84ae                	mv	s1,a1
    80002344:	89b2                	mv	s3,a2
    80002346:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002348:	e00ff0ef          	jal	80001948 <myproc>
  if (user_src) {
    8000234c:	c085                	beqz	s1,8000236c <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    8000234e:	874a                	mv	a4,s2
    80002350:	86ce                	mv	a3,s3
    80002352:	8652                	mv	a2,s4
    80002354:	652c                	ld	a1,72(a0)
    80002356:	6928                	ld	a0,80(a0)
    80002358:	af0ff0ef          	jal	80001648 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000235c:	70a2                	ld	ra,40(sp)
    8000235e:	7402                	ld	s0,32(sp)
    80002360:	64e2                	ld	s1,24(sp)
    80002362:	6942                	ld	s2,16(sp)
    80002364:	69a2                	ld	s3,8(sp)
    80002366:	6a02                	ld	s4,0(sp)
    80002368:	6145                	addi	sp,sp,48
    8000236a:	8082                	ret
    memmove(dst, (char *)src, len);
    8000236c:	0009061b          	sext.w	a2,s2
    80002370:	85ce                	mv	a1,s3
    80002372:	8552                	mv	a0,s4
    80002374:	9d5fe0ef          	jal	80000d48 <memmove>
    return 0;
    80002378:	8526                	mv	a0,s1
    8000237a:	b7cd                	j	8000235c <either_copyin+0x2c>

000000008000237c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000237c:	715d                	addi	sp,sp,-80
    8000237e:	e486                	sd	ra,72(sp)
    80002380:	e0a2                	sd	s0,64(sp)
    80002382:	fc26                	sd	s1,56(sp)
    80002384:	f84a                	sd	s2,48(sp)
    80002386:	f44e                	sd	s3,40(sp)
    80002388:	f052                	sd	s4,32(sp)
    8000238a:	ec56                	sd	s5,24(sp)
    8000238c:	e85a                	sd	s6,16(sp)
    8000238e:	e45e                	sd	s7,8(sp)
    80002390:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002392:	00005517          	auipc	a0,0x5
    80002396:	ce650513          	addi	a0,a0,-794 # 80007078 <etext+0x78>
    8000239a:	970fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000239e:	00010497          	auipc	s1,0x10
    800023a2:	5e248493          	addi	s1,s1,1506 # 80012980 <proc+0x158>
    800023a6:	00016917          	auipc	s2,0x16
    800023aa:	fda90913          	addi	s2,s2,-38 # 80018380 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023ae:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800023b0:	00005997          	auipc	s3,0x5
    800023b4:	e7098993          	addi	s3,s3,-400 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    800023b8:	00005a97          	auipc	s5,0x5
    800023bc:	e70a8a93          	addi	s5,s5,-400 # 80007228 <etext+0x228>
    printk("\n");
    800023c0:	00005a17          	auipc	s4,0x5
    800023c4:	cb8a0a13          	addi	s4,s4,-840 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023c8:	00005b97          	auipc	s7,0x5
    800023cc:	380b8b93          	addi	s7,s7,896 # 80007748 <states.0>
    800023d0:	a829                	j	800023ea <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    800023d2:	ed86a583          	lw	a1,-296(a3)
    800023d6:	8556                	mv	a0,s5
    800023d8:	932fe0ef          	jal	8000050a <printk>
    printk("\n");
    800023dc:	8552                	mv	a0,s4
    800023de:	92cfe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800023e2:	16848493          	addi	s1,s1,360
    800023e6:	03248263          	beq	s1,s2,8000240a <procdump+0x8e>
    if (p->state == UNUSED)
    800023ea:	86a6                	mv	a3,s1
    800023ec:	ec04a783          	lw	a5,-320(s1)
    800023f0:	dbed                	beqz	a5,800023e2 <procdump+0x66>
      state = "???";
    800023f2:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023f4:	fcfb6fe3          	bltu	s6,a5,800023d2 <procdump+0x56>
    800023f8:	02079713          	slli	a4,a5,0x20
    800023fc:	01d75793          	srli	a5,a4,0x1d
    80002400:	97de                	add	a5,a5,s7
    80002402:	6390                	ld	a2,0(a5)
    80002404:	f679                	bnez	a2,800023d2 <procdump+0x56>
      state = "???";
    80002406:	864e                	mv	a2,s3
    80002408:	b7e9                	j	800023d2 <procdump+0x56>
  }
}
    8000240a:	60a6                	ld	ra,72(sp)
    8000240c:	6406                	ld	s0,64(sp)
    8000240e:	74e2                	ld	s1,56(sp)
    80002410:	7942                	ld	s2,48(sp)
    80002412:	79a2                	ld	s3,40(sp)
    80002414:	7a02                	ld	s4,32(sp)
    80002416:	6ae2                	ld	s5,24(sp)
    80002418:	6b42                	ld	s6,16(sp)
    8000241a:	6ba2                	ld	s7,8(sp)
    8000241c:	6161                	addi	sp,sp,80
    8000241e:	8082                	ret

0000000080002420 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002420:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002424:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002428:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000242a:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000242c:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002430:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002434:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002438:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000243c:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002440:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002444:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002448:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000244c:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002450:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002454:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002458:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000245c:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000245e:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002460:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002464:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002468:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000246c:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002470:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002474:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002478:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000247c:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002480:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002484:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002488:	8082                	ret

000000008000248a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000248a:	1141                	addi	sp,sp,-16
    8000248c:	e406                	sd	ra,8(sp)
    8000248e:	e022                	sd	s0,0(sp)
    80002490:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002492:	00005597          	auipc	a1,0x5
    80002496:	dd658593          	addi	a1,a1,-554 # 80007268 <etext+0x268>
    8000249a:	00016517          	auipc	a0,0x16
    8000249e:	d8e50513          	addi	a0,a0,-626 # 80018228 <tickslock>
    800024a2:	f06fe0ef          	jal	80000ba8 <initlock>
}
    800024a6:	60a2                	ld	ra,8(sp)
    800024a8:	6402                	ld	s0,0(sp)
    800024aa:	0141                	addi	sp,sp,16
    800024ac:	8082                	ret

00000000800024ae <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024ae:	1141                	addi	sp,sp,-16
    800024b0:	e406                	sd	ra,8(sp)
    800024b2:	e022                	sd	s0,0(sp)
    800024b4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    800024b6:	00003797          	auipc	a5,0x3
    800024ba:	16a78793          	addi	a5,a5,362 # 80005620 <kernelvec>
    800024be:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024c2:	60a2                	ld	ra,8(sp)
    800024c4:	6402                	ld	s0,0(sp)
    800024c6:	0141                	addi	sp,sp,16
    800024c8:	8082                	ret

00000000800024ca <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800024ca:	1141                	addi	sp,sp,-16
    800024cc:	e406                	sd	ra,8(sp)
    800024ce:	e022                	sd	s0,0(sp)
    800024d0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024d2:	c76ff0ef          	jal	80001948 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    800024d6:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800024da:	04000737          	lui	a4,0x4000
    800024de:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800024e0:	0732                	slli	a4,a4,0xc
    800024e2:	00004797          	auipc	a5,0x4
    800024e6:	b1e78793          	addi	a5,a5,-1250 # 80006000 <_trampoline>
    800024ea:	00004697          	auipc	a3,0x4
    800024ee:	b1668693          	addi	a3,a3,-1258 # 80006000 <_trampoline>
    800024f2:	8f95                	sub	a5,a5,a3
    800024f4:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    800024f6:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024fa:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    800024fc:	18002773          	csrr	a4,satp
    80002500:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002502:	6d38                	ld	a4,88(a0)
    80002504:	613c                	ld	a5,64(a0)
    80002506:	6685                	lui	a3,0x1
    80002508:	97b6                	add	a5,a5,a3
    8000250a:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000250c:	6d3c                	ld	a5,88(a0)
    8000250e:	00000717          	auipc	a4,0x0
    80002512:	0fc70713          	addi	a4,a4,252 # 8000260a <usertrap>
    80002516:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002518:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    8000251a:	8712                	mv	a4,tp
    8000251c:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000251e:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002522:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002526:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000252a:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000252e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002530:	6f9c                	ld	a5,24(a5)
    80002532:	14179073          	csrw	sepc,a5
}
    80002536:	60a2                	ld	ra,8(sp)
    80002538:	6402                	ld	s0,0(sp)
    8000253a:	0141                	addi	sp,sp,16
    8000253c:	8082                	ret

000000008000253e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000253e:	1141                	addi	sp,sp,-16
    80002540:	e406                	sd	ra,8(sp)
    80002542:	e022                	sd	s0,0(sp)
    80002544:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80002546:	bceff0ef          	jal	80001914 <cpuid>
    8000254a:	cd11                	beqz	a0,80002566 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    8000254c:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002550:	000f4737          	lui	a4,0xf4
    80002554:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002558:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000255a:	14d79073          	csrw	stimecmp,a5
}
    8000255e:	60a2                	ld	ra,8(sp)
    80002560:	6402                	ld	s0,0(sp)
    80002562:	0141                	addi	sp,sp,16
    80002564:	8082                	ret
    acquire(&tickslock);
    80002566:	00016517          	auipc	a0,0x16
    8000256a:	cc250513          	addi	a0,a0,-830 # 80018228 <tickslock>
    8000256e:	ebafe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002572:	00008717          	auipc	a4,0x8
    80002576:	d8670713          	addi	a4,a4,-634 # 8000a2f8 <ticks>
    8000257a:	431c                	lw	a5,0(a4)
    8000257c:	2785                	addiw	a5,a5,1
    8000257e:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002580:	853a                	mv	a0,a4
    80002582:	a3dff0ef          	jal	80001fbe <wakeup>
    release(&tickslock);
    80002586:	00016517          	auipc	a0,0x16
    8000258a:	ca250513          	addi	a0,a0,-862 # 80018228 <tickslock>
    8000258e:	f22fe0ef          	jal	80000cb0 <release>
    80002592:	bf6d                	j	8000254c <clockintr+0xe>

0000000080002594 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002594:	1101                	addi	sp,sp,-32
    80002596:	ec06                	sd	ra,24(sp)
    80002598:	e822                	sd	s0,16(sp)
    8000259a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    8000259c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    800025a0:	57fd                	li	a5,-1
    800025a2:	17fe                	slli	a5,a5,0x3f
    800025a4:	07a5                	addi	a5,a5,9
    800025a6:	00f70c63          	beq	a4,a5,800025be <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    800025aa:	57fd                	li	a5,-1
    800025ac:	17fe                	slli	a5,a5,0x3f
    800025ae:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025b0:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    800025b2:	04f70863          	beq	a4,a5,80002602 <devintr+0x6e>
  }
}
    800025b6:	60e2                	ld	ra,24(sp)
    800025b8:	6442                	ld	s0,16(sp)
    800025ba:	6105                	addi	sp,sp,32
    800025bc:	8082                	ret
    800025be:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800025c0:	10e030ef          	jal	800056ce <plic_claim>
    800025c4:	872a                	mv	a4,a0
    800025c6:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    800025c8:	47a9                	li	a5,10
    800025ca:	00f50963          	beq	a0,a5,800025dc <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    800025ce:	4785                	li	a5,1
    800025d0:	00f50963          	beq	a0,a5,800025e2 <devintr+0x4e>
    return 1;
    800025d4:	4505                	li	a0,1
    } else if (irq) {
    800025d6:	eb09                	bnez	a4,800025e8 <devintr+0x54>
    800025d8:	64a2                	ld	s1,8(sp)
    800025da:	bff1                	j	800025b6 <devintr+0x22>
      uartintr();
    800025dc:	c12fe0ef          	jal	800009ee <uartintr>
    if (irq)
    800025e0:	a819                	j	800025f6 <devintr+0x62>
      virtio_disk_intr();
    800025e2:	5a8030ef          	jal	80005b8a <virtio_disk_intr>
    if (irq)
    800025e6:	a801                	j	800025f6 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    800025e8:	85ba                	mv	a1,a4
    800025ea:	00005517          	auipc	a0,0x5
    800025ee:	c8650513          	addi	a0,a0,-890 # 80007270 <etext+0x270>
    800025f2:	f19fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    800025f6:	8526                	mv	a0,s1
    800025f8:	0f8030ef          	jal	800056f0 <plic_complete>
    return 1;
    800025fc:	4505                	li	a0,1
    800025fe:	64a2                	ld	s1,8(sp)
    80002600:	bf5d                	j	800025b6 <devintr+0x22>
    clockintr();
    80002602:	f3dff0ef          	jal	8000253e <clockintr>
    return 2;
    80002606:	4509                	li	a0,2
    80002608:	b77d                	j	800025b6 <devintr+0x22>

000000008000260a <usertrap>:
{
    8000260a:	1101                	addi	sp,sp,-32
    8000260c:	ec06                	sd	ra,24(sp)
    8000260e:	e822                	sd	s0,16(sp)
    80002610:	e426                	sd	s1,8(sp)
    80002612:	e04a                	sd	s2,0(sp)
    80002614:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002616:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    8000261a:	1007f793          	andi	a5,a5,256
    8000261e:	eba5                	bnez	a5,8000268e <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002620:	00003797          	auipc	a5,0x3
    80002624:	00078793          	mv	a5,a5
    80002628:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000262c:	b1cff0ef          	jal	80001948 <myproc>
    80002630:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002632:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002634:	14102773          	csrr	a4,sepc
    80002638:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    8000263a:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    8000263e:	47a1                	li	a5,8
    80002640:	04f70d63          	beq	a4,a5,8000269a <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    80002644:	f51ff0ef          	jal	80002594 <devintr>
    80002648:	892a                	mv	s2,a0
    8000264a:	e54d                	bnez	a0,800026f4 <usertrap+0xea>
    8000264c:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002650:	47bd                	li	a5,15
    80002652:	08f70463          	beq	a4,a5,800026da <usertrap+0xd0>
    80002656:	14202773          	csrr	a4,scause
    8000265a:	47b5                	li	a5,13
    8000265c:	06f70f63          	beq	a4,a5,800026da <usertrap+0xd0>
    80002660:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002664:	5890                	lw	a2,48(s1)
    80002666:	00005517          	auipc	a0,0x5
    8000266a:	c4a50513          	addi	a0,a0,-950 # 800072b0 <etext+0x2b0>
    8000266e:	e9dfd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002672:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002676:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000267a:	00005517          	auipc	a0,0x5
    8000267e:	c6650513          	addi	a0,a0,-922 # 800072e0 <etext+0x2e0>
    80002682:	e89fd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002686:	8526                	mv	a0,s1
    80002688:	b05ff0ef          	jal	8000218c <setkilled>
    8000268c:	a015                	j	800026b0 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    8000268e:	00005517          	auipc	a0,0x5
    80002692:	c0250513          	addi	a0,a0,-1022 # 80007290 <etext+0x290>
    80002696:	99efe0ef          	jal	80000834 <panic>
    if (killed(p))
    8000269a:	b17ff0ef          	jal	800021b0 <killed>
    8000269e:	e915                	bnez	a0,800026d2 <usertrap+0xc8>
    p->trapframe->epc += 4;
    800026a0:	6cb8                	ld	a4,88(s1)
    800026a2:	6f1c                	ld	a5,24(a4)
    800026a4:	0791                	addi	a5,a5,4 # 80005624 <kernelvec+0x4>
    800026a6:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    800026a8:	10016073          	csrsi	sstatus,2
    syscall();
    800026ac:	244000ef          	jal	800028f0 <syscall>
  if (killed(p))
    800026b0:	8526                	mv	a0,s1
    800026b2:	affff0ef          	jal	800021b0 <killed>
    800026b6:	e521                	bnez	a0,800026fe <usertrap+0xf4>
  prepare_return();
    800026b8:	e13ff0ef          	jal	800024ca <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800026bc:	68a8                	ld	a0,80(s1)
    800026be:	8131                	srli	a0,a0,0xc
    800026c0:	57fd                	li	a5,-1
    800026c2:	17fe                	slli	a5,a5,0x3f
    800026c4:	8d5d                	or	a0,a0,a5
}
    800026c6:	60e2                	ld	ra,24(sp)
    800026c8:	6442                	ld	s0,16(sp)
    800026ca:	64a2                	ld	s1,8(sp)
    800026cc:	6902                	ld	s2,0(sp)
    800026ce:	6105                	addi	sp,sp,32
    800026d0:	8082                	ret
      kexit(-1);
    800026d2:	557d                	li	a0,-1
    800026d4:	9a7ff0ef          	jal	8000207a <kexit>
    800026d8:	b7e1                	j	800026a0 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    800026da:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    800026de:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    800026e2:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    800026e4:	0016b693          	seqz	a3,a3
    800026e8:	64ac                	ld	a1,72(s1)
    800026ea:	68a8                	ld	a0,80(s1)
    800026ec:	e1bfe0ef          	jal	80001506 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800026f0:	f161                	bnez	a0,800026b0 <usertrap+0xa6>
    800026f2:	b7bd                	j	80002660 <usertrap+0x56>
  if (killed(p))
    800026f4:	8526                	mv	a0,s1
    800026f6:	abbff0ef          	jal	800021b0 <killed>
    800026fa:	c511                	beqz	a0,80002706 <usertrap+0xfc>
    800026fc:	a011                	j	80002700 <usertrap+0xf6>
    800026fe:	4901                	li	s2,0
    kexit(-1);
    80002700:	557d                	li	a0,-1
    80002702:	979ff0ef          	jal	8000207a <kexit>
  if (which_dev == 2)
    80002706:	4789                	li	a5,2
    80002708:	faf918e3          	bne	s2,a5,800026b8 <usertrap+0xae>
    yield();
    8000270c:	81bff0ef          	jal	80001f26 <yield>
    80002710:	b765                	j	800026b8 <usertrap+0xae>

0000000080002712 <kerneltrap>:
{
    80002712:	7179                	addi	sp,sp,-48
    80002714:	f406                	sd	ra,40(sp)
    80002716:	f022                	sd	s0,32(sp)
    80002718:	ec26                	sd	s1,24(sp)
    8000271a:	e84a                	sd	s2,16(sp)
    8000271c:	e44e                	sd	s3,8(sp)
    8000271e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002720:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002724:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    80002728:	142027f3          	csrr	a5,scause
    8000272c:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    8000272e:	1004f793          	andi	a5,s1,256
    80002732:	c795                	beqz	a5,8000275e <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002734:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002738:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000273a:	eb85                	bnez	a5,8000276a <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    8000273c:	e59ff0ef          	jal	80002594 <devintr>
    80002740:	c91d                	beqz	a0,80002776 <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    80002742:	4789                	li	a5,2
    80002744:	04f50a63          	beq	a0,a5,80002798 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002748:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000274c:	10049073          	csrw	sstatus,s1
}
    80002750:	70a2                	ld	ra,40(sp)
    80002752:	7402                	ld	s0,32(sp)
    80002754:	64e2                	ld	s1,24(sp)
    80002756:	6942                	ld	s2,16(sp)
    80002758:	69a2                	ld	s3,8(sp)
    8000275a:	6145                	addi	sp,sp,48
    8000275c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000275e:	00005517          	auipc	a0,0x5
    80002762:	baa50513          	addi	a0,a0,-1110 # 80007308 <etext+0x308>
    80002766:	8cefe0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    8000276a:	00005517          	auipc	a0,0x5
    8000276e:	bc650513          	addi	a0,a0,-1082 # 80007330 <etext+0x330>
    80002772:	8c2fe0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002776:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000277a:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    8000277e:	85ce                	mv	a1,s3
    80002780:	00005517          	auipc	a0,0x5
    80002784:	bd050513          	addi	a0,a0,-1072 # 80007350 <etext+0x350>
    80002788:	d83fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    8000278c:	00005517          	auipc	a0,0x5
    80002790:	bec50513          	addi	a0,a0,-1044 # 80007378 <etext+0x378>
    80002794:	8a0fe0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    80002798:	9b0ff0ef          	jal	80001948 <myproc>
    8000279c:	d555                	beqz	a0,80002748 <kerneltrap+0x36>
    yield();
    8000279e:	f88ff0ef          	jal	80001f26 <yield>
    800027a2:	b75d                	j	80002748 <kerneltrap+0x36>

00000000800027a4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800027a4:	1101                	addi	sp,sp,-32
    800027a6:	ec06                	sd	ra,24(sp)
    800027a8:	e822                	sd	s0,16(sp)
    800027aa:	e426                	sd	s1,8(sp)
    800027ac:	1000                	addi	s0,sp,32
    800027ae:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027b0:	998ff0ef          	jal	80001948 <myproc>
  switch (n) {
    800027b4:	4795                	li	a5,5
    800027b6:	0497e163          	bltu	a5,s1,800027f8 <argraw+0x54>
    800027ba:	048a                	slli	s1,s1,0x2
    800027bc:	00005717          	auipc	a4,0x5
    800027c0:	fbc70713          	addi	a4,a4,-68 # 80007778 <states.0+0x30>
    800027c4:	94ba                	add	s1,s1,a4
    800027c6:	409c                	lw	a5,0(s1)
    800027c8:	97ba                	add	a5,a5,a4
    800027ca:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027cc:	6d3c                	ld	a5,88(a0)
    800027ce:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800027d0:	60e2                	ld	ra,24(sp)
    800027d2:	6442                	ld	s0,16(sp)
    800027d4:	64a2                	ld	s1,8(sp)
    800027d6:	6105                	addi	sp,sp,32
    800027d8:	8082                	ret
    return p->trapframe->a1;
    800027da:	6d3c                	ld	a5,88(a0)
    800027dc:	7fa8                	ld	a0,120(a5)
    800027de:	bfcd                	j	800027d0 <argraw+0x2c>
    return p->trapframe->a2;
    800027e0:	6d3c                	ld	a5,88(a0)
    800027e2:	63c8                	ld	a0,128(a5)
    800027e4:	b7f5                	j	800027d0 <argraw+0x2c>
    return p->trapframe->a3;
    800027e6:	6d3c                	ld	a5,88(a0)
    800027e8:	67c8                	ld	a0,136(a5)
    800027ea:	b7dd                	j	800027d0 <argraw+0x2c>
    return p->trapframe->a4;
    800027ec:	6d3c                	ld	a5,88(a0)
    800027ee:	6bc8                	ld	a0,144(a5)
    800027f0:	b7c5                	j	800027d0 <argraw+0x2c>
    return p->trapframe->a5;
    800027f2:	6d3c                	ld	a5,88(a0)
    800027f4:	6fc8                	ld	a0,152(a5)
    800027f6:	bfe9                	j	800027d0 <argraw+0x2c>
  panic("argraw");
    800027f8:	00005517          	auipc	a0,0x5
    800027fc:	b9050513          	addi	a0,a0,-1136 # 80007388 <etext+0x388>
    80002800:	834fe0ef          	jal	80000834 <panic>

0000000080002804 <fetchaddr>:
{
    80002804:	1101                	addi	sp,sp,-32
    80002806:	ec06                	sd	ra,24(sp)
    80002808:	e822                	sd	s0,16(sp)
    8000280a:	e426                	sd	s1,8(sp)
    8000280c:	e04a                	sd	s2,0(sp)
    8000280e:	1000                	addi	s0,sp,32
    80002810:	84aa                	mv	s1,a0
    80002812:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002814:	934ff0ef          	jal	80001948 <myproc>
  if (addr >= p->sz ||
    80002818:	652c                	ld	a1,72(a0)
    8000281a:	02b4f663          	bgeu	s1,a1,80002846 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000281e:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002822:	02f5e463          	bltu	a1,a5,8000284a <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    80002826:	4721                	li	a4,8
    80002828:	86a6                	mv	a3,s1
    8000282a:	864a                	mv	a2,s2
    8000282c:	6928                	ld	a0,80(a0)
    8000282e:	e1bfe0ef          	jal	80001648 <copyin>
    80002832:	00a03533          	snez	a0,a0
    80002836:	40a0053b          	negw	a0,a0
}
    8000283a:	60e2                	ld	ra,24(sp)
    8000283c:	6442                	ld	s0,16(sp)
    8000283e:	64a2                	ld	s1,8(sp)
    80002840:	6902                	ld	s2,0(sp)
    80002842:	6105                	addi	sp,sp,32
    80002844:	8082                	ret
    return -1;
    80002846:	557d                	li	a0,-1
    80002848:	bfcd                	j	8000283a <fetchaddr+0x36>
    8000284a:	557d                	li	a0,-1
    8000284c:	b7fd                	j	8000283a <fetchaddr+0x36>

000000008000284e <fetchstr>:
{
    8000284e:	7179                	addi	sp,sp,-48
    80002850:	f406                	sd	ra,40(sp)
    80002852:	f022                	sd	s0,32(sp)
    80002854:	ec26                	sd	s1,24(sp)
    80002856:	e84a                	sd	s2,16(sp)
    80002858:	e44e                	sd	s3,8(sp)
    8000285a:	1800                	addi	s0,sp,48
    8000285c:	89aa                	mv	s3,a0
    8000285e:	84ae                	mv	s1,a1
    80002860:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002862:	8e6ff0ef          	jal	80001948 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002866:	874a                	mv	a4,s2
    80002868:	86ce                	mv	a3,s3
    8000286a:	8626                	mv	a2,s1
    8000286c:	652c                	ld	a1,72(a0)
    8000286e:	6928                	ld	a0,80(a0)
    80002870:	e75fe0ef          	jal	800016e4 <copyinstr>
    80002874:	00054c63          	bltz	a0,8000288c <fetchstr+0x3e>
  return strlen(buf);
    80002878:	8526                	mv	a0,s1
    8000287a:	df8fe0ef          	jal	80000e72 <strlen>
}
    8000287e:	70a2                	ld	ra,40(sp)
    80002880:	7402                	ld	s0,32(sp)
    80002882:	64e2                	ld	s1,24(sp)
    80002884:	6942                	ld	s2,16(sp)
    80002886:	69a2                	ld	s3,8(sp)
    80002888:	6145                	addi	sp,sp,48
    8000288a:	8082                	ret
    return -1;
    8000288c:	557d                	li	a0,-1
    8000288e:	bfc5                	j	8000287e <fetchstr+0x30>

0000000080002890 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002890:	1101                	addi	sp,sp,-32
    80002892:	ec06                	sd	ra,24(sp)
    80002894:	e822                	sd	s0,16(sp)
    80002896:	e426                	sd	s1,8(sp)
    80002898:	1000                	addi	s0,sp,32
    8000289a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000289c:	f09ff0ef          	jal	800027a4 <argraw>
    800028a0:	c088                	sw	a0,0(s1)
}
    800028a2:	60e2                	ld	ra,24(sp)
    800028a4:	6442                	ld	s0,16(sp)
    800028a6:	64a2                	ld	s1,8(sp)
    800028a8:	6105                	addi	sp,sp,32
    800028aa:	8082                	ret

00000000800028ac <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800028ac:	1101                	addi	sp,sp,-32
    800028ae:	ec06                	sd	ra,24(sp)
    800028b0:	e822                	sd	s0,16(sp)
    800028b2:	e426                	sd	s1,8(sp)
    800028b4:	1000                	addi	s0,sp,32
    800028b6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028b8:	eedff0ef          	jal	800027a4 <argraw>
    800028bc:	e088                	sd	a0,0(s1)
}
    800028be:	60e2                	ld	ra,24(sp)
    800028c0:	6442                	ld	s0,16(sp)
    800028c2:	64a2                	ld	s1,8(sp)
    800028c4:	6105                	addi	sp,sp,32
    800028c6:	8082                	ret

00000000800028c8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028c8:	1101                	addi	sp,sp,-32
    800028ca:	ec06                	sd	ra,24(sp)
    800028cc:	e822                	sd	s0,16(sp)
    800028ce:	e426                	sd	s1,8(sp)
    800028d0:	e04a                	sd	s2,0(sp)
    800028d2:	1000                	addi	s0,sp,32
    800028d4:	892e                	mv	s2,a1
    800028d6:	84b2                	mv	s1,a2
  *ip = argraw(n);
    800028d8:	ecdff0ef          	jal	800027a4 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800028dc:	8626                	mv	a2,s1
    800028de:	85ca                	mv	a1,s2
    800028e0:	f6fff0ef          	jal	8000284e <fetchstr>
}
    800028e4:	60e2                	ld	ra,24(sp)
    800028e6:	6442                	ld	s0,16(sp)
    800028e8:	64a2                	ld	s1,8(sp)
    800028ea:	6902                	ld	s2,0(sp)
    800028ec:	6105                	addi	sp,sp,32
    800028ee:	8082                	ret

00000000800028f0 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    800028f0:	1101                	addi	sp,sp,-32
    800028f2:	ec06                	sd	ra,24(sp)
    800028f4:	e822                	sd	s0,16(sp)
    800028f6:	e426                	sd	s1,8(sp)
    800028f8:	e04a                	sd	s2,0(sp)
    800028fa:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800028fc:	84cff0ef          	jal	80001948 <myproc>
    80002900:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002902:	05853903          	ld	s2,88(a0)
    80002906:	0a893783          	ld	a5,168(s2)
    8000290a:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000290e:	37fd                	addiw	a5,a5,-1
    80002910:	4755                	li	a4,21
    80002912:	00f76f63          	bltu	a4,a5,80002930 <syscall+0x40>
    80002916:	00369713          	slli	a4,a3,0x3
    8000291a:	00005797          	auipc	a5,0x5
    8000291e:	e7678793          	addi	a5,a5,-394 # 80007790 <syscalls>
    80002922:	97ba                	add	a5,a5,a4
    80002924:	639c                	ld	a5,0(a5)
    80002926:	c789                	beqz	a5,80002930 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002928:	9782                	jalr	a5
    8000292a:	06a93823          	sd	a0,112(s2)
    8000292e:	a829                	j	80002948 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002930:	15848613          	addi	a2,s1,344
    80002934:	588c                	lw	a1,48(s1)
    80002936:	00005517          	auipc	a0,0x5
    8000293a:	a5a50513          	addi	a0,a0,-1446 # 80007390 <etext+0x390>
    8000293e:	bcdfd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002942:	6cbc                	ld	a5,88(s1)
    80002944:	577d                	li	a4,-1
    80002946:	fbb8                	sd	a4,112(a5)
  }
}
    80002948:	60e2                	ld	ra,24(sp)
    8000294a:	6442                	ld	s0,16(sp)
    8000294c:	64a2                	ld	s1,8(sp)
    8000294e:	6902                	ld	s2,0(sp)
    80002950:	6105                	addi	sp,sp,32
    80002952:	8082                	ret

0000000080002954 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002954:	1101                	addi	sp,sp,-32
    80002956:	ec06                	sd	ra,24(sp)
    80002958:	e822                	sd	s0,16(sp)
    8000295a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000295c:	fec40593          	addi	a1,s0,-20
    80002960:	4501                	li	a0,0
    80002962:	f2fff0ef          	jal	80002890 <argint>
  kexit(n);
    80002966:	fec42503          	lw	a0,-20(s0)
    8000296a:	f10ff0ef          	jal	8000207a <kexit>
  return 0; // not reached
}
    8000296e:	4501                	li	a0,0
    80002970:	60e2                	ld	ra,24(sp)
    80002972:	6442                	ld	s0,16(sp)
    80002974:	6105                	addi	sp,sp,32
    80002976:	8082                	ret

0000000080002978 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002978:	1141                	addi	sp,sp,-16
    8000297a:	e406                	sd	ra,8(sp)
    8000297c:	e022                	sd	s0,0(sp)
    8000297e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002980:	fc9fe0ef          	jal	80001948 <myproc>
}
    80002984:	5908                	lw	a0,48(a0)
    80002986:	60a2                	ld	ra,8(sp)
    80002988:	6402                	ld	s0,0(sp)
    8000298a:	0141                	addi	sp,sp,16
    8000298c:	8082                	ret

000000008000298e <sys_fork>:

uint64
sys_fork(void)
{
    8000298e:	1141                	addi	sp,sp,-16
    80002990:	e406                	sd	ra,8(sp)
    80002992:	e022                	sd	s0,0(sp)
    80002994:	0800                	addi	s0,sp,16
  return kfork();
    80002996:	b12ff0ef          	jal	80001ca8 <kfork>
}
    8000299a:	60a2                	ld	ra,8(sp)
    8000299c:	6402                	ld	s0,0(sp)
    8000299e:	0141                	addi	sp,sp,16
    800029a0:	8082                	ret

00000000800029a2 <sys_wait>:

uint64
sys_wait(void)
{
    800029a2:	1101                	addi	sp,sp,-32
    800029a4:	ec06                	sd	ra,24(sp)
    800029a6:	e822                	sd	s0,16(sp)
    800029a8:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029aa:	fe840593          	addi	a1,s0,-24
    800029ae:	4501                	li	a0,0
    800029b0:	efdff0ef          	jal	800028ac <argaddr>
  return kwait(p);
    800029b4:	fe843503          	ld	a0,-24(s0)
    800029b8:	823ff0ef          	jal	800021da <kwait>
}
    800029bc:	60e2                	ld	ra,24(sp)
    800029be:	6442                	ld	s0,16(sp)
    800029c0:	6105                	addi	sp,sp,32
    800029c2:	8082                	ret

00000000800029c4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029c4:	7179                	addi	sp,sp,-48
    800029c6:	f406                	sd	ra,40(sp)
    800029c8:	f022                	sd	s0,32(sp)
    800029ca:	ec26                	sd	s1,24(sp)
    800029cc:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800029ce:	fd840593          	addi	a1,s0,-40
    800029d2:	4501                	li	a0,0
    800029d4:	ebdff0ef          	jal	80002890 <argint>
  argint(1, &t);
    800029d8:	fdc40593          	addi	a1,s0,-36
    800029dc:	4505                	li	a0,1
    800029de:	eb3ff0ef          	jal	80002890 <argint>
  addr = myproc()->sz;
    800029e2:	f67fe0ef          	jal	80001948 <myproc>
    800029e6:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    800029e8:	fdc42703          	lw	a4,-36(s0)
    800029ec:	4785                	li	a5,1
    800029ee:	02f70763          	beq	a4,a5,80002a1c <sys_sbrk+0x58>
    800029f2:	fd842783          	lw	a5,-40(s0)
    800029f6:	0207c363          	bltz	a5,80002a1c <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    800029fa:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    800029fc:	02000737          	lui	a4,0x2000
    80002a00:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002a02:	0736                	slli	a4,a4,0xd
    80002a04:	02f76a63          	bltu	a4,a5,80002a38 <sys_sbrk+0x74>
    80002a08:	0297e863          	bltu	a5,s1,80002a38 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002a0c:	f3dfe0ef          	jal	80001948 <myproc>
    80002a10:	fd842703          	lw	a4,-40(s0)
    80002a14:	653c                	ld	a5,72(a0)
    80002a16:	97ba                	add	a5,a5,a4
    80002a18:	e53c                	sd	a5,72(a0)
    80002a1a:	a039                	j	80002a28 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002a1c:	fd842503          	lw	a0,-40(s0)
    80002a20:	a26ff0ef          	jal	80001c46 <growproc>
    80002a24:	00054863          	bltz	a0,80002a34 <sys_sbrk+0x70>
  }
  return addr;
}
    80002a28:	8526                	mv	a0,s1
    80002a2a:	70a2                	ld	ra,40(sp)
    80002a2c:	7402                	ld	s0,32(sp)
    80002a2e:	64e2                	ld	s1,24(sp)
    80002a30:	6145                	addi	sp,sp,48
    80002a32:	8082                	ret
      return -1;
    80002a34:	54fd                	li	s1,-1
    80002a36:	bfcd                	j	80002a28 <sys_sbrk+0x64>
      return -1;
    80002a38:	54fd                	li	s1,-1
    80002a3a:	b7fd                	j	80002a28 <sys_sbrk+0x64>

0000000080002a3c <sys_pause>:

uint64
sys_pause(void)
{
    80002a3c:	7139                	addi	sp,sp,-64
    80002a3e:	fc06                	sd	ra,56(sp)
    80002a40:	f822                	sd	s0,48(sp)
    80002a42:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a44:	fcc40593          	addi	a1,s0,-52
    80002a48:	4501                	li	a0,0
    80002a4a:	e47ff0ef          	jal	80002890 <argint>
  if (n < 0)
    80002a4e:	fcc42783          	lw	a5,-52(s0)
    80002a52:	0807c063          	bltz	a5,80002ad2 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002a56:	00015517          	auipc	a0,0x15
    80002a5a:	7d250513          	addi	a0,a0,2002 # 80018228 <tickslock>
    80002a5e:	9cafe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002a62:	fcc42783          	lw	a5,-52(s0)
    80002a66:	cbb9                	beqz	a5,80002abc <sys_pause+0x80>
    80002a68:	f426                	sd	s1,40(sp)
    80002a6a:	f04a                	sd	s2,32(sp)
    80002a6c:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002a6e:	00008997          	auipc	s3,0x8
    80002a72:	88a9a983          	lw	s3,-1910(s3) # 8000a2f8 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002a76:	00008917          	auipc	s2,0x8
    80002a7a:	88290913          	addi	s2,s2,-1918 # 8000a2f8 <ticks>
    release(&tickslock);
    80002a7e:	00015497          	auipc	s1,0x15
    80002a82:	7aa48493          	addi	s1,s1,1962 # 80018228 <tickslock>
    if (killed(myproc())) {
    80002a86:	ec3fe0ef          	jal	80001948 <myproc>
    80002a8a:	f26ff0ef          	jal	800021b0 <killed>
    80002a8e:	e529                	bnez	a0,80002ad8 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002a90:	854a                	mv	a0,s2
    80002a92:	cc0ff0ef          	jal	80001f52 <sleep_prepare>
    release(&tickslock);
    80002a96:	8526                	mv	a0,s1
    80002a98:	a18fe0ef          	jal	80000cb0 <release>
    sleep();
    80002a9c:	cf2ff0ef          	jal	80001f8e <sleep>
    acquire(&tickslock);
    80002aa0:	8526                	mv	a0,s1
    80002aa2:	986fe0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002aa6:	00092783          	lw	a5,0(s2)
    80002aaa:	413787bb          	subw	a5,a5,s3
    80002aae:	fcc42703          	lw	a4,-52(s0)
    80002ab2:	fce7eae3          	bltu	a5,a4,80002a86 <sys_pause+0x4a>
    80002ab6:	74a2                	ld	s1,40(sp)
    80002ab8:	7902                	ld	s2,32(sp)
    80002aba:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002abc:	00015517          	auipc	a0,0x15
    80002ac0:	76c50513          	addi	a0,a0,1900 # 80018228 <tickslock>
    80002ac4:	9ecfe0ef          	jal	80000cb0 <release>
  return 0;
    80002ac8:	4501                	li	a0,0
}
    80002aca:	70e2                	ld	ra,56(sp)
    80002acc:	7442                	ld	s0,48(sp)
    80002ace:	6121                	addi	sp,sp,64
    80002ad0:	8082                	ret
    n = 0;
    80002ad2:	fc042623          	sw	zero,-52(s0)
    80002ad6:	b741                	j	80002a56 <sys_pause+0x1a>
      release(&tickslock);
    80002ad8:	00015517          	auipc	a0,0x15
    80002adc:	75050513          	addi	a0,a0,1872 # 80018228 <tickslock>
    80002ae0:	9d0fe0ef          	jal	80000cb0 <release>
      return -1;
    80002ae4:	557d                	li	a0,-1
    80002ae6:	74a2                	ld	s1,40(sp)
    80002ae8:	7902                	ld	s2,32(sp)
    80002aea:	69e2                	ld	s3,24(sp)
    80002aec:	bff9                	j	80002aca <sys_pause+0x8e>

0000000080002aee <sys_kill>:

uint64
sys_kill(void)
{
    80002aee:	1101                	addi	sp,sp,-32
    80002af0:	ec06                	sd	ra,24(sp)
    80002af2:	e822                	sd	s0,16(sp)
    80002af4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002af6:	fec40593          	addi	a1,s0,-20
    80002afa:	4501                	li	a0,0
    80002afc:	d95ff0ef          	jal	80002890 <argint>
  return kkill(pid);
    80002b00:	fec42503          	lw	a0,-20(s0)
    80002b04:	e1cff0ef          	jal	80002120 <kkill>
}
    80002b08:	60e2                	ld	ra,24(sp)
    80002b0a:	6442                	ld	s0,16(sp)
    80002b0c:	6105                	addi	sp,sp,32
    80002b0e:	8082                	ret

0000000080002b10 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b10:	1101                	addi	sp,sp,-32
    80002b12:	ec06                	sd	ra,24(sp)
    80002b14:	e822                	sd	s0,16(sp)
    80002b16:	e426                	sd	s1,8(sp)
    80002b18:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b1a:	00015517          	auipc	a0,0x15
    80002b1e:	70e50513          	addi	a0,a0,1806 # 80018228 <tickslock>
    80002b22:	906fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002b26:	00007797          	auipc	a5,0x7
    80002b2a:	7d27a783          	lw	a5,2002(a5) # 8000a2f8 <ticks>
    80002b2e:	84be                	mv	s1,a5
  release(&tickslock);
    80002b30:	00015517          	auipc	a0,0x15
    80002b34:	6f850513          	addi	a0,a0,1784 # 80018228 <tickslock>
    80002b38:	978fe0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002b3c:	02049513          	slli	a0,s1,0x20
    80002b40:	9101                	srli	a0,a0,0x20
    80002b42:	60e2                	ld	ra,24(sp)
    80002b44:	6442                	ld	s0,16(sp)
    80002b46:	64a2                	ld	s1,8(sp)
    80002b48:	6105                	addi	sp,sp,32
    80002b4a:	8082                	ret

0000000080002b4c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b4c:	7179                	addi	sp,sp,-48
    80002b4e:	f406                	sd	ra,40(sp)
    80002b50:	f022                	sd	s0,32(sp)
    80002b52:	ec26                	sd	s1,24(sp)
    80002b54:	e84a                	sd	s2,16(sp)
    80002b56:	e44e                	sd	s3,8(sp)
    80002b58:	e052                	sd	s4,0(sp)
    80002b5a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b5c:	00005597          	auipc	a1,0x5
    80002b60:	85458593          	addi	a1,a1,-1964 # 800073b0 <etext+0x3b0>
    80002b64:	00015517          	auipc	a0,0x15
    80002b68:	6dc50513          	addi	a0,a0,1756 # 80018240 <bcache>
    80002b6c:	83cfe0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b70:	0001d797          	auipc	a5,0x1d
    80002b74:	6d078793          	addi	a5,a5,1744 # 80020240 <bcache+0x8000>
    80002b78:	0001e717          	auipc	a4,0x1e
    80002b7c:	93070713          	addi	a4,a4,-1744 # 800204a8 <bcache+0x8268>
    80002b80:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b84:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002b88:	00015497          	auipc	s1,0x15
    80002b8c:	6d048493          	addi	s1,s1,1744 # 80018258 <bcache+0x18>
    b->next = bcache.head.next;
    80002b90:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b92:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b94:	00005a17          	auipc	s4,0x5
    80002b98:	824a0a13          	addi	s4,s4,-2012 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002b9c:	2b893783          	ld	a5,696(s2)
    80002ba0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ba2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ba6:	85d2                	mv	a1,s4
    80002ba8:	01048513          	addi	a0,s1,16
    80002bac:	41c010ef          	jal	80003fc8 <initsleeplock>
    bcache.head.next->prev = b;
    80002bb0:	2b893783          	ld	a5,696(s2)
    80002bb4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002bb6:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002bba:	45848493          	addi	s1,s1,1112
    80002bbe:	fd349fe3          	bne	s1,s3,80002b9c <binit+0x50>
  }
}
    80002bc2:	70a2                	ld	ra,40(sp)
    80002bc4:	7402                	ld	s0,32(sp)
    80002bc6:	64e2                	ld	s1,24(sp)
    80002bc8:	6942                	ld	s2,16(sp)
    80002bca:	69a2                	ld	s3,8(sp)
    80002bcc:	6a02                	ld	s4,0(sp)
    80002bce:	6145                	addi	sp,sp,48
    80002bd0:	8082                	ret

0000000080002bd2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002bd2:	7179                	addi	sp,sp,-48
    80002bd4:	f406                	sd	ra,40(sp)
    80002bd6:	f022                	sd	s0,32(sp)
    80002bd8:	ec26                	sd	s1,24(sp)
    80002bda:	e84a                	sd	s2,16(sp)
    80002bdc:	e44e                	sd	s3,8(sp)
    80002bde:	1800                	addi	s0,sp,48
    80002be0:	892a                	mv	s2,a0
    80002be2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002be4:	00015517          	auipc	a0,0x15
    80002be8:	65c50513          	addi	a0,a0,1628 # 80018240 <bcache>
    80002bec:	83cfe0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002bf0:	0001e497          	auipc	s1,0x1e
    80002bf4:	9084b483          	ld	s1,-1784(s1) # 800204f8 <bcache+0x82b8>
    80002bf8:	0001e797          	auipc	a5,0x1e
    80002bfc:	8b078793          	addi	a5,a5,-1872 # 800204a8 <bcache+0x8268>
    80002c00:	02f48b63          	beq	s1,a5,80002c36 <bread+0x64>
    80002c04:	873e                	mv	a4,a5
    80002c06:	a021                	j	80002c0e <bread+0x3c>
    80002c08:	68a4                	ld	s1,80(s1)
    80002c0a:	02e48663          	beq	s1,a4,80002c36 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002c0e:	449c                	lw	a5,8(s1)
    80002c10:	ff279ce3          	bne	a5,s2,80002c08 <bread+0x36>
    80002c14:	44dc                	lw	a5,12(s1)
    80002c16:	ff3799e3          	bne	a5,s3,80002c08 <bread+0x36>
      b->refcnt++;
    80002c1a:	40bc                	lw	a5,64(s1)
    80002c1c:	2785                	addiw	a5,a5,1
    80002c1e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c20:	00015517          	auipc	a0,0x15
    80002c24:	62050513          	addi	a0,a0,1568 # 80018240 <bcache>
    80002c28:	888fe0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002c2c:	01048513          	addi	a0,s1,16
    80002c30:	3ce010ef          	jal	80003ffe <acquiresleep>
      return b;
    80002c34:	a889                	j	80002c86 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002c36:	0001e497          	auipc	s1,0x1e
    80002c3a:	8ba4b483          	ld	s1,-1862(s1) # 800204f0 <bcache+0x82b0>
    80002c3e:	0001e797          	auipc	a5,0x1e
    80002c42:	86a78793          	addi	a5,a5,-1942 # 800204a8 <bcache+0x8268>
    80002c46:	00f48863          	beq	s1,a5,80002c56 <bread+0x84>
    80002c4a:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002c4c:	40bc                	lw	a5,64(s1)
    80002c4e:	cb91                	beqz	a5,80002c62 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002c50:	64a4                	ld	s1,72(s1)
    80002c52:	fee49de3          	bne	s1,a4,80002c4c <bread+0x7a>
  panic("bget: no buffers");
    80002c56:	00004517          	auipc	a0,0x4
    80002c5a:	76a50513          	addi	a0,a0,1898 # 800073c0 <etext+0x3c0>
    80002c5e:	bd7fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002c62:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c66:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c6a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c6e:	4785                	li	a5,1
    80002c70:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c72:	00015517          	auipc	a0,0x15
    80002c76:	5ce50513          	addi	a0,a0,1486 # 80018240 <bcache>
    80002c7a:	836fe0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002c7e:	01048513          	addi	a0,s1,16
    80002c82:	37c010ef          	jal	80003ffe <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002c86:	409c                	lw	a5,0(s1)
    80002c88:	cb89                	beqz	a5,80002c9a <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c8a:	8526                	mv	a0,s1
    80002c8c:	70a2                	ld	ra,40(sp)
    80002c8e:	7402                	ld	s0,32(sp)
    80002c90:	64e2                	ld	s1,24(sp)
    80002c92:	6942                	ld	s2,16(sp)
    80002c94:	69a2                	ld	s3,8(sp)
    80002c96:	6145                	addi	sp,sp,48
    80002c98:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c9a:	4581                	li	a1,0
    80002c9c:	8526                	mv	a0,s1
    80002c9e:	4b9020ef          	jal	80005956 <virtio_disk_rw>
    b->valid = 1;
    80002ca2:	4785                	li	a5,1
    80002ca4:	c09c                	sw	a5,0(s1)
  return b;
    80002ca6:	b7d5                	j	80002c8a <bread+0xb8>

0000000080002ca8 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002ca8:	1101                	addi	sp,sp,-32
    80002caa:	ec06                	sd	ra,24(sp)
    80002cac:	e822                	sd	s0,16(sp)
    80002cae:	e426                	sd	s1,8(sp)
    80002cb0:	1000                	addi	s0,sp,32
    80002cb2:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002cb4:	0541                	addi	a0,a0,16
    80002cb6:	3d4010ef          	jal	8000408a <holdingsleep>
    80002cba:	c911                	beqz	a0,80002cce <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002cbc:	4585                	li	a1,1
    80002cbe:	8526                	mv	a0,s1
    80002cc0:	497020ef          	jal	80005956 <virtio_disk_rw>
}
    80002cc4:	60e2                	ld	ra,24(sp)
    80002cc6:	6442                	ld	s0,16(sp)
    80002cc8:	64a2                	ld	s1,8(sp)
    80002cca:	6105                	addi	sp,sp,32
    80002ccc:	8082                	ret
    panic("bwrite");
    80002cce:	00004517          	auipc	a0,0x4
    80002cd2:	70a50513          	addi	a0,a0,1802 # 800073d8 <etext+0x3d8>
    80002cd6:	b5ffd0ef          	jal	80000834 <panic>

0000000080002cda <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002cda:	1101                	addi	sp,sp,-32
    80002cdc:	ec06                	sd	ra,24(sp)
    80002cde:	e822                	sd	s0,16(sp)
    80002ce0:	e426                	sd	s1,8(sp)
    80002ce2:	e04a                	sd	s2,0(sp)
    80002ce4:	1000                	addi	s0,sp,32
    80002ce6:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002ce8:	01050913          	addi	s2,a0,16
    80002cec:	854a                	mv	a0,s2
    80002cee:	39c010ef          	jal	8000408a <holdingsleep>
    80002cf2:	c125                	beqz	a0,80002d52 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002cf4:	854a                	mv	a0,s2
    80002cf6:	35c010ef          	jal	80004052 <releasesleep>

  acquire(&bcache.lock);
    80002cfa:	00015517          	auipc	a0,0x15
    80002cfe:	54650513          	addi	a0,a0,1350 # 80018240 <bcache>
    80002d02:	f27fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002d06:	40bc                	lw	a5,64(s1)
    80002d08:	37fd                	addiw	a5,a5,-1
    80002d0a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d0c:	e79d                	bnez	a5,80002d3a <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d0e:	68b8                	ld	a4,80(s1)
    80002d10:	64bc                	ld	a5,72(s1)
    80002d12:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d14:	68b8                	ld	a4,80(s1)
    80002d16:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d18:	0001d797          	auipc	a5,0x1d
    80002d1c:	52878793          	addi	a5,a5,1320 # 80020240 <bcache+0x8000>
    80002d20:	2b87b703          	ld	a4,696(a5)
    80002d24:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d26:	0001d717          	auipc	a4,0x1d
    80002d2a:	78270713          	addi	a4,a4,1922 # 800204a8 <bcache+0x8268>
    80002d2e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d30:	2b87b703          	ld	a4,696(a5)
    80002d34:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d36:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002d3a:	00015517          	auipc	a0,0x15
    80002d3e:	50650513          	addi	a0,a0,1286 # 80018240 <bcache>
    80002d42:	f6ffd0ef          	jal	80000cb0 <release>
}
    80002d46:	60e2                	ld	ra,24(sp)
    80002d48:	6442                	ld	s0,16(sp)
    80002d4a:	64a2                	ld	s1,8(sp)
    80002d4c:	6902                	ld	s2,0(sp)
    80002d4e:	6105                	addi	sp,sp,32
    80002d50:	8082                	ret
    panic("brelse");
    80002d52:	00004517          	auipc	a0,0x4
    80002d56:	68e50513          	addi	a0,a0,1678 # 800073e0 <etext+0x3e0>
    80002d5a:	adbfd0ef          	jal	80000834 <panic>

0000000080002d5e <bpin>:

void
bpin(struct buf *b)
{
    80002d5e:	1101                	addi	sp,sp,-32
    80002d60:	ec06                	sd	ra,24(sp)
    80002d62:	e822                	sd	s0,16(sp)
    80002d64:	e426                	sd	s1,8(sp)
    80002d66:	1000                	addi	s0,sp,32
    80002d68:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d6a:	00015517          	auipc	a0,0x15
    80002d6e:	4d650513          	addi	a0,a0,1238 # 80018240 <bcache>
    80002d72:	eb7fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002d76:	40bc                	lw	a5,64(s1)
    80002d78:	2785                	addiw	a5,a5,1
    80002d7a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d7c:	00015517          	auipc	a0,0x15
    80002d80:	4c450513          	addi	a0,a0,1220 # 80018240 <bcache>
    80002d84:	f2dfd0ef          	jal	80000cb0 <release>
}
    80002d88:	60e2                	ld	ra,24(sp)
    80002d8a:	6442                	ld	s0,16(sp)
    80002d8c:	64a2                	ld	s1,8(sp)
    80002d8e:	6105                	addi	sp,sp,32
    80002d90:	8082                	ret

0000000080002d92 <bunpin>:

void
bunpin(struct buf *b)
{
    80002d92:	1101                	addi	sp,sp,-32
    80002d94:	ec06                	sd	ra,24(sp)
    80002d96:	e822                	sd	s0,16(sp)
    80002d98:	e426                	sd	s1,8(sp)
    80002d9a:	1000                	addi	s0,sp,32
    80002d9c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d9e:	00015517          	auipc	a0,0x15
    80002da2:	4a250513          	addi	a0,a0,1186 # 80018240 <bcache>
    80002da6:	e83fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002daa:	40bc                	lw	a5,64(s1)
    80002dac:	37fd                	addiw	a5,a5,-1
    80002dae:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002db0:	00015517          	auipc	a0,0x15
    80002db4:	49050513          	addi	a0,a0,1168 # 80018240 <bcache>
    80002db8:	ef9fd0ef          	jal	80000cb0 <release>
}
    80002dbc:	60e2                	ld	ra,24(sp)
    80002dbe:	6442                	ld	s0,16(sp)
    80002dc0:	64a2                	ld	s1,8(sp)
    80002dc2:	6105                	addi	sp,sp,32
    80002dc4:	8082                	ret

0000000080002dc6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002dc6:	1101                	addi	sp,sp,-32
    80002dc8:	ec06                	sd	ra,24(sp)
    80002dca:	e822                	sd	s0,16(sp)
    80002dcc:	e426                	sd	s1,8(sp)
    80002dce:	e04a                	sd	s2,0(sp)
    80002dd0:	1000                	addi	s0,sp,32
    80002dd2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002dd4:	00d5d79b          	srliw	a5,a1,0xd
    80002dd8:	0001e597          	auipc	a1,0x1e
    80002ddc:	b445a583          	lw	a1,-1212(a1) # 8002091c <sb+0x1c>
    80002de0:	9dbd                	addw	a1,a1,a5
    80002de2:	df1ff0ef          	jal	80002bd2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002de6:	0074f713          	andi	a4,s1,7
    80002dea:	4785                	li	a5,1
    80002dec:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002df0:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002df2:	90d9                	srli	s1,s1,0x36
    80002df4:	00950733          	add	a4,a0,s1
    80002df8:	05874703          	lbu	a4,88(a4)
    80002dfc:	00e7f6b3          	and	a3,a5,a4
    80002e00:	c29d                	beqz	a3,80002e26 <bfree+0x60>
    80002e02:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002e04:	94aa                	add	s1,s1,a0
    80002e06:	fff7c793          	not	a5,a5
    80002e0a:	8f7d                	and	a4,a4,a5
    80002e0c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e10:	080010ef          	jal	80003e90 <log_write>
  brelse(bp);
    80002e14:	854a                	mv	a0,s2
    80002e16:	ec5ff0ef          	jal	80002cda <brelse>
}
    80002e1a:	60e2                	ld	ra,24(sp)
    80002e1c:	6442                	ld	s0,16(sp)
    80002e1e:	64a2                	ld	s1,8(sp)
    80002e20:	6902                	ld	s2,0(sp)
    80002e22:	6105                	addi	sp,sp,32
    80002e24:	8082                	ret
    panic("freeing free block");
    80002e26:	00004517          	auipc	a0,0x4
    80002e2a:	5c250513          	addi	a0,a0,1474 # 800073e8 <etext+0x3e8>
    80002e2e:	a07fd0ef          	jal	80000834 <panic>

0000000080002e32 <balloc>:
{
    80002e32:	715d                	addi	sp,sp,-80
    80002e34:	e486                	sd	ra,72(sp)
    80002e36:	e0a2                	sd	s0,64(sp)
    80002e38:	fc26                	sd	s1,56(sp)
    80002e3a:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002e3c:	0001e797          	auipc	a5,0x1e
    80002e40:	ac87a783          	lw	a5,-1336(a5) # 80020904 <sb+0x4>
    80002e44:	0e078263          	beqz	a5,80002f28 <balloc+0xf6>
    80002e48:	f84a                	sd	s2,48(sp)
    80002e4a:	f44e                	sd	s3,40(sp)
    80002e4c:	f052                	sd	s4,32(sp)
    80002e4e:	ec56                	sd	s5,24(sp)
    80002e50:	e85a                	sd	s6,16(sp)
    80002e52:	e45e                	sd	s7,8(sp)
    80002e54:	e062                	sd	s8,0(sp)
    80002e56:	8baa                	mv	s7,a0
    80002e58:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e5a:	0001eb17          	auipc	s6,0x1e
    80002e5e:	aa6b0b13          	addi	s6,s6,-1370 # 80020900 <sb>
      m = 1 << (bi % 8);
    80002e62:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e64:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002e66:	6c09                	lui	s8,0x2
    80002e68:	a09d                	j	80002ece <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002e6a:	97ca                	add	a5,a5,s2
    80002e6c:	8e55                	or	a2,a2,a3
    80002e6e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e72:	854a                	mv	a0,s2
    80002e74:	01c010ef          	jal	80003e90 <log_write>
        brelse(bp);
    80002e78:	854a                	mv	a0,s2
    80002e7a:	e61ff0ef          	jal	80002cda <brelse>
  bp = bread(dev, bno);
    80002e7e:	85a6                	mv	a1,s1
    80002e80:	855e                	mv	a0,s7
    80002e82:	d51ff0ef          	jal	80002bd2 <bread>
    80002e86:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e88:	40000613          	li	a2,1024
    80002e8c:	4581                	li	a1,0
    80002e8e:	05850513          	addi	a0,a0,88
    80002e92:	e57fd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    80002e96:	854a                	mv	a0,s2
    80002e98:	7f9000ef          	jal	80003e90 <log_write>
  brelse(bp);
    80002e9c:	854a                	mv	a0,s2
    80002e9e:	e3dff0ef          	jal	80002cda <brelse>
}
    80002ea2:	7942                	ld	s2,48(sp)
    80002ea4:	79a2                	ld	s3,40(sp)
    80002ea6:	7a02                	ld	s4,32(sp)
    80002ea8:	6ae2                	ld	s5,24(sp)
    80002eaa:	6b42                	ld	s6,16(sp)
    80002eac:	6ba2                	ld	s7,8(sp)
    80002eae:	6c02                	ld	s8,0(sp)
}
    80002eb0:	8526                	mv	a0,s1
    80002eb2:	60a6                	ld	ra,72(sp)
    80002eb4:	6406                	ld	s0,64(sp)
    80002eb6:	74e2                	ld	s1,56(sp)
    80002eb8:	6161                	addi	sp,sp,80
    80002eba:	8082                	ret
    brelse(bp);
    80002ebc:	854a                	mv	a0,s2
    80002ebe:	e1dff0ef          	jal	80002cda <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002ec2:	015c0abb          	addw	s5,s8,s5
    80002ec6:	004b2783          	lw	a5,4(s6)
    80002eca:	04faf863          	bgeu	s5,a5,80002f1a <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002ece:	40dad59b          	sraiw	a1,s5,0xd
    80002ed2:	01cb2783          	lw	a5,28(s6)
    80002ed6:	9dbd                	addw	a1,a1,a5
    80002ed8:	855e                	mv	a0,s7
    80002eda:	cf9ff0ef          	jal	80002bd2 <bread>
    80002ede:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002ee0:	004b2503          	lw	a0,4(s6)
    80002ee4:	84d6                	mv	s1,s5
    80002ee6:	4701                	li	a4,0
    80002ee8:	fca4fae3          	bgeu	s1,a0,80002ebc <balloc+0x8a>
      m = 1 << (bi % 8);
    80002eec:	00777693          	andi	a3,a4,7
    80002ef0:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002ef4:	41f7579b          	sraiw	a5,a4,0x1f
    80002ef8:	01d7d79b          	srliw	a5,a5,0x1d
    80002efc:	9fb9                	addw	a5,a5,a4
    80002efe:	4037d79b          	sraiw	a5,a5,0x3
    80002f02:	00f90633          	add	a2,s2,a5
    80002f06:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80002f0a:	00c6f5b3          	and	a1,a3,a2
    80002f0e:	ddb1                	beqz	a1,80002e6a <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f10:	2705                	addiw	a4,a4,1
    80002f12:	2485                	addiw	s1,s1,1
    80002f14:	fd471ae3          	bne	a4,s4,80002ee8 <balloc+0xb6>
    80002f18:	b755                	j	80002ebc <balloc+0x8a>
    80002f1a:	7942                	ld	s2,48(sp)
    80002f1c:	79a2                	ld	s3,40(sp)
    80002f1e:	7a02                	ld	s4,32(sp)
    80002f20:	6ae2                	ld	s5,24(sp)
    80002f22:	6b42                	ld	s6,16(sp)
    80002f24:	6ba2                	ld	s7,8(sp)
    80002f26:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    80002f28:	00004517          	auipc	a0,0x4
    80002f2c:	4d850513          	addi	a0,a0,1240 # 80007400 <etext+0x400>
    80002f30:	ddafd0ef          	jal	8000050a <printk>
  return 0;
    80002f34:	4481                	li	s1,0
    80002f36:	bfad                	j	80002eb0 <balloc+0x7e>

0000000080002f38 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f38:	7179                	addi	sp,sp,-48
    80002f3a:	f406                	sd	ra,40(sp)
    80002f3c:	f022                	sd	s0,32(sp)
    80002f3e:	ec26                	sd	s1,24(sp)
    80002f40:	e84a                	sd	s2,16(sp)
    80002f42:	e44e                	sd	s3,8(sp)
    80002f44:	1800                	addi	s0,sp,48
    80002f46:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80002f48:	47ad                	li	a5,11
    80002f4a:	02b7e363          	bltu	a5,a1,80002f70 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80002f4e:	02059793          	slli	a5,a1,0x20
    80002f52:	01e7d593          	srli	a1,a5,0x1e
    80002f56:	00b509b3          	add	s3,a0,a1
    80002f5a:	0509a483          	lw	s1,80(s3)
    80002f5e:	e0b5                	bnez	s1,80002fc2 <bmap+0x8a>
      addr = balloc(ip->dev);
    80002f60:	4108                	lw	a0,0(a0)
    80002f62:	ed1ff0ef          	jal	80002e32 <balloc>
    80002f66:	84aa                	mv	s1,a0
      if (addr == 0)
    80002f68:	cd29                	beqz	a0,80002fc2 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80002f6a:	04a9a823          	sw	a0,80(s3)
    80002f6e:	a891                	j	80002fc2 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f70:	ff45879b          	addiw	a5,a1,-12
    80002f74:	873e                	mv	a4,a5
    80002f76:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    80002f78:	0ff00793          	li	a5,255
    80002f7c:	06e7e763          	bltu	a5,a4,80002fea <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80002f80:	08052483          	lw	s1,128(a0)
    80002f84:	e891                	bnez	s1,80002f98 <bmap+0x60>
      addr = balloc(ip->dev);
    80002f86:	4108                	lw	a0,0(a0)
    80002f88:	eabff0ef          	jal	80002e32 <balloc>
    80002f8c:	84aa                	mv	s1,a0
      if (addr == 0)
    80002f8e:	c915                	beqz	a0,80002fc2 <bmap+0x8a>
    80002f90:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f92:	08a92023          	sw	a0,128(s2)
    80002f96:	a011                	j	80002f9a <bmap+0x62>
    80002f98:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f9a:	85a6                	mv	a1,s1
    80002f9c:	00092503          	lw	a0,0(s2)
    80002fa0:	c33ff0ef          	jal	80002bd2 <bread>
    80002fa4:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80002fa6:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80002faa:	02099713          	slli	a4,s3,0x20
    80002fae:	01e75593          	srli	a1,a4,0x1e
    80002fb2:	97ae                	add	a5,a5,a1
    80002fb4:	89be                	mv	s3,a5
    80002fb6:	4384                	lw	s1,0(a5)
    80002fb8:	cc89                	beqz	s1,80002fd2 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002fba:	8552                	mv	a0,s4
    80002fbc:	d1fff0ef          	jal	80002cda <brelse>
    return addr;
    80002fc0:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002fc2:	8526                	mv	a0,s1
    80002fc4:	70a2                	ld	ra,40(sp)
    80002fc6:	7402                	ld	s0,32(sp)
    80002fc8:	64e2                	ld	s1,24(sp)
    80002fca:	6942                	ld	s2,16(sp)
    80002fcc:	69a2                	ld	s3,8(sp)
    80002fce:	6145                	addi	sp,sp,48
    80002fd0:	8082                	ret
      addr = balloc(ip->dev);
    80002fd2:	00092503          	lw	a0,0(s2)
    80002fd6:	e5dff0ef          	jal	80002e32 <balloc>
    80002fda:	84aa                	mv	s1,a0
      if (addr) {
    80002fdc:	dd79                	beqz	a0,80002fba <bmap+0x82>
        a[bn] = addr;
    80002fde:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80002fe2:	8552                	mv	a0,s4
    80002fe4:	6ad000ef          	jal	80003e90 <log_write>
    80002fe8:	bfc9                	j	80002fba <bmap+0x82>
    80002fea:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002fec:	00004517          	auipc	a0,0x4
    80002ff0:	42c50513          	addi	a0,a0,1068 # 80007418 <etext+0x418>
    80002ff4:	841fd0ef          	jal	80000834 <panic>

0000000080002ff8 <iget>:
{
    80002ff8:	7179                	addi	sp,sp,-48
    80002ffa:	f406                	sd	ra,40(sp)
    80002ffc:	f022                	sd	s0,32(sp)
    80002ffe:	ec26                	sd	s1,24(sp)
    80003000:	e84a                	sd	s2,16(sp)
    80003002:	e44e                	sd	s3,8(sp)
    80003004:	e052                	sd	s4,0(sp)
    80003006:	1800                	addi	s0,sp,48
    80003008:	892a                	mv	s2,a0
    8000300a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000300c:	0001e517          	auipc	a0,0x1e
    80003010:	91450513          	addi	a0,a0,-1772 # 80020920 <itable>
    80003014:	c15fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    80003018:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000301a:	0001e497          	auipc	s1,0x1e
    8000301e:	91e48493          	addi	s1,s1,-1762 # 80020938 <itable+0x18>
    80003022:	0001f697          	auipc	a3,0x1f
    80003026:	3a668693          	addi	a3,a3,934 # 800223c8 <log>
    8000302a:	a809                	j	8000303c <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    8000302c:	e781                	bnez	a5,80003034 <iget+0x3c>
    8000302e:	00099363          	bnez	s3,80003034 <iget+0x3c>
      empty = ip;
    80003032:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003034:	08848493          	addi	s1,s1,136
    80003038:	02d48563          	beq	s1,a3,80003062 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    8000303c:	449c                	lw	a5,8(s1)
    8000303e:	fef057e3          	blez	a5,8000302c <iget+0x34>
    80003042:	4098                	lw	a4,0(s1)
    80003044:	ff2718e3          	bne	a4,s2,80003034 <iget+0x3c>
    80003048:	40d8                	lw	a4,4(s1)
    8000304a:	ff4715e3          	bne	a4,s4,80003034 <iget+0x3c>
      ip->ref++;
    8000304e:	2785                	addiw	a5,a5,1
    80003050:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003052:	0001e517          	auipc	a0,0x1e
    80003056:	8ce50513          	addi	a0,a0,-1842 # 80020920 <itable>
    8000305a:	c57fd0ef          	jal	80000cb0 <release>
      return ip;
    8000305e:	89a6                	mv	s3,s1
    80003060:	a015                	j	80003084 <iget+0x8c>
  if (empty == 0)
    80003062:	02098a63          	beqz	s3,80003096 <iget+0x9e>
  ip->dev = dev;
    80003066:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000306a:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    8000306e:	4785                	li	a5,1
    80003070:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003074:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003078:	0001e517          	auipc	a0,0x1e
    8000307c:	8a850513          	addi	a0,a0,-1880 # 80020920 <itable>
    80003080:	c31fd0ef          	jal	80000cb0 <release>
}
    80003084:	854e                	mv	a0,s3
    80003086:	70a2                	ld	ra,40(sp)
    80003088:	7402                	ld	s0,32(sp)
    8000308a:	64e2                	ld	s1,24(sp)
    8000308c:	6942                	ld	s2,16(sp)
    8000308e:	69a2                	ld	s3,8(sp)
    80003090:	6a02                	ld	s4,0(sp)
    80003092:	6145                	addi	sp,sp,48
    80003094:	8082                	ret
    panic("iget: no inodes");
    80003096:	00004517          	auipc	a0,0x4
    8000309a:	39a50513          	addi	a0,a0,922 # 80007430 <etext+0x430>
    8000309e:	f96fd0ef          	jal	80000834 <panic>

00000000800030a2 <iinit>:
{
    800030a2:	7179                	addi	sp,sp,-48
    800030a4:	f406                	sd	ra,40(sp)
    800030a6:	f022                	sd	s0,32(sp)
    800030a8:	ec26                	sd	s1,24(sp)
    800030aa:	e84a                	sd	s2,16(sp)
    800030ac:	e44e                	sd	s3,8(sp)
    800030ae:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800030b0:	00004597          	auipc	a1,0x4
    800030b4:	39058593          	addi	a1,a1,912 # 80007440 <etext+0x440>
    800030b8:	0001e517          	auipc	a0,0x1e
    800030bc:	86850513          	addi	a0,a0,-1944 # 80020920 <itable>
    800030c0:	ae9fd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    800030c4:	0001e497          	auipc	s1,0x1e
    800030c8:	88448493          	addi	s1,s1,-1916 # 80020948 <itable+0x28>
    800030cc:	0001f997          	auipc	s3,0x1f
    800030d0:	30c98993          	addi	s3,s3,780 # 800223d8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800030d4:	00004917          	auipc	s2,0x4
    800030d8:	37490913          	addi	s2,s2,884 # 80007448 <etext+0x448>
    800030dc:	85ca                	mv	a1,s2
    800030de:	8526                	mv	a0,s1
    800030e0:	6e9000ef          	jal	80003fc8 <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    800030e4:	08848493          	addi	s1,s1,136
    800030e8:	ff349ae3          	bne	s1,s3,800030dc <iinit+0x3a>
}
    800030ec:	70a2                	ld	ra,40(sp)
    800030ee:	7402                	ld	s0,32(sp)
    800030f0:	64e2                	ld	s1,24(sp)
    800030f2:	6942                	ld	s2,16(sp)
    800030f4:	69a2                	ld	s3,8(sp)
    800030f6:	6145                	addi	sp,sp,48
    800030f8:	8082                	ret

00000000800030fa <ialloc>:
{
    800030fa:	7139                	addi	sp,sp,-64
    800030fc:	fc06                	sd	ra,56(sp)
    800030fe:	f822                	sd	s0,48(sp)
    80003100:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003102:	0001e717          	auipc	a4,0x1e
    80003106:	80a72703          	lw	a4,-2038(a4) # 8002090c <sb+0xc>
    8000310a:	4785                	li	a5,1
    8000310c:	06e7f063          	bgeu	a5,a4,8000316c <ialloc+0x72>
    80003110:	f426                	sd	s1,40(sp)
    80003112:	f04a                	sd	s2,32(sp)
    80003114:	ec4e                	sd	s3,24(sp)
    80003116:	e852                	sd	s4,16(sp)
    80003118:	e456                	sd	s5,8(sp)
    8000311a:	e05a                	sd	s6,0(sp)
    8000311c:	8aaa                	mv	s5,a0
    8000311e:	8b2e                	mv	s6,a1
    80003120:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003122:	0001da17          	auipc	s4,0x1d
    80003126:	7dea0a13          	addi	s4,s4,2014 # 80020900 <sb>
    8000312a:	00495593          	srli	a1,s2,0x4
    8000312e:	018a2783          	lw	a5,24(s4)
    80003132:	9dbd                	addw	a1,a1,a5
    80003134:	8556                	mv	a0,s5
    80003136:	a9dff0ef          	jal	80002bd2 <bread>
    8000313a:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    8000313c:	05850993          	addi	s3,a0,88
    80003140:	00f97793          	andi	a5,s2,15
    80003144:	079a                	slli	a5,a5,0x6
    80003146:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    80003148:	00099783          	lh	a5,0(s3)
    8000314c:	cb9d                	beqz	a5,80003182 <ialloc+0x88>
    brelse(bp);
    8000314e:	b8dff0ef          	jal	80002cda <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003152:	0905                	addi	s2,s2,1
    80003154:	00ca2703          	lw	a4,12(s4)
    80003158:	0009079b          	sext.w	a5,s2
    8000315c:	fce7e7e3          	bltu	a5,a4,8000312a <ialloc+0x30>
    80003160:	74a2                	ld	s1,40(sp)
    80003162:	7902                	ld	s2,32(sp)
    80003164:	69e2                	ld	s3,24(sp)
    80003166:	6a42                	ld	s4,16(sp)
    80003168:	6aa2                	ld	s5,8(sp)
    8000316a:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    8000316c:	00004517          	auipc	a0,0x4
    80003170:	2e450513          	addi	a0,a0,740 # 80007450 <etext+0x450>
    80003174:	b96fd0ef          	jal	8000050a <printk>
  return 0;
    80003178:	4501                	li	a0,0
}
    8000317a:	70e2                	ld	ra,56(sp)
    8000317c:	7442                	ld	s0,48(sp)
    8000317e:	6121                	addi	sp,sp,64
    80003180:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003182:	04000613          	li	a2,64
    80003186:	4581                	li	a1,0
    80003188:	854e                	mv	a0,s3
    8000318a:	b5ffd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    8000318e:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003192:	8526                	mv	a0,s1
    80003194:	4fd000ef          	jal	80003e90 <log_write>
      brelse(bp);
    80003198:	8526                	mv	a0,s1
    8000319a:	b41ff0ef          	jal	80002cda <brelse>
      return iget(dev, inum);
    8000319e:	0009059b          	sext.w	a1,s2
    800031a2:	8556                	mv	a0,s5
    800031a4:	e55ff0ef          	jal	80002ff8 <iget>
    800031a8:	74a2                	ld	s1,40(sp)
    800031aa:	7902                	ld	s2,32(sp)
    800031ac:	69e2                	ld	s3,24(sp)
    800031ae:	6a42                	ld	s4,16(sp)
    800031b0:	6aa2                	ld	s5,8(sp)
    800031b2:	6b02                	ld	s6,0(sp)
    800031b4:	b7d9                	j	8000317a <ialloc+0x80>

00000000800031b6 <iupdate>:
{
    800031b6:	1101                	addi	sp,sp,-32
    800031b8:	ec06                	sd	ra,24(sp)
    800031ba:	e822                	sd	s0,16(sp)
    800031bc:	e426                	sd	s1,8(sp)
    800031be:	e04a                	sd	s2,0(sp)
    800031c0:	1000                	addi	s0,sp,32
    800031c2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800031c4:	415c                	lw	a5,4(a0)
    800031c6:	0047d79b          	srliw	a5,a5,0x4
    800031ca:	0001d597          	auipc	a1,0x1d
    800031ce:	74e5a583          	lw	a1,1870(a1) # 80020918 <sb+0x18>
    800031d2:	9dbd                	addw	a1,a1,a5
    800031d4:	4108                	lw	a0,0(a0)
    800031d6:	9fdff0ef          	jal	80002bd2 <bread>
    800031da:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    800031dc:	05850793          	addi	a5,a0,88
    800031e0:	40d8                	lw	a4,4(s1)
    800031e2:	8b3d                	andi	a4,a4,15
    800031e4:	071a                	slli	a4,a4,0x6
    800031e6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800031e8:	04449703          	lh	a4,68(s1)
    800031ec:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800031f0:	04649703          	lh	a4,70(s1)
    800031f4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800031f8:	04849703          	lh	a4,72(s1)
    800031fc:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003200:	04a49703          	lh	a4,74(s1)
    80003204:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003208:	44f8                	lw	a4,76(s1)
    8000320a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000320c:	03400613          	li	a2,52
    80003210:	05048593          	addi	a1,s1,80
    80003214:	00c78513          	addi	a0,a5,12
    80003218:	b31fd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    8000321c:	854a                	mv	a0,s2
    8000321e:	473000ef          	jal	80003e90 <log_write>
  brelse(bp);
    80003222:	854a                	mv	a0,s2
    80003224:	ab7ff0ef          	jal	80002cda <brelse>
}
    80003228:	60e2                	ld	ra,24(sp)
    8000322a:	6442                	ld	s0,16(sp)
    8000322c:	64a2                	ld	s1,8(sp)
    8000322e:	6902                	ld	s2,0(sp)
    80003230:	6105                	addi	sp,sp,32
    80003232:	8082                	ret

0000000080003234 <idup>:
{
    80003234:	1101                	addi	sp,sp,-32
    80003236:	ec06                	sd	ra,24(sp)
    80003238:	e822                	sd	s0,16(sp)
    8000323a:	e426                	sd	s1,8(sp)
    8000323c:	1000                	addi	s0,sp,32
    8000323e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003240:	0001d517          	auipc	a0,0x1d
    80003244:	6e050513          	addi	a0,a0,1760 # 80020920 <itable>
    80003248:	9e1fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    8000324c:	449c                	lw	a5,8(s1)
    8000324e:	2785                	addiw	a5,a5,1
    80003250:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003252:	0001d517          	auipc	a0,0x1d
    80003256:	6ce50513          	addi	a0,a0,1742 # 80020920 <itable>
    8000325a:	a57fd0ef          	jal	80000cb0 <release>
}
    8000325e:	8526                	mv	a0,s1
    80003260:	60e2                	ld	ra,24(sp)
    80003262:	6442                	ld	s0,16(sp)
    80003264:	64a2                	ld	s1,8(sp)
    80003266:	6105                	addi	sp,sp,32
    80003268:	8082                	ret

000000008000326a <ilock>:
{
    8000326a:	1101                	addi	sp,sp,-32
    8000326c:	ec06                	sd	ra,24(sp)
    8000326e:	e822                	sd	s0,16(sp)
    80003270:	e426                	sd	s1,8(sp)
    80003272:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003274:	cd19                	beqz	a0,80003292 <ilock+0x28>
    80003276:	84aa                	mv	s1,a0
    80003278:	451c                	lw	a5,8(a0)
    8000327a:	00f05c63          	blez	a5,80003292 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000327e:	0541                	addi	a0,a0,16
    80003280:	57f000ef          	jal	80003ffe <acquiresleep>
  if (ip->valid == 0) {
    80003284:	40bc                	lw	a5,64(s1)
    80003286:	cf89                	beqz	a5,800032a0 <ilock+0x36>
}
    80003288:	60e2                	ld	ra,24(sp)
    8000328a:	6442                	ld	s0,16(sp)
    8000328c:	64a2                	ld	s1,8(sp)
    8000328e:	6105                	addi	sp,sp,32
    80003290:	8082                	ret
    80003292:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003294:	00004517          	auipc	a0,0x4
    80003298:	1d450513          	addi	a0,a0,468 # 80007468 <etext+0x468>
    8000329c:	d98fd0ef          	jal	80000834 <panic>
    800032a0:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032a2:	40dc                	lw	a5,4(s1)
    800032a4:	0047d79b          	srliw	a5,a5,0x4
    800032a8:	0001d597          	auipc	a1,0x1d
    800032ac:	6705a583          	lw	a1,1648(a1) # 80020918 <sb+0x18>
    800032b0:	9dbd                	addw	a1,a1,a5
    800032b2:	4088                	lw	a0,0(s1)
    800032b4:	91fff0ef          	jal	80002bd2 <bread>
    800032b8:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    800032ba:	05850593          	addi	a1,a0,88
    800032be:	40dc                	lw	a5,4(s1)
    800032c0:	8bbd                	andi	a5,a5,15
    800032c2:	079a                	slli	a5,a5,0x6
    800032c4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800032c6:	00059783          	lh	a5,0(a1)
    800032ca:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800032ce:	00259783          	lh	a5,2(a1)
    800032d2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800032d6:	00459783          	lh	a5,4(a1)
    800032da:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800032de:	00659783          	lh	a5,6(a1)
    800032e2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800032e6:	459c                	lw	a5,8(a1)
    800032e8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800032ea:	03400613          	li	a2,52
    800032ee:	05b1                	addi	a1,a1,12
    800032f0:	05048513          	addi	a0,s1,80
    800032f4:	a55fd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    800032f8:	854a                	mv	a0,s2
    800032fa:	9e1ff0ef          	jal	80002cda <brelse>
    ip->valid = 1;
    800032fe:	4785                	li	a5,1
    80003300:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003302:	04449783          	lh	a5,68(s1)
    80003306:	c399                	beqz	a5,8000330c <ilock+0xa2>
    80003308:	6902                	ld	s2,0(sp)
    8000330a:	bfbd                	j	80003288 <ilock+0x1e>
      panic("ilock: no type");
    8000330c:	00004517          	auipc	a0,0x4
    80003310:	16450513          	addi	a0,a0,356 # 80007470 <etext+0x470>
    80003314:	d20fd0ef          	jal	80000834 <panic>

0000000080003318 <iunlock>:
{
    80003318:	1101                	addi	sp,sp,-32
    8000331a:	ec06                	sd	ra,24(sp)
    8000331c:	e822                	sd	s0,16(sp)
    8000331e:	e426                	sd	s1,8(sp)
    80003320:	e04a                	sd	s2,0(sp)
    80003322:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003324:	c505                	beqz	a0,8000334c <iunlock+0x34>
    80003326:	84aa                	mv	s1,a0
    80003328:	01050913          	addi	s2,a0,16
    8000332c:	854a                	mv	a0,s2
    8000332e:	55d000ef          	jal	8000408a <holdingsleep>
    80003332:	cd09                	beqz	a0,8000334c <iunlock+0x34>
    80003334:	449c                	lw	a5,8(s1)
    80003336:	00f05b63          	blez	a5,8000334c <iunlock+0x34>
  releasesleep(&ip->lock);
    8000333a:	854a                	mv	a0,s2
    8000333c:	517000ef          	jal	80004052 <releasesleep>
}
    80003340:	60e2                	ld	ra,24(sp)
    80003342:	6442                	ld	s0,16(sp)
    80003344:	64a2                	ld	s1,8(sp)
    80003346:	6902                	ld	s2,0(sp)
    80003348:	6105                	addi	sp,sp,32
    8000334a:	8082                	ret
    panic("iunlock");
    8000334c:	00004517          	auipc	a0,0x4
    80003350:	13450513          	addi	a0,a0,308 # 80007480 <etext+0x480>
    80003354:	ce0fd0ef          	jal	80000834 <panic>

0000000080003358 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003358:	7179                	addi	sp,sp,-48
    8000335a:	f406                	sd	ra,40(sp)
    8000335c:	f022                	sd	s0,32(sp)
    8000335e:	ec26                	sd	s1,24(sp)
    80003360:	e84a                	sd	s2,16(sp)
    80003362:	e44e                	sd	s3,8(sp)
    80003364:	1800                	addi	s0,sp,48
    80003366:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    80003368:	05050493          	addi	s1,a0,80
    8000336c:	08050913          	addi	s2,a0,128
    80003370:	a021                	j	80003378 <itrunc+0x20>
    80003372:	0491                	addi	s1,s1,4
    80003374:	01248b63          	beq	s1,s2,8000338a <itrunc+0x32>
    if (ip->addrs[i]) {
    80003378:	408c                	lw	a1,0(s1)
    8000337a:	dde5                	beqz	a1,80003372 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000337c:	0009a503          	lw	a0,0(s3)
    80003380:	a47ff0ef          	jal	80002dc6 <bfree>
      ip->addrs[i] = 0;
    80003384:	0004a023          	sw	zero,0(s1)
    80003388:	b7ed                	j	80003372 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    8000338a:	0809a583          	lw	a1,128(s3)
    8000338e:	ed89                	bnez	a1,800033a8 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003390:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003394:	854e                	mv	a0,s3
    80003396:	e21ff0ef          	jal	800031b6 <iupdate>
}
    8000339a:	70a2                	ld	ra,40(sp)
    8000339c:	7402                	ld	s0,32(sp)
    8000339e:	64e2                	ld	s1,24(sp)
    800033a0:	6942                	ld	s2,16(sp)
    800033a2:	69a2                	ld	s3,8(sp)
    800033a4:	6145                	addi	sp,sp,48
    800033a6:	8082                	ret
    800033a8:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800033aa:	0009a503          	lw	a0,0(s3)
    800033ae:	825ff0ef          	jal	80002bd2 <bread>
    800033b2:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    800033b4:	05850493          	addi	s1,a0,88
    800033b8:	45850913          	addi	s2,a0,1112
    800033bc:	a021                	j	800033c4 <itrunc+0x6c>
    800033be:	0491                	addi	s1,s1,4
    800033c0:	01248963          	beq	s1,s2,800033d2 <itrunc+0x7a>
      if (a[j])
    800033c4:	408c                	lw	a1,0(s1)
    800033c6:	dde5                	beqz	a1,800033be <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800033c8:	0009a503          	lw	a0,0(s3)
    800033cc:	9fbff0ef          	jal	80002dc6 <bfree>
    800033d0:	b7fd                	j	800033be <itrunc+0x66>
    brelse(bp);
    800033d2:	8552                	mv	a0,s4
    800033d4:	907ff0ef          	jal	80002cda <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800033d8:	0809a583          	lw	a1,128(s3)
    800033dc:	0009a503          	lw	a0,0(s3)
    800033e0:	9e7ff0ef          	jal	80002dc6 <bfree>
    ip->addrs[NDIRECT] = 0;
    800033e4:	0809a023          	sw	zero,128(s3)
    800033e8:	6a02                	ld	s4,0(sp)
    800033ea:	b75d                	j	80003390 <itrunc+0x38>

00000000800033ec <iput>:
{
    800033ec:	7179                	addi	sp,sp,-48
    800033ee:	f406                	sd	ra,40(sp)
    800033f0:	f022                	sd	s0,32(sp)
    800033f2:	ec26                	sd	s1,24(sp)
    800033f4:	1800                	addi	s0,sp,48
    800033f6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033f8:	0001d517          	auipc	a0,0x1d
    800033fc:	52850513          	addi	a0,a0,1320 # 80020920 <itable>
    80003400:	829fd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003404:	449c                	lw	a5,8(s1)
    80003406:	4705                	li	a4,1
    80003408:	00e78f63          	beq	a5,a4,80003426 <iput+0x3a>
  ip->ref--;
    8000340c:	37fd                	addiw	a5,a5,-1
    8000340e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003410:	0001d517          	auipc	a0,0x1d
    80003414:	51050513          	addi	a0,a0,1296 # 80020920 <itable>
    80003418:	899fd0ef          	jal	80000cb0 <release>
}
    8000341c:	70a2                	ld	ra,40(sp)
    8000341e:	7402                	ld	s0,32(sp)
    80003420:	64e2                	ld	s1,24(sp)
    80003422:	6145                	addi	sp,sp,48
    80003424:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003426:	40b8                	lw	a4,64(s1)
    80003428:	d375                	beqz	a4,8000340c <iput+0x20>
    8000342a:	e84a                	sd	s2,16(sp)
    8000342c:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    8000342e:	0004aa03          	lw	s4,0(s1)
    80003432:	0044a903          	lw	s2,4(s1)
  if (last) {
    80003436:	04a49703          	lh	a4,74(s1)
    8000343a:	ef3d                	bnez	a4,800034b8 <iput+0xcc>
    8000343c:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    8000343e:	01048793          	addi	a5,s1,16
    80003442:	89be                	mv	s3,a5
    80003444:	853e                	mv	a0,a5
    80003446:	3b9000ef          	jal	80003ffe <acquiresleep>
    release(&itable.lock);
    8000344a:	0001d517          	auipc	a0,0x1d
    8000344e:	4d650513          	addi	a0,a0,1238 # 80020920 <itable>
    80003452:	85ffd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    80003456:	8526                	mv	a0,s1
    80003458:	f01ff0ef          	jal	80003358 <itrunc>
    ip->valid = 0;
    8000345c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003460:	854e                	mv	a0,s3
    80003462:	3f1000ef          	jal	80004052 <releasesleep>
    acquire(&itable.lock);
    80003466:	0001d517          	auipc	a0,0x1d
    8000346a:	4ba50513          	addi	a0,a0,1210 # 80020920 <itable>
    8000346e:	fbafd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    80003472:	449c                	lw	a5,8(s1)
    80003474:	37fd                	addiw	a5,a5,-1
    80003476:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003478:	0001d517          	auipc	a0,0x1d
    8000347c:	4a850513          	addi	a0,a0,1192 # 80020920 <itable>
    80003480:	831fd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003484:	0049579b          	srliw	a5,s2,0x4
    80003488:	0001d597          	auipc	a1,0x1d
    8000348c:	4905a583          	lw	a1,1168(a1) # 80020918 <sb+0x18>
    80003490:	9dbd                	addw	a1,a1,a5
    80003492:	8552                	mv	a0,s4
    80003494:	f3eff0ef          	jal	80002bd2 <bread>
    80003498:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000349a:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    8000349e:	079a                	slli	a5,a5,0x6
    800034a0:	97aa                	add	a5,a5,a0
    800034a2:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    800034a6:	1eb000ef          	jal	80003e90 <log_write>
  brelse(bp);
    800034aa:	8526                	mv	a0,s1
    800034ac:	82fff0ef          	jal	80002cda <brelse>
}
    800034b0:	6942                	ld	s2,16(sp)
    800034b2:	69a2                	ld	s3,8(sp)
    800034b4:	6a02                	ld	s4,0(sp)
    800034b6:	b79d                	j	8000341c <iput+0x30>
    800034b8:	6942                	ld	s2,16(sp)
    800034ba:	6a02                	ld	s4,0(sp)
    800034bc:	bf81                	j	8000340c <iput+0x20>

00000000800034be <iunlockput>:
{
    800034be:	1101                	addi	sp,sp,-32
    800034c0:	ec06                	sd	ra,24(sp)
    800034c2:	e822                	sd	s0,16(sp)
    800034c4:	e426                	sd	s1,8(sp)
    800034c6:	1000                	addi	s0,sp,32
    800034c8:	84aa                	mv	s1,a0
  iunlock(ip);
    800034ca:	e4fff0ef          	jal	80003318 <iunlock>
  iput(ip);
    800034ce:	8526                	mv	a0,s1
    800034d0:	f1dff0ef          	jal	800033ec <iput>
}
    800034d4:	60e2                	ld	ra,24(sp)
    800034d6:	6442                	ld	s0,16(sp)
    800034d8:	64a2                	ld	s1,8(sp)
    800034da:	6105                	addi	sp,sp,32
    800034dc:	8082                	ret

00000000800034de <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034de:	0001d717          	auipc	a4,0x1d
    800034e2:	42e72703          	lw	a4,1070(a4) # 8002090c <sb+0xc>
    800034e6:	4785                	li	a5,1
    800034e8:	0ae7fe63          	bgeu	a5,a4,800035a4 <ireclaim+0xc6>
{
    800034ec:	7139                	addi	sp,sp,-64
    800034ee:	fc06                	sd	ra,56(sp)
    800034f0:	f822                	sd	s0,48(sp)
    800034f2:	f426                	sd	s1,40(sp)
    800034f4:	f04a                	sd	s2,32(sp)
    800034f6:	ec4e                	sd	s3,24(sp)
    800034f8:	e852                	sd	s4,16(sp)
    800034fa:	e456                	sd	s5,8(sp)
    800034fc:	e05a                	sd	s6,0(sp)
    800034fe:	0080                	addi	s0,sp,64
    80003500:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003502:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003504:	0001da17          	auipc	s4,0x1d
    80003508:	3fca0a13          	addi	s4,s4,1020 # 80020900 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    8000350c:	00004b17          	auipc	s6,0x4
    80003510:	f7cb0b13          	addi	s6,s6,-132 # 80007488 <etext+0x488>
    80003514:	a099                	j	8000355a <ireclaim+0x7c>
    80003516:	85ce                	mv	a1,s3
    80003518:	855a                	mv	a0,s6
    8000351a:	ff1fc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    8000351e:	85ce                	mv	a1,s3
    80003520:	8556                	mv	a0,s5
    80003522:	ad7ff0ef          	jal	80002ff8 <iget>
    80003526:	89aa                	mv	s3,a0
    brelse(bp);
    80003528:	854a                	mv	a0,s2
    8000352a:	fb0ff0ef          	jal	80002cda <brelse>
    if (ip) {
    8000352e:	00098f63          	beqz	s3,8000354c <ireclaim+0x6e>
      begin_op();
    80003532:	7b0000ef          	jal	80003ce2 <begin_op>
      ilock(ip);
    80003536:	854e                	mv	a0,s3
    80003538:	d33ff0ef          	jal	8000326a <ilock>
      iunlock(ip);
    8000353c:	854e                	mv	a0,s3
    8000353e:	ddbff0ef          	jal	80003318 <iunlock>
      iput(ip);
    80003542:	854e                	mv	a0,s3
    80003544:	ea9ff0ef          	jal	800033ec <iput>
      end_op();
    80003548:	027000ef          	jal	80003d6e <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000354c:	0485                	addi	s1,s1,1
    8000354e:	00ca2703          	lw	a4,12(s4)
    80003552:	0004879b          	sext.w	a5,s1
    80003556:	02e7fd63          	bgeu	a5,a4,80003590 <ireclaim+0xb2>
    8000355a:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000355e:	0044d593          	srli	a1,s1,0x4
    80003562:	018a2783          	lw	a5,24(s4)
    80003566:	9dbd                	addw	a1,a1,a5
    80003568:	8556                	mv	a0,s5
    8000356a:	e68ff0ef          	jal	80002bd2 <bread>
    8000356e:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003570:	05850793          	addi	a5,a0,88
    80003574:	00f9f713          	andi	a4,s3,15
    80003578:	071a                	slli	a4,a4,0x6
    8000357a:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    8000357c:	00079703          	lh	a4,0(a5)
    80003580:	c701                	beqz	a4,80003588 <ireclaim+0xaa>
    80003582:	00679783          	lh	a5,6(a5)
    80003586:	dbc1                	beqz	a5,80003516 <ireclaim+0x38>
    brelse(bp);
    80003588:	854a                	mv	a0,s2
    8000358a:	f50ff0ef          	jal	80002cda <brelse>
    if (ip) {
    8000358e:	bf7d                	j	8000354c <ireclaim+0x6e>
}
    80003590:	70e2                	ld	ra,56(sp)
    80003592:	7442                	ld	s0,48(sp)
    80003594:	74a2                	ld	s1,40(sp)
    80003596:	7902                	ld	s2,32(sp)
    80003598:	69e2                	ld	s3,24(sp)
    8000359a:	6a42                	ld	s4,16(sp)
    8000359c:	6aa2                	ld	s5,8(sp)
    8000359e:	6b02                	ld	s6,0(sp)
    800035a0:	6121                	addi	sp,sp,64
    800035a2:	8082                	ret
    800035a4:	8082                	ret

00000000800035a6 <fsinit>:
{
    800035a6:	1101                	addi	sp,sp,-32
    800035a8:	ec06                	sd	ra,24(sp)
    800035aa:	e822                	sd	s0,16(sp)
    800035ac:	e426                	sd	s1,8(sp)
    800035ae:	e04a                	sd	s2,0(sp)
    800035b0:	1000                	addi	s0,sp,32
    800035b2:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800035b4:	4585                	li	a1,1
    800035b6:	e1cff0ef          	jal	80002bd2 <bread>
    800035ba:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800035bc:	02000613          	li	a2,32
    800035c0:	05850593          	addi	a1,a0,88
    800035c4:	0001d517          	auipc	a0,0x1d
    800035c8:	33c50513          	addi	a0,a0,828 # 80020900 <sb>
    800035cc:	f7cfd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    800035d0:	8526                	mv	a0,s1
    800035d2:	f08ff0ef          	jal	80002cda <brelse>
  if (sb.magic != FSMAGIC)
    800035d6:	0001d717          	auipc	a4,0x1d
    800035da:	32a72703          	lw	a4,810(a4) # 80020900 <sb>
    800035de:	102037b7          	lui	a5,0x10203
    800035e2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035e6:	02f71263          	bne	a4,a5,8000360a <fsinit+0x64>
  initlog(dev, &sb);
    800035ea:	0001d597          	auipc	a1,0x1d
    800035ee:	31658593          	addi	a1,a1,790 # 80020900 <sb>
    800035f2:	854a                	mv	a0,s2
    800035f4:	66c000ef          	jal	80003c60 <initlog>
  ireclaim(dev);
    800035f8:	854a                	mv	a0,s2
    800035fa:	ee5ff0ef          	jal	800034de <ireclaim>
}
    800035fe:	60e2                	ld	ra,24(sp)
    80003600:	6442                	ld	s0,16(sp)
    80003602:	64a2                	ld	s1,8(sp)
    80003604:	6902                	ld	s2,0(sp)
    80003606:	6105                	addi	sp,sp,32
    80003608:	8082                	ret
    panic("invalid file system");
    8000360a:	00004517          	auipc	a0,0x4
    8000360e:	e9e50513          	addi	a0,a0,-354 # 800074a8 <etext+0x4a8>
    80003612:	a22fd0ef          	jal	80000834 <panic>

0000000080003616 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003616:	1141                	addi	sp,sp,-16
    80003618:	e406                	sd	ra,8(sp)
    8000361a:	e022                	sd	s0,0(sp)
    8000361c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000361e:	411c                	lw	a5,0(a0)
    80003620:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003622:	415c                	lw	a5,4(a0)
    80003624:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003626:	04451783          	lh	a5,68(a0)
    8000362a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000362e:	04a51783          	lh	a5,74(a0)
    80003632:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003636:	04c56783          	lwu	a5,76(a0)
    8000363a:	e99c                	sd	a5,16(a1)
}
    8000363c:	60a2                	ld	ra,8(sp)
    8000363e:	6402                	ld	s0,0(sp)
    80003640:	0141                	addi	sp,sp,16
    80003642:	8082                	ret

0000000080003644 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003644:	457c                	lw	a5,76(a0)
    80003646:	0ed7e663          	bltu	a5,a3,80003732 <readi+0xee>
{
    8000364a:	7159                	addi	sp,sp,-112
    8000364c:	f486                	sd	ra,104(sp)
    8000364e:	f0a2                	sd	s0,96(sp)
    80003650:	eca6                	sd	s1,88(sp)
    80003652:	e0d2                	sd	s4,64(sp)
    80003654:	fc56                	sd	s5,56(sp)
    80003656:	f85a                	sd	s6,48(sp)
    80003658:	f45e                	sd	s7,40(sp)
    8000365a:	1880                	addi	s0,sp,112
    8000365c:	8b2a                	mv	s6,a0
    8000365e:	8bae                	mv	s7,a1
    80003660:	8a32                	mv	s4,a2
    80003662:	84b6                	mv	s1,a3
    80003664:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003666:	9f35                	addw	a4,a4,a3
    return 0;
    80003668:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    8000366a:	0ad76b63          	bltu	a4,a3,80003720 <readi+0xdc>
    8000366e:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003670:	00e7f463          	bgeu	a5,a4,80003678 <readi+0x34>
    n = ip->size - off;
    80003674:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003678:	080a8b63          	beqz	s5,8000370e <readi+0xca>
    8000367c:	e8ca                	sd	s2,80(sp)
    8000367e:	f062                	sd	s8,32(sp)
    80003680:	ec66                	sd	s9,24(sp)
    80003682:	e86a                	sd	s10,16(sp)
    80003684:	e46e                	sd	s11,8(sp)
    80003686:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003688:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000368c:	5c7d                	li	s8,-1
    8000368e:	a80d                	j	800036c0 <readi+0x7c>
    80003690:	020d1d93          	slli	s11,s10,0x20
    80003694:	020ddd93          	srli	s11,s11,0x20
    80003698:	05890613          	addi	a2,s2,88
    8000369c:	86ee                	mv	a3,s11
    8000369e:	963e                	add	a2,a2,a5
    800036a0:	85d2                	mv	a1,s4
    800036a2:	855e                	mv	a0,s7
    800036a4:	c41fe0ef          	jal	800022e4 <either_copyout>
    800036a8:	05850363          	beq	a0,s8,800036ee <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800036ac:	854a                	mv	a0,s2
    800036ae:	e2cff0ef          	jal	80002cda <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800036b2:	013d09bb          	addw	s3,s10,s3
    800036b6:	009d04bb          	addw	s1,s10,s1
    800036ba:	9a6e                	add	s4,s4,s11
    800036bc:	0559f363          	bgeu	s3,s5,80003702 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    800036c0:	00a4d59b          	srliw	a1,s1,0xa
    800036c4:	855a                	mv	a0,s6
    800036c6:	873ff0ef          	jal	80002f38 <bmap>
    800036ca:	85aa                	mv	a1,a0
    if (addr == 0)
    800036cc:	c139                	beqz	a0,80003712 <readi+0xce>
    bp = bread(ip->dev, addr);
    800036ce:	000b2503          	lw	a0,0(s6)
    800036d2:	d00ff0ef          	jal	80002bd2 <bread>
    800036d6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800036d8:	3ff4f793          	andi	a5,s1,1023
    800036dc:	40fc873b          	subw	a4,s9,a5
    800036e0:	413a86bb          	subw	a3,s5,s3
    800036e4:	8d3a                	mv	s10,a4
    800036e6:	fae6f5e3          	bgeu	a3,a4,80003690 <readi+0x4c>
    800036ea:	8d36                	mv	s10,a3
    800036ec:	b755                	j	80003690 <readi+0x4c>
      brelse(bp);
    800036ee:	854a                	mv	a0,s2
    800036f0:	deaff0ef          	jal	80002cda <brelse>
      tot = -1;
    800036f4:	59fd                	li	s3,-1
      break;
    800036f6:	6946                	ld	s2,80(sp)
    800036f8:	7c02                	ld	s8,32(sp)
    800036fa:	6ce2                	ld	s9,24(sp)
    800036fc:	6d42                	ld	s10,16(sp)
    800036fe:	6da2                	ld	s11,8(sp)
    80003700:	a831                	j	8000371c <readi+0xd8>
    80003702:	6946                	ld	s2,80(sp)
    80003704:	7c02                	ld	s8,32(sp)
    80003706:	6ce2                	ld	s9,24(sp)
    80003708:	6d42                	ld	s10,16(sp)
    8000370a:	6da2                	ld	s11,8(sp)
    8000370c:	a801                	j	8000371c <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000370e:	89d6                	mv	s3,s5
    80003710:	a031                	j	8000371c <readi+0xd8>
    80003712:	6946                	ld	s2,80(sp)
    80003714:	7c02                	ld	s8,32(sp)
    80003716:	6ce2                	ld	s9,24(sp)
    80003718:	6d42                	ld	s10,16(sp)
    8000371a:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000371c:	854e                	mv	a0,s3
    8000371e:	69a6                	ld	s3,72(sp)
}
    80003720:	70a6                	ld	ra,104(sp)
    80003722:	7406                	ld	s0,96(sp)
    80003724:	64e6                	ld	s1,88(sp)
    80003726:	6a06                	ld	s4,64(sp)
    80003728:	7ae2                	ld	s5,56(sp)
    8000372a:	7b42                	ld	s6,48(sp)
    8000372c:	7ba2                	ld	s7,40(sp)
    8000372e:	6165                	addi	sp,sp,112
    80003730:	8082                	ret
    return 0;
    80003732:	4501                	li	a0,0
}
    80003734:	8082                	ret

0000000080003736 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003736:	457c                	lw	a5,76(a0)
    80003738:	0ed7ee63          	bltu	a5,a3,80003834 <writei+0xfe>
{
    8000373c:	7159                	addi	sp,sp,-112
    8000373e:	f486                	sd	ra,104(sp)
    80003740:	f0a2                	sd	s0,96(sp)
    80003742:	e8ca                	sd	s2,80(sp)
    80003744:	e0d2                	sd	s4,64(sp)
    80003746:	fc56                	sd	s5,56(sp)
    80003748:	f85a                	sd	s6,48(sp)
    8000374a:	f45e                	sd	s7,40(sp)
    8000374c:	1880                	addi	s0,sp,112
    8000374e:	8aaa                	mv	s5,a0
    80003750:	8bae                	mv	s7,a1
    80003752:	8a32                	mv	s4,a2
    80003754:	8936                	mv	s2,a3
    80003756:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003758:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    8000375c:	00043737          	lui	a4,0x43
    80003760:	0cf76c63          	bltu	a4,a5,80003838 <writei+0x102>
    80003764:	0cd7ea63          	bltu	a5,a3,80003838 <writei+0x102>
    80003768:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000376a:	0a0b0d63          	beqz	s6,80003824 <writei+0xee>
    8000376e:	eca6                	sd	s1,88(sp)
    80003770:	f062                	sd	s8,32(sp)
    80003772:	ec66                	sd	s9,24(sp)
    80003774:	e86a                	sd	s10,16(sp)
    80003776:	e46e                	sd	s11,8(sp)
    80003778:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000377a:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000377e:	5c7d                	li	s8,-1
    80003780:	a825                	j	800037b8 <writei+0x82>
    80003782:	020d1d93          	slli	s11,s10,0x20
    80003786:	020ddd93          	srli	s11,s11,0x20
    8000378a:	05848513          	addi	a0,s1,88
    8000378e:	86ee                	mv	a3,s11
    80003790:	8652                	mv	a2,s4
    80003792:	85de                	mv	a1,s7
    80003794:	953e                	add	a0,a0,a5
    80003796:	b9bfe0ef          	jal	80002330 <either_copyin>
    8000379a:	05850663          	beq	a0,s8,800037e6 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    8000379e:	8526                	mv	a0,s1
    800037a0:	6f0000ef          	jal	80003e90 <log_write>
    brelse(bp);
    800037a4:	8526                	mv	a0,s1
    800037a6:	d34ff0ef          	jal	80002cda <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800037aa:	013d09bb          	addw	s3,s10,s3
    800037ae:	012d093b          	addw	s2,s10,s2
    800037b2:	9a6e                	add	s4,s4,s11
    800037b4:	0369ff63          	bgeu	s3,s6,800037f2 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    800037b8:	00a9559b          	srliw	a1,s2,0xa
    800037bc:	8556                	mv	a0,s5
    800037be:	f7aff0ef          	jal	80002f38 <bmap>
    800037c2:	85aa                	mv	a1,a0
    if (addr == 0)
    800037c4:	c51d                	beqz	a0,800037f2 <writei+0xbc>
    bp = bread(ip->dev, addr);
    800037c6:	000aa503          	lw	a0,0(s5)
    800037ca:	c08ff0ef          	jal	80002bd2 <bread>
    800037ce:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800037d0:	3ff97793          	andi	a5,s2,1023
    800037d4:	40fc873b          	subw	a4,s9,a5
    800037d8:	413b06bb          	subw	a3,s6,s3
    800037dc:	8d3a                	mv	s10,a4
    800037de:	fae6f2e3          	bgeu	a3,a4,80003782 <writei+0x4c>
    800037e2:	8d36                	mv	s10,a3
    800037e4:	bf79                	j	80003782 <writei+0x4c>
      log_write(bp);
    800037e6:	8526                	mv	a0,s1
    800037e8:	6a8000ef          	jal	80003e90 <log_write>
      brelse(bp);
    800037ec:	8526                	mv	a0,s1
    800037ee:	cecff0ef          	jal	80002cda <brelse>
  }

  if (off > ip->size)
    800037f2:	04caa783          	lw	a5,76(s5)
    800037f6:	0327f963          	bgeu	a5,s2,80003828 <writei+0xf2>
    ip->size = off;
    800037fa:	052aa623          	sw	s2,76(s5)
    800037fe:	64e6                	ld	s1,88(sp)
    80003800:	7c02                	ld	s8,32(sp)
    80003802:	6ce2                	ld	s9,24(sp)
    80003804:	6d42                	ld	s10,16(sp)
    80003806:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003808:	8556                	mv	a0,s5
    8000380a:	9adff0ef          	jal	800031b6 <iupdate>

  return tot;
    8000380e:	854e                	mv	a0,s3
    80003810:	69a6                	ld	s3,72(sp)
}
    80003812:	70a6                	ld	ra,104(sp)
    80003814:	7406                	ld	s0,96(sp)
    80003816:	6946                	ld	s2,80(sp)
    80003818:	6a06                	ld	s4,64(sp)
    8000381a:	7ae2                	ld	s5,56(sp)
    8000381c:	7b42                	ld	s6,48(sp)
    8000381e:	7ba2                	ld	s7,40(sp)
    80003820:	6165                	addi	sp,sp,112
    80003822:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003824:	89da                	mv	s3,s6
    80003826:	b7cd                	j	80003808 <writei+0xd2>
    80003828:	64e6                	ld	s1,88(sp)
    8000382a:	7c02                	ld	s8,32(sp)
    8000382c:	6ce2                	ld	s9,24(sp)
    8000382e:	6d42                	ld	s10,16(sp)
    80003830:	6da2                	ld	s11,8(sp)
    80003832:	bfd9                	j	80003808 <writei+0xd2>
    return -1;
    80003834:	557d                	li	a0,-1
}
    80003836:	8082                	ret
    return -1;
    80003838:	557d                	li	a0,-1
    8000383a:	bfe1                	j	80003812 <writei+0xdc>

000000008000383c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000383c:	1141                	addi	sp,sp,-16
    8000383e:	e406                	sd	ra,8(sp)
    80003840:	e022                	sd	s0,0(sp)
    80003842:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003844:	4639                	li	a2,14
    80003846:	d76fd0ef          	jal	80000dbc <strncmp>
}
    8000384a:	60a2                	ld	ra,8(sp)
    8000384c:	6402                	ld	s0,0(sp)
    8000384e:	0141                	addi	sp,sp,16
    80003850:	8082                	ret

0000000080003852 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003852:	711d                	addi	sp,sp,-96
    80003854:	ec86                	sd	ra,88(sp)
    80003856:	e8a2                	sd	s0,80(sp)
    80003858:	e4a6                	sd	s1,72(sp)
    8000385a:	e0ca                	sd	s2,64(sp)
    8000385c:	fc4e                	sd	s3,56(sp)
    8000385e:	f852                	sd	s4,48(sp)
    80003860:	f456                	sd	s5,40(sp)
    80003862:	f05a                	sd	s6,32(sp)
    80003864:	ec5e                	sd	s7,24(sp)
    80003866:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003868:	04451703          	lh	a4,68(a0)
    8000386c:	4785                	li	a5,1
    8000386e:	00f71f63          	bne	a4,a5,8000388c <dirlookup+0x3a>
    80003872:	892a                	mv	s2,a0
    80003874:	8aae                	mv	s5,a1
    80003876:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003878:	457c                	lw	a5,76(a0)
    8000387a:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000387c:	fa040a13          	addi	s4,s0,-96
    80003880:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003882:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003886:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003888:	e39d                	bnez	a5,800038ae <dirlookup+0x5c>
    8000388a:	a8b9                	j	800038e8 <dirlookup+0x96>
    panic("dirlookup not DIR");
    8000388c:	00004517          	auipc	a0,0x4
    80003890:	c3450513          	addi	a0,a0,-972 # 800074c0 <etext+0x4c0>
    80003894:	fa1fc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    80003898:	00004517          	auipc	a0,0x4
    8000389c:	c4050513          	addi	a0,a0,-960 # 800074d8 <etext+0x4d8>
    800038a0:	f95fc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800038a4:	24c1                	addiw	s1,s1,16
    800038a6:	04c92783          	lw	a5,76(s2)
    800038aa:	02f4fe63          	bgeu	s1,a5,800038e6 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038ae:	874e                	mv	a4,s3
    800038b0:	86a6                	mv	a3,s1
    800038b2:	8652                	mv	a2,s4
    800038b4:	4581                	li	a1,0
    800038b6:	854a                	mv	a0,s2
    800038b8:	d8dff0ef          	jal	80003644 <readi>
    800038bc:	fd351ee3          	bne	a0,s3,80003898 <dirlookup+0x46>
    if (de.inum == 0)
    800038c0:	fa045783          	lhu	a5,-96(s0)
    800038c4:	d3e5                	beqz	a5,800038a4 <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    800038c6:	85da                	mv	a1,s6
    800038c8:	8556                	mv	a0,s5
    800038ca:	f73ff0ef          	jal	8000383c <namecmp>
    800038ce:	f979                	bnez	a0,800038a4 <dirlookup+0x52>
      if (poff)
    800038d0:	000b8463          	beqz	s7,800038d8 <dirlookup+0x86>
        *poff = off;
    800038d4:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800038d8:	fa045583          	lhu	a1,-96(s0)
    800038dc:	00092503          	lw	a0,0(s2)
    800038e0:	f18ff0ef          	jal	80002ff8 <iget>
    800038e4:	a011                	j	800038e8 <dirlookup+0x96>
  return 0;
    800038e6:	4501                	li	a0,0
}
    800038e8:	60e6                	ld	ra,88(sp)
    800038ea:	6446                	ld	s0,80(sp)
    800038ec:	64a6                	ld	s1,72(sp)
    800038ee:	6906                	ld	s2,64(sp)
    800038f0:	79e2                	ld	s3,56(sp)
    800038f2:	7a42                	ld	s4,48(sp)
    800038f4:	7aa2                	ld	s5,40(sp)
    800038f6:	7b02                	ld	s6,32(sp)
    800038f8:	6be2                	ld	s7,24(sp)
    800038fa:	6125                	addi	sp,sp,96
    800038fc:	8082                	ret

00000000800038fe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    800038fe:	711d                	addi	sp,sp,-96
    80003900:	ec86                	sd	ra,88(sp)
    80003902:	e8a2                	sd	s0,80(sp)
    80003904:	e4a6                	sd	s1,72(sp)
    80003906:	e0ca                	sd	s2,64(sp)
    80003908:	fc4e                	sd	s3,56(sp)
    8000390a:	f852                	sd	s4,48(sp)
    8000390c:	f456                	sd	s5,40(sp)
    8000390e:	f05a                	sd	s6,32(sp)
    80003910:	ec5e                	sd	s7,24(sp)
    80003912:	e862                	sd	s8,16(sp)
    80003914:	e466                	sd	s9,8(sp)
    80003916:	e06a                	sd	s10,0(sp)
    80003918:	1080                	addi	s0,sp,96
    8000391a:	84aa                	mv	s1,a0
    8000391c:	8b2e                	mv	s6,a1
    8000391e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003920:	00054703          	lbu	a4,0(a0)
    80003924:	02f00793          	li	a5,47
    80003928:	00f70f63          	beq	a4,a5,80003946 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000392c:	81cfe0ef          	jal	80001948 <myproc>
    80003930:	15053503          	ld	a0,336(a0)
    80003934:	901ff0ef          	jal	80003234 <idup>
    80003938:	8a2a                	mv	s4,a0
  while (*path == '/')
    8000393a:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    8000393e:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003940:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003942:	4b85                	li	s7,1
    80003944:	a07d                	j	800039f2 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003946:	4585                	li	a1,1
    80003948:	852e                	mv	a0,a1
    8000394a:	eaeff0ef          	jal	80002ff8 <iget>
    8000394e:	8a2a                	mv	s4,a0
    80003950:	b7ed                	j	8000393a <namex+0x3c>
      iunlockput(ip);
    80003952:	8552                	mv	a0,s4
    80003954:	b6bff0ef          	jal	800034be <iunlockput>
      return 0;
    80003958:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    8000395a:	8552                	mv	a0,s4
    8000395c:	60e6                	ld	ra,88(sp)
    8000395e:	6446                	ld	s0,80(sp)
    80003960:	64a6                	ld	s1,72(sp)
    80003962:	6906                	ld	s2,64(sp)
    80003964:	79e2                	ld	s3,56(sp)
    80003966:	7a42                	ld	s4,48(sp)
    80003968:	7aa2                	ld	s5,40(sp)
    8000396a:	7b02                	ld	s6,32(sp)
    8000396c:	6be2                	ld	s7,24(sp)
    8000396e:	6c42                	ld	s8,16(sp)
    80003970:	6ca2                	ld	s9,8(sp)
    80003972:	6d02                	ld	s10,0(sp)
    80003974:	6125                	addi	sp,sp,96
    80003976:	8082                	ret
      iunlockput(ip);
    80003978:	8552                	mv	a0,s4
    8000397a:	b45ff0ef          	jal	800034be <iunlockput>
      return 0;
    8000397e:	4a01                	li	s4,0
    80003980:	bfe9                	j	8000395a <namex+0x5c>
      iunlock(ip);
    80003982:	8552                	mv	a0,s4
    80003984:	995ff0ef          	jal	80003318 <iunlock>
      return ip;
    80003988:	bfc9                	j	8000395a <namex+0x5c>
      iunlockput(ip);
    8000398a:	8552                	mv	a0,s4
    8000398c:	b33ff0ef          	jal	800034be <iunlockput>
      return 0;
    80003990:	8a4a                	mv	s4,s2
    80003992:	b7e1                	j	8000395a <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003994:	8926                	mv	s2,s1
  len = path - s;
    80003996:	4d01                	li	s10,0
    80003998:	4601                	li	a2,0
    memmove(name, s, len);
    8000399a:	2601                	sext.w	a2,a2
    8000399c:	85a6                	mv	a1,s1
    8000399e:	8556                	mv	a0,s5
    800039a0:	ba8fd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    800039a4:	9d56                	add	s10,s10,s5
    800039a6:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb9f8>
  while (*path == '/')
    800039aa:	00094783          	lbu	a5,0(s2)
    800039ae:	09379b63          	bne	a5,s3,80003a44 <namex+0x146>
    800039b2:	84ca                	mv	s1,s2
    path++;
    800039b4:	0485                	addi	s1,s1,1
  while (*path == '/')
    800039b6:	0004c783          	lbu	a5,0(s1)
    800039ba:	ff378de3          	beq	a5,s3,800039b4 <namex+0xb6>
    ilock(ip);
    800039be:	8552                	mv	a0,s4
    800039c0:	8abff0ef          	jal	8000326a <ilock>
    if (ip->type != T_DIR) {
    800039c4:	044a1783          	lh	a5,68(s4)
    800039c8:	f97795e3          	bne	a5,s7,80003952 <namex+0x54>
    if (ip->nlink == 0) {
    800039cc:	04aa1783          	lh	a5,74(s4)
    800039d0:	d7c5                	beqz	a5,80003978 <namex+0x7a>
    if (nameiparent && *path == '\0') {
    800039d2:	000b0563          	beqz	s6,800039dc <namex+0xde>
    800039d6:	0004c783          	lbu	a5,0(s1)
    800039da:	d7c5                	beqz	a5,80003982 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    800039dc:	4601                	li	a2,0
    800039de:	85d6                	mv	a1,s5
    800039e0:	8552                	mv	a0,s4
    800039e2:	e71ff0ef          	jal	80003852 <dirlookup>
    800039e6:	892a                	mv	s2,a0
    800039e8:	d14d                	beqz	a0,8000398a <namex+0x8c>
    iunlockput(ip);
    800039ea:	8552                	mv	a0,s4
    800039ec:	ad3ff0ef          	jal	800034be <iunlockput>
    ip = next;
    800039f0:	8a4a                	mv	s4,s2
  while (*path == '/')
    800039f2:	0004c783          	lbu	a5,0(s1)
    800039f6:	01379763          	bne	a5,s3,80003a04 <namex+0x106>
    path++;
    800039fa:	0485                	addi	s1,s1,1
  while (*path == '/')
    800039fc:	0004c783          	lbu	a5,0(s1)
    80003a00:	ff378de3          	beq	a5,s3,800039fa <namex+0xfc>
  if (*path == 0)
    80003a04:	c7a1                	beqz	a5,80003a4c <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003a06:	0004c783          	lbu	a5,0(s1)
    80003a0a:	fd178713          	addi	a4,a5,-47
    80003a0e:	d359                	beqz	a4,80003994 <namex+0x96>
    80003a10:	d3d1                	beqz	a5,80003994 <namex+0x96>
    80003a12:	8926                	mv	s2,s1
    path++;
    80003a14:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003a16:	00094783          	lbu	a5,0(s2)
    80003a1a:	fd178713          	addi	a4,a5,-47
    80003a1e:	c311                	beqz	a4,80003a22 <namex+0x124>
    80003a20:	fbf5                	bnez	a5,80003a14 <namex+0x116>
  len = path - s;
    80003a22:	40990633          	sub	a2,s2,s1
    80003a26:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003a2a:	f7ac58e3          	bge	s8,s10,8000399a <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003a2e:	8666                	mv	a2,s9
    80003a30:	85a6                	mv	a1,s1
    80003a32:	8556                	mv	a0,s5
    80003a34:	b14fd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003a38:	00094783          	lbu	a5,0(s2)
    80003a3c:	84ca                	mv	s1,s2
    80003a3e:	f7378be3          	beq	a5,s3,800039b4 <namex+0xb6>
    80003a42:	bfb5                	j	800039be <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003a44:	00090463          	beqz	s2,80003a4c <namex+0x14e>
    80003a48:	84ca                	mv	s1,s2
    80003a4a:	bf95                	j	800039be <namex+0xc0>
  if (nameiparent) {
    80003a4c:	f00b07e3          	beqz	s6,8000395a <namex+0x5c>
    iput(ip);
    80003a50:	8552                	mv	a0,s4
    80003a52:	99bff0ef          	jal	800033ec <iput>
    return 0;
    80003a56:	4a01                	li	s4,0
    80003a58:	b709                	j	8000395a <namex+0x5c>

0000000080003a5a <dirlink>:
{
    80003a5a:	715d                	addi	sp,sp,-80
    80003a5c:	e486                	sd	ra,72(sp)
    80003a5e:	e0a2                	sd	s0,64(sp)
    80003a60:	f84a                	sd	s2,48(sp)
    80003a62:	ec56                	sd	s5,24(sp)
    80003a64:	e85a                	sd	s6,16(sp)
    80003a66:	0880                	addi	s0,sp,80
    80003a68:	892a                	mv	s2,a0
    80003a6a:	8aae                	mv	s5,a1
    80003a6c:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003a6e:	4601                	li	a2,0
    80003a70:	de3ff0ef          	jal	80003852 <dirlookup>
    80003a74:	ed1d                	bnez	a0,80003ab2 <dirlink+0x58>
    80003a76:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a78:	04c92483          	lw	s1,76(s2)
    80003a7c:	c4b9                	beqz	s1,80003aca <dirlink+0x70>
    80003a7e:	f44e                	sd	s3,40(sp)
    80003a80:	f052                	sd	s4,32(sp)
    80003a82:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a84:	fb040a13          	addi	s4,s0,-80
    80003a88:	49c1                	li	s3,16
    80003a8a:	874e                	mv	a4,s3
    80003a8c:	86a6                	mv	a3,s1
    80003a8e:	8652                	mv	a2,s4
    80003a90:	4581                	li	a1,0
    80003a92:	854a                	mv	a0,s2
    80003a94:	bb1ff0ef          	jal	80003644 <readi>
    80003a98:	03351163          	bne	a0,s3,80003aba <dirlink+0x60>
    if (de.inum == 0)
    80003a9c:	fb045783          	lhu	a5,-80(s0)
    80003aa0:	c39d                	beqz	a5,80003ac6 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003aa2:	24c1                	addiw	s1,s1,16
    80003aa4:	04c92783          	lw	a5,76(s2)
    80003aa8:	fef4e1e3          	bltu	s1,a5,80003a8a <dirlink+0x30>
    80003aac:	79a2                	ld	s3,40(sp)
    80003aae:	7a02                	ld	s4,32(sp)
    80003ab0:	a829                	j	80003aca <dirlink+0x70>
    iput(ip);
    80003ab2:	93bff0ef          	jal	800033ec <iput>
    return -1;
    80003ab6:	557d                	li	a0,-1
    80003ab8:	a83d                	j	80003af6 <dirlink+0x9c>
      panic("dirlink read");
    80003aba:	00004517          	auipc	a0,0x4
    80003abe:	a2e50513          	addi	a0,a0,-1490 # 800074e8 <etext+0x4e8>
    80003ac2:	d73fc0ef          	jal	80000834 <panic>
    80003ac6:	79a2                	ld	s3,40(sp)
    80003ac8:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003aca:	4639                	li	a2,14
    80003acc:	85d6                	mv	a1,s5
    80003ace:	fb240513          	addi	a0,s0,-78
    80003ad2:	b24fd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003ad6:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ada:	4741                	li	a4,16
    80003adc:	86a6                	mv	a3,s1
    80003ade:	fb040613          	addi	a2,s0,-80
    80003ae2:	4581                	li	a1,0
    80003ae4:	854a                	mv	a0,s2
    80003ae6:	c51ff0ef          	jal	80003736 <writei>
    80003aea:	1541                	addi	a0,a0,-16
    80003aec:	00a03533          	snez	a0,a0
    80003af0:	40a0053b          	negw	a0,a0
    80003af4:	74e2                	ld	s1,56(sp)
}
    80003af6:	60a6                	ld	ra,72(sp)
    80003af8:	6406                	ld	s0,64(sp)
    80003afa:	7942                	ld	s2,48(sp)
    80003afc:	6ae2                	ld	s5,24(sp)
    80003afe:	6b42                	ld	s6,16(sp)
    80003b00:	6161                	addi	sp,sp,80
    80003b02:	8082                	ret

0000000080003b04 <namei>:

struct inode *
namei(char *path)
{
    80003b04:	1101                	addi	sp,sp,-32
    80003b06:	ec06                	sd	ra,24(sp)
    80003b08:	e822                	sd	s0,16(sp)
    80003b0a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b0c:	fe040613          	addi	a2,s0,-32
    80003b10:	4581                	li	a1,0
    80003b12:	dedff0ef          	jal	800038fe <namex>
}
    80003b16:	60e2                	ld	ra,24(sp)
    80003b18:	6442                	ld	s0,16(sp)
    80003b1a:	6105                	addi	sp,sp,32
    80003b1c:	8082                	ret

0000000080003b1e <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003b1e:	1141                	addi	sp,sp,-16
    80003b20:	e406                	sd	ra,8(sp)
    80003b22:	e022                	sd	s0,0(sp)
    80003b24:	0800                	addi	s0,sp,16
    80003b26:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b28:	4585                	li	a1,1
    80003b2a:	dd5ff0ef          	jal	800038fe <namex>
}
    80003b2e:	60a2                	ld	ra,8(sp)
    80003b30:	6402                	ld	s0,0(sp)
    80003b32:	0141                	addi	sp,sp,16
    80003b34:	8082                	ret

0000000080003b36 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b36:	1101                	addi	sp,sp,-32
    80003b38:	ec06                	sd	ra,24(sp)
    80003b3a:	e822                	sd	s0,16(sp)
    80003b3c:	e426                	sd	s1,8(sp)
    80003b3e:	e04a                	sd	s2,0(sp)
    80003b40:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003b42:	0001f917          	auipc	s2,0x1f
    80003b46:	88690913          	addi	s2,s2,-1914 # 800223c8 <log>
    80003b4a:	01892583          	lw	a1,24(s2)
    80003b4e:	02492503          	lw	a0,36(s2)
    80003b52:	880ff0ef          	jal	80002bd2 <bread>
    80003b56:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003b58:	02c92603          	lw	a2,44(s2)
    80003b5c:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b5e:	00c05f63          	blez	a2,80003b7c <write_head+0x46>
    80003b62:	0001f717          	auipc	a4,0x1f
    80003b66:	89670713          	addi	a4,a4,-1898 # 800223f8 <log+0x30>
    80003b6a:	87aa                	mv	a5,a0
    80003b6c:	060a                	slli	a2,a2,0x2
    80003b6e:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b70:	4314                	lw	a3,0(a4)
    80003b72:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b74:	0711                	addi	a4,a4,4
    80003b76:	0791                	addi	a5,a5,4
    80003b78:	fec79ce3          	bne	a5,a2,80003b70 <write_head+0x3a>
  }
  bwrite(buf);
    80003b7c:	8526                	mv	a0,s1
    80003b7e:	92aff0ef          	jal	80002ca8 <bwrite>
  brelse(buf);
    80003b82:	8526                	mv	a0,s1
    80003b84:	956ff0ef          	jal	80002cda <brelse>
}
    80003b88:	60e2                	ld	ra,24(sp)
    80003b8a:	6442                	ld	s0,16(sp)
    80003b8c:	64a2                	ld	s1,8(sp)
    80003b8e:	6902                	ld	s2,0(sp)
    80003b90:	6105                	addi	sp,sp,32
    80003b92:	8082                	ret

0000000080003b94 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b94:	0001f797          	auipc	a5,0x1f
    80003b98:	8607a783          	lw	a5,-1952(a5) # 800223f4 <log+0x2c>
    80003b9c:	0cf05163          	blez	a5,80003c5e <install_trans+0xca>
{
    80003ba0:	715d                	addi	sp,sp,-80
    80003ba2:	e486                	sd	ra,72(sp)
    80003ba4:	e0a2                	sd	s0,64(sp)
    80003ba6:	fc26                	sd	s1,56(sp)
    80003ba8:	f84a                	sd	s2,48(sp)
    80003baa:	f44e                	sd	s3,40(sp)
    80003bac:	f052                	sd	s4,32(sp)
    80003bae:	ec56                	sd	s5,24(sp)
    80003bb0:	e85a                	sd	s6,16(sp)
    80003bb2:	e45e                	sd	s7,8(sp)
    80003bb4:	e062                	sd	s8,0(sp)
    80003bb6:	0880                	addi	s0,sp,80
    80003bb8:	8b2a                	mv	s6,a0
    80003bba:	0001fa97          	auipc	s5,0x1f
    80003bbe:	83ea8a93          	addi	s5,s5,-1986 # 800223f8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bc2:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003bc4:	00004c17          	auipc	s8,0x4
    80003bc8:	934c0c13          	addi	s8,s8,-1740 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003bcc:	0001ea17          	auipc	s4,0x1e
    80003bd0:	7fca0a13          	addi	s4,s4,2044 # 800223c8 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003bd4:	40000b93          	li	s7,1024
    80003bd8:	a025                	j	80003c00 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003bda:	000aa603          	lw	a2,0(s5)
    80003bde:	85ce                	mv	a1,s3
    80003be0:	8562                	mv	a0,s8
    80003be2:	929fc0ef          	jal	8000050a <printk>
    80003be6:	a839                	j	80003c04 <install_trans+0x70>
    brelse(lbuf);
    80003be8:	854a                	mv	a0,s2
    80003bea:	8f0ff0ef          	jal	80002cda <brelse>
    brelse(dbuf);
    80003bee:	8526                	mv	a0,s1
    80003bf0:	8eaff0ef          	jal	80002cda <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bf4:	2985                	addiw	s3,s3,1
    80003bf6:	0a91                	addi	s5,s5,4
    80003bf8:	02ca2783          	lw	a5,44(s4)
    80003bfc:	04f9d563          	bge	s3,a5,80003c46 <install_trans+0xb2>
    if (recovering) {
    80003c00:	fc0b1de3          	bnez	s6,80003bda <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003c04:	018a2583          	lw	a1,24(s4)
    80003c08:	013585bb          	addw	a1,a1,s3
    80003c0c:	2585                	addiw	a1,a1,1
    80003c0e:	024a2503          	lw	a0,36(s4)
    80003c12:	fc1fe0ef          	jal	80002bd2 <bread>
    80003c16:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003c18:	000aa583          	lw	a1,0(s5)
    80003c1c:	024a2503          	lw	a0,36(s4)
    80003c20:	fb3fe0ef          	jal	80002bd2 <bread>
    80003c24:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003c26:	865e                	mv	a2,s7
    80003c28:	05890593          	addi	a1,s2,88
    80003c2c:	05850513          	addi	a0,a0,88
    80003c30:	918fd0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003c34:	8526                	mv	a0,s1
    80003c36:	872ff0ef          	jal	80002ca8 <bwrite>
    if (recovering == 0)
    80003c3a:	fa0b17e3          	bnez	s6,80003be8 <install_trans+0x54>
      bunpin(dbuf);
    80003c3e:	8526                	mv	a0,s1
    80003c40:	952ff0ef          	jal	80002d92 <bunpin>
    80003c44:	b755                	j	80003be8 <install_trans+0x54>
}
    80003c46:	60a6                	ld	ra,72(sp)
    80003c48:	6406                	ld	s0,64(sp)
    80003c4a:	74e2                	ld	s1,56(sp)
    80003c4c:	7942                	ld	s2,48(sp)
    80003c4e:	79a2                	ld	s3,40(sp)
    80003c50:	7a02                	ld	s4,32(sp)
    80003c52:	6ae2                	ld	s5,24(sp)
    80003c54:	6b42                	ld	s6,16(sp)
    80003c56:	6ba2                	ld	s7,8(sp)
    80003c58:	6c02                	ld	s8,0(sp)
    80003c5a:	6161                	addi	sp,sp,80
    80003c5c:	8082                	ret
    80003c5e:	8082                	ret

0000000080003c60 <initlog>:
{
    80003c60:	7179                	addi	sp,sp,-48
    80003c62:	f406                	sd	ra,40(sp)
    80003c64:	f022                	sd	s0,32(sp)
    80003c66:	ec26                	sd	s1,24(sp)
    80003c68:	e84a                	sd	s2,16(sp)
    80003c6a:	e44e                	sd	s3,8(sp)
    80003c6c:	1800                	addi	s0,sp,48
    80003c6e:	84aa                	mv	s1,a0
    80003c70:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c72:	0001e917          	auipc	s2,0x1e
    80003c76:	75690913          	addi	s2,s2,1878 # 800223c8 <log>
    80003c7a:	00004597          	auipc	a1,0x4
    80003c7e:	89e58593          	addi	a1,a1,-1890 # 80007518 <etext+0x518>
    80003c82:	854a                	mv	a0,s2
    80003c84:	f25fc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003c88:	0149a583          	lw	a1,20(s3)
    80003c8c:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003c90:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003c94:	8526                	mv	a0,s1
    80003c96:	f3dfe0ef          	jal	80002bd2 <bread>
  log.lh.n = lh->n;
    80003c9a:	4d30                	lw	a2,88(a0)
    80003c9c:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003ca0:	00c05f63          	blez	a2,80003cbe <initlog+0x5e>
    80003ca4:	87aa                	mv	a5,a0
    80003ca6:	0001e717          	auipc	a4,0x1e
    80003caa:	75270713          	addi	a4,a4,1874 # 800223f8 <log+0x30>
    80003cae:	060a                	slli	a2,a2,0x2
    80003cb0:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003cb2:	4ff4                	lw	a3,92(a5)
    80003cb4:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003cb6:	0791                	addi	a5,a5,4
    80003cb8:	0711                	addi	a4,a4,4
    80003cba:	fec79ce3          	bne	a5,a2,80003cb2 <initlog+0x52>
  brelse(buf);
    80003cbe:	81cff0ef          	jal	80002cda <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003cc2:	4505                	li	a0,1
    80003cc4:	ed1ff0ef          	jal	80003b94 <install_trans>
  log.lh.n = 0;
    80003cc8:	0001e797          	auipc	a5,0x1e
    80003ccc:	7207a623          	sw	zero,1836(a5) # 800223f4 <log+0x2c>
  write_head(); // clear the log
    80003cd0:	e67ff0ef          	jal	80003b36 <write_head>
}
    80003cd4:	70a2                	ld	ra,40(sp)
    80003cd6:	7402                	ld	s0,32(sp)
    80003cd8:	64e2                	ld	s1,24(sp)
    80003cda:	6942                	ld	s2,16(sp)
    80003cdc:	69a2                	ld	s3,8(sp)
    80003cde:	6145                	addi	sp,sp,48
    80003ce0:	8082                	ret

0000000080003ce2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ce2:	1101                	addi	sp,sp,-32
    80003ce4:	ec06                	sd	ra,24(sp)
    80003ce6:	e822                	sd	s0,16(sp)
    80003ce8:	e426                	sd	s1,8(sp)
    80003cea:	e04a                	sd	s2,0(sp)
    80003cec:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003cee:	0001e517          	auipc	a0,0x1e
    80003cf2:	6da50513          	addi	a0,a0,1754 # 800223c8 <log>
    80003cf6:	f33fc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80003cfa:	0001e497          	auipc	s1,0x1e
    80003cfe:	6ce48493          	addi	s1,s1,1742 # 800223c8 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003d02:	4979                	li	s2,30
    80003d04:	a821                	j	80003d1c <begin_op+0x3a>
      sleep_prepare(&log);
    80003d06:	8526                	mv	a0,s1
    80003d08:	a4afe0ef          	jal	80001f52 <sleep_prepare>
      release(&log.lock);
    80003d0c:	8526                	mv	a0,s1
    80003d0e:	fa3fc0ef          	jal	80000cb0 <release>
      sleep();
    80003d12:	a7cfe0ef          	jal	80001f8e <sleep>
      acquire(&log.lock);
    80003d16:	8526                	mv	a0,s1
    80003d18:	f11fc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80003d1c:	509c                	lw	a5,32(s1)
    80003d1e:	f7e5                	bnez	a5,80003d06 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003d20:	4cd8                	lw	a4,28(s1)
    80003d22:	2705                	addiw	a4,a4,1
    80003d24:	0027179b          	slliw	a5,a4,0x2
    80003d28:	9fb9                	addw	a5,a5,a4
    80003d2a:	0017979b          	slliw	a5,a5,0x1
    80003d2e:	54d4                	lw	a3,44(s1)
    80003d30:	9fb5                	addw	a5,a5,a3
    80003d32:	00f95e63          	bge	s2,a5,80003d4e <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003d36:	8526                	mv	a0,s1
    80003d38:	a1afe0ef          	jal	80001f52 <sleep_prepare>
      release(&log.lock);
    80003d3c:	8526                	mv	a0,s1
    80003d3e:	f73fc0ef          	jal	80000cb0 <release>
      sleep();
    80003d42:	a4cfe0ef          	jal	80001f8e <sleep>
      acquire(&log.lock);
    80003d46:	8526                	mv	a0,s1
    80003d48:	ee1fc0ef          	jal	80000c28 <acquire>
    80003d4c:	bfc1                	j	80003d1c <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003d4e:	0001e797          	auipc	a5,0x1e
    80003d52:	68e7ab23          	sw	a4,1686(a5) # 800223e4 <log+0x1c>
      release(&log.lock);
    80003d56:	0001e517          	auipc	a0,0x1e
    80003d5a:	67250513          	addi	a0,a0,1650 # 800223c8 <log>
    80003d5e:	f53fc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80003d62:	60e2                	ld	ra,24(sp)
    80003d64:	6442                	ld	s0,16(sp)
    80003d66:	64a2                	ld	s1,8(sp)
    80003d68:	6902                	ld	s2,0(sp)
    80003d6a:	6105                	addi	sp,sp,32
    80003d6c:	8082                	ret

0000000080003d6e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d6e:	7139                	addi	sp,sp,-64
    80003d70:	fc06                	sd	ra,56(sp)
    80003d72:	f822                	sd	s0,48(sp)
    80003d74:	f426                	sd	s1,40(sp)
    80003d76:	f04a                	sd	s2,32(sp)
    80003d78:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d7a:	0001e497          	auipc	s1,0x1e
    80003d7e:	64e48493          	addi	s1,s1,1614 # 800223c8 <log>
    80003d82:	8526                	mv	a0,s1
    80003d84:	ea5fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003d88:	4cdc                	lw	a5,28(s1)
    80003d8a:	37fd                	addiw	a5,a5,-1
    80003d8c:	893e                	mv	s2,a5
    80003d8e:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003d90:	509c                	lw	a5,32(s1)
    80003d92:	e3b1                	bnez	a5,80003dd6 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003d94:	04091a63          	bnez	s2,80003de8 <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003d98:	0001e497          	auipc	s1,0x1e
    80003d9c:	63048493          	addi	s1,s1,1584 # 800223c8 <log>
    80003da0:	4785                	li	a5,1
    80003da2:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003da4:	8526                	mv	a0,s1
    80003da6:	f0bfc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003daa:	54dc                	lw	a5,44(s1)
    80003dac:	06f04063          	bgtz	a5,80003e0c <end_op+0x9e>
    acquire(&log.lock);
    80003db0:	0001e497          	auipc	s1,0x1e
    80003db4:	61848493          	addi	s1,s1,1560 # 800223c8 <log>
    80003db8:	8526                	mv	a0,s1
    80003dba:	e6ffc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003dbe:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003dc2:	549c                	lw	a5,40(s1)
    80003dc4:	2785                	addiw	a5,a5,1
    80003dc6:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003dc8:	8526                	mv	a0,s1
    80003dca:	9f4fe0ef          	jal	80001fbe <wakeup>
    release(&log.lock);
    80003dce:	8526                	mv	a0,s1
    80003dd0:	ee1fc0ef          	jal	80000cb0 <release>
}
    80003dd4:	a035                	j	80003e00 <end_op+0x92>
    80003dd6:	ec4e                	sd	s3,24(sp)
    80003dd8:	e852                	sd	s4,16(sp)
    80003dda:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003ddc:	00003517          	auipc	a0,0x3
    80003de0:	74450513          	addi	a0,a0,1860 # 80007520 <etext+0x520>
    80003de4:	a51fc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003de8:	0001e517          	auipc	a0,0x1e
    80003dec:	5e050513          	addi	a0,a0,1504 # 800223c8 <log>
    80003df0:	9cefe0ef          	jal	80001fbe <wakeup>
  release(&log.lock);
    80003df4:	0001e517          	auipc	a0,0x1e
    80003df8:	5d450513          	addi	a0,a0,1492 # 800223c8 <log>
    80003dfc:	eb5fc0ef          	jal	80000cb0 <release>
}
    80003e00:	70e2                	ld	ra,56(sp)
    80003e02:	7442                	ld	s0,48(sp)
    80003e04:	74a2                	ld	s1,40(sp)
    80003e06:	7902                	ld	s2,32(sp)
    80003e08:	6121                	addi	sp,sp,64
    80003e0a:	8082                	ret
    80003e0c:	ec4e                	sd	s3,24(sp)
    80003e0e:	e852                	sd	s4,16(sp)
    80003e10:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e12:	0001ea97          	auipc	s5,0x1e
    80003e16:	5e6a8a93          	addi	s5,s5,1510 # 800223f8 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003e1a:	0001ea17          	auipc	s4,0x1e
    80003e1e:	5aea0a13          	addi	s4,s4,1454 # 800223c8 <log>
    80003e22:	018a2583          	lw	a1,24(s4)
    80003e26:	012585bb          	addw	a1,a1,s2
    80003e2a:	2585                	addiw	a1,a1,1
    80003e2c:	024a2503          	lw	a0,36(s4)
    80003e30:	da3fe0ef          	jal	80002bd2 <bread>
    80003e34:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003e36:	000aa583          	lw	a1,0(s5)
    80003e3a:	024a2503          	lw	a0,36(s4)
    80003e3e:	d95fe0ef          	jal	80002bd2 <bread>
    80003e42:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e44:	40000613          	li	a2,1024
    80003e48:	05850593          	addi	a1,a0,88
    80003e4c:	05848513          	addi	a0,s1,88
    80003e50:	ef9fc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    80003e54:	8526                	mv	a0,s1
    80003e56:	e53fe0ef          	jal	80002ca8 <bwrite>
    brelse(from);
    80003e5a:	854e                	mv	a0,s3
    80003e5c:	e7ffe0ef          	jal	80002cda <brelse>
    brelse(to);
    80003e60:	8526                	mv	a0,s1
    80003e62:	e79fe0ef          	jal	80002cda <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e66:	2905                	addiw	s2,s2,1
    80003e68:	0a91                	addi	s5,s5,4
    80003e6a:	02ca2783          	lw	a5,44(s4)
    80003e6e:	faf94ae3          	blt	s2,a5,80003e22 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003e72:	cc5ff0ef          	jal	80003b36 <write_head>
    install_trans(0); // Now install writes to home locations
    80003e76:	4501                	li	a0,0
    80003e78:	d1dff0ef          	jal	80003b94 <install_trans>
    log.lh.n = 0;
    80003e7c:	0001e797          	auipc	a5,0x1e
    80003e80:	5607ac23          	sw	zero,1400(a5) # 800223f4 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003e84:	cb3ff0ef          	jal	80003b36 <write_head>
    80003e88:	69e2                	ld	s3,24(sp)
    80003e8a:	6a42                	ld	s4,16(sp)
    80003e8c:	6aa2                	ld	s5,8(sp)
    80003e8e:	b70d                	j	80003db0 <end_op+0x42>

0000000080003e90 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003e90:	1101                	addi	sp,sp,-32
    80003e92:	ec06                	sd	ra,24(sp)
    80003e94:	e822                	sd	s0,16(sp)
    80003e96:	e426                	sd	s1,8(sp)
    80003e98:	1000                	addi	s0,sp,32
    80003e9a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003e9c:	0001e517          	auipc	a0,0x1e
    80003ea0:	52c50513          	addi	a0,a0,1324 # 800223c8 <log>
    80003ea4:	d85fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003ea8:	0001e617          	auipc	a2,0x1e
    80003eac:	54c62603          	lw	a2,1356(a2) # 800223f4 <log+0x2c>
    80003eb0:	47f5                	li	a5,29
    80003eb2:	04c7cd63          	blt	a5,a2,80003f0c <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003eb6:	0001e797          	auipc	a5,0x1e
    80003eba:	52e7a783          	lw	a5,1326(a5) # 800223e4 <log+0x1c>
    80003ebe:	04f05d63          	blez	a5,80003f18 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003ec2:	4781                	li	a5,0
    80003ec4:	06c05063          	blez	a2,80003f24 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003ec8:	44cc                	lw	a1,12(s1)
    80003eca:	0001e717          	auipc	a4,0x1e
    80003ece:	52e70713          	addi	a4,a4,1326 # 800223f8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003ed2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003ed4:	4314                	lw	a3,0(a4)
    80003ed6:	04b68763          	beq	a3,a1,80003f24 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003eda:	2785                	addiw	a5,a5,1
    80003edc:	0711                	addi	a4,a4,4
    80003ede:	fef61be3          	bne	a2,a5,80003ed4 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003ee2:	060a                	slli	a2,a2,0x2
    80003ee4:	02060613          	addi	a2,a2,32
    80003ee8:	0001e797          	auipc	a5,0x1e
    80003eec:	4e078793          	addi	a5,a5,1248 # 800223c8 <log>
    80003ef0:	97b2                	add	a5,a5,a2
    80003ef2:	44d8                	lw	a4,12(s1)
    80003ef4:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003ef6:	8526                	mv	a0,s1
    80003ef8:	e67fe0ef          	jal	80002d5e <bpin>
    log.lh.n++;
    80003efc:	0001e717          	auipc	a4,0x1e
    80003f00:	4cc70713          	addi	a4,a4,1228 # 800223c8 <log>
    80003f04:	575c                	lw	a5,44(a4)
    80003f06:	2785                	addiw	a5,a5,1
    80003f08:	d75c                	sw	a5,44(a4)
    80003f0a:	a815                	j	80003f3e <log_write+0xae>
    panic("too big a transaction");
    80003f0c:	00003517          	auipc	a0,0x3
    80003f10:	62450513          	addi	a0,a0,1572 # 80007530 <etext+0x530>
    80003f14:	921fc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    80003f18:	00003517          	auipc	a0,0x3
    80003f1c:	63050513          	addi	a0,a0,1584 # 80007548 <etext+0x548>
    80003f20:	915fc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    80003f24:	00279693          	slli	a3,a5,0x2
    80003f28:	02068693          	addi	a3,a3,32
    80003f2c:	0001e717          	auipc	a4,0x1e
    80003f30:	49c70713          	addi	a4,a4,1180 # 800223c8 <log>
    80003f34:	9736                	add	a4,a4,a3
    80003f36:	44d4                	lw	a3,12(s1)
    80003f38:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80003f3a:	faf60ee3          	beq	a2,a5,80003ef6 <log_write+0x66>
  }
  release(&log.lock);
    80003f3e:	0001e517          	auipc	a0,0x1e
    80003f42:	48a50513          	addi	a0,a0,1162 # 800223c8 <log>
    80003f46:	d6bfc0ef          	jal	80000cb0 <release>
}
    80003f4a:	60e2                	ld	ra,24(sp)
    80003f4c:	6442                	ld	s0,16(sp)
    80003f4e:	64a2                	ld	s1,8(sp)
    80003f50:	6105                	addi	sp,sp,32
    80003f52:	8082                	ret

0000000080003f54 <sys_sync>:

uint64
sys_sync(void)
{
    80003f54:	1101                	addi	sp,sp,-32
    80003f56:	ec06                	sd	ra,24(sp)
    80003f58:	e822                	sd	s0,16(sp)
    80003f5a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003f5c:	0001e517          	auipc	a0,0x1e
    80003f60:	46c50513          	addi	a0,a0,1132 # 800223c8 <log>
    80003f64:	cc5fc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    80003f68:	0001e797          	auipc	a5,0x1e
    80003f6c:	4807a783          	lw	a5,1152(a5) # 800223e8 <log+0x20>
    80003f70:	e799                	bnez	a5,80003f7e <sys_sync+0x2a>
    80003f72:	0001e797          	auipc	a5,0x1e
    80003f76:	4727a783          	lw	a5,1138(a5) # 800223e4 <log+0x1c>
    80003f7a:	02f05c63          	blez	a5,80003fb2 <sys_sync+0x5e>
    80003f7e:	e426                	sd	s1,8(sp)
    80003f80:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80003f82:	0001e917          	auipc	s2,0x1e
    80003f86:	46e92903          	lw	s2,1134(s2) # 800223f0 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80003f8a:	0001e497          	auipc	s1,0x1e
    80003f8e:	43e48493          	addi	s1,s1,1086 # 800223c8 <log>
    80003f92:	8526                	mv	a0,s1
    80003f94:	fbffd0ef          	jal	80001f52 <sleep_prepare>
      release(&log.lock);
    80003f98:	8526                	mv	a0,s1
    80003f9a:	d17fc0ef          	jal	80000cb0 <release>
      sleep();
    80003f9e:	ff1fd0ef          	jal	80001f8e <sleep>
      acquire(&log.lock);
    80003fa2:	8526                	mv	a0,s1
    80003fa4:	c85fc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    80003fa8:	549c                	lw	a5,40(s1)
    80003faa:	fef954e3          	bge	s2,a5,80003f92 <sys_sync+0x3e>
    80003fae:	64a2                	ld	s1,8(sp)
    80003fb0:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80003fb2:	0001e517          	auipc	a0,0x1e
    80003fb6:	41650513          	addi	a0,a0,1046 # 800223c8 <log>
    80003fba:	cf7fc0ef          	jal	80000cb0 <release>
  return 0;
}
    80003fbe:	4501                	li	a0,0
    80003fc0:	60e2                	ld	ra,24(sp)
    80003fc2:	6442                	ld	s0,16(sp)
    80003fc4:	6105                	addi	sp,sp,32
    80003fc6:	8082                	ret

0000000080003fc8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003fc8:	1101                	addi	sp,sp,-32
    80003fca:	ec06                	sd	ra,24(sp)
    80003fcc:	e822                	sd	s0,16(sp)
    80003fce:	e426                	sd	s1,8(sp)
    80003fd0:	e04a                	sd	s2,0(sp)
    80003fd2:	1000                	addi	s0,sp,32
    80003fd4:	84aa                	mv	s1,a0
    80003fd6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003fd8:	00003597          	auipc	a1,0x3
    80003fdc:	59058593          	addi	a1,a1,1424 # 80007568 <etext+0x568>
    80003fe0:	0521                	addi	a0,a0,8
    80003fe2:	bc7fc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    80003fe6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003fea:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003fee:	0204a423          	sw	zero,40(s1)
}
    80003ff2:	60e2                	ld	ra,24(sp)
    80003ff4:	6442                	ld	s0,16(sp)
    80003ff6:	64a2                	ld	s1,8(sp)
    80003ff8:	6902                	ld	s2,0(sp)
    80003ffa:	6105                	addi	sp,sp,32
    80003ffc:	8082                	ret

0000000080003ffe <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003ffe:	1101                	addi	sp,sp,-32
    80004000:	ec06                	sd	ra,24(sp)
    80004002:	e822                	sd	s0,16(sp)
    80004004:	e426                	sd	s1,8(sp)
    80004006:	e04a                	sd	s2,0(sp)
    80004008:	1000                	addi	s0,sp,32
    8000400a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000400c:	00850913          	addi	s2,a0,8
    80004010:	854a                	mv	a0,s2
    80004012:	c17fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004016:	409c                	lw	a5,0(s1)
    80004018:	cf91                	beqz	a5,80004034 <acquiresleep+0x36>
    sleep_prepare(lk);
    8000401a:	8526                	mv	a0,s1
    8000401c:	f37fd0ef          	jal	80001f52 <sleep_prepare>
    release(&lk->lk);
    80004020:	854a                	mv	a0,s2
    80004022:	c8ffc0ef          	jal	80000cb0 <release>
    sleep();
    80004026:	f69fd0ef          	jal	80001f8e <sleep>
    acquire(&lk->lk);
    8000402a:	854a                	mv	a0,s2
    8000402c:	bfdfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004030:	409c                	lw	a5,0(s1)
    80004032:	f7e5                	bnez	a5,8000401a <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004034:	4785                	li	a5,1
    80004036:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004038:	911fd0ef          	jal	80001948 <myproc>
    8000403c:	591c                	lw	a5,48(a0)
    8000403e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004040:	854a                	mv	a0,s2
    80004042:	c6ffc0ef          	jal	80000cb0 <release>
}
    80004046:	60e2                	ld	ra,24(sp)
    80004048:	6442                	ld	s0,16(sp)
    8000404a:	64a2                	ld	s1,8(sp)
    8000404c:	6902                	ld	s2,0(sp)
    8000404e:	6105                	addi	sp,sp,32
    80004050:	8082                	ret

0000000080004052 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004052:	1101                	addi	sp,sp,-32
    80004054:	ec06                	sd	ra,24(sp)
    80004056:	e822                	sd	s0,16(sp)
    80004058:	e426                	sd	s1,8(sp)
    8000405a:	e04a                	sd	s2,0(sp)
    8000405c:	1000                	addi	s0,sp,32
    8000405e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004060:	00850913          	addi	s2,a0,8
    80004064:	854a                	mv	a0,s2
    80004066:	bc3fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    8000406a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000406e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004072:	8526                	mv	a0,s1
    80004074:	f4bfd0ef          	jal	80001fbe <wakeup>
  release(&lk->lk);
    80004078:	854a                	mv	a0,s2
    8000407a:	c37fc0ef          	jal	80000cb0 <release>
}
    8000407e:	60e2                	ld	ra,24(sp)
    80004080:	6442                	ld	s0,16(sp)
    80004082:	64a2                	ld	s1,8(sp)
    80004084:	6902                	ld	s2,0(sp)
    80004086:	6105                	addi	sp,sp,32
    80004088:	8082                	ret

000000008000408a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000408a:	7179                	addi	sp,sp,-48
    8000408c:	f406                	sd	ra,40(sp)
    8000408e:	f022                	sd	s0,32(sp)
    80004090:	ec26                	sd	s1,24(sp)
    80004092:	e84a                	sd	s2,16(sp)
    80004094:	1800                	addi	s0,sp,48
    80004096:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80004098:	00850913          	addi	s2,a0,8
    8000409c:	854a                	mv	a0,s2
    8000409e:	b8bfc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800040a2:	409c                	lw	a5,0(s1)
    800040a4:	ef81                	bnez	a5,800040bc <holdingsleep+0x32>
    800040a6:	4481                	li	s1,0
  release(&lk->lk);
    800040a8:	854a                	mv	a0,s2
    800040aa:	c07fc0ef          	jal	80000cb0 <release>
  return r;
}
    800040ae:	8526                	mv	a0,s1
    800040b0:	70a2                	ld	ra,40(sp)
    800040b2:	7402                	ld	s0,32(sp)
    800040b4:	64e2                	ld	s1,24(sp)
    800040b6:	6942                	ld	s2,16(sp)
    800040b8:	6145                	addi	sp,sp,48
    800040ba:	8082                	ret
    800040bc:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800040be:	0284a983          	lw	s3,40(s1)
    800040c2:	887fd0ef          	jal	80001948 <myproc>
    800040c6:	5904                	lw	s1,48(a0)
    800040c8:	413484b3          	sub	s1,s1,s3
    800040cc:	0014b493          	seqz	s1,s1
    800040d0:	69a2                	ld	s3,8(sp)
    800040d2:	bfd9                	j	800040a8 <holdingsleep+0x1e>

00000000800040d4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800040d4:	1141                	addi	sp,sp,-16
    800040d6:	e406                	sd	ra,8(sp)
    800040d8:	e022                	sd	s0,0(sp)
    800040da:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800040dc:	00003597          	auipc	a1,0x3
    800040e0:	49c58593          	addi	a1,a1,1180 # 80007578 <etext+0x578>
    800040e4:	0001e517          	auipc	a0,0x1e
    800040e8:	42c50513          	addi	a0,a0,1068 # 80022510 <ftable>
    800040ec:	abdfc0ef          	jal	80000ba8 <initlock>
}
    800040f0:	60a2                	ld	ra,8(sp)
    800040f2:	6402                	ld	s0,0(sp)
    800040f4:	0141                	addi	sp,sp,16
    800040f6:	8082                	ret

00000000800040f8 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800040f8:	1101                	addi	sp,sp,-32
    800040fa:	ec06                	sd	ra,24(sp)
    800040fc:	e822                	sd	s0,16(sp)
    800040fe:	e426                	sd	s1,8(sp)
    80004100:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004102:	0001e517          	auipc	a0,0x1e
    80004106:	40e50513          	addi	a0,a0,1038 # 80022510 <ftable>
    8000410a:	b1ffc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    8000410e:	0001e497          	auipc	s1,0x1e
    80004112:	41a48493          	addi	s1,s1,1050 # 80022528 <ftable+0x18>
    80004116:	0001f717          	auipc	a4,0x1f
    8000411a:	3b270713          	addi	a4,a4,946 # 800234c8 <disk>
    if (f->ref == 0) {
    8000411e:	40dc                	lw	a5,4(s1)
    80004120:	cf89                	beqz	a5,8000413a <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004122:	02848493          	addi	s1,s1,40
    80004126:	fee49ce3          	bne	s1,a4,8000411e <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000412a:	0001e517          	auipc	a0,0x1e
    8000412e:	3e650513          	addi	a0,a0,998 # 80022510 <ftable>
    80004132:	b7ffc0ef          	jal	80000cb0 <release>
  return 0;
    80004136:	4481                	li	s1,0
    80004138:	a809                	j	8000414a <filealloc+0x52>
      f->ref = 1;
    8000413a:	4785                	li	a5,1
    8000413c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000413e:	0001e517          	auipc	a0,0x1e
    80004142:	3d250513          	addi	a0,a0,978 # 80022510 <ftable>
    80004146:	b6bfc0ef          	jal	80000cb0 <release>
}
    8000414a:	8526                	mv	a0,s1
    8000414c:	60e2                	ld	ra,24(sp)
    8000414e:	6442                	ld	s0,16(sp)
    80004150:	64a2                	ld	s1,8(sp)
    80004152:	6105                	addi	sp,sp,32
    80004154:	8082                	ret

0000000080004156 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004156:	1101                	addi	sp,sp,-32
    80004158:	ec06                	sd	ra,24(sp)
    8000415a:	e822                	sd	s0,16(sp)
    8000415c:	e426                	sd	s1,8(sp)
    8000415e:	1000                	addi	s0,sp,32
    80004160:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004162:	0001e517          	auipc	a0,0x1e
    80004166:	3ae50513          	addi	a0,a0,942 # 80022510 <ftable>
    8000416a:	abffc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    8000416e:	40dc                	lw	a5,4(s1)
    80004170:	02f05063          	blez	a5,80004190 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004174:	2785                	addiw	a5,a5,1
    80004176:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004178:	0001e517          	auipc	a0,0x1e
    8000417c:	39850513          	addi	a0,a0,920 # 80022510 <ftable>
    80004180:	b31fc0ef          	jal	80000cb0 <release>
  return f;
}
    80004184:	8526                	mv	a0,s1
    80004186:	60e2                	ld	ra,24(sp)
    80004188:	6442                	ld	s0,16(sp)
    8000418a:	64a2                	ld	s1,8(sp)
    8000418c:	6105                	addi	sp,sp,32
    8000418e:	8082                	ret
    panic("filedup");
    80004190:	00003517          	auipc	a0,0x3
    80004194:	3f050513          	addi	a0,a0,1008 # 80007580 <etext+0x580>
    80004198:	e9cfc0ef          	jal	80000834 <panic>

000000008000419c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000419c:	7139                	addi	sp,sp,-64
    8000419e:	fc06                	sd	ra,56(sp)
    800041a0:	f822                	sd	s0,48(sp)
    800041a2:	f426                	sd	s1,40(sp)
    800041a4:	0080                	addi	s0,sp,64
    800041a6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800041a8:	0001e517          	auipc	a0,0x1e
    800041ac:	36850513          	addi	a0,a0,872 # 80022510 <ftable>
    800041b0:	a79fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800041b4:	40dc                	lw	a5,4(s1)
    800041b6:	04f05a63          	blez	a5,8000420a <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    800041ba:	37fd                	addiw	a5,a5,-1
    800041bc:	c0dc                	sw	a5,4(s1)
    800041be:	06f04063          	bgtz	a5,8000421e <fileclose+0x82>
    800041c2:	f04a                	sd	s2,32(sp)
    800041c4:	ec4e                	sd	s3,24(sp)
    800041c6:	e852                	sd	s4,16(sp)
    800041c8:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800041ca:	0004a903          	lw	s2,0(s1)
    800041ce:	0094c783          	lbu	a5,9(s1)
    800041d2:	89be                	mv	s3,a5
    800041d4:	689c                	ld	a5,16(s1)
    800041d6:	8a3e                	mv	s4,a5
    800041d8:	6c9c                	ld	a5,24(s1)
    800041da:	8abe                	mv	s5,a5
  f->ref = 0;
    800041dc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800041e0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800041e4:	0001e517          	auipc	a0,0x1e
    800041e8:	32c50513          	addi	a0,a0,812 # 80022510 <ftable>
    800041ec:	ac5fc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    800041f0:	4785                	li	a5,1
    800041f2:	04f90163          	beq	s2,a5,80004234 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    800041f6:	ffe9079b          	addiw	a5,s2,-2
    800041fa:	4705                	li	a4,1
    800041fc:	04f77563          	bgeu	a4,a5,80004246 <fileclose+0xaa>
    80004200:	7902                	ld	s2,32(sp)
    80004202:	69e2                	ld	s3,24(sp)
    80004204:	6a42                	ld	s4,16(sp)
    80004206:	6aa2                	ld	s5,8(sp)
    80004208:	a00d                	j	8000422a <fileclose+0x8e>
    8000420a:	f04a                	sd	s2,32(sp)
    8000420c:	ec4e                	sd	s3,24(sp)
    8000420e:	e852                	sd	s4,16(sp)
    80004210:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004212:	00003517          	auipc	a0,0x3
    80004216:	37650513          	addi	a0,a0,886 # 80007588 <etext+0x588>
    8000421a:	e1afc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    8000421e:	0001e517          	auipc	a0,0x1e
    80004222:	2f250513          	addi	a0,a0,754 # 80022510 <ftable>
    80004226:	a8bfc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000422a:	70e2                	ld	ra,56(sp)
    8000422c:	7442                	ld	s0,48(sp)
    8000422e:	74a2                	ld	s1,40(sp)
    80004230:	6121                	addi	sp,sp,64
    80004232:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004234:	85ce                	mv	a1,s3
    80004236:	8552                	mv	a0,s4
    80004238:	36a000ef          	jal	800045a2 <pipeclose>
    8000423c:	7902                	ld	s2,32(sp)
    8000423e:	69e2                	ld	s3,24(sp)
    80004240:	6a42                	ld	s4,16(sp)
    80004242:	6aa2                	ld	s5,8(sp)
    80004244:	b7dd                	j	8000422a <fileclose+0x8e>
    begin_op();
    80004246:	a9dff0ef          	jal	80003ce2 <begin_op>
    iput(ff.ip);
    8000424a:	8556                	mv	a0,s5
    8000424c:	9a0ff0ef          	jal	800033ec <iput>
    end_op();
    80004250:	b1fff0ef          	jal	80003d6e <end_op>
    80004254:	7902                	ld	s2,32(sp)
    80004256:	69e2                	ld	s3,24(sp)
    80004258:	6a42                	ld	s4,16(sp)
    8000425a:	6aa2                	ld	s5,8(sp)
    8000425c:	b7f9                	j	8000422a <fileclose+0x8e>

000000008000425e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000425e:	715d                	addi	sp,sp,-80
    80004260:	e486                	sd	ra,72(sp)
    80004262:	e0a2                	sd	s0,64(sp)
    80004264:	fc26                	sd	s1,56(sp)
    80004266:	f052                	sd	s4,32(sp)
    80004268:	0880                	addi	s0,sp,80
    8000426a:	84aa                	mv	s1,a0
    8000426c:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000426e:	edafd0ef          	jal	80001948 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004272:	409c                	lw	a5,0(s1)
    80004274:	37f9                	addiw	a5,a5,-2
    80004276:	4705                	li	a4,1
    80004278:	04f76963          	bltu	a4,a5,800042ca <filestat+0x6c>
    8000427c:	f84a                	sd	s2,48(sp)
    8000427e:	f44e                	sd	s3,40(sp)
    80004280:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    80004282:	fb840993          	addi	s3,s0,-72
    80004286:	4661                	li	a2,24
    80004288:	4581                	li	a1,0
    8000428a:	854e                	mv	a0,s3
    8000428c:	a5dfc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    80004290:	6c88                	ld	a0,24(s1)
    80004292:	fd9fe0ef          	jal	8000326a <ilock>
    stati(f->ip, &st);
    80004296:	85ce                	mv	a1,s3
    80004298:	6c88                	ld	a0,24(s1)
    8000429a:	b7cff0ef          	jal	80003616 <stati>
    iunlock(f->ip);
    8000429e:	6c88                	ld	a0,24(s1)
    800042a0:	878ff0ef          	jal	80003318 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    800042a4:	4761                	li	a4,24
    800042a6:	86ce                	mv	a3,s3
    800042a8:	8652                	mv	a2,s4
    800042aa:	04893583          	ld	a1,72(s2)
    800042ae:	05093503          	ld	a0,80(s2)
    800042b2:	ad0fd0ef          	jal	80001582 <copyout>
    800042b6:	41f5551b          	sraiw	a0,a0,0x1f
    800042ba:	7942                	ld	s2,48(sp)
    800042bc:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800042be:	60a6                	ld	ra,72(sp)
    800042c0:	6406                	ld	s0,64(sp)
    800042c2:	74e2                	ld	s1,56(sp)
    800042c4:	7a02                	ld	s4,32(sp)
    800042c6:	6161                	addi	sp,sp,80
    800042c8:	8082                	ret
  return -1;
    800042ca:	557d                	li	a0,-1
    800042cc:	bfcd                	j	800042be <filestat+0x60>

00000000800042ce <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800042ce:	7179                	addi	sp,sp,-48
    800042d0:	f406                	sd	ra,40(sp)
    800042d2:	f022                	sd	s0,32(sp)
    800042d4:	e84a                	sd	s2,16(sp)
    800042d6:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    800042d8:	00854783          	lbu	a5,8(a0)
    800042dc:	c3dd                	beqz	a5,80004382 <fileread+0xb4>
    800042de:	ec26                	sd	s1,24(sp)
    800042e0:	e44e                	sd	s3,8(sp)
    800042e2:	84aa                	mv	s1,a0
    800042e4:	892e                	mv	s2,a1
    800042e6:	89b2                	mv	s3,a2
    800042e8:	01f6579b          	srliw	a5,a2,0x1f
    800042ec:	ebc9                	bnez	a5,8000437e <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    800042ee:	411c                	lw	a5,0(a0)
    800042f0:	4705                	li	a4,1
    800042f2:	04e78363          	beq	a5,a4,80004338 <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800042f6:	470d                	li	a4,3
    800042f8:	04e78763          	beq	a5,a4,80004346 <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    800042fc:	4709                	li	a4,2
    800042fe:	06e79a63          	bne	a5,a4,80004372 <fileread+0xa4>
    ilock(f->ip);
    80004302:	6d08                	ld	a0,24(a0)
    80004304:	f67fe0ef          	jal	8000326a <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004308:	874e                	mv	a4,s3
    8000430a:	5094                	lw	a3,32(s1)
    8000430c:	864a                	mv	a2,s2
    8000430e:	4585                	li	a1,1
    80004310:	6c88                	ld	a0,24(s1)
    80004312:	b32ff0ef          	jal	80003644 <readi>
    80004316:	892a                	mv	s2,a0
    80004318:	00a05563          	blez	a0,80004322 <fileread+0x54>
      f->off += r;
    8000431c:	509c                	lw	a5,32(s1)
    8000431e:	9fa9                	addw	a5,a5,a0
    80004320:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004322:	6c88                	ld	a0,24(s1)
    80004324:	ff5fe0ef          	jal	80003318 <iunlock>
    80004328:	64e2                	ld	s1,24(sp)
    8000432a:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000432c:	854a                	mv	a0,s2
    8000432e:	70a2                	ld	ra,40(sp)
    80004330:	7402                	ld	s0,32(sp)
    80004332:	6942                	ld	s2,16(sp)
    80004334:	6145                	addi	sp,sp,48
    80004336:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004338:	6908                	ld	a0,16(a0)
    8000433a:	3e2000ef          	jal	8000471c <piperead>
    8000433e:	892a                	mv	s2,a0
    80004340:	64e2                	ld	s1,24(sp)
    80004342:	69a2                	ld	s3,8(sp)
    80004344:	b7e5                	j	8000432c <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004346:	02451783          	lh	a5,36(a0)
    8000434a:	03079693          	slli	a3,a5,0x30
    8000434e:	92c1                	srli	a3,a3,0x30
    80004350:	4725                	li	a4,9
    80004352:	02d76b63          	bltu	a4,a3,80004388 <fileread+0xba>
    80004356:	0792                	slli	a5,a5,0x4
    80004358:	0001e717          	auipc	a4,0x1e
    8000435c:	11870713          	addi	a4,a4,280 # 80022470 <devsw>
    80004360:	97ba                	add	a5,a5,a4
    80004362:	639c                	ld	a5,0(a5)
    80004364:	c79d                	beqz	a5,80004392 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    80004366:	4505                	li	a0,1
    80004368:	9782                	jalr	a5
    8000436a:	892a                	mv	s2,a0
    8000436c:	64e2                	ld	s1,24(sp)
    8000436e:	69a2                	ld	s3,8(sp)
    80004370:	bf75                	j	8000432c <fileread+0x5e>
    panic("fileread");
    80004372:	00003517          	auipc	a0,0x3
    80004376:	22650513          	addi	a0,a0,550 # 80007598 <etext+0x598>
    8000437a:	cbafc0ef          	jal	80000834 <panic>
    8000437e:	64e2                	ld	s1,24(sp)
    80004380:	69a2                	ld	s3,8(sp)
    return -1;
    80004382:	57fd                	li	a5,-1
    80004384:	893e                	mv	s2,a5
    80004386:	b75d                	j	8000432c <fileread+0x5e>
      return -1;
    80004388:	57fd                	li	a5,-1
    8000438a:	893e                	mv	s2,a5
    8000438c:	64e2                	ld	s1,24(sp)
    8000438e:	69a2                	ld	s3,8(sp)
    80004390:	bf71                	j	8000432c <fileread+0x5e>
    80004392:	57fd                	li	a5,-1
    80004394:	893e                	mv	s2,a5
    80004396:	64e2                	ld	s1,24(sp)
    80004398:	69a2                	ld	s3,8(sp)
    8000439a:	bf49                	j	8000432c <fileread+0x5e>

000000008000439c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    8000439c:	00954783          	lbu	a5,9(a0)
    800043a0:	12078b63          	beqz	a5,800044d6 <filewrite+0x13a>
{
    800043a4:	711d                	addi	sp,sp,-96
    800043a6:	ec86                	sd	ra,88(sp)
    800043a8:	e8a2                	sd	s0,80(sp)
    800043aa:	e0ca                	sd	s2,64(sp)
    800043ac:	f456                	sd	s5,40(sp)
    800043ae:	f05a                	sd	s6,32(sp)
    800043b0:	1080                	addi	s0,sp,96
    800043b2:	892a                	mv	s2,a0
    800043b4:	8b2e                	mv	s6,a1
    800043b6:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    800043b8:	01f6579b          	srliw	a5,a2,0x1f
    800043bc:	0e079d63          	bnez	a5,800044b6 <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    800043c0:	411c                	lw	a5,0(a0)
    800043c2:	4705                	li	a4,1
    800043c4:	02e78a63          	beq	a5,a4,800043f8 <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800043c8:	470d                	li	a4,3
    800043ca:	02e78b63          	beq	a5,a4,80004400 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    800043ce:	4709                	li	a4,2
    800043d0:	0ce79763          	bne	a5,a4,8000449e <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    800043d4:	0ec05763          	blez	a2,800044c2 <filewrite+0x126>
    800043d8:	e4a6                	sd	s1,72(sp)
    800043da:	fc4e                	sd	s3,56(sp)
    800043dc:	f852                	sd	s4,48(sp)
    800043de:	ec5e                	sd	s7,24(sp)
    800043e0:	e862                	sd	s8,16(sp)
    800043e2:	e466                	sd	s9,8(sp)
    int i = 0;
    800043e4:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    800043e6:	6b85                	lui	s7,0x1
    800043e8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800043ec:	6785                	lui	a5,0x1
    800043ee:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800043f2:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800043f4:	4c05                	li	s8,1
    800043f6:	a8ad                	j	80004470 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    800043f8:	6908                	ld	a0,16(a0)
    800043fa:	206000ef          	jal	80004600 <pipewrite>
    800043fe:	a849                	j	80004490 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004400:	02451783          	lh	a5,36(a0)
    80004404:	03079693          	slli	a3,a5,0x30
    80004408:	92c1                	srli	a3,a3,0x30
    8000440a:	4725                	li	a4,9
    8000440c:	0ad76763          	bltu	a4,a3,800044ba <filewrite+0x11e>
    80004410:	0792                	slli	a5,a5,0x4
    80004412:	0001e717          	auipc	a4,0x1e
    80004416:	05e70713          	addi	a4,a4,94 # 80022470 <devsw>
    8000441a:	97ba                	add	a5,a5,a4
    8000441c:	679c                	ld	a5,8(a5)
    8000441e:	c3c5                	beqz	a5,800044be <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004420:	4505                	li	a0,1
    80004422:	9782                	jalr	a5
    80004424:	a0b5                	j	80004490 <filewrite+0xf4>
      if (n1 > max)
    80004426:	2981                	sext.w	s3,s3
      begin_op();
    80004428:	8bbff0ef          	jal	80003ce2 <begin_op>
      ilock(f->ip);
    8000442c:	01893503          	ld	a0,24(s2)
    80004430:	e3bfe0ef          	jal	8000326a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004434:	874e                	mv	a4,s3
    80004436:	02092683          	lw	a3,32(s2)
    8000443a:	016a0633          	add	a2,s4,s6
    8000443e:	85e2                	mv	a1,s8
    80004440:	01893503          	ld	a0,24(s2)
    80004444:	af2ff0ef          	jal	80003736 <writei>
    80004448:	84aa                	mv	s1,a0
    8000444a:	00a05763          	blez	a0,80004458 <filewrite+0xbc>
        f->off += r;
    8000444e:	02092783          	lw	a5,32(s2)
    80004452:	9fa9                	addw	a5,a5,a0
    80004454:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004458:	01893503          	ld	a0,24(s2)
    8000445c:	ebdfe0ef          	jal	80003318 <iunlock>
      end_op();
    80004460:	90fff0ef          	jal	80003d6e <end_op>

      if (r != n1) {
    80004464:	00999d63          	bne	s3,s1,8000447e <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    80004468:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    8000446c:	015a5963          	bge	s4,s5,8000447e <filewrite+0xe2>
      int n1 = n - i;
    80004470:	414a87bb          	subw	a5,s5,s4
    80004474:	89be                	mv	s3,a5
      if (n1 > max)
    80004476:	fafbd8e3          	bge	s7,a5,80004426 <filewrite+0x8a>
    8000447a:	89e6                	mv	s3,s9
    8000447c:	b76d                	j	80004426 <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    8000447e:	054a9463          	bne	s5,s4,800044c6 <filewrite+0x12a>
    80004482:	8556                	mv	a0,s5
    80004484:	64a6                	ld	s1,72(sp)
    80004486:	79e2                	ld	s3,56(sp)
    80004488:	7a42                	ld	s4,48(sp)
    8000448a:	6be2                	ld	s7,24(sp)
    8000448c:	6c42                	ld	s8,16(sp)
    8000448e:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004490:	60e6                	ld	ra,88(sp)
    80004492:	6446                	ld	s0,80(sp)
    80004494:	6906                	ld	s2,64(sp)
    80004496:	7aa2                	ld	s5,40(sp)
    80004498:	7b02                	ld	s6,32(sp)
    8000449a:	6125                	addi	sp,sp,96
    8000449c:	8082                	ret
    8000449e:	e4a6                	sd	s1,72(sp)
    800044a0:	fc4e                	sd	s3,56(sp)
    800044a2:	f852                	sd	s4,48(sp)
    800044a4:	ec5e                	sd	s7,24(sp)
    800044a6:	e862                	sd	s8,16(sp)
    800044a8:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800044aa:	00003517          	auipc	a0,0x3
    800044ae:	0fe50513          	addi	a0,a0,254 # 800075a8 <etext+0x5a8>
    800044b2:	b82fc0ef          	jal	80000834 <panic>
    return -1;
    800044b6:	557d                	li	a0,-1
    800044b8:	bfe1                	j	80004490 <filewrite+0xf4>
      return -1;
    800044ba:	557d                	li	a0,-1
    800044bc:	bfd1                	j	80004490 <filewrite+0xf4>
    800044be:	557d                	li	a0,-1
    800044c0:	bfc1                	j	80004490 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    800044c2:	8532                	mv	a0,a2
    800044c4:	b7f1                	j	80004490 <filewrite+0xf4>
    800044c6:	557d                	li	a0,-1
    800044c8:	64a6                	ld	s1,72(sp)
    800044ca:	79e2                	ld	s3,56(sp)
    800044cc:	7a42                	ld	s4,48(sp)
    800044ce:	6be2                	ld	s7,24(sp)
    800044d0:	6c42                	ld	s8,16(sp)
    800044d2:	6ca2                	ld	s9,8(sp)
    800044d4:	bf75                	j	80004490 <filewrite+0xf4>
    return -1;
    800044d6:	557d                	li	a0,-1
}
    800044d8:	8082                	ret

00000000800044da <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800044da:	7179                	addi	sp,sp,-48
    800044dc:	f406                	sd	ra,40(sp)
    800044de:	f022                	sd	s0,32(sp)
    800044e0:	ec26                	sd	s1,24(sp)
    800044e2:	e052                	sd	s4,0(sp)
    800044e4:	1800                	addi	s0,sp,48
    800044e6:	84aa                	mv	s1,a0
    800044e8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800044ea:	0005b023          	sd	zero,0(a1)
    800044ee:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800044f2:	c07ff0ef          	jal	800040f8 <filealloc>
    800044f6:	e088                	sd	a0,0(s1)
    800044f8:	c549                	beqz	a0,80004582 <pipealloc+0xa8>
    800044fa:	bffff0ef          	jal	800040f8 <filealloc>
    800044fe:	00aa3023          	sd	a0,0(s4)
    80004502:	cd25                	beqz	a0,8000457a <pipealloc+0xa0>
    80004504:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004506:	e48fc0ef          	jal	80000b4e <kalloc>
    8000450a:	892a                	mv	s2,a0
    8000450c:	c12d                	beqz	a0,8000456e <pipealloc+0x94>
    8000450e:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004510:	4985                	li	s3,1
    80004512:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004516:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000451a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000451e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004522:	00003597          	auipc	a1,0x3
    80004526:	09658593          	addi	a1,a1,150 # 800075b8 <etext+0x5b8>
    8000452a:	e7efc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    8000452e:	609c                	ld	a5,0(s1)
    80004530:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004534:	609c                	ld	a5,0(s1)
    80004536:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000453a:	609c                	ld	a5,0(s1)
    8000453c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004540:	609c                	ld	a5,0(s1)
    80004542:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004546:	000a3783          	ld	a5,0(s4)
    8000454a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000454e:	000a3783          	ld	a5,0(s4)
    80004552:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004556:	000a3783          	ld	a5,0(s4)
    8000455a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000455e:	000a3783          	ld	a5,0(s4)
    80004562:	0127b823          	sd	s2,16(a5)
  return 0;
    80004566:	4501                	li	a0,0
    80004568:	6942                	ld	s2,16(sp)
    8000456a:	69a2                	ld	s3,8(sp)
    8000456c:	a01d                	j	80004592 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    8000456e:	6088                	ld	a0,0(s1)
    80004570:	c119                	beqz	a0,80004576 <pipealloc+0x9c>
    80004572:	6942                	ld	s2,16(sp)
    80004574:	a029                	j	8000457e <pipealloc+0xa4>
    80004576:	6942                	ld	s2,16(sp)
    80004578:	a029                	j	80004582 <pipealloc+0xa8>
    8000457a:	6088                	ld	a0,0(s1)
    8000457c:	c10d                	beqz	a0,8000459e <pipealloc+0xc4>
    fileclose(*f0);
    8000457e:	c1fff0ef          	jal	8000419c <fileclose>
  if (*f1)
    80004582:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004586:	557d                	li	a0,-1
  if (*f1)
    80004588:	c789                	beqz	a5,80004592 <pipealloc+0xb8>
    fileclose(*f1);
    8000458a:	853e                	mv	a0,a5
    8000458c:	c11ff0ef          	jal	8000419c <fileclose>
  return -1;
    80004590:	557d                	li	a0,-1
}
    80004592:	70a2                	ld	ra,40(sp)
    80004594:	7402                	ld	s0,32(sp)
    80004596:	64e2                	ld	s1,24(sp)
    80004598:	6a02                	ld	s4,0(sp)
    8000459a:	6145                	addi	sp,sp,48
    8000459c:	8082                	ret
  return -1;
    8000459e:	557d                	li	a0,-1
    800045a0:	bfcd                	j	80004592 <pipealloc+0xb8>

00000000800045a2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800045a2:	1101                	addi	sp,sp,-32
    800045a4:	ec06                	sd	ra,24(sp)
    800045a6:	e822                	sd	s0,16(sp)
    800045a8:	e426                	sd	s1,8(sp)
    800045aa:	e04a                	sd	s2,0(sp)
    800045ac:	1000                	addi	s0,sp,32
    800045ae:	84aa                	mv	s1,a0
    800045b0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800045b2:	e76fc0ef          	jal	80000c28 <acquire>
  if (writable) {
    800045b6:	02090763          	beqz	s2,800045e4 <pipeclose+0x42>
    pi->writeopen = 0;
    800045ba:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800045be:	21848513          	addi	a0,s1,536
    800045c2:	9fdfd0ef          	jal	80001fbe <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    800045c6:	2204a783          	lw	a5,544(s1)
    800045ca:	e781                	bnez	a5,800045d2 <pipeclose+0x30>
    800045cc:	2244a783          	lw	a5,548(s1)
    800045d0:	c38d                	beqz	a5,800045f2 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    800045d2:	8526                	mv	a0,s1
    800045d4:	edcfc0ef          	jal	80000cb0 <release>
}
    800045d8:	60e2                	ld	ra,24(sp)
    800045da:	6442                	ld	s0,16(sp)
    800045dc:	64a2                	ld	s1,8(sp)
    800045de:	6902                	ld	s2,0(sp)
    800045e0:	6105                	addi	sp,sp,32
    800045e2:	8082                	ret
    pi->readopen = 0;
    800045e4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800045e8:	21c48513          	addi	a0,s1,540
    800045ec:	9d3fd0ef          	jal	80001fbe <wakeup>
    800045f0:	bfd9                	j	800045c6 <pipeclose+0x24>
    release(&pi->lock);
    800045f2:	8526                	mv	a0,s1
    800045f4:	ebcfc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    800045f8:	8526                	mv	a0,s1
    800045fa:	c6cfc0ef          	jal	80000a66 <kfree>
    800045fe:	bfe9                	j	800045d8 <pipeclose+0x36>

0000000080004600 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004600:	7159                	addi	sp,sp,-112
    80004602:	f486                	sd	ra,104(sp)
    80004604:	f0a2                	sd	s0,96(sp)
    80004606:	eca6                	sd	s1,88(sp)
    80004608:	e8ca                	sd	s2,80(sp)
    8000460a:	e4ce                	sd	s3,72(sp)
    8000460c:	e0d2                	sd	s4,64(sp)
    8000460e:	fc56                	sd	s5,56(sp)
    80004610:	1880                	addi	s0,sp,112
    80004612:	84aa                	mv	s1,a0
    80004614:	8aae                	mv	s5,a1
    80004616:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004618:	b30fd0ef          	jal	80001948 <myproc>
    8000461c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000461e:	8526                	mv	a0,s1
    80004620:	e08fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    80004624:	0f405a63          	blez	s4,80004718 <pipewrite+0x118>
    80004628:	f85a                	sd	s6,48(sp)
    8000462a:	f45e                	sd	s7,40(sp)
    8000462c:	f062                	sd	s8,32(sp)
    8000462e:	ec66                	sd	s9,24(sp)
    80004630:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004632:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004634:	f9f40c13          	addi	s8,s0,-97
    80004638:	4b85                	li	s7,1
    8000463a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000463c:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    80004640:	21c48c93          	addi	s9,s1,540
    80004644:	a0a1                	j	8000468c <pipewrite+0x8c>
      release(&pi->lock);
    80004646:	8526                	mv	a0,s1
    80004648:	e68fc0ef          	jal	80000cb0 <release>
      return -1;
    8000464c:	597d                	li	s2,-1
    8000464e:	7b42                	ld	s6,48(sp)
    80004650:	7ba2                	ld	s7,40(sp)
    80004652:	7c02                	ld	s8,32(sp)
    80004654:	6ce2                	ld	s9,24(sp)
    80004656:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004658:	854a                	mv	a0,s2
    8000465a:	70a6                	ld	ra,104(sp)
    8000465c:	7406                	ld	s0,96(sp)
    8000465e:	64e6                	ld	s1,88(sp)
    80004660:	6946                	ld	s2,80(sp)
    80004662:	69a6                	ld	s3,72(sp)
    80004664:	6a06                	ld	s4,64(sp)
    80004666:	7ae2                	ld	s5,56(sp)
    80004668:	6165                	addi	sp,sp,112
    8000466a:	8082                	ret
      wakeup(&pi->nread);
    8000466c:	856a                	mv	a0,s10
    8000466e:	951fd0ef          	jal	80001fbe <wakeup>
      sleep_prepare(&pi->nwrite);
    80004672:	8566                	mv	a0,s9
    80004674:	8dffd0ef          	jal	80001f52 <sleep_prepare>
      release(&pi->lock);
    80004678:	8526                	mv	a0,s1
    8000467a:	e36fc0ef          	jal	80000cb0 <release>
      sleep();
    8000467e:	911fd0ef          	jal	80001f8e <sleep>
      acquire(&pi->lock);
    80004682:	8526                	mv	a0,s1
    80004684:	da4fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    80004688:	07495b63          	bge	s2,s4,800046fe <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    8000468c:	2204a783          	lw	a5,544(s1)
    80004690:	dbdd                	beqz	a5,80004646 <pipewrite+0x46>
    80004692:	854e                	mv	a0,s3
    80004694:	b1dfd0ef          	jal	800021b0 <killed>
    80004698:	f55d                	bnez	a0,80004646 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    8000469a:	2184a783          	lw	a5,536(s1)
    8000469e:	21c4a703          	lw	a4,540(s1)
    800046a2:	2007879b          	addiw	a5,a5,512
    800046a6:	fcf703e3          	beq	a4,a5,8000466c <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800046aa:	875e                	mv	a4,s7
    800046ac:	015906b3          	add	a3,s2,s5
    800046b0:	8662                	mv	a2,s8
    800046b2:	0489b583          	ld	a1,72(s3)
    800046b6:	0509b503          	ld	a0,80(s3)
    800046ba:	f8ffc0ef          	jal	80001648 <copyin>
    800046be:	03650163          	beq	a0,s6,800046e0 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800046c2:	21c4a783          	lw	a5,540(s1)
    800046c6:	0017871b          	addiw	a4,a5,1
    800046ca:	20e4ae23          	sw	a4,540(s1)
    800046ce:	1ff7f793          	andi	a5,a5,511
    800046d2:	97a6                	add	a5,a5,s1
    800046d4:	f9f44703          	lbu	a4,-97(s0)
    800046d8:	00e78c23          	sb	a4,24(a5)
      i++;
    800046dc:	2905                	addiw	s2,s2,1
    800046de:	b76d                	j	80004688 <pipewrite+0x88>
        if (i == 0)
    800046e0:	00090863          	beqz	s2,800046f0 <pipewrite+0xf0>
    800046e4:	7b42                	ld	s6,48(sp)
    800046e6:	7ba2                	ld	s7,40(sp)
    800046e8:	7c02                	ld	s8,32(sp)
    800046ea:	6ce2                	ld	s9,24(sp)
    800046ec:	6d42                	ld	s10,16(sp)
    800046ee:	a829                	j	80004708 <pipewrite+0x108>
          i = -1;
    800046f0:	892a                	mv	s2,a0
        break;
    800046f2:	7b42                	ld	s6,48(sp)
    800046f4:	7ba2                	ld	s7,40(sp)
    800046f6:	7c02                	ld	s8,32(sp)
    800046f8:	6ce2                	ld	s9,24(sp)
    800046fa:	6d42                	ld	s10,16(sp)
    800046fc:	a031                	j	80004708 <pipewrite+0x108>
    800046fe:	7b42                	ld	s6,48(sp)
    80004700:	7ba2                	ld	s7,40(sp)
    80004702:	7c02                	ld	s8,32(sp)
    80004704:	6ce2                	ld	s9,24(sp)
    80004706:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004708:	21848513          	addi	a0,s1,536
    8000470c:	8b3fd0ef          	jal	80001fbe <wakeup>
  release(&pi->lock);
    80004710:	8526                	mv	a0,s1
    80004712:	d9efc0ef          	jal	80000cb0 <release>
  return i;
    80004716:	b789                	j	80004658 <pipewrite+0x58>
  int i = 0;
    80004718:	4901                	li	s2,0
    8000471a:	b7fd                	j	80004708 <pipewrite+0x108>

000000008000471c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000471c:	711d                	addi	sp,sp,-96
    8000471e:	ec86                	sd	ra,88(sp)
    80004720:	e8a2                	sd	s0,80(sp)
    80004722:	e4a6                	sd	s1,72(sp)
    80004724:	e0ca                	sd	s2,64(sp)
    80004726:	fc4e                	sd	s3,56(sp)
    80004728:	f852                	sd	s4,48(sp)
    8000472a:	f456                	sd	s5,40(sp)
    8000472c:	1080                	addi	s0,sp,96
    8000472e:	84aa                	mv	s1,a0
    80004730:	89ae                	mv	s3,a1
    80004732:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004734:	a14fd0ef          	jal	80001948 <myproc>
    80004738:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    8000473a:	8526                	mv	a0,s1
    8000473c:	cecfc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004740:	0d505263          	blez	s5,80004804 <piperead+0xe8>
    80004744:	2184a703          	lw	a4,536(s1)
    80004748:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    8000474c:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004750:	02f71e63          	bne	a4,a5,8000478c <piperead+0x70>
    80004754:	2244a783          	lw	a5,548(s1)
    80004758:	c3b9                	beqz	a5,8000479e <piperead+0x82>
    if (killed(pr)) {
    8000475a:	854a                	mv	a0,s2
    8000475c:	a55fd0ef          	jal	800021b0 <killed>
    80004760:	e915                	bnez	a0,80004794 <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004762:	8552                	mv	a0,s4
    80004764:	feefd0ef          	jal	80001f52 <sleep_prepare>
    release(&pi->lock);
    80004768:	8526                	mv	a0,s1
    8000476a:	d46fc0ef          	jal	80000cb0 <release>
    sleep();
    8000476e:	821fd0ef          	jal	80001f8e <sleep>
    acquire(&pi->lock);
    80004772:	8526                	mv	a0,s1
    80004774:	cb4fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004778:	2184a703          	lw	a4,536(s1)
    8000477c:	21c4a783          	lw	a5,540(s1)
    80004780:	fcf70ae3          	beq	a4,a5,80004754 <piperead+0x38>
    80004784:	f05a                	sd	s6,32(sp)
    80004786:	ec5e                	sd	s7,24(sp)
    80004788:	e862                	sd	s8,16(sp)
    8000478a:	a829                	j	800047a4 <piperead+0x88>
    8000478c:	f05a                	sd	s6,32(sp)
    8000478e:	ec5e                	sd	s7,24(sp)
    80004790:	e862                	sd	s8,16(sp)
    80004792:	a809                	j	800047a4 <piperead+0x88>
      release(&pi->lock);
    80004794:	8526                	mv	a0,s1
    80004796:	d1afc0ef          	jal	80000cb0 <release>
      return -1;
    8000479a:	5a7d                	li	s4,-1
    8000479c:	a8a5                	j	80004814 <piperead+0xf8>
    8000479e:	f05a                	sd	s6,32(sp)
    800047a0:	ec5e                	sd	s7,24(sp)
    800047a2:	e862                	sd	s8,16(sp)
{
    800047a4:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    800047a6:	faf40c13          	addi	s8,s0,-81
    800047aa:	4b85                	li	s7,1
    800047ac:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    800047ae:	2184a783          	lw	a5,536(s1)
    800047b2:	21c4a703          	lw	a4,540(s1)
    800047b6:	06f70e63          	beq	a4,a5,80004832 <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    800047ba:	1ff7f793          	andi	a5,a5,511
    800047be:	97a6                	add	a5,a5,s1
    800047c0:	0187c783          	lbu	a5,24(a5)
    800047c4:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    800047c8:	875e                	mv	a4,s7
    800047ca:	86e2                	mv	a3,s8
    800047cc:	864e                	mv	a2,s3
    800047ce:	04893583          	ld	a1,72(s2)
    800047d2:	05093503          	ld	a0,80(s2)
    800047d6:	dadfc0ef          	jal	80001582 <copyout>
    800047da:	01650f63          	beq	a0,s6,800047f8 <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800047de:	2184a783          	lw	a5,536(s1)
    800047e2:	2785                	addiw	a5,a5,1
    800047e4:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800047e8:	2a05                	addiw	s4,s4,1
    800047ea:	0985                	addi	s3,s3,1
    800047ec:	fd4a91e3          	bne	s5,s4,800047ae <piperead+0x92>
    800047f0:	7b02                	ld	s6,32(sp)
    800047f2:	6be2                	ld	s7,24(sp)
    800047f4:	6c42                	ld	s8,16(sp)
    800047f6:	a801                	j	80004806 <piperead+0xea>
      if (i == 0)
    800047f8:	020a0863          	beqz	s4,80004828 <piperead+0x10c>
    800047fc:	7b02                	ld	s6,32(sp)
    800047fe:	6be2                	ld	s7,24(sp)
    80004800:	6c42                	ld	s8,16(sp)
    80004802:	a011                	j	80004806 <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004804:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004806:	21c48513          	addi	a0,s1,540
    8000480a:	fb4fd0ef          	jal	80001fbe <wakeup>
  release(&pi->lock);
    8000480e:	8526                	mv	a0,s1
    80004810:	ca0fc0ef          	jal	80000cb0 <release>
  return i;
}
    80004814:	8552                	mv	a0,s4
    80004816:	60e6                	ld	ra,88(sp)
    80004818:	6446                	ld	s0,80(sp)
    8000481a:	64a6                	ld	s1,72(sp)
    8000481c:	6906                	ld	s2,64(sp)
    8000481e:	79e2                	ld	s3,56(sp)
    80004820:	7a42                	ld	s4,48(sp)
    80004822:	7aa2                	ld	s5,40(sp)
    80004824:	6125                	addi	sp,sp,96
    80004826:	8082                	ret
        i = -1;
    80004828:	8a2a                	mv	s4,a0
    8000482a:	7b02                	ld	s6,32(sp)
    8000482c:	6be2                	ld	s7,24(sp)
    8000482e:	6c42                	ld	s8,16(sp)
    80004830:	bfd9                	j	80004806 <piperead+0xea>
    80004832:	7b02                	ld	s6,32(sp)
    80004834:	6be2                	ld	s7,24(sp)
    80004836:	6c42                	ld	s8,16(sp)
    80004838:	b7f9                	j	80004806 <piperead+0xea>

000000008000483a <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    8000483a:	1141                	addi	sp,sp,-16
    8000483c:	e406                	sd	ra,8(sp)
    8000483e:	e022                	sd	s0,0(sp)
    80004840:	0800                	addi	s0,sp,16
    80004842:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004844:	0035151b          	slliw	a0,a0,0x3
    80004848:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    8000484a:	8b89                	andi	a5,a5,2
    8000484c:	c399                	beqz	a5,80004852 <flags2perm+0x18>
    perm |= PTE_W;
    8000484e:	00456513          	ori	a0,a0,4
  return perm;
}
    80004852:	60a2                	ld	ra,8(sp)
    80004854:	6402                	ld	s0,0(sp)
    80004856:	0141                	addi	sp,sp,16
    80004858:	8082                	ret

000000008000485a <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000485a:	de010113          	addi	sp,sp,-544
    8000485e:	20113c23          	sd	ra,536(sp)
    80004862:	20813823          	sd	s0,528(sp)
    80004866:	20913423          	sd	s1,520(sp)
    8000486a:	21213023          	sd	s2,512(sp)
    8000486e:	1400                	addi	s0,sp,544
    80004870:	892a                	mv	s2,a0
    80004872:	dea43823          	sd	a0,-528(s0)
    80004876:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000487a:	8cefd0ef          	jal	80001948 <myproc>
    8000487e:	84aa                	mv	s1,a0

  begin_op();
    80004880:	c62ff0ef          	jal	80003ce2 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004884:	854a                	mv	a0,s2
    80004886:	a7eff0ef          	jal	80003b04 <namei>
    8000488a:	cd21                	beqz	a0,800048e2 <kexec+0x88>
    8000488c:	fbd2                	sd	s4,496(sp)
    8000488e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004890:	9dbfe0ef          	jal	8000326a <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004894:	04000713          	li	a4,64
    80004898:	4681                	li	a3,0
    8000489a:	e5040613          	addi	a2,s0,-432
    8000489e:	4581                	li	a1,0
    800048a0:	8552                	mv	a0,s4
    800048a2:	da3fe0ef          	jal	80003644 <readi>
    800048a6:	04000793          	li	a5,64
    800048aa:	00f51a63          	bne	a0,a5,800048be <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    800048ae:	e5042703          	lw	a4,-432(s0)
    800048b2:	464c47b7          	lui	a5,0x464c4
    800048b6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800048ba:	02f70863          	beq	a4,a5,800048ea <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    800048be:	8552                	mv	a0,s4
    800048c0:	bfffe0ef          	jal	800034be <iunlockput>
    end_op();
    800048c4:	caaff0ef          	jal	80003d6e <end_op>
  }
  return -1;
    800048c8:	557d                	li	a0,-1
    800048ca:	7a5e                	ld	s4,496(sp)
}
    800048cc:	21813083          	ld	ra,536(sp)
    800048d0:	21013403          	ld	s0,528(sp)
    800048d4:	20813483          	ld	s1,520(sp)
    800048d8:	20013903          	ld	s2,512(sp)
    800048dc:	22010113          	addi	sp,sp,544
    800048e0:	8082                	ret
    end_op();
    800048e2:	c8cff0ef          	jal	80003d6e <end_op>
    return -1;
    800048e6:	557d                	li	a0,-1
    800048e8:	b7d5                	j	800048cc <kexec+0x72>
    800048ea:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    800048ec:	8526                	mv	a0,s1
    800048ee:	960fd0ef          	jal	80001a4e <proc_pagetable>
    800048f2:	8b2a                	mv	s6,a0
    800048f4:	26050e63          	beqz	a0,80004b70 <kexec+0x316>
    800048f8:	ffce                	sd	s3,504(sp)
    800048fa:	f7d6                	sd	s5,488(sp)
    800048fc:	efde                	sd	s7,472(sp)
    800048fe:	ebe2                	sd	s8,464(sp)
    80004900:	e7e6                	sd	s9,456(sp)
    80004902:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004904:	e8845783          	lhu	a5,-376(s0)
    80004908:	14078263          	beqz	a5,80004a4c <kexec+0x1f2>
    8000490c:	ff6e                	sd	s11,440(sp)
    8000490e:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004912:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004914:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004916:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    8000491a:	6c85                	lui	s9,0x1
    8000491c:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004920:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004924:	6a85                	lui	s5,0x1
    80004926:	a085                	j	80004986 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004928:	00003517          	auipc	a0,0x3
    8000492c:	c9850513          	addi	a0,a0,-872 # 800075c0 <etext+0x5c0>
    80004930:	f05fb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004934:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004936:	874a                	mv	a4,s2
    80004938:	009b86bb          	addw	a3,s7,s1
    8000493c:	4581                	li	a1,0
    8000493e:	8552                	mv	a0,s4
    80004940:	d05fe0ef          	jal	80003644 <readi>
    80004944:	22a91a63          	bne	s2,a0,80004b78 <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004948:	009a84bb          	addw	s1,s5,s1
    8000494c:	0334f263          	bgeu	s1,s3,80004970 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004950:	02049593          	slli	a1,s1,0x20
    80004954:	9181                	srli	a1,a1,0x20
    80004956:	95e2                	add	a1,a1,s8
    80004958:	855a                	mv	a0,s6
    8000495a:	ebefc0ef          	jal	80001018 <walkaddr>
    8000495e:	862a                	mv	a2,a0
    if (pa == 0)
    80004960:	d561                	beqz	a0,80004928 <kexec+0xce>
    if (sz - i < PGSIZE)
    80004962:	409987bb          	subw	a5,s3,s1
    80004966:	893e                	mv	s2,a5
    80004968:	fcfcf6e3          	bgeu	s9,a5,80004934 <kexec+0xda>
    8000496c:	8956                	mv	s2,s5
    8000496e:	b7d9                	j	80004934 <kexec+0xda>
    sz = sz1;
    80004970:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004974:	2d05                	addiw	s10,s10,1
    80004976:	e0843783          	ld	a5,-504(s0)
    8000497a:	0387869b          	addiw	a3,a5,56
    8000497e:	e8845783          	lhu	a5,-376(s0)
    80004982:	06fd5d63          	bge	s10,a5,800049fc <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004986:	e0d43423          	sd	a3,-504(s0)
    8000498a:	876e                	mv	a4,s11
    8000498c:	e1840613          	addi	a2,s0,-488
    80004990:	4581                	li	a1,0
    80004992:	8552                	mv	a0,s4
    80004994:	cb1fe0ef          	jal	80003644 <readi>
    80004998:	1db51e63          	bne	a0,s11,80004b74 <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    8000499c:	e1842783          	lw	a5,-488(s0)
    800049a0:	4705                	li	a4,1
    800049a2:	fce799e3          	bne	a5,a4,80004974 <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    800049a6:	e4043483          	ld	s1,-448(s0)
    800049aa:	e3843783          	ld	a5,-456(s0)
    800049ae:	1ef4e363          	bltu	s1,a5,80004b94 <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    800049b2:	e2843783          	ld	a5,-472(s0)
    800049b6:	94be                	add	s1,s1,a5
    800049b8:	1ef4e163          	bltu	s1,a5,80004b9a <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    800049bc:	de843703          	ld	a4,-536(s0)
    800049c0:	8ff9                	and	a5,a5,a4
    800049c2:	1c079f63          	bnez	a5,80004ba0 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    800049c6:	e1c42503          	lw	a0,-484(s0)
    800049ca:	e71ff0ef          	jal	8000483a <flags2perm>
    800049ce:	86aa                	mv	a3,a0
    800049d0:	8626                	mv	a2,s1
    800049d2:	85ca                	mv	a1,s2
    800049d4:	855a                	mv	a0,s6
    800049d6:	919fc0ef          	jal	800012ee <uvmalloc>
    800049da:	dea43c23          	sd	a0,-520(s0)
    800049de:	1c050463          	beqz	a0,80004ba6 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800049e2:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    800049e6:	00098863          	beqz	s3,800049f6 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800049ea:	e2843c03          	ld	s8,-472(s0)
    800049ee:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    800049f2:	4481                	li	s1,0
    800049f4:	bfb1                	j	80004950 <kexec+0xf6>
    sz = sz1;
    800049f6:	df843903          	ld	s2,-520(s0)
    800049fa:	bfad                	j	80004974 <kexec+0x11a>
    800049fc:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    800049fe:	8552                	mv	a0,s4
    80004a00:	abffe0ef          	jal	800034be <iunlockput>
  end_op();
    80004a04:	b6aff0ef          	jal	80003d6e <end_op>
  p = myproc();
    80004a08:	f41fc0ef          	jal	80001948 <myproc>
    80004a0c:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004a0e:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004a12:	6c05                	lui	s8,0x1
    80004a14:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004a16:	9c4a                	add	s8,s8,s2
    80004a18:	77fd                	lui	a5,0xfffff
    80004a1a:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004a1e:	4691                	li	a3,4
    80004a20:	6609                	lui	a2,0x2
    80004a22:	9662                	add	a2,a2,s8
    80004a24:	85e2                	mv	a1,s8
    80004a26:	855a                	mv	a0,s6
    80004a28:	8c7fc0ef          	jal	800012ee <uvmalloc>
    80004a2c:	892a                	mv	s2,a0
    80004a2e:	e10d                	bnez	a0,80004a50 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004a30:	85e2                	mv	a1,s8
    80004a32:	855a                	mv	a0,s6
    80004a34:	89efd0ef          	jal	80001ad2 <proc_freepagetable>
  return -1;
    80004a38:	557d                	li	a0,-1
    80004a3a:	79fe                	ld	s3,504(sp)
    80004a3c:	7a5e                	ld	s4,496(sp)
    80004a3e:	7abe                	ld	s5,488(sp)
    80004a40:	7b1e                	ld	s6,480(sp)
    80004a42:	6bfe                	ld	s7,472(sp)
    80004a44:	6c5e                	ld	s8,464(sp)
    80004a46:	6cbe                	ld	s9,456(sp)
    80004a48:	6d1e                	ld	s10,448(sp)
    80004a4a:	b549                	j	800048cc <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a4c:	4901                	li	s2,0
    80004a4e:	bf45                	j	800049fe <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004a50:	75f9                	lui	a1,0xffffe
    80004a52:	95aa                	add	a1,a1,a0
    80004a54:	855a                	mv	a0,s6
    80004a56:	a6bfc0ef          	jal	800014c0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004a5a:	80090a13          	addi	s4,s2,-2048
    80004a5e:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004a62:	e0043783          	ld	a5,-512(s0)
    80004a66:	6388                	ld	a0,0(a5)
    80004a68:	c545                	beqz	a0,80004b10 <kexec+0x2b6>
  sp = sz;
    80004a6a:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004a6c:	4481                	li	s1,0
    ustack[argc] = sp;
    80004a6e:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004a72:	c00fc0ef          	jal	80000e72 <strlen>
    80004a76:	0015079b          	addiw	a5,a0,1
    80004a7a:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004a7e:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004a82:	134c6563          	bltu	s8,s4,80004bac <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004a86:	e0043d03          	ld	s10,-512(s0)
    80004a8a:	000d3c83          	ld	s9,0(s10)
    80004a8e:	8566                	mv	a0,s9
    80004a90:	be2fc0ef          	jal	80000e72 <strlen>
    80004a94:	0015071b          	addiw	a4,a0,1
    80004a98:	86e6                	mv	a3,s9
    80004a9a:	8662                	mv	a2,s8
    80004a9c:	85ca                	mv	a1,s2
    80004a9e:	855a                	mv	a0,s6
    80004aa0:	ae3fc0ef          	jal	80001582 <copyout>
    80004aa4:	10054663          	bltz	a0,80004bb0 <kexec+0x356>
    ustack[argc] = sp;
    80004aa8:	00349793          	slli	a5,s1,0x3
    80004aac:	97de                	add	a5,a5,s7
    80004aae:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb9f8>
  for (argc = 0; argv[argc]; argc++) {
    80004ab2:	0485                	addi	s1,s1,1
    80004ab4:	008d0793          	addi	a5,s10,8
    80004ab8:	e0f43023          	sd	a5,-512(s0)
    80004abc:	008d3503          	ld	a0,8(s10)
    80004ac0:	f94d                	bnez	a0,80004a72 <kexec+0x218>
  ustack[argc] = 0;
    80004ac2:	00349793          	slli	a5,s1,0x3
    80004ac6:	f9078793          	addi	a5,a5,-112
    80004aca:	97a2                	add	a5,a5,s0
    80004acc:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004ad0:	00349713          	slli	a4,s1,0x3
    80004ad4:	0721                	addi	a4,a4,8
    80004ad6:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004ada:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004ade:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004ae0:	f54be8e3          	bltu	s7,s4,80004a30 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004ae4:	e9040693          	addi	a3,s0,-368
    80004ae8:	865e                	mv	a2,s7
    80004aea:	85ca                	mv	a1,s2
    80004aec:	855a                	mv	a0,s6
    80004aee:	a95fc0ef          	jal	80001582 <copyout>
    80004af2:	f2054fe3          	bltz	a0,80004a30 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004af6:	0589b783          	ld	a5,88(s3)
    80004afa:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004afe:	df043783          	ld	a5,-528(s0)
    80004b02:	0007c703          	lbu	a4,0(a5)
    80004b06:	c30d                	beqz	a4,80004b28 <kexec+0x2ce>
    80004b08:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004b0a:	02f00693          	li	a3,47
    80004b0e:	a801                	j	80004b1e <kexec+0x2c4>
  sp = sz;
    80004b10:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004b12:	4481                	li	s1,0
    80004b14:	b77d                	j	80004ac2 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004b16:	0785                	addi	a5,a5,1
    80004b18:	fff7c703          	lbu	a4,-1(a5)
    80004b1c:	c711                	beqz	a4,80004b28 <kexec+0x2ce>
    if (*s == '/')
    80004b1e:	fed71ce3          	bne	a4,a3,80004b16 <kexec+0x2bc>
      last = s + 1;
    80004b22:	def43823          	sd	a5,-528(s0)
    80004b26:	bfc5                	j	80004b16 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004b28:	4641                	li	a2,16
    80004b2a:	df043583          	ld	a1,-528(s0)
    80004b2e:	15898513          	addi	a0,s3,344
    80004b32:	b0afc0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004b36:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004b3a:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004b3e:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004b42:	0589b783          	ld	a5,88(s3)
    80004b46:	e6843703          	ld	a4,-408(s0)
    80004b4a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004b4c:	0589b783          	ld	a5,88(s3)
    80004b50:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004b54:	85d6                	mv	a1,s5
    80004b56:	f7dfc0ef          	jal	80001ad2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004b5a:	0004851b          	sext.w	a0,s1
    80004b5e:	79fe                	ld	s3,504(sp)
    80004b60:	7a5e                	ld	s4,496(sp)
    80004b62:	7abe                	ld	s5,488(sp)
    80004b64:	7b1e                	ld	s6,480(sp)
    80004b66:	6bfe                	ld	s7,472(sp)
    80004b68:	6c5e                	ld	s8,464(sp)
    80004b6a:	6cbe                	ld	s9,456(sp)
    80004b6c:	6d1e                	ld	s10,448(sp)
    80004b6e:	bbb9                	j	800048cc <kexec+0x72>
    80004b70:	7b1e                	ld	s6,480(sp)
    80004b72:	b3b1                	j	800048be <kexec+0x64>
    80004b74:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004b78:	df843583          	ld	a1,-520(s0)
    80004b7c:	855a                	mv	a0,s6
    80004b7e:	f55fc0ef          	jal	80001ad2 <proc_freepagetable>
  if (ip) {
    80004b82:	79fe                	ld	s3,504(sp)
    80004b84:	7abe                	ld	s5,488(sp)
    80004b86:	7b1e                	ld	s6,480(sp)
    80004b88:	6bfe                	ld	s7,472(sp)
    80004b8a:	6c5e                	ld	s8,464(sp)
    80004b8c:	6cbe                	ld	s9,456(sp)
    80004b8e:	6d1e                	ld	s10,448(sp)
    80004b90:	7dfa                	ld	s11,440(sp)
    80004b92:	b335                	j	800048be <kexec+0x64>
    80004b94:	df243c23          	sd	s2,-520(s0)
    80004b98:	b7c5                	j	80004b78 <kexec+0x31e>
    80004b9a:	df243c23          	sd	s2,-520(s0)
    80004b9e:	bfe9                	j	80004b78 <kexec+0x31e>
    80004ba0:	df243c23          	sd	s2,-520(s0)
    80004ba4:	bfd1                	j	80004b78 <kexec+0x31e>
    80004ba6:	df243c23          	sd	s2,-520(s0)
    80004baa:	b7f9                	j	80004b78 <kexec+0x31e>
  sz = sz1;
    80004bac:	8c4a                	mv	s8,s2
    80004bae:	b549                	j	80004a30 <kexec+0x1d6>
    80004bb0:	8c4a                	mv	s8,s2
    80004bb2:	bdbd                	j	80004a30 <kexec+0x1d6>

0000000080004bb4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004bb4:	7179                	addi	sp,sp,-48
    80004bb6:	f406                	sd	ra,40(sp)
    80004bb8:	f022                	sd	s0,32(sp)
    80004bba:	ec26                	sd	s1,24(sp)
    80004bbc:	e84a                	sd	s2,16(sp)
    80004bbe:	1800                	addi	s0,sp,48
    80004bc0:	892e                	mv	s2,a1
    80004bc2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004bc4:	fdc40593          	addi	a1,s0,-36
    80004bc8:	cc9fd0ef          	jal	80002890 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004bcc:	fdc42703          	lw	a4,-36(s0)
    80004bd0:	47bd                	li	a5,15
    80004bd2:	02e7ea63          	bltu	a5,a4,80004c06 <argfd+0x52>
    80004bd6:	d73fc0ef          	jal	80001948 <myproc>
    80004bda:	fdc42703          	lw	a4,-36(s0)
    80004bde:	00371793          	slli	a5,a4,0x3
    80004be2:	0d078793          	addi	a5,a5,208
    80004be6:	953e                	add	a0,a0,a5
    80004be8:	611c                	ld	a5,0(a0)
    80004bea:	c385                	beqz	a5,80004c0a <argfd+0x56>
    return -1;
  if (pfd)
    80004bec:	00090463          	beqz	s2,80004bf4 <argfd+0x40>
    *pfd = fd;
    80004bf0:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004bf4:	4501                	li	a0,0
  if (pf)
    80004bf6:	c091                	beqz	s1,80004bfa <argfd+0x46>
    *pf = f;
    80004bf8:	e09c                	sd	a5,0(s1)
}
    80004bfa:	70a2                	ld	ra,40(sp)
    80004bfc:	7402                	ld	s0,32(sp)
    80004bfe:	64e2                	ld	s1,24(sp)
    80004c00:	6942                	ld	s2,16(sp)
    80004c02:	6145                	addi	sp,sp,48
    80004c04:	8082                	ret
    return -1;
    80004c06:	557d                	li	a0,-1
    80004c08:	bfcd                	j	80004bfa <argfd+0x46>
    80004c0a:	557d                	li	a0,-1
    80004c0c:	b7fd                	j	80004bfa <argfd+0x46>

0000000080004c0e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c0e:	1101                	addi	sp,sp,-32
    80004c10:	ec06                	sd	ra,24(sp)
    80004c12:	e822                	sd	s0,16(sp)
    80004c14:	e426                	sd	s1,8(sp)
    80004c16:	1000                	addi	s0,sp,32
    80004c18:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004c1a:	d2ffc0ef          	jal	80001948 <myproc>
    80004c1e:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004c20:	0d050793          	addi	a5,a0,208
    80004c24:	4501                	li	a0,0
    80004c26:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004c28:	6398                	ld	a4,0(a5)
    80004c2a:	cb19                	beqz	a4,80004c40 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004c2c:	2505                	addiw	a0,a0,1
    80004c2e:	07a1                	addi	a5,a5,8
    80004c30:	fed51ce3          	bne	a0,a3,80004c28 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004c34:	557d                	li	a0,-1
}
    80004c36:	60e2                	ld	ra,24(sp)
    80004c38:	6442                	ld	s0,16(sp)
    80004c3a:	64a2                	ld	s1,8(sp)
    80004c3c:	6105                	addi	sp,sp,32
    80004c3e:	8082                	ret
      p->ofile[fd] = f;
    80004c40:	00351793          	slli	a5,a0,0x3
    80004c44:	0d078793          	addi	a5,a5,208
    80004c48:	963e                	add	a2,a2,a5
    80004c4a:	e204                	sd	s1,0(a2)
      return fd;
    80004c4c:	b7ed                	j	80004c36 <fdalloc+0x28>

0000000080004c4e <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004c4e:	715d                	addi	sp,sp,-80
    80004c50:	e486                	sd	ra,72(sp)
    80004c52:	e0a2                	sd	s0,64(sp)
    80004c54:	fc26                	sd	s1,56(sp)
    80004c56:	f84a                	sd	s2,48(sp)
    80004c58:	f052                	sd	s4,32(sp)
    80004c5a:	ec56                	sd	s5,24(sp)
    80004c5c:	e85a                	sd	s6,16(sp)
    80004c5e:	0880                	addi	s0,sp,80
    80004c60:	8a2e                	mv	s4,a1
    80004c62:	8ab2                	mv	s5,a2
    80004c64:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004c66:	fb040593          	addi	a1,s0,-80
    80004c6a:	eb5fe0ef          	jal	80003b1e <nameiparent>
    80004c6e:	84aa                	mv	s1,a0
    80004c70:	12050f63          	beqz	a0,80004dae <create+0x160>
    return 0;

  ilock(dp);
    80004c74:	df6fe0ef          	jal	8000326a <ilock>

  if (dp->nlink == 0) {
    80004c78:	04a49783          	lh	a5,74(s1)
    80004c7c:	cbb9                	beqz	a5,80004cd2 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004c7e:	7761                	lui	a4,0xffff8
    80004c80:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd49f9>
    80004c82:	97ba                	add	a5,a5,a4
    80004c84:	e781                	bnez	a5,80004c8c <create+0x3e>
    80004c86:	fffa0793          	addi	a5,s4,-1
    80004c8a:	cba9                	beqz	a5,80004cdc <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004c8c:	4601                	li	a2,0
    80004c8e:	fb040593          	addi	a1,s0,-80
    80004c92:	8526                	mv	a0,s1
    80004c94:	bbffe0ef          	jal	80003852 <dirlookup>
    80004c98:	892a                	mv	s2,a0
    80004c9a:	c939                	beqz	a0,80004cf0 <create+0xa2>
    iunlockput(dp);
    80004c9c:	8526                	mv	a0,s1
    80004c9e:	821fe0ef          	jal	800034be <iunlockput>
    ilock(ip);
    80004ca2:	854a                	mv	a0,s2
    80004ca4:	dc6fe0ef          	jal	8000326a <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004ca8:	4789                	li	a5,2
    80004caa:	02fa1e63          	bne	s4,a5,80004ce6 <create+0x98>
    80004cae:	04495783          	lhu	a5,68(s2)
    80004cb2:	37f9                	addiw	a5,a5,-2
    80004cb4:	17c2                	slli	a5,a5,0x30
    80004cb6:	93c1                	srli	a5,a5,0x30
    80004cb8:	4705                	li	a4,1
    80004cba:	02f76663          	bltu	a4,a5,80004ce6 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004cbe:	854a                	mv	a0,s2
    80004cc0:	60a6                	ld	ra,72(sp)
    80004cc2:	6406                	ld	s0,64(sp)
    80004cc4:	74e2                	ld	s1,56(sp)
    80004cc6:	7942                	ld	s2,48(sp)
    80004cc8:	7a02                	ld	s4,32(sp)
    80004cca:	6ae2                	ld	s5,24(sp)
    80004ccc:	6b42                	ld	s6,16(sp)
    80004cce:	6161                	addi	sp,sp,80
    80004cd0:	8082                	ret
    iunlockput(dp);
    80004cd2:	8526                	mv	a0,s1
    80004cd4:	feafe0ef          	jal	800034be <iunlockput>
    return 0;
    80004cd8:	4901                	li	s2,0
    80004cda:	b7d5                	j	80004cbe <create+0x70>
    iunlockput(dp);
    80004cdc:	8526                	mv	a0,s1
    80004cde:	fe0fe0ef          	jal	800034be <iunlockput>
    return 0;
    80004ce2:	4901                	li	s2,0
    80004ce4:	bfe9                	j	80004cbe <create+0x70>
    iunlockput(ip);
    80004ce6:	854a                	mv	a0,s2
    80004ce8:	fd6fe0ef          	jal	800034be <iunlockput>
    return 0;
    80004cec:	4901                	li	s2,0
    80004cee:	bfc1                	j	80004cbe <create+0x70>
    80004cf0:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004cf2:	85d2                	mv	a1,s4
    80004cf4:	4088                	lw	a0,0(s1)
    80004cf6:	c04fe0ef          	jal	800030fa <ialloc>
    80004cfa:	89aa                	mv	s3,a0
    80004cfc:	cd1d                	beqz	a0,80004d3a <create+0xec>
  ilock(ip);
    80004cfe:	d6cfe0ef          	jal	8000326a <ilock>
  ip->major = major;
    80004d02:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004d06:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004d0a:	4705                	li	a4,1
    80004d0c:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004d10:	854e                	mv	a0,s3
    80004d12:	ca4fe0ef          	jal	800031b6 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004d16:	4705                	li	a4,1
    80004d18:	02ea0763          	beq	s4,a4,80004d46 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004d1c:	0049a603          	lw	a2,4(s3)
    80004d20:	fb040593          	addi	a1,s0,-80
    80004d24:	8526                	mv	a0,s1
    80004d26:	d35fe0ef          	jal	80003a5a <dirlink>
    80004d2a:	06054563          	bltz	a0,80004d94 <create+0x146>
  iunlockput(dp);
    80004d2e:	8526                	mv	a0,s1
    80004d30:	f8efe0ef          	jal	800034be <iunlockput>
  return ip;
    80004d34:	894e                	mv	s2,s3
    80004d36:	79a2                	ld	s3,40(sp)
    80004d38:	b759                	j	80004cbe <create+0x70>
    iunlockput(dp);
    80004d3a:	8526                	mv	a0,s1
    80004d3c:	f82fe0ef          	jal	800034be <iunlockput>
    return 0;
    80004d40:	894e                	mv	s2,s3
    80004d42:	79a2                	ld	s3,40(sp)
    80004d44:	bfad                	j	80004cbe <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004d46:	0049a603          	lw	a2,4(s3)
    80004d4a:	00003597          	auipc	a1,0x3
    80004d4e:	89658593          	addi	a1,a1,-1898 # 800075e0 <etext+0x5e0>
    80004d52:	854e                	mv	a0,s3
    80004d54:	d07fe0ef          	jal	80003a5a <dirlink>
    80004d58:	02054e63          	bltz	a0,80004d94 <create+0x146>
    80004d5c:	40d0                	lw	a2,4(s1)
    80004d5e:	00003597          	auipc	a1,0x3
    80004d62:	88a58593          	addi	a1,a1,-1910 # 800075e8 <etext+0x5e8>
    80004d66:	854e                	mv	a0,s3
    80004d68:	cf3fe0ef          	jal	80003a5a <dirlink>
    80004d6c:	02054463          	bltz	a0,80004d94 <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004d70:	0049a603          	lw	a2,4(s3)
    80004d74:	fb040593          	addi	a1,s0,-80
    80004d78:	8526                	mv	a0,s1
    80004d7a:	ce1fe0ef          	jal	80003a5a <dirlink>
    80004d7e:	00054b63          	bltz	a0,80004d94 <create+0x146>
    dp->nlink++; // for ".."
    80004d82:	04a4d783          	lhu	a5,74(s1)
    80004d86:	2785                	addiw	a5,a5,1
    80004d88:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d8c:	8526                	mv	a0,s1
    80004d8e:	c28fe0ef          	jal	800031b6 <iupdate>
    80004d92:	bf71                	j	80004d2e <create+0xe0>
  ip->nlink = 0;
    80004d94:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004d98:	854e                	mv	a0,s3
    80004d9a:	c1cfe0ef          	jal	800031b6 <iupdate>
  iunlockput(ip);
    80004d9e:	854e                	mv	a0,s3
    80004da0:	f1efe0ef          	jal	800034be <iunlockput>
  iunlockput(dp);
    80004da4:	8526                	mv	a0,s1
    80004da6:	f18fe0ef          	jal	800034be <iunlockput>
  return 0;
    80004daa:	79a2                	ld	s3,40(sp)
    80004dac:	bf09                	j	80004cbe <create+0x70>
    return 0;
    80004dae:	892a                	mv	s2,a0
    80004db0:	b739                	j	80004cbe <create+0x70>

0000000080004db2 <sys_dup>:
{
    80004db2:	7179                	addi	sp,sp,-48
    80004db4:	f406                	sd	ra,40(sp)
    80004db6:	f022                	sd	s0,32(sp)
    80004db8:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004dba:	fd840613          	addi	a2,s0,-40
    80004dbe:	4581                	li	a1,0
    80004dc0:	4501                	li	a0,0
    80004dc2:	df3ff0ef          	jal	80004bb4 <argfd>
    return -1;
    80004dc6:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004dc8:	02054363          	bltz	a0,80004dee <sys_dup+0x3c>
    80004dcc:	ec26                	sd	s1,24(sp)
    80004dce:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004dd0:	fd843483          	ld	s1,-40(s0)
    80004dd4:	8526                	mv	a0,s1
    80004dd6:	e39ff0ef          	jal	80004c0e <fdalloc>
    80004dda:	892a                	mv	s2,a0
    return -1;
    80004ddc:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004dde:	00054d63          	bltz	a0,80004df8 <sys_dup+0x46>
  filedup(f);
    80004de2:	8526                	mv	a0,s1
    80004de4:	b72ff0ef          	jal	80004156 <filedup>
  return fd;
    80004de8:	87ca                	mv	a5,s2
    80004dea:	64e2                	ld	s1,24(sp)
    80004dec:	6942                	ld	s2,16(sp)
}
    80004dee:	853e                	mv	a0,a5
    80004df0:	70a2                	ld	ra,40(sp)
    80004df2:	7402                	ld	s0,32(sp)
    80004df4:	6145                	addi	sp,sp,48
    80004df6:	8082                	ret
    80004df8:	64e2                	ld	s1,24(sp)
    80004dfa:	6942                	ld	s2,16(sp)
    80004dfc:	bfcd                	j	80004dee <sys_dup+0x3c>

0000000080004dfe <sys_read>:
{
    80004dfe:	7179                	addi	sp,sp,-48
    80004e00:	f406                	sd	ra,40(sp)
    80004e02:	f022                	sd	s0,32(sp)
    80004e04:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e06:	fd840593          	addi	a1,s0,-40
    80004e0a:	4505                	li	a0,1
    80004e0c:	aa1fd0ef          	jal	800028ac <argaddr>
  argint(2, &n);
    80004e10:	fe440593          	addi	a1,s0,-28
    80004e14:	4509                	li	a0,2
    80004e16:	a7bfd0ef          	jal	80002890 <argint>
  if (argfd(0, 0, &f) < 0)
    80004e1a:	fe840613          	addi	a2,s0,-24
    80004e1e:	4581                	li	a1,0
    80004e20:	4501                	li	a0,0
    80004e22:	d93ff0ef          	jal	80004bb4 <argfd>
    80004e26:	87aa                	mv	a5,a0
    return -1;
    80004e28:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004e2a:	0007ca63          	bltz	a5,80004e3e <sys_read+0x40>
  return fileread(f, p, n);
    80004e2e:	fe442603          	lw	a2,-28(s0)
    80004e32:	fd843583          	ld	a1,-40(s0)
    80004e36:	fe843503          	ld	a0,-24(s0)
    80004e3a:	c94ff0ef          	jal	800042ce <fileread>
}
    80004e3e:	70a2                	ld	ra,40(sp)
    80004e40:	7402                	ld	s0,32(sp)
    80004e42:	6145                	addi	sp,sp,48
    80004e44:	8082                	ret

0000000080004e46 <sys_write>:
{
    80004e46:	7179                	addi	sp,sp,-48
    80004e48:	f406                	sd	ra,40(sp)
    80004e4a:	f022                	sd	s0,32(sp)
    80004e4c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e4e:	fd840593          	addi	a1,s0,-40
    80004e52:	4505                	li	a0,1
    80004e54:	a59fd0ef          	jal	800028ac <argaddr>
  argint(2, &n);
    80004e58:	fe440593          	addi	a1,s0,-28
    80004e5c:	4509                	li	a0,2
    80004e5e:	a33fd0ef          	jal	80002890 <argint>
  if (argfd(0, 0, &f) < 0)
    80004e62:	fe840613          	addi	a2,s0,-24
    80004e66:	4581                	li	a1,0
    80004e68:	4501                	li	a0,0
    80004e6a:	d4bff0ef          	jal	80004bb4 <argfd>
    80004e6e:	87aa                	mv	a5,a0
    return -1;
    80004e70:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004e72:	0007ca63          	bltz	a5,80004e86 <sys_write+0x40>
  return filewrite(f, p, n);
    80004e76:	fe442603          	lw	a2,-28(s0)
    80004e7a:	fd843583          	ld	a1,-40(s0)
    80004e7e:	fe843503          	ld	a0,-24(s0)
    80004e82:	d1aff0ef          	jal	8000439c <filewrite>
}
    80004e86:	70a2                	ld	ra,40(sp)
    80004e88:	7402                	ld	s0,32(sp)
    80004e8a:	6145                	addi	sp,sp,48
    80004e8c:	8082                	ret

0000000080004e8e <sys_close>:
{
    80004e8e:	1101                	addi	sp,sp,-32
    80004e90:	ec06                	sd	ra,24(sp)
    80004e92:	e822                	sd	s0,16(sp)
    80004e94:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004e96:	fe040613          	addi	a2,s0,-32
    80004e9a:	fec40593          	addi	a1,s0,-20
    80004e9e:	4501                	li	a0,0
    80004ea0:	d15ff0ef          	jal	80004bb4 <argfd>
    return -1;
    80004ea4:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004ea6:	02054163          	bltz	a0,80004ec8 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004eaa:	a9ffc0ef          	jal	80001948 <myproc>
    80004eae:	fec42783          	lw	a5,-20(s0)
    80004eb2:	078e                	slli	a5,a5,0x3
    80004eb4:	0d078793          	addi	a5,a5,208
    80004eb8:	953e                	add	a0,a0,a5
    80004eba:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004ebe:	fe043503          	ld	a0,-32(s0)
    80004ec2:	adaff0ef          	jal	8000419c <fileclose>
  return 0;
    80004ec6:	4781                	li	a5,0
}
    80004ec8:	853e                	mv	a0,a5
    80004eca:	60e2                	ld	ra,24(sp)
    80004ecc:	6442                	ld	s0,16(sp)
    80004ece:	6105                	addi	sp,sp,32
    80004ed0:	8082                	ret

0000000080004ed2 <sys_fstat>:
{
    80004ed2:	1101                	addi	sp,sp,-32
    80004ed4:	ec06                	sd	ra,24(sp)
    80004ed6:	e822                	sd	s0,16(sp)
    80004ed8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004eda:	fe040593          	addi	a1,s0,-32
    80004ede:	4505                	li	a0,1
    80004ee0:	9cdfd0ef          	jal	800028ac <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004ee4:	fe840613          	addi	a2,s0,-24
    80004ee8:	4581                	li	a1,0
    80004eea:	4501                	li	a0,0
    80004eec:	cc9ff0ef          	jal	80004bb4 <argfd>
    80004ef0:	87aa                	mv	a5,a0
    return -1;
    80004ef2:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004ef4:	0007c863          	bltz	a5,80004f04 <sys_fstat+0x32>
  return filestat(f, st);
    80004ef8:	fe043583          	ld	a1,-32(s0)
    80004efc:	fe843503          	ld	a0,-24(s0)
    80004f00:	b5eff0ef          	jal	8000425e <filestat>
}
    80004f04:	60e2                	ld	ra,24(sp)
    80004f06:	6442                	ld	s0,16(sp)
    80004f08:	6105                	addi	sp,sp,32
    80004f0a:	8082                	ret

0000000080004f0c <sys_link>:
{
    80004f0c:	7169                	addi	sp,sp,-304
    80004f0e:	f606                	sd	ra,296(sp)
    80004f10:	f222                	sd	s0,288(sp)
    80004f12:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f14:	08000613          	li	a2,128
    80004f18:	ed040593          	addi	a1,s0,-304
    80004f1c:	4501                	li	a0,0
    80004f1e:	9abfd0ef          	jal	800028c8 <argstr>
    return -1;
    80004f22:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f24:	10054163          	bltz	a0,80005026 <sys_link+0x11a>
    80004f28:	08000613          	li	a2,128
    80004f2c:	f5040593          	addi	a1,s0,-176
    80004f30:	4505                	li	a0,1
    80004f32:	997fd0ef          	jal	800028c8 <argstr>
    return -1;
    80004f36:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f38:	0e054763          	bltz	a0,80005026 <sys_link+0x11a>
    80004f3c:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f3e:	da5fe0ef          	jal	80003ce2 <begin_op>
  if ((ip = namei(old)) == 0) {
    80004f42:	ed040513          	addi	a0,s0,-304
    80004f46:	bbffe0ef          	jal	80003b04 <namei>
    80004f4a:	84aa                	mv	s1,a0
    80004f4c:	cd35                	beqz	a0,80004fc8 <sys_link+0xbc>
  ilock(ip);
    80004f4e:	b1cfe0ef          	jal	8000326a <ilock>
  if (ip->type == T_DIR) {
    80004f52:	04449703          	lh	a4,68(s1)
    80004f56:	4785                	li	a5,1
    80004f58:	06f70d63          	beq	a4,a5,80004fd2 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80004f5c:	04a49783          	lh	a5,74(s1)
    80004f60:	6721                	lui	a4,0x8
    80004f62:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004f64:	06e78f63          	beq	a5,a4,80004fe2 <sys_link+0xd6>
    80004f68:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004f6a:	2785                	addiw	a5,a5,1
    80004f6c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f70:	8526                	mv	a0,s1
    80004f72:	a44fe0ef          	jal	800031b6 <iupdate>
  iunlock(ip);
    80004f76:	8526                	mv	a0,s1
    80004f78:	ba0fe0ef          	jal	80003318 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80004f7c:	fd040593          	addi	a1,s0,-48
    80004f80:	f5040513          	addi	a0,s0,-176
    80004f84:	b9bfe0ef          	jal	80003b1e <nameiparent>
    80004f88:	892a                	mv	s2,a0
    80004f8a:	c93d                	beqz	a0,80005000 <sys_link+0xf4>
  ilock(dp);
    80004f8c:	adefe0ef          	jal	8000326a <ilock>
  if (dp->nlink == 0) {
    80004f90:	04a91783          	lh	a5,74(s2)
    80004f94:	cfb9                	beqz	a5,80004ff2 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80004f96:	854a                	mv	a0,s2
    80004f98:	00092703          	lw	a4,0(s2)
    80004f9c:	409c                	lw	a5,0(s1)
    80004f9e:	04f71e63          	bne	a4,a5,80004ffa <sys_link+0xee>
    80004fa2:	40d0                	lw	a2,4(s1)
    80004fa4:	fd040593          	addi	a1,s0,-48
    80004fa8:	ab3fe0ef          	jal	80003a5a <dirlink>
    80004fac:	04054763          	bltz	a0,80004ffa <sys_link+0xee>
  iunlockput(dp);
    80004fb0:	854a                	mv	a0,s2
    80004fb2:	d0cfe0ef          	jal	800034be <iunlockput>
  iput(ip);
    80004fb6:	8526                	mv	a0,s1
    80004fb8:	c34fe0ef          	jal	800033ec <iput>
  end_op();
    80004fbc:	db3fe0ef          	jal	80003d6e <end_op>
  return 0;
    80004fc0:	4781                	li	a5,0
    80004fc2:	64f2                	ld	s1,280(sp)
    80004fc4:	6952                	ld	s2,272(sp)
    80004fc6:	a085                	j	80005026 <sys_link+0x11a>
    end_op();
    80004fc8:	da7fe0ef          	jal	80003d6e <end_op>
    return -1;
    80004fcc:	57fd                	li	a5,-1
    80004fce:	64f2                	ld	s1,280(sp)
    80004fd0:	a899                	j	80005026 <sys_link+0x11a>
    iunlockput(ip);
    80004fd2:	8526                	mv	a0,s1
    80004fd4:	ceafe0ef          	jal	800034be <iunlockput>
    end_op();
    80004fd8:	d97fe0ef          	jal	80003d6e <end_op>
    return -1;
    80004fdc:	57fd                	li	a5,-1
    80004fde:	64f2                	ld	s1,280(sp)
    80004fe0:	a099                	j	80005026 <sys_link+0x11a>
    iunlockput(ip);
    80004fe2:	8526                	mv	a0,s1
    80004fe4:	cdafe0ef          	jal	800034be <iunlockput>
    end_op();
    80004fe8:	d87fe0ef          	jal	80003d6e <end_op>
    return -1;
    80004fec:	57fd                	li	a5,-1
    80004fee:	64f2                	ld	s1,280(sp)
    80004ff0:	a81d                	j	80005026 <sys_link+0x11a>
    iunlockput(dp);
    80004ff2:	854a                	mv	a0,s2
    80004ff4:	ccafe0ef          	jal	800034be <iunlockput>
    goto bad;
    80004ff8:	a021                	j	80005000 <sys_link+0xf4>
    iunlockput(dp);
    80004ffa:	854a                	mv	a0,s2
    80004ffc:	cc2fe0ef          	jal	800034be <iunlockput>
  ilock(ip);
    80005000:	8526                	mv	a0,s1
    80005002:	a68fe0ef          	jal	8000326a <ilock>
  ip->nlink--;
    80005006:	04a4d783          	lhu	a5,74(s1)
    8000500a:	37fd                	addiw	a5,a5,-1
    8000500c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005010:	8526                	mv	a0,s1
    80005012:	9a4fe0ef          	jal	800031b6 <iupdate>
  iunlockput(ip);
    80005016:	8526                	mv	a0,s1
    80005018:	ca6fe0ef          	jal	800034be <iunlockput>
  end_op();
    8000501c:	d53fe0ef          	jal	80003d6e <end_op>
  return -1;
    80005020:	57fd                	li	a5,-1
    80005022:	64f2                	ld	s1,280(sp)
    80005024:	6952                	ld	s2,272(sp)
}
    80005026:	853e                	mv	a0,a5
    80005028:	70b2                	ld	ra,296(sp)
    8000502a:	7412                	ld	s0,288(sp)
    8000502c:	6155                	addi	sp,sp,304
    8000502e:	8082                	ret

0000000080005030 <sys_unlink>:
{
    80005030:	7151                	addi	sp,sp,-240
    80005032:	f586                	sd	ra,232(sp)
    80005034:	f1a2                	sd	s0,224(sp)
    80005036:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005038:	08000613          	li	a2,128
    8000503c:	f3040593          	addi	a1,s0,-208
    80005040:	4501                	li	a0,0
    80005042:	887fd0ef          	jal	800028c8 <argstr>
    80005046:	14054d63          	bltz	a0,800051a0 <sys_unlink+0x170>
    8000504a:	eda6                	sd	s1,216(sp)
  begin_op();
    8000504c:	c97fe0ef          	jal	80003ce2 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80005050:	fb040593          	addi	a1,s0,-80
    80005054:	f3040513          	addi	a0,s0,-208
    80005058:	ac7fe0ef          	jal	80003b1e <nameiparent>
    8000505c:	84aa                	mv	s1,a0
    8000505e:	c955                	beqz	a0,80005112 <sys_unlink+0xe2>
  ilock(dp);
    80005060:	a0afe0ef          	jal	8000326a <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005064:	00002597          	auipc	a1,0x2
    80005068:	57c58593          	addi	a1,a1,1404 # 800075e0 <etext+0x5e0>
    8000506c:	fb040513          	addi	a0,s0,-80
    80005070:	fccfe0ef          	jal	8000383c <namecmp>
    80005074:	10050b63          	beqz	a0,8000518a <sys_unlink+0x15a>
    80005078:	00002597          	auipc	a1,0x2
    8000507c:	57058593          	addi	a1,a1,1392 # 800075e8 <etext+0x5e8>
    80005080:	fb040513          	addi	a0,s0,-80
    80005084:	fb8fe0ef          	jal	8000383c <namecmp>
    80005088:	10050163          	beqz	a0,8000518a <sys_unlink+0x15a>
    8000508c:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    8000508e:	f2c40613          	addi	a2,s0,-212
    80005092:	fb040593          	addi	a1,s0,-80
    80005096:	8526                	mv	a0,s1
    80005098:	fbafe0ef          	jal	80003852 <dirlookup>
    8000509c:	892a                	mv	s2,a0
    8000509e:	0e050563          	beqz	a0,80005188 <sys_unlink+0x158>
    800050a2:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800050a4:	9c6fe0ef          	jal	8000326a <ilock>
  if (ip->nlink < 1)
    800050a8:	04a91783          	lh	a5,74(s2)
    800050ac:	06f05863          	blez	a5,8000511c <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    800050b0:	04491703          	lh	a4,68(s2)
    800050b4:	4785                	li	a5,1
    800050b6:	06f70963          	beq	a4,a5,80005128 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    800050ba:	fc040993          	addi	s3,s0,-64
    800050be:	4641                	li	a2,16
    800050c0:	4581                	li	a1,0
    800050c2:	854e                	mv	a0,s3
    800050c4:	c25fb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050c8:	4741                	li	a4,16
    800050ca:	f2c42683          	lw	a3,-212(s0)
    800050ce:	864e                	mv	a2,s3
    800050d0:	4581                	li	a1,0
    800050d2:	8526                	mv	a0,s1
    800050d4:	e62fe0ef          	jal	80003736 <writei>
    800050d8:	47c1                	li	a5,16
    800050da:	08f51863          	bne	a0,a5,8000516a <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    800050de:	04491703          	lh	a4,68(s2)
    800050e2:	4785                	li	a5,1
    800050e4:	08f70963          	beq	a4,a5,80005176 <sys_unlink+0x146>
  iunlockput(dp);
    800050e8:	8526                	mv	a0,s1
    800050ea:	bd4fe0ef          	jal	800034be <iunlockput>
  ip->nlink--;
    800050ee:	04a95783          	lhu	a5,74(s2)
    800050f2:	37fd                	addiw	a5,a5,-1
    800050f4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800050f8:	854a                	mv	a0,s2
    800050fa:	8bcfe0ef          	jal	800031b6 <iupdate>
  iunlockput(ip);
    800050fe:	854a                	mv	a0,s2
    80005100:	bbefe0ef          	jal	800034be <iunlockput>
  end_op();
    80005104:	c6bfe0ef          	jal	80003d6e <end_op>
  return 0;
    80005108:	4501                	li	a0,0
    8000510a:	64ee                	ld	s1,216(sp)
    8000510c:	694e                	ld	s2,208(sp)
    8000510e:	69ae                	ld	s3,200(sp)
    80005110:	a061                	j	80005198 <sys_unlink+0x168>
    end_op();
    80005112:	c5dfe0ef          	jal	80003d6e <end_op>
    return -1;
    80005116:	557d                	li	a0,-1
    80005118:	64ee                	ld	s1,216(sp)
    8000511a:	a8bd                	j	80005198 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    8000511c:	00002517          	auipc	a0,0x2
    80005120:	4d450513          	addi	a0,a0,1236 # 800075f0 <etext+0x5f0>
    80005124:	f10fb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005128:	04c92703          	lw	a4,76(s2)
    8000512c:	02000793          	li	a5,32
    80005130:	f8e7f5e3          	bgeu	a5,a4,800050ba <sys_unlink+0x8a>
    80005134:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005136:	4741                	li	a4,16
    80005138:	86ce                	mv	a3,s3
    8000513a:	f1840613          	addi	a2,s0,-232
    8000513e:	4581                	li	a1,0
    80005140:	854a                	mv	a0,s2
    80005142:	d02fe0ef          	jal	80003644 <readi>
    80005146:	47c1                	li	a5,16
    80005148:	00f51b63          	bne	a0,a5,8000515e <sys_unlink+0x12e>
    if (de.inum != 0)
    8000514c:	f1845783          	lhu	a5,-232(s0)
    80005150:	ebb1                	bnez	a5,800051a4 <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005152:	29c1                	addiw	s3,s3,16
    80005154:	04c92783          	lw	a5,76(s2)
    80005158:	fcf9efe3          	bltu	s3,a5,80005136 <sys_unlink+0x106>
    8000515c:	bfb9                	j	800050ba <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000515e:	00002517          	auipc	a0,0x2
    80005162:	4aa50513          	addi	a0,a0,1194 # 80007608 <etext+0x608>
    80005166:	ecefb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    8000516a:	00002517          	auipc	a0,0x2
    8000516e:	4b650513          	addi	a0,a0,1206 # 80007620 <etext+0x620>
    80005172:	ec2fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    80005176:	04a4d783          	lhu	a5,74(s1)
    8000517a:	37fd                	addiw	a5,a5,-1
    8000517c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005180:	8526                	mv	a0,s1
    80005182:	834fe0ef          	jal	800031b6 <iupdate>
    80005186:	b78d                	j	800050e8 <sys_unlink+0xb8>
    80005188:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000518a:	8526                	mv	a0,s1
    8000518c:	b32fe0ef          	jal	800034be <iunlockput>
  end_op();
    80005190:	bdffe0ef          	jal	80003d6e <end_op>
  return -1;
    80005194:	557d                	li	a0,-1
    80005196:	64ee                	ld	s1,216(sp)
}
    80005198:	70ae                	ld	ra,232(sp)
    8000519a:	740e                	ld	s0,224(sp)
    8000519c:	616d                	addi	sp,sp,240
    8000519e:	8082                	ret
    return -1;
    800051a0:	557d                	li	a0,-1
    800051a2:	bfdd                	j	80005198 <sys_unlink+0x168>
    iunlockput(ip);
    800051a4:	854a                	mv	a0,s2
    800051a6:	b18fe0ef          	jal	800034be <iunlockput>
    goto bad;
    800051aa:	694e                	ld	s2,208(sp)
    800051ac:	69ae                	ld	s3,200(sp)
    800051ae:	bff1                	j	8000518a <sys_unlink+0x15a>

00000000800051b0 <sys_open>:

uint64
sys_open(void)
{
    800051b0:	7131                	addi	sp,sp,-192
    800051b2:	fd06                	sd	ra,184(sp)
    800051b4:	f922                	sd	s0,176(sp)
    800051b6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800051b8:	f4c40593          	addi	a1,s0,-180
    800051bc:	4505                	li	a0,1
    800051be:	ed2fd0ef          	jal	80002890 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800051c2:	08000613          	li	a2,128
    800051c6:	f5040593          	addi	a1,s0,-176
    800051ca:	4501                	li	a0,0
    800051cc:	efcfd0ef          	jal	800028c8 <argstr>
    800051d0:	87aa                	mv	a5,a0
    return -1;
    800051d2:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800051d4:	0a07c363          	bltz	a5,8000527a <sys_open+0xca>
    800051d8:	f526                	sd	s1,168(sp)

  begin_op();
    800051da:	b09fe0ef          	jal	80003ce2 <begin_op>

  if (omode & O_CREATE) {
    800051de:	f4c42783          	lw	a5,-180(s0)
    800051e2:	2007f793          	andi	a5,a5,512
    800051e6:	c3dd                	beqz	a5,8000528c <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800051e8:	4681                	li	a3,0
    800051ea:	4601                	li	a2,0
    800051ec:	4589                	li	a1,2
    800051ee:	f5040513          	addi	a0,s0,-176
    800051f2:	a5dff0ef          	jal	80004c4e <create>
    800051f6:	84aa                	mv	s1,a0
    if (ip == 0) {
    800051f8:	c549                	beqz	a0,80005282 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    800051fa:	04449703          	lh	a4,68(s1)
    800051fe:	478d                	li	a5,3
    80005200:	00f71763          	bne	a4,a5,8000520e <sys_open+0x5e>
    80005204:	0464d703          	lhu	a4,70(s1)
    80005208:	47a5                	li	a5,9
    8000520a:	0ae7ee63          	bltu	a5,a4,800052c6 <sys_open+0x116>
    8000520e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    80005210:	ee9fe0ef          	jal	800040f8 <filealloc>
    80005214:	892a                	mv	s2,a0
    80005216:	c561                	beqz	a0,800052de <sys_open+0x12e>
    80005218:	ed4e                	sd	s3,152(sp)
    8000521a:	9f5ff0ef          	jal	80004c0e <fdalloc>
    8000521e:	89aa                	mv	s3,a0
    80005220:	0a054b63          	bltz	a0,800052d6 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    80005224:	04449703          	lh	a4,68(s1)
    80005228:	478d                	li	a5,3
    8000522a:	0cf70363          	beq	a4,a5,800052f0 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000522e:	4789                	li	a5,2
    80005230:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005234:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005238:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000523c:	f4c42783          	lw	a5,-180(s0)
    80005240:	0017f713          	andi	a4,a5,1
    80005244:	00174713          	xori	a4,a4,1
    80005248:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000524c:	0037f713          	andi	a4,a5,3
    80005250:	00e03733          	snez	a4,a4
    80005254:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80005258:	4007f793          	andi	a5,a5,1024
    8000525c:	c791                	beqz	a5,80005268 <sys_open+0xb8>
    8000525e:	04449703          	lh	a4,68(s1)
    80005262:	4789                	li	a5,2
    80005264:	08f70d63          	beq	a4,a5,800052fe <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005268:	8526                	mv	a0,s1
    8000526a:	8aefe0ef          	jal	80003318 <iunlock>
  end_op();
    8000526e:	b01fe0ef          	jal	80003d6e <end_op>

  return fd;
    80005272:	854e                	mv	a0,s3
    80005274:	74aa                	ld	s1,168(sp)
    80005276:	790a                	ld	s2,160(sp)
    80005278:	69ea                	ld	s3,152(sp)
}
    8000527a:	70ea                	ld	ra,184(sp)
    8000527c:	744a                	ld	s0,176(sp)
    8000527e:	6129                	addi	sp,sp,192
    80005280:	8082                	ret
      end_op();
    80005282:	aedfe0ef          	jal	80003d6e <end_op>
      return -1;
    80005286:	557d                	li	a0,-1
    80005288:	74aa                	ld	s1,168(sp)
    8000528a:	bfc5                	j	8000527a <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    8000528c:	f5040513          	addi	a0,s0,-176
    80005290:	875fe0ef          	jal	80003b04 <namei>
    80005294:	84aa                	mv	s1,a0
    80005296:	c11d                	beqz	a0,800052bc <sys_open+0x10c>
    ilock(ip);
    80005298:	fd3fd0ef          	jal	8000326a <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    8000529c:	04449703          	lh	a4,68(s1)
    800052a0:	4785                	li	a5,1
    800052a2:	f4f71ce3          	bne	a4,a5,800051fa <sys_open+0x4a>
    800052a6:	f4c42783          	lw	a5,-180(s0)
    800052aa:	d3b5                	beqz	a5,8000520e <sys_open+0x5e>
      iunlockput(ip);
    800052ac:	8526                	mv	a0,s1
    800052ae:	a10fe0ef          	jal	800034be <iunlockput>
      end_op();
    800052b2:	abdfe0ef          	jal	80003d6e <end_op>
      return -1;
    800052b6:	557d                	li	a0,-1
    800052b8:	74aa                	ld	s1,168(sp)
    800052ba:	b7c1                	j	8000527a <sys_open+0xca>
      end_op();
    800052bc:	ab3fe0ef          	jal	80003d6e <end_op>
      return -1;
    800052c0:	557d                	li	a0,-1
    800052c2:	74aa                	ld	s1,168(sp)
    800052c4:	bf5d                	j	8000527a <sys_open+0xca>
    iunlockput(ip);
    800052c6:	8526                	mv	a0,s1
    800052c8:	9f6fe0ef          	jal	800034be <iunlockput>
    end_op();
    800052cc:	aa3fe0ef          	jal	80003d6e <end_op>
    return -1;
    800052d0:	557d                	li	a0,-1
    800052d2:	74aa                	ld	s1,168(sp)
    800052d4:	b75d                	j	8000527a <sys_open+0xca>
      fileclose(f);
    800052d6:	854a                	mv	a0,s2
    800052d8:	ec5fe0ef          	jal	8000419c <fileclose>
    800052dc:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800052de:	8526                	mv	a0,s1
    800052e0:	9defe0ef          	jal	800034be <iunlockput>
    end_op();
    800052e4:	a8bfe0ef          	jal	80003d6e <end_op>
    return -1;
    800052e8:	557d                	li	a0,-1
    800052ea:	74aa                	ld	s1,168(sp)
    800052ec:	790a                	ld	s2,160(sp)
    800052ee:	b771                	j	8000527a <sys_open+0xca>
    f->type = FD_DEVICE;
    800052f0:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800052f4:	04649783          	lh	a5,70(s1)
    800052f8:	02f91223          	sh	a5,36(s2)
    800052fc:	bf35                	j	80005238 <sys_open+0x88>
    itrunc(ip);
    800052fe:	8526                	mv	a0,s1
    80005300:	858fe0ef          	jal	80003358 <itrunc>
    80005304:	b795                	j	80005268 <sys_open+0xb8>

0000000080005306 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005306:	7175                	addi	sp,sp,-144
    80005308:	e506                	sd	ra,136(sp)
    8000530a:	e122                	sd	s0,128(sp)
    8000530c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000530e:	9d5fe0ef          	jal	80003ce2 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    80005312:	08000613          	li	a2,128
    80005316:	f7040593          	addi	a1,s0,-144
    8000531a:	4501                	li	a0,0
    8000531c:	dacfd0ef          	jal	800028c8 <argstr>
    80005320:	02054363          	bltz	a0,80005346 <sys_mkdir+0x40>
    80005324:	4681                	li	a3,0
    80005326:	4601                	li	a2,0
    80005328:	4585                	li	a1,1
    8000532a:	f7040513          	addi	a0,s0,-144
    8000532e:	921ff0ef          	jal	80004c4e <create>
    80005332:	c911                	beqz	a0,80005346 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005334:	98afe0ef          	jal	800034be <iunlockput>
  end_op();
    80005338:	a37fe0ef          	jal	80003d6e <end_op>
  return 0;
    8000533c:	4501                	li	a0,0
}
    8000533e:	60aa                	ld	ra,136(sp)
    80005340:	640a                	ld	s0,128(sp)
    80005342:	6149                	addi	sp,sp,144
    80005344:	8082                	ret
    end_op();
    80005346:	a29fe0ef          	jal	80003d6e <end_op>
    return -1;
    8000534a:	557d                	li	a0,-1
    8000534c:	bfcd                	j	8000533e <sys_mkdir+0x38>

000000008000534e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000534e:	7135                	addi	sp,sp,-160
    80005350:	ed06                	sd	ra,152(sp)
    80005352:	e922                	sd	s0,144(sp)
    80005354:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005356:	98dfe0ef          	jal	80003ce2 <begin_op>
  argint(1, &major);
    8000535a:	f6c40593          	addi	a1,s0,-148
    8000535e:	4505                	li	a0,1
    80005360:	d30fd0ef          	jal	80002890 <argint>
  argint(2, &minor);
    80005364:	f6840593          	addi	a1,s0,-152
    80005368:	4509                	li	a0,2
    8000536a:	d26fd0ef          	jal	80002890 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    8000536e:	08000613          	li	a2,128
    80005372:	f7040593          	addi	a1,s0,-144
    80005376:	4501                	li	a0,0
    80005378:	d50fd0ef          	jal	800028c8 <argstr>
    8000537c:	02054563          	bltz	a0,800053a6 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005380:	f6841683          	lh	a3,-152(s0)
    80005384:	f6c41603          	lh	a2,-148(s0)
    80005388:	458d                	li	a1,3
    8000538a:	f7040513          	addi	a0,s0,-144
    8000538e:	8c1ff0ef          	jal	80004c4e <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005392:	c911                	beqz	a0,800053a6 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005394:	92afe0ef          	jal	800034be <iunlockput>
  end_op();
    80005398:	9d7fe0ef          	jal	80003d6e <end_op>
  return 0;
    8000539c:	4501                	li	a0,0
}
    8000539e:	60ea                	ld	ra,152(sp)
    800053a0:	644a                	ld	s0,144(sp)
    800053a2:	610d                	addi	sp,sp,160
    800053a4:	8082                	ret
    end_op();
    800053a6:	9c9fe0ef          	jal	80003d6e <end_op>
    return -1;
    800053aa:	557d                	li	a0,-1
    800053ac:	bfcd                	j	8000539e <sys_mknod+0x50>

00000000800053ae <sys_chdir>:

uint64
sys_chdir(void)
{
    800053ae:	7135                	addi	sp,sp,-160
    800053b0:	ed06                	sd	ra,152(sp)
    800053b2:	e922                	sd	s0,144(sp)
    800053b4:	e14a                	sd	s2,128(sp)
    800053b6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800053b8:	d90fc0ef          	jal	80001948 <myproc>
    800053bc:	892a                	mv	s2,a0

  begin_op();
    800053be:	925fe0ef          	jal	80003ce2 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    800053c2:	08000613          	li	a2,128
    800053c6:	f6040593          	addi	a1,s0,-160
    800053ca:	4501                	li	a0,0
    800053cc:	cfcfd0ef          	jal	800028c8 <argstr>
    800053d0:	04054363          	bltz	a0,80005416 <sys_chdir+0x68>
    800053d4:	e526                	sd	s1,136(sp)
    800053d6:	f6040513          	addi	a0,s0,-160
    800053da:	f2afe0ef          	jal	80003b04 <namei>
    800053de:	84aa                	mv	s1,a0
    800053e0:	c915                	beqz	a0,80005414 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800053e2:	e89fd0ef          	jal	8000326a <ilock>
  if (ip->type != T_DIR) {
    800053e6:	04449703          	lh	a4,68(s1)
    800053ea:	4785                	li	a5,1
    800053ec:	02f71963          	bne	a4,a5,8000541e <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800053f0:	8526                	mv	a0,s1
    800053f2:	f27fd0ef          	jal	80003318 <iunlock>
  iput(p->cwd);
    800053f6:	15093503          	ld	a0,336(s2)
    800053fa:	ff3fd0ef          	jal	800033ec <iput>
  end_op();
    800053fe:	971fe0ef          	jal	80003d6e <end_op>
  p->cwd = ip;
    80005402:	14993823          	sd	s1,336(s2)
  return 0;
    80005406:	4501                	li	a0,0
    80005408:	64aa                	ld	s1,136(sp)
}
    8000540a:	60ea                	ld	ra,152(sp)
    8000540c:	644a                	ld	s0,144(sp)
    8000540e:	690a                	ld	s2,128(sp)
    80005410:	610d                	addi	sp,sp,160
    80005412:	8082                	ret
    80005414:	64aa                	ld	s1,136(sp)
    end_op();
    80005416:	959fe0ef          	jal	80003d6e <end_op>
    return -1;
    8000541a:	557d                	li	a0,-1
    8000541c:	b7fd                	j	8000540a <sys_chdir+0x5c>
    iunlockput(ip);
    8000541e:	8526                	mv	a0,s1
    80005420:	89efe0ef          	jal	800034be <iunlockput>
    end_op();
    80005424:	94bfe0ef          	jal	80003d6e <end_op>
    return -1;
    80005428:	557d                	li	a0,-1
    8000542a:	64aa                	ld	s1,136(sp)
    8000542c:	bff9                	j	8000540a <sys_chdir+0x5c>

000000008000542e <sys_exec>:

uint64
sys_exec(void)
{
    8000542e:	7105                	addi	sp,sp,-480
    80005430:	ef86                	sd	ra,472(sp)
    80005432:	eba2                	sd	s0,464(sp)
    80005434:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005436:	e2840593          	addi	a1,s0,-472
    8000543a:	4505                	li	a0,1
    8000543c:	c70fd0ef          	jal	800028ac <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    80005440:	08000613          	li	a2,128
    80005444:	f3040593          	addi	a1,s0,-208
    80005448:	4501                	li	a0,0
    8000544a:	c7efd0ef          	jal	800028c8 <argstr>
    8000544e:	87aa                	mv	a5,a0
    return -1;
    80005450:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005452:	0e07c063          	bltz	a5,80005532 <sys_exec+0x104>
    80005456:	e7a6                	sd	s1,456(sp)
    80005458:	e3ca                	sd	s2,448(sp)
    8000545a:	ff4e                	sd	s3,440(sp)
    8000545c:	fb52                	sd	s4,432(sp)
    8000545e:	f756                	sd	s5,424(sp)
    80005460:	f35a                	sd	s6,416(sp)
    80005462:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005464:	e3040a13          	addi	s4,s0,-464
    80005468:	10000613          	li	a2,256
    8000546c:	4581                	li	a1,0
    8000546e:	8552                	mv	a0,s4
    80005470:	879fb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    80005474:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005476:	89d2                	mv	s3,s4
    80005478:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000547a:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000547e:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    80005480:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005484:	00391513          	slli	a0,s2,0x3
    80005488:	85d6                	mv	a1,s5
    8000548a:	e2843783          	ld	a5,-472(s0)
    8000548e:	953e                	add	a0,a0,a5
    80005490:	b74fd0ef          	jal	80002804 <fetchaddr>
    80005494:	02054663          	bltz	a0,800054c0 <sys_exec+0x92>
    if (uarg == 0) {
    80005498:	e2043783          	ld	a5,-480(s0)
    8000549c:	c7a1                	beqz	a5,800054e4 <sys_exec+0xb6>
    argv[i] = kalloc();
    8000549e:	eb0fb0ef          	jal	80000b4e <kalloc>
    800054a2:	85aa                	mv	a1,a0
    800054a4:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    800054a8:	cd01                	beqz	a0,800054c0 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800054aa:	865a                	mv	a2,s6
    800054ac:	e2043503          	ld	a0,-480(s0)
    800054b0:	b9efd0ef          	jal	8000284e <fetchstr>
    800054b4:	00054663          	bltz	a0,800054c0 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    800054b8:	0905                	addi	s2,s2,1
    800054ba:	09a1                	addi	s3,s3,8
    800054bc:	fd7914e3          	bne	s2,s7,80005484 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054c0:	100a0a13          	addi	s4,s4,256
    800054c4:	6088                	ld	a0,0(s1)
    800054c6:	cd31                	beqz	a0,80005522 <sys_exec+0xf4>
    kfree(argv[i]);
    800054c8:	d9efb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054cc:	04a1                	addi	s1,s1,8
    800054ce:	ff449be3          	bne	s1,s4,800054c4 <sys_exec+0x96>
  return -1;
    800054d2:	557d                	li	a0,-1
    800054d4:	64be                	ld	s1,456(sp)
    800054d6:	691e                	ld	s2,448(sp)
    800054d8:	79fa                	ld	s3,440(sp)
    800054da:	7a5a                	ld	s4,432(sp)
    800054dc:	7aba                	ld	s5,424(sp)
    800054de:	7b1a                	ld	s6,416(sp)
    800054e0:	6bfa                	ld	s7,408(sp)
    800054e2:	a881                	j	80005532 <sys_exec+0x104>
      argv[i] = 0;
    800054e4:	0009079b          	sext.w	a5,s2
    800054e8:	e3040593          	addi	a1,s0,-464
    800054ec:	078e                	slli	a5,a5,0x3
    800054ee:	97ae                	add	a5,a5,a1
    800054f0:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    800054f4:	f3040513          	addi	a0,s0,-208
    800054f8:	b62ff0ef          	jal	8000485a <kexec>
    800054fc:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054fe:	100a0a13          	addi	s4,s4,256
    80005502:	6088                	ld	a0,0(s1)
    80005504:	c511                	beqz	a0,80005510 <sys_exec+0xe2>
    kfree(argv[i]);
    80005506:	d60fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000550a:	04a1                	addi	s1,s1,8
    8000550c:	ff449be3          	bne	s1,s4,80005502 <sys_exec+0xd4>
  return ret;
    80005510:	854a                	mv	a0,s2
    80005512:	64be                	ld	s1,456(sp)
    80005514:	691e                	ld	s2,448(sp)
    80005516:	79fa                	ld	s3,440(sp)
    80005518:	7a5a                	ld	s4,432(sp)
    8000551a:	7aba                	ld	s5,424(sp)
    8000551c:	7b1a                	ld	s6,416(sp)
    8000551e:	6bfa                	ld	s7,408(sp)
    80005520:	a809                	j	80005532 <sys_exec+0x104>
  return -1;
    80005522:	557d                	li	a0,-1
    80005524:	64be                	ld	s1,456(sp)
    80005526:	691e                	ld	s2,448(sp)
    80005528:	79fa                	ld	s3,440(sp)
    8000552a:	7a5a                	ld	s4,432(sp)
    8000552c:	7aba                	ld	s5,424(sp)
    8000552e:	7b1a                	ld	s6,416(sp)
    80005530:	6bfa                	ld	s7,408(sp)
}
    80005532:	60fe                	ld	ra,472(sp)
    80005534:	645e                	ld	s0,464(sp)
    80005536:	613d                	addi	sp,sp,480
    80005538:	8082                	ret

000000008000553a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000553a:	7139                	addi	sp,sp,-64
    8000553c:	fc06                	sd	ra,56(sp)
    8000553e:	f822                	sd	s0,48(sp)
    80005540:	f426                	sd	s1,40(sp)
    80005542:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005544:	c04fc0ef          	jal	80001948 <myproc>
    80005548:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000554a:	fd840593          	addi	a1,s0,-40
    8000554e:	4501                	li	a0,0
    80005550:	b5cfd0ef          	jal	800028ac <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005554:	fc840593          	addi	a1,s0,-56
    80005558:	fd040513          	addi	a0,s0,-48
    8000555c:	f7ffe0ef          	jal	800044da <pipealloc>
    return -1;
    80005560:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005562:	0a054963          	bltz	a0,80005614 <sys_pipe+0xda>
  fd0 = -1;
    80005566:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    8000556a:	fd043503          	ld	a0,-48(s0)
    8000556e:	ea0ff0ef          	jal	80004c0e <fdalloc>
    80005572:	fca42223          	sw	a0,-60(s0)
    80005576:	08054663          	bltz	a0,80005602 <sys_pipe+0xc8>
    8000557a:	fc843503          	ld	a0,-56(s0)
    8000557e:	e90ff0ef          	jal	80004c0e <fdalloc>
    80005582:	fca42023          	sw	a0,-64(s0)
    80005586:	06054463          	bltz	a0,800055ee <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    8000558a:	4711                	li	a4,4
    8000558c:	fc440693          	addi	a3,s0,-60
    80005590:	fd843603          	ld	a2,-40(s0)
    80005594:	64ac                	ld	a1,72(s1)
    80005596:	68a8                	ld	a0,80(s1)
    80005598:	febfb0ef          	jal	80001582 <copyout>
    8000559c:	00054f63          	bltz	a0,800055ba <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    800055a0:	4711                	li	a4,4
    800055a2:	fc040693          	addi	a3,s0,-64
    800055a6:	fd843603          	ld	a2,-40(s0)
    800055aa:	963a                	add	a2,a2,a4
    800055ac:	64ac                	ld	a1,72(s1)
    800055ae:	68a8                	ld	a0,80(s1)
    800055b0:	fd3fb0ef          	jal	80001582 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800055b4:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800055b6:	04055f63          	bgez	a0,80005614 <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    800055ba:	fc442783          	lw	a5,-60(s0)
    800055be:	078e                	slli	a5,a5,0x3
    800055c0:	0d078793          	addi	a5,a5,208
    800055c4:	97a6                	add	a5,a5,s1
    800055c6:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800055ca:	fc042783          	lw	a5,-64(s0)
    800055ce:	078e                	slli	a5,a5,0x3
    800055d0:	0d078793          	addi	a5,a5,208
    800055d4:	94be                	add	s1,s1,a5
    800055d6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800055da:	fd043503          	ld	a0,-48(s0)
    800055de:	bbffe0ef          	jal	8000419c <fileclose>
    fileclose(wf);
    800055e2:	fc843503          	ld	a0,-56(s0)
    800055e6:	bb7fe0ef          	jal	8000419c <fileclose>
    return -1;
    800055ea:	57fd                	li	a5,-1
    800055ec:	a025                	j	80005614 <sys_pipe+0xda>
    if (fd0 >= 0)
    800055ee:	fc442783          	lw	a5,-60(s0)
    800055f2:	0007c863          	bltz	a5,80005602 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    800055f6:	078e                	slli	a5,a5,0x3
    800055f8:	0d078793          	addi	a5,a5,208
    800055fc:	97a6                	add	a5,a5,s1
    800055fe:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005602:	fd043503          	ld	a0,-48(s0)
    80005606:	b97fe0ef          	jal	8000419c <fileclose>
    fileclose(wf);
    8000560a:	fc843503          	ld	a0,-56(s0)
    8000560e:	b8ffe0ef          	jal	8000419c <fileclose>
    return -1;
    80005612:	57fd                	li	a5,-1
}
    80005614:	853e                	mv	a0,a5
    80005616:	70e2                	ld	ra,56(sp)
    80005618:	7442                	ld	s0,48(sp)
    8000561a:	74a2                	ld	s1,40(sp)
    8000561c:	6121                	addi	sp,sp,64
    8000561e:	8082                	ret

0000000080005620 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005620:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005622:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005624:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005626:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005628:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000562a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000562c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000562e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005630:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005632:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005634:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005636:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005638:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000563a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000563c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000563e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005640:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005642:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005644:	8cefd0ef          	jal	80002712 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005648:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000564a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000564c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000564e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005650:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005652:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005654:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005656:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005658:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000565a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000565c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000565e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005660:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005662:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005664:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005666:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005668:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000566a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000566c:	10200073          	sret
    80005670:	0001                	nop
    80005672:	00000013          	nop
    80005676:	00000013          	nop
    8000567a:	00000013          	nop

000000008000567e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000567e:	1141                	addi	sp,sp,-16
    80005680:	e406                	sd	ra,8(sp)
    80005682:	e022                	sd	s0,0(sp)
    80005684:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005686:	0c000737          	lui	a4,0xc000
    8000568a:	4785                	li	a5,1
    8000568c:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000568e:	c35c                	sw	a5,4(a4)
}
    80005690:	60a2                	ld	ra,8(sp)
    80005692:	6402                	ld	s0,0(sp)
    80005694:	0141                	addi	sp,sp,16
    80005696:	8082                	ret

0000000080005698 <plicinithart>:

void
plicinithart(void)
{
    80005698:	1141                	addi	sp,sp,-16
    8000569a:	e406                	sd	ra,8(sp)
    8000569c:	e022                	sd	s0,0(sp)
    8000569e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056a0:	a74fc0ef          	jal	80001914 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    800056a4:	0085179b          	slliw	a5,a0,0x8
    800056a8:	0c002737          	lui	a4,0xc002
    800056ac:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    800056b0:	97ba                	add	a5,a5,a4
    800056b2:	40200713          	li	a4,1026
    800056b6:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    800056b8:	00d5151b          	slliw	a0,a0,0xd
    800056bc:	0c2017b7          	lui	a5,0xc201
    800056c0:	953e                	add	a0,a0,a5
    800056c2:	00052023          	sw	zero,0(a0)
}
    800056c6:	60a2                	ld	ra,8(sp)
    800056c8:	6402                	ld	s0,0(sp)
    800056ca:	0141                	addi	sp,sp,16
    800056cc:	8082                	ret

00000000800056ce <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800056ce:	1141                	addi	sp,sp,-16
    800056d0:	e406                	sd	ra,8(sp)
    800056d2:	e022                	sd	s0,0(sp)
    800056d4:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056d6:	a3efc0ef          	jal	80001914 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    800056da:	00d5151b          	slliw	a0,a0,0xd
    800056de:	0c2017b7          	lui	a5,0xc201
    800056e2:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    800056e4:	953e                	add	a0,a0,a5
    800056e6:	4108                	lw	a0,0(a0)
  return irq;
}
    800056e8:	60a2                	ld	ra,8(sp)
    800056ea:	6402                	ld	s0,0(sp)
    800056ec:	0141                	addi	sp,sp,16
    800056ee:	8082                	ret

00000000800056f0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800056f0:	1101                	addi	sp,sp,-32
    800056f2:	ec06                	sd	ra,24(sp)
    800056f4:	e822                	sd	s0,16(sp)
    800056f6:	e426                	sd	s1,8(sp)
    800056f8:	1000                	addi	s0,sp,32
    800056fa:	84aa                	mv	s1,a0
  int hart = cpuid();
    800056fc:	a18fc0ef          	jal	80001914 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    80005700:	00d5179b          	slliw	a5,a0,0xd
    80005704:	0c201737          	lui	a4,0xc201
    80005708:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    8000570a:	97ba                	add	a5,a5,a4
    8000570c:	c384                	sw	s1,0(a5)
}
    8000570e:	60e2                	ld	ra,24(sp)
    80005710:	6442                	ld	s0,16(sp)
    80005712:	64a2                	ld	s1,8(sp)
    80005714:	6105                	addi	sp,sp,32
    80005716:	8082                	ret

0000000080005718 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005718:	1141                	addi	sp,sp,-16
    8000571a:	e406                	sd	ra,8(sp)
    8000571c:	e022                	sd	s0,0(sp)
    8000571e:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005720:	479d                	li	a5,7
    80005722:	04a7ca63          	blt	a5,a0,80005776 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005726:	0001e797          	auipc	a5,0x1e
    8000572a:	da278793          	addi	a5,a5,-606 # 800234c8 <disk>
    8000572e:	97aa                	add	a5,a5,a0
    80005730:	0187c783          	lbu	a5,24(a5)
    80005734:	e7b9                	bnez	a5,80005782 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005736:	00451693          	slli	a3,a0,0x4
    8000573a:	0001e797          	auipc	a5,0x1e
    8000573e:	d8e78793          	addi	a5,a5,-626 # 800234c8 <disk>
    80005742:	6398                	ld	a4,0(a5)
    80005744:	9736                	add	a4,a4,a3
    80005746:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000574a:	6398                	ld	a4,0(a5)
    8000574c:	9736                	add	a4,a4,a3
    8000574e:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005752:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005756:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000575a:	97aa                	add	a5,a5,a0
    8000575c:	4705                	li	a4,1
    8000575e:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005762:	0001e517          	auipc	a0,0x1e
    80005766:	d7e50513          	addi	a0,a0,-642 # 800234e0 <disk+0x18>
    8000576a:	855fc0ef          	jal	80001fbe <wakeup>
}
    8000576e:	60a2                	ld	ra,8(sp)
    80005770:	6402                	ld	s0,0(sp)
    80005772:	0141                	addi	sp,sp,16
    80005774:	8082                	ret
    panic("free_desc 1");
    80005776:	00002517          	auipc	a0,0x2
    8000577a:	eba50513          	addi	a0,a0,-326 # 80007630 <etext+0x630>
    8000577e:	8b6fb0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    80005782:	00002517          	auipc	a0,0x2
    80005786:	ebe50513          	addi	a0,a0,-322 # 80007640 <etext+0x640>
    8000578a:	8aafb0ef          	jal	80000834 <panic>

000000008000578e <virtio_disk_init>:
{
    8000578e:	1101                	addi	sp,sp,-32
    80005790:	ec06                	sd	ra,24(sp)
    80005792:	e822                	sd	s0,16(sp)
    80005794:	e426                	sd	s1,8(sp)
    80005796:	e04a                	sd	s2,0(sp)
    80005798:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000579a:	00002597          	auipc	a1,0x2
    8000579e:	eb658593          	addi	a1,a1,-330 # 80007650 <etext+0x650>
    800057a2:	0001e517          	auipc	a0,0x1e
    800057a6:	e4e50513          	addi	a0,a0,-434 # 800235f0 <disk+0x128>
    800057aa:	bfefb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057ae:	100017b7          	lui	a5,0x10001
    800057b2:	4398                	lw	a4,0(a5)
    800057b4:	2701                	sext.w	a4,a4
    800057b6:	747277b7          	lui	a5,0x74727
    800057ba:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800057be:	14f71863          	bne	a4,a5,8000590e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057c2:	100017b7          	lui	a5,0x10001
    800057c6:	43dc                	lw	a5,4(a5)
    800057c8:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057ca:	4709                	li	a4,2
    800057cc:	14e79163          	bne	a5,a4,8000590e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057d0:	100017b7          	lui	a5,0x10001
    800057d4:	479c                	lw	a5,8(a5)
    800057d6:	2781                	sext.w	a5,a5
    800057d8:	12e79b63          	bne	a5,a4,8000590e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    800057dc:	100017b7          	lui	a5,0x10001
    800057e0:	47d8                	lw	a4,12(a5)
    800057e2:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057e4:	554d47b7          	lui	a5,0x554d4
    800057e8:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800057ec:	12f71163          	bne	a4,a5,8000590e <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057f0:	100017b7          	lui	a5,0x10001
    800057f4:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057f8:	4705                	li	a4,1
    800057fa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057fc:	470d                	li	a4,3
    800057fe:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005800:	10001737          	lui	a4,0x10001
    80005804:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005806:	c7ffe6b7          	lui	a3,0xc7ffe
    8000580a:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdaf57>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000580e:	8f75                	and	a4,a4,a3
    80005810:	100016b7          	lui	a3,0x10001
    80005814:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005816:	472d                	li	a4,11
    80005818:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000581a:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000581e:	439c                	lw	a5,0(a5)
    80005820:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005824:	8ba1                	andi	a5,a5,8
    80005826:	0e078a63          	beqz	a5,8000591a <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000582a:	100017b7          	lui	a5,0x10001
    8000582e:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005832:	43fc                	lw	a5,68(a5)
    80005834:	2781                	sext.w	a5,a5
    80005836:	0e079863          	bnez	a5,80005926 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000583a:	100017b7          	lui	a5,0x10001
    8000583e:	5bdc                	lw	a5,52(a5)
    80005840:	2781                	sext.w	a5,a5
  if (max == 0)
    80005842:	0e078863          	beqz	a5,80005932 <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005846:	471d                	li	a4,7
    80005848:	0ef77b63          	bgeu	a4,a5,8000593e <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    8000584c:	b02fb0ef          	jal	80000b4e <kalloc>
    80005850:	0001e497          	auipc	s1,0x1e
    80005854:	c7848493          	addi	s1,s1,-904 # 800234c8 <disk>
    80005858:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    8000585a:	af4fb0ef          	jal	80000b4e <kalloc>
    8000585e:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005860:	aeefb0ef          	jal	80000b4e <kalloc>
    80005864:	87aa                	mv	a5,a0
    80005866:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005868:	6088                	ld	a0,0(s1)
    8000586a:	0e050063          	beqz	a0,8000594a <virtio_disk_init+0x1bc>
    8000586e:	0001e717          	auipc	a4,0x1e
    80005872:	c6273703          	ld	a4,-926(a4) # 800234d0 <disk+0x8>
    80005876:	cb71                	beqz	a4,8000594a <virtio_disk_init+0x1bc>
    80005878:	cbe9                	beqz	a5,8000594a <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    8000587a:	6605                	lui	a2,0x1
    8000587c:	4581                	li	a1,0
    8000587e:	c6afb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005882:	0001e497          	auipc	s1,0x1e
    80005886:	c4648493          	addi	s1,s1,-954 # 800234c8 <disk>
    8000588a:	6605                	lui	a2,0x1
    8000588c:	4581                	li	a1,0
    8000588e:	6488                	ld	a0,8(s1)
    80005890:	c58fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005894:	6605                	lui	a2,0x1
    80005896:	4581                	li	a1,0
    80005898:	6888                	ld	a0,16(s1)
    8000589a:	c4efb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000589e:	100017b7          	lui	a5,0x10001
    800058a2:	4721                	li	a4,8
    800058a4:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800058a6:	4098                	lw	a4,0(s1)
    800058a8:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800058ac:	40d8                	lw	a4,4(s1)
    800058ae:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800058b2:	649c                	ld	a5,8(s1)
    800058b4:	0007869b          	sext.w	a3,a5
    800058b8:	10001737          	lui	a4,0x10001
    800058bc:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800058c0:	9781                	srai	a5,a5,0x20
    800058c2:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800058c6:	689c                	ld	a5,16(s1)
    800058c8:	0007869b          	sext.w	a3,a5
    800058cc:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800058d0:	9781                	srai	a5,a5,0x20
    800058d2:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800058d6:	4785                	li	a5,1
    800058d8:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800058da:	00f48c23          	sb	a5,24(s1)
    800058de:	00f48ca3          	sb	a5,25(s1)
    800058e2:	00f48d23          	sb	a5,26(s1)
    800058e6:	00f48da3          	sb	a5,27(s1)
    800058ea:	00f48e23          	sb	a5,28(s1)
    800058ee:	00f48ea3          	sb	a5,29(s1)
    800058f2:	00f48f23          	sb	a5,30(s1)
    800058f6:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800058fa:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800058fe:	07272823          	sw	s2,112(a4)
}
    80005902:	60e2                	ld	ra,24(sp)
    80005904:	6442                	ld	s0,16(sp)
    80005906:	64a2                	ld	s1,8(sp)
    80005908:	6902                	ld	s2,0(sp)
    8000590a:	6105                	addi	sp,sp,32
    8000590c:	8082                	ret
    panic("could not find virtio disk");
    8000590e:	00002517          	auipc	a0,0x2
    80005912:	d5250513          	addi	a0,a0,-686 # 80007660 <etext+0x660>
    80005916:	f1ffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000591a:	00002517          	auipc	a0,0x2
    8000591e:	d6650513          	addi	a0,a0,-666 # 80007680 <etext+0x680>
    80005922:	f13fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005926:	00002517          	auipc	a0,0x2
    8000592a:	d7a50513          	addi	a0,a0,-646 # 800076a0 <etext+0x6a0>
    8000592e:	f07fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005932:	00002517          	auipc	a0,0x2
    80005936:	d8e50513          	addi	a0,a0,-626 # 800076c0 <etext+0x6c0>
    8000593a:	efbfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    8000593e:	00002517          	auipc	a0,0x2
    80005942:	da250513          	addi	a0,a0,-606 # 800076e0 <etext+0x6e0>
    80005946:	eeffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    8000594a:	00002517          	auipc	a0,0x2
    8000594e:	db650513          	addi	a0,a0,-586 # 80007700 <etext+0x700>
    80005952:	ee3fa0ef          	jal	80000834 <panic>

0000000080005956 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005956:	711d                	addi	sp,sp,-96
    80005958:	ec86                	sd	ra,88(sp)
    8000595a:	e8a2                	sd	s0,80(sp)
    8000595c:	e4a6                	sd	s1,72(sp)
    8000595e:	e0ca                	sd	s2,64(sp)
    80005960:	fc4e                	sd	s3,56(sp)
    80005962:	f852                	sd	s4,48(sp)
    80005964:	f456                	sd	s5,40(sp)
    80005966:	f05a                	sd	s6,32(sp)
    80005968:	ec5e                	sd	s7,24(sp)
    8000596a:	e862                	sd	s8,16(sp)
    8000596c:	1080                	addi	s0,sp,96
    8000596e:	89aa                	mv	s3,a0
    80005970:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005972:	00c52b83          	lw	s7,12(a0)
    80005976:	001b9b9b          	slliw	s7,s7,0x1
    8000597a:	1b82                	slli	s7,s7,0x20
    8000597c:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005980:	0001e517          	auipc	a0,0x1e
    80005984:	c7050513          	addi	a0,a0,-912 # 800235f0 <disk+0x128>
    80005988:	aa0fb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    8000598c:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000598e:	0001ea97          	auipc	s5,0x1e
    80005992:	b3aa8a93          	addi	s5,s5,-1222 # 800234c8 <disk>
  for (int i = 0; i < 3; i++) {
    80005996:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005998:	5c7d                	li	s8,-1
    8000599a:	a8a5                	j	80005a12 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    8000599c:	00fa8733          	add	a4,s5,a5
    800059a0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800059a4:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    800059a6:	0207c563          	bltz	a5,800059d0 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    800059aa:	2905                	addiw	s2,s2,1
    800059ac:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800059ae:	07490663          	beq	s2,s4,80005a1a <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    800059b2:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    800059b4:	0001e717          	auipc	a4,0x1e
    800059b8:	b1470713          	addi	a4,a4,-1260 # 800234c8 <disk>
    800059bc:	4781                	li	a5,0
    if (disk.free[i]) {
    800059be:	01874683          	lbu	a3,24(a4)
    800059c2:	fee9                	bnez	a3,8000599c <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    800059c4:	2785                	addiw	a5,a5,1
    800059c6:	0705                	addi	a4,a4,1
    800059c8:	fe979be3          	bne	a5,s1,800059be <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    800059cc:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    800059d0:	01205d63          	blez	s2,800059ea <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    800059d4:	fa042503          	lw	a0,-96(s0)
    800059d8:	d41ff0ef          	jal	80005718 <free_desc>
      for (int j = 0; j < i; j++)
    800059dc:	4785                	li	a5,1
    800059de:	0127d663          	bge	a5,s2,800059ea <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    800059e2:	fa442503          	lw	a0,-92(s0)
    800059e6:	d33ff0ef          	jal	80005718 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    800059ea:	0001e517          	auipc	a0,0x1e
    800059ee:	af650513          	addi	a0,a0,-1290 # 800234e0 <disk+0x18>
    800059f2:	d60fc0ef          	jal	80001f52 <sleep_prepare>
    release(&disk.vdisk_lock);
    800059f6:	0001e517          	auipc	a0,0x1e
    800059fa:	bfa50513          	addi	a0,a0,-1030 # 800235f0 <disk+0x128>
    800059fe:	ab2fb0ef          	jal	80000cb0 <release>
    sleep();
    80005a02:	d8cfc0ef          	jal	80001f8e <sleep>
    acquire(&disk.vdisk_lock);
    80005a06:	0001e517          	auipc	a0,0x1e
    80005a0a:	bea50513          	addi	a0,a0,-1046 # 800235f0 <disk+0x128>
    80005a0e:	a1afb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005a12:	fa040613          	addi	a2,s0,-96
    80005a16:	4901                	li	s2,0
    80005a18:	bf69                	j	800059b2 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a1a:	fa042503          	lw	a0,-96(s0)
    80005a1e:	00451693          	slli	a3,a0,0x4

  if (write)
    80005a22:	0001e797          	auipc	a5,0x1e
    80005a26:	aa678793          	addi	a5,a5,-1370 # 800234c8 <disk>
    80005a2a:	00451713          	slli	a4,a0,0x4
    80005a2e:	0a070713          	addi	a4,a4,160
    80005a32:	973e                	add	a4,a4,a5
    80005a34:	01603633          	snez	a2,s6
    80005a38:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005a3a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005a3e:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005a42:	6398                	ld	a4,0(a5)
    80005a44:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a46:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005a4a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005a4c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005a4e:	6390                	ld	a2,0(a5)
    80005a50:	00d60833          	add	a6,a2,a3
    80005a54:	4741                	li	a4,16
    80005a56:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005a5a:	4585                	li	a1,1
    80005a5c:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005a60:	fa442703          	lw	a4,-92(s0)
    80005a64:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005a68:	0712                	slli	a4,a4,0x4
    80005a6a:	963a                	add	a2,a2,a4
    80005a6c:	05898813          	addi	a6,s3,88
    80005a70:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005a74:	0007b883          	ld	a7,0(a5)
    80005a78:	9746                	add	a4,a4,a7
    80005a7a:	40000613          	li	a2,1024
    80005a7e:	c710                	sw	a2,8(a4)
  if (write)
    80005a80:	001b3613          	seqz	a2,s6
    80005a84:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005a88:	8e4d                	or	a2,a2,a1
    80005a8a:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005a8e:	fa842603          	lw	a2,-88(s0)
    80005a92:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005a96:	00451813          	slli	a6,a0,0x4
    80005a9a:	02080813          	addi	a6,a6,32
    80005a9e:	983e                	add	a6,a6,a5
    80005aa0:	577d                	li	a4,-1
    80005aa2:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005aa6:	0612                	slli	a2,a2,0x4
    80005aa8:	98b2                	add	a7,a7,a2
    80005aaa:	03068713          	addi	a4,a3,48
    80005aae:	973e                	add	a4,a4,a5
    80005ab0:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005ab4:	6398                	ld	a4,0(a5)
    80005ab6:	9732                	add	a4,a4,a2
    80005ab8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005aba:	4689                	li	a3,2
    80005abc:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005ac0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005ac4:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005ac8:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005acc:	6794                	ld	a3,8(a5)
    80005ace:	0026d703          	lhu	a4,2(a3)
    80005ad2:	8b1d                	andi	a4,a4,7
    80005ad4:	0706                	slli	a4,a4,0x1
    80005ad6:	96ba                	add	a3,a3,a4
    80005ad8:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005adc:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005ae0:	6798                	ld	a4,8(a5)
    80005ae2:	00275783          	lhu	a5,2(a4)
    80005ae6:	2785                	addiw	a5,a5,1
    80005ae8:	00f71123          	sh	a5,2(a4)
    80005aec:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005af0:	100017b7          	lui	a5,0x10001
    80005af4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005af8:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005afc:	0001e497          	auipc	s1,0x1e
    80005b00:	af448493          	addi	s1,s1,-1292 # 800235f0 <disk+0x128>
  while (b->disk == 1) {
    80005b04:	892e                	mv	s2,a1
    80005b06:	02b79163          	bne	a5,a1,80005b28 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005b0a:	854e                	mv	a0,s3
    80005b0c:	c46fc0ef          	jal	80001f52 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005b10:	8526                	mv	a0,s1
    80005b12:	99efb0ef          	jal	80000cb0 <release>
    sleep();
    80005b16:	c78fc0ef          	jal	80001f8e <sleep>
    acquire(&disk.vdisk_lock);
    80005b1a:	8526                	mv	a0,s1
    80005b1c:	90cfb0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005b20:	0049a783          	lw	a5,4(s3)
    80005b24:	ff2783e3          	beq	a5,s2,80005b0a <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005b28:	fa042903          	lw	s2,-96(s0)
    80005b2c:	00491713          	slli	a4,s2,0x4
    80005b30:	02070713          	addi	a4,a4,32
    80005b34:	0001e797          	auipc	a5,0x1e
    80005b38:	99478793          	addi	a5,a5,-1644 # 800234c8 <disk>
    80005b3c:	97ba                	add	a5,a5,a4
    80005b3e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005b42:	0001e997          	auipc	s3,0x1e
    80005b46:	98698993          	addi	s3,s3,-1658 # 800234c8 <disk>
    80005b4a:	00491713          	slli	a4,s2,0x4
    80005b4e:	0009b783          	ld	a5,0(s3)
    80005b52:	97ba                	add	a5,a5,a4
    80005b54:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005b58:	854a                	mv	a0,s2
    80005b5a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005b5e:	bbbff0ef          	jal	80005718 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005b62:	8885                	andi	s1,s1,1
    80005b64:	f0fd                	bnez	s1,80005b4a <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005b66:	0001e517          	auipc	a0,0x1e
    80005b6a:	a8a50513          	addi	a0,a0,-1398 # 800235f0 <disk+0x128>
    80005b6e:	942fb0ef          	jal	80000cb0 <release>
}
    80005b72:	60e6                	ld	ra,88(sp)
    80005b74:	6446                	ld	s0,80(sp)
    80005b76:	64a6                	ld	s1,72(sp)
    80005b78:	6906                	ld	s2,64(sp)
    80005b7a:	79e2                	ld	s3,56(sp)
    80005b7c:	7a42                	ld	s4,48(sp)
    80005b7e:	7aa2                	ld	s5,40(sp)
    80005b80:	7b02                	ld	s6,32(sp)
    80005b82:	6be2                	ld	s7,24(sp)
    80005b84:	6c42                	ld	s8,16(sp)
    80005b86:	6125                	addi	sp,sp,96
    80005b88:	8082                	ret

0000000080005b8a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005b8a:	1101                	addi	sp,sp,-32
    80005b8c:	ec06                	sd	ra,24(sp)
    80005b8e:	e822                	sd	s0,16(sp)
    80005b90:	e426                	sd	s1,8(sp)
    80005b92:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005b94:	0001e497          	auipc	s1,0x1e
    80005b98:	93448493          	addi	s1,s1,-1740 # 800234c8 <disk>
    80005b9c:	0001e517          	auipc	a0,0x1e
    80005ba0:	a5450513          	addi	a0,a0,-1452 # 800235f0 <disk+0x128>
    80005ba4:	884fb0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005ba8:	100017b7          	lui	a5,0x10001
    80005bac:	53bc                	lw	a5,96(a5)
    80005bae:	8b8d                	andi	a5,a5,3
    80005bb0:	10001737          	lui	a4,0x10001
    80005bb4:	d37c                	sw	a5,100(a4)
    80005bb6:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005bba:	689c                	ld	a5,16(s1)
    80005bbc:	0204d703          	lhu	a4,32(s1)
    80005bc0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005bc4:	04f70863          	beq	a4,a5,80005c14 <virtio_disk_intr+0x8a>
    80005bc8:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005bcc:	6898                	ld	a4,16(s1)
    80005bce:	0204d783          	lhu	a5,32(s1)
    80005bd2:	8b9d                	andi	a5,a5,7
    80005bd4:	078e                	slli	a5,a5,0x3
    80005bd6:	97ba                	add	a5,a5,a4
    80005bd8:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005bda:	00479713          	slli	a4,a5,0x4
    80005bde:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005be2:	9726                	add	a4,a4,s1
    80005be4:	01074703          	lbu	a4,16(a4)
    80005be8:	e329                	bnez	a4,80005c2a <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005bea:	0792                	slli	a5,a5,0x4
    80005bec:	02078793          	addi	a5,a5,32
    80005bf0:	97a6                	add	a5,a5,s1
    80005bf2:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005bf4:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005bf8:	bc6fc0ef          	jal	80001fbe <wakeup>

    disk.used_idx += 1;
    80005bfc:	0204d783          	lhu	a5,32(s1)
    80005c00:	2785                	addiw	a5,a5,1
    80005c02:	17c2                	slli	a5,a5,0x30
    80005c04:	93c1                	srli	a5,a5,0x30
    80005c06:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005c0a:	6898                	ld	a4,16(s1)
    80005c0c:	00275703          	lhu	a4,2(a4)
    80005c10:	faf71ce3          	bne	a4,a5,80005bc8 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005c14:	0001e517          	auipc	a0,0x1e
    80005c18:	9dc50513          	addi	a0,a0,-1572 # 800235f0 <disk+0x128>
    80005c1c:	894fb0ef          	jal	80000cb0 <release>
}
    80005c20:	60e2                	ld	ra,24(sp)
    80005c22:	6442                	ld	s0,16(sp)
    80005c24:	64a2                	ld	s1,8(sp)
    80005c26:	6105                	addi	sp,sp,32
    80005c28:	8082                	ret
      panic("virtio_disk_intr status");
    80005c2a:	00002517          	auipc	a0,0x2
    80005c2e:	aee50513          	addi	a0,a0,-1298 # 80007718 <etext+0x718>
    80005c32:	c03fa0ef          	jal	80000834 <panic>
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
