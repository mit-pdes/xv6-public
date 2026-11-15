
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
    80000004:	4a813103          	ld	sp,1192(sp) # 8000a4a8 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdabdf>
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
    8000011c:	292020ef          	jal	800023ae <either_copyin>
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
    80000198:	36c50513          	addi	a0,a0,876 # 80012500 <cons>
    8000019c:	28d000ef          	jal	80000c28 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	36048493          	addi	s1,s1,864 # 80012500 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	3f090913          	addi	s2,s2,1008 # 80012598 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	790010ef          	jal	80001950 <myproc>
    800001c4:	06a020ef          	jal	8000222e <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	605010ef          	jal	80001fd0 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	637010ef          	jal	8000200c <sleep>
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
    800001f2:	31270713          	addi	a4,a4,786 # 80012500 <cons>
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
    80000220:	142020ef          	jal	80002362 <either_copyout>
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
    8000023c:	2c850513          	addi	a0,a0,712 # 80012500 <cons>
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
    80000262:	32f72d23          	sw	a5,826(a4) # 80012598 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	28c50513          	addi	a0,a0,652 # 80012500 <cons>
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
    800002cc:	23850513          	addi	a0,a0,568 # 80012500 <cons>
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
    800002ea:	110020ef          	jal	800023fa <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	21250513          	addi	a0,a0,530 # 80012500 <cons>
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
    80000310:	1f470713          	addi	a4,a4,500 # 80012500 <cons>
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
    80000336:	1ce70713          	addi	a4,a4,462 # 80012500 <cons>
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
    80000360:	23c72703          	lw	a4,572(a4) # 80012598 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	18e70713          	addi	a4,a4,398 # 80012500 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	17e48493          	addi	s1,s1,382 # 80012500 <cons>
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
    800003c8:	13c70713          	addi	a4,a4,316 # 80012500 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	1cf72323          	sw	a5,454(a4) # 800125a0 <cons+0xa0>
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
    800003fc:	10878793          	addi	a5,a5,264 # 80012500 <cons>
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
    8000041e:	18c7a123          	sw	a2,386(a5) # 8001259c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	17650513          	addi	a0,a0,374 # 80012598 <cons+0x98>
    8000042a:	413010ef          	jal	8000203c <wakeup>
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
    80000444:	0c050513          	addi	a0,a0,192 # 80012500 <cons>
    80000448:	760000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	63878793          	addi	a5,a5,1592 # 80022a88 <devsw>
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
    80000492:	2b280813          	addi	a6,a6,690 # 80007740 <digits>
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
    8000052c:	f9c7a783          	lw	a5,-100(a5) # 8000a4c4 <panicking>
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
    80000572:	03a50513          	addi	a0,a0,58 # 800125a8 <pr>
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
    800006e6:	05ec8c93          	addi	s9,s9,94 # 80007740 <digits>
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
    8000076e:	d5a7a783          	lw	a5,-678(a5) # 8000a4c4 <panicking>
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
    80000798:	e1450513          	addi	a0,a0,-492 # 800125a8 <pr>
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
    80000848:	c897a023          	sw	s1,-896(a5) # 8000a4c4 <panicking>
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
    8000086a:	c497ad23          	sw	s1,-934(a5) # 8000a4c0 <panicked>
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
    80000884:	d2850513          	addi	a0,a0,-728 # 800125a8 <pr>
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
    800008da:	cea50513          	addi	a0,a0,-790 # 800125c0 <tx_lock>
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
    800008fe:	cc650513          	addi	a0,a0,-826 # 800125c0 <tx_lock>
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
    8000091c:	bb490913          	addi	s2,s2,-1100 # 8000a4cc <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	ba898993          	addi	s3,s3,-1112 # 8000a4c8 <tx_chan>
      release(&tx_lock);
    80000928:	00012497          	auipc	s1,0x12
    8000092c:	c9848493          	addi	s1,s1,-872 # 800125c0 <tx_lock>
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
    8000093a:	696010ef          	jal	80001fd0 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	6c8010ef          	jal	8000200c <sleep>
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
    8000097c:	c4850513          	addi	a0,a0,-952 # 800125c0 <tx_lock>
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
    800009a0:	b287a783          	lw	a5,-1240(a5) # 8000a4c4 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	b1a7a783          	lw	a5,-1254(a5) # 8000a4c0 <panicked>
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
    800009d0:	af87a783          	lw	a5,-1288(a5) # 8000a4c4 <panicking>
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
    80000a06:	bbe50513          	addi	a0,a0,-1090 # 800125c0 <tx_lock>
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
    80000a20:	ba450513          	addi	a0,a0,-1116 # 800125c0 <tx_lock>
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
    80000a48:	a807a423          	sw	zero,-1400(a5) # 8000a4cc <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	a7c50513          	addi	a0,a0,-1412 # 8000a4c8 <tx_chan>
    80000a54:	5e8010ef          	jal	8000203c <wakeup>
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
    80000a76:	1ae78793          	addi	a5,a5,430 # 80023c20 <end>
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
    80000aa0:	b3c90913          	addi	s2,s2,-1220 # 800125d8 <kmem>
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
    80000b2e:	aae50513          	addi	a0,a0,-1362 # 800125d8 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00023517          	auipc	a0,0x23
    80000b3e:	0e650513          	addi	a0,a0,230 # 80023c20 <end>
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
    80000b5c:	a8050513          	addi	a0,a0,-1408 # 800125d8 <kmem>
    80000b60:	0c8000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b64:	00012497          	auipc	s1,0x12
    80000b68:	a8c4b483          	ld	s1,-1396(s1) # 800125f0 <kmem+0x18>
  if (r)
    80000b6c:	c49d                	beqz	s1,80000b9a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00012717          	auipc	a4,0x12
    80000b74:	a8f73023          	sd	a5,-1408(a4) # 800125f0 <kmem+0x18>
  release(&kmem.lock);
    80000b78:	00012517          	auipc	a0,0x12
    80000b7c:	a6050513          	addi	a0,a0,-1440 # 800125d8 <kmem>
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
    80000b9e:	a3e50513          	addi	a0,a0,-1474 # 800125d8 <kmem>
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
    80000bd8:	559000ef          	jal	80001930 <mycpu>
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
    80000bfe:	533000ef          	jal	80001930 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x2c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	52b000ef          	jal	80001930 <mycpu>
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
    80000c1a:	517000ef          	jal	80001930 <mycpu>
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
    80000c4c:	4e5000ef          	jal	80001930 <mycpu>
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
    80000c70:	4c1000ef          	jal	80001930 <mycpu>
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
    80000ea6:	277000ef          	jal	8000191c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eaa:	00009717          	auipc	a4,0x9
    80000eae:	62670713          	addi	a4,a4,1574 # 8000a4d0 <started>
  if (cpuid() == 0) {
    80000eb2:	c51d                	beqz	a0,80000ee0 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eb4:	431c                	lw	a5,0(a4)
    80000eb6:	0230000f          	fence	r,rw
    80000eba:	2781                	sext.w	a5,a5
    80000ebc:	dfe5                	beqz	a5,80000eb4 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000ebe:	25f000ef          	jal	8000191c <cpuid>
    80000ec2:	85aa                	mv	a1,a0
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1d450513          	addi	a0,a0,468 # 80007098 <etext+0x98>
    80000ecc:	e3eff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000ed0:	08a000ef          	jal	80000f5a <kvminithart>
    trapinithart(); // install kernel trap vector
    80000ed4:	658010ef          	jal	8000252c <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	321040ef          	jal	800059f8 <plicinithart>
  }

  scheduler();
    80000edc:	759000ef          	jal	80001e34 <scheduler>
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
    80000f10:	2d6000ef          	jal	800011e6 <kvminit>
    kvminithart();      // turn on paging
    80000f14:	046000ef          	jal	80000f5a <kvminithart>
    procinit();         // process table
    80000f18:	14f000ef          	jal	80001866 <procinit>
    shminit();          // shared memory
    80000f1c:	4af010ef          	jal	80002bca <shminit>
    seminit();          // semaphores
    80000f20:	593010ef          	jal	80002cb2 <seminit>
    trapinit();         // trap vectors
    80000f24:	5e4010ef          	jal	80002508 <trapinit>
    trapinithart();     // install kernel trap vector
    80000f28:	604010ef          	jal	8000252c <trapinithart>
    plicinit();         // set up interrupt controller
    80000f2c:	2b3040ef          	jal	800059de <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f30:	2c9040ef          	jal	800059f8 <plicinithart>
    binit();            // buffer cache
    80000f34:	777010ef          	jal	80002eaa <binit>
    iinit();            // inode table
    80000f38:	4c8020ef          	jal	80003400 <iinit>
    fileinit();         // file table
    80000f3c:	4f6030ef          	jal	80004432 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f40:	3af040ef          	jal	80005aee <virtio_disk_init>
    userinit();         // first user process
    80000f44:	4fb000ef          	jal	80001c3e <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f48:	00009797          	auipc	a5,0x9
    80000f4c:	58878793          	addi	a5,a5,1416 # 8000a4d0 <started>
    80000f50:	4705                	li	a4,1
    80000f52:	0310000f          	fence	rw,w
    80000f56:	c398                	sw	a4,0(a5)
    80000f58:	b751                	j	80000edc <main+0x3e>

0000000080000f5a <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f5a:	1141                	addi	sp,sp,-16
    80000f5c:	e406                	sd	ra,8(sp)
    80000f5e:	e022                	sd	s0,0(sp)
    80000f60:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f62:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f66:	00009797          	auipc	a5,0x9
    80000f6a:	5727b783          	ld	a5,1394(a5) # 8000a4d8 <kernel_pagetable>
    80000f6e:	83b1                	srli	a5,a5,0xc
    80000f70:	577d                	li	a4,-1
    80000f72:	177e                	slli	a4,a4,0x3f
    80000f74:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000f76:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f7a:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f7e:	60a2                	ld	ra,8(sp)
    80000f80:	6402                	ld	s0,0(sp)
    80000f82:	0141                	addi	sp,sp,16
    80000f84:	8082                	ret

0000000080000f86 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f86:	7139                	addi	sp,sp,-64
    80000f88:	fc06                	sd	ra,56(sp)
    80000f8a:	f822                	sd	s0,48(sp)
    80000f8c:	f426                	sd	s1,40(sp)
    80000f8e:	f04a                	sd	s2,32(sp)
    80000f90:	ec4e                	sd	s3,24(sp)
    80000f92:	e852                	sd	s4,16(sp)
    80000f94:	e456                	sd	s5,8(sp)
    80000f96:	e05a                	sd	s6,0(sp)
    80000f98:	0080                	addi	s0,sp,64
    80000f9a:	84aa                	mv	s1,a0
    80000f9c:	89ae                	mv	s3,a1
    80000f9e:	8b32                	mv	s6,a2
  if (va >= MAXVA)
    80000fa0:	57fd                	li	a5,-1
    80000fa2:	83e9                	srli	a5,a5,0x1a
    80000fa4:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000fa6:	4ab1                	li	s5,12
  if (va >= MAXVA)
    80000fa8:	04b7e263          	bltu	a5,a1,80000fec <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fac:	0149d933          	srl	s2,s3,s4
    80000fb0:	1ff97913          	andi	s2,s2,511
    80000fb4:	090e                	slli	s2,s2,0x3
    80000fb6:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000fb8:	00093483          	ld	s1,0(s2)
    80000fbc:	0014f793          	andi	a5,s1,1
    80000fc0:	cf85                	beqz	a5,80000ff8 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fc2:	80a9                	srli	s1,s1,0xa
    80000fc4:	04b2                	slli	s1,s1,0xc
  for (int level = 2; level > 0; level--) {
    80000fc6:	3a5d                	addiw	s4,s4,-9
    80000fc8:	ff5a12e3          	bne	s4,s5,80000fac <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fcc:	00c9d513          	srli	a0,s3,0xc
    80000fd0:	1ff57513          	andi	a0,a0,511
    80000fd4:	050e                	slli	a0,a0,0x3
    80000fd6:	9526                	add	a0,a0,s1
}
    80000fd8:	70e2                	ld	ra,56(sp)
    80000fda:	7442                	ld	s0,48(sp)
    80000fdc:	74a2                	ld	s1,40(sp)
    80000fde:	7902                	ld	s2,32(sp)
    80000fe0:	69e2                	ld	s3,24(sp)
    80000fe2:	6a42                	ld	s4,16(sp)
    80000fe4:	6aa2                	ld	s5,8(sp)
    80000fe6:	6b02                	ld	s6,0(sp)
    80000fe8:	6121                	addi	sp,sp,64
    80000fea:	8082                	ret
    panic("walk");
    80000fec:	00006517          	auipc	a0,0x6
    80000ff0:	0c450513          	addi	a0,a0,196 # 800070b0 <etext+0xb0>
    80000ff4:	841ff0ef          	jal	80000834 <panic>
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000ff8:	020b0263          	beqz	s6,8000101c <walk+0x96>
    80000ffc:	b53ff0ef          	jal	80000b4e <kalloc>
    80001000:	84aa                	mv	s1,a0
    80001002:	d979                	beqz	a0,80000fd8 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80001004:	6605                	lui	a2,0x1
    80001006:	4581                	li	a1,0
    80001008:	ce1ff0ef          	jal	80000ce8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000100c:	00c4d793          	srli	a5,s1,0xc
    80001010:	07aa                	slli	a5,a5,0xa
    80001012:	0017e793          	ori	a5,a5,1
    80001016:	00f93023          	sd	a5,0(s2)
    8000101a:	b775                	j	80000fc6 <walk+0x40>
        return 0;
    8000101c:	4501                	li	a0,0
    8000101e:	bf6d                	j	80000fd8 <walk+0x52>

0000000080001020 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80001020:	57fd                	li	a5,-1
    80001022:	83e9                	srli	a5,a5,0x1a
    80001024:	00b7f463          	bgeu	a5,a1,8000102c <walkaddr+0xc>
    return 0;
    80001028:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000102a:	8082                	ret
{
    8000102c:	1141                	addi	sp,sp,-16
    8000102e:	e406                	sd	ra,8(sp)
    80001030:	e022                	sd	s0,0(sp)
    80001032:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001034:	4601                	li	a2,0
    80001036:	f51ff0ef          	jal	80000f86 <walk>
  if (pte == 0)
    8000103a:	c901                	beqz	a0,8000104a <walkaddr+0x2a>
  if ((*pte & PTE_V) == 0)
    8000103c:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    8000103e:	0117f693          	andi	a3,a5,17
    80001042:	4745                	li	a4,17
    return 0;
    80001044:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80001046:	00e68663          	beq	a3,a4,80001052 <walkaddr+0x32>
}
    8000104a:	60a2                	ld	ra,8(sp)
    8000104c:	6402                	ld	s0,0(sp)
    8000104e:	0141                	addi	sp,sp,16
    80001050:	8082                	ret
  pa = PTE2PA(*pte);
    80001052:	83a9                	srli	a5,a5,0xa
    80001054:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001058:	bfcd                	j	8000104a <walkaddr+0x2a>

000000008000105a <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000105a:	715d                	addi	sp,sp,-80
    8000105c:	e486                	sd	ra,72(sp)
    8000105e:	e0a2                	sd	s0,64(sp)
    80001060:	fc26                	sd	s1,56(sp)
    80001062:	f84a                	sd	s2,48(sp)
    80001064:	f44e                	sd	s3,40(sp)
    80001066:	f052                	sd	s4,32(sp)
    80001068:	ec56                	sd	s5,24(sp)
    8000106a:	e85a                	sd	s6,16(sp)
    8000106c:	e45e                	sd	s7,8(sp)
    8000106e:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80001070:	03459793          	slli	a5,a1,0x34
    80001074:	eba1                	bnez	a5,800010c4 <mappages+0x6a>
    80001076:	8a2a                	mv	s4,a0
    80001078:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    8000107a:	03461793          	slli	a5,a2,0x34
    8000107e:	eba9                	bnez	a5,800010d0 <mappages+0x76>
    panic("mappages: size not aligned");

  if (size == 0)
    80001080:	ce31                	beqz	a2,800010dc <mappages+0x82>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    80001082:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    80001086:	80060613          	addi	a2,a2,-2048
    8000108a:	00b60933          	add	s2,a2,a1
  a = va;
    8000108e:	84ae                	mv	s1,a1
  for (;;) {
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001090:	4b05                	li	s6,1
    80001092:	40b689b3          	sub	s3,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    80001096:	6b85                	lui	s7,0x1
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001098:	865a                	mv	a2,s6
    8000109a:	85a6                	mv	a1,s1
    8000109c:	8552                	mv	a0,s4
    8000109e:	ee9ff0ef          	jal	80000f86 <walk>
    800010a2:	c929                	beqz	a0,800010f4 <mappages+0x9a>
    if (*pte & PTE_V)
    800010a4:	611c                	ld	a5,0(a0)
    800010a6:	8b85                	andi	a5,a5,1
    800010a8:	e3a1                	bnez	a5,800010e8 <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010aa:	013487b3          	add	a5,s1,s3
    800010ae:	83b1                	srli	a5,a5,0xc
    800010b0:	07aa                	slli	a5,a5,0xa
    800010b2:	0157e7b3          	or	a5,a5,s5
    800010b6:	0017e793          	ori	a5,a5,1
    800010ba:	e11c                	sd	a5,0(a0)
    if (a == last)
    800010bc:	05248863          	beq	s1,s2,8000110c <mappages+0xb2>
    a += PGSIZE;
    800010c0:	94de                	add	s1,s1,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010c2:	bfd9                	j	80001098 <mappages+0x3e>
    panic("mappages: va not aligned");
    800010c4:	00006517          	auipc	a0,0x6
    800010c8:	ff450513          	addi	a0,a0,-12 # 800070b8 <etext+0xb8>
    800010cc:	f68ff0ef          	jal	80000834 <panic>
    panic("mappages: size not aligned");
    800010d0:	00006517          	auipc	a0,0x6
    800010d4:	00850513          	addi	a0,a0,8 # 800070d8 <etext+0xd8>
    800010d8:	f5cff0ef          	jal	80000834 <panic>
    panic("mappages: size");
    800010dc:	00006517          	auipc	a0,0x6
    800010e0:	01c50513          	addi	a0,a0,28 # 800070f8 <etext+0xf8>
    800010e4:	f50ff0ef          	jal	80000834 <panic>
      panic("mappages: remap");
    800010e8:	00006517          	auipc	a0,0x6
    800010ec:	02050513          	addi	a0,a0,32 # 80007108 <etext+0x108>
    800010f0:	f44ff0ef          	jal	80000834 <panic>
      return -1;
    800010f4:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010f6:	60a6                	ld	ra,72(sp)
    800010f8:	6406                	ld	s0,64(sp)
    800010fa:	74e2                	ld	s1,56(sp)
    800010fc:	7942                	ld	s2,48(sp)
    800010fe:	79a2                	ld	s3,40(sp)
    80001100:	7a02                	ld	s4,32(sp)
    80001102:	6ae2                	ld	s5,24(sp)
    80001104:	6b42                	ld	s6,16(sp)
    80001106:	6ba2                	ld	s7,8(sp)
    80001108:	6161                	addi	sp,sp,80
    8000110a:	8082                	ret
  return 0;
    8000110c:	4501                	li	a0,0
    8000110e:	b7e5                	j	800010f6 <mappages+0x9c>

0000000080001110 <kvmmap>:
{
    80001110:	1141                	addi	sp,sp,-16
    80001112:	e406                	sd	ra,8(sp)
    80001114:	e022                	sd	s0,0(sp)
    80001116:	0800                	addi	s0,sp,16
    80001118:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000111a:	86b2                	mv	a3,a2
    8000111c:	863e                	mv	a2,a5
    8000111e:	f3dff0ef          	jal	8000105a <mappages>
    80001122:	e509                	bnez	a0,8000112c <kvmmap+0x1c>
}
    80001124:	60a2                	ld	ra,8(sp)
    80001126:	6402                	ld	s0,0(sp)
    80001128:	0141                	addi	sp,sp,16
    8000112a:	8082                	ret
    panic("kvmmap");
    8000112c:	00006517          	auipc	a0,0x6
    80001130:	fec50513          	addi	a0,a0,-20 # 80007118 <etext+0x118>
    80001134:	f00ff0ef          	jal	80000834 <panic>

0000000080001138 <kvmmake>:
{
    80001138:	1101                	addi	sp,sp,-32
    8000113a:	ec06                	sd	ra,24(sp)
    8000113c:	e822                	sd	s0,16(sp)
    8000113e:	e426                	sd	s1,8(sp)
    80001140:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    80001142:	a0dff0ef          	jal	80000b4e <kalloc>
    80001146:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001148:	6605                	lui	a2,0x1
    8000114a:	4581                	li	a1,0
    8000114c:	b9dff0ef          	jal	80000ce8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001150:	4719                	li	a4,6
    80001152:	6685                	lui	a3,0x1
    80001154:	10000637          	lui	a2,0x10000
    80001158:	85b2                	mv	a1,a2
    8000115a:	8526                	mv	a0,s1
    8000115c:	fb5ff0ef          	jal	80001110 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001160:	4719                	li	a4,6
    80001162:	6685                	lui	a3,0x1
    80001164:	10001637          	lui	a2,0x10001
    80001168:	85b2                	mv	a1,a2
    8000116a:	8526                	mv	a0,s1
    8000116c:	fa5ff0ef          	jal	80001110 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001170:	4719                	li	a4,6
    80001172:	040006b7          	lui	a3,0x4000
    80001176:	0c000637          	lui	a2,0xc000
    8000117a:	85b2                	mv	a1,a2
    8000117c:	8526                	mv	a0,s1
    8000117e:	f93ff0ef          	jal	80001110 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    80001182:	4729                	li	a4,10
    80001184:	80006697          	auipc	a3,0x80006
    80001188:	e7c68693          	addi	a3,a3,-388 # 7000 <_entry-0x7fff9000>
    8000118c:	4605                	li	a2,1
    8000118e:	067e                	slli	a2,a2,0x1f
    80001190:	85b2                	mv	a1,a2
    80001192:	8526                	mv	a0,s1
    80001194:	f7dff0ef          	jal	80001110 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    80001198:	4719                	li	a4,6
    8000119a:	00006697          	auipc	a3,0x6
    8000119e:	e6668693          	addi	a3,a3,-410 # 80007000 <etext>
    800011a2:	47c5                	li	a5,17
    800011a4:	07ee                	slli	a5,a5,0x1b
    800011a6:	40d786b3          	sub	a3,a5,a3
    800011aa:	00006617          	auipc	a2,0x6
    800011ae:	e5660613          	addi	a2,a2,-426 # 80007000 <etext>
    800011b2:	85b2                	mv	a1,a2
    800011b4:	8526                	mv	a0,s1
    800011b6:	f5bff0ef          	jal	80001110 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011ba:	4729                	li	a4,10
    800011bc:	6685                	lui	a3,0x1
    800011be:	00005617          	auipc	a2,0x5
    800011c2:	e4260613          	addi	a2,a2,-446 # 80006000 <_trampoline>
    800011c6:	040005b7          	lui	a1,0x4000
    800011ca:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011cc:	05b2                	slli	a1,a1,0xc
    800011ce:	8526                	mv	a0,s1
    800011d0:	f41ff0ef          	jal	80001110 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011d4:	8526                	mv	a0,s1
    800011d6:	5ec000ef          	jal	800017c2 <proc_mapstacks>
}
    800011da:	8526                	mv	a0,s1
    800011dc:	60e2                	ld	ra,24(sp)
    800011de:	6442                	ld	s0,16(sp)
    800011e0:	64a2                	ld	s1,8(sp)
    800011e2:	6105                	addi	sp,sp,32
    800011e4:	8082                	ret

00000000800011e6 <kvminit>:
{
    800011e6:	1141                	addi	sp,sp,-16
    800011e8:	e406                	sd	ra,8(sp)
    800011ea:	e022                	sd	s0,0(sp)
    800011ec:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011ee:	f4bff0ef          	jal	80001138 <kvmmake>
    800011f2:	00009797          	auipc	a5,0x9
    800011f6:	2ea7b323          	sd	a0,742(a5) # 8000a4d8 <kernel_pagetable>
}
    800011fa:	60a2                	ld	ra,8(sp)
    800011fc:	6402                	ld	s0,0(sp)
    800011fe:	0141                	addi	sp,sp,16
    80001200:	8082                	ret

0000000080001202 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001202:	1101                	addi	sp,sp,-32
    80001204:	ec06                	sd	ra,24(sp)
    80001206:	e822                	sd	s0,16(sp)
    80001208:	e426                	sd	s1,8(sp)
    8000120a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    8000120c:	943ff0ef          	jal	80000b4e <kalloc>
    80001210:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001212:	c509                	beqz	a0,8000121c <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001214:	6605                	lui	a2,0x1
    80001216:	4581                	li	a1,0
    80001218:	ad1ff0ef          	jal	80000ce8 <memset>
  return pagetable;
}
    8000121c:	8526                	mv	a0,s1
    8000121e:	60e2                	ld	ra,24(sp)
    80001220:	6442                	ld	s0,16(sp)
    80001222:	64a2                	ld	s1,8(sp)
    80001224:	6105                	addi	sp,sp,32
    80001226:	8082                	ret

0000000080001228 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001228:	7139                	addi	sp,sp,-64
    8000122a:	fc06                	sd	ra,56(sp)
    8000122c:	f822                	sd	s0,48(sp)
    8000122e:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80001230:	03459793          	slli	a5,a1,0x34
    80001234:	e38d                	bnez	a5,80001256 <uvmunmap+0x2e>
    80001236:	f04a                	sd	s2,32(sp)
    80001238:	ec4e                	sd	s3,24(sp)
    8000123a:	e852                	sd	s4,16(sp)
    8000123c:	e456                	sd	s5,8(sp)
    8000123e:	e05a                	sd	s6,0(sp)
    80001240:	8a2a                	mv	s4,a0
    80001242:	892e                	mv	s2,a1
    80001244:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    80001246:	0632                	slli	a2,a2,0xc
    80001248:	00b609b3          	add	s3,a2,a1
    8000124c:	6b05                	lui	s6,0x1
    8000124e:	0535f963          	bgeu	a1,s3,800012a0 <uvmunmap+0x78>
    80001252:	f426                	sd	s1,40(sp)
    80001254:	a015                	j	80001278 <uvmunmap+0x50>
    80001256:	f426                	sd	s1,40(sp)
    80001258:	f04a                	sd	s2,32(sp)
    8000125a:	ec4e                	sd	s3,24(sp)
    8000125c:	e852                	sd	s4,16(sp)
    8000125e:	e456                	sd	s5,8(sp)
    80001260:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    80001262:	00006517          	auipc	a0,0x6
    80001266:	ebe50513          	addi	a0,a0,-322 # 80007120 <etext+0x120>
    8000126a:	dcaff0ef          	jal	80000834 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    8000126e:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    80001272:	995a                	add	s2,s2,s6
    80001274:	03397563          	bgeu	s2,s3,8000129e <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001278:	4601                	li	a2,0
    8000127a:	85ca                	mv	a1,s2
    8000127c:	8552                	mv	a0,s4
    8000127e:	d09ff0ef          	jal	80000f86 <walk>
    80001282:	84aa                	mv	s1,a0
    80001284:	d57d                	beqz	a0,80001272 <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    80001286:	611c                	ld	a5,0(a0)
    80001288:	0017f713          	andi	a4,a5,1
    8000128c:	d37d                	beqz	a4,80001272 <uvmunmap+0x4a>
    if (do_free) {
    8000128e:	fe0a80e3          	beqz	s5,8000126e <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001292:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    80001294:	00c79513          	slli	a0,a5,0xc
    80001298:	fceff0ef          	jal	80000a66 <kfree>
    8000129c:	bfc9                	j	8000126e <uvmunmap+0x46>
    8000129e:	74a2                	ld	s1,40(sp)
    800012a0:	7902                	ld	s2,32(sp)
    800012a2:	69e2                	ld	s3,24(sp)
    800012a4:	6a42                	ld	s4,16(sp)
    800012a6:	6aa2                	ld	s5,8(sp)
    800012a8:	6b02                	ld	s6,0(sp)
  }
}
    800012aa:	70e2                	ld	ra,56(sp)
    800012ac:	7442                	ld	s0,48(sp)
    800012ae:	6121                	addi	sp,sp,64
    800012b0:	8082                	ret

00000000800012b2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012b2:	1101                	addi	sp,sp,-32
    800012b4:	ec06                	sd	ra,24(sp)
    800012b6:	e822                	sd	s0,16(sp)
    800012b8:	e426                	sd	s1,8(sp)
    800012ba:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    800012bc:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    800012be:	00b67d63          	bgeu	a2,a1,800012d8 <uvmdealloc+0x26>
    800012c2:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    800012c4:	6785                	lui	a5,0x1
    800012c6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012c8:	00f60733          	add	a4,a2,a5
    800012cc:	76fd                	lui	a3,0xfffff
    800012ce:	8f75                	and	a4,a4,a3
    800012d0:	97ae                	add	a5,a5,a1
    800012d2:	8ff5                	and	a5,a5,a3
    800012d4:	00f76863          	bltu	a4,a5,800012e4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012d8:	8526                	mv	a0,s1
    800012da:	60e2                	ld	ra,24(sp)
    800012dc:	6442                	ld	s0,16(sp)
    800012de:	64a2                	ld	s1,8(sp)
    800012e0:	6105                	addi	sp,sp,32
    800012e2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012e4:	8f99                	sub	a5,a5,a4
    800012e6:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012e8:	4685                	li	a3,1
    800012ea:	0007861b          	sext.w	a2,a5
    800012ee:	85ba                	mv	a1,a4
    800012f0:	f39ff0ef          	jal	80001228 <uvmunmap>
    800012f4:	b7d5                	j	800012d8 <uvmdealloc+0x26>

00000000800012f6 <uvmalloc>:
  if (newsz < oldsz)
    800012f6:	0ab66163          	bltu	a2,a1,80001398 <uvmalloc+0xa2>
{
    800012fa:	715d                	addi	sp,sp,-80
    800012fc:	e486                	sd	ra,72(sp)
    800012fe:	e0a2                	sd	s0,64(sp)
    80001300:	f84a                	sd	s2,48(sp)
    80001302:	f052                	sd	s4,32(sp)
    80001304:	ec56                	sd	s5,24(sp)
    80001306:	e45e                	sd	s7,8(sp)
    80001308:	0880                	addi	s0,sp,80
    8000130a:	8aaa                	mv	s5,a0
    8000130c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000130e:	6785                	lui	a5,0x1
    80001310:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001312:	95be                	add	a1,a1,a5
    80001314:	77fd                	lui	a5,0xfffff
    80001316:	00f5f933          	and	s2,a1,a5
    8000131a:	8bca                	mv	s7,s2
  for (a = oldsz; a < newsz; a += PGSIZE) {
    8000131c:	08c97063          	bgeu	s2,a2,8000139c <uvmalloc+0xa6>
    80001320:	fc26                	sd	s1,56(sp)
    80001322:	f44e                	sd	s3,40(sp)
    80001324:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    80001326:	6985                	lui	s3,0x1
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001328:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000132c:	823ff0ef          	jal	80000b4e <kalloc>
    80001330:	84aa                	mv	s1,a0
    if (mem == 0) {
    80001332:	c50d                	beqz	a0,8000135c <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    80001334:	864e                	mv	a2,s3
    80001336:	4581                	li	a1,0
    80001338:	9b1ff0ef          	jal	80000ce8 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    8000133c:	875a                	mv	a4,s6
    8000133e:	86a6                	mv	a3,s1
    80001340:	864e                	mv	a2,s3
    80001342:	85ca                	mv	a1,s2
    80001344:	8556                	mv	a0,s5
    80001346:	d15ff0ef          	jal	8000105a <mappages>
    8000134a:	e915                	bnez	a0,8000137e <uvmalloc+0x88>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    8000134c:	994e                	add	s2,s2,s3
    8000134e:	fd496fe3          	bltu	s2,s4,8000132c <uvmalloc+0x36>
  return newsz;
    80001352:	8552                	mv	a0,s4
    80001354:	74e2                	ld	s1,56(sp)
    80001356:	79a2                	ld	s3,40(sp)
    80001358:	6b42                	ld	s6,16(sp)
    8000135a:	a811                	j	8000136e <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    8000135c:	865e                	mv	a2,s7
    8000135e:	85ca                	mv	a1,s2
    80001360:	8556                	mv	a0,s5
    80001362:	f51ff0ef          	jal	800012b2 <uvmdealloc>
      return 0;
    80001366:	4501                	li	a0,0
    80001368:	74e2                	ld	s1,56(sp)
    8000136a:	79a2                	ld	s3,40(sp)
    8000136c:	6b42                	ld	s6,16(sp)
}
    8000136e:	60a6                	ld	ra,72(sp)
    80001370:	6406                	ld	s0,64(sp)
    80001372:	7942                	ld	s2,48(sp)
    80001374:	7a02                	ld	s4,32(sp)
    80001376:	6ae2                	ld	s5,24(sp)
    80001378:	6ba2                	ld	s7,8(sp)
    8000137a:	6161                	addi	sp,sp,80
    8000137c:	8082                	ret
      kfree(mem);
    8000137e:	8526                	mv	a0,s1
    80001380:	ee6ff0ef          	jal	80000a66 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001384:	865e                	mv	a2,s7
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	f29ff0ef          	jal	800012b2 <uvmdealloc>
      return 0;
    8000138e:	4501                	li	a0,0
    80001390:	74e2                	ld	s1,56(sp)
    80001392:	79a2                	ld	s3,40(sp)
    80001394:	6b42                	ld	s6,16(sp)
    80001396:	bfe1                	j	8000136e <uvmalloc+0x78>
    return oldsz;
    80001398:	852e                	mv	a0,a1
}
    8000139a:	8082                	ret
  return newsz;
    8000139c:	8532                	mv	a0,a2
    8000139e:	bfc1                	j	8000136e <uvmalloc+0x78>

00000000800013a0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013a0:	7179                	addi	sp,sp,-48
    800013a2:	f406                	sd	ra,40(sp)
    800013a4:	f022                	sd	s0,32(sp)
    800013a6:	ec26                	sd	s1,24(sp)
    800013a8:	e84a                	sd	s2,16(sp)
    800013aa:	e44e                	sd	s3,8(sp)
    800013ac:	1800                	addi	s0,sp,48
    800013ae:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    800013b0:	84aa                	mv	s1,a0
    800013b2:	6905                	lui	s2,0x1
    800013b4:	992a                	add	s2,s2,a0
    800013b6:	a811                	j	800013ca <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if (pte & PTE_V) {
      panic("freewalk: leaf");
    800013b8:	00006517          	auipc	a0,0x6
    800013bc:	d8050513          	addi	a0,a0,-640 # 80007138 <etext+0x138>
    800013c0:	c74ff0ef          	jal	80000834 <panic>
  for (int i = 0; i < 512; i++) {
    800013c4:	04a1                	addi	s1,s1,8
    800013c6:	03248163          	beq	s1,s2,800013e8 <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013ca:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013cc:	0017f713          	andi	a4,a5,1
    800013d0:	db75                	beqz	a4,800013c4 <freewalk+0x24>
    800013d2:	00e7f713          	andi	a4,a5,14
    800013d6:	f36d                	bnez	a4,800013b8 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800013d8:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013da:	00c79513          	slli	a0,a5,0xc
    800013de:	fc3ff0ef          	jal	800013a0 <freewalk>
      pagetable[i] = 0;
    800013e2:	0004b023          	sd	zero,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013e6:	bff9                	j	800013c4 <freewalk+0x24>
    }
  }
  kfree((void *)pagetable);
    800013e8:	854e                	mv	a0,s3
    800013ea:	e7cff0ef          	jal	80000a66 <kfree>
}
    800013ee:	70a2                	ld	ra,40(sp)
    800013f0:	7402                	ld	s0,32(sp)
    800013f2:	64e2                	ld	s1,24(sp)
    800013f4:	6942                	ld	s2,16(sp)
    800013f6:	69a2                	ld	s3,8(sp)
    800013f8:	6145                	addi	sp,sp,48
    800013fa:	8082                	ret

00000000800013fc <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013fc:	1101                	addi	sp,sp,-32
    800013fe:	ec06                	sd	ra,24(sp)
    80001400:	e822                	sd	s0,16(sp)
    80001402:	e426                	sd	s1,8(sp)
    80001404:	1000                	addi	s0,sp,32
    80001406:	84aa                	mv	s1,a0
  if (sz > 0)
    80001408:	e989                	bnez	a1,8000141a <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    8000140a:	8526                	mv	a0,s1
    8000140c:	f95ff0ef          	jal	800013a0 <freewalk>
}
    80001410:	60e2                	ld	ra,24(sp)
    80001412:	6442                	ld	s0,16(sp)
    80001414:	64a2                	ld	s1,8(sp)
    80001416:	6105                	addi	sp,sp,32
    80001418:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    8000141a:	6785                	lui	a5,0x1
    8000141c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000141e:	95be                	add	a1,a1,a5
    80001420:	4685                	li	a3,1
    80001422:	00c5d613          	srli	a2,a1,0xc
    80001426:	4581                	li	a1,0
    80001428:	e01ff0ef          	jal	80001228 <uvmunmap>
    8000142c:	bff9                	j	8000140a <uvmfree+0xe>

000000008000142e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    8000142e:	ca59                	beqz	a2,800014c4 <uvmcopy+0x96>
{
    80001430:	715d                	addi	sp,sp,-80
    80001432:	e486                	sd	ra,72(sp)
    80001434:	e0a2                	sd	s0,64(sp)
    80001436:	fc26                	sd	s1,56(sp)
    80001438:	f84a                	sd	s2,48(sp)
    8000143a:	f44e                	sd	s3,40(sp)
    8000143c:	f052                	sd	s4,32(sp)
    8000143e:	ec56                	sd	s5,24(sp)
    80001440:	e85a                	sd	s6,16(sp)
    80001442:	e45e                	sd	s7,8(sp)
    80001444:	0880                	addi	s0,sp,80
    80001446:	8b2a                	mv	s6,a0
    80001448:	8bae                	mv	s7,a1
    8000144a:	8ab2                	mv	s5,a2
  for (i = 0; i < sz; i += PGSIZE) {
    8000144c:	4481                	li	s1,0
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if ((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    8000144e:	6a05                	lui	s4,0x1
    80001450:	a021                	j	80001458 <uvmcopy+0x2a>
  for (i = 0; i < sz; i += PGSIZE) {
    80001452:	94d2                	add	s1,s1,s4
    80001454:	0554fc63          	bgeu	s1,s5,800014ac <uvmcopy+0x7e>
    if ((pte = walk(old, i, 0)) == 0)
    80001458:	4601                	li	a2,0
    8000145a:	85a6                	mv	a1,s1
    8000145c:	855a                	mv	a0,s6
    8000145e:	b29ff0ef          	jal	80000f86 <walk>
    80001462:	d965                	beqz	a0,80001452 <uvmcopy+0x24>
    if ((*pte & PTE_V) == 0)
    80001464:	00053983          	ld	s3,0(a0)
    80001468:	0019f793          	andi	a5,s3,1
    8000146c:	d3fd                	beqz	a5,80001452 <uvmcopy+0x24>
    if ((mem = kalloc()) == 0)
    8000146e:	ee0ff0ef          	jal	80000b4e <kalloc>
    80001472:	892a                	mv	s2,a0
    80001474:	c11d                	beqz	a0,8000149a <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    80001476:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char *)pa, PGSIZE);
    8000147a:	8652                	mv	a2,s4
    8000147c:	05b2                	slli	a1,a1,0xc
    8000147e:	8cbff0ef          	jal	80000d48 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    80001482:	3ff9f713          	andi	a4,s3,1023
    80001486:	86ca                	mv	a3,s2
    80001488:	8652                	mv	a2,s4
    8000148a:	85a6                	mv	a1,s1
    8000148c:	855e                	mv	a0,s7
    8000148e:	bcdff0ef          	jal	8000105a <mappages>
    80001492:	d161                	beqz	a0,80001452 <uvmcopy+0x24>
      kfree(mem);
    80001494:	854a                	mv	a0,s2
    80001496:	dd0ff0ef          	jal	80000a66 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000149a:	4685                	li	a3,1
    8000149c:	00c4d613          	srli	a2,s1,0xc
    800014a0:	4581                	li	a1,0
    800014a2:	855e                	mv	a0,s7
    800014a4:	d85ff0ef          	jal	80001228 <uvmunmap>
  return -1;
    800014a8:	557d                	li	a0,-1
    800014aa:	a011                	j	800014ae <uvmcopy+0x80>
  return 0;
    800014ac:	4501                	li	a0,0
}
    800014ae:	60a6                	ld	ra,72(sp)
    800014b0:	6406                	ld	s0,64(sp)
    800014b2:	74e2                	ld	s1,56(sp)
    800014b4:	7942                	ld	s2,48(sp)
    800014b6:	79a2                	ld	s3,40(sp)
    800014b8:	7a02                	ld	s4,32(sp)
    800014ba:	6ae2                	ld	s5,24(sp)
    800014bc:	6b42                	ld	s6,16(sp)
    800014be:	6ba2                	ld	s7,8(sp)
    800014c0:	6161                	addi	sp,sp,80
    800014c2:	8082                	ret
  return 0;
    800014c4:	4501                	li	a0,0
}
    800014c6:	8082                	ret

00000000800014c8 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014c8:	1141                	addi	sp,sp,-16
    800014ca:	e406                	sd	ra,8(sp)
    800014cc:	e022                	sd	s0,0(sp)
    800014ce:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    800014d0:	4601                	li	a2,0
    800014d2:	ab5ff0ef          	jal	80000f86 <walk>
  if (pte == 0)
    800014d6:	c901                	beqz	a0,800014e6 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014d8:	611c                	ld	a5,0(a0)
    800014da:	9bbd                	andi	a5,a5,-17
    800014dc:	e11c                	sd	a5,0(a0)
}
    800014de:	60a2                	ld	ra,8(sp)
    800014e0:	6402                	ld	s0,0(sp)
    800014e2:	0141                	addi	sp,sp,16
    800014e4:	8082                	ret
    panic("uvmclear");
    800014e6:	00006517          	auipc	a0,0x6
    800014ea:	c6250513          	addi	a0,a0,-926 # 80007148 <etext+0x148>
    800014ee:	b46ff0ef          	jal	80000834 <panic>

00000000800014f2 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800014f2:	1141                	addi	sp,sp,-16
    800014f4:	e406                	sd	ra,8(sp)
    800014f6:	e022                	sd	s0,0(sp)
    800014f8:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800014fa:	4601                	li	a2,0
    800014fc:	a8bff0ef          	jal	80000f86 <walk>
  if (pte == 0) {
    80001500:	c119                	beqz	a0,80001506 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V) {
    80001502:	6108                	ld	a0,0(a0)
    80001504:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001506:	60a2                	ld	ra,8(sp)
    80001508:	6402                	ld	s0,0(sp)
    8000150a:	0141                	addi	sp,sp,16
    8000150c:	8082                	ret

000000008000150e <vmfault>:
{
    8000150e:	7179                	addi	sp,sp,-48
    80001510:	f406                	sd	ra,40(sp)
    80001512:	f022                	sd	s0,32(sp)
    80001514:	e052                	sd	s4,0(sp)
    80001516:	1800                	addi	s0,sp,48
    return 0;
    80001518:	4a01                	li	s4,0
  if (va >= psz)
    8000151a:	00b66863          	bltu	a2,a1,8000152a <vmfault+0x1c>
}
    8000151e:	8552                	mv	a0,s4
    80001520:	70a2                	ld	ra,40(sp)
    80001522:	7402                	ld	s0,32(sp)
    80001524:	6a02                	ld	s4,0(sp)
    80001526:	6145                	addi	sp,sp,48
    80001528:	8082                	ret
    8000152a:	ec26                	sd	s1,24(sp)
    8000152c:	e44e                	sd	s3,8(sp)
    8000152e:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    80001530:	77fd                	lui	a5,0xfffff
    80001532:	00f679b3          	and	s3,a2,a5
  if (ismapped(pagetable, va)) {
    80001536:	85ce                	mv	a1,s3
    80001538:	fbbff0ef          	jal	800014f2 <ismapped>
    return 0;
    8000153c:	4a01                	li	s4,0
  if (ismapped(pagetable, va)) {
    8000153e:	c501                	beqz	a0,80001546 <vmfault+0x38>
    80001540:	64e2                	ld	s1,24(sp)
    80001542:	69a2                	ld	s3,8(sp)
    80001544:	bfe9                	j	8000151e <vmfault+0x10>
    80001546:	e84a                	sd	s2,16(sp)
  mem = (uint64)kalloc();
    80001548:	e06ff0ef          	jal	80000b4e <kalloc>
    8000154c:	892a                	mv	s2,a0
  if (mem == 0)
    8000154e:	c915                	beqz	a0,80001582 <vmfault+0x74>
  mem = (uint64)kalloc();
    80001550:	8a2a                	mv	s4,a0
  memset((void *)mem, 0, PGSIZE);
    80001552:	6605                	lui	a2,0x1
    80001554:	4581                	li	a1,0
    80001556:	f92ff0ef          	jal	80000ce8 <memset>
  if (mappages(pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    8000155a:	4759                	li	a4,22
    8000155c:	86ca                	mv	a3,s2
    8000155e:	6605                	lui	a2,0x1
    80001560:	85ce                	mv	a1,s3
    80001562:	8526                	mv	a0,s1
    80001564:	af7ff0ef          	jal	8000105a <mappages>
    80001568:	e509                	bnez	a0,80001572 <vmfault+0x64>
    8000156a:	64e2                	ld	s1,24(sp)
    8000156c:	6942                	ld	s2,16(sp)
    8000156e:	69a2                	ld	s3,8(sp)
    80001570:	b77d                	j	8000151e <vmfault+0x10>
    kfree((void *)mem);
    80001572:	854a                	mv	a0,s2
    80001574:	cf2ff0ef          	jal	80000a66 <kfree>
    return 0;
    80001578:	4a01                	li	s4,0
    8000157a:	64e2                	ld	s1,24(sp)
    8000157c:	6942                	ld	s2,16(sp)
    8000157e:	69a2                	ld	s3,8(sp)
    80001580:	bf79                	j	8000151e <vmfault+0x10>
    80001582:	64e2                	ld	s1,24(sp)
    80001584:	6942                	ld	s2,16(sp)
    80001586:	69a2                	ld	s3,8(sp)
    80001588:	bf59                	j	8000151e <vmfault+0x10>

000000008000158a <copyout>:
  while (len > 0) {
    8000158a:	cf49                	beqz	a4,80001624 <copyout+0x9a>
{
    8000158c:	7159                	addi	sp,sp,-112
    8000158e:	f486                	sd	ra,104(sp)
    80001590:	f0a2                	sd	s0,96(sp)
    80001592:	eca6                	sd	s1,88(sp)
    80001594:	e8ca                	sd	s2,80(sp)
    80001596:	e4ce                	sd	s3,72(sp)
    80001598:	e0d2                	sd	s4,64(sp)
    8000159a:	fc56                	sd	s5,56(sp)
    8000159c:	f85a                	sd	s6,48(sp)
    8000159e:	f45e                	sd	s7,40(sp)
    800015a0:	f062                	sd	s8,32(sp)
    800015a2:	ec66                	sd	s9,24(sp)
    800015a4:	e86a                	sd	s10,16(sp)
    800015a6:	e46e                	sd	s11,8(sp)
    800015a8:	1880                	addi	s0,sp,112
    800015aa:	8baa                	mv	s7,a0
    800015ac:	8dae                	mv	s11,a1
    800015ae:	8a32                	mv	s4,a2
    800015b0:	8b36                	mv	s6,a3
    800015b2:	8aba                	mv	s5,a4
    va0 = PGROUNDDOWN(dstva);
    800015b4:	7d7d                	lui	s10,0xfffff
    if (va0 >= MAXVA)
    800015b6:	5cfd                	li	s9,-1
    800015b8:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    800015bc:	6c05                	lui	s8,0x1
    800015be:	a005                	j	800015de <copyout+0x54>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015c0:	409a0533          	sub	a0,s4,s1
    800015c4:	0009061b          	sext.w	a2,s2
    800015c8:	85da                	mv	a1,s6
    800015ca:	954e                	add	a0,a0,s3
    800015cc:	f7cff0ef          	jal	80000d48 <memmove>
    len -= n;
    800015d0:	412a8ab3          	sub	s5,s5,s2
    src += n;
    800015d4:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    800015d6:	01848a33          	add	s4,s1,s8
  while (len > 0) {
    800015da:	040a8363          	beqz	s5,80001620 <copyout+0x96>
    va0 = PGROUNDDOWN(dstva);
    800015de:	01aa74b3          	and	s1,s4,s10
    if (va0 >= MAXVA)
    800015e2:	049ce363          	bltu	s9,s1,80001628 <copyout+0x9e>
    pa0 = walkaddr(pagetable, va0);
    800015e6:	85a6                	mv	a1,s1
    800015e8:	855e                	mv	a0,s7
    800015ea:	a37ff0ef          	jal	80001020 <walkaddr>
    800015ee:	89aa                	mv	s3,a0
    if (pa0 == 0) {
    800015f0:	e909                	bnez	a0,80001602 <copyout+0x78>
      if ((pa0 = vmfault(pagetable, psz, va0, 0)) == 0) {
    800015f2:	4681                	li	a3,0
    800015f4:	8626                	mv	a2,s1
    800015f6:	85ee                	mv	a1,s11
    800015f8:	855e                	mv	a0,s7
    800015fa:	f15ff0ef          	jal	8000150e <vmfault>
    800015fe:	89aa                	mv	s3,a0
    80001600:	c521                	beqz	a0,80001648 <copyout+0xbe>
    pte = walk(pagetable, va0, 0);
    80001602:	4601                	li	a2,0
    80001604:	85a6                	mv	a1,s1
    80001606:	855e                	mv	a0,s7
    80001608:	97fff0ef          	jal	80000f86 <walk>
    if ((*pte & PTE_W) == 0)
    8000160c:	611c                	ld	a5,0(a0)
    8000160e:	8b91                	andi	a5,a5,4
    80001610:	cf95                	beqz	a5,8000164c <copyout+0xc2>
    n = PGSIZE - (dstva - va0);
    80001612:	41448933          	sub	s2,s1,s4
    80001616:	9962                	add	s2,s2,s8
    if (n > len)
    80001618:	fb2af4e3          	bgeu	s5,s2,800015c0 <copyout+0x36>
    8000161c:	8956                	mv	s2,s5
    8000161e:	b74d                	j	800015c0 <copyout+0x36>
  return 0;
    80001620:	4501                	li	a0,0
    80001622:	a021                	j	8000162a <copyout+0xa0>
    80001624:	4501                	li	a0,0
}
    80001626:	8082                	ret
      return -1;
    80001628:	557d                	li	a0,-1
}
    8000162a:	70a6                	ld	ra,104(sp)
    8000162c:	7406                	ld	s0,96(sp)
    8000162e:	64e6                	ld	s1,88(sp)
    80001630:	6946                	ld	s2,80(sp)
    80001632:	69a6                	ld	s3,72(sp)
    80001634:	6a06                	ld	s4,64(sp)
    80001636:	7ae2                	ld	s5,56(sp)
    80001638:	7b42                	ld	s6,48(sp)
    8000163a:	7ba2                	ld	s7,40(sp)
    8000163c:	7c02                	ld	s8,32(sp)
    8000163e:	6ce2                	ld	s9,24(sp)
    80001640:	6d42                	ld	s10,16(sp)
    80001642:	6da2                	ld	s11,8(sp)
    80001644:	6165                	addi	sp,sp,112
    80001646:	8082                	ret
        return -1;
    80001648:	557d                	li	a0,-1
    8000164a:	b7c5                	j	8000162a <copyout+0xa0>
      return -1;
    8000164c:	557d                	li	a0,-1
    8000164e:	bff1                	j	8000162a <copyout+0xa0>

0000000080001650 <copyin>:
  while (len > 0) {
    80001650:	cf41                	beqz	a4,800016e8 <copyin+0x98>
{
    80001652:	711d                	addi	sp,sp,-96
    80001654:	ec86                	sd	ra,88(sp)
    80001656:	e8a2                	sd	s0,80(sp)
    80001658:	e4a6                	sd	s1,72(sp)
    8000165a:	e0ca                	sd	s2,64(sp)
    8000165c:	fc4e                	sd	s3,56(sp)
    8000165e:	f852                	sd	s4,48(sp)
    80001660:	f456                	sd	s5,40(sp)
    80001662:	f05a                	sd	s6,32(sp)
    80001664:	ec5e                	sd	s7,24(sp)
    80001666:	e862                	sd	s8,16(sp)
    80001668:	e466                	sd	s9,8(sp)
    8000166a:	e06a                	sd	s10,0(sp)
    8000166c:	1080                	addi	s0,sp,96
    8000166e:	8baa                	mv	s7,a0
    80001670:	8cae                	mv	s9,a1
    80001672:	8ab2                	mv	s5,a2
    80001674:	8936                	mv	s2,a3
    80001676:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    80001678:	7c7d                	lui	s8,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    8000167a:	4d05                	li	s10,1
    n = PGSIZE - (srcva - va0);
    8000167c:	6b05                	lui	s6,0x1
    8000167e:	a035                	j	800016aa <copyin+0x5a>
    80001680:	412984b3          	sub	s1,s3,s2
    80001684:	94da                	add	s1,s1,s6
    if (n > len)
    80001686:	009a7363          	bgeu	s4,s1,8000168c <copyin+0x3c>
    8000168a:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000168c:	413905b3          	sub	a1,s2,s3
    80001690:	0004861b          	sext.w	a2,s1
    80001694:	95aa                	add	a1,a1,a0
    80001696:	8556                	mv	a0,s5
    80001698:	eb0ff0ef          	jal	80000d48 <memmove>
    len -= n;
    8000169c:	409a0a33          	sub	s4,s4,s1
    dst += n;
    800016a0:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    800016a2:	01698933          	add	s2,s3,s6
  while (len > 0) {
    800016a6:	020a0263          	beqz	s4,800016ca <copyin+0x7a>
    va0 = PGROUNDDOWN(srcva);
    800016aa:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    800016ae:	85ce                	mv	a1,s3
    800016b0:	855e                	mv	a0,s7
    800016b2:	96fff0ef          	jal	80001020 <walkaddr>
    if (pa0 == 0) {
    800016b6:	f569                	bnez	a0,80001680 <copyin+0x30>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800016b8:	86ea                	mv	a3,s10
    800016ba:	864e                	mv	a2,s3
    800016bc:	85e6                	mv	a1,s9
    800016be:	855e                	mv	a0,s7
    800016c0:	e4fff0ef          	jal	8000150e <vmfault>
    800016c4:	fd55                	bnez	a0,80001680 <copyin+0x30>
        return -1;
    800016c6:	557d                	li	a0,-1
    800016c8:	a011                	j	800016cc <copyin+0x7c>
  return 0;
    800016ca:	4501                	li	a0,0
}
    800016cc:	60e6                	ld	ra,88(sp)
    800016ce:	6446                	ld	s0,80(sp)
    800016d0:	64a6                	ld	s1,72(sp)
    800016d2:	6906                	ld	s2,64(sp)
    800016d4:	79e2                	ld	s3,56(sp)
    800016d6:	7a42                	ld	s4,48(sp)
    800016d8:	7aa2                	ld	s5,40(sp)
    800016da:	7b02                	ld	s6,32(sp)
    800016dc:	6be2                	ld	s7,24(sp)
    800016de:	6c42                	ld	s8,16(sp)
    800016e0:	6ca2                	ld	s9,8(sp)
    800016e2:	6d02                	ld	s10,0(sp)
    800016e4:	6125                	addi	sp,sp,96
    800016e6:	8082                	ret
  return 0;
    800016e8:	4501                	li	a0,0
}
    800016ea:	8082                	ret

00000000800016ec <copyinstr>:
  while (got_null == 0 && max > 0) {
    800016ec:	c769                	beqz	a4,800017b6 <copyinstr+0xca>
{
    800016ee:	711d                	addi	sp,sp,-96
    800016f0:	ec86                	sd	ra,88(sp)
    800016f2:	e8a2                	sd	s0,80(sp)
    800016f4:	e4a6                	sd	s1,72(sp)
    800016f6:	e0ca                	sd	s2,64(sp)
    800016f8:	fc4e                	sd	s3,56(sp)
    800016fa:	f852                	sd	s4,48(sp)
    800016fc:	f456                	sd	s5,40(sp)
    800016fe:	f05a                	sd	s6,32(sp)
    80001700:	ec5e                	sd	s7,24(sp)
    80001702:	e862                	sd	s8,16(sp)
    80001704:	e466                	sd	s9,8(sp)
    80001706:	1080                	addi	s0,sp,96
    80001708:	8b2a                	mv	s6,a0
    8000170a:	8c2e                	mv	s8,a1
    8000170c:	89b2                	mv	s3,a2
    8000170e:	84b6                	mv	s1,a3
    80001710:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    80001712:	7bfd                	lui	s7,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001714:	4c85                	li	s9,1
    n = PGSIZE - (srcva - va0);
    80001716:	6a85                	lui	s5,0x1
    80001718:	a881                	j	80001768 <copyinstr+0x7c>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    8000171a:	86e6                	mv	a3,s9
    8000171c:	864a                	mv	a2,s2
    8000171e:	85e2                	mv	a1,s8
    80001720:	855a                	mv	a0,s6
    80001722:	dedff0ef          	jal	8000150e <vmfault>
    80001726:	e921                	bnez	a0,80001776 <copyinstr+0x8a>
        return -1;
    80001728:	557d                	li	a0,-1
    8000172a:	a801                	j	8000173a <copyinstr+0x4e>
        *dst = '\0';
    8000172c:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb3e0>
        got_null = 1;
    80001730:	4785                	li	a5,1
  if (got_null) {
    80001732:	0017c793          	xori	a5,a5,1
    80001736:	40f0053b          	negw	a0,a5
}
    8000173a:	60e6                	ld	ra,88(sp)
    8000173c:	6446                	ld	s0,80(sp)
    8000173e:	64a6                	ld	s1,72(sp)
    80001740:	6906                	ld	s2,64(sp)
    80001742:	79e2                	ld	s3,56(sp)
    80001744:	7a42                	ld	s4,48(sp)
    80001746:	7aa2                	ld	s5,40(sp)
    80001748:	7b02                	ld	s6,32(sp)
    8000174a:	6be2                	ld	s7,24(sp)
    8000174c:	6c42                	ld	s8,16(sp)
    8000174e:	6ca2                	ld	s9,8(sp)
    80001750:	6125                	addi	sp,sp,96
    80001752:	8082                	ret
    80001754:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80001758:	974e                	add	a4,a4,s3
      --max;
    8000175a:	40b70a33          	sub	s4,a4,a1
    srcva = va0 + PGSIZE;
    8000175e:	015904b3          	add	s1,s2,s5
  while (got_null == 0 && max > 0) {
    80001762:	04e58463          	beq	a1,a4,800017aa <copyinstr+0xbe>
{
    80001766:	89be                	mv	s3,a5
    va0 = PGROUNDDOWN(srcva);
    80001768:	0174f933          	and	s2,s1,s7
    pa0 = walkaddr(pagetable, va0);
    8000176c:	85ca                	mv	a1,s2
    8000176e:	855a                	mv	a0,s6
    80001770:	8b1ff0ef          	jal	80001020 <walkaddr>
    if (pa0 == 0) {
    80001774:	d15d                	beqz	a0,8000171a <copyinstr+0x2e>
    n = PGSIZE - (srcva - va0);
    80001776:	40990633          	sub	a2,s2,s1
    8000177a:	9656                	add	a2,a2,s5
    if (n > max)
    8000177c:	00ca7363          	bgeu	s4,a2,80001782 <copyinstr+0x96>
    80001780:	8652                	mv	a2,s4
    while (n > 0) {
    80001782:	c615                	beqz	a2,800017ae <copyinstr+0xc2>
    char *p = (char *)(pa0 + (srcva - va0));
    80001784:	412484b3          	sub	s1,s1,s2
    80001788:	94aa                	add	s1,s1,a0
    8000178a:	87ce                	mv	a5,s3
      if (*p == '\0') {
    8000178c:	413484b3          	sub	s1,s1,s3
    while (n > 0) {
    80001790:	964e                	add	a2,a2,s3
    80001792:	85be                	mv	a1,a5
      if (*p == '\0') {
    80001794:	00f48733          	add	a4,s1,a5
    80001798:	00074683          	lbu	a3,0(a4)
    8000179c:	dac1                	beqz	a3,8000172c <copyinstr+0x40>
        *dst = *p;
    8000179e:	00d78023          	sb	a3,0(a5)
      dst++;
    800017a2:	0785                	addi	a5,a5,1
    while (n > 0) {
    800017a4:	fec797e3          	bne	a5,a2,80001792 <copyinstr+0xa6>
    800017a8:	b775                	j	80001754 <copyinstr+0x68>
    800017aa:	4781                	li	a5,0
    800017ac:	b759                	j	80001732 <copyinstr+0x46>
    srcva = va0 + PGSIZE;
    800017ae:	6485                	lui	s1,0x1
    800017b0:	94ca                	add	s1,s1,s2
    800017b2:	87ce                	mv	a5,s3
    800017b4:	bf4d                	j	80001766 <copyinstr+0x7a>
  int got_null = 0;
    800017b6:	4781                	li	a5,0
  if (got_null) {
    800017b8:	0017c793          	xori	a5,a5,1
    800017bc:	40f0053b          	negw	a0,a5
}
    800017c0:	8082                	ret

00000000800017c2 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017c2:	715d                	addi	sp,sp,-80
    800017c4:	e486                	sd	ra,72(sp)
    800017c6:	e0a2                	sd	s0,64(sp)
    800017c8:	fc26                	sd	s1,56(sp)
    800017ca:	f84a                	sd	s2,48(sp)
    800017cc:	f44e                	sd	s3,40(sp)
    800017ce:	f052                	sd	s4,32(sp)
    800017d0:	ec56                	sd	s5,24(sp)
    800017d2:	e85a                	sd	s6,16(sp)
    800017d4:	e45e                	sd	s7,8(sp)
    800017d6:	e062                	sd	s8,0(sp)
    800017d8:	0880                	addi	s0,sp,80
    800017da:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800017dc:	00011497          	auipc	s1,0x11
    800017e0:	24c48493          	addi	s1,s1,588 # 80012a28 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017e4:	8c26                	mv	s8,s1
    800017e6:	000a57b7          	lui	a5,0xa5
    800017ea:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800017ee:	07b2                	slli	a5,a5,0xc
    800017f0:	fa578793          	addi	a5,a5,-91
    800017f4:	4fa50937          	lui	s2,0x4fa50
    800017f8:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800017fc:	1902                	slli	s2,s2,0x20
    800017fe:	993e                	add	s2,s2,a5
    80001800:	040009b7          	lui	s3,0x4000
    80001804:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001806:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001808:	4b99                	li	s7,6
    8000180a:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    8000180c:	00017a97          	auipc	s5,0x17
    80001810:	c1ca8a93          	addi	s5,s5,-996 # 80018428 <tickslock>
    char *pa = kalloc();
    80001814:	b3aff0ef          	jal	80000b4e <kalloc>
    80001818:	862a                	mv	a2,a0
    if (pa == 0)
    8000181a:	c121                	beqz	a0,8000185a <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    8000181c:	418485b3          	sub	a1,s1,s8
    80001820:	858d                	srai	a1,a1,0x3
    80001822:	032585b3          	mul	a1,a1,s2
    80001826:	05b6                	slli	a1,a1,0xd
    80001828:	6789                	lui	a5,0x2
    8000182a:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000182c:	875e                	mv	a4,s7
    8000182e:	86da                	mv	a3,s6
    80001830:	40b985b3          	sub	a1,s3,a1
    80001834:	8552                	mv	a0,s4
    80001836:	8dbff0ef          	jal	80001110 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000183a:	16848493          	addi	s1,s1,360
    8000183e:	fd549be3          	bne	s1,s5,80001814 <proc_mapstacks+0x52>
  }
}
    80001842:	60a6                	ld	ra,72(sp)
    80001844:	6406                	ld	s0,64(sp)
    80001846:	74e2                	ld	s1,56(sp)
    80001848:	7942                	ld	s2,48(sp)
    8000184a:	79a2                	ld	s3,40(sp)
    8000184c:	7a02                	ld	s4,32(sp)
    8000184e:	6ae2                	ld	s5,24(sp)
    80001850:	6b42                	ld	s6,16(sp)
    80001852:	6ba2                	ld	s7,8(sp)
    80001854:	6c02                	ld	s8,0(sp)
    80001856:	6161                	addi	sp,sp,80
    80001858:	8082                	ret
      panic("kalloc");
    8000185a:	00006517          	auipc	a0,0x6
    8000185e:	8fe50513          	addi	a0,a0,-1794 # 80007158 <etext+0x158>
    80001862:	fd3fe0ef          	jal	80000834 <panic>

0000000080001866 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001866:	7139                	addi	sp,sp,-64
    80001868:	fc06                	sd	ra,56(sp)
    8000186a:	f822                	sd	s0,48(sp)
    8000186c:	f426                	sd	s1,40(sp)
    8000186e:	f04a                	sd	s2,32(sp)
    80001870:	ec4e                	sd	s3,24(sp)
    80001872:	e852                	sd	s4,16(sp)
    80001874:	e456                	sd	s5,8(sp)
    80001876:	e05a                	sd	s6,0(sp)
    80001878:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    8000187a:	00006597          	auipc	a1,0x6
    8000187e:	8e658593          	addi	a1,a1,-1818 # 80007160 <etext+0x160>
    80001882:	00011517          	auipc	a0,0x11
    80001886:	d7650513          	addi	a0,a0,-650 # 800125f8 <pid_lock>
    8000188a:	b1eff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000188e:	00006597          	auipc	a1,0x6
    80001892:	8da58593          	addi	a1,a1,-1830 # 80007168 <etext+0x168>
    80001896:	00011517          	auipc	a0,0x11
    8000189a:	d7a50513          	addi	a0,a0,-646 # 80012610 <wait_lock>
    8000189e:	b0aff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    800018a2:	00011497          	auipc	s1,0x11
    800018a6:	18648493          	addi	s1,s1,390 # 80012a28 <proc>
    initlock(&p->lock, "proc");
    800018aa:	00006b17          	auipc	s6,0x6
    800018ae:	8ceb0b13          	addi	s6,s6,-1842 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018b2:	8aa6                	mv	s5,s1
    800018b4:	000a57b7          	lui	a5,0xa5
    800018b8:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800018bc:	07b2                	slli	a5,a5,0xc
    800018be:	fa578793          	addi	a5,a5,-91
    800018c2:	4fa50937          	lui	s2,0x4fa50
    800018c6:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800018ca:	1902                	slli	s2,s2,0x20
    800018cc:	993e                	add	s2,s2,a5
    800018ce:	040009b7          	lui	s3,0x4000
    800018d2:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018d4:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    800018d6:	00017a17          	auipc	s4,0x17
    800018da:	b52a0a13          	addi	s4,s4,-1198 # 80018428 <tickslock>
    initlock(&p->lock, "proc");
    800018de:	85da                	mv	a1,s6
    800018e0:	8526                	mv	a0,s1
    800018e2:	ac6ff0ef          	jal	80000ba8 <initlock>
    p->state = UNUSED;
    800018e6:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800018ea:	415487b3          	sub	a5,s1,s5
    800018ee:	878d                	srai	a5,a5,0x3
    800018f0:	032787b3          	mul	a5,a5,s2
    800018f4:	07b6                	slli	a5,a5,0xd
    800018f6:	6709                	lui	a4,0x2
    800018f8:	9fb9                	addw	a5,a5,a4
    800018fa:	40f987b3          	sub	a5,s3,a5
    800018fe:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    80001900:	16848493          	addi	s1,s1,360
    80001904:	fd449de3          	bne	s1,s4,800018de <procinit+0x78>
  }
}
    80001908:	70e2                	ld	ra,56(sp)
    8000190a:	7442                	ld	s0,48(sp)
    8000190c:	74a2                	ld	s1,40(sp)
    8000190e:	7902                	ld	s2,32(sp)
    80001910:	69e2                	ld	s3,24(sp)
    80001912:	6a42                	ld	s4,16(sp)
    80001914:	6aa2                	ld	s5,8(sp)
    80001916:	6b02                	ld	s6,0(sp)
    80001918:	6121                	addi	sp,sp,64
    8000191a:	8082                	ret

000000008000191c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000191c:	1141                	addi	sp,sp,-16
    8000191e:	e406                	sd	ra,8(sp)
    80001920:	e022                	sd	s0,0(sp)
    80001922:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    80001924:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001926:	2501                	sext.w	a0,a0
    80001928:	60a2                	ld	ra,8(sp)
    8000192a:	6402                	ld	s0,0(sp)
    8000192c:	0141                	addi	sp,sp,16
    8000192e:	8082                	ret

0000000080001930 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001930:	1141                	addi	sp,sp,-16
    80001932:	e406                	sd	ra,8(sp)
    80001934:	e022                	sd	s0,0(sp)
    80001936:	0800                	addi	s0,sp,16
    80001938:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000193a:	2781                	sext.w	a5,a5
    8000193c:	079e                	slli	a5,a5,0x7
  return c;
}
    8000193e:	00011517          	auipc	a0,0x11
    80001942:	cea50513          	addi	a0,a0,-790 # 80012628 <cpus>
    80001946:	953e                	add	a0,a0,a5
    80001948:	60a2                	ld	ra,8(sp)
    8000194a:	6402                	ld	s0,0(sp)
    8000194c:	0141                	addi	sp,sp,16
    8000194e:	8082                	ret

0000000080001950 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001950:	1101                	addi	sp,sp,-32
    80001952:	ec06                	sd	ra,24(sp)
    80001954:	e822                	sd	s0,16(sp)
    80001956:	e426                	sd	s1,8(sp)
    80001958:	1000                	addi	s0,sp,32
  push_off();
    8000195a:	a94ff0ef          	jal	80000bee <push_off>
    8000195e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001960:	2781                	sext.w	a5,a5
    80001962:	079e                	slli	a5,a5,0x7
    80001964:	00011717          	auipc	a4,0x11
    80001968:	c9470713          	addi	a4,a4,-876 # 800125f8 <pid_lock>
    8000196c:	97ba                	add	a5,a5,a4
    8000196e:	7b9c                	ld	a5,48(a5)
    80001970:	84be                	mv	s1,a5
  pop_off();
    80001972:	af6ff0ef          	jal	80000c68 <pop_off>
  return p;
}
    80001976:	8526                	mv	a0,s1
    80001978:	60e2                	ld	ra,24(sp)
    8000197a:	6442                	ld	s0,16(sp)
    8000197c:	64a2                	ld	s1,8(sp)
    8000197e:	6105                	addi	sp,sp,32
    80001980:	8082                	ret

0000000080001982 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001982:	7179                	addi	sp,sp,-48
    80001984:	f406                	sd	ra,40(sp)
    80001986:	f022                	sd	s0,32(sp)
    80001988:	ec26                	sd	s1,24(sp)
    8000198a:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000198c:	fc5ff0ef          	jal	80001950 <myproc>
    80001990:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001992:	b1eff0ef          	jal	80000cb0 <release>

  if (first) {
    80001996:	00009797          	auipc	a5,0x9
    8000199a:	afa7a783          	lw	a5,-1286(a5) # 8000a490 <first.1>
    8000199e:	cf85                	beqz	a5,800019d6 <forkret+0x54>
    first = 0;
    800019a0:	00009797          	auipc	a5,0x9
    800019a4:	ae07a823          	sw	zero,-1296(a5) # 8000a490 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019a8:	4505                	li	a0,1
    800019aa:	75b010ef          	jal	80003904 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019ae:	00005797          	auipc	a5,0x5
    800019b2:	7d278793          	addi	a5,a5,2002 # 80007180 <etext+0x180>
    800019b6:	fcf43823          	sd	a5,-48(s0)
    800019ba:	fc043c23          	sd	zero,-40(s0)
    800019be:	fd040593          	addi	a1,s0,-48
    800019c2:	853e                	mv	a0,a5
    800019c4:	1f4030ef          	jal	80004bb8 <kexec>
    800019c8:	6cbc                	ld	a5,88(s1)
    800019ca:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019cc:	6cbc                	ld	a5,88(s1)
    800019ce:	7bb8                	ld	a4,112(a5)
    800019d0:	57fd                	li	a5,-1
    800019d2:	02f70d63          	beq	a4,a5,80001a0c <forkret+0x8a>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019d6:	373000ef          	jal	80002548 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019da:	68a8                	ld	a0,80(s1)
    800019dc:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019de:	04000737          	lui	a4,0x4000
    800019e2:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019e4:	0732                	slli	a4,a4,0xc
    800019e6:	00004797          	auipc	a5,0x4
    800019ea:	6b678793          	addi	a5,a5,1718 # 8000609c <userret>
    800019ee:	00004697          	auipc	a3,0x4
    800019f2:	61268693          	addi	a3,a3,1554 # 80006000 <_trampoline>
    800019f6:	8f95                	sub	a5,a5,a3
    800019f8:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019fa:	577d                	li	a4,-1
    800019fc:	177e                	slli	a4,a4,0x3f
    800019fe:	8d59                	or	a0,a0,a4
    80001a00:	9782                	jalr	a5
}
    80001a02:	70a2                	ld	ra,40(sp)
    80001a04:	7402                	ld	s0,32(sp)
    80001a06:	64e2                	ld	s1,24(sp)
    80001a08:	6145                	addi	sp,sp,48
    80001a0a:	8082                	ret
      panic("exec");
    80001a0c:	00005517          	auipc	a0,0x5
    80001a10:	77c50513          	addi	a0,a0,1916 # 80007188 <etext+0x188>
    80001a14:	e21fe0ef          	jal	80000834 <panic>

0000000080001a18 <allocpid>:
{
    80001a18:	1101                	addi	sp,sp,-32
    80001a1a:	ec06                	sd	ra,24(sp)
    80001a1c:	e822                	sd	s0,16(sp)
    80001a1e:	e426                	sd	s1,8(sp)
    80001a20:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a22:	00011517          	auipc	a0,0x11
    80001a26:	bd650513          	addi	a0,a0,-1066 # 800125f8 <pid_lock>
    80001a2a:	9feff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a2e:	00009797          	auipc	a5,0x9
    80001a32:	a6678793          	addi	a5,a5,-1434 # 8000a494 <nextpid>
    80001a36:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a38:	0014871b          	addiw	a4,s1,1
    80001a3c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a3e:	00011517          	auipc	a0,0x11
    80001a42:	bba50513          	addi	a0,a0,-1094 # 800125f8 <pid_lock>
    80001a46:	a6aff0ef          	jal	80000cb0 <release>
}
    80001a4a:	8526                	mv	a0,s1
    80001a4c:	60e2                	ld	ra,24(sp)
    80001a4e:	6442                	ld	s0,16(sp)
    80001a50:	64a2                	ld	s1,8(sp)
    80001a52:	6105                	addi	sp,sp,32
    80001a54:	8082                	ret

0000000080001a56 <proc_pagetable>:
{
    80001a56:	1101                	addi	sp,sp,-32
    80001a58:	ec06                	sd	ra,24(sp)
    80001a5a:	e822                	sd	s0,16(sp)
    80001a5c:	e426                	sd	s1,8(sp)
    80001a5e:	e04a                	sd	s2,0(sp)
    80001a60:	1000                	addi	s0,sp,32
    80001a62:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a64:	f9eff0ef          	jal	80001202 <uvmcreate>
    80001a68:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a6a:	cd05                	beqz	a0,80001aa2 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a6c:	4729                	li	a4,10
    80001a6e:	00004697          	auipc	a3,0x4
    80001a72:	59268693          	addi	a3,a3,1426 # 80006000 <_trampoline>
    80001a76:	6605                	lui	a2,0x1
    80001a78:	040005b7          	lui	a1,0x4000
    80001a7c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a7e:	05b2                	slli	a1,a1,0xc
    80001a80:	ddaff0ef          	jal	8000105a <mappages>
    80001a84:	02054663          	bltz	a0,80001ab0 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001a88:	4719                	li	a4,6
    80001a8a:	05893683          	ld	a3,88(s2)
    80001a8e:	6605                	lui	a2,0x1
    80001a90:	020005b7          	lui	a1,0x2000
    80001a94:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a96:	05b6                	slli	a1,a1,0xd
    80001a98:	8526                	mv	a0,s1
    80001a9a:	dc0ff0ef          	jal	8000105a <mappages>
    80001a9e:	00054f63          	bltz	a0,80001abc <proc_pagetable+0x66>
}
    80001aa2:	8526                	mv	a0,s1
    80001aa4:	60e2                	ld	ra,24(sp)
    80001aa6:	6442                	ld	s0,16(sp)
    80001aa8:	64a2                	ld	s1,8(sp)
    80001aaa:	6902                	ld	s2,0(sp)
    80001aac:	6105                	addi	sp,sp,32
    80001aae:	8082                	ret
    uvmfree(pagetable, 0);
    80001ab0:	4581                	li	a1,0
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	949ff0ef          	jal	800013fc <uvmfree>
    return 0;
    80001ab8:	4481                	li	s1,0
    80001aba:	b7e5                	j	80001aa2 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001abc:	4681                	li	a3,0
    80001abe:	4605                	li	a2,1
    80001ac0:	040005b7          	lui	a1,0x4000
    80001ac4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ac6:	05b2                	slli	a1,a1,0xc
    80001ac8:	8526                	mv	a0,s1
    80001aca:	f5eff0ef          	jal	80001228 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ace:	4581                	li	a1,0
    80001ad0:	8526                	mv	a0,s1
    80001ad2:	92bff0ef          	jal	800013fc <uvmfree>
    return 0;
    80001ad6:	4481                	li	s1,0
    80001ad8:	b7e9                	j	80001aa2 <proc_pagetable+0x4c>

0000000080001ada <proc_freepagetable>:
{
    80001ada:	1101                	addi	sp,sp,-32
    80001adc:	ec06                	sd	ra,24(sp)
    80001ade:	e822                	sd	s0,16(sp)
    80001ae0:	e426                	sd	s1,8(sp)
    80001ae2:	e04a                	sd	s2,0(sp)
    80001ae4:	1000                	addi	s0,sp,32
    80001ae6:	84aa                	mv	s1,a0
    80001ae8:	892e                	mv	s2,a1
  pte_t *pte = walk(pagetable, SHM_VA, 0);
    80001aea:	4601                	li	a2,0
    80001aec:	040005b7          	lui	a1,0x4000
    80001af0:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80001af2:	05b2                	slli	a1,a1,0xc
    80001af4:	c92ff0ef          	jal	80000f86 <walk>
  if (pte && (*pte & PTE_V))
    80001af8:	c501                	beqz	a0,80001b00 <proc_freepagetable+0x26>
    80001afa:	611c                	ld	a5,0(a0)
    80001afc:	8b85                	andi	a5,a5,1
    80001afe:	ef8d                	bnez	a5,80001b38 <proc_freepagetable+0x5e>
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b00:	4681                	li	a3,0
    80001b02:	4605                	li	a2,1
    80001b04:	040005b7          	lui	a1,0x4000
    80001b08:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b0a:	05b2                	slli	a1,a1,0xc
    80001b0c:	8526                	mv	a0,s1
    80001b0e:	f1aff0ef          	jal	80001228 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b12:	4681                	li	a3,0
    80001b14:	4605                	li	a2,1
    80001b16:	020005b7          	lui	a1,0x2000
    80001b1a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b1c:	05b6                	slli	a1,a1,0xd
    80001b1e:	8526                	mv	a0,s1
    80001b20:	f08ff0ef          	jal	80001228 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b24:	85ca                	mv	a1,s2
    80001b26:	8526                	mv	a0,s1
    80001b28:	8d5ff0ef          	jal	800013fc <uvmfree>
}
    80001b2c:	60e2                	ld	ra,24(sp)
    80001b2e:	6442                	ld	s0,16(sp)
    80001b30:	64a2                	ld	s1,8(sp)
    80001b32:	6902                	ld	s2,0(sp)
    80001b34:	6105                	addi	sp,sp,32
    80001b36:	8082                	ret
    uvmunmap(pagetable, SHM_VA, 1, 0);
    80001b38:	4681                	li	a3,0
    80001b3a:	4605                	li	a2,1
    80001b3c:	040005b7          	lui	a1,0x4000
    80001b40:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80001b42:	05b2                	slli	a1,a1,0xc
    80001b44:	8526                	mv	a0,s1
    80001b46:	ee2ff0ef          	jal	80001228 <uvmunmap>
    80001b4a:	bf5d                	j	80001b00 <proc_freepagetable+0x26>

0000000080001b4c <freeproc>:
{
    80001b4c:	1101                	addi	sp,sp,-32
    80001b4e:	ec06                	sd	ra,24(sp)
    80001b50:	e822                	sd	s0,16(sp)
    80001b52:	e426                	sd	s1,8(sp)
    80001b54:	1000                	addi	s0,sp,32
    80001b56:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b58:	6d28                	ld	a0,88(a0)
    80001b5a:	c119                	beqz	a0,80001b60 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001b5c:	f0bfe0ef          	jal	80000a66 <kfree>
  p->trapframe = 0;
    80001b60:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b64:	68a8                	ld	a0,80(s1)
    80001b66:	c501                	beqz	a0,80001b6e <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b68:	64ac                	ld	a1,72(s1)
    80001b6a:	f71ff0ef          	jal	80001ada <proc_freepagetable>
  p->pagetable = 0;
    80001b6e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b72:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b76:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001b7a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b7e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b82:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b86:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b8a:	0004ac23          	sw	zero,24(s1)
}
    80001b8e:	60e2                	ld	ra,24(sp)
    80001b90:	6442                	ld	s0,16(sp)
    80001b92:	64a2                	ld	s1,8(sp)
    80001b94:	6105                	addi	sp,sp,32
    80001b96:	8082                	ret

0000000080001b98 <allocproc>:
{
    80001b98:	1101                	addi	sp,sp,-32
    80001b9a:	ec06                	sd	ra,24(sp)
    80001b9c:	e822                	sd	s0,16(sp)
    80001b9e:	e426                	sd	s1,8(sp)
    80001ba0:	e04a                	sd	s2,0(sp)
    80001ba2:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ba4:	00011497          	auipc	s1,0x11
    80001ba8:	e8448493          	addi	s1,s1,-380 # 80012a28 <proc>
    80001bac:	00017917          	auipc	s2,0x17
    80001bb0:	87c90913          	addi	s2,s2,-1924 # 80018428 <tickslock>
    acquire(&p->lock);
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	872ff0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001bba:	4c9c                	lw	a5,24(s1)
    80001bbc:	cb91                	beqz	a5,80001bd0 <allocproc+0x38>
      release(&p->lock);
    80001bbe:	8526                	mv	a0,s1
    80001bc0:	8f0ff0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bc4:	16848493          	addi	s1,s1,360
    80001bc8:	ff2496e3          	bne	s1,s2,80001bb4 <allocproc+0x1c>
  return 0;
    80001bcc:	4481                	li	s1,0
    80001bce:	a089                	j	80001c10 <allocproc+0x78>
  p->pid = allocpid();
    80001bd0:	e49ff0ef          	jal	80001a18 <allocpid>
    80001bd4:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bd6:	4785                	li	a5,1
    80001bd8:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bda:	f75fe0ef          	jal	80000b4e <kalloc>
    80001bde:	892a                	mv	s2,a0
    80001be0:	eca8                	sd	a0,88(s1)
    80001be2:	cd15                	beqz	a0,80001c1e <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001be4:	8526                	mv	a0,s1
    80001be6:	e71ff0ef          	jal	80001a56 <proc_pagetable>
    80001bea:	892a                	mv	s2,a0
    80001bec:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001bee:	c121                	beqz	a0,80001c2e <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001bf0:	07000613          	li	a2,112
    80001bf4:	4581                	li	a1,0
    80001bf6:	06048513          	addi	a0,s1,96
    80001bfa:	8eeff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001bfe:	00000797          	auipc	a5,0x0
    80001c02:	d8478793          	addi	a5,a5,-636 # 80001982 <forkret>
    80001c06:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c08:	60bc                	ld	a5,64(s1)
    80001c0a:	6705                	lui	a4,0x1
    80001c0c:	97ba                	add	a5,a5,a4
    80001c0e:	f4bc                	sd	a5,104(s1)
}
    80001c10:	8526                	mv	a0,s1
    80001c12:	60e2                	ld	ra,24(sp)
    80001c14:	6442                	ld	s0,16(sp)
    80001c16:	64a2                	ld	s1,8(sp)
    80001c18:	6902                	ld	s2,0(sp)
    80001c1a:	6105                	addi	sp,sp,32
    80001c1c:	8082                	ret
    freeproc(p);
    80001c1e:	8526                	mv	a0,s1
    80001c20:	f2dff0ef          	jal	80001b4c <freeproc>
    release(&p->lock);
    80001c24:	8526                	mv	a0,s1
    80001c26:	88aff0ef          	jal	80000cb0 <release>
    return 0;
    80001c2a:	84ca                	mv	s1,s2
    80001c2c:	b7d5                	j	80001c10 <allocproc+0x78>
    freeproc(p);
    80001c2e:	8526                	mv	a0,s1
    80001c30:	f1dff0ef          	jal	80001b4c <freeproc>
    release(&p->lock);
    80001c34:	8526                	mv	a0,s1
    80001c36:	87aff0ef          	jal	80000cb0 <release>
    return 0;
    80001c3a:	84ca                	mv	s1,s2
    80001c3c:	bfd1                	j	80001c10 <allocproc+0x78>

0000000080001c3e <userinit>:
{
    80001c3e:	1101                	addi	sp,sp,-32
    80001c40:	ec06                	sd	ra,24(sp)
    80001c42:	e822                	sd	s0,16(sp)
    80001c44:	e426                	sd	s1,8(sp)
    80001c46:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c48:	f51ff0ef          	jal	80001b98 <allocproc>
    80001c4c:	84aa                	mv	s1,a0
  initproc = p;
    80001c4e:	00009797          	auipc	a5,0x9
    80001c52:	88a7b923          	sd	a0,-1902(a5) # 8000a4e0 <initproc>
  p->cwd = namei("/");
    80001c56:	00005517          	auipc	a0,0x5
    80001c5a:	53a50513          	addi	a0,a0,1338 # 80007190 <etext+0x190>
    80001c5e:	204020ef          	jal	80003e62 <namei>
    80001c62:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c66:	478d                	li	a5,3
    80001c68:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c6a:	8526                	mv	a0,s1
    80001c6c:	844ff0ef          	jal	80000cb0 <release>
}
    80001c70:	60e2                	ld	ra,24(sp)
    80001c72:	6442                	ld	s0,16(sp)
    80001c74:	64a2                	ld	s1,8(sp)
    80001c76:	6105                	addi	sp,sp,32
    80001c78:	8082                	ret

0000000080001c7a <growproc>:
{
    80001c7a:	1101                	addi	sp,sp,-32
    80001c7c:	ec06                	sd	ra,24(sp)
    80001c7e:	e822                	sd	s0,16(sp)
    80001c80:	e426                	sd	s1,8(sp)
    80001c82:	e04a                	sd	s2,0(sp)
    80001c84:	1000                	addi	s0,sp,32
    80001c86:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c88:	cc9ff0ef          	jal	80001950 <myproc>
    80001c8c:	892a                	mv	s2,a0
  sz = p->sz;
    80001c8e:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c90:	02905963          	blez	s1,80001cc2 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c94:	00b48633          	add	a2,s1,a1
    80001c98:	020007b7          	lui	a5,0x2000
    80001c9c:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c9e:	07b6                	slli	a5,a5,0xd
    80001ca0:	02c7ea63          	bltu	a5,a2,80001cd4 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001ca4:	4691                	li	a3,4
    80001ca6:	6928                	ld	a0,80(a0)
    80001ca8:	e4eff0ef          	jal	800012f6 <uvmalloc>
    80001cac:	85aa                	mv	a1,a0
    80001cae:	c50d                	beqz	a0,80001cd8 <growproc+0x5e>
  p->sz = sz;
    80001cb0:	04b93423          	sd	a1,72(s2)
  return 0;
    80001cb4:	4501                	li	a0,0
}
    80001cb6:	60e2                	ld	ra,24(sp)
    80001cb8:	6442                	ld	s0,16(sp)
    80001cba:	64a2                	ld	s1,8(sp)
    80001cbc:	6902                	ld	s2,0(sp)
    80001cbe:	6105                	addi	sp,sp,32
    80001cc0:	8082                	ret
  } else if (n < 0) {
    80001cc2:	fe04d7e3          	bgez	s1,80001cb0 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001cc6:	00b48633          	add	a2,s1,a1
    80001cca:	6928                	ld	a0,80(a0)
    80001ccc:	de6ff0ef          	jal	800012b2 <uvmdealloc>
    80001cd0:	85aa                	mv	a1,a0
    80001cd2:	bff9                	j	80001cb0 <growproc+0x36>
      return -1;
    80001cd4:	557d                	li	a0,-1
    80001cd6:	b7c5                	j	80001cb6 <growproc+0x3c>
      return -1;
    80001cd8:	557d                	li	a0,-1
    80001cda:	bff1                	j	80001cb6 <growproc+0x3c>

0000000080001cdc <kfork>:
{
    80001cdc:	7139                	addi	sp,sp,-64
    80001cde:	fc06                	sd	ra,56(sp)
    80001ce0:	f822                	sd	s0,48(sp)
    80001ce2:	f426                	sd	s1,40(sp)
    80001ce4:	e456                	sd	s5,8(sp)
    80001ce6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ce8:	c69ff0ef          	jal	80001950 <myproc>
    80001cec:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001cee:	eabff0ef          	jal	80001b98 <allocproc>
    80001cf2:	12050f63          	beqz	a0,80001e30 <kfork+0x154>
    80001cf6:	e852                	sd	s4,16(sp)
    80001cf8:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001cfa:	048ab603          	ld	a2,72(s5)
    80001cfe:	692c                	ld	a1,80(a0)
    80001d00:	050ab503          	ld	a0,80(s5)
    80001d04:	f2aff0ef          	jal	8000142e <uvmcopy>
    80001d08:	06054663          	bltz	a0,80001d74 <kfork+0x98>
  np->sz = p->sz;
    80001d0c:	048ab783          	ld	a5,72(s5)
    80001d10:	04fa3423          	sd	a5,72(s4)
  pte_t *shm_pte = walk(p->pagetable, SHM_VA, 0);
    80001d14:	4601                	li	a2,0
    80001d16:	040005b7          	lui	a1,0x4000
    80001d1a:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80001d1c:	05b2                	slli	a1,a1,0xc
    80001d1e:	050ab503          	ld	a0,80(s5)
    80001d22:	a64ff0ef          	jal	80000f86 <walk>
  if (shm_pte && (*shm_pte & PTE_V)) {
    80001d26:	c509                	beqz	a0,80001d30 <kfork+0x54>
    80001d28:	611c                	ld	a5,0(a0)
    80001d2a:	0017f713          	andi	a4,a5,1
    80001d2e:	ef21                	bnez	a4,80001d86 <kfork+0xaa>
    80001d30:	f04a                	sd	s2,32(sp)
    80001d32:	ec4e                	sd	s3,24(sp)
  *(np->trapframe) = *(p->trapframe);
    80001d34:	058ab683          	ld	a3,88(s5)
    80001d38:	87b6                	mv	a5,a3
    80001d3a:	058a3703          	ld	a4,88(s4)
    80001d3e:	12068693          	addi	a3,a3,288
    80001d42:	6388                	ld	a0,0(a5)
    80001d44:	678c                	ld	a1,8(a5)
    80001d46:	6b90                	ld	a2,16(a5)
    80001d48:	e308                	sd	a0,0(a4)
    80001d4a:	e70c                	sd	a1,8(a4)
    80001d4c:	eb10                	sd	a2,16(a4)
    80001d4e:	6f90                	ld	a2,24(a5)
    80001d50:	ef10                	sd	a2,24(a4)
    80001d52:	02078793          	addi	a5,a5,32
    80001d56:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d5a:	fed794e3          	bne	a5,a3,80001d42 <kfork+0x66>
  np->trapframe->a0 = 0;
    80001d5e:	058a3783          	ld	a5,88(s4)
    80001d62:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d66:	0d0a8493          	addi	s1,s5,208
    80001d6a:	0d0a0913          	addi	s2,s4,208
    80001d6e:	150a8993          	addi	s3,s5,336
    80001d72:	a0a9                	j	80001dbc <kfork+0xe0>
    freeproc(np);
    80001d74:	8552                	mv	a0,s4
    80001d76:	dd7ff0ef          	jal	80001b4c <freeproc>
    release(&np->lock);
    80001d7a:	8552                	mv	a0,s4
    80001d7c:	f35fe0ef          	jal	80000cb0 <release>
    return -1;
    80001d80:	54fd                	li	s1,-1
    80001d82:	6a42                	ld	s4,16(sp)
    80001d84:	a879                	j	80001e22 <kfork+0x146>
    uint64 pa = PTE2PA(*shm_pte);
    80001d86:	83a9                	srli	a5,a5,0xa
    if (mappages(np->pagetable, SHM_VA, PGSIZE, pa, PTE_R | PTE_W | PTE_U) != 0) {
    80001d88:	4759                	li	a4,22
    80001d8a:	00c79693          	slli	a3,a5,0xc
    80001d8e:	6605                	lui	a2,0x1
    80001d90:	040005b7          	lui	a1,0x4000
    80001d94:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80001d96:	05b2                	slli	a1,a1,0xc
    80001d98:	050a3503          	ld	a0,80(s4)
    80001d9c:	abeff0ef          	jal	8000105a <mappages>
    80001da0:	d941                	beqz	a0,80001d30 <kfork+0x54>
      freeproc(np);
    80001da2:	8552                	mv	a0,s4
    80001da4:	da9ff0ef          	jal	80001b4c <freeproc>
      release(&np->lock);
    80001da8:	8552                	mv	a0,s4
    80001daa:	f07fe0ef          	jal	80000cb0 <release>
      return -1;
    80001dae:	54fd                	li	s1,-1
    80001db0:	6a42                	ld	s4,16(sp)
    80001db2:	a885                	j	80001e22 <kfork+0x146>
  for (i = 0; i < NOFILE; i++)
    80001db4:	04a1                	addi	s1,s1,8
    80001db6:	0921                	addi	s2,s2,8
    80001db8:	01348963          	beq	s1,s3,80001dca <kfork+0xee>
    if (p->ofile[i])
    80001dbc:	6088                	ld	a0,0(s1)
    80001dbe:	d97d                	beqz	a0,80001db4 <kfork+0xd8>
      np->ofile[i] = filedup(p->ofile[i]);
    80001dc0:	6f4020ef          	jal	800044b4 <filedup>
    80001dc4:	00a93023          	sd	a0,0(s2)
    80001dc8:	b7f5                	j	80001db4 <kfork+0xd8>
  np->cwd = idup(p->cwd);
    80001dca:	150ab503          	ld	a0,336(s5)
    80001dce:	7c4010ef          	jal	80003592 <idup>
    80001dd2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001dd6:	4641                	li	a2,16
    80001dd8:	158a8593          	addi	a1,s5,344
    80001ddc:	158a0513          	addi	a0,s4,344
    80001de0:	85cff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001de4:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001de8:	8552                	mv	a0,s4
    80001dea:	ec7fe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001dee:	00011517          	auipc	a0,0x11
    80001df2:	82250513          	addi	a0,a0,-2014 # 80012610 <wait_lock>
    80001df6:	e33fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001dfa:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001dfe:	00011517          	auipc	a0,0x11
    80001e02:	81250513          	addi	a0,a0,-2030 # 80012610 <wait_lock>
    80001e06:	eabfe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001e0a:	8552                	mv	a0,s4
    80001e0c:	e1dfe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001e10:	478d                	li	a5,3
    80001e12:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e16:	8552                	mv	a0,s4
    80001e18:	e99fe0ef          	jal	80000cb0 <release>
  return pid;
    80001e1c:	7902                	ld	s2,32(sp)
    80001e1e:	69e2                	ld	s3,24(sp)
    80001e20:	6a42                	ld	s4,16(sp)
}
    80001e22:	8526                	mv	a0,s1
    80001e24:	70e2                	ld	ra,56(sp)
    80001e26:	7442                	ld	s0,48(sp)
    80001e28:	74a2                	ld	s1,40(sp)
    80001e2a:	6aa2                	ld	s5,8(sp)
    80001e2c:	6121                	addi	sp,sp,64
    80001e2e:	8082                	ret
    return -1;
    80001e30:	54fd                	li	s1,-1
    80001e32:	bfc5                	j	80001e22 <kfork+0x146>

0000000080001e34 <scheduler>:
{
    80001e34:	711d                	addi	sp,sp,-96
    80001e36:	ec86                	sd	ra,88(sp)
    80001e38:	e8a2                	sd	s0,80(sp)
    80001e3a:	e4a6                	sd	s1,72(sp)
    80001e3c:	e0ca                	sd	s2,64(sp)
    80001e3e:	fc4e                	sd	s3,56(sp)
    80001e40:	f852                	sd	s4,48(sp)
    80001e42:	f456                	sd	s5,40(sp)
    80001e44:	f05a                	sd	s6,32(sp)
    80001e46:	ec5e                	sd	s7,24(sp)
    80001e48:	e862                	sd	s8,16(sp)
    80001e4a:	e466                	sd	s9,8(sp)
    80001e4c:	1080                	addi	s0,sp,96
    80001e4e:	8792                	mv	a5,tp
  int id = r_tp();
    80001e50:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e52:	00779a93          	slli	s5,a5,0x7
    80001e56:	00010717          	auipc	a4,0x10
    80001e5a:	7a270713          	addi	a4,a4,1954 # 800125f8 <pid_lock>
    80001e5e:	9756                	add	a4,a4,s5
    80001e60:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001e64:	00010717          	auipc	a4,0x10
    80001e68:	7cc70713          	addi	a4,a4,1996 # 80012630 <cpus+0x8>
    80001e6c:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001e6e:	4c11                	li	s8,4
        c->proc = p;
    80001e70:	00010b17          	auipc	s6,0x10
    80001e74:	788b0b13          	addi	s6,s6,1928 # 800125f8 <pid_lock>
    80001e78:	079e                	slli	a5,a5,0x7
    80001e7a:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001e7e:	4b85                	li	s7,1
    80001e80:	a0a9                	j	80001eca <scheduler+0x96>
      release(&p->lock);
    80001e82:	8526                	mv	a0,s1
    80001e84:	e2dfe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e88:	16848493          	addi	s1,s1,360
    80001e8c:	03248b63          	beq	s1,s2,80001ec2 <scheduler+0x8e>
      acquire(&p->lock);
    80001e90:	8526                	mv	a0,s1
    80001e92:	d97fe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001e96:	4c9c                	lw	a5,24(s1)
    80001e98:	ff3795e3          	bne	a5,s3,80001e82 <scheduler+0x4e>
        p->state = RUNNING;
    80001e9c:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001ea0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001ea4:	06048593          	addi	a1,s1,96
    80001ea8:	8556                	mv	a0,s5
    80001eaa:	5f4000ef          	jal	8000249e <swtch>
    80001eae:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001eb0:	2781                	sext.w	a5,a5
    80001eb2:	079e                	slli	a5,a5,0x7
    80001eb4:	97da                	add	a5,a5,s6
    80001eb6:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001eba:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001ebe:	8cde                	mv	s9,s7
    80001ec0:	b7c9                	j	80001e82 <scheduler+0x4e>
    if (found == 0) {
    80001ec2:	000c9463          	bnez	s9,80001eca <scheduler+0x96>
      asm volatile("wfi");
    80001ec6:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001eca:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001ece:	10017073          	csrci	sstatus,2
    int found = 0;
    80001ed2:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001ed4:	00011497          	auipc	s1,0x11
    80001ed8:	b5448493          	addi	s1,s1,-1196 # 80012a28 <proc>
      if (p->state == RUNNABLE) {
    80001edc:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001ede:	00016917          	auipc	s2,0x16
    80001ee2:	54a90913          	addi	s2,s2,1354 # 80018428 <tickslock>
    80001ee6:	b76d                	j	80001e90 <scheduler+0x5c>

0000000080001ee8 <sched>:
{
    80001ee8:	7179                	addi	sp,sp,-48
    80001eea:	f406                	sd	ra,40(sp)
    80001eec:	f022                	sd	s0,32(sp)
    80001eee:	ec26                	sd	s1,24(sp)
    80001ef0:	e84a                	sd	s2,16(sp)
    80001ef2:	e44e                	sd	s3,8(sp)
    80001ef4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ef6:	a5bff0ef          	jal	80001950 <myproc>
    80001efa:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001efc:	cc7fe0ef          	jal	80000bc2 <holding>
    80001f00:	c935                	beqz	a0,80001f74 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f02:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001f04:	2781                	sext.w	a5,a5
    80001f06:	079e                	slli	a5,a5,0x7
    80001f08:	00010717          	auipc	a4,0x10
    80001f0c:	6f070713          	addi	a4,a4,1776 # 800125f8 <pid_lock>
    80001f10:	97ba                	add	a5,a5,a4
    80001f12:	0a87a703          	lw	a4,168(a5)
    80001f16:	4785                	li	a5,1
    80001f18:	06f71463          	bne	a4,a5,80001f80 <sched+0x98>
  if (p->state == RUNNING)
    80001f1c:	4c98                	lw	a4,24(s1)
    80001f1e:	4791                	li	a5,4
    80001f20:	06f70663          	beq	a4,a5,80001f8c <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001f24:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f28:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001f2a:	e7bd                	bnez	a5,80001f98 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f2c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f2e:	00010917          	auipc	s2,0x10
    80001f32:	6ca90913          	addi	s2,s2,1738 # 800125f8 <pid_lock>
    80001f36:	2781                	sext.w	a5,a5
    80001f38:	079e                	slli	a5,a5,0x7
    80001f3a:	97ca                	add	a5,a5,s2
    80001f3c:	0ac7a983          	lw	s3,172(a5)
    80001f40:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f42:	2781                	sext.w	a5,a5
    80001f44:	079e                	slli	a5,a5,0x7
    80001f46:	07a1                	addi	a5,a5,8
    80001f48:	00010597          	auipc	a1,0x10
    80001f4c:	6e058593          	addi	a1,a1,1760 # 80012628 <cpus>
    80001f50:	95be                	add	a1,a1,a5
    80001f52:	06048513          	addi	a0,s1,96
    80001f56:	548000ef          	jal	8000249e <swtch>
    80001f5a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f5c:	2781                	sext.w	a5,a5
    80001f5e:	079e                	slli	a5,a5,0x7
    80001f60:	993e                	add	s2,s2,a5
    80001f62:	0b392623          	sw	s3,172(s2)
}
    80001f66:	70a2                	ld	ra,40(sp)
    80001f68:	7402                	ld	s0,32(sp)
    80001f6a:	64e2                	ld	s1,24(sp)
    80001f6c:	6942                	ld	s2,16(sp)
    80001f6e:	69a2                	ld	s3,8(sp)
    80001f70:	6145                	addi	sp,sp,48
    80001f72:	8082                	ret
    panic("sched p->lock");
    80001f74:	00005517          	auipc	a0,0x5
    80001f78:	22450513          	addi	a0,a0,548 # 80007198 <etext+0x198>
    80001f7c:	8b9fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80001f80:	00005517          	auipc	a0,0x5
    80001f84:	22850513          	addi	a0,a0,552 # 800071a8 <etext+0x1a8>
    80001f88:	8adfe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80001f8c:	00005517          	auipc	a0,0x5
    80001f90:	22c50513          	addi	a0,a0,556 # 800071b8 <etext+0x1b8>
    80001f94:	8a1fe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80001f98:	00005517          	auipc	a0,0x5
    80001f9c:	23050513          	addi	a0,a0,560 # 800071c8 <etext+0x1c8>
    80001fa0:	895fe0ef          	jal	80000834 <panic>

0000000080001fa4 <yield>:
{
    80001fa4:	1101                	addi	sp,sp,-32
    80001fa6:	ec06                	sd	ra,24(sp)
    80001fa8:	e822                	sd	s0,16(sp)
    80001faa:	e426                	sd	s1,8(sp)
    80001fac:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fae:	9a3ff0ef          	jal	80001950 <myproc>
    80001fb2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001fb4:	c75fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001fb8:	478d                	li	a5,3
    80001fba:	cc9c                	sw	a5,24(s1)
  sched();
    80001fbc:	f2dff0ef          	jal	80001ee8 <sched>
  release(&p->lock);
    80001fc0:	8526                	mv	a0,s1
    80001fc2:	ceffe0ef          	jal	80000cb0 <release>
}
    80001fc6:	60e2                	ld	ra,24(sp)
    80001fc8:	6442                	ld	s0,16(sp)
    80001fca:	64a2                	ld	s1,8(sp)
    80001fcc:	6105                	addi	sp,sp,32
    80001fce:	8082                	ret

0000000080001fd0 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001fd0:	1101                	addi	sp,sp,-32
    80001fd2:	ec06                	sd	ra,24(sp)
    80001fd4:	e822                	sd	s0,16(sp)
    80001fd6:	e426                	sd	s1,8(sp)
    80001fd8:	e04a                	sd	s2,0(sp)
    80001fda:	1000                	addi	s0,sp,32
    80001fdc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fde:	973ff0ef          	jal	80001950 <myproc>
    80001fe2:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001fe4:	c45fe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    80001fe8:	cc81                	beqz	s1,80002000 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001fea:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001fee:	854a                	mv	a0,s2
    80001ff0:	cc1fe0ef          	jal	80000cb0 <release>
}
    80001ff4:	60e2                	ld	ra,24(sp)
    80001ff6:	6442                	ld	s0,16(sp)
    80001ff8:	64a2                	ld	s1,8(sp)
    80001ffa:	6902                	ld	s2,0(sp)
    80001ffc:	6105                	addi	sp,sp,32
    80001ffe:	8082                	ret
    panic("sleep_prepare: zero chan");
    80002000:	00005517          	auipc	a0,0x5
    80002004:	1e050513          	addi	a0,a0,480 # 800071e0 <etext+0x1e0>
    80002008:	82dfe0ef          	jal	80000834 <panic>

000000008000200c <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    8000200c:	1101                	addi	sp,sp,-32
    8000200e:	ec06                	sd	ra,24(sp)
    80002010:	e822                	sd	s0,16(sp)
    80002012:	e426                	sd	s1,8(sp)
    80002014:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002016:	93bff0ef          	jal	80001950 <myproc>
    8000201a:	84aa                	mv	s1,a0

  acquire(&p->lock);
    8000201c:	c0dfe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    80002020:	709c                	ld	a5,32(s1)
    80002022:	c789                	beqz	a5,8000202c <sleep+0x20>
    p->state = SLEEPING;
    80002024:	4789                	li	a5,2
    80002026:	cc9c                	sw	a5,24(s1)
    sched();
    80002028:	ec1ff0ef          	jal	80001ee8 <sched>
  }
  release(&p->lock);
    8000202c:	8526                	mv	a0,s1
    8000202e:	c83fe0ef          	jal	80000cb0 <release>
}
    80002032:	60e2                	ld	ra,24(sp)
    80002034:	6442                	ld	s0,16(sp)
    80002036:	64a2                	ld	s1,8(sp)
    80002038:	6105                	addi	sp,sp,32
    8000203a:	8082                	ret

000000008000203c <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    8000203c:	7139                	addi	sp,sp,-64
    8000203e:	fc06                	sd	ra,56(sp)
    80002040:	f822                	sd	s0,48(sp)
    80002042:	f426                	sd	s1,40(sp)
    80002044:	f04a                	sd	s2,32(sp)
    80002046:	ec4e                	sd	s3,24(sp)
    80002048:	e852                	sd	s4,16(sp)
    8000204a:	e456                	sd	s5,8(sp)
    8000204c:	0080                	addi	s0,sp,64
    8000204e:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002050:	00011497          	auipc	s1,0x11
    80002054:	9d848493          	addi	s1,s1,-1576 # 80012a28 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80002058:	4a09                	li	s4,2
        p->state = RUNNABLE;
    8000205a:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    8000205c:	00016997          	auipc	s3,0x16
    80002060:	3cc98993          	addi	s3,s3,972 # 80018428 <tickslock>
    80002064:	a801                	j	80002074 <wakeup+0x38>
      }
    }
    release(&p->lock);
    80002066:	8526                	mv	a0,s1
    80002068:	c49fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000206c:	16848493          	addi	s1,s1,360
    80002070:	03348063          	beq	s1,s3,80002090 <wakeup+0x54>
    acquire(&p->lock);
    80002074:	8526                	mv	a0,s1
    80002076:	bb3fe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    8000207a:	709c                	ld	a5,32(s1)
    8000207c:	ff2795e3          	bne	a5,s2,80002066 <wakeup+0x2a>
      p->chan = 0;
    80002080:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80002084:	4c9c                	lw	a5,24(s1)
    80002086:	ff4790e3          	bne	a5,s4,80002066 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000208a:	0154ac23          	sw	s5,24(s1)
    8000208e:	bfe1                	j	80002066 <wakeup+0x2a>
  }
}
    80002090:	70e2                	ld	ra,56(sp)
    80002092:	7442                	ld	s0,48(sp)
    80002094:	74a2                	ld	s1,40(sp)
    80002096:	7902                	ld	s2,32(sp)
    80002098:	69e2                	ld	s3,24(sp)
    8000209a:	6a42                	ld	s4,16(sp)
    8000209c:	6aa2                	ld	s5,8(sp)
    8000209e:	6121                	addi	sp,sp,64
    800020a0:	8082                	ret

00000000800020a2 <reparent>:
{
    800020a2:	7179                	addi	sp,sp,-48
    800020a4:	f406                	sd	ra,40(sp)
    800020a6:	f022                	sd	s0,32(sp)
    800020a8:	ec26                	sd	s1,24(sp)
    800020aa:	e84a                	sd	s2,16(sp)
    800020ac:	e44e                	sd	s3,8(sp)
    800020ae:	e052                	sd	s4,0(sp)
    800020b0:	1800                	addi	s0,sp,48
    800020b2:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020b4:	00011497          	auipc	s1,0x11
    800020b8:	97448493          	addi	s1,s1,-1676 # 80012a28 <proc>
      pp->parent = initproc;
    800020bc:	00008a17          	auipc	s4,0x8
    800020c0:	424a0a13          	addi	s4,s4,1060 # 8000a4e0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020c4:	00016997          	auipc	s3,0x16
    800020c8:	36498993          	addi	s3,s3,868 # 80018428 <tickslock>
    800020cc:	a029                	j	800020d6 <reparent+0x34>
    800020ce:	16848493          	addi	s1,s1,360
    800020d2:	01348b63          	beq	s1,s3,800020e8 <reparent+0x46>
    if (pp->parent == p) {
    800020d6:	7c9c                	ld	a5,56(s1)
    800020d8:	ff279be3          	bne	a5,s2,800020ce <reparent+0x2c>
      pp->parent = initproc;
    800020dc:	000a3503          	ld	a0,0(s4)
    800020e0:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800020e2:	f5bff0ef          	jal	8000203c <wakeup>
    800020e6:	b7e5                	j	800020ce <reparent+0x2c>
}
    800020e8:	70a2                	ld	ra,40(sp)
    800020ea:	7402                	ld	s0,32(sp)
    800020ec:	64e2                	ld	s1,24(sp)
    800020ee:	6942                	ld	s2,16(sp)
    800020f0:	69a2                	ld	s3,8(sp)
    800020f2:	6a02                	ld	s4,0(sp)
    800020f4:	6145                	addi	sp,sp,48
    800020f6:	8082                	ret

00000000800020f8 <kexit>:
{
    800020f8:	7179                	addi	sp,sp,-48
    800020fa:	f406                	sd	ra,40(sp)
    800020fc:	f022                	sd	s0,32(sp)
    800020fe:	ec26                	sd	s1,24(sp)
    80002100:	e84a                	sd	s2,16(sp)
    80002102:	e44e                	sd	s3,8(sp)
    80002104:	e052                	sd	s4,0(sp)
    80002106:	1800                	addi	s0,sp,48
    80002108:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000210a:	847ff0ef          	jal	80001950 <myproc>
    8000210e:	89aa                	mv	s3,a0
  if (p == initproc)
    80002110:	00008797          	auipc	a5,0x8
    80002114:	3d07b783          	ld	a5,976(a5) # 8000a4e0 <initproc>
    80002118:	0d050493          	addi	s1,a0,208
    8000211c:	15050913          	addi	s2,a0,336
    80002120:	00a79b63          	bne	a5,a0,80002136 <kexit+0x3e>
    panic("init exiting");
    80002124:	00005517          	auipc	a0,0x5
    80002128:	0dc50513          	addi	a0,a0,220 # 80007200 <etext+0x200>
    8000212c:	f08fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002130:	04a1                	addi	s1,s1,8
    80002132:	01248963          	beq	s1,s2,80002144 <kexit+0x4c>
    if (p->ofile[fd]) {
    80002136:	6088                	ld	a0,0(s1)
    80002138:	dd65                	beqz	a0,80002130 <kexit+0x38>
      fileclose(f);
    8000213a:	3c0020ef          	jal	800044fa <fileclose>
      p->ofile[fd] = 0;
    8000213e:	0004b023          	sd	zero,0(s1)
    80002142:	b7fd                	j	80002130 <kexit+0x38>
  begin_op();
    80002144:	6fd010ef          	jal	80004040 <begin_op>
  iput(p->cwd);
    80002148:	1509b503          	ld	a0,336(s3)
    8000214c:	5fe010ef          	jal	8000374a <iput>
  end_op();
    80002150:	77d010ef          	jal	800040cc <end_op>
  p->cwd = 0;
    80002154:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002158:	00010517          	auipc	a0,0x10
    8000215c:	4b850513          	addi	a0,a0,1208 # 80012610 <wait_lock>
    80002160:	ac9fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    80002164:	854e                	mv	a0,s3
    80002166:	f3dff0ef          	jal	800020a2 <reparent>
  wakeup(p->parent);
    8000216a:	0389b503          	ld	a0,56(s3)
    8000216e:	ecfff0ef          	jal	8000203c <wakeup>
  acquire(&p->lock);
    80002172:	854e                	mv	a0,s3
    80002174:	ab5fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    80002178:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000217c:	4795                	li	a5,5
    8000217e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002182:	00010517          	auipc	a0,0x10
    80002186:	48e50513          	addi	a0,a0,1166 # 80012610 <wait_lock>
    8000218a:	b27fe0ef          	jal	80000cb0 <release>
  sched();
    8000218e:	d5bff0ef          	jal	80001ee8 <sched>
  panic("zombie exit");
    80002192:	00005517          	auipc	a0,0x5
    80002196:	07e50513          	addi	a0,a0,126 # 80007210 <etext+0x210>
    8000219a:	e9afe0ef          	jal	80000834 <panic>

000000008000219e <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    8000219e:	c525                	beqz	a0,80002206 <kkill+0x68>
{
    800021a0:	7179                	addi	sp,sp,-48
    800021a2:	f406                	sd	ra,40(sp)
    800021a4:	f022                	sd	s0,32(sp)
    800021a6:	ec26                	sd	s1,24(sp)
    800021a8:	e84a                	sd	s2,16(sp)
    800021aa:	e44e                	sd	s3,8(sp)
    800021ac:	1800                	addi	s0,sp,48
    800021ae:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    800021b0:	00011497          	auipc	s1,0x11
    800021b4:	87848493          	addi	s1,s1,-1928 # 80012a28 <proc>
    800021b8:	00016997          	auipc	s3,0x16
    800021bc:	27098993          	addi	s3,s3,624 # 80018428 <tickslock>
    acquire(&p->lock);
    800021c0:	8526                	mv	a0,s1
    800021c2:	a67fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    800021c6:	589c                	lw	a5,48(s1)
    800021c8:	01278b63          	beq	a5,s2,800021de <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800021cc:	8526                	mv	a0,s1
    800021ce:	ae3fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800021d2:	16848493          	addi	s1,s1,360
    800021d6:	ff3495e3          	bne	s1,s3,800021c0 <kkill+0x22>
  }
  return -1;
    800021da:	557d                	li	a0,-1
    800021dc:	a819                	j	800021f2 <kkill+0x54>
      p->killed = 1;
    800021de:	4785                	li	a5,1
    800021e0:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800021e2:	4c98                	lw	a4,24(s1)
    800021e4:	4789                	li	a5,2
    800021e6:	00f70d63          	beq	a4,a5,80002200 <kkill+0x62>
      release(&p->lock);
    800021ea:	8526                	mv	a0,s1
    800021ec:	ac5fe0ef          	jal	80000cb0 <release>
      return 0;
    800021f0:	4501                	li	a0,0
}
    800021f2:	70a2                	ld	ra,40(sp)
    800021f4:	7402                	ld	s0,32(sp)
    800021f6:	64e2                	ld	s1,24(sp)
    800021f8:	6942                	ld	s2,16(sp)
    800021fa:	69a2                	ld	s3,8(sp)
    800021fc:	6145                	addi	sp,sp,48
    800021fe:	8082                	ret
        p->state = RUNNABLE;
    80002200:	478d                	li	a5,3
    80002202:	cc9c                	sw	a5,24(s1)
    80002204:	b7dd                	j	800021ea <kkill+0x4c>
    return -1;
    80002206:	557d                	li	a0,-1
}
    80002208:	8082                	ret

000000008000220a <setkilled>:

void
setkilled(struct proc *p)
{
    8000220a:	1101                	addi	sp,sp,-32
    8000220c:	ec06                	sd	ra,24(sp)
    8000220e:	e822                	sd	s0,16(sp)
    80002210:	e426                	sd	s1,8(sp)
    80002212:	1000                	addi	s0,sp,32
    80002214:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002216:	a13fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    8000221a:	4785                	li	a5,1
    8000221c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000221e:	8526                	mv	a0,s1
    80002220:	a91fe0ef          	jal	80000cb0 <release>
}
    80002224:	60e2                	ld	ra,24(sp)
    80002226:	6442                	ld	s0,16(sp)
    80002228:	64a2                	ld	s1,8(sp)
    8000222a:	6105                	addi	sp,sp,32
    8000222c:	8082                	ret

000000008000222e <killed>:

int
killed(struct proc *p)
{
    8000222e:	1101                	addi	sp,sp,-32
    80002230:	ec06                	sd	ra,24(sp)
    80002232:	e822                	sd	s0,16(sp)
    80002234:	e426                	sd	s1,8(sp)
    80002236:	e04a                	sd	s2,0(sp)
    80002238:	1000                	addi	s0,sp,32
    8000223a:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000223c:	9edfe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80002240:	549c                	lw	a5,40(s1)
    80002242:	893e                	mv	s2,a5
  release(&p->lock);
    80002244:	8526                	mv	a0,s1
    80002246:	a6bfe0ef          	jal	80000cb0 <release>
  return k;
}
    8000224a:	854a                	mv	a0,s2
    8000224c:	60e2                	ld	ra,24(sp)
    8000224e:	6442                	ld	s0,16(sp)
    80002250:	64a2                	ld	s1,8(sp)
    80002252:	6902                	ld	s2,0(sp)
    80002254:	6105                	addi	sp,sp,32
    80002256:	8082                	ret

0000000080002258 <kwait>:
{
    80002258:	715d                	addi	sp,sp,-80
    8000225a:	e486                	sd	ra,72(sp)
    8000225c:	e0a2                	sd	s0,64(sp)
    8000225e:	fc26                	sd	s1,56(sp)
    80002260:	f84a                	sd	s2,48(sp)
    80002262:	f44e                	sd	s3,40(sp)
    80002264:	f052                	sd	s4,32(sp)
    80002266:	ec56                	sd	s5,24(sp)
    80002268:	e85a                	sd	s6,16(sp)
    8000226a:	e45e                	sd	s7,8(sp)
    8000226c:	0880                	addi	s0,sp,80
    8000226e:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002270:	ee0ff0ef          	jal	80001950 <myproc>
    80002274:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002276:	00010517          	auipc	a0,0x10
    8000227a:	39a50513          	addi	a0,a0,922 # 80012610 <wait_lock>
    8000227e:	9abfe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002282:	4a15                	li	s4,5
        havekids = 1;
    80002284:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002286:	00016997          	auipc	s3,0x16
    8000228a:	1a298993          	addi	s3,s3,418 # 80018428 <tickslock>
    release(&wait_lock);
    8000228e:	00010b17          	auipc	s6,0x10
    80002292:	382b0b13          	addi	s6,s6,898 # 80012610 <wait_lock>
    80002296:	a845                	j	80002346 <kwait+0xee>
          pid = pp->pid;
    80002298:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    8000229c:	000b8e63          	beqz	s7,800022b8 <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    800022a0:	4711                	li	a4,4
    800022a2:	02c48693          	addi	a3,s1,44
    800022a6:	865e                	mv	a2,s7
    800022a8:	04893583          	ld	a1,72(s2)
    800022ac:	05093503          	ld	a0,80(s2)
    800022b0:	adaff0ef          	jal	8000158a <copyout>
          if (addr != 0 &&
    800022b4:	02054c63          	bltz	a0,800022ec <kwait+0x94>
          pp->parent = 0;
    800022b8:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    800022bc:	8526                	mv	a0,s1
    800022be:	88fff0ef          	jal	80001b4c <freeproc>
          release(&pp->lock);
    800022c2:	8526                	mv	a0,s1
    800022c4:	9edfe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    800022c8:	00010517          	auipc	a0,0x10
    800022cc:	34850513          	addi	a0,a0,840 # 80012610 <wait_lock>
    800022d0:	9e1fe0ef          	jal	80000cb0 <release>
}
    800022d4:	854e                	mv	a0,s3
    800022d6:	60a6                	ld	ra,72(sp)
    800022d8:	6406                	ld	s0,64(sp)
    800022da:	74e2                	ld	s1,56(sp)
    800022dc:	7942                	ld	s2,48(sp)
    800022de:	79a2                	ld	s3,40(sp)
    800022e0:	7a02                	ld	s4,32(sp)
    800022e2:	6ae2                	ld	s5,24(sp)
    800022e4:	6b42                	ld	s6,16(sp)
    800022e6:	6ba2                	ld	s7,8(sp)
    800022e8:	6161                	addi	sp,sp,80
    800022ea:	8082                	ret
            release(&pp->lock);
    800022ec:	8526                	mv	a0,s1
    800022ee:	9c3fe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    800022f2:	00010517          	auipc	a0,0x10
    800022f6:	31e50513          	addi	a0,a0,798 # 80012610 <wait_lock>
    800022fa:	9b7fe0ef          	jal	80000cb0 <release>
            return -1;
    800022fe:	59fd                	li	s3,-1
    80002300:	bfd1                	j	800022d4 <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002302:	16848493          	addi	s1,s1,360
    80002306:	03348063          	beq	s1,s3,80002326 <kwait+0xce>
      if (pp->parent == p) {
    8000230a:	7c9c                	ld	a5,56(s1)
    8000230c:	ff279be3          	bne	a5,s2,80002302 <kwait+0xaa>
        acquire(&pp->lock);
    80002310:	8526                	mv	a0,s1
    80002312:	917fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002316:	4c9c                	lw	a5,24(s1)
    80002318:	f94780e3          	beq	a5,s4,80002298 <kwait+0x40>
        release(&pp->lock);
    8000231c:	8526                	mv	a0,s1
    8000231e:	993fe0ef          	jal	80000cb0 <release>
        havekids = 1;
    80002322:	8756                	mv	a4,s5
    80002324:	bff9                	j	80002302 <kwait+0xaa>
    if (!havekids || killed(p)) {
    80002326:	c715                	beqz	a4,80002352 <kwait+0xfa>
    80002328:	854a                	mv	a0,s2
    8000232a:	f05ff0ef          	jal	8000222e <killed>
    8000232e:	e115                	bnez	a0,80002352 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    80002330:	854a                	mv	a0,s2
    80002332:	c9fff0ef          	jal	80001fd0 <sleep_prepare>
    release(&wait_lock);
    80002336:	855a                	mv	a0,s6
    80002338:	979fe0ef          	jal	80000cb0 <release>
    sleep();
    8000233c:	cd1ff0ef          	jal	8000200c <sleep>
    acquire(&wait_lock);
    80002340:	855a                	mv	a0,s6
    80002342:	8e7fe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    80002346:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002348:	00010497          	auipc	s1,0x10
    8000234c:	6e048493          	addi	s1,s1,1760 # 80012a28 <proc>
    80002350:	bf6d                	j	8000230a <kwait+0xb2>
      release(&wait_lock);
    80002352:	00010517          	auipc	a0,0x10
    80002356:	2be50513          	addi	a0,a0,702 # 80012610 <wait_lock>
    8000235a:	957fe0ef          	jal	80000cb0 <release>
      return -1;
    8000235e:	59fd                	li	s3,-1
    80002360:	bf95                	j	800022d4 <kwait+0x7c>

0000000080002362 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002362:	7179                	addi	sp,sp,-48
    80002364:	f406                	sd	ra,40(sp)
    80002366:	f022                	sd	s0,32(sp)
    80002368:	ec26                	sd	s1,24(sp)
    8000236a:	e84a                	sd	s2,16(sp)
    8000236c:	e44e                	sd	s3,8(sp)
    8000236e:	e052                	sd	s4,0(sp)
    80002370:	1800                	addi	s0,sp,48
    80002372:	84aa                	mv	s1,a0
    80002374:	8a2e                	mv	s4,a1
    80002376:	89b2                	mv	s3,a2
    80002378:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000237a:	dd6ff0ef          	jal	80001950 <myproc>
  if (user_dst) {
    8000237e:	c085                	beqz	s1,8000239e <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    80002380:	874a                	mv	a4,s2
    80002382:	86ce                	mv	a3,s3
    80002384:	8652                	mv	a2,s4
    80002386:	652c                	ld	a1,72(a0)
    80002388:	6928                	ld	a0,80(a0)
    8000238a:	a00ff0ef          	jal	8000158a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000238e:	70a2                	ld	ra,40(sp)
    80002390:	7402                	ld	s0,32(sp)
    80002392:	64e2                	ld	s1,24(sp)
    80002394:	6942                	ld	s2,16(sp)
    80002396:	69a2                	ld	s3,8(sp)
    80002398:	6a02                	ld	s4,0(sp)
    8000239a:	6145                	addi	sp,sp,48
    8000239c:	8082                	ret
    memmove((char *)dst, src, len);
    8000239e:	0009061b          	sext.w	a2,s2
    800023a2:	85ce                	mv	a1,s3
    800023a4:	8552                	mv	a0,s4
    800023a6:	9a3fe0ef          	jal	80000d48 <memmove>
    return 0;
    800023aa:	8526                	mv	a0,s1
    800023ac:	b7cd                	j	8000238e <either_copyout+0x2c>

00000000800023ae <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800023ae:	7179                	addi	sp,sp,-48
    800023b0:	f406                	sd	ra,40(sp)
    800023b2:	f022                	sd	s0,32(sp)
    800023b4:	ec26                	sd	s1,24(sp)
    800023b6:	e84a                	sd	s2,16(sp)
    800023b8:	e44e                	sd	s3,8(sp)
    800023ba:	e052                	sd	s4,0(sp)
    800023bc:	1800                	addi	s0,sp,48
    800023be:	8a2a                	mv	s4,a0
    800023c0:	84ae                	mv	s1,a1
    800023c2:	89b2                	mv	s3,a2
    800023c4:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800023c6:	d8aff0ef          	jal	80001950 <myproc>
  if (user_src) {
    800023ca:	c085                	beqz	s1,800023ea <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    800023cc:	874a                	mv	a4,s2
    800023ce:	86ce                	mv	a3,s3
    800023d0:	8652                	mv	a2,s4
    800023d2:	652c                	ld	a1,72(a0)
    800023d4:	6928                	ld	a0,80(a0)
    800023d6:	a7aff0ef          	jal	80001650 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800023da:	70a2                	ld	ra,40(sp)
    800023dc:	7402                	ld	s0,32(sp)
    800023de:	64e2                	ld	s1,24(sp)
    800023e0:	6942                	ld	s2,16(sp)
    800023e2:	69a2                	ld	s3,8(sp)
    800023e4:	6a02                	ld	s4,0(sp)
    800023e6:	6145                	addi	sp,sp,48
    800023e8:	8082                	ret
    memmove(dst, (char *)src, len);
    800023ea:	0009061b          	sext.w	a2,s2
    800023ee:	85ce                	mv	a1,s3
    800023f0:	8552                	mv	a0,s4
    800023f2:	957fe0ef          	jal	80000d48 <memmove>
    return 0;
    800023f6:	8526                	mv	a0,s1
    800023f8:	b7cd                	j	800023da <either_copyin+0x2c>

00000000800023fa <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800023fa:	715d                	addi	sp,sp,-80
    800023fc:	e486                	sd	ra,72(sp)
    800023fe:	e0a2                	sd	s0,64(sp)
    80002400:	fc26                	sd	s1,56(sp)
    80002402:	f84a                	sd	s2,48(sp)
    80002404:	f44e                	sd	s3,40(sp)
    80002406:	f052                	sd	s4,32(sp)
    80002408:	ec56                	sd	s5,24(sp)
    8000240a:	e85a                	sd	s6,16(sp)
    8000240c:	e45e                	sd	s7,8(sp)
    8000240e:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002410:	00005517          	auipc	a0,0x5
    80002414:	c6850513          	addi	a0,a0,-920 # 80007078 <etext+0x78>
    80002418:	8f2fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000241c:	00010497          	auipc	s1,0x10
    80002420:	76448493          	addi	s1,s1,1892 # 80012b80 <proc+0x158>
    80002424:	00016917          	auipc	s2,0x16
    80002428:	15c90913          	addi	s2,s2,348 # 80018580 <sems+0x128>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000242c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000242e:	00005997          	auipc	s3,0x5
    80002432:	df298993          	addi	s3,s3,-526 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    80002436:	00005a97          	auipc	s5,0x5
    8000243a:	df2a8a93          	addi	s5,s5,-526 # 80007228 <etext+0x228>
    printk("\n");
    8000243e:	00005a17          	auipc	s4,0x5
    80002442:	c3aa0a13          	addi	s4,s4,-966 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002446:	00005b97          	auipc	s7,0x5
    8000244a:	312b8b93          	addi	s7,s7,786 # 80007758 <states.0>
    8000244e:	a829                	j	80002468 <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002450:	ed86a583          	lw	a1,-296(a3)
    80002454:	8556                	mv	a0,s5
    80002456:	8b4fe0ef          	jal	8000050a <printk>
    printk("\n");
    8000245a:	8552                	mv	a0,s4
    8000245c:	8aefe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002460:	16848493          	addi	s1,s1,360
    80002464:	03248263          	beq	s1,s2,80002488 <procdump+0x8e>
    if (p->state == UNUSED)
    80002468:	86a6                	mv	a3,s1
    8000246a:	ec04a783          	lw	a5,-320(s1)
    8000246e:	dbed                	beqz	a5,80002460 <procdump+0x66>
      state = "???";
    80002470:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002472:	fcfb6fe3          	bltu	s6,a5,80002450 <procdump+0x56>
    80002476:	02079713          	slli	a4,a5,0x20
    8000247a:	01d75793          	srli	a5,a4,0x1d
    8000247e:	97de                	add	a5,a5,s7
    80002480:	6390                	ld	a2,0(a5)
    80002482:	f679                	bnez	a2,80002450 <procdump+0x56>
      state = "???";
    80002484:	864e                	mv	a2,s3
    80002486:	b7e9                	j	80002450 <procdump+0x56>
  }
}
    80002488:	60a6                	ld	ra,72(sp)
    8000248a:	6406                	ld	s0,64(sp)
    8000248c:	74e2                	ld	s1,56(sp)
    8000248e:	7942                	ld	s2,48(sp)
    80002490:	79a2                	ld	s3,40(sp)
    80002492:	7a02                	ld	s4,32(sp)
    80002494:	6ae2                	ld	s5,24(sp)
    80002496:	6b42                	ld	s6,16(sp)
    80002498:	6ba2                	ld	s7,8(sp)
    8000249a:	6161                	addi	sp,sp,80
    8000249c:	8082                	ret

000000008000249e <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000249e:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800024a2:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800024a6:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800024a8:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800024aa:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800024ae:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800024b2:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800024b6:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800024ba:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800024be:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800024c2:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800024c6:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800024ca:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800024ce:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800024d2:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800024d6:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800024da:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800024dc:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800024de:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800024e2:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800024e6:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800024ea:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800024ee:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800024f2:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800024f6:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800024fa:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800024fe:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002502:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002506:	8082                	ret

0000000080002508 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002508:	1141                	addi	sp,sp,-16
    8000250a:	e406                	sd	ra,8(sp)
    8000250c:	e022                	sd	s0,0(sp)
    8000250e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002510:	00005597          	auipc	a1,0x5
    80002514:	d5858593          	addi	a1,a1,-680 # 80007268 <etext+0x268>
    80002518:	00016517          	auipc	a0,0x16
    8000251c:	f1050513          	addi	a0,a0,-240 # 80018428 <tickslock>
    80002520:	e88fe0ef          	jal	80000ba8 <initlock>
}
    80002524:	60a2                	ld	ra,8(sp)
    80002526:	6402                	ld	s0,0(sp)
    80002528:	0141                	addi	sp,sp,16
    8000252a:	8082                	ret

000000008000252c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000252c:	1141                	addi	sp,sp,-16
    8000252e:	e406                	sd	ra,8(sp)
    80002530:	e022                	sd	s0,0(sp)
    80002532:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002534:	00003797          	auipc	a5,0x3
    80002538:	44c78793          	addi	a5,a5,1100 # 80005980 <kernelvec>
    8000253c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002540:	60a2                	ld	ra,8(sp)
    80002542:	6402                	ld	s0,0(sp)
    80002544:	0141                	addi	sp,sp,16
    80002546:	8082                	ret

0000000080002548 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002548:	1141                	addi	sp,sp,-16
    8000254a:	e406                	sd	ra,8(sp)
    8000254c:	e022                	sd	s0,0(sp)
    8000254e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002550:	c00ff0ef          	jal	80001950 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002554:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002558:	04000737          	lui	a4,0x4000
    8000255c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000255e:	0732                	slli	a4,a4,0xc
    80002560:	00004797          	auipc	a5,0x4
    80002564:	aa078793          	addi	a5,a5,-1376 # 80006000 <_trampoline>
    80002568:	00004697          	auipc	a3,0x4
    8000256c:	a9868693          	addi	a3,a3,-1384 # 80006000 <_trampoline>
    80002570:	8f95                	sub	a5,a5,a3
    80002572:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002574:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002578:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    8000257a:	18002773          	csrr	a4,satp
    8000257e:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002580:	6d38                	ld	a4,88(a0)
    80002582:	613c                	ld	a5,64(a0)
    80002584:	6685                	lui	a3,0x1
    80002586:	97b6                	add	a5,a5,a3
    80002588:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000258a:	6d3c                	ld	a5,88(a0)
    8000258c:	00000717          	auipc	a4,0x0
    80002590:	0fc70713          	addi	a4,a4,252 # 80002688 <usertrap>
    80002594:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002596:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    80002598:	8712                	mv	a4,tp
    8000259a:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000259c:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800025a0:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800025a4:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800025a8:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800025ac:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800025ae:	6f9c                	ld	a5,24(a5)
    800025b0:	14179073          	csrw	sepc,a5
}
    800025b4:	60a2                	ld	ra,8(sp)
    800025b6:	6402                	ld	s0,0(sp)
    800025b8:	0141                	addi	sp,sp,16
    800025ba:	8082                	ret

00000000800025bc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800025bc:	1141                	addi	sp,sp,-16
    800025be:	e406                	sd	ra,8(sp)
    800025c0:	e022                	sd	s0,0(sp)
    800025c2:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    800025c4:	b58ff0ef          	jal	8000191c <cpuid>
    800025c8:	cd11                	beqz	a0,800025e4 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800025ca:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800025ce:	000f4737          	lui	a4,0xf4
    800025d2:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800025d6:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    800025d8:	14d79073          	csrw	stimecmp,a5
}
    800025dc:	60a2                	ld	ra,8(sp)
    800025de:	6402                	ld	s0,0(sp)
    800025e0:	0141                	addi	sp,sp,16
    800025e2:	8082                	ret
    acquire(&tickslock);
    800025e4:	00016517          	auipc	a0,0x16
    800025e8:	e4450513          	addi	a0,a0,-444 # 80018428 <tickslock>
    800025ec:	e3cfe0ef          	jal	80000c28 <acquire>
    ticks++;
    800025f0:	00008717          	auipc	a4,0x8
    800025f4:	ef870713          	addi	a4,a4,-264 # 8000a4e8 <ticks>
    800025f8:	431c                	lw	a5,0(a4)
    800025fa:	2785                	addiw	a5,a5,1
    800025fc:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800025fe:	853a                	mv	a0,a4
    80002600:	a3dff0ef          	jal	8000203c <wakeup>
    release(&tickslock);
    80002604:	00016517          	auipc	a0,0x16
    80002608:	e2450513          	addi	a0,a0,-476 # 80018428 <tickslock>
    8000260c:	ea4fe0ef          	jal	80000cb0 <release>
    80002610:	bf6d                	j	800025ca <clockintr+0xe>

0000000080002612 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002612:	1101                	addi	sp,sp,-32
    80002614:	ec06                	sd	ra,24(sp)
    80002616:	e822                	sd	s0,16(sp)
    80002618:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    8000261a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    8000261e:	57fd                	li	a5,-1
    80002620:	17fe                	slli	a5,a5,0x3f
    80002622:	07a5                	addi	a5,a5,9
    80002624:	00f70c63          	beq	a4,a5,8000263c <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    80002628:	57fd                	li	a5,-1
    8000262a:	17fe                	slli	a5,a5,0x3f
    8000262c:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000262e:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002630:	04f70863          	beq	a4,a5,80002680 <devintr+0x6e>
  }
}
    80002634:	60e2                	ld	ra,24(sp)
    80002636:	6442                	ld	s0,16(sp)
    80002638:	6105                	addi	sp,sp,32
    8000263a:	8082                	ret
    8000263c:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000263e:	3f0030ef          	jal	80005a2e <plic_claim>
    80002642:	872a                	mv	a4,a0
    80002644:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002646:	47a9                	li	a5,10
    80002648:	00f50963          	beq	a0,a5,8000265a <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    8000264c:	4785                	li	a5,1
    8000264e:	00f50963          	beq	a0,a5,80002660 <devintr+0x4e>
    return 1;
    80002652:	4505                	li	a0,1
    } else if (irq) {
    80002654:	eb09                	bnez	a4,80002666 <devintr+0x54>
    80002656:	64a2                	ld	s1,8(sp)
    80002658:	bff1                	j	80002634 <devintr+0x22>
      uartintr();
    8000265a:	b94fe0ef          	jal	800009ee <uartintr>
    if (irq)
    8000265e:	a819                	j	80002674 <devintr+0x62>
      virtio_disk_intr();
    80002660:	08b030ef          	jal	80005eea <virtio_disk_intr>
    if (irq)
    80002664:	a801                	j	80002674 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    80002666:	85ba                	mv	a1,a4
    80002668:	00005517          	auipc	a0,0x5
    8000266c:	c0850513          	addi	a0,a0,-1016 # 80007270 <etext+0x270>
    80002670:	e9bfd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    80002674:	8526                	mv	a0,s1
    80002676:	3da030ef          	jal	80005a50 <plic_complete>
    return 1;
    8000267a:	4505                	li	a0,1
    8000267c:	64a2                	ld	s1,8(sp)
    8000267e:	bf5d                	j	80002634 <devintr+0x22>
    clockintr();
    80002680:	f3dff0ef          	jal	800025bc <clockintr>
    return 2;
    80002684:	4509                	li	a0,2
    80002686:	b77d                	j	80002634 <devintr+0x22>

0000000080002688 <usertrap>:
{
    80002688:	1101                	addi	sp,sp,-32
    8000268a:	ec06                	sd	ra,24(sp)
    8000268c:	e822                	sd	s0,16(sp)
    8000268e:	e426                	sd	s1,8(sp)
    80002690:	e04a                	sd	s2,0(sp)
    80002692:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002694:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002698:	1007f793          	andi	a5,a5,256
    8000269c:	eba5                	bnez	a5,8000270c <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000269e:	00003797          	auipc	a5,0x3
    800026a2:	2e278793          	addi	a5,a5,738 # 80005980 <kernelvec>
    800026a6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800026aa:	aa6ff0ef          	jal	80001950 <myproc>
    800026ae:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800026b0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026b2:	14102773          	csrr	a4,sepc
    800026b6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800026b8:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800026bc:	47a1                	li	a5,8
    800026be:	04f70d63          	beq	a4,a5,80002718 <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    800026c2:	f51ff0ef          	jal	80002612 <devintr>
    800026c6:	892a                	mv	s2,a0
    800026c8:	e54d                	bnez	a0,80002772 <usertrap+0xea>
    800026ca:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800026ce:	47bd                	li	a5,15
    800026d0:	08f70463          	beq	a4,a5,80002758 <usertrap+0xd0>
    800026d4:	14202773          	csrr	a4,scause
    800026d8:	47b5                	li	a5,13
    800026da:	06f70f63          	beq	a4,a5,80002758 <usertrap+0xd0>
    800026de:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800026e2:	5890                	lw	a2,48(s1)
    800026e4:	00005517          	auipc	a0,0x5
    800026e8:	bcc50513          	addi	a0,a0,-1076 # 800072b0 <etext+0x2b0>
    800026ec:	e1ffd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026f0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800026f4:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800026f8:	00005517          	auipc	a0,0x5
    800026fc:	be850513          	addi	a0,a0,-1048 # 800072e0 <etext+0x2e0>
    80002700:	e0bfd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002704:	8526                	mv	a0,s1
    80002706:	b05ff0ef          	jal	8000220a <setkilled>
    8000270a:	a015                	j	8000272e <usertrap+0xa6>
    panic("usertrap: not from user mode");
    8000270c:	00005517          	auipc	a0,0x5
    80002710:	b8450513          	addi	a0,a0,-1148 # 80007290 <etext+0x290>
    80002714:	920fe0ef          	jal	80000834 <panic>
    if (killed(p))
    80002718:	b17ff0ef          	jal	8000222e <killed>
    8000271c:	e915                	bnez	a0,80002750 <usertrap+0xc8>
    p->trapframe->epc += 4;
    8000271e:	6cb8                	ld	a4,88(s1)
    80002720:	6f1c                	ld	a5,24(a4)
    80002722:	0791                	addi	a5,a5,4
    80002724:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002726:	10016073          	csrsi	sstatus,2
    syscall();
    8000272a:	244000ef          	jal	8000296e <syscall>
  if (killed(p))
    8000272e:	8526                	mv	a0,s1
    80002730:	affff0ef          	jal	8000222e <killed>
    80002734:	e521                	bnez	a0,8000277c <usertrap+0xf4>
  prepare_return();
    80002736:	e13ff0ef          	jal	80002548 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000273a:	68a8                	ld	a0,80(s1)
    8000273c:	8131                	srli	a0,a0,0xc
    8000273e:	57fd                	li	a5,-1
    80002740:	17fe                	slli	a5,a5,0x3f
    80002742:	8d5d                	or	a0,a0,a5
}
    80002744:	60e2                	ld	ra,24(sp)
    80002746:	6442                	ld	s0,16(sp)
    80002748:	64a2                	ld	s1,8(sp)
    8000274a:	6902                	ld	s2,0(sp)
    8000274c:	6105                	addi	sp,sp,32
    8000274e:	8082                	ret
      kexit(-1);
    80002750:	557d                	li	a0,-1
    80002752:	9a7ff0ef          	jal	800020f8 <kexit>
    80002756:	b7e1                	j	8000271e <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002758:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    8000275c:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002760:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    80002762:	0016b693          	seqz	a3,a3
    80002766:	64ac                	ld	a1,72(s1)
    80002768:	68a8                	ld	a0,80(s1)
    8000276a:	da5fe0ef          	jal	8000150e <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    8000276e:	f161                	bnez	a0,8000272e <usertrap+0xa6>
    80002770:	b7bd                	j	800026de <usertrap+0x56>
  if (killed(p))
    80002772:	8526                	mv	a0,s1
    80002774:	abbff0ef          	jal	8000222e <killed>
    80002778:	c511                	beqz	a0,80002784 <usertrap+0xfc>
    8000277a:	a011                	j	8000277e <usertrap+0xf6>
    8000277c:	4901                	li	s2,0
    kexit(-1);
    8000277e:	557d                	li	a0,-1
    80002780:	979ff0ef          	jal	800020f8 <kexit>
  if (which_dev == 2)
    80002784:	4789                	li	a5,2
    80002786:	faf918e3          	bne	s2,a5,80002736 <usertrap+0xae>
    yield();
    8000278a:	81bff0ef          	jal	80001fa4 <yield>
    8000278e:	b765                	j	80002736 <usertrap+0xae>

0000000080002790 <kerneltrap>:
{
    80002790:	7179                	addi	sp,sp,-48
    80002792:	f406                	sd	ra,40(sp)
    80002794:	f022                	sd	s0,32(sp)
    80002796:	ec26                	sd	s1,24(sp)
    80002798:	e84a                	sd	s2,16(sp)
    8000279a:	e44e                	sd	s3,8(sp)
    8000279c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000279e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027a2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800027a6:	142027f3          	csrr	a5,scause
    800027aa:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    800027ac:	1004f793          	andi	a5,s1,256
    800027b0:	c795                	beqz	a5,800027dc <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027b2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800027b6:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800027b8:	eb85                	bnez	a5,800027e8 <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    800027ba:	e59ff0ef          	jal	80002612 <devintr>
    800027be:	c91d                	beqz	a0,800027f4 <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    800027c0:	4789                	li	a5,2
    800027c2:	04f50a63          	beq	a0,a5,80002816 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    800027c6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800027ca:	10049073          	csrw	sstatus,s1
}
    800027ce:	70a2                	ld	ra,40(sp)
    800027d0:	7402                	ld	s0,32(sp)
    800027d2:	64e2                	ld	s1,24(sp)
    800027d4:	6942                	ld	s2,16(sp)
    800027d6:	69a2                	ld	s3,8(sp)
    800027d8:	6145                	addi	sp,sp,48
    800027da:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800027dc:	00005517          	auipc	a0,0x5
    800027e0:	b2c50513          	addi	a0,a0,-1236 # 80007308 <etext+0x308>
    800027e4:	850fe0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    800027e8:	00005517          	auipc	a0,0x5
    800027ec:	b4850513          	addi	a0,a0,-1208 # 80007330 <etext+0x330>
    800027f0:	844fe0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027f4:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800027f8:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800027fc:	85ce                	mv	a1,s3
    800027fe:	00005517          	auipc	a0,0x5
    80002802:	b5250513          	addi	a0,a0,-1198 # 80007350 <etext+0x350>
    80002806:	d05fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    8000280a:	00005517          	auipc	a0,0x5
    8000280e:	b6e50513          	addi	a0,a0,-1170 # 80007378 <etext+0x378>
    80002812:	822fe0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    80002816:	93aff0ef          	jal	80001950 <myproc>
    8000281a:	d555                	beqz	a0,800027c6 <kerneltrap+0x36>
    yield();
    8000281c:	f88ff0ef          	jal	80001fa4 <yield>
    80002820:	b75d                	j	800027c6 <kerneltrap+0x36>

0000000080002822 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002822:	1101                	addi	sp,sp,-32
    80002824:	ec06                	sd	ra,24(sp)
    80002826:	e822                	sd	s0,16(sp)
    80002828:	e426                	sd	s1,8(sp)
    8000282a:	1000                	addi	s0,sp,32
    8000282c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000282e:	922ff0ef          	jal	80001950 <myproc>
  switch (n) {
    80002832:	4795                	li	a5,5
    80002834:	0497e163          	bltu	a5,s1,80002876 <argraw+0x54>
    80002838:	048a                	slli	s1,s1,0x2
    8000283a:	00005717          	auipc	a4,0x5
    8000283e:	f4e70713          	addi	a4,a4,-178 # 80007788 <states.0+0x30>
    80002842:	94ba                	add	s1,s1,a4
    80002844:	409c                	lw	a5,0(s1)
    80002846:	97ba                	add	a5,a5,a4
    80002848:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000284a:	6d3c                	ld	a5,88(a0)
    8000284c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000284e:	60e2                	ld	ra,24(sp)
    80002850:	6442                	ld	s0,16(sp)
    80002852:	64a2                	ld	s1,8(sp)
    80002854:	6105                	addi	sp,sp,32
    80002856:	8082                	ret
    return p->trapframe->a1;
    80002858:	6d3c                	ld	a5,88(a0)
    8000285a:	7fa8                	ld	a0,120(a5)
    8000285c:	bfcd                	j	8000284e <argraw+0x2c>
    return p->trapframe->a2;
    8000285e:	6d3c                	ld	a5,88(a0)
    80002860:	63c8                	ld	a0,128(a5)
    80002862:	b7f5                	j	8000284e <argraw+0x2c>
    return p->trapframe->a3;
    80002864:	6d3c                	ld	a5,88(a0)
    80002866:	67c8                	ld	a0,136(a5)
    80002868:	b7dd                	j	8000284e <argraw+0x2c>
    return p->trapframe->a4;
    8000286a:	6d3c                	ld	a5,88(a0)
    8000286c:	6bc8                	ld	a0,144(a5)
    8000286e:	b7c5                	j	8000284e <argraw+0x2c>
    return p->trapframe->a5;
    80002870:	6d3c                	ld	a5,88(a0)
    80002872:	6fc8                	ld	a0,152(a5)
    80002874:	bfe9                	j	8000284e <argraw+0x2c>
  panic("argraw");
    80002876:	00005517          	auipc	a0,0x5
    8000287a:	b1250513          	addi	a0,a0,-1262 # 80007388 <etext+0x388>
    8000287e:	fb7fd0ef          	jal	80000834 <panic>

0000000080002882 <fetchaddr>:
{
    80002882:	1101                	addi	sp,sp,-32
    80002884:	ec06                	sd	ra,24(sp)
    80002886:	e822                	sd	s0,16(sp)
    80002888:	e426                	sd	s1,8(sp)
    8000288a:	e04a                	sd	s2,0(sp)
    8000288c:	1000                	addi	s0,sp,32
    8000288e:	84aa                	mv	s1,a0
    80002890:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002892:	8beff0ef          	jal	80001950 <myproc>
  if (addr >= p->sz ||
    80002896:	652c                	ld	a1,72(a0)
    80002898:	02b4f663          	bgeu	s1,a1,800028c4 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000289c:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    800028a0:	02f5e463          	bltu	a1,a5,800028c8 <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    800028a4:	4721                	li	a4,8
    800028a6:	86a6                	mv	a3,s1
    800028a8:	864a                	mv	a2,s2
    800028aa:	6928                	ld	a0,80(a0)
    800028ac:	da5fe0ef          	jal	80001650 <copyin>
    800028b0:	00a03533          	snez	a0,a0
    800028b4:	40a0053b          	negw	a0,a0
}
    800028b8:	60e2                	ld	ra,24(sp)
    800028ba:	6442                	ld	s0,16(sp)
    800028bc:	64a2                	ld	s1,8(sp)
    800028be:	6902                	ld	s2,0(sp)
    800028c0:	6105                	addi	sp,sp,32
    800028c2:	8082                	ret
    return -1;
    800028c4:	557d                	li	a0,-1
    800028c6:	bfcd                	j	800028b8 <fetchaddr+0x36>
    800028c8:	557d                	li	a0,-1
    800028ca:	b7fd                	j	800028b8 <fetchaddr+0x36>

00000000800028cc <fetchstr>:
{
    800028cc:	7179                	addi	sp,sp,-48
    800028ce:	f406                	sd	ra,40(sp)
    800028d0:	f022                	sd	s0,32(sp)
    800028d2:	ec26                	sd	s1,24(sp)
    800028d4:	e84a                	sd	s2,16(sp)
    800028d6:	e44e                	sd	s3,8(sp)
    800028d8:	1800                	addi	s0,sp,48
    800028da:	89aa                	mv	s3,a0
    800028dc:	84ae                	mv	s1,a1
    800028de:	8932                	mv	s2,a2
  struct proc *p = myproc();
    800028e0:	870ff0ef          	jal	80001950 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    800028e4:	874a                	mv	a4,s2
    800028e6:	86ce                	mv	a3,s3
    800028e8:	8626                	mv	a2,s1
    800028ea:	652c                	ld	a1,72(a0)
    800028ec:	6928                	ld	a0,80(a0)
    800028ee:	dfffe0ef          	jal	800016ec <copyinstr>
    800028f2:	00054c63          	bltz	a0,8000290a <fetchstr+0x3e>
  return strlen(buf);
    800028f6:	8526                	mv	a0,s1
    800028f8:	d7afe0ef          	jal	80000e72 <strlen>
}
    800028fc:	70a2                	ld	ra,40(sp)
    800028fe:	7402                	ld	s0,32(sp)
    80002900:	64e2                	ld	s1,24(sp)
    80002902:	6942                	ld	s2,16(sp)
    80002904:	69a2                	ld	s3,8(sp)
    80002906:	6145                	addi	sp,sp,48
    80002908:	8082                	ret
    return -1;
    8000290a:	557d                	li	a0,-1
    8000290c:	bfc5                	j	800028fc <fetchstr+0x30>

000000008000290e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000290e:	1101                	addi	sp,sp,-32
    80002910:	ec06                	sd	ra,24(sp)
    80002912:	e822                	sd	s0,16(sp)
    80002914:	e426                	sd	s1,8(sp)
    80002916:	1000                	addi	s0,sp,32
    80002918:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000291a:	f09ff0ef          	jal	80002822 <argraw>
    8000291e:	c088                	sw	a0,0(s1)
}
    80002920:	60e2                	ld	ra,24(sp)
    80002922:	6442                	ld	s0,16(sp)
    80002924:	64a2                	ld	s1,8(sp)
    80002926:	6105                	addi	sp,sp,32
    80002928:	8082                	ret

000000008000292a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000292a:	1101                	addi	sp,sp,-32
    8000292c:	ec06                	sd	ra,24(sp)
    8000292e:	e822                	sd	s0,16(sp)
    80002930:	e426                	sd	s1,8(sp)
    80002932:	1000                	addi	s0,sp,32
    80002934:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002936:	eedff0ef          	jal	80002822 <argraw>
    8000293a:	e088                	sd	a0,0(s1)
}
    8000293c:	60e2                	ld	ra,24(sp)
    8000293e:	6442                	ld	s0,16(sp)
    80002940:	64a2                	ld	s1,8(sp)
    80002942:	6105                	addi	sp,sp,32
    80002944:	8082                	ret

0000000080002946 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002946:	1101                	addi	sp,sp,-32
    80002948:	ec06                	sd	ra,24(sp)
    8000294a:	e822                	sd	s0,16(sp)
    8000294c:	e426                	sd	s1,8(sp)
    8000294e:	e04a                	sd	s2,0(sp)
    80002950:	1000                	addi	s0,sp,32
    80002952:	892e                	mv	s2,a1
    80002954:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002956:	ecdff0ef          	jal	80002822 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    8000295a:	8626                	mv	a2,s1
    8000295c:	85ca                	mv	a1,s2
    8000295e:	f6fff0ef          	jal	800028cc <fetchstr>
}
    80002962:	60e2                	ld	ra,24(sp)
    80002964:	6442                	ld	s0,16(sp)
    80002966:	64a2                	ld	s1,8(sp)
    80002968:	6902                	ld	s2,0(sp)
    8000296a:	6105                	addi	sp,sp,32
    8000296c:	8082                	ret

000000008000296e <syscall>:
  // clang-format on
};

void
syscall(void)
{
    8000296e:	1101                	addi	sp,sp,-32
    80002970:	ec06                	sd	ra,24(sp)
    80002972:	e822                	sd	s0,16(sp)
    80002974:	e426                	sd	s1,8(sp)
    80002976:	e04a                	sd	s2,0(sp)
    80002978:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000297a:	fd7fe0ef          	jal	80001950 <myproc>
    8000297e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002980:	05853903          	ld	s2,88(a0)
    80002984:	0a893783          	ld	a5,168(s2)
    80002988:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000298c:	37fd                	addiw	a5,a5,-1
    8000298e:	4765                	li	a4,25
    80002990:	00f76f63          	bltu	a4,a5,800029ae <syscall+0x40>
    80002994:	00369713          	slli	a4,a3,0x3
    80002998:	00005797          	auipc	a5,0x5
    8000299c:	e0878793          	addi	a5,a5,-504 # 800077a0 <syscalls>
    800029a0:	97ba                	add	a5,a5,a4
    800029a2:	639c                	ld	a5,0(a5)
    800029a4:	c789                	beqz	a5,800029ae <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800029a6:	9782                	jalr	a5
    800029a8:	06a93823          	sd	a0,112(s2)
    800029ac:	a829                	j	800029c6 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    800029ae:	15848613          	addi	a2,s1,344
    800029b2:	588c                	lw	a1,48(s1)
    800029b4:	00005517          	auipc	a0,0x5
    800029b8:	9dc50513          	addi	a0,a0,-1572 # 80007390 <etext+0x390>
    800029bc:	b4ffd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    800029c0:	6cbc                	ld	a5,88(s1)
    800029c2:	577d                	li	a4,-1
    800029c4:	fbb8                	sd	a4,112(a5)
  }
}
    800029c6:	60e2                	ld	ra,24(sp)
    800029c8:	6442                	ld	s0,16(sp)
    800029ca:	64a2                	ld	s1,8(sp)
    800029cc:	6902                	ld	s2,0(sp)
    800029ce:	6105                	addi	sp,sp,32
    800029d0:	8082                	ret

00000000800029d2 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800029d2:	1101                	addi	sp,sp,-32
    800029d4:	ec06                	sd	ra,24(sp)
    800029d6:	e822                	sd	s0,16(sp)
    800029d8:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800029da:	fec40593          	addi	a1,s0,-20
    800029de:	4501                	li	a0,0
    800029e0:	f2fff0ef          	jal	8000290e <argint>
  kexit(n);
    800029e4:	fec42503          	lw	a0,-20(s0)
    800029e8:	f10ff0ef          	jal	800020f8 <kexit>
  return 0; // not reached
}
    800029ec:	4501                	li	a0,0
    800029ee:	60e2                	ld	ra,24(sp)
    800029f0:	6442                	ld	s0,16(sp)
    800029f2:	6105                	addi	sp,sp,32
    800029f4:	8082                	ret

00000000800029f6 <sys_getpid>:

uint64
sys_getpid(void)
{
    800029f6:	1141                	addi	sp,sp,-16
    800029f8:	e406                	sd	ra,8(sp)
    800029fa:	e022                	sd	s0,0(sp)
    800029fc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800029fe:	f53fe0ef          	jal	80001950 <myproc>
}
    80002a02:	5908                	lw	a0,48(a0)
    80002a04:	60a2                	ld	ra,8(sp)
    80002a06:	6402                	ld	s0,0(sp)
    80002a08:	0141                	addi	sp,sp,16
    80002a0a:	8082                	ret

0000000080002a0c <sys_fork>:

uint64
sys_fork(void)
{
    80002a0c:	1141                	addi	sp,sp,-16
    80002a0e:	e406                	sd	ra,8(sp)
    80002a10:	e022                	sd	s0,0(sp)
    80002a12:	0800                	addi	s0,sp,16
  return kfork();
    80002a14:	ac8ff0ef          	jal	80001cdc <kfork>
}
    80002a18:	60a2                	ld	ra,8(sp)
    80002a1a:	6402                	ld	s0,0(sp)
    80002a1c:	0141                	addi	sp,sp,16
    80002a1e:	8082                	ret

0000000080002a20 <sys_wait>:

uint64
sys_wait(void)
{
    80002a20:	1101                	addi	sp,sp,-32
    80002a22:	ec06                	sd	ra,24(sp)
    80002a24:	e822                	sd	s0,16(sp)
    80002a26:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a28:	fe840593          	addi	a1,s0,-24
    80002a2c:	4501                	li	a0,0
    80002a2e:	efdff0ef          	jal	8000292a <argaddr>
  return kwait(p);
    80002a32:	fe843503          	ld	a0,-24(s0)
    80002a36:	823ff0ef          	jal	80002258 <kwait>
}
    80002a3a:	60e2                	ld	ra,24(sp)
    80002a3c:	6442                	ld	s0,16(sp)
    80002a3e:	6105                	addi	sp,sp,32
    80002a40:	8082                	ret

0000000080002a42 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a42:	7179                	addi	sp,sp,-48
    80002a44:	f406                	sd	ra,40(sp)
    80002a46:	f022                	sd	s0,32(sp)
    80002a48:	ec26                	sd	s1,24(sp)
    80002a4a:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a4c:	fd840593          	addi	a1,s0,-40
    80002a50:	4501                	li	a0,0
    80002a52:	ebdff0ef          	jal	8000290e <argint>
  argint(1, &t);
    80002a56:	fdc40593          	addi	a1,s0,-36
    80002a5a:	4505                	li	a0,1
    80002a5c:	eb3ff0ef          	jal	8000290e <argint>
  addr = myproc()->sz;
    80002a60:	ef1fe0ef          	jal	80001950 <myproc>
    80002a64:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002a66:	fdc42703          	lw	a4,-36(s0)
    80002a6a:	4785                	li	a5,1
    80002a6c:	02f70763          	beq	a4,a5,80002a9a <sys_sbrk+0x58>
    80002a70:	fd842783          	lw	a5,-40(s0)
    80002a74:	0207c363          	bltz	a5,80002a9a <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002a78:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002a7a:	02000737          	lui	a4,0x2000
    80002a7e:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002a80:	0736                	slli	a4,a4,0xd
    80002a82:	02f76a63          	bltu	a4,a5,80002ab6 <sys_sbrk+0x74>
    80002a86:	0297e863          	bltu	a5,s1,80002ab6 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002a8a:	ec7fe0ef          	jal	80001950 <myproc>
    80002a8e:	fd842703          	lw	a4,-40(s0)
    80002a92:	653c                	ld	a5,72(a0)
    80002a94:	97ba                	add	a5,a5,a4
    80002a96:	e53c                	sd	a5,72(a0)
    80002a98:	a039                	j	80002aa6 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002a9a:	fd842503          	lw	a0,-40(s0)
    80002a9e:	9dcff0ef          	jal	80001c7a <growproc>
    80002aa2:	00054863          	bltz	a0,80002ab2 <sys_sbrk+0x70>
  }
  return addr;
}
    80002aa6:	8526                	mv	a0,s1
    80002aa8:	70a2                	ld	ra,40(sp)
    80002aaa:	7402                	ld	s0,32(sp)
    80002aac:	64e2                	ld	s1,24(sp)
    80002aae:	6145                	addi	sp,sp,48
    80002ab0:	8082                	ret
      return -1;
    80002ab2:	54fd                	li	s1,-1
    80002ab4:	bfcd                	j	80002aa6 <sys_sbrk+0x64>
      return -1;
    80002ab6:	54fd                	li	s1,-1
    80002ab8:	b7fd                	j	80002aa6 <sys_sbrk+0x64>

0000000080002aba <sys_pause>:

uint64
sys_pause(void)
{
    80002aba:	7139                	addi	sp,sp,-64
    80002abc:	fc06                	sd	ra,56(sp)
    80002abe:	f822                	sd	s0,48(sp)
    80002ac0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002ac2:	fcc40593          	addi	a1,s0,-52
    80002ac6:	4501                	li	a0,0
    80002ac8:	e47ff0ef          	jal	8000290e <argint>
  if (n < 0)
    80002acc:	fcc42783          	lw	a5,-52(s0)
    80002ad0:	0807c063          	bltz	a5,80002b50 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002ad4:	00016517          	auipc	a0,0x16
    80002ad8:	95450513          	addi	a0,a0,-1708 # 80018428 <tickslock>
    80002adc:	94cfe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002ae0:	fcc42783          	lw	a5,-52(s0)
    80002ae4:	cbb9                	beqz	a5,80002b3a <sys_pause+0x80>
    80002ae6:	f426                	sd	s1,40(sp)
    80002ae8:	f04a                	sd	s2,32(sp)
    80002aea:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002aec:	00008997          	auipc	s3,0x8
    80002af0:	9fc9a983          	lw	s3,-1540(s3) # 8000a4e8 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002af4:	00008917          	auipc	s2,0x8
    80002af8:	9f490913          	addi	s2,s2,-1548 # 8000a4e8 <ticks>
    release(&tickslock);
    80002afc:	00016497          	auipc	s1,0x16
    80002b00:	92c48493          	addi	s1,s1,-1748 # 80018428 <tickslock>
    if (killed(myproc())) {
    80002b04:	e4dfe0ef          	jal	80001950 <myproc>
    80002b08:	f26ff0ef          	jal	8000222e <killed>
    80002b0c:	e529                	bnez	a0,80002b56 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002b0e:	854a                	mv	a0,s2
    80002b10:	cc0ff0ef          	jal	80001fd0 <sleep_prepare>
    release(&tickslock);
    80002b14:	8526                	mv	a0,s1
    80002b16:	99afe0ef          	jal	80000cb0 <release>
    sleep();
    80002b1a:	cf2ff0ef          	jal	8000200c <sleep>
    acquire(&tickslock);
    80002b1e:	8526                	mv	a0,s1
    80002b20:	908fe0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002b24:	00092783          	lw	a5,0(s2)
    80002b28:	413787bb          	subw	a5,a5,s3
    80002b2c:	fcc42703          	lw	a4,-52(s0)
    80002b30:	fce7eae3          	bltu	a5,a4,80002b04 <sys_pause+0x4a>
    80002b34:	74a2                	ld	s1,40(sp)
    80002b36:	7902                	ld	s2,32(sp)
    80002b38:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b3a:	00016517          	auipc	a0,0x16
    80002b3e:	8ee50513          	addi	a0,a0,-1810 # 80018428 <tickslock>
    80002b42:	96efe0ef          	jal	80000cb0 <release>
  return 0;
    80002b46:	4501                	li	a0,0
}
    80002b48:	70e2                	ld	ra,56(sp)
    80002b4a:	7442                	ld	s0,48(sp)
    80002b4c:	6121                	addi	sp,sp,64
    80002b4e:	8082                	ret
    n = 0;
    80002b50:	fc042623          	sw	zero,-52(s0)
    80002b54:	b741                	j	80002ad4 <sys_pause+0x1a>
      release(&tickslock);
    80002b56:	00016517          	auipc	a0,0x16
    80002b5a:	8d250513          	addi	a0,a0,-1838 # 80018428 <tickslock>
    80002b5e:	952fe0ef          	jal	80000cb0 <release>
      return -1;
    80002b62:	557d                	li	a0,-1
    80002b64:	74a2                	ld	s1,40(sp)
    80002b66:	7902                	ld	s2,32(sp)
    80002b68:	69e2                	ld	s3,24(sp)
    80002b6a:	bff9                	j	80002b48 <sys_pause+0x8e>

0000000080002b6c <sys_kill>:

uint64
sys_kill(void)
{
    80002b6c:	1101                	addi	sp,sp,-32
    80002b6e:	ec06                	sd	ra,24(sp)
    80002b70:	e822                	sd	s0,16(sp)
    80002b72:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b74:	fec40593          	addi	a1,s0,-20
    80002b78:	4501                	li	a0,0
    80002b7a:	d95ff0ef          	jal	8000290e <argint>
  return kkill(pid);
    80002b7e:	fec42503          	lw	a0,-20(s0)
    80002b82:	e1cff0ef          	jal	8000219e <kkill>
}
    80002b86:	60e2                	ld	ra,24(sp)
    80002b88:	6442                	ld	s0,16(sp)
    80002b8a:	6105                	addi	sp,sp,32
    80002b8c:	8082                	ret

0000000080002b8e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b8e:	1101                	addi	sp,sp,-32
    80002b90:	ec06                	sd	ra,24(sp)
    80002b92:	e822                	sd	s0,16(sp)
    80002b94:	e426                	sd	s1,8(sp)
    80002b96:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b98:	00016517          	auipc	a0,0x16
    80002b9c:	89050513          	addi	a0,a0,-1904 # 80018428 <tickslock>
    80002ba0:	888fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002ba4:	00008797          	auipc	a5,0x8
    80002ba8:	9447a783          	lw	a5,-1724(a5) # 8000a4e8 <ticks>
    80002bac:	84be                	mv	s1,a5
  release(&tickslock);
    80002bae:	00016517          	auipc	a0,0x16
    80002bb2:	87a50513          	addi	a0,a0,-1926 # 80018428 <tickslock>
    80002bb6:	8fafe0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002bba:	02049513          	slli	a0,s1,0x20
    80002bbe:	9101                	srli	a0,a0,0x20
    80002bc0:	60e2                	ld	ra,24(sp)
    80002bc2:	6442                	ld	s0,16(sp)
    80002bc4:	64a2                	ld	s1,8(sp)
    80002bc6:	6105                	addi	sp,sp,32
    80002bc8:	8082                	ret

0000000080002bca <shminit>:
static char *global_shm_page = 0;
static struct spinlock global_shm_lock;

void
shminit(void)
{
    80002bca:	1141                	addi	sp,sp,-16
    80002bcc:	e406                	sd	ra,8(sp)
    80002bce:	e022                	sd	s0,0(sp)
    80002bd0:	0800                	addi	s0,sp,16
  initlock(&global_shm_lock, "shm");
    80002bd2:	00004597          	auipc	a1,0x4
    80002bd6:	7de58593          	addi	a1,a1,2014 # 800073b0 <etext+0x3b0>
    80002bda:	00016517          	auipc	a0,0x16
    80002bde:	86650513          	addi	a0,a0,-1946 # 80018440 <global_shm_lock>
    80002be2:	fc7fd0ef          	jal	80000ba8 <initlock>
}
    80002be6:	60a2                	ld	ra,8(sp)
    80002be8:	6402                	ld	s0,0(sp)
    80002bea:	0141                	addi	sp,sp,16
    80002bec:	8082                	ret

0000000080002bee <shm_get>:

uint64
shm_get(void)
{
    80002bee:	1101                	addi	sp,sp,-32
    80002bf0:	ec06                	sd	ra,24(sp)
    80002bf2:	e822                	sd	s0,16(sp)
    80002bf4:	e426                	sd	s1,8(sp)
    80002bf6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002bf8:	d59fe0ef          	jal	80001950 <myproc>
    80002bfc:	84aa                	mv	s1,a0

  acquire(&global_shm_lock);
    80002bfe:	00016517          	auipc	a0,0x16
    80002c02:	84250513          	addi	a0,a0,-1982 # 80018440 <global_shm_lock>
    80002c06:	822fe0ef          	jal	80000c28 <acquire>
  if (global_shm_page == 0) {
    80002c0a:	00008797          	auipc	a5,0x8
    80002c0e:	8e67b783          	ld	a5,-1818(a5) # 8000a4f0 <global_shm_page>
    80002c12:	cbb1                	beqz	a5,80002c66 <shm_get+0x78>
      return 0;
    }
    memset(global_shm_page, 0, PGSIZE);
  }

  pte_t *pte = walk(p->pagetable, SHM_VA, 0);
    80002c14:	4601                	li	a2,0
    80002c16:	040005b7          	lui	a1,0x4000
    80002c1a:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80002c1c:	05b2                	slli	a1,a1,0xc
    80002c1e:	68a8                	ld	a0,80(s1)
    80002c20:	b66fe0ef          	jal	80000f86 <walk>
  if (pte == 0 || (*pte & PTE_V) == 0) {
    80002c24:	c501                	beqz	a0,80002c2c <shm_get+0x3e>
    80002c26:	611c                	ld	a5,0(a0)
    80002c28:	8b85                	andi	a5,a5,1
    80002c2a:	ef99                	bnez	a5,80002c48 <shm_get+0x5a>
    if (mappages(p->pagetable, SHM_VA, PGSIZE, (uint64)global_shm_page, PTE_R | PTE_W | PTE_U) != 0) {
    80002c2c:	4759                	li	a4,22
    80002c2e:	00008697          	auipc	a3,0x8
    80002c32:	8c26b683          	ld	a3,-1854(a3) # 8000a4f0 <global_shm_page>
    80002c36:	6605                	lui	a2,0x1
    80002c38:	040005b7          	lui	a1,0x4000
    80002c3c:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80002c3e:	05b2                	slli	a1,a1,0xc
    80002c40:	68a8                	ld	a0,80(s1)
    80002c42:	c18fe0ef          	jal	8000105a <mappages>
    80002c46:	e521                	bnez	a0,80002c8e <shm_get+0xa0>
      release(&global_shm_lock);
      return 0;
    }
  }
  release(&global_shm_lock);
    80002c48:	00015517          	auipc	a0,0x15
    80002c4c:	7f850513          	addi	a0,a0,2040 # 80018440 <global_shm_lock>
    80002c50:	860fe0ef          	jal	80000cb0 <release>
  return SHM_VA;
    80002c54:	04000537          	lui	a0,0x4000
    80002c58:	1575                	addi	a0,a0,-3 # 3fffffd <_entry-0x7c000003>
    80002c5a:	0532                	slli	a0,a0,0xc
}
    80002c5c:	60e2                	ld	ra,24(sp)
    80002c5e:	6442                	ld	s0,16(sp)
    80002c60:	64a2                	ld	s1,8(sp)
    80002c62:	6105                	addi	sp,sp,32
    80002c64:	8082                	ret
    global_shm_page = kalloc();
    80002c66:	ee9fd0ef          	jal	80000b4e <kalloc>
    80002c6a:	00008797          	auipc	a5,0x8
    80002c6e:	88a7b323          	sd	a0,-1914(a5) # 8000a4f0 <global_shm_page>
    if (global_shm_page == 0) {
    80002c72:	c511                	beqz	a0,80002c7e <shm_get+0x90>
    memset(global_shm_page, 0, PGSIZE);
    80002c74:	6605                	lui	a2,0x1
    80002c76:	4581                	li	a1,0
    80002c78:	870fe0ef          	jal	80000ce8 <memset>
    80002c7c:	bf61                	j	80002c14 <shm_get+0x26>
      release(&global_shm_lock);
    80002c7e:	00015517          	auipc	a0,0x15
    80002c82:	7c250513          	addi	a0,a0,1986 # 80018440 <global_shm_lock>
    80002c86:	82afe0ef          	jal	80000cb0 <release>
      return 0;
    80002c8a:	4501                	li	a0,0
    80002c8c:	bfc1                	j	80002c5c <shm_get+0x6e>
      release(&global_shm_lock);
    80002c8e:	00015517          	auipc	a0,0x15
    80002c92:	7b250513          	addi	a0,a0,1970 # 80018440 <global_shm_lock>
    80002c96:	81afe0ef          	jal	80000cb0 <release>
      return 0;
    80002c9a:	4501                	li	a0,0
    80002c9c:	b7c1                	j	80002c5c <shm_get+0x6e>

0000000080002c9e <sys_shm_get>:

uint64
sys_shm_get(void)
{
    80002c9e:	1141                	addi	sp,sp,-16
    80002ca0:	e406                	sd	ra,8(sp)
    80002ca2:	e022                	sd	s0,0(sp)
    80002ca4:	0800                	addi	s0,sp,16
  return shm_get();
    80002ca6:	f49ff0ef          	jal	80002bee <shm_get>
}
    80002caa:	60a2                	ld	ra,8(sp)
    80002cac:	6402                	ld	s0,0(sp)
    80002cae:	0141                	addi	sp,sp,16
    80002cb0:	8082                	ret

0000000080002cb2 <seminit>:

static struct semaphore sems[MAX_SEM];

void
seminit(void)
{
    80002cb2:	7179                	addi	sp,sp,-48
    80002cb4:	f406                	sd	ra,40(sp)
    80002cb6:	f022                	sd	s0,32(sp)
    80002cb8:	ec26                	sd	s1,24(sp)
    80002cba:	e84a                	sd	s2,16(sp)
    80002cbc:	e44e                	sd	s3,8(sp)
    80002cbe:	1800                	addi	s0,sp,48
  for (int i = 0; i < MAX_SEM; i++) {
    80002cc0:	00015497          	auipc	s1,0x15
    80002cc4:	79848493          	addi	s1,s1,1944 # 80018458 <sems>
    80002cc8:	00016997          	auipc	s3,0x16
    80002ccc:	b9098993          	addi	s3,s3,-1136 # 80018858 <bcache>
    initlock(&sems[i].lock, "sem");
    80002cd0:	00004917          	auipc	s2,0x4
    80002cd4:	6e890913          	addi	s2,s2,1768 # 800073b8 <etext+0x3b8>
    80002cd8:	85ca                	mv	a1,s2
    80002cda:	8526                	mv	a0,s1
    80002cdc:	ecdfd0ef          	jal	80000ba8 <initlock>
    sems[i].value = 0;
    80002ce0:	0004ac23          	sw	zero,24(s1)
    sems[i].active = 0;
    80002ce4:	0004ae23          	sw	zero,28(s1)
  for (int i = 0; i < MAX_SEM; i++) {
    80002ce8:	02048493          	addi	s1,s1,32
    80002cec:	ff3496e3          	bne	s1,s3,80002cd8 <seminit+0x26>
  }
}
    80002cf0:	70a2                	ld	ra,40(sp)
    80002cf2:	7402                	ld	s0,32(sp)
    80002cf4:	64e2                	ld	s1,24(sp)
    80002cf6:	6942                	ld	s2,16(sp)
    80002cf8:	69a2                	ld	s3,8(sp)
    80002cfa:	6145                	addi	sp,sp,48
    80002cfc:	8082                	ret

0000000080002cfe <ksem_init>:

int
ksem_init(int id, int val)
{
  if (id < 0 || id >= MAX_SEM)
    80002cfe:	47fd                	li	a5,31
    80002d00:	04a7e863          	bltu	a5,a0,80002d50 <ksem_init+0x52>
{
    80002d04:	7179                	addi	sp,sp,-48
    80002d06:	f406                	sd	ra,40(sp)
    80002d08:	f022                	sd	s0,32(sp)
    80002d0a:	ec26                	sd	s1,24(sp)
    80002d0c:	e84a                	sd	s2,16(sp)
    80002d0e:	e44e                	sd	s3,8(sp)
    80002d10:	1800                	addi	s0,sp,48
    80002d12:	89ae                	mv	s3,a1
    return -1;
  acquire(&sems[id].lock);
    80002d14:	00551493          	slli	s1,a0,0x5
    80002d18:	00015917          	auipc	s2,0x15
    80002d1c:	74090913          	addi	s2,s2,1856 # 80018458 <sems>
    80002d20:	9926                	add	s2,s2,s1
    80002d22:	854a                	mv	a0,s2
    80002d24:	f05fd0ef          	jal	80000c28 <acquire>
  sems[id].value = val;
    80002d28:	00015797          	auipc	a5,0x15
    80002d2c:	71878793          	addi	a5,a5,1816 # 80018440 <global_shm_lock>
    80002d30:	97a6                	add	a5,a5,s1
    80002d32:	0337a823          	sw	s3,48(a5)
  sems[id].active = 1;
    80002d36:	4705                	li	a4,1
    80002d38:	dbd8                	sw	a4,52(a5)
  release(&sems[id].lock);
    80002d3a:	854a                	mv	a0,s2
    80002d3c:	f75fd0ef          	jal	80000cb0 <release>
  return 0;
    80002d40:	4501                	li	a0,0
}
    80002d42:	70a2                	ld	ra,40(sp)
    80002d44:	7402                	ld	s0,32(sp)
    80002d46:	64e2                	ld	s1,24(sp)
    80002d48:	6942                	ld	s2,16(sp)
    80002d4a:	69a2                	ld	s3,8(sp)
    80002d4c:	6145                	addi	sp,sp,48
    80002d4e:	8082                	ret
    return -1;
    80002d50:	557d                	li	a0,-1
}
    80002d52:	8082                	ret

0000000080002d54 <ksem_wait>:

int
ksem_wait(int id)
{
  if (id < 0 || id >= MAX_SEM)
    80002d54:	47fd                	li	a5,31
    80002d56:	08a7e463          	bltu	a5,a0,80002dde <ksem_wait+0x8a>
{
    80002d5a:	7179                	addi	sp,sp,-48
    80002d5c:	f406                	sd	ra,40(sp)
    80002d5e:	f022                	sd	s0,32(sp)
    80002d60:	ec26                	sd	s1,24(sp)
    80002d62:	e84a                	sd	s2,16(sp)
    80002d64:	e44e                	sd	s3,8(sp)
    80002d66:	1800                	addi	s0,sp,48
    80002d68:	89aa                	mv	s3,a0
    return -1;
  acquire(&sems[id].lock);
    80002d6a:	00551913          	slli	s2,a0,0x5
    80002d6e:	00015497          	auipc	s1,0x15
    80002d72:	6ea48493          	addi	s1,s1,1770 # 80018458 <sems>
    80002d76:	94ca                	add	s1,s1,s2
    80002d78:	8526                	mv	a0,s1
    80002d7a:	eaffd0ef          	jal	80000c28 <acquire>
  while (sems[id].value <= 0) {
    80002d7e:	00015797          	auipc	a5,0x15
    80002d82:	6c278793          	addi	a5,a5,1730 # 80018440 <global_shm_lock>
    80002d86:	97ca                	add	a5,a5,s2
    80002d88:	5b9c                	lw	a5,48(a5)
    80002d8a:	02f04763          	bgtz	a5,80002db8 <ksem_wait+0x64>
    80002d8e:	87ca                	mv	a5,s2
    80002d90:	00015917          	auipc	s2,0x15
    80002d94:	6b090913          	addi	s2,s2,1712 # 80018440 <global_shm_lock>
    80002d98:	993e                	add	s2,s2,a5
    sleep_prepare(&sems[id]);
    80002d9a:	8526                	mv	a0,s1
    80002d9c:	a34ff0ef          	jal	80001fd0 <sleep_prepare>
    release(&sems[id].lock);
    80002da0:	8526                	mv	a0,s1
    80002da2:	f0ffd0ef          	jal	80000cb0 <release>
    sleep();
    80002da6:	a66ff0ef          	jal	8000200c <sleep>
    acquire(&sems[id].lock);
    80002daa:	8526                	mv	a0,s1
    80002dac:	e7dfd0ef          	jal	80000c28 <acquire>
  while (sems[id].value <= 0) {
    80002db0:	03092783          	lw	a5,48(s2)
    80002db4:	fef053e3          	blez	a5,80002d9a <ksem_wait+0x46>
  }
  sems[id].value--;
    80002db8:	0996                	slli	s3,s3,0x5
    80002dba:	00015717          	auipc	a4,0x15
    80002dbe:	68670713          	addi	a4,a4,1670 # 80018440 <global_shm_lock>
    80002dc2:	974e                	add	a4,a4,s3
    80002dc4:	37fd                	addiw	a5,a5,-1
    80002dc6:	db1c                	sw	a5,48(a4)
  release(&sems[id].lock);
    80002dc8:	8526                	mv	a0,s1
    80002dca:	ee7fd0ef          	jal	80000cb0 <release>
  return 0;
    80002dce:	4501                	li	a0,0
}
    80002dd0:	70a2                	ld	ra,40(sp)
    80002dd2:	7402                	ld	s0,32(sp)
    80002dd4:	64e2                	ld	s1,24(sp)
    80002dd6:	6942                	ld	s2,16(sp)
    80002dd8:	69a2                	ld	s3,8(sp)
    80002dda:	6145                	addi	sp,sp,48
    80002ddc:	8082                	ret
    return -1;
    80002dde:	557d                	li	a0,-1
}
    80002de0:	8082                	ret

0000000080002de2 <ksem_post>:

int
ksem_post(int id)
{
  if (id < 0 || id >= MAX_SEM)
    80002de2:	47fd                	li	a5,31
    80002de4:	04a7e763          	bltu	a5,a0,80002e32 <ksem_post+0x50>
{
    80002de8:	1101                	addi	sp,sp,-32
    80002dea:	ec06                	sd	ra,24(sp)
    80002dec:	e822                	sd	s0,16(sp)
    80002dee:	e426                	sd	s1,8(sp)
    80002df0:	e04a                	sd	s2,0(sp)
    80002df2:	1000                	addi	s0,sp,32
    return -1;
  acquire(&sems[id].lock);
    80002df4:	00551493          	slli	s1,a0,0x5
    80002df8:	00015917          	auipc	s2,0x15
    80002dfc:	66090913          	addi	s2,s2,1632 # 80018458 <sems>
    80002e00:	9926                	add	s2,s2,s1
    80002e02:	854a                	mv	a0,s2
    80002e04:	e25fd0ef          	jal	80000c28 <acquire>
  sems[id].value++;
    80002e08:	00015797          	auipc	a5,0x15
    80002e0c:	63878793          	addi	a5,a5,1592 # 80018440 <global_shm_lock>
    80002e10:	97a6                	add	a5,a5,s1
    80002e12:	5b98                	lw	a4,48(a5)
    80002e14:	2705                	addiw	a4,a4,1
    80002e16:	db98                	sw	a4,48(a5)
  wakeup(&sems[id]);
    80002e18:	854a                	mv	a0,s2
    80002e1a:	a22ff0ef          	jal	8000203c <wakeup>
  release(&sems[id].lock);
    80002e1e:	854a                	mv	a0,s2
    80002e20:	e91fd0ef          	jal	80000cb0 <release>
  return 0;
    80002e24:	4501                	li	a0,0
}
    80002e26:	60e2                	ld	ra,24(sp)
    80002e28:	6442                	ld	s0,16(sp)
    80002e2a:	64a2                	ld	s1,8(sp)
    80002e2c:	6902                	ld	s2,0(sp)
    80002e2e:	6105                	addi	sp,sp,32
    80002e30:	8082                	ret
    return -1;
    80002e32:	557d                	li	a0,-1
}
    80002e34:	8082                	ret

0000000080002e36 <sys_sem_init>:

uint64
sys_sem_init(void)
{
    80002e36:	1101                	addi	sp,sp,-32
    80002e38:	ec06                	sd	ra,24(sp)
    80002e3a:	e822                	sd	s0,16(sp)
    80002e3c:	1000                	addi	s0,sp,32
  int id, val;
  argint(0, &id);
    80002e3e:	fec40593          	addi	a1,s0,-20
    80002e42:	4501                	li	a0,0
    80002e44:	acbff0ef          	jal	8000290e <argint>
  argint(1, &val);
    80002e48:	fe840593          	addi	a1,s0,-24
    80002e4c:	4505                	li	a0,1
    80002e4e:	ac1ff0ef          	jal	8000290e <argint>
  return ksem_init(id, val);
    80002e52:	fe842583          	lw	a1,-24(s0)
    80002e56:	fec42503          	lw	a0,-20(s0)
    80002e5a:	ea5ff0ef          	jal	80002cfe <ksem_init>
}
    80002e5e:	60e2                	ld	ra,24(sp)
    80002e60:	6442                	ld	s0,16(sp)
    80002e62:	6105                	addi	sp,sp,32
    80002e64:	8082                	ret

0000000080002e66 <sys_sem_wait>:

uint64
sys_sem_wait(void)
{
    80002e66:	1101                	addi	sp,sp,-32
    80002e68:	ec06                	sd	ra,24(sp)
    80002e6a:	e822                	sd	s0,16(sp)
    80002e6c:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    80002e6e:	fec40593          	addi	a1,s0,-20
    80002e72:	4501                	li	a0,0
    80002e74:	a9bff0ef          	jal	8000290e <argint>
  return ksem_wait(id);
    80002e78:	fec42503          	lw	a0,-20(s0)
    80002e7c:	ed9ff0ef          	jal	80002d54 <ksem_wait>
}
    80002e80:	60e2                	ld	ra,24(sp)
    80002e82:	6442                	ld	s0,16(sp)
    80002e84:	6105                	addi	sp,sp,32
    80002e86:	8082                	ret

0000000080002e88 <sys_sem_post>:

uint64
sys_sem_post(void)
{
    80002e88:	1101                	addi	sp,sp,-32
    80002e8a:	ec06                	sd	ra,24(sp)
    80002e8c:	e822                	sd	s0,16(sp)
    80002e8e:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    80002e90:	fec40593          	addi	a1,s0,-20
    80002e94:	4501                	li	a0,0
    80002e96:	a79ff0ef          	jal	8000290e <argint>
  return ksem_post(id);
    80002e9a:	fec42503          	lw	a0,-20(s0)
    80002e9e:	f45ff0ef          	jal	80002de2 <ksem_post>
}
    80002ea2:	60e2                	ld	ra,24(sp)
    80002ea4:	6442                	ld	s0,16(sp)
    80002ea6:	6105                	addi	sp,sp,32
    80002ea8:	8082                	ret

0000000080002eaa <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002eaa:	7179                	addi	sp,sp,-48
    80002eac:	f406                	sd	ra,40(sp)
    80002eae:	f022                	sd	s0,32(sp)
    80002eb0:	ec26                	sd	s1,24(sp)
    80002eb2:	e84a                	sd	s2,16(sp)
    80002eb4:	e44e                	sd	s3,8(sp)
    80002eb6:	e052                	sd	s4,0(sp)
    80002eb8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002eba:	00004597          	auipc	a1,0x4
    80002ebe:	50658593          	addi	a1,a1,1286 # 800073c0 <etext+0x3c0>
    80002ec2:	00016517          	auipc	a0,0x16
    80002ec6:	99650513          	addi	a0,a0,-1642 # 80018858 <bcache>
    80002eca:	cdffd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ece:	0001e797          	auipc	a5,0x1e
    80002ed2:	98a78793          	addi	a5,a5,-1654 # 80020858 <bcache+0x8000>
    80002ed6:	0001e717          	auipc	a4,0x1e
    80002eda:	bea70713          	addi	a4,a4,-1046 # 80020ac0 <bcache+0x8268>
    80002ede:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ee2:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002ee6:	00016497          	auipc	s1,0x16
    80002eea:	98a48493          	addi	s1,s1,-1654 # 80018870 <bcache+0x18>
    b->next = bcache.head.next;
    80002eee:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ef0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ef2:	00004a17          	auipc	s4,0x4
    80002ef6:	4d6a0a13          	addi	s4,s4,1238 # 800073c8 <etext+0x3c8>
    b->next = bcache.head.next;
    80002efa:	2b893783          	ld	a5,696(s2)
    80002efe:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f00:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f04:	85d2                	mv	a1,s4
    80002f06:	01048513          	addi	a0,s1,16
    80002f0a:	41c010ef          	jal	80004326 <initsleeplock>
    bcache.head.next->prev = b;
    80002f0e:	2b893783          	ld	a5,696(s2)
    80002f12:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f14:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002f18:	45848493          	addi	s1,s1,1112
    80002f1c:	fd349fe3          	bne	s1,s3,80002efa <binit+0x50>
  }
}
    80002f20:	70a2                	ld	ra,40(sp)
    80002f22:	7402                	ld	s0,32(sp)
    80002f24:	64e2                	ld	s1,24(sp)
    80002f26:	6942                	ld	s2,16(sp)
    80002f28:	69a2                	ld	s3,8(sp)
    80002f2a:	6a02                	ld	s4,0(sp)
    80002f2c:	6145                	addi	sp,sp,48
    80002f2e:	8082                	ret

0000000080002f30 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002f30:	7179                	addi	sp,sp,-48
    80002f32:	f406                	sd	ra,40(sp)
    80002f34:	f022                	sd	s0,32(sp)
    80002f36:	ec26                	sd	s1,24(sp)
    80002f38:	e84a                	sd	s2,16(sp)
    80002f3a:	e44e                	sd	s3,8(sp)
    80002f3c:	1800                	addi	s0,sp,48
    80002f3e:	892a                	mv	s2,a0
    80002f40:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f42:	00016517          	auipc	a0,0x16
    80002f46:	91650513          	addi	a0,a0,-1770 # 80018858 <bcache>
    80002f4a:	cdffd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002f4e:	0001e497          	auipc	s1,0x1e
    80002f52:	bc24b483          	ld	s1,-1086(s1) # 80020b10 <bcache+0x82b8>
    80002f56:	0001e797          	auipc	a5,0x1e
    80002f5a:	b6a78793          	addi	a5,a5,-1174 # 80020ac0 <bcache+0x8268>
    80002f5e:	02f48b63          	beq	s1,a5,80002f94 <bread+0x64>
    80002f62:	873e                	mv	a4,a5
    80002f64:	a021                	j	80002f6c <bread+0x3c>
    80002f66:	68a4                	ld	s1,80(s1)
    80002f68:	02e48663          	beq	s1,a4,80002f94 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002f6c:	449c                	lw	a5,8(s1)
    80002f6e:	ff279ce3          	bne	a5,s2,80002f66 <bread+0x36>
    80002f72:	44dc                	lw	a5,12(s1)
    80002f74:	ff3799e3          	bne	a5,s3,80002f66 <bread+0x36>
      b->refcnt++;
    80002f78:	40bc                	lw	a5,64(s1)
    80002f7a:	2785                	addiw	a5,a5,1
    80002f7c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f7e:	00016517          	auipc	a0,0x16
    80002f82:	8da50513          	addi	a0,a0,-1830 # 80018858 <bcache>
    80002f86:	d2bfd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002f8a:	01048513          	addi	a0,s1,16
    80002f8e:	3ce010ef          	jal	8000435c <acquiresleep>
      return b;
    80002f92:	a889                	j	80002fe4 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002f94:	0001e497          	auipc	s1,0x1e
    80002f98:	b744b483          	ld	s1,-1164(s1) # 80020b08 <bcache+0x82b0>
    80002f9c:	0001e797          	auipc	a5,0x1e
    80002fa0:	b2478793          	addi	a5,a5,-1244 # 80020ac0 <bcache+0x8268>
    80002fa4:	00f48863          	beq	s1,a5,80002fb4 <bread+0x84>
    80002fa8:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002faa:	40bc                	lw	a5,64(s1)
    80002fac:	cb91                	beqz	a5,80002fc0 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002fae:	64a4                	ld	s1,72(s1)
    80002fb0:	fee49de3          	bne	s1,a4,80002faa <bread+0x7a>
  panic("bget: no buffers");
    80002fb4:	00004517          	auipc	a0,0x4
    80002fb8:	41c50513          	addi	a0,a0,1052 # 800073d0 <etext+0x3d0>
    80002fbc:	879fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002fc0:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002fc4:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002fc8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fcc:	4785                	li	a5,1
    80002fce:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fd0:	00016517          	auipc	a0,0x16
    80002fd4:	88850513          	addi	a0,a0,-1912 # 80018858 <bcache>
    80002fd8:	cd9fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002fdc:	01048513          	addi	a0,s1,16
    80002fe0:	37c010ef          	jal	8000435c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002fe4:	409c                	lw	a5,0(s1)
    80002fe6:	cb89                	beqz	a5,80002ff8 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002fe8:	8526                	mv	a0,s1
    80002fea:	70a2                	ld	ra,40(sp)
    80002fec:	7402                	ld	s0,32(sp)
    80002fee:	64e2                	ld	s1,24(sp)
    80002ff0:	6942                	ld	s2,16(sp)
    80002ff2:	69a2                	ld	s3,8(sp)
    80002ff4:	6145                	addi	sp,sp,48
    80002ff6:	8082                	ret
    virtio_disk_rw(b, 0);
    80002ff8:	4581                	li	a1,0
    80002ffa:	8526                	mv	a0,s1
    80002ffc:	4bb020ef          	jal	80005cb6 <virtio_disk_rw>
    b->valid = 1;
    80003000:	4785                	li	a5,1
    80003002:	c09c                	sw	a5,0(s1)
  return b;
    80003004:	b7d5                	j	80002fe8 <bread+0xb8>

0000000080003006 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80003006:	1101                	addi	sp,sp,-32
    80003008:	ec06                	sd	ra,24(sp)
    8000300a:	e822                	sd	s0,16(sp)
    8000300c:	e426                	sd	s1,8(sp)
    8000300e:	1000                	addi	s0,sp,32
    80003010:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80003012:	0541                	addi	a0,a0,16
    80003014:	3d4010ef          	jal	800043e8 <holdingsleep>
    80003018:	c911                	beqz	a0,8000302c <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000301a:	4585                	li	a1,1
    8000301c:	8526                	mv	a0,s1
    8000301e:	499020ef          	jal	80005cb6 <virtio_disk_rw>
}
    80003022:	60e2                	ld	ra,24(sp)
    80003024:	6442                	ld	s0,16(sp)
    80003026:	64a2                	ld	s1,8(sp)
    80003028:	6105                	addi	sp,sp,32
    8000302a:	8082                	ret
    panic("bwrite");
    8000302c:	00004517          	auipc	a0,0x4
    80003030:	3bc50513          	addi	a0,a0,956 # 800073e8 <etext+0x3e8>
    80003034:	801fd0ef          	jal	80000834 <panic>

0000000080003038 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003038:	1101                	addi	sp,sp,-32
    8000303a:	ec06                	sd	ra,24(sp)
    8000303c:	e822                	sd	s0,16(sp)
    8000303e:	e426                	sd	s1,8(sp)
    80003040:	e04a                	sd	s2,0(sp)
    80003042:	1000                	addi	s0,sp,32
    80003044:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80003046:	01050913          	addi	s2,a0,16
    8000304a:	854a                	mv	a0,s2
    8000304c:	39c010ef          	jal	800043e8 <holdingsleep>
    80003050:	c125                	beqz	a0,800030b0 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80003052:	854a                	mv	a0,s2
    80003054:	35c010ef          	jal	800043b0 <releasesleep>

  acquire(&bcache.lock);
    80003058:	00016517          	auipc	a0,0x16
    8000305c:	80050513          	addi	a0,a0,-2048 # 80018858 <bcache>
    80003060:	bc9fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80003064:	40bc                	lw	a5,64(s1)
    80003066:	37fd                	addiw	a5,a5,-1
    80003068:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000306a:	e79d                	bnez	a5,80003098 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000306c:	68b8                	ld	a4,80(s1)
    8000306e:	64bc                	ld	a5,72(s1)
    80003070:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003072:	68b8                	ld	a4,80(s1)
    80003074:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003076:	0001d797          	auipc	a5,0x1d
    8000307a:	7e278793          	addi	a5,a5,2018 # 80020858 <bcache+0x8000>
    8000307e:	2b87b703          	ld	a4,696(a5)
    80003082:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003084:	0001e717          	auipc	a4,0x1e
    80003088:	a3c70713          	addi	a4,a4,-1476 # 80020ac0 <bcache+0x8268>
    8000308c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000308e:	2b87b703          	ld	a4,696(a5)
    80003092:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003094:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80003098:	00015517          	auipc	a0,0x15
    8000309c:	7c050513          	addi	a0,a0,1984 # 80018858 <bcache>
    800030a0:	c11fd0ef          	jal	80000cb0 <release>
}
    800030a4:	60e2                	ld	ra,24(sp)
    800030a6:	6442                	ld	s0,16(sp)
    800030a8:	64a2                	ld	s1,8(sp)
    800030aa:	6902                	ld	s2,0(sp)
    800030ac:	6105                	addi	sp,sp,32
    800030ae:	8082                	ret
    panic("brelse");
    800030b0:	00004517          	auipc	a0,0x4
    800030b4:	34050513          	addi	a0,a0,832 # 800073f0 <etext+0x3f0>
    800030b8:	f7cfd0ef          	jal	80000834 <panic>

00000000800030bc <bpin>:

void
bpin(struct buf *b)
{
    800030bc:	1101                	addi	sp,sp,-32
    800030be:	ec06                	sd	ra,24(sp)
    800030c0:	e822                	sd	s0,16(sp)
    800030c2:	e426                	sd	s1,8(sp)
    800030c4:	1000                	addi	s0,sp,32
    800030c6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030c8:	00015517          	auipc	a0,0x15
    800030cc:	79050513          	addi	a0,a0,1936 # 80018858 <bcache>
    800030d0:	b59fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    800030d4:	40bc                	lw	a5,64(s1)
    800030d6:	2785                	addiw	a5,a5,1
    800030d8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030da:	00015517          	auipc	a0,0x15
    800030de:	77e50513          	addi	a0,a0,1918 # 80018858 <bcache>
    800030e2:	bcffd0ef          	jal	80000cb0 <release>
}
    800030e6:	60e2                	ld	ra,24(sp)
    800030e8:	6442                	ld	s0,16(sp)
    800030ea:	64a2                	ld	s1,8(sp)
    800030ec:	6105                	addi	sp,sp,32
    800030ee:	8082                	ret

00000000800030f0 <bunpin>:

void
bunpin(struct buf *b)
{
    800030f0:	1101                	addi	sp,sp,-32
    800030f2:	ec06                	sd	ra,24(sp)
    800030f4:	e822                	sd	s0,16(sp)
    800030f6:	e426                	sd	s1,8(sp)
    800030f8:	1000                	addi	s0,sp,32
    800030fa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030fc:	00015517          	auipc	a0,0x15
    80003100:	75c50513          	addi	a0,a0,1884 # 80018858 <bcache>
    80003104:	b25fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80003108:	40bc                	lw	a5,64(s1)
    8000310a:	37fd                	addiw	a5,a5,-1
    8000310c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000310e:	00015517          	auipc	a0,0x15
    80003112:	74a50513          	addi	a0,a0,1866 # 80018858 <bcache>
    80003116:	b9bfd0ef          	jal	80000cb0 <release>
}
    8000311a:	60e2                	ld	ra,24(sp)
    8000311c:	6442                	ld	s0,16(sp)
    8000311e:	64a2                	ld	s1,8(sp)
    80003120:	6105                	addi	sp,sp,32
    80003122:	8082                	ret

0000000080003124 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003124:	1101                	addi	sp,sp,-32
    80003126:	ec06                	sd	ra,24(sp)
    80003128:	e822                	sd	s0,16(sp)
    8000312a:	e426                	sd	s1,8(sp)
    8000312c:	e04a                	sd	s2,0(sp)
    8000312e:	1000                	addi	s0,sp,32
    80003130:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003132:	00d5d79b          	srliw	a5,a1,0xd
    80003136:	0001e597          	auipc	a1,0x1e
    8000313a:	dfe5a583          	lw	a1,-514(a1) # 80020f34 <sb+0x1c>
    8000313e:	9dbd                	addw	a1,a1,a5
    80003140:	df1ff0ef          	jal	80002f30 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003144:	0074f713          	andi	a4,s1,7
    80003148:	4785                	li	a5,1
    8000314a:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    8000314e:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80003150:	90d9                	srli	s1,s1,0x36
    80003152:	00950733          	add	a4,a0,s1
    80003156:	05874703          	lbu	a4,88(a4)
    8000315a:	00e7f6b3          	and	a3,a5,a4
    8000315e:	c29d                	beqz	a3,80003184 <bfree+0x60>
    80003160:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80003162:	94aa                	add	s1,s1,a0
    80003164:	fff7c793          	not	a5,a5
    80003168:	8f7d                	and	a4,a4,a5
    8000316a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000316e:	080010ef          	jal	800041ee <log_write>
  brelse(bp);
    80003172:	854a                	mv	a0,s2
    80003174:	ec5ff0ef          	jal	80003038 <brelse>
}
    80003178:	60e2                	ld	ra,24(sp)
    8000317a:	6442                	ld	s0,16(sp)
    8000317c:	64a2                	ld	s1,8(sp)
    8000317e:	6902                	ld	s2,0(sp)
    80003180:	6105                	addi	sp,sp,32
    80003182:	8082                	ret
    panic("freeing free block");
    80003184:	00004517          	auipc	a0,0x4
    80003188:	27450513          	addi	a0,a0,628 # 800073f8 <etext+0x3f8>
    8000318c:	ea8fd0ef          	jal	80000834 <panic>

0000000080003190 <balloc>:
{
    80003190:	715d                	addi	sp,sp,-80
    80003192:	e486                	sd	ra,72(sp)
    80003194:	e0a2                	sd	s0,64(sp)
    80003196:	fc26                	sd	s1,56(sp)
    80003198:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    8000319a:	0001e797          	auipc	a5,0x1e
    8000319e:	d827a783          	lw	a5,-638(a5) # 80020f1c <sb+0x4>
    800031a2:	0e078263          	beqz	a5,80003286 <balloc+0xf6>
    800031a6:	f84a                	sd	s2,48(sp)
    800031a8:	f44e                	sd	s3,40(sp)
    800031aa:	f052                	sd	s4,32(sp)
    800031ac:	ec56                	sd	s5,24(sp)
    800031ae:	e85a                	sd	s6,16(sp)
    800031b0:	e45e                	sd	s7,8(sp)
    800031b2:	e062                	sd	s8,0(sp)
    800031b4:	8baa                	mv	s7,a0
    800031b6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031b8:	0001eb17          	auipc	s6,0x1e
    800031bc:	d60b0b13          	addi	s6,s6,-672 # 80020f18 <sb>
      m = 1 << (bi % 8);
    800031c0:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    800031c2:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    800031c4:	6c09                	lui	s8,0x2
    800031c6:	a09d                	j	8000322c <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    800031c8:	97ca                	add	a5,a5,s2
    800031ca:	8e55                	or	a2,a2,a3
    800031cc:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800031d0:	854a                	mv	a0,s2
    800031d2:	01c010ef          	jal	800041ee <log_write>
        brelse(bp);
    800031d6:	854a                	mv	a0,s2
    800031d8:	e61ff0ef          	jal	80003038 <brelse>
  bp = bread(dev, bno);
    800031dc:	85a6                	mv	a1,s1
    800031de:	855e                	mv	a0,s7
    800031e0:	d51ff0ef          	jal	80002f30 <bread>
    800031e4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031e6:	40000613          	li	a2,1024
    800031ea:	4581                	li	a1,0
    800031ec:	05850513          	addi	a0,a0,88
    800031f0:	af9fd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    800031f4:	854a                	mv	a0,s2
    800031f6:	7f9000ef          	jal	800041ee <log_write>
  brelse(bp);
    800031fa:	854a                	mv	a0,s2
    800031fc:	e3dff0ef          	jal	80003038 <brelse>
}
    80003200:	7942                	ld	s2,48(sp)
    80003202:	79a2                	ld	s3,40(sp)
    80003204:	7a02                	ld	s4,32(sp)
    80003206:	6ae2                	ld	s5,24(sp)
    80003208:	6b42                	ld	s6,16(sp)
    8000320a:	6ba2                	ld	s7,8(sp)
    8000320c:	6c02                	ld	s8,0(sp)
}
    8000320e:	8526                	mv	a0,s1
    80003210:	60a6                	ld	ra,72(sp)
    80003212:	6406                	ld	s0,64(sp)
    80003214:	74e2                	ld	s1,56(sp)
    80003216:	6161                	addi	sp,sp,80
    80003218:	8082                	ret
    brelse(bp);
    8000321a:	854a                	mv	a0,s2
    8000321c:	e1dff0ef          	jal	80003038 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80003220:	015c0abb          	addw	s5,s8,s5
    80003224:	004b2783          	lw	a5,4(s6)
    80003228:	04faf863          	bgeu	s5,a5,80003278 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    8000322c:	40dad59b          	sraiw	a1,s5,0xd
    80003230:	01cb2783          	lw	a5,28(s6)
    80003234:	9dbd                	addw	a1,a1,a5
    80003236:	855e                	mv	a0,s7
    80003238:	cf9ff0ef          	jal	80002f30 <bread>
    8000323c:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    8000323e:	004b2503          	lw	a0,4(s6)
    80003242:	84d6                	mv	s1,s5
    80003244:	4701                	li	a4,0
    80003246:	fca4fae3          	bgeu	s1,a0,8000321a <balloc+0x8a>
      m = 1 << (bi % 8);
    8000324a:	00777693          	andi	a3,a4,7
    8000324e:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80003252:	41f7579b          	sraiw	a5,a4,0x1f
    80003256:	01d7d79b          	srliw	a5,a5,0x1d
    8000325a:	9fb9                	addw	a5,a5,a4
    8000325c:	4037d79b          	sraiw	a5,a5,0x3
    80003260:	00f90633          	add	a2,s2,a5
    80003264:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003268:	00c6f5b3          	and	a1,a3,a2
    8000326c:	ddb1                	beqz	a1,800031c8 <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    8000326e:	2705                	addiw	a4,a4,1
    80003270:	2485                	addiw	s1,s1,1
    80003272:	fd471ae3          	bne	a4,s4,80003246 <balloc+0xb6>
    80003276:	b755                	j	8000321a <balloc+0x8a>
    80003278:	7942                	ld	s2,48(sp)
    8000327a:	79a2                	ld	s3,40(sp)
    8000327c:	7a02                	ld	s4,32(sp)
    8000327e:	6ae2                	ld	s5,24(sp)
    80003280:	6b42                	ld	s6,16(sp)
    80003282:	6ba2                	ld	s7,8(sp)
    80003284:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    80003286:	00004517          	auipc	a0,0x4
    8000328a:	18a50513          	addi	a0,a0,394 # 80007410 <etext+0x410>
    8000328e:	a7cfd0ef          	jal	8000050a <printk>
  return 0;
    80003292:	4481                	li	s1,0
    80003294:	bfad                	j	8000320e <balloc+0x7e>

0000000080003296 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003296:	7179                	addi	sp,sp,-48
    80003298:	f406                	sd	ra,40(sp)
    8000329a:	f022                	sd	s0,32(sp)
    8000329c:	ec26                	sd	s1,24(sp)
    8000329e:	e84a                	sd	s2,16(sp)
    800032a0:	e44e                	sd	s3,8(sp)
    800032a2:	1800                	addi	s0,sp,48
    800032a4:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    800032a6:	47ad                	li	a5,11
    800032a8:	02b7e363          	bltu	a5,a1,800032ce <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    800032ac:	02059793          	slli	a5,a1,0x20
    800032b0:	01e7d593          	srli	a1,a5,0x1e
    800032b4:	00b509b3          	add	s3,a0,a1
    800032b8:	0509a483          	lw	s1,80(s3)
    800032bc:	e0b5                	bnez	s1,80003320 <bmap+0x8a>
      addr = balloc(ip->dev);
    800032be:	4108                	lw	a0,0(a0)
    800032c0:	ed1ff0ef          	jal	80003190 <balloc>
    800032c4:	84aa                	mv	s1,a0
      if (addr == 0)
    800032c6:	cd29                	beqz	a0,80003320 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    800032c8:	04a9a823          	sw	a0,80(s3)
    800032cc:	a891                	j	80003320 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800032ce:	ff45879b          	addiw	a5,a1,-12
    800032d2:	873e                	mv	a4,a5
    800032d4:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    800032d6:	0ff00793          	li	a5,255
    800032da:	06e7e763          	bltu	a5,a4,80003348 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    800032de:	08052483          	lw	s1,128(a0)
    800032e2:	e891                	bnez	s1,800032f6 <bmap+0x60>
      addr = balloc(ip->dev);
    800032e4:	4108                	lw	a0,0(a0)
    800032e6:	eabff0ef          	jal	80003190 <balloc>
    800032ea:	84aa                	mv	s1,a0
      if (addr == 0)
    800032ec:	c915                	beqz	a0,80003320 <bmap+0x8a>
    800032ee:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800032f0:	08a92023          	sw	a0,128(s2)
    800032f4:	a011                	j	800032f8 <bmap+0x62>
    800032f6:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800032f8:	85a6                	mv	a1,s1
    800032fa:	00092503          	lw	a0,0(s2)
    800032fe:	c33ff0ef          	jal	80002f30 <bread>
    80003302:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80003304:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80003308:	02099713          	slli	a4,s3,0x20
    8000330c:	01e75593          	srli	a1,a4,0x1e
    80003310:	97ae                	add	a5,a5,a1
    80003312:	89be                	mv	s3,a5
    80003314:	4384                	lw	s1,0(a5)
    80003316:	cc89                	beqz	s1,80003330 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003318:	8552                	mv	a0,s4
    8000331a:	d1fff0ef          	jal	80003038 <brelse>
    return addr;
    8000331e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003320:	8526                	mv	a0,s1
    80003322:	70a2                	ld	ra,40(sp)
    80003324:	7402                	ld	s0,32(sp)
    80003326:	64e2                	ld	s1,24(sp)
    80003328:	6942                	ld	s2,16(sp)
    8000332a:	69a2                	ld	s3,8(sp)
    8000332c:	6145                	addi	sp,sp,48
    8000332e:	8082                	ret
      addr = balloc(ip->dev);
    80003330:	00092503          	lw	a0,0(s2)
    80003334:	e5dff0ef          	jal	80003190 <balloc>
    80003338:	84aa                	mv	s1,a0
      if (addr) {
    8000333a:	dd79                	beqz	a0,80003318 <bmap+0x82>
        a[bn] = addr;
    8000333c:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003340:	8552                	mv	a0,s4
    80003342:	6ad000ef          	jal	800041ee <log_write>
    80003346:	bfc9                	j	80003318 <bmap+0x82>
    80003348:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000334a:	00004517          	auipc	a0,0x4
    8000334e:	0de50513          	addi	a0,a0,222 # 80007428 <etext+0x428>
    80003352:	ce2fd0ef          	jal	80000834 <panic>

0000000080003356 <iget>:
{
    80003356:	7179                	addi	sp,sp,-48
    80003358:	f406                	sd	ra,40(sp)
    8000335a:	f022                	sd	s0,32(sp)
    8000335c:	ec26                	sd	s1,24(sp)
    8000335e:	e84a                	sd	s2,16(sp)
    80003360:	e44e                	sd	s3,8(sp)
    80003362:	e052                	sd	s4,0(sp)
    80003364:	1800                	addi	s0,sp,48
    80003366:	892a                	mv	s2,a0
    80003368:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000336a:	0001e517          	auipc	a0,0x1e
    8000336e:	bce50513          	addi	a0,a0,-1074 # 80020f38 <itable>
    80003372:	8b7fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    80003376:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003378:	0001e497          	auipc	s1,0x1e
    8000337c:	bd848493          	addi	s1,s1,-1064 # 80020f50 <itable+0x18>
    80003380:	0001f697          	auipc	a3,0x1f
    80003384:	66068693          	addi	a3,a3,1632 # 800229e0 <log>
    80003388:	a809                	j	8000339a <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    8000338a:	e781                	bnez	a5,80003392 <iget+0x3c>
    8000338c:	00099363          	bnez	s3,80003392 <iget+0x3c>
      empty = ip;
    80003390:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003392:	08848493          	addi	s1,s1,136
    80003396:	02d48563          	beq	s1,a3,800033c0 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    8000339a:	449c                	lw	a5,8(s1)
    8000339c:	fef057e3          	blez	a5,8000338a <iget+0x34>
    800033a0:	4098                	lw	a4,0(s1)
    800033a2:	ff2718e3          	bne	a4,s2,80003392 <iget+0x3c>
    800033a6:	40d8                	lw	a4,4(s1)
    800033a8:	ff4715e3          	bne	a4,s4,80003392 <iget+0x3c>
      ip->ref++;
    800033ac:	2785                	addiw	a5,a5,1
    800033ae:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800033b0:	0001e517          	auipc	a0,0x1e
    800033b4:	b8850513          	addi	a0,a0,-1144 # 80020f38 <itable>
    800033b8:	8f9fd0ef          	jal	80000cb0 <release>
      return ip;
    800033bc:	89a6                	mv	s3,s1
    800033be:	a015                	j	800033e2 <iget+0x8c>
  if (empty == 0)
    800033c0:	02098a63          	beqz	s3,800033f4 <iget+0x9e>
  ip->dev = dev;
    800033c4:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800033c8:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800033cc:	4785                	li	a5,1
    800033ce:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800033d2:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800033d6:	0001e517          	auipc	a0,0x1e
    800033da:	b6250513          	addi	a0,a0,-1182 # 80020f38 <itable>
    800033de:	8d3fd0ef          	jal	80000cb0 <release>
}
    800033e2:	854e                	mv	a0,s3
    800033e4:	70a2                	ld	ra,40(sp)
    800033e6:	7402                	ld	s0,32(sp)
    800033e8:	64e2                	ld	s1,24(sp)
    800033ea:	6942                	ld	s2,16(sp)
    800033ec:	69a2                	ld	s3,8(sp)
    800033ee:	6a02                	ld	s4,0(sp)
    800033f0:	6145                	addi	sp,sp,48
    800033f2:	8082                	ret
    panic("iget: no inodes");
    800033f4:	00004517          	auipc	a0,0x4
    800033f8:	04c50513          	addi	a0,a0,76 # 80007440 <etext+0x440>
    800033fc:	c38fd0ef          	jal	80000834 <panic>

0000000080003400 <iinit>:
{
    80003400:	7179                	addi	sp,sp,-48
    80003402:	f406                	sd	ra,40(sp)
    80003404:	f022                	sd	s0,32(sp)
    80003406:	ec26                	sd	s1,24(sp)
    80003408:	e84a                	sd	s2,16(sp)
    8000340a:	e44e                	sd	s3,8(sp)
    8000340c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000340e:	00004597          	auipc	a1,0x4
    80003412:	04258593          	addi	a1,a1,66 # 80007450 <etext+0x450>
    80003416:	0001e517          	auipc	a0,0x1e
    8000341a:	b2250513          	addi	a0,a0,-1246 # 80020f38 <itable>
    8000341e:	f8afd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    80003422:	0001e497          	auipc	s1,0x1e
    80003426:	b3e48493          	addi	s1,s1,-1218 # 80020f60 <itable+0x28>
    8000342a:	0001f997          	auipc	s3,0x1f
    8000342e:	5c698993          	addi	s3,s3,1478 # 800229f0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003432:	00004917          	auipc	s2,0x4
    80003436:	02690913          	addi	s2,s2,38 # 80007458 <etext+0x458>
    8000343a:	85ca                	mv	a1,s2
    8000343c:	8526                	mv	a0,s1
    8000343e:	6e9000ef          	jal	80004326 <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003442:	08848493          	addi	s1,s1,136
    80003446:	ff349ae3          	bne	s1,s3,8000343a <iinit+0x3a>
}
    8000344a:	70a2                	ld	ra,40(sp)
    8000344c:	7402                	ld	s0,32(sp)
    8000344e:	64e2                	ld	s1,24(sp)
    80003450:	6942                	ld	s2,16(sp)
    80003452:	69a2                	ld	s3,8(sp)
    80003454:	6145                	addi	sp,sp,48
    80003456:	8082                	ret

0000000080003458 <ialloc>:
{
    80003458:	7139                	addi	sp,sp,-64
    8000345a:	fc06                	sd	ra,56(sp)
    8000345c:	f822                	sd	s0,48(sp)
    8000345e:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003460:	0001e717          	auipc	a4,0x1e
    80003464:	ac472703          	lw	a4,-1340(a4) # 80020f24 <sb+0xc>
    80003468:	4785                	li	a5,1
    8000346a:	06e7f063          	bgeu	a5,a4,800034ca <ialloc+0x72>
    8000346e:	f426                	sd	s1,40(sp)
    80003470:	f04a                	sd	s2,32(sp)
    80003472:	ec4e                	sd	s3,24(sp)
    80003474:	e852                	sd	s4,16(sp)
    80003476:	e456                	sd	s5,8(sp)
    80003478:	e05a                	sd	s6,0(sp)
    8000347a:	8aaa                	mv	s5,a0
    8000347c:	8b2e                	mv	s6,a1
    8000347e:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003480:	0001ea17          	auipc	s4,0x1e
    80003484:	a98a0a13          	addi	s4,s4,-1384 # 80020f18 <sb>
    80003488:	00495593          	srli	a1,s2,0x4
    8000348c:	018a2783          	lw	a5,24(s4)
    80003490:	9dbd                	addw	a1,a1,a5
    80003492:	8556                	mv	a0,s5
    80003494:	a9dff0ef          	jal	80002f30 <bread>
    80003498:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    8000349a:	05850993          	addi	s3,a0,88
    8000349e:	00f97793          	andi	a5,s2,15
    800034a2:	079a                	slli	a5,a5,0x6
    800034a4:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    800034a6:	00099783          	lh	a5,0(s3)
    800034aa:	cb9d                	beqz	a5,800034e0 <ialloc+0x88>
    brelse(bp);
    800034ac:	b8dff0ef          	jal	80003038 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    800034b0:	0905                	addi	s2,s2,1
    800034b2:	00ca2703          	lw	a4,12(s4)
    800034b6:	0009079b          	sext.w	a5,s2
    800034ba:	fce7e7e3          	bltu	a5,a4,80003488 <ialloc+0x30>
    800034be:	74a2                	ld	s1,40(sp)
    800034c0:	7902                	ld	s2,32(sp)
    800034c2:	69e2                	ld	s3,24(sp)
    800034c4:	6a42                	ld	s4,16(sp)
    800034c6:	6aa2                	ld	s5,8(sp)
    800034c8:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800034ca:	00004517          	auipc	a0,0x4
    800034ce:	f9650513          	addi	a0,a0,-106 # 80007460 <etext+0x460>
    800034d2:	838fd0ef          	jal	8000050a <printk>
  return 0;
    800034d6:	4501                	li	a0,0
}
    800034d8:	70e2                	ld	ra,56(sp)
    800034da:	7442                	ld	s0,48(sp)
    800034dc:	6121                	addi	sp,sp,64
    800034de:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800034e0:	04000613          	li	a2,64
    800034e4:	4581                	li	a1,0
    800034e6:	854e                	mv	a0,s3
    800034e8:	801fd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    800034ec:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800034f0:	8526                	mv	a0,s1
    800034f2:	4fd000ef          	jal	800041ee <log_write>
      brelse(bp);
    800034f6:	8526                	mv	a0,s1
    800034f8:	b41ff0ef          	jal	80003038 <brelse>
      return iget(dev, inum);
    800034fc:	0009059b          	sext.w	a1,s2
    80003500:	8556                	mv	a0,s5
    80003502:	e55ff0ef          	jal	80003356 <iget>
    80003506:	74a2                	ld	s1,40(sp)
    80003508:	7902                	ld	s2,32(sp)
    8000350a:	69e2                	ld	s3,24(sp)
    8000350c:	6a42                	ld	s4,16(sp)
    8000350e:	6aa2                	ld	s5,8(sp)
    80003510:	6b02                	ld	s6,0(sp)
    80003512:	b7d9                	j	800034d8 <ialloc+0x80>

0000000080003514 <iupdate>:
{
    80003514:	1101                	addi	sp,sp,-32
    80003516:	ec06                	sd	ra,24(sp)
    80003518:	e822                	sd	s0,16(sp)
    8000351a:	e426                	sd	s1,8(sp)
    8000351c:	e04a                	sd	s2,0(sp)
    8000351e:	1000                	addi	s0,sp,32
    80003520:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003522:	415c                	lw	a5,4(a0)
    80003524:	0047d79b          	srliw	a5,a5,0x4
    80003528:	0001e597          	auipc	a1,0x1e
    8000352c:	a085a583          	lw	a1,-1528(a1) # 80020f30 <sb+0x18>
    80003530:	9dbd                	addw	a1,a1,a5
    80003532:	4108                	lw	a0,0(a0)
    80003534:	9fdff0ef          	jal	80002f30 <bread>
    80003538:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000353a:	05850793          	addi	a5,a0,88
    8000353e:	40d8                	lw	a4,4(s1)
    80003540:	8b3d                	andi	a4,a4,15
    80003542:	071a                	slli	a4,a4,0x6
    80003544:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003546:	04449703          	lh	a4,68(s1)
    8000354a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000354e:	04649703          	lh	a4,70(s1)
    80003552:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003556:	04849703          	lh	a4,72(s1)
    8000355a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000355e:	04a49703          	lh	a4,74(s1)
    80003562:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003566:	44f8                	lw	a4,76(s1)
    80003568:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000356a:	03400613          	li	a2,52
    8000356e:	05048593          	addi	a1,s1,80
    80003572:	00c78513          	addi	a0,a5,12
    80003576:	fd2fd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    8000357a:	854a                	mv	a0,s2
    8000357c:	473000ef          	jal	800041ee <log_write>
  brelse(bp);
    80003580:	854a                	mv	a0,s2
    80003582:	ab7ff0ef          	jal	80003038 <brelse>
}
    80003586:	60e2                	ld	ra,24(sp)
    80003588:	6442                	ld	s0,16(sp)
    8000358a:	64a2                	ld	s1,8(sp)
    8000358c:	6902                	ld	s2,0(sp)
    8000358e:	6105                	addi	sp,sp,32
    80003590:	8082                	ret

0000000080003592 <idup>:
{
    80003592:	1101                	addi	sp,sp,-32
    80003594:	ec06                	sd	ra,24(sp)
    80003596:	e822                	sd	s0,16(sp)
    80003598:	e426                	sd	s1,8(sp)
    8000359a:	1000                	addi	s0,sp,32
    8000359c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000359e:	0001e517          	auipc	a0,0x1e
    800035a2:	99a50513          	addi	a0,a0,-1638 # 80020f38 <itable>
    800035a6:	e82fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    800035aa:	449c                	lw	a5,8(s1)
    800035ac:	2785                	addiw	a5,a5,1
    800035ae:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035b0:	0001e517          	auipc	a0,0x1e
    800035b4:	98850513          	addi	a0,a0,-1656 # 80020f38 <itable>
    800035b8:	ef8fd0ef          	jal	80000cb0 <release>
}
    800035bc:	8526                	mv	a0,s1
    800035be:	60e2                	ld	ra,24(sp)
    800035c0:	6442                	ld	s0,16(sp)
    800035c2:	64a2                	ld	s1,8(sp)
    800035c4:	6105                	addi	sp,sp,32
    800035c6:	8082                	ret

00000000800035c8 <ilock>:
{
    800035c8:	1101                	addi	sp,sp,-32
    800035ca:	ec06                	sd	ra,24(sp)
    800035cc:	e822                	sd	s0,16(sp)
    800035ce:	e426                	sd	s1,8(sp)
    800035d0:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800035d2:	cd19                	beqz	a0,800035f0 <ilock+0x28>
    800035d4:	84aa                	mv	s1,a0
    800035d6:	451c                	lw	a5,8(a0)
    800035d8:	00f05c63          	blez	a5,800035f0 <ilock+0x28>
  acquiresleep(&ip->lock);
    800035dc:	0541                	addi	a0,a0,16
    800035de:	57f000ef          	jal	8000435c <acquiresleep>
  if (ip->valid == 0) {
    800035e2:	40bc                	lw	a5,64(s1)
    800035e4:	cf89                	beqz	a5,800035fe <ilock+0x36>
}
    800035e6:	60e2                	ld	ra,24(sp)
    800035e8:	6442                	ld	s0,16(sp)
    800035ea:	64a2                	ld	s1,8(sp)
    800035ec:	6105                	addi	sp,sp,32
    800035ee:	8082                	ret
    800035f0:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800035f2:	00004517          	auipc	a0,0x4
    800035f6:	e8650513          	addi	a0,a0,-378 # 80007478 <etext+0x478>
    800035fa:	a3afd0ef          	jal	80000834 <panic>
    800035fe:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003600:	40dc                	lw	a5,4(s1)
    80003602:	0047d79b          	srliw	a5,a5,0x4
    80003606:	0001e597          	auipc	a1,0x1e
    8000360a:	92a5a583          	lw	a1,-1750(a1) # 80020f30 <sb+0x18>
    8000360e:	9dbd                	addw	a1,a1,a5
    80003610:	4088                	lw	a0,0(s1)
    80003612:	91fff0ef          	jal	80002f30 <bread>
    80003616:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003618:	05850593          	addi	a1,a0,88
    8000361c:	40dc                	lw	a5,4(s1)
    8000361e:	8bbd                	andi	a5,a5,15
    80003620:	079a                	slli	a5,a5,0x6
    80003622:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003624:	00059783          	lh	a5,0(a1)
    80003628:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000362c:	00259783          	lh	a5,2(a1)
    80003630:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003634:	00459783          	lh	a5,4(a1)
    80003638:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000363c:	00659783          	lh	a5,6(a1)
    80003640:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003644:	459c                	lw	a5,8(a1)
    80003646:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003648:	03400613          	li	a2,52
    8000364c:	05b1                	addi	a1,a1,12
    8000364e:	05048513          	addi	a0,s1,80
    80003652:	ef6fd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    80003656:	854a                	mv	a0,s2
    80003658:	9e1ff0ef          	jal	80003038 <brelse>
    ip->valid = 1;
    8000365c:	4785                	li	a5,1
    8000365e:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003660:	04449783          	lh	a5,68(s1)
    80003664:	c399                	beqz	a5,8000366a <ilock+0xa2>
    80003666:	6902                	ld	s2,0(sp)
    80003668:	bfbd                	j	800035e6 <ilock+0x1e>
      panic("ilock: no type");
    8000366a:	00004517          	auipc	a0,0x4
    8000366e:	e1650513          	addi	a0,a0,-490 # 80007480 <etext+0x480>
    80003672:	9c2fd0ef          	jal	80000834 <panic>

0000000080003676 <iunlock>:
{
    80003676:	1101                	addi	sp,sp,-32
    80003678:	ec06                	sd	ra,24(sp)
    8000367a:	e822                	sd	s0,16(sp)
    8000367c:	e426                	sd	s1,8(sp)
    8000367e:	e04a                	sd	s2,0(sp)
    80003680:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003682:	c505                	beqz	a0,800036aa <iunlock+0x34>
    80003684:	84aa                	mv	s1,a0
    80003686:	01050913          	addi	s2,a0,16
    8000368a:	854a                	mv	a0,s2
    8000368c:	55d000ef          	jal	800043e8 <holdingsleep>
    80003690:	cd09                	beqz	a0,800036aa <iunlock+0x34>
    80003692:	449c                	lw	a5,8(s1)
    80003694:	00f05b63          	blez	a5,800036aa <iunlock+0x34>
  releasesleep(&ip->lock);
    80003698:	854a                	mv	a0,s2
    8000369a:	517000ef          	jal	800043b0 <releasesleep>
}
    8000369e:	60e2                	ld	ra,24(sp)
    800036a0:	6442                	ld	s0,16(sp)
    800036a2:	64a2                	ld	s1,8(sp)
    800036a4:	6902                	ld	s2,0(sp)
    800036a6:	6105                	addi	sp,sp,32
    800036a8:	8082                	ret
    panic("iunlock");
    800036aa:	00004517          	auipc	a0,0x4
    800036ae:	de650513          	addi	a0,a0,-538 # 80007490 <etext+0x490>
    800036b2:	982fd0ef          	jal	80000834 <panic>

00000000800036b6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800036b6:	7179                	addi	sp,sp,-48
    800036b8:	f406                	sd	ra,40(sp)
    800036ba:	f022                	sd	s0,32(sp)
    800036bc:	ec26                	sd	s1,24(sp)
    800036be:	e84a                	sd	s2,16(sp)
    800036c0:	e44e                	sd	s3,8(sp)
    800036c2:	1800                	addi	s0,sp,48
    800036c4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800036c6:	05050493          	addi	s1,a0,80
    800036ca:	08050913          	addi	s2,a0,128
    800036ce:	a021                	j	800036d6 <itrunc+0x20>
    800036d0:	0491                	addi	s1,s1,4
    800036d2:	01248b63          	beq	s1,s2,800036e8 <itrunc+0x32>
    if (ip->addrs[i]) {
    800036d6:	408c                	lw	a1,0(s1)
    800036d8:	dde5                	beqz	a1,800036d0 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800036da:	0009a503          	lw	a0,0(s3)
    800036de:	a47ff0ef          	jal	80003124 <bfree>
      ip->addrs[i] = 0;
    800036e2:	0004a023          	sw	zero,0(s1)
    800036e6:	b7ed                	j	800036d0 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800036e8:	0809a583          	lw	a1,128(s3)
    800036ec:	ed89                	bnez	a1,80003706 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800036ee:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800036f2:	854e                	mv	a0,s3
    800036f4:	e21ff0ef          	jal	80003514 <iupdate>
}
    800036f8:	70a2                	ld	ra,40(sp)
    800036fa:	7402                	ld	s0,32(sp)
    800036fc:	64e2                	ld	s1,24(sp)
    800036fe:	6942                	ld	s2,16(sp)
    80003700:	69a2                	ld	s3,8(sp)
    80003702:	6145                	addi	sp,sp,48
    80003704:	8082                	ret
    80003706:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003708:	0009a503          	lw	a0,0(s3)
    8000370c:	825ff0ef          	jal	80002f30 <bread>
    80003710:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    80003712:	05850493          	addi	s1,a0,88
    80003716:	45850913          	addi	s2,a0,1112
    8000371a:	a021                	j	80003722 <itrunc+0x6c>
    8000371c:	0491                	addi	s1,s1,4
    8000371e:	01248963          	beq	s1,s2,80003730 <itrunc+0x7a>
      if (a[j])
    80003722:	408c                	lw	a1,0(s1)
    80003724:	dde5                	beqz	a1,8000371c <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003726:	0009a503          	lw	a0,0(s3)
    8000372a:	9fbff0ef          	jal	80003124 <bfree>
    8000372e:	b7fd                	j	8000371c <itrunc+0x66>
    brelse(bp);
    80003730:	8552                	mv	a0,s4
    80003732:	907ff0ef          	jal	80003038 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003736:	0809a583          	lw	a1,128(s3)
    8000373a:	0009a503          	lw	a0,0(s3)
    8000373e:	9e7ff0ef          	jal	80003124 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003742:	0809a023          	sw	zero,128(s3)
    80003746:	6a02                	ld	s4,0(sp)
    80003748:	b75d                	j	800036ee <itrunc+0x38>

000000008000374a <iput>:
{
    8000374a:	7179                	addi	sp,sp,-48
    8000374c:	f406                	sd	ra,40(sp)
    8000374e:	f022                	sd	s0,32(sp)
    80003750:	ec26                	sd	s1,24(sp)
    80003752:	1800                	addi	s0,sp,48
    80003754:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003756:	0001d517          	auipc	a0,0x1d
    8000375a:	7e250513          	addi	a0,a0,2018 # 80020f38 <itable>
    8000375e:	ccafd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003762:	449c                	lw	a5,8(s1)
    80003764:	4705                	li	a4,1
    80003766:	00e78f63          	beq	a5,a4,80003784 <iput+0x3a>
  ip->ref--;
    8000376a:	37fd                	addiw	a5,a5,-1
    8000376c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000376e:	0001d517          	auipc	a0,0x1d
    80003772:	7ca50513          	addi	a0,a0,1994 # 80020f38 <itable>
    80003776:	d3afd0ef          	jal	80000cb0 <release>
}
    8000377a:	70a2                	ld	ra,40(sp)
    8000377c:	7402                	ld	s0,32(sp)
    8000377e:	64e2                	ld	s1,24(sp)
    80003780:	6145                	addi	sp,sp,48
    80003782:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003784:	40b8                	lw	a4,64(s1)
    80003786:	d375                	beqz	a4,8000376a <iput+0x20>
    80003788:	e84a                	sd	s2,16(sp)
    8000378a:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    8000378c:	0004aa03          	lw	s4,0(s1)
    80003790:	0044a903          	lw	s2,4(s1)
  if (last) {
    80003794:	04a49703          	lh	a4,74(s1)
    80003798:	ef3d                	bnez	a4,80003816 <iput+0xcc>
    8000379a:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    8000379c:	01048793          	addi	a5,s1,16
    800037a0:	89be                	mv	s3,a5
    800037a2:	853e                	mv	a0,a5
    800037a4:	3b9000ef          	jal	8000435c <acquiresleep>
    release(&itable.lock);
    800037a8:	0001d517          	auipc	a0,0x1d
    800037ac:	79050513          	addi	a0,a0,1936 # 80020f38 <itable>
    800037b0:	d00fd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    800037b4:	8526                	mv	a0,s1
    800037b6:	f01ff0ef          	jal	800036b6 <itrunc>
    ip->valid = 0;
    800037ba:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800037be:	854e                	mv	a0,s3
    800037c0:	3f1000ef          	jal	800043b0 <releasesleep>
    acquire(&itable.lock);
    800037c4:	0001d517          	auipc	a0,0x1d
    800037c8:	77450513          	addi	a0,a0,1908 # 80020f38 <itable>
    800037cc:	c5cfd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    800037d0:	449c                	lw	a5,8(s1)
    800037d2:	37fd                	addiw	a5,a5,-1
    800037d4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037d6:	0001d517          	auipc	a0,0x1d
    800037da:	76250513          	addi	a0,a0,1890 # 80020f38 <itable>
    800037de:	cd2fd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800037e2:	0049579b          	srliw	a5,s2,0x4
    800037e6:	0001d597          	auipc	a1,0x1d
    800037ea:	74a5a583          	lw	a1,1866(a1) # 80020f30 <sb+0x18>
    800037ee:	9dbd                	addw	a1,a1,a5
    800037f0:	8552                	mv	a0,s4
    800037f2:	f3eff0ef          	jal	80002f30 <bread>
    800037f6:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800037f8:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    800037fc:	079a                	slli	a5,a5,0x6
    800037fe:	97aa                	add	a5,a5,a0
    80003800:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    80003804:	1eb000ef          	jal	800041ee <log_write>
  brelse(bp);
    80003808:	8526                	mv	a0,s1
    8000380a:	82fff0ef          	jal	80003038 <brelse>
}
    8000380e:	6942                	ld	s2,16(sp)
    80003810:	69a2                	ld	s3,8(sp)
    80003812:	6a02                	ld	s4,0(sp)
    80003814:	b79d                	j	8000377a <iput+0x30>
    80003816:	6942                	ld	s2,16(sp)
    80003818:	6a02                	ld	s4,0(sp)
    8000381a:	bf81                	j	8000376a <iput+0x20>

000000008000381c <iunlockput>:
{
    8000381c:	1101                	addi	sp,sp,-32
    8000381e:	ec06                	sd	ra,24(sp)
    80003820:	e822                	sd	s0,16(sp)
    80003822:	e426                	sd	s1,8(sp)
    80003824:	1000                	addi	s0,sp,32
    80003826:	84aa                	mv	s1,a0
  iunlock(ip);
    80003828:	e4fff0ef          	jal	80003676 <iunlock>
  iput(ip);
    8000382c:	8526                	mv	a0,s1
    8000382e:	f1dff0ef          	jal	8000374a <iput>
}
    80003832:	60e2                	ld	ra,24(sp)
    80003834:	6442                	ld	s0,16(sp)
    80003836:	64a2                	ld	s1,8(sp)
    80003838:	6105                	addi	sp,sp,32
    8000383a:	8082                	ret

000000008000383c <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000383c:	0001d717          	auipc	a4,0x1d
    80003840:	6e872703          	lw	a4,1768(a4) # 80020f24 <sb+0xc>
    80003844:	4785                	li	a5,1
    80003846:	0ae7fe63          	bgeu	a5,a4,80003902 <ireclaim+0xc6>
{
    8000384a:	7139                	addi	sp,sp,-64
    8000384c:	fc06                	sd	ra,56(sp)
    8000384e:	f822                	sd	s0,48(sp)
    80003850:	f426                	sd	s1,40(sp)
    80003852:	f04a                	sd	s2,32(sp)
    80003854:	ec4e                	sd	s3,24(sp)
    80003856:	e852                	sd	s4,16(sp)
    80003858:	e456                	sd	s5,8(sp)
    8000385a:	e05a                	sd	s6,0(sp)
    8000385c:	0080                	addi	s0,sp,64
    8000385e:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003860:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003862:	0001da17          	auipc	s4,0x1d
    80003866:	6b6a0a13          	addi	s4,s4,1718 # 80020f18 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    8000386a:	00004b17          	auipc	s6,0x4
    8000386e:	c2eb0b13          	addi	s6,s6,-978 # 80007498 <etext+0x498>
    80003872:	a099                	j	800038b8 <ireclaim+0x7c>
    80003874:	85ce                	mv	a1,s3
    80003876:	855a                	mv	a0,s6
    80003878:	c93fc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    8000387c:	85ce                	mv	a1,s3
    8000387e:	8556                	mv	a0,s5
    80003880:	ad7ff0ef          	jal	80003356 <iget>
    80003884:	89aa                	mv	s3,a0
    brelse(bp);
    80003886:	854a                	mv	a0,s2
    80003888:	fb0ff0ef          	jal	80003038 <brelse>
    if (ip) {
    8000388c:	00098f63          	beqz	s3,800038aa <ireclaim+0x6e>
      begin_op();
    80003890:	7b0000ef          	jal	80004040 <begin_op>
      ilock(ip);
    80003894:	854e                	mv	a0,s3
    80003896:	d33ff0ef          	jal	800035c8 <ilock>
      iunlock(ip);
    8000389a:	854e                	mv	a0,s3
    8000389c:	ddbff0ef          	jal	80003676 <iunlock>
      iput(ip);
    800038a0:	854e                	mv	a0,s3
    800038a2:	ea9ff0ef          	jal	8000374a <iput>
      end_op();
    800038a6:	027000ef          	jal	800040cc <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800038aa:	0485                	addi	s1,s1,1
    800038ac:	00ca2703          	lw	a4,12(s4)
    800038b0:	0004879b          	sext.w	a5,s1
    800038b4:	02e7fd63          	bgeu	a5,a4,800038ee <ireclaim+0xb2>
    800038b8:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800038bc:	0044d593          	srli	a1,s1,0x4
    800038c0:	018a2783          	lw	a5,24(s4)
    800038c4:	9dbd                	addw	a1,a1,a5
    800038c6:	8556                	mv	a0,s5
    800038c8:	e68ff0ef          	jal	80002f30 <bread>
    800038cc:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800038ce:	05850793          	addi	a5,a0,88
    800038d2:	00f9f713          	andi	a4,s3,15
    800038d6:	071a                	slli	a4,a4,0x6
    800038d8:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    800038da:	00079703          	lh	a4,0(a5)
    800038de:	c701                	beqz	a4,800038e6 <ireclaim+0xaa>
    800038e0:	00679783          	lh	a5,6(a5)
    800038e4:	dbc1                	beqz	a5,80003874 <ireclaim+0x38>
    brelse(bp);
    800038e6:	854a                	mv	a0,s2
    800038e8:	f50ff0ef          	jal	80003038 <brelse>
    if (ip) {
    800038ec:	bf7d                	j	800038aa <ireclaim+0x6e>
}
    800038ee:	70e2                	ld	ra,56(sp)
    800038f0:	7442                	ld	s0,48(sp)
    800038f2:	74a2                	ld	s1,40(sp)
    800038f4:	7902                	ld	s2,32(sp)
    800038f6:	69e2                	ld	s3,24(sp)
    800038f8:	6a42                	ld	s4,16(sp)
    800038fa:	6aa2                	ld	s5,8(sp)
    800038fc:	6b02                	ld	s6,0(sp)
    800038fe:	6121                	addi	sp,sp,64
    80003900:	8082                	ret
    80003902:	8082                	ret

0000000080003904 <fsinit>:
{
    80003904:	1101                	addi	sp,sp,-32
    80003906:	ec06                	sd	ra,24(sp)
    80003908:	e822                	sd	s0,16(sp)
    8000390a:	e426                	sd	s1,8(sp)
    8000390c:	e04a                	sd	s2,0(sp)
    8000390e:	1000                	addi	s0,sp,32
    80003910:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003912:	4585                	li	a1,1
    80003914:	e1cff0ef          	jal	80002f30 <bread>
    80003918:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000391a:	02000613          	li	a2,32
    8000391e:	05850593          	addi	a1,a0,88
    80003922:	0001d517          	auipc	a0,0x1d
    80003926:	5f650513          	addi	a0,a0,1526 # 80020f18 <sb>
    8000392a:	c1efd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    8000392e:	8526                	mv	a0,s1
    80003930:	f08ff0ef          	jal	80003038 <brelse>
  if (sb.magic != FSMAGIC)
    80003934:	0001d717          	auipc	a4,0x1d
    80003938:	5e472703          	lw	a4,1508(a4) # 80020f18 <sb>
    8000393c:	102037b7          	lui	a5,0x10203
    80003940:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003944:	02f71263          	bne	a4,a5,80003968 <fsinit+0x64>
  initlog(dev, &sb);
    80003948:	0001d597          	auipc	a1,0x1d
    8000394c:	5d058593          	addi	a1,a1,1488 # 80020f18 <sb>
    80003950:	854a                	mv	a0,s2
    80003952:	66c000ef          	jal	80003fbe <initlog>
  ireclaim(dev);
    80003956:	854a                	mv	a0,s2
    80003958:	ee5ff0ef          	jal	8000383c <ireclaim>
}
    8000395c:	60e2                	ld	ra,24(sp)
    8000395e:	6442                	ld	s0,16(sp)
    80003960:	64a2                	ld	s1,8(sp)
    80003962:	6902                	ld	s2,0(sp)
    80003964:	6105                	addi	sp,sp,32
    80003966:	8082                	ret
    panic("invalid file system");
    80003968:	00004517          	auipc	a0,0x4
    8000396c:	b5050513          	addi	a0,a0,-1200 # 800074b8 <etext+0x4b8>
    80003970:	ec5fc0ef          	jal	80000834 <panic>

0000000080003974 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003974:	1141                	addi	sp,sp,-16
    80003976:	e406                	sd	ra,8(sp)
    80003978:	e022                	sd	s0,0(sp)
    8000397a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000397c:	411c                	lw	a5,0(a0)
    8000397e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003980:	415c                	lw	a5,4(a0)
    80003982:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003984:	04451783          	lh	a5,68(a0)
    80003988:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000398c:	04a51783          	lh	a5,74(a0)
    80003990:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003994:	04c56783          	lwu	a5,76(a0)
    80003998:	e99c                	sd	a5,16(a1)
}
    8000399a:	60a2                	ld	ra,8(sp)
    8000399c:	6402                	ld	s0,0(sp)
    8000399e:	0141                	addi	sp,sp,16
    800039a0:	8082                	ret

00000000800039a2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800039a2:	457c                	lw	a5,76(a0)
    800039a4:	0ed7e663          	bltu	a5,a3,80003a90 <readi+0xee>
{
    800039a8:	7159                	addi	sp,sp,-112
    800039aa:	f486                	sd	ra,104(sp)
    800039ac:	f0a2                	sd	s0,96(sp)
    800039ae:	eca6                	sd	s1,88(sp)
    800039b0:	e0d2                	sd	s4,64(sp)
    800039b2:	fc56                	sd	s5,56(sp)
    800039b4:	f85a                	sd	s6,48(sp)
    800039b6:	f45e                	sd	s7,40(sp)
    800039b8:	1880                	addi	s0,sp,112
    800039ba:	8b2a                	mv	s6,a0
    800039bc:	8bae                	mv	s7,a1
    800039be:	8a32                	mv	s4,a2
    800039c0:	84b6                	mv	s1,a3
    800039c2:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800039c4:	9f35                	addw	a4,a4,a3
    return 0;
    800039c6:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800039c8:	0ad76b63          	bltu	a4,a3,80003a7e <readi+0xdc>
    800039cc:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    800039ce:	00e7f463          	bgeu	a5,a4,800039d6 <readi+0x34>
    n = ip->size - off;
    800039d2:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800039d6:	080a8b63          	beqz	s5,80003a6c <readi+0xca>
    800039da:	e8ca                	sd	s2,80(sp)
    800039dc:	f062                	sd	s8,32(sp)
    800039de:	ec66                	sd	s9,24(sp)
    800039e0:	e86a                	sd	s10,16(sp)
    800039e2:	e46e                	sd	s11,8(sp)
    800039e4:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800039e6:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039ea:	5c7d                	li	s8,-1
    800039ec:	a80d                	j	80003a1e <readi+0x7c>
    800039ee:	020d1d93          	slli	s11,s10,0x20
    800039f2:	020ddd93          	srli	s11,s11,0x20
    800039f6:	05890613          	addi	a2,s2,88
    800039fa:	86ee                	mv	a3,s11
    800039fc:	963e                	add	a2,a2,a5
    800039fe:	85d2                	mv	a1,s4
    80003a00:	855e                	mv	a0,s7
    80003a02:	961fe0ef          	jal	80002362 <either_copyout>
    80003a06:	05850363          	beq	a0,s8,80003a4c <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a0a:	854a                	mv	a0,s2
    80003a0c:	e2cff0ef          	jal	80003038 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003a10:	013d09bb          	addw	s3,s10,s3
    80003a14:	009d04bb          	addw	s1,s10,s1
    80003a18:	9a6e                	add	s4,s4,s11
    80003a1a:	0559f363          	bgeu	s3,s5,80003a60 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    80003a1e:	00a4d59b          	srliw	a1,s1,0xa
    80003a22:	855a                	mv	a0,s6
    80003a24:	873ff0ef          	jal	80003296 <bmap>
    80003a28:	85aa                	mv	a1,a0
    if (addr == 0)
    80003a2a:	c139                	beqz	a0,80003a70 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003a2c:	000b2503          	lw	a0,0(s6)
    80003a30:	d00ff0ef          	jal	80002f30 <bread>
    80003a34:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003a36:	3ff4f793          	andi	a5,s1,1023
    80003a3a:	40fc873b          	subw	a4,s9,a5
    80003a3e:	413a86bb          	subw	a3,s5,s3
    80003a42:	8d3a                	mv	s10,a4
    80003a44:	fae6f5e3          	bgeu	a3,a4,800039ee <readi+0x4c>
    80003a48:	8d36                	mv	s10,a3
    80003a4a:	b755                	j	800039ee <readi+0x4c>
      brelse(bp);
    80003a4c:	854a                	mv	a0,s2
    80003a4e:	deaff0ef          	jal	80003038 <brelse>
      tot = -1;
    80003a52:	59fd                	li	s3,-1
      break;
    80003a54:	6946                	ld	s2,80(sp)
    80003a56:	7c02                	ld	s8,32(sp)
    80003a58:	6ce2                	ld	s9,24(sp)
    80003a5a:	6d42                	ld	s10,16(sp)
    80003a5c:	6da2                	ld	s11,8(sp)
    80003a5e:	a831                	j	80003a7a <readi+0xd8>
    80003a60:	6946                	ld	s2,80(sp)
    80003a62:	7c02                	ld	s8,32(sp)
    80003a64:	6ce2                	ld	s9,24(sp)
    80003a66:	6d42                	ld	s10,16(sp)
    80003a68:	6da2                	ld	s11,8(sp)
    80003a6a:	a801                	j	80003a7a <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003a6c:	89d6                	mv	s3,s5
    80003a6e:	a031                	j	80003a7a <readi+0xd8>
    80003a70:	6946                	ld	s2,80(sp)
    80003a72:	7c02                	ld	s8,32(sp)
    80003a74:	6ce2                	ld	s9,24(sp)
    80003a76:	6d42                	ld	s10,16(sp)
    80003a78:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003a7a:	854e                	mv	a0,s3
    80003a7c:	69a6                	ld	s3,72(sp)
}
    80003a7e:	70a6                	ld	ra,104(sp)
    80003a80:	7406                	ld	s0,96(sp)
    80003a82:	64e6                	ld	s1,88(sp)
    80003a84:	6a06                	ld	s4,64(sp)
    80003a86:	7ae2                	ld	s5,56(sp)
    80003a88:	7b42                	ld	s6,48(sp)
    80003a8a:	7ba2                	ld	s7,40(sp)
    80003a8c:	6165                	addi	sp,sp,112
    80003a8e:	8082                	ret
    return 0;
    80003a90:	4501                	li	a0,0
}
    80003a92:	8082                	ret

0000000080003a94 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003a94:	457c                	lw	a5,76(a0)
    80003a96:	0ed7ee63          	bltu	a5,a3,80003b92 <writei+0xfe>
{
    80003a9a:	7159                	addi	sp,sp,-112
    80003a9c:	f486                	sd	ra,104(sp)
    80003a9e:	f0a2                	sd	s0,96(sp)
    80003aa0:	e8ca                	sd	s2,80(sp)
    80003aa2:	e0d2                	sd	s4,64(sp)
    80003aa4:	fc56                	sd	s5,56(sp)
    80003aa6:	f85a                	sd	s6,48(sp)
    80003aa8:	f45e                	sd	s7,40(sp)
    80003aaa:	1880                	addi	s0,sp,112
    80003aac:	8aaa                	mv	s5,a0
    80003aae:	8bae                	mv	s7,a1
    80003ab0:	8a32                	mv	s4,a2
    80003ab2:	8936                	mv	s2,a3
    80003ab4:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003ab6:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003aba:	00043737          	lui	a4,0x43
    80003abe:	0cf76c63          	bltu	a4,a5,80003b96 <writei+0x102>
    80003ac2:	0cd7ea63          	bltu	a5,a3,80003b96 <writei+0x102>
    80003ac6:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003ac8:	0a0b0d63          	beqz	s6,80003b82 <writei+0xee>
    80003acc:	eca6                	sd	s1,88(sp)
    80003ace:	f062                	sd	s8,32(sp)
    80003ad0:	ec66                	sd	s9,24(sp)
    80003ad2:	e86a                	sd	s10,16(sp)
    80003ad4:	e46e                	sd	s11,8(sp)
    80003ad6:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003ad8:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003adc:	5c7d                	li	s8,-1
    80003ade:	a825                	j	80003b16 <writei+0x82>
    80003ae0:	020d1d93          	slli	s11,s10,0x20
    80003ae4:	020ddd93          	srli	s11,s11,0x20
    80003ae8:	05848513          	addi	a0,s1,88
    80003aec:	86ee                	mv	a3,s11
    80003aee:	8652                	mv	a2,s4
    80003af0:	85de                	mv	a1,s7
    80003af2:	953e                	add	a0,a0,a5
    80003af4:	8bbfe0ef          	jal	800023ae <either_copyin>
    80003af8:	05850663          	beq	a0,s8,80003b44 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003afc:	8526                	mv	a0,s1
    80003afe:	6f0000ef          	jal	800041ee <log_write>
    brelse(bp);
    80003b02:	8526                	mv	a0,s1
    80003b04:	d34ff0ef          	jal	80003038 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003b08:	013d09bb          	addw	s3,s10,s3
    80003b0c:	012d093b          	addw	s2,s10,s2
    80003b10:	9a6e                	add	s4,s4,s11
    80003b12:	0369ff63          	bgeu	s3,s6,80003b50 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    80003b16:	00a9559b          	srliw	a1,s2,0xa
    80003b1a:	8556                	mv	a0,s5
    80003b1c:	f7aff0ef          	jal	80003296 <bmap>
    80003b20:	85aa                	mv	a1,a0
    if (addr == 0)
    80003b22:	c51d                	beqz	a0,80003b50 <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003b24:	000aa503          	lw	a0,0(s5)
    80003b28:	c08ff0ef          	jal	80002f30 <bread>
    80003b2c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003b2e:	3ff97793          	andi	a5,s2,1023
    80003b32:	40fc873b          	subw	a4,s9,a5
    80003b36:	413b06bb          	subw	a3,s6,s3
    80003b3a:	8d3a                	mv	s10,a4
    80003b3c:	fae6f2e3          	bgeu	a3,a4,80003ae0 <writei+0x4c>
    80003b40:	8d36                	mv	s10,a3
    80003b42:	bf79                	j	80003ae0 <writei+0x4c>
      log_write(bp);
    80003b44:	8526                	mv	a0,s1
    80003b46:	6a8000ef          	jal	800041ee <log_write>
      brelse(bp);
    80003b4a:	8526                	mv	a0,s1
    80003b4c:	cecff0ef          	jal	80003038 <brelse>
  }

  if (off > ip->size)
    80003b50:	04caa783          	lw	a5,76(s5)
    80003b54:	0327f963          	bgeu	a5,s2,80003b86 <writei+0xf2>
    ip->size = off;
    80003b58:	052aa623          	sw	s2,76(s5)
    80003b5c:	64e6                	ld	s1,88(sp)
    80003b5e:	7c02                	ld	s8,32(sp)
    80003b60:	6ce2                	ld	s9,24(sp)
    80003b62:	6d42                	ld	s10,16(sp)
    80003b64:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b66:	8556                	mv	a0,s5
    80003b68:	9adff0ef          	jal	80003514 <iupdate>

  return tot;
    80003b6c:	854e                	mv	a0,s3
    80003b6e:	69a6                	ld	s3,72(sp)
}
    80003b70:	70a6                	ld	ra,104(sp)
    80003b72:	7406                	ld	s0,96(sp)
    80003b74:	6946                	ld	s2,80(sp)
    80003b76:	6a06                	ld	s4,64(sp)
    80003b78:	7ae2                	ld	s5,56(sp)
    80003b7a:	7b42                	ld	s6,48(sp)
    80003b7c:	7ba2                	ld	s7,40(sp)
    80003b7e:	6165                	addi	sp,sp,112
    80003b80:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003b82:	89da                	mv	s3,s6
    80003b84:	b7cd                	j	80003b66 <writei+0xd2>
    80003b86:	64e6                	ld	s1,88(sp)
    80003b88:	7c02                	ld	s8,32(sp)
    80003b8a:	6ce2                	ld	s9,24(sp)
    80003b8c:	6d42                	ld	s10,16(sp)
    80003b8e:	6da2                	ld	s11,8(sp)
    80003b90:	bfd9                	j	80003b66 <writei+0xd2>
    return -1;
    80003b92:	557d                	li	a0,-1
}
    80003b94:	8082                	ret
    return -1;
    80003b96:	557d                	li	a0,-1
    80003b98:	bfe1                	j	80003b70 <writei+0xdc>

0000000080003b9a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b9a:	1141                	addi	sp,sp,-16
    80003b9c:	e406                	sd	ra,8(sp)
    80003b9e:	e022                	sd	s0,0(sp)
    80003ba0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ba2:	4639                	li	a2,14
    80003ba4:	a18fd0ef          	jal	80000dbc <strncmp>
}
    80003ba8:	60a2                	ld	ra,8(sp)
    80003baa:	6402                	ld	s0,0(sp)
    80003bac:	0141                	addi	sp,sp,16
    80003bae:	8082                	ret

0000000080003bb0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003bb0:	711d                	addi	sp,sp,-96
    80003bb2:	ec86                	sd	ra,88(sp)
    80003bb4:	e8a2                	sd	s0,80(sp)
    80003bb6:	e4a6                	sd	s1,72(sp)
    80003bb8:	e0ca                	sd	s2,64(sp)
    80003bba:	fc4e                	sd	s3,56(sp)
    80003bbc:	f852                	sd	s4,48(sp)
    80003bbe:	f456                	sd	s5,40(sp)
    80003bc0:	f05a                	sd	s6,32(sp)
    80003bc2:	ec5e                	sd	s7,24(sp)
    80003bc4:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003bc6:	04451703          	lh	a4,68(a0)
    80003bca:	4785                	li	a5,1
    80003bcc:	00f71f63          	bne	a4,a5,80003bea <dirlookup+0x3a>
    80003bd0:	892a                	mv	s2,a0
    80003bd2:	8aae                	mv	s5,a1
    80003bd4:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003bd6:	457c                	lw	a5,76(a0)
    80003bd8:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bda:	fa040a13          	addi	s4,s0,-96
    80003bde:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003be0:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003be4:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003be6:	e39d                	bnez	a5,80003c0c <dirlookup+0x5c>
    80003be8:	a8b9                	j	80003c46 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003bea:	00004517          	auipc	a0,0x4
    80003bee:	8e650513          	addi	a0,a0,-1818 # 800074d0 <etext+0x4d0>
    80003bf2:	c43fc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    80003bf6:	00004517          	auipc	a0,0x4
    80003bfa:	8f250513          	addi	a0,a0,-1806 # 800074e8 <etext+0x4e8>
    80003bfe:	c37fc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003c02:	24c1                	addiw	s1,s1,16
    80003c04:	04c92783          	lw	a5,76(s2)
    80003c08:	02f4fe63          	bgeu	s1,a5,80003c44 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c0c:	874e                	mv	a4,s3
    80003c0e:	86a6                	mv	a3,s1
    80003c10:	8652                	mv	a2,s4
    80003c12:	4581                	li	a1,0
    80003c14:	854a                	mv	a0,s2
    80003c16:	d8dff0ef          	jal	800039a2 <readi>
    80003c1a:	fd351ee3          	bne	a0,s3,80003bf6 <dirlookup+0x46>
    if (de.inum == 0)
    80003c1e:	fa045783          	lhu	a5,-96(s0)
    80003c22:	d3e5                	beqz	a5,80003c02 <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003c24:	85da                	mv	a1,s6
    80003c26:	8556                	mv	a0,s5
    80003c28:	f73ff0ef          	jal	80003b9a <namecmp>
    80003c2c:	f979                	bnez	a0,80003c02 <dirlookup+0x52>
      if (poff)
    80003c2e:	000b8463          	beqz	s7,80003c36 <dirlookup+0x86>
        *poff = off;
    80003c32:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003c36:	fa045583          	lhu	a1,-96(s0)
    80003c3a:	00092503          	lw	a0,0(s2)
    80003c3e:	f18ff0ef          	jal	80003356 <iget>
    80003c42:	a011                	j	80003c46 <dirlookup+0x96>
  return 0;
    80003c44:	4501                	li	a0,0
}
    80003c46:	60e6                	ld	ra,88(sp)
    80003c48:	6446                	ld	s0,80(sp)
    80003c4a:	64a6                	ld	s1,72(sp)
    80003c4c:	6906                	ld	s2,64(sp)
    80003c4e:	79e2                	ld	s3,56(sp)
    80003c50:	7a42                	ld	s4,48(sp)
    80003c52:	7aa2                	ld	s5,40(sp)
    80003c54:	7b02                	ld	s6,32(sp)
    80003c56:	6be2                	ld	s7,24(sp)
    80003c58:	6125                	addi	sp,sp,96
    80003c5a:	8082                	ret

0000000080003c5c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003c5c:	711d                	addi	sp,sp,-96
    80003c5e:	ec86                	sd	ra,88(sp)
    80003c60:	e8a2                	sd	s0,80(sp)
    80003c62:	e4a6                	sd	s1,72(sp)
    80003c64:	e0ca                	sd	s2,64(sp)
    80003c66:	fc4e                	sd	s3,56(sp)
    80003c68:	f852                	sd	s4,48(sp)
    80003c6a:	f456                	sd	s5,40(sp)
    80003c6c:	f05a                	sd	s6,32(sp)
    80003c6e:	ec5e                	sd	s7,24(sp)
    80003c70:	e862                	sd	s8,16(sp)
    80003c72:	e466                	sd	s9,8(sp)
    80003c74:	e06a                	sd	s10,0(sp)
    80003c76:	1080                	addi	s0,sp,96
    80003c78:	84aa                	mv	s1,a0
    80003c7a:	8b2e                	mv	s6,a1
    80003c7c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003c7e:	00054703          	lbu	a4,0(a0)
    80003c82:	02f00793          	li	a5,47
    80003c86:	00f70f63          	beq	a4,a5,80003ca4 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c8a:	cc7fd0ef          	jal	80001950 <myproc>
    80003c8e:	15053503          	ld	a0,336(a0)
    80003c92:	901ff0ef          	jal	80003592 <idup>
    80003c96:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003c98:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003c9c:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003c9e:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003ca0:	4b85                	li	s7,1
    80003ca2:	a07d                	j	80003d50 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003ca4:	4585                	li	a1,1
    80003ca6:	852e                	mv	a0,a1
    80003ca8:	eaeff0ef          	jal	80003356 <iget>
    80003cac:	8a2a                	mv	s4,a0
    80003cae:	b7ed                	j	80003c98 <namex+0x3c>
      iunlockput(ip);
    80003cb0:	8552                	mv	a0,s4
    80003cb2:	b6bff0ef          	jal	8000381c <iunlockput>
      return 0;
    80003cb6:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cb8:	8552                	mv	a0,s4
    80003cba:	60e6                	ld	ra,88(sp)
    80003cbc:	6446                	ld	s0,80(sp)
    80003cbe:	64a6                	ld	s1,72(sp)
    80003cc0:	6906                	ld	s2,64(sp)
    80003cc2:	79e2                	ld	s3,56(sp)
    80003cc4:	7a42                	ld	s4,48(sp)
    80003cc6:	7aa2                	ld	s5,40(sp)
    80003cc8:	7b02                	ld	s6,32(sp)
    80003cca:	6be2                	ld	s7,24(sp)
    80003ccc:	6c42                	ld	s8,16(sp)
    80003cce:	6ca2                	ld	s9,8(sp)
    80003cd0:	6d02                	ld	s10,0(sp)
    80003cd2:	6125                	addi	sp,sp,96
    80003cd4:	8082                	ret
      iunlockput(ip);
    80003cd6:	8552                	mv	a0,s4
    80003cd8:	b45ff0ef          	jal	8000381c <iunlockput>
      return 0;
    80003cdc:	4a01                	li	s4,0
    80003cde:	bfe9                	j	80003cb8 <namex+0x5c>
      iunlock(ip);
    80003ce0:	8552                	mv	a0,s4
    80003ce2:	995ff0ef          	jal	80003676 <iunlock>
      return ip;
    80003ce6:	bfc9                	j	80003cb8 <namex+0x5c>
      iunlockput(ip);
    80003ce8:	8552                	mv	a0,s4
    80003cea:	b33ff0ef          	jal	8000381c <iunlockput>
      return 0;
    80003cee:	8a4a                	mv	s4,s2
    80003cf0:	b7e1                	j	80003cb8 <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003cf2:	8926                	mv	s2,s1
  len = path - s;
    80003cf4:	4d01                	li	s10,0
    80003cf6:	4601                	li	a2,0
    memmove(name, s, len);
    80003cf8:	2601                	sext.w	a2,a2
    80003cfa:	85a6                	mv	a1,s1
    80003cfc:	8556                	mv	a0,s5
    80003cfe:	84afd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003d02:	9d56                	add	s10,s10,s5
    80003d04:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb3e0>
  while (*path == '/')
    80003d08:	00094783          	lbu	a5,0(s2)
    80003d0c:	09379b63          	bne	a5,s3,80003da2 <namex+0x146>
    80003d10:	84ca                	mv	s1,s2
    path++;
    80003d12:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003d14:	0004c783          	lbu	a5,0(s1)
    80003d18:	ff378de3          	beq	a5,s3,80003d12 <namex+0xb6>
    ilock(ip);
    80003d1c:	8552                	mv	a0,s4
    80003d1e:	8abff0ef          	jal	800035c8 <ilock>
    if (ip->type != T_DIR) {
    80003d22:	044a1783          	lh	a5,68(s4)
    80003d26:	f97795e3          	bne	a5,s7,80003cb0 <namex+0x54>
    if (ip->nlink == 0) {
    80003d2a:	04aa1783          	lh	a5,74(s4)
    80003d2e:	d7c5                	beqz	a5,80003cd6 <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003d30:	000b0563          	beqz	s6,80003d3a <namex+0xde>
    80003d34:	0004c783          	lbu	a5,0(s1)
    80003d38:	d7c5                	beqz	a5,80003ce0 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003d3a:	4601                	li	a2,0
    80003d3c:	85d6                	mv	a1,s5
    80003d3e:	8552                	mv	a0,s4
    80003d40:	e71ff0ef          	jal	80003bb0 <dirlookup>
    80003d44:	892a                	mv	s2,a0
    80003d46:	d14d                	beqz	a0,80003ce8 <namex+0x8c>
    iunlockput(ip);
    80003d48:	8552                	mv	a0,s4
    80003d4a:	ad3ff0ef          	jal	8000381c <iunlockput>
    ip = next;
    80003d4e:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003d50:	0004c783          	lbu	a5,0(s1)
    80003d54:	01379763          	bne	a5,s3,80003d62 <namex+0x106>
    path++;
    80003d58:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003d5a:	0004c783          	lbu	a5,0(s1)
    80003d5e:	ff378de3          	beq	a5,s3,80003d58 <namex+0xfc>
  if (*path == 0)
    80003d62:	c7a1                	beqz	a5,80003daa <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003d64:	0004c783          	lbu	a5,0(s1)
    80003d68:	fd178713          	addi	a4,a5,-47
    80003d6c:	d359                	beqz	a4,80003cf2 <namex+0x96>
    80003d6e:	d3d1                	beqz	a5,80003cf2 <namex+0x96>
    80003d70:	8926                	mv	s2,s1
    path++;
    80003d72:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003d74:	00094783          	lbu	a5,0(s2)
    80003d78:	fd178713          	addi	a4,a5,-47
    80003d7c:	c311                	beqz	a4,80003d80 <namex+0x124>
    80003d7e:	fbf5                	bnez	a5,80003d72 <namex+0x116>
  len = path - s;
    80003d80:	40990633          	sub	a2,s2,s1
    80003d84:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003d88:	f7ac58e3          	bge	s8,s10,80003cf8 <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003d8c:	8666                	mv	a2,s9
    80003d8e:	85a6                	mv	a1,s1
    80003d90:	8556                	mv	a0,s5
    80003d92:	fb7fc0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003d96:	00094783          	lbu	a5,0(s2)
    80003d9a:	84ca                	mv	s1,s2
    80003d9c:	f7378be3          	beq	a5,s3,80003d12 <namex+0xb6>
    80003da0:	bfb5                	j	80003d1c <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003da2:	00090463          	beqz	s2,80003daa <namex+0x14e>
    80003da6:	84ca                	mv	s1,s2
    80003da8:	bf95                	j	80003d1c <namex+0xc0>
  if (nameiparent) {
    80003daa:	f00b07e3          	beqz	s6,80003cb8 <namex+0x5c>
    iput(ip);
    80003dae:	8552                	mv	a0,s4
    80003db0:	99bff0ef          	jal	8000374a <iput>
    return 0;
    80003db4:	4a01                	li	s4,0
    80003db6:	b709                	j	80003cb8 <namex+0x5c>

0000000080003db8 <dirlink>:
{
    80003db8:	715d                	addi	sp,sp,-80
    80003dba:	e486                	sd	ra,72(sp)
    80003dbc:	e0a2                	sd	s0,64(sp)
    80003dbe:	f84a                	sd	s2,48(sp)
    80003dc0:	ec56                	sd	s5,24(sp)
    80003dc2:	e85a                	sd	s6,16(sp)
    80003dc4:	0880                	addi	s0,sp,80
    80003dc6:	892a                	mv	s2,a0
    80003dc8:	8aae                	mv	s5,a1
    80003dca:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003dcc:	4601                	li	a2,0
    80003dce:	de3ff0ef          	jal	80003bb0 <dirlookup>
    80003dd2:	ed1d                	bnez	a0,80003e10 <dirlink+0x58>
    80003dd4:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003dd6:	04c92483          	lw	s1,76(s2)
    80003dda:	c4b9                	beqz	s1,80003e28 <dirlink+0x70>
    80003ddc:	f44e                	sd	s3,40(sp)
    80003dde:	f052                	sd	s4,32(sp)
    80003de0:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003de2:	fb040a13          	addi	s4,s0,-80
    80003de6:	49c1                	li	s3,16
    80003de8:	874e                	mv	a4,s3
    80003dea:	86a6                	mv	a3,s1
    80003dec:	8652                	mv	a2,s4
    80003dee:	4581                	li	a1,0
    80003df0:	854a                	mv	a0,s2
    80003df2:	bb1ff0ef          	jal	800039a2 <readi>
    80003df6:	03351163          	bne	a0,s3,80003e18 <dirlink+0x60>
    if (de.inum == 0)
    80003dfa:	fb045783          	lhu	a5,-80(s0)
    80003dfe:	c39d                	beqz	a5,80003e24 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003e00:	24c1                	addiw	s1,s1,16
    80003e02:	04c92783          	lw	a5,76(s2)
    80003e06:	fef4e1e3          	bltu	s1,a5,80003de8 <dirlink+0x30>
    80003e0a:	79a2                	ld	s3,40(sp)
    80003e0c:	7a02                	ld	s4,32(sp)
    80003e0e:	a829                	j	80003e28 <dirlink+0x70>
    iput(ip);
    80003e10:	93bff0ef          	jal	8000374a <iput>
    return -1;
    80003e14:	557d                	li	a0,-1
    80003e16:	a83d                	j	80003e54 <dirlink+0x9c>
      panic("dirlink read");
    80003e18:	00003517          	auipc	a0,0x3
    80003e1c:	6e050513          	addi	a0,a0,1760 # 800074f8 <etext+0x4f8>
    80003e20:	a15fc0ef          	jal	80000834 <panic>
    80003e24:	79a2                	ld	s3,40(sp)
    80003e26:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003e28:	4639                	li	a2,14
    80003e2a:	85d6                	mv	a1,s5
    80003e2c:	fb240513          	addi	a0,s0,-78
    80003e30:	fc7fc0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003e34:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e38:	4741                	li	a4,16
    80003e3a:	86a6                	mv	a3,s1
    80003e3c:	fb040613          	addi	a2,s0,-80
    80003e40:	4581                	li	a1,0
    80003e42:	854a                	mv	a0,s2
    80003e44:	c51ff0ef          	jal	80003a94 <writei>
    80003e48:	1541                	addi	a0,a0,-16
    80003e4a:	00a03533          	snez	a0,a0
    80003e4e:	40a0053b          	negw	a0,a0
    80003e52:	74e2                	ld	s1,56(sp)
}
    80003e54:	60a6                	ld	ra,72(sp)
    80003e56:	6406                	ld	s0,64(sp)
    80003e58:	7942                	ld	s2,48(sp)
    80003e5a:	6ae2                	ld	s5,24(sp)
    80003e5c:	6b42                	ld	s6,16(sp)
    80003e5e:	6161                	addi	sp,sp,80
    80003e60:	8082                	ret

0000000080003e62 <namei>:

struct inode *
namei(char *path)
{
    80003e62:	1101                	addi	sp,sp,-32
    80003e64:	ec06                	sd	ra,24(sp)
    80003e66:	e822                	sd	s0,16(sp)
    80003e68:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e6a:	fe040613          	addi	a2,s0,-32
    80003e6e:	4581                	li	a1,0
    80003e70:	dedff0ef          	jal	80003c5c <namex>
}
    80003e74:	60e2                	ld	ra,24(sp)
    80003e76:	6442                	ld	s0,16(sp)
    80003e78:	6105                	addi	sp,sp,32
    80003e7a:	8082                	ret

0000000080003e7c <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003e7c:	1141                	addi	sp,sp,-16
    80003e7e:	e406                	sd	ra,8(sp)
    80003e80:	e022                	sd	s0,0(sp)
    80003e82:	0800                	addi	s0,sp,16
    80003e84:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e86:	4585                	li	a1,1
    80003e88:	dd5ff0ef          	jal	80003c5c <namex>
}
    80003e8c:	60a2                	ld	ra,8(sp)
    80003e8e:	6402                	ld	s0,0(sp)
    80003e90:	0141                	addi	sp,sp,16
    80003e92:	8082                	ret

0000000080003e94 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e94:	1101                	addi	sp,sp,-32
    80003e96:	ec06                	sd	ra,24(sp)
    80003e98:	e822                	sd	s0,16(sp)
    80003e9a:	e426                	sd	s1,8(sp)
    80003e9c:	e04a                	sd	s2,0(sp)
    80003e9e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ea0:	0001f917          	auipc	s2,0x1f
    80003ea4:	b4090913          	addi	s2,s2,-1216 # 800229e0 <log>
    80003ea8:	01892583          	lw	a1,24(s2)
    80003eac:	02492503          	lw	a0,36(s2)
    80003eb0:	880ff0ef          	jal	80002f30 <bread>
    80003eb4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003eb6:	02c92603          	lw	a2,44(s2)
    80003eba:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003ebc:	00c05f63          	blez	a2,80003eda <write_head+0x46>
    80003ec0:	0001f717          	auipc	a4,0x1f
    80003ec4:	b5070713          	addi	a4,a4,-1200 # 80022a10 <log+0x30>
    80003ec8:	87aa                	mv	a5,a0
    80003eca:	060a                	slli	a2,a2,0x2
    80003ecc:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003ece:	4314                	lw	a3,0(a4)
    80003ed0:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003ed2:	0711                	addi	a4,a4,4
    80003ed4:	0791                	addi	a5,a5,4
    80003ed6:	fec79ce3          	bne	a5,a2,80003ece <write_head+0x3a>
  }
  bwrite(buf);
    80003eda:	8526                	mv	a0,s1
    80003edc:	92aff0ef          	jal	80003006 <bwrite>
  brelse(buf);
    80003ee0:	8526                	mv	a0,s1
    80003ee2:	956ff0ef          	jal	80003038 <brelse>
}
    80003ee6:	60e2                	ld	ra,24(sp)
    80003ee8:	6442                	ld	s0,16(sp)
    80003eea:	64a2                	ld	s1,8(sp)
    80003eec:	6902                	ld	s2,0(sp)
    80003eee:	6105                	addi	sp,sp,32
    80003ef0:	8082                	ret

0000000080003ef2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ef2:	0001f797          	auipc	a5,0x1f
    80003ef6:	b1a7a783          	lw	a5,-1254(a5) # 80022a0c <log+0x2c>
    80003efa:	0cf05163          	blez	a5,80003fbc <install_trans+0xca>
{
    80003efe:	715d                	addi	sp,sp,-80
    80003f00:	e486                	sd	ra,72(sp)
    80003f02:	e0a2                	sd	s0,64(sp)
    80003f04:	fc26                	sd	s1,56(sp)
    80003f06:	f84a                	sd	s2,48(sp)
    80003f08:	f44e                	sd	s3,40(sp)
    80003f0a:	f052                	sd	s4,32(sp)
    80003f0c:	ec56                	sd	s5,24(sp)
    80003f0e:	e85a                	sd	s6,16(sp)
    80003f10:	e45e                	sd	s7,8(sp)
    80003f12:	e062                	sd	s8,0(sp)
    80003f14:	0880                	addi	s0,sp,80
    80003f16:	8b2a                	mv	s6,a0
    80003f18:	0001fa97          	auipc	s5,0x1f
    80003f1c:	af8a8a93          	addi	s5,s5,-1288 # 80022a10 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f20:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003f22:	00003c17          	auipc	s8,0x3
    80003f26:	5e6c0c13          	addi	s8,s8,1510 # 80007508 <etext+0x508>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003f2a:	0001fa17          	auipc	s4,0x1f
    80003f2e:	ab6a0a13          	addi	s4,s4,-1354 # 800229e0 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003f32:	40000b93          	li	s7,1024
    80003f36:	a025                	j	80003f5e <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003f38:	000aa603          	lw	a2,0(s5)
    80003f3c:	85ce                	mv	a1,s3
    80003f3e:	8562                	mv	a0,s8
    80003f40:	dcafc0ef          	jal	8000050a <printk>
    80003f44:	a839                	j	80003f62 <install_trans+0x70>
    brelse(lbuf);
    80003f46:	854a                	mv	a0,s2
    80003f48:	8f0ff0ef          	jal	80003038 <brelse>
    brelse(dbuf);
    80003f4c:	8526                	mv	a0,s1
    80003f4e:	8eaff0ef          	jal	80003038 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f52:	2985                	addiw	s3,s3,1
    80003f54:	0a91                	addi	s5,s5,4
    80003f56:	02ca2783          	lw	a5,44(s4)
    80003f5a:	04f9d563          	bge	s3,a5,80003fa4 <install_trans+0xb2>
    if (recovering) {
    80003f5e:	fc0b1de3          	bnez	s6,80003f38 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003f62:	018a2583          	lw	a1,24(s4)
    80003f66:	013585bb          	addw	a1,a1,s3
    80003f6a:	2585                	addiw	a1,a1,1
    80003f6c:	024a2503          	lw	a0,36(s4)
    80003f70:	fc1fe0ef          	jal	80002f30 <bread>
    80003f74:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003f76:	000aa583          	lw	a1,0(s5)
    80003f7a:	024a2503          	lw	a0,36(s4)
    80003f7e:	fb3fe0ef          	jal	80002f30 <bread>
    80003f82:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003f84:	865e                	mv	a2,s7
    80003f86:	05890593          	addi	a1,s2,88
    80003f8a:	05850513          	addi	a0,a0,88
    80003f8e:	dbbfc0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003f92:	8526                	mv	a0,s1
    80003f94:	872ff0ef          	jal	80003006 <bwrite>
    if (recovering == 0)
    80003f98:	fa0b17e3          	bnez	s6,80003f46 <install_trans+0x54>
      bunpin(dbuf);
    80003f9c:	8526                	mv	a0,s1
    80003f9e:	952ff0ef          	jal	800030f0 <bunpin>
    80003fa2:	b755                	j	80003f46 <install_trans+0x54>
}
    80003fa4:	60a6                	ld	ra,72(sp)
    80003fa6:	6406                	ld	s0,64(sp)
    80003fa8:	74e2                	ld	s1,56(sp)
    80003faa:	7942                	ld	s2,48(sp)
    80003fac:	79a2                	ld	s3,40(sp)
    80003fae:	7a02                	ld	s4,32(sp)
    80003fb0:	6ae2                	ld	s5,24(sp)
    80003fb2:	6b42                	ld	s6,16(sp)
    80003fb4:	6ba2                	ld	s7,8(sp)
    80003fb6:	6c02                	ld	s8,0(sp)
    80003fb8:	6161                	addi	sp,sp,80
    80003fba:	8082                	ret
    80003fbc:	8082                	ret

0000000080003fbe <initlog>:
{
    80003fbe:	7179                	addi	sp,sp,-48
    80003fc0:	f406                	sd	ra,40(sp)
    80003fc2:	f022                	sd	s0,32(sp)
    80003fc4:	ec26                	sd	s1,24(sp)
    80003fc6:	e84a                	sd	s2,16(sp)
    80003fc8:	e44e                	sd	s3,8(sp)
    80003fca:	1800                	addi	s0,sp,48
    80003fcc:	84aa                	mv	s1,a0
    80003fce:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003fd0:	0001f917          	auipc	s2,0x1f
    80003fd4:	a1090913          	addi	s2,s2,-1520 # 800229e0 <log>
    80003fd8:	00003597          	auipc	a1,0x3
    80003fdc:	55058593          	addi	a1,a1,1360 # 80007528 <etext+0x528>
    80003fe0:	854a                	mv	a0,s2
    80003fe2:	bc7fc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003fe6:	0149a583          	lw	a1,20(s3)
    80003fea:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003fee:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003ff2:	8526                	mv	a0,s1
    80003ff4:	f3dfe0ef          	jal	80002f30 <bread>
  log.lh.n = lh->n;
    80003ff8:	4d30                	lw	a2,88(a0)
    80003ffa:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003ffe:	00c05f63          	blez	a2,8000401c <initlog+0x5e>
    80004002:	87aa                	mv	a5,a0
    80004004:	0001f717          	auipc	a4,0x1f
    80004008:	a0c70713          	addi	a4,a4,-1524 # 80022a10 <log+0x30>
    8000400c:	060a                	slli	a2,a2,0x2
    8000400e:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004010:	4ff4                	lw	a3,92(a5)
    80004012:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004014:	0791                	addi	a5,a5,4
    80004016:	0711                	addi	a4,a4,4
    80004018:	fec79ce3          	bne	a5,a2,80004010 <initlog+0x52>
  brelse(buf);
    8000401c:	81cff0ef          	jal	80003038 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004020:	4505                	li	a0,1
    80004022:	ed1ff0ef          	jal	80003ef2 <install_trans>
  log.lh.n = 0;
    80004026:	0001f797          	auipc	a5,0x1f
    8000402a:	9e07a323          	sw	zero,-1562(a5) # 80022a0c <log+0x2c>
  write_head(); // clear the log
    8000402e:	e67ff0ef          	jal	80003e94 <write_head>
}
    80004032:	70a2                	ld	ra,40(sp)
    80004034:	7402                	ld	s0,32(sp)
    80004036:	64e2                	ld	s1,24(sp)
    80004038:	6942                	ld	s2,16(sp)
    8000403a:	69a2                	ld	s3,8(sp)
    8000403c:	6145                	addi	sp,sp,48
    8000403e:	8082                	ret

0000000080004040 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004040:	1101                	addi	sp,sp,-32
    80004042:	ec06                	sd	ra,24(sp)
    80004044:	e822                	sd	s0,16(sp)
    80004046:	e426                	sd	s1,8(sp)
    80004048:	e04a                	sd	s2,0(sp)
    8000404a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000404c:	0001f517          	auipc	a0,0x1f
    80004050:	99450513          	addi	a0,a0,-1644 # 800229e0 <log>
    80004054:	bd5fc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80004058:	0001f497          	auipc	s1,0x1f
    8000405c:	98848493          	addi	s1,s1,-1656 # 800229e0 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80004060:	4979                	li	s2,30
    80004062:	a821                	j	8000407a <begin_op+0x3a>
      sleep_prepare(&log);
    80004064:	8526                	mv	a0,s1
    80004066:	f6bfd0ef          	jal	80001fd0 <sleep_prepare>
      release(&log.lock);
    8000406a:	8526                	mv	a0,s1
    8000406c:	c45fc0ef          	jal	80000cb0 <release>
      sleep();
    80004070:	f9dfd0ef          	jal	8000200c <sleep>
      acquire(&log.lock);
    80004074:	8526                	mv	a0,s1
    80004076:	bb3fc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    8000407a:	509c                	lw	a5,32(s1)
    8000407c:	f7e5                	bnez	a5,80004064 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    8000407e:	4cd8                	lw	a4,28(s1)
    80004080:	2705                	addiw	a4,a4,1
    80004082:	0027179b          	slliw	a5,a4,0x2
    80004086:	9fb9                	addw	a5,a5,a4
    80004088:	0017979b          	slliw	a5,a5,0x1
    8000408c:	54d4                	lw	a3,44(s1)
    8000408e:	9fb5                	addw	a5,a5,a3
    80004090:	00f95e63          	bge	s2,a5,800040ac <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80004094:	8526                	mv	a0,s1
    80004096:	f3bfd0ef          	jal	80001fd0 <sleep_prepare>
      release(&log.lock);
    8000409a:	8526                	mv	a0,s1
    8000409c:	c15fc0ef          	jal	80000cb0 <release>
      sleep();
    800040a0:	f6dfd0ef          	jal	8000200c <sleep>
      acquire(&log.lock);
    800040a4:	8526                	mv	a0,s1
    800040a6:	b83fc0ef          	jal	80000c28 <acquire>
    800040aa:	bfc1                	j	8000407a <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    800040ac:	0001f797          	auipc	a5,0x1f
    800040b0:	94e7a823          	sw	a4,-1712(a5) # 800229fc <log+0x1c>
      release(&log.lock);
    800040b4:	0001f517          	auipc	a0,0x1f
    800040b8:	92c50513          	addi	a0,a0,-1748 # 800229e0 <log>
    800040bc:	bf5fc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    800040c0:	60e2                	ld	ra,24(sp)
    800040c2:	6442                	ld	s0,16(sp)
    800040c4:	64a2                	ld	s1,8(sp)
    800040c6:	6902                	ld	s2,0(sp)
    800040c8:	6105                	addi	sp,sp,32
    800040ca:	8082                	ret

00000000800040cc <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800040cc:	7139                	addi	sp,sp,-64
    800040ce:	fc06                	sd	ra,56(sp)
    800040d0:	f822                	sd	s0,48(sp)
    800040d2:	f426                	sd	s1,40(sp)
    800040d4:	f04a                	sd	s2,32(sp)
    800040d6:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040d8:	0001f497          	auipc	s1,0x1f
    800040dc:	90848493          	addi	s1,s1,-1784 # 800229e0 <log>
    800040e0:	8526                	mv	a0,s1
    800040e2:	b47fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    800040e6:	4cdc                	lw	a5,28(s1)
    800040e8:	37fd                	addiw	a5,a5,-1
    800040ea:	893e                	mv	s2,a5
    800040ec:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    800040ee:	509c                	lw	a5,32(s1)
    800040f0:	e3b1                	bnez	a5,80004134 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    800040f2:	04091a63          	bnez	s2,80004146 <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    800040f6:	0001f497          	auipc	s1,0x1f
    800040fa:	8ea48493          	addi	s1,s1,-1814 # 800229e0 <log>
    800040fe:	4785                	li	a5,1
    80004100:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004102:	8526                	mv	a0,s1
    80004104:	badfc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004108:	54dc                	lw	a5,44(s1)
    8000410a:	06f04063          	bgtz	a5,8000416a <end_op+0x9e>
    acquire(&log.lock);
    8000410e:	0001f497          	auipc	s1,0x1f
    80004112:	8d248493          	addi	s1,s1,-1838 # 800229e0 <log>
    80004116:	8526                	mv	a0,s1
    80004118:	b11fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    8000411c:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80004120:	549c                	lw	a5,40(s1)
    80004122:	2785                	addiw	a5,a5,1
    80004124:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80004126:	8526                	mv	a0,s1
    80004128:	f15fd0ef          	jal	8000203c <wakeup>
    release(&log.lock);
    8000412c:	8526                	mv	a0,s1
    8000412e:	b83fc0ef          	jal	80000cb0 <release>
}
    80004132:	a035                	j	8000415e <end_op+0x92>
    80004134:	ec4e                	sd	s3,24(sp)
    80004136:	e852                	sd	s4,16(sp)
    80004138:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000413a:	00003517          	auipc	a0,0x3
    8000413e:	3f650513          	addi	a0,a0,1014 # 80007530 <etext+0x530>
    80004142:	ef2fc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80004146:	0001f517          	auipc	a0,0x1f
    8000414a:	89a50513          	addi	a0,a0,-1894 # 800229e0 <log>
    8000414e:	eeffd0ef          	jal	8000203c <wakeup>
  release(&log.lock);
    80004152:	0001f517          	auipc	a0,0x1f
    80004156:	88e50513          	addi	a0,a0,-1906 # 800229e0 <log>
    8000415a:	b57fc0ef          	jal	80000cb0 <release>
}
    8000415e:	70e2                	ld	ra,56(sp)
    80004160:	7442                	ld	s0,48(sp)
    80004162:	74a2                	ld	s1,40(sp)
    80004164:	7902                	ld	s2,32(sp)
    80004166:	6121                	addi	sp,sp,64
    80004168:	8082                	ret
    8000416a:	ec4e                	sd	s3,24(sp)
    8000416c:	e852                	sd	s4,16(sp)
    8000416e:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004170:	0001fa97          	auipc	s5,0x1f
    80004174:	8a0a8a93          	addi	s5,s5,-1888 # 80022a10 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80004178:	0001fa17          	auipc	s4,0x1f
    8000417c:	868a0a13          	addi	s4,s4,-1944 # 800229e0 <log>
    80004180:	018a2583          	lw	a1,24(s4)
    80004184:	012585bb          	addw	a1,a1,s2
    80004188:	2585                	addiw	a1,a1,1
    8000418a:	024a2503          	lw	a0,36(s4)
    8000418e:	da3fe0ef          	jal	80002f30 <bread>
    80004192:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004194:	000aa583          	lw	a1,0(s5)
    80004198:	024a2503          	lw	a0,36(s4)
    8000419c:	d95fe0ef          	jal	80002f30 <bread>
    800041a0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800041a2:	40000613          	li	a2,1024
    800041a6:	05850593          	addi	a1,a0,88
    800041aa:	05848513          	addi	a0,s1,88
    800041ae:	b9bfc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    800041b2:	8526                	mv	a0,s1
    800041b4:	e53fe0ef          	jal	80003006 <bwrite>
    brelse(from);
    800041b8:	854e                	mv	a0,s3
    800041ba:	e7ffe0ef          	jal	80003038 <brelse>
    brelse(to);
    800041be:	8526                	mv	a0,s1
    800041c0:	e79fe0ef          	jal	80003038 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041c4:	2905                	addiw	s2,s2,1
    800041c6:	0a91                	addi	s5,s5,4
    800041c8:	02ca2783          	lw	a5,44(s4)
    800041cc:	faf94ae3          	blt	s2,a5,80004180 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    800041d0:	cc5ff0ef          	jal	80003e94 <write_head>
    install_trans(0); // Now install writes to home locations
    800041d4:	4501                	li	a0,0
    800041d6:	d1dff0ef          	jal	80003ef2 <install_trans>
    log.lh.n = 0;
    800041da:	0001f797          	auipc	a5,0x1f
    800041de:	8207a923          	sw	zero,-1998(a5) # 80022a0c <log+0x2c>
    write_head(); // Erase the transaction from the log
    800041e2:	cb3ff0ef          	jal	80003e94 <write_head>
    800041e6:	69e2                	ld	s3,24(sp)
    800041e8:	6a42                	ld	s4,16(sp)
    800041ea:	6aa2                	ld	s5,8(sp)
    800041ec:	b70d                	j	8000410e <end_op+0x42>

00000000800041ee <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800041ee:	1101                	addi	sp,sp,-32
    800041f0:	ec06                	sd	ra,24(sp)
    800041f2:	e822                	sd	s0,16(sp)
    800041f4:	e426                	sd	s1,8(sp)
    800041f6:	1000                	addi	s0,sp,32
    800041f8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800041fa:	0001e517          	auipc	a0,0x1e
    800041fe:	7e650513          	addi	a0,a0,2022 # 800229e0 <log>
    80004202:	a27fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004206:	0001f617          	auipc	a2,0x1f
    8000420a:	80662603          	lw	a2,-2042(a2) # 80022a0c <log+0x2c>
    8000420e:	47f5                	li	a5,29
    80004210:	04c7cd63          	blt	a5,a2,8000426a <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004214:	0001e797          	auipc	a5,0x1e
    80004218:	7e87a783          	lw	a5,2024(a5) # 800229fc <log+0x1c>
    8000421c:	04f05d63          	blez	a5,80004276 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004220:	4781                	li	a5,0
    80004222:	06c05063          	blez	a2,80004282 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80004226:	44cc                	lw	a1,12(s1)
    80004228:	0001e717          	auipc	a4,0x1e
    8000422c:	7e870713          	addi	a4,a4,2024 # 80022a10 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004230:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80004232:	4314                	lw	a3,0(a4)
    80004234:	04b68763          	beq	a3,a1,80004282 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80004238:	2785                	addiw	a5,a5,1
    8000423a:	0711                	addi	a4,a4,4
    8000423c:	fef61be3          	bne	a2,a5,80004232 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004240:	060a                	slli	a2,a2,0x2
    80004242:	02060613          	addi	a2,a2,32
    80004246:	0001e797          	auipc	a5,0x1e
    8000424a:	79a78793          	addi	a5,a5,1946 # 800229e0 <log>
    8000424e:	97b2                	add	a5,a5,a2
    80004250:	44d8                	lw	a4,12(s1)
    80004252:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80004254:	8526                	mv	a0,s1
    80004256:	e67fe0ef          	jal	800030bc <bpin>
    log.lh.n++;
    8000425a:	0001e717          	auipc	a4,0x1e
    8000425e:	78670713          	addi	a4,a4,1926 # 800229e0 <log>
    80004262:	575c                	lw	a5,44(a4)
    80004264:	2785                	addiw	a5,a5,1
    80004266:	d75c                	sw	a5,44(a4)
    80004268:	a815                	j	8000429c <log_write+0xae>
    panic("too big a transaction");
    8000426a:	00003517          	auipc	a0,0x3
    8000426e:	2d650513          	addi	a0,a0,726 # 80007540 <etext+0x540>
    80004272:	dc2fc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    80004276:	00003517          	auipc	a0,0x3
    8000427a:	2e250513          	addi	a0,a0,738 # 80007558 <etext+0x558>
    8000427e:	db6fc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    80004282:	00279693          	slli	a3,a5,0x2
    80004286:	02068693          	addi	a3,a3,32
    8000428a:	0001e717          	auipc	a4,0x1e
    8000428e:	75670713          	addi	a4,a4,1878 # 800229e0 <log>
    80004292:	9736                	add	a4,a4,a3
    80004294:	44d4                	lw	a3,12(s1)
    80004296:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80004298:	faf60ee3          	beq	a2,a5,80004254 <log_write+0x66>
  }
  release(&log.lock);
    8000429c:	0001e517          	auipc	a0,0x1e
    800042a0:	74450513          	addi	a0,a0,1860 # 800229e0 <log>
    800042a4:	a0dfc0ef          	jal	80000cb0 <release>
}
    800042a8:	60e2                	ld	ra,24(sp)
    800042aa:	6442                	ld	s0,16(sp)
    800042ac:	64a2                	ld	s1,8(sp)
    800042ae:	6105                	addi	sp,sp,32
    800042b0:	8082                	ret

00000000800042b2 <sys_sync>:

uint64
sys_sync(void)
{
    800042b2:	1101                	addi	sp,sp,-32
    800042b4:	ec06                	sd	ra,24(sp)
    800042b6:	e822                	sd	s0,16(sp)
    800042b8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042ba:	0001e517          	auipc	a0,0x1e
    800042be:	72650513          	addi	a0,a0,1830 # 800229e0 <log>
    800042c2:	967fc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    800042c6:	0001e797          	auipc	a5,0x1e
    800042ca:	73a7a783          	lw	a5,1850(a5) # 80022a00 <log+0x20>
    800042ce:	e799                	bnez	a5,800042dc <sys_sync+0x2a>
    800042d0:	0001e797          	auipc	a5,0x1e
    800042d4:	72c7a783          	lw	a5,1836(a5) # 800229fc <log+0x1c>
    800042d8:	02f05c63          	blez	a5,80004310 <sys_sync+0x5e>
    800042dc:	e426                	sd	s1,8(sp)
    800042de:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    800042e0:	0001e917          	auipc	s2,0x1e
    800042e4:	72892903          	lw	s2,1832(s2) # 80022a08 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    800042e8:	0001e497          	auipc	s1,0x1e
    800042ec:	6f848493          	addi	s1,s1,1784 # 800229e0 <log>
    800042f0:	8526                	mv	a0,s1
    800042f2:	cdffd0ef          	jal	80001fd0 <sleep_prepare>
      release(&log.lock);
    800042f6:	8526                	mv	a0,s1
    800042f8:	9b9fc0ef          	jal	80000cb0 <release>
      sleep();
    800042fc:	d11fd0ef          	jal	8000200c <sleep>
      acquire(&log.lock);
    80004300:	8526                	mv	a0,s1
    80004302:	927fc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    80004306:	549c                	lw	a5,40(s1)
    80004308:	fef954e3          	bge	s2,a5,800042f0 <sys_sync+0x3e>
    8000430c:	64a2                	ld	s1,8(sp)
    8000430e:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80004310:	0001e517          	auipc	a0,0x1e
    80004314:	6d050513          	addi	a0,a0,1744 # 800229e0 <log>
    80004318:	999fc0ef          	jal	80000cb0 <release>
  return 0;
}
    8000431c:	4501                	li	a0,0
    8000431e:	60e2                	ld	ra,24(sp)
    80004320:	6442                	ld	s0,16(sp)
    80004322:	6105                	addi	sp,sp,32
    80004324:	8082                	ret

0000000080004326 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004326:	1101                	addi	sp,sp,-32
    80004328:	ec06                	sd	ra,24(sp)
    8000432a:	e822                	sd	s0,16(sp)
    8000432c:	e426                	sd	s1,8(sp)
    8000432e:	e04a                	sd	s2,0(sp)
    80004330:	1000                	addi	s0,sp,32
    80004332:	84aa                	mv	s1,a0
    80004334:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004336:	00003597          	auipc	a1,0x3
    8000433a:	24258593          	addi	a1,a1,578 # 80007578 <etext+0x578>
    8000433e:	0521                	addi	a0,a0,8
    80004340:	869fc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    80004344:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004348:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000434c:	0204a423          	sw	zero,40(s1)
}
    80004350:	60e2                	ld	ra,24(sp)
    80004352:	6442                	ld	s0,16(sp)
    80004354:	64a2                	ld	s1,8(sp)
    80004356:	6902                	ld	s2,0(sp)
    80004358:	6105                	addi	sp,sp,32
    8000435a:	8082                	ret

000000008000435c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000435c:	1101                	addi	sp,sp,-32
    8000435e:	ec06                	sd	ra,24(sp)
    80004360:	e822                	sd	s0,16(sp)
    80004362:	e426                	sd	s1,8(sp)
    80004364:	e04a                	sd	s2,0(sp)
    80004366:	1000                	addi	s0,sp,32
    80004368:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000436a:	00850913          	addi	s2,a0,8
    8000436e:	854a                	mv	a0,s2
    80004370:	8b9fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004374:	409c                	lw	a5,0(s1)
    80004376:	cf91                	beqz	a5,80004392 <acquiresleep+0x36>
    sleep_prepare(lk);
    80004378:	8526                	mv	a0,s1
    8000437a:	c57fd0ef          	jal	80001fd0 <sleep_prepare>
    release(&lk->lk);
    8000437e:	854a                	mv	a0,s2
    80004380:	931fc0ef          	jal	80000cb0 <release>
    sleep();
    80004384:	c89fd0ef          	jal	8000200c <sleep>
    acquire(&lk->lk);
    80004388:	854a                	mv	a0,s2
    8000438a:	89ffc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    8000438e:	409c                	lw	a5,0(s1)
    80004390:	f7e5                	bnez	a5,80004378 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004392:	4785                	li	a5,1
    80004394:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004396:	dbafd0ef          	jal	80001950 <myproc>
    8000439a:	591c                	lw	a5,48(a0)
    8000439c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000439e:	854a                	mv	a0,s2
    800043a0:	911fc0ef          	jal	80000cb0 <release>
}
    800043a4:	60e2                	ld	ra,24(sp)
    800043a6:	6442                	ld	s0,16(sp)
    800043a8:	64a2                	ld	s1,8(sp)
    800043aa:	6902                	ld	s2,0(sp)
    800043ac:	6105                	addi	sp,sp,32
    800043ae:	8082                	ret

00000000800043b0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800043b0:	1101                	addi	sp,sp,-32
    800043b2:	ec06                	sd	ra,24(sp)
    800043b4:	e822                	sd	s0,16(sp)
    800043b6:	e426                	sd	s1,8(sp)
    800043b8:	e04a                	sd	s2,0(sp)
    800043ba:	1000                	addi	s0,sp,32
    800043bc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043be:	00850913          	addi	s2,a0,8
    800043c2:	854a                	mv	a0,s2
    800043c4:	865fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    800043c8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043cc:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800043d0:	8526                	mv	a0,s1
    800043d2:	c6bfd0ef          	jal	8000203c <wakeup>
  release(&lk->lk);
    800043d6:	854a                	mv	a0,s2
    800043d8:	8d9fc0ef          	jal	80000cb0 <release>
}
    800043dc:	60e2                	ld	ra,24(sp)
    800043de:	6442                	ld	s0,16(sp)
    800043e0:	64a2                	ld	s1,8(sp)
    800043e2:	6902                	ld	s2,0(sp)
    800043e4:	6105                	addi	sp,sp,32
    800043e6:	8082                	ret

00000000800043e8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800043e8:	7179                	addi	sp,sp,-48
    800043ea:	f406                	sd	ra,40(sp)
    800043ec:	f022                	sd	s0,32(sp)
    800043ee:	ec26                	sd	s1,24(sp)
    800043f0:	e84a                	sd	s2,16(sp)
    800043f2:	1800                	addi	s0,sp,48
    800043f4:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800043f6:	00850913          	addi	s2,a0,8
    800043fa:	854a                	mv	a0,s2
    800043fc:	82dfc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004400:	409c                	lw	a5,0(s1)
    80004402:	ef81                	bnez	a5,8000441a <holdingsleep+0x32>
    80004404:	4481                	li	s1,0
  release(&lk->lk);
    80004406:	854a                	mv	a0,s2
    80004408:	8a9fc0ef          	jal	80000cb0 <release>
  return r;
}
    8000440c:	8526                	mv	a0,s1
    8000440e:	70a2                	ld	ra,40(sp)
    80004410:	7402                	ld	s0,32(sp)
    80004412:	64e2                	ld	s1,24(sp)
    80004414:	6942                	ld	s2,16(sp)
    80004416:	6145                	addi	sp,sp,48
    80004418:	8082                	ret
    8000441a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000441c:	0284a983          	lw	s3,40(s1)
    80004420:	d30fd0ef          	jal	80001950 <myproc>
    80004424:	5904                	lw	s1,48(a0)
    80004426:	413484b3          	sub	s1,s1,s3
    8000442a:	0014b493          	seqz	s1,s1
    8000442e:	69a2                	ld	s3,8(sp)
    80004430:	bfd9                	j	80004406 <holdingsleep+0x1e>

0000000080004432 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004432:	1141                	addi	sp,sp,-16
    80004434:	e406                	sd	ra,8(sp)
    80004436:	e022                	sd	s0,0(sp)
    80004438:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000443a:	00003597          	auipc	a1,0x3
    8000443e:	14e58593          	addi	a1,a1,334 # 80007588 <etext+0x588>
    80004442:	0001e517          	auipc	a0,0x1e
    80004446:	6e650513          	addi	a0,a0,1766 # 80022b28 <ftable>
    8000444a:	f5efc0ef          	jal	80000ba8 <initlock>
}
    8000444e:	60a2                	ld	ra,8(sp)
    80004450:	6402                	ld	s0,0(sp)
    80004452:	0141                	addi	sp,sp,16
    80004454:	8082                	ret

0000000080004456 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80004456:	1101                	addi	sp,sp,-32
    80004458:	ec06                	sd	ra,24(sp)
    8000445a:	e822                	sd	s0,16(sp)
    8000445c:	e426                	sd	s1,8(sp)
    8000445e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004460:	0001e517          	auipc	a0,0x1e
    80004464:	6c850513          	addi	a0,a0,1736 # 80022b28 <ftable>
    80004468:	fc0fc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    8000446c:	0001e497          	auipc	s1,0x1e
    80004470:	6d448493          	addi	s1,s1,1748 # 80022b40 <ftable+0x18>
    80004474:	0001f717          	auipc	a4,0x1f
    80004478:	66c70713          	addi	a4,a4,1644 # 80023ae0 <disk>
    if (f->ref == 0) {
    8000447c:	40dc                	lw	a5,4(s1)
    8000447e:	cf89                	beqz	a5,80004498 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004480:	02848493          	addi	s1,s1,40
    80004484:	fee49ce3          	bne	s1,a4,8000447c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004488:	0001e517          	auipc	a0,0x1e
    8000448c:	6a050513          	addi	a0,a0,1696 # 80022b28 <ftable>
    80004490:	821fc0ef          	jal	80000cb0 <release>
  return 0;
    80004494:	4481                	li	s1,0
    80004496:	a809                	j	800044a8 <filealloc+0x52>
      f->ref = 1;
    80004498:	4785                	li	a5,1
    8000449a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000449c:	0001e517          	auipc	a0,0x1e
    800044a0:	68c50513          	addi	a0,a0,1676 # 80022b28 <ftable>
    800044a4:	80dfc0ef          	jal	80000cb0 <release>
}
    800044a8:	8526                	mv	a0,s1
    800044aa:	60e2                	ld	ra,24(sp)
    800044ac:	6442                	ld	s0,16(sp)
    800044ae:	64a2                	ld	s1,8(sp)
    800044b0:	6105                	addi	sp,sp,32
    800044b2:	8082                	ret

00000000800044b4 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    800044b4:	1101                	addi	sp,sp,-32
    800044b6:	ec06                	sd	ra,24(sp)
    800044b8:	e822                	sd	s0,16(sp)
    800044ba:	e426                	sd	s1,8(sp)
    800044bc:	1000                	addi	s0,sp,32
    800044be:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800044c0:	0001e517          	auipc	a0,0x1e
    800044c4:	66850513          	addi	a0,a0,1640 # 80022b28 <ftable>
    800044c8:	f60fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800044cc:	40dc                	lw	a5,4(s1)
    800044ce:	02f05063          	blez	a5,800044ee <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800044d2:	2785                	addiw	a5,a5,1
    800044d4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800044d6:	0001e517          	auipc	a0,0x1e
    800044da:	65250513          	addi	a0,a0,1618 # 80022b28 <ftable>
    800044de:	fd2fc0ef          	jal	80000cb0 <release>
  return f;
}
    800044e2:	8526                	mv	a0,s1
    800044e4:	60e2                	ld	ra,24(sp)
    800044e6:	6442                	ld	s0,16(sp)
    800044e8:	64a2                	ld	s1,8(sp)
    800044ea:	6105                	addi	sp,sp,32
    800044ec:	8082                	ret
    panic("filedup");
    800044ee:	00003517          	auipc	a0,0x3
    800044f2:	0a250513          	addi	a0,a0,162 # 80007590 <etext+0x590>
    800044f6:	b3efc0ef          	jal	80000834 <panic>

00000000800044fa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044fa:	7139                	addi	sp,sp,-64
    800044fc:	fc06                	sd	ra,56(sp)
    800044fe:	f822                	sd	s0,48(sp)
    80004500:	f426                	sd	s1,40(sp)
    80004502:	0080                	addi	s0,sp,64
    80004504:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004506:	0001e517          	auipc	a0,0x1e
    8000450a:	62250513          	addi	a0,a0,1570 # 80022b28 <ftable>
    8000450e:	f1afc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    80004512:	40dc                	lw	a5,4(s1)
    80004514:	04f05a63          	blez	a5,80004568 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    80004518:	37fd                	addiw	a5,a5,-1
    8000451a:	c0dc                	sw	a5,4(s1)
    8000451c:	06f04063          	bgtz	a5,8000457c <fileclose+0x82>
    80004520:	f04a                	sd	s2,32(sp)
    80004522:	ec4e                	sd	s3,24(sp)
    80004524:	e852                	sd	s4,16(sp)
    80004526:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004528:	0004a903          	lw	s2,0(s1)
    8000452c:	0094c783          	lbu	a5,9(s1)
    80004530:	89be                	mv	s3,a5
    80004532:	689c                	ld	a5,16(s1)
    80004534:	8a3e                	mv	s4,a5
    80004536:	6c9c                	ld	a5,24(s1)
    80004538:	8abe                	mv	s5,a5
  f->ref = 0;
    8000453a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000453e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004542:	0001e517          	auipc	a0,0x1e
    80004546:	5e650513          	addi	a0,a0,1510 # 80022b28 <ftable>
    8000454a:	f66fc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    8000454e:	4785                	li	a5,1
    80004550:	04f90163          	beq	s2,a5,80004592 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    80004554:	ffe9079b          	addiw	a5,s2,-2
    80004558:	4705                	li	a4,1
    8000455a:	04f77563          	bgeu	a4,a5,800045a4 <fileclose+0xaa>
    8000455e:	7902                	ld	s2,32(sp)
    80004560:	69e2                	ld	s3,24(sp)
    80004562:	6a42                	ld	s4,16(sp)
    80004564:	6aa2                	ld	s5,8(sp)
    80004566:	a00d                	j	80004588 <fileclose+0x8e>
    80004568:	f04a                	sd	s2,32(sp)
    8000456a:	ec4e                	sd	s3,24(sp)
    8000456c:	e852                	sd	s4,16(sp)
    8000456e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004570:	00003517          	auipc	a0,0x3
    80004574:	02850513          	addi	a0,a0,40 # 80007598 <etext+0x598>
    80004578:	abcfc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    8000457c:	0001e517          	auipc	a0,0x1e
    80004580:	5ac50513          	addi	a0,a0,1452 # 80022b28 <ftable>
    80004584:	f2cfc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004588:	70e2                	ld	ra,56(sp)
    8000458a:	7442                	ld	s0,48(sp)
    8000458c:	74a2                	ld	s1,40(sp)
    8000458e:	6121                	addi	sp,sp,64
    80004590:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004592:	85ce                	mv	a1,s3
    80004594:	8552                	mv	a0,s4
    80004596:	36a000ef          	jal	80004900 <pipeclose>
    8000459a:	7902                	ld	s2,32(sp)
    8000459c:	69e2                	ld	s3,24(sp)
    8000459e:	6a42                	ld	s4,16(sp)
    800045a0:	6aa2                	ld	s5,8(sp)
    800045a2:	b7dd                	j	80004588 <fileclose+0x8e>
    begin_op();
    800045a4:	a9dff0ef          	jal	80004040 <begin_op>
    iput(ff.ip);
    800045a8:	8556                	mv	a0,s5
    800045aa:	9a0ff0ef          	jal	8000374a <iput>
    end_op();
    800045ae:	b1fff0ef          	jal	800040cc <end_op>
    800045b2:	7902                	ld	s2,32(sp)
    800045b4:	69e2                	ld	s3,24(sp)
    800045b6:	6a42                	ld	s4,16(sp)
    800045b8:	6aa2                	ld	s5,8(sp)
    800045ba:	b7f9                	j	80004588 <fileclose+0x8e>

00000000800045bc <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800045bc:	715d                	addi	sp,sp,-80
    800045be:	e486                	sd	ra,72(sp)
    800045c0:	e0a2                	sd	s0,64(sp)
    800045c2:	fc26                	sd	s1,56(sp)
    800045c4:	f052                	sd	s4,32(sp)
    800045c6:	0880                	addi	s0,sp,80
    800045c8:	84aa                	mv	s1,a0
    800045ca:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800045cc:	b84fd0ef          	jal	80001950 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    800045d0:	409c                	lw	a5,0(s1)
    800045d2:	37f9                	addiw	a5,a5,-2
    800045d4:	4705                	li	a4,1
    800045d6:	04f76963          	bltu	a4,a5,80004628 <filestat+0x6c>
    800045da:	f84a                	sd	s2,48(sp)
    800045dc:	f44e                	sd	s3,40(sp)
    800045de:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    800045e0:	fb840993          	addi	s3,s0,-72
    800045e4:	4661                	li	a2,24
    800045e6:	4581                	li	a1,0
    800045e8:	854e                	mv	a0,s3
    800045ea:	efefc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    800045ee:	6c88                	ld	a0,24(s1)
    800045f0:	fd9fe0ef          	jal	800035c8 <ilock>
    stati(f->ip, &st);
    800045f4:	85ce                	mv	a1,s3
    800045f6:	6c88                	ld	a0,24(s1)
    800045f8:	b7cff0ef          	jal	80003974 <stati>
    iunlock(f->ip);
    800045fc:	6c88                	ld	a0,24(s1)
    800045fe:	878ff0ef          	jal	80003676 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    80004602:	4761                	li	a4,24
    80004604:	86ce                	mv	a3,s3
    80004606:	8652                	mv	a2,s4
    80004608:	04893583          	ld	a1,72(s2)
    8000460c:	05093503          	ld	a0,80(s2)
    80004610:	f7bfc0ef          	jal	8000158a <copyout>
    80004614:	41f5551b          	sraiw	a0,a0,0x1f
    80004618:	7942                	ld	s2,48(sp)
    8000461a:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000461c:	60a6                	ld	ra,72(sp)
    8000461e:	6406                	ld	s0,64(sp)
    80004620:	74e2                	ld	s1,56(sp)
    80004622:	7a02                	ld	s4,32(sp)
    80004624:	6161                	addi	sp,sp,80
    80004626:	8082                	ret
  return -1;
    80004628:	557d                	li	a0,-1
    8000462a:	bfcd                	j	8000461c <filestat+0x60>

000000008000462c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000462c:	7179                	addi	sp,sp,-48
    8000462e:	f406                	sd	ra,40(sp)
    80004630:	f022                	sd	s0,32(sp)
    80004632:	e84a                	sd	s2,16(sp)
    80004634:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    80004636:	00854783          	lbu	a5,8(a0)
    8000463a:	c3dd                	beqz	a5,800046e0 <fileread+0xb4>
    8000463c:	ec26                	sd	s1,24(sp)
    8000463e:	e44e                	sd	s3,8(sp)
    80004640:	84aa                	mv	s1,a0
    80004642:	892e                	mv	s2,a1
    80004644:	89b2                	mv	s3,a2
    80004646:	01f6579b          	srliw	a5,a2,0x1f
    8000464a:	ebc9                	bnez	a5,800046dc <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    8000464c:	411c                	lw	a5,0(a0)
    8000464e:	4705                	li	a4,1
    80004650:	04e78363          	beq	a5,a4,80004696 <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004654:	470d                	li	a4,3
    80004656:	04e78763          	beq	a5,a4,800046a4 <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    8000465a:	4709                	li	a4,2
    8000465c:	06e79a63          	bne	a5,a4,800046d0 <fileread+0xa4>
    ilock(f->ip);
    80004660:	6d08                	ld	a0,24(a0)
    80004662:	f67fe0ef          	jal	800035c8 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004666:	874e                	mv	a4,s3
    80004668:	5094                	lw	a3,32(s1)
    8000466a:	864a                	mv	a2,s2
    8000466c:	4585                	li	a1,1
    8000466e:	6c88                	ld	a0,24(s1)
    80004670:	b32ff0ef          	jal	800039a2 <readi>
    80004674:	892a                	mv	s2,a0
    80004676:	00a05563          	blez	a0,80004680 <fileread+0x54>
      f->off += r;
    8000467a:	509c                	lw	a5,32(s1)
    8000467c:	9fa9                	addw	a5,a5,a0
    8000467e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004680:	6c88                	ld	a0,24(s1)
    80004682:	ff5fe0ef          	jal	80003676 <iunlock>
    80004686:	64e2                	ld	s1,24(sp)
    80004688:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000468a:	854a                	mv	a0,s2
    8000468c:	70a2                	ld	ra,40(sp)
    8000468e:	7402                	ld	s0,32(sp)
    80004690:	6942                	ld	s2,16(sp)
    80004692:	6145                	addi	sp,sp,48
    80004694:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004696:	6908                	ld	a0,16(a0)
    80004698:	3e2000ef          	jal	80004a7a <piperead>
    8000469c:	892a                	mv	s2,a0
    8000469e:	64e2                	ld	s1,24(sp)
    800046a0:	69a2                	ld	s3,8(sp)
    800046a2:	b7e5                	j	8000468a <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800046a4:	02451783          	lh	a5,36(a0)
    800046a8:	03079693          	slli	a3,a5,0x30
    800046ac:	92c1                	srli	a3,a3,0x30
    800046ae:	4725                	li	a4,9
    800046b0:	02d76b63          	bltu	a4,a3,800046e6 <fileread+0xba>
    800046b4:	0792                	slli	a5,a5,0x4
    800046b6:	0001e717          	auipc	a4,0x1e
    800046ba:	3d270713          	addi	a4,a4,978 # 80022a88 <devsw>
    800046be:	97ba                	add	a5,a5,a4
    800046c0:	639c                	ld	a5,0(a5)
    800046c2:	c79d                	beqz	a5,800046f0 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    800046c4:	4505                	li	a0,1
    800046c6:	9782                	jalr	a5
    800046c8:	892a                	mv	s2,a0
    800046ca:	64e2                	ld	s1,24(sp)
    800046cc:	69a2                	ld	s3,8(sp)
    800046ce:	bf75                	j	8000468a <fileread+0x5e>
    panic("fileread");
    800046d0:	00003517          	auipc	a0,0x3
    800046d4:	ed850513          	addi	a0,a0,-296 # 800075a8 <etext+0x5a8>
    800046d8:	95cfc0ef          	jal	80000834 <panic>
    800046dc:	64e2                	ld	s1,24(sp)
    800046de:	69a2                	ld	s3,8(sp)
    return -1;
    800046e0:	57fd                	li	a5,-1
    800046e2:	893e                	mv	s2,a5
    800046e4:	b75d                	j	8000468a <fileread+0x5e>
      return -1;
    800046e6:	57fd                	li	a5,-1
    800046e8:	893e                	mv	s2,a5
    800046ea:	64e2                	ld	s1,24(sp)
    800046ec:	69a2                	ld	s3,8(sp)
    800046ee:	bf71                	j	8000468a <fileread+0x5e>
    800046f0:	57fd                	li	a5,-1
    800046f2:	893e                	mv	s2,a5
    800046f4:	64e2                	ld	s1,24(sp)
    800046f6:	69a2                	ld	s3,8(sp)
    800046f8:	bf49                	j	8000468a <fileread+0x5e>

00000000800046fa <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    800046fa:	00954783          	lbu	a5,9(a0)
    800046fe:	12078b63          	beqz	a5,80004834 <filewrite+0x13a>
{
    80004702:	711d                	addi	sp,sp,-96
    80004704:	ec86                	sd	ra,88(sp)
    80004706:	e8a2                	sd	s0,80(sp)
    80004708:	e0ca                	sd	s2,64(sp)
    8000470a:	f456                	sd	s5,40(sp)
    8000470c:	f05a                	sd	s6,32(sp)
    8000470e:	1080                	addi	s0,sp,96
    80004710:	892a                	mv	s2,a0
    80004712:	8b2e                	mv	s6,a1
    80004714:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    80004716:	01f6579b          	srliw	a5,a2,0x1f
    8000471a:	0e079d63          	bnez	a5,80004814 <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    8000471e:	411c                	lw	a5,0(a0)
    80004720:	4705                	li	a4,1
    80004722:	02e78a63          	beq	a5,a4,80004756 <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004726:	470d                	li	a4,3
    80004728:	02e78b63          	beq	a5,a4,8000475e <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    8000472c:	4709                	li	a4,2
    8000472e:	0ce79763          	bne	a5,a4,800047fc <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    80004732:	0ec05763          	blez	a2,80004820 <filewrite+0x126>
    80004736:	e4a6                	sd	s1,72(sp)
    80004738:	fc4e                	sd	s3,56(sp)
    8000473a:	f852                	sd	s4,48(sp)
    8000473c:	ec5e                	sd	s7,24(sp)
    8000473e:	e862                	sd	s8,16(sp)
    80004740:	e466                	sd	s9,8(sp)
    int i = 0;
    80004742:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    80004744:	6b85                	lui	s7,0x1
    80004746:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000474a:	6785                	lui	a5,0x1
    8000474c:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004750:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004752:	4c05                	li	s8,1
    80004754:	a8ad                	j	800047ce <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    80004756:	6908                	ld	a0,16(a0)
    80004758:	206000ef          	jal	8000495e <pipewrite>
    8000475c:	a849                	j	800047ee <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000475e:	02451783          	lh	a5,36(a0)
    80004762:	03079693          	slli	a3,a5,0x30
    80004766:	92c1                	srli	a3,a3,0x30
    80004768:	4725                	li	a4,9
    8000476a:	0ad76763          	bltu	a4,a3,80004818 <filewrite+0x11e>
    8000476e:	0792                	slli	a5,a5,0x4
    80004770:	0001e717          	auipc	a4,0x1e
    80004774:	31870713          	addi	a4,a4,792 # 80022a88 <devsw>
    80004778:	97ba                	add	a5,a5,a4
    8000477a:	679c                	ld	a5,8(a5)
    8000477c:	c3c5                	beqz	a5,8000481c <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000477e:	4505                	li	a0,1
    80004780:	9782                	jalr	a5
    80004782:	a0b5                	j	800047ee <filewrite+0xf4>
      if (n1 > max)
    80004784:	2981                	sext.w	s3,s3
      begin_op();
    80004786:	8bbff0ef          	jal	80004040 <begin_op>
      ilock(f->ip);
    8000478a:	01893503          	ld	a0,24(s2)
    8000478e:	e3bfe0ef          	jal	800035c8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004792:	874e                	mv	a4,s3
    80004794:	02092683          	lw	a3,32(s2)
    80004798:	016a0633          	add	a2,s4,s6
    8000479c:	85e2                	mv	a1,s8
    8000479e:	01893503          	ld	a0,24(s2)
    800047a2:	af2ff0ef          	jal	80003a94 <writei>
    800047a6:	84aa                	mv	s1,a0
    800047a8:	00a05763          	blez	a0,800047b6 <filewrite+0xbc>
        f->off += r;
    800047ac:	02092783          	lw	a5,32(s2)
    800047b0:	9fa9                	addw	a5,a5,a0
    800047b2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800047b6:	01893503          	ld	a0,24(s2)
    800047ba:	ebdfe0ef          	jal	80003676 <iunlock>
      end_op();
    800047be:	90fff0ef          	jal	800040cc <end_op>

      if (r != n1) {
    800047c2:	00999d63          	bne	s3,s1,800047dc <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    800047c6:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    800047ca:	015a5963          	bge	s4,s5,800047dc <filewrite+0xe2>
      int n1 = n - i;
    800047ce:	414a87bb          	subw	a5,s5,s4
    800047d2:	89be                	mv	s3,a5
      if (n1 > max)
    800047d4:	fafbd8e3          	bge	s7,a5,80004784 <filewrite+0x8a>
    800047d8:	89e6                	mv	s3,s9
    800047da:	b76d                	j	80004784 <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    800047dc:	054a9463          	bne	s5,s4,80004824 <filewrite+0x12a>
    800047e0:	8556                	mv	a0,s5
    800047e2:	64a6                	ld	s1,72(sp)
    800047e4:	79e2                	ld	s3,56(sp)
    800047e6:	7a42                	ld	s4,48(sp)
    800047e8:	6be2                	ld	s7,24(sp)
    800047ea:	6c42                	ld	s8,16(sp)
    800047ec:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800047ee:	60e6                	ld	ra,88(sp)
    800047f0:	6446                	ld	s0,80(sp)
    800047f2:	6906                	ld	s2,64(sp)
    800047f4:	7aa2                	ld	s5,40(sp)
    800047f6:	7b02                	ld	s6,32(sp)
    800047f8:	6125                	addi	sp,sp,96
    800047fa:	8082                	ret
    800047fc:	e4a6                	sd	s1,72(sp)
    800047fe:	fc4e                	sd	s3,56(sp)
    80004800:	f852                	sd	s4,48(sp)
    80004802:	ec5e                	sd	s7,24(sp)
    80004804:	e862                	sd	s8,16(sp)
    80004806:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004808:	00003517          	auipc	a0,0x3
    8000480c:	db050513          	addi	a0,a0,-592 # 800075b8 <etext+0x5b8>
    80004810:	824fc0ef          	jal	80000834 <panic>
    return -1;
    80004814:	557d                	li	a0,-1
    80004816:	bfe1                	j	800047ee <filewrite+0xf4>
      return -1;
    80004818:	557d                	li	a0,-1
    8000481a:	bfd1                	j	800047ee <filewrite+0xf4>
    8000481c:	557d                	li	a0,-1
    8000481e:	bfc1                	j	800047ee <filewrite+0xf4>
    ret = (i == n ? n : -1);
    80004820:	8532                	mv	a0,a2
    80004822:	b7f1                	j	800047ee <filewrite+0xf4>
    80004824:	557d                	li	a0,-1
    80004826:	64a6                	ld	s1,72(sp)
    80004828:	79e2                	ld	s3,56(sp)
    8000482a:	7a42                	ld	s4,48(sp)
    8000482c:	6be2                	ld	s7,24(sp)
    8000482e:	6c42                	ld	s8,16(sp)
    80004830:	6ca2                	ld	s9,8(sp)
    80004832:	bf75                	j	800047ee <filewrite+0xf4>
    return -1;
    80004834:	557d                	li	a0,-1
}
    80004836:	8082                	ret

0000000080004838 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004838:	7179                	addi	sp,sp,-48
    8000483a:	f406                	sd	ra,40(sp)
    8000483c:	f022                	sd	s0,32(sp)
    8000483e:	ec26                	sd	s1,24(sp)
    80004840:	e052                	sd	s4,0(sp)
    80004842:	1800                	addi	s0,sp,48
    80004844:	84aa                	mv	s1,a0
    80004846:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004848:	0005b023          	sd	zero,0(a1)
    8000484c:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004850:	c07ff0ef          	jal	80004456 <filealloc>
    80004854:	e088                	sd	a0,0(s1)
    80004856:	c549                	beqz	a0,800048e0 <pipealloc+0xa8>
    80004858:	bffff0ef          	jal	80004456 <filealloc>
    8000485c:	00aa3023          	sd	a0,0(s4)
    80004860:	cd25                	beqz	a0,800048d8 <pipealloc+0xa0>
    80004862:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004864:	aeafc0ef          	jal	80000b4e <kalloc>
    80004868:	892a                	mv	s2,a0
    8000486a:	c12d                	beqz	a0,800048cc <pipealloc+0x94>
    8000486c:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000486e:	4985                	li	s3,1
    80004870:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004874:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004878:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000487c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004880:	00003597          	auipc	a1,0x3
    80004884:	d4858593          	addi	a1,a1,-696 # 800075c8 <etext+0x5c8>
    80004888:	b20fc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    8000488c:	609c                	ld	a5,0(s1)
    8000488e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004892:	609c                	ld	a5,0(s1)
    80004894:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004898:	609c                	ld	a5,0(s1)
    8000489a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000489e:	609c                	ld	a5,0(s1)
    800048a0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800048a4:	000a3783          	ld	a5,0(s4)
    800048a8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800048ac:	000a3783          	ld	a5,0(s4)
    800048b0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800048b4:	000a3783          	ld	a5,0(s4)
    800048b8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800048bc:	000a3783          	ld	a5,0(s4)
    800048c0:	0127b823          	sd	s2,16(a5)
  return 0;
    800048c4:	4501                	li	a0,0
    800048c6:	6942                	ld	s2,16(sp)
    800048c8:	69a2                	ld	s3,8(sp)
    800048ca:	a01d                	j	800048f0 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    800048cc:	6088                	ld	a0,0(s1)
    800048ce:	c119                	beqz	a0,800048d4 <pipealloc+0x9c>
    800048d0:	6942                	ld	s2,16(sp)
    800048d2:	a029                	j	800048dc <pipealloc+0xa4>
    800048d4:	6942                	ld	s2,16(sp)
    800048d6:	a029                	j	800048e0 <pipealloc+0xa8>
    800048d8:	6088                	ld	a0,0(s1)
    800048da:	c10d                	beqz	a0,800048fc <pipealloc+0xc4>
    fileclose(*f0);
    800048dc:	c1fff0ef          	jal	800044fa <fileclose>
  if (*f1)
    800048e0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800048e4:	557d                	li	a0,-1
  if (*f1)
    800048e6:	c789                	beqz	a5,800048f0 <pipealloc+0xb8>
    fileclose(*f1);
    800048e8:	853e                	mv	a0,a5
    800048ea:	c11ff0ef          	jal	800044fa <fileclose>
  return -1;
    800048ee:	557d                	li	a0,-1
}
    800048f0:	70a2                	ld	ra,40(sp)
    800048f2:	7402                	ld	s0,32(sp)
    800048f4:	64e2                	ld	s1,24(sp)
    800048f6:	6a02                	ld	s4,0(sp)
    800048f8:	6145                	addi	sp,sp,48
    800048fa:	8082                	ret
  return -1;
    800048fc:	557d                	li	a0,-1
    800048fe:	bfcd                	j	800048f0 <pipealloc+0xb8>

0000000080004900 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004900:	1101                	addi	sp,sp,-32
    80004902:	ec06                	sd	ra,24(sp)
    80004904:	e822                	sd	s0,16(sp)
    80004906:	e426                	sd	s1,8(sp)
    80004908:	e04a                	sd	s2,0(sp)
    8000490a:	1000                	addi	s0,sp,32
    8000490c:	84aa                	mv	s1,a0
    8000490e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004910:	b18fc0ef          	jal	80000c28 <acquire>
  if (writable) {
    80004914:	02090763          	beqz	s2,80004942 <pipeclose+0x42>
    pi->writeopen = 0;
    80004918:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000491c:	21848513          	addi	a0,s1,536
    80004920:	f1cfd0ef          	jal	8000203c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004924:	2204a783          	lw	a5,544(s1)
    80004928:	e781                	bnez	a5,80004930 <pipeclose+0x30>
    8000492a:	2244a783          	lw	a5,548(s1)
    8000492e:	c38d                	beqz	a5,80004950 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    80004930:	8526                	mv	a0,s1
    80004932:	b7efc0ef          	jal	80000cb0 <release>
}
    80004936:	60e2                	ld	ra,24(sp)
    80004938:	6442                	ld	s0,16(sp)
    8000493a:	64a2                	ld	s1,8(sp)
    8000493c:	6902                	ld	s2,0(sp)
    8000493e:	6105                	addi	sp,sp,32
    80004940:	8082                	ret
    pi->readopen = 0;
    80004942:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004946:	21c48513          	addi	a0,s1,540
    8000494a:	ef2fd0ef          	jal	8000203c <wakeup>
    8000494e:	bfd9                	j	80004924 <pipeclose+0x24>
    release(&pi->lock);
    80004950:	8526                	mv	a0,s1
    80004952:	b5efc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    80004956:	8526                	mv	a0,s1
    80004958:	90efc0ef          	jal	80000a66 <kfree>
    8000495c:	bfe9                	j	80004936 <pipeclose+0x36>

000000008000495e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000495e:	7159                	addi	sp,sp,-112
    80004960:	f486                	sd	ra,104(sp)
    80004962:	f0a2                	sd	s0,96(sp)
    80004964:	eca6                	sd	s1,88(sp)
    80004966:	e8ca                	sd	s2,80(sp)
    80004968:	e4ce                	sd	s3,72(sp)
    8000496a:	e0d2                	sd	s4,64(sp)
    8000496c:	fc56                	sd	s5,56(sp)
    8000496e:	1880                	addi	s0,sp,112
    80004970:	84aa                	mv	s1,a0
    80004972:	8aae                	mv	s5,a1
    80004974:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004976:	fdbfc0ef          	jal	80001950 <myproc>
    8000497a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000497c:	8526                	mv	a0,s1
    8000497e:	aaafc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    80004982:	0f405a63          	blez	s4,80004a76 <pipewrite+0x118>
    80004986:	f85a                	sd	s6,48(sp)
    80004988:	f45e                	sd	s7,40(sp)
    8000498a:	f062                	sd	s8,32(sp)
    8000498c:	ec66                	sd	s9,24(sp)
    8000498e:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004990:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004992:	f9f40c13          	addi	s8,s0,-97
    80004996:	4b85                	li	s7,1
    80004998:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000499a:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    8000499e:	21c48c93          	addi	s9,s1,540
    800049a2:	a0a1                	j	800049ea <pipewrite+0x8c>
      release(&pi->lock);
    800049a4:	8526                	mv	a0,s1
    800049a6:	b0afc0ef          	jal	80000cb0 <release>
      return -1;
    800049aa:	597d                	li	s2,-1
    800049ac:	7b42                	ld	s6,48(sp)
    800049ae:	7ba2                	ld	s7,40(sp)
    800049b0:	7c02                	ld	s8,32(sp)
    800049b2:	6ce2                	ld	s9,24(sp)
    800049b4:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800049b6:	854a                	mv	a0,s2
    800049b8:	70a6                	ld	ra,104(sp)
    800049ba:	7406                	ld	s0,96(sp)
    800049bc:	64e6                	ld	s1,88(sp)
    800049be:	6946                	ld	s2,80(sp)
    800049c0:	69a6                	ld	s3,72(sp)
    800049c2:	6a06                	ld	s4,64(sp)
    800049c4:	7ae2                	ld	s5,56(sp)
    800049c6:	6165                	addi	sp,sp,112
    800049c8:	8082                	ret
      wakeup(&pi->nread);
    800049ca:	856a                	mv	a0,s10
    800049cc:	e70fd0ef          	jal	8000203c <wakeup>
      sleep_prepare(&pi->nwrite);
    800049d0:	8566                	mv	a0,s9
    800049d2:	dfefd0ef          	jal	80001fd0 <sleep_prepare>
      release(&pi->lock);
    800049d6:	8526                	mv	a0,s1
    800049d8:	ad8fc0ef          	jal	80000cb0 <release>
      sleep();
    800049dc:	e30fd0ef          	jal	8000200c <sleep>
      acquire(&pi->lock);
    800049e0:	8526                	mv	a0,s1
    800049e2:	a46fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    800049e6:	07495b63          	bge	s2,s4,80004a5c <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    800049ea:	2204a783          	lw	a5,544(s1)
    800049ee:	dbdd                	beqz	a5,800049a4 <pipewrite+0x46>
    800049f0:	854e                	mv	a0,s3
    800049f2:	83dfd0ef          	jal	8000222e <killed>
    800049f6:	f55d                	bnez	a0,800049a4 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    800049f8:	2184a783          	lw	a5,536(s1)
    800049fc:	21c4a703          	lw	a4,540(s1)
    80004a00:	2007879b          	addiw	a5,a5,512
    80004a04:	fcf703e3          	beq	a4,a5,800049ca <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004a08:	875e                	mv	a4,s7
    80004a0a:	015906b3          	add	a3,s2,s5
    80004a0e:	8662                	mv	a2,s8
    80004a10:	0489b583          	ld	a1,72(s3)
    80004a14:	0509b503          	ld	a0,80(s3)
    80004a18:	c39fc0ef          	jal	80001650 <copyin>
    80004a1c:	03650163          	beq	a0,s6,80004a3e <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a20:	21c4a783          	lw	a5,540(s1)
    80004a24:	0017871b          	addiw	a4,a5,1
    80004a28:	20e4ae23          	sw	a4,540(s1)
    80004a2c:	1ff7f793          	andi	a5,a5,511
    80004a30:	97a6                	add	a5,a5,s1
    80004a32:	f9f44703          	lbu	a4,-97(s0)
    80004a36:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a3a:	2905                	addiw	s2,s2,1
    80004a3c:	b76d                	j	800049e6 <pipewrite+0x88>
        if (i == 0)
    80004a3e:	00090863          	beqz	s2,80004a4e <pipewrite+0xf0>
    80004a42:	7b42                	ld	s6,48(sp)
    80004a44:	7ba2                	ld	s7,40(sp)
    80004a46:	7c02                	ld	s8,32(sp)
    80004a48:	6ce2                	ld	s9,24(sp)
    80004a4a:	6d42                	ld	s10,16(sp)
    80004a4c:	a829                	j	80004a66 <pipewrite+0x108>
          i = -1;
    80004a4e:	892a                	mv	s2,a0
        break;
    80004a50:	7b42                	ld	s6,48(sp)
    80004a52:	7ba2                	ld	s7,40(sp)
    80004a54:	7c02                	ld	s8,32(sp)
    80004a56:	6ce2                	ld	s9,24(sp)
    80004a58:	6d42                	ld	s10,16(sp)
    80004a5a:	a031                	j	80004a66 <pipewrite+0x108>
    80004a5c:	7b42                	ld	s6,48(sp)
    80004a5e:	7ba2                	ld	s7,40(sp)
    80004a60:	7c02                	ld	s8,32(sp)
    80004a62:	6ce2                	ld	s9,24(sp)
    80004a64:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004a66:	21848513          	addi	a0,s1,536
    80004a6a:	dd2fd0ef          	jal	8000203c <wakeup>
  release(&pi->lock);
    80004a6e:	8526                	mv	a0,s1
    80004a70:	a40fc0ef          	jal	80000cb0 <release>
  return i;
    80004a74:	b789                	j	800049b6 <pipewrite+0x58>
  int i = 0;
    80004a76:	4901                	li	s2,0
    80004a78:	b7fd                	j	80004a66 <pipewrite+0x108>

0000000080004a7a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a7a:	711d                	addi	sp,sp,-96
    80004a7c:	ec86                	sd	ra,88(sp)
    80004a7e:	e8a2                	sd	s0,80(sp)
    80004a80:	e4a6                	sd	s1,72(sp)
    80004a82:	e0ca                	sd	s2,64(sp)
    80004a84:	fc4e                	sd	s3,56(sp)
    80004a86:	f852                	sd	s4,48(sp)
    80004a88:	f456                	sd	s5,40(sp)
    80004a8a:	1080                	addi	s0,sp,96
    80004a8c:	84aa                	mv	s1,a0
    80004a8e:	89ae                	mv	s3,a1
    80004a90:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a92:	ebffc0ef          	jal	80001950 <myproc>
    80004a96:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    80004a98:	8526                	mv	a0,s1
    80004a9a:	98efc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004a9e:	0d505263          	blez	s5,80004b62 <piperead+0xe8>
    80004aa2:	2184a703          	lw	a4,536(s1)
    80004aa6:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004aaa:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004aae:	02f71e63          	bne	a4,a5,80004aea <piperead+0x70>
    80004ab2:	2244a783          	lw	a5,548(s1)
    80004ab6:	c3b9                	beqz	a5,80004afc <piperead+0x82>
    if (killed(pr)) {
    80004ab8:	854a                	mv	a0,s2
    80004aba:	f74fd0ef          	jal	8000222e <killed>
    80004abe:	e915                	bnez	a0,80004af2 <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004ac0:	8552                	mv	a0,s4
    80004ac2:	d0efd0ef          	jal	80001fd0 <sleep_prepare>
    release(&pi->lock);
    80004ac6:	8526                	mv	a0,s1
    80004ac8:	9e8fc0ef          	jal	80000cb0 <release>
    sleep();
    80004acc:	d40fd0ef          	jal	8000200c <sleep>
    acquire(&pi->lock);
    80004ad0:	8526                	mv	a0,s1
    80004ad2:	956fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004ad6:	2184a703          	lw	a4,536(s1)
    80004ada:	21c4a783          	lw	a5,540(s1)
    80004ade:	fcf70ae3          	beq	a4,a5,80004ab2 <piperead+0x38>
    80004ae2:	f05a                	sd	s6,32(sp)
    80004ae4:	ec5e                	sd	s7,24(sp)
    80004ae6:	e862                	sd	s8,16(sp)
    80004ae8:	a829                	j	80004b02 <piperead+0x88>
    80004aea:	f05a                	sd	s6,32(sp)
    80004aec:	ec5e                	sd	s7,24(sp)
    80004aee:	e862                	sd	s8,16(sp)
    80004af0:	a809                	j	80004b02 <piperead+0x88>
      release(&pi->lock);
    80004af2:	8526                	mv	a0,s1
    80004af4:	9bcfc0ef          	jal	80000cb0 <release>
      return -1;
    80004af8:	5a7d                	li	s4,-1
    80004afa:	a8a5                	j	80004b72 <piperead+0xf8>
    80004afc:	f05a                	sd	s6,32(sp)
    80004afe:	ec5e                	sd	s7,24(sp)
    80004b00:	e862                	sd	s8,16(sp)
{
    80004b02:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004b04:	faf40c13          	addi	s8,s0,-81
    80004b08:	4b85                	li	s7,1
    80004b0a:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    80004b0c:	2184a783          	lw	a5,536(s1)
    80004b10:	21c4a703          	lw	a4,540(s1)
    80004b14:	06f70e63          	beq	a4,a5,80004b90 <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    80004b18:	1ff7f793          	andi	a5,a5,511
    80004b1c:	97a6                	add	a5,a5,s1
    80004b1e:	0187c783          	lbu	a5,24(a5)
    80004b22:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004b26:	875e                	mv	a4,s7
    80004b28:	86e2                	mv	a3,s8
    80004b2a:	864e                	mv	a2,s3
    80004b2c:	04893583          	ld	a1,72(s2)
    80004b30:	05093503          	ld	a0,80(s2)
    80004b34:	a57fc0ef          	jal	8000158a <copyout>
    80004b38:	01650f63          	beq	a0,s6,80004b56 <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004b3c:	2184a783          	lw	a5,536(s1)
    80004b40:	2785                	addiw	a5,a5,1
    80004b42:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004b46:	2a05                	addiw	s4,s4,1
    80004b48:	0985                	addi	s3,s3,1
    80004b4a:	fd4a91e3          	bne	s5,s4,80004b0c <piperead+0x92>
    80004b4e:	7b02                	ld	s6,32(sp)
    80004b50:	6be2                	ld	s7,24(sp)
    80004b52:	6c42                	ld	s8,16(sp)
    80004b54:	a801                	j	80004b64 <piperead+0xea>
      if (i == 0)
    80004b56:	020a0863          	beqz	s4,80004b86 <piperead+0x10c>
    80004b5a:	7b02                	ld	s6,32(sp)
    80004b5c:	6be2                	ld	s7,24(sp)
    80004b5e:	6c42                	ld	s8,16(sp)
    80004b60:	a011                	j	80004b64 <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004b62:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004b64:	21c48513          	addi	a0,s1,540
    80004b68:	cd4fd0ef          	jal	8000203c <wakeup>
  release(&pi->lock);
    80004b6c:	8526                	mv	a0,s1
    80004b6e:	942fc0ef          	jal	80000cb0 <release>
  return i;
}
    80004b72:	8552                	mv	a0,s4
    80004b74:	60e6                	ld	ra,88(sp)
    80004b76:	6446                	ld	s0,80(sp)
    80004b78:	64a6                	ld	s1,72(sp)
    80004b7a:	6906                	ld	s2,64(sp)
    80004b7c:	79e2                	ld	s3,56(sp)
    80004b7e:	7a42                	ld	s4,48(sp)
    80004b80:	7aa2                	ld	s5,40(sp)
    80004b82:	6125                	addi	sp,sp,96
    80004b84:	8082                	ret
        i = -1;
    80004b86:	8a2a                	mv	s4,a0
    80004b88:	7b02                	ld	s6,32(sp)
    80004b8a:	6be2                	ld	s7,24(sp)
    80004b8c:	6c42                	ld	s8,16(sp)
    80004b8e:	bfd9                	j	80004b64 <piperead+0xea>
    80004b90:	7b02                	ld	s6,32(sp)
    80004b92:	6be2                	ld	s7,24(sp)
    80004b94:	6c42                	ld	s8,16(sp)
    80004b96:	b7f9                	j	80004b64 <piperead+0xea>

0000000080004b98 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004b98:	1141                	addi	sp,sp,-16
    80004b9a:	e406                	sd	ra,8(sp)
    80004b9c:	e022                	sd	s0,0(sp)
    80004b9e:	0800                	addi	s0,sp,16
    80004ba0:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004ba2:	0035151b          	slliw	a0,a0,0x3
    80004ba6:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    80004ba8:	8b89                	andi	a5,a5,2
    80004baa:	c399                	beqz	a5,80004bb0 <flags2perm+0x18>
    perm |= PTE_W;
    80004bac:	00456513          	ori	a0,a0,4
  return perm;
}
    80004bb0:	60a2                	ld	ra,8(sp)
    80004bb2:	6402                	ld	s0,0(sp)
    80004bb4:	0141                	addi	sp,sp,16
    80004bb6:	8082                	ret

0000000080004bb8 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004bb8:	de010113          	addi	sp,sp,-544
    80004bbc:	20113c23          	sd	ra,536(sp)
    80004bc0:	20813823          	sd	s0,528(sp)
    80004bc4:	20913423          	sd	s1,520(sp)
    80004bc8:	21213023          	sd	s2,512(sp)
    80004bcc:	1400                	addi	s0,sp,544
    80004bce:	892a                	mv	s2,a0
    80004bd0:	dea43823          	sd	a0,-528(s0)
    80004bd4:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004bd8:	d79fc0ef          	jal	80001950 <myproc>
    80004bdc:	84aa                	mv	s1,a0

  begin_op();
    80004bde:	c62ff0ef          	jal	80004040 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004be2:	854a                	mv	a0,s2
    80004be4:	a7eff0ef          	jal	80003e62 <namei>
    80004be8:	cd21                	beqz	a0,80004c40 <kexec+0x88>
    80004bea:	fbd2                	sd	s4,496(sp)
    80004bec:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004bee:	9dbfe0ef          	jal	800035c8 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004bf2:	04000713          	li	a4,64
    80004bf6:	4681                	li	a3,0
    80004bf8:	e5040613          	addi	a2,s0,-432
    80004bfc:	4581                	li	a1,0
    80004bfe:	8552                	mv	a0,s4
    80004c00:	da3fe0ef          	jal	800039a2 <readi>
    80004c04:	04000793          	li	a5,64
    80004c08:	00f51a63          	bne	a0,a5,80004c1c <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004c0c:	e5042703          	lw	a4,-432(s0)
    80004c10:	464c47b7          	lui	a5,0x464c4
    80004c14:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c18:	02f70863          	beq	a4,a5,80004c48 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004c1c:	8552                	mv	a0,s4
    80004c1e:	bfffe0ef          	jal	8000381c <iunlockput>
    end_op();
    80004c22:	caaff0ef          	jal	800040cc <end_op>
  }
  return -1;
    80004c26:	557d                	li	a0,-1
    80004c28:	7a5e                	ld	s4,496(sp)
}
    80004c2a:	21813083          	ld	ra,536(sp)
    80004c2e:	21013403          	ld	s0,528(sp)
    80004c32:	20813483          	ld	s1,520(sp)
    80004c36:	20013903          	ld	s2,512(sp)
    80004c3a:	22010113          	addi	sp,sp,544
    80004c3e:	8082                	ret
    end_op();
    80004c40:	c8cff0ef          	jal	800040cc <end_op>
    return -1;
    80004c44:	557d                	li	a0,-1
    80004c46:	b7d5                	j	80004c2a <kexec+0x72>
    80004c48:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004c4a:	8526                	mv	a0,s1
    80004c4c:	e0bfc0ef          	jal	80001a56 <proc_pagetable>
    80004c50:	8b2a                	mv	s6,a0
    80004c52:	26050e63          	beqz	a0,80004ece <kexec+0x316>
    80004c56:	ffce                	sd	s3,504(sp)
    80004c58:	f7d6                	sd	s5,488(sp)
    80004c5a:	efde                	sd	s7,472(sp)
    80004c5c:	ebe2                	sd	s8,464(sp)
    80004c5e:	e7e6                	sd	s9,456(sp)
    80004c60:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004c62:	e8845783          	lhu	a5,-376(s0)
    80004c66:	14078263          	beqz	a5,80004daa <kexec+0x1f2>
    80004c6a:	ff6e                	sd	s11,440(sp)
    80004c6c:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c70:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004c72:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004c74:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004c78:	6c85                	lui	s9,0x1
    80004c7a:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004c7e:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004c82:	6a85                	lui	s5,0x1
    80004c84:	a085                	j	80004ce4 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004c86:	00003517          	auipc	a0,0x3
    80004c8a:	94a50513          	addi	a0,a0,-1718 # 800075d0 <etext+0x5d0>
    80004c8e:	ba7fb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004c92:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004c94:	874a                	mv	a4,s2
    80004c96:	009b86bb          	addw	a3,s7,s1
    80004c9a:	4581                	li	a1,0
    80004c9c:	8552                	mv	a0,s4
    80004c9e:	d05fe0ef          	jal	800039a2 <readi>
    80004ca2:	22a91a63          	bne	s2,a0,80004ed6 <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004ca6:	009a84bb          	addw	s1,s5,s1
    80004caa:	0334f263          	bgeu	s1,s3,80004cce <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004cae:	02049593          	slli	a1,s1,0x20
    80004cb2:	9181                	srli	a1,a1,0x20
    80004cb4:	95e2                	add	a1,a1,s8
    80004cb6:	855a                	mv	a0,s6
    80004cb8:	b68fc0ef          	jal	80001020 <walkaddr>
    80004cbc:	862a                	mv	a2,a0
    if (pa == 0)
    80004cbe:	d561                	beqz	a0,80004c86 <kexec+0xce>
    if (sz - i < PGSIZE)
    80004cc0:	409987bb          	subw	a5,s3,s1
    80004cc4:	893e                	mv	s2,a5
    80004cc6:	fcfcf6e3          	bgeu	s9,a5,80004c92 <kexec+0xda>
    80004cca:	8956                	mv	s2,s5
    80004ccc:	b7d9                	j	80004c92 <kexec+0xda>
    sz = sz1;
    80004cce:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004cd2:	2d05                	addiw	s10,s10,1
    80004cd4:	e0843783          	ld	a5,-504(s0)
    80004cd8:	0387869b          	addiw	a3,a5,56
    80004cdc:	e8845783          	lhu	a5,-376(s0)
    80004ce0:	06fd5d63          	bge	s10,a5,80004d5a <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ce4:	e0d43423          	sd	a3,-504(s0)
    80004ce8:	876e                	mv	a4,s11
    80004cea:	e1840613          	addi	a2,s0,-488
    80004cee:	4581                	li	a1,0
    80004cf0:	8552                	mv	a0,s4
    80004cf2:	cb1fe0ef          	jal	800039a2 <readi>
    80004cf6:	1db51e63          	bne	a0,s11,80004ed2 <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004cfa:	e1842783          	lw	a5,-488(s0)
    80004cfe:	4705                	li	a4,1
    80004d00:	fce799e3          	bne	a5,a4,80004cd2 <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004d04:	e4043483          	ld	s1,-448(s0)
    80004d08:	e3843783          	ld	a5,-456(s0)
    80004d0c:	1ef4e363          	bltu	s1,a5,80004ef2 <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004d10:	e2843783          	ld	a5,-472(s0)
    80004d14:	94be                	add	s1,s1,a5
    80004d16:	1ef4e163          	bltu	s1,a5,80004ef8 <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004d1a:	de843703          	ld	a4,-536(s0)
    80004d1e:	8ff9                	and	a5,a5,a4
    80004d20:	1c079f63          	bnez	a5,80004efe <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004d24:	e1c42503          	lw	a0,-484(s0)
    80004d28:	e71ff0ef          	jal	80004b98 <flags2perm>
    80004d2c:	86aa                	mv	a3,a0
    80004d2e:	8626                	mv	a2,s1
    80004d30:	85ca                	mv	a1,s2
    80004d32:	855a                	mv	a0,s6
    80004d34:	dc2fc0ef          	jal	800012f6 <uvmalloc>
    80004d38:	dea43c23          	sd	a0,-520(s0)
    80004d3c:	1c050463          	beqz	a0,80004f04 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d40:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004d44:	00098863          	beqz	s3,80004d54 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d48:	e2843c03          	ld	s8,-472(s0)
    80004d4c:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004d50:	4481                	li	s1,0
    80004d52:	bfb1                	j	80004cae <kexec+0xf6>
    sz = sz1;
    80004d54:	df843903          	ld	s2,-520(s0)
    80004d58:	bfad                	j	80004cd2 <kexec+0x11a>
    80004d5a:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004d5c:	8552                	mv	a0,s4
    80004d5e:	abffe0ef          	jal	8000381c <iunlockput>
  end_op();
    80004d62:	b6aff0ef          	jal	800040cc <end_op>
  p = myproc();
    80004d66:	bebfc0ef          	jal	80001950 <myproc>
    80004d6a:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004d6c:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004d70:	6c05                	lui	s8,0x1
    80004d72:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004d74:	9c4a                	add	s8,s8,s2
    80004d76:	77fd                	lui	a5,0xfffff
    80004d78:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004d7c:	4691                	li	a3,4
    80004d7e:	6609                	lui	a2,0x2
    80004d80:	9662                	add	a2,a2,s8
    80004d82:	85e2                	mv	a1,s8
    80004d84:	855a                	mv	a0,s6
    80004d86:	d70fc0ef          	jal	800012f6 <uvmalloc>
    80004d8a:	892a                	mv	s2,a0
    80004d8c:	e10d                	bnez	a0,80004dae <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004d8e:	85e2                	mv	a1,s8
    80004d90:	855a                	mv	a0,s6
    80004d92:	d49fc0ef          	jal	80001ada <proc_freepagetable>
  return -1;
    80004d96:	557d                	li	a0,-1
    80004d98:	79fe                	ld	s3,504(sp)
    80004d9a:	7a5e                	ld	s4,496(sp)
    80004d9c:	7abe                	ld	s5,488(sp)
    80004d9e:	7b1e                	ld	s6,480(sp)
    80004da0:	6bfe                	ld	s7,472(sp)
    80004da2:	6c5e                	ld	s8,464(sp)
    80004da4:	6cbe                	ld	s9,456(sp)
    80004da6:	6d1e                	ld	s10,448(sp)
    80004da8:	b549                	j	80004c2a <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004daa:	4901                	li	s2,0
    80004dac:	bf45                	j	80004d5c <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004dae:	75f9                	lui	a1,0xffffe
    80004db0:	95aa                	add	a1,a1,a0
    80004db2:	855a                	mv	a0,s6
    80004db4:	f14fc0ef          	jal	800014c8 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004db8:	80090a13          	addi	s4,s2,-2048
    80004dbc:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004dc0:	e0043783          	ld	a5,-512(s0)
    80004dc4:	6388                	ld	a0,0(a5)
    80004dc6:	c545                	beqz	a0,80004e6e <kexec+0x2b6>
  sp = sz;
    80004dc8:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004dca:	4481                	li	s1,0
    ustack[argc] = sp;
    80004dcc:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004dd0:	8a2fc0ef          	jal	80000e72 <strlen>
    80004dd4:	0015079b          	addiw	a5,a0,1
    80004dd8:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ddc:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004de0:	134c6563          	bltu	s8,s4,80004f0a <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004de4:	e0043d03          	ld	s10,-512(s0)
    80004de8:	000d3c83          	ld	s9,0(s10)
    80004dec:	8566                	mv	a0,s9
    80004dee:	884fc0ef          	jal	80000e72 <strlen>
    80004df2:	0015071b          	addiw	a4,a0,1
    80004df6:	86e6                	mv	a3,s9
    80004df8:	8662                	mv	a2,s8
    80004dfa:	85ca                	mv	a1,s2
    80004dfc:	855a                	mv	a0,s6
    80004dfe:	f8cfc0ef          	jal	8000158a <copyout>
    80004e02:	10054663          	bltz	a0,80004f0e <kexec+0x356>
    ustack[argc] = sp;
    80004e06:	00349793          	slli	a5,s1,0x3
    80004e0a:	97de                	add	a5,a5,s7
    80004e0c:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb3e0>
  for (argc = 0; argv[argc]; argc++) {
    80004e10:	0485                	addi	s1,s1,1
    80004e12:	008d0793          	addi	a5,s10,8
    80004e16:	e0f43023          	sd	a5,-512(s0)
    80004e1a:	008d3503          	ld	a0,8(s10)
    80004e1e:	f94d                	bnez	a0,80004dd0 <kexec+0x218>
  ustack[argc] = 0;
    80004e20:	00349793          	slli	a5,s1,0x3
    80004e24:	f9078793          	addi	a5,a5,-112
    80004e28:	97a2                	add	a5,a5,s0
    80004e2a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004e2e:	00349713          	slli	a4,s1,0x3
    80004e32:	0721                	addi	a4,a4,8
    80004e34:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004e38:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004e3c:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004e3e:	f54be8e3          	bltu	s7,s4,80004d8e <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004e42:	e9040693          	addi	a3,s0,-368
    80004e46:	865e                	mv	a2,s7
    80004e48:	85ca                	mv	a1,s2
    80004e4a:	855a                	mv	a0,s6
    80004e4c:	f3efc0ef          	jal	8000158a <copyout>
    80004e50:	f2054fe3          	bltz	a0,80004d8e <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004e54:	0589b783          	ld	a5,88(s3)
    80004e58:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004e5c:	df043783          	ld	a5,-528(s0)
    80004e60:	0007c703          	lbu	a4,0(a5)
    80004e64:	c30d                	beqz	a4,80004e86 <kexec+0x2ce>
    80004e66:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004e68:	02f00693          	li	a3,47
    80004e6c:	a801                	j	80004e7c <kexec+0x2c4>
  sp = sz;
    80004e6e:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004e70:	4481                	li	s1,0
    80004e72:	b77d                	j	80004e20 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004e74:	0785                	addi	a5,a5,1
    80004e76:	fff7c703          	lbu	a4,-1(a5)
    80004e7a:	c711                	beqz	a4,80004e86 <kexec+0x2ce>
    if (*s == '/')
    80004e7c:	fed71ce3          	bne	a4,a3,80004e74 <kexec+0x2bc>
      last = s + 1;
    80004e80:	def43823          	sd	a5,-528(s0)
    80004e84:	bfc5                	j	80004e74 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e86:	4641                	li	a2,16
    80004e88:	df043583          	ld	a1,-528(s0)
    80004e8c:	15898513          	addi	a0,s3,344
    80004e90:	fadfb0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004e94:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004e98:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004e9c:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004ea0:	0589b783          	ld	a5,88(s3)
    80004ea4:	e6843703          	ld	a4,-408(s0)
    80004ea8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004eaa:	0589b783          	ld	a5,88(s3)
    80004eae:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004eb2:	85d6                	mv	a1,s5
    80004eb4:	c27fc0ef          	jal	80001ada <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004eb8:	0004851b          	sext.w	a0,s1
    80004ebc:	79fe                	ld	s3,504(sp)
    80004ebe:	7a5e                	ld	s4,496(sp)
    80004ec0:	7abe                	ld	s5,488(sp)
    80004ec2:	7b1e                	ld	s6,480(sp)
    80004ec4:	6bfe                	ld	s7,472(sp)
    80004ec6:	6c5e                	ld	s8,464(sp)
    80004ec8:	6cbe                	ld	s9,456(sp)
    80004eca:	6d1e                	ld	s10,448(sp)
    80004ecc:	bbb9                	j	80004c2a <kexec+0x72>
    80004ece:	7b1e                	ld	s6,480(sp)
    80004ed0:	b3b1                	j	80004c1c <kexec+0x64>
    80004ed2:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004ed6:	df843583          	ld	a1,-520(s0)
    80004eda:	855a                	mv	a0,s6
    80004edc:	bfffc0ef          	jal	80001ada <proc_freepagetable>
  if (ip) {
    80004ee0:	79fe                	ld	s3,504(sp)
    80004ee2:	7abe                	ld	s5,488(sp)
    80004ee4:	7b1e                	ld	s6,480(sp)
    80004ee6:	6bfe                	ld	s7,472(sp)
    80004ee8:	6c5e                	ld	s8,464(sp)
    80004eea:	6cbe                	ld	s9,456(sp)
    80004eec:	6d1e                	ld	s10,448(sp)
    80004eee:	7dfa                	ld	s11,440(sp)
    80004ef0:	b335                	j	80004c1c <kexec+0x64>
    80004ef2:	df243c23          	sd	s2,-520(s0)
    80004ef6:	b7c5                	j	80004ed6 <kexec+0x31e>
    80004ef8:	df243c23          	sd	s2,-520(s0)
    80004efc:	bfe9                	j	80004ed6 <kexec+0x31e>
    80004efe:	df243c23          	sd	s2,-520(s0)
    80004f02:	bfd1                	j	80004ed6 <kexec+0x31e>
    80004f04:	df243c23          	sd	s2,-520(s0)
    80004f08:	b7f9                	j	80004ed6 <kexec+0x31e>
  sz = sz1;
    80004f0a:	8c4a                	mv	s8,s2
    80004f0c:	b549                	j	80004d8e <kexec+0x1d6>
    80004f0e:	8c4a                	mv	s8,s2
    80004f10:	bdbd                	j	80004d8e <kexec+0x1d6>

0000000080004f12 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f12:	7179                	addi	sp,sp,-48
    80004f14:	f406                	sd	ra,40(sp)
    80004f16:	f022                	sd	s0,32(sp)
    80004f18:	ec26                	sd	s1,24(sp)
    80004f1a:	e84a                	sd	s2,16(sp)
    80004f1c:	1800                	addi	s0,sp,48
    80004f1e:	892e                	mv	s2,a1
    80004f20:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f22:	fdc40593          	addi	a1,s0,-36
    80004f26:	9e9fd0ef          	jal	8000290e <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004f2a:	fdc42703          	lw	a4,-36(s0)
    80004f2e:	47bd                	li	a5,15
    80004f30:	02e7ea63          	bltu	a5,a4,80004f64 <argfd+0x52>
    80004f34:	a1dfc0ef          	jal	80001950 <myproc>
    80004f38:	fdc42703          	lw	a4,-36(s0)
    80004f3c:	00371793          	slli	a5,a4,0x3
    80004f40:	0d078793          	addi	a5,a5,208
    80004f44:	953e                	add	a0,a0,a5
    80004f46:	611c                	ld	a5,0(a0)
    80004f48:	c385                	beqz	a5,80004f68 <argfd+0x56>
    return -1;
  if (pfd)
    80004f4a:	00090463          	beqz	s2,80004f52 <argfd+0x40>
    *pfd = fd;
    80004f4e:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004f52:	4501                	li	a0,0
  if (pf)
    80004f54:	c091                	beqz	s1,80004f58 <argfd+0x46>
    *pf = f;
    80004f56:	e09c                	sd	a5,0(s1)
}
    80004f58:	70a2                	ld	ra,40(sp)
    80004f5a:	7402                	ld	s0,32(sp)
    80004f5c:	64e2                	ld	s1,24(sp)
    80004f5e:	6942                	ld	s2,16(sp)
    80004f60:	6145                	addi	sp,sp,48
    80004f62:	8082                	ret
    return -1;
    80004f64:	557d                	li	a0,-1
    80004f66:	bfcd                	j	80004f58 <argfd+0x46>
    80004f68:	557d                	li	a0,-1
    80004f6a:	b7fd                	j	80004f58 <argfd+0x46>

0000000080004f6c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f6c:	1101                	addi	sp,sp,-32
    80004f6e:	ec06                	sd	ra,24(sp)
    80004f70:	e822                	sd	s0,16(sp)
    80004f72:	e426                	sd	s1,8(sp)
    80004f74:	1000                	addi	s0,sp,32
    80004f76:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f78:	9d9fc0ef          	jal	80001950 <myproc>
    80004f7c:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004f7e:	0d050793          	addi	a5,a0,208
    80004f82:	4501                	li	a0,0
    80004f84:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004f86:	6398                	ld	a4,0(a5)
    80004f88:	cb19                	beqz	a4,80004f9e <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004f8a:	2505                	addiw	a0,a0,1
    80004f8c:	07a1                	addi	a5,a5,8
    80004f8e:	fed51ce3          	bne	a0,a3,80004f86 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f92:	557d                	li	a0,-1
}
    80004f94:	60e2                	ld	ra,24(sp)
    80004f96:	6442                	ld	s0,16(sp)
    80004f98:	64a2                	ld	s1,8(sp)
    80004f9a:	6105                	addi	sp,sp,32
    80004f9c:	8082                	ret
      p->ofile[fd] = f;
    80004f9e:	00351793          	slli	a5,a0,0x3
    80004fa2:	0d078793          	addi	a5,a5,208
    80004fa6:	963e                	add	a2,a2,a5
    80004fa8:	e204                	sd	s1,0(a2)
      return fd;
    80004faa:	b7ed                	j	80004f94 <fdalloc+0x28>

0000000080004fac <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004fac:	715d                	addi	sp,sp,-80
    80004fae:	e486                	sd	ra,72(sp)
    80004fb0:	e0a2                	sd	s0,64(sp)
    80004fb2:	fc26                	sd	s1,56(sp)
    80004fb4:	f84a                	sd	s2,48(sp)
    80004fb6:	f052                	sd	s4,32(sp)
    80004fb8:	ec56                	sd	s5,24(sp)
    80004fba:	e85a                	sd	s6,16(sp)
    80004fbc:	0880                	addi	s0,sp,80
    80004fbe:	8a2e                	mv	s4,a1
    80004fc0:	8ab2                	mv	s5,a2
    80004fc2:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004fc4:	fb040593          	addi	a1,s0,-80
    80004fc8:	eb5fe0ef          	jal	80003e7c <nameiparent>
    80004fcc:	84aa                	mv	s1,a0
    80004fce:	12050f63          	beqz	a0,8000510c <create+0x160>
    return 0;

  ilock(dp);
    80004fd2:	df6fe0ef          	jal	800035c8 <ilock>

  if (dp->nlink == 0) {
    80004fd6:	04a49783          	lh	a5,74(s1)
    80004fda:	cbb9                	beqz	a5,80005030 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004fdc:	7761                	lui	a4,0xffff8
    80004fde:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd43e1>
    80004fe0:	97ba                	add	a5,a5,a4
    80004fe2:	e781                	bnez	a5,80004fea <create+0x3e>
    80004fe4:	fffa0793          	addi	a5,s4,-1
    80004fe8:	cba9                	beqz	a5,8000503a <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004fea:	4601                	li	a2,0
    80004fec:	fb040593          	addi	a1,s0,-80
    80004ff0:	8526                	mv	a0,s1
    80004ff2:	bbffe0ef          	jal	80003bb0 <dirlookup>
    80004ff6:	892a                	mv	s2,a0
    80004ff8:	c939                	beqz	a0,8000504e <create+0xa2>
    iunlockput(dp);
    80004ffa:	8526                	mv	a0,s1
    80004ffc:	821fe0ef          	jal	8000381c <iunlockput>
    ilock(ip);
    80005000:	854a                	mv	a0,s2
    80005002:	dc6fe0ef          	jal	800035c8 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005006:	4789                	li	a5,2
    80005008:	02fa1e63          	bne	s4,a5,80005044 <create+0x98>
    8000500c:	04495783          	lhu	a5,68(s2)
    80005010:	37f9                	addiw	a5,a5,-2
    80005012:	17c2                	slli	a5,a5,0x30
    80005014:	93c1                	srli	a5,a5,0x30
    80005016:	4705                	li	a4,1
    80005018:	02f76663          	bltu	a4,a5,80005044 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000501c:	854a                	mv	a0,s2
    8000501e:	60a6                	ld	ra,72(sp)
    80005020:	6406                	ld	s0,64(sp)
    80005022:	74e2                	ld	s1,56(sp)
    80005024:	7942                	ld	s2,48(sp)
    80005026:	7a02                	ld	s4,32(sp)
    80005028:	6ae2                	ld	s5,24(sp)
    8000502a:	6b42                	ld	s6,16(sp)
    8000502c:	6161                	addi	sp,sp,80
    8000502e:	8082                	ret
    iunlockput(dp);
    80005030:	8526                	mv	a0,s1
    80005032:	feafe0ef          	jal	8000381c <iunlockput>
    return 0;
    80005036:	4901                	li	s2,0
    80005038:	b7d5                	j	8000501c <create+0x70>
    iunlockput(dp);
    8000503a:	8526                	mv	a0,s1
    8000503c:	fe0fe0ef          	jal	8000381c <iunlockput>
    return 0;
    80005040:	4901                	li	s2,0
    80005042:	bfe9                	j	8000501c <create+0x70>
    iunlockput(ip);
    80005044:	854a                	mv	a0,s2
    80005046:	fd6fe0ef          	jal	8000381c <iunlockput>
    return 0;
    8000504a:	4901                	li	s2,0
    8000504c:	bfc1                	j	8000501c <create+0x70>
    8000504e:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80005050:	85d2                	mv	a1,s4
    80005052:	4088                	lw	a0,0(s1)
    80005054:	c04fe0ef          	jal	80003458 <ialloc>
    80005058:	89aa                	mv	s3,a0
    8000505a:	cd1d                	beqz	a0,80005098 <create+0xec>
  ilock(ip);
    8000505c:	d6cfe0ef          	jal	800035c8 <ilock>
  ip->major = major;
    80005060:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80005064:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80005068:	4705                	li	a4,1
    8000506a:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    8000506e:	854e                	mv	a0,s3
    80005070:	ca4fe0ef          	jal	80003514 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80005074:	4705                	li	a4,1
    80005076:	02ea0763          	beq	s4,a4,800050a4 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    8000507a:	0049a603          	lw	a2,4(s3)
    8000507e:	fb040593          	addi	a1,s0,-80
    80005082:	8526                	mv	a0,s1
    80005084:	d35fe0ef          	jal	80003db8 <dirlink>
    80005088:	06054563          	bltz	a0,800050f2 <create+0x146>
  iunlockput(dp);
    8000508c:	8526                	mv	a0,s1
    8000508e:	f8efe0ef          	jal	8000381c <iunlockput>
  return ip;
    80005092:	894e                	mv	s2,s3
    80005094:	79a2                	ld	s3,40(sp)
    80005096:	b759                	j	8000501c <create+0x70>
    iunlockput(dp);
    80005098:	8526                	mv	a0,s1
    8000509a:	f82fe0ef          	jal	8000381c <iunlockput>
    return 0;
    8000509e:	894e                	mv	s2,s3
    800050a0:	79a2                	ld	s3,40(sp)
    800050a2:	bfad                	j	8000501c <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050a4:	0049a603          	lw	a2,4(s3)
    800050a8:	00002597          	auipc	a1,0x2
    800050ac:	54858593          	addi	a1,a1,1352 # 800075f0 <etext+0x5f0>
    800050b0:	854e                	mv	a0,s3
    800050b2:	d07fe0ef          	jal	80003db8 <dirlink>
    800050b6:	02054e63          	bltz	a0,800050f2 <create+0x146>
    800050ba:	40d0                	lw	a2,4(s1)
    800050bc:	00002597          	auipc	a1,0x2
    800050c0:	53c58593          	addi	a1,a1,1340 # 800075f8 <etext+0x5f8>
    800050c4:	854e                	mv	a0,s3
    800050c6:	cf3fe0ef          	jal	80003db8 <dirlink>
    800050ca:	02054463          	bltz	a0,800050f2 <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    800050ce:	0049a603          	lw	a2,4(s3)
    800050d2:	fb040593          	addi	a1,s0,-80
    800050d6:	8526                	mv	a0,s1
    800050d8:	ce1fe0ef          	jal	80003db8 <dirlink>
    800050dc:	00054b63          	bltz	a0,800050f2 <create+0x146>
    dp->nlink++; // for ".."
    800050e0:	04a4d783          	lhu	a5,74(s1)
    800050e4:	2785                	addiw	a5,a5,1
    800050e6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800050ea:	8526                	mv	a0,s1
    800050ec:	c28fe0ef          	jal	80003514 <iupdate>
    800050f0:	bf71                	j	8000508c <create+0xe0>
  ip->nlink = 0;
    800050f2:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    800050f6:	854e                	mv	a0,s3
    800050f8:	c1cfe0ef          	jal	80003514 <iupdate>
  iunlockput(ip);
    800050fc:	854e                	mv	a0,s3
    800050fe:	f1efe0ef          	jal	8000381c <iunlockput>
  iunlockput(dp);
    80005102:	8526                	mv	a0,s1
    80005104:	f18fe0ef          	jal	8000381c <iunlockput>
  return 0;
    80005108:	79a2                	ld	s3,40(sp)
    8000510a:	bf09                	j	8000501c <create+0x70>
    return 0;
    8000510c:	892a                	mv	s2,a0
    8000510e:	b739                	j	8000501c <create+0x70>

0000000080005110 <sys_dup>:
{
    80005110:	7179                	addi	sp,sp,-48
    80005112:	f406                	sd	ra,40(sp)
    80005114:	f022                	sd	s0,32(sp)
    80005116:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80005118:	fd840613          	addi	a2,s0,-40
    8000511c:	4581                	li	a1,0
    8000511e:	4501                	li	a0,0
    80005120:	df3ff0ef          	jal	80004f12 <argfd>
    return -1;
    80005124:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80005126:	02054363          	bltz	a0,8000514c <sys_dup+0x3c>
    8000512a:	ec26                	sd	s1,24(sp)
    8000512c:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    8000512e:	fd843483          	ld	s1,-40(s0)
    80005132:	8526                	mv	a0,s1
    80005134:	e39ff0ef          	jal	80004f6c <fdalloc>
    80005138:	892a                	mv	s2,a0
    return -1;
    8000513a:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    8000513c:	00054d63          	bltz	a0,80005156 <sys_dup+0x46>
  filedup(f);
    80005140:	8526                	mv	a0,s1
    80005142:	b72ff0ef          	jal	800044b4 <filedup>
  return fd;
    80005146:	87ca                	mv	a5,s2
    80005148:	64e2                	ld	s1,24(sp)
    8000514a:	6942                	ld	s2,16(sp)
}
    8000514c:	853e                	mv	a0,a5
    8000514e:	70a2                	ld	ra,40(sp)
    80005150:	7402                	ld	s0,32(sp)
    80005152:	6145                	addi	sp,sp,48
    80005154:	8082                	ret
    80005156:	64e2                	ld	s1,24(sp)
    80005158:	6942                	ld	s2,16(sp)
    8000515a:	bfcd                	j	8000514c <sys_dup+0x3c>

000000008000515c <sys_read>:
{
    8000515c:	7179                	addi	sp,sp,-48
    8000515e:	f406                	sd	ra,40(sp)
    80005160:	f022                	sd	s0,32(sp)
    80005162:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005164:	fd840593          	addi	a1,s0,-40
    80005168:	4505                	li	a0,1
    8000516a:	fc0fd0ef          	jal	8000292a <argaddr>
  argint(2, &n);
    8000516e:	fe440593          	addi	a1,s0,-28
    80005172:	4509                	li	a0,2
    80005174:	f9afd0ef          	jal	8000290e <argint>
  if (argfd(0, 0, &f) < 0)
    80005178:	fe840613          	addi	a2,s0,-24
    8000517c:	4581                	li	a1,0
    8000517e:	4501                	li	a0,0
    80005180:	d93ff0ef          	jal	80004f12 <argfd>
    80005184:	87aa                	mv	a5,a0
    return -1;
    80005186:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005188:	0007ca63          	bltz	a5,8000519c <sys_read+0x40>
  return fileread(f, p, n);
    8000518c:	fe442603          	lw	a2,-28(s0)
    80005190:	fd843583          	ld	a1,-40(s0)
    80005194:	fe843503          	ld	a0,-24(s0)
    80005198:	c94ff0ef          	jal	8000462c <fileread>
}
    8000519c:	70a2                	ld	ra,40(sp)
    8000519e:	7402                	ld	s0,32(sp)
    800051a0:	6145                	addi	sp,sp,48
    800051a2:	8082                	ret

00000000800051a4 <sys_write>:
{
    800051a4:	7179                	addi	sp,sp,-48
    800051a6:	f406                	sd	ra,40(sp)
    800051a8:	f022                	sd	s0,32(sp)
    800051aa:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051ac:	fd840593          	addi	a1,s0,-40
    800051b0:	4505                	li	a0,1
    800051b2:	f78fd0ef          	jal	8000292a <argaddr>
  argint(2, &n);
    800051b6:	fe440593          	addi	a1,s0,-28
    800051ba:	4509                	li	a0,2
    800051bc:	f52fd0ef          	jal	8000290e <argint>
  if (argfd(0, 0, &f) < 0)
    800051c0:	fe840613          	addi	a2,s0,-24
    800051c4:	4581                	li	a1,0
    800051c6:	4501                	li	a0,0
    800051c8:	d4bff0ef          	jal	80004f12 <argfd>
    800051cc:	87aa                	mv	a5,a0
    return -1;
    800051ce:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800051d0:	0007ca63          	bltz	a5,800051e4 <sys_write+0x40>
  return filewrite(f, p, n);
    800051d4:	fe442603          	lw	a2,-28(s0)
    800051d8:	fd843583          	ld	a1,-40(s0)
    800051dc:	fe843503          	ld	a0,-24(s0)
    800051e0:	d1aff0ef          	jal	800046fa <filewrite>
}
    800051e4:	70a2                	ld	ra,40(sp)
    800051e6:	7402                	ld	s0,32(sp)
    800051e8:	6145                	addi	sp,sp,48
    800051ea:	8082                	ret

00000000800051ec <sys_close>:
{
    800051ec:	1101                	addi	sp,sp,-32
    800051ee:	ec06                	sd	ra,24(sp)
    800051f0:	e822                	sd	s0,16(sp)
    800051f2:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    800051f4:	fe040613          	addi	a2,s0,-32
    800051f8:	fec40593          	addi	a1,s0,-20
    800051fc:	4501                	li	a0,0
    800051fe:	d15ff0ef          	jal	80004f12 <argfd>
    return -1;
    80005202:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80005204:	02054163          	bltz	a0,80005226 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80005208:	f48fc0ef          	jal	80001950 <myproc>
    8000520c:	fec42783          	lw	a5,-20(s0)
    80005210:	078e                	slli	a5,a5,0x3
    80005212:	0d078793          	addi	a5,a5,208
    80005216:	953e                	add	a0,a0,a5
    80005218:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000521c:	fe043503          	ld	a0,-32(s0)
    80005220:	adaff0ef          	jal	800044fa <fileclose>
  return 0;
    80005224:	4781                	li	a5,0
}
    80005226:	853e                	mv	a0,a5
    80005228:	60e2                	ld	ra,24(sp)
    8000522a:	6442                	ld	s0,16(sp)
    8000522c:	6105                	addi	sp,sp,32
    8000522e:	8082                	ret

0000000080005230 <sys_fstat>:
{
    80005230:	1101                	addi	sp,sp,-32
    80005232:	ec06                	sd	ra,24(sp)
    80005234:	e822                	sd	s0,16(sp)
    80005236:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005238:	fe040593          	addi	a1,s0,-32
    8000523c:	4505                	li	a0,1
    8000523e:	eecfd0ef          	jal	8000292a <argaddr>
  if (argfd(0, 0, &f) < 0)
    80005242:	fe840613          	addi	a2,s0,-24
    80005246:	4581                	li	a1,0
    80005248:	4501                	li	a0,0
    8000524a:	cc9ff0ef          	jal	80004f12 <argfd>
    8000524e:	87aa                	mv	a5,a0
    return -1;
    80005250:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005252:	0007c863          	bltz	a5,80005262 <sys_fstat+0x32>
  return filestat(f, st);
    80005256:	fe043583          	ld	a1,-32(s0)
    8000525a:	fe843503          	ld	a0,-24(s0)
    8000525e:	b5eff0ef          	jal	800045bc <filestat>
}
    80005262:	60e2                	ld	ra,24(sp)
    80005264:	6442                	ld	s0,16(sp)
    80005266:	6105                	addi	sp,sp,32
    80005268:	8082                	ret

000000008000526a <sys_link>:
{
    8000526a:	7169                	addi	sp,sp,-304
    8000526c:	f606                	sd	ra,296(sp)
    8000526e:	f222                	sd	s0,288(sp)
    80005270:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005272:	08000613          	li	a2,128
    80005276:	ed040593          	addi	a1,s0,-304
    8000527a:	4501                	li	a0,0
    8000527c:	ecafd0ef          	jal	80002946 <argstr>
    return -1;
    80005280:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005282:	10054163          	bltz	a0,80005384 <sys_link+0x11a>
    80005286:	08000613          	li	a2,128
    8000528a:	f5040593          	addi	a1,s0,-176
    8000528e:	4505                	li	a0,1
    80005290:	eb6fd0ef          	jal	80002946 <argstr>
    return -1;
    80005294:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005296:	0e054763          	bltz	a0,80005384 <sys_link+0x11a>
    8000529a:	ee26                	sd	s1,280(sp)
  begin_op();
    8000529c:	da5fe0ef          	jal	80004040 <begin_op>
  if ((ip = namei(old)) == 0) {
    800052a0:	ed040513          	addi	a0,s0,-304
    800052a4:	bbffe0ef          	jal	80003e62 <namei>
    800052a8:	84aa                	mv	s1,a0
    800052aa:	cd35                	beqz	a0,80005326 <sys_link+0xbc>
  ilock(ip);
    800052ac:	b1cfe0ef          	jal	800035c8 <ilock>
  if (ip->type == T_DIR) {
    800052b0:	04449703          	lh	a4,68(s1)
    800052b4:	4785                	li	a5,1
    800052b6:	06f70d63          	beq	a4,a5,80005330 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    800052ba:	04a49783          	lh	a5,74(s1)
    800052be:	6721                	lui	a4,0x8
    800052c0:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    800052c2:	06e78f63          	beq	a5,a4,80005340 <sys_link+0xd6>
    800052c6:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800052c8:	2785                	addiw	a5,a5,1
    800052ca:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052ce:	8526                	mv	a0,s1
    800052d0:	a44fe0ef          	jal	80003514 <iupdate>
  iunlock(ip);
    800052d4:	8526                	mv	a0,s1
    800052d6:	ba0fe0ef          	jal	80003676 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    800052da:	fd040593          	addi	a1,s0,-48
    800052de:	f5040513          	addi	a0,s0,-176
    800052e2:	b9bfe0ef          	jal	80003e7c <nameiparent>
    800052e6:	892a                	mv	s2,a0
    800052e8:	c93d                	beqz	a0,8000535e <sys_link+0xf4>
  ilock(dp);
    800052ea:	adefe0ef          	jal	800035c8 <ilock>
  if (dp->nlink == 0) {
    800052ee:	04a91783          	lh	a5,74(s2)
    800052f2:	cfb9                	beqz	a5,80005350 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    800052f4:	854a                	mv	a0,s2
    800052f6:	00092703          	lw	a4,0(s2)
    800052fa:	409c                	lw	a5,0(s1)
    800052fc:	04f71e63          	bne	a4,a5,80005358 <sys_link+0xee>
    80005300:	40d0                	lw	a2,4(s1)
    80005302:	fd040593          	addi	a1,s0,-48
    80005306:	ab3fe0ef          	jal	80003db8 <dirlink>
    8000530a:	04054763          	bltz	a0,80005358 <sys_link+0xee>
  iunlockput(dp);
    8000530e:	854a                	mv	a0,s2
    80005310:	d0cfe0ef          	jal	8000381c <iunlockput>
  iput(ip);
    80005314:	8526                	mv	a0,s1
    80005316:	c34fe0ef          	jal	8000374a <iput>
  end_op();
    8000531a:	db3fe0ef          	jal	800040cc <end_op>
  return 0;
    8000531e:	4781                	li	a5,0
    80005320:	64f2                	ld	s1,280(sp)
    80005322:	6952                	ld	s2,272(sp)
    80005324:	a085                	j	80005384 <sys_link+0x11a>
    end_op();
    80005326:	da7fe0ef          	jal	800040cc <end_op>
    return -1;
    8000532a:	57fd                	li	a5,-1
    8000532c:	64f2                	ld	s1,280(sp)
    8000532e:	a899                	j	80005384 <sys_link+0x11a>
    iunlockput(ip);
    80005330:	8526                	mv	a0,s1
    80005332:	ceafe0ef          	jal	8000381c <iunlockput>
    end_op();
    80005336:	d97fe0ef          	jal	800040cc <end_op>
    return -1;
    8000533a:	57fd                	li	a5,-1
    8000533c:	64f2                	ld	s1,280(sp)
    8000533e:	a099                	j	80005384 <sys_link+0x11a>
    iunlockput(ip);
    80005340:	8526                	mv	a0,s1
    80005342:	cdafe0ef          	jal	8000381c <iunlockput>
    end_op();
    80005346:	d87fe0ef          	jal	800040cc <end_op>
    return -1;
    8000534a:	57fd                	li	a5,-1
    8000534c:	64f2                	ld	s1,280(sp)
    8000534e:	a81d                	j	80005384 <sys_link+0x11a>
    iunlockput(dp);
    80005350:	854a                	mv	a0,s2
    80005352:	ccafe0ef          	jal	8000381c <iunlockput>
    goto bad;
    80005356:	a021                	j	8000535e <sys_link+0xf4>
    iunlockput(dp);
    80005358:	854a                	mv	a0,s2
    8000535a:	cc2fe0ef          	jal	8000381c <iunlockput>
  ilock(ip);
    8000535e:	8526                	mv	a0,s1
    80005360:	a68fe0ef          	jal	800035c8 <ilock>
  ip->nlink--;
    80005364:	04a4d783          	lhu	a5,74(s1)
    80005368:	37fd                	addiw	a5,a5,-1
    8000536a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000536e:	8526                	mv	a0,s1
    80005370:	9a4fe0ef          	jal	80003514 <iupdate>
  iunlockput(ip);
    80005374:	8526                	mv	a0,s1
    80005376:	ca6fe0ef          	jal	8000381c <iunlockput>
  end_op();
    8000537a:	d53fe0ef          	jal	800040cc <end_op>
  return -1;
    8000537e:	57fd                	li	a5,-1
    80005380:	64f2                	ld	s1,280(sp)
    80005382:	6952                	ld	s2,272(sp)
}
    80005384:	853e                	mv	a0,a5
    80005386:	70b2                	ld	ra,296(sp)
    80005388:	7412                	ld	s0,288(sp)
    8000538a:	6155                	addi	sp,sp,304
    8000538c:	8082                	ret

000000008000538e <sys_unlink>:
{
    8000538e:	7151                	addi	sp,sp,-240
    80005390:	f586                	sd	ra,232(sp)
    80005392:	f1a2                	sd	s0,224(sp)
    80005394:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005396:	08000613          	li	a2,128
    8000539a:	f3040593          	addi	a1,s0,-208
    8000539e:	4501                	li	a0,0
    800053a0:	da6fd0ef          	jal	80002946 <argstr>
    800053a4:	14054d63          	bltz	a0,800054fe <sys_unlink+0x170>
    800053a8:	eda6                	sd	s1,216(sp)
  begin_op();
    800053aa:	c97fe0ef          	jal	80004040 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    800053ae:	fb040593          	addi	a1,s0,-80
    800053b2:	f3040513          	addi	a0,s0,-208
    800053b6:	ac7fe0ef          	jal	80003e7c <nameiparent>
    800053ba:	84aa                	mv	s1,a0
    800053bc:	c955                	beqz	a0,80005470 <sys_unlink+0xe2>
  ilock(dp);
    800053be:	a0afe0ef          	jal	800035c8 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800053c2:	00002597          	auipc	a1,0x2
    800053c6:	22e58593          	addi	a1,a1,558 # 800075f0 <etext+0x5f0>
    800053ca:	fb040513          	addi	a0,s0,-80
    800053ce:	fccfe0ef          	jal	80003b9a <namecmp>
    800053d2:	10050b63          	beqz	a0,800054e8 <sys_unlink+0x15a>
    800053d6:	00002597          	auipc	a1,0x2
    800053da:	22258593          	addi	a1,a1,546 # 800075f8 <etext+0x5f8>
    800053de:	fb040513          	addi	a0,s0,-80
    800053e2:	fb8fe0ef          	jal	80003b9a <namecmp>
    800053e6:	10050163          	beqz	a0,800054e8 <sys_unlink+0x15a>
    800053ea:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    800053ec:	f2c40613          	addi	a2,s0,-212
    800053f0:	fb040593          	addi	a1,s0,-80
    800053f4:	8526                	mv	a0,s1
    800053f6:	fbafe0ef          	jal	80003bb0 <dirlookup>
    800053fa:	892a                	mv	s2,a0
    800053fc:	0e050563          	beqz	a0,800054e6 <sys_unlink+0x158>
    80005400:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005402:	9c6fe0ef          	jal	800035c8 <ilock>
  if (ip->nlink < 1)
    80005406:	04a91783          	lh	a5,74(s2)
    8000540a:	06f05863          	blez	a5,8000547a <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    8000540e:	04491703          	lh	a4,68(s2)
    80005412:	4785                	li	a5,1
    80005414:	06f70963          	beq	a4,a5,80005486 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005418:	fc040993          	addi	s3,s0,-64
    8000541c:	4641                	li	a2,16
    8000541e:	4581                	li	a1,0
    80005420:	854e                	mv	a0,s3
    80005422:	8c7fb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005426:	4741                	li	a4,16
    80005428:	f2c42683          	lw	a3,-212(s0)
    8000542c:	864e                	mv	a2,s3
    8000542e:	4581                	li	a1,0
    80005430:	8526                	mv	a0,s1
    80005432:	e62fe0ef          	jal	80003a94 <writei>
    80005436:	47c1                	li	a5,16
    80005438:	08f51863          	bne	a0,a5,800054c8 <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    8000543c:	04491703          	lh	a4,68(s2)
    80005440:	4785                	li	a5,1
    80005442:	08f70963          	beq	a4,a5,800054d4 <sys_unlink+0x146>
  iunlockput(dp);
    80005446:	8526                	mv	a0,s1
    80005448:	bd4fe0ef          	jal	8000381c <iunlockput>
  ip->nlink--;
    8000544c:	04a95783          	lhu	a5,74(s2)
    80005450:	37fd                	addiw	a5,a5,-1
    80005452:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005456:	854a                	mv	a0,s2
    80005458:	8bcfe0ef          	jal	80003514 <iupdate>
  iunlockput(ip);
    8000545c:	854a                	mv	a0,s2
    8000545e:	bbefe0ef          	jal	8000381c <iunlockput>
  end_op();
    80005462:	c6bfe0ef          	jal	800040cc <end_op>
  return 0;
    80005466:	4501                	li	a0,0
    80005468:	64ee                	ld	s1,216(sp)
    8000546a:	694e                	ld	s2,208(sp)
    8000546c:	69ae                	ld	s3,200(sp)
    8000546e:	a061                	j	800054f6 <sys_unlink+0x168>
    end_op();
    80005470:	c5dfe0ef          	jal	800040cc <end_op>
    return -1;
    80005474:	557d                	li	a0,-1
    80005476:	64ee                	ld	s1,216(sp)
    80005478:	a8bd                	j	800054f6 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    8000547a:	00002517          	auipc	a0,0x2
    8000547e:	18650513          	addi	a0,a0,390 # 80007600 <etext+0x600>
    80005482:	bb2fb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005486:	04c92703          	lw	a4,76(s2)
    8000548a:	02000793          	li	a5,32
    8000548e:	f8e7f5e3          	bgeu	a5,a4,80005418 <sys_unlink+0x8a>
    80005492:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005494:	4741                	li	a4,16
    80005496:	86ce                	mv	a3,s3
    80005498:	f1840613          	addi	a2,s0,-232
    8000549c:	4581                	li	a1,0
    8000549e:	854a                	mv	a0,s2
    800054a0:	d02fe0ef          	jal	800039a2 <readi>
    800054a4:	47c1                	li	a5,16
    800054a6:	00f51b63          	bne	a0,a5,800054bc <sys_unlink+0x12e>
    if (de.inum != 0)
    800054aa:	f1845783          	lhu	a5,-232(s0)
    800054ae:	ebb1                	bnez	a5,80005502 <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800054b0:	29c1                	addiw	s3,s3,16
    800054b2:	04c92783          	lw	a5,76(s2)
    800054b6:	fcf9efe3          	bltu	s3,a5,80005494 <sys_unlink+0x106>
    800054ba:	bfb9                	j	80005418 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800054bc:	00002517          	auipc	a0,0x2
    800054c0:	15c50513          	addi	a0,a0,348 # 80007618 <etext+0x618>
    800054c4:	b70fb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    800054c8:	00002517          	auipc	a0,0x2
    800054cc:	16850513          	addi	a0,a0,360 # 80007630 <etext+0x630>
    800054d0:	b64fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    800054d4:	04a4d783          	lhu	a5,74(s1)
    800054d8:	37fd                	addiw	a5,a5,-1
    800054da:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054de:	8526                	mv	a0,s1
    800054e0:	834fe0ef          	jal	80003514 <iupdate>
    800054e4:	b78d                	j	80005446 <sys_unlink+0xb8>
    800054e6:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800054e8:	8526                	mv	a0,s1
    800054ea:	b32fe0ef          	jal	8000381c <iunlockput>
  end_op();
    800054ee:	bdffe0ef          	jal	800040cc <end_op>
  return -1;
    800054f2:	557d                	li	a0,-1
    800054f4:	64ee                	ld	s1,216(sp)
}
    800054f6:	70ae                	ld	ra,232(sp)
    800054f8:	740e                	ld	s0,224(sp)
    800054fa:	616d                	addi	sp,sp,240
    800054fc:	8082                	ret
    return -1;
    800054fe:	557d                	li	a0,-1
    80005500:	bfdd                	j	800054f6 <sys_unlink+0x168>
    iunlockput(ip);
    80005502:	854a                	mv	a0,s2
    80005504:	b18fe0ef          	jal	8000381c <iunlockput>
    goto bad;
    80005508:	694e                	ld	s2,208(sp)
    8000550a:	69ae                	ld	s3,200(sp)
    8000550c:	bff1                	j	800054e8 <sys_unlink+0x15a>

000000008000550e <sys_open>:

uint64
sys_open(void)
{
    8000550e:	7131                	addi	sp,sp,-192
    80005510:	fd06                	sd	ra,184(sp)
    80005512:	f922                	sd	s0,176(sp)
    80005514:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005516:	f4c40593          	addi	a1,s0,-180
    8000551a:	4505                	li	a0,1
    8000551c:	bf2fd0ef          	jal	8000290e <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005520:	08000613          	li	a2,128
    80005524:	f5040593          	addi	a1,s0,-176
    80005528:	4501                	li	a0,0
    8000552a:	c1cfd0ef          	jal	80002946 <argstr>
    8000552e:	87aa                	mv	a5,a0
    return -1;
    80005530:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005532:	0a07c363          	bltz	a5,800055d8 <sys_open+0xca>
    80005536:	f526                	sd	s1,168(sp)

  begin_op();
    80005538:	b09fe0ef          	jal	80004040 <begin_op>

  if (omode & O_CREATE) {
    8000553c:	f4c42783          	lw	a5,-180(s0)
    80005540:	2007f793          	andi	a5,a5,512
    80005544:	c3dd                	beqz	a5,800055ea <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005546:	4681                	li	a3,0
    80005548:	4601                	li	a2,0
    8000554a:	4589                	li	a1,2
    8000554c:	f5040513          	addi	a0,s0,-176
    80005550:	a5dff0ef          	jal	80004fac <create>
    80005554:	84aa                	mv	s1,a0
    if (ip == 0) {
    80005556:	c549                	beqz	a0,800055e0 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    80005558:	04449703          	lh	a4,68(s1)
    8000555c:	478d                	li	a5,3
    8000555e:	00f71763          	bne	a4,a5,8000556c <sys_open+0x5e>
    80005562:	0464d703          	lhu	a4,70(s1)
    80005566:	47a5                	li	a5,9
    80005568:	0ae7ee63          	bltu	a5,a4,80005624 <sys_open+0x116>
    8000556c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    8000556e:	ee9fe0ef          	jal	80004456 <filealloc>
    80005572:	892a                	mv	s2,a0
    80005574:	c561                	beqz	a0,8000563c <sys_open+0x12e>
    80005576:	ed4e                	sd	s3,152(sp)
    80005578:	9f5ff0ef          	jal	80004f6c <fdalloc>
    8000557c:	89aa                	mv	s3,a0
    8000557e:	0a054b63          	bltz	a0,80005634 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    80005582:	04449703          	lh	a4,68(s1)
    80005586:	478d                	li	a5,3
    80005588:	0cf70363          	beq	a4,a5,8000564e <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000558c:	4789                	li	a5,2
    8000558e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005592:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005596:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000559a:	f4c42783          	lw	a5,-180(s0)
    8000559e:	0017f713          	andi	a4,a5,1
    800055a2:	00174713          	xori	a4,a4,1
    800055a6:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800055aa:	0037f713          	andi	a4,a5,3
    800055ae:	00e03733          	snez	a4,a4
    800055b2:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    800055b6:	4007f793          	andi	a5,a5,1024
    800055ba:	c791                	beqz	a5,800055c6 <sys_open+0xb8>
    800055bc:	04449703          	lh	a4,68(s1)
    800055c0:	4789                	li	a5,2
    800055c2:	08f70d63          	beq	a4,a5,8000565c <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800055c6:	8526                	mv	a0,s1
    800055c8:	8aefe0ef          	jal	80003676 <iunlock>
  end_op();
    800055cc:	b01fe0ef          	jal	800040cc <end_op>

  return fd;
    800055d0:	854e                	mv	a0,s3
    800055d2:	74aa                	ld	s1,168(sp)
    800055d4:	790a                	ld	s2,160(sp)
    800055d6:	69ea                	ld	s3,152(sp)
}
    800055d8:	70ea                	ld	ra,184(sp)
    800055da:	744a                	ld	s0,176(sp)
    800055dc:	6129                	addi	sp,sp,192
    800055de:	8082                	ret
      end_op();
    800055e0:	aedfe0ef          	jal	800040cc <end_op>
      return -1;
    800055e4:	557d                	li	a0,-1
    800055e6:	74aa                	ld	s1,168(sp)
    800055e8:	bfc5                	j	800055d8 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    800055ea:	f5040513          	addi	a0,s0,-176
    800055ee:	875fe0ef          	jal	80003e62 <namei>
    800055f2:	84aa                	mv	s1,a0
    800055f4:	c11d                	beqz	a0,8000561a <sys_open+0x10c>
    ilock(ip);
    800055f6:	fd3fd0ef          	jal	800035c8 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    800055fa:	04449703          	lh	a4,68(s1)
    800055fe:	4785                	li	a5,1
    80005600:	f4f71ce3          	bne	a4,a5,80005558 <sys_open+0x4a>
    80005604:	f4c42783          	lw	a5,-180(s0)
    80005608:	d3b5                	beqz	a5,8000556c <sys_open+0x5e>
      iunlockput(ip);
    8000560a:	8526                	mv	a0,s1
    8000560c:	a10fe0ef          	jal	8000381c <iunlockput>
      end_op();
    80005610:	abdfe0ef          	jal	800040cc <end_op>
      return -1;
    80005614:	557d                	li	a0,-1
    80005616:	74aa                	ld	s1,168(sp)
    80005618:	b7c1                	j	800055d8 <sys_open+0xca>
      end_op();
    8000561a:	ab3fe0ef          	jal	800040cc <end_op>
      return -1;
    8000561e:	557d                	li	a0,-1
    80005620:	74aa                	ld	s1,168(sp)
    80005622:	bf5d                	j	800055d8 <sys_open+0xca>
    iunlockput(ip);
    80005624:	8526                	mv	a0,s1
    80005626:	9f6fe0ef          	jal	8000381c <iunlockput>
    end_op();
    8000562a:	aa3fe0ef          	jal	800040cc <end_op>
    return -1;
    8000562e:	557d                	li	a0,-1
    80005630:	74aa                	ld	s1,168(sp)
    80005632:	b75d                	j	800055d8 <sys_open+0xca>
      fileclose(f);
    80005634:	854a                	mv	a0,s2
    80005636:	ec5fe0ef          	jal	800044fa <fileclose>
    8000563a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000563c:	8526                	mv	a0,s1
    8000563e:	9defe0ef          	jal	8000381c <iunlockput>
    end_op();
    80005642:	a8bfe0ef          	jal	800040cc <end_op>
    return -1;
    80005646:	557d                	li	a0,-1
    80005648:	74aa                	ld	s1,168(sp)
    8000564a:	790a                	ld	s2,160(sp)
    8000564c:	b771                	j	800055d8 <sys_open+0xca>
    f->type = FD_DEVICE;
    8000564e:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005652:	04649783          	lh	a5,70(s1)
    80005656:	02f91223          	sh	a5,36(s2)
    8000565a:	bf35                	j	80005596 <sys_open+0x88>
    itrunc(ip);
    8000565c:	8526                	mv	a0,s1
    8000565e:	858fe0ef          	jal	800036b6 <itrunc>
    80005662:	b795                	j	800055c6 <sys_open+0xb8>

0000000080005664 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005664:	7175                	addi	sp,sp,-144
    80005666:	e506                	sd	ra,136(sp)
    80005668:	e122                	sd	s0,128(sp)
    8000566a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000566c:	9d5fe0ef          	jal	80004040 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    80005670:	08000613          	li	a2,128
    80005674:	f7040593          	addi	a1,s0,-144
    80005678:	4501                	li	a0,0
    8000567a:	accfd0ef          	jal	80002946 <argstr>
    8000567e:	02054363          	bltz	a0,800056a4 <sys_mkdir+0x40>
    80005682:	4681                	li	a3,0
    80005684:	4601                	li	a2,0
    80005686:	4585                	li	a1,1
    80005688:	f7040513          	addi	a0,s0,-144
    8000568c:	921ff0ef          	jal	80004fac <create>
    80005690:	c911                	beqz	a0,800056a4 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005692:	98afe0ef          	jal	8000381c <iunlockput>
  end_op();
    80005696:	a37fe0ef          	jal	800040cc <end_op>
  return 0;
    8000569a:	4501                	li	a0,0
}
    8000569c:	60aa                	ld	ra,136(sp)
    8000569e:	640a                	ld	s0,128(sp)
    800056a0:	6149                	addi	sp,sp,144
    800056a2:	8082                	ret
    end_op();
    800056a4:	a29fe0ef          	jal	800040cc <end_op>
    return -1;
    800056a8:	557d                	li	a0,-1
    800056aa:	bfcd                	j	8000569c <sys_mkdir+0x38>

00000000800056ac <sys_mknod>:

uint64
sys_mknod(void)
{
    800056ac:	7135                	addi	sp,sp,-160
    800056ae:	ed06                	sd	ra,152(sp)
    800056b0:	e922                	sd	s0,144(sp)
    800056b2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800056b4:	98dfe0ef          	jal	80004040 <begin_op>
  argint(1, &major);
    800056b8:	f6c40593          	addi	a1,s0,-148
    800056bc:	4505                	li	a0,1
    800056be:	a50fd0ef          	jal	8000290e <argint>
  argint(2, &minor);
    800056c2:	f6840593          	addi	a1,s0,-152
    800056c6:	4509                	li	a0,2
    800056c8:	a46fd0ef          	jal	8000290e <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800056cc:	08000613          	li	a2,128
    800056d0:	f7040593          	addi	a1,s0,-144
    800056d4:	4501                	li	a0,0
    800056d6:	a70fd0ef          	jal	80002946 <argstr>
    800056da:	02054563          	bltz	a0,80005704 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    800056de:	f6841683          	lh	a3,-152(s0)
    800056e2:	f6c41603          	lh	a2,-148(s0)
    800056e6:	458d                	li	a1,3
    800056e8:	f7040513          	addi	a0,s0,-144
    800056ec:	8c1ff0ef          	jal	80004fac <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800056f0:	c911                	beqz	a0,80005704 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800056f2:	92afe0ef          	jal	8000381c <iunlockput>
  end_op();
    800056f6:	9d7fe0ef          	jal	800040cc <end_op>
  return 0;
    800056fa:	4501                	li	a0,0
}
    800056fc:	60ea                	ld	ra,152(sp)
    800056fe:	644a                	ld	s0,144(sp)
    80005700:	610d                	addi	sp,sp,160
    80005702:	8082                	ret
    end_op();
    80005704:	9c9fe0ef          	jal	800040cc <end_op>
    return -1;
    80005708:	557d                	li	a0,-1
    8000570a:	bfcd                	j	800056fc <sys_mknod+0x50>

000000008000570c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000570c:	7135                	addi	sp,sp,-160
    8000570e:	ed06                	sd	ra,152(sp)
    80005710:	e922                	sd	s0,144(sp)
    80005712:	e14a                	sd	s2,128(sp)
    80005714:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005716:	a3afc0ef          	jal	80001950 <myproc>
    8000571a:	892a                	mv	s2,a0

  begin_op();
    8000571c:	925fe0ef          	jal	80004040 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    80005720:	08000613          	li	a2,128
    80005724:	f6040593          	addi	a1,s0,-160
    80005728:	4501                	li	a0,0
    8000572a:	a1cfd0ef          	jal	80002946 <argstr>
    8000572e:	04054363          	bltz	a0,80005774 <sys_chdir+0x68>
    80005732:	e526                	sd	s1,136(sp)
    80005734:	f6040513          	addi	a0,s0,-160
    80005738:	f2afe0ef          	jal	80003e62 <namei>
    8000573c:	84aa                	mv	s1,a0
    8000573e:	c915                	beqz	a0,80005772 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005740:	e89fd0ef          	jal	800035c8 <ilock>
  if (ip->type != T_DIR) {
    80005744:	04449703          	lh	a4,68(s1)
    80005748:	4785                	li	a5,1
    8000574a:	02f71963          	bne	a4,a5,8000577c <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000574e:	8526                	mv	a0,s1
    80005750:	f27fd0ef          	jal	80003676 <iunlock>
  iput(p->cwd);
    80005754:	15093503          	ld	a0,336(s2)
    80005758:	ff3fd0ef          	jal	8000374a <iput>
  end_op();
    8000575c:	971fe0ef          	jal	800040cc <end_op>
  p->cwd = ip;
    80005760:	14993823          	sd	s1,336(s2)
  return 0;
    80005764:	4501                	li	a0,0
    80005766:	64aa                	ld	s1,136(sp)
}
    80005768:	60ea                	ld	ra,152(sp)
    8000576a:	644a                	ld	s0,144(sp)
    8000576c:	690a                	ld	s2,128(sp)
    8000576e:	610d                	addi	sp,sp,160
    80005770:	8082                	ret
    80005772:	64aa                	ld	s1,136(sp)
    end_op();
    80005774:	959fe0ef          	jal	800040cc <end_op>
    return -1;
    80005778:	557d                	li	a0,-1
    8000577a:	b7fd                	j	80005768 <sys_chdir+0x5c>
    iunlockput(ip);
    8000577c:	8526                	mv	a0,s1
    8000577e:	89efe0ef          	jal	8000381c <iunlockput>
    end_op();
    80005782:	94bfe0ef          	jal	800040cc <end_op>
    return -1;
    80005786:	557d                	li	a0,-1
    80005788:	64aa                	ld	s1,136(sp)
    8000578a:	bff9                	j	80005768 <sys_chdir+0x5c>

000000008000578c <sys_exec>:

uint64
sys_exec(void)
{
    8000578c:	7105                	addi	sp,sp,-480
    8000578e:	ef86                	sd	ra,472(sp)
    80005790:	eba2                	sd	s0,464(sp)
    80005792:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005794:	e2840593          	addi	a1,s0,-472
    80005798:	4505                	li	a0,1
    8000579a:	990fd0ef          	jal	8000292a <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    8000579e:	08000613          	li	a2,128
    800057a2:	f3040593          	addi	a1,s0,-208
    800057a6:	4501                	li	a0,0
    800057a8:	99efd0ef          	jal	80002946 <argstr>
    800057ac:	87aa                	mv	a5,a0
    return -1;
    800057ae:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    800057b0:	0e07c063          	bltz	a5,80005890 <sys_exec+0x104>
    800057b4:	e7a6                	sd	s1,456(sp)
    800057b6:	e3ca                	sd	s2,448(sp)
    800057b8:	ff4e                	sd	s3,440(sp)
    800057ba:	fb52                	sd	s4,432(sp)
    800057bc:	f756                	sd	s5,424(sp)
    800057be:	f35a                	sd	s6,416(sp)
    800057c0:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800057c2:	e3040a13          	addi	s4,s0,-464
    800057c6:	10000613          	li	a2,256
    800057ca:	4581                	li	a1,0
    800057cc:	8552                	mv	a0,s4
    800057ce:	d1afb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    800057d2:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800057d4:	89d2                	mv	s3,s4
    800057d6:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800057d8:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800057dc:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    800057de:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800057e2:	00391513          	slli	a0,s2,0x3
    800057e6:	85d6                	mv	a1,s5
    800057e8:	e2843783          	ld	a5,-472(s0)
    800057ec:	953e                	add	a0,a0,a5
    800057ee:	894fd0ef          	jal	80002882 <fetchaddr>
    800057f2:	02054663          	bltz	a0,8000581e <sys_exec+0x92>
    if (uarg == 0) {
    800057f6:	e2043783          	ld	a5,-480(s0)
    800057fa:	c7a1                	beqz	a5,80005842 <sys_exec+0xb6>
    argv[i] = kalloc();
    800057fc:	b52fb0ef          	jal	80000b4e <kalloc>
    80005800:	85aa                	mv	a1,a0
    80005802:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005806:	cd01                	beqz	a0,8000581e <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005808:	865a                	mv	a2,s6
    8000580a:	e2043503          	ld	a0,-480(s0)
    8000580e:	8befd0ef          	jal	800028cc <fetchstr>
    80005812:	00054663          	bltz	a0,8000581e <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    80005816:	0905                	addi	s2,s2,1
    80005818:	09a1                	addi	s3,s3,8
    8000581a:	fd7914e3          	bne	s2,s7,800057e2 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000581e:	100a0a13          	addi	s4,s4,256
    80005822:	6088                	ld	a0,0(s1)
    80005824:	cd31                	beqz	a0,80005880 <sys_exec+0xf4>
    kfree(argv[i]);
    80005826:	a40fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000582a:	04a1                	addi	s1,s1,8
    8000582c:	ff449be3          	bne	s1,s4,80005822 <sys_exec+0x96>
  return -1;
    80005830:	557d                	li	a0,-1
    80005832:	64be                	ld	s1,456(sp)
    80005834:	691e                	ld	s2,448(sp)
    80005836:	79fa                	ld	s3,440(sp)
    80005838:	7a5a                	ld	s4,432(sp)
    8000583a:	7aba                	ld	s5,424(sp)
    8000583c:	7b1a                	ld	s6,416(sp)
    8000583e:	6bfa                	ld	s7,408(sp)
    80005840:	a881                	j	80005890 <sys_exec+0x104>
      argv[i] = 0;
    80005842:	0009079b          	sext.w	a5,s2
    80005846:	e3040593          	addi	a1,s0,-464
    8000584a:	078e                	slli	a5,a5,0x3
    8000584c:	97ae                	add	a5,a5,a1
    8000584e:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005852:	f3040513          	addi	a0,s0,-208
    80005856:	b62ff0ef          	jal	80004bb8 <kexec>
    8000585a:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000585c:	100a0a13          	addi	s4,s4,256
    80005860:	6088                	ld	a0,0(s1)
    80005862:	c511                	beqz	a0,8000586e <sys_exec+0xe2>
    kfree(argv[i]);
    80005864:	a02fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005868:	04a1                	addi	s1,s1,8
    8000586a:	ff449be3          	bne	s1,s4,80005860 <sys_exec+0xd4>
  return ret;
    8000586e:	854a                	mv	a0,s2
    80005870:	64be                	ld	s1,456(sp)
    80005872:	691e                	ld	s2,448(sp)
    80005874:	79fa                	ld	s3,440(sp)
    80005876:	7a5a                	ld	s4,432(sp)
    80005878:	7aba                	ld	s5,424(sp)
    8000587a:	7b1a                	ld	s6,416(sp)
    8000587c:	6bfa                	ld	s7,408(sp)
    8000587e:	a809                	j	80005890 <sys_exec+0x104>
  return -1;
    80005880:	557d                	li	a0,-1
    80005882:	64be                	ld	s1,456(sp)
    80005884:	691e                	ld	s2,448(sp)
    80005886:	79fa                	ld	s3,440(sp)
    80005888:	7a5a                	ld	s4,432(sp)
    8000588a:	7aba                	ld	s5,424(sp)
    8000588c:	7b1a                	ld	s6,416(sp)
    8000588e:	6bfa                	ld	s7,408(sp)
}
    80005890:	60fe                	ld	ra,472(sp)
    80005892:	645e                	ld	s0,464(sp)
    80005894:	613d                	addi	sp,sp,480
    80005896:	8082                	ret

0000000080005898 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005898:	7139                	addi	sp,sp,-64
    8000589a:	fc06                	sd	ra,56(sp)
    8000589c:	f822                	sd	s0,48(sp)
    8000589e:	f426                	sd	s1,40(sp)
    800058a0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800058a2:	8aefc0ef          	jal	80001950 <myproc>
    800058a6:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800058a8:	fd840593          	addi	a1,s0,-40
    800058ac:	4501                	li	a0,0
    800058ae:	87cfd0ef          	jal	8000292a <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    800058b2:	fc840593          	addi	a1,s0,-56
    800058b6:	fd040513          	addi	a0,s0,-48
    800058ba:	f7ffe0ef          	jal	80004838 <pipealloc>
    return -1;
    800058be:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    800058c0:	0a054963          	bltz	a0,80005972 <sys_pipe+0xda>
  fd0 = -1;
    800058c4:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    800058c8:	fd043503          	ld	a0,-48(s0)
    800058cc:	ea0ff0ef          	jal	80004f6c <fdalloc>
    800058d0:	fca42223          	sw	a0,-60(s0)
    800058d4:	08054663          	bltz	a0,80005960 <sys_pipe+0xc8>
    800058d8:	fc843503          	ld	a0,-56(s0)
    800058dc:	e90ff0ef          	jal	80004f6c <fdalloc>
    800058e0:	fca42023          	sw	a0,-64(s0)
    800058e4:	06054463          	bltz	a0,8000594c <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800058e8:	4711                	li	a4,4
    800058ea:	fc440693          	addi	a3,s0,-60
    800058ee:	fd843603          	ld	a2,-40(s0)
    800058f2:	64ac                	ld	a1,72(s1)
    800058f4:	68a8                	ld	a0,80(s1)
    800058f6:	c95fb0ef          	jal	8000158a <copyout>
    800058fa:	00054f63          	bltz	a0,80005918 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    800058fe:	4711                	li	a4,4
    80005900:	fc040693          	addi	a3,s0,-64
    80005904:	fd843603          	ld	a2,-40(s0)
    80005908:	963a                	add	a2,a2,a4
    8000590a:	64ac                	ld	a1,72(s1)
    8000590c:	68a8                	ld	a0,80(s1)
    8000590e:	c7dfb0ef          	jal	8000158a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005912:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005914:	04055f63          	bgez	a0,80005972 <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    80005918:	fc442783          	lw	a5,-60(s0)
    8000591c:	078e                	slli	a5,a5,0x3
    8000591e:	0d078793          	addi	a5,a5,208
    80005922:	97a6                	add	a5,a5,s1
    80005924:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005928:	fc042783          	lw	a5,-64(s0)
    8000592c:	078e                	slli	a5,a5,0x3
    8000592e:	0d078793          	addi	a5,a5,208
    80005932:	94be                	add	s1,s1,a5
    80005934:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005938:	fd043503          	ld	a0,-48(s0)
    8000593c:	bbffe0ef          	jal	800044fa <fileclose>
    fileclose(wf);
    80005940:	fc843503          	ld	a0,-56(s0)
    80005944:	bb7fe0ef          	jal	800044fa <fileclose>
    return -1;
    80005948:	57fd                	li	a5,-1
    8000594a:	a025                	j	80005972 <sys_pipe+0xda>
    if (fd0 >= 0)
    8000594c:	fc442783          	lw	a5,-60(s0)
    80005950:	0007c863          	bltz	a5,80005960 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    80005954:	078e                	slli	a5,a5,0x3
    80005956:	0d078793          	addi	a5,a5,208
    8000595a:	97a6                	add	a5,a5,s1
    8000595c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005960:	fd043503          	ld	a0,-48(s0)
    80005964:	b97fe0ef          	jal	800044fa <fileclose>
    fileclose(wf);
    80005968:	fc843503          	ld	a0,-56(s0)
    8000596c:	b8ffe0ef          	jal	800044fa <fileclose>
    return -1;
    80005970:	57fd                	li	a5,-1
}
    80005972:	853e                	mv	a0,a5
    80005974:	70e2                	ld	ra,56(sp)
    80005976:	7442                	ld	s0,48(sp)
    80005978:	74a2                	ld	s1,40(sp)
    8000597a:	6121                	addi	sp,sp,64
    8000597c:	8082                	ret
	...

0000000080005980 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005980:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005982:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005984:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005986:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005988:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000598a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000598c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000598e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005990:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005992:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005994:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005996:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005998:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000599a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000599c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000599e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800059a0:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800059a2:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800059a4:	dedfc0ef          	jal	80002790 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800059a8:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800059aa:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800059ac:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800059ae:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800059b0:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800059b2:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800059b4:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800059b6:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800059b8:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800059ba:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800059bc:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800059be:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800059c0:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800059c2:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800059c4:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800059c6:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800059c8:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800059ca:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800059cc:	10200073          	sret
    800059d0:	0001                	nop
    800059d2:	00000013          	nop
    800059d6:	00000013          	nop
    800059da:	00000013          	nop

00000000800059de <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800059de:	1141                	addi	sp,sp,-16
    800059e0:	e406                	sd	ra,8(sp)
    800059e2:	e022                	sd	s0,0(sp)
    800059e4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    800059e6:	0c000737          	lui	a4,0xc000
    800059ea:	4785                	li	a5,1
    800059ec:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    800059ee:	c35c                	sw	a5,4(a4)
}
    800059f0:	60a2                	ld	ra,8(sp)
    800059f2:	6402                	ld	s0,0(sp)
    800059f4:	0141                	addi	sp,sp,16
    800059f6:	8082                	ret

00000000800059f8 <plicinithart>:

void
plicinithart(void)
{
    800059f8:	1141                	addi	sp,sp,-16
    800059fa:	e406                	sd	ra,8(sp)
    800059fc:	e022                	sd	s0,0(sp)
    800059fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005a00:	f1dfb0ef          	jal	8000191c <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    80005a04:	0085179b          	slliw	a5,a0,0x8
    80005a08:	0c002737          	lui	a4,0xc002
    80005a0c:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    80005a10:	97ba                	add	a5,a5,a4
    80005a12:	40200713          	li	a4,1026
    80005a16:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005a18:	00d5151b          	slliw	a0,a0,0xd
    80005a1c:	0c2017b7          	lui	a5,0xc201
    80005a20:	953e                	add	a0,a0,a5
    80005a22:	00052023          	sw	zero,0(a0)
}
    80005a26:	60a2                	ld	ra,8(sp)
    80005a28:	6402                	ld	s0,0(sp)
    80005a2a:	0141                	addi	sp,sp,16
    80005a2c:	8082                	ret

0000000080005a2e <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005a2e:	1141                	addi	sp,sp,-16
    80005a30:	e406                	sd	ra,8(sp)
    80005a32:	e022                	sd	s0,0(sp)
    80005a34:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005a36:	ee7fb0ef          	jal	8000191c <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    80005a3a:	00d5151b          	slliw	a0,a0,0xd
    80005a3e:	0c2017b7          	lui	a5,0xc201
    80005a42:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80005a44:	953e                	add	a0,a0,a5
    80005a46:	4108                	lw	a0,0(a0)
  return irq;
}
    80005a48:	60a2                	ld	ra,8(sp)
    80005a4a:	6402                	ld	s0,0(sp)
    80005a4c:	0141                	addi	sp,sp,16
    80005a4e:	8082                	ret

0000000080005a50 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005a50:	1101                	addi	sp,sp,-32
    80005a52:	ec06                	sd	ra,24(sp)
    80005a54:	e822                	sd	s0,16(sp)
    80005a56:	e426                	sd	s1,8(sp)
    80005a58:	1000                	addi	s0,sp,32
    80005a5a:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005a5c:	ec1fb0ef          	jal	8000191c <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    80005a60:	00d5179b          	slliw	a5,a0,0xd
    80005a64:	0c201737          	lui	a4,0xc201
    80005a68:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    80005a6a:	97ba                	add	a5,a5,a4
    80005a6c:	c384                	sw	s1,0(a5)
}
    80005a6e:	60e2                	ld	ra,24(sp)
    80005a70:	6442                	ld	s0,16(sp)
    80005a72:	64a2                	ld	s1,8(sp)
    80005a74:	6105                	addi	sp,sp,32
    80005a76:	8082                	ret

0000000080005a78 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005a78:	1141                	addi	sp,sp,-16
    80005a7a:	e406                	sd	ra,8(sp)
    80005a7c:	e022                	sd	s0,0(sp)
    80005a7e:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005a80:	479d                	li	a5,7
    80005a82:	04a7ca63          	blt	a5,a0,80005ad6 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005a86:	0001e797          	auipc	a5,0x1e
    80005a8a:	05a78793          	addi	a5,a5,90 # 80023ae0 <disk>
    80005a8e:	97aa                	add	a5,a5,a0
    80005a90:	0187c783          	lbu	a5,24(a5)
    80005a94:	e7b9                	bnez	a5,80005ae2 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005a96:	00451693          	slli	a3,a0,0x4
    80005a9a:	0001e797          	auipc	a5,0x1e
    80005a9e:	04678793          	addi	a5,a5,70 # 80023ae0 <disk>
    80005aa2:	6398                	ld	a4,0(a5)
    80005aa4:	9736                	add	a4,a4,a3
    80005aa6:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005aaa:	6398                	ld	a4,0(a5)
    80005aac:	9736                	add	a4,a4,a3
    80005aae:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005ab2:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005ab6:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005aba:	97aa                	add	a5,a5,a0
    80005abc:	4705                	li	a4,1
    80005abe:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005ac2:	0001e517          	auipc	a0,0x1e
    80005ac6:	03650513          	addi	a0,a0,54 # 80023af8 <disk+0x18>
    80005aca:	d72fc0ef          	jal	8000203c <wakeup>
}
    80005ace:	60a2                	ld	ra,8(sp)
    80005ad0:	6402                	ld	s0,0(sp)
    80005ad2:	0141                	addi	sp,sp,16
    80005ad4:	8082                	ret
    panic("free_desc 1");
    80005ad6:	00002517          	auipc	a0,0x2
    80005ada:	b6a50513          	addi	a0,a0,-1174 # 80007640 <etext+0x640>
    80005ade:	d57fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    80005ae2:	00002517          	auipc	a0,0x2
    80005ae6:	b6e50513          	addi	a0,a0,-1170 # 80007650 <etext+0x650>
    80005aea:	d4bfa0ef          	jal	80000834 <panic>

0000000080005aee <virtio_disk_init>:
{
    80005aee:	1101                	addi	sp,sp,-32
    80005af0:	ec06                	sd	ra,24(sp)
    80005af2:	e822                	sd	s0,16(sp)
    80005af4:	e426                	sd	s1,8(sp)
    80005af6:	e04a                	sd	s2,0(sp)
    80005af8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005afa:	00002597          	auipc	a1,0x2
    80005afe:	b6658593          	addi	a1,a1,-1178 # 80007660 <etext+0x660>
    80005b02:	0001e517          	auipc	a0,0x1e
    80005b06:	10650513          	addi	a0,a0,262 # 80023c08 <disk+0x128>
    80005b0a:	89efb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005b0e:	100017b7          	lui	a5,0x10001
    80005b12:	4398                	lw	a4,0(a5)
    80005b14:	2701                	sext.w	a4,a4
    80005b16:	747277b7          	lui	a5,0x74727
    80005b1a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005b1e:	14f71863          	bne	a4,a5,80005c6e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b22:	100017b7          	lui	a5,0x10001
    80005b26:	43dc                	lw	a5,4(a5)
    80005b28:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005b2a:	4709                	li	a4,2
    80005b2c:	14e79163          	bne	a5,a4,80005c6e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b30:	100017b7          	lui	a5,0x10001
    80005b34:	479c                	lw	a5,8(a5)
    80005b36:	2781                	sext.w	a5,a5
    80005b38:	12e79b63          	bne	a5,a4,80005c6e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    80005b3c:	100017b7          	lui	a5,0x10001
    80005b40:	47d8                	lw	a4,12(a5)
    80005b42:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b44:	554d47b7          	lui	a5,0x554d4
    80005b48:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005b4c:	12f71163          	bne	a4,a5,80005c6e <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b50:	100017b7          	lui	a5,0x10001
    80005b54:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b58:	4705                	li	a4,1
    80005b5a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b5c:	470d                	li	a4,3
    80005b5e:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005b60:	10001737          	lui	a4,0x10001
    80005b64:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005b66:	c7ffe6b7          	lui	a3,0xc7ffe
    80005b6a:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fda93f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005b6e:	8f75                	and	a4,a4,a3
    80005b70:	100016b7          	lui	a3,0x10001
    80005b74:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b76:	472d                	li	a4,11
    80005b78:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b7a:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005b7e:	439c                	lw	a5,0(a5)
    80005b80:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005b84:	8ba1                	andi	a5,a5,8
    80005b86:	0e078a63          	beqz	a5,80005c7a <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005b8a:	100017b7          	lui	a5,0x10001
    80005b8e:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005b92:	43fc                	lw	a5,68(a5)
    80005b94:	2781                	sext.w	a5,a5
    80005b96:	0e079863          	bnez	a5,80005c86 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005b9a:	100017b7          	lui	a5,0x10001
    80005b9e:	5bdc                	lw	a5,52(a5)
    80005ba0:	2781                	sext.w	a5,a5
  if (max == 0)
    80005ba2:	0e078863          	beqz	a5,80005c92 <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005ba6:	471d                	li	a4,7
    80005ba8:	0ef77b63          	bgeu	a4,a5,80005c9e <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005bac:	fa3fa0ef          	jal	80000b4e <kalloc>
    80005bb0:	0001e497          	auipc	s1,0x1e
    80005bb4:	f3048493          	addi	s1,s1,-208 # 80023ae0 <disk>
    80005bb8:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005bba:	f95fa0ef          	jal	80000b4e <kalloc>
    80005bbe:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005bc0:	f8ffa0ef          	jal	80000b4e <kalloc>
    80005bc4:	87aa                	mv	a5,a0
    80005bc6:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005bc8:	6088                	ld	a0,0(s1)
    80005bca:	0e050063          	beqz	a0,80005caa <virtio_disk_init+0x1bc>
    80005bce:	0001e717          	auipc	a4,0x1e
    80005bd2:	f1a73703          	ld	a4,-230(a4) # 80023ae8 <disk+0x8>
    80005bd6:	cb71                	beqz	a4,80005caa <virtio_disk_init+0x1bc>
    80005bd8:	cbe9                	beqz	a5,80005caa <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005bda:	6605                	lui	a2,0x1
    80005bdc:	4581                	li	a1,0
    80005bde:	90afb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005be2:	0001e497          	auipc	s1,0x1e
    80005be6:	efe48493          	addi	s1,s1,-258 # 80023ae0 <disk>
    80005bea:	6605                	lui	a2,0x1
    80005bec:	4581                	li	a1,0
    80005bee:	6488                	ld	a0,8(s1)
    80005bf0:	8f8fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005bf4:	6605                	lui	a2,0x1
    80005bf6:	4581                	li	a1,0
    80005bf8:	6888                	ld	a0,16(s1)
    80005bfa:	8eefb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005bfe:	100017b7          	lui	a5,0x10001
    80005c02:	4721                	li	a4,8
    80005c04:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005c06:	4098                	lw	a4,0(s1)
    80005c08:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005c0c:	40d8                	lw	a4,4(s1)
    80005c0e:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005c12:	649c                	ld	a5,8(s1)
    80005c14:	0007869b          	sext.w	a3,a5
    80005c18:	10001737          	lui	a4,0x10001
    80005c1c:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005c20:	9781                	srai	a5,a5,0x20
    80005c22:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005c26:	689c                	ld	a5,16(s1)
    80005c28:	0007869b          	sext.w	a3,a5
    80005c2c:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005c30:	9781                	srai	a5,a5,0x20
    80005c32:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005c36:	4785                	li	a5,1
    80005c38:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005c3a:	00f48c23          	sb	a5,24(s1)
    80005c3e:	00f48ca3          	sb	a5,25(s1)
    80005c42:	00f48d23          	sb	a5,26(s1)
    80005c46:	00f48da3          	sb	a5,27(s1)
    80005c4a:	00f48e23          	sb	a5,28(s1)
    80005c4e:	00f48ea3          	sb	a5,29(s1)
    80005c52:	00f48f23          	sb	a5,30(s1)
    80005c56:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005c5a:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c5e:	07272823          	sw	s2,112(a4)
}
    80005c62:	60e2                	ld	ra,24(sp)
    80005c64:	6442                	ld	s0,16(sp)
    80005c66:	64a2                	ld	s1,8(sp)
    80005c68:	6902                	ld	s2,0(sp)
    80005c6a:	6105                	addi	sp,sp,32
    80005c6c:	8082                	ret
    panic("could not find virtio disk");
    80005c6e:	00002517          	auipc	a0,0x2
    80005c72:	a0250513          	addi	a0,a0,-1534 # 80007670 <etext+0x670>
    80005c76:	bbffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005c7a:	00002517          	auipc	a0,0x2
    80005c7e:	a1650513          	addi	a0,a0,-1514 # 80007690 <etext+0x690>
    80005c82:	bb3fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005c86:	00002517          	auipc	a0,0x2
    80005c8a:	a2a50513          	addi	a0,a0,-1494 # 800076b0 <etext+0x6b0>
    80005c8e:	ba7fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005c92:	00002517          	auipc	a0,0x2
    80005c96:	a3e50513          	addi	a0,a0,-1474 # 800076d0 <etext+0x6d0>
    80005c9a:	b9bfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005c9e:	00002517          	auipc	a0,0x2
    80005ca2:	a5250513          	addi	a0,a0,-1454 # 800076f0 <etext+0x6f0>
    80005ca6:	b8ffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005caa:	00002517          	auipc	a0,0x2
    80005cae:	a6650513          	addi	a0,a0,-1434 # 80007710 <etext+0x710>
    80005cb2:	b83fa0ef          	jal	80000834 <panic>

0000000080005cb6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005cb6:	711d                	addi	sp,sp,-96
    80005cb8:	ec86                	sd	ra,88(sp)
    80005cba:	e8a2                	sd	s0,80(sp)
    80005cbc:	e4a6                	sd	s1,72(sp)
    80005cbe:	e0ca                	sd	s2,64(sp)
    80005cc0:	fc4e                	sd	s3,56(sp)
    80005cc2:	f852                	sd	s4,48(sp)
    80005cc4:	f456                	sd	s5,40(sp)
    80005cc6:	f05a                	sd	s6,32(sp)
    80005cc8:	ec5e                	sd	s7,24(sp)
    80005cca:	e862                	sd	s8,16(sp)
    80005ccc:	1080                	addi	s0,sp,96
    80005cce:	89aa                	mv	s3,a0
    80005cd0:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005cd2:	00c52b83          	lw	s7,12(a0)
    80005cd6:	001b9b9b          	slliw	s7,s7,0x1
    80005cda:	1b82                	slli	s7,s7,0x20
    80005cdc:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005ce0:	0001e517          	auipc	a0,0x1e
    80005ce4:	f2850513          	addi	a0,a0,-216 # 80023c08 <disk+0x128>
    80005ce8:	f41fa0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005cec:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005cee:	0001ea97          	auipc	s5,0x1e
    80005cf2:	df2a8a93          	addi	s5,s5,-526 # 80023ae0 <disk>
  for (int i = 0; i < 3; i++) {
    80005cf6:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005cf8:	5c7d                	li	s8,-1
    80005cfa:	a8a5                	j	80005d72 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005cfc:	00fa8733          	add	a4,s5,a5
    80005d00:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005d04:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005d06:	0207c563          	bltz	a5,80005d30 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005d0a:	2905                	addiw	s2,s2,1
    80005d0c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005d0e:	07490663          	beq	s2,s4,80005d7a <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005d12:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005d14:	0001e717          	auipc	a4,0x1e
    80005d18:	dcc70713          	addi	a4,a4,-564 # 80023ae0 <disk>
    80005d1c:	4781                	li	a5,0
    if (disk.free[i]) {
    80005d1e:	01874683          	lbu	a3,24(a4)
    80005d22:	fee9                	bnez	a3,80005cfc <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005d24:	2785                	addiw	a5,a5,1
    80005d26:	0705                	addi	a4,a4,1
    80005d28:	fe979be3          	bne	a5,s1,80005d1e <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005d2c:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005d30:	01205d63          	blez	s2,80005d4a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005d34:	fa042503          	lw	a0,-96(s0)
    80005d38:	d41ff0ef          	jal	80005a78 <free_desc>
      for (int j = 0; j < i; j++)
    80005d3c:	4785                	li	a5,1
    80005d3e:	0127d663          	bge	a5,s2,80005d4a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005d42:	fa442503          	lw	a0,-92(s0)
    80005d46:	d33ff0ef          	jal	80005a78 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005d4a:	0001e517          	auipc	a0,0x1e
    80005d4e:	dae50513          	addi	a0,a0,-594 # 80023af8 <disk+0x18>
    80005d52:	a7efc0ef          	jal	80001fd0 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005d56:	0001e517          	auipc	a0,0x1e
    80005d5a:	eb250513          	addi	a0,a0,-334 # 80023c08 <disk+0x128>
    80005d5e:	f53fa0ef          	jal	80000cb0 <release>
    sleep();
    80005d62:	aaafc0ef          	jal	8000200c <sleep>
    acquire(&disk.vdisk_lock);
    80005d66:	0001e517          	auipc	a0,0x1e
    80005d6a:	ea250513          	addi	a0,a0,-350 # 80023c08 <disk+0x128>
    80005d6e:	ebbfa0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005d72:	fa040613          	addi	a2,s0,-96
    80005d76:	4901                	li	s2,0
    80005d78:	bf69                	j	80005d12 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d7a:	fa042503          	lw	a0,-96(s0)
    80005d7e:	00451693          	slli	a3,a0,0x4

  if (write)
    80005d82:	0001e797          	auipc	a5,0x1e
    80005d86:	d5e78793          	addi	a5,a5,-674 # 80023ae0 <disk>
    80005d8a:	00451713          	slli	a4,a0,0x4
    80005d8e:	0a070713          	addi	a4,a4,160
    80005d92:	973e                	add	a4,a4,a5
    80005d94:	01603633          	snez	a2,s6
    80005d98:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005d9a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005d9e:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005da2:	6398                	ld	a4,0(a5)
    80005da4:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005da6:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005daa:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005dac:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005dae:	6390                	ld	a2,0(a5)
    80005db0:	00d60833          	add	a6,a2,a3
    80005db4:	4741                	li	a4,16
    80005db6:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005dba:	4585                	li	a1,1
    80005dbc:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005dc0:	fa442703          	lw	a4,-92(s0)
    80005dc4:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005dc8:	0712                	slli	a4,a4,0x4
    80005dca:	963a                	add	a2,a2,a4
    80005dcc:	05898813          	addi	a6,s3,88
    80005dd0:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005dd4:	0007b883          	ld	a7,0(a5)
    80005dd8:	9746                	add	a4,a4,a7
    80005dda:	40000613          	li	a2,1024
    80005dde:	c710                	sw	a2,8(a4)
  if (write)
    80005de0:	001b3613          	seqz	a2,s6
    80005de4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005de8:	8e4d                	or	a2,a2,a1
    80005dea:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005dee:	fa842603          	lw	a2,-88(s0)
    80005df2:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005df6:	00451813          	slli	a6,a0,0x4
    80005dfa:	02080813          	addi	a6,a6,32
    80005dfe:	983e                	add	a6,a6,a5
    80005e00:	577d                	li	a4,-1
    80005e02:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005e06:	0612                	slli	a2,a2,0x4
    80005e08:	98b2                	add	a7,a7,a2
    80005e0a:	03068713          	addi	a4,a3,48
    80005e0e:	973e                	add	a4,a4,a5
    80005e10:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005e14:	6398                	ld	a4,0(a5)
    80005e16:	9732                	add	a4,a4,a2
    80005e18:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005e1a:	4689                	li	a3,2
    80005e1c:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005e20:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005e24:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005e28:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005e2c:	6794                	ld	a3,8(a5)
    80005e2e:	0026d703          	lhu	a4,2(a3)
    80005e32:	8b1d                	andi	a4,a4,7
    80005e34:	0706                	slli	a4,a4,0x1
    80005e36:	96ba                	add	a3,a3,a4
    80005e38:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005e3c:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005e40:	6798                	ld	a4,8(a5)
    80005e42:	00275783          	lhu	a5,2(a4)
    80005e46:	2785                	addiw	a5,a5,1
    80005e48:	00f71123          	sh	a5,2(a4)
    80005e4c:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005e50:	100017b7          	lui	a5,0x10001
    80005e54:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005e58:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005e5c:	0001e497          	auipc	s1,0x1e
    80005e60:	dac48493          	addi	s1,s1,-596 # 80023c08 <disk+0x128>
  while (b->disk == 1) {
    80005e64:	892e                	mv	s2,a1
    80005e66:	02b79163          	bne	a5,a1,80005e88 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005e6a:	854e                	mv	a0,s3
    80005e6c:	964fc0ef          	jal	80001fd0 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005e70:	8526                	mv	a0,s1
    80005e72:	e3ffa0ef          	jal	80000cb0 <release>
    sleep();
    80005e76:	996fc0ef          	jal	8000200c <sleep>
    acquire(&disk.vdisk_lock);
    80005e7a:	8526                	mv	a0,s1
    80005e7c:	dadfa0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005e80:	0049a783          	lw	a5,4(s3)
    80005e84:	ff2783e3          	beq	a5,s2,80005e6a <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005e88:	fa042903          	lw	s2,-96(s0)
    80005e8c:	00491713          	slli	a4,s2,0x4
    80005e90:	02070713          	addi	a4,a4,32
    80005e94:	0001e797          	auipc	a5,0x1e
    80005e98:	c4c78793          	addi	a5,a5,-948 # 80023ae0 <disk>
    80005e9c:	97ba                	add	a5,a5,a4
    80005e9e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005ea2:	0001e997          	auipc	s3,0x1e
    80005ea6:	c3e98993          	addi	s3,s3,-962 # 80023ae0 <disk>
    80005eaa:	00491713          	slli	a4,s2,0x4
    80005eae:	0009b783          	ld	a5,0(s3)
    80005eb2:	97ba                	add	a5,a5,a4
    80005eb4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005eb8:	854a                	mv	a0,s2
    80005eba:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005ebe:	bbbff0ef          	jal	80005a78 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005ec2:	8885                	andi	s1,s1,1
    80005ec4:	f0fd                	bnez	s1,80005eaa <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005ec6:	0001e517          	auipc	a0,0x1e
    80005eca:	d4250513          	addi	a0,a0,-702 # 80023c08 <disk+0x128>
    80005ece:	de3fa0ef          	jal	80000cb0 <release>
}
    80005ed2:	60e6                	ld	ra,88(sp)
    80005ed4:	6446                	ld	s0,80(sp)
    80005ed6:	64a6                	ld	s1,72(sp)
    80005ed8:	6906                	ld	s2,64(sp)
    80005eda:	79e2                	ld	s3,56(sp)
    80005edc:	7a42                	ld	s4,48(sp)
    80005ede:	7aa2                	ld	s5,40(sp)
    80005ee0:	7b02                	ld	s6,32(sp)
    80005ee2:	6be2                	ld	s7,24(sp)
    80005ee4:	6c42                	ld	s8,16(sp)
    80005ee6:	6125                	addi	sp,sp,96
    80005ee8:	8082                	ret

0000000080005eea <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005eea:	1101                	addi	sp,sp,-32
    80005eec:	ec06                	sd	ra,24(sp)
    80005eee:	e822                	sd	s0,16(sp)
    80005ef0:	e426                	sd	s1,8(sp)
    80005ef2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005ef4:	0001e497          	auipc	s1,0x1e
    80005ef8:	bec48493          	addi	s1,s1,-1044 # 80023ae0 <disk>
    80005efc:	0001e517          	auipc	a0,0x1e
    80005f00:	d0c50513          	addi	a0,a0,-756 # 80023c08 <disk+0x128>
    80005f04:	d25fa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005f08:	100017b7          	lui	a5,0x10001
    80005f0c:	53bc                	lw	a5,96(a5)
    80005f0e:	8b8d                	andi	a5,a5,3
    80005f10:	10001737          	lui	a4,0x10001
    80005f14:	d37c                	sw	a5,100(a4)
    80005f16:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005f1a:	689c                	ld	a5,16(s1)
    80005f1c:	0204d703          	lhu	a4,32(s1)
    80005f20:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005f24:	04f70863          	beq	a4,a5,80005f74 <virtio_disk_intr+0x8a>
    80005f28:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005f2c:	6898                	ld	a4,16(s1)
    80005f2e:	0204d783          	lhu	a5,32(s1)
    80005f32:	8b9d                	andi	a5,a5,7
    80005f34:	078e                	slli	a5,a5,0x3
    80005f36:	97ba                	add	a5,a5,a4
    80005f38:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005f3a:	00479713          	slli	a4,a5,0x4
    80005f3e:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005f42:	9726                	add	a4,a4,s1
    80005f44:	01074703          	lbu	a4,16(a4)
    80005f48:	e329                	bnez	a4,80005f8a <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005f4a:	0792                	slli	a5,a5,0x4
    80005f4c:	02078793          	addi	a5,a5,32
    80005f50:	97a6                	add	a5,a5,s1
    80005f52:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005f54:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005f58:	8e4fc0ef          	jal	8000203c <wakeup>

    disk.used_idx += 1;
    80005f5c:	0204d783          	lhu	a5,32(s1)
    80005f60:	2785                	addiw	a5,a5,1
    80005f62:	17c2                	slli	a5,a5,0x30
    80005f64:	93c1                	srli	a5,a5,0x30
    80005f66:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005f6a:	6898                	ld	a4,16(s1)
    80005f6c:	00275703          	lhu	a4,2(a4)
    80005f70:	faf71ce3          	bne	a4,a5,80005f28 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005f74:	0001e517          	auipc	a0,0x1e
    80005f78:	c9450513          	addi	a0,a0,-876 # 80023c08 <disk+0x128>
    80005f7c:	d35fa0ef          	jal	80000cb0 <release>
}
    80005f80:	60e2                	ld	ra,24(sp)
    80005f82:	6442                	ld	s0,16(sp)
    80005f84:	64a2                	ld	s1,8(sp)
    80005f86:	6105                	addi	sp,sp,32
    80005f88:	8082                	ret
      panic("virtio_disk_intr status");
    80005f8a:	00001517          	auipc	a0,0x1
    80005f8e:	79e50513          	addi	a0,a0,1950 # 80007728 <etext+0x728>
    80005f92:	8a3fa0ef          	jal	80000834 <panic>
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
