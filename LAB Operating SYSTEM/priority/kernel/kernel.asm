
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
    80000004:	37813103          	ld	sp,888(sp) # 8000a378 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdaf37>
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
    8000011c:	3a2020ef          	jal	800024be <either_copyin>
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
    80000198:	22c50513          	addi	a0,a0,556 # 800123c0 <cons>
    8000019c:	28d000ef          	jal	80000c28 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	22048493          	addi	s1,s1,544 # 800123c0 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	2b090913          	addi	s2,s2,688 # 80012458 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	788010ef          	jal	80001948 <myproc>
    800001c4:	17a020ef          	jal	8000233e <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	715010ef          	jal	800020e0 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	747010ef          	jal	8000211c <sleep>
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
    800001f2:	1d270713          	addi	a4,a4,466 # 800123c0 <cons>
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
    80000220:	252020ef          	jal	80002472 <either_copyout>
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
    8000023c:	18850513          	addi	a0,a0,392 # 800123c0 <cons>
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
    80000262:	1ef72d23          	sw	a5,506(a4) # 80012458 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	14c50513          	addi	a0,a0,332 # 800123c0 <cons>
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
    800002cc:	0f850513          	addi	a0,a0,248 # 800123c0 <cons>
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
    800002ea:	220020ef          	jal	8000250a <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	0d250513          	addi	a0,a0,210 # 800123c0 <cons>
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
    80000310:	0b470713          	addi	a4,a4,180 # 800123c0 <cons>
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
    80000336:	08e70713          	addi	a4,a4,142 # 800123c0 <cons>
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
    80000360:	0fc72703          	lw	a4,252(a4) # 80012458 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	04e70713          	addi	a4,a4,78 # 800123c0 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	03e48493          	addi	s1,s1,62 # 800123c0 <cons>
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
    800003c8:	ffc70713          	addi	a4,a4,-4 # 800123c0 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	08f72323          	sw	a5,134(a4) # 80012460 <cons+0xa0>
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
    800003fc:	fc878793          	addi	a5,a5,-56 # 800123c0 <cons>
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
    8000041e:	04c7a123          	sw	a2,66(a5) # 8001245c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	03650513          	addi	a0,a0,54 # 80012458 <cons+0x98>
    8000042a:	523010ef          	jal	8000214c <wakeup>
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
    80000444:	f8050513          	addi	a0,a0,-128 # 800123c0 <cons>
    80000448:	760000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	2e078793          	addi	a5,a5,736 # 80022730 <devsw>
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
    8000052c:	e6c7a783          	lw	a5,-404(a5) # 8000a394 <panicking>
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
    80000572:	efa50513          	addi	a0,a0,-262 # 80012468 <pr>
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
    8000076e:	c2a7a783          	lw	a5,-982(a5) # 8000a394 <panicking>
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
    80000798:	cd450513          	addi	a0,a0,-812 # 80012468 <pr>
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
    80000848:	b497a823          	sw	s1,-1200(a5) # 8000a394 <panicking>
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
    8000086a:	b297a523          	sw	s1,-1238(a5) # 8000a390 <panicked>
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
    80000884:	be850513          	addi	a0,a0,-1048 # 80012468 <pr>
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
    800008da:	baa50513          	addi	a0,a0,-1110 # 80012480 <tx_lock>
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
    800008fe:	b8650513          	addi	a0,a0,-1146 # 80012480 <tx_lock>
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
    8000091c:	a8490913          	addi	s2,s2,-1404 # 8000a39c <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	a7898993          	addi	s3,s3,-1416 # 8000a398 <tx_chan>
      release(&tx_lock);
    80000928:	00012497          	auipc	s1,0x12
    8000092c:	b5848493          	addi	s1,s1,-1192 # 80012480 <tx_lock>
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
    8000093a:	7a6010ef          	jal	800020e0 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	7d8010ef          	jal	8000211c <sleep>
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
    8000097c:	b0850513          	addi	a0,a0,-1272 # 80012480 <tx_lock>
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
    800009a0:	9f87a783          	lw	a5,-1544(a5) # 8000a394 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	9ea7a783          	lw	a5,-1558(a5) # 8000a390 <panicked>
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
    800009d0:	9c87a783          	lw	a5,-1592(a5) # 8000a394 <panicking>
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
    80000a06:	a7e50513          	addi	a0,a0,-1410 # 80012480 <tx_lock>
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
    80000a20:	a6450513          	addi	a0,a0,-1436 # 80012480 <tx_lock>
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
    80000a48:	9407ac23          	sw	zero,-1704(a5) # 8000a39c <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	94c50513          	addi	a0,a0,-1716 # 8000a398 <tx_chan>
    80000a54:	6f8010ef          	jal	8000214c <wakeup>
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
    80000a76:	e5678793          	addi	a5,a5,-426 # 800238c8 <end>
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
    80000aa0:	9fc90913          	addi	s2,s2,-1540 # 80012498 <kmem>
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
    80000b2e:	96e50513          	addi	a0,a0,-1682 # 80012498 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00023517          	auipc	a0,0x23
    80000b3e:	d8e50513          	addi	a0,a0,-626 # 800238c8 <end>
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
    80000b5c:	94050513          	addi	a0,a0,-1728 # 80012498 <kmem>
    80000b60:	0c8000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b64:	00012497          	auipc	s1,0x12
    80000b68:	94c4b483          	ld	s1,-1716(s1) # 800124b0 <kmem+0x18>
  if (r)
    80000b6c:	c49d                	beqz	s1,80000b9a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00012717          	auipc	a4,0x12
    80000b74:	94f73023          	sd	a5,-1728(a4) # 800124b0 <kmem+0x18>
  release(&kmem.lock);
    80000b78:	00012517          	auipc	a0,0x12
    80000b7c:	92050513          	addi	a0,a0,-1760 # 80012498 <kmem>
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
    80000b9e:	8fe50513          	addi	a0,a0,-1794 # 80012498 <kmem>
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
    80000eae:	4f670713          	addi	a4,a4,1270 # 8000a3a0 <started>
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
    80000ed4:	768010ef          	jal	8000263c <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	191040ef          	jal	80005868 <plicinithart>
  }

  scheduler();
    80000edc:	7ef000ef          	jal	80001eca <scheduler>
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
    80000f1c:	6fc010ef          	jal	80002618 <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	71c010ef          	jal	8000263c <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	12b040ef          	jal	8000584e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	141040ef          	jal	80005868 <plicinithart>
    binit();            // buffer cache
    80000f2c:	5e3010ef          	jal	80002d0e <binit>
    iinit();            // inode table
    80000f30:	334020ef          	jal	80003264 <iinit>
    fileinit();         // file table
    80000f34:	362030ef          	jal	80004296 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	227040ef          	jal	8000595e <virtio_disk_init>
    userinit();         // first user process
    80000f3c:	4e3000ef          	jal	80001c1e <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f40:	00009797          	auipc	a5,0x9
    80000f44:	46078793          	addi	a5,a5,1120 # 8000a3a0 <started>
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
    80000f62:	44a7b783          	ld	a5,1098(a5) # 8000a3a8 <kernel_pagetable>
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
    800011ee:	1aa7bf23          	sd	a0,446(a5) # 8000a3a8 <kernel_pagetable>
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
    80001724:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb738>
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
    800017d8:	11448493          	addi	s1,s1,276 # 800128e8 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017dc:	8c26                	mv	s8,s1
    800017de:	ff4df937          	lui	s2,0xff4df
    800017e2:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb0f5>
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
    80001808:	ce4a8a93          	addi	s5,s5,-796 # 800184e8 <tickslock>
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
    8000187e:	c3e50513          	addi	a0,a0,-962 # 800124b8 <pid_lock>
    80001882:	b26ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001886:	00006597          	auipc	a1,0x6
    8000188a:	8e258593          	addi	a1,a1,-1822 # 80007168 <etext+0x168>
    8000188e:	00011517          	auipc	a0,0x11
    80001892:	c4250513          	addi	a0,a0,-958 # 800124d0 <wait_lock>
    80001896:	b12ff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000189a:	00011497          	auipc	s1,0x11
    8000189e:	04e48493          	addi	s1,s1,78 # 800128e8 <proc>
    initlock(&p->lock, "proc");
    800018a2:	00006b17          	auipc	s6,0x6
    800018a6:	8d6b0b13          	addi	s6,s6,-1834 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018aa:	8aa6                	mv	s5,s1
    800018ac:	ff4df937          	lui	s2,0xff4df
    800018b0:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb0f5>
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
    800018d2:	c1aa0a13          	addi	s4,s4,-998 # 800184e8 <tickslock>
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
    8000193a:	bb250513          	addi	a0,a0,-1102 # 800124e8 <cpus>
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
    80001960:	b5c70713          	addi	a4,a4,-1188 # 800124b8 <pid_lock>
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
    80001992:	9d27a783          	lw	a5,-1582(a5) # 8000a360 <first.1>
    80001996:	cf85                	beqz	a5,800019ce <forkret+0x54>
    first = 0;
    80001998:	00009797          	auipc	a5,0x9
    8000199c:	9c07a423          	sw	zero,-1592(a5) # 8000a360 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019a0:	4505                	li	a0,1
    800019a2:	5c7010ef          	jal	80003768 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019a6:	00005797          	auipc	a5,0x5
    800019aa:	7da78793          	addi	a5,a5,2010 # 80007180 <etext+0x180>
    800019ae:	fcf43823          	sd	a5,-48(s0)
    800019b2:	fc043c23          	sd	zero,-40(s0)
    800019b6:	fd040593          	addi	a1,s0,-48
    800019ba:	853e                	mv	a0,a5
    800019bc:	060030ef          	jal	80004a1c <kexec>
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
    800019ce:	48b000ef          	jal	80002658 <prepare_return>
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
    80001a1e:	a9e50513          	addi	a0,a0,-1378 # 800124b8 <pid_lock>
    80001a22:	a06ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a26:	00009797          	auipc	a5,0x9
    80001a2a:	93e78793          	addi	a5,a5,-1730 # 8000a364 <nextpid>
    80001a2e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a30:	0014871b          	addiw	a4,s1,1
    80001a34:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a36:	00011517          	auipc	a0,0x11
    80001a3a:	a8250513          	addi	a0,a0,-1406 # 800124b8 <pid_lock>
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
    80001b7e:	d6e48493          	addi	s1,s1,-658 # 800128e8 <proc>
    80001b82:	00017917          	auipc	s2,0x17
    80001b86:	96690913          	addi	s2,s2,-1690 # 800184e8 <tickslock>
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
    80001c32:	78a7b123          	sd	a0,1922(a5) # 8000a3b0 <initproc>
  p->cwd = namei("/");
    80001c36:	00005517          	auipc	a0,0x5
    80001c3a:	55a50513          	addi	a0,a0,1370 # 80007190 <etext+0x190>
    80001c3e:	088020ef          	jal	80003cc6 <namei>
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
    80001d56:	5c2020ef          	jal	80004318 <filedup>
    80001d5a:	00a93023          	sd	a0,0(s2)
    80001d5e:	b7f5                	j	80001d4a <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d60:	150ab503          	ld	a0,336(s5)
    80001d64:	692010ef          	jal	800033f6 <idup>
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
    80001d88:	74c50513          	addi	a0,a0,1868 # 800124d0 <wait_lock>
    80001d8c:	e9dfe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001d90:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d94:	00010517          	auipc	a0,0x10
    80001d98:	73c50513          	addi	a0,a0,1852 # 800124d0 <wait_lock>
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
    80001dec:	b0048493          	addi	s1,s1,-1280 # 800128e8 <proc>
    80001df0:	00016997          	auipc	s3,0x16
    80001df4:	6f898993          	addi	s3,s3,1784 # 800184e8 <tickslock>
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

0000000080001e52 <update_proc_aging>:
{
    80001e52:	7139                	addi	sp,sp,-64
    80001e54:	fc06                	sd	ra,56(sp)
    80001e56:	f822                	sd	s0,48(sp)
    80001e58:	f426                	sd	s1,40(sp)
    80001e5a:	f04a                	sd	s2,32(sp)
    80001e5c:	ec4e                	sd	s3,24(sp)
    80001e5e:	e852                	sd	s4,16(sp)
    80001e60:	e456                	sd	s5,8(sp)
    80001e62:	0080                	addi	s0,sp,64
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e64:	00011497          	auipc	s1,0x11
    80001e68:	a8448493          	addi	s1,s1,-1404 # 800128e8 <proc>
    if (p->state == RUNNABLE) {
    80001e6c:	498d                	li	s3,3
      if (p->wait_ticks > 30) {
    80001e6e:	4a79                	li	s4,30
        if (p->priority > 1) {
    80001e70:	4a85                	li	s5,1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e72:	00016917          	auipc	s2,0x16
    80001e76:	67690913          	addi	s2,s2,1654 # 800184e8 <tickslock>
    80001e7a:	a811                	j	80001e8e <update_proc_aging+0x3c>
        p->wait_ticks = 0;
    80001e7c:	1604a623          	sw	zero,364(s1)
    release(&p->lock);
    80001e80:	8526                	mv	a0,s1
    80001e82:	e2ffe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e86:	17048493          	addi	s1,s1,368
    80001e8a:	03248763          	beq	s1,s2,80001eb8 <update_proc_aging+0x66>
    acquire(&p->lock);
    80001e8e:	8526                	mv	a0,s1
    80001e90:	d99fe0ef          	jal	80000c28 <acquire>
    if (p->state == RUNNABLE) {
    80001e94:	4c9c                	lw	a5,24(s1)
    80001e96:	ff3795e3          	bne	a5,s3,80001e80 <update_proc_aging+0x2e>
      p->wait_ticks++;
    80001e9a:	16c4a783          	lw	a5,364(s1)
    80001e9e:	2785                	addiw	a5,a5,1
    80001ea0:	16f4a623          	sw	a5,364(s1)
      if (p->wait_ticks > 30) {
    80001ea4:	fcfa7ee3          	bgeu	s4,a5,80001e80 <update_proc_aging+0x2e>
        if (p->priority > 1) {
    80001ea8:	1684a783          	lw	a5,360(s1)
    80001eac:	fcfad8e3          	bge	s5,a5,80001e7c <update_proc_aging+0x2a>
          p->priority--; // Raise priority (1 = highest)
    80001eb0:	37fd                	addiw	a5,a5,-1
    80001eb2:	16f4a423          	sw	a5,360(s1)
    80001eb6:	b7d9                	j	80001e7c <update_proc_aging+0x2a>
}
    80001eb8:	70e2                	ld	ra,56(sp)
    80001eba:	7442                	ld	s0,48(sp)
    80001ebc:	74a2                	ld	s1,40(sp)
    80001ebe:	7902                	ld	s2,32(sp)
    80001ec0:	69e2                	ld	s3,24(sp)
    80001ec2:	6a42                	ld	s4,16(sp)
    80001ec4:	6aa2                	ld	s5,8(sp)
    80001ec6:	6121                	addi	sp,sp,64
    80001ec8:	8082                	ret

0000000080001eca <scheduler>:
{
    80001eca:	7119                	addi	sp,sp,-128
    80001ecc:	fc86                	sd	ra,120(sp)
    80001ece:	f8a2                	sd	s0,112(sp)
    80001ed0:	f4a6                	sd	s1,104(sp)
    80001ed2:	f0ca                	sd	s2,96(sp)
    80001ed4:	ecce                	sd	s3,88(sp)
    80001ed6:	e8d2                	sd	s4,80(sp)
    80001ed8:	e4d6                	sd	s5,72(sp)
    80001eda:	e0da                	sd	s6,64(sp)
    80001edc:	fc5e                	sd	s7,56(sp)
    80001ede:	f862                	sd	s8,48(sp)
    80001ee0:	f466                	sd	s9,40(sp)
    80001ee2:	f06a                	sd	s10,32(sp)
    80001ee4:	ec6e                	sd	s11,24(sp)
    80001ee6:	0100                	addi	s0,sp,128
    80001ee8:	8792                	mv	a5,tp
  int id = r_tp();
    80001eea:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001eec:	00779693          	slli	a3,a5,0x7
    80001ef0:	00010717          	auipc	a4,0x10
    80001ef4:	5c870713          	addi	a4,a4,1480 # 800124b8 <pid_lock>
    80001ef8:	9736                	add	a4,a4,a3
    80001efa:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &best_p->context);
    80001efe:	00010717          	auipc	a4,0x10
    80001f02:	5f270713          	addi	a4,a4,1522 # 800124f0 <cpus+0x8>
    80001f06:	9736                	add	a4,a4,a3
    80001f08:	f8e43423          	sd	a4,-120(s0)
  int last_idx = -1;
    80001f0c:	5cfd                	li	s9,-1
        p = &proc[idx];
    80001f0e:	17000b13          	li	s6,368
    80001f12:	00011a97          	auipc	s5,0x11
    80001f16:	9d6a8a93          	addi	s5,s5,-1578 # 800128e8 <proc>
      c->proc = best_p;
    80001f1a:	00010d97          	auipc	s11,0x10
    80001f1e:	59ed8d93          	addi	s11,s11,1438 # 800124b8 <pid_lock>
    80001f22:	00dd8d33          	add	s10,s11,a3
    80001f26:	a855                	j	80001fda <scheduler+0x110>
      if (p->state == RUNNABLE && p->priority < min_prio) {
    80001f28:	0007099b          	sext.w	s3,a4
      release(&p->lock);
    80001f2c:	8526                	mv	a0,s1
    80001f2e:	d83fe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f32:	17048493          	addi	s1,s1,368
    80001f36:	03248063          	beq	s1,s2,80001f56 <scheduler+0x8c>
      acquire(&p->lock);
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	cedfe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE && p->priority < min_prio) {
    80001f40:	4c9c                	lw	a5,24(s1)
    80001f42:	ff4795e3          	bne	a5,s4,80001f2c <scheduler+0x62>
    80001f46:	1684a783          	lw	a5,360(s1)
    80001f4a:	873e                	mv	a4,a5
    80001f4c:	2781                	sext.w	a5,a5
    80001f4e:	fcf9dde3          	bge	s3,a5,80001f28 <scheduler+0x5e>
    80001f52:	874e                	mv	a4,s3
    80001f54:	bfd1                	j	80001f28 <scheduler+0x5e>
    if (min_prio <= 20) {
    80001f56:	47d1                	li	a5,20
    80001f58:	0737cf63          	blt	a5,s3,80001fd6 <scheduler+0x10c>
    80001f5c:	001c8a1b          	addiw	s4,s9,1
    80001f60:	041c8c1b          	addiw	s8,s9,65
        if (p->state == RUNNABLE && p->priority == min_prio) {
    80001f64:	4b8d                	li	s7,3
    80001f66:	a039                	j	80001f74 <scheduler+0xaa>
        release(&p->lock);
    80001f68:	854a                	mv	a0,s2
    80001f6a:	d47fe0ef          	jal	80000cb0 <release>
      for (int i = 0; i < NPROC; i++) {
    80001f6e:	2a05                	addiw	s4,s4,1
    80001f70:	078a0363          	beq	s4,s8,80001fd6 <scheduler+0x10c>
        int idx = (last_idx + 1 + i) % NPROC;
    80001f74:	41fa579b          	sraiw	a5,s4,0x1f
    80001f78:	01a7d79b          	srliw	a5,a5,0x1a
    80001f7c:	014784bb          	addw	s1,a5,s4
    80001f80:	03f4f493          	andi	s1,s1,63
    80001f84:	9c9d                	subw	s1,s1,a5
        p = &proc[idx];
    80001f86:	03648933          	mul	s2,s1,s6
    80001f8a:	9956                	add	s2,s2,s5
        acquire(&p->lock);
    80001f8c:	854a                	mv	a0,s2
    80001f8e:	c9bfe0ef          	jal	80000c28 <acquire>
        if (p->state == RUNNABLE && p->priority == min_prio) {
    80001f92:	01892783          	lw	a5,24(s2)
    80001f96:	fd7799e3          	bne	a5,s7,80001f68 <scheduler+0x9e>
    80001f9a:	16892783          	lw	a5,360(s2)
    80001f9e:	fd3795e3          	bne	a5,s3,80001f68 <scheduler+0x9e>
      best_p->wait_ticks = 0; // Reset wait ticks as process is scheduled
    80001fa2:	16092623          	sw	zero,364(s2)
      best_p->state = RUNNING;
    80001fa6:	4791                	li	a5,4
    80001fa8:	00f92c23          	sw	a5,24(s2)
      c->proc = best_p;
    80001fac:	032d3823          	sd	s2,48(s10) # fffffffffffff030 <end+0xffffffff7ffdb768>
      swtch(&c->context, &best_p->context);
    80001fb0:	06090593          	addi	a1,s2,96
    80001fb4:	f8843503          	ld	a0,-120(s0)
    80001fb8:	5f6000ef          	jal	800025ae <swtch>
    80001fbc:	8792                	mv	a5,tp
      mycpu()->intena = 0;
    80001fbe:	2781                	sext.w	a5,a5
    80001fc0:	079e                	slli	a5,a5,0x7
    80001fc2:	97ee                	add	a5,a5,s11
    80001fc4:	0a07a623          	sw	zero,172(a5)
      c->proc = 0;
    80001fc8:	020d3823          	sd	zero,48(s10)
      release(&best_p->lock);
    80001fcc:	854a                	mv	a0,s2
    80001fce:	ce3fe0ef          	jal	80000cb0 <release>
          last_idx = idx;
    80001fd2:	8ca6                	mv	s9,s1
    80001fd4:	a019                	j	80001fda <scheduler+0x110>
      asm volatile("wfi");
    80001fd6:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001fda:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001fde:	10017073          	csrci	sstatus,2
    int min_prio = 21;
    80001fe2:	49d5                	li	s3,21
    for (p = proc; p < &proc[NPROC]; p++) {
    80001fe4:	00011497          	auipc	s1,0x11
    80001fe8:	90448493          	addi	s1,s1,-1788 # 800128e8 <proc>
      if (p->state == RUNNABLE && p->priority < min_prio) {
    80001fec:	4a0d                	li	s4,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001fee:	00016917          	auipc	s2,0x16
    80001ff2:	4fa90913          	addi	s2,s2,1274 # 800184e8 <tickslock>
    80001ff6:	b791                	j	80001f3a <scheduler+0x70>

0000000080001ff8 <sched>:
{
    80001ff8:	7179                	addi	sp,sp,-48
    80001ffa:	f406                	sd	ra,40(sp)
    80001ffc:	f022                	sd	s0,32(sp)
    80001ffe:	ec26                	sd	s1,24(sp)
    80002000:	e84a                	sd	s2,16(sp)
    80002002:	e44e                	sd	s3,8(sp)
    80002004:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002006:	943ff0ef          	jal	80001948 <myproc>
    8000200a:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000200c:	bb7fe0ef          	jal	80000bc2 <holding>
    80002010:	c935                	beqz	a0,80002084 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80002012:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002014:	2781                	sext.w	a5,a5
    80002016:	079e                	slli	a5,a5,0x7
    80002018:	00010717          	auipc	a4,0x10
    8000201c:	4a070713          	addi	a4,a4,1184 # 800124b8 <pid_lock>
    80002020:	97ba                	add	a5,a5,a4
    80002022:	0a87a703          	lw	a4,168(a5)
    80002026:	4785                	li	a5,1
    80002028:	06f71463          	bne	a4,a5,80002090 <sched+0x98>
  if (p->state == RUNNING)
    8000202c:	4c98                	lw	a4,24(s1)
    8000202e:	4791                	li	a5,4
    80002030:	06f70663          	beq	a4,a5,8000209c <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002034:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002038:	8b89                	andi	a5,a5,2
  if (intr_get())
    8000203a:	e7bd                	bnez	a5,800020a8 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    8000203c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000203e:	00010917          	auipc	s2,0x10
    80002042:	47a90913          	addi	s2,s2,1146 # 800124b8 <pid_lock>
    80002046:	2781                	sext.w	a5,a5
    80002048:	079e                	slli	a5,a5,0x7
    8000204a:	97ca                	add	a5,a5,s2
    8000204c:	0ac7a983          	lw	s3,172(a5)
    80002050:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002052:	2781                	sext.w	a5,a5
    80002054:	079e                	slli	a5,a5,0x7
    80002056:	07a1                	addi	a5,a5,8
    80002058:	00010597          	auipc	a1,0x10
    8000205c:	49058593          	addi	a1,a1,1168 # 800124e8 <cpus>
    80002060:	95be                	add	a1,a1,a5
    80002062:	06048513          	addi	a0,s1,96
    80002066:	548000ef          	jal	800025ae <swtch>
    8000206a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000206c:	2781                	sext.w	a5,a5
    8000206e:	079e                	slli	a5,a5,0x7
    80002070:	993e                	add	s2,s2,a5
    80002072:	0b392623          	sw	s3,172(s2)
}
    80002076:	70a2                	ld	ra,40(sp)
    80002078:	7402                	ld	s0,32(sp)
    8000207a:	64e2                	ld	s1,24(sp)
    8000207c:	6942                	ld	s2,16(sp)
    8000207e:	69a2                	ld	s3,8(sp)
    80002080:	6145                	addi	sp,sp,48
    80002082:	8082                	ret
    panic("sched p->lock");
    80002084:	00005517          	auipc	a0,0x5
    80002088:	11450513          	addi	a0,a0,276 # 80007198 <etext+0x198>
    8000208c:	fa8fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80002090:	00005517          	auipc	a0,0x5
    80002094:	11850513          	addi	a0,a0,280 # 800071a8 <etext+0x1a8>
    80002098:	f9cfe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    8000209c:	00005517          	auipc	a0,0x5
    800020a0:	11c50513          	addi	a0,a0,284 # 800071b8 <etext+0x1b8>
    800020a4:	f90fe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    800020a8:	00005517          	auipc	a0,0x5
    800020ac:	12050513          	addi	a0,a0,288 # 800071c8 <etext+0x1c8>
    800020b0:	f84fe0ef          	jal	80000834 <panic>

00000000800020b4 <yield>:
{
    800020b4:	1101                	addi	sp,sp,-32
    800020b6:	ec06                	sd	ra,24(sp)
    800020b8:	e822                	sd	s0,16(sp)
    800020ba:	e426                	sd	s1,8(sp)
    800020bc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020be:	88bff0ef          	jal	80001948 <myproc>
    800020c2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020c4:	b65fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    800020c8:	478d                	li	a5,3
    800020ca:	cc9c                	sw	a5,24(s1)
  sched();
    800020cc:	f2dff0ef          	jal	80001ff8 <sched>
  release(&p->lock);
    800020d0:	8526                	mv	a0,s1
    800020d2:	bdffe0ef          	jal	80000cb0 <release>
}
    800020d6:	60e2                	ld	ra,24(sp)
    800020d8:	6442                	ld	s0,16(sp)
    800020da:	64a2                	ld	s1,8(sp)
    800020dc:	6105                	addi	sp,sp,32
    800020de:	8082                	ret

00000000800020e0 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    800020e0:	1101                	addi	sp,sp,-32
    800020e2:	ec06                	sd	ra,24(sp)
    800020e4:	e822                	sd	s0,16(sp)
    800020e6:	e426                	sd	s1,8(sp)
    800020e8:	e04a                	sd	s2,0(sp)
    800020ea:	1000                	addi	s0,sp,32
    800020ec:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800020ee:	85bff0ef          	jal	80001948 <myproc>
    800020f2:	892a                	mv	s2,a0

  acquire(&p->lock);
    800020f4:	b35fe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    800020f8:	cc81                	beqz	s1,80002110 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    800020fa:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    800020fe:	854a                	mv	a0,s2
    80002100:	bb1fe0ef          	jal	80000cb0 <release>
}
    80002104:	60e2                	ld	ra,24(sp)
    80002106:	6442                	ld	s0,16(sp)
    80002108:	64a2                	ld	s1,8(sp)
    8000210a:	6902                	ld	s2,0(sp)
    8000210c:	6105                	addi	sp,sp,32
    8000210e:	8082                	ret
    panic("sleep_prepare: zero chan");
    80002110:	00005517          	auipc	a0,0x5
    80002114:	0d050513          	addi	a0,a0,208 # 800071e0 <etext+0x1e0>
    80002118:	f1cfe0ef          	jal	80000834 <panic>

000000008000211c <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    8000211c:	1101                	addi	sp,sp,-32
    8000211e:	ec06                	sd	ra,24(sp)
    80002120:	e822                	sd	s0,16(sp)
    80002122:	e426                	sd	s1,8(sp)
    80002124:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002126:	823ff0ef          	jal	80001948 <myproc>
    8000212a:	84aa                	mv	s1,a0

  acquire(&p->lock);
    8000212c:	afdfe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    80002130:	709c                	ld	a5,32(s1)
    80002132:	c789                	beqz	a5,8000213c <sleep+0x20>
    p->state = SLEEPING;
    80002134:	4789                	li	a5,2
    80002136:	cc9c                	sw	a5,24(s1)
    sched();
    80002138:	ec1ff0ef          	jal	80001ff8 <sched>
  }
  release(&p->lock);
    8000213c:	8526                	mv	a0,s1
    8000213e:	b73fe0ef          	jal	80000cb0 <release>
}
    80002142:	60e2                	ld	ra,24(sp)
    80002144:	6442                	ld	s0,16(sp)
    80002146:	64a2                	ld	s1,8(sp)
    80002148:	6105                	addi	sp,sp,32
    8000214a:	8082                	ret

000000008000214c <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    8000214c:	7139                	addi	sp,sp,-64
    8000214e:	fc06                	sd	ra,56(sp)
    80002150:	f822                	sd	s0,48(sp)
    80002152:	f426                	sd	s1,40(sp)
    80002154:	f04a                	sd	s2,32(sp)
    80002156:	ec4e                	sd	s3,24(sp)
    80002158:	e852                	sd	s4,16(sp)
    8000215a:	e456                	sd	s5,8(sp)
    8000215c:	0080                	addi	s0,sp,64
    8000215e:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002160:	00010497          	auipc	s1,0x10
    80002164:	78848493          	addi	s1,s1,1928 # 800128e8 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80002168:	4a09                	li	s4,2
        p->state = RUNNABLE;
    8000216a:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    8000216c:	00016997          	auipc	s3,0x16
    80002170:	37c98993          	addi	s3,s3,892 # 800184e8 <tickslock>
    80002174:	a801                	j	80002184 <wakeup+0x38>
      }
    }
    release(&p->lock);
    80002176:	8526                	mv	a0,s1
    80002178:	b39fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000217c:	17048493          	addi	s1,s1,368
    80002180:	03348063          	beq	s1,s3,800021a0 <wakeup+0x54>
    acquire(&p->lock);
    80002184:	8526                	mv	a0,s1
    80002186:	aa3fe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    8000218a:	709c                	ld	a5,32(s1)
    8000218c:	ff2795e3          	bne	a5,s2,80002176 <wakeup+0x2a>
      p->chan = 0;
    80002190:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80002194:	4c9c                	lw	a5,24(s1)
    80002196:	ff4790e3          	bne	a5,s4,80002176 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000219a:	0154ac23          	sw	s5,24(s1)
    8000219e:	bfe1                	j	80002176 <wakeup+0x2a>
  }
}
    800021a0:	70e2                	ld	ra,56(sp)
    800021a2:	7442                	ld	s0,48(sp)
    800021a4:	74a2                	ld	s1,40(sp)
    800021a6:	7902                	ld	s2,32(sp)
    800021a8:	69e2                	ld	s3,24(sp)
    800021aa:	6a42                	ld	s4,16(sp)
    800021ac:	6aa2                	ld	s5,8(sp)
    800021ae:	6121                	addi	sp,sp,64
    800021b0:	8082                	ret

00000000800021b2 <reparent>:
{
    800021b2:	7179                	addi	sp,sp,-48
    800021b4:	f406                	sd	ra,40(sp)
    800021b6:	f022                	sd	s0,32(sp)
    800021b8:	ec26                	sd	s1,24(sp)
    800021ba:	e84a                	sd	s2,16(sp)
    800021bc:	e44e                	sd	s3,8(sp)
    800021be:	e052                	sd	s4,0(sp)
    800021c0:	1800                	addi	s0,sp,48
    800021c2:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021c4:	00010497          	auipc	s1,0x10
    800021c8:	72448493          	addi	s1,s1,1828 # 800128e8 <proc>
      pp->parent = initproc;
    800021cc:	00008a17          	auipc	s4,0x8
    800021d0:	1e4a0a13          	addi	s4,s4,484 # 8000a3b0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021d4:	00016997          	auipc	s3,0x16
    800021d8:	31498993          	addi	s3,s3,788 # 800184e8 <tickslock>
    800021dc:	a029                	j	800021e6 <reparent+0x34>
    800021de:	17048493          	addi	s1,s1,368
    800021e2:	01348b63          	beq	s1,s3,800021f8 <reparent+0x46>
    if (pp->parent == p) {
    800021e6:	7c9c                	ld	a5,56(s1)
    800021e8:	ff279be3          	bne	a5,s2,800021de <reparent+0x2c>
      pp->parent = initproc;
    800021ec:	000a3503          	ld	a0,0(s4)
    800021f0:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021f2:	f5bff0ef          	jal	8000214c <wakeup>
    800021f6:	b7e5                	j	800021de <reparent+0x2c>
}
    800021f8:	70a2                	ld	ra,40(sp)
    800021fa:	7402                	ld	s0,32(sp)
    800021fc:	64e2                	ld	s1,24(sp)
    800021fe:	6942                	ld	s2,16(sp)
    80002200:	69a2                	ld	s3,8(sp)
    80002202:	6a02                	ld	s4,0(sp)
    80002204:	6145                	addi	sp,sp,48
    80002206:	8082                	ret

0000000080002208 <kexit>:
{
    80002208:	7179                	addi	sp,sp,-48
    8000220a:	f406                	sd	ra,40(sp)
    8000220c:	f022                	sd	s0,32(sp)
    8000220e:	ec26                	sd	s1,24(sp)
    80002210:	e84a                	sd	s2,16(sp)
    80002212:	e44e                	sd	s3,8(sp)
    80002214:	e052                	sd	s4,0(sp)
    80002216:	1800                	addi	s0,sp,48
    80002218:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000221a:	f2eff0ef          	jal	80001948 <myproc>
    8000221e:	89aa                	mv	s3,a0
  if (p == initproc)
    80002220:	00008797          	auipc	a5,0x8
    80002224:	1907b783          	ld	a5,400(a5) # 8000a3b0 <initproc>
    80002228:	0d050493          	addi	s1,a0,208
    8000222c:	15050913          	addi	s2,a0,336
    80002230:	00a79b63          	bne	a5,a0,80002246 <kexit+0x3e>
    panic("init exiting");
    80002234:	00005517          	auipc	a0,0x5
    80002238:	fcc50513          	addi	a0,a0,-52 # 80007200 <etext+0x200>
    8000223c:	df8fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002240:	04a1                	addi	s1,s1,8
    80002242:	01248963          	beq	s1,s2,80002254 <kexit+0x4c>
    if (p->ofile[fd]) {
    80002246:	6088                	ld	a0,0(s1)
    80002248:	dd65                	beqz	a0,80002240 <kexit+0x38>
      fileclose(f);
    8000224a:	114020ef          	jal	8000435e <fileclose>
      p->ofile[fd] = 0;
    8000224e:	0004b023          	sd	zero,0(s1)
    80002252:	b7fd                	j	80002240 <kexit+0x38>
  begin_op();
    80002254:	451010ef          	jal	80003ea4 <begin_op>
  iput(p->cwd);
    80002258:	1509b503          	ld	a0,336(s3)
    8000225c:	352010ef          	jal	800035ae <iput>
  end_op();
    80002260:	4d1010ef          	jal	80003f30 <end_op>
  p->cwd = 0;
    80002264:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002268:	00010517          	auipc	a0,0x10
    8000226c:	26850513          	addi	a0,a0,616 # 800124d0 <wait_lock>
    80002270:	9b9fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    80002274:	854e                	mv	a0,s3
    80002276:	f3dff0ef          	jal	800021b2 <reparent>
  wakeup(p->parent);
    8000227a:	0389b503          	ld	a0,56(s3)
    8000227e:	ecfff0ef          	jal	8000214c <wakeup>
  acquire(&p->lock);
    80002282:	854e                	mv	a0,s3
    80002284:	9a5fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    80002288:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000228c:	4795                	li	a5,5
    8000228e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002292:	00010517          	auipc	a0,0x10
    80002296:	23e50513          	addi	a0,a0,574 # 800124d0 <wait_lock>
    8000229a:	a17fe0ef          	jal	80000cb0 <release>
  sched();
    8000229e:	d5bff0ef          	jal	80001ff8 <sched>
  panic("zombie exit");
    800022a2:	00005517          	auipc	a0,0x5
    800022a6:	f6e50513          	addi	a0,a0,-146 # 80007210 <etext+0x210>
    800022aa:	d8afe0ef          	jal	80000834 <panic>

00000000800022ae <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    800022ae:	c525                	beqz	a0,80002316 <kkill+0x68>
{
    800022b0:	7179                	addi	sp,sp,-48
    800022b2:	f406                	sd	ra,40(sp)
    800022b4:	f022                	sd	s0,32(sp)
    800022b6:	ec26                	sd	s1,24(sp)
    800022b8:	e84a                	sd	s2,16(sp)
    800022ba:	e44e                	sd	s3,8(sp)
    800022bc:	1800                	addi	s0,sp,48
    800022be:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    800022c0:	00010497          	auipc	s1,0x10
    800022c4:	62848493          	addi	s1,s1,1576 # 800128e8 <proc>
    800022c8:	00016997          	auipc	s3,0x16
    800022cc:	22098993          	addi	s3,s3,544 # 800184e8 <tickslock>
    acquire(&p->lock);
    800022d0:	8526                	mv	a0,s1
    800022d2:	957fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    800022d6:	589c                	lw	a5,48(s1)
    800022d8:	01278b63          	beq	a5,s2,800022ee <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022dc:	8526                	mv	a0,s1
    800022de:	9d3fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800022e2:	17048493          	addi	s1,s1,368
    800022e6:	ff3495e3          	bne	s1,s3,800022d0 <kkill+0x22>
  }
  return -1;
    800022ea:	557d                	li	a0,-1
    800022ec:	a819                	j	80002302 <kkill+0x54>
      p->killed = 1;
    800022ee:	4785                	li	a5,1
    800022f0:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800022f2:	4c98                	lw	a4,24(s1)
    800022f4:	4789                	li	a5,2
    800022f6:	00f70d63          	beq	a4,a5,80002310 <kkill+0x62>
      release(&p->lock);
    800022fa:	8526                	mv	a0,s1
    800022fc:	9b5fe0ef          	jal	80000cb0 <release>
      return 0;
    80002300:	4501                	li	a0,0
}
    80002302:	70a2                	ld	ra,40(sp)
    80002304:	7402                	ld	s0,32(sp)
    80002306:	64e2                	ld	s1,24(sp)
    80002308:	6942                	ld	s2,16(sp)
    8000230a:	69a2                	ld	s3,8(sp)
    8000230c:	6145                	addi	sp,sp,48
    8000230e:	8082                	ret
        p->state = RUNNABLE;
    80002310:	478d                	li	a5,3
    80002312:	cc9c                	sw	a5,24(s1)
    80002314:	b7dd                	j	800022fa <kkill+0x4c>
    return -1;
    80002316:	557d                	li	a0,-1
}
    80002318:	8082                	ret

000000008000231a <setkilled>:

void
setkilled(struct proc *p)
{
    8000231a:	1101                	addi	sp,sp,-32
    8000231c:	ec06                	sd	ra,24(sp)
    8000231e:	e822                	sd	s0,16(sp)
    80002320:	e426                	sd	s1,8(sp)
    80002322:	1000                	addi	s0,sp,32
    80002324:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002326:	903fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    8000232a:	4785                	li	a5,1
    8000232c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000232e:	8526                	mv	a0,s1
    80002330:	981fe0ef          	jal	80000cb0 <release>
}
    80002334:	60e2                	ld	ra,24(sp)
    80002336:	6442                	ld	s0,16(sp)
    80002338:	64a2                	ld	s1,8(sp)
    8000233a:	6105                	addi	sp,sp,32
    8000233c:	8082                	ret

000000008000233e <killed>:

int
killed(struct proc *p)
{
    8000233e:	1101                	addi	sp,sp,-32
    80002340:	ec06                	sd	ra,24(sp)
    80002342:	e822                	sd	s0,16(sp)
    80002344:	e426                	sd	s1,8(sp)
    80002346:	e04a                	sd	s2,0(sp)
    80002348:	1000                	addi	s0,sp,32
    8000234a:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000234c:	8ddfe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80002350:	549c                	lw	a5,40(s1)
    80002352:	893e                	mv	s2,a5
  release(&p->lock);
    80002354:	8526                	mv	a0,s1
    80002356:	95bfe0ef          	jal	80000cb0 <release>
  return k;
}
    8000235a:	854a                	mv	a0,s2
    8000235c:	60e2                	ld	ra,24(sp)
    8000235e:	6442                	ld	s0,16(sp)
    80002360:	64a2                	ld	s1,8(sp)
    80002362:	6902                	ld	s2,0(sp)
    80002364:	6105                	addi	sp,sp,32
    80002366:	8082                	ret

0000000080002368 <kwait>:
{
    80002368:	715d                	addi	sp,sp,-80
    8000236a:	e486                	sd	ra,72(sp)
    8000236c:	e0a2                	sd	s0,64(sp)
    8000236e:	fc26                	sd	s1,56(sp)
    80002370:	f84a                	sd	s2,48(sp)
    80002372:	f44e                	sd	s3,40(sp)
    80002374:	f052                	sd	s4,32(sp)
    80002376:	ec56                	sd	s5,24(sp)
    80002378:	e85a                	sd	s6,16(sp)
    8000237a:	e45e                	sd	s7,8(sp)
    8000237c:	0880                	addi	s0,sp,80
    8000237e:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002380:	dc8ff0ef          	jal	80001948 <myproc>
    80002384:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002386:	00010517          	auipc	a0,0x10
    8000238a:	14a50513          	addi	a0,a0,330 # 800124d0 <wait_lock>
    8000238e:	89bfe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002392:	4a15                	li	s4,5
        havekids = 1;
    80002394:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002396:	00016997          	auipc	s3,0x16
    8000239a:	15298993          	addi	s3,s3,338 # 800184e8 <tickslock>
    release(&wait_lock);
    8000239e:	00010b17          	auipc	s6,0x10
    800023a2:	132b0b13          	addi	s6,s6,306 # 800124d0 <wait_lock>
    800023a6:	a845                	j	80002456 <kwait+0xee>
          pid = pp->pid;
    800023a8:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    800023ac:	000b8e63          	beqz	s7,800023c8 <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    800023b0:	4711                	li	a4,4
    800023b2:	02c48693          	addi	a3,s1,44
    800023b6:	865e                	mv	a2,s7
    800023b8:	04893583          	ld	a1,72(s2)
    800023bc:	05093503          	ld	a0,80(s2)
    800023c0:	9c2ff0ef          	jal	80001582 <copyout>
          if (addr != 0 &&
    800023c4:	02054c63          	bltz	a0,800023fc <kwait+0x94>
          pp->parent = 0;
    800023c8:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    800023cc:	8526                	mv	a0,s1
    800023ce:	f4aff0ef          	jal	80001b18 <freeproc>
          release(&pp->lock);
    800023d2:	8526                	mv	a0,s1
    800023d4:	8ddfe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    800023d8:	00010517          	auipc	a0,0x10
    800023dc:	0f850513          	addi	a0,a0,248 # 800124d0 <wait_lock>
    800023e0:	8d1fe0ef          	jal	80000cb0 <release>
}
    800023e4:	854e                	mv	a0,s3
    800023e6:	60a6                	ld	ra,72(sp)
    800023e8:	6406                	ld	s0,64(sp)
    800023ea:	74e2                	ld	s1,56(sp)
    800023ec:	7942                	ld	s2,48(sp)
    800023ee:	79a2                	ld	s3,40(sp)
    800023f0:	7a02                	ld	s4,32(sp)
    800023f2:	6ae2                	ld	s5,24(sp)
    800023f4:	6b42                	ld	s6,16(sp)
    800023f6:	6ba2                	ld	s7,8(sp)
    800023f8:	6161                	addi	sp,sp,80
    800023fa:	8082                	ret
            release(&pp->lock);
    800023fc:	8526                	mv	a0,s1
    800023fe:	8b3fe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    80002402:	00010517          	auipc	a0,0x10
    80002406:	0ce50513          	addi	a0,a0,206 # 800124d0 <wait_lock>
    8000240a:	8a7fe0ef          	jal	80000cb0 <release>
            return -1;
    8000240e:	59fd                	li	s3,-1
    80002410:	bfd1                	j	800023e4 <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002412:	17048493          	addi	s1,s1,368
    80002416:	03348063          	beq	s1,s3,80002436 <kwait+0xce>
      if (pp->parent == p) {
    8000241a:	7c9c                	ld	a5,56(s1)
    8000241c:	ff279be3          	bne	a5,s2,80002412 <kwait+0xaa>
        acquire(&pp->lock);
    80002420:	8526                	mv	a0,s1
    80002422:	807fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002426:	4c9c                	lw	a5,24(s1)
    80002428:	f94780e3          	beq	a5,s4,800023a8 <kwait+0x40>
        release(&pp->lock);
    8000242c:	8526                	mv	a0,s1
    8000242e:	883fe0ef          	jal	80000cb0 <release>
        havekids = 1;
    80002432:	8756                	mv	a4,s5
    80002434:	bff9                	j	80002412 <kwait+0xaa>
    if (!havekids || killed(p)) {
    80002436:	c715                	beqz	a4,80002462 <kwait+0xfa>
    80002438:	854a                	mv	a0,s2
    8000243a:	f05ff0ef          	jal	8000233e <killed>
    8000243e:	e115                	bnez	a0,80002462 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    80002440:	854a                	mv	a0,s2
    80002442:	c9fff0ef          	jal	800020e0 <sleep_prepare>
    release(&wait_lock);
    80002446:	855a                	mv	a0,s6
    80002448:	869fe0ef          	jal	80000cb0 <release>
    sleep();
    8000244c:	cd1ff0ef          	jal	8000211c <sleep>
    acquire(&wait_lock);
    80002450:	855a                	mv	a0,s6
    80002452:	fd6fe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    80002456:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002458:	00010497          	auipc	s1,0x10
    8000245c:	49048493          	addi	s1,s1,1168 # 800128e8 <proc>
    80002460:	bf6d                	j	8000241a <kwait+0xb2>
      release(&wait_lock);
    80002462:	00010517          	auipc	a0,0x10
    80002466:	06e50513          	addi	a0,a0,110 # 800124d0 <wait_lock>
    8000246a:	847fe0ef          	jal	80000cb0 <release>
      return -1;
    8000246e:	59fd                	li	s3,-1
    80002470:	bf95                	j	800023e4 <kwait+0x7c>

0000000080002472 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002472:	7179                	addi	sp,sp,-48
    80002474:	f406                	sd	ra,40(sp)
    80002476:	f022                	sd	s0,32(sp)
    80002478:	ec26                	sd	s1,24(sp)
    8000247a:	e84a                	sd	s2,16(sp)
    8000247c:	e44e                	sd	s3,8(sp)
    8000247e:	e052                	sd	s4,0(sp)
    80002480:	1800                	addi	s0,sp,48
    80002482:	84aa                	mv	s1,a0
    80002484:	8a2e                	mv	s4,a1
    80002486:	89b2                	mv	s3,a2
    80002488:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000248a:	cbeff0ef          	jal	80001948 <myproc>
  if (user_dst) {
    8000248e:	c085                	beqz	s1,800024ae <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    80002490:	874a                	mv	a4,s2
    80002492:	86ce                	mv	a3,s3
    80002494:	8652                	mv	a2,s4
    80002496:	652c                	ld	a1,72(a0)
    80002498:	6928                	ld	a0,80(a0)
    8000249a:	8e8ff0ef          	jal	80001582 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000249e:	70a2                	ld	ra,40(sp)
    800024a0:	7402                	ld	s0,32(sp)
    800024a2:	64e2                	ld	s1,24(sp)
    800024a4:	6942                	ld	s2,16(sp)
    800024a6:	69a2                	ld	s3,8(sp)
    800024a8:	6a02                	ld	s4,0(sp)
    800024aa:	6145                	addi	sp,sp,48
    800024ac:	8082                	ret
    memmove((char *)dst, src, len);
    800024ae:	0009061b          	sext.w	a2,s2
    800024b2:	85ce                	mv	a1,s3
    800024b4:	8552                	mv	a0,s4
    800024b6:	893fe0ef          	jal	80000d48 <memmove>
    return 0;
    800024ba:	8526                	mv	a0,s1
    800024bc:	b7cd                	j	8000249e <either_copyout+0x2c>

00000000800024be <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024be:	7179                	addi	sp,sp,-48
    800024c0:	f406                	sd	ra,40(sp)
    800024c2:	f022                	sd	s0,32(sp)
    800024c4:	ec26                	sd	s1,24(sp)
    800024c6:	e84a                	sd	s2,16(sp)
    800024c8:	e44e                	sd	s3,8(sp)
    800024ca:	e052                	sd	s4,0(sp)
    800024cc:	1800                	addi	s0,sp,48
    800024ce:	8a2a                	mv	s4,a0
    800024d0:	84ae                	mv	s1,a1
    800024d2:	89b2                	mv	s3,a2
    800024d4:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800024d6:	c72ff0ef          	jal	80001948 <myproc>
  if (user_src) {
    800024da:	c085                	beqz	s1,800024fa <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    800024dc:	874a                	mv	a4,s2
    800024de:	86ce                	mv	a3,s3
    800024e0:	8652                	mv	a2,s4
    800024e2:	652c                	ld	a1,72(a0)
    800024e4:	6928                	ld	a0,80(a0)
    800024e6:	962ff0ef          	jal	80001648 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800024ea:	70a2                	ld	ra,40(sp)
    800024ec:	7402                	ld	s0,32(sp)
    800024ee:	64e2                	ld	s1,24(sp)
    800024f0:	6942                	ld	s2,16(sp)
    800024f2:	69a2                	ld	s3,8(sp)
    800024f4:	6a02                	ld	s4,0(sp)
    800024f6:	6145                	addi	sp,sp,48
    800024f8:	8082                	ret
    memmove(dst, (char *)src, len);
    800024fa:	0009061b          	sext.w	a2,s2
    800024fe:	85ce                	mv	a1,s3
    80002500:	8552                	mv	a0,s4
    80002502:	847fe0ef          	jal	80000d48 <memmove>
    return 0;
    80002506:	8526                	mv	a0,s1
    80002508:	b7cd                	j	800024ea <either_copyin+0x2c>

000000008000250a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000250a:	715d                	addi	sp,sp,-80
    8000250c:	e486                	sd	ra,72(sp)
    8000250e:	e0a2                	sd	s0,64(sp)
    80002510:	fc26                	sd	s1,56(sp)
    80002512:	f84a                	sd	s2,48(sp)
    80002514:	f44e                	sd	s3,40(sp)
    80002516:	f052                	sd	s4,32(sp)
    80002518:	ec56                	sd	s5,24(sp)
    8000251a:	e85a                	sd	s6,16(sp)
    8000251c:	e45e                	sd	s7,8(sp)
    8000251e:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002520:	00005517          	auipc	a0,0x5
    80002524:	b5850513          	addi	a0,a0,-1192 # 80007078 <etext+0x78>
    80002528:	fe3fd0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000252c:	00010497          	auipc	s1,0x10
    80002530:	51448493          	addi	s1,s1,1300 # 80012a40 <proc+0x158>
    80002534:	00016917          	auipc	s2,0x16
    80002538:	10c90913          	addi	s2,s2,268 # 80018640 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000253c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000253e:	00005997          	auipc	s3,0x5
    80002542:	ce298993          	addi	s3,s3,-798 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    80002546:	00005a97          	auipc	s5,0x5
    8000254a:	ce2a8a93          	addi	s5,s5,-798 # 80007228 <etext+0x228>
    printk("\n");
    8000254e:	00005a17          	auipc	s4,0x5
    80002552:	b2aa0a13          	addi	s4,s4,-1238 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002556:	00005b97          	auipc	s7,0x5
    8000255a:	1f2b8b93          	addi	s7,s7,498 # 80007748 <states.0>
    8000255e:	a829                	j	80002578 <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002560:	ed86a583          	lw	a1,-296(a3)
    80002564:	8556                	mv	a0,s5
    80002566:	fa5fd0ef          	jal	8000050a <printk>
    printk("\n");
    8000256a:	8552                	mv	a0,s4
    8000256c:	f9ffd0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002570:	17048493          	addi	s1,s1,368
    80002574:	03248263          	beq	s1,s2,80002598 <procdump+0x8e>
    if (p->state == UNUSED)
    80002578:	86a6                	mv	a3,s1
    8000257a:	ec04a783          	lw	a5,-320(s1)
    8000257e:	dbed                	beqz	a5,80002570 <procdump+0x66>
      state = "???";
    80002580:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002582:	fcfb6fe3          	bltu	s6,a5,80002560 <procdump+0x56>
    80002586:	02079713          	slli	a4,a5,0x20
    8000258a:	01d75793          	srli	a5,a4,0x1d
    8000258e:	97de                	add	a5,a5,s7
    80002590:	6390                	ld	a2,0(a5)
    80002592:	f679                	bnez	a2,80002560 <procdump+0x56>
      state = "???";
    80002594:	864e                	mv	a2,s3
    80002596:	b7e9                	j	80002560 <procdump+0x56>
  }
}
    80002598:	60a6                	ld	ra,72(sp)
    8000259a:	6406                	ld	s0,64(sp)
    8000259c:	74e2                	ld	s1,56(sp)
    8000259e:	7942                	ld	s2,48(sp)
    800025a0:	79a2                	ld	s3,40(sp)
    800025a2:	7a02                	ld	s4,32(sp)
    800025a4:	6ae2                	ld	s5,24(sp)
    800025a6:	6b42                	ld	s6,16(sp)
    800025a8:	6ba2                	ld	s7,8(sp)
    800025aa:	6161                	addi	sp,sp,80
    800025ac:	8082                	ret

00000000800025ae <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800025ae:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800025b2:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800025b6:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800025b8:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800025ba:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800025be:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800025c2:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800025c6:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800025ca:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800025ce:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800025d2:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800025d6:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800025da:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800025de:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800025e2:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800025e6:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800025ea:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800025ec:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800025ee:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800025f2:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800025f6:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800025fa:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800025fe:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002602:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002606:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000260a:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000260e:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002612:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002616:	8082                	ret

0000000080002618 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002618:	1141                	addi	sp,sp,-16
    8000261a:	e406                	sd	ra,8(sp)
    8000261c:	e022                	sd	s0,0(sp)
    8000261e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002620:	00005597          	auipc	a1,0x5
    80002624:	c4858593          	addi	a1,a1,-952 # 80007268 <etext+0x268>
    80002628:	00016517          	auipc	a0,0x16
    8000262c:	ec050513          	addi	a0,a0,-320 # 800184e8 <tickslock>
    80002630:	d78fe0ef          	jal	80000ba8 <initlock>
}
    80002634:	60a2                	ld	ra,8(sp)
    80002636:	6402                	ld	s0,0(sp)
    80002638:	0141                	addi	sp,sp,16
    8000263a:	8082                	ret

000000008000263c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000263c:	1141                	addi	sp,sp,-16
    8000263e:	e406                	sd	ra,8(sp)
    80002640:	e022                	sd	s0,0(sp)
    80002642:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002644:	00003797          	auipc	a5,0x3
    80002648:	1ac78793          	addi	a5,a5,428 # 800057f0 <kernelvec>
    8000264c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002650:	60a2                	ld	ra,8(sp)
    80002652:	6402                	ld	s0,0(sp)
    80002654:	0141                	addi	sp,sp,16
    80002656:	8082                	ret

0000000080002658 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002658:	1141                	addi	sp,sp,-16
    8000265a:	e406                	sd	ra,8(sp)
    8000265c:	e022                	sd	s0,0(sp)
    8000265e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002660:	ae8ff0ef          	jal	80001948 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002664:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002668:	04000737          	lui	a4,0x4000
    8000266c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000266e:	0732                	slli	a4,a4,0xc
    80002670:	00004797          	auipc	a5,0x4
    80002674:	99078793          	addi	a5,a5,-1648 # 80006000 <_trampoline>
    80002678:	00004697          	auipc	a3,0x4
    8000267c:	98868693          	addi	a3,a3,-1656 # 80006000 <_trampoline>
    80002680:	8f95                	sub	a5,a5,a3
    80002682:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002684:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002688:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    8000268a:	18002773          	csrr	a4,satp
    8000268e:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002690:	6d38                	ld	a4,88(a0)
    80002692:	613c                	ld	a5,64(a0)
    80002694:	6685                	lui	a3,0x1
    80002696:	97b6                	add	a5,a5,a3
    80002698:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000269a:	6d3c                	ld	a5,88(a0)
    8000269c:	00000717          	auipc	a4,0x0
    800026a0:	10070713          	addi	a4,a4,256 # 8000279c <usertrap>
    800026a4:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800026a6:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    800026a8:	8712                	mv	a4,tp
    800026aa:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026ac:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026b0:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026b4:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800026b8:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026bc:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800026be:	6f9c                	ld	a5,24(a5)
    800026c0:	14179073          	csrw	sepc,a5
}
    800026c4:	60a2                	ld	ra,8(sp)
    800026c6:	6402                	ld	s0,0(sp)
    800026c8:	0141                	addi	sp,sp,16
    800026ca:	8082                	ret

00000000800026cc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026cc:	1141                	addi	sp,sp,-16
    800026ce:	e406                	sd	ra,8(sp)
    800026d0:	e022                	sd	s0,0(sp)
    800026d2:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    800026d4:	a40ff0ef          	jal	80001914 <cpuid>
    800026d8:	cd11                	beqz	a0,800026f4 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800026da:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800026de:	000f4737          	lui	a4,0xf4
    800026e2:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800026e6:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    800026e8:	14d79073          	csrw	stimecmp,a5
}
    800026ec:	60a2                	ld	ra,8(sp)
    800026ee:	6402                	ld	s0,0(sp)
    800026f0:	0141                	addi	sp,sp,16
    800026f2:	8082                	ret
    acquire(&tickslock);
    800026f4:	00016517          	auipc	a0,0x16
    800026f8:	df450513          	addi	a0,a0,-524 # 800184e8 <tickslock>
    800026fc:	d2cfe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002700:	00008717          	auipc	a4,0x8
    80002704:	cb870713          	addi	a4,a4,-840 # 8000a3b8 <ticks>
    80002708:	431c                	lw	a5,0(a4)
    8000270a:	2785                	addiw	a5,a5,1
    8000270c:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    8000270e:	853a                	mv	a0,a4
    80002710:	a3dff0ef          	jal	8000214c <wakeup>
    release(&tickslock);
    80002714:	00016517          	auipc	a0,0x16
    80002718:	dd450513          	addi	a0,a0,-556 # 800184e8 <tickslock>
    8000271c:	d94fe0ef          	jal	80000cb0 <release>
    update_proc_aging();
    80002720:	f32ff0ef          	jal	80001e52 <update_proc_aging>
    80002724:	bf5d                	j	800026da <clockintr+0xe>

0000000080002726 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002726:	1101                	addi	sp,sp,-32
    80002728:	ec06                	sd	ra,24(sp)
    8000272a:	e822                	sd	s0,16(sp)
    8000272c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    8000272e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002732:	57fd                	li	a5,-1
    80002734:	17fe                	slli	a5,a5,0x3f
    80002736:	07a5                	addi	a5,a5,9
    80002738:	00f70c63          	beq	a4,a5,80002750 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    8000273c:	57fd                	li	a5,-1
    8000273e:	17fe                	slli	a5,a5,0x3f
    80002740:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002742:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002744:	04f70863          	beq	a4,a5,80002794 <devintr+0x6e>
  }
}
    80002748:	60e2                	ld	ra,24(sp)
    8000274a:	6442                	ld	s0,16(sp)
    8000274c:	6105                	addi	sp,sp,32
    8000274e:	8082                	ret
    80002750:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002752:	14c030ef          	jal	8000589e <plic_claim>
    80002756:	872a                	mv	a4,a0
    80002758:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    8000275a:	47a9                	li	a5,10
    8000275c:	00f50963          	beq	a0,a5,8000276e <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    80002760:	4785                	li	a5,1
    80002762:	00f50963          	beq	a0,a5,80002774 <devintr+0x4e>
    return 1;
    80002766:	4505                	li	a0,1
    } else if (irq) {
    80002768:	eb09                	bnez	a4,8000277a <devintr+0x54>
    8000276a:	64a2                	ld	s1,8(sp)
    8000276c:	bff1                	j	80002748 <devintr+0x22>
      uartintr();
    8000276e:	a80fe0ef          	jal	800009ee <uartintr>
    if (irq)
    80002772:	a819                	j	80002788 <devintr+0x62>
      virtio_disk_intr();
    80002774:	5e6030ef          	jal	80005d5a <virtio_disk_intr>
    if (irq)
    80002778:	a801                	j	80002788 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    8000277a:	85ba                	mv	a1,a4
    8000277c:	00005517          	auipc	a0,0x5
    80002780:	af450513          	addi	a0,a0,-1292 # 80007270 <etext+0x270>
    80002784:	d87fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    80002788:	8526                	mv	a0,s1
    8000278a:	136030ef          	jal	800058c0 <plic_complete>
    return 1;
    8000278e:	4505                	li	a0,1
    80002790:	64a2                	ld	s1,8(sp)
    80002792:	bf5d                	j	80002748 <devintr+0x22>
    clockintr();
    80002794:	f39ff0ef          	jal	800026cc <clockintr>
    return 2;
    80002798:	4509                	li	a0,2
    8000279a:	b77d                	j	80002748 <devintr+0x22>

000000008000279c <usertrap>:
{
    8000279c:	1101                	addi	sp,sp,-32
    8000279e:	ec06                	sd	ra,24(sp)
    800027a0:	e822                	sd	s0,16(sp)
    800027a2:	e426                	sd	s1,8(sp)
    800027a4:	e04a                	sd	s2,0(sp)
    800027a6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027a8:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800027ac:	1007f793          	andi	a5,a5,256
    800027b0:	eba5                	bnez	a5,80002820 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800027b2:	00003797          	auipc	a5,0x3
    800027b6:	03e78793          	addi	a5,a5,62 # 800057f0 <kernelvec>
    800027ba:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027be:	98aff0ef          	jal	80001948 <myproc>
    800027c2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027c4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027c6:	14102773          	csrr	a4,sepc
    800027ca:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800027cc:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800027d0:	47a1                	li	a5,8
    800027d2:	04f70d63          	beq	a4,a5,8000282c <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    800027d6:	f51ff0ef          	jal	80002726 <devintr>
    800027da:	892a                	mv	s2,a0
    800027dc:	e54d                	bnez	a0,80002886 <usertrap+0xea>
    800027de:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800027e2:	47bd                	li	a5,15
    800027e4:	08f70463          	beq	a4,a5,8000286c <usertrap+0xd0>
    800027e8:	14202773          	csrr	a4,scause
    800027ec:	47b5                	li	a5,13
    800027ee:	06f70f63          	beq	a4,a5,8000286c <usertrap+0xd0>
    800027f2:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800027f6:	5890                	lw	a2,48(s1)
    800027f8:	00005517          	auipc	a0,0x5
    800027fc:	ab850513          	addi	a0,a0,-1352 # 800072b0 <etext+0x2b0>
    80002800:	d0bfd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002804:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002808:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000280c:	00005517          	auipc	a0,0x5
    80002810:	ad450513          	addi	a0,a0,-1324 # 800072e0 <etext+0x2e0>
    80002814:	cf7fd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002818:	8526                	mv	a0,s1
    8000281a:	b01ff0ef          	jal	8000231a <setkilled>
    8000281e:	a015                	j	80002842 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    80002820:	00005517          	auipc	a0,0x5
    80002824:	a7050513          	addi	a0,a0,-1424 # 80007290 <etext+0x290>
    80002828:	80cfe0ef          	jal	80000834 <panic>
    if (killed(p))
    8000282c:	b13ff0ef          	jal	8000233e <killed>
    80002830:	e915                	bnez	a0,80002864 <usertrap+0xc8>
    p->trapframe->epc += 4;
    80002832:	6cb8                	ld	a4,88(s1)
    80002834:	6f1c                	ld	a5,24(a4)
    80002836:	0791                	addi	a5,a5,4
    80002838:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    8000283a:	10016073          	csrsi	sstatus,2
    syscall();
    8000283e:	244000ef          	jal	80002a82 <syscall>
  if (killed(p))
    80002842:	8526                	mv	a0,s1
    80002844:	afbff0ef          	jal	8000233e <killed>
    80002848:	e521                	bnez	a0,80002890 <usertrap+0xf4>
  prepare_return();
    8000284a:	e0fff0ef          	jal	80002658 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000284e:	68a8                	ld	a0,80(s1)
    80002850:	8131                	srli	a0,a0,0xc
    80002852:	57fd                	li	a5,-1
    80002854:	17fe                	slli	a5,a5,0x3f
    80002856:	8d5d                	or	a0,a0,a5
}
    80002858:	60e2                	ld	ra,24(sp)
    8000285a:	6442                	ld	s0,16(sp)
    8000285c:	64a2                	ld	s1,8(sp)
    8000285e:	6902                	ld	s2,0(sp)
    80002860:	6105                	addi	sp,sp,32
    80002862:	8082                	ret
      kexit(-1);
    80002864:	557d                	li	a0,-1
    80002866:	9a3ff0ef          	jal	80002208 <kexit>
    8000286a:	b7e1                	j	80002832 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    8000286c:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    80002870:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002874:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    80002876:	0016b693          	seqz	a3,a3
    8000287a:	64ac                	ld	a1,72(s1)
    8000287c:	68a8                	ld	a0,80(s1)
    8000287e:	c89fe0ef          	jal	80001506 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002882:	f161                	bnez	a0,80002842 <usertrap+0xa6>
    80002884:	b7bd                	j	800027f2 <usertrap+0x56>
  if (killed(p))
    80002886:	8526                	mv	a0,s1
    80002888:	ab7ff0ef          	jal	8000233e <killed>
    8000288c:	c511                	beqz	a0,80002898 <usertrap+0xfc>
    8000288e:	a011                	j	80002892 <usertrap+0xf6>
    80002890:	4901                	li	s2,0
    kexit(-1);
    80002892:	557d                	li	a0,-1
    80002894:	975ff0ef          	jal	80002208 <kexit>
  if (which_dev == 2)
    80002898:	4789                	li	a5,2
    8000289a:	faf918e3          	bne	s2,a5,8000284a <usertrap+0xae>
    yield();
    8000289e:	817ff0ef          	jal	800020b4 <yield>
    800028a2:	b765                	j	8000284a <usertrap+0xae>

00000000800028a4 <kerneltrap>:
{
    800028a4:	7179                	addi	sp,sp,-48
    800028a6:	f406                	sd	ra,40(sp)
    800028a8:	f022                	sd	s0,32(sp)
    800028aa:	ec26                	sd	s1,24(sp)
    800028ac:	e84a                	sd	s2,16(sp)
    800028ae:	e44e                	sd	s3,8(sp)
    800028b0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    800028b2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800028b6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800028ba:	142027f3          	csrr	a5,scause
    800028be:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    800028c0:	1004f793          	andi	a5,s1,256
    800028c4:	c795                	beqz	a5,800028f0 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800028c6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028ca:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800028cc:	eb85                	bnez	a5,800028fc <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    800028ce:	e59ff0ef          	jal	80002726 <devintr>
    800028d2:	c91d                	beqz	a0,80002908 <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    800028d4:	4789                	li	a5,2
    800028d6:	04f50a63          	beq	a0,a5,8000292a <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    800028da:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800028de:	10049073          	csrw	sstatus,s1
}
    800028e2:	70a2                	ld	ra,40(sp)
    800028e4:	7402                	ld	s0,32(sp)
    800028e6:	64e2                	ld	s1,24(sp)
    800028e8:	6942                	ld	s2,16(sp)
    800028ea:	69a2                	ld	s3,8(sp)
    800028ec:	6145                	addi	sp,sp,48
    800028ee:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028f0:	00005517          	auipc	a0,0x5
    800028f4:	a1850513          	addi	a0,a0,-1512 # 80007308 <etext+0x308>
    800028f8:	f3dfd0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    800028fc:	00005517          	auipc	a0,0x5
    80002900:	a3450513          	addi	a0,a0,-1484 # 80007330 <etext+0x330>
    80002904:	f31fd0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002908:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000290c:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    80002910:	85ce                	mv	a1,s3
    80002912:	00005517          	auipc	a0,0x5
    80002916:	a3e50513          	addi	a0,a0,-1474 # 80007350 <etext+0x350>
    8000291a:	bf1fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    8000291e:	00005517          	auipc	a0,0x5
    80002922:	a5a50513          	addi	a0,a0,-1446 # 80007378 <etext+0x378>
    80002926:	f0ffd0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    8000292a:	81eff0ef          	jal	80001948 <myproc>
    8000292e:	d555                	beqz	a0,800028da <kerneltrap+0x36>
    yield();
    80002930:	f84ff0ef          	jal	800020b4 <yield>
    80002934:	b75d                	j	800028da <kerneltrap+0x36>

0000000080002936 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002936:	1101                	addi	sp,sp,-32
    80002938:	ec06                	sd	ra,24(sp)
    8000293a:	e822                	sd	s0,16(sp)
    8000293c:	e426                	sd	s1,8(sp)
    8000293e:	1000                	addi	s0,sp,32
    80002940:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002942:	806ff0ef          	jal	80001948 <myproc>
  switch (n) {
    80002946:	4795                	li	a5,5
    80002948:	0497e163          	bltu	a5,s1,8000298a <argraw+0x54>
    8000294c:	048a                	slli	s1,s1,0x2
    8000294e:	00005717          	auipc	a4,0x5
    80002952:	e2a70713          	addi	a4,a4,-470 # 80007778 <states.0+0x30>
    80002956:	94ba                	add	s1,s1,a4
    80002958:	409c                	lw	a5,0(s1)
    8000295a:	97ba                	add	a5,a5,a4
    8000295c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000295e:	6d3c                	ld	a5,88(a0)
    80002960:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002962:	60e2                	ld	ra,24(sp)
    80002964:	6442                	ld	s0,16(sp)
    80002966:	64a2                	ld	s1,8(sp)
    80002968:	6105                	addi	sp,sp,32
    8000296a:	8082                	ret
    return p->trapframe->a1;
    8000296c:	6d3c                	ld	a5,88(a0)
    8000296e:	7fa8                	ld	a0,120(a5)
    80002970:	bfcd                	j	80002962 <argraw+0x2c>
    return p->trapframe->a2;
    80002972:	6d3c                	ld	a5,88(a0)
    80002974:	63c8                	ld	a0,128(a5)
    80002976:	b7f5                	j	80002962 <argraw+0x2c>
    return p->trapframe->a3;
    80002978:	6d3c                	ld	a5,88(a0)
    8000297a:	67c8                	ld	a0,136(a5)
    8000297c:	b7dd                	j	80002962 <argraw+0x2c>
    return p->trapframe->a4;
    8000297e:	6d3c                	ld	a5,88(a0)
    80002980:	6bc8                	ld	a0,144(a5)
    80002982:	b7c5                	j	80002962 <argraw+0x2c>
    return p->trapframe->a5;
    80002984:	6d3c                	ld	a5,88(a0)
    80002986:	6fc8                	ld	a0,152(a5)
    80002988:	bfe9                	j	80002962 <argraw+0x2c>
  panic("argraw");
    8000298a:	00005517          	auipc	a0,0x5
    8000298e:	9fe50513          	addi	a0,a0,-1538 # 80007388 <etext+0x388>
    80002992:	ea3fd0ef          	jal	80000834 <panic>

0000000080002996 <fetchaddr>:
{
    80002996:	1101                	addi	sp,sp,-32
    80002998:	ec06                	sd	ra,24(sp)
    8000299a:	e822                	sd	s0,16(sp)
    8000299c:	e426                	sd	s1,8(sp)
    8000299e:	e04a                	sd	s2,0(sp)
    800029a0:	1000                	addi	s0,sp,32
    800029a2:	84aa                	mv	s1,a0
    800029a4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800029a6:	fa3fe0ef          	jal	80001948 <myproc>
  if (addr >= p->sz ||
    800029aa:	652c                	ld	a1,72(a0)
    800029ac:	02b4f663          	bgeu	s1,a1,800029d8 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800029b0:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    800029b4:	02f5e463          	bltu	a1,a5,800029dc <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    800029b8:	4721                	li	a4,8
    800029ba:	86a6                	mv	a3,s1
    800029bc:	864a                	mv	a2,s2
    800029be:	6928                	ld	a0,80(a0)
    800029c0:	c89fe0ef          	jal	80001648 <copyin>
    800029c4:	00a03533          	snez	a0,a0
    800029c8:	40a0053b          	negw	a0,a0
}
    800029cc:	60e2                	ld	ra,24(sp)
    800029ce:	6442                	ld	s0,16(sp)
    800029d0:	64a2                	ld	s1,8(sp)
    800029d2:	6902                	ld	s2,0(sp)
    800029d4:	6105                	addi	sp,sp,32
    800029d6:	8082                	ret
    return -1;
    800029d8:	557d                	li	a0,-1
    800029da:	bfcd                	j	800029cc <fetchaddr+0x36>
    800029dc:	557d                	li	a0,-1
    800029de:	b7fd                	j	800029cc <fetchaddr+0x36>

00000000800029e0 <fetchstr>:
{
    800029e0:	7179                	addi	sp,sp,-48
    800029e2:	f406                	sd	ra,40(sp)
    800029e4:	f022                	sd	s0,32(sp)
    800029e6:	ec26                	sd	s1,24(sp)
    800029e8:	e84a                	sd	s2,16(sp)
    800029ea:	e44e                	sd	s3,8(sp)
    800029ec:	1800                	addi	s0,sp,48
    800029ee:	89aa                	mv	s3,a0
    800029f0:	84ae                	mv	s1,a1
    800029f2:	8932                	mv	s2,a2
  struct proc *p = myproc();
    800029f4:	f55fe0ef          	jal	80001948 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    800029f8:	874a                	mv	a4,s2
    800029fa:	86ce                	mv	a3,s3
    800029fc:	8626                	mv	a2,s1
    800029fe:	652c                	ld	a1,72(a0)
    80002a00:	6928                	ld	a0,80(a0)
    80002a02:	ce3fe0ef          	jal	800016e4 <copyinstr>
    80002a06:	00054c63          	bltz	a0,80002a1e <fetchstr+0x3e>
  return strlen(buf);
    80002a0a:	8526                	mv	a0,s1
    80002a0c:	c66fe0ef          	jal	80000e72 <strlen>
}
    80002a10:	70a2                	ld	ra,40(sp)
    80002a12:	7402                	ld	s0,32(sp)
    80002a14:	64e2                	ld	s1,24(sp)
    80002a16:	6942                	ld	s2,16(sp)
    80002a18:	69a2                	ld	s3,8(sp)
    80002a1a:	6145                	addi	sp,sp,48
    80002a1c:	8082                	ret
    return -1;
    80002a1e:	557d                	li	a0,-1
    80002a20:	bfc5                	j	80002a10 <fetchstr+0x30>

0000000080002a22 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a22:	1101                	addi	sp,sp,-32
    80002a24:	ec06                	sd	ra,24(sp)
    80002a26:	e822                	sd	s0,16(sp)
    80002a28:	e426                	sd	s1,8(sp)
    80002a2a:	1000                	addi	s0,sp,32
    80002a2c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a2e:	f09ff0ef          	jal	80002936 <argraw>
    80002a32:	c088                	sw	a0,0(s1)
}
    80002a34:	60e2                	ld	ra,24(sp)
    80002a36:	6442                	ld	s0,16(sp)
    80002a38:	64a2                	ld	s1,8(sp)
    80002a3a:	6105                	addi	sp,sp,32
    80002a3c:	8082                	ret

0000000080002a3e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a3e:	1101                	addi	sp,sp,-32
    80002a40:	ec06                	sd	ra,24(sp)
    80002a42:	e822                	sd	s0,16(sp)
    80002a44:	e426                	sd	s1,8(sp)
    80002a46:	1000                	addi	s0,sp,32
    80002a48:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a4a:	eedff0ef          	jal	80002936 <argraw>
    80002a4e:	e088                	sd	a0,0(s1)
}
    80002a50:	60e2                	ld	ra,24(sp)
    80002a52:	6442                	ld	s0,16(sp)
    80002a54:	64a2                	ld	s1,8(sp)
    80002a56:	6105                	addi	sp,sp,32
    80002a58:	8082                	ret

0000000080002a5a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a5a:	1101                	addi	sp,sp,-32
    80002a5c:	ec06                	sd	ra,24(sp)
    80002a5e:	e822                	sd	s0,16(sp)
    80002a60:	e426                	sd	s1,8(sp)
    80002a62:	e04a                	sd	s2,0(sp)
    80002a64:	1000                	addi	s0,sp,32
    80002a66:	892e                	mv	s2,a1
    80002a68:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002a6a:	ecdff0ef          	jal	80002936 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002a6e:	8626                	mv	a2,s1
    80002a70:	85ca                	mv	a1,s2
    80002a72:	f6fff0ef          	jal	800029e0 <fetchstr>
}
    80002a76:	60e2                	ld	ra,24(sp)
    80002a78:	6442                	ld	s0,16(sp)
    80002a7a:	64a2                	ld	s1,8(sp)
    80002a7c:	6902                	ld	s2,0(sp)
    80002a7e:	6105                	addi	sp,sp,32
    80002a80:	8082                	ret

0000000080002a82 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002a82:	1101                	addi	sp,sp,-32
    80002a84:	ec06                	sd	ra,24(sp)
    80002a86:	e822                	sd	s0,16(sp)
    80002a88:	e426                	sd	s1,8(sp)
    80002a8a:	e04a                	sd	s2,0(sp)
    80002a8c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002a8e:	ebbfe0ef          	jal	80001948 <myproc>
    80002a92:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002a94:	05853903          	ld	s2,88(a0)
    80002a98:	0a893783          	ld	a5,168(s2)
    80002a9c:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002aa0:	37fd                	addiw	a5,a5,-1
    80002aa2:	4759                	li	a4,22
    80002aa4:	00f76f63          	bltu	a4,a5,80002ac2 <syscall+0x40>
    80002aa8:	00369713          	slli	a4,a3,0x3
    80002aac:	00005797          	auipc	a5,0x5
    80002ab0:	ce478793          	addi	a5,a5,-796 # 80007790 <syscalls>
    80002ab4:	97ba                	add	a5,a5,a4
    80002ab6:	639c                	ld	a5,0(a5)
    80002ab8:	c789                	beqz	a5,80002ac2 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002aba:	9782                	jalr	a5
    80002abc:	06a93823          	sd	a0,112(s2)
    80002ac0:	a829                	j	80002ada <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002ac2:	15848613          	addi	a2,s1,344
    80002ac6:	588c                	lw	a1,48(s1)
    80002ac8:	00005517          	auipc	a0,0x5
    80002acc:	8c850513          	addi	a0,a0,-1848 # 80007390 <etext+0x390>
    80002ad0:	a3bfd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002ad4:	6cbc                	ld	a5,88(s1)
    80002ad6:	577d                	li	a4,-1
    80002ad8:	fbb8                	sd	a4,112(a5)
  }
}
    80002ada:	60e2                	ld	ra,24(sp)
    80002adc:	6442                	ld	s0,16(sp)
    80002ade:	64a2                	ld	s1,8(sp)
    80002ae0:	6902                	ld	s2,0(sp)
    80002ae2:	6105                	addi	sp,sp,32
    80002ae4:	8082                	ret

0000000080002ae6 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002ae6:	1101                	addi	sp,sp,-32
    80002ae8:	ec06                	sd	ra,24(sp)
    80002aea:	e822                	sd	s0,16(sp)
    80002aec:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002aee:	fec40593          	addi	a1,s0,-20
    80002af2:	4501                	li	a0,0
    80002af4:	f2fff0ef          	jal	80002a22 <argint>
  kexit(n);
    80002af8:	fec42503          	lw	a0,-20(s0)
    80002afc:	f0cff0ef          	jal	80002208 <kexit>
  return 0; // not reached
}
    80002b00:	4501                	li	a0,0
    80002b02:	60e2                	ld	ra,24(sp)
    80002b04:	6442                	ld	s0,16(sp)
    80002b06:	6105                	addi	sp,sp,32
    80002b08:	8082                	ret

0000000080002b0a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b0a:	1141                	addi	sp,sp,-16
    80002b0c:	e406                	sd	ra,8(sp)
    80002b0e:	e022                	sd	s0,0(sp)
    80002b10:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b12:	e37fe0ef          	jal	80001948 <myproc>
}
    80002b16:	5908                	lw	a0,48(a0)
    80002b18:	60a2                	ld	ra,8(sp)
    80002b1a:	6402                	ld	s0,0(sp)
    80002b1c:	0141                	addi	sp,sp,16
    80002b1e:	8082                	ret

0000000080002b20 <sys_fork>:

uint64
sys_fork(void)
{
    80002b20:	1141                	addi	sp,sp,-16
    80002b22:	e406                	sd	ra,8(sp)
    80002b24:	e022                	sd	s0,0(sp)
    80002b26:	0800                	addi	s0,sp,16
  return kfork();
    80002b28:	994ff0ef          	jal	80001cbc <kfork>
}
    80002b2c:	60a2                	ld	ra,8(sp)
    80002b2e:	6402                	ld	s0,0(sp)
    80002b30:	0141                	addi	sp,sp,16
    80002b32:	8082                	ret

0000000080002b34 <sys_wait>:

uint64
sys_wait(void)
{
    80002b34:	1101                	addi	sp,sp,-32
    80002b36:	ec06                	sd	ra,24(sp)
    80002b38:	e822                	sd	s0,16(sp)
    80002b3a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b3c:	fe840593          	addi	a1,s0,-24
    80002b40:	4501                	li	a0,0
    80002b42:	efdff0ef          	jal	80002a3e <argaddr>
  return kwait(p);
    80002b46:	fe843503          	ld	a0,-24(s0)
    80002b4a:	81fff0ef          	jal	80002368 <kwait>
}
    80002b4e:	60e2                	ld	ra,24(sp)
    80002b50:	6442                	ld	s0,16(sp)
    80002b52:	6105                	addi	sp,sp,32
    80002b54:	8082                	ret

0000000080002b56 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b56:	7179                	addi	sp,sp,-48
    80002b58:	f406                	sd	ra,40(sp)
    80002b5a:	f022                	sd	s0,32(sp)
    80002b5c:	ec26                	sd	s1,24(sp)
    80002b5e:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002b60:	fd840593          	addi	a1,s0,-40
    80002b64:	4501                	li	a0,0
    80002b66:	ebdff0ef          	jal	80002a22 <argint>
  argint(1, &t);
    80002b6a:	fdc40593          	addi	a1,s0,-36
    80002b6e:	4505                	li	a0,1
    80002b70:	eb3ff0ef          	jal	80002a22 <argint>
  addr = myproc()->sz;
    80002b74:	dd5fe0ef          	jal	80001948 <myproc>
    80002b78:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002b7a:	fdc42703          	lw	a4,-36(s0)
    80002b7e:	4785                	li	a5,1
    80002b80:	02f70763          	beq	a4,a5,80002bae <sys_sbrk+0x58>
    80002b84:	fd842783          	lw	a5,-40(s0)
    80002b88:	0207c363          	bltz	a5,80002bae <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002b8c:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002b8e:	02000737          	lui	a4,0x2000
    80002b92:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002b94:	0736                	slli	a4,a4,0xd
    80002b96:	02f76a63          	bltu	a4,a5,80002bca <sys_sbrk+0x74>
    80002b9a:	0297e863          	bltu	a5,s1,80002bca <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002b9e:	dabfe0ef          	jal	80001948 <myproc>
    80002ba2:	fd842703          	lw	a4,-40(s0)
    80002ba6:	653c                	ld	a5,72(a0)
    80002ba8:	97ba                	add	a5,a5,a4
    80002baa:	e53c                	sd	a5,72(a0)
    80002bac:	a039                	j	80002bba <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002bae:	fd842503          	lw	a0,-40(s0)
    80002bb2:	8a8ff0ef          	jal	80001c5a <growproc>
    80002bb6:	00054863          	bltz	a0,80002bc6 <sys_sbrk+0x70>
  }
  return addr;
}
    80002bba:	8526                	mv	a0,s1
    80002bbc:	70a2                	ld	ra,40(sp)
    80002bbe:	7402                	ld	s0,32(sp)
    80002bc0:	64e2                	ld	s1,24(sp)
    80002bc2:	6145                	addi	sp,sp,48
    80002bc4:	8082                	ret
      return -1;
    80002bc6:	54fd                	li	s1,-1
    80002bc8:	bfcd                	j	80002bba <sys_sbrk+0x64>
      return -1;
    80002bca:	54fd                	li	s1,-1
    80002bcc:	b7fd                	j	80002bba <sys_sbrk+0x64>

0000000080002bce <sys_pause>:

uint64
sys_pause(void)
{
    80002bce:	7139                	addi	sp,sp,-64
    80002bd0:	fc06                	sd	ra,56(sp)
    80002bd2:	f822                	sd	s0,48(sp)
    80002bd4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002bd6:	fcc40593          	addi	a1,s0,-52
    80002bda:	4501                	li	a0,0
    80002bdc:	e47ff0ef          	jal	80002a22 <argint>
  if (n < 0)
    80002be0:	fcc42783          	lw	a5,-52(s0)
    80002be4:	0807c063          	bltz	a5,80002c64 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002be8:	00016517          	auipc	a0,0x16
    80002bec:	90050513          	addi	a0,a0,-1792 # 800184e8 <tickslock>
    80002bf0:	838fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002bf4:	fcc42783          	lw	a5,-52(s0)
    80002bf8:	cbb9                	beqz	a5,80002c4e <sys_pause+0x80>
    80002bfa:	f426                	sd	s1,40(sp)
    80002bfc:	f04a                	sd	s2,32(sp)
    80002bfe:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002c00:	00007997          	auipc	s3,0x7
    80002c04:	7b89a983          	lw	s3,1976(s3) # 8000a3b8 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002c08:	00007917          	auipc	s2,0x7
    80002c0c:	7b090913          	addi	s2,s2,1968 # 8000a3b8 <ticks>
    release(&tickslock);
    80002c10:	00016497          	auipc	s1,0x16
    80002c14:	8d848493          	addi	s1,s1,-1832 # 800184e8 <tickslock>
    if (killed(myproc())) {
    80002c18:	d31fe0ef          	jal	80001948 <myproc>
    80002c1c:	f22ff0ef          	jal	8000233e <killed>
    80002c20:	e529                	bnez	a0,80002c6a <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002c22:	854a                	mv	a0,s2
    80002c24:	cbcff0ef          	jal	800020e0 <sleep_prepare>
    release(&tickslock);
    80002c28:	8526                	mv	a0,s1
    80002c2a:	886fe0ef          	jal	80000cb0 <release>
    sleep();
    80002c2e:	ceeff0ef          	jal	8000211c <sleep>
    acquire(&tickslock);
    80002c32:	8526                	mv	a0,s1
    80002c34:	ff5fd0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002c38:	00092783          	lw	a5,0(s2)
    80002c3c:	413787bb          	subw	a5,a5,s3
    80002c40:	fcc42703          	lw	a4,-52(s0)
    80002c44:	fce7eae3          	bltu	a5,a4,80002c18 <sys_pause+0x4a>
    80002c48:	74a2                	ld	s1,40(sp)
    80002c4a:	7902                	ld	s2,32(sp)
    80002c4c:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002c4e:	00016517          	auipc	a0,0x16
    80002c52:	89a50513          	addi	a0,a0,-1894 # 800184e8 <tickslock>
    80002c56:	85afe0ef          	jal	80000cb0 <release>
  return 0;
    80002c5a:	4501                	li	a0,0
}
    80002c5c:	70e2                	ld	ra,56(sp)
    80002c5e:	7442                	ld	s0,48(sp)
    80002c60:	6121                	addi	sp,sp,64
    80002c62:	8082                	ret
    n = 0;
    80002c64:	fc042623          	sw	zero,-52(s0)
    80002c68:	b741                	j	80002be8 <sys_pause+0x1a>
      release(&tickslock);
    80002c6a:	00016517          	auipc	a0,0x16
    80002c6e:	87e50513          	addi	a0,a0,-1922 # 800184e8 <tickslock>
    80002c72:	83efe0ef          	jal	80000cb0 <release>
      return -1;
    80002c76:	557d                	li	a0,-1
    80002c78:	74a2                	ld	s1,40(sp)
    80002c7a:	7902                	ld	s2,32(sp)
    80002c7c:	69e2                	ld	s3,24(sp)
    80002c7e:	bff9                	j	80002c5c <sys_pause+0x8e>

0000000080002c80 <sys_kill>:

uint64
sys_kill(void)
{
    80002c80:	1101                	addi	sp,sp,-32
    80002c82:	ec06                	sd	ra,24(sp)
    80002c84:	e822                	sd	s0,16(sp)
    80002c86:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002c88:	fec40593          	addi	a1,s0,-20
    80002c8c:	4501                	li	a0,0
    80002c8e:	d95ff0ef          	jal	80002a22 <argint>
  return kkill(pid);
    80002c92:	fec42503          	lw	a0,-20(s0)
    80002c96:	e18ff0ef          	jal	800022ae <kkill>
}
    80002c9a:	60e2                	ld	ra,24(sp)
    80002c9c:	6442                	ld	s0,16(sp)
    80002c9e:	6105                	addi	sp,sp,32
    80002ca0:	8082                	ret

0000000080002ca2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ca2:	1101                	addi	sp,sp,-32
    80002ca4:	ec06                	sd	ra,24(sp)
    80002ca6:	e822                	sd	s0,16(sp)
    80002ca8:	e426                	sd	s1,8(sp)
    80002caa:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002cac:	00016517          	auipc	a0,0x16
    80002cb0:	83c50513          	addi	a0,a0,-1988 # 800184e8 <tickslock>
    80002cb4:	f75fd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002cb8:	00007797          	auipc	a5,0x7
    80002cbc:	7007a783          	lw	a5,1792(a5) # 8000a3b8 <ticks>
    80002cc0:	84be                	mv	s1,a5
  release(&tickslock);
    80002cc2:	00016517          	auipc	a0,0x16
    80002cc6:	82650513          	addi	a0,a0,-2010 # 800184e8 <tickslock>
    80002cca:	fe7fd0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002cce:	02049513          	slli	a0,s1,0x20
    80002cd2:	9101                	srli	a0,a0,0x20
    80002cd4:	60e2                	ld	ra,24(sp)
    80002cd6:	6442                	ld	s0,16(sp)
    80002cd8:	64a2                	ld	s1,8(sp)
    80002cda:	6105                	addi	sp,sp,32
    80002cdc:	8082                	ret

0000000080002cde <sys_set_priority>:

// Question 2: System call to set priority of a process
uint64
sys_set_priority(void)
{
    80002cde:	1101                	addi	sp,sp,-32
    80002ce0:	ec06                	sd	ra,24(sp)
    80002ce2:	e822                	sd	s0,16(sp)
    80002ce4:	1000                	addi	s0,sp,32
  int pid;
  int priority;

  argint(0, &pid);
    80002ce6:	fec40593          	addi	a1,s0,-20
    80002cea:	4501                	li	a0,0
    80002cec:	d37ff0ef          	jal	80002a22 <argint>
  argint(1, &priority);
    80002cf0:	fe840593          	addi	a1,s0,-24
    80002cf4:	4505                	li	a0,1
    80002cf6:	d2dff0ef          	jal	80002a22 <argint>
  return set_priority(pid, priority);
    80002cfa:	fe842583          	lw	a1,-24(s0)
    80002cfe:	fec42503          	lw	a0,-20(s0)
    80002d02:	8c8ff0ef          	jal	80001dca <set_priority>
}
    80002d06:	60e2                	ld	ra,24(sp)
    80002d08:	6442                	ld	s0,16(sp)
    80002d0a:	6105                	addi	sp,sp,32
    80002d0c:	8082                	ret

0000000080002d0e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d0e:	7179                	addi	sp,sp,-48
    80002d10:	f406                	sd	ra,40(sp)
    80002d12:	f022                	sd	s0,32(sp)
    80002d14:	ec26                	sd	s1,24(sp)
    80002d16:	e84a                	sd	s2,16(sp)
    80002d18:	e44e                	sd	s3,8(sp)
    80002d1a:	e052                	sd	s4,0(sp)
    80002d1c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d1e:	00004597          	auipc	a1,0x4
    80002d22:	69258593          	addi	a1,a1,1682 # 800073b0 <etext+0x3b0>
    80002d26:	00015517          	auipc	a0,0x15
    80002d2a:	7da50513          	addi	a0,a0,2010 # 80018500 <bcache>
    80002d2e:	e7bfd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d32:	0001d797          	auipc	a5,0x1d
    80002d36:	7ce78793          	addi	a5,a5,1998 # 80020500 <bcache+0x8000>
    80002d3a:	0001e717          	auipc	a4,0x1e
    80002d3e:	a2e70713          	addi	a4,a4,-1490 # 80020768 <bcache+0x8268>
    80002d42:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d46:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002d4a:	00015497          	auipc	s1,0x15
    80002d4e:	7ce48493          	addi	s1,s1,1998 # 80018518 <bcache+0x18>
    b->next = bcache.head.next;
    80002d52:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d54:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d56:	00004a17          	auipc	s4,0x4
    80002d5a:	662a0a13          	addi	s4,s4,1634 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002d5e:	2b893783          	ld	a5,696(s2)
    80002d62:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d64:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d68:	85d2                	mv	a1,s4
    80002d6a:	01048513          	addi	a0,s1,16
    80002d6e:	41c010ef          	jal	8000418a <initsleeplock>
    bcache.head.next->prev = b;
    80002d72:	2b893783          	ld	a5,696(s2)
    80002d76:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d78:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002d7c:	45848493          	addi	s1,s1,1112
    80002d80:	fd349fe3          	bne	s1,s3,80002d5e <binit+0x50>
  }
}
    80002d84:	70a2                	ld	ra,40(sp)
    80002d86:	7402                	ld	s0,32(sp)
    80002d88:	64e2                	ld	s1,24(sp)
    80002d8a:	6942                	ld	s2,16(sp)
    80002d8c:	69a2                	ld	s3,8(sp)
    80002d8e:	6a02                	ld	s4,0(sp)
    80002d90:	6145                	addi	sp,sp,48
    80002d92:	8082                	ret

0000000080002d94 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002d94:	7179                	addi	sp,sp,-48
    80002d96:	f406                	sd	ra,40(sp)
    80002d98:	f022                	sd	s0,32(sp)
    80002d9a:	ec26                	sd	s1,24(sp)
    80002d9c:	e84a                	sd	s2,16(sp)
    80002d9e:	e44e                	sd	s3,8(sp)
    80002da0:	1800                	addi	s0,sp,48
    80002da2:	892a                	mv	s2,a0
    80002da4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002da6:	00015517          	auipc	a0,0x15
    80002daa:	75a50513          	addi	a0,a0,1882 # 80018500 <bcache>
    80002dae:	e7bfd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002db2:	0001e497          	auipc	s1,0x1e
    80002db6:	a064b483          	ld	s1,-1530(s1) # 800207b8 <bcache+0x82b8>
    80002dba:	0001e797          	auipc	a5,0x1e
    80002dbe:	9ae78793          	addi	a5,a5,-1618 # 80020768 <bcache+0x8268>
    80002dc2:	02f48b63          	beq	s1,a5,80002df8 <bread+0x64>
    80002dc6:	873e                	mv	a4,a5
    80002dc8:	a021                	j	80002dd0 <bread+0x3c>
    80002dca:	68a4                	ld	s1,80(s1)
    80002dcc:	02e48663          	beq	s1,a4,80002df8 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002dd0:	449c                	lw	a5,8(s1)
    80002dd2:	ff279ce3          	bne	a5,s2,80002dca <bread+0x36>
    80002dd6:	44dc                	lw	a5,12(s1)
    80002dd8:	ff3799e3          	bne	a5,s3,80002dca <bread+0x36>
      b->refcnt++;
    80002ddc:	40bc                	lw	a5,64(s1)
    80002dde:	2785                	addiw	a5,a5,1
    80002de0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002de2:	00015517          	auipc	a0,0x15
    80002de6:	71e50513          	addi	a0,a0,1822 # 80018500 <bcache>
    80002dea:	ec7fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002dee:	01048513          	addi	a0,s1,16
    80002df2:	3ce010ef          	jal	800041c0 <acquiresleep>
      return b;
    80002df6:	a889                	j	80002e48 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002df8:	0001e497          	auipc	s1,0x1e
    80002dfc:	9b84b483          	ld	s1,-1608(s1) # 800207b0 <bcache+0x82b0>
    80002e00:	0001e797          	auipc	a5,0x1e
    80002e04:	96878793          	addi	a5,a5,-1688 # 80020768 <bcache+0x8268>
    80002e08:	00f48863          	beq	s1,a5,80002e18 <bread+0x84>
    80002e0c:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002e0e:	40bc                	lw	a5,64(s1)
    80002e10:	cb91                	beqz	a5,80002e24 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002e12:	64a4                	ld	s1,72(s1)
    80002e14:	fee49de3          	bne	s1,a4,80002e0e <bread+0x7a>
  panic("bget: no buffers");
    80002e18:	00004517          	auipc	a0,0x4
    80002e1c:	5a850513          	addi	a0,a0,1448 # 800073c0 <etext+0x3c0>
    80002e20:	a15fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002e24:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002e28:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002e2c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e30:	4785                	li	a5,1
    80002e32:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e34:	00015517          	auipc	a0,0x15
    80002e38:	6cc50513          	addi	a0,a0,1740 # 80018500 <bcache>
    80002e3c:	e75fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002e40:	01048513          	addi	a0,s1,16
    80002e44:	37c010ef          	jal	800041c0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002e48:	409c                	lw	a5,0(s1)
    80002e4a:	cb89                	beqz	a5,80002e5c <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e4c:	8526                	mv	a0,s1
    80002e4e:	70a2                	ld	ra,40(sp)
    80002e50:	7402                	ld	s0,32(sp)
    80002e52:	64e2                	ld	s1,24(sp)
    80002e54:	6942                	ld	s2,16(sp)
    80002e56:	69a2                	ld	s3,8(sp)
    80002e58:	6145                	addi	sp,sp,48
    80002e5a:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e5c:	4581                	li	a1,0
    80002e5e:	8526                	mv	a0,s1
    80002e60:	4c7020ef          	jal	80005b26 <virtio_disk_rw>
    b->valid = 1;
    80002e64:	4785                	li	a5,1
    80002e66:	c09c                	sw	a5,0(s1)
  return b;
    80002e68:	b7d5                	j	80002e4c <bread+0xb8>

0000000080002e6a <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002e6a:	1101                	addi	sp,sp,-32
    80002e6c:	ec06                	sd	ra,24(sp)
    80002e6e:	e822                	sd	s0,16(sp)
    80002e70:	e426                	sd	s1,8(sp)
    80002e72:	1000                	addi	s0,sp,32
    80002e74:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002e76:	0541                	addi	a0,a0,16
    80002e78:	3d4010ef          	jal	8000424c <holdingsleep>
    80002e7c:	c911                	beqz	a0,80002e90 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e7e:	4585                	li	a1,1
    80002e80:	8526                	mv	a0,s1
    80002e82:	4a5020ef          	jal	80005b26 <virtio_disk_rw>
}
    80002e86:	60e2                	ld	ra,24(sp)
    80002e88:	6442                	ld	s0,16(sp)
    80002e8a:	64a2                	ld	s1,8(sp)
    80002e8c:	6105                	addi	sp,sp,32
    80002e8e:	8082                	ret
    panic("bwrite");
    80002e90:	00004517          	auipc	a0,0x4
    80002e94:	54850513          	addi	a0,a0,1352 # 800073d8 <etext+0x3d8>
    80002e98:	99dfd0ef          	jal	80000834 <panic>

0000000080002e9c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e9c:	1101                	addi	sp,sp,-32
    80002e9e:	ec06                	sd	ra,24(sp)
    80002ea0:	e822                	sd	s0,16(sp)
    80002ea2:	e426                	sd	s1,8(sp)
    80002ea4:	e04a                	sd	s2,0(sp)
    80002ea6:	1000                	addi	s0,sp,32
    80002ea8:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002eaa:	01050913          	addi	s2,a0,16
    80002eae:	854a                	mv	a0,s2
    80002eb0:	39c010ef          	jal	8000424c <holdingsleep>
    80002eb4:	c125                	beqz	a0,80002f14 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002eb6:	854a                	mv	a0,s2
    80002eb8:	35c010ef          	jal	80004214 <releasesleep>

  acquire(&bcache.lock);
    80002ebc:	00015517          	auipc	a0,0x15
    80002ec0:	64450513          	addi	a0,a0,1604 # 80018500 <bcache>
    80002ec4:	d65fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002ec8:	40bc                	lw	a5,64(s1)
    80002eca:	37fd                	addiw	a5,a5,-1
    80002ecc:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002ece:	e79d                	bnez	a5,80002efc <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002ed0:	68b8                	ld	a4,80(s1)
    80002ed2:	64bc                	ld	a5,72(s1)
    80002ed4:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002ed6:	68b8                	ld	a4,80(s1)
    80002ed8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002eda:	0001d797          	auipc	a5,0x1d
    80002ede:	62678793          	addi	a5,a5,1574 # 80020500 <bcache+0x8000>
    80002ee2:	2b87b703          	ld	a4,696(a5)
    80002ee6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ee8:	0001e717          	auipc	a4,0x1e
    80002eec:	88070713          	addi	a4,a4,-1920 # 80020768 <bcache+0x8268>
    80002ef0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002ef2:	2b87b703          	ld	a4,696(a5)
    80002ef6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002ef8:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002efc:	00015517          	auipc	a0,0x15
    80002f00:	60450513          	addi	a0,a0,1540 # 80018500 <bcache>
    80002f04:	dadfd0ef          	jal	80000cb0 <release>
}
    80002f08:	60e2                	ld	ra,24(sp)
    80002f0a:	6442                	ld	s0,16(sp)
    80002f0c:	64a2                	ld	s1,8(sp)
    80002f0e:	6902                	ld	s2,0(sp)
    80002f10:	6105                	addi	sp,sp,32
    80002f12:	8082                	ret
    panic("brelse");
    80002f14:	00004517          	auipc	a0,0x4
    80002f18:	4cc50513          	addi	a0,a0,1228 # 800073e0 <etext+0x3e0>
    80002f1c:	919fd0ef          	jal	80000834 <panic>

0000000080002f20 <bpin>:

void
bpin(struct buf *b)
{
    80002f20:	1101                	addi	sp,sp,-32
    80002f22:	ec06                	sd	ra,24(sp)
    80002f24:	e822                	sd	s0,16(sp)
    80002f26:	e426                	sd	s1,8(sp)
    80002f28:	1000                	addi	s0,sp,32
    80002f2a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f2c:	00015517          	auipc	a0,0x15
    80002f30:	5d450513          	addi	a0,a0,1492 # 80018500 <bcache>
    80002f34:	cf5fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002f38:	40bc                	lw	a5,64(s1)
    80002f3a:	2785                	addiw	a5,a5,1
    80002f3c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f3e:	00015517          	auipc	a0,0x15
    80002f42:	5c250513          	addi	a0,a0,1474 # 80018500 <bcache>
    80002f46:	d6bfd0ef          	jal	80000cb0 <release>
}
    80002f4a:	60e2                	ld	ra,24(sp)
    80002f4c:	6442                	ld	s0,16(sp)
    80002f4e:	64a2                	ld	s1,8(sp)
    80002f50:	6105                	addi	sp,sp,32
    80002f52:	8082                	ret

0000000080002f54 <bunpin>:

void
bunpin(struct buf *b)
{
    80002f54:	1101                	addi	sp,sp,-32
    80002f56:	ec06                	sd	ra,24(sp)
    80002f58:	e822                	sd	s0,16(sp)
    80002f5a:	e426                	sd	s1,8(sp)
    80002f5c:	1000                	addi	s0,sp,32
    80002f5e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f60:	00015517          	auipc	a0,0x15
    80002f64:	5a050513          	addi	a0,a0,1440 # 80018500 <bcache>
    80002f68:	cc1fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002f6c:	40bc                	lw	a5,64(s1)
    80002f6e:	37fd                	addiw	a5,a5,-1
    80002f70:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f72:	00015517          	auipc	a0,0x15
    80002f76:	58e50513          	addi	a0,a0,1422 # 80018500 <bcache>
    80002f7a:	d37fd0ef          	jal	80000cb0 <release>
}
    80002f7e:	60e2                	ld	ra,24(sp)
    80002f80:	6442                	ld	s0,16(sp)
    80002f82:	64a2                	ld	s1,8(sp)
    80002f84:	6105                	addi	sp,sp,32
    80002f86:	8082                	ret

0000000080002f88 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f88:	1101                	addi	sp,sp,-32
    80002f8a:	ec06                	sd	ra,24(sp)
    80002f8c:	e822                	sd	s0,16(sp)
    80002f8e:	e426                	sd	s1,8(sp)
    80002f90:	e04a                	sd	s2,0(sp)
    80002f92:	1000                	addi	s0,sp,32
    80002f94:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f96:	00d5d79b          	srliw	a5,a1,0xd
    80002f9a:	0001e597          	auipc	a1,0x1e
    80002f9e:	c425a583          	lw	a1,-958(a1) # 80020bdc <sb+0x1c>
    80002fa2:	9dbd                	addw	a1,a1,a5
    80002fa4:	df1ff0ef          	jal	80002d94 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002fa8:	0074f713          	andi	a4,s1,7
    80002fac:	4785                	li	a5,1
    80002fae:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002fb2:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002fb4:	90d9                	srli	s1,s1,0x36
    80002fb6:	00950733          	add	a4,a0,s1
    80002fba:	05874703          	lbu	a4,88(a4)
    80002fbe:	00e7f6b3          	and	a3,a5,a4
    80002fc2:	c29d                	beqz	a3,80002fe8 <bfree+0x60>
    80002fc4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002fc6:	94aa                	add	s1,s1,a0
    80002fc8:	fff7c793          	not	a5,a5
    80002fcc:	8f7d                	and	a4,a4,a5
    80002fce:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002fd2:	080010ef          	jal	80004052 <log_write>
  brelse(bp);
    80002fd6:	854a                	mv	a0,s2
    80002fd8:	ec5ff0ef          	jal	80002e9c <brelse>
}
    80002fdc:	60e2                	ld	ra,24(sp)
    80002fde:	6442                	ld	s0,16(sp)
    80002fe0:	64a2                	ld	s1,8(sp)
    80002fe2:	6902                	ld	s2,0(sp)
    80002fe4:	6105                	addi	sp,sp,32
    80002fe6:	8082                	ret
    panic("freeing free block");
    80002fe8:	00004517          	auipc	a0,0x4
    80002fec:	40050513          	addi	a0,a0,1024 # 800073e8 <etext+0x3e8>
    80002ff0:	845fd0ef          	jal	80000834 <panic>

0000000080002ff4 <balloc>:
{
    80002ff4:	715d                	addi	sp,sp,-80
    80002ff6:	e486                	sd	ra,72(sp)
    80002ff8:	e0a2                	sd	s0,64(sp)
    80002ffa:	fc26                	sd	s1,56(sp)
    80002ffc:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002ffe:	0001e797          	auipc	a5,0x1e
    80003002:	bc67a783          	lw	a5,-1082(a5) # 80020bc4 <sb+0x4>
    80003006:	0e078263          	beqz	a5,800030ea <balloc+0xf6>
    8000300a:	f84a                	sd	s2,48(sp)
    8000300c:	f44e                	sd	s3,40(sp)
    8000300e:	f052                	sd	s4,32(sp)
    80003010:	ec56                	sd	s5,24(sp)
    80003012:	e85a                	sd	s6,16(sp)
    80003014:	e45e                	sd	s7,8(sp)
    80003016:	e062                	sd	s8,0(sp)
    80003018:	8baa                	mv	s7,a0
    8000301a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000301c:	0001eb17          	auipc	s6,0x1e
    80003020:	ba4b0b13          	addi	s6,s6,-1116 # 80020bc0 <sb>
      m = 1 << (bi % 8);
    80003024:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003026:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80003028:	6c09                	lui	s8,0x2
    8000302a:	a09d                	j	80003090 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    8000302c:	97ca                	add	a5,a5,s2
    8000302e:	8e55                	or	a2,a2,a3
    80003030:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003034:	854a                	mv	a0,s2
    80003036:	01c010ef          	jal	80004052 <log_write>
        brelse(bp);
    8000303a:	854a                	mv	a0,s2
    8000303c:	e61ff0ef          	jal	80002e9c <brelse>
  bp = bread(dev, bno);
    80003040:	85a6                	mv	a1,s1
    80003042:	855e                	mv	a0,s7
    80003044:	d51ff0ef          	jal	80002d94 <bread>
    80003048:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000304a:	40000613          	li	a2,1024
    8000304e:	4581                	li	a1,0
    80003050:	05850513          	addi	a0,a0,88
    80003054:	c95fd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    80003058:	854a                	mv	a0,s2
    8000305a:	7f9000ef          	jal	80004052 <log_write>
  brelse(bp);
    8000305e:	854a                	mv	a0,s2
    80003060:	e3dff0ef          	jal	80002e9c <brelse>
}
    80003064:	7942                	ld	s2,48(sp)
    80003066:	79a2                	ld	s3,40(sp)
    80003068:	7a02                	ld	s4,32(sp)
    8000306a:	6ae2                	ld	s5,24(sp)
    8000306c:	6b42                	ld	s6,16(sp)
    8000306e:	6ba2                	ld	s7,8(sp)
    80003070:	6c02                	ld	s8,0(sp)
}
    80003072:	8526                	mv	a0,s1
    80003074:	60a6                	ld	ra,72(sp)
    80003076:	6406                	ld	s0,64(sp)
    80003078:	74e2                	ld	s1,56(sp)
    8000307a:	6161                	addi	sp,sp,80
    8000307c:	8082                	ret
    brelse(bp);
    8000307e:	854a                	mv	a0,s2
    80003080:	e1dff0ef          	jal	80002e9c <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80003084:	015c0abb          	addw	s5,s8,s5
    80003088:	004b2783          	lw	a5,4(s6)
    8000308c:	04faf863          	bgeu	s5,a5,800030dc <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80003090:	40dad59b          	sraiw	a1,s5,0xd
    80003094:	01cb2783          	lw	a5,28(s6)
    80003098:	9dbd                	addw	a1,a1,a5
    8000309a:	855e                	mv	a0,s7
    8000309c:	cf9ff0ef          	jal	80002d94 <bread>
    800030a0:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    800030a2:	004b2503          	lw	a0,4(s6)
    800030a6:	84d6                	mv	s1,s5
    800030a8:	4701                	li	a4,0
    800030aa:	fca4fae3          	bgeu	s1,a0,8000307e <balloc+0x8a>
      m = 1 << (bi % 8);
    800030ae:	00777693          	andi	a3,a4,7
    800030b2:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    800030b6:	41f7579b          	sraiw	a5,a4,0x1f
    800030ba:	01d7d79b          	srliw	a5,a5,0x1d
    800030be:	9fb9                	addw	a5,a5,a4
    800030c0:	4037d79b          	sraiw	a5,a5,0x3
    800030c4:	00f90633          	add	a2,s2,a5
    800030c8:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800030cc:	00c6f5b3          	and	a1,a3,a2
    800030d0:	ddb1                	beqz	a1,8000302c <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    800030d2:	2705                	addiw	a4,a4,1
    800030d4:	2485                	addiw	s1,s1,1
    800030d6:	fd471ae3          	bne	a4,s4,800030aa <balloc+0xb6>
    800030da:	b755                	j	8000307e <balloc+0x8a>
    800030dc:	7942                	ld	s2,48(sp)
    800030de:	79a2                	ld	s3,40(sp)
    800030e0:	7a02                	ld	s4,32(sp)
    800030e2:	6ae2                	ld	s5,24(sp)
    800030e4:	6b42                	ld	s6,16(sp)
    800030e6:	6ba2                	ld	s7,8(sp)
    800030e8:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    800030ea:	00004517          	auipc	a0,0x4
    800030ee:	31650513          	addi	a0,a0,790 # 80007400 <etext+0x400>
    800030f2:	c18fd0ef          	jal	8000050a <printk>
  return 0;
    800030f6:	4481                	li	s1,0
    800030f8:	bfad                	j	80003072 <balloc+0x7e>

00000000800030fa <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800030fa:	7179                	addi	sp,sp,-48
    800030fc:	f406                	sd	ra,40(sp)
    800030fe:	f022                	sd	s0,32(sp)
    80003100:	ec26                	sd	s1,24(sp)
    80003102:	e84a                	sd	s2,16(sp)
    80003104:	e44e                	sd	s3,8(sp)
    80003106:	1800                	addi	s0,sp,48
    80003108:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    8000310a:	47ad                	li	a5,11
    8000310c:	02b7e363          	bltu	a5,a1,80003132 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80003110:	02059793          	slli	a5,a1,0x20
    80003114:	01e7d593          	srli	a1,a5,0x1e
    80003118:	00b509b3          	add	s3,a0,a1
    8000311c:	0509a483          	lw	s1,80(s3)
    80003120:	e0b5                	bnez	s1,80003184 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003122:	4108                	lw	a0,0(a0)
    80003124:	ed1ff0ef          	jal	80002ff4 <balloc>
    80003128:	84aa                	mv	s1,a0
      if (addr == 0)
    8000312a:	cd29                	beqz	a0,80003184 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    8000312c:	04a9a823          	sw	a0,80(s3)
    80003130:	a891                	j	80003184 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003132:	ff45879b          	addiw	a5,a1,-12
    80003136:	873e                	mv	a4,a5
    80003138:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    8000313a:	0ff00793          	li	a5,255
    8000313e:	06e7e763          	bltu	a5,a4,800031ac <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80003142:	08052483          	lw	s1,128(a0)
    80003146:	e891                	bnez	s1,8000315a <bmap+0x60>
      addr = balloc(ip->dev);
    80003148:	4108                	lw	a0,0(a0)
    8000314a:	eabff0ef          	jal	80002ff4 <balloc>
    8000314e:	84aa                	mv	s1,a0
      if (addr == 0)
    80003150:	c915                	beqz	a0,80003184 <bmap+0x8a>
    80003152:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003154:	08a92023          	sw	a0,128(s2)
    80003158:	a011                	j	8000315c <bmap+0x62>
    8000315a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000315c:	85a6                	mv	a1,s1
    8000315e:	00092503          	lw	a0,0(s2)
    80003162:	c33ff0ef          	jal	80002d94 <bread>
    80003166:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80003168:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    8000316c:	02099713          	slli	a4,s3,0x20
    80003170:	01e75593          	srli	a1,a4,0x1e
    80003174:	97ae                	add	a5,a5,a1
    80003176:	89be                	mv	s3,a5
    80003178:	4384                	lw	s1,0(a5)
    8000317a:	cc89                	beqz	s1,80003194 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000317c:	8552                	mv	a0,s4
    8000317e:	d1fff0ef          	jal	80002e9c <brelse>
    return addr;
    80003182:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003184:	8526                	mv	a0,s1
    80003186:	70a2                	ld	ra,40(sp)
    80003188:	7402                	ld	s0,32(sp)
    8000318a:	64e2                	ld	s1,24(sp)
    8000318c:	6942                	ld	s2,16(sp)
    8000318e:	69a2                	ld	s3,8(sp)
    80003190:	6145                	addi	sp,sp,48
    80003192:	8082                	ret
      addr = balloc(ip->dev);
    80003194:	00092503          	lw	a0,0(s2)
    80003198:	e5dff0ef          	jal	80002ff4 <balloc>
    8000319c:	84aa                	mv	s1,a0
      if (addr) {
    8000319e:	dd79                	beqz	a0,8000317c <bmap+0x82>
        a[bn] = addr;
    800031a0:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800031a4:	8552                	mv	a0,s4
    800031a6:	6ad000ef          	jal	80004052 <log_write>
    800031aa:	bfc9                	j	8000317c <bmap+0x82>
    800031ac:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800031ae:	00004517          	auipc	a0,0x4
    800031b2:	26a50513          	addi	a0,a0,618 # 80007418 <etext+0x418>
    800031b6:	e7efd0ef          	jal	80000834 <panic>

00000000800031ba <iget>:
{
    800031ba:	7179                	addi	sp,sp,-48
    800031bc:	f406                	sd	ra,40(sp)
    800031be:	f022                	sd	s0,32(sp)
    800031c0:	ec26                	sd	s1,24(sp)
    800031c2:	e84a                	sd	s2,16(sp)
    800031c4:	e44e                	sd	s3,8(sp)
    800031c6:	e052                	sd	s4,0(sp)
    800031c8:	1800                	addi	s0,sp,48
    800031ca:	892a                	mv	s2,a0
    800031cc:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800031ce:	0001e517          	auipc	a0,0x1e
    800031d2:	a1250513          	addi	a0,a0,-1518 # 80020be0 <itable>
    800031d6:	a53fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    800031da:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800031dc:	0001e497          	auipc	s1,0x1e
    800031e0:	a1c48493          	addi	s1,s1,-1508 # 80020bf8 <itable+0x18>
    800031e4:	0001f697          	auipc	a3,0x1f
    800031e8:	4a468693          	addi	a3,a3,1188 # 80022688 <log>
    800031ec:	a809                	j	800031fe <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800031ee:	e781                	bnez	a5,800031f6 <iget+0x3c>
    800031f0:	00099363          	bnez	s3,800031f6 <iget+0x3c>
      empty = ip;
    800031f4:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800031f6:	08848493          	addi	s1,s1,136
    800031fa:	02d48563          	beq	s1,a3,80003224 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    800031fe:	449c                	lw	a5,8(s1)
    80003200:	fef057e3          	blez	a5,800031ee <iget+0x34>
    80003204:	4098                	lw	a4,0(s1)
    80003206:	ff2718e3          	bne	a4,s2,800031f6 <iget+0x3c>
    8000320a:	40d8                	lw	a4,4(s1)
    8000320c:	ff4715e3          	bne	a4,s4,800031f6 <iget+0x3c>
      ip->ref++;
    80003210:	2785                	addiw	a5,a5,1
    80003212:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003214:	0001e517          	auipc	a0,0x1e
    80003218:	9cc50513          	addi	a0,a0,-1588 # 80020be0 <itable>
    8000321c:	a95fd0ef          	jal	80000cb0 <release>
      return ip;
    80003220:	89a6                	mv	s3,s1
    80003222:	a015                	j	80003246 <iget+0x8c>
  if (empty == 0)
    80003224:	02098a63          	beqz	s3,80003258 <iget+0x9e>
  ip->dev = dev;
    80003228:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000322c:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003230:	4785                	li	a5,1
    80003232:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003236:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000323a:	0001e517          	auipc	a0,0x1e
    8000323e:	9a650513          	addi	a0,a0,-1626 # 80020be0 <itable>
    80003242:	a6ffd0ef          	jal	80000cb0 <release>
}
    80003246:	854e                	mv	a0,s3
    80003248:	70a2                	ld	ra,40(sp)
    8000324a:	7402                	ld	s0,32(sp)
    8000324c:	64e2                	ld	s1,24(sp)
    8000324e:	6942                	ld	s2,16(sp)
    80003250:	69a2                	ld	s3,8(sp)
    80003252:	6a02                	ld	s4,0(sp)
    80003254:	6145                	addi	sp,sp,48
    80003256:	8082                	ret
    panic("iget: no inodes");
    80003258:	00004517          	auipc	a0,0x4
    8000325c:	1d850513          	addi	a0,a0,472 # 80007430 <etext+0x430>
    80003260:	dd4fd0ef          	jal	80000834 <panic>

0000000080003264 <iinit>:
{
    80003264:	7179                	addi	sp,sp,-48
    80003266:	f406                	sd	ra,40(sp)
    80003268:	f022                	sd	s0,32(sp)
    8000326a:	ec26                	sd	s1,24(sp)
    8000326c:	e84a                	sd	s2,16(sp)
    8000326e:	e44e                	sd	s3,8(sp)
    80003270:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003272:	00004597          	auipc	a1,0x4
    80003276:	1ce58593          	addi	a1,a1,462 # 80007440 <etext+0x440>
    8000327a:	0001e517          	auipc	a0,0x1e
    8000327e:	96650513          	addi	a0,a0,-1690 # 80020be0 <itable>
    80003282:	927fd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    80003286:	0001e497          	auipc	s1,0x1e
    8000328a:	98248493          	addi	s1,s1,-1662 # 80020c08 <itable+0x28>
    8000328e:	0001f997          	auipc	s3,0x1f
    80003292:	40a98993          	addi	s3,s3,1034 # 80022698 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003296:	00004917          	auipc	s2,0x4
    8000329a:	1b290913          	addi	s2,s2,434 # 80007448 <etext+0x448>
    8000329e:	85ca                	mv	a1,s2
    800032a0:	8526                	mv	a0,s1
    800032a2:	6e9000ef          	jal	8000418a <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    800032a6:	08848493          	addi	s1,s1,136
    800032aa:	ff349ae3          	bne	s1,s3,8000329e <iinit+0x3a>
}
    800032ae:	70a2                	ld	ra,40(sp)
    800032b0:	7402                	ld	s0,32(sp)
    800032b2:	64e2                	ld	s1,24(sp)
    800032b4:	6942                	ld	s2,16(sp)
    800032b6:	69a2                	ld	s3,8(sp)
    800032b8:	6145                	addi	sp,sp,48
    800032ba:	8082                	ret

00000000800032bc <ialloc>:
{
    800032bc:	7139                	addi	sp,sp,-64
    800032be:	fc06                	sd	ra,56(sp)
    800032c0:	f822                	sd	s0,48(sp)
    800032c2:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    800032c4:	0001e717          	auipc	a4,0x1e
    800032c8:	90872703          	lw	a4,-1784(a4) # 80020bcc <sb+0xc>
    800032cc:	4785                	li	a5,1
    800032ce:	06e7f063          	bgeu	a5,a4,8000332e <ialloc+0x72>
    800032d2:	f426                	sd	s1,40(sp)
    800032d4:	f04a                	sd	s2,32(sp)
    800032d6:	ec4e                	sd	s3,24(sp)
    800032d8:	e852                	sd	s4,16(sp)
    800032da:	e456                	sd	s5,8(sp)
    800032dc:	e05a                	sd	s6,0(sp)
    800032de:	8aaa                	mv	s5,a0
    800032e0:	8b2e                	mv	s6,a1
    800032e2:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800032e4:	0001ea17          	auipc	s4,0x1e
    800032e8:	8dca0a13          	addi	s4,s4,-1828 # 80020bc0 <sb>
    800032ec:	00495593          	srli	a1,s2,0x4
    800032f0:	018a2783          	lw	a5,24(s4)
    800032f4:	9dbd                	addw	a1,a1,a5
    800032f6:	8556                	mv	a0,s5
    800032f8:	a9dff0ef          	jal	80002d94 <bread>
    800032fc:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    800032fe:	05850993          	addi	s3,a0,88
    80003302:	00f97793          	andi	a5,s2,15
    80003306:	079a                	slli	a5,a5,0x6
    80003308:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    8000330a:	00099783          	lh	a5,0(s3)
    8000330e:	cb9d                	beqz	a5,80003344 <ialloc+0x88>
    brelse(bp);
    80003310:	b8dff0ef          	jal	80002e9c <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003314:	0905                	addi	s2,s2,1
    80003316:	00ca2703          	lw	a4,12(s4)
    8000331a:	0009079b          	sext.w	a5,s2
    8000331e:	fce7e7e3          	bltu	a5,a4,800032ec <ialloc+0x30>
    80003322:	74a2                	ld	s1,40(sp)
    80003324:	7902                	ld	s2,32(sp)
    80003326:	69e2                	ld	s3,24(sp)
    80003328:	6a42                	ld	s4,16(sp)
    8000332a:	6aa2                	ld	s5,8(sp)
    8000332c:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    8000332e:	00004517          	auipc	a0,0x4
    80003332:	12250513          	addi	a0,a0,290 # 80007450 <etext+0x450>
    80003336:	9d4fd0ef          	jal	8000050a <printk>
  return 0;
    8000333a:	4501                	li	a0,0
}
    8000333c:	70e2                	ld	ra,56(sp)
    8000333e:	7442                	ld	s0,48(sp)
    80003340:	6121                	addi	sp,sp,64
    80003342:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003344:	04000613          	li	a2,64
    80003348:	4581                	li	a1,0
    8000334a:	854e                	mv	a0,s3
    8000334c:	99dfd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    80003350:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003354:	8526                	mv	a0,s1
    80003356:	4fd000ef          	jal	80004052 <log_write>
      brelse(bp);
    8000335a:	8526                	mv	a0,s1
    8000335c:	b41ff0ef          	jal	80002e9c <brelse>
      return iget(dev, inum);
    80003360:	0009059b          	sext.w	a1,s2
    80003364:	8556                	mv	a0,s5
    80003366:	e55ff0ef          	jal	800031ba <iget>
    8000336a:	74a2                	ld	s1,40(sp)
    8000336c:	7902                	ld	s2,32(sp)
    8000336e:	69e2                	ld	s3,24(sp)
    80003370:	6a42                	ld	s4,16(sp)
    80003372:	6aa2                	ld	s5,8(sp)
    80003374:	6b02                	ld	s6,0(sp)
    80003376:	b7d9                	j	8000333c <ialloc+0x80>

0000000080003378 <iupdate>:
{
    80003378:	1101                	addi	sp,sp,-32
    8000337a:	ec06                	sd	ra,24(sp)
    8000337c:	e822                	sd	s0,16(sp)
    8000337e:	e426                	sd	s1,8(sp)
    80003380:	e04a                	sd	s2,0(sp)
    80003382:	1000                	addi	s0,sp,32
    80003384:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003386:	415c                	lw	a5,4(a0)
    80003388:	0047d79b          	srliw	a5,a5,0x4
    8000338c:	0001e597          	auipc	a1,0x1e
    80003390:	84c5a583          	lw	a1,-1972(a1) # 80020bd8 <sb+0x18>
    80003394:	9dbd                	addw	a1,a1,a5
    80003396:	4108                	lw	a0,0(a0)
    80003398:	9fdff0ef          	jal	80002d94 <bread>
    8000339c:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000339e:	05850793          	addi	a5,a0,88
    800033a2:	40d8                	lw	a4,4(s1)
    800033a4:	8b3d                	andi	a4,a4,15
    800033a6:	071a                	slli	a4,a4,0x6
    800033a8:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800033aa:	04449703          	lh	a4,68(s1)
    800033ae:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800033b2:	04649703          	lh	a4,70(s1)
    800033b6:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800033ba:	04849703          	lh	a4,72(s1)
    800033be:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800033c2:	04a49703          	lh	a4,74(s1)
    800033c6:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800033ca:	44f8                	lw	a4,76(s1)
    800033cc:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800033ce:	03400613          	li	a2,52
    800033d2:	05048593          	addi	a1,s1,80
    800033d6:	00c78513          	addi	a0,a5,12
    800033da:	96ffd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    800033de:	854a                	mv	a0,s2
    800033e0:	473000ef          	jal	80004052 <log_write>
  brelse(bp);
    800033e4:	854a                	mv	a0,s2
    800033e6:	ab7ff0ef          	jal	80002e9c <brelse>
}
    800033ea:	60e2                	ld	ra,24(sp)
    800033ec:	6442                	ld	s0,16(sp)
    800033ee:	64a2                	ld	s1,8(sp)
    800033f0:	6902                	ld	s2,0(sp)
    800033f2:	6105                	addi	sp,sp,32
    800033f4:	8082                	ret

00000000800033f6 <idup>:
{
    800033f6:	1101                	addi	sp,sp,-32
    800033f8:	ec06                	sd	ra,24(sp)
    800033fa:	e822                	sd	s0,16(sp)
    800033fc:	e426                	sd	s1,8(sp)
    800033fe:	1000                	addi	s0,sp,32
    80003400:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003402:	0001d517          	auipc	a0,0x1d
    80003406:	7de50513          	addi	a0,a0,2014 # 80020be0 <itable>
    8000340a:	81ffd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    8000340e:	449c                	lw	a5,8(s1)
    80003410:	2785                	addiw	a5,a5,1
    80003412:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003414:	0001d517          	auipc	a0,0x1d
    80003418:	7cc50513          	addi	a0,a0,1996 # 80020be0 <itable>
    8000341c:	895fd0ef          	jal	80000cb0 <release>
}
    80003420:	8526                	mv	a0,s1
    80003422:	60e2                	ld	ra,24(sp)
    80003424:	6442                	ld	s0,16(sp)
    80003426:	64a2                	ld	s1,8(sp)
    80003428:	6105                	addi	sp,sp,32
    8000342a:	8082                	ret

000000008000342c <ilock>:
{
    8000342c:	1101                	addi	sp,sp,-32
    8000342e:	ec06                	sd	ra,24(sp)
    80003430:	e822                	sd	s0,16(sp)
    80003432:	e426                	sd	s1,8(sp)
    80003434:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003436:	cd19                	beqz	a0,80003454 <ilock+0x28>
    80003438:	84aa                	mv	s1,a0
    8000343a:	451c                	lw	a5,8(a0)
    8000343c:	00f05c63          	blez	a5,80003454 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003440:	0541                	addi	a0,a0,16
    80003442:	57f000ef          	jal	800041c0 <acquiresleep>
  if (ip->valid == 0) {
    80003446:	40bc                	lw	a5,64(s1)
    80003448:	cf89                	beqz	a5,80003462 <ilock+0x36>
}
    8000344a:	60e2                	ld	ra,24(sp)
    8000344c:	6442                	ld	s0,16(sp)
    8000344e:	64a2                	ld	s1,8(sp)
    80003450:	6105                	addi	sp,sp,32
    80003452:	8082                	ret
    80003454:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003456:	00004517          	auipc	a0,0x4
    8000345a:	01250513          	addi	a0,a0,18 # 80007468 <etext+0x468>
    8000345e:	bd6fd0ef          	jal	80000834 <panic>
    80003462:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003464:	40dc                	lw	a5,4(s1)
    80003466:	0047d79b          	srliw	a5,a5,0x4
    8000346a:	0001d597          	auipc	a1,0x1d
    8000346e:	76e5a583          	lw	a1,1902(a1) # 80020bd8 <sb+0x18>
    80003472:	9dbd                	addw	a1,a1,a5
    80003474:	4088                	lw	a0,0(s1)
    80003476:	91fff0ef          	jal	80002d94 <bread>
    8000347a:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000347c:	05850593          	addi	a1,a0,88
    80003480:	40dc                	lw	a5,4(s1)
    80003482:	8bbd                	andi	a5,a5,15
    80003484:	079a                	slli	a5,a5,0x6
    80003486:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003488:	00059783          	lh	a5,0(a1)
    8000348c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003490:	00259783          	lh	a5,2(a1)
    80003494:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003498:	00459783          	lh	a5,4(a1)
    8000349c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800034a0:	00659783          	lh	a5,6(a1)
    800034a4:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800034a8:	459c                	lw	a5,8(a1)
    800034aa:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800034ac:	03400613          	li	a2,52
    800034b0:	05b1                	addi	a1,a1,12
    800034b2:	05048513          	addi	a0,s1,80
    800034b6:	893fd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    800034ba:	854a                	mv	a0,s2
    800034bc:	9e1ff0ef          	jal	80002e9c <brelse>
    ip->valid = 1;
    800034c0:	4785                	li	a5,1
    800034c2:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    800034c4:	04449783          	lh	a5,68(s1)
    800034c8:	c399                	beqz	a5,800034ce <ilock+0xa2>
    800034ca:	6902                	ld	s2,0(sp)
    800034cc:	bfbd                	j	8000344a <ilock+0x1e>
      panic("ilock: no type");
    800034ce:	00004517          	auipc	a0,0x4
    800034d2:	fa250513          	addi	a0,a0,-94 # 80007470 <etext+0x470>
    800034d6:	b5efd0ef          	jal	80000834 <panic>

00000000800034da <iunlock>:
{
    800034da:	1101                	addi	sp,sp,-32
    800034dc:	ec06                	sd	ra,24(sp)
    800034de:	e822                	sd	s0,16(sp)
    800034e0:	e426                	sd	s1,8(sp)
    800034e2:	e04a                	sd	s2,0(sp)
    800034e4:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800034e6:	c505                	beqz	a0,8000350e <iunlock+0x34>
    800034e8:	84aa                	mv	s1,a0
    800034ea:	01050913          	addi	s2,a0,16
    800034ee:	854a                	mv	a0,s2
    800034f0:	55d000ef          	jal	8000424c <holdingsleep>
    800034f4:	cd09                	beqz	a0,8000350e <iunlock+0x34>
    800034f6:	449c                	lw	a5,8(s1)
    800034f8:	00f05b63          	blez	a5,8000350e <iunlock+0x34>
  releasesleep(&ip->lock);
    800034fc:	854a                	mv	a0,s2
    800034fe:	517000ef          	jal	80004214 <releasesleep>
}
    80003502:	60e2                	ld	ra,24(sp)
    80003504:	6442                	ld	s0,16(sp)
    80003506:	64a2                	ld	s1,8(sp)
    80003508:	6902                	ld	s2,0(sp)
    8000350a:	6105                	addi	sp,sp,32
    8000350c:	8082                	ret
    panic("iunlock");
    8000350e:	00004517          	auipc	a0,0x4
    80003512:	f7250513          	addi	a0,a0,-142 # 80007480 <etext+0x480>
    80003516:	b1efd0ef          	jal	80000834 <panic>

000000008000351a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000351a:	7179                	addi	sp,sp,-48
    8000351c:	f406                	sd	ra,40(sp)
    8000351e:	f022                	sd	s0,32(sp)
    80003520:	ec26                	sd	s1,24(sp)
    80003522:	e84a                	sd	s2,16(sp)
    80003524:	e44e                	sd	s3,8(sp)
    80003526:	1800                	addi	s0,sp,48
    80003528:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    8000352a:	05050493          	addi	s1,a0,80
    8000352e:	08050913          	addi	s2,a0,128
    80003532:	a021                	j	8000353a <itrunc+0x20>
    80003534:	0491                	addi	s1,s1,4
    80003536:	01248b63          	beq	s1,s2,8000354c <itrunc+0x32>
    if (ip->addrs[i]) {
    8000353a:	408c                	lw	a1,0(s1)
    8000353c:	dde5                	beqz	a1,80003534 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000353e:	0009a503          	lw	a0,0(s3)
    80003542:	a47ff0ef          	jal	80002f88 <bfree>
      ip->addrs[i] = 0;
    80003546:	0004a023          	sw	zero,0(s1)
    8000354a:	b7ed                	j	80003534 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    8000354c:	0809a583          	lw	a1,128(s3)
    80003550:	ed89                	bnez	a1,8000356a <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003552:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003556:	854e                	mv	a0,s3
    80003558:	e21ff0ef          	jal	80003378 <iupdate>
}
    8000355c:	70a2                	ld	ra,40(sp)
    8000355e:	7402                	ld	s0,32(sp)
    80003560:	64e2                	ld	s1,24(sp)
    80003562:	6942                	ld	s2,16(sp)
    80003564:	69a2                	ld	s3,8(sp)
    80003566:	6145                	addi	sp,sp,48
    80003568:	8082                	ret
    8000356a:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000356c:	0009a503          	lw	a0,0(s3)
    80003570:	825ff0ef          	jal	80002d94 <bread>
    80003574:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    80003576:	05850493          	addi	s1,a0,88
    8000357a:	45850913          	addi	s2,a0,1112
    8000357e:	a021                	j	80003586 <itrunc+0x6c>
    80003580:	0491                	addi	s1,s1,4
    80003582:	01248963          	beq	s1,s2,80003594 <itrunc+0x7a>
      if (a[j])
    80003586:	408c                	lw	a1,0(s1)
    80003588:	dde5                	beqz	a1,80003580 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000358a:	0009a503          	lw	a0,0(s3)
    8000358e:	9fbff0ef          	jal	80002f88 <bfree>
    80003592:	b7fd                	j	80003580 <itrunc+0x66>
    brelse(bp);
    80003594:	8552                	mv	a0,s4
    80003596:	907ff0ef          	jal	80002e9c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000359a:	0809a583          	lw	a1,128(s3)
    8000359e:	0009a503          	lw	a0,0(s3)
    800035a2:	9e7ff0ef          	jal	80002f88 <bfree>
    ip->addrs[NDIRECT] = 0;
    800035a6:	0809a023          	sw	zero,128(s3)
    800035aa:	6a02                	ld	s4,0(sp)
    800035ac:	b75d                	j	80003552 <itrunc+0x38>

00000000800035ae <iput>:
{
    800035ae:	7179                	addi	sp,sp,-48
    800035b0:	f406                	sd	ra,40(sp)
    800035b2:	f022                	sd	s0,32(sp)
    800035b4:	ec26                	sd	s1,24(sp)
    800035b6:	1800                	addi	s0,sp,48
    800035b8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800035ba:	0001d517          	auipc	a0,0x1d
    800035be:	62650513          	addi	a0,a0,1574 # 80020be0 <itable>
    800035c2:	e66fd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800035c6:	449c                	lw	a5,8(s1)
    800035c8:	4705                	li	a4,1
    800035ca:	00e78f63          	beq	a5,a4,800035e8 <iput+0x3a>
  ip->ref--;
    800035ce:	37fd                	addiw	a5,a5,-1
    800035d0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035d2:	0001d517          	auipc	a0,0x1d
    800035d6:	60e50513          	addi	a0,a0,1550 # 80020be0 <itable>
    800035da:	ed6fd0ef          	jal	80000cb0 <release>
}
    800035de:	70a2                	ld	ra,40(sp)
    800035e0:	7402                	ld	s0,32(sp)
    800035e2:	64e2                	ld	s1,24(sp)
    800035e4:	6145                	addi	sp,sp,48
    800035e6:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800035e8:	40b8                	lw	a4,64(s1)
    800035ea:	d375                	beqz	a4,800035ce <iput+0x20>
    800035ec:	e84a                	sd	s2,16(sp)
    800035ee:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    800035f0:	0004aa03          	lw	s4,0(s1)
    800035f4:	0044a903          	lw	s2,4(s1)
  if (last) {
    800035f8:	04a49703          	lh	a4,74(s1)
    800035fc:	ef3d                	bnez	a4,8000367a <iput+0xcc>
    800035fe:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    80003600:	01048793          	addi	a5,s1,16
    80003604:	89be                	mv	s3,a5
    80003606:	853e                	mv	a0,a5
    80003608:	3b9000ef          	jal	800041c0 <acquiresleep>
    release(&itable.lock);
    8000360c:	0001d517          	auipc	a0,0x1d
    80003610:	5d450513          	addi	a0,a0,1492 # 80020be0 <itable>
    80003614:	e9cfd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    80003618:	8526                	mv	a0,s1
    8000361a:	f01ff0ef          	jal	8000351a <itrunc>
    ip->valid = 0;
    8000361e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003622:	854e                	mv	a0,s3
    80003624:	3f1000ef          	jal	80004214 <releasesleep>
    acquire(&itable.lock);
    80003628:	0001d517          	auipc	a0,0x1d
    8000362c:	5b850513          	addi	a0,a0,1464 # 80020be0 <itable>
    80003630:	df8fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    80003634:	449c                	lw	a5,8(s1)
    80003636:	37fd                	addiw	a5,a5,-1
    80003638:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000363a:	0001d517          	auipc	a0,0x1d
    8000363e:	5a650513          	addi	a0,a0,1446 # 80020be0 <itable>
    80003642:	e6efd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003646:	0049579b          	srliw	a5,s2,0x4
    8000364a:	0001d597          	auipc	a1,0x1d
    8000364e:	58e5a583          	lw	a1,1422(a1) # 80020bd8 <sb+0x18>
    80003652:	9dbd                	addw	a1,a1,a5
    80003654:	8552                	mv	a0,s4
    80003656:	f3eff0ef          	jal	80002d94 <bread>
    8000365a:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000365c:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    80003660:	079a                	slli	a5,a5,0x6
    80003662:	97aa                	add	a5,a5,a0
    80003664:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    80003668:	1eb000ef          	jal	80004052 <log_write>
  brelse(bp);
    8000366c:	8526                	mv	a0,s1
    8000366e:	82fff0ef          	jal	80002e9c <brelse>
}
    80003672:	6942                	ld	s2,16(sp)
    80003674:	69a2                	ld	s3,8(sp)
    80003676:	6a02                	ld	s4,0(sp)
    80003678:	b79d                	j	800035de <iput+0x30>
    8000367a:	6942                	ld	s2,16(sp)
    8000367c:	6a02                	ld	s4,0(sp)
    8000367e:	bf81                	j	800035ce <iput+0x20>

0000000080003680 <iunlockput>:
{
    80003680:	1101                	addi	sp,sp,-32
    80003682:	ec06                	sd	ra,24(sp)
    80003684:	e822                	sd	s0,16(sp)
    80003686:	e426                	sd	s1,8(sp)
    80003688:	1000                	addi	s0,sp,32
    8000368a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000368c:	e4fff0ef          	jal	800034da <iunlock>
  iput(ip);
    80003690:	8526                	mv	a0,s1
    80003692:	f1dff0ef          	jal	800035ae <iput>
}
    80003696:	60e2                	ld	ra,24(sp)
    80003698:	6442                	ld	s0,16(sp)
    8000369a:	64a2                	ld	s1,8(sp)
    8000369c:	6105                	addi	sp,sp,32
    8000369e:	8082                	ret

00000000800036a0 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036a0:	0001d717          	auipc	a4,0x1d
    800036a4:	52c72703          	lw	a4,1324(a4) # 80020bcc <sb+0xc>
    800036a8:	4785                	li	a5,1
    800036aa:	0ae7fe63          	bgeu	a5,a4,80003766 <ireclaim+0xc6>
{
    800036ae:	7139                	addi	sp,sp,-64
    800036b0:	fc06                	sd	ra,56(sp)
    800036b2:	f822                	sd	s0,48(sp)
    800036b4:	f426                	sd	s1,40(sp)
    800036b6:	f04a                	sd	s2,32(sp)
    800036b8:	ec4e                	sd	s3,24(sp)
    800036ba:	e852                	sd	s4,16(sp)
    800036bc:	e456                	sd	s5,8(sp)
    800036be:	e05a                	sd	s6,0(sp)
    800036c0:	0080                	addi	s0,sp,64
    800036c2:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036c4:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036c6:	0001da17          	auipc	s4,0x1d
    800036ca:	4faa0a13          	addi	s4,s4,1274 # 80020bc0 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    800036ce:	00004b17          	auipc	s6,0x4
    800036d2:	dbab0b13          	addi	s6,s6,-582 # 80007488 <etext+0x488>
    800036d6:	a099                	j	8000371c <ireclaim+0x7c>
    800036d8:	85ce                	mv	a1,s3
    800036da:	855a                	mv	a0,s6
    800036dc:	e2ffc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    800036e0:	85ce                	mv	a1,s3
    800036e2:	8556                	mv	a0,s5
    800036e4:	ad7ff0ef          	jal	800031ba <iget>
    800036e8:	89aa                	mv	s3,a0
    brelse(bp);
    800036ea:	854a                	mv	a0,s2
    800036ec:	fb0ff0ef          	jal	80002e9c <brelse>
    if (ip) {
    800036f0:	00098f63          	beqz	s3,8000370e <ireclaim+0x6e>
      begin_op();
    800036f4:	7b0000ef          	jal	80003ea4 <begin_op>
      ilock(ip);
    800036f8:	854e                	mv	a0,s3
    800036fa:	d33ff0ef          	jal	8000342c <ilock>
      iunlock(ip);
    800036fe:	854e                	mv	a0,s3
    80003700:	ddbff0ef          	jal	800034da <iunlock>
      iput(ip);
    80003704:	854e                	mv	a0,s3
    80003706:	ea9ff0ef          	jal	800035ae <iput>
      end_op();
    8000370a:	027000ef          	jal	80003f30 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000370e:	0485                	addi	s1,s1,1
    80003710:	00ca2703          	lw	a4,12(s4)
    80003714:	0004879b          	sext.w	a5,s1
    80003718:	02e7fd63          	bgeu	a5,a4,80003752 <ireclaim+0xb2>
    8000371c:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003720:	0044d593          	srli	a1,s1,0x4
    80003724:	018a2783          	lw	a5,24(s4)
    80003728:	9dbd                	addw	a1,a1,a5
    8000372a:	8556                	mv	a0,s5
    8000372c:	e68ff0ef          	jal	80002d94 <bread>
    80003730:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003732:	05850793          	addi	a5,a0,88
    80003736:	00f9f713          	andi	a4,s3,15
    8000373a:	071a                	slli	a4,a4,0x6
    8000373c:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    8000373e:	00079703          	lh	a4,0(a5)
    80003742:	c701                	beqz	a4,8000374a <ireclaim+0xaa>
    80003744:	00679783          	lh	a5,6(a5)
    80003748:	dbc1                	beqz	a5,800036d8 <ireclaim+0x38>
    brelse(bp);
    8000374a:	854a                	mv	a0,s2
    8000374c:	f50ff0ef          	jal	80002e9c <brelse>
    if (ip) {
    80003750:	bf7d                	j	8000370e <ireclaim+0x6e>
}
    80003752:	70e2                	ld	ra,56(sp)
    80003754:	7442                	ld	s0,48(sp)
    80003756:	74a2                	ld	s1,40(sp)
    80003758:	7902                	ld	s2,32(sp)
    8000375a:	69e2                	ld	s3,24(sp)
    8000375c:	6a42                	ld	s4,16(sp)
    8000375e:	6aa2                	ld	s5,8(sp)
    80003760:	6b02                	ld	s6,0(sp)
    80003762:	6121                	addi	sp,sp,64
    80003764:	8082                	ret
    80003766:	8082                	ret

0000000080003768 <fsinit>:
{
    80003768:	1101                	addi	sp,sp,-32
    8000376a:	ec06                	sd	ra,24(sp)
    8000376c:	e822                	sd	s0,16(sp)
    8000376e:	e426                	sd	s1,8(sp)
    80003770:	e04a                	sd	s2,0(sp)
    80003772:	1000                	addi	s0,sp,32
    80003774:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003776:	4585                	li	a1,1
    80003778:	e1cff0ef          	jal	80002d94 <bread>
    8000377c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000377e:	02000613          	li	a2,32
    80003782:	05850593          	addi	a1,a0,88
    80003786:	0001d517          	auipc	a0,0x1d
    8000378a:	43a50513          	addi	a0,a0,1082 # 80020bc0 <sb>
    8000378e:	dbafd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    80003792:	8526                	mv	a0,s1
    80003794:	f08ff0ef          	jal	80002e9c <brelse>
  if (sb.magic != FSMAGIC)
    80003798:	0001d717          	auipc	a4,0x1d
    8000379c:	42872703          	lw	a4,1064(a4) # 80020bc0 <sb>
    800037a0:	102037b7          	lui	a5,0x10203
    800037a4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037a8:	02f71263          	bne	a4,a5,800037cc <fsinit+0x64>
  initlog(dev, &sb);
    800037ac:	0001d597          	auipc	a1,0x1d
    800037b0:	41458593          	addi	a1,a1,1044 # 80020bc0 <sb>
    800037b4:	854a                	mv	a0,s2
    800037b6:	66c000ef          	jal	80003e22 <initlog>
  ireclaim(dev);
    800037ba:	854a                	mv	a0,s2
    800037bc:	ee5ff0ef          	jal	800036a0 <ireclaim>
}
    800037c0:	60e2                	ld	ra,24(sp)
    800037c2:	6442                	ld	s0,16(sp)
    800037c4:	64a2                	ld	s1,8(sp)
    800037c6:	6902                	ld	s2,0(sp)
    800037c8:	6105                	addi	sp,sp,32
    800037ca:	8082                	ret
    panic("invalid file system");
    800037cc:	00004517          	auipc	a0,0x4
    800037d0:	cdc50513          	addi	a0,a0,-804 # 800074a8 <etext+0x4a8>
    800037d4:	860fd0ef          	jal	80000834 <panic>

00000000800037d8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800037d8:	1141                	addi	sp,sp,-16
    800037da:	e406                	sd	ra,8(sp)
    800037dc:	e022                	sd	s0,0(sp)
    800037de:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800037e0:	411c                	lw	a5,0(a0)
    800037e2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800037e4:	415c                	lw	a5,4(a0)
    800037e6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800037e8:	04451783          	lh	a5,68(a0)
    800037ec:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800037f0:	04a51783          	lh	a5,74(a0)
    800037f4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800037f8:	04c56783          	lwu	a5,76(a0)
    800037fc:	e99c                	sd	a5,16(a1)
}
    800037fe:	60a2                	ld	ra,8(sp)
    80003800:	6402                	ld	s0,0(sp)
    80003802:	0141                	addi	sp,sp,16
    80003804:	8082                	ret

0000000080003806 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003806:	457c                	lw	a5,76(a0)
    80003808:	0ed7e663          	bltu	a5,a3,800038f4 <readi+0xee>
{
    8000380c:	7159                	addi	sp,sp,-112
    8000380e:	f486                	sd	ra,104(sp)
    80003810:	f0a2                	sd	s0,96(sp)
    80003812:	eca6                	sd	s1,88(sp)
    80003814:	e0d2                	sd	s4,64(sp)
    80003816:	fc56                	sd	s5,56(sp)
    80003818:	f85a                	sd	s6,48(sp)
    8000381a:	f45e                	sd	s7,40(sp)
    8000381c:	1880                	addi	s0,sp,112
    8000381e:	8b2a                	mv	s6,a0
    80003820:	8bae                	mv	s7,a1
    80003822:	8a32                	mv	s4,a2
    80003824:	84b6                	mv	s1,a3
    80003826:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003828:	9f35                	addw	a4,a4,a3
    return 0;
    8000382a:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    8000382c:	0ad76b63          	bltu	a4,a3,800038e2 <readi+0xdc>
    80003830:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003832:	00e7f463          	bgeu	a5,a4,8000383a <readi+0x34>
    n = ip->size - off;
    80003836:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000383a:	080a8b63          	beqz	s5,800038d0 <readi+0xca>
    8000383e:	e8ca                	sd	s2,80(sp)
    80003840:	f062                	sd	s8,32(sp)
    80003842:	ec66                	sd	s9,24(sp)
    80003844:	e86a                	sd	s10,16(sp)
    80003846:	e46e                	sd	s11,8(sp)
    80003848:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000384a:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000384e:	5c7d                	li	s8,-1
    80003850:	a80d                	j	80003882 <readi+0x7c>
    80003852:	020d1d93          	slli	s11,s10,0x20
    80003856:	020ddd93          	srli	s11,s11,0x20
    8000385a:	05890613          	addi	a2,s2,88
    8000385e:	86ee                	mv	a3,s11
    80003860:	963e                	add	a2,a2,a5
    80003862:	85d2                	mv	a1,s4
    80003864:	855e                	mv	a0,s7
    80003866:	c0dfe0ef          	jal	80002472 <either_copyout>
    8000386a:	05850363          	beq	a0,s8,800038b0 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000386e:	854a                	mv	a0,s2
    80003870:	e2cff0ef          	jal	80002e9c <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003874:	013d09bb          	addw	s3,s10,s3
    80003878:	009d04bb          	addw	s1,s10,s1
    8000387c:	9a6e                	add	s4,s4,s11
    8000387e:	0559f363          	bgeu	s3,s5,800038c4 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    80003882:	00a4d59b          	srliw	a1,s1,0xa
    80003886:	855a                	mv	a0,s6
    80003888:	873ff0ef          	jal	800030fa <bmap>
    8000388c:	85aa                	mv	a1,a0
    if (addr == 0)
    8000388e:	c139                	beqz	a0,800038d4 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003890:	000b2503          	lw	a0,0(s6)
    80003894:	d00ff0ef          	jal	80002d94 <bread>
    80003898:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000389a:	3ff4f793          	andi	a5,s1,1023
    8000389e:	40fc873b          	subw	a4,s9,a5
    800038a2:	413a86bb          	subw	a3,s5,s3
    800038a6:	8d3a                	mv	s10,a4
    800038a8:	fae6f5e3          	bgeu	a3,a4,80003852 <readi+0x4c>
    800038ac:	8d36                	mv	s10,a3
    800038ae:	b755                	j	80003852 <readi+0x4c>
      brelse(bp);
    800038b0:	854a                	mv	a0,s2
    800038b2:	deaff0ef          	jal	80002e9c <brelse>
      tot = -1;
    800038b6:	59fd                	li	s3,-1
      break;
    800038b8:	6946                	ld	s2,80(sp)
    800038ba:	7c02                	ld	s8,32(sp)
    800038bc:	6ce2                	ld	s9,24(sp)
    800038be:	6d42                	ld	s10,16(sp)
    800038c0:	6da2                	ld	s11,8(sp)
    800038c2:	a831                	j	800038de <readi+0xd8>
    800038c4:	6946                	ld	s2,80(sp)
    800038c6:	7c02                	ld	s8,32(sp)
    800038c8:	6ce2                	ld	s9,24(sp)
    800038ca:	6d42                	ld	s10,16(sp)
    800038cc:	6da2                	ld	s11,8(sp)
    800038ce:	a801                	j	800038de <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800038d0:	89d6                	mv	s3,s5
    800038d2:	a031                	j	800038de <readi+0xd8>
    800038d4:	6946                	ld	s2,80(sp)
    800038d6:	7c02                	ld	s8,32(sp)
    800038d8:	6ce2                	ld	s9,24(sp)
    800038da:	6d42                	ld	s10,16(sp)
    800038dc:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800038de:	854e                	mv	a0,s3
    800038e0:	69a6                	ld	s3,72(sp)
}
    800038e2:	70a6                	ld	ra,104(sp)
    800038e4:	7406                	ld	s0,96(sp)
    800038e6:	64e6                	ld	s1,88(sp)
    800038e8:	6a06                	ld	s4,64(sp)
    800038ea:	7ae2                	ld	s5,56(sp)
    800038ec:	7b42                	ld	s6,48(sp)
    800038ee:	7ba2                	ld	s7,40(sp)
    800038f0:	6165                	addi	sp,sp,112
    800038f2:	8082                	ret
    return 0;
    800038f4:	4501                	li	a0,0
}
    800038f6:	8082                	ret

00000000800038f8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800038f8:	457c                	lw	a5,76(a0)
    800038fa:	0ed7ee63          	bltu	a5,a3,800039f6 <writei+0xfe>
{
    800038fe:	7159                	addi	sp,sp,-112
    80003900:	f486                	sd	ra,104(sp)
    80003902:	f0a2                	sd	s0,96(sp)
    80003904:	e8ca                	sd	s2,80(sp)
    80003906:	e0d2                	sd	s4,64(sp)
    80003908:	fc56                	sd	s5,56(sp)
    8000390a:	f85a                	sd	s6,48(sp)
    8000390c:	f45e                	sd	s7,40(sp)
    8000390e:	1880                	addi	s0,sp,112
    80003910:	8aaa                	mv	s5,a0
    80003912:	8bae                	mv	s7,a1
    80003914:	8a32                	mv	s4,a2
    80003916:	8936                	mv	s2,a3
    80003918:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    8000391a:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    8000391e:	00043737          	lui	a4,0x43
    80003922:	0cf76c63          	bltu	a4,a5,800039fa <writei+0x102>
    80003926:	0cd7ea63          	bltu	a5,a3,800039fa <writei+0x102>
    8000392a:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000392c:	0a0b0d63          	beqz	s6,800039e6 <writei+0xee>
    80003930:	eca6                	sd	s1,88(sp)
    80003932:	f062                	sd	s8,32(sp)
    80003934:	ec66                	sd	s9,24(sp)
    80003936:	e86a                	sd	s10,16(sp)
    80003938:	e46e                	sd	s11,8(sp)
    8000393a:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000393c:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003940:	5c7d                	li	s8,-1
    80003942:	a825                	j	8000397a <writei+0x82>
    80003944:	020d1d93          	slli	s11,s10,0x20
    80003948:	020ddd93          	srli	s11,s11,0x20
    8000394c:	05848513          	addi	a0,s1,88
    80003950:	86ee                	mv	a3,s11
    80003952:	8652                	mv	a2,s4
    80003954:	85de                	mv	a1,s7
    80003956:	953e                	add	a0,a0,a5
    80003958:	b67fe0ef          	jal	800024be <either_copyin>
    8000395c:	05850663          	beq	a0,s8,800039a8 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003960:	8526                	mv	a0,s1
    80003962:	6f0000ef          	jal	80004052 <log_write>
    brelse(bp);
    80003966:	8526                	mv	a0,s1
    80003968:	d34ff0ef          	jal	80002e9c <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000396c:	013d09bb          	addw	s3,s10,s3
    80003970:	012d093b          	addw	s2,s10,s2
    80003974:	9a6e                	add	s4,s4,s11
    80003976:	0369ff63          	bgeu	s3,s6,800039b4 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    8000397a:	00a9559b          	srliw	a1,s2,0xa
    8000397e:	8556                	mv	a0,s5
    80003980:	f7aff0ef          	jal	800030fa <bmap>
    80003984:	85aa                	mv	a1,a0
    if (addr == 0)
    80003986:	c51d                	beqz	a0,800039b4 <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003988:	000aa503          	lw	a0,0(s5)
    8000398c:	c08ff0ef          	jal	80002d94 <bread>
    80003990:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003992:	3ff97793          	andi	a5,s2,1023
    80003996:	40fc873b          	subw	a4,s9,a5
    8000399a:	413b06bb          	subw	a3,s6,s3
    8000399e:	8d3a                	mv	s10,a4
    800039a0:	fae6f2e3          	bgeu	a3,a4,80003944 <writei+0x4c>
    800039a4:	8d36                	mv	s10,a3
    800039a6:	bf79                	j	80003944 <writei+0x4c>
      log_write(bp);
    800039a8:	8526                	mv	a0,s1
    800039aa:	6a8000ef          	jal	80004052 <log_write>
      brelse(bp);
    800039ae:	8526                	mv	a0,s1
    800039b0:	cecff0ef          	jal	80002e9c <brelse>
  }

  if (off > ip->size)
    800039b4:	04caa783          	lw	a5,76(s5)
    800039b8:	0327f963          	bgeu	a5,s2,800039ea <writei+0xf2>
    ip->size = off;
    800039bc:	052aa623          	sw	s2,76(s5)
    800039c0:	64e6                	ld	s1,88(sp)
    800039c2:	7c02                	ld	s8,32(sp)
    800039c4:	6ce2                	ld	s9,24(sp)
    800039c6:	6d42                	ld	s10,16(sp)
    800039c8:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800039ca:	8556                	mv	a0,s5
    800039cc:	9adff0ef          	jal	80003378 <iupdate>

  return tot;
    800039d0:	854e                	mv	a0,s3
    800039d2:	69a6                	ld	s3,72(sp)
}
    800039d4:	70a6                	ld	ra,104(sp)
    800039d6:	7406                	ld	s0,96(sp)
    800039d8:	6946                	ld	s2,80(sp)
    800039da:	6a06                	ld	s4,64(sp)
    800039dc:	7ae2                	ld	s5,56(sp)
    800039de:	7b42                	ld	s6,48(sp)
    800039e0:	7ba2                	ld	s7,40(sp)
    800039e2:	6165                	addi	sp,sp,112
    800039e4:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800039e6:	89da                	mv	s3,s6
    800039e8:	b7cd                	j	800039ca <writei+0xd2>
    800039ea:	64e6                	ld	s1,88(sp)
    800039ec:	7c02                	ld	s8,32(sp)
    800039ee:	6ce2                	ld	s9,24(sp)
    800039f0:	6d42                	ld	s10,16(sp)
    800039f2:	6da2                	ld	s11,8(sp)
    800039f4:	bfd9                	j	800039ca <writei+0xd2>
    return -1;
    800039f6:	557d                	li	a0,-1
}
    800039f8:	8082                	ret
    return -1;
    800039fa:	557d                	li	a0,-1
    800039fc:	bfe1                	j	800039d4 <writei+0xdc>

00000000800039fe <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800039fe:	1141                	addi	sp,sp,-16
    80003a00:	e406                	sd	ra,8(sp)
    80003a02:	e022                	sd	s0,0(sp)
    80003a04:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a06:	4639                	li	a2,14
    80003a08:	bb4fd0ef          	jal	80000dbc <strncmp>
}
    80003a0c:	60a2                	ld	ra,8(sp)
    80003a0e:	6402                	ld	s0,0(sp)
    80003a10:	0141                	addi	sp,sp,16
    80003a12:	8082                	ret

0000000080003a14 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a14:	711d                	addi	sp,sp,-96
    80003a16:	ec86                	sd	ra,88(sp)
    80003a18:	e8a2                	sd	s0,80(sp)
    80003a1a:	e4a6                	sd	s1,72(sp)
    80003a1c:	e0ca                	sd	s2,64(sp)
    80003a1e:	fc4e                	sd	s3,56(sp)
    80003a20:	f852                	sd	s4,48(sp)
    80003a22:	f456                	sd	s5,40(sp)
    80003a24:	f05a                	sd	s6,32(sp)
    80003a26:	ec5e                	sd	s7,24(sp)
    80003a28:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003a2a:	04451703          	lh	a4,68(a0)
    80003a2e:	4785                	li	a5,1
    80003a30:	00f71f63          	bne	a4,a5,80003a4e <dirlookup+0x3a>
    80003a34:	892a                	mv	s2,a0
    80003a36:	8aae                	mv	s5,a1
    80003a38:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a3a:	457c                	lw	a5,76(a0)
    80003a3c:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a3e:	fa040a13          	addi	s4,s0,-96
    80003a42:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003a44:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a48:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a4a:	e39d                	bnez	a5,80003a70 <dirlookup+0x5c>
    80003a4c:	a8b9                	j	80003aaa <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003a4e:	00004517          	auipc	a0,0x4
    80003a52:	a7250513          	addi	a0,a0,-1422 # 800074c0 <etext+0x4c0>
    80003a56:	ddffc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    80003a5a:	00004517          	auipc	a0,0x4
    80003a5e:	a7e50513          	addi	a0,a0,-1410 # 800074d8 <etext+0x4d8>
    80003a62:	dd3fc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a66:	24c1                	addiw	s1,s1,16
    80003a68:	04c92783          	lw	a5,76(s2)
    80003a6c:	02f4fe63          	bgeu	s1,a5,80003aa8 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a70:	874e                	mv	a4,s3
    80003a72:	86a6                	mv	a3,s1
    80003a74:	8652                	mv	a2,s4
    80003a76:	4581                	li	a1,0
    80003a78:	854a                	mv	a0,s2
    80003a7a:	d8dff0ef          	jal	80003806 <readi>
    80003a7e:	fd351ee3          	bne	a0,s3,80003a5a <dirlookup+0x46>
    if (de.inum == 0)
    80003a82:	fa045783          	lhu	a5,-96(s0)
    80003a86:	d3e5                	beqz	a5,80003a66 <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003a88:	85da                	mv	a1,s6
    80003a8a:	8556                	mv	a0,s5
    80003a8c:	f73ff0ef          	jal	800039fe <namecmp>
    80003a90:	f979                	bnez	a0,80003a66 <dirlookup+0x52>
      if (poff)
    80003a92:	000b8463          	beqz	s7,80003a9a <dirlookup+0x86>
        *poff = off;
    80003a96:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003a9a:	fa045583          	lhu	a1,-96(s0)
    80003a9e:	00092503          	lw	a0,0(s2)
    80003aa2:	f18ff0ef          	jal	800031ba <iget>
    80003aa6:	a011                	j	80003aaa <dirlookup+0x96>
  return 0;
    80003aa8:	4501                	li	a0,0
}
    80003aaa:	60e6                	ld	ra,88(sp)
    80003aac:	6446                	ld	s0,80(sp)
    80003aae:	64a6                	ld	s1,72(sp)
    80003ab0:	6906                	ld	s2,64(sp)
    80003ab2:	79e2                	ld	s3,56(sp)
    80003ab4:	7a42                	ld	s4,48(sp)
    80003ab6:	7aa2                	ld	s5,40(sp)
    80003ab8:	7b02                	ld	s6,32(sp)
    80003aba:	6be2                	ld	s7,24(sp)
    80003abc:	6125                	addi	sp,sp,96
    80003abe:	8082                	ret

0000000080003ac0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003ac0:	711d                	addi	sp,sp,-96
    80003ac2:	ec86                	sd	ra,88(sp)
    80003ac4:	e8a2                	sd	s0,80(sp)
    80003ac6:	e4a6                	sd	s1,72(sp)
    80003ac8:	e0ca                	sd	s2,64(sp)
    80003aca:	fc4e                	sd	s3,56(sp)
    80003acc:	f852                	sd	s4,48(sp)
    80003ace:	f456                	sd	s5,40(sp)
    80003ad0:	f05a                	sd	s6,32(sp)
    80003ad2:	ec5e                	sd	s7,24(sp)
    80003ad4:	e862                	sd	s8,16(sp)
    80003ad6:	e466                	sd	s9,8(sp)
    80003ad8:	e06a                	sd	s10,0(sp)
    80003ada:	1080                	addi	s0,sp,96
    80003adc:	84aa                	mv	s1,a0
    80003ade:	8b2e                	mv	s6,a1
    80003ae0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003ae2:	00054703          	lbu	a4,0(a0)
    80003ae6:	02f00793          	li	a5,47
    80003aea:	00f70f63          	beq	a4,a5,80003b08 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003aee:	e5bfd0ef          	jal	80001948 <myproc>
    80003af2:	15053503          	ld	a0,336(a0)
    80003af6:	901ff0ef          	jal	800033f6 <idup>
    80003afa:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003afc:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003b00:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003b02:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003b04:	4b85                	li	s7,1
    80003b06:	a07d                	j	80003bb4 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003b08:	4585                	li	a1,1
    80003b0a:	852e                	mv	a0,a1
    80003b0c:	eaeff0ef          	jal	800031ba <iget>
    80003b10:	8a2a                	mv	s4,a0
    80003b12:	b7ed                	j	80003afc <namex+0x3c>
      iunlockput(ip);
    80003b14:	8552                	mv	a0,s4
    80003b16:	b6bff0ef          	jal	80003680 <iunlockput>
      return 0;
    80003b1a:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003b1c:	8552                	mv	a0,s4
    80003b1e:	60e6                	ld	ra,88(sp)
    80003b20:	6446                	ld	s0,80(sp)
    80003b22:	64a6                	ld	s1,72(sp)
    80003b24:	6906                	ld	s2,64(sp)
    80003b26:	79e2                	ld	s3,56(sp)
    80003b28:	7a42                	ld	s4,48(sp)
    80003b2a:	7aa2                	ld	s5,40(sp)
    80003b2c:	7b02                	ld	s6,32(sp)
    80003b2e:	6be2                	ld	s7,24(sp)
    80003b30:	6c42                	ld	s8,16(sp)
    80003b32:	6ca2                	ld	s9,8(sp)
    80003b34:	6d02                	ld	s10,0(sp)
    80003b36:	6125                	addi	sp,sp,96
    80003b38:	8082                	ret
      iunlockput(ip);
    80003b3a:	8552                	mv	a0,s4
    80003b3c:	b45ff0ef          	jal	80003680 <iunlockput>
      return 0;
    80003b40:	4a01                	li	s4,0
    80003b42:	bfe9                	j	80003b1c <namex+0x5c>
      iunlock(ip);
    80003b44:	8552                	mv	a0,s4
    80003b46:	995ff0ef          	jal	800034da <iunlock>
      return ip;
    80003b4a:	bfc9                	j	80003b1c <namex+0x5c>
      iunlockput(ip);
    80003b4c:	8552                	mv	a0,s4
    80003b4e:	b33ff0ef          	jal	80003680 <iunlockput>
      return 0;
    80003b52:	8a4a                	mv	s4,s2
    80003b54:	b7e1                	j	80003b1c <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003b56:	8926                	mv	s2,s1
  len = path - s;
    80003b58:	4d01                	li	s10,0
    80003b5a:	4601                	li	a2,0
    memmove(name, s, len);
    80003b5c:	2601                	sext.w	a2,a2
    80003b5e:	85a6                	mv	a1,s1
    80003b60:	8556                	mv	a0,s5
    80003b62:	9e6fd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003b66:	9d56                	add	s10,s10,s5
    80003b68:	000d0023          	sb	zero,0(s10)
  while (*path == '/')
    80003b6c:	00094783          	lbu	a5,0(s2)
    80003b70:	09379b63          	bne	a5,s3,80003c06 <namex+0x146>
    80003b74:	84ca                	mv	s1,s2
    path++;
    80003b76:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b78:	0004c783          	lbu	a5,0(s1)
    80003b7c:	ff378de3          	beq	a5,s3,80003b76 <namex+0xb6>
    ilock(ip);
    80003b80:	8552                	mv	a0,s4
    80003b82:	8abff0ef          	jal	8000342c <ilock>
    if (ip->type != T_DIR) {
    80003b86:	044a1783          	lh	a5,68(s4)
    80003b8a:	f97795e3          	bne	a5,s7,80003b14 <namex+0x54>
    if (ip->nlink == 0) {
    80003b8e:	04aa1783          	lh	a5,74(s4)
    80003b92:	d7c5                	beqz	a5,80003b3a <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003b94:	000b0563          	beqz	s6,80003b9e <namex+0xde>
    80003b98:	0004c783          	lbu	a5,0(s1)
    80003b9c:	d7c5                	beqz	a5,80003b44 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003b9e:	4601                	li	a2,0
    80003ba0:	85d6                	mv	a1,s5
    80003ba2:	8552                	mv	a0,s4
    80003ba4:	e71ff0ef          	jal	80003a14 <dirlookup>
    80003ba8:	892a                	mv	s2,a0
    80003baa:	d14d                	beqz	a0,80003b4c <namex+0x8c>
    iunlockput(ip);
    80003bac:	8552                	mv	a0,s4
    80003bae:	ad3ff0ef          	jal	80003680 <iunlockput>
    ip = next;
    80003bb2:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003bb4:	0004c783          	lbu	a5,0(s1)
    80003bb8:	01379763          	bne	a5,s3,80003bc6 <namex+0x106>
    path++;
    80003bbc:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003bbe:	0004c783          	lbu	a5,0(s1)
    80003bc2:	ff378de3          	beq	a5,s3,80003bbc <namex+0xfc>
  if (*path == 0)
    80003bc6:	c7a1                	beqz	a5,80003c0e <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003bc8:	0004c783          	lbu	a5,0(s1)
    80003bcc:	fd178713          	addi	a4,a5,-47
    80003bd0:	d359                	beqz	a4,80003b56 <namex+0x96>
    80003bd2:	d3d1                	beqz	a5,80003b56 <namex+0x96>
    80003bd4:	8926                	mv	s2,s1
    path++;
    80003bd6:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003bd8:	00094783          	lbu	a5,0(s2)
    80003bdc:	fd178713          	addi	a4,a5,-47
    80003be0:	c311                	beqz	a4,80003be4 <namex+0x124>
    80003be2:	fbf5                	bnez	a5,80003bd6 <namex+0x116>
  len = path - s;
    80003be4:	40990633          	sub	a2,s2,s1
    80003be8:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003bec:	f7ac58e3          	bge	s8,s10,80003b5c <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003bf0:	8666                	mv	a2,s9
    80003bf2:	85a6                	mv	a1,s1
    80003bf4:	8556                	mv	a0,s5
    80003bf6:	952fd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003bfa:	00094783          	lbu	a5,0(s2)
    80003bfe:	84ca                	mv	s1,s2
    80003c00:	f7378be3          	beq	a5,s3,80003b76 <namex+0xb6>
    80003c04:	bfb5                	j	80003b80 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003c06:	00090463          	beqz	s2,80003c0e <namex+0x14e>
    80003c0a:	84ca                	mv	s1,s2
    80003c0c:	bf95                	j	80003b80 <namex+0xc0>
  if (nameiparent) {
    80003c0e:	f00b07e3          	beqz	s6,80003b1c <namex+0x5c>
    iput(ip);
    80003c12:	8552                	mv	a0,s4
    80003c14:	99bff0ef          	jal	800035ae <iput>
    return 0;
    80003c18:	4a01                	li	s4,0
    80003c1a:	b709                	j	80003b1c <namex+0x5c>

0000000080003c1c <dirlink>:
{
    80003c1c:	715d                	addi	sp,sp,-80
    80003c1e:	e486                	sd	ra,72(sp)
    80003c20:	e0a2                	sd	s0,64(sp)
    80003c22:	f84a                	sd	s2,48(sp)
    80003c24:	ec56                	sd	s5,24(sp)
    80003c26:	e85a                	sd	s6,16(sp)
    80003c28:	0880                	addi	s0,sp,80
    80003c2a:	892a                	mv	s2,a0
    80003c2c:	8aae                	mv	s5,a1
    80003c2e:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003c30:	4601                	li	a2,0
    80003c32:	de3ff0ef          	jal	80003a14 <dirlookup>
    80003c36:	ed1d                	bnez	a0,80003c74 <dirlink+0x58>
    80003c38:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003c3a:	04c92483          	lw	s1,76(s2)
    80003c3e:	c4b9                	beqz	s1,80003c8c <dirlink+0x70>
    80003c40:	f44e                	sd	s3,40(sp)
    80003c42:	f052                	sd	s4,32(sp)
    80003c44:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c46:	fb040a13          	addi	s4,s0,-80
    80003c4a:	49c1                	li	s3,16
    80003c4c:	874e                	mv	a4,s3
    80003c4e:	86a6                	mv	a3,s1
    80003c50:	8652                	mv	a2,s4
    80003c52:	4581                	li	a1,0
    80003c54:	854a                	mv	a0,s2
    80003c56:	bb1ff0ef          	jal	80003806 <readi>
    80003c5a:	03351163          	bne	a0,s3,80003c7c <dirlink+0x60>
    if (de.inum == 0)
    80003c5e:	fb045783          	lhu	a5,-80(s0)
    80003c62:	c39d                	beqz	a5,80003c88 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003c64:	24c1                	addiw	s1,s1,16
    80003c66:	04c92783          	lw	a5,76(s2)
    80003c6a:	fef4e1e3          	bltu	s1,a5,80003c4c <dirlink+0x30>
    80003c6e:	79a2                	ld	s3,40(sp)
    80003c70:	7a02                	ld	s4,32(sp)
    80003c72:	a829                	j	80003c8c <dirlink+0x70>
    iput(ip);
    80003c74:	93bff0ef          	jal	800035ae <iput>
    return -1;
    80003c78:	557d                	li	a0,-1
    80003c7a:	a83d                	j	80003cb8 <dirlink+0x9c>
      panic("dirlink read");
    80003c7c:	00004517          	auipc	a0,0x4
    80003c80:	86c50513          	addi	a0,a0,-1940 # 800074e8 <etext+0x4e8>
    80003c84:	bb1fc0ef          	jal	80000834 <panic>
    80003c88:	79a2                	ld	s3,40(sp)
    80003c8a:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003c8c:	4639                	li	a2,14
    80003c8e:	85d6                	mv	a1,s5
    80003c90:	fb240513          	addi	a0,s0,-78
    80003c94:	962fd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003c98:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c9c:	4741                	li	a4,16
    80003c9e:	86a6                	mv	a3,s1
    80003ca0:	fb040613          	addi	a2,s0,-80
    80003ca4:	4581                	li	a1,0
    80003ca6:	854a                	mv	a0,s2
    80003ca8:	c51ff0ef          	jal	800038f8 <writei>
    80003cac:	1541                	addi	a0,a0,-16
    80003cae:	00a03533          	snez	a0,a0
    80003cb2:	40a0053b          	negw	a0,a0
    80003cb6:	74e2                	ld	s1,56(sp)
}
    80003cb8:	60a6                	ld	ra,72(sp)
    80003cba:	6406                	ld	s0,64(sp)
    80003cbc:	7942                	ld	s2,48(sp)
    80003cbe:	6ae2                	ld	s5,24(sp)
    80003cc0:	6b42                	ld	s6,16(sp)
    80003cc2:	6161                	addi	sp,sp,80
    80003cc4:	8082                	ret

0000000080003cc6 <namei>:

struct inode *
namei(char *path)
{
    80003cc6:	1101                	addi	sp,sp,-32
    80003cc8:	ec06                	sd	ra,24(sp)
    80003cca:	e822                	sd	s0,16(sp)
    80003ccc:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003cce:	fe040613          	addi	a2,s0,-32
    80003cd2:	4581                	li	a1,0
    80003cd4:	dedff0ef          	jal	80003ac0 <namex>
}
    80003cd8:	60e2                	ld	ra,24(sp)
    80003cda:	6442                	ld	s0,16(sp)
    80003cdc:	6105                	addi	sp,sp,32
    80003cde:	8082                	ret

0000000080003ce0 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003ce0:	1141                	addi	sp,sp,-16
    80003ce2:	e406                	sd	ra,8(sp)
    80003ce4:	e022                	sd	s0,0(sp)
    80003ce6:	0800                	addi	s0,sp,16
    80003ce8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003cea:	4585                	li	a1,1
    80003cec:	dd5ff0ef          	jal	80003ac0 <namex>
}
    80003cf0:	60a2                	ld	ra,8(sp)
    80003cf2:	6402                	ld	s0,0(sp)
    80003cf4:	0141                	addi	sp,sp,16
    80003cf6:	8082                	ret

0000000080003cf8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003cf8:	1101                	addi	sp,sp,-32
    80003cfa:	ec06                	sd	ra,24(sp)
    80003cfc:	e822                	sd	s0,16(sp)
    80003cfe:	e426                	sd	s1,8(sp)
    80003d00:	e04a                	sd	s2,0(sp)
    80003d02:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003d04:	0001f917          	auipc	s2,0x1f
    80003d08:	98490913          	addi	s2,s2,-1660 # 80022688 <log>
    80003d0c:	01892583          	lw	a1,24(s2)
    80003d10:	02492503          	lw	a0,36(s2)
    80003d14:	880ff0ef          	jal	80002d94 <bread>
    80003d18:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003d1a:	02c92603          	lw	a2,44(s2)
    80003d1e:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003d20:	00c05f63          	blez	a2,80003d3e <write_head+0x46>
    80003d24:	0001f717          	auipc	a4,0x1f
    80003d28:	99470713          	addi	a4,a4,-1644 # 800226b8 <log+0x30>
    80003d2c:	87aa                	mv	a5,a0
    80003d2e:	060a                	slli	a2,a2,0x2
    80003d30:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003d32:	4314                	lw	a3,0(a4)
    80003d34:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003d36:	0711                	addi	a4,a4,4
    80003d38:	0791                	addi	a5,a5,4
    80003d3a:	fec79ce3          	bne	a5,a2,80003d32 <write_head+0x3a>
  }
  bwrite(buf);
    80003d3e:	8526                	mv	a0,s1
    80003d40:	92aff0ef          	jal	80002e6a <bwrite>
  brelse(buf);
    80003d44:	8526                	mv	a0,s1
    80003d46:	956ff0ef          	jal	80002e9c <brelse>
}
    80003d4a:	60e2                	ld	ra,24(sp)
    80003d4c:	6442                	ld	s0,16(sp)
    80003d4e:	64a2                	ld	s1,8(sp)
    80003d50:	6902                	ld	s2,0(sp)
    80003d52:	6105                	addi	sp,sp,32
    80003d54:	8082                	ret

0000000080003d56 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d56:	0001f797          	auipc	a5,0x1f
    80003d5a:	95e7a783          	lw	a5,-1698(a5) # 800226b4 <log+0x2c>
    80003d5e:	0cf05163          	blez	a5,80003e20 <install_trans+0xca>
{
    80003d62:	715d                	addi	sp,sp,-80
    80003d64:	e486                	sd	ra,72(sp)
    80003d66:	e0a2                	sd	s0,64(sp)
    80003d68:	fc26                	sd	s1,56(sp)
    80003d6a:	f84a                	sd	s2,48(sp)
    80003d6c:	f44e                	sd	s3,40(sp)
    80003d6e:	f052                	sd	s4,32(sp)
    80003d70:	ec56                	sd	s5,24(sp)
    80003d72:	e85a                	sd	s6,16(sp)
    80003d74:	e45e                	sd	s7,8(sp)
    80003d76:	e062                	sd	s8,0(sp)
    80003d78:	0880                	addi	s0,sp,80
    80003d7a:	8b2a                	mv	s6,a0
    80003d7c:	0001fa97          	auipc	s5,0x1f
    80003d80:	93ca8a93          	addi	s5,s5,-1732 # 800226b8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d84:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d86:	00003c17          	auipc	s8,0x3
    80003d8a:	772c0c13          	addi	s8,s8,1906 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003d8e:	0001fa17          	auipc	s4,0x1f
    80003d92:	8faa0a13          	addi	s4,s4,-1798 # 80022688 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003d96:	40000b93          	li	s7,1024
    80003d9a:	a025                	j	80003dc2 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d9c:	000aa603          	lw	a2,0(s5)
    80003da0:	85ce                	mv	a1,s3
    80003da2:	8562                	mv	a0,s8
    80003da4:	f66fc0ef          	jal	8000050a <printk>
    80003da8:	a839                	j	80003dc6 <install_trans+0x70>
    brelse(lbuf);
    80003daa:	854a                	mv	a0,s2
    80003dac:	8f0ff0ef          	jal	80002e9c <brelse>
    brelse(dbuf);
    80003db0:	8526                	mv	a0,s1
    80003db2:	8eaff0ef          	jal	80002e9c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003db6:	2985                	addiw	s3,s3,1
    80003db8:	0a91                	addi	s5,s5,4
    80003dba:	02ca2783          	lw	a5,44(s4)
    80003dbe:	04f9d563          	bge	s3,a5,80003e08 <install_trans+0xb2>
    if (recovering) {
    80003dc2:	fc0b1de3          	bnez	s6,80003d9c <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003dc6:	018a2583          	lw	a1,24(s4)
    80003dca:	013585bb          	addw	a1,a1,s3
    80003dce:	2585                	addiw	a1,a1,1
    80003dd0:	024a2503          	lw	a0,36(s4)
    80003dd4:	fc1fe0ef          	jal	80002d94 <bread>
    80003dd8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003dda:	000aa583          	lw	a1,0(s5)
    80003dde:	024a2503          	lw	a0,36(s4)
    80003de2:	fb3fe0ef          	jal	80002d94 <bread>
    80003de6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003de8:	865e                	mv	a2,s7
    80003dea:	05890593          	addi	a1,s2,88
    80003dee:	05850513          	addi	a0,a0,88
    80003df2:	f57fc0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003df6:	8526                	mv	a0,s1
    80003df8:	872ff0ef          	jal	80002e6a <bwrite>
    if (recovering == 0)
    80003dfc:	fa0b17e3          	bnez	s6,80003daa <install_trans+0x54>
      bunpin(dbuf);
    80003e00:	8526                	mv	a0,s1
    80003e02:	952ff0ef          	jal	80002f54 <bunpin>
    80003e06:	b755                	j	80003daa <install_trans+0x54>
}
    80003e08:	60a6                	ld	ra,72(sp)
    80003e0a:	6406                	ld	s0,64(sp)
    80003e0c:	74e2                	ld	s1,56(sp)
    80003e0e:	7942                	ld	s2,48(sp)
    80003e10:	79a2                	ld	s3,40(sp)
    80003e12:	7a02                	ld	s4,32(sp)
    80003e14:	6ae2                	ld	s5,24(sp)
    80003e16:	6b42                	ld	s6,16(sp)
    80003e18:	6ba2                	ld	s7,8(sp)
    80003e1a:	6c02                	ld	s8,0(sp)
    80003e1c:	6161                	addi	sp,sp,80
    80003e1e:	8082                	ret
    80003e20:	8082                	ret

0000000080003e22 <initlog>:
{
    80003e22:	7179                	addi	sp,sp,-48
    80003e24:	f406                	sd	ra,40(sp)
    80003e26:	f022                	sd	s0,32(sp)
    80003e28:	ec26                	sd	s1,24(sp)
    80003e2a:	e84a                	sd	s2,16(sp)
    80003e2c:	e44e                	sd	s3,8(sp)
    80003e2e:	1800                	addi	s0,sp,48
    80003e30:	84aa                	mv	s1,a0
    80003e32:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003e34:	0001f917          	auipc	s2,0x1f
    80003e38:	85490913          	addi	s2,s2,-1964 # 80022688 <log>
    80003e3c:	00003597          	auipc	a1,0x3
    80003e40:	6dc58593          	addi	a1,a1,1756 # 80007518 <etext+0x518>
    80003e44:	854a                	mv	a0,s2
    80003e46:	d63fc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003e4a:	0149a583          	lw	a1,20(s3)
    80003e4e:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003e52:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003e56:	8526                	mv	a0,s1
    80003e58:	f3dfe0ef          	jal	80002d94 <bread>
  log.lh.n = lh->n;
    80003e5c:	4d30                	lw	a2,88(a0)
    80003e5e:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003e62:	00c05f63          	blez	a2,80003e80 <initlog+0x5e>
    80003e66:	87aa                	mv	a5,a0
    80003e68:	0001f717          	auipc	a4,0x1f
    80003e6c:	85070713          	addi	a4,a4,-1968 # 800226b8 <log+0x30>
    80003e70:	060a                	slli	a2,a2,0x2
    80003e72:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e74:	4ff4                	lw	a3,92(a5)
    80003e76:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e78:	0791                	addi	a5,a5,4
    80003e7a:	0711                	addi	a4,a4,4
    80003e7c:	fec79ce3          	bne	a5,a2,80003e74 <initlog+0x52>
  brelse(buf);
    80003e80:	81cff0ef          	jal	80002e9c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e84:	4505                	li	a0,1
    80003e86:	ed1ff0ef          	jal	80003d56 <install_trans>
  log.lh.n = 0;
    80003e8a:	0001f797          	auipc	a5,0x1f
    80003e8e:	8207a523          	sw	zero,-2006(a5) # 800226b4 <log+0x2c>
  write_head(); // clear the log
    80003e92:	e67ff0ef          	jal	80003cf8 <write_head>
}
    80003e96:	70a2                	ld	ra,40(sp)
    80003e98:	7402                	ld	s0,32(sp)
    80003e9a:	64e2                	ld	s1,24(sp)
    80003e9c:	6942                	ld	s2,16(sp)
    80003e9e:	69a2                	ld	s3,8(sp)
    80003ea0:	6145                	addi	sp,sp,48
    80003ea2:	8082                	ret

0000000080003ea4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ea4:	1101                	addi	sp,sp,-32
    80003ea6:	ec06                	sd	ra,24(sp)
    80003ea8:	e822                	sd	s0,16(sp)
    80003eaa:	e426                	sd	s1,8(sp)
    80003eac:	e04a                	sd	s2,0(sp)
    80003eae:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003eb0:	0001e517          	auipc	a0,0x1e
    80003eb4:	7d850513          	addi	a0,a0,2008 # 80022688 <log>
    80003eb8:	d71fc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80003ebc:	0001e497          	auipc	s1,0x1e
    80003ec0:	7cc48493          	addi	s1,s1,1996 # 80022688 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003ec4:	4979                	li	s2,30
    80003ec6:	a821                	j	80003ede <begin_op+0x3a>
      sleep_prepare(&log);
    80003ec8:	8526                	mv	a0,s1
    80003eca:	a16fe0ef          	jal	800020e0 <sleep_prepare>
      release(&log.lock);
    80003ece:	8526                	mv	a0,s1
    80003ed0:	de1fc0ef          	jal	80000cb0 <release>
      sleep();
    80003ed4:	a48fe0ef          	jal	8000211c <sleep>
      acquire(&log.lock);
    80003ed8:	8526                	mv	a0,s1
    80003eda:	d4ffc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80003ede:	509c                	lw	a5,32(s1)
    80003ee0:	f7e5                	bnez	a5,80003ec8 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003ee2:	4cd8                	lw	a4,28(s1)
    80003ee4:	2705                	addiw	a4,a4,1
    80003ee6:	0027179b          	slliw	a5,a4,0x2
    80003eea:	9fb9                	addw	a5,a5,a4
    80003eec:	0017979b          	slliw	a5,a5,0x1
    80003ef0:	54d4                	lw	a3,44(s1)
    80003ef2:	9fb5                	addw	a5,a5,a3
    80003ef4:	00f95e63          	bge	s2,a5,80003f10 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003ef8:	8526                	mv	a0,s1
    80003efa:	9e6fe0ef          	jal	800020e0 <sleep_prepare>
      release(&log.lock);
    80003efe:	8526                	mv	a0,s1
    80003f00:	db1fc0ef          	jal	80000cb0 <release>
      sleep();
    80003f04:	a18fe0ef          	jal	8000211c <sleep>
      acquire(&log.lock);
    80003f08:	8526                	mv	a0,s1
    80003f0a:	d1ffc0ef          	jal	80000c28 <acquire>
    80003f0e:	bfc1                	j	80003ede <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003f10:	0001e797          	auipc	a5,0x1e
    80003f14:	78e7aa23          	sw	a4,1940(a5) # 800226a4 <log+0x1c>
      release(&log.lock);
    80003f18:	0001e517          	auipc	a0,0x1e
    80003f1c:	77050513          	addi	a0,a0,1904 # 80022688 <log>
    80003f20:	d91fc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80003f24:	60e2                	ld	ra,24(sp)
    80003f26:	6442                	ld	s0,16(sp)
    80003f28:	64a2                	ld	s1,8(sp)
    80003f2a:	6902                	ld	s2,0(sp)
    80003f2c:	6105                	addi	sp,sp,32
    80003f2e:	8082                	ret

0000000080003f30 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003f30:	7139                	addi	sp,sp,-64
    80003f32:	fc06                	sd	ra,56(sp)
    80003f34:	f822                	sd	s0,48(sp)
    80003f36:	f426                	sd	s1,40(sp)
    80003f38:	f04a                	sd	s2,32(sp)
    80003f3a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003f3c:	0001e497          	auipc	s1,0x1e
    80003f40:	74c48493          	addi	s1,s1,1868 # 80022688 <log>
    80003f44:	8526                	mv	a0,s1
    80003f46:	ce3fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003f4a:	4cdc                	lw	a5,28(s1)
    80003f4c:	37fd                	addiw	a5,a5,-1
    80003f4e:	893e                	mv	s2,a5
    80003f50:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003f52:	509c                	lw	a5,32(s1)
    80003f54:	e3b1                	bnez	a5,80003f98 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003f56:	04091a63          	bnez	s2,80003faa <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003f5a:	0001e497          	auipc	s1,0x1e
    80003f5e:	72e48493          	addi	s1,s1,1838 # 80022688 <log>
    80003f62:	4785                	li	a5,1
    80003f64:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f66:	8526                	mv	a0,s1
    80003f68:	d49fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f6c:	54dc                	lw	a5,44(s1)
    80003f6e:	06f04063          	bgtz	a5,80003fce <end_op+0x9e>
    acquire(&log.lock);
    80003f72:	0001e497          	auipc	s1,0x1e
    80003f76:	71648493          	addi	s1,s1,1814 # 80022688 <log>
    80003f7a:	8526                	mv	a0,s1
    80003f7c:	cadfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003f80:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003f84:	549c                	lw	a5,40(s1)
    80003f86:	2785                	addiw	a5,a5,1
    80003f88:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003f8a:	8526                	mv	a0,s1
    80003f8c:	9c0fe0ef          	jal	8000214c <wakeup>
    release(&log.lock);
    80003f90:	8526                	mv	a0,s1
    80003f92:	d1ffc0ef          	jal	80000cb0 <release>
}
    80003f96:	a035                	j	80003fc2 <end_op+0x92>
    80003f98:	ec4e                	sd	s3,24(sp)
    80003f9a:	e852                	sd	s4,16(sp)
    80003f9c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003f9e:	00003517          	auipc	a0,0x3
    80003fa2:	58250513          	addi	a0,a0,1410 # 80007520 <etext+0x520>
    80003fa6:	88ffc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003faa:	0001e517          	auipc	a0,0x1e
    80003fae:	6de50513          	addi	a0,a0,1758 # 80022688 <log>
    80003fb2:	99afe0ef          	jal	8000214c <wakeup>
  release(&log.lock);
    80003fb6:	0001e517          	auipc	a0,0x1e
    80003fba:	6d250513          	addi	a0,a0,1746 # 80022688 <log>
    80003fbe:	cf3fc0ef          	jal	80000cb0 <release>
}
    80003fc2:	70e2                	ld	ra,56(sp)
    80003fc4:	7442                	ld	s0,48(sp)
    80003fc6:	74a2                	ld	s1,40(sp)
    80003fc8:	7902                	ld	s2,32(sp)
    80003fca:	6121                	addi	sp,sp,64
    80003fcc:	8082                	ret
    80003fce:	ec4e                	sd	s3,24(sp)
    80003fd0:	e852                	sd	s4,16(sp)
    80003fd2:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fd4:	0001ea97          	auipc	s5,0x1e
    80003fd8:	6e4a8a93          	addi	s5,s5,1764 # 800226b8 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003fdc:	0001ea17          	auipc	s4,0x1e
    80003fe0:	6aca0a13          	addi	s4,s4,1708 # 80022688 <log>
    80003fe4:	018a2583          	lw	a1,24(s4)
    80003fe8:	012585bb          	addw	a1,a1,s2
    80003fec:	2585                	addiw	a1,a1,1
    80003fee:	024a2503          	lw	a0,36(s4)
    80003ff2:	da3fe0ef          	jal	80002d94 <bread>
    80003ff6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003ff8:	000aa583          	lw	a1,0(s5)
    80003ffc:	024a2503          	lw	a0,36(s4)
    80004000:	d95fe0ef          	jal	80002d94 <bread>
    80004004:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004006:	40000613          	li	a2,1024
    8000400a:	05850593          	addi	a1,a0,88
    8000400e:	05848513          	addi	a0,s1,88
    80004012:	d37fc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    80004016:	8526                	mv	a0,s1
    80004018:	e53fe0ef          	jal	80002e6a <bwrite>
    brelse(from);
    8000401c:	854e                	mv	a0,s3
    8000401e:	e7ffe0ef          	jal	80002e9c <brelse>
    brelse(to);
    80004022:	8526                	mv	a0,s1
    80004024:	e79fe0ef          	jal	80002e9c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004028:	2905                	addiw	s2,s2,1
    8000402a:	0a91                	addi	s5,s5,4
    8000402c:	02ca2783          	lw	a5,44(s4)
    80004030:	faf94ae3          	blt	s2,a5,80003fe4 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80004034:	cc5ff0ef          	jal	80003cf8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004038:	4501                	li	a0,0
    8000403a:	d1dff0ef          	jal	80003d56 <install_trans>
    log.lh.n = 0;
    8000403e:	0001e797          	auipc	a5,0x1e
    80004042:	6607ab23          	sw	zero,1654(a5) # 800226b4 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80004046:	cb3ff0ef          	jal	80003cf8 <write_head>
    8000404a:	69e2                	ld	s3,24(sp)
    8000404c:	6a42                	ld	s4,16(sp)
    8000404e:	6aa2                	ld	s5,8(sp)
    80004050:	b70d                	j	80003f72 <end_op+0x42>

0000000080004052 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004052:	1101                	addi	sp,sp,-32
    80004054:	ec06                	sd	ra,24(sp)
    80004056:	e822                	sd	s0,16(sp)
    80004058:	e426                	sd	s1,8(sp)
    8000405a:	1000                	addi	s0,sp,32
    8000405c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000405e:	0001e517          	auipc	a0,0x1e
    80004062:	62a50513          	addi	a0,a0,1578 # 80022688 <log>
    80004066:	bc3fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000406a:	0001e617          	auipc	a2,0x1e
    8000406e:	64a62603          	lw	a2,1610(a2) # 800226b4 <log+0x2c>
    80004072:	47f5                	li	a5,29
    80004074:	04c7cd63          	blt	a5,a2,800040ce <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004078:	0001e797          	auipc	a5,0x1e
    8000407c:	62c7a783          	lw	a5,1580(a5) # 800226a4 <log+0x1c>
    80004080:	04f05d63          	blez	a5,800040da <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004084:	4781                	li	a5,0
    80004086:	06c05063          	blez	a2,800040e6 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    8000408a:	44cc                	lw	a1,12(s1)
    8000408c:	0001e717          	auipc	a4,0x1e
    80004090:	62c70713          	addi	a4,a4,1580 # 800226b8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004094:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80004096:	4314                	lw	a3,0(a4)
    80004098:	04b68763          	beq	a3,a1,800040e6 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    8000409c:	2785                	addiw	a5,a5,1
    8000409e:	0711                	addi	a4,a4,4
    800040a0:	fef61be3          	bne	a2,a5,80004096 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800040a4:	060a                	slli	a2,a2,0x2
    800040a6:	02060613          	addi	a2,a2,32
    800040aa:	0001e797          	auipc	a5,0x1e
    800040ae:	5de78793          	addi	a5,a5,1502 # 80022688 <log>
    800040b2:	97b2                	add	a5,a5,a2
    800040b4:	44d8                	lw	a4,12(s1)
    800040b6:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    800040b8:	8526                	mv	a0,s1
    800040ba:	e67fe0ef          	jal	80002f20 <bpin>
    log.lh.n++;
    800040be:	0001e717          	auipc	a4,0x1e
    800040c2:	5ca70713          	addi	a4,a4,1482 # 80022688 <log>
    800040c6:	575c                	lw	a5,44(a4)
    800040c8:	2785                	addiw	a5,a5,1
    800040ca:	d75c                	sw	a5,44(a4)
    800040cc:	a815                	j	80004100 <log_write+0xae>
    panic("too big a transaction");
    800040ce:	00003517          	auipc	a0,0x3
    800040d2:	46250513          	addi	a0,a0,1122 # 80007530 <etext+0x530>
    800040d6:	f5efc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    800040da:	00003517          	auipc	a0,0x3
    800040de:	46e50513          	addi	a0,a0,1134 # 80007548 <etext+0x548>
    800040e2:	f52fc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    800040e6:	00279693          	slli	a3,a5,0x2
    800040ea:	02068693          	addi	a3,a3,32
    800040ee:	0001e717          	auipc	a4,0x1e
    800040f2:	59a70713          	addi	a4,a4,1434 # 80022688 <log>
    800040f6:	9736                	add	a4,a4,a3
    800040f8:	44d4                	lw	a3,12(s1)
    800040fa:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    800040fc:	faf60ee3          	beq	a2,a5,800040b8 <log_write+0x66>
  }
  release(&log.lock);
    80004100:	0001e517          	auipc	a0,0x1e
    80004104:	58850513          	addi	a0,a0,1416 # 80022688 <log>
    80004108:	ba9fc0ef          	jal	80000cb0 <release>
}
    8000410c:	60e2                	ld	ra,24(sp)
    8000410e:	6442                	ld	s0,16(sp)
    80004110:	64a2                	ld	s1,8(sp)
    80004112:	6105                	addi	sp,sp,32
    80004114:	8082                	ret

0000000080004116 <sys_sync>:

uint64
sys_sync(void)
{
    80004116:	1101                	addi	sp,sp,-32
    80004118:	ec06                	sd	ra,24(sp)
    8000411a:	e822                	sd	s0,16(sp)
    8000411c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000411e:	0001e517          	auipc	a0,0x1e
    80004122:	56a50513          	addi	a0,a0,1386 # 80022688 <log>
    80004126:	b03fc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    8000412a:	0001e797          	auipc	a5,0x1e
    8000412e:	57e7a783          	lw	a5,1406(a5) # 800226a8 <log+0x20>
    80004132:	e799                	bnez	a5,80004140 <sys_sync+0x2a>
    80004134:	0001e797          	auipc	a5,0x1e
    80004138:	5707a783          	lw	a5,1392(a5) # 800226a4 <log+0x1c>
    8000413c:	02f05c63          	blez	a5,80004174 <sys_sync+0x5e>
    80004140:	e426                	sd	s1,8(sp)
    80004142:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80004144:	0001e917          	auipc	s2,0x1e
    80004148:	56c92903          	lw	s2,1388(s2) # 800226b0 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    8000414c:	0001e497          	auipc	s1,0x1e
    80004150:	53c48493          	addi	s1,s1,1340 # 80022688 <log>
    80004154:	8526                	mv	a0,s1
    80004156:	f8bfd0ef          	jal	800020e0 <sleep_prepare>
      release(&log.lock);
    8000415a:	8526                	mv	a0,s1
    8000415c:	b55fc0ef          	jal	80000cb0 <release>
      sleep();
    80004160:	fbdfd0ef          	jal	8000211c <sleep>
      acquire(&log.lock);
    80004164:	8526                	mv	a0,s1
    80004166:	ac3fc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    8000416a:	549c                	lw	a5,40(s1)
    8000416c:	fef954e3          	bge	s2,a5,80004154 <sys_sync+0x3e>
    80004170:	64a2                	ld	s1,8(sp)
    80004172:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80004174:	0001e517          	auipc	a0,0x1e
    80004178:	51450513          	addi	a0,a0,1300 # 80022688 <log>
    8000417c:	b35fc0ef          	jal	80000cb0 <release>
  return 0;
}
    80004180:	4501                	li	a0,0
    80004182:	60e2                	ld	ra,24(sp)
    80004184:	6442                	ld	s0,16(sp)
    80004186:	6105                	addi	sp,sp,32
    80004188:	8082                	ret

000000008000418a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000418a:	1101                	addi	sp,sp,-32
    8000418c:	ec06                	sd	ra,24(sp)
    8000418e:	e822                	sd	s0,16(sp)
    80004190:	e426                	sd	s1,8(sp)
    80004192:	e04a                	sd	s2,0(sp)
    80004194:	1000                	addi	s0,sp,32
    80004196:	84aa                	mv	s1,a0
    80004198:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000419a:	00003597          	auipc	a1,0x3
    8000419e:	3ce58593          	addi	a1,a1,974 # 80007568 <etext+0x568>
    800041a2:	0521                	addi	a0,a0,8
    800041a4:	a05fc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    800041a8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800041ac:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800041b0:	0204a423          	sw	zero,40(s1)
}
    800041b4:	60e2                	ld	ra,24(sp)
    800041b6:	6442                	ld	s0,16(sp)
    800041b8:	64a2                	ld	s1,8(sp)
    800041ba:	6902                	ld	s2,0(sp)
    800041bc:	6105                	addi	sp,sp,32
    800041be:	8082                	ret

00000000800041c0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800041c0:	1101                	addi	sp,sp,-32
    800041c2:	ec06                	sd	ra,24(sp)
    800041c4:	e822                	sd	s0,16(sp)
    800041c6:	e426                	sd	s1,8(sp)
    800041c8:	e04a                	sd	s2,0(sp)
    800041ca:	1000                	addi	s0,sp,32
    800041cc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041ce:	00850913          	addi	s2,a0,8
    800041d2:	854a                	mv	a0,s2
    800041d4:	a55fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800041d8:	409c                	lw	a5,0(s1)
    800041da:	cf91                	beqz	a5,800041f6 <acquiresleep+0x36>
    sleep_prepare(lk);
    800041dc:	8526                	mv	a0,s1
    800041de:	f03fd0ef          	jal	800020e0 <sleep_prepare>
    release(&lk->lk);
    800041e2:	854a                	mv	a0,s2
    800041e4:	acdfc0ef          	jal	80000cb0 <release>
    sleep();
    800041e8:	f35fd0ef          	jal	8000211c <sleep>
    acquire(&lk->lk);
    800041ec:	854a                	mv	a0,s2
    800041ee:	a3bfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800041f2:	409c                	lw	a5,0(s1)
    800041f4:	f7e5                	bnez	a5,800041dc <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800041f6:	4785                	li	a5,1
    800041f8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800041fa:	f4efd0ef          	jal	80001948 <myproc>
    800041fe:	591c                	lw	a5,48(a0)
    80004200:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004202:	854a                	mv	a0,s2
    80004204:	aadfc0ef          	jal	80000cb0 <release>
}
    80004208:	60e2                	ld	ra,24(sp)
    8000420a:	6442                	ld	s0,16(sp)
    8000420c:	64a2                	ld	s1,8(sp)
    8000420e:	6902                	ld	s2,0(sp)
    80004210:	6105                	addi	sp,sp,32
    80004212:	8082                	ret

0000000080004214 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004214:	1101                	addi	sp,sp,-32
    80004216:	ec06                	sd	ra,24(sp)
    80004218:	e822                	sd	s0,16(sp)
    8000421a:	e426                	sd	s1,8(sp)
    8000421c:	e04a                	sd	s2,0(sp)
    8000421e:	1000                	addi	s0,sp,32
    80004220:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004222:	00850913          	addi	s2,a0,8
    80004226:	854a                	mv	a0,s2
    80004228:	a01fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    8000422c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004230:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004234:	8526                	mv	a0,s1
    80004236:	f17fd0ef          	jal	8000214c <wakeup>
  release(&lk->lk);
    8000423a:	854a                	mv	a0,s2
    8000423c:	a75fc0ef          	jal	80000cb0 <release>
}
    80004240:	60e2                	ld	ra,24(sp)
    80004242:	6442                	ld	s0,16(sp)
    80004244:	64a2                	ld	s1,8(sp)
    80004246:	6902                	ld	s2,0(sp)
    80004248:	6105                	addi	sp,sp,32
    8000424a:	8082                	ret

000000008000424c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000424c:	7179                	addi	sp,sp,-48
    8000424e:	f406                	sd	ra,40(sp)
    80004250:	f022                	sd	s0,32(sp)
    80004252:	ec26                	sd	s1,24(sp)
    80004254:	e84a                	sd	s2,16(sp)
    80004256:	1800                	addi	s0,sp,48
    80004258:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    8000425a:	00850913          	addi	s2,a0,8
    8000425e:	854a                	mv	a0,s2
    80004260:	9c9fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004264:	409c                	lw	a5,0(s1)
    80004266:	ef81                	bnez	a5,8000427e <holdingsleep+0x32>
    80004268:	4481                	li	s1,0
  release(&lk->lk);
    8000426a:	854a                	mv	a0,s2
    8000426c:	a45fc0ef          	jal	80000cb0 <release>
  return r;
}
    80004270:	8526                	mv	a0,s1
    80004272:	70a2                	ld	ra,40(sp)
    80004274:	7402                	ld	s0,32(sp)
    80004276:	64e2                	ld	s1,24(sp)
    80004278:	6942                	ld	s2,16(sp)
    8000427a:	6145                	addi	sp,sp,48
    8000427c:	8082                	ret
    8000427e:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004280:	0284a983          	lw	s3,40(s1)
    80004284:	ec4fd0ef          	jal	80001948 <myproc>
    80004288:	5904                	lw	s1,48(a0)
    8000428a:	413484b3          	sub	s1,s1,s3
    8000428e:	0014b493          	seqz	s1,s1
    80004292:	69a2                	ld	s3,8(sp)
    80004294:	bfd9                	j	8000426a <holdingsleep+0x1e>

0000000080004296 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004296:	1141                	addi	sp,sp,-16
    80004298:	e406                	sd	ra,8(sp)
    8000429a:	e022                	sd	s0,0(sp)
    8000429c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000429e:	00003597          	auipc	a1,0x3
    800042a2:	2da58593          	addi	a1,a1,730 # 80007578 <etext+0x578>
    800042a6:	0001e517          	auipc	a0,0x1e
    800042aa:	52a50513          	addi	a0,a0,1322 # 800227d0 <ftable>
    800042ae:	8fbfc0ef          	jal	80000ba8 <initlock>
}
    800042b2:	60a2                	ld	ra,8(sp)
    800042b4:	6402                	ld	s0,0(sp)
    800042b6:	0141                	addi	sp,sp,16
    800042b8:	8082                	ret

00000000800042ba <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800042ba:	1101                	addi	sp,sp,-32
    800042bc:	ec06                	sd	ra,24(sp)
    800042be:	e822                	sd	s0,16(sp)
    800042c0:	e426                	sd	s1,8(sp)
    800042c2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800042c4:	0001e517          	auipc	a0,0x1e
    800042c8:	50c50513          	addi	a0,a0,1292 # 800227d0 <ftable>
    800042cc:	95dfc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800042d0:	0001e497          	auipc	s1,0x1e
    800042d4:	51848493          	addi	s1,s1,1304 # 800227e8 <ftable+0x18>
    800042d8:	0001f717          	auipc	a4,0x1f
    800042dc:	4b070713          	addi	a4,a4,1200 # 80023788 <disk>
    if (f->ref == 0) {
    800042e0:	40dc                	lw	a5,4(s1)
    800042e2:	cf89                	beqz	a5,800042fc <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800042e4:	02848493          	addi	s1,s1,40
    800042e8:	fee49ce3          	bne	s1,a4,800042e0 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800042ec:	0001e517          	auipc	a0,0x1e
    800042f0:	4e450513          	addi	a0,a0,1252 # 800227d0 <ftable>
    800042f4:	9bdfc0ef          	jal	80000cb0 <release>
  return 0;
    800042f8:	4481                	li	s1,0
    800042fa:	a809                	j	8000430c <filealloc+0x52>
      f->ref = 1;
    800042fc:	4785                	li	a5,1
    800042fe:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004300:	0001e517          	auipc	a0,0x1e
    80004304:	4d050513          	addi	a0,a0,1232 # 800227d0 <ftable>
    80004308:	9a9fc0ef          	jal	80000cb0 <release>
}
    8000430c:	8526                	mv	a0,s1
    8000430e:	60e2                	ld	ra,24(sp)
    80004310:	6442                	ld	s0,16(sp)
    80004312:	64a2                	ld	s1,8(sp)
    80004314:	6105                	addi	sp,sp,32
    80004316:	8082                	ret

0000000080004318 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004318:	1101                	addi	sp,sp,-32
    8000431a:	ec06                	sd	ra,24(sp)
    8000431c:	e822                	sd	s0,16(sp)
    8000431e:	e426                	sd	s1,8(sp)
    80004320:	1000                	addi	s0,sp,32
    80004322:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004324:	0001e517          	auipc	a0,0x1e
    80004328:	4ac50513          	addi	a0,a0,1196 # 800227d0 <ftable>
    8000432c:	8fdfc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    80004330:	40dc                	lw	a5,4(s1)
    80004332:	02f05063          	blez	a5,80004352 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004336:	2785                	addiw	a5,a5,1
    80004338:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000433a:	0001e517          	auipc	a0,0x1e
    8000433e:	49650513          	addi	a0,a0,1174 # 800227d0 <ftable>
    80004342:	96ffc0ef          	jal	80000cb0 <release>
  return f;
}
    80004346:	8526                	mv	a0,s1
    80004348:	60e2                	ld	ra,24(sp)
    8000434a:	6442                	ld	s0,16(sp)
    8000434c:	64a2                	ld	s1,8(sp)
    8000434e:	6105                	addi	sp,sp,32
    80004350:	8082                	ret
    panic("filedup");
    80004352:	00003517          	auipc	a0,0x3
    80004356:	22e50513          	addi	a0,a0,558 # 80007580 <etext+0x580>
    8000435a:	cdafc0ef          	jal	80000834 <panic>

000000008000435e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000435e:	7139                	addi	sp,sp,-64
    80004360:	fc06                	sd	ra,56(sp)
    80004362:	f822                	sd	s0,48(sp)
    80004364:	f426                	sd	s1,40(sp)
    80004366:	0080                	addi	s0,sp,64
    80004368:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000436a:	0001e517          	auipc	a0,0x1e
    8000436e:	46650513          	addi	a0,a0,1126 # 800227d0 <ftable>
    80004372:	8b7fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    80004376:	40dc                	lw	a5,4(s1)
    80004378:	04f05a63          	blez	a5,800043cc <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    8000437c:	37fd                	addiw	a5,a5,-1
    8000437e:	c0dc                	sw	a5,4(s1)
    80004380:	06f04063          	bgtz	a5,800043e0 <fileclose+0x82>
    80004384:	f04a                	sd	s2,32(sp)
    80004386:	ec4e                	sd	s3,24(sp)
    80004388:	e852                	sd	s4,16(sp)
    8000438a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000438c:	0004a903          	lw	s2,0(s1)
    80004390:	0094c783          	lbu	a5,9(s1)
    80004394:	89be                	mv	s3,a5
    80004396:	689c                	ld	a5,16(s1)
    80004398:	8a3e                	mv	s4,a5
    8000439a:	6c9c                	ld	a5,24(s1)
    8000439c:	8abe                	mv	s5,a5
  f->ref = 0;
    8000439e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800043a2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800043a6:	0001e517          	auipc	a0,0x1e
    800043aa:	42a50513          	addi	a0,a0,1066 # 800227d0 <ftable>
    800043ae:	903fc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    800043b2:	4785                	li	a5,1
    800043b4:	04f90163          	beq	s2,a5,800043f6 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    800043b8:	ffe9079b          	addiw	a5,s2,-2
    800043bc:	4705                	li	a4,1
    800043be:	04f77563          	bgeu	a4,a5,80004408 <fileclose+0xaa>
    800043c2:	7902                	ld	s2,32(sp)
    800043c4:	69e2                	ld	s3,24(sp)
    800043c6:	6a42                	ld	s4,16(sp)
    800043c8:	6aa2                	ld	s5,8(sp)
    800043ca:	a00d                	j	800043ec <fileclose+0x8e>
    800043cc:	f04a                	sd	s2,32(sp)
    800043ce:	ec4e                	sd	s3,24(sp)
    800043d0:	e852                	sd	s4,16(sp)
    800043d2:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800043d4:	00003517          	auipc	a0,0x3
    800043d8:	1b450513          	addi	a0,a0,436 # 80007588 <etext+0x588>
    800043dc:	c58fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    800043e0:	0001e517          	auipc	a0,0x1e
    800043e4:	3f050513          	addi	a0,a0,1008 # 800227d0 <ftable>
    800043e8:	8c9fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800043ec:	70e2                	ld	ra,56(sp)
    800043ee:	7442                	ld	s0,48(sp)
    800043f0:	74a2                	ld	s1,40(sp)
    800043f2:	6121                	addi	sp,sp,64
    800043f4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800043f6:	85ce                	mv	a1,s3
    800043f8:	8552                	mv	a0,s4
    800043fa:	36a000ef          	jal	80004764 <pipeclose>
    800043fe:	7902                	ld	s2,32(sp)
    80004400:	69e2                	ld	s3,24(sp)
    80004402:	6a42                	ld	s4,16(sp)
    80004404:	6aa2                	ld	s5,8(sp)
    80004406:	b7dd                	j	800043ec <fileclose+0x8e>
    begin_op();
    80004408:	a9dff0ef          	jal	80003ea4 <begin_op>
    iput(ff.ip);
    8000440c:	8556                	mv	a0,s5
    8000440e:	9a0ff0ef          	jal	800035ae <iput>
    end_op();
    80004412:	b1fff0ef          	jal	80003f30 <end_op>
    80004416:	7902                	ld	s2,32(sp)
    80004418:	69e2                	ld	s3,24(sp)
    8000441a:	6a42                	ld	s4,16(sp)
    8000441c:	6aa2                	ld	s5,8(sp)
    8000441e:	b7f9                	j	800043ec <fileclose+0x8e>

0000000080004420 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004420:	715d                	addi	sp,sp,-80
    80004422:	e486                	sd	ra,72(sp)
    80004424:	e0a2                	sd	s0,64(sp)
    80004426:	fc26                	sd	s1,56(sp)
    80004428:	f052                	sd	s4,32(sp)
    8000442a:	0880                	addi	s0,sp,80
    8000442c:	84aa                	mv	s1,a0
    8000442e:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004430:	d18fd0ef          	jal	80001948 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004434:	409c                	lw	a5,0(s1)
    80004436:	37f9                	addiw	a5,a5,-2
    80004438:	4705                	li	a4,1
    8000443a:	04f76963          	bltu	a4,a5,8000448c <filestat+0x6c>
    8000443e:	f84a                	sd	s2,48(sp)
    80004440:	f44e                	sd	s3,40(sp)
    80004442:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    80004444:	fb840993          	addi	s3,s0,-72
    80004448:	4661                	li	a2,24
    8000444a:	4581                	li	a1,0
    8000444c:	854e                	mv	a0,s3
    8000444e:	89bfc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    80004452:	6c88                	ld	a0,24(s1)
    80004454:	fd9fe0ef          	jal	8000342c <ilock>
    stati(f->ip, &st);
    80004458:	85ce                	mv	a1,s3
    8000445a:	6c88                	ld	a0,24(s1)
    8000445c:	b7cff0ef          	jal	800037d8 <stati>
    iunlock(f->ip);
    80004460:	6c88                	ld	a0,24(s1)
    80004462:	878ff0ef          	jal	800034da <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    80004466:	4761                	li	a4,24
    80004468:	86ce                	mv	a3,s3
    8000446a:	8652                	mv	a2,s4
    8000446c:	04893583          	ld	a1,72(s2)
    80004470:	05093503          	ld	a0,80(s2)
    80004474:	90efd0ef          	jal	80001582 <copyout>
    80004478:	41f5551b          	sraiw	a0,a0,0x1f
    8000447c:	7942                	ld	s2,48(sp)
    8000447e:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004480:	60a6                	ld	ra,72(sp)
    80004482:	6406                	ld	s0,64(sp)
    80004484:	74e2                	ld	s1,56(sp)
    80004486:	7a02                	ld	s4,32(sp)
    80004488:	6161                	addi	sp,sp,80
    8000448a:	8082                	ret
  return -1;
    8000448c:	557d                	li	a0,-1
    8000448e:	bfcd                	j	80004480 <filestat+0x60>

0000000080004490 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004490:	7179                	addi	sp,sp,-48
    80004492:	f406                	sd	ra,40(sp)
    80004494:	f022                	sd	s0,32(sp)
    80004496:	e84a                	sd	s2,16(sp)
    80004498:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    8000449a:	00854783          	lbu	a5,8(a0)
    8000449e:	c3dd                	beqz	a5,80004544 <fileread+0xb4>
    800044a0:	ec26                	sd	s1,24(sp)
    800044a2:	e44e                	sd	s3,8(sp)
    800044a4:	84aa                	mv	s1,a0
    800044a6:	892e                	mv	s2,a1
    800044a8:	89b2                	mv	s3,a2
    800044aa:	01f6579b          	srliw	a5,a2,0x1f
    800044ae:	ebc9                	bnez	a5,80004540 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    800044b0:	411c                	lw	a5,0(a0)
    800044b2:	4705                	li	a4,1
    800044b4:	04e78363          	beq	a5,a4,800044fa <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800044b8:	470d                	li	a4,3
    800044ba:	04e78763          	beq	a5,a4,80004508 <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    800044be:	4709                	li	a4,2
    800044c0:	06e79a63          	bne	a5,a4,80004534 <fileread+0xa4>
    ilock(f->ip);
    800044c4:	6d08                	ld	a0,24(a0)
    800044c6:	f67fe0ef          	jal	8000342c <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800044ca:	874e                	mv	a4,s3
    800044cc:	5094                	lw	a3,32(s1)
    800044ce:	864a                	mv	a2,s2
    800044d0:	4585                	li	a1,1
    800044d2:	6c88                	ld	a0,24(s1)
    800044d4:	b32ff0ef          	jal	80003806 <readi>
    800044d8:	892a                	mv	s2,a0
    800044da:	00a05563          	blez	a0,800044e4 <fileread+0x54>
      f->off += r;
    800044de:	509c                	lw	a5,32(s1)
    800044e0:	9fa9                	addw	a5,a5,a0
    800044e2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800044e4:	6c88                	ld	a0,24(s1)
    800044e6:	ff5fe0ef          	jal	800034da <iunlock>
    800044ea:	64e2                	ld	s1,24(sp)
    800044ec:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800044ee:	854a                	mv	a0,s2
    800044f0:	70a2                	ld	ra,40(sp)
    800044f2:	7402                	ld	s0,32(sp)
    800044f4:	6942                	ld	s2,16(sp)
    800044f6:	6145                	addi	sp,sp,48
    800044f8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800044fa:	6908                	ld	a0,16(a0)
    800044fc:	3e2000ef          	jal	800048de <piperead>
    80004500:	892a                	mv	s2,a0
    80004502:	64e2                	ld	s1,24(sp)
    80004504:	69a2                	ld	s3,8(sp)
    80004506:	b7e5                	j	800044ee <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004508:	02451783          	lh	a5,36(a0)
    8000450c:	03079693          	slli	a3,a5,0x30
    80004510:	92c1                	srli	a3,a3,0x30
    80004512:	4725                	li	a4,9
    80004514:	02d76b63          	bltu	a4,a3,8000454a <fileread+0xba>
    80004518:	0792                	slli	a5,a5,0x4
    8000451a:	0001e717          	auipc	a4,0x1e
    8000451e:	21670713          	addi	a4,a4,534 # 80022730 <devsw>
    80004522:	97ba                	add	a5,a5,a4
    80004524:	639c                	ld	a5,0(a5)
    80004526:	c79d                	beqz	a5,80004554 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    80004528:	4505                	li	a0,1
    8000452a:	9782                	jalr	a5
    8000452c:	892a                	mv	s2,a0
    8000452e:	64e2                	ld	s1,24(sp)
    80004530:	69a2                	ld	s3,8(sp)
    80004532:	bf75                	j	800044ee <fileread+0x5e>
    panic("fileread");
    80004534:	00003517          	auipc	a0,0x3
    80004538:	06450513          	addi	a0,a0,100 # 80007598 <etext+0x598>
    8000453c:	af8fc0ef          	jal	80000834 <panic>
    80004540:	64e2                	ld	s1,24(sp)
    80004542:	69a2                	ld	s3,8(sp)
    return -1;
    80004544:	57fd                	li	a5,-1
    80004546:	893e                	mv	s2,a5
    80004548:	b75d                	j	800044ee <fileread+0x5e>
      return -1;
    8000454a:	57fd                	li	a5,-1
    8000454c:	893e                	mv	s2,a5
    8000454e:	64e2                	ld	s1,24(sp)
    80004550:	69a2                	ld	s3,8(sp)
    80004552:	bf71                	j	800044ee <fileread+0x5e>
    80004554:	57fd                	li	a5,-1
    80004556:	893e                	mv	s2,a5
    80004558:	64e2                	ld	s1,24(sp)
    8000455a:	69a2                	ld	s3,8(sp)
    8000455c:	bf49                	j	800044ee <fileread+0x5e>

000000008000455e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    8000455e:	00954783          	lbu	a5,9(a0)
    80004562:	12078b63          	beqz	a5,80004698 <filewrite+0x13a>
{
    80004566:	711d                	addi	sp,sp,-96
    80004568:	ec86                	sd	ra,88(sp)
    8000456a:	e8a2                	sd	s0,80(sp)
    8000456c:	e0ca                	sd	s2,64(sp)
    8000456e:	f456                	sd	s5,40(sp)
    80004570:	f05a                	sd	s6,32(sp)
    80004572:	1080                	addi	s0,sp,96
    80004574:	892a                	mv	s2,a0
    80004576:	8b2e                	mv	s6,a1
    80004578:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    8000457a:	01f6579b          	srliw	a5,a2,0x1f
    8000457e:	0e079d63          	bnez	a5,80004678 <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    80004582:	411c                	lw	a5,0(a0)
    80004584:	4705                	li	a4,1
    80004586:	02e78a63          	beq	a5,a4,800045ba <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000458a:	470d                	li	a4,3
    8000458c:	02e78b63          	beq	a5,a4,800045c2 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004590:	4709                	li	a4,2
    80004592:	0ce79763          	bne	a5,a4,80004660 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    80004596:	0ec05763          	blez	a2,80004684 <filewrite+0x126>
    8000459a:	e4a6                	sd	s1,72(sp)
    8000459c:	fc4e                	sd	s3,56(sp)
    8000459e:	f852                	sd	s4,48(sp)
    800045a0:	ec5e                	sd	s7,24(sp)
    800045a2:	e862                	sd	s8,16(sp)
    800045a4:	e466                	sd	s9,8(sp)
    int i = 0;
    800045a6:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    800045a8:	6b85                	lui	s7,0x1
    800045aa:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800045ae:	6785                	lui	a5,0x1
    800045b0:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800045b4:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800045b6:	4c05                	li	s8,1
    800045b8:	a8ad                	j	80004632 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    800045ba:	6908                	ld	a0,16(a0)
    800045bc:	206000ef          	jal	800047c2 <pipewrite>
    800045c0:	a849                	j	80004652 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800045c2:	02451783          	lh	a5,36(a0)
    800045c6:	03079693          	slli	a3,a5,0x30
    800045ca:	92c1                	srli	a3,a3,0x30
    800045cc:	4725                	li	a4,9
    800045ce:	0ad76763          	bltu	a4,a3,8000467c <filewrite+0x11e>
    800045d2:	0792                	slli	a5,a5,0x4
    800045d4:	0001e717          	auipc	a4,0x1e
    800045d8:	15c70713          	addi	a4,a4,348 # 80022730 <devsw>
    800045dc:	97ba                	add	a5,a5,a4
    800045de:	679c                	ld	a5,8(a5)
    800045e0:	c3c5                	beqz	a5,80004680 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800045e2:	4505                	li	a0,1
    800045e4:	9782                	jalr	a5
    800045e6:	a0b5                	j	80004652 <filewrite+0xf4>
      if (n1 > max)
    800045e8:	2981                	sext.w	s3,s3
      begin_op();
    800045ea:	8bbff0ef          	jal	80003ea4 <begin_op>
      ilock(f->ip);
    800045ee:	01893503          	ld	a0,24(s2)
    800045f2:	e3bfe0ef          	jal	8000342c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800045f6:	874e                	mv	a4,s3
    800045f8:	02092683          	lw	a3,32(s2)
    800045fc:	016a0633          	add	a2,s4,s6
    80004600:	85e2                	mv	a1,s8
    80004602:	01893503          	ld	a0,24(s2)
    80004606:	af2ff0ef          	jal	800038f8 <writei>
    8000460a:	84aa                	mv	s1,a0
    8000460c:	00a05763          	blez	a0,8000461a <filewrite+0xbc>
        f->off += r;
    80004610:	02092783          	lw	a5,32(s2)
    80004614:	9fa9                	addw	a5,a5,a0
    80004616:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000461a:	01893503          	ld	a0,24(s2)
    8000461e:	ebdfe0ef          	jal	800034da <iunlock>
      end_op();
    80004622:	90fff0ef          	jal	80003f30 <end_op>

      if (r != n1) {
    80004626:	00999d63          	bne	s3,s1,80004640 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    8000462a:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    8000462e:	015a5963          	bge	s4,s5,80004640 <filewrite+0xe2>
      int n1 = n - i;
    80004632:	414a87bb          	subw	a5,s5,s4
    80004636:	89be                	mv	s3,a5
      if (n1 > max)
    80004638:	fafbd8e3          	bge	s7,a5,800045e8 <filewrite+0x8a>
    8000463c:	89e6                	mv	s3,s9
    8000463e:	b76d                	j	800045e8 <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    80004640:	054a9463          	bne	s5,s4,80004688 <filewrite+0x12a>
    80004644:	8556                	mv	a0,s5
    80004646:	64a6                	ld	s1,72(sp)
    80004648:	79e2                	ld	s3,56(sp)
    8000464a:	7a42                	ld	s4,48(sp)
    8000464c:	6be2                	ld	s7,24(sp)
    8000464e:	6c42                	ld	s8,16(sp)
    80004650:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004652:	60e6                	ld	ra,88(sp)
    80004654:	6446                	ld	s0,80(sp)
    80004656:	6906                	ld	s2,64(sp)
    80004658:	7aa2                	ld	s5,40(sp)
    8000465a:	7b02                	ld	s6,32(sp)
    8000465c:	6125                	addi	sp,sp,96
    8000465e:	8082                	ret
    80004660:	e4a6                	sd	s1,72(sp)
    80004662:	fc4e                	sd	s3,56(sp)
    80004664:	f852                	sd	s4,48(sp)
    80004666:	ec5e                	sd	s7,24(sp)
    80004668:	e862                	sd	s8,16(sp)
    8000466a:	e466                	sd	s9,8(sp)
    panic("filewrite");
    8000466c:	00003517          	auipc	a0,0x3
    80004670:	f3c50513          	addi	a0,a0,-196 # 800075a8 <etext+0x5a8>
    80004674:	9c0fc0ef          	jal	80000834 <panic>
    return -1;
    80004678:	557d                	li	a0,-1
    8000467a:	bfe1                	j	80004652 <filewrite+0xf4>
      return -1;
    8000467c:	557d                	li	a0,-1
    8000467e:	bfd1                	j	80004652 <filewrite+0xf4>
    80004680:	557d                	li	a0,-1
    80004682:	bfc1                	j	80004652 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    80004684:	8532                	mv	a0,a2
    80004686:	b7f1                	j	80004652 <filewrite+0xf4>
    80004688:	557d                	li	a0,-1
    8000468a:	64a6                	ld	s1,72(sp)
    8000468c:	79e2                	ld	s3,56(sp)
    8000468e:	7a42                	ld	s4,48(sp)
    80004690:	6be2                	ld	s7,24(sp)
    80004692:	6c42                	ld	s8,16(sp)
    80004694:	6ca2                	ld	s9,8(sp)
    80004696:	bf75                	j	80004652 <filewrite+0xf4>
    return -1;
    80004698:	557d                	li	a0,-1
}
    8000469a:	8082                	ret

000000008000469c <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000469c:	7179                	addi	sp,sp,-48
    8000469e:	f406                	sd	ra,40(sp)
    800046a0:	f022                	sd	s0,32(sp)
    800046a2:	ec26                	sd	s1,24(sp)
    800046a4:	e052                	sd	s4,0(sp)
    800046a6:	1800                	addi	s0,sp,48
    800046a8:	84aa                	mv	s1,a0
    800046aa:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800046ac:	0005b023          	sd	zero,0(a1)
    800046b0:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800046b4:	c07ff0ef          	jal	800042ba <filealloc>
    800046b8:	e088                	sd	a0,0(s1)
    800046ba:	c549                	beqz	a0,80004744 <pipealloc+0xa8>
    800046bc:	bffff0ef          	jal	800042ba <filealloc>
    800046c0:	00aa3023          	sd	a0,0(s4)
    800046c4:	cd25                	beqz	a0,8000473c <pipealloc+0xa0>
    800046c6:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    800046c8:	c86fc0ef          	jal	80000b4e <kalloc>
    800046cc:	892a                	mv	s2,a0
    800046ce:	c12d                	beqz	a0,80004730 <pipealloc+0x94>
    800046d0:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800046d2:	4985                	li	s3,1
    800046d4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800046d8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800046dc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800046e0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800046e4:	00003597          	auipc	a1,0x3
    800046e8:	ed458593          	addi	a1,a1,-300 # 800075b8 <etext+0x5b8>
    800046ec:	cbcfc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    800046f0:	609c                	ld	a5,0(s1)
    800046f2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800046f6:	609c                	ld	a5,0(s1)
    800046f8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800046fc:	609c                	ld	a5,0(s1)
    800046fe:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004702:	609c                	ld	a5,0(s1)
    80004704:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004708:	000a3783          	ld	a5,0(s4)
    8000470c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004710:	000a3783          	ld	a5,0(s4)
    80004714:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004718:	000a3783          	ld	a5,0(s4)
    8000471c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004720:	000a3783          	ld	a5,0(s4)
    80004724:	0127b823          	sd	s2,16(a5)
  return 0;
    80004728:	4501                	li	a0,0
    8000472a:	6942                	ld	s2,16(sp)
    8000472c:	69a2                	ld	s3,8(sp)
    8000472e:	a01d                	j	80004754 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004730:	6088                	ld	a0,0(s1)
    80004732:	c119                	beqz	a0,80004738 <pipealloc+0x9c>
    80004734:	6942                	ld	s2,16(sp)
    80004736:	a029                	j	80004740 <pipealloc+0xa4>
    80004738:	6942                	ld	s2,16(sp)
    8000473a:	a029                	j	80004744 <pipealloc+0xa8>
    8000473c:	6088                	ld	a0,0(s1)
    8000473e:	c10d                	beqz	a0,80004760 <pipealloc+0xc4>
    fileclose(*f0);
    80004740:	c1fff0ef          	jal	8000435e <fileclose>
  if (*f1)
    80004744:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004748:	557d                	li	a0,-1
  if (*f1)
    8000474a:	c789                	beqz	a5,80004754 <pipealloc+0xb8>
    fileclose(*f1);
    8000474c:	853e                	mv	a0,a5
    8000474e:	c11ff0ef          	jal	8000435e <fileclose>
  return -1;
    80004752:	557d                	li	a0,-1
}
    80004754:	70a2                	ld	ra,40(sp)
    80004756:	7402                	ld	s0,32(sp)
    80004758:	64e2                	ld	s1,24(sp)
    8000475a:	6a02                	ld	s4,0(sp)
    8000475c:	6145                	addi	sp,sp,48
    8000475e:	8082                	ret
  return -1;
    80004760:	557d                	li	a0,-1
    80004762:	bfcd                	j	80004754 <pipealloc+0xb8>

0000000080004764 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004764:	1101                	addi	sp,sp,-32
    80004766:	ec06                	sd	ra,24(sp)
    80004768:	e822                	sd	s0,16(sp)
    8000476a:	e426                	sd	s1,8(sp)
    8000476c:	e04a                	sd	s2,0(sp)
    8000476e:	1000                	addi	s0,sp,32
    80004770:	84aa                	mv	s1,a0
    80004772:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004774:	cb4fc0ef          	jal	80000c28 <acquire>
  if (writable) {
    80004778:	02090763          	beqz	s2,800047a6 <pipeclose+0x42>
    pi->writeopen = 0;
    8000477c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004780:	21848513          	addi	a0,s1,536
    80004784:	9c9fd0ef          	jal	8000214c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004788:	2204a783          	lw	a5,544(s1)
    8000478c:	e781                	bnez	a5,80004794 <pipeclose+0x30>
    8000478e:	2244a783          	lw	a5,548(s1)
    80004792:	c38d                	beqz	a5,800047b4 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    80004794:	8526                	mv	a0,s1
    80004796:	d1afc0ef          	jal	80000cb0 <release>
}
    8000479a:	60e2                	ld	ra,24(sp)
    8000479c:	6442                	ld	s0,16(sp)
    8000479e:	64a2                	ld	s1,8(sp)
    800047a0:	6902                	ld	s2,0(sp)
    800047a2:	6105                	addi	sp,sp,32
    800047a4:	8082                	ret
    pi->readopen = 0;
    800047a6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800047aa:	21c48513          	addi	a0,s1,540
    800047ae:	99ffd0ef          	jal	8000214c <wakeup>
    800047b2:	bfd9                	j	80004788 <pipeclose+0x24>
    release(&pi->lock);
    800047b4:	8526                	mv	a0,s1
    800047b6:	cfafc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    800047ba:	8526                	mv	a0,s1
    800047bc:	aaafc0ef          	jal	80000a66 <kfree>
    800047c0:	bfe9                	j	8000479a <pipeclose+0x36>

00000000800047c2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800047c2:	7159                	addi	sp,sp,-112
    800047c4:	f486                	sd	ra,104(sp)
    800047c6:	f0a2                	sd	s0,96(sp)
    800047c8:	eca6                	sd	s1,88(sp)
    800047ca:	e8ca                	sd	s2,80(sp)
    800047cc:	e4ce                	sd	s3,72(sp)
    800047ce:	e0d2                	sd	s4,64(sp)
    800047d0:	fc56                	sd	s5,56(sp)
    800047d2:	1880                	addi	s0,sp,112
    800047d4:	84aa                	mv	s1,a0
    800047d6:	8aae                	mv	s5,a1
    800047d8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800047da:	96efd0ef          	jal	80001948 <myproc>
    800047de:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800047e0:	8526                	mv	a0,s1
    800047e2:	c46fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    800047e6:	0f405a63          	blez	s4,800048da <pipewrite+0x118>
    800047ea:	f85a                	sd	s6,48(sp)
    800047ec:	f45e                	sd	s7,40(sp)
    800047ee:	f062                	sd	s8,32(sp)
    800047f0:	ec66                	sd	s9,24(sp)
    800047f2:	e86a                	sd	s10,16(sp)
  int i = 0;
    800047f4:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800047f6:	f9f40c13          	addi	s8,s0,-97
    800047fa:	4b85                	li	s7,1
    800047fc:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800047fe:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    80004802:	21c48c93          	addi	s9,s1,540
    80004806:	a0a1                	j	8000484e <pipewrite+0x8c>
      release(&pi->lock);
    80004808:	8526                	mv	a0,s1
    8000480a:	ca6fc0ef          	jal	80000cb0 <release>
      return -1;
    8000480e:	597d                	li	s2,-1
    80004810:	7b42                	ld	s6,48(sp)
    80004812:	7ba2                	ld	s7,40(sp)
    80004814:	7c02                	ld	s8,32(sp)
    80004816:	6ce2                	ld	s9,24(sp)
    80004818:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000481a:	854a                	mv	a0,s2
    8000481c:	70a6                	ld	ra,104(sp)
    8000481e:	7406                	ld	s0,96(sp)
    80004820:	64e6                	ld	s1,88(sp)
    80004822:	6946                	ld	s2,80(sp)
    80004824:	69a6                	ld	s3,72(sp)
    80004826:	6a06                	ld	s4,64(sp)
    80004828:	7ae2                	ld	s5,56(sp)
    8000482a:	6165                	addi	sp,sp,112
    8000482c:	8082                	ret
      wakeup(&pi->nread);
    8000482e:	856a                	mv	a0,s10
    80004830:	91dfd0ef          	jal	8000214c <wakeup>
      sleep_prepare(&pi->nwrite);
    80004834:	8566                	mv	a0,s9
    80004836:	8abfd0ef          	jal	800020e0 <sleep_prepare>
      release(&pi->lock);
    8000483a:	8526                	mv	a0,s1
    8000483c:	c74fc0ef          	jal	80000cb0 <release>
      sleep();
    80004840:	8ddfd0ef          	jal	8000211c <sleep>
      acquire(&pi->lock);
    80004844:	8526                	mv	a0,s1
    80004846:	be2fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    8000484a:	07495b63          	bge	s2,s4,800048c0 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    8000484e:	2204a783          	lw	a5,544(s1)
    80004852:	dbdd                	beqz	a5,80004808 <pipewrite+0x46>
    80004854:	854e                	mv	a0,s3
    80004856:	ae9fd0ef          	jal	8000233e <killed>
    8000485a:	f55d                	bnez	a0,80004808 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    8000485c:	2184a783          	lw	a5,536(s1)
    80004860:	21c4a703          	lw	a4,540(s1)
    80004864:	2007879b          	addiw	a5,a5,512
    80004868:	fcf703e3          	beq	a4,a5,8000482e <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    8000486c:	875e                	mv	a4,s7
    8000486e:	015906b3          	add	a3,s2,s5
    80004872:	8662                	mv	a2,s8
    80004874:	0489b583          	ld	a1,72(s3)
    80004878:	0509b503          	ld	a0,80(s3)
    8000487c:	dcdfc0ef          	jal	80001648 <copyin>
    80004880:	03650163          	beq	a0,s6,800048a2 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004884:	21c4a783          	lw	a5,540(s1)
    80004888:	0017871b          	addiw	a4,a5,1
    8000488c:	20e4ae23          	sw	a4,540(s1)
    80004890:	1ff7f793          	andi	a5,a5,511
    80004894:	97a6                	add	a5,a5,s1
    80004896:	f9f44703          	lbu	a4,-97(s0)
    8000489a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000489e:	2905                	addiw	s2,s2,1
    800048a0:	b76d                	j	8000484a <pipewrite+0x88>
        if (i == 0)
    800048a2:	00090863          	beqz	s2,800048b2 <pipewrite+0xf0>
    800048a6:	7b42                	ld	s6,48(sp)
    800048a8:	7ba2                	ld	s7,40(sp)
    800048aa:	7c02                	ld	s8,32(sp)
    800048ac:	6ce2                	ld	s9,24(sp)
    800048ae:	6d42                	ld	s10,16(sp)
    800048b0:	a829                	j	800048ca <pipewrite+0x108>
          i = -1;
    800048b2:	892a                	mv	s2,a0
        break;
    800048b4:	7b42                	ld	s6,48(sp)
    800048b6:	7ba2                	ld	s7,40(sp)
    800048b8:	7c02                	ld	s8,32(sp)
    800048ba:	6ce2                	ld	s9,24(sp)
    800048bc:	6d42                	ld	s10,16(sp)
    800048be:	a031                	j	800048ca <pipewrite+0x108>
    800048c0:	7b42                	ld	s6,48(sp)
    800048c2:	7ba2                	ld	s7,40(sp)
    800048c4:	7c02                	ld	s8,32(sp)
    800048c6:	6ce2                	ld	s9,24(sp)
    800048c8:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800048ca:	21848513          	addi	a0,s1,536
    800048ce:	87ffd0ef          	jal	8000214c <wakeup>
  release(&pi->lock);
    800048d2:	8526                	mv	a0,s1
    800048d4:	bdcfc0ef          	jal	80000cb0 <release>
  return i;
    800048d8:	b789                	j	8000481a <pipewrite+0x58>
  int i = 0;
    800048da:	4901                	li	s2,0
    800048dc:	b7fd                	j	800048ca <pipewrite+0x108>

00000000800048de <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800048de:	711d                	addi	sp,sp,-96
    800048e0:	ec86                	sd	ra,88(sp)
    800048e2:	e8a2                	sd	s0,80(sp)
    800048e4:	e4a6                	sd	s1,72(sp)
    800048e6:	e0ca                	sd	s2,64(sp)
    800048e8:	fc4e                	sd	s3,56(sp)
    800048ea:	f852                	sd	s4,48(sp)
    800048ec:	f456                	sd	s5,40(sp)
    800048ee:	1080                	addi	s0,sp,96
    800048f0:	84aa                	mv	s1,a0
    800048f2:	89ae                	mv	s3,a1
    800048f4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800048f6:	852fd0ef          	jal	80001948 <myproc>
    800048fa:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    800048fc:	8526                	mv	a0,s1
    800048fe:	b2afc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004902:	0d505263          	blez	s5,800049c6 <piperead+0xe8>
    80004906:	2184a703          	lw	a4,536(s1)
    8000490a:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    8000490e:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004912:	02f71e63          	bne	a4,a5,8000494e <piperead+0x70>
    80004916:	2244a783          	lw	a5,548(s1)
    8000491a:	c3b9                	beqz	a5,80004960 <piperead+0x82>
    if (killed(pr)) {
    8000491c:	854a                	mv	a0,s2
    8000491e:	a21fd0ef          	jal	8000233e <killed>
    80004922:	e915                	bnez	a0,80004956 <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004924:	8552                	mv	a0,s4
    80004926:	fbafd0ef          	jal	800020e0 <sleep_prepare>
    release(&pi->lock);
    8000492a:	8526                	mv	a0,s1
    8000492c:	b84fc0ef          	jal	80000cb0 <release>
    sleep();
    80004930:	fecfd0ef          	jal	8000211c <sleep>
    acquire(&pi->lock);
    80004934:	8526                	mv	a0,s1
    80004936:	af2fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000493a:	2184a703          	lw	a4,536(s1)
    8000493e:	21c4a783          	lw	a5,540(s1)
    80004942:	fcf70ae3          	beq	a4,a5,80004916 <piperead+0x38>
    80004946:	f05a                	sd	s6,32(sp)
    80004948:	ec5e                	sd	s7,24(sp)
    8000494a:	e862                	sd	s8,16(sp)
    8000494c:	a829                	j	80004966 <piperead+0x88>
    8000494e:	f05a                	sd	s6,32(sp)
    80004950:	ec5e                	sd	s7,24(sp)
    80004952:	e862                	sd	s8,16(sp)
    80004954:	a809                	j	80004966 <piperead+0x88>
      release(&pi->lock);
    80004956:	8526                	mv	a0,s1
    80004958:	b58fc0ef          	jal	80000cb0 <release>
      return -1;
    8000495c:	5a7d                	li	s4,-1
    8000495e:	a8a5                	j	800049d6 <piperead+0xf8>
    80004960:	f05a                	sd	s6,32(sp)
    80004962:	ec5e                	sd	s7,24(sp)
    80004964:	e862                	sd	s8,16(sp)
{
    80004966:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004968:	faf40c13          	addi	s8,s0,-81
    8000496c:	4b85                	li	s7,1
    8000496e:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    80004970:	2184a783          	lw	a5,536(s1)
    80004974:	21c4a703          	lw	a4,540(s1)
    80004978:	06f70e63          	beq	a4,a5,800049f4 <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    8000497c:	1ff7f793          	andi	a5,a5,511
    80004980:	97a6                	add	a5,a5,s1
    80004982:	0187c783          	lbu	a5,24(a5)
    80004986:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    8000498a:	875e                	mv	a4,s7
    8000498c:	86e2                	mv	a3,s8
    8000498e:	864e                	mv	a2,s3
    80004990:	04893583          	ld	a1,72(s2)
    80004994:	05093503          	ld	a0,80(s2)
    80004998:	bebfc0ef          	jal	80001582 <copyout>
    8000499c:	01650f63          	beq	a0,s6,800049ba <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800049a0:	2184a783          	lw	a5,536(s1)
    800049a4:	2785                	addiw	a5,a5,1
    800049a6:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800049aa:	2a05                	addiw	s4,s4,1
    800049ac:	0985                	addi	s3,s3,1
    800049ae:	fd4a91e3          	bne	s5,s4,80004970 <piperead+0x92>
    800049b2:	7b02                	ld	s6,32(sp)
    800049b4:	6be2                	ld	s7,24(sp)
    800049b6:	6c42                	ld	s8,16(sp)
    800049b8:	a801                	j	800049c8 <piperead+0xea>
      if (i == 0)
    800049ba:	020a0863          	beqz	s4,800049ea <piperead+0x10c>
    800049be:	7b02                	ld	s6,32(sp)
    800049c0:	6be2                	ld	s7,24(sp)
    800049c2:	6c42                	ld	s8,16(sp)
    800049c4:	a011                	j	800049c8 <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800049c6:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    800049c8:	21c48513          	addi	a0,s1,540
    800049cc:	f80fd0ef          	jal	8000214c <wakeup>
  release(&pi->lock);
    800049d0:	8526                	mv	a0,s1
    800049d2:	adefc0ef          	jal	80000cb0 <release>
  return i;
}
    800049d6:	8552                	mv	a0,s4
    800049d8:	60e6                	ld	ra,88(sp)
    800049da:	6446                	ld	s0,80(sp)
    800049dc:	64a6                	ld	s1,72(sp)
    800049de:	6906                	ld	s2,64(sp)
    800049e0:	79e2                	ld	s3,56(sp)
    800049e2:	7a42                	ld	s4,48(sp)
    800049e4:	7aa2                	ld	s5,40(sp)
    800049e6:	6125                	addi	sp,sp,96
    800049e8:	8082                	ret
        i = -1;
    800049ea:	8a2a                	mv	s4,a0
    800049ec:	7b02                	ld	s6,32(sp)
    800049ee:	6be2                	ld	s7,24(sp)
    800049f0:	6c42                	ld	s8,16(sp)
    800049f2:	bfd9                	j	800049c8 <piperead+0xea>
    800049f4:	7b02                	ld	s6,32(sp)
    800049f6:	6be2                	ld	s7,24(sp)
    800049f8:	6c42                	ld	s8,16(sp)
    800049fa:	b7f9                	j	800049c8 <piperead+0xea>

00000000800049fc <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    800049fc:	1141                	addi	sp,sp,-16
    800049fe:	e406                	sd	ra,8(sp)
    80004a00:	e022                	sd	s0,0(sp)
    80004a02:	0800                	addi	s0,sp,16
    80004a04:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004a06:	0035151b          	slliw	a0,a0,0x3
    80004a0a:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    80004a0c:	8b89                	andi	a5,a5,2
    80004a0e:	c399                	beqz	a5,80004a14 <flags2perm+0x18>
    perm |= PTE_W;
    80004a10:	00456513          	ori	a0,a0,4
  return perm;
}
    80004a14:	60a2                	ld	ra,8(sp)
    80004a16:	6402                	ld	s0,0(sp)
    80004a18:	0141                	addi	sp,sp,16
    80004a1a:	8082                	ret

0000000080004a1c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004a1c:	de010113          	addi	sp,sp,-544
    80004a20:	20113c23          	sd	ra,536(sp)
    80004a24:	20813823          	sd	s0,528(sp)
    80004a28:	20913423          	sd	s1,520(sp)
    80004a2c:	21213023          	sd	s2,512(sp)
    80004a30:	1400                	addi	s0,sp,544
    80004a32:	892a                	mv	s2,a0
    80004a34:	dea43823          	sd	a0,-528(s0)
    80004a38:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004a3c:	f0dfc0ef          	jal	80001948 <myproc>
    80004a40:	84aa                	mv	s1,a0

  begin_op();
    80004a42:	c62ff0ef          	jal	80003ea4 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004a46:	854a                	mv	a0,s2
    80004a48:	a7eff0ef          	jal	80003cc6 <namei>
    80004a4c:	cd21                	beqz	a0,80004aa4 <kexec+0x88>
    80004a4e:	fbd2                	sd	s4,496(sp)
    80004a50:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004a52:	9dbfe0ef          	jal	8000342c <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004a56:	04000713          	li	a4,64
    80004a5a:	4681                	li	a3,0
    80004a5c:	e5040613          	addi	a2,s0,-432
    80004a60:	4581                	li	a1,0
    80004a62:	8552                	mv	a0,s4
    80004a64:	da3fe0ef          	jal	80003806 <readi>
    80004a68:	04000793          	li	a5,64
    80004a6c:	00f51a63          	bne	a0,a5,80004a80 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004a70:	e5042703          	lw	a4,-432(s0)
    80004a74:	464c47b7          	lui	a5,0x464c4
    80004a78:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a7c:	02f70863          	beq	a4,a5,80004aac <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004a80:	8552                	mv	a0,s4
    80004a82:	bfffe0ef          	jal	80003680 <iunlockput>
    end_op();
    80004a86:	caaff0ef          	jal	80003f30 <end_op>
  }
  return -1;
    80004a8a:	557d                	li	a0,-1
    80004a8c:	7a5e                	ld	s4,496(sp)
}
    80004a8e:	21813083          	ld	ra,536(sp)
    80004a92:	21013403          	ld	s0,528(sp)
    80004a96:	20813483          	ld	s1,520(sp)
    80004a9a:	20013903          	ld	s2,512(sp)
    80004a9e:	22010113          	addi	sp,sp,544
    80004aa2:	8082                	ret
    end_op();
    80004aa4:	c8cff0ef          	jal	80003f30 <end_op>
    return -1;
    80004aa8:	557d                	li	a0,-1
    80004aaa:	b7d5                	j	80004a8e <kexec+0x72>
    80004aac:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004aae:	8526                	mv	a0,s1
    80004ab0:	f9ffc0ef          	jal	80001a4e <proc_pagetable>
    80004ab4:	8b2a                	mv	s6,a0
    80004ab6:	26050e63          	beqz	a0,80004d32 <kexec+0x316>
    80004aba:	ffce                	sd	s3,504(sp)
    80004abc:	f7d6                	sd	s5,488(sp)
    80004abe:	efde                	sd	s7,472(sp)
    80004ac0:	ebe2                	sd	s8,464(sp)
    80004ac2:	e7e6                	sd	s9,456(sp)
    80004ac4:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004ac6:	e8845783          	lhu	a5,-376(s0)
    80004aca:	14078263          	beqz	a5,80004c0e <kexec+0x1f2>
    80004ace:	ff6e                	sd	s11,440(sp)
    80004ad0:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ad4:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004ad6:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ad8:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004adc:	6c85                	lui	s9,0x1
    80004ade:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004ae2:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004ae6:	6a85                	lui	s5,0x1
    80004ae8:	a085                	j	80004b48 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004aea:	00003517          	auipc	a0,0x3
    80004aee:	ad650513          	addi	a0,a0,-1322 # 800075c0 <etext+0x5c0>
    80004af2:	d43fb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004af6:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004af8:	874a                	mv	a4,s2
    80004afa:	009b86bb          	addw	a3,s7,s1
    80004afe:	4581                	li	a1,0
    80004b00:	8552                	mv	a0,s4
    80004b02:	d05fe0ef          	jal	80003806 <readi>
    80004b06:	22a91a63          	bne	s2,a0,80004d3a <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004b0a:	009a84bb          	addw	s1,s5,s1
    80004b0e:	0334f263          	bgeu	s1,s3,80004b32 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004b12:	02049593          	slli	a1,s1,0x20
    80004b16:	9181                	srli	a1,a1,0x20
    80004b18:	95e2                	add	a1,a1,s8
    80004b1a:	855a                	mv	a0,s6
    80004b1c:	cfcfc0ef          	jal	80001018 <walkaddr>
    80004b20:	862a                	mv	a2,a0
    if (pa == 0)
    80004b22:	d561                	beqz	a0,80004aea <kexec+0xce>
    if (sz - i < PGSIZE)
    80004b24:	409987bb          	subw	a5,s3,s1
    80004b28:	893e                	mv	s2,a5
    80004b2a:	fcfcf6e3          	bgeu	s9,a5,80004af6 <kexec+0xda>
    80004b2e:	8956                	mv	s2,s5
    80004b30:	b7d9                	j	80004af6 <kexec+0xda>
    sz = sz1;
    80004b32:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004b36:	2d05                	addiw	s10,s10,1
    80004b38:	e0843783          	ld	a5,-504(s0)
    80004b3c:	0387869b          	addiw	a3,a5,56
    80004b40:	e8845783          	lhu	a5,-376(s0)
    80004b44:	06fd5d63          	bge	s10,a5,80004bbe <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004b48:	e0d43423          	sd	a3,-504(s0)
    80004b4c:	876e                	mv	a4,s11
    80004b4e:	e1840613          	addi	a2,s0,-488
    80004b52:	4581                	li	a1,0
    80004b54:	8552                	mv	a0,s4
    80004b56:	cb1fe0ef          	jal	80003806 <readi>
    80004b5a:	1db51e63          	bne	a0,s11,80004d36 <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004b5e:	e1842783          	lw	a5,-488(s0)
    80004b62:	4705                	li	a4,1
    80004b64:	fce799e3          	bne	a5,a4,80004b36 <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004b68:	e4043483          	ld	s1,-448(s0)
    80004b6c:	e3843783          	ld	a5,-456(s0)
    80004b70:	1ef4e363          	bltu	s1,a5,80004d56 <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004b74:	e2843783          	ld	a5,-472(s0)
    80004b78:	94be                	add	s1,s1,a5
    80004b7a:	1ef4e163          	bltu	s1,a5,80004d5c <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004b7e:	de843703          	ld	a4,-536(s0)
    80004b82:	8ff9                	and	a5,a5,a4
    80004b84:	1c079f63          	bnez	a5,80004d62 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004b88:	e1c42503          	lw	a0,-484(s0)
    80004b8c:	e71ff0ef          	jal	800049fc <flags2perm>
    80004b90:	86aa                	mv	a3,a0
    80004b92:	8626                	mv	a2,s1
    80004b94:	85ca                	mv	a1,s2
    80004b96:	855a                	mv	a0,s6
    80004b98:	f56fc0ef          	jal	800012ee <uvmalloc>
    80004b9c:	dea43c23          	sd	a0,-520(s0)
    80004ba0:	1c050463          	beqz	a0,80004d68 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ba4:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004ba8:	00098863          	beqz	s3,80004bb8 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004bac:	e2843c03          	ld	s8,-472(s0)
    80004bb0:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004bb4:	4481                	li	s1,0
    80004bb6:	bfb1                	j	80004b12 <kexec+0xf6>
    sz = sz1;
    80004bb8:	df843903          	ld	s2,-520(s0)
    80004bbc:	bfad                	j	80004b36 <kexec+0x11a>
    80004bbe:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004bc0:	8552                	mv	a0,s4
    80004bc2:	abffe0ef          	jal	80003680 <iunlockput>
  end_op();
    80004bc6:	b6aff0ef          	jal	80003f30 <end_op>
  p = myproc();
    80004bca:	d7ffc0ef          	jal	80001948 <myproc>
    80004bce:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004bd0:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004bd4:	6c05                	lui	s8,0x1
    80004bd6:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004bd8:	9c4a                	add	s8,s8,s2
    80004bda:	77fd                	lui	a5,0xfffff
    80004bdc:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004be0:	4691                	li	a3,4
    80004be2:	6609                	lui	a2,0x2
    80004be4:	9662                	add	a2,a2,s8
    80004be6:	85e2                	mv	a1,s8
    80004be8:	855a                	mv	a0,s6
    80004bea:	f04fc0ef          	jal	800012ee <uvmalloc>
    80004bee:	892a                	mv	s2,a0
    80004bf0:	e10d                	bnez	a0,80004c12 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004bf2:	85e2                	mv	a1,s8
    80004bf4:	855a                	mv	a0,s6
    80004bf6:	eddfc0ef          	jal	80001ad2 <proc_freepagetable>
  return -1;
    80004bfa:	557d                	li	a0,-1
    80004bfc:	79fe                	ld	s3,504(sp)
    80004bfe:	7a5e                	ld	s4,496(sp)
    80004c00:	7abe                	ld	s5,488(sp)
    80004c02:	7b1e                	ld	s6,480(sp)
    80004c04:	6bfe                	ld	s7,472(sp)
    80004c06:	6c5e                	ld	s8,464(sp)
    80004c08:	6cbe                	ld	s9,456(sp)
    80004c0a:	6d1e                	ld	s10,448(sp)
    80004c0c:	b549                	j	80004a8e <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c0e:	4901                	li	s2,0
    80004c10:	bf45                	j	80004bc0 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004c12:	75f9                	lui	a1,0xffffe
    80004c14:	95aa                	add	a1,a1,a0
    80004c16:	855a                	mv	a0,s6
    80004c18:	8a9fc0ef          	jal	800014c0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004c1c:	80090a13          	addi	s4,s2,-2048
    80004c20:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004c24:	e0043783          	ld	a5,-512(s0)
    80004c28:	6388                	ld	a0,0(a5)
    80004c2a:	c545                	beqz	a0,80004cd2 <kexec+0x2b6>
  sp = sz;
    80004c2c:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004c2e:	4481                	li	s1,0
    ustack[argc] = sp;
    80004c30:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004c34:	a3efc0ef          	jal	80000e72 <strlen>
    80004c38:	0015079b          	addiw	a5,a0,1
    80004c3c:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004c40:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004c44:	134c6563          	bltu	s8,s4,80004d6e <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004c48:	e0043d03          	ld	s10,-512(s0)
    80004c4c:	000d3c83          	ld	s9,0(s10)
    80004c50:	8566                	mv	a0,s9
    80004c52:	a20fc0ef          	jal	80000e72 <strlen>
    80004c56:	0015071b          	addiw	a4,a0,1
    80004c5a:	86e6                	mv	a3,s9
    80004c5c:	8662                	mv	a2,s8
    80004c5e:	85ca                	mv	a1,s2
    80004c60:	855a                	mv	a0,s6
    80004c62:	921fc0ef          	jal	80001582 <copyout>
    80004c66:	10054663          	bltz	a0,80004d72 <kexec+0x356>
    ustack[argc] = sp;
    80004c6a:	00349793          	slli	a5,s1,0x3
    80004c6e:	97de                	add	a5,a5,s7
    80004c70:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb738>
  for (argc = 0; argv[argc]; argc++) {
    80004c74:	0485                	addi	s1,s1,1
    80004c76:	008d0793          	addi	a5,s10,8
    80004c7a:	e0f43023          	sd	a5,-512(s0)
    80004c7e:	008d3503          	ld	a0,8(s10)
    80004c82:	f94d                	bnez	a0,80004c34 <kexec+0x218>
  ustack[argc] = 0;
    80004c84:	00349793          	slli	a5,s1,0x3
    80004c88:	f9078793          	addi	a5,a5,-112
    80004c8c:	97a2                	add	a5,a5,s0
    80004c8e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004c92:	00349713          	slli	a4,s1,0x3
    80004c96:	0721                	addi	a4,a4,8
    80004c98:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004c9c:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004ca0:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004ca2:	f54be8e3          	bltu	s7,s4,80004bf2 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004ca6:	e9040693          	addi	a3,s0,-368
    80004caa:	865e                	mv	a2,s7
    80004cac:	85ca                	mv	a1,s2
    80004cae:	855a                	mv	a0,s6
    80004cb0:	8d3fc0ef          	jal	80001582 <copyout>
    80004cb4:	f2054fe3          	bltz	a0,80004bf2 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004cb8:	0589b783          	ld	a5,88(s3)
    80004cbc:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004cc0:	df043783          	ld	a5,-528(s0)
    80004cc4:	0007c703          	lbu	a4,0(a5)
    80004cc8:	c30d                	beqz	a4,80004cea <kexec+0x2ce>
    80004cca:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004ccc:	02f00693          	li	a3,47
    80004cd0:	a801                	j	80004ce0 <kexec+0x2c4>
  sp = sz;
    80004cd2:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004cd4:	4481                	li	s1,0
    80004cd6:	b77d                	j	80004c84 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004cd8:	0785                	addi	a5,a5,1
    80004cda:	fff7c703          	lbu	a4,-1(a5)
    80004cde:	c711                	beqz	a4,80004cea <kexec+0x2ce>
    if (*s == '/')
    80004ce0:	fed71ce3          	bne	a4,a3,80004cd8 <kexec+0x2bc>
      last = s + 1;
    80004ce4:	def43823          	sd	a5,-528(s0)
    80004ce8:	bfc5                	j	80004cd8 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004cea:	4641                	li	a2,16
    80004cec:	df043583          	ld	a1,-528(s0)
    80004cf0:	15898513          	addi	a0,s3,344
    80004cf4:	948fc0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004cf8:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004cfc:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004d00:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004d04:	0589b783          	ld	a5,88(s3)
    80004d08:	e6843703          	ld	a4,-408(s0)
    80004d0c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004d0e:	0589b783          	ld	a5,88(s3)
    80004d12:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004d16:	85d6                	mv	a1,s5
    80004d18:	dbbfc0ef          	jal	80001ad2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004d1c:	0004851b          	sext.w	a0,s1
    80004d20:	79fe                	ld	s3,504(sp)
    80004d22:	7a5e                	ld	s4,496(sp)
    80004d24:	7abe                	ld	s5,488(sp)
    80004d26:	7b1e                	ld	s6,480(sp)
    80004d28:	6bfe                	ld	s7,472(sp)
    80004d2a:	6c5e                	ld	s8,464(sp)
    80004d2c:	6cbe                	ld	s9,456(sp)
    80004d2e:	6d1e                	ld	s10,448(sp)
    80004d30:	bbb9                	j	80004a8e <kexec+0x72>
    80004d32:	7b1e                	ld	s6,480(sp)
    80004d34:	b3b1                	j	80004a80 <kexec+0x64>
    80004d36:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004d3a:	df843583          	ld	a1,-520(s0)
    80004d3e:	855a                	mv	a0,s6
    80004d40:	d93fc0ef          	jal	80001ad2 <proc_freepagetable>
  if (ip) {
    80004d44:	79fe                	ld	s3,504(sp)
    80004d46:	7abe                	ld	s5,488(sp)
    80004d48:	7b1e                	ld	s6,480(sp)
    80004d4a:	6bfe                	ld	s7,472(sp)
    80004d4c:	6c5e                	ld	s8,464(sp)
    80004d4e:	6cbe                	ld	s9,456(sp)
    80004d50:	6d1e                	ld	s10,448(sp)
    80004d52:	7dfa                	ld	s11,440(sp)
    80004d54:	b335                	j	80004a80 <kexec+0x64>
    80004d56:	df243c23          	sd	s2,-520(s0)
    80004d5a:	b7c5                	j	80004d3a <kexec+0x31e>
    80004d5c:	df243c23          	sd	s2,-520(s0)
    80004d60:	bfe9                	j	80004d3a <kexec+0x31e>
    80004d62:	df243c23          	sd	s2,-520(s0)
    80004d66:	bfd1                	j	80004d3a <kexec+0x31e>
    80004d68:	df243c23          	sd	s2,-520(s0)
    80004d6c:	b7f9                	j	80004d3a <kexec+0x31e>
  sz = sz1;
    80004d6e:	8c4a                	mv	s8,s2
    80004d70:	b549                	j	80004bf2 <kexec+0x1d6>
    80004d72:	8c4a                	mv	s8,s2
    80004d74:	bdbd                	j	80004bf2 <kexec+0x1d6>

0000000080004d76 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004d76:	7179                	addi	sp,sp,-48
    80004d78:	f406                	sd	ra,40(sp)
    80004d7a:	f022                	sd	s0,32(sp)
    80004d7c:	ec26                	sd	s1,24(sp)
    80004d7e:	e84a                	sd	s2,16(sp)
    80004d80:	1800                	addi	s0,sp,48
    80004d82:	892e                	mv	s2,a1
    80004d84:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d86:	fdc40593          	addi	a1,s0,-36
    80004d8a:	c99fd0ef          	jal	80002a22 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004d8e:	fdc42703          	lw	a4,-36(s0)
    80004d92:	47bd                	li	a5,15
    80004d94:	02e7ea63          	bltu	a5,a4,80004dc8 <argfd+0x52>
    80004d98:	bb1fc0ef          	jal	80001948 <myproc>
    80004d9c:	fdc42703          	lw	a4,-36(s0)
    80004da0:	00371793          	slli	a5,a4,0x3
    80004da4:	0d078793          	addi	a5,a5,208
    80004da8:	953e                	add	a0,a0,a5
    80004daa:	611c                	ld	a5,0(a0)
    80004dac:	c385                	beqz	a5,80004dcc <argfd+0x56>
    return -1;
  if (pfd)
    80004dae:	00090463          	beqz	s2,80004db6 <argfd+0x40>
    *pfd = fd;
    80004db2:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004db6:	4501                	li	a0,0
  if (pf)
    80004db8:	c091                	beqz	s1,80004dbc <argfd+0x46>
    *pf = f;
    80004dba:	e09c                	sd	a5,0(s1)
}
    80004dbc:	70a2                	ld	ra,40(sp)
    80004dbe:	7402                	ld	s0,32(sp)
    80004dc0:	64e2                	ld	s1,24(sp)
    80004dc2:	6942                	ld	s2,16(sp)
    80004dc4:	6145                	addi	sp,sp,48
    80004dc6:	8082                	ret
    return -1;
    80004dc8:	557d                	li	a0,-1
    80004dca:	bfcd                	j	80004dbc <argfd+0x46>
    80004dcc:	557d                	li	a0,-1
    80004dce:	b7fd                	j	80004dbc <argfd+0x46>

0000000080004dd0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004dd0:	1101                	addi	sp,sp,-32
    80004dd2:	ec06                	sd	ra,24(sp)
    80004dd4:	e822                	sd	s0,16(sp)
    80004dd6:	e426                	sd	s1,8(sp)
    80004dd8:	1000                	addi	s0,sp,32
    80004dda:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004ddc:	b6dfc0ef          	jal	80001948 <myproc>
    80004de0:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004de2:	0d050793          	addi	a5,a0,208
    80004de6:	4501                	li	a0,0
    80004de8:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004dea:	6398                	ld	a4,0(a5)
    80004dec:	cb19                	beqz	a4,80004e02 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004dee:	2505                	addiw	a0,a0,1
    80004df0:	07a1                	addi	a5,a5,8
    80004df2:	fed51ce3          	bne	a0,a3,80004dea <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004df6:	557d                	li	a0,-1
}
    80004df8:	60e2                	ld	ra,24(sp)
    80004dfa:	6442                	ld	s0,16(sp)
    80004dfc:	64a2                	ld	s1,8(sp)
    80004dfe:	6105                	addi	sp,sp,32
    80004e00:	8082                	ret
      p->ofile[fd] = f;
    80004e02:	00351793          	slli	a5,a0,0x3
    80004e06:	0d078793          	addi	a5,a5,208
    80004e0a:	963e                	add	a2,a2,a5
    80004e0c:	e204                	sd	s1,0(a2)
      return fd;
    80004e0e:	b7ed                	j	80004df8 <fdalloc+0x28>

0000000080004e10 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004e10:	715d                	addi	sp,sp,-80
    80004e12:	e486                	sd	ra,72(sp)
    80004e14:	e0a2                	sd	s0,64(sp)
    80004e16:	fc26                	sd	s1,56(sp)
    80004e18:	f84a                	sd	s2,48(sp)
    80004e1a:	f052                	sd	s4,32(sp)
    80004e1c:	ec56                	sd	s5,24(sp)
    80004e1e:	e85a                	sd	s6,16(sp)
    80004e20:	0880                	addi	s0,sp,80
    80004e22:	8a2e                	mv	s4,a1
    80004e24:	8ab2                	mv	s5,a2
    80004e26:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004e28:	fb040593          	addi	a1,s0,-80
    80004e2c:	eb5fe0ef          	jal	80003ce0 <nameiparent>
    80004e30:	84aa                	mv	s1,a0
    80004e32:	12050f63          	beqz	a0,80004f70 <create+0x160>
    return 0;

  ilock(dp);
    80004e36:	df6fe0ef          	jal	8000342c <ilock>

  if (dp->nlink == 0) {
    80004e3a:	04a49783          	lh	a5,74(s1)
    80004e3e:	cbb9                	beqz	a5,80004e94 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004e40:	7761                	lui	a4,0xffff8
    80004e42:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd4739>
    80004e44:	97ba                	add	a5,a5,a4
    80004e46:	e781                	bnez	a5,80004e4e <create+0x3e>
    80004e48:	fffa0793          	addi	a5,s4,-1
    80004e4c:	cba9                	beqz	a5,80004e9e <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004e4e:	4601                	li	a2,0
    80004e50:	fb040593          	addi	a1,s0,-80
    80004e54:	8526                	mv	a0,s1
    80004e56:	bbffe0ef          	jal	80003a14 <dirlookup>
    80004e5a:	892a                	mv	s2,a0
    80004e5c:	c939                	beqz	a0,80004eb2 <create+0xa2>
    iunlockput(dp);
    80004e5e:	8526                	mv	a0,s1
    80004e60:	821fe0ef          	jal	80003680 <iunlockput>
    ilock(ip);
    80004e64:	854a                	mv	a0,s2
    80004e66:	dc6fe0ef          	jal	8000342c <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004e6a:	4789                	li	a5,2
    80004e6c:	02fa1e63          	bne	s4,a5,80004ea8 <create+0x98>
    80004e70:	04495783          	lhu	a5,68(s2)
    80004e74:	37f9                	addiw	a5,a5,-2
    80004e76:	17c2                	slli	a5,a5,0x30
    80004e78:	93c1                	srli	a5,a5,0x30
    80004e7a:	4705                	li	a4,1
    80004e7c:	02f76663          	bltu	a4,a5,80004ea8 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004e80:	854a                	mv	a0,s2
    80004e82:	60a6                	ld	ra,72(sp)
    80004e84:	6406                	ld	s0,64(sp)
    80004e86:	74e2                	ld	s1,56(sp)
    80004e88:	7942                	ld	s2,48(sp)
    80004e8a:	7a02                	ld	s4,32(sp)
    80004e8c:	6ae2                	ld	s5,24(sp)
    80004e8e:	6b42                	ld	s6,16(sp)
    80004e90:	6161                	addi	sp,sp,80
    80004e92:	8082                	ret
    iunlockput(dp);
    80004e94:	8526                	mv	a0,s1
    80004e96:	feafe0ef          	jal	80003680 <iunlockput>
    return 0;
    80004e9a:	4901                	li	s2,0
    80004e9c:	b7d5                	j	80004e80 <create+0x70>
    iunlockput(dp);
    80004e9e:	8526                	mv	a0,s1
    80004ea0:	fe0fe0ef          	jal	80003680 <iunlockput>
    return 0;
    80004ea4:	4901                	li	s2,0
    80004ea6:	bfe9                	j	80004e80 <create+0x70>
    iunlockput(ip);
    80004ea8:	854a                	mv	a0,s2
    80004eaa:	fd6fe0ef          	jal	80003680 <iunlockput>
    return 0;
    80004eae:	4901                	li	s2,0
    80004eb0:	bfc1                	j	80004e80 <create+0x70>
    80004eb2:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004eb4:	85d2                	mv	a1,s4
    80004eb6:	4088                	lw	a0,0(s1)
    80004eb8:	c04fe0ef          	jal	800032bc <ialloc>
    80004ebc:	89aa                	mv	s3,a0
    80004ebe:	cd1d                	beqz	a0,80004efc <create+0xec>
  ilock(ip);
    80004ec0:	d6cfe0ef          	jal	8000342c <ilock>
  ip->major = major;
    80004ec4:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004ec8:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004ecc:	4705                	li	a4,1
    80004ece:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004ed2:	854e                	mv	a0,s3
    80004ed4:	ca4fe0ef          	jal	80003378 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004ed8:	4705                	li	a4,1
    80004eda:	02ea0763          	beq	s4,a4,80004f08 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004ede:	0049a603          	lw	a2,4(s3)
    80004ee2:	fb040593          	addi	a1,s0,-80
    80004ee6:	8526                	mv	a0,s1
    80004ee8:	d35fe0ef          	jal	80003c1c <dirlink>
    80004eec:	06054563          	bltz	a0,80004f56 <create+0x146>
  iunlockput(dp);
    80004ef0:	8526                	mv	a0,s1
    80004ef2:	f8efe0ef          	jal	80003680 <iunlockput>
  return ip;
    80004ef6:	894e                	mv	s2,s3
    80004ef8:	79a2                	ld	s3,40(sp)
    80004efa:	b759                	j	80004e80 <create+0x70>
    iunlockput(dp);
    80004efc:	8526                	mv	a0,s1
    80004efe:	f82fe0ef          	jal	80003680 <iunlockput>
    return 0;
    80004f02:	894e                	mv	s2,s3
    80004f04:	79a2                	ld	s3,40(sp)
    80004f06:	bfad                	j	80004e80 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004f08:	0049a603          	lw	a2,4(s3)
    80004f0c:	00002597          	auipc	a1,0x2
    80004f10:	6d458593          	addi	a1,a1,1748 # 800075e0 <etext+0x5e0>
    80004f14:	854e                	mv	a0,s3
    80004f16:	d07fe0ef          	jal	80003c1c <dirlink>
    80004f1a:	02054e63          	bltz	a0,80004f56 <create+0x146>
    80004f1e:	40d0                	lw	a2,4(s1)
    80004f20:	00002597          	auipc	a1,0x2
    80004f24:	6c858593          	addi	a1,a1,1736 # 800075e8 <etext+0x5e8>
    80004f28:	854e                	mv	a0,s3
    80004f2a:	cf3fe0ef          	jal	80003c1c <dirlink>
    80004f2e:	02054463          	bltz	a0,80004f56 <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004f32:	0049a603          	lw	a2,4(s3)
    80004f36:	fb040593          	addi	a1,s0,-80
    80004f3a:	8526                	mv	a0,s1
    80004f3c:	ce1fe0ef          	jal	80003c1c <dirlink>
    80004f40:	00054b63          	bltz	a0,80004f56 <create+0x146>
    dp->nlink++; // for ".."
    80004f44:	04a4d783          	lhu	a5,74(s1)
    80004f48:	2785                	addiw	a5,a5,1
    80004f4a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f4e:	8526                	mv	a0,s1
    80004f50:	c28fe0ef          	jal	80003378 <iupdate>
    80004f54:	bf71                	j	80004ef0 <create+0xe0>
  ip->nlink = 0;
    80004f56:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004f5a:	854e                	mv	a0,s3
    80004f5c:	c1cfe0ef          	jal	80003378 <iupdate>
  iunlockput(ip);
    80004f60:	854e                	mv	a0,s3
    80004f62:	f1efe0ef          	jal	80003680 <iunlockput>
  iunlockput(dp);
    80004f66:	8526                	mv	a0,s1
    80004f68:	f18fe0ef          	jal	80003680 <iunlockput>
  return 0;
    80004f6c:	79a2                	ld	s3,40(sp)
    80004f6e:	bf09                	j	80004e80 <create+0x70>
    return 0;
    80004f70:	892a                	mv	s2,a0
    80004f72:	b739                	j	80004e80 <create+0x70>

0000000080004f74 <sys_dup>:
{
    80004f74:	7179                	addi	sp,sp,-48
    80004f76:	f406                	sd	ra,40(sp)
    80004f78:	f022                	sd	s0,32(sp)
    80004f7a:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004f7c:	fd840613          	addi	a2,s0,-40
    80004f80:	4581                	li	a1,0
    80004f82:	4501                	li	a0,0
    80004f84:	df3ff0ef          	jal	80004d76 <argfd>
    return -1;
    80004f88:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004f8a:	02054363          	bltz	a0,80004fb0 <sys_dup+0x3c>
    80004f8e:	ec26                	sd	s1,24(sp)
    80004f90:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004f92:	fd843483          	ld	s1,-40(s0)
    80004f96:	8526                	mv	a0,s1
    80004f98:	e39ff0ef          	jal	80004dd0 <fdalloc>
    80004f9c:	892a                	mv	s2,a0
    return -1;
    80004f9e:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004fa0:	00054d63          	bltz	a0,80004fba <sys_dup+0x46>
  filedup(f);
    80004fa4:	8526                	mv	a0,s1
    80004fa6:	b72ff0ef          	jal	80004318 <filedup>
  return fd;
    80004faa:	87ca                	mv	a5,s2
    80004fac:	64e2                	ld	s1,24(sp)
    80004fae:	6942                	ld	s2,16(sp)
}
    80004fb0:	853e                	mv	a0,a5
    80004fb2:	70a2                	ld	ra,40(sp)
    80004fb4:	7402                	ld	s0,32(sp)
    80004fb6:	6145                	addi	sp,sp,48
    80004fb8:	8082                	ret
    80004fba:	64e2                	ld	s1,24(sp)
    80004fbc:	6942                	ld	s2,16(sp)
    80004fbe:	bfcd                	j	80004fb0 <sys_dup+0x3c>

0000000080004fc0 <sys_read>:
{
    80004fc0:	7179                	addi	sp,sp,-48
    80004fc2:	f406                	sd	ra,40(sp)
    80004fc4:	f022                	sd	s0,32(sp)
    80004fc6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fc8:	fd840593          	addi	a1,s0,-40
    80004fcc:	4505                	li	a0,1
    80004fce:	a71fd0ef          	jal	80002a3e <argaddr>
  argint(2, &n);
    80004fd2:	fe440593          	addi	a1,s0,-28
    80004fd6:	4509                	li	a0,2
    80004fd8:	a4bfd0ef          	jal	80002a22 <argint>
  if (argfd(0, 0, &f) < 0)
    80004fdc:	fe840613          	addi	a2,s0,-24
    80004fe0:	4581                	li	a1,0
    80004fe2:	4501                	li	a0,0
    80004fe4:	d93ff0ef          	jal	80004d76 <argfd>
    80004fe8:	87aa                	mv	a5,a0
    return -1;
    80004fea:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004fec:	0007ca63          	bltz	a5,80005000 <sys_read+0x40>
  return fileread(f, p, n);
    80004ff0:	fe442603          	lw	a2,-28(s0)
    80004ff4:	fd843583          	ld	a1,-40(s0)
    80004ff8:	fe843503          	ld	a0,-24(s0)
    80004ffc:	c94ff0ef          	jal	80004490 <fileread>
}
    80005000:	70a2                	ld	ra,40(sp)
    80005002:	7402                	ld	s0,32(sp)
    80005004:	6145                	addi	sp,sp,48
    80005006:	8082                	ret

0000000080005008 <sys_write>:
{
    80005008:	7179                	addi	sp,sp,-48
    8000500a:	f406                	sd	ra,40(sp)
    8000500c:	f022                	sd	s0,32(sp)
    8000500e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005010:	fd840593          	addi	a1,s0,-40
    80005014:	4505                	li	a0,1
    80005016:	a29fd0ef          	jal	80002a3e <argaddr>
  argint(2, &n);
    8000501a:	fe440593          	addi	a1,s0,-28
    8000501e:	4509                	li	a0,2
    80005020:	a03fd0ef          	jal	80002a22 <argint>
  if (argfd(0, 0, &f) < 0)
    80005024:	fe840613          	addi	a2,s0,-24
    80005028:	4581                	li	a1,0
    8000502a:	4501                	li	a0,0
    8000502c:	d4bff0ef          	jal	80004d76 <argfd>
    80005030:	87aa                	mv	a5,a0
    return -1;
    80005032:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005034:	0007ca63          	bltz	a5,80005048 <sys_write+0x40>
  return filewrite(f, p, n);
    80005038:	fe442603          	lw	a2,-28(s0)
    8000503c:	fd843583          	ld	a1,-40(s0)
    80005040:	fe843503          	ld	a0,-24(s0)
    80005044:	d1aff0ef          	jal	8000455e <filewrite>
}
    80005048:	70a2                	ld	ra,40(sp)
    8000504a:	7402                	ld	s0,32(sp)
    8000504c:	6145                	addi	sp,sp,48
    8000504e:	8082                	ret

0000000080005050 <sys_close>:
{
    80005050:	1101                	addi	sp,sp,-32
    80005052:	ec06                	sd	ra,24(sp)
    80005054:	e822                	sd	s0,16(sp)
    80005056:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80005058:	fe040613          	addi	a2,s0,-32
    8000505c:	fec40593          	addi	a1,s0,-20
    80005060:	4501                	li	a0,0
    80005062:	d15ff0ef          	jal	80004d76 <argfd>
    return -1;
    80005066:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80005068:	02054163          	bltz	a0,8000508a <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    8000506c:	8ddfc0ef          	jal	80001948 <myproc>
    80005070:	fec42783          	lw	a5,-20(s0)
    80005074:	078e                	slli	a5,a5,0x3
    80005076:	0d078793          	addi	a5,a5,208
    8000507a:	953e                	add	a0,a0,a5
    8000507c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005080:	fe043503          	ld	a0,-32(s0)
    80005084:	adaff0ef          	jal	8000435e <fileclose>
  return 0;
    80005088:	4781                	li	a5,0
}
    8000508a:	853e                	mv	a0,a5
    8000508c:	60e2                	ld	ra,24(sp)
    8000508e:	6442                	ld	s0,16(sp)
    80005090:	6105                	addi	sp,sp,32
    80005092:	8082                	ret

0000000080005094 <sys_fstat>:
{
    80005094:	1101                	addi	sp,sp,-32
    80005096:	ec06                	sd	ra,24(sp)
    80005098:	e822                	sd	s0,16(sp)
    8000509a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000509c:	fe040593          	addi	a1,s0,-32
    800050a0:	4505                	li	a0,1
    800050a2:	99dfd0ef          	jal	80002a3e <argaddr>
  if (argfd(0, 0, &f) < 0)
    800050a6:	fe840613          	addi	a2,s0,-24
    800050aa:	4581                	li	a1,0
    800050ac:	4501                	li	a0,0
    800050ae:	cc9ff0ef          	jal	80004d76 <argfd>
    800050b2:	87aa                	mv	a5,a0
    return -1;
    800050b4:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800050b6:	0007c863          	bltz	a5,800050c6 <sys_fstat+0x32>
  return filestat(f, st);
    800050ba:	fe043583          	ld	a1,-32(s0)
    800050be:	fe843503          	ld	a0,-24(s0)
    800050c2:	b5eff0ef          	jal	80004420 <filestat>
}
    800050c6:	60e2                	ld	ra,24(sp)
    800050c8:	6442                	ld	s0,16(sp)
    800050ca:	6105                	addi	sp,sp,32
    800050cc:	8082                	ret

00000000800050ce <sys_link>:
{
    800050ce:	7169                	addi	sp,sp,-304
    800050d0:	f606                	sd	ra,296(sp)
    800050d2:	f222                	sd	s0,288(sp)
    800050d4:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050d6:	08000613          	li	a2,128
    800050da:	ed040593          	addi	a1,s0,-304
    800050de:	4501                	li	a0,0
    800050e0:	97bfd0ef          	jal	80002a5a <argstr>
    return -1;
    800050e4:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050e6:	10054163          	bltz	a0,800051e8 <sys_link+0x11a>
    800050ea:	08000613          	li	a2,128
    800050ee:	f5040593          	addi	a1,s0,-176
    800050f2:	4505                	li	a0,1
    800050f4:	967fd0ef          	jal	80002a5a <argstr>
    return -1;
    800050f8:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050fa:	0e054763          	bltz	a0,800051e8 <sys_link+0x11a>
    800050fe:	ee26                	sd	s1,280(sp)
  begin_op();
    80005100:	da5fe0ef          	jal	80003ea4 <begin_op>
  if ((ip = namei(old)) == 0) {
    80005104:	ed040513          	addi	a0,s0,-304
    80005108:	bbffe0ef          	jal	80003cc6 <namei>
    8000510c:	84aa                	mv	s1,a0
    8000510e:	cd35                	beqz	a0,8000518a <sys_link+0xbc>
  ilock(ip);
    80005110:	b1cfe0ef          	jal	8000342c <ilock>
  if (ip->type == T_DIR) {
    80005114:	04449703          	lh	a4,68(s1)
    80005118:	4785                	li	a5,1
    8000511a:	06f70d63          	beq	a4,a5,80005194 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    8000511e:	04a49783          	lh	a5,74(s1)
    80005122:	6721                	lui	a4,0x8
    80005124:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80005126:	06e78f63          	beq	a5,a4,800051a4 <sys_link+0xd6>
    8000512a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000512c:	2785                	addiw	a5,a5,1
    8000512e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005132:	8526                	mv	a0,s1
    80005134:	a44fe0ef          	jal	80003378 <iupdate>
  iunlock(ip);
    80005138:	8526                	mv	a0,s1
    8000513a:	ba0fe0ef          	jal	800034da <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    8000513e:	fd040593          	addi	a1,s0,-48
    80005142:	f5040513          	addi	a0,s0,-176
    80005146:	b9bfe0ef          	jal	80003ce0 <nameiparent>
    8000514a:	892a                	mv	s2,a0
    8000514c:	c93d                	beqz	a0,800051c2 <sys_link+0xf4>
  ilock(dp);
    8000514e:	adefe0ef          	jal	8000342c <ilock>
  if (dp->nlink == 0) {
    80005152:	04a91783          	lh	a5,74(s2)
    80005156:	cfb9                	beqz	a5,800051b4 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80005158:	854a                	mv	a0,s2
    8000515a:	00092703          	lw	a4,0(s2)
    8000515e:	409c                	lw	a5,0(s1)
    80005160:	04f71e63          	bne	a4,a5,800051bc <sys_link+0xee>
    80005164:	40d0                	lw	a2,4(s1)
    80005166:	fd040593          	addi	a1,s0,-48
    8000516a:	ab3fe0ef          	jal	80003c1c <dirlink>
    8000516e:	04054763          	bltz	a0,800051bc <sys_link+0xee>
  iunlockput(dp);
    80005172:	854a                	mv	a0,s2
    80005174:	d0cfe0ef          	jal	80003680 <iunlockput>
  iput(ip);
    80005178:	8526                	mv	a0,s1
    8000517a:	c34fe0ef          	jal	800035ae <iput>
  end_op();
    8000517e:	db3fe0ef          	jal	80003f30 <end_op>
  return 0;
    80005182:	4781                	li	a5,0
    80005184:	64f2                	ld	s1,280(sp)
    80005186:	6952                	ld	s2,272(sp)
    80005188:	a085                	j	800051e8 <sys_link+0x11a>
    end_op();
    8000518a:	da7fe0ef          	jal	80003f30 <end_op>
    return -1;
    8000518e:	57fd                	li	a5,-1
    80005190:	64f2                	ld	s1,280(sp)
    80005192:	a899                	j	800051e8 <sys_link+0x11a>
    iunlockput(ip);
    80005194:	8526                	mv	a0,s1
    80005196:	ceafe0ef          	jal	80003680 <iunlockput>
    end_op();
    8000519a:	d97fe0ef          	jal	80003f30 <end_op>
    return -1;
    8000519e:	57fd                	li	a5,-1
    800051a0:	64f2                	ld	s1,280(sp)
    800051a2:	a099                	j	800051e8 <sys_link+0x11a>
    iunlockput(ip);
    800051a4:	8526                	mv	a0,s1
    800051a6:	cdafe0ef          	jal	80003680 <iunlockput>
    end_op();
    800051aa:	d87fe0ef          	jal	80003f30 <end_op>
    return -1;
    800051ae:	57fd                	li	a5,-1
    800051b0:	64f2                	ld	s1,280(sp)
    800051b2:	a81d                	j	800051e8 <sys_link+0x11a>
    iunlockput(dp);
    800051b4:	854a                	mv	a0,s2
    800051b6:	ccafe0ef          	jal	80003680 <iunlockput>
    goto bad;
    800051ba:	a021                	j	800051c2 <sys_link+0xf4>
    iunlockput(dp);
    800051bc:	854a                	mv	a0,s2
    800051be:	cc2fe0ef          	jal	80003680 <iunlockput>
  ilock(ip);
    800051c2:	8526                	mv	a0,s1
    800051c4:	a68fe0ef          	jal	8000342c <ilock>
  ip->nlink--;
    800051c8:	04a4d783          	lhu	a5,74(s1)
    800051cc:	37fd                	addiw	a5,a5,-1
    800051ce:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800051d2:	8526                	mv	a0,s1
    800051d4:	9a4fe0ef          	jal	80003378 <iupdate>
  iunlockput(ip);
    800051d8:	8526                	mv	a0,s1
    800051da:	ca6fe0ef          	jal	80003680 <iunlockput>
  end_op();
    800051de:	d53fe0ef          	jal	80003f30 <end_op>
  return -1;
    800051e2:	57fd                	li	a5,-1
    800051e4:	64f2                	ld	s1,280(sp)
    800051e6:	6952                	ld	s2,272(sp)
}
    800051e8:	853e                	mv	a0,a5
    800051ea:	70b2                	ld	ra,296(sp)
    800051ec:	7412                	ld	s0,288(sp)
    800051ee:	6155                	addi	sp,sp,304
    800051f0:	8082                	ret

00000000800051f2 <sys_unlink>:
{
    800051f2:	7151                	addi	sp,sp,-240
    800051f4:	f586                	sd	ra,232(sp)
    800051f6:	f1a2                	sd	s0,224(sp)
    800051f8:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    800051fa:	08000613          	li	a2,128
    800051fe:	f3040593          	addi	a1,s0,-208
    80005202:	4501                	li	a0,0
    80005204:	857fd0ef          	jal	80002a5a <argstr>
    80005208:	14054d63          	bltz	a0,80005362 <sys_unlink+0x170>
    8000520c:	eda6                	sd	s1,216(sp)
  begin_op();
    8000520e:	c97fe0ef          	jal	80003ea4 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80005212:	fb040593          	addi	a1,s0,-80
    80005216:	f3040513          	addi	a0,s0,-208
    8000521a:	ac7fe0ef          	jal	80003ce0 <nameiparent>
    8000521e:	84aa                	mv	s1,a0
    80005220:	c955                	beqz	a0,800052d4 <sys_unlink+0xe2>
  ilock(dp);
    80005222:	a0afe0ef          	jal	8000342c <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005226:	00002597          	auipc	a1,0x2
    8000522a:	3ba58593          	addi	a1,a1,954 # 800075e0 <etext+0x5e0>
    8000522e:	fb040513          	addi	a0,s0,-80
    80005232:	fccfe0ef          	jal	800039fe <namecmp>
    80005236:	10050b63          	beqz	a0,8000534c <sys_unlink+0x15a>
    8000523a:	00002597          	auipc	a1,0x2
    8000523e:	3ae58593          	addi	a1,a1,942 # 800075e8 <etext+0x5e8>
    80005242:	fb040513          	addi	a0,s0,-80
    80005246:	fb8fe0ef          	jal	800039fe <namecmp>
    8000524a:	10050163          	beqz	a0,8000534c <sys_unlink+0x15a>
    8000524e:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005250:	f2c40613          	addi	a2,s0,-212
    80005254:	fb040593          	addi	a1,s0,-80
    80005258:	8526                	mv	a0,s1
    8000525a:	fbafe0ef          	jal	80003a14 <dirlookup>
    8000525e:	892a                	mv	s2,a0
    80005260:	0e050563          	beqz	a0,8000534a <sys_unlink+0x158>
    80005264:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005266:	9c6fe0ef          	jal	8000342c <ilock>
  if (ip->nlink < 1)
    8000526a:	04a91783          	lh	a5,74(s2)
    8000526e:	06f05863          	blez	a5,800052de <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    80005272:	04491703          	lh	a4,68(s2)
    80005276:	4785                	li	a5,1
    80005278:	06f70963          	beq	a4,a5,800052ea <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    8000527c:	fc040993          	addi	s3,s0,-64
    80005280:	4641                	li	a2,16
    80005282:	4581                	li	a1,0
    80005284:	854e                	mv	a0,s3
    80005286:	a63fb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000528a:	4741                	li	a4,16
    8000528c:	f2c42683          	lw	a3,-212(s0)
    80005290:	864e                	mv	a2,s3
    80005292:	4581                	li	a1,0
    80005294:	8526                	mv	a0,s1
    80005296:	e62fe0ef          	jal	800038f8 <writei>
    8000529a:	47c1                	li	a5,16
    8000529c:	08f51863          	bne	a0,a5,8000532c <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    800052a0:	04491703          	lh	a4,68(s2)
    800052a4:	4785                	li	a5,1
    800052a6:	08f70963          	beq	a4,a5,80005338 <sys_unlink+0x146>
  iunlockput(dp);
    800052aa:	8526                	mv	a0,s1
    800052ac:	bd4fe0ef          	jal	80003680 <iunlockput>
  ip->nlink--;
    800052b0:	04a95783          	lhu	a5,74(s2)
    800052b4:	37fd                	addiw	a5,a5,-1
    800052b6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800052ba:	854a                	mv	a0,s2
    800052bc:	8bcfe0ef          	jal	80003378 <iupdate>
  iunlockput(ip);
    800052c0:	854a                	mv	a0,s2
    800052c2:	bbefe0ef          	jal	80003680 <iunlockput>
  end_op();
    800052c6:	c6bfe0ef          	jal	80003f30 <end_op>
  return 0;
    800052ca:	4501                	li	a0,0
    800052cc:	64ee                	ld	s1,216(sp)
    800052ce:	694e                	ld	s2,208(sp)
    800052d0:	69ae                	ld	s3,200(sp)
    800052d2:	a061                	j	8000535a <sys_unlink+0x168>
    end_op();
    800052d4:	c5dfe0ef          	jal	80003f30 <end_op>
    return -1;
    800052d8:	557d                	li	a0,-1
    800052da:	64ee                	ld	s1,216(sp)
    800052dc:	a8bd                	j	8000535a <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800052de:	00002517          	auipc	a0,0x2
    800052e2:	31250513          	addi	a0,a0,786 # 800075f0 <etext+0x5f0>
    800052e6:	d4efb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800052ea:	04c92703          	lw	a4,76(s2)
    800052ee:	02000793          	li	a5,32
    800052f2:	f8e7f5e3          	bgeu	a5,a4,8000527c <sys_unlink+0x8a>
    800052f6:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800052f8:	4741                	li	a4,16
    800052fa:	86ce                	mv	a3,s3
    800052fc:	f1840613          	addi	a2,s0,-232
    80005300:	4581                	li	a1,0
    80005302:	854a                	mv	a0,s2
    80005304:	d02fe0ef          	jal	80003806 <readi>
    80005308:	47c1                	li	a5,16
    8000530a:	00f51b63          	bne	a0,a5,80005320 <sys_unlink+0x12e>
    if (de.inum != 0)
    8000530e:	f1845783          	lhu	a5,-232(s0)
    80005312:	ebb1                	bnez	a5,80005366 <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005314:	29c1                	addiw	s3,s3,16
    80005316:	04c92783          	lw	a5,76(s2)
    8000531a:	fcf9efe3          	bltu	s3,a5,800052f8 <sys_unlink+0x106>
    8000531e:	bfb9                	j	8000527c <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005320:	00002517          	auipc	a0,0x2
    80005324:	2e850513          	addi	a0,a0,744 # 80007608 <etext+0x608>
    80005328:	d0cfb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    8000532c:	00002517          	auipc	a0,0x2
    80005330:	2f450513          	addi	a0,a0,756 # 80007620 <etext+0x620>
    80005334:	d00fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    80005338:	04a4d783          	lhu	a5,74(s1)
    8000533c:	37fd                	addiw	a5,a5,-1
    8000533e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005342:	8526                	mv	a0,s1
    80005344:	834fe0ef          	jal	80003378 <iupdate>
    80005348:	b78d                	j	800052aa <sys_unlink+0xb8>
    8000534a:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000534c:	8526                	mv	a0,s1
    8000534e:	b32fe0ef          	jal	80003680 <iunlockput>
  end_op();
    80005352:	bdffe0ef          	jal	80003f30 <end_op>
  return -1;
    80005356:	557d                	li	a0,-1
    80005358:	64ee                	ld	s1,216(sp)
}
    8000535a:	70ae                	ld	ra,232(sp)
    8000535c:	740e                	ld	s0,224(sp)
    8000535e:	616d                	addi	sp,sp,240
    80005360:	8082                	ret
    return -1;
    80005362:	557d                	li	a0,-1
    80005364:	bfdd                	j	8000535a <sys_unlink+0x168>
    iunlockput(ip);
    80005366:	854a                	mv	a0,s2
    80005368:	b18fe0ef          	jal	80003680 <iunlockput>
    goto bad;
    8000536c:	694e                	ld	s2,208(sp)
    8000536e:	69ae                	ld	s3,200(sp)
    80005370:	bff1                	j	8000534c <sys_unlink+0x15a>

0000000080005372 <sys_open>:

uint64
sys_open(void)
{
    80005372:	7131                	addi	sp,sp,-192
    80005374:	fd06                	sd	ra,184(sp)
    80005376:	f922                	sd	s0,176(sp)
    80005378:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000537a:	f4c40593          	addi	a1,s0,-180
    8000537e:	4505                	li	a0,1
    80005380:	ea2fd0ef          	jal	80002a22 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005384:	08000613          	li	a2,128
    80005388:	f5040593          	addi	a1,s0,-176
    8000538c:	4501                	li	a0,0
    8000538e:	eccfd0ef          	jal	80002a5a <argstr>
    80005392:	87aa                	mv	a5,a0
    return -1;
    80005394:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005396:	0a07c363          	bltz	a5,8000543c <sys_open+0xca>
    8000539a:	f526                	sd	s1,168(sp)

  begin_op();
    8000539c:	b09fe0ef          	jal	80003ea4 <begin_op>

  if (omode & O_CREATE) {
    800053a0:	f4c42783          	lw	a5,-180(s0)
    800053a4:	2007f793          	andi	a5,a5,512
    800053a8:	c3dd                	beqz	a5,8000544e <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800053aa:	4681                	li	a3,0
    800053ac:	4601                	li	a2,0
    800053ae:	4589                	li	a1,2
    800053b0:	f5040513          	addi	a0,s0,-176
    800053b4:	a5dff0ef          	jal	80004e10 <create>
    800053b8:	84aa                	mv	s1,a0
    if (ip == 0) {
    800053ba:	c549                	beqz	a0,80005444 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    800053bc:	04449703          	lh	a4,68(s1)
    800053c0:	478d                	li	a5,3
    800053c2:	00f71763          	bne	a4,a5,800053d0 <sys_open+0x5e>
    800053c6:	0464d703          	lhu	a4,70(s1)
    800053ca:	47a5                	li	a5,9
    800053cc:	0ae7ee63          	bltu	a5,a4,80005488 <sys_open+0x116>
    800053d0:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    800053d2:	ee9fe0ef          	jal	800042ba <filealloc>
    800053d6:	892a                	mv	s2,a0
    800053d8:	c561                	beqz	a0,800054a0 <sys_open+0x12e>
    800053da:	ed4e                	sd	s3,152(sp)
    800053dc:	9f5ff0ef          	jal	80004dd0 <fdalloc>
    800053e0:	89aa                	mv	s3,a0
    800053e2:	0a054b63          	bltz	a0,80005498 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    800053e6:	04449703          	lh	a4,68(s1)
    800053ea:	478d                	li	a5,3
    800053ec:	0cf70363          	beq	a4,a5,800054b2 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800053f0:	4789                	li	a5,2
    800053f2:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800053f6:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800053fa:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800053fe:	f4c42783          	lw	a5,-180(s0)
    80005402:	0017f713          	andi	a4,a5,1
    80005406:	00174713          	xori	a4,a4,1
    8000540a:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000540e:	0037f713          	andi	a4,a5,3
    80005412:	00e03733          	snez	a4,a4
    80005416:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    8000541a:	4007f793          	andi	a5,a5,1024
    8000541e:	c791                	beqz	a5,8000542a <sys_open+0xb8>
    80005420:	04449703          	lh	a4,68(s1)
    80005424:	4789                	li	a5,2
    80005426:	08f70d63          	beq	a4,a5,800054c0 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    8000542a:	8526                	mv	a0,s1
    8000542c:	8aefe0ef          	jal	800034da <iunlock>
  end_op();
    80005430:	b01fe0ef          	jal	80003f30 <end_op>

  return fd;
    80005434:	854e                	mv	a0,s3
    80005436:	74aa                	ld	s1,168(sp)
    80005438:	790a                	ld	s2,160(sp)
    8000543a:	69ea                	ld	s3,152(sp)
}
    8000543c:	70ea                	ld	ra,184(sp)
    8000543e:	744a                	ld	s0,176(sp)
    80005440:	6129                	addi	sp,sp,192
    80005442:	8082                	ret
      end_op();
    80005444:	aedfe0ef          	jal	80003f30 <end_op>
      return -1;
    80005448:	557d                	li	a0,-1
    8000544a:	74aa                	ld	s1,168(sp)
    8000544c:	bfc5                	j	8000543c <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    8000544e:	f5040513          	addi	a0,s0,-176
    80005452:	875fe0ef          	jal	80003cc6 <namei>
    80005456:	84aa                	mv	s1,a0
    80005458:	c11d                	beqz	a0,8000547e <sys_open+0x10c>
    ilock(ip);
    8000545a:	fd3fd0ef          	jal	8000342c <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    8000545e:	04449703          	lh	a4,68(s1)
    80005462:	4785                	li	a5,1
    80005464:	f4f71ce3          	bne	a4,a5,800053bc <sys_open+0x4a>
    80005468:	f4c42783          	lw	a5,-180(s0)
    8000546c:	d3b5                	beqz	a5,800053d0 <sys_open+0x5e>
      iunlockput(ip);
    8000546e:	8526                	mv	a0,s1
    80005470:	a10fe0ef          	jal	80003680 <iunlockput>
      end_op();
    80005474:	abdfe0ef          	jal	80003f30 <end_op>
      return -1;
    80005478:	557d                	li	a0,-1
    8000547a:	74aa                	ld	s1,168(sp)
    8000547c:	b7c1                	j	8000543c <sys_open+0xca>
      end_op();
    8000547e:	ab3fe0ef          	jal	80003f30 <end_op>
      return -1;
    80005482:	557d                	li	a0,-1
    80005484:	74aa                	ld	s1,168(sp)
    80005486:	bf5d                	j	8000543c <sys_open+0xca>
    iunlockput(ip);
    80005488:	8526                	mv	a0,s1
    8000548a:	9f6fe0ef          	jal	80003680 <iunlockput>
    end_op();
    8000548e:	aa3fe0ef          	jal	80003f30 <end_op>
    return -1;
    80005492:	557d                	li	a0,-1
    80005494:	74aa                	ld	s1,168(sp)
    80005496:	b75d                	j	8000543c <sys_open+0xca>
      fileclose(f);
    80005498:	854a                	mv	a0,s2
    8000549a:	ec5fe0ef          	jal	8000435e <fileclose>
    8000549e:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800054a0:	8526                	mv	a0,s1
    800054a2:	9defe0ef          	jal	80003680 <iunlockput>
    end_op();
    800054a6:	a8bfe0ef          	jal	80003f30 <end_op>
    return -1;
    800054aa:	557d                	li	a0,-1
    800054ac:	74aa                	ld	s1,168(sp)
    800054ae:	790a                	ld	s2,160(sp)
    800054b0:	b771                	j	8000543c <sys_open+0xca>
    f->type = FD_DEVICE;
    800054b2:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800054b6:	04649783          	lh	a5,70(s1)
    800054ba:	02f91223          	sh	a5,36(s2)
    800054be:	bf35                	j	800053fa <sys_open+0x88>
    itrunc(ip);
    800054c0:	8526                	mv	a0,s1
    800054c2:	858fe0ef          	jal	8000351a <itrunc>
    800054c6:	b795                	j	8000542a <sys_open+0xb8>

00000000800054c8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800054c8:	7175                	addi	sp,sp,-144
    800054ca:	e506                	sd	ra,136(sp)
    800054cc:	e122                	sd	s0,128(sp)
    800054ce:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800054d0:	9d5fe0ef          	jal	80003ea4 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    800054d4:	08000613          	li	a2,128
    800054d8:	f7040593          	addi	a1,s0,-144
    800054dc:	4501                	li	a0,0
    800054de:	d7cfd0ef          	jal	80002a5a <argstr>
    800054e2:	02054363          	bltz	a0,80005508 <sys_mkdir+0x40>
    800054e6:	4681                	li	a3,0
    800054e8:	4601                	li	a2,0
    800054ea:	4585                	li	a1,1
    800054ec:	f7040513          	addi	a0,s0,-144
    800054f0:	921ff0ef          	jal	80004e10 <create>
    800054f4:	c911                	beqz	a0,80005508 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054f6:	98afe0ef          	jal	80003680 <iunlockput>
  end_op();
    800054fa:	a37fe0ef          	jal	80003f30 <end_op>
  return 0;
    800054fe:	4501                	li	a0,0
}
    80005500:	60aa                	ld	ra,136(sp)
    80005502:	640a                	ld	s0,128(sp)
    80005504:	6149                	addi	sp,sp,144
    80005506:	8082                	ret
    end_op();
    80005508:	a29fe0ef          	jal	80003f30 <end_op>
    return -1;
    8000550c:	557d                	li	a0,-1
    8000550e:	bfcd                	j	80005500 <sys_mkdir+0x38>

0000000080005510 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005510:	7135                	addi	sp,sp,-160
    80005512:	ed06                	sd	ra,152(sp)
    80005514:	e922                	sd	s0,144(sp)
    80005516:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005518:	98dfe0ef          	jal	80003ea4 <begin_op>
  argint(1, &major);
    8000551c:	f6c40593          	addi	a1,s0,-148
    80005520:	4505                	li	a0,1
    80005522:	d00fd0ef          	jal	80002a22 <argint>
  argint(2, &minor);
    80005526:	f6840593          	addi	a1,s0,-152
    8000552a:	4509                	li	a0,2
    8000552c:	cf6fd0ef          	jal	80002a22 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005530:	08000613          	li	a2,128
    80005534:	f7040593          	addi	a1,s0,-144
    80005538:	4501                	li	a0,0
    8000553a:	d20fd0ef          	jal	80002a5a <argstr>
    8000553e:	02054563          	bltz	a0,80005568 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005542:	f6841683          	lh	a3,-152(s0)
    80005546:	f6c41603          	lh	a2,-148(s0)
    8000554a:	458d                	li	a1,3
    8000554c:	f7040513          	addi	a0,s0,-144
    80005550:	8c1ff0ef          	jal	80004e10 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005554:	c911                	beqz	a0,80005568 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005556:	92afe0ef          	jal	80003680 <iunlockput>
  end_op();
    8000555a:	9d7fe0ef          	jal	80003f30 <end_op>
  return 0;
    8000555e:	4501                	li	a0,0
}
    80005560:	60ea                	ld	ra,152(sp)
    80005562:	644a                	ld	s0,144(sp)
    80005564:	610d                	addi	sp,sp,160
    80005566:	8082                	ret
    end_op();
    80005568:	9c9fe0ef          	jal	80003f30 <end_op>
    return -1;
    8000556c:	557d                	li	a0,-1
    8000556e:	bfcd                	j	80005560 <sys_mknod+0x50>

0000000080005570 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005570:	7135                	addi	sp,sp,-160
    80005572:	ed06                	sd	ra,152(sp)
    80005574:	e922                	sd	s0,144(sp)
    80005576:	e14a                	sd	s2,128(sp)
    80005578:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000557a:	bcefc0ef          	jal	80001948 <myproc>
    8000557e:	892a                	mv	s2,a0

  begin_op();
    80005580:	925fe0ef          	jal	80003ea4 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    80005584:	08000613          	li	a2,128
    80005588:	f6040593          	addi	a1,s0,-160
    8000558c:	4501                	li	a0,0
    8000558e:	cccfd0ef          	jal	80002a5a <argstr>
    80005592:	04054363          	bltz	a0,800055d8 <sys_chdir+0x68>
    80005596:	e526                	sd	s1,136(sp)
    80005598:	f6040513          	addi	a0,s0,-160
    8000559c:	f2afe0ef          	jal	80003cc6 <namei>
    800055a0:	84aa                	mv	s1,a0
    800055a2:	c915                	beqz	a0,800055d6 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800055a4:	e89fd0ef          	jal	8000342c <ilock>
  if (ip->type != T_DIR) {
    800055a8:	04449703          	lh	a4,68(s1)
    800055ac:	4785                	li	a5,1
    800055ae:	02f71963          	bne	a4,a5,800055e0 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800055b2:	8526                	mv	a0,s1
    800055b4:	f27fd0ef          	jal	800034da <iunlock>
  iput(p->cwd);
    800055b8:	15093503          	ld	a0,336(s2)
    800055bc:	ff3fd0ef          	jal	800035ae <iput>
  end_op();
    800055c0:	971fe0ef          	jal	80003f30 <end_op>
  p->cwd = ip;
    800055c4:	14993823          	sd	s1,336(s2)
  return 0;
    800055c8:	4501                	li	a0,0
    800055ca:	64aa                	ld	s1,136(sp)
}
    800055cc:	60ea                	ld	ra,152(sp)
    800055ce:	644a                	ld	s0,144(sp)
    800055d0:	690a                	ld	s2,128(sp)
    800055d2:	610d                	addi	sp,sp,160
    800055d4:	8082                	ret
    800055d6:	64aa                	ld	s1,136(sp)
    end_op();
    800055d8:	959fe0ef          	jal	80003f30 <end_op>
    return -1;
    800055dc:	557d                	li	a0,-1
    800055de:	b7fd                	j	800055cc <sys_chdir+0x5c>
    iunlockput(ip);
    800055e0:	8526                	mv	a0,s1
    800055e2:	89efe0ef          	jal	80003680 <iunlockput>
    end_op();
    800055e6:	94bfe0ef          	jal	80003f30 <end_op>
    return -1;
    800055ea:	557d                	li	a0,-1
    800055ec:	64aa                	ld	s1,136(sp)
    800055ee:	bff9                	j	800055cc <sys_chdir+0x5c>

00000000800055f0 <sys_exec>:

uint64
sys_exec(void)
{
    800055f0:	7105                	addi	sp,sp,-480
    800055f2:	ef86                	sd	ra,472(sp)
    800055f4:	eba2                	sd	s0,464(sp)
    800055f6:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800055f8:	e2840593          	addi	a1,s0,-472
    800055fc:	4505                	li	a0,1
    800055fe:	c40fd0ef          	jal	80002a3e <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    80005602:	08000613          	li	a2,128
    80005606:	f3040593          	addi	a1,s0,-208
    8000560a:	4501                	li	a0,0
    8000560c:	c4efd0ef          	jal	80002a5a <argstr>
    80005610:	87aa                	mv	a5,a0
    return -1;
    80005612:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005614:	0e07c063          	bltz	a5,800056f4 <sys_exec+0x104>
    80005618:	e7a6                	sd	s1,456(sp)
    8000561a:	e3ca                	sd	s2,448(sp)
    8000561c:	ff4e                	sd	s3,440(sp)
    8000561e:	fb52                	sd	s4,432(sp)
    80005620:	f756                	sd	s5,424(sp)
    80005622:	f35a                	sd	s6,416(sp)
    80005624:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005626:	e3040a13          	addi	s4,s0,-464
    8000562a:	10000613          	li	a2,256
    8000562e:	4581                	li	a1,0
    80005630:	8552                	mv	a0,s4
    80005632:	eb6fb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    80005636:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005638:	89d2                	mv	s3,s4
    8000563a:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000563c:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005640:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    80005642:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005646:	00391513          	slli	a0,s2,0x3
    8000564a:	85d6                	mv	a1,s5
    8000564c:	e2843783          	ld	a5,-472(s0)
    80005650:	953e                	add	a0,a0,a5
    80005652:	b44fd0ef          	jal	80002996 <fetchaddr>
    80005656:	02054663          	bltz	a0,80005682 <sys_exec+0x92>
    if (uarg == 0) {
    8000565a:	e2043783          	ld	a5,-480(s0)
    8000565e:	c7a1                	beqz	a5,800056a6 <sys_exec+0xb6>
    argv[i] = kalloc();
    80005660:	ceefb0ef          	jal	80000b4e <kalloc>
    80005664:	85aa                	mv	a1,a0
    80005666:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    8000566a:	cd01                	beqz	a0,80005682 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000566c:	865a                	mv	a2,s6
    8000566e:	e2043503          	ld	a0,-480(s0)
    80005672:	b6efd0ef          	jal	800029e0 <fetchstr>
    80005676:	00054663          	bltz	a0,80005682 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    8000567a:	0905                	addi	s2,s2,1
    8000567c:	09a1                	addi	s3,s3,8
    8000567e:	fd7914e3          	bne	s2,s7,80005646 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005682:	100a0a13          	addi	s4,s4,256
    80005686:	6088                	ld	a0,0(s1)
    80005688:	cd31                	beqz	a0,800056e4 <sys_exec+0xf4>
    kfree(argv[i]);
    8000568a:	bdcfb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000568e:	04a1                	addi	s1,s1,8
    80005690:	ff449be3          	bne	s1,s4,80005686 <sys_exec+0x96>
  return -1;
    80005694:	557d                	li	a0,-1
    80005696:	64be                	ld	s1,456(sp)
    80005698:	691e                	ld	s2,448(sp)
    8000569a:	79fa                	ld	s3,440(sp)
    8000569c:	7a5a                	ld	s4,432(sp)
    8000569e:	7aba                	ld	s5,424(sp)
    800056a0:	7b1a                	ld	s6,416(sp)
    800056a2:	6bfa                	ld	s7,408(sp)
    800056a4:	a881                	j	800056f4 <sys_exec+0x104>
      argv[i] = 0;
    800056a6:	0009079b          	sext.w	a5,s2
    800056aa:	e3040593          	addi	a1,s0,-464
    800056ae:	078e                	slli	a5,a5,0x3
    800056b0:	97ae                	add	a5,a5,a1
    800056b2:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    800056b6:	f3040513          	addi	a0,s0,-208
    800056ba:	b62ff0ef          	jal	80004a1c <kexec>
    800056be:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800056c0:	100a0a13          	addi	s4,s4,256
    800056c4:	6088                	ld	a0,0(s1)
    800056c6:	c511                	beqz	a0,800056d2 <sys_exec+0xe2>
    kfree(argv[i]);
    800056c8:	b9efb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800056cc:	04a1                	addi	s1,s1,8
    800056ce:	ff449be3          	bne	s1,s4,800056c4 <sys_exec+0xd4>
  return ret;
    800056d2:	854a                	mv	a0,s2
    800056d4:	64be                	ld	s1,456(sp)
    800056d6:	691e                	ld	s2,448(sp)
    800056d8:	79fa                	ld	s3,440(sp)
    800056da:	7a5a                	ld	s4,432(sp)
    800056dc:	7aba                	ld	s5,424(sp)
    800056de:	7b1a                	ld	s6,416(sp)
    800056e0:	6bfa                	ld	s7,408(sp)
    800056e2:	a809                	j	800056f4 <sys_exec+0x104>
  return -1;
    800056e4:	557d                	li	a0,-1
    800056e6:	64be                	ld	s1,456(sp)
    800056e8:	691e                	ld	s2,448(sp)
    800056ea:	79fa                	ld	s3,440(sp)
    800056ec:	7a5a                	ld	s4,432(sp)
    800056ee:	7aba                	ld	s5,424(sp)
    800056f0:	7b1a                	ld	s6,416(sp)
    800056f2:	6bfa                	ld	s7,408(sp)
}
    800056f4:	60fe                	ld	ra,472(sp)
    800056f6:	645e                	ld	s0,464(sp)
    800056f8:	613d                	addi	sp,sp,480
    800056fa:	8082                	ret

00000000800056fc <sys_pipe>:

uint64
sys_pipe(void)
{
    800056fc:	7139                	addi	sp,sp,-64
    800056fe:	fc06                	sd	ra,56(sp)
    80005700:	f822                	sd	s0,48(sp)
    80005702:	f426                	sd	s1,40(sp)
    80005704:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005706:	a42fc0ef          	jal	80001948 <myproc>
    8000570a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000570c:	fd840593          	addi	a1,s0,-40
    80005710:	4501                	li	a0,0
    80005712:	b2cfd0ef          	jal	80002a3e <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005716:	fc840593          	addi	a1,s0,-56
    8000571a:	fd040513          	addi	a0,s0,-48
    8000571e:	f7ffe0ef          	jal	8000469c <pipealloc>
    return -1;
    80005722:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005724:	0a054963          	bltz	a0,800057d6 <sys_pipe+0xda>
  fd0 = -1;
    80005728:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    8000572c:	fd043503          	ld	a0,-48(s0)
    80005730:	ea0ff0ef          	jal	80004dd0 <fdalloc>
    80005734:	fca42223          	sw	a0,-60(s0)
    80005738:	08054663          	bltz	a0,800057c4 <sys_pipe+0xc8>
    8000573c:	fc843503          	ld	a0,-56(s0)
    80005740:	e90ff0ef          	jal	80004dd0 <fdalloc>
    80005744:	fca42023          	sw	a0,-64(s0)
    80005748:	06054463          	bltz	a0,800057b0 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    8000574c:	4711                	li	a4,4
    8000574e:	fc440693          	addi	a3,s0,-60
    80005752:	fd843603          	ld	a2,-40(s0)
    80005756:	64ac                	ld	a1,72(s1)
    80005758:	68a8                	ld	a0,80(s1)
    8000575a:	e29fb0ef          	jal	80001582 <copyout>
    8000575e:	00054f63          	bltz	a0,8000577c <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    80005762:	4711                	li	a4,4
    80005764:	fc040693          	addi	a3,s0,-64
    80005768:	fd843603          	ld	a2,-40(s0)
    8000576c:	963a                	add	a2,a2,a4
    8000576e:	64ac                	ld	a1,72(s1)
    80005770:	68a8                	ld	a0,80(s1)
    80005772:	e11fb0ef          	jal	80001582 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005776:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005778:	04055f63          	bgez	a0,800057d6 <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    8000577c:	fc442783          	lw	a5,-60(s0)
    80005780:	078e                	slli	a5,a5,0x3
    80005782:	0d078793          	addi	a5,a5,208
    80005786:	97a6                	add	a5,a5,s1
    80005788:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000578c:	fc042783          	lw	a5,-64(s0)
    80005790:	078e                	slli	a5,a5,0x3
    80005792:	0d078793          	addi	a5,a5,208
    80005796:	94be                	add	s1,s1,a5
    80005798:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000579c:	fd043503          	ld	a0,-48(s0)
    800057a0:	bbffe0ef          	jal	8000435e <fileclose>
    fileclose(wf);
    800057a4:	fc843503          	ld	a0,-56(s0)
    800057a8:	bb7fe0ef          	jal	8000435e <fileclose>
    return -1;
    800057ac:	57fd                	li	a5,-1
    800057ae:	a025                	j	800057d6 <sys_pipe+0xda>
    if (fd0 >= 0)
    800057b0:	fc442783          	lw	a5,-60(s0)
    800057b4:	0007c863          	bltz	a5,800057c4 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    800057b8:	078e                	slli	a5,a5,0x3
    800057ba:	0d078793          	addi	a5,a5,208
    800057be:	97a6                	add	a5,a5,s1
    800057c0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800057c4:	fd043503          	ld	a0,-48(s0)
    800057c8:	b97fe0ef          	jal	8000435e <fileclose>
    fileclose(wf);
    800057cc:	fc843503          	ld	a0,-56(s0)
    800057d0:	b8ffe0ef          	jal	8000435e <fileclose>
    return -1;
    800057d4:	57fd                	li	a5,-1
}
    800057d6:	853e                	mv	a0,a5
    800057d8:	70e2                	ld	ra,56(sp)
    800057da:	7442                	ld	s0,48(sp)
    800057dc:	74a2                	ld	s1,40(sp)
    800057de:	6121                	addi	sp,sp,64
    800057e0:	8082                	ret
	...

00000000800057f0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800057f0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800057f2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800057f4:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    800057f6:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800057f8:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800057fa:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800057fc:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800057fe:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005800:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005802:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005804:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005806:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005808:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000580a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000580c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000580e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005810:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005812:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005814:	890fd0ef          	jal	800028a4 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005818:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000581a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000581c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000581e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005820:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005822:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005824:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005826:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005828:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000582a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000582c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000582e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005830:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005832:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005834:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005836:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005838:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000583a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000583c:	10200073          	sret
    80005840:	0001                	nop
    80005842:	00000013          	nop
    80005846:	00000013          	nop
    8000584a:	00000013          	nop

000000008000584e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000584e:	1141                	addi	sp,sp,-16
    80005850:	e406                	sd	ra,8(sp)
    80005852:	e022                	sd	s0,0(sp)
    80005854:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005856:	0c000737          	lui	a4,0xc000
    8000585a:	4785                	li	a5,1
    8000585c:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000585e:	c35c                	sw	a5,4(a4)
}
    80005860:	60a2                	ld	ra,8(sp)
    80005862:	6402                	ld	s0,0(sp)
    80005864:	0141                	addi	sp,sp,16
    80005866:	8082                	ret

0000000080005868 <plicinithart>:

void
plicinithart(void)
{
    80005868:	1141                	addi	sp,sp,-16
    8000586a:	e406                	sd	ra,8(sp)
    8000586c:	e022                	sd	s0,0(sp)
    8000586e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005870:	8a4fc0ef          	jal	80001914 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    80005874:	0085179b          	slliw	a5,a0,0x8
    80005878:	0c002737          	lui	a4,0xc002
    8000587c:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    80005880:	97ba                	add	a5,a5,a4
    80005882:	40200713          	li	a4,1026
    80005886:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005888:	00d5151b          	slliw	a0,a0,0xd
    8000588c:	0c2017b7          	lui	a5,0xc201
    80005890:	953e                	add	a0,a0,a5
    80005892:	00052023          	sw	zero,0(a0)
}
    80005896:	60a2                	ld	ra,8(sp)
    80005898:	6402                	ld	s0,0(sp)
    8000589a:	0141                	addi	sp,sp,16
    8000589c:	8082                	ret

000000008000589e <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000589e:	1141                	addi	sp,sp,-16
    800058a0:	e406                	sd	ra,8(sp)
    800058a2:	e022                	sd	s0,0(sp)
    800058a4:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800058a6:	86efc0ef          	jal	80001914 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    800058aa:	00d5151b          	slliw	a0,a0,0xd
    800058ae:	0c2017b7          	lui	a5,0xc201
    800058b2:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    800058b4:	953e                	add	a0,a0,a5
    800058b6:	4108                	lw	a0,0(a0)
  return irq;
}
    800058b8:	60a2                	ld	ra,8(sp)
    800058ba:	6402                	ld	s0,0(sp)
    800058bc:	0141                	addi	sp,sp,16
    800058be:	8082                	ret

00000000800058c0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800058c0:	1101                	addi	sp,sp,-32
    800058c2:	ec06                	sd	ra,24(sp)
    800058c4:	e822                	sd	s0,16(sp)
    800058c6:	e426                	sd	s1,8(sp)
    800058c8:	1000                	addi	s0,sp,32
    800058ca:	84aa                	mv	s1,a0
  int hart = cpuid();
    800058cc:	848fc0ef          	jal	80001914 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    800058d0:	00d5179b          	slliw	a5,a0,0xd
    800058d4:	0c201737          	lui	a4,0xc201
    800058d8:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    800058da:	97ba                	add	a5,a5,a4
    800058dc:	c384                	sw	s1,0(a5)
}
    800058de:	60e2                	ld	ra,24(sp)
    800058e0:	6442                	ld	s0,16(sp)
    800058e2:	64a2                	ld	s1,8(sp)
    800058e4:	6105                	addi	sp,sp,32
    800058e6:	8082                	ret

00000000800058e8 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800058e8:	1141                	addi	sp,sp,-16
    800058ea:	e406                	sd	ra,8(sp)
    800058ec:	e022                	sd	s0,0(sp)
    800058ee:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800058f0:	479d                	li	a5,7
    800058f2:	04a7ca63          	blt	a5,a0,80005946 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    800058f6:	0001e797          	auipc	a5,0x1e
    800058fa:	e9278793          	addi	a5,a5,-366 # 80023788 <disk>
    800058fe:	97aa                	add	a5,a5,a0
    80005900:	0187c783          	lbu	a5,24(a5)
    80005904:	e7b9                	bnez	a5,80005952 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005906:	00451693          	slli	a3,a0,0x4
    8000590a:	0001e797          	auipc	a5,0x1e
    8000590e:	e7e78793          	addi	a5,a5,-386 # 80023788 <disk>
    80005912:	6398                	ld	a4,0(a5)
    80005914:	9736                	add	a4,a4,a3
    80005916:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000591a:	6398                	ld	a4,0(a5)
    8000591c:	9736                	add	a4,a4,a3
    8000591e:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005922:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005926:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000592a:	97aa                	add	a5,a5,a0
    8000592c:	4705                	li	a4,1
    8000592e:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005932:	0001e517          	auipc	a0,0x1e
    80005936:	e6e50513          	addi	a0,a0,-402 # 800237a0 <disk+0x18>
    8000593a:	813fc0ef          	jal	8000214c <wakeup>
}
    8000593e:	60a2                	ld	ra,8(sp)
    80005940:	6402                	ld	s0,0(sp)
    80005942:	0141                	addi	sp,sp,16
    80005944:	8082                	ret
    panic("free_desc 1");
    80005946:	00002517          	auipc	a0,0x2
    8000594a:	cea50513          	addi	a0,a0,-790 # 80007630 <etext+0x630>
    8000594e:	ee7fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    80005952:	00002517          	auipc	a0,0x2
    80005956:	cee50513          	addi	a0,a0,-786 # 80007640 <etext+0x640>
    8000595a:	edbfa0ef          	jal	80000834 <panic>

000000008000595e <virtio_disk_init>:
{
    8000595e:	1101                	addi	sp,sp,-32
    80005960:	ec06                	sd	ra,24(sp)
    80005962:	e822                	sd	s0,16(sp)
    80005964:	e426                	sd	s1,8(sp)
    80005966:	e04a                	sd	s2,0(sp)
    80005968:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000596a:	00002597          	auipc	a1,0x2
    8000596e:	ce658593          	addi	a1,a1,-794 # 80007650 <etext+0x650>
    80005972:	0001e517          	auipc	a0,0x1e
    80005976:	f3e50513          	addi	a0,a0,-194 # 800238b0 <disk+0x128>
    8000597a:	a2efb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000597e:	100017b7          	lui	a5,0x10001
    80005982:	4398                	lw	a4,0(a5)
    80005984:	2701                	sext.w	a4,a4
    80005986:	747277b7          	lui	a5,0x74727
    8000598a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000598e:	14f71863          	bne	a4,a5,80005ade <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005992:	100017b7          	lui	a5,0x10001
    80005996:	43dc                	lw	a5,4(a5)
    80005998:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000599a:	4709                	li	a4,2
    8000599c:	14e79163          	bne	a5,a4,80005ade <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800059a0:	100017b7          	lui	a5,0x10001
    800059a4:	479c                	lw	a5,8(a5)
    800059a6:	2781                	sext.w	a5,a5
    800059a8:	12e79b63          	bne	a5,a4,80005ade <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    800059ac:	100017b7          	lui	a5,0x10001
    800059b0:	47d8                	lw	a4,12(a5)
    800059b2:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800059b4:	554d47b7          	lui	a5,0x554d4
    800059b8:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800059bc:	12f71163          	bne	a4,a5,80005ade <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    800059c0:	100017b7          	lui	a5,0x10001
    800059c4:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800059c8:	4705                	li	a4,1
    800059ca:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059cc:	470d                	li	a4,3
    800059ce:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800059d0:	10001737          	lui	a4,0x10001
    800059d4:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800059d6:	c7ffe6b7          	lui	a3,0xc7ffe
    800059da:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdac97>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800059de:	8f75                	and	a4,a4,a3
    800059e0:	100016b7          	lui	a3,0x10001
    800059e4:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059e6:	472d                	li	a4,11
    800059e8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059ea:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800059ee:	439c                	lw	a5,0(a5)
    800059f0:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800059f4:	8ba1                	andi	a5,a5,8
    800059f6:	0e078a63          	beqz	a5,80005aea <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800059fa:	100017b7          	lui	a5,0x10001
    800059fe:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005a02:	43fc                	lw	a5,68(a5)
    80005a04:	2781                	sext.w	a5,a5
    80005a06:	0e079863          	bnez	a5,80005af6 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005a0a:	100017b7          	lui	a5,0x10001
    80005a0e:	5bdc                	lw	a5,52(a5)
    80005a10:	2781                	sext.w	a5,a5
  if (max == 0)
    80005a12:	0e078863          	beqz	a5,80005b02 <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005a16:	471d                	li	a4,7
    80005a18:	0ef77b63          	bgeu	a4,a5,80005b0e <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005a1c:	932fb0ef          	jal	80000b4e <kalloc>
    80005a20:	0001e497          	auipc	s1,0x1e
    80005a24:	d6848493          	addi	s1,s1,-664 # 80023788 <disk>
    80005a28:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005a2a:	924fb0ef          	jal	80000b4e <kalloc>
    80005a2e:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005a30:	91efb0ef          	jal	80000b4e <kalloc>
    80005a34:	87aa                	mv	a5,a0
    80005a36:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005a38:	6088                	ld	a0,0(s1)
    80005a3a:	0e050063          	beqz	a0,80005b1a <virtio_disk_init+0x1bc>
    80005a3e:	0001e717          	auipc	a4,0x1e
    80005a42:	d5273703          	ld	a4,-686(a4) # 80023790 <disk+0x8>
    80005a46:	cb71                	beqz	a4,80005b1a <virtio_disk_init+0x1bc>
    80005a48:	cbe9                	beqz	a5,80005b1a <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005a4a:	6605                	lui	a2,0x1
    80005a4c:	4581                	li	a1,0
    80005a4e:	a9afb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005a52:	0001e497          	auipc	s1,0x1e
    80005a56:	d3648493          	addi	s1,s1,-714 # 80023788 <disk>
    80005a5a:	6605                	lui	a2,0x1
    80005a5c:	4581                	li	a1,0
    80005a5e:	6488                	ld	a0,8(s1)
    80005a60:	a88fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005a64:	6605                	lui	a2,0x1
    80005a66:	4581                	li	a1,0
    80005a68:	6888                	ld	a0,16(s1)
    80005a6a:	a7efb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005a6e:	100017b7          	lui	a5,0x10001
    80005a72:	4721                	li	a4,8
    80005a74:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005a76:	4098                	lw	a4,0(s1)
    80005a78:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005a7c:	40d8                	lw	a4,4(s1)
    80005a7e:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005a82:	649c                	ld	a5,8(s1)
    80005a84:	0007869b          	sext.w	a3,a5
    80005a88:	10001737          	lui	a4,0x10001
    80005a8c:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005a90:	9781                	srai	a5,a5,0x20
    80005a92:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005a96:	689c                	ld	a5,16(s1)
    80005a98:	0007869b          	sext.w	a3,a5
    80005a9c:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005aa0:	9781                	srai	a5,a5,0x20
    80005aa2:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005aa6:	4785                	li	a5,1
    80005aa8:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005aaa:	00f48c23          	sb	a5,24(s1)
    80005aae:	00f48ca3          	sb	a5,25(s1)
    80005ab2:	00f48d23          	sb	a5,26(s1)
    80005ab6:	00f48da3          	sb	a5,27(s1)
    80005aba:	00f48e23          	sb	a5,28(s1)
    80005abe:	00f48ea3          	sb	a5,29(s1)
    80005ac2:	00f48f23          	sb	a5,30(s1)
    80005ac6:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005aca:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ace:	07272823          	sw	s2,112(a4)
}
    80005ad2:	60e2                	ld	ra,24(sp)
    80005ad4:	6442                	ld	s0,16(sp)
    80005ad6:	64a2                	ld	s1,8(sp)
    80005ad8:	6902                	ld	s2,0(sp)
    80005ada:	6105                	addi	sp,sp,32
    80005adc:	8082                	ret
    panic("could not find virtio disk");
    80005ade:	00002517          	auipc	a0,0x2
    80005ae2:	b8250513          	addi	a0,a0,-1150 # 80007660 <etext+0x660>
    80005ae6:	d4ffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005aea:	00002517          	auipc	a0,0x2
    80005aee:	b9650513          	addi	a0,a0,-1130 # 80007680 <etext+0x680>
    80005af2:	d43fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005af6:	00002517          	auipc	a0,0x2
    80005afa:	baa50513          	addi	a0,a0,-1110 # 800076a0 <etext+0x6a0>
    80005afe:	d37fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005b02:	00002517          	auipc	a0,0x2
    80005b06:	bbe50513          	addi	a0,a0,-1090 # 800076c0 <etext+0x6c0>
    80005b0a:	d2bfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005b0e:	00002517          	auipc	a0,0x2
    80005b12:	bd250513          	addi	a0,a0,-1070 # 800076e0 <etext+0x6e0>
    80005b16:	d1ffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005b1a:	00002517          	auipc	a0,0x2
    80005b1e:	be650513          	addi	a0,a0,-1050 # 80007700 <etext+0x700>
    80005b22:	d13fa0ef          	jal	80000834 <panic>

0000000080005b26 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005b26:	711d                	addi	sp,sp,-96
    80005b28:	ec86                	sd	ra,88(sp)
    80005b2a:	e8a2                	sd	s0,80(sp)
    80005b2c:	e4a6                	sd	s1,72(sp)
    80005b2e:	e0ca                	sd	s2,64(sp)
    80005b30:	fc4e                	sd	s3,56(sp)
    80005b32:	f852                	sd	s4,48(sp)
    80005b34:	f456                	sd	s5,40(sp)
    80005b36:	f05a                	sd	s6,32(sp)
    80005b38:	ec5e                	sd	s7,24(sp)
    80005b3a:	e862                	sd	s8,16(sp)
    80005b3c:	1080                	addi	s0,sp,96
    80005b3e:	89aa                	mv	s3,a0
    80005b40:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005b42:	00c52b83          	lw	s7,12(a0)
    80005b46:	001b9b9b          	slliw	s7,s7,0x1
    80005b4a:	1b82                	slli	s7,s7,0x20
    80005b4c:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005b50:	0001e517          	auipc	a0,0x1e
    80005b54:	d6050513          	addi	a0,a0,-672 # 800238b0 <disk+0x128>
    80005b58:	8d0fb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005b5c:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005b5e:	0001ea97          	auipc	s5,0x1e
    80005b62:	c2aa8a93          	addi	s5,s5,-982 # 80023788 <disk>
  for (int i = 0; i < 3; i++) {
    80005b66:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005b68:	5c7d                	li	s8,-1
    80005b6a:	a8a5                	j	80005be2 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005b6c:	00fa8733          	add	a4,s5,a5
    80005b70:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005b74:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005b76:	0207c563          	bltz	a5,80005ba0 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005b7a:	2905                	addiw	s2,s2,1
    80005b7c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005b7e:	07490663          	beq	s2,s4,80005bea <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005b82:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005b84:	0001e717          	auipc	a4,0x1e
    80005b88:	c0470713          	addi	a4,a4,-1020 # 80023788 <disk>
    80005b8c:	4781                	li	a5,0
    if (disk.free[i]) {
    80005b8e:	01874683          	lbu	a3,24(a4)
    80005b92:	fee9                	bnez	a3,80005b6c <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005b94:	2785                	addiw	a5,a5,1
    80005b96:	0705                	addi	a4,a4,1
    80005b98:	fe979be3          	bne	a5,s1,80005b8e <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005b9c:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005ba0:	01205d63          	blez	s2,80005bba <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005ba4:	fa042503          	lw	a0,-96(s0)
    80005ba8:	d41ff0ef          	jal	800058e8 <free_desc>
      for (int j = 0; j < i; j++)
    80005bac:	4785                	li	a5,1
    80005bae:	0127d663          	bge	a5,s2,80005bba <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005bb2:	fa442503          	lw	a0,-92(s0)
    80005bb6:	d33ff0ef          	jal	800058e8 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005bba:	0001e517          	auipc	a0,0x1e
    80005bbe:	be650513          	addi	a0,a0,-1050 # 800237a0 <disk+0x18>
    80005bc2:	d1efc0ef          	jal	800020e0 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005bc6:	0001e517          	auipc	a0,0x1e
    80005bca:	cea50513          	addi	a0,a0,-790 # 800238b0 <disk+0x128>
    80005bce:	8e2fb0ef          	jal	80000cb0 <release>
    sleep();
    80005bd2:	d4afc0ef          	jal	8000211c <sleep>
    acquire(&disk.vdisk_lock);
    80005bd6:	0001e517          	auipc	a0,0x1e
    80005bda:	cda50513          	addi	a0,a0,-806 # 800238b0 <disk+0x128>
    80005bde:	84afb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005be2:	fa040613          	addi	a2,s0,-96
    80005be6:	4901                	li	s2,0
    80005be8:	bf69                	j	80005b82 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005bea:	fa042503          	lw	a0,-96(s0)
    80005bee:	00451693          	slli	a3,a0,0x4

  if (write)
    80005bf2:	0001e797          	auipc	a5,0x1e
    80005bf6:	b9678793          	addi	a5,a5,-1130 # 80023788 <disk>
    80005bfa:	00451713          	slli	a4,a0,0x4
    80005bfe:	0a070713          	addi	a4,a4,160
    80005c02:	973e                	add	a4,a4,a5
    80005c04:	01603633          	snez	a2,s6
    80005c08:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005c0a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005c0e:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005c12:	6398                	ld	a4,0(a5)
    80005c14:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005c16:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005c1a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005c1c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005c1e:	6390                	ld	a2,0(a5)
    80005c20:	00d60833          	add	a6,a2,a3
    80005c24:	4741                	li	a4,16
    80005c26:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005c2a:	4585                	li	a1,1
    80005c2c:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005c30:	fa442703          	lw	a4,-92(s0)
    80005c34:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005c38:	0712                	slli	a4,a4,0x4
    80005c3a:	963a                	add	a2,a2,a4
    80005c3c:	05898813          	addi	a6,s3,88
    80005c40:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005c44:	0007b883          	ld	a7,0(a5)
    80005c48:	9746                	add	a4,a4,a7
    80005c4a:	40000613          	li	a2,1024
    80005c4e:	c710                	sw	a2,8(a4)
  if (write)
    80005c50:	001b3613          	seqz	a2,s6
    80005c54:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005c58:	8e4d                	or	a2,a2,a1
    80005c5a:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005c5e:	fa842603          	lw	a2,-88(s0)
    80005c62:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005c66:	00451813          	slli	a6,a0,0x4
    80005c6a:	02080813          	addi	a6,a6,32
    80005c6e:	983e                	add	a6,a6,a5
    80005c70:	577d                	li	a4,-1
    80005c72:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005c76:	0612                	slli	a2,a2,0x4
    80005c78:	98b2                	add	a7,a7,a2
    80005c7a:	03068713          	addi	a4,a3,48
    80005c7e:	973e                	add	a4,a4,a5
    80005c80:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005c84:	6398                	ld	a4,0(a5)
    80005c86:	9732                	add	a4,a4,a2
    80005c88:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005c8a:	4689                	li	a3,2
    80005c8c:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005c90:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005c94:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005c98:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005c9c:	6794                	ld	a3,8(a5)
    80005c9e:	0026d703          	lhu	a4,2(a3)
    80005ca2:	8b1d                	andi	a4,a4,7
    80005ca4:	0706                	slli	a4,a4,0x1
    80005ca6:	96ba                	add	a3,a3,a4
    80005ca8:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005cac:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005cb0:	6798                	ld	a4,8(a5)
    80005cb2:	00275783          	lhu	a5,2(a4)
    80005cb6:	2785                	addiw	a5,a5,1
    80005cb8:	00f71123          	sh	a5,2(a4)
    80005cbc:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005cc0:	100017b7          	lui	a5,0x10001
    80005cc4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005cc8:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005ccc:	0001e497          	auipc	s1,0x1e
    80005cd0:	be448493          	addi	s1,s1,-1052 # 800238b0 <disk+0x128>
  while (b->disk == 1) {
    80005cd4:	892e                	mv	s2,a1
    80005cd6:	02b79163          	bne	a5,a1,80005cf8 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005cda:	854e                	mv	a0,s3
    80005cdc:	c04fc0ef          	jal	800020e0 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005ce0:	8526                	mv	a0,s1
    80005ce2:	fcffa0ef          	jal	80000cb0 <release>
    sleep();
    80005ce6:	c36fc0ef          	jal	8000211c <sleep>
    acquire(&disk.vdisk_lock);
    80005cea:	8526                	mv	a0,s1
    80005cec:	f3dfa0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005cf0:	0049a783          	lw	a5,4(s3)
    80005cf4:	ff2783e3          	beq	a5,s2,80005cda <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005cf8:	fa042903          	lw	s2,-96(s0)
    80005cfc:	00491713          	slli	a4,s2,0x4
    80005d00:	02070713          	addi	a4,a4,32
    80005d04:	0001e797          	auipc	a5,0x1e
    80005d08:	a8478793          	addi	a5,a5,-1404 # 80023788 <disk>
    80005d0c:	97ba                	add	a5,a5,a4
    80005d0e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005d12:	0001e997          	auipc	s3,0x1e
    80005d16:	a7698993          	addi	s3,s3,-1418 # 80023788 <disk>
    80005d1a:	00491713          	slli	a4,s2,0x4
    80005d1e:	0009b783          	ld	a5,0(s3)
    80005d22:	97ba                	add	a5,a5,a4
    80005d24:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005d28:	854a                	mv	a0,s2
    80005d2a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005d2e:	bbbff0ef          	jal	800058e8 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005d32:	8885                	andi	s1,s1,1
    80005d34:	f0fd                	bnez	s1,80005d1a <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005d36:	0001e517          	auipc	a0,0x1e
    80005d3a:	b7a50513          	addi	a0,a0,-1158 # 800238b0 <disk+0x128>
    80005d3e:	f73fa0ef          	jal	80000cb0 <release>
}
    80005d42:	60e6                	ld	ra,88(sp)
    80005d44:	6446                	ld	s0,80(sp)
    80005d46:	64a6                	ld	s1,72(sp)
    80005d48:	6906                	ld	s2,64(sp)
    80005d4a:	79e2                	ld	s3,56(sp)
    80005d4c:	7a42                	ld	s4,48(sp)
    80005d4e:	7aa2                	ld	s5,40(sp)
    80005d50:	7b02                	ld	s6,32(sp)
    80005d52:	6be2                	ld	s7,24(sp)
    80005d54:	6c42                	ld	s8,16(sp)
    80005d56:	6125                	addi	sp,sp,96
    80005d58:	8082                	ret

0000000080005d5a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005d5a:	1101                	addi	sp,sp,-32
    80005d5c:	ec06                	sd	ra,24(sp)
    80005d5e:	e822                	sd	s0,16(sp)
    80005d60:	e426                	sd	s1,8(sp)
    80005d62:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005d64:	0001e497          	auipc	s1,0x1e
    80005d68:	a2448493          	addi	s1,s1,-1500 # 80023788 <disk>
    80005d6c:	0001e517          	auipc	a0,0x1e
    80005d70:	b4450513          	addi	a0,a0,-1212 # 800238b0 <disk+0x128>
    80005d74:	eb5fa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005d78:	100017b7          	lui	a5,0x10001
    80005d7c:	53bc                	lw	a5,96(a5)
    80005d7e:	8b8d                	andi	a5,a5,3
    80005d80:	10001737          	lui	a4,0x10001
    80005d84:	d37c                	sw	a5,100(a4)
    80005d86:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005d8a:	689c                	ld	a5,16(s1)
    80005d8c:	0204d703          	lhu	a4,32(s1)
    80005d90:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005d94:	04f70863          	beq	a4,a5,80005de4 <virtio_disk_intr+0x8a>
    80005d98:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005d9c:	6898                	ld	a4,16(s1)
    80005d9e:	0204d783          	lhu	a5,32(s1)
    80005da2:	8b9d                	andi	a5,a5,7
    80005da4:	078e                	slli	a5,a5,0x3
    80005da6:	97ba                	add	a5,a5,a4
    80005da8:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005daa:	00479713          	slli	a4,a5,0x4
    80005dae:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005db2:	9726                	add	a4,a4,s1
    80005db4:	01074703          	lbu	a4,16(a4)
    80005db8:	e329                	bnez	a4,80005dfa <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005dba:	0792                	slli	a5,a5,0x4
    80005dbc:	02078793          	addi	a5,a5,32
    80005dc0:	97a6                	add	a5,a5,s1
    80005dc2:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005dc4:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005dc8:	b84fc0ef          	jal	8000214c <wakeup>

    disk.used_idx += 1;
    80005dcc:	0204d783          	lhu	a5,32(s1)
    80005dd0:	2785                	addiw	a5,a5,1
    80005dd2:	17c2                	slli	a5,a5,0x30
    80005dd4:	93c1                	srli	a5,a5,0x30
    80005dd6:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005dda:	6898                	ld	a4,16(s1)
    80005ddc:	00275703          	lhu	a4,2(a4)
    80005de0:	faf71ce3          	bne	a4,a5,80005d98 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005de4:	0001e517          	auipc	a0,0x1e
    80005de8:	acc50513          	addi	a0,a0,-1332 # 800238b0 <disk+0x128>
    80005dec:	ec5fa0ef          	jal	80000cb0 <release>
}
    80005df0:	60e2                	ld	ra,24(sp)
    80005df2:	6442                	ld	s0,16(sp)
    80005df4:	64a2                	ld	s1,8(sp)
    80005df6:	6105                	addi	sp,sp,32
    80005df8:	8082                	ret
      panic("virtio_disk_intr status");
    80005dfa:	00002517          	auipc	a0,0x2
    80005dfe:	91e50513          	addi	a0,a0,-1762 # 80007718 <etext+0x718>
    80005e02:	a33fa0ef          	jal	80000834 <panic>
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
