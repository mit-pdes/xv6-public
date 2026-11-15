
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
    80000004:	3d813103          	ld	sp,984(sp) # 8000a3d8 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdaed7>
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
    8000011c:	408020ef          	jal	80002524 <either_copyin>
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
    80000198:	28c50513          	addi	a0,a0,652 # 80012420 <cons>
    8000019c:	28d000ef          	jal	80000c28 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	28048493          	addi	s1,s1,640 # 80012420 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	31090913          	addi	s2,s2,784 # 800124b8 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	788010ef          	jal	80001948 <myproc>
    800001c4:	1e0020ef          	jal	800023a4 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	77b010ef          	jal	80002146 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	7ad010ef          	jal	80002182 <sleep>
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
    800001f2:	23270713          	addi	a4,a4,562 # 80012420 <cons>
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
    80000220:	2b8020ef          	jal	800024d8 <either_copyout>
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
    8000023c:	1e850513          	addi	a0,a0,488 # 80012420 <cons>
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
    80000262:	24f72d23          	sw	a5,602(a4) # 800124b8 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	1ac50513          	addi	a0,a0,428 # 80012420 <cons>
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
    800002cc:	15850513          	addi	a0,a0,344 # 80012420 <cons>
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
    800002ea:	286020ef          	jal	80002570 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	13250513          	addi	a0,a0,306 # 80012420 <cons>
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
    80000310:	11470713          	addi	a4,a4,276 # 80012420 <cons>
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
    80000336:	0ee70713          	addi	a4,a4,238 # 80012420 <cons>
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
    80000360:	15c72703          	lw	a4,348(a4) # 800124b8 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	0ae70713          	addi	a4,a4,174 # 80012420 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	09e48493          	addi	s1,s1,158 # 80012420 <cons>
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
    800003c8:	05c70713          	addi	a4,a4,92 # 80012420 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	0ef72323          	sw	a5,230(a4) # 800124c0 <cons+0xa0>
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
    800003fc:	02878793          	addi	a5,a5,40 # 80012420 <cons>
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
    8000041e:	0ac7a123          	sw	a2,162(a5) # 800124bc <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	09650513          	addi	a0,a0,150 # 800124b8 <cons+0x98>
    8000042a:	589010ef          	jal	800021b2 <wakeup>
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
    80000444:	fe050513          	addi	a0,a0,-32 # 80012420 <cons>
    80000448:	760000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	34078793          	addi	a5,a5,832 # 80022790 <devsw>
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
    8000052c:	ecc7a783          	lw	a5,-308(a5) # 8000a3f4 <panicking>
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
    80000572:	f5a50513          	addi	a0,a0,-166 # 800124c8 <pr>
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
    8000076e:	c8a7a783          	lw	a5,-886(a5) # 8000a3f4 <panicking>
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
    80000798:	d3450513          	addi	a0,a0,-716 # 800124c8 <pr>
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
    80000848:	ba97a823          	sw	s1,-1104(a5) # 8000a3f4 <panicking>
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
    8000086a:	b897a523          	sw	s1,-1142(a5) # 8000a3f0 <panicked>
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
    80000884:	c4850513          	addi	a0,a0,-952 # 800124c8 <pr>
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
    800008da:	c0a50513          	addi	a0,a0,-1014 # 800124e0 <tx_lock>
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
    800008fe:	be650513          	addi	a0,a0,-1050 # 800124e0 <tx_lock>
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
    8000091c:	ae490913          	addi	s2,s2,-1308 # 8000a3fc <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	ad898993          	addi	s3,s3,-1320 # 8000a3f8 <tx_chan>
      release(&tx_lock);
    80000928:	00012497          	auipc	s1,0x12
    8000092c:	bb848493          	addi	s1,s1,-1096 # 800124e0 <tx_lock>
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
    8000093a:	00d010ef          	jal	80002146 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	03f010ef          	jal	80002182 <sleep>
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
    8000097c:	b6850513          	addi	a0,a0,-1176 # 800124e0 <tx_lock>
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
    800009a0:	a587a783          	lw	a5,-1448(a5) # 8000a3f4 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	a4a7a783          	lw	a5,-1462(a5) # 8000a3f0 <panicked>
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
    800009d0:	a287a783          	lw	a5,-1496(a5) # 8000a3f4 <panicking>
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
    80000a06:	ade50513          	addi	a0,a0,-1314 # 800124e0 <tx_lock>
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
    80000a20:	ac450513          	addi	a0,a0,-1340 # 800124e0 <tx_lock>
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
    80000a48:	9a07ac23          	sw	zero,-1608(a5) # 8000a3fc <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	9ac50513          	addi	a0,a0,-1620 # 8000a3f8 <tx_chan>
    80000a54:	75e010ef          	jal	800021b2 <wakeup>
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
    80000a76:	eb678793          	addi	a5,a5,-330 # 80023928 <end>
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
    80000aa0:	a5c90913          	addi	s2,s2,-1444 # 800124f8 <kmem>
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
    80000b2e:	9ce50513          	addi	a0,a0,-1586 # 800124f8 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00023517          	auipc	a0,0x23
    80000b3e:	dee50513          	addi	a0,a0,-530 # 80023928 <end>
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
    80000b5c:	9a050513          	addi	a0,a0,-1632 # 800124f8 <kmem>
    80000b60:	0c8000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b64:	00012497          	auipc	s1,0x12
    80000b68:	9ac4b483          	ld	s1,-1620(s1) # 80012510 <kmem+0x18>
  if (r)
    80000b6c:	c49d                	beqz	s1,80000b9a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00012717          	auipc	a4,0x12
    80000b74:	9af73023          	sd	a5,-1632(a4) # 80012510 <kmem+0x18>
  release(&kmem.lock);
    80000b78:	00012517          	auipc	a0,0x12
    80000b7c:	98050513          	addi	a0,a0,-1664 # 800124f8 <kmem>
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
    80000b9e:	95e50513          	addi	a0,a0,-1698 # 800124f8 <kmem>
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
    80000eae:	55670713          	addi	a4,a4,1366 # 8000a400 <started>
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
    80000ed4:	7ce010ef          	jal	800026a2 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	211040ef          	jal	800058e8 <plicinithart>
  }

  scheduler();
    80000edc:	054010ef          	jal	80001f30 <scheduler>
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
    80000f1c:	762010ef          	jal	8000267e <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	782010ef          	jal	800026a2 <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	1ab040ef          	jal	800058ce <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	1c1040ef          	jal	800058e8 <plicinithart>
    binit();            // buffer cache
    80000f2c:	66b010ef          	jal	80002d96 <binit>
    iinit();            // inode table
    80000f30:	3bc020ef          	jal	800032ec <iinit>
    fileinit();         // file table
    80000f34:	3ea030ef          	jal	8000431e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	2a7040ef          	jal	800059de <virtio_disk_init>
    userinit();         // first user process
    80000f3c:	4e3000ef          	jal	80001c1e <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f40:	00009797          	auipc	a5,0x9
    80000f44:	4c078793          	addi	a5,a5,1216 # 8000a400 <started>
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
    80000f62:	4aa7b783          	ld	a5,1194(a5) # 8000a408 <kernel_pagetable>
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
    800011ee:	20a7bf23          	sd	a0,542(a5) # 8000a408 <kernel_pagetable>
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
    80001724:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb6d8>
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
    800017d8:	17448493          	addi	s1,s1,372 # 80012948 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017dc:	8c26                	mv	s8,s1
    800017de:	ff4df937          	lui	s2,0xff4df
    800017e2:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb095>
    800017e6:	0936                	slli	s2,s2,0xd
    800017e8:	6f590913          	addi	s2,s2,1781
    800017ec:	0936                	slli	s2,s2,0xd
    800017ee:	bd390913          	addi	s2,s2,-1069
    800017f2:	0932                	slli	s2,s2,0xc
    800017f4:	7a790913          	addi	s2,s2,1959
    800017f8:	040009b7          	lui	s3,0x4000
    800017fc:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017fe:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001800:	4b99                	li	s7,6
    80001802:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001804:	00017a97          	auipc	s5,0x17
    80001808:	d44a8a93          	addi	s5,s5,-700 # 80018548 <tickslock>
    char *pa = kalloc();
    8000180c:	b42ff0ef          	jal	80000b4e <kalloc>
    80001810:	862a                	mv	a2,a0
    if (pa == 0)
    80001812:	c121                	beqz	a0,80001852 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    80001814:	418485b3          	sub	a1,s1,s8
    80001818:	8591                	srai	a1,a1,0x4
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
    80001832:	17048493          	addi	s1,s1,368
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
    8000187e:	c9e50513          	addi	a0,a0,-866 # 80012518 <pid_lock>
    80001882:	b26ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001886:	00006597          	auipc	a1,0x6
    8000188a:	8e258593          	addi	a1,a1,-1822 # 80007168 <etext+0x168>
    8000188e:	00011517          	auipc	a0,0x11
    80001892:	ca250513          	addi	a0,a0,-862 # 80012530 <wait_lock>
    80001896:	b12ff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000189a:	00011497          	auipc	s1,0x11
    8000189e:	0ae48493          	addi	s1,s1,174 # 80012948 <proc>
    initlock(&p->lock, "proc");
    800018a2:	00006b17          	auipc	s6,0x6
    800018a6:	8d6b0b13          	addi	s6,s6,-1834 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018aa:	8aa6                	mv	s5,s1
    800018ac:	ff4df937          	lui	s2,0xff4df
    800018b0:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb095>
    800018b4:	0936                	slli	s2,s2,0xd
    800018b6:	6f590913          	addi	s2,s2,1781
    800018ba:	0936                	slli	s2,s2,0xd
    800018bc:	bd390913          	addi	s2,s2,-1069
    800018c0:	0932                	slli	s2,s2,0xc
    800018c2:	7a790913          	addi	s2,s2,1959
    800018c6:	040009b7          	lui	s3,0x4000
    800018ca:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018cc:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    800018ce:	00017a17          	auipc	s4,0x17
    800018d2:	c7aa0a13          	addi	s4,s4,-902 # 80018548 <tickslock>
    initlock(&p->lock, "proc");
    800018d6:	85da                	mv	a1,s6
    800018d8:	8526                	mv	a0,s1
    800018da:	aceff0ef          	jal	80000ba8 <initlock>
    p->state = UNUSED;
    800018de:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800018e2:	415487b3          	sub	a5,s1,s5
    800018e6:	8791                	srai	a5,a5,0x4
    800018e8:	032787b3          	mul	a5,a5,s2
    800018ec:	07b6                	slli	a5,a5,0xd
    800018ee:	6709                	lui	a4,0x2
    800018f0:	9fb9                	addw	a5,a5,a4
    800018f2:	40f987b3          	sub	a5,s3,a5
    800018f6:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    800018f8:	17048493          	addi	s1,s1,368
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
    8000193a:	c1250513          	addi	a0,a0,-1006 # 80012548 <cpus>
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
    80001960:	bbc70713          	addi	a4,a4,-1092 # 80012518 <pid_lock>
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
    80001992:	a327a783          	lw	a5,-1486(a5) # 8000a3c0 <first.1>
    80001996:	cf85                	beqz	a5,800019ce <forkret+0x54>
    first = 0;
    80001998:	00009797          	auipc	a5,0x9
    8000199c:	a207a423          	sw	zero,-1496(a5) # 8000a3c0 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019a0:	4505                	li	a0,1
    800019a2:	64f010ef          	jal	800037f0 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019a6:	00005797          	auipc	a5,0x5
    800019aa:	7da78793          	addi	a5,a5,2010 # 80007180 <etext+0x180>
    800019ae:	fcf43823          	sd	a5,-48(s0)
    800019b2:	fc043c23          	sd	zero,-40(s0)
    800019b6:	fd040593          	addi	a1,s0,-48
    800019ba:	853e                	mv	a0,a5
    800019bc:	0e8030ef          	jal	80004aa4 <kexec>
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
    800019ce:	4f1000ef          	jal	800026be <prepare_return>
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
    80001a1e:	afe50513          	addi	a0,a0,-1282 # 80012518 <pid_lock>
    80001a22:	a06ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a26:	00009797          	auipc	a5,0x9
    80001a2a:	99e78793          	addi	a5,a5,-1634 # 8000a3c4 <nextpid>
    80001a2e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a30:	0014871b          	addiw	a4,s1,1
    80001a34:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a36:	00011517          	auipc	a0,0x11
    80001a3a:	ae250513          	addi	a0,a0,-1310 # 80012518 <pid_lock>
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
  p->priority = 10;
    80001b5a:	47a9                	li	a5,10
    80001b5c:	16f4a423          	sw	a5,360(s1)
  p->wait_ticks = 0;
    80001b60:	1604a623          	sw	zero,364(s1)
}
    80001b64:	60e2                	ld	ra,24(sp)
    80001b66:	6442                	ld	s0,16(sp)
    80001b68:	64a2                	ld	s1,8(sp)
    80001b6a:	6105                	addi	sp,sp,32
    80001b6c:	8082                	ret

0000000080001b6e <allocproc>:
{
    80001b6e:	1101                	addi	sp,sp,-32
    80001b70:	ec06                	sd	ra,24(sp)
    80001b72:	e822                	sd	s0,16(sp)
    80001b74:	e426                	sd	s1,8(sp)
    80001b76:	e04a                	sd	s2,0(sp)
    80001b78:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b7a:	00011497          	auipc	s1,0x11
    80001b7e:	dce48493          	addi	s1,s1,-562 # 80012948 <proc>
    80001b82:	00017917          	auipc	s2,0x17
    80001b86:	9c690913          	addi	s2,s2,-1594 # 80018548 <tickslock>
    acquire(&p->lock);
    80001b8a:	8526                	mv	a0,s1
    80001b8c:	89cff0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001b90:	4c9c                	lw	a5,24(s1)
    80001b92:	cb91                	beqz	a5,80001ba6 <allocproc+0x38>
      release(&p->lock);
    80001b94:	8526                	mv	a0,s1
    80001b96:	91aff0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b9a:	17048493          	addi	s1,s1,368
    80001b9e:	ff2496e3          	bne	s1,s2,80001b8a <allocproc+0x1c>
  return 0;
    80001ba2:	4481                	li	s1,0
    80001ba4:	a0b1                	j	80001bf0 <allocproc+0x82>
  p->pid = allocpid();
    80001ba6:	e6bff0ef          	jal	80001a10 <allocpid>
    80001baa:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bac:	4785                	li	a5,1
    80001bae:	cc9c                	sw	a5,24(s1)
  p->priority = 10;   // default priority = 10 (1 = highest, 20 = lowest)
    80001bb0:	47a9                	li	a5,10
    80001bb2:	16f4a423          	sw	a5,360(s1)
  p->wait_ticks = 0;  // initial wait ticks
    80001bb6:	1604a623          	sw	zero,364(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bba:	f95fe0ef          	jal	80000b4e <kalloc>
    80001bbe:	892a                	mv	s2,a0
    80001bc0:	eca8                	sd	a0,88(s1)
    80001bc2:	cd15                	beqz	a0,80001bfe <allocproc+0x90>
  p->pagetable = proc_pagetable(p);
    80001bc4:	8526                	mv	a0,s1
    80001bc6:	e89ff0ef          	jal	80001a4e <proc_pagetable>
    80001bca:	892a                	mv	s2,a0
    80001bcc:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001bce:	c121                	beqz	a0,80001c0e <allocproc+0xa0>
  memset(&p->context, 0, sizeof(p->context));
    80001bd0:	07000613          	li	a2,112
    80001bd4:	4581                	li	a1,0
    80001bd6:	06048513          	addi	a0,s1,96
    80001bda:	90eff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001bde:	00000797          	auipc	a5,0x0
    80001be2:	d9c78793          	addi	a5,a5,-612 # 8000197a <forkret>
    80001be6:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001be8:	60bc                	ld	a5,64(s1)
    80001bea:	6705                	lui	a4,0x1
    80001bec:	97ba                	add	a5,a5,a4
    80001bee:	f4bc                	sd	a5,104(s1)
}
    80001bf0:	8526                	mv	a0,s1
    80001bf2:	60e2                	ld	ra,24(sp)
    80001bf4:	6442                	ld	s0,16(sp)
    80001bf6:	64a2                	ld	s1,8(sp)
    80001bf8:	6902                	ld	s2,0(sp)
    80001bfa:	6105                	addi	sp,sp,32
    80001bfc:	8082                	ret
    freeproc(p);
    80001bfe:	8526                	mv	a0,s1
    80001c00:	f19ff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001c04:	8526                	mv	a0,s1
    80001c06:	8aaff0ef          	jal	80000cb0 <release>
    return 0;
    80001c0a:	84ca                	mv	s1,s2
    80001c0c:	b7d5                	j	80001bf0 <allocproc+0x82>
    freeproc(p);
    80001c0e:	8526                	mv	a0,s1
    80001c10:	f09ff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001c14:	8526                	mv	a0,s1
    80001c16:	89aff0ef          	jal	80000cb0 <release>
    return 0;
    80001c1a:	84ca                	mv	s1,s2
    80001c1c:	bfd1                	j	80001bf0 <allocproc+0x82>

0000000080001c1e <userinit>:
{
    80001c1e:	1101                	addi	sp,sp,-32
    80001c20:	ec06                	sd	ra,24(sp)
    80001c22:	e822                	sd	s0,16(sp)
    80001c24:	e426                	sd	s1,8(sp)
    80001c26:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c28:	f47ff0ef          	jal	80001b6e <allocproc>
    80001c2c:	84aa                	mv	s1,a0
  initproc = p;
    80001c2e:	00008797          	auipc	a5,0x8
    80001c32:	7ea7b123          	sd	a0,2018(a5) # 8000a410 <initproc>
  p->cwd = namei("/");
    80001c36:	00005517          	auipc	a0,0x5
    80001c3a:	55a50513          	addi	a0,a0,1370 # 80007190 <etext+0x190>
    80001c3e:	110020ef          	jal	80003d4e <namei>
    80001c42:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c46:	478d                	li	a5,3
    80001c48:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c4a:	8526                	mv	a0,s1
    80001c4c:	864ff0ef          	jal	80000cb0 <release>
}
    80001c50:	60e2                	ld	ra,24(sp)
    80001c52:	6442                	ld	s0,16(sp)
    80001c54:	64a2                	ld	s1,8(sp)
    80001c56:	6105                	addi	sp,sp,32
    80001c58:	8082                	ret

0000000080001c5a <growproc>:
{
    80001c5a:	1101                	addi	sp,sp,-32
    80001c5c:	ec06                	sd	ra,24(sp)
    80001c5e:	e822                	sd	s0,16(sp)
    80001c60:	e426                	sd	s1,8(sp)
    80001c62:	e04a                	sd	s2,0(sp)
    80001c64:	1000                	addi	s0,sp,32
    80001c66:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c68:	ce1ff0ef          	jal	80001948 <myproc>
    80001c6c:	892a                	mv	s2,a0
  sz = p->sz;
    80001c6e:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c70:	02905963          	blez	s1,80001ca2 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c74:	00b48633          	add	a2,s1,a1
    80001c78:	020007b7          	lui	a5,0x2000
    80001c7c:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c7e:	07b6                	slli	a5,a5,0xd
    80001c80:	02c7ea63          	bltu	a5,a2,80001cb4 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c84:	4691                	li	a3,4
    80001c86:	6928                	ld	a0,80(a0)
    80001c88:	e66ff0ef          	jal	800012ee <uvmalloc>
    80001c8c:	85aa                	mv	a1,a0
    80001c8e:	c50d                	beqz	a0,80001cb8 <growproc+0x5e>
  p->sz = sz;
    80001c90:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c94:	4501                	li	a0,0
}
    80001c96:	60e2                	ld	ra,24(sp)
    80001c98:	6442                	ld	s0,16(sp)
    80001c9a:	64a2                	ld	s1,8(sp)
    80001c9c:	6902                	ld	s2,0(sp)
    80001c9e:	6105                	addi	sp,sp,32
    80001ca0:	8082                	ret
  } else if (n < 0) {
    80001ca2:	fe04d7e3          	bgez	s1,80001c90 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ca6:	00b48633          	add	a2,s1,a1
    80001caa:	6928                	ld	a0,80(a0)
    80001cac:	dfeff0ef          	jal	800012aa <uvmdealloc>
    80001cb0:	85aa                	mv	a1,a0
    80001cb2:	bff9                	j	80001c90 <growproc+0x36>
      return -1;
    80001cb4:	557d                	li	a0,-1
    80001cb6:	b7c5                	j	80001c96 <growproc+0x3c>
      return -1;
    80001cb8:	557d                	li	a0,-1
    80001cba:	bff1                	j	80001c96 <growproc+0x3c>

0000000080001cbc <kfork>:
{
    80001cbc:	7139                	addi	sp,sp,-64
    80001cbe:	fc06                	sd	ra,56(sp)
    80001cc0:	f822                	sd	s0,48(sp)
    80001cc2:	f426                	sd	s1,40(sp)
    80001cc4:	e456                	sd	s5,8(sp)
    80001cc6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cc8:	c81ff0ef          	jal	80001948 <myproc>
    80001ccc:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001cce:	ea1ff0ef          	jal	80001b6e <allocproc>
    80001cd2:	0e050a63          	beqz	a0,80001dc6 <kfork+0x10a>
    80001cd6:	e852                	sd	s4,16(sp)
    80001cd8:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001cda:	048ab603          	ld	a2,72(s5)
    80001cde:	692c                	ld	a1,80(a0)
    80001ce0:	050ab503          	ld	a0,80(s5)
    80001ce4:	f42ff0ef          	jal	80001426 <uvmcopy>
    80001ce8:	04054863          	bltz	a0,80001d38 <kfork+0x7c>
    80001cec:	f04a                	sd	s2,32(sp)
    80001cee:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001cf0:	048ab783          	ld	a5,72(s5)
    80001cf4:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001cf8:	058ab683          	ld	a3,88(s5)
    80001cfc:	87b6                	mv	a5,a3
    80001cfe:	058a3703          	ld	a4,88(s4)
    80001d02:	12068693          	addi	a3,a3,288
    80001d06:	6388                	ld	a0,0(a5)
    80001d08:	678c                	ld	a1,8(a5)
    80001d0a:	6b90                	ld	a2,16(a5)
    80001d0c:	e308                	sd	a0,0(a4)
    80001d0e:	e70c                	sd	a1,8(a4)
    80001d10:	eb10                	sd	a2,16(a4)
    80001d12:	6f90                	ld	a2,24(a5)
    80001d14:	ef10                	sd	a2,24(a4)
    80001d16:	02078793          	addi	a5,a5,32
    80001d1a:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d1e:	fed794e3          	bne	a5,a3,80001d06 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d22:	058a3783          	ld	a5,88(s4)
    80001d26:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d2a:	0d0a8493          	addi	s1,s5,208
    80001d2e:	0d0a0913          	addi	s2,s4,208
    80001d32:	150a8993          	addi	s3,s5,336
    80001d36:	a831                	j	80001d52 <kfork+0x96>
    freeproc(np);
    80001d38:	8552                	mv	a0,s4
    80001d3a:	ddfff0ef          	jal	80001b18 <freeproc>
    release(&np->lock);
    80001d3e:	8552                	mv	a0,s4
    80001d40:	f71fe0ef          	jal	80000cb0 <release>
    return -1;
    80001d44:	54fd                	li	s1,-1
    80001d46:	6a42                	ld	s4,16(sp)
    80001d48:	a885                	j	80001db8 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d4a:	04a1                	addi	s1,s1,8
    80001d4c:	0921                	addi	s2,s2,8
    80001d4e:	01348963          	beq	s1,s3,80001d60 <kfork+0xa4>
    if (p->ofile[i])
    80001d52:	6088                	ld	a0,0(s1)
    80001d54:	d97d                	beqz	a0,80001d4a <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d56:	64a020ef          	jal	800043a0 <filedup>
    80001d5a:	00a93023          	sd	a0,0(s2)
    80001d5e:	b7f5                	j	80001d4a <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d60:	150ab503          	ld	a0,336(s5)
    80001d64:	71a010ef          	jal	8000347e <idup>
    80001d68:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d6c:	4641                	li	a2,16
    80001d6e:	158a8593          	addi	a1,s5,344
    80001d72:	158a0513          	addi	a0,s4,344
    80001d76:	8c6ff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001d7a:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d7e:	8552                	mv	a0,s4
    80001d80:	f31fe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001d84:	00010517          	auipc	a0,0x10
    80001d88:	7ac50513          	addi	a0,a0,1964 # 80012530 <wait_lock>
    80001d8c:	e9dfe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001d90:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d94:	00010517          	auipc	a0,0x10
    80001d98:	79c50513          	addi	a0,a0,1948 # 80012530 <wait_lock>
    80001d9c:	f15fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001da0:	8552                	mv	a0,s4
    80001da2:	e87fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001da6:	478d                	li	a5,3
    80001da8:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001dac:	8552                	mv	a0,s4
    80001dae:	f03fe0ef          	jal	80000cb0 <release>
  return pid;
    80001db2:	7902                	ld	s2,32(sp)
    80001db4:	69e2                	ld	s3,24(sp)
    80001db6:	6a42                	ld	s4,16(sp)
}
    80001db8:	8526                	mv	a0,s1
    80001dba:	70e2                	ld	ra,56(sp)
    80001dbc:	7442                	ld	s0,48(sp)
    80001dbe:	74a2                	ld	s1,40(sp)
    80001dc0:	6aa2                	ld	s5,8(sp)
    80001dc2:	6121                	addi	sp,sp,64
    80001dc4:	8082                	ret
    return -1;
    80001dc6:	54fd                	li	s1,-1
    80001dc8:	bfc5                	j	80001db8 <kfork+0xfc>

0000000080001dca <set_priority>:
{
    80001dca:	7179                	addi	sp,sp,-48
    80001dcc:	f406                	sd	ra,40(sp)
    80001dce:	f022                	sd	s0,32(sp)
    80001dd0:	e84a                	sd	s2,16(sp)
    80001dd2:	1800                	addi	s0,sp,48
  if (new_priority < 1 || new_priority > 20)
    80001dd4:	fff5871b          	addiw	a4,a1,-1
    80001dd8:	47cd                	li	a5,19
    80001dda:	06e7ea63          	bltu	a5,a4,80001e4e <set_priority+0x84>
    80001dde:	ec26                	sd	s1,24(sp)
    80001de0:	e44e                	sd	s3,8(sp)
    80001de2:	e052                	sd	s4,0(sp)
    80001de4:	892a                	mv	s2,a0
    80001de6:	8a2e                	mv	s4,a1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001de8:	00011497          	auipc	s1,0x11
    80001dec:	b6048493          	addi	s1,s1,-1184 # 80012948 <proc>
    80001df0:	00016997          	auipc	s3,0x16
    80001df4:	75898993          	addi	s3,s3,1880 # 80018548 <tickslock>
    80001df8:	a801                	j	80001e08 <set_priority+0x3e>
    release(&p->lock);
    80001dfa:	8526                	mv	a0,s1
    80001dfc:	eb5fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e00:	17048493          	addi	s1,s1,368
    80001e04:	05348063          	beq	s1,s3,80001e44 <set_priority+0x7a>
    acquire(&p->lock);
    80001e08:	8526                	mv	a0,s1
    80001e0a:	e1ffe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid || (pid == 0 && p == myproc())) {
    80001e0e:	589c                	lw	a5,48(s1)
    80001e10:	01278863          	beq	a5,s2,80001e20 <set_priority+0x56>
    80001e14:	fe0913e3          	bnez	s2,80001dfa <set_priority+0x30>
    80001e18:	b31ff0ef          	jal	80001948 <myproc>
    80001e1c:	fc951fe3          	bne	a0,s1,80001dfa <set_priority+0x30>
      int old = p->priority;
    80001e20:	1684a903          	lw	s2,360(s1)
      p->priority = new_priority;
    80001e24:	1744a423          	sw	s4,360(s1)
      p->wait_ticks = 0;
    80001e28:	1604a623          	sw	zero,364(s1)
      release(&p->lock);
    80001e2c:	8526                	mv	a0,s1
    80001e2e:	e83fe0ef          	jal	80000cb0 <release>
      return old;
    80001e32:	64e2                	ld	s1,24(sp)
    80001e34:	69a2                	ld	s3,8(sp)
    80001e36:	6a02                	ld	s4,0(sp)
}
    80001e38:	854a                	mv	a0,s2
    80001e3a:	70a2                	ld	ra,40(sp)
    80001e3c:	7402                	ld	s0,32(sp)
    80001e3e:	6942                	ld	s2,16(sp)
    80001e40:	6145                	addi	sp,sp,48
    80001e42:	8082                	ret
  return -1;
    80001e44:	597d                	li	s2,-1
    80001e46:	64e2                	ld	s1,24(sp)
    80001e48:	69a2                	ld	s3,8(sp)
    80001e4a:	6a02                	ld	s4,0(sp)
    80001e4c:	b7f5                	j	80001e38 <set_priority+0x6e>
    return -1;
    80001e4e:	597d                	li	s2,-1
    80001e50:	b7e5                	j	80001e38 <set_priority+0x6e>

0000000080001e52 <get_priority>:
{
    80001e52:	7179                	addi	sp,sp,-48
    80001e54:	f406                	sd	ra,40(sp)
    80001e56:	f022                	sd	s0,32(sp)
    80001e58:	ec26                	sd	s1,24(sp)
    80001e5a:	e84a                	sd	s2,16(sp)
    80001e5c:	e44e                	sd	s3,8(sp)
    80001e5e:	1800                	addi	s0,sp,48
    80001e60:	892a                	mv	s2,a0
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e62:	00011497          	auipc	s1,0x11
    80001e66:	ae648493          	addi	s1,s1,-1306 # 80012948 <proc>
    80001e6a:	00016997          	auipc	s3,0x16
    80001e6e:	6de98993          	addi	s3,s3,1758 # 80018548 <tickslock>
    80001e72:	a801                	j	80001e82 <get_priority+0x30>
    release(&p->lock);
    80001e74:	8526                	mv	a0,s1
    80001e76:	e3bfe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e7a:	17048493          	addi	s1,s1,368
    80001e7e:	03348b63          	beq	s1,s3,80001eb4 <get_priority+0x62>
    acquire(&p->lock);
    80001e82:	8526                	mv	a0,s1
    80001e84:	da5fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid || (pid == 0 && p == myproc())) {
    80001e88:	589c                	lw	a5,48(s1)
    80001e8a:	01278863          	beq	a5,s2,80001e9a <get_priority+0x48>
    80001e8e:	fe0913e3          	bnez	s2,80001e74 <get_priority+0x22>
    80001e92:	ab7ff0ef          	jal	80001948 <myproc>
    80001e96:	fc951fe3          	bne	a0,s1,80001e74 <get_priority+0x22>
      int prio = p->priority;
    80001e9a:	1684a903          	lw	s2,360(s1)
      release(&p->lock);
    80001e9e:	8526                	mv	a0,s1
    80001ea0:	e11fe0ef          	jal	80000cb0 <release>
}
    80001ea4:	854a                	mv	a0,s2
    80001ea6:	70a2                	ld	ra,40(sp)
    80001ea8:	7402                	ld	s0,32(sp)
    80001eaa:	64e2                	ld	s1,24(sp)
    80001eac:	6942                	ld	s2,16(sp)
    80001eae:	69a2                	ld	s3,8(sp)
    80001eb0:	6145                	addi	sp,sp,48
    80001eb2:	8082                	ret
  return -1;
    80001eb4:	597d                	li	s2,-1
    80001eb6:	b7fd                	j	80001ea4 <get_priority+0x52>

0000000080001eb8 <update_proc_aging>:
{
    80001eb8:	7139                	addi	sp,sp,-64
    80001eba:	fc06                	sd	ra,56(sp)
    80001ebc:	f822                	sd	s0,48(sp)
    80001ebe:	f426                	sd	s1,40(sp)
    80001ec0:	f04a                	sd	s2,32(sp)
    80001ec2:	ec4e                	sd	s3,24(sp)
    80001ec4:	e852                	sd	s4,16(sp)
    80001ec6:	e456                	sd	s5,8(sp)
    80001ec8:	0080                	addi	s0,sp,64
  for (p = proc; p < &proc[NPROC]; p++) {
    80001eca:	00011497          	auipc	s1,0x11
    80001ece:	a7e48493          	addi	s1,s1,-1410 # 80012948 <proc>
    if (p->state == RUNNABLE) {
    80001ed2:	498d                	li	s3,3
      if (p->wait_ticks > 30) {
    80001ed4:	4a79                	li	s4,30
        if (p->priority > 1) {
    80001ed6:	4a85                	li	s5,1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ed8:	00016917          	auipc	s2,0x16
    80001edc:	67090913          	addi	s2,s2,1648 # 80018548 <tickslock>
    80001ee0:	a811                	j	80001ef4 <update_proc_aging+0x3c>
        p->wait_ticks = 0;
    80001ee2:	1604a623          	sw	zero,364(s1)
    release(&p->lock);
    80001ee6:	8526                	mv	a0,s1
    80001ee8:	dc9fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001eec:	17048493          	addi	s1,s1,368
    80001ef0:	03248763          	beq	s1,s2,80001f1e <update_proc_aging+0x66>
    acquire(&p->lock);
    80001ef4:	8526                	mv	a0,s1
    80001ef6:	d33fe0ef          	jal	80000c28 <acquire>
    if (p->state == RUNNABLE) {
    80001efa:	4c9c                	lw	a5,24(s1)
    80001efc:	ff3795e3          	bne	a5,s3,80001ee6 <update_proc_aging+0x2e>
      p->wait_ticks++;
    80001f00:	16c4a783          	lw	a5,364(s1)
    80001f04:	2785                	addiw	a5,a5,1
    80001f06:	16f4a623          	sw	a5,364(s1)
      if (p->wait_ticks > 30) {
    80001f0a:	fcfa7ee3          	bgeu	s4,a5,80001ee6 <update_proc_aging+0x2e>
        if (p->priority > 1) {
    80001f0e:	1684a783          	lw	a5,360(s1)
    80001f12:	fcfad8e3          	bge	s5,a5,80001ee2 <update_proc_aging+0x2a>
          p->priority--; // Raise priority (1 = highest)
    80001f16:	37fd                	addiw	a5,a5,-1
    80001f18:	16f4a423          	sw	a5,360(s1)
    80001f1c:	b7d9                	j	80001ee2 <update_proc_aging+0x2a>
}
    80001f1e:	70e2                	ld	ra,56(sp)
    80001f20:	7442                	ld	s0,48(sp)
    80001f22:	74a2                	ld	s1,40(sp)
    80001f24:	7902                	ld	s2,32(sp)
    80001f26:	69e2                	ld	s3,24(sp)
    80001f28:	6a42                	ld	s4,16(sp)
    80001f2a:	6aa2                	ld	s5,8(sp)
    80001f2c:	6121                	addi	sp,sp,64
    80001f2e:	8082                	ret

0000000080001f30 <scheduler>:
{
    80001f30:	7119                	addi	sp,sp,-128
    80001f32:	fc86                	sd	ra,120(sp)
    80001f34:	f8a2                	sd	s0,112(sp)
    80001f36:	f4a6                	sd	s1,104(sp)
    80001f38:	f0ca                	sd	s2,96(sp)
    80001f3a:	ecce                	sd	s3,88(sp)
    80001f3c:	e8d2                	sd	s4,80(sp)
    80001f3e:	e4d6                	sd	s5,72(sp)
    80001f40:	e0da                	sd	s6,64(sp)
    80001f42:	fc5e                	sd	s7,56(sp)
    80001f44:	f862                	sd	s8,48(sp)
    80001f46:	f466                	sd	s9,40(sp)
    80001f48:	f06a                	sd	s10,32(sp)
    80001f4a:	ec6e                	sd	s11,24(sp)
    80001f4c:	0100                	addi	s0,sp,128
    80001f4e:	8792                	mv	a5,tp
  int id = r_tp();
    80001f50:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f52:	00779693          	slli	a3,a5,0x7
    80001f56:	00010717          	auipc	a4,0x10
    80001f5a:	5c270713          	addi	a4,a4,1474 # 80012518 <pid_lock>
    80001f5e:	9736                	add	a4,a4,a3
    80001f60:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &best_p->context);
    80001f64:	00010717          	auipc	a4,0x10
    80001f68:	5ec70713          	addi	a4,a4,1516 # 80012550 <cpus+0x8>
    80001f6c:	9736                	add	a4,a4,a3
    80001f6e:	f8e43423          	sd	a4,-120(s0)
  int last_idx = -1;
    80001f72:	5cfd                	li	s9,-1
        p = &proc[idx];
    80001f74:	17000b13          	li	s6,368
    80001f78:	00011a97          	auipc	s5,0x11
    80001f7c:	9d0a8a93          	addi	s5,s5,-1584 # 80012948 <proc>
      c->proc = best_p;
    80001f80:	00010d97          	auipc	s11,0x10
    80001f84:	598d8d93          	addi	s11,s11,1432 # 80012518 <pid_lock>
    80001f88:	00dd8d33          	add	s10,s11,a3
    80001f8c:	a855                	j	80002040 <scheduler+0x110>
      if (p->state == RUNNABLE && p->priority < min_prio) {
    80001f8e:	0007099b          	sext.w	s3,a4
      release(&p->lock);
    80001f92:	8526                	mv	a0,s1
    80001f94:	d1dfe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f98:	17048493          	addi	s1,s1,368
    80001f9c:	03248063          	beq	s1,s2,80001fbc <scheduler+0x8c>
      acquire(&p->lock);
    80001fa0:	8526                	mv	a0,s1
    80001fa2:	c87fe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE && p->priority < min_prio) {
    80001fa6:	4c9c                	lw	a5,24(s1)
    80001fa8:	ff4795e3          	bne	a5,s4,80001f92 <scheduler+0x62>
    80001fac:	1684a783          	lw	a5,360(s1)
    80001fb0:	873e                	mv	a4,a5
    80001fb2:	2781                	sext.w	a5,a5
    80001fb4:	fcf9dde3          	bge	s3,a5,80001f8e <scheduler+0x5e>
    80001fb8:	874e                	mv	a4,s3
    80001fba:	bfd1                	j	80001f8e <scheduler+0x5e>
    if (min_prio <= 20) {
    80001fbc:	47d1                	li	a5,20
    80001fbe:	0737cf63          	blt	a5,s3,8000203c <scheduler+0x10c>
    80001fc2:	001c8a1b          	addiw	s4,s9,1
    80001fc6:	041c8c1b          	addiw	s8,s9,65
        if (p->state == RUNNABLE && p->priority == min_prio) {
    80001fca:	4b8d                	li	s7,3
    80001fcc:	a039                	j	80001fda <scheduler+0xaa>
        release(&p->lock);
    80001fce:	854a                	mv	a0,s2
    80001fd0:	ce1fe0ef          	jal	80000cb0 <release>
      for (int i = 0; i < NPROC; i++) {
    80001fd4:	2a05                	addiw	s4,s4,1
    80001fd6:	078a0363          	beq	s4,s8,8000203c <scheduler+0x10c>
        int idx = (last_idx + 1 + i) % NPROC;
    80001fda:	41fa579b          	sraiw	a5,s4,0x1f
    80001fde:	01a7d79b          	srliw	a5,a5,0x1a
    80001fe2:	014784bb          	addw	s1,a5,s4
    80001fe6:	03f4f493          	andi	s1,s1,63
    80001fea:	9c9d                	subw	s1,s1,a5
        p = &proc[idx];
    80001fec:	03648933          	mul	s2,s1,s6
    80001ff0:	9956                	add	s2,s2,s5
        acquire(&p->lock);
    80001ff2:	854a                	mv	a0,s2
    80001ff4:	c35fe0ef          	jal	80000c28 <acquire>
        if (p->state == RUNNABLE && p->priority == min_prio) {
    80001ff8:	01892783          	lw	a5,24(s2)
    80001ffc:	fd7799e3          	bne	a5,s7,80001fce <scheduler+0x9e>
    80002000:	16892783          	lw	a5,360(s2)
    80002004:	fd3795e3          	bne	a5,s3,80001fce <scheduler+0x9e>
      best_p->wait_ticks = 0; // Reset wait ticks as process is scheduled
    80002008:	16092623          	sw	zero,364(s2)
      best_p->state = RUNNING;
    8000200c:	4791                	li	a5,4
    8000200e:	00f92c23          	sw	a5,24(s2)
      c->proc = best_p;
    80002012:	032d3823          	sd	s2,48(s10) # fffffffffffff030 <end+0xffffffff7ffdb708>
      swtch(&c->context, &best_p->context);
    80002016:	06090593          	addi	a1,s2,96
    8000201a:	f8843503          	ld	a0,-120(s0)
    8000201e:	5f6000ef          	jal	80002614 <swtch>
    80002022:	8792                	mv	a5,tp
      mycpu()->intena = 0;
    80002024:	2781                	sext.w	a5,a5
    80002026:	079e                	slli	a5,a5,0x7
    80002028:	97ee                	add	a5,a5,s11
    8000202a:	0a07a623          	sw	zero,172(a5)
      c->proc = 0;
    8000202e:	020d3823          	sd	zero,48(s10)
      release(&best_p->lock);
    80002032:	854a                	mv	a0,s2
    80002034:	c7dfe0ef          	jal	80000cb0 <release>
          last_idx = idx;
    80002038:	8ca6                	mv	s9,s1
    8000203a:	a019                	j	80002040 <scheduler+0x110>
      asm volatile("wfi");
    8000203c:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002040:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002044:	10017073          	csrci	sstatus,2
    int min_prio = 21;
    80002048:	49d5                	li	s3,21
    for (p = proc; p < &proc[NPROC]; p++) {
    8000204a:	00011497          	auipc	s1,0x11
    8000204e:	8fe48493          	addi	s1,s1,-1794 # 80012948 <proc>
      if (p->state == RUNNABLE && p->priority < min_prio) {
    80002052:	4a0d                	li	s4,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80002054:	00016917          	auipc	s2,0x16
    80002058:	4f490913          	addi	s2,s2,1268 # 80018548 <tickslock>
    8000205c:	b791                	j	80001fa0 <scheduler+0x70>

000000008000205e <sched>:
{
    8000205e:	7179                	addi	sp,sp,-48
    80002060:	f406                	sd	ra,40(sp)
    80002062:	f022                	sd	s0,32(sp)
    80002064:	ec26                	sd	s1,24(sp)
    80002066:	e84a                	sd	s2,16(sp)
    80002068:	e44e                	sd	s3,8(sp)
    8000206a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000206c:	8ddff0ef          	jal	80001948 <myproc>
    80002070:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002072:	b51fe0ef          	jal	80000bc2 <holding>
    80002076:	c935                	beqz	a0,800020ea <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80002078:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000207a:	2781                	sext.w	a5,a5
    8000207c:	079e                	slli	a5,a5,0x7
    8000207e:	00010717          	auipc	a4,0x10
    80002082:	49a70713          	addi	a4,a4,1178 # 80012518 <pid_lock>
    80002086:	97ba                	add	a5,a5,a4
    80002088:	0a87a703          	lw	a4,168(a5)
    8000208c:	4785                	li	a5,1
    8000208e:	06f71463          	bne	a4,a5,800020f6 <sched+0x98>
  if (p->state == RUNNING)
    80002092:	4c98                	lw	a4,24(s1)
    80002094:	4791                	li	a5,4
    80002096:	06f70663          	beq	a4,a5,80002102 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000209a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000209e:	8b89                	andi	a5,a5,2
  if (intr_get())
    800020a0:	e7bd                	bnez	a5,8000210e <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    800020a2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020a4:	00010917          	auipc	s2,0x10
    800020a8:	47490913          	addi	s2,s2,1140 # 80012518 <pid_lock>
    800020ac:	2781                	sext.w	a5,a5
    800020ae:	079e                	slli	a5,a5,0x7
    800020b0:	97ca                	add	a5,a5,s2
    800020b2:	0ac7a983          	lw	s3,172(a5)
    800020b6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020b8:	2781                	sext.w	a5,a5
    800020ba:	079e                	slli	a5,a5,0x7
    800020bc:	07a1                	addi	a5,a5,8
    800020be:	00010597          	auipc	a1,0x10
    800020c2:	48a58593          	addi	a1,a1,1162 # 80012548 <cpus>
    800020c6:	95be                	add	a1,a1,a5
    800020c8:	06048513          	addi	a0,s1,96
    800020cc:	548000ef          	jal	80002614 <swtch>
    800020d0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020d2:	2781                	sext.w	a5,a5
    800020d4:	079e                	slli	a5,a5,0x7
    800020d6:	993e                	add	s2,s2,a5
    800020d8:	0b392623          	sw	s3,172(s2)
}
    800020dc:	70a2                	ld	ra,40(sp)
    800020de:	7402                	ld	s0,32(sp)
    800020e0:	64e2                	ld	s1,24(sp)
    800020e2:	6942                	ld	s2,16(sp)
    800020e4:	69a2                	ld	s3,8(sp)
    800020e6:	6145                	addi	sp,sp,48
    800020e8:	8082                	ret
    panic("sched p->lock");
    800020ea:	00005517          	auipc	a0,0x5
    800020ee:	0ae50513          	addi	a0,a0,174 # 80007198 <etext+0x198>
    800020f2:	f42fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    800020f6:	00005517          	auipc	a0,0x5
    800020fa:	0b250513          	addi	a0,a0,178 # 800071a8 <etext+0x1a8>
    800020fe:	f36fe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80002102:	00005517          	auipc	a0,0x5
    80002106:	0b650513          	addi	a0,a0,182 # 800071b8 <etext+0x1b8>
    8000210a:	f2afe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    8000210e:	00005517          	auipc	a0,0x5
    80002112:	0ba50513          	addi	a0,a0,186 # 800071c8 <etext+0x1c8>
    80002116:	f1efe0ef          	jal	80000834 <panic>

000000008000211a <yield>:
{
    8000211a:	1101                	addi	sp,sp,-32
    8000211c:	ec06                	sd	ra,24(sp)
    8000211e:	e822                	sd	s0,16(sp)
    80002120:	e426                	sd	s1,8(sp)
    80002122:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002124:	825ff0ef          	jal	80001948 <myproc>
    80002128:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000212a:	afffe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    8000212e:	478d                	li	a5,3
    80002130:	cc9c                	sw	a5,24(s1)
  sched();
    80002132:	f2dff0ef          	jal	8000205e <sched>
  release(&p->lock);
    80002136:	8526                	mv	a0,s1
    80002138:	b79fe0ef          	jal	80000cb0 <release>
}
    8000213c:	60e2                	ld	ra,24(sp)
    8000213e:	6442                	ld	s0,16(sp)
    80002140:	64a2                	ld	s1,8(sp)
    80002142:	6105                	addi	sp,sp,32
    80002144:	8082                	ret

0000000080002146 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80002146:	1101                	addi	sp,sp,-32
    80002148:	ec06                	sd	ra,24(sp)
    8000214a:	e822                	sd	s0,16(sp)
    8000214c:	e426                	sd	s1,8(sp)
    8000214e:	e04a                	sd	s2,0(sp)
    80002150:	1000                	addi	s0,sp,32
    80002152:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002154:	ff4ff0ef          	jal	80001948 <myproc>
    80002158:	892a                	mv	s2,a0

  acquire(&p->lock);
    8000215a:	acffe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    8000215e:	cc81                	beqz	s1,80002176 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80002160:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80002164:	854a                	mv	a0,s2
    80002166:	b4bfe0ef          	jal	80000cb0 <release>
}
    8000216a:	60e2                	ld	ra,24(sp)
    8000216c:	6442                	ld	s0,16(sp)
    8000216e:	64a2                	ld	s1,8(sp)
    80002170:	6902                	ld	s2,0(sp)
    80002172:	6105                	addi	sp,sp,32
    80002174:	8082                	ret
    panic("sleep_prepare: zero chan");
    80002176:	00005517          	auipc	a0,0x5
    8000217a:	06a50513          	addi	a0,a0,106 # 800071e0 <etext+0x1e0>
    8000217e:	eb6fe0ef          	jal	80000834 <panic>

0000000080002182 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80002182:	1101                	addi	sp,sp,-32
    80002184:	ec06                	sd	ra,24(sp)
    80002186:	e822                	sd	s0,16(sp)
    80002188:	e426                	sd	s1,8(sp)
    8000218a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000218c:	fbcff0ef          	jal	80001948 <myproc>
    80002190:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80002192:	a97fe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    80002196:	709c                	ld	a5,32(s1)
    80002198:	c789                	beqz	a5,800021a2 <sleep+0x20>
    p->state = SLEEPING;
    8000219a:	4789                	li	a5,2
    8000219c:	cc9c                	sw	a5,24(s1)
    sched();
    8000219e:	ec1ff0ef          	jal	8000205e <sched>
  }
  release(&p->lock);
    800021a2:	8526                	mv	a0,s1
    800021a4:	b0dfe0ef          	jal	80000cb0 <release>
}
    800021a8:	60e2                	ld	ra,24(sp)
    800021aa:	6442                	ld	s0,16(sp)
    800021ac:	64a2                	ld	s1,8(sp)
    800021ae:	6105                	addi	sp,sp,32
    800021b0:	8082                	ret

00000000800021b2 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    800021b2:	7139                	addi	sp,sp,-64
    800021b4:	fc06                	sd	ra,56(sp)
    800021b6:	f822                	sd	s0,48(sp)
    800021b8:	f426                	sd	s1,40(sp)
    800021ba:	f04a                	sd	s2,32(sp)
    800021bc:	ec4e                	sd	s3,24(sp)
    800021be:	e852                	sd	s4,16(sp)
    800021c0:	e456                	sd	s5,8(sp)
    800021c2:	0080                	addi	s0,sp,64
    800021c4:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800021c6:	00010497          	auipc	s1,0x10
    800021ca:	78248493          	addi	s1,s1,1922 # 80012948 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    800021ce:	4a09                	li	s4,2
        p->state = RUNNABLE;
    800021d0:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    800021d2:	00016997          	auipc	s3,0x16
    800021d6:	37698993          	addi	s3,s3,886 # 80018548 <tickslock>
    800021da:	a801                	j	800021ea <wakeup+0x38>
      }
    }
    release(&p->lock);
    800021dc:	8526                	mv	a0,s1
    800021de:	ad3fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800021e2:	17048493          	addi	s1,s1,368
    800021e6:	03348063          	beq	s1,s3,80002206 <wakeup+0x54>
    acquire(&p->lock);
    800021ea:	8526                	mv	a0,s1
    800021ec:	a3dfe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    800021f0:	709c                	ld	a5,32(s1)
    800021f2:	ff2795e3          	bne	a5,s2,800021dc <wakeup+0x2a>
      p->chan = 0;
    800021f6:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    800021fa:	4c9c                	lw	a5,24(s1)
    800021fc:	ff4790e3          	bne	a5,s4,800021dc <wakeup+0x2a>
        p->state = RUNNABLE;
    80002200:	0154ac23          	sw	s5,24(s1)
    80002204:	bfe1                	j	800021dc <wakeup+0x2a>
  }
}
    80002206:	70e2                	ld	ra,56(sp)
    80002208:	7442                	ld	s0,48(sp)
    8000220a:	74a2                	ld	s1,40(sp)
    8000220c:	7902                	ld	s2,32(sp)
    8000220e:	69e2                	ld	s3,24(sp)
    80002210:	6a42                	ld	s4,16(sp)
    80002212:	6aa2                	ld	s5,8(sp)
    80002214:	6121                	addi	sp,sp,64
    80002216:	8082                	ret

0000000080002218 <reparent>:
{
    80002218:	7179                	addi	sp,sp,-48
    8000221a:	f406                	sd	ra,40(sp)
    8000221c:	f022                	sd	s0,32(sp)
    8000221e:	ec26                	sd	s1,24(sp)
    80002220:	e84a                	sd	s2,16(sp)
    80002222:	e44e                	sd	s3,8(sp)
    80002224:	e052                	sd	s4,0(sp)
    80002226:	1800                	addi	s0,sp,48
    80002228:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000222a:	00010497          	auipc	s1,0x10
    8000222e:	71e48493          	addi	s1,s1,1822 # 80012948 <proc>
      pp->parent = initproc;
    80002232:	00008a17          	auipc	s4,0x8
    80002236:	1dea0a13          	addi	s4,s4,478 # 8000a410 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000223a:	00016997          	auipc	s3,0x16
    8000223e:	30e98993          	addi	s3,s3,782 # 80018548 <tickslock>
    80002242:	a029                	j	8000224c <reparent+0x34>
    80002244:	17048493          	addi	s1,s1,368
    80002248:	01348b63          	beq	s1,s3,8000225e <reparent+0x46>
    if (pp->parent == p) {
    8000224c:	7c9c                	ld	a5,56(s1)
    8000224e:	ff279be3          	bne	a5,s2,80002244 <reparent+0x2c>
      pp->parent = initproc;
    80002252:	000a3503          	ld	a0,0(s4)
    80002256:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002258:	f5bff0ef          	jal	800021b2 <wakeup>
    8000225c:	b7e5                	j	80002244 <reparent+0x2c>
}
    8000225e:	70a2                	ld	ra,40(sp)
    80002260:	7402                	ld	s0,32(sp)
    80002262:	64e2                	ld	s1,24(sp)
    80002264:	6942                	ld	s2,16(sp)
    80002266:	69a2                	ld	s3,8(sp)
    80002268:	6a02                	ld	s4,0(sp)
    8000226a:	6145                	addi	sp,sp,48
    8000226c:	8082                	ret

000000008000226e <kexit>:
{
    8000226e:	7179                	addi	sp,sp,-48
    80002270:	f406                	sd	ra,40(sp)
    80002272:	f022                	sd	s0,32(sp)
    80002274:	ec26                	sd	s1,24(sp)
    80002276:	e84a                	sd	s2,16(sp)
    80002278:	e44e                	sd	s3,8(sp)
    8000227a:	e052                	sd	s4,0(sp)
    8000227c:	1800                	addi	s0,sp,48
    8000227e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002280:	ec8ff0ef          	jal	80001948 <myproc>
    80002284:	89aa                	mv	s3,a0
  if (p == initproc)
    80002286:	00008797          	auipc	a5,0x8
    8000228a:	18a7b783          	ld	a5,394(a5) # 8000a410 <initproc>
    8000228e:	0d050493          	addi	s1,a0,208
    80002292:	15050913          	addi	s2,a0,336
    80002296:	00a79b63          	bne	a5,a0,800022ac <kexit+0x3e>
    panic("init exiting");
    8000229a:	00005517          	auipc	a0,0x5
    8000229e:	f6650513          	addi	a0,a0,-154 # 80007200 <etext+0x200>
    800022a2:	d92fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    800022a6:	04a1                	addi	s1,s1,8
    800022a8:	01248963          	beq	s1,s2,800022ba <kexit+0x4c>
    if (p->ofile[fd]) {
    800022ac:	6088                	ld	a0,0(s1)
    800022ae:	dd65                	beqz	a0,800022a6 <kexit+0x38>
      fileclose(f);
    800022b0:	136020ef          	jal	800043e6 <fileclose>
      p->ofile[fd] = 0;
    800022b4:	0004b023          	sd	zero,0(s1)
    800022b8:	b7fd                	j	800022a6 <kexit+0x38>
  begin_op();
    800022ba:	473010ef          	jal	80003f2c <begin_op>
  iput(p->cwd);
    800022be:	1509b503          	ld	a0,336(s3)
    800022c2:	374010ef          	jal	80003636 <iput>
  end_op();
    800022c6:	4f3010ef          	jal	80003fb8 <end_op>
  p->cwd = 0;
    800022ca:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022ce:	00010517          	auipc	a0,0x10
    800022d2:	26250513          	addi	a0,a0,610 # 80012530 <wait_lock>
    800022d6:	953fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    800022da:	854e                	mv	a0,s3
    800022dc:	f3dff0ef          	jal	80002218 <reparent>
  wakeup(p->parent);
    800022e0:	0389b503          	ld	a0,56(s3)
    800022e4:	ecfff0ef          	jal	800021b2 <wakeup>
  acquire(&p->lock);
    800022e8:	854e                	mv	a0,s3
    800022ea:	93ffe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    800022ee:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022f2:	4795                	li	a5,5
    800022f4:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022f8:	00010517          	auipc	a0,0x10
    800022fc:	23850513          	addi	a0,a0,568 # 80012530 <wait_lock>
    80002300:	9b1fe0ef          	jal	80000cb0 <release>
  sched();
    80002304:	d5bff0ef          	jal	8000205e <sched>
  panic("zombie exit");
    80002308:	00005517          	auipc	a0,0x5
    8000230c:	f0850513          	addi	a0,a0,-248 # 80007210 <etext+0x210>
    80002310:	d24fe0ef          	jal	80000834 <panic>

0000000080002314 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    80002314:	c525                	beqz	a0,8000237c <kkill+0x68>
{
    80002316:	7179                	addi	sp,sp,-48
    80002318:	f406                	sd	ra,40(sp)
    8000231a:	f022                	sd	s0,32(sp)
    8000231c:	ec26                	sd	s1,24(sp)
    8000231e:	e84a                	sd	s2,16(sp)
    80002320:	e44e                	sd	s3,8(sp)
    80002322:	1800                	addi	s0,sp,48
    80002324:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002326:	00010497          	auipc	s1,0x10
    8000232a:	62248493          	addi	s1,s1,1570 # 80012948 <proc>
    8000232e:	00016997          	auipc	s3,0x16
    80002332:	21a98993          	addi	s3,s3,538 # 80018548 <tickslock>
    acquire(&p->lock);
    80002336:	8526                	mv	a0,s1
    80002338:	8f1fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    8000233c:	589c                	lw	a5,48(s1)
    8000233e:	01278b63          	beq	a5,s2,80002354 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002342:	8526                	mv	a0,s1
    80002344:	96dfe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002348:	17048493          	addi	s1,s1,368
    8000234c:	ff3495e3          	bne	s1,s3,80002336 <kkill+0x22>
  }
  return -1;
    80002350:	557d                	li	a0,-1
    80002352:	a819                	j	80002368 <kkill+0x54>
      p->killed = 1;
    80002354:	4785                	li	a5,1
    80002356:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002358:	4c98                	lw	a4,24(s1)
    8000235a:	4789                	li	a5,2
    8000235c:	00f70d63          	beq	a4,a5,80002376 <kkill+0x62>
      release(&p->lock);
    80002360:	8526                	mv	a0,s1
    80002362:	94ffe0ef          	jal	80000cb0 <release>
      return 0;
    80002366:	4501                	li	a0,0
}
    80002368:	70a2                	ld	ra,40(sp)
    8000236a:	7402                	ld	s0,32(sp)
    8000236c:	64e2                	ld	s1,24(sp)
    8000236e:	6942                	ld	s2,16(sp)
    80002370:	69a2                	ld	s3,8(sp)
    80002372:	6145                	addi	sp,sp,48
    80002374:	8082                	ret
        p->state = RUNNABLE;
    80002376:	478d                	li	a5,3
    80002378:	cc9c                	sw	a5,24(s1)
    8000237a:	b7dd                	j	80002360 <kkill+0x4c>
    return -1;
    8000237c:	557d                	li	a0,-1
}
    8000237e:	8082                	ret

0000000080002380 <setkilled>:

void
setkilled(struct proc *p)
{
    80002380:	1101                	addi	sp,sp,-32
    80002382:	ec06                	sd	ra,24(sp)
    80002384:	e822                	sd	s0,16(sp)
    80002386:	e426                	sd	s1,8(sp)
    80002388:	1000                	addi	s0,sp,32
    8000238a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000238c:	89dfe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002390:	4785                	li	a5,1
    80002392:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002394:	8526                	mv	a0,s1
    80002396:	91bfe0ef          	jal	80000cb0 <release>
}
    8000239a:	60e2                	ld	ra,24(sp)
    8000239c:	6442                	ld	s0,16(sp)
    8000239e:	64a2                	ld	s1,8(sp)
    800023a0:	6105                	addi	sp,sp,32
    800023a2:	8082                	ret

00000000800023a4 <killed>:

int
killed(struct proc *p)
{
    800023a4:	1101                	addi	sp,sp,-32
    800023a6:	ec06                	sd	ra,24(sp)
    800023a8:	e822                	sd	s0,16(sp)
    800023aa:	e426                	sd	s1,8(sp)
    800023ac:	e04a                	sd	s2,0(sp)
    800023ae:	1000                	addi	s0,sp,32
    800023b0:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800023b2:	877fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    800023b6:	549c                	lw	a5,40(s1)
    800023b8:	893e                	mv	s2,a5
  release(&p->lock);
    800023ba:	8526                	mv	a0,s1
    800023bc:	8f5fe0ef          	jal	80000cb0 <release>
  return k;
}
    800023c0:	854a                	mv	a0,s2
    800023c2:	60e2                	ld	ra,24(sp)
    800023c4:	6442                	ld	s0,16(sp)
    800023c6:	64a2                	ld	s1,8(sp)
    800023c8:	6902                	ld	s2,0(sp)
    800023ca:	6105                	addi	sp,sp,32
    800023cc:	8082                	ret

00000000800023ce <kwait>:
{
    800023ce:	715d                	addi	sp,sp,-80
    800023d0:	e486                	sd	ra,72(sp)
    800023d2:	e0a2                	sd	s0,64(sp)
    800023d4:	fc26                	sd	s1,56(sp)
    800023d6:	f84a                	sd	s2,48(sp)
    800023d8:	f44e                	sd	s3,40(sp)
    800023da:	f052                	sd	s4,32(sp)
    800023dc:	ec56                	sd	s5,24(sp)
    800023de:	e85a                	sd	s6,16(sp)
    800023e0:	e45e                	sd	s7,8(sp)
    800023e2:	0880                	addi	s0,sp,80
    800023e4:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800023e6:	d62ff0ef          	jal	80001948 <myproc>
    800023ea:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023ec:	00010517          	auipc	a0,0x10
    800023f0:	14450513          	addi	a0,a0,324 # 80012530 <wait_lock>
    800023f4:	835fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800023f8:	4a15                	li	s4,5
        havekids = 1;
    800023fa:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800023fc:	00016997          	auipc	s3,0x16
    80002400:	14c98993          	addi	s3,s3,332 # 80018548 <tickslock>
    release(&wait_lock);
    80002404:	00010b17          	auipc	s6,0x10
    80002408:	12cb0b13          	addi	s6,s6,300 # 80012530 <wait_lock>
    8000240c:	a845                	j	800024bc <kwait+0xee>
          pid = pp->pid;
    8000240e:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    80002412:	000b8e63          	beqz	s7,8000242e <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    80002416:	4711                	li	a4,4
    80002418:	02c48693          	addi	a3,s1,44
    8000241c:	865e                	mv	a2,s7
    8000241e:	04893583          	ld	a1,72(s2)
    80002422:	05093503          	ld	a0,80(s2)
    80002426:	95cff0ef          	jal	80001582 <copyout>
          if (addr != 0 &&
    8000242a:	02054c63          	bltz	a0,80002462 <kwait+0x94>
          pp->parent = 0;
    8000242e:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    80002432:	8526                	mv	a0,s1
    80002434:	ee4ff0ef          	jal	80001b18 <freeproc>
          release(&pp->lock);
    80002438:	8526                	mv	a0,s1
    8000243a:	877fe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    8000243e:	00010517          	auipc	a0,0x10
    80002442:	0f250513          	addi	a0,a0,242 # 80012530 <wait_lock>
    80002446:	86bfe0ef          	jal	80000cb0 <release>
}
    8000244a:	854e                	mv	a0,s3
    8000244c:	60a6                	ld	ra,72(sp)
    8000244e:	6406                	ld	s0,64(sp)
    80002450:	74e2                	ld	s1,56(sp)
    80002452:	7942                	ld	s2,48(sp)
    80002454:	79a2                	ld	s3,40(sp)
    80002456:	7a02                	ld	s4,32(sp)
    80002458:	6ae2                	ld	s5,24(sp)
    8000245a:	6b42                	ld	s6,16(sp)
    8000245c:	6ba2                	ld	s7,8(sp)
    8000245e:	6161                	addi	sp,sp,80
    80002460:	8082                	ret
            release(&pp->lock);
    80002462:	8526                	mv	a0,s1
    80002464:	84dfe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    80002468:	00010517          	auipc	a0,0x10
    8000246c:	0c850513          	addi	a0,a0,200 # 80012530 <wait_lock>
    80002470:	841fe0ef          	jal	80000cb0 <release>
            return -1;
    80002474:	59fd                	li	s3,-1
    80002476:	bfd1                	j	8000244a <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002478:	17048493          	addi	s1,s1,368
    8000247c:	03348063          	beq	s1,s3,8000249c <kwait+0xce>
      if (pp->parent == p) {
    80002480:	7c9c                	ld	a5,56(s1)
    80002482:	ff279be3          	bne	a5,s2,80002478 <kwait+0xaa>
        acquire(&pp->lock);
    80002486:	8526                	mv	a0,s1
    80002488:	fa0fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    8000248c:	4c9c                	lw	a5,24(s1)
    8000248e:	f94780e3          	beq	a5,s4,8000240e <kwait+0x40>
        release(&pp->lock);
    80002492:	8526                	mv	a0,s1
    80002494:	81dfe0ef          	jal	80000cb0 <release>
        havekids = 1;
    80002498:	8756                	mv	a4,s5
    8000249a:	bff9                	j	80002478 <kwait+0xaa>
    if (!havekids || killed(p)) {
    8000249c:	c715                	beqz	a4,800024c8 <kwait+0xfa>
    8000249e:	854a                	mv	a0,s2
    800024a0:	f05ff0ef          	jal	800023a4 <killed>
    800024a4:	e115                	bnez	a0,800024c8 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    800024a6:	854a                	mv	a0,s2
    800024a8:	c9fff0ef          	jal	80002146 <sleep_prepare>
    release(&wait_lock);
    800024ac:	855a                	mv	a0,s6
    800024ae:	803fe0ef          	jal	80000cb0 <release>
    sleep();
    800024b2:	cd1ff0ef          	jal	80002182 <sleep>
    acquire(&wait_lock);
    800024b6:	855a                	mv	a0,s6
    800024b8:	f70fe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    800024bc:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800024be:	00010497          	auipc	s1,0x10
    800024c2:	48a48493          	addi	s1,s1,1162 # 80012948 <proc>
    800024c6:	bf6d                	j	80002480 <kwait+0xb2>
      release(&wait_lock);
    800024c8:	00010517          	auipc	a0,0x10
    800024cc:	06850513          	addi	a0,a0,104 # 80012530 <wait_lock>
    800024d0:	fe0fe0ef          	jal	80000cb0 <release>
      return -1;
    800024d4:	59fd                	li	s3,-1
    800024d6:	bf95                	j	8000244a <kwait+0x7c>

00000000800024d8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024d8:	7179                	addi	sp,sp,-48
    800024da:	f406                	sd	ra,40(sp)
    800024dc:	f022                	sd	s0,32(sp)
    800024de:	ec26                	sd	s1,24(sp)
    800024e0:	e84a                	sd	s2,16(sp)
    800024e2:	e44e                	sd	s3,8(sp)
    800024e4:	e052                	sd	s4,0(sp)
    800024e6:	1800                	addi	s0,sp,48
    800024e8:	84aa                	mv	s1,a0
    800024ea:	8a2e                	mv	s4,a1
    800024ec:	89b2                	mv	s3,a2
    800024ee:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800024f0:	c58ff0ef          	jal	80001948 <myproc>
  if (user_dst) {
    800024f4:	c085                	beqz	s1,80002514 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    800024f6:	874a                	mv	a4,s2
    800024f8:	86ce                	mv	a3,s3
    800024fa:	8652                	mv	a2,s4
    800024fc:	652c                	ld	a1,72(a0)
    800024fe:	6928                	ld	a0,80(a0)
    80002500:	882ff0ef          	jal	80001582 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002504:	70a2                	ld	ra,40(sp)
    80002506:	7402                	ld	s0,32(sp)
    80002508:	64e2                	ld	s1,24(sp)
    8000250a:	6942                	ld	s2,16(sp)
    8000250c:	69a2                	ld	s3,8(sp)
    8000250e:	6a02                	ld	s4,0(sp)
    80002510:	6145                	addi	sp,sp,48
    80002512:	8082                	ret
    memmove((char *)dst, src, len);
    80002514:	0009061b          	sext.w	a2,s2
    80002518:	85ce                	mv	a1,s3
    8000251a:	8552                	mv	a0,s4
    8000251c:	82dfe0ef          	jal	80000d48 <memmove>
    return 0;
    80002520:	8526                	mv	a0,s1
    80002522:	b7cd                	j	80002504 <either_copyout+0x2c>

0000000080002524 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002524:	7179                	addi	sp,sp,-48
    80002526:	f406                	sd	ra,40(sp)
    80002528:	f022                	sd	s0,32(sp)
    8000252a:	ec26                	sd	s1,24(sp)
    8000252c:	e84a                	sd	s2,16(sp)
    8000252e:	e44e                	sd	s3,8(sp)
    80002530:	e052                	sd	s4,0(sp)
    80002532:	1800                	addi	s0,sp,48
    80002534:	8a2a                	mv	s4,a0
    80002536:	84ae                	mv	s1,a1
    80002538:	89b2                	mv	s3,a2
    8000253a:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000253c:	c0cff0ef          	jal	80001948 <myproc>
  if (user_src) {
    80002540:	c085                	beqz	s1,80002560 <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    80002542:	874a                	mv	a4,s2
    80002544:	86ce                	mv	a3,s3
    80002546:	8652                	mv	a2,s4
    80002548:	652c                	ld	a1,72(a0)
    8000254a:	6928                	ld	a0,80(a0)
    8000254c:	8fcff0ef          	jal	80001648 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002550:	70a2                	ld	ra,40(sp)
    80002552:	7402                	ld	s0,32(sp)
    80002554:	64e2                	ld	s1,24(sp)
    80002556:	6942                	ld	s2,16(sp)
    80002558:	69a2                	ld	s3,8(sp)
    8000255a:	6a02                	ld	s4,0(sp)
    8000255c:	6145                	addi	sp,sp,48
    8000255e:	8082                	ret
    memmove(dst, (char *)src, len);
    80002560:	0009061b          	sext.w	a2,s2
    80002564:	85ce                	mv	a1,s3
    80002566:	8552                	mv	a0,s4
    80002568:	fe0fe0ef          	jal	80000d48 <memmove>
    return 0;
    8000256c:	8526                	mv	a0,s1
    8000256e:	b7cd                	j	80002550 <either_copyin+0x2c>

0000000080002570 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002570:	715d                	addi	sp,sp,-80
    80002572:	e486                	sd	ra,72(sp)
    80002574:	e0a2                	sd	s0,64(sp)
    80002576:	fc26                	sd	s1,56(sp)
    80002578:	f84a                	sd	s2,48(sp)
    8000257a:	f44e                	sd	s3,40(sp)
    8000257c:	f052                	sd	s4,32(sp)
    8000257e:	ec56                	sd	s5,24(sp)
    80002580:	e85a                	sd	s6,16(sp)
    80002582:	e45e                	sd	s7,8(sp)
    80002584:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002586:	00005517          	auipc	a0,0x5
    8000258a:	af250513          	addi	a0,a0,-1294 # 80007078 <etext+0x78>
    8000258e:	f7dfd0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002592:	00010497          	auipc	s1,0x10
    80002596:	50e48493          	addi	s1,s1,1294 # 80012aa0 <proc+0x158>
    8000259a:	00016917          	auipc	s2,0x16
    8000259e:	10690913          	addi	s2,s2,262 # 800186a0 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025a4:	00005997          	auipc	s3,0x5
    800025a8:	c7c98993          	addi	s3,s3,-900 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    800025ac:	00005a97          	auipc	s5,0x5
    800025b0:	c7ca8a93          	addi	s5,s5,-900 # 80007228 <etext+0x228>
    printk("\n");
    800025b4:	00005a17          	auipc	s4,0x5
    800025b8:	ac4a0a13          	addi	s4,s4,-1340 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025bc:	00005b97          	auipc	s7,0x5
    800025c0:	18cb8b93          	addi	s7,s7,396 # 80007748 <states.0>
    800025c4:	a829                	j	800025de <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    800025c6:	ed86a583          	lw	a1,-296(a3)
    800025ca:	8556                	mv	a0,s5
    800025cc:	f3ffd0ef          	jal	8000050a <printk>
    printk("\n");
    800025d0:	8552                	mv	a0,s4
    800025d2:	f39fd0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800025d6:	17048493          	addi	s1,s1,368
    800025da:	03248263          	beq	s1,s2,800025fe <procdump+0x8e>
    if (p->state == UNUSED)
    800025de:	86a6                	mv	a3,s1
    800025e0:	ec04a783          	lw	a5,-320(s1)
    800025e4:	dbed                	beqz	a5,800025d6 <procdump+0x66>
      state = "???";
    800025e6:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025e8:	fcfb6fe3          	bltu	s6,a5,800025c6 <procdump+0x56>
    800025ec:	02079713          	slli	a4,a5,0x20
    800025f0:	01d75793          	srli	a5,a4,0x1d
    800025f4:	97de                	add	a5,a5,s7
    800025f6:	6390                	ld	a2,0(a5)
    800025f8:	f679                	bnez	a2,800025c6 <procdump+0x56>
      state = "???";
    800025fa:	864e                	mv	a2,s3
    800025fc:	b7e9                	j	800025c6 <procdump+0x56>
  }
}
    800025fe:	60a6                	ld	ra,72(sp)
    80002600:	6406                	ld	s0,64(sp)
    80002602:	74e2                	ld	s1,56(sp)
    80002604:	7942                	ld	s2,48(sp)
    80002606:	79a2                	ld	s3,40(sp)
    80002608:	7a02                	ld	s4,32(sp)
    8000260a:	6ae2                	ld	s5,24(sp)
    8000260c:	6b42                	ld	s6,16(sp)
    8000260e:	6ba2                	ld	s7,8(sp)
    80002610:	6161                	addi	sp,sp,80
    80002612:	8082                	ret

0000000080002614 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002614:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002618:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000261c:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000261e:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002620:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002624:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002628:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000262c:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002630:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002634:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002638:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000263c:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002640:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002644:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002648:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000264c:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002650:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002652:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002654:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002658:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000265c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002660:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002664:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002668:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000266c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002670:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002674:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002678:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000267c:	8082                	ret

000000008000267e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000267e:	1141                	addi	sp,sp,-16
    80002680:	e406                	sd	ra,8(sp)
    80002682:	e022                	sd	s0,0(sp)
    80002684:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002686:	00005597          	auipc	a1,0x5
    8000268a:	be258593          	addi	a1,a1,-1054 # 80007268 <etext+0x268>
    8000268e:	00016517          	auipc	a0,0x16
    80002692:	eba50513          	addi	a0,a0,-326 # 80018548 <tickslock>
    80002696:	d12fe0ef          	jal	80000ba8 <initlock>
}
    8000269a:	60a2                	ld	ra,8(sp)
    8000269c:	6402                	ld	s0,0(sp)
    8000269e:	0141                	addi	sp,sp,16
    800026a0:	8082                	ret

00000000800026a2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026a2:	1141                	addi	sp,sp,-16
    800026a4:	e406                	sd	ra,8(sp)
    800026a6:	e022                	sd	s0,0(sp)
    800026a8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    800026aa:	00003797          	auipc	a5,0x3
    800026ae:	1c678793          	addi	a5,a5,454 # 80005870 <kernelvec>
    800026b2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026b6:	60a2                	ld	ra,8(sp)
    800026b8:	6402                	ld	s0,0(sp)
    800026ba:	0141                	addi	sp,sp,16
    800026bc:	8082                	ret

00000000800026be <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800026be:	1141                	addi	sp,sp,-16
    800026c0:	e406                	sd	ra,8(sp)
    800026c2:	e022                	sd	s0,0(sp)
    800026c4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026c6:	a82ff0ef          	jal	80001948 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    800026ca:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800026ce:	04000737          	lui	a4,0x4000
    800026d2:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800026d4:	0732                	slli	a4,a4,0xc
    800026d6:	00004797          	auipc	a5,0x4
    800026da:	92a78793          	addi	a5,a5,-1750 # 80006000 <_trampoline>
    800026de:	00004697          	auipc	a3,0x4
    800026e2:	92268693          	addi	a3,a3,-1758 # 80006000 <_trampoline>
    800026e6:	8f95                	sub	a5,a5,a3
    800026e8:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    800026ea:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026ee:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    800026f0:	18002773          	csrr	a4,satp
    800026f4:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026f6:	6d38                	ld	a4,88(a0)
    800026f8:	613c                	ld	a5,64(a0)
    800026fa:	6685                	lui	a3,0x1
    800026fc:	97b6                	add	a5,a5,a3
    800026fe:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002700:	6d3c                	ld	a5,88(a0)
    80002702:	00000717          	auipc	a4,0x0
    80002706:	10070713          	addi	a4,a4,256 # 80002802 <usertrap>
    8000270a:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000270c:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    8000270e:	8712                	mv	a4,tp
    80002710:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002712:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002716:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000271a:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000271e:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002722:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002724:	6f9c                	ld	a5,24(a5)
    80002726:	14179073          	csrw	sepc,a5
}
    8000272a:	60a2                	ld	ra,8(sp)
    8000272c:	6402                	ld	s0,0(sp)
    8000272e:	0141                	addi	sp,sp,16
    80002730:	8082                	ret

0000000080002732 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002732:	1141                	addi	sp,sp,-16
    80002734:	e406                	sd	ra,8(sp)
    80002736:	e022                	sd	s0,0(sp)
    80002738:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    8000273a:	9daff0ef          	jal	80001914 <cpuid>
    8000273e:	cd11                	beqz	a0,8000275a <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    80002740:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002744:	000f4737          	lui	a4,0xf4
    80002748:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000274c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000274e:	14d79073          	csrw	stimecmp,a5
}
    80002752:	60a2                	ld	ra,8(sp)
    80002754:	6402                	ld	s0,0(sp)
    80002756:	0141                	addi	sp,sp,16
    80002758:	8082                	ret
    acquire(&tickslock);
    8000275a:	00016517          	auipc	a0,0x16
    8000275e:	dee50513          	addi	a0,a0,-530 # 80018548 <tickslock>
    80002762:	cc6fe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002766:	00008717          	auipc	a4,0x8
    8000276a:	cb270713          	addi	a4,a4,-846 # 8000a418 <ticks>
    8000276e:	431c                	lw	a5,0(a4)
    80002770:	2785                	addiw	a5,a5,1
    80002772:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002774:	853a                	mv	a0,a4
    80002776:	a3dff0ef          	jal	800021b2 <wakeup>
    release(&tickslock);
    8000277a:	00016517          	auipc	a0,0x16
    8000277e:	dce50513          	addi	a0,a0,-562 # 80018548 <tickslock>
    80002782:	d2efe0ef          	jal	80000cb0 <release>
    update_proc_aging();
    80002786:	f32ff0ef          	jal	80001eb8 <update_proc_aging>
    8000278a:	bf5d                	j	80002740 <clockintr+0xe>

000000008000278c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000278c:	1101                	addi	sp,sp,-32
    8000278e:	ec06                	sd	ra,24(sp)
    80002790:	e822                	sd	s0,16(sp)
    80002792:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    80002794:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002798:	57fd                	li	a5,-1
    8000279a:	17fe                	slli	a5,a5,0x3f
    8000279c:	07a5                	addi	a5,a5,9
    8000279e:	00f70c63          	beq	a4,a5,800027b6 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    800027a2:	57fd                	li	a5,-1
    800027a4:	17fe                	slli	a5,a5,0x3f
    800027a6:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800027a8:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    800027aa:	04f70863          	beq	a4,a5,800027fa <devintr+0x6e>
  }
}
    800027ae:	60e2                	ld	ra,24(sp)
    800027b0:	6442                	ld	s0,16(sp)
    800027b2:	6105                	addi	sp,sp,32
    800027b4:	8082                	ret
    800027b6:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800027b8:	166030ef          	jal	8000591e <plic_claim>
    800027bc:	872a                	mv	a4,a0
    800027be:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    800027c0:	47a9                	li	a5,10
    800027c2:	00f50963          	beq	a0,a5,800027d4 <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    800027c6:	4785                	li	a5,1
    800027c8:	00f50963          	beq	a0,a5,800027da <devintr+0x4e>
    return 1;
    800027cc:	4505                	li	a0,1
    } else if (irq) {
    800027ce:	eb09                	bnez	a4,800027e0 <devintr+0x54>
    800027d0:	64a2                	ld	s1,8(sp)
    800027d2:	bff1                	j	800027ae <devintr+0x22>
      uartintr();
    800027d4:	a1afe0ef          	jal	800009ee <uartintr>
    if (irq)
    800027d8:	a819                	j	800027ee <devintr+0x62>
      virtio_disk_intr();
    800027da:	600030ef          	jal	80005dda <virtio_disk_intr>
    if (irq)
    800027de:	a801                	j	800027ee <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    800027e0:	85ba                	mv	a1,a4
    800027e2:	00005517          	auipc	a0,0x5
    800027e6:	a8e50513          	addi	a0,a0,-1394 # 80007270 <etext+0x270>
    800027ea:	d21fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    800027ee:	8526                	mv	a0,s1
    800027f0:	150030ef          	jal	80005940 <plic_complete>
    return 1;
    800027f4:	4505                	li	a0,1
    800027f6:	64a2                	ld	s1,8(sp)
    800027f8:	bf5d                	j	800027ae <devintr+0x22>
    clockintr();
    800027fa:	f39ff0ef          	jal	80002732 <clockintr>
    return 2;
    800027fe:	4509                	li	a0,2
    80002800:	b77d                	j	800027ae <devintr+0x22>

0000000080002802 <usertrap>:
{
    80002802:	1101                	addi	sp,sp,-32
    80002804:	ec06                	sd	ra,24(sp)
    80002806:	e822                	sd	s0,16(sp)
    80002808:	e426                	sd	s1,8(sp)
    8000280a:	e04a                	sd	s2,0(sp)
    8000280c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000280e:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002812:	1007f793          	andi	a5,a5,256
    80002816:	eba5                	bnez	a5,80002886 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002818:	00003797          	auipc	a5,0x3
    8000281c:	05878793          	addi	a5,a5,88 # 80005870 <kernelvec>
    80002820:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002824:	924ff0ef          	jal	80001948 <myproc>
    80002828:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000282a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000282c:	14102773          	csrr	a4,sepc
    80002830:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    80002832:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    80002836:	47a1                	li	a5,8
    80002838:	04f70d63          	beq	a4,a5,80002892 <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    8000283c:	f51ff0ef          	jal	8000278c <devintr>
    80002840:	892a                	mv	s2,a0
    80002842:	e54d                	bnez	a0,800028ec <usertrap+0xea>
    80002844:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002848:	47bd                	li	a5,15
    8000284a:	08f70463          	beq	a4,a5,800028d2 <usertrap+0xd0>
    8000284e:	14202773          	csrr	a4,scause
    80002852:	47b5                	li	a5,13
    80002854:	06f70f63          	beq	a4,a5,800028d2 <usertrap+0xd0>
    80002858:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000285c:	5890                	lw	a2,48(s1)
    8000285e:	00005517          	auipc	a0,0x5
    80002862:	a5250513          	addi	a0,a0,-1454 # 800072b0 <etext+0x2b0>
    80002866:	ca5fd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000286a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000286e:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002872:	00005517          	auipc	a0,0x5
    80002876:	a6e50513          	addi	a0,a0,-1426 # 800072e0 <etext+0x2e0>
    8000287a:	c91fd0ef          	jal	8000050a <printk>
    setkilled(p);
    8000287e:	8526                	mv	a0,s1
    80002880:	b01ff0ef          	jal	80002380 <setkilled>
    80002884:	a015                	j	800028a8 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    80002886:	00005517          	auipc	a0,0x5
    8000288a:	a0a50513          	addi	a0,a0,-1526 # 80007290 <etext+0x290>
    8000288e:	fa7fd0ef          	jal	80000834 <panic>
    if (killed(p))
    80002892:	b13ff0ef          	jal	800023a4 <killed>
    80002896:	e915                	bnez	a0,800028ca <usertrap+0xc8>
    p->trapframe->epc += 4;
    80002898:	6cb8                	ld	a4,88(s1)
    8000289a:	6f1c                	ld	a5,24(a4)
    8000289c:	0791                	addi	a5,a5,4
    8000289e:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    800028a0:	10016073          	csrsi	sstatus,2
    syscall();
    800028a4:	244000ef          	jal	80002ae8 <syscall>
  if (killed(p))
    800028a8:	8526                	mv	a0,s1
    800028aa:	afbff0ef          	jal	800023a4 <killed>
    800028ae:	e521                	bnez	a0,800028f6 <usertrap+0xf4>
  prepare_return();
    800028b0:	e0fff0ef          	jal	800026be <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800028b4:	68a8                	ld	a0,80(s1)
    800028b6:	8131                	srli	a0,a0,0xc
    800028b8:	57fd                	li	a5,-1
    800028ba:	17fe                	slli	a5,a5,0x3f
    800028bc:	8d5d                	or	a0,a0,a5
}
    800028be:	60e2                	ld	ra,24(sp)
    800028c0:	6442                	ld	s0,16(sp)
    800028c2:	64a2                	ld	s1,8(sp)
    800028c4:	6902                	ld	s2,0(sp)
    800028c6:	6105                	addi	sp,sp,32
    800028c8:	8082                	ret
      kexit(-1);
    800028ca:	557d                	li	a0,-1
    800028cc:	9a3ff0ef          	jal	8000226e <kexit>
    800028d0:	b7e1                	j	80002898 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    800028d2:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    800028d6:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    800028da:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    800028dc:	0016b693          	seqz	a3,a3
    800028e0:	64ac                	ld	a1,72(s1)
    800028e2:	68a8                	ld	a0,80(s1)
    800028e4:	c23fe0ef          	jal	80001506 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800028e8:	f161                	bnez	a0,800028a8 <usertrap+0xa6>
    800028ea:	b7bd                	j	80002858 <usertrap+0x56>
  if (killed(p))
    800028ec:	8526                	mv	a0,s1
    800028ee:	ab7ff0ef          	jal	800023a4 <killed>
    800028f2:	c511                	beqz	a0,800028fe <usertrap+0xfc>
    800028f4:	a011                	j	800028f8 <usertrap+0xf6>
    800028f6:	4901                	li	s2,0
    kexit(-1);
    800028f8:	557d                	li	a0,-1
    800028fa:	975ff0ef          	jal	8000226e <kexit>
  if (which_dev == 2)
    800028fe:	4789                	li	a5,2
    80002900:	faf918e3          	bne	s2,a5,800028b0 <usertrap+0xae>
    yield();
    80002904:	817ff0ef          	jal	8000211a <yield>
    80002908:	b765                	j	800028b0 <usertrap+0xae>

000000008000290a <kerneltrap>:
{
    8000290a:	7179                	addi	sp,sp,-48
    8000290c:	f406                	sd	ra,40(sp)
    8000290e:	f022                	sd	s0,32(sp)
    80002910:	ec26                	sd	s1,24(sp)
    80002912:	e84a                	sd	s2,16(sp)
    80002914:	e44e                	sd	s3,8(sp)
    80002916:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002918:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000291c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    80002920:	142027f3          	csrr	a5,scause
    80002924:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    80002926:	1004f793          	andi	a5,s1,256
    8000292a:	c795                	beqz	a5,80002956 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000292c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002930:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002932:	eb85                	bnez	a5,80002962 <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    80002934:	e59ff0ef          	jal	8000278c <devintr>
    80002938:	c91d                	beqz	a0,8000296e <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    8000293a:	4789                	li	a5,2
    8000293c:	04f50a63          	beq	a0,a5,80002990 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002940:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002944:	10049073          	csrw	sstatus,s1
}
    80002948:	70a2                	ld	ra,40(sp)
    8000294a:	7402                	ld	s0,32(sp)
    8000294c:	64e2                	ld	s1,24(sp)
    8000294e:	6942                	ld	s2,16(sp)
    80002950:	69a2                	ld	s3,8(sp)
    80002952:	6145                	addi	sp,sp,48
    80002954:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002956:	00005517          	auipc	a0,0x5
    8000295a:	9b250513          	addi	a0,a0,-1614 # 80007308 <etext+0x308>
    8000295e:	ed7fd0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    80002962:	00005517          	auipc	a0,0x5
    80002966:	9ce50513          	addi	a0,a0,-1586 # 80007330 <etext+0x330>
    8000296a:	ecbfd0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000296e:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002972:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    80002976:	85ce                	mv	a1,s3
    80002978:	00005517          	auipc	a0,0x5
    8000297c:	9d850513          	addi	a0,a0,-1576 # 80007350 <etext+0x350>
    80002980:	b8bfd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    80002984:	00005517          	auipc	a0,0x5
    80002988:	9f450513          	addi	a0,a0,-1548 # 80007378 <etext+0x378>
    8000298c:	ea9fd0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    80002990:	fb9fe0ef          	jal	80001948 <myproc>
    80002994:	d555                	beqz	a0,80002940 <kerneltrap+0x36>
    yield();
    80002996:	f84ff0ef          	jal	8000211a <yield>
    8000299a:	b75d                	j	80002940 <kerneltrap+0x36>

000000008000299c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000299c:	1101                	addi	sp,sp,-32
    8000299e:	ec06                	sd	ra,24(sp)
    800029a0:	e822                	sd	s0,16(sp)
    800029a2:	e426                	sd	s1,8(sp)
    800029a4:	1000                	addi	s0,sp,32
    800029a6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029a8:	fa1fe0ef          	jal	80001948 <myproc>
  switch (n) {
    800029ac:	4795                	li	a5,5
    800029ae:	0497e163          	bltu	a5,s1,800029f0 <argraw+0x54>
    800029b2:	048a                	slli	s1,s1,0x2
    800029b4:	00005717          	auipc	a4,0x5
    800029b8:	dc470713          	addi	a4,a4,-572 # 80007778 <states.0+0x30>
    800029bc:	94ba                	add	s1,s1,a4
    800029be:	409c                	lw	a5,0(s1)
    800029c0:	97ba                	add	a5,a5,a4
    800029c2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029c4:	6d3c                	ld	a5,88(a0)
    800029c6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029c8:	60e2                	ld	ra,24(sp)
    800029ca:	6442                	ld	s0,16(sp)
    800029cc:	64a2                	ld	s1,8(sp)
    800029ce:	6105                	addi	sp,sp,32
    800029d0:	8082                	ret
    return p->trapframe->a1;
    800029d2:	6d3c                	ld	a5,88(a0)
    800029d4:	7fa8                	ld	a0,120(a5)
    800029d6:	bfcd                	j	800029c8 <argraw+0x2c>
    return p->trapframe->a2;
    800029d8:	6d3c                	ld	a5,88(a0)
    800029da:	63c8                	ld	a0,128(a5)
    800029dc:	b7f5                	j	800029c8 <argraw+0x2c>
    return p->trapframe->a3;
    800029de:	6d3c                	ld	a5,88(a0)
    800029e0:	67c8                	ld	a0,136(a5)
    800029e2:	b7dd                	j	800029c8 <argraw+0x2c>
    return p->trapframe->a4;
    800029e4:	6d3c                	ld	a5,88(a0)
    800029e6:	6bc8                	ld	a0,144(a5)
    800029e8:	b7c5                	j	800029c8 <argraw+0x2c>
    return p->trapframe->a5;
    800029ea:	6d3c                	ld	a5,88(a0)
    800029ec:	6fc8                	ld	a0,152(a5)
    800029ee:	bfe9                	j	800029c8 <argraw+0x2c>
  panic("argraw");
    800029f0:	00005517          	auipc	a0,0x5
    800029f4:	99850513          	addi	a0,a0,-1640 # 80007388 <etext+0x388>
    800029f8:	e3dfd0ef          	jal	80000834 <panic>

00000000800029fc <fetchaddr>:
{
    800029fc:	1101                	addi	sp,sp,-32
    800029fe:	ec06                	sd	ra,24(sp)
    80002a00:	e822                	sd	s0,16(sp)
    80002a02:	e426                	sd	s1,8(sp)
    80002a04:	e04a                	sd	s2,0(sp)
    80002a06:	1000                	addi	s0,sp,32
    80002a08:	84aa                	mv	s1,a0
    80002a0a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a0c:	f3dfe0ef          	jal	80001948 <myproc>
  if (addr >= p->sz ||
    80002a10:	652c                	ld	a1,72(a0)
    80002a12:	02b4f663          	bgeu	s1,a1,80002a3e <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a16:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002a1a:	02f5e463          	bltu	a1,a5,80002a42 <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a1e:	4721                	li	a4,8
    80002a20:	86a6                	mv	a3,s1
    80002a22:	864a                	mv	a2,s2
    80002a24:	6928                	ld	a0,80(a0)
    80002a26:	c23fe0ef          	jal	80001648 <copyin>
    80002a2a:	00a03533          	snez	a0,a0
    80002a2e:	40a0053b          	negw	a0,a0
}
    80002a32:	60e2                	ld	ra,24(sp)
    80002a34:	6442                	ld	s0,16(sp)
    80002a36:	64a2                	ld	s1,8(sp)
    80002a38:	6902                	ld	s2,0(sp)
    80002a3a:	6105                	addi	sp,sp,32
    80002a3c:	8082                	ret
    return -1;
    80002a3e:	557d                	li	a0,-1
    80002a40:	bfcd                	j	80002a32 <fetchaddr+0x36>
    80002a42:	557d                	li	a0,-1
    80002a44:	b7fd                	j	80002a32 <fetchaddr+0x36>

0000000080002a46 <fetchstr>:
{
    80002a46:	7179                	addi	sp,sp,-48
    80002a48:	f406                	sd	ra,40(sp)
    80002a4a:	f022                	sd	s0,32(sp)
    80002a4c:	ec26                	sd	s1,24(sp)
    80002a4e:	e84a                	sd	s2,16(sp)
    80002a50:	e44e                	sd	s3,8(sp)
    80002a52:	1800                	addi	s0,sp,48
    80002a54:	89aa                	mv	s3,a0
    80002a56:	84ae                	mv	s1,a1
    80002a58:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002a5a:	eeffe0ef          	jal	80001948 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002a5e:	874a                	mv	a4,s2
    80002a60:	86ce                	mv	a3,s3
    80002a62:	8626                	mv	a2,s1
    80002a64:	652c                	ld	a1,72(a0)
    80002a66:	6928                	ld	a0,80(a0)
    80002a68:	c7dfe0ef          	jal	800016e4 <copyinstr>
    80002a6c:	00054c63          	bltz	a0,80002a84 <fetchstr+0x3e>
  return strlen(buf);
    80002a70:	8526                	mv	a0,s1
    80002a72:	c00fe0ef          	jal	80000e72 <strlen>
}
    80002a76:	70a2                	ld	ra,40(sp)
    80002a78:	7402                	ld	s0,32(sp)
    80002a7a:	64e2                	ld	s1,24(sp)
    80002a7c:	6942                	ld	s2,16(sp)
    80002a7e:	69a2                	ld	s3,8(sp)
    80002a80:	6145                	addi	sp,sp,48
    80002a82:	8082                	ret
    return -1;
    80002a84:	557d                	li	a0,-1
    80002a86:	bfc5                	j	80002a76 <fetchstr+0x30>

0000000080002a88 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a88:	1101                	addi	sp,sp,-32
    80002a8a:	ec06                	sd	ra,24(sp)
    80002a8c:	e822                	sd	s0,16(sp)
    80002a8e:	e426                	sd	s1,8(sp)
    80002a90:	1000                	addi	s0,sp,32
    80002a92:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a94:	f09ff0ef          	jal	8000299c <argraw>
    80002a98:	c088                	sw	a0,0(s1)
}
    80002a9a:	60e2                	ld	ra,24(sp)
    80002a9c:	6442                	ld	s0,16(sp)
    80002a9e:	64a2                	ld	s1,8(sp)
    80002aa0:	6105                	addi	sp,sp,32
    80002aa2:	8082                	ret

0000000080002aa4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002aa4:	1101                	addi	sp,sp,-32
    80002aa6:	ec06                	sd	ra,24(sp)
    80002aa8:	e822                	sd	s0,16(sp)
    80002aaa:	e426                	sd	s1,8(sp)
    80002aac:	1000                	addi	s0,sp,32
    80002aae:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ab0:	eedff0ef          	jal	8000299c <argraw>
    80002ab4:	e088                	sd	a0,0(s1)
}
    80002ab6:	60e2                	ld	ra,24(sp)
    80002ab8:	6442                	ld	s0,16(sp)
    80002aba:	64a2                	ld	s1,8(sp)
    80002abc:	6105                	addi	sp,sp,32
    80002abe:	8082                	ret

0000000080002ac0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ac0:	1101                	addi	sp,sp,-32
    80002ac2:	ec06                	sd	ra,24(sp)
    80002ac4:	e822                	sd	s0,16(sp)
    80002ac6:	e426                	sd	s1,8(sp)
    80002ac8:	e04a                	sd	s2,0(sp)
    80002aca:	1000                	addi	s0,sp,32
    80002acc:	892e                	mv	s2,a1
    80002ace:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002ad0:	ecdff0ef          	jal	8000299c <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002ad4:	8626                	mv	a2,s1
    80002ad6:	85ca                	mv	a1,s2
    80002ad8:	f6fff0ef          	jal	80002a46 <fetchstr>
}
    80002adc:	60e2                	ld	ra,24(sp)
    80002ade:	6442                	ld	s0,16(sp)
    80002ae0:	64a2                	ld	s1,8(sp)
    80002ae2:	6902                	ld	s2,0(sp)
    80002ae4:	6105                	addi	sp,sp,32
    80002ae6:	8082                	ret

0000000080002ae8 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002ae8:	1101                	addi	sp,sp,-32
    80002aea:	ec06                	sd	ra,24(sp)
    80002aec:	e822                	sd	s0,16(sp)
    80002aee:	e426                	sd	s1,8(sp)
    80002af0:	e04a                	sd	s2,0(sp)
    80002af2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002af4:	e55fe0ef          	jal	80001948 <myproc>
    80002af8:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002afa:	05853903          	ld	s2,88(a0)
    80002afe:	0a893783          	ld	a5,168(s2)
    80002b02:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b06:	37fd                	addiw	a5,a5,-1
    80002b08:	475d                	li	a4,23
    80002b0a:	00f76f63          	bltu	a4,a5,80002b28 <syscall+0x40>
    80002b0e:	00369713          	slli	a4,a3,0x3
    80002b12:	00005797          	auipc	a5,0x5
    80002b16:	c7e78793          	addi	a5,a5,-898 # 80007790 <syscalls>
    80002b1a:	97ba                	add	a5,a5,a4
    80002b1c:	639c                	ld	a5,0(a5)
    80002b1e:	c789                	beqz	a5,80002b28 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b20:	9782                	jalr	a5
    80002b22:	06a93823          	sd	a0,112(s2)
    80002b26:	a829                	j	80002b40 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002b28:	15848613          	addi	a2,s1,344
    80002b2c:	588c                	lw	a1,48(s1)
    80002b2e:	00005517          	auipc	a0,0x5
    80002b32:	86250513          	addi	a0,a0,-1950 # 80007390 <etext+0x390>
    80002b36:	9d5fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002b3a:	6cbc                	ld	a5,88(s1)
    80002b3c:	577d                	li	a4,-1
    80002b3e:	fbb8                	sd	a4,112(a5)
  }
}
    80002b40:	60e2                	ld	ra,24(sp)
    80002b42:	6442                	ld	s0,16(sp)
    80002b44:	64a2                	ld	s1,8(sp)
    80002b46:	6902                	ld	s2,0(sp)
    80002b48:	6105                	addi	sp,sp,32
    80002b4a:	8082                	ret

0000000080002b4c <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002b4c:	1101                	addi	sp,sp,-32
    80002b4e:	ec06                	sd	ra,24(sp)
    80002b50:	e822                	sd	s0,16(sp)
    80002b52:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002b54:	fec40593          	addi	a1,s0,-20
    80002b58:	4501                	li	a0,0
    80002b5a:	f2fff0ef          	jal	80002a88 <argint>
  kexit(n);
    80002b5e:	fec42503          	lw	a0,-20(s0)
    80002b62:	f0cff0ef          	jal	8000226e <kexit>
  return 0; // not reached
}
    80002b66:	4501                	li	a0,0
    80002b68:	60e2                	ld	ra,24(sp)
    80002b6a:	6442                	ld	s0,16(sp)
    80002b6c:	6105                	addi	sp,sp,32
    80002b6e:	8082                	ret

0000000080002b70 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b70:	1141                	addi	sp,sp,-16
    80002b72:	e406                	sd	ra,8(sp)
    80002b74:	e022                	sd	s0,0(sp)
    80002b76:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b78:	dd1fe0ef          	jal	80001948 <myproc>
}
    80002b7c:	5908                	lw	a0,48(a0)
    80002b7e:	60a2                	ld	ra,8(sp)
    80002b80:	6402                	ld	s0,0(sp)
    80002b82:	0141                	addi	sp,sp,16
    80002b84:	8082                	ret

0000000080002b86 <sys_fork>:

uint64
sys_fork(void)
{
    80002b86:	1141                	addi	sp,sp,-16
    80002b88:	e406                	sd	ra,8(sp)
    80002b8a:	e022                	sd	s0,0(sp)
    80002b8c:	0800                	addi	s0,sp,16
  return kfork();
    80002b8e:	92eff0ef          	jal	80001cbc <kfork>
}
    80002b92:	60a2                	ld	ra,8(sp)
    80002b94:	6402                	ld	s0,0(sp)
    80002b96:	0141                	addi	sp,sp,16
    80002b98:	8082                	ret

0000000080002b9a <sys_wait>:

uint64
sys_wait(void)
{
    80002b9a:	1101                	addi	sp,sp,-32
    80002b9c:	ec06                	sd	ra,24(sp)
    80002b9e:	e822                	sd	s0,16(sp)
    80002ba0:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002ba2:	fe840593          	addi	a1,s0,-24
    80002ba6:	4501                	li	a0,0
    80002ba8:	efdff0ef          	jal	80002aa4 <argaddr>
  return kwait(p);
    80002bac:	fe843503          	ld	a0,-24(s0)
    80002bb0:	81fff0ef          	jal	800023ce <kwait>
}
    80002bb4:	60e2                	ld	ra,24(sp)
    80002bb6:	6442                	ld	s0,16(sp)
    80002bb8:	6105                	addi	sp,sp,32
    80002bba:	8082                	ret

0000000080002bbc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002bbc:	7179                	addi	sp,sp,-48
    80002bbe:	f406                	sd	ra,40(sp)
    80002bc0:	f022                	sd	s0,32(sp)
    80002bc2:	ec26                	sd	s1,24(sp)
    80002bc4:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002bc6:	fd840593          	addi	a1,s0,-40
    80002bca:	4501                	li	a0,0
    80002bcc:	ebdff0ef          	jal	80002a88 <argint>
  argint(1, &t);
    80002bd0:	fdc40593          	addi	a1,s0,-36
    80002bd4:	4505                	li	a0,1
    80002bd6:	eb3ff0ef          	jal	80002a88 <argint>
  addr = myproc()->sz;
    80002bda:	d6ffe0ef          	jal	80001948 <myproc>
    80002bde:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002be0:	fdc42703          	lw	a4,-36(s0)
    80002be4:	4785                	li	a5,1
    80002be6:	02f70763          	beq	a4,a5,80002c14 <sys_sbrk+0x58>
    80002bea:	fd842783          	lw	a5,-40(s0)
    80002bee:	0207c363          	bltz	a5,80002c14 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002bf2:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002bf4:	02000737          	lui	a4,0x2000
    80002bf8:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002bfa:	0736                	slli	a4,a4,0xd
    80002bfc:	02f76a63          	bltu	a4,a5,80002c30 <sys_sbrk+0x74>
    80002c00:	0297e863          	bltu	a5,s1,80002c30 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002c04:	d45fe0ef          	jal	80001948 <myproc>
    80002c08:	fd842703          	lw	a4,-40(s0)
    80002c0c:	653c                	ld	a5,72(a0)
    80002c0e:	97ba                	add	a5,a5,a4
    80002c10:	e53c                	sd	a5,72(a0)
    80002c12:	a039                	j	80002c20 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002c14:	fd842503          	lw	a0,-40(s0)
    80002c18:	842ff0ef          	jal	80001c5a <growproc>
    80002c1c:	00054863          	bltz	a0,80002c2c <sys_sbrk+0x70>
  }
  return addr;
}
    80002c20:	8526                	mv	a0,s1
    80002c22:	70a2                	ld	ra,40(sp)
    80002c24:	7402                	ld	s0,32(sp)
    80002c26:	64e2                	ld	s1,24(sp)
    80002c28:	6145                	addi	sp,sp,48
    80002c2a:	8082                	ret
      return -1;
    80002c2c:	54fd                	li	s1,-1
    80002c2e:	bfcd                	j	80002c20 <sys_sbrk+0x64>
      return -1;
    80002c30:	54fd                	li	s1,-1
    80002c32:	b7fd                	j	80002c20 <sys_sbrk+0x64>

0000000080002c34 <sys_pause>:

uint64
sys_pause(void)
{
    80002c34:	7139                	addi	sp,sp,-64
    80002c36:	fc06                	sd	ra,56(sp)
    80002c38:	f822                	sd	s0,48(sp)
    80002c3a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c3c:	fcc40593          	addi	a1,s0,-52
    80002c40:	4501                	li	a0,0
    80002c42:	e47ff0ef          	jal	80002a88 <argint>
  if (n < 0)
    80002c46:	fcc42783          	lw	a5,-52(s0)
    80002c4a:	0807c063          	bltz	a5,80002cca <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002c4e:	00016517          	auipc	a0,0x16
    80002c52:	8fa50513          	addi	a0,a0,-1798 # 80018548 <tickslock>
    80002c56:	fd3fd0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002c5a:	fcc42783          	lw	a5,-52(s0)
    80002c5e:	cbb9                	beqz	a5,80002cb4 <sys_pause+0x80>
    80002c60:	f426                	sd	s1,40(sp)
    80002c62:	f04a                	sd	s2,32(sp)
    80002c64:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002c66:	00007997          	auipc	s3,0x7
    80002c6a:	7b29a983          	lw	s3,1970(s3) # 8000a418 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002c6e:	00007917          	auipc	s2,0x7
    80002c72:	7aa90913          	addi	s2,s2,1962 # 8000a418 <ticks>
    release(&tickslock);
    80002c76:	00016497          	auipc	s1,0x16
    80002c7a:	8d248493          	addi	s1,s1,-1838 # 80018548 <tickslock>
    if (killed(myproc())) {
    80002c7e:	ccbfe0ef          	jal	80001948 <myproc>
    80002c82:	f22ff0ef          	jal	800023a4 <killed>
    80002c86:	e529                	bnez	a0,80002cd0 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002c88:	854a                	mv	a0,s2
    80002c8a:	cbcff0ef          	jal	80002146 <sleep_prepare>
    release(&tickslock);
    80002c8e:	8526                	mv	a0,s1
    80002c90:	820fe0ef          	jal	80000cb0 <release>
    sleep();
    80002c94:	ceeff0ef          	jal	80002182 <sleep>
    acquire(&tickslock);
    80002c98:	8526                	mv	a0,s1
    80002c9a:	f8ffd0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002c9e:	00092783          	lw	a5,0(s2)
    80002ca2:	413787bb          	subw	a5,a5,s3
    80002ca6:	fcc42703          	lw	a4,-52(s0)
    80002caa:	fce7eae3          	bltu	a5,a4,80002c7e <sys_pause+0x4a>
    80002cae:	74a2                	ld	s1,40(sp)
    80002cb0:	7902                	ld	s2,32(sp)
    80002cb2:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002cb4:	00016517          	auipc	a0,0x16
    80002cb8:	89450513          	addi	a0,a0,-1900 # 80018548 <tickslock>
    80002cbc:	ff5fd0ef          	jal	80000cb0 <release>
  return 0;
    80002cc0:	4501                	li	a0,0
}
    80002cc2:	70e2                	ld	ra,56(sp)
    80002cc4:	7442                	ld	s0,48(sp)
    80002cc6:	6121                	addi	sp,sp,64
    80002cc8:	8082                	ret
    n = 0;
    80002cca:	fc042623          	sw	zero,-52(s0)
    80002cce:	b741                	j	80002c4e <sys_pause+0x1a>
      release(&tickslock);
    80002cd0:	00016517          	auipc	a0,0x16
    80002cd4:	87850513          	addi	a0,a0,-1928 # 80018548 <tickslock>
    80002cd8:	fd9fd0ef          	jal	80000cb0 <release>
      return -1;
    80002cdc:	557d                	li	a0,-1
    80002cde:	74a2                	ld	s1,40(sp)
    80002ce0:	7902                	ld	s2,32(sp)
    80002ce2:	69e2                	ld	s3,24(sp)
    80002ce4:	bff9                	j	80002cc2 <sys_pause+0x8e>

0000000080002ce6 <sys_kill>:

uint64
sys_kill(void)
{
    80002ce6:	1101                	addi	sp,sp,-32
    80002ce8:	ec06                	sd	ra,24(sp)
    80002cea:	e822                	sd	s0,16(sp)
    80002cec:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002cee:	fec40593          	addi	a1,s0,-20
    80002cf2:	4501                	li	a0,0
    80002cf4:	d95ff0ef          	jal	80002a88 <argint>
  return kkill(pid);
    80002cf8:	fec42503          	lw	a0,-20(s0)
    80002cfc:	e18ff0ef          	jal	80002314 <kkill>
}
    80002d00:	60e2                	ld	ra,24(sp)
    80002d02:	6442                	ld	s0,16(sp)
    80002d04:	6105                	addi	sp,sp,32
    80002d06:	8082                	ret

0000000080002d08 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d08:	1101                	addi	sp,sp,-32
    80002d0a:	ec06                	sd	ra,24(sp)
    80002d0c:	e822                	sd	s0,16(sp)
    80002d0e:	e426                	sd	s1,8(sp)
    80002d10:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d12:	00016517          	auipc	a0,0x16
    80002d16:	83650513          	addi	a0,a0,-1994 # 80018548 <tickslock>
    80002d1a:	f0ffd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002d1e:	00007797          	auipc	a5,0x7
    80002d22:	6fa7a783          	lw	a5,1786(a5) # 8000a418 <ticks>
    80002d26:	84be                	mv	s1,a5
  release(&tickslock);
    80002d28:	00016517          	auipc	a0,0x16
    80002d2c:	82050513          	addi	a0,a0,-2016 # 80018548 <tickslock>
    80002d30:	f81fd0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002d34:	02049513          	slli	a0,s1,0x20
    80002d38:	9101                	srli	a0,a0,0x20
    80002d3a:	60e2                	ld	ra,24(sp)
    80002d3c:	6442                	ld	s0,16(sp)
    80002d3e:	64a2                	ld	s1,8(sp)
    80002d40:	6105                	addi	sp,sp,32
    80002d42:	8082                	ret

0000000080002d44 <sys_set_priority>:

uint64
sys_set_priority(void)
{
    80002d44:	1101                	addi	sp,sp,-32
    80002d46:	ec06                	sd	ra,24(sp)
    80002d48:	e822                	sd	s0,16(sp)
    80002d4a:	1000                	addi	s0,sp,32
  int pid;
  int priority;

  argint(0, &pid);
    80002d4c:	fec40593          	addi	a1,s0,-20
    80002d50:	4501                	li	a0,0
    80002d52:	d37ff0ef          	jal	80002a88 <argint>
  argint(1, &priority);
    80002d56:	fe840593          	addi	a1,s0,-24
    80002d5a:	4505                	li	a0,1
    80002d5c:	d2dff0ef          	jal	80002a88 <argint>
  return set_priority(pid, priority);
    80002d60:	fe842583          	lw	a1,-24(s0)
    80002d64:	fec42503          	lw	a0,-20(s0)
    80002d68:	862ff0ef          	jal	80001dca <set_priority>
}
    80002d6c:	60e2                	ld	ra,24(sp)
    80002d6e:	6442                	ld	s0,16(sp)
    80002d70:	6105                	addi	sp,sp,32
    80002d72:	8082                	ret

0000000080002d74 <sys_get_priority>:

uint64
sys_get_priority(void)
{
    80002d74:	1101                	addi	sp,sp,-32
    80002d76:	ec06                	sd	ra,24(sp)
    80002d78:	e822                	sd	s0,16(sp)
    80002d7a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d7c:	fec40593          	addi	a1,s0,-20
    80002d80:	4501                	li	a0,0
    80002d82:	d07ff0ef          	jal	80002a88 <argint>
  return get_priority(pid);
    80002d86:	fec42503          	lw	a0,-20(s0)
    80002d8a:	8c8ff0ef          	jal	80001e52 <get_priority>
}
    80002d8e:	60e2                	ld	ra,24(sp)
    80002d90:	6442                	ld	s0,16(sp)
    80002d92:	6105                	addi	sp,sp,32
    80002d94:	8082                	ret

0000000080002d96 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d96:	7179                	addi	sp,sp,-48
    80002d98:	f406                	sd	ra,40(sp)
    80002d9a:	f022                	sd	s0,32(sp)
    80002d9c:	ec26                	sd	s1,24(sp)
    80002d9e:	e84a                	sd	s2,16(sp)
    80002da0:	e44e                	sd	s3,8(sp)
    80002da2:	e052                	sd	s4,0(sp)
    80002da4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002da6:	00004597          	auipc	a1,0x4
    80002daa:	60a58593          	addi	a1,a1,1546 # 800073b0 <etext+0x3b0>
    80002dae:	00015517          	auipc	a0,0x15
    80002db2:	7b250513          	addi	a0,a0,1970 # 80018560 <bcache>
    80002db6:	df3fd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002dba:	0001d797          	auipc	a5,0x1d
    80002dbe:	7a678793          	addi	a5,a5,1958 # 80020560 <bcache+0x8000>
    80002dc2:	0001e717          	auipc	a4,0x1e
    80002dc6:	a0670713          	addi	a4,a4,-1530 # 800207c8 <bcache+0x8268>
    80002dca:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002dce:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002dd2:	00015497          	auipc	s1,0x15
    80002dd6:	7a648493          	addi	s1,s1,1958 # 80018578 <bcache+0x18>
    b->next = bcache.head.next;
    80002dda:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ddc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002dde:	00004a17          	auipc	s4,0x4
    80002de2:	5daa0a13          	addi	s4,s4,1498 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002de6:	2b893783          	ld	a5,696(s2)
    80002dea:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002dec:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002df0:	85d2                	mv	a1,s4
    80002df2:	01048513          	addi	a0,s1,16
    80002df6:	41c010ef          	jal	80004212 <initsleeplock>
    bcache.head.next->prev = b;
    80002dfa:	2b893783          	ld	a5,696(s2)
    80002dfe:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e00:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002e04:	45848493          	addi	s1,s1,1112
    80002e08:	fd349fe3          	bne	s1,s3,80002de6 <binit+0x50>
  }
}
    80002e0c:	70a2                	ld	ra,40(sp)
    80002e0e:	7402                	ld	s0,32(sp)
    80002e10:	64e2                	ld	s1,24(sp)
    80002e12:	6942                	ld	s2,16(sp)
    80002e14:	69a2                	ld	s3,8(sp)
    80002e16:	6a02                	ld	s4,0(sp)
    80002e18:	6145                	addi	sp,sp,48
    80002e1a:	8082                	ret

0000000080002e1c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002e1c:	7179                	addi	sp,sp,-48
    80002e1e:	f406                	sd	ra,40(sp)
    80002e20:	f022                	sd	s0,32(sp)
    80002e22:	ec26                	sd	s1,24(sp)
    80002e24:	e84a                	sd	s2,16(sp)
    80002e26:	e44e                	sd	s3,8(sp)
    80002e28:	1800                	addi	s0,sp,48
    80002e2a:	892a                	mv	s2,a0
    80002e2c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e2e:	00015517          	auipc	a0,0x15
    80002e32:	73250513          	addi	a0,a0,1842 # 80018560 <bcache>
    80002e36:	df3fd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002e3a:	0001e497          	auipc	s1,0x1e
    80002e3e:	9de4b483          	ld	s1,-1570(s1) # 80020818 <bcache+0x82b8>
    80002e42:	0001e797          	auipc	a5,0x1e
    80002e46:	98678793          	addi	a5,a5,-1658 # 800207c8 <bcache+0x8268>
    80002e4a:	02f48b63          	beq	s1,a5,80002e80 <bread+0x64>
    80002e4e:	873e                	mv	a4,a5
    80002e50:	a021                	j	80002e58 <bread+0x3c>
    80002e52:	68a4                	ld	s1,80(s1)
    80002e54:	02e48663          	beq	s1,a4,80002e80 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002e58:	449c                	lw	a5,8(s1)
    80002e5a:	ff279ce3          	bne	a5,s2,80002e52 <bread+0x36>
    80002e5e:	44dc                	lw	a5,12(s1)
    80002e60:	ff3799e3          	bne	a5,s3,80002e52 <bread+0x36>
      b->refcnt++;
    80002e64:	40bc                	lw	a5,64(s1)
    80002e66:	2785                	addiw	a5,a5,1
    80002e68:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e6a:	00015517          	auipc	a0,0x15
    80002e6e:	6f650513          	addi	a0,a0,1782 # 80018560 <bcache>
    80002e72:	e3ffd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002e76:	01048513          	addi	a0,s1,16
    80002e7a:	3ce010ef          	jal	80004248 <acquiresleep>
      return b;
    80002e7e:	a889                	j	80002ed0 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002e80:	0001e497          	auipc	s1,0x1e
    80002e84:	9904b483          	ld	s1,-1648(s1) # 80020810 <bcache+0x82b0>
    80002e88:	0001e797          	auipc	a5,0x1e
    80002e8c:	94078793          	addi	a5,a5,-1728 # 800207c8 <bcache+0x8268>
    80002e90:	00f48863          	beq	s1,a5,80002ea0 <bread+0x84>
    80002e94:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002e96:	40bc                	lw	a5,64(s1)
    80002e98:	cb91                	beqz	a5,80002eac <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002e9a:	64a4                	ld	s1,72(s1)
    80002e9c:	fee49de3          	bne	s1,a4,80002e96 <bread+0x7a>
  panic("bget: no buffers");
    80002ea0:	00004517          	auipc	a0,0x4
    80002ea4:	52050513          	addi	a0,a0,1312 # 800073c0 <etext+0x3c0>
    80002ea8:	98dfd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002eac:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002eb0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002eb4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002eb8:	4785                	li	a5,1
    80002eba:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ebc:	00015517          	auipc	a0,0x15
    80002ec0:	6a450513          	addi	a0,a0,1700 # 80018560 <bcache>
    80002ec4:	dedfd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002ec8:	01048513          	addi	a0,s1,16
    80002ecc:	37c010ef          	jal	80004248 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002ed0:	409c                	lw	a5,0(s1)
    80002ed2:	cb89                	beqz	a5,80002ee4 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ed4:	8526                	mv	a0,s1
    80002ed6:	70a2                	ld	ra,40(sp)
    80002ed8:	7402                	ld	s0,32(sp)
    80002eda:	64e2                	ld	s1,24(sp)
    80002edc:	6942                	ld	s2,16(sp)
    80002ede:	69a2                	ld	s3,8(sp)
    80002ee0:	6145                	addi	sp,sp,48
    80002ee2:	8082                	ret
    virtio_disk_rw(b, 0);
    80002ee4:	4581                	li	a1,0
    80002ee6:	8526                	mv	a0,s1
    80002ee8:	4bf020ef          	jal	80005ba6 <virtio_disk_rw>
    b->valid = 1;
    80002eec:	4785                	li	a5,1
    80002eee:	c09c                	sw	a5,0(s1)
  return b;
    80002ef0:	b7d5                	j	80002ed4 <bread+0xb8>

0000000080002ef2 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002ef2:	1101                	addi	sp,sp,-32
    80002ef4:	ec06                	sd	ra,24(sp)
    80002ef6:	e822                	sd	s0,16(sp)
    80002ef8:	e426                	sd	s1,8(sp)
    80002efa:	1000                	addi	s0,sp,32
    80002efc:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002efe:	0541                	addi	a0,a0,16
    80002f00:	3d4010ef          	jal	800042d4 <holdingsleep>
    80002f04:	c911                	beqz	a0,80002f18 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f06:	4585                	li	a1,1
    80002f08:	8526                	mv	a0,s1
    80002f0a:	49d020ef          	jal	80005ba6 <virtio_disk_rw>
}
    80002f0e:	60e2                	ld	ra,24(sp)
    80002f10:	6442                	ld	s0,16(sp)
    80002f12:	64a2                	ld	s1,8(sp)
    80002f14:	6105                	addi	sp,sp,32
    80002f16:	8082                	ret
    panic("bwrite");
    80002f18:	00004517          	auipc	a0,0x4
    80002f1c:	4c050513          	addi	a0,a0,1216 # 800073d8 <etext+0x3d8>
    80002f20:	915fd0ef          	jal	80000834 <panic>

0000000080002f24 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f24:	1101                	addi	sp,sp,-32
    80002f26:	ec06                	sd	ra,24(sp)
    80002f28:	e822                	sd	s0,16(sp)
    80002f2a:	e426                	sd	s1,8(sp)
    80002f2c:	e04a                	sd	s2,0(sp)
    80002f2e:	1000                	addi	s0,sp,32
    80002f30:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002f32:	01050913          	addi	s2,a0,16
    80002f36:	854a                	mv	a0,s2
    80002f38:	39c010ef          	jal	800042d4 <holdingsleep>
    80002f3c:	c125                	beqz	a0,80002f9c <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002f3e:	854a                	mv	a0,s2
    80002f40:	35c010ef          	jal	8000429c <releasesleep>

  acquire(&bcache.lock);
    80002f44:	00015517          	auipc	a0,0x15
    80002f48:	61c50513          	addi	a0,a0,1564 # 80018560 <bcache>
    80002f4c:	cddfd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002f50:	40bc                	lw	a5,64(s1)
    80002f52:	37fd                	addiw	a5,a5,-1
    80002f54:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f56:	e79d                	bnez	a5,80002f84 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f58:	68b8                	ld	a4,80(s1)
    80002f5a:	64bc                	ld	a5,72(s1)
    80002f5c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002f5e:	68b8                	ld	a4,80(s1)
    80002f60:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f62:	0001d797          	auipc	a5,0x1d
    80002f66:	5fe78793          	addi	a5,a5,1534 # 80020560 <bcache+0x8000>
    80002f6a:	2b87b703          	ld	a4,696(a5)
    80002f6e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f70:	0001e717          	auipc	a4,0x1e
    80002f74:	85870713          	addi	a4,a4,-1960 # 800207c8 <bcache+0x8268>
    80002f78:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002f7a:	2b87b703          	ld	a4,696(a5)
    80002f7e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002f80:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002f84:	00015517          	auipc	a0,0x15
    80002f88:	5dc50513          	addi	a0,a0,1500 # 80018560 <bcache>
    80002f8c:	d25fd0ef          	jal	80000cb0 <release>
}
    80002f90:	60e2                	ld	ra,24(sp)
    80002f92:	6442                	ld	s0,16(sp)
    80002f94:	64a2                	ld	s1,8(sp)
    80002f96:	6902                	ld	s2,0(sp)
    80002f98:	6105                	addi	sp,sp,32
    80002f9a:	8082                	ret
    panic("brelse");
    80002f9c:	00004517          	auipc	a0,0x4
    80002fa0:	44450513          	addi	a0,a0,1092 # 800073e0 <etext+0x3e0>
    80002fa4:	891fd0ef          	jal	80000834 <panic>

0000000080002fa8 <bpin>:

void
bpin(struct buf *b)
{
    80002fa8:	1101                	addi	sp,sp,-32
    80002faa:	ec06                	sd	ra,24(sp)
    80002fac:	e822                	sd	s0,16(sp)
    80002fae:	e426                	sd	s1,8(sp)
    80002fb0:	1000                	addi	s0,sp,32
    80002fb2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fb4:	00015517          	auipc	a0,0x15
    80002fb8:	5ac50513          	addi	a0,a0,1452 # 80018560 <bcache>
    80002fbc:	c6dfd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002fc0:	40bc                	lw	a5,64(s1)
    80002fc2:	2785                	addiw	a5,a5,1
    80002fc4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fc6:	00015517          	auipc	a0,0x15
    80002fca:	59a50513          	addi	a0,a0,1434 # 80018560 <bcache>
    80002fce:	ce3fd0ef          	jal	80000cb0 <release>
}
    80002fd2:	60e2                	ld	ra,24(sp)
    80002fd4:	6442                	ld	s0,16(sp)
    80002fd6:	64a2                	ld	s1,8(sp)
    80002fd8:	6105                	addi	sp,sp,32
    80002fda:	8082                	ret

0000000080002fdc <bunpin>:

void
bunpin(struct buf *b)
{
    80002fdc:	1101                	addi	sp,sp,-32
    80002fde:	ec06                	sd	ra,24(sp)
    80002fe0:	e822                	sd	s0,16(sp)
    80002fe2:	e426                	sd	s1,8(sp)
    80002fe4:	1000                	addi	s0,sp,32
    80002fe6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fe8:	00015517          	auipc	a0,0x15
    80002fec:	57850513          	addi	a0,a0,1400 # 80018560 <bcache>
    80002ff0:	c39fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002ff4:	40bc                	lw	a5,64(s1)
    80002ff6:	37fd                	addiw	a5,a5,-1
    80002ff8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ffa:	00015517          	auipc	a0,0x15
    80002ffe:	56650513          	addi	a0,a0,1382 # 80018560 <bcache>
    80003002:	caffd0ef          	jal	80000cb0 <release>
}
    80003006:	60e2                	ld	ra,24(sp)
    80003008:	6442                	ld	s0,16(sp)
    8000300a:	64a2                	ld	s1,8(sp)
    8000300c:	6105                	addi	sp,sp,32
    8000300e:	8082                	ret

0000000080003010 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003010:	1101                	addi	sp,sp,-32
    80003012:	ec06                	sd	ra,24(sp)
    80003014:	e822                	sd	s0,16(sp)
    80003016:	e426                	sd	s1,8(sp)
    80003018:	e04a                	sd	s2,0(sp)
    8000301a:	1000                	addi	s0,sp,32
    8000301c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000301e:	00d5d79b          	srliw	a5,a1,0xd
    80003022:	0001e597          	auipc	a1,0x1e
    80003026:	c1a5a583          	lw	a1,-998(a1) # 80020c3c <sb+0x1c>
    8000302a:	9dbd                	addw	a1,a1,a5
    8000302c:	df1ff0ef          	jal	80002e1c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003030:	0074f713          	andi	a4,s1,7
    80003034:	4785                	li	a5,1
    80003036:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    8000303a:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    8000303c:	90d9                	srli	s1,s1,0x36
    8000303e:	00950733          	add	a4,a0,s1
    80003042:	05874703          	lbu	a4,88(a4)
    80003046:	00e7f6b3          	and	a3,a5,a4
    8000304a:	c29d                	beqz	a3,80003070 <bfree+0x60>
    8000304c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    8000304e:	94aa                	add	s1,s1,a0
    80003050:	fff7c793          	not	a5,a5
    80003054:	8f7d                	and	a4,a4,a5
    80003056:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000305a:	080010ef          	jal	800040da <log_write>
  brelse(bp);
    8000305e:	854a                	mv	a0,s2
    80003060:	ec5ff0ef          	jal	80002f24 <brelse>
}
    80003064:	60e2                	ld	ra,24(sp)
    80003066:	6442                	ld	s0,16(sp)
    80003068:	64a2                	ld	s1,8(sp)
    8000306a:	6902                	ld	s2,0(sp)
    8000306c:	6105                	addi	sp,sp,32
    8000306e:	8082                	ret
    panic("freeing free block");
    80003070:	00004517          	auipc	a0,0x4
    80003074:	37850513          	addi	a0,a0,888 # 800073e8 <etext+0x3e8>
    80003078:	fbcfd0ef          	jal	80000834 <panic>

000000008000307c <balloc>:
{
    8000307c:	715d                	addi	sp,sp,-80
    8000307e:	e486                	sd	ra,72(sp)
    80003080:	e0a2                	sd	s0,64(sp)
    80003082:	fc26                	sd	s1,56(sp)
    80003084:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80003086:	0001e797          	auipc	a5,0x1e
    8000308a:	b9e7a783          	lw	a5,-1122(a5) # 80020c24 <sb+0x4>
    8000308e:	0e078263          	beqz	a5,80003172 <balloc+0xf6>
    80003092:	f84a                	sd	s2,48(sp)
    80003094:	f44e                	sd	s3,40(sp)
    80003096:	f052                	sd	s4,32(sp)
    80003098:	ec56                	sd	s5,24(sp)
    8000309a:	e85a                	sd	s6,16(sp)
    8000309c:	e45e                	sd	s7,8(sp)
    8000309e:	e062                	sd	s8,0(sp)
    800030a0:	8baa                	mv	s7,a0
    800030a2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800030a4:	0001eb17          	auipc	s6,0x1e
    800030a8:	b7cb0b13          	addi	s6,s6,-1156 # 80020c20 <sb>
      m = 1 << (bi % 8);
    800030ac:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    800030ae:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    800030b0:	6c09                	lui	s8,0x2
    800030b2:	a09d                	j	80003118 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    800030b4:	97ca                	add	a5,a5,s2
    800030b6:	8e55                	or	a2,a2,a3
    800030b8:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800030bc:	854a                	mv	a0,s2
    800030be:	01c010ef          	jal	800040da <log_write>
        brelse(bp);
    800030c2:	854a                	mv	a0,s2
    800030c4:	e61ff0ef          	jal	80002f24 <brelse>
  bp = bread(dev, bno);
    800030c8:	85a6                	mv	a1,s1
    800030ca:	855e                	mv	a0,s7
    800030cc:	d51ff0ef          	jal	80002e1c <bread>
    800030d0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800030d2:	40000613          	li	a2,1024
    800030d6:	4581                	li	a1,0
    800030d8:	05850513          	addi	a0,a0,88
    800030dc:	c0dfd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    800030e0:	854a                	mv	a0,s2
    800030e2:	7f9000ef          	jal	800040da <log_write>
  brelse(bp);
    800030e6:	854a                	mv	a0,s2
    800030e8:	e3dff0ef          	jal	80002f24 <brelse>
}
    800030ec:	7942                	ld	s2,48(sp)
    800030ee:	79a2                	ld	s3,40(sp)
    800030f0:	7a02                	ld	s4,32(sp)
    800030f2:	6ae2                	ld	s5,24(sp)
    800030f4:	6b42                	ld	s6,16(sp)
    800030f6:	6ba2                	ld	s7,8(sp)
    800030f8:	6c02                	ld	s8,0(sp)
}
    800030fa:	8526                	mv	a0,s1
    800030fc:	60a6                	ld	ra,72(sp)
    800030fe:	6406                	ld	s0,64(sp)
    80003100:	74e2                	ld	s1,56(sp)
    80003102:	6161                	addi	sp,sp,80
    80003104:	8082                	ret
    brelse(bp);
    80003106:	854a                	mv	a0,s2
    80003108:	e1dff0ef          	jal	80002f24 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    8000310c:	015c0abb          	addw	s5,s8,s5
    80003110:	004b2783          	lw	a5,4(s6)
    80003114:	04faf863          	bgeu	s5,a5,80003164 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80003118:	40dad59b          	sraiw	a1,s5,0xd
    8000311c:	01cb2783          	lw	a5,28(s6)
    80003120:	9dbd                	addw	a1,a1,a5
    80003122:	855e                	mv	a0,s7
    80003124:	cf9ff0ef          	jal	80002e1c <bread>
    80003128:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    8000312a:	004b2503          	lw	a0,4(s6)
    8000312e:	84d6                	mv	s1,s5
    80003130:	4701                	li	a4,0
    80003132:	fca4fae3          	bgeu	s1,a0,80003106 <balloc+0x8a>
      m = 1 << (bi % 8);
    80003136:	00777693          	andi	a3,a4,7
    8000313a:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    8000313e:	41f7579b          	sraiw	a5,a4,0x1f
    80003142:	01d7d79b          	srliw	a5,a5,0x1d
    80003146:	9fb9                	addw	a5,a5,a4
    80003148:	4037d79b          	sraiw	a5,a5,0x3
    8000314c:	00f90633          	add	a2,s2,a5
    80003150:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003154:	00c6f5b3          	and	a1,a3,a2
    80003158:	ddb1                	beqz	a1,800030b4 <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    8000315a:	2705                	addiw	a4,a4,1
    8000315c:	2485                	addiw	s1,s1,1
    8000315e:	fd471ae3          	bne	a4,s4,80003132 <balloc+0xb6>
    80003162:	b755                	j	80003106 <balloc+0x8a>
    80003164:	7942                	ld	s2,48(sp)
    80003166:	79a2                	ld	s3,40(sp)
    80003168:	7a02                	ld	s4,32(sp)
    8000316a:	6ae2                	ld	s5,24(sp)
    8000316c:	6b42                	ld	s6,16(sp)
    8000316e:	6ba2                	ld	s7,8(sp)
    80003170:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    80003172:	00004517          	auipc	a0,0x4
    80003176:	28e50513          	addi	a0,a0,654 # 80007400 <etext+0x400>
    8000317a:	b90fd0ef          	jal	8000050a <printk>
  return 0;
    8000317e:	4481                	li	s1,0
    80003180:	bfad                	j	800030fa <balloc+0x7e>

0000000080003182 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003182:	7179                	addi	sp,sp,-48
    80003184:	f406                	sd	ra,40(sp)
    80003186:	f022                	sd	s0,32(sp)
    80003188:	ec26                	sd	s1,24(sp)
    8000318a:	e84a                	sd	s2,16(sp)
    8000318c:	e44e                	sd	s3,8(sp)
    8000318e:	1800                	addi	s0,sp,48
    80003190:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80003192:	47ad                	li	a5,11
    80003194:	02b7e363          	bltu	a5,a1,800031ba <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80003198:	02059793          	slli	a5,a1,0x20
    8000319c:	01e7d593          	srli	a1,a5,0x1e
    800031a0:	00b509b3          	add	s3,a0,a1
    800031a4:	0509a483          	lw	s1,80(s3)
    800031a8:	e0b5                	bnez	s1,8000320c <bmap+0x8a>
      addr = balloc(ip->dev);
    800031aa:	4108                	lw	a0,0(a0)
    800031ac:	ed1ff0ef          	jal	8000307c <balloc>
    800031b0:	84aa                	mv	s1,a0
      if (addr == 0)
    800031b2:	cd29                	beqz	a0,8000320c <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    800031b4:	04a9a823          	sw	a0,80(s3)
    800031b8:	a891                	j	8000320c <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800031ba:	ff45879b          	addiw	a5,a1,-12
    800031be:	873e                	mv	a4,a5
    800031c0:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    800031c2:	0ff00793          	li	a5,255
    800031c6:	06e7e763          	bltu	a5,a4,80003234 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    800031ca:	08052483          	lw	s1,128(a0)
    800031ce:	e891                	bnez	s1,800031e2 <bmap+0x60>
      addr = balloc(ip->dev);
    800031d0:	4108                	lw	a0,0(a0)
    800031d2:	eabff0ef          	jal	8000307c <balloc>
    800031d6:	84aa                	mv	s1,a0
      if (addr == 0)
    800031d8:	c915                	beqz	a0,8000320c <bmap+0x8a>
    800031da:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800031dc:	08a92023          	sw	a0,128(s2)
    800031e0:	a011                	j	800031e4 <bmap+0x62>
    800031e2:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800031e4:	85a6                	mv	a1,s1
    800031e6:	00092503          	lw	a0,0(s2)
    800031ea:	c33ff0ef          	jal	80002e1c <bread>
    800031ee:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    800031f0:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    800031f4:	02099713          	slli	a4,s3,0x20
    800031f8:	01e75593          	srli	a1,a4,0x1e
    800031fc:	97ae                	add	a5,a5,a1
    800031fe:	89be                	mv	s3,a5
    80003200:	4384                	lw	s1,0(a5)
    80003202:	cc89                	beqz	s1,8000321c <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003204:	8552                	mv	a0,s4
    80003206:	d1fff0ef          	jal	80002f24 <brelse>
    return addr;
    8000320a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000320c:	8526                	mv	a0,s1
    8000320e:	70a2                	ld	ra,40(sp)
    80003210:	7402                	ld	s0,32(sp)
    80003212:	64e2                	ld	s1,24(sp)
    80003214:	6942                	ld	s2,16(sp)
    80003216:	69a2                	ld	s3,8(sp)
    80003218:	6145                	addi	sp,sp,48
    8000321a:	8082                	ret
      addr = balloc(ip->dev);
    8000321c:	00092503          	lw	a0,0(s2)
    80003220:	e5dff0ef          	jal	8000307c <balloc>
    80003224:	84aa                	mv	s1,a0
      if (addr) {
    80003226:	dd79                	beqz	a0,80003204 <bmap+0x82>
        a[bn] = addr;
    80003228:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    8000322c:	8552                	mv	a0,s4
    8000322e:	6ad000ef          	jal	800040da <log_write>
    80003232:	bfc9                	j	80003204 <bmap+0x82>
    80003234:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003236:	00004517          	auipc	a0,0x4
    8000323a:	1e250513          	addi	a0,a0,482 # 80007418 <etext+0x418>
    8000323e:	df6fd0ef          	jal	80000834 <panic>

0000000080003242 <iget>:
{
    80003242:	7179                	addi	sp,sp,-48
    80003244:	f406                	sd	ra,40(sp)
    80003246:	f022                	sd	s0,32(sp)
    80003248:	ec26                	sd	s1,24(sp)
    8000324a:	e84a                	sd	s2,16(sp)
    8000324c:	e44e                	sd	s3,8(sp)
    8000324e:	e052                	sd	s4,0(sp)
    80003250:	1800                	addi	s0,sp,48
    80003252:	892a                	mv	s2,a0
    80003254:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003256:	0001e517          	auipc	a0,0x1e
    8000325a:	9ea50513          	addi	a0,a0,-1558 # 80020c40 <itable>
    8000325e:	9cbfd0ef          	jal	80000c28 <acquire>
  empty = 0;
    80003262:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003264:	0001e497          	auipc	s1,0x1e
    80003268:	9f448493          	addi	s1,s1,-1548 # 80020c58 <itable+0x18>
    8000326c:	0001f697          	auipc	a3,0x1f
    80003270:	47c68693          	addi	a3,a3,1148 # 800226e8 <log>
    80003274:	a809                	j	80003286 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003276:	e781                	bnez	a5,8000327e <iget+0x3c>
    80003278:	00099363          	bnez	s3,8000327e <iget+0x3c>
      empty = ip;
    8000327c:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000327e:	08848493          	addi	s1,s1,136
    80003282:	02d48563          	beq	s1,a3,800032ac <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80003286:	449c                	lw	a5,8(s1)
    80003288:	fef057e3          	blez	a5,80003276 <iget+0x34>
    8000328c:	4098                	lw	a4,0(s1)
    8000328e:	ff2718e3          	bne	a4,s2,8000327e <iget+0x3c>
    80003292:	40d8                	lw	a4,4(s1)
    80003294:	ff4715e3          	bne	a4,s4,8000327e <iget+0x3c>
      ip->ref++;
    80003298:	2785                	addiw	a5,a5,1
    8000329a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000329c:	0001e517          	auipc	a0,0x1e
    800032a0:	9a450513          	addi	a0,a0,-1628 # 80020c40 <itable>
    800032a4:	a0dfd0ef          	jal	80000cb0 <release>
      return ip;
    800032a8:	89a6                	mv	s3,s1
    800032aa:	a015                	j	800032ce <iget+0x8c>
  if (empty == 0)
    800032ac:	02098a63          	beqz	s3,800032e0 <iget+0x9e>
  ip->dev = dev;
    800032b0:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800032b4:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800032b8:	4785                	li	a5,1
    800032ba:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800032be:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800032c2:	0001e517          	auipc	a0,0x1e
    800032c6:	97e50513          	addi	a0,a0,-1666 # 80020c40 <itable>
    800032ca:	9e7fd0ef          	jal	80000cb0 <release>
}
    800032ce:	854e                	mv	a0,s3
    800032d0:	70a2                	ld	ra,40(sp)
    800032d2:	7402                	ld	s0,32(sp)
    800032d4:	64e2                	ld	s1,24(sp)
    800032d6:	6942                	ld	s2,16(sp)
    800032d8:	69a2                	ld	s3,8(sp)
    800032da:	6a02                	ld	s4,0(sp)
    800032dc:	6145                	addi	sp,sp,48
    800032de:	8082                	ret
    panic("iget: no inodes");
    800032e0:	00004517          	auipc	a0,0x4
    800032e4:	15050513          	addi	a0,a0,336 # 80007430 <etext+0x430>
    800032e8:	d4cfd0ef          	jal	80000834 <panic>

00000000800032ec <iinit>:
{
    800032ec:	7179                	addi	sp,sp,-48
    800032ee:	f406                	sd	ra,40(sp)
    800032f0:	f022                	sd	s0,32(sp)
    800032f2:	ec26                	sd	s1,24(sp)
    800032f4:	e84a                	sd	s2,16(sp)
    800032f6:	e44e                	sd	s3,8(sp)
    800032f8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800032fa:	00004597          	auipc	a1,0x4
    800032fe:	14658593          	addi	a1,a1,326 # 80007440 <etext+0x440>
    80003302:	0001e517          	auipc	a0,0x1e
    80003306:	93e50513          	addi	a0,a0,-1730 # 80020c40 <itable>
    8000330a:	89ffd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    8000330e:	0001e497          	auipc	s1,0x1e
    80003312:	95a48493          	addi	s1,s1,-1702 # 80020c68 <itable+0x28>
    80003316:	0001f997          	auipc	s3,0x1f
    8000331a:	3e298993          	addi	s3,s3,994 # 800226f8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000331e:	00004917          	auipc	s2,0x4
    80003322:	12a90913          	addi	s2,s2,298 # 80007448 <etext+0x448>
    80003326:	85ca                	mv	a1,s2
    80003328:	8526                	mv	a0,s1
    8000332a:	6e9000ef          	jal	80004212 <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    8000332e:	08848493          	addi	s1,s1,136
    80003332:	ff349ae3          	bne	s1,s3,80003326 <iinit+0x3a>
}
    80003336:	70a2                	ld	ra,40(sp)
    80003338:	7402                	ld	s0,32(sp)
    8000333a:	64e2                	ld	s1,24(sp)
    8000333c:	6942                	ld	s2,16(sp)
    8000333e:	69a2                	ld	s3,8(sp)
    80003340:	6145                	addi	sp,sp,48
    80003342:	8082                	ret

0000000080003344 <ialloc>:
{
    80003344:	7139                	addi	sp,sp,-64
    80003346:	fc06                	sd	ra,56(sp)
    80003348:	f822                	sd	s0,48(sp)
    8000334a:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000334c:	0001e717          	auipc	a4,0x1e
    80003350:	8e072703          	lw	a4,-1824(a4) # 80020c2c <sb+0xc>
    80003354:	4785                	li	a5,1
    80003356:	06e7f063          	bgeu	a5,a4,800033b6 <ialloc+0x72>
    8000335a:	f426                	sd	s1,40(sp)
    8000335c:	f04a                	sd	s2,32(sp)
    8000335e:	ec4e                	sd	s3,24(sp)
    80003360:	e852                	sd	s4,16(sp)
    80003362:	e456                	sd	s5,8(sp)
    80003364:	e05a                	sd	s6,0(sp)
    80003366:	8aaa                	mv	s5,a0
    80003368:	8b2e                	mv	s6,a1
    8000336a:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    8000336c:	0001ea17          	auipc	s4,0x1e
    80003370:	8b4a0a13          	addi	s4,s4,-1868 # 80020c20 <sb>
    80003374:	00495593          	srli	a1,s2,0x4
    80003378:	018a2783          	lw	a5,24(s4)
    8000337c:	9dbd                	addw	a1,a1,a5
    8000337e:	8556                	mv	a0,s5
    80003380:	a9dff0ef          	jal	80002e1c <bread>
    80003384:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003386:	05850993          	addi	s3,a0,88
    8000338a:	00f97793          	andi	a5,s2,15
    8000338e:	079a                	slli	a5,a5,0x6
    80003390:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    80003392:	00099783          	lh	a5,0(s3)
    80003396:	cb9d                	beqz	a5,800033cc <ialloc+0x88>
    brelse(bp);
    80003398:	b8dff0ef          	jal	80002f24 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000339c:	0905                	addi	s2,s2,1
    8000339e:	00ca2703          	lw	a4,12(s4)
    800033a2:	0009079b          	sext.w	a5,s2
    800033a6:	fce7e7e3          	bltu	a5,a4,80003374 <ialloc+0x30>
    800033aa:	74a2                	ld	s1,40(sp)
    800033ac:	7902                	ld	s2,32(sp)
    800033ae:	69e2                	ld	s3,24(sp)
    800033b0:	6a42                	ld	s4,16(sp)
    800033b2:	6aa2                	ld	s5,8(sp)
    800033b4:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800033b6:	00004517          	auipc	a0,0x4
    800033ba:	09a50513          	addi	a0,a0,154 # 80007450 <etext+0x450>
    800033be:	94cfd0ef          	jal	8000050a <printk>
  return 0;
    800033c2:	4501                	li	a0,0
}
    800033c4:	70e2                	ld	ra,56(sp)
    800033c6:	7442                	ld	s0,48(sp)
    800033c8:	6121                	addi	sp,sp,64
    800033ca:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800033cc:	04000613          	li	a2,64
    800033d0:	4581                	li	a1,0
    800033d2:	854e                	mv	a0,s3
    800033d4:	915fd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    800033d8:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800033dc:	8526                	mv	a0,s1
    800033de:	4fd000ef          	jal	800040da <log_write>
      brelse(bp);
    800033e2:	8526                	mv	a0,s1
    800033e4:	b41ff0ef          	jal	80002f24 <brelse>
      return iget(dev, inum);
    800033e8:	0009059b          	sext.w	a1,s2
    800033ec:	8556                	mv	a0,s5
    800033ee:	e55ff0ef          	jal	80003242 <iget>
    800033f2:	74a2                	ld	s1,40(sp)
    800033f4:	7902                	ld	s2,32(sp)
    800033f6:	69e2                	ld	s3,24(sp)
    800033f8:	6a42                	ld	s4,16(sp)
    800033fa:	6aa2                	ld	s5,8(sp)
    800033fc:	6b02                	ld	s6,0(sp)
    800033fe:	b7d9                	j	800033c4 <ialloc+0x80>

0000000080003400 <iupdate>:
{
    80003400:	1101                	addi	sp,sp,-32
    80003402:	ec06                	sd	ra,24(sp)
    80003404:	e822                	sd	s0,16(sp)
    80003406:	e426                	sd	s1,8(sp)
    80003408:	e04a                	sd	s2,0(sp)
    8000340a:	1000                	addi	s0,sp,32
    8000340c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000340e:	415c                	lw	a5,4(a0)
    80003410:	0047d79b          	srliw	a5,a5,0x4
    80003414:	0001e597          	auipc	a1,0x1e
    80003418:	8245a583          	lw	a1,-2012(a1) # 80020c38 <sb+0x18>
    8000341c:	9dbd                	addw	a1,a1,a5
    8000341e:	4108                	lw	a0,0(a0)
    80003420:	9fdff0ef          	jal	80002e1c <bread>
    80003424:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003426:	05850793          	addi	a5,a0,88
    8000342a:	40d8                	lw	a4,4(s1)
    8000342c:	8b3d                	andi	a4,a4,15
    8000342e:	071a                	slli	a4,a4,0x6
    80003430:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003432:	04449703          	lh	a4,68(s1)
    80003436:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000343a:	04649703          	lh	a4,70(s1)
    8000343e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003442:	04849703          	lh	a4,72(s1)
    80003446:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000344a:	04a49703          	lh	a4,74(s1)
    8000344e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003452:	44f8                	lw	a4,76(s1)
    80003454:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003456:	03400613          	li	a2,52
    8000345a:	05048593          	addi	a1,s1,80
    8000345e:	00c78513          	addi	a0,a5,12
    80003462:	8e7fd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    80003466:	854a                	mv	a0,s2
    80003468:	473000ef          	jal	800040da <log_write>
  brelse(bp);
    8000346c:	854a                	mv	a0,s2
    8000346e:	ab7ff0ef          	jal	80002f24 <brelse>
}
    80003472:	60e2                	ld	ra,24(sp)
    80003474:	6442                	ld	s0,16(sp)
    80003476:	64a2                	ld	s1,8(sp)
    80003478:	6902                	ld	s2,0(sp)
    8000347a:	6105                	addi	sp,sp,32
    8000347c:	8082                	ret

000000008000347e <idup>:
{
    8000347e:	1101                	addi	sp,sp,-32
    80003480:	ec06                	sd	ra,24(sp)
    80003482:	e822                	sd	s0,16(sp)
    80003484:	e426                	sd	s1,8(sp)
    80003486:	1000                	addi	s0,sp,32
    80003488:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000348a:	0001d517          	auipc	a0,0x1d
    8000348e:	7b650513          	addi	a0,a0,1974 # 80020c40 <itable>
    80003492:	f96fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003496:	449c                	lw	a5,8(s1)
    80003498:	2785                	addiw	a5,a5,1
    8000349a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000349c:	0001d517          	auipc	a0,0x1d
    800034a0:	7a450513          	addi	a0,a0,1956 # 80020c40 <itable>
    800034a4:	80dfd0ef          	jal	80000cb0 <release>
}
    800034a8:	8526                	mv	a0,s1
    800034aa:	60e2                	ld	ra,24(sp)
    800034ac:	6442                	ld	s0,16(sp)
    800034ae:	64a2                	ld	s1,8(sp)
    800034b0:	6105                	addi	sp,sp,32
    800034b2:	8082                	ret

00000000800034b4 <ilock>:
{
    800034b4:	1101                	addi	sp,sp,-32
    800034b6:	ec06                	sd	ra,24(sp)
    800034b8:	e822                	sd	s0,16(sp)
    800034ba:	e426                	sd	s1,8(sp)
    800034bc:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800034be:	cd19                	beqz	a0,800034dc <ilock+0x28>
    800034c0:	84aa                	mv	s1,a0
    800034c2:	451c                	lw	a5,8(a0)
    800034c4:	00f05c63          	blez	a5,800034dc <ilock+0x28>
  acquiresleep(&ip->lock);
    800034c8:	0541                	addi	a0,a0,16
    800034ca:	57f000ef          	jal	80004248 <acquiresleep>
  if (ip->valid == 0) {
    800034ce:	40bc                	lw	a5,64(s1)
    800034d0:	cf89                	beqz	a5,800034ea <ilock+0x36>
}
    800034d2:	60e2                	ld	ra,24(sp)
    800034d4:	6442                	ld	s0,16(sp)
    800034d6:	64a2                	ld	s1,8(sp)
    800034d8:	6105                	addi	sp,sp,32
    800034da:	8082                	ret
    800034dc:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800034de:	00004517          	auipc	a0,0x4
    800034e2:	f8a50513          	addi	a0,a0,-118 # 80007468 <etext+0x468>
    800034e6:	b4efd0ef          	jal	80000834 <panic>
    800034ea:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800034ec:	40dc                	lw	a5,4(s1)
    800034ee:	0047d79b          	srliw	a5,a5,0x4
    800034f2:	0001d597          	auipc	a1,0x1d
    800034f6:	7465a583          	lw	a1,1862(a1) # 80020c38 <sb+0x18>
    800034fa:	9dbd                	addw	a1,a1,a5
    800034fc:	4088                	lw	a0,0(s1)
    800034fe:	91fff0ef          	jal	80002e1c <bread>
    80003502:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003504:	05850593          	addi	a1,a0,88
    80003508:	40dc                	lw	a5,4(s1)
    8000350a:	8bbd                	andi	a5,a5,15
    8000350c:	079a                	slli	a5,a5,0x6
    8000350e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003510:	00059783          	lh	a5,0(a1)
    80003514:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003518:	00259783          	lh	a5,2(a1)
    8000351c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003520:	00459783          	lh	a5,4(a1)
    80003524:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003528:	00659783          	lh	a5,6(a1)
    8000352c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003530:	459c                	lw	a5,8(a1)
    80003532:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003534:	03400613          	li	a2,52
    80003538:	05b1                	addi	a1,a1,12
    8000353a:	05048513          	addi	a0,s1,80
    8000353e:	80bfd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    80003542:	854a                	mv	a0,s2
    80003544:	9e1ff0ef          	jal	80002f24 <brelse>
    ip->valid = 1;
    80003548:	4785                	li	a5,1
    8000354a:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    8000354c:	04449783          	lh	a5,68(s1)
    80003550:	c399                	beqz	a5,80003556 <ilock+0xa2>
    80003552:	6902                	ld	s2,0(sp)
    80003554:	bfbd                	j	800034d2 <ilock+0x1e>
      panic("ilock: no type");
    80003556:	00004517          	auipc	a0,0x4
    8000355a:	f1a50513          	addi	a0,a0,-230 # 80007470 <etext+0x470>
    8000355e:	ad6fd0ef          	jal	80000834 <panic>

0000000080003562 <iunlock>:
{
    80003562:	1101                	addi	sp,sp,-32
    80003564:	ec06                	sd	ra,24(sp)
    80003566:	e822                	sd	s0,16(sp)
    80003568:	e426                	sd	s1,8(sp)
    8000356a:	e04a                	sd	s2,0(sp)
    8000356c:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000356e:	c505                	beqz	a0,80003596 <iunlock+0x34>
    80003570:	84aa                	mv	s1,a0
    80003572:	01050913          	addi	s2,a0,16
    80003576:	854a                	mv	a0,s2
    80003578:	55d000ef          	jal	800042d4 <holdingsleep>
    8000357c:	cd09                	beqz	a0,80003596 <iunlock+0x34>
    8000357e:	449c                	lw	a5,8(s1)
    80003580:	00f05b63          	blez	a5,80003596 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003584:	854a                	mv	a0,s2
    80003586:	517000ef          	jal	8000429c <releasesleep>
}
    8000358a:	60e2                	ld	ra,24(sp)
    8000358c:	6442                	ld	s0,16(sp)
    8000358e:	64a2                	ld	s1,8(sp)
    80003590:	6902                	ld	s2,0(sp)
    80003592:	6105                	addi	sp,sp,32
    80003594:	8082                	ret
    panic("iunlock");
    80003596:	00004517          	auipc	a0,0x4
    8000359a:	eea50513          	addi	a0,a0,-278 # 80007480 <etext+0x480>
    8000359e:	a96fd0ef          	jal	80000834 <panic>

00000000800035a2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800035a2:	7179                	addi	sp,sp,-48
    800035a4:	f406                	sd	ra,40(sp)
    800035a6:	f022                	sd	s0,32(sp)
    800035a8:	ec26                	sd	s1,24(sp)
    800035aa:	e84a                	sd	s2,16(sp)
    800035ac:	e44e                	sd	s3,8(sp)
    800035ae:	1800                	addi	s0,sp,48
    800035b0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800035b2:	05050493          	addi	s1,a0,80
    800035b6:	08050913          	addi	s2,a0,128
    800035ba:	a021                	j	800035c2 <itrunc+0x20>
    800035bc:	0491                	addi	s1,s1,4
    800035be:	01248b63          	beq	s1,s2,800035d4 <itrunc+0x32>
    if (ip->addrs[i]) {
    800035c2:	408c                	lw	a1,0(s1)
    800035c4:	dde5                	beqz	a1,800035bc <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800035c6:	0009a503          	lw	a0,0(s3)
    800035ca:	a47ff0ef          	jal	80003010 <bfree>
      ip->addrs[i] = 0;
    800035ce:	0004a023          	sw	zero,0(s1)
    800035d2:	b7ed                	j	800035bc <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800035d4:	0809a583          	lw	a1,128(s3)
    800035d8:	ed89                	bnez	a1,800035f2 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800035da:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800035de:	854e                	mv	a0,s3
    800035e0:	e21ff0ef          	jal	80003400 <iupdate>
}
    800035e4:	70a2                	ld	ra,40(sp)
    800035e6:	7402                	ld	s0,32(sp)
    800035e8:	64e2                	ld	s1,24(sp)
    800035ea:	6942                	ld	s2,16(sp)
    800035ec:	69a2                	ld	s3,8(sp)
    800035ee:	6145                	addi	sp,sp,48
    800035f0:	8082                	ret
    800035f2:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800035f4:	0009a503          	lw	a0,0(s3)
    800035f8:	825ff0ef          	jal	80002e1c <bread>
    800035fc:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    800035fe:	05850493          	addi	s1,a0,88
    80003602:	45850913          	addi	s2,a0,1112
    80003606:	a021                	j	8000360e <itrunc+0x6c>
    80003608:	0491                	addi	s1,s1,4
    8000360a:	01248963          	beq	s1,s2,8000361c <itrunc+0x7a>
      if (a[j])
    8000360e:	408c                	lw	a1,0(s1)
    80003610:	dde5                	beqz	a1,80003608 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003612:	0009a503          	lw	a0,0(s3)
    80003616:	9fbff0ef          	jal	80003010 <bfree>
    8000361a:	b7fd                	j	80003608 <itrunc+0x66>
    brelse(bp);
    8000361c:	8552                	mv	a0,s4
    8000361e:	907ff0ef          	jal	80002f24 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003622:	0809a583          	lw	a1,128(s3)
    80003626:	0009a503          	lw	a0,0(s3)
    8000362a:	9e7ff0ef          	jal	80003010 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000362e:	0809a023          	sw	zero,128(s3)
    80003632:	6a02                	ld	s4,0(sp)
    80003634:	b75d                	j	800035da <itrunc+0x38>

0000000080003636 <iput>:
{
    80003636:	7179                	addi	sp,sp,-48
    80003638:	f406                	sd	ra,40(sp)
    8000363a:	f022                	sd	s0,32(sp)
    8000363c:	ec26                	sd	s1,24(sp)
    8000363e:	1800                	addi	s0,sp,48
    80003640:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003642:	0001d517          	auipc	a0,0x1d
    80003646:	5fe50513          	addi	a0,a0,1534 # 80020c40 <itable>
    8000364a:	ddefd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    8000364e:	449c                	lw	a5,8(s1)
    80003650:	4705                	li	a4,1
    80003652:	00e78f63          	beq	a5,a4,80003670 <iput+0x3a>
  ip->ref--;
    80003656:	37fd                	addiw	a5,a5,-1
    80003658:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000365a:	0001d517          	auipc	a0,0x1d
    8000365e:	5e650513          	addi	a0,a0,1510 # 80020c40 <itable>
    80003662:	e4efd0ef          	jal	80000cb0 <release>
}
    80003666:	70a2                	ld	ra,40(sp)
    80003668:	7402                	ld	s0,32(sp)
    8000366a:	64e2                	ld	s1,24(sp)
    8000366c:	6145                	addi	sp,sp,48
    8000366e:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003670:	40b8                	lw	a4,64(s1)
    80003672:	d375                	beqz	a4,80003656 <iput+0x20>
    80003674:	e84a                	sd	s2,16(sp)
    80003676:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    80003678:	0004aa03          	lw	s4,0(s1)
    8000367c:	0044a903          	lw	s2,4(s1)
  if (last) {
    80003680:	04a49703          	lh	a4,74(s1)
    80003684:	ef3d                	bnez	a4,80003702 <iput+0xcc>
    80003686:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    80003688:	01048793          	addi	a5,s1,16
    8000368c:	89be                	mv	s3,a5
    8000368e:	853e                	mv	a0,a5
    80003690:	3b9000ef          	jal	80004248 <acquiresleep>
    release(&itable.lock);
    80003694:	0001d517          	auipc	a0,0x1d
    80003698:	5ac50513          	addi	a0,a0,1452 # 80020c40 <itable>
    8000369c:	e14fd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    800036a0:	8526                	mv	a0,s1
    800036a2:	f01ff0ef          	jal	800035a2 <itrunc>
    ip->valid = 0;
    800036a6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800036aa:	854e                	mv	a0,s3
    800036ac:	3f1000ef          	jal	8000429c <releasesleep>
    acquire(&itable.lock);
    800036b0:	0001d517          	auipc	a0,0x1d
    800036b4:	59050513          	addi	a0,a0,1424 # 80020c40 <itable>
    800036b8:	d70fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    800036bc:	449c                	lw	a5,8(s1)
    800036be:	37fd                	addiw	a5,a5,-1
    800036c0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036c2:	0001d517          	auipc	a0,0x1d
    800036c6:	57e50513          	addi	a0,a0,1406 # 80020c40 <itable>
    800036ca:	de6fd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036ce:	0049579b          	srliw	a5,s2,0x4
    800036d2:	0001d597          	auipc	a1,0x1d
    800036d6:	5665a583          	lw	a1,1382(a1) # 80020c38 <sb+0x18>
    800036da:	9dbd                	addw	a1,a1,a5
    800036dc:	8552                	mv	a0,s4
    800036de:	f3eff0ef          	jal	80002e1c <bread>
    800036e2:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800036e4:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    800036e8:	079a                	slli	a5,a5,0x6
    800036ea:	97aa                	add	a5,a5,a0
    800036ec:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    800036f0:	1eb000ef          	jal	800040da <log_write>
  brelse(bp);
    800036f4:	8526                	mv	a0,s1
    800036f6:	82fff0ef          	jal	80002f24 <brelse>
}
    800036fa:	6942                	ld	s2,16(sp)
    800036fc:	69a2                	ld	s3,8(sp)
    800036fe:	6a02                	ld	s4,0(sp)
    80003700:	b79d                	j	80003666 <iput+0x30>
    80003702:	6942                	ld	s2,16(sp)
    80003704:	6a02                	ld	s4,0(sp)
    80003706:	bf81                	j	80003656 <iput+0x20>

0000000080003708 <iunlockput>:
{
    80003708:	1101                	addi	sp,sp,-32
    8000370a:	ec06                	sd	ra,24(sp)
    8000370c:	e822                	sd	s0,16(sp)
    8000370e:	e426                	sd	s1,8(sp)
    80003710:	1000                	addi	s0,sp,32
    80003712:	84aa                	mv	s1,a0
  iunlock(ip);
    80003714:	e4fff0ef          	jal	80003562 <iunlock>
  iput(ip);
    80003718:	8526                	mv	a0,s1
    8000371a:	f1dff0ef          	jal	80003636 <iput>
}
    8000371e:	60e2                	ld	ra,24(sp)
    80003720:	6442                	ld	s0,16(sp)
    80003722:	64a2                	ld	s1,8(sp)
    80003724:	6105                	addi	sp,sp,32
    80003726:	8082                	ret

0000000080003728 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003728:	0001d717          	auipc	a4,0x1d
    8000372c:	50472703          	lw	a4,1284(a4) # 80020c2c <sb+0xc>
    80003730:	4785                	li	a5,1
    80003732:	0ae7fe63          	bgeu	a5,a4,800037ee <ireclaim+0xc6>
{
    80003736:	7139                	addi	sp,sp,-64
    80003738:	fc06                	sd	ra,56(sp)
    8000373a:	f822                	sd	s0,48(sp)
    8000373c:	f426                	sd	s1,40(sp)
    8000373e:	f04a                	sd	s2,32(sp)
    80003740:	ec4e                	sd	s3,24(sp)
    80003742:	e852                	sd	s4,16(sp)
    80003744:	e456                	sd	s5,8(sp)
    80003746:	e05a                	sd	s6,0(sp)
    80003748:	0080                	addi	s0,sp,64
    8000374a:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000374c:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000374e:	0001da17          	auipc	s4,0x1d
    80003752:	4d2a0a13          	addi	s4,s4,1234 # 80020c20 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    80003756:	00004b17          	auipc	s6,0x4
    8000375a:	d32b0b13          	addi	s6,s6,-718 # 80007488 <etext+0x488>
    8000375e:	a099                	j	800037a4 <ireclaim+0x7c>
    80003760:	85ce                	mv	a1,s3
    80003762:	855a                	mv	a0,s6
    80003764:	da7fc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    80003768:	85ce                	mv	a1,s3
    8000376a:	8556                	mv	a0,s5
    8000376c:	ad7ff0ef          	jal	80003242 <iget>
    80003770:	89aa                	mv	s3,a0
    brelse(bp);
    80003772:	854a                	mv	a0,s2
    80003774:	fb0ff0ef          	jal	80002f24 <brelse>
    if (ip) {
    80003778:	00098f63          	beqz	s3,80003796 <ireclaim+0x6e>
      begin_op();
    8000377c:	7b0000ef          	jal	80003f2c <begin_op>
      ilock(ip);
    80003780:	854e                	mv	a0,s3
    80003782:	d33ff0ef          	jal	800034b4 <ilock>
      iunlock(ip);
    80003786:	854e                	mv	a0,s3
    80003788:	ddbff0ef          	jal	80003562 <iunlock>
      iput(ip);
    8000378c:	854e                	mv	a0,s3
    8000378e:	ea9ff0ef          	jal	80003636 <iput>
      end_op();
    80003792:	027000ef          	jal	80003fb8 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003796:	0485                	addi	s1,s1,1
    80003798:	00ca2703          	lw	a4,12(s4)
    8000379c:	0004879b          	sext.w	a5,s1
    800037a0:	02e7fd63          	bgeu	a5,a4,800037da <ireclaim+0xb2>
    800037a4:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800037a8:	0044d593          	srli	a1,s1,0x4
    800037ac:	018a2783          	lw	a5,24(s4)
    800037b0:	9dbd                	addw	a1,a1,a5
    800037b2:	8556                	mv	a0,s5
    800037b4:	e68ff0ef          	jal	80002e1c <bread>
    800037b8:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800037ba:	05850793          	addi	a5,a0,88
    800037be:	00f9f713          	andi	a4,s3,15
    800037c2:	071a                	slli	a4,a4,0x6
    800037c4:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    800037c6:	00079703          	lh	a4,0(a5)
    800037ca:	c701                	beqz	a4,800037d2 <ireclaim+0xaa>
    800037cc:	00679783          	lh	a5,6(a5)
    800037d0:	dbc1                	beqz	a5,80003760 <ireclaim+0x38>
    brelse(bp);
    800037d2:	854a                	mv	a0,s2
    800037d4:	f50ff0ef          	jal	80002f24 <brelse>
    if (ip) {
    800037d8:	bf7d                	j	80003796 <ireclaim+0x6e>
}
    800037da:	70e2                	ld	ra,56(sp)
    800037dc:	7442                	ld	s0,48(sp)
    800037de:	74a2                	ld	s1,40(sp)
    800037e0:	7902                	ld	s2,32(sp)
    800037e2:	69e2                	ld	s3,24(sp)
    800037e4:	6a42                	ld	s4,16(sp)
    800037e6:	6aa2                	ld	s5,8(sp)
    800037e8:	6b02                	ld	s6,0(sp)
    800037ea:	6121                	addi	sp,sp,64
    800037ec:	8082                	ret
    800037ee:	8082                	ret

00000000800037f0 <fsinit>:
{
    800037f0:	1101                	addi	sp,sp,-32
    800037f2:	ec06                	sd	ra,24(sp)
    800037f4:	e822                	sd	s0,16(sp)
    800037f6:	e426                	sd	s1,8(sp)
    800037f8:	e04a                	sd	s2,0(sp)
    800037fa:	1000                	addi	s0,sp,32
    800037fc:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800037fe:	4585                	li	a1,1
    80003800:	e1cff0ef          	jal	80002e1c <bread>
    80003804:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003806:	02000613          	li	a2,32
    8000380a:	05850593          	addi	a1,a0,88
    8000380e:	0001d517          	auipc	a0,0x1d
    80003812:	41250513          	addi	a0,a0,1042 # 80020c20 <sb>
    80003816:	d32fd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    8000381a:	8526                	mv	a0,s1
    8000381c:	f08ff0ef          	jal	80002f24 <brelse>
  if (sb.magic != FSMAGIC)
    80003820:	0001d717          	auipc	a4,0x1d
    80003824:	40072703          	lw	a4,1024(a4) # 80020c20 <sb>
    80003828:	102037b7          	lui	a5,0x10203
    8000382c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003830:	02f71263          	bne	a4,a5,80003854 <fsinit+0x64>
  initlog(dev, &sb);
    80003834:	0001d597          	auipc	a1,0x1d
    80003838:	3ec58593          	addi	a1,a1,1004 # 80020c20 <sb>
    8000383c:	854a                	mv	a0,s2
    8000383e:	66c000ef          	jal	80003eaa <initlog>
  ireclaim(dev);
    80003842:	854a                	mv	a0,s2
    80003844:	ee5ff0ef          	jal	80003728 <ireclaim>
}
    80003848:	60e2                	ld	ra,24(sp)
    8000384a:	6442                	ld	s0,16(sp)
    8000384c:	64a2                	ld	s1,8(sp)
    8000384e:	6902                	ld	s2,0(sp)
    80003850:	6105                	addi	sp,sp,32
    80003852:	8082                	ret
    panic("invalid file system");
    80003854:	00004517          	auipc	a0,0x4
    80003858:	c5450513          	addi	a0,a0,-940 # 800074a8 <etext+0x4a8>
    8000385c:	fd9fc0ef          	jal	80000834 <panic>

0000000080003860 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003860:	1141                	addi	sp,sp,-16
    80003862:	e406                	sd	ra,8(sp)
    80003864:	e022                	sd	s0,0(sp)
    80003866:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003868:	411c                	lw	a5,0(a0)
    8000386a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000386c:	415c                	lw	a5,4(a0)
    8000386e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003870:	04451783          	lh	a5,68(a0)
    80003874:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003878:	04a51783          	lh	a5,74(a0)
    8000387c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003880:	04c56783          	lwu	a5,76(a0)
    80003884:	e99c                	sd	a5,16(a1)
}
    80003886:	60a2                	ld	ra,8(sp)
    80003888:	6402                	ld	s0,0(sp)
    8000388a:	0141                	addi	sp,sp,16
    8000388c:	8082                	ret

000000008000388e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    8000388e:	457c                	lw	a5,76(a0)
    80003890:	0ed7e663          	bltu	a5,a3,8000397c <readi+0xee>
{
    80003894:	7159                	addi	sp,sp,-112
    80003896:	f486                	sd	ra,104(sp)
    80003898:	f0a2                	sd	s0,96(sp)
    8000389a:	eca6                	sd	s1,88(sp)
    8000389c:	e0d2                	sd	s4,64(sp)
    8000389e:	fc56                	sd	s5,56(sp)
    800038a0:	f85a                	sd	s6,48(sp)
    800038a2:	f45e                	sd	s7,40(sp)
    800038a4:	1880                	addi	s0,sp,112
    800038a6:	8b2a                	mv	s6,a0
    800038a8:	8bae                	mv	s7,a1
    800038aa:	8a32                	mv	s4,a2
    800038ac:	84b6                	mv	s1,a3
    800038ae:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800038b0:	9f35                	addw	a4,a4,a3
    return 0;
    800038b2:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800038b4:	0ad76b63          	bltu	a4,a3,8000396a <readi+0xdc>
    800038b8:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    800038ba:	00e7f463          	bgeu	a5,a4,800038c2 <readi+0x34>
    n = ip->size - off;
    800038be:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800038c2:	080a8b63          	beqz	s5,80003958 <readi+0xca>
    800038c6:	e8ca                	sd	s2,80(sp)
    800038c8:	f062                	sd	s8,32(sp)
    800038ca:	ec66                	sd	s9,24(sp)
    800038cc:	e86a                	sd	s10,16(sp)
    800038ce:	e46e                	sd	s11,8(sp)
    800038d0:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800038d2:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800038d6:	5c7d                	li	s8,-1
    800038d8:	a80d                	j	8000390a <readi+0x7c>
    800038da:	020d1d93          	slli	s11,s10,0x20
    800038de:	020ddd93          	srli	s11,s11,0x20
    800038e2:	05890613          	addi	a2,s2,88
    800038e6:	86ee                	mv	a3,s11
    800038e8:	963e                	add	a2,a2,a5
    800038ea:	85d2                	mv	a1,s4
    800038ec:	855e                	mv	a0,s7
    800038ee:	bebfe0ef          	jal	800024d8 <either_copyout>
    800038f2:	05850363          	beq	a0,s8,80003938 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800038f6:	854a                	mv	a0,s2
    800038f8:	e2cff0ef          	jal	80002f24 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800038fc:	013d09bb          	addw	s3,s10,s3
    80003900:	009d04bb          	addw	s1,s10,s1
    80003904:	9a6e                	add	s4,s4,s11
    80003906:	0559f363          	bgeu	s3,s5,8000394c <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    8000390a:	00a4d59b          	srliw	a1,s1,0xa
    8000390e:	855a                	mv	a0,s6
    80003910:	873ff0ef          	jal	80003182 <bmap>
    80003914:	85aa                	mv	a1,a0
    if (addr == 0)
    80003916:	c139                	beqz	a0,8000395c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003918:	000b2503          	lw	a0,0(s6)
    8000391c:	d00ff0ef          	jal	80002e1c <bread>
    80003920:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003922:	3ff4f793          	andi	a5,s1,1023
    80003926:	40fc873b          	subw	a4,s9,a5
    8000392a:	413a86bb          	subw	a3,s5,s3
    8000392e:	8d3a                	mv	s10,a4
    80003930:	fae6f5e3          	bgeu	a3,a4,800038da <readi+0x4c>
    80003934:	8d36                	mv	s10,a3
    80003936:	b755                	j	800038da <readi+0x4c>
      brelse(bp);
    80003938:	854a                	mv	a0,s2
    8000393a:	deaff0ef          	jal	80002f24 <brelse>
      tot = -1;
    8000393e:	59fd                	li	s3,-1
      break;
    80003940:	6946                	ld	s2,80(sp)
    80003942:	7c02                	ld	s8,32(sp)
    80003944:	6ce2                	ld	s9,24(sp)
    80003946:	6d42                	ld	s10,16(sp)
    80003948:	6da2                	ld	s11,8(sp)
    8000394a:	a831                	j	80003966 <readi+0xd8>
    8000394c:	6946                	ld	s2,80(sp)
    8000394e:	7c02                	ld	s8,32(sp)
    80003950:	6ce2                	ld	s9,24(sp)
    80003952:	6d42                	ld	s10,16(sp)
    80003954:	6da2                	ld	s11,8(sp)
    80003956:	a801                	j	80003966 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003958:	89d6                	mv	s3,s5
    8000395a:	a031                	j	80003966 <readi+0xd8>
    8000395c:	6946                	ld	s2,80(sp)
    8000395e:	7c02                	ld	s8,32(sp)
    80003960:	6ce2                	ld	s9,24(sp)
    80003962:	6d42                	ld	s10,16(sp)
    80003964:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003966:	854e                	mv	a0,s3
    80003968:	69a6                	ld	s3,72(sp)
}
    8000396a:	70a6                	ld	ra,104(sp)
    8000396c:	7406                	ld	s0,96(sp)
    8000396e:	64e6                	ld	s1,88(sp)
    80003970:	6a06                	ld	s4,64(sp)
    80003972:	7ae2                	ld	s5,56(sp)
    80003974:	7b42                	ld	s6,48(sp)
    80003976:	7ba2                	ld	s7,40(sp)
    80003978:	6165                	addi	sp,sp,112
    8000397a:	8082                	ret
    return 0;
    8000397c:	4501                	li	a0,0
}
    8000397e:	8082                	ret

0000000080003980 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003980:	457c                	lw	a5,76(a0)
    80003982:	0ed7ee63          	bltu	a5,a3,80003a7e <writei+0xfe>
{
    80003986:	7159                	addi	sp,sp,-112
    80003988:	f486                	sd	ra,104(sp)
    8000398a:	f0a2                	sd	s0,96(sp)
    8000398c:	e8ca                	sd	s2,80(sp)
    8000398e:	e0d2                	sd	s4,64(sp)
    80003990:	fc56                	sd	s5,56(sp)
    80003992:	f85a                	sd	s6,48(sp)
    80003994:	f45e                	sd	s7,40(sp)
    80003996:	1880                	addi	s0,sp,112
    80003998:	8aaa                	mv	s5,a0
    8000399a:	8bae                	mv	s7,a1
    8000399c:	8a32                	mv	s4,a2
    8000399e:	8936                	mv	s2,a3
    800039a0:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    800039a2:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    800039a6:	00043737          	lui	a4,0x43
    800039aa:	0cf76c63          	bltu	a4,a5,80003a82 <writei+0x102>
    800039ae:	0cd7ea63          	bltu	a5,a3,80003a82 <writei+0x102>
    800039b2:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800039b4:	0a0b0d63          	beqz	s6,80003a6e <writei+0xee>
    800039b8:	eca6                	sd	s1,88(sp)
    800039ba:	f062                	sd	s8,32(sp)
    800039bc:	ec66                	sd	s9,24(sp)
    800039be:	e86a                	sd	s10,16(sp)
    800039c0:	e46e                	sd	s11,8(sp)
    800039c2:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800039c4:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800039c8:	5c7d                	li	s8,-1
    800039ca:	a825                	j	80003a02 <writei+0x82>
    800039cc:	020d1d93          	slli	s11,s10,0x20
    800039d0:	020ddd93          	srli	s11,s11,0x20
    800039d4:	05848513          	addi	a0,s1,88
    800039d8:	86ee                	mv	a3,s11
    800039da:	8652                	mv	a2,s4
    800039dc:	85de                	mv	a1,s7
    800039de:	953e                	add	a0,a0,a5
    800039e0:	b45fe0ef          	jal	80002524 <either_copyin>
    800039e4:	05850663          	beq	a0,s8,80003a30 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    800039e8:	8526                	mv	a0,s1
    800039ea:	6f0000ef          	jal	800040da <log_write>
    brelse(bp);
    800039ee:	8526                	mv	a0,s1
    800039f0:	d34ff0ef          	jal	80002f24 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800039f4:	013d09bb          	addw	s3,s10,s3
    800039f8:	012d093b          	addw	s2,s10,s2
    800039fc:	9a6e                	add	s4,s4,s11
    800039fe:	0369ff63          	bgeu	s3,s6,80003a3c <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    80003a02:	00a9559b          	srliw	a1,s2,0xa
    80003a06:	8556                	mv	a0,s5
    80003a08:	f7aff0ef          	jal	80003182 <bmap>
    80003a0c:	85aa                	mv	a1,a0
    if (addr == 0)
    80003a0e:	c51d                	beqz	a0,80003a3c <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003a10:	000aa503          	lw	a0,0(s5)
    80003a14:	c08ff0ef          	jal	80002e1c <bread>
    80003a18:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003a1a:	3ff97793          	andi	a5,s2,1023
    80003a1e:	40fc873b          	subw	a4,s9,a5
    80003a22:	413b06bb          	subw	a3,s6,s3
    80003a26:	8d3a                	mv	s10,a4
    80003a28:	fae6f2e3          	bgeu	a3,a4,800039cc <writei+0x4c>
    80003a2c:	8d36                	mv	s10,a3
    80003a2e:	bf79                	j	800039cc <writei+0x4c>
      log_write(bp);
    80003a30:	8526                	mv	a0,s1
    80003a32:	6a8000ef          	jal	800040da <log_write>
      brelse(bp);
    80003a36:	8526                	mv	a0,s1
    80003a38:	cecff0ef          	jal	80002f24 <brelse>
  }

  if (off > ip->size)
    80003a3c:	04caa783          	lw	a5,76(s5)
    80003a40:	0327f963          	bgeu	a5,s2,80003a72 <writei+0xf2>
    ip->size = off;
    80003a44:	052aa623          	sw	s2,76(s5)
    80003a48:	64e6                	ld	s1,88(sp)
    80003a4a:	7c02                	ld	s8,32(sp)
    80003a4c:	6ce2                	ld	s9,24(sp)
    80003a4e:	6d42                	ld	s10,16(sp)
    80003a50:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003a52:	8556                	mv	a0,s5
    80003a54:	9adff0ef          	jal	80003400 <iupdate>

  return tot;
    80003a58:	854e                	mv	a0,s3
    80003a5a:	69a6                	ld	s3,72(sp)
}
    80003a5c:	70a6                	ld	ra,104(sp)
    80003a5e:	7406                	ld	s0,96(sp)
    80003a60:	6946                	ld	s2,80(sp)
    80003a62:	6a06                	ld	s4,64(sp)
    80003a64:	7ae2                	ld	s5,56(sp)
    80003a66:	7b42                	ld	s6,48(sp)
    80003a68:	7ba2                	ld	s7,40(sp)
    80003a6a:	6165                	addi	sp,sp,112
    80003a6c:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003a6e:	89da                	mv	s3,s6
    80003a70:	b7cd                	j	80003a52 <writei+0xd2>
    80003a72:	64e6                	ld	s1,88(sp)
    80003a74:	7c02                	ld	s8,32(sp)
    80003a76:	6ce2                	ld	s9,24(sp)
    80003a78:	6d42                	ld	s10,16(sp)
    80003a7a:	6da2                	ld	s11,8(sp)
    80003a7c:	bfd9                	j	80003a52 <writei+0xd2>
    return -1;
    80003a7e:	557d                	li	a0,-1
}
    80003a80:	8082                	ret
    return -1;
    80003a82:	557d                	li	a0,-1
    80003a84:	bfe1                	j	80003a5c <writei+0xdc>

0000000080003a86 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003a86:	1141                	addi	sp,sp,-16
    80003a88:	e406                	sd	ra,8(sp)
    80003a8a:	e022                	sd	s0,0(sp)
    80003a8c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a8e:	4639                	li	a2,14
    80003a90:	b2cfd0ef          	jal	80000dbc <strncmp>
}
    80003a94:	60a2                	ld	ra,8(sp)
    80003a96:	6402                	ld	s0,0(sp)
    80003a98:	0141                	addi	sp,sp,16
    80003a9a:	8082                	ret

0000000080003a9c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a9c:	711d                	addi	sp,sp,-96
    80003a9e:	ec86                	sd	ra,88(sp)
    80003aa0:	e8a2                	sd	s0,80(sp)
    80003aa2:	e4a6                	sd	s1,72(sp)
    80003aa4:	e0ca                	sd	s2,64(sp)
    80003aa6:	fc4e                	sd	s3,56(sp)
    80003aa8:	f852                	sd	s4,48(sp)
    80003aaa:	f456                	sd	s5,40(sp)
    80003aac:	f05a                	sd	s6,32(sp)
    80003aae:	ec5e                	sd	s7,24(sp)
    80003ab0:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003ab2:	04451703          	lh	a4,68(a0)
    80003ab6:	4785                	li	a5,1
    80003ab8:	00f71f63          	bne	a4,a5,80003ad6 <dirlookup+0x3a>
    80003abc:	892a                	mv	s2,a0
    80003abe:	8aae                	mv	s5,a1
    80003ac0:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003ac2:	457c                	lw	a5,76(a0)
    80003ac4:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ac6:	fa040a13          	addi	s4,s0,-96
    80003aca:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003acc:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ad0:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003ad2:	e39d                	bnez	a5,80003af8 <dirlookup+0x5c>
    80003ad4:	a8b9                	j	80003b32 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003ad6:	00004517          	auipc	a0,0x4
    80003ada:	9ea50513          	addi	a0,a0,-1558 # 800074c0 <etext+0x4c0>
    80003ade:	d57fc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    80003ae2:	00004517          	auipc	a0,0x4
    80003ae6:	9f650513          	addi	a0,a0,-1546 # 800074d8 <etext+0x4d8>
    80003aea:	d4bfc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003aee:	24c1                	addiw	s1,s1,16
    80003af0:	04c92783          	lw	a5,76(s2)
    80003af4:	02f4fe63          	bgeu	s1,a5,80003b30 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003af8:	874e                	mv	a4,s3
    80003afa:	86a6                	mv	a3,s1
    80003afc:	8652                	mv	a2,s4
    80003afe:	4581                	li	a1,0
    80003b00:	854a                	mv	a0,s2
    80003b02:	d8dff0ef          	jal	8000388e <readi>
    80003b06:	fd351ee3          	bne	a0,s3,80003ae2 <dirlookup+0x46>
    if (de.inum == 0)
    80003b0a:	fa045783          	lhu	a5,-96(s0)
    80003b0e:	d3e5                	beqz	a5,80003aee <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003b10:	85da                	mv	a1,s6
    80003b12:	8556                	mv	a0,s5
    80003b14:	f73ff0ef          	jal	80003a86 <namecmp>
    80003b18:	f979                	bnez	a0,80003aee <dirlookup+0x52>
      if (poff)
    80003b1a:	000b8463          	beqz	s7,80003b22 <dirlookup+0x86>
        *poff = off;
    80003b1e:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003b22:	fa045583          	lhu	a1,-96(s0)
    80003b26:	00092503          	lw	a0,0(s2)
    80003b2a:	f18ff0ef          	jal	80003242 <iget>
    80003b2e:	a011                	j	80003b32 <dirlookup+0x96>
  return 0;
    80003b30:	4501                	li	a0,0
}
    80003b32:	60e6                	ld	ra,88(sp)
    80003b34:	6446                	ld	s0,80(sp)
    80003b36:	64a6                	ld	s1,72(sp)
    80003b38:	6906                	ld	s2,64(sp)
    80003b3a:	79e2                	ld	s3,56(sp)
    80003b3c:	7a42                	ld	s4,48(sp)
    80003b3e:	7aa2                	ld	s5,40(sp)
    80003b40:	7b02                	ld	s6,32(sp)
    80003b42:	6be2                	ld	s7,24(sp)
    80003b44:	6125                	addi	sp,sp,96
    80003b46:	8082                	ret

0000000080003b48 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003b48:	711d                	addi	sp,sp,-96
    80003b4a:	ec86                	sd	ra,88(sp)
    80003b4c:	e8a2                	sd	s0,80(sp)
    80003b4e:	e4a6                	sd	s1,72(sp)
    80003b50:	e0ca                	sd	s2,64(sp)
    80003b52:	fc4e                	sd	s3,56(sp)
    80003b54:	f852                	sd	s4,48(sp)
    80003b56:	f456                	sd	s5,40(sp)
    80003b58:	f05a                	sd	s6,32(sp)
    80003b5a:	ec5e                	sd	s7,24(sp)
    80003b5c:	e862                	sd	s8,16(sp)
    80003b5e:	e466                	sd	s9,8(sp)
    80003b60:	e06a                	sd	s10,0(sp)
    80003b62:	1080                	addi	s0,sp,96
    80003b64:	84aa                	mv	s1,a0
    80003b66:	8b2e                	mv	s6,a1
    80003b68:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003b6a:	00054703          	lbu	a4,0(a0)
    80003b6e:	02f00793          	li	a5,47
    80003b72:	00f70f63          	beq	a4,a5,80003b90 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003b76:	dd3fd0ef          	jal	80001948 <myproc>
    80003b7a:	15053503          	ld	a0,336(a0)
    80003b7e:	901ff0ef          	jal	8000347e <idup>
    80003b82:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003b84:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003b88:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003b8a:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003b8c:	4b85                	li	s7,1
    80003b8e:	a07d                	j	80003c3c <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003b90:	4585                	li	a1,1
    80003b92:	852e                	mv	a0,a1
    80003b94:	eaeff0ef          	jal	80003242 <iget>
    80003b98:	8a2a                	mv	s4,a0
    80003b9a:	b7ed                	j	80003b84 <namex+0x3c>
      iunlockput(ip);
    80003b9c:	8552                	mv	a0,s4
    80003b9e:	b6bff0ef          	jal	80003708 <iunlockput>
      return 0;
    80003ba2:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ba4:	8552                	mv	a0,s4
    80003ba6:	60e6                	ld	ra,88(sp)
    80003ba8:	6446                	ld	s0,80(sp)
    80003baa:	64a6                	ld	s1,72(sp)
    80003bac:	6906                	ld	s2,64(sp)
    80003bae:	79e2                	ld	s3,56(sp)
    80003bb0:	7a42                	ld	s4,48(sp)
    80003bb2:	7aa2                	ld	s5,40(sp)
    80003bb4:	7b02                	ld	s6,32(sp)
    80003bb6:	6be2                	ld	s7,24(sp)
    80003bb8:	6c42                	ld	s8,16(sp)
    80003bba:	6ca2                	ld	s9,8(sp)
    80003bbc:	6d02                	ld	s10,0(sp)
    80003bbe:	6125                	addi	sp,sp,96
    80003bc0:	8082                	ret
      iunlockput(ip);
    80003bc2:	8552                	mv	a0,s4
    80003bc4:	b45ff0ef          	jal	80003708 <iunlockput>
      return 0;
    80003bc8:	4a01                	li	s4,0
    80003bca:	bfe9                	j	80003ba4 <namex+0x5c>
      iunlock(ip);
    80003bcc:	8552                	mv	a0,s4
    80003bce:	995ff0ef          	jal	80003562 <iunlock>
      return ip;
    80003bd2:	bfc9                	j	80003ba4 <namex+0x5c>
      iunlockput(ip);
    80003bd4:	8552                	mv	a0,s4
    80003bd6:	b33ff0ef          	jal	80003708 <iunlockput>
      return 0;
    80003bda:	8a4a                	mv	s4,s2
    80003bdc:	b7e1                	j	80003ba4 <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003bde:	8926                	mv	s2,s1
  len = path - s;
    80003be0:	4d01                	li	s10,0
    80003be2:	4601                	li	a2,0
    memmove(name, s, len);
    80003be4:	2601                	sext.w	a2,a2
    80003be6:	85a6                	mv	a1,s1
    80003be8:	8556                	mv	a0,s5
    80003bea:	95efd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003bee:	9d56                	add	s10,s10,s5
    80003bf0:	000d0023          	sb	zero,0(s10)
  while (*path == '/')
    80003bf4:	00094783          	lbu	a5,0(s2)
    80003bf8:	09379b63          	bne	a5,s3,80003c8e <namex+0x146>
    80003bfc:	84ca                	mv	s1,s2
    path++;
    80003bfe:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003c00:	0004c783          	lbu	a5,0(s1)
    80003c04:	ff378de3          	beq	a5,s3,80003bfe <namex+0xb6>
    ilock(ip);
    80003c08:	8552                	mv	a0,s4
    80003c0a:	8abff0ef          	jal	800034b4 <ilock>
    if (ip->type != T_DIR) {
    80003c0e:	044a1783          	lh	a5,68(s4)
    80003c12:	f97795e3          	bne	a5,s7,80003b9c <namex+0x54>
    if (ip->nlink == 0) {
    80003c16:	04aa1783          	lh	a5,74(s4)
    80003c1a:	d7c5                	beqz	a5,80003bc2 <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003c1c:	000b0563          	beqz	s6,80003c26 <namex+0xde>
    80003c20:	0004c783          	lbu	a5,0(s1)
    80003c24:	d7c5                	beqz	a5,80003bcc <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003c26:	4601                	li	a2,0
    80003c28:	85d6                	mv	a1,s5
    80003c2a:	8552                	mv	a0,s4
    80003c2c:	e71ff0ef          	jal	80003a9c <dirlookup>
    80003c30:	892a                	mv	s2,a0
    80003c32:	d14d                	beqz	a0,80003bd4 <namex+0x8c>
    iunlockput(ip);
    80003c34:	8552                	mv	a0,s4
    80003c36:	ad3ff0ef          	jal	80003708 <iunlockput>
    ip = next;
    80003c3a:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003c3c:	0004c783          	lbu	a5,0(s1)
    80003c40:	01379763          	bne	a5,s3,80003c4e <namex+0x106>
    path++;
    80003c44:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003c46:	0004c783          	lbu	a5,0(s1)
    80003c4a:	ff378de3          	beq	a5,s3,80003c44 <namex+0xfc>
  if (*path == 0)
    80003c4e:	c7a1                	beqz	a5,80003c96 <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003c50:	0004c783          	lbu	a5,0(s1)
    80003c54:	fd178713          	addi	a4,a5,-47
    80003c58:	d359                	beqz	a4,80003bde <namex+0x96>
    80003c5a:	d3d1                	beqz	a5,80003bde <namex+0x96>
    80003c5c:	8926                	mv	s2,s1
    path++;
    80003c5e:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003c60:	00094783          	lbu	a5,0(s2)
    80003c64:	fd178713          	addi	a4,a5,-47
    80003c68:	c311                	beqz	a4,80003c6c <namex+0x124>
    80003c6a:	fbf5                	bnez	a5,80003c5e <namex+0x116>
  len = path - s;
    80003c6c:	40990633          	sub	a2,s2,s1
    80003c70:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003c74:	f7ac58e3          	bge	s8,s10,80003be4 <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003c78:	8666                	mv	a2,s9
    80003c7a:	85a6                	mv	a1,s1
    80003c7c:	8556                	mv	a0,s5
    80003c7e:	8cafd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003c82:	00094783          	lbu	a5,0(s2)
    80003c86:	84ca                	mv	s1,s2
    80003c88:	f7378be3          	beq	a5,s3,80003bfe <namex+0xb6>
    80003c8c:	bfb5                	j	80003c08 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003c8e:	00090463          	beqz	s2,80003c96 <namex+0x14e>
    80003c92:	84ca                	mv	s1,s2
    80003c94:	bf95                	j	80003c08 <namex+0xc0>
  if (nameiparent) {
    80003c96:	f00b07e3          	beqz	s6,80003ba4 <namex+0x5c>
    iput(ip);
    80003c9a:	8552                	mv	a0,s4
    80003c9c:	99bff0ef          	jal	80003636 <iput>
    return 0;
    80003ca0:	4a01                	li	s4,0
    80003ca2:	b709                	j	80003ba4 <namex+0x5c>

0000000080003ca4 <dirlink>:
{
    80003ca4:	715d                	addi	sp,sp,-80
    80003ca6:	e486                	sd	ra,72(sp)
    80003ca8:	e0a2                	sd	s0,64(sp)
    80003caa:	f84a                	sd	s2,48(sp)
    80003cac:	ec56                	sd	s5,24(sp)
    80003cae:	e85a                	sd	s6,16(sp)
    80003cb0:	0880                	addi	s0,sp,80
    80003cb2:	892a                	mv	s2,a0
    80003cb4:	8aae                	mv	s5,a1
    80003cb6:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003cb8:	4601                	li	a2,0
    80003cba:	de3ff0ef          	jal	80003a9c <dirlookup>
    80003cbe:	ed1d                	bnez	a0,80003cfc <dirlink+0x58>
    80003cc0:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003cc2:	04c92483          	lw	s1,76(s2)
    80003cc6:	c4b9                	beqz	s1,80003d14 <dirlink+0x70>
    80003cc8:	f44e                	sd	s3,40(sp)
    80003cca:	f052                	sd	s4,32(sp)
    80003ccc:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cce:	fb040a13          	addi	s4,s0,-80
    80003cd2:	49c1                	li	s3,16
    80003cd4:	874e                	mv	a4,s3
    80003cd6:	86a6                	mv	a3,s1
    80003cd8:	8652                	mv	a2,s4
    80003cda:	4581                	li	a1,0
    80003cdc:	854a                	mv	a0,s2
    80003cde:	bb1ff0ef          	jal	8000388e <readi>
    80003ce2:	03351163          	bne	a0,s3,80003d04 <dirlink+0x60>
    if (de.inum == 0)
    80003ce6:	fb045783          	lhu	a5,-80(s0)
    80003cea:	c39d                	beqz	a5,80003d10 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003cec:	24c1                	addiw	s1,s1,16
    80003cee:	04c92783          	lw	a5,76(s2)
    80003cf2:	fef4e1e3          	bltu	s1,a5,80003cd4 <dirlink+0x30>
    80003cf6:	79a2                	ld	s3,40(sp)
    80003cf8:	7a02                	ld	s4,32(sp)
    80003cfa:	a829                	j	80003d14 <dirlink+0x70>
    iput(ip);
    80003cfc:	93bff0ef          	jal	80003636 <iput>
    return -1;
    80003d00:	557d                	li	a0,-1
    80003d02:	a83d                	j	80003d40 <dirlink+0x9c>
      panic("dirlink read");
    80003d04:	00003517          	auipc	a0,0x3
    80003d08:	7e450513          	addi	a0,a0,2020 # 800074e8 <etext+0x4e8>
    80003d0c:	b29fc0ef          	jal	80000834 <panic>
    80003d10:	79a2                	ld	s3,40(sp)
    80003d12:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003d14:	4639                	li	a2,14
    80003d16:	85d6                	mv	a1,s5
    80003d18:	fb240513          	addi	a0,s0,-78
    80003d1c:	8dafd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003d20:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d24:	4741                	li	a4,16
    80003d26:	86a6                	mv	a3,s1
    80003d28:	fb040613          	addi	a2,s0,-80
    80003d2c:	4581                	li	a1,0
    80003d2e:	854a                	mv	a0,s2
    80003d30:	c51ff0ef          	jal	80003980 <writei>
    80003d34:	1541                	addi	a0,a0,-16
    80003d36:	00a03533          	snez	a0,a0
    80003d3a:	40a0053b          	negw	a0,a0
    80003d3e:	74e2                	ld	s1,56(sp)
}
    80003d40:	60a6                	ld	ra,72(sp)
    80003d42:	6406                	ld	s0,64(sp)
    80003d44:	7942                	ld	s2,48(sp)
    80003d46:	6ae2                	ld	s5,24(sp)
    80003d48:	6b42                	ld	s6,16(sp)
    80003d4a:	6161                	addi	sp,sp,80
    80003d4c:	8082                	ret

0000000080003d4e <namei>:

struct inode *
namei(char *path)
{
    80003d4e:	1101                	addi	sp,sp,-32
    80003d50:	ec06                	sd	ra,24(sp)
    80003d52:	e822                	sd	s0,16(sp)
    80003d54:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003d56:	fe040613          	addi	a2,s0,-32
    80003d5a:	4581                	li	a1,0
    80003d5c:	dedff0ef          	jal	80003b48 <namex>
}
    80003d60:	60e2                	ld	ra,24(sp)
    80003d62:	6442                	ld	s0,16(sp)
    80003d64:	6105                	addi	sp,sp,32
    80003d66:	8082                	ret

0000000080003d68 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003d68:	1141                	addi	sp,sp,-16
    80003d6a:	e406                	sd	ra,8(sp)
    80003d6c:	e022                	sd	s0,0(sp)
    80003d6e:	0800                	addi	s0,sp,16
    80003d70:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003d72:	4585                	li	a1,1
    80003d74:	dd5ff0ef          	jal	80003b48 <namex>
}
    80003d78:	60a2                	ld	ra,8(sp)
    80003d7a:	6402                	ld	s0,0(sp)
    80003d7c:	0141                	addi	sp,sp,16
    80003d7e:	8082                	ret

0000000080003d80 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003d80:	1101                	addi	sp,sp,-32
    80003d82:	ec06                	sd	ra,24(sp)
    80003d84:	e822                	sd	s0,16(sp)
    80003d86:	e426                	sd	s1,8(sp)
    80003d88:	e04a                	sd	s2,0(sp)
    80003d8a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003d8c:	0001f917          	auipc	s2,0x1f
    80003d90:	95c90913          	addi	s2,s2,-1700 # 800226e8 <log>
    80003d94:	01892583          	lw	a1,24(s2)
    80003d98:	02492503          	lw	a0,36(s2)
    80003d9c:	880ff0ef          	jal	80002e1c <bread>
    80003da0:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003da2:	02c92603          	lw	a2,44(s2)
    80003da6:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003da8:	00c05f63          	blez	a2,80003dc6 <write_head+0x46>
    80003dac:	0001f717          	auipc	a4,0x1f
    80003db0:	96c70713          	addi	a4,a4,-1684 # 80022718 <log+0x30>
    80003db4:	87aa                	mv	a5,a0
    80003db6:	060a                	slli	a2,a2,0x2
    80003db8:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003dba:	4314                	lw	a3,0(a4)
    80003dbc:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003dbe:	0711                	addi	a4,a4,4
    80003dc0:	0791                	addi	a5,a5,4
    80003dc2:	fec79ce3          	bne	a5,a2,80003dba <write_head+0x3a>
  }
  bwrite(buf);
    80003dc6:	8526                	mv	a0,s1
    80003dc8:	92aff0ef          	jal	80002ef2 <bwrite>
  brelse(buf);
    80003dcc:	8526                	mv	a0,s1
    80003dce:	956ff0ef          	jal	80002f24 <brelse>
}
    80003dd2:	60e2                	ld	ra,24(sp)
    80003dd4:	6442                	ld	s0,16(sp)
    80003dd6:	64a2                	ld	s1,8(sp)
    80003dd8:	6902                	ld	s2,0(sp)
    80003dda:	6105                	addi	sp,sp,32
    80003ddc:	8082                	ret

0000000080003dde <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dde:	0001f797          	auipc	a5,0x1f
    80003de2:	9367a783          	lw	a5,-1738(a5) # 80022714 <log+0x2c>
    80003de6:	0cf05163          	blez	a5,80003ea8 <install_trans+0xca>
{
    80003dea:	715d                	addi	sp,sp,-80
    80003dec:	e486                	sd	ra,72(sp)
    80003dee:	e0a2                	sd	s0,64(sp)
    80003df0:	fc26                	sd	s1,56(sp)
    80003df2:	f84a                	sd	s2,48(sp)
    80003df4:	f44e                	sd	s3,40(sp)
    80003df6:	f052                	sd	s4,32(sp)
    80003df8:	ec56                	sd	s5,24(sp)
    80003dfa:	e85a                	sd	s6,16(sp)
    80003dfc:	e45e                	sd	s7,8(sp)
    80003dfe:	e062                	sd	s8,0(sp)
    80003e00:	0880                	addi	s0,sp,80
    80003e02:	8b2a                	mv	s6,a0
    80003e04:	0001fa97          	auipc	s5,0x1f
    80003e08:	914a8a93          	addi	s5,s5,-1772 # 80022718 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e0c:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003e0e:	00003c17          	auipc	s8,0x3
    80003e12:	6eac0c13          	addi	s8,s8,1770 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003e16:	0001fa17          	auipc	s4,0x1f
    80003e1a:	8d2a0a13          	addi	s4,s4,-1838 # 800226e8 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003e1e:	40000b93          	li	s7,1024
    80003e22:	a025                	j	80003e4a <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003e24:	000aa603          	lw	a2,0(s5)
    80003e28:	85ce                	mv	a1,s3
    80003e2a:	8562                	mv	a0,s8
    80003e2c:	edefc0ef          	jal	8000050a <printk>
    80003e30:	a839                	j	80003e4e <install_trans+0x70>
    brelse(lbuf);
    80003e32:	854a                	mv	a0,s2
    80003e34:	8f0ff0ef          	jal	80002f24 <brelse>
    brelse(dbuf);
    80003e38:	8526                	mv	a0,s1
    80003e3a:	8eaff0ef          	jal	80002f24 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e3e:	2985                	addiw	s3,s3,1
    80003e40:	0a91                	addi	s5,s5,4
    80003e42:	02ca2783          	lw	a5,44(s4)
    80003e46:	04f9d563          	bge	s3,a5,80003e90 <install_trans+0xb2>
    if (recovering) {
    80003e4a:	fc0b1de3          	bnez	s6,80003e24 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003e4e:	018a2583          	lw	a1,24(s4)
    80003e52:	013585bb          	addw	a1,a1,s3
    80003e56:	2585                	addiw	a1,a1,1
    80003e58:	024a2503          	lw	a0,36(s4)
    80003e5c:	fc1fe0ef          	jal	80002e1c <bread>
    80003e60:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003e62:	000aa583          	lw	a1,0(s5)
    80003e66:	024a2503          	lw	a0,36(s4)
    80003e6a:	fb3fe0ef          	jal	80002e1c <bread>
    80003e6e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003e70:	865e                	mv	a2,s7
    80003e72:	05890593          	addi	a1,s2,88
    80003e76:	05850513          	addi	a0,a0,88
    80003e7a:	ecffc0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003e7e:	8526                	mv	a0,s1
    80003e80:	872ff0ef          	jal	80002ef2 <bwrite>
    if (recovering == 0)
    80003e84:	fa0b17e3          	bnez	s6,80003e32 <install_trans+0x54>
      bunpin(dbuf);
    80003e88:	8526                	mv	a0,s1
    80003e8a:	952ff0ef          	jal	80002fdc <bunpin>
    80003e8e:	b755                	j	80003e32 <install_trans+0x54>
}
    80003e90:	60a6                	ld	ra,72(sp)
    80003e92:	6406                	ld	s0,64(sp)
    80003e94:	74e2                	ld	s1,56(sp)
    80003e96:	7942                	ld	s2,48(sp)
    80003e98:	79a2                	ld	s3,40(sp)
    80003e9a:	7a02                	ld	s4,32(sp)
    80003e9c:	6ae2                	ld	s5,24(sp)
    80003e9e:	6b42                	ld	s6,16(sp)
    80003ea0:	6ba2                	ld	s7,8(sp)
    80003ea2:	6c02                	ld	s8,0(sp)
    80003ea4:	6161                	addi	sp,sp,80
    80003ea6:	8082                	ret
    80003ea8:	8082                	ret

0000000080003eaa <initlog>:
{
    80003eaa:	7179                	addi	sp,sp,-48
    80003eac:	f406                	sd	ra,40(sp)
    80003eae:	f022                	sd	s0,32(sp)
    80003eb0:	ec26                	sd	s1,24(sp)
    80003eb2:	e84a                	sd	s2,16(sp)
    80003eb4:	e44e                	sd	s3,8(sp)
    80003eb6:	1800                	addi	s0,sp,48
    80003eb8:	84aa                	mv	s1,a0
    80003eba:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003ebc:	0001f917          	auipc	s2,0x1f
    80003ec0:	82c90913          	addi	s2,s2,-2004 # 800226e8 <log>
    80003ec4:	00003597          	auipc	a1,0x3
    80003ec8:	65458593          	addi	a1,a1,1620 # 80007518 <etext+0x518>
    80003ecc:	854a                	mv	a0,s2
    80003ece:	cdbfc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003ed2:	0149a583          	lw	a1,20(s3)
    80003ed6:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003eda:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003ede:	8526                	mv	a0,s1
    80003ee0:	f3dfe0ef          	jal	80002e1c <bread>
  log.lh.n = lh->n;
    80003ee4:	4d30                	lw	a2,88(a0)
    80003ee6:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003eea:	00c05f63          	blez	a2,80003f08 <initlog+0x5e>
    80003eee:	87aa                	mv	a5,a0
    80003ef0:	0001f717          	auipc	a4,0x1f
    80003ef4:	82870713          	addi	a4,a4,-2008 # 80022718 <log+0x30>
    80003ef8:	060a                	slli	a2,a2,0x2
    80003efa:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003efc:	4ff4                	lw	a3,92(a5)
    80003efe:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f00:	0791                	addi	a5,a5,4
    80003f02:	0711                	addi	a4,a4,4
    80003f04:	fec79ce3          	bne	a5,a2,80003efc <initlog+0x52>
  brelse(buf);
    80003f08:	81cff0ef          	jal	80002f24 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003f0c:	4505                	li	a0,1
    80003f0e:	ed1ff0ef          	jal	80003dde <install_trans>
  log.lh.n = 0;
    80003f12:	0001f797          	auipc	a5,0x1f
    80003f16:	8007a123          	sw	zero,-2046(a5) # 80022714 <log+0x2c>
  write_head(); // clear the log
    80003f1a:	e67ff0ef          	jal	80003d80 <write_head>
}
    80003f1e:	70a2                	ld	ra,40(sp)
    80003f20:	7402                	ld	s0,32(sp)
    80003f22:	64e2                	ld	s1,24(sp)
    80003f24:	6942                	ld	s2,16(sp)
    80003f26:	69a2                	ld	s3,8(sp)
    80003f28:	6145                	addi	sp,sp,48
    80003f2a:	8082                	ret

0000000080003f2c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003f2c:	1101                	addi	sp,sp,-32
    80003f2e:	ec06                	sd	ra,24(sp)
    80003f30:	e822                	sd	s0,16(sp)
    80003f32:	e426                	sd	s1,8(sp)
    80003f34:	e04a                	sd	s2,0(sp)
    80003f36:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003f38:	0001e517          	auipc	a0,0x1e
    80003f3c:	7b050513          	addi	a0,a0,1968 # 800226e8 <log>
    80003f40:	ce9fc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80003f44:	0001e497          	auipc	s1,0x1e
    80003f48:	7a448493          	addi	s1,s1,1956 # 800226e8 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003f4c:	4979                	li	s2,30
    80003f4e:	a821                	j	80003f66 <begin_op+0x3a>
      sleep_prepare(&log);
    80003f50:	8526                	mv	a0,s1
    80003f52:	9f4fe0ef          	jal	80002146 <sleep_prepare>
      release(&log.lock);
    80003f56:	8526                	mv	a0,s1
    80003f58:	d59fc0ef          	jal	80000cb0 <release>
      sleep();
    80003f5c:	a26fe0ef          	jal	80002182 <sleep>
      acquire(&log.lock);
    80003f60:	8526                	mv	a0,s1
    80003f62:	cc7fc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80003f66:	509c                	lw	a5,32(s1)
    80003f68:	f7e5                	bnez	a5,80003f50 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003f6a:	4cd8                	lw	a4,28(s1)
    80003f6c:	2705                	addiw	a4,a4,1
    80003f6e:	0027179b          	slliw	a5,a4,0x2
    80003f72:	9fb9                	addw	a5,a5,a4
    80003f74:	0017979b          	slliw	a5,a5,0x1
    80003f78:	54d4                	lw	a3,44(s1)
    80003f7a:	9fb5                	addw	a5,a5,a3
    80003f7c:	00f95e63          	bge	s2,a5,80003f98 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003f80:	8526                	mv	a0,s1
    80003f82:	9c4fe0ef          	jal	80002146 <sleep_prepare>
      release(&log.lock);
    80003f86:	8526                	mv	a0,s1
    80003f88:	d29fc0ef          	jal	80000cb0 <release>
      sleep();
    80003f8c:	9f6fe0ef          	jal	80002182 <sleep>
      acquire(&log.lock);
    80003f90:	8526                	mv	a0,s1
    80003f92:	c97fc0ef          	jal	80000c28 <acquire>
    80003f96:	bfc1                	j	80003f66 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003f98:	0001e797          	auipc	a5,0x1e
    80003f9c:	76e7a623          	sw	a4,1900(a5) # 80022704 <log+0x1c>
      release(&log.lock);
    80003fa0:	0001e517          	auipc	a0,0x1e
    80003fa4:	74850513          	addi	a0,a0,1864 # 800226e8 <log>
    80003fa8:	d09fc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80003fac:	60e2                	ld	ra,24(sp)
    80003fae:	6442                	ld	s0,16(sp)
    80003fb0:	64a2                	ld	s1,8(sp)
    80003fb2:	6902                	ld	s2,0(sp)
    80003fb4:	6105                	addi	sp,sp,32
    80003fb6:	8082                	ret

0000000080003fb8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003fb8:	7139                	addi	sp,sp,-64
    80003fba:	fc06                	sd	ra,56(sp)
    80003fbc:	f822                	sd	s0,48(sp)
    80003fbe:	f426                	sd	s1,40(sp)
    80003fc0:	f04a                	sd	s2,32(sp)
    80003fc2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003fc4:	0001e497          	auipc	s1,0x1e
    80003fc8:	72448493          	addi	s1,s1,1828 # 800226e8 <log>
    80003fcc:	8526                	mv	a0,s1
    80003fce:	c5bfc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003fd2:	4cdc                	lw	a5,28(s1)
    80003fd4:	37fd                	addiw	a5,a5,-1
    80003fd6:	893e                	mv	s2,a5
    80003fd8:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003fda:	509c                	lw	a5,32(s1)
    80003fdc:	e3b1                	bnez	a5,80004020 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003fde:	04091a63          	bnez	s2,80004032 <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003fe2:	0001e497          	auipc	s1,0x1e
    80003fe6:	70648493          	addi	s1,s1,1798 # 800226e8 <log>
    80003fea:	4785                	li	a5,1
    80003fec:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003fee:	8526                	mv	a0,s1
    80003ff0:	cc1fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ff4:	54dc                	lw	a5,44(s1)
    80003ff6:	06f04063          	bgtz	a5,80004056 <end_op+0x9e>
    acquire(&log.lock);
    80003ffa:	0001e497          	auipc	s1,0x1e
    80003ffe:	6ee48493          	addi	s1,s1,1774 # 800226e8 <log>
    80004002:	8526                	mv	a0,s1
    80004004:	c25fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80004008:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    8000400c:	549c                	lw	a5,40(s1)
    8000400e:	2785                	addiw	a5,a5,1
    80004010:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80004012:	8526                	mv	a0,s1
    80004014:	99efe0ef          	jal	800021b2 <wakeup>
    release(&log.lock);
    80004018:	8526                	mv	a0,s1
    8000401a:	c97fc0ef          	jal	80000cb0 <release>
}
    8000401e:	a035                	j	8000404a <end_op+0x92>
    80004020:	ec4e                	sd	s3,24(sp)
    80004022:	e852                	sd	s4,16(sp)
    80004024:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004026:	00003517          	auipc	a0,0x3
    8000402a:	4fa50513          	addi	a0,a0,1274 # 80007520 <etext+0x520>
    8000402e:	807fc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80004032:	0001e517          	auipc	a0,0x1e
    80004036:	6b650513          	addi	a0,a0,1718 # 800226e8 <log>
    8000403a:	978fe0ef          	jal	800021b2 <wakeup>
  release(&log.lock);
    8000403e:	0001e517          	auipc	a0,0x1e
    80004042:	6aa50513          	addi	a0,a0,1706 # 800226e8 <log>
    80004046:	c6bfc0ef          	jal	80000cb0 <release>
}
    8000404a:	70e2                	ld	ra,56(sp)
    8000404c:	7442                	ld	s0,48(sp)
    8000404e:	74a2                	ld	s1,40(sp)
    80004050:	7902                	ld	s2,32(sp)
    80004052:	6121                	addi	sp,sp,64
    80004054:	8082                	ret
    80004056:	ec4e                	sd	s3,24(sp)
    80004058:	e852                	sd	s4,16(sp)
    8000405a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000405c:	0001ea97          	auipc	s5,0x1e
    80004060:	6bca8a93          	addi	s5,s5,1724 # 80022718 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80004064:	0001ea17          	auipc	s4,0x1e
    80004068:	684a0a13          	addi	s4,s4,1668 # 800226e8 <log>
    8000406c:	018a2583          	lw	a1,24(s4)
    80004070:	012585bb          	addw	a1,a1,s2
    80004074:	2585                	addiw	a1,a1,1
    80004076:	024a2503          	lw	a0,36(s4)
    8000407a:	da3fe0ef          	jal	80002e1c <bread>
    8000407e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004080:	000aa583          	lw	a1,0(s5)
    80004084:	024a2503          	lw	a0,36(s4)
    80004088:	d95fe0ef          	jal	80002e1c <bread>
    8000408c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000408e:	40000613          	li	a2,1024
    80004092:	05850593          	addi	a1,a0,88
    80004096:	05848513          	addi	a0,s1,88
    8000409a:	caffc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    8000409e:	8526                	mv	a0,s1
    800040a0:	e53fe0ef          	jal	80002ef2 <bwrite>
    brelse(from);
    800040a4:	854e                	mv	a0,s3
    800040a6:	e7ffe0ef          	jal	80002f24 <brelse>
    brelse(to);
    800040aa:	8526                	mv	a0,s1
    800040ac:	e79fe0ef          	jal	80002f24 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040b0:	2905                	addiw	s2,s2,1
    800040b2:	0a91                	addi	s5,s5,4
    800040b4:	02ca2783          	lw	a5,44(s4)
    800040b8:	faf94ae3          	blt	s2,a5,8000406c <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    800040bc:	cc5ff0ef          	jal	80003d80 <write_head>
    install_trans(0); // Now install writes to home locations
    800040c0:	4501                	li	a0,0
    800040c2:	d1dff0ef          	jal	80003dde <install_trans>
    log.lh.n = 0;
    800040c6:	0001e797          	auipc	a5,0x1e
    800040ca:	6407a723          	sw	zero,1614(a5) # 80022714 <log+0x2c>
    write_head(); // Erase the transaction from the log
    800040ce:	cb3ff0ef          	jal	80003d80 <write_head>
    800040d2:	69e2                	ld	s3,24(sp)
    800040d4:	6a42                	ld	s4,16(sp)
    800040d6:	6aa2                	ld	s5,8(sp)
    800040d8:	b70d                	j	80003ffa <end_op+0x42>

00000000800040da <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800040da:	1101                	addi	sp,sp,-32
    800040dc:	ec06                	sd	ra,24(sp)
    800040de:	e822                	sd	s0,16(sp)
    800040e0:	e426                	sd	s1,8(sp)
    800040e2:	1000                	addi	s0,sp,32
    800040e4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800040e6:	0001e517          	auipc	a0,0x1e
    800040ea:	60250513          	addi	a0,a0,1538 # 800226e8 <log>
    800040ee:	b3bfc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800040f2:	0001e617          	auipc	a2,0x1e
    800040f6:	62262603          	lw	a2,1570(a2) # 80022714 <log+0x2c>
    800040fa:	47f5                	li	a5,29
    800040fc:	04c7cd63          	blt	a5,a2,80004156 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004100:	0001e797          	auipc	a5,0x1e
    80004104:	6047a783          	lw	a5,1540(a5) # 80022704 <log+0x1c>
    80004108:	04f05d63          	blez	a5,80004162 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000410c:	4781                	li	a5,0
    8000410e:	06c05063          	blez	a2,8000416e <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80004112:	44cc                	lw	a1,12(s1)
    80004114:	0001e717          	auipc	a4,0x1e
    80004118:	60470713          	addi	a4,a4,1540 # 80022718 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000411c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    8000411e:	4314                	lw	a3,0(a4)
    80004120:	04b68763          	beq	a3,a1,8000416e <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80004124:	2785                	addiw	a5,a5,1
    80004126:	0711                	addi	a4,a4,4
    80004128:	fef61be3          	bne	a2,a5,8000411e <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000412c:	060a                	slli	a2,a2,0x2
    8000412e:	02060613          	addi	a2,a2,32
    80004132:	0001e797          	auipc	a5,0x1e
    80004136:	5b678793          	addi	a5,a5,1462 # 800226e8 <log>
    8000413a:	97b2                	add	a5,a5,a2
    8000413c:	44d8                	lw	a4,12(s1)
    8000413e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80004140:	8526                	mv	a0,s1
    80004142:	e67fe0ef          	jal	80002fa8 <bpin>
    log.lh.n++;
    80004146:	0001e717          	auipc	a4,0x1e
    8000414a:	5a270713          	addi	a4,a4,1442 # 800226e8 <log>
    8000414e:	575c                	lw	a5,44(a4)
    80004150:	2785                	addiw	a5,a5,1
    80004152:	d75c                	sw	a5,44(a4)
    80004154:	a815                	j	80004188 <log_write+0xae>
    panic("too big a transaction");
    80004156:	00003517          	auipc	a0,0x3
    8000415a:	3da50513          	addi	a0,a0,986 # 80007530 <etext+0x530>
    8000415e:	ed6fc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    80004162:	00003517          	auipc	a0,0x3
    80004166:	3e650513          	addi	a0,a0,998 # 80007548 <etext+0x548>
    8000416a:	ecafc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    8000416e:	00279693          	slli	a3,a5,0x2
    80004172:	02068693          	addi	a3,a3,32
    80004176:	0001e717          	auipc	a4,0x1e
    8000417a:	57270713          	addi	a4,a4,1394 # 800226e8 <log>
    8000417e:	9736                	add	a4,a4,a3
    80004180:	44d4                	lw	a3,12(s1)
    80004182:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80004184:	faf60ee3          	beq	a2,a5,80004140 <log_write+0x66>
  }
  release(&log.lock);
    80004188:	0001e517          	auipc	a0,0x1e
    8000418c:	56050513          	addi	a0,a0,1376 # 800226e8 <log>
    80004190:	b21fc0ef          	jal	80000cb0 <release>
}
    80004194:	60e2                	ld	ra,24(sp)
    80004196:	6442                	ld	s0,16(sp)
    80004198:	64a2                	ld	s1,8(sp)
    8000419a:	6105                	addi	sp,sp,32
    8000419c:	8082                	ret

000000008000419e <sys_sync>:

uint64
sys_sync(void)
{
    8000419e:	1101                	addi	sp,sp,-32
    800041a0:	ec06                	sd	ra,24(sp)
    800041a2:	e822                	sd	s0,16(sp)
    800041a4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800041a6:	0001e517          	auipc	a0,0x1e
    800041aa:	54250513          	addi	a0,a0,1346 # 800226e8 <log>
    800041ae:	a7bfc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    800041b2:	0001e797          	auipc	a5,0x1e
    800041b6:	5567a783          	lw	a5,1366(a5) # 80022708 <log+0x20>
    800041ba:	e799                	bnez	a5,800041c8 <sys_sync+0x2a>
    800041bc:	0001e797          	auipc	a5,0x1e
    800041c0:	5487a783          	lw	a5,1352(a5) # 80022704 <log+0x1c>
    800041c4:	02f05c63          	blez	a5,800041fc <sys_sync+0x5e>
    800041c8:	e426                	sd	s1,8(sp)
    800041ca:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    800041cc:	0001e917          	auipc	s2,0x1e
    800041d0:	54492903          	lw	s2,1348(s2) # 80022710 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    800041d4:	0001e497          	auipc	s1,0x1e
    800041d8:	51448493          	addi	s1,s1,1300 # 800226e8 <log>
    800041dc:	8526                	mv	a0,s1
    800041de:	f69fd0ef          	jal	80002146 <sleep_prepare>
      release(&log.lock);
    800041e2:	8526                	mv	a0,s1
    800041e4:	acdfc0ef          	jal	80000cb0 <release>
      sleep();
    800041e8:	f9bfd0ef          	jal	80002182 <sleep>
      acquire(&log.lock);
    800041ec:	8526                	mv	a0,s1
    800041ee:	a3bfc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    800041f2:	549c                	lw	a5,40(s1)
    800041f4:	fef954e3          	bge	s2,a5,800041dc <sys_sync+0x3e>
    800041f8:	64a2                	ld	s1,8(sp)
    800041fa:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    800041fc:	0001e517          	auipc	a0,0x1e
    80004200:	4ec50513          	addi	a0,a0,1260 # 800226e8 <log>
    80004204:	aadfc0ef          	jal	80000cb0 <release>
  return 0;
}
    80004208:	4501                	li	a0,0
    8000420a:	60e2                	ld	ra,24(sp)
    8000420c:	6442                	ld	s0,16(sp)
    8000420e:	6105                	addi	sp,sp,32
    80004210:	8082                	ret

0000000080004212 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004212:	1101                	addi	sp,sp,-32
    80004214:	ec06                	sd	ra,24(sp)
    80004216:	e822                	sd	s0,16(sp)
    80004218:	e426                	sd	s1,8(sp)
    8000421a:	e04a                	sd	s2,0(sp)
    8000421c:	1000                	addi	s0,sp,32
    8000421e:	84aa                	mv	s1,a0
    80004220:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004222:	00003597          	auipc	a1,0x3
    80004226:	34658593          	addi	a1,a1,838 # 80007568 <etext+0x568>
    8000422a:	0521                	addi	a0,a0,8
    8000422c:	97dfc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    80004230:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004234:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004238:	0204a423          	sw	zero,40(s1)
}
    8000423c:	60e2                	ld	ra,24(sp)
    8000423e:	6442                	ld	s0,16(sp)
    80004240:	64a2                	ld	s1,8(sp)
    80004242:	6902                	ld	s2,0(sp)
    80004244:	6105                	addi	sp,sp,32
    80004246:	8082                	ret

0000000080004248 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004248:	1101                	addi	sp,sp,-32
    8000424a:	ec06                	sd	ra,24(sp)
    8000424c:	e822                	sd	s0,16(sp)
    8000424e:	e426                	sd	s1,8(sp)
    80004250:	e04a                	sd	s2,0(sp)
    80004252:	1000                	addi	s0,sp,32
    80004254:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004256:	00850913          	addi	s2,a0,8
    8000425a:	854a                	mv	a0,s2
    8000425c:	9cdfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004260:	409c                	lw	a5,0(s1)
    80004262:	cf91                	beqz	a5,8000427e <acquiresleep+0x36>
    sleep_prepare(lk);
    80004264:	8526                	mv	a0,s1
    80004266:	ee1fd0ef          	jal	80002146 <sleep_prepare>
    release(&lk->lk);
    8000426a:	854a                	mv	a0,s2
    8000426c:	a45fc0ef          	jal	80000cb0 <release>
    sleep();
    80004270:	f13fd0ef          	jal	80002182 <sleep>
    acquire(&lk->lk);
    80004274:	854a                	mv	a0,s2
    80004276:	9b3fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    8000427a:	409c                	lw	a5,0(s1)
    8000427c:	f7e5                	bnez	a5,80004264 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000427e:	4785                	li	a5,1
    80004280:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004282:	ec6fd0ef          	jal	80001948 <myproc>
    80004286:	591c                	lw	a5,48(a0)
    80004288:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000428a:	854a                	mv	a0,s2
    8000428c:	a25fc0ef          	jal	80000cb0 <release>
}
    80004290:	60e2                	ld	ra,24(sp)
    80004292:	6442                	ld	s0,16(sp)
    80004294:	64a2                	ld	s1,8(sp)
    80004296:	6902                	ld	s2,0(sp)
    80004298:	6105                	addi	sp,sp,32
    8000429a:	8082                	ret

000000008000429c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000429c:	1101                	addi	sp,sp,-32
    8000429e:	ec06                	sd	ra,24(sp)
    800042a0:	e822                	sd	s0,16(sp)
    800042a2:	e426                	sd	s1,8(sp)
    800042a4:	e04a                	sd	s2,0(sp)
    800042a6:	1000                	addi	s0,sp,32
    800042a8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042aa:	00850913          	addi	s2,a0,8
    800042ae:	854a                	mv	a0,s2
    800042b0:	979fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    800042b4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042b8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800042bc:	8526                	mv	a0,s1
    800042be:	ef5fd0ef          	jal	800021b2 <wakeup>
  release(&lk->lk);
    800042c2:	854a                	mv	a0,s2
    800042c4:	9edfc0ef          	jal	80000cb0 <release>
}
    800042c8:	60e2                	ld	ra,24(sp)
    800042ca:	6442                	ld	s0,16(sp)
    800042cc:	64a2                	ld	s1,8(sp)
    800042ce:	6902                	ld	s2,0(sp)
    800042d0:	6105                	addi	sp,sp,32
    800042d2:	8082                	ret

00000000800042d4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800042d4:	7179                	addi	sp,sp,-48
    800042d6:	f406                	sd	ra,40(sp)
    800042d8:	f022                	sd	s0,32(sp)
    800042da:	ec26                	sd	s1,24(sp)
    800042dc:	e84a                	sd	s2,16(sp)
    800042de:	1800                	addi	s0,sp,48
    800042e0:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800042e2:	00850913          	addi	s2,a0,8
    800042e6:	854a                	mv	a0,s2
    800042e8:	941fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800042ec:	409c                	lw	a5,0(s1)
    800042ee:	ef81                	bnez	a5,80004306 <holdingsleep+0x32>
    800042f0:	4481                	li	s1,0
  release(&lk->lk);
    800042f2:	854a                	mv	a0,s2
    800042f4:	9bdfc0ef          	jal	80000cb0 <release>
  return r;
}
    800042f8:	8526                	mv	a0,s1
    800042fa:	70a2                	ld	ra,40(sp)
    800042fc:	7402                	ld	s0,32(sp)
    800042fe:	64e2                	ld	s1,24(sp)
    80004300:	6942                	ld	s2,16(sp)
    80004302:	6145                	addi	sp,sp,48
    80004304:	8082                	ret
    80004306:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004308:	0284a983          	lw	s3,40(s1)
    8000430c:	e3cfd0ef          	jal	80001948 <myproc>
    80004310:	5904                	lw	s1,48(a0)
    80004312:	413484b3          	sub	s1,s1,s3
    80004316:	0014b493          	seqz	s1,s1
    8000431a:	69a2                	ld	s3,8(sp)
    8000431c:	bfd9                	j	800042f2 <holdingsleep+0x1e>

000000008000431e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000431e:	1141                	addi	sp,sp,-16
    80004320:	e406                	sd	ra,8(sp)
    80004322:	e022                	sd	s0,0(sp)
    80004324:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004326:	00003597          	auipc	a1,0x3
    8000432a:	25258593          	addi	a1,a1,594 # 80007578 <etext+0x578>
    8000432e:	0001e517          	auipc	a0,0x1e
    80004332:	50250513          	addi	a0,a0,1282 # 80022830 <ftable>
    80004336:	873fc0ef          	jal	80000ba8 <initlock>
}
    8000433a:	60a2                	ld	ra,8(sp)
    8000433c:	6402                	ld	s0,0(sp)
    8000433e:	0141                	addi	sp,sp,16
    80004340:	8082                	ret

0000000080004342 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80004342:	1101                	addi	sp,sp,-32
    80004344:	ec06                	sd	ra,24(sp)
    80004346:	e822                	sd	s0,16(sp)
    80004348:	e426                	sd	s1,8(sp)
    8000434a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000434c:	0001e517          	auipc	a0,0x1e
    80004350:	4e450513          	addi	a0,a0,1252 # 80022830 <ftable>
    80004354:	8d5fc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004358:	0001e497          	auipc	s1,0x1e
    8000435c:	4f048493          	addi	s1,s1,1264 # 80022848 <ftable+0x18>
    80004360:	0001f717          	auipc	a4,0x1f
    80004364:	48870713          	addi	a4,a4,1160 # 800237e8 <disk>
    if (f->ref == 0) {
    80004368:	40dc                	lw	a5,4(s1)
    8000436a:	cf89                	beqz	a5,80004384 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    8000436c:	02848493          	addi	s1,s1,40
    80004370:	fee49ce3          	bne	s1,a4,80004368 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004374:	0001e517          	auipc	a0,0x1e
    80004378:	4bc50513          	addi	a0,a0,1212 # 80022830 <ftable>
    8000437c:	935fc0ef          	jal	80000cb0 <release>
  return 0;
    80004380:	4481                	li	s1,0
    80004382:	a809                	j	80004394 <filealloc+0x52>
      f->ref = 1;
    80004384:	4785                	li	a5,1
    80004386:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004388:	0001e517          	auipc	a0,0x1e
    8000438c:	4a850513          	addi	a0,a0,1192 # 80022830 <ftable>
    80004390:	921fc0ef          	jal	80000cb0 <release>
}
    80004394:	8526                	mv	a0,s1
    80004396:	60e2                	ld	ra,24(sp)
    80004398:	6442                	ld	s0,16(sp)
    8000439a:	64a2                	ld	s1,8(sp)
    8000439c:	6105                	addi	sp,sp,32
    8000439e:	8082                	ret

00000000800043a0 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    800043a0:	1101                	addi	sp,sp,-32
    800043a2:	ec06                	sd	ra,24(sp)
    800043a4:	e822                	sd	s0,16(sp)
    800043a6:	e426                	sd	s1,8(sp)
    800043a8:	1000                	addi	s0,sp,32
    800043aa:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800043ac:	0001e517          	auipc	a0,0x1e
    800043b0:	48450513          	addi	a0,a0,1156 # 80022830 <ftable>
    800043b4:	875fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800043b8:	40dc                	lw	a5,4(s1)
    800043ba:	02f05063          	blez	a5,800043da <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800043be:	2785                	addiw	a5,a5,1
    800043c0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800043c2:	0001e517          	auipc	a0,0x1e
    800043c6:	46e50513          	addi	a0,a0,1134 # 80022830 <ftable>
    800043ca:	8e7fc0ef          	jal	80000cb0 <release>
  return f;
}
    800043ce:	8526                	mv	a0,s1
    800043d0:	60e2                	ld	ra,24(sp)
    800043d2:	6442                	ld	s0,16(sp)
    800043d4:	64a2                	ld	s1,8(sp)
    800043d6:	6105                	addi	sp,sp,32
    800043d8:	8082                	ret
    panic("filedup");
    800043da:	00003517          	auipc	a0,0x3
    800043de:	1a650513          	addi	a0,a0,422 # 80007580 <etext+0x580>
    800043e2:	c52fc0ef          	jal	80000834 <panic>

00000000800043e6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800043e6:	7139                	addi	sp,sp,-64
    800043e8:	fc06                	sd	ra,56(sp)
    800043ea:	f822                	sd	s0,48(sp)
    800043ec:	f426                	sd	s1,40(sp)
    800043ee:	0080                	addi	s0,sp,64
    800043f0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800043f2:	0001e517          	auipc	a0,0x1e
    800043f6:	43e50513          	addi	a0,a0,1086 # 80022830 <ftable>
    800043fa:	82ffc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800043fe:	40dc                	lw	a5,4(s1)
    80004400:	04f05a63          	blez	a5,80004454 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    80004404:	37fd                	addiw	a5,a5,-1
    80004406:	c0dc                	sw	a5,4(s1)
    80004408:	06f04063          	bgtz	a5,80004468 <fileclose+0x82>
    8000440c:	f04a                	sd	s2,32(sp)
    8000440e:	ec4e                	sd	s3,24(sp)
    80004410:	e852                	sd	s4,16(sp)
    80004412:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004414:	0004a903          	lw	s2,0(s1)
    80004418:	0094c783          	lbu	a5,9(s1)
    8000441c:	89be                	mv	s3,a5
    8000441e:	689c                	ld	a5,16(s1)
    80004420:	8a3e                	mv	s4,a5
    80004422:	6c9c                	ld	a5,24(s1)
    80004424:	8abe                	mv	s5,a5
  f->ref = 0;
    80004426:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000442a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000442e:	0001e517          	auipc	a0,0x1e
    80004432:	40250513          	addi	a0,a0,1026 # 80022830 <ftable>
    80004436:	87bfc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    8000443a:	4785                	li	a5,1
    8000443c:	04f90163          	beq	s2,a5,8000447e <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    80004440:	ffe9079b          	addiw	a5,s2,-2
    80004444:	4705                	li	a4,1
    80004446:	04f77563          	bgeu	a4,a5,80004490 <fileclose+0xaa>
    8000444a:	7902                	ld	s2,32(sp)
    8000444c:	69e2                	ld	s3,24(sp)
    8000444e:	6a42                	ld	s4,16(sp)
    80004450:	6aa2                	ld	s5,8(sp)
    80004452:	a00d                	j	80004474 <fileclose+0x8e>
    80004454:	f04a                	sd	s2,32(sp)
    80004456:	ec4e                	sd	s3,24(sp)
    80004458:	e852                	sd	s4,16(sp)
    8000445a:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000445c:	00003517          	auipc	a0,0x3
    80004460:	12c50513          	addi	a0,a0,300 # 80007588 <etext+0x588>
    80004464:	bd0fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    80004468:	0001e517          	auipc	a0,0x1e
    8000446c:	3c850513          	addi	a0,a0,968 # 80022830 <ftable>
    80004470:	841fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004474:	70e2                	ld	ra,56(sp)
    80004476:	7442                	ld	s0,48(sp)
    80004478:	74a2                	ld	s1,40(sp)
    8000447a:	6121                	addi	sp,sp,64
    8000447c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000447e:	85ce                	mv	a1,s3
    80004480:	8552                	mv	a0,s4
    80004482:	36a000ef          	jal	800047ec <pipeclose>
    80004486:	7902                	ld	s2,32(sp)
    80004488:	69e2                	ld	s3,24(sp)
    8000448a:	6a42                	ld	s4,16(sp)
    8000448c:	6aa2                	ld	s5,8(sp)
    8000448e:	b7dd                	j	80004474 <fileclose+0x8e>
    begin_op();
    80004490:	a9dff0ef          	jal	80003f2c <begin_op>
    iput(ff.ip);
    80004494:	8556                	mv	a0,s5
    80004496:	9a0ff0ef          	jal	80003636 <iput>
    end_op();
    8000449a:	b1fff0ef          	jal	80003fb8 <end_op>
    8000449e:	7902                	ld	s2,32(sp)
    800044a0:	69e2                	ld	s3,24(sp)
    800044a2:	6a42                	ld	s4,16(sp)
    800044a4:	6aa2                	ld	s5,8(sp)
    800044a6:	b7f9                	j	80004474 <fileclose+0x8e>

00000000800044a8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800044a8:	715d                	addi	sp,sp,-80
    800044aa:	e486                	sd	ra,72(sp)
    800044ac:	e0a2                	sd	s0,64(sp)
    800044ae:	fc26                	sd	s1,56(sp)
    800044b0:	f052                	sd	s4,32(sp)
    800044b2:	0880                	addi	s0,sp,80
    800044b4:	84aa                	mv	s1,a0
    800044b6:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800044b8:	c90fd0ef          	jal	80001948 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    800044bc:	409c                	lw	a5,0(s1)
    800044be:	37f9                	addiw	a5,a5,-2
    800044c0:	4705                	li	a4,1
    800044c2:	04f76963          	bltu	a4,a5,80004514 <filestat+0x6c>
    800044c6:	f84a                	sd	s2,48(sp)
    800044c8:	f44e                	sd	s3,40(sp)
    800044ca:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    800044cc:	fb840993          	addi	s3,s0,-72
    800044d0:	4661                	li	a2,24
    800044d2:	4581                	li	a1,0
    800044d4:	854e                	mv	a0,s3
    800044d6:	813fc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    800044da:	6c88                	ld	a0,24(s1)
    800044dc:	fd9fe0ef          	jal	800034b4 <ilock>
    stati(f->ip, &st);
    800044e0:	85ce                	mv	a1,s3
    800044e2:	6c88                	ld	a0,24(s1)
    800044e4:	b7cff0ef          	jal	80003860 <stati>
    iunlock(f->ip);
    800044e8:	6c88                	ld	a0,24(s1)
    800044ea:	878ff0ef          	jal	80003562 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    800044ee:	4761                	li	a4,24
    800044f0:	86ce                	mv	a3,s3
    800044f2:	8652                	mv	a2,s4
    800044f4:	04893583          	ld	a1,72(s2)
    800044f8:	05093503          	ld	a0,80(s2)
    800044fc:	886fd0ef          	jal	80001582 <copyout>
    80004500:	41f5551b          	sraiw	a0,a0,0x1f
    80004504:	7942                	ld	s2,48(sp)
    80004506:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004508:	60a6                	ld	ra,72(sp)
    8000450a:	6406                	ld	s0,64(sp)
    8000450c:	74e2                	ld	s1,56(sp)
    8000450e:	7a02                	ld	s4,32(sp)
    80004510:	6161                	addi	sp,sp,80
    80004512:	8082                	ret
  return -1;
    80004514:	557d                	li	a0,-1
    80004516:	bfcd                	j	80004508 <filestat+0x60>

0000000080004518 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004518:	7179                	addi	sp,sp,-48
    8000451a:	f406                	sd	ra,40(sp)
    8000451c:	f022                	sd	s0,32(sp)
    8000451e:	e84a                	sd	s2,16(sp)
    80004520:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    80004522:	00854783          	lbu	a5,8(a0)
    80004526:	c3dd                	beqz	a5,800045cc <fileread+0xb4>
    80004528:	ec26                	sd	s1,24(sp)
    8000452a:	e44e                	sd	s3,8(sp)
    8000452c:	84aa                	mv	s1,a0
    8000452e:	892e                	mv	s2,a1
    80004530:	89b2                	mv	s3,a2
    80004532:	01f6579b          	srliw	a5,a2,0x1f
    80004536:	ebc9                	bnez	a5,800045c8 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    80004538:	411c                	lw	a5,0(a0)
    8000453a:	4705                	li	a4,1
    8000453c:	04e78363          	beq	a5,a4,80004582 <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004540:	470d                	li	a4,3
    80004542:	04e78763          	beq	a5,a4,80004590 <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004546:	4709                	li	a4,2
    80004548:	06e79a63          	bne	a5,a4,800045bc <fileread+0xa4>
    ilock(f->ip);
    8000454c:	6d08                	ld	a0,24(a0)
    8000454e:	f67fe0ef          	jal	800034b4 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004552:	874e                	mv	a4,s3
    80004554:	5094                	lw	a3,32(s1)
    80004556:	864a                	mv	a2,s2
    80004558:	4585                	li	a1,1
    8000455a:	6c88                	ld	a0,24(s1)
    8000455c:	b32ff0ef          	jal	8000388e <readi>
    80004560:	892a                	mv	s2,a0
    80004562:	00a05563          	blez	a0,8000456c <fileread+0x54>
      f->off += r;
    80004566:	509c                	lw	a5,32(s1)
    80004568:	9fa9                	addw	a5,a5,a0
    8000456a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000456c:	6c88                	ld	a0,24(s1)
    8000456e:	ff5fe0ef          	jal	80003562 <iunlock>
    80004572:	64e2                	ld	s1,24(sp)
    80004574:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004576:	854a                	mv	a0,s2
    80004578:	70a2                	ld	ra,40(sp)
    8000457a:	7402                	ld	s0,32(sp)
    8000457c:	6942                	ld	s2,16(sp)
    8000457e:	6145                	addi	sp,sp,48
    80004580:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004582:	6908                	ld	a0,16(a0)
    80004584:	3e2000ef          	jal	80004966 <piperead>
    80004588:	892a                	mv	s2,a0
    8000458a:	64e2                	ld	s1,24(sp)
    8000458c:	69a2                	ld	s3,8(sp)
    8000458e:	b7e5                	j	80004576 <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004590:	02451783          	lh	a5,36(a0)
    80004594:	03079693          	slli	a3,a5,0x30
    80004598:	92c1                	srli	a3,a3,0x30
    8000459a:	4725                	li	a4,9
    8000459c:	02d76b63          	bltu	a4,a3,800045d2 <fileread+0xba>
    800045a0:	0792                	slli	a5,a5,0x4
    800045a2:	0001e717          	auipc	a4,0x1e
    800045a6:	1ee70713          	addi	a4,a4,494 # 80022790 <devsw>
    800045aa:	97ba                	add	a5,a5,a4
    800045ac:	639c                	ld	a5,0(a5)
    800045ae:	c79d                	beqz	a5,800045dc <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    800045b0:	4505                	li	a0,1
    800045b2:	9782                	jalr	a5
    800045b4:	892a                	mv	s2,a0
    800045b6:	64e2                	ld	s1,24(sp)
    800045b8:	69a2                	ld	s3,8(sp)
    800045ba:	bf75                	j	80004576 <fileread+0x5e>
    panic("fileread");
    800045bc:	00003517          	auipc	a0,0x3
    800045c0:	fdc50513          	addi	a0,a0,-36 # 80007598 <etext+0x598>
    800045c4:	a70fc0ef          	jal	80000834 <panic>
    800045c8:	64e2                	ld	s1,24(sp)
    800045ca:	69a2                	ld	s3,8(sp)
    return -1;
    800045cc:	57fd                	li	a5,-1
    800045ce:	893e                	mv	s2,a5
    800045d0:	b75d                	j	80004576 <fileread+0x5e>
      return -1;
    800045d2:	57fd                	li	a5,-1
    800045d4:	893e                	mv	s2,a5
    800045d6:	64e2                	ld	s1,24(sp)
    800045d8:	69a2                	ld	s3,8(sp)
    800045da:	bf71                	j	80004576 <fileread+0x5e>
    800045dc:	57fd                	li	a5,-1
    800045de:	893e                	mv	s2,a5
    800045e0:	64e2                	ld	s1,24(sp)
    800045e2:	69a2                	ld	s3,8(sp)
    800045e4:	bf49                	j	80004576 <fileread+0x5e>

00000000800045e6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    800045e6:	00954783          	lbu	a5,9(a0)
    800045ea:	12078b63          	beqz	a5,80004720 <filewrite+0x13a>
{
    800045ee:	711d                	addi	sp,sp,-96
    800045f0:	ec86                	sd	ra,88(sp)
    800045f2:	e8a2                	sd	s0,80(sp)
    800045f4:	e0ca                	sd	s2,64(sp)
    800045f6:	f456                	sd	s5,40(sp)
    800045f8:	f05a                	sd	s6,32(sp)
    800045fa:	1080                	addi	s0,sp,96
    800045fc:	892a                	mv	s2,a0
    800045fe:	8b2e                	mv	s6,a1
    80004600:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    80004602:	01f6579b          	srliw	a5,a2,0x1f
    80004606:	0e079d63          	bnez	a5,80004700 <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    8000460a:	411c                	lw	a5,0(a0)
    8000460c:	4705                	li	a4,1
    8000460e:	02e78a63          	beq	a5,a4,80004642 <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004612:	470d                	li	a4,3
    80004614:	02e78b63          	beq	a5,a4,8000464a <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004618:	4709                	li	a4,2
    8000461a:	0ce79763          	bne	a5,a4,800046e8 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    8000461e:	0ec05763          	blez	a2,8000470c <filewrite+0x126>
    80004622:	e4a6                	sd	s1,72(sp)
    80004624:	fc4e                	sd	s3,56(sp)
    80004626:	f852                	sd	s4,48(sp)
    80004628:	ec5e                	sd	s7,24(sp)
    8000462a:	e862                	sd	s8,16(sp)
    8000462c:	e466                	sd	s9,8(sp)
    int i = 0;
    8000462e:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    80004630:	6b85                	lui	s7,0x1
    80004632:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004636:	6785                	lui	a5,0x1
    80004638:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    8000463c:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000463e:	4c05                	li	s8,1
    80004640:	a8ad                	j	800046ba <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    80004642:	6908                	ld	a0,16(a0)
    80004644:	206000ef          	jal	8000484a <pipewrite>
    80004648:	a849                	j	800046da <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000464a:	02451783          	lh	a5,36(a0)
    8000464e:	03079693          	slli	a3,a5,0x30
    80004652:	92c1                	srli	a3,a3,0x30
    80004654:	4725                	li	a4,9
    80004656:	0ad76763          	bltu	a4,a3,80004704 <filewrite+0x11e>
    8000465a:	0792                	slli	a5,a5,0x4
    8000465c:	0001e717          	auipc	a4,0x1e
    80004660:	13470713          	addi	a4,a4,308 # 80022790 <devsw>
    80004664:	97ba                	add	a5,a5,a4
    80004666:	679c                	ld	a5,8(a5)
    80004668:	c3c5                	beqz	a5,80004708 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000466a:	4505                	li	a0,1
    8000466c:	9782                	jalr	a5
    8000466e:	a0b5                	j	800046da <filewrite+0xf4>
      if (n1 > max)
    80004670:	2981                	sext.w	s3,s3
      begin_op();
    80004672:	8bbff0ef          	jal	80003f2c <begin_op>
      ilock(f->ip);
    80004676:	01893503          	ld	a0,24(s2)
    8000467a:	e3bfe0ef          	jal	800034b4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000467e:	874e                	mv	a4,s3
    80004680:	02092683          	lw	a3,32(s2)
    80004684:	016a0633          	add	a2,s4,s6
    80004688:	85e2                	mv	a1,s8
    8000468a:	01893503          	ld	a0,24(s2)
    8000468e:	af2ff0ef          	jal	80003980 <writei>
    80004692:	84aa                	mv	s1,a0
    80004694:	00a05763          	blez	a0,800046a2 <filewrite+0xbc>
        f->off += r;
    80004698:	02092783          	lw	a5,32(s2)
    8000469c:	9fa9                	addw	a5,a5,a0
    8000469e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800046a2:	01893503          	ld	a0,24(s2)
    800046a6:	ebdfe0ef          	jal	80003562 <iunlock>
      end_op();
    800046aa:	90fff0ef          	jal	80003fb8 <end_op>

      if (r != n1) {
    800046ae:	00999d63          	bne	s3,s1,800046c8 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    800046b2:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    800046b6:	015a5963          	bge	s4,s5,800046c8 <filewrite+0xe2>
      int n1 = n - i;
    800046ba:	414a87bb          	subw	a5,s5,s4
    800046be:	89be                	mv	s3,a5
      if (n1 > max)
    800046c0:	fafbd8e3          	bge	s7,a5,80004670 <filewrite+0x8a>
    800046c4:	89e6                	mv	s3,s9
    800046c6:	b76d                	j	80004670 <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    800046c8:	054a9463          	bne	s5,s4,80004710 <filewrite+0x12a>
    800046cc:	8556                	mv	a0,s5
    800046ce:	64a6                	ld	s1,72(sp)
    800046d0:	79e2                	ld	s3,56(sp)
    800046d2:	7a42                	ld	s4,48(sp)
    800046d4:	6be2                	ld	s7,24(sp)
    800046d6:	6c42                	ld	s8,16(sp)
    800046d8:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800046da:	60e6                	ld	ra,88(sp)
    800046dc:	6446                	ld	s0,80(sp)
    800046de:	6906                	ld	s2,64(sp)
    800046e0:	7aa2                	ld	s5,40(sp)
    800046e2:	7b02                	ld	s6,32(sp)
    800046e4:	6125                	addi	sp,sp,96
    800046e6:	8082                	ret
    800046e8:	e4a6                	sd	s1,72(sp)
    800046ea:	fc4e                	sd	s3,56(sp)
    800046ec:	f852                	sd	s4,48(sp)
    800046ee:	ec5e                	sd	s7,24(sp)
    800046f0:	e862                	sd	s8,16(sp)
    800046f2:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800046f4:	00003517          	auipc	a0,0x3
    800046f8:	eb450513          	addi	a0,a0,-332 # 800075a8 <etext+0x5a8>
    800046fc:	938fc0ef          	jal	80000834 <panic>
    return -1;
    80004700:	557d                	li	a0,-1
    80004702:	bfe1                	j	800046da <filewrite+0xf4>
      return -1;
    80004704:	557d                	li	a0,-1
    80004706:	bfd1                	j	800046da <filewrite+0xf4>
    80004708:	557d                	li	a0,-1
    8000470a:	bfc1                	j	800046da <filewrite+0xf4>
    ret = (i == n ? n : -1);
    8000470c:	8532                	mv	a0,a2
    8000470e:	b7f1                	j	800046da <filewrite+0xf4>
    80004710:	557d                	li	a0,-1
    80004712:	64a6                	ld	s1,72(sp)
    80004714:	79e2                	ld	s3,56(sp)
    80004716:	7a42                	ld	s4,48(sp)
    80004718:	6be2                	ld	s7,24(sp)
    8000471a:	6c42                	ld	s8,16(sp)
    8000471c:	6ca2                	ld	s9,8(sp)
    8000471e:	bf75                	j	800046da <filewrite+0xf4>
    return -1;
    80004720:	557d                	li	a0,-1
}
    80004722:	8082                	ret

0000000080004724 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004724:	7179                	addi	sp,sp,-48
    80004726:	f406                	sd	ra,40(sp)
    80004728:	f022                	sd	s0,32(sp)
    8000472a:	ec26                	sd	s1,24(sp)
    8000472c:	e052                	sd	s4,0(sp)
    8000472e:	1800                	addi	s0,sp,48
    80004730:	84aa                	mv	s1,a0
    80004732:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004734:	0005b023          	sd	zero,0(a1)
    80004738:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000473c:	c07ff0ef          	jal	80004342 <filealloc>
    80004740:	e088                	sd	a0,0(s1)
    80004742:	c549                	beqz	a0,800047cc <pipealloc+0xa8>
    80004744:	bffff0ef          	jal	80004342 <filealloc>
    80004748:	00aa3023          	sd	a0,0(s4)
    8000474c:	cd25                	beqz	a0,800047c4 <pipealloc+0xa0>
    8000474e:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004750:	bfefc0ef          	jal	80000b4e <kalloc>
    80004754:	892a                	mv	s2,a0
    80004756:	c12d                	beqz	a0,800047b8 <pipealloc+0x94>
    80004758:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000475a:	4985                	li	s3,1
    8000475c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004760:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004764:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004768:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000476c:	00003597          	auipc	a1,0x3
    80004770:	e4c58593          	addi	a1,a1,-436 # 800075b8 <etext+0x5b8>
    80004774:	c34fc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004778:	609c                	ld	a5,0(s1)
    8000477a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000477e:	609c                	ld	a5,0(s1)
    80004780:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004784:	609c                	ld	a5,0(s1)
    80004786:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000478a:	609c                	ld	a5,0(s1)
    8000478c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004790:	000a3783          	ld	a5,0(s4)
    80004794:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004798:	000a3783          	ld	a5,0(s4)
    8000479c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800047a0:	000a3783          	ld	a5,0(s4)
    800047a4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800047a8:	000a3783          	ld	a5,0(s4)
    800047ac:	0127b823          	sd	s2,16(a5)
  return 0;
    800047b0:	4501                	li	a0,0
    800047b2:	6942                	ld	s2,16(sp)
    800047b4:	69a2                	ld	s3,8(sp)
    800047b6:	a01d                	j	800047dc <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    800047b8:	6088                	ld	a0,0(s1)
    800047ba:	c119                	beqz	a0,800047c0 <pipealloc+0x9c>
    800047bc:	6942                	ld	s2,16(sp)
    800047be:	a029                	j	800047c8 <pipealloc+0xa4>
    800047c0:	6942                	ld	s2,16(sp)
    800047c2:	a029                	j	800047cc <pipealloc+0xa8>
    800047c4:	6088                	ld	a0,0(s1)
    800047c6:	c10d                	beqz	a0,800047e8 <pipealloc+0xc4>
    fileclose(*f0);
    800047c8:	c1fff0ef          	jal	800043e6 <fileclose>
  if (*f1)
    800047cc:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800047d0:	557d                	li	a0,-1
  if (*f1)
    800047d2:	c789                	beqz	a5,800047dc <pipealloc+0xb8>
    fileclose(*f1);
    800047d4:	853e                	mv	a0,a5
    800047d6:	c11ff0ef          	jal	800043e6 <fileclose>
  return -1;
    800047da:	557d                	li	a0,-1
}
    800047dc:	70a2                	ld	ra,40(sp)
    800047de:	7402                	ld	s0,32(sp)
    800047e0:	64e2                	ld	s1,24(sp)
    800047e2:	6a02                	ld	s4,0(sp)
    800047e4:	6145                	addi	sp,sp,48
    800047e6:	8082                	ret
  return -1;
    800047e8:	557d                	li	a0,-1
    800047ea:	bfcd                	j	800047dc <pipealloc+0xb8>

00000000800047ec <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800047ec:	1101                	addi	sp,sp,-32
    800047ee:	ec06                	sd	ra,24(sp)
    800047f0:	e822                	sd	s0,16(sp)
    800047f2:	e426                	sd	s1,8(sp)
    800047f4:	e04a                	sd	s2,0(sp)
    800047f6:	1000                	addi	s0,sp,32
    800047f8:	84aa                	mv	s1,a0
    800047fa:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800047fc:	c2cfc0ef          	jal	80000c28 <acquire>
  if (writable) {
    80004800:	02090763          	beqz	s2,8000482e <pipeclose+0x42>
    pi->writeopen = 0;
    80004804:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004808:	21848513          	addi	a0,s1,536
    8000480c:	9a7fd0ef          	jal	800021b2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004810:	2204a783          	lw	a5,544(s1)
    80004814:	e781                	bnez	a5,8000481c <pipeclose+0x30>
    80004816:	2244a783          	lw	a5,548(s1)
    8000481a:	c38d                	beqz	a5,8000483c <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    8000481c:	8526                	mv	a0,s1
    8000481e:	c92fc0ef          	jal	80000cb0 <release>
}
    80004822:	60e2                	ld	ra,24(sp)
    80004824:	6442                	ld	s0,16(sp)
    80004826:	64a2                	ld	s1,8(sp)
    80004828:	6902                	ld	s2,0(sp)
    8000482a:	6105                	addi	sp,sp,32
    8000482c:	8082                	ret
    pi->readopen = 0;
    8000482e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004832:	21c48513          	addi	a0,s1,540
    80004836:	97dfd0ef          	jal	800021b2 <wakeup>
    8000483a:	bfd9                	j	80004810 <pipeclose+0x24>
    release(&pi->lock);
    8000483c:	8526                	mv	a0,s1
    8000483e:	c72fc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    80004842:	8526                	mv	a0,s1
    80004844:	a22fc0ef          	jal	80000a66 <kfree>
    80004848:	bfe9                	j	80004822 <pipeclose+0x36>

000000008000484a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000484a:	7159                	addi	sp,sp,-112
    8000484c:	f486                	sd	ra,104(sp)
    8000484e:	f0a2                	sd	s0,96(sp)
    80004850:	eca6                	sd	s1,88(sp)
    80004852:	e8ca                	sd	s2,80(sp)
    80004854:	e4ce                	sd	s3,72(sp)
    80004856:	e0d2                	sd	s4,64(sp)
    80004858:	fc56                	sd	s5,56(sp)
    8000485a:	1880                	addi	s0,sp,112
    8000485c:	84aa                	mv	s1,a0
    8000485e:	8aae                	mv	s5,a1
    80004860:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004862:	8e6fd0ef          	jal	80001948 <myproc>
    80004866:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004868:	8526                	mv	a0,s1
    8000486a:	bbefc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    8000486e:	0f405a63          	blez	s4,80004962 <pipewrite+0x118>
    80004872:	f85a                	sd	s6,48(sp)
    80004874:	f45e                	sd	s7,40(sp)
    80004876:	f062                	sd	s8,32(sp)
    80004878:	ec66                	sd	s9,24(sp)
    8000487a:	e86a                	sd	s10,16(sp)
  int i = 0;
    8000487c:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    8000487e:	f9f40c13          	addi	s8,s0,-97
    80004882:	4b85                	li	s7,1
    80004884:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004886:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    8000488a:	21c48c93          	addi	s9,s1,540
    8000488e:	a0a1                	j	800048d6 <pipewrite+0x8c>
      release(&pi->lock);
    80004890:	8526                	mv	a0,s1
    80004892:	c1efc0ef          	jal	80000cb0 <release>
      return -1;
    80004896:	597d                	li	s2,-1
    80004898:	7b42                	ld	s6,48(sp)
    8000489a:	7ba2                	ld	s7,40(sp)
    8000489c:	7c02                	ld	s8,32(sp)
    8000489e:	6ce2                	ld	s9,24(sp)
    800048a0:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800048a2:	854a                	mv	a0,s2
    800048a4:	70a6                	ld	ra,104(sp)
    800048a6:	7406                	ld	s0,96(sp)
    800048a8:	64e6                	ld	s1,88(sp)
    800048aa:	6946                	ld	s2,80(sp)
    800048ac:	69a6                	ld	s3,72(sp)
    800048ae:	6a06                	ld	s4,64(sp)
    800048b0:	7ae2                	ld	s5,56(sp)
    800048b2:	6165                	addi	sp,sp,112
    800048b4:	8082                	ret
      wakeup(&pi->nread);
    800048b6:	856a                	mv	a0,s10
    800048b8:	8fbfd0ef          	jal	800021b2 <wakeup>
      sleep_prepare(&pi->nwrite);
    800048bc:	8566                	mv	a0,s9
    800048be:	889fd0ef          	jal	80002146 <sleep_prepare>
      release(&pi->lock);
    800048c2:	8526                	mv	a0,s1
    800048c4:	becfc0ef          	jal	80000cb0 <release>
      sleep();
    800048c8:	8bbfd0ef          	jal	80002182 <sleep>
      acquire(&pi->lock);
    800048cc:	8526                	mv	a0,s1
    800048ce:	b5afc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    800048d2:	07495b63          	bge	s2,s4,80004948 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    800048d6:	2204a783          	lw	a5,544(s1)
    800048da:	dbdd                	beqz	a5,80004890 <pipewrite+0x46>
    800048dc:	854e                	mv	a0,s3
    800048de:	ac7fd0ef          	jal	800023a4 <killed>
    800048e2:	f55d                	bnez	a0,80004890 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    800048e4:	2184a783          	lw	a5,536(s1)
    800048e8:	21c4a703          	lw	a4,540(s1)
    800048ec:	2007879b          	addiw	a5,a5,512
    800048f0:	fcf703e3          	beq	a4,a5,800048b6 <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800048f4:	875e                	mv	a4,s7
    800048f6:	015906b3          	add	a3,s2,s5
    800048fa:	8662                	mv	a2,s8
    800048fc:	0489b583          	ld	a1,72(s3)
    80004900:	0509b503          	ld	a0,80(s3)
    80004904:	d45fc0ef          	jal	80001648 <copyin>
    80004908:	03650163          	beq	a0,s6,8000492a <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000490c:	21c4a783          	lw	a5,540(s1)
    80004910:	0017871b          	addiw	a4,a5,1
    80004914:	20e4ae23          	sw	a4,540(s1)
    80004918:	1ff7f793          	andi	a5,a5,511
    8000491c:	97a6                	add	a5,a5,s1
    8000491e:	f9f44703          	lbu	a4,-97(s0)
    80004922:	00e78c23          	sb	a4,24(a5)
      i++;
    80004926:	2905                	addiw	s2,s2,1
    80004928:	b76d                	j	800048d2 <pipewrite+0x88>
        if (i == 0)
    8000492a:	00090863          	beqz	s2,8000493a <pipewrite+0xf0>
    8000492e:	7b42                	ld	s6,48(sp)
    80004930:	7ba2                	ld	s7,40(sp)
    80004932:	7c02                	ld	s8,32(sp)
    80004934:	6ce2                	ld	s9,24(sp)
    80004936:	6d42                	ld	s10,16(sp)
    80004938:	a829                	j	80004952 <pipewrite+0x108>
          i = -1;
    8000493a:	892a                	mv	s2,a0
        break;
    8000493c:	7b42                	ld	s6,48(sp)
    8000493e:	7ba2                	ld	s7,40(sp)
    80004940:	7c02                	ld	s8,32(sp)
    80004942:	6ce2                	ld	s9,24(sp)
    80004944:	6d42                	ld	s10,16(sp)
    80004946:	a031                	j	80004952 <pipewrite+0x108>
    80004948:	7b42                	ld	s6,48(sp)
    8000494a:	7ba2                	ld	s7,40(sp)
    8000494c:	7c02                	ld	s8,32(sp)
    8000494e:	6ce2                	ld	s9,24(sp)
    80004950:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004952:	21848513          	addi	a0,s1,536
    80004956:	85dfd0ef          	jal	800021b2 <wakeup>
  release(&pi->lock);
    8000495a:	8526                	mv	a0,s1
    8000495c:	b54fc0ef          	jal	80000cb0 <release>
  return i;
    80004960:	b789                	j	800048a2 <pipewrite+0x58>
  int i = 0;
    80004962:	4901                	li	s2,0
    80004964:	b7fd                	j	80004952 <pipewrite+0x108>

0000000080004966 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004966:	711d                	addi	sp,sp,-96
    80004968:	ec86                	sd	ra,88(sp)
    8000496a:	e8a2                	sd	s0,80(sp)
    8000496c:	e4a6                	sd	s1,72(sp)
    8000496e:	e0ca                	sd	s2,64(sp)
    80004970:	fc4e                	sd	s3,56(sp)
    80004972:	f852                	sd	s4,48(sp)
    80004974:	f456                	sd	s5,40(sp)
    80004976:	1080                	addi	s0,sp,96
    80004978:	84aa                	mv	s1,a0
    8000497a:	89ae                	mv	s3,a1
    8000497c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000497e:	fcbfc0ef          	jal	80001948 <myproc>
    80004982:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    80004984:	8526                	mv	a0,s1
    80004986:	aa2fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000498a:	0d505263          	blez	s5,80004a4e <piperead+0xe8>
    8000498e:	2184a703          	lw	a4,536(s1)
    80004992:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004996:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000499a:	02f71e63          	bne	a4,a5,800049d6 <piperead+0x70>
    8000499e:	2244a783          	lw	a5,548(s1)
    800049a2:	c3b9                	beqz	a5,800049e8 <piperead+0x82>
    if (killed(pr)) {
    800049a4:	854a                	mv	a0,s2
    800049a6:	9fffd0ef          	jal	800023a4 <killed>
    800049aa:	e915                	bnez	a0,800049de <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800049ac:	8552                	mv	a0,s4
    800049ae:	f98fd0ef          	jal	80002146 <sleep_prepare>
    release(&pi->lock);
    800049b2:	8526                	mv	a0,s1
    800049b4:	afcfc0ef          	jal	80000cb0 <release>
    sleep();
    800049b8:	fcafd0ef          	jal	80002182 <sleep>
    acquire(&pi->lock);
    800049bc:	8526                	mv	a0,s1
    800049be:	a6afc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800049c2:	2184a703          	lw	a4,536(s1)
    800049c6:	21c4a783          	lw	a5,540(s1)
    800049ca:	fcf70ae3          	beq	a4,a5,8000499e <piperead+0x38>
    800049ce:	f05a                	sd	s6,32(sp)
    800049d0:	ec5e                	sd	s7,24(sp)
    800049d2:	e862                	sd	s8,16(sp)
    800049d4:	a829                	j	800049ee <piperead+0x88>
    800049d6:	f05a                	sd	s6,32(sp)
    800049d8:	ec5e                	sd	s7,24(sp)
    800049da:	e862                	sd	s8,16(sp)
    800049dc:	a809                	j	800049ee <piperead+0x88>
      release(&pi->lock);
    800049de:	8526                	mv	a0,s1
    800049e0:	ad0fc0ef          	jal	80000cb0 <release>
      return -1;
    800049e4:	5a7d                	li	s4,-1
    800049e6:	a8a5                	j	80004a5e <piperead+0xf8>
    800049e8:	f05a                	sd	s6,32(sp)
    800049ea:	ec5e                	sd	s7,24(sp)
    800049ec:	e862                	sd	s8,16(sp)
{
    800049ee:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    800049f0:	faf40c13          	addi	s8,s0,-81
    800049f4:	4b85                	li	s7,1
    800049f6:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    800049f8:	2184a783          	lw	a5,536(s1)
    800049fc:	21c4a703          	lw	a4,540(s1)
    80004a00:	06f70e63          	beq	a4,a5,80004a7c <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    80004a04:	1ff7f793          	andi	a5,a5,511
    80004a08:	97a6                	add	a5,a5,s1
    80004a0a:	0187c783          	lbu	a5,24(a5)
    80004a0e:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004a12:	875e                	mv	a4,s7
    80004a14:	86e2                	mv	a3,s8
    80004a16:	864e                	mv	a2,s3
    80004a18:	04893583          	ld	a1,72(s2)
    80004a1c:	05093503          	ld	a0,80(s2)
    80004a20:	b63fc0ef          	jal	80001582 <copyout>
    80004a24:	01650f63          	beq	a0,s6,80004a42 <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004a28:	2184a783          	lw	a5,536(s1)
    80004a2c:	2785                	addiw	a5,a5,1
    80004a2e:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004a32:	2a05                	addiw	s4,s4,1
    80004a34:	0985                	addi	s3,s3,1
    80004a36:	fd4a91e3          	bne	s5,s4,800049f8 <piperead+0x92>
    80004a3a:	7b02                	ld	s6,32(sp)
    80004a3c:	6be2                	ld	s7,24(sp)
    80004a3e:	6c42                	ld	s8,16(sp)
    80004a40:	a801                	j	80004a50 <piperead+0xea>
      if (i == 0)
    80004a42:	020a0863          	beqz	s4,80004a72 <piperead+0x10c>
    80004a46:	7b02                	ld	s6,32(sp)
    80004a48:	6be2                	ld	s7,24(sp)
    80004a4a:	6c42                	ld	s8,16(sp)
    80004a4c:	a011                	j	80004a50 <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004a4e:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004a50:	21c48513          	addi	a0,s1,540
    80004a54:	f5efd0ef          	jal	800021b2 <wakeup>
  release(&pi->lock);
    80004a58:	8526                	mv	a0,s1
    80004a5a:	a56fc0ef          	jal	80000cb0 <release>
  return i;
}
    80004a5e:	8552                	mv	a0,s4
    80004a60:	60e6                	ld	ra,88(sp)
    80004a62:	6446                	ld	s0,80(sp)
    80004a64:	64a6                	ld	s1,72(sp)
    80004a66:	6906                	ld	s2,64(sp)
    80004a68:	79e2                	ld	s3,56(sp)
    80004a6a:	7a42                	ld	s4,48(sp)
    80004a6c:	7aa2                	ld	s5,40(sp)
    80004a6e:	6125                	addi	sp,sp,96
    80004a70:	8082                	ret
        i = -1;
    80004a72:	8a2a                	mv	s4,a0
    80004a74:	7b02                	ld	s6,32(sp)
    80004a76:	6be2                	ld	s7,24(sp)
    80004a78:	6c42                	ld	s8,16(sp)
    80004a7a:	bfd9                	j	80004a50 <piperead+0xea>
    80004a7c:	7b02                	ld	s6,32(sp)
    80004a7e:	6be2                	ld	s7,24(sp)
    80004a80:	6c42                	ld	s8,16(sp)
    80004a82:	b7f9                	j	80004a50 <piperead+0xea>

0000000080004a84 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004a84:	1141                	addi	sp,sp,-16
    80004a86:	e406                	sd	ra,8(sp)
    80004a88:	e022                	sd	s0,0(sp)
    80004a8a:	0800                	addi	s0,sp,16
    80004a8c:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004a8e:	0035151b          	slliw	a0,a0,0x3
    80004a92:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    80004a94:	8b89                	andi	a5,a5,2
    80004a96:	c399                	beqz	a5,80004a9c <flags2perm+0x18>
    perm |= PTE_W;
    80004a98:	00456513          	ori	a0,a0,4
  return perm;
}
    80004a9c:	60a2                	ld	ra,8(sp)
    80004a9e:	6402                	ld	s0,0(sp)
    80004aa0:	0141                	addi	sp,sp,16
    80004aa2:	8082                	ret

0000000080004aa4 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004aa4:	de010113          	addi	sp,sp,-544
    80004aa8:	20113c23          	sd	ra,536(sp)
    80004aac:	20813823          	sd	s0,528(sp)
    80004ab0:	20913423          	sd	s1,520(sp)
    80004ab4:	21213023          	sd	s2,512(sp)
    80004ab8:	1400                	addi	s0,sp,544
    80004aba:	892a                	mv	s2,a0
    80004abc:	dea43823          	sd	a0,-528(s0)
    80004ac0:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ac4:	e85fc0ef          	jal	80001948 <myproc>
    80004ac8:	84aa                	mv	s1,a0

  begin_op();
    80004aca:	c62ff0ef          	jal	80003f2c <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004ace:	854a                	mv	a0,s2
    80004ad0:	a7eff0ef          	jal	80003d4e <namei>
    80004ad4:	cd21                	beqz	a0,80004b2c <kexec+0x88>
    80004ad6:	fbd2                	sd	s4,496(sp)
    80004ad8:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ada:	9dbfe0ef          	jal	800034b4 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ade:	04000713          	li	a4,64
    80004ae2:	4681                	li	a3,0
    80004ae4:	e5040613          	addi	a2,s0,-432
    80004ae8:	4581                	li	a1,0
    80004aea:	8552                	mv	a0,s4
    80004aec:	da3fe0ef          	jal	8000388e <readi>
    80004af0:	04000793          	li	a5,64
    80004af4:	00f51a63          	bne	a0,a5,80004b08 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004af8:	e5042703          	lw	a4,-432(s0)
    80004afc:	464c47b7          	lui	a5,0x464c4
    80004b00:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004b04:	02f70863          	beq	a4,a5,80004b34 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004b08:	8552                	mv	a0,s4
    80004b0a:	bfffe0ef          	jal	80003708 <iunlockput>
    end_op();
    80004b0e:	caaff0ef          	jal	80003fb8 <end_op>
  }
  return -1;
    80004b12:	557d                	li	a0,-1
    80004b14:	7a5e                	ld	s4,496(sp)
}
    80004b16:	21813083          	ld	ra,536(sp)
    80004b1a:	21013403          	ld	s0,528(sp)
    80004b1e:	20813483          	ld	s1,520(sp)
    80004b22:	20013903          	ld	s2,512(sp)
    80004b26:	22010113          	addi	sp,sp,544
    80004b2a:	8082                	ret
    end_op();
    80004b2c:	c8cff0ef          	jal	80003fb8 <end_op>
    return -1;
    80004b30:	557d                	li	a0,-1
    80004b32:	b7d5                	j	80004b16 <kexec+0x72>
    80004b34:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004b36:	8526                	mv	a0,s1
    80004b38:	f17fc0ef          	jal	80001a4e <proc_pagetable>
    80004b3c:	8b2a                	mv	s6,a0
    80004b3e:	26050e63          	beqz	a0,80004dba <kexec+0x316>
    80004b42:	ffce                	sd	s3,504(sp)
    80004b44:	f7d6                	sd	s5,488(sp)
    80004b46:	efde                	sd	s7,472(sp)
    80004b48:	ebe2                	sd	s8,464(sp)
    80004b4a:	e7e6                	sd	s9,456(sp)
    80004b4c:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004b4e:	e8845783          	lhu	a5,-376(s0)
    80004b52:	14078263          	beqz	a5,80004c96 <kexec+0x1f2>
    80004b56:	ff6e                	sd	s11,440(sp)
    80004b58:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b5c:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004b5e:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004b60:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004b64:	6c85                	lui	s9,0x1
    80004b66:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004b6a:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004b6e:	6a85                	lui	s5,0x1
    80004b70:	a085                	j	80004bd0 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004b72:	00003517          	auipc	a0,0x3
    80004b76:	a4e50513          	addi	a0,a0,-1458 # 800075c0 <etext+0x5c0>
    80004b7a:	cbbfb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004b7e:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004b80:	874a                	mv	a4,s2
    80004b82:	009b86bb          	addw	a3,s7,s1
    80004b86:	4581                	li	a1,0
    80004b88:	8552                	mv	a0,s4
    80004b8a:	d05fe0ef          	jal	8000388e <readi>
    80004b8e:	22a91a63          	bne	s2,a0,80004dc2 <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004b92:	009a84bb          	addw	s1,s5,s1
    80004b96:	0334f263          	bgeu	s1,s3,80004bba <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004b9a:	02049593          	slli	a1,s1,0x20
    80004b9e:	9181                	srli	a1,a1,0x20
    80004ba0:	95e2                	add	a1,a1,s8
    80004ba2:	855a                	mv	a0,s6
    80004ba4:	c74fc0ef          	jal	80001018 <walkaddr>
    80004ba8:	862a                	mv	a2,a0
    if (pa == 0)
    80004baa:	d561                	beqz	a0,80004b72 <kexec+0xce>
    if (sz - i < PGSIZE)
    80004bac:	409987bb          	subw	a5,s3,s1
    80004bb0:	893e                	mv	s2,a5
    80004bb2:	fcfcf6e3          	bgeu	s9,a5,80004b7e <kexec+0xda>
    80004bb6:	8956                	mv	s2,s5
    80004bb8:	b7d9                	j	80004b7e <kexec+0xda>
    sz = sz1;
    80004bba:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004bbe:	2d05                	addiw	s10,s10,1
    80004bc0:	e0843783          	ld	a5,-504(s0)
    80004bc4:	0387869b          	addiw	a3,a5,56
    80004bc8:	e8845783          	lhu	a5,-376(s0)
    80004bcc:	06fd5d63          	bge	s10,a5,80004c46 <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004bd0:	e0d43423          	sd	a3,-504(s0)
    80004bd4:	876e                	mv	a4,s11
    80004bd6:	e1840613          	addi	a2,s0,-488
    80004bda:	4581                	li	a1,0
    80004bdc:	8552                	mv	a0,s4
    80004bde:	cb1fe0ef          	jal	8000388e <readi>
    80004be2:	1db51e63          	bne	a0,s11,80004dbe <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004be6:	e1842783          	lw	a5,-488(s0)
    80004bea:	4705                	li	a4,1
    80004bec:	fce799e3          	bne	a5,a4,80004bbe <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004bf0:	e4043483          	ld	s1,-448(s0)
    80004bf4:	e3843783          	ld	a5,-456(s0)
    80004bf8:	1ef4e363          	bltu	s1,a5,80004dde <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004bfc:	e2843783          	ld	a5,-472(s0)
    80004c00:	94be                	add	s1,s1,a5
    80004c02:	1ef4e163          	bltu	s1,a5,80004de4 <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004c06:	de843703          	ld	a4,-536(s0)
    80004c0a:	8ff9                	and	a5,a5,a4
    80004c0c:	1c079f63          	bnez	a5,80004dea <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004c10:	e1c42503          	lw	a0,-484(s0)
    80004c14:	e71ff0ef          	jal	80004a84 <flags2perm>
    80004c18:	86aa                	mv	a3,a0
    80004c1a:	8626                	mv	a2,s1
    80004c1c:	85ca                	mv	a1,s2
    80004c1e:	855a                	mv	a0,s6
    80004c20:	ecefc0ef          	jal	800012ee <uvmalloc>
    80004c24:	dea43c23          	sd	a0,-520(s0)
    80004c28:	1c050463          	beqz	a0,80004df0 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004c2c:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004c30:	00098863          	beqz	s3,80004c40 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004c34:	e2843c03          	ld	s8,-472(s0)
    80004c38:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004c3c:	4481                	li	s1,0
    80004c3e:	bfb1                	j	80004b9a <kexec+0xf6>
    sz = sz1;
    80004c40:	df843903          	ld	s2,-520(s0)
    80004c44:	bfad                	j	80004bbe <kexec+0x11a>
    80004c46:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004c48:	8552                	mv	a0,s4
    80004c4a:	abffe0ef          	jal	80003708 <iunlockput>
  end_op();
    80004c4e:	b6aff0ef          	jal	80003fb8 <end_op>
  p = myproc();
    80004c52:	cf7fc0ef          	jal	80001948 <myproc>
    80004c56:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004c58:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004c5c:	6c05                	lui	s8,0x1
    80004c5e:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004c60:	9c4a                	add	s8,s8,s2
    80004c62:	77fd                	lui	a5,0xfffff
    80004c64:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004c68:	4691                	li	a3,4
    80004c6a:	6609                	lui	a2,0x2
    80004c6c:	9662                	add	a2,a2,s8
    80004c6e:	85e2                	mv	a1,s8
    80004c70:	855a                	mv	a0,s6
    80004c72:	e7cfc0ef          	jal	800012ee <uvmalloc>
    80004c76:	892a                	mv	s2,a0
    80004c78:	e10d                	bnez	a0,80004c9a <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004c7a:	85e2                	mv	a1,s8
    80004c7c:	855a                	mv	a0,s6
    80004c7e:	e55fc0ef          	jal	80001ad2 <proc_freepagetable>
  return -1;
    80004c82:	557d                	li	a0,-1
    80004c84:	79fe                	ld	s3,504(sp)
    80004c86:	7a5e                	ld	s4,496(sp)
    80004c88:	7abe                	ld	s5,488(sp)
    80004c8a:	7b1e                	ld	s6,480(sp)
    80004c8c:	6bfe                	ld	s7,472(sp)
    80004c8e:	6c5e                	ld	s8,464(sp)
    80004c90:	6cbe                	ld	s9,456(sp)
    80004c92:	6d1e                	ld	s10,448(sp)
    80004c94:	b549                	j	80004b16 <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c96:	4901                	li	s2,0
    80004c98:	bf45                	j	80004c48 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004c9a:	75f9                	lui	a1,0xffffe
    80004c9c:	95aa                	add	a1,a1,a0
    80004c9e:	855a                	mv	a0,s6
    80004ca0:	821fc0ef          	jal	800014c0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004ca4:	80090a13          	addi	s4,s2,-2048
    80004ca8:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004cac:	e0043783          	ld	a5,-512(s0)
    80004cb0:	6388                	ld	a0,0(a5)
    80004cb2:	c545                	beqz	a0,80004d5a <kexec+0x2b6>
  sp = sz;
    80004cb4:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004cb6:	4481                	li	s1,0
    ustack[argc] = sp;
    80004cb8:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004cbc:	9b6fc0ef          	jal	80000e72 <strlen>
    80004cc0:	0015079b          	addiw	a5,a0,1
    80004cc4:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004cc8:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004ccc:	134c6563          	bltu	s8,s4,80004df6 <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004cd0:	e0043d03          	ld	s10,-512(s0)
    80004cd4:	000d3c83          	ld	s9,0(s10)
    80004cd8:	8566                	mv	a0,s9
    80004cda:	998fc0ef          	jal	80000e72 <strlen>
    80004cde:	0015071b          	addiw	a4,a0,1
    80004ce2:	86e6                	mv	a3,s9
    80004ce4:	8662                	mv	a2,s8
    80004ce6:	85ca                	mv	a1,s2
    80004ce8:	855a                	mv	a0,s6
    80004cea:	899fc0ef          	jal	80001582 <copyout>
    80004cee:	10054663          	bltz	a0,80004dfa <kexec+0x356>
    ustack[argc] = sp;
    80004cf2:	00349793          	slli	a5,s1,0x3
    80004cf6:	97de                	add	a5,a5,s7
    80004cf8:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb6d8>
  for (argc = 0; argv[argc]; argc++) {
    80004cfc:	0485                	addi	s1,s1,1
    80004cfe:	008d0793          	addi	a5,s10,8
    80004d02:	e0f43023          	sd	a5,-512(s0)
    80004d06:	008d3503          	ld	a0,8(s10)
    80004d0a:	f94d                	bnez	a0,80004cbc <kexec+0x218>
  ustack[argc] = 0;
    80004d0c:	00349793          	slli	a5,s1,0x3
    80004d10:	f9078793          	addi	a5,a5,-112
    80004d14:	97a2                	add	a5,a5,s0
    80004d16:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004d1a:	00349713          	slli	a4,s1,0x3
    80004d1e:	0721                	addi	a4,a4,8
    80004d20:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004d24:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004d28:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004d2a:	f54be8e3          	bltu	s7,s4,80004c7a <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004d2e:	e9040693          	addi	a3,s0,-368
    80004d32:	865e                	mv	a2,s7
    80004d34:	85ca                	mv	a1,s2
    80004d36:	855a                	mv	a0,s6
    80004d38:	84bfc0ef          	jal	80001582 <copyout>
    80004d3c:	f2054fe3          	bltz	a0,80004c7a <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004d40:	0589b783          	ld	a5,88(s3)
    80004d44:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004d48:	df043783          	ld	a5,-528(s0)
    80004d4c:	0007c703          	lbu	a4,0(a5)
    80004d50:	c30d                	beqz	a4,80004d72 <kexec+0x2ce>
    80004d52:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004d54:	02f00693          	li	a3,47
    80004d58:	a801                	j	80004d68 <kexec+0x2c4>
  sp = sz;
    80004d5a:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004d5c:	4481                	li	s1,0
    80004d5e:	b77d                	j	80004d0c <kexec+0x268>
  for (last = s = path; *s; s++)
    80004d60:	0785                	addi	a5,a5,1
    80004d62:	fff7c703          	lbu	a4,-1(a5)
    80004d66:	c711                	beqz	a4,80004d72 <kexec+0x2ce>
    if (*s == '/')
    80004d68:	fed71ce3          	bne	a4,a3,80004d60 <kexec+0x2bc>
      last = s + 1;
    80004d6c:	def43823          	sd	a5,-528(s0)
    80004d70:	bfc5                	j	80004d60 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004d72:	4641                	li	a2,16
    80004d74:	df043583          	ld	a1,-528(s0)
    80004d78:	15898513          	addi	a0,s3,344
    80004d7c:	8c0fc0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004d80:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004d84:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004d88:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004d8c:	0589b783          	ld	a5,88(s3)
    80004d90:	e6843703          	ld	a4,-408(s0)
    80004d94:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004d96:	0589b783          	ld	a5,88(s3)
    80004d9a:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004d9e:	85d6                	mv	a1,s5
    80004da0:	d33fc0ef          	jal	80001ad2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004da4:	0004851b          	sext.w	a0,s1
    80004da8:	79fe                	ld	s3,504(sp)
    80004daa:	7a5e                	ld	s4,496(sp)
    80004dac:	7abe                	ld	s5,488(sp)
    80004dae:	7b1e                	ld	s6,480(sp)
    80004db0:	6bfe                	ld	s7,472(sp)
    80004db2:	6c5e                	ld	s8,464(sp)
    80004db4:	6cbe                	ld	s9,456(sp)
    80004db6:	6d1e                	ld	s10,448(sp)
    80004db8:	bbb9                	j	80004b16 <kexec+0x72>
    80004dba:	7b1e                	ld	s6,480(sp)
    80004dbc:	b3b1                	j	80004b08 <kexec+0x64>
    80004dbe:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004dc2:	df843583          	ld	a1,-520(s0)
    80004dc6:	855a                	mv	a0,s6
    80004dc8:	d0bfc0ef          	jal	80001ad2 <proc_freepagetable>
  if (ip) {
    80004dcc:	79fe                	ld	s3,504(sp)
    80004dce:	7abe                	ld	s5,488(sp)
    80004dd0:	7b1e                	ld	s6,480(sp)
    80004dd2:	6bfe                	ld	s7,472(sp)
    80004dd4:	6c5e                	ld	s8,464(sp)
    80004dd6:	6cbe                	ld	s9,456(sp)
    80004dd8:	6d1e                	ld	s10,448(sp)
    80004dda:	7dfa                	ld	s11,440(sp)
    80004ddc:	b335                	j	80004b08 <kexec+0x64>
    80004dde:	df243c23          	sd	s2,-520(s0)
    80004de2:	b7c5                	j	80004dc2 <kexec+0x31e>
    80004de4:	df243c23          	sd	s2,-520(s0)
    80004de8:	bfe9                	j	80004dc2 <kexec+0x31e>
    80004dea:	df243c23          	sd	s2,-520(s0)
    80004dee:	bfd1                	j	80004dc2 <kexec+0x31e>
    80004df0:	df243c23          	sd	s2,-520(s0)
    80004df4:	b7f9                	j	80004dc2 <kexec+0x31e>
  sz = sz1;
    80004df6:	8c4a                	mv	s8,s2
    80004df8:	b549                	j	80004c7a <kexec+0x1d6>
    80004dfa:	8c4a                	mv	s8,s2
    80004dfc:	bdbd                	j	80004c7a <kexec+0x1d6>

0000000080004dfe <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004dfe:	7179                	addi	sp,sp,-48
    80004e00:	f406                	sd	ra,40(sp)
    80004e02:	f022                	sd	s0,32(sp)
    80004e04:	ec26                	sd	s1,24(sp)
    80004e06:	e84a                	sd	s2,16(sp)
    80004e08:	1800                	addi	s0,sp,48
    80004e0a:	892e                	mv	s2,a1
    80004e0c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004e0e:	fdc40593          	addi	a1,s0,-36
    80004e12:	c77fd0ef          	jal	80002a88 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004e16:	fdc42703          	lw	a4,-36(s0)
    80004e1a:	47bd                	li	a5,15
    80004e1c:	02e7ea63          	bltu	a5,a4,80004e50 <argfd+0x52>
    80004e20:	b29fc0ef          	jal	80001948 <myproc>
    80004e24:	fdc42703          	lw	a4,-36(s0)
    80004e28:	00371793          	slli	a5,a4,0x3
    80004e2c:	0d078793          	addi	a5,a5,208
    80004e30:	953e                	add	a0,a0,a5
    80004e32:	611c                	ld	a5,0(a0)
    80004e34:	c385                	beqz	a5,80004e54 <argfd+0x56>
    return -1;
  if (pfd)
    80004e36:	00090463          	beqz	s2,80004e3e <argfd+0x40>
    *pfd = fd;
    80004e3a:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004e3e:	4501                	li	a0,0
  if (pf)
    80004e40:	c091                	beqz	s1,80004e44 <argfd+0x46>
    *pf = f;
    80004e42:	e09c                	sd	a5,0(s1)
}
    80004e44:	70a2                	ld	ra,40(sp)
    80004e46:	7402                	ld	s0,32(sp)
    80004e48:	64e2                	ld	s1,24(sp)
    80004e4a:	6942                	ld	s2,16(sp)
    80004e4c:	6145                	addi	sp,sp,48
    80004e4e:	8082                	ret
    return -1;
    80004e50:	557d                	li	a0,-1
    80004e52:	bfcd                	j	80004e44 <argfd+0x46>
    80004e54:	557d                	li	a0,-1
    80004e56:	b7fd                	j	80004e44 <argfd+0x46>

0000000080004e58 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004e58:	1101                	addi	sp,sp,-32
    80004e5a:	ec06                	sd	ra,24(sp)
    80004e5c:	e822                	sd	s0,16(sp)
    80004e5e:	e426                	sd	s1,8(sp)
    80004e60:	1000                	addi	s0,sp,32
    80004e62:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004e64:	ae5fc0ef          	jal	80001948 <myproc>
    80004e68:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004e6a:	0d050793          	addi	a5,a0,208
    80004e6e:	4501                	li	a0,0
    80004e70:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004e72:	6398                	ld	a4,0(a5)
    80004e74:	cb19                	beqz	a4,80004e8a <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004e76:	2505                	addiw	a0,a0,1
    80004e78:	07a1                	addi	a5,a5,8
    80004e7a:	fed51ce3          	bne	a0,a3,80004e72 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004e7e:	557d                	li	a0,-1
}
    80004e80:	60e2                	ld	ra,24(sp)
    80004e82:	6442                	ld	s0,16(sp)
    80004e84:	64a2                	ld	s1,8(sp)
    80004e86:	6105                	addi	sp,sp,32
    80004e88:	8082                	ret
      p->ofile[fd] = f;
    80004e8a:	00351793          	slli	a5,a0,0x3
    80004e8e:	0d078793          	addi	a5,a5,208
    80004e92:	963e                	add	a2,a2,a5
    80004e94:	e204                	sd	s1,0(a2)
      return fd;
    80004e96:	b7ed                	j	80004e80 <fdalloc+0x28>

0000000080004e98 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004e98:	715d                	addi	sp,sp,-80
    80004e9a:	e486                	sd	ra,72(sp)
    80004e9c:	e0a2                	sd	s0,64(sp)
    80004e9e:	fc26                	sd	s1,56(sp)
    80004ea0:	f84a                	sd	s2,48(sp)
    80004ea2:	f052                	sd	s4,32(sp)
    80004ea4:	ec56                	sd	s5,24(sp)
    80004ea6:	e85a                	sd	s6,16(sp)
    80004ea8:	0880                	addi	s0,sp,80
    80004eaa:	8a2e                	mv	s4,a1
    80004eac:	8ab2                	mv	s5,a2
    80004eae:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004eb0:	fb040593          	addi	a1,s0,-80
    80004eb4:	eb5fe0ef          	jal	80003d68 <nameiparent>
    80004eb8:	84aa                	mv	s1,a0
    80004eba:	12050f63          	beqz	a0,80004ff8 <create+0x160>
    return 0;

  ilock(dp);
    80004ebe:	df6fe0ef          	jal	800034b4 <ilock>

  if (dp->nlink == 0) {
    80004ec2:	04a49783          	lh	a5,74(s1)
    80004ec6:	cbb9                	beqz	a5,80004f1c <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004ec8:	7761                	lui	a4,0xffff8
    80004eca:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd46d9>
    80004ecc:	97ba                	add	a5,a5,a4
    80004ece:	e781                	bnez	a5,80004ed6 <create+0x3e>
    80004ed0:	fffa0793          	addi	a5,s4,-1
    80004ed4:	cba9                	beqz	a5,80004f26 <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004ed6:	4601                	li	a2,0
    80004ed8:	fb040593          	addi	a1,s0,-80
    80004edc:	8526                	mv	a0,s1
    80004ede:	bbffe0ef          	jal	80003a9c <dirlookup>
    80004ee2:	892a                	mv	s2,a0
    80004ee4:	c939                	beqz	a0,80004f3a <create+0xa2>
    iunlockput(dp);
    80004ee6:	8526                	mv	a0,s1
    80004ee8:	821fe0ef          	jal	80003708 <iunlockput>
    ilock(ip);
    80004eec:	854a                	mv	a0,s2
    80004eee:	dc6fe0ef          	jal	800034b4 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004ef2:	4789                	li	a5,2
    80004ef4:	02fa1e63          	bne	s4,a5,80004f30 <create+0x98>
    80004ef8:	04495783          	lhu	a5,68(s2)
    80004efc:	37f9                	addiw	a5,a5,-2
    80004efe:	17c2                	slli	a5,a5,0x30
    80004f00:	93c1                	srli	a5,a5,0x30
    80004f02:	4705                	li	a4,1
    80004f04:	02f76663          	bltu	a4,a5,80004f30 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004f08:	854a                	mv	a0,s2
    80004f0a:	60a6                	ld	ra,72(sp)
    80004f0c:	6406                	ld	s0,64(sp)
    80004f0e:	74e2                	ld	s1,56(sp)
    80004f10:	7942                	ld	s2,48(sp)
    80004f12:	7a02                	ld	s4,32(sp)
    80004f14:	6ae2                	ld	s5,24(sp)
    80004f16:	6b42                	ld	s6,16(sp)
    80004f18:	6161                	addi	sp,sp,80
    80004f1a:	8082                	ret
    iunlockput(dp);
    80004f1c:	8526                	mv	a0,s1
    80004f1e:	feafe0ef          	jal	80003708 <iunlockput>
    return 0;
    80004f22:	4901                	li	s2,0
    80004f24:	b7d5                	j	80004f08 <create+0x70>
    iunlockput(dp);
    80004f26:	8526                	mv	a0,s1
    80004f28:	fe0fe0ef          	jal	80003708 <iunlockput>
    return 0;
    80004f2c:	4901                	li	s2,0
    80004f2e:	bfe9                	j	80004f08 <create+0x70>
    iunlockput(ip);
    80004f30:	854a                	mv	a0,s2
    80004f32:	fd6fe0ef          	jal	80003708 <iunlockput>
    return 0;
    80004f36:	4901                	li	s2,0
    80004f38:	bfc1                	j	80004f08 <create+0x70>
    80004f3a:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004f3c:	85d2                	mv	a1,s4
    80004f3e:	4088                	lw	a0,0(s1)
    80004f40:	c04fe0ef          	jal	80003344 <ialloc>
    80004f44:	89aa                	mv	s3,a0
    80004f46:	cd1d                	beqz	a0,80004f84 <create+0xec>
  ilock(ip);
    80004f48:	d6cfe0ef          	jal	800034b4 <ilock>
  ip->major = major;
    80004f4c:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004f50:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004f54:	4705                	li	a4,1
    80004f56:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004f5a:	854e                	mv	a0,s3
    80004f5c:	ca4fe0ef          	jal	80003400 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004f60:	4705                	li	a4,1
    80004f62:	02ea0763          	beq	s4,a4,80004f90 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004f66:	0049a603          	lw	a2,4(s3)
    80004f6a:	fb040593          	addi	a1,s0,-80
    80004f6e:	8526                	mv	a0,s1
    80004f70:	d35fe0ef          	jal	80003ca4 <dirlink>
    80004f74:	06054563          	bltz	a0,80004fde <create+0x146>
  iunlockput(dp);
    80004f78:	8526                	mv	a0,s1
    80004f7a:	f8efe0ef          	jal	80003708 <iunlockput>
  return ip;
    80004f7e:	894e                	mv	s2,s3
    80004f80:	79a2                	ld	s3,40(sp)
    80004f82:	b759                	j	80004f08 <create+0x70>
    iunlockput(dp);
    80004f84:	8526                	mv	a0,s1
    80004f86:	f82fe0ef          	jal	80003708 <iunlockput>
    return 0;
    80004f8a:	894e                	mv	s2,s3
    80004f8c:	79a2                	ld	s3,40(sp)
    80004f8e:	bfad                	j	80004f08 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004f90:	0049a603          	lw	a2,4(s3)
    80004f94:	00002597          	auipc	a1,0x2
    80004f98:	64c58593          	addi	a1,a1,1612 # 800075e0 <etext+0x5e0>
    80004f9c:	854e                	mv	a0,s3
    80004f9e:	d07fe0ef          	jal	80003ca4 <dirlink>
    80004fa2:	02054e63          	bltz	a0,80004fde <create+0x146>
    80004fa6:	40d0                	lw	a2,4(s1)
    80004fa8:	00002597          	auipc	a1,0x2
    80004fac:	64058593          	addi	a1,a1,1600 # 800075e8 <etext+0x5e8>
    80004fb0:	854e                	mv	a0,s3
    80004fb2:	cf3fe0ef          	jal	80003ca4 <dirlink>
    80004fb6:	02054463          	bltz	a0,80004fde <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004fba:	0049a603          	lw	a2,4(s3)
    80004fbe:	fb040593          	addi	a1,s0,-80
    80004fc2:	8526                	mv	a0,s1
    80004fc4:	ce1fe0ef          	jal	80003ca4 <dirlink>
    80004fc8:	00054b63          	bltz	a0,80004fde <create+0x146>
    dp->nlink++; // for ".."
    80004fcc:	04a4d783          	lhu	a5,74(s1)
    80004fd0:	2785                	addiw	a5,a5,1
    80004fd2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004fd6:	8526                	mv	a0,s1
    80004fd8:	c28fe0ef          	jal	80003400 <iupdate>
    80004fdc:	bf71                	j	80004f78 <create+0xe0>
  ip->nlink = 0;
    80004fde:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004fe2:	854e                	mv	a0,s3
    80004fe4:	c1cfe0ef          	jal	80003400 <iupdate>
  iunlockput(ip);
    80004fe8:	854e                	mv	a0,s3
    80004fea:	f1efe0ef          	jal	80003708 <iunlockput>
  iunlockput(dp);
    80004fee:	8526                	mv	a0,s1
    80004ff0:	f18fe0ef          	jal	80003708 <iunlockput>
  return 0;
    80004ff4:	79a2                	ld	s3,40(sp)
    80004ff6:	bf09                	j	80004f08 <create+0x70>
    return 0;
    80004ff8:	892a                	mv	s2,a0
    80004ffa:	b739                	j	80004f08 <create+0x70>

0000000080004ffc <sys_dup>:
{
    80004ffc:	7179                	addi	sp,sp,-48
    80004ffe:	f406                	sd	ra,40(sp)
    80005000:	f022                	sd	s0,32(sp)
    80005002:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80005004:	fd840613          	addi	a2,s0,-40
    80005008:	4581                	li	a1,0
    8000500a:	4501                	li	a0,0
    8000500c:	df3ff0ef          	jal	80004dfe <argfd>
    return -1;
    80005010:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80005012:	02054363          	bltz	a0,80005038 <sys_dup+0x3c>
    80005016:	ec26                	sd	s1,24(sp)
    80005018:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    8000501a:	fd843483          	ld	s1,-40(s0)
    8000501e:	8526                	mv	a0,s1
    80005020:	e39ff0ef          	jal	80004e58 <fdalloc>
    80005024:	892a                	mv	s2,a0
    return -1;
    80005026:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80005028:	00054d63          	bltz	a0,80005042 <sys_dup+0x46>
  filedup(f);
    8000502c:	8526                	mv	a0,s1
    8000502e:	b72ff0ef          	jal	800043a0 <filedup>
  return fd;
    80005032:	87ca                	mv	a5,s2
    80005034:	64e2                	ld	s1,24(sp)
    80005036:	6942                	ld	s2,16(sp)
}
    80005038:	853e                	mv	a0,a5
    8000503a:	70a2                	ld	ra,40(sp)
    8000503c:	7402                	ld	s0,32(sp)
    8000503e:	6145                	addi	sp,sp,48
    80005040:	8082                	ret
    80005042:	64e2                	ld	s1,24(sp)
    80005044:	6942                	ld	s2,16(sp)
    80005046:	bfcd                	j	80005038 <sys_dup+0x3c>

0000000080005048 <sys_read>:
{
    80005048:	7179                	addi	sp,sp,-48
    8000504a:	f406                	sd	ra,40(sp)
    8000504c:	f022                	sd	s0,32(sp)
    8000504e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005050:	fd840593          	addi	a1,s0,-40
    80005054:	4505                	li	a0,1
    80005056:	a4ffd0ef          	jal	80002aa4 <argaddr>
  argint(2, &n);
    8000505a:	fe440593          	addi	a1,s0,-28
    8000505e:	4509                	li	a0,2
    80005060:	a29fd0ef          	jal	80002a88 <argint>
  if (argfd(0, 0, &f) < 0)
    80005064:	fe840613          	addi	a2,s0,-24
    80005068:	4581                	li	a1,0
    8000506a:	4501                	li	a0,0
    8000506c:	d93ff0ef          	jal	80004dfe <argfd>
    80005070:	87aa                	mv	a5,a0
    return -1;
    80005072:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005074:	0007ca63          	bltz	a5,80005088 <sys_read+0x40>
  return fileread(f, p, n);
    80005078:	fe442603          	lw	a2,-28(s0)
    8000507c:	fd843583          	ld	a1,-40(s0)
    80005080:	fe843503          	ld	a0,-24(s0)
    80005084:	c94ff0ef          	jal	80004518 <fileread>
}
    80005088:	70a2                	ld	ra,40(sp)
    8000508a:	7402                	ld	s0,32(sp)
    8000508c:	6145                	addi	sp,sp,48
    8000508e:	8082                	ret

0000000080005090 <sys_write>:
{
    80005090:	7179                	addi	sp,sp,-48
    80005092:	f406                	sd	ra,40(sp)
    80005094:	f022                	sd	s0,32(sp)
    80005096:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005098:	fd840593          	addi	a1,s0,-40
    8000509c:	4505                	li	a0,1
    8000509e:	a07fd0ef          	jal	80002aa4 <argaddr>
  argint(2, &n);
    800050a2:	fe440593          	addi	a1,s0,-28
    800050a6:	4509                	li	a0,2
    800050a8:	9e1fd0ef          	jal	80002a88 <argint>
  if (argfd(0, 0, &f) < 0)
    800050ac:	fe840613          	addi	a2,s0,-24
    800050b0:	4581                	li	a1,0
    800050b2:	4501                	li	a0,0
    800050b4:	d4bff0ef          	jal	80004dfe <argfd>
    800050b8:	87aa                	mv	a5,a0
    return -1;
    800050ba:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800050bc:	0007ca63          	bltz	a5,800050d0 <sys_write+0x40>
  return filewrite(f, p, n);
    800050c0:	fe442603          	lw	a2,-28(s0)
    800050c4:	fd843583          	ld	a1,-40(s0)
    800050c8:	fe843503          	ld	a0,-24(s0)
    800050cc:	d1aff0ef          	jal	800045e6 <filewrite>
}
    800050d0:	70a2                	ld	ra,40(sp)
    800050d2:	7402                	ld	s0,32(sp)
    800050d4:	6145                	addi	sp,sp,48
    800050d6:	8082                	ret

00000000800050d8 <sys_close>:
{
    800050d8:	1101                	addi	sp,sp,-32
    800050da:	ec06                	sd	ra,24(sp)
    800050dc:	e822                	sd	s0,16(sp)
    800050de:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    800050e0:	fe040613          	addi	a2,s0,-32
    800050e4:	fec40593          	addi	a1,s0,-20
    800050e8:	4501                	li	a0,0
    800050ea:	d15ff0ef          	jal	80004dfe <argfd>
    return -1;
    800050ee:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    800050f0:	02054163          	bltz	a0,80005112 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    800050f4:	855fc0ef          	jal	80001948 <myproc>
    800050f8:	fec42783          	lw	a5,-20(s0)
    800050fc:	078e                	slli	a5,a5,0x3
    800050fe:	0d078793          	addi	a5,a5,208
    80005102:	953e                	add	a0,a0,a5
    80005104:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005108:	fe043503          	ld	a0,-32(s0)
    8000510c:	adaff0ef          	jal	800043e6 <fileclose>
  return 0;
    80005110:	4781                	li	a5,0
}
    80005112:	853e                	mv	a0,a5
    80005114:	60e2                	ld	ra,24(sp)
    80005116:	6442                	ld	s0,16(sp)
    80005118:	6105                	addi	sp,sp,32
    8000511a:	8082                	ret

000000008000511c <sys_fstat>:
{
    8000511c:	1101                	addi	sp,sp,-32
    8000511e:	ec06                	sd	ra,24(sp)
    80005120:	e822                	sd	s0,16(sp)
    80005122:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005124:	fe040593          	addi	a1,s0,-32
    80005128:	4505                	li	a0,1
    8000512a:	97bfd0ef          	jal	80002aa4 <argaddr>
  if (argfd(0, 0, &f) < 0)
    8000512e:	fe840613          	addi	a2,s0,-24
    80005132:	4581                	li	a1,0
    80005134:	4501                	li	a0,0
    80005136:	cc9ff0ef          	jal	80004dfe <argfd>
    8000513a:	87aa                	mv	a5,a0
    return -1;
    8000513c:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    8000513e:	0007c863          	bltz	a5,8000514e <sys_fstat+0x32>
  return filestat(f, st);
    80005142:	fe043583          	ld	a1,-32(s0)
    80005146:	fe843503          	ld	a0,-24(s0)
    8000514a:	b5eff0ef          	jal	800044a8 <filestat>
}
    8000514e:	60e2                	ld	ra,24(sp)
    80005150:	6442                	ld	s0,16(sp)
    80005152:	6105                	addi	sp,sp,32
    80005154:	8082                	ret

0000000080005156 <sys_link>:
{
    80005156:	7169                	addi	sp,sp,-304
    80005158:	f606                	sd	ra,296(sp)
    8000515a:	f222                	sd	s0,288(sp)
    8000515c:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000515e:	08000613          	li	a2,128
    80005162:	ed040593          	addi	a1,s0,-304
    80005166:	4501                	li	a0,0
    80005168:	959fd0ef          	jal	80002ac0 <argstr>
    return -1;
    8000516c:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000516e:	10054163          	bltz	a0,80005270 <sys_link+0x11a>
    80005172:	08000613          	li	a2,128
    80005176:	f5040593          	addi	a1,s0,-176
    8000517a:	4505                	li	a0,1
    8000517c:	945fd0ef          	jal	80002ac0 <argstr>
    return -1;
    80005180:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005182:	0e054763          	bltz	a0,80005270 <sys_link+0x11a>
    80005186:	ee26                	sd	s1,280(sp)
  begin_op();
    80005188:	da5fe0ef          	jal	80003f2c <begin_op>
  if ((ip = namei(old)) == 0) {
    8000518c:	ed040513          	addi	a0,s0,-304
    80005190:	bbffe0ef          	jal	80003d4e <namei>
    80005194:	84aa                	mv	s1,a0
    80005196:	cd35                	beqz	a0,80005212 <sys_link+0xbc>
  ilock(ip);
    80005198:	b1cfe0ef          	jal	800034b4 <ilock>
  if (ip->type == T_DIR) {
    8000519c:	04449703          	lh	a4,68(s1)
    800051a0:	4785                	li	a5,1
    800051a2:	06f70d63          	beq	a4,a5,8000521c <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    800051a6:	04a49783          	lh	a5,74(s1)
    800051aa:	6721                	lui	a4,0x8
    800051ac:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    800051ae:	06e78f63          	beq	a5,a4,8000522c <sys_link+0xd6>
    800051b2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800051b4:	2785                	addiw	a5,a5,1
    800051b6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800051ba:	8526                	mv	a0,s1
    800051bc:	a44fe0ef          	jal	80003400 <iupdate>
  iunlock(ip);
    800051c0:	8526                	mv	a0,s1
    800051c2:	ba0fe0ef          	jal	80003562 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    800051c6:	fd040593          	addi	a1,s0,-48
    800051ca:	f5040513          	addi	a0,s0,-176
    800051ce:	b9bfe0ef          	jal	80003d68 <nameiparent>
    800051d2:	892a                	mv	s2,a0
    800051d4:	c93d                	beqz	a0,8000524a <sys_link+0xf4>
  ilock(dp);
    800051d6:	adefe0ef          	jal	800034b4 <ilock>
  if (dp->nlink == 0) {
    800051da:	04a91783          	lh	a5,74(s2)
    800051de:	cfb9                	beqz	a5,8000523c <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    800051e0:	854a                	mv	a0,s2
    800051e2:	00092703          	lw	a4,0(s2)
    800051e6:	409c                	lw	a5,0(s1)
    800051e8:	04f71e63          	bne	a4,a5,80005244 <sys_link+0xee>
    800051ec:	40d0                	lw	a2,4(s1)
    800051ee:	fd040593          	addi	a1,s0,-48
    800051f2:	ab3fe0ef          	jal	80003ca4 <dirlink>
    800051f6:	04054763          	bltz	a0,80005244 <sys_link+0xee>
  iunlockput(dp);
    800051fa:	854a                	mv	a0,s2
    800051fc:	d0cfe0ef          	jal	80003708 <iunlockput>
  iput(ip);
    80005200:	8526                	mv	a0,s1
    80005202:	c34fe0ef          	jal	80003636 <iput>
  end_op();
    80005206:	db3fe0ef          	jal	80003fb8 <end_op>
  return 0;
    8000520a:	4781                	li	a5,0
    8000520c:	64f2                	ld	s1,280(sp)
    8000520e:	6952                	ld	s2,272(sp)
    80005210:	a085                	j	80005270 <sys_link+0x11a>
    end_op();
    80005212:	da7fe0ef          	jal	80003fb8 <end_op>
    return -1;
    80005216:	57fd                	li	a5,-1
    80005218:	64f2                	ld	s1,280(sp)
    8000521a:	a899                	j	80005270 <sys_link+0x11a>
    iunlockput(ip);
    8000521c:	8526                	mv	a0,s1
    8000521e:	ceafe0ef          	jal	80003708 <iunlockput>
    end_op();
    80005222:	d97fe0ef          	jal	80003fb8 <end_op>
    return -1;
    80005226:	57fd                	li	a5,-1
    80005228:	64f2                	ld	s1,280(sp)
    8000522a:	a099                	j	80005270 <sys_link+0x11a>
    iunlockput(ip);
    8000522c:	8526                	mv	a0,s1
    8000522e:	cdafe0ef          	jal	80003708 <iunlockput>
    end_op();
    80005232:	d87fe0ef          	jal	80003fb8 <end_op>
    return -1;
    80005236:	57fd                	li	a5,-1
    80005238:	64f2                	ld	s1,280(sp)
    8000523a:	a81d                	j	80005270 <sys_link+0x11a>
    iunlockput(dp);
    8000523c:	854a                	mv	a0,s2
    8000523e:	ccafe0ef          	jal	80003708 <iunlockput>
    goto bad;
    80005242:	a021                	j	8000524a <sys_link+0xf4>
    iunlockput(dp);
    80005244:	854a                	mv	a0,s2
    80005246:	cc2fe0ef          	jal	80003708 <iunlockput>
  ilock(ip);
    8000524a:	8526                	mv	a0,s1
    8000524c:	a68fe0ef          	jal	800034b4 <ilock>
  ip->nlink--;
    80005250:	04a4d783          	lhu	a5,74(s1)
    80005254:	37fd                	addiw	a5,a5,-1
    80005256:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000525a:	8526                	mv	a0,s1
    8000525c:	9a4fe0ef          	jal	80003400 <iupdate>
  iunlockput(ip);
    80005260:	8526                	mv	a0,s1
    80005262:	ca6fe0ef          	jal	80003708 <iunlockput>
  end_op();
    80005266:	d53fe0ef          	jal	80003fb8 <end_op>
  return -1;
    8000526a:	57fd                	li	a5,-1
    8000526c:	64f2                	ld	s1,280(sp)
    8000526e:	6952                	ld	s2,272(sp)
}
    80005270:	853e                	mv	a0,a5
    80005272:	70b2                	ld	ra,296(sp)
    80005274:	7412                	ld	s0,288(sp)
    80005276:	6155                	addi	sp,sp,304
    80005278:	8082                	ret

000000008000527a <sys_unlink>:
{
    8000527a:	7151                	addi	sp,sp,-240
    8000527c:	f586                	sd	ra,232(sp)
    8000527e:	f1a2                	sd	s0,224(sp)
    80005280:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005282:	08000613          	li	a2,128
    80005286:	f3040593          	addi	a1,s0,-208
    8000528a:	4501                	li	a0,0
    8000528c:	835fd0ef          	jal	80002ac0 <argstr>
    80005290:	14054d63          	bltz	a0,800053ea <sys_unlink+0x170>
    80005294:	eda6                	sd	s1,216(sp)
  begin_op();
    80005296:	c97fe0ef          	jal	80003f2c <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    8000529a:	fb040593          	addi	a1,s0,-80
    8000529e:	f3040513          	addi	a0,s0,-208
    800052a2:	ac7fe0ef          	jal	80003d68 <nameiparent>
    800052a6:	84aa                	mv	s1,a0
    800052a8:	c955                	beqz	a0,8000535c <sys_unlink+0xe2>
  ilock(dp);
    800052aa:	a0afe0ef          	jal	800034b4 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800052ae:	00002597          	auipc	a1,0x2
    800052b2:	33258593          	addi	a1,a1,818 # 800075e0 <etext+0x5e0>
    800052b6:	fb040513          	addi	a0,s0,-80
    800052ba:	fccfe0ef          	jal	80003a86 <namecmp>
    800052be:	10050b63          	beqz	a0,800053d4 <sys_unlink+0x15a>
    800052c2:	00002597          	auipc	a1,0x2
    800052c6:	32658593          	addi	a1,a1,806 # 800075e8 <etext+0x5e8>
    800052ca:	fb040513          	addi	a0,s0,-80
    800052ce:	fb8fe0ef          	jal	80003a86 <namecmp>
    800052d2:	10050163          	beqz	a0,800053d4 <sys_unlink+0x15a>
    800052d6:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    800052d8:	f2c40613          	addi	a2,s0,-212
    800052dc:	fb040593          	addi	a1,s0,-80
    800052e0:	8526                	mv	a0,s1
    800052e2:	fbafe0ef          	jal	80003a9c <dirlookup>
    800052e6:	892a                	mv	s2,a0
    800052e8:	0e050563          	beqz	a0,800053d2 <sys_unlink+0x158>
    800052ec:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800052ee:	9c6fe0ef          	jal	800034b4 <ilock>
  if (ip->nlink < 1)
    800052f2:	04a91783          	lh	a5,74(s2)
    800052f6:	06f05863          	blez	a5,80005366 <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    800052fa:	04491703          	lh	a4,68(s2)
    800052fe:	4785                	li	a5,1
    80005300:	06f70963          	beq	a4,a5,80005372 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005304:	fc040993          	addi	s3,s0,-64
    80005308:	4641                	li	a2,16
    8000530a:	4581                	li	a1,0
    8000530c:	854e                	mv	a0,s3
    8000530e:	9dbfb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005312:	4741                	li	a4,16
    80005314:	f2c42683          	lw	a3,-212(s0)
    80005318:	864e                	mv	a2,s3
    8000531a:	4581                	li	a1,0
    8000531c:	8526                	mv	a0,s1
    8000531e:	e62fe0ef          	jal	80003980 <writei>
    80005322:	47c1                	li	a5,16
    80005324:	08f51863          	bne	a0,a5,800053b4 <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    80005328:	04491703          	lh	a4,68(s2)
    8000532c:	4785                	li	a5,1
    8000532e:	08f70963          	beq	a4,a5,800053c0 <sys_unlink+0x146>
  iunlockput(dp);
    80005332:	8526                	mv	a0,s1
    80005334:	bd4fe0ef          	jal	80003708 <iunlockput>
  ip->nlink--;
    80005338:	04a95783          	lhu	a5,74(s2)
    8000533c:	37fd                	addiw	a5,a5,-1
    8000533e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005342:	854a                	mv	a0,s2
    80005344:	8bcfe0ef          	jal	80003400 <iupdate>
  iunlockput(ip);
    80005348:	854a                	mv	a0,s2
    8000534a:	bbefe0ef          	jal	80003708 <iunlockput>
  end_op();
    8000534e:	c6bfe0ef          	jal	80003fb8 <end_op>
  return 0;
    80005352:	4501                	li	a0,0
    80005354:	64ee                	ld	s1,216(sp)
    80005356:	694e                	ld	s2,208(sp)
    80005358:	69ae                	ld	s3,200(sp)
    8000535a:	a061                	j	800053e2 <sys_unlink+0x168>
    end_op();
    8000535c:	c5dfe0ef          	jal	80003fb8 <end_op>
    return -1;
    80005360:	557d                	li	a0,-1
    80005362:	64ee                	ld	s1,216(sp)
    80005364:	a8bd                	j	800053e2 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005366:	00002517          	auipc	a0,0x2
    8000536a:	28a50513          	addi	a0,a0,650 # 800075f0 <etext+0x5f0>
    8000536e:	cc6fb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005372:	04c92703          	lw	a4,76(s2)
    80005376:	02000793          	li	a5,32
    8000537a:	f8e7f5e3          	bgeu	a5,a4,80005304 <sys_unlink+0x8a>
    8000537e:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005380:	4741                	li	a4,16
    80005382:	86ce                	mv	a3,s3
    80005384:	f1840613          	addi	a2,s0,-232
    80005388:	4581                	li	a1,0
    8000538a:	854a                	mv	a0,s2
    8000538c:	d02fe0ef          	jal	8000388e <readi>
    80005390:	47c1                	li	a5,16
    80005392:	00f51b63          	bne	a0,a5,800053a8 <sys_unlink+0x12e>
    if (de.inum != 0)
    80005396:	f1845783          	lhu	a5,-232(s0)
    8000539a:	ebb1                	bnez	a5,800053ee <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000539c:	29c1                	addiw	s3,s3,16
    8000539e:	04c92783          	lw	a5,76(s2)
    800053a2:	fcf9efe3          	bltu	s3,a5,80005380 <sys_unlink+0x106>
    800053a6:	bfb9                	j	80005304 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800053a8:	00002517          	auipc	a0,0x2
    800053ac:	26050513          	addi	a0,a0,608 # 80007608 <etext+0x608>
    800053b0:	c84fb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    800053b4:	00002517          	auipc	a0,0x2
    800053b8:	26c50513          	addi	a0,a0,620 # 80007620 <etext+0x620>
    800053bc:	c78fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    800053c0:	04a4d783          	lhu	a5,74(s1)
    800053c4:	37fd                	addiw	a5,a5,-1
    800053c6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800053ca:	8526                	mv	a0,s1
    800053cc:	834fe0ef          	jal	80003400 <iupdate>
    800053d0:	b78d                	j	80005332 <sys_unlink+0xb8>
    800053d2:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800053d4:	8526                	mv	a0,s1
    800053d6:	b32fe0ef          	jal	80003708 <iunlockput>
  end_op();
    800053da:	bdffe0ef          	jal	80003fb8 <end_op>
  return -1;
    800053de:	557d                	li	a0,-1
    800053e0:	64ee                	ld	s1,216(sp)
}
    800053e2:	70ae                	ld	ra,232(sp)
    800053e4:	740e                	ld	s0,224(sp)
    800053e6:	616d                	addi	sp,sp,240
    800053e8:	8082                	ret
    return -1;
    800053ea:	557d                	li	a0,-1
    800053ec:	bfdd                	j	800053e2 <sys_unlink+0x168>
    iunlockput(ip);
    800053ee:	854a                	mv	a0,s2
    800053f0:	b18fe0ef          	jal	80003708 <iunlockput>
    goto bad;
    800053f4:	694e                	ld	s2,208(sp)
    800053f6:	69ae                	ld	s3,200(sp)
    800053f8:	bff1                	j	800053d4 <sys_unlink+0x15a>

00000000800053fa <sys_open>:

uint64
sys_open(void)
{
    800053fa:	7131                	addi	sp,sp,-192
    800053fc:	fd06                	sd	ra,184(sp)
    800053fe:	f922                	sd	s0,176(sp)
    80005400:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005402:	f4c40593          	addi	a1,s0,-180
    80005406:	4505                	li	a0,1
    80005408:	e80fd0ef          	jal	80002a88 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000540c:	08000613          	li	a2,128
    80005410:	f5040593          	addi	a1,s0,-176
    80005414:	4501                	li	a0,0
    80005416:	eaafd0ef          	jal	80002ac0 <argstr>
    8000541a:	87aa                	mv	a5,a0
    return -1;
    8000541c:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000541e:	0a07c363          	bltz	a5,800054c4 <sys_open+0xca>
    80005422:	f526                	sd	s1,168(sp)

  begin_op();
    80005424:	b09fe0ef          	jal	80003f2c <begin_op>

  if (omode & O_CREATE) {
    80005428:	f4c42783          	lw	a5,-180(s0)
    8000542c:	2007f793          	andi	a5,a5,512
    80005430:	c3dd                	beqz	a5,800054d6 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005432:	4681                	li	a3,0
    80005434:	4601                	li	a2,0
    80005436:	4589                	li	a1,2
    80005438:	f5040513          	addi	a0,s0,-176
    8000543c:	a5dff0ef          	jal	80004e98 <create>
    80005440:	84aa                	mv	s1,a0
    if (ip == 0) {
    80005442:	c549                	beqz	a0,800054cc <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    80005444:	04449703          	lh	a4,68(s1)
    80005448:	478d                	li	a5,3
    8000544a:	00f71763          	bne	a4,a5,80005458 <sys_open+0x5e>
    8000544e:	0464d703          	lhu	a4,70(s1)
    80005452:	47a5                	li	a5,9
    80005454:	0ae7ee63          	bltu	a5,a4,80005510 <sys_open+0x116>
    80005458:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    8000545a:	ee9fe0ef          	jal	80004342 <filealloc>
    8000545e:	892a                	mv	s2,a0
    80005460:	c561                	beqz	a0,80005528 <sys_open+0x12e>
    80005462:	ed4e                	sd	s3,152(sp)
    80005464:	9f5ff0ef          	jal	80004e58 <fdalloc>
    80005468:	89aa                	mv	s3,a0
    8000546a:	0a054b63          	bltz	a0,80005520 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    8000546e:	04449703          	lh	a4,68(s1)
    80005472:	478d                	li	a5,3
    80005474:	0cf70363          	beq	a4,a5,8000553a <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005478:	4789                	li	a5,2
    8000547a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000547e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005482:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005486:	f4c42783          	lw	a5,-180(s0)
    8000548a:	0017f713          	andi	a4,a5,1
    8000548e:	00174713          	xori	a4,a4,1
    80005492:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005496:	0037f713          	andi	a4,a5,3
    8000549a:	00e03733          	snez	a4,a4
    8000549e:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    800054a2:	4007f793          	andi	a5,a5,1024
    800054a6:	c791                	beqz	a5,800054b2 <sys_open+0xb8>
    800054a8:	04449703          	lh	a4,68(s1)
    800054ac:	4789                	li	a5,2
    800054ae:	08f70d63          	beq	a4,a5,80005548 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800054b2:	8526                	mv	a0,s1
    800054b4:	8aefe0ef          	jal	80003562 <iunlock>
  end_op();
    800054b8:	b01fe0ef          	jal	80003fb8 <end_op>

  return fd;
    800054bc:	854e                	mv	a0,s3
    800054be:	74aa                	ld	s1,168(sp)
    800054c0:	790a                	ld	s2,160(sp)
    800054c2:	69ea                	ld	s3,152(sp)
}
    800054c4:	70ea                	ld	ra,184(sp)
    800054c6:	744a                	ld	s0,176(sp)
    800054c8:	6129                	addi	sp,sp,192
    800054ca:	8082                	ret
      end_op();
    800054cc:	aedfe0ef          	jal	80003fb8 <end_op>
      return -1;
    800054d0:	557d                	li	a0,-1
    800054d2:	74aa                	ld	s1,168(sp)
    800054d4:	bfc5                	j	800054c4 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    800054d6:	f5040513          	addi	a0,s0,-176
    800054da:	875fe0ef          	jal	80003d4e <namei>
    800054de:	84aa                	mv	s1,a0
    800054e0:	c11d                	beqz	a0,80005506 <sys_open+0x10c>
    ilock(ip);
    800054e2:	fd3fd0ef          	jal	800034b4 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    800054e6:	04449703          	lh	a4,68(s1)
    800054ea:	4785                	li	a5,1
    800054ec:	f4f71ce3          	bne	a4,a5,80005444 <sys_open+0x4a>
    800054f0:	f4c42783          	lw	a5,-180(s0)
    800054f4:	d3b5                	beqz	a5,80005458 <sys_open+0x5e>
      iunlockput(ip);
    800054f6:	8526                	mv	a0,s1
    800054f8:	a10fe0ef          	jal	80003708 <iunlockput>
      end_op();
    800054fc:	abdfe0ef          	jal	80003fb8 <end_op>
      return -1;
    80005500:	557d                	li	a0,-1
    80005502:	74aa                	ld	s1,168(sp)
    80005504:	b7c1                	j	800054c4 <sys_open+0xca>
      end_op();
    80005506:	ab3fe0ef          	jal	80003fb8 <end_op>
      return -1;
    8000550a:	557d                	li	a0,-1
    8000550c:	74aa                	ld	s1,168(sp)
    8000550e:	bf5d                	j	800054c4 <sys_open+0xca>
    iunlockput(ip);
    80005510:	8526                	mv	a0,s1
    80005512:	9f6fe0ef          	jal	80003708 <iunlockput>
    end_op();
    80005516:	aa3fe0ef          	jal	80003fb8 <end_op>
    return -1;
    8000551a:	557d                	li	a0,-1
    8000551c:	74aa                	ld	s1,168(sp)
    8000551e:	b75d                	j	800054c4 <sys_open+0xca>
      fileclose(f);
    80005520:	854a                	mv	a0,s2
    80005522:	ec5fe0ef          	jal	800043e6 <fileclose>
    80005526:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005528:	8526                	mv	a0,s1
    8000552a:	9defe0ef          	jal	80003708 <iunlockput>
    end_op();
    8000552e:	a8bfe0ef          	jal	80003fb8 <end_op>
    return -1;
    80005532:	557d                	li	a0,-1
    80005534:	74aa                	ld	s1,168(sp)
    80005536:	790a                	ld	s2,160(sp)
    80005538:	b771                	j	800054c4 <sys_open+0xca>
    f->type = FD_DEVICE;
    8000553a:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    8000553e:	04649783          	lh	a5,70(s1)
    80005542:	02f91223          	sh	a5,36(s2)
    80005546:	bf35                	j	80005482 <sys_open+0x88>
    itrunc(ip);
    80005548:	8526                	mv	a0,s1
    8000554a:	858fe0ef          	jal	800035a2 <itrunc>
    8000554e:	b795                	j	800054b2 <sys_open+0xb8>

0000000080005550 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005550:	7175                	addi	sp,sp,-144
    80005552:	e506                	sd	ra,136(sp)
    80005554:	e122                	sd	s0,128(sp)
    80005556:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005558:	9d5fe0ef          	jal	80003f2c <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    8000555c:	08000613          	li	a2,128
    80005560:	f7040593          	addi	a1,s0,-144
    80005564:	4501                	li	a0,0
    80005566:	d5afd0ef          	jal	80002ac0 <argstr>
    8000556a:	02054363          	bltz	a0,80005590 <sys_mkdir+0x40>
    8000556e:	4681                	li	a3,0
    80005570:	4601                	li	a2,0
    80005572:	4585                	li	a1,1
    80005574:	f7040513          	addi	a0,s0,-144
    80005578:	921ff0ef          	jal	80004e98 <create>
    8000557c:	c911                	beqz	a0,80005590 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000557e:	98afe0ef          	jal	80003708 <iunlockput>
  end_op();
    80005582:	a37fe0ef          	jal	80003fb8 <end_op>
  return 0;
    80005586:	4501                	li	a0,0
}
    80005588:	60aa                	ld	ra,136(sp)
    8000558a:	640a                	ld	s0,128(sp)
    8000558c:	6149                	addi	sp,sp,144
    8000558e:	8082                	ret
    end_op();
    80005590:	a29fe0ef          	jal	80003fb8 <end_op>
    return -1;
    80005594:	557d                	li	a0,-1
    80005596:	bfcd                	j	80005588 <sys_mkdir+0x38>

0000000080005598 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005598:	7135                	addi	sp,sp,-160
    8000559a:	ed06                	sd	ra,152(sp)
    8000559c:	e922                	sd	s0,144(sp)
    8000559e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800055a0:	98dfe0ef          	jal	80003f2c <begin_op>
  argint(1, &major);
    800055a4:	f6c40593          	addi	a1,s0,-148
    800055a8:	4505                	li	a0,1
    800055aa:	cdefd0ef          	jal	80002a88 <argint>
  argint(2, &minor);
    800055ae:	f6840593          	addi	a1,s0,-152
    800055b2:	4509                	li	a0,2
    800055b4:	cd4fd0ef          	jal	80002a88 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800055b8:	08000613          	li	a2,128
    800055bc:	f7040593          	addi	a1,s0,-144
    800055c0:	4501                	li	a0,0
    800055c2:	cfefd0ef          	jal	80002ac0 <argstr>
    800055c6:	02054563          	bltz	a0,800055f0 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    800055ca:	f6841683          	lh	a3,-152(s0)
    800055ce:	f6c41603          	lh	a2,-148(s0)
    800055d2:	458d                	li	a1,3
    800055d4:	f7040513          	addi	a0,s0,-144
    800055d8:	8c1ff0ef          	jal	80004e98 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800055dc:	c911                	beqz	a0,800055f0 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800055de:	92afe0ef          	jal	80003708 <iunlockput>
  end_op();
    800055e2:	9d7fe0ef          	jal	80003fb8 <end_op>
  return 0;
    800055e6:	4501                	li	a0,0
}
    800055e8:	60ea                	ld	ra,152(sp)
    800055ea:	644a                	ld	s0,144(sp)
    800055ec:	610d                	addi	sp,sp,160
    800055ee:	8082                	ret
    end_op();
    800055f0:	9c9fe0ef          	jal	80003fb8 <end_op>
    return -1;
    800055f4:	557d                	li	a0,-1
    800055f6:	bfcd                	j	800055e8 <sys_mknod+0x50>

00000000800055f8 <sys_chdir>:

uint64
sys_chdir(void)
{
    800055f8:	7135                	addi	sp,sp,-160
    800055fa:	ed06                	sd	ra,152(sp)
    800055fc:	e922                	sd	s0,144(sp)
    800055fe:	e14a                	sd	s2,128(sp)
    80005600:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005602:	b46fc0ef          	jal	80001948 <myproc>
    80005606:	892a                	mv	s2,a0

  begin_op();
    80005608:	925fe0ef          	jal	80003f2c <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    8000560c:	08000613          	li	a2,128
    80005610:	f6040593          	addi	a1,s0,-160
    80005614:	4501                	li	a0,0
    80005616:	caafd0ef          	jal	80002ac0 <argstr>
    8000561a:	04054363          	bltz	a0,80005660 <sys_chdir+0x68>
    8000561e:	e526                	sd	s1,136(sp)
    80005620:	f6040513          	addi	a0,s0,-160
    80005624:	f2afe0ef          	jal	80003d4e <namei>
    80005628:	84aa                	mv	s1,a0
    8000562a:	c915                	beqz	a0,8000565e <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000562c:	e89fd0ef          	jal	800034b4 <ilock>
  if (ip->type != T_DIR) {
    80005630:	04449703          	lh	a4,68(s1)
    80005634:	4785                	li	a5,1
    80005636:	02f71963          	bne	a4,a5,80005668 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000563a:	8526                	mv	a0,s1
    8000563c:	f27fd0ef          	jal	80003562 <iunlock>
  iput(p->cwd);
    80005640:	15093503          	ld	a0,336(s2)
    80005644:	ff3fd0ef          	jal	80003636 <iput>
  end_op();
    80005648:	971fe0ef          	jal	80003fb8 <end_op>
  p->cwd = ip;
    8000564c:	14993823          	sd	s1,336(s2)
  return 0;
    80005650:	4501                	li	a0,0
    80005652:	64aa                	ld	s1,136(sp)
}
    80005654:	60ea                	ld	ra,152(sp)
    80005656:	644a                	ld	s0,144(sp)
    80005658:	690a                	ld	s2,128(sp)
    8000565a:	610d                	addi	sp,sp,160
    8000565c:	8082                	ret
    8000565e:	64aa                	ld	s1,136(sp)
    end_op();
    80005660:	959fe0ef          	jal	80003fb8 <end_op>
    return -1;
    80005664:	557d                	li	a0,-1
    80005666:	b7fd                	j	80005654 <sys_chdir+0x5c>
    iunlockput(ip);
    80005668:	8526                	mv	a0,s1
    8000566a:	89efe0ef          	jal	80003708 <iunlockput>
    end_op();
    8000566e:	94bfe0ef          	jal	80003fb8 <end_op>
    return -1;
    80005672:	557d                	li	a0,-1
    80005674:	64aa                	ld	s1,136(sp)
    80005676:	bff9                	j	80005654 <sys_chdir+0x5c>

0000000080005678 <sys_exec>:

uint64
sys_exec(void)
{
    80005678:	7105                	addi	sp,sp,-480
    8000567a:	ef86                	sd	ra,472(sp)
    8000567c:	eba2                	sd	s0,464(sp)
    8000567e:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005680:	e2840593          	addi	a1,s0,-472
    80005684:	4505                	li	a0,1
    80005686:	c1efd0ef          	jal	80002aa4 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    8000568a:	08000613          	li	a2,128
    8000568e:	f3040593          	addi	a1,s0,-208
    80005692:	4501                	li	a0,0
    80005694:	c2cfd0ef          	jal	80002ac0 <argstr>
    80005698:	87aa                	mv	a5,a0
    return -1;
    8000569a:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    8000569c:	0e07c063          	bltz	a5,8000577c <sys_exec+0x104>
    800056a0:	e7a6                	sd	s1,456(sp)
    800056a2:	e3ca                	sd	s2,448(sp)
    800056a4:	ff4e                	sd	s3,440(sp)
    800056a6:	fb52                	sd	s4,432(sp)
    800056a8:	f756                	sd	s5,424(sp)
    800056aa:	f35a                	sd	s6,416(sp)
    800056ac:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800056ae:	e3040a13          	addi	s4,s0,-464
    800056b2:	10000613          	li	a2,256
    800056b6:	4581                	li	a1,0
    800056b8:	8552                	mv	a0,s4
    800056ba:	e2efb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    800056be:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800056c0:	89d2                	mv	s3,s4
    800056c2:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800056c4:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800056c8:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    800056ca:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800056ce:	00391513          	slli	a0,s2,0x3
    800056d2:	85d6                	mv	a1,s5
    800056d4:	e2843783          	ld	a5,-472(s0)
    800056d8:	953e                	add	a0,a0,a5
    800056da:	b22fd0ef          	jal	800029fc <fetchaddr>
    800056de:	02054663          	bltz	a0,8000570a <sys_exec+0x92>
    if (uarg == 0) {
    800056e2:	e2043783          	ld	a5,-480(s0)
    800056e6:	c7a1                	beqz	a5,8000572e <sys_exec+0xb6>
    argv[i] = kalloc();
    800056e8:	c66fb0ef          	jal	80000b4e <kalloc>
    800056ec:	85aa                	mv	a1,a0
    800056ee:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    800056f2:	cd01                	beqz	a0,8000570a <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800056f4:	865a                	mv	a2,s6
    800056f6:	e2043503          	ld	a0,-480(s0)
    800056fa:	b4cfd0ef          	jal	80002a46 <fetchstr>
    800056fe:	00054663          	bltz	a0,8000570a <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    80005702:	0905                	addi	s2,s2,1
    80005704:	09a1                	addi	s3,s3,8
    80005706:	fd7914e3          	bne	s2,s7,800056ce <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000570a:	100a0a13          	addi	s4,s4,256
    8000570e:	6088                	ld	a0,0(s1)
    80005710:	cd31                	beqz	a0,8000576c <sys_exec+0xf4>
    kfree(argv[i]);
    80005712:	b54fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005716:	04a1                	addi	s1,s1,8
    80005718:	ff449be3          	bne	s1,s4,8000570e <sys_exec+0x96>
  return -1;
    8000571c:	557d                	li	a0,-1
    8000571e:	64be                	ld	s1,456(sp)
    80005720:	691e                	ld	s2,448(sp)
    80005722:	79fa                	ld	s3,440(sp)
    80005724:	7a5a                	ld	s4,432(sp)
    80005726:	7aba                	ld	s5,424(sp)
    80005728:	7b1a                	ld	s6,416(sp)
    8000572a:	6bfa                	ld	s7,408(sp)
    8000572c:	a881                	j	8000577c <sys_exec+0x104>
      argv[i] = 0;
    8000572e:	0009079b          	sext.w	a5,s2
    80005732:	e3040593          	addi	a1,s0,-464
    80005736:	078e                	slli	a5,a5,0x3
    80005738:	97ae                	add	a5,a5,a1
    8000573a:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000573e:	f3040513          	addi	a0,s0,-208
    80005742:	b62ff0ef          	jal	80004aa4 <kexec>
    80005746:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005748:	100a0a13          	addi	s4,s4,256
    8000574c:	6088                	ld	a0,0(s1)
    8000574e:	c511                	beqz	a0,8000575a <sys_exec+0xe2>
    kfree(argv[i]);
    80005750:	b16fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005754:	04a1                	addi	s1,s1,8
    80005756:	ff449be3          	bne	s1,s4,8000574c <sys_exec+0xd4>
  return ret;
    8000575a:	854a                	mv	a0,s2
    8000575c:	64be                	ld	s1,456(sp)
    8000575e:	691e                	ld	s2,448(sp)
    80005760:	79fa                	ld	s3,440(sp)
    80005762:	7a5a                	ld	s4,432(sp)
    80005764:	7aba                	ld	s5,424(sp)
    80005766:	7b1a                	ld	s6,416(sp)
    80005768:	6bfa                	ld	s7,408(sp)
    8000576a:	a809                	j	8000577c <sys_exec+0x104>
  return -1;
    8000576c:	557d                	li	a0,-1
    8000576e:	64be                	ld	s1,456(sp)
    80005770:	691e                	ld	s2,448(sp)
    80005772:	79fa                	ld	s3,440(sp)
    80005774:	7a5a                	ld	s4,432(sp)
    80005776:	7aba                	ld	s5,424(sp)
    80005778:	7b1a                	ld	s6,416(sp)
    8000577a:	6bfa                	ld	s7,408(sp)
}
    8000577c:	60fe                	ld	ra,472(sp)
    8000577e:	645e                	ld	s0,464(sp)
    80005780:	613d                	addi	sp,sp,480
    80005782:	8082                	ret

0000000080005784 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005784:	7139                	addi	sp,sp,-64
    80005786:	fc06                	sd	ra,56(sp)
    80005788:	f822                	sd	s0,48(sp)
    8000578a:	f426                	sd	s1,40(sp)
    8000578c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000578e:	9bafc0ef          	jal	80001948 <myproc>
    80005792:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005794:	fd840593          	addi	a1,s0,-40
    80005798:	4501                	li	a0,0
    8000579a:	b0afd0ef          	jal	80002aa4 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    8000579e:	fc840593          	addi	a1,s0,-56
    800057a2:	fd040513          	addi	a0,s0,-48
    800057a6:	f7ffe0ef          	jal	80004724 <pipealloc>
    return -1;
    800057aa:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    800057ac:	0a054963          	bltz	a0,8000585e <sys_pipe+0xda>
  fd0 = -1;
    800057b0:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    800057b4:	fd043503          	ld	a0,-48(s0)
    800057b8:	ea0ff0ef          	jal	80004e58 <fdalloc>
    800057bc:	fca42223          	sw	a0,-60(s0)
    800057c0:	08054663          	bltz	a0,8000584c <sys_pipe+0xc8>
    800057c4:	fc843503          	ld	a0,-56(s0)
    800057c8:	e90ff0ef          	jal	80004e58 <fdalloc>
    800057cc:	fca42023          	sw	a0,-64(s0)
    800057d0:	06054463          	bltz	a0,80005838 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800057d4:	4711                	li	a4,4
    800057d6:	fc440693          	addi	a3,s0,-60
    800057da:	fd843603          	ld	a2,-40(s0)
    800057de:	64ac                	ld	a1,72(s1)
    800057e0:	68a8                	ld	a0,80(s1)
    800057e2:	da1fb0ef          	jal	80001582 <copyout>
    800057e6:	00054f63          	bltz	a0,80005804 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    800057ea:	4711                	li	a4,4
    800057ec:	fc040693          	addi	a3,s0,-64
    800057f0:	fd843603          	ld	a2,-40(s0)
    800057f4:	963a                	add	a2,a2,a4
    800057f6:	64ac                	ld	a1,72(s1)
    800057f8:	68a8                	ld	a0,80(s1)
    800057fa:	d89fb0ef          	jal	80001582 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800057fe:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005800:	04055f63          	bgez	a0,8000585e <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    80005804:	fc442783          	lw	a5,-60(s0)
    80005808:	078e                	slli	a5,a5,0x3
    8000580a:	0d078793          	addi	a5,a5,208
    8000580e:	97a6                	add	a5,a5,s1
    80005810:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005814:	fc042783          	lw	a5,-64(s0)
    80005818:	078e                	slli	a5,a5,0x3
    8000581a:	0d078793          	addi	a5,a5,208
    8000581e:	94be                	add	s1,s1,a5
    80005820:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005824:	fd043503          	ld	a0,-48(s0)
    80005828:	bbffe0ef          	jal	800043e6 <fileclose>
    fileclose(wf);
    8000582c:	fc843503          	ld	a0,-56(s0)
    80005830:	bb7fe0ef          	jal	800043e6 <fileclose>
    return -1;
    80005834:	57fd                	li	a5,-1
    80005836:	a025                	j	8000585e <sys_pipe+0xda>
    if (fd0 >= 0)
    80005838:	fc442783          	lw	a5,-60(s0)
    8000583c:	0007c863          	bltz	a5,8000584c <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    80005840:	078e                	slli	a5,a5,0x3
    80005842:	0d078793          	addi	a5,a5,208
    80005846:	97a6                	add	a5,a5,s1
    80005848:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000584c:	fd043503          	ld	a0,-48(s0)
    80005850:	b97fe0ef          	jal	800043e6 <fileclose>
    fileclose(wf);
    80005854:	fc843503          	ld	a0,-56(s0)
    80005858:	b8ffe0ef          	jal	800043e6 <fileclose>
    return -1;
    8000585c:	57fd                	li	a5,-1
}
    8000585e:	853e                	mv	a0,a5
    80005860:	70e2                	ld	ra,56(sp)
    80005862:	7442                	ld	s0,48(sp)
    80005864:	74a2                	ld	s1,40(sp)
    80005866:	6121                	addi	sp,sp,64
    80005868:	8082                	ret
    8000586a:	0000                	unimp
    8000586c:	0000                	unimp
	...

0000000080005870 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005870:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005872:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005874:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005876:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005878:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000587a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000587c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000587e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005880:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005882:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005884:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005886:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005888:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000588a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000588c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000588e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005890:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005892:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005894:	876fd0ef          	jal	8000290a <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005898:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000589a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000589c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000589e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800058a0:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800058a2:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800058a4:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800058a6:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800058a8:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800058aa:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800058ac:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800058ae:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800058b0:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800058b2:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800058b4:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800058b6:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800058b8:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800058ba:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800058bc:	10200073          	sret
    800058c0:	0001                	nop
    800058c2:	00000013          	nop
    800058c6:	00000013          	nop
    800058ca:	00000013          	nop

00000000800058ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800058ce:	1141                	addi	sp,sp,-16
    800058d0:	e406                	sd	ra,8(sp)
    800058d2:	e022                	sd	s0,0(sp)
    800058d4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    800058d6:	0c000737          	lui	a4,0xc000
    800058da:	4785                	li	a5,1
    800058dc:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    800058de:	c35c                	sw	a5,4(a4)
}
    800058e0:	60a2                	ld	ra,8(sp)
    800058e2:	6402                	ld	s0,0(sp)
    800058e4:	0141                	addi	sp,sp,16
    800058e6:	8082                	ret

00000000800058e8 <plicinithart>:

void
plicinithart(void)
{
    800058e8:	1141                	addi	sp,sp,-16
    800058ea:	e406                	sd	ra,8(sp)
    800058ec:	e022                	sd	s0,0(sp)
    800058ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800058f0:	824fc0ef          	jal	80001914 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    800058f4:	0085179b          	slliw	a5,a0,0x8
    800058f8:	0c002737          	lui	a4,0xc002
    800058fc:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    80005900:	97ba                	add	a5,a5,a4
    80005902:	40200713          	li	a4,1026
    80005906:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005908:	00d5151b          	slliw	a0,a0,0xd
    8000590c:	0c2017b7          	lui	a5,0xc201
    80005910:	953e                	add	a0,a0,a5
    80005912:	00052023          	sw	zero,0(a0)
}
    80005916:	60a2                	ld	ra,8(sp)
    80005918:	6402                	ld	s0,0(sp)
    8000591a:	0141                	addi	sp,sp,16
    8000591c:	8082                	ret

000000008000591e <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000591e:	1141                	addi	sp,sp,-16
    80005920:	e406                	sd	ra,8(sp)
    80005922:	e022                	sd	s0,0(sp)
    80005924:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005926:	feffb0ef          	jal	80001914 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    8000592a:	00d5151b          	slliw	a0,a0,0xd
    8000592e:	0c2017b7          	lui	a5,0xc201
    80005932:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80005934:	953e                	add	a0,a0,a5
    80005936:	4108                	lw	a0,0(a0)
  return irq;
}
    80005938:	60a2                	ld	ra,8(sp)
    8000593a:	6402                	ld	s0,0(sp)
    8000593c:	0141                	addi	sp,sp,16
    8000593e:	8082                	ret

0000000080005940 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005940:	1101                	addi	sp,sp,-32
    80005942:	ec06                	sd	ra,24(sp)
    80005944:	e822                	sd	s0,16(sp)
    80005946:	e426                	sd	s1,8(sp)
    80005948:	1000                	addi	s0,sp,32
    8000594a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000594c:	fc9fb0ef          	jal	80001914 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    80005950:	00d5179b          	slliw	a5,a0,0xd
    80005954:	0c201737          	lui	a4,0xc201
    80005958:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    8000595a:	97ba                	add	a5,a5,a4
    8000595c:	c384                	sw	s1,0(a5)
}
    8000595e:	60e2                	ld	ra,24(sp)
    80005960:	6442                	ld	s0,16(sp)
    80005962:	64a2                	ld	s1,8(sp)
    80005964:	6105                	addi	sp,sp,32
    80005966:	8082                	ret

0000000080005968 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005968:	1141                	addi	sp,sp,-16
    8000596a:	e406                	sd	ra,8(sp)
    8000596c:	e022                	sd	s0,0(sp)
    8000596e:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005970:	479d                	li	a5,7
    80005972:	04a7ca63          	blt	a5,a0,800059c6 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005976:	0001e797          	auipc	a5,0x1e
    8000597a:	e7278793          	addi	a5,a5,-398 # 800237e8 <disk>
    8000597e:	97aa                	add	a5,a5,a0
    80005980:	0187c783          	lbu	a5,24(a5)
    80005984:	e7b9                	bnez	a5,800059d2 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005986:	00451693          	slli	a3,a0,0x4
    8000598a:	0001e797          	auipc	a5,0x1e
    8000598e:	e5e78793          	addi	a5,a5,-418 # 800237e8 <disk>
    80005992:	6398                	ld	a4,0(a5)
    80005994:	9736                	add	a4,a4,a3
    80005996:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000599a:	6398                	ld	a4,0(a5)
    8000599c:	9736                	add	a4,a4,a3
    8000599e:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800059a2:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800059a6:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800059aa:	97aa                	add	a5,a5,a0
    800059ac:	4705                	li	a4,1
    800059ae:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800059b2:	0001e517          	auipc	a0,0x1e
    800059b6:	e4e50513          	addi	a0,a0,-434 # 80023800 <disk+0x18>
    800059ba:	ff8fc0ef          	jal	800021b2 <wakeup>
}
    800059be:	60a2                	ld	ra,8(sp)
    800059c0:	6402                	ld	s0,0(sp)
    800059c2:	0141                	addi	sp,sp,16
    800059c4:	8082                	ret
    panic("free_desc 1");
    800059c6:	00002517          	auipc	a0,0x2
    800059ca:	c6a50513          	addi	a0,a0,-918 # 80007630 <etext+0x630>
    800059ce:	e67fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    800059d2:	00002517          	auipc	a0,0x2
    800059d6:	c6e50513          	addi	a0,a0,-914 # 80007640 <etext+0x640>
    800059da:	e5bfa0ef          	jal	80000834 <panic>

00000000800059de <virtio_disk_init>:
{
    800059de:	1101                	addi	sp,sp,-32
    800059e0:	ec06                	sd	ra,24(sp)
    800059e2:	e822                	sd	s0,16(sp)
    800059e4:	e426                	sd	s1,8(sp)
    800059e6:	e04a                	sd	s2,0(sp)
    800059e8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800059ea:	00002597          	auipc	a1,0x2
    800059ee:	c6658593          	addi	a1,a1,-922 # 80007650 <etext+0x650>
    800059f2:	0001e517          	auipc	a0,0x1e
    800059f6:	f1e50513          	addi	a0,a0,-226 # 80023910 <disk+0x128>
    800059fa:	9aefb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800059fe:	100017b7          	lui	a5,0x10001
    80005a02:	4398                	lw	a4,0(a5)
    80005a04:	2701                	sext.w	a4,a4
    80005a06:	747277b7          	lui	a5,0x74727
    80005a0a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005a0e:	14f71863          	bne	a4,a5,80005b5e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005a12:	100017b7          	lui	a5,0x10001
    80005a16:	43dc                	lw	a5,4(a5)
    80005a18:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005a1a:	4709                	li	a4,2
    80005a1c:	14e79163          	bne	a5,a4,80005b5e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005a20:	100017b7          	lui	a5,0x10001
    80005a24:	479c                	lw	a5,8(a5)
    80005a26:	2781                	sext.w	a5,a5
    80005a28:	12e79b63          	bne	a5,a4,80005b5e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    80005a2c:	100017b7          	lui	a5,0x10001
    80005a30:	47d8                	lw	a4,12(a5)
    80005a32:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005a34:	554d47b7          	lui	a5,0x554d4
    80005a38:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005a3c:	12f71163          	bne	a4,a5,80005b5e <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a40:	100017b7          	lui	a5,0x10001
    80005a44:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a48:	4705                	li	a4,1
    80005a4a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a4c:	470d                	li	a4,3
    80005a4e:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005a50:	10001737          	lui	a4,0x10001
    80005a54:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005a56:	c7ffe6b7          	lui	a3,0xc7ffe
    80005a5a:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdac37>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005a5e:	8f75                	and	a4,a4,a3
    80005a60:	100016b7          	lui	a3,0x10001
    80005a64:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a66:	472d                	li	a4,11
    80005a68:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a6a:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005a6e:	439c                	lw	a5,0(a5)
    80005a70:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005a74:	8ba1                	andi	a5,a5,8
    80005a76:	0e078a63          	beqz	a5,80005b6a <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005a7a:	100017b7          	lui	a5,0x10001
    80005a7e:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005a82:	43fc                	lw	a5,68(a5)
    80005a84:	2781                	sext.w	a5,a5
    80005a86:	0e079863          	bnez	a5,80005b76 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005a8a:	100017b7          	lui	a5,0x10001
    80005a8e:	5bdc                	lw	a5,52(a5)
    80005a90:	2781                	sext.w	a5,a5
  if (max == 0)
    80005a92:	0e078863          	beqz	a5,80005b82 <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005a96:	471d                	li	a4,7
    80005a98:	0ef77b63          	bgeu	a4,a5,80005b8e <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005a9c:	8b2fb0ef          	jal	80000b4e <kalloc>
    80005aa0:	0001e497          	auipc	s1,0x1e
    80005aa4:	d4848493          	addi	s1,s1,-696 # 800237e8 <disk>
    80005aa8:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005aaa:	8a4fb0ef          	jal	80000b4e <kalloc>
    80005aae:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005ab0:	89efb0ef          	jal	80000b4e <kalloc>
    80005ab4:	87aa                	mv	a5,a0
    80005ab6:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005ab8:	6088                	ld	a0,0(s1)
    80005aba:	0e050063          	beqz	a0,80005b9a <virtio_disk_init+0x1bc>
    80005abe:	0001e717          	auipc	a4,0x1e
    80005ac2:	d3273703          	ld	a4,-718(a4) # 800237f0 <disk+0x8>
    80005ac6:	cb71                	beqz	a4,80005b9a <virtio_disk_init+0x1bc>
    80005ac8:	cbe9                	beqz	a5,80005b9a <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005aca:	6605                	lui	a2,0x1
    80005acc:	4581                	li	a1,0
    80005ace:	a1afb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005ad2:	0001e497          	auipc	s1,0x1e
    80005ad6:	d1648493          	addi	s1,s1,-746 # 800237e8 <disk>
    80005ada:	6605                	lui	a2,0x1
    80005adc:	4581                	li	a1,0
    80005ade:	6488                	ld	a0,8(s1)
    80005ae0:	a08fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005ae4:	6605                	lui	a2,0x1
    80005ae6:	4581                	li	a1,0
    80005ae8:	6888                	ld	a0,16(s1)
    80005aea:	9fefb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005aee:	100017b7          	lui	a5,0x10001
    80005af2:	4721                	li	a4,8
    80005af4:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005af6:	4098                	lw	a4,0(s1)
    80005af8:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005afc:	40d8                	lw	a4,4(s1)
    80005afe:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005b02:	649c                	ld	a5,8(s1)
    80005b04:	0007869b          	sext.w	a3,a5
    80005b08:	10001737          	lui	a4,0x10001
    80005b0c:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005b10:	9781                	srai	a5,a5,0x20
    80005b12:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005b16:	689c                	ld	a5,16(s1)
    80005b18:	0007869b          	sext.w	a3,a5
    80005b1c:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005b20:	9781                	srai	a5,a5,0x20
    80005b22:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005b26:	4785                	li	a5,1
    80005b28:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005b2a:	00f48c23          	sb	a5,24(s1)
    80005b2e:	00f48ca3          	sb	a5,25(s1)
    80005b32:	00f48d23          	sb	a5,26(s1)
    80005b36:	00f48da3          	sb	a5,27(s1)
    80005b3a:	00f48e23          	sb	a5,28(s1)
    80005b3e:	00f48ea3          	sb	a5,29(s1)
    80005b42:	00f48f23          	sb	a5,30(s1)
    80005b46:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005b4a:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b4e:	07272823          	sw	s2,112(a4)
}
    80005b52:	60e2                	ld	ra,24(sp)
    80005b54:	6442                	ld	s0,16(sp)
    80005b56:	64a2                	ld	s1,8(sp)
    80005b58:	6902                	ld	s2,0(sp)
    80005b5a:	6105                	addi	sp,sp,32
    80005b5c:	8082                	ret
    panic("could not find virtio disk");
    80005b5e:	00002517          	auipc	a0,0x2
    80005b62:	b0250513          	addi	a0,a0,-1278 # 80007660 <etext+0x660>
    80005b66:	ccffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005b6a:	00002517          	auipc	a0,0x2
    80005b6e:	b1650513          	addi	a0,a0,-1258 # 80007680 <etext+0x680>
    80005b72:	cc3fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005b76:	00002517          	auipc	a0,0x2
    80005b7a:	b2a50513          	addi	a0,a0,-1238 # 800076a0 <etext+0x6a0>
    80005b7e:	cb7fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005b82:	00002517          	auipc	a0,0x2
    80005b86:	b3e50513          	addi	a0,a0,-1218 # 800076c0 <etext+0x6c0>
    80005b8a:	cabfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005b8e:	00002517          	auipc	a0,0x2
    80005b92:	b5250513          	addi	a0,a0,-1198 # 800076e0 <etext+0x6e0>
    80005b96:	c9ffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005b9a:	00002517          	auipc	a0,0x2
    80005b9e:	b6650513          	addi	a0,a0,-1178 # 80007700 <etext+0x700>
    80005ba2:	c93fa0ef          	jal	80000834 <panic>

0000000080005ba6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ba6:	711d                	addi	sp,sp,-96
    80005ba8:	ec86                	sd	ra,88(sp)
    80005baa:	e8a2                	sd	s0,80(sp)
    80005bac:	e4a6                	sd	s1,72(sp)
    80005bae:	e0ca                	sd	s2,64(sp)
    80005bb0:	fc4e                	sd	s3,56(sp)
    80005bb2:	f852                	sd	s4,48(sp)
    80005bb4:	f456                	sd	s5,40(sp)
    80005bb6:	f05a                	sd	s6,32(sp)
    80005bb8:	ec5e                	sd	s7,24(sp)
    80005bba:	e862                	sd	s8,16(sp)
    80005bbc:	1080                	addi	s0,sp,96
    80005bbe:	89aa                	mv	s3,a0
    80005bc0:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005bc2:	00c52b83          	lw	s7,12(a0)
    80005bc6:	001b9b9b          	slliw	s7,s7,0x1
    80005bca:	1b82                	slli	s7,s7,0x20
    80005bcc:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005bd0:	0001e517          	auipc	a0,0x1e
    80005bd4:	d4050513          	addi	a0,a0,-704 # 80023910 <disk+0x128>
    80005bd8:	850fb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005bdc:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005bde:	0001ea97          	auipc	s5,0x1e
    80005be2:	c0aa8a93          	addi	s5,s5,-1014 # 800237e8 <disk>
  for (int i = 0; i < 3; i++) {
    80005be6:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005be8:	5c7d                	li	s8,-1
    80005bea:	a8a5                	j	80005c62 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005bec:	00fa8733          	add	a4,s5,a5
    80005bf0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005bf4:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005bf6:	0207c563          	bltz	a5,80005c20 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005bfa:	2905                	addiw	s2,s2,1
    80005bfc:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005bfe:	07490663          	beq	s2,s4,80005c6a <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005c02:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005c04:	0001e717          	auipc	a4,0x1e
    80005c08:	be470713          	addi	a4,a4,-1052 # 800237e8 <disk>
    80005c0c:	4781                	li	a5,0
    if (disk.free[i]) {
    80005c0e:	01874683          	lbu	a3,24(a4)
    80005c12:	fee9                	bnez	a3,80005bec <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005c14:	2785                	addiw	a5,a5,1
    80005c16:	0705                	addi	a4,a4,1
    80005c18:	fe979be3          	bne	a5,s1,80005c0e <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005c1c:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005c20:	01205d63          	blez	s2,80005c3a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005c24:	fa042503          	lw	a0,-96(s0)
    80005c28:	d41ff0ef          	jal	80005968 <free_desc>
      for (int j = 0; j < i; j++)
    80005c2c:	4785                	li	a5,1
    80005c2e:	0127d663          	bge	a5,s2,80005c3a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005c32:	fa442503          	lw	a0,-92(s0)
    80005c36:	d33ff0ef          	jal	80005968 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005c3a:	0001e517          	auipc	a0,0x1e
    80005c3e:	bc650513          	addi	a0,a0,-1082 # 80023800 <disk+0x18>
    80005c42:	d04fc0ef          	jal	80002146 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005c46:	0001e517          	auipc	a0,0x1e
    80005c4a:	cca50513          	addi	a0,a0,-822 # 80023910 <disk+0x128>
    80005c4e:	862fb0ef          	jal	80000cb0 <release>
    sleep();
    80005c52:	d30fc0ef          	jal	80002182 <sleep>
    acquire(&disk.vdisk_lock);
    80005c56:	0001e517          	auipc	a0,0x1e
    80005c5a:	cba50513          	addi	a0,a0,-838 # 80023910 <disk+0x128>
    80005c5e:	fcbfa0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005c62:	fa040613          	addi	a2,s0,-96
    80005c66:	4901                	li	s2,0
    80005c68:	bf69                	j	80005c02 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005c6a:	fa042503          	lw	a0,-96(s0)
    80005c6e:	00451693          	slli	a3,a0,0x4

  if (write)
    80005c72:	0001e797          	auipc	a5,0x1e
    80005c76:	b7678793          	addi	a5,a5,-1162 # 800237e8 <disk>
    80005c7a:	00451713          	slli	a4,a0,0x4
    80005c7e:	0a070713          	addi	a4,a4,160
    80005c82:	973e                	add	a4,a4,a5
    80005c84:	01603633          	snez	a2,s6
    80005c88:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005c8a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005c8e:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005c92:	6398                	ld	a4,0(a5)
    80005c94:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005c96:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005c9a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005c9c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005c9e:	6390                	ld	a2,0(a5)
    80005ca0:	00d60833          	add	a6,a2,a3
    80005ca4:	4741                	li	a4,16
    80005ca6:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005caa:	4585                	li	a1,1
    80005cac:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005cb0:	fa442703          	lw	a4,-92(s0)
    80005cb4:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005cb8:	0712                	slli	a4,a4,0x4
    80005cba:	963a                	add	a2,a2,a4
    80005cbc:	05898813          	addi	a6,s3,88
    80005cc0:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005cc4:	0007b883          	ld	a7,0(a5)
    80005cc8:	9746                	add	a4,a4,a7
    80005cca:	40000613          	li	a2,1024
    80005cce:	c710                	sw	a2,8(a4)
  if (write)
    80005cd0:	001b3613          	seqz	a2,s6
    80005cd4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005cd8:	8e4d                	or	a2,a2,a1
    80005cda:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005cde:	fa842603          	lw	a2,-88(s0)
    80005ce2:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005ce6:	00451813          	slli	a6,a0,0x4
    80005cea:	02080813          	addi	a6,a6,32
    80005cee:	983e                	add	a6,a6,a5
    80005cf0:	577d                	li	a4,-1
    80005cf2:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005cf6:	0612                	slli	a2,a2,0x4
    80005cf8:	98b2                	add	a7,a7,a2
    80005cfa:	03068713          	addi	a4,a3,48
    80005cfe:	973e                	add	a4,a4,a5
    80005d00:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005d04:	6398                	ld	a4,0(a5)
    80005d06:	9732                	add	a4,a4,a2
    80005d08:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005d0a:	4689                	li	a3,2
    80005d0c:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005d10:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005d14:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005d18:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005d1c:	6794                	ld	a3,8(a5)
    80005d1e:	0026d703          	lhu	a4,2(a3)
    80005d22:	8b1d                	andi	a4,a4,7
    80005d24:	0706                	slli	a4,a4,0x1
    80005d26:	96ba                	add	a3,a3,a4
    80005d28:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005d2c:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005d30:	6798                	ld	a4,8(a5)
    80005d32:	00275783          	lhu	a5,2(a4)
    80005d36:	2785                	addiw	a5,a5,1
    80005d38:	00f71123          	sh	a5,2(a4)
    80005d3c:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005d40:	100017b7          	lui	a5,0x10001
    80005d44:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005d48:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005d4c:	0001e497          	auipc	s1,0x1e
    80005d50:	bc448493          	addi	s1,s1,-1084 # 80023910 <disk+0x128>
  while (b->disk == 1) {
    80005d54:	892e                	mv	s2,a1
    80005d56:	02b79163          	bne	a5,a1,80005d78 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005d5a:	854e                	mv	a0,s3
    80005d5c:	beafc0ef          	jal	80002146 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005d60:	8526                	mv	a0,s1
    80005d62:	f4ffa0ef          	jal	80000cb0 <release>
    sleep();
    80005d66:	c1cfc0ef          	jal	80002182 <sleep>
    acquire(&disk.vdisk_lock);
    80005d6a:	8526                	mv	a0,s1
    80005d6c:	ebdfa0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005d70:	0049a783          	lw	a5,4(s3)
    80005d74:	ff2783e3          	beq	a5,s2,80005d5a <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005d78:	fa042903          	lw	s2,-96(s0)
    80005d7c:	00491713          	slli	a4,s2,0x4
    80005d80:	02070713          	addi	a4,a4,32
    80005d84:	0001e797          	auipc	a5,0x1e
    80005d88:	a6478793          	addi	a5,a5,-1436 # 800237e8 <disk>
    80005d8c:	97ba                	add	a5,a5,a4
    80005d8e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005d92:	0001e997          	auipc	s3,0x1e
    80005d96:	a5698993          	addi	s3,s3,-1450 # 800237e8 <disk>
    80005d9a:	00491713          	slli	a4,s2,0x4
    80005d9e:	0009b783          	ld	a5,0(s3)
    80005da2:	97ba                	add	a5,a5,a4
    80005da4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005da8:	854a                	mv	a0,s2
    80005daa:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005dae:	bbbff0ef          	jal	80005968 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005db2:	8885                	andi	s1,s1,1
    80005db4:	f0fd                	bnez	s1,80005d9a <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005db6:	0001e517          	auipc	a0,0x1e
    80005dba:	b5a50513          	addi	a0,a0,-1190 # 80023910 <disk+0x128>
    80005dbe:	ef3fa0ef          	jal	80000cb0 <release>
}
    80005dc2:	60e6                	ld	ra,88(sp)
    80005dc4:	6446                	ld	s0,80(sp)
    80005dc6:	64a6                	ld	s1,72(sp)
    80005dc8:	6906                	ld	s2,64(sp)
    80005dca:	79e2                	ld	s3,56(sp)
    80005dcc:	7a42                	ld	s4,48(sp)
    80005dce:	7aa2                	ld	s5,40(sp)
    80005dd0:	7b02                	ld	s6,32(sp)
    80005dd2:	6be2                	ld	s7,24(sp)
    80005dd4:	6c42                	ld	s8,16(sp)
    80005dd6:	6125                	addi	sp,sp,96
    80005dd8:	8082                	ret

0000000080005dda <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005dda:	1101                	addi	sp,sp,-32
    80005ddc:	ec06                	sd	ra,24(sp)
    80005dde:	e822                	sd	s0,16(sp)
    80005de0:	e426                	sd	s1,8(sp)
    80005de2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005de4:	0001e497          	auipc	s1,0x1e
    80005de8:	a0448493          	addi	s1,s1,-1532 # 800237e8 <disk>
    80005dec:	0001e517          	auipc	a0,0x1e
    80005df0:	b2450513          	addi	a0,a0,-1244 # 80023910 <disk+0x128>
    80005df4:	e35fa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005df8:	100017b7          	lui	a5,0x10001
    80005dfc:	53bc                	lw	a5,96(a5)
    80005dfe:	8b8d                	andi	a5,a5,3
    80005e00:	10001737          	lui	a4,0x10001
    80005e04:	d37c                	sw	a5,100(a4)
    80005e06:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005e0a:	689c                	ld	a5,16(s1)
    80005e0c:	0204d703          	lhu	a4,32(s1)
    80005e10:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005e14:	04f70863          	beq	a4,a5,80005e64 <virtio_disk_intr+0x8a>
    80005e18:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005e1c:	6898                	ld	a4,16(s1)
    80005e1e:	0204d783          	lhu	a5,32(s1)
    80005e22:	8b9d                	andi	a5,a5,7
    80005e24:	078e                	slli	a5,a5,0x3
    80005e26:	97ba                	add	a5,a5,a4
    80005e28:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005e2a:	00479713          	slli	a4,a5,0x4
    80005e2e:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005e32:	9726                	add	a4,a4,s1
    80005e34:	01074703          	lbu	a4,16(a4)
    80005e38:	e329                	bnez	a4,80005e7a <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005e3a:	0792                	slli	a5,a5,0x4
    80005e3c:	02078793          	addi	a5,a5,32
    80005e40:	97a6                	add	a5,a5,s1
    80005e42:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005e44:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005e48:	b6afc0ef          	jal	800021b2 <wakeup>

    disk.used_idx += 1;
    80005e4c:	0204d783          	lhu	a5,32(s1)
    80005e50:	2785                	addiw	a5,a5,1
    80005e52:	17c2                	slli	a5,a5,0x30
    80005e54:	93c1                	srli	a5,a5,0x30
    80005e56:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005e5a:	6898                	ld	a4,16(s1)
    80005e5c:	00275703          	lhu	a4,2(a4)
    80005e60:	faf71ce3          	bne	a4,a5,80005e18 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005e64:	0001e517          	auipc	a0,0x1e
    80005e68:	aac50513          	addi	a0,a0,-1364 # 80023910 <disk+0x128>
    80005e6c:	e45fa0ef          	jal	80000cb0 <release>
}
    80005e70:	60e2                	ld	ra,24(sp)
    80005e72:	6442                	ld	s0,16(sp)
    80005e74:	64a2                	ld	s1,8(sp)
    80005e76:	6105                	addi	sp,sp,32
    80005e78:	8082                	ret
      panic("virtio_disk_intr status");
    80005e7a:	00002517          	auipc	a0,0x2
    80005e7e:	89e50513          	addi	a0,a0,-1890 # 80007718 <etext+0x718>
    80005e82:	9b3fa0ef          	jal	80000834 <panic>
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
