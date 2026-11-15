
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
    80000004:	4b813103          	ld	sp,1208(sp) # 8000a4b8 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdaff7>
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
    8000011c:	3c6020ef          	jal	800024e2 <either_copyin>
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
    800001c0:	13b010ef          	jal	80001afa <myproc>
    800001c4:	19e020ef          	jal	80002362 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	739010ef          	jal	80002104 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	76b010ef          	jal	80002140 <sleep>
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
    80000220:	276020ef          	jal	80002496 <either_copyout>
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
    800002ea:	244020ef          	jal	8000252e <procdump>
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
    8000042a:	547010ef          	jal	80002170 <wakeup>
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
    80000454:	22078793          	addi	a5,a5,544 # 80022670 <devsw>
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
    80000492:	42280813          	addi	a6,a6,1058 # 800078b0 <digits>
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
    8000052c:	fac7a783          	lw	a5,-84(a5) # 8000a4d4 <panicking>
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
    800006e6:	1cec8c93          	addi	s9,s9,462 # 800078b0 <digits>
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
    8000076e:	d6a7a783          	lw	a5,-662(a5) # 8000a4d4 <panicking>
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
    80000848:	c897a823          	sw	s1,-880(a5) # 8000a4d4 <panicking>
  printk("panic: ");
    8000084c:	00006517          	auipc	a0,0x6
    80000850:	7c450513          	addi	a0,a0,1988 # 80007010 <etext+0x10>
    80000854:	cb7ff0ef          	jal	8000050a <printk>
  printk("%s\n", s);
    80000858:	85ca                	mv	a1,s2
    8000085a:	00006517          	auipc	a0,0x6
    8000085e:	7be50513          	addi	a0,a0,1982 # 80007018 <etext+0x18>
    80000862:	ca9ff0ef          	jal	8000050a <printk>
  panicked = 1; // freeze uart output from other CPUs
    80000866:	0000a797          	auipc	a5,0xa
    8000086a:	c697a523          	sw	s1,-918(a5) # 8000a4d0 <panicked>
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
    8000087c:	7a858593          	addi	a1,a1,1960 # 80007020 <etext+0x20>
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
    800008d2:	75a58593          	addi	a1,a1,1882 # 80007028 <etext+0x28>
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
    8000091c:	bc490913          	addi	s2,s2,-1084 # 8000a4dc <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	bb898993          	addi	s3,s3,-1096 # 8000a4d8 <tx_chan>
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
    8000093a:	7ca010ef          	jal	80002104 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	7fc010ef          	jal	80002140 <sleep>
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
    800009a0:	b387a783          	lw	a5,-1224(a5) # 8000a4d4 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	b2a7a783          	lw	a5,-1238(a5) # 8000a4d0 <panicked>
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
    800009d0:	b087a783          	lw	a5,-1272(a5) # 8000a4d4 <panicking>
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
    80000a48:	a807ac23          	sw	zero,-1384(a5) # 8000a4dc <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	a8c50513          	addi	a0,a0,-1396 # 8000a4d8 <tx_chan>
    80000a54:	71c010ef          	jal	80002170 <wakeup>
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
    80000a76:	d9678793          	addi	a5,a5,-618 # 80023808 <end>
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
    80000aca:	56a50513          	addi	a0,a0,1386 # 80007030 <etext+0x30>
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
    80000b26:	51658593          	addi	a1,a1,1302 # 80007038 <etext+0x38>
    80000b2a:	00012517          	auipc	a0,0x12
    80000b2e:	aae50513          	addi	a0,a0,-1362 # 800125d8 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00023517          	auipc	a0,0x23
    80000b3e:	cce50513          	addi	a0,a0,-818 # 80023808 <end>
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
    80000bd8:	703000ef          	jal	80001ada <mycpu>
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
    80000bfe:	6dd000ef          	jal	80001ada <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x2c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	6d5000ef          	jal	80001ada <mycpu>
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
    80000c1a:	6c1000ef          	jal	80001ada <mycpu>
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
    80000c4c:	68f000ef          	jal	80001ada <mycpu>
    80000c50:	e888                	sd	a0,16(s1)
}
    80000c52:	60e2                	ld	ra,24(sp)
    80000c54:	6442                	ld	s0,16(sp)
    80000c56:	64a2                	ld	s1,8(sp)
    80000c58:	6105                	addi	sp,sp,32
    80000c5a:	8082                	ret
    panic("acquire");
    80000c5c:	00006517          	auipc	a0,0x6
    80000c60:	3e450513          	addi	a0,a0,996 # 80007040 <etext+0x40>
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
    80000c70:	66b000ef          	jal	80001ada <mycpu>
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
    80000c9c:	3b050513          	addi	a0,a0,944 # 80007048 <etext+0x48>
    80000ca0:	b95ff0ef          	jal	80000834 <panic>
    panic("pop_off");
    80000ca4:	00006517          	auipc	a0,0x6
    80000ca8:	3bc50513          	addi	a0,a0,956 # 80007060 <etext+0x60>
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
    80000ce0:	38c50513          	addi	a0,a0,908 # 80007068 <etext+0x68>
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
    80000ea6:	421000ef          	jal	80001ac6 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eaa:	00009717          	auipc	a4,0x9
    80000eae:	63670713          	addi	a4,a4,1590 # 8000a4e0 <started>
  if (cpuid() == 0) {
    80000eb2:	c51d                	beqz	a0,80000ee0 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eb4:	431c                	lw	a5,0(a4)
    80000eb6:	0230000f          	fence	r,rw
    80000eba:	2781                	sext.w	a5,a5
    80000ebc:	dfe5                	beqz	a5,80000eb4 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000ebe:	409000ef          	jal	80001ac6 <cpuid>
    80000ec2:	85aa                	mv	a1,a0
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1c450513          	addi	a0,a0,452 # 80007088 <etext+0x88>
    80000ecc:	e3eff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000ed0:	082000ef          	jal	80000f52 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000ed4:	78c010ef          	jal	80002660 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	191040ef          	jal	80005868 <plicinithart>
  }

  scheduler();
    80000edc:	08c010ef          	jal	80001f68 <scheduler>
    consoleinit();
    80000ee0:	d50ff0ef          	jal	80000430 <consoleinit>
    printkinit();
    80000ee4:	98dff0ef          	jal	80000870 <printkinit>
    printk("\n");
    80000ee8:	00006517          	auipc	a0,0x6
    80000eec:	30850513          	addi	a0,a0,776 # 800071f0 <etext+0x1f0>
    80000ef0:	e1aff0ef          	jal	8000050a <printk>
    printk("xv6 kernel is booting\n");
    80000ef4:	00006517          	auipc	a0,0x6
    80000ef8:	17c50513          	addi	a0,a0,380 # 80007070 <etext+0x70>
    80000efc:	e0eff0ef          	jal	8000050a <printk>
    printk("\n");
    80000f00:	00006517          	auipc	a0,0x6
    80000f04:	2f050513          	addi	a0,a0,752 # 800071f0 <etext+0x1f0>
    80000f08:	e02ff0ef          	jal	8000050a <printk>
    kinit();            // physical page allocator
    80000f0c:	c0fff0ef          	jal	80000b1a <kinit>
    kvminit();          // create kernel page table
    80000f10:	2ce000ef          	jal	800011de <kvminit>
    kvminithart();      // turn on paging
    80000f14:	03e000ef          	jal	80000f52 <kvminithart>
    procinit();         // process table
    80000f18:	2f9000ef          	jal	80001a10 <procinit>
    trapinit();         // trap vectors
    80000f1c:	720010ef          	jal	8000263c <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	740010ef          	jal	80002660 <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	12b040ef          	jal	8000584e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	141040ef          	jal	80005868 <plicinithart>
    binit();            // buffer cache
    80000f2c:	5ed010ef          	jal	80002d18 <binit>
    iinit();            // inode table
    80000f30:	33e020ef          	jal	8000326e <iinit>
    fileinit();         // file table
    80000f34:	36c030ef          	jal	800042a0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	227040ef          	jal	8000595e <virtio_disk_init>
    userinit();         // first user process
    80000f3c:	681000ef          	jal	80001dbc <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f40:	00009797          	auipc	a5,0x9
    80000f44:	5a078793          	addi	a5,a5,1440 # 8000a4e0 <started>
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
    80000f62:	58a7b783          	ld	a5,1418(a5) # 8000a4e8 <kernel_pagetable>
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
    80000fe8:	0bc50513          	addi	a0,a0,188 # 800070a0 <etext+0xa0>
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
    800010c0:	fec50513          	addi	a0,a0,-20 # 800070a8 <etext+0xa8>
    800010c4:	f70ff0ef          	jal	80000834 <panic>
    panic("mappages: size not aligned");
    800010c8:	00006517          	auipc	a0,0x6
    800010cc:	00050513          	mv	a0,a0
    800010d0:	f64ff0ef          	jal	80000834 <panic>
    panic("mappages: size");
    800010d4:	00006517          	auipc	a0,0x6
    800010d8:	01450513          	addi	a0,a0,20 # 800070e8 <etext+0xe8>
    800010dc:	f58ff0ef          	jal	80000834 <panic>
      panic("mappages: remap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	01850513          	addi	a0,a0,24 # 800070f8 <etext+0xf8>
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
    80001128:	fe450513          	addi	a0,a0,-28 # 80007108 <etext+0x108>
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
    800011ce:	79e000ef          	jal	8000196c <proc_mapstacks>
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
    800011ee:	2ea7bf23          	sd	a0,766(a5) # 8000a4e8 <kernel_pagetable>
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
    8000125e:	eb650513          	addi	a0,a0,-330 # 80007110 <etext+0x110>
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
    800013b4:	d7850513          	addi	a0,a0,-648 # 80007128 <etext+0x128>
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
    800014e2:	c5a50513          	addi	a0,a0,-934 # 80007138 <etext+0x138>
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
    80001724:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb7f8>
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

00000000800017ba <kvmprint>:

// Hierarchical page table dump for calling process
int
kvmprint(pagetable_t pagetable)
{
    800017ba:	7135                	addi	sp,sp,-160
    800017bc:	ed06                	sd	ra,152(sp)
    800017be:	e922                	sd	s0,144(sp)
    800017c0:	e526                	sd	s1,136(sp)
    800017c2:	e14a                	sd	s2,128(sp)
    800017c4:	fcce                	sd	s3,120(sp)
    800017c6:	f8d2                	sd	s4,112(sp)
    800017c8:	f4d6                	sd	s5,104(sp)
    800017ca:	f0da                	sd	s6,96(sp)
    800017cc:	ecde                	sd	s7,88(sp)
    800017ce:	e8e2                	sd	s8,80(sp)
    800017d0:	e4e6                	sd	s9,72(sp)
    800017d2:	e0ea                	sd	s10,64(sp)
    800017d4:	fc6e                	sd	s11,56(sp)
    800017d6:	1100                	addi	s0,sp,160
    800017d8:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800017da:	320000ef          	jal	80001afa <myproc>
    800017de:	892a                	mv	s2,a0
  printf("page table %p (pid %d, sz %d):\n", pagetable, p->pid, (int)p->sz);
    800017e0:	4534                	lw	a3,72(a0)
    800017e2:	5910                	lw	a2,48(a0)
    800017e4:	85d2                	mv	a1,s4
    800017e6:	00006517          	auipc	a0,0x6
    800017ea:	98a50513          	addi	a0,a0,-1654 # 80007170 <etext+0x170>
    800017ee:	d1dfe0ef          	jal	8000050a <printk>
    800017f2:	f8043023          	sd	zero,-128(s0)
  int kernel_entries = 0;
  int user_pages_count = 0;
  int guard_page_found = 0;

  // Level 2 (Page Directory)
  for (int i = 0; i < 512; i++) {
    800017f6:	4481                	li	s1,0
  int guard_page_found = 0;
    800017f8:	4c01                	li	s8,0
  int user_pages_count = 0;
    800017fa:	4d81                	li	s11,0
  int kernel_entries = 0;
    800017fc:	4b01                	li	s6,0
          // Level 0 (Page Table Entries)
          for (int k = 0; k < 512; k++) {
            pte_t pte0 = pt0[k];
            if (pte0 & PTE_V) {
              uint64 va = ((uint64)i << 30) | ((uint64)j << 21) | ((uint64)k << 12);
              if (va < KERNBASE) {
    800017fe:	80000ab7          	lui	s5,0x80000
    80001802:	fffaca93          	not	s5,s5
    80001806:	a8f9                	j	800018e4 <kvmprint+0x12a>
                if (u_bit) {
                  user_pages_count++;
                } else {
                  // Guard page created by exec() has PTE_U cleared
                  note = " <-- [STACK GUARD PAGE: PTE_U=0]";
                  guard_page_found++;
    80001808:	2c05                	addiw	s8,s8,1 # fffffffffffff001 <end+0xffffffff7ffdb7f9>
                  note = " <-- [STACK GUARD PAGE: PTE_U=0]";
    8000180a:	00006897          	auipc	a7,0x6
    8000180e:	93e88893          	addi	a7,a7,-1730 # 80007148 <etext+0x148>
                }
                printf("    ..pte[%d]: va 0x%lx -> pa 0x%lx, flags: [P=%d, W=%d, U=%d]%s\n",
    80001812:	4705                	li	a4,1
    80001814:	855e                	mv	a0,s7
    80001816:	cf5fe0ef          	jal	8000050a <printk>
          for (int k = 0; k < 512; k++) {
    8000181a:	0485                	addi	s1,s1,1 # 1001 <_entry-0x7fffefff>
    8000181c:	0921                	addi	s2,s2,8 # 1008 <_entry-0x7fffeff8>
    8000181e:	05348363          	beq	s1,s3,80001864 <kvmprint+0xaa>
            pte_t pte0 = pt0[k];
    80001822:	00093803          	ld	a6,0(s2)
            if (pte0 & PTE_V) {
    80001826:	00187793          	andi	a5,a6,1
    8000182a:	dbe5                	beqz	a5,8000181a <kvmprint+0x60>
              uint64 va = ((uint64)i << 30) | ((uint64)j << 21) | ((uint64)k << 12);
    8000182c:	00c49613          	slli	a2,s1,0xc
    80001830:	00ca6633          	or	a2,s4,a2
              if (va < KERNBASE) {
    80001834:	02cae663          	bltu	s5,a2,80001860 <kvmprint+0xa6>
    80001838:	0004859b          	sext.w	a1,s1
                uint64 pa = PTE2PA(pte0);
    8000183c:	00a85693          	srli	a3,a6,0xa
    80001840:	06b2                	slli	a3,a3,0xc
                int w_bit = (pte0 & PTE_W) ? 1 : 0;
    80001842:	00285793          	srli	a5,a6,0x2
    80001846:	8b85                	andi	a5,a5,1
                int u_bit = (pte0 & PTE_U) ? 1 : 0;
    80001848:	00485813          	srli	a6,a6,0x4
    8000184c:	00187813          	andi	a6,a6,1
                if (u_bit) {
    80001850:	fa080ce3          	beqz	a6,80001808 <kvmprint+0x4e>
                  user_pages_count++;
    80001854:	2d85                	addiw	s11,s11,1
                char *note = "";
    80001856:	00006897          	auipc	a7,0x6
    8000185a:	91288893          	addi	a7,a7,-1774 # 80007168 <etext+0x168>
    8000185e:	bf55                	j	80001812 <kvmprint+0x58>
                       k, va, pa, p_bit, w_bit, u_bit, note);
              } else {
                kernel_entries++;
    80001860:	2b05                	addiw	s6,s6,1 # 1001 <_entry-0x7fffefff>
    80001862:	bf65                	j	8000181a <kvmprint+0x60>
      for (int j = 0; j < 512; j++) {
    80001864:	2c85                	addiw	s9,s9,1
    80001866:	0d21                	addi	s10,s10,8 # fffffffffffff008 <end+0xffffffff7ffdb800>
    80001868:	002007b7          	lui	a5,0x200
    8000186c:	f8843703          	ld	a4,-120(s0)
    80001870:	97ba                	add	a5,a5,a4
    80001872:	f8f43423          	sd	a5,-120(s0)
    80001876:	053c8463          	beq	s9,s3,800018be <kvmprint+0x104>
        pte_t pte1 = pt1[j];
    8000187a:	000d3703          	ld	a4,0(s10)
        if (pte1 & PTE_V) {
    8000187e:	00177793          	andi	a5,a4,1
    80001882:	d3ed                	beqz	a5,80001864 <kvmprint+0xaa>
          uint64 pa0 = PTE2PA(pte1);
    80001884:	00a75913          	srli	s2,a4,0xa
    80001888:	0932                	slli	s2,s2,0xc
                 (pte1 & PTE_U) ? 1 : 0);
    8000188a:	00475793          	srli	a5,a4,0x4
                 (pte1 & PTE_W) ? 1 : 0,
    8000188e:	8309                	srli	a4,a4,0x2
          printf("  ..mid[%d]: pa 0x%lx, flags: [P=%d, W=%d, U=%d]\n",
    80001890:	8b85                	andi	a5,a5,1
    80001892:	8b05                	andi	a4,a4,1
    80001894:	4685                	li	a3,1
    80001896:	864a                	mv	a2,s2
    80001898:	85e6                	mv	a1,s9
    8000189a:	00006517          	auipc	a0,0x6
    8000189e:	92650513          	addi	a0,a0,-1754 # 800071c0 <etext+0x1c0>
    800018a2:	c69fe0ef          	jal	8000050a <printk>
    800018a6:	4481                	li	s1,0
              uint64 va = ((uint64)i << 30) | ((uint64)j << 21) | ((uint64)k << 12);
    800018a8:	f8043783          	ld	a5,-128(s0)
    800018ac:	f8843703          	ld	a4,-120(s0)
    800018b0:	00e7ea33          	or	s4,a5,a4
                printf("    ..pte[%d]: va 0x%lx -> pa 0x%lx, flags: [P=%d, W=%d, U=%d]%s\n",
    800018b4:	00006b97          	auipc	s7,0x6
    800018b8:	944b8b93          	addi	s7,s7,-1724 # 800071f8 <etext+0x1f8>
    800018bc:	b79d                	j	80001822 <kvmprint+0x68>
    800018be:	f7843903          	ld	s2,-136(s0)
    800018c2:	f7043483          	ld	s1,-144(s0)
    800018c6:	f6843a03          	ld	s4,-152(s0)
  for (int i = 0; i < 512; i++) {
    800018ca:	2485                	addiw	s1,s1,1
    800018cc:	0a21                	addi	s4,s4,8
    800018ce:	400007b7          	lui	a5,0x40000
    800018d2:	f8043703          	ld	a4,-128(s0)
    800018d6:	97ba                	add	a5,a5,a4
    800018d8:	f8f43023          	sd	a5,-128(s0)
    800018dc:	20000793          	li	a5,512
    800018e0:	04f48463          	beq	s1,a5,80001928 <kvmprint+0x16e>
    pte_t pte2 = pagetable[i];
    800018e4:	000a3703          	ld	a4,0(s4)
    if (pte2 & PTE_V) {
    800018e8:	00177793          	andi	a5,a4,1
    800018ec:	dff9                	beqz	a5,800018ca <kvmprint+0x110>
      uint64 pa1 = PTE2PA(pte2);
    800018ee:	00a75d13          	srli	s10,a4,0xa
    800018f2:	0d32                	slli	s10,s10,0xc
             (pte2 & PTE_U) ? 1 : 0);
    800018f4:	00475793          	srli	a5,a4,0x4
             (pte2 & PTE_W) ? 1 : 0,
    800018f8:	8309                	srli	a4,a4,0x2
      printf("..dir[%d]: pa 0x%lx, flags: [P=%d, W=%d, U=%d]\n",
    800018fa:	8b85                	andi	a5,a5,1
    800018fc:	8b05                	andi	a4,a4,1
    800018fe:	4685                	li	a3,1
    80001900:	866a                	mv	a2,s10
    80001902:	85a6                	mv	a1,s1
    80001904:	00006517          	auipc	a0,0x6
    80001908:	88c50513          	addi	a0,a0,-1908 # 80007190 <etext+0x190>
    8000190c:	bfffe0ef          	jal	8000050a <printk>
    80001910:	f8043423          	sd	zero,-120(s0)
      for (int j = 0; j < 512; j++) {
    80001914:	4c81                	li	s9,0
          for (int k = 0; k < 512; k++) {
    80001916:	20000993          	li	s3,512
    8000191a:	f7243c23          	sd	s2,-136(s0)
    8000191e:	f6943823          	sd	s1,-144(s0)
    80001922:	f7443423          	sd	s4,-152(s0)
    80001926:	bf91                	j	8000187a <kvmprint+0xc0>
        }
      }
    }
  }

  printf("Kernel entries summary: %d high-memory kernel entries mapped (trampoline/trapframe).\n", kernel_entries);
    80001928:	85da                	mv	a1,s6
    8000192a:	00006517          	auipc	a0,0x6
    8000192e:	91650513          	addi	a0,a0,-1770 # 80007240 <etext+0x240>
    80001932:	bd9fe0ef          	jal	8000050a <printk>
  printf("User accessible pages: %d (sz/PGSIZE=%ld minus guard page=%d)\n",
    80001936:	04893603          	ld	a2,72(s2)
    8000193a:	86e2                	mv	a3,s8
    8000193c:	8231                	srli	a2,a2,0xc
    8000193e:	85ee                	mv	a1,s11
    80001940:	00006517          	auipc	a0,0x6
    80001944:	95850513          	addi	a0,a0,-1704 # 80007298 <etext+0x298>
    80001948:	bc3fe0ef          	jal	8000050a <printk>
         user_pages_count, p->sz / PGSIZE, guard_page_found);
  return 0;
}
    8000194c:	4501                	li	a0,0
    8000194e:	60ea                	ld	ra,152(sp)
    80001950:	644a                	ld	s0,144(sp)
    80001952:	64aa                	ld	s1,136(sp)
    80001954:	690a                	ld	s2,128(sp)
    80001956:	79e6                	ld	s3,120(sp)
    80001958:	7a46                	ld	s4,112(sp)
    8000195a:	7aa6                	ld	s5,104(sp)
    8000195c:	7b06                	ld	s6,96(sp)
    8000195e:	6be6                	ld	s7,88(sp)
    80001960:	6c46                	ld	s8,80(sp)
    80001962:	6ca6                	ld	s9,72(sp)
    80001964:	6d06                	ld	s10,64(sp)
    80001966:	7de2                	ld	s11,56(sp)
    80001968:	610d                	addi	sp,sp,160
    8000196a:	8082                	ret

000000008000196c <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000196c:	715d                	addi	sp,sp,-80
    8000196e:	e486                	sd	ra,72(sp)
    80001970:	e0a2                	sd	s0,64(sp)
    80001972:	fc26                	sd	s1,56(sp)
    80001974:	f84a                	sd	s2,48(sp)
    80001976:	f44e                	sd	s3,40(sp)
    80001978:	f052                	sd	s4,32(sp)
    8000197a:	ec56                	sd	s5,24(sp)
    8000197c:	e85a                	sd	s6,16(sp)
    8000197e:	e45e                	sd	s7,8(sp)
    80001980:	e062                	sd	s8,0(sp)
    80001982:	0880                	addi	s0,sp,80
    80001984:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001986:	00011497          	auipc	s1,0x11
    8000198a:	0a248493          	addi	s1,s1,162 # 80012a28 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000198e:	8c26                	mv	s8,s1
    80001990:	000a57b7          	lui	a5,0xa5
    80001994:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001998:	07b2                	slli	a5,a5,0xc
    8000199a:	fa578793          	addi	a5,a5,-91
    8000199e:	4fa50937          	lui	s2,0x4fa50
    800019a2:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800019a6:	1902                	slli	s2,s2,0x20
    800019a8:	993e                	add	s2,s2,a5
    800019aa:	040009b7          	lui	s3,0x4000
    800019ae:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019b0:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019b2:	4b99                	li	s7,6
    800019b4:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    800019b6:	00017a97          	auipc	s5,0x17
    800019ba:	a72a8a93          	addi	s5,s5,-1422 # 80018428 <tickslock>
    char *pa = kalloc();
    800019be:	990ff0ef          	jal	80000b4e <kalloc>
    800019c2:	862a                	mv	a2,a0
    if (pa == 0)
    800019c4:	c121                	beqz	a0,80001a04 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    800019c6:	418485b3          	sub	a1,s1,s8
    800019ca:	858d                	srai	a1,a1,0x3
    800019cc:	032585b3          	mul	a1,a1,s2
    800019d0:	05b6                	slli	a1,a1,0xd
    800019d2:	6789                	lui	a5,0x2
    800019d4:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019d6:	875e                	mv	a4,s7
    800019d8:	86da                	mv	a3,s6
    800019da:	40b985b3          	sub	a1,s3,a1
    800019de:	8552                	mv	a0,s4
    800019e0:	f28ff0ef          	jal	80001108 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    800019e4:	16848493          	addi	s1,s1,360
    800019e8:	fd549be3          	bne	s1,s5,800019be <proc_mapstacks+0x52>
  }
}
    800019ec:	60a6                	ld	ra,72(sp)
    800019ee:	6406                	ld	s0,64(sp)
    800019f0:	74e2                	ld	s1,56(sp)
    800019f2:	7942                	ld	s2,48(sp)
    800019f4:	79a2                	ld	s3,40(sp)
    800019f6:	7a02                	ld	s4,32(sp)
    800019f8:	6ae2                	ld	s5,24(sp)
    800019fa:	6b42                	ld	s6,16(sp)
    800019fc:	6ba2                	ld	s7,8(sp)
    800019fe:	6c02                	ld	s8,0(sp)
    80001a00:	6161                	addi	sp,sp,80
    80001a02:	8082                	ret
      panic("kalloc");
    80001a04:	00006517          	auipc	a0,0x6
    80001a08:	8d450513          	addi	a0,a0,-1836 # 800072d8 <etext+0x2d8>
    80001a0c:	e29fe0ef          	jal	80000834 <panic>

0000000080001a10 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001a10:	7139                	addi	sp,sp,-64
    80001a12:	fc06                	sd	ra,56(sp)
    80001a14:	f822                	sd	s0,48(sp)
    80001a16:	f426                	sd	s1,40(sp)
    80001a18:	f04a                	sd	s2,32(sp)
    80001a1a:	ec4e                	sd	s3,24(sp)
    80001a1c:	e852                	sd	s4,16(sp)
    80001a1e:	e456                	sd	s5,8(sp)
    80001a20:	e05a                	sd	s6,0(sp)
    80001a22:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001a24:	00006597          	auipc	a1,0x6
    80001a28:	8bc58593          	addi	a1,a1,-1860 # 800072e0 <etext+0x2e0>
    80001a2c:	00011517          	auipc	a0,0x11
    80001a30:	bcc50513          	addi	a0,a0,-1076 # 800125f8 <pid_lock>
    80001a34:	974ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a38:	00006597          	auipc	a1,0x6
    80001a3c:	8b058593          	addi	a1,a1,-1872 # 800072e8 <etext+0x2e8>
    80001a40:	00011517          	auipc	a0,0x11
    80001a44:	bd050513          	addi	a0,a0,-1072 # 80012610 <wait_lock>
    80001a48:	960ff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001a4c:	00011497          	auipc	s1,0x11
    80001a50:	fdc48493          	addi	s1,s1,-36 # 80012a28 <proc>
    initlock(&p->lock, "proc");
    80001a54:	00006b17          	auipc	s6,0x6
    80001a58:	8a4b0b13          	addi	s6,s6,-1884 # 800072f8 <etext+0x2f8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001a5c:	8aa6                	mv	s5,s1
    80001a5e:	000a57b7          	lui	a5,0xa5
    80001a62:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001a66:	07b2                	slli	a5,a5,0xc
    80001a68:	fa578793          	addi	a5,a5,-91
    80001a6c:	4fa50937          	lui	s2,0x4fa50
    80001a70:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001a74:	1902                	slli	s2,s2,0x20
    80001a76:	993e                	add	s2,s2,a5
    80001a78:	040009b7          	lui	s3,0x4000
    80001a7c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a7e:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001a80:	00017a17          	auipc	s4,0x17
    80001a84:	9a8a0a13          	addi	s4,s4,-1624 # 80018428 <tickslock>
    initlock(&p->lock, "proc");
    80001a88:	85da                	mv	a1,s6
    80001a8a:	8526                	mv	a0,s1
    80001a8c:	91cff0ef          	jal	80000ba8 <initlock>
    p->state = UNUSED;
    80001a90:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001a94:	415487b3          	sub	a5,s1,s5
    80001a98:	878d                	srai	a5,a5,0x3
    80001a9a:	032787b3          	mul	a5,a5,s2
    80001a9e:	07b6                	slli	a5,a5,0xd
    80001aa0:	6709                	lui	a4,0x2
    80001aa2:	9fb9                	addw	a5,a5,a4
    80001aa4:	40f987b3          	sub	a5,s3,a5
    80001aa8:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    80001aaa:	16848493          	addi	s1,s1,360
    80001aae:	fd449de3          	bne	s1,s4,80001a88 <procinit+0x78>
  }
}
    80001ab2:	70e2                	ld	ra,56(sp)
    80001ab4:	7442                	ld	s0,48(sp)
    80001ab6:	74a2                	ld	s1,40(sp)
    80001ab8:	7902                	ld	s2,32(sp)
    80001aba:	69e2                	ld	s3,24(sp)
    80001abc:	6a42                	ld	s4,16(sp)
    80001abe:	6aa2                	ld	s5,8(sp)
    80001ac0:	6b02                	ld	s6,0(sp)
    80001ac2:	6121                	addi	sp,sp,64
    80001ac4:	8082                	ret

0000000080001ac6 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001ac6:	1141                	addi	sp,sp,-16
    80001ac8:	e406                	sd	ra,8(sp)
    80001aca:	e022                	sd	s0,0(sp)
    80001acc:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    80001ace:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001ad0:	2501                	sext.w	a0,a0
    80001ad2:	60a2                	ld	ra,8(sp)
    80001ad4:	6402                	ld	s0,0(sp)
    80001ad6:	0141                	addi	sp,sp,16
    80001ad8:	8082                	ret

0000000080001ada <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001ada:	1141                	addi	sp,sp,-16
    80001adc:	e406                	sd	ra,8(sp)
    80001ade:	e022                	sd	s0,0(sp)
    80001ae0:	0800                	addi	s0,sp,16
    80001ae2:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001ae4:	2781                	sext.w	a5,a5
    80001ae6:	079e                	slli	a5,a5,0x7
  return c;
}
    80001ae8:	00011517          	auipc	a0,0x11
    80001aec:	b4050513          	addi	a0,a0,-1216 # 80012628 <cpus>
    80001af0:	953e                	add	a0,a0,a5
    80001af2:	60a2                	ld	ra,8(sp)
    80001af4:	6402                	ld	s0,0(sp)
    80001af6:	0141                	addi	sp,sp,16
    80001af8:	8082                	ret

0000000080001afa <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001afa:	1101                	addi	sp,sp,-32
    80001afc:	ec06                	sd	ra,24(sp)
    80001afe:	e822                	sd	s0,16(sp)
    80001b00:	e426                	sd	s1,8(sp)
    80001b02:	1000                	addi	s0,sp,32
  push_off();
    80001b04:	8eaff0ef          	jal	80000bee <push_off>
    80001b08:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b0a:	2781                	sext.w	a5,a5
    80001b0c:	079e                	slli	a5,a5,0x7
    80001b0e:	00011717          	auipc	a4,0x11
    80001b12:	aea70713          	addi	a4,a4,-1302 # 800125f8 <pid_lock>
    80001b16:	97ba                	add	a5,a5,a4
    80001b18:	7b9c                	ld	a5,48(a5)
    80001b1a:	84be                	mv	s1,a5
  pop_off();
    80001b1c:	94cff0ef          	jal	80000c68 <pop_off>
  return p;
}
    80001b20:	8526                	mv	a0,s1
    80001b22:	60e2                	ld	ra,24(sp)
    80001b24:	6442                	ld	s0,16(sp)
    80001b26:	64a2                	ld	s1,8(sp)
    80001b28:	6105                	addi	sp,sp,32
    80001b2a:	8082                	ret

0000000080001b2c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b2c:	7179                	addi	sp,sp,-48
    80001b2e:	f406                	sd	ra,40(sp)
    80001b30:	f022                	sd	s0,32(sp)
    80001b32:	ec26                	sd	s1,24(sp)
    80001b34:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001b36:	fc5ff0ef          	jal	80001afa <myproc>
    80001b3a:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001b3c:	974ff0ef          	jal	80000cb0 <release>

  if (first) {
    80001b40:	00009797          	auipc	a5,0x9
    80001b44:	9607a783          	lw	a5,-1696(a5) # 8000a4a0 <first.1>
    80001b48:	cf85                	beqz	a5,80001b80 <forkret+0x54>
    first = 0;
    80001b4a:	00009797          	auipc	a5,0x9
    80001b4e:	9407ab23          	sw	zero,-1706(a5) # 8000a4a0 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001b52:	4505                	li	a0,1
    80001b54:	41f010ef          	jal	80003772 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001b58:	00005797          	auipc	a5,0x5
    80001b5c:	7a878793          	addi	a5,a5,1960 # 80007300 <etext+0x300>
    80001b60:	fcf43823          	sd	a5,-48(s0)
    80001b64:	fc043c23          	sd	zero,-40(s0)
    80001b68:	fd040593          	addi	a1,s0,-48
    80001b6c:	853e                	mv	a0,a5
    80001b6e:	6b9020ef          	jal	80004a26 <kexec>
    80001b72:	6cbc                	ld	a5,88(s1)
    80001b74:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001b76:	6cbc                	ld	a5,88(s1)
    80001b78:	7bb8                	ld	a4,112(a5)
    80001b7a:	57fd                	li	a5,-1
    80001b7c:	02f70d63          	beq	a4,a5,80001bb6 <forkret+0x8a>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001b80:	2fd000ef          	jal	8000267c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b84:	68a8                	ld	a0,80(s1)
    80001b86:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001b88:	04000737          	lui	a4,0x4000
    80001b8c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001b8e:	0732                	slli	a4,a4,0xc
    80001b90:	00004797          	auipc	a5,0x4
    80001b94:	50c78793          	addi	a5,a5,1292 # 8000609c <userret>
    80001b98:	00004697          	auipc	a3,0x4
    80001b9c:	46868693          	addi	a3,a3,1128 # 80006000 <_trampoline>
    80001ba0:	8f95                	sub	a5,a5,a3
    80001ba2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001ba4:	577d                	li	a4,-1
    80001ba6:	177e                	slli	a4,a4,0x3f
    80001ba8:	8d59                	or	a0,a0,a4
    80001baa:	9782                	jalr	a5
}
    80001bac:	70a2                	ld	ra,40(sp)
    80001bae:	7402                	ld	s0,32(sp)
    80001bb0:	64e2                	ld	s1,24(sp)
    80001bb2:	6145                	addi	sp,sp,48
    80001bb4:	8082                	ret
      panic("exec");
    80001bb6:	00005517          	auipc	a0,0x5
    80001bba:	75250513          	addi	a0,a0,1874 # 80007308 <etext+0x308>
    80001bbe:	c77fe0ef          	jal	80000834 <panic>

0000000080001bc2 <allocpid>:
{
    80001bc2:	1101                	addi	sp,sp,-32
    80001bc4:	ec06                	sd	ra,24(sp)
    80001bc6:	e822                	sd	s0,16(sp)
    80001bc8:	e426                	sd	s1,8(sp)
    80001bca:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bcc:	00011517          	auipc	a0,0x11
    80001bd0:	a2c50513          	addi	a0,a0,-1492 # 800125f8 <pid_lock>
    80001bd4:	854ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001bd8:	00009797          	auipc	a5,0x9
    80001bdc:	8cc78793          	addi	a5,a5,-1844 # 8000a4a4 <nextpid>
    80001be0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001be2:	0014871b          	addiw	a4,s1,1
    80001be6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001be8:	00011517          	auipc	a0,0x11
    80001bec:	a1050513          	addi	a0,a0,-1520 # 800125f8 <pid_lock>
    80001bf0:	8c0ff0ef          	jal	80000cb0 <release>
}
    80001bf4:	8526                	mv	a0,s1
    80001bf6:	60e2                	ld	ra,24(sp)
    80001bf8:	6442                	ld	s0,16(sp)
    80001bfa:	64a2                	ld	s1,8(sp)
    80001bfc:	6105                	addi	sp,sp,32
    80001bfe:	8082                	ret

0000000080001c00 <proc_pagetable>:
{
    80001c00:	1101                	addi	sp,sp,-32
    80001c02:	ec06                	sd	ra,24(sp)
    80001c04:	e822                	sd	s0,16(sp)
    80001c06:	e426                	sd	s1,8(sp)
    80001c08:	e04a                	sd	s2,0(sp)
    80001c0a:	1000                	addi	s0,sp,32
    80001c0c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c0e:	decff0ef          	jal	800011fa <uvmcreate>
    80001c12:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001c14:	cd05                	beqz	a0,80001c4c <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001c16:	4729                	li	a4,10
    80001c18:	00004697          	auipc	a3,0x4
    80001c1c:	3e868693          	addi	a3,a3,1000 # 80006000 <_trampoline>
    80001c20:	6605                	lui	a2,0x1
    80001c22:	040005b7          	lui	a1,0x4000
    80001c26:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c28:	05b2                	slli	a1,a1,0xc
    80001c2a:	c28ff0ef          	jal	80001052 <mappages>
    80001c2e:	02054663          	bltz	a0,80001c5a <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001c32:	4719                	li	a4,6
    80001c34:	05893683          	ld	a3,88(s2)
    80001c38:	6605                	lui	a2,0x1
    80001c3a:	020005b7          	lui	a1,0x2000
    80001c3e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c40:	05b6                	slli	a1,a1,0xd
    80001c42:	8526                	mv	a0,s1
    80001c44:	c0eff0ef          	jal	80001052 <mappages>
    80001c48:	00054f63          	bltz	a0,80001c66 <proc_pagetable+0x66>
}
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	60e2                	ld	ra,24(sp)
    80001c50:	6442                	ld	s0,16(sp)
    80001c52:	64a2                	ld	s1,8(sp)
    80001c54:	6902                	ld	s2,0(sp)
    80001c56:	6105                	addi	sp,sp,32
    80001c58:	8082                	ret
    uvmfree(pagetable, 0);
    80001c5a:	4581                	li	a1,0
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	f96ff0ef          	jal	800013f4 <uvmfree>
    return 0;
    80001c62:	4481                	li	s1,0
    80001c64:	b7e5                	j	80001c4c <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c66:	4681                	li	a3,0
    80001c68:	4605                	li	a2,1
    80001c6a:	040005b7          	lui	a1,0x4000
    80001c6e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c70:	05b2                	slli	a1,a1,0xc
    80001c72:	8526                	mv	a0,s1
    80001c74:	dacff0ef          	jal	80001220 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c78:	4581                	li	a1,0
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	f78ff0ef          	jal	800013f4 <uvmfree>
    return 0;
    80001c80:	4481                	li	s1,0
    80001c82:	b7e9                	j	80001c4c <proc_pagetable+0x4c>

0000000080001c84 <proc_freepagetable>:
{
    80001c84:	1101                	addi	sp,sp,-32
    80001c86:	ec06                	sd	ra,24(sp)
    80001c88:	e822                	sd	s0,16(sp)
    80001c8a:	e426                	sd	s1,8(sp)
    80001c8c:	e04a                	sd	s2,0(sp)
    80001c8e:	1000                	addi	s0,sp,32
    80001c90:	84aa                	mv	s1,a0
    80001c92:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c94:	4681                	li	a3,0
    80001c96:	4605                	li	a2,1
    80001c98:	040005b7          	lui	a1,0x4000
    80001c9c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c9e:	05b2                	slli	a1,a1,0xc
    80001ca0:	d80ff0ef          	jal	80001220 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ca4:	4681                	li	a3,0
    80001ca6:	4605                	li	a2,1
    80001ca8:	020005b7          	lui	a1,0x2000
    80001cac:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cae:	05b6                	slli	a1,a1,0xd
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	d6eff0ef          	jal	80001220 <uvmunmap>
  uvmfree(pagetable, sz);
    80001cb6:	85ca                	mv	a1,s2
    80001cb8:	8526                	mv	a0,s1
    80001cba:	f3aff0ef          	jal	800013f4 <uvmfree>
}
    80001cbe:	60e2                	ld	ra,24(sp)
    80001cc0:	6442                	ld	s0,16(sp)
    80001cc2:	64a2                	ld	s1,8(sp)
    80001cc4:	6902                	ld	s2,0(sp)
    80001cc6:	6105                	addi	sp,sp,32
    80001cc8:	8082                	ret

0000000080001cca <freeproc>:
{
    80001cca:	1101                	addi	sp,sp,-32
    80001ccc:	ec06                	sd	ra,24(sp)
    80001cce:	e822                	sd	s0,16(sp)
    80001cd0:	e426                	sd	s1,8(sp)
    80001cd2:	1000                	addi	s0,sp,32
    80001cd4:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001cd6:	6d28                	ld	a0,88(a0)
    80001cd8:	c119                	beqz	a0,80001cde <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001cda:	d8dfe0ef          	jal	80000a66 <kfree>
  p->trapframe = 0;
    80001cde:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001ce2:	68a8                	ld	a0,80(s1)
    80001ce4:	c501                	beqz	a0,80001cec <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001ce6:	64ac                	ld	a1,72(s1)
    80001ce8:	f9dff0ef          	jal	80001c84 <proc_freepagetable>
  p->pagetable = 0;
    80001cec:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001cf0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001cf4:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001cf8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001cfc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d00:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d04:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d08:	0004ac23          	sw	zero,24(s1)
}
    80001d0c:	60e2                	ld	ra,24(sp)
    80001d0e:	6442                	ld	s0,16(sp)
    80001d10:	64a2                	ld	s1,8(sp)
    80001d12:	6105                	addi	sp,sp,32
    80001d14:	8082                	ret

0000000080001d16 <allocproc>:
{
    80001d16:	1101                	addi	sp,sp,-32
    80001d18:	ec06                	sd	ra,24(sp)
    80001d1a:	e822                	sd	s0,16(sp)
    80001d1c:	e426                	sd	s1,8(sp)
    80001d1e:	e04a                	sd	s2,0(sp)
    80001d20:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001d22:	00011497          	auipc	s1,0x11
    80001d26:	d0648493          	addi	s1,s1,-762 # 80012a28 <proc>
    80001d2a:	00016917          	auipc	s2,0x16
    80001d2e:	6fe90913          	addi	s2,s2,1790 # 80018428 <tickslock>
    acquire(&p->lock);
    80001d32:	8526                	mv	a0,s1
    80001d34:	ef5fe0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001d38:	4c9c                	lw	a5,24(s1)
    80001d3a:	cb91                	beqz	a5,80001d4e <allocproc+0x38>
      release(&p->lock);
    80001d3c:	8526                	mv	a0,s1
    80001d3e:	f73fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001d42:	16848493          	addi	s1,s1,360
    80001d46:	ff2496e3          	bne	s1,s2,80001d32 <allocproc+0x1c>
  return 0;
    80001d4a:	4481                	li	s1,0
    80001d4c:	a089                	j	80001d8e <allocproc+0x78>
  p->pid = allocpid();
    80001d4e:	e75ff0ef          	jal	80001bc2 <allocpid>
    80001d52:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d54:	4785                	li	a5,1
    80001d56:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001d58:	df7fe0ef          	jal	80000b4e <kalloc>
    80001d5c:	892a                	mv	s2,a0
    80001d5e:	eca8                	sd	a0,88(s1)
    80001d60:	cd15                	beqz	a0,80001d9c <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001d62:	8526                	mv	a0,s1
    80001d64:	e9dff0ef          	jal	80001c00 <proc_pagetable>
    80001d68:	892a                	mv	s2,a0
    80001d6a:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001d6c:	c121                	beqz	a0,80001dac <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001d6e:	07000613          	li	a2,112
    80001d72:	4581                	li	a1,0
    80001d74:	06048513          	addi	a0,s1,96
    80001d78:	f71fe0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001d7c:	00000797          	auipc	a5,0x0
    80001d80:	db078793          	addi	a5,a5,-592 # 80001b2c <forkret>
    80001d84:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d86:	60bc                	ld	a5,64(s1)
    80001d88:	6705                	lui	a4,0x1
    80001d8a:	97ba                	add	a5,a5,a4
    80001d8c:	f4bc                	sd	a5,104(s1)
}
    80001d8e:	8526                	mv	a0,s1
    80001d90:	60e2                	ld	ra,24(sp)
    80001d92:	6442                	ld	s0,16(sp)
    80001d94:	64a2                	ld	s1,8(sp)
    80001d96:	6902                	ld	s2,0(sp)
    80001d98:	6105                	addi	sp,sp,32
    80001d9a:	8082                	ret
    freeproc(p);
    80001d9c:	8526                	mv	a0,s1
    80001d9e:	f2dff0ef          	jal	80001cca <freeproc>
    release(&p->lock);
    80001da2:	8526                	mv	a0,s1
    80001da4:	f0dfe0ef          	jal	80000cb0 <release>
    return 0;
    80001da8:	84ca                	mv	s1,s2
    80001daa:	b7d5                	j	80001d8e <allocproc+0x78>
    freeproc(p);
    80001dac:	8526                	mv	a0,s1
    80001dae:	f1dff0ef          	jal	80001cca <freeproc>
    release(&p->lock);
    80001db2:	8526                	mv	a0,s1
    80001db4:	efdfe0ef          	jal	80000cb0 <release>
    return 0;
    80001db8:	84ca                	mv	s1,s2
    80001dba:	bfd1                	j	80001d8e <allocproc+0x78>

0000000080001dbc <userinit>:
{
    80001dbc:	1101                	addi	sp,sp,-32
    80001dbe:	ec06                	sd	ra,24(sp)
    80001dc0:	e822                	sd	s0,16(sp)
    80001dc2:	e426                	sd	s1,8(sp)
    80001dc4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001dc6:	f51ff0ef          	jal	80001d16 <allocproc>
    80001dca:	84aa                	mv	s1,a0
  initproc = p;
    80001dcc:	00008797          	auipc	a5,0x8
    80001dd0:	72a7b223          	sd	a0,1828(a5) # 8000a4f0 <initproc>
  p->cwd = namei("/");
    80001dd4:	00005517          	auipc	a0,0x5
    80001dd8:	53c50513          	addi	a0,a0,1340 # 80007310 <etext+0x310>
    80001ddc:	6f5010ef          	jal	80003cd0 <namei>
    80001de0:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001de4:	478d                	li	a5,3
    80001de6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001de8:	8526                	mv	a0,s1
    80001dea:	ec7fe0ef          	jal	80000cb0 <release>
}
    80001dee:	60e2                	ld	ra,24(sp)
    80001df0:	6442                	ld	s0,16(sp)
    80001df2:	64a2                	ld	s1,8(sp)
    80001df4:	6105                	addi	sp,sp,32
    80001df6:	8082                	ret

0000000080001df8 <growproc>:
{
    80001df8:	1101                	addi	sp,sp,-32
    80001dfa:	ec06                	sd	ra,24(sp)
    80001dfc:	e822                	sd	s0,16(sp)
    80001dfe:	e426                	sd	s1,8(sp)
    80001e00:	e04a                	sd	s2,0(sp)
    80001e02:	1000                	addi	s0,sp,32
    80001e04:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e06:	cf5ff0ef          	jal	80001afa <myproc>
    80001e0a:	892a                	mv	s2,a0
  sz = p->sz;
    80001e0c:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001e0e:	02905963          	blez	s1,80001e40 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001e12:	00b48633          	add	a2,s1,a1
    80001e16:	020007b7          	lui	a5,0x2000
    80001e1a:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001e1c:	07b6                	slli	a5,a5,0xd
    80001e1e:	02c7ea63          	bltu	a5,a2,80001e52 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001e22:	4691                	li	a3,4
    80001e24:	6928                	ld	a0,80(a0)
    80001e26:	cc8ff0ef          	jal	800012ee <uvmalloc>
    80001e2a:	85aa                	mv	a1,a0
    80001e2c:	c50d                	beqz	a0,80001e56 <growproc+0x5e>
  p->sz = sz;
    80001e2e:	04b93423          	sd	a1,72(s2)
  return 0;
    80001e32:	4501                	li	a0,0
}
    80001e34:	60e2                	ld	ra,24(sp)
    80001e36:	6442                	ld	s0,16(sp)
    80001e38:	64a2                	ld	s1,8(sp)
    80001e3a:	6902                	ld	s2,0(sp)
    80001e3c:	6105                	addi	sp,sp,32
    80001e3e:	8082                	ret
  } else if (n < 0) {
    80001e40:	fe04d7e3          	bgez	s1,80001e2e <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e44:	00b48633          	add	a2,s1,a1
    80001e48:	6928                	ld	a0,80(a0)
    80001e4a:	c60ff0ef          	jal	800012aa <uvmdealloc>
    80001e4e:	85aa                	mv	a1,a0
    80001e50:	bff9                	j	80001e2e <growproc+0x36>
      return -1;
    80001e52:	557d                	li	a0,-1
    80001e54:	b7c5                	j	80001e34 <growproc+0x3c>
      return -1;
    80001e56:	557d                	li	a0,-1
    80001e58:	bff1                	j	80001e34 <growproc+0x3c>

0000000080001e5a <kfork>:
{
    80001e5a:	7139                	addi	sp,sp,-64
    80001e5c:	fc06                	sd	ra,56(sp)
    80001e5e:	f822                	sd	s0,48(sp)
    80001e60:	f426                	sd	s1,40(sp)
    80001e62:	e456                	sd	s5,8(sp)
    80001e64:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e66:	c95ff0ef          	jal	80001afa <myproc>
    80001e6a:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001e6c:	eabff0ef          	jal	80001d16 <allocproc>
    80001e70:	0e050a63          	beqz	a0,80001f64 <kfork+0x10a>
    80001e74:	e852                	sd	s4,16(sp)
    80001e76:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001e78:	048ab603          	ld	a2,72(s5)
    80001e7c:	692c                	ld	a1,80(a0)
    80001e7e:	050ab503          	ld	a0,80(s5)
    80001e82:	da4ff0ef          	jal	80001426 <uvmcopy>
    80001e86:	04054863          	bltz	a0,80001ed6 <kfork+0x7c>
    80001e8a:	f04a                	sd	s2,32(sp)
    80001e8c:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e8e:	048ab783          	ld	a5,72(s5)
    80001e92:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e96:	058ab683          	ld	a3,88(s5)
    80001e9a:	87b6                	mv	a5,a3
    80001e9c:	058a3703          	ld	a4,88(s4)
    80001ea0:	12068693          	addi	a3,a3,288
    80001ea4:	6388                	ld	a0,0(a5)
    80001ea6:	678c                	ld	a1,8(a5)
    80001ea8:	6b90                	ld	a2,16(a5)
    80001eaa:	e308                	sd	a0,0(a4)
    80001eac:	e70c                	sd	a1,8(a4)
    80001eae:	eb10                	sd	a2,16(a4)
    80001eb0:	6f90                	ld	a2,24(a5)
    80001eb2:	ef10                	sd	a2,24(a4)
    80001eb4:	02078793          	addi	a5,a5,32
    80001eb8:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001ebc:	fed794e3          	bne	a5,a3,80001ea4 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001ec0:	058a3783          	ld	a5,88(s4)
    80001ec4:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001ec8:	0d0a8493          	addi	s1,s5,208
    80001ecc:	0d0a0913          	addi	s2,s4,208
    80001ed0:	150a8993          	addi	s3,s5,336
    80001ed4:	a831                	j	80001ef0 <kfork+0x96>
    freeproc(np);
    80001ed6:	8552                	mv	a0,s4
    80001ed8:	df3ff0ef          	jal	80001cca <freeproc>
    release(&np->lock);
    80001edc:	8552                	mv	a0,s4
    80001ede:	dd3fe0ef          	jal	80000cb0 <release>
    return -1;
    80001ee2:	54fd                	li	s1,-1
    80001ee4:	6a42                	ld	s4,16(sp)
    80001ee6:	a885                	j	80001f56 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001ee8:	04a1                	addi	s1,s1,8
    80001eea:	0921                	addi	s2,s2,8
    80001eec:	01348963          	beq	s1,s3,80001efe <kfork+0xa4>
    if (p->ofile[i])
    80001ef0:	6088                	ld	a0,0(s1)
    80001ef2:	d97d                	beqz	a0,80001ee8 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ef4:	42e020ef          	jal	80004322 <filedup>
    80001ef8:	00a93023          	sd	a0,0(s2)
    80001efc:	b7f5                	j	80001ee8 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001efe:	150ab503          	ld	a0,336(s5)
    80001f02:	4fe010ef          	jal	80003400 <idup>
    80001f06:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f0a:	4641                	li	a2,16
    80001f0c:	158a8593          	addi	a1,s5,344
    80001f10:	158a0513          	addi	a0,s4,344
    80001f14:	f29fe0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001f18:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001f1c:	8552                	mv	a0,s4
    80001f1e:	d93fe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001f22:	00010517          	auipc	a0,0x10
    80001f26:	6ee50513          	addi	a0,a0,1774 # 80012610 <wait_lock>
    80001f2a:	cfffe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001f2e:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f32:	00010517          	auipc	a0,0x10
    80001f36:	6de50513          	addi	a0,a0,1758 # 80012610 <wait_lock>
    80001f3a:	d77fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001f3e:	8552                	mv	a0,s4
    80001f40:	ce9fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001f44:	478d                	li	a5,3
    80001f46:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f4a:	8552                	mv	a0,s4
    80001f4c:	d65fe0ef          	jal	80000cb0 <release>
  return pid;
    80001f50:	7902                	ld	s2,32(sp)
    80001f52:	69e2                	ld	s3,24(sp)
    80001f54:	6a42                	ld	s4,16(sp)
}
    80001f56:	8526                	mv	a0,s1
    80001f58:	70e2                	ld	ra,56(sp)
    80001f5a:	7442                	ld	s0,48(sp)
    80001f5c:	74a2                	ld	s1,40(sp)
    80001f5e:	6aa2                	ld	s5,8(sp)
    80001f60:	6121                	addi	sp,sp,64
    80001f62:	8082                	ret
    return -1;
    80001f64:	54fd                	li	s1,-1
    80001f66:	bfc5                	j	80001f56 <kfork+0xfc>

0000000080001f68 <scheduler>:
{
    80001f68:	711d                	addi	sp,sp,-96
    80001f6a:	ec86                	sd	ra,88(sp)
    80001f6c:	e8a2                	sd	s0,80(sp)
    80001f6e:	e4a6                	sd	s1,72(sp)
    80001f70:	e0ca                	sd	s2,64(sp)
    80001f72:	fc4e                	sd	s3,56(sp)
    80001f74:	f852                	sd	s4,48(sp)
    80001f76:	f456                	sd	s5,40(sp)
    80001f78:	f05a                	sd	s6,32(sp)
    80001f7a:	ec5e                	sd	s7,24(sp)
    80001f7c:	e862                	sd	s8,16(sp)
    80001f7e:	e466                	sd	s9,8(sp)
    80001f80:	1080                	addi	s0,sp,96
    80001f82:	8792                	mv	a5,tp
  int id = r_tp();
    80001f84:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f86:	00779a93          	slli	s5,a5,0x7
    80001f8a:	00010717          	auipc	a4,0x10
    80001f8e:	66e70713          	addi	a4,a4,1646 # 800125f8 <pid_lock>
    80001f92:	9756                	add	a4,a4,s5
    80001f94:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f98:	00010717          	auipc	a4,0x10
    80001f9c:	69870713          	addi	a4,a4,1688 # 80012630 <cpus+0x8>
    80001fa0:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001fa2:	4c11                	li	s8,4
        c->proc = p;
    80001fa4:	00010b17          	auipc	s6,0x10
    80001fa8:	654b0b13          	addi	s6,s6,1620 # 800125f8 <pid_lock>
    80001fac:	079e                	slli	a5,a5,0x7
    80001fae:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001fb2:	4b85                	li	s7,1
    80001fb4:	a0a9                	j	80001ffe <scheduler+0x96>
      release(&p->lock);
    80001fb6:	8526                	mv	a0,s1
    80001fb8:	cf9fe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001fbc:	16848493          	addi	s1,s1,360
    80001fc0:	03248b63          	beq	s1,s2,80001ff6 <scheduler+0x8e>
      acquire(&p->lock);
    80001fc4:	8526                	mv	a0,s1
    80001fc6:	c63fe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001fca:	4c9c                	lw	a5,24(s1)
    80001fcc:	ff3795e3          	bne	a5,s3,80001fb6 <scheduler+0x4e>
        p->state = RUNNING;
    80001fd0:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001fd4:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fd8:	06048593          	addi	a1,s1,96
    80001fdc:	8556                	mv	a0,s5
    80001fde:	5f4000ef          	jal	800025d2 <swtch>
    80001fe2:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001fe4:	2781                	sext.w	a5,a5
    80001fe6:	079e                	slli	a5,a5,0x7
    80001fe8:	97da                	add	a5,a5,s6
    80001fea:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001fee:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001ff2:	8cde                	mv	s9,s7
    80001ff4:	b7c9                	j	80001fb6 <scheduler+0x4e>
    if (found == 0) {
    80001ff6:	000c9463          	bnez	s9,80001ffe <scheduler+0x96>
      asm volatile("wfi");
    80001ffa:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001ffe:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002002:	10017073          	csrci	sstatus,2
    int found = 0;
    80002006:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80002008:	00011497          	auipc	s1,0x11
    8000200c:	a2048493          	addi	s1,s1,-1504 # 80012a28 <proc>
      if (p->state == RUNNABLE) {
    80002010:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80002012:	00016917          	auipc	s2,0x16
    80002016:	41690913          	addi	s2,s2,1046 # 80018428 <tickslock>
    8000201a:	b76d                	j	80001fc4 <scheduler+0x5c>

000000008000201c <sched>:
{
    8000201c:	7179                	addi	sp,sp,-48
    8000201e:	f406                	sd	ra,40(sp)
    80002020:	f022                	sd	s0,32(sp)
    80002022:	ec26                	sd	s1,24(sp)
    80002024:	e84a                	sd	s2,16(sp)
    80002026:	e44e                	sd	s3,8(sp)
    80002028:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000202a:	ad1ff0ef          	jal	80001afa <myproc>
    8000202e:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002030:	b93fe0ef          	jal	80000bc2 <holding>
    80002034:	c935                	beqz	a0,800020a8 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80002036:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002038:	2781                	sext.w	a5,a5
    8000203a:	079e                	slli	a5,a5,0x7
    8000203c:	00010717          	auipc	a4,0x10
    80002040:	5bc70713          	addi	a4,a4,1468 # 800125f8 <pid_lock>
    80002044:	97ba                	add	a5,a5,a4
    80002046:	0a87a703          	lw	a4,168(a5)
    8000204a:	4785                	li	a5,1
    8000204c:	06f71463          	bne	a4,a5,800020b4 <sched+0x98>
  if (p->state == RUNNING)
    80002050:	4c98                	lw	a4,24(s1)
    80002052:	4791                	li	a5,4
    80002054:	06f70663          	beq	a4,a5,800020c0 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002058:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000205c:	8b89                	andi	a5,a5,2
  if (intr_get())
    8000205e:	e7bd                	bnez	a5,800020cc <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80002060:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002062:	00010917          	auipc	s2,0x10
    80002066:	59690913          	addi	s2,s2,1430 # 800125f8 <pid_lock>
    8000206a:	2781                	sext.w	a5,a5
    8000206c:	079e                	slli	a5,a5,0x7
    8000206e:	97ca                	add	a5,a5,s2
    80002070:	0ac7a983          	lw	s3,172(a5)
    80002074:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002076:	2781                	sext.w	a5,a5
    80002078:	079e                	slli	a5,a5,0x7
    8000207a:	07a1                	addi	a5,a5,8
    8000207c:	00010597          	auipc	a1,0x10
    80002080:	5ac58593          	addi	a1,a1,1452 # 80012628 <cpus>
    80002084:	95be                	add	a1,a1,a5
    80002086:	06048513          	addi	a0,s1,96
    8000208a:	548000ef          	jal	800025d2 <swtch>
    8000208e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002090:	2781                	sext.w	a5,a5
    80002092:	079e                	slli	a5,a5,0x7
    80002094:	993e                	add	s2,s2,a5
    80002096:	0b392623          	sw	s3,172(s2)
}
    8000209a:	70a2                	ld	ra,40(sp)
    8000209c:	7402                	ld	s0,32(sp)
    8000209e:	64e2                	ld	s1,24(sp)
    800020a0:	6942                	ld	s2,16(sp)
    800020a2:	69a2                	ld	s3,8(sp)
    800020a4:	6145                	addi	sp,sp,48
    800020a6:	8082                	ret
    panic("sched p->lock");
    800020a8:	00005517          	auipc	a0,0x5
    800020ac:	27050513          	addi	a0,a0,624 # 80007318 <etext+0x318>
    800020b0:	f84fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    800020b4:	00005517          	auipc	a0,0x5
    800020b8:	27450513          	addi	a0,a0,628 # 80007328 <etext+0x328>
    800020bc:	f78fe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    800020c0:	00005517          	auipc	a0,0x5
    800020c4:	27850513          	addi	a0,a0,632 # 80007338 <etext+0x338>
    800020c8:	f6cfe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    800020cc:	00005517          	auipc	a0,0x5
    800020d0:	27c50513          	addi	a0,a0,636 # 80007348 <etext+0x348>
    800020d4:	f60fe0ef          	jal	80000834 <panic>

00000000800020d8 <yield>:
{
    800020d8:	1101                	addi	sp,sp,-32
    800020da:	ec06                	sd	ra,24(sp)
    800020dc:	e822                	sd	s0,16(sp)
    800020de:	e426                	sd	s1,8(sp)
    800020e0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020e2:	a19ff0ef          	jal	80001afa <myproc>
    800020e6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020e8:	b41fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    800020ec:	478d                	li	a5,3
    800020ee:	cc9c                	sw	a5,24(s1)
  sched();
    800020f0:	f2dff0ef          	jal	8000201c <sched>
  release(&p->lock);
    800020f4:	8526                	mv	a0,s1
    800020f6:	bbbfe0ef          	jal	80000cb0 <release>
}
    800020fa:	60e2                	ld	ra,24(sp)
    800020fc:	6442                	ld	s0,16(sp)
    800020fe:	64a2                	ld	s1,8(sp)
    80002100:	6105                	addi	sp,sp,32
    80002102:	8082                	ret

0000000080002104 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80002104:	1101                	addi	sp,sp,-32
    80002106:	ec06                	sd	ra,24(sp)
    80002108:	e822                	sd	s0,16(sp)
    8000210a:	e426                	sd	s1,8(sp)
    8000210c:	e04a                	sd	s2,0(sp)
    8000210e:	1000                	addi	s0,sp,32
    80002110:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002112:	9e9ff0ef          	jal	80001afa <myproc>
    80002116:	892a                	mv	s2,a0

  acquire(&p->lock);
    80002118:	b11fe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    8000211c:	cc81                	beqz	s1,80002134 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    8000211e:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80002122:	854a                	mv	a0,s2
    80002124:	b8dfe0ef          	jal	80000cb0 <release>
}
    80002128:	60e2                	ld	ra,24(sp)
    8000212a:	6442                	ld	s0,16(sp)
    8000212c:	64a2                	ld	s1,8(sp)
    8000212e:	6902                	ld	s2,0(sp)
    80002130:	6105                	addi	sp,sp,32
    80002132:	8082                	ret
    panic("sleep_prepare: zero chan");
    80002134:	00005517          	auipc	a0,0x5
    80002138:	22c50513          	addi	a0,a0,556 # 80007360 <etext+0x360>
    8000213c:	ef8fe0ef          	jal	80000834 <panic>

0000000080002140 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80002140:	1101                	addi	sp,sp,-32
    80002142:	ec06                	sd	ra,24(sp)
    80002144:	e822                	sd	s0,16(sp)
    80002146:	e426                	sd	s1,8(sp)
    80002148:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000214a:	9b1ff0ef          	jal	80001afa <myproc>
    8000214e:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80002150:	ad9fe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    80002154:	709c                	ld	a5,32(s1)
    80002156:	c789                	beqz	a5,80002160 <sleep+0x20>
    p->state = SLEEPING;
    80002158:	4789                	li	a5,2
    8000215a:	cc9c                	sw	a5,24(s1)
    sched();
    8000215c:	ec1ff0ef          	jal	8000201c <sched>
  }
  release(&p->lock);
    80002160:	8526                	mv	a0,s1
    80002162:	b4ffe0ef          	jal	80000cb0 <release>
}
    80002166:	60e2                	ld	ra,24(sp)
    80002168:	6442                	ld	s0,16(sp)
    8000216a:	64a2                	ld	s1,8(sp)
    8000216c:	6105                	addi	sp,sp,32
    8000216e:	8082                	ret

0000000080002170 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80002170:	7139                	addi	sp,sp,-64
    80002172:	fc06                	sd	ra,56(sp)
    80002174:	f822                	sd	s0,48(sp)
    80002176:	f426                	sd	s1,40(sp)
    80002178:	f04a                	sd	s2,32(sp)
    8000217a:	ec4e                	sd	s3,24(sp)
    8000217c:	e852                	sd	s4,16(sp)
    8000217e:	e456                	sd	s5,8(sp)
    80002180:	0080                	addi	s0,sp,64
    80002182:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002184:	00011497          	auipc	s1,0x11
    80002188:	8a448493          	addi	s1,s1,-1884 # 80012a28 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    8000218c:	4a09                	li	s4,2
        p->state = RUNNABLE;
    8000218e:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80002190:	00016997          	auipc	s3,0x16
    80002194:	29898993          	addi	s3,s3,664 # 80018428 <tickslock>
    80002198:	a801                	j	800021a8 <wakeup+0x38>
      }
    }
    release(&p->lock);
    8000219a:	8526                	mv	a0,s1
    8000219c:	b15fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800021a0:	16848493          	addi	s1,s1,360
    800021a4:	03348063          	beq	s1,s3,800021c4 <wakeup+0x54>
    acquire(&p->lock);
    800021a8:	8526                	mv	a0,s1
    800021aa:	a7ffe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    800021ae:	709c                	ld	a5,32(s1)
    800021b0:	ff2795e3          	bne	a5,s2,8000219a <wakeup+0x2a>
      p->chan = 0;
    800021b4:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    800021b8:	4c9c                	lw	a5,24(s1)
    800021ba:	ff4790e3          	bne	a5,s4,8000219a <wakeup+0x2a>
        p->state = RUNNABLE;
    800021be:	0154ac23          	sw	s5,24(s1)
    800021c2:	bfe1                	j	8000219a <wakeup+0x2a>
  }
}
    800021c4:	70e2                	ld	ra,56(sp)
    800021c6:	7442                	ld	s0,48(sp)
    800021c8:	74a2                	ld	s1,40(sp)
    800021ca:	7902                	ld	s2,32(sp)
    800021cc:	69e2                	ld	s3,24(sp)
    800021ce:	6a42                	ld	s4,16(sp)
    800021d0:	6aa2                	ld	s5,8(sp)
    800021d2:	6121                	addi	sp,sp,64
    800021d4:	8082                	ret

00000000800021d6 <reparent>:
{
    800021d6:	7179                	addi	sp,sp,-48
    800021d8:	f406                	sd	ra,40(sp)
    800021da:	f022                	sd	s0,32(sp)
    800021dc:	ec26                	sd	s1,24(sp)
    800021de:	e84a                	sd	s2,16(sp)
    800021e0:	e44e                	sd	s3,8(sp)
    800021e2:	e052                	sd	s4,0(sp)
    800021e4:	1800                	addi	s0,sp,48
    800021e6:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021e8:	00011497          	auipc	s1,0x11
    800021ec:	84048493          	addi	s1,s1,-1984 # 80012a28 <proc>
      pp->parent = initproc;
    800021f0:	00008a17          	auipc	s4,0x8
    800021f4:	300a0a13          	addi	s4,s4,768 # 8000a4f0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021f8:	00016997          	auipc	s3,0x16
    800021fc:	23098993          	addi	s3,s3,560 # 80018428 <tickslock>
    80002200:	a029                	j	8000220a <reparent+0x34>
    80002202:	16848493          	addi	s1,s1,360
    80002206:	01348b63          	beq	s1,s3,8000221c <reparent+0x46>
    if (pp->parent == p) {
    8000220a:	7c9c                	ld	a5,56(s1)
    8000220c:	ff279be3          	bne	a5,s2,80002202 <reparent+0x2c>
      pp->parent = initproc;
    80002210:	000a3503          	ld	a0,0(s4)
    80002214:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002216:	f5bff0ef          	jal	80002170 <wakeup>
    8000221a:	b7e5                	j	80002202 <reparent+0x2c>
}
    8000221c:	70a2                	ld	ra,40(sp)
    8000221e:	7402                	ld	s0,32(sp)
    80002220:	64e2                	ld	s1,24(sp)
    80002222:	6942                	ld	s2,16(sp)
    80002224:	69a2                	ld	s3,8(sp)
    80002226:	6a02                	ld	s4,0(sp)
    80002228:	6145                	addi	sp,sp,48
    8000222a:	8082                	ret

000000008000222c <kexit>:
{
    8000222c:	7179                	addi	sp,sp,-48
    8000222e:	f406                	sd	ra,40(sp)
    80002230:	f022                	sd	s0,32(sp)
    80002232:	ec26                	sd	s1,24(sp)
    80002234:	e84a                	sd	s2,16(sp)
    80002236:	e44e                	sd	s3,8(sp)
    80002238:	e052                	sd	s4,0(sp)
    8000223a:	1800                	addi	s0,sp,48
    8000223c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000223e:	8bdff0ef          	jal	80001afa <myproc>
    80002242:	89aa                	mv	s3,a0
  if (p == initproc)
    80002244:	00008797          	auipc	a5,0x8
    80002248:	2ac7b783          	ld	a5,684(a5) # 8000a4f0 <initproc>
    8000224c:	0d050493          	addi	s1,a0,208
    80002250:	15050913          	addi	s2,a0,336
    80002254:	00a79b63          	bne	a5,a0,8000226a <kexit+0x3e>
    panic("init exiting");
    80002258:	00005517          	auipc	a0,0x5
    8000225c:	12850513          	addi	a0,a0,296 # 80007380 <etext+0x380>
    80002260:	dd4fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002264:	04a1                	addi	s1,s1,8
    80002266:	01248963          	beq	s1,s2,80002278 <kexit+0x4c>
    if (p->ofile[fd]) {
    8000226a:	6088                	ld	a0,0(s1)
    8000226c:	dd65                	beqz	a0,80002264 <kexit+0x38>
      fileclose(f);
    8000226e:	0fa020ef          	jal	80004368 <fileclose>
      p->ofile[fd] = 0;
    80002272:	0004b023          	sd	zero,0(s1)
    80002276:	b7fd                	j	80002264 <kexit+0x38>
  begin_op();
    80002278:	437010ef          	jal	80003eae <begin_op>
  iput(p->cwd);
    8000227c:	1509b503          	ld	a0,336(s3)
    80002280:	338010ef          	jal	800035b8 <iput>
  end_op();
    80002284:	4b7010ef          	jal	80003f3a <end_op>
  p->cwd = 0;
    80002288:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000228c:	00010517          	auipc	a0,0x10
    80002290:	38450513          	addi	a0,a0,900 # 80012610 <wait_lock>
    80002294:	995fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    80002298:	854e                	mv	a0,s3
    8000229a:	f3dff0ef          	jal	800021d6 <reparent>
  wakeup(p->parent);
    8000229e:	0389b503          	ld	a0,56(s3)
    800022a2:	ecfff0ef          	jal	80002170 <wakeup>
  acquire(&p->lock);
    800022a6:	854e                	mv	a0,s3
    800022a8:	981fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    800022ac:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022b0:	4795                	li	a5,5
    800022b2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022b6:	00010517          	auipc	a0,0x10
    800022ba:	35a50513          	addi	a0,a0,858 # 80012610 <wait_lock>
    800022be:	9f3fe0ef          	jal	80000cb0 <release>
  sched();
    800022c2:	d5bff0ef          	jal	8000201c <sched>
  panic("zombie exit");
    800022c6:	00005517          	auipc	a0,0x5
    800022ca:	0ca50513          	addi	a0,a0,202 # 80007390 <etext+0x390>
    800022ce:	d66fe0ef          	jal	80000834 <panic>

00000000800022d2 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    800022d2:	c525                	beqz	a0,8000233a <kkill+0x68>
{
    800022d4:	7179                	addi	sp,sp,-48
    800022d6:	f406                	sd	ra,40(sp)
    800022d8:	f022                	sd	s0,32(sp)
    800022da:	ec26                	sd	s1,24(sp)
    800022dc:	e84a                	sd	s2,16(sp)
    800022de:	e44e                	sd	s3,8(sp)
    800022e0:	1800                	addi	s0,sp,48
    800022e2:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    800022e4:	00010497          	auipc	s1,0x10
    800022e8:	74448493          	addi	s1,s1,1860 # 80012a28 <proc>
    800022ec:	00016997          	auipc	s3,0x16
    800022f0:	13c98993          	addi	s3,s3,316 # 80018428 <tickslock>
    acquire(&p->lock);
    800022f4:	8526                	mv	a0,s1
    800022f6:	933fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    800022fa:	589c                	lw	a5,48(s1)
    800022fc:	01278b63          	beq	a5,s2,80002312 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002300:	8526                	mv	a0,s1
    80002302:	9affe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002306:	16848493          	addi	s1,s1,360
    8000230a:	ff3495e3          	bne	s1,s3,800022f4 <kkill+0x22>
  }
  return -1;
    8000230e:	557d                	li	a0,-1
    80002310:	a819                	j	80002326 <kkill+0x54>
      p->killed = 1;
    80002312:	4785                	li	a5,1
    80002314:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002316:	4c98                	lw	a4,24(s1)
    80002318:	4789                	li	a5,2
    8000231a:	00f70d63          	beq	a4,a5,80002334 <kkill+0x62>
      release(&p->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	991fe0ef          	jal	80000cb0 <release>
      return 0;
    80002324:	4501                	li	a0,0
}
    80002326:	70a2                	ld	ra,40(sp)
    80002328:	7402                	ld	s0,32(sp)
    8000232a:	64e2                	ld	s1,24(sp)
    8000232c:	6942                	ld	s2,16(sp)
    8000232e:	69a2                	ld	s3,8(sp)
    80002330:	6145                	addi	sp,sp,48
    80002332:	8082                	ret
        p->state = RUNNABLE;
    80002334:	478d                	li	a5,3
    80002336:	cc9c                	sw	a5,24(s1)
    80002338:	b7dd                	j	8000231e <kkill+0x4c>
    return -1;
    8000233a:	557d                	li	a0,-1
}
    8000233c:	8082                	ret

000000008000233e <setkilled>:

void
setkilled(struct proc *p)
{
    8000233e:	1101                	addi	sp,sp,-32
    80002340:	ec06                	sd	ra,24(sp)
    80002342:	e822                	sd	s0,16(sp)
    80002344:	e426                	sd	s1,8(sp)
    80002346:	1000                	addi	s0,sp,32
    80002348:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000234a:	8dffe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    8000234e:	4785                	li	a5,1
    80002350:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002352:	8526                	mv	a0,s1
    80002354:	95dfe0ef          	jal	80000cb0 <release>
}
    80002358:	60e2                	ld	ra,24(sp)
    8000235a:	6442                	ld	s0,16(sp)
    8000235c:	64a2                	ld	s1,8(sp)
    8000235e:	6105                	addi	sp,sp,32
    80002360:	8082                	ret

0000000080002362 <killed>:

int
killed(struct proc *p)
{
    80002362:	1101                	addi	sp,sp,-32
    80002364:	ec06                	sd	ra,24(sp)
    80002366:	e822                	sd	s0,16(sp)
    80002368:	e426                	sd	s1,8(sp)
    8000236a:	e04a                	sd	s2,0(sp)
    8000236c:	1000                	addi	s0,sp,32
    8000236e:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002370:	8b9fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80002374:	549c                	lw	a5,40(s1)
    80002376:	893e                	mv	s2,a5
  release(&p->lock);
    80002378:	8526                	mv	a0,s1
    8000237a:	937fe0ef          	jal	80000cb0 <release>
  return k;
}
    8000237e:	854a                	mv	a0,s2
    80002380:	60e2                	ld	ra,24(sp)
    80002382:	6442                	ld	s0,16(sp)
    80002384:	64a2                	ld	s1,8(sp)
    80002386:	6902                	ld	s2,0(sp)
    80002388:	6105                	addi	sp,sp,32
    8000238a:	8082                	ret

000000008000238c <kwait>:
{
    8000238c:	715d                	addi	sp,sp,-80
    8000238e:	e486                	sd	ra,72(sp)
    80002390:	e0a2                	sd	s0,64(sp)
    80002392:	fc26                	sd	s1,56(sp)
    80002394:	f84a                	sd	s2,48(sp)
    80002396:	f44e                	sd	s3,40(sp)
    80002398:	f052                	sd	s4,32(sp)
    8000239a:	ec56                	sd	s5,24(sp)
    8000239c:	e85a                	sd	s6,16(sp)
    8000239e:	e45e                	sd	s7,8(sp)
    800023a0:	0880                	addi	s0,sp,80
    800023a2:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800023a4:	f56ff0ef          	jal	80001afa <myproc>
    800023a8:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023aa:	00010517          	auipc	a0,0x10
    800023ae:	26650513          	addi	a0,a0,614 # 80012610 <wait_lock>
    800023b2:	877fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800023b6:	4a15                	li	s4,5
        havekids = 1;
    800023b8:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800023ba:	00016997          	auipc	s3,0x16
    800023be:	06e98993          	addi	s3,s3,110 # 80018428 <tickslock>
    release(&wait_lock);
    800023c2:	00010b17          	auipc	s6,0x10
    800023c6:	24eb0b13          	addi	s6,s6,590 # 80012610 <wait_lock>
    800023ca:	a845                	j	8000247a <kwait+0xee>
          pid = pp->pid;
    800023cc:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    800023d0:	000b8e63          	beqz	s7,800023ec <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    800023d4:	4711                	li	a4,4
    800023d6:	02c48693          	addi	a3,s1,44
    800023da:	865e                	mv	a2,s7
    800023dc:	04893583          	ld	a1,72(s2)
    800023e0:	05093503          	ld	a0,80(s2)
    800023e4:	99eff0ef          	jal	80001582 <copyout>
          if (addr != 0 &&
    800023e8:	02054c63          	bltz	a0,80002420 <kwait+0x94>
          pp->parent = 0;
    800023ec:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    800023f0:	8526                	mv	a0,s1
    800023f2:	8d9ff0ef          	jal	80001cca <freeproc>
          release(&pp->lock);
    800023f6:	8526                	mv	a0,s1
    800023f8:	8b9fe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    800023fc:	00010517          	auipc	a0,0x10
    80002400:	21450513          	addi	a0,a0,532 # 80012610 <wait_lock>
    80002404:	8adfe0ef          	jal	80000cb0 <release>
}
    80002408:	854e                	mv	a0,s3
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
            release(&pp->lock);
    80002420:	8526                	mv	a0,s1
    80002422:	88ffe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    80002426:	00010517          	auipc	a0,0x10
    8000242a:	1ea50513          	addi	a0,a0,490 # 80012610 <wait_lock>
    8000242e:	883fe0ef          	jal	80000cb0 <release>
            return -1;
    80002432:	59fd                	li	s3,-1
    80002434:	bfd1                	j	80002408 <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002436:	16848493          	addi	s1,s1,360
    8000243a:	03348063          	beq	s1,s3,8000245a <kwait+0xce>
      if (pp->parent == p) {
    8000243e:	7c9c                	ld	a5,56(s1)
    80002440:	ff279be3          	bne	a5,s2,80002436 <kwait+0xaa>
        acquire(&pp->lock);
    80002444:	8526                	mv	a0,s1
    80002446:	fe2fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    8000244a:	4c9c                	lw	a5,24(s1)
    8000244c:	f94780e3          	beq	a5,s4,800023cc <kwait+0x40>
        release(&pp->lock);
    80002450:	8526                	mv	a0,s1
    80002452:	85ffe0ef          	jal	80000cb0 <release>
        havekids = 1;
    80002456:	8756                	mv	a4,s5
    80002458:	bff9                	j	80002436 <kwait+0xaa>
    if (!havekids || killed(p)) {
    8000245a:	c715                	beqz	a4,80002486 <kwait+0xfa>
    8000245c:	854a                	mv	a0,s2
    8000245e:	f05ff0ef          	jal	80002362 <killed>
    80002462:	e115                	bnez	a0,80002486 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    80002464:	854a                	mv	a0,s2
    80002466:	c9fff0ef          	jal	80002104 <sleep_prepare>
    release(&wait_lock);
    8000246a:	855a                	mv	a0,s6
    8000246c:	845fe0ef          	jal	80000cb0 <release>
    sleep();
    80002470:	cd1ff0ef          	jal	80002140 <sleep>
    acquire(&wait_lock);
    80002474:	855a                	mv	a0,s6
    80002476:	fb2fe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    8000247a:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000247c:	00010497          	auipc	s1,0x10
    80002480:	5ac48493          	addi	s1,s1,1452 # 80012a28 <proc>
    80002484:	bf6d                	j	8000243e <kwait+0xb2>
      release(&wait_lock);
    80002486:	00010517          	auipc	a0,0x10
    8000248a:	18a50513          	addi	a0,a0,394 # 80012610 <wait_lock>
    8000248e:	823fe0ef          	jal	80000cb0 <release>
      return -1;
    80002492:	59fd                	li	s3,-1
    80002494:	bf95                	j	80002408 <kwait+0x7c>

0000000080002496 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002496:	7179                	addi	sp,sp,-48
    80002498:	f406                	sd	ra,40(sp)
    8000249a:	f022                	sd	s0,32(sp)
    8000249c:	ec26                	sd	s1,24(sp)
    8000249e:	e84a                	sd	s2,16(sp)
    800024a0:	e44e                	sd	s3,8(sp)
    800024a2:	e052                	sd	s4,0(sp)
    800024a4:	1800                	addi	s0,sp,48
    800024a6:	84aa                	mv	s1,a0
    800024a8:	8a2e                	mv	s4,a1
    800024aa:	89b2                	mv	s3,a2
    800024ac:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800024ae:	e4cff0ef          	jal	80001afa <myproc>
  if (user_dst) {
    800024b2:	c085                	beqz	s1,800024d2 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    800024b4:	874a                	mv	a4,s2
    800024b6:	86ce                	mv	a3,s3
    800024b8:	8652                	mv	a2,s4
    800024ba:	652c                	ld	a1,72(a0)
    800024bc:	6928                	ld	a0,80(a0)
    800024be:	8c4ff0ef          	jal	80001582 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024c2:	70a2                	ld	ra,40(sp)
    800024c4:	7402                	ld	s0,32(sp)
    800024c6:	64e2                	ld	s1,24(sp)
    800024c8:	6942                	ld	s2,16(sp)
    800024ca:	69a2                	ld	s3,8(sp)
    800024cc:	6a02                	ld	s4,0(sp)
    800024ce:	6145                	addi	sp,sp,48
    800024d0:	8082                	ret
    memmove((char *)dst, src, len);
    800024d2:	0009061b          	sext.w	a2,s2
    800024d6:	85ce                	mv	a1,s3
    800024d8:	8552                	mv	a0,s4
    800024da:	86ffe0ef          	jal	80000d48 <memmove>
    return 0;
    800024de:	8526                	mv	a0,s1
    800024e0:	b7cd                	j	800024c2 <either_copyout+0x2c>

00000000800024e2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024e2:	7179                	addi	sp,sp,-48
    800024e4:	f406                	sd	ra,40(sp)
    800024e6:	f022                	sd	s0,32(sp)
    800024e8:	ec26                	sd	s1,24(sp)
    800024ea:	e84a                	sd	s2,16(sp)
    800024ec:	e44e                	sd	s3,8(sp)
    800024ee:	e052                	sd	s4,0(sp)
    800024f0:	1800                	addi	s0,sp,48
    800024f2:	8a2a                	mv	s4,a0
    800024f4:	84ae                	mv	s1,a1
    800024f6:	89b2                	mv	s3,a2
    800024f8:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800024fa:	e00ff0ef          	jal	80001afa <myproc>
  if (user_src) {
    800024fe:	c085                	beqz	s1,8000251e <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    80002500:	874a                	mv	a4,s2
    80002502:	86ce                	mv	a3,s3
    80002504:	8652                	mv	a2,s4
    80002506:	652c                	ld	a1,72(a0)
    80002508:	6928                	ld	a0,80(a0)
    8000250a:	93eff0ef          	jal	80001648 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000250e:	70a2                	ld	ra,40(sp)
    80002510:	7402                	ld	s0,32(sp)
    80002512:	64e2                	ld	s1,24(sp)
    80002514:	6942                	ld	s2,16(sp)
    80002516:	69a2                	ld	s3,8(sp)
    80002518:	6a02                	ld	s4,0(sp)
    8000251a:	6145                	addi	sp,sp,48
    8000251c:	8082                	ret
    memmove(dst, (char *)src, len);
    8000251e:	0009061b          	sext.w	a2,s2
    80002522:	85ce                	mv	a1,s3
    80002524:	8552                	mv	a0,s4
    80002526:	823fe0ef          	jal	80000d48 <memmove>
    return 0;
    8000252a:	8526                	mv	a0,s1
    8000252c:	b7cd                	j	8000250e <either_copyin+0x2c>

000000008000252e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000252e:	715d                	addi	sp,sp,-80
    80002530:	e486                	sd	ra,72(sp)
    80002532:	e0a2                	sd	s0,64(sp)
    80002534:	fc26                	sd	s1,56(sp)
    80002536:	f84a                	sd	s2,48(sp)
    80002538:	f44e                	sd	s3,40(sp)
    8000253a:	f052                	sd	s4,32(sp)
    8000253c:	ec56                	sd	s5,24(sp)
    8000253e:	e85a                	sd	s6,16(sp)
    80002540:	e45e                	sd	s7,8(sp)
    80002542:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002544:	00005517          	auipc	a0,0x5
    80002548:	cac50513          	addi	a0,a0,-852 # 800071f0 <etext+0x1f0>
    8000254c:	fbffd0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002550:	00010497          	auipc	s1,0x10
    80002554:	63048493          	addi	s1,s1,1584 # 80012b80 <proc+0x158>
    80002558:	00016917          	auipc	s2,0x16
    8000255c:	02890913          	addi	s2,s2,40 # 80018580 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002560:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002562:	00005997          	auipc	s3,0x5
    80002566:	e3e98993          	addi	s3,s3,-450 # 800073a0 <etext+0x3a0>
    printk("%d %s %s", p->pid, state, p->name);
    8000256a:	00005a97          	auipc	s5,0x5
    8000256e:	e3ea8a93          	addi	s5,s5,-450 # 800073a8 <etext+0x3a8>
    printk("\n");
    80002572:	00005a17          	auipc	s4,0x5
    80002576:	c7ea0a13          	addi	s4,s4,-898 # 800071f0 <etext+0x1f0>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000257a:	00005b97          	auipc	s7,0x5
    8000257e:	34eb8b93          	addi	s7,s7,846 # 800078c8 <states.0>
    80002582:	a829                	j	8000259c <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002584:	ed86a583          	lw	a1,-296(a3)
    80002588:	8556                	mv	a0,s5
    8000258a:	f81fd0ef          	jal	8000050a <printk>
    printk("\n");
    8000258e:	8552                	mv	a0,s4
    80002590:	f7bfd0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002594:	16848493          	addi	s1,s1,360
    80002598:	03248263          	beq	s1,s2,800025bc <procdump+0x8e>
    if (p->state == UNUSED)
    8000259c:	86a6                	mv	a3,s1
    8000259e:	ec04a783          	lw	a5,-320(s1)
    800025a2:	dbed                	beqz	a5,80002594 <procdump+0x66>
      state = "???";
    800025a4:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a6:	fcfb6fe3          	bltu	s6,a5,80002584 <procdump+0x56>
    800025aa:	02079713          	slli	a4,a5,0x20
    800025ae:	01d75793          	srli	a5,a4,0x1d
    800025b2:	97de                	add	a5,a5,s7
    800025b4:	6390                	ld	a2,0(a5)
    800025b6:	f679                	bnez	a2,80002584 <procdump+0x56>
      state = "???";
    800025b8:	864e                	mv	a2,s3
    800025ba:	b7e9                	j	80002584 <procdump+0x56>
  }
}
    800025bc:	60a6                	ld	ra,72(sp)
    800025be:	6406                	ld	s0,64(sp)
    800025c0:	74e2                	ld	s1,56(sp)
    800025c2:	7942                	ld	s2,48(sp)
    800025c4:	79a2                	ld	s3,40(sp)
    800025c6:	7a02                	ld	s4,32(sp)
    800025c8:	6ae2                	ld	s5,24(sp)
    800025ca:	6b42                	ld	s6,16(sp)
    800025cc:	6ba2                	ld	s7,8(sp)
    800025ce:	6161                	addi	sp,sp,80
    800025d0:	8082                	ret

00000000800025d2 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800025d2:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800025d6:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800025da:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800025dc:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800025de:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800025e2:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800025e6:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800025ea:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800025ee:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800025f2:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800025f6:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800025fa:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800025fe:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002602:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002606:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000260a:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000260e:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002610:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002612:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002616:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000261a:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000261e:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002622:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002626:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000262a:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000262e:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002632:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002636:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000263a:	8082                	ret

000000008000263c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000263c:	1141                	addi	sp,sp,-16
    8000263e:	e406                	sd	ra,8(sp)
    80002640:	e022                	sd	s0,0(sp)
    80002642:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002644:	00005597          	auipc	a1,0x5
    80002648:	da458593          	addi	a1,a1,-604 # 800073e8 <etext+0x3e8>
    8000264c:	00016517          	auipc	a0,0x16
    80002650:	ddc50513          	addi	a0,a0,-548 # 80018428 <tickslock>
    80002654:	d54fe0ef          	jal	80000ba8 <initlock>
}
    80002658:	60a2                	ld	ra,8(sp)
    8000265a:	6402                	ld	s0,0(sp)
    8000265c:	0141                	addi	sp,sp,16
    8000265e:	8082                	ret

0000000080002660 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002660:	1141                	addi	sp,sp,-16
    80002662:	e406                	sd	ra,8(sp)
    80002664:	e022                	sd	s0,0(sp)
    80002666:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002668:	00003797          	auipc	a5,0x3
    8000266c:	18878793          	addi	a5,a5,392 # 800057f0 <kernelvec>
    80002670:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002674:	60a2                	ld	ra,8(sp)
    80002676:	6402                	ld	s0,0(sp)
    80002678:	0141                	addi	sp,sp,16
    8000267a:	8082                	ret

000000008000267c <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000267c:	1141                	addi	sp,sp,-16
    8000267e:	e406                	sd	ra,8(sp)
    80002680:	e022                	sd	s0,0(sp)
    80002682:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002684:	c76ff0ef          	jal	80001afa <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002688:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000268c:	04000737          	lui	a4,0x4000
    80002690:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002692:	0732                	slli	a4,a4,0xc
    80002694:	00004797          	auipc	a5,0x4
    80002698:	96c78793          	addi	a5,a5,-1684 # 80006000 <_trampoline>
    8000269c:	00004697          	auipc	a3,0x4
    800026a0:	96468693          	addi	a3,a3,-1692 # 80006000 <_trampoline>
    800026a4:	8f95                	sub	a5,a5,a3
    800026a6:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    800026a8:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026ac:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    800026ae:	18002773          	csrr	a4,satp
    800026b2:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026b4:	6d38                	ld	a4,88(a0)
    800026b6:	613c                	ld	a5,64(a0)
    800026b8:	6685                	lui	a3,0x1
    800026ba:	97b6                	add	a5,a5,a3
    800026bc:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026be:	6d3c                	ld	a5,88(a0)
    800026c0:	00000717          	auipc	a4,0x0
    800026c4:	0fc70713          	addi	a4,a4,252 # 800027bc <usertrap>
    800026c8:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800026ca:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    800026cc:	8712                	mv	a4,tp
    800026ce:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026d0:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026d4:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026d8:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800026dc:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026e0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800026e2:	6f9c                	ld	a5,24(a5)
    800026e4:	14179073          	csrw	sepc,a5
}
    800026e8:	60a2                	ld	ra,8(sp)
    800026ea:	6402                	ld	s0,0(sp)
    800026ec:	0141                	addi	sp,sp,16
    800026ee:	8082                	ret

00000000800026f0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026f0:	1141                	addi	sp,sp,-16
    800026f2:	e406                	sd	ra,8(sp)
    800026f4:	e022                	sd	s0,0(sp)
    800026f6:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    800026f8:	bceff0ef          	jal	80001ac6 <cpuid>
    800026fc:	cd11                	beqz	a0,80002718 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800026fe:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002702:	000f4737          	lui	a4,0xf4
    80002706:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000270a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000270c:	14d79073          	csrw	stimecmp,a5
}
    80002710:	60a2                	ld	ra,8(sp)
    80002712:	6402                	ld	s0,0(sp)
    80002714:	0141                	addi	sp,sp,16
    80002716:	8082                	ret
    acquire(&tickslock);
    80002718:	00016517          	auipc	a0,0x16
    8000271c:	d1050513          	addi	a0,a0,-752 # 80018428 <tickslock>
    80002720:	d08fe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002724:	00008717          	auipc	a4,0x8
    80002728:	dd470713          	addi	a4,a4,-556 # 8000a4f8 <ticks>
    8000272c:	431c                	lw	a5,0(a4)
    8000272e:	2785                	addiw	a5,a5,1
    80002730:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002732:	853a                	mv	a0,a4
    80002734:	a3dff0ef          	jal	80002170 <wakeup>
    release(&tickslock);
    80002738:	00016517          	auipc	a0,0x16
    8000273c:	cf050513          	addi	a0,a0,-784 # 80018428 <tickslock>
    80002740:	d70fe0ef          	jal	80000cb0 <release>
    80002744:	bf6d                	j	800026fe <clockintr+0xe>

0000000080002746 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002746:	1101                	addi	sp,sp,-32
    80002748:	ec06                	sd	ra,24(sp)
    8000274a:	e822                	sd	s0,16(sp)
    8000274c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    8000274e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002752:	57fd                	li	a5,-1
    80002754:	17fe                	slli	a5,a5,0x3f
    80002756:	07a5                	addi	a5,a5,9
    80002758:	00f70c63          	beq	a4,a5,80002770 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    8000275c:	57fd                	li	a5,-1
    8000275e:	17fe                	slli	a5,a5,0x3f
    80002760:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002762:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002764:	04f70863          	beq	a4,a5,800027b4 <devintr+0x6e>
  }
}
    80002768:	60e2                	ld	ra,24(sp)
    8000276a:	6442                	ld	s0,16(sp)
    8000276c:	6105                	addi	sp,sp,32
    8000276e:	8082                	ret
    80002770:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002772:	12c030ef          	jal	8000589e <plic_claim>
    80002776:	872a                	mv	a4,a0
    80002778:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    8000277a:	47a9                	li	a5,10
    8000277c:	00f50963          	beq	a0,a5,8000278e <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    80002780:	4785                	li	a5,1
    80002782:	00f50963          	beq	a0,a5,80002794 <devintr+0x4e>
    return 1;
    80002786:	4505                	li	a0,1
    } else if (irq) {
    80002788:	eb09                	bnez	a4,8000279a <devintr+0x54>
    8000278a:	64a2                	ld	s1,8(sp)
    8000278c:	bff1                	j	80002768 <devintr+0x22>
      uartintr();
    8000278e:	a60fe0ef          	jal	800009ee <uartintr>
    if (irq)
    80002792:	a819                	j	800027a8 <devintr+0x62>
      virtio_disk_intr();
    80002794:	5c6030ef          	jal	80005d5a <virtio_disk_intr>
    if (irq)
    80002798:	a801                	j	800027a8 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    8000279a:	85ba                	mv	a1,a4
    8000279c:	00005517          	auipc	a0,0x5
    800027a0:	c5450513          	addi	a0,a0,-940 # 800073f0 <etext+0x3f0>
    800027a4:	d67fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    800027a8:	8526                	mv	a0,s1
    800027aa:	116030ef          	jal	800058c0 <plic_complete>
    return 1;
    800027ae:	4505                	li	a0,1
    800027b0:	64a2                	ld	s1,8(sp)
    800027b2:	bf5d                	j	80002768 <devintr+0x22>
    clockintr();
    800027b4:	f3dff0ef          	jal	800026f0 <clockintr>
    return 2;
    800027b8:	4509                	li	a0,2
    800027ba:	b77d                	j	80002768 <devintr+0x22>

00000000800027bc <usertrap>:
{
    800027bc:	1101                	addi	sp,sp,-32
    800027be:	ec06                	sd	ra,24(sp)
    800027c0:	e822                	sd	s0,16(sp)
    800027c2:	e426                	sd	s1,8(sp)
    800027c4:	e04a                	sd	s2,0(sp)
    800027c6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027c8:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800027cc:	1007f793          	andi	a5,a5,256
    800027d0:	eba5                	bnez	a5,80002840 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800027d2:	00003797          	auipc	a5,0x3
    800027d6:	01e78793          	addi	a5,a5,30 # 800057f0 <kernelvec>
    800027da:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027de:	b1cff0ef          	jal	80001afa <myproc>
    800027e2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027e4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027e6:	14102773          	csrr	a4,sepc
    800027ea:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800027ec:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800027f0:	47a1                	li	a5,8
    800027f2:	04f70d63          	beq	a4,a5,8000284c <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    800027f6:	f51ff0ef          	jal	80002746 <devintr>
    800027fa:	892a                	mv	s2,a0
    800027fc:	e54d                	bnez	a0,800028a6 <usertrap+0xea>
    800027fe:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002802:	47bd                	li	a5,15
    80002804:	08f70463          	beq	a4,a5,8000288c <usertrap+0xd0>
    80002808:	14202773          	csrr	a4,scause
    8000280c:	47b5                	li	a5,13
    8000280e:	06f70f63          	beq	a4,a5,8000288c <usertrap+0xd0>
    80002812:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002816:	5890                	lw	a2,48(s1)
    80002818:	00005517          	auipc	a0,0x5
    8000281c:	c1850513          	addi	a0,a0,-1000 # 80007430 <etext+0x430>
    80002820:	cebfd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002824:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002828:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000282c:	00005517          	auipc	a0,0x5
    80002830:	c3450513          	addi	a0,a0,-972 # 80007460 <etext+0x460>
    80002834:	cd7fd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002838:	8526                	mv	a0,s1
    8000283a:	b05ff0ef          	jal	8000233e <setkilled>
    8000283e:	a015                	j	80002862 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    80002840:	00005517          	auipc	a0,0x5
    80002844:	bd050513          	addi	a0,a0,-1072 # 80007410 <etext+0x410>
    80002848:	fedfd0ef          	jal	80000834 <panic>
    if (killed(p))
    8000284c:	b17ff0ef          	jal	80002362 <killed>
    80002850:	e915                	bnez	a0,80002884 <usertrap+0xc8>
    p->trapframe->epc += 4;
    80002852:	6cb8                	ld	a4,88(s1)
    80002854:	6f1c                	ld	a5,24(a4)
    80002856:	0791                	addi	a5,a5,4
    80002858:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    8000285a:	10016073          	csrsi	sstatus,2
    syscall();
    8000285e:	244000ef          	jal	80002aa2 <syscall>
  if (killed(p))
    80002862:	8526                	mv	a0,s1
    80002864:	affff0ef          	jal	80002362 <killed>
    80002868:	e521                	bnez	a0,800028b0 <usertrap+0xf4>
  prepare_return();
    8000286a:	e13ff0ef          	jal	8000267c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000286e:	68a8                	ld	a0,80(s1)
    80002870:	8131                	srli	a0,a0,0xc
    80002872:	57fd                	li	a5,-1
    80002874:	17fe                	slli	a5,a5,0x3f
    80002876:	8d5d                	or	a0,a0,a5
}
    80002878:	60e2                	ld	ra,24(sp)
    8000287a:	6442                	ld	s0,16(sp)
    8000287c:	64a2                	ld	s1,8(sp)
    8000287e:	6902                	ld	s2,0(sp)
    80002880:	6105                	addi	sp,sp,32
    80002882:	8082                	ret
      kexit(-1);
    80002884:	557d                	li	a0,-1
    80002886:	9a7ff0ef          	jal	8000222c <kexit>
    8000288a:	b7e1                	j	80002852 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    8000288c:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    80002890:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002894:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    80002896:	0016b693          	seqz	a3,a3
    8000289a:	64ac                	ld	a1,72(s1)
    8000289c:	68a8                	ld	a0,80(s1)
    8000289e:	c69fe0ef          	jal	80001506 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800028a2:	f161                	bnez	a0,80002862 <usertrap+0xa6>
    800028a4:	b7bd                	j	80002812 <usertrap+0x56>
  if (killed(p))
    800028a6:	8526                	mv	a0,s1
    800028a8:	abbff0ef          	jal	80002362 <killed>
    800028ac:	c511                	beqz	a0,800028b8 <usertrap+0xfc>
    800028ae:	a011                	j	800028b2 <usertrap+0xf6>
    800028b0:	4901                	li	s2,0
    kexit(-1);
    800028b2:	557d                	li	a0,-1
    800028b4:	979ff0ef          	jal	8000222c <kexit>
  if (which_dev == 2)
    800028b8:	4789                	li	a5,2
    800028ba:	faf918e3          	bne	s2,a5,8000286a <usertrap+0xae>
    yield();
    800028be:	81bff0ef          	jal	800020d8 <yield>
    800028c2:	b765                	j	8000286a <usertrap+0xae>

00000000800028c4 <kerneltrap>:
{
    800028c4:	7179                	addi	sp,sp,-48
    800028c6:	f406                	sd	ra,40(sp)
    800028c8:	f022                	sd	s0,32(sp)
    800028ca:	ec26                	sd	s1,24(sp)
    800028cc:	e84a                	sd	s2,16(sp)
    800028ce:	e44e                	sd	s3,8(sp)
    800028d0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    800028d2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800028d6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800028da:	142027f3          	csrr	a5,scause
    800028de:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    800028e0:	1004f793          	andi	a5,s1,256
    800028e4:	c795                	beqz	a5,80002910 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800028e6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028ea:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800028ec:	eb85                	bnez	a5,8000291c <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    800028ee:	e59ff0ef          	jal	80002746 <devintr>
    800028f2:	c91d                	beqz	a0,80002928 <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    800028f4:	4789                	li	a5,2
    800028f6:	04f50a63          	beq	a0,a5,8000294a <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    800028fa:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800028fe:	10049073          	csrw	sstatus,s1
}
    80002902:	70a2                	ld	ra,40(sp)
    80002904:	7402                	ld	s0,32(sp)
    80002906:	64e2                	ld	s1,24(sp)
    80002908:	6942                	ld	s2,16(sp)
    8000290a:	69a2                	ld	s3,8(sp)
    8000290c:	6145                	addi	sp,sp,48
    8000290e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002910:	00005517          	auipc	a0,0x5
    80002914:	b7850513          	addi	a0,a0,-1160 # 80007488 <etext+0x488>
    80002918:	f1dfd0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    8000291c:	00005517          	auipc	a0,0x5
    80002920:	b9450513          	addi	a0,a0,-1132 # 800074b0 <etext+0x4b0>
    80002924:	f11fd0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002928:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000292c:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    80002930:	85ce                	mv	a1,s3
    80002932:	00005517          	auipc	a0,0x5
    80002936:	b9e50513          	addi	a0,a0,-1122 # 800074d0 <etext+0x4d0>
    8000293a:	bd1fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    8000293e:	00005517          	auipc	a0,0x5
    80002942:	bba50513          	addi	a0,a0,-1094 # 800074f8 <etext+0x4f8>
    80002946:	eeffd0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    8000294a:	9b0ff0ef          	jal	80001afa <myproc>
    8000294e:	d555                	beqz	a0,800028fa <kerneltrap+0x36>
    yield();
    80002950:	f88ff0ef          	jal	800020d8 <yield>
    80002954:	b75d                	j	800028fa <kerneltrap+0x36>

0000000080002956 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002956:	1101                	addi	sp,sp,-32
    80002958:	ec06                	sd	ra,24(sp)
    8000295a:	e822                	sd	s0,16(sp)
    8000295c:	e426                	sd	s1,8(sp)
    8000295e:	1000                	addi	s0,sp,32
    80002960:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002962:	998ff0ef          	jal	80001afa <myproc>
  switch (n) {
    80002966:	4795                	li	a5,5
    80002968:	0497e163          	bltu	a5,s1,800029aa <argraw+0x54>
    8000296c:	048a                	slli	s1,s1,0x2
    8000296e:	00005717          	auipc	a4,0x5
    80002972:	f8a70713          	addi	a4,a4,-118 # 800078f8 <states.0+0x30>
    80002976:	94ba                	add	s1,s1,a4
    80002978:	409c                	lw	a5,0(s1)
    8000297a:	97ba                	add	a5,a5,a4
    8000297c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000297e:	6d3c                	ld	a5,88(a0)
    80002980:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002982:	60e2                	ld	ra,24(sp)
    80002984:	6442                	ld	s0,16(sp)
    80002986:	64a2                	ld	s1,8(sp)
    80002988:	6105                	addi	sp,sp,32
    8000298a:	8082                	ret
    return p->trapframe->a1;
    8000298c:	6d3c                	ld	a5,88(a0)
    8000298e:	7fa8                	ld	a0,120(a5)
    80002990:	bfcd                	j	80002982 <argraw+0x2c>
    return p->trapframe->a2;
    80002992:	6d3c                	ld	a5,88(a0)
    80002994:	63c8                	ld	a0,128(a5)
    80002996:	b7f5                	j	80002982 <argraw+0x2c>
    return p->trapframe->a3;
    80002998:	6d3c                	ld	a5,88(a0)
    8000299a:	67c8                	ld	a0,136(a5)
    8000299c:	b7dd                	j	80002982 <argraw+0x2c>
    return p->trapframe->a4;
    8000299e:	6d3c                	ld	a5,88(a0)
    800029a0:	6bc8                	ld	a0,144(a5)
    800029a2:	b7c5                	j	80002982 <argraw+0x2c>
    return p->trapframe->a5;
    800029a4:	6d3c                	ld	a5,88(a0)
    800029a6:	6fc8                	ld	a0,152(a5)
    800029a8:	bfe9                	j	80002982 <argraw+0x2c>
  panic("argraw");
    800029aa:	00005517          	auipc	a0,0x5
    800029ae:	b5e50513          	addi	a0,a0,-1186 # 80007508 <etext+0x508>
    800029b2:	e83fd0ef          	jal	80000834 <panic>

00000000800029b6 <fetchaddr>:
{
    800029b6:	1101                	addi	sp,sp,-32
    800029b8:	ec06                	sd	ra,24(sp)
    800029ba:	e822                	sd	s0,16(sp)
    800029bc:	e426                	sd	s1,8(sp)
    800029be:	e04a                	sd	s2,0(sp)
    800029c0:	1000                	addi	s0,sp,32
    800029c2:	84aa                	mv	s1,a0
    800029c4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800029c6:	934ff0ef          	jal	80001afa <myproc>
  if (addr >= p->sz ||
    800029ca:	652c                	ld	a1,72(a0)
    800029cc:	02b4f663          	bgeu	s1,a1,800029f8 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800029d0:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    800029d4:	02f5e463          	bltu	a1,a5,800029fc <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    800029d8:	4721                	li	a4,8
    800029da:	86a6                	mv	a3,s1
    800029dc:	864a                	mv	a2,s2
    800029de:	6928                	ld	a0,80(a0)
    800029e0:	c69fe0ef          	jal	80001648 <copyin>
    800029e4:	00a03533          	snez	a0,a0
    800029e8:	40a0053b          	negw	a0,a0
}
    800029ec:	60e2                	ld	ra,24(sp)
    800029ee:	6442                	ld	s0,16(sp)
    800029f0:	64a2                	ld	s1,8(sp)
    800029f2:	6902                	ld	s2,0(sp)
    800029f4:	6105                	addi	sp,sp,32
    800029f6:	8082                	ret
    return -1;
    800029f8:	557d                	li	a0,-1
    800029fa:	bfcd                	j	800029ec <fetchaddr+0x36>
    800029fc:	557d                	li	a0,-1
    800029fe:	b7fd                	j	800029ec <fetchaddr+0x36>

0000000080002a00 <fetchstr>:
{
    80002a00:	7179                	addi	sp,sp,-48
    80002a02:	f406                	sd	ra,40(sp)
    80002a04:	f022                	sd	s0,32(sp)
    80002a06:	ec26                	sd	s1,24(sp)
    80002a08:	e84a                	sd	s2,16(sp)
    80002a0a:	e44e                	sd	s3,8(sp)
    80002a0c:	1800                	addi	s0,sp,48
    80002a0e:	89aa                	mv	s3,a0
    80002a10:	84ae                	mv	s1,a1
    80002a12:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002a14:	8e6ff0ef          	jal	80001afa <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002a18:	874a                	mv	a4,s2
    80002a1a:	86ce                	mv	a3,s3
    80002a1c:	8626                	mv	a2,s1
    80002a1e:	652c                	ld	a1,72(a0)
    80002a20:	6928                	ld	a0,80(a0)
    80002a22:	cc3fe0ef          	jal	800016e4 <copyinstr>
    80002a26:	00054c63          	bltz	a0,80002a3e <fetchstr+0x3e>
  return strlen(buf);
    80002a2a:	8526                	mv	a0,s1
    80002a2c:	c46fe0ef          	jal	80000e72 <strlen>
}
    80002a30:	70a2                	ld	ra,40(sp)
    80002a32:	7402                	ld	s0,32(sp)
    80002a34:	64e2                	ld	s1,24(sp)
    80002a36:	6942                	ld	s2,16(sp)
    80002a38:	69a2                	ld	s3,8(sp)
    80002a3a:	6145                	addi	sp,sp,48
    80002a3c:	8082                	ret
    return -1;
    80002a3e:	557d                	li	a0,-1
    80002a40:	bfc5                	j	80002a30 <fetchstr+0x30>

0000000080002a42 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a42:	1101                	addi	sp,sp,-32
    80002a44:	ec06                	sd	ra,24(sp)
    80002a46:	e822                	sd	s0,16(sp)
    80002a48:	e426                	sd	s1,8(sp)
    80002a4a:	1000                	addi	s0,sp,32
    80002a4c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a4e:	f09ff0ef          	jal	80002956 <argraw>
    80002a52:	c088                	sw	a0,0(s1)
}
    80002a54:	60e2                	ld	ra,24(sp)
    80002a56:	6442                	ld	s0,16(sp)
    80002a58:	64a2                	ld	s1,8(sp)
    80002a5a:	6105                	addi	sp,sp,32
    80002a5c:	8082                	ret

0000000080002a5e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a5e:	1101                	addi	sp,sp,-32
    80002a60:	ec06                	sd	ra,24(sp)
    80002a62:	e822                	sd	s0,16(sp)
    80002a64:	e426                	sd	s1,8(sp)
    80002a66:	1000                	addi	s0,sp,32
    80002a68:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a6a:	eedff0ef          	jal	80002956 <argraw>
    80002a6e:	e088                	sd	a0,0(s1)
}
    80002a70:	60e2                	ld	ra,24(sp)
    80002a72:	6442                	ld	s0,16(sp)
    80002a74:	64a2                	ld	s1,8(sp)
    80002a76:	6105                	addi	sp,sp,32
    80002a78:	8082                	ret

0000000080002a7a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a7a:	1101                	addi	sp,sp,-32
    80002a7c:	ec06                	sd	ra,24(sp)
    80002a7e:	e822                	sd	s0,16(sp)
    80002a80:	e426                	sd	s1,8(sp)
    80002a82:	e04a                	sd	s2,0(sp)
    80002a84:	1000                	addi	s0,sp,32
    80002a86:	892e                	mv	s2,a1
    80002a88:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002a8a:	ecdff0ef          	jal	80002956 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002a8e:	8626                	mv	a2,s1
    80002a90:	85ca                	mv	a1,s2
    80002a92:	f6fff0ef          	jal	80002a00 <fetchstr>
}
    80002a96:	60e2                	ld	ra,24(sp)
    80002a98:	6442                	ld	s0,16(sp)
    80002a9a:	64a2                	ld	s1,8(sp)
    80002a9c:	6902                	ld	s2,0(sp)
    80002a9e:	6105                	addi	sp,sp,32
    80002aa0:	8082                	ret

0000000080002aa2 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002aa2:	1101                	addi	sp,sp,-32
    80002aa4:	ec06                	sd	ra,24(sp)
    80002aa6:	e822                	sd	s0,16(sp)
    80002aa8:	e426                	sd	s1,8(sp)
    80002aaa:	e04a                	sd	s2,0(sp)
    80002aac:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002aae:	84cff0ef          	jal	80001afa <myproc>
    80002ab2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ab4:	05853903          	ld	s2,88(a0)
    80002ab8:	0a893783          	ld	a5,168(s2)
    80002abc:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ac0:	37fd                	addiw	a5,a5,-1
    80002ac2:	4759                	li	a4,22
    80002ac4:	00f76f63          	bltu	a4,a5,80002ae2 <syscall+0x40>
    80002ac8:	00369713          	slli	a4,a3,0x3
    80002acc:	00005797          	auipc	a5,0x5
    80002ad0:	e4478793          	addi	a5,a5,-444 # 80007910 <syscalls>
    80002ad4:	97ba                	add	a5,a5,a4
    80002ad6:	639c                	ld	a5,0(a5)
    80002ad8:	c789                	beqz	a5,80002ae2 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002ada:	9782                	jalr	a5
    80002adc:	06a93823          	sd	a0,112(s2)
    80002ae0:	a829                	j	80002afa <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002ae2:	15848613          	addi	a2,s1,344
    80002ae6:	588c                	lw	a1,48(s1)
    80002ae8:	00005517          	auipc	a0,0x5
    80002aec:	a2850513          	addi	a0,a0,-1496 # 80007510 <etext+0x510>
    80002af0:	a1bfd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002af4:	6cbc                	ld	a5,88(s1)
    80002af6:	577d                	li	a4,-1
    80002af8:	fbb8                	sd	a4,112(a5)
  }
}
    80002afa:	60e2                	ld	ra,24(sp)
    80002afc:	6442                	ld	s0,16(sp)
    80002afe:	64a2                	ld	s1,8(sp)
    80002b00:	6902                	ld	s2,0(sp)
    80002b02:	6105                	addi	sp,sp,32
    80002b04:	8082                	ret

0000000080002b06 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002b06:	1101                	addi	sp,sp,-32
    80002b08:	ec06                	sd	ra,24(sp)
    80002b0a:	e822                	sd	s0,16(sp)
    80002b0c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002b0e:	fec40593          	addi	a1,s0,-20
    80002b12:	4501                	li	a0,0
    80002b14:	f2fff0ef          	jal	80002a42 <argint>
  kexit(n);
    80002b18:	fec42503          	lw	a0,-20(s0)
    80002b1c:	f10ff0ef          	jal	8000222c <kexit>
  return 0; // not reached
}
    80002b20:	4501                	li	a0,0
    80002b22:	60e2                	ld	ra,24(sp)
    80002b24:	6442                	ld	s0,16(sp)
    80002b26:	6105                	addi	sp,sp,32
    80002b28:	8082                	ret

0000000080002b2a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b2a:	1141                	addi	sp,sp,-16
    80002b2c:	e406                	sd	ra,8(sp)
    80002b2e:	e022                	sd	s0,0(sp)
    80002b30:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b32:	fc9fe0ef          	jal	80001afa <myproc>
}
    80002b36:	5908                	lw	a0,48(a0)
    80002b38:	60a2                	ld	ra,8(sp)
    80002b3a:	6402                	ld	s0,0(sp)
    80002b3c:	0141                	addi	sp,sp,16
    80002b3e:	8082                	ret

0000000080002b40 <sys_fork>:

uint64
sys_fork(void)
{
    80002b40:	1141                	addi	sp,sp,-16
    80002b42:	e406                	sd	ra,8(sp)
    80002b44:	e022                	sd	s0,0(sp)
    80002b46:	0800                	addi	s0,sp,16
  return kfork();
    80002b48:	b12ff0ef          	jal	80001e5a <kfork>
}
    80002b4c:	60a2                	ld	ra,8(sp)
    80002b4e:	6402                	ld	s0,0(sp)
    80002b50:	0141                	addi	sp,sp,16
    80002b52:	8082                	ret

0000000080002b54 <sys_wait>:

uint64
sys_wait(void)
{
    80002b54:	1101                	addi	sp,sp,-32
    80002b56:	ec06                	sd	ra,24(sp)
    80002b58:	e822                	sd	s0,16(sp)
    80002b5a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b5c:	fe840593          	addi	a1,s0,-24
    80002b60:	4501                	li	a0,0
    80002b62:	efdff0ef          	jal	80002a5e <argaddr>
  return kwait(p);
    80002b66:	fe843503          	ld	a0,-24(s0)
    80002b6a:	823ff0ef          	jal	8000238c <kwait>
}
    80002b6e:	60e2                	ld	ra,24(sp)
    80002b70:	6442                	ld	s0,16(sp)
    80002b72:	6105                	addi	sp,sp,32
    80002b74:	8082                	ret

0000000080002b76 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b76:	7179                	addi	sp,sp,-48
    80002b78:	f406                	sd	ra,40(sp)
    80002b7a:	f022                	sd	s0,32(sp)
    80002b7c:	ec26                	sd	s1,24(sp)
    80002b7e:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002b80:	fd840593          	addi	a1,s0,-40
    80002b84:	4501                	li	a0,0
    80002b86:	ebdff0ef          	jal	80002a42 <argint>
  argint(1, &t);
    80002b8a:	fdc40593          	addi	a1,s0,-36
    80002b8e:	4505                	li	a0,1
    80002b90:	eb3ff0ef          	jal	80002a42 <argint>
  addr = myproc()->sz;
    80002b94:	f67fe0ef          	jal	80001afa <myproc>
    80002b98:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002b9a:	fdc42703          	lw	a4,-36(s0)
    80002b9e:	4785                	li	a5,1
    80002ba0:	02f70763          	beq	a4,a5,80002bce <sys_sbrk+0x58>
    80002ba4:	fd842783          	lw	a5,-40(s0)
    80002ba8:	0207c363          	bltz	a5,80002bce <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002bac:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002bae:	02000737          	lui	a4,0x2000
    80002bb2:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002bb4:	0736                	slli	a4,a4,0xd
    80002bb6:	02f76a63          	bltu	a4,a5,80002bea <sys_sbrk+0x74>
    80002bba:	0297e863          	bltu	a5,s1,80002bea <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002bbe:	f3dfe0ef          	jal	80001afa <myproc>
    80002bc2:	fd842703          	lw	a4,-40(s0)
    80002bc6:	653c                	ld	a5,72(a0)
    80002bc8:	97ba                	add	a5,a5,a4
    80002bca:	e53c                	sd	a5,72(a0)
    80002bcc:	a039                	j	80002bda <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002bce:	fd842503          	lw	a0,-40(s0)
    80002bd2:	a26ff0ef          	jal	80001df8 <growproc>
    80002bd6:	00054863          	bltz	a0,80002be6 <sys_sbrk+0x70>
  }
  return addr;
}
    80002bda:	8526                	mv	a0,s1
    80002bdc:	70a2                	ld	ra,40(sp)
    80002bde:	7402                	ld	s0,32(sp)
    80002be0:	64e2                	ld	s1,24(sp)
    80002be2:	6145                	addi	sp,sp,48
    80002be4:	8082                	ret
      return -1;
    80002be6:	54fd                	li	s1,-1
    80002be8:	bfcd                	j	80002bda <sys_sbrk+0x64>
      return -1;
    80002bea:	54fd                	li	s1,-1
    80002bec:	b7fd                	j	80002bda <sys_sbrk+0x64>

0000000080002bee <sys_pause>:

uint64
sys_pause(void)
{
    80002bee:	7139                	addi	sp,sp,-64
    80002bf0:	fc06                	sd	ra,56(sp)
    80002bf2:	f822                	sd	s0,48(sp)
    80002bf4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002bf6:	fcc40593          	addi	a1,s0,-52
    80002bfa:	4501                	li	a0,0
    80002bfc:	e47ff0ef          	jal	80002a42 <argint>
  if (n < 0)
    80002c00:	fcc42783          	lw	a5,-52(s0)
    80002c04:	0807c063          	bltz	a5,80002c84 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002c08:	00016517          	auipc	a0,0x16
    80002c0c:	82050513          	addi	a0,a0,-2016 # 80018428 <tickslock>
    80002c10:	818fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002c14:	fcc42783          	lw	a5,-52(s0)
    80002c18:	cbb9                	beqz	a5,80002c6e <sys_pause+0x80>
    80002c1a:	f426                	sd	s1,40(sp)
    80002c1c:	f04a                	sd	s2,32(sp)
    80002c1e:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002c20:	00008997          	auipc	s3,0x8
    80002c24:	8d89a983          	lw	s3,-1832(s3) # 8000a4f8 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002c28:	00008917          	auipc	s2,0x8
    80002c2c:	8d090913          	addi	s2,s2,-1840 # 8000a4f8 <ticks>
    release(&tickslock);
    80002c30:	00015497          	auipc	s1,0x15
    80002c34:	7f848493          	addi	s1,s1,2040 # 80018428 <tickslock>
    if (killed(myproc())) {
    80002c38:	ec3fe0ef          	jal	80001afa <myproc>
    80002c3c:	f26ff0ef          	jal	80002362 <killed>
    80002c40:	e529                	bnez	a0,80002c8a <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002c42:	854a                	mv	a0,s2
    80002c44:	cc0ff0ef          	jal	80002104 <sleep_prepare>
    release(&tickslock);
    80002c48:	8526                	mv	a0,s1
    80002c4a:	866fe0ef          	jal	80000cb0 <release>
    sleep();
    80002c4e:	cf2ff0ef          	jal	80002140 <sleep>
    acquire(&tickslock);
    80002c52:	8526                	mv	a0,s1
    80002c54:	fd5fd0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002c58:	00092783          	lw	a5,0(s2)
    80002c5c:	413787bb          	subw	a5,a5,s3
    80002c60:	fcc42703          	lw	a4,-52(s0)
    80002c64:	fce7eae3          	bltu	a5,a4,80002c38 <sys_pause+0x4a>
    80002c68:	74a2                	ld	s1,40(sp)
    80002c6a:	7902                	ld	s2,32(sp)
    80002c6c:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002c6e:	00015517          	auipc	a0,0x15
    80002c72:	7ba50513          	addi	a0,a0,1978 # 80018428 <tickslock>
    80002c76:	83afe0ef          	jal	80000cb0 <release>
  return 0;
    80002c7a:	4501                	li	a0,0
}
    80002c7c:	70e2                	ld	ra,56(sp)
    80002c7e:	7442                	ld	s0,48(sp)
    80002c80:	6121                	addi	sp,sp,64
    80002c82:	8082                	ret
    n = 0;
    80002c84:	fc042623          	sw	zero,-52(s0)
    80002c88:	b741                	j	80002c08 <sys_pause+0x1a>
      release(&tickslock);
    80002c8a:	00015517          	auipc	a0,0x15
    80002c8e:	79e50513          	addi	a0,a0,1950 # 80018428 <tickslock>
    80002c92:	81efe0ef          	jal	80000cb0 <release>
      return -1;
    80002c96:	557d                	li	a0,-1
    80002c98:	74a2                	ld	s1,40(sp)
    80002c9a:	7902                	ld	s2,32(sp)
    80002c9c:	69e2                	ld	s3,24(sp)
    80002c9e:	bff9                	j	80002c7c <sys_pause+0x8e>

0000000080002ca0 <sys_kill>:

uint64
sys_kill(void)
{
    80002ca0:	1101                	addi	sp,sp,-32
    80002ca2:	ec06                	sd	ra,24(sp)
    80002ca4:	e822                	sd	s0,16(sp)
    80002ca6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ca8:	fec40593          	addi	a1,s0,-20
    80002cac:	4501                	li	a0,0
    80002cae:	d95ff0ef          	jal	80002a42 <argint>
  return kkill(pid);
    80002cb2:	fec42503          	lw	a0,-20(s0)
    80002cb6:	e1cff0ef          	jal	800022d2 <kkill>
}
    80002cba:	60e2                	ld	ra,24(sp)
    80002cbc:	6442                	ld	s0,16(sp)
    80002cbe:	6105                	addi	sp,sp,32
    80002cc0:	8082                	ret

0000000080002cc2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002cc2:	1101                	addi	sp,sp,-32
    80002cc4:	ec06                	sd	ra,24(sp)
    80002cc6:	e822                	sd	s0,16(sp)
    80002cc8:	e426                	sd	s1,8(sp)
    80002cca:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ccc:	00015517          	auipc	a0,0x15
    80002cd0:	75c50513          	addi	a0,a0,1884 # 80018428 <tickslock>
    80002cd4:	f55fd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002cd8:	00008797          	auipc	a5,0x8
    80002cdc:	8207a783          	lw	a5,-2016(a5) # 8000a4f8 <ticks>
    80002ce0:	84be                	mv	s1,a5
  release(&tickslock);
    80002ce2:	00015517          	auipc	a0,0x15
    80002ce6:	74650513          	addi	a0,a0,1862 # 80018428 <tickslock>
    80002cea:	fc7fd0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002cee:	02049513          	slli	a0,s1,0x20
    80002cf2:	9101                	srli	a0,a0,0x20
    80002cf4:	60e2                	ld	ra,24(sp)
    80002cf6:	6442                	ld	s0,16(sp)
    80002cf8:	64a2                	ld	s1,8(sp)
    80002cfa:	6105                	addi	sp,sp,32
    80002cfc:	8082                	ret

0000000080002cfe <sys_vmprint>:

uint64
sys_vmprint(void)
{
    80002cfe:	1141                	addi	sp,sp,-16
    80002d00:	e406                	sd	ra,8(sp)
    80002d02:	e022                	sd	s0,0(sp)
    80002d04:	0800                	addi	s0,sp,16
  return kvmprint(myproc()->pagetable);
    80002d06:	df5fe0ef          	jal	80001afa <myproc>
    80002d0a:	6928                	ld	a0,80(a0)
    80002d0c:	aaffe0ef          	jal	800017ba <kvmprint>
}
    80002d10:	60a2                	ld	ra,8(sp)
    80002d12:	6402                	ld	s0,0(sp)
    80002d14:	0141                	addi	sp,sp,16
    80002d16:	8082                	ret

0000000080002d18 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d18:	7179                	addi	sp,sp,-48
    80002d1a:	f406                	sd	ra,40(sp)
    80002d1c:	f022                	sd	s0,32(sp)
    80002d1e:	ec26                	sd	s1,24(sp)
    80002d20:	e84a                	sd	s2,16(sp)
    80002d22:	e44e                	sd	s3,8(sp)
    80002d24:	e052                	sd	s4,0(sp)
    80002d26:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d28:	00005597          	auipc	a1,0x5
    80002d2c:	80858593          	addi	a1,a1,-2040 # 80007530 <etext+0x530>
    80002d30:	00015517          	auipc	a0,0x15
    80002d34:	71050513          	addi	a0,a0,1808 # 80018440 <bcache>
    80002d38:	e71fd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d3c:	0001d797          	auipc	a5,0x1d
    80002d40:	70478793          	addi	a5,a5,1796 # 80020440 <bcache+0x8000>
    80002d44:	0001e717          	auipc	a4,0x1e
    80002d48:	96470713          	addi	a4,a4,-1692 # 800206a8 <bcache+0x8268>
    80002d4c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d50:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002d54:	00015497          	auipc	s1,0x15
    80002d58:	70448493          	addi	s1,s1,1796 # 80018458 <bcache+0x18>
    b->next = bcache.head.next;
    80002d5c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d5e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d60:	00004a17          	auipc	s4,0x4
    80002d64:	7d8a0a13          	addi	s4,s4,2008 # 80007538 <etext+0x538>
    b->next = bcache.head.next;
    80002d68:	2b893783          	ld	a5,696(s2)
    80002d6c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d6e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d72:	85d2                	mv	a1,s4
    80002d74:	01048513          	addi	a0,s1,16
    80002d78:	41c010ef          	jal	80004194 <initsleeplock>
    bcache.head.next->prev = b;
    80002d7c:	2b893783          	ld	a5,696(s2)
    80002d80:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d82:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002d86:	45848493          	addi	s1,s1,1112
    80002d8a:	fd349fe3          	bne	s1,s3,80002d68 <binit+0x50>
  }
}
    80002d8e:	70a2                	ld	ra,40(sp)
    80002d90:	7402                	ld	s0,32(sp)
    80002d92:	64e2                	ld	s1,24(sp)
    80002d94:	6942                	ld	s2,16(sp)
    80002d96:	69a2                	ld	s3,8(sp)
    80002d98:	6a02                	ld	s4,0(sp)
    80002d9a:	6145                	addi	sp,sp,48
    80002d9c:	8082                	ret

0000000080002d9e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002d9e:	7179                	addi	sp,sp,-48
    80002da0:	f406                	sd	ra,40(sp)
    80002da2:	f022                	sd	s0,32(sp)
    80002da4:	ec26                	sd	s1,24(sp)
    80002da6:	e84a                	sd	s2,16(sp)
    80002da8:	e44e                	sd	s3,8(sp)
    80002daa:	1800                	addi	s0,sp,48
    80002dac:	892a                	mv	s2,a0
    80002dae:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002db0:	00015517          	auipc	a0,0x15
    80002db4:	69050513          	addi	a0,a0,1680 # 80018440 <bcache>
    80002db8:	e71fd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002dbc:	0001e497          	auipc	s1,0x1e
    80002dc0:	93c4b483          	ld	s1,-1732(s1) # 800206f8 <bcache+0x82b8>
    80002dc4:	0001e797          	auipc	a5,0x1e
    80002dc8:	8e478793          	addi	a5,a5,-1820 # 800206a8 <bcache+0x8268>
    80002dcc:	02f48b63          	beq	s1,a5,80002e02 <bread+0x64>
    80002dd0:	873e                	mv	a4,a5
    80002dd2:	a021                	j	80002dda <bread+0x3c>
    80002dd4:	68a4                	ld	s1,80(s1)
    80002dd6:	02e48663          	beq	s1,a4,80002e02 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002dda:	449c                	lw	a5,8(s1)
    80002ddc:	ff279ce3          	bne	a5,s2,80002dd4 <bread+0x36>
    80002de0:	44dc                	lw	a5,12(s1)
    80002de2:	ff3799e3          	bne	a5,s3,80002dd4 <bread+0x36>
      b->refcnt++;
    80002de6:	40bc                	lw	a5,64(s1)
    80002de8:	2785                	addiw	a5,a5,1
    80002dea:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002dec:	00015517          	auipc	a0,0x15
    80002df0:	65450513          	addi	a0,a0,1620 # 80018440 <bcache>
    80002df4:	ebdfd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002df8:	01048513          	addi	a0,s1,16
    80002dfc:	3ce010ef          	jal	800041ca <acquiresleep>
      return b;
    80002e00:	a889                	j	80002e52 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002e02:	0001e497          	auipc	s1,0x1e
    80002e06:	8ee4b483          	ld	s1,-1810(s1) # 800206f0 <bcache+0x82b0>
    80002e0a:	0001e797          	auipc	a5,0x1e
    80002e0e:	89e78793          	addi	a5,a5,-1890 # 800206a8 <bcache+0x8268>
    80002e12:	00f48863          	beq	s1,a5,80002e22 <bread+0x84>
    80002e16:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002e18:	40bc                	lw	a5,64(s1)
    80002e1a:	cb91                	beqz	a5,80002e2e <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002e1c:	64a4                	ld	s1,72(s1)
    80002e1e:	fee49de3          	bne	s1,a4,80002e18 <bread+0x7a>
  panic("bget: no buffers");
    80002e22:	00004517          	auipc	a0,0x4
    80002e26:	71e50513          	addi	a0,a0,1822 # 80007540 <etext+0x540>
    80002e2a:	a0bfd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002e2e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002e32:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002e36:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e3a:	4785                	li	a5,1
    80002e3c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e3e:	00015517          	auipc	a0,0x15
    80002e42:	60250513          	addi	a0,a0,1538 # 80018440 <bcache>
    80002e46:	e6bfd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002e4a:	01048513          	addi	a0,s1,16
    80002e4e:	37c010ef          	jal	800041ca <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002e52:	409c                	lw	a5,0(s1)
    80002e54:	cb89                	beqz	a5,80002e66 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e56:	8526                	mv	a0,s1
    80002e58:	70a2                	ld	ra,40(sp)
    80002e5a:	7402                	ld	s0,32(sp)
    80002e5c:	64e2                	ld	s1,24(sp)
    80002e5e:	6942                	ld	s2,16(sp)
    80002e60:	69a2                	ld	s3,8(sp)
    80002e62:	6145                	addi	sp,sp,48
    80002e64:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e66:	4581                	li	a1,0
    80002e68:	8526                	mv	a0,s1
    80002e6a:	4bd020ef          	jal	80005b26 <virtio_disk_rw>
    b->valid = 1;
    80002e6e:	4785                	li	a5,1
    80002e70:	c09c                	sw	a5,0(s1)
  return b;
    80002e72:	b7d5                	j	80002e56 <bread+0xb8>

0000000080002e74 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002e74:	1101                	addi	sp,sp,-32
    80002e76:	ec06                	sd	ra,24(sp)
    80002e78:	e822                	sd	s0,16(sp)
    80002e7a:	e426                	sd	s1,8(sp)
    80002e7c:	1000                	addi	s0,sp,32
    80002e7e:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002e80:	0541                	addi	a0,a0,16
    80002e82:	3d4010ef          	jal	80004256 <holdingsleep>
    80002e86:	c911                	beqz	a0,80002e9a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e88:	4585                	li	a1,1
    80002e8a:	8526                	mv	a0,s1
    80002e8c:	49b020ef          	jal	80005b26 <virtio_disk_rw>
}
    80002e90:	60e2                	ld	ra,24(sp)
    80002e92:	6442                	ld	s0,16(sp)
    80002e94:	64a2                	ld	s1,8(sp)
    80002e96:	6105                	addi	sp,sp,32
    80002e98:	8082                	ret
    panic("bwrite");
    80002e9a:	00004517          	auipc	a0,0x4
    80002e9e:	6be50513          	addi	a0,a0,1726 # 80007558 <etext+0x558>
    80002ea2:	993fd0ef          	jal	80000834 <panic>

0000000080002ea6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ea6:	1101                	addi	sp,sp,-32
    80002ea8:	ec06                	sd	ra,24(sp)
    80002eaa:	e822                	sd	s0,16(sp)
    80002eac:	e426                	sd	s1,8(sp)
    80002eae:	e04a                	sd	s2,0(sp)
    80002eb0:	1000                	addi	s0,sp,32
    80002eb2:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002eb4:	01050913          	addi	s2,a0,16
    80002eb8:	854a                	mv	a0,s2
    80002eba:	39c010ef          	jal	80004256 <holdingsleep>
    80002ebe:	c125                	beqz	a0,80002f1e <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002ec0:	854a                	mv	a0,s2
    80002ec2:	35c010ef          	jal	8000421e <releasesleep>

  acquire(&bcache.lock);
    80002ec6:	00015517          	auipc	a0,0x15
    80002eca:	57a50513          	addi	a0,a0,1402 # 80018440 <bcache>
    80002ece:	d5bfd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002ed2:	40bc                	lw	a5,64(s1)
    80002ed4:	37fd                	addiw	a5,a5,-1
    80002ed6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002ed8:	e79d                	bnez	a5,80002f06 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002eda:	68b8                	ld	a4,80(s1)
    80002edc:	64bc                	ld	a5,72(s1)
    80002ede:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002ee0:	68b8                	ld	a4,80(s1)
    80002ee2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ee4:	0001d797          	auipc	a5,0x1d
    80002ee8:	55c78793          	addi	a5,a5,1372 # 80020440 <bcache+0x8000>
    80002eec:	2b87b703          	ld	a4,696(a5)
    80002ef0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ef2:	0001d717          	auipc	a4,0x1d
    80002ef6:	7b670713          	addi	a4,a4,1974 # 800206a8 <bcache+0x8268>
    80002efa:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002efc:	2b87b703          	ld	a4,696(a5)
    80002f00:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002f02:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002f06:	00015517          	auipc	a0,0x15
    80002f0a:	53a50513          	addi	a0,a0,1338 # 80018440 <bcache>
    80002f0e:	da3fd0ef          	jal	80000cb0 <release>
}
    80002f12:	60e2                	ld	ra,24(sp)
    80002f14:	6442                	ld	s0,16(sp)
    80002f16:	64a2                	ld	s1,8(sp)
    80002f18:	6902                	ld	s2,0(sp)
    80002f1a:	6105                	addi	sp,sp,32
    80002f1c:	8082                	ret
    panic("brelse");
    80002f1e:	00004517          	auipc	a0,0x4
    80002f22:	64250513          	addi	a0,a0,1602 # 80007560 <etext+0x560>
    80002f26:	90ffd0ef          	jal	80000834 <panic>

0000000080002f2a <bpin>:

void
bpin(struct buf *b)
{
    80002f2a:	1101                	addi	sp,sp,-32
    80002f2c:	ec06                	sd	ra,24(sp)
    80002f2e:	e822                	sd	s0,16(sp)
    80002f30:	e426                	sd	s1,8(sp)
    80002f32:	1000                	addi	s0,sp,32
    80002f34:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f36:	00015517          	auipc	a0,0x15
    80002f3a:	50a50513          	addi	a0,a0,1290 # 80018440 <bcache>
    80002f3e:	cebfd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002f42:	40bc                	lw	a5,64(s1)
    80002f44:	2785                	addiw	a5,a5,1
    80002f46:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f48:	00015517          	auipc	a0,0x15
    80002f4c:	4f850513          	addi	a0,a0,1272 # 80018440 <bcache>
    80002f50:	d61fd0ef          	jal	80000cb0 <release>
}
    80002f54:	60e2                	ld	ra,24(sp)
    80002f56:	6442                	ld	s0,16(sp)
    80002f58:	64a2                	ld	s1,8(sp)
    80002f5a:	6105                	addi	sp,sp,32
    80002f5c:	8082                	ret

0000000080002f5e <bunpin>:

void
bunpin(struct buf *b)
{
    80002f5e:	1101                	addi	sp,sp,-32
    80002f60:	ec06                	sd	ra,24(sp)
    80002f62:	e822                	sd	s0,16(sp)
    80002f64:	e426                	sd	s1,8(sp)
    80002f66:	1000                	addi	s0,sp,32
    80002f68:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f6a:	00015517          	auipc	a0,0x15
    80002f6e:	4d650513          	addi	a0,a0,1238 # 80018440 <bcache>
    80002f72:	cb7fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002f76:	40bc                	lw	a5,64(s1)
    80002f78:	37fd                	addiw	a5,a5,-1
    80002f7a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f7c:	00015517          	auipc	a0,0x15
    80002f80:	4c450513          	addi	a0,a0,1220 # 80018440 <bcache>
    80002f84:	d2dfd0ef          	jal	80000cb0 <release>
}
    80002f88:	60e2                	ld	ra,24(sp)
    80002f8a:	6442                	ld	s0,16(sp)
    80002f8c:	64a2                	ld	s1,8(sp)
    80002f8e:	6105                	addi	sp,sp,32
    80002f90:	8082                	ret

0000000080002f92 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f92:	1101                	addi	sp,sp,-32
    80002f94:	ec06                	sd	ra,24(sp)
    80002f96:	e822                	sd	s0,16(sp)
    80002f98:	e426                	sd	s1,8(sp)
    80002f9a:	e04a                	sd	s2,0(sp)
    80002f9c:	1000                	addi	s0,sp,32
    80002f9e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002fa0:	00d5d79b          	srliw	a5,a1,0xd
    80002fa4:	0001e597          	auipc	a1,0x1e
    80002fa8:	b785a583          	lw	a1,-1160(a1) # 80020b1c <sb+0x1c>
    80002fac:	9dbd                	addw	a1,a1,a5
    80002fae:	df1ff0ef          	jal	80002d9e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002fb2:	0074f713          	andi	a4,s1,7
    80002fb6:	4785                	li	a5,1
    80002fb8:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002fbc:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002fbe:	90d9                	srli	s1,s1,0x36
    80002fc0:	00950733          	add	a4,a0,s1
    80002fc4:	05874703          	lbu	a4,88(a4)
    80002fc8:	00e7f6b3          	and	a3,a5,a4
    80002fcc:	c29d                	beqz	a3,80002ff2 <bfree+0x60>
    80002fce:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002fd0:	94aa                	add	s1,s1,a0
    80002fd2:	fff7c793          	not	a5,a5
    80002fd6:	8f7d                	and	a4,a4,a5
    80002fd8:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002fdc:	080010ef          	jal	8000405c <log_write>
  brelse(bp);
    80002fe0:	854a                	mv	a0,s2
    80002fe2:	ec5ff0ef          	jal	80002ea6 <brelse>
}
    80002fe6:	60e2                	ld	ra,24(sp)
    80002fe8:	6442                	ld	s0,16(sp)
    80002fea:	64a2                	ld	s1,8(sp)
    80002fec:	6902                	ld	s2,0(sp)
    80002fee:	6105                	addi	sp,sp,32
    80002ff0:	8082                	ret
    panic("freeing free block");
    80002ff2:	00004517          	auipc	a0,0x4
    80002ff6:	57650513          	addi	a0,a0,1398 # 80007568 <etext+0x568>
    80002ffa:	83bfd0ef          	jal	80000834 <panic>

0000000080002ffe <balloc>:
{
    80002ffe:	715d                	addi	sp,sp,-80
    80003000:	e486                	sd	ra,72(sp)
    80003002:	e0a2                	sd	s0,64(sp)
    80003004:	fc26                	sd	s1,56(sp)
    80003006:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80003008:	0001e797          	auipc	a5,0x1e
    8000300c:	afc7a783          	lw	a5,-1284(a5) # 80020b04 <sb+0x4>
    80003010:	0e078263          	beqz	a5,800030f4 <balloc+0xf6>
    80003014:	f84a                	sd	s2,48(sp)
    80003016:	f44e                	sd	s3,40(sp)
    80003018:	f052                	sd	s4,32(sp)
    8000301a:	ec56                	sd	s5,24(sp)
    8000301c:	e85a                	sd	s6,16(sp)
    8000301e:	e45e                	sd	s7,8(sp)
    80003020:	e062                	sd	s8,0(sp)
    80003022:	8baa                	mv	s7,a0
    80003024:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003026:	0001eb17          	auipc	s6,0x1e
    8000302a:	adab0b13          	addi	s6,s6,-1318 # 80020b00 <sb>
      m = 1 << (bi % 8);
    8000302e:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003030:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80003032:	6c09                	lui	s8,0x2
    80003034:	a09d                	j	8000309a <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80003036:	97ca                	add	a5,a5,s2
    80003038:	8e55                	or	a2,a2,a3
    8000303a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000303e:	854a                	mv	a0,s2
    80003040:	01c010ef          	jal	8000405c <log_write>
        brelse(bp);
    80003044:	854a                	mv	a0,s2
    80003046:	e61ff0ef          	jal	80002ea6 <brelse>
  bp = bread(dev, bno);
    8000304a:	85a6                	mv	a1,s1
    8000304c:	855e                	mv	a0,s7
    8000304e:	d51ff0ef          	jal	80002d9e <bread>
    80003052:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003054:	40000613          	li	a2,1024
    80003058:	4581                	li	a1,0
    8000305a:	05850513          	addi	a0,a0,88
    8000305e:	c8bfd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    80003062:	854a                	mv	a0,s2
    80003064:	7f9000ef          	jal	8000405c <log_write>
  brelse(bp);
    80003068:	854a                	mv	a0,s2
    8000306a:	e3dff0ef          	jal	80002ea6 <brelse>
}
    8000306e:	7942                	ld	s2,48(sp)
    80003070:	79a2                	ld	s3,40(sp)
    80003072:	7a02                	ld	s4,32(sp)
    80003074:	6ae2                	ld	s5,24(sp)
    80003076:	6b42                	ld	s6,16(sp)
    80003078:	6ba2                	ld	s7,8(sp)
    8000307a:	6c02                	ld	s8,0(sp)
}
    8000307c:	8526                	mv	a0,s1
    8000307e:	60a6                	ld	ra,72(sp)
    80003080:	6406                	ld	s0,64(sp)
    80003082:	74e2                	ld	s1,56(sp)
    80003084:	6161                	addi	sp,sp,80
    80003086:	8082                	ret
    brelse(bp);
    80003088:	854a                	mv	a0,s2
    8000308a:	e1dff0ef          	jal	80002ea6 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    8000308e:	015c0abb          	addw	s5,s8,s5
    80003092:	004b2783          	lw	a5,4(s6)
    80003096:	04faf863          	bgeu	s5,a5,800030e6 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    8000309a:	40dad59b          	sraiw	a1,s5,0xd
    8000309e:	01cb2783          	lw	a5,28(s6)
    800030a2:	9dbd                	addw	a1,a1,a5
    800030a4:	855e                	mv	a0,s7
    800030a6:	cf9ff0ef          	jal	80002d9e <bread>
    800030aa:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    800030ac:	004b2503          	lw	a0,4(s6)
    800030b0:	84d6                	mv	s1,s5
    800030b2:	4701                	li	a4,0
    800030b4:	fca4fae3          	bgeu	s1,a0,80003088 <balloc+0x8a>
      m = 1 << (bi % 8);
    800030b8:	00777693          	andi	a3,a4,7
    800030bc:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    800030c0:	41f7579b          	sraiw	a5,a4,0x1f
    800030c4:	01d7d79b          	srliw	a5,a5,0x1d
    800030c8:	9fb9                	addw	a5,a5,a4
    800030ca:	4037d79b          	sraiw	a5,a5,0x3
    800030ce:	00f90633          	add	a2,s2,a5
    800030d2:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800030d6:	00c6f5b3          	and	a1,a3,a2
    800030da:	ddb1                	beqz	a1,80003036 <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    800030dc:	2705                	addiw	a4,a4,1
    800030de:	2485                	addiw	s1,s1,1
    800030e0:	fd471ae3          	bne	a4,s4,800030b4 <balloc+0xb6>
    800030e4:	b755                	j	80003088 <balloc+0x8a>
    800030e6:	7942                	ld	s2,48(sp)
    800030e8:	79a2                	ld	s3,40(sp)
    800030ea:	7a02                	ld	s4,32(sp)
    800030ec:	6ae2                	ld	s5,24(sp)
    800030ee:	6b42                	ld	s6,16(sp)
    800030f0:	6ba2                	ld	s7,8(sp)
    800030f2:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    800030f4:	00004517          	auipc	a0,0x4
    800030f8:	48c50513          	addi	a0,a0,1164 # 80007580 <etext+0x580>
    800030fc:	c0efd0ef          	jal	8000050a <printk>
  return 0;
    80003100:	4481                	li	s1,0
    80003102:	bfad                	j	8000307c <balloc+0x7e>

0000000080003104 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003104:	7179                	addi	sp,sp,-48
    80003106:	f406                	sd	ra,40(sp)
    80003108:	f022                	sd	s0,32(sp)
    8000310a:	ec26                	sd	s1,24(sp)
    8000310c:	e84a                	sd	s2,16(sp)
    8000310e:	e44e                	sd	s3,8(sp)
    80003110:	1800                	addi	s0,sp,48
    80003112:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80003114:	47ad                	li	a5,11
    80003116:	02b7e363          	bltu	a5,a1,8000313c <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    8000311a:	02059793          	slli	a5,a1,0x20
    8000311e:	01e7d593          	srli	a1,a5,0x1e
    80003122:	00b509b3          	add	s3,a0,a1
    80003126:	0509a483          	lw	s1,80(s3)
    8000312a:	e0b5                	bnez	s1,8000318e <bmap+0x8a>
      addr = balloc(ip->dev);
    8000312c:	4108                	lw	a0,0(a0)
    8000312e:	ed1ff0ef          	jal	80002ffe <balloc>
    80003132:	84aa                	mv	s1,a0
      if (addr == 0)
    80003134:	cd29                	beqz	a0,8000318e <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80003136:	04a9a823          	sw	a0,80(s3)
    8000313a:	a891                	j	8000318e <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000313c:	ff45879b          	addiw	a5,a1,-12
    80003140:	873e                	mv	a4,a5
    80003142:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    80003144:	0ff00793          	li	a5,255
    80003148:	06e7e763          	bltu	a5,a4,800031b6 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    8000314c:	08052483          	lw	s1,128(a0)
    80003150:	e891                	bnez	s1,80003164 <bmap+0x60>
      addr = balloc(ip->dev);
    80003152:	4108                	lw	a0,0(a0)
    80003154:	eabff0ef          	jal	80002ffe <balloc>
    80003158:	84aa                	mv	s1,a0
      if (addr == 0)
    8000315a:	c915                	beqz	a0,8000318e <bmap+0x8a>
    8000315c:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000315e:	08a92023          	sw	a0,128(s2)
    80003162:	a011                	j	80003166 <bmap+0x62>
    80003164:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003166:	85a6                	mv	a1,s1
    80003168:	00092503          	lw	a0,0(s2)
    8000316c:	c33ff0ef          	jal	80002d9e <bread>
    80003170:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80003172:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80003176:	02099713          	slli	a4,s3,0x20
    8000317a:	01e75593          	srli	a1,a4,0x1e
    8000317e:	97ae                	add	a5,a5,a1
    80003180:	89be                	mv	s3,a5
    80003182:	4384                	lw	s1,0(a5)
    80003184:	cc89                	beqz	s1,8000319e <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003186:	8552                	mv	a0,s4
    80003188:	d1fff0ef          	jal	80002ea6 <brelse>
    return addr;
    8000318c:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000318e:	8526                	mv	a0,s1
    80003190:	70a2                	ld	ra,40(sp)
    80003192:	7402                	ld	s0,32(sp)
    80003194:	64e2                	ld	s1,24(sp)
    80003196:	6942                	ld	s2,16(sp)
    80003198:	69a2                	ld	s3,8(sp)
    8000319a:	6145                	addi	sp,sp,48
    8000319c:	8082                	ret
      addr = balloc(ip->dev);
    8000319e:	00092503          	lw	a0,0(s2)
    800031a2:	e5dff0ef          	jal	80002ffe <balloc>
    800031a6:	84aa                	mv	s1,a0
      if (addr) {
    800031a8:	dd79                	beqz	a0,80003186 <bmap+0x82>
        a[bn] = addr;
    800031aa:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800031ae:	8552                	mv	a0,s4
    800031b0:	6ad000ef          	jal	8000405c <log_write>
    800031b4:	bfc9                	j	80003186 <bmap+0x82>
    800031b6:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800031b8:	00004517          	auipc	a0,0x4
    800031bc:	3e050513          	addi	a0,a0,992 # 80007598 <etext+0x598>
    800031c0:	e74fd0ef          	jal	80000834 <panic>

00000000800031c4 <iget>:
{
    800031c4:	7179                	addi	sp,sp,-48
    800031c6:	f406                	sd	ra,40(sp)
    800031c8:	f022                	sd	s0,32(sp)
    800031ca:	ec26                	sd	s1,24(sp)
    800031cc:	e84a                	sd	s2,16(sp)
    800031ce:	e44e                	sd	s3,8(sp)
    800031d0:	e052                	sd	s4,0(sp)
    800031d2:	1800                	addi	s0,sp,48
    800031d4:	892a                	mv	s2,a0
    800031d6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800031d8:	0001e517          	auipc	a0,0x1e
    800031dc:	94850513          	addi	a0,a0,-1720 # 80020b20 <itable>
    800031e0:	a49fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    800031e4:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800031e6:	0001e497          	auipc	s1,0x1e
    800031ea:	95248493          	addi	s1,s1,-1710 # 80020b38 <itable+0x18>
    800031ee:	0001f697          	auipc	a3,0x1f
    800031f2:	3da68693          	addi	a3,a3,986 # 800225c8 <log>
    800031f6:	a809                	j	80003208 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800031f8:	e781                	bnez	a5,80003200 <iget+0x3c>
    800031fa:	00099363          	bnez	s3,80003200 <iget+0x3c>
      empty = ip;
    800031fe:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003200:	08848493          	addi	s1,s1,136
    80003204:	02d48563          	beq	s1,a3,8000322e <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80003208:	449c                	lw	a5,8(s1)
    8000320a:	fef057e3          	blez	a5,800031f8 <iget+0x34>
    8000320e:	4098                	lw	a4,0(s1)
    80003210:	ff2718e3          	bne	a4,s2,80003200 <iget+0x3c>
    80003214:	40d8                	lw	a4,4(s1)
    80003216:	ff4715e3          	bne	a4,s4,80003200 <iget+0x3c>
      ip->ref++;
    8000321a:	2785                	addiw	a5,a5,1
    8000321c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000321e:	0001e517          	auipc	a0,0x1e
    80003222:	90250513          	addi	a0,a0,-1790 # 80020b20 <itable>
    80003226:	a8bfd0ef          	jal	80000cb0 <release>
      return ip;
    8000322a:	89a6                	mv	s3,s1
    8000322c:	a015                	j	80003250 <iget+0x8c>
  if (empty == 0)
    8000322e:	02098a63          	beqz	s3,80003262 <iget+0x9e>
  ip->dev = dev;
    80003232:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003236:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    8000323a:	4785                	li	a5,1
    8000323c:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003240:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003244:	0001e517          	auipc	a0,0x1e
    80003248:	8dc50513          	addi	a0,a0,-1828 # 80020b20 <itable>
    8000324c:	a65fd0ef          	jal	80000cb0 <release>
}
    80003250:	854e                	mv	a0,s3
    80003252:	70a2                	ld	ra,40(sp)
    80003254:	7402                	ld	s0,32(sp)
    80003256:	64e2                	ld	s1,24(sp)
    80003258:	6942                	ld	s2,16(sp)
    8000325a:	69a2                	ld	s3,8(sp)
    8000325c:	6a02                	ld	s4,0(sp)
    8000325e:	6145                	addi	sp,sp,48
    80003260:	8082                	ret
    panic("iget: no inodes");
    80003262:	00004517          	auipc	a0,0x4
    80003266:	34e50513          	addi	a0,a0,846 # 800075b0 <etext+0x5b0>
    8000326a:	dcafd0ef          	jal	80000834 <panic>

000000008000326e <iinit>:
{
    8000326e:	7179                	addi	sp,sp,-48
    80003270:	f406                	sd	ra,40(sp)
    80003272:	f022                	sd	s0,32(sp)
    80003274:	ec26                	sd	s1,24(sp)
    80003276:	e84a                	sd	s2,16(sp)
    80003278:	e44e                	sd	s3,8(sp)
    8000327a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000327c:	00004597          	auipc	a1,0x4
    80003280:	34458593          	addi	a1,a1,836 # 800075c0 <etext+0x5c0>
    80003284:	0001e517          	auipc	a0,0x1e
    80003288:	89c50513          	addi	a0,a0,-1892 # 80020b20 <itable>
    8000328c:	91dfd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    80003290:	0001e497          	auipc	s1,0x1e
    80003294:	8b848493          	addi	s1,s1,-1864 # 80020b48 <itable+0x28>
    80003298:	0001f997          	auipc	s3,0x1f
    8000329c:	34098993          	addi	s3,s3,832 # 800225d8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800032a0:	00004917          	auipc	s2,0x4
    800032a4:	32890913          	addi	s2,s2,808 # 800075c8 <etext+0x5c8>
    800032a8:	85ca                	mv	a1,s2
    800032aa:	8526                	mv	a0,s1
    800032ac:	6e9000ef          	jal	80004194 <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    800032b0:	08848493          	addi	s1,s1,136
    800032b4:	ff349ae3          	bne	s1,s3,800032a8 <iinit+0x3a>
}
    800032b8:	70a2                	ld	ra,40(sp)
    800032ba:	7402                	ld	s0,32(sp)
    800032bc:	64e2                	ld	s1,24(sp)
    800032be:	6942                	ld	s2,16(sp)
    800032c0:	69a2                	ld	s3,8(sp)
    800032c2:	6145                	addi	sp,sp,48
    800032c4:	8082                	ret

00000000800032c6 <ialloc>:
{
    800032c6:	7139                	addi	sp,sp,-64
    800032c8:	fc06                	sd	ra,56(sp)
    800032ca:	f822                	sd	s0,48(sp)
    800032cc:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    800032ce:	0001e717          	auipc	a4,0x1e
    800032d2:	83e72703          	lw	a4,-1986(a4) # 80020b0c <sb+0xc>
    800032d6:	4785                	li	a5,1
    800032d8:	06e7f063          	bgeu	a5,a4,80003338 <ialloc+0x72>
    800032dc:	f426                	sd	s1,40(sp)
    800032de:	f04a                	sd	s2,32(sp)
    800032e0:	ec4e                	sd	s3,24(sp)
    800032e2:	e852                	sd	s4,16(sp)
    800032e4:	e456                	sd	s5,8(sp)
    800032e6:	e05a                	sd	s6,0(sp)
    800032e8:	8aaa                	mv	s5,a0
    800032ea:	8b2e                	mv	s6,a1
    800032ec:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800032ee:	0001ea17          	auipc	s4,0x1e
    800032f2:	812a0a13          	addi	s4,s4,-2030 # 80020b00 <sb>
    800032f6:	00495593          	srli	a1,s2,0x4
    800032fa:	018a2783          	lw	a5,24(s4)
    800032fe:	9dbd                	addw	a1,a1,a5
    80003300:	8556                	mv	a0,s5
    80003302:	a9dff0ef          	jal	80002d9e <bread>
    80003306:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003308:	05850993          	addi	s3,a0,88
    8000330c:	00f97793          	andi	a5,s2,15
    80003310:	079a                	slli	a5,a5,0x6
    80003312:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    80003314:	00099783          	lh	a5,0(s3)
    80003318:	cb9d                	beqz	a5,8000334e <ialloc+0x88>
    brelse(bp);
    8000331a:	b8dff0ef          	jal	80002ea6 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000331e:	0905                	addi	s2,s2,1
    80003320:	00ca2703          	lw	a4,12(s4)
    80003324:	0009079b          	sext.w	a5,s2
    80003328:	fce7e7e3          	bltu	a5,a4,800032f6 <ialloc+0x30>
    8000332c:	74a2                	ld	s1,40(sp)
    8000332e:	7902                	ld	s2,32(sp)
    80003330:	69e2                	ld	s3,24(sp)
    80003332:	6a42                	ld	s4,16(sp)
    80003334:	6aa2                	ld	s5,8(sp)
    80003336:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    80003338:	00004517          	auipc	a0,0x4
    8000333c:	29850513          	addi	a0,a0,664 # 800075d0 <etext+0x5d0>
    80003340:	9cafd0ef          	jal	8000050a <printk>
  return 0;
    80003344:	4501                	li	a0,0
}
    80003346:	70e2                	ld	ra,56(sp)
    80003348:	7442                	ld	s0,48(sp)
    8000334a:	6121                	addi	sp,sp,64
    8000334c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000334e:	04000613          	li	a2,64
    80003352:	4581                	li	a1,0
    80003354:	854e                	mv	a0,s3
    80003356:	993fd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    8000335a:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    8000335e:	8526                	mv	a0,s1
    80003360:	4fd000ef          	jal	8000405c <log_write>
      brelse(bp);
    80003364:	8526                	mv	a0,s1
    80003366:	b41ff0ef          	jal	80002ea6 <brelse>
      return iget(dev, inum);
    8000336a:	0009059b          	sext.w	a1,s2
    8000336e:	8556                	mv	a0,s5
    80003370:	e55ff0ef          	jal	800031c4 <iget>
    80003374:	74a2                	ld	s1,40(sp)
    80003376:	7902                	ld	s2,32(sp)
    80003378:	69e2                	ld	s3,24(sp)
    8000337a:	6a42                	ld	s4,16(sp)
    8000337c:	6aa2                	ld	s5,8(sp)
    8000337e:	6b02                	ld	s6,0(sp)
    80003380:	b7d9                	j	80003346 <ialloc+0x80>

0000000080003382 <iupdate>:
{
    80003382:	1101                	addi	sp,sp,-32
    80003384:	ec06                	sd	ra,24(sp)
    80003386:	e822                	sd	s0,16(sp)
    80003388:	e426                	sd	s1,8(sp)
    8000338a:	e04a                	sd	s2,0(sp)
    8000338c:	1000                	addi	s0,sp,32
    8000338e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003390:	415c                	lw	a5,4(a0)
    80003392:	0047d79b          	srliw	a5,a5,0x4
    80003396:	0001d597          	auipc	a1,0x1d
    8000339a:	7825a583          	lw	a1,1922(a1) # 80020b18 <sb+0x18>
    8000339e:	9dbd                	addw	a1,a1,a5
    800033a0:	4108                	lw	a0,0(a0)
    800033a2:	9fdff0ef          	jal	80002d9e <bread>
    800033a6:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    800033a8:	05850793          	addi	a5,a0,88
    800033ac:	40d8                	lw	a4,4(s1)
    800033ae:	8b3d                	andi	a4,a4,15
    800033b0:	071a                	slli	a4,a4,0x6
    800033b2:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800033b4:	04449703          	lh	a4,68(s1)
    800033b8:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800033bc:	04649703          	lh	a4,70(s1)
    800033c0:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800033c4:	04849703          	lh	a4,72(s1)
    800033c8:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800033cc:	04a49703          	lh	a4,74(s1)
    800033d0:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800033d4:	44f8                	lw	a4,76(s1)
    800033d6:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800033d8:	03400613          	li	a2,52
    800033dc:	05048593          	addi	a1,s1,80
    800033e0:	00c78513          	addi	a0,a5,12
    800033e4:	965fd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    800033e8:	854a                	mv	a0,s2
    800033ea:	473000ef          	jal	8000405c <log_write>
  brelse(bp);
    800033ee:	854a                	mv	a0,s2
    800033f0:	ab7ff0ef          	jal	80002ea6 <brelse>
}
    800033f4:	60e2                	ld	ra,24(sp)
    800033f6:	6442                	ld	s0,16(sp)
    800033f8:	64a2                	ld	s1,8(sp)
    800033fa:	6902                	ld	s2,0(sp)
    800033fc:	6105                	addi	sp,sp,32
    800033fe:	8082                	ret

0000000080003400 <idup>:
{
    80003400:	1101                	addi	sp,sp,-32
    80003402:	ec06                	sd	ra,24(sp)
    80003404:	e822                	sd	s0,16(sp)
    80003406:	e426                	sd	s1,8(sp)
    80003408:	1000                	addi	s0,sp,32
    8000340a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000340c:	0001d517          	auipc	a0,0x1d
    80003410:	71450513          	addi	a0,a0,1812 # 80020b20 <itable>
    80003414:	815fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003418:	449c                	lw	a5,8(s1)
    8000341a:	2785                	addiw	a5,a5,1
    8000341c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000341e:	0001d517          	auipc	a0,0x1d
    80003422:	70250513          	addi	a0,a0,1794 # 80020b20 <itable>
    80003426:	88bfd0ef          	jal	80000cb0 <release>
}
    8000342a:	8526                	mv	a0,s1
    8000342c:	60e2                	ld	ra,24(sp)
    8000342e:	6442                	ld	s0,16(sp)
    80003430:	64a2                	ld	s1,8(sp)
    80003432:	6105                	addi	sp,sp,32
    80003434:	8082                	ret

0000000080003436 <ilock>:
{
    80003436:	1101                	addi	sp,sp,-32
    80003438:	ec06                	sd	ra,24(sp)
    8000343a:	e822                	sd	s0,16(sp)
    8000343c:	e426                	sd	s1,8(sp)
    8000343e:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003440:	cd19                	beqz	a0,8000345e <ilock+0x28>
    80003442:	84aa                	mv	s1,a0
    80003444:	451c                	lw	a5,8(a0)
    80003446:	00f05c63          	blez	a5,8000345e <ilock+0x28>
  acquiresleep(&ip->lock);
    8000344a:	0541                	addi	a0,a0,16
    8000344c:	57f000ef          	jal	800041ca <acquiresleep>
  if (ip->valid == 0) {
    80003450:	40bc                	lw	a5,64(s1)
    80003452:	cf89                	beqz	a5,8000346c <ilock+0x36>
}
    80003454:	60e2                	ld	ra,24(sp)
    80003456:	6442                	ld	s0,16(sp)
    80003458:	64a2                	ld	s1,8(sp)
    8000345a:	6105                	addi	sp,sp,32
    8000345c:	8082                	ret
    8000345e:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003460:	00004517          	auipc	a0,0x4
    80003464:	18850513          	addi	a0,a0,392 # 800075e8 <etext+0x5e8>
    80003468:	bccfd0ef          	jal	80000834 <panic>
    8000346c:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000346e:	40dc                	lw	a5,4(s1)
    80003470:	0047d79b          	srliw	a5,a5,0x4
    80003474:	0001d597          	auipc	a1,0x1d
    80003478:	6a45a583          	lw	a1,1700(a1) # 80020b18 <sb+0x18>
    8000347c:	9dbd                	addw	a1,a1,a5
    8000347e:	4088                	lw	a0,0(s1)
    80003480:	91fff0ef          	jal	80002d9e <bread>
    80003484:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003486:	05850593          	addi	a1,a0,88
    8000348a:	40dc                	lw	a5,4(s1)
    8000348c:	8bbd                	andi	a5,a5,15
    8000348e:	079a                	slli	a5,a5,0x6
    80003490:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003492:	00059783          	lh	a5,0(a1)
    80003496:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000349a:	00259783          	lh	a5,2(a1)
    8000349e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800034a2:	00459783          	lh	a5,4(a1)
    800034a6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800034aa:	00659783          	lh	a5,6(a1)
    800034ae:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800034b2:	459c                	lw	a5,8(a1)
    800034b4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800034b6:	03400613          	li	a2,52
    800034ba:	05b1                	addi	a1,a1,12
    800034bc:	05048513          	addi	a0,s1,80
    800034c0:	889fd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    800034c4:	854a                	mv	a0,s2
    800034c6:	9e1ff0ef          	jal	80002ea6 <brelse>
    ip->valid = 1;
    800034ca:	4785                	li	a5,1
    800034cc:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    800034ce:	04449783          	lh	a5,68(s1)
    800034d2:	c399                	beqz	a5,800034d8 <ilock+0xa2>
    800034d4:	6902                	ld	s2,0(sp)
    800034d6:	bfbd                	j	80003454 <ilock+0x1e>
      panic("ilock: no type");
    800034d8:	00004517          	auipc	a0,0x4
    800034dc:	11850513          	addi	a0,a0,280 # 800075f0 <etext+0x5f0>
    800034e0:	b54fd0ef          	jal	80000834 <panic>

00000000800034e4 <iunlock>:
{
    800034e4:	1101                	addi	sp,sp,-32
    800034e6:	ec06                	sd	ra,24(sp)
    800034e8:	e822                	sd	s0,16(sp)
    800034ea:	e426                	sd	s1,8(sp)
    800034ec:	e04a                	sd	s2,0(sp)
    800034ee:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800034f0:	c505                	beqz	a0,80003518 <iunlock+0x34>
    800034f2:	84aa                	mv	s1,a0
    800034f4:	01050913          	addi	s2,a0,16
    800034f8:	854a                	mv	a0,s2
    800034fa:	55d000ef          	jal	80004256 <holdingsleep>
    800034fe:	cd09                	beqz	a0,80003518 <iunlock+0x34>
    80003500:	449c                	lw	a5,8(s1)
    80003502:	00f05b63          	blez	a5,80003518 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003506:	854a                	mv	a0,s2
    80003508:	517000ef          	jal	8000421e <releasesleep>
}
    8000350c:	60e2                	ld	ra,24(sp)
    8000350e:	6442                	ld	s0,16(sp)
    80003510:	64a2                	ld	s1,8(sp)
    80003512:	6902                	ld	s2,0(sp)
    80003514:	6105                	addi	sp,sp,32
    80003516:	8082                	ret
    panic("iunlock");
    80003518:	00004517          	auipc	a0,0x4
    8000351c:	0e850513          	addi	a0,a0,232 # 80007600 <etext+0x600>
    80003520:	b14fd0ef          	jal	80000834 <panic>

0000000080003524 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003524:	7179                	addi	sp,sp,-48
    80003526:	f406                	sd	ra,40(sp)
    80003528:	f022                	sd	s0,32(sp)
    8000352a:	ec26                	sd	s1,24(sp)
    8000352c:	e84a                	sd	s2,16(sp)
    8000352e:	e44e                	sd	s3,8(sp)
    80003530:	1800                	addi	s0,sp,48
    80003532:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    80003534:	05050493          	addi	s1,a0,80
    80003538:	08050913          	addi	s2,a0,128
    8000353c:	a021                	j	80003544 <itrunc+0x20>
    8000353e:	0491                	addi	s1,s1,4
    80003540:	01248b63          	beq	s1,s2,80003556 <itrunc+0x32>
    if (ip->addrs[i]) {
    80003544:	408c                	lw	a1,0(s1)
    80003546:	dde5                	beqz	a1,8000353e <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003548:	0009a503          	lw	a0,0(s3)
    8000354c:	a47ff0ef          	jal	80002f92 <bfree>
      ip->addrs[i] = 0;
    80003550:	0004a023          	sw	zero,0(s1)
    80003554:	b7ed                	j	8000353e <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    80003556:	0809a583          	lw	a1,128(s3)
    8000355a:	ed89                	bnez	a1,80003574 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000355c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003560:	854e                	mv	a0,s3
    80003562:	e21ff0ef          	jal	80003382 <iupdate>
}
    80003566:	70a2                	ld	ra,40(sp)
    80003568:	7402                	ld	s0,32(sp)
    8000356a:	64e2                	ld	s1,24(sp)
    8000356c:	6942                	ld	s2,16(sp)
    8000356e:	69a2                	ld	s3,8(sp)
    80003570:	6145                	addi	sp,sp,48
    80003572:	8082                	ret
    80003574:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003576:	0009a503          	lw	a0,0(s3)
    8000357a:	825ff0ef          	jal	80002d9e <bread>
    8000357e:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    80003580:	05850493          	addi	s1,a0,88
    80003584:	45850913          	addi	s2,a0,1112
    80003588:	a021                	j	80003590 <itrunc+0x6c>
    8000358a:	0491                	addi	s1,s1,4
    8000358c:	01248963          	beq	s1,s2,8000359e <itrunc+0x7a>
      if (a[j])
    80003590:	408c                	lw	a1,0(s1)
    80003592:	dde5                	beqz	a1,8000358a <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003594:	0009a503          	lw	a0,0(s3)
    80003598:	9fbff0ef          	jal	80002f92 <bfree>
    8000359c:	b7fd                	j	8000358a <itrunc+0x66>
    brelse(bp);
    8000359e:	8552                	mv	a0,s4
    800035a0:	907ff0ef          	jal	80002ea6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800035a4:	0809a583          	lw	a1,128(s3)
    800035a8:	0009a503          	lw	a0,0(s3)
    800035ac:	9e7ff0ef          	jal	80002f92 <bfree>
    ip->addrs[NDIRECT] = 0;
    800035b0:	0809a023          	sw	zero,128(s3)
    800035b4:	6a02                	ld	s4,0(sp)
    800035b6:	b75d                	j	8000355c <itrunc+0x38>

00000000800035b8 <iput>:
{
    800035b8:	7179                	addi	sp,sp,-48
    800035ba:	f406                	sd	ra,40(sp)
    800035bc:	f022                	sd	s0,32(sp)
    800035be:	ec26                	sd	s1,24(sp)
    800035c0:	1800                	addi	s0,sp,48
    800035c2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800035c4:	0001d517          	auipc	a0,0x1d
    800035c8:	55c50513          	addi	a0,a0,1372 # 80020b20 <itable>
    800035cc:	e5cfd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800035d0:	449c                	lw	a5,8(s1)
    800035d2:	4705                	li	a4,1
    800035d4:	00e78f63          	beq	a5,a4,800035f2 <iput+0x3a>
  ip->ref--;
    800035d8:	37fd                	addiw	a5,a5,-1
    800035da:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035dc:	0001d517          	auipc	a0,0x1d
    800035e0:	54450513          	addi	a0,a0,1348 # 80020b20 <itable>
    800035e4:	eccfd0ef          	jal	80000cb0 <release>
}
    800035e8:	70a2                	ld	ra,40(sp)
    800035ea:	7402                	ld	s0,32(sp)
    800035ec:	64e2                	ld	s1,24(sp)
    800035ee:	6145                	addi	sp,sp,48
    800035f0:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800035f2:	40b8                	lw	a4,64(s1)
    800035f4:	d375                	beqz	a4,800035d8 <iput+0x20>
    800035f6:	e84a                	sd	s2,16(sp)
    800035f8:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    800035fa:	0004aa03          	lw	s4,0(s1)
    800035fe:	0044a903          	lw	s2,4(s1)
  if (last) {
    80003602:	04a49703          	lh	a4,74(s1)
    80003606:	ef3d                	bnez	a4,80003684 <iput+0xcc>
    80003608:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    8000360a:	01048793          	addi	a5,s1,16
    8000360e:	89be                	mv	s3,a5
    80003610:	853e                	mv	a0,a5
    80003612:	3b9000ef          	jal	800041ca <acquiresleep>
    release(&itable.lock);
    80003616:	0001d517          	auipc	a0,0x1d
    8000361a:	50a50513          	addi	a0,a0,1290 # 80020b20 <itable>
    8000361e:	e92fd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    80003622:	8526                	mv	a0,s1
    80003624:	f01ff0ef          	jal	80003524 <itrunc>
    ip->valid = 0;
    80003628:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000362c:	854e                	mv	a0,s3
    8000362e:	3f1000ef          	jal	8000421e <releasesleep>
    acquire(&itable.lock);
    80003632:	0001d517          	auipc	a0,0x1d
    80003636:	4ee50513          	addi	a0,a0,1262 # 80020b20 <itable>
    8000363a:	deefd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    8000363e:	449c                	lw	a5,8(s1)
    80003640:	37fd                	addiw	a5,a5,-1
    80003642:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003644:	0001d517          	auipc	a0,0x1d
    80003648:	4dc50513          	addi	a0,a0,1244 # 80020b20 <itable>
    8000364c:	e64fd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003650:	0049579b          	srliw	a5,s2,0x4
    80003654:	0001d597          	auipc	a1,0x1d
    80003658:	4c45a583          	lw	a1,1220(a1) # 80020b18 <sb+0x18>
    8000365c:	9dbd                	addw	a1,a1,a5
    8000365e:	8552                	mv	a0,s4
    80003660:	f3eff0ef          	jal	80002d9e <bread>
    80003664:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003666:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    8000366a:	079a                	slli	a5,a5,0x6
    8000366c:	97aa                	add	a5,a5,a0
    8000366e:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    80003672:	1eb000ef          	jal	8000405c <log_write>
  brelse(bp);
    80003676:	8526                	mv	a0,s1
    80003678:	82fff0ef          	jal	80002ea6 <brelse>
}
    8000367c:	6942                	ld	s2,16(sp)
    8000367e:	69a2                	ld	s3,8(sp)
    80003680:	6a02                	ld	s4,0(sp)
    80003682:	b79d                	j	800035e8 <iput+0x30>
    80003684:	6942                	ld	s2,16(sp)
    80003686:	6a02                	ld	s4,0(sp)
    80003688:	bf81                	j	800035d8 <iput+0x20>

000000008000368a <iunlockput>:
{
    8000368a:	1101                	addi	sp,sp,-32
    8000368c:	ec06                	sd	ra,24(sp)
    8000368e:	e822                	sd	s0,16(sp)
    80003690:	e426                	sd	s1,8(sp)
    80003692:	1000                	addi	s0,sp,32
    80003694:	84aa                	mv	s1,a0
  iunlock(ip);
    80003696:	e4fff0ef          	jal	800034e4 <iunlock>
  iput(ip);
    8000369a:	8526                	mv	a0,s1
    8000369c:	f1dff0ef          	jal	800035b8 <iput>
}
    800036a0:	60e2                	ld	ra,24(sp)
    800036a2:	6442                	ld	s0,16(sp)
    800036a4:	64a2                	ld	s1,8(sp)
    800036a6:	6105                	addi	sp,sp,32
    800036a8:	8082                	ret

00000000800036aa <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036aa:	0001d717          	auipc	a4,0x1d
    800036ae:	46272703          	lw	a4,1122(a4) # 80020b0c <sb+0xc>
    800036b2:	4785                	li	a5,1
    800036b4:	0ae7fe63          	bgeu	a5,a4,80003770 <ireclaim+0xc6>
{
    800036b8:	7139                	addi	sp,sp,-64
    800036ba:	fc06                	sd	ra,56(sp)
    800036bc:	f822                	sd	s0,48(sp)
    800036be:	f426                	sd	s1,40(sp)
    800036c0:	f04a                	sd	s2,32(sp)
    800036c2:	ec4e                	sd	s3,24(sp)
    800036c4:	e852                	sd	s4,16(sp)
    800036c6:	e456                	sd	s5,8(sp)
    800036c8:	e05a                	sd	s6,0(sp)
    800036ca:	0080                	addi	s0,sp,64
    800036cc:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036ce:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036d0:	0001da17          	auipc	s4,0x1d
    800036d4:	430a0a13          	addi	s4,s4,1072 # 80020b00 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    800036d8:	00004b17          	auipc	s6,0x4
    800036dc:	f30b0b13          	addi	s6,s6,-208 # 80007608 <etext+0x608>
    800036e0:	a099                	j	80003726 <ireclaim+0x7c>
    800036e2:	85ce                	mv	a1,s3
    800036e4:	855a                	mv	a0,s6
    800036e6:	e25fc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    800036ea:	85ce                	mv	a1,s3
    800036ec:	8556                	mv	a0,s5
    800036ee:	ad7ff0ef          	jal	800031c4 <iget>
    800036f2:	89aa                	mv	s3,a0
    brelse(bp);
    800036f4:	854a                	mv	a0,s2
    800036f6:	fb0ff0ef          	jal	80002ea6 <brelse>
    if (ip) {
    800036fa:	00098f63          	beqz	s3,80003718 <ireclaim+0x6e>
      begin_op();
    800036fe:	7b0000ef          	jal	80003eae <begin_op>
      ilock(ip);
    80003702:	854e                	mv	a0,s3
    80003704:	d33ff0ef          	jal	80003436 <ilock>
      iunlock(ip);
    80003708:	854e                	mv	a0,s3
    8000370a:	ddbff0ef          	jal	800034e4 <iunlock>
      iput(ip);
    8000370e:	854e                	mv	a0,s3
    80003710:	ea9ff0ef          	jal	800035b8 <iput>
      end_op();
    80003714:	027000ef          	jal	80003f3a <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003718:	0485                	addi	s1,s1,1
    8000371a:	00ca2703          	lw	a4,12(s4)
    8000371e:	0004879b          	sext.w	a5,s1
    80003722:	02e7fd63          	bgeu	a5,a4,8000375c <ireclaim+0xb2>
    80003726:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000372a:	0044d593          	srli	a1,s1,0x4
    8000372e:	018a2783          	lw	a5,24(s4)
    80003732:	9dbd                	addw	a1,a1,a5
    80003734:	8556                	mv	a0,s5
    80003736:	e68ff0ef          	jal	80002d9e <bread>
    8000373a:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000373c:	05850793          	addi	a5,a0,88
    80003740:	00f9f713          	andi	a4,s3,15
    80003744:	071a                	slli	a4,a4,0x6
    80003746:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    80003748:	00079703          	lh	a4,0(a5)
    8000374c:	c701                	beqz	a4,80003754 <ireclaim+0xaa>
    8000374e:	00679783          	lh	a5,6(a5)
    80003752:	dbc1                	beqz	a5,800036e2 <ireclaim+0x38>
    brelse(bp);
    80003754:	854a                	mv	a0,s2
    80003756:	f50ff0ef          	jal	80002ea6 <brelse>
    if (ip) {
    8000375a:	bf7d                	j	80003718 <ireclaim+0x6e>
}
    8000375c:	70e2                	ld	ra,56(sp)
    8000375e:	7442                	ld	s0,48(sp)
    80003760:	74a2                	ld	s1,40(sp)
    80003762:	7902                	ld	s2,32(sp)
    80003764:	69e2                	ld	s3,24(sp)
    80003766:	6a42                	ld	s4,16(sp)
    80003768:	6aa2                	ld	s5,8(sp)
    8000376a:	6b02                	ld	s6,0(sp)
    8000376c:	6121                	addi	sp,sp,64
    8000376e:	8082                	ret
    80003770:	8082                	ret

0000000080003772 <fsinit>:
{
    80003772:	1101                	addi	sp,sp,-32
    80003774:	ec06                	sd	ra,24(sp)
    80003776:	e822                	sd	s0,16(sp)
    80003778:	e426                	sd	s1,8(sp)
    8000377a:	e04a                	sd	s2,0(sp)
    8000377c:	1000                	addi	s0,sp,32
    8000377e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003780:	4585                	li	a1,1
    80003782:	e1cff0ef          	jal	80002d9e <bread>
    80003786:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003788:	02000613          	li	a2,32
    8000378c:	05850593          	addi	a1,a0,88
    80003790:	0001d517          	auipc	a0,0x1d
    80003794:	37050513          	addi	a0,a0,880 # 80020b00 <sb>
    80003798:	db0fd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    8000379c:	8526                	mv	a0,s1
    8000379e:	f08ff0ef          	jal	80002ea6 <brelse>
  if (sb.magic != FSMAGIC)
    800037a2:	0001d717          	auipc	a4,0x1d
    800037a6:	35e72703          	lw	a4,862(a4) # 80020b00 <sb>
    800037aa:	102037b7          	lui	a5,0x10203
    800037ae:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037b2:	02f71263          	bne	a4,a5,800037d6 <fsinit+0x64>
  initlog(dev, &sb);
    800037b6:	0001d597          	auipc	a1,0x1d
    800037ba:	34a58593          	addi	a1,a1,842 # 80020b00 <sb>
    800037be:	854a                	mv	a0,s2
    800037c0:	66c000ef          	jal	80003e2c <initlog>
  ireclaim(dev);
    800037c4:	854a                	mv	a0,s2
    800037c6:	ee5ff0ef          	jal	800036aa <ireclaim>
}
    800037ca:	60e2                	ld	ra,24(sp)
    800037cc:	6442                	ld	s0,16(sp)
    800037ce:	64a2                	ld	s1,8(sp)
    800037d0:	6902                	ld	s2,0(sp)
    800037d2:	6105                	addi	sp,sp,32
    800037d4:	8082                	ret
    panic("invalid file system");
    800037d6:	00004517          	auipc	a0,0x4
    800037da:	e5250513          	addi	a0,a0,-430 # 80007628 <etext+0x628>
    800037de:	856fd0ef          	jal	80000834 <panic>

00000000800037e2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800037e2:	1141                	addi	sp,sp,-16
    800037e4:	e406                	sd	ra,8(sp)
    800037e6:	e022                	sd	s0,0(sp)
    800037e8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800037ea:	411c                	lw	a5,0(a0)
    800037ec:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800037ee:	415c                	lw	a5,4(a0)
    800037f0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800037f2:	04451783          	lh	a5,68(a0)
    800037f6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800037fa:	04a51783          	lh	a5,74(a0)
    800037fe:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003802:	04c56783          	lwu	a5,76(a0)
    80003806:	e99c                	sd	a5,16(a1)
}
    80003808:	60a2                	ld	ra,8(sp)
    8000380a:	6402                	ld	s0,0(sp)
    8000380c:	0141                	addi	sp,sp,16
    8000380e:	8082                	ret

0000000080003810 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003810:	457c                	lw	a5,76(a0)
    80003812:	0ed7e663          	bltu	a5,a3,800038fe <readi+0xee>
{
    80003816:	7159                	addi	sp,sp,-112
    80003818:	f486                	sd	ra,104(sp)
    8000381a:	f0a2                	sd	s0,96(sp)
    8000381c:	eca6                	sd	s1,88(sp)
    8000381e:	e0d2                	sd	s4,64(sp)
    80003820:	fc56                	sd	s5,56(sp)
    80003822:	f85a                	sd	s6,48(sp)
    80003824:	f45e                	sd	s7,40(sp)
    80003826:	1880                	addi	s0,sp,112
    80003828:	8b2a                	mv	s6,a0
    8000382a:	8bae                	mv	s7,a1
    8000382c:	8a32                	mv	s4,a2
    8000382e:	84b6                	mv	s1,a3
    80003830:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003832:	9f35                	addw	a4,a4,a3
    return 0;
    80003834:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003836:	0ad76b63          	bltu	a4,a3,800038ec <readi+0xdc>
    8000383a:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    8000383c:	00e7f463          	bgeu	a5,a4,80003844 <readi+0x34>
    n = ip->size - off;
    80003840:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003844:	080a8b63          	beqz	s5,800038da <readi+0xca>
    80003848:	e8ca                	sd	s2,80(sp)
    8000384a:	f062                	sd	s8,32(sp)
    8000384c:	ec66                	sd	s9,24(sp)
    8000384e:	e86a                	sd	s10,16(sp)
    80003850:	e46e                	sd	s11,8(sp)
    80003852:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003854:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003858:	5c7d                	li	s8,-1
    8000385a:	a80d                	j	8000388c <readi+0x7c>
    8000385c:	020d1d93          	slli	s11,s10,0x20
    80003860:	020ddd93          	srli	s11,s11,0x20
    80003864:	05890613          	addi	a2,s2,88
    80003868:	86ee                	mv	a3,s11
    8000386a:	963e                	add	a2,a2,a5
    8000386c:	85d2                	mv	a1,s4
    8000386e:	855e                	mv	a0,s7
    80003870:	c27fe0ef          	jal	80002496 <either_copyout>
    80003874:	05850363          	beq	a0,s8,800038ba <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003878:	854a                	mv	a0,s2
    8000387a:	e2cff0ef          	jal	80002ea6 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000387e:	013d09bb          	addw	s3,s10,s3
    80003882:	009d04bb          	addw	s1,s10,s1
    80003886:	9a6e                	add	s4,s4,s11
    80003888:	0559f363          	bgeu	s3,s5,800038ce <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    8000388c:	00a4d59b          	srliw	a1,s1,0xa
    80003890:	855a                	mv	a0,s6
    80003892:	873ff0ef          	jal	80003104 <bmap>
    80003896:	85aa                	mv	a1,a0
    if (addr == 0)
    80003898:	c139                	beqz	a0,800038de <readi+0xce>
    bp = bread(ip->dev, addr);
    8000389a:	000b2503          	lw	a0,0(s6)
    8000389e:	d00ff0ef          	jal	80002d9e <bread>
    800038a2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800038a4:	3ff4f793          	andi	a5,s1,1023
    800038a8:	40fc873b          	subw	a4,s9,a5
    800038ac:	413a86bb          	subw	a3,s5,s3
    800038b0:	8d3a                	mv	s10,a4
    800038b2:	fae6f5e3          	bgeu	a3,a4,8000385c <readi+0x4c>
    800038b6:	8d36                	mv	s10,a3
    800038b8:	b755                	j	8000385c <readi+0x4c>
      brelse(bp);
    800038ba:	854a                	mv	a0,s2
    800038bc:	deaff0ef          	jal	80002ea6 <brelse>
      tot = -1;
    800038c0:	59fd                	li	s3,-1
      break;
    800038c2:	6946                	ld	s2,80(sp)
    800038c4:	7c02                	ld	s8,32(sp)
    800038c6:	6ce2                	ld	s9,24(sp)
    800038c8:	6d42                	ld	s10,16(sp)
    800038ca:	6da2                	ld	s11,8(sp)
    800038cc:	a831                	j	800038e8 <readi+0xd8>
    800038ce:	6946                	ld	s2,80(sp)
    800038d0:	7c02                	ld	s8,32(sp)
    800038d2:	6ce2                	ld	s9,24(sp)
    800038d4:	6d42                	ld	s10,16(sp)
    800038d6:	6da2                	ld	s11,8(sp)
    800038d8:	a801                	j	800038e8 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800038da:	89d6                	mv	s3,s5
    800038dc:	a031                	j	800038e8 <readi+0xd8>
    800038de:	6946                	ld	s2,80(sp)
    800038e0:	7c02                	ld	s8,32(sp)
    800038e2:	6ce2                	ld	s9,24(sp)
    800038e4:	6d42                	ld	s10,16(sp)
    800038e6:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800038e8:	854e                	mv	a0,s3
    800038ea:	69a6                	ld	s3,72(sp)
}
    800038ec:	70a6                	ld	ra,104(sp)
    800038ee:	7406                	ld	s0,96(sp)
    800038f0:	64e6                	ld	s1,88(sp)
    800038f2:	6a06                	ld	s4,64(sp)
    800038f4:	7ae2                	ld	s5,56(sp)
    800038f6:	7b42                	ld	s6,48(sp)
    800038f8:	7ba2                	ld	s7,40(sp)
    800038fa:	6165                	addi	sp,sp,112
    800038fc:	8082                	ret
    return 0;
    800038fe:	4501                	li	a0,0
}
    80003900:	8082                	ret

0000000080003902 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003902:	457c                	lw	a5,76(a0)
    80003904:	0ed7ee63          	bltu	a5,a3,80003a00 <writei+0xfe>
{
    80003908:	7159                	addi	sp,sp,-112
    8000390a:	f486                	sd	ra,104(sp)
    8000390c:	f0a2                	sd	s0,96(sp)
    8000390e:	e8ca                	sd	s2,80(sp)
    80003910:	e0d2                	sd	s4,64(sp)
    80003912:	fc56                	sd	s5,56(sp)
    80003914:	f85a                	sd	s6,48(sp)
    80003916:	f45e                	sd	s7,40(sp)
    80003918:	1880                	addi	s0,sp,112
    8000391a:	8aaa                	mv	s5,a0
    8000391c:	8bae                	mv	s7,a1
    8000391e:	8a32                	mv	s4,a2
    80003920:	8936                	mv	s2,a3
    80003922:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003924:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003928:	00043737          	lui	a4,0x43
    8000392c:	0cf76c63          	bltu	a4,a5,80003a04 <writei+0x102>
    80003930:	0cd7ea63          	bltu	a5,a3,80003a04 <writei+0x102>
    80003934:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003936:	0a0b0d63          	beqz	s6,800039f0 <writei+0xee>
    8000393a:	eca6                	sd	s1,88(sp)
    8000393c:	f062                	sd	s8,32(sp)
    8000393e:	ec66                	sd	s9,24(sp)
    80003940:	e86a                	sd	s10,16(sp)
    80003942:	e46e                	sd	s11,8(sp)
    80003944:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003946:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000394a:	5c7d                	li	s8,-1
    8000394c:	a825                	j	80003984 <writei+0x82>
    8000394e:	020d1d93          	slli	s11,s10,0x20
    80003952:	020ddd93          	srli	s11,s11,0x20
    80003956:	05848513          	addi	a0,s1,88
    8000395a:	86ee                	mv	a3,s11
    8000395c:	8652                	mv	a2,s4
    8000395e:	85de                	mv	a1,s7
    80003960:	953e                	add	a0,a0,a5
    80003962:	b81fe0ef          	jal	800024e2 <either_copyin>
    80003966:	05850663          	beq	a0,s8,800039b2 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    8000396a:	8526                	mv	a0,s1
    8000396c:	6f0000ef          	jal	8000405c <log_write>
    brelse(bp);
    80003970:	8526                	mv	a0,s1
    80003972:	d34ff0ef          	jal	80002ea6 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003976:	013d09bb          	addw	s3,s10,s3
    8000397a:	012d093b          	addw	s2,s10,s2
    8000397e:	9a6e                	add	s4,s4,s11
    80003980:	0369ff63          	bgeu	s3,s6,800039be <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    80003984:	00a9559b          	srliw	a1,s2,0xa
    80003988:	8556                	mv	a0,s5
    8000398a:	f7aff0ef          	jal	80003104 <bmap>
    8000398e:	85aa                	mv	a1,a0
    if (addr == 0)
    80003990:	c51d                	beqz	a0,800039be <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003992:	000aa503          	lw	a0,0(s5)
    80003996:	c08ff0ef          	jal	80002d9e <bread>
    8000399a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000399c:	3ff97793          	andi	a5,s2,1023
    800039a0:	40fc873b          	subw	a4,s9,a5
    800039a4:	413b06bb          	subw	a3,s6,s3
    800039a8:	8d3a                	mv	s10,a4
    800039aa:	fae6f2e3          	bgeu	a3,a4,8000394e <writei+0x4c>
    800039ae:	8d36                	mv	s10,a3
    800039b0:	bf79                	j	8000394e <writei+0x4c>
      log_write(bp);
    800039b2:	8526                	mv	a0,s1
    800039b4:	6a8000ef          	jal	8000405c <log_write>
      brelse(bp);
    800039b8:	8526                	mv	a0,s1
    800039ba:	cecff0ef          	jal	80002ea6 <brelse>
  }

  if (off > ip->size)
    800039be:	04caa783          	lw	a5,76(s5)
    800039c2:	0327f963          	bgeu	a5,s2,800039f4 <writei+0xf2>
    ip->size = off;
    800039c6:	052aa623          	sw	s2,76(s5)
    800039ca:	64e6                	ld	s1,88(sp)
    800039cc:	7c02                	ld	s8,32(sp)
    800039ce:	6ce2                	ld	s9,24(sp)
    800039d0:	6d42                	ld	s10,16(sp)
    800039d2:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800039d4:	8556                	mv	a0,s5
    800039d6:	9adff0ef          	jal	80003382 <iupdate>

  return tot;
    800039da:	854e                	mv	a0,s3
    800039dc:	69a6                	ld	s3,72(sp)
}
    800039de:	70a6                	ld	ra,104(sp)
    800039e0:	7406                	ld	s0,96(sp)
    800039e2:	6946                	ld	s2,80(sp)
    800039e4:	6a06                	ld	s4,64(sp)
    800039e6:	7ae2                	ld	s5,56(sp)
    800039e8:	7b42                	ld	s6,48(sp)
    800039ea:	7ba2                	ld	s7,40(sp)
    800039ec:	6165                	addi	sp,sp,112
    800039ee:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800039f0:	89da                	mv	s3,s6
    800039f2:	b7cd                	j	800039d4 <writei+0xd2>
    800039f4:	64e6                	ld	s1,88(sp)
    800039f6:	7c02                	ld	s8,32(sp)
    800039f8:	6ce2                	ld	s9,24(sp)
    800039fa:	6d42                	ld	s10,16(sp)
    800039fc:	6da2                	ld	s11,8(sp)
    800039fe:	bfd9                	j	800039d4 <writei+0xd2>
    return -1;
    80003a00:	557d                	li	a0,-1
}
    80003a02:	8082                	ret
    return -1;
    80003a04:	557d                	li	a0,-1
    80003a06:	bfe1                	j	800039de <writei+0xdc>

0000000080003a08 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003a08:	1141                	addi	sp,sp,-16
    80003a0a:	e406                	sd	ra,8(sp)
    80003a0c:	e022                	sd	s0,0(sp)
    80003a0e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a10:	4639                	li	a2,14
    80003a12:	baafd0ef          	jal	80000dbc <strncmp>
}
    80003a16:	60a2                	ld	ra,8(sp)
    80003a18:	6402                	ld	s0,0(sp)
    80003a1a:	0141                	addi	sp,sp,16
    80003a1c:	8082                	ret

0000000080003a1e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a1e:	711d                	addi	sp,sp,-96
    80003a20:	ec86                	sd	ra,88(sp)
    80003a22:	e8a2                	sd	s0,80(sp)
    80003a24:	e4a6                	sd	s1,72(sp)
    80003a26:	e0ca                	sd	s2,64(sp)
    80003a28:	fc4e                	sd	s3,56(sp)
    80003a2a:	f852                	sd	s4,48(sp)
    80003a2c:	f456                	sd	s5,40(sp)
    80003a2e:	f05a                	sd	s6,32(sp)
    80003a30:	ec5e                	sd	s7,24(sp)
    80003a32:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003a34:	04451703          	lh	a4,68(a0)
    80003a38:	4785                	li	a5,1
    80003a3a:	00f71f63          	bne	a4,a5,80003a58 <dirlookup+0x3a>
    80003a3e:	892a                	mv	s2,a0
    80003a40:	8aae                	mv	s5,a1
    80003a42:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a44:	457c                	lw	a5,76(a0)
    80003a46:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a48:	fa040a13          	addi	s4,s0,-96
    80003a4c:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003a4e:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a52:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a54:	e39d                	bnez	a5,80003a7a <dirlookup+0x5c>
    80003a56:	a8b9                	j	80003ab4 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003a58:	00004517          	auipc	a0,0x4
    80003a5c:	be850513          	addi	a0,a0,-1048 # 80007640 <etext+0x640>
    80003a60:	dd5fc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    80003a64:	00004517          	auipc	a0,0x4
    80003a68:	bf450513          	addi	a0,a0,-1036 # 80007658 <etext+0x658>
    80003a6c:	dc9fc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a70:	24c1                	addiw	s1,s1,16
    80003a72:	04c92783          	lw	a5,76(s2)
    80003a76:	02f4fe63          	bgeu	s1,a5,80003ab2 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a7a:	874e                	mv	a4,s3
    80003a7c:	86a6                	mv	a3,s1
    80003a7e:	8652                	mv	a2,s4
    80003a80:	4581                	li	a1,0
    80003a82:	854a                	mv	a0,s2
    80003a84:	d8dff0ef          	jal	80003810 <readi>
    80003a88:	fd351ee3          	bne	a0,s3,80003a64 <dirlookup+0x46>
    if (de.inum == 0)
    80003a8c:	fa045783          	lhu	a5,-96(s0)
    80003a90:	d3e5                	beqz	a5,80003a70 <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003a92:	85da                	mv	a1,s6
    80003a94:	8556                	mv	a0,s5
    80003a96:	f73ff0ef          	jal	80003a08 <namecmp>
    80003a9a:	f979                	bnez	a0,80003a70 <dirlookup+0x52>
      if (poff)
    80003a9c:	000b8463          	beqz	s7,80003aa4 <dirlookup+0x86>
        *poff = off;
    80003aa0:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003aa4:	fa045583          	lhu	a1,-96(s0)
    80003aa8:	00092503          	lw	a0,0(s2)
    80003aac:	f18ff0ef          	jal	800031c4 <iget>
    80003ab0:	a011                	j	80003ab4 <dirlookup+0x96>
  return 0;
    80003ab2:	4501                	li	a0,0
}
    80003ab4:	60e6                	ld	ra,88(sp)
    80003ab6:	6446                	ld	s0,80(sp)
    80003ab8:	64a6                	ld	s1,72(sp)
    80003aba:	6906                	ld	s2,64(sp)
    80003abc:	79e2                	ld	s3,56(sp)
    80003abe:	7a42                	ld	s4,48(sp)
    80003ac0:	7aa2                	ld	s5,40(sp)
    80003ac2:	7b02                	ld	s6,32(sp)
    80003ac4:	6be2                	ld	s7,24(sp)
    80003ac6:	6125                	addi	sp,sp,96
    80003ac8:	8082                	ret

0000000080003aca <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003aca:	711d                	addi	sp,sp,-96
    80003acc:	ec86                	sd	ra,88(sp)
    80003ace:	e8a2                	sd	s0,80(sp)
    80003ad0:	e4a6                	sd	s1,72(sp)
    80003ad2:	e0ca                	sd	s2,64(sp)
    80003ad4:	fc4e                	sd	s3,56(sp)
    80003ad6:	f852                	sd	s4,48(sp)
    80003ad8:	f456                	sd	s5,40(sp)
    80003ada:	f05a                	sd	s6,32(sp)
    80003adc:	ec5e                	sd	s7,24(sp)
    80003ade:	e862                	sd	s8,16(sp)
    80003ae0:	e466                	sd	s9,8(sp)
    80003ae2:	e06a                	sd	s10,0(sp)
    80003ae4:	1080                	addi	s0,sp,96
    80003ae6:	84aa                	mv	s1,a0
    80003ae8:	8b2e                	mv	s6,a1
    80003aea:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003aec:	00054703          	lbu	a4,0(a0)
    80003af0:	02f00793          	li	a5,47
    80003af4:	00f70f63          	beq	a4,a5,80003b12 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003af8:	802fe0ef          	jal	80001afa <myproc>
    80003afc:	15053503          	ld	a0,336(a0)
    80003b00:	901ff0ef          	jal	80003400 <idup>
    80003b04:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003b06:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003b0a:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003b0c:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003b0e:	4b85                	li	s7,1
    80003b10:	a07d                	j	80003bbe <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003b12:	4585                	li	a1,1
    80003b14:	852e                	mv	a0,a1
    80003b16:	eaeff0ef          	jal	800031c4 <iget>
    80003b1a:	8a2a                	mv	s4,a0
    80003b1c:	b7ed                	j	80003b06 <namex+0x3c>
      iunlockput(ip);
    80003b1e:	8552                	mv	a0,s4
    80003b20:	b6bff0ef          	jal	8000368a <iunlockput>
      return 0;
    80003b24:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003b26:	8552                	mv	a0,s4
    80003b28:	60e6                	ld	ra,88(sp)
    80003b2a:	6446                	ld	s0,80(sp)
    80003b2c:	64a6                	ld	s1,72(sp)
    80003b2e:	6906                	ld	s2,64(sp)
    80003b30:	79e2                	ld	s3,56(sp)
    80003b32:	7a42                	ld	s4,48(sp)
    80003b34:	7aa2                	ld	s5,40(sp)
    80003b36:	7b02                	ld	s6,32(sp)
    80003b38:	6be2                	ld	s7,24(sp)
    80003b3a:	6c42                	ld	s8,16(sp)
    80003b3c:	6ca2                	ld	s9,8(sp)
    80003b3e:	6d02                	ld	s10,0(sp)
    80003b40:	6125                	addi	sp,sp,96
    80003b42:	8082                	ret
      iunlockput(ip);
    80003b44:	8552                	mv	a0,s4
    80003b46:	b45ff0ef          	jal	8000368a <iunlockput>
      return 0;
    80003b4a:	4a01                	li	s4,0
    80003b4c:	bfe9                	j	80003b26 <namex+0x5c>
      iunlock(ip);
    80003b4e:	8552                	mv	a0,s4
    80003b50:	995ff0ef          	jal	800034e4 <iunlock>
      return ip;
    80003b54:	bfc9                	j	80003b26 <namex+0x5c>
      iunlockput(ip);
    80003b56:	8552                	mv	a0,s4
    80003b58:	b33ff0ef          	jal	8000368a <iunlockput>
      return 0;
    80003b5c:	8a4a                	mv	s4,s2
    80003b5e:	b7e1                	j	80003b26 <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003b60:	8926                	mv	s2,s1
  len = path - s;
    80003b62:	4d01                	li	s10,0
    80003b64:	4601                	li	a2,0
    memmove(name, s, len);
    80003b66:	2601                	sext.w	a2,a2
    80003b68:	85a6                	mv	a1,s1
    80003b6a:	8556                	mv	a0,s5
    80003b6c:	9dcfd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003b70:	9d56                	add	s10,s10,s5
    80003b72:	000d0023          	sb	zero,0(s10)
  while (*path == '/')
    80003b76:	00094783          	lbu	a5,0(s2)
    80003b7a:	09379b63          	bne	a5,s3,80003c10 <namex+0x146>
    80003b7e:	84ca                	mv	s1,s2
    path++;
    80003b80:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b82:	0004c783          	lbu	a5,0(s1)
    80003b86:	ff378de3          	beq	a5,s3,80003b80 <namex+0xb6>
    ilock(ip);
    80003b8a:	8552                	mv	a0,s4
    80003b8c:	8abff0ef          	jal	80003436 <ilock>
    if (ip->type != T_DIR) {
    80003b90:	044a1783          	lh	a5,68(s4)
    80003b94:	f97795e3          	bne	a5,s7,80003b1e <namex+0x54>
    if (ip->nlink == 0) {
    80003b98:	04aa1783          	lh	a5,74(s4)
    80003b9c:	d7c5                	beqz	a5,80003b44 <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003b9e:	000b0563          	beqz	s6,80003ba8 <namex+0xde>
    80003ba2:	0004c783          	lbu	a5,0(s1)
    80003ba6:	d7c5                	beqz	a5,80003b4e <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003ba8:	4601                	li	a2,0
    80003baa:	85d6                	mv	a1,s5
    80003bac:	8552                	mv	a0,s4
    80003bae:	e71ff0ef          	jal	80003a1e <dirlookup>
    80003bb2:	892a                	mv	s2,a0
    80003bb4:	d14d                	beqz	a0,80003b56 <namex+0x8c>
    iunlockput(ip);
    80003bb6:	8552                	mv	a0,s4
    80003bb8:	ad3ff0ef          	jal	8000368a <iunlockput>
    ip = next;
    80003bbc:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003bbe:	0004c783          	lbu	a5,0(s1)
    80003bc2:	01379763          	bne	a5,s3,80003bd0 <namex+0x106>
    path++;
    80003bc6:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003bc8:	0004c783          	lbu	a5,0(s1)
    80003bcc:	ff378de3          	beq	a5,s3,80003bc6 <namex+0xfc>
  if (*path == 0)
    80003bd0:	c7a1                	beqz	a5,80003c18 <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003bd2:	0004c783          	lbu	a5,0(s1)
    80003bd6:	fd178713          	addi	a4,a5,-47
    80003bda:	d359                	beqz	a4,80003b60 <namex+0x96>
    80003bdc:	d3d1                	beqz	a5,80003b60 <namex+0x96>
    80003bde:	8926                	mv	s2,s1
    path++;
    80003be0:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003be2:	00094783          	lbu	a5,0(s2)
    80003be6:	fd178713          	addi	a4,a5,-47
    80003bea:	c311                	beqz	a4,80003bee <namex+0x124>
    80003bec:	fbf5                	bnez	a5,80003be0 <namex+0x116>
  len = path - s;
    80003bee:	40990633          	sub	a2,s2,s1
    80003bf2:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003bf6:	f7ac58e3          	bge	s8,s10,80003b66 <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003bfa:	8666                	mv	a2,s9
    80003bfc:	85a6                	mv	a1,s1
    80003bfe:	8556                	mv	a0,s5
    80003c00:	948fd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003c04:	00094783          	lbu	a5,0(s2)
    80003c08:	84ca                	mv	s1,s2
    80003c0a:	f7378be3          	beq	a5,s3,80003b80 <namex+0xb6>
    80003c0e:	bfb5                	j	80003b8a <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003c10:	00090463          	beqz	s2,80003c18 <namex+0x14e>
    80003c14:	84ca                	mv	s1,s2
    80003c16:	bf95                	j	80003b8a <namex+0xc0>
  if (nameiparent) {
    80003c18:	f00b07e3          	beqz	s6,80003b26 <namex+0x5c>
    iput(ip);
    80003c1c:	8552                	mv	a0,s4
    80003c1e:	99bff0ef          	jal	800035b8 <iput>
    return 0;
    80003c22:	4a01                	li	s4,0
    80003c24:	b709                	j	80003b26 <namex+0x5c>

0000000080003c26 <dirlink>:
{
    80003c26:	715d                	addi	sp,sp,-80
    80003c28:	e486                	sd	ra,72(sp)
    80003c2a:	e0a2                	sd	s0,64(sp)
    80003c2c:	f84a                	sd	s2,48(sp)
    80003c2e:	ec56                	sd	s5,24(sp)
    80003c30:	e85a                	sd	s6,16(sp)
    80003c32:	0880                	addi	s0,sp,80
    80003c34:	892a                	mv	s2,a0
    80003c36:	8aae                	mv	s5,a1
    80003c38:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003c3a:	4601                	li	a2,0
    80003c3c:	de3ff0ef          	jal	80003a1e <dirlookup>
    80003c40:	ed1d                	bnez	a0,80003c7e <dirlink+0x58>
    80003c42:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003c44:	04c92483          	lw	s1,76(s2)
    80003c48:	c4b9                	beqz	s1,80003c96 <dirlink+0x70>
    80003c4a:	f44e                	sd	s3,40(sp)
    80003c4c:	f052                	sd	s4,32(sp)
    80003c4e:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c50:	fb040a13          	addi	s4,s0,-80
    80003c54:	49c1                	li	s3,16
    80003c56:	874e                	mv	a4,s3
    80003c58:	86a6                	mv	a3,s1
    80003c5a:	8652                	mv	a2,s4
    80003c5c:	4581                	li	a1,0
    80003c5e:	854a                	mv	a0,s2
    80003c60:	bb1ff0ef          	jal	80003810 <readi>
    80003c64:	03351163          	bne	a0,s3,80003c86 <dirlink+0x60>
    if (de.inum == 0)
    80003c68:	fb045783          	lhu	a5,-80(s0)
    80003c6c:	c39d                	beqz	a5,80003c92 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003c6e:	24c1                	addiw	s1,s1,16
    80003c70:	04c92783          	lw	a5,76(s2)
    80003c74:	fef4e1e3          	bltu	s1,a5,80003c56 <dirlink+0x30>
    80003c78:	79a2                	ld	s3,40(sp)
    80003c7a:	7a02                	ld	s4,32(sp)
    80003c7c:	a829                	j	80003c96 <dirlink+0x70>
    iput(ip);
    80003c7e:	93bff0ef          	jal	800035b8 <iput>
    return -1;
    80003c82:	557d                	li	a0,-1
    80003c84:	a83d                	j	80003cc2 <dirlink+0x9c>
      panic("dirlink read");
    80003c86:	00004517          	auipc	a0,0x4
    80003c8a:	9e250513          	addi	a0,a0,-1566 # 80007668 <etext+0x668>
    80003c8e:	ba7fc0ef          	jal	80000834 <panic>
    80003c92:	79a2                	ld	s3,40(sp)
    80003c94:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003c96:	4639                	li	a2,14
    80003c98:	85d6                	mv	a1,s5
    80003c9a:	fb240513          	addi	a0,s0,-78
    80003c9e:	958fd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003ca2:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ca6:	4741                	li	a4,16
    80003ca8:	86a6                	mv	a3,s1
    80003caa:	fb040613          	addi	a2,s0,-80
    80003cae:	4581                	li	a1,0
    80003cb0:	854a                	mv	a0,s2
    80003cb2:	c51ff0ef          	jal	80003902 <writei>
    80003cb6:	1541                	addi	a0,a0,-16
    80003cb8:	00a03533          	snez	a0,a0
    80003cbc:	40a0053b          	negw	a0,a0
    80003cc0:	74e2                	ld	s1,56(sp)
}
    80003cc2:	60a6                	ld	ra,72(sp)
    80003cc4:	6406                	ld	s0,64(sp)
    80003cc6:	7942                	ld	s2,48(sp)
    80003cc8:	6ae2                	ld	s5,24(sp)
    80003cca:	6b42                	ld	s6,16(sp)
    80003ccc:	6161                	addi	sp,sp,80
    80003cce:	8082                	ret

0000000080003cd0 <namei>:

struct inode *
namei(char *path)
{
    80003cd0:	1101                	addi	sp,sp,-32
    80003cd2:	ec06                	sd	ra,24(sp)
    80003cd4:	e822                	sd	s0,16(sp)
    80003cd6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003cd8:	fe040613          	addi	a2,s0,-32
    80003cdc:	4581                	li	a1,0
    80003cde:	dedff0ef          	jal	80003aca <namex>
}
    80003ce2:	60e2                	ld	ra,24(sp)
    80003ce4:	6442                	ld	s0,16(sp)
    80003ce6:	6105                	addi	sp,sp,32
    80003ce8:	8082                	ret

0000000080003cea <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003cea:	1141                	addi	sp,sp,-16
    80003cec:	e406                	sd	ra,8(sp)
    80003cee:	e022                	sd	s0,0(sp)
    80003cf0:	0800                	addi	s0,sp,16
    80003cf2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003cf4:	4585                	li	a1,1
    80003cf6:	dd5ff0ef          	jal	80003aca <namex>
}
    80003cfa:	60a2                	ld	ra,8(sp)
    80003cfc:	6402                	ld	s0,0(sp)
    80003cfe:	0141                	addi	sp,sp,16
    80003d00:	8082                	ret

0000000080003d02 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003d02:	1101                	addi	sp,sp,-32
    80003d04:	ec06                	sd	ra,24(sp)
    80003d06:	e822                	sd	s0,16(sp)
    80003d08:	e426                	sd	s1,8(sp)
    80003d0a:	e04a                	sd	s2,0(sp)
    80003d0c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003d0e:	0001f917          	auipc	s2,0x1f
    80003d12:	8ba90913          	addi	s2,s2,-1862 # 800225c8 <log>
    80003d16:	01892583          	lw	a1,24(s2)
    80003d1a:	02492503          	lw	a0,36(s2)
    80003d1e:	880ff0ef          	jal	80002d9e <bread>
    80003d22:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003d24:	02c92603          	lw	a2,44(s2)
    80003d28:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003d2a:	00c05f63          	blez	a2,80003d48 <write_head+0x46>
    80003d2e:	0001f717          	auipc	a4,0x1f
    80003d32:	8ca70713          	addi	a4,a4,-1846 # 800225f8 <log+0x30>
    80003d36:	87aa                	mv	a5,a0
    80003d38:	060a                	slli	a2,a2,0x2
    80003d3a:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003d3c:	4314                	lw	a3,0(a4)
    80003d3e:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003d40:	0711                	addi	a4,a4,4
    80003d42:	0791                	addi	a5,a5,4
    80003d44:	fec79ce3          	bne	a5,a2,80003d3c <write_head+0x3a>
  }
  bwrite(buf);
    80003d48:	8526                	mv	a0,s1
    80003d4a:	92aff0ef          	jal	80002e74 <bwrite>
  brelse(buf);
    80003d4e:	8526                	mv	a0,s1
    80003d50:	956ff0ef          	jal	80002ea6 <brelse>
}
    80003d54:	60e2                	ld	ra,24(sp)
    80003d56:	6442                	ld	s0,16(sp)
    80003d58:	64a2                	ld	s1,8(sp)
    80003d5a:	6902                	ld	s2,0(sp)
    80003d5c:	6105                	addi	sp,sp,32
    80003d5e:	8082                	ret

0000000080003d60 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d60:	0001f797          	auipc	a5,0x1f
    80003d64:	8947a783          	lw	a5,-1900(a5) # 800225f4 <log+0x2c>
    80003d68:	0cf05163          	blez	a5,80003e2a <install_trans+0xca>
{
    80003d6c:	715d                	addi	sp,sp,-80
    80003d6e:	e486                	sd	ra,72(sp)
    80003d70:	e0a2                	sd	s0,64(sp)
    80003d72:	fc26                	sd	s1,56(sp)
    80003d74:	f84a                	sd	s2,48(sp)
    80003d76:	f44e                	sd	s3,40(sp)
    80003d78:	f052                	sd	s4,32(sp)
    80003d7a:	ec56                	sd	s5,24(sp)
    80003d7c:	e85a                	sd	s6,16(sp)
    80003d7e:	e45e                	sd	s7,8(sp)
    80003d80:	e062                	sd	s8,0(sp)
    80003d82:	0880                	addi	s0,sp,80
    80003d84:	8b2a                	mv	s6,a0
    80003d86:	0001fa97          	auipc	s5,0x1f
    80003d8a:	872a8a93          	addi	s5,s5,-1934 # 800225f8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d8e:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d90:	00004c17          	auipc	s8,0x4
    80003d94:	8e8c0c13          	addi	s8,s8,-1816 # 80007678 <etext+0x678>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003d98:	0001fa17          	auipc	s4,0x1f
    80003d9c:	830a0a13          	addi	s4,s4,-2000 # 800225c8 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003da0:	40000b93          	li	s7,1024
    80003da4:	a025                	j	80003dcc <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003da6:	000aa603          	lw	a2,0(s5)
    80003daa:	85ce                	mv	a1,s3
    80003dac:	8562                	mv	a0,s8
    80003dae:	f5cfc0ef          	jal	8000050a <printk>
    80003db2:	a839                	j	80003dd0 <install_trans+0x70>
    brelse(lbuf);
    80003db4:	854a                	mv	a0,s2
    80003db6:	8f0ff0ef          	jal	80002ea6 <brelse>
    brelse(dbuf);
    80003dba:	8526                	mv	a0,s1
    80003dbc:	8eaff0ef          	jal	80002ea6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dc0:	2985                	addiw	s3,s3,1
    80003dc2:	0a91                	addi	s5,s5,4
    80003dc4:	02ca2783          	lw	a5,44(s4)
    80003dc8:	04f9d563          	bge	s3,a5,80003e12 <install_trans+0xb2>
    if (recovering) {
    80003dcc:	fc0b1de3          	bnez	s6,80003da6 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003dd0:	018a2583          	lw	a1,24(s4)
    80003dd4:	013585bb          	addw	a1,a1,s3
    80003dd8:	2585                	addiw	a1,a1,1
    80003dda:	024a2503          	lw	a0,36(s4)
    80003dde:	fc1fe0ef          	jal	80002d9e <bread>
    80003de2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003de4:	000aa583          	lw	a1,0(s5)
    80003de8:	024a2503          	lw	a0,36(s4)
    80003dec:	fb3fe0ef          	jal	80002d9e <bread>
    80003df0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003df2:	865e                	mv	a2,s7
    80003df4:	05890593          	addi	a1,s2,88
    80003df8:	05850513          	addi	a0,a0,88
    80003dfc:	f4dfc0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003e00:	8526                	mv	a0,s1
    80003e02:	872ff0ef          	jal	80002e74 <bwrite>
    if (recovering == 0)
    80003e06:	fa0b17e3          	bnez	s6,80003db4 <install_trans+0x54>
      bunpin(dbuf);
    80003e0a:	8526                	mv	a0,s1
    80003e0c:	952ff0ef          	jal	80002f5e <bunpin>
    80003e10:	b755                	j	80003db4 <install_trans+0x54>
}
    80003e12:	60a6                	ld	ra,72(sp)
    80003e14:	6406                	ld	s0,64(sp)
    80003e16:	74e2                	ld	s1,56(sp)
    80003e18:	7942                	ld	s2,48(sp)
    80003e1a:	79a2                	ld	s3,40(sp)
    80003e1c:	7a02                	ld	s4,32(sp)
    80003e1e:	6ae2                	ld	s5,24(sp)
    80003e20:	6b42                	ld	s6,16(sp)
    80003e22:	6ba2                	ld	s7,8(sp)
    80003e24:	6c02                	ld	s8,0(sp)
    80003e26:	6161                	addi	sp,sp,80
    80003e28:	8082                	ret
    80003e2a:	8082                	ret

0000000080003e2c <initlog>:
{
    80003e2c:	7179                	addi	sp,sp,-48
    80003e2e:	f406                	sd	ra,40(sp)
    80003e30:	f022                	sd	s0,32(sp)
    80003e32:	ec26                	sd	s1,24(sp)
    80003e34:	e84a                	sd	s2,16(sp)
    80003e36:	e44e                	sd	s3,8(sp)
    80003e38:	1800                	addi	s0,sp,48
    80003e3a:	84aa                	mv	s1,a0
    80003e3c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003e3e:	0001e917          	auipc	s2,0x1e
    80003e42:	78a90913          	addi	s2,s2,1930 # 800225c8 <log>
    80003e46:	00004597          	auipc	a1,0x4
    80003e4a:	85258593          	addi	a1,a1,-1966 # 80007698 <etext+0x698>
    80003e4e:	854a                	mv	a0,s2
    80003e50:	d59fc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003e54:	0149a583          	lw	a1,20(s3)
    80003e58:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003e5c:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003e60:	8526                	mv	a0,s1
    80003e62:	f3dfe0ef          	jal	80002d9e <bread>
  log.lh.n = lh->n;
    80003e66:	4d30                	lw	a2,88(a0)
    80003e68:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003e6c:	00c05f63          	blez	a2,80003e8a <initlog+0x5e>
    80003e70:	87aa                	mv	a5,a0
    80003e72:	0001e717          	auipc	a4,0x1e
    80003e76:	78670713          	addi	a4,a4,1926 # 800225f8 <log+0x30>
    80003e7a:	060a                	slli	a2,a2,0x2
    80003e7c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e7e:	4ff4                	lw	a3,92(a5)
    80003e80:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e82:	0791                	addi	a5,a5,4
    80003e84:	0711                	addi	a4,a4,4
    80003e86:	fec79ce3          	bne	a5,a2,80003e7e <initlog+0x52>
  brelse(buf);
    80003e8a:	81cff0ef          	jal	80002ea6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e8e:	4505                	li	a0,1
    80003e90:	ed1ff0ef          	jal	80003d60 <install_trans>
  log.lh.n = 0;
    80003e94:	0001e797          	auipc	a5,0x1e
    80003e98:	7607a023          	sw	zero,1888(a5) # 800225f4 <log+0x2c>
  write_head(); // clear the log
    80003e9c:	e67ff0ef          	jal	80003d02 <write_head>
}
    80003ea0:	70a2                	ld	ra,40(sp)
    80003ea2:	7402                	ld	s0,32(sp)
    80003ea4:	64e2                	ld	s1,24(sp)
    80003ea6:	6942                	ld	s2,16(sp)
    80003ea8:	69a2                	ld	s3,8(sp)
    80003eaa:	6145                	addi	sp,sp,48
    80003eac:	8082                	ret

0000000080003eae <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003eae:	1101                	addi	sp,sp,-32
    80003eb0:	ec06                	sd	ra,24(sp)
    80003eb2:	e822                	sd	s0,16(sp)
    80003eb4:	e426                	sd	s1,8(sp)
    80003eb6:	e04a                	sd	s2,0(sp)
    80003eb8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003eba:	0001e517          	auipc	a0,0x1e
    80003ebe:	70e50513          	addi	a0,a0,1806 # 800225c8 <log>
    80003ec2:	d67fc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80003ec6:	0001e497          	auipc	s1,0x1e
    80003eca:	70248493          	addi	s1,s1,1794 # 800225c8 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003ece:	4979                	li	s2,30
    80003ed0:	a821                	j	80003ee8 <begin_op+0x3a>
      sleep_prepare(&log);
    80003ed2:	8526                	mv	a0,s1
    80003ed4:	a30fe0ef          	jal	80002104 <sleep_prepare>
      release(&log.lock);
    80003ed8:	8526                	mv	a0,s1
    80003eda:	dd7fc0ef          	jal	80000cb0 <release>
      sleep();
    80003ede:	a62fe0ef          	jal	80002140 <sleep>
      acquire(&log.lock);
    80003ee2:	8526                	mv	a0,s1
    80003ee4:	d45fc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80003ee8:	509c                	lw	a5,32(s1)
    80003eea:	f7e5                	bnez	a5,80003ed2 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003eec:	4cd8                	lw	a4,28(s1)
    80003eee:	2705                	addiw	a4,a4,1
    80003ef0:	0027179b          	slliw	a5,a4,0x2
    80003ef4:	9fb9                	addw	a5,a5,a4
    80003ef6:	0017979b          	slliw	a5,a5,0x1
    80003efa:	54d4                	lw	a3,44(s1)
    80003efc:	9fb5                	addw	a5,a5,a3
    80003efe:	00f95e63          	bge	s2,a5,80003f1a <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003f02:	8526                	mv	a0,s1
    80003f04:	a00fe0ef          	jal	80002104 <sleep_prepare>
      release(&log.lock);
    80003f08:	8526                	mv	a0,s1
    80003f0a:	da7fc0ef          	jal	80000cb0 <release>
      sleep();
    80003f0e:	a32fe0ef          	jal	80002140 <sleep>
      acquire(&log.lock);
    80003f12:	8526                	mv	a0,s1
    80003f14:	d15fc0ef          	jal	80000c28 <acquire>
    80003f18:	bfc1                	j	80003ee8 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003f1a:	0001e797          	auipc	a5,0x1e
    80003f1e:	6ce7a523          	sw	a4,1738(a5) # 800225e4 <log+0x1c>
      release(&log.lock);
    80003f22:	0001e517          	auipc	a0,0x1e
    80003f26:	6a650513          	addi	a0,a0,1702 # 800225c8 <log>
    80003f2a:	d87fc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80003f2e:	60e2                	ld	ra,24(sp)
    80003f30:	6442                	ld	s0,16(sp)
    80003f32:	64a2                	ld	s1,8(sp)
    80003f34:	6902                	ld	s2,0(sp)
    80003f36:	6105                	addi	sp,sp,32
    80003f38:	8082                	ret

0000000080003f3a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003f3a:	7139                	addi	sp,sp,-64
    80003f3c:	fc06                	sd	ra,56(sp)
    80003f3e:	f822                	sd	s0,48(sp)
    80003f40:	f426                	sd	s1,40(sp)
    80003f42:	f04a                	sd	s2,32(sp)
    80003f44:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003f46:	0001e497          	auipc	s1,0x1e
    80003f4a:	68248493          	addi	s1,s1,1666 # 800225c8 <log>
    80003f4e:	8526                	mv	a0,s1
    80003f50:	cd9fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003f54:	4cdc                	lw	a5,28(s1)
    80003f56:	37fd                	addiw	a5,a5,-1
    80003f58:	893e                	mv	s2,a5
    80003f5a:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003f5c:	509c                	lw	a5,32(s1)
    80003f5e:	e3b1                	bnez	a5,80003fa2 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003f60:	04091a63          	bnez	s2,80003fb4 <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003f64:	0001e497          	auipc	s1,0x1e
    80003f68:	66448493          	addi	s1,s1,1636 # 800225c8 <log>
    80003f6c:	4785                	li	a5,1
    80003f6e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f70:	8526                	mv	a0,s1
    80003f72:	d3ffc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f76:	54dc                	lw	a5,44(s1)
    80003f78:	06f04063          	bgtz	a5,80003fd8 <end_op+0x9e>
    acquire(&log.lock);
    80003f7c:	0001e497          	auipc	s1,0x1e
    80003f80:	64c48493          	addi	s1,s1,1612 # 800225c8 <log>
    80003f84:	8526                	mv	a0,s1
    80003f86:	ca3fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003f8a:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003f8e:	549c                	lw	a5,40(s1)
    80003f90:	2785                	addiw	a5,a5,1
    80003f92:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003f94:	8526                	mv	a0,s1
    80003f96:	9dafe0ef          	jal	80002170 <wakeup>
    release(&log.lock);
    80003f9a:	8526                	mv	a0,s1
    80003f9c:	d15fc0ef          	jal	80000cb0 <release>
}
    80003fa0:	a035                	j	80003fcc <end_op+0x92>
    80003fa2:	ec4e                	sd	s3,24(sp)
    80003fa4:	e852                	sd	s4,16(sp)
    80003fa6:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003fa8:	00003517          	auipc	a0,0x3
    80003fac:	6f850513          	addi	a0,a0,1784 # 800076a0 <etext+0x6a0>
    80003fb0:	885fc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003fb4:	0001e517          	auipc	a0,0x1e
    80003fb8:	61450513          	addi	a0,a0,1556 # 800225c8 <log>
    80003fbc:	9b4fe0ef          	jal	80002170 <wakeup>
  release(&log.lock);
    80003fc0:	0001e517          	auipc	a0,0x1e
    80003fc4:	60850513          	addi	a0,a0,1544 # 800225c8 <log>
    80003fc8:	ce9fc0ef          	jal	80000cb0 <release>
}
    80003fcc:	70e2                	ld	ra,56(sp)
    80003fce:	7442                	ld	s0,48(sp)
    80003fd0:	74a2                	ld	s1,40(sp)
    80003fd2:	7902                	ld	s2,32(sp)
    80003fd4:	6121                	addi	sp,sp,64
    80003fd6:	8082                	ret
    80003fd8:	ec4e                	sd	s3,24(sp)
    80003fda:	e852                	sd	s4,16(sp)
    80003fdc:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fde:	0001ea97          	auipc	s5,0x1e
    80003fe2:	61aa8a93          	addi	s5,s5,1562 # 800225f8 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003fe6:	0001ea17          	auipc	s4,0x1e
    80003fea:	5e2a0a13          	addi	s4,s4,1506 # 800225c8 <log>
    80003fee:	018a2583          	lw	a1,24(s4)
    80003ff2:	012585bb          	addw	a1,a1,s2
    80003ff6:	2585                	addiw	a1,a1,1
    80003ff8:	024a2503          	lw	a0,36(s4)
    80003ffc:	da3fe0ef          	jal	80002d9e <bread>
    80004000:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004002:	000aa583          	lw	a1,0(s5)
    80004006:	024a2503          	lw	a0,36(s4)
    8000400a:	d95fe0ef          	jal	80002d9e <bread>
    8000400e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004010:	40000613          	li	a2,1024
    80004014:	05850593          	addi	a1,a0,88
    80004018:	05848513          	addi	a0,s1,88
    8000401c:	d2dfc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    80004020:	8526                	mv	a0,s1
    80004022:	e53fe0ef          	jal	80002e74 <bwrite>
    brelse(from);
    80004026:	854e                	mv	a0,s3
    80004028:	e7ffe0ef          	jal	80002ea6 <brelse>
    brelse(to);
    8000402c:	8526                	mv	a0,s1
    8000402e:	e79fe0ef          	jal	80002ea6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004032:	2905                	addiw	s2,s2,1
    80004034:	0a91                	addi	s5,s5,4
    80004036:	02ca2783          	lw	a5,44(s4)
    8000403a:	faf94ae3          	blt	s2,a5,80003fee <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    8000403e:	cc5ff0ef          	jal	80003d02 <write_head>
    install_trans(0); // Now install writes to home locations
    80004042:	4501                	li	a0,0
    80004044:	d1dff0ef          	jal	80003d60 <install_trans>
    log.lh.n = 0;
    80004048:	0001e797          	auipc	a5,0x1e
    8000404c:	5a07a623          	sw	zero,1452(a5) # 800225f4 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80004050:	cb3ff0ef          	jal	80003d02 <write_head>
    80004054:	69e2                	ld	s3,24(sp)
    80004056:	6a42                	ld	s4,16(sp)
    80004058:	6aa2                	ld	s5,8(sp)
    8000405a:	b70d                	j	80003f7c <end_op+0x42>

000000008000405c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000405c:	1101                	addi	sp,sp,-32
    8000405e:	ec06                	sd	ra,24(sp)
    80004060:	e822                	sd	s0,16(sp)
    80004062:	e426                	sd	s1,8(sp)
    80004064:	1000                	addi	s0,sp,32
    80004066:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004068:	0001e517          	auipc	a0,0x1e
    8000406c:	56050513          	addi	a0,a0,1376 # 800225c8 <log>
    80004070:	bb9fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004074:	0001e617          	auipc	a2,0x1e
    80004078:	58062603          	lw	a2,1408(a2) # 800225f4 <log+0x2c>
    8000407c:	47f5                	li	a5,29
    8000407e:	04c7cd63          	blt	a5,a2,800040d8 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004082:	0001e797          	auipc	a5,0x1e
    80004086:	5627a783          	lw	a5,1378(a5) # 800225e4 <log+0x1c>
    8000408a:	04f05d63          	blez	a5,800040e4 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000408e:	4781                	li	a5,0
    80004090:	06c05063          	blez	a2,800040f0 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80004094:	44cc                	lw	a1,12(s1)
    80004096:	0001e717          	auipc	a4,0x1e
    8000409a:	56270713          	addi	a4,a4,1378 # 800225f8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000409e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    800040a0:	4314                	lw	a3,0(a4)
    800040a2:	04b68763          	beq	a3,a1,800040f0 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    800040a6:	2785                	addiw	a5,a5,1
    800040a8:	0711                	addi	a4,a4,4
    800040aa:	fef61be3          	bne	a2,a5,800040a0 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800040ae:	060a                	slli	a2,a2,0x2
    800040b0:	02060613          	addi	a2,a2,32
    800040b4:	0001e797          	auipc	a5,0x1e
    800040b8:	51478793          	addi	a5,a5,1300 # 800225c8 <log>
    800040bc:	97b2                	add	a5,a5,a2
    800040be:	44d8                	lw	a4,12(s1)
    800040c0:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    800040c2:	8526                	mv	a0,s1
    800040c4:	e67fe0ef          	jal	80002f2a <bpin>
    log.lh.n++;
    800040c8:	0001e717          	auipc	a4,0x1e
    800040cc:	50070713          	addi	a4,a4,1280 # 800225c8 <log>
    800040d0:	575c                	lw	a5,44(a4)
    800040d2:	2785                	addiw	a5,a5,1
    800040d4:	d75c                	sw	a5,44(a4)
    800040d6:	a815                	j	8000410a <log_write+0xae>
    panic("too big a transaction");
    800040d8:	00003517          	auipc	a0,0x3
    800040dc:	5d850513          	addi	a0,a0,1496 # 800076b0 <etext+0x6b0>
    800040e0:	f54fc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    800040e4:	00003517          	auipc	a0,0x3
    800040e8:	5e450513          	addi	a0,a0,1508 # 800076c8 <etext+0x6c8>
    800040ec:	f48fc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    800040f0:	00279693          	slli	a3,a5,0x2
    800040f4:	02068693          	addi	a3,a3,32
    800040f8:	0001e717          	auipc	a4,0x1e
    800040fc:	4d070713          	addi	a4,a4,1232 # 800225c8 <log>
    80004100:	9736                	add	a4,a4,a3
    80004102:	44d4                	lw	a3,12(s1)
    80004104:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80004106:	faf60ee3          	beq	a2,a5,800040c2 <log_write+0x66>
  }
  release(&log.lock);
    8000410a:	0001e517          	auipc	a0,0x1e
    8000410e:	4be50513          	addi	a0,a0,1214 # 800225c8 <log>
    80004112:	b9ffc0ef          	jal	80000cb0 <release>
}
    80004116:	60e2                	ld	ra,24(sp)
    80004118:	6442                	ld	s0,16(sp)
    8000411a:	64a2                	ld	s1,8(sp)
    8000411c:	6105                	addi	sp,sp,32
    8000411e:	8082                	ret

0000000080004120 <sys_sync>:

uint64
sys_sync(void)
{
    80004120:	1101                	addi	sp,sp,-32
    80004122:	ec06                	sd	ra,24(sp)
    80004124:	e822                	sd	s0,16(sp)
    80004126:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004128:	0001e517          	auipc	a0,0x1e
    8000412c:	4a050513          	addi	a0,a0,1184 # 800225c8 <log>
    80004130:	af9fc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    80004134:	0001e797          	auipc	a5,0x1e
    80004138:	4b47a783          	lw	a5,1204(a5) # 800225e8 <log+0x20>
    8000413c:	e799                	bnez	a5,8000414a <sys_sync+0x2a>
    8000413e:	0001e797          	auipc	a5,0x1e
    80004142:	4a67a783          	lw	a5,1190(a5) # 800225e4 <log+0x1c>
    80004146:	02f05c63          	blez	a5,8000417e <sys_sync+0x5e>
    8000414a:	e426                	sd	s1,8(sp)
    8000414c:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    8000414e:	0001e917          	auipc	s2,0x1e
    80004152:	4a292903          	lw	s2,1186(s2) # 800225f0 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80004156:	0001e497          	auipc	s1,0x1e
    8000415a:	47248493          	addi	s1,s1,1138 # 800225c8 <log>
    8000415e:	8526                	mv	a0,s1
    80004160:	fa5fd0ef          	jal	80002104 <sleep_prepare>
      release(&log.lock);
    80004164:	8526                	mv	a0,s1
    80004166:	b4bfc0ef          	jal	80000cb0 <release>
      sleep();
    8000416a:	fd7fd0ef          	jal	80002140 <sleep>
      acquire(&log.lock);
    8000416e:	8526                	mv	a0,s1
    80004170:	ab9fc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    80004174:	549c                	lw	a5,40(s1)
    80004176:	fef954e3          	bge	s2,a5,8000415e <sys_sync+0x3e>
    8000417a:	64a2                	ld	s1,8(sp)
    8000417c:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    8000417e:	0001e517          	auipc	a0,0x1e
    80004182:	44a50513          	addi	a0,a0,1098 # 800225c8 <log>
    80004186:	b2bfc0ef          	jal	80000cb0 <release>
  return 0;
}
    8000418a:	4501                	li	a0,0
    8000418c:	60e2                	ld	ra,24(sp)
    8000418e:	6442                	ld	s0,16(sp)
    80004190:	6105                	addi	sp,sp,32
    80004192:	8082                	ret

0000000080004194 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004194:	1101                	addi	sp,sp,-32
    80004196:	ec06                	sd	ra,24(sp)
    80004198:	e822                	sd	s0,16(sp)
    8000419a:	e426                	sd	s1,8(sp)
    8000419c:	e04a                	sd	s2,0(sp)
    8000419e:	1000                	addi	s0,sp,32
    800041a0:	84aa                	mv	s1,a0
    800041a2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800041a4:	00003597          	auipc	a1,0x3
    800041a8:	54458593          	addi	a1,a1,1348 # 800076e8 <etext+0x6e8>
    800041ac:	0521                	addi	a0,a0,8
    800041ae:	9fbfc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    800041b2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800041b6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800041ba:	0204a423          	sw	zero,40(s1)
}
    800041be:	60e2                	ld	ra,24(sp)
    800041c0:	6442                	ld	s0,16(sp)
    800041c2:	64a2                	ld	s1,8(sp)
    800041c4:	6902                	ld	s2,0(sp)
    800041c6:	6105                	addi	sp,sp,32
    800041c8:	8082                	ret

00000000800041ca <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800041ca:	1101                	addi	sp,sp,-32
    800041cc:	ec06                	sd	ra,24(sp)
    800041ce:	e822                	sd	s0,16(sp)
    800041d0:	e426                	sd	s1,8(sp)
    800041d2:	e04a                	sd	s2,0(sp)
    800041d4:	1000                	addi	s0,sp,32
    800041d6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041d8:	00850913          	addi	s2,a0,8
    800041dc:	854a                	mv	a0,s2
    800041de:	a4bfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800041e2:	409c                	lw	a5,0(s1)
    800041e4:	cf91                	beqz	a5,80004200 <acquiresleep+0x36>
    sleep_prepare(lk);
    800041e6:	8526                	mv	a0,s1
    800041e8:	f1dfd0ef          	jal	80002104 <sleep_prepare>
    release(&lk->lk);
    800041ec:	854a                	mv	a0,s2
    800041ee:	ac3fc0ef          	jal	80000cb0 <release>
    sleep();
    800041f2:	f4ffd0ef          	jal	80002140 <sleep>
    acquire(&lk->lk);
    800041f6:	854a                	mv	a0,s2
    800041f8:	a31fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800041fc:	409c                	lw	a5,0(s1)
    800041fe:	f7e5                	bnez	a5,800041e6 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004200:	4785                	li	a5,1
    80004202:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004204:	8f7fd0ef          	jal	80001afa <myproc>
    80004208:	591c                	lw	a5,48(a0)
    8000420a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000420c:	854a                	mv	a0,s2
    8000420e:	aa3fc0ef          	jal	80000cb0 <release>
}
    80004212:	60e2                	ld	ra,24(sp)
    80004214:	6442                	ld	s0,16(sp)
    80004216:	64a2                	ld	s1,8(sp)
    80004218:	6902                	ld	s2,0(sp)
    8000421a:	6105                	addi	sp,sp,32
    8000421c:	8082                	ret

000000008000421e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000421e:	1101                	addi	sp,sp,-32
    80004220:	ec06                	sd	ra,24(sp)
    80004222:	e822                	sd	s0,16(sp)
    80004224:	e426                	sd	s1,8(sp)
    80004226:	e04a                	sd	s2,0(sp)
    80004228:	1000                	addi	s0,sp,32
    8000422a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000422c:	00850913          	addi	s2,a0,8
    80004230:	854a                	mv	a0,s2
    80004232:	9f7fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    80004236:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000423a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000423e:	8526                	mv	a0,s1
    80004240:	f31fd0ef          	jal	80002170 <wakeup>
  release(&lk->lk);
    80004244:	854a                	mv	a0,s2
    80004246:	a6bfc0ef          	jal	80000cb0 <release>
}
    8000424a:	60e2                	ld	ra,24(sp)
    8000424c:	6442                	ld	s0,16(sp)
    8000424e:	64a2                	ld	s1,8(sp)
    80004250:	6902                	ld	s2,0(sp)
    80004252:	6105                	addi	sp,sp,32
    80004254:	8082                	ret

0000000080004256 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004256:	7179                	addi	sp,sp,-48
    80004258:	f406                	sd	ra,40(sp)
    8000425a:	f022                	sd	s0,32(sp)
    8000425c:	ec26                	sd	s1,24(sp)
    8000425e:	e84a                	sd	s2,16(sp)
    80004260:	1800                	addi	s0,sp,48
    80004262:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80004264:	00850913          	addi	s2,a0,8
    80004268:	854a                	mv	a0,s2
    8000426a:	9bffc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000426e:	409c                	lw	a5,0(s1)
    80004270:	ef81                	bnez	a5,80004288 <holdingsleep+0x32>
    80004272:	4481                	li	s1,0
  release(&lk->lk);
    80004274:	854a                	mv	a0,s2
    80004276:	a3bfc0ef          	jal	80000cb0 <release>
  return r;
}
    8000427a:	8526                	mv	a0,s1
    8000427c:	70a2                	ld	ra,40(sp)
    8000427e:	7402                	ld	s0,32(sp)
    80004280:	64e2                	ld	s1,24(sp)
    80004282:	6942                	ld	s2,16(sp)
    80004284:	6145                	addi	sp,sp,48
    80004286:	8082                	ret
    80004288:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000428a:	0284a983          	lw	s3,40(s1)
    8000428e:	86dfd0ef          	jal	80001afa <myproc>
    80004292:	5904                	lw	s1,48(a0)
    80004294:	413484b3          	sub	s1,s1,s3
    80004298:	0014b493          	seqz	s1,s1
    8000429c:	69a2                	ld	s3,8(sp)
    8000429e:	bfd9                	j	80004274 <holdingsleep+0x1e>

00000000800042a0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800042a0:	1141                	addi	sp,sp,-16
    800042a2:	e406                	sd	ra,8(sp)
    800042a4:	e022                	sd	s0,0(sp)
    800042a6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800042a8:	00003597          	auipc	a1,0x3
    800042ac:	45058593          	addi	a1,a1,1104 # 800076f8 <etext+0x6f8>
    800042b0:	0001e517          	auipc	a0,0x1e
    800042b4:	46050513          	addi	a0,a0,1120 # 80022710 <ftable>
    800042b8:	8f1fc0ef          	jal	80000ba8 <initlock>
}
    800042bc:	60a2                	ld	ra,8(sp)
    800042be:	6402                	ld	s0,0(sp)
    800042c0:	0141                	addi	sp,sp,16
    800042c2:	8082                	ret

00000000800042c4 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800042c4:	1101                	addi	sp,sp,-32
    800042c6:	ec06                	sd	ra,24(sp)
    800042c8:	e822                	sd	s0,16(sp)
    800042ca:	e426                	sd	s1,8(sp)
    800042cc:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800042ce:	0001e517          	auipc	a0,0x1e
    800042d2:	44250513          	addi	a0,a0,1090 # 80022710 <ftable>
    800042d6:	953fc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800042da:	0001e497          	auipc	s1,0x1e
    800042de:	44e48493          	addi	s1,s1,1102 # 80022728 <ftable+0x18>
    800042e2:	0001f717          	auipc	a4,0x1f
    800042e6:	3e670713          	addi	a4,a4,998 # 800236c8 <disk>
    if (f->ref == 0) {
    800042ea:	40dc                	lw	a5,4(s1)
    800042ec:	cf89                	beqz	a5,80004306 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800042ee:	02848493          	addi	s1,s1,40
    800042f2:	fee49ce3          	bne	s1,a4,800042ea <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800042f6:	0001e517          	auipc	a0,0x1e
    800042fa:	41a50513          	addi	a0,a0,1050 # 80022710 <ftable>
    800042fe:	9b3fc0ef          	jal	80000cb0 <release>
  return 0;
    80004302:	4481                	li	s1,0
    80004304:	a809                	j	80004316 <filealloc+0x52>
      f->ref = 1;
    80004306:	4785                	li	a5,1
    80004308:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000430a:	0001e517          	auipc	a0,0x1e
    8000430e:	40650513          	addi	a0,a0,1030 # 80022710 <ftable>
    80004312:	99ffc0ef          	jal	80000cb0 <release>
}
    80004316:	8526                	mv	a0,s1
    80004318:	60e2                	ld	ra,24(sp)
    8000431a:	6442                	ld	s0,16(sp)
    8000431c:	64a2                	ld	s1,8(sp)
    8000431e:	6105                	addi	sp,sp,32
    80004320:	8082                	ret

0000000080004322 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004322:	1101                	addi	sp,sp,-32
    80004324:	ec06                	sd	ra,24(sp)
    80004326:	e822                	sd	s0,16(sp)
    80004328:	e426                	sd	s1,8(sp)
    8000432a:	1000                	addi	s0,sp,32
    8000432c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000432e:	0001e517          	auipc	a0,0x1e
    80004332:	3e250513          	addi	a0,a0,994 # 80022710 <ftable>
    80004336:	8f3fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    8000433a:	40dc                	lw	a5,4(s1)
    8000433c:	02f05063          	blez	a5,8000435c <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004340:	2785                	addiw	a5,a5,1
    80004342:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004344:	0001e517          	auipc	a0,0x1e
    80004348:	3cc50513          	addi	a0,a0,972 # 80022710 <ftable>
    8000434c:	965fc0ef          	jal	80000cb0 <release>
  return f;
}
    80004350:	8526                	mv	a0,s1
    80004352:	60e2                	ld	ra,24(sp)
    80004354:	6442                	ld	s0,16(sp)
    80004356:	64a2                	ld	s1,8(sp)
    80004358:	6105                	addi	sp,sp,32
    8000435a:	8082                	ret
    panic("filedup");
    8000435c:	00003517          	auipc	a0,0x3
    80004360:	3a450513          	addi	a0,a0,932 # 80007700 <etext+0x700>
    80004364:	cd0fc0ef          	jal	80000834 <panic>

0000000080004368 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004368:	7139                	addi	sp,sp,-64
    8000436a:	fc06                	sd	ra,56(sp)
    8000436c:	f822                	sd	s0,48(sp)
    8000436e:	f426                	sd	s1,40(sp)
    80004370:	0080                	addi	s0,sp,64
    80004372:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004374:	0001e517          	auipc	a0,0x1e
    80004378:	39c50513          	addi	a0,a0,924 # 80022710 <ftable>
    8000437c:	8adfc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    80004380:	40dc                	lw	a5,4(s1)
    80004382:	04f05a63          	blez	a5,800043d6 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    80004386:	37fd                	addiw	a5,a5,-1
    80004388:	c0dc                	sw	a5,4(s1)
    8000438a:	06f04063          	bgtz	a5,800043ea <fileclose+0x82>
    8000438e:	f04a                	sd	s2,32(sp)
    80004390:	ec4e                	sd	s3,24(sp)
    80004392:	e852                	sd	s4,16(sp)
    80004394:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004396:	0004a903          	lw	s2,0(s1)
    8000439a:	0094c783          	lbu	a5,9(s1)
    8000439e:	89be                	mv	s3,a5
    800043a0:	689c                	ld	a5,16(s1)
    800043a2:	8a3e                	mv	s4,a5
    800043a4:	6c9c                	ld	a5,24(s1)
    800043a6:	8abe                	mv	s5,a5
  f->ref = 0;
    800043a8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800043ac:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800043b0:	0001e517          	auipc	a0,0x1e
    800043b4:	36050513          	addi	a0,a0,864 # 80022710 <ftable>
    800043b8:	8f9fc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    800043bc:	4785                	li	a5,1
    800043be:	04f90163          	beq	s2,a5,80004400 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    800043c2:	ffe9079b          	addiw	a5,s2,-2
    800043c6:	4705                	li	a4,1
    800043c8:	04f77563          	bgeu	a4,a5,80004412 <fileclose+0xaa>
    800043cc:	7902                	ld	s2,32(sp)
    800043ce:	69e2                	ld	s3,24(sp)
    800043d0:	6a42                	ld	s4,16(sp)
    800043d2:	6aa2                	ld	s5,8(sp)
    800043d4:	a00d                	j	800043f6 <fileclose+0x8e>
    800043d6:	f04a                	sd	s2,32(sp)
    800043d8:	ec4e                	sd	s3,24(sp)
    800043da:	e852                	sd	s4,16(sp)
    800043dc:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800043de:	00003517          	auipc	a0,0x3
    800043e2:	32a50513          	addi	a0,a0,810 # 80007708 <etext+0x708>
    800043e6:	c4efc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    800043ea:	0001e517          	auipc	a0,0x1e
    800043ee:	32650513          	addi	a0,a0,806 # 80022710 <ftable>
    800043f2:	8bffc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800043f6:	70e2                	ld	ra,56(sp)
    800043f8:	7442                	ld	s0,48(sp)
    800043fa:	74a2                	ld	s1,40(sp)
    800043fc:	6121                	addi	sp,sp,64
    800043fe:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004400:	85ce                	mv	a1,s3
    80004402:	8552                	mv	a0,s4
    80004404:	36a000ef          	jal	8000476e <pipeclose>
    80004408:	7902                	ld	s2,32(sp)
    8000440a:	69e2                	ld	s3,24(sp)
    8000440c:	6a42                	ld	s4,16(sp)
    8000440e:	6aa2                	ld	s5,8(sp)
    80004410:	b7dd                	j	800043f6 <fileclose+0x8e>
    begin_op();
    80004412:	a9dff0ef          	jal	80003eae <begin_op>
    iput(ff.ip);
    80004416:	8556                	mv	a0,s5
    80004418:	9a0ff0ef          	jal	800035b8 <iput>
    end_op();
    8000441c:	b1fff0ef          	jal	80003f3a <end_op>
    80004420:	7902                	ld	s2,32(sp)
    80004422:	69e2                	ld	s3,24(sp)
    80004424:	6a42                	ld	s4,16(sp)
    80004426:	6aa2                	ld	s5,8(sp)
    80004428:	b7f9                	j	800043f6 <fileclose+0x8e>

000000008000442a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000442a:	715d                	addi	sp,sp,-80
    8000442c:	e486                	sd	ra,72(sp)
    8000442e:	e0a2                	sd	s0,64(sp)
    80004430:	fc26                	sd	s1,56(sp)
    80004432:	f052                	sd	s4,32(sp)
    80004434:	0880                	addi	s0,sp,80
    80004436:	84aa                	mv	s1,a0
    80004438:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000443a:	ec0fd0ef          	jal	80001afa <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    8000443e:	409c                	lw	a5,0(s1)
    80004440:	37f9                	addiw	a5,a5,-2
    80004442:	4705                	li	a4,1
    80004444:	04f76963          	bltu	a4,a5,80004496 <filestat+0x6c>
    80004448:	f84a                	sd	s2,48(sp)
    8000444a:	f44e                	sd	s3,40(sp)
    8000444c:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    8000444e:	fb840993          	addi	s3,s0,-72
    80004452:	4661                	li	a2,24
    80004454:	4581                	li	a1,0
    80004456:	854e                	mv	a0,s3
    80004458:	891fc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    8000445c:	6c88                	ld	a0,24(s1)
    8000445e:	fd9fe0ef          	jal	80003436 <ilock>
    stati(f->ip, &st);
    80004462:	85ce                	mv	a1,s3
    80004464:	6c88                	ld	a0,24(s1)
    80004466:	b7cff0ef          	jal	800037e2 <stati>
    iunlock(f->ip);
    8000446a:	6c88                	ld	a0,24(s1)
    8000446c:	878ff0ef          	jal	800034e4 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    80004470:	4761                	li	a4,24
    80004472:	86ce                	mv	a3,s3
    80004474:	8652                	mv	a2,s4
    80004476:	04893583          	ld	a1,72(s2)
    8000447a:	05093503          	ld	a0,80(s2)
    8000447e:	904fd0ef          	jal	80001582 <copyout>
    80004482:	41f5551b          	sraiw	a0,a0,0x1f
    80004486:	7942                	ld	s2,48(sp)
    80004488:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000448a:	60a6                	ld	ra,72(sp)
    8000448c:	6406                	ld	s0,64(sp)
    8000448e:	74e2                	ld	s1,56(sp)
    80004490:	7a02                	ld	s4,32(sp)
    80004492:	6161                	addi	sp,sp,80
    80004494:	8082                	ret
  return -1;
    80004496:	557d                	li	a0,-1
    80004498:	bfcd                	j	8000448a <filestat+0x60>

000000008000449a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000449a:	7179                	addi	sp,sp,-48
    8000449c:	f406                	sd	ra,40(sp)
    8000449e:	f022                	sd	s0,32(sp)
    800044a0:	e84a                	sd	s2,16(sp)
    800044a2:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    800044a4:	00854783          	lbu	a5,8(a0)
    800044a8:	c3dd                	beqz	a5,8000454e <fileread+0xb4>
    800044aa:	ec26                	sd	s1,24(sp)
    800044ac:	e44e                	sd	s3,8(sp)
    800044ae:	84aa                	mv	s1,a0
    800044b0:	892e                	mv	s2,a1
    800044b2:	89b2                	mv	s3,a2
    800044b4:	01f6579b          	srliw	a5,a2,0x1f
    800044b8:	ebc9                	bnez	a5,8000454a <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    800044ba:	411c                	lw	a5,0(a0)
    800044bc:	4705                	li	a4,1
    800044be:	04e78363          	beq	a5,a4,80004504 <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800044c2:	470d                	li	a4,3
    800044c4:	04e78763          	beq	a5,a4,80004512 <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    800044c8:	4709                	li	a4,2
    800044ca:	06e79a63          	bne	a5,a4,8000453e <fileread+0xa4>
    ilock(f->ip);
    800044ce:	6d08                	ld	a0,24(a0)
    800044d0:	f67fe0ef          	jal	80003436 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800044d4:	874e                	mv	a4,s3
    800044d6:	5094                	lw	a3,32(s1)
    800044d8:	864a                	mv	a2,s2
    800044da:	4585                	li	a1,1
    800044dc:	6c88                	ld	a0,24(s1)
    800044de:	b32ff0ef          	jal	80003810 <readi>
    800044e2:	892a                	mv	s2,a0
    800044e4:	00a05563          	blez	a0,800044ee <fileread+0x54>
      f->off += r;
    800044e8:	509c                	lw	a5,32(s1)
    800044ea:	9fa9                	addw	a5,a5,a0
    800044ec:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800044ee:	6c88                	ld	a0,24(s1)
    800044f0:	ff5fe0ef          	jal	800034e4 <iunlock>
    800044f4:	64e2                	ld	s1,24(sp)
    800044f6:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800044f8:	854a                	mv	a0,s2
    800044fa:	70a2                	ld	ra,40(sp)
    800044fc:	7402                	ld	s0,32(sp)
    800044fe:	6942                	ld	s2,16(sp)
    80004500:	6145                	addi	sp,sp,48
    80004502:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004504:	6908                	ld	a0,16(a0)
    80004506:	3e2000ef          	jal	800048e8 <piperead>
    8000450a:	892a                	mv	s2,a0
    8000450c:	64e2                	ld	s1,24(sp)
    8000450e:	69a2                	ld	s3,8(sp)
    80004510:	b7e5                	j	800044f8 <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004512:	02451783          	lh	a5,36(a0)
    80004516:	03079693          	slli	a3,a5,0x30
    8000451a:	92c1                	srli	a3,a3,0x30
    8000451c:	4725                	li	a4,9
    8000451e:	02d76b63          	bltu	a4,a3,80004554 <fileread+0xba>
    80004522:	0792                	slli	a5,a5,0x4
    80004524:	0001e717          	auipc	a4,0x1e
    80004528:	14c70713          	addi	a4,a4,332 # 80022670 <devsw>
    8000452c:	97ba                	add	a5,a5,a4
    8000452e:	639c                	ld	a5,0(a5)
    80004530:	c79d                	beqz	a5,8000455e <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    80004532:	4505                	li	a0,1
    80004534:	9782                	jalr	a5
    80004536:	892a                	mv	s2,a0
    80004538:	64e2                	ld	s1,24(sp)
    8000453a:	69a2                	ld	s3,8(sp)
    8000453c:	bf75                	j	800044f8 <fileread+0x5e>
    panic("fileread");
    8000453e:	00003517          	auipc	a0,0x3
    80004542:	1da50513          	addi	a0,a0,474 # 80007718 <etext+0x718>
    80004546:	aeefc0ef          	jal	80000834 <panic>
    8000454a:	64e2                	ld	s1,24(sp)
    8000454c:	69a2                	ld	s3,8(sp)
    return -1;
    8000454e:	57fd                	li	a5,-1
    80004550:	893e                	mv	s2,a5
    80004552:	b75d                	j	800044f8 <fileread+0x5e>
      return -1;
    80004554:	57fd                	li	a5,-1
    80004556:	893e                	mv	s2,a5
    80004558:	64e2                	ld	s1,24(sp)
    8000455a:	69a2                	ld	s3,8(sp)
    8000455c:	bf71                	j	800044f8 <fileread+0x5e>
    8000455e:	57fd                	li	a5,-1
    80004560:	893e                	mv	s2,a5
    80004562:	64e2                	ld	s1,24(sp)
    80004564:	69a2                	ld	s3,8(sp)
    80004566:	bf49                	j	800044f8 <fileread+0x5e>

0000000080004568 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    80004568:	00954783          	lbu	a5,9(a0)
    8000456c:	12078b63          	beqz	a5,800046a2 <filewrite+0x13a>
{
    80004570:	711d                	addi	sp,sp,-96
    80004572:	ec86                	sd	ra,88(sp)
    80004574:	e8a2                	sd	s0,80(sp)
    80004576:	e0ca                	sd	s2,64(sp)
    80004578:	f456                	sd	s5,40(sp)
    8000457a:	f05a                	sd	s6,32(sp)
    8000457c:	1080                	addi	s0,sp,96
    8000457e:	892a                	mv	s2,a0
    80004580:	8b2e                	mv	s6,a1
    80004582:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    80004584:	01f6579b          	srliw	a5,a2,0x1f
    80004588:	0e079d63          	bnez	a5,80004682 <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    8000458c:	411c                	lw	a5,0(a0)
    8000458e:	4705                	li	a4,1
    80004590:	02e78a63          	beq	a5,a4,800045c4 <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004594:	470d                	li	a4,3
    80004596:	02e78b63          	beq	a5,a4,800045cc <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    8000459a:	4709                	li	a4,2
    8000459c:	0ce79763          	bne	a5,a4,8000466a <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    800045a0:	0ec05763          	blez	a2,8000468e <filewrite+0x126>
    800045a4:	e4a6                	sd	s1,72(sp)
    800045a6:	fc4e                	sd	s3,56(sp)
    800045a8:	f852                	sd	s4,48(sp)
    800045aa:	ec5e                	sd	s7,24(sp)
    800045ac:	e862                	sd	s8,16(sp)
    800045ae:	e466                	sd	s9,8(sp)
    int i = 0;
    800045b0:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    800045b2:	6b85                	lui	s7,0x1
    800045b4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800045b8:	6785                	lui	a5,0x1
    800045ba:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800045be:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800045c0:	4c05                	li	s8,1
    800045c2:	a8ad                	j	8000463c <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    800045c4:	6908                	ld	a0,16(a0)
    800045c6:	206000ef          	jal	800047cc <pipewrite>
    800045ca:	a849                	j	8000465c <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800045cc:	02451783          	lh	a5,36(a0)
    800045d0:	03079693          	slli	a3,a5,0x30
    800045d4:	92c1                	srli	a3,a3,0x30
    800045d6:	4725                	li	a4,9
    800045d8:	0ad76763          	bltu	a4,a3,80004686 <filewrite+0x11e>
    800045dc:	0792                	slli	a5,a5,0x4
    800045de:	0001e717          	auipc	a4,0x1e
    800045e2:	09270713          	addi	a4,a4,146 # 80022670 <devsw>
    800045e6:	97ba                	add	a5,a5,a4
    800045e8:	679c                	ld	a5,8(a5)
    800045ea:	c3c5                	beqz	a5,8000468a <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800045ec:	4505                	li	a0,1
    800045ee:	9782                	jalr	a5
    800045f0:	a0b5                	j	8000465c <filewrite+0xf4>
      if (n1 > max)
    800045f2:	2981                	sext.w	s3,s3
      begin_op();
    800045f4:	8bbff0ef          	jal	80003eae <begin_op>
      ilock(f->ip);
    800045f8:	01893503          	ld	a0,24(s2)
    800045fc:	e3bfe0ef          	jal	80003436 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004600:	874e                	mv	a4,s3
    80004602:	02092683          	lw	a3,32(s2)
    80004606:	016a0633          	add	a2,s4,s6
    8000460a:	85e2                	mv	a1,s8
    8000460c:	01893503          	ld	a0,24(s2)
    80004610:	af2ff0ef          	jal	80003902 <writei>
    80004614:	84aa                	mv	s1,a0
    80004616:	00a05763          	blez	a0,80004624 <filewrite+0xbc>
        f->off += r;
    8000461a:	02092783          	lw	a5,32(s2)
    8000461e:	9fa9                	addw	a5,a5,a0
    80004620:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004624:	01893503          	ld	a0,24(s2)
    80004628:	ebdfe0ef          	jal	800034e4 <iunlock>
      end_op();
    8000462c:	90fff0ef          	jal	80003f3a <end_op>

      if (r != n1) {
    80004630:	00999d63          	bne	s3,s1,8000464a <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    80004634:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    80004638:	015a5963          	bge	s4,s5,8000464a <filewrite+0xe2>
      int n1 = n - i;
    8000463c:	414a87bb          	subw	a5,s5,s4
    80004640:	89be                	mv	s3,a5
      if (n1 > max)
    80004642:	fafbd8e3          	bge	s7,a5,800045f2 <filewrite+0x8a>
    80004646:	89e6                	mv	s3,s9
    80004648:	b76d                	j	800045f2 <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    8000464a:	054a9463          	bne	s5,s4,80004692 <filewrite+0x12a>
    8000464e:	8556                	mv	a0,s5
    80004650:	64a6                	ld	s1,72(sp)
    80004652:	79e2                	ld	s3,56(sp)
    80004654:	7a42                	ld	s4,48(sp)
    80004656:	6be2                	ld	s7,24(sp)
    80004658:	6c42                	ld	s8,16(sp)
    8000465a:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000465c:	60e6                	ld	ra,88(sp)
    8000465e:	6446                	ld	s0,80(sp)
    80004660:	6906                	ld	s2,64(sp)
    80004662:	7aa2                	ld	s5,40(sp)
    80004664:	7b02                	ld	s6,32(sp)
    80004666:	6125                	addi	sp,sp,96
    80004668:	8082                	ret
    8000466a:	e4a6                	sd	s1,72(sp)
    8000466c:	fc4e                	sd	s3,56(sp)
    8000466e:	f852                	sd	s4,48(sp)
    80004670:	ec5e                	sd	s7,24(sp)
    80004672:	e862                	sd	s8,16(sp)
    80004674:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004676:	00003517          	auipc	a0,0x3
    8000467a:	0b250513          	addi	a0,a0,178 # 80007728 <etext+0x728>
    8000467e:	9b6fc0ef          	jal	80000834 <panic>
    return -1;
    80004682:	557d                	li	a0,-1
    80004684:	bfe1                	j	8000465c <filewrite+0xf4>
      return -1;
    80004686:	557d                	li	a0,-1
    80004688:	bfd1                	j	8000465c <filewrite+0xf4>
    8000468a:	557d                	li	a0,-1
    8000468c:	bfc1                	j	8000465c <filewrite+0xf4>
    ret = (i == n ? n : -1);
    8000468e:	8532                	mv	a0,a2
    80004690:	b7f1                	j	8000465c <filewrite+0xf4>
    80004692:	557d                	li	a0,-1
    80004694:	64a6                	ld	s1,72(sp)
    80004696:	79e2                	ld	s3,56(sp)
    80004698:	7a42                	ld	s4,48(sp)
    8000469a:	6be2                	ld	s7,24(sp)
    8000469c:	6c42                	ld	s8,16(sp)
    8000469e:	6ca2                	ld	s9,8(sp)
    800046a0:	bf75                	j	8000465c <filewrite+0xf4>
    return -1;
    800046a2:	557d                	li	a0,-1
}
    800046a4:	8082                	ret

00000000800046a6 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800046a6:	7179                	addi	sp,sp,-48
    800046a8:	f406                	sd	ra,40(sp)
    800046aa:	f022                	sd	s0,32(sp)
    800046ac:	ec26                	sd	s1,24(sp)
    800046ae:	e052                	sd	s4,0(sp)
    800046b0:	1800                	addi	s0,sp,48
    800046b2:	84aa                	mv	s1,a0
    800046b4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800046b6:	0005b023          	sd	zero,0(a1)
    800046ba:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800046be:	c07ff0ef          	jal	800042c4 <filealloc>
    800046c2:	e088                	sd	a0,0(s1)
    800046c4:	c549                	beqz	a0,8000474e <pipealloc+0xa8>
    800046c6:	bffff0ef          	jal	800042c4 <filealloc>
    800046ca:	00aa3023          	sd	a0,0(s4)
    800046ce:	cd25                	beqz	a0,80004746 <pipealloc+0xa0>
    800046d0:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    800046d2:	c7cfc0ef          	jal	80000b4e <kalloc>
    800046d6:	892a                	mv	s2,a0
    800046d8:	c12d                	beqz	a0,8000473a <pipealloc+0x94>
    800046da:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800046dc:	4985                	li	s3,1
    800046de:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800046e2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800046e6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800046ea:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800046ee:	00003597          	auipc	a1,0x3
    800046f2:	04a58593          	addi	a1,a1,74 # 80007738 <etext+0x738>
    800046f6:	cb2fc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    800046fa:	609c                	ld	a5,0(s1)
    800046fc:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004700:	609c                	ld	a5,0(s1)
    80004702:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004706:	609c                	ld	a5,0(s1)
    80004708:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000470c:	609c                	ld	a5,0(s1)
    8000470e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004712:	000a3783          	ld	a5,0(s4)
    80004716:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000471a:	000a3783          	ld	a5,0(s4)
    8000471e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004722:	000a3783          	ld	a5,0(s4)
    80004726:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000472a:	000a3783          	ld	a5,0(s4)
    8000472e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004732:	4501                	li	a0,0
    80004734:	6942                	ld	s2,16(sp)
    80004736:	69a2                	ld	s3,8(sp)
    80004738:	a01d                	j	8000475e <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    8000473a:	6088                	ld	a0,0(s1)
    8000473c:	c119                	beqz	a0,80004742 <pipealloc+0x9c>
    8000473e:	6942                	ld	s2,16(sp)
    80004740:	a029                	j	8000474a <pipealloc+0xa4>
    80004742:	6942                	ld	s2,16(sp)
    80004744:	a029                	j	8000474e <pipealloc+0xa8>
    80004746:	6088                	ld	a0,0(s1)
    80004748:	c10d                	beqz	a0,8000476a <pipealloc+0xc4>
    fileclose(*f0);
    8000474a:	c1fff0ef          	jal	80004368 <fileclose>
  if (*f1)
    8000474e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004752:	557d                	li	a0,-1
  if (*f1)
    80004754:	c789                	beqz	a5,8000475e <pipealloc+0xb8>
    fileclose(*f1);
    80004756:	853e                	mv	a0,a5
    80004758:	c11ff0ef          	jal	80004368 <fileclose>
  return -1;
    8000475c:	557d                	li	a0,-1
}
    8000475e:	70a2                	ld	ra,40(sp)
    80004760:	7402                	ld	s0,32(sp)
    80004762:	64e2                	ld	s1,24(sp)
    80004764:	6a02                	ld	s4,0(sp)
    80004766:	6145                	addi	sp,sp,48
    80004768:	8082                	ret
  return -1;
    8000476a:	557d                	li	a0,-1
    8000476c:	bfcd                	j	8000475e <pipealloc+0xb8>

000000008000476e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000476e:	1101                	addi	sp,sp,-32
    80004770:	ec06                	sd	ra,24(sp)
    80004772:	e822                	sd	s0,16(sp)
    80004774:	e426                	sd	s1,8(sp)
    80004776:	e04a                	sd	s2,0(sp)
    80004778:	1000                	addi	s0,sp,32
    8000477a:	84aa                	mv	s1,a0
    8000477c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000477e:	caafc0ef          	jal	80000c28 <acquire>
  if (writable) {
    80004782:	02090763          	beqz	s2,800047b0 <pipeclose+0x42>
    pi->writeopen = 0;
    80004786:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000478a:	21848513          	addi	a0,s1,536
    8000478e:	9e3fd0ef          	jal	80002170 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004792:	2204a783          	lw	a5,544(s1)
    80004796:	e781                	bnez	a5,8000479e <pipeclose+0x30>
    80004798:	2244a783          	lw	a5,548(s1)
    8000479c:	c38d                	beqz	a5,800047be <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    8000479e:	8526                	mv	a0,s1
    800047a0:	d10fc0ef          	jal	80000cb0 <release>
}
    800047a4:	60e2                	ld	ra,24(sp)
    800047a6:	6442                	ld	s0,16(sp)
    800047a8:	64a2                	ld	s1,8(sp)
    800047aa:	6902                	ld	s2,0(sp)
    800047ac:	6105                	addi	sp,sp,32
    800047ae:	8082                	ret
    pi->readopen = 0;
    800047b0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800047b4:	21c48513          	addi	a0,s1,540
    800047b8:	9b9fd0ef          	jal	80002170 <wakeup>
    800047bc:	bfd9                	j	80004792 <pipeclose+0x24>
    release(&pi->lock);
    800047be:	8526                	mv	a0,s1
    800047c0:	cf0fc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    800047c4:	8526                	mv	a0,s1
    800047c6:	aa0fc0ef          	jal	80000a66 <kfree>
    800047ca:	bfe9                	j	800047a4 <pipeclose+0x36>

00000000800047cc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800047cc:	7159                	addi	sp,sp,-112
    800047ce:	f486                	sd	ra,104(sp)
    800047d0:	f0a2                	sd	s0,96(sp)
    800047d2:	eca6                	sd	s1,88(sp)
    800047d4:	e8ca                	sd	s2,80(sp)
    800047d6:	e4ce                	sd	s3,72(sp)
    800047d8:	e0d2                	sd	s4,64(sp)
    800047da:	fc56                	sd	s5,56(sp)
    800047dc:	1880                	addi	s0,sp,112
    800047de:	84aa                	mv	s1,a0
    800047e0:	8aae                	mv	s5,a1
    800047e2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800047e4:	b16fd0ef          	jal	80001afa <myproc>
    800047e8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800047ea:	8526                	mv	a0,s1
    800047ec:	c3cfc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    800047f0:	0f405a63          	blez	s4,800048e4 <pipewrite+0x118>
    800047f4:	f85a                	sd	s6,48(sp)
    800047f6:	f45e                	sd	s7,40(sp)
    800047f8:	f062                	sd	s8,32(sp)
    800047fa:	ec66                	sd	s9,24(sp)
    800047fc:	e86a                	sd	s10,16(sp)
  int i = 0;
    800047fe:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004800:	f9f40c13          	addi	s8,s0,-97
    80004804:	4b85                	li	s7,1
    80004806:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004808:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    8000480c:	21c48c93          	addi	s9,s1,540
    80004810:	a0a1                	j	80004858 <pipewrite+0x8c>
      release(&pi->lock);
    80004812:	8526                	mv	a0,s1
    80004814:	c9cfc0ef          	jal	80000cb0 <release>
      return -1;
    80004818:	597d                	li	s2,-1
    8000481a:	7b42                	ld	s6,48(sp)
    8000481c:	7ba2                	ld	s7,40(sp)
    8000481e:	7c02                	ld	s8,32(sp)
    80004820:	6ce2                	ld	s9,24(sp)
    80004822:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004824:	854a                	mv	a0,s2
    80004826:	70a6                	ld	ra,104(sp)
    80004828:	7406                	ld	s0,96(sp)
    8000482a:	64e6                	ld	s1,88(sp)
    8000482c:	6946                	ld	s2,80(sp)
    8000482e:	69a6                	ld	s3,72(sp)
    80004830:	6a06                	ld	s4,64(sp)
    80004832:	7ae2                	ld	s5,56(sp)
    80004834:	6165                	addi	sp,sp,112
    80004836:	8082                	ret
      wakeup(&pi->nread);
    80004838:	856a                	mv	a0,s10
    8000483a:	937fd0ef          	jal	80002170 <wakeup>
      sleep_prepare(&pi->nwrite);
    8000483e:	8566                	mv	a0,s9
    80004840:	8c5fd0ef          	jal	80002104 <sleep_prepare>
      release(&pi->lock);
    80004844:	8526                	mv	a0,s1
    80004846:	c6afc0ef          	jal	80000cb0 <release>
      sleep();
    8000484a:	8f7fd0ef          	jal	80002140 <sleep>
      acquire(&pi->lock);
    8000484e:	8526                	mv	a0,s1
    80004850:	bd8fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    80004854:	07495b63          	bge	s2,s4,800048ca <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    80004858:	2204a783          	lw	a5,544(s1)
    8000485c:	dbdd                	beqz	a5,80004812 <pipewrite+0x46>
    8000485e:	854e                	mv	a0,s3
    80004860:	b03fd0ef          	jal	80002362 <killed>
    80004864:	f55d                	bnez	a0,80004812 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    80004866:	2184a783          	lw	a5,536(s1)
    8000486a:	21c4a703          	lw	a4,540(s1)
    8000486e:	2007879b          	addiw	a5,a5,512
    80004872:	fcf703e3          	beq	a4,a5,80004838 <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004876:	875e                	mv	a4,s7
    80004878:	015906b3          	add	a3,s2,s5
    8000487c:	8662                	mv	a2,s8
    8000487e:	0489b583          	ld	a1,72(s3)
    80004882:	0509b503          	ld	a0,80(s3)
    80004886:	dc3fc0ef          	jal	80001648 <copyin>
    8000488a:	03650163          	beq	a0,s6,800048ac <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000488e:	21c4a783          	lw	a5,540(s1)
    80004892:	0017871b          	addiw	a4,a5,1
    80004896:	20e4ae23          	sw	a4,540(s1)
    8000489a:	1ff7f793          	andi	a5,a5,511
    8000489e:	97a6                	add	a5,a5,s1
    800048a0:	f9f44703          	lbu	a4,-97(s0)
    800048a4:	00e78c23          	sb	a4,24(a5)
      i++;
    800048a8:	2905                	addiw	s2,s2,1
    800048aa:	b76d                	j	80004854 <pipewrite+0x88>
        if (i == 0)
    800048ac:	00090863          	beqz	s2,800048bc <pipewrite+0xf0>
    800048b0:	7b42                	ld	s6,48(sp)
    800048b2:	7ba2                	ld	s7,40(sp)
    800048b4:	7c02                	ld	s8,32(sp)
    800048b6:	6ce2                	ld	s9,24(sp)
    800048b8:	6d42                	ld	s10,16(sp)
    800048ba:	a829                	j	800048d4 <pipewrite+0x108>
          i = -1;
    800048bc:	892a                	mv	s2,a0
        break;
    800048be:	7b42                	ld	s6,48(sp)
    800048c0:	7ba2                	ld	s7,40(sp)
    800048c2:	7c02                	ld	s8,32(sp)
    800048c4:	6ce2                	ld	s9,24(sp)
    800048c6:	6d42                	ld	s10,16(sp)
    800048c8:	a031                	j	800048d4 <pipewrite+0x108>
    800048ca:	7b42                	ld	s6,48(sp)
    800048cc:	7ba2                	ld	s7,40(sp)
    800048ce:	7c02                	ld	s8,32(sp)
    800048d0:	6ce2                	ld	s9,24(sp)
    800048d2:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800048d4:	21848513          	addi	a0,s1,536
    800048d8:	899fd0ef          	jal	80002170 <wakeup>
  release(&pi->lock);
    800048dc:	8526                	mv	a0,s1
    800048de:	bd2fc0ef          	jal	80000cb0 <release>
  return i;
    800048e2:	b789                	j	80004824 <pipewrite+0x58>
  int i = 0;
    800048e4:	4901                	li	s2,0
    800048e6:	b7fd                	j	800048d4 <pipewrite+0x108>

00000000800048e8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800048e8:	711d                	addi	sp,sp,-96
    800048ea:	ec86                	sd	ra,88(sp)
    800048ec:	e8a2                	sd	s0,80(sp)
    800048ee:	e4a6                	sd	s1,72(sp)
    800048f0:	e0ca                	sd	s2,64(sp)
    800048f2:	fc4e                	sd	s3,56(sp)
    800048f4:	f852                	sd	s4,48(sp)
    800048f6:	f456                	sd	s5,40(sp)
    800048f8:	1080                	addi	s0,sp,96
    800048fa:	84aa                	mv	s1,a0
    800048fc:	89ae                	mv	s3,a1
    800048fe:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004900:	9fafd0ef          	jal	80001afa <myproc>
    80004904:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    80004906:	8526                	mv	a0,s1
    80004908:	b20fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000490c:	0d505263          	blez	s5,800049d0 <piperead+0xe8>
    80004910:	2184a703          	lw	a4,536(s1)
    80004914:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004918:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000491c:	02f71e63          	bne	a4,a5,80004958 <piperead+0x70>
    80004920:	2244a783          	lw	a5,548(s1)
    80004924:	c3b9                	beqz	a5,8000496a <piperead+0x82>
    if (killed(pr)) {
    80004926:	854a                	mv	a0,s2
    80004928:	a3bfd0ef          	jal	80002362 <killed>
    8000492c:	e915                	bnez	a0,80004960 <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    8000492e:	8552                	mv	a0,s4
    80004930:	fd4fd0ef          	jal	80002104 <sleep_prepare>
    release(&pi->lock);
    80004934:	8526                	mv	a0,s1
    80004936:	b7afc0ef          	jal	80000cb0 <release>
    sleep();
    8000493a:	807fd0ef          	jal	80002140 <sleep>
    acquire(&pi->lock);
    8000493e:	8526                	mv	a0,s1
    80004940:	ae8fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004944:	2184a703          	lw	a4,536(s1)
    80004948:	21c4a783          	lw	a5,540(s1)
    8000494c:	fcf70ae3          	beq	a4,a5,80004920 <piperead+0x38>
    80004950:	f05a                	sd	s6,32(sp)
    80004952:	ec5e                	sd	s7,24(sp)
    80004954:	e862                	sd	s8,16(sp)
    80004956:	a829                	j	80004970 <piperead+0x88>
    80004958:	f05a                	sd	s6,32(sp)
    8000495a:	ec5e                	sd	s7,24(sp)
    8000495c:	e862                	sd	s8,16(sp)
    8000495e:	a809                	j	80004970 <piperead+0x88>
      release(&pi->lock);
    80004960:	8526                	mv	a0,s1
    80004962:	b4efc0ef          	jal	80000cb0 <release>
      return -1;
    80004966:	5a7d                	li	s4,-1
    80004968:	a8a5                	j	800049e0 <piperead+0xf8>
    8000496a:	f05a                	sd	s6,32(sp)
    8000496c:	ec5e                	sd	s7,24(sp)
    8000496e:	e862                	sd	s8,16(sp)
{
    80004970:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004972:	faf40c13          	addi	s8,s0,-81
    80004976:	4b85                	li	s7,1
    80004978:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    8000497a:	2184a783          	lw	a5,536(s1)
    8000497e:	21c4a703          	lw	a4,540(s1)
    80004982:	06f70e63          	beq	a4,a5,800049fe <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    80004986:	1ff7f793          	andi	a5,a5,511
    8000498a:	97a6                	add	a5,a5,s1
    8000498c:	0187c783          	lbu	a5,24(a5)
    80004990:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004994:	875e                	mv	a4,s7
    80004996:	86e2                	mv	a3,s8
    80004998:	864e                	mv	a2,s3
    8000499a:	04893583          	ld	a1,72(s2)
    8000499e:	05093503          	ld	a0,80(s2)
    800049a2:	be1fc0ef          	jal	80001582 <copyout>
    800049a6:	01650f63          	beq	a0,s6,800049c4 <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800049aa:	2184a783          	lw	a5,536(s1)
    800049ae:	2785                	addiw	a5,a5,1
    800049b0:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800049b4:	2a05                	addiw	s4,s4,1
    800049b6:	0985                	addi	s3,s3,1
    800049b8:	fd4a91e3          	bne	s5,s4,8000497a <piperead+0x92>
    800049bc:	7b02                	ld	s6,32(sp)
    800049be:	6be2                	ld	s7,24(sp)
    800049c0:	6c42                	ld	s8,16(sp)
    800049c2:	a801                	j	800049d2 <piperead+0xea>
      if (i == 0)
    800049c4:	020a0863          	beqz	s4,800049f4 <piperead+0x10c>
    800049c8:	7b02                	ld	s6,32(sp)
    800049ca:	6be2                	ld	s7,24(sp)
    800049cc:	6c42                	ld	s8,16(sp)
    800049ce:	a011                	j	800049d2 <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800049d0:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    800049d2:	21c48513          	addi	a0,s1,540
    800049d6:	f9afd0ef          	jal	80002170 <wakeup>
  release(&pi->lock);
    800049da:	8526                	mv	a0,s1
    800049dc:	ad4fc0ef          	jal	80000cb0 <release>
  return i;
}
    800049e0:	8552                	mv	a0,s4
    800049e2:	60e6                	ld	ra,88(sp)
    800049e4:	6446                	ld	s0,80(sp)
    800049e6:	64a6                	ld	s1,72(sp)
    800049e8:	6906                	ld	s2,64(sp)
    800049ea:	79e2                	ld	s3,56(sp)
    800049ec:	7a42                	ld	s4,48(sp)
    800049ee:	7aa2                	ld	s5,40(sp)
    800049f0:	6125                	addi	sp,sp,96
    800049f2:	8082                	ret
        i = -1;
    800049f4:	8a2a                	mv	s4,a0
    800049f6:	7b02                	ld	s6,32(sp)
    800049f8:	6be2                	ld	s7,24(sp)
    800049fa:	6c42                	ld	s8,16(sp)
    800049fc:	bfd9                	j	800049d2 <piperead+0xea>
    800049fe:	7b02                	ld	s6,32(sp)
    80004a00:	6be2                	ld	s7,24(sp)
    80004a02:	6c42                	ld	s8,16(sp)
    80004a04:	b7f9                	j	800049d2 <piperead+0xea>

0000000080004a06 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004a06:	1141                	addi	sp,sp,-16
    80004a08:	e406                	sd	ra,8(sp)
    80004a0a:	e022                	sd	s0,0(sp)
    80004a0c:	0800                	addi	s0,sp,16
    80004a0e:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004a10:	0035151b          	slliw	a0,a0,0x3
    80004a14:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    80004a16:	8b89                	andi	a5,a5,2
    80004a18:	c399                	beqz	a5,80004a1e <flags2perm+0x18>
    perm |= PTE_W;
    80004a1a:	00456513          	ori	a0,a0,4
  return perm;
}
    80004a1e:	60a2                	ld	ra,8(sp)
    80004a20:	6402                	ld	s0,0(sp)
    80004a22:	0141                	addi	sp,sp,16
    80004a24:	8082                	ret

0000000080004a26 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004a26:	de010113          	addi	sp,sp,-544
    80004a2a:	20113c23          	sd	ra,536(sp)
    80004a2e:	20813823          	sd	s0,528(sp)
    80004a32:	20913423          	sd	s1,520(sp)
    80004a36:	21213023          	sd	s2,512(sp)
    80004a3a:	1400                	addi	s0,sp,544
    80004a3c:	892a                	mv	s2,a0
    80004a3e:	dea43823          	sd	a0,-528(s0)
    80004a42:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004a46:	8b4fd0ef          	jal	80001afa <myproc>
    80004a4a:	84aa                	mv	s1,a0

  begin_op();
    80004a4c:	c62ff0ef          	jal	80003eae <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004a50:	854a                	mv	a0,s2
    80004a52:	a7eff0ef          	jal	80003cd0 <namei>
    80004a56:	cd21                	beqz	a0,80004aae <kexec+0x88>
    80004a58:	fbd2                	sd	s4,496(sp)
    80004a5a:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004a5c:	9dbfe0ef          	jal	80003436 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004a60:	04000713          	li	a4,64
    80004a64:	4681                	li	a3,0
    80004a66:	e5040613          	addi	a2,s0,-432
    80004a6a:	4581                	li	a1,0
    80004a6c:	8552                	mv	a0,s4
    80004a6e:	da3fe0ef          	jal	80003810 <readi>
    80004a72:	04000793          	li	a5,64
    80004a76:	00f51a63          	bne	a0,a5,80004a8a <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004a7a:	e5042703          	lw	a4,-432(s0)
    80004a7e:	464c47b7          	lui	a5,0x464c4
    80004a82:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a86:	02f70863          	beq	a4,a5,80004ab6 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004a8a:	8552                	mv	a0,s4
    80004a8c:	bfffe0ef          	jal	8000368a <iunlockput>
    end_op();
    80004a90:	caaff0ef          	jal	80003f3a <end_op>
  }
  return -1;
    80004a94:	557d                	li	a0,-1
    80004a96:	7a5e                	ld	s4,496(sp)
}
    80004a98:	21813083          	ld	ra,536(sp)
    80004a9c:	21013403          	ld	s0,528(sp)
    80004aa0:	20813483          	ld	s1,520(sp)
    80004aa4:	20013903          	ld	s2,512(sp)
    80004aa8:	22010113          	addi	sp,sp,544
    80004aac:	8082                	ret
    end_op();
    80004aae:	c8cff0ef          	jal	80003f3a <end_op>
    return -1;
    80004ab2:	557d                	li	a0,-1
    80004ab4:	b7d5                	j	80004a98 <kexec+0x72>
    80004ab6:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004ab8:	8526                	mv	a0,s1
    80004aba:	946fd0ef          	jal	80001c00 <proc_pagetable>
    80004abe:	8b2a                	mv	s6,a0
    80004ac0:	26050e63          	beqz	a0,80004d3c <kexec+0x316>
    80004ac4:	ffce                	sd	s3,504(sp)
    80004ac6:	f7d6                	sd	s5,488(sp)
    80004ac8:	efde                	sd	s7,472(sp)
    80004aca:	ebe2                	sd	s8,464(sp)
    80004acc:	e7e6                	sd	s9,456(sp)
    80004ace:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004ad0:	e8845783          	lhu	a5,-376(s0)
    80004ad4:	14078263          	beqz	a5,80004c18 <kexec+0x1f2>
    80004ad8:	ff6e                	sd	s11,440(sp)
    80004ada:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ade:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004ae0:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ae2:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004ae6:	6c85                	lui	s9,0x1
    80004ae8:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004aec:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004af0:	6a85                	lui	s5,0x1
    80004af2:	a085                	j	80004b52 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004af4:	00003517          	auipc	a0,0x3
    80004af8:	c4c50513          	addi	a0,a0,-948 # 80007740 <etext+0x740>
    80004afc:	d39fb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004b00:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004b02:	874a                	mv	a4,s2
    80004b04:	009b86bb          	addw	a3,s7,s1
    80004b08:	4581                	li	a1,0
    80004b0a:	8552                	mv	a0,s4
    80004b0c:	d05fe0ef          	jal	80003810 <readi>
    80004b10:	22a91a63          	bne	s2,a0,80004d44 <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004b14:	009a84bb          	addw	s1,s5,s1
    80004b18:	0334f263          	bgeu	s1,s3,80004b3c <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004b1c:	02049593          	slli	a1,s1,0x20
    80004b20:	9181                	srli	a1,a1,0x20
    80004b22:	95e2                	add	a1,a1,s8
    80004b24:	855a                	mv	a0,s6
    80004b26:	cf2fc0ef          	jal	80001018 <walkaddr>
    80004b2a:	862a                	mv	a2,a0
    if (pa == 0)
    80004b2c:	d561                	beqz	a0,80004af4 <kexec+0xce>
    if (sz - i < PGSIZE)
    80004b2e:	409987bb          	subw	a5,s3,s1
    80004b32:	893e                	mv	s2,a5
    80004b34:	fcfcf6e3          	bgeu	s9,a5,80004b00 <kexec+0xda>
    80004b38:	8956                	mv	s2,s5
    80004b3a:	b7d9                	j	80004b00 <kexec+0xda>
    sz = sz1;
    80004b3c:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004b40:	2d05                	addiw	s10,s10,1
    80004b42:	e0843783          	ld	a5,-504(s0)
    80004b46:	0387869b          	addiw	a3,a5,56
    80004b4a:	e8845783          	lhu	a5,-376(s0)
    80004b4e:	06fd5d63          	bge	s10,a5,80004bc8 <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004b52:	e0d43423          	sd	a3,-504(s0)
    80004b56:	876e                	mv	a4,s11
    80004b58:	e1840613          	addi	a2,s0,-488
    80004b5c:	4581                	li	a1,0
    80004b5e:	8552                	mv	a0,s4
    80004b60:	cb1fe0ef          	jal	80003810 <readi>
    80004b64:	1db51e63          	bne	a0,s11,80004d40 <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004b68:	e1842783          	lw	a5,-488(s0)
    80004b6c:	4705                	li	a4,1
    80004b6e:	fce799e3          	bne	a5,a4,80004b40 <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004b72:	e4043483          	ld	s1,-448(s0)
    80004b76:	e3843783          	ld	a5,-456(s0)
    80004b7a:	1ef4e363          	bltu	s1,a5,80004d60 <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004b7e:	e2843783          	ld	a5,-472(s0)
    80004b82:	94be                	add	s1,s1,a5
    80004b84:	1ef4e163          	bltu	s1,a5,80004d66 <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004b88:	de843703          	ld	a4,-536(s0)
    80004b8c:	8ff9                	and	a5,a5,a4
    80004b8e:	1c079f63          	bnez	a5,80004d6c <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004b92:	e1c42503          	lw	a0,-484(s0)
    80004b96:	e71ff0ef          	jal	80004a06 <flags2perm>
    80004b9a:	86aa                	mv	a3,a0
    80004b9c:	8626                	mv	a2,s1
    80004b9e:	85ca                	mv	a1,s2
    80004ba0:	855a                	mv	a0,s6
    80004ba2:	f4cfc0ef          	jal	800012ee <uvmalloc>
    80004ba6:	dea43c23          	sd	a0,-520(s0)
    80004baa:	1c050463          	beqz	a0,80004d72 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004bae:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004bb2:	00098863          	beqz	s3,80004bc2 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004bb6:	e2843c03          	ld	s8,-472(s0)
    80004bba:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004bbe:	4481                	li	s1,0
    80004bc0:	bfb1                	j	80004b1c <kexec+0xf6>
    sz = sz1;
    80004bc2:	df843903          	ld	s2,-520(s0)
    80004bc6:	bfad                	j	80004b40 <kexec+0x11a>
    80004bc8:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004bca:	8552                	mv	a0,s4
    80004bcc:	abffe0ef          	jal	8000368a <iunlockput>
  end_op();
    80004bd0:	b6aff0ef          	jal	80003f3a <end_op>
  p = myproc();
    80004bd4:	f27fc0ef          	jal	80001afa <myproc>
    80004bd8:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004bda:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004bde:	6c05                	lui	s8,0x1
    80004be0:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004be2:	9c4a                	add	s8,s8,s2
    80004be4:	77fd                	lui	a5,0xfffff
    80004be6:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004bea:	4691                	li	a3,4
    80004bec:	6609                	lui	a2,0x2
    80004bee:	9662                	add	a2,a2,s8
    80004bf0:	85e2                	mv	a1,s8
    80004bf2:	855a                	mv	a0,s6
    80004bf4:	efafc0ef          	jal	800012ee <uvmalloc>
    80004bf8:	892a                	mv	s2,a0
    80004bfa:	e10d                	bnez	a0,80004c1c <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004bfc:	85e2                	mv	a1,s8
    80004bfe:	855a                	mv	a0,s6
    80004c00:	884fd0ef          	jal	80001c84 <proc_freepagetable>
  return -1;
    80004c04:	557d                	li	a0,-1
    80004c06:	79fe                	ld	s3,504(sp)
    80004c08:	7a5e                	ld	s4,496(sp)
    80004c0a:	7abe                	ld	s5,488(sp)
    80004c0c:	7b1e                	ld	s6,480(sp)
    80004c0e:	6bfe                	ld	s7,472(sp)
    80004c10:	6c5e                	ld	s8,464(sp)
    80004c12:	6cbe                	ld	s9,456(sp)
    80004c14:	6d1e                	ld	s10,448(sp)
    80004c16:	b549                	j	80004a98 <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c18:	4901                	li	s2,0
    80004c1a:	bf45                	j	80004bca <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004c1c:	75f9                	lui	a1,0xffffe
    80004c1e:	95aa                	add	a1,a1,a0
    80004c20:	855a                	mv	a0,s6
    80004c22:	89ffc0ef          	jal	800014c0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004c26:	80090a13          	addi	s4,s2,-2048
    80004c2a:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004c2e:	e0043783          	ld	a5,-512(s0)
    80004c32:	6388                	ld	a0,0(a5)
    80004c34:	c545                	beqz	a0,80004cdc <kexec+0x2b6>
  sp = sz;
    80004c36:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004c38:	4481                	li	s1,0
    ustack[argc] = sp;
    80004c3a:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004c3e:	a34fc0ef          	jal	80000e72 <strlen>
    80004c42:	0015079b          	addiw	a5,a0,1
    80004c46:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004c4a:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004c4e:	134c6563          	bltu	s8,s4,80004d78 <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004c52:	e0043d03          	ld	s10,-512(s0)
    80004c56:	000d3c83          	ld	s9,0(s10)
    80004c5a:	8566                	mv	a0,s9
    80004c5c:	a16fc0ef          	jal	80000e72 <strlen>
    80004c60:	0015071b          	addiw	a4,a0,1
    80004c64:	86e6                	mv	a3,s9
    80004c66:	8662                	mv	a2,s8
    80004c68:	85ca                	mv	a1,s2
    80004c6a:	855a                	mv	a0,s6
    80004c6c:	917fc0ef          	jal	80001582 <copyout>
    80004c70:	10054663          	bltz	a0,80004d7c <kexec+0x356>
    ustack[argc] = sp;
    80004c74:	00349793          	slli	a5,s1,0x3
    80004c78:	97de                	add	a5,a5,s7
    80004c7a:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb7f8>
  for (argc = 0; argv[argc]; argc++) {
    80004c7e:	0485                	addi	s1,s1,1
    80004c80:	008d0793          	addi	a5,s10,8
    80004c84:	e0f43023          	sd	a5,-512(s0)
    80004c88:	008d3503          	ld	a0,8(s10)
    80004c8c:	f94d                	bnez	a0,80004c3e <kexec+0x218>
  ustack[argc] = 0;
    80004c8e:	00349793          	slli	a5,s1,0x3
    80004c92:	f9078793          	addi	a5,a5,-112
    80004c96:	97a2                	add	a5,a5,s0
    80004c98:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004c9c:	00349713          	slli	a4,s1,0x3
    80004ca0:	0721                	addi	a4,a4,8
    80004ca2:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004ca6:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004caa:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004cac:	f54be8e3          	bltu	s7,s4,80004bfc <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004cb0:	e9040693          	addi	a3,s0,-368
    80004cb4:	865e                	mv	a2,s7
    80004cb6:	85ca                	mv	a1,s2
    80004cb8:	855a                	mv	a0,s6
    80004cba:	8c9fc0ef          	jal	80001582 <copyout>
    80004cbe:	f2054fe3          	bltz	a0,80004bfc <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004cc2:	0589b783          	ld	a5,88(s3)
    80004cc6:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004cca:	df043783          	ld	a5,-528(s0)
    80004cce:	0007c703          	lbu	a4,0(a5)
    80004cd2:	c30d                	beqz	a4,80004cf4 <kexec+0x2ce>
    80004cd4:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004cd6:	02f00693          	li	a3,47
    80004cda:	a801                	j	80004cea <kexec+0x2c4>
  sp = sz;
    80004cdc:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004cde:	4481                	li	s1,0
    80004ce0:	b77d                	j	80004c8e <kexec+0x268>
  for (last = s = path; *s; s++)
    80004ce2:	0785                	addi	a5,a5,1
    80004ce4:	fff7c703          	lbu	a4,-1(a5)
    80004ce8:	c711                	beqz	a4,80004cf4 <kexec+0x2ce>
    if (*s == '/')
    80004cea:	fed71ce3          	bne	a4,a3,80004ce2 <kexec+0x2bc>
      last = s + 1;
    80004cee:	def43823          	sd	a5,-528(s0)
    80004cf2:	bfc5                	j	80004ce2 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004cf4:	4641                	li	a2,16
    80004cf6:	df043583          	ld	a1,-528(s0)
    80004cfa:	15898513          	addi	a0,s3,344
    80004cfe:	93efc0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004d02:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004d06:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004d0a:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004d0e:	0589b783          	ld	a5,88(s3)
    80004d12:	e6843703          	ld	a4,-408(s0)
    80004d16:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004d18:	0589b783          	ld	a5,88(s3)
    80004d1c:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004d20:	85d6                	mv	a1,s5
    80004d22:	f63fc0ef          	jal	80001c84 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004d26:	0004851b          	sext.w	a0,s1
    80004d2a:	79fe                	ld	s3,504(sp)
    80004d2c:	7a5e                	ld	s4,496(sp)
    80004d2e:	7abe                	ld	s5,488(sp)
    80004d30:	7b1e                	ld	s6,480(sp)
    80004d32:	6bfe                	ld	s7,472(sp)
    80004d34:	6c5e                	ld	s8,464(sp)
    80004d36:	6cbe                	ld	s9,456(sp)
    80004d38:	6d1e                	ld	s10,448(sp)
    80004d3a:	bbb9                	j	80004a98 <kexec+0x72>
    80004d3c:	7b1e                	ld	s6,480(sp)
    80004d3e:	b3b1                	j	80004a8a <kexec+0x64>
    80004d40:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004d44:	df843583          	ld	a1,-520(s0)
    80004d48:	855a                	mv	a0,s6
    80004d4a:	f3bfc0ef          	jal	80001c84 <proc_freepagetable>
  if (ip) {
    80004d4e:	79fe                	ld	s3,504(sp)
    80004d50:	7abe                	ld	s5,488(sp)
    80004d52:	7b1e                	ld	s6,480(sp)
    80004d54:	6bfe                	ld	s7,472(sp)
    80004d56:	6c5e                	ld	s8,464(sp)
    80004d58:	6cbe                	ld	s9,456(sp)
    80004d5a:	6d1e                	ld	s10,448(sp)
    80004d5c:	7dfa                	ld	s11,440(sp)
    80004d5e:	b335                	j	80004a8a <kexec+0x64>
    80004d60:	df243c23          	sd	s2,-520(s0)
    80004d64:	b7c5                	j	80004d44 <kexec+0x31e>
    80004d66:	df243c23          	sd	s2,-520(s0)
    80004d6a:	bfe9                	j	80004d44 <kexec+0x31e>
    80004d6c:	df243c23          	sd	s2,-520(s0)
    80004d70:	bfd1                	j	80004d44 <kexec+0x31e>
    80004d72:	df243c23          	sd	s2,-520(s0)
    80004d76:	b7f9                	j	80004d44 <kexec+0x31e>
  sz = sz1;
    80004d78:	8c4a                	mv	s8,s2
    80004d7a:	b549                	j	80004bfc <kexec+0x1d6>
    80004d7c:	8c4a                	mv	s8,s2
    80004d7e:	bdbd                	j	80004bfc <kexec+0x1d6>

0000000080004d80 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004d80:	7179                	addi	sp,sp,-48
    80004d82:	f406                	sd	ra,40(sp)
    80004d84:	f022                	sd	s0,32(sp)
    80004d86:	ec26                	sd	s1,24(sp)
    80004d88:	e84a                	sd	s2,16(sp)
    80004d8a:	1800                	addi	s0,sp,48
    80004d8c:	892e                	mv	s2,a1
    80004d8e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d90:	fdc40593          	addi	a1,s0,-36
    80004d94:	caffd0ef          	jal	80002a42 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004d98:	fdc42703          	lw	a4,-36(s0)
    80004d9c:	47bd                	li	a5,15
    80004d9e:	02e7ea63          	bltu	a5,a4,80004dd2 <argfd+0x52>
    80004da2:	d59fc0ef          	jal	80001afa <myproc>
    80004da6:	fdc42703          	lw	a4,-36(s0)
    80004daa:	00371793          	slli	a5,a4,0x3
    80004dae:	0d078793          	addi	a5,a5,208
    80004db2:	953e                	add	a0,a0,a5
    80004db4:	611c                	ld	a5,0(a0)
    80004db6:	c385                	beqz	a5,80004dd6 <argfd+0x56>
    return -1;
  if (pfd)
    80004db8:	00090463          	beqz	s2,80004dc0 <argfd+0x40>
    *pfd = fd;
    80004dbc:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004dc0:	4501                	li	a0,0
  if (pf)
    80004dc2:	c091                	beqz	s1,80004dc6 <argfd+0x46>
    *pf = f;
    80004dc4:	e09c                	sd	a5,0(s1)
}
    80004dc6:	70a2                	ld	ra,40(sp)
    80004dc8:	7402                	ld	s0,32(sp)
    80004dca:	64e2                	ld	s1,24(sp)
    80004dcc:	6942                	ld	s2,16(sp)
    80004dce:	6145                	addi	sp,sp,48
    80004dd0:	8082                	ret
    return -1;
    80004dd2:	557d                	li	a0,-1
    80004dd4:	bfcd                	j	80004dc6 <argfd+0x46>
    80004dd6:	557d                	li	a0,-1
    80004dd8:	b7fd                	j	80004dc6 <argfd+0x46>

0000000080004dda <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004dda:	1101                	addi	sp,sp,-32
    80004ddc:	ec06                	sd	ra,24(sp)
    80004dde:	e822                	sd	s0,16(sp)
    80004de0:	e426                	sd	s1,8(sp)
    80004de2:	1000                	addi	s0,sp,32
    80004de4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004de6:	d15fc0ef          	jal	80001afa <myproc>
    80004dea:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004dec:	0d050793          	addi	a5,a0,208
    80004df0:	4501                	li	a0,0
    80004df2:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004df4:	6398                	ld	a4,0(a5)
    80004df6:	cb19                	beqz	a4,80004e0c <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004df8:	2505                	addiw	a0,a0,1
    80004dfa:	07a1                	addi	a5,a5,8
    80004dfc:	fed51ce3          	bne	a0,a3,80004df4 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004e00:	557d                	li	a0,-1
}
    80004e02:	60e2                	ld	ra,24(sp)
    80004e04:	6442                	ld	s0,16(sp)
    80004e06:	64a2                	ld	s1,8(sp)
    80004e08:	6105                	addi	sp,sp,32
    80004e0a:	8082                	ret
      p->ofile[fd] = f;
    80004e0c:	00351793          	slli	a5,a0,0x3
    80004e10:	0d078793          	addi	a5,a5,208
    80004e14:	963e                	add	a2,a2,a5
    80004e16:	e204                	sd	s1,0(a2)
      return fd;
    80004e18:	b7ed                	j	80004e02 <fdalloc+0x28>

0000000080004e1a <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004e1a:	715d                	addi	sp,sp,-80
    80004e1c:	e486                	sd	ra,72(sp)
    80004e1e:	e0a2                	sd	s0,64(sp)
    80004e20:	fc26                	sd	s1,56(sp)
    80004e22:	f84a                	sd	s2,48(sp)
    80004e24:	f052                	sd	s4,32(sp)
    80004e26:	ec56                	sd	s5,24(sp)
    80004e28:	e85a                	sd	s6,16(sp)
    80004e2a:	0880                	addi	s0,sp,80
    80004e2c:	8a2e                	mv	s4,a1
    80004e2e:	8ab2                	mv	s5,a2
    80004e30:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004e32:	fb040593          	addi	a1,s0,-80
    80004e36:	eb5fe0ef          	jal	80003cea <nameiparent>
    80004e3a:	84aa                	mv	s1,a0
    80004e3c:	12050f63          	beqz	a0,80004f7a <create+0x160>
    return 0;

  ilock(dp);
    80004e40:	df6fe0ef          	jal	80003436 <ilock>

  if (dp->nlink == 0) {
    80004e44:	04a49783          	lh	a5,74(s1)
    80004e48:	cbb9                	beqz	a5,80004e9e <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004e4a:	7761                	lui	a4,0xffff8
    80004e4c:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd47f9>
    80004e4e:	97ba                	add	a5,a5,a4
    80004e50:	e781                	bnez	a5,80004e58 <create+0x3e>
    80004e52:	fffa0793          	addi	a5,s4,-1
    80004e56:	cba9                	beqz	a5,80004ea8 <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004e58:	4601                	li	a2,0
    80004e5a:	fb040593          	addi	a1,s0,-80
    80004e5e:	8526                	mv	a0,s1
    80004e60:	bbffe0ef          	jal	80003a1e <dirlookup>
    80004e64:	892a                	mv	s2,a0
    80004e66:	c939                	beqz	a0,80004ebc <create+0xa2>
    iunlockput(dp);
    80004e68:	8526                	mv	a0,s1
    80004e6a:	821fe0ef          	jal	8000368a <iunlockput>
    ilock(ip);
    80004e6e:	854a                	mv	a0,s2
    80004e70:	dc6fe0ef          	jal	80003436 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004e74:	4789                	li	a5,2
    80004e76:	02fa1e63          	bne	s4,a5,80004eb2 <create+0x98>
    80004e7a:	04495783          	lhu	a5,68(s2)
    80004e7e:	37f9                	addiw	a5,a5,-2
    80004e80:	17c2                	slli	a5,a5,0x30
    80004e82:	93c1                	srli	a5,a5,0x30
    80004e84:	4705                	li	a4,1
    80004e86:	02f76663          	bltu	a4,a5,80004eb2 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004e8a:	854a                	mv	a0,s2
    80004e8c:	60a6                	ld	ra,72(sp)
    80004e8e:	6406                	ld	s0,64(sp)
    80004e90:	74e2                	ld	s1,56(sp)
    80004e92:	7942                	ld	s2,48(sp)
    80004e94:	7a02                	ld	s4,32(sp)
    80004e96:	6ae2                	ld	s5,24(sp)
    80004e98:	6b42                	ld	s6,16(sp)
    80004e9a:	6161                	addi	sp,sp,80
    80004e9c:	8082                	ret
    iunlockput(dp);
    80004e9e:	8526                	mv	a0,s1
    80004ea0:	feafe0ef          	jal	8000368a <iunlockput>
    return 0;
    80004ea4:	4901                	li	s2,0
    80004ea6:	b7d5                	j	80004e8a <create+0x70>
    iunlockput(dp);
    80004ea8:	8526                	mv	a0,s1
    80004eaa:	fe0fe0ef          	jal	8000368a <iunlockput>
    return 0;
    80004eae:	4901                	li	s2,0
    80004eb0:	bfe9                	j	80004e8a <create+0x70>
    iunlockput(ip);
    80004eb2:	854a                	mv	a0,s2
    80004eb4:	fd6fe0ef          	jal	8000368a <iunlockput>
    return 0;
    80004eb8:	4901                	li	s2,0
    80004eba:	bfc1                	j	80004e8a <create+0x70>
    80004ebc:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004ebe:	85d2                	mv	a1,s4
    80004ec0:	4088                	lw	a0,0(s1)
    80004ec2:	c04fe0ef          	jal	800032c6 <ialloc>
    80004ec6:	89aa                	mv	s3,a0
    80004ec8:	cd1d                	beqz	a0,80004f06 <create+0xec>
  ilock(ip);
    80004eca:	d6cfe0ef          	jal	80003436 <ilock>
  ip->major = major;
    80004ece:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004ed2:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004ed6:	4705                	li	a4,1
    80004ed8:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004edc:	854e                	mv	a0,s3
    80004ede:	ca4fe0ef          	jal	80003382 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004ee2:	4705                	li	a4,1
    80004ee4:	02ea0763          	beq	s4,a4,80004f12 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004ee8:	0049a603          	lw	a2,4(s3)
    80004eec:	fb040593          	addi	a1,s0,-80
    80004ef0:	8526                	mv	a0,s1
    80004ef2:	d35fe0ef          	jal	80003c26 <dirlink>
    80004ef6:	06054563          	bltz	a0,80004f60 <create+0x146>
  iunlockput(dp);
    80004efa:	8526                	mv	a0,s1
    80004efc:	f8efe0ef          	jal	8000368a <iunlockput>
  return ip;
    80004f00:	894e                	mv	s2,s3
    80004f02:	79a2                	ld	s3,40(sp)
    80004f04:	b759                	j	80004e8a <create+0x70>
    iunlockput(dp);
    80004f06:	8526                	mv	a0,s1
    80004f08:	f82fe0ef          	jal	8000368a <iunlockput>
    return 0;
    80004f0c:	894e                	mv	s2,s3
    80004f0e:	79a2                	ld	s3,40(sp)
    80004f10:	bfad                	j	80004e8a <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004f12:	0049a603          	lw	a2,4(s3)
    80004f16:	00003597          	auipc	a1,0x3
    80004f1a:	84a58593          	addi	a1,a1,-1974 # 80007760 <etext+0x760>
    80004f1e:	854e                	mv	a0,s3
    80004f20:	d07fe0ef          	jal	80003c26 <dirlink>
    80004f24:	02054e63          	bltz	a0,80004f60 <create+0x146>
    80004f28:	40d0                	lw	a2,4(s1)
    80004f2a:	00003597          	auipc	a1,0x3
    80004f2e:	83e58593          	addi	a1,a1,-1986 # 80007768 <etext+0x768>
    80004f32:	854e                	mv	a0,s3
    80004f34:	cf3fe0ef          	jal	80003c26 <dirlink>
    80004f38:	02054463          	bltz	a0,80004f60 <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004f3c:	0049a603          	lw	a2,4(s3)
    80004f40:	fb040593          	addi	a1,s0,-80
    80004f44:	8526                	mv	a0,s1
    80004f46:	ce1fe0ef          	jal	80003c26 <dirlink>
    80004f4a:	00054b63          	bltz	a0,80004f60 <create+0x146>
    dp->nlink++; // for ".."
    80004f4e:	04a4d783          	lhu	a5,74(s1)
    80004f52:	2785                	addiw	a5,a5,1
    80004f54:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f58:	8526                	mv	a0,s1
    80004f5a:	c28fe0ef          	jal	80003382 <iupdate>
    80004f5e:	bf71                	j	80004efa <create+0xe0>
  ip->nlink = 0;
    80004f60:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004f64:	854e                	mv	a0,s3
    80004f66:	c1cfe0ef          	jal	80003382 <iupdate>
  iunlockput(ip);
    80004f6a:	854e                	mv	a0,s3
    80004f6c:	f1efe0ef          	jal	8000368a <iunlockput>
  iunlockput(dp);
    80004f70:	8526                	mv	a0,s1
    80004f72:	f18fe0ef          	jal	8000368a <iunlockput>
  return 0;
    80004f76:	79a2                	ld	s3,40(sp)
    80004f78:	bf09                	j	80004e8a <create+0x70>
    return 0;
    80004f7a:	892a                	mv	s2,a0
    80004f7c:	b739                	j	80004e8a <create+0x70>

0000000080004f7e <sys_dup>:
{
    80004f7e:	7179                	addi	sp,sp,-48
    80004f80:	f406                	sd	ra,40(sp)
    80004f82:	f022                	sd	s0,32(sp)
    80004f84:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004f86:	fd840613          	addi	a2,s0,-40
    80004f8a:	4581                	li	a1,0
    80004f8c:	4501                	li	a0,0
    80004f8e:	df3ff0ef          	jal	80004d80 <argfd>
    return -1;
    80004f92:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004f94:	02054363          	bltz	a0,80004fba <sys_dup+0x3c>
    80004f98:	ec26                	sd	s1,24(sp)
    80004f9a:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004f9c:	fd843483          	ld	s1,-40(s0)
    80004fa0:	8526                	mv	a0,s1
    80004fa2:	e39ff0ef          	jal	80004dda <fdalloc>
    80004fa6:	892a                	mv	s2,a0
    return -1;
    80004fa8:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004faa:	00054d63          	bltz	a0,80004fc4 <sys_dup+0x46>
  filedup(f);
    80004fae:	8526                	mv	a0,s1
    80004fb0:	b72ff0ef          	jal	80004322 <filedup>
  return fd;
    80004fb4:	87ca                	mv	a5,s2
    80004fb6:	64e2                	ld	s1,24(sp)
    80004fb8:	6942                	ld	s2,16(sp)
}
    80004fba:	853e                	mv	a0,a5
    80004fbc:	70a2                	ld	ra,40(sp)
    80004fbe:	7402                	ld	s0,32(sp)
    80004fc0:	6145                	addi	sp,sp,48
    80004fc2:	8082                	ret
    80004fc4:	64e2                	ld	s1,24(sp)
    80004fc6:	6942                	ld	s2,16(sp)
    80004fc8:	bfcd                	j	80004fba <sys_dup+0x3c>

0000000080004fca <sys_read>:
{
    80004fca:	7179                	addi	sp,sp,-48
    80004fcc:	f406                	sd	ra,40(sp)
    80004fce:	f022                	sd	s0,32(sp)
    80004fd0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fd2:	fd840593          	addi	a1,s0,-40
    80004fd6:	4505                	li	a0,1
    80004fd8:	a87fd0ef          	jal	80002a5e <argaddr>
  argint(2, &n);
    80004fdc:	fe440593          	addi	a1,s0,-28
    80004fe0:	4509                	li	a0,2
    80004fe2:	a61fd0ef          	jal	80002a42 <argint>
  if (argfd(0, 0, &f) < 0)
    80004fe6:	fe840613          	addi	a2,s0,-24
    80004fea:	4581                	li	a1,0
    80004fec:	4501                	li	a0,0
    80004fee:	d93ff0ef          	jal	80004d80 <argfd>
    80004ff2:	87aa                	mv	a5,a0
    return -1;
    80004ff4:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004ff6:	0007ca63          	bltz	a5,8000500a <sys_read+0x40>
  return fileread(f, p, n);
    80004ffa:	fe442603          	lw	a2,-28(s0)
    80004ffe:	fd843583          	ld	a1,-40(s0)
    80005002:	fe843503          	ld	a0,-24(s0)
    80005006:	c94ff0ef          	jal	8000449a <fileread>
}
    8000500a:	70a2                	ld	ra,40(sp)
    8000500c:	7402                	ld	s0,32(sp)
    8000500e:	6145                	addi	sp,sp,48
    80005010:	8082                	ret

0000000080005012 <sys_write>:
{
    80005012:	7179                	addi	sp,sp,-48
    80005014:	f406                	sd	ra,40(sp)
    80005016:	f022                	sd	s0,32(sp)
    80005018:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000501a:	fd840593          	addi	a1,s0,-40
    8000501e:	4505                	li	a0,1
    80005020:	a3ffd0ef          	jal	80002a5e <argaddr>
  argint(2, &n);
    80005024:	fe440593          	addi	a1,s0,-28
    80005028:	4509                	li	a0,2
    8000502a:	a19fd0ef          	jal	80002a42 <argint>
  if (argfd(0, 0, &f) < 0)
    8000502e:	fe840613          	addi	a2,s0,-24
    80005032:	4581                	li	a1,0
    80005034:	4501                	li	a0,0
    80005036:	d4bff0ef          	jal	80004d80 <argfd>
    8000503a:	87aa                	mv	a5,a0
    return -1;
    8000503c:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    8000503e:	0007ca63          	bltz	a5,80005052 <sys_write+0x40>
  return filewrite(f, p, n);
    80005042:	fe442603          	lw	a2,-28(s0)
    80005046:	fd843583          	ld	a1,-40(s0)
    8000504a:	fe843503          	ld	a0,-24(s0)
    8000504e:	d1aff0ef          	jal	80004568 <filewrite>
}
    80005052:	70a2                	ld	ra,40(sp)
    80005054:	7402                	ld	s0,32(sp)
    80005056:	6145                	addi	sp,sp,48
    80005058:	8082                	ret

000000008000505a <sys_close>:
{
    8000505a:	1101                	addi	sp,sp,-32
    8000505c:	ec06                	sd	ra,24(sp)
    8000505e:	e822                	sd	s0,16(sp)
    80005060:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80005062:	fe040613          	addi	a2,s0,-32
    80005066:	fec40593          	addi	a1,s0,-20
    8000506a:	4501                	li	a0,0
    8000506c:	d15ff0ef          	jal	80004d80 <argfd>
    return -1;
    80005070:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80005072:	02054163          	bltz	a0,80005094 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80005076:	a85fc0ef          	jal	80001afa <myproc>
    8000507a:	fec42783          	lw	a5,-20(s0)
    8000507e:	078e                	slli	a5,a5,0x3
    80005080:	0d078793          	addi	a5,a5,208
    80005084:	953e                	add	a0,a0,a5
    80005086:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000508a:	fe043503          	ld	a0,-32(s0)
    8000508e:	adaff0ef          	jal	80004368 <fileclose>
  return 0;
    80005092:	4781                	li	a5,0
}
    80005094:	853e                	mv	a0,a5
    80005096:	60e2                	ld	ra,24(sp)
    80005098:	6442                	ld	s0,16(sp)
    8000509a:	6105                	addi	sp,sp,32
    8000509c:	8082                	ret

000000008000509e <sys_fstat>:
{
    8000509e:	1101                	addi	sp,sp,-32
    800050a0:	ec06                	sd	ra,24(sp)
    800050a2:	e822                	sd	s0,16(sp)
    800050a4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800050a6:	fe040593          	addi	a1,s0,-32
    800050aa:	4505                	li	a0,1
    800050ac:	9b3fd0ef          	jal	80002a5e <argaddr>
  if (argfd(0, 0, &f) < 0)
    800050b0:	fe840613          	addi	a2,s0,-24
    800050b4:	4581                	li	a1,0
    800050b6:	4501                	li	a0,0
    800050b8:	cc9ff0ef          	jal	80004d80 <argfd>
    800050bc:	87aa                	mv	a5,a0
    return -1;
    800050be:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800050c0:	0007c863          	bltz	a5,800050d0 <sys_fstat+0x32>
  return filestat(f, st);
    800050c4:	fe043583          	ld	a1,-32(s0)
    800050c8:	fe843503          	ld	a0,-24(s0)
    800050cc:	b5eff0ef          	jal	8000442a <filestat>
}
    800050d0:	60e2                	ld	ra,24(sp)
    800050d2:	6442                	ld	s0,16(sp)
    800050d4:	6105                	addi	sp,sp,32
    800050d6:	8082                	ret

00000000800050d8 <sys_link>:
{
    800050d8:	7169                	addi	sp,sp,-304
    800050da:	f606                	sd	ra,296(sp)
    800050dc:	f222                	sd	s0,288(sp)
    800050de:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050e0:	08000613          	li	a2,128
    800050e4:	ed040593          	addi	a1,s0,-304
    800050e8:	4501                	li	a0,0
    800050ea:	991fd0ef          	jal	80002a7a <argstr>
    return -1;
    800050ee:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050f0:	10054163          	bltz	a0,800051f2 <sys_link+0x11a>
    800050f4:	08000613          	li	a2,128
    800050f8:	f5040593          	addi	a1,s0,-176
    800050fc:	4505                	li	a0,1
    800050fe:	97dfd0ef          	jal	80002a7a <argstr>
    return -1;
    80005102:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005104:	0e054763          	bltz	a0,800051f2 <sys_link+0x11a>
    80005108:	ee26                	sd	s1,280(sp)
  begin_op();
    8000510a:	da5fe0ef          	jal	80003eae <begin_op>
  if ((ip = namei(old)) == 0) {
    8000510e:	ed040513          	addi	a0,s0,-304
    80005112:	bbffe0ef          	jal	80003cd0 <namei>
    80005116:	84aa                	mv	s1,a0
    80005118:	cd35                	beqz	a0,80005194 <sys_link+0xbc>
  ilock(ip);
    8000511a:	b1cfe0ef          	jal	80003436 <ilock>
  if (ip->type == T_DIR) {
    8000511e:	04449703          	lh	a4,68(s1)
    80005122:	4785                	li	a5,1
    80005124:	06f70d63          	beq	a4,a5,8000519e <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80005128:	04a49783          	lh	a5,74(s1)
    8000512c:	6721                	lui	a4,0x8
    8000512e:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80005130:	06e78f63          	beq	a5,a4,800051ae <sys_link+0xd6>
    80005134:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005136:	2785                	addiw	a5,a5,1
    80005138:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000513c:	8526                	mv	a0,s1
    8000513e:	a44fe0ef          	jal	80003382 <iupdate>
  iunlock(ip);
    80005142:	8526                	mv	a0,s1
    80005144:	ba0fe0ef          	jal	800034e4 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80005148:	fd040593          	addi	a1,s0,-48
    8000514c:	f5040513          	addi	a0,s0,-176
    80005150:	b9bfe0ef          	jal	80003cea <nameiparent>
    80005154:	892a                	mv	s2,a0
    80005156:	c93d                	beqz	a0,800051cc <sys_link+0xf4>
  ilock(dp);
    80005158:	adefe0ef          	jal	80003436 <ilock>
  if (dp->nlink == 0) {
    8000515c:	04a91783          	lh	a5,74(s2)
    80005160:	cfb9                	beqz	a5,800051be <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80005162:	854a                	mv	a0,s2
    80005164:	00092703          	lw	a4,0(s2)
    80005168:	409c                	lw	a5,0(s1)
    8000516a:	04f71e63          	bne	a4,a5,800051c6 <sys_link+0xee>
    8000516e:	40d0                	lw	a2,4(s1)
    80005170:	fd040593          	addi	a1,s0,-48
    80005174:	ab3fe0ef          	jal	80003c26 <dirlink>
    80005178:	04054763          	bltz	a0,800051c6 <sys_link+0xee>
  iunlockput(dp);
    8000517c:	854a                	mv	a0,s2
    8000517e:	d0cfe0ef          	jal	8000368a <iunlockput>
  iput(ip);
    80005182:	8526                	mv	a0,s1
    80005184:	c34fe0ef          	jal	800035b8 <iput>
  end_op();
    80005188:	db3fe0ef          	jal	80003f3a <end_op>
  return 0;
    8000518c:	4781                	li	a5,0
    8000518e:	64f2                	ld	s1,280(sp)
    80005190:	6952                	ld	s2,272(sp)
    80005192:	a085                	j	800051f2 <sys_link+0x11a>
    end_op();
    80005194:	da7fe0ef          	jal	80003f3a <end_op>
    return -1;
    80005198:	57fd                	li	a5,-1
    8000519a:	64f2                	ld	s1,280(sp)
    8000519c:	a899                	j	800051f2 <sys_link+0x11a>
    iunlockput(ip);
    8000519e:	8526                	mv	a0,s1
    800051a0:	ceafe0ef          	jal	8000368a <iunlockput>
    end_op();
    800051a4:	d97fe0ef          	jal	80003f3a <end_op>
    return -1;
    800051a8:	57fd                	li	a5,-1
    800051aa:	64f2                	ld	s1,280(sp)
    800051ac:	a099                	j	800051f2 <sys_link+0x11a>
    iunlockput(ip);
    800051ae:	8526                	mv	a0,s1
    800051b0:	cdafe0ef          	jal	8000368a <iunlockput>
    end_op();
    800051b4:	d87fe0ef          	jal	80003f3a <end_op>
    return -1;
    800051b8:	57fd                	li	a5,-1
    800051ba:	64f2                	ld	s1,280(sp)
    800051bc:	a81d                	j	800051f2 <sys_link+0x11a>
    iunlockput(dp);
    800051be:	854a                	mv	a0,s2
    800051c0:	ccafe0ef          	jal	8000368a <iunlockput>
    goto bad;
    800051c4:	a021                	j	800051cc <sys_link+0xf4>
    iunlockput(dp);
    800051c6:	854a                	mv	a0,s2
    800051c8:	cc2fe0ef          	jal	8000368a <iunlockput>
  ilock(ip);
    800051cc:	8526                	mv	a0,s1
    800051ce:	a68fe0ef          	jal	80003436 <ilock>
  ip->nlink--;
    800051d2:	04a4d783          	lhu	a5,74(s1)
    800051d6:	37fd                	addiw	a5,a5,-1
    800051d8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800051dc:	8526                	mv	a0,s1
    800051de:	9a4fe0ef          	jal	80003382 <iupdate>
  iunlockput(ip);
    800051e2:	8526                	mv	a0,s1
    800051e4:	ca6fe0ef          	jal	8000368a <iunlockput>
  end_op();
    800051e8:	d53fe0ef          	jal	80003f3a <end_op>
  return -1;
    800051ec:	57fd                	li	a5,-1
    800051ee:	64f2                	ld	s1,280(sp)
    800051f0:	6952                	ld	s2,272(sp)
}
    800051f2:	853e                	mv	a0,a5
    800051f4:	70b2                	ld	ra,296(sp)
    800051f6:	7412                	ld	s0,288(sp)
    800051f8:	6155                	addi	sp,sp,304
    800051fa:	8082                	ret

00000000800051fc <sys_unlink>:
{
    800051fc:	7151                	addi	sp,sp,-240
    800051fe:	f586                	sd	ra,232(sp)
    80005200:	f1a2                	sd	s0,224(sp)
    80005202:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005204:	08000613          	li	a2,128
    80005208:	f3040593          	addi	a1,s0,-208
    8000520c:	4501                	li	a0,0
    8000520e:	86dfd0ef          	jal	80002a7a <argstr>
    80005212:	14054d63          	bltz	a0,8000536c <sys_unlink+0x170>
    80005216:	eda6                	sd	s1,216(sp)
  begin_op();
    80005218:	c97fe0ef          	jal	80003eae <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    8000521c:	fb040593          	addi	a1,s0,-80
    80005220:	f3040513          	addi	a0,s0,-208
    80005224:	ac7fe0ef          	jal	80003cea <nameiparent>
    80005228:	84aa                	mv	s1,a0
    8000522a:	c955                	beqz	a0,800052de <sys_unlink+0xe2>
  ilock(dp);
    8000522c:	a0afe0ef          	jal	80003436 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005230:	00002597          	auipc	a1,0x2
    80005234:	53058593          	addi	a1,a1,1328 # 80007760 <etext+0x760>
    80005238:	fb040513          	addi	a0,s0,-80
    8000523c:	fccfe0ef          	jal	80003a08 <namecmp>
    80005240:	10050b63          	beqz	a0,80005356 <sys_unlink+0x15a>
    80005244:	00002597          	auipc	a1,0x2
    80005248:	52458593          	addi	a1,a1,1316 # 80007768 <etext+0x768>
    8000524c:	fb040513          	addi	a0,s0,-80
    80005250:	fb8fe0ef          	jal	80003a08 <namecmp>
    80005254:	10050163          	beqz	a0,80005356 <sys_unlink+0x15a>
    80005258:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    8000525a:	f2c40613          	addi	a2,s0,-212
    8000525e:	fb040593          	addi	a1,s0,-80
    80005262:	8526                	mv	a0,s1
    80005264:	fbafe0ef          	jal	80003a1e <dirlookup>
    80005268:	892a                	mv	s2,a0
    8000526a:	0e050563          	beqz	a0,80005354 <sys_unlink+0x158>
    8000526e:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005270:	9c6fe0ef          	jal	80003436 <ilock>
  if (ip->nlink < 1)
    80005274:	04a91783          	lh	a5,74(s2)
    80005278:	06f05863          	blez	a5,800052e8 <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    8000527c:	04491703          	lh	a4,68(s2)
    80005280:	4785                	li	a5,1
    80005282:	06f70963          	beq	a4,a5,800052f4 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005286:	fc040993          	addi	s3,s0,-64
    8000528a:	4641                	li	a2,16
    8000528c:	4581                	li	a1,0
    8000528e:	854e                	mv	a0,s3
    80005290:	a59fb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005294:	4741                	li	a4,16
    80005296:	f2c42683          	lw	a3,-212(s0)
    8000529a:	864e                	mv	a2,s3
    8000529c:	4581                	li	a1,0
    8000529e:	8526                	mv	a0,s1
    800052a0:	e62fe0ef          	jal	80003902 <writei>
    800052a4:	47c1                	li	a5,16
    800052a6:	08f51863          	bne	a0,a5,80005336 <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    800052aa:	04491703          	lh	a4,68(s2)
    800052ae:	4785                	li	a5,1
    800052b0:	08f70963          	beq	a4,a5,80005342 <sys_unlink+0x146>
  iunlockput(dp);
    800052b4:	8526                	mv	a0,s1
    800052b6:	bd4fe0ef          	jal	8000368a <iunlockput>
  ip->nlink--;
    800052ba:	04a95783          	lhu	a5,74(s2)
    800052be:	37fd                	addiw	a5,a5,-1
    800052c0:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800052c4:	854a                	mv	a0,s2
    800052c6:	8bcfe0ef          	jal	80003382 <iupdate>
  iunlockput(ip);
    800052ca:	854a                	mv	a0,s2
    800052cc:	bbefe0ef          	jal	8000368a <iunlockput>
  end_op();
    800052d0:	c6bfe0ef          	jal	80003f3a <end_op>
  return 0;
    800052d4:	4501                	li	a0,0
    800052d6:	64ee                	ld	s1,216(sp)
    800052d8:	694e                	ld	s2,208(sp)
    800052da:	69ae                	ld	s3,200(sp)
    800052dc:	a061                	j	80005364 <sys_unlink+0x168>
    end_op();
    800052de:	c5dfe0ef          	jal	80003f3a <end_op>
    return -1;
    800052e2:	557d                	li	a0,-1
    800052e4:	64ee                	ld	s1,216(sp)
    800052e6:	a8bd                	j	80005364 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800052e8:	00002517          	auipc	a0,0x2
    800052ec:	48850513          	addi	a0,a0,1160 # 80007770 <etext+0x770>
    800052f0:	d44fb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800052f4:	04c92703          	lw	a4,76(s2)
    800052f8:	02000793          	li	a5,32
    800052fc:	f8e7f5e3          	bgeu	a5,a4,80005286 <sys_unlink+0x8a>
    80005300:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005302:	4741                	li	a4,16
    80005304:	86ce                	mv	a3,s3
    80005306:	f1840613          	addi	a2,s0,-232
    8000530a:	4581                	li	a1,0
    8000530c:	854a                	mv	a0,s2
    8000530e:	d02fe0ef          	jal	80003810 <readi>
    80005312:	47c1                	li	a5,16
    80005314:	00f51b63          	bne	a0,a5,8000532a <sys_unlink+0x12e>
    if (de.inum != 0)
    80005318:	f1845783          	lhu	a5,-232(s0)
    8000531c:	ebb1                	bnez	a5,80005370 <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000531e:	29c1                	addiw	s3,s3,16
    80005320:	04c92783          	lw	a5,76(s2)
    80005324:	fcf9efe3          	bltu	s3,a5,80005302 <sys_unlink+0x106>
    80005328:	bfb9                	j	80005286 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000532a:	00002517          	auipc	a0,0x2
    8000532e:	45e50513          	addi	a0,a0,1118 # 80007788 <etext+0x788>
    80005332:	d02fb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    80005336:	00002517          	auipc	a0,0x2
    8000533a:	46a50513          	addi	a0,a0,1130 # 800077a0 <etext+0x7a0>
    8000533e:	cf6fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    80005342:	04a4d783          	lhu	a5,74(s1)
    80005346:	37fd                	addiw	a5,a5,-1
    80005348:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000534c:	8526                	mv	a0,s1
    8000534e:	834fe0ef          	jal	80003382 <iupdate>
    80005352:	b78d                	j	800052b4 <sys_unlink+0xb8>
    80005354:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005356:	8526                	mv	a0,s1
    80005358:	b32fe0ef          	jal	8000368a <iunlockput>
  end_op();
    8000535c:	bdffe0ef          	jal	80003f3a <end_op>
  return -1;
    80005360:	557d                	li	a0,-1
    80005362:	64ee                	ld	s1,216(sp)
}
    80005364:	70ae                	ld	ra,232(sp)
    80005366:	740e                	ld	s0,224(sp)
    80005368:	616d                	addi	sp,sp,240
    8000536a:	8082                	ret
    return -1;
    8000536c:	557d                	li	a0,-1
    8000536e:	bfdd                	j	80005364 <sys_unlink+0x168>
    iunlockput(ip);
    80005370:	854a                	mv	a0,s2
    80005372:	b18fe0ef          	jal	8000368a <iunlockput>
    goto bad;
    80005376:	694e                	ld	s2,208(sp)
    80005378:	69ae                	ld	s3,200(sp)
    8000537a:	bff1                	j	80005356 <sys_unlink+0x15a>

000000008000537c <sys_open>:

uint64
sys_open(void)
{
    8000537c:	7131                	addi	sp,sp,-192
    8000537e:	fd06                	sd	ra,184(sp)
    80005380:	f922                	sd	s0,176(sp)
    80005382:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005384:	f4c40593          	addi	a1,s0,-180
    80005388:	4505                	li	a0,1
    8000538a:	eb8fd0ef          	jal	80002a42 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000538e:	08000613          	li	a2,128
    80005392:	f5040593          	addi	a1,s0,-176
    80005396:	4501                	li	a0,0
    80005398:	ee2fd0ef          	jal	80002a7a <argstr>
    8000539c:	87aa                	mv	a5,a0
    return -1;
    8000539e:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800053a0:	0a07c363          	bltz	a5,80005446 <sys_open+0xca>
    800053a4:	f526                	sd	s1,168(sp)

  begin_op();
    800053a6:	b09fe0ef          	jal	80003eae <begin_op>

  if (omode & O_CREATE) {
    800053aa:	f4c42783          	lw	a5,-180(s0)
    800053ae:	2007f793          	andi	a5,a5,512
    800053b2:	c3dd                	beqz	a5,80005458 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800053b4:	4681                	li	a3,0
    800053b6:	4601                	li	a2,0
    800053b8:	4589                	li	a1,2
    800053ba:	f5040513          	addi	a0,s0,-176
    800053be:	a5dff0ef          	jal	80004e1a <create>
    800053c2:	84aa                	mv	s1,a0
    if (ip == 0) {
    800053c4:	c549                	beqz	a0,8000544e <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    800053c6:	04449703          	lh	a4,68(s1)
    800053ca:	478d                	li	a5,3
    800053cc:	00f71763          	bne	a4,a5,800053da <sys_open+0x5e>
    800053d0:	0464d703          	lhu	a4,70(s1)
    800053d4:	47a5                	li	a5,9
    800053d6:	0ae7ee63          	bltu	a5,a4,80005492 <sys_open+0x116>
    800053da:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    800053dc:	ee9fe0ef          	jal	800042c4 <filealloc>
    800053e0:	892a                	mv	s2,a0
    800053e2:	c561                	beqz	a0,800054aa <sys_open+0x12e>
    800053e4:	ed4e                	sd	s3,152(sp)
    800053e6:	9f5ff0ef          	jal	80004dda <fdalloc>
    800053ea:	89aa                	mv	s3,a0
    800053ec:	0a054b63          	bltz	a0,800054a2 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    800053f0:	04449703          	lh	a4,68(s1)
    800053f4:	478d                	li	a5,3
    800053f6:	0cf70363          	beq	a4,a5,800054bc <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800053fa:	4789                	li	a5,2
    800053fc:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005400:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005404:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005408:	f4c42783          	lw	a5,-180(s0)
    8000540c:	0017f713          	andi	a4,a5,1
    80005410:	00174713          	xori	a4,a4,1
    80005414:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005418:	0037f713          	andi	a4,a5,3
    8000541c:	00e03733          	snez	a4,a4
    80005420:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80005424:	4007f793          	andi	a5,a5,1024
    80005428:	c791                	beqz	a5,80005434 <sys_open+0xb8>
    8000542a:	04449703          	lh	a4,68(s1)
    8000542e:	4789                	li	a5,2
    80005430:	08f70d63          	beq	a4,a5,800054ca <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005434:	8526                	mv	a0,s1
    80005436:	8aefe0ef          	jal	800034e4 <iunlock>
  end_op();
    8000543a:	b01fe0ef          	jal	80003f3a <end_op>

  return fd;
    8000543e:	854e                	mv	a0,s3
    80005440:	74aa                	ld	s1,168(sp)
    80005442:	790a                	ld	s2,160(sp)
    80005444:	69ea                	ld	s3,152(sp)
}
    80005446:	70ea                	ld	ra,184(sp)
    80005448:	744a                	ld	s0,176(sp)
    8000544a:	6129                	addi	sp,sp,192
    8000544c:	8082                	ret
      end_op();
    8000544e:	aedfe0ef          	jal	80003f3a <end_op>
      return -1;
    80005452:	557d                	li	a0,-1
    80005454:	74aa                	ld	s1,168(sp)
    80005456:	bfc5                	j	80005446 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    80005458:	f5040513          	addi	a0,s0,-176
    8000545c:	875fe0ef          	jal	80003cd0 <namei>
    80005460:	84aa                	mv	s1,a0
    80005462:	c11d                	beqz	a0,80005488 <sys_open+0x10c>
    ilock(ip);
    80005464:	fd3fd0ef          	jal	80003436 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    80005468:	04449703          	lh	a4,68(s1)
    8000546c:	4785                	li	a5,1
    8000546e:	f4f71ce3          	bne	a4,a5,800053c6 <sys_open+0x4a>
    80005472:	f4c42783          	lw	a5,-180(s0)
    80005476:	d3b5                	beqz	a5,800053da <sys_open+0x5e>
      iunlockput(ip);
    80005478:	8526                	mv	a0,s1
    8000547a:	a10fe0ef          	jal	8000368a <iunlockput>
      end_op();
    8000547e:	abdfe0ef          	jal	80003f3a <end_op>
      return -1;
    80005482:	557d                	li	a0,-1
    80005484:	74aa                	ld	s1,168(sp)
    80005486:	b7c1                	j	80005446 <sys_open+0xca>
      end_op();
    80005488:	ab3fe0ef          	jal	80003f3a <end_op>
      return -1;
    8000548c:	557d                	li	a0,-1
    8000548e:	74aa                	ld	s1,168(sp)
    80005490:	bf5d                	j	80005446 <sys_open+0xca>
    iunlockput(ip);
    80005492:	8526                	mv	a0,s1
    80005494:	9f6fe0ef          	jal	8000368a <iunlockput>
    end_op();
    80005498:	aa3fe0ef          	jal	80003f3a <end_op>
    return -1;
    8000549c:	557d                	li	a0,-1
    8000549e:	74aa                	ld	s1,168(sp)
    800054a0:	b75d                	j	80005446 <sys_open+0xca>
      fileclose(f);
    800054a2:	854a                	mv	a0,s2
    800054a4:	ec5fe0ef          	jal	80004368 <fileclose>
    800054a8:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800054aa:	8526                	mv	a0,s1
    800054ac:	9defe0ef          	jal	8000368a <iunlockput>
    end_op();
    800054b0:	a8bfe0ef          	jal	80003f3a <end_op>
    return -1;
    800054b4:	557d                	li	a0,-1
    800054b6:	74aa                	ld	s1,168(sp)
    800054b8:	790a                	ld	s2,160(sp)
    800054ba:	b771                	j	80005446 <sys_open+0xca>
    f->type = FD_DEVICE;
    800054bc:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800054c0:	04649783          	lh	a5,70(s1)
    800054c4:	02f91223          	sh	a5,36(s2)
    800054c8:	bf35                	j	80005404 <sys_open+0x88>
    itrunc(ip);
    800054ca:	8526                	mv	a0,s1
    800054cc:	858fe0ef          	jal	80003524 <itrunc>
    800054d0:	b795                	j	80005434 <sys_open+0xb8>

00000000800054d2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800054d2:	7175                	addi	sp,sp,-144
    800054d4:	e506                	sd	ra,136(sp)
    800054d6:	e122                	sd	s0,128(sp)
    800054d8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800054da:	9d5fe0ef          	jal	80003eae <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    800054de:	08000613          	li	a2,128
    800054e2:	f7040593          	addi	a1,s0,-144
    800054e6:	4501                	li	a0,0
    800054e8:	d92fd0ef          	jal	80002a7a <argstr>
    800054ec:	02054363          	bltz	a0,80005512 <sys_mkdir+0x40>
    800054f0:	4681                	li	a3,0
    800054f2:	4601                	li	a2,0
    800054f4:	4585                	li	a1,1
    800054f6:	f7040513          	addi	a0,s0,-144
    800054fa:	921ff0ef          	jal	80004e1a <create>
    800054fe:	c911                	beqz	a0,80005512 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005500:	98afe0ef          	jal	8000368a <iunlockput>
  end_op();
    80005504:	a37fe0ef          	jal	80003f3a <end_op>
  return 0;
    80005508:	4501                	li	a0,0
}
    8000550a:	60aa                	ld	ra,136(sp)
    8000550c:	640a                	ld	s0,128(sp)
    8000550e:	6149                	addi	sp,sp,144
    80005510:	8082                	ret
    end_op();
    80005512:	a29fe0ef          	jal	80003f3a <end_op>
    return -1;
    80005516:	557d                	li	a0,-1
    80005518:	bfcd                	j	8000550a <sys_mkdir+0x38>

000000008000551a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000551a:	7135                	addi	sp,sp,-160
    8000551c:	ed06                	sd	ra,152(sp)
    8000551e:	e922                	sd	s0,144(sp)
    80005520:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005522:	98dfe0ef          	jal	80003eae <begin_op>
  argint(1, &major);
    80005526:	f6c40593          	addi	a1,s0,-148
    8000552a:	4505                	li	a0,1
    8000552c:	d16fd0ef          	jal	80002a42 <argint>
  argint(2, &minor);
    80005530:	f6840593          	addi	a1,s0,-152
    80005534:	4509                	li	a0,2
    80005536:	d0cfd0ef          	jal	80002a42 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    8000553a:	08000613          	li	a2,128
    8000553e:	f7040593          	addi	a1,s0,-144
    80005542:	4501                	li	a0,0
    80005544:	d36fd0ef          	jal	80002a7a <argstr>
    80005548:	02054563          	bltz	a0,80005572 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    8000554c:	f6841683          	lh	a3,-152(s0)
    80005550:	f6c41603          	lh	a2,-148(s0)
    80005554:	458d                	li	a1,3
    80005556:	f7040513          	addi	a0,s0,-144
    8000555a:	8c1ff0ef          	jal	80004e1a <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    8000555e:	c911                	beqz	a0,80005572 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005560:	92afe0ef          	jal	8000368a <iunlockput>
  end_op();
    80005564:	9d7fe0ef          	jal	80003f3a <end_op>
  return 0;
    80005568:	4501                	li	a0,0
}
    8000556a:	60ea                	ld	ra,152(sp)
    8000556c:	644a                	ld	s0,144(sp)
    8000556e:	610d                	addi	sp,sp,160
    80005570:	8082                	ret
    end_op();
    80005572:	9c9fe0ef          	jal	80003f3a <end_op>
    return -1;
    80005576:	557d                	li	a0,-1
    80005578:	bfcd                	j	8000556a <sys_mknod+0x50>

000000008000557a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000557a:	7135                	addi	sp,sp,-160
    8000557c:	ed06                	sd	ra,152(sp)
    8000557e:	e922                	sd	s0,144(sp)
    80005580:	e14a                	sd	s2,128(sp)
    80005582:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005584:	d76fc0ef          	jal	80001afa <myproc>
    80005588:	892a                	mv	s2,a0

  begin_op();
    8000558a:	925fe0ef          	jal	80003eae <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    8000558e:	08000613          	li	a2,128
    80005592:	f6040593          	addi	a1,s0,-160
    80005596:	4501                	li	a0,0
    80005598:	ce2fd0ef          	jal	80002a7a <argstr>
    8000559c:	04054363          	bltz	a0,800055e2 <sys_chdir+0x68>
    800055a0:	e526                	sd	s1,136(sp)
    800055a2:	f6040513          	addi	a0,s0,-160
    800055a6:	f2afe0ef          	jal	80003cd0 <namei>
    800055aa:	84aa                	mv	s1,a0
    800055ac:	c915                	beqz	a0,800055e0 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800055ae:	e89fd0ef          	jal	80003436 <ilock>
  if (ip->type != T_DIR) {
    800055b2:	04449703          	lh	a4,68(s1)
    800055b6:	4785                	li	a5,1
    800055b8:	02f71963          	bne	a4,a5,800055ea <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800055bc:	8526                	mv	a0,s1
    800055be:	f27fd0ef          	jal	800034e4 <iunlock>
  iput(p->cwd);
    800055c2:	15093503          	ld	a0,336(s2)
    800055c6:	ff3fd0ef          	jal	800035b8 <iput>
  end_op();
    800055ca:	971fe0ef          	jal	80003f3a <end_op>
  p->cwd = ip;
    800055ce:	14993823          	sd	s1,336(s2)
  return 0;
    800055d2:	4501                	li	a0,0
    800055d4:	64aa                	ld	s1,136(sp)
}
    800055d6:	60ea                	ld	ra,152(sp)
    800055d8:	644a                	ld	s0,144(sp)
    800055da:	690a                	ld	s2,128(sp)
    800055dc:	610d                	addi	sp,sp,160
    800055de:	8082                	ret
    800055e0:	64aa                	ld	s1,136(sp)
    end_op();
    800055e2:	959fe0ef          	jal	80003f3a <end_op>
    return -1;
    800055e6:	557d                	li	a0,-1
    800055e8:	b7fd                	j	800055d6 <sys_chdir+0x5c>
    iunlockput(ip);
    800055ea:	8526                	mv	a0,s1
    800055ec:	89efe0ef          	jal	8000368a <iunlockput>
    end_op();
    800055f0:	94bfe0ef          	jal	80003f3a <end_op>
    return -1;
    800055f4:	557d                	li	a0,-1
    800055f6:	64aa                	ld	s1,136(sp)
    800055f8:	bff9                	j	800055d6 <sys_chdir+0x5c>

00000000800055fa <sys_exec>:

uint64
sys_exec(void)
{
    800055fa:	7105                	addi	sp,sp,-480
    800055fc:	ef86                	sd	ra,472(sp)
    800055fe:	eba2                	sd	s0,464(sp)
    80005600:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005602:	e2840593          	addi	a1,s0,-472
    80005606:	4505                	li	a0,1
    80005608:	c56fd0ef          	jal	80002a5e <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    8000560c:	08000613          	li	a2,128
    80005610:	f3040593          	addi	a1,s0,-208
    80005614:	4501                	li	a0,0
    80005616:	c64fd0ef          	jal	80002a7a <argstr>
    8000561a:	87aa                	mv	a5,a0
    return -1;
    8000561c:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    8000561e:	0e07c063          	bltz	a5,800056fe <sys_exec+0x104>
    80005622:	e7a6                	sd	s1,456(sp)
    80005624:	e3ca                	sd	s2,448(sp)
    80005626:	ff4e                	sd	s3,440(sp)
    80005628:	fb52                	sd	s4,432(sp)
    8000562a:	f756                	sd	s5,424(sp)
    8000562c:	f35a                	sd	s6,416(sp)
    8000562e:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005630:	e3040a13          	addi	s4,s0,-464
    80005634:	10000613          	li	a2,256
    80005638:	4581                	li	a1,0
    8000563a:	8552                	mv	a0,s4
    8000563c:	eacfb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    80005640:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005642:	89d2                	mv	s3,s4
    80005644:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005646:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000564a:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    8000564c:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005650:	00391513          	slli	a0,s2,0x3
    80005654:	85d6                	mv	a1,s5
    80005656:	e2843783          	ld	a5,-472(s0)
    8000565a:	953e                	add	a0,a0,a5
    8000565c:	b5afd0ef          	jal	800029b6 <fetchaddr>
    80005660:	02054663          	bltz	a0,8000568c <sys_exec+0x92>
    if (uarg == 0) {
    80005664:	e2043783          	ld	a5,-480(s0)
    80005668:	c7a1                	beqz	a5,800056b0 <sys_exec+0xb6>
    argv[i] = kalloc();
    8000566a:	ce4fb0ef          	jal	80000b4e <kalloc>
    8000566e:	85aa                	mv	a1,a0
    80005670:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005674:	cd01                	beqz	a0,8000568c <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005676:	865a                	mv	a2,s6
    80005678:	e2043503          	ld	a0,-480(s0)
    8000567c:	b84fd0ef          	jal	80002a00 <fetchstr>
    80005680:	00054663          	bltz	a0,8000568c <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    80005684:	0905                	addi	s2,s2,1
    80005686:	09a1                	addi	s3,s3,8
    80005688:	fd7914e3          	bne	s2,s7,80005650 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000568c:	100a0a13          	addi	s4,s4,256
    80005690:	6088                	ld	a0,0(s1)
    80005692:	cd31                	beqz	a0,800056ee <sys_exec+0xf4>
    kfree(argv[i]);
    80005694:	bd2fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005698:	04a1                	addi	s1,s1,8
    8000569a:	ff449be3          	bne	s1,s4,80005690 <sys_exec+0x96>
  return -1;
    8000569e:	557d                	li	a0,-1
    800056a0:	64be                	ld	s1,456(sp)
    800056a2:	691e                	ld	s2,448(sp)
    800056a4:	79fa                	ld	s3,440(sp)
    800056a6:	7a5a                	ld	s4,432(sp)
    800056a8:	7aba                	ld	s5,424(sp)
    800056aa:	7b1a                	ld	s6,416(sp)
    800056ac:	6bfa                	ld	s7,408(sp)
    800056ae:	a881                	j	800056fe <sys_exec+0x104>
      argv[i] = 0;
    800056b0:	0009079b          	sext.w	a5,s2
    800056b4:	e3040593          	addi	a1,s0,-464
    800056b8:	078e                	slli	a5,a5,0x3
    800056ba:	97ae                	add	a5,a5,a1
    800056bc:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    800056c0:	f3040513          	addi	a0,s0,-208
    800056c4:	b62ff0ef          	jal	80004a26 <kexec>
    800056c8:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800056ca:	100a0a13          	addi	s4,s4,256
    800056ce:	6088                	ld	a0,0(s1)
    800056d0:	c511                	beqz	a0,800056dc <sys_exec+0xe2>
    kfree(argv[i]);
    800056d2:	b94fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800056d6:	04a1                	addi	s1,s1,8
    800056d8:	ff449be3          	bne	s1,s4,800056ce <sys_exec+0xd4>
  return ret;
    800056dc:	854a                	mv	a0,s2
    800056de:	64be                	ld	s1,456(sp)
    800056e0:	691e                	ld	s2,448(sp)
    800056e2:	79fa                	ld	s3,440(sp)
    800056e4:	7a5a                	ld	s4,432(sp)
    800056e6:	7aba                	ld	s5,424(sp)
    800056e8:	7b1a                	ld	s6,416(sp)
    800056ea:	6bfa                	ld	s7,408(sp)
    800056ec:	a809                	j	800056fe <sys_exec+0x104>
  return -1;
    800056ee:	557d                	li	a0,-1
    800056f0:	64be                	ld	s1,456(sp)
    800056f2:	691e                	ld	s2,448(sp)
    800056f4:	79fa                	ld	s3,440(sp)
    800056f6:	7a5a                	ld	s4,432(sp)
    800056f8:	7aba                	ld	s5,424(sp)
    800056fa:	7b1a                	ld	s6,416(sp)
    800056fc:	6bfa                	ld	s7,408(sp)
}
    800056fe:	60fe                	ld	ra,472(sp)
    80005700:	645e                	ld	s0,464(sp)
    80005702:	613d                	addi	sp,sp,480
    80005704:	8082                	ret

0000000080005706 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005706:	7139                	addi	sp,sp,-64
    80005708:	fc06                	sd	ra,56(sp)
    8000570a:	f822                	sd	s0,48(sp)
    8000570c:	f426                	sd	s1,40(sp)
    8000570e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005710:	beafc0ef          	jal	80001afa <myproc>
    80005714:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005716:	fd840593          	addi	a1,s0,-40
    8000571a:	4501                	li	a0,0
    8000571c:	b42fd0ef          	jal	80002a5e <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005720:	fc840593          	addi	a1,s0,-56
    80005724:	fd040513          	addi	a0,s0,-48
    80005728:	f7ffe0ef          	jal	800046a6 <pipealloc>
    return -1;
    8000572c:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    8000572e:	0a054963          	bltz	a0,800057e0 <sys_pipe+0xda>
  fd0 = -1;
    80005732:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    80005736:	fd043503          	ld	a0,-48(s0)
    8000573a:	ea0ff0ef          	jal	80004dda <fdalloc>
    8000573e:	fca42223          	sw	a0,-60(s0)
    80005742:	08054663          	bltz	a0,800057ce <sys_pipe+0xc8>
    80005746:	fc843503          	ld	a0,-56(s0)
    8000574a:	e90ff0ef          	jal	80004dda <fdalloc>
    8000574e:	fca42023          	sw	a0,-64(s0)
    80005752:	06054463          	bltz	a0,800057ba <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005756:	4711                	li	a4,4
    80005758:	fc440693          	addi	a3,s0,-60
    8000575c:	fd843603          	ld	a2,-40(s0)
    80005760:	64ac                	ld	a1,72(s1)
    80005762:	68a8                	ld	a0,80(s1)
    80005764:	e1ffb0ef          	jal	80001582 <copyout>
    80005768:	00054f63          	bltz	a0,80005786 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    8000576c:	4711                	li	a4,4
    8000576e:	fc040693          	addi	a3,s0,-64
    80005772:	fd843603          	ld	a2,-40(s0)
    80005776:	963a                	add	a2,a2,a4
    80005778:	64ac                	ld	a1,72(s1)
    8000577a:	68a8                	ld	a0,80(s1)
    8000577c:	e07fb0ef          	jal	80001582 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005780:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005782:	04055f63          	bgez	a0,800057e0 <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    80005786:	fc442783          	lw	a5,-60(s0)
    8000578a:	078e                	slli	a5,a5,0x3
    8000578c:	0d078793          	addi	a5,a5,208
    80005790:	97a6                	add	a5,a5,s1
    80005792:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005796:	fc042783          	lw	a5,-64(s0)
    8000579a:	078e                	slli	a5,a5,0x3
    8000579c:	0d078793          	addi	a5,a5,208
    800057a0:	94be                	add	s1,s1,a5
    800057a2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800057a6:	fd043503          	ld	a0,-48(s0)
    800057aa:	bbffe0ef          	jal	80004368 <fileclose>
    fileclose(wf);
    800057ae:	fc843503          	ld	a0,-56(s0)
    800057b2:	bb7fe0ef          	jal	80004368 <fileclose>
    return -1;
    800057b6:	57fd                	li	a5,-1
    800057b8:	a025                	j	800057e0 <sys_pipe+0xda>
    if (fd0 >= 0)
    800057ba:	fc442783          	lw	a5,-60(s0)
    800057be:	0007c863          	bltz	a5,800057ce <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    800057c2:	078e                	slli	a5,a5,0x3
    800057c4:	0d078793          	addi	a5,a5,208
    800057c8:	97a6                	add	a5,a5,s1
    800057ca:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800057ce:	fd043503          	ld	a0,-48(s0)
    800057d2:	b97fe0ef          	jal	80004368 <fileclose>
    fileclose(wf);
    800057d6:	fc843503          	ld	a0,-56(s0)
    800057da:	b8ffe0ef          	jal	80004368 <fileclose>
    return -1;
    800057de:	57fd                	li	a5,-1
}
    800057e0:	853e                	mv	a0,a5
    800057e2:	70e2                	ld	ra,56(sp)
    800057e4:	7442                	ld	s0,48(sp)
    800057e6:	74a2                	ld	s1,40(sp)
    800057e8:	6121                	addi	sp,sp,64
    800057ea:	8082                	ret
    800057ec:	0000                	unimp
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
    80005814:	8b0fd0ef          	jal	800028c4 <kerneltrap>

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
    80005870:	a56fc0ef          	jal	80001ac6 <cpuid>

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
    800058a6:	a20fc0ef          	jal	80001ac6 <cpuid>
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
    800058cc:	9fafc0ef          	jal	80001ac6 <cpuid>
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
    800058fa:	dd278793          	addi	a5,a5,-558 # 800236c8 <disk>
    800058fe:	97aa                	add	a5,a5,a0
    80005900:	0187c783          	lbu	a5,24(a5)
    80005904:	e7b9                	bnez	a5,80005952 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005906:	00451693          	slli	a3,a0,0x4
    8000590a:	0001e797          	auipc	a5,0x1e
    8000590e:	dbe78793          	addi	a5,a5,-578 # 800236c8 <disk>
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
    80005936:	dae50513          	addi	a0,a0,-594 # 800236e0 <disk+0x18>
    8000593a:	837fc0ef          	jal	80002170 <wakeup>
}
    8000593e:	60a2                	ld	ra,8(sp)
    80005940:	6402                	ld	s0,0(sp)
    80005942:	0141                	addi	sp,sp,16
    80005944:	8082                	ret
    panic("free_desc 1");
    80005946:	00002517          	auipc	a0,0x2
    8000594a:	e6a50513          	addi	a0,a0,-406 # 800077b0 <etext+0x7b0>
    8000594e:	ee7fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    80005952:	00002517          	auipc	a0,0x2
    80005956:	e6e50513          	addi	a0,a0,-402 # 800077c0 <etext+0x7c0>
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
    8000596e:	e6658593          	addi	a1,a1,-410 # 800077d0 <etext+0x7d0>
    80005972:	0001e517          	auipc	a0,0x1e
    80005976:	e7e50513          	addi	a0,a0,-386 # 800237f0 <disk+0x128>
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
    800059da:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdad57>
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
    80005a24:	ca848493          	addi	s1,s1,-856 # 800236c8 <disk>
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
    80005a42:	c9273703          	ld	a4,-878(a4) # 800236d0 <disk+0x8>
    80005a46:	cb71                	beqz	a4,80005b1a <virtio_disk_init+0x1bc>
    80005a48:	cbe9                	beqz	a5,80005b1a <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005a4a:	6605                	lui	a2,0x1
    80005a4c:	4581                	li	a1,0
    80005a4e:	a9afb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005a52:	0001e497          	auipc	s1,0x1e
    80005a56:	c7648493          	addi	s1,s1,-906 # 800236c8 <disk>
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
    80005ae2:	d0250513          	addi	a0,a0,-766 # 800077e0 <etext+0x7e0>
    80005ae6:	d4ffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005aea:	00002517          	auipc	a0,0x2
    80005aee:	d1650513          	addi	a0,a0,-746 # 80007800 <etext+0x800>
    80005af2:	d43fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005af6:	00002517          	auipc	a0,0x2
    80005afa:	d2a50513          	addi	a0,a0,-726 # 80007820 <etext+0x820>
    80005afe:	d37fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005b02:	00002517          	auipc	a0,0x2
    80005b06:	d3e50513          	addi	a0,a0,-706 # 80007840 <etext+0x840>
    80005b0a:	d2bfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005b0e:	00002517          	auipc	a0,0x2
    80005b12:	d5250513          	addi	a0,a0,-686 # 80007860 <etext+0x860>
    80005b16:	d1ffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005b1a:	00002517          	auipc	a0,0x2
    80005b1e:	d6650513          	addi	a0,a0,-666 # 80007880 <etext+0x880>
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
    80005b54:	ca050513          	addi	a0,a0,-864 # 800237f0 <disk+0x128>
    80005b58:	8d0fb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005b5c:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005b5e:	0001ea97          	auipc	s5,0x1e
    80005b62:	b6aa8a93          	addi	s5,s5,-1174 # 800236c8 <disk>
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
    80005b88:	b4470713          	addi	a4,a4,-1212 # 800236c8 <disk>
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
    80005bbe:	b2650513          	addi	a0,a0,-1242 # 800236e0 <disk+0x18>
    80005bc2:	d42fc0ef          	jal	80002104 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005bc6:	0001e517          	auipc	a0,0x1e
    80005bca:	c2a50513          	addi	a0,a0,-982 # 800237f0 <disk+0x128>
    80005bce:	8e2fb0ef          	jal	80000cb0 <release>
    sleep();
    80005bd2:	d6efc0ef          	jal	80002140 <sleep>
    acquire(&disk.vdisk_lock);
    80005bd6:	0001e517          	auipc	a0,0x1e
    80005bda:	c1a50513          	addi	a0,a0,-998 # 800237f0 <disk+0x128>
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
    80005bf6:	ad678793          	addi	a5,a5,-1322 # 800236c8 <disk>
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
    80005cd0:	b2448493          	addi	s1,s1,-1244 # 800237f0 <disk+0x128>
  while (b->disk == 1) {
    80005cd4:	892e                	mv	s2,a1
    80005cd6:	02b79163          	bne	a5,a1,80005cf8 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005cda:	854e                	mv	a0,s3
    80005cdc:	c28fc0ef          	jal	80002104 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005ce0:	8526                	mv	a0,s1
    80005ce2:	fcffa0ef          	jal	80000cb0 <release>
    sleep();
    80005ce6:	c5afc0ef          	jal	80002140 <sleep>
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
    80005d08:	9c478793          	addi	a5,a5,-1596 # 800236c8 <disk>
    80005d0c:	97ba                	add	a5,a5,a4
    80005d0e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005d12:	0001e997          	auipc	s3,0x1e
    80005d16:	9b698993          	addi	s3,s3,-1610 # 800236c8 <disk>
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
    80005d3a:	aba50513          	addi	a0,a0,-1350 # 800237f0 <disk+0x128>
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
    80005d68:	96448493          	addi	s1,s1,-1692 # 800236c8 <disk>
    80005d6c:	0001e517          	auipc	a0,0x1e
    80005d70:	a8450513          	addi	a0,a0,-1404 # 800237f0 <disk+0x128>
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
    80005dc8:	ba8fc0ef          	jal	80002170 <wakeup>

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
    80005de8:	a0c50513          	addi	a0,a0,-1524 # 800237f0 <disk+0x128>
    80005dec:	ec5fa0ef          	jal	80000cb0 <release>
}
    80005df0:	60e2                	ld	ra,24(sp)
    80005df2:	6442                	ld	s0,16(sp)
    80005df4:	64a2                	ld	s1,8(sp)
    80005df6:	6105                	addi	sp,sp,32
    80005df8:	8082                	ret
      panic("virtio_disk_intr status");
    80005dfa:	00002517          	auipc	a0,0x2
    80005dfe:	a9e50513          	addi	a0,a0,-1378 # 80007898 <etext+0x898>
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
