
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
    80000004:	35813103          	ld	sp,856(sp) # 8000a358 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdaf57>
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
    8000011c:	360020ef          	jal	8000247c <either_copyin>
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
    80000198:	20c50513          	addi	a0,a0,524 # 800123a0 <cons>
    8000019c:	28d000ef          	jal	80000c28 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	20048493          	addi	s1,s1,512 # 800123a0 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	29090913          	addi	s2,s2,656 # 80012438 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	788010ef          	jal	80001948 <myproc>
    800001c4:	138020ef          	jal	800022fc <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	6cf010ef          	jal	8000209a <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	701010ef          	jal	800020d6 <sleep>
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
    800001f2:	1b270713          	addi	a4,a4,434 # 800123a0 <cons>
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
    80000220:	210020ef          	jal	80002430 <either_copyout>
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
    8000023c:	16850513          	addi	a0,a0,360 # 800123a0 <cons>
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
    80000262:	1cf72d23          	sw	a5,474(a4) # 80012438 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	12c50513          	addi	a0,a0,300 # 800123a0 <cons>
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
    800002cc:	0d850513          	addi	a0,a0,216 # 800123a0 <cons>
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
    800002ea:	1de020ef          	jal	800024c8 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	0b250513          	addi	a0,a0,178 # 800123a0 <cons>
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
    80000310:	09470713          	addi	a4,a4,148 # 800123a0 <cons>
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
    80000336:	06e70713          	addi	a4,a4,110 # 800123a0 <cons>
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
    80000360:	0dc72703          	lw	a4,220(a4) # 80012438 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	02e70713          	addi	a4,a4,46 # 800123a0 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	01e48493          	addi	s1,s1,30 # 800123a0 <cons>
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
    800003c8:	fdc70713          	addi	a4,a4,-36 # 800123a0 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	06f72323          	sw	a5,102(a4) # 80012440 <cons+0xa0>
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
    800003fc:	fa878793          	addi	a5,a5,-88 # 800123a0 <cons>
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
    8000041e:	02c7a123          	sw	a2,34(a5) # 8001243c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	01650513          	addi	a0,a0,22 # 80012438 <cons+0x98>
    8000042a:	4e1010ef          	jal	8000210a <wakeup>
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
    80000444:	f6050513          	addi	a0,a0,-160 # 800123a0 <cons>
    80000448:	760000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	2c078793          	addi	a5,a5,704 # 80022710 <devsw>
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
    8000052c:	e4c7a783          	lw	a5,-436(a5) # 8000a374 <panicking>
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
    80000572:	eda50513          	addi	a0,a0,-294 # 80012448 <pr>
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
    8000076e:	c0a7a783          	lw	a5,-1014(a5) # 8000a374 <panicking>
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
    80000798:	cb450513          	addi	a0,a0,-844 # 80012448 <pr>
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
    80000848:	b297a823          	sw	s1,-1232(a5) # 8000a374 <panicking>
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
    8000086a:	b097a523          	sw	s1,-1270(a5) # 8000a370 <panicked>
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
    80000884:	bc850513          	addi	a0,a0,-1080 # 80012448 <pr>
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
    800008da:	b8a50513          	addi	a0,a0,-1142 # 80012460 <tx_lock>
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
    800008fe:	b6650513          	addi	a0,a0,-1178 # 80012460 <tx_lock>
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
    8000091c:	a6490913          	addi	s2,s2,-1436 # 8000a37c <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	a5898993          	addi	s3,s3,-1448 # 8000a378 <tx_chan>
      release(&tx_lock);
    80000928:	00012497          	auipc	s1,0x12
    8000092c:	b3848493          	addi	s1,s1,-1224 # 80012460 <tx_lock>
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
    8000093a:	760010ef          	jal	8000209a <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	792010ef          	jal	800020d6 <sleep>
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
    8000097c:	ae850513          	addi	a0,a0,-1304 # 80012460 <tx_lock>
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
    800009a0:	9d87a783          	lw	a5,-1576(a5) # 8000a374 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	9ca7a783          	lw	a5,-1590(a5) # 8000a370 <panicked>
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
    800009d0:	9a87a783          	lw	a5,-1624(a5) # 8000a374 <panicking>
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
    80000a06:	a5e50513          	addi	a0,a0,-1442 # 80012460 <tx_lock>
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
    80000a20:	a4450513          	addi	a0,a0,-1468 # 80012460 <tx_lock>
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
    80000a48:	9207ac23          	sw	zero,-1736(a5) # 8000a37c <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	92c50513          	addi	a0,a0,-1748 # 8000a378 <tx_chan>
    80000a54:	6b6010ef          	jal	8000210a <wakeup>
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
    80000a76:	e3678793          	addi	a5,a5,-458 # 800238a8 <end>
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
    80000aa0:	9dc90913          	addi	s2,s2,-1572 # 80012478 <kmem>
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
    80000b2e:	94e50513          	addi	a0,a0,-1714 # 80012478 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00023517          	auipc	a0,0x23
    80000b3e:	d6e50513          	addi	a0,a0,-658 # 800238a8 <end>
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
    80000b5c:	92050513          	addi	a0,a0,-1760 # 80012478 <kmem>
    80000b60:	0c8000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b64:	00012497          	auipc	s1,0x12
    80000b68:	92c4b483          	ld	s1,-1748(s1) # 80012490 <kmem+0x18>
  if (r)
    80000b6c:	c49d                	beqz	s1,80000b9a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00012717          	auipc	a4,0x12
    80000b74:	92f73023          	sd	a5,-1760(a4) # 80012490 <kmem+0x18>
  release(&kmem.lock);
    80000b78:	00012517          	auipc	a0,0x12
    80000b7c:	90050513          	addi	a0,a0,-1792 # 80012478 <kmem>
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
    80000b9e:	8de50513          	addi	a0,a0,-1826 # 80012478 <kmem>
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
    80000eae:	4d670713          	addi	a4,a4,1238 # 8000a380 <started>
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
    80000ed4:	726010ef          	jal	800025fa <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	141040ef          	jal	80005818 <plicinithart>
  }

  scheduler();
    80000edc:	7cb000ef          	jal	80001ea6 <scheduler>
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
    80000f1c:	6ba010ef          	jal	800025d6 <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	6da010ef          	jal	800025fa <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	0db040ef          	jal	800057fe <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	0f1040ef          	jal	80005818 <plicinithart>
    binit();            // buffer cache
    80000f2c:	59b010ef          	jal	80002cc6 <binit>
    iinit();            // inode table
    80000f30:	2ec020ef          	jal	8000321c <iinit>
    fileinit();         // file table
    80000f34:	31a030ef          	jal	8000424e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	1d7040ef          	jal	8000590e <virtio_disk_init>
    userinit();         // first user process
    80000f3c:	4df000ef          	jal	80001c1a <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f40:	00009797          	auipc	a5,0x9
    80000f44:	44078793          	addi	a5,a5,1088 # 8000a380 <started>
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
    80000f62:	42a7b783          	ld	a5,1066(a5) # 8000a388 <kernel_pagetable>
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
    800011ee:	18a7bf23          	sd	a0,414(a5) # 8000a388 <kernel_pagetable>
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
    80001724:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb758>
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
    800017d8:	0f448493          	addi	s1,s1,244 # 800128c8 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017dc:	8c26                	mv	s8,s1
    800017de:	ff4df937          	lui	s2,0xff4df
    800017e2:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb115>
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
    80001808:	cc4a8a93          	addi	s5,s5,-828 # 800184c8 <tickslock>
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
    8000187e:	c1e50513          	addi	a0,a0,-994 # 80012498 <pid_lock>
    80001882:	b26ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001886:	00006597          	auipc	a1,0x6
    8000188a:	8e258593          	addi	a1,a1,-1822 # 80007168 <etext+0x168>
    8000188e:	00011517          	auipc	a0,0x11
    80001892:	c2250513          	addi	a0,a0,-990 # 800124b0 <wait_lock>
    80001896:	b12ff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000189a:	00011497          	auipc	s1,0x11
    8000189e:	02e48493          	addi	s1,s1,46 # 800128c8 <proc>
    initlock(&p->lock, "proc");
    800018a2:	00006b17          	auipc	s6,0x6
    800018a6:	8d6b0b13          	addi	s6,s6,-1834 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018aa:	8aa6                	mv	s5,s1
    800018ac:	ff4df937          	lui	s2,0xff4df
    800018b0:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb115>
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
    800018d2:	bfaa0a13          	addi	s4,s4,-1030 # 800184c8 <tickslock>
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
    8000193a:	b9250513          	addi	a0,a0,-1134 # 800124c8 <cpus>
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
    80001960:	b3c70713          	addi	a4,a4,-1220 # 80012498 <pid_lock>
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
    80001992:	9b27a783          	lw	a5,-1614(a5) # 8000a340 <first.1>
    80001996:	cf85                	beqz	a5,800019ce <forkret+0x54>
    first = 0;
    80001998:	00009797          	auipc	a5,0x9
    8000199c:	9a07a423          	sw	zero,-1624(a5) # 8000a340 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019a0:	4505                	li	a0,1
    800019a2:	57f010ef          	jal	80003720 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019a6:	00005797          	auipc	a5,0x5
    800019aa:	7da78793          	addi	a5,a5,2010 # 80007180 <etext+0x180>
    800019ae:	fcf43823          	sd	a5,-48(s0)
    800019b2:	fc043c23          	sd	zero,-40(s0)
    800019b6:	fd040593          	addi	a1,s0,-48
    800019ba:	853e                	mv	a0,a5
    800019bc:	018030ef          	jal	800049d4 <kexec>
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
    800019ce:	449000ef          	jal	80002616 <prepare_return>
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
    80001a1e:	a7e50513          	addi	a0,a0,-1410 # 80012498 <pid_lock>
    80001a22:	a06ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a26:	00009797          	auipc	a5,0x9
    80001a2a:	91e78793          	addi	a5,a5,-1762 # 8000a344 <nextpid>
    80001a2e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a30:	0014871b          	addiw	a4,s1,1
    80001a34:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a36:	00011517          	auipc	a0,0x11
    80001a3a:	a6250513          	addi	a0,a0,-1438 # 80012498 <pid_lock>
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
  p->queue_level = 0;
    80001b5a:	1604a423          	sw	zero,360(s1)
  p->ticks_used = 0;
    80001b5e:	1604a623          	sw	zero,364(s1)
}
    80001b62:	60e2                	ld	ra,24(sp)
    80001b64:	6442                	ld	s0,16(sp)
    80001b66:	64a2                	ld	s1,8(sp)
    80001b68:	6105                	addi	sp,sp,32
    80001b6a:	8082                	ret

0000000080001b6c <allocproc>:
{
    80001b6c:	1101                	addi	sp,sp,-32
    80001b6e:	ec06                	sd	ra,24(sp)
    80001b70:	e822                	sd	s0,16(sp)
    80001b72:	e426                	sd	s1,8(sp)
    80001b74:	e04a                	sd	s2,0(sp)
    80001b76:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b78:	00011497          	auipc	s1,0x11
    80001b7c:	d5048493          	addi	s1,s1,-688 # 800128c8 <proc>
    80001b80:	00017917          	auipc	s2,0x17
    80001b84:	94890913          	addi	s2,s2,-1720 # 800184c8 <tickslock>
    acquire(&p->lock);
    80001b88:	8526                	mv	a0,s1
    80001b8a:	89eff0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001b8e:	4c9c                	lw	a5,24(s1)
    80001b90:	cb91                	beqz	a5,80001ba4 <allocproc+0x38>
      release(&p->lock);
    80001b92:	8526                	mv	a0,s1
    80001b94:	91cff0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b98:	17048493          	addi	s1,s1,368
    80001b9c:	ff2496e3          	bne	s1,s2,80001b88 <allocproc+0x1c>
  return 0;
    80001ba0:	4481                	li	s1,0
    80001ba2:	a0a9                	j	80001bec <allocproc+0x80>
  p->pid = allocpid();
    80001ba4:	e6dff0ef          	jal	80001a10 <allocpid>
    80001ba8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001baa:	4785                	li	a5,1
    80001bac:	cc9c                	sw	a5,24(s1)
  p->queue_level = 0;
    80001bae:	1604a423          	sw	zero,360(s1)
  p->ticks_used = 0;
    80001bb2:	1604a623          	sw	zero,364(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bb6:	f99fe0ef          	jal	80000b4e <kalloc>
    80001bba:	892a                	mv	s2,a0
    80001bbc:	eca8                	sd	a0,88(s1)
    80001bbe:	cd15                	beqz	a0,80001bfa <allocproc+0x8e>
  p->pagetable = proc_pagetable(p);
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	e8dff0ef          	jal	80001a4e <proc_pagetable>
    80001bc6:	892a                	mv	s2,a0
    80001bc8:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001bca:	c121                	beqz	a0,80001c0a <allocproc+0x9e>
  memset(&p->context, 0, sizeof(p->context));
    80001bcc:	07000613          	li	a2,112
    80001bd0:	4581                	li	a1,0
    80001bd2:	06048513          	addi	a0,s1,96
    80001bd6:	912ff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001bda:	00000797          	auipc	a5,0x0
    80001bde:	da078793          	addi	a5,a5,-608 # 8000197a <forkret>
    80001be2:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001be4:	60bc                	ld	a5,64(s1)
    80001be6:	6705                	lui	a4,0x1
    80001be8:	97ba                	add	a5,a5,a4
    80001bea:	f4bc                	sd	a5,104(s1)
}
    80001bec:	8526                	mv	a0,s1
    80001bee:	60e2                	ld	ra,24(sp)
    80001bf0:	6442                	ld	s0,16(sp)
    80001bf2:	64a2                	ld	s1,8(sp)
    80001bf4:	6902                	ld	s2,0(sp)
    80001bf6:	6105                	addi	sp,sp,32
    80001bf8:	8082                	ret
    freeproc(p);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	f1dff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001c00:	8526                	mv	a0,s1
    80001c02:	8aeff0ef          	jal	80000cb0 <release>
    return 0;
    80001c06:	84ca                	mv	s1,s2
    80001c08:	b7d5                	j	80001bec <allocproc+0x80>
    freeproc(p);
    80001c0a:	8526                	mv	a0,s1
    80001c0c:	f0dff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001c10:	8526                	mv	a0,s1
    80001c12:	89eff0ef          	jal	80000cb0 <release>
    return 0;
    80001c16:	84ca                	mv	s1,s2
    80001c18:	bfd1                	j	80001bec <allocproc+0x80>

0000000080001c1a <userinit>:
{
    80001c1a:	1101                	addi	sp,sp,-32
    80001c1c:	ec06                	sd	ra,24(sp)
    80001c1e:	e822                	sd	s0,16(sp)
    80001c20:	e426                	sd	s1,8(sp)
    80001c22:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c24:	f49ff0ef          	jal	80001b6c <allocproc>
    80001c28:	84aa                	mv	s1,a0
  initproc = p;
    80001c2a:	00008797          	auipc	a5,0x8
    80001c2e:	76a7b323          	sd	a0,1894(a5) # 8000a390 <initproc>
  p->cwd = namei("/");
    80001c32:	00005517          	auipc	a0,0x5
    80001c36:	55e50513          	addi	a0,a0,1374 # 80007190 <etext+0x190>
    80001c3a:	044020ef          	jal	80003c7e <namei>
    80001c3e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c42:	478d                	li	a5,3
    80001c44:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c46:	8526                	mv	a0,s1
    80001c48:	868ff0ef          	jal	80000cb0 <release>
}
    80001c4c:	60e2                	ld	ra,24(sp)
    80001c4e:	6442                	ld	s0,16(sp)
    80001c50:	64a2                	ld	s1,8(sp)
    80001c52:	6105                	addi	sp,sp,32
    80001c54:	8082                	ret

0000000080001c56 <growproc>:
{
    80001c56:	1101                	addi	sp,sp,-32
    80001c58:	ec06                	sd	ra,24(sp)
    80001c5a:	e822                	sd	s0,16(sp)
    80001c5c:	e426                	sd	s1,8(sp)
    80001c5e:	e04a                	sd	s2,0(sp)
    80001c60:	1000                	addi	s0,sp,32
    80001c62:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c64:	ce5ff0ef          	jal	80001948 <myproc>
    80001c68:	892a                	mv	s2,a0
  sz = p->sz;
    80001c6a:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c6c:	02905963          	blez	s1,80001c9e <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c70:	00b48633          	add	a2,s1,a1
    80001c74:	020007b7          	lui	a5,0x2000
    80001c78:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c7a:	07b6                	slli	a5,a5,0xd
    80001c7c:	02c7ea63          	bltu	a5,a2,80001cb0 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c80:	4691                	li	a3,4
    80001c82:	6928                	ld	a0,80(a0)
    80001c84:	e6aff0ef          	jal	800012ee <uvmalloc>
    80001c88:	85aa                	mv	a1,a0
    80001c8a:	c50d                	beqz	a0,80001cb4 <growproc+0x5e>
  p->sz = sz;
    80001c8c:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c90:	4501                	li	a0,0
}
    80001c92:	60e2                	ld	ra,24(sp)
    80001c94:	6442                	ld	s0,16(sp)
    80001c96:	64a2                	ld	s1,8(sp)
    80001c98:	6902                	ld	s2,0(sp)
    80001c9a:	6105                	addi	sp,sp,32
    80001c9c:	8082                	ret
  } else if (n < 0) {
    80001c9e:	fe04d7e3          	bgez	s1,80001c8c <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ca2:	00b48633          	add	a2,s1,a1
    80001ca6:	6928                	ld	a0,80(a0)
    80001ca8:	e02ff0ef          	jal	800012aa <uvmdealloc>
    80001cac:	85aa                	mv	a1,a0
    80001cae:	bff9                	j	80001c8c <growproc+0x36>
      return -1;
    80001cb0:	557d                	li	a0,-1
    80001cb2:	b7c5                	j	80001c92 <growproc+0x3c>
      return -1;
    80001cb4:	557d                	li	a0,-1
    80001cb6:	bff1                	j	80001c92 <growproc+0x3c>

0000000080001cb8 <kfork>:
{
    80001cb8:	7139                	addi	sp,sp,-64
    80001cba:	fc06                	sd	ra,56(sp)
    80001cbc:	f822                	sd	s0,48(sp)
    80001cbe:	f426                	sd	s1,40(sp)
    80001cc0:	e456                	sd	s5,8(sp)
    80001cc2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cc4:	c85ff0ef          	jal	80001948 <myproc>
    80001cc8:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001cca:	ea3ff0ef          	jal	80001b6c <allocproc>
    80001cce:	0e050a63          	beqz	a0,80001dc2 <kfork+0x10a>
    80001cd2:	e852                	sd	s4,16(sp)
    80001cd4:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001cd6:	048ab603          	ld	a2,72(s5)
    80001cda:	692c                	ld	a1,80(a0)
    80001cdc:	050ab503          	ld	a0,80(s5)
    80001ce0:	f46ff0ef          	jal	80001426 <uvmcopy>
    80001ce4:	04054863          	bltz	a0,80001d34 <kfork+0x7c>
    80001ce8:	f04a                	sd	s2,32(sp)
    80001cea:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001cec:	048ab783          	ld	a5,72(s5)
    80001cf0:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001cf4:	058ab683          	ld	a3,88(s5)
    80001cf8:	87b6                	mv	a5,a3
    80001cfa:	058a3703          	ld	a4,88(s4)
    80001cfe:	12068693          	addi	a3,a3,288
    80001d02:	6388                	ld	a0,0(a5)
    80001d04:	678c                	ld	a1,8(a5)
    80001d06:	6b90                	ld	a2,16(a5)
    80001d08:	e308                	sd	a0,0(a4)
    80001d0a:	e70c                	sd	a1,8(a4)
    80001d0c:	eb10                	sd	a2,16(a4)
    80001d0e:	6f90                	ld	a2,24(a5)
    80001d10:	ef10                	sd	a2,24(a4)
    80001d12:	02078793          	addi	a5,a5,32
    80001d16:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d1a:	fed794e3          	bne	a5,a3,80001d02 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d1e:	058a3783          	ld	a5,88(s4)
    80001d22:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d26:	0d0a8493          	addi	s1,s5,208
    80001d2a:	0d0a0913          	addi	s2,s4,208
    80001d2e:	150a8993          	addi	s3,s5,336
    80001d32:	a831                	j	80001d4e <kfork+0x96>
    freeproc(np);
    80001d34:	8552                	mv	a0,s4
    80001d36:	de3ff0ef          	jal	80001b18 <freeproc>
    release(&np->lock);
    80001d3a:	8552                	mv	a0,s4
    80001d3c:	f75fe0ef          	jal	80000cb0 <release>
    return -1;
    80001d40:	54fd                	li	s1,-1
    80001d42:	6a42                	ld	s4,16(sp)
    80001d44:	a885                	j	80001db4 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d46:	04a1                	addi	s1,s1,8
    80001d48:	0921                	addi	s2,s2,8
    80001d4a:	01348963          	beq	s1,s3,80001d5c <kfork+0xa4>
    if (p->ofile[i])
    80001d4e:	6088                	ld	a0,0(s1)
    80001d50:	d97d                	beqz	a0,80001d46 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d52:	57e020ef          	jal	800042d0 <filedup>
    80001d56:	00a93023          	sd	a0,0(s2)
    80001d5a:	b7f5                	j	80001d46 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d5c:	150ab503          	ld	a0,336(s5)
    80001d60:	64e010ef          	jal	800033ae <idup>
    80001d64:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d68:	4641                	li	a2,16
    80001d6a:	158a8593          	addi	a1,s5,344
    80001d6e:	158a0513          	addi	a0,s4,344
    80001d72:	8caff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001d76:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d7a:	8552                	mv	a0,s4
    80001d7c:	f35fe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001d80:	00010517          	auipc	a0,0x10
    80001d84:	73050513          	addi	a0,a0,1840 # 800124b0 <wait_lock>
    80001d88:	ea1fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001d8c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d90:	00010517          	auipc	a0,0x10
    80001d94:	72050513          	addi	a0,a0,1824 # 800124b0 <wait_lock>
    80001d98:	f19fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001d9c:	8552                	mv	a0,s4
    80001d9e:	e8bfe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001da2:	478d                	li	a5,3
    80001da4:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001da8:	8552                	mv	a0,s4
    80001daa:	f07fe0ef          	jal	80000cb0 <release>
  return pid;
    80001dae:	7902                	ld	s2,32(sp)
    80001db0:	69e2                	ld	s3,24(sp)
    80001db2:	6a42                	ld	s4,16(sp)
}
    80001db4:	8526                	mv	a0,s1
    80001db6:	70e2                	ld	ra,56(sp)
    80001db8:	7442                	ld	s0,48(sp)
    80001dba:	74a2                	ld	s1,40(sp)
    80001dbc:	6aa2                	ld	s5,8(sp)
    80001dbe:	6121                	addi	sp,sp,64
    80001dc0:	8082                	ret
    return -1;
    80001dc2:	54fd                	li	s1,-1
    80001dc4:	bfc5                	j	80001db4 <kfork+0xfc>

0000000080001dc6 <mlfq_timer_tick>:
{
    80001dc6:	1101                	addi	sp,sp,-32
    80001dc8:	ec06                	sd	ra,24(sp)
    80001dca:	e822                	sd	s0,16(sp)
    80001dcc:	e04a                	sd	s2,0(sp)
    80001dce:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001dd0:	b79ff0ef          	jal	80001948 <myproc>
    return 0;
    80001dd4:	4901                	li	s2,0
  if (p == 0)
    80001dd6:	cd29                	beqz	a0,80001e30 <mlfq_timer_tick+0x6a>
    80001dd8:	e426                	sd	s1,8(sp)
    80001dda:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ddc:	e4dfe0ef          	jal	80000c28 <acquire>
  p->ticks_used++;
    80001de0:	16c4a783          	lw	a5,364(s1)
    80001de4:	2785                	addiw	a5,a5,1
    80001de6:	873e                	mv	a4,a5
    80001de8:	16f4a623          	sw	a5,364(s1)
  if (p->queue_level == 0)
    80001dec:	1684a783          	lw	a5,360(s1)
    80001df0:	cb85                	beqz	a5,80001e20 <mlfq_timer_tick+0x5a>
  else if (p->queue_level == 1)
    80001df2:	4685                	li	a3,1
    80001df4:	04d78463          	beq	a5,a3,80001e3c <mlfq_timer_tick+0x76>
  if (p->ticks_used >= time_slice) {
    80001df8:	468d                	li	a3,3
    80001dfa:	00e6d963          	bge	a3,a4,80001e0c <mlfq_timer_tick+0x46>
    p->ticks_used = 0;
    80001dfe:	1604a623          	sw	zero,364(s1)
    if (p->queue_level < 2) {
    80001e02:	4705                	li	a4,1
    should_yield = 1;
    80001e04:	893a                	mv	s2,a4
    if (p->queue_level < 2) {
    80001e06:	02f74163          	blt	a4,a5,80001e28 <mlfq_timer_tick+0x62>
    80001e0a:	a029                	j	80001e14 <mlfq_timer_tick+0x4e>
  int should_yield = 0;
    80001e0c:	4901                	li	s2,0
    80001e0e:	a829                	j	80001e28 <mlfq_timer_tick+0x62>
    p->ticks_used = 0;
    80001e10:	1604a623          	sw	zero,364(s1)
      p->queue_level++; // Demote to next lower priority queue
    80001e14:	2785                	addiw	a5,a5,1
    80001e16:	16f4a423          	sw	a5,360(s1)
    should_yield = 1;
    80001e1a:	4785                	li	a5,1
    80001e1c:	893e                	mv	s2,a5
    80001e1e:	a029                	j	80001e28 <mlfq_timer_tick+0x62>
    time_slice = 1;
    80001e20:	4685                	li	a3,1
  int should_yield = 0;
    80001e22:	4901                	li	s2,0
  if (p->ticks_used >= time_slice) {
    80001e24:	fed756e3          	bge	a4,a3,80001e10 <mlfq_timer_tick+0x4a>
  release(&p->lock);
    80001e28:	8526                	mv	a0,s1
    80001e2a:	e87fe0ef          	jal	80000cb0 <release>
  return should_yield;
    80001e2e:	64a2                	ld	s1,8(sp)
}
    80001e30:	854a                	mv	a0,s2
    80001e32:	60e2                	ld	ra,24(sp)
    80001e34:	6442                	ld	s0,16(sp)
    80001e36:	6902                	ld	s2,0(sp)
    80001e38:	6105                	addi	sp,sp,32
    80001e3a:	8082                	ret
    time_slice = 2;
    80001e3c:	4689                	li	a3,2
    80001e3e:	b7d5                	j	80001e22 <mlfq_timer_tick+0x5c>

0000000080001e40 <get_queue>:
{
    80001e40:	7179                	addi	sp,sp,-48
    80001e42:	f406                	sd	ra,40(sp)
    80001e44:	f022                	sd	s0,32(sp)
    80001e46:	ec26                	sd	s1,24(sp)
    80001e48:	e84a                	sd	s2,16(sp)
    80001e4a:	e44e                	sd	s3,8(sp)
    80001e4c:	1800                	addi	s0,sp,48
    80001e4e:	892a                	mv	s2,a0
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e50:	00011497          	auipc	s1,0x11
    80001e54:	a7848493          	addi	s1,s1,-1416 # 800128c8 <proc>
    80001e58:	00016997          	auipc	s3,0x16
    80001e5c:	67098993          	addi	s3,s3,1648 # 800184c8 <tickslock>
    80001e60:	a801                	j	80001e70 <get_queue+0x30>
    release(&p->lock);
    80001e62:	8526                	mv	a0,s1
    80001e64:	e4dfe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e68:	17048493          	addi	s1,s1,368
    80001e6c:	03348b63          	beq	s1,s3,80001ea2 <get_queue+0x62>
    acquire(&p->lock);
    80001e70:	8526                	mv	a0,s1
    80001e72:	db7fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid || (pid == 0 && p == myproc())) {
    80001e76:	589c                	lw	a5,48(s1)
    80001e78:	01278863          	beq	a5,s2,80001e88 <get_queue+0x48>
    80001e7c:	fe0913e3          	bnez	s2,80001e62 <get_queue+0x22>
    80001e80:	ac9ff0ef          	jal	80001948 <myproc>
    80001e84:	fc951fe3          	bne	a0,s1,80001e62 <get_queue+0x22>
      int q = p->queue_level;
    80001e88:	1684a903          	lw	s2,360(s1)
      release(&p->lock);
    80001e8c:	8526                	mv	a0,s1
    80001e8e:	e23fe0ef          	jal	80000cb0 <release>
}
    80001e92:	854a                	mv	a0,s2
    80001e94:	70a2                	ld	ra,40(sp)
    80001e96:	7402                	ld	s0,32(sp)
    80001e98:	64e2                	ld	s1,24(sp)
    80001e9a:	6942                	ld	s2,16(sp)
    80001e9c:	69a2                	ld	s3,8(sp)
    80001e9e:	6145                	addi	sp,sp,48
    80001ea0:	8082                	ret
  return -1;
    80001ea2:	597d                	li	s2,-1
    80001ea4:	b7fd                	j	80001e92 <get_queue+0x52>

0000000080001ea6 <scheduler>:
{
    80001ea6:	7119                	addi	sp,sp,-128
    80001ea8:	fc86                	sd	ra,120(sp)
    80001eaa:	f8a2                	sd	s0,112(sp)
    80001eac:	f4a6                	sd	s1,104(sp)
    80001eae:	f0ca                	sd	s2,96(sp)
    80001eb0:	ecce                	sd	s3,88(sp)
    80001eb2:	e8d2                	sd	s4,80(sp)
    80001eb4:	e4d6                	sd	s5,72(sp)
    80001eb6:	e0da                	sd	s6,64(sp)
    80001eb8:	fc5e                	sd	s7,56(sp)
    80001eba:	f862                	sd	s8,48(sp)
    80001ebc:	f466                	sd	s9,40(sp)
    80001ebe:	f06a                	sd	s10,32(sp)
    80001ec0:	ec6e                	sd	s11,24(sp)
    80001ec2:	0100                	addi	s0,sp,128
    80001ec4:	8d12                	mv	s10,tp
  int id = r_tp();
    80001ec6:	2d01                	sext.w	s10,s10
  int last_idx[3] = {-1, -1, -1};
    80001ec8:	57fd                	li	a5,-1
    80001eca:	f8f42023          	sw	a5,-128(s0)
    80001ece:	f8f42223          	sw	a5,-124(s0)
    80001ed2:	f8f42423          	sw	a5,-120(s0)
  c->proc = 0;
    80001ed6:	007d1c93          	slli	s9,s10,0x7
    80001eda:	00010797          	auipc	a5,0x10
    80001ede:	5be78793          	addi	a5,a5,1470 # 80012498 <pid_lock>
    80001ee2:	97e6                	add	a5,a5,s9
    80001ee4:	0207b823          	sd	zero,48(a5)
      swtch(&c->context, &best_p->context);
    80001ee8:	00010797          	auipc	a5,0x10
    80001eec:	5e878793          	addi	a5,a5,1512 # 800124d0 <cpus+0x8>
    80001ef0:	9cbe                	add	s9,s9,a5
        p = &proc[idx];
    80001ef2:	17000a13          	li	s4,368
    80001ef6:	00011997          	auipc	s3,0x11
    80001efa:	9d298993          	addi	s3,s3,-1582 # 800128c8 <proc>
        if (p->state == RUNNABLE && p->queue_level == q) {
    80001efe:	4b0d                	li	s6,3
      for (int i = 0; i < NPROC; i++) {
    80001f00:	04000b93          	li	s7,64
    80001f04:	a071                	j	80001f90 <scheduler+0xea>
        release(&p->lock);
    80001f06:	856e                	mv	a0,s11
    80001f08:	da9fe0ef          	jal	80000cb0 <release>
      for (int i = 0; i < NPROC; i++) {
    80001f0c:	2905                	addiw	s2,s2,1
    80001f0e:	09790963          	beq	s2,s7,80001fa0 <scheduler+0xfa>
        int idx = (last_idx[q] + 1 + i) % NPROC;
    80001f12:	000aa783          	lw	a5,0(s5)
    80001f16:	2785                	addiw	a5,a5,1
    80001f18:	012787bb          	addw	a5,a5,s2
    80001f1c:	41f7d71b          	sraiw	a4,a5,0x1f
    80001f20:	01a7571b          	srliw	a4,a4,0x1a
    80001f24:	00f704bb          	addw	s1,a4,a5
    80001f28:	03f4f493          	andi	s1,s1,63
    80001f2c:	9c99                	subw	s1,s1,a4
        p = &proc[idx];
    80001f2e:	03448db3          	mul	s11,s1,s4
    80001f32:	9dce                	add	s11,s11,s3
        acquire(&p->lock);
    80001f34:	856e                	mv	a0,s11
    80001f36:	cf3fe0ef          	jal	80000c28 <acquire>
        if (p->state == RUNNABLE && p->queue_level == q) {
    80001f3a:	018da783          	lw	a5,24(s11)
    80001f3e:	fd6794e3          	bne	a5,s6,80001f06 <scheduler+0x60>
    80001f42:	168da783          	lw	a5,360(s11)
    80001f46:	fd8790e3          	bne	a5,s8,80001f06 <scheduler+0x60>
          last_idx[q] = idx;
    80001f4a:	0c0a                	slli	s8,s8,0x2
    80001f4c:	f90c0793          	addi	a5,s8,-112 # ffffffffffffef90 <end+0xffffffff7ffdb6e8>
    80001f50:	00878c33          	add	s8,a5,s0
    80001f54:	fe9c2823          	sw	s1,-16(s8)
      best_p->state = RUNNING;
    80001f58:	4791                	li	a5,4
    80001f5a:	00fdac23          	sw	a5,24(s11)
      c->proc = best_p;
    80001f5e:	00010917          	auipc	s2,0x10
    80001f62:	53a90913          	addi	s2,s2,1338 # 80012498 <pid_lock>
    80001f66:	007d1493          	slli	s1,s10,0x7
    80001f6a:	94ca                	add	s1,s1,s2
    80001f6c:	03b4b823          	sd	s11,48(s1)
      swtch(&c->context, &best_p->context);
    80001f70:	060d8593          	addi	a1,s11,96
    80001f74:	8566                	mv	a0,s9
    80001f76:	5f6000ef          	jal	8000256c <swtch>
    80001f7a:	8792                	mv	a5,tp
      mycpu()->intena = 0;
    80001f7c:	2781                	sext.w	a5,a5
    80001f7e:	079e                	slli	a5,a5,0x7
    80001f80:	993e                	add	s2,s2,a5
    80001f82:	0a092623          	sw	zero,172(s2)
      c->proc = 0;
    80001f86:	0204b823          	sd	zero,48(s1)
      release(&best_p->lock);
    80001f8a:	856e                	mv	a0,s11
    80001f8c:	d25fe0ef          	jal	80000cb0 <release>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001f90:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001f94:	10017073          	csrci	sstatus,2
    for (int q = 0; q < 3; q++) {
    80001f98:	f8040a93          	addi	s5,s0,-128
    80001f9c:	4c01                	li	s8,0
    80001f9e:	a029                	j	80001fa8 <scheduler+0x102>
    80001fa0:	2c05                	addiw	s8,s8,1
    80001fa2:	0a91                	addi	s5,s5,4
    80001fa4:	016c0463          	beq	s8,s6,80001fac <scheduler+0x106>
      for (int i = 0; i < NPROC; i++) {
    80001fa8:	4901                	li	s2,0
    80001faa:	b7a5                	j	80001f12 <scheduler+0x6c>
      asm volatile("wfi");
    80001fac:	10500073          	wfi
    80001fb0:	b7c5                	j	80001f90 <scheduler+0xea>

0000000080001fb2 <sched>:
{
    80001fb2:	7179                	addi	sp,sp,-48
    80001fb4:	f406                	sd	ra,40(sp)
    80001fb6:	f022                	sd	s0,32(sp)
    80001fb8:	ec26                	sd	s1,24(sp)
    80001fba:	e84a                	sd	s2,16(sp)
    80001fbc:	e44e                	sd	s3,8(sp)
    80001fbe:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fc0:	989ff0ef          	jal	80001948 <myproc>
    80001fc4:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001fc6:	bfdfe0ef          	jal	80000bc2 <holding>
    80001fca:	c935                	beqz	a0,8000203e <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001fcc:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001fce:	2781                	sext.w	a5,a5
    80001fd0:	079e                	slli	a5,a5,0x7
    80001fd2:	00010717          	auipc	a4,0x10
    80001fd6:	4c670713          	addi	a4,a4,1222 # 80012498 <pid_lock>
    80001fda:	97ba                	add	a5,a5,a4
    80001fdc:	0a87a703          	lw	a4,168(a5)
    80001fe0:	4785                	li	a5,1
    80001fe2:	06f71463          	bne	a4,a5,8000204a <sched+0x98>
  if (p->state == RUNNING)
    80001fe6:	4c98                	lw	a4,24(s1)
    80001fe8:	4791                	li	a5,4
    80001fea:	06f70663          	beq	a4,a5,80002056 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001fee:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ff2:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001ff4:	e7bd                	bnez	a5,80002062 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001ff6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001ff8:	00010917          	auipc	s2,0x10
    80001ffc:	4a090913          	addi	s2,s2,1184 # 80012498 <pid_lock>
    80002000:	2781                	sext.w	a5,a5
    80002002:	079e                	slli	a5,a5,0x7
    80002004:	97ca                	add	a5,a5,s2
    80002006:	0ac7a983          	lw	s3,172(a5)
    8000200a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000200c:	2781                	sext.w	a5,a5
    8000200e:	079e                	slli	a5,a5,0x7
    80002010:	07a1                	addi	a5,a5,8
    80002012:	00010597          	auipc	a1,0x10
    80002016:	4b658593          	addi	a1,a1,1206 # 800124c8 <cpus>
    8000201a:	95be                	add	a1,a1,a5
    8000201c:	06048513          	addi	a0,s1,96
    80002020:	54c000ef          	jal	8000256c <swtch>
    80002024:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002026:	2781                	sext.w	a5,a5
    80002028:	079e                	slli	a5,a5,0x7
    8000202a:	993e                	add	s2,s2,a5
    8000202c:	0b392623          	sw	s3,172(s2)
}
    80002030:	70a2                	ld	ra,40(sp)
    80002032:	7402                	ld	s0,32(sp)
    80002034:	64e2                	ld	s1,24(sp)
    80002036:	6942                	ld	s2,16(sp)
    80002038:	69a2                	ld	s3,8(sp)
    8000203a:	6145                	addi	sp,sp,48
    8000203c:	8082                	ret
    panic("sched p->lock");
    8000203e:	00005517          	auipc	a0,0x5
    80002042:	15a50513          	addi	a0,a0,346 # 80007198 <etext+0x198>
    80002046:	feefe0ef          	jal	80000834 <panic>
    panic("sched locks");
    8000204a:	00005517          	auipc	a0,0x5
    8000204e:	15e50513          	addi	a0,a0,350 # 800071a8 <etext+0x1a8>
    80002052:	fe2fe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80002056:	00005517          	auipc	a0,0x5
    8000205a:	16250513          	addi	a0,a0,354 # 800071b8 <etext+0x1b8>
    8000205e:	fd6fe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80002062:	00005517          	auipc	a0,0x5
    80002066:	16650513          	addi	a0,a0,358 # 800071c8 <etext+0x1c8>
    8000206a:	fcafe0ef          	jal	80000834 <panic>

000000008000206e <yield>:
{
    8000206e:	1101                	addi	sp,sp,-32
    80002070:	ec06                	sd	ra,24(sp)
    80002072:	e822                	sd	s0,16(sp)
    80002074:	e426                	sd	s1,8(sp)
    80002076:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002078:	8d1ff0ef          	jal	80001948 <myproc>
    8000207c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000207e:	babfe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80002082:	478d                	li	a5,3
    80002084:	cc9c                	sw	a5,24(s1)
  sched();
    80002086:	f2dff0ef          	jal	80001fb2 <sched>
  release(&p->lock);
    8000208a:	8526                	mv	a0,s1
    8000208c:	c25fe0ef          	jal	80000cb0 <release>
}
    80002090:	60e2                	ld	ra,24(sp)
    80002092:	6442                	ld	s0,16(sp)
    80002094:	64a2                	ld	s1,8(sp)
    80002096:	6105                	addi	sp,sp,32
    80002098:	8082                	ret

000000008000209a <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    8000209a:	1101                	addi	sp,sp,-32
    8000209c:	ec06                	sd	ra,24(sp)
    8000209e:	e822                	sd	s0,16(sp)
    800020a0:	e426                	sd	s1,8(sp)
    800020a2:	e04a                	sd	s2,0(sp)
    800020a4:	1000                	addi	s0,sp,32
    800020a6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800020a8:	8a1ff0ef          	jal	80001948 <myproc>
    800020ac:	892a                	mv	s2,a0

  acquire(&p->lock);
    800020ae:	b7bfe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    800020b2:	cc81                	beqz	s1,800020ca <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    800020b4:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    800020b8:	854a                	mv	a0,s2
    800020ba:	bf7fe0ef          	jal	80000cb0 <release>
}
    800020be:	60e2                	ld	ra,24(sp)
    800020c0:	6442                	ld	s0,16(sp)
    800020c2:	64a2                	ld	s1,8(sp)
    800020c4:	6902                	ld	s2,0(sp)
    800020c6:	6105                	addi	sp,sp,32
    800020c8:	8082                	ret
    panic("sleep_prepare: zero chan");
    800020ca:	00005517          	auipc	a0,0x5
    800020ce:	11650513          	addi	a0,a0,278 # 800071e0 <etext+0x1e0>
    800020d2:	f62fe0ef          	jal	80000834 <panic>

00000000800020d6 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    800020d6:	1101                	addi	sp,sp,-32
    800020d8:	ec06                	sd	ra,24(sp)
    800020da:	e822                	sd	s0,16(sp)
    800020dc:	e426                	sd	s1,8(sp)
    800020de:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020e0:	869ff0ef          	jal	80001948 <myproc>
    800020e4:	84aa                	mv	s1,a0

  acquire(&p->lock);
    800020e6:	b43fe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    800020ea:	709c                	ld	a5,32(s1)
    800020ec:	c799                	beqz	a5,800020fa <sleep+0x24>
    p->state = SLEEPING;
    800020ee:	4789                	li	a5,2
    800020f0:	cc9c                	sw	a5,24(s1)
    p->ticks_used = 0; // Voluntary yield/sleep: reset quantum without demotion
    800020f2:	1604a623          	sw	zero,364(s1)
    sched();
    800020f6:	ebdff0ef          	jal	80001fb2 <sched>
  }
  release(&p->lock);
    800020fa:	8526                	mv	a0,s1
    800020fc:	bb5fe0ef          	jal	80000cb0 <release>
}
    80002100:	60e2                	ld	ra,24(sp)
    80002102:	6442                	ld	s0,16(sp)
    80002104:	64a2                	ld	s1,8(sp)
    80002106:	6105                	addi	sp,sp,32
    80002108:	8082                	ret

000000008000210a <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    8000210a:	7139                	addi	sp,sp,-64
    8000210c:	fc06                	sd	ra,56(sp)
    8000210e:	f822                	sd	s0,48(sp)
    80002110:	f426                	sd	s1,40(sp)
    80002112:	f04a                	sd	s2,32(sp)
    80002114:	ec4e                	sd	s3,24(sp)
    80002116:	e852                	sd	s4,16(sp)
    80002118:	e456                	sd	s5,8(sp)
    8000211a:	0080                	addi	s0,sp,64
    8000211c:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000211e:	00010497          	auipc	s1,0x10
    80002122:	7aa48493          	addi	s1,s1,1962 # 800128c8 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80002126:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80002128:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    8000212a:	00016997          	auipc	s3,0x16
    8000212e:	39e98993          	addi	s3,s3,926 # 800184c8 <tickslock>
    80002132:	a801                	j	80002142 <wakeup+0x38>
      }
    }
    release(&p->lock);
    80002134:	8526                	mv	a0,s1
    80002136:	b7bfe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000213a:	17048493          	addi	s1,s1,368
    8000213e:	03348063          	beq	s1,s3,8000215e <wakeup+0x54>
    acquire(&p->lock);
    80002142:	8526                	mv	a0,s1
    80002144:	ae5fe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    80002148:	709c                	ld	a5,32(s1)
    8000214a:	ff2795e3          	bne	a5,s2,80002134 <wakeup+0x2a>
      p->chan = 0;
    8000214e:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80002152:	4c9c                	lw	a5,24(s1)
    80002154:	ff4790e3          	bne	a5,s4,80002134 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002158:	0154ac23          	sw	s5,24(s1)
    8000215c:	bfe1                	j	80002134 <wakeup+0x2a>
  }
}
    8000215e:	70e2                	ld	ra,56(sp)
    80002160:	7442                	ld	s0,48(sp)
    80002162:	74a2                	ld	s1,40(sp)
    80002164:	7902                	ld	s2,32(sp)
    80002166:	69e2                	ld	s3,24(sp)
    80002168:	6a42                	ld	s4,16(sp)
    8000216a:	6aa2                	ld	s5,8(sp)
    8000216c:	6121                	addi	sp,sp,64
    8000216e:	8082                	ret

0000000080002170 <reparent>:
{
    80002170:	7179                	addi	sp,sp,-48
    80002172:	f406                	sd	ra,40(sp)
    80002174:	f022                	sd	s0,32(sp)
    80002176:	ec26                	sd	s1,24(sp)
    80002178:	e84a                	sd	s2,16(sp)
    8000217a:	e44e                	sd	s3,8(sp)
    8000217c:	e052                	sd	s4,0(sp)
    8000217e:	1800                	addi	s0,sp,48
    80002180:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002182:	00010497          	auipc	s1,0x10
    80002186:	74648493          	addi	s1,s1,1862 # 800128c8 <proc>
      pp->parent = initproc;
    8000218a:	00008a17          	auipc	s4,0x8
    8000218e:	206a0a13          	addi	s4,s4,518 # 8000a390 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002192:	00016997          	auipc	s3,0x16
    80002196:	33698993          	addi	s3,s3,822 # 800184c8 <tickslock>
    8000219a:	a029                	j	800021a4 <reparent+0x34>
    8000219c:	17048493          	addi	s1,s1,368
    800021a0:	01348b63          	beq	s1,s3,800021b6 <reparent+0x46>
    if (pp->parent == p) {
    800021a4:	7c9c                	ld	a5,56(s1)
    800021a6:	ff279be3          	bne	a5,s2,8000219c <reparent+0x2c>
      pp->parent = initproc;
    800021aa:	000a3503          	ld	a0,0(s4)
    800021ae:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021b0:	f5bff0ef          	jal	8000210a <wakeup>
    800021b4:	b7e5                	j	8000219c <reparent+0x2c>
}
    800021b6:	70a2                	ld	ra,40(sp)
    800021b8:	7402                	ld	s0,32(sp)
    800021ba:	64e2                	ld	s1,24(sp)
    800021bc:	6942                	ld	s2,16(sp)
    800021be:	69a2                	ld	s3,8(sp)
    800021c0:	6a02                	ld	s4,0(sp)
    800021c2:	6145                	addi	sp,sp,48
    800021c4:	8082                	ret

00000000800021c6 <kexit>:
{
    800021c6:	7179                	addi	sp,sp,-48
    800021c8:	f406                	sd	ra,40(sp)
    800021ca:	f022                	sd	s0,32(sp)
    800021cc:	ec26                	sd	s1,24(sp)
    800021ce:	e84a                	sd	s2,16(sp)
    800021d0:	e44e                	sd	s3,8(sp)
    800021d2:	e052                	sd	s4,0(sp)
    800021d4:	1800                	addi	s0,sp,48
    800021d6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021d8:	f70ff0ef          	jal	80001948 <myproc>
    800021dc:	89aa                	mv	s3,a0
  if (p == initproc)
    800021de:	00008797          	auipc	a5,0x8
    800021e2:	1b27b783          	ld	a5,434(a5) # 8000a390 <initproc>
    800021e6:	0d050493          	addi	s1,a0,208
    800021ea:	15050913          	addi	s2,a0,336
    800021ee:	00a79b63          	bne	a5,a0,80002204 <kexit+0x3e>
    panic("init exiting");
    800021f2:	00005517          	auipc	a0,0x5
    800021f6:	00e50513          	addi	a0,a0,14 # 80007200 <etext+0x200>
    800021fa:	e3afe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    800021fe:	04a1                	addi	s1,s1,8
    80002200:	01248963          	beq	s1,s2,80002212 <kexit+0x4c>
    if (p->ofile[fd]) {
    80002204:	6088                	ld	a0,0(s1)
    80002206:	dd65                	beqz	a0,800021fe <kexit+0x38>
      fileclose(f);
    80002208:	10e020ef          	jal	80004316 <fileclose>
      p->ofile[fd] = 0;
    8000220c:	0004b023          	sd	zero,0(s1)
    80002210:	b7fd                	j	800021fe <kexit+0x38>
  begin_op();
    80002212:	44b010ef          	jal	80003e5c <begin_op>
  iput(p->cwd);
    80002216:	1509b503          	ld	a0,336(s3)
    8000221a:	34c010ef          	jal	80003566 <iput>
  end_op();
    8000221e:	4cb010ef          	jal	80003ee8 <end_op>
  p->cwd = 0;
    80002222:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002226:	00010517          	auipc	a0,0x10
    8000222a:	28a50513          	addi	a0,a0,650 # 800124b0 <wait_lock>
    8000222e:	9fbfe0ef          	jal	80000c28 <acquire>
  reparent(p);
    80002232:	854e                	mv	a0,s3
    80002234:	f3dff0ef          	jal	80002170 <reparent>
  wakeup(p->parent);
    80002238:	0389b503          	ld	a0,56(s3)
    8000223c:	ecfff0ef          	jal	8000210a <wakeup>
  acquire(&p->lock);
    80002240:	854e                	mv	a0,s3
    80002242:	9e7fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    80002246:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000224a:	4795                	li	a5,5
    8000224c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002250:	00010517          	auipc	a0,0x10
    80002254:	26050513          	addi	a0,a0,608 # 800124b0 <wait_lock>
    80002258:	a59fe0ef          	jal	80000cb0 <release>
  sched();
    8000225c:	d57ff0ef          	jal	80001fb2 <sched>
  panic("zombie exit");
    80002260:	00005517          	auipc	a0,0x5
    80002264:	fb050513          	addi	a0,a0,-80 # 80007210 <etext+0x210>
    80002268:	dccfe0ef          	jal	80000834 <panic>

000000008000226c <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    8000226c:	c525                	beqz	a0,800022d4 <kkill+0x68>
{
    8000226e:	7179                	addi	sp,sp,-48
    80002270:	f406                	sd	ra,40(sp)
    80002272:	f022                	sd	s0,32(sp)
    80002274:	ec26                	sd	s1,24(sp)
    80002276:	e84a                	sd	s2,16(sp)
    80002278:	e44e                	sd	s3,8(sp)
    8000227a:	1800                	addi	s0,sp,48
    8000227c:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000227e:	00010497          	auipc	s1,0x10
    80002282:	64a48493          	addi	s1,s1,1610 # 800128c8 <proc>
    80002286:	00016997          	auipc	s3,0x16
    8000228a:	24298993          	addi	s3,s3,578 # 800184c8 <tickslock>
    acquire(&p->lock);
    8000228e:	8526                	mv	a0,s1
    80002290:	999fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    80002294:	589c                	lw	a5,48(s1)
    80002296:	01278b63          	beq	a5,s2,800022ac <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000229a:	8526                	mv	a0,s1
    8000229c:	a15fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800022a0:	17048493          	addi	s1,s1,368
    800022a4:	ff3495e3          	bne	s1,s3,8000228e <kkill+0x22>
  }
  return -1;
    800022a8:	557d                	li	a0,-1
    800022aa:	a819                	j	800022c0 <kkill+0x54>
      p->killed = 1;
    800022ac:	4785                	li	a5,1
    800022ae:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800022b0:	4c98                	lw	a4,24(s1)
    800022b2:	4789                	li	a5,2
    800022b4:	00f70d63          	beq	a4,a5,800022ce <kkill+0x62>
      release(&p->lock);
    800022b8:	8526                	mv	a0,s1
    800022ba:	9f7fe0ef          	jal	80000cb0 <release>
      return 0;
    800022be:	4501                	li	a0,0
}
    800022c0:	70a2                	ld	ra,40(sp)
    800022c2:	7402                	ld	s0,32(sp)
    800022c4:	64e2                	ld	s1,24(sp)
    800022c6:	6942                	ld	s2,16(sp)
    800022c8:	69a2                	ld	s3,8(sp)
    800022ca:	6145                	addi	sp,sp,48
    800022cc:	8082                	ret
        p->state = RUNNABLE;
    800022ce:	478d                	li	a5,3
    800022d0:	cc9c                	sw	a5,24(s1)
    800022d2:	b7dd                	j	800022b8 <kkill+0x4c>
    return -1;
    800022d4:	557d                	li	a0,-1
}
    800022d6:	8082                	ret

00000000800022d8 <setkilled>:

void
setkilled(struct proc *p)
{
    800022d8:	1101                	addi	sp,sp,-32
    800022da:	ec06                	sd	ra,24(sp)
    800022dc:	e822                	sd	s0,16(sp)
    800022de:	e426                	sd	s1,8(sp)
    800022e0:	1000                	addi	s0,sp,32
    800022e2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022e4:	945fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    800022e8:	4785                	li	a5,1
    800022ea:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022ec:	8526                	mv	a0,s1
    800022ee:	9c3fe0ef          	jal	80000cb0 <release>
}
    800022f2:	60e2                	ld	ra,24(sp)
    800022f4:	6442                	ld	s0,16(sp)
    800022f6:	64a2                	ld	s1,8(sp)
    800022f8:	6105                	addi	sp,sp,32
    800022fa:	8082                	ret

00000000800022fc <killed>:

int
killed(struct proc *p)
{
    800022fc:	1101                	addi	sp,sp,-32
    800022fe:	ec06                	sd	ra,24(sp)
    80002300:	e822                	sd	s0,16(sp)
    80002302:	e426                	sd	s1,8(sp)
    80002304:	e04a                	sd	s2,0(sp)
    80002306:	1000                	addi	s0,sp,32
    80002308:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000230a:	91ffe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    8000230e:	549c                	lw	a5,40(s1)
    80002310:	893e                	mv	s2,a5
  release(&p->lock);
    80002312:	8526                	mv	a0,s1
    80002314:	99dfe0ef          	jal	80000cb0 <release>
  return k;
}
    80002318:	854a                	mv	a0,s2
    8000231a:	60e2                	ld	ra,24(sp)
    8000231c:	6442                	ld	s0,16(sp)
    8000231e:	64a2                	ld	s1,8(sp)
    80002320:	6902                	ld	s2,0(sp)
    80002322:	6105                	addi	sp,sp,32
    80002324:	8082                	ret

0000000080002326 <kwait>:
{
    80002326:	715d                	addi	sp,sp,-80
    80002328:	e486                	sd	ra,72(sp)
    8000232a:	e0a2                	sd	s0,64(sp)
    8000232c:	fc26                	sd	s1,56(sp)
    8000232e:	f84a                	sd	s2,48(sp)
    80002330:	f44e                	sd	s3,40(sp)
    80002332:	f052                	sd	s4,32(sp)
    80002334:	ec56                	sd	s5,24(sp)
    80002336:	e85a                	sd	s6,16(sp)
    80002338:	e45e                	sd	s7,8(sp)
    8000233a:	0880                	addi	s0,sp,80
    8000233c:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    8000233e:	e0aff0ef          	jal	80001948 <myproc>
    80002342:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002344:	00010517          	auipc	a0,0x10
    80002348:	16c50513          	addi	a0,a0,364 # 800124b0 <wait_lock>
    8000234c:	8ddfe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002350:	4a15                	li	s4,5
        havekids = 1;
    80002352:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002354:	00016997          	auipc	s3,0x16
    80002358:	17498993          	addi	s3,s3,372 # 800184c8 <tickslock>
    release(&wait_lock);
    8000235c:	00010b17          	auipc	s6,0x10
    80002360:	154b0b13          	addi	s6,s6,340 # 800124b0 <wait_lock>
    80002364:	a845                	j	80002414 <kwait+0xee>
          pid = pp->pid;
    80002366:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    8000236a:	000b8e63          	beqz	s7,80002386 <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    8000236e:	4711                	li	a4,4
    80002370:	02c48693          	addi	a3,s1,44
    80002374:	865e                	mv	a2,s7
    80002376:	04893583          	ld	a1,72(s2)
    8000237a:	05093503          	ld	a0,80(s2)
    8000237e:	a04ff0ef          	jal	80001582 <copyout>
          if (addr != 0 &&
    80002382:	02054c63          	bltz	a0,800023ba <kwait+0x94>
          pp->parent = 0;
    80002386:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    8000238a:	8526                	mv	a0,s1
    8000238c:	f8cff0ef          	jal	80001b18 <freeproc>
          release(&pp->lock);
    80002390:	8526                	mv	a0,s1
    80002392:	91ffe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    80002396:	00010517          	auipc	a0,0x10
    8000239a:	11a50513          	addi	a0,a0,282 # 800124b0 <wait_lock>
    8000239e:	913fe0ef          	jal	80000cb0 <release>
}
    800023a2:	854e                	mv	a0,s3
    800023a4:	60a6                	ld	ra,72(sp)
    800023a6:	6406                	ld	s0,64(sp)
    800023a8:	74e2                	ld	s1,56(sp)
    800023aa:	7942                	ld	s2,48(sp)
    800023ac:	79a2                	ld	s3,40(sp)
    800023ae:	7a02                	ld	s4,32(sp)
    800023b0:	6ae2                	ld	s5,24(sp)
    800023b2:	6b42                	ld	s6,16(sp)
    800023b4:	6ba2                	ld	s7,8(sp)
    800023b6:	6161                	addi	sp,sp,80
    800023b8:	8082                	ret
            release(&pp->lock);
    800023ba:	8526                	mv	a0,s1
    800023bc:	8f5fe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    800023c0:	00010517          	auipc	a0,0x10
    800023c4:	0f050513          	addi	a0,a0,240 # 800124b0 <wait_lock>
    800023c8:	8e9fe0ef          	jal	80000cb0 <release>
            return -1;
    800023cc:	59fd                	li	s3,-1
    800023ce:	bfd1                	j	800023a2 <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800023d0:	17048493          	addi	s1,s1,368
    800023d4:	03348063          	beq	s1,s3,800023f4 <kwait+0xce>
      if (pp->parent == p) {
    800023d8:	7c9c                	ld	a5,56(s1)
    800023da:	ff279be3          	bne	a5,s2,800023d0 <kwait+0xaa>
        acquire(&pp->lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	849fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800023e4:	4c9c                	lw	a5,24(s1)
    800023e6:	f94780e3          	beq	a5,s4,80002366 <kwait+0x40>
        release(&pp->lock);
    800023ea:	8526                	mv	a0,s1
    800023ec:	8c5fe0ef          	jal	80000cb0 <release>
        havekids = 1;
    800023f0:	8756                	mv	a4,s5
    800023f2:	bff9                	j	800023d0 <kwait+0xaa>
    if (!havekids || killed(p)) {
    800023f4:	c715                	beqz	a4,80002420 <kwait+0xfa>
    800023f6:	854a                	mv	a0,s2
    800023f8:	f05ff0ef          	jal	800022fc <killed>
    800023fc:	e115                	bnez	a0,80002420 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    800023fe:	854a                	mv	a0,s2
    80002400:	c9bff0ef          	jal	8000209a <sleep_prepare>
    release(&wait_lock);
    80002404:	855a                	mv	a0,s6
    80002406:	8abfe0ef          	jal	80000cb0 <release>
    sleep();
    8000240a:	ccdff0ef          	jal	800020d6 <sleep>
    acquire(&wait_lock);
    8000240e:	855a                	mv	a0,s6
    80002410:	819fe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    80002414:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002416:	00010497          	auipc	s1,0x10
    8000241a:	4b248493          	addi	s1,s1,1202 # 800128c8 <proc>
    8000241e:	bf6d                	j	800023d8 <kwait+0xb2>
      release(&wait_lock);
    80002420:	00010517          	auipc	a0,0x10
    80002424:	09050513          	addi	a0,a0,144 # 800124b0 <wait_lock>
    80002428:	889fe0ef          	jal	80000cb0 <release>
      return -1;
    8000242c:	59fd                	li	s3,-1
    8000242e:	bf95                	j	800023a2 <kwait+0x7c>

0000000080002430 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002430:	7179                	addi	sp,sp,-48
    80002432:	f406                	sd	ra,40(sp)
    80002434:	f022                	sd	s0,32(sp)
    80002436:	ec26                	sd	s1,24(sp)
    80002438:	e84a                	sd	s2,16(sp)
    8000243a:	e44e                	sd	s3,8(sp)
    8000243c:	e052                	sd	s4,0(sp)
    8000243e:	1800                	addi	s0,sp,48
    80002440:	84aa                	mv	s1,a0
    80002442:	8a2e                	mv	s4,a1
    80002444:	89b2                	mv	s3,a2
    80002446:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002448:	d00ff0ef          	jal	80001948 <myproc>
  if (user_dst) {
    8000244c:	c085                	beqz	s1,8000246c <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    8000244e:	874a                	mv	a4,s2
    80002450:	86ce                	mv	a3,s3
    80002452:	8652                	mv	a2,s4
    80002454:	652c                	ld	a1,72(a0)
    80002456:	6928                	ld	a0,80(a0)
    80002458:	92aff0ef          	jal	80001582 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000245c:	70a2                	ld	ra,40(sp)
    8000245e:	7402                	ld	s0,32(sp)
    80002460:	64e2                	ld	s1,24(sp)
    80002462:	6942                	ld	s2,16(sp)
    80002464:	69a2                	ld	s3,8(sp)
    80002466:	6a02                	ld	s4,0(sp)
    80002468:	6145                	addi	sp,sp,48
    8000246a:	8082                	ret
    memmove((char *)dst, src, len);
    8000246c:	0009061b          	sext.w	a2,s2
    80002470:	85ce                	mv	a1,s3
    80002472:	8552                	mv	a0,s4
    80002474:	8d5fe0ef          	jal	80000d48 <memmove>
    return 0;
    80002478:	8526                	mv	a0,s1
    8000247a:	b7cd                	j	8000245c <either_copyout+0x2c>

000000008000247c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000247c:	7179                	addi	sp,sp,-48
    8000247e:	f406                	sd	ra,40(sp)
    80002480:	f022                	sd	s0,32(sp)
    80002482:	ec26                	sd	s1,24(sp)
    80002484:	e84a                	sd	s2,16(sp)
    80002486:	e44e                	sd	s3,8(sp)
    80002488:	e052                	sd	s4,0(sp)
    8000248a:	1800                	addi	s0,sp,48
    8000248c:	8a2a                	mv	s4,a0
    8000248e:	84ae                	mv	s1,a1
    80002490:	89b2                	mv	s3,a2
    80002492:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002494:	cb4ff0ef          	jal	80001948 <myproc>
  if (user_src) {
    80002498:	c085                	beqz	s1,800024b8 <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    8000249a:	874a                	mv	a4,s2
    8000249c:	86ce                	mv	a3,s3
    8000249e:	8652                	mv	a2,s4
    800024a0:	652c                	ld	a1,72(a0)
    800024a2:	6928                	ld	a0,80(a0)
    800024a4:	9a4ff0ef          	jal	80001648 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800024a8:	70a2                	ld	ra,40(sp)
    800024aa:	7402                	ld	s0,32(sp)
    800024ac:	64e2                	ld	s1,24(sp)
    800024ae:	6942                	ld	s2,16(sp)
    800024b0:	69a2                	ld	s3,8(sp)
    800024b2:	6a02                	ld	s4,0(sp)
    800024b4:	6145                	addi	sp,sp,48
    800024b6:	8082                	ret
    memmove(dst, (char *)src, len);
    800024b8:	0009061b          	sext.w	a2,s2
    800024bc:	85ce                	mv	a1,s3
    800024be:	8552                	mv	a0,s4
    800024c0:	889fe0ef          	jal	80000d48 <memmove>
    return 0;
    800024c4:	8526                	mv	a0,s1
    800024c6:	b7cd                	j	800024a8 <either_copyin+0x2c>

00000000800024c8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024c8:	715d                	addi	sp,sp,-80
    800024ca:	e486                	sd	ra,72(sp)
    800024cc:	e0a2                	sd	s0,64(sp)
    800024ce:	fc26                	sd	s1,56(sp)
    800024d0:	f84a                	sd	s2,48(sp)
    800024d2:	f44e                	sd	s3,40(sp)
    800024d4:	f052                	sd	s4,32(sp)
    800024d6:	ec56                	sd	s5,24(sp)
    800024d8:	e85a                	sd	s6,16(sp)
    800024da:	e45e                	sd	s7,8(sp)
    800024dc:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    800024de:	00005517          	auipc	a0,0x5
    800024e2:	b9a50513          	addi	a0,a0,-1126 # 80007078 <etext+0x78>
    800024e6:	824fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800024ea:	00010497          	auipc	s1,0x10
    800024ee:	53648493          	addi	s1,s1,1334 # 80012a20 <proc+0x158>
    800024f2:	00016917          	auipc	s2,0x16
    800024f6:	12e90913          	addi	s2,s2,302 # 80018620 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024fa:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800024fc:	00005997          	auipc	s3,0x5
    80002500:	d2498993          	addi	s3,s3,-732 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    80002504:	00005a97          	auipc	s5,0x5
    80002508:	d24a8a93          	addi	s5,s5,-732 # 80007228 <etext+0x228>
    printk("\n");
    8000250c:	00005a17          	auipc	s4,0x5
    80002510:	b6ca0a13          	addi	s4,s4,-1172 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002514:	00005b97          	auipc	s7,0x5
    80002518:	234b8b93          	addi	s7,s7,564 # 80007748 <states.0>
    8000251c:	a829                	j	80002536 <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    8000251e:	ed86a583          	lw	a1,-296(a3)
    80002522:	8556                	mv	a0,s5
    80002524:	fe7fd0ef          	jal	8000050a <printk>
    printk("\n");
    80002528:	8552                	mv	a0,s4
    8000252a:	fe1fd0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000252e:	17048493          	addi	s1,s1,368
    80002532:	03248263          	beq	s1,s2,80002556 <procdump+0x8e>
    if (p->state == UNUSED)
    80002536:	86a6                	mv	a3,s1
    80002538:	ec04a783          	lw	a5,-320(s1)
    8000253c:	dbed                	beqz	a5,8000252e <procdump+0x66>
      state = "???";
    8000253e:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002540:	fcfb6fe3          	bltu	s6,a5,8000251e <procdump+0x56>
    80002544:	02079713          	slli	a4,a5,0x20
    80002548:	01d75793          	srli	a5,a4,0x1d
    8000254c:	97de                	add	a5,a5,s7
    8000254e:	6390                	ld	a2,0(a5)
    80002550:	f679                	bnez	a2,8000251e <procdump+0x56>
      state = "???";
    80002552:	864e                	mv	a2,s3
    80002554:	b7e9                	j	8000251e <procdump+0x56>
  }
}
    80002556:	60a6                	ld	ra,72(sp)
    80002558:	6406                	ld	s0,64(sp)
    8000255a:	74e2                	ld	s1,56(sp)
    8000255c:	7942                	ld	s2,48(sp)
    8000255e:	79a2                	ld	s3,40(sp)
    80002560:	7a02                	ld	s4,32(sp)
    80002562:	6ae2                	ld	s5,24(sp)
    80002564:	6b42                	ld	s6,16(sp)
    80002566:	6ba2                	ld	s7,8(sp)
    80002568:	6161                	addi	sp,sp,80
    8000256a:	8082                	ret

000000008000256c <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000256c:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002570:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002574:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002576:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002578:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000257c:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002580:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002584:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002588:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000258c:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002590:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002594:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002598:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000259c:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800025a0:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800025a4:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800025a8:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800025aa:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800025ac:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800025b0:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800025b4:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800025b8:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800025bc:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800025c0:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800025c4:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800025c8:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800025cc:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800025d0:	0685bd83          	ld	s11,104(a1)
        
        ret
    800025d4:	8082                	ret

00000000800025d6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800025d6:	1141                	addi	sp,sp,-16
    800025d8:	e406                	sd	ra,8(sp)
    800025da:	e022                	sd	s0,0(sp)
    800025dc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800025de:	00005597          	auipc	a1,0x5
    800025e2:	c8a58593          	addi	a1,a1,-886 # 80007268 <etext+0x268>
    800025e6:	00016517          	auipc	a0,0x16
    800025ea:	ee250513          	addi	a0,a0,-286 # 800184c8 <tickslock>
    800025ee:	dbafe0ef          	jal	80000ba8 <initlock>
}
    800025f2:	60a2                	ld	ra,8(sp)
    800025f4:	6402                	ld	s0,0(sp)
    800025f6:	0141                	addi	sp,sp,16
    800025f8:	8082                	ret

00000000800025fa <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800025fa:	1141                	addi	sp,sp,-16
    800025fc:	e406                	sd	ra,8(sp)
    800025fe:	e022                	sd	s0,0(sp)
    80002600:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002602:	00003797          	auipc	a5,0x3
    80002606:	19e78793          	addi	a5,a5,414 # 800057a0 <kernelvec>
    8000260a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000260e:	60a2                	ld	ra,8(sp)
    80002610:	6402                	ld	s0,0(sp)
    80002612:	0141                	addi	sp,sp,16
    80002614:	8082                	ret

0000000080002616 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002616:	1141                	addi	sp,sp,-16
    80002618:	e406                	sd	ra,8(sp)
    8000261a:	e022                	sd	s0,0(sp)
    8000261c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000261e:	b2aff0ef          	jal	80001948 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002622:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002626:	04000737          	lui	a4,0x4000
    8000262a:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000262c:	0732                	slli	a4,a4,0xc
    8000262e:	00004797          	auipc	a5,0x4
    80002632:	9d278793          	addi	a5,a5,-1582 # 80006000 <_trampoline>
    80002636:	00004697          	auipc	a3,0x4
    8000263a:	9ca68693          	addi	a3,a3,-1590 # 80006000 <_trampoline>
    8000263e:	8f95                	sub	a5,a5,a3
    80002640:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002642:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002646:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    80002648:	18002773          	csrr	a4,satp
    8000264c:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000264e:	6d38                	ld	a4,88(a0)
    80002650:	613c                	ld	a5,64(a0)
    80002652:	6685                	lui	a3,0x1
    80002654:	97b6                	add	a5,a5,a3
    80002656:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002658:	6d3c                	ld	a5,88(a0)
    8000265a:	00000717          	auipc	a4,0x0
    8000265e:	0fc70713          	addi	a4,a4,252 # 80002756 <usertrap>
    80002662:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002664:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    80002666:	8712                	mv	a4,tp
    80002668:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000266a:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000266e:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002672:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002676:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000267a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    8000267c:	6f9c                	ld	a5,24(a5)
    8000267e:	14179073          	csrw	sepc,a5
}
    80002682:	60a2                	ld	ra,8(sp)
    80002684:	6402                	ld	s0,0(sp)
    80002686:	0141                	addi	sp,sp,16
    80002688:	8082                	ret

000000008000268a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000268a:	1141                	addi	sp,sp,-16
    8000268c:	e406                	sd	ra,8(sp)
    8000268e:	e022                	sd	s0,0(sp)
    80002690:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80002692:	a82ff0ef          	jal	80001914 <cpuid>
    80002696:	cd11                	beqz	a0,800026b2 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    80002698:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000269c:	000f4737          	lui	a4,0xf4
    800026a0:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800026a4:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    800026a6:	14d79073          	csrw	stimecmp,a5
}
    800026aa:	60a2                	ld	ra,8(sp)
    800026ac:	6402                	ld	s0,0(sp)
    800026ae:	0141                	addi	sp,sp,16
    800026b0:	8082                	ret
    acquire(&tickslock);
    800026b2:	00016517          	auipc	a0,0x16
    800026b6:	e1650513          	addi	a0,a0,-490 # 800184c8 <tickslock>
    800026ba:	d6efe0ef          	jal	80000c28 <acquire>
    ticks++;
    800026be:	00008717          	auipc	a4,0x8
    800026c2:	cda70713          	addi	a4,a4,-806 # 8000a398 <ticks>
    800026c6:	431c                	lw	a5,0(a4)
    800026c8:	2785                	addiw	a5,a5,1
    800026ca:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800026cc:	853a                	mv	a0,a4
    800026ce:	a3dff0ef          	jal	8000210a <wakeup>
    release(&tickslock);
    800026d2:	00016517          	auipc	a0,0x16
    800026d6:	df650513          	addi	a0,a0,-522 # 800184c8 <tickslock>
    800026da:	dd6fe0ef          	jal	80000cb0 <release>
    800026de:	bf6d                	j	80002698 <clockintr+0xe>

00000000800026e0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800026e0:	1101                	addi	sp,sp,-32
    800026e2:	ec06                	sd	ra,24(sp)
    800026e4:	e822                	sd	s0,16(sp)
    800026e6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    800026e8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    800026ec:	57fd                	li	a5,-1
    800026ee:	17fe                	slli	a5,a5,0x3f
    800026f0:	07a5                	addi	a5,a5,9
    800026f2:	00f70c63          	beq	a4,a5,8000270a <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    800026f6:	57fd                	li	a5,-1
    800026f8:	17fe                	slli	a5,a5,0x3f
    800026fa:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800026fc:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    800026fe:	04f70863          	beq	a4,a5,8000274e <devintr+0x6e>
  }
}
    80002702:	60e2                	ld	ra,24(sp)
    80002704:	6442                	ld	s0,16(sp)
    80002706:	6105                	addi	sp,sp,32
    80002708:	8082                	ret
    8000270a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000270c:	142030ef          	jal	8000584e <plic_claim>
    80002710:	872a                	mv	a4,a0
    80002712:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002714:	47a9                	li	a5,10
    80002716:	00f50963          	beq	a0,a5,80002728 <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    8000271a:	4785                	li	a5,1
    8000271c:	00f50963          	beq	a0,a5,8000272e <devintr+0x4e>
    return 1;
    80002720:	4505                	li	a0,1
    } else if (irq) {
    80002722:	eb09                	bnez	a4,80002734 <devintr+0x54>
    80002724:	64a2                	ld	s1,8(sp)
    80002726:	bff1                	j	80002702 <devintr+0x22>
      uartintr();
    80002728:	ac6fe0ef          	jal	800009ee <uartintr>
    if (irq)
    8000272c:	a819                	j	80002742 <devintr+0x62>
      virtio_disk_intr();
    8000272e:	5dc030ef          	jal	80005d0a <virtio_disk_intr>
    if (irq)
    80002732:	a801                	j	80002742 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    80002734:	85ba                	mv	a1,a4
    80002736:	00005517          	auipc	a0,0x5
    8000273a:	b3a50513          	addi	a0,a0,-1222 # 80007270 <etext+0x270>
    8000273e:	dcdfd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    80002742:	8526                	mv	a0,s1
    80002744:	12c030ef          	jal	80005870 <plic_complete>
    return 1;
    80002748:	4505                	li	a0,1
    8000274a:	64a2                	ld	s1,8(sp)
    8000274c:	bf5d                	j	80002702 <devintr+0x22>
    clockintr();
    8000274e:	f3dff0ef          	jal	8000268a <clockintr>
    return 2;
    80002752:	4509                	li	a0,2
    80002754:	b77d                	j	80002702 <devintr+0x22>

0000000080002756 <usertrap>:
{
    80002756:	1101                	addi	sp,sp,-32
    80002758:	ec06                	sd	ra,24(sp)
    8000275a:	e822                	sd	s0,16(sp)
    8000275c:	e426                	sd	s1,8(sp)
    8000275e:	e04a                	sd	s2,0(sp)
    80002760:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002762:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002766:	1007f793          	andi	a5,a5,256
    8000276a:	eba5                	bnez	a5,800027da <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000276c:	00003797          	auipc	a5,0x3
    80002770:	03478793          	addi	a5,a5,52 # 800057a0 <kernelvec>
    80002774:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002778:	9d0ff0ef          	jal	80001948 <myproc>
    8000277c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000277e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002780:	14102773          	csrr	a4,sepc
    80002784:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    80002786:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    8000278a:	47a1                	li	a5,8
    8000278c:	04f70d63          	beq	a4,a5,800027e6 <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    80002790:	f51ff0ef          	jal	800026e0 <devintr>
    80002794:	892a                	mv	s2,a0
    80002796:	e54d                	bnez	a0,80002840 <usertrap+0xea>
    80002798:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    8000279c:	47bd                	li	a5,15
    8000279e:	08f70463          	beq	a4,a5,80002826 <usertrap+0xd0>
    800027a2:	14202773          	csrr	a4,scause
    800027a6:	47b5                	li	a5,13
    800027a8:	06f70f63          	beq	a4,a5,80002826 <usertrap+0xd0>
    800027ac:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800027b0:	5890                	lw	a2,48(s1)
    800027b2:	00005517          	auipc	a0,0x5
    800027b6:	afe50513          	addi	a0,a0,-1282 # 800072b0 <etext+0x2b0>
    800027ba:	d51fd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027be:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800027c2:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800027c6:	00005517          	auipc	a0,0x5
    800027ca:	b1a50513          	addi	a0,a0,-1254 # 800072e0 <etext+0x2e0>
    800027ce:	d3dfd0ef          	jal	8000050a <printk>
    setkilled(p);
    800027d2:	8526                	mv	a0,s1
    800027d4:	b05ff0ef          	jal	800022d8 <setkilled>
    800027d8:	a015                	j	800027fc <usertrap+0xa6>
    panic("usertrap: not from user mode");
    800027da:	00005517          	auipc	a0,0x5
    800027de:	ab650513          	addi	a0,a0,-1354 # 80007290 <etext+0x290>
    800027e2:	852fe0ef          	jal	80000834 <panic>
    if (killed(p))
    800027e6:	b17ff0ef          	jal	800022fc <killed>
    800027ea:	e915                	bnez	a0,8000281e <usertrap+0xc8>
    p->trapframe->epc += 4;
    800027ec:	6cb8                	ld	a4,88(s1)
    800027ee:	6f1c                	ld	a5,24(a4)
    800027f0:	0791                	addi	a5,a5,4
    800027f2:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    800027f4:	10016073          	csrsi	sstatus,2
    syscall();
    800027f8:	250000ef          	jal	80002a48 <syscall>
  if (killed(p))
    800027fc:	8526                	mv	a0,s1
    800027fe:	affff0ef          	jal	800022fc <killed>
    80002802:	e521                	bnez	a0,8000284a <usertrap+0xf4>
  prepare_return();
    80002804:	e13ff0ef          	jal	80002616 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002808:	68a8                	ld	a0,80(s1)
    8000280a:	8131                	srli	a0,a0,0xc
    8000280c:	57fd                	li	a5,-1
    8000280e:	17fe                	slli	a5,a5,0x3f
    80002810:	8d5d                	or	a0,a0,a5
}
    80002812:	60e2                	ld	ra,24(sp)
    80002814:	6442                	ld	s0,16(sp)
    80002816:	64a2                	ld	s1,8(sp)
    80002818:	6902                	ld	s2,0(sp)
    8000281a:	6105                	addi	sp,sp,32
    8000281c:	8082                	ret
      kexit(-1);
    8000281e:	557d                	li	a0,-1
    80002820:	9a7ff0ef          	jal	800021c6 <kexit>
    80002824:	b7e1                	j	800027ec <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002826:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    8000282a:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    8000282e:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    80002830:	0016b693          	seqz	a3,a3
    80002834:	64ac                	ld	a1,72(s1)
    80002836:	68a8                	ld	a0,80(s1)
    80002838:	ccffe0ef          	jal	80001506 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    8000283c:	f161                	bnez	a0,800027fc <usertrap+0xa6>
    8000283e:	b7bd                	j	800027ac <usertrap+0x56>
  if (killed(p))
    80002840:	8526                	mv	a0,s1
    80002842:	abbff0ef          	jal	800022fc <killed>
    80002846:	c511                	beqz	a0,80002852 <usertrap+0xfc>
    80002848:	a011                	j	8000284c <usertrap+0xf6>
    8000284a:	4901                	li	s2,0
    kexit(-1);
    8000284c:	557d                	li	a0,-1
    8000284e:	979ff0ef          	jal	800021c6 <kexit>
  if (which_dev == 2) {
    80002852:	4789                	li	a5,2
    80002854:	faf918e3          	bne	s2,a5,80002804 <usertrap+0xae>
    if (mlfq_timer_tick())
    80002858:	d6eff0ef          	jal	80001dc6 <mlfq_timer_tick>
    8000285c:	d545                	beqz	a0,80002804 <usertrap+0xae>
      yield();
    8000285e:	811ff0ef          	jal	8000206e <yield>
    80002862:	b74d                	j	80002804 <usertrap+0xae>

0000000080002864 <kerneltrap>:
{
    80002864:	7179                	addi	sp,sp,-48
    80002866:	f406                	sd	ra,40(sp)
    80002868:	f022                	sd	s0,32(sp)
    8000286a:	ec26                	sd	s1,24(sp)
    8000286c:	e84a                	sd	s2,16(sp)
    8000286e:	e44e                	sd	s3,8(sp)
    80002870:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002872:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002876:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    8000287a:	142027f3          	csrr	a5,scause
    8000287e:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    80002880:	1004f793          	andi	a5,s1,256
    80002884:	c795                	beqz	a5,800028b0 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002886:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000288a:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000288c:	eb85                	bnez	a5,800028bc <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    8000288e:	e53ff0ef          	jal	800026e0 <devintr>
    80002892:	c91d                	beqz	a0,800028c8 <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0) {
    80002894:	4789                	li	a5,2
    80002896:	04f50a63          	beq	a0,a5,800028ea <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    8000289a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000289e:	10049073          	csrw	sstatus,s1
}
    800028a2:	70a2                	ld	ra,40(sp)
    800028a4:	7402                	ld	s0,32(sp)
    800028a6:	64e2                	ld	s1,24(sp)
    800028a8:	6942                	ld	s2,16(sp)
    800028aa:	69a2                	ld	s3,8(sp)
    800028ac:	6145                	addi	sp,sp,48
    800028ae:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028b0:	00005517          	auipc	a0,0x5
    800028b4:	a5850513          	addi	a0,a0,-1448 # 80007308 <etext+0x308>
    800028b8:	f7dfd0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    800028bc:	00005517          	auipc	a0,0x5
    800028c0:	a7450513          	addi	a0,a0,-1420 # 80007330 <etext+0x330>
    800028c4:	f71fd0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800028c8:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800028cc:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800028d0:	85ce                	mv	a1,s3
    800028d2:	00005517          	auipc	a0,0x5
    800028d6:	a7e50513          	addi	a0,a0,-1410 # 80007350 <etext+0x350>
    800028da:	c31fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    800028de:	00005517          	auipc	a0,0x5
    800028e2:	a9a50513          	addi	a0,a0,-1382 # 80007378 <etext+0x378>
    800028e6:	f4ffd0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0) {
    800028ea:	85eff0ef          	jal	80001948 <myproc>
    800028ee:	d555                	beqz	a0,8000289a <kerneltrap+0x36>
    if (mlfq_timer_tick())
    800028f0:	cd6ff0ef          	jal	80001dc6 <mlfq_timer_tick>
    800028f4:	d15d                	beqz	a0,8000289a <kerneltrap+0x36>
      yield();
    800028f6:	f78ff0ef          	jal	8000206e <yield>
    800028fa:	b745                	j	8000289a <kerneltrap+0x36>

00000000800028fc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800028fc:	1101                	addi	sp,sp,-32
    800028fe:	ec06                	sd	ra,24(sp)
    80002900:	e822                	sd	s0,16(sp)
    80002902:	e426                	sd	s1,8(sp)
    80002904:	1000                	addi	s0,sp,32
    80002906:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002908:	840ff0ef          	jal	80001948 <myproc>
  switch (n) {
    8000290c:	4795                	li	a5,5
    8000290e:	0497e163          	bltu	a5,s1,80002950 <argraw+0x54>
    80002912:	048a                	slli	s1,s1,0x2
    80002914:	00005717          	auipc	a4,0x5
    80002918:	e6470713          	addi	a4,a4,-412 # 80007778 <states.0+0x30>
    8000291c:	94ba                	add	s1,s1,a4
    8000291e:	409c                	lw	a5,0(s1)
    80002920:	97ba                	add	a5,a5,a4
    80002922:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002924:	6d3c                	ld	a5,88(a0)
    80002926:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002928:	60e2                	ld	ra,24(sp)
    8000292a:	6442                	ld	s0,16(sp)
    8000292c:	64a2                	ld	s1,8(sp)
    8000292e:	6105                	addi	sp,sp,32
    80002930:	8082                	ret
    return p->trapframe->a1;
    80002932:	6d3c                	ld	a5,88(a0)
    80002934:	7fa8                	ld	a0,120(a5)
    80002936:	bfcd                	j	80002928 <argraw+0x2c>
    return p->trapframe->a2;
    80002938:	6d3c                	ld	a5,88(a0)
    8000293a:	63c8                	ld	a0,128(a5)
    8000293c:	b7f5                	j	80002928 <argraw+0x2c>
    return p->trapframe->a3;
    8000293e:	6d3c                	ld	a5,88(a0)
    80002940:	67c8                	ld	a0,136(a5)
    80002942:	b7dd                	j	80002928 <argraw+0x2c>
    return p->trapframe->a4;
    80002944:	6d3c                	ld	a5,88(a0)
    80002946:	6bc8                	ld	a0,144(a5)
    80002948:	b7c5                	j	80002928 <argraw+0x2c>
    return p->trapframe->a5;
    8000294a:	6d3c                	ld	a5,88(a0)
    8000294c:	6fc8                	ld	a0,152(a5)
    8000294e:	bfe9                	j	80002928 <argraw+0x2c>
  panic("argraw");
    80002950:	00005517          	auipc	a0,0x5
    80002954:	a3850513          	addi	a0,a0,-1480 # 80007388 <etext+0x388>
    80002958:	eddfd0ef          	jal	80000834 <panic>

000000008000295c <fetchaddr>:
{
    8000295c:	1101                	addi	sp,sp,-32
    8000295e:	ec06                	sd	ra,24(sp)
    80002960:	e822                	sd	s0,16(sp)
    80002962:	e426                	sd	s1,8(sp)
    80002964:	e04a                	sd	s2,0(sp)
    80002966:	1000                	addi	s0,sp,32
    80002968:	84aa                	mv	s1,a0
    8000296a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000296c:	fddfe0ef          	jal	80001948 <myproc>
  if (addr >= p->sz ||
    80002970:	652c                	ld	a1,72(a0)
    80002972:	02b4f663          	bgeu	s1,a1,8000299e <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002976:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    8000297a:	02f5e463          	bltu	a1,a5,800029a2 <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    8000297e:	4721                	li	a4,8
    80002980:	86a6                	mv	a3,s1
    80002982:	864a                	mv	a2,s2
    80002984:	6928                	ld	a0,80(a0)
    80002986:	cc3fe0ef          	jal	80001648 <copyin>
    8000298a:	00a03533          	snez	a0,a0
    8000298e:	40a0053b          	negw	a0,a0
}
    80002992:	60e2                	ld	ra,24(sp)
    80002994:	6442                	ld	s0,16(sp)
    80002996:	64a2                	ld	s1,8(sp)
    80002998:	6902                	ld	s2,0(sp)
    8000299a:	6105                	addi	sp,sp,32
    8000299c:	8082                	ret
    return -1;
    8000299e:	557d                	li	a0,-1
    800029a0:	bfcd                	j	80002992 <fetchaddr+0x36>
    800029a2:	557d                	li	a0,-1
    800029a4:	b7fd                	j	80002992 <fetchaddr+0x36>

00000000800029a6 <fetchstr>:
{
    800029a6:	7179                	addi	sp,sp,-48
    800029a8:	f406                	sd	ra,40(sp)
    800029aa:	f022                	sd	s0,32(sp)
    800029ac:	ec26                	sd	s1,24(sp)
    800029ae:	e84a                	sd	s2,16(sp)
    800029b0:	e44e                	sd	s3,8(sp)
    800029b2:	1800                	addi	s0,sp,48
    800029b4:	89aa                	mv	s3,a0
    800029b6:	84ae                	mv	s1,a1
    800029b8:	8932                	mv	s2,a2
  struct proc *p = myproc();
    800029ba:	f8ffe0ef          	jal	80001948 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    800029be:	874a                	mv	a4,s2
    800029c0:	86ce                	mv	a3,s3
    800029c2:	8626                	mv	a2,s1
    800029c4:	652c                	ld	a1,72(a0)
    800029c6:	6928                	ld	a0,80(a0)
    800029c8:	d1dfe0ef          	jal	800016e4 <copyinstr>
    800029cc:	00054c63          	bltz	a0,800029e4 <fetchstr+0x3e>
  return strlen(buf);
    800029d0:	8526                	mv	a0,s1
    800029d2:	ca0fe0ef          	jal	80000e72 <strlen>
}
    800029d6:	70a2                	ld	ra,40(sp)
    800029d8:	7402                	ld	s0,32(sp)
    800029da:	64e2                	ld	s1,24(sp)
    800029dc:	6942                	ld	s2,16(sp)
    800029de:	69a2                	ld	s3,8(sp)
    800029e0:	6145                	addi	sp,sp,48
    800029e2:	8082                	ret
    return -1;
    800029e4:	557d                	li	a0,-1
    800029e6:	bfc5                	j	800029d6 <fetchstr+0x30>

00000000800029e8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800029e8:	1101                	addi	sp,sp,-32
    800029ea:	ec06                	sd	ra,24(sp)
    800029ec:	e822                	sd	s0,16(sp)
    800029ee:	e426                	sd	s1,8(sp)
    800029f0:	1000                	addi	s0,sp,32
    800029f2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800029f4:	f09ff0ef          	jal	800028fc <argraw>
    800029f8:	c088                	sw	a0,0(s1)
}
    800029fa:	60e2                	ld	ra,24(sp)
    800029fc:	6442                	ld	s0,16(sp)
    800029fe:	64a2                	ld	s1,8(sp)
    80002a00:	6105                	addi	sp,sp,32
    80002a02:	8082                	ret

0000000080002a04 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a04:	1101                	addi	sp,sp,-32
    80002a06:	ec06                	sd	ra,24(sp)
    80002a08:	e822                	sd	s0,16(sp)
    80002a0a:	e426                	sd	s1,8(sp)
    80002a0c:	1000                	addi	s0,sp,32
    80002a0e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a10:	eedff0ef          	jal	800028fc <argraw>
    80002a14:	e088                	sd	a0,0(s1)
}
    80002a16:	60e2                	ld	ra,24(sp)
    80002a18:	6442                	ld	s0,16(sp)
    80002a1a:	64a2                	ld	s1,8(sp)
    80002a1c:	6105                	addi	sp,sp,32
    80002a1e:	8082                	ret

0000000080002a20 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a20:	1101                	addi	sp,sp,-32
    80002a22:	ec06                	sd	ra,24(sp)
    80002a24:	e822                	sd	s0,16(sp)
    80002a26:	e426                	sd	s1,8(sp)
    80002a28:	e04a                	sd	s2,0(sp)
    80002a2a:	1000                	addi	s0,sp,32
    80002a2c:	892e                	mv	s2,a1
    80002a2e:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002a30:	ecdff0ef          	jal	800028fc <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002a34:	8626                	mv	a2,s1
    80002a36:	85ca                	mv	a1,s2
    80002a38:	f6fff0ef          	jal	800029a6 <fetchstr>
}
    80002a3c:	60e2                	ld	ra,24(sp)
    80002a3e:	6442                	ld	s0,16(sp)
    80002a40:	64a2                	ld	s1,8(sp)
    80002a42:	6902                	ld	s2,0(sp)
    80002a44:	6105                	addi	sp,sp,32
    80002a46:	8082                	ret

0000000080002a48 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002a48:	1101                	addi	sp,sp,-32
    80002a4a:	ec06                	sd	ra,24(sp)
    80002a4c:	e822                	sd	s0,16(sp)
    80002a4e:	e426                	sd	s1,8(sp)
    80002a50:	e04a                	sd	s2,0(sp)
    80002a52:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002a54:	ef5fe0ef          	jal	80001948 <myproc>
    80002a58:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002a5a:	05853903          	ld	s2,88(a0)
    80002a5e:	0a893783          	ld	a5,168(s2)
    80002a62:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002a66:	37fd                	addiw	a5,a5,-1
    80002a68:	4759                	li	a4,22
    80002a6a:	00f76f63          	bltu	a4,a5,80002a88 <syscall+0x40>
    80002a6e:	00369713          	slli	a4,a3,0x3
    80002a72:	00005797          	auipc	a5,0x5
    80002a76:	d1e78793          	addi	a5,a5,-738 # 80007790 <syscalls>
    80002a7a:	97ba                	add	a5,a5,a4
    80002a7c:	639c                	ld	a5,0(a5)
    80002a7e:	c789                	beqz	a5,80002a88 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002a80:	9782                	jalr	a5
    80002a82:	06a93823          	sd	a0,112(s2)
    80002a86:	a829                	j	80002aa0 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002a88:	15848613          	addi	a2,s1,344
    80002a8c:	588c                	lw	a1,48(s1)
    80002a8e:	00005517          	auipc	a0,0x5
    80002a92:	90250513          	addi	a0,a0,-1790 # 80007390 <etext+0x390>
    80002a96:	a75fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002a9a:	6cbc                	ld	a5,88(s1)
    80002a9c:	577d                	li	a4,-1
    80002a9e:	fbb8                	sd	a4,112(a5)
  }
}
    80002aa0:	60e2                	ld	ra,24(sp)
    80002aa2:	6442                	ld	s0,16(sp)
    80002aa4:	64a2                	ld	s1,8(sp)
    80002aa6:	6902                	ld	s2,0(sp)
    80002aa8:	6105                	addi	sp,sp,32
    80002aaa:	8082                	ret

0000000080002aac <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002aac:	1101                	addi	sp,sp,-32
    80002aae:	ec06                	sd	ra,24(sp)
    80002ab0:	e822                	sd	s0,16(sp)
    80002ab2:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002ab4:	fec40593          	addi	a1,s0,-20
    80002ab8:	4501                	li	a0,0
    80002aba:	f2fff0ef          	jal	800029e8 <argint>
  kexit(n);
    80002abe:	fec42503          	lw	a0,-20(s0)
    80002ac2:	f04ff0ef          	jal	800021c6 <kexit>
  return 0; // not reached
}
    80002ac6:	4501                	li	a0,0
    80002ac8:	60e2                	ld	ra,24(sp)
    80002aca:	6442                	ld	s0,16(sp)
    80002acc:	6105                	addi	sp,sp,32
    80002ace:	8082                	ret

0000000080002ad0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ad0:	1141                	addi	sp,sp,-16
    80002ad2:	e406                	sd	ra,8(sp)
    80002ad4:	e022                	sd	s0,0(sp)
    80002ad6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ad8:	e71fe0ef          	jal	80001948 <myproc>
}
    80002adc:	5908                	lw	a0,48(a0)
    80002ade:	60a2                	ld	ra,8(sp)
    80002ae0:	6402                	ld	s0,0(sp)
    80002ae2:	0141                	addi	sp,sp,16
    80002ae4:	8082                	ret

0000000080002ae6 <sys_fork>:

uint64
sys_fork(void)
{
    80002ae6:	1141                	addi	sp,sp,-16
    80002ae8:	e406                	sd	ra,8(sp)
    80002aea:	e022                	sd	s0,0(sp)
    80002aec:	0800                	addi	s0,sp,16
  return kfork();
    80002aee:	9caff0ef          	jal	80001cb8 <kfork>
}
    80002af2:	60a2                	ld	ra,8(sp)
    80002af4:	6402                	ld	s0,0(sp)
    80002af6:	0141                	addi	sp,sp,16
    80002af8:	8082                	ret

0000000080002afa <sys_wait>:

uint64
sys_wait(void)
{
    80002afa:	1101                	addi	sp,sp,-32
    80002afc:	ec06                	sd	ra,24(sp)
    80002afe:	e822                	sd	s0,16(sp)
    80002b00:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b02:	fe840593          	addi	a1,s0,-24
    80002b06:	4501                	li	a0,0
    80002b08:	efdff0ef          	jal	80002a04 <argaddr>
  return kwait(p);
    80002b0c:	fe843503          	ld	a0,-24(s0)
    80002b10:	817ff0ef          	jal	80002326 <kwait>
}
    80002b14:	60e2                	ld	ra,24(sp)
    80002b16:	6442                	ld	s0,16(sp)
    80002b18:	6105                	addi	sp,sp,32
    80002b1a:	8082                	ret

0000000080002b1c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b1c:	7179                	addi	sp,sp,-48
    80002b1e:	f406                	sd	ra,40(sp)
    80002b20:	f022                	sd	s0,32(sp)
    80002b22:	ec26                	sd	s1,24(sp)
    80002b24:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002b26:	fd840593          	addi	a1,s0,-40
    80002b2a:	4501                	li	a0,0
    80002b2c:	ebdff0ef          	jal	800029e8 <argint>
  argint(1, &t);
    80002b30:	fdc40593          	addi	a1,s0,-36
    80002b34:	4505                	li	a0,1
    80002b36:	eb3ff0ef          	jal	800029e8 <argint>
  addr = myproc()->sz;
    80002b3a:	e0ffe0ef          	jal	80001948 <myproc>
    80002b3e:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002b40:	fdc42703          	lw	a4,-36(s0)
    80002b44:	4785                	li	a5,1
    80002b46:	02f70763          	beq	a4,a5,80002b74 <sys_sbrk+0x58>
    80002b4a:	fd842783          	lw	a5,-40(s0)
    80002b4e:	0207c363          	bltz	a5,80002b74 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002b52:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002b54:	02000737          	lui	a4,0x2000
    80002b58:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002b5a:	0736                	slli	a4,a4,0xd
    80002b5c:	02f76a63          	bltu	a4,a5,80002b90 <sys_sbrk+0x74>
    80002b60:	0297e863          	bltu	a5,s1,80002b90 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002b64:	de5fe0ef          	jal	80001948 <myproc>
    80002b68:	fd842703          	lw	a4,-40(s0)
    80002b6c:	653c                	ld	a5,72(a0)
    80002b6e:	97ba                	add	a5,a5,a4
    80002b70:	e53c                	sd	a5,72(a0)
    80002b72:	a039                	j	80002b80 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002b74:	fd842503          	lw	a0,-40(s0)
    80002b78:	8deff0ef          	jal	80001c56 <growproc>
    80002b7c:	00054863          	bltz	a0,80002b8c <sys_sbrk+0x70>
  }
  return addr;
}
    80002b80:	8526                	mv	a0,s1
    80002b82:	70a2                	ld	ra,40(sp)
    80002b84:	7402                	ld	s0,32(sp)
    80002b86:	64e2                	ld	s1,24(sp)
    80002b88:	6145                	addi	sp,sp,48
    80002b8a:	8082                	ret
      return -1;
    80002b8c:	54fd                	li	s1,-1
    80002b8e:	bfcd                	j	80002b80 <sys_sbrk+0x64>
      return -1;
    80002b90:	54fd                	li	s1,-1
    80002b92:	b7fd                	j	80002b80 <sys_sbrk+0x64>

0000000080002b94 <sys_pause>:

uint64
sys_pause(void)
{
    80002b94:	7139                	addi	sp,sp,-64
    80002b96:	fc06                	sd	ra,56(sp)
    80002b98:	f822                	sd	s0,48(sp)
    80002b9a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002b9c:	fcc40593          	addi	a1,s0,-52
    80002ba0:	4501                	li	a0,0
    80002ba2:	e47ff0ef          	jal	800029e8 <argint>
  if (n < 0)
    80002ba6:	fcc42783          	lw	a5,-52(s0)
    80002baa:	0807c063          	bltz	a5,80002c2a <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002bae:	00016517          	auipc	a0,0x16
    80002bb2:	91a50513          	addi	a0,a0,-1766 # 800184c8 <tickslock>
    80002bb6:	872fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002bba:	fcc42783          	lw	a5,-52(s0)
    80002bbe:	cbb9                	beqz	a5,80002c14 <sys_pause+0x80>
    80002bc0:	f426                	sd	s1,40(sp)
    80002bc2:	f04a                	sd	s2,32(sp)
    80002bc4:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002bc6:	00007997          	auipc	s3,0x7
    80002bca:	7d29a983          	lw	s3,2002(s3) # 8000a398 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002bce:	00007917          	auipc	s2,0x7
    80002bd2:	7ca90913          	addi	s2,s2,1994 # 8000a398 <ticks>
    release(&tickslock);
    80002bd6:	00016497          	auipc	s1,0x16
    80002bda:	8f248493          	addi	s1,s1,-1806 # 800184c8 <tickslock>
    if (killed(myproc())) {
    80002bde:	d6bfe0ef          	jal	80001948 <myproc>
    80002be2:	f1aff0ef          	jal	800022fc <killed>
    80002be6:	e529                	bnez	a0,80002c30 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002be8:	854a                	mv	a0,s2
    80002bea:	cb0ff0ef          	jal	8000209a <sleep_prepare>
    release(&tickslock);
    80002bee:	8526                	mv	a0,s1
    80002bf0:	8c0fe0ef          	jal	80000cb0 <release>
    sleep();
    80002bf4:	ce2ff0ef          	jal	800020d6 <sleep>
    acquire(&tickslock);
    80002bf8:	8526                	mv	a0,s1
    80002bfa:	82efe0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002bfe:	00092783          	lw	a5,0(s2)
    80002c02:	413787bb          	subw	a5,a5,s3
    80002c06:	fcc42703          	lw	a4,-52(s0)
    80002c0a:	fce7eae3          	bltu	a5,a4,80002bde <sys_pause+0x4a>
    80002c0e:	74a2                	ld	s1,40(sp)
    80002c10:	7902                	ld	s2,32(sp)
    80002c12:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002c14:	00016517          	auipc	a0,0x16
    80002c18:	8b450513          	addi	a0,a0,-1868 # 800184c8 <tickslock>
    80002c1c:	894fe0ef          	jal	80000cb0 <release>
  return 0;
    80002c20:	4501                	li	a0,0
}
    80002c22:	70e2                	ld	ra,56(sp)
    80002c24:	7442                	ld	s0,48(sp)
    80002c26:	6121                	addi	sp,sp,64
    80002c28:	8082                	ret
    n = 0;
    80002c2a:	fc042623          	sw	zero,-52(s0)
    80002c2e:	b741                	j	80002bae <sys_pause+0x1a>
      release(&tickslock);
    80002c30:	00016517          	auipc	a0,0x16
    80002c34:	89850513          	addi	a0,a0,-1896 # 800184c8 <tickslock>
    80002c38:	878fe0ef          	jal	80000cb0 <release>
      return -1;
    80002c3c:	557d                	li	a0,-1
    80002c3e:	74a2                	ld	s1,40(sp)
    80002c40:	7902                	ld	s2,32(sp)
    80002c42:	69e2                	ld	s3,24(sp)
    80002c44:	bff9                	j	80002c22 <sys_pause+0x8e>

0000000080002c46 <sys_kill>:

uint64
sys_kill(void)
{
    80002c46:	1101                	addi	sp,sp,-32
    80002c48:	ec06                	sd	ra,24(sp)
    80002c4a:	e822                	sd	s0,16(sp)
    80002c4c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002c4e:	fec40593          	addi	a1,s0,-20
    80002c52:	4501                	li	a0,0
    80002c54:	d95ff0ef          	jal	800029e8 <argint>
  return kkill(pid);
    80002c58:	fec42503          	lw	a0,-20(s0)
    80002c5c:	e10ff0ef          	jal	8000226c <kkill>
}
    80002c60:	60e2                	ld	ra,24(sp)
    80002c62:	6442                	ld	s0,16(sp)
    80002c64:	6105                	addi	sp,sp,32
    80002c66:	8082                	ret

0000000080002c68 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002c68:	1101                	addi	sp,sp,-32
    80002c6a:	ec06                	sd	ra,24(sp)
    80002c6c:	e822                	sd	s0,16(sp)
    80002c6e:	e426                	sd	s1,8(sp)
    80002c70:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002c72:	00016517          	auipc	a0,0x16
    80002c76:	85650513          	addi	a0,a0,-1962 # 800184c8 <tickslock>
    80002c7a:	faffd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002c7e:	00007797          	auipc	a5,0x7
    80002c82:	71a7a783          	lw	a5,1818(a5) # 8000a398 <ticks>
    80002c86:	84be                	mv	s1,a5
  release(&tickslock);
    80002c88:	00016517          	auipc	a0,0x16
    80002c8c:	84050513          	addi	a0,a0,-1984 # 800184c8 <tickslock>
    80002c90:	820fe0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002c94:	02049513          	slli	a0,s1,0x20
    80002c98:	9101                	srli	a0,a0,0x20
    80002c9a:	60e2                	ld	ra,24(sp)
    80002c9c:	6442                	ld	s0,16(sp)
    80002c9e:	64a2                	ld	s1,8(sp)
    80002ca0:	6105                	addi	sp,sp,32
    80002ca2:	8082                	ret

0000000080002ca4 <sys_get_queue>:

// MLFQ: System call to query process queue level
uint64
sys_get_queue(void)
{
    80002ca4:	1101                	addi	sp,sp,-32
    80002ca6:	ec06                	sd	ra,24(sp)
    80002ca8:	e822                	sd	s0,16(sp)
    80002caa:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002cac:	fec40593          	addi	a1,s0,-20
    80002cb0:	4501                	li	a0,0
    80002cb2:	d37ff0ef          	jal	800029e8 <argint>
  return get_queue(pid);
    80002cb6:	fec42503          	lw	a0,-20(s0)
    80002cba:	986ff0ef          	jal	80001e40 <get_queue>
}
    80002cbe:	60e2                	ld	ra,24(sp)
    80002cc0:	6442                	ld	s0,16(sp)
    80002cc2:	6105                	addi	sp,sp,32
    80002cc4:	8082                	ret

0000000080002cc6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002cc6:	7179                	addi	sp,sp,-48
    80002cc8:	f406                	sd	ra,40(sp)
    80002cca:	f022                	sd	s0,32(sp)
    80002ccc:	ec26                	sd	s1,24(sp)
    80002cce:	e84a                	sd	s2,16(sp)
    80002cd0:	e44e                	sd	s3,8(sp)
    80002cd2:	e052                	sd	s4,0(sp)
    80002cd4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002cd6:	00004597          	auipc	a1,0x4
    80002cda:	6da58593          	addi	a1,a1,1754 # 800073b0 <etext+0x3b0>
    80002cde:	00016517          	auipc	a0,0x16
    80002ce2:	80250513          	addi	a0,a0,-2046 # 800184e0 <bcache>
    80002ce6:	ec3fd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002cea:	0001d797          	auipc	a5,0x1d
    80002cee:	7f678793          	addi	a5,a5,2038 # 800204e0 <bcache+0x8000>
    80002cf2:	0001e717          	auipc	a4,0x1e
    80002cf6:	a5670713          	addi	a4,a4,-1450 # 80020748 <bcache+0x8268>
    80002cfa:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002cfe:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002d02:	00015497          	auipc	s1,0x15
    80002d06:	7f648493          	addi	s1,s1,2038 # 800184f8 <bcache+0x18>
    b->next = bcache.head.next;
    80002d0a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d0c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d0e:	00004a17          	auipc	s4,0x4
    80002d12:	6aaa0a13          	addi	s4,s4,1706 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002d16:	2b893783          	ld	a5,696(s2)
    80002d1a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d1c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d20:	85d2                	mv	a1,s4
    80002d22:	01048513          	addi	a0,s1,16
    80002d26:	41c010ef          	jal	80004142 <initsleeplock>
    bcache.head.next->prev = b;
    80002d2a:	2b893783          	ld	a5,696(s2)
    80002d2e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d30:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002d34:	45848493          	addi	s1,s1,1112
    80002d38:	fd349fe3          	bne	s1,s3,80002d16 <binit+0x50>
  }
}
    80002d3c:	70a2                	ld	ra,40(sp)
    80002d3e:	7402                	ld	s0,32(sp)
    80002d40:	64e2                	ld	s1,24(sp)
    80002d42:	6942                	ld	s2,16(sp)
    80002d44:	69a2                	ld	s3,8(sp)
    80002d46:	6a02                	ld	s4,0(sp)
    80002d48:	6145                	addi	sp,sp,48
    80002d4a:	8082                	ret

0000000080002d4c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002d4c:	7179                	addi	sp,sp,-48
    80002d4e:	f406                	sd	ra,40(sp)
    80002d50:	f022                	sd	s0,32(sp)
    80002d52:	ec26                	sd	s1,24(sp)
    80002d54:	e84a                	sd	s2,16(sp)
    80002d56:	e44e                	sd	s3,8(sp)
    80002d58:	1800                	addi	s0,sp,48
    80002d5a:	892a                	mv	s2,a0
    80002d5c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d5e:	00015517          	auipc	a0,0x15
    80002d62:	78250513          	addi	a0,a0,1922 # 800184e0 <bcache>
    80002d66:	ec3fd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002d6a:	0001e497          	auipc	s1,0x1e
    80002d6e:	a2e4b483          	ld	s1,-1490(s1) # 80020798 <bcache+0x82b8>
    80002d72:	0001e797          	auipc	a5,0x1e
    80002d76:	9d678793          	addi	a5,a5,-1578 # 80020748 <bcache+0x8268>
    80002d7a:	02f48b63          	beq	s1,a5,80002db0 <bread+0x64>
    80002d7e:	873e                	mv	a4,a5
    80002d80:	a021                	j	80002d88 <bread+0x3c>
    80002d82:	68a4                	ld	s1,80(s1)
    80002d84:	02e48663          	beq	s1,a4,80002db0 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002d88:	449c                	lw	a5,8(s1)
    80002d8a:	ff279ce3          	bne	a5,s2,80002d82 <bread+0x36>
    80002d8e:	44dc                	lw	a5,12(s1)
    80002d90:	ff3799e3          	bne	a5,s3,80002d82 <bread+0x36>
      b->refcnt++;
    80002d94:	40bc                	lw	a5,64(s1)
    80002d96:	2785                	addiw	a5,a5,1
    80002d98:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d9a:	00015517          	auipc	a0,0x15
    80002d9e:	74650513          	addi	a0,a0,1862 # 800184e0 <bcache>
    80002da2:	f0ffd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002da6:	01048513          	addi	a0,s1,16
    80002daa:	3ce010ef          	jal	80004178 <acquiresleep>
      return b;
    80002dae:	a889                	j	80002e00 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002db0:	0001e497          	auipc	s1,0x1e
    80002db4:	9e04b483          	ld	s1,-1568(s1) # 80020790 <bcache+0x82b0>
    80002db8:	0001e797          	auipc	a5,0x1e
    80002dbc:	99078793          	addi	a5,a5,-1648 # 80020748 <bcache+0x8268>
    80002dc0:	00f48863          	beq	s1,a5,80002dd0 <bread+0x84>
    80002dc4:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002dc6:	40bc                	lw	a5,64(s1)
    80002dc8:	cb91                	beqz	a5,80002ddc <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002dca:	64a4                	ld	s1,72(s1)
    80002dcc:	fee49de3          	bne	s1,a4,80002dc6 <bread+0x7a>
  panic("bget: no buffers");
    80002dd0:	00004517          	auipc	a0,0x4
    80002dd4:	5f050513          	addi	a0,a0,1520 # 800073c0 <etext+0x3c0>
    80002dd8:	a5dfd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002ddc:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002de0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002de4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002de8:	4785                	li	a5,1
    80002dea:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002dec:	00015517          	auipc	a0,0x15
    80002df0:	6f450513          	addi	a0,a0,1780 # 800184e0 <bcache>
    80002df4:	ebdfd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002df8:	01048513          	addi	a0,s1,16
    80002dfc:	37c010ef          	jal	80004178 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002e00:	409c                	lw	a5,0(s1)
    80002e02:	cb89                	beqz	a5,80002e14 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e04:	8526                	mv	a0,s1
    80002e06:	70a2                	ld	ra,40(sp)
    80002e08:	7402                	ld	s0,32(sp)
    80002e0a:	64e2                	ld	s1,24(sp)
    80002e0c:	6942                	ld	s2,16(sp)
    80002e0e:	69a2                	ld	s3,8(sp)
    80002e10:	6145                	addi	sp,sp,48
    80002e12:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e14:	4581                	li	a1,0
    80002e16:	8526                	mv	a0,s1
    80002e18:	4bf020ef          	jal	80005ad6 <virtio_disk_rw>
    b->valid = 1;
    80002e1c:	4785                	li	a5,1
    80002e1e:	c09c                	sw	a5,0(s1)
  return b;
    80002e20:	b7d5                	j	80002e04 <bread+0xb8>

0000000080002e22 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002e22:	1101                	addi	sp,sp,-32
    80002e24:	ec06                	sd	ra,24(sp)
    80002e26:	e822                	sd	s0,16(sp)
    80002e28:	e426                	sd	s1,8(sp)
    80002e2a:	1000                	addi	s0,sp,32
    80002e2c:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002e2e:	0541                	addi	a0,a0,16
    80002e30:	3d4010ef          	jal	80004204 <holdingsleep>
    80002e34:	c911                	beqz	a0,80002e48 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e36:	4585                	li	a1,1
    80002e38:	8526                	mv	a0,s1
    80002e3a:	49d020ef          	jal	80005ad6 <virtio_disk_rw>
}
    80002e3e:	60e2                	ld	ra,24(sp)
    80002e40:	6442                	ld	s0,16(sp)
    80002e42:	64a2                	ld	s1,8(sp)
    80002e44:	6105                	addi	sp,sp,32
    80002e46:	8082                	ret
    panic("bwrite");
    80002e48:	00004517          	auipc	a0,0x4
    80002e4c:	59050513          	addi	a0,a0,1424 # 800073d8 <etext+0x3d8>
    80002e50:	9e5fd0ef          	jal	80000834 <panic>

0000000080002e54 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e54:	1101                	addi	sp,sp,-32
    80002e56:	ec06                	sd	ra,24(sp)
    80002e58:	e822                	sd	s0,16(sp)
    80002e5a:	e426                	sd	s1,8(sp)
    80002e5c:	e04a                	sd	s2,0(sp)
    80002e5e:	1000                	addi	s0,sp,32
    80002e60:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002e62:	01050913          	addi	s2,a0,16
    80002e66:	854a                	mv	a0,s2
    80002e68:	39c010ef          	jal	80004204 <holdingsleep>
    80002e6c:	c125                	beqz	a0,80002ecc <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002e6e:	854a                	mv	a0,s2
    80002e70:	35c010ef          	jal	800041cc <releasesleep>

  acquire(&bcache.lock);
    80002e74:	00015517          	auipc	a0,0x15
    80002e78:	66c50513          	addi	a0,a0,1644 # 800184e0 <bcache>
    80002e7c:	dadfd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002e80:	40bc                	lw	a5,64(s1)
    80002e82:	37fd                	addiw	a5,a5,-1
    80002e84:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e86:	e79d                	bnez	a5,80002eb4 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e88:	68b8                	ld	a4,80(s1)
    80002e8a:	64bc                	ld	a5,72(s1)
    80002e8c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002e8e:	68b8                	ld	a4,80(s1)
    80002e90:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e92:	0001d797          	auipc	a5,0x1d
    80002e96:	64e78793          	addi	a5,a5,1614 # 800204e0 <bcache+0x8000>
    80002e9a:	2b87b703          	ld	a4,696(a5)
    80002e9e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ea0:	0001e717          	auipc	a4,0x1e
    80002ea4:	8a870713          	addi	a4,a4,-1880 # 80020748 <bcache+0x8268>
    80002ea8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002eaa:	2b87b703          	ld	a4,696(a5)
    80002eae:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002eb0:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002eb4:	00015517          	auipc	a0,0x15
    80002eb8:	62c50513          	addi	a0,a0,1580 # 800184e0 <bcache>
    80002ebc:	df5fd0ef          	jal	80000cb0 <release>
}
    80002ec0:	60e2                	ld	ra,24(sp)
    80002ec2:	6442                	ld	s0,16(sp)
    80002ec4:	64a2                	ld	s1,8(sp)
    80002ec6:	6902                	ld	s2,0(sp)
    80002ec8:	6105                	addi	sp,sp,32
    80002eca:	8082                	ret
    panic("brelse");
    80002ecc:	00004517          	auipc	a0,0x4
    80002ed0:	51450513          	addi	a0,a0,1300 # 800073e0 <etext+0x3e0>
    80002ed4:	961fd0ef          	jal	80000834 <panic>

0000000080002ed8 <bpin>:

void
bpin(struct buf *b)
{
    80002ed8:	1101                	addi	sp,sp,-32
    80002eda:	ec06                	sd	ra,24(sp)
    80002edc:	e822                	sd	s0,16(sp)
    80002ede:	e426                	sd	s1,8(sp)
    80002ee0:	1000                	addi	s0,sp,32
    80002ee2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ee4:	00015517          	auipc	a0,0x15
    80002ee8:	5fc50513          	addi	a0,a0,1532 # 800184e0 <bcache>
    80002eec:	d3dfd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002ef0:	40bc                	lw	a5,64(s1)
    80002ef2:	2785                	addiw	a5,a5,1
    80002ef4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ef6:	00015517          	auipc	a0,0x15
    80002efa:	5ea50513          	addi	a0,a0,1514 # 800184e0 <bcache>
    80002efe:	db3fd0ef          	jal	80000cb0 <release>
}
    80002f02:	60e2                	ld	ra,24(sp)
    80002f04:	6442                	ld	s0,16(sp)
    80002f06:	64a2                	ld	s1,8(sp)
    80002f08:	6105                	addi	sp,sp,32
    80002f0a:	8082                	ret

0000000080002f0c <bunpin>:

void
bunpin(struct buf *b)
{
    80002f0c:	1101                	addi	sp,sp,-32
    80002f0e:	ec06                	sd	ra,24(sp)
    80002f10:	e822                	sd	s0,16(sp)
    80002f12:	e426                	sd	s1,8(sp)
    80002f14:	1000                	addi	s0,sp,32
    80002f16:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f18:	00015517          	auipc	a0,0x15
    80002f1c:	5c850513          	addi	a0,a0,1480 # 800184e0 <bcache>
    80002f20:	d09fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002f24:	40bc                	lw	a5,64(s1)
    80002f26:	37fd                	addiw	a5,a5,-1
    80002f28:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f2a:	00015517          	auipc	a0,0x15
    80002f2e:	5b650513          	addi	a0,a0,1462 # 800184e0 <bcache>
    80002f32:	d7ffd0ef          	jal	80000cb0 <release>
}
    80002f36:	60e2                	ld	ra,24(sp)
    80002f38:	6442                	ld	s0,16(sp)
    80002f3a:	64a2                	ld	s1,8(sp)
    80002f3c:	6105                	addi	sp,sp,32
    80002f3e:	8082                	ret

0000000080002f40 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f40:	1101                	addi	sp,sp,-32
    80002f42:	ec06                	sd	ra,24(sp)
    80002f44:	e822                	sd	s0,16(sp)
    80002f46:	e426                	sd	s1,8(sp)
    80002f48:	e04a                	sd	s2,0(sp)
    80002f4a:	1000                	addi	s0,sp,32
    80002f4c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f4e:	00d5d79b          	srliw	a5,a1,0xd
    80002f52:	0001e597          	auipc	a1,0x1e
    80002f56:	c6a5a583          	lw	a1,-918(a1) # 80020bbc <sb+0x1c>
    80002f5a:	9dbd                	addw	a1,a1,a5
    80002f5c:	df1ff0ef          	jal	80002d4c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f60:	0074f713          	andi	a4,s1,7
    80002f64:	4785                	li	a5,1
    80002f66:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002f6a:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002f6c:	90d9                	srli	s1,s1,0x36
    80002f6e:	00950733          	add	a4,a0,s1
    80002f72:	05874703          	lbu	a4,88(a4)
    80002f76:	00e7f6b3          	and	a3,a5,a4
    80002f7a:	c29d                	beqz	a3,80002fa0 <bfree+0x60>
    80002f7c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002f7e:	94aa                	add	s1,s1,a0
    80002f80:	fff7c793          	not	a5,a5
    80002f84:	8f7d                	and	a4,a4,a5
    80002f86:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002f8a:	080010ef          	jal	8000400a <log_write>
  brelse(bp);
    80002f8e:	854a                	mv	a0,s2
    80002f90:	ec5ff0ef          	jal	80002e54 <brelse>
}
    80002f94:	60e2                	ld	ra,24(sp)
    80002f96:	6442                	ld	s0,16(sp)
    80002f98:	64a2                	ld	s1,8(sp)
    80002f9a:	6902                	ld	s2,0(sp)
    80002f9c:	6105                	addi	sp,sp,32
    80002f9e:	8082                	ret
    panic("freeing free block");
    80002fa0:	00004517          	auipc	a0,0x4
    80002fa4:	44850513          	addi	a0,a0,1096 # 800073e8 <etext+0x3e8>
    80002fa8:	88dfd0ef          	jal	80000834 <panic>

0000000080002fac <balloc>:
{
    80002fac:	715d                	addi	sp,sp,-80
    80002fae:	e486                	sd	ra,72(sp)
    80002fb0:	e0a2                	sd	s0,64(sp)
    80002fb2:	fc26                	sd	s1,56(sp)
    80002fb4:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002fb6:	0001e797          	auipc	a5,0x1e
    80002fba:	bee7a783          	lw	a5,-1042(a5) # 80020ba4 <sb+0x4>
    80002fbe:	0e078263          	beqz	a5,800030a2 <balloc+0xf6>
    80002fc2:	f84a                	sd	s2,48(sp)
    80002fc4:	f44e                	sd	s3,40(sp)
    80002fc6:	f052                	sd	s4,32(sp)
    80002fc8:	ec56                	sd	s5,24(sp)
    80002fca:	e85a                	sd	s6,16(sp)
    80002fcc:	e45e                	sd	s7,8(sp)
    80002fce:	e062                	sd	s8,0(sp)
    80002fd0:	8baa                	mv	s7,a0
    80002fd2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002fd4:	0001eb17          	auipc	s6,0x1e
    80002fd8:	bccb0b13          	addi	s6,s6,-1076 # 80020ba0 <sb>
      m = 1 << (bi % 8);
    80002fdc:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002fde:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002fe0:	6c09                	lui	s8,0x2
    80002fe2:	a09d                	j	80003048 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002fe4:	97ca                	add	a5,a5,s2
    80002fe6:	8e55                	or	a2,a2,a3
    80002fe8:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002fec:	854a                	mv	a0,s2
    80002fee:	01c010ef          	jal	8000400a <log_write>
        brelse(bp);
    80002ff2:	854a                	mv	a0,s2
    80002ff4:	e61ff0ef          	jal	80002e54 <brelse>
  bp = bread(dev, bno);
    80002ff8:	85a6                	mv	a1,s1
    80002ffa:	855e                	mv	a0,s7
    80002ffc:	d51ff0ef          	jal	80002d4c <bread>
    80003000:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003002:	40000613          	li	a2,1024
    80003006:	4581                	li	a1,0
    80003008:	05850513          	addi	a0,a0,88
    8000300c:	cddfd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    80003010:	854a                	mv	a0,s2
    80003012:	7f9000ef          	jal	8000400a <log_write>
  brelse(bp);
    80003016:	854a                	mv	a0,s2
    80003018:	e3dff0ef          	jal	80002e54 <brelse>
}
    8000301c:	7942                	ld	s2,48(sp)
    8000301e:	79a2                	ld	s3,40(sp)
    80003020:	7a02                	ld	s4,32(sp)
    80003022:	6ae2                	ld	s5,24(sp)
    80003024:	6b42                	ld	s6,16(sp)
    80003026:	6ba2                	ld	s7,8(sp)
    80003028:	6c02                	ld	s8,0(sp)
}
    8000302a:	8526                	mv	a0,s1
    8000302c:	60a6                	ld	ra,72(sp)
    8000302e:	6406                	ld	s0,64(sp)
    80003030:	74e2                	ld	s1,56(sp)
    80003032:	6161                	addi	sp,sp,80
    80003034:	8082                	ret
    brelse(bp);
    80003036:	854a                	mv	a0,s2
    80003038:	e1dff0ef          	jal	80002e54 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    8000303c:	015c0abb          	addw	s5,s8,s5
    80003040:	004b2783          	lw	a5,4(s6)
    80003044:	04faf863          	bgeu	s5,a5,80003094 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80003048:	40dad59b          	sraiw	a1,s5,0xd
    8000304c:	01cb2783          	lw	a5,28(s6)
    80003050:	9dbd                	addw	a1,a1,a5
    80003052:	855e                	mv	a0,s7
    80003054:	cf9ff0ef          	jal	80002d4c <bread>
    80003058:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    8000305a:	004b2503          	lw	a0,4(s6)
    8000305e:	84d6                	mv	s1,s5
    80003060:	4701                	li	a4,0
    80003062:	fca4fae3          	bgeu	s1,a0,80003036 <balloc+0x8a>
      m = 1 << (bi % 8);
    80003066:	00777693          	andi	a3,a4,7
    8000306a:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    8000306e:	41f7579b          	sraiw	a5,a4,0x1f
    80003072:	01d7d79b          	srliw	a5,a5,0x1d
    80003076:	9fb9                	addw	a5,a5,a4
    80003078:	4037d79b          	sraiw	a5,a5,0x3
    8000307c:	00f90633          	add	a2,s2,a5
    80003080:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003084:	00c6f5b3          	and	a1,a3,a2
    80003088:	ddb1                	beqz	a1,80002fe4 <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    8000308a:	2705                	addiw	a4,a4,1
    8000308c:	2485                	addiw	s1,s1,1
    8000308e:	fd471ae3          	bne	a4,s4,80003062 <balloc+0xb6>
    80003092:	b755                	j	80003036 <balloc+0x8a>
    80003094:	7942                	ld	s2,48(sp)
    80003096:	79a2                	ld	s3,40(sp)
    80003098:	7a02                	ld	s4,32(sp)
    8000309a:	6ae2                	ld	s5,24(sp)
    8000309c:	6b42                	ld	s6,16(sp)
    8000309e:	6ba2                	ld	s7,8(sp)
    800030a0:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    800030a2:	00004517          	auipc	a0,0x4
    800030a6:	35e50513          	addi	a0,a0,862 # 80007400 <etext+0x400>
    800030aa:	c60fd0ef          	jal	8000050a <printk>
  return 0;
    800030ae:	4481                	li	s1,0
    800030b0:	bfad                	j	8000302a <balloc+0x7e>

00000000800030b2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800030b2:	7179                	addi	sp,sp,-48
    800030b4:	f406                	sd	ra,40(sp)
    800030b6:	f022                	sd	s0,32(sp)
    800030b8:	ec26                	sd	s1,24(sp)
    800030ba:	e84a                	sd	s2,16(sp)
    800030bc:	e44e                	sd	s3,8(sp)
    800030be:	1800                	addi	s0,sp,48
    800030c0:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    800030c2:	47ad                	li	a5,11
    800030c4:	02b7e363          	bltu	a5,a1,800030ea <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    800030c8:	02059793          	slli	a5,a1,0x20
    800030cc:	01e7d593          	srli	a1,a5,0x1e
    800030d0:	00b509b3          	add	s3,a0,a1
    800030d4:	0509a483          	lw	s1,80(s3)
    800030d8:	e0b5                	bnez	s1,8000313c <bmap+0x8a>
      addr = balloc(ip->dev);
    800030da:	4108                	lw	a0,0(a0)
    800030dc:	ed1ff0ef          	jal	80002fac <balloc>
    800030e0:	84aa                	mv	s1,a0
      if (addr == 0)
    800030e2:	cd29                	beqz	a0,8000313c <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    800030e4:	04a9a823          	sw	a0,80(s3)
    800030e8:	a891                	j	8000313c <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800030ea:	ff45879b          	addiw	a5,a1,-12
    800030ee:	873e                	mv	a4,a5
    800030f0:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    800030f2:	0ff00793          	li	a5,255
    800030f6:	06e7e763          	bltu	a5,a4,80003164 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    800030fa:	08052483          	lw	s1,128(a0)
    800030fe:	e891                	bnez	s1,80003112 <bmap+0x60>
      addr = balloc(ip->dev);
    80003100:	4108                	lw	a0,0(a0)
    80003102:	eabff0ef          	jal	80002fac <balloc>
    80003106:	84aa                	mv	s1,a0
      if (addr == 0)
    80003108:	c915                	beqz	a0,8000313c <bmap+0x8a>
    8000310a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000310c:	08a92023          	sw	a0,128(s2)
    80003110:	a011                	j	80003114 <bmap+0x62>
    80003112:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003114:	85a6                	mv	a1,s1
    80003116:	00092503          	lw	a0,0(s2)
    8000311a:	c33ff0ef          	jal	80002d4c <bread>
    8000311e:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80003120:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80003124:	02099713          	slli	a4,s3,0x20
    80003128:	01e75593          	srli	a1,a4,0x1e
    8000312c:	97ae                	add	a5,a5,a1
    8000312e:	89be                	mv	s3,a5
    80003130:	4384                	lw	s1,0(a5)
    80003132:	cc89                	beqz	s1,8000314c <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003134:	8552                	mv	a0,s4
    80003136:	d1fff0ef          	jal	80002e54 <brelse>
    return addr;
    8000313a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000313c:	8526                	mv	a0,s1
    8000313e:	70a2                	ld	ra,40(sp)
    80003140:	7402                	ld	s0,32(sp)
    80003142:	64e2                	ld	s1,24(sp)
    80003144:	6942                	ld	s2,16(sp)
    80003146:	69a2                	ld	s3,8(sp)
    80003148:	6145                	addi	sp,sp,48
    8000314a:	8082                	ret
      addr = balloc(ip->dev);
    8000314c:	00092503          	lw	a0,0(s2)
    80003150:	e5dff0ef          	jal	80002fac <balloc>
    80003154:	84aa                	mv	s1,a0
      if (addr) {
    80003156:	dd79                	beqz	a0,80003134 <bmap+0x82>
        a[bn] = addr;
    80003158:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    8000315c:	8552                	mv	a0,s4
    8000315e:	6ad000ef          	jal	8000400a <log_write>
    80003162:	bfc9                	j	80003134 <bmap+0x82>
    80003164:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003166:	00004517          	auipc	a0,0x4
    8000316a:	2b250513          	addi	a0,a0,690 # 80007418 <etext+0x418>
    8000316e:	ec6fd0ef          	jal	80000834 <panic>

0000000080003172 <iget>:
{
    80003172:	7179                	addi	sp,sp,-48
    80003174:	f406                	sd	ra,40(sp)
    80003176:	f022                	sd	s0,32(sp)
    80003178:	ec26                	sd	s1,24(sp)
    8000317a:	e84a                	sd	s2,16(sp)
    8000317c:	e44e                	sd	s3,8(sp)
    8000317e:	e052                	sd	s4,0(sp)
    80003180:	1800                	addi	s0,sp,48
    80003182:	892a                	mv	s2,a0
    80003184:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003186:	0001e517          	auipc	a0,0x1e
    8000318a:	a3a50513          	addi	a0,a0,-1478 # 80020bc0 <itable>
    8000318e:	a9bfd0ef          	jal	80000c28 <acquire>
  empty = 0;
    80003192:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003194:	0001e497          	auipc	s1,0x1e
    80003198:	a4448493          	addi	s1,s1,-1468 # 80020bd8 <itable+0x18>
    8000319c:	0001f697          	auipc	a3,0x1f
    800031a0:	4cc68693          	addi	a3,a3,1228 # 80022668 <log>
    800031a4:	a809                	j	800031b6 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800031a6:	e781                	bnez	a5,800031ae <iget+0x3c>
    800031a8:	00099363          	bnez	s3,800031ae <iget+0x3c>
      empty = ip;
    800031ac:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800031ae:	08848493          	addi	s1,s1,136
    800031b2:	02d48563          	beq	s1,a3,800031dc <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    800031b6:	449c                	lw	a5,8(s1)
    800031b8:	fef057e3          	blez	a5,800031a6 <iget+0x34>
    800031bc:	4098                	lw	a4,0(s1)
    800031be:	ff2718e3          	bne	a4,s2,800031ae <iget+0x3c>
    800031c2:	40d8                	lw	a4,4(s1)
    800031c4:	ff4715e3          	bne	a4,s4,800031ae <iget+0x3c>
      ip->ref++;
    800031c8:	2785                	addiw	a5,a5,1
    800031ca:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800031cc:	0001e517          	auipc	a0,0x1e
    800031d0:	9f450513          	addi	a0,a0,-1548 # 80020bc0 <itable>
    800031d4:	addfd0ef          	jal	80000cb0 <release>
      return ip;
    800031d8:	89a6                	mv	s3,s1
    800031da:	a015                	j	800031fe <iget+0x8c>
  if (empty == 0)
    800031dc:	02098a63          	beqz	s3,80003210 <iget+0x9e>
  ip->dev = dev;
    800031e0:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800031e4:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800031e8:	4785                	li	a5,1
    800031ea:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800031ee:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800031f2:	0001e517          	auipc	a0,0x1e
    800031f6:	9ce50513          	addi	a0,a0,-1586 # 80020bc0 <itable>
    800031fa:	ab7fd0ef          	jal	80000cb0 <release>
}
    800031fe:	854e                	mv	a0,s3
    80003200:	70a2                	ld	ra,40(sp)
    80003202:	7402                	ld	s0,32(sp)
    80003204:	64e2                	ld	s1,24(sp)
    80003206:	6942                	ld	s2,16(sp)
    80003208:	69a2                	ld	s3,8(sp)
    8000320a:	6a02                	ld	s4,0(sp)
    8000320c:	6145                	addi	sp,sp,48
    8000320e:	8082                	ret
    panic("iget: no inodes");
    80003210:	00004517          	auipc	a0,0x4
    80003214:	22050513          	addi	a0,a0,544 # 80007430 <etext+0x430>
    80003218:	e1cfd0ef          	jal	80000834 <panic>

000000008000321c <iinit>:
{
    8000321c:	7179                	addi	sp,sp,-48
    8000321e:	f406                	sd	ra,40(sp)
    80003220:	f022                	sd	s0,32(sp)
    80003222:	ec26                	sd	s1,24(sp)
    80003224:	e84a                	sd	s2,16(sp)
    80003226:	e44e                	sd	s3,8(sp)
    80003228:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000322a:	00004597          	auipc	a1,0x4
    8000322e:	21658593          	addi	a1,a1,534 # 80007440 <etext+0x440>
    80003232:	0001e517          	auipc	a0,0x1e
    80003236:	98e50513          	addi	a0,a0,-1650 # 80020bc0 <itable>
    8000323a:	96ffd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    8000323e:	0001e497          	auipc	s1,0x1e
    80003242:	9aa48493          	addi	s1,s1,-1622 # 80020be8 <itable+0x28>
    80003246:	0001f997          	auipc	s3,0x1f
    8000324a:	43298993          	addi	s3,s3,1074 # 80022678 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000324e:	00004917          	auipc	s2,0x4
    80003252:	1fa90913          	addi	s2,s2,506 # 80007448 <etext+0x448>
    80003256:	85ca                	mv	a1,s2
    80003258:	8526                	mv	a0,s1
    8000325a:	6e9000ef          	jal	80004142 <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    8000325e:	08848493          	addi	s1,s1,136
    80003262:	ff349ae3          	bne	s1,s3,80003256 <iinit+0x3a>
}
    80003266:	70a2                	ld	ra,40(sp)
    80003268:	7402                	ld	s0,32(sp)
    8000326a:	64e2                	ld	s1,24(sp)
    8000326c:	6942                	ld	s2,16(sp)
    8000326e:	69a2                	ld	s3,8(sp)
    80003270:	6145                	addi	sp,sp,48
    80003272:	8082                	ret

0000000080003274 <ialloc>:
{
    80003274:	7139                	addi	sp,sp,-64
    80003276:	fc06                	sd	ra,56(sp)
    80003278:	f822                	sd	s0,48(sp)
    8000327a:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000327c:	0001e717          	auipc	a4,0x1e
    80003280:	93072703          	lw	a4,-1744(a4) # 80020bac <sb+0xc>
    80003284:	4785                	li	a5,1
    80003286:	06e7f063          	bgeu	a5,a4,800032e6 <ialloc+0x72>
    8000328a:	f426                	sd	s1,40(sp)
    8000328c:	f04a                	sd	s2,32(sp)
    8000328e:	ec4e                	sd	s3,24(sp)
    80003290:	e852                	sd	s4,16(sp)
    80003292:	e456                	sd	s5,8(sp)
    80003294:	e05a                	sd	s6,0(sp)
    80003296:	8aaa                	mv	s5,a0
    80003298:	8b2e                	mv	s6,a1
    8000329a:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    8000329c:	0001ea17          	auipc	s4,0x1e
    800032a0:	904a0a13          	addi	s4,s4,-1788 # 80020ba0 <sb>
    800032a4:	00495593          	srli	a1,s2,0x4
    800032a8:	018a2783          	lw	a5,24(s4)
    800032ac:	9dbd                	addw	a1,a1,a5
    800032ae:	8556                	mv	a0,s5
    800032b0:	a9dff0ef          	jal	80002d4c <bread>
    800032b4:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    800032b6:	05850993          	addi	s3,a0,88
    800032ba:	00f97793          	andi	a5,s2,15
    800032be:	079a                	slli	a5,a5,0x6
    800032c0:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    800032c2:	00099783          	lh	a5,0(s3)
    800032c6:	cb9d                	beqz	a5,800032fc <ialloc+0x88>
    brelse(bp);
    800032c8:	b8dff0ef          	jal	80002e54 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    800032cc:	0905                	addi	s2,s2,1
    800032ce:	00ca2703          	lw	a4,12(s4)
    800032d2:	0009079b          	sext.w	a5,s2
    800032d6:	fce7e7e3          	bltu	a5,a4,800032a4 <ialloc+0x30>
    800032da:	74a2                	ld	s1,40(sp)
    800032dc:	7902                	ld	s2,32(sp)
    800032de:	69e2                	ld	s3,24(sp)
    800032e0:	6a42                	ld	s4,16(sp)
    800032e2:	6aa2                	ld	s5,8(sp)
    800032e4:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800032e6:	00004517          	auipc	a0,0x4
    800032ea:	16a50513          	addi	a0,a0,362 # 80007450 <etext+0x450>
    800032ee:	a1cfd0ef          	jal	8000050a <printk>
  return 0;
    800032f2:	4501                	li	a0,0
}
    800032f4:	70e2                	ld	ra,56(sp)
    800032f6:	7442                	ld	s0,48(sp)
    800032f8:	6121                	addi	sp,sp,64
    800032fa:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800032fc:	04000613          	li	a2,64
    80003300:	4581                	li	a1,0
    80003302:	854e                	mv	a0,s3
    80003304:	9e5fd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    80003308:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    8000330c:	8526                	mv	a0,s1
    8000330e:	4fd000ef          	jal	8000400a <log_write>
      brelse(bp);
    80003312:	8526                	mv	a0,s1
    80003314:	b41ff0ef          	jal	80002e54 <brelse>
      return iget(dev, inum);
    80003318:	0009059b          	sext.w	a1,s2
    8000331c:	8556                	mv	a0,s5
    8000331e:	e55ff0ef          	jal	80003172 <iget>
    80003322:	74a2                	ld	s1,40(sp)
    80003324:	7902                	ld	s2,32(sp)
    80003326:	69e2                	ld	s3,24(sp)
    80003328:	6a42                	ld	s4,16(sp)
    8000332a:	6aa2                	ld	s5,8(sp)
    8000332c:	6b02                	ld	s6,0(sp)
    8000332e:	b7d9                	j	800032f4 <ialloc+0x80>

0000000080003330 <iupdate>:
{
    80003330:	1101                	addi	sp,sp,-32
    80003332:	ec06                	sd	ra,24(sp)
    80003334:	e822                	sd	s0,16(sp)
    80003336:	e426                	sd	s1,8(sp)
    80003338:	e04a                	sd	s2,0(sp)
    8000333a:	1000                	addi	s0,sp,32
    8000333c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000333e:	415c                	lw	a5,4(a0)
    80003340:	0047d79b          	srliw	a5,a5,0x4
    80003344:	0001e597          	auipc	a1,0x1e
    80003348:	8745a583          	lw	a1,-1932(a1) # 80020bb8 <sb+0x18>
    8000334c:	9dbd                	addw	a1,a1,a5
    8000334e:	4108                	lw	a0,0(a0)
    80003350:	9fdff0ef          	jal	80002d4c <bread>
    80003354:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003356:	05850793          	addi	a5,a0,88
    8000335a:	40d8                	lw	a4,4(s1)
    8000335c:	8b3d                	andi	a4,a4,15
    8000335e:	071a                	slli	a4,a4,0x6
    80003360:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003362:	04449703          	lh	a4,68(s1)
    80003366:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000336a:	04649703          	lh	a4,70(s1)
    8000336e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003372:	04849703          	lh	a4,72(s1)
    80003376:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000337a:	04a49703          	lh	a4,74(s1)
    8000337e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003382:	44f8                	lw	a4,76(s1)
    80003384:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003386:	03400613          	li	a2,52
    8000338a:	05048593          	addi	a1,s1,80
    8000338e:	00c78513          	addi	a0,a5,12
    80003392:	9b7fd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    80003396:	854a                	mv	a0,s2
    80003398:	473000ef          	jal	8000400a <log_write>
  brelse(bp);
    8000339c:	854a                	mv	a0,s2
    8000339e:	ab7ff0ef          	jal	80002e54 <brelse>
}
    800033a2:	60e2                	ld	ra,24(sp)
    800033a4:	6442                	ld	s0,16(sp)
    800033a6:	64a2                	ld	s1,8(sp)
    800033a8:	6902                	ld	s2,0(sp)
    800033aa:	6105                	addi	sp,sp,32
    800033ac:	8082                	ret

00000000800033ae <idup>:
{
    800033ae:	1101                	addi	sp,sp,-32
    800033b0:	ec06                	sd	ra,24(sp)
    800033b2:	e822                	sd	s0,16(sp)
    800033b4:	e426                	sd	s1,8(sp)
    800033b6:	1000                	addi	s0,sp,32
    800033b8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033ba:	0001e517          	auipc	a0,0x1e
    800033be:	80650513          	addi	a0,a0,-2042 # 80020bc0 <itable>
    800033c2:	867fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    800033c6:	449c                	lw	a5,8(s1)
    800033c8:	2785                	addiw	a5,a5,1
    800033ca:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033cc:	0001d517          	auipc	a0,0x1d
    800033d0:	7f450513          	addi	a0,a0,2036 # 80020bc0 <itable>
    800033d4:	8ddfd0ef          	jal	80000cb0 <release>
}
    800033d8:	8526                	mv	a0,s1
    800033da:	60e2                	ld	ra,24(sp)
    800033dc:	6442                	ld	s0,16(sp)
    800033de:	64a2                	ld	s1,8(sp)
    800033e0:	6105                	addi	sp,sp,32
    800033e2:	8082                	ret

00000000800033e4 <ilock>:
{
    800033e4:	1101                	addi	sp,sp,-32
    800033e6:	ec06                	sd	ra,24(sp)
    800033e8:	e822                	sd	s0,16(sp)
    800033ea:	e426                	sd	s1,8(sp)
    800033ec:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800033ee:	cd19                	beqz	a0,8000340c <ilock+0x28>
    800033f0:	84aa                	mv	s1,a0
    800033f2:	451c                	lw	a5,8(a0)
    800033f4:	00f05c63          	blez	a5,8000340c <ilock+0x28>
  acquiresleep(&ip->lock);
    800033f8:	0541                	addi	a0,a0,16
    800033fa:	57f000ef          	jal	80004178 <acquiresleep>
  if (ip->valid == 0) {
    800033fe:	40bc                	lw	a5,64(s1)
    80003400:	cf89                	beqz	a5,8000341a <ilock+0x36>
}
    80003402:	60e2                	ld	ra,24(sp)
    80003404:	6442                	ld	s0,16(sp)
    80003406:	64a2                	ld	s1,8(sp)
    80003408:	6105                	addi	sp,sp,32
    8000340a:	8082                	ret
    8000340c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000340e:	00004517          	auipc	a0,0x4
    80003412:	05a50513          	addi	a0,a0,90 # 80007468 <etext+0x468>
    80003416:	c1efd0ef          	jal	80000834 <panic>
    8000341a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000341c:	40dc                	lw	a5,4(s1)
    8000341e:	0047d79b          	srliw	a5,a5,0x4
    80003422:	0001d597          	auipc	a1,0x1d
    80003426:	7965a583          	lw	a1,1942(a1) # 80020bb8 <sb+0x18>
    8000342a:	9dbd                	addw	a1,a1,a5
    8000342c:	4088                	lw	a0,0(s1)
    8000342e:	91fff0ef          	jal	80002d4c <bread>
    80003432:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003434:	05850593          	addi	a1,a0,88
    80003438:	40dc                	lw	a5,4(s1)
    8000343a:	8bbd                	andi	a5,a5,15
    8000343c:	079a                	slli	a5,a5,0x6
    8000343e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003440:	00059783          	lh	a5,0(a1)
    80003444:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003448:	00259783          	lh	a5,2(a1)
    8000344c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003450:	00459783          	lh	a5,4(a1)
    80003454:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003458:	00659783          	lh	a5,6(a1)
    8000345c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003460:	459c                	lw	a5,8(a1)
    80003462:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003464:	03400613          	li	a2,52
    80003468:	05b1                	addi	a1,a1,12
    8000346a:	05048513          	addi	a0,s1,80
    8000346e:	8dbfd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    80003472:	854a                	mv	a0,s2
    80003474:	9e1ff0ef          	jal	80002e54 <brelse>
    ip->valid = 1;
    80003478:	4785                	li	a5,1
    8000347a:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    8000347c:	04449783          	lh	a5,68(s1)
    80003480:	c399                	beqz	a5,80003486 <ilock+0xa2>
    80003482:	6902                	ld	s2,0(sp)
    80003484:	bfbd                	j	80003402 <ilock+0x1e>
      panic("ilock: no type");
    80003486:	00004517          	auipc	a0,0x4
    8000348a:	fea50513          	addi	a0,a0,-22 # 80007470 <etext+0x470>
    8000348e:	ba6fd0ef          	jal	80000834 <panic>

0000000080003492 <iunlock>:
{
    80003492:	1101                	addi	sp,sp,-32
    80003494:	ec06                	sd	ra,24(sp)
    80003496:	e822                	sd	s0,16(sp)
    80003498:	e426                	sd	s1,8(sp)
    8000349a:	e04a                	sd	s2,0(sp)
    8000349c:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000349e:	c505                	beqz	a0,800034c6 <iunlock+0x34>
    800034a0:	84aa                	mv	s1,a0
    800034a2:	01050913          	addi	s2,a0,16
    800034a6:	854a                	mv	a0,s2
    800034a8:	55d000ef          	jal	80004204 <holdingsleep>
    800034ac:	cd09                	beqz	a0,800034c6 <iunlock+0x34>
    800034ae:	449c                	lw	a5,8(s1)
    800034b0:	00f05b63          	blez	a5,800034c6 <iunlock+0x34>
  releasesleep(&ip->lock);
    800034b4:	854a                	mv	a0,s2
    800034b6:	517000ef          	jal	800041cc <releasesleep>
}
    800034ba:	60e2                	ld	ra,24(sp)
    800034bc:	6442                	ld	s0,16(sp)
    800034be:	64a2                	ld	s1,8(sp)
    800034c0:	6902                	ld	s2,0(sp)
    800034c2:	6105                	addi	sp,sp,32
    800034c4:	8082                	ret
    panic("iunlock");
    800034c6:	00004517          	auipc	a0,0x4
    800034ca:	fba50513          	addi	a0,a0,-70 # 80007480 <etext+0x480>
    800034ce:	b66fd0ef          	jal	80000834 <panic>

00000000800034d2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800034d2:	7179                	addi	sp,sp,-48
    800034d4:	f406                	sd	ra,40(sp)
    800034d6:	f022                	sd	s0,32(sp)
    800034d8:	ec26                	sd	s1,24(sp)
    800034da:	e84a                	sd	s2,16(sp)
    800034dc:	e44e                	sd	s3,8(sp)
    800034de:	1800                	addi	s0,sp,48
    800034e0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800034e2:	05050493          	addi	s1,a0,80
    800034e6:	08050913          	addi	s2,a0,128
    800034ea:	a021                	j	800034f2 <itrunc+0x20>
    800034ec:	0491                	addi	s1,s1,4
    800034ee:	01248b63          	beq	s1,s2,80003504 <itrunc+0x32>
    if (ip->addrs[i]) {
    800034f2:	408c                	lw	a1,0(s1)
    800034f4:	dde5                	beqz	a1,800034ec <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800034f6:	0009a503          	lw	a0,0(s3)
    800034fa:	a47ff0ef          	jal	80002f40 <bfree>
      ip->addrs[i] = 0;
    800034fe:	0004a023          	sw	zero,0(s1)
    80003502:	b7ed                	j	800034ec <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    80003504:	0809a583          	lw	a1,128(s3)
    80003508:	ed89                	bnez	a1,80003522 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000350a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000350e:	854e                	mv	a0,s3
    80003510:	e21ff0ef          	jal	80003330 <iupdate>
}
    80003514:	70a2                	ld	ra,40(sp)
    80003516:	7402                	ld	s0,32(sp)
    80003518:	64e2                	ld	s1,24(sp)
    8000351a:	6942                	ld	s2,16(sp)
    8000351c:	69a2                	ld	s3,8(sp)
    8000351e:	6145                	addi	sp,sp,48
    80003520:	8082                	ret
    80003522:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003524:	0009a503          	lw	a0,0(s3)
    80003528:	825ff0ef          	jal	80002d4c <bread>
    8000352c:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    8000352e:	05850493          	addi	s1,a0,88
    80003532:	45850913          	addi	s2,a0,1112
    80003536:	a021                	j	8000353e <itrunc+0x6c>
    80003538:	0491                	addi	s1,s1,4
    8000353a:	01248963          	beq	s1,s2,8000354c <itrunc+0x7a>
      if (a[j])
    8000353e:	408c                	lw	a1,0(s1)
    80003540:	dde5                	beqz	a1,80003538 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003542:	0009a503          	lw	a0,0(s3)
    80003546:	9fbff0ef          	jal	80002f40 <bfree>
    8000354a:	b7fd                	j	80003538 <itrunc+0x66>
    brelse(bp);
    8000354c:	8552                	mv	a0,s4
    8000354e:	907ff0ef          	jal	80002e54 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003552:	0809a583          	lw	a1,128(s3)
    80003556:	0009a503          	lw	a0,0(s3)
    8000355a:	9e7ff0ef          	jal	80002f40 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000355e:	0809a023          	sw	zero,128(s3)
    80003562:	6a02                	ld	s4,0(sp)
    80003564:	b75d                	j	8000350a <itrunc+0x38>

0000000080003566 <iput>:
{
    80003566:	7179                	addi	sp,sp,-48
    80003568:	f406                	sd	ra,40(sp)
    8000356a:	f022                	sd	s0,32(sp)
    8000356c:	ec26                	sd	s1,24(sp)
    8000356e:	1800                	addi	s0,sp,48
    80003570:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003572:	0001d517          	auipc	a0,0x1d
    80003576:	64e50513          	addi	a0,a0,1614 # 80020bc0 <itable>
    8000357a:	eaefd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    8000357e:	449c                	lw	a5,8(s1)
    80003580:	4705                	li	a4,1
    80003582:	00e78f63          	beq	a5,a4,800035a0 <iput+0x3a>
  ip->ref--;
    80003586:	37fd                	addiw	a5,a5,-1
    80003588:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000358a:	0001d517          	auipc	a0,0x1d
    8000358e:	63650513          	addi	a0,a0,1590 # 80020bc0 <itable>
    80003592:	f1efd0ef          	jal	80000cb0 <release>
}
    80003596:	70a2                	ld	ra,40(sp)
    80003598:	7402                	ld	s0,32(sp)
    8000359a:	64e2                	ld	s1,24(sp)
    8000359c:	6145                	addi	sp,sp,48
    8000359e:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800035a0:	40b8                	lw	a4,64(s1)
    800035a2:	d375                	beqz	a4,80003586 <iput+0x20>
    800035a4:	e84a                	sd	s2,16(sp)
    800035a6:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    800035a8:	0004aa03          	lw	s4,0(s1)
    800035ac:	0044a903          	lw	s2,4(s1)
  if (last) {
    800035b0:	04a49703          	lh	a4,74(s1)
    800035b4:	ef3d                	bnez	a4,80003632 <iput+0xcc>
    800035b6:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    800035b8:	01048793          	addi	a5,s1,16
    800035bc:	89be                	mv	s3,a5
    800035be:	853e                	mv	a0,a5
    800035c0:	3b9000ef          	jal	80004178 <acquiresleep>
    release(&itable.lock);
    800035c4:	0001d517          	auipc	a0,0x1d
    800035c8:	5fc50513          	addi	a0,a0,1532 # 80020bc0 <itable>
    800035cc:	ee4fd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    800035d0:	8526                	mv	a0,s1
    800035d2:	f01ff0ef          	jal	800034d2 <itrunc>
    ip->valid = 0;
    800035d6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800035da:	854e                	mv	a0,s3
    800035dc:	3f1000ef          	jal	800041cc <releasesleep>
    acquire(&itable.lock);
    800035e0:	0001d517          	auipc	a0,0x1d
    800035e4:	5e050513          	addi	a0,a0,1504 # 80020bc0 <itable>
    800035e8:	e40fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    800035ec:	449c                	lw	a5,8(s1)
    800035ee:	37fd                	addiw	a5,a5,-1
    800035f0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035f2:	0001d517          	auipc	a0,0x1d
    800035f6:	5ce50513          	addi	a0,a0,1486 # 80020bc0 <itable>
    800035fa:	eb6fd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035fe:	0049579b          	srliw	a5,s2,0x4
    80003602:	0001d597          	auipc	a1,0x1d
    80003606:	5b65a583          	lw	a1,1462(a1) # 80020bb8 <sb+0x18>
    8000360a:	9dbd                	addw	a1,a1,a5
    8000360c:	8552                	mv	a0,s4
    8000360e:	f3eff0ef          	jal	80002d4c <bread>
    80003612:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003614:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    80003618:	079a                	slli	a5,a5,0x6
    8000361a:	97aa                	add	a5,a5,a0
    8000361c:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    80003620:	1eb000ef          	jal	8000400a <log_write>
  brelse(bp);
    80003624:	8526                	mv	a0,s1
    80003626:	82fff0ef          	jal	80002e54 <brelse>
}
    8000362a:	6942                	ld	s2,16(sp)
    8000362c:	69a2                	ld	s3,8(sp)
    8000362e:	6a02                	ld	s4,0(sp)
    80003630:	b79d                	j	80003596 <iput+0x30>
    80003632:	6942                	ld	s2,16(sp)
    80003634:	6a02                	ld	s4,0(sp)
    80003636:	bf81                	j	80003586 <iput+0x20>

0000000080003638 <iunlockput>:
{
    80003638:	1101                	addi	sp,sp,-32
    8000363a:	ec06                	sd	ra,24(sp)
    8000363c:	e822                	sd	s0,16(sp)
    8000363e:	e426                	sd	s1,8(sp)
    80003640:	1000                	addi	s0,sp,32
    80003642:	84aa                	mv	s1,a0
  iunlock(ip);
    80003644:	e4fff0ef          	jal	80003492 <iunlock>
  iput(ip);
    80003648:	8526                	mv	a0,s1
    8000364a:	f1dff0ef          	jal	80003566 <iput>
}
    8000364e:	60e2                	ld	ra,24(sp)
    80003650:	6442                	ld	s0,16(sp)
    80003652:	64a2                	ld	s1,8(sp)
    80003654:	6105                	addi	sp,sp,32
    80003656:	8082                	ret

0000000080003658 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003658:	0001d717          	auipc	a4,0x1d
    8000365c:	55472703          	lw	a4,1364(a4) # 80020bac <sb+0xc>
    80003660:	4785                	li	a5,1
    80003662:	0ae7fe63          	bgeu	a5,a4,8000371e <ireclaim+0xc6>
{
    80003666:	7139                	addi	sp,sp,-64
    80003668:	fc06                	sd	ra,56(sp)
    8000366a:	f822                	sd	s0,48(sp)
    8000366c:	f426                	sd	s1,40(sp)
    8000366e:	f04a                	sd	s2,32(sp)
    80003670:	ec4e                	sd	s3,24(sp)
    80003672:	e852                	sd	s4,16(sp)
    80003674:	e456                	sd	s5,8(sp)
    80003676:	e05a                	sd	s6,0(sp)
    80003678:	0080                	addi	s0,sp,64
    8000367a:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000367c:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000367e:	0001da17          	auipc	s4,0x1d
    80003682:	522a0a13          	addi	s4,s4,1314 # 80020ba0 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    80003686:	00004b17          	auipc	s6,0x4
    8000368a:	e02b0b13          	addi	s6,s6,-510 # 80007488 <etext+0x488>
    8000368e:	a099                	j	800036d4 <ireclaim+0x7c>
    80003690:	85ce                	mv	a1,s3
    80003692:	855a                	mv	a0,s6
    80003694:	e77fc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    80003698:	85ce                	mv	a1,s3
    8000369a:	8556                	mv	a0,s5
    8000369c:	ad7ff0ef          	jal	80003172 <iget>
    800036a0:	89aa                	mv	s3,a0
    brelse(bp);
    800036a2:	854a                	mv	a0,s2
    800036a4:	fb0ff0ef          	jal	80002e54 <brelse>
    if (ip) {
    800036a8:	00098f63          	beqz	s3,800036c6 <ireclaim+0x6e>
      begin_op();
    800036ac:	7b0000ef          	jal	80003e5c <begin_op>
      ilock(ip);
    800036b0:	854e                	mv	a0,s3
    800036b2:	d33ff0ef          	jal	800033e4 <ilock>
      iunlock(ip);
    800036b6:	854e                	mv	a0,s3
    800036b8:	ddbff0ef          	jal	80003492 <iunlock>
      iput(ip);
    800036bc:	854e                	mv	a0,s3
    800036be:	ea9ff0ef          	jal	80003566 <iput>
      end_op();
    800036c2:	027000ef          	jal	80003ee8 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036c6:	0485                	addi	s1,s1,1
    800036c8:	00ca2703          	lw	a4,12(s4)
    800036cc:	0004879b          	sext.w	a5,s1
    800036d0:	02e7fd63          	bgeu	a5,a4,8000370a <ireclaim+0xb2>
    800036d4:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036d8:	0044d593          	srli	a1,s1,0x4
    800036dc:	018a2783          	lw	a5,24(s4)
    800036e0:	9dbd                	addw	a1,a1,a5
    800036e2:	8556                	mv	a0,s5
    800036e4:	e68ff0ef          	jal	80002d4c <bread>
    800036e8:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800036ea:	05850793          	addi	a5,a0,88
    800036ee:	00f9f713          	andi	a4,s3,15
    800036f2:	071a                	slli	a4,a4,0x6
    800036f4:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    800036f6:	00079703          	lh	a4,0(a5)
    800036fa:	c701                	beqz	a4,80003702 <ireclaim+0xaa>
    800036fc:	00679783          	lh	a5,6(a5)
    80003700:	dbc1                	beqz	a5,80003690 <ireclaim+0x38>
    brelse(bp);
    80003702:	854a                	mv	a0,s2
    80003704:	f50ff0ef          	jal	80002e54 <brelse>
    if (ip) {
    80003708:	bf7d                	j	800036c6 <ireclaim+0x6e>
}
    8000370a:	70e2                	ld	ra,56(sp)
    8000370c:	7442                	ld	s0,48(sp)
    8000370e:	74a2                	ld	s1,40(sp)
    80003710:	7902                	ld	s2,32(sp)
    80003712:	69e2                	ld	s3,24(sp)
    80003714:	6a42                	ld	s4,16(sp)
    80003716:	6aa2                	ld	s5,8(sp)
    80003718:	6b02                	ld	s6,0(sp)
    8000371a:	6121                	addi	sp,sp,64
    8000371c:	8082                	ret
    8000371e:	8082                	ret

0000000080003720 <fsinit>:
{
    80003720:	1101                	addi	sp,sp,-32
    80003722:	ec06                	sd	ra,24(sp)
    80003724:	e822                	sd	s0,16(sp)
    80003726:	e426                	sd	s1,8(sp)
    80003728:	e04a                	sd	s2,0(sp)
    8000372a:	1000                	addi	s0,sp,32
    8000372c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000372e:	4585                	li	a1,1
    80003730:	e1cff0ef          	jal	80002d4c <bread>
    80003734:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003736:	02000613          	li	a2,32
    8000373a:	05850593          	addi	a1,a0,88
    8000373e:	0001d517          	auipc	a0,0x1d
    80003742:	46250513          	addi	a0,a0,1122 # 80020ba0 <sb>
    80003746:	e02fd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    8000374a:	8526                	mv	a0,s1
    8000374c:	f08ff0ef          	jal	80002e54 <brelse>
  if (sb.magic != FSMAGIC)
    80003750:	0001d717          	auipc	a4,0x1d
    80003754:	45072703          	lw	a4,1104(a4) # 80020ba0 <sb>
    80003758:	102037b7          	lui	a5,0x10203
    8000375c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003760:	02f71263          	bne	a4,a5,80003784 <fsinit+0x64>
  initlog(dev, &sb);
    80003764:	0001d597          	auipc	a1,0x1d
    80003768:	43c58593          	addi	a1,a1,1084 # 80020ba0 <sb>
    8000376c:	854a                	mv	a0,s2
    8000376e:	66c000ef          	jal	80003dda <initlog>
  ireclaim(dev);
    80003772:	854a                	mv	a0,s2
    80003774:	ee5ff0ef          	jal	80003658 <ireclaim>
}
    80003778:	60e2                	ld	ra,24(sp)
    8000377a:	6442                	ld	s0,16(sp)
    8000377c:	64a2                	ld	s1,8(sp)
    8000377e:	6902                	ld	s2,0(sp)
    80003780:	6105                	addi	sp,sp,32
    80003782:	8082                	ret
    panic("invalid file system");
    80003784:	00004517          	auipc	a0,0x4
    80003788:	d2450513          	addi	a0,a0,-732 # 800074a8 <etext+0x4a8>
    8000378c:	8a8fd0ef          	jal	80000834 <panic>

0000000080003790 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003790:	1141                	addi	sp,sp,-16
    80003792:	e406                	sd	ra,8(sp)
    80003794:	e022                	sd	s0,0(sp)
    80003796:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003798:	411c                	lw	a5,0(a0)
    8000379a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000379c:	415c                	lw	a5,4(a0)
    8000379e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800037a0:	04451783          	lh	a5,68(a0)
    800037a4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800037a8:	04a51783          	lh	a5,74(a0)
    800037ac:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800037b0:	04c56783          	lwu	a5,76(a0)
    800037b4:	e99c                	sd	a5,16(a1)
}
    800037b6:	60a2                	ld	ra,8(sp)
    800037b8:	6402                	ld	s0,0(sp)
    800037ba:	0141                	addi	sp,sp,16
    800037bc:	8082                	ret

00000000800037be <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800037be:	457c                	lw	a5,76(a0)
    800037c0:	0ed7e663          	bltu	a5,a3,800038ac <readi+0xee>
{
    800037c4:	7159                	addi	sp,sp,-112
    800037c6:	f486                	sd	ra,104(sp)
    800037c8:	f0a2                	sd	s0,96(sp)
    800037ca:	eca6                	sd	s1,88(sp)
    800037cc:	e0d2                	sd	s4,64(sp)
    800037ce:	fc56                	sd	s5,56(sp)
    800037d0:	f85a                	sd	s6,48(sp)
    800037d2:	f45e                	sd	s7,40(sp)
    800037d4:	1880                	addi	s0,sp,112
    800037d6:	8b2a                	mv	s6,a0
    800037d8:	8bae                	mv	s7,a1
    800037da:	8a32                	mv	s4,a2
    800037dc:	84b6                	mv	s1,a3
    800037de:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800037e0:	9f35                	addw	a4,a4,a3
    return 0;
    800037e2:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800037e4:	0ad76b63          	bltu	a4,a3,8000389a <readi+0xdc>
    800037e8:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    800037ea:	00e7f463          	bgeu	a5,a4,800037f2 <readi+0x34>
    n = ip->size - off;
    800037ee:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800037f2:	080a8b63          	beqz	s5,80003888 <readi+0xca>
    800037f6:	e8ca                	sd	s2,80(sp)
    800037f8:	f062                	sd	s8,32(sp)
    800037fa:	ec66                	sd	s9,24(sp)
    800037fc:	e86a                	sd	s10,16(sp)
    800037fe:	e46e                	sd	s11,8(sp)
    80003800:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003802:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003806:	5c7d                	li	s8,-1
    80003808:	a80d                	j	8000383a <readi+0x7c>
    8000380a:	020d1d93          	slli	s11,s10,0x20
    8000380e:	020ddd93          	srli	s11,s11,0x20
    80003812:	05890613          	addi	a2,s2,88
    80003816:	86ee                	mv	a3,s11
    80003818:	963e                	add	a2,a2,a5
    8000381a:	85d2                	mv	a1,s4
    8000381c:	855e                	mv	a0,s7
    8000381e:	c13fe0ef          	jal	80002430 <either_copyout>
    80003822:	05850363          	beq	a0,s8,80003868 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003826:	854a                	mv	a0,s2
    80003828:	e2cff0ef          	jal	80002e54 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000382c:	013d09bb          	addw	s3,s10,s3
    80003830:	009d04bb          	addw	s1,s10,s1
    80003834:	9a6e                	add	s4,s4,s11
    80003836:	0559f363          	bgeu	s3,s5,8000387c <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    8000383a:	00a4d59b          	srliw	a1,s1,0xa
    8000383e:	855a                	mv	a0,s6
    80003840:	873ff0ef          	jal	800030b2 <bmap>
    80003844:	85aa                	mv	a1,a0
    if (addr == 0)
    80003846:	c139                	beqz	a0,8000388c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003848:	000b2503          	lw	a0,0(s6)
    8000384c:	d00ff0ef          	jal	80002d4c <bread>
    80003850:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003852:	3ff4f793          	andi	a5,s1,1023
    80003856:	40fc873b          	subw	a4,s9,a5
    8000385a:	413a86bb          	subw	a3,s5,s3
    8000385e:	8d3a                	mv	s10,a4
    80003860:	fae6f5e3          	bgeu	a3,a4,8000380a <readi+0x4c>
    80003864:	8d36                	mv	s10,a3
    80003866:	b755                	j	8000380a <readi+0x4c>
      brelse(bp);
    80003868:	854a                	mv	a0,s2
    8000386a:	deaff0ef          	jal	80002e54 <brelse>
      tot = -1;
    8000386e:	59fd                	li	s3,-1
      break;
    80003870:	6946                	ld	s2,80(sp)
    80003872:	7c02                	ld	s8,32(sp)
    80003874:	6ce2                	ld	s9,24(sp)
    80003876:	6d42                	ld	s10,16(sp)
    80003878:	6da2                	ld	s11,8(sp)
    8000387a:	a831                	j	80003896 <readi+0xd8>
    8000387c:	6946                	ld	s2,80(sp)
    8000387e:	7c02                	ld	s8,32(sp)
    80003880:	6ce2                	ld	s9,24(sp)
    80003882:	6d42                	ld	s10,16(sp)
    80003884:	6da2                	ld	s11,8(sp)
    80003886:	a801                	j	80003896 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003888:	89d6                	mv	s3,s5
    8000388a:	a031                	j	80003896 <readi+0xd8>
    8000388c:	6946                	ld	s2,80(sp)
    8000388e:	7c02                	ld	s8,32(sp)
    80003890:	6ce2                	ld	s9,24(sp)
    80003892:	6d42                	ld	s10,16(sp)
    80003894:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003896:	854e                	mv	a0,s3
    80003898:	69a6                	ld	s3,72(sp)
}
    8000389a:	70a6                	ld	ra,104(sp)
    8000389c:	7406                	ld	s0,96(sp)
    8000389e:	64e6                	ld	s1,88(sp)
    800038a0:	6a06                	ld	s4,64(sp)
    800038a2:	7ae2                	ld	s5,56(sp)
    800038a4:	7b42                	ld	s6,48(sp)
    800038a6:	7ba2                	ld	s7,40(sp)
    800038a8:	6165                	addi	sp,sp,112
    800038aa:	8082                	ret
    return 0;
    800038ac:	4501                	li	a0,0
}
    800038ae:	8082                	ret

00000000800038b0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800038b0:	457c                	lw	a5,76(a0)
    800038b2:	0ed7ee63          	bltu	a5,a3,800039ae <writei+0xfe>
{
    800038b6:	7159                	addi	sp,sp,-112
    800038b8:	f486                	sd	ra,104(sp)
    800038ba:	f0a2                	sd	s0,96(sp)
    800038bc:	e8ca                	sd	s2,80(sp)
    800038be:	e0d2                	sd	s4,64(sp)
    800038c0:	fc56                	sd	s5,56(sp)
    800038c2:	f85a                	sd	s6,48(sp)
    800038c4:	f45e                	sd	s7,40(sp)
    800038c6:	1880                	addi	s0,sp,112
    800038c8:	8aaa                	mv	s5,a0
    800038ca:	8bae                	mv	s7,a1
    800038cc:	8a32                	mv	s4,a2
    800038ce:	8936                	mv	s2,a3
    800038d0:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    800038d2:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    800038d6:	00043737          	lui	a4,0x43
    800038da:	0cf76c63          	bltu	a4,a5,800039b2 <writei+0x102>
    800038de:	0cd7ea63          	bltu	a5,a3,800039b2 <writei+0x102>
    800038e2:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800038e4:	0a0b0d63          	beqz	s6,8000399e <writei+0xee>
    800038e8:	eca6                	sd	s1,88(sp)
    800038ea:	f062                	sd	s8,32(sp)
    800038ec:	ec66                	sd	s9,24(sp)
    800038ee:	e86a                	sd	s10,16(sp)
    800038f0:	e46e                	sd	s11,8(sp)
    800038f2:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800038f4:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800038f8:	5c7d                	li	s8,-1
    800038fa:	a825                	j	80003932 <writei+0x82>
    800038fc:	020d1d93          	slli	s11,s10,0x20
    80003900:	020ddd93          	srli	s11,s11,0x20
    80003904:	05848513          	addi	a0,s1,88
    80003908:	86ee                	mv	a3,s11
    8000390a:	8652                	mv	a2,s4
    8000390c:	85de                	mv	a1,s7
    8000390e:	953e                	add	a0,a0,a5
    80003910:	b6dfe0ef          	jal	8000247c <either_copyin>
    80003914:	05850663          	beq	a0,s8,80003960 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003918:	8526                	mv	a0,s1
    8000391a:	6f0000ef          	jal	8000400a <log_write>
    brelse(bp);
    8000391e:	8526                	mv	a0,s1
    80003920:	d34ff0ef          	jal	80002e54 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003924:	013d09bb          	addw	s3,s10,s3
    80003928:	012d093b          	addw	s2,s10,s2
    8000392c:	9a6e                	add	s4,s4,s11
    8000392e:	0369ff63          	bgeu	s3,s6,8000396c <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    80003932:	00a9559b          	srliw	a1,s2,0xa
    80003936:	8556                	mv	a0,s5
    80003938:	f7aff0ef          	jal	800030b2 <bmap>
    8000393c:	85aa                	mv	a1,a0
    if (addr == 0)
    8000393e:	c51d                	beqz	a0,8000396c <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003940:	000aa503          	lw	a0,0(s5)
    80003944:	c08ff0ef          	jal	80002d4c <bread>
    80003948:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000394a:	3ff97793          	andi	a5,s2,1023
    8000394e:	40fc873b          	subw	a4,s9,a5
    80003952:	413b06bb          	subw	a3,s6,s3
    80003956:	8d3a                	mv	s10,a4
    80003958:	fae6f2e3          	bgeu	a3,a4,800038fc <writei+0x4c>
    8000395c:	8d36                	mv	s10,a3
    8000395e:	bf79                	j	800038fc <writei+0x4c>
      log_write(bp);
    80003960:	8526                	mv	a0,s1
    80003962:	6a8000ef          	jal	8000400a <log_write>
      brelse(bp);
    80003966:	8526                	mv	a0,s1
    80003968:	cecff0ef          	jal	80002e54 <brelse>
  }

  if (off > ip->size)
    8000396c:	04caa783          	lw	a5,76(s5)
    80003970:	0327f963          	bgeu	a5,s2,800039a2 <writei+0xf2>
    ip->size = off;
    80003974:	052aa623          	sw	s2,76(s5)
    80003978:	64e6                	ld	s1,88(sp)
    8000397a:	7c02                	ld	s8,32(sp)
    8000397c:	6ce2                	ld	s9,24(sp)
    8000397e:	6d42                	ld	s10,16(sp)
    80003980:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003982:	8556                	mv	a0,s5
    80003984:	9adff0ef          	jal	80003330 <iupdate>

  return tot;
    80003988:	854e                	mv	a0,s3
    8000398a:	69a6                	ld	s3,72(sp)
}
    8000398c:	70a6                	ld	ra,104(sp)
    8000398e:	7406                	ld	s0,96(sp)
    80003990:	6946                	ld	s2,80(sp)
    80003992:	6a06                	ld	s4,64(sp)
    80003994:	7ae2                	ld	s5,56(sp)
    80003996:	7b42                	ld	s6,48(sp)
    80003998:	7ba2                	ld	s7,40(sp)
    8000399a:	6165                	addi	sp,sp,112
    8000399c:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000399e:	89da                	mv	s3,s6
    800039a0:	b7cd                	j	80003982 <writei+0xd2>
    800039a2:	64e6                	ld	s1,88(sp)
    800039a4:	7c02                	ld	s8,32(sp)
    800039a6:	6ce2                	ld	s9,24(sp)
    800039a8:	6d42                	ld	s10,16(sp)
    800039aa:	6da2                	ld	s11,8(sp)
    800039ac:	bfd9                	j	80003982 <writei+0xd2>
    return -1;
    800039ae:	557d                	li	a0,-1
}
    800039b0:	8082                	ret
    return -1;
    800039b2:	557d                	li	a0,-1
    800039b4:	bfe1                	j	8000398c <writei+0xdc>

00000000800039b6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800039b6:	1141                	addi	sp,sp,-16
    800039b8:	e406                	sd	ra,8(sp)
    800039ba:	e022                	sd	s0,0(sp)
    800039bc:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800039be:	4639                	li	a2,14
    800039c0:	bfcfd0ef          	jal	80000dbc <strncmp>
}
    800039c4:	60a2                	ld	ra,8(sp)
    800039c6:	6402                	ld	s0,0(sp)
    800039c8:	0141                	addi	sp,sp,16
    800039ca:	8082                	ret

00000000800039cc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800039cc:	711d                	addi	sp,sp,-96
    800039ce:	ec86                	sd	ra,88(sp)
    800039d0:	e8a2                	sd	s0,80(sp)
    800039d2:	e4a6                	sd	s1,72(sp)
    800039d4:	e0ca                	sd	s2,64(sp)
    800039d6:	fc4e                	sd	s3,56(sp)
    800039d8:	f852                	sd	s4,48(sp)
    800039da:	f456                	sd	s5,40(sp)
    800039dc:	f05a                	sd	s6,32(sp)
    800039de:	ec5e                	sd	s7,24(sp)
    800039e0:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    800039e2:	04451703          	lh	a4,68(a0)
    800039e6:	4785                	li	a5,1
    800039e8:	00f71f63          	bne	a4,a5,80003a06 <dirlookup+0x3a>
    800039ec:	892a                	mv	s2,a0
    800039ee:	8aae                	mv	s5,a1
    800039f0:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039f2:	457c                	lw	a5,76(a0)
    800039f4:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039f6:	fa040a13          	addi	s4,s0,-96
    800039fa:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    800039fc:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a00:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a02:	e39d                	bnez	a5,80003a28 <dirlookup+0x5c>
    80003a04:	a8b9                	j	80003a62 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003a06:	00004517          	auipc	a0,0x4
    80003a0a:	aba50513          	addi	a0,a0,-1350 # 800074c0 <etext+0x4c0>
    80003a0e:	e27fc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    80003a12:	00004517          	auipc	a0,0x4
    80003a16:	ac650513          	addi	a0,a0,-1338 # 800074d8 <etext+0x4d8>
    80003a1a:	e1bfc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a1e:	24c1                	addiw	s1,s1,16
    80003a20:	04c92783          	lw	a5,76(s2)
    80003a24:	02f4fe63          	bgeu	s1,a5,80003a60 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a28:	874e                	mv	a4,s3
    80003a2a:	86a6                	mv	a3,s1
    80003a2c:	8652                	mv	a2,s4
    80003a2e:	4581                	li	a1,0
    80003a30:	854a                	mv	a0,s2
    80003a32:	d8dff0ef          	jal	800037be <readi>
    80003a36:	fd351ee3          	bne	a0,s3,80003a12 <dirlookup+0x46>
    if (de.inum == 0)
    80003a3a:	fa045783          	lhu	a5,-96(s0)
    80003a3e:	d3e5                	beqz	a5,80003a1e <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003a40:	85da                	mv	a1,s6
    80003a42:	8556                	mv	a0,s5
    80003a44:	f73ff0ef          	jal	800039b6 <namecmp>
    80003a48:	f979                	bnez	a0,80003a1e <dirlookup+0x52>
      if (poff)
    80003a4a:	000b8463          	beqz	s7,80003a52 <dirlookup+0x86>
        *poff = off;
    80003a4e:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003a52:	fa045583          	lhu	a1,-96(s0)
    80003a56:	00092503          	lw	a0,0(s2)
    80003a5a:	f18ff0ef          	jal	80003172 <iget>
    80003a5e:	a011                	j	80003a62 <dirlookup+0x96>
  return 0;
    80003a60:	4501                	li	a0,0
}
    80003a62:	60e6                	ld	ra,88(sp)
    80003a64:	6446                	ld	s0,80(sp)
    80003a66:	64a6                	ld	s1,72(sp)
    80003a68:	6906                	ld	s2,64(sp)
    80003a6a:	79e2                	ld	s3,56(sp)
    80003a6c:	7a42                	ld	s4,48(sp)
    80003a6e:	7aa2                	ld	s5,40(sp)
    80003a70:	7b02                	ld	s6,32(sp)
    80003a72:	6be2                	ld	s7,24(sp)
    80003a74:	6125                	addi	sp,sp,96
    80003a76:	8082                	ret

0000000080003a78 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003a78:	711d                	addi	sp,sp,-96
    80003a7a:	ec86                	sd	ra,88(sp)
    80003a7c:	e8a2                	sd	s0,80(sp)
    80003a7e:	e4a6                	sd	s1,72(sp)
    80003a80:	e0ca                	sd	s2,64(sp)
    80003a82:	fc4e                	sd	s3,56(sp)
    80003a84:	f852                	sd	s4,48(sp)
    80003a86:	f456                	sd	s5,40(sp)
    80003a88:	f05a                	sd	s6,32(sp)
    80003a8a:	ec5e                	sd	s7,24(sp)
    80003a8c:	e862                	sd	s8,16(sp)
    80003a8e:	e466                	sd	s9,8(sp)
    80003a90:	e06a                	sd	s10,0(sp)
    80003a92:	1080                	addi	s0,sp,96
    80003a94:	84aa                	mv	s1,a0
    80003a96:	8b2e                	mv	s6,a1
    80003a98:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003a9a:	00054703          	lbu	a4,0(a0)
    80003a9e:	02f00793          	li	a5,47
    80003aa2:	00f70f63          	beq	a4,a5,80003ac0 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003aa6:	ea3fd0ef          	jal	80001948 <myproc>
    80003aaa:	15053503          	ld	a0,336(a0)
    80003aae:	901ff0ef          	jal	800033ae <idup>
    80003ab2:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003ab4:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003ab8:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003aba:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003abc:	4b85                	li	s7,1
    80003abe:	a07d                	j	80003b6c <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003ac0:	4585                	li	a1,1
    80003ac2:	852e                	mv	a0,a1
    80003ac4:	eaeff0ef          	jal	80003172 <iget>
    80003ac8:	8a2a                	mv	s4,a0
    80003aca:	b7ed                	j	80003ab4 <namex+0x3c>
      iunlockput(ip);
    80003acc:	8552                	mv	a0,s4
    80003ace:	b6bff0ef          	jal	80003638 <iunlockput>
      return 0;
    80003ad2:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ad4:	8552                	mv	a0,s4
    80003ad6:	60e6                	ld	ra,88(sp)
    80003ad8:	6446                	ld	s0,80(sp)
    80003ada:	64a6                	ld	s1,72(sp)
    80003adc:	6906                	ld	s2,64(sp)
    80003ade:	79e2                	ld	s3,56(sp)
    80003ae0:	7a42                	ld	s4,48(sp)
    80003ae2:	7aa2                	ld	s5,40(sp)
    80003ae4:	7b02                	ld	s6,32(sp)
    80003ae6:	6be2                	ld	s7,24(sp)
    80003ae8:	6c42                	ld	s8,16(sp)
    80003aea:	6ca2                	ld	s9,8(sp)
    80003aec:	6d02                	ld	s10,0(sp)
    80003aee:	6125                	addi	sp,sp,96
    80003af0:	8082                	ret
      iunlockput(ip);
    80003af2:	8552                	mv	a0,s4
    80003af4:	b45ff0ef          	jal	80003638 <iunlockput>
      return 0;
    80003af8:	4a01                	li	s4,0
    80003afa:	bfe9                	j	80003ad4 <namex+0x5c>
      iunlock(ip);
    80003afc:	8552                	mv	a0,s4
    80003afe:	995ff0ef          	jal	80003492 <iunlock>
      return ip;
    80003b02:	bfc9                	j	80003ad4 <namex+0x5c>
      iunlockput(ip);
    80003b04:	8552                	mv	a0,s4
    80003b06:	b33ff0ef          	jal	80003638 <iunlockput>
      return 0;
    80003b0a:	8a4a                	mv	s4,s2
    80003b0c:	b7e1                	j	80003ad4 <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003b0e:	8926                	mv	s2,s1
  len = path - s;
    80003b10:	4d01                	li	s10,0
    80003b12:	4601                	li	a2,0
    memmove(name, s, len);
    80003b14:	2601                	sext.w	a2,a2
    80003b16:	85a6                	mv	a1,s1
    80003b18:	8556                	mv	a0,s5
    80003b1a:	a2efd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003b1e:	9d56                	add	s10,s10,s5
    80003b20:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb758>
  while (*path == '/')
    80003b24:	00094783          	lbu	a5,0(s2)
    80003b28:	09379b63          	bne	a5,s3,80003bbe <namex+0x146>
    80003b2c:	84ca                	mv	s1,s2
    path++;
    80003b2e:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b30:	0004c783          	lbu	a5,0(s1)
    80003b34:	ff378de3          	beq	a5,s3,80003b2e <namex+0xb6>
    ilock(ip);
    80003b38:	8552                	mv	a0,s4
    80003b3a:	8abff0ef          	jal	800033e4 <ilock>
    if (ip->type != T_DIR) {
    80003b3e:	044a1783          	lh	a5,68(s4)
    80003b42:	f97795e3          	bne	a5,s7,80003acc <namex+0x54>
    if (ip->nlink == 0) {
    80003b46:	04aa1783          	lh	a5,74(s4)
    80003b4a:	d7c5                	beqz	a5,80003af2 <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003b4c:	000b0563          	beqz	s6,80003b56 <namex+0xde>
    80003b50:	0004c783          	lbu	a5,0(s1)
    80003b54:	d7c5                	beqz	a5,80003afc <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003b56:	4601                	li	a2,0
    80003b58:	85d6                	mv	a1,s5
    80003b5a:	8552                	mv	a0,s4
    80003b5c:	e71ff0ef          	jal	800039cc <dirlookup>
    80003b60:	892a                	mv	s2,a0
    80003b62:	d14d                	beqz	a0,80003b04 <namex+0x8c>
    iunlockput(ip);
    80003b64:	8552                	mv	a0,s4
    80003b66:	ad3ff0ef          	jal	80003638 <iunlockput>
    ip = next;
    80003b6a:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003b6c:	0004c783          	lbu	a5,0(s1)
    80003b70:	01379763          	bne	a5,s3,80003b7e <namex+0x106>
    path++;
    80003b74:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b76:	0004c783          	lbu	a5,0(s1)
    80003b7a:	ff378de3          	beq	a5,s3,80003b74 <namex+0xfc>
  if (*path == 0)
    80003b7e:	c7a1                	beqz	a5,80003bc6 <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003b80:	0004c783          	lbu	a5,0(s1)
    80003b84:	fd178713          	addi	a4,a5,-47
    80003b88:	d359                	beqz	a4,80003b0e <namex+0x96>
    80003b8a:	d3d1                	beqz	a5,80003b0e <namex+0x96>
    80003b8c:	8926                	mv	s2,s1
    path++;
    80003b8e:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003b90:	00094783          	lbu	a5,0(s2)
    80003b94:	fd178713          	addi	a4,a5,-47
    80003b98:	c311                	beqz	a4,80003b9c <namex+0x124>
    80003b9a:	fbf5                	bnez	a5,80003b8e <namex+0x116>
  len = path - s;
    80003b9c:	40990633          	sub	a2,s2,s1
    80003ba0:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003ba4:	f7ac58e3          	bge	s8,s10,80003b14 <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003ba8:	8666                	mv	a2,s9
    80003baa:	85a6                	mv	a1,s1
    80003bac:	8556                	mv	a0,s5
    80003bae:	99afd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003bb2:	00094783          	lbu	a5,0(s2)
    80003bb6:	84ca                	mv	s1,s2
    80003bb8:	f7378be3          	beq	a5,s3,80003b2e <namex+0xb6>
    80003bbc:	bfb5                	j	80003b38 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003bbe:	00090463          	beqz	s2,80003bc6 <namex+0x14e>
    80003bc2:	84ca                	mv	s1,s2
    80003bc4:	bf95                	j	80003b38 <namex+0xc0>
  if (nameiparent) {
    80003bc6:	f00b07e3          	beqz	s6,80003ad4 <namex+0x5c>
    iput(ip);
    80003bca:	8552                	mv	a0,s4
    80003bcc:	99bff0ef          	jal	80003566 <iput>
    return 0;
    80003bd0:	4a01                	li	s4,0
    80003bd2:	b709                	j	80003ad4 <namex+0x5c>

0000000080003bd4 <dirlink>:
{
    80003bd4:	715d                	addi	sp,sp,-80
    80003bd6:	e486                	sd	ra,72(sp)
    80003bd8:	e0a2                	sd	s0,64(sp)
    80003bda:	f84a                	sd	s2,48(sp)
    80003bdc:	ec56                	sd	s5,24(sp)
    80003bde:	e85a                	sd	s6,16(sp)
    80003be0:	0880                	addi	s0,sp,80
    80003be2:	892a                	mv	s2,a0
    80003be4:	8aae                	mv	s5,a1
    80003be6:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003be8:	4601                	li	a2,0
    80003bea:	de3ff0ef          	jal	800039cc <dirlookup>
    80003bee:	ed1d                	bnez	a0,80003c2c <dirlink+0x58>
    80003bf0:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003bf2:	04c92483          	lw	s1,76(s2)
    80003bf6:	c4b9                	beqz	s1,80003c44 <dirlink+0x70>
    80003bf8:	f44e                	sd	s3,40(sp)
    80003bfa:	f052                	sd	s4,32(sp)
    80003bfc:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bfe:	fb040a13          	addi	s4,s0,-80
    80003c02:	49c1                	li	s3,16
    80003c04:	874e                	mv	a4,s3
    80003c06:	86a6                	mv	a3,s1
    80003c08:	8652                	mv	a2,s4
    80003c0a:	4581                	li	a1,0
    80003c0c:	854a                	mv	a0,s2
    80003c0e:	bb1ff0ef          	jal	800037be <readi>
    80003c12:	03351163          	bne	a0,s3,80003c34 <dirlink+0x60>
    if (de.inum == 0)
    80003c16:	fb045783          	lhu	a5,-80(s0)
    80003c1a:	c39d                	beqz	a5,80003c40 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003c1c:	24c1                	addiw	s1,s1,16
    80003c1e:	04c92783          	lw	a5,76(s2)
    80003c22:	fef4e1e3          	bltu	s1,a5,80003c04 <dirlink+0x30>
    80003c26:	79a2                	ld	s3,40(sp)
    80003c28:	7a02                	ld	s4,32(sp)
    80003c2a:	a829                	j	80003c44 <dirlink+0x70>
    iput(ip);
    80003c2c:	93bff0ef          	jal	80003566 <iput>
    return -1;
    80003c30:	557d                	li	a0,-1
    80003c32:	a83d                	j	80003c70 <dirlink+0x9c>
      panic("dirlink read");
    80003c34:	00004517          	auipc	a0,0x4
    80003c38:	8b450513          	addi	a0,a0,-1868 # 800074e8 <etext+0x4e8>
    80003c3c:	bf9fc0ef          	jal	80000834 <panic>
    80003c40:	79a2                	ld	s3,40(sp)
    80003c42:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003c44:	4639                	li	a2,14
    80003c46:	85d6                	mv	a1,s5
    80003c48:	fb240513          	addi	a0,s0,-78
    80003c4c:	9aafd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003c50:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c54:	4741                	li	a4,16
    80003c56:	86a6                	mv	a3,s1
    80003c58:	fb040613          	addi	a2,s0,-80
    80003c5c:	4581                	li	a1,0
    80003c5e:	854a                	mv	a0,s2
    80003c60:	c51ff0ef          	jal	800038b0 <writei>
    80003c64:	1541                	addi	a0,a0,-16
    80003c66:	00a03533          	snez	a0,a0
    80003c6a:	40a0053b          	negw	a0,a0
    80003c6e:	74e2                	ld	s1,56(sp)
}
    80003c70:	60a6                	ld	ra,72(sp)
    80003c72:	6406                	ld	s0,64(sp)
    80003c74:	7942                	ld	s2,48(sp)
    80003c76:	6ae2                	ld	s5,24(sp)
    80003c78:	6b42                	ld	s6,16(sp)
    80003c7a:	6161                	addi	sp,sp,80
    80003c7c:	8082                	ret

0000000080003c7e <namei>:

struct inode *
namei(char *path)
{
    80003c7e:	1101                	addi	sp,sp,-32
    80003c80:	ec06                	sd	ra,24(sp)
    80003c82:	e822                	sd	s0,16(sp)
    80003c84:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c86:	fe040613          	addi	a2,s0,-32
    80003c8a:	4581                	li	a1,0
    80003c8c:	dedff0ef          	jal	80003a78 <namex>
}
    80003c90:	60e2                	ld	ra,24(sp)
    80003c92:	6442                	ld	s0,16(sp)
    80003c94:	6105                	addi	sp,sp,32
    80003c96:	8082                	ret

0000000080003c98 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003c98:	1141                	addi	sp,sp,-16
    80003c9a:	e406                	sd	ra,8(sp)
    80003c9c:	e022                	sd	s0,0(sp)
    80003c9e:	0800                	addi	s0,sp,16
    80003ca0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ca2:	4585                	li	a1,1
    80003ca4:	dd5ff0ef          	jal	80003a78 <namex>
}
    80003ca8:	60a2                	ld	ra,8(sp)
    80003caa:	6402                	ld	s0,0(sp)
    80003cac:	0141                	addi	sp,sp,16
    80003cae:	8082                	ret

0000000080003cb0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003cb0:	1101                	addi	sp,sp,-32
    80003cb2:	ec06                	sd	ra,24(sp)
    80003cb4:	e822                	sd	s0,16(sp)
    80003cb6:	e426                	sd	s1,8(sp)
    80003cb8:	e04a                	sd	s2,0(sp)
    80003cba:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003cbc:	0001f917          	auipc	s2,0x1f
    80003cc0:	9ac90913          	addi	s2,s2,-1620 # 80022668 <log>
    80003cc4:	01892583          	lw	a1,24(s2)
    80003cc8:	02492503          	lw	a0,36(s2)
    80003ccc:	880ff0ef          	jal	80002d4c <bread>
    80003cd0:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003cd2:	02c92603          	lw	a2,44(s2)
    80003cd6:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003cd8:	00c05f63          	blez	a2,80003cf6 <write_head+0x46>
    80003cdc:	0001f717          	auipc	a4,0x1f
    80003ce0:	9bc70713          	addi	a4,a4,-1604 # 80022698 <log+0x30>
    80003ce4:	87aa                	mv	a5,a0
    80003ce6:	060a                	slli	a2,a2,0x2
    80003ce8:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003cea:	4314                	lw	a3,0(a4)
    80003cec:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003cee:	0711                	addi	a4,a4,4
    80003cf0:	0791                	addi	a5,a5,4
    80003cf2:	fec79ce3          	bne	a5,a2,80003cea <write_head+0x3a>
  }
  bwrite(buf);
    80003cf6:	8526                	mv	a0,s1
    80003cf8:	92aff0ef          	jal	80002e22 <bwrite>
  brelse(buf);
    80003cfc:	8526                	mv	a0,s1
    80003cfe:	956ff0ef          	jal	80002e54 <brelse>
}
    80003d02:	60e2                	ld	ra,24(sp)
    80003d04:	6442                	ld	s0,16(sp)
    80003d06:	64a2                	ld	s1,8(sp)
    80003d08:	6902                	ld	s2,0(sp)
    80003d0a:	6105                	addi	sp,sp,32
    80003d0c:	8082                	ret

0000000080003d0e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d0e:	0001f797          	auipc	a5,0x1f
    80003d12:	9867a783          	lw	a5,-1658(a5) # 80022694 <log+0x2c>
    80003d16:	0cf05163          	blez	a5,80003dd8 <install_trans+0xca>
{
    80003d1a:	715d                	addi	sp,sp,-80
    80003d1c:	e486                	sd	ra,72(sp)
    80003d1e:	e0a2                	sd	s0,64(sp)
    80003d20:	fc26                	sd	s1,56(sp)
    80003d22:	f84a                	sd	s2,48(sp)
    80003d24:	f44e                	sd	s3,40(sp)
    80003d26:	f052                	sd	s4,32(sp)
    80003d28:	ec56                	sd	s5,24(sp)
    80003d2a:	e85a                	sd	s6,16(sp)
    80003d2c:	e45e                	sd	s7,8(sp)
    80003d2e:	e062                	sd	s8,0(sp)
    80003d30:	0880                	addi	s0,sp,80
    80003d32:	8b2a                	mv	s6,a0
    80003d34:	0001fa97          	auipc	s5,0x1f
    80003d38:	964a8a93          	addi	s5,s5,-1692 # 80022698 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d3c:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d3e:	00003c17          	auipc	s8,0x3
    80003d42:	7bac0c13          	addi	s8,s8,1978 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003d46:	0001fa17          	auipc	s4,0x1f
    80003d4a:	922a0a13          	addi	s4,s4,-1758 # 80022668 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003d4e:	40000b93          	li	s7,1024
    80003d52:	a025                	j	80003d7a <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d54:	000aa603          	lw	a2,0(s5)
    80003d58:	85ce                	mv	a1,s3
    80003d5a:	8562                	mv	a0,s8
    80003d5c:	faefc0ef          	jal	8000050a <printk>
    80003d60:	a839                	j	80003d7e <install_trans+0x70>
    brelse(lbuf);
    80003d62:	854a                	mv	a0,s2
    80003d64:	8f0ff0ef          	jal	80002e54 <brelse>
    brelse(dbuf);
    80003d68:	8526                	mv	a0,s1
    80003d6a:	8eaff0ef          	jal	80002e54 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d6e:	2985                	addiw	s3,s3,1
    80003d70:	0a91                	addi	s5,s5,4
    80003d72:	02ca2783          	lw	a5,44(s4)
    80003d76:	04f9d563          	bge	s3,a5,80003dc0 <install_trans+0xb2>
    if (recovering) {
    80003d7a:	fc0b1de3          	bnez	s6,80003d54 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003d7e:	018a2583          	lw	a1,24(s4)
    80003d82:	013585bb          	addw	a1,a1,s3
    80003d86:	2585                	addiw	a1,a1,1
    80003d88:	024a2503          	lw	a0,36(s4)
    80003d8c:	fc1fe0ef          	jal	80002d4c <bread>
    80003d90:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003d92:	000aa583          	lw	a1,0(s5)
    80003d96:	024a2503          	lw	a0,36(s4)
    80003d9a:	fb3fe0ef          	jal	80002d4c <bread>
    80003d9e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003da0:	865e                	mv	a2,s7
    80003da2:	05890593          	addi	a1,s2,88
    80003da6:	05850513          	addi	a0,a0,88
    80003daa:	f9ffc0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003dae:	8526                	mv	a0,s1
    80003db0:	872ff0ef          	jal	80002e22 <bwrite>
    if (recovering == 0)
    80003db4:	fa0b17e3          	bnez	s6,80003d62 <install_trans+0x54>
      bunpin(dbuf);
    80003db8:	8526                	mv	a0,s1
    80003dba:	952ff0ef          	jal	80002f0c <bunpin>
    80003dbe:	b755                	j	80003d62 <install_trans+0x54>
}
    80003dc0:	60a6                	ld	ra,72(sp)
    80003dc2:	6406                	ld	s0,64(sp)
    80003dc4:	74e2                	ld	s1,56(sp)
    80003dc6:	7942                	ld	s2,48(sp)
    80003dc8:	79a2                	ld	s3,40(sp)
    80003dca:	7a02                	ld	s4,32(sp)
    80003dcc:	6ae2                	ld	s5,24(sp)
    80003dce:	6b42                	ld	s6,16(sp)
    80003dd0:	6ba2                	ld	s7,8(sp)
    80003dd2:	6c02                	ld	s8,0(sp)
    80003dd4:	6161                	addi	sp,sp,80
    80003dd6:	8082                	ret
    80003dd8:	8082                	ret

0000000080003dda <initlog>:
{
    80003dda:	7179                	addi	sp,sp,-48
    80003ddc:	f406                	sd	ra,40(sp)
    80003dde:	f022                	sd	s0,32(sp)
    80003de0:	ec26                	sd	s1,24(sp)
    80003de2:	e84a                	sd	s2,16(sp)
    80003de4:	e44e                	sd	s3,8(sp)
    80003de6:	1800                	addi	s0,sp,48
    80003de8:	84aa                	mv	s1,a0
    80003dea:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003dec:	0001f917          	auipc	s2,0x1f
    80003df0:	87c90913          	addi	s2,s2,-1924 # 80022668 <log>
    80003df4:	00003597          	auipc	a1,0x3
    80003df8:	72458593          	addi	a1,a1,1828 # 80007518 <etext+0x518>
    80003dfc:	854a                	mv	a0,s2
    80003dfe:	dabfc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003e02:	0149a583          	lw	a1,20(s3)
    80003e06:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003e0a:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003e0e:	8526                	mv	a0,s1
    80003e10:	f3dfe0ef          	jal	80002d4c <bread>
  log.lh.n = lh->n;
    80003e14:	4d30                	lw	a2,88(a0)
    80003e16:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003e1a:	00c05f63          	blez	a2,80003e38 <initlog+0x5e>
    80003e1e:	87aa                	mv	a5,a0
    80003e20:	0001f717          	auipc	a4,0x1f
    80003e24:	87870713          	addi	a4,a4,-1928 # 80022698 <log+0x30>
    80003e28:	060a                	slli	a2,a2,0x2
    80003e2a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e2c:	4ff4                	lw	a3,92(a5)
    80003e2e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e30:	0791                	addi	a5,a5,4
    80003e32:	0711                	addi	a4,a4,4
    80003e34:	fec79ce3          	bne	a5,a2,80003e2c <initlog+0x52>
  brelse(buf);
    80003e38:	81cff0ef          	jal	80002e54 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e3c:	4505                	li	a0,1
    80003e3e:	ed1ff0ef          	jal	80003d0e <install_trans>
  log.lh.n = 0;
    80003e42:	0001f797          	auipc	a5,0x1f
    80003e46:	8407a923          	sw	zero,-1966(a5) # 80022694 <log+0x2c>
  write_head(); // clear the log
    80003e4a:	e67ff0ef          	jal	80003cb0 <write_head>
}
    80003e4e:	70a2                	ld	ra,40(sp)
    80003e50:	7402                	ld	s0,32(sp)
    80003e52:	64e2                	ld	s1,24(sp)
    80003e54:	6942                	ld	s2,16(sp)
    80003e56:	69a2                	ld	s3,8(sp)
    80003e58:	6145                	addi	sp,sp,48
    80003e5a:	8082                	ret

0000000080003e5c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e5c:	1101                	addi	sp,sp,-32
    80003e5e:	ec06                	sd	ra,24(sp)
    80003e60:	e822                	sd	s0,16(sp)
    80003e62:	e426                	sd	s1,8(sp)
    80003e64:	e04a                	sd	s2,0(sp)
    80003e66:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e68:	0001f517          	auipc	a0,0x1f
    80003e6c:	80050513          	addi	a0,a0,-2048 # 80022668 <log>
    80003e70:	db9fc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80003e74:	0001e497          	auipc	s1,0x1e
    80003e78:	7f448493          	addi	s1,s1,2036 # 80022668 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003e7c:	4979                	li	s2,30
    80003e7e:	a821                	j	80003e96 <begin_op+0x3a>
      sleep_prepare(&log);
    80003e80:	8526                	mv	a0,s1
    80003e82:	a18fe0ef          	jal	8000209a <sleep_prepare>
      release(&log.lock);
    80003e86:	8526                	mv	a0,s1
    80003e88:	e29fc0ef          	jal	80000cb0 <release>
      sleep();
    80003e8c:	a4afe0ef          	jal	800020d6 <sleep>
      acquire(&log.lock);
    80003e90:	8526                	mv	a0,s1
    80003e92:	d97fc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80003e96:	509c                	lw	a5,32(s1)
    80003e98:	f7e5                	bnez	a5,80003e80 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003e9a:	4cd8                	lw	a4,28(s1)
    80003e9c:	2705                	addiw	a4,a4,1
    80003e9e:	0027179b          	slliw	a5,a4,0x2
    80003ea2:	9fb9                	addw	a5,a5,a4
    80003ea4:	0017979b          	slliw	a5,a5,0x1
    80003ea8:	54d4                	lw	a3,44(s1)
    80003eaa:	9fb5                	addw	a5,a5,a3
    80003eac:	00f95e63          	bge	s2,a5,80003ec8 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003eb0:	8526                	mv	a0,s1
    80003eb2:	9e8fe0ef          	jal	8000209a <sleep_prepare>
      release(&log.lock);
    80003eb6:	8526                	mv	a0,s1
    80003eb8:	df9fc0ef          	jal	80000cb0 <release>
      sleep();
    80003ebc:	a1afe0ef          	jal	800020d6 <sleep>
      acquire(&log.lock);
    80003ec0:	8526                	mv	a0,s1
    80003ec2:	d67fc0ef          	jal	80000c28 <acquire>
    80003ec6:	bfc1                	j	80003e96 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003ec8:	0001e797          	auipc	a5,0x1e
    80003ecc:	7ae7ae23          	sw	a4,1980(a5) # 80022684 <log+0x1c>
      release(&log.lock);
    80003ed0:	0001e517          	auipc	a0,0x1e
    80003ed4:	79850513          	addi	a0,a0,1944 # 80022668 <log>
    80003ed8:	dd9fc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80003edc:	60e2                	ld	ra,24(sp)
    80003ede:	6442                	ld	s0,16(sp)
    80003ee0:	64a2                	ld	s1,8(sp)
    80003ee2:	6902                	ld	s2,0(sp)
    80003ee4:	6105                	addi	sp,sp,32
    80003ee6:	8082                	ret

0000000080003ee8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003ee8:	7139                	addi	sp,sp,-64
    80003eea:	fc06                	sd	ra,56(sp)
    80003eec:	f822                	sd	s0,48(sp)
    80003eee:	f426                	sd	s1,40(sp)
    80003ef0:	f04a                	sd	s2,32(sp)
    80003ef2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003ef4:	0001e497          	auipc	s1,0x1e
    80003ef8:	77448493          	addi	s1,s1,1908 # 80022668 <log>
    80003efc:	8526                	mv	a0,s1
    80003efe:	d2bfc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003f02:	4cdc                	lw	a5,28(s1)
    80003f04:	37fd                	addiw	a5,a5,-1
    80003f06:	893e                	mv	s2,a5
    80003f08:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003f0a:	509c                	lw	a5,32(s1)
    80003f0c:	e3b1                	bnez	a5,80003f50 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003f0e:	04091a63          	bnez	s2,80003f62 <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003f12:	0001e497          	auipc	s1,0x1e
    80003f16:	75648493          	addi	s1,s1,1878 # 80022668 <log>
    80003f1a:	4785                	li	a5,1
    80003f1c:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f1e:	8526                	mv	a0,s1
    80003f20:	d91fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f24:	54dc                	lw	a5,44(s1)
    80003f26:	06f04063          	bgtz	a5,80003f86 <end_op+0x9e>
    acquire(&log.lock);
    80003f2a:	0001e497          	auipc	s1,0x1e
    80003f2e:	73e48493          	addi	s1,s1,1854 # 80022668 <log>
    80003f32:	8526                	mv	a0,s1
    80003f34:	cf5fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003f38:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003f3c:	549c                	lw	a5,40(s1)
    80003f3e:	2785                	addiw	a5,a5,1
    80003f40:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003f42:	8526                	mv	a0,s1
    80003f44:	9c6fe0ef          	jal	8000210a <wakeup>
    release(&log.lock);
    80003f48:	8526                	mv	a0,s1
    80003f4a:	d67fc0ef          	jal	80000cb0 <release>
}
    80003f4e:	a035                	j	80003f7a <end_op+0x92>
    80003f50:	ec4e                	sd	s3,24(sp)
    80003f52:	e852                	sd	s4,16(sp)
    80003f54:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003f56:	00003517          	auipc	a0,0x3
    80003f5a:	5ca50513          	addi	a0,a0,1482 # 80007520 <etext+0x520>
    80003f5e:	8d7fc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003f62:	0001e517          	auipc	a0,0x1e
    80003f66:	70650513          	addi	a0,a0,1798 # 80022668 <log>
    80003f6a:	9a0fe0ef          	jal	8000210a <wakeup>
  release(&log.lock);
    80003f6e:	0001e517          	auipc	a0,0x1e
    80003f72:	6fa50513          	addi	a0,a0,1786 # 80022668 <log>
    80003f76:	d3bfc0ef          	jal	80000cb0 <release>
}
    80003f7a:	70e2                	ld	ra,56(sp)
    80003f7c:	7442                	ld	s0,48(sp)
    80003f7e:	74a2                	ld	s1,40(sp)
    80003f80:	7902                	ld	s2,32(sp)
    80003f82:	6121                	addi	sp,sp,64
    80003f84:	8082                	ret
    80003f86:	ec4e                	sd	s3,24(sp)
    80003f88:	e852                	sd	s4,16(sp)
    80003f8a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f8c:	0001ea97          	auipc	s5,0x1e
    80003f90:	70ca8a93          	addi	s5,s5,1804 # 80022698 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003f94:	0001ea17          	auipc	s4,0x1e
    80003f98:	6d4a0a13          	addi	s4,s4,1748 # 80022668 <log>
    80003f9c:	018a2583          	lw	a1,24(s4)
    80003fa0:	012585bb          	addw	a1,a1,s2
    80003fa4:	2585                	addiw	a1,a1,1
    80003fa6:	024a2503          	lw	a0,36(s4)
    80003faa:	da3fe0ef          	jal	80002d4c <bread>
    80003fae:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003fb0:	000aa583          	lw	a1,0(s5)
    80003fb4:	024a2503          	lw	a0,36(s4)
    80003fb8:	d95fe0ef          	jal	80002d4c <bread>
    80003fbc:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003fbe:	40000613          	li	a2,1024
    80003fc2:	05850593          	addi	a1,a0,88
    80003fc6:	05848513          	addi	a0,s1,88
    80003fca:	d7ffc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    80003fce:	8526                	mv	a0,s1
    80003fd0:	e53fe0ef          	jal	80002e22 <bwrite>
    brelse(from);
    80003fd4:	854e                	mv	a0,s3
    80003fd6:	e7ffe0ef          	jal	80002e54 <brelse>
    brelse(to);
    80003fda:	8526                	mv	a0,s1
    80003fdc:	e79fe0ef          	jal	80002e54 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fe0:	2905                	addiw	s2,s2,1
    80003fe2:	0a91                	addi	s5,s5,4
    80003fe4:	02ca2783          	lw	a5,44(s4)
    80003fe8:	faf94ae3          	blt	s2,a5,80003f9c <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003fec:	cc5ff0ef          	jal	80003cb0 <write_head>
    install_trans(0); // Now install writes to home locations
    80003ff0:	4501                	li	a0,0
    80003ff2:	d1dff0ef          	jal	80003d0e <install_trans>
    log.lh.n = 0;
    80003ff6:	0001e797          	auipc	a5,0x1e
    80003ffa:	6807af23          	sw	zero,1694(a5) # 80022694 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003ffe:	cb3ff0ef          	jal	80003cb0 <write_head>
    80004002:	69e2                	ld	s3,24(sp)
    80004004:	6a42                	ld	s4,16(sp)
    80004006:	6aa2                	ld	s5,8(sp)
    80004008:	b70d                	j	80003f2a <end_op+0x42>

000000008000400a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000400a:	1101                	addi	sp,sp,-32
    8000400c:	ec06                	sd	ra,24(sp)
    8000400e:	e822                	sd	s0,16(sp)
    80004010:	e426                	sd	s1,8(sp)
    80004012:	1000                	addi	s0,sp,32
    80004014:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004016:	0001e517          	auipc	a0,0x1e
    8000401a:	65250513          	addi	a0,a0,1618 # 80022668 <log>
    8000401e:	c0bfc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004022:	0001e617          	auipc	a2,0x1e
    80004026:	67262603          	lw	a2,1650(a2) # 80022694 <log+0x2c>
    8000402a:	47f5                	li	a5,29
    8000402c:	04c7cd63          	blt	a5,a2,80004086 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004030:	0001e797          	auipc	a5,0x1e
    80004034:	6547a783          	lw	a5,1620(a5) # 80022684 <log+0x1c>
    80004038:	04f05d63          	blez	a5,80004092 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000403c:	4781                	li	a5,0
    8000403e:	06c05063          	blez	a2,8000409e <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80004042:	44cc                	lw	a1,12(s1)
    80004044:	0001e717          	auipc	a4,0x1e
    80004048:	65470713          	addi	a4,a4,1620 # 80022698 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000404c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    8000404e:	4314                	lw	a3,0(a4)
    80004050:	04b68763          	beq	a3,a1,8000409e <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80004054:	2785                	addiw	a5,a5,1
    80004056:	0711                	addi	a4,a4,4
    80004058:	fef61be3          	bne	a2,a5,8000404e <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000405c:	060a                	slli	a2,a2,0x2
    8000405e:	02060613          	addi	a2,a2,32
    80004062:	0001e797          	auipc	a5,0x1e
    80004066:	60678793          	addi	a5,a5,1542 # 80022668 <log>
    8000406a:	97b2                	add	a5,a5,a2
    8000406c:	44d8                	lw	a4,12(s1)
    8000406e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80004070:	8526                	mv	a0,s1
    80004072:	e67fe0ef          	jal	80002ed8 <bpin>
    log.lh.n++;
    80004076:	0001e717          	auipc	a4,0x1e
    8000407a:	5f270713          	addi	a4,a4,1522 # 80022668 <log>
    8000407e:	575c                	lw	a5,44(a4)
    80004080:	2785                	addiw	a5,a5,1
    80004082:	d75c                	sw	a5,44(a4)
    80004084:	a815                	j	800040b8 <log_write+0xae>
    panic("too big a transaction");
    80004086:	00003517          	auipc	a0,0x3
    8000408a:	4aa50513          	addi	a0,a0,1194 # 80007530 <etext+0x530>
    8000408e:	fa6fc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    80004092:	00003517          	auipc	a0,0x3
    80004096:	4b650513          	addi	a0,a0,1206 # 80007548 <etext+0x548>
    8000409a:	f9afc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    8000409e:	00279693          	slli	a3,a5,0x2
    800040a2:	02068693          	addi	a3,a3,32
    800040a6:	0001e717          	auipc	a4,0x1e
    800040aa:	5c270713          	addi	a4,a4,1474 # 80022668 <log>
    800040ae:	9736                	add	a4,a4,a3
    800040b0:	44d4                	lw	a3,12(s1)
    800040b2:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    800040b4:	faf60ee3          	beq	a2,a5,80004070 <log_write+0x66>
  }
  release(&log.lock);
    800040b8:	0001e517          	auipc	a0,0x1e
    800040bc:	5b050513          	addi	a0,a0,1456 # 80022668 <log>
    800040c0:	bf1fc0ef          	jal	80000cb0 <release>
}
    800040c4:	60e2                	ld	ra,24(sp)
    800040c6:	6442                	ld	s0,16(sp)
    800040c8:	64a2                	ld	s1,8(sp)
    800040ca:	6105                	addi	sp,sp,32
    800040cc:	8082                	ret

00000000800040ce <sys_sync>:

uint64
sys_sync(void)
{
    800040ce:	1101                	addi	sp,sp,-32
    800040d0:	ec06                	sd	ra,24(sp)
    800040d2:	e822                	sd	s0,16(sp)
    800040d4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040d6:	0001e517          	auipc	a0,0x1e
    800040da:	59250513          	addi	a0,a0,1426 # 80022668 <log>
    800040de:	b4bfc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    800040e2:	0001e797          	auipc	a5,0x1e
    800040e6:	5a67a783          	lw	a5,1446(a5) # 80022688 <log+0x20>
    800040ea:	e799                	bnez	a5,800040f8 <sys_sync+0x2a>
    800040ec:	0001e797          	auipc	a5,0x1e
    800040f0:	5987a783          	lw	a5,1432(a5) # 80022684 <log+0x1c>
    800040f4:	02f05c63          	blez	a5,8000412c <sys_sync+0x5e>
    800040f8:	e426                	sd	s1,8(sp)
    800040fa:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    800040fc:	0001e917          	auipc	s2,0x1e
    80004100:	59492903          	lw	s2,1428(s2) # 80022690 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80004104:	0001e497          	auipc	s1,0x1e
    80004108:	56448493          	addi	s1,s1,1380 # 80022668 <log>
    8000410c:	8526                	mv	a0,s1
    8000410e:	f8dfd0ef          	jal	8000209a <sleep_prepare>
      release(&log.lock);
    80004112:	8526                	mv	a0,s1
    80004114:	b9dfc0ef          	jal	80000cb0 <release>
      sleep();
    80004118:	fbffd0ef          	jal	800020d6 <sleep>
      acquire(&log.lock);
    8000411c:	8526                	mv	a0,s1
    8000411e:	b0bfc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    80004122:	549c                	lw	a5,40(s1)
    80004124:	fef954e3          	bge	s2,a5,8000410c <sys_sync+0x3e>
    80004128:	64a2                	ld	s1,8(sp)
    8000412a:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    8000412c:	0001e517          	auipc	a0,0x1e
    80004130:	53c50513          	addi	a0,a0,1340 # 80022668 <log>
    80004134:	b7dfc0ef          	jal	80000cb0 <release>
  return 0;
}
    80004138:	4501                	li	a0,0
    8000413a:	60e2                	ld	ra,24(sp)
    8000413c:	6442                	ld	s0,16(sp)
    8000413e:	6105                	addi	sp,sp,32
    80004140:	8082                	ret

0000000080004142 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004142:	1101                	addi	sp,sp,-32
    80004144:	ec06                	sd	ra,24(sp)
    80004146:	e822                	sd	s0,16(sp)
    80004148:	e426                	sd	s1,8(sp)
    8000414a:	e04a                	sd	s2,0(sp)
    8000414c:	1000                	addi	s0,sp,32
    8000414e:	84aa                	mv	s1,a0
    80004150:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004152:	00003597          	auipc	a1,0x3
    80004156:	41658593          	addi	a1,a1,1046 # 80007568 <etext+0x568>
    8000415a:	0521                	addi	a0,a0,8
    8000415c:	a4dfc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    80004160:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004164:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004168:	0204a423          	sw	zero,40(s1)
}
    8000416c:	60e2                	ld	ra,24(sp)
    8000416e:	6442                	ld	s0,16(sp)
    80004170:	64a2                	ld	s1,8(sp)
    80004172:	6902                	ld	s2,0(sp)
    80004174:	6105                	addi	sp,sp,32
    80004176:	8082                	ret

0000000080004178 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004178:	1101                	addi	sp,sp,-32
    8000417a:	ec06                	sd	ra,24(sp)
    8000417c:	e822                	sd	s0,16(sp)
    8000417e:	e426                	sd	s1,8(sp)
    80004180:	e04a                	sd	s2,0(sp)
    80004182:	1000                	addi	s0,sp,32
    80004184:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004186:	00850913          	addi	s2,a0,8
    8000418a:	854a                	mv	a0,s2
    8000418c:	a9dfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004190:	409c                	lw	a5,0(s1)
    80004192:	cf91                	beqz	a5,800041ae <acquiresleep+0x36>
    sleep_prepare(lk);
    80004194:	8526                	mv	a0,s1
    80004196:	f05fd0ef          	jal	8000209a <sleep_prepare>
    release(&lk->lk);
    8000419a:	854a                	mv	a0,s2
    8000419c:	b15fc0ef          	jal	80000cb0 <release>
    sleep();
    800041a0:	f37fd0ef          	jal	800020d6 <sleep>
    acquire(&lk->lk);
    800041a4:	854a                	mv	a0,s2
    800041a6:	a83fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800041aa:	409c                	lw	a5,0(s1)
    800041ac:	f7e5                	bnez	a5,80004194 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800041ae:	4785                	li	a5,1
    800041b0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800041b2:	f96fd0ef          	jal	80001948 <myproc>
    800041b6:	591c                	lw	a5,48(a0)
    800041b8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800041ba:	854a                	mv	a0,s2
    800041bc:	af5fc0ef          	jal	80000cb0 <release>
}
    800041c0:	60e2                	ld	ra,24(sp)
    800041c2:	6442                	ld	s0,16(sp)
    800041c4:	64a2                	ld	s1,8(sp)
    800041c6:	6902                	ld	s2,0(sp)
    800041c8:	6105                	addi	sp,sp,32
    800041ca:	8082                	ret

00000000800041cc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800041cc:	1101                	addi	sp,sp,-32
    800041ce:	ec06                	sd	ra,24(sp)
    800041d0:	e822                	sd	s0,16(sp)
    800041d2:	e426                	sd	s1,8(sp)
    800041d4:	e04a                	sd	s2,0(sp)
    800041d6:	1000                	addi	s0,sp,32
    800041d8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041da:	00850913          	addi	s2,a0,8
    800041de:	854a                	mv	a0,s2
    800041e0:	a49fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    800041e4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800041e8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800041ec:	8526                	mv	a0,s1
    800041ee:	f1dfd0ef          	jal	8000210a <wakeup>
  release(&lk->lk);
    800041f2:	854a                	mv	a0,s2
    800041f4:	abdfc0ef          	jal	80000cb0 <release>
}
    800041f8:	60e2                	ld	ra,24(sp)
    800041fa:	6442                	ld	s0,16(sp)
    800041fc:	64a2                	ld	s1,8(sp)
    800041fe:	6902                	ld	s2,0(sp)
    80004200:	6105                	addi	sp,sp,32
    80004202:	8082                	ret

0000000080004204 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004204:	7179                	addi	sp,sp,-48
    80004206:	f406                	sd	ra,40(sp)
    80004208:	f022                	sd	s0,32(sp)
    8000420a:	ec26                	sd	s1,24(sp)
    8000420c:	e84a                	sd	s2,16(sp)
    8000420e:	1800                	addi	s0,sp,48
    80004210:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80004212:	00850913          	addi	s2,a0,8
    80004216:	854a                	mv	a0,s2
    80004218:	a11fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000421c:	409c                	lw	a5,0(s1)
    8000421e:	ef81                	bnez	a5,80004236 <holdingsleep+0x32>
    80004220:	4481                	li	s1,0
  release(&lk->lk);
    80004222:	854a                	mv	a0,s2
    80004224:	a8dfc0ef          	jal	80000cb0 <release>
  return r;
}
    80004228:	8526                	mv	a0,s1
    8000422a:	70a2                	ld	ra,40(sp)
    8000422c:	7402                	ld	s0,32(sp)
    8000422e:	64e2                	ld	s1,24(sp)
    80004230:	6942                	ld	s2,16(sp)
    80004232:	6145                	addi	sp,sp,48
    80004234:	8082                	ret
    80004236:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004238:	0284a983          	lw	s3,40(s1)
    8000423c:	f0cfd0ef          	jal	80001948 <myproc>
    80004240:	5904                	lw	s1,48(a0)
    80004242:	413484b3          	sub	s1,s1,s3
    80004246:	0014b493          	seqz	s1,s1
    8000424a:	69a2                	ld	s3,8(sp)
    8000424c:	bfd9                	j	80004222 <holdingsleep+0x1e>

000000008000424e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000424e:	1141                	addi	sp,sp,-16
    80004250:	e406                	sd	ra,8(sp)
    80004252:	e022                	sd	s0,0(sp)
    80004254:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004256:	00003597          	auipc	a1,0x3
    8000425a:	32258593          	addi	a1,a1,802 # 80007578 <etext+0x578>
    8000425e:	0001e517          	auipc	a0,0x1e
    80004262:	55250513          	addi	a0,a0,1362 # 800227b0 <ftable>
    80004266:	943fc0ef          	jal	80000ba8 <initlock>
}
    8000426a:	60a2                	ld	ra,8(sp)
    8000426c:	6402                	ld	s0,0(sp)
    8000426e:	0141                	addi	sp,sp,16
    80004270:	8082                	ret

0000000080004272 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80004272:	1101                	addi	sp,sp,-32
    80004274:	ec06                	sd	ra,24(sp)
    80004276:	e822                	sd	s0,16(sp)
    80004278:	e426                	sd	s1,8(sp)
    8000427a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000427c:	0001e517          	auipc	a0,0x1e
    80004280:	53450513          	addi	a0,a0,1332 # 800227b0 <ftable>
    80004284:	9a5fc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004288:	0001e497          	auipc	s1,0x1e
    8000428c:	54048493          	addi	s1,s1,1344 # 800227c8 <ftable+0x18>
    80004290:	0001f717          	auipc	a4,0x1f
    80004294:	4d870713          	addi	a4,a4,1240 # 80023768 <disk>
    if (f->ref == 0) {
    80004298:	40dc                	lw	a5,4(s1)
    8000429a:	cf89                	beqz	a5,800042b4 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    8000429c:	02848493          	addi	s1,s1,40
    800042a0:	fee49ce3          	bne	s1,a4,80004298 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800042a4:	0001e517          	auipc	a0,0x1e
    800042a8:	50c50513          	addi	a0,a0,1292 # 800227b0 <ftable>
    800042ac:	a05fc0ef          	jal	80000cb0 <release>
  return 0;
    800042b0:	4481                	li	s1,0
    800042b2:	a809                	j	800042c4 <filealloc+0x52>
      f->ref = 1;
    800042b4:	4785                	li	a5,1
    800042b6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800042b8:	0001e517          	auipc	a0,0x1e
    800042bc:	4f850513          	addi	a0,a0,1272 # 800227b0 <ftable>
    800042c0:	9f1fc0ef          	jal	80000cb0 <release>
}
    800042c4:	8526                	mv	a0,s1
    800042c6:	60e2                	ld	ra,24(sp)
    800042c8:	6442                	ld	s0,16(sp)
    800042ca:	64a2                	ld	s1,8(sp)
    800042cc:	6105                	addi	sp,sp,32
    800042ce:	8082                	ret

00000000800042d0 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    800042d0:	1101                	addi	sp,sp,-32
    800042d2:	ec06                	sd	ra,24(sp)
    800042d4:	e822                	sd	s0,16(sp)
    800042d6:	e426                	sd	s1,8(sp)
    800042d8:	1000                	addi	s0,sp,32
    800042da:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800042dc:	0001e517          	auipc	a0,0x1e
    800042e0:	4d450513          	addi	a0,a0,1236 # 800227b0 <ftable>
    800042e4:	945fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800042e8:	40dc                	lw	a5,4(s1)
    800042ea:	02f05063          	blez	a5,8000430a <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800042ee:	2785                	addiw	a5,a5,1
    800042f0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800042f2:	0001e517          	auipc	a0,0x1e
    800042f6:	4be50513          	addi	a0,a0,1214 # 800227b0 <ftable>
    800042fa:	9b7fc0ef          	jal	80000cb0 <release>
  return f;
}
    800042fe:	8526                	mv	a0,s1
    80004300:	60e2                	ld	ra,24(sp)
    80004302:	6442                	ld	s0,16(sp)
    80004304:	64a2                	ld	s1,8(sp)
    80004306:	6105                	addi	sp,sp,32
    80004308:	8082                	ret
    panic("filedup");
    8000430a:	00003517          	auipc	a0,0x3
    8000430e:	27650513          	addi	a0,a0,630 # 80007580 <etext+0x580>
    80004312:	d22fc0ef          	jal	80000834 <panic>

0000000080004316 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004316:	7139                	addi	sp,sp,-64
    80004318:	fc06                	sd	ra,56(sp)
    8000431a:	f822                	sd	s0,48(sp)
    8000431c:	f426                	sd	s1,40(sp)
    8000431e:	0080                	addi	s0,sp,64
    80004320:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004322:	0001e517          	auipc	a0,0x1e
    80004326:	48e50513          	addi	a0,a0,1166 # 800227b0 <ftable>
    8000432a:	8fffc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    8000432e:	40dc                	lw	a5,4(s1)
    80004330:	04f05a63          	blez	a5,80004384 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    80004334:	37fd                	addiw	a5,a5,-1
    80004336:	c0dc                	sw	a5,4(s1)
    80004338:	06f04063          	bgtz	a5,80004398 <fileclose+0x82>
    8000433c:	f04a                	sd	s2,32(sp)
    8000433e:	ec4e                	sd	s3,24(sp)
    80004340:	e852                	sd	s4,16(sp)
    80004342:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004344:	0004a903          	lw	s2,0(s1)
    80004348:	0094c783          	lbu	a5,9(s1)
    8000434c:	89be                	mv	s3,a5
    8000434e:	689c                	ld	a5,16(s1)
    80004350:	8a3e                	mv	s4,a5
    80004352:	6c9c                	ld	a5,24(s1)
    80004354:	8abe                	mv	s5,a5
  f->ref = 0;
    80004356:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000435a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000435e:	0001e517          	auipc	a0,0x1e
    80004362:	45250513          	addi	a0,a0,1106 # 800227b0 <ftable>
    80004366:	94bfc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    8000436a:	4785                	li	a5,1
    8000436c:	04f90163          	beq	s2,a5,800043ae <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    80004370:	ffe9079b          	addiw	a5,s2,-2
    80004374:	4705                	li	a4,1
    80004376:	04f77563          	bgeu	a4,a5,800043c0 <fileclose+0xaa>
    8000437a:	7902                	ld	s2,32(sp)
    8000437c:	69e2                	ld	s3,24(sp)
    8000437e:	6a42                	ld	s4,16(sp)
    80004380:	6aa2                	ld	s5,8(sp)
    80004382:	a00d                	j	800043a4 <fileclose+0x8e>
    80004384:	f04a                	sd	s2,32(sp)
    80004386:	ec4e                	sd	s3,24(sp)
    80004388:	e852                	sd	s4,16(sp)
    8000438a:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000438c:	00003517          	auipc	a0,0x3
    80004390:	1fc50513          	addi	a0,a0,508 # 80007588 <etext+0x588>
    80004394:	ca0fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    80004398:	0001e517          	auipc	a0,0x1e
    8000439c:	41850513          	addi	a0,a0,1048 # 800227b0 <ftable>
    800043a0:	911fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800043a4:	70e2                	ld	ra,56(sp)
    800043a6:	7442                	ld	s0,48(sp)
    800043a8:	74a2                	ld	s1,40(sp)
    800043aa:	6121                	addi	sp,sp,64
    800043ac:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800043ae:	85ce                	mv	a1,s3
    800043b0:	8552                	mv	a0,s4
    800043b2:	36a000ef          	jal	8000471c <pipeclose>
    800043b6:	7902                	ld	s2,32(sp)
    800043b8:	69e2                	ld	s3,24(sp)
    800043ba:	6a42                	ld	s4,16(sp)
    800043bc:	6aa2                	ld	s5,8(sp)
    800043be:	b7dd                	j	800043a4 <fileclose+0x8e>
    begin_op();
    800043c0:	a9dff0ef          	jal	80003e5c <begin_op>
    iput(ff.ip);
    800043c4:	8556                	mv	a0,s5
    800043c6:	9a0ff0ef          	jal	80003566 <iput>
    end_op();
    800043ca:	b1fff0ef          	jal	80003ee8 <end_op>
    800043ce:	7902                	ld	s2,32(sp)
    800043d0:	69e2                	ld	s3,24(sp)
    800043d2:	6a42                	ld	s4,16(sp)
    800043d4:	6aa2                	ld	s5,8(sp)
    800043d6:	b7f9                	j	800043a4 <fileclose+0x8e>

00000000800043d8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800043d8:	715d                	addi	sp,sp,-80
    800043da:	e486                	sd	ra,72(sp)
    800043dc:	e0a2                	sd	s0,64(sp)
    800043de:	fc26                	sd	s1,56(sp)
    800043e0:	f052                	sd	s4,32(sp)
    800043e2:	0880                	addi	s0,sp,80
    800043e4:	84aa                	mv	s1,a0
    800043e6:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800043e8:	d60fd0ef          	jal	80001948 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    800043ec:	409c                	lw	a5,0(s1)
    800043ee:	37f9                	addiw	a5,a5,-2
    800043f0:	4705                	li	a4,1
    800043f2:	04f76963          	bltu	a4,a5,80004444 <filestat+0x6c>
    800043f6:	f84a                	sd	s2,48(sp)
    800043f8:	f44e                	sd	s3,40(sp)
    800043fa:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    800043fc:	fb840993          	addi	s3,s0,-72
    80004400:	4661                	li	a2,24
    80004402:	4581                	li	a1,0
    80004404:	854e                	mv	a0,s3
    80004406:	8e3fc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    8000440a:	6c88                	ld	a0,24(s1)
    8000440c:	fd9fe0ef          	jal	800033e4 <ilock>
    stati(f->ip, &st);
    80004410:	85ce                	mv	a1,s3
    80004412:	6c88                	ld	a0,24(s1)
    80004414:	b7cff0ef          	jal	80003790 <stati>
    iunlock(f->ip);
    80004418:	6c88                	ld	a0,24(s1)
    8000441a:	878ff0ef          	jal	80003492 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    8000441e:	4761                	li	a4,24
    80004420:	86ce                	mv	a3,s3
    80004422:	8652                	mv	a2,s4
    80004424:	04893583          	ld	a1,72(s2)
    80004428:	05093503          	ld	a0,80(s2)
    8000442c:	956fd0ef          	jal	80001582 <copyout>
    80004430:	41f5551b          	sraiw	a0,a0,0x1f
    80004434:	7942                	ld	s2,48(sp)
    80004436:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004438:	60a6                	ld	ra,72(sp)
    8000443a:	6406                	ld	s0,64(sp)
    8000443c:	74e2                	ld	s1,56(sp)
    8000443e:	7a02                	ld	s4,32(sp)
    80004440:	6161                	addi	sp,sp,80
    80004442:	8082                	ret
  return -1;
    80004444:	557d                	li	a0,-1
    80004446:	bfcd                	j	80004438 <filestat+0x60>

0000000080004448 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004448:	7179                	addi	sp,sp,-48
    8000444a:	f406                	sd	ra,40(sp)
    8000444c:	f022                	sd	s0,32(sp)
    8000444e:	e84a                	sd	s2,16(sp)
    80004450:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    80004452:	00854783          	lbu	a5,8(a0)
    80004456:	c3dd                	beqz	a5,800044fc <fileread+0xb4>
    80004458:	ec26                	sd	s1,24(sp)
    8000445a:	e44e                	sd	s3,8(sp)
    8000445c:	84aa                	mv	s1,a0
    8000445e:	892e                	mv	s2,a1
    80004460:	89b2                	mv	s3,a2
    80004462:	01f6579b          	srliw	a5,a2,0x1f
    80004466:	ebc9                	bnez	a5,800044f8 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    80004468:	411c                	lw	a5,0(a0)
    8000446a:	4705                	li	a4,1
    8000446c:	04e78363          	beq	a5,a4,800044b2 <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004470:	470d                	li	a4,3
    80004472:	04e78763          	beq	a5,a4,800044c0 <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004476:	4709                	li	a4,2
    80004478:	06e79a63          	bne	a5,a4,800044ec <fileread+0xa4>
    ilock(f->ip);
    8000447c:	6d08                	ld	a0,24(a0)
    8000447e:	f67fe0ef          	jal	800033e4 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004482:	874e                	mv	a4,s3
    80004484:	5094                	lw	a3,32(s1)
    80004486:	864a                	mv	a2,s2
    80004488:	4585                	li	a1,1
    8000448a:	6c88                	ld	a0,24(s1)
    8000448c:	b32ff0ef          	jal	800037be <readi>
    80004490:	892a                	mv	s2,a0
    80004492:	00a05563          	blez	a0,8000449c <fileread+0x54>
      f->off += r;
    80004496:	509c                	lw	a5,32(s1)
    80004498:	9fa9                	addw	a5,a5,a0
    8000449a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000449c:	6c88                	ld	a0,24(s1)
    8000449e:	ff5fe0ef          	jal	80003492 <iunlock>
    800044a2:	64e2                	ld	s1,24(sp)
    800044a4:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800044a6:	854a                	mv	a0,s2
    800044a8:	70a2                	ld	ra,40(sp)
    800044aa:	7402                	ld	s0,32(sp)
    800044ac:	6942                	ld	s2,16(sp)
    800044ae:	6145                	addi	sp,sp,48
    800044b0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800044b2:	6908                	ld	a0,16(a0)
    800044b4:	3e2000ef          	jal	80004896 <piperead>
    800044b8:	892a                	mv	s2,a0
    800044ba:	64e2                	ld	s1,24(sp)
    800044bc:	69a2                	ld	s3,8(sp)
    800044be:	b7e5                	j	800044a6 <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800044c0:	02451783          	lh	a5,36(a0)
    800044c4:	03079693          	slli	a3,a5,0x30
    800044c8:	92c1                	srli	a3,a3,0x30
    800044ca:	4725                	li	a4,9
    800044cc:	02d76b63          	bltu	a4,a3,80004502 <fileread+0xba>
    800044d0:	0792                	slli	a5,a5,0x4
    800044d2:	0001e717          	auipc	a4,0x1e
    800044d6:	23e70713          	addi	a4,a4,574 # 80022710 <devsw>
    800044da:	97ba                	add	a5,a5,a4
    800044dc:	639c                	ld	a5,0(a5)
    800044de:	c79d                	beqz	a5,8000450c <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    800044e0:	4505                	li	a0,1
    800044e2:	9782                	jalr	a5
    800044e4:	892a                	mv	s2,a0
    800044e6:	64e2                	ld	s1,24(sp)
    800044e8:	69a2                	ld	s3,8(sp)
    800044ea:	bf75                	j	800044a6 <fileread+0x5e>
    panic("fileread");
    800044ec:	00003517          	auipc	a0,0x3
    800044f0:	0ac50513          	addi	a0,a0,172 # 80007598 <etext+0x598>
    800044f4:	b40fc0ef          	jal	80000834 <panic>
    800044f8:	64e2                	ld	s1,24(sp)
    800044fa:	69a2                	ld	s3,8(sp)
    return -1;
    800044fc:	57fd                	li	a5,-1
    800044fe:	893e                	mv	s2,a5
    80004500:	b75d                	j	800044a6 <fileread+0x5e>
      return -1;
    80004502:	57fd                	li	a5,-1
    80004504:	893e                	mv	s2,a5
    80004506:	64e2                	ld	s1,24(sp)
    80004508:	69a2                	ld	s3,8(sp)
    8000450a:	bf71                	j	800044a6 <fileread+0x5e>
    8000450c:	57fd                	li	a5,-1
    8000450e:	893e                	mv	s2,a5
    80004510:	64e2                	ld	s1,24(sp)
    80004512:	69a2                	ld	s3,8(sp)
    80004514:	bf49                	j	800044a6 <fileread+0x5e>

0000000080004516 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    80004516:	00954783          	lbu	a5,9(a0)
    8000451a:	12078b63          	beqz	a5,80004650 <filewrite+0x13a>
{
    8000451e:	711d                	addi	sp,sp,-96
    80004520:	ec86                	sd	ra,88(sp)
    80004522:	e8a2                	sd	s0,80(sp)
    80004524:	e0ca                	sd	s2,64(sp)
    80004526:	f456                	sd	s5,40(sp)
    80004528:	f05a                	sd	s6,32(sp)
    8000452a:	1080                	addi	s0,sp,96
    8000452c:	892a                	mv	s2,a0
    8000452e:	8b2e                	mv	s6,a1
    80004530:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    80004532:	01f6579b          	srliw	a5,a2,0x1f
    80004536:	0e079d63          	bnez	a5,80004630 <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    8000453a:	411c                	lw	a5,0(a0)
    8000453c:	4705                	li	a4,1
    8000453e:	02e78a63          	beq	a5,a4,80004572 <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004542:	470d                	li	a4,3
    80004544:	02e78b63          	beq	a5,a4,8000457a <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004548:	4709                	li	a4,2
    8000454a:	0ce79763          	bne	a5,a4,80004618 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    8000454e:	0ec05763          	blez	a2,8000463c <filewrite+0x126>
    80004552:	e4a6                	sd	s1,72(sp)
    80004554:	fc4e                	sd	s3,56(sp)
    80004556:	f852                	sd	s4,48(sp)
    80004558:	ec5e                	sd	s7,24(sp)
    8000455a:	e862                	sd	s8,16(sp)
    8000455c:	e466                	sd	s9,8(sp)
    int i = 0;
    8000455e:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    80004560:	6b85                	lui	s7,0x1
    80004562:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004566:	6785                	lui	a5,0x1
    80004568:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    8000456c:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000456e:	4c05                	li	s8,1
    80004570:	a8ad                	j	800045ea <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    80004572:	6908                	ld	a0,16(a0)
    80004574:	206000ef          	jal	8000477a <pipewrite>
    80004578:	a849                	j	8000460a <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000457a:	02451783          	lh	a5,36(a0)
    8000457e:	03079693          	slli	a3,a5,0x30
    80004582:	92c1                	srli	a3,a3,0x30
    80004584:	4725                	li	a4,9
    80004586:	0ad76763          	bltu	a4,a3,80004634 <filewrite+0x11e>
    8000458a:	0792                	slli	a5,a5,0x4
    8000458c:	0001e717          	auipc	a4,0x1e
    80004590:	18470713          	addi	a4,a4,388 # 80022710 <devsw>
    80004594:	97ba                	add	a5,a5,a4
    80004596:	679c                	ld	a5,8(a5)
    80004598:	c3c5                	beqz	a5,80004638 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000459a:	4505                	li	a0,1
    8000459c:	9782                	jalr	a5
    8000459e:	a0b5                	j	8000460a <filewrite+0xf4>
      if (n1 > max)
    800045a0:	2981                	sext.w	s3,s3
      begin_op();
    800045a2:	8bbff0ef          	jal	80003e5c <begin_op>
      ilock(f->ip);
    800045a6:	01893503          	ld	a0,24(s2)
    800045aa:	e3bfe0ef          	jal	800033e4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800045ae:	874e                	mv	a4,s3
    800045b0:	02092683          	lw	a3,32(s2)
    800045b4:	016a0633          	add	a2,s4,s6
    800045b8:	85e2                	mv	a1,s8
    800045ba:	01893503          	ld	a0,24(s2)
    800045be:	af2ff0ef          	jal	800038b0 <writei>
    800045c2:	84aa                	mv	s1,a0
    800045c4:	00a05763          	blez	a0,800045d2 <filewrite+0xbc>
        f->off += r;
    800045c8:	02092783          	lw	a5,32(s2)
    800045cc:	9fa9                	addw	a5,a5,a0
    800045ce:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800045d2:	01893503          	ld	a0,24(s2)
    800045d6:	ebdfe0ef          	jal	80003492 <iunlock>
      end_op();
    800045da:	90fff0ef          	jal	80003ee8 <end_op>

      if (r != n1) {
    800045de:	00999d63          	bne	s3,s1,800045f8 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    800045e2:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    800045e6:	015a5963          	bge	s4,s5,800045f8 <filewrite+0xe2>
      int n1 = n - i;
    800045ea:	414a87bb          	subw	a5,s5,s4
    800045ee:	89be                	mv	s3,a5
      if (n1 > max)
    800045f0:	fafbd8e3          	bge	s7,a5,800045a0 <filewrite+0x8a>
    800045f4:	89e6                	mv	s3,s9
    800045f6:	b76d                	j	800045a0 <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    800045f8:	054a9463          	bne	s5,s4,80004640 <filewrite+0x12a>
    800045fc:	8556                	mv	a0,s5
    800045fe:	64a6                	ld	s1,72(sp)
    80004600:	79e2                	ld	s3,56(sp)
    80004602:	7a42                	ld	s4,48(sp)
    80004604:	6be2                	ld	s7,24(sp)
    80004606:	6c42                	ld	s8,16(sp)
    80004608:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000460a:	60e6                	ld	ra,88(sp)
    8000460c:	6446                	ld	s0,80(sp)
    8000460e:	6906                	ld	s2,64(sp)
    80004610:	7aa2                	ld	s5,40(sp)
    80004612:	7b02                	ld	s6,32(sp)
    80004614:	6125                	addi	sp,sp,96
    80004616:	8082                	ret
    80004618:	e4a6                	sd	s1,72(sp)
    8000461a:	fc4e                	sd	s3,56(sp)
    8000461c:	f852                	sd	s4,48(sp)
    8000461e:	ec5e                	sd	s7,24(sp)
    80004620:	e862                	sd	s8,16(sp)
    80004622:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004624:	00003517          	auipc	a0,0x3
    80004628:	f8450513          	addi	a0,a0,-124 # 800075a8 <etext+0x5a8>
    8000462c:	a08fc0ef          	jal	80000834 <panic>
    return -1;
    80004630:	557d                	li	a0,-1
    80004632:	bfe1                	j	8000460a <filewrite+0xf4>
      return -1;
    80004634:	557d                	li	a0,-1
    80004636:	bfd1                	j	8000460a <filewrite+0xf4>
    80004638:	557d                	li	a0,-1
    8000463a:	bfc1                	j	8000460a <filewrite+0xf4>
    ret = (i == n ? n : -1);
    8000463c:	8532                	mv	a0,a2
    8000463e:	b7f1                	j	8000460a <filewrite+0xf4>
    80004640:	557d                	li	a0,-1
    80004642:	64a6                	ld	s1,72(sp)
    80004644:	79e2                	ld	s3,56(sp)
    80004646:	7a42                	ld	s4,48(sp)
    80004648:	6be2                	ld	s7,24(sp)
    8000464a:	6c42                	ld	s8,16(sp)
    8000464c:	6ca2                	ld	s9,8(sp)
    8000464e:	bf75                	j	8000460a <filewrite+0xf4>
    return -1;
    80004650:	557d                	li	a0,-1
}
    80004652:	8082                	ret

0000000080004654 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004654:	7179                	addi	sp,sp,-48
    80004656:	f406                	sd	ra,40(sp)
    80004658:	f022                	sd	s0,32(sp)
    8000465a:	ec26                	sd	s1,24(sp)
    8000465c:	e052                	sd	s4,0(sp)
    8000465e:	1800                	addi	s0,sp,48
    80004660:	84aa                	mv	s1,a0
    80004662:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004664:	0005b023          	sd	zero,0(a1)
    80004668:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000466c:	c07ff0ef          	jal	80004272 <filealloc>
    80004670:	e088                	sd	a0,0(s1)
    80004672:	c549                	beqz	a0,800046fc <pipealloc+0xa8>
    80004674:	bffff0ef          	jal	80004272 <filealloc>
    80004678:	00aa3023          	sd	a0,0(s4)
    8000467c:	cd25                	beqz	a0,800046f4 <pipealloc+0xa0>
    8000467e:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004680:	ccefc0ef          	jal	80000b4e <kalloc>
    80004684:	892a                	mv	s2,a0
    80004686:	c12d                	beqz	a0,800046e8 <pipealloc+0x94>
    80004688:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000468a:	4985                	li	s3,1
    8000468c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004690:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004694:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004698:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000469c:	00003597          	auipc	a1,0x3
    800046a0:	f1c58593          	addi	a1,a1,-228 # 800075b8 <etext+0x5b8>
    800046a4:	d04fc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    800046a8:	609c                	ld	a5,0(s1)
    800046aa:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800046ae:	609c                	ld	a5,0(s1)
    800046b0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800046b4:	609c                	ld	a5,0(s1)
    800046b6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800046ba:	609c                	ld	a5,0(s1)
    800046bc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800046c0:	000a3783          	ld	a5,0(s4)
    800046c4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800046c8:	000a3783          	ld	a5,0(s4)
    800046cc:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800046d0:	000a3783          	ld	a5,0(s4)
    800046d4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800046d8:	000a3783          	ld	a5,0(s4)
    800046dc:	0127b823          	sd	s2,16(a5)
  return 0;
    800046e0:	4501                	li	a0,0
    800046e2:	6942                	ld	s2,16(sp)
    800046e4:	69a2                	ld	s3,8(sp)
    800046e6:	a01d                	j	8000470c <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    800046e8:	6088                	ld	a0,0(s1)
    800046ea:	c119                	beqz	a0,800046f0 <pipealloc+0x9c>
    800046ec:	6942                	ld	s2,16(sp)
    800046ee:	a029                	j	800046f8 <pipealloc+0xa4>
    800046f0:	6942                	ld	s2,16(sp)
    800046f2:	a029                	j	800046fc <pipealloc+0xa8>
    800046f4:	6088                	ld	a0,0(s1)
    800046f6:	c10d                	beqz	a0,80004718 <pipealloc+0xc4>
    fileclose(*f0);
    800046f8:	c1fff0ef          	jal	80004316 <fileclose>
  if (*f1)
    800046fc:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004700:	557d                	li	a0,-1
  if (*f1)
    80004702:	c789                	beqz	a5,8000470c <pipealloc+0xb8>
    fileclose(*f1);
    80004704:	853e                	mv	a0,a5
    80004706:	c11ff0ef          	jal	80004316 <fileclose>
  return -1;
    8000470a:	557d                	li	a0,-1
}
    8000470c:	70a2                	ld	ra,40(sp)
    8000470e:	7402                	ld	s0,32(sp)
    80004710:	64e2                	ld	s1,24(sp)
    80004712:	6a02                	ld	s4,0(sp)
    80004714:	6145                	addi	sp,sp,48
    80004716:	8082                	ret
  return -1;
    80004718:	557d                	li	a0,-1
    8000471a:	bfcd                	j	8000470c <pipealloc+0xb8>

000000008000471c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000471c:	1101                	addi	sp,sp,-32
    8000471e:	ec06                	sd	ra,24(sp)
    80004720:	e822                	sd	s0,16(sp)
    80004722:	e426                	sd	s1,8(sp)
    80004724:	e04a                	sd	s2,0(sp)
    80004726:	1000                	addi	s0,sp,32
    80004728:	84aa                	mv	s1,a0
    8000472a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000472c:	cfcfc0ef          	jal	80000c28 <acquire>
  if (writable) {
    80004730:	02090763          	beqz	s2,8000475e <pipeclose+0x42>
    pi->writeopen = 0;
    80004734:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004738:	21848513          	addi	a0,s1,536
    8000473c:	9cffd0ef          	jal	8000210a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004740:	2204a783          	lw	a5,544(s1)
    80004744:	e781                	bnez	a5,8000474c <pipeclose+0x30>
    80004746:	2244a783          	lw	a5,548(s1)
    8000474a:	c38d                	beqz	a5,8000476c <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    8000474c:	8526                	mv	a0,s1
    8000474e:	d62fc0ef          	jal	80000cb0 <release>
}
    80004752:	60e2                	ld	ra,24(sp)
    80004754:	6442                	ld	s0,16(sp)
    80004756:	64a2                	ld	s1,8(sp)
    80004758:	6902                	ld	s2,0(sp)
    8000475a:	6105                	addi	sp,sp,32
    8000475c:	8082                	ret
    pi->readopen = 0;
    8000475e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004762:	21c48513          	addi	a0,s1,540
    80004766:	9a5fd0ef          	jal	8000210a <wakeup>
    8000476a:	bfd9                	j	80004740 <pipeclose+0x24>
    release(&pi->lock);
    8000476c:	8526                	mv	a0,s1
    8000476e:	d42fc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    80004772:	8526                	mv	a0,s1
    80004774:	af2fc0ef          	jal	80000a66 <kfree>
    80004778:	bfe9                	j	80004752 <pipeclose+0x36>

000000008000477a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000477a:	7159                	addi	sp,sp,-112
    8000477c:	f486                	sd	ra,104(sp)
    8000477e:	f0a2                	sd	s0,96(sp)
    80004780:	eca6                	sd	s1,88(sp)
    80004782:	e8ca                	sd	s2,80(sp)
    80004784:	e4ce                	sd	s3,72(sp)
    80004786:	e0d2                	sd	s4,64(sp)
    80004788:	fc56                	sd	s5,56(sp)
    8000478a:	1880                	addi	s0,sp,112
    8000478c:	84aa                	mv	s1,a0
    8000478e:	8aae                	mv	s5,a1
    80004790:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004792:	9b6fd0ef          	jal	80001948 <myproc>
    80004796:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004798:	8526                	mv	a0,s1
    8000479a:	c8efc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    8000479e:	0f405a63          	blez	s4,80004892 <pipewrite+0x118>
    800047a2:	f85a                	sd	s6,48(sp)
    800047a4:	f45e                	sd	s7,40(sp)
    800047a6:	f062                	sd	s8,32(sp)
    800047a8:	ec66                	sd	s9,24(sp)
    800047aa:	e86a                	sd	s10,16(sp)
  int i = 0;
    800047ac:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800047ae:	f9f40c13          	addi	s8,s0,-97
    800047b2:	4b85                	li	s7,1
    800047b4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800047b6:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    800047ba:	21c48c93          	addi	s9,s1,540
    800047be:	a0a1                	j	80004806 <pipewrite+0x8c>
      release(&pi->lock);
    800047c0:	8526                	mv	a0,s1
    800047c2:	ceefc0ef          	jal	80000cb0 <release>
      return -1;
    800047c6:	597d                	li	s2,-1
    800047c8:	7b42                	ld	s6,48(sp)
    800047ca:	7ba2                	ld	s7,40(sp)
    800047cc:	7c02                	ld	s8,32(sp)
    800047ce:	6ce2                	ld	s9,24(sp)
    800047d0:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800047d2:	854a                	mv	a0,s2
    800047d4:	70a6                	ld	ra,104(sp)
    800047d6:	7406                	ld	s0,96(sp)
    800047d8:	64e6                	ld	s1,88(sp)
    800047da:	6946                	ld	s2,80(sp)
    800047dc:	69a6                	ld	s3,72(sp)
    800047de:	6a06                	ld	s4,64(sp)
    800047e0:	7ae2                	ld	s5,56(sp)
    800047e2:	6165                	addi	sp,sp,112
    800047e4:	8082                	ret
      wakeup(&pi->nread);
    800047e6:	856a                	mv	a0,s10
    800047e8:	923fd0ef          	jal	8000210a <wakeup>
      sleep_prepare(&pi->nwrite);
    800047ec:	8566                	mv	a0,s9
    800047ee:	8adfd0ef          	jal	8000209a <sleep_prepare>
      release(&pi->lock);
    800047f2:	8526                	mv	a0,s1
    800047f4:	cbcfc0ef          	jal	80000cb0 <release>
      sleep();
    800047f8:	8dffd0ef          	jal	800020d6 <sleep>
      acquire(&pi->lock);
    800047fc:	8526                	mv	a0,s1
    800047fe:	c2afc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    80004802:	07495b63          	bge	s2,s4,80004878 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    80004806:	2204a783          	lw	a5,544(s1)
    8000480a:	dbdd                	beqz	a5,800047c0 <pipewrite+0x46>
    8000480c:	854e                	mv	a0,s3
    8000480e:	aeffd0ef          	jal	800022fc <killed>
    80004812:	f55d                	bnez	a0,800047c0 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    80004814:	2184a783          	lw	a5,536(s1)
    80004818:	21c4a703          	lw	a4,540(s1)
    8000481c:	2007879b          	addiw	a5,a5,512
    80004820:	fcf703e3          	beq	a4,a5,800047e6 <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004824:	875e                	mv	a4,s7
    80004826:	015906b3          	add	a3,s2,s5
    8000482a:	8662                	mv	a2,s8
    8000482c:	0489b583          	ld	a1,72(s3)
    80004830:	0509b503          	ld	a0,80(s3)
    80004834:	e15fc0ef          	jal	80001648 <copyin>
    80004838:	03650163          	beq	a0,s6,8000485a <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000483c:	21c4a783          	lw	a5,540(s1)
    80004840:	0017871b          	addiw	a4,a5,1
    80004844:	20e4ae23          	sw	a4,540(s1)
    80004848:	1ff7f793          	andi	a5,a5,511
    8000484c:	97a6                	add	a5,a5,s1
    8000484e:	f9f44703          	lbu	a4,-97(s0)
    80004852:	00e78c23          	sb	a4,24(a5)
      i++;
    80004856:	2905                	addiw	s2,s2,1
    80004858:	b76d                	j	80004802 <pipewrite+0x88>
        if (i == 0)
    8000485a:	00090863          	beqz	s2,8000486a <pipewrite+0xf0>
    8000485e:	7b42                	ld	s6,48(sp)
    80004860:	7ba2                	ld	s7,40(sp)
    80004862:	7c02                	ld	s8,32(sp)
    80004864:	6ce2                	ld	s9,24(sp)
    80004866:	6d42                	ld	s10,16(sp)
    80004868:	a829                	j	80004882 <pipewrite+0x108>
          i = -1;
    8000486a:	892a                	mv	s2,a0
        break;
    8000486c:	7b42                	ld	s6,48(sp)
    8000486e:	7ba2                	ld	s7,40(sp)
    80004870:	7c02                	ld	s8,32(sp)
    80004872:	6ce2                	ld	s9,24(sp)
    80004874:	6d42                	ld	s10,16(sp)
    80004876:	a031                	j	80004882 <pipewrite+0x108>
    80004878:	7b42                	ld	s6,48(sp)
    8000487a:	7ba2                	ld	s7,40(sp)
    8000487c:	7c02                	ld	s8,32(sp)
    8000487e:	6ce2                	ld	s9,24(sp)
    80004880:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004882:	21848513          	addi	a0,s1,536
    80004886:	885fd0ef          	jal	8000210a <wakeup>
  release(&pi->lock);
    8000488a:	8526                	mv	a0,s1
    8000488c:	c24fc0ef          	jal	80000cb0 <release>
  return i;
    80004890:	b789                	j	800047d2 <pipewrite+0x58>
  int i = 0;
    80004892:	4901                	li	s2,0
    80004894:	b7fd                	j	80004882 <pipewrite+0x108>

0000000080004896 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004896:	711d                	addi	sp,sp,-96
    80004898:	ec86                	sd	ra,88(sp)
    8000489a:	e8a2                	sd	s0,80(sp)
    8000489c:	e4a6                	sd	s1,72(sp)
    8000489e:	e0ca                	sd	s2,64(sp)
    800048a0:	fc4e                	sd	s3,56(sp)
    800048a2:	f852                	sd	s4,48(sp)
    800048a4:	f456                	sd	s5,40(sp)
    800048a6:	1080                	addi	s0,sp,96
    800048a8:	84aa                	mv	s1,a0
    800048aa:	89ae                	mv	s3,a1
    800048ac:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800048ae:	89afd0ef          	jal	80001948 <myproc>
    800048b2:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    800048b4:	8526                	mv	a0,s1
    800048b6:	b72fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048ba:	0d505263          	blez	s5,8000497e <piperead+0xe8>
    800048be:	2184a703          	lw	a4,536(s1)
    800048c2:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800048c6:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048ca:	02f71e63          	bne	a4,a5,80004906 <piperead+0x70>
    800048ce:	2244a783          	lw	a5,548(s1)
    800048d2:	c3b9                	beqz	a5,80004918 <piperead+0x82>
    if (killed(pr)) {
    800048d4:	854a                	mv	a0,s2
    800048d6:	a27fd0ef          	jal	800022fc <killed>
    800048da:	e915                	bnez	a0,8000490e <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800048dc:	8552                	mv	a0,s4
    800048de:	fbcfd0ef          	jal	8000209a <sleep_prepare>
    release(&pi->lock);
    800048e2:	8526                	mv	a0,s1
    800048e4:	bccfc0ef          	jal	80000cb0 <release>
    sleep();
    800048e8:	feefd0ef          	jal	800020d6 <sleep>
    acquire(&pi->lock);
    800048ec:	8526                	mv	a0,s1
    800048ee:	b3afc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048f2:	2184a703          	lw	a4,536(s1)
    800048f6:	21c4a783          	lw	a5,540(s1)
    800048fa:	fcf70ae3          	beq	a4,a5,800048ce <piperead+0x38>
    800048fe:	f05a                	sd	s6,32(sp)
    80004900:	ec5e                	sd	s7,24(sp)
    80004902:	e862                	sd	s8,16(sp)
    80004904:	a829                	j	8000491e <piperead+0x88>
    80004906:	f05a                	sd	s6,32(sp)
    80004908:	ec5e                	sd	s7,24(sp)
    8000490a:	e862                	sd	s8,16(sp)
    8000490c:	a809                	j	8000491e <piperead+0x88>
      release(&pi->lock);
    8000490e:	8526                	mv	a0,s1
    80004910:	ba0fc0ef          	jal	80000cb0 <release>
      return -1;
    80004914:	5a7d                	li	s4,-1
    80004916:	a8a5                	j	8000498e <piperead+0xf8>
    80004918:	f05a                	sd	s6,32(sp)
    8000491a:	ec5e                	sd	s7,24(sp)
    8000491c:	e862                	sd	s8,16(sp)
{
    8000491e:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004920:	faf40c13          	addi	s8,s0,-81
    80004924:	4b85                	li	s7,1
    80004926:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    80004928:	2184a783          	lw	a5,536(s1)
    8000492c:	21c4a703          	lw	a4,540(s1)
    80004930:	06f70e63          	beq	a4,a5,800049ac <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    80004934:	1ff7f793          	andi	a5,a5,511
    80004938:	97a6                	add	a5,a5,s1
    8000493a:	0187c783          	lbu	a5,24(a5)
    8000493e:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004942:	875e                	mv	a4,s7
    80004944:	86e2                	mv	a3,s8
    80004946:	864e                	mv	a2,s3
    80004948:	04893583          	ld	a1,72(s2)
    8000494c:	05093503          	ld	a0,80(s2)
    80004950:	c33fc0ef          	jal	80001582 <copyout>
    80004954:	01650f63          	beq	a0,s6,80004972 <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004958:	2184a783          	lw	a5,536(s1)
    8000495c:	2785                	addiw	a5,a5,1
    8000495e:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004962:	2a05                	addiw	s4,s4,1
    80004964:	0985                	addi	s3,s3,1
    80004966:	fd4a91e3          	bne	s5,s4,80004928 <piperead+0x92>
    8000496a:	7b02                	ld	s6,32(sp)
    8000496c:	6be2                	ld	s7,24(sp)
    8000496e:	6c42                	ld	s8,16(sp)
    80004970:	a801                	j	80004980 <piperead+0xea>
      if (i == 0)
    80004972:	020a0863          	beqz	s4,800049a2 <piperead+0x10c>
    80004976:	7b02                	ld	s6,32(sp)
    80004978:	6be2                	ld	s7,24(sp)
    8000497a:	6c42                	ld	s8,16(sp)
    8000497c:	a011                	j	80004980 <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000497e:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004980:	21c48513          	addi	a0,s1,540
    80004984:	f86fd0ef          	jal	8000210a <wakeup>
  release(&pi->lock);
    80004988:	8526                	mv	a0,s1
    8000498a:	b26fc0ef          	jal	80000cb0 <release>
  return i;
}
    8000498e:	8552                	mv	a0,s4
    80004990:	60e6                	ld	ra,88(sp)
    80004992:	6446                	ld	s0,80(sp)
    80004994:	64a6                	ld	s1,72(sp)
    80004996:	6906                	ld	s2,64(sp)
    80004998:	79e2                	ld	s3,56(sp)
    8000499a:	7a42                	ld	s4,48(sp)
    8000499c:	7aa2                	ld	s5,40(sp)
    8000499e:	6125                	addi	sp,sp,96
    800049a0:	8082                	ret
        i = -1;
    800049a2:	8a2a                	mv	s4,a0
    800049a4:	7b02                	ld	s6,32(sp)
    800049a6:	6be2                	ld	s7,24(sp)
    800049a8:	6c42                	ld	s8,16(sp)
    800049aa:	bfd9                	j	80004980 <piperead+0xea>
    800049ac:	7b02                	ld	s6,32(sp)
    800049ae:	6be2                	ld	s7,24(sp)
    800049b0:	6c42                	ld	s8,16(sp)
    800049b2:	b7f9                	j	80004980 <piperead+0xea>

00000000800049b4 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    800049b4:	1141                	addi	sp,sp,-16
    800049b6:	e406                	sd	ra,8(sp)
    800049b8:	e022                	sd	s0,0(sp)
    800049ba:	0800                	addi	s0,sp,16
    800049bc:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800049be:	0035151b          	slliw	a0,a0,0x3
    800049c2:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    800049c4:	8b89                	andi	a5,a5,2
    800049c6:	c399                	beqz	a5,800049cc <flags2perm+0x18>
    perm |= PTE_W;
    800049c8:	00456513          	ori	a0,a0,4
  return perm;
}
    800049cc:	60a2                	ld	ra,8(sp)
    800049ce:	6402                	ld	s0,0(sp)
    800049d0:	0141                	addi	sp,sp,16
    800049d2:	8082                	ret

00000000800049d4 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800049d4:	de010113          	addi	sp,sp,-544
    800049d8:	20113c23          	sd	ra,536(sp)
    800049dc:	20813823          	sd	s0,528(sp)
    800049e0:	20913423          	sd	s1,520(sp)
    800049e4:	21213023          	sd	s2,512(sp)
    800049e8:	1400                	addi	s0,sp,544
    800049ea:	892a                	mv	s2,a0
    800049ec:	dea43823          	sd	a0,-528(s0)
    800049f0:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800049f4:	f55fc0ef          	jal	80001948 <myproc>
    800049f8:	84aa                	mv	s1,a0

  begin_op();
    800049fa:	c62ff0ef          	jal	80003e5c <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    800049fe:	854a                	mv	a0,s2
    80004a00:	a7eff0ef          	jal	80003c7e <namei>
    80004a04:	cd21                	beqz	a0,80004a5c <kexec+0x88>
    80004a06:	fbd2                	sd	s4,496(sp)
    80004a08:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004a0a:	9dbfe0ef          	jal	800033e4 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004a0e:	04000713          	li	a4,64
    80004a12:	4681                	li	a3,0
    80004a14:	e5040613          	addi	a2,s0,-432
    80004a18:	4581                	li	a1,0
    80004a1a:	8552                	mv	a0,s4
    80004a1c:	da3fe0ef          	jal	800037be <readi>
    80004a20:	04000793          	li	a5,64
    80004a24:	00f51a63          	bne	a0,a5,80004a38 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004a28:	e5042703          	lw	a4,-432(s0)
    80004a2c:	464c47b7          	lui	a5,0x464c4
    80004a30:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a34:	02f70863          	beq	a4,a5,80004a64 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004a38:	8552                	mv	a0,s4
    80004a3a:	bfffe0ef          	jal	80003638 <iunlockput>
    end_op();
    80004a3e:	caaff0ef          	jal	80003ee8 <end_op>
  }
  return -1;
    80004a42:	557d                	li	a0,-1
    80004a44:	7a5e                	ld	s4,496(sp)
}
    80004a46:	21813083          	ld	ra,536(sp)
    80004a4a:	21013403          	ld	s0,528(sp)
    80004a4e:	20813483          	ld	s1,520(sp)
    80004a52:	20013903          	ld	s2,512(sp)
    80004a56:	22010113          	addi	sp,sp,544
    80004a5a:	8082                	ret
    end_op();
    80004a5c:	c8cff0ef          	jal	80003ee8 <end_op>
    return -1;
    80004a60:	557d                	li	a0,-1
    80004a62:	b7d5                	j	80004a46 <kexec+0x72>
    80004a64:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004a66:	8526                	mv	a0,s1
    80004a68:	fe7fc0ef          	jal	80001a4e <proc_pagetable>
    80004a6c:	8b2a                	mv	s6,a0
    80004a6e:	26050e63          	beqz	a0,80004cea <kexec+0x316>
    80004a72:	ffce                	sd	s3,504(sp)
    80004a74:	f7d6                	sd	s5,488(sp)
    80004a76:	efde                	sd	s7,472(sp)
    80004a78:	ebe2                	sd	s8,464(sp)
    80004a7a:	e7e6                	sd	s9,456(sp)
    80004a7c:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a7e:	e8845783          	lhu	a5,-376(s0)
    80004a82:	14078263          	beqz	a5,80004bc6 <kexec+0x1f2>
    80004a86:	ff6e                	sd	s11,440(sp)
    80004a88:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a8c:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a8e:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a90:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004a94:	6c85                	lui	s9,0x1
    80004a96:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004a9a:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004a9e:	6a85                	lui	s5,0x1
    80004aa0:	a085                	j	80004b00 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004aa2:	00003517          	auipc	a0,0x3
    80004aa6:	b1e50513          	addi	a0,a0,-1250 # 800075c0 <etext+0x5c0>
    80004aaa:	d8bfb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004aae:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004ab0:	874a                	mv	a4,s2
    80004ab2:	009b86bb          	addw	a3,s7,s1
    80004ab6:	4581                	li	a1,0
    80004ab8:	8552                	mv	a0,s4
    80004aba:	d05fe0ef          	jal	800037be <readi>
    80004abe:	22a91a63          	bne	s2,a0,80004cf2 <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004ac2:	009a84bb          	addw	s1,s5,s1
    80004ac6:	0334f263          	bgeu	s1,s3,80004aea <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004aca:	02049593          	slli	a1,s1,0x20
    80004ace:	9181                	srli	a1,a1,0x20
    80004ad0:	95e2                	add	a1,a1,s8
    80004ad2:	855a                	mv	a0,s6
    80004ad4:	d44fc0ef          	jal	80001018 <walkaddr>
    80004ad8:	862a                	mv	a2,a0
    if (pa == 0)
    80004ada:	d561                	beqz	a0,80004aa2 <kexec+0xce>
    if (sz - i < PGSIZE)
    80004adc:	409987bb          	subw	a5,s3,s1
    80004ae0:	893e                	mv	s2,a5
    80004ae2:	fcfcf6e3          	bgeu	s9,a5,80004aae <kexec+0xda>
    80004ae6:	8956                	mv	s2,s5
    80004ae8:	b7d9                	j	80004aae <kexec+0xda>
    sz = sz1;
    80004aea:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004aee:	2d05                	addiw	s10,s10,1
    80004af0:	e0843783          	ld	a5,-504(s0)
    80004af4:	0387869b          	addiw	a3,a5,56
    80004af8:	e8845783          	lhu	a5,-376(s0)
    80004afc:	06fd5d63          	bge	s10,a5,80004b76 <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004b00:	e0d43423          	sd	a3,-504(s0)
    80004b04:	876e                	mv	a4,s11
    80004b06:	e1840613          	addi	a2,s0,-488
    80004b0a:	4581                	li	a1,0
    80004b0c:	8552                	mv	a0,s4
    80004b0e:	cb1fe0ef          	jal	800037be <readi>
    80004b12:	1db51e63          	bne	a0,s11,80004cee <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004b16:	e1842783          	lw	a5,-488(s0)
    80004b1a:	4705                	li	a4,1
    80004b1c:	fce799e3          	bne	a5,a4,80004aee <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004b20:	e4043483          	ld	s1,-448(s0)
    80004b24:	e3843783          	ld	a5,-456(s0)
    80004b28:	1ef4e363          	bltu	s1,a5,80004d0e <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004b2c:	e2843783          	ld	a5,-472(s0)
    80004b30:	94be                	add	s1,s1,a5
    80004b32:	1ef4e163          	bltu	s1,a5,80004d14 <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004b36:	de843703          	ld	a4,-536(s0)
    80004b3a:	8ff9                	and	a5,a5,a4
    80004b3c:	1c079f63          	bnez	a5,80004d1a <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004b40:	e1c42503          	lw	a0,-484(s0)
    80004b44:	e71ff0ef          	jal	800049b4 <flags2perm>
    80004b48:	86aa                	mv	a3,a0
    80004b4a:	8626                	mv	a2,s1
    80004b4c:	85ca                	mv	a1,s2
    80004b4e:	855a                	mv	a0,s6
    80004b50:	f9efc0ef          	jal	800012ee <uvmalloc>
    80004b54:	dea43c23          	sd	a0,-520(s0)
    80004b58:	1c050463          	beqz	a0,80004d20 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b5c:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004b60:	00098863          	beqz	s3,80004b70 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b64:	e2843c03          	ld	s8,-472(s0)
    80004b68:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004b6c:	4481                	li	s1,0
    80004b6e:	bfb1                	j	80004aca <kexec+0xf6>
    sz = sz1;
    80004b70:	df843903          	ld	s2,-520(s0)
    80004b74:	bfad                	j	80004aee <kexec+0x11a>
    80004b76:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004b78:	8552                	mv	a0,s4
    80004b7a:	abffe0ef          	jal	80003638 <iunlockput>
  end_op();
    80004b7e:	b6aff0ef          	jal	80003ee8 <end_op>
  p = myproc();
    80004b82:	dc7fc0ef          	jal	80001948 <myproc>
    80004b86:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004b88:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004b8c:	6c05                	lui	s8,0x1
    80004b8e:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004b90:	9c4a                	add	s8,s8,s2
    80004b92:	77fd                	lui	a5,0xfffff
    80004b94:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004b98:	4691                	li	a3,4
    80004b9a:	6609                	lui	a2,0x2
    80004b9c:	9662                	add	a2,a2,s8
    80004b9e:	85e2                	mv	a1,s8
    80004ba0:	855a                	mv	a0,s6
    80004ba2:	f4cfc0ef          	jal	800012ee <uvmalloc>
    80004ba6:	892a                	mv	s2,a0
    80004ba8:	e10d                	bnez	a0,80004bca <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004baa:	85e2                	mv	a1,s8
    80004bac:	855a                	mv	a0,s6
    80004bae:	f25fc0ef          	jal	80001ad2 <proc_freepagetable>
  return -1;
    80004bb2:	557d                	li	a0,-1
    80004bb4:	79fe                	ld	s3,504(sp)
    80004bb6:	7a5e                	ld	s4,496(sp)
    80004bb8:	7abe                	ld	s5,488(sp)
    80004bba:	7b1e                	ld	s6,480(sp)
    80004bbc:	6bfe                	ld	s7,472(sp)
    80004bbe:	6c5e                	ld	s8,464(sp)
    80004bc0:	6cbe                	ld	s9,456(sp)
    80004bc2:	6d1e                	ld	s10,448(sp)
    80004bc4:	b549                	j	80004a46 <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004bc6:	4901                	li	s2,0
    80004bc8:	bf45                	j	80004b78 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004bca:	75f9                	lui	a1,0xffffe
    80004bcc:	95aa                	add	a1,a1,a0
    80004bce:	855a                	mv	a0,s6
    80004bd0:	8f1fc0ef          	jal	800014c0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004bd4:	80090a13          	addi	s4,s2,-2048
    80004bd8:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004bdc:	e0043783          	ld	a5,-512(s0)
    80004be0:	6388                	ld	a0,0(a5)
    80004be2:	c545                	beqz	a0,80004c8a <kexec+0x2b6>
  sp = sz;
    80004be4:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004be6:	4481                	li	s1,0
    ustack[argc] = sp;
    80004be8:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004bec:	a86fc0ef          	jal	80000e72 <strlen>
    80004bf0:	0015079b          	addiw	a5,a0,1
    80004bf4:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004bf8:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004bfc:	134c6563          	bltu	s8,s4,80004d26 <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004c00:	e0043d03          	ld	s10,-512(s0)
    80004c04:	000d3c83          	ld	s9,0(s10)
    80004c08:	8566                	mv	a0,s9
    80004c0a:	a68fc0ef          	jal	80000e72 <strlen>
    80004c0e:	0015071b          	addiw	a4,a0,1
    80004c12:	86e6                	mv	a3,s9
    80004c14:	8662                	mv	a2,s8
    80004c16:	85ca                	mv	a1,s2
    80004c18:	855a                	mv	a0,s6
    80004c1a:	969fc0ef          	jal	80001582 <copyout>
    80004c1e:	10054663          	bltz	a0,80004d2a <kexec+0x356>
    ustack[argc] = sp;
    80004c22:	00349793          	slli	a5,s1,0x3
    80004c26:	97de                	add	a5,a5,s7
    80004c28:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb758>
  for (argc = 0; argv[argc]; argc++) {
    80004c2c:	0485                	addi	s1,s1,1
    80004c2e:	008d0793          	addi	a5,s10,8
    80004c32:	e0f43023          	sd	a5,-512(s0)
    80004c36:	008d3503          	ld	a0,8(s10)
    80004c3a:	f94d                	bnez	a0,80004bec <kexec+0x218>
  ustack[argc] = 0;
    80004c3c:	00349793          	slli	a5,s1,0x3
    80004c40:	f9078793          	addi	a5,a5,-112
    80004c44:	97a2                	add	a5,a5,s0
    80004c46:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004c4a:	00349713          	slli	a4,s1,0x3
    80004c4e:	0721                	addi	a4,a4,8
    80004c50:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004c54:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004c58:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004c5a:	f54be8e3          	bltu	s7,s4,80004baa <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004c5e:	e9040693          	addi	a3,s0,-368
    80004c62:	865e                	mv	a2,s7
    80004c64:	85ca                	mv	a1,s2
    80004c66:	855a                	mv	a0,s6
    80004c68:	91bfc0ef          	jal	80001582 <copyout>
    80004c6c:	f2054fe3          	bltz	a0,80004baa <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004c70:	0589b783          	ld	a5,88(s3)
    80004c74:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004c78:	df043783          	ld	a5,-528(s0)
    80004c7c:	0007c703          	lbu	a4,0(a5)
    80004c80:	c30d                	beqz	a4,80004ca2 <kexec+0x2ce>
    80004c82:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004c84:	02f00693          	li	a3,47
    80004c88:	a801                	j	80004c98 <kexec+0x2c4>
  sp = sz;
    80004c8a:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004c8c:	4481                	li	s1,0
    80004c8e:	b77d                	j	80004c3c <kexec+0x268>
  for (last = s = path; *s; s++)
    80004c90:	0785                	addi	a5,a5,1
    80004c92:	fff7c703          	lbu	a4,-1(a5)
    80004c96:	c711                	beqz	a4,80004ca2 <kexec+0x2ce>
    if (*s == '/')
    80004c98:	fed71ce3          	bne	a4,a3,80004c90 <kexec+0x2bc>
      last = s + 1;
    80004c9c:	def43823          	sd	a5,-528(s0)
    80004ca0:	bfc5                	j	80004c90 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ca2:	4641                	li	a2,16
    80004ca4:	df043583          	ld	a1,-528(s0)
    80004ca8:	15898513          	addi	a0,s3,344
    80004cac:	990fc0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004cb0:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004cb4:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004cb8:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004cbc:	0589b783          	ld	a5,88(s3)
    80004cc0:	e6843703          	ld	a4,-408(s0)
    80004cc4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004cc6:	0589b783          	ld	a5,88(s3)
    80004cca:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004cce:	85d6                	mv	a1,s5
    80004cd0:	e03fc0ef          	jal	80001ad2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004cd4:	0004851b          	sext.w	a0,s1
    80004cd8:	79fe                	ld	s3,504(sp)
    80004cda:	7a5e                	ld	s4,496(sp)
    80004cdc:	7abe                	ld	s5,488(sp)
    80004cde:	7b1e                	ld	s6,480(sp)
    80004ce0:	6bfe                	ld	s7,472(sp)
    80004ce2:	6c5e                	ld	s8,464(sp)
    80004ce4:	6cbe                	ld	s9,456(sp)
    80004ce6:	6d1e                	ld	s10,448(sp)
    80004ce8:	bbb9                	j	80004a46 <kexec+0x72>
    80004cea:	7b1e                	ld	s6,480(sp)
    80004cec:	b3b1                	j	80004a38 <kexec+0x64>
    80004cee:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004cf2:	df843583          	ld	a1,-520(s0)
    80004cf6:	855a                	mv	a0,s6
    80004cf8:	ddbfc0ef          	jal	80001ad2 <proc_freepagetable>
  if (ip) {
    80004cfc:	79fe                	ld	s3,504(sp)
    80004cfe:	7abe                	ld	s5,488(sp)
    80004d00:	7b1e                	ld	s6,480(sp)
    80004d02:	6bfe                	ld	s7,472(sp)
    80004d04:	6c5e                	ld	s8,464(sp)
    80004d06:	6cbe                	ld	s9,456(sp)
    80004d08:	6d1e                	ld	s10,448(sp)
    80004d0a:	7dfa                	ld	s11,440(sp)
    80004d0c:	b335                	j	80004a38 <kexec+0x64>
    80004d0e:	df243c23          	sd	s2,-520(s0)
    80004d12:	b7c5                	j	80004cf2 <kexec+0x31e>
    80004d14:	df243c23          	sd	s2,-520(s0)
    80004d18:	bfe9                	j	80004cf2 <kexec+0x31e>
    80004d1a:	df243c23          	sd	s2,-520(s0)
    80004d1e:	bfd1                	j	80004cf2 <kexec+0x31e>
    80004d20:	df243c23          	sd	s2,-520(s0)
    80004d24:	b7f9                	j	80004cf2 <kexec+0x31e>
  sz = sz1;
    80004d26:	8c4a                	mv	s8,s2
    80004d28:	b549                	j	80004baa <kexec+0x1d6>
    80004d2a:	8c4a                	mv	s8,s2
    80004d2c:	bdbd                	j	80004baa <kexec+0x1d6>

0000000080004d2e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004d2e:	7179                	addi	sp,sp,-48
    80004d30:	f406                	sd	ra,40(sp)
    80004d32:	f022                	sd	s0,32(sp)
    80004d34:	ec26                	sd	s1,24(sp)
    80004d36:	e84a                	sd	s2,16(sp)
    80004d38:	1800                	addi	s0,sp,48
    80004d3a:	892e                	mv	s2,a1
    80004d3c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d3e:	fdc40593          	addi	a1,s0,-36
    80004d42:	ca7fd0ef          	jal	800029e8 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004d46:	fdc42703          	lw	a4,-36(s0)
    80004d4a:	47bd                	li	a5,15
    80004d4c:	02e7ea63          	bltu	a5,a4,80004d80 <argfd+0x52>
    80004d50:	bf9fc0ef          	jal	80001948 <myproc>
    80004d54:	fdc42703          	lw	a4,-36(s0)
    80004d58:	00371793          	slli	a5,a4,0x3
    80004d5c:	0d078793          	addi	a5,a5,208
    80004d60:	953e                	add	a0,a0,a5
    80004d62:	611c                	ld	a5,0(a0)
    80004d64:	c385                	beqz	a5,80004d84 <argfd+0x56>
    return -1;
  if (pfd)
    80004d66:	00090463          	beqz	s2,80004d6e <argfd+0x40>
    *pfd = fd;
    80004d6a:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004d6e:	4501                	li	a0,0
  if (pf)
    80004d70:	c091                	beqz	s1,80004d74 <argfd+0x46>
    *pf = f;
    80004d72:	e09c                	sd	a5,0(s1)
}
    80004d74:	70a2                	ld	ra,40(sp)
    80004d76:	7402                	ld	s0,32(sp)
    80004d78:	64e2                	ld	s1,24(sp)
    80004d7a:	6942                	ld	s2,16(sp)
    80004d7c:	6145                	addi	sp,sp,48
    80004d7e:	8082                	ret
    return -1;
    80004d80:	557d                	li	a0,-1
    80004d82:	bfcd                	j	80004d74 <argfd+0x46>
    80004d84:	557d                	li	a0,-1
    80004d86:	b7fd                	j	80004d74 <argfd+0x46>

0000000080004d88 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004d88:	1101                	addi	sp,sp,-32
    80004d8a:	ec06                	sd	ra,24(sp)
    80004d8c:	e822                	sd	s0,16(sp)
    80004d8e:	e426                	sd	s1,8(sp)
    80004d90:	1000                	addi	s0,sp,32
    80004d92:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004d94:	bb5fc0ef          	jal	80001948 <myproc>
    80004d98:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004d9a:	0d050793          	addi	a5,a0,208
    80004d9e:	4501                	li	a0,0
    80004da0:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004da2:	6398                	ld	a4,0(a5)
    80004da4:	cb19                	beqz	a4,80004dba <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004da6:	2505                	addiw	a0,a0,1
    80004da8:	07a1                	addi	a5,a5,8
    80004daa:	fed51ce3          	bne	a0,a3,80004da2 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004dae:	557d                	li	a0,-1
}
    80004db0:	60e2                	ld	ra,24(sp)
    80004db2:	6442                	ld	s0,16(sp)
    80004db4:	64a2                	ld	s1,8(sp)
    80004db6:	6105                	addi	sp,sp,32
    80004db8:	8082                	ret
      p->ofile[fd] = f;
    80004dba:	00351793          	slli	a5,a0,0x3
    80004dbe:	0d078793          	addi	a5,a5,208
    80004dc2:	963e                	add	a2,a2,a5
    80004dc4:	e204                	sd	s1,0(a2)
      return fd;
    80004dc6:	b7ed                	j	80004db0 <fdalloc+0x28>

0000000080004dc8 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004dc8:	715d                	addi	sp,sp,-80
    80004dca:	e486                	sd	ra,72(sp)
    80004dcc:	e0a2                	sd	s0,64(sp)
    80004dce:	fc26                	sd	s1,56(sp)
    80004dd0:	f84a                	sd	s2,48(sp)
    80004dd2:	f052                	sd	s4,32(sp)
    80004dd4:	ec56                	sd	s5,24(sp)
    80004dd6:	e85a                	sd	s6,16(sp)
    80004dd8:	0880                	addi	s0,sp,80
    80004dda:	8a2e                	mv	s4,a1
    80004ddc:	8ab2                	mv	s5,a2
    80004dde:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004de0:	fb040593          	addi	a1,s0,-80
    80004de4:	eb5fe0ef          	jal	80003c98 <nameiparent>
    80004de8:	84aa                	mv	s1,a0
    80004dea:	12050f63          	beqz	a0,80004f28 <create+0x160>
    return 0;

  ilock(dp);
    80004dee:	df6fe0ef          	jal	800033e4 <ilock>

  if (dp->nlink == 0) {
    80004df2:	04a49783          	lh	a5,74(s1)
    80004df6:	cbb9                	beqz	a5,80004e4c <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004df8:	7761                	lui	a4,0xffff8
    80004dfa:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd4759>
    80004dfc:	97ba                	add	a5,a5,a4
    80004dfe:	e781                	bnez	a5,80004e06 <create+0x3e>
    80004e00:	fffa0793          	addi	a5,s4,-1
    80004e04:	cba9                	beqz	a5,80004e56 <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004e06:	4601                	li	a2,0
    80004e08:	fb040593          	addi	a1,s0,-80
    80004e0c:	8526                	mv	a0,s1
    80004e0e:	bbffe0ef          	jal	800039cc <dirlookup>
    80004e12:	892a                	mv	s2,a0
    80004e14:	c939                	beqz	a0,80004e6a <create+0xa2>
    iunlockput(dp);
    80004e16:	8526                	mv	a0,s1
    80004e18:	821fe0ef          	jal	80003638 <iunlockput>
    ilock(ip);
    80004e1c:	854a                	mv	a0,s2
    80004e1e:	dc6fe0ef          	jal	800033e4 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004e22:	4789                	li	a5,2
    80004e24:	02fa1e63          	bne	s4,a5,80004e60 <create+0x98>
    80004e28:	04495783          	lhu	a5,68(s2)
    80004e2c:	37f9                	addiw	a5,a5,-2
    80004e2e:	17c2                	slli	a5,a5,0x30
    80004e30:	93c1                	srli	a5,a5,0x30
    80004e32:	4705                	li	a4,1
    80004e34:	02f76663          	bltu	a4,a5,80004e60 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004e38:	854a                	mv	a0,s2
    80004e3a:	60a6                	ld	ra,72(sp)
    80004e3c:	6406                	ld	s0,64(sp)
    80004e3e:	74e2                	ld	s1,56(sp)
    80004e40:	7942                	ld	s2,48(sp)
    80004e42:	7a02                	ld	s4,32(sp)
    80004e44:	6ae2                	ld	s5,24(sp)
    80004e46:	6b42                	ld	s6,16(sp)
    80004e48:	6161                	addi	sp,sp,80
    80004e4a:	8082                	ret
    iunlockput(dp);
    80004e4c:	8526                	mv	a0,s1
    80004e4e:	feafe0ef          	jal	80003638 <iunlockput>
    return 0;
    80004e52:	4901                	li	s2,0
    80004e54:	b7d5                	j	80004e38 <create+0x70>
    iunlockput(dp);
    80004e56:	8526                	mv	a0,s1
    80004e58:	fe0fe0ef          	jal	80003638 <iunlockput>
    return 0;
    80004e5c:	4901                	li	s2,0
    80004e5e:	bfe9                	j	80004e38 <create+0x70>
    iunlockput(ip);
    80004e60:	854a                	mv	a0,s2
    80004e62:	fd6fe0ef          	jal	80003638 <iunlockput>
    return 0;
    80004e66:	4901                	li	s2,0
    80004e68:	bfc1                	j	80004e38 <create+0x70>
    80004e6a:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004e6c:	85d2                	mv	a1,s4
    80004e6e:	4088                	lw	a0,0(s1)
    80004e70:	c04fe0ef          	jal	80003274 <ialloc>
    80004e74:	89aa                	mv	s3,a0
    80004e76:	cd1d                	beqz	a0,80004eb4 <create+0xec>
  ilock(ip);
    80004e78:	d6cfe0ef          	jal	800033e4 <ilock>
  ip->major = major;
    80004e7c:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004e80:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004e84:	4705                	li	a4,1
    80004e86:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004e8a:	854e                	mv	a0,s3
    80004e8c:	ca4fe0ef          	jal	80003330 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004e90:	4705                	li	a4,1
    80004e92:	02ea0763          	beq	s4,a4,80004ec0 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004e96:	0049a603          	lw	a2,4(s3)
    80004e9a:	fb040593          	addi	a1,s0,-80
    80004e9e:	8526                	mv	a0,s1
    80004ea0:	d35fe0ef          	jal	80003bd4 <dirlink>
    80004ea4:	06054563          	bltz	a0,80004f0e <create+0x146>
  iunlockput(dp);
    80004ea8:	8526                	mv	a0,s1
    80004eaa:	f8efe0ef          	jal	80003638 <iunlockput>
  return ip;
    80004eae:	894e                	mv	s2,s3
    80004eb0:	79a2                	ld	s3,40(sp)
    80004eb2:	b759                	j	80004e38 <create+0x70>
    iunlockput(dp);
    80004eb4:	8526                	mv	a0,s1
    80004eb6:	f82fe0ef          	jal	80003638 <iunlockput>
    return 0;
    80004eba:	894e                	mv	s2,s3
    80004ebc:	79a2                	ld	s3,40(sp)
    80004ebe:	bfad                	j	80004e38 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ec0:	0049a603          	lw	a2,4(s3)
    80004ec4:	00002597          	auipc	a1,0x2
    80004ec8:	71c58593          	addi	a1,a1,1820 # 800075e0 <etext+0x5e0>
    80004ecc:	854e                	mv	a0,s3
    80004ece:	d07fe0ef          	jal	80003bd4 <dirlink>
    80004ed2:	02054e63          	bltz	a0,80004f0e <create+0x146>
    80004ed6:	40d0                	lw	a2,4(s1)
    80004ed8:	00002597          	auipc	a1,0x2
    80004edc:	71058593          	addi	a1,a1,1808 # 800075e8 <etext+0x5e8>
    80004ee0:	854e                	mv	a0,s3
    80004ee2:	cf3fe0ef          	jal	80003bd4 <dirlink>
    80004ee6:	02054463          	bltz	a0,80004f0e <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004eea:	0049a603          	lw	a2,4(s3)
    80004eee:	fb040593          	addi	a1,s0,-80
    80004ef2:	8526                	mv	a0,s1
    80004ef4:	ce1fe0ef          	jal	80003bd4 <dirlink>
    80004ef8:	00054b63          	bltz	a0,80004f0e <create+0x146>
    dp->nlink++; // for ".."
    80004efc:	04a4d783          	lhu	a5,74(s1)
    80004f00:	2785                	addiw	a5,a5,1
    80004f02:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f06:	8526                	mv	a0,s1
    80004f08:	c28fe0ef          	jal	80003330 <iupdate>
    80004f0c:	bf71                	j	80004ea8 <create+0xe0>
  ip->nlink = 0;
    80004f0e:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004f12:	854e                	mv	a0,s3
    80004f14:	c1cfe0ef          	jal	80003330 <iupdate>
  iunlockput(ip);
    80004f18:	854e                	mv	a0,s3
    80004f1a:	f1efe0ef          	jal	80003638 <iunlockput>
  iunlockput(dp);
    80004f1e:	8526                	mv	a0,s1
    80004f20:	f18fe0ef          	jal	80003638 <iunlockput>
  return 0;
    80004f24:	79a2                	ld	s3,40(sp)
    80004f26:	bf09                	j	80004e38 <create+0x70>
    return 0;
    80004f28:	892a                	mv	s2,a0
    80004f2a:	b739                	j	80004e38 <create+0x70>

0000000080004f2c <sys_dup>:
{
    80004f2c:	7179                	addi	sp,sp,-48
    80004f2e:	f406                	sd	ra,40(sp)
    80004f30:	f022                	sd	s0,32(sp)
    80004f32:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004f34:	fd840613          	addi	a2,s0,-40
    80004f38:	4581                	li	a1,0
    80004f3a:	4501                	li	a0,0
    80004f3c:	df3ff0ef          	jal	80004d2e <argfd>
    return -1;
    80004f40:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004f42:	02054363          	bltz	a0,80004f68 <sys_dup+0x3c>
    80004f46:	ec26                	sd	s1,24(sp)
    80004f48:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004f4a:	fd843483          	ld	s1,-40(s0)
    80004f4e:	8526                	mv	a0,s1
    80004f50:	e39ff0ef          	jal	80004d88 <fdalloc>
    80004f54:	892a                	mv	s2,a0
    return -1;
    80004f56:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004f58:	00054d63          	bltz	a0,80004f72 <sys_dup+0x46>
  filedup(f);
    80004f5c:	8526                	mv	a0,s1
    80004f5e:	b72ff0ef          	jal	800042d0 <filedup>
  return fd;
    80004f62:	87ca                	mv	a5,s2
    80004f64:	64e2                	ld	s1,24(sp)
    80004f66:	6942                	ld	s2,16(sp)
}
    80004f68:	853e                	mv	a0,a5
    80004f6a:	70a2                	ld	ra,40(sp)
    80004f6c:	7402                	ld	s0,32(sp)
    80004f6e:	6145                	addi	sp,sp,48
    80004f70:	8082                	ret
    80004f72:	64e2                	ld	s1,24(sp)
    80004f74:	6942                	ld	s2,16(sp)
    80004f76:	bfcd                	j	80004f68 <sys_dup+0x3c>

0000000080004f78 <sys_read>:
{
    80004f78:	7179                	addi	sp,sp,-48
    80004f7a:	f406                	sd	ra,40(sp)
    80004f7c:	f022                	sd	s0,32(sp)
    80004f7e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f80:	fd840593          	addi	a1,s0,-40
    80004f84:	4505                	li	a0,1
    80004f86:	a7ffd0ef          	jal	80002a04 <argaddr>
  argint(2, &n);
    80004f8a:	fe440593          	addi	a1,s0,-28
    80004f8e:	4509                	li	a0,2
    80004f90:	a59fd0ef          	jal	800029e8 <argint>
  if (argfd(0, 0, &f) < 0)
    80004f94:	fe840613          	addi	a2,s0,-24
    80004f98:	4581                	li	a1,0
    80004f9a:	4501                	li	a0,0
    80004f9c:	d93ff0ef          	jal	80004d2e <argfd>
    80004fa0:	87aa                	mv	a5,a0
    return -1;
    80004fa2:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004fa4:	0007ca63          	bltz	a5,80004fb8 <sys_read+0x40>
  return fileread(f, p, n);
    80004fa8:	fe442603          	lw	a2,-28(s0)
    80004fac:	fd843583          	ld	a1,-40(s0)
    80004fb0:	fe843503          	ld	a0,-24(s0)
    80004fb4:	c94ff0ef          	jal	80004448 <fileread>
}
    80004fb8:	70a2                	ld	ra,40(sp)
    80004fba:	7402                	ld	s0,32(sp)
    80004fbc:	6145                	addi	sp,sp,48
    80004fbe:	8082                	ret

0000000080004fc0 <sys_write>:
{
    80004fc0:	7179                	addi	sp,sp,-48
    80004fc2:	f406                	sd	ra,40(sp)
    80004fc4:	f022                	sd	s0,32(sp)
    80004fc6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fc8:	fd840593          	addi	a1,s0,-40
    80004fcc:	4505                	li	a0,1
    80004fce:	a37fd0ef          	jal	80002a04 <argaddr>
  argint(2, &n);
    80004fd2:	fe440593          	addi	a1,s0,-28
    80004fd6:	4509                	li	a0,2
    80004fd8:	a11fd0ef          	jal	800029e8 <argint>
  if (argfd(0, 0, &f) < 0)
    80004fdc:	fe840613          	addi	a2,s0,-24
    80004fe0:	4581                	li	a1,0
    80004fe2:	4501                	li	a0,0
    80004fe4:	d4bff0ef          	jal	80004d2e <argfd>
    80004fe8:	87aa                	mv	a5,a0
    return -1;
    80004fea:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004fec:	0007ca63          	bltz	a5,80005000 <sys_write+0x40>
  return filewrite(f, p, n);
    80004ff0:	fe442603          	lw	a2,-28(s0)
    80004ff4:	fd843583          	ld	a1,-40(s0)
    80004ff8:	fe843503          	ld	a0,-24(s0)
    80004ffc:	d1aff0ef          	jal	80004516 <filewrite>
}
    80005000:	70a2                	ld	ra,40(sp)
    80005002:	7402                	ld	s0,32(sp)
    80005004:	6145                	addi	sp,sp,48
    80005006:	8082                	ret

0000000080005008 <sys_close>:
{
    80005008:	1101                	addi	sp,sp,-32
    8000500a:	ec06                	sd	ra,24(sp)
    8000500c:	e822                	sd	s0,16(sp)
    8000500e:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80005010:	fe040613          	addi	a2,s0,-32
    80005014:	fec40593          	addi	a1,s0,-20
    80005018:	4501                	li	a0,0
    8000501a:	d15ff0ef          	jal	80004d2e <argfd>
    return -1;
    8000501e:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80005020:	02054163          	bltz	a0,80005042 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80005024:	925fc0ef          	jal	80001948 <myproc>
    80005028:	fec42783          	lw	a5,-20(s0)
    8000502c:	078e                	slli	a5,a5,0x3
    8000502e:	0d078793          	addi	a5,a5,208
    80005032:	953e                	add	a0,a0,a5
    80005034:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005038:	fe043503          	ld	a0,-32(s0)
    8000503c:	adaff0ef          	jal	80004316 <fileclose>
  return 0;
    80005040:	4781                	li	a5,0
}
    80005042:	853e                	mv	a0,a5
    80005044:	60e2                	ld	ra,24(sp)
    80005046:	6442                	ld	s0,16(sp)
    80005048:	6105                	addi	sp,sp,32
    8000504a:	8082                	ret

000000008000504c <sys_fstat>:
{
    8000504c:	1101                	addi	sp,sp,-32
    8000504e:	ec06                	sd	ra,24(sp)
    80005050:	e822                	sd	s0,16(sp)
    80005052:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005054:	fe040593          	addi	a1,s0,-32
    80005058:	4505                	li	a0,1
    8000505a:	9abfd0ef          	jal	80002a04 <argaddr>
  if (argfd(0, 0, &f) < 0)
    8000505e:	fe840613          	addi	a2,s0,-24
    80005062:	4581                	li	a1,0
    80005064:	4501                	li	a0,0
    80005066:	cc9ff0ef          	jal	80004d2e <argfd>
    8000506a:	87aa                	mv	a5,a0
    return -1;
    8000506c:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    8000506e:	0007c863          	bltz	a5,8000507e <sys_fstat+0x32>
  return filestat(f, st);
    80005072:	fe043583          	ld	a1,-32(s0)
    80005076:	fe843503          	ld	a0,-24(s0)
    8000507a:	b5eff0ef          	jal	800043d8 <filestat>
}
    8000507e:	60e2                	ld	ra,24(sp)
    80005080:	6442                	ld	s0,16(sp)
    80005082:	6105                	addi	sp,sp,32
    80005084:	8082                	ret

0000000080005086 <sys_link>:
{
    80005086:	7169                	addi	sp,sp,-304
    80005088:	f606                	sd	ra,296(sp)
    8000508a:	f222                	sd	s0,288(sp)
    8000508c:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000508e:	08000613          	li	a2,128
    80005092:	ed040593          	addi	a1,s0,-304
    80005096:	4501                	li	a0,0
    80005098:	989fd0ef          	jal	80002a20 <argstr>
    return -1;
    8000509c:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000509e:	10054163          	bltz	a0,800051a0 <sys_link+0x11a>
    800050a2:	08000613          	li	a2,128
    800050a6:	f5040593          	addi	a1,s0,-176
    800050aa:	4505                	li	a0,1
    800050ac:	975fd0ef          	jal	80002a20 <argstr>
    return -1;
    800050b0:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050b2:	0e054763          	bltz	a0,800051a0 <sys_link+0x11a>
    800050b6:	ee26                	sd	s1,280(sp)
  begin_op();
    800050b8:	da5fe0ef          	jal	80003e5c <begin_op>
  if ((ip = namei(old)) == 0) {
    800050bc:	ed040513          	addi	a0,s0,-304
    800050c0:	bbffe0ef          	jal	80003c7e <namei>
    800050c4:	84aa                	mv	s1,a0
    800050c6:	cd35                	beqz	a0,80005142 <sys_link+0xbc>
  ilock(ip);
    800050c8:	b1cfe0ef          	jal	800033e4 <ilock>
  if (ip->type == T_DIR) {
    800050cc:	04449703          	lh	a4,68(s1)
    800050d0:	4785                	li	a5,1
    800050d2:	06f70d63          	beq	a4,a5,8000514c <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    800050d6:	04a49783          	lh	a5,74(s1)
    800050da:	6721                	lui	a4,0x8
    800050dc:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    800050de:	06e78f63          	beq	a5,a4,8000515c <sys_link+0xd6>
    800050e2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800050e4:	2785                	addiw	a5,a5,1
    800050e6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050ea:	8526                	mv	a0,s1
    800050ec:	a44fe0ef          	jal	80003330 <iupdate>
  iunlock(ip);
    800050f0:	8526                	mv	a0,s1
    800050f2:	ba0fe0ef          	jal	80003492 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    800050f6:	fd040593          	addi	a1,s0,-48
    800050fa:	f5040513          	addi	a0,s0,-176
    800050fe:	b9bfe0ef          	jal	80003c98 <nameiparent>
    80005102:	892a                	mv	s2,a0
    80005104:	c93d                	beqz	a0,8000517a <sys_link+0xf4>
  ilock(dp);
    80005106:	adefe0ef          	jal	800033e4 <ilock>
  if (dp->nlink == 0) {
    8000510a:	04a91783          	lh	a5,74(s2)
    8000510e:	cfb9                	beqz	a5,8000516c <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80005110:	854a                	mv	a0,s2
    80005112:	00092703          	lw	a4,0(s2)
    80005116:	409c                	lw	a5,0(s1)
    80005118:	04f71e63          	bne	a4,a5,80005174 <sys_link+0xee>
    8000511c:	40d0                	lw	a2,4(s1)
    8000511e:	fd040593          	addi	a1,s0,-48
    80005122:	ab3fe0ef          	jal	80003bd4 <dirlink>
    80005126:	04054763          	bltz	a0,80005174 <sys_link+0xee>
  iunlockput(dp);
    8000512a:	854a                	mv	a0,s2
    8000512c:	d0cfe0ef          	jal	80003638 <iunlockput>
  iput(ip);
    80005130:	8526                	mv	a0,s1
    80005132:	c34fe0ef          	jal	80003566 <iput>
  end_op();
    80005136:	db3fe0ef          	jal	80003ee8 <end_op>
  return 0;
    8000513a:	4781                	li	a5,0
    8000513c:	64f2                	ld	s1,280(sp)
    8000513e:	6952                	ld	s2,272(sp)
    80005140:	a085                	j	800051a0 <sys_link+0x11a>
    end_op();
    80005142:	da7fe0ef          	jal	80003ee8 <end_op>
    return -1;
    80005146:	57fd                	li	a5,-1
    80005148:	64f2                	ld	s1,280(sp)
    8000514a:	a899                	j	800051a0 <sys_link+0x11a>
    iunlockput(ip);
    8000514c:	8526                	mv	a0,s1
    8000514e:	ceafe0ef          	jal	80003638 <iunlockput>
    end_op();
    80005152:	d97fe0ef          	jal	80003ee8 <end_op>
    return -1;
    80005156:	57fd                	li	a5,-1
    80005158:	64f2                	ld	s1,280(sp)
    8000515a:	a099                	j	800051a0 <sys_link+0x11a>
    iunlockput(ip);
    8000515c:	8526                	mv	a0,s1
    8000515e:	cdafe0ef          	jal	80003638 <iunlockput>
    end_op();
    80005162:	d87fe0ef          	jal	80003ee8 <end_op>
    return -1;
    80005166:	57fd                	li	a5,-1
    80005168:	64f2                	ld	s1,280(sp)
    8000516a:	a81d                	j	800051a0 <sys_link+0x11a>
    iunlockput(dp);
    8000516c:	854a                	mv	a0,s2
    8000516e:	ccafe0ef          	jal	80003638 <iunlockput>
    goto bad;
    80005172:	a021                	j	8000517a <sys_link+0xf4>
    iunlockput(dp);
    80005174:	854a                	mv	a0,s2
    80005176:	cc2fe0ef          	jal	80003638 <iunlockput>
  ilock(ip);
    8000517a:	8526                	mv	a0,s1
    8000517c:	a68fe0ef          	jal	800033e4 <ilock>
  ip->nlink--;
    80005180:	04a4d783          	lhu	a5,74(s1)
    80005184:	37fd                	addiw	a5,a5,-1
    80005186:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000518a:	8526                	mv	a0,s1
    8000518c:	9a4fe0ef          	jal	80003330 <iupdate>
  iunlockput(ip);
    80005190:	8526                	mv	a0,s1
    80005192:	ca6fe0ef          	jal	80003638 <iunlockput>
  end_op();
    80005196:	d53fe0ef          	jal	80003ee8 <end_op>
  return -1;
    8000519a:	57fd                	li	a5,-1
    8000519c:	64f2                	ld	s1,280(sp)
    8000519e:	6952                	ld	s2,272(sp)
}
    800051a0:	853e                	mv	a0,a5
    800051a2:	70b2                	ld	ra,296(sp)
    800051a4:	7412                	ld	s0,288(sp)
    800051a6:	6155                	addi	sp,sp,304
    800051a8:	8082                	ret

00000000800051aa <sys_unlink>:
{
    800051aa:	7151                	addi	sp,sp,-240
    800051ac:	f586                	sd	ra,232(sp)
    800051ae:	f1a2                	sd	s0,224(sp)
    800051b0:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    800051b2:	08000613          	li	a2,128
    800051b6:	f3040593          	addi	a1,s0,-208
    800051ba:	4501                	li	a0,0
    800051bc:	865fd0ef          	jal	80002a20 <argstr>
    800051c0:	14054d63          	bltz	a0,8000531a <sys_unlink+0x170>
    800051c4:	eda6                	sd	s1,216(sp)
  begin_op();
    800051c6:	c97fe0ef          	jal	80003e5c <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    800051ca:	fb040593          	addi	a1,s0,-80
    800051ce:	f3040513          	addi	a0,s0,-208
    800051d2:	ac7fe0ef          	jal	80003c98 <nameiparent>
    800051d6:	84aa                	mv	s1,a0
    800051d8:	c955                	beqz	a0,8000528c <sys_unlink+0xe2>
  ilock(dp);
    800051da:	a0afe0ef          	jal	800033e4 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800051de:	00002597          	auipc	a1,0x2
    800051e2:	40258593          	addi	a1,a1,1026 # 800075e0 <etext+0x5e0>
    800051e6:	fb040513          	addi	a0,s0,-80
    800051ea:	fccfe0ef          	jal	800039b6 <namecmp>
    800051ee:	10050b63          	beqz	a0,80005304 <sys_unlink+0x15a>
    800051f2:	00002597          	auipc	a1,0x2
    800051f6:	3f658593          	addi	a1,a1,1014 # 800075e8 <etext+0x5e8>
    800051fa:	fb040513          	addi	a0,s0,-80
    800051fe:	fb8fe0ef          	jal	800039b6 <namecmp>
    80005202:	10050163          	beqz	a0,80005304 <sys_unlink+0x15a>
    80005206:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005208:	f2c40613          	addi	a2,s0,-212
    8000520c:	fb040593          	addi	a1,s0,-80
    80005210:	8526                	mv	a0,s1
    80005212:	fbafe0ef          	jal	800039cc <dirlookup>
    80005216:	892a                	mv	s2,a0
    80005218:	0e050563          	beqz	a0,80005302 <sys_unlink+0x158>
    8000521c:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    8000521e:	9c6fe0ef          	jal	800033e4 <ilock>
  if (ip->nlink < 1)
    80005222:	04a91783          	lh	a5,74(s2)
    80005226:	06f05863          	blez	a5,80005296 <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    8000522a:	04491703          	lh	a4,68(s2)
    8000522e:	4785                	li	a5,1
    80005230:	06f70963          	beq	a4,a5,800052a2 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005234:	fc040993          	addi	s3,s0,-64
    80005238:	4641                	li	a2,16
    8000523a:	4581                	li	a1,0
    8000523c:	854e                	mv	a0,s3
    8000523e:	aabfb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005242:	4741                	li	a4,16
    80005244:	f2c42683          	lw	a3,-212(s0)
    80005248:	864e                	mv	a2,s3
    8000524a:	4581                	li	a1,0
    8000524c:	8526                	mv	a0,s1
    8000524e:	e62fe0ef          	jal	800038b0 <writei>
    80005252:	47c1                	li	a5,16
    80005254:	08f51863          	bne	a0,a5,800052e4 <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    80005258:	04491703          	lh	a4,68(s2)
    8000525c:	4785                	li	a5,1
    8000525e:	08f70963          	beq	a4,a5,800052f0 <sys_unlink+0x146>
  iunlockput(dp);
    80005262:	8526                	mv	a0,s1
    80005264:	bd4fe0ef          	jal	80003638 <iunlockput>
  ip->nlink--;
    80005268:	04a95783          	lhu	a5,74(s2)
    8000526c:	37fd                	addiw	a5,a5,-1
    8000526e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005272:	854a                	mv	a0,s2
    80005274:	8bcfe0ef          	jal	80003330 <iupdate>
  iunlockput(ip);
    80005278:	854a                	mv	a0,s2
    8000527a:	bbefe0ef          	jal	80003638 <iunlockput>
  end_op();
    8000527e:	c6bfe0ef          	jal	80003ee8 <end_op>
  return 0;
    80005282:	4501                	li	a0,0
    80005284:	64ee                	ld	s1,216(sp)
    80005286:	694e                	ld	s2,208(sp)
    80005288:	69ae                	ld	s3,200(sp)
    8000528a:	a061                	j	80005312 <sys_unlink+0x168>
    end_op();
    8000528c:	c5dfe0ef          	jal	80003ee8 <end_op>
    return -1;
    80005290:	557d                	li	a0,-1
    80005292:	64ee                	ld	s1,216(sp)
    80005294:	a8bd                	j	80005312 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005296:	00002517          	auipc	a0,0x2
    8000529a:	35a50513          	addi	a0,a0,858 # 800075f0 <etext+0x5f0>
    8000529e:	d96fb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800052a2:	04c92703          	lw	a4,76(s2)
    800052a6:	02000793          	li	a5,32
    800052aa:	f8e7f5e3          	bgeu	a5,a4,80005234 <sys_unlink+0x8a>
    800052ae:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800052b0:	4741                	li	a4,16
    800052b2:	86ce                	mv	a3,s3
    800052b4:	f1840613          	addi	a2,s0,-232
    800052b8:	4581                	li	a1,0
    800052ba:	854a                	mv	a0,s2
    800052bc:	d02fe0ef          	jal	800037be <readi>
    800052c0:	47c1                	li	a5,16
    800052c2:	00f51b63          	bne	a0,a5,800052d8 <sys_unlink+0x12e>
    if (de.inum != 0)
    800052c6:	f1845783          	lhu	a5,-232(s0)
    800052ca:	ebb1                	bnez	a5,8000531e <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800052cc:	29c1                	addiw	s3,s3,16
    800052ce:	04c92783          	lw	a5,76(s2)
    800052d2:	fcf9efe3          	bltu	s3,a5,800052b0 <sys_unlink+0x106>
    800052d6:	bfb9                	j	80005234 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800052d8:	00002517          	auipc	a0,0x2
    800052dc:	33050513          	addi	a0,a0,816 # 80007608 <etext+0x608>
    800052e0:	d54fb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    800052e4:	00002517          	auipc	a0,0x2
    800052e8:	33c50513          	addi	a0,a0,828 # 80007620 <etext+0x620>
    800052ec:	d48fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    800052f0:	04a4d783          	lhu	a5,74(s1)
    800052f4:	37fd                	addiw	a5,a5,-1
    800052f6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800052fa:	8526                	mv	a0,s1
    800052fc:	834fe0ef          	jal	80003330 <iupdate>
    80005300:	b78d                	j	80005262 <sys_unlink+0xb8>
    80005302:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005304:	8526                	mv	a0,s1
    80005306:	b32fe0ef          	jal	80003638 <iunlockput>
  end_op();
    8000530a:	bdffe0ef          	jal	80003ee8 <end_op>
  return -1;
    8000530e:	557d                	li	a0,-1
    80005310:	64ee                	ld	s1,216(sp)
}
    80005312:	70ae                	ld	ra,232(sp)
    80005314:	740e                	ld	s0,224(sp)
    80005316:	616d                	addi	sp,sp,240
    80005318:	8082                	ret
    return -1;
    8000531a:	557d                	li	a0,-1
    8000531c:	bfdd                	j	80005312 <sys_unlink+0x168>
    iunlockput(ip);
    8000531e:	854a                	mv	a0,s2
    80005320:	b18fe0ef          	jal	80003638 <iunlockput>
    goto bad;
    80005324:	694e                	ld	s2,208(sp)
    80005326:	69ae                	ld	s3,200(sp)
    80005328:	bff1                	j	80005304 <sys_unlink+0x15a>

000000008000532a <sys_open>:

uint64
sys_open(void)
{
    8000532a:	7131                	addi	sp,sp,-192
    8000532c:	fd06                	sd	ra,184(sp)
    8000532e:	f922                	sd	s0,176(sp)
    80005330:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005332:	f4c40593          	addi	a1,s0,-180
    80005336:	4505                	li	a0,1
    80005338:	eb0fd0ef          	jal	800029e8 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000533c:	08000613          	li	a2,128
    80005340:	f5040593          	addi	a1,s0,-176
    80005344:	4501                	li	a0,0
    80005346:	edafd0ef          	jal	80002a20 <argstr>
    8000534a:	87aa                	mv	a5,a0
    return -1;
    8000534c:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000534e:	0a07c363          	bltz	a5,800053f4 <sys_open+0xca>
    80005352:	f526                	sd	s1,168(sp)

  begin_op();
    80005354:	b09fe0ef          	jal	80003e5c <begin_op>

  if (omode & O_CREATE) {
    80005358:	f4c42783          	lw	a5,-180(s0)
    8000535c:	2007f793          	andi	a5,a5,512
    80005360:	c3dd                	beqz	a5,80005406 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005362:	4681                	li	a3,0
    80005364:	4601                	li	a2,0
    80005366:	4589                	li	a1,2
    80005368:	f5040513          	addi	a0,s0,-176
    8000536c:	a5dff0ef          	jal	80004dc8 <create>
    80005370:	84aa                	mv	s1,a0
    if (ip == 0) {
    80005372:	c549                	beqz	a0,800053fc <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    80005374:	04449703          	lh	a4,68(s1)
    80005378:	478d                	li	a5,3
    8000537a:	00f71763          	bne	a4,a5,80005388 <sys_open+0x5e>
    8000537e:	0464d703          	lhu	a4,70(s1)
    80005382:	47a5                	li	a5,9
    80005384:	0ae7ee63          	bltu	a5,a4,80005440 <sys_open+0x116>
    80005388:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    8000538a:	ee9fe0ef          	jal	80004272 <filealloc>
    8000538e:	892a                	mv	s2,a0
    80005390:	c561                	beqz	a0,80005458 <sys_open+0x12e>
    80005392:	ed4e                	sd	s3,152(sp)
    80005394:	9f5ff0ef          	jal	80004d88 <fdalloc>
    80005398:	89aa                	mv	s3,a0
    8000539a:	0a054b63          	bltz	a0,80005450 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    8000539e:	04449703          	lh	a4,68(s1)
    800053a2:	478d                	li	a5,3
    800053a4:	0cf70363          	beq	a4,a5,8000546a <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800053a8:	4789                	li	a5,2
    800053aa:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800053ae:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800053b2:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800053b6:	f4c42783          	lw	a5,-180(s0)
    800053ba:	0017f713          	andi	a4,a5,1
    800053be:	00174713          	xori	a4,a4,1
    800053c2:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800053c6:	0037f713          	andi	a4,a5,3
    800053ca:	00e03733          	snez	a4,a4
    800053ce:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    800053d2:	4007f793          	andi	a5,a5,1024
    800053d6:	c791                	beqz	a5,800053e2 <sys_open+0xb8>
    800053d8:	04449703          	lh	a4,68(s1)
    800053dc:	4789                	li	a5,2
    800053de:	08f70d63          	beq	a4,a5,80005478 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800053e2:	8526                	mv	a0,s1
    800053e4:	8aefe0ef          	jal	80003492 <iunlock>
  end_op();
    800053e8:	b01fe0ef          	jal	80003ee8 <end_op>

  return fd;
    800053ec:	854e                	mv	a0,s3
    800053ee:	74aa                	ld	s1,168(sp)
    800053f0:	790a                	ld	s2,160(sp)
    800053f2:	69ea                	ld	s3,152(sp)
}
    800053f4:	70ea                	ld	ra,184(sp)
    800053f6:	744a                	ld	s0,176(sp)
    800053f8:	6129                	addi	sp,sp,192
    800053fa:	8082                	ret
      end_op();
    800053fc:	aedfe0ef          	jal	80003ee8 <end_op>
      return -1;
    80005400:	557d                	li	a0,-1
    80005402:	74aa                	ld	s1,168(sp)
    80005404:	bfc5                	j	800053f4 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    80005406:	f5040513          	addi	a0,s0,-176
    8000540a:	875fe0ef          	jal	80003c7e <namei>
    8000540e:	84aa                	mv	s1,a0
    80005410:	c11d                	beqz	a0,80005436 <sys_open+0x10c>
    ilock(ip);
    80005412:	fd3fd0ef          	jal	800033e4 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    80005416:	04449703          	lh	a4,68(s1)
    8000541a:	4785                	li	a5,1
    8000541c:	f4f71ce3          	bne	a4,a5,80005374 <sys_open+0x4a>
    80005420:	f4c42783          	lw	a5,-180(s0)
    80005424:	d3b5                	beqz	a5,80005388 <sys_open+0x5e>
      iunlockput(ip);
    80005426:	8526                	mv	a0,s1
    80005428:	a10fe0ef          	jal	80003638 <iunlockput>
      end_op();
    8000542c:	abdfe0ef          	jal	80003ee8 <end_op>
      return -1;
    80005430:	557d                	li	a0,-1
    80005432:	74aa                	ld	s1,168(sp)
    80005434:	b7c1                	j	800053f4 <sys_open+0xca>
      end_op();
    80005436:	ab3fe0ef          	jal	80003ee8 <end_op>
      return -1;
    8000543a:	557d                	li	a0,-1
    8000543c:	74aa                	ld	s1,168(sp)
    8000543e:	bf5d                	j	800053f4 <sys_open+0xca>
    iunlockput(ip);
    80005440:	8526                	mv	a0,s1
    80005442:	9f6fe0ef          	jal	80003638 <iunlockput>
    end_op();
    80005446:	aa3fe0ef          	jal	80003ee8 <end_op>
    return -1;
    8000544a:	557d                	li	a0,-1
    8000544c:	74aa                	ld	s1,168(sp)
    8000544e:	b75d                	j	800053f4 <sys_open+0xca>
      fileclose(f);
    80005450:	854a                	mv	a0,s2
    80005452:	ec5fe0ef          	jal	80004316 <fileclose>
    80005456:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005458:	8526                	mv	a0,s1
    8000545a:	9defe0ef          	jal	80003638 <iunlockput>
    end_op();
    8000545e:	a8bfe0ef          	jal	80003ee8 <end_op>
    return -1;
    80005462:	557d                	li	a0,-1
    80005464:	74aa                	ld	s1,168(sp)
    80005466:	790a                	ld	s2,160(sp)
    80005468:	b771                	j	800053f4 <sys_open+0xca>
    f->type = FD_DEVICE;
    8000546a:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    8000546e:	04649783          	lh	a5,70(s1)
    80005472:	02f91223          	sh	a5,36(s2)
    80005476:	bf35                	j	800053b2 <sys_open+0x88>
    itrunc(ip);
    80005478:	8526                	mv	a0,s1
    8000547a:	858fe0ef          	jal	800034d2 <itrunc>
    8000547e:	b795                	j	800053e2 <sys_open+0xb8>

0000000080005480 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005480:	7175                	addi	sp,sp,-144
    80005482:	e506                	sd	ra,136(sp)
    80005484:	e122                	sd	s0,128(sp)
    80005486:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005488:	9d5fe0ef          	jal	80003e5c <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    8000548c:	08000613          	li	a2,128
    80005490:	f7040593          	addi	a1,s0,-144
    80005494:	4501                	li	a0,0
    80005496:	d8afd0ef          	jal	80002a20 <argstr>
    8000549a:	02054363          	bltz	a0,800054c0 <sys_mkdir+0x40>
    8000549e:	4681                	li	a3,0
    800054a0:	4601                	li	a2,0
    800054a2:	4585                	li	a1,1
    800054a4:	f7040513          	addi	a0,s0,-144
    800054a8:	921ff0ef          	jal	80004dc8 <create>
    800054ac:	c911                	beqz	a0,800054c0 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054ae:	98afe0ef          	jal	80003638 <iunlockput>
  end_op();
    800054b2:	a37fe0ef          	jal	80003ee8 <end_op>
  return 0;
    800054b6:	4501                	li	a0,0
}
    800054b8:	60aa                	ld	ra,136(sp)
    800054ba:	640a                	ld	s0,128(sp)
    800054bc:	6149                	addi	sp,sp,144
    800054be:	8082                	ret
    end_op();
    800054c0:	a29fe0ef          	jal	80003ee8 <end_op>
    return -1;
    800054c4:	557d                	li	a0,-1
    800054c6:	bfcd                	j	800054b8 <sys_mkdir+0x38>

00000000800054c8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800054c8:	7135                	addi	sp,sp,-160
    800054ca:	ed06                	sd	ra,152(sp)
    800054cc:	e922                	sd	s0,144(sp)
    800054ce:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800054d0:	98dfe0ef          	jal	80003e5c <begin_op>
  argint(1, &major);
    800054d4:	f6c40593          	addi	a1,s0,-148
    800054d8:	4505                	li	a0,1
    800054da:	d0efd0ef          	jal	800029e8 <argint>
  argint(2, &minor);
    800054de:	f6840593          	addi	a1,s0,-152
    800054e2:	4509                	li	a0,2
    800054e4:	d04fd0ef          	jal	800029e8 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800054e8:	08000613          	li	a2,128
    800054ec:	f7040593          	addi	a1,s0,-144
    800054f0:	4501                	li	a0,0
    800054f2:	d2efd0ef          	jal	80002a20 <argstr>
    800054f6:	02054563          	bltz	a0,80005520 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    800054fa:	f6841683          	lh	a3,-152(s0)
    800054fe:	f6c41603          	lh	a2,-148(s0)
    80005502:	458d                	li	a1,3
    80005504:	f7040513          	addi	a0,s0,-144
    80005508:	8c1ff0ef          	jal	80004dc8 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    8000550c:	c911                	beqz	a0,80005520 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000550e:	92afe0ef          	jal	80003638 <iunlockput>
  end_op();
    80005512:	9d7fe0ef          	jal	80003ee8 <end_op>
  return 0;
    80005516:	4501                	li	a0,0
}
    80005518:	60ea                	ld	ra,152(sp)
    8000551a:	644a                	ld	s0,144(sp)
    8000551c:	610d                	addi	sp,sp,160
    8000551e:	8082                	ret
    end_op();
    80005520:	9c9fe0ef          	jal	80003ee8 <end_op>
    return -1;
    80005524:	557d                	li	a0,-1
    80005526:	bfcd                	j	80005518 <sys_mknod+0x50>

0000000080005528 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005528:	7135                	addi	sp,sp,-160
    8000552a:	ed06                	sd	ra,152(sp)
    8000552c:	e922                	sd	s0,144(sp)
    8000552e:	e14a                	sd	s2,128(sp)
    80005530:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005532:	c16fc0ef          	jal	80001948 <myproc>
    80005536:	892a                	mv	s2,a0

  begin_op();
    80005538:	925fe0ef          	jal	80003e5c <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    8000553c:	08000613          	li	a2,128
    80005540:	f6040593          	addi	a1,s0,-160
    80005544:	4501                	li	a0,0
    80005546:	cdafd0ef          	jal	80002a20 <argstr>
    8000554a:	04054363          	bltz	a0,80005590 <sys_chdir+0x68>
    8000554e:	e526                	sd	s1,136(sp)
    80005550:	f6040513          	addi	a0,s0,-160
    80005554:	f2afe0ef          	jal	80003c7e <namei>
    80005558:	84aa                	mv	s1,a0
    8000555a:	c915                	beqz	a0,8000558e <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000555c:	e89fd0ef          	jal	800033e4 <ilock>
  if (ip->type != T_DIR) {
    80005560:	04449703          	lh	a4,68(s1)
    80005564:	4785                	li	a5,1
    80005566:	02f71963          	bne	a4,a5,80005598 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000556a:	8526                	mv	a0,s1
    8000556c:	f27fd0ef          	jal	80003492 <iunlock>
  iput(p->cwd);
    80005570:	15093503          	ld	a0,336(s2)
    80005574:	ff3fd0ef          	jal	80003566 <iput>
  end_op();
    80005578:	971fe0ef          	jal	80003ee8 <end_op>
  p->cwd = ip;
    8000557c:	14993823          	sd	s1,336(s2)
  return 0;
    80005580:	4501                	li	a0,0
    80005582:	64aa                	ld	s1,136(sp)
}
    80005584:	60ea                	ld	ra,152(sp)
    80005586:	644a                	ld	s0,144(sp)
    80005588:	690a                	ld	s2,128(sp)
    8000558a:	610d                	addi	sp,sp,160
    8000558c:	8082                	ret
    8000558e:	64aa                	ld	s1,136(sp)
    end_op();
    80005590:	959fe0ef          	jal	80003ee8 <end_op>
    return -1;
    80005594:	557d                	li	a0,-1
    80005596:	b7fd                	j	80005584 <sys_chdir+0x5c>
    iunlockput(ip);
    80005598:	8526                	mv	a0,s1
    8000559a:	89efe0ef          	jal	80003638 <iunlockput>
    end_op();
    8000559e:	94bfe0ef          	jal	80003ee8 <end_op>
    return -1;
    800055a2:	557d                	li	a0,-1
    800055a4:	64aa                	ld	s1,136(sp)
    800055a6:	bff9                	j	80005584 <sys_chdir+0x5c>

00000000800055a8 <sys_exec>:

uint64
sys_exec(void)
{
    800055a8:	7105                	addi	sp,sp,-480
    800055aa:	ef86                	sd	ra,472(sp)
    800055ac:	eba2                	sd	s0,464(sp)
    800055ae:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800055b0:	e2840593          	addi	a1,s0,-472
    800055b4:	4505                	li	a0,1
    800055b6:	c4efd0ef          	jal	80002a04 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    800055ba:	08000613          	li	a2,128
    800055be:	f3040593          	addi	a1,s0,-208
    800055c2:	4501                	li	a0,0
    800055c4:	c5cfd0ef          	jal	80002a20 <argstr>
    800055c8:	87aa                	mv	a5,a0
    return -1;
    800055ca:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    800055cc:	0e07c063          	bltz	a5,800056ac <sys_exec+0x104>
    800055d0:	e7a6                	sd	s1,456(sp)
    800055d2:	e3ca                	sd	s2,448(sp)
    800055d4:	ff4e                	sd	s3,440(sp)
    800055d6:	fb52                	sd	s4,432(sp)
    800055d8:	f756                	sd	s5,424(sp)
    800055da:	f35a                	sd	s6,416(sp)
    800055dc:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800055de:	e3040a13          	addi	s4,s0,-464
    800055e2:	10000613          	li	a2,256
    800055e6:	4581                	li	a1,0
    800055e8:	8552                	mv	a0,s4
    800055ea:	efefb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    800055ee:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800055f0:	89d2                	mv	s3,s4
    800055f2:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800055f4:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800055f8:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    800055fa:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800055fe:	00391513          	slli	a0,s2,0x3
    80005602:	85d6                	mv	a1,s5
    80005604:	e2843783          	ld	a5,-472(s0)
    80005608:	953e                	add	a0,a0,a5
    8000560a:	b52fd0ef          	jal	8000295c <fetchaddr>
    8000560e:	02054663          	bltz	a0,8000563a <sys_exec+0x92>
    if (uarg == 0) {
    80005612:	e2043783          	ld	a5,-480(s0)
    80005616:	c7a1                	beqz	a5,8000565e <sys_exec+0xb6>
    argv[i] = kalloc();
    80005618:	d36fb0ef          	jal	80000b4e <kalloc>
    8000561c:	85aa                	mv	a1,a0
    8000561e:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005622:	cd01                	beqz	a0,8000563a <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005624:	865a                	mv	a2,s6
    80005626:	e2043503          	ld	a0,-480(s0)
    8000562a:	b7cfd0ef          	jal	800029a6 <fetchstr>
    8000562e:	00054663          	bltz	a0,8000563a <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    80005632:	0905                	addi	s2,s2,1
    80005634:	09a1                	addi	s3,s3,8
    80005636:	fd7914e3          	bne	s2,s7,800055fe <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000563a:	100a0a13          	addi	s4,s4,256
    8000563e:	6088                	ld	a0,0(s1)
    80005640:	cd31                	beqz	a0,8000569c <sys_exec+0xf4>
    kfree(argv[i]);
    80005642:	c24fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005646:	04a1                	addi	s1,s1,8
    80005648:	ff449be3          	bne	s1,s4,8000563e <sys_exec+0x96>
  return -1;
    8000564c:	557d                	li	a0,-1
    8000564e:	64be                	ld	s1,456(sp)
    80005650:	691e                	ld	s2,448(sp)
    80005652:	79fa                	ld	s3,440(sp)
    80005654:	7a5a                	ld	s4,432(sp)
    80005656:	7aba                	ld	s5,424(sp)
    80005658:	7b1a                	ld	s6,416(sp)
    8000565a:	6bfa                	ld	s7,408(sp)
    8000565c:	a881                	j	800056ac <sys_exec+0x104>
      argv[i] = 0;
    8000565e:	0009079b          	sext.w	a5,s2
    80005662:	e3040593          	addi	a1,s0,-464
    80005666:	078e                	slli	a5,a5,0x3
    80005668:	97ae                	add	a5,a5,a1
    8000566a:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000566e:	f3040513          	addi	a0,s0,-208
    80005672:	b62ff0ef          	jal	800049d4 <kexec>
    80005676:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005678:	100a0a13          	addi	s4,s4,256
    8000567c:	6088                	ld	a0,0(s1)
    8000567e:	c511                	beqz	a0,8000568a <sys_exec+0xe2>
    kfree(argv[i]);
    80005680:	be6fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005684:	04a1                	addi	s1,s1,8
    80005686:	ff449be3          	bne	s1,s4,8000567c <sys_exec+0xd4>
  return ret;
    8000568a:	854a                	mv	a0,s2
    8000568c:	64be                	ld	s1,456(sp)
    8000568e:	691e                	ld	s2,448(sp)
    80005690:	79fa                	ld	s3,440(sp)
    80005692:	7a5a                	ld	s4,432(sp)
    80005694:	7aba                	ld	s5,424(sp)
    80005696:	7b1a                	ld	s6,416(sp)
    80005698:	6bfa                	ld	s7,408(sp)
    8000569a:	a809                	j	800056ac <sys_exec+0x104>
  return -1;
    8000569c:	557d                	li	a0,-1
    8000569e:	64be                	ld	s1,456(sp)
    800056a0:	691e                	ld	s2,448(sp)
    800056a2:	79fa                	ld	s3,440(sp)
    800056a4:	7a5a                	ld	s4,432(sp)
    800056a6:	7aba                	ld	s5,424(sp)
    800056a8:	7b1a                	ld	s6,416(sp)
    800056aa:	6bfa                	ld	s7,408(sp)
}
    800056ac:	60fe                	ld	ra,472(sp)
    800056ae:	645e                	ld	s0,464(sp)
    800056b0:	613d                	addi	sp,sp,480
    800056b2:	8082                	ret

00000000800056b4 <sys_pipe>:

uint64
sys_pipe(void)
{
    800056b4:	7139                	addi	sp,sp,-64
    800056b6:	fc06                	sd	ra,56(sp)
    800056b8:	f822                	sd	s0,48(sp)
    800056ba:	f426                	sd	s1,40(sp)
    800056bc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800056be:	a8afc0ef          	jal	80001948 <myproc>
    800056c2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800056c4:	fd840593          	addi	a1,s0,-40
    800056c8:	4501                	li	a0,0
    800056ca:	b3afd0ef          	jal	80002a04 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    800056ce:	fc840593          	addi	a1,s0,-56
    800056d2:	fd040513          	addi	a0,s0,-48
    800056d6:	f7ffe0ef          	jal	80004654 <pipealloc>
    return -1;
    800056da:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    800056dc:	0a054963          	bltz	a0,8000578e <sys_pipe+0xda>
  fd0 = -1;
    800056e0:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    800056e4:	fd043503          	ld	a0,-48(s0)
    800056e8:	ea0ff0ef          	jal	80004d88 <fdalloc>
    800056ec:	fca42223          	sw	a0,-60(s0)
    800056f0:	08054663          	bltz	a0,8000577c <sys_pipe+0xc8>
    800056f4:	fc843503          	ld	a0,-56(s0)
    800056f8:	e90ff0ef          	jal	80004d88 <fdalloc>
    800056fc:	fca42023          	sw	a0,-64(s0)
    80005700:	06054463          	bltz	a0,80005768 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005704:	4711                	li	a4,4
    80005706:	fc440693          	addi	a3,s0,-60
    8000570a:	fd843603          	ld	a2,-40(s0)
    8000570e:	64ac                	ld	a1,72(s1)
    80005710:	68a8                	ld	a0,80(s1)
    80005712:	e71fb0ef          	jal	80001582 <copyout>
    80005716:	00054f63          	bltz	a0,80005734 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    8000571a:	4711                	li	a4,4
    8000571c:	fc040693          	addi	a3,s0,-64
    80005720:	fd843603          	ld	a2,-40(s0)
    80005724:	963a                	add	a2,a2,a4
    80005726:	64ac                	ld	a1,72(s1)
    80005728:	68a8                	ld	a0,80(s1)
    8000572a:	e59fb0ef          	jal	80001582 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000572e:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005730:	04055f63          	bgez	a0,8000578e <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    80005734:	fc442783          	lw	a5,-60(s0)
    80005738:	078e                	slli	a5,a5,0x3
    8000573a:	0d078793          	addi	a5,a5,208
    8000573e:	97a6                	add	a5,a5,s1
    80005740:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005744:	fc042783          	lw	a5,-64(s0)
    80005748:	078e                	slli	a5,a5,0x3
    8000574a:	0d078793          	addi	a5,a5,208
    8000574e:	94be                	add	s1,s1,a5
    80005750:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005754:	fd043503          	ld	a0,-48(s0)
    80005758:	bbffe0ef          	jal	80004316 <fileclose>
    fileclose(wf);
    8000575c:	fc843503          	ld	a0,-56(s0)
    80005760:	bb7fe0ef          	jal	80004316 <fileclose>
    return -1;
    80005764:	57fd                	li	a5,-1
    80005766:	a025                	j	8000578e <sys_pipe+0xda>
    if (fd0 >= 0)
    80005768:	fc442783          	lw	a5,-60(s0)
    8000576c:	0007c863          	bltz	a5,8000577c <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    80005770:	078e                	slli	a5,a5,0x3
    80005772:	0d078793          	addi	a5,a5,208
    80005776:	97a6                	add	a5,a5,s1
    80005778:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000577c:	fd043503          	ld	a0,-48(s0)
    80005780:	b97fe0ef          	jal	80004316 <fileclose>
    fileclose(wf);
    80005784:	fc843503          	ld	a0,-56(s0)
    80005788:	b8ffe0ef          	jal	80004316 <fileclose>
    return -1;
    8000578c:	57fd                	li	a5,-1
}
    8000578e:	853e                	mv	a0,a5
    80005790:	70e2                	ld	ra,56(sp)
    80005792:	7442                	ld	s0,48(sp)
    80005794:	74a2                	ld	s1,40(sp)
    80005796:	6121                	addi	sp,sp,64
    80005798:	8082                	ret
    8000579a:	0000                	unimp
    8000579c:	0000                	unimp
	...

00000000800057a0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800057a0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800057a2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800057a4:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    800057a6:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800057a8:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800057aa:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800057ac:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800057ae:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800057b0:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800057b2:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800057b4:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800057b6:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800057b8:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800057ba:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800057bc:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800057be:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800057c0:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800057c2:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800057c4:	8a0fd0ef          	jal	80002864 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800057c8:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800057ca:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800057cc:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800057ce:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800057d0:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800057d2:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800057d4:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800057d6:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800057d8:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800057da:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800057dc:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800057de:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800057e0:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800057e2:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800057e4:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800057e6:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800057e8:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800057ea:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800057ec:	10200073          	sret
    800057f0:	0001                	nop
    800057f2:	00000013          	nop
    800057f6:	00000013          	nop
    800057fa:	00000013          	nop

00000000800057fe <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800057fe:	1141                	addi	sp,sp,-16
    80005800:	e406                	sd	ra,8(sp)
    80005802:	e022                	sd	s0,0(sp)
    80005804:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005806:	0c000737          	lui	a4,0xc000
    8000580a:	4785                	li	a5,1
    8000580c:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000580e:	c35c                	sw	a5,4(a4)
}
    80005810:	60a2                	ld	ra,8(sp)
    80005812:	6402                	ld	s0,0(sp)
    80005814:	0141                	addi	sp,sp,16
    80005816:	8082                	ret

0000000080005818 <plicinithart>:

void
plicinithart(void)
{
    80005818:	1141                	addi	sp,sp,-16
    8000581a:	e406                	sd	ra,8(sp)
    8000581c:	e022                	sd	s0,0(sp)
    8000581e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005820:	8f4fc0ef          	jal	80001914 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    80005824:	0085179b          	slliw	a5,a0,0x8
    80005828:	0c002737          	lui	a4,0xc002
    8000582c:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    80005830:	97ba                	add	a5,a5,a4
    80005832:	40200713          	li	a4,1026
    80005836:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005838:	00d5151b          	slliw	a0,a0,0xd
    8000583c:	0c2017b7          	lui	a5,0xc201
    80005840:	953e                	add	a0,a0,a5
    80005842:	00052023          	sw	zero,0(a0)
}
    80005846:	60a2                	ld	ra,8(sp)
    80005848:	6402                	ld	s0,0(sp)
    8000584a:	0141                	addi	sp,sp,16
    8000584c:	8082                	ret

000000008000584e <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000584e:	1141                	addi	sp,sp,-16
    80005850:	e406                	sd	ra,8(sp)
    80005852:	e022                	sd	s0,0(sp)
    80005854:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005856:	8befc0ef          	jal	80001914 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    8000585a:	00d5151b          	slliw	a0,a0,0xd
    8000585e:	0c2017b7          	lui	a5,0xc201
    80005862:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80005864:	953e                	add	a0,a0,a5
    80005866:	4108                	lw	a0,0(a0)
  return irq;
}
    80005868:	60a2                	ld	ra,8(sp)
    8000586a:	6402                	ld	s0,0(sp)
    8000586c:	0141                	addi	sp,sp,16
    8000586e:	8082                	ret

0000000080005870 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005870:	1101                	addi	sp,sp,-32
    80005872:	ec06                	sd	ra,24(sp)
    80005874:	e822                	sd	s0,16(sp)
    80005876:	e426                	sd	s1,8(sp)
    80005878:	1000                	addi	s0,sp,32
    8000587a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000587c:	898fc0ef          	jal	80001914 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    80005880:	00d5179b          	slliw	a5,a0,0xd
    80005884:	0c201737          	lui	a4,0xc201
    80005888:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    8000588a:	97ba                	add	a5,a5,a4
    8000588c:	c384                	sw	s1,0(a5)
}
    8000588e:	60e2                	ld	ra,24(sp)
    80005890:	6442                	ld	s0,16(sp)
    80005892:	64a2                	ld	s1,8(sp)
    80005894:	6105                	addi	sp,sp,32
    80005896:	8082                	ret

0000000080005898 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005898:	1141                	addi	sp,sp,-16
    8000589a:	e406                	sd	ra,8(sp)
    8000589c:	e022                	sd	s0,0(sp)
    8000589e:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800058a0:	479d                	li	a5,7
    800058a2:	04a7ca63          	blt	a5,a0,800058f6 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    800058a6:	0001e797          	auipc	a5,0x1e
    800058aa:	ec278793          	addi	a5,a5,-318 # 80023768 <disk>
    800058ae:	97aa                	add	a5,a5,a0
    800058b0:	0187c783          	lbu	a5,24(a5)
    800058b4:	e7b9                	bnez	a5,80005902 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800058b6:	00451693          	slli	a3,a0,0x4
    800058ba:	0001e797          	auipc	a5,0x1e
    800058be:	eae78793          	addi	a5,a5,-338 # 80023768 <disk>
    800058c2:	6398                	ld	a4,0(a5)
    800058c4:	9736                	add	a4,a4,a3
    800058c6:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800058ca:	6398                	ld	a4,0(a5)
    800058cc:	9736                	add	a4,a4,a3
    800058ce:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800058d2:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800058d6:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800058da:	97aa                	add	a5,a5,a0
    800058dc:	4705                	li	a4,1
    800058de:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800058e2:	0001e517          	auipc	a0,0x1e
    800058e6:	e9e50513          	addi	a0,a0,-354 # 80023780 <disk+0x18>
    800058ea:	821fc0ef          	jal	8000210a <wakeup>
}
    800058ee:	60a2                	ld	ra,8(sp)
    800058f0:	6402                	ld	s0,0(sp)
    800058f2:	0141                	addi	sp,sp,16
    800058f4:	8082                	ret
    panic("free_desc 1");
    800058f6:	00002517          	auipc	a0,0x2
    800058fa:	d3a50513          	addi	a0,a0,-710 # 80007630 <etext+0x630>
    800058fe:	f37fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    80005902:	00002517          	auipc	a0,0x2
    80005906:	d3e50513          	addi	a0,a0,-706 # 80007640 <etext+0x640>
    8000590a:	f2bfa0ef          	jal	80000834 <panic>

000000008000590e <virtio_disk_init>:
{
    8000590e:	1101                	addi	sp,sp,-32
    80005910:	ec06                	sd	ra,24(sp)
    80005912:	e822                	sd	s0,16(sp)
    80005914:	e426                	sd	s1,8(sp)
    80005916:	e04a                	sd	s2,0(sp)
    80005918:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000591a:	00002597          	auipc	a1,0x2
    8000591e:	d3658593          	addi	a1,a1,-714 # 80007650 <etext+0x650>
    80005922:	0001e517          	auipc	a0,0x1e
    80005926:	f6e50513          	addi	a0,a0,-146 # 80023890 <disk+0x128>
    8000592a:	a7efb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000592e:	100017b7          	lui	a5,0x10001
    80005932:	4398                	lw	a4,0(a5)
    80005934:	2701                	sext.w	a4,a4
    80005936:	747277b7          	lui	a5,0x74727
    8000593a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000593e:	14f71863          	bne	a4,a5,80005a8e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005942:	100017b7          	lui	a5,0x10001
    80005946:	43dc                	lw	a5,4(a5)
    80005948:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000594a:	4709                	li	a4,2
    8000594c:	14e79163          	bne	a5,a4,80005a8e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005950:	100017b7          	lui	a5,0x10001
    80005954:	479c                	lw	a5,8(a5)
    80005956:	2781                	sext.w	a5,a5
    80005958:	12e79b63          	bne	a5,a4,80005a8e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    8000595c:	100017b7          	lui	a5,0x10001
    80005960:	47d8                	lw	a4,12(a5)
    80005962:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005964:	554d47b7          	lui	a5,0x554d4
    80005968:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000596c:	12f71163          	bne	a4,a5,80005a8e <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005970:	100017b7          	lui	a5,0x10001
    80005974:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005978:	4705                	li	a4,1
    8000597a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000597c:	470d                	li	a4,3
    8000597e:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005980:	10001737          	lui	a4,0x10001
    80005984:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005986:	c7ffe6b7          	lui	a3,0xc7ffe
    8000598a:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdacb7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000598e:	8f75                	and	a4,a4,a3
    80005990:	100016b7          	lui	a3,0x10001
    80005994:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005996:	472d                	li	a4,11
    80005998:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000599a:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000599e:	439c                	lw	a5,0(a5)
    800059a0:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800059a4:	8ba1                	andi	a5,a5,8
    800059a6:	0e078a63          	beqz	a5,80005a9a <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800059aa:	100017b7          	lui	a5,0x10001
    800059ae:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    800059b2:	43fc                	lw	a5,68(a5)
    800059b4:	2781                	sext.w	a5,a5
    800059b6:	0e079863          	bnez	a5,80005aa6 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800059ba:	100017b7          	lui	a5,0x10001
    800059be:	5bdc                	lw	a5,52(a5)
    800059c0:	2781                	sext.w	a5,a5
  if (max == 0)
    800059c2:	0e078863          	beqz	a5,80005ab2 <virtio_disk_init+0x1a4>
  if (max < NUM)
    800059c6:	471d                	li	a4,7
    800059c8:	0ef77b63          	bgeu	a4,a5,80005abe <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800059cc:	982fb0ef          	jal	80000b4e <kalloc>
    800059d0:	0001e497          	auipc	s1,0x1e
    800059d4:	d9848493          	addi	s1,s1,-616 # 80023768 <disk>
    800059d8:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800059da:	974fb0ef          	jal	80000b4e <kalloc>
    800059de:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800059e0:	96efb0ef          	jal	80000b4e <kalloc>
    800059e4:	87aa                	mv	a5,a0
    800059e6:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    800059e8:	6088                	ld	a0,0(s1)
    800059ea:	0e050063          	beqz	a0,80005aca <virtio_disk_init+0x1bc>
    800059ee:	0001e717          	auipc	a4,0x1e
    800059f2:	d8273703          	ld	a4,-638(a4) # 80023770 <disk+0x8>
    800059f6:	cb71                	beqz	a4,80005aca <virtio_disk_init+0x1bc>
    800059f8:	cbe9                	beqz	a5,80005aca <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800059fa:	6605                	lui	a2,0x1
    800059fc:	4581                	li	a1,0
    800059fe:	aeafb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005a02:	0001e497          	auipc	s1,0x1e
    80005a06:	d6648493          	addi	s1,s1,-666 # 80023768 <disk>
    80005a0a:	6605                	lui	a2,0x1
    80005a0c:	4581                	li	a1,0
    80005a0e:	6488                	ld	a0,8(s1)
    80005a10:	ad8fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005a14:	6605                	lui	a2,0x1
    80005a16:	4581                	li	a1,0
    80005a18:	6888                	ld	a0,16(s1)
    80005a1a:	acefb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005a1e:	100017b7          	lui	a5,0x10001
    80005a22:	4721                	li	a4,8
    80005a24:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005a26:	4098                	lw	a4,0(s1)
    80005a28:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005a2c:	40d8                	lw	a4,4(s1)
    80005a2e:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005a32:	649c                	ld	a5,8(s1)
    80005a34:	0007869b          	sext.w	a3,a5
    80005a38:	10001737          	lui	a4,0x10001
    80005a3c:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005a40:	9781                	srai	a5,a5,0x20
    80005a42:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005a46:	689c                	ld	a5,16(s1)
    80005a48:	0007869b          	sext.w	a3,a5
    80005a4c:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005a50:	9781                	srai	a5,a5,0x20
    80005a52:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a56:	4785                	li	a5,1
    80005a58:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005a5a:	00f48c23          	sb	a5,24(s1)
    80005a5e:	00f48ca3          	sb	a5,25(s1)
    80005a62:	00f48d23          	sb	a5,26(s1)
    80005a66:	00f48da3          	sb	a5,27(s1)
    80005a6a:	00f48e23          	sb	a5,28(s1)
    80005a6e:	00f48ea3          	sb	a5,29(s1)
    80005a72:	00f48f23          	sb	a5,30(s1)
    80005a76:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005a7a:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a7e:	07272823          	sw	s2,112(a4)
}
    80005a82:	60e2                	ld	ra,24(sp)
    80005a84:	6442                	ld	s0,16(sp)
    80005a86:	64a2                	ld	s1,8(sp)
    80005a88:	6902                	ld	s2,0(sp)
    80005a8a:	6105                	addi	sp,sp,32
    80005a8c:	8082                	ret
    panic("could not find virtio disk");
    80005a8e:	00002517          	auipc	a0,0x2
    80005a92:	bd250513          	addi	a0,a0,-1070 # 80007660 <etext+0x660>
    80005a96:	d9ffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005a9a:	00002517          	auipc	a0,0x2
    80005a9e:	be650513          	addi	a0,a0,-1050 # 80007680 <etext+0x680>
    80005aa2:	d93fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005aa6:	00002517          	auipc	a0,0x2
    80005aaa:	bfa50513          	addi	a0,a0,-1030 # 800076a0 <etext+0x6a0>
    80005aae:	d87fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005ab2:	00002517          	auipc	a0,0x2
    80005ab6:	c0e50513          	addi	a0,a0,-1010 # 800076c0 <etext+0x6c0>
    80005aba:	d7bfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005abe:	00002517          	auipc	a0,0x2
    80005ac2:	c2250513          	addi	a0,a0,-990 # 800076e0 <etext+0x6e0>
    80005ac6:	d6ffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005aca:	00002517          	auipc	a0,0x2
    80005ace:	c3650513          	addi	a0,a0,-970 # 80007700 <etext+0x700>
    80005ad2:	d63fa0ef          	jal	80000834 <panic>

0000000080005ad6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ad6:	711d                	addi	sp,sp,-96
    80005ad8:	ec86                	sd	ra,88(sp)
    80005ada:	e8a2                	sd	s0,80(sp)
    80005adc:	e4a6                	sd	s1,72(sp)
    80005ade:	e0ca                	sd	s2,64(sp)
    80005ae0:	fc4e                	sd	s3,56(sp)
    80005ae2:	f852                	sd	s4,48(sp)
    80005ae4:	f456                	sd	s5,40(sp)
    80005ae6:	f05a                	sd	s6,32(sp)
    80005ae8:	ec5e                	sd	s7,24(sp)
    80005aea:	e862                	sd	s8,16(sp)
    80005aec:	1080                	addi	s0,sp,96
    80005aee:	89aa                	mv	s3,a0
    80005af0:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005af2:	00c52b83          	lw	s7,12(a0)
    80005af6:	001b9b9b          	slliw	s7,s7,0x1
    80005afa:	1b82                	slli	s7,s7,0x20
    80005afc:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005b00:	0001e517          	auipc	a0,0x1e
    80005b04:	d9050513          	addi	a0,a0,-624 # 80023890 <disk+0x128>
    80005b08:	920fb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005b0c:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005b0e:	0001ea97          	auipc	s5,0x1e
    80005b12:	c5aa8a93          	addi	s5,s5,-934 # 80023768 <disk>
  for (int i = 0; i < 3; i++) {
    80005b16:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005b18:	5c7d                	li	s8,-1
    80005b1a:	a8a5                	j	80005b92 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005b1c:	00fa8733          	add	a4,s5,a5
    80005b20:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005b24:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005b26:	0207c563          	bltz	a5,80005b50 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005b2a:	2905                	addiw	s2,s2,1
    80005b2c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005b2e:	07490663          	beq	s2,s4,80005b9a <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005b32:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005b34:	0001e717          	auipc	a4,0x1e
    80005b38:	c3470713          	addi	a4,a4,-972 # 80023768 <disk>
    80005b3c:	4781                	li	a5,0
    if (disk.free[i]) {
    80005b3e:	01874683          	lbu	a3,24(a4)
    80005b42:	fee9                	bnez	a3,80005b1c <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005b44:	2785                	addiw	a5,a5,1
    80005b46:	0705                	addi	a4,a4,1
    80005b48:	fe979be3          	bne	a5,s1,80005b3e <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005b4c:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005b50:	01205d63          	blez	s2,80005b6a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b54:	fa042503          	lw	a0,-96(s0)
    80005b58:	d41ff0ef          	jal	80005898 <free_desc>
      for (int j = 0; j < i; j++)
    80005b5c:	4785                	li	a5,1
    80005b5e:	0127d663          	bge	a5,s2,80005b6a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b62:	fa442503          	lw	a0,-92(s0)
    80005b66:	d33ff0ef          	jal	80005898 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005b6a:	0001e517          	auipc	a0,0x1e
    80005b6e:	c1650513          	addi	a0,a0,-1002 # 80023780 <disk+0x18>
    80005b72:	d28fc0ef          	jal	8000209a <sleep_prepare>
    release(&disk.vdisk_lock);
    80005b76:	0001e517          	auipc	a0,0x1e
    80005b7a:	d1a50513          	addi	a0,a0,-742 # 80023890 <disk+0x128>
    80005b7e:	932fb0ef          	jal	80000cb0 <release>
    sleep();
    80005b82:	d54fc0ef          	jal	800020d6 <sleep>
    acquire(&disk.vdisk_lock);
    80005b86:	0001e517          	auipc	a0,0x1e
    80005b8a:	d0a50513          	addi	a0,a0,-758 # 80023890 <disk+0x128>
    80005b8e:	89afb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005b92:	fa040613          	addi	a2,s0,-96
    80005b96:	4901                	li	s2,0
    80005b98:	bf69                	j	80005b32 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b9a:	fa042503          	lw	a0,-96(s0)
    80005b9e:	00451693          	slli	a3,a0,0x4

  if (write)
    80005ba2:	0001e797          	auipc	a5,0x1e
    80005ba6:	bc678793          	addi	a5,a5,-1082 # 80023768 <disk>
    80005baa:	00451713          	slli	a4,a0,0x4
    80005bae:	0a070713          	addi	a4,a4,160
    80005bb2:	973e                	add	a4,a4,a5
    80005bb4:	01603633          	snez	a2,s6
    80005bb8:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005bba:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005bbe:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005bc2:	6398                	ld	a4,0(a5)
    80005bc4:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005bc6:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005bca:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005bcc:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005bce:	6390                	ld	a2,0(a5)
    80005bd0:	00d60833          	add	a6,a2,a3
    80005bd4:	4741                	li	a4,16
    80005bd6:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005bda:	4585                	li	a1,1
    80005bdc:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005be0:	fa442703          	lw	a4,-92(s0)
    80005be4:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005be8:	0712                	slli	a4,a4,0x4
    80005bea:	963a                	add	a2,a2,a4
    80005bec:	05898813          	addi	a6,s3,88
    80005bf0:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005bf4:	0007b883          	ld	a7,0(a5)
    80005bf8:	9746                	add	a4,a4,a7
    80005bfa:	40000613          	li	a2,1024
    80005bfe:	c710                	sw	a2,8(a4)
  if (write)
    80005c00:	001b3613          	seqz	a2,s6
    80005c04:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005c08:	8e4d                	or	a2,a2,a1
    80005c0a:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005c0e:	fa842603          	lw	a2,-88(s0)
    80005c12:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005c16:	00451813          	slli	a6,a0,0x4
    80005c1a:	02080813          	addi	a6,a6,32
    80005c1e:	983e                	add	a6,a6,a5
    80005c20:	577d                	li	a4,-1
    80005c22:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005c26:	0612                	slli	a2,a2,0x4
    80005c28:	98b2                	add	a7,a7,a2
    80005c2a:	03068713          	addi	a4,a3,48
    80005c2e:	973e                	add	a4,a4,a5
    80005c30:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005c34:	6398                	ld	a4,0(a5)
    80005c36:	9732                	add	a4,a4,a2
    80005c38:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005c3a:	4689                	li	a3,2
    80005c3c:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005c40:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005c44:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005c48:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005c4c:	6794                	ld	a3,8(a5)
    80005c4e:	0026d703          	lhu	a4,2(a3)
    80005c52:	8b1d                	andi	a4,a4,7
    80005c54:	0706                	slli	a4,a4,0x1
    80005c56:	96ba                	add	a3,a3,a4
    80005c58:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005c5c:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c60:	6798                	ld	a4,8(a5)
    80005c62:	00275783          	lhu	a5,2(a4)
    80005c66:	2785                	addiw	a5,a5,1
    80005c68:	00f71123          	sh	a5,2(a4)
    80005c6c:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005c70:	100017b7          	lui	a5,0x10001
    80005c74:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005c78:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005c7c:	0001e497          	auipc	s1,0x1e
    80005c80:	c1448493          	addi	s1,s1,-1004 # 80023890 <disk+0x128>
  while (b->disk == 1) {
    80005c84:	892e                	mv	s2,a1
    80005c86:	02b79163          	bne	a5,a1,80005ca8 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005c8a:	854e                	mv	a0,s3
    80005c8c:	c0efc0ef          	jal	8000209a <sleep_prepare>
    release(&disk.vdisk_lock);
    80005c90:	8526                	mv	a0,s1
    80005c92:	81efb0ef          	jal	80000cb0 <release>
    sleep();
    80005c96:	c40fc0ef          	jal	800020d6 <sleep>
    acquire(&disk.vdisk_lock);
    80005c9a:	8526                	mv	a0,s1
    80005c9c:	f8dfa0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005ca0:	0049a783          	lw	a5,4(s3)
    80005ca4:	ff2783e3          	beq	a5,s2,80005c8a <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005ca8:	fa042903          	lw	s2,-96(s0)
    80005cac:	00491713          	slli	a4,s2,0x4
    80005cb0:	02070713          	addi	a4,a4,32
    80005cb4:	0001e797          	auipc	a5,0x1e
    80005cb8:	ab478793          	addi	a5,a5,-1356 # 80023768 <disk>
    80005cbc:	97ba                	add	a5,a5,a4
    80005cbe:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005cc2:	0001e997          	auipc	s3,0x1e
    80005cc6:	aa698993          	addi	s3,s3,-1370 # 80023768 <disk>
    80005cca:	00491713          	slli	a4,s2,0x4
    80005cce:	0009b783          	ld	a5,0(s3)
    80005cd2:	97ba                	add	a5,a5,a4
    80005cd4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005cd8:	854a                	mv	a0,s2
    80005cda:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005cde:	bbbff0ef          	jal	80005898 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005ce2:	8885                	andi	s1,s1,1
    80005ce4:	f0fd                	bnez	s1,80005cca <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005ce6:	0001e517          	auipc	a0,0x1e
    80005cea:	baa50513          	addi	a0,a0,-1110 # 80023890 <disk+0x128>
    80005cee:	fc3fa0ef          	jal	80000cb0 <release>
}
    80005cf2:	60e6                	ld	ra,88(sp)
    80005cf4:	6446                	ld	s0,80(sp)
    80005cf6:	64a6                	ld	s1,72(sp)
    80005cf8:	6906                	ld	s2,64(sp)
    80005cfa:	79e2                	ld	s3,56(sp)
    80005cfc:	7a42                	ld	s4,48(sp)
    80005cfe:	7aa2                	ld	s5,40(sp)
    80005d00:	7b02                	ld	s6,32(sp)
    80005d02:	6be2                	ld	s7,24(sp)
    80005d04:	6c42                	ld	s8,16(sp)
    80005d06:	6125                	addi	sp,sp,96
    80005d08:	8082                	ret

0000000080005d0a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005d0a:	1101                	addi	sp,sp,-32
    80005d0c:	ec06                	sd	ra,24(sp)
    80005d0e:	e822                	sd	s0,16(sp)
    80005d10:	e426                	sd	s1,8(sp)
    80005d12:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005d14:	0001e497          	auipc	s1,0x1e
    80005d18:	a5448493          	addi	s1,s1,-1452 # 80023768 <disk>
    80005d1c:	0001e517          	auipc	a0,0x1e
    80005d20:	b7450513          	addi	a0,a0,-1164 # 80023890 <disk+0x128>
    80005d24:	f05fa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005d28:	100017b7          	lui	a5,0x10001
    80005d2c:	53bc                	lw	a5,96(a5)
    80005d2e:	8b8d                	andi	a5,a5,3
    80005d30:	10001737          	lui	a4,0x10001
    80005d34:	d37c                	sw	a5,100(a4)
    80005d36:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005d3a:	689c                	ld	a5,16(s1)
    80005d3c:	0204d703          	lhu	a4,32(s1)
    80005d40:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005d44:	04f70863          	beq	a4,a5,80005d94 <virtio_disk_intr+0x8a>
    80005d48:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005d4c:	6898                	ld	a4,16(s1)
    80005d4e:	0204d783          	lhu	a5,32(s1)
    80005d52:	8b9d                	andi	a5,a5,7
    80005d54:	078e                	slli	a5,a5,0x3
    80005d56:	97ba                	add	a5,a5,a4
    80005d58:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005d5a:	00479713          	slli	a4,a5,0x4
    80005d5e:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005d62:	9726                	add	a4,a4,s1
    80005d64:	01074703          	lbu	a4,16(a4)
    80005d68:	e329                	bnez	a4,80005daa <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d6a:	0792                	slli	a5,a5,0x4
    80005d6c:	02078793          	addi	a5,a5,32
    80005d70:	97a6                	add	a5,a5,s1
    80005d72:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005d74:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d78:	b92fc0ef          	jal	8000210a <wakeup>

    disk.used_idx += 1;
    80005d7c:	0204d783          	lhu	a5,32(s1)
    80005d80:	2785                	addiw	a5,a5,1
    80005d82:	17c2                	slli	a5,a5,0x30
    80005d84:	93c1                	srli	a5,a5,0x30
    80005d86:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005d8a:	6898                	ld	a4,16(s1)
    80005d8c:	00275703          	lhu	a4,2(a4)
    80005d90:	faf71ce3          	bne	a4,a5,80005d48 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005d94:	0001e517          	auipc	a0,0x1e
    80005d98:	afc50513          	addi	a0,a0,-1284 # 80023890 <disk+0x128>
    80005d9c:	f15fa0ef          	jal	80000cb0 <release>
}
    80005da0:	60e2                	ld	ra,24(sp)
    80005da2:	6442                	ld	s0,16(sp)
    80005da4:	64a2                	ld	s1,8(sp)
    80005da6:	6105                	addi	sp,sp,32
    80005da8:	8082                	ret
      panic("virtio_disk_intr status");
    80005daa:	00002517          	auipc	a0,0x2
    80005dae:	96e50513          	addi	a0,a0,-1682 # 80007718 <etext+0x718>
    80005db2:	a83fa0ef          	jal	80000834 <panic>
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
