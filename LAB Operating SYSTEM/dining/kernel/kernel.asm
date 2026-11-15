
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
    8000011c:	27a020ef          	jal	80002396 <either_copyin>
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
    800001c4:	052020ef          	jal	80002216 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	5ed010ef          	jal	80001fb8 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	61f010ef          	jal	80001ff4 <sleep>
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
    80000220:	12a020ef          	jal	8000234a <either_copyout>
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
    800002ea:	0f8020ef          	jal	800023e2 <procdump>
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
    8000042a:	3fb010ef          	jal	80002024 <wakeup>
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
    8000093a:	67e010ef          	jal	80001fb8 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	6b0010ef          	jal	80001ff4 <sleep>
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
    80000a54:	5d0010ef          	jal	80002024 <wakeup>
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
    seminit();          // semaphores
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
    80000ed4:	640010ef          	jal	80002514 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	311040ef          	jal	800059e8 <plicinithart>
  }

  scheduler();
    80000edc:	741000ef          	jal	80001e1c <scheduler>
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
    trapinit();         // trap vectors
    80000f1c:	5d4010ef          	jal	800024f0 <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	5f4010ef          	jal	80002514 <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	2ab040ef          	jal	800059ce <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	2c1040ef          	jal	800059e8 <plicinithart>
    binit();            // buffer cache
    80000f2c:	767010ef          	jal	80002e92 <binit>
    iinit();            // inode table
    80000f30:	4b8020ef          	jal	800033e8 <iinit>
    fileinit();         // file table
    80000f34:	4e6030ef          	jal	8000441a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	3a7040ef          	jal	80005ade <virtio_disk_init>
    shminit();          // shared memory
    80000f3c:	477010ef          	jal	80002bb2 <shminit>
    seminit();          // semaphores
    80000f40:	55b010ef          	jal	80002c9a <seminit>
    userinit();         // first user process
    80000f44:	4e1000ef          	jal	80001c24 <userinit>
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
    800019aa:	743010ef          	jal	800038ec <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019ae:	00005797          	auipc	a5,0x5
    800019b2:	7d278793          	addi	a5,a5,2002 # 80007180 <etext+0x180>
    800019b6:	fcf43823          	sd	a5,-48(s0)
    800019ba:	fc043c23          	sd	zero,-40(s0)
    800019be:	fd040593          	addi	a1,s0,-48
    800019c2:	853e                	mv	a0,a5
    800019c4:	1dc030ef          	jal	80004ba0 <kexec>
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
    800019d6:	35b000ef          	jal	80002530 <prepare_return>
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
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aea:	4681                	li	a3,0
    80001aec:	4605                	li	a2,1
    80001aee:	040005b7          	lui	a1,0x4000
    80001af2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001af4:	05b2                	slli	a1,a1,0xc
    80001af6:	f32ff0ef          	jal	80001228 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001afa:	4681                	li	a3,0
    80001afc:	4605                	li	a2,1
    80001afe:	020005b7          	lui	a1,0x2000
    80001b02:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b04:	05b6                	slli	a1,a1,0xd
    80001b06:	8526                	mv	a0,s1
    80001b08:	f20ff0ef          	jal	80001228 <uvmunmap>
  uvmunmap(pagetable, SHM_VA, 1, 0);
    80001b0c:	4681                	li	a3,0
    80001b0e:	4605                	li	a2,1
    80001b10:	040005b7          	lui	a1,0x4000
    80001b14:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80001b16:	05b2                	slli	a1,a1,0xc
    80001b18:	8526                	mv	a0,s1
    80001b1a:	f0eff0ef          	jal	80001228 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b1e:	85ca                	mv	a1,s2
    80001b20:	8526                	mv	a0,s1
    80001b22:	8dbff0ef          	jal	800013fc <uvmfree>
}
    80001b26:	60e2                	ld	ra,24(sp)
    80001b28:	6442                	ld	s0,16(sp)
    80001b2a:	64a2                	ld	s1,8(sp)
    80001b2c:	6902                	ld	s2,0(sp)
    80001b2e:	6105                	addi	sp,sp,32
    80001b30:	8082                	ret

0000000080001b32 <freeproc>:
{
    80001b32:	1101                	addi	sp,sp,-32
    80001b34:	ec06                	sd	ra,24(sp)
    80001b36:	e822                	sd	s0,16(sp)
    80001b38:	e426                	sd	s1,8(sp)
    80001b3a:	1000                	addi	s0,sp,32
    80001b3c:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b3e:	6d28                	ld	a0,88(a0)
    80001b40:	c119                	beqz	a0,80001b46 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001b42:	f25fe0ef          	jal	80000a66 <kfree>
  p->trapframe = 0;
    80001b46:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b4a:	68a8                	ld	a0,80(s1)
    80001b4c:	c501                	beqz	a0,80001b54 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b4e:	64ac                	ld	a1,72(s1)
    80001b50:	f8bff0ef          	jal	80001ada <proc_freepagetable>
  p->pagetable = 0;
    80001b54:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b58:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b5c:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001b60:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b64:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b68:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b6c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b70:	0004ac23          	sw	zero,24(s1)
}
    80001b74:	60e2                	ld	ra,24(sp)
    80001b76:	6442                	ld	s0,16(sp)
    80001b78:	64a2                	ld	s1,8(sp)
    80001b7a:	6105                	addi	sp,sp,32
    80001b7c:	8082                	ret

0000000080001b7e <allocproc>:
{
    80001b7e:	1101                	addi	sp,sp,-32
    80001b80:	ec06                	sd	ra,24(sp)
    80001b82:	e822                	sd	s0,16(sp)
    80001b84:	e426                	sd	s1,8(sp)
    80001b86:	e04a                	sd	s2,0(sp)
    80001b88:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b8a:	00011497          	auipc	s1,0x11
    80001b8e:	e9e48493          	addi	s1,s1,-354 # 80012a28 <proc>
    80001b92:	00017917          	auipc	s2,0x17
    80001b96:	89690913          	addi	s2,s2,-1898 # 80018428 <tickslock>
    acquire(&p->lock);
    80001b9a:	8526                	mv	a0,s1
    80001b9c:	88cff0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001ba0:	4c9c                	lw	a5,24(s1)
    80001ba2:	cb91                	beqz	a5,80001bb6 <allocproc+0x38>
      release(&p->lock);
    80001ba4:	8526                	mv	a0,s1
    80001ba6:	90aff0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001baa:	16848493          	addi	s1,s1,360
    80001bae:	ff2496e3          	bne	s1,s2,80001b9a <allocproc+0x1c>
  return 0;
    80001bb2:	4481                	li	s1,0
    80001bb4:	a089                	j	80001bf6 <allocproc+0x78>
  p->pid = allocpid();
    80001bb6:	e63ff0ef          	jal	80001a18 <allocpid>
    80001bba:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bbc:	4785                	li	a5,1
    80001bbe:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bc0:	f8ffe0ef          	jal	80000b4e <kalloc>
    80001bc4:	892a                	mv	s2,a0
    80001bc6:	eca8                	sd	a0,88(s1)
    80001bc8:	cd15                	beqz	a0,80001c04 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001bca:	8526                	mv	a0,s1
    80001bcc:	e8bff0ef          	jal	80001a56 <proc_pagetable>
    80001bd0:	892a                	mv	s2,a0
    80001bd2:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001bd4:	c121                	beqz	a0,80001c14 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001bd6:	07000613          	li	a2,112
    80001bda:	4581                	li	a1,0
    80001bdc:	06048513          	addi	a0,s1,96
    80001be0:	908ff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001be4:	00000797          	auipc	a5,0x0
    80001be8:	d9e78793          	addi	a5,a5,-610 # 80001982 <forkret>
    80001bec:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bee:	60bc                	ld	a5,64(s1)
    80001bf0:	6705                	lui	a4,0x1
    80001bf2:	97ba                	add	a5,a5,a4
    80001bf4:	f4bc                	sd	a5,104(s1)
}
    80001bf6:	8526                	mv	a0,s1
    80001bf8:	60e2                	ld	ra,24(sp)
    80001bfa:	6442                	ld	s0,16(sp)
    80001bfc:	64a2                	ld	s1,8(sp)
    80001bfe:	6902                	ld	s2,0(sp)
    80001c00:	6105                	addi	sp,sp,32
    80001c02:	8082                	ret
    freeproc(p);
    80001c04:	8526                	mv	a0,s1
    80001c06:	f2dff0ef          	jal	80001b32 <freeproc>
    release(&p->lock);
    80001c0a:	8526                	mv	a0,s1
    80001c0c:	8a4ff0ef          	jal	80000cb0 <release>
    return 0;
    80001c10:	84ca                	mv	s1,s2
    80001c12:	b7d5                	j	80001bf6 <allocproc+0x78>
    freeproc(p);
    80001c14:	8526                	mv	a0,s1
    80001c16:	f1dff0ef          	jal	80001b32 <freeproc>
    release(&p->lock);
    80001c1a:	8526                	mv	a0,s1
    80001c1c:	894ff0ef          	jal	80000cb0 <release>
    return 0;
    80001c20:	84ca                	mv	s1,s2
    80001c22:	bfd1                	j	80001bf6 <allocproc+0x78>

0000000080001c24 <userinit>:
{
    80001c24:	1101                	addi	sp,sp,-32
    80001c26:	ec06                	sd	ra,24(sp)
    80001c28:	e822                	sd	s0,16(sp)
    80001c2a:	e426                	sd	s1,8(sp)
    80001c2c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c2e:	f51ff0ef          	jal	80001b7e <allocproc>
    80001c32:	84aa                	mv	s1,a0
  initproc = p;
    80001c34:	00009797          	auipc	a5,0x9
    80001c38:	8aa7b623          	sd	a0,-1876(a5) # 8000a4e0 <initproc>
  p->cwd = namei("/");
    80001c3c:	00005517          	auipc	a0,0x5
    80001c40:	55450513          	addi	a0,a0,1364 # 80007190 <etext+0x190>
    80001c44:	206020ef          	jal	80003e4a <namei>
    80001c48:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c4c:	478d                	li	a5,3
    80001c4e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c50:	8526                	mv	a0,s1
    80001c52:	85eff0ef          	jal	80000cb0 <release>
}
    80001c56:	60e2                	ld	ra,24(sp)
    80001c58:	6442                	ld	s0,16(sp)
    80001c5a:	64a2                	ld	s1,8(sp)
    80001c5c:	6105                	addi	sp,sp,32
    80001c5e:	8082                	ret

0000000080001c60 <growproc>:
{
    80001c60:	1101                	addi	sp,sp,-32
    80001c62:	ec06                	sd	ra,24(sp)
    80001c64:	e822                	sd	s0,16(sp)
    80001c66:	e426                	sd	s1,8(sp)
    80001c68:	e04a                	sd	s2,0(sp)
    80001c6a:	1000                	addi	s0,sp,32
    80001c6c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c6e:	ce3ff0ef          	jal	80001950 <myproc>
    80001c72:	892a                	mv	s2,a0
  sz = p->sz;
    80001c74:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c76:	02905963          	blez	s1,80001ca8 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c7a:	00b48633          	add	a2,s1,a1
    80001c7e:	020007b7          	lui	a5,0x2000
    80001c82:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c84:	07b6                	slli	a5,a5,0xd
    80001c86:	02c7ea63          	bltu	a5,a2,80001cba <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c8a:	4691                	li	a3,4
    80001c8c:	6928                	ld	a0,80(a0)
    80001c8e:	e68ff0ef          	jal	800012f6 <uvmalloc>
    80001c92:	85aa                	mv	a1,a0
    80001c94:	c50d                	beqz	a0,80001cbe <growproc+0x5e>
  p->sz = sz;
    80001c96:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c9a:	4501                	li	a0,0
}
    80001c9c:	60e2                	ld	ra,24(sp)
    80001c9e:	6442                	ld	s0,16(sp)
    80001ca0:	64a2                	ld	s1,8(sp)
    80001ca2:	6902                	ld	s2,0(sp)
    80001ca4:	6105                	addi	sp,sp,32
    80001ca6:	8082                	ret
  } else if (n < 0) {
    80001ca8:	fe04d7e3          	bgez	s1,80001c96 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001cac:	00b48633          	add	a2,s1,a1
    80001cb0:	6928                	ld	a0,80(a0)
    80001cb2:	e00ff0ef          	jal	800012b2 <uvmdealloc>
    80001cb6:	85aa                	mv	a1,a0
    80001cb8:	bff9                	j	80001c96 <growproc+0x36>
      return -1;
    80001cba:	557d                	li	a0,-1
    80001cbc:	b7c5                	j	80001c9c <growproc+0x3c>
      return -1;
    80001cbe:	557d                	li	a0,-1
    80001cc0:	bff1                	j	80001c9c <growproc+0x3c>

0000000080001cc2 <kfork>:
{
    80001cc2:	7139                	addi	sp,sp,-64
    80001cc4:	fc06                	sd	ra,56(sp)
    80001cc6:	f822                	sd	s0,48(sp)
    80001cc8:	f426                	sd	s1,40(sp)
    80001cca:	e456                	sd	s5,8(sp)
    80001ccc:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cce:	c83ff0ef          	jal	80001950 <myproc>
    80001cd2:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001cd4:	eabff0ef          	jal	80001b7e <allocproc>
    80001cd8:	14050063          	beqz	a0,80001e18 <kfork+0x156>
    80001cdc:	e852                	sd	s4,16(sp)
    80001cde:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001ce0:	048ab603          	ld	a2,72(s5)
    80001ce4:	692c                	ld	a1,80(a0)
    80001ce6:	050ab503          	ld	a0,80(s5)
    80001cea:	f44ff0ef          	jal	8000142e <uvmcopy>
    80001cee:	06054663          	bltz	a0,80001d5a <kfork+0x98>
  np->sz = p->sz;
    80001cf2:	048ab783          	ld	a5,72(s5)
    80001cf6:	04fa3423          	sd	a5,72(s4)
  pte_t *shm_pte = walk(p->pagetable, SHM_VA, 0);
    80001cfa:	4601                	li	a2,0
    80001cfc:	040005b7          	lui	a1,0x4000
    80001d00:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80001d02:	05b2                	slli	a1,a1,0xc
    80001d04:	050ab503          	ld	a0,80(s5)
    80001d08:	a7eff0ef          	jal	80000f86 <walk>
  if (shm_pte && (*shm_pte & PTE_V)) {
    80001d0c:	c509                	beqz	a0,80001d16 <kfork+0x54>
    80001d0e:	6118                	ld	a4,0(a0)
    80001d10:	00177793          	andi	a5,a4,1
    80001d14:	efa1                	bnez	a5,80001d6c <kfork+0xaa>
    80001d16:	f04a                	sd	s2,32(sp)
    80001d18:	ec4e                	sd	s3,24(sp)
  *(np->trapframe) = *(p->trapframe);
    80001d1a:	058ab683          	ld	a3,88(s5)
    80001d1e:	87b6                	mv	a5,a3
    80001d20:	058a3703          	ld	a4,88(s4)
    80001d24:	12068693          	addi	a3,a3,288
    80001d28:	6388                	ld	a0,0(a5)
    80001d2a:	678c                	ld	a1,8(a5)
    80001d2c:	6b90                	ld	a2,16(a5)
    80001d2e:	e308                	sd	a0,0(a4)
    80001d30:	e70c                	sd	a1,8(a4)
    80001d32:	eb10                	sd	a2,16(a4)
    80001d34:	6f90                	ld	a2,24(a5)
    80001d36:	ef10                	sd	a2,24(a4)
    80001d38:	02078793          	addi	a5,a5,32
    80001d3c:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d40:	fed794e3          	bne	a5,a3,80001d28 <kfork+0x66>
  np->trapframe->a0 = 0;
    80001d44:	058a3783          	ld	a5,88(s4)
    80001d48:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d4c:	0d0a8493          	addi	s1,s5,208
    80001d50:	0d0a0913          	addi	s2,s4,208
    80001d54:	150a8993          	addi	s3,s5,336
    80001d58:	a0b1                	j	80001da4 <kfork+0xe2>
    freeproc(np);
    80001d5a:	8552                	mv	a0,s4
    80001d5c:	dd7ff0ef          	jal	80001b32 <freeproc>
    release(&np->lock);
    80001d60:	8552                	mv	a0,s4
    80001d62:	f4ffe0ef          	jal	80000cb0 <release>
    return -1;
    80001d66:	54fd                	li	s1,-1
    80001d68:	6a42                	ld	s4,16(sp)
    80001d6a:	a045                	j	80001e0a <kfork+0x148>
    uint64 pa = PTE2PA(*shm_pte);
    80001d6c:	00a75693          	srli	a3,a4,0xa
    if (mappages(np->pagetable, SHM_VA, PGSIZE, pa, flags) != 0) {
    80001d70:	3ff77713          	andi	a4,a4,1023
    80001d74:	06b2                	slli	a3,a3,0xc
    80001d76:	6605                	lui	a2,0x1
    80001d78:	040005b7          	lui	a1,0x4000
    80001d7c:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80001d7e:	05b2                	slli	a1,a1,0xc
    80001d80:	050a3503          	ld	a0,80(s4)
    80001d84:	ad6ff0ef          	jal	8000105a <mappages>
    80001d88:	d559                	beqz	a0,80001d16 <kfork+0x54>
      freeproc(np);
    80001d8a:	8552                	mv	a0,s4
    80001d8c:	da7ff0ef          	jal	80001b32 <freeproc>
      release(&np->lock);
    80001d90:	8552                	mv	a0,s4
    80001d92:	f1ffe0ef          	jal	80000cb0 <release>
      return -1;
    80001d96:	54fd                	li	s1,-1
    80001d98:	6a42                	ld	s4,16(sp)
    80001d9a:	a885                	j	80001e0a <kfork+0x148>
  for (i = 0; i < NOFILE; i++)
    80001d9c:	04a1                	addi	s1,s1,8
    80001d9e:	0921                	addi	s2,s2,8
    80001da0:	01348963          	beq	s1,s3,80001db2 <kfork+0xf0>
    if (p->ofile[i])
    80001da4:	6088                	ld	a0,0(s1)
    80001da6:	d97d                	beqz	a0,80001d9c <kfork+0xda>
      np->ofile[i] = filedup(p->ofile[i]);
    80001da8:	6f4020ef          	jal	8000449c <filedup>
    80001dac:	00a93023          	sd	a0,0(s2)
    80001db0:	b7f5                	j	80001d9c <kfork+0xda>
  np->cwd = idup(p->cwd);
    80001db2:	150ab503          	ld	a0,336(s5)
    80001db6:	7c4010ef          	jal	8000357a <idup>
    80001dba:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001dbe:	4641                	li	a2,16
    80001dc0:	158a8593          	addi	a1,s5,344
    80001dc4:	158a0513          	addi	a0,s4,344
    80001dc8:	874ff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001dcc:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001dd0:	8552                	mv	a0,s4
    80001dd2:	edffe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001dd6:	00011517          	auipc	a0,0x11
    80001dda:	83a50513          	addi	a0,a0,-1990 # 80012610 <wait_lock>
    80001dde:	e4bfe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001de2:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001de6:	00011517          	auipc	a0,0x11
    80001dea:	82a50513          	addi	a0,a0,-2006 # 80012610 <wait_lock>
    80001dee:	ec3fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001df2:	8552                	mv	a0,s4
    80001df4:	e35fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001df8:	478d                	li	a5,3
    80001dfa:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001dfe:	8552                	mv	a0,s4
    80001e00:	eb1fe0ef          	jal	80000cb0 <release>
  return pid;
    80001e04:	7902                	ld	s2,32(sp)
    80001e06:	69e2                	ld	s3,24(sp)
    80001e08:	6a42                	ld	s4,16(sp)
}
    80001e0a:	8526                	mv	a0,s1
    80001e0c:	70e2                	ld	ra,56(sp)
    80001e0e:	7442                	ld	s0,48(sp)
    80001e10:	74a2                	ld	s1,40(sp)
    80001e12:	6aa2                	ld	s5,8(sp)
    80001e14:	6121                	addi	sp,sp,64
    80001e16:	8082                	ret
    return -1;
    80001e18:	54fd                	li	s1,-1
    80001e1a:	bfc5                	j	80001e0a <kfork+0x148>

0000000080001e1c <scheduler>:
{
    80001e1c:	711d                	addi	sp,sp,-96
    80001e1e:	ec86                	sd	ra,88(sp)
    80001e20:	e8a2                	sd	s0,80(sp)
    80001e22:	e4a6                	sd	s1,72(sp)
    80001e24:	e0ca                	sd	s2,64(sp)
    80001e26:	fc4e                	sd	s3,56(sp)
    80001e28:	f852                	sd	s4,48(sp)
    80001e2a:	f456                	sd	s5,40(sp)
    80001e2c:	f05a                	sd	s6,32(sp)
    80001e2e:	ec5e                	sd	s7,24(sp)
    80001e30:	e862                	sd	s8,16(sp)
    80001e32:	e466                	sd	s9,8(sp)
    80001e34:	1080                	addi	s0,sp,96
    80001e36:	8792                	mv	a5,tp
  int id = r_tp();
    80001e38:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e3a:	00779a93          	slli	s5,a5,0x7
    80001e3e:	00010717          	auipc	a4,0x10
    80001e42:	7ba70713          	addi	a4,a4,1978 # 800125f8 <pid_lock>
    80001e46:	9756                	add	a4,a4,s5
    80001e48:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001e4c:	00010717          	auipc	a4,0x10
    80001e50:	7e470713          	addi	a4,a4,2020 # 80012630 <cpus+0x8>
    80001e54:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001e56:	4c11                	li	s8,4
        c->proc = p;
    80001e58:	00010b17          	auipc	s6,0x10
    80001e5c:	7a0b0b13          	addi	s6,s6,1952 # 800125f8 <pid_lock>
    80001e60:	079e                	slli	a5,a5,0x7
    80001e62:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001e66:	4b85                	li	s7,1
    80001e68:	a0a9                	j	80001eb2 <scheduler+0x96>
      release(&p->lock);
    80001e6a:	8526                	mv	a0,s1
    80001e6c:	e45fe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e70:	16848493          	addi	s1,s1,360
    80001e74:	03248b63          	beq	s1,s2,80001eaa <scheduler+0x8e>
      acquire(&p->lock);
    80001e78:	8526                	mv	a0,s1
    80001e7a:	daffe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001e7e:	4c9c                	lw	a5,24(s1)
    80001e80:	ff3795e3          	bne	a5,s3,80001e6a <scheduler+0x4e>
        p->state = RUNNING;
    80001e84:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e88:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001e8c:	06048593          	addi	a1,s1,96
    80001e90:	8556                	mv	a0,s5
    80001e92:	5f4000ef          	jal	80002486 <swtch>
    80001e96:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001e98:	2781                	sext.w	a5,a5
    80001e9a:	079e                	slli	a5,a5,0x7
    80001e9c:	97da                	add	a5,a5,s6
    80001e9e:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001ea2:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001ea6:	8cde                	mv	s9,s7
    80001ea8:	b7c9                	j	80001e6a <scheduler+0x4e>
    if (found == 0) {
    80001eaa:	000c9463          	bnez	s9,80001eb2 <scheduler+0x96>
      asm volatile("wfi");
    80001eae:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001eb2:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001eb6:	10017073          	csrci	sstatus,2
    int found = 0;
    80001eba:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001ebc:	00011497          	auipc	s1,0x11
    80001ec0:	b6c48493          	addi	s1,s1,-1172 # 80012a28 <proc>
      if (p->state == RUNNABLE) {
    80001ec4:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001ec6:	00016917          	auipc	s2,0x16
    80001eca:	56290913          	addi	s2,s2,1378 # 80018428 <tickslock>
    80001ece:	b76d                	j	80001e78 <scheduler+0x5c>

0000000080001ed0 <sched>:
{
    80001ed0:	7179                	addi	sp,sp,-48
    80001ed2:	f406                	sd	ra,40(sp)
    80001ed4:	f022                	sd	s0,32(sp)
    80001ed6:	ec26                	sd	s1,24(sp)
    80001ed8:	e84a                	sd	s2,16(sp)
    80001eda:	e44e                	sd	s3,8(sp)
    80001edc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ede:	a73ff0ef          	jal	80001950 <myproc>
    80001ee2:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001ee4:	cdffe0ef          	jal	80000bc2 <holding>
    80001ee8:	c935                	beqz	a0,80001f5c <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001eea:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001eec:	2781                	sext.w	a5,a5
    80001eee:	079e                	slli	a5,a5,0x7
    80001ef0:	00010717          	auipc	a4,0x10
    80001ef4:	70870713          	addi	a4,a4,1800 # 800125f8 <pid_lock>
    80001ef8:	97ba                	add	a5,a5,a4
    80001efa:	0a87a703          	lw	a4,168(a5)
    80001efe:	4785                	li	a5,1
    80001f00:	06f71463          	bne	a4,a5,80001f68 <sched+0x98>
  if (p->state == RUNNING)
    80001f04:	4c98                	lw	a4,24(s1)
    80001f06:	4791                	li	a5,4
    80001f08:	06f70663          	beq	a4,a5,80001f74 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001f0c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f10:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001f12:	e7bd                	bnez	a5,80001f80 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f14:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f16:	00010917          	auipc	s2,0x10
    80001f1a:	6e290913          	addi	s2,s2,1762 # 800125f8 <pid_lock>
    80001f1e:	2781                	sext.w	a5,a5
    80001f20:	079e                	slli	a5,a5,0x7
    80001f22:	97ca                	add	a5,a5,s2
    80001f24:	0ac7a983          	lw	s3,172(a5)
    80001f28:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f2a:	2781                	sext.w	a5,a5
    80001f2c:	079e                	slli	a5,a5,0x7
    80001f2e:	07a1                	addi	a5,a5,8
    80001f30:	00010597          	auipc	a1,0x10
    80001f34:	6f858593          	addi	a1,a1,1784 # 80012628 <cpus>
    80001f38:	95be                	add	a1,a1,a5
    80001f3a:	06048513          	addi	a0,s1,96
    80001f3e:	548000ef          	jal	80002486 <swtch>
    80001f42:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f44:	2781                	sext.w	a5,a5
    80001f46:	079e                	slli	a5,a5,0x7
    80001f48:	993e                	add	s2,s2,a5
    80001f4a:	0b392623          	sw	s3,172(s2)
}
    80001f4e:	70a2                	ld	ra,40(sp)
    80001f50:	7402                	ld	s0,32(sp)
    80001f52:	64e2                	ld	s1,24(sp)
    80001f54:	6942                	ld	s2,16(sp)
    80001f56:	69a2                	ld	s3,8(sp)
    80001f58:	6145                	addi	sp,sp,48
    80001f5a:	8082                	ret
    panic("sched p->lock");
    80001f5c:	00005517          	auipc	a0,0x5
    80001f60:	23c50513          	addi	a0,a0,572 # 80007198 <etext+0x198>
    80001f64:	8d1fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80001f68:	00005517          	auipc	a0,0x5
    80001f6c:	24050513          	addi	a0,a0,576 # 800071a8 <etext+0x1a8>
    80001f70:	8c5fe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80001f74:	00005517          	auipc	a0,0x5
    80001f78:	24450513          	addi	a0,a0,580 # 800071b8 <etext+0x1b8>
    80001f7c:	8b9fe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80001f80:	00005517          	auipc	a0,0x5
    80001f84:	24850513          	addi	a0,a0,584 # 800071c8 <etext+0x1c8>
    80001f88:	8adfe0ef          	jal	80000834 <panic>

0000000080001f8c <yield>:
{
    80001f8c:	1101                	addi	sp,sp,-32
    80001f8e:	ec06                	sd	ra,24(sp)
    80001f90:	e822                	sd	s0,16(sp)
    80001f92:	e426                	sd	s1,8(sp)
    80001f94:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f96:	9bbff0ef          	jal	80001950 <myproc>
    80001f9a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f9c:	c8dfe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001fa0:	478d                	li	a5,3
    80001fa2:	cc9c                	sw	a5,24(s1)
  sched();
    80001fa4:	f2dff0ef          	jal	80001ed0 <sched>
  release(&p->lock);
    80001fa8:	8526                	mv	a0,s1
    80001faa:	d07fe0ef          	jal	80000cb0 <release>
}
    80001fae:	60e2                	ld	ra,24(sp)
    80001fb0:	6442                	ld	s0,16(sp)
    80001fb2:	64a2                	ld	s1,8(sp)
    80001fb4:	6105                	addi	sp,sp,32
    80001fb6:	8082                	ret

0000000080001fb8 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001fb8:	1101                	addi	sp,sp,-32
    80001fba:	ec06                	sd	ra,24(sp)
    80001fbc:	e822                	sd	s0,16(sp)
    80001fbe:	e426                	sd	s1,8(sp)
    80001fc0:	e04a                	sd	s2,0(sp)
    80001fc2:	1000                	addi	s0,sp,32
    80001fc4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fc6:	98bff0ef          	jal	80001950 <myproc>
    80001fca:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001fcc:	c5dfe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    80001fd0:	cc81                	beqz	s1,80001fe8 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001fd2:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001fd6:	854a                	mv	a0,s2
    80001fd8:	cd9fe0ef          	jal	80000cb0 <release>
}
    80001fdc:	60e2                	ld	ra,24(sp)
    80001fde:	6442                	ld	s0,16(sp)
    80001fe0:	64a2                	ld	s1,8(sp)
    80001fe2:	6902                	ld	s2,0(sp)
    80001fe4:	6105                	addi	sp,sp,32
    80001fe6:	8082                	ret
    panic("sleep_prepare: zero chan");
    80001fe8:	00005517          	auipc	a0,0x5
    80001fec:	1f850513          	addi	a0,a0,504 # 800071e0 <etext+0x1e0>
    80001ff0:	845fe0ef          	jal	80000834 <panic>

0000000080001ff4 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80001ff4:	1101                	addi	sp,sp,-32
    80001ff6:	ec06                	sd	ra,24(sp)
    80001ff8:	e822                	sd	s0,16(sp)
    80001ffa:	e426                	sd	s1,8(sp)
    80001ffc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ffe:	953ff0ef          	jal	80001950 <myproc>
    80002002:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80002004:	c25fe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    80002008:	709c                	ld	a5,32(s1)
    8000200a:	c789                	beqz	a5,80002014 <sleep+0x20>
    p->state = SLEEPING;
    8000200c:	4789                	li	a5,2
    8000200e:	cc9c                	sw	a5,24(s1)
    sched();
    80002010:	ec1ff0ef          	jal	80001ed0 <sched>
  }
  release(&p->lock);
    80002014:	8526                	mv	a0,s1
    80002016:	c9bfe0ef          	jal	80000cb0 <release>
}
    8000201a:	60e2                	ld	ra,24(sp)
    8000201c:	6442                	ld	s0,16(sp)
    8000201e:	64a2                	ld	s1,8(sp)
    80002020:	6105                	addi	sp,sp,32
    80002022:	8082                	ret

0000000080002024 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80002024:	7139                	addi	sp,sp,-64
    80002026:	fc06                	sd	ra,56(sp)
    80002028:	f822                	sd	s0,48(sp)
    8000202a:	f426                	sd	s1,40(sp)
    8000202c:	f04a                	sd	s2,32(sp)
    8000202e:	ec4e                	sd	s3,24(sp)
    80002030:	e852                	sd	s4,16(sp)
    80002032:	e456                	sd	s5,8(sp)
    80002034:	0080                	addi	s0,sp,64
    80002036:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002038:	00011497          	auipc	s1,0x11
    8000203c:	9f048493          	addi	s1,s1,-1552 # 80012a28 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80002040:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80002042:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80002044:	00016997          	auipc	s3,0x16
    80002048:	3e498993          	addi	s3,s3,996 # 80018428 <tickslock>
    8000204c:	a801                	j	8000205c <wakeup+0x38>
      }
    }
    release(&p->lock);
    8000204e:	8526                	mv	a0,s1
    80002050:	c61fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002054:	16848493          	addi	s1,s1,360
    80002058:	03348063          	beq	s1,s3,80002078 <wakeup+0x54>
    acquire(&p->lock);
    8000205c:	8526                	mv	a0,s1
    8000205e:	bcbfe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    80002062:	709c                	ld	a5,32(s1)
    80002064:	ff2795e3          	bne	a5,s2,8000204e <wakeup+0x2a>
      p->chan = 0;
    80002068:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    8000206c:	4c9c                	lw	a5,24(s1)
    8000206e:	ff4790e3          	bne	a5,s4,8000204e <wakeup+0x2a>
        p->state = RUNNABLE;
    80002072:	0154ac23          	sw	s5,24(s1)
    80002076:	bfe1                	j	8000204e <wakeup+0x2a>
  }
}
    80002078:	70e2                	ld	ra,56(sp)
    8000207a:	7442                	ld	s0,48(sp)
    8000207c:	74a2                	ld	s1,40(sp)
    8000207e:	7902                	ld	s2,32(sp)
    80002080:	69e2                	ld	s3,24(sp)
    80002082:	6a42                	ld	s4,16(sp)
    80002084:	6aa2                	ld	s5,8(sp)
    80002086:	6121                	addi	sp,sp,64
    80002088:	8082                	ret

000000008000208a <reparent>:
{
    8000208a:	7179                	addi	sp,sp,-48
    8000208c:	f406                	sd	ra,40(sp)
    8000208e:	f022                	sd	s0,32(sp)
    80002090:	ec26                	sd	s1,24(sp)
    80002092:	e84a                	sd	s2,16(sp)
    80002094:	e44e                	sd	s3,8(sp)
    80002096:	e052                	sd	s4,0(sp)
    80002098:	1800                	addi	s0,sp,48
    8000209a:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000209c:	00011497          	auipc	s1,0x11
    800020a0:	98c48493          	addi	s1,s1,-1652 # 80012a28 <proc>
      pp->parent = initproc;
    800020a4:	00008a17          	auipc	s4,0x8
    800020a8:	43ca0a13          	addi	s4,s4,1084 # 8000a4e0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020ac:	00016997          	auipc	s3,0x16
    800020b0:	37c98993          	addi	s3,s3,892 # 80018428 <tickslock>
    800020b4:	a029                	j	800020be <reparent+0x34>
    800020b6:	16848493          	addi	s1,s1,360
    800020ba:	01348b63          	beq	s1,s3,800020d0 <reparent+0x46>
    if (pp->parent == p) {
    800020be:	7c9c                	ld	a5,56(s1)
    800020c0:	ff279be3          	bne	a5,s2,800020b6 <reparent+0x2c>
      pp->parent = initproc;
    800020c4:	000a3503          	ld	a0,0(s4)
    800020c8:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800020ca:	f5bff0ef          	jal	80002024 <wakeup>
    800020ce:	b7e5                	j	800020b6 <reparent+0x2c>
}
    800020d0:	70a2                	ld	ra,40(sp)
    800020d2:	7402                	ld	s0,32(sp)
    800020d4:	64e2                	ld	s1,24(sp)
    800020d6:	6942                	ld	s2,16(sp)
    800020d8:	69a2                	ld	s3,8(sp)
    800020da:	6a02                	ld	s4,0(sp)
    800020dc:	6145                	addi	sp,sp,48
    800020de:	8082                	ret

00000000800020e0 <kexit>:
{
    800020e0:	7179                	addi	sp,sp,-48
    800020e2:	f406                	sd	ra,40(sp)
    800020e4:	f022                	sd	s0,32(sp)
    800020e6:	ec26                	sd	s1,24(sp)
    800020e8:	e84a                	sd	s2,16(sp)
    800020ea:	e44e                	sd	s3,8(sp)
    800020ec:	e052                	sd	s4,0(sp)
    800020ee:	1800                	addi	s0,sp,48
    800020f0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020f2:	85fff0ef          	jal	80001950 <myproc>
    800020f6:	89aa                	mv	s3,a0
  if (p == initproc)
    800020f8:	00008797          	auipc	a5,0x8
    800020fc:	3e87b783          	ld	a5,1000(a5) # 8000a4e0 <initproc>
    80002100:	0d050493          	addi	s1,a0,208
    80002104:	15050913          	addi	s2,a0,336
    80002108:	00a79b63          	bne	a5,a0,8000211e <kexit+0x3e>
    panic("init exiting");
    8000210c:	00005517          	auipc	a0,0x5
    80002110:	0f450513          	addi	a0,a0,244 # 80007200 <etext+0x200>
    80002114:	f20fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002118:	04a1                	addi	s1,s1,8
    8000211a:	01248963          	beq	s1,s2,8000212c <kexit+0x4c>
    if (p->ofile[fd]) {
    8000211e:	6088                	ld	a0,0(s1)
    80002120:	dd65                	beqz	a0,80002118 <kexit+0x38>
      fileclose(f);
    80002122:	3c0020ef          	jal	800044e2 <fileclose>
      p->ofile[fd] = 0;
    80002126:	0004b023          	sd	zero,0(s1)
    8000212a:	b7fd                	j	80002118 <kexit+0x38>
  begin_op();
    8000212c:	6fd010ef          	jal	80004028 <begin_op>
  iput(p->cwd);
    80002130:	1509b503          	ld	a0,336(s3)
    80002134:	5fe010ef          	jal	80003732 <iput>
  end_op();
    80002138:	77d010ef          	jal	800040b4 <end_op>
  p->cwd = 0;
    8000213c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002140:	00010517          	auipc	a0,0x10
    80002144:	4d050513          	addi	a0,a0,1232 # 80012610 <wait_lock>
    80002148:	ae1fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    8000214c:	854e                	mv	a0,s3
    8000214e:	f3dff0ef          	jal	8000208a <reparent>
  wakeup(p->parent);
    80002152:	0389b503          	ld	a0,56(s3)
    80002156:	ecfff0ef          	jal	80002024 <wakeup>
  acquire(&p->lock);
    8000215a:	854e                	mv	a0,s3
    8000215c:	acdfe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    80002160:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002164:	4795                	li	a5,5
    80002166:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000216a:	00010517          	auipc	a0,0x10
    8000216e:	4a650513          	addi	a0,a0,1190 # 80012610 <wait_lock>
    80002172:	b3ffe0ef          	jal	80000cb0 <release>
  sched();
    80002176:	d5bff0ef          	jal	80001ed0 <sched>
  panic("zombie exit");
    8000217a:	00005517          	auipc	a0,0x5
    8000217e:	09650513          	addi	a0,a0,150 # 80007210 <etext+0x210>
    80002182:	eb2fe0ef          	jal	80000834 <panic>

0000000080002186 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    80002186:	c525                	beqz	a0,800021ee <kkill+0x68>
{
    80002188:	7179                	addi	sp,sp,-48
    8000218a:	f406                	sd	ra,40(sp)
    8000218c:	f022                	sd	s0,32(sp)
    8000218e:	ec26                	sd	s1,24(sp)
    80002190:	e84a                	sd	s2,16(sp)
    80002192:	e44e                	sd	s3,8(sp)
    80002194:	1800                	addi	s0,sp,48
    80002196:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002198:	00011497          	auipc	s1,0x11
    8000219c:	89048493          	addi	s1,s1,-1904 # 80012a28 <proc>
    800021a0:	00016997          	auipc	s3,0x16
    800021a4:	28898993          	addi	s3,s3,648 # 80018428 <tickslock>
    acquire(&p->lock);
    800021a8:	8526                	mv	a0,s1
    800021aa:	a7ffe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    800021ae:	589c                	lw	a5,48(s1)
    800021b0:	01278b63          	beq	a5,s2,800021c6 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800021b4:	8526                	mv	a0,s1
    800021b6:	afbfe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800021ba:	16848493          	addi	s1,s1,360
    800021be:	ff3495e3          	bne	s1,s3,800021a8 <kkill+0x22>
  }
  return -1;
    800021c2:	557d                	li	a0,-1
    800021c4:	a819                	j	800021da <kkill+0x54>
      p->killed = 1;
    800021c6:	4785                	li	a5,1
    800021c8:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800021ca:	4c98                	lw	a4,24(s1)
    800021cc:	4789                	li	a5,2
    800021ce:	00f70d63          	beq	a4,a5,800021e8 <kkill+0x62>
      release(&p->lock);
    800021d2:	8526                	mv	a0,s1
    800021d4:	addfe0ef          	jal	80000cb0 <release>
      return 0;
    800021d8:	4501                	li	a0,0
}
    800021da:	70a2                	ld	ra,40(sp)
    800021dc:	7402                	ld	s0,32(sp)
    800021de:	64e2                	ld	s1,24(sp)
    800021e0:	6942                	ld	s2,16(sp)
    800021e2:	69a2                	ld	s3,8(sp)
    800021e4:	6145                	addi	sp,sp,48
    800021e6:	8082                	ret
        p->state = RUNNABLE;
    800021e8:	478d                	li	a5,3
    800021ea:	cc9c                	sw	a5,24(s1)
    800021ec:	b7dd                	j	800021d2 <kkill+0x4c>
    return -1;
    800021ee:	557d                	li	a0,-1
}
    800021f0:	8082                	ret

00000000800021f2 <setkilled>:

void
setkilled(struct proc *p)
{
    800021f2:	1101                	addi	sp,sp,-32
    800021f4:	ec06                	sd	ra,24(sp)
    800021f6:	e822                	sd	s0,16(sp)
    800021f8:	e426                	sd	s1,8(sp)
    800021fa:	1000                	addi	s0,sp,32
    800021fc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021fe:	a2bfe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002202:	4785                	li	a5,1
    80002204:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002206:	8526                	mv	a0,s1
    80002208:	aa9fe0ef          	jal	80000cb0 <release>
}
    8000220c:	60e2                	ld	ra,24(sp)
    8000220e:	6442                	ld	s0,16(sp)
    80002210:	64a2                	ld	s1,8(sp)
    80002212:	6105                	addi	sp,sp,32
    80002214:	8082                	ret

0000000080002216 <killed>:

int
killed(struct proc *p)
{
    80002216:	1101                	addi	sp,sp,-32
    80002218:	ec06                	sd	ra,24(sp)
    8000221a:	e822                	sd	s0,16(sp)
    8000221c:	e426                	sd	s1,8(sp)
    8000221e:	e04a                	sd	s2,0(sp)
    80002220:	1000                	addi	s0,sp,32
    80002222:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002224:	a05fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80002228:	549c                	lw	a5,40(s1)
    8000222a:	893e                	mv	s2,a5
  release(&p->lock);
    8000222c:	8526                	mv	a0,s1
    8000222e:	a83fe0ef          	jal	80000cb0 <release>
  return k;
}
    80002232:	854a                	mv	a0,s2
    80002234:	60e2                	ld	ra,24(sp)
    80002236:	6442                	ld	s0,16(sp)
    80002238:	64a2                	ld	s1,8(sp)
    8000223a:	6902                	ld	s2,0(sp)
    8000223c:	6105                	addi	sp,sp,32
    8000223e:	8082                	ret

0000000080002240 <kwait>:
{
    80002240:	715d                	addi	sp,sp,-80
    80002242:	e486                	sd	ra,72(sp)
    80002244:	e0a2                	sd	s0,64(sp)
    80002246:	fc26                	sd	s1,56(sp)
    80002248:	f84a                	sd	s2,48(sp)
    8000224a:	f44e                	sd	s3,40(sp)
    8000224c:	f052                	sd	s4,32(sp)
    8000224e:	ec56                	sd	s5,24(sp)
    80002250:	e85a                	sd	s6,16(sp)
    80002252:	e45e                	sd	s7,8(sp)
    80002254:	0880                	addi	s0,sp,80
    80002256:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002258:	ef8ff0ef          	jal	80001950 <myproc>
    8000225c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000225e:	00010517          	auipc	a0,0x10
    80002262:	3b250513          	addi	a0,a0,946 # 80012610 <wait_lock>
    80002266:	9c3fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    8000226a:	4a15                	li	s4,5
        havekids = 1;
    8000226c:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000226e:	00016997          	auipc	s3,0x16
    80002272:	1ba98993          	addi	s3,s3,442 # 80018428 <tickslock>
    release(&wait_lock);
    80002276:	00010b17          	auipc	s6,0x10
    8000227a:	39ab0b13          	addi	s6,s6,922 # 80012610 <wait_lock>
    8000227e:	a845                	j	8000232e <kwait+0xee>
          pid = pp->pid;
    80002280:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    80002284:	000b8e63          	beqz	s7,800022a0 <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    80002288:	4711                	li	a4,4
    8000228a:	02c48693          	addi	a3,s1,44
    8000228e:	865e                	mv	a2,s7
    80002290:	04893583          	ld	a1,72(s2)
    80002294:	05093503          	ld	a0,80(s2)
    80002298:	af2ff0ef          	jal	8000158a <copyout>
          if (addr != 0 &&
    8000229c:	02054c63          	bltz	a0,800022d4 <kwait+0x94>
          pp->parent = 0;
    800022a0:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    800022a4:	8526                	mv	a0,s1
    800022a6:	88dff0ef          	jal	80001b32 <freeproc>
          release(&pp->lock);
    800022aa:	8526                	mv	a0,s1
    800022ac:	a05fe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    800022b0:	00010517          	auipc	a0,0x10
    800022b4:	36050513          	addi	a0,a0,864 # 80012610 <wait_lock>
    800022b8:	9f9fe0ef          	jal	80000cb0 <release>
}
    800022bc:	854e                	mv	a0,s3
    800022be:	60a6                	ld	ra,72(sp)
    800022c0:	6406                	ld	s0,64(sp)
    800022c2:	74e2                	ld	s1,56(sp)
    800022c4:	7942                	ld	s2,48(sp)
    800022c6:	79a2                	ld	s3,40(sp)
    800022c8:	7a02                	ld	s4,32(sp)
    800022ca:	6ae2                	ld	s5,24(sp)
    800022cc:	6b42                	ld	s6,16(sp)
    800022ce:	6ba2                	ld	s7,8(sp)
    800022d0:	6161                	addi	sp,sp,80
    800022d2:	8082                	ret
            release(&pp->lock);
    800022d4:	8526                	mv	a0,s1
    800022d6:	9dbfe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    800022da:	00010517          	auipc	a0,0x10
    800022de:	33650513          	addi	a0,a0,822 # 80012610 <wait_lock>
    800022e2:	9cffe0ef          	jal	80000cb0 <release>
            return -1;
    800022e6:	59fd                	li	s3,-1
    800022e8:	bfd1                	j	800022bc <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022ea:	16848493          	addi	s1,s1,360
    800022ee:	03348063          	beq	s1,s3,8000230e <kwait+0xce>
      if (pp->parent == p) {
    800022f2:	7c9c                	ld	a5,56(s1)
    800022f4:	ff279be3          	bne	a5,s2,800022ea <kwait+0xaa>
        acquire(&pp->lock);
    800022f8:	8526                	mv	a0,s1
    800022fa:	92ffe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800022fe:	4c9c                	lw	a5,24(s1)
    80002300:	f94780e3          	beq	a5,s4,80002280 <kwait+0x40>
        release(&pp->lock);
    80002304:	8526                	mv	a0,s1
    80002306:	9abfe0ef          	jal	80000cb0 <release>
        havekids = 1;
    8000230a:	8756                	mv	a4,s5
    8000230c:	bff9                	j	800022ea <kwait+0xaa>
    if (!havekids || killed(p)) {
    8000230e:	c715                	beqz	a4,8000233a <kwait+0xfa>
    80002310:	854a                	mv	a0,s2
    80002312:	f05ff0ef          	jal	80002216 <killed>
    80002316:	e115                	bnez	a0,8000233a <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    80002318:	854a                	mv	a0,s2
    8000231a:	c9fff0ef          	jal	80001fb8 <sleep_prepare>
    release(&wait_lock);
    8000231e:	855a                	mv	a0,s6
    80002320:	991fe0ef          	jal	80000cb0 <release>
    sleep();
    80002324:	cd1ff0ef          	jal	80001ff4 <sleep>
    acquire(&wait_lock);
    80002328:	855a                	mv	a0,s6
    8000232a:	8fffe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    8000232e:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002330:	00010497          	auipc	s1,0x10
    80002334:	6f848493          	addi	s1,s1,1784 # 80012a28 <proc>
    80002338:	bf6d                	j	800022f2 <kwait+0xb2>
      release(&wait_lock);
    8000233a:	00010517          	auipc	a0,0x10
    8000233e:	2d650513          	addi	a0,a0,726 # 80012610 <wait_lock>
    80002342:	96ffe0ef          	jal	80000cb0 <release>
      return -1;
    80002346:	59fd                	li	s3,-1
    80002348:	bf95                	j	800022bc <kwait+0x7c>

000000008000234a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000234a:	7179                	addi	sp,sp,-48
    8000234c:	f406                	sd	ra,40(sp)
    8000234e:	f022                	sd	s0,32(sp)
    80002350:	ec26                	sd	s1,24(sp)
    80002352:	e84a                	sd	s2,16(sp)
    80002354:	e44e                	sd	s3,8(sp)
    80002356:	e052                	sd	s4,0(sp)
    80002358:	1800                	addi	s0,sp,48
    8000235a:	84aa                	mv	s1,a0
    8000235c:	8a2e                	mv	s4,a1
    8000235e:	89b2                	mv	s3,a2
    80002360:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002362:	deeff0ef          	jal	80001950 <myproc>
  if (user_dst) {
    80002366:	c085                	beqz	s1,80002386 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    80002368:	874a                	mv	a4,s2
    8000236a:	86ce                	mv	a3,s3
    8000236c:	8652                	mv	a2,s4
    8000236e:	652c                	ld	a1,72(a0)
    80002370:	6928                	ld	a0,80(a0)
    80002372:	a18ff0ef          	jal	8000158a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002376:	70a2                	ld	ra,40(sp)
    80002378:	7402                	ld	s0,32(sp)
    8000237a:	64e2                	ld	s1,24(sp)
    8000237c:	6942                	ld	s2,16(sp)
    8000237e:	69a2                	ld	s3,8(sp)
    80002380:	6a02                	ld	s4,0(sp)
    80002382:	6145                	addi	sp,sp,48
    80002384:	8082                	ret
    memmove((char *)dst, src, len);
    80002386:	0009061b          	sext.w	a2,s2
    8000238a:	85ce                	mv	a1,s3
    8000238c:	8552                	mv	a0,s4
    8000238e:	9bbfe0ef          	jal	80000d48 <memmove>
    return 0;
    80002392:	8526                	mv	a0,s1
    80002394:	b7cd                	j	80002376 <either_copyout+0x2c>

0000000080002396 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002396:	7179                	addi	sp,sp,-48
    80002398:	f406                	sd	ra,40(sp)
    8000239a:	f022                	sd	s0,32(sp)
    8000239c:	ec26                	sd	s1,24(sp)
    8000239e:	e84a                	sd	s2,16(sp)
    800023a0:	e44e                	sd	s3,8(sp)
    800023a2:	e052                	sd	s4,0(sp)
    800023a4:	1800                	addi	s0,sp,48
    800023a6:	8a2a                	mv	s4,a0
    800023a8:	84ae                	mv	s1,a1
    800023aa:	89b2                	mv	s3,a2
    800023ac:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800023ae:	da2ff0ef          	jal	80001950 <myproc>
  if (user_src) {
    800023b2:	c085                	beqz	s1,800023d2 <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    800023b4:	874a                	mv	a4,s2
    800023b6:	86ce                	mv	a3,s3
    800023b8:	8652                	mv	a2,s4
    800023ba:	652c                	ld	a1,72(a0)
    800023bc:	6928                	ld	a0,80(a0)
    800023be:	a92ff0ef          	jal	80001650 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800023c2:	70a2                	ld	ra,40(sp)
    800023c4:	7402                	ld	s0,32(sp)
    800023c6:	64e2                	ld	s1,24(sp)
    800023c8:	6942                	ld	s2,16(sp)
    800023ca:	69a2                	ld	s3,8(sp)
    800023cc:	6a02                	ld	s4,0(sp)
    800023ce:	6145                	addi	sp,sp,48
    800023d0:	8082                	ret
    memmove(dst, (char *)src, len);
    800023d2:	0009061b          	sext.w	a2,s2
    800023d6:	85ce                	mv	a1,s3
    800023d8:	8552                	mv	a0,s4
    800023da:	96ffe0ef          	jal	80000d48 <memmove>
    return 0;
    800023de:	8526                	mv	a0,s1
    800023e0:	b7cd                	j	800023c2 <either_copyin+0x2c>

00000000800023e2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800023e2:	715d                	addi	sp,sp,-80
    800023e4:	e486                	sd	ra,72(sp)
    800023e6:	e0a2                	sd	s0,64(sp)
    800023e8:	fc26                	sd	s1,56(sp)
    800023ea:	f84a                	sd	s2,48(sp)
    800023ec:	f44e                	sd	s3,40(sp)
    800023ee:	f052                	sd	s4,32(sp)
    800023f0:	ec56                	sd	s5,24(sp)
    800023f2:	e85a                	sd	s6,16(sp)
    800023f4:	e45e                	sd	s7,8(sp)
    800023f6:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    800023f8:	00005517          	auipc	a0,0x5
    800023fc:	c8050513          	addi	a0,a0,-896 # 80007078 <etext+0x78>
    80002400:	90afe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002404:	00010497          	auipc	s1,0x10
    80002408:	77c48493          	addi	s1,s1,1916 # 80012b80 <proc+0x158>
    8000240c:	00016917          	auipc	s2,0x16
    80002410:	17490913          	addi	s2,s2,372 # 80018580 <sems+0x128>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002414:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002416:	00005997          	auipc	s3,0x5
    8000241a:	e0a98993          	addi	s3,s3,-502 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    8000241e:	00005a97          	auipc	s5,0x5
    80002422:	e0aa8a93          	addi	s5,s5,-502 # 80007228 <etext+0x228>
    printk("\n");
    80002426:	00005a17          	auipc	s4,0x5
    8000242a:	c52a0a13          	addi	s4,s4,-942 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000242e:	00005b97          	auipc	s7,0x5
    80002432:	32ab8b93          	addi	s7,s7,810 # 80007758 <states.0>
    80002436:	a829                	j	80002450 <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002438:	ed86a583          	lw	a1,-296(a3)
    8000243c:	8556                	mv	a0,s5
    8000243e:	8ccfe0ef          	jal	8000050a <printk>
    printk("\n");
    80002442:	8552                	mv	a0,s4
    80002444:	8c6fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002448:	16848493          	addi	s1,s1,360
    8000244c:	03248263          	beq	s1,s2,80002470 <procdump+0x8e>
    if (p->state == UNUSED)
    80002450:	86a6                	mv	a3,s1
    80002452:	ec04a783          	lw	a5,-320(s1)
    80002456:	dbed                	beqz	a5,80002448 <procdump+0x66>
      state = "???";
    80002458:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000245a:	fcfb6fe3          	bltu	s6,a5,80002438 <procdump+0x56>
    8000245e:	02079713          	slli	a4,a5,0x20
    80002462:	01d75793          	srli	a5,a4,0x1d
    80002466:	97de                	add	a5,a5,s7
    80002468:	6390                	ld	a2,0(a5)
    8000246a:	f679                	bnez	a2,80002438 <procdump+0x56>
      state = "???";
    8000246c:	864e                	mv	a2,s3
    8000246e:	b7e9                	j	80002438 <procdump+0x56>
  }
}
    80002470:	60a6                	ld	ra,72(sp)
    80002472:	6406                	ld	s0,64(sp)
    80002474:	74e2                	ld	s1,56(sp)
    80002476:	7942                	ld	s2,48(sp)
    80002478:	79a2                	ld	s3,40(sp)
    8000247a:	7a02                	ld	s4,32(sp)
    8000247c:	6ae2                	ld	s5,24(sp)
    8000247e:	6b42                	ld	s6,16(sp)
    80002480:	6ba2                	ld	s7,8(sp)
    80002482:	6161                	addi	sp,sp,80
    80002484:	8082                	ret

0000000080002486 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002486:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000248a:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000248e:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002490:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002492:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002496:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000249a:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000249e:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800024a2:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800024a6:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800024aa:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800024ae:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800024b2:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800024b6:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800024ba:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800024be:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800024c2:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800024c4:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800024c6:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800024ca:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800024ce:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800024d2:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800024d6:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800024da:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800024de:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800024e2:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800024e6:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800024ea:	0685bd83          	ld	s11,104(a1)
        
        ret
    800024ee:	8082                	ret

00000000800024f0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800024f0:	1141                	addi	sp,sp,-16
    800024f2:	e406                	sd	ra,8(sp)
    800024f4:	e022                	sd	s0,0(sp)
    800024f6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800024f8:	00005597          	auipc	a1,0x5
    800024fc:	d7058593          	addi	a1,a1,-656 # 80007268 <etext+0x268>
    80002500:	00016517          	auipc	a0,0x16
    80002504:	f2850513          	addi	a0,a0,-216 # 80018428 <tickslock>
    80002508:	ea0fe0ef          	jal	80000ba8 <initlock>
}
    8000250c:	60a2                	ld	ra,8(sp)
    8000250e:	6402                	ld	s0,0(sp)
    80002510:	0141                	addi	sp,sp,16
    80002512:	8082                	ret

0000000080002514 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002514:	1141                	addi	sp,sp,-16
    80002516:	e406                	sd	ra,8(sp)
    80002518:	e022                	sd	s0,0(sp)
    8000251a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000251c:	00003797          	auipc	a5,0x3
    80002520:	45478793          	addi	a5,a5,1108 # 80005970 <kernelvec>
    80002524:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002528:	60a2                	ld	ra,8(sp)
    8000252a:	6402                	ld	s0,0(sp)
    8000252c:	0141                	addi	sp,sp,16
    8000252e:	8082                	ret

0000000080002530 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002530:	1141                	addi	sp,sp,-16
    80002532:	e406                	sd	ra,8(sp)
    80002534:	e022                	sd	s0,0(sp)
    80002536:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002538:	c18ff0ef          	jal	80001950 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    8000253c:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002540:	04000737          	lui	a4,0x4000
    80002544:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002546:	0732                	slli	a4,a4,0xc
    80002548:	00004797          	auipc	a5,0x4
    8000254c:	ab878793          	addi	a5,a5,-1352 # 80006000 <_trampoline>
    80002550:	00004697          	auipc	a3,0x4
    80002554:	ab068693          	addi	a3,a3,-1360 # 80006000 <_trampoline>
    80002558:	8f95                	sub	a5,a5,a3
    8000255a:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000255c:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002560:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    80002562:	18002773          	csrr	a4,satp
    80002566:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002568:	6d38                	ld	a4,88(a0)
    8000256a:	613c                	ld	a5,64(a0)
    8000256c:	6685                	lui	a3,0x1
    8000256e:	97b6                	add	a5,a5,a3
    80002570:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002572:	6d3c                	ld	a5,88(a0)
    80002574:	00000717          	auipc	a4,0x0
    80002578:	0fc70713          	addi	a4,a4,252 # 80002670 <usertrap>
    8000257c:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000257e:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    80002580:	8712                	mv	a4,tp
    80002582:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002584:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002588:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000258c:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002590:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002594:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002596:	6f9c                	ld	a5,24(a5)
    80002598:	14179073          	csrw	sepc,a5
}
    8000259c:	60a2                	ld	ra,8(sp)
    8000259e:	6402                	ld	s0,0(sp)
    800025a0:	0141                	addi	sp,sp,16
    800025a2:	8082                	ret

00000000800025a4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800025a4:	1141                	addi	sp,sp,-16
    800025a6:	e406                	sd	ra,8(sp)
    800025a8:	e022                	sd	s0,0(sp)
    800025aa:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    800025ac:	b70ff0ef          	jal	8000191c <cpuid>
    800025b0:	cd11                	beqz	a0,800025cc <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800025b2:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800025b6:	000f4737          	lui	a4,0xf4
    800025ba:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800025be:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    800025c0:	14d79073          	csrw	stimecmp,a5
}
    800025c4:	60a2                	ld	ra,8(sp)
    800025c6:	6402                	ld	s0,0(sp)
    800025c8:	0141                	addi	sp,sp,16
    800025ca:	8082                	ret
    acquire(&tickslock);
    800025cc:	00016517          	auipc	a0,0x16
    800025d0:	e5c50513          	addi	a0,a0,-420 # 80018428 <tickslock>
    800025d4:	e54fe0ef          	jal	80000c28 <acquire>
    ticks++;
    800025d8:	00008717          	auipc	a4,0x8
    800025dc:	f1070713          	addi	a4,a4,-240 # 8000a4e8 <ticks>
    800025e0:	431c                	lw	a5,0(a4)
    800025e2:	2785                	addiw	a5,a5,1
    800025e4:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800025e6:	853a                	mv	a0,a4
    800025e8:	a3dff0ef          	jal	80002024 <wakeup>
    release(&tickslock);
    800025ec:	00016517          	auipc	a0,0x16
    800025f0:	e3c50513          	addi	a0,a0,-452 # 80018428 <tickslock>
    800025f4:	ebcfe0ef          	jal	80000cb0 <release>
    800025f8:	bf6d                	j	800025b2 <clockintr+0xe>

00000000800025fa <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800025fa:	1101                	addi	sp,sp,-32
    800025fc:	ec06                	sd	ra,24(sp)
    800025fe:	e822                	sd	s0,16(sp)
    80002600:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    80002602:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002606:	57fd                	li	a5,-1
    80002608:	17fe                	slli	a5,a5,0x3f
    8000260a:	07a5                	addi	a5,a5,9
    8000260c:	00f70c63          	beq	a4,a5,80002624 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    80002610:	57fd                	li	a5,-1
    80002612:	17fe                	slli	a5,a5,0x3f
    80002614:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002616:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002618:	04f70863          	beq	a4,a5,80002668 <devintr+0x6e>
  }
}
    8000261c:	60e2                	ld	ra,24(sp)
    8000261e:	6442                	ld	s0,16(sp)
    80002620:	6105                	addi	sp,sp,32
    80002622:	8082                	ret
    80002624:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002626:	3f8030ef          	jal	80005a1e <plic_claim>
    8000262a:	872a                	mv	a4,a0
    8000262c:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    8000262e:	47a9                	li	a5,10
    80002630:	00f50963          	beq	a0,a5,80002642 <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    80002634:	4785                	li	a5,1
    80002636:	00f50963          	beq	a0,a5,80002648 <devintr+0x4e>
    return 1;
    8000263a:	4505                	li	a0,1
    } else if (irq) {
    8000263c:	eb09                	bnez	a4,8000264e <devintr+0x54>
    8000263e:	64a2                	ld	s1,8(sp)
    80002640:	bff1                	j	8000261c <devintr+0x22>
      uartintr();
    80002642:	bacfe0ef          	jal	800009ee <uartintr>
    if (irq)
    80002646:	a819                	j	8000265c <devintr+0x62>
      virtio_disk_intr();
    80002648:	093030ef          	jal	80005eda <virtio_disk_intr>
    if (irq)
    8000264c:	a801                	j	8000265c <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    8000264e:	85ba                	mv	a1,a4
    80002650:	00005517          	auipc	a0,0x5
    80002654:	c2050513          	addi	a0,a0,-992 # 80007270 <etext+0x270>
    80002658:	eb3fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    8000265c:	8526                	mv	a0,s1
    8000265e:	3e2030ef          	jal	80005a40 <plic_complete>
    return 1;
    80002662:	4505                	li	a0,1
    80002664:	64a2                	ld	s1,8(sp)
    80002666:	bf5d                	j	8000261c <devintr+0x22>
    clockintr();
    80002668:	f3dff0ef          	jal	800025a4 <clockintr>
    return 2;
    8000266c:	4509                	li	a0,2
    8000266e:	b77d                	j	8000261c <devintr+0x22>

0000000080002670 <usertrap>:
{
    80002670:	1101                	addi	sp,sp,-32
    80002672:	ec06                	sd	ra,24(sp)
    80002674:	e822                	sd	s0,16(sp)
    80002676:	e426                	sd	s1,8(sp)
    80002678:	e04a                	sd	s2,0(sp)
    8000267a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000267c:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002680:	1007f793          	andi	a5,a5,256
    80002684:	eba5                	bnez	a5,800026f4 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002686:	00003797          	auipc	a5,0x3
    8000268a:	2ea78793          	addi	a5,a5,746 # 80005970 <kernelvec>
    8000268e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002692:	abeff0ef          	jal	80001950 <myproc>
    80002696:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002698:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000269a:	14102773          	csrr	a4,sepc
    8000269e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800026a0:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800026a4:	47a1                	li	a5,8
    800026a6:	04f70d63          	beq	a4,a5,80002700 <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    800026aa:	f51ff0ef          	jal	800025fa <devintr>
    800026ae:	892a                	mv	s2,a0
    800026b0:	e54d                	bnez	a0,8000275a <usertrap+0xea>
    800026b2:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800026b6:	47bd                	li	a5,15
    800026b8:	08f70463          	beq	a4,a5,80002740 <usertrap+0xd0>
    800026bc:	14202773          	csrr	a4,scause
    800026c0:	47b5                	li	a5,13
    800026c2:	06f70f63          	beq	a4,a5,80002740 <usertrap+0xd0>
    800026c6:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800026ca:	5890                	lw	a2,48(s1)
    800026cc:	00005517          	auipc	a0,0x5
    800026d0:	be450513          	addi	a0,a0,-1052 # 800072b0 <etext+0x2b0>
    800026d4:	e37fd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026d8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800026dc:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800026e0:	00005517          	auipc	a0,0x5
    800026e4:	c0050513          	addi	a0,a0,-1024 # 800072e0 <etext+0x2e0>
    800026e8:	e23fd0ef          	jal	8000050a <printk>
    setkilled(p);
    800026ec:	8526                	mv	a0,s1
    800026ee:	b05ff0ef          	jal	800021f2 <setkilled>
    800026f2:	a015                	j	80002716 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    800026f4:	00005517          	auipc	a0,0x5
    800026f8:	b9c50513          	addi	a0,a0,-1124 # 80007290 <etext+0x290>
    800026fc:	938fe0ef          	jal	80000834 <panic>
    if (killed(p))
    80002700:	b17ff0ef          	jal	80002216 <killed>
    80002704:	e915                	bnez	a0,80002738 <usertrap+0xc8>
    p->trapframe->epc += 4;
    80002706:	6cb8                	ld	a4,88(s1)
    80002708:	6f1c                	ld	a5,24(a4)
    8000270a:	0791                	addi	a5,a5,4
    8000270c:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    8000270e:	10016073          	csrsi	sstatus,2
    syscall();
    80002712:	244000ef          	jal	80002956 <syscall>
  if (killed(p))
    80002716:	8526                	mv	a0,s1
    80002718:	affff0ef          	jal	80002216 <killed>
    8000271c:	e521                	bnez	a0,80002764 <usertrap+0xf4>
  prepare_return();
    8000271e:	e13ff0ef          	jal	80002530 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002722:	68a8                	ld	a0,80(s1)
    80002724:	8131                	srli	a0,a0,0xc
    80002726:	57fd                	li	a5,-1
    80002728:	17fe                	slli	a5,a5,0x3f
    8000272a:	8d5d                	or	a0,a0,a5
}
    8000272c:	60e2                	ld	ra,24(sp)
    8000272e:	6442                	ld	s0,16(sp)
    80002730:	64a2                	ld	s1,8(sp)
    80002732:	6902                	ld	s2,0(sp)
    80002734:	6105                	addi	sp,sp,32
    80002736:	8082                	ret
      kexit(-1);
    80002738:	557d                	li	a0,-1
    8000273a:	9a7ff0ef          	jal	800020e0 <kexit>
    8000273e:	b7e1                	j	80002706 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002740:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    80002744:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002748:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    8000274a:	0016b693          	seqz	a3,a3
    8000274e:	64ac                	ld	a1,72(s1)
    80002750:	68a8                	ld	a0,80(s1)
    80002752:	dbdfe0ef          	jal	8000150e <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002756:	f161                	bnez	a0,80002716 <usertrap+0xa6>
    80002758:	b7bd                	j	800026c6 <usertrap+0x56>
  if (killed(p))
    8000275a:	8526                	mv	a0,s1
    8000275c:	abbff0ef          	jal	80002216 <killed>
    80002760:	c511                	beqz	a0,8000276c <usertrap+0xfc>
    80002762:	a011                	j	80002766 <usertrap+0xf6>
    80002764:	4901                	li	s2,0
    kexit(-1);
    80002766:	557d                	li	a0,-1
    80002768:	979ff0ef          	jal	800020e0 <kexit>
  if (which_dev == 2)
    8000276c:	4789                	li	a5,2
    8000276e:	faf918e3          	bne	s2,a5,8000271e <usertrap+0xae>
    yield();
    80002772:	81bff0ef          	jal	80001f8c <yield>
    80002776:	b765                	j	8000271e <usertrap+0xae>

0000000080002778 <kerneltrap>:
{
    80002778:	7179                	addi	sp,sp,-48
    8000277a:	f406                	sd	ra,40(sp)
    8000277c:	f022                	sd	s0,32(sp)
    8000277e:	ec26                	sd	s1,24(sp)
    80002780:	e84a                	sd	s2,16(sp)
    80002782:	e44e                	sd	s3,8(sp)
    80002784:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002786:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000278a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    8000278e:	142027f3          	csrr	a5,scause
    80002792:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    80002794:	1004f793          	andi	a5,s1,256
    80002798:	c795                	beqz	a5,800027c4 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000279a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000279e:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800027a0:	eb85                	bnez	a5,800027d0 <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    800027a2:	e59ff0ef          	jal	800025fa <devintr>
    800027a6:	c91d                	beqz	a0,800027dc <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    800027a8:	4789                	li	a5,2
    800027aa:	04f50a63          	beq	a0,a5,800027fe <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    800027ae:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800027b2:	10049073          	csrw	sstatus,s1
}
    800027b6:	70a2                	ld	ra,40(sp)
    800027b8:	7402                	ld	s0,32(sp)
    800027ba:	64e2                	ld	s1,24(sp)
    800027bc:	6942                	ld	s2,16(sp)
    800027be:	69a2                	ld	s3,8(sp)
    800027c0:	6145                	addi	sp,sp,48
    800027c2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800027c4:	00005517          	auipc	a0,0x5
    800027c8:	b4450513          	addi	a0,a0,-1212 # 80007308 <etext+0x308>
    800027cc:	868fe0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    800027d0:	00005517          	auipc	a0,0x5
    800027d4:	b6050513          	addi	a0,a0,-1184 # 80007330 <etext+0x330>
    800027d8:	85cfe0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027dc:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800027e0:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800027e4:	85ce                	mv	a1,s3
    800027e6:	00005517          	auipc	a0,0x5
    800027ea:	b6a50513          	addi	a0,a0,-1174 # 80007350 <etext+0x350>
    800027ee:	d1dfd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    800027f2:	00005517          	auipc	a0,0x5
    800027f6:	b8650513          	addi	a0,a0,-1146 # 80007378 <etext+0x378>
    800027fa:	83afe0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    800027fe:	952ff0ef          	jal	80001950 <myproc>
    80002802:	d555                	beqz	a0,800027ae <kerneltrap+0x36>
    yield();
    80002804:	f88ff0ef          	jal	80001f8c <yield>
    80002808:	b75d                	j	800027ae <kerneltrap+0x36>

000000008000280a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000280a:	1101                	addi	sp,sp,-32
    8000280c:	ec06                	sd	ra,24(sp)
    8000280e:	e822                	sd	s0,16(sp)
    80002810:	e426                	sd	s1,8(sp)
    80002812:	1000                	addi	s0,sp,32
    80002814:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002816:	93aff0ef          	jal	80001950 <myproc>
  switch (n) {
    8000281a:	4795                	li	a5,5
    8000281c:	0497e163          	bltu	a5,s1,8000285e <argraw+0x54>
    80002820:	048a                	slli	s1,s1,0x2
    80002822:	00005717          	auipc	a4,0x5
    80002826:	f6670713          	addi	a4,a4,-154 # 80007788 <states.0+0x30>
    8000282a:	94ba                	add	s1,s1,a4
    8000282c:	409c                	lw	a5,0(s1)
    8000282e:	97ba                	add	a5,a5,a4
    80002830:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002832:	6d3c                	ld	a5,88(a0)
    80002834:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002836:	60e2                	ld	ra,24(sp)
    80002838:	6442                	ld	s0,16(sp)
    8000283a:	64a2                	ld	s1,8(sp)
    8000283c:	6105                	addi	sp,sp,32
    8000283e:	8082                	ret
    return p->trapframe->a1;
    80002840:	6d3c                	ld	a5,88(a0)
    80002842:	7fa8                	ld	a0,120(a5)
    80002844:	bfcd                	j	80002836 <argraw+0x2c>
    return p->trapframe->a2;
    80002846:	6d3c                	ld	a5,88(a0)
    80002848:	63c8                	ld	a0,128(a5)
    8000284a:	b7f5                	j	80002836 <argraw+0x2c>
    return p->trapframe->a3;
    8000284c:	6d3c                	ld	a5,88(a0)
    8000284e:	67c8                	ld	a0,136(a5)
    80002850:	b7dd                	j	80002836 <argraw+0x2c>
    return p->trapframe->a4;
    80002852:	6d3c                	ld	a5,88(a0)
    80002854:	6bc8                	ld	a0,144(a5)
    80002856:	b7c5                	j	80002836 <argraw+0x2c>
    return p->trapframe->a5;
    80002858:	6d3c                	ld	a5,88(a0)
    8000285a:	6fc8                	ld	a0,152(a5)
    8000285c:	bfe9                	j	80002836 <argraw+0x2c>
  panic("argraw");
    8000285e:	00005517          	auipc	a0,0x5
    80002862:	b2a50513          	addi	a0,a0,-1238 # 80007388 <etext+0x388>
    80002866:	fcffd0ef          	jal	80000834 <panic>

000000008000286a <fetchaddr>:
{
    8000286a:	1101                	addi	sp,sp,-32
    8000286c:	ec06                	sd	ra,24(sp)
    8000286e:	e822                	sd	s0,16(sp)
    80002870:	e426                	sd	s1,8(sp)
    80002872:	e04a                	sd	s2,0(sp)
    80002874:	1000                	addi	s0,sp,32
    80002876:	84aa                	mv	s1,a0
    80002878:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000287a:	8d6ff0ef          	jal	80001950 <myproc>
  if (addr >= p->sz ||
    8000287e:	652c                	ld	a1,72(a0)
    80002880:	02b4f663          	bgeu	s1,a1,800028ac <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002884:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002888:	02f5e463          	bltu	a1,a5,800028b0 <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    8000288c:	4721                	li	a4,8
    8000288e:	86a6                	mv	a3,s1
    80002890:	864a                	mv	a2,s2
    80002892:	6928                	ld	a0,80(a0)
    80002894:	dbdfe0ef          	jal	80001650 <copyin>
    80002898:	00a03533          	snez	a0,a0
    8000289c:	40a0053b          	negw	a0,a0
}
    800028a0:	60e2                	ld	ra,24(sp)
    800028a2:	6442                	ld	s0,16(sp)
    800028a4:	64a2                	ld	s1,8(sp)
    800028a6:	6902                	ld	s2,0(sp)
    800028a8:	6105                	addi	sp,sp,32
    800028aa:	8082                	ret
    return -1;
    800028ac:	557d                	li	a0,-1
    800028ae:	bfcd                	j	800028a0 <fetchaddr+0x36>
    800028b0:	557d                	li	a0,-1
    800028b2:	b7fd                	j	800028a0 <fetchaddr+0x36>

00000000800028b4 <fetchstr>:
{
    800028b4:	7179                	addi	sp,sp,-48
    800028b6:	f406                	sd	ra,40(sp)
    800028b8:	f022                	sd	s0,32(sp)
    800028ba:	ec26                	sd	s1,24(sp)
    800028bc:	e84a                	sd	s2,16(sp)
    800028be:	e44e                	sd	s3,8(sp)
    800028c0:	1800                	addi	s0,sp,48
    800028c2:	89aa                	mv	s3,a0
    800028c4:	84ae                	mv	s1,a1
    800028c6:	8932                	mv	s2,a2
  struct proc *p = myproc();
    800028c8:	888ff0ef          	jal	80001950 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    800028cc:	874a                	mv	a4,s2
    800028ce:	86ce                	mv	a3,s3
    800028d0:	8626                	mv	a2,s1
    800028d2:	652c                	ld	a1,72(a0)
    800028d4:	6928                	ld	a0,80(a0)
    800028d6:	e17fe0ef          	jal	800016ec <copyinstr>
    800028da:	00054c63          	bltz	a0,800028f2 <fetchstr+0x3e>
  return strlen(buf);
    800028de:	8526                	mv	a0,s1
    800028e0:	d92fe0ef          	jal	80000e72 <strlen>
}
    800028e4:	70a2                	ld	ra,40(sp)
    800028e6:	7402                	ld	s0,32(sp)
    800028e8:	64e2                	ld	s1,24(sp)
    800028ea:	6942                	ld	s2,16(sp)
    800028ec:	69a2                	ld	s3,8(sp)
    800028ee:	6145                	addi	sp,sp,48
    800028f0:	8082                	ret
    return -1;
    800028f2:	557d                	li	a0,-1
    800028f4:	bfc5                	j	800028e4 <fetchstr+0x30>

00000000800028f6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800028f6:	1101                	addi	sp,sp,-32
    800028f8:	ec06                	sd	ra,24(sp)
    800028fa:	e822                	sd	s0,16(sp)
    800028fc:	e426                	sd	s1,8(sp)
    800028fe:	1000                	addi	s0,sp,32
    80002900:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002902:	f09ff0ef          	jal	8000280a <argraw>
    80002906:	c088                	sw	a0,0(s1)
}
    80002908:	60e2                	ld	ra,24(sp)
    8000290a:	6442                	ld	s0,16(sp)
    8000290c:	64a2                	ld	s1,8(sp)
    8000290e:	6105                	addi	sp,sp,32
    80002910:	8082                	ret

0000000080002912 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002912:	1101                	addi	sp,sp,-32
    80002914:	ec06                	sd	ra,24(sp)
    80002916:	e822                	sd	s0,16(sp)
    80002918:	e426                	sd	s1,8(sp)
    8000291a:	1000                	addi	s0,sp,32
    8000291c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000291e:	eedff0ef          	jal	8000280a <argraw>
    80002922:	e088                	sd	a0,0(s1)
}
    80002924:	60e2                	ld	ra,24(sp)
    80002926:	6442                	ld	s0,16(sp)
    80002928:	64a2                	ld	s1,8(sp)
    8000292a:	6105                	addi	sp,sp,32
    8000292c:	8082                	ret

000000008000292e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000292e:	1101                	addi	sp,sp,-32
    80002930:	ec06                	sd	ra,24(sp)
    80002932:	e822                	sd	s0,16(sp)
    80002934:	e426                	sd	s1,8(sp)
    80002936:	e04a                	sd	s2,0(sp)
    80002938:	1000                	addi	s0,sp,32
    8000293a:	892e                	mv	s2,a1
    8000293c:	84b2                	mv	s1,a2
  *ip = argraw(n);
    8000293e:	ecdff0ef          	jal	8000280a <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002942:	8626                	mv	a2,s1
    80002944:	85ca                	mv	a1,s2
    80002946:	f6fff0ef          	jal	800028b4 <fetchstr>
}
    8000294a:	60e2                	ld	ra,24(sp)
    8000294c:	6442                	ld	s0,16(sp)
    8000294e:	64a2                	ld	s1,8(sp)
    80002950:	6902                	ld	s2,0(sp)
    80002952:	6105                	addi	sp,sp,32
    80002954:	8082                	ret

0000000080002956 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002956:	1101                	addi	sp,sp,-32
    80002958:	ec06                	sd	ra,24(sp)
    8000295a:	e822                	sd	s0,16(sp)
    8000295c:	e426                	sd	s1,8(sp)
    8000295e:	e04a                	sd	s2,0(sp)
    80002960:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002962:	feffe0ef          	jal	80001950 <myproc>
    80002966:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002968:	05853903          	ld	s2,88(a0)
    8000296c:	0a893783          	ld	a5,168(s2)
    80002970:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002974:	37fd                	addiw	a5,a5,-1
    80002976:	4765                	li	a4,25
    80002978:	00f76f63          	bltu	a4,a5,80002996 <syscall+0x40>
    8000297c:	00369713          	slli	a4,a3,0x3
    80002980:	00005797          	auipc	a5,0x5
    80002984:	e2078793          	addi	a5,a5,-480 # 800077a0 <syscalls>
    80002988:	97ba                	add	a5,a5,a4
    8000298a:	639c                	ld	a5,0(a5)
    8000298c:	c789                	beqz	a5,80002996 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000298e:	9782                	jalr	a5
    80002990:	06a93823          	sd	a0,112(s2)
    80002994:	a829                	j	800029ae <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002996:	15848613          	addi	a2,s1,344
    8000299a:	588c                	lw	a1,48(s1)
    8000299c:	00005517          	auipc	a0,0x5
    800029a0:	9f450513          	addi	a0,a0,-1548 # 80007390 <etext+0x390>
    800029a4:	b67fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    800029a8:	6cbc                	ld	a5,88(s1)
    800029aa:	577d                	li	a4,-1
    800029ac:	fbb8                	sd	a4,112(a5)
  }
}
    800029ae:	60e2                	ld	ra,24(sp)
    800029b0:	6442                	ld	s0,16(sp)
    800029b2:	64a2                	ld	s1,8(sp)
    800029b4:	6902                	ld	s2,0(sp)
    800029b6:	6105                	addi	sp,sp,32
    800029b8:	8082                	ret

00000000800029ba <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800029ba:	1101                	addi	sp,sp,-32
    800029bc:	ec06                	sd	ra,24(sp)
    800029be:	e822                	sd	s0,16(sp)
    800029c0:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800029c2:	fec40593          	addi	a1,s0,-20
    800029c6:	4501                	li	a0,0
    800029c8:	f2fff0ef          	jal	800028f6 <argint>
  kexit(n);
    800029cc:	fec42503          	lw	a0,-20(s0)
    800029d0:	f10ff0ef          	jal	800020e0 <kexit>
  return 0; // not reached
}
    800029d4:	4501                	li	a0,0
    800029d6:	60e2                	ld	ra,24(sp)
    800029d8:	6442                	ld	s0,16(sp)
    800029da:	6105                	addi	sp,sp,32
    800029dc:	8082                	ret

00000000800029de <sys_getpid>:

uint64
sys_getpid(void)
{
    800029de:	1141                	addi	sp,sp,-16
    800029e0:	e406                	sd	ra,8(sp)
    800029e2:	e022                	sd	s0,0(sp)
    800029e4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800029e6:	f6bfe0ef          	jal	80001950 <myproc>
}
    800029ea:	5908                	lw	a0,48(a0)
    800029ec:	60a2                	ld	ra,8(sp)
    800029ee:	6402                	ld	s0,0(sp)
    800029f0:	0141                	addi	sp,sp,16
    800029f2:	8082                	ret

00000000800029f4 <sys_fork>:

uint64
sys_fork(void)
{
    800029f4:	1141                	addi	sp,sp,-16
    800029f6:	e406                	sd	ra,8(sp)
    800029f8:	e022                	sd	s0,0(sp)
    800029fa:	0800                	addi	s0,sp,16
  return kfork();
    800029fc:	ac6ff0ef          	jal	80001cc2 <kfork>
}
    80002a00:	60a2                	ld	ra,8(sp)
    80002a02:	6402                	ld	s0,0(sp)
    80002a04:	0141                	addi	sp,sp,16
    80002a06:	8082                	ret

0000000080002a08 <sys_wait>:

uint64
sys_wait(void)
{
    80002a08:	1101                	addi	sp,sp,-32
    80002a0a:	ec06                	sd	ra,24(sp)
    80002a0c:	e822                	sd	s0,16(sp)
    80002a0e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a10:	fe840593          	addi	a1,s0,-24
    80002a14:	4501                	li	a0,0
    80002a16:	efdff0ef          	jal	80002912 <argaddr>
  return kwait(p);
    80002a1a:	fe843503          	ld	a0,-24(s0)
    80002a1e:	823ff0ef          	jal	80002240 <kwait>
}
    80002a22:	60e2                	ld	ra,24(sp)
    80002a24:	6442                	ld	s0,16(sp)
    80002a26:	6105                	addi	sp,sp,32
    80002a28:	8082                	ret

0000000080002a2a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a2a:	7179                	addi	sp,sp,-48
    80002a2c:	f406                	sd	ra,40(sp)
    80002a2e:	f022                	sd	s0,32(sp)
    80002a30:	ec26                	sd	s1,24(sp)
    80002a32:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a34:	fd840593          	addi	a1,s0,-40
    80002a38:	4501                	li	a0,0
    80002a3a:	ebdff0ef          	jal	800028f6 <argint>
  argint(1, &t);
    80002a3e:	fdc40593          	addi	a1,s0,-36
    80002a42:	4505                	li	a0,1
    80002a44:	eb3ff0ef          	jal	800028f6 <argint>
  addr = myproc()->sz;
    80002a48:	f09fe0ef          	jal	80001950 <myproc>
    80002a4c:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002a4e:	fdc42703          	lw	a4,-36(s0)
    80002a52:	4785                	li	a5,1
    80002a54:	02f70763          	beq	a4,a5,80002a82 <sys_sbrk+0x58>
    80002a58:	fd842783          	lw	a5,-40(s0)
    80002a5c:	0207c363          	bltz	a5,80002a82 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002a60:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002a62:	02000737          	lui	a4,0x2000
    80002a66:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002a68:	0736                	slli	a4,a4,0xd
    80002a6a:	02f76a63          	bltu	a4,a5,80002a9e <sys_sbrk+0x74>
    80002a6e:	0297e863          	bltu	a5,s1,80002a9e <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002a72:	edffe0ef          	jal	80001950 <myproc>
    80002a76:	fd842703          	lw	a4,-40(s0)
    80002a7a:	653c                	ld	a5,72(a0)
    80002a7c:	97ba                	add	a5,a5,a4
    80002a7e:	e53c                	sd	a5,72(a0)
    80002a80:	a039                	j	80002a8e <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002a82:	fd842503          	lw	a0,-40(s0)
    80002a86:	9daff0ef          	jal	80001c60 <growproc>
    80002a8a:	00054863          	bltz	a0,80002a9a <sys_sbrk+0x70>
  }
  return addr;
}
    80002a8e:	8526                	mv	a0,s1
    80002a90:	70a2                	ld	ra,40(sp)
    80002a92:	7402                	ld	s0,32(sp)
    80002a94:	64e2                	ld	s1,24(sp)
    80002a96:	6145                	addi	sp,sp,48
    80002a98:	8082                	ret
      return -1;
    80002a9a:	54fd                	li	s1,-1
    80002a9c:	bfcd                	j	80002a8e <sys_sbrk+0x64>
      return -1;
    80002a9e:	54fd                	li	s1,-1
    80002aa0:	b7fd                	j	80002a8e <sys_sbrk+0x64>

0000000080002aa2 <sys_pause>:

uint64
sys_pause(void)
{
    80002aa2:	7139                	addi	sp,sp,-64
    80002aa4:	fc06                	sd	ra,56(sp)
    80002aa6:	f822                	sd	s0,48(sp)
    80002aa8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002aaa:	fcc40593          	addi	a1,s0,-52
    80002aae:	4501                	li	a0,0
    80002ab0:	e47ff0ef          	jal	800028f6 <argint>
  if (n < 0)
    80002ab4:	fcc42783          	lw	a5,-52(s0)
    80002ab8:	0807c063          	bltz	a5,80002b38 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002abc:	00016517          	auipc	a0,0x16
    80002ac0:	96c50513          	addi	a0,a0,-1684 # 80018428 <tickslock>
    80002ac4:	964fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002ac8:	fcc42783          	lw	a5,-52(s0)
    80002acc:	cbb9                	beqz	a5,80002b22 <sys_pause+0x80>
    80002ace:	f426                	sd	s1,40(sp)
    80002ad0:	f04a                	sd	s2,32(sp)
    80002ad2:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002ad4:	00008997          	auipc	s3,0x8
    80002ad8:	a149a983          	lw	s3,-1516(s3) # 8000a4e8 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002adc:	00008917          	auipc	s2,0x8
    80002ae0:	a0c90913          	addi	s2,s2,-1524 # 8000a4e8 <ticks>
    release(&tickslock);
    80002ae4:	00016497          	auipc	s1,0x16
    80002ae8:	94448493          	addi	s1,s1,-1724 # 80018428 <tickslock>
    if (killed(myproc())) {
    80002aec:	e65fe0ef          	jal	80001950 <myproc>
    80002af0:	f26ff0ef          	jal	80002216 <killed>
    80002af4:	e529                	bnez	a0,80002b3e <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002af6:	854a                	mv	a0,s2
    80002af8:	cc0ff0ef          	jal	80001fb8 <sleep_prepare>
    release(&tickslock);
    80002afc:	8526                	mv	a0,s1
    80002afe:	9b2fe0ef          	jal	80000cb0 <release>
    sleep();
    80002b02:	cf2ff0ef          	jal	80001ff4 <sleep>
    acquire(&tickslock);
    80002b06:	8526                	mv	a0,s1
    80002b08:	920fe0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002b0c:	00092783          	lw	a5,0(s2)
    80002b10:	413787bb          	subw	a5,a5,s3
    80002b14:	fcc42703          	lw	a4,-52(s0)
    80002b18:	fce7eae3          	bltu	a5,a4,80002aec <sys_pause+0x4a>
    80002b1c:	74a2                	ld	s1,40(sp)
    80002b1e:	7902                	ld	s2,32(sp)
    80002b20:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b22:	00016517          	auipc	a0,0x16
    80002b26:	90650513          	addi	a0,a0,-1786 # 80018428 <tickslock>
    80002b2a:	986fe0ef          	jal	80000cb0 <release>
  return 0;
    80002b2e:	4501                	li	a0,0
}
    80002b30:	70e2                	ld	ra,56(sp)
    80002b32:	7442                	ld	s0,48(sp)
    80002b34:	6121                	addi	sp,sp,64
    80002b36:	8082                	ret
    n = 0;
    80002b38:	fc042623          	sw	zero,-52(s0)
    80002b3c:	b741                	j	80002abc <sys_pause+0x1a>
      release(&tickslock);
    80002b3e:	00016517          	auipc	a0,0x16
    80002b42:	8ea50513          	addi	a0,a0,-1814 # 80018428 <tickslock>
    80002b46:	96afe0ef          	jal	80000cb0 <release>
      return -1;
    80002b4a:	557d                	li	a0,-1
    80002b4c:	74a2                	ld	s1,40(sp)
    80002b4e:	7902                	ld	s2,32(sp)
    80002b50:	69e2                	ld	s3,24(sp)
    80002b52:	bff9                	j	80002b30 <sys_pause+0x8e>

0000000080002b54 <sys_kill>:

uint64
sys_kill(void)
{
    80002b54:	1101                	addi	sp,sp,-32
    80002b56:	ec06                	sd	ra,24(sp)
    80002b58:	e822                	sd	s0,16(sp)
    80002b5a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b5c:	fec40593          	addi	a1,s0,-20
    80002b60:	4501                	li	a0,0
    80002b62:	d95ff0ef          	jal	800028f6 <argint>
  return kkill(pid);
    80002b66:	fec42503          	lw	a0,-20(s0)
    80002b6a:	e1cff0ef          	jal	80002186 <kkill>
}
    80002b6e:	60e2                	ld	ra,24(sp)
    80002b70:	6442                	ld	s0,16(sp)
    80002b72:	6105                	addi	sp,sp,32
    80002b74:	8082                	ret

0000000080002b76 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b76:	1101                	addi	sp,sp,-32
    80002b78:	ec06                	sd	ra,24(sp)
    80002b7a:	e822                	sd	s0,16(sp)
    80002b7c:	e426                	sd	s1,8(sp)
    80002b7e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b80:	00016517          	auipc	a0,0x16
    80002b84:	8a850513          	addi	a0,a0,-1880 # 80018428 <tickslock>
    80002b88:	8a0fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002b8c:	00008797          	auipc	a5,0x8
    80002b90:	95c7a783          	lw	a5,-1700(a5) # 8000a4e8 <ticks>
    80002b94:	84be                	mv	s1,a5
  release(&tickslock);
    80002b96:	00016517          	auipc	a0,0x16
    80002b9a:	89250513          	addi	a0,a0,-1902 # 80018428 <tickslock>
    80002b9e:	912fe0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002ba2:	02049513          	slli	a0,s1,0x20
    80002ba6:	9101                	srli	a0,a0,0x20
    80002ba8:	60e2                	ld	ra,24(sp)
    80002baa:	6442                	ld	s0,16(sp)
    80002bac:	64a2                	ld	s1,8(sp)
    80002bae:	6105                	addi	sp,sp,32
    80002bb0:	8082                	ret

0000000080002bb2 <shminit>:
static char *global_shm_page = 0;
static struct spinlock global_shm_lock;

void
shminit(void)
{
    80002bb2:	1141                	addi	sp,sp,-16
    80002bb4:	e406                	sd	ra,8(sp)
    80002bb6:	e022                	sd	s0,0(sp)
    80002bb8:	0800                	addi	s0,sp,16
  initlock(&global_shm_lock, "shm");
    80002bba:	00004597          	auipc	a1,0x4
    80002bbe:	7f658593          	addi	a1,a1,2038 # 800073b0 <etext+0x3b0>
    80002bc2:	00016517          	auipc	a0,0x16
    80002bc6:	87e50513          	addi	a0,a0,-1922 # 80018440 <global_shm_lock>
    80002bca:	fdffd0ef          	jal	80000ba8 <initlock>
}
    80002bce:	60a2                	ld	ra,8(sp)
    80002bd0:	6402                	ld	s0,0(sp)
    80002bd2:	0141                	addi	sp,sp,16
    80002bd4:	8082                	ret

0000000080002bd6 <shm_get>:

uint64
shm_get(void)
{
    80002bd6:	1101                	addi	sp,sp,-32
    80002bd8:	ec06                	sd	ra,24(sp)
    80002bda:	e822                	sd	s0,16(sp)
    80002bdc:	e426                	sd	s1,8(sp)
    80002bde:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002be0:	d71fe0ef          	jal	80001950 <myproc>
    80002be4:	84aa                	mv	s1,a0

  acquire(&global_shm_lock);
    80002be6:	00016517          	auipc	a0,0x16
    80002bea:	85a50513          	addi	a0,a0,-1958 # 80018440 <global_shm_lock>
    80002bee:	83afe0ef          	jal	80000c28 <acquire>
  if (global_shm_page == 0) {
    80002bf2:	00008797          	auipc	a5,0x8
    80002bf6:	8fe7b783          	ld	a5,-1794(a5) # 8000a4f0 <global_shm_page>
    80002bfa:	cbb1                	beqz	a5,80002c4e <shm_get+0x78>
      return 0;
    }
    memset(global_shm_page, 0, PGSIZE);
  }

  pte_t *pte = walk(p->pagetable, SHM_VA, 0);
    80002bfc:	4601                	li	a2,0
    80002bfe:	040005b7          	lui	a1,0x4000
    80002c02:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80002c04:	05b2                	slli	a1,a1,0xc
    80002c06:	68a8                	ld	a0,80(s1)
    80002c08:	b7efe0ef          	jal	80000f86 <walk>
  if (pte == 0 || (*pte & PTE_V) == 0) {
    80002c0c:	c501                	beqz	a0,80002c14 <shm_get+0x3e>
    80002c0e:	611c                	ld	a5,0(a0)
    80002c10:	8b85                	andi	a5,a5,1
    80002c12:	ef99                	bnez	a5,80002c30 <shm_get+0x5a>
    if (mappages(p->pagetable, SHM_VA, PGSIZE, (uint64)global_shm_page, PTE_R | PTE_W | PTE_U) != 0) {
    80002c14:	4759                	li	a4,22
    80002c16:	00008697          	auipc	a3,0x8
    80002c1a:	8da6b683          	ld	a3,-1830(a3) # 8000a4f0 <global_shm_page>
    80002c1e:	6605                	lui	a2,0x1
    80002c20:	040005b7          	lui	a1,0x4000
    80002c24:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80002c26:	05b2                	slli	a1,a1,0xc
    80002c28:	68a8                	ld	a0,80(s1)
    80002c2a:	c30fe0ef          	jal	8000105a <mappages>
    80002c2e:	e521                	bnez	a0,80002c76 <shm_get+0xa0>
      release(&global_shm_lock);
      return 0;
    }
  }
  release(&global_shm_lock);
    80002c30:	00016517          	auipc	a0,0x16
    80002c34:	81050513          	addi	a0,a0,-2032 # 80018440 <global_shm_lock>
    80002c38:	878fe0ef          	jal	80000cb0 <release>
  return SHM_VA;
    80002c3c:	04000537          	lui	a0,0x4000
    80002c40:	1575                	addi	a0,a0,-3 # 3fffffd <_entry-0x7c000003>
    80002c42:	0532                	slli	a0,a0,0xc
}
    80002c44:	60e2                	ld	ra,24(sp)
    80002c46:	6442                	ld	s0,16(sp)
    80002c48:	64a2                	ld	s1,8(sp)
    80002c4a:	6105                	addi	sp,sp,32
    80002c4c:	8082                	ret
    global_shm_page = kalloc();
    80002c4e:	f01fd0ef          	jal	80000b4e <kalloc>
    80002c52:	00008797          	auipc	a5,0x8
    80002c56:	88a7bf23          	sd	a0,-1890(a5) # 8000a4f0 <global_shm_page>
    if (global_shm_page == 0) {
    80002c5a:	c511                	beqz	a0,80002c66 <shm_get+0x90>
    memset(global_shm_page, 0, PGSIZE);
    80002c5c:	6605                	lui	a2,0x1
    80002c5e:	4581                	li	a1,0
    80002c60:	888fe0ef          	jal	80000ce8 <memset>
    80002c64:	bf61                	j	80002bfc <shm_get+0x26>
      release(&global_shm_lock);
    80002c66:	00015517          	auipc	a0,0x15
    80002c6a:	7da50513          	addi	a0,a0,2010 # 80018440 <global_shm_lock>
    80002c6e:	842fe0ef          	jal	80000cb0 <release>
      return 0;
    80002c72:	4501                	li	a0,0
    80002c74:	bfc1                	j	80002c44 <shm_get+0x6e>
      release(&global_shm_lock);
    80002c76:	00015517          	auipc	a0,0x15
    80002c7a:	7ca50513          	addi	a0,a0,1994 # 80018440 <global_shm_lock>
    80002c7e:	832fe0ef          	jal	80000cb0 <release>
      return 0;
    80002c82:	4501                	li	a0,0
    80002c84:	b7c1                	j	80002c44 <shm_get+0x6e>

0000000080002c86 <sys_shm_get>:

uint64
sys_shm_get(void)
{
    80002c86:	1141                	addi	sp,sp,-16
    80002c88:	e406                	sd	ra,8(sp)
    80002c8a:	e022                	sd	s0,0(sp)
    80002c8c:	0800                	addi	s0,sp,16
  return shm_get();
    80002c8e:	f49ff0ef          	jal	80002bd6 <shm_get>
}
    80002c92:	60a2                	ld	ra,8(sp)
    80002c94:	6402                	ld	s0,0(sp)
    80002c96:	0141                	addi	sp,sp,16
    80002c98:	8082                	ret

0000000080002c9a <seminit>:

static struct semaphore sems[MAX_SEM];

void
seminit(void)
{
    80002c9a:	7179                	addi	sp,sp,-48
    80002c9c:	f406                	sd	ra,40(sp)
    80002c9e:	f022                	sd	s0,32(sp)
    80002ca0:	ec26                	sd	s1,24(sp)
    80002ca2:	e84a                	sd	s2,16(sp)
    80002ca4:	e44e                	sd	s3,8(sp)
    80002ca6:	1800                	addi	s0,sp,48
  for (int i = 0; i < MAX_SEM; i++) {
    80002ca8:	00015497          	auipc	s1,0x15
    80002cac:	7b048493          	addi	s1,s1,1968 # 80018458 <sems>
    80002cb0:	00016997          	auipc	s3,0x16
    80002cb4:	ba898993          	addi	s3,s3,-1112 # 80018858 <bcache>
    initlock(&sems[i].lock, "sem");
    80002cb8:	00004917          	auipc	s2,0x4
    80002cbc:	70090913          	addi	s2,s2,1792 # 800073b8 <etext+0x3b8>
    80002cc0:	85ca                	mv	a1,s2
    80002cc2:	8526                	mv	a0,s1
    80002cc4:	ee5fd0ef          	jal	80000ba8 <initlock>
    sems[i].value = 0;
    80002cc8:	0004ac23          	sw	zero,24(s1)
    sems[i].active = 0;
    80002ccc:	0004ae23          	sw	zero,28(s1)
  for (int i = 0; i < MAX_SEM; i++) {
    80002cd0:	02048493          	addi	s1,s1,32
    80002cd4:	ff3496e3          	bne	s1,s3,80002cc0 <seminit+0x26>
  }
}
    80002cd8:	70a2                	ld	ra,40(sp)
    80002cda:	7402                	ld	s0,32(sp)
    80002cdc:	64e2                	ld	s1,24(sp)
    80002cde:	6942                	ld	s2,16(sp)
    80002ce0:	69a2                	ld	s3,8(sp)
    80002ce2:	6145                	addi	sp,sp,48
    80002ce4:	8082                	ret

0000000080002ce6 <ksem_init>:

int
ksem_init(int id, int val)
{
  if (id < 0 || id >= MAX_SEM)
    80002ce6:	47fd                	li	a5,31
    80002ce8:	04a7e863          	bltu	a5,a0,80002d38 <ksem_init+0x52>
{
    80002cec:	7179                	addi	sp,sp,-48
    80002cee:	f406                	sd	ra,40(sp)
    80002cf0:	f022                	sd	s0,32(sp)
    80002cf2:	ec26                	sd	s1,24(sp)
    80002cf4:	e84a                	sd	s2,16(sp)
    80002cf6:	e44e                	sd	s3,8(sp)
    80002cf8:	1800                	addi	s0,sp,48
    80002cfa:	89ae                	mv	s3,a1
    return -1;
  acquire(&sems[id].lock);
    80002cfc:	00551493          	slli	s1,a0,0x5
    80002d00:	00015917          	auipc	s2,0x15
    80002d04:	75890913          	addi	s2,s2,1880 # 80018458 <sems>
    80002d08:	9926                	add	s2,s2,s1
    80002d0a:	854a                	mv	a0,s2
    80002d0c:	f1dfd0ef          	jal	80000c28 <acquire>
  sems[id].value = val;
    80002d10:	00015797          	auipc	a5,0x15
    80002d14:	73078793          	addi	a5,a5,1840 # 80018440 <global_shm_lock>
    80002d18:	97a6                	add	a5,a5,s1
    80002d1a:	0337a823          	sw	s3,48(a5)
  sems[id].active = 1;
    80002d1e:	4705                	li	a4,1
    80002d20:	dbd8                	sw	a4,52(a5)
  release(&sems[id].lock);
    80002d22:	854a                	mv	a0,s2
    80002d24:	f8dfd0ef          	jal	80000cb0 <release>
  return 0;
    80002d28:	4501                	li	a0,0
}
    80002d2a:	70a2                	ld	ra,40(sp)
    80002d2c:	7402                	ld	s0,32(sp)
    80002d2e:	64e2                	ld	s1,24(sp)
    80002d30:	6942                	ld	s2,16(sp)
    80002d32:	69a2                	ld	s3,8(sp)
    80002d34:	6145                	addi	sp,sp,48
    80002d36:	8082                	ret
    return -1;
    80002d38:	557d                	li	a0,-1
}
    80002d3a:	8082                	ret

0000000080002d3c <ksem_wait>:

int
ksem_wait(int id)
{
  if (id < 0 || id >= MAX_SEM)
    80002d3c:	47fd                	li	a5,31
    80002d3e:	08a7e463          	bltu	a5,a0,80002dc6 <ksem_wait+0x8a>
{
    80002d42:	7179                	addi	sp,sp,-48
    80002d44:	f406                	sd	ra,40(sp)
    80002d46:	f022                	sd	s0,32(sp)
    80002d48:	ec26                	sd	s1,24(sp)
    80002d4a:	e84a                	sd	s2,16(sp)
    80002d4c:	e44e                	sd	s3,8(sp)
    80002d4e:	1800                	addi	s0,sp,48
    80002d50:	89aa                	mv	s3,a0
    return -1;
  acquire(&sems[id].lock);
    80002d52:	00551913          	slli	s2,a0,0x5
    80002d56:	00015497          	auipc	s1,0x15
    80002d5a:	70248493          	addi	s1,s1,1794 # 80018458 <sems>
    80002d5e:	94ca                	add	s1,s1,s2
    80002d60:	8526                	mv	a0,s1
    80002d62:	ec7fd0ef          	jal	80000c28 <acquire>
  while (sems[id].value <= 0) {
    80002d66:	00015797          	auipc	a5,0x15
    80002d6a:	6da78793          	addi	a5,a5,1754 # 80018440 <global_shm_lock>
    80002d6e:	97ca                	add	a5,a5,s2
    80002d70:	5b9c                	lw	a5,48(a5)
    80002d72:	02f04763          	bgtz	a5,80002da0 <ksem_wait+0x64>
    80002d76:	87ca                	mv	a5,s2
    80002d78:	00015917          	auipc	s2,0x15
    80002d7c:	6c890913          	addi	s2,s2,1736 # 80018440 <global_shm_lock>
    80002d80:	993e                	add	s2,s2,a5
    sleep_prepare(&sems[id]);
    80002d82:	8526                	mv	a0,s1
    80002d84:	a34ff0ef          	jal	80001fb8 <sleep_prepare>
    release(&sems[id].lock);
    80002d88:	8526                	mv	a0,s1
    80002d8a:	f27fd0ef          	jal	80000cb0 <release>
    sleep();
    80002d8e:	a66ff0ef          	jal	80001ff4 <sleep>
    acquire(&sems[id].lock);
    80002d92:	8526                	mv	a0,s1
    80002d94:	e95fd0ef          	jal	80000c28 <acquire>
  while (sems[id].value <= 0) {
    80002d98:	03092783          	lw	a5,48(s2)
    80002d9c:	fef053e3          	blez	a5,80002d82 <ksem_wait+0x46>
  }
  sems[id].value--;
    80002da0:	0996                	slli	s3,s3,0x5
    80002da2:	00015717          	auipc	a4,0x15
    80002da6:	69e70713          	addi	a4,a4,1694 # 80018440 <global_shm_lock>
    80002daa:	974e                	add	a4,a4,s3
    80002dac:	37fd                	addiw	a5,a5,-1
    80002dae:	db1c                	sw	a5,48(a4)
  release(&sems[id].lock);
    80002db0:	8526                	mv	a0,s1
    80002db2:	efffd0ef          	jal	80000cb0 <release>
  return 0;
    80002db6:	4501                	li	a0,0
}
    80002db8:	70a2                	ld	ra,40(sp)
    80002dba:	7402                	ld	s0,32(sp)
    80002dbc:	64e2                	ld	s1,24(sp)
    80002dbe:	6942                	ld	s2,16(sp)
    80002dc0:	69a2                	ld	s3,8(sp)
    80002dc2:	6145                	addi	sp,sp,48
    80002dc4:	8082                	ret
    return -1;
    80002dc6:	557d                	li	a0,-1
}
    80002dc8:	8082                	ret

0000000080002dca <ksem_post>:

int
ksem_post(int id)
{
  if (id < 0 || id >= MAX_SEM)
    80002dca:	47fd                	li	a5,31
    80002dcc:	04a7e763          	bltu	a5,a0,80002e1a <ksem_post+0x50>
{
    80002dd0:	1101                	addi	sp,sp,-32
    80002dd2:	ec06                	sd	ra,24(sp)
    80002dd4:	e822                	sd	s0,16(sp)
    80002dd6:	e426                	sd	s1,8(sp)
    80002dd8:	e04a                	sd	s2,0(sp)
    80002dda:	1000                	addi	s0,sp,32
    return -1;
  acquire(&sems[id].lock);
    80002ddc:	00551493          	slli	s1,a0,0x5
    80002de0:	00015917          	auipc	s2,0x15
    80002de4:	67890913          	addi	s2,s2,1656 # 80018458 <sems>
    80002de8:	9926                	add	s2,s2,s1
    80002dea:	854a                	mv	a0,s2
    80002dec:	e3dfd0ef          	jal	80000c28 <acquire>
  sems[id].value++;
    80002df0:	00015797          	auipc	a5,0x15
    80002df4:	65078793          	addi	a5,a5,1616 # 80018440 <global_shm_lock>
    80002df8:	97a6                	add	a5,a5,s1
    80002dfa:	5b98                	lw	a4,48(a5)
    80002dfc:	2705                	addiw	a4,a4,1
    80002dfe:	db98                	sw	a4,48(a5)
  wakeup(&sems[id]);
    80002e00:	854a                	mv	a0,s2
    80002e02:	a22ff0ef          	jal	80002024 <wakeup>
  release(&sems[id].lock);
    80002e06:	854a                	mv	a0,s2
    80002e08:	ea9fd0ef          	jal	80000cb0 <release>
  return 0;
    80002e0c:	4501                	li	a0,0
}
    80002e0e:	60e2                	ld	ra,24(sp)
    80002e10:	6442                	ld	s0,16(sp)
    80002e12:	64a2                	ld	s1,8(sp)
    80002e14:	6902                	ld	s2,0(sp)
    80002e16:	6105                	addi	sp,sp,32
    80002e18:	8082                	ret
    return -1;
    80002e1a:	557d                	li	a0,-1
}
    80002e1c:	8082                	ret

0000000080002e1e <sys_sem_init>:

uint64
sys_sem_init(void)
{
    80002e1e:	1101                	addi	sp,sp,-32
    80002e20:	ec06                	sd	ra,24(sp)
    80002e22:	e822                	sd	s0,16(sp)
    80002e24:	1000                	addi	s0,sp,32
  int id, val;
  argint(0, &id);
    80002e26:	fec40593          	addi	a1,s0,-20
    80002e2a:	4501                	li	a0,0
    80002e2c:	acbff0ef          	jal	800028f6 <argint>
  argint(1, &val);
    80002e30:	fe840593          	addi	a1,s0,-24
    80002e34:	4505                	li	a0,1
    80002e36:	ac1ff0ef          	jal	800028f6 <argint>
  return ksem_init(id, val);
    80002e3a:	fe842583          	lw	a1,-24(s0)
    80002e3e:	fec42503          	lw	a0,-20(s0)
    80002e42:	ea5ff0ef          	jal	80002ce6 <ksem_init>
}
    80002e46:	60e2                	ld	ra,24(sp)
    80002e48:	6442                	ld	s0,16(sp)
    80002e4a:	6105                	addi	sp,sp,32
    80002e4c:	8082                	ret

0000000080002e4e <sys_sem_wait>:

uint64
sys_sem_wait(void)
{
    80002e4e:	1101                	addi	sp,sp,-32
    80002e50:	ec06                	sd	ra,24(sp)
    80002e52:	e822                	sd	s0,16(sp)
    80002e54:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    80002e56:	fec40593          	addi	a1,s0,-20
    80002e5a:	4501                	li	a0,0
    80002e5c:	a9bff0ef          	jal	800028f6 <argint>
  return ksem_wait(id);
    80002e60:	fec42503          	lw	a0,-20(s0)
    80002e64:	ed9ff0ef          	jal	80002d3c <ksem_wait>
}
    80002e68:	60e2                	ld	ra,24(sp)
    80002e6a:	6442                	ld	s0,16(sp)
    80002e6c:	6105                	addi	sp,sp,32
    80002e6e:	8082                	ret

0000000080002e70 <sys_sem_post>:

uint64
sys_sem_post(void)
{
    80002e70:	1101                	addi	sp,sp,-32
    80002e72:	ec06                	sd	ra,24(sp)
    80002e74:	e822                	sd	s0,16(sp)
    80002e76:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    80002e78:	fec40593          	addi	a1,s0,-20
    80002e7c:	4501                	li	a0,0
    80002e7e:	a79ff0ef          	jal	800028f6 <argint>
  return ksem_post(id);
    80002e82:	fec42503          	lw	a0,-20(s0)
    80002e86:	f45ff0ef          	jal	80002dca <ksem_post>
}
    80002e8a:	60e2                	ld	ra,24(sp)
    80002e8c:	6442                	ld	s0,16(sp)
    80002e8e:	6105                	addi	sp,sp,32
    80002e90:	8082                	ret

0000000080002e92 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e92:	7179                	addi	sp,sp,-48
    80002e94:	f406                	sd	ra,40(sp)
    80002e96:	f022                	sd	s0,32(sp)
    80002e98:	ec26                	sd	s1,24(sp)
    80002e9a:	e84a                	sd	s2,16(sp)
    80002e9c:	e44e                	sd	s3,8(sp)
    80002e9e:	e052                	sd	s4,0(sp)
    80002ea0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ea2:	00004597          	auipc	a1,0x4
    80002ea6:	51e58593          	addi	a1,a1,1310 # 800073c0 <etext+0x3c0>
    80002eaa:	00016517          	auipc	a0,0x16
    80002eae:	9ae50513          	addi	a0,a0,-1618 # 80018858 <bcache>
    80002eb2:	cf7fd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002eb6:	0001e797          	auipc	a5,0x1e
    80002eba:	9a278793          	addi	a5,a5,-1630 # 80020858 <bcache+0x8000>
    80002ebe:	0001e717          	auipc	a4,0x1e
    80002ec2:	c0270713          	addi	a4,a4,-1022 # 80020ac0 <bcache+0x8268>
    80002ec6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002eca:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002ece:	00016497          	auipc	s1,0x16
    80002ed2:	9a248493          	addi	s1,s1,-1630 # 80018870 <bcache+0x18>
    b->next = bcache.head.next;
    80002ed6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ed8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002eda:	00004a17          	auipc	s4,0x4
    80002ede:	4eea0a13          	addi	s4,s4,1262 # 800073c8 <etext+0x3c8>
    b->next = bcache.head.next;
    80002ee2:	2b893783          	ld	a5,696(s2)
    80002ee6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ee8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002eec:	85d2                	mv	a1,s4
    80002eee:	01048513          	addi	a0,s1,16
    80002ef2:	41c010ef          	jal	8000430e <initsleeplock>
    bcache.head.next->prev = b;
    80002ef6:	2b893783          	ld	a5,696(s2)
    80002efa:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002efc:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002f00:	45848493          	addi	s1,s1,1112
    80002f04:	fd349fe3          	bne	s1,s3,80002ee2 <binit+0x50>
  }
}
    80002f08:	70a2                	ld	ra,40(sp)
    80002f0a:	7402                	ld	s0,32(sp)
    80002f0c:	64e2                	ld	s1,24(sp)
    80002f0e:	6942                	ld	s2,16(sp)
    80002f10:	69a2                	ld	s3,8(sp)
    80002f12:	6a02                	ld	s4,0(sp)
    80002f14:	6145                	addi	sp,sp,48
    80002f16:	8082                	ret

0000000080002f18 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002f18:	7179                	addi	sp,sp,-48
    80002f1a:	f406                	sd	ra,40(sp)
    80002f1c:	f022                	sd	s0,32(sp)
    80002f1e:	ec26                	sd	s1,24(sp)
    80002f20:	e84a                	sd	s2,16(sp)
    80002f22:	e44e                	sd	s3,8(sp)
    80002f24:	1800                	addi	s0,sp,48
    80002f26:	892a                	mv	s2,a0
    80002f28:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f2a:	00016517          	auipc	a0,0x16
    80002f2e:	92e50513          	addi	a0,a0,-1746 # 80018858 <bcache>
    80002f32:	cf7fd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002f36:	0001e497          	auipc	s1,0x1e
    80002f3a:	bda4b483          	ld	s1,-1062(s1) # 80020b10 <bcache+0x82b8>
    80002f3e:	0001e797          	auipc	a5,0x1e
    80002f42:	b8278793          	addi	a5,a5,-1150 # 80020ac0 <bcache+0x8268>
    80002f46:	02f48b63          	beq	s1,a5,80002f7c <bread+0x64>
    80002f4a:	873e                	mv	a4,a5
    80002f4c:	a021                	j	80002f54 <bread+0x3c>
    80002f4e:	68a4                	ld	s1,80(s1)
    80002f50:	02e48663          	beq	s1,a4,80002f7c <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002f54:	449c                	lw	a5,8(s1)
    80002f56:	ff279ce3          	bne	a5,s2,80002f4e <bread+0x36>
    80002f5a:	44dc                	lw	a5,12(s1)
    80002f5c:	ff3799e3          	bne	a5,s3,80002f4e <bread+0x36>
      b->refcnt++;
    80002f60:	40bc                	lw	a5,64(s1)
    80002f62:	2785                	addiw	a5,a5,1
    80002f64:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f66:	00016517          	auipc	a0,0x16
    80002f6a:	8f250513          	addi	a0,a0,-1806 # 80018858 <bcache>
    80002f6e:	d43fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002f72:	01048513          	addi	a0,s1,16
    80002f76:	3ce010ef          	jal	80004344 <acquiresleep>
      return b;
    80002f7a:	a889                	j	80002fcc <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002f7c:	0001e497          	auipc	s1,0x1e
    80002f80:	b8c4b483          	ld	s1,-1140(s1) # 80020b08 <bcache+0x82b0>
    80002f84:	0001e797          	auipc	a5,0x1e
    80002f88:	b3c78793          	addi	a5,a5,-1220 # 80020ac0 <bcache+0x8268>
    80002f8c:	00f48863          	beq	s1,a5,80002f9c <bread+0x84>
    80002f90:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002f92:	40bc                	lw	a5,64(s1)
    80002f94:	cb91                	beqz	a5,80002fa8 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002f96:	64a4                	ld	s1,72(s1)
    80002f98:	fee49de3          	bne	s1,a4,80002f92 <bread+0x7a>
  panic("bget: no buffers");
    80002f9c:	00004517          	auipc	a0,0x4
    80002fa0:	43450513          	addi	a0,a0,1076 # 800073d0 <etext+0x3d0>
    80002fa4:	891fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002fa8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002fac:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002fb0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fb4:	4785                	li	a5,1
    80002fb6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fb8:	00016517          	auipc	a0,0x16
    80002fbc:	8a050513          	addi	a0,a0,-1888 # 80018858 <bcache>
    80002fc0:	cf1fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002fc4:	01048513          	addi	a0,s1,16
    80002fc8:	37c010ef          	jal	80004344 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002fcc:	409c                	lw	a5,0(s1)
    80002fce:	cb89                	beqz	a5,80002fe0 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002fd0:	8526                	mv	a0,s1
    80002fd2:	70a2                	ld	ra,40(sp)
    80002fd4:	7402                	ld	s0,32(sp)
    80002fd6:	64e2                	ld	s1,24(sp)
    80002fd8:	6942                	ld	s2,16(sp)
    80002fda:	69a2                	ld	s3,8(sp)
    80002fdc:	6145                	addi	sp,sp,48
    80002fde:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fe0:	4581                	li	a1,0
    80002fe2:	8526                	mv	a0,s1
    80002fe4:	4c3020ef          	jal	80005ca6 <virtio_disk_rw>
    b->valid = 1;
    80002fe8:	4785                	li	a5,1
    80002fea:	c09c                	sw	a5,0(s1)
  return b;
    80002fec:	b7d5                	j	80002fd0 <bread+0xb8>

0000000080002fee <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002fee:	1101                	addi	sp,sp,-32
    80002ff0:	ec06                	sd	ra,24(sp)
    80002ff2:	e822                	sd	s0,16(sp)
    80002ff4:	e426                	sd	s1,8(sp)
    80002ff6:	1000                	addi	s0,sp,32
    80002ff8:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002ffa:	0541                	addi	a0,a0,16
    80002ffc:	3d4010ef          	jal	800043d0 <holdingsleep>
    80003000:	c911                	beqz	a0,80003014 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003002:	4585                	li	a1,1
    80003004:	8526                	mv	a0,s1
    80003006:	4a1020ef          	jal	80005ca6 <virtio_disk_rw>
}
    8000300a:	60e2                	ld	ra,24(sp)
    8000300c:	6442                	ld	s0,16(sp)
    8000300e:	64a2                	ld	s1,8(sp)
    80003010:	6105                	addi	sp,sp,32
    80003012:	8082                	ret
    panic("bwrite");
    80003014:	00004517          	auipc	a0,0x4
    80003018:	3d450513          	addi	a0,a0,980 # 800073e8 <etext+0x3e8>
    8000301c:	819fd0ef          	jal	80000834 <panic>

0000000080003020 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003020:	1101                	addi	sp,sp,-32
    80003022:	ec06                	sd	ra,24(sp)
    80003024:	e822                	sd	s0,16(sp)
    80003026:	e426                	sd	s1,8(sp)
    80003028:	e04a                	sd	s2,0(sp)
    8000302a:	1000                	addi	s0,sp,32
    8000302c:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    8000302e:	01050913          	addi	s2,a0,16
    80003032:	854a                	mv	a0,s2
    80003034:	39c010ef          	jal	800043d0 <holdingsleep>
    80003038:	c125                	beqz	a0,80003098 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    8000303a:	854a                	mv	a0,s2
    8000303c:	35c010ef          	jal	80004398 <releasesleep>

  acquire(&bcache.lock);
    80003040:	00016517          	auipc	a0,0x16
    80003044:	81850513          	addi	a0,a0,-2024 # 80018858 <bcache>
    80003048:	be1fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    8000304c:	40bc                	lw	a5,64(s1)
    8000304e:	37fd                	addiw	a5,a5,-1
    80003050:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003052:	e79d                	bnez	a5,80003080 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003054:	68b8                	ld	a4,80(s1)
    80003056:	64bc                	ld	a5,72(s1)
    80003058:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000305a:	68b8                	ld	a4,80(s1)
    8000305c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000305e:	0001d797          	auipc	a5,0x1d
    80003062:	7fa78793          	addi	a5,a5,2042 # 80020858 <bcache+0x8000>
    80003066:	2b87b703          	ld	a4,696(a5)
    8000306a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000306c:	0001e717          	auipc	a4,0x1e
    80003070:	a5470713          	addi	a4,a4,-1452 # 80020ac0 <bcache+0x8268>
    80003074:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003076:	2b87b703          	ld	a4,696(a5)
    8000307a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000307c:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80003080:	00015517          	auipc	a0,0x15
    80003084:	7d850513          	addi	a0,a0,2008 # 80018858 <bcache>
    80003088:	c29fd0ef          	jal	80000cb0 <release>
}
    8000308c:	60e2                	ld	ra,24(sp)
    8000308e:	6442                	ld	s0,16(sp)
    80003090:	64a2                	ld	s1,8(sp)
    80003092:	6902                	ld	s2,0(sp)
    80003094:	6105                	addi	sp,sp,32
    80003096:	8082                	ret
    panic("brelse");
    80003098:	00004517          	auipc	a0,0x4
    8000309c:	35850513          	addi	a0,a0,856 # 800073f0 <etext+0x3f0>
    800030a0:	f94fd0ef          	jal	80000834 <panic>

00000000800030a4 <bpin>:

void
bpin(struct buf *b)
{
    800030a4:	1101                	addi	sp,sp,-32
    800030a6:	ec06                	sd	ra,24(sp)
    800030a8:	e822                	sd	s0,16(sp)
    800030aa:	e426                	sd	s1,8(sp)
    800030ac:	1000                	addi	s0,sp,32
    800030ae:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030b0:	00015517          	auipc	a0,0x15
    800030b4:	7a850513          	addi	a0,a0,1960 # 80018858 <bcache>
    800030b8:	b71fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    800030bc:	40bc                	lw	a5,64(s1)
    800030be:	2785                	addiw	a5,a5,1
    800030c0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030c2:	00015517          	auipc	a0,0x15
    800030c6:	79650513          	addi	a0,a0,1942 # 80018858 <bcache>
    800030ca:	be7fd0ef          	jal	80000cb0 <release>
}
    800030ce:	60e2                	ld	ra,24(sp)
    800030d0:	6442                	ld	s0,16(sp)
    800030d2:	64a2                	ld	s1,8(sp)
    800030d4:	6105                	addi	sp,sp,32
    800030d6:	8082                	ret

00000000800030d8 <bunpin>:

void
bunpin(struct buf *b)
{
    800030d8:	1101                	addi	sp,sp,-32
    800030da:	ec06                	sd	ra,24(sp)
    800030dc:	e822                	sd	s0,16(sp)
    800030de:	e426                	sd	s1,8(sp)
    800030e0:	1000                	addi	s0,sp,32
    800030e2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030e4:	00015517          	auipc	a0,0x15
    800030e8:	77450513          	addi	a0,a0,1908 # 80018858 <bcache>
    800030ec:	b3dfd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    800030f0:	40bc                	lw	a5,64(s1)
    800030f2:	37fd                	addiw	a5,a5,-1
    800030f4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030f6:	00015517          	auipc	a0,0x15
    800030fa:	76250513          	addi	a0,a0,1890 # 80018858 <bcache>
    800030fe:	bb3fd0ef          	jal	80000cb0 <release>
}
    80003102:	60e2                	ld	ra,24(sp)
    80003104:	6442                	ld	s0,16(sp)
    80003106:	64a2                	ld	s1,8(sp)
    80003108:	6105                	addi	sp,sp,32
    8000310a:	8082                	ret

000000008000310c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000310c:	1101                	addi	sp,sp,-32
    8000310e:	ec06                	sd	ra,24(sp)
    80003110:	e822                	sd	s0,16(sp)
    80003112:	e426                	sd	s1,8(sp)
    80003114:	e04a                	sd	s2,0(sp)
    80003116:	1000                	addi	s0,sp,32
    80003118:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000311a:	00d5d79b          	srliw	a5,a1,0xd
    8000311e:	0001e597          	auipc	a1,0x1e
    80003122:	e165a583          	lw	a1,-490(a1) # 80020f34 <sb+0x1c>
    80003126:	9dbd                	addw	a1,a1,a5
    80003128:	df1ff0ef          	jal	80002f18 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000312c:	0074f713          	andi	a4,s1,7
    80003130:	4785                	li	a5,1
    80003132:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80003136:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80003138:	90d9                	srli	s1,s1,0x36
    8000313a:	00950733          	add	a4,a0,s1
    8000313e:	05874703          	lbu	a4,88(a4)
    80003142:	00e7f6b3          	and	a3,a5,a4
    80003146:	c29d                	beqz	a3,8000316c <bfree+0x60>
    80003148:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    8000314a:	94aa                	add	s1,s1,a0
    8000314c:	fff7c793          	not	a5,a5
    80003150:	8f7d                	and	a4,a4,a5
    80003152:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003156:	080010ef          	jal	800041d6 <log_write>
  brelse(bp);
    8000315a:	854a                	mv	a0,s2
    8000315c:	ec5ff0ef          	jal	80003020 <brelse>
}
    80003160:	60e2                	ld	ra,24(sp)
    80003162:	6442                	ld	s0,16(sp)
    80003164:	64a2                	ld	s1,8(sp)
    80003166:	6902                	ld	s2,0(sp)
    80003168:	6105                	addi	sp,sp,32
    8000316a:	8082                	ret
    panic("freeing free block");
    8000316c:	00004517          	auipc	a0,0x4
    80003170:	28c50513          	addi	a0,a0,652 # 800073f8 <etext+0x3f8>
    80003174:	ec0fd0ef          	jal	80000834 <panic>

0000000080003178 <balloc>:
{
    80003178:	715d                	addi	sp,sp,-80
    8000317a:	e486                	sd	ra,72(sp)
    8000317c:	e0a2                	sd	s0,64(sp)
    8000317e:	fc26                	sd	s1,56(sp)
    80003180:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80003182:	0001e797          	auipc	a5,0x1e
    80003186:	d9a7a783          	lw	a5,-614(a5) # 80020f1c <sb+0x4>
    8000318a:	0e078263          	beqz	a5,8000326e <balloc+0xf6>
    8000318e:	f84a                	sd	s2,48(sp)
    80003190:	f44e                	sd	s3,40(sp)
    80003192:	f052                	sd	s4,32(sp)
    80003194:	ec56                	sd	s5,24(sp)
    80003196:	e85a                	sd	s6,16(sp)
    80003198:	e45e                	sd	s7,8(sp)
    8000319a:	e062                	sd	s8,0(sp)
    8000319c:	8baa                	mv	s7,a0
    8000319e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031a0:	0001eb17          	auipc	s6,0x1e
    800031a4:	d78b0b13          	addi	s6,s6,-648 # 80020f18 <sb>
      m = 1 << (bi % 8);
    800031a8:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    800031aa:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    800031ac:	6c09                	lui	s8,0x2
    800031ae:	a09d                	j	80003214 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    800031b0:	97ca                	add	a5,a5,s2
    800031b2:	8e55                	or	a2,a2,a3
    800031b4:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800031b8:	854a                	mv	a0,s2
    800031ba:	01c010ef          	jal	800041d6 <log_write>
        brelse(bp);
    800031be:	854a                	mv	a0,s2
    800031c0:	e61ff0ef          	jal	80003020 <brelse>
  bp = bread(dev, bno);
    800031c4:	85a6                	mv	a1,s1
    800031c6:	855e                	mv	a0,s7
    800031c8:	d51ff0ef          	jal	80002f18 <bread>
    800031cc:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031ce:	40000613          	li	a2,1024
    800031d2:	4581                	li	a1,0
    800031d4:	05850513          	addi	a0,a0,88
    800031d8:	b11fd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    800031dc:	854a                	mv	a0,s2
    800031de:	7f9000ef          	jal	800041d6 <log_write>
  brelse(bp);
    800031e2:	854a                	mv	a0,s2
    800031e4:	e3dff0ef          	jal	80003020 <brelse>
}
    800031e8:	7942                	ld	s2,48(sp)
    800031ea:	79a2                	ld	s3,40(sp)
    800031ec:	7a02                	ld	s4,32(sp)
    800031ee:	6ae2                	ld	s5,24(sp)
    800031f0:	6b42                	ld	s6,16(sp)
    800031f2:	6ba2                	ld	s7,8(sp)
    800031f4:	6c02                	ld	s8,0(sp)
}
    800031f6:	8526                	mv	a0,s1
    800031f8:	60a6                	ld	ra,72(sp)
    800031fa:	6406                	ld	s0,64(sp)
    800031fc:	74e2                	ld	s1,56(sp)
    800031fe:	6161                	addi	sp,sp,80
    80003200:	8082                	ret
    brelse(bp);
    80003202:	854a                	mv	a0,s2
    80003204:	e1dff0ef          	jal	80003020 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80003208:	015c0abb          	addw	s5,s8,s5
    8000320c:	004b2783          	lw	a5,4(s6)
    80003210:	04faf863          	bgeu	s5,a5,80003260 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80003214:	40dad59b          	sraiw	a1,s5,0xd
    80003218:	01cb2783          	lw	a5,28(s6)
    8000321c:	9dbd                	addw	a1,a1,a5
    8000321e:	855e                	mv	a0,s7
    80003220:	cf9ff0ef          	jal	80002f18 <bread>
    80003224:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003226:	004b2503          	lw	a0,4(s6)
    8000322a:	84d6                	mv	s1,s5
    8000322c:	4701                	li	a4,0
    8000322e:	fca4fae3          	bgeu	s1,a0,80003202 <balloc+0x8a>
      m = 1 << (bi % 8);
    80003232:	00777693          	andi	a3,a4,7
    80003236:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    8000323a:	41f7579b          	sraiw	a5,a4,0x1f
    8000323e:	01d7d79b          	srliw	a5,a5,0x1d
    80003242:	9fb9                	addw	a5,a5,a4
    80003244:	4037d79b          	sraiw	a5,a5,0x3
    80003248:	00f90633          	add	a2,s2,a5
    8000324c:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003250:	00c6f5b3          	and	a1,a3,a2
    80003254:	ddb1                	beqz	a1,800031b0 <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003256:	2705                	addiw	a4,a4,1
    80003258:	2485                	addiw	s1,s1,1
    8000325a:	fd471ae3          	bne	a4,s4,8000322e <balloc+0xb6>
    8000325e:	b755                	j	80003202 <balloc+0x8a>
    80003260:	7942                	ld	s2,48(sp)
    80003262:	79a2                	ld	s3,40(sp)
    80003264:	7a02                	ld	s4,32(sp)
    80003266:	6ae2                	ld	s5,24(sp)
    80003268:	6b42                	ld	s6,16(sp)
    8000326a:	6ba2                	ld	s7,8(sp)
    8000326c:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    8000326e:	00004517          	auipc	a0,0x4
    80003272:	1a250513          	addi	a0,a0,418 # 80007410 <etext+0x410>
    80003276:	a94fd0ef          	jal	8000050a <printk>
  return 0;
    8000327a:	4481                	li	s1,0
    8000327c:	bfad                	j	800031f6 <balloc+0x7e>

000000008000327e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000327e:	7179                	addi	sp,sp,-48
    80003280:	f406                	sd	ra,40(sp)
    80003282:	f022                	sd	s0,32(sp)
    80003284:	ec26                	sd	s1,24(sp)
    80003286:	e84a                	sd	s2,16(sp)
    80003288:	e44e                	sd	s3,8(sp)
    8000328a:	1800                	addi	s0,sp,48
    8000328c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    8000328e:	47ad                	li	a5,11
    80003290:	02b7e363          	bltu	a5,a1,800032b6 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80003294:	02059793          	slli	a5,a1,0x20
    80003298:	01e7d593          	srli	a1,a5,0x1e
    8000329c:	00b509b3          	add	s3,a0,a1
    800032a0:	0509a483          	lw	s1,80(s3)
    800032a4:	e0b5                	bnez	s1,80003308 <bmap+0x8a>
      addr = balloc(ip->dev);
    800032a6:	4108                	lw	a0,0(a0)
    800032a8:	ed1ff0ef          	jal	80003178 <balloc>
    800032ac:	84aa                	mv	s1,a0
      if (addr == 0)
    800032ae:	cd29                	beqz	a0,80003308 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    800032b0:	04a9a823          	sw	a0,80(s3)
    800032b4:	a891                	j	80003308 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800032b6:	ff45879b          	addiw	a5,a1,-12
    800032ba:	873e                	mv	a4,a5
    800032bc:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    800032be:	0ff00793          	li	a5,255
    800032c2:	06e7e763          	bltu	a5,a4,80003330 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    800032c6:	08052483          	lw	s1,128(a0)
    800032ca:	e891                	bnez	s1,800032de <bmap+0x60>
      addr = balloc(ip->dev);
    800032cc:	4108                	lw	a0,0(a0)
    800032ce:	eabff0ef          	jal	80003178 <balloc>
    800032d2:	84aa                	mv	s1,a0
      if (addr == 0)
    800032d4:	c915                	beqz	a0,80003308 <bmap+0x8a>
    800032d6:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800032d8:	08a92023          	sw	a0,128(s2)
    800032dc:	a011                	j	800032e0 <bmap+0x62>
    800032de:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800032e0:	85a6                	mv	a1,s1
    800032e2:	00092503          	lw	a0,0(s2)
    800032e6:	c33ff0ef          	jal	80002f18 <bread>
    800032ea:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    800032ec:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    800032f0:	02099713          	slli	a4,s3,0x20
    800032f4:	01e75593          	srli	a1,a4,0x1e
    800032f8:	97ae                	add	a5,a5,a1
    800032fa:	89be                	mv	s3,a5
    800032fc:	4384                	lw	s1,0(a5)
    800032fe:	cc89                	beqz	s1,80003318 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003300:	8552                	mv	a0,s4
    80003302:	d1fff0ef          	jal	80003020 <brelse>
    return addr;
    80003306:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003308:	8526                	mv	a0,s1
    8000330a:	70a2                	ld	ra,40(sp)
    8000330c:	7402                	ld	s0,32(sp)
    8000330e:	64e2                	ld	s1,24(sp)
    80003310:	6942                	ld	s2,16(sp)
    80003312:	69a2                	ld	s3,8(sp)
    80003314:	6145                	addi	sp,sp,48
    80003316:	8082                	ret
      addr = balloc(ip->dev);
    80003318:	00092503          	lw	a0,0(s2)
    8000331c:	e5dff0ef          	jal	80003178 <balloc>
    80003320:	84aa                	mv	s1,a0
      if (addr) {
    80003322:	dd79                	beqz	a0,80003300 <bmap+0x82>
        a[bn] = addr;
    80003324:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003328:	8552                	mv	a0,s4
    8000332a:	6ad000ef          	jal	800041d6 <log_write>
    8000332e:	bfc9                	j	80003300 <bmap+0x82>
    80003330:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003332:	00004517          	auipc	a0,0x4
    80003336:	0f650513          	addi	a0,a0,246 # 80007428 <etext+0x428>
    8000333a:	cfafd0ef          	jal	80000834 <panic>

000000008000333e <iget>:
{
    8000333e:	7179                	addi	sp,sp,-48
    80003340:	f406                	sd	ra,40(sp)
    80003342:	f022                	sd	s0,32(sp)
    80003344:	ec26                	sd	s1,24(sp)
    80003346:	e84a                	sd	s2,16(sp)
    80003348:	e44e                	sd	s3,8(sp)
    8000334a:	e052                	sd	s4,0(sp)
    8000334c:	1800                	addi	s0,sp,48
    8000334e:	892a                	mv	s2,a0
    80003350:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003352:	0001e517          	auipc	a0,0x1e
    80003356:	be650513          	addi	a0,a0,-1050 # 80020f38 <itable>
    8000335a:	8cffd0ef          	jal	80000c28 <acquire>
  empty = 0;
    8000335e:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003360:	0001e497          	auipc	s1,0x1e
    80003364:	bf048493          	addi	s1,s1,-1040 # 80020f50 <itable+0x18>
    80003368:	0001f697          	auipc	a3,0x1f
    8000336c:	67868693          	addi	a3,a3,1656 # 800229e0 <log>
    80003370:	a809                	j	80003382 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003372:	e781                	bnez	a5,8000337a <iget+0x3c>
    80003374:	00099363          	bnez	s3,8000337a <iget+0x3c>
      empty = ip;
    80003378:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000337a:	08848493          	addi	s1,s1,136
    8000337e:	02d48563          	beq	s1,a3,800033a8 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80003382:	449c                	lw	a5,8(s1)
    80003384:	fef057e3          	blez	a5,80003372 <iget+0x34>
    80003388:	4098                	lw	a4,0(s1)
    8000338a:	ff2718e3          	bne	a4,s2,8000337a <iget+0x3c>
    8000338e:	40d8                	lw	a4,4(s1)
    80003390:	ff4715e3          	bne	a4,s4,8000337a <iget+0x3c>
      ip->ref++;
    80003394:	2785                	addiw	a5,a5,1
    80003396:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003398:	0001e517          	auipc	a0,0x1e
    8000339c:	ba050513          	addi	a0,a0,-1120 # 80020f38 <itable>
    800033a0:	911fd0ef          	jal	80000cb0 <release>
      return ip;
    800033a4:	89a6                	mv	s3,s1
    800033a6:	a015                	j	800033ca <iget+0x8c>
  if (empty == 0)
    800033a8:	02098a63          	beqz	s3,800033dc <iget+0x9e>
  ip->dev = dev;
    800033ac:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800033b0:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800033b4:	4785                	li	a5,1
    800033b6:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800033ba:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800033be:	0001e517          	auipc	a0,0x1e
    800033c2:	b7a50513          	addi	a0,a0,-1158 # 80020f38 <itable>
    800033c6:	8ebfd0ef          	jal	80000cb0 <release>
}
    800033ca:	854e                	mv	a0,s3
    800033cc:	70a2                	ld	ra,40(sp)
    800033ce:	7402                	ld	s0,32(sp)
    800033d0:	64e2                	ld	s1,24(sp)
    800033d2:	6942                	ld	s2,16(sp)
    800033d4:	69a2                	ld	s3,8(sp)
    800033d6:	6a02                	ld	s4,0(sp)
    800033d8:	6145                	addi	sp,sp,48
    800033da:	8082                	ret
    panic("iget: no inodes");
    800033dc:	00004517          	auipc	a0,0x4
    800033e0:	06450513          	addi	a0,a0,100 # 80007440 <etext+0x440>
    800033e4:	c50fd0ef          	jal	80000834 <panic>

00000000800033e8 <iinit>:
{
    800033e8:	7179                	addi	sp,sp,-48
    800033ea:	f406                	sd	ra,40(sp)
    800033ec:	f022                	sd	s0,32(sp)
    800033ee:	ec26                	sd	s1,24(sp)
    800033f0:	e84a                	sd	s2,16(sp)
    800033f2:	e44e                	sd	s3,8(sp)
    800033f4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800033f6:	00004597          	auipc	a1,0x4
    800033fa:	05a58593          	addi	a1,a1,90 # 80007450 <etext+0x450>
    800033fe:	0001e517          	auipc	a0,0x1e
    80003402:	b3a50513          	addi	a0,a0,-1222 # 80020f38 <itable>
    80003406:	fa2fd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    8000340a:	0001e497          	auipc	s1,0x1e
    8000340e:	b5648493          	addi	s1,s1,-1194 # 80020f60 <itable+0x28>
    80003412:	0001f997          	auipc	s3,0x1f
    80003416:	5de98993          	addi	s3,s3,1502 # 800229f0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000341a:	00004917          	auipc	s2,0x4
    8000341e:	03e90913          	addi	s2,s2,62 # 80007458 <etext+0x458>
    80003422:	85ca                	mv	a1,s2
    80003424:	8526                	mv	a0,s1
    80003426:	6e9000ef          	jal	8000430e <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    8000342a:	08848493          	addi	s1,s1,136
    8000342e:	ff349ae3          	bne	s1,s3,80003422 <iinit+0x3a>
}
    80003432:	70a2                	ld	ra,40(sp)
    80003434:	7402                	ld	s0,32(sp)
    80003436:	64e2                	ld	s1,24(sp)
    80003438:	6942                	ld	s2,16(sp)
    8000343a:	69a2                	ld	s3,8(sp)
    8000343c:	6145                	addi	sp,sp,48
    8000343e:	8082                	ret

0000000080003440 <ialloc>:
{
    80003440:	7139                	addi	sp,sp,-64
    80003442:	fc06                	sd	ra,56(sp)
    80003444:	f822                	sd	s0,48(sp)
    80003446:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003448:	0001e717          	auipc	a4,0x1e
    8000344c:	adc72703          	lw	a4,-1316(a4) # 80020f24 <sb+0xc>
    80003450:	4785                	li	a5,1
    80003452:	06e7f063          	bgeu	a5,a4,800034b2 <ialloc+0x72>
    80003456:	f426                	sd	s1,40(sp)
    80003458:	f04a                	sd	s2,32(sp)
    8000345a:	ec4e                	sd	s3,24(sp)
    8000345c:	e852                	sd	s4,16(sp)
    8000345e:	e456                	sd	s5,8(sp)
    80003460:	e05a                	sd	s6,0(sp)
    80003462:	8aaa                	mv	s5,a0
    80003464:	8b2e                	mv	s6,a1
    80003466:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003468:	0001ea17          	auipc	s4,0x1e
    8000346c:	ab0a0a13          	addi	s4,s4,-1360 # 80020f18 <sb>
    80003470:	00495593          	srli	a1,s2,0x4
    80003474:	018a2783          	lw	a5,24(s4)
    80003478:	9dbd                	addw	a1,a1,a5
    8000347a:	8556                	mv	a0,s5
    8000347c:	a9dff0ef          	jal	80002f18 <bread>
    80003480:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003482:	05850993          	addi	s3,a0,88
    80003486:	00f97793          	andi	a5,s2,15
    8000348a:	079a                	slli	a5,a5,0x6
    8000348c:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    8000348e:	00099783          	lh	a5,0(s3)
    80003492:	cb9d                	beqz	a5,800034c8 <ialloc+0x88>
    brelse(bp);
    80003494:	b8dff0ef          	jal	80003020 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003498:	0905                	addi	s2,s2,1
    8000349a:	00ca2703          	lw	a4,12(s4)
    8000349e:	0009079b          	sext.w	a5,s2
    800034a2:	fce7e7e3          	bltu	a5,a4,80003470 <ialloc+0x30>
    800034a6:	74a2                	ld	s1,40(sp)
    800034a8:	7902                	ld	s2,32(sp)
    800034aa:	69e2                	ld	s3,24(sp)
    800034ac:	6a42                	ld	s4,16(sp)
    800034ae:	6aa2                	ld	s5,8(sp)
    800034b0:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800034b2:	00004517          	auipc	a0,0x4
    800034b6:	fae50513          	addi	a0,a0,-82 # 80007460 <etext+0x460>
    800034ba:	850fd0ef          	jal	8000050a <printk>
  return 0;
    800034be:	4501                	li	a0,0
}
    800034c0:	70e2                	ld	ra,56(sp)
    800034c2:	7442                	ld	s0,48(sp)
    800034c4:	6121                	addi	sp,sp,64
    800034c6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800034c8:	04000613          	li	a2,64
    800034cc:	4581                	li	a1,0
    800034ce:	854e                	mv	a0,s3
    800034d0:	819fd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    800034d4:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800034d8:	8526                	mv	a0,s1
    800034da:	4fd000ef          	jal	800041d6 <log_write>
      brelse(bp);
    800034de:	8526                	mv	a0,s1
    800034e0:	b41ff0ef          	jal	80003020 <brelse>
      return iget(dev, inum);
    800034e4:	0009059b          	sext.w	a1,s2
    800034e8:	8556                	mv	a0,s5
    800034ea:	e55ff0ef          	jal	8000333e <iget>
    800034ee:	74a2                	ld	s1,40(sp)
    800034f0:	7902                	ld	s2,32(sp)
    800034f2:	69e2                	ld	s3,24(sp)
    800034f4:	6a42                	ld	s4,16(sp)
    800034f6:	6aa2                	ld	s5,8(sp)
    800034f8:	6b02                	ld	s6,0(sp)
    800034fa:	b7d9                	j	800034c0 <ialloc+0x80>

00000000800034fc <iupdate>:
{
    800034fc:	1101                	addi	sp,sp,-32
    800034fe:	ec06                	sd	ra,24(sp)
    80003500:	e822                	sd	s0,16(sp)
    80003502:	e426                	sd	s1,8(sp)
    80003504:	e04a                	sd	s2,0(sp)
    80003506:	1000                	addi	s0,sp,32
    80003508:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000350a:	415c                	lw	a5,4(a0)
    8000350c:	0047d79b          	srliw	a5,a5,0x4
    80003510:	0001e597          	auipc	a1,0x1e
    80003514:	a205a583          	lw	a1,-1504(a1) # 80020f30 <sb+0x18>
    80003518:	9dbd                	addw	a1,a1,a5
    8000351a:	4108                	lw	a0,0(a0)
    8000351c:	9fdff0ef          	jal	80002f18 <bread>
    80003520:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003522:	05850793          	addi	a5,a0,88
    80003526:	40d8                	lw	a4,4(s1)
    80003528:	8b3d                	andi	a4,a4,15
    8000352a:	071a                	slli	a4,a4,0x6
    8000352c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000352e:	04449703          	lh	a4,68(s1)
    80003532:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003536:	04649703          	lh	a4,70(s1)
    8000353a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000353e:	04849703          	lh	a4,72(s1)
    80003542:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003546:	04a49703          	lh	a4,74(s1)
    8000354a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000354e:	44f8                	lw	a4,76(s1)
    80003550:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003552:	03400613          	li	a2,52
    80003556:	05048593          	addi	a1,s1,80
    8000355a:	00c78513          	addi	a0,a5,12
    8000355e:	feafd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    80003562:	854a                	mv	a0,s2
    80003564:	473000ef          	jal	800041d6 <log_write>
  brelse(bp);
    80003568:	854a                	mv	a0,s2
    8000356a:	ab7ff0ef          	jal	80003020 <brelse>
}
    8000356e:	60e2                	ld	ra,24(sp)
    80003570:	6442                	ld	s0,16(sp)
    80003572:	64a2                	ld	s1,8(sp)
    80003574:	6902                	ld	s2,0(sp)
    80003576:	6105                	addi	sp,sp,32
    80003578:	8082                	ret

000000008000357a <idup>:
{
    8000357a:	1101                	addi	sp,sp,-32
    8000357c:	ec06                	sd	ra,24(sp)
    8000357e:	e822                	sd	s0,16(sp)
    80003580:	e426                	sd	s1,8(sp)
    80003582:	1000                	addi	s0,sp,32
    80003584:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003586:	0001e517          	auipc	a0,0x1e
    8000358a:	9b250513          	addi	a0,a0,-1614 # 80020f38 <itable>
    8000358e:	e9afd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003592:	449c                	lw	a5,8(s1)
    80003594:	2785                	addiw	a5,a5,1
    80003596:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003598:	0001e517          	auipc	a0,0x1e
    8000359c:	9a050513          	addi	a0,a0,-1632 # 80020f38 <itable>
    800035a0:	f10fd0ef          	jal	80000cb0 <release>
}
    800035a4:	8526                	mv	a0,s1
    800035a6:	60e2                	ld	ra,24(sp)
    800035a8:	6442                	ld	s0,16(sp)
    800035aa:	64a2                	ld	s1,8(sp)
    800035ac:	6105                	addi	sp,sp,32
    800035ae:	8082                	ret

00000000800035b0 <ilock>:
{
    800035b0:	1101                	addi	sp,sp,-32
    800035b2:	ec06                	sd	ra,24(sp)
    800035b4:	e822                	sd	s0,16(sp)
    800035b6:	e426                	sd	s1,8(sp)
    800035b8:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800035ba:	cd19                	beqz	a0,800035d8 <ilock+0x28>
    800035bc:	84aa                	mv	s1,a0
    800035be:	451c                	lw	a5,8(a0)
    800035c0:	00f05c63          	blez	a5,800035d8 <ilock+0x28>
  acquiresleep(&ip->lock);
    800035c4:	0541                	addi	a0,a0,16
    800035c6:	57f000ef          	jal	80004344 <acquiresleep>
  if (ip->valid == 0) {
    800035ca:	40bc                	lw	a5,64(s1)
    800035cc:	cf89                	beqz	a5,800035e6 <ilock+0x36>
}
    800035ce:	60e2                	ld	ra,24(sp)
    800035d0:	6442                	ld	s0,16(sp)
    800035d2:	64a2                	ld	s1,8(sp)
    800035d4:	6105                	addi	sp,sp,32
    800035d6:	8082                	ret
    800035d8:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800035da:	00004517          	auipc	a0,0x4
    800035de:	e9e50513          	addi	a0,a0,-354 # 80007478 <etext+0x478>
    800035e2:	a52fd0ef          	jal	80000834 <panic>
    800035e6:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035e8:	40dc                	lw	a5,4(s1)
    800035ea:	0047d79b          	srliw	a5,a5,0x4
    800035ee:	0001e597          	auipc	a1,0x1e
    800035f2:	9425a583          	lw	a1,-1726(a1) # 80020f30 <sb+0x18>
    800035f6:	9dbd                	addw	a1,a1,a5
    800035f8:	4088                	lw	a0,0(s1)
    800035fa:	91fff0ef          	jal	80002f18 <bread>
    800035fe:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003600:	05850593          	addi	a1,a0,88
    80003604:	40dc                	lw	a5,4(s1)
    80003606:	8bbd                	andi	a5,a5,15
    80003608:	079a                	slli	a5,a5,0x6
    8000360a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000360c:	00059783          	lh	a5,0(a1)
    80003610:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003614:	00259783          	lh	a5,2(a1)
    80003618:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000361c:	00459783          	lh	a5,4(a1)
    80003620:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003624:	00659783          	lh	a5,6(a1)
    80003628:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000362c:	459c                	lw	a5,8(a1)
    8000362e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003630:	03400613          	li	a2,52
    80003634:	05b1                	addi	a1,a1,12
    80003636:	05048513          	addi	a0,s1,80
    8000363a:	f0efd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    8000363e:	854a                	mv	a0,s2
    80003640:	9e1ff0ef          	jal	80003020 <brelse>
    ip->valid = 1;
    80003644:	4785                	li	a5,1
    80003646:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003648:	04449783          	lh	a5,68(s1)
    8000364c:	c399                	beqz	a5,80003652 <ilock+0xa2>
    8000364e:	6902                	ld	s2,0(sp)
    80003650:	bfbd                	j	800035ce <ilock+0x1e>
      panic("ilock: no type");
    80003652:	00004517          	auipc	a0,0x4
    80003656:	e2e50513          	addi	a0,a0,-466 # 80007480 <etext+0x480>
    8000365a:	9dafd0ef          	jal	80000834 <panic>

000000008000365e <iunlock>:
{
    8000365e:	1101                	addi	sp,sp,-32
    80003660:	ec06                	sd	ra,24(sp)
    80003662:	e822                	sd	s0,16(sp)
    80003664:	e426                	sd	s1,8(sp)
    80003666:	e04a                	sd	s2,0(sp)
    80003668:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000366a:	c505                	beqz	a0,80003692 <iunlock+0x34>
    8000366c:	84aa                	mv	s1,a0
    8000366e:	01050913          	addi	s2,a0,16
    80003672:	854a                	mv	a0,s2
    80003674:	55d000ef          	jal	800043d0 <holdingsleep>
    80003678:	cd09                	beqz	a0,80003692 <iunlock+0x34>
    8000367a:	449c                	lw	a5,8(s1)
    8000367c:	00f05b63          	blez	a5,80003692 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003680:	854a                	mv	a0,s2
    80003682:	517000ef          	jal	80004398 <releasesleep>
}
    80003686:	60e2                	ld	ra,24(sp)
    80003688:	6442                	ld	s0,16(sp)
    8000368a:	64a2                	ld	s1,8(sp)
    8000368c:	6902                	ld	s2,0(sp)
    8000368e:	6105                	addi	sp,sp,32
    80003690:	8082                	ret
    panic("iunlock");
    80003692:	00004517          	auipc	a0,0x4
    80003696:	dfe50513          	addi	a0,a0,-514 # 80007490 <etext+0x490>
    8000369a:	99afd0ef          	jal	80000834 <panic>

000000008000369e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000369e:	7179                	addi	sp,sp,-48
    800036a0:	f406                	sd	ra,40(sp)
    800036a2:	f022                	sd	s0,32(sp)
    800036a4:	ec26                	sd	s1,24(sp)
    800036a6:	e84a                	sd	s2,16(sp)
    800036a8:	e44e                	sd	s3,8(sp)
    800036aa:	1800                	addi	s0,sp,48
    800036ac:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800036ae:	05050493          	addi	s1,a0,80
    800036b2:	08050913          	addi	s2,a0,128
    800036b6:	a021                	j	800036be <itrunc+0x20>
    800036b8:	0491                	addi	s1,s1,4
    800036ba:	01248b63          	beq	s1,s2,800036d0 <itrunc+0x32>
    if (ip->addrs[i]) {
    800036be:	408c                	lw	a1,0(s1)
    800036c0:	dde5                	beqz	a1,800036b8 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800036c2:	0009a503          	lw	a0,0(s3)
    800036c6:	a47ff0ef          	jal	8000310c <bfree>
      ip->addrs[i] = 0;
    800036ca:	0004a023          	sw	zero,0(s1)
    800036ce:	b7ed                	j	800036b8 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800036d0:	0809a583          	lw	a1,128(s3)
    800036d4:	ed89                	bnez	a1,800036ee <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800036d6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800036da:	854e                	mv	a0,s3
    800036dc:	e21ff0ef          	jal	800034fc <iupdate>
}
    800036e0:	70a2                	ld	ra,40(sp)
    800036e2:	7402                	ld	s0,32(sp)
    800036e4:	64e2                	ld	s1,24(sp)
    800036e6:	6942                	ld	s2,16(sp)
    800036e8:	69a2                	ld	s3,8(sp)
    800036ea:	6145                	addi	sp,sp,48
    800036ec:	8082                	ret
    800036ee:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800036f0:	0009a503          	lw	a0,0(s3)
    800036f4:	825ff0ef          	jal	80002f18 <bread>
    800036f8:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    800036fa:	05850493          	addi	s1,a0,88
    800036fe:	45850913          	addi	s2,a0,1112
    80003702:	a021                	j	8000370a <itrunc+0x6c>
    80003704:	0491                	addi	s1,s1,4
    80003706:	01248963          	beq	s1,s2,80003718 <itrunc+0x7a>
      if (a[j])
    8000370a:	408c                	lw	a1,0(s1)
    8000370c:	dde5                	beqz	a1,80003704 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000370e:	0009a503          	lw	a0,0(s3)
    80003712:	9fbff0ef          	jal	8000310c <bfree>
    80003716:	b7fd                	j	80003704 <itrunc+0x66>
    brelse(bp);
    80003718:	8552                	mv	a0,s4
    8000371a:	907ff0ef          	jal	80003020 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000371e:	0809a583          	lw	a1,128(s3)
    80003722:	0009a503          	lw	a0,0(s3)
    80003726:	9e7ff0ef          	jal	8000310c <bfree>
    ip->addrs[NDIRECT] = 0;
    8000372a:	0809a023          	sw	zero,128(s3)
    8000372e:	6a02                	ld	s4,0(sp)
    80003730:	b75d                	j	800036d6 <itrunc+0x38>

0000000080003732 <iput>:
{
    80003732:	7179                	addi	sp,sp,-48
    80003734:	f406                	sd	ra,40(sp)
    80003736:	f022                	sd	s0,32(sp)
    80003738:	ec26                	sd	s1,24(sp)
    8000373a:	1800                	addi	s0,sp,48
    8000373c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000373e:	0001d517          	auipc	a0,0x1d
    80003742:	7fa50513          	addi	a0,a0,2042 # 80020f38 <itable>
    80003746:	ce2fd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    8000374a:	449c                	lw	a5,8(s1)
    8000374c:	4705                	li	a4,1
    8000374e:	00e78f63          	beq	a5,a4,8000376c <iput+0x3a>
  ip->ref--;
    80003752:	37fd                	addiw	a5,a5,-1
    80003754:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003756:	0001d517          	auipc	a0,0x1d
    8000375a:	7e250513          	addi	a0,a0,2018 # 80020f38 <itable>
    8000375e:	d52fd0ef          	jal	80000cb0 <release>
}
    80003762:	70a2                	ld	ra,40(sp)
    80003764:	7402                	ld	s0,32(sp)
    80003766:	64e2                	ld	s1,24(sp)
    80003768:	6145                	addi	sp,sp,48
    8000376a:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    8000376c:	40b8                	lw	a4,64(s1)
    8000376e:	d375                	beqz	a4,80003752 <iput+0x20>
    80003770:	e84a                	sd	s2,16(sp)
    80003772:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    80003774:	0004aa03          	lw	s4,0(s1)
    80003778:	0044a903          	lw	s2,4(s1)
  if (last) {
    8000377c:	04a49703          	lh	a4,74(s1)
    80003780:	ef3d                	bnez	a4,800037fe <iput+0xcc>
    80003782:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    80003784:	01048793          	addi	a5,s1,16
    80003788:	89be                	mv	s3,a5
    8000378a:	853e                	mv	a0,a5
    8000378c:	3b9000ef          	jal	80004344 <acquiresleep>
    release(&itable.lock);
    80003790:	0001d517          	auipc	a0,0x1d
    80003794:	7a850513          	addi	a0,a0,1960 # 80020f38 <itable>
    80003798:	d18fd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    8000379c:	8526                	mv	a0,s1
    8000379e:	f01ff0ef          	jal	8000369e <itrunc>
    ip->valid = 0;
    800037a2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800037a6:	854e                	mv	a0,s3
    800037a8:	3f1000ef          	jal	80004398 <releasesleep>
    acquire(&itable.lock);
    800037ac:	0001d517          	auipc	a0,0x1d
    800037b0:	78c50513          	addi	a0,a0,1932 # 80020f38 <itable>
    800037b4:	c74fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    800037b8:	449c                	lw	a5,8(s1)
    800037ba:	37fd                	addiw	a5,a5,-1
    800037bc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037be:	0001d517          	auipc	a0,0x1d
    800037c2:	77a50513          	addi	a0,a0,1914 # 80020f38 <itable>
    800037c6:	ceafd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800037ca:	0049579b          	srliw	a5,s2,0x4
    800037ce:	0001d597          	auipc	a1,0x1d
    800037d2:	7625a583          	lw	a1,1890(a1) # 80020f30 <sb+0x18>
    800037d6:	9dbd                	addw	a1,a1,a5
    800037d8:	8552                	mv	a0,s4
    800037da:	f3eff0ef          	jal	80002f18 <bread>
    800037de:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800037e0:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    800037e4:	079a                	slli	a5,a5,0x6
    800037e6:	97aa                	add	a5,a5,a0
    800037e8:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    800037ec:	1eb000ef          	jal	800041d6 <log_write>
  brelse(bp);
    800037f0:	8526                	mv	a0,s1
    800037f2:	82fff0ef          	jal	80003020 <brelse>
}
    800037f6:	6942                	ld	s2,16(sp)
    800037f8:	69a2                	ld	s3,8(sp)
    800037fa:	6a02                	ld	s4,0(sp)
    800037fc:	b79d                	j	80003762 <iput+0x30>
    800037fe:	6942                	ld	s2,16(sp)
    80003800:	6a02                	ld	s4,0(sp)
    80003802:	bf81                	j	80003752 <iput+0x20>

0000000080003804 <iunlockput>:
{
    80003804:	1101                	addi	sp,sp,-32
    80003806:	ec06                	sd	ra,24(sp)
    80003808:	e822                	sd	s0,16(sp)
    8000380a:	e426                	sd	s1,8(sp)
    8000380c:	1000                	addi	s0,sp,32
    8000380e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003810:	e4fff0ef          	jal	8000365e <iunlock>
  iput(ip);
    80003814:	8526                	mv	a0,s1
    80003816:	f1dff0ef          	jal	80003732 <iput>
}
    8000381a:	60e2                	ld	ra,24(sp)
    8000381c:	6442                	ld	s0,16(sp)
    8000381e:	64a2                	ld	s1,8(sp)
    80003820:	6105                	addi	sp,sp,32
    80003822:	8082                	ret

0000000080003824 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003824:	0001d717          	auipc	a4,0x1d
    80003828:	70072703          	lw	a4,1792(a4) # 80020f24 <sb+0xc>
    8000382c:	4785                	li	a5,1
    8000382e:	0ae7fe63          	bgeu	a5,a4,800038ea <ireclaim+0xc6>
{
    80003832:	7139                	addi	sp,sp,-64
    80003834:	fc06                	sd	ra,56(sp)
    80003836:	f822                	sd	s0,48(sp)
    80003838:	f426                	sd	s1,40(sp)
    8000383a:	f04a                	sd	s2,32(sp)
    8000383c:	ec4e                	sd	s3,24(sp)
    8000383e:	e852                	sd	s4,16(sp)
    80003840:	e456                	sd	s5,8(sp)
    80003842:	e05a                	sd	s6,0(sp)
    80003844:	0080                	addi	s0,sp,64
    80003846:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003848:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000384a:	0001da17          	auipc	s4,0x1d
    8000384e:	6cea0a13          	addi	s4,s4,1742 # 80020f18 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    80003852:	00004b17          	auipc	s6,0x4
    80003856:	c46b0b13          	addi	s6,s6,-954 # 80007498 <etext+0x498>
    8000385a:	a099                	j	800038a0 <ireclaim+0x7c>
    8000385c:	85ce                	mv	a1,s3
    8000385e:	855a                	mv	a0,s6
    80003860:	cabfc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    80003864:	85ce                	mv	a1,s3
    80003866:	8556                	mv	a0,s5
    80003868:	ad7ff0ef          	jal	8000333e <iget>
    8000386c:	89aa                	mv	s3,a0
    brelse(bp);
    8000386e:	854a                	mv	a0,s2
    80003870:	fb0ff0ef          	jal	80003020 <brelse>
    if (ip) {
    80003874:	00098f63          	beqz	s3,80003892 <ireclaim+0x6e>
      begin_op();
    80003878:	7b0000ef          	jal	80004028 <begin_op>
      ilock(ip);
    8000387c:	854e                	mv	a0,s3
    8000387e:	d33ff0ef          	jal	800035b0 <ilock>
      iunlock(ip);
    80003882:	854e                	mv	a0,s3
    80003884:	ddbff0ef          	jal	8000365e <iunlock>
      iput(ip);
    80003888:	854e                	mv	a0,s3
    8000388a:	ea9ff0ef          	jal	80003732 <iput>
      end_op();
    8000388e:	027000ef          	jal	800040b4 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003892:	0485                	addi	s1,s1,1
    80003894:	00ca2703          	lw	a4,12(s4)
    80003898:	0004879b          	sext.w	a5,s1
    8000389c:	02e7fd63          	bgeu	a5,a4,800038d6 <ireclaim+0xb2>
    800038a0:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800038a4:	0044d593          	srli	a1,s1,0x4
    800038a8:	018a2783          	lw	a5,24(s4)
    800038ac:	9dbd                	addw	a1,a1,a5
    800038ae:	8556                	mv	a0,s5
    800038b0:	e68ff0ef          	jal	80002f18 <bread>
    800038b4:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800038b6:	05850793          	addi	a5,a0,88
    800038ba:	00f9f713          	andi	a4,s3,15
    800038be:	071a                	slli	a4,a4,0x6
    800038c0:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    800038c2:	00079703          	lh	a4,0(a5)
    800038c6:	c701                	beqz	a4,800038ce <ireclaim+0xaa>
    800038c8:	00679783          	lh	a5,6(a5)
    800038cc:	dbc1                	beqz	a5,8000385c <ireclaim+0x38>
    brelse(bp);
    800038ce:	854a                	mv	a0,s2
    800038d0:	f50ff0ef          	jal	80003020 <brelse>
    if (ip) {
    800038d4:	bf7d                	j	80003892 <ireclaim+0x6e>
}
    800038d6:	70e2                	ld	ra,56(sp)
    800038d8:	7442                	ld	s0,48(sp)
    800038da:	74a2                	ld	s1,40(sp)
    800038dc:	7902                	ld	s2,32(sp)
    800038de:	69e2                	ld	s3,24(sp)
    800038e0:	6a42                	ld	s4,16(sp)
    800038e2:	6aa2                	ld	s5,8(sp)
    800038e4:	6b02                	ld	s6,0(sp)
    800038e6:	6121                	addi	sp,sp,64
    800038e8:	8082                	ret
    800038ea:	8082                	ret

00000000800038ec <fsinit>:
{
    800038ec:	1101                	addi	sp,sp,-32
    800038ee:	ec06                	sd	ra,24(sp)
    800038f0:	e822                	sd	s0,16(sp)
    800038f2:	e426                	sd	s1,8(sp)
    800038f4:	e04a                	sd	s2,0(sp)
    800038f6:	1000                	addi	s0,sp,32
    800038f8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800038fa:	4585                	li	a1,1
    800038fc:	e1cff0ef          	jal	80002f18 <bread>
    80003900:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003902:	02000613          	li	a2,32
    80003906:	05850593          	addi	a1,a0,88
    8000390a:	0001d517          	auipc	a0,0x1d
    8000390e:	60e50513          	addi	a0,a0,1550 # 80020f18 <sb>
    80003912:	c36fd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    80003916:	8526                	mv	a0,s1
    80003918:	f08ff0ef          	jal	80003020 <brelse>
  if (sb.magic != FSMAGIC)
    8000391c:	0001d717          	auipc	a4,0x1d
    80003920:	5fc72703          	lw	a4,1532(a4) # 80020f18 <sb>
    80003924:	102037b7          	lui	a5,0x10203
    80003928:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000392c:	02f71263          	bne	a4,a5,80003950 <fsinit+0x64>
  initlog(dev, &sb);
    80003930:	0001d597          	auipc	a1,0x1d
    80003934:	5e858593          	addi	a1,a1,1512 # 80020f18 <sb>
    80003938:	854a                	mv	a0,s2
    8000393a:	66c000ef          	jal	80003fa6 <initlog>
  ireclaim(dev);
    8000393e:	854a                	mv	a0,s2
    80003940:	ee5ff0ef          	jal	80003824 <ireclaim>
}
    80003944:	60e2                	ld	ra,24(sp)
    80003946:	6442                	ld	s0,16(sp)
    80003948:	64a2                	ld	s1,8(sp)
    8000394a:	6902                	ld	s2,0(sp)
    8000394c:	6105                	addi	sp,sp,32
    8000394e:	8082                	ret
    panic("invalid file system");
    80003950:	00004517          	auipc	a0,0x4
    80003954:	b6850513          	addi	a0,a0,-1176 # 800074b8 <etext+0x4b8>
    80003958:	eddfc0ef          	jal	80000834 <panic>

000000008000395c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000395c:	1141                	addi	sp,sp,-16
    8000395e:	e406                	sd	ra,8(sp)
    80003960:	e022                	sd	s0,0(sp)
    80003962:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003964:	411c                	lw	a5,0(a0)
    80003966:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003968:	415c                	lw	a5,4(a0)
    8000396a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000396c:	04451783          	lh	a5,68(a0)
    80003970:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003974:	04a51783          	lh	a5,74(a0)
    80003978:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000397c:	04c56783          	lwu	a5,76(a0)
    80003980:	e99c                	sd	a5,16(a1)
}
    80003982:	60a2                	ld	ra,8(sp)
    80003984:	6402                	ld	s0,0(sp)
    80003986:	0141                	addi	sp,sp,16
    80003988:	8082                	ret

000000008000398a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    8000398a:	457c                	lw	a5,76(a0)
    8000398c:	0ed7e663          	bltu	a5,a3,80003a78 <readi+0xee>
{
    80003990:	7159                	addi	sp,sp,-112
    80003992:	f486                	sd	ra,104(sp)
    80003994:	f0a2                	sd	s0,96(sp)
    80003996:	eca6                	sd	s1,88(sp)
    80003998:	e0d2                	sd	s4,64(sp)
    8000399a:	fc56                	sd	s5,56(sp)
    8000399c:	f85a                	sd	s6,48(sp)
    8000399e:	f45e                	sd	s7,40(sp)
    800039a0:	1880                	addi	s0,sp,112
    800039a2:	8b2a                	mv	s6,a0
    800039a4:	8bae                	mv	s7,a1
    800039a6:	8a32                	mv	s4,a2
    800039a8:	84b6                	mv	s1,a3
    800039aa:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800039ac:	9f35                	addw	a4,a4,a3
    return 0;
    800039ae:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800039b0:	0ad76b63          	bltu	a4,a3,80003a66 <readi+0xdc>
    800039b4:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    800039b6:	00e7f463          	bgeu	a5,a4,800039be <readi+0x34>
    n = ip->size - off;
    800039ba:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800039be:	080a8b63          	beqz	s5,80003a54 <readi+0xca>
    800039c2:	e8ca                	sd	s2,80(sp)
    800039c4:	f062                	sd	s8,32(sp)
    800039c6:	ec66                	sd	s9,24(sp)
    800039c8:	e86a                	sd	s10,16(sp)
    800039ca:	e46e                	sd	s11,8(sp)
    800039cc:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800039ce:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039d2:	5c7d                	li	s8,-1
    800039d4:	a80d                	j	80003a06 <readi+0x7c>
    800039d6:	020d1d93          	slli	s11,s10,0x20
    800039da:	020ddd93          	srli	s11,s11,0x20
    800039de:	05890613          	addi	a2,s2,88
    800039e2:	86ee                	mv	a3,s11
    800039e4:	963e                	add	a2,a2,a5
    800039e6:	85d2                	mv	a1,s4
    800039e8:	855e                	mv	a0,s7
    800039ea:	961fe0ef          	jal	8000234a <either_copyout>
    800039ee:	05850363          	beq	a0,s8,80003a34 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039f2:	854a                	mv	a0,s2
    800039f4:	e2cff0ef          	jal	80003020 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800039f8:	013d09bb          	addw	s3,s10,s3
    800039fc:	009d04bb          	addw	s1,s10,s1
    80003a00:	9a6e                	add	s4,s4,s11
    80003a02:	0559f363          	bgeu	s3,s5,80003a48 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    80003a06:	00a4d59b          	srliw	a1,s1,0xa
    80003a0a:	855a                	mv	a0,s6
    80003a0c:	873ff0ef          	jal	8000327e <bmap>
    80003a10:	85aa                	mv	a1,a0
    if (addr == 0)
    80003a12:	c139                	beqz	a0,80003a58 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003a14:	000b2503          	lw	a0,0(s6)
    80003a18:	d00ff0ef          	jal	80002f18 <bread>
    80003a1c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003a1e:	3ff4f793          	andi	a5,s1,1023
    80003a22:	40fc873b          	subw	a4,s9,a5
    80003a26:	413a86bb          	subw	a3,s5,s3
    80003a2a:	8d3a                	mv	s10,a4
    80003a2c:	fae6f5e3          	bgeu	a3,a4,800039d6 <readi+0x4c>
    80003a30:	8d36                	mv	s10,a3
    80003a32:	b755                	j	800039d6 <readi+0x4c>
      brelse(bp);
    80003a34:	854a                	mv	a0,s2
    80003a36:	deaff0ef          	jal	80003020 <brelse>
      tot = -1;
    80003a3a:	59fd                	li	s3,-1
      break;
    80003a3c:	6946                	ld	s2,80(sp)
    80003a3e:	7c02                	ld	s8,32(sp)
    80003a40:	6ce2                	ld	s9,24(sp)
    80003a42:	6d42                	ld	s10,16(sp)
    80003a44:	6da2                	ld	s11,8(sp)
    80003a46:	a831                	j	80003a62 <readi+0xd8>
    80003a48:	6946                	ld	s2,80(sp)
    80003a4a:	7c02                	ld	s8,32(sp)
    80003a4c:	6ce2                	ld	s9,24(sp)
    80003a4e:	6d42                	ld	s10,16(sp)
    80003a50:	6da2                	ld	s11,8(sp)
    80003a52:	a801                	j	80003a62 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003a54:	89d6                	mv	s3,s5
    80003a56:	a031                	j	80003a62 <readi+0xd8>
    80003a58:	6946                	ld	s2,80(sp)
    80003a5a:	7c02                	ld	s8,32(sp)
    80003a5c:	6ce2                	ld	s9,24(sp)
    80003a5e:	6d42                	ld	s10,16(sp)
    80003a60:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003a62:	854e                	mv	a0,s3
    80003a64:	69a6                	ld	s3,72(sp)
}
    80003a66:	70a6                	ld	ra,104(sp)
    80003a68:	7406                	ld	s0,96(sp)
    80003a6a:	64e6                	ld	s1,88(sp)
    80003a6c:	6a06                	ld	s4,64(sp)
    80003a6e:	7ae2                	ld	s5,56(sp)
    80003a70:	7b42                	ld	s6,48(sp)
    80003a72:	7ba2                	ld	s7,40(sp)
    80003a74:	6165                	addi	sp,sp,112
    80003a76:	8082                	ret
    return 0;
    80003a78:	4501                	li	a0,0
}
    80003a7a:	8082                	ret

0000000080003a7c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003a7c:	457c                	lw	a5,76(a0)
    80003a7e:	0ed7ee63          	bltu	a5,a3,80003b7a <writei+0xfe>
{
    80003a82:	7159                	addi	sp,sp,-112
    80003a84:	f486                	sd	ra,104(sp)
    80003a86:	f0a2                	sd	s0,96(sp)
    80003a88:	e8ca                	sd	s2,80(sp)
    80003a8a:	e0d2                	sd	s4,64(sp)
    80003a8c:	fc56                	sd	s5,56(sp)
    80003a8e:	f85a                	sd	s6,48(sp)
    80003a90:	f45e                	sd	s7,40(sp)
    80003a92:	1880                	addi	s0,sp,112
    80003a94:	8aaa                	mv	s5,a0
    80003a96:	8bae                	mv	s7,a1
    80003a98:	8a32                	mv	s4,a2
    80003a9a:	8936                	mv	s2,a3
    80003a9c:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003a9e:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003aa2:	00043737          	lui	a4,0x43
    80003aa6:	0cf76c63          	bltu	a4,a5,80003b7e <writei+0x102>
    80003aaa:	0cd7ea63          	bltu	a5,a3,80003b7e <writei+0x102>
    80003aae:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003ab0:	0a0b0d63          	beqz	s6,80003b6a <writei+0xee>
    80003ab4:	eca6                	sd	s1,88(sp)
    80003ab6:	f062                	sd	s8,32(sp)
    80003ab8:	ec66                	sd	s9,24(sp)
    80003aba:	e86a                	sd	s10,16(sp)
    80003abc:	e46e                	sd	s11,8(sp)
    80003abe:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003ac0:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ac4:	5c7d                	li	s8,-1
    80003ac6:	a825                	j	80003afe <writei+0x82>
    80003ac8:	020d1d93          	slli	s11,s10,0x20
    80003acc:	020ddd93          	srli	s11,s11,0x20
    80003ad0:	05848513          	addi	a0,s1,88
    80003ad4:	86ee                	mv	a3,s11
    80003ad6:	8652                	mv	a2,s4
    80003ad8:	85de                	mv	a1,s7
    80003ada:	953e                	add	a0,a0,a5
    80003adc:	8bbfe0ef          	jal	80002396 <either_copyin>
    80003ae0:	05850663          	beq	a0,s8,80003b2c <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ae4:	8526                	mv	a0,s1
    80003ae6:	6f0000ef          	jal	800041d6 <log_write>
    brelse(bp);
    80003aea:	8526                	mv	a0,s1
    80003aec:	d34ff0ef          	jal	80003020 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003af0:	013d09bb          	addw	s3,s10,s3
    80003af4:	012d093b          	addw	s2,s10,s2
    80003af8:	9a6e                	add	s4,s4,s11
    80003afa:	0369ff63          	bgeu	s3,s6,80003b38 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    80003afe:	00a9559b          	srliw	a1,s2,0xa
    80003b02:	8556                	mv	a0,s5
    80003b04:	f7aff0ef          	jal	8000327e <bmap>
    80003b08:	85aa                	mv	a1,a0
    if (addr == 0)
    80003b0a:	c51d                	beqz	a0,80003b38 <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003b0c:	000aa503          	lw	a0,0(s5)
    80003b10:	c08ff0ef          	jal	80002f18 <bread>
    80003b14:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003b16:	3ff97793          	andi	a5,s2,1023
    80003b1a:	40fc873b          	subw	a4,s9,a5
    80003b1e:	413b06bb          	subw	a3,s6,s3
    80003b22:	8d3a                	mv	s10,a4
    80003b24:	fae6f2e3          	bgeu	a3,a4,80003ac8 <writei+0x4c>
    80003b28:	8d36                	mv	s10,a3
    80003b2a:	bf79                	j	80003ac8 <writei+0x4c>
      log_write(bp);
    80003b2c:	8526                	mv	a0,s1
    80003b2e:	6a8000ef          	jal	800041d6 <log_write>
      brelse(bp);
    80003b32:	8526                	mv	a0,s1
    80003b34:	cecff0ef          	jal	80003020 <brelse>
  }

  if (off > ip->size)
    80003b38:	04caa783          	lw	a5,76(s5)
    80003b3c:	0327f963          	bgeu	a5,s2,80003b6e <writei+0xf2>
    ip->size = off;
    80003b40:	052aa623          	sw	s2,76(s5)
    80003b44:	64e6                	ld	s1,88(sp)
    80003b46:	7c02                	ld	s8,32(sp)
    80003b48:	6ce2                	ld	s9,24(sp)
    80003b4a:	6d42                	ld	s10,16(sp)
    80003b4c:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b4e:	8556                	mv	a0,s5
    80003b50:	9adff0ef          	jal	800034fc <iupdate>

  return tot;
    80003b54:	854e                	mv	a0,s3
    80003b56:	69a6                	ld	s3,72(sp)
}
    80003b58:	70a6                	ld	ra,104(sp)
    80003b5a:	7406                	ld	s0,96(sp)
    80003b5c:	6946                	ld	s2,80(sp)
    80003b5e:	6a06                	ld	s4,64(sp)
    80003b60:	7ae2                	ld	s5,56(sp)
    80003b62:	7b42                	ld	s6,48(sp)
    80003b64:	7ba2                	ld	s7,40(sp)
    80003b66:	6165                	addi	sp,sp,112
    80003b68:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003b6a:	89da                	mv	s3,s6
    80003b6c:	b7cd                	j	80003b4e <writei+0xd2>
    80003b6e:	64e6                	ld	s1,88(sp)
    80003b70:	7c02                	ld	s8,32(sp)
    80003b72:	6ce2                	ld	s9,24(sp)
    80003b74:	6d42                	ld	s10,16(sp)
    80003b76:	6da2                	ld	s11,8(sp)
    80003b78:	bfd9                	j	80003b4e <writei+0xd2>
    return -1;
    80003b7a:	557d                	li	a0,-1
}
    80003b7c:	8082                	ret
    return -1;
    80003b7e:	557d                	li	a0,-1
    80003b80:	bfe1                	j	80003b58 <writei+0xdc>

0000000080003b82 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b82:	1141                	addi	sp,sp,-16
    80003b84:	e406                	sd	ra,8(sp)
    80003b86:	e022                	sd	s0,0(sp)
    80003b88:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b8a:	4639                	li	a2,14
    80003b8c:	a30fd0ef          	jal	80000dbc <strncmp>
}
    80003b90:	60a2                	ld	ra,8(sp)
    80003b92:	6402                	ld	s0,0(sp)
    80003b94:	0141                	addi	sp,sp,16
    80003b96:	8082                	ret

0000000080003b98 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b98:	711d                	addi	sp,sp,-96
    80003b9a:	ec86                	sd	ra,88(sp)
    80003b9c:	e8a2                	sd	s0,80(sp)
    80003b9e:	e4a6                	sd	s1,72(sp)
    80003ba0:	e0ca                	sd	s2,64(sp)
    80003ba2:	fc4e                	sd	s3,56(sp)
    80003ba4:	f852                	sd	s4,48(sp)
    80003ba6:	f456                	sd	s5,40(sp)
    80003ba8:	f05a                	sd	s6,32(sp)
    80003baa:	ec5e                	sd	s7,24(sp)
    80003bac:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003bae:	04451703          	lh	a4,68(a0)
    80003bb2:	4785                	li	a5,1
    80003bb4:	00f71f63          	bne	a4,a5,80003bd2 <dirlookup+0x3a>
    80003bb8:	892a                	mv	s2,a0
    80003bba:	8aae                	mv	s5,a1
    80003bbc:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003bbe:	457c                	lw	a5,76(a0)
    80003bc0:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bc2:	fa040a13          	addi	s4,s0,-96
    80003bc6:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003bc8:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bcc:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003bce:	e39d                	bnez	a5,80003bf4 <dirlookup+0x5c>
    80003bd0:	a8b9                	j	80003c2e <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003bd2:	00004517          	auipc	a0,0x4
    80003bd6:	8fe50513          	addi	a0,a0,-1794 # 800074d0 <etext+0x4d0>
    80003bda:	c5bfc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    80003bde:	00004517          	auipc	a0,0x4
    80003be2:	90a50513          	addi	a0,a0,-1782 # 800074e8 <etext+0x4e8>
    80003be6:	c4ffc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003bea:	24c1                	addiw	s1,s1,16
    80003bec:	04c92783          	lw	a5,76(s2)
    80003bf0:	02f4fe63          	bgeu	s1,a5,80003c2c <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bf4:	874e                	mv	a4,s3
    80003bf6:	86a6                	mv	a3,s1
    80003bf8:	8652                	mv	a2,s4
    80003bfa:	4581                	li	a1,0
    80003bfc:	854a                	mv	a0,s2
    80003bfe:	d8dff0ef          	jal	8000398a <readi>
    80003c02:	fd351ee3          	bne	a0,s3,80003bde <dirlookup+0x46>
    if (de.inum == 0)
    80003c06:	fa045783          	lhu	a5,-96(s0)
    80003c0a:	d3e5                	beqz	a5,80003bea <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003c0c:	85da                	mv	a1,s6
    80003c0e:	8556                	mv	a0,s5
    80003c10:	f73ff0ef          	jal	80003b82 <namecmp>
    80003c14:	f979                	bnez	a0,80003bea <dirlookup+0x52>
      if (poff)
    80003c16:	000b8463          	beqz	s7,80003c1e <dirlookup+0x86>
        *poff = off;
    80003c1a:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003c1e:	fa045583          	lhu	a1,-96(s0)
    80003c22:	00092503          	lw	a0,0(s2)
    80003c26:	f18ff0ef          	jal	8000333e <iget>
    80003c2a:	a011                	j	80003c2e <dirlookup+0x96>
  return 0;
    80003c2c:	4501                	li	a0,0
}
    80003c2e:	60e6                	ld	ra,88(sp)
    80003c30:	6446                	ld	s0,80(sp)
    80003c32:	64a6                	ld	s1,72(sp)
    80003c34:	6906                	ld	s2,64(sp)
    80003c36:	79e2                	ld	s3,56(sp)
    80003c38:	7a42                	ld	s4,48(sp)
    80003c3a:	7aa2                	ld	s5,40(sp)
    80003c3c:	7b02                	ld	s6,32(sp)
    80003c3e:	6be2                	ld	s7,24(sp)
    80003c40:	6125                	addi	sp,sp,96
    80003c42:	8082                	ret

0000000080003c44 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003c44:	711d                	addi	sp,sp,-96
    80003c46:	ec86                	sd	ra,88(sp)
    80003c48:	e8a2                	sd	s0,80(sp)
    80003c4a:	e4a6                	sd	s1,72(sp)
    80003c4c:	e0ca                	sd	s2,64(sp)
    80003c4e:	fc4e                	sd	s3,56(sp)
    80003c50:	f852                	sd	s4,48(sp)
    80003c52:	f456                	sd	s5,40(sp)
    80003c54:	f05a                	sd	s6,32(sp)
    80003c56:	ec5e                	sd	s7,24(sp)
    80003c58:	e862                	sd	s8,16(sp)
    80003c5a:	e466                	sd	s9,8(sp)
    80003c5c:	e06a                	sd	s10,0(sp)
    80003c5e:	1080                	addi	s0,sp,96
    80003c60:	84aa                	mv	s1,a0
    80003c62:	8b2e                	mv	s6,a1
    80003c64:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003c66:	00054703          	lbu	a4,0(a0)
    80003c6a:	02f00793          	li	a5,47
    80003c6e:	00f70f63          	beq	a4,a5,80003c8c <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c72:	cdffd0ef          	jal	80001950 <myproc>
    80003c76:	15053503          	ld	a0,336(a0)
    80003c7a:	901ff0ef          	jal	8000357a <idup>
    80003c7e:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003c80:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003c84:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003c86:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003c88:	4b85                	li	s7,1
    80003c8a:	a07d                	j	80003d38 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003c8c:	4585                	li	a1,1
    80003c8e:	852e                	mv	a0,a1
    80003c90:	eaeff0ef          	jal	8000333e <iget>
    80003c94:	8a2a                	mv	s4,a0
    80003c96:	b7ed                	j	80003c80 <namex+0x3c>
      iunlockput(ip);
    80003c98:	8552                	mv	a0,s4
    80003c9a:	b6bff0ef          	jal	80003804 <iunlockput>
      return 0;
    80003c9e:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ca0:	8552                	mv	a0,s4
    80003ca2:	60e6                	ld	ra,88(sp)
    80003ca4:	6446                	ld	s0,80(sp)
    80003ca6:	64a6                	ld	s1,72(sp)
    80003ca8:	6906                	ld	s2,64(sp)
    80003caa:	79e2                	ld	s3,56(sp)
    80003cac:	7a42                	ld	s4,48(sp)
    80003cae:	7aa2                	ld	s5,40(sp)
    80003cb0:	7b02                	ld	s6,32(sp)
    80003cb2:	6be2                	ld	s7,24(sp)
    80003cb4:	6c42                	ld	s8,16(sp)
    80003cb6:	6ca2                	ld	s9,8(sp)
    80003cb8:	6d02                	ld	s10,0(sp)
    80003cba:	6125                	addi	sp,sp,96
    80003cbc:	8082                	ret
      iunlockput(ip);
    80003cbe:	8552                	mv	a0,s4
    80003cc0:	b45ff0ef          	jal	80003804 <iunlockput>
      return 0;
    80003cc4:	4a01                	li	s4,0
    80003cc6:	bfe9                	j	80003ca0 <namex+0x5c>
      iunlock(ip);
    80003cc8:	8552                	mv	a0,s4
    80003cca:	995ff0ef          	jal	8000365e <iunlock>
      return ip;
    80003cce:	bfc9                	j	80003ca0 <namex+0x5c>
      iunlockput(ip);
    80003cd0:	8552                	mv	a0,s4
    80003cd2:	b33ff0ef          	jal	80003804 <iunlockput>
      return 0;
    80003cd6:	8a4a                	mv	s4,s2
    80003cd8:	b7e1                	j	80003ca0 <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003cda:	8926                	mv	s2,s1
  len = path - s;
    80003cdc:	4d01                	li	s10,0
    80003cde:	4601                	li	a2,0
    memmove(name, s, len);
    80003ce0:	2601                	sext.w	a2,a2
    80003ce2:	85a6                	mv	a1,s1
    80003ce4:	8556                	mv	a0,s5
    80003ce6:	862fd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003cea:	9d56                	add	s10,s10,s5
    80003cec:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb3e0>
  while (*path == '/')
    80003cf0:	00094783          	lbu	a5,0(s2)
    80003cf4:	09379b63          	bne	a5,s3,80003d8a <namex+0x146>
    80003cf8:	84ca                	mv	s1,s2
    path++;
    80003cfa:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003cfc:	0004c783          	lbu	a5,0(s1)
    80003d00:	ff378de3          	beq	a5,s3,80003cfa <namex+0xb6>
    ilock(ip);
    80003d04:	8552                	mv	a0,s4
    80003d06:	8abff0ef          	jal	800035b0 <ilock>
    if (ip->type != T_DIR) {
    80003d0a:	044a1783          	lh	a5,68(s4)
    80003d0e:	f97795e3          	bne	a5,s7,80003c98 <namex+0x54>
    if (ip->nlink == 0) {
    80003d12:	04aa1783          	lh	a5,74(s4)
    80003d16:	d7c5                	beqz	a5,80003cbe <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003d18:	000b0563          	beqz	s6,80003d22 <namex+0xde>
    80003d1c:	0004c783          	lbu	a5,0(s1)
    80003d20:	d7c5                	beqz	a5,80003cc8 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003d22:	4601                	li	a2,0
    80003d24:	85d6                	mv	a1,s5
    80003d26:	8552                	mv	a0,s4
    80003d28:	e71ff0ef          	jal	80003b98 <dirlookup>
    80003d2c:	892a                	mv	s2,a0
    80003d2e:	d14d                	beqz	a0,80003cd0 <namex+0x8c>
    iunlockput(ip);
    80003d30:	8552                	mv	a0,s4
    80003d32:	ad3ff0ef          	jal	80003804 <iunlockput>
    ip = next;
    80003d36:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003d38:	0004c783          	lbu	a5,0(s1)
    80003d3c:	01379763          	bne	a5,s3,80003d4a <namex+0x106>
    path++;
    80003d40:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003d42:	0004c783          	lbu	a5,0(s1)
    80003d46:	ff378de3          	beq	a5,s3,80003d40 <namex+0xfc>
  if (*path == 0)
    80003d4a:	c7a1                	beqz	a5,80003d92 <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003d4c:	0004c783          	lbu	a5,0(s1)
    80003d50:	fd178713          	addi	a4,a5,-47
    80003d54:	d359                	beqz	a4,80003cda <namex+0x96>
    80003d56:	d3d1                	beqz	a5,80003cda <namex+0x96>
    80003d58:	8926                	mv	s2,s1
    path++;
    80003d5a:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003d5c:	00094783          	lbu	a5,0(s2)
    80003d60:	fd178713          	addi	a4,a5,-47
    80003d64:	c311                	beqz	a4,80003d68 <namex+0x124>
    80003d66:	fbf5                	bnez	a5,80003d5a <namex+0x116>
  len = path - s;
    80003d68:	40990633          	sub	a2,s2,s1
    80003d6c:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003d70:	f7ac58e3          	bge	s8,s10,80003ce0 <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003d74:	8666                	mv	a2,s9
    80003d76:	85a6                	mv	a1,s1
    80003d78:	8556                	mv	a0,s5
    80003d7a:	fcffc0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003d7e:	00094783          	lbu	a5,0(s2)
    80003d82:	84ca                	mv	s1,s2
    80003d84:	f7378be3          	beq	a5,s3,80003cfa <namex+0xb6>
    80003d88:	bfb5                	j	80003d04 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003d8a:	00090463          	beqz	s2,80003d92 <namex+0x14e>
    80003d8e:	84ca                	mv	s1,s2
    80003d90:	bf95                	j	80003d04 <namex+0xc0>
  if (nameiparent) {
    80003d92:	f00b07e3          	beqz	s6,80003ca0 <namex+0x5c>
    iput(ip);
    80003d96:	8552                	mv	a0,s4
    80003d98:	99bff0ef          	jal	80003732 <iput>
    return 0;
    80003d9c:	4a01                	li	s4,0
    80003d9e:	b709                	j	80003ca0 <namex+0x5c>

0000000080003da0 <dirlink>:
{
    80003da0:	715d                	addi	sp,sp,-80
    80003da2:	e486                	sd	ra,72(sp)
    80003da4:	e0a2                	sd	s0,64(sp)
    80003da6:	f84a                	sd	s2,48(sp)
    80003da8:	ec56                	sd	s5,24(sp)
    80003daa:	e85a                	sd	s6,16(sp)
    80003dac:	0880                	addi	s0,sp,80
    80003dae:	892a                	mv	s2,a0
    80003db0:	8aae                	mv	s5,a1
    80003db2:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003db4:	4601                	li	a2,0
    80003db6:	de3ff0ef          	jal	80003b98 <dirlookup>
    80003dba:	ed1d                	bnez	a0,80003df8 <dirlink+0x58>
    80003dbc:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003dbe:	04c92483          	lw	s1,76(s2)
    80003dc2:	c4b9                	beqz	s1,80003e10 <dirlink+0x70>
    80003dc4:	f44e                	sd	s3,40(sp)
    80003dc6:	f052                	sd	s4,32(sp)
    80003dc8:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dca:	fb040a13          	addi	s4,s0,-80
    80003dce:	49c1                	li	s3,16
    80003dd0:	874e                	mv	a4,s3
    80003dd2:	86a6                	mv	a3,s1
    80003dd4:	8652                	mv	a2,s4
    80003dd6:	4581                	li	a1,0
    80003dd8:	854a                	mv	a0,s2
    80003dda:	bb1ff0ef          	jal	8000398a <readi>
    80003dde:	03351163          	bne	a0,s3,80003e00 <dirlink+0x60>
    if (de.inum == 0)
    80003de2:	fb045783          	lhu	a5,-80(s0)
    80003de6:	c39d                	beqz	a5,80003e0c <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003de8:	24c1                	addiw	s1,s1,16
    80003dea:	04c92783          	lw	a5,76(s2)
    80003dee:	fef4e1e3          	bltu	s1,a5,80003dd0 <dirlink+0x30>
    80003df2:	79a2                	ld	s3,40(sp)
    80003df4:	7a02                	ld	s4,32(sp)
    80003df6:	a829                	j	80003e10 <dirlink+0x70>
    iput(ip);
    80003df8:	93bff0ef          	jal	80003732 <iput>
    return -1;
    80003dfc:	557d                	li	a0,-1
    80003dfe:	a83d                	j	80003e3c <dirlink+0x9c>
      panic("dirlink read");
    80003e00:	00003517          	auipc	a0,0x3
    80003e04:	6f850513          	addi	a0,a0,1784 # 800074f8 <etext+0x4f8>
    80003e08:	a2dfc0ef          	jal	80000834 <panic>
    80003e0c:	79a2                	ld	s3,40(sp)
    80003e0e:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003e10:	4639                	li	a2,14
    80003e12:	85d6                	mv	a1,s5
    80003e14:	fb240513          	addi	a0,s0,-78
    80003e18:	fdffc0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003e1c:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e20:	4741                	li	a4,16
    80003e22:	86a6                	mv	a3,s1
    80003e24:	fb040613          	addi	a2,s0,-80
    80003e28:	4581                	li	a1,0
    80003e2a:	854a                	mv	a0,s2
    80003e2c:	c51ff0ef          	jal	80003a7c <writei>
    80003e30:	1541                	addi	a0,a0,-16
    80003e32:	00a03533          	snez	a0,a0
    80003e36:	40a0053b          	negw	a0,a0
    80003e3a:	74e2                	ld	s1,56(sp)
}
    80003e3c:	60a6                	ld	ra,72(sp)
    80003e3e:	6406                	ld	s0,64(sp)
    80003e40:	7942                	ld	s2,48(sp)
    80003e42:	6ae2                	ld	s5,24(sp)
    80003e44:	6b42                	ld	s6,16(sp)
    80003e46:	6161                	addi	sp,sp,80
    80003e48:	8082                	ret

0000000080003e4a <namei>:

struct inode *
namei(char *path)
{
    80003e4a:	1101                	addi	sp,sp,-32
    80003e4c:	ec06                	sd	ra,24(sp)
    80003e4e:	e822                	sd	s0,16(sp)
    80003e50:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e52:	fe040613          	addi	a2,s0,-32
    80003e56:	4581                	li	a1,0
    80003e58:	dedff0ef          	jal	80003c44 <namex>
}
    80003e5c:	60e2                	ld	ra,24(sp)
    80003e5e:	6442                	ld	s0,16(sp)
    80003e60:	6105                	addi	sp,sp,32
    80003e62:	8082                	ret

0000000080003e64 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003e64:	1141                	addi	sp,sp,-16
    80003e66:	e406                	sd	ra,8(sp)
    80003e68:	e022                	sd	s0,0(sp)
    80003e6a:	0800                	addi	s0,sp,16
    80003e6c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e6e:	4585                	li	a1,1
    80003e70:	dd5ff0ef          	jal	80003c44 <namex>
}
    80003e74:	60a2                	ld	ra,8(sp)
    80003e76:	6402                	ld	s0,0(sp)
    80003e78:	0141                	addi	sp,sp,16
    80003e7a:	8082                	ret

0000000080003e7c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e7c:	1101                	addi	sp,sp,-32
    80003e7e:	ec06                	sd	ra,24(sp)
    80003e80:	e822                	sd	s0,16(sp)
    80003e82:	e426                	sd	s1,8(sp)
    80003e84:	e04a                	sd	s2,0(sp)
    80003e86:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e88:	0001f917          	auipc	s2,0x1f
    80003e8c:	b5890913          	addi	s2,s2,-1192 # 800229e0 <log>
    80003e90:	01892583          	lw	a1,24(s2)
    80003e94:	02492503          	lw	a0,36(s2)
    80003e98:	880ff0ef          	jal	80002f18 <bread>
    80003e9c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003e9e:	02c92603          	lw	a2,44(s2)
    80003ea2:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003ea4:	00c05f63          	blez	a2,80003ec2 <write_head+0x46>
    80003ea8:	0001f717          	auipc	a4,0x1f
    80003eac:	b6870713          	addi	a4,a4,-1176 # 80022a10 <log+0x30>
    80003eb0:	87aa                	mv	a5,a0
    80003eb2:	060a                	slli	a2,a2,0x2
    80003eb4:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003eb6:	4314                	lw	a3,0(a4)
    80003eb8:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003eba:	0711                	addi	a4,a4,4
    80003ebc:	0791                	addi	a5,a5,4
    80003ebe:	fec79ce3          	bne	a5,a2,80003eb6 <write_head+0x3a>
  }
  bwrite(buf);
    80003ec2:	8526                	mv	a0,s1
    80003ec4:	92aff0ef          	jal	80002fee <bwrite>
  brelse(buf);
    80003ec8:	8526                	mv	a0,s1
    80003eca:	956ff0ef          	jal	80003020 <brelse>
}
    80003ece:	60e2                	ld	ra,24(sp)
    80003ed0:	6442                	ld	s0,16(sp)
    80003ed2:	64a2                	ld	s1,8(sp)
    80003ed4:	6902                	ld	s2,0(sp)
    80003ed6:	6105                	addi	sp,sp,32
    80003ed8:	8082                	ret

0000000080003eda <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003eda:	0001f797          	auipc	a5,0x1f
    80003ede:	b327a783          	lw	a5,-1230(a5) # 80022a0c <log+0x2c>
    80003ee2:	0cf05163          	blez	a5,80003fa4 <install_trans+0xca>
{
    80003ee6:	715d                	addi	sp,sp,-80
    80003ee8:	e486                	sd	ra,72(sp)
    80003eea:	e0a2                	sd	s0,64(sp)
    80003eec:	fc26                	sd	s1,56(sp)
    80003eee:	f84a                	sd	s2,48(sp)
    80003ef0:	f44e                	sd	s3,40(sp)
    80003ef2:	f052                	sd	s4,32(sp)
    80003ef4:	ec56                	sd	s5,24(sp)
    80003ef6:	e85a                	sd	s6,16(sp)
    80003ef8:	e45e                	sd	s7,8(sp)
    80003efa:	e062                	sd	s8,0(sp)
    80003efc:	0880                	addi	s0,sp,80
    80003efe:	8b2a                	mv	s6,a0
    80003f00:	0001fa97          	auipc	s5,0x1f
    80003f04:	b10a8a93          	addi	s5,s5,-1264 # 80022a10 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f08:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003f0a:	00003c17          	auipc	s8,0x3
    80003f0e:	5fec0c13          	addi	s8,s8,1534 # 80007508 <etext+0x508>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003f12:	0001fa17          	auipc	s4,0x1f
    80003f16:	acea0a13          	addi	s4,s4,-1330 # 800229e0 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003f1a:	40000b93          	li	s7,1024
    80003f1e:	a025                	j	80003f46 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003f20:	000aa603          	lw	a2,0(s5)
    80003f24:	85ce                	mv	a1,s3
    80003f26:	8562                	mv	a0,s8
    80003f28:	de2fc0ef          	jal	8000050a <printk>
    80003f2c:	a839                	j	80003f4a <install_trans+0x70>
    brelse(lbuf);
    80003f2e:	854a                	mv	a0,s2
    80003f30:	8f0ff0ef          	jal	80003020 <brelse>
    brelse(dbuf);
    80003f34:	8526                	mv	a0,s1
    80003f36:	8eaff0ef          	jal	80003020 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f3a:	2985                	addiw	s3,s3,1
    80003f3c:	0a91                	addi	s5,s5,4
    80003f3e:	02ca2783          	lw	a5,44(s4)
    80003f42:	04f9d563          	bge	s3,a5,80003f8c <install_trans+0xb2>
    if (recovering) {
    80003f46:	fc0b1de3          	bnez	s6,80003f20 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003f4a:	018a2583          	lw	a1,24(s4)
    80003f4e:	013585bb          	addw	a1,a1,s3
    80003f52:	2585                	addiw	a1,a1,1
    80003f54:	024a2503          	lw	a0,36(s4)
    80003f58:	fc1fe0ef          	jal	80002f18 <bread>
    80003f5c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003f5e:	000aa583          	lw	a1,0(s5)
    80003f62:	024a2503          	lw	a0,36(s4)
    80003f66:	fb3fe0ef          	jal	80002f18 <bread>
    80003f6a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003f6c:	865e                	mv	a2,s7
    80003f6e:	05890593          	addi	a1,s2,88
    80003f72:	05850513          	addi	a0,a0,88
    80003f76:	dd3fc0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003f7a:	8526                	mv	a0,s1
    80003f7c:	872ff0ef          	jal	80002fee <bwrite>
    if (recovering == 0)
    80003f80:	fa0b17e3          	bnez	s6,80003f2e <install_trans+0x54>
      bunpin(dbuf);
    80003f84:	8526                	mv	a0,s1
    80003f86:	952ff0ef          	jal	800030d8 <bunpin>
    80003f8a:	b755                	j	80003f2e <install_trans+0x54>
}
    80003f8c:	60a6                	ld	ra,72(sp)
    80003f8e:	6406                	ld	s0,64(sp)
    80003f90:	74e2                	ld	s1,56(sp)
    80003f92:	7942                	ld	s2,48(sp)
    80003f94:	79a2                	ld	s3,40(sp)
    80003f96:	7a02                	ld	s4,32(sp)
    80003f98:	6ae2                	ld	s5,24(sp)
    80003f9a:	6b42                	ld	s6,16(sp)
    80003f9c:	6ba2                	ld	s7,8(sp)
    80003f9e:	6c02                	ld	s8,0(sp)
    80003fa0:	6161                	addi	sp,sp,80
    80003fa2:	8082                	ret
    80003fa4:	8082                	ret

0000000080003fa6 <initlog>:
{
    80003fa6:	7179                	addi	sp,sp,-48
    80003fa8:	f406                	sd	ra,40(sp)
    80003faa:	f022                	sd	s0,32(sp)
    80003fac:	ec26                	sd	s1,24(sp)
    80003fae:	e84a                	sd	s2,16(sp)
    80003fb0:	e44e                	sd	s3,8(sp)
    80003fb2:	1800                	addi	s0,sp,48
    80003fb4:	84aa                	mv	s1,a0
    80003fb6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003fb8:	0001f917          	auipc	s2,0x1f
    80003fbc:	a2890913          	addi	s2,s2,-1496 # 800229e0 <log>
    80003fc0:	00003597          	auipc	a1,0x3
    80003fc4:	56858593          	addi	a1,a1,1384 # 80007528 <etext+0x528>
    80003fc8:	854a                	mv	a0,s2
    80003fca:	bdffc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003fce:	0149a583          	lw	a1,20(s3)
    80003fd2:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003fd6:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003fda:	8526                	mv	a0,s1
    80003fdc:	f3dfe0ef          	jal	80002f18 <bread>
  log.lh.n = lh->n;
    80003fe0:	4d30                	lw	a2,88(a0)
    80003fe2:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003fe6:	00c05f63          	blez	a2,80004004 <initlog+0x5e>
    80003fea:	87aa                	mv	a5,a0
    80003fec:	0001f717          	auipc	a4,0x1f
    80003ff0:	a2470713          	addi	a4,a4,-1500 # 80022a10 <log+0x30>
    80003ff4:	060a                	slli	a2,a2,0x2
    80003ff6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003ff8:	4ff4                	lw	a3,92(a5)
    80003ffa:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ffc:	0791                	addi	a5,a5,4
    80003ffe:	0711                	addi	a4,a4,4
    80004000:	fec79ce3          	bne	a5,a2,80003ff8 <initlog+0x52>
  brelse(buf);
    80004004:	81cff0ef          	jal	80003020 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004008:	4505                	li	a0,1
    8000400a:	ed1ff0ef          	jal	80003eda <install_trans>
  log.lh.n = 0;
    8000400e:	0001f797          	auipc	a5,0x1f
    80004012:	9e07af23          	sw	zero,-1538(a5) # 80022a0c <log+0x2c>
  write_head(); // clear the log
    80004016:	e67ff0ef          	jal	80003e7c <write_head>
}
    8000401a:	70a2                	ld	ra,40(sp)
    8000401c:	7402                	ld	s0,32(sp)
    8000401e:	64e2                	ld	s1,24(sp)
    80004020:	6942                	ld	s2,16(sp)
    80004022:	69a2                	ld	s3,8(sp)
    80004024:	6145                	addi	sp,sp,48
    80004026:	8082                	ret

0000000080004028 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004028:	1101                	addi	sp,sp,-32
    8000402a:	ec06                	sd	ra,24(sp)
    8000402c:	e822                	sd	s0,16(sp)
    8000402e:	e426                	sd	s1,8(sp)
    80004030:	e04a                	sd	s2,0(sp)
    80004032:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004034:	0001f517          	auipc	a0,0x1f
    80004038:	9ac50513          	addi	a0,a0,-1620 # 800229e0 <log>
    8000403c:	bedfc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80004040:	0001f497          	auipc	s1,0x1f
    80004044:	9a048493          	addi	s1,s1,-1632 # 800229e0 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80004048:	4979                	li	s2,30
    8000404a:	a821                	j	80004062 <begin_op+0x3a>
      sleep_prepare(&log);
    8000404c:	8526                	mv	a0,s1
    8000404e:	f6bfd0ef          	jal	80001fb8 <sleep_prepare>
      release(&log.lock);
    80004052:	8526                	mv	a0,s1
    80004054:	c5dfc0ef          	jal	80000cb0 <release>
      sleep();
    80004058:	f9dfd0ef          	jal	80001ff4 <sleep>
      acquire(&log.lock);
    8000405c:	8526                	mv	a0,s1
    8000405e:	bcbfc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80004062:	509c                	lw	a5,32(s1)
    80004064:	f7e5                	bnez	a5,8000404c <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80004066:	4cd8                	lw	a4,28(s1)
    80004068:	2705                	addiw	a4,a4,1
    8000406a:	0027179b          	slliw	a5,a4,0x2
    8000406e:	9fb9                	addw	a5,a5,a4
    80004070:	0017979b          	slliw	a5,a5,0x1
    80004074:	54d4                	lw	a3,44(s1)
    80004076:	9fb5                	addw	a5,a5,a3
    80004078:	00f95e63          	bge	s2,a5,80004094 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    8000407c:	8526                	mv	a0,s1
    8000407e:	f3bfd0ef          	jal	80001fb8 <sleep_prepare>
      release(&log.lock);
    80004082:	8526                	mv	a0,s1
    80004084:	c2dfc0ef          	jal	80000cb0 <release>
      sleep();
    80004088:	f6dfd0ef          	jal	80001ff4 <sleep>
      acquire(&log.lock);
    8000408c:	8526                	mv	a0,s1
    8000408e:	b9bfc0ef          	jal	80000c28 <acquire>
    80004092:	bfc1                	j	80004062 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80004094:	0001f797          	auipc	a5,0x1f
    80004098:	96e7a423          	sw	a4,-1688(a5) # 800229fc <log+0x1c>
      release(&log.lock);
    8000409c:	0001f517          	auipc	a0,0x1f
    800040a0:	94450513          	addi	a0,a0,-1724 # 800229e0 <log>
    800040a4:	c0dfc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    800040a8:	60e2                	ld	ra,24(sp)
    800040aa:	6442                	ld	s0,16(sp)
    800040ac:	64a2                	ld	s1,8(sp)
    800040ae:	6902                	ld	s2,0(sp)
    800040b0:	6105                	addi	sp,sp,32
    800040b2:	8082                	ret

00000000800040b4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800040b4:	7139                	addi	sp,sp,-64
    800040b6:	fc06                	sd	ra,56(sp)
    800040b8:	f822                	sd	s0,48(sp)
    800040ba:	f426                	sd	s1,40(sp)
    800040bc:	f04a                	sd	s2,32(sp)
    800040be:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040c0:	0001f497          	auipc	s1,0x1f
    800040c4:	92048493          	addi	s1,s1,-1760 # 800229e0 <log>
    800040c8:	8526                	mv	a0,s1
    800040ca:	b5ffc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    800040ce:	4cdc                	lw	a5,28(s1)
    800040d0:	37fd                	addiw	a5,a5,-1
    800040d2:	893e                	mv	s2,a5
    800040d4:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    800040d6:	509c                	lw	a5,32(s1)
    800040d8:	e3b1                	bnez	a5,8000411c <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    800040da:	04091a63          	bnez	s2,8000412e <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    800040de:	0001f497          	auipc	s1,0x1f
    800040e2:	90248493          	addi	s1,s1,-1790 # 800229e0 <log>
    800040e6:	4785                	li	a5,1
    800040e8:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800040ea:	8526                	mv	a0,s1
    800040ec:	bc5fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800040f0:	54dc                	lw	a5,44(s1)
    800040f2:	06f04063          	bgtz	a5,80004152 <end_op+0x9e>
    acquire(&log.lock);
    800040f6:	0001f497          	auipc	s1,0x1f
    800040fa:	8ea48493          	addi	s1,s1,-1814 # 800229e0 <log>
    800040fe:	8526                	mv	a0,s1
    80004100:	b29fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80004104:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80004108:	549c                	lw	a5,40(s1)
    8000410a:	2785                	addiw	a5,a5,1
    8000410c:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    8000410e:	8526                	mv	a0,s1
    80004110:	f15fd0ef          	jal	80002024 <wakeup>
    release(&log.lock);
    80004114:	8526                	mv	a0,s1
    80004116:	b9bfc0ef          	jal	80000cb0 <release>
}
    8000411a:	a035                	j	80004146 <end_op+0x92>
    8000411c:	ec4e                	sd	s3,24(sp)
    8000411e:	e852                	sd	s4,16(sp)
    80004120:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004122:	00003517          	auipc	a0,0x3
    80004126:	40e50513          	addi	a0,a0,1038 # 80007530 <etext+0x530>
    8000412a:	f0afc0ef          	jal	80000834 <panic>
    wakeup(&log);
    8000412e:	0001f517          	auipc	a0,0x1f
    80004132:	8b250513          	addi	a0,a0,-1870 # 800229e0 <log>
    80004136:	eeffd0ef          	jal	80002024 <wakeup>
  release(&log.lock);
    8000413a:	0001f517          	auipc	a0,0x1f
    8000413e:	8a650513          	addi	a0,a0,-1882 # 800229e0 <log>
    80004142:	b6ffc0ef          	jal	80000cb0 <release>
}
    80004146:	70e2                	ld	ra,56(sp)
    80004148:	7442                	ld	s0,48(sp)
    8000414a:	74a2                	ld	s1,40(sp)
    8000414c:	7902                	ld	s2,32(sp)
    8000414e:	6121                	addi	sp,sp,64
    80004150:	8082                	ret
    80004152:	ec4e                	sd	s3,24(sp)
    80004154:	e852                	sd	s4,16(sp)
    80004156:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004158:	0001fa97          	auipc	s5,0x1f
    8000415c:	8b8a8a93          	addi	s5,s5,-1864 # 80022a10 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80004160:	0001fa17          	auipc	s4,0x1f
    80004164:	880a0a13          	addi	s4,s4,-1920 # 800229e0 <log>
    80004168:	018a2583          	lw	a1,24(s4)
    8000416c:	012585bb          	addw	a1,a1,s2
    80004170:	2585                	addiw	a1,a1,1
    80004172:	024a2503          	lw	a0,36(s4)
    80004176:	da3fe0ef          	jal	80002f18 <bread>
    8000417a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000417c:	000aa583          	lw	a1,0(s5)
    80004180:	024a2503          	lw	a0,36(s4)
    80004184:	d95fe0ef          	jal	80002f18 <bread>
    80004188:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000418a:	40000613          	li	a2,1024
    8000418e:	05850593          	addi	a1,a0,88
    80004192:	05848513          	addi	a0,s1,88
    80004196:	bb3fc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    8000419a:	8526                	mv	a0,s1
    8000419c:	e53fe0ef          	jal	80002fee <bwrite>
    brelse(from);
    800041a0:	854e                	mv	a0,s3
    800041a2:	e7ffe0ef          	jal	80003020 <brelse>
    brelse(to);
    800041a6:	8526                	mv	a0,s1
    800041a8:	e79fe0ef          	jal	80003020 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041ac:	2905                	addiw	s2,s2,1
    800041ae:	0a91                	addi	s5,s5,4
    800041b0:	02ca2783          	lw	a5,44(s4)
    800041b4:	faf94ae3          	blt	s2,a5,80004168 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    800041b8:	cc5ff0ef          	jal	80003e7c <write_head>
    install_trans(0); // Now install writes to home locations
    800041bc:	4501                	li	a0,0
    800041be:	d1dff0ef          	jal	80003eda <install_trans>
    log.lh.n = 0;
    800041c2:	0001f797          	auipc	a5,0x1f
    800041c6:	8407a523          	sw	zero,-1974(a5) # 80022a0c <log+0x2c>
    write_head(); // Erase the transaction from the log
    800041ca:	cb3ff0ef          	jal	80003e7c <write_head>
    800041ce:	69e2                	ld	s3,24(sp)
    800041d0:	6a42                	ld	s4,16(sp)
    800041d2:	6aa2                	ld	s5,8(sp)
    800041d4:	b70d                	j	800040f6 <end_op+0x42>

00000000800041d6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800041d6:	1101                	addi	sp,sp,-32
    800041d8:	ec06                	sd	ra,24(sp)
    800041da:	e822                	sd	s0,16(sp)
    800041dc:	e426                	sd	s1,8(sp)
    800041de:	1000                	addi	s0,sp,32
    800041e0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800041e2:	0001e517          	auipc	a0,0x1e
    800041e6:	7fe50513          	addi	a0,a0,2046 # 800229e0 <log>
    800041ea:	a3ffc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800041ee:	0001f617          	auipc	a2,0x1f
    800041f2:	81e62603          	lw	a2,-2018(a2) # 80022a0c <log+0x2c>
    800041f6:	47f5                	li	a5,29
    800041f8:	04c7cd63          	blt	a5,a2,80004252 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800041fc:	0001f797          	auipc	a5,0x1f
    80004200:	8007a783          	lw	a5,-2048(a5) # 800229fc <log+0x1c>
    80004204:	04f05d63          	blez	a5,8000425e <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004208:	4781                	li	a5,0
    8000420a:	06c05063          	blez	a2,8000426a <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    8000420e:	44cc                	lw	a1,12(s1)
    80004210:	0001f717          	auipc	a4,0x1f
    80004214:	80070713          	addi	a4,a4,-2048 # 80022a10 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004218:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    8000421a:	4314                	lw	a3,0(a4)
    8000421c:	04b68763          	beq	a3,a1,8000426a <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80004220:	2785                	addiw	a5,a5,1
    80004222:	0711                	addi	a4,a4,4
    80004224:	fef61be3          	bne	a2,a5,8000421a <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004228:	060a                	slli	a2,a2,0x2
    8000422a:	02060613          	addi	a2,a2,32
    8000422e:	0001e797          	auipc	a5,0x1e
    80004232:	7b278793          	addi	a5,a5,1970 # 800229e0 <log>
    80004236:	97b2                	add	a5,a5,a2
    80004238:	44d8                	lw	a4,12(s1)
    8000423a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    8000423c:	8526                	mv	a0,s1
    8000423e:	e67fe0ef          	jal	800030a4 <bpin>
    log.lh.n++;
    80004242:	0001e717          	auipc	a4,0x1e
    80004246:	79e70713          	addi	a4,a4,1950 # 800229e0 <log>
    8000424a:	575c                	lw	a5,44(a4)
    8000424c:	2785                	addiw	a5,a5,1
    8000424e:	d75c                	sw	a5,44(a4)
    80004250:	a815                	j	80004284 <log_write+0xae>
    panic("too big a transaction");
    80004252:	00003517          	auipc	a0,0x3
    80004256:	2ee50513          	addi	a0,a0,750 # 80007540 <etext+0x540>
    8000425a:	ddafc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    8000425e:	00003517          	auipc	a0,0x3
    80004262:	2fa50513          	addi	a0,a0,762 # 80007558 <etext+0x558>
    80004266:	dcefc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    8000426a:	00279693          	slli	a3,a5,0x2
    8000426e:	02068693          	addi	a3,a3,32
    80004272:	0001e717          	auipc	a4,0x1e
    80004276:	76e70713          	addi	a4,a4,1902 # 800229e0 <log>
    8000427a:	9736                	add	a4,a4,a3
    8000427c:	44d4                	lw	a3,12(s1)
    8000427e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80004280:	faf60ee3          	beq	a2,a5,8000423c <log_write+0x66>
  }
  release(&log.lock);
    80004284:	0001e517          	auipc	a0,0x1e
    80004288:	75c50513          	addi	a0,a0,1884 # 800229e0 <log>
    8000428c:	a25fc0ef          	jal	80000cb0 <release>
}
    80004290:	60e2                	ld	ra,24(sp)
    80004292:	6442                	ld	s0,16(sp)
    80004294:	64a2                	ld	s1,8(sp)
    80004296:	6105                	addi	sp,sp,32
    80004298:	8082                	ret

000000008000429a <sys_sync>:

uint64
sys_sync(void)
{
    8000429a:	1101                	addi	sp,sp,-32
    8000429c:	ec06                	sd	ra,24(sp)
    8000429e:	e822                	sd	s0,16(sp)
    800042a0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042a2:	0001e517          	auipc	a0,0x1e
    800042a6:	73e50513          	addi	a0,a0,1854 # 800229e0 <log>
    800042aa:	97ffc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    800042ae:	0001e797          	auipc	a5,0x1e
    800042b2:	7527a783          	lw	a5,1874(a5) # 80022a00 <log+0x20>
    800042b6:	e799                	bnez	a5,800042c4 <sys_sync+0x2a>
    800042b8:	0001e797          	auipc	a5,0x1e
    800042bc:	7447a783          	lw	a5,1860(a5) # 800229fc <log+0x1c>
    800042c0:	02f05c63          	blez	a5,800042f8 <sys_sync+0x5e>
    800042c4:	e426                	sd	s1,8(sp)
    800042c6:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    800042c8:	0001e917          	auipc	s2,0x1e
    800042cc:	74092903          	lw	s2,1856(s2) # 80022a08 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    800042d0:	0001e497          	auipc	s1,0x1e
    800042d4:	71048493          	addi	s1,s1,1808 # 800229e0 <log>
    800042d8:	8526                	mv	a0,s1
    800042da:	cdffd0ef          	jal	80001fb8 <sleep_prepare>
      release(&log.lock);
    800042de:	8526                	mv	a0,s1
    800042e0:	9d1fc0ef          	jal	80000cb0 <release>
      sleep();
    800042e4:	d11fd0ef          	jal	80001ff4 <sleep>
      acquire(&log.lock);
    800042e8:	8526                	mv	a0,s1
    800042ea:	93ffc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    800042ee:	549c                	lw	a5,40(s1)
    800042f0:	fef954e3          	bge	s2,a5,800042d8 <sys_sync+0x3e>
    800042f4:	64a2                	ld	s1,8(sp)
    800042f6:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    800042f8:	0001e517          	auipc	a0,0x1e
    800042fc:	6e850513          	addi	a0,a0,1768 # 800229e0 <log>
    80004300:	9b1fc0ef          	jal	80000cb0 <release>
  return 0;
}
    80004304:	4501                	li	a0,0
    80004306:	60e2                	ld	ra,24(sp)
    80004308:	6442                	ld	s0,16(sp)
    8000430a:	6105                	addi	sp,sp,32
    8000430c:	8082                	ret

000000008000430e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000430e:	1101                	addi	sp,sp,-32
    80004310:	ec06                	sd	ra,24(sp)
    80004312:	e822                	sd	s0,16(sp)
    80004314:	e426                	sd	s1,8(sp)
    80004316:	e04a                	sd	s2,0(sp)
    80004318:	1000                	addi	s0,sp,32
    8000431a:	84aa                	mv	s1,a0
    8000431c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000431e:	00003597          	auipc	a1,0x3
    80004322:	25a58593          	addi	a1,a1,602 # 80007578 <etext+0x578>
    80004326:	0521                	addi	a0,a0,8
    80004328:	881fc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    8000432c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004330:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004334:	0204a423          	sw	zero,40(s1)
}
    80004338:	60e2                	ld	ra,24(sp)
    8000433a:	6442                	ld	s0,16(sp)
    8000433c:	64a2                	ld	s1,8(sp)
    8000433e:	6902                	ld	s2,0(sp)
    80004340:	6105                	addi	sp,sp,32
    80004342:	8082                	ret

0000000080004344 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004344:	1101                	addi	sp,sp,-32
    80004346:	ec06                	sd	ra,24(sp)
    80004348:	e822                	sd	s0,16(sp)
    8000434a:	e426                	sd	s1,8(sp)
    8000434c:	e04a                	sd	s2,0(sp)
    8000434e:	1000                	addi	s0,sp,32
    80004350:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004352:	00850913          	addi	s2,a0,8
    80004356:	854a                	mv	a0,s2
    80004358:	8d1fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    8000435c:	409c                	lw	a5,0(s1)
    8000435e:	cf91                	beqz	a5,8000437a <acquiresleep+0x36>
    sleep_prepare(lk);
    80004360:	8526                	mv	a0,s1
    80004362:	c57fd0ef          	jal	80001fb8 <sleep_prepare>
    release(&lk->lk);
    80004366:	854a                	mv	a0,s2
    80004368:	949fc0ef          	jal	80000cb0 <release>
    sleep();
    8000436c:	c89fd0ef          	jal	80001ff4 <sleep>
    acquire(&lk->lk);
    80004370:	854a                	mv	a0,s2
    80004372:	8b7fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004376:	409c                	lw	a5,0(s1)
    80004378:	f7e5                	bnez	a5,80004360 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000437a:	4785                	li	a5,1
    8000437c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000437e:	dd2fd0ef          	jal	80001950 <myproc>
    80004382:	591c                	lw	a5,48(a0)
    80004384:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004386:	854a                	mv	a0,s2
    80004388:	929fc0ef          	jal	80000cb0 <release>
}
    8000438c:	60e2                	ld	ra,24(sp)
    8000438e:	6442                	ld	s0,16(sp)
    80004390:	64a2                	ld	s1,8(sp)
    80004392:	6902                	ld	s2,0(sp)
    80004394:	6105                	addi	sp,sp,32
    80004396:	8082                	ret

0000000080004398 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004398:	1101                	addi	sp,sp,-32
    8000439a:	ec06                	sd	ra,24(sp)
    8000439c:	e822                	sd	s0,16(sp)
    8000439e:	e426                	sd	s1,8(sp)
    800043a0:	e04a                	sd	s2,0(sp)
    800043a2:	1000                	addi	s0,sp,32
    800043a4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043a6:	00850913          	addi	s2,a0,8
    800043aa:	854a                	mv	a0,s2
    800043ac:	87dfc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    800043b0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043b4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800043b8:	8526                	mv	a0,s1
    800043ba:	c6bfd0ef          	jal	80002024 <wakeup>
  release(&lk->lk);
    800043be:	854a                	mv	a0,s2
    800043c0:	8f1fc0ef          	jal	80000cb0 <release>
}
    800043c4:	60e2                	ld	ra,24(sp)
    800043c6:	6442                	ld	s0,16(sp)
    800043c8:	64a2                	ld	s1,8(sp)
    800043ca:	6902                	ld	s2,0(sp)
    800043cc:	6105                	addi	sp,sp,32
    800043ce:	8082                	ret

00000000800043d0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800043d0:	7179                	addi	sp,sp,-48
    800043d2:	f406                	sd	ra,40(sp)
    800043d4:	f022                	sd	s0,32(sp)
    800043d6:	ec26                	sd	s1,24(sp)
    800043d8:	e84a                	sd	s2,16(sp)
    800043da:	1800                	addi	s0,sp,48
    800043dc:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800043de:	00850913          	addi	s2,a0,8
    800043e2:	854a                	mv	a0,s2
    800043e4:	845fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800043e8:	409c                	lw	a5,0(s1)
    800043ea:	ef81                	bnez	a5,80004402 <holdingsleep+0x32>
    800043ec:	4481                	li	s1,0
  release(&lk->lk);
    800043ee:	854a                	mv	a0,s2
    800043f0:	8c1fc0ef          	jal	80000cb0 <release>
  return r;
}
    800043f4:	8526                	mv	a0,s1
    800043f6:	70a2                	ld	ra,40(sp)
    800043f8:	7402                	ld	s0,32(sp)
    800043fa:	64e2                	ld	s1,24(sp)
    800043fc:	6942                	ld	s2,16(sp)
    800043fe:	6145                	addi	sp,sp,48
    80004400:	8082                	ret
    80004402:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004404:	0284a983          	lw	s3,40(s1)
    80004408:	d48fd0ef          	jal	80001950 <myproc>
    8000440c:	5904                	lw	s1,48(a0)
    8000440e:	413484b3          	sub	s1,s1,s3
    80004412:	0014b493          	seqz	s1,s1
    80004416:	69a2                	ld	s3,8(sp)
    80004418:	bfd9                	j	800043ee <holdingsleep+0x1e>

000000008000441a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000441a:	1141                	addi	sp,sp,-16
    8000441c:	e406                	sd	ra,8(sp)
    8000441e:	e022                	sd	s0,0(sp)
    80004420:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004422:	00003597          	auipc	a1,0x3
    80004426:	16658593          	addi	a1,a1,358 # 80007588 <etext+0x588>
    8000442a:	0001e517          	auipc	a0,0x1e
    8000442e:	6fe50513          	addi	a0,a0,1790 # 80022b28 <ftable>
    80004432:	f76fc0ef          	jal	80000ba8 <initlock>
}
    80004436:	60a2                	ld	ra,8(sp)
    80004438:	6402                	ld	s0,0(sp)
    8000443a:	0141                	addi	sp,sp,16
    8000443c:	8082                	ret

000000008000443e <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    8000443e:	1101                	addi	sp,sp,-32
    80004440:	ec06                	sd	ra,24(sp)
    80004442:	e822                	sd	s0,16(sp)
    80004444:	e426                	sd	s1,8(sp)
    80004446:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004448:	0001e517          	auipc	a0,0x1e
    8000444c:	6e050513          	addi	a0,a0,1760 # 80022b28 <ftable>
    80004450:	fd8fc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004454:	0001e497          	auipc	s1,0x1e
    80004458:	6ec48493          	addi	s1,s1,1772 # 80022b40 <ftable+0x18>
    8000445c:	0001f717          	auipc	a4,0x1f
    80004460:	68470713          	addi	a4,a4,1668 # 80023ae0 <disk>
    if (f->ref == 0) {
    80004464:	40dc                	lw	a5,4(s1)
    80004466:	cf89                	beqz	a5,80004480 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004468:	02848493          	addi	s1,s1,40
    8000446c:	fee49ce3          	bne	s1,a4,80004464 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004470:	0001e517          	auipc	a0,0x1e
    80004474:	6b850513          	addi	a0,a0,1720 # 80022b28 <ftable>
    80004478:	839fc0ef          	jal	80000cb0 <release>
  return 0;
    8000447c:	4481                	li	s1,0
    8000447e:	a809                	j	80004490 <filealloc+0x52>
      f->ref = 1;
    80004480:	4785                	li	a5,1
    80004482:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004484:	0001e517          	auipc	a0,0x1e
    80004488:	6a450513          	addi	a0,a0,1700 # 80022b28 <ftable>
    8000448c:	825fc0ef          	jal	80000cb0 <release>
}
    80004490:	8526                	mv	a0,s1
    80004492:	60e2                	ld	ra,24(sp)
    80004494:	6442                	ld	s0,16(sp)
    80004496:	64a2                	ld	s1,8(sp)
    80004498:	6105                	addi	sp,sp,32
    8000449a:	8082                	ret

000000008000449c <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    8000449c:	1101                	addi	sp,sp,-32
    8000449e:	ec06                	sd	ra,24(sp)
    800044a0:	e822                	sd	s0,16(sp)
    800044a2:	e426                	sd	s1,8(sp)
    800044a4:	1000                	addi	s0,sp,32
    800044a6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800044a8:	0001e517          	auipc	a0,0x1e
    800044ac:	68050513          	addi	a0,a0,1664 # 80022b28 <ftable>
    800044b0:	f78fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800044b4:	40dc                	lw	a5,4(s1)
    800044b6:	02f05063          	blez	a5,800044d6 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800044ba:	2785                	addiw	a5,a5,1
    800044bc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800044be:	0001e517          	auipc	a0,0x1e
    800044c2:	66a50513          	addi	a0,a0,1642 # 80022b28 <ftable>
    800044c6:	feafc0ef          	jal	80000cb0 <release>
  return f;
}
    800044ca:	8526                	mv	a0,s1
    800044cc:	60e2                	ld	ra,24(sp)
    800044ce:	6442                	ld	s0,16(sp)
    800044d0:	64a2                	ld	s1,8(sp)
    800044d2:	6105                	addi	sp,sp,32
    800044d4:	8082                	ret
    panic("filedup");
    800044d6:	00003517          	auipc	a0,0x3
    800044da:	0ba50513          	addi	a0,a0,186 # 80007590 <etext+0x590>
    800044de:	b56fc0ef          	jal	80000834 <panic>

00000000800044e2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044e2:	7139                	addi	sp,sp,-64
    800044e4:	fc06                	sd	ra,56(sp)
    800044e6:	f822                	sd	s0,48(sp)
    800044e8:	f426                	sd	s1,40(sp)
    800044ea:	0080                	addi	s0,sp,64
    800044ec:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044ee:	0001e517          	auipc	a0,0x1e
    800044f2:	63a50513          	addi	a0,a0,1594 # 80022b28 <ftable>
    800044f6:	f32fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800044fa:	40dc                	lw	a5,4(s1)
    800044fc:	04f05a63          	blez	a5,80004550 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    80004500:	37fd                	addiw	a5,a5,-1
    80004502:	c0dc                	sw	a5,4(s1)
    80004504:	06f04063          	bgtz	a5,80004564 <fileclose+0x82>
    80004508:	f04a                	sd	s2,32(sp)
    8000450a:	ec4e                	sd	s3,24(sp)
    8000450c:	e852                	sd	s4,16(sp)
    8000450e:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004510:	0004a903          	lw	s2,0(s1)
    80004514:	0094c783          	lbu	a5,9(s1)
    80004518:	89be                	mv	s3,a5
    8000451a:	689c                	ld	a5,16(s1)
    8000451c:	8a3e                	mv	s4,a5
    8000451e:	6c9c                	ld	a5,24(s1)
    80004520:	8abe                	mv	s5,a5
  f->ref = 0;
    80004522:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004526:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000452a:	0001e517          	auipc	a0,0x1e
    8000452e:	5fe50513          	addi	a0,a0,1534 # 80022b28 <ftable>
    80004532:	f7efc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    80004536:	4785                	li	a5,1
    80004538:	04f90163          	beq	s2,a5,8000457a <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    8000453c:	ffe9079b          	addiw	a5,s2,-2
    80004540:	4705                	li	a4,1
    80004542:	04f77563          	bgeu	a4,a5,8000458c <fileclose+0xaa>
    80004546:	7902                	ld	s2,32(sp)
    80004548:	69e2                	ld	s3,24(sp)
    8000454a:	6a42                	ld	s4,16(sp)
    8000454c:	6aa2                	ld	s5,8(sp)
    8000454e:	a00d                	j	80004570 <fileclose+0x8e>
    80004550:	f04a                	sd	s2,32(sp)
    80004552:	ec4e                	sd	s3,24(sp)
    80004554:	e852                	sd	s4,16(sp)
    80004556:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004558:	00003517          	auipc	a0,0x3
    8000455c:	04050513          	addi	a0,a0,64 # 80007598 <etext+0x598>
    80004560:	ad4fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    80004564:	0001e517          	auipc	a0,0x1e
    80004568:	5c450513          	addi	a0,a0,1476 # 80022b28 <ftable>
    8000456c:	f44fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004570:	70e2                	ld	ra,56(sp)
    80004572:	7442                	ld	s0,48(sp)
    80004574:	74a2                	ld	s1,40(sp)
    80004576:	6121                	addi	sp,sp,64
    80004578:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000457a:	85ce                	mv	a1,s3
    8000457c:	8552                	mv	a0,s4
    8000457e:	36a000ef          	jal	800048e8 <pipeclose>
    80004582:	7902                	ld	s2,32(sp)
    80004584:	69e2                	ld	s3,24(sp)
    80004586:	6a42                	ld	s4,16(sp)
    80004588:	6aa2                	ld	s5,8(sp)
    8000458a:	b7dd                	j	80004570 <fileclose+0x8e>
    begin_op();
    8000458c:	a9dff0ef          	jal	80004028 <begin_op>
    iput(ff.ip);
    80004590:	8556                	mv	a0,s5
    80004592:	9a0ff0ef          	jal	80003732 <iput>
    end_op();
    80004596:	b1fff0ef          	jal	800040b4 <end_op>
    8000459a:	7902                	ld	s2,32(sp)
    8000459c:	69e2                	ld	s3,24(sp)
    8000459e:	6a42                	ld	s4,16(sp)
    800045a0:	6aa2                	ld	s5,8(sp)
    800045a2:	b7f9                	j	80004570 <fileclose+0x8e>

00000000800045a4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800045a4:	715d                	addi	sp,sp,-80
    800045a6:	e486                	sd	ra,72(sp)
    800045a8:	e0a2                	sd	s0,64(sp)
    800045aa:	fc26                	sd	s1,56(sp)
    800045ac:	f052                	sd	s4,32(sp)
    800045ae:	0880                	addi	s0,sp,80
    800045b0:	84aa                	mv	s1,a0
    800045b2:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800045b4:	b9cfd0ef          	jal	80001950 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    800045b8:	409c                	lw	a5,0(s1)
    800045ba:	37f9                	addiw	a5,a5,-2
    800045bc:	4705                	li	a4,1
    800045be:	04f76963          	bltu	a4,a5,80004610 <filestat+0x6c>
    800045c2:	f84a                	sd	s2,48(sp)
    800045c4:	f44e                	sd	s3,40(sp)
    800045c6:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    800045c8:	fb840993          	addi	s3,s0,-72
    800045cc:	4661                	li	a2,24
    800045ce:	4581                	li	a1,0
    800045d0:	854e                	mv	a0,s3
    800045d2:	f16fc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    800045d6:	6c88                	ld	a0,24(s1)
    800045d8:	fd9fe0ef          	jal	800035b0 <ilock>
    stati(f->ip, &st);
    800045dc:	85ce                	mv	a1,s3
    800045de:	6c88                	ld	a0,24(s1)
    800045e0:	b7cff0ef          	jal	8000395c <stati>
    iunlock(f->ip);
    800045e4:	6c88                	ld	a0,24(s1)
    800045e6:	878ff0ef          	jal	8000365e <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    800045ea:	4761                	li	a4,24
    800045ec:	86ce                	mv	a3,s3
    800045ee:	8652                	mv	a2,s4
    800045f0:	04893583          	ld	a1,72(s2)
    800045f4:	05093503          	ld	a0,80(s2)
    800045f8:	f93fc0ef          	jal	8000158a <copyout>
    800045fc:	41f5551b          	sraiw	a0,a0,0x1f
    80004600:	7942                	ld	s2,48(sp)
    80004602:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004604:	60a6                	ld	ra,72(sp)
    80004606:	6406                	ld	s0,64(sp)
    80004608:	74e2                	ld	s1,56(sp)
    8000460a:	7a02                	ld	s4,32(sp)
    8000460c:	6161                	addi	sp,sp,80
    8000460e:	8082                	ret
  return -1;
    80004610:	557d                	li	a0,-1
    80004612:	bfcd                	j	80004604 <filestat+0x60>

0000000080004614 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004614:	7179                	addi	sp,sp,-48
    80004616:	f406                	sd	ra,40(sp)
    80004618:	f022                	sd	s0,32(sp)
    8000461a:	e84a                	sd	s2,16(sp)
    8000461c:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    8000461e:	00854783          	lbu	a5,8(a0)
    80004622:	c3dd                	beqz	a5,800046c8 <fileread+0xb4>
    80004624:	ec26                	sd	s1,24(sp)
    80004626:	e44e                	sd	s3,8(sp)
    80004628:	84aa                	mv	s1,a0
    8000462a:	892e                	mv	s2,a1
    8000462c:	89b2                	mv	s3,a2
    8000462e:	01f6579b          	srliw	a5,a2,0x1f
    80004632:	ebc9                	bnez	a5,800046c4 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    80004634:	411c                	lw	a5,0(a0)
    80004636:	4705                	li	a4,1
    80004638:	04e78363          	beq	a5,a4,8000467e <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000463c:	470d                	li	a4,3
    8000463e:	04e78763          	beq	a5,a4,8000468c <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004642:	4709                	li	a4,2
    80004644:	06e79a63          	bne	a5,a4,800046b8 <fileread+0xa4>
    ilock(f->ip);
    80004648:	6d08                	ld	a0,24(a0)
    8000464a:	f67fe0ef          	jal	800035b0 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000464e:	874e                	mv	a4,s3
    80004650:	5094                	lw	a3,32(s1)
    80004652:	864a                	mv	a2,s2
    80004654:	4585                	li	a1,1
    80004656:	6c88                	ld	a0,24(s1)
    80004658:	b32ff0ef          	jal	8000398a <readi>
    8000465c:	892a                	mv	s2,a0
    8000465e:	00a05563          	blez	a0,80004668 <fileread+0x54>
      f->off += r;
    80004662:	509c                	lw	a5,32(s1)
    80004664:	9fa9                	addw	a5,a5,a0
    80004666:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004668:	6c88                	ld	a0,24(s1)
    8000466a:	ff5fe0ef          	jal	8000365e <iunlock>
    8000466e:	64e2                	ld	s1,24(sp)
    80004670:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004672:	854a                	mv	a0,s2
    80004674:	70a2                	ld	ra,40(sp)
    80004676:	7402                	ld	s0,32(sp)
    80004678:	6942                	ld	s2,16(sp)
    8000467a:	6145                	addi	sp,sp,48
    8000467c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000467e:	6908                	ld	a0,16(a0)
    80004680:	3e2000ef          	jal	80004a62 <piperead>
    80004684:	892a                	mv	s2,a0
    80004686:	64e2                	ld	s1,24(sp)
    80004688:	69a2                	ld	s3,8(sp)
    8000468a:	b7e5                	j	80004672 <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000468c:	02451783          	lh	a5,36(a0)
    80004690:	03079693          	slli	a3,a5,0x30
    80004694:	92c1                	srli	a3,a3,0x30
    80004696:	4725                	li	a4,9
    80004698:	02d76b63          	bltu	a4,a3,800046ce <fileread+0xba>
    8000469c:	0792                	slli	a5,a5,0x4
    8000469e:	0001e717          	auipc	a4,0x1e
    800046a2:	3ea70713          	addi	a4,a4,1002 # 80022a88 <devsw>
    800046a6:	97ba                	add	a5,a5,a4
    800046a8:	639c                	ld	a5,0(a5)
    800046aa:	c79d                	beqz	a5,800046d8 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    800046ac:	4505                	li	a0,1
    800046ae:	9782                	jalr	a5
    800046b0:	892a                	mv	s2,a0
    800046b2:	64e2                	ld	s1,24(sp)
    800046b4:	69a2                	ld	s3,8(sp)
    800046b6:	bf75                	j	80004672 <fileread+0x5e>
    panic("fileread");
    800046b8:	00003517          	auipc	a0,0x3
    800046bc:	ef050513          	addi	a0,a0,-272 # 800075a8 <etext+0x5a8>
    800046c0:	974fc0ef          	jal	80000834 <panic>
    800046c4:	64e2                	ld	s1,24(sp)
    800046c6:	69a2                	ld	s3,8(sp)
    return -1;
    800046c8:	57fd                	li	a5,-1
    800046ca:	893e                	mv	s2,a5
    800046cc:	b75d                	j	80004672 <fileread+0x5e>
      return -1;
    800046ce:	57fd                	li	a5,-1
    800046d0:	893e                	mv	s2,a5
    800046d2:	64e2                	ld	s1,24(sp)
    800046d4:	69a2                	ld	s3,8(sp)
    800046d6:	bf71                	j	80004672 <fileread+0x5e>
    800046d8:	57fd                	li	a5,-1
    800046da:	893e                	mv	s2,a5
    800046dc:	64e2                	ld	s1,24(sp)
    800046de:	69a2                	ld	s3,8(sp)
    800046e0:	bf49                	j	80004672 <fileread+0x5e>

00000000800046e2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    800046e2:	00954783          	lbu	a5,9(a0)
    800046e6:	12078b63          	beqz	a5,8000481c <filewrite+0x13a>
{
    800046ea:	711d                	addi	sp,sp,-96
    800046ec:	ec86                	sd	ra,88(sp)
    800046ee:	e8a2                	sd	s0,80(sp)
    800046f0:	e0ca                	sd	s2,64(sp)
    800046f2:	f456                	sd	s5,40(sp)
    800046f4:	f05a                	sd	s6,32(sp)
    800046f6:	1080                	addi	s0,sp,96
    800046f8:	892a                	mv	s2,a0
    800046fa:	8b2e                	mv	s6,a1
    800046fc:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    800046fe:	01f6579b          	srliw	a5,a2,0x1f
    80004702:	0e079d63          	bnez	a5,800047fc <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    80004706:	411c                	lw	a5,0(a0)
    80004708:	4705                	li	a4,1
    8000470a:	02e78a63          	beq	a5,a4,8000473e <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000470e:	470d                	li	a4,3
    80004710:	02e78b63          	beq	a5,a4,80004746 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004714:	4709                	li	a4,2
    80004716:	0ce79763          	bne	a5,a4,800047e4 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    8000471a:	0ec05763          	blez	a2,80004808 <filewrite+0x126>
    8000471e:	e4a6                	sd	s1,72(sp)
    80004720:	fc4e                	sd	s3,56(sp)
    80004722:	f852                	sd	s4,48(sp)
    80004724:	ec5e                	sd	s7,24(sp)
    80004726:	e862                	sd	s8,16(sp)
    80004728:	e466                	sd	s9,8(sp)
    int i = 0;
    8000472a:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    8000472c:	6b85                	lui	s7,0x1
    8000472e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004732:	6785                	lui	a5,0x1
    80004734:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004738:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000473a:	4c05                	li	s8,1
    8000473c:	a8ad                	j	800047b6 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    8000473e:	6908                	ld	a0,16(a0)
    80004740:	206000ef          	jal	80004946 <pipewrite>
    80004744:	a849                	j	800047d6 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004746:	02451783          	lh	a5,36(a0)
    8000474a:	03079693          	slli	a3,a5,0x30
    8000474e:	92c1                	srli	a3,a3,0x30
    80004750:	4725                	li	a4,9
    80004752:	0ad76763          	bltu	a4,a3,80004800 <filewrite+0x11e>
    80004756:	0792                	slli	a5,a5,0x4
    80004758:	0001e717          	auipc	a4,0x1e
    8000475c:	33070713          	addi	a4,a4,816 # 80022a88 <devsw>
    80004760:	97ba                	add	a5,a5,a4
    80004762:	679c                	ld	a5,8(a5)
    80004764:	c3c5                	beqz	a5,80004804 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004766:	4505                	li	a0,1
    80004768:	9782                	jalr	a5
    8000476a:	a0b5                	j	800047d6 <filewrite+0xf4>
      if (n1 > max)
    8000476c:	2981                	sext.w	s3,s3
      begin_op();
    8000476e:	8bbff0ef          	jal	80004028 <begin_op>
      ilock(f->ip);
    80004772:	01893503          	ld	a0,24(s2)
    80004776:	e3bfe0ef          	jal	800035b0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000477a:	874e                	mv	a4,s3
    8000477c:	02092683          	lw	a3,32(s2)
    80004780:	016a0633          	add	a2,s4,s6
    80004784:	85e2                	mv	a1,s8
    80004786:	01893503          	ld	a0,24(s2)
    8000478a:	af2ff0ef          	jal	80003a7c <writei>
    8000478e:	84aa                	mv	s1,a0
    80004790:	00a05763          	blez	a0,8000479e <filewrite+0xbc>
        f->off += r;
    80004794:	02092783          	lw	a5,32(s2)
    80004798:	9fa9                	addw	a5,a5,a0
    8000479a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000479e:	01893503          	ld	a0,24(s2)
    800047a2:	ebdfe0ef          	jal	8000365e <iunlock>
      end_op();
    800047a6:	90fff0ef          	jal	800040b4 <end_op>

      if (r != n1) {
    800047aa:	00999d63          	bne	s3,s1,800047c4 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    800047ae:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    800047b2:	015a5963          	bge	s4,s5,800047c4 <filewrite+0xe2>
      int n1 = n - i;
    800047b6:	414a87bb          	subw	a5,s5,s4
    800047ba:	89be                	mv	s3,a5
      if (n1 > max)
    800047bc:	fafbd8e3          	bge	s7,a5,8000476c <filewrite+0x8a>
    800047c0:	89e6                	mv	s3,s9
    800047c2:	b76d                	j	8000476c <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    800047c4:	054a9463          	bne	s5,s4,8000480c <filewrite+0x12a>
    800047c8:	8556                	mv	a0,s5
    800047ca:	64a6                	ld	s1,72(sp)
    800047cc:	79e2                	ld	s3,56(sp)
    800047ce:	7a42                	ld	s4,48(sp)
    800047d0:	6be2                	ld	s7,24(sp)
    800047d2:	6c42                	ld	s8,16(sp)
    800047d4:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800047d6:	60e6                	ld	ra,88(sp)
    800047d8:	6446                	ld	s0,80(sp)
    800047da:	6906                	ld	s2,64(sp)
    800047dc:	7aa2                	ld	s5,40(sp)
    800047de:	7b02                	ld	s6,32(sp)
    800047e0:	6125                	addi	sp,sp,96
    800047e2:	8082                	ret
    800047e4:	e4a6                	sd	s1,72(sp)
    800047e6:	fc4e                	sd	s3,56(sp)
    800047e8:	f852                	sd	s4,48(sp)
    800047ea:	ec5e                	sd	s7,24(sp)
    800047ec:	e862                	sd	s8,16(sp)
    800047ee:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800047f0:	00003517          	auipc	a0,0x3
    800047f4:	dc850513          	addi	a0,a0,-568 # 800075b8 <etext+0x5b8>
    800047f8:	83cfc0ef          	jal	80000834 <panic>
    return -1;
    800047fc:	557d                	li	a0,-1
    800047fe:	bfe1                	j	800047d6 <filewrite+0xf4>
      return -1;
    80004800:	557d                	li	a0,-1
    80004802:	bfd1                	j	800047d6 <filewrite+0xf4>
    80004804:	557d                	li	a0,-1
    80004806:	bfc1                	j	800047d6 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    80004808:	8532                	mv	a0,a2
    8000480a:	b7f1                	j	800047d6 <filewrite+0xf4>
    8000480c:	557d                	li	a0,-1
    8000480e:	64a6                	ld	s1,72(sp)
    80004810:	79e2                	ld	s3,56(sp)
    80004812:	7a42                	ld	s4,48(sp)
    80004814:	6be2                	ld	s7,24(sp)
    80004816:	6c42                	ld	s8,16(sp)
    80004818:	6ca2                	ld	s9,8(sp)
    8000481a:	bf75                	j	800047d6 <filewrite+0xf4>
    return -1;
    8000481c:	557d                	li	a0,-1
}
    8000481e:	8082                	ret

0000000080004820 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004820:	7179                	addi	sp,sp,-48
    80004822:	f406                	sd	ra,40(sp)
    80004824:	f022                	sd	s0,32(sp)
    80004826:	ec26                	sd	s1,24(sp)
    80004828:	e052                	sd	s4,0(sp)
    8000482a:	1800                	addi	s0,sp,48
    8000482c:	84aa                	mv	s1,a0
    8000482e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004830:	0005b023          	sd	zero,0(a1)
    80004834:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004838:	c07ff0ef          	jal	8000443e <filealloc>
    8000483c:	e088                	sd	a0,0(s1)
    8000483e:	c549                	beqz	a0,800048c8 <pipealloc+0xa8>
    80004840:	bffff0ef          	jal	8000443e <filealloc>
    80004844:	00aa3023          	sd	a0,0(s4)
    80004848:	cd25                	beqz	a0,800048c0 <pipealloc+0xa0>
    8000484a:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    8000484c:	b02fc0ef          	jal	80000b4e <kalloc>
    80004850:	892a                	mv	s2,a0
    80004852:	c12d                	beqz	a0,800048b4 <pipealloc+0x94>
    80004854:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004856:	4985                	li	s3,1
    80004858:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000485c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004860:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004864:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004868:	00003597          	auipc	a1,0x3
    8000486c:	d6058593          	addi	a1,a1,-672 # 800075c8 <etext+0x5c8>
    80004870:	b38fc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004874:	609c                	ld	a5,0(s1)
    80004876:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000487a:	609c                	ld	a5,0(s1)
    8000487c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004880:	609c                	ld	a5,0(s1)
    80004882:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004886:	609c                	ld	a5,0(s1)
    80004888:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000488c:	000a3783          	ld	a5,0(s4)
    80004890:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004894:	000a3783          	ld	a5,0(s4)
    80004898:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000489c:	000a3783          	ld	a5,0(s4)
    800048a0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800048a4:	000a3783          	ld	a5,0(s4)
    800048a8:	0127b823          	sd	s2,16(a5)
  return 0;
    800048ac:	4501                	li	a0,0
    800048ae:	6942                	ld	s2,16(sp)
    800048b0:	69a2                	ld	s3,8(sp)
    800048b2:	a01d                	j	800048d8 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    800048b4:	6088                	ld	a0,0(s1)
    800048b6:	c119                	beqz	a0,800048bc <pipealloc+0x9c>
    800048b8:	6942                	ld	s2,16(sp)
    800048ba:	a029                	j	800048c4 <pipealloc+0xa4>
    800048bc:	6942                	ld	s2,16(sp)
    800048be:	a029                	j	800048c8 <pipealloc+0xa8>
    800048c0:	6088                	ld	a0,0(s1)
    800048c2:	c10d                	beqz	a0,800048e4 <pipealloc+0xc4>
    fileclose(*f0);
    800048c4:	c1fff0ef          	jal	800044e2 <fileclose>
  if (*f1)
    800048c8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800048cc:	557d                	li	a0,-1
  if (*f1)
    800048ce:	c789                	beqz	a5,800048d8 <pipealloc+0xb8>
    fileclose(*f1);
    800048d0:	853e                	mv	a0,a5
    800048d2:	c11ff0ef          	jal	800044e2 <fileclose>
  return -1;
    800048d6:	557d                	li	a0,-1
}
    800048d8:	70a2                	ld	ra,40(sp)
    800048da:	7402                	ld	s0,32(sp)
    800048dc:	64e2                	ld	s1,24(sp)
    800048de:	6a02                	ld	s4,0(sp)
    800048e0:	6145                	addi	sp,sp,48
    800048e2:	8082                	ret
  return -1;
    800048e4:	557d                	li	a0,-1
    800048e6:	bfcd                	j	800048d8 <pipealloc+0xb8>

00000000800048e8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800048e8:	1101                	addi	sp,sp,-32
    800048ea:	ec06                	sd	ra,24(sp)
    800048ec:	e822                	sd	s0,16(sp)
    800048ee:	e426                	sd	s1,8(sp)
    800048f0:	e04a                	sd	s2,0(sp)
    800048f2:	1000                	addi	s0,sp,32
    800048f4:	84aa                	mv	s1,a0
    800048f6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800048f8:	b30fc0ef          	jal	80000c28 <acquire>
  if (writable) {
    800048fc:	02090763          	beqz	s2,8000492a <pipeclose+0x42>
    pi->writeopen = 0;
    80004900:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004904:	21848513          	addi	a0,s1,536
    80004908:	f1cfd0ef          	jal	80002024 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    8000490c:	2204a783          	lw	a5,544(s1)
    80004910:	e781                	bnez	a5,80004918 <pipeclose+0x30>
    80004912:	2244a783          	lw	a5,548(s1)
    80004916:	c38d                	beqz	a5,80004938 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    80004918:	8526                	mv	a0,s1
    8000491a:	b96fc0ef          	jal	80000cb0 <release>
}
    8000491e:	60e2                	ld	ra,24(sp)
    80004920:	6442                	ld	s0,16(sp)
    80004922:	64a2                	ld	s1,8(sp)
    80004924:	6902                	ld	s2,0(sp)
    80004926:	6105                	addi	sp,sp,32
    80004928:	8082                	ret
    pi->readopen = 0;
    8000492a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000492e:	21c48513          	addi	a0,s1,540
    80004932:	ef2fd0ef          	jal	80002024 <wakeup>
    80004936:	bfd9                	j	8000490c <pipeclose+0x24>
    release(&pi->lock);
    80004938:	8526                	mv	a0,s1
    8000493a:	b76fc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    8000493e:	8526                	mv	a0,s1
    80004940:	926fc0ef          	jal	80000a66 <kfree>
    80004944:	bfe9                	j	8000491e <pipeclose+0x36>

0000000080004946 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004946:	7159                	addi	sp,sp,-112
    80004948:	f486                	sd	ra,104(sp)
    8000494a:	f0a2                	sd	s0,96(sp)
    8000494c:	eca6                	sd	s1,88(sp)
    8000494e:	e8ca                	sd	s2,80(sp)
    80004950:	e4ce                	sd	s3,72(sp)
    80004952:	e0d2                	sd	s4,64(sp)
    80004954:	fc56                	sd	s5,56(sp)
    80004956:	1880                	addi	s0,sp,112
    80004958:	84aa                	mv	s1,a0
    8000495a:	8aae                	mv	s5,a1
    8000495c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000495e:	ff3fc0ef          	jal	80001950 <myproc>
    80004962:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004964:	8526                	mv	a0,s1
    80004966:	ac2fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    8000496a:	0f405a63          	blez	s4,80004a5e <pipewrite+0x118>
    8000496e:	f85a                	sd	s6,48(sp)
    80004970:	f45e                	sd	s7,40(sp)
    80004972:	f062                	sd	s8,32(sp)
    80004974:	ec66                	sd	s9,24(sp)
    80004976:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004978:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    8000497a:	f9f40c13          	addi	s8,s0,-97
    8000497e:	4b85                	li	s7,1
    80004980:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004982:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    80004986:	21c48c93          	addi	s9,s1,540
    8000498a:	a0a1                	j	800049d2 <pipewrite+0x8c>
      release(&pi->lock);
    8000498c:	8526                	mv	a0,s1
    8000498e:	b22fc0ef          	jal	80000cb0 <release>
      return -1;
    80004992:	597d                	li	s2,-1
    80004994:	7b42                	ld	s6,48(sp)
    80004996:	7ba2                	ld	s7,40(sp)
    80004998:	7c02                	ld	s8,32(sp)
    8000499a:	6ce2                	ld	s9,24(sp)
    8000499c:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000499e:	854a                	mv	a0,s2
    800049a0:	70a6                	ld	ra,104(sp)
    800049a2:	7406                	ld	s0,96(sp)
    800049a4:	64e6                	ld	s1,88(sp)
    800049a6:	6946                	ld	s2,80(sp)
    800049a8:	69a6                	ld	s3,72(sp)
    800049aa:	6a06                	ld	s4,64(sp)
    800049ac:	7ae2                	ld	s5,56(sp)
    800049ae:	6165                	addi	sp,sp,112
    800049b0:	8082                	ret
      wakeup(&pi->nread);
    800049b2:	856a                	mv	a0,s10
    800049b4:	e70fd0ef          	jal	80002024 <wakeup>
      sleep_prepare(&pi->nwrite);
    800049b8:	8566                	mv	a0,s9
    800049ba:	dfefd0ef          	jal	80001fb8 <sleep_prepare>
      release(&pi->lock);
    800049be:	8526                	mv	a0,s1
    800049c0:	af0fc0ef          	jal	80000cb0 <release>
      sleep();
    800049c4:	e30fd0ef          	jal	80001ff4 <sleep>
      acquire(&pi->lock);
    800049c8:	8526                	mv	a0,s1
    800049ca:	a5efc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    800049ce:	07495b63          	bge	s2,s4,80004a44 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    800049d2:	2204a783          	lw	a5,544(s1)
    800049d6:	dbdd                	beqz	a5,8000498c <pipewrite+0x46>
    800049d8:	854e                	mv	a0,s3
    800049da:	83dfd0ef          	jal	80002216 <killed>
    800049de:	f55d                	bnez	a0,8000498c <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    800049e0:	2184a783          	lw	a5,536(s1)
    800049e4:	21c4a703          	lw	a4,540(s1)
    800049e8:	2007879b          	addiw	a5,a5,512
    800049ec:	fcf703e3          	beq	a4,a5,800049b2 <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800049f0:	875e                	mv	a4,s7
    800049f2:	015906b3          	add	a3,s2,s5
    800049f6:	8662                	mv	a2,s8
    800049f8:	0489b583          	ld	a1,72(s3)
    800049fc:	0509b503          	ld	a0,80(s3)
    80004a00:	c51fc0ef          	jal	80001650 <copyin>
    80004a04:	03650163          	beq	a0,s6,80004a26 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a08:	21c4a783          	lw	a5,540(s1)
    80004a0c:	0017871b          	addiw	a4,a5,1
    80004a10:	20e4ae23          	sw	a4,540(s1)
    80004a14:	1ff7f793          	andi	a5,a5,511
    80004a18:	97a6                	add	a5,a5,s1
    80004a1a:	f9f44703          	lbu	a4,-97(s0)
    80004a1e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a22:	2905                	addiw	s2,s2,1
    80004a24:	b76d                	j	800049ce <pipewrite+0x88>
        if (i == 0)
    80004a26:	00090863          	beqz	s2,80004a36 <pipewrite+0xf0>
    80004a2a:	7b42                	ld	s6,48(sp)
    80004a2c:	7ba2                	ld	s7,40(sp)
    80004a2e:	7c02                	ld	s8,32(sp)
    80004a30:	6ce2                	ld	s9,24(sp)
    80004a32:	6d42                	ld	s10,16(sp)
    80004a34:	a829                	j	80004a4e <pipewrite+0x108>
          i = -1;
    80004a36:	892a                	mv	s2,a0
        break;
    80004a38:	7b42                	ld	s6,48(sp)
    80004a3a:	7ba2                	ld	s7,40(sp)
    80004a3c:	7c02                	ld	s8,32(sp)
    80004a3e:	6ce2                	ld	s9,24(sp)
    80004a40:	6d42                	ld	s10,16(sp)
    80004a42:	a031                	j	80004a4e <pipewrite+0x108>
    80004a44:	7b42                	ld	s6,48(sp)
    80004a46:	7ba2                	ld	s7,40(sp)
    80004a48:	7c02                	ld	s8,32(sp)
    80004a4a:	6ce2                	ld	s9,24(sp)
    80004a4c:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004a4e:	21848513          	addi	a0,s1,536
    80004a52:	dd2fd0ef          	jal	80002024 <wakeup>
  release(&pi->lock);
    80004a56:	8526                	mv	a0,s1
    80004a58:	a58fc0ef          	jal	80000cb0 <release>
  return i;
    80004a5c:	b789                	j	8000499e <pipewrite+0x58>
  int i = 0;
    80004a5e:	4901                	li	s2,0
    80004a60:	b7fd                	j	80004a4e <pipewrite+0x108>

0000000080004a62 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a62:	711d                	addi	sp,sp,-96
    80004a64:	ec86                	sd	ra,88(sp)
    80004a66:	e8a2                	sd	s0,80(sp)
    80004a68:	e4a6                	sd	s1,72(sp)
    80004a6a:	e0ca                	sd	s2,64(sp)
    80004a6c:	fc4e                	sd	s3,56(sp)
    80004a6e:	f852                	sd	s4,48(sp)
    80004a70:	f456                	sd	s5,40(sp)
    80004a72:	1080                	addi	s0,sp,96
    80004a74:	84aa                	mv	s1,a0
    80004a76:	89ae                	mv	s3,a1
    80004a78:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a7a:	ed7fc0ef          	jal	80001950 <myproc>
    80004a7e:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    80004a80:	8526                	mv	a0,s1
    80004a82:	9a6fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004a86:	0d505263          	blez	s5,80004b4a <piperead+0xe8>
    80004a8a:	2184a703          	lw	a4,536(s1)
    80004a8e:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004a92:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004a96:	02f71e63          	bne	a4,a5,80004ad2 <piperead+0x70>
    80004a9a:	2244a783          	lw	a5,548(s1)
    80004a9e:	c3b9                	beqz	a5,80004ae4 <piperead+0x82>
    if (killed(pr)) {
    80004aa0:	854a                	mv	a0,s2
    80004aa2:	f74fd0ef          	jal	80002216 <killed>
    80004aa6:	e915                	bnez	a0,80004ada <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004aa8:	8552                	mv	a0,s4
    80004aaa:	d0efd0ef          	jal	80001fb8 <sleep_prepare>
    release(&pi->lock);
    80004aae:	8526                	mv	a0,s1
    80004ab0:	a00fc0ef          	jal	80000cb0 <release>
    sleep();
    80004ab4:	d40fd0ef          	jal	80001ff4 <sleep>
    acquire(&pi->lock);
    80004ab8:	8526                	mv	a0,s1
    80004aba:	96efc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004abe:	2184a703          	lw	a4,536(s1)
    80004ac2:	21c4a783          	lw	a5,540(s1)
    80004ac6:	fcf70ae3          	beq	a4,a5,80004a9a <piperead+0x38>
    80004aca:	f05a                	sd	s6,32(sp)
    80004acc:	ec5e                	sd	s7,24(sp)
    80004ace:	e862                	sd	s8,16(sp)
    80004ad0:	a829                	j	80004aea <piperead+0x88>
    80004ad2:	f05a                	sd	s6,32(sp)
    80004ad4:	ec5e                	sd	s7,24(sp)
    80004ad6:	e862                	sd	s8,16(sp)
    80004ad8:	a809                	j	80004aea <piperead+0x88>
      release(&pi->lock);
    80004ada:	8526                	mv	a0,s1
    80004adc:	9d4fc0ef          	jal	80000cb0 <release>
      return -1;
    80004ae0:	5a7d                	li	s4,-1
    80004ae2:	a8a5                	j	80004b5a <piperead+0xf8>
    80004ae4:	f05a                	sd	s6,32(sp)
    80004ae6:	ec5e                	sd	s7,24(sp)
    80004ae8:	e862                	sd	s8,16(sp)
{
    80004aea:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004aec:	faf40c13          	addi	s8,s0,-81
    80004af0:	4b85                	li	s7,1
    80004af2:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    80004af4:	2184a783          	lw	a5,536(s1)
    80004af8:	21c4a703          	lw	a4,540(s1)
    80004afc:	06f70e63          	beq	a4,a5,80004b78 <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    80004b00:	1ff7f793          	andi	a5,a5,511
    80004b04:	97a6                	add	a5,a5,s1
    80004b06:	0187c783          	lbu	a5,24(a5)
    80004b0a:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004b0e:	875e                	mv	a4,s7
    80004b10:	86e2                	mv	a3,s8
    80004b12:	864e                	mv	a2,s3
    80004b14:	04893583          	ld	a1,72(s2)
    80004b18:	05093503          	ld	a0,80(s2)
    80004b1c:	a6ffc0ef          	jal	8000158a <copyout>
    80004b20:	01650f63          	beq	a0,s6,80004b3e <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004b24:	2184a783          	lw	a5,536(s1)
    80004b28:	2785                	addiw	a5,a5,1
    80004b2a:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004b2e:	2a05                	addiw	s4,s4,1
    80004b30:	0985                	addi	s3,s3,1
    80004b32:	fd4a91e3          	bne	s5,s4,80004af4 <piperead+0x92>
    80004b36:	7b02                	ld	s6,32(sp)
    80004b38:	6be2                	ld	s7,24(sp)
    80004b3a:	6c42                	ld	s8,16(sp)
    80004b3c:	a801                	j	80004b4c <piperead+0xea>
      if (i == 0)
    80004b3e:	020a0863          	beqz	s4,80004b6e <piperead+0x10c>
    80004b42:	7b02                	ld	s6,32(sp)
    80004b44:	6be2                	ld	s7,24(sp)
    80004b46:	6c42                	ld	s8,16(sp)
    80004b48:	a011                	j	80004b4c <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004b4a:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004b4c:	21c48513          	addi	a0,s1,540
    80004b50:	cd4fd0ef          	jal	80002024 <wakeup>
  release(&pi->lock);
    80004b54:	8526                	mv	a0,s1
    80004b56:	95afc0ef          	jal	80000cb0 <release>
  return i;
}
    80004b5a:	8552                	mv	a0,s4
    80004b5c:	60e6                	ld	ra,88(sp)
    80004b5e:	6446                	ld	s0,80(sp)
    80004b60:	64a6                	ld	s1,72(sp)
    80004b62:	6906                	ld	s2,64(sp)
    80004b64:	79e2                	ld	s3,56(sp)
    80004b66:	7a42                	ld	s4,48(sp)
    80004b68:	7aa2                	ld	s5,40(sp)
    80004b6a:	6125                	addi	sp,sp,96
    80004b6c:	8082                	ret
        i = -1;
    80004b6e:	8a2a                	mv	s4,a0
    80004b70:	7b02                	ld	s6,32(sp)
    80004b72:	6be2                	ld	s7,24(sp)
    80004b74:	6c42                	ld	s8,16(sp)
    80004b76:	bfd9                	j	80004b4c <piperead+0xea>
    80004b78:	7b02                	ld	s6,32(sp)
    80004b7a:	6be2                	ld	s7,24(sp)
    80004b7c:	6c42                	ld	s8,16(sp)
    80004b7e:	b7f9                	j	80004b4c <piperead+0xea>

0000000080004b80 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004b80:	1141                	addi	sp,sp,-16
    80004b82:	e406                	sd	ra,8(sp)
    80004b84:	e022                	sd	s0,0(sp)
    80004b86:	0800                	addi	s0,sp,16
    80004b88:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004b8a:	0035151b          	slliw	a0,a0,0x3
    80004b8e:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    80004b90:	8b89                	andi	a5,a5,2
    80004b92:	c399                	beqz	a5,80004b98 <flags2perm+0x18>
    perm |= PTE_W;
    80004b94:	00456513          	ori	a0,a0,4
  return perm;
}
    80004b98:	60a2                	ld	ra,8(sp)
    80004b9a:	6402                	ld	s0,0(sp)
    80004b9c:	0141                	addi	sp,sp,16
    80004b9e:	8082                	ret

0000000080004ba0 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004ba0:	de010113          	addi	sp,sp,-544
    80004ba4:	20113c23          	sd	ra,536(sp)
    80004ba8:	20813823          	sd	s0,528(sp)
    80004bac:	20913423          	sd	s1,520(sp)
    80004bb0:	21213023          	sd	s2,512(sp)
    80004bb4:	1400                	addi	s0,sp,544
    80004bb6:	892a                	mv	s2,a0
    80004bb8:	dea43823          	sd	a0,-528(s0)
    80004bbc:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004bc0:	d91fc0ef          	jal	80001950 <myproc>
    80004bc4:	84aa                	mv	s1,a0

  begin_op();
    80004bc6:	c62ff0ef          	jal	80004028 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004bca:	854a                	mv	a0,s2
    80004bcc:	a7eff0ef          	jal	80003e4a <namei>
    80004bd0:	cd21                	beqz	a0,80004c28 <kexec+0x88>
    80004bd2:	fbd2                	sd	s4,496(sp)
    80004bd4:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004bd6:	9dbfe0ef          	jal	800035b0 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004bda:	04000713          	li	a4,64
    80004bde:	4681                	li	a3,0
    80004be0:	e5040613          	addi	a2,s0,-432
    80004be4:	4581                	li	a1,0
    80004be6:	8552                	mv	a0,s4
    80004be8:	da3fe0ef          	jal	8000398a <readi>
    80004bec:	04000793          	li	a5,64
    80004bf0:	00f51a63          	bne	a0,a5,80004c04 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004bf4:	e5042703          	lw	a4,-432(s0)
    80004bf8:	464c47b7          	lui	a5,0x464c4
    80004bfc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c00:	02f70863          	beq	a4,a5,80004c30 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004c04:	8552                	mv	a0,s4
    80004c06:	bfffe0ef          	jal	80003804 <iunlockput>
    end_op();
    80004c0a:	caaff0ef          	jal	800040b4 <end_op>
  }
  return -1;
    80004c0e:	557d                	li	a0,-1
    80004c10:	7a5e                	ld	s4,496(sp)
}
    80004c12:	21813083          	ld	ra,536(sp)
    80004c16:	21013403          	ld	s0,528(sp)
    80004c1a:	20813483          	ld	s1,520(sp)
    80004c1e:	20013903          	ld	s2,512(sp)
    80004c22:	22010113          	addi	sp,sp,544
    80004c26:	8082                	ret
    end_op();
    80004c28:	c8cff0ef          	jal	800040b4 <end_op>
    return -1;
    80004c2c:	557d                	li	a0,-1
    80004c2e:	b7d5                	j	80004c12 <kexec+0x72>
    80004c30:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004c32:	8526                	mv	a0,s1
    80004c34:	e23fc0ef          	jal	80001a56 <proc_pagetable>
    80004c38:	8b2a                	mv	s6,a0
    80004c3a:	26050e63          	beqz	a0,80004eb6 <kexec+0x316>
    80004c3e:	ffce                	sd	s3,504(sp)
    80004c40:	f7d6                	sd	s5,488(sp)
    80004c42:	efde                	sd	s7,472(sp)
    80004c44:	ebe2                	sd	s8,464(sp)
    80004c46:	e7e6                	sd	s9,456(sp)
    80004c48:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004c4a:	e8845783          	lhu	a5,-376(s0)
    80004c4e:	14078263          	beqz	a5,80004d92 <kexec+0x1f2>
    80004c52:	ff6e                	sd	s11,440(sp)
    80004c54:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c58:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004c5a:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004c5c:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004c60:	6c85                	lui	s9,0x1
    80004c62:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004c66:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004c6a:	6a85                	lui	s5,0x1
    80004c6c:	a085                	j	80004ccc <kexec+0x12c>
      panic("loadseg: address should exist");
    80004c6e:	00003517          	auipc	a0,0x3
    80004c72:	96250513          	addi	a0,a0,-1694 # 800075d0 <etext+0x5d0>
    80004c76:	bbffb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004c7a:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004c7c:	874a                	mv	a4,s2
    80004c7e:	009b86bb          	addw	a3,s7,s1
    80004c82:	4581                	li	a1,0
    80004c84:	8552                	mv	a0,s4
    80004c86:	d05fe0ef          	jal	8000398a <readi>
    80004c8a:	22a91a63          	bne	s2,a0,80004ebe <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004c8e:	009a84bb          	addw	s1,s5,s1
    80004c92:	0334f263          	bgeu	s1,s3,80004cb6 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004c96:	02049593          	slli	a1,s1,0x20
    80004c9a:	9181                	srli	a1,a1,0x20
    80004c9c:	95e2                	add	a1,a1,s8
    80004c9e:	855a                	mv	a0,s6
    80004ca0:	b80fc0ef          	jal	80001020 <walkaddr>
    80004ca4:	862a                	mv	a2,a0
    if (pa == 0)
    80004ca6:	d561                	beqz	a0,80004c6e <kexec+0xce>
    if (sz - i < PGSIZE)
    80004ca8:	409987bb          	subw	a5,s3,s1
    80004cac:	893e                	mv	s2,a5
    80004cae:	fcfcf6e3          	bgeu	s9,a5,80004c7a <kexec+0xda>
    80004cb2:	8956                	mv	s2,s5
    80004cb4:	b7d9                	j	80004c7a <kexec+0xda>
    sz = sz1;
    80004cb6:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004cba:	2d05                	addiw	s10,s10,1
    80004cbc:	e0843783          	ld	a5,-504(s0)
    80004cc0:	0387869b          	addiw	a3,a5,56
    80004cc4:	e8845783          	lhu	a5,-376(s0)
    80004cc8:	06fd5d63          	bge	s10,a5,80004d42 <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ccc:	e0d43423          	sd	a3,-504(s0)
    80004cd0:	876e                	mv	a4,s11
    80004cd2:	e1840613          	addi	a2,s0,-488
    80004cd6:	4581                	li	a1,0
    80004cd8:	8552                	mv	a0,s4
    80004cda:	cb1fe0ef          	jal	8000398a <readi>
    80004cde:	1db51e63          	bne	a0,s11,80004eba <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004ce2:	e1842783          	lw	a5,-488(s0)
    80004ce6:	4705                	li	a4,1
    80004ce8:	fce799e3          	bne	a5,a4,80004cba <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004cec:	e4043483          	ld	s1,-448(s0)
    80004cf0:	e3843783          	ld	a5,-456(s0)
    80004cf4:	1ef4e363          	bltu	s1,a5,80004eda <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004cf8:	e2843783          	ld	a5,-472(s0)
    80004cfc:	94be                	add	s1,s1,a5
    80004cfe:	1ef4e163          	bltu	s1,a5,80004ee0 <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004d02:	de843703          	ld	a4,-536(s0)
    80004d06:	8ff9                	and	a5,a5,a4
    80004d08:	1c079f63          	bnez	a5,80004ee6 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004d0c:	e1c42503          	lw	a0,-484(s0)
    80004d10:	e71ff0ef          	jal	80004b80 <flags2perm>
    80004d14:	86aa                	mv	a3,a0
    80004d16:	8626                	mv	a2,s1
    80004d18:	85ca                	mv	a1,s2
    80004d1a:	855a                	mv	a0,s6
    80004d1c:	ddafc0ef          	jal	800012f6 <uvmalloc>
    80004d20:	dea43c23          	sd	a0,-520(s0)
    80004d24:	1c050463          	beqz	a0,80004eec <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d28:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004d2c:	00098863          	beqz	s3,80004d3c <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d30:	e2843c03          	ld	s8,-472(s0)
    80004d34:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004d38:	4481                	li	s1,0
    80004d3a:	bfb1                	j	80004c96 <kexec+0xf6>
    sz = sz1;
    80004d3c:	df843903          	ld	s2,-520(s0)
    80004d40:	bfad                	j	80004cba <kexec+0x11a>
    80004d42:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004d44:	8552                	mv	a0,s4
    80004d46:	abffe0ef          	jal	80003804 <iunlockput>
  end_op();
    80004d4a:	b6aff0ef          	jal	800040b4 <end_op>
  p = myproc();
    80004d4e:	c03fc0ef          	jal	80001950 <myproc>
    80004d52:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004d54:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004d58:	6c05                	lui	s8,0x1
    80004d5a:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004d5c:	9c4a                	add	s8,s8,s2
    80004d5e:	77fd                	lui	a5,0xfffff
    80004d60:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004d64:	4691                	li	a3,4
    80004d66:	6609                	lui	a2,0x2
    80004d68:	9662                	add	a2,a2,s8
    80004d6a:	85e2                	mv	a1,s8
    80004d6c:	855a                	mv	a0,s6
    80004d6e:	d88fc0ef          	jal	800012f6 <uvmalloc>
    80004d72:	892a                	mv	s2,a0
    80004d74:	e10d                	bnez	a0,80004d96 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004d76:	85e2                	mv	a1,s8
    80004d78:	855a                	mv	a0,s6
    80004d7a:	d61fc0ef          	jal	80001ada <proc_freepagetable>
  return -1;
    80004d7e:	557d                	li	a0,-1
    80004d80:	79fe                	ld	s3,504(sp)
    80004d82:	7a5e                	ld	s4,496(sp)
    80004d84:	7abe                	ld	s5,488(sp)
    80004d86:	7b1e                	ld	s6,480(sp)
    80004d88:	6bfe                	ld	s7,472(sp)
    80004d8a:	6c5e                	ld	s8,464(sp)
    80004d8c:	6cbe                	ld	s9,456(sp)
    80004d8e:	6d1e                	ld	s10,448(sp)
    80004d90:	b549                	j	80004c12 <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d92:	4901                	li	s2,0
    80004d94:	bf45                	j	80004d44 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004d96:	75f9                	lui	a1,0xffffe
    80004d98:	95aa                	add	a1,a1,a0
    80004d9a:	855a                	mv	a0,s6
    80004d9c:	f2cfc0ef          	jal	800014c8 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004da0:	80090a13          	addi	s4,s2,-2048
    80004da4:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004da8:	e0043783          	ld	a5,-512(s0)
    80004dac:	6388                	ld	a0,0(a5)
    80004dae:	c545                	beqz	a0,80004e56 <kexec+0x2b6>
  sp = sz;
    80004db0:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004db2:	4481                	li	s1,0
    ustack[argc] = sp;
    80004db4:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004db8:	8bafc0ef          	jal	80000e72 <strlen>
    80004dbc:	0015079b          	addiw	a5,a0,1
    80004dc0:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004dc4:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004dc8:	134c6563          	bltu	s8,s4,80004ef2 <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004dcc:	e0043d03          	ld	s10,-512(s0)
    80004dd0:	000d3c83          	ld	s9,0(s10)
    80004dd4:	8566                	mv	a0,s9
    80004dd6:	89cfc0ef          	jal	80000e72 <strlen>
    80004dda:	0015071b          	addiw	a4,a0,1
    80004dde:	86e6                	mv	a3,s9
    80004de0:	8662                	mv	a2,s8
    80004de2:	85ca                	mv	a1,s2
    80004de4:	855a                	mv	a0,s6
    80004de6:	fa4fc0ef          	jal	8000158a <copyout>
    80004dea:	10054663          	bltz	a0,80004ef6 <kexec+0x356>
    ustack[argc] = sp;
    80004dee:	00349793          	slli	a5,s1,0x3
    80004df2:	97de                	add	a5,a5,s7
    80004df4:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb3e0>
  for (argc = 0; argv[argc]; argc++) {
    80004df8:	0485                	addi	s1,s1,1
    80004dfa:	008d0793          	addi	a5,s10,8
    80004dfe:	e0f43023          	sd	a5,-512(s0)
    80004e02:	008d3503          	ld	a0,8(s10)
    80004e06:	f94d                	bnez	a0,80004db8 <kexec+0x218>
  ustack[argc] = 0;
    80004e08:	00349793          	slli	a5,s1,0x3
    80004e0c:	f9078793          	addi	a5,a5,-112
    80004e10:	97a2                	add	a5,a5,s0
    80004e12:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004e16:	00349713          	slli	a4,s1,0x3
    80004e1a:	0721                	addi	a4,a4,8
    80004e1c:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004e20:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004e24:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004e26:	f54be8e3          	bltu	s7,s4,80004d76 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004e2a:	e9040693          	addi	a3,s0,-368
    80004e2e:	865e                	mv	a2,s7
    80004e30:	85ca                	mv	a1,s2
    80004e32:	855a                	mv	a0,s6
    80004e34:	f56fc0ef          	jal	8000158a <copyout>
    80004e38:	f2054fe3          	bltz	a0,80004d76 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004e3c:	0589b783          	ld	a5,88(s3)
    80004e40:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004e44:	df043783          	ld	a5,-528(s0)
    80004e48:	0007c703          	lbu	a4,0(a5)
    80004e4c:	c30d                	beqz	a4,80004e6e <kexec+0x2ce>
    80004e4e:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004e50:	02f00693          	li	a3,47
    80004e54:	a801                	j	80004e64 <kexec+0x2c4>
  sp = sz;
    80004e56:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004e58:	4481                	li	s1,0
    80004e5a:	b77d                	j	80004e08 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004e5c:	0785                	addi	a5,a5,1
    80004e5e:	fff7c703          	lbu	a4,-1(a5)
    80004e62:	c711                	beqz	a4,80004e6e <kexec+0x2ce>
    if (*s == '/')
    80004e64:	fed71ce3          	bne	a4,a3,80004e5c <kexec+0x2bc>
      last = s + 1;
    80004e68:	def43823          	sd	a5,-528(s0)
    80004e6c:	bfc5                	j	80004e5c <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e6e:	4641                	li	a2,16
    80004e70:	df043583          	ld	a1,-528(s0)
    80004e74:	15898513          	addi	a0,s3,344
    80004e78:	fc5fb0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004e7c:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004e80:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004e84:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004e88:	0589b783          	ld	a5,88(s3)
    80004e8c:	e6843703          	ld	a4,-408(s0)
    80004e90:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004e92:	0589b783          	ld	a5,88(s3)
    80004e96:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e9a:	85d6                	mv	a1,s5
    80004e9c:	c3ffc0ef          	jal	80001ada <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ea0:	0004851b          	sext.w	a0,s1
    80004ea4:	79fe                	ld	s3,504(sp)
    80004ea6:	7a5e                	ld	s4,496(sp)
    80004ea8:	7abe                	ld	s5,488(sp)
    80004eaa:	7b1e                	ld	s6,480(sp)
    80004eac:	6bfe                	ld	s7,472(sp)
    80004eae:	6c5e                	ld	s8,464(sp)
    80004eb0:	6cbe                	ld	s9,456(sp)
    80004eb2:	6d1e                	ld	s10,448(sp)
    80004eb4:	bbb9                	j	80004c12 <kexec+0x72>
    80004eb6:	7b1e                	ld	s6,480(sp)
    80004eb8:	b3b1                	j	80004c04 <kexec+0x64>
    80004eba:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004ebe:	df843583          	ld	a1,-520(s0)
    80004ec2:	855a                	mv	a0,s6
    80004ec4:	c17fc0ef          	jal	80001ada <proc_freepagetable>
  if (ip) {
    80004ec8:	79fe                	ld	s3,504(sp)
    80004eca:	7abe                	ld	s5,488(sp)
    80004ecc:	7b1e                	ld	s6,480(sp)
    80004ece:	6bfe                	ld	s7,472(sp)
    80004ed0:	6c5e                	ld	s8,464(sp)
    80004ed2:	6cbe                	ld	s9,456(sp)
    80004ed4:	6d1e                	ld	s10,448(sp)
    80004ed6:	7dfa                	ld	s11,440(sp)
    80004ed8:	b335                	j	80004c04 <kexec+0x64>
    80004eda:	df243c23          	sd	s2,-520(s0)
    80004ede:	b7c5                	j	80004ebe <kexec+0x31e>
    80004ee0:	df243c23          	sd	s2,-520(s0)
    80004ee4:	bfe9                	j	80004ebe <kexec+0x31e>
    80004ee6:	df243c23          	sd	s2,-520(s0)
    80004eea:	bfd1                	j	80004ebe <kexec+0x31e>
    80004eec:	df243c23          	sd	s2,-520(s0)
    80004ef0:	b7f9                	j	80004ebe <kexec+0x31e>
  sz = sz1;
    80004ef2:	8c4a                	mv	s8,s2
    80004ef4:	b549                	j	80004d76 <kexec+0x1d6>
    80004ef6:	8c4a                	mv	s8,s2
    80004ef8:	bdbd                	j	80004d76 <kexec+0x1d6>

0000000080004efa <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004efa:	7179                	addi	sp,sp,-48
    80004efc:	f406                	sd	ra,40(sp)
    80004efe:	f022                	sd	s0,32(sp)
    80004f00:	ec26                	sd	s1,24(sp)
    80004f02:	e84a                	sd	s2,16(sp)
    80004f04:	1800                	addi	s0,sp,48
    80004f06:	892e                	mv	s2,a1
    80004f08:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f0a:	fdc40593          	addi	a1,s0,-36
    80004f0e:	9e9fd0ef          	jal	800028f6 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004f12:	fdc42703          	lw	a4,-36(s0)
    80004f16:	47bd                	li	a5,15
    80004f18:	02e7ea63          	bltu	a5,a4,80004f4c <argfd+0x52>
    80004f1c:	a35fc0ef          	jal	80001950 <myproc>
    80004f20:	fdc42703          	lw	a4,-36(s0)
    80004f24:	00371793          	slli	a5,a4,0x3
    80004f28:	0d078793          	addi	a5,a5,208
    80004f2c:	953e                	add	a0,a0,a5
    80004f2e:	611c                	ld	a5,0(a0)
    80004f30:	c385                	beqz	a5,80004f50 <argfd+0x56>
    return -1;
  if (pfd)
    80004f32:	00090463          	beqz	s2,80004f3a <argfd+0x40>
    *pfd = fd;
    80004f36:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004f3a:	4501                	li	a0,0
  if (pf)
    80004f3c:	c091                	beqz	s1,80004f40 <argfd+0x46>
    *pf = f;
    80004f3e:	e09c                	sd	a5,0(s1)
}
    80004f40:	70a2                	ld	ra,40(sp)
    80004f42:	7402                	ld	s0,32(sp)
    80004f44:	64e2                	ld	s1,24(sp)
    80004f46:	6942                	ld	s2,16(sp)
    80004f48:	6145                	addi	sp,sp,48
    80004f4a:	8082                	ret
    return -1;
    80004f4c:	557d                	li	a0,-1
    80004f4e:	bfcd                	j	80004f40 <argfd+0x46>
    80004f50:	557d                	li	a0,-1
    80004f52:	b7fd                	j	80004f40 <argfd+0x46>

0000000080004f54 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f54:	1101                	addi	sp,sp,-32
    80004f56:	ec06                	sd	ra,24(sp)
    80004f58:	e822                	sd	s0,16(sp)
    80004f5a:	e426                	sd	s1,8(sp)
    80004f5c:	1000                	addi	s0,sp,32
    80004f5e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f60:	9f1fc0ef          	jal	80001950 <myproc>
    80004f64:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004f66:	0d050793          	addi	a5,a0,208
    80004f6a:	4501                	li	a0,0
    80004f6c:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004f6e:	6398                	ld	a4,0(a5)
    80004f70:	cb19                	beqz	a4,80004f86 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004f72:	2505                	addiw	a0,a0,1
    80004f74:	07a1                	addi	a5,a5,8
    80004f76:	fed51ce3          	bne	a0,a3,80004f6e <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f7a:	557d                	li	a0,-1
}
    80004f7c:	60e2                	ld	ra,24(sp)
    80004f7e:	6442                	ld	s0,16(sp)
    80004f80:	64a2                	ld	s1,8(sp)
    80004f82:	6105                	addi	sp,sp,32
    80004f84:	8082                	ret
      p->ofile[fd] = f;
    80004f86:	00351793          	slli	a5,a0,0x3
    80004f8a:	0d078793          	addi	a5,a5,208
    80004f8e:	963e                	add	a2,a2,a5
    80004f90:	e204                	sd	s1,0(a2)
      return fd;
    80004f92:	b7ed                	j	80004f7c <fdalloc+0x28>

0000000080004f94 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004f94:	715d                	addi	sp,sp,-80
    80004f96:	e486                	sd	ra,72(sp)
    80004f98:	e0a2                	sd	s0,64(sp)
    80004f9a:	fc26                	sd	s1,56(sp)
    80004f9c:	f84a                	sd	s2,48(sp)
    80004f9e:	f052                	sd	s4,32(sp)
    80004fa0:	ec56                	sd	s5,24(sp)
    80004fa2:	e85a                	sd	s6,16(sp)
    80004fa4:	0880                	addi	s0,sp,80
    80004fa6:	8a2e                	mv	s4,a1
    80004fa8:	8ab2                	mv	s5,a2
    80004faa:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004fac:	fb040593          	addi	a1,s0,-80
    80004fb0:	eb5fe0ef          	jal	80003e64 <nameiparent>
    80004fb4:	84aa                	mv	s1,a0
    80004fb6:	12050f63          	beqz	a0,800050f4 <create+0x160>
    return 0;

  ilock(dp);
    80004fba:	df6fe0ef          	jal	800035b0 <ilock>

  if (dp->nlink == 0) {
    80004fbe:	04a49783          	lh	a5,74(s1)
    80004fc2:	cbb9                	beqz	a5,80005018 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004fc4:	7761                	lui	a4,0xffff8
    80004fc6:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd43e1>
    80004fc8:	97ba                	add	a5,a5,a4
    80004fca:	e781                	bnez	a5,80004fd2 <create+0x3e>
    80004fcc:	fffa0793          	addi	a5,s4,-1
    80004fd0:	cba9                	beqz	a5,80005022 <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004fd2:	4601                	li	a2,0
    80004fd4:	fb040593          	addi	a1,s0,-80
    80004fd8:	8526                	mv	a0,s1
    80004fda:	bbffe0ef          	jal	80003b98 <dirlookup>
    80004fde:	892a                	mv	s2,a0
    80004fe0:	c939                	beqz	a0,80005036 <create+0xa2>
    iunlockput(dp);
    80004fe2:	8526                	mv	a0,s1
    80004fe4:	821fe0ef          	jal	80003804 <iunlockput>
    ilock(ip);
    80004fe8:	854a                	mv	a0,s2
    80004fea:	dc6fe0ef          	jal	800035b0 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004fee:	4789                	li	a5,2
    80004ff0:	02fa1e63          	bne	s4,a5,8000502c <create+0x98>
    80004ff4:	04495783          	lhu	a5,68(s2)
    80004ff8:	37f9                	addiw	a5,a5,-2
    80004ffa:	17c2                	slli	a5,a5,0x30
    80004ffc:	93c1                	srli	a5,a5,0x30
    80004ffe:	4705                	li	a4,1
    80005000:	02f76663          	bltu	a4,a5,8000502c <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005004:	854a                	mv	a0,s2
    80005006:	60a6                	ld	ra,72(sp)
    80005008:	6406                	ld	s0,64(sp)
    8000500a:	74e2                	ld	s1,56(sp)
    8000500c:	7942                	ld	s2,48(sp)
    8000500e:	7a02                	ld	s4,32(sp)
    80005010:	6ae2                	ld	s5,24(sp)
    80005012:	6b42                	ld	s6,16(sp)
    80005014:	6161                	addi	sp,sp,80
    80005016:	8082                	ret
    iunlockput(dp);
    80005018:	8526                	mv	a0,s1
    8000501a:	feafe0ef          	jal	80003804 <iunlockput>
    return 0;
    8000501e:	4901                	li	s2,0
    80005020:	b7d5                	j	80005004 <create+0x70>
    iunlockput(dp);
    80005022:	8526                	mv	a0,s1
    80005024:	fe0fe0ef          	jal	80003804 <iunlockput>
    return 0;
    80005028:	4901                	li	s2,0
    8000502a:	bfe9                	j	80005004 <create+0x70>
    iunlockput(ip);
    8000502c:	854a                	mv	a0,s2
    8000502e:	fd6fe0ef          	jal	80003804 <iunlockput>
    return 0;
    80005032:	4901                	li	s2,0
    80005034:	bfc1                	j	80005004 <create+0x70>
    80005036:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80005038:	85d2                	mv	a1,s4
    8000503a:	4088                	lw	a0,0(s1)
    8000503c:	c04fe0ef          	jal	80003440 <ialloc>
    80005040:	89aa                	mv	s3,a0
    80005042:	cd1d                	beqz	a0,80005080 <create+0xec>
  ilock(ip);
    80005044:	d6cfe0ef          	jal	800035b0 <ilock>
  ip->major = major;
    80005048:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    8000504c:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80005050:	4705                	li	a4,1
    80005052:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80005056:	854e                	mv	a0,s3
    80005058:	ca4fe0ef          	jal	800034fc <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    8000505c:	4705                	li	a4,1
    8000505e:	02ea0763          	beq	s4,a4,8000508c <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80005062:	0049a603          	lw	a2,4(s3)
    80005066:	fb040593          	addi	a1,s0,-80
    8000506a:	8526                	mv	a0,s1
    8000506c:	d35fe0ef          	jal	80003da0 <dirlink>
    80005070:	06054563          	bltz	a0,800050da <create+0x146>
  iunlockput(dp);
    80005074:	8526                	mv	a0,s1
    80005076:	f8efe0ef          	jal	80003804 <iunlockput>
  return ip;
    8000507a:	894e                	mv	s2,s3
    8000507c:	79a2                	ld	s3,40(sp)
    8000507e:	b759                	j	80005004 <create+0x70>
    iunlockput(dp);
    80005080:	8526                	mv	a0,s1
    80005082:	f82fe0ef          	jal	80003804 <iunlockput>
    return 0;
    80005086:	894e                	mv	s2,s3
    80005088:	79a2                	ld	s3,40(sp)
    8000508a:	bfad                	j	80005004 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000508c:	0049a603          	lw	a2,4(s3)
    80005090:	00002597          	auipc	a1,0x2
    80005094:	56058593          	addi	a1,a1,1376 # 800075f0 <etext+0x5f0>
    80005098:	854e                	mv	a0,s3
    8000509a:	d07fe0ef          	jal	80003da0 <dirlink>
    8000509e:	02054e63          	bltz	a0,800050da <create+0x146>
    800050a2:	40d0                	lw	a2,4(s1)
    800050a4:	00002597          	auipc	a1,0x2
    800050a8:	55458593          	addi	a1,a1,1364 # 800075f8 <etext+0x5f8>
    800050ac:	854e                	mv	a0,s3
    800050ae:	cf3fe0ef          	jal	80003da0 <dirlink>
    800050b2:	02054463          	bltz	a0,800050da <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    800050b6:	0049a603          	lw	a2,4(s3)
    800050ba:	fb040593          	addi	a1,s0,-80
    800050be:	8526                	mv	a0,s1
    800050c0:	ce1fe0ef          	jal	80003da0 <dirlink>
    800050c4:	00054b63          	bltz	a0,800050da <create+0x146>
    dp->nlink++; // for ".."
    800050c8:	04a4d783          	lhu	a5,74(s1)
    800050cc:	2785                	addiw	a5,a5,1
    800050ce:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800050d2:	8526                	mv	a0,s1
    800050d4:	c28fe0ef          	jal	800034fc <iupdate>
    800050d8:	bf71                	j	80005074 <create+0xe0>
  ip->nlink = 0;
    800050da:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    800050de:	854e                	mv	a0,s3
    800050e0:	c1cfe0ef          	jal	800034fc <iupdate>
  iunlockput(ip);
    800050e4:	854e                	mv	a0,s3
    800050e6:	f1efe0ef          	jal	80003804 <iunlockput>
  iunlockput(dp);
    800050ea:	8526                	mv	a0,s1
    800050ec:	f18fe0ef          	jal	80003804 <iunlockput>
  return 0;
    800050f0:	79a2                	ld	s3,40(sp)
    800050f2:	bf09                	j	80005004 <create+0x70>
    return 0;
    800050f4:	892a                	mv	s2,a0
    800050f6:	b739                	j	80005004 <create+0x70>

00000000800050f8 <sys_dup>:
{
    800050f8:	7179                	addi	sp,sp,-48
    800050fa:	f406                	sd	ra,40(sp)
    800050fc:	f022                	sd	s0,32(sp)
    800050fe:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80005100:	fd840613          	addi	a2,s0,-40
    80005104:	4581                	li	a1,0
    80005106:	4501                	li	a0,0
    80005108:	df3ff0ef          	jal	80004efa <argfd>
    return -1;
    8000510c:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    8000510e:	02054363          	bltz	a0,80005134 <sys_dup+0x3c>
    80005112:	ec26                	sd	s1,24(sp)
    80005114:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80005116:	fd843483          	ld	s1,-40(s0)
    8000511a:	8526                	mv	a0,s1
    8000511c:	e39ff0ef          	jal	80004f54 <fdalloc>
    80005120:	892a                	mv	s2,a0
    return -1;
    80005122:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80005124:	00054d63          	bltz	a0,8000513e <sys_dup+0x46>
  filedup(f);
    80005128:	8526                	mv	a0,s1
    8000512a:	b72ff0ef          	jal	8000449c <filedup>
  return fd;
    8000512e:	87ca                	mv	a5,s2
    80005130:	64e2                	ld	s1,24(sp)
    80005132:	6942                	ld	s2,16(sp)
}
    80005134:	853e                	mv	a0,a5
    80005136:	70a2                	ld	ra,40(sp)
    80005138:	7402                	ld	s0,32(sp)
    8000513a:	6145                	addi	sp,sp,48
    8000513c:	8082                	ret
    8000513e:	64e2                	ld	s1,24(sp)
    80005140:	6942                	ld	s2,16(sp)
    80005142:	bfcd                	j	80005134 <sys_dup+0x3c>

0000000080005144 <sys_read>:
{
    80005144:	7179                	addi	sp,sp,-48
    80005146:	f406                	sd	ra,40(sp)
    80005148:	f022                	sd	s0,32(sp)
    8000514a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000514c:	fd840593          	addi	a1,s0,-40
    80005150:	4505                	li	a0,1
    80005152:	fc0fd0ef          	jal	80002912 <argaddr>
  argint(2, &n);
    80005156:	fe440593          	addi	a1,s0,-28
    8000515a:	4509                	li	a0,2
    8000515c:	f9afd0ef          	jal	800028f6 <argint>
  if (argfd(0, 0, &f) < 0)
    80005160:	fe840613          	addi	a2,s0,-24
    80005164:	4581                	li	a1,0
    80005166:	4501                	li	a0,0
    80005168:	d93ff0ef          	jal	80004efa <argfd>
    8000516c:	87aa                	mv	a5,a0
    return -1;
    8000516e:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005170:	0007ca63          	bltz	a5,80005184 <sys_read+0x40>
  return fileread(f, p, n);
    80005174:	fe442603          	lw	a2,-28(s0)
    80005178:	fd843583          	ld	a1,-40(s0)
    8000517c:	fe843503          	ld	a0,-24(s0)
    80005180:	c94ff0ef          	jal	80004614 <fileread>
}
    80005184:	70a2                	ld	ra,40(sp)
    80005186:	7402                	ld	s0,32(sp)
    80005188:	6145                	addi	sp,sp,48
    8000518a:	8082                	ret

000000008000518c <sys_write>:
{
    8000518c:	7179                	addi	sp,sp,-48
    8000518e:	f406                	sd	ra,40(sp)
    80005190:	f022                	sd	s0,32(sp)
    80005192:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005194:	fd840593          	addi	a1,s0,-40
    80005198:	4505                	li	a0,1
    8000519a:	f78fd0ef          	jal	80002912 <argaddr>
  argint(2, &n);
    8000519e:	fe440593          	addi	a1,s0,-28
    800051a2:	4509                	li	a0,2
    800051a4:	f52fd0ef          	jal	800028f6 <argint>
  if (argfd(0, 0, &f) < 0)
    800051a8:	fe840613          	addi	a2,s0,-24
    800051ac:	4581                	li	a1,0
    800051ae:	4501                	li	a0,0
    800051b0:	d4bff0ef          	jal	80004efa <argfd>
    800051b4:	87aa                	mv	a5,a0
    return -1;
    800051b6:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800051b8:	0007ca63          	bltz	a5,800051cc <sys_write+0x40>
  return filewrite(f, p, n);
    800051bc:	fe442603          	lw	a2,-28(s0)
    800051c0:	fd843583          	ld	a1,-40(s0)
    800051c4:	fe843503          	ld	a0,-24(s0)
    800051c8:	d1aff0ef          	jal	800046e2 <filewrite>
}
    800051cc:	70a2                	ld	ra,40(sp)
    800051ce:	7402                	ld	s0,32(sp)
    800051d0:	6145                	addi	sp,sp,48
    800051d2:	8082                	ret

00000000800051d4 <sys_close>:
{
    800051d4:	1101                	addi	sp,sp,-32
    800051d6:	ec06                	sd	ra,24(sp)
    800051d8:	e822                	sd	s0,16(sp)
    800051da:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    800051dc:	fe040613          	addi	a2,s0,-32
    800051e0:	fec40593          	addi	a1,s0,-20
    800051e4:	4501                	li	a0,0
    800051e6:	d15ff0ef          	jal	80004efa <argfd>
    return -1;
    800051ea:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    800051ec:	02054163          	bltz	a0,8000520e <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    800051f0:	f60fc0ef          	jal	80001950 <myproc>
    800051f4:	fec42783          	lw	a5,-20(s0)
    800051f8:	078e                	slli	a5,a5,0x3
    800051fa:	0d078793          	addi	a5,a5,208
    800051fe:	953e                	add	a0,a0,a5
    80005200:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005204:	fe043503          	ld	a0,-32(s0)
    80005208:	adaff0ef          	jal	800044e2 <fileclose>
  return 0;
    8000520c:	4781                	li	a5,0
}
    8000520e:	853e                	mv	a0,a5
    80005210:	60e2                	ld	ra,24(sp)
    80005212:	6442                	ld	s0,16(sp)
    80005214:	6105                	addi	sp,sp,32
    80005216:	8082                	ret

0000000080005218 <sys_fstat>:
{
    80005218:	1101                	addi	sp,sp,-32
    8000521a:	ec06                	sd	ra,24(sp)
    8000521c:	e822                	sd	s0,16(sp)
    8000521e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005220:	fe040593          	addi	a1,s0,-32
    80005224:	4505                	li	a0,1
    80005226:	eecfd0ef          	jal	80002912 <argaddr>
  if (argfd(0, 0, &f) < 0)
    8000522a:	fe840613          	addi	a2,s0,-24
    8000522e:	4581                	li	a1,0
    80005230:	4501                	li	a0,0
    80005232:	cc9ff0ef          	jal	80004efa <argfd>
    80005236:	87aa                	mv	a5,a0
    return -1;
    80005238:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    8000523a:	0007c863          	bltz	a5,8000524a <sys_fstat+0x32>
  return filestat(f, st);
    8000523e:	fe043583          	ld	a1,-32(s0)
    80005242:	fe843503          	ld	a0,-24(s0)
    80005246:	b5eff0ef          	jal	800045a4 <filestat>
}
    8000524a:	60e2                	ld	ra,24(sp)
    8000524c:	6442                	ld	s0,16(sp)
    8000524e:	6105                	addi	sp,sp,32
    80005250:	8082                	ret

0000000080005252 <sys_link>:
{
    80005252:	7169                	addi	sp,sp,-304
    80005254:	f606                	sd	ra,296(sp)
    80005256:	f222                	sd	s0,288(sp)
    80005258:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000525a:	08000613          	li	a2,128
    8000525e:	ed040593          	addi	a1,s0,-304
    80005262:	4501                	li	a0,0
    80005264:	ecafd0ef          	jal	8000292e <argstr>
    return -1;
    80005268:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000526a:	10054163          	bltz	a0,8000536c <sys_link+0x11a>
    8000526e:	08000613          	li	a2,128
    80005272:	f5040593          	addi	a1,s0,-176
    80005276:	4505                	li	a0,1
    80005278:	eb6fd0ef          	jal	8000292e <argstr>
    return -1;
    8000527c:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000527e:	0e054763          	bltz	a0,8000536c <sys_link+0x11a>
    80005282:	ee26                	sd	s1,280(sp)
  begin_op();
    80005284:	da5fe0ef          	jal	80004028 <begin_op>
  if ((ip = namei(old)) == 0) {
    80005288:	ed040513          	addi	a0,s0,-304
    8000528c:	bbffe0ef          	jal	80003e4a <namei>
    80005290:	84aa                	mv	s1,a0
    80005292:	cd35                	beqz	a0,8000530e <sys_link+0xbc>
  ilock(ip);
    80005294:	b1cfe0ef          	jal	800035b0 <ilock>
  if (ip->type == T_DIR) {
    80005298:	04449703          	lh	a4,68(s1)
    8000529c:	4785                	li	a5,1
    8000529e:	06f70d63          	beq	a4,a5,80005318 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    800052a2:	04a49783          	lh	a5,74(s1)
    800052a6:	6721                	lui	a4,0x8
    800052a8:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    800052aa:	06e78f63          	beq	a5,a4,80005328 <sys_link+0xd6>
    800052ae:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800052b0:	2785                	addiw	a5,a5,1
    800052b2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052b6:	8526                	mv	a0,s1
    800052b8:	a44fe0ef          	jal	800034fc <iupdate>
  iunlock(ip);
    800052bc:	8526                	mv	a0,s1
    800052be:	ba0fe0ef          	jal	8000365e <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    800052c2:	fd040593          	addi	a1,s0,-48
    800052c6:	f5040513          	addi	a0,s0,-176
    800052ca:	b9bfe0ef          	jal	80003e64 <nameiparent>
    800052ce:	892a                	mv	s2,a0
    800052d0:	c93d                	beqz	a0,80005346 <sys_link+0xf4>
  ilock(dp);
    800052d2:	adefe0ef          	jal	800035b0 <ilock>
  if (dp->nlink == 0) {
    800052d6:	04a91783          	lh	a5,74(s2)
    800052da:	cfb9                	beqz	a5,80005338 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    800052dc:	854a                	mv	a0,s2
    800052de:	00092703          	lw	a4,0(s2)
    800052e2:	409c                	lw	a5,0(s1)
    800052e4:	04f71e63          	bne	a4,a5,80005340 <sys_link+0xee>
    800052e8:	40d0                	lw	a2,4(s1)
    800052ea:	fd040593          	addi	a1,s0,-48
    800052ee:	ab3fe0ef          	jal	80003da0 <dirlink>
    800052f2:	04054763          	bltz	a0,80005340 <sys_link+0xee>
  iunlockput(dp);
    800052f6:	854a                	mv	a0,s2
    800052f8:	d0cfe0ef          	jal	80003804 <iunlockput>
  iput(ip);
    800052fc:	8526                	mv	a0,s1
    800052fe:	c34fe0ef          	jal	80003732 <iput>
  end_op();
    80005302:	db3fe0ef          	jal	800040b4 <end_op>
  return 0;
    80005306:	4781                	li	a5,0
    80005308:	64f2                	ld	s1,280(sp)
    8000530a:	6952                	ld	s2,272(sp)
    8000530c:	a085                	j	8000536c <sys_link+0x11a>
    end_op();
    8000530e:	da7fe0ef          	jal	800040b4 <end_op>
    return -1;
    80005312:	57fd                	li	a5,-1
    80005314:	64f2                	ld	s1,280(sp)
    80005316:	a899                	j	8000536c <sys_link+0x11a>
    iunlockput(ip);
    80005318:	8526                	mv	a0,s1
    8000531a:	ceafe0ef          	jal	80003804 <iunlockput>
    end_op();
    8000531e:	d97fe0ef          	jal	800040b4 <end_op>
    return -1;
    80005322:	57fd                	li	a5,-1
    80005324:	64f2                	ld	s1,280(sp)
    80005326:	a099                	j	8000536c <sys_link+0x11a>
    iunlockput(ip);
    80005328:	8526                	mv	a0,s1
    8000532a:	cdafe0ef          	jal	80003804 <iunlockput>
    end_op();
    8000532e:	d87fe0ef          	jal	800040b4 <end_op>
    return -1;
    80005332:	57fd                	li	a5,-1
    80005334:	64f2                	ld	s1,280(sp)
    80005336:	a81d                	j	8000536c <sys_link+0x11a>
    iunlockput(dp);
    80005338:	854a                	mv	a0,s2
    8000533a:	ccafe0ef          	jal	80003804 <iunlockput>
    goto bad;
    8000533e:	a021                	j	80005346 <sys_link+0xf4>
    iunlockput(dp);
    80005340:	854a                	mv	a0,s2
    80005342:	cc2fe0ef          	jal	80003804 <iunlockput>
  ilock(ip);
    80005346:	8526                	mv	a0,s1
    80005348:	a68fe0ef          	jal	800035b0 <ilock>
  ip->nlink--;
    8000534c:	04a4d783          	lhu	a5,74(s1)
    80005350:	37fd                	addiw	a5,a5,-1
    80005352:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005356:	8526                	mv	a0,s1
    80005358:	9a4fe0ef          	jal	800034fc <iupdate>
  iunlockput(ip);
    8000535c:	8526                	mv	a0,s1
    8000535e:	ca6fe0ef          	jal	80003804 <iunlockput>
  end_op();
    80005362:	d53fe0ef          	jal	800040b4 <end_op>
  return -1;
    80005366:	57fd                	li	a5,-1
    80005368:	64f2                	ld	s1,280(sp)
    8000536a:	6952                	ld	s2,272(sp)
}
    8000536c:	853e                	mv	a0,a5
    8000536e:	70b2                	ld	ra,296(sp)
    80005370:	7412                	ld	s0,288(sp)
    80005372:	6155                	addi	sp,sp,304
    80005374:	8082                	ret

0000000080005376 <sys_unlink>:
{
    80005376:	7151                	addi	sp,sp,-240
    80005378:	f586                	sd	ra,232(sp)
    8000537a:	f1a2                	sd	s0,224(sp)
    8000537c:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    8000537e:	08000613          	li	a2,128
    80005382:	f3040593          	addi	a1,s0,-208
    80005386:	4501                	li	a0,0
    80005388:	da6fd0ef          	jal	8000292e <argstr>
    8000538c:	14054d63          	bltz	a0,800054e6 <sys_unlink+0x170>
    80005390:	eda6                	sd	s1,216(sp)
  begin_op();
    80005392:	c97fe0ef          	jal	80004028 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80005396:	fb040593          	addi	a1,s0,-80
    8000539a:	f3040513          	addi	a0,s0,-208
    8000539e:	ac7fe0ef          	jal	80003e64 <nameiparent>
    800053a2:	84aa                	mv	s1,a0
    800053a4:	c955                	beqz	a0,80005458 <sys_unlink+0xe2>
  ilock(dp);
    800053a6:	a0afe0ef          	jal	800035b0 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800053aa:	00002597          	auipc	a1,0x2
    800053ae:	24658593          	addi	a1,a1,582 # 800075f0 <etext+0x5f0>
    800053b2:	fb040513          	addi	a0,s0,-80
    800053b6:	fccfe0ef          	jal	80003b82 <namecmp>
    800053ba:	10050b63          	beqz	a0,800054d0 <sys_unlink+0x15a>
    800053be:	00002597          	auipc	a1,0x2
    800053c2:	23a58593          	addi	a1,a1,570 # 800075f8 <etext+0x5f8>
    800053c6:	fb040513          	addi	a0,s0,-80
    800053ca:	fb8fe0ef          	jal	80003b82 <namecmp>
    800053ce:	10050163          	beqz	a0,800054d0 <sys_unlink+0x15a>
    800053d2:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    800053d4:	f2c40613          	addi	a2,s0,-212
    800053d8:	fb040593          	addi	a1,s0,-80
    800053dc:	8526                	mv	a0,s1
    800053de:	fbafe0ef          	jal	80003b98 <dirlookup>
    800053e2:	892a                	mv	s2,a0
    800053e4:	0e050563          	beqz	a0,800054ce <sys_unlink+0x158>
    800053e8:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800053ea:	9c6fe0ef          	jal	800035b0 <ilock>
  if (ip->nlink < 1)
    800053ee:	04a91783          	lh	a5,74(s2)
    800053f2:	06f05863          	blez	a5,80005462 <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    800053f6:	04491703          	lh	a4,68(s2)
    800053fa:	4785                	li	a5,1
    800053fc:	06f70963          	beq	a4,a5,8000546e <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005400:	fc040993          	addi	s3,s0,-64
    80005404:	4641                	li	a2,16
    80005406:	4581                	li	a1,0
    80005408:	854e                	mv	a0,s3
    8000540a:	8dffb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000540e:	4741                	li	a4,16
    80005410:	f2c42683          	lw	a3,-212(s0)
    80005414:	864e                	mv	a2,s3
    80005416:	4581                	li	a1,0
    80005418:	8526                	mv	a0,s1
    8000541a:	e62fe0ef          	jal	80003a7c <writei>
    8000541e:	47c1                	li	a5,16
    80005420:	08f51863          	bne	a0,a5,800054b0 <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    80005424:	04491703          	lh	a4,68(s2)
    80005428:	4785                	li	a5,1
    8000542a:	08f70963          	beq	a4,a5,800054bc <sys_unlink+0x146>
  iunlockput(dp);
    8000542e:	8526                	mv	a0,s1
    80005430:	bd4fe0ef          	jal	80003804 <iunlockput>
  ip->nlink--;
    80005434:	04a95783          	lhu	a5,74(s2)
    80005438:	37fd                	addiw	a5,a5,-1
    8000543a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000543e:	854a                	mv	a0,s2
    80005440:	8bcfe0ef          	jal	800034fc <iupdate>
  iunlockput(ip);
    80005444:	854a                	mv	a0,s2
    80005446:	bbefe0ef          	jal	80003804 <iunlockput>
  end_op();
    8000544a:	c6bfe0ef          	jal	800040b4 <end_op>
  return 0;
    8000544e:	4501                	li	a0,0
    80005450:	64ee                	ld	s1,216(sp)
    80005452:	694e                	ld	s2,208(sp)
    80005454:	69ae                	ld	s3,200(sp)
    80005456:	a061                	j	800054de <sys_unlink+0x168>
    end_op();
    80005458:	c5dfe0ef          	jal	800040b4 <end_op>
    return -1;
    8000545c:	557d                	li	a0,-1
    8000545e:	64ee                	ld	s1,216(sp)
    80005460:	a8bd                	j	800054de <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005462:	00002517          	auipc	a0,0x2
    80005466:	19e50513          	addi	a0,a0,414 # 80007600 <etext+0x600>
    8000546a:	bcafb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000546e:	04c92703          	lw	a4,76(s2)
    80005472:	02000793          	li	a5,32
    80005476:	f8e7f5e3          	bgeu	a5,a4,80005400 <sys_unlink+0x8a>
    8000547a:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000547c:	4741                	li	a4,16
    8000547e:	86ce                	mv	a3,s3
    80005480:	f1840613          	addi	a2,s0,-232
    80005484:	4581                	li	a1,0
    80005486:	854a                	mv	a0,s2
    80005488:	d02fe0ef          	jal	8000398a <readi>
    8000548c:	47c1                	li	a5,16
    8000548e:	00f51b63          	bne	a0,a5,800054a4 <sys_unlink+0x12e>
    if (de.inum != 0)
    80005492:	f1845783          	lhu	a5,-232(s0)
    80005496:	ebb1                	bnez	a5,800054ea <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005498:	29c1                	addiw	s3,s3,16
    8000549a:	04c92783          	lw	a5,76(s2)
    8000549e:	fcf9efe3          	bltu	s3,a5,8000547c <sys_unlink+0x106>
    800054a2:	bfb9                	j	80005400 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800054a4:	00002517          	auipc	a0,0x2
    800054a8:	17450513          	addi	a0,a0,372 # 80007618 <etext+0x618>
    800054ac:	b88fb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    800054b0:	00002517          	auipc	a0,0x2
    800054b4:	18050513          	addi	a0,a0,384 # 80007630 <etext+0x630>
    800054b8:	b7cfb0ef          	jal	80000834 <panic>
    dp->nlink--;
    800054bc:	04a4d783          	lhu	a5,74(s1)
    800054c0:	37fd                	addiw	a5,a5,-1
    800054c2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054c6:	8526                	mv	a0,s1
    800054c8:	834fe0ef          	jal	800034fc <iupdate>
    800054cc:	b78d                	j	8000542e <sys_unlink+0xb8>
    800054ce:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800054d0:	8526                	mv	a0,s1
    800054d2:	b32fe0ef          	jal	80003804 <iunlockput>
  end_op();
    800054d6:	bdffe0ef          	jal	800040b4 <end_op>
  return -1;
    800054da:	557d                	li	a0,-1
    800054dc:	64ee                	ld	s1,216(sp)
}
    800054de:	70ae                	ld	ra,232(sp)
    800054e0:	740e                	ld	s0,224(sp)
    800054e2:	616d                	addi	sp,sp,240
    800054e4:	8082                	ret
    return -1;
    800054e6:	557d                	li	a0,-1
    800054e8:	bfdd                	j	800054de <sys_unlink+0x168>
    iunlockput(ip);
    800054ea:	854a                	mv	a0,s2
    800054ec:	b18fe0ef          	jal	80003804 <iunlockput>
    goto bad;
    800054f0:	694e                	ld	s2,208(sp)
    800054f2:	69ae                	ld	s3,200(sp)
    800054f4:	bff1                	j	800054d0 <sys_unlink+0x15a>

00000000800054f6 <sys_open>:

uint64
sys_open(void)
{
    800054f6:	7131                	addi	sp,sp,-192
    800054f8:	fd06                	sd	ra,184(sp)
    800054fa:	f922                	sd	s0,176(sp)
    800054fc:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800054fe:	f4c40593          	addi	a1,s0,-180
    80005502:	4505                	li	a0,1
    80005504:	bf2fd0ef          	jal	800028f6 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005508:	08000613          	li	a2,128
    8000550c:	f5040593          	addi	a1,s0,-176
    80005510:	4501                	li	a0,0
    80005512:	c1cfd0ef          	jal	8000292e <argstr>
    80005516:	87aa                	mv	a5,a0
    return -1;
    80005518:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000551a:	0a07c363          	bltz	a5,800055c0 <sys_open+0xca>
    8000551e:	f526                	sd	s1,168(sp)

  begin_op();
    80005520:	b09fe0ef          	jal	80004028 <begin_op>

  if (omode & O_CREATE) {
    80005524:	f4c42783          	lw	a5,-180(s0)
    80005528:	2007f793          	andi	a5,a5,512
    8000552c:	c3dd                	beqz	a5,800055d2 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    8000552e:	4681                	li	a3,0
    80005530:	4601                	li	a2,0
    80005532:	4589                	li	a1,2
    80005534:	f5040513          	addi	a0,s0,-176
    80005538:	a5dff0ef          	jal	80004f94 <create>
    8000553c:	84aa                	mv	s1,a0
    if (ip == 0) {
    8000553e:	c549                	beqz	a0,800055c8 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    80005540:	04449703          	lh	a4,68(s1)
    80005544:	478d                	li	a5,3
    80005546:	00f71763          	bne	a4,a5,80005554 <sys_open+0x5e>
    8000554a:	0464d703          	lhu	a4,70(s1)
    8000554e:	47a5                	li	a5,9
    80005550:	0ae7ee63          	bltu	a5,a4,8000560c <sys_open+0x116>
    80005554:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    80005556:	ee9fe0ef          	jal	8000443e <filealloc>
    8000555a:	892a                	mv	s2,a0
    8000555c:	c561                	beqz	a0,80005624 <sys_open+0x12e>
    8000555e:	ed4e                	sd	s3,152(sp)
    80005560:	9f5ff0ef          	jal	80004f54 <fdalloc>
    80005564:	89aa                	mv	s3,a0
    80005566:	0a054b63          	bltz	a0,8000561c <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    8000556a:	04449703          	lh	a4,68(s1)
    8000556e:	478d                	li	a5,3
    80005570:	0cf70363          	beq	a4,a5,80005636 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005574:	4789                	li	a5,2
    80005576:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000557a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000557e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005582:	f4c42783          	lw	a5,-180(s0)
    80005586:	0017f713          	andi	a4,a5,1
    8000558a:	00174713          	xori	a4,a4,1
    8000558e:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005592:	0037f713          	andi	a4,a5,3
    80005596:	00e03733          	snez	a4,a4
    8000559a:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    8000559e:	4007f793          	andi	a5,a5,1024
    800055a2:	c791                	beqz	a5,800055ae <sys_open+0xb8>
    800055a4:	04449703          	lh	a4,68(s1)
    800055a8:	4789                	li	a5,2
    800055aa:	08f70d63          	beq	a4,a5,80005644 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800055ae:	8526                	mv	a0,s1
    800055b0:	8aefe0ef          	jal	8000365e <iunlock>
  end_op();
    800055b4:	b01fe0ef          	jal	800040b4 <end_op>

  return fd;
    800055b8:	854e                	mv	a0,s3
    800055ba:	74aa                	ld	s1,168(sp)
    800055bc:	790a                	ld	s2,160(sp)
    800055be:	69ea                	ld	s3,152(sp)
}
    800055c0:	70ea                	ld	ra,184(sp)
    800055c2:	744a                	ld	s0,176(sp)
    800055c4:	6129                	addi	sp,sp,192
    800055c6:	8082                	ret
      end_op();
    800055c8:	aedfe0ef          	jal	800040b4 <end_op>
      return -1;
    800055cc:	557d                	li	a0,-1
    800055ce:	74aa                	ld	s1,168(sp)
    800055d0:	bfc5                	j	800055c0 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    800055d2:	f5040513          	addi	a0,s0,-176
    800055d6:	875fe0ef          	jal	80003e4a <namei>
    800055da:	84aa                	mv	s1,a0
    800055dc:	c11d                	beqz	a0,80005602 <sys_open+0x10c>
    ilock(ip);
    800055de:	fd3fd0ef          	jal	800035b0 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    800055e2:	04449703          	lh	a4,68(s1)
    800055e6:	4785                	li	a5,1
    800055e8:	f4f71ce3          	bne	a4,a5,80005540 <sys_open+0x4a>
    800055ec:	f4c42783          	lw	a5,-180(s0)
    800055f0:	d3b5                	beqz	a5,80005554 <sys_open+0x5e>
      iunlockput(ip);
    800055f2:	8526                	mv	a0,s1
    800055f4:	a10fe0ef          	jal	80003804 <iunlockput>
      end_op();
    800055f8:	abdfe0ef          	jal	800040b4 <end_op>
      return -1;
    800055fc:	557d                	li	a0,-1
    800055fe:	74aa                	ld	s1,168(sp)
    80005600:	b7c1                	j	800055c0 <sys_open+0xca>
      end_op();
    80005602:	ab3fe0ef          	jal	800040b4 <end_op>
      return -1;
    80005606:	557d                	li	a0,-1
    80005608:	74aa                	ld	s1,168(sp)
    8000560a:	bf5d                	j	800055c0 <sys_open+0xca>
    iunlockput(ip);
    8000560c:	8526                	mv	a0,s1
    8000560e:	9f6fe0ef          	jal	80003804 <iunlockput>
    end_op();
    80005612:	aa3fe0ef          	jal	800040b4 <end_op>
    return -1;
    80005616:	557d                	li	a0,-1
    80005618:	74aa                	ld	s1,168(sp)
    8000561a:	b75d                	j	800055c0 <sys_open+0xca>
      fileclose(f);
    8000561c:	854a                	mv	a0,s2
    8000561e:	ec5fe0ef          	jal	800044e2 <fileclose>
    80005622:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005624:	8526                	mv	a0,s1
    80005626:	9defe0ef          	jal	80003804 <iunlockput>
    end_op();
    8000562a:	a8bfe0ef          	jal	800040b4 <end_op>
    return -1;
    8000562e:	557d                	li	a0,-1
    80005630:	74aa                	ld	s1,168(sp)
    80005632:	790a                	ld	s2,160(sp)
    80005634:	b771                	j	800055c0 <sys_open+0xca>
    f->type = FD_DEVICE;
    80005636:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    8000563a:	04649783          	lh	a5,70(s1)
    8000563e:	02f91223          	sh	a5,36(s2)
    80005642:	bf35                	j	8000557e <sys_open+0x88>
    itrunc(ip);
    80005644:	8526                	mv	a0,s1
    80005646:	858fe0ef          	jal	8000369e <itrunc>
    8000564a:	b795                	j	800055ae <sys_open+0xb8>

000000008000564c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000564c:	7175                	addi	sp,sp,-144
    8000564e:	e506                	sd	ra,136(sp)
    80005650:	e122                	sd	s0,128(sp)
    80005652:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005654:	9d5fe0ef          	jal	80004028 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    80005658:	08000613          	li	a2,128
    8000565c:	f7040593          	addi	a1,s0,-144
    80005660:	4501                	li	a0,0
    80005662:	accfd0ef          	jal	8000292e <argstr>
    80005666:	02054363          	bltz	a0,8000568c <sys_mkdir+0x40>
    8000566a:	4681                	li	a3,0
    8000566c:	4601                	li	a2,0
    8000566e:	4585                	li	a1,1
    80005670:	f7040513          	addi	a0,s0,-144
    80005674:	921ff0ef          	jal	80004f94 <create>
    80005678:	c911                	beqz	a0,8000568c <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000567a:	98afe0ef          	jal	80003804 <iunlockput>
  end_op();
    8000567e:	a37fe0ef          	jal	800040b4 <end_op>
  return 0;
    80005682:	4501                	li	a0,0
}
    80005684:	60aa                	ld	ra,136(sp)
    80005686:	640a                	ld	s0,128(sp)
    80005688:	6149                	addi	sp,sp,144
    8000568a:	8082                	ret
    end_op();
    8000568c:	a29fe0ef          	jal	800040b4 <end_op>
    return -1;
    80005690:	557d                	li	a0,-1
    80005692:	bfcd                	j	80005684 <sys_mkdir+0x38>

0000000080005694 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005694:	7135                	addi	sp,sp,-160
    80005696:	ed06                	sd	ra,152(sp)
    80005698:	e922                	sd	s0,144(sp)
    8000569a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000569c:	98dfe0ef          	jal	80004028 <begin_op>
  argint(1, &major);
    800056a0:	f6c40593          	addi	a1,s0,-148
    800056a4:	4505                	li	a0,1
    800056a6:	a50fd0ef          	jal	800028f6 <argint>
  argint(2, &minor);
    800056aa:	f6840593          	addi	a1,s0,-152
    800056ae:	4509                	li	a0,2
    800056b0:	a46fd0ef          	jal	800028f6 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800056b4:	08000613          	li	a2,128
    800056b8:	f7040593          	addi	a1,s0,-144
    800056bc:	4501                	li	a0,0
    800056be:	a70fd0ef          	jal	8000292e <argstr>
    800056c2:	02054563          	bltz	a0,800056ec <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    800056c6:	f6841683          	lh	a3,-152(s0)
    800056ca:	f6c41603          	lh	a2,-148(s0)
    800056ce:	458d                	li	a1,3
    800056d0:	f7040513          	addi	a0,s0,-144
    800056d4:	8c1ff0ef          	jal	80004f94 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800056d8:	c911                	beqz	a0,800056ec <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800056da:	92afe0ef          	jal	80003804 <iunlockput>
  end_op();
    800056de:	9d7fe0ef          	jal	800040b4 <end_op>
  return 0;
    800056e2:	4501                	li	a0,0
}
    800056e4:	60ea                	ld	ra,152(sp)
    800056e6:	644a                	ld	s0,144(sp)
    800056e8:	610d                	addi	sp,sp,160
    800056ea:	8082                	ret
    end_op();
    800056ec:	9c9fe0ef          	jal	800040b4 <end_op>
    return -1;
    800056f0:	557d                	li	a0,-1
    800056f2:	bfcd                	j	800056e4 <sys_mknod+0x50>

00000000800056f4 <sys_chdir>:

uint64
sys_chdir(void)
{
    800056f4:	7135                	addi	sp,sp,-160
    800056f6:	ed06                	sd	ra,152(sp)
    800056f8:	e922                	sd	s0,144(sp)
    800056fa:	e14a                	sd	s2,128(sp)
    800056fc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800056fe:	a52fc0ef          	jal	80001950 <myproc>
    80005702:	892a                	mv	s2,a0

  begin_op();
    80005704:	925fe0ef          	jal	80004028 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    80005708:	08000613          	li	a2,128
    8000570c:	f6040593          	addi	a1,s0,-160
    80005710:	4501                	li	a0,0
    80005712:	a1cfd0ef          	jal	8000292e <argstr>
    80005716:	04054363          	bltz	a0,8000575c <sys_chdir+0x68>
    8000571a:	e526                	sd	s1,136(sp)
    8000571c:	f6040513          	addi	a0,s0,-160
    80005720:	f2afe0ef          	jal	80003e4a <namei>
    80005724:	84aa                	mv	s1,a0
    80005726:	c915                	beqz	a0,8000575a <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005728:	e89fd0ef          	jal	800035b0 <ilock>
  if (ip->type != T_DIR) {
    8000572c:	04449703          	lh	a4,68(s1)
    80005730:	4785                	li	a5,1
    80005732:	02f71963          	bne	a4,a5,80005764 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005736:	8526                	mv	a0,s1
    80005738:	f27fd0ef          	jal	8000365e <iunlock>
  iput(p->cwd);
    8000573c:	15093503          	ld	a0,336(s2)
    80005740:	ff3fd0ef          	jal	80003732 <iput>
  end_op();
    80005744:	971fe0ef          	jal	800040b4 <end_op>
  p->cwd = ip;
    80005748:	14993823          	sd	s1,336(s2)
  return 0;
    8000574c:	4501                	li	a0,0
    8000574e:	64aa                	ld	s1,136(sp)
}
    80005750:	60ea                	ld	ra,152(sp)
    80005752:	644a                	ld	s0,144(sp)
    80005754:	690a                	ld	s2,128(sp)
    80005756:	610d                	addi	sp,sp,160
    80005758:	8082                	ret
    8000575a:	64aa                	ld	s1,136(sp)
    end_op();
    8000575c:	959fe0ef          	jal	800040b4 <end_op>
    return -1;
    80005760:	557d                	li	a0,-1
    80005762:	b7fd                	j	80005750 <sys_chdir+0x5c>
    iunlockput(ip);
    80005764:	8526                	mv	a0,s1
    80005766:	89efe0ef          	jal	80003804 <iunlockput>
    end_op();
    8000576a:	94bfe0ef          	jal	800040b4 <end_op>
    return -1;
    8000576e:	557d                	li	a0,-1
    80005770:	64aa                	ld	s1,136(sp)
    80005772:	bff9                	j	80005750 <sys_chdir+0x5c>

0000000080005774 <sys_exec>:

uint64
sys_exec(void)
{
    80005774:	7105                	addi	sp,sp,-480
    80005776:	ef86                	sd	ra,472(sp)
    80005778:	eba2                	sd	s0,464(sp)
    8000577a:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000577c:	e2840593          	addi	a1,s0,-472
    80005780:	4505                	li	a0,1
    80005782:	990fd0ef          	jal	80002912 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    80005786:	08000613          	li	a2,128
    8000578a:	f3040593          	addi	a1,s0,-208
    8000578e:	4501                	li	a0,0
    80005790:	99efd0ef          	jal	8000292e <argstr>
    80005794:	87aa                	mv	a5,a0
    return -1;
    80005796:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005798:	0e07c063          	bltz	a5,80005878 <sys_exec+0x104>
    8000579c:	e7a6                	sd	s1,456(sp)
    8000579e:	e3ca                	sd	s2,448(sp)
    800057a0:	ff4e                	sd	s3,440(sp)
    800057a2:	fb52                	sd	s4,432(sp)
    800057a4:	f756                	sd	s5,424(sp)
    800057a6:	f35a                	sd	s6,416(sp)
    800057a8:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800057aa:	e3040a13          	addi	s4,s0,-464
    800057ae:	10000613          	li	a2,256
    800057b2:	4581                	li	a1,0
    800057b4:	8552                	mv	a0,s4
    800057b6:	d32fb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    800057ba:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800057bc:	89d2                	mv	s3,s4
    800057be:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800057c0:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800057c4:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    800057c6:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800057ca:	00391513          	slli	a0,s2,0x3
    800057ce:	85d6                	mv	a1,s5
    800057d0:	e2843783          	ld	a5,-472(s0)
    800057d4:	953e                	add	a0,a0,a5
    800057d6:	894fd0ef          	jal	8000286a <fetchaddr>
    800057da:	02054663          	bltz	a0,80005806 <sys_exec+0x92>
    if (uarg == 0) {
    800057de:	e2043783          	ld	a5,-480(s0)
    800057e2:	c7a1                	beqz	a5,8000582a <sys_exec+0xb6>
    argv[i] = kalloc();
    800057e4:	b6afb0ef          	jal	80000b4e <kalloc>
    800057e8:	85aa                	mv	a1,a0
    800057ea:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    800057ee:	cd01                	beqz	a0,80005806 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800057f0:	865a                	mv	a2,s6
    800057f2:	e2043503          	ld	a0,-480(s0)
    800057f6:	8befd0ef          	jal	800028b4 <fetchstr>
    800057fa:	00054663          	bltz	a0,80005806 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    800057fe:	0905                	addi	s2,s2,1
    80005800:	09a1                	addi	s3,s3,8
    80005802:	fd7914e3          	bne	s2,s7,800057ca <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005806:	100a0a13          	addi	s4,s4,256
    8000580a:	6088                	ld	a0,0(s1)
    8000580c:	cd31                	beqz	a0,80005868 <sys_exec+0xf4>
    kfree(argv[i]);
    8000580e:	a58fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005812:	04a1                	addi	s1,s1,8
    80005814:	ff449be3          	bne	s1,s4,8000580a <sys_exec+0x96>
  return -1;
    80005818:	557d                	li	a0,-1
    8000581a:	64be                	ld	s1,456(sp)
    8000581c:	691e                	ld	s2,448(sp)
    8000581e:	79fa                	ld	s3,440(sp)
    80005820:	7a5a                	ld	s4,432(sp)
    80005822:	7aba                	ld	s5,424(sp)
    80005824:	7b1a                	ld	s6,416(sp)
    80005826:	6bfa                	ld	s7,408(sp)
    80005828:	a881                	j	80005878 <sys_exec+0x104>
      argv[i] = 0;
    8000582a:	0009079b          	sext.w	a5,s2
    8000582e:	e3040593          	addi	a1,s0,-464
    80005832:	078e                	slli	a5,a5,0x3
    80005834:	97ae                	add	a5,a5,a1
    80005836:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000583a:	f3040513          	addi	a0,s0,-208
    8000583e:	b62ff0ef          	jal	80004ba0 <kexec>
    80005842:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005844:	100a0a13          	addi	s4,s4,256
    80005848:	6088                	ld	a0,0(s1)
    8000584a:	c511                	beqz	a0,80005856 <sys_exec+0xe2>
    kfree(argv[i]);
    8000584c:	a1afb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005850:	04a1                	addi	s1,s1,8
    80005852:	ff449be3          	bne	s1,s4,80005848 <sys_exec+0xd4>
  return ret;
    80005856:	854a                	mv	a0,s2
    80005858:	64be                	ld	s1,456(sp)
    8000585a:	691e                	ld	s2,448(sp)
    8000585c:	79fa                	ld	s3,440(sp)
    8000585e:	7a5a                	ld	s4,432(sp)
    80005860:	7aba                	ld	s5,424(sp)
    80005862:	7b1a                	ld	s6,416(sp)
    80005864:	6bfa                	ld	s7,408(sp)
    80005866:	a809                	j	80005878 <sys_exec+0x104>
  return -1;
    80005868:	557d                	li	a0,-1
    8000586a:	64be                	ld	s1,456(sp)
    8000586c:	691e                	ld	s2,448(sp)
    8000586e:	79fa                	ld	s3,440(sp)
    80005870:	7a5a                	ld	s4,432(sp)
    80005872:	7aba                	ld	s5,424(sp)
    80005874:	7b1a                	ld	s6,416(sp)
    80005876:	6bfa                	ld	s7,408(sp)
}
    80005878:	60fe                	ld	ra,472(sp)
    8000587a:	645e                	ld	s0,464(sp)
    8000587c:	613d                	addi	sp,sp,480
    8000587e:	8082                	ret

0000000080005880 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005880:	7139                	addi	sp,sp,-64
    80005882:	fc06                	sd	ra,56(sp)
    80005884:	f822                	sd	s0,48(sp)
    80005886:	f426                	sd	s1,40(sp)
    80005888:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000588a:	8c6fc0ef          	jal	80001950 <myproc>
    8000588e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005890:	fd840593          	addi	a1,s0,-40
    80005894:	4501                	li	a0,0
    80005896:	87cfd0ef          	jal	80002912 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    8000589a:	fc840593          	addi	a1,s0,-56
    8000589e:	fd040513          	addi	a0,s0,-48
    800058a2:	f7ffe0ef          	jal	80004820 <pipealloc>
    return -1;
    800058a6:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    800058a8:	0a054963          	bltz	a0,8000595a <sys_pipe+0xda>
  fd0 = -1;
    800058ac:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    800058b0:	fd043503          	ld	a0,-48(s0)
    800058b4:	ea0ff0ef          	jal	80004f54 <fdalloc>
    800058b8:	fca42223          	sw	a0,-60(s0)
    800058bc:	08054663          	bltz	a0,80005948 <sys_pipe+0xc8>
    800058c0:	fc843503          	ld	a0,-56(s0)
    800058c4:	e90ff0ef          	jal	80004f54 <fdalloc>
    800058c8:	fca42023          	sw	a0,-64(s0)
    800058cc:	06054463          	bltz	a0,80005934 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800058d0:	4711                	li	a4,4
    800058d2:	fc440693          	addi	a3,s0,-60
    800058d6:	fd843603          	ld	a2,-40(s0)
    800058da:	64ac                	ld	a1,72(s1)
    800058dc:	68a8                	ld	a0,80(s1)
    800058de:	cadfb0ef          	jal	8000158a <copyout>
    800058e2:	00054f63          	bltz	a0,80005900 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    800058e6:	4711                	li	a4,4
    800058e8:	fc040693          	addi	a3,s0,-64
    800058ec:	fd843603          	ld	a2,-40(s0)
    800058f0:	963a                	add	a2,a2,a4
    800058f2:	64ac                	ld	a1,72(s1)
    800058f4:	68a8                	ld	a0,80(s1)
    800058f6:	c95fb0ef          	jal	8000158a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800058fa:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800058fc:	04055f63          	bgez	a0,8000595a <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    80005900:	fc442783          	lw	a5,-60(s0)
    80005904:	078e                	slli	a5,a5,0x3
    80005906:	0d078793          	addi	a5,a5,208
    8000590a:	97a6                	add	a5,a5,s1
    8000590c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005910:	fc042783          	lw	a5,-64(s0)
    80005914:	078e                	slli	a5,a5,0x3
    80005916:	0d078793          	addi	a5,a5,208
    8000591a:	94be                	add	s1,s1,a5
    8000591c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005920:	fd043503          	ld	a0,-48(s0)
    80005924:	bbffe0ef          	jal	800044e2 <fileclose>
    fileclose(wf);
    80005928:	fc843503          	ld	a0,-56(s0)
    8000592c:	bb7fe0ef          	jal	800044e2 <fileclose>
    return -1;
    80005930:	57fd                	li	a5,-1
    80005932:	a025                	j	8000595a <sys_pipe+0xda>
    if (fd0 >= 0)
    80005934:	fc442783          	lw	a5,-60(s0)
    80005938:	0007c863          	bltz	a5,80005948 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    8000593c:	078e                	slli	a5,a5,0x3
    8000593e:	0d078793          	addi	a5,a5,208
    80005942:	97a6                	add	a5,a5,s1
    80005944:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005948:	fd043503          	ld	a0,-48(s0)
    8000594c:	b97fe0ef          	jal	800044e2 <fileclose>
    fileclose(wf);
    80005950:	fc843503          	ld	a0,-56(s0)
    80005954:	b8ffe0ef          	jal	800044e2 <fileclose>
    return -1;
    80005958:	57fd                	li	a5,-1
}
    8000595a:	853e                	mv	a0,a5
    8000595c:	70e2                	ld	ra,56(sp)
    8000595e:	7442                	ld	s0,48(sp)
    80005960:	74a2                	ld	s1,40(sp)
    80005962:	6121                	addi	sp,sp,64
    80005964:	8082                	ret
	...

0000000080005970 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005970:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005972:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005974:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005976:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005978:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000597a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000597c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000597e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005980:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005982:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005984:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005986:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005988:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000598a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000598c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000598e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005990:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005992:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005994:	de5fc0ef          	jal	80002778 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005998:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000599a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000599c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000599e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800059a0:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800059a2:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800059a4:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800059a6:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800059a8:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800059aa:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800059ac:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800059ae:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800059b0:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800059b2:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800059b4:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800059b6:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800059b8:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800059ba:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800059bc:	10200073          	sret
    800059c0:	0001                	nop
    800059c2:	00000013          	nop
    800059c6:	00000013          	nop
    800059ca:	00000013          	nop

00000000800059ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800059ce:	1141                	addi	sp,sp,-16
    800059d0:	e406                	sd	ra,8(sp)
    800059d2:	e022                	sd	s0,0(sp)
    800059d4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    800059d6:	0c000737          	lui	a4,0xc000
    800059da:	4785                	li	a5,1
    800059dc:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    800059de:	c35c                	sw	a5,4(a4)
}
    800059e0:	60a2                	ld	ra,8(sp)
    800059e2:	6402                	ld	s0,0(sp)
    800059e4:	0141                	addi	sp,sp,16
    800059e6:	8082                	ret

00000000800059e8 <plicinithart>:

void
plicinithart(void)
{
    800059e8:	1141                	addi	sp,sp,-16
    800059ea:	e406                	sd	ra,8(sp)
    800059ec:	e022                	sd	s0,0(sp)
    800059ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800059f0:	f2dfb0ef          	jal	8000191c <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    800059f4:	0085179b          	slliw	a5,a0,0x8
    800059f8:	0c002737          	lui	a4,0xc002
    800059fc:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    80005a00:	97ba                	add	a5,a5,a4
    80005a02:	40200713          	li	a4,1026
    80005a06:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005a08:	00d5151b          	slliw	a0,a0,0xd
    80005a0c:	0c2017b7          	lui	a5,0xc201
    80005a10:	953e                	add	a0,a0,a5
    80005a12:	00052023          	sw	zero,0(a0)
}
    80005a16:	60a2                	ld	ra,8(sp)
    80005a18:	6402                	ld	s0,0(sp)
    80005a1a:	0141                	addi	sp,sp,16
    80005a1c:	8082                	ret

0000000080005a1e <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005a1e:	1141                	addi	sp,sp,-16
    80005a20:	e406                	sd	ra,8(sp)
    80005a22:	e022                	sd	s0,0(sp)
    80005a24:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005a26:	ef7fb0ef          	jal	8000191c <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    80005a2a:	00d5151b          	slliw	a0,a0,0xd
    80005a2e:	0c2017b7          	lui	a5,0xc201
    80005a32:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80005a34:	953e                	add	a0,a0,a5
    80005a36:	4108                	lw	a0,0(a0)
  return irq;
}
    80005a38:	60a2                	ld	ra,8(sp)
    80005a3a:	6402                	ld	s0,0(sp)
    80005a3c:	0141                	addi	sp,sp,16
    80005a3e:	8082                	ret

0000000080005a40 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005a40:	1101                	addi	sp,sp,-32
    80005a42:	ec06                	sd	ra,24(sp)
    80005a44:	e822                	sd	s0,16(sp)
    80005a46:	e426                	sd	s1,8(sp)
    80005a48:	1000                	addi	s0,sp,32
    80005a4a:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005a4c:	ed1fb0ef          	jal	8000191c <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    80005a50:	00d5179b          	slliw	a5,a0,0xd
    80005a54:	0c201737          	lui	a4,0xc201
    80005a58:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    80005a5a:	97ba                	add	a5,a5,a4
    80005a5c:	c384                	sw	s1,0(a5)
}
    80005a5e:	60e2                	ld	ra,24(sp)
    80005a60:	6442                	ld	s0,16(sp)
    80005a62:	64a2                	ld	s1,8(sp)
    80005a64:	6105                	addi	sp,sp,32
    80005a66:	8082                	ret

0000000080005a68 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005a68:	1141                	addi	sp,sp,-16
    80005a6a:	e406                	sd	ra,8(sp)
    80005a6c:	e022                	sd	s0,0(sp)
    80005a6e:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005a70:	479d                	li	a5,7
    80005a72:	04a7ca63          	blt	a5,a0,80005ac6 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005a76:	0001e797          	auipc	a5,0x1e
    80005a7a:	06a78793          	addi	a5,a5,106 # 80023ae0 <disk>
    80005a7e:	97aa                	add	a5,a5,a0
    80005a80:	0187c783          	lbu	a5,24(a5)
    80005a84:	e7b9                	bnez	a5,80005ad2 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005a86:	00451693          	slli	a3,a0,0x4
    80005a8a:	0001e797          	auipc	a5,0x1e
    80005a8e:	05678793          	addi	a5,a5,86 # 80023ae0 <disk>
    80005a92:	6398                	ld	a4,0(a5)
    80005a94:	9736                	add	a4,a4,a3
    80005a96:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005a9a:	6398                	ld	a4,0(a5)
    80005a9c:	9736                	add	a4,a4,a3
    80005a9e:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005aa2:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005aa6:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005aaa:	97aa                	add	a5,a5,a0
    80005aac:	4705                	li	a4,1
    80005aae:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005ab2:	0001e517          	auipc	a0,0x1e
    80005ab6:	04650513          	addi	a0,a0,70 # 80023af8 <disk+0x18>
    80005aba:	d6afc0ef          	jal	80002024 <wakeup>
}
    80005abe:	60a2                	ld	ra,8(sp)
    80005ac0:	6402                	ld	s0,0(sp)
    80005ac2:	0141                	addi	sp,sp,16
    80005ac4:	8082                	ret
    panic("free_desc 1");
    80005ac6:	00002517          	auipc	a0,0x2
    80005aca:	b7a50513          	addi	a0,a0,-1158 # 80007640 <etext+0x640>
    80005ace:	d67fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    80005ad2:	00002517          	auipc	a0,0x2
    80005ad6:	b7e50513          	addi	a0,a0,-1154 # 80007650 <etext+0x650>
    80005ada:	d5bfa0ef          	jal	80000834 <panic>

0000000080005ade <virtio_disk_init>:
{
    80005ade:	1101                	addi	sp,sp,-32
    80005ae0:	ec06                	sd	ra,24(sp)
    80005ae2:	e822                	sd	s0,16(sp)
    80005ae4:	e426                	sd	s1,8(sp)
    80005ae6:	e04a                	sd	s2,0(sp)
    80005ae8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005aea:	00002597          	auipc	a1,0x2
    80005aee:	b7658593          	addi	a1,a1,-1162 # 80007660 <etext+0x660>
    80005af2:	0001e517          	auipc	a0,0x1e
    80005af6:	11650513          	addi	a0,a0,278 # 80023c08 <disk+0x128>
    80005afa:	8aefb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005afe:	100017b7          	lui	a5,0x10001
    80005b02:	4398                	lw	a4,0(a5)
    80005b04:	2701                	sext.w	a4,a4
    80005b06:	747277b7          	lui	a5,0x74727
    80005b0a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005b0e:	14f71863          	bne	a4,a5,80005c5e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b12:	100017b7          	lui	a5,0x10001
    80005b16:	43dc                	lw	a5,4(a5)
    80005b18:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005b1a:	4709                	li	a4,2
    80005b1c:	14e79163          	bne	a5,a4,80005c5e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b20:	100017b7          	lui	a5,0x10001
    80005b24:	479c                	lw	a5,8(a5)
    80005b26:	2781                	sext.w	a5,a5
    80005b28:	12e79b63          	bne	a5,a4,80005c5e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    80005b2c:	100017b7          	lui	a5,0x10001
    80005b30:	47d8                	lw	a4,12(a5)
    80005b32:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b34:	554d47b7          	lui	a5,0x554d4
    80005b38:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005b3c:	12f71163          	bne	a4,a5,80005c5e <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b40:	100017b7          	lui	a5,0x10001
    80005b44:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b48:	4705                	li	a4,1
    80005b4a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b4c:	470d                	li	a4,3
    80005b4e:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005b50:	10001737          	lui	a4,0x10001
    80005b54:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005b56:	c7ffe6b7          	lui	a3,0xc7ffe
    80005b5a:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fda93f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005b5e:	8f75                	and	a4,a4,a3
    80005b60:	100016b7          	lui	a3,0x10001
    80005b64:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b66:	472d                	li	a4,11
    80005b68:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b6a:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005b6e:	439c                	lw	a5,0(a5)
    80005b70:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005b74:	8ba1                	andi	a5,a5,8
    80005b76:	0e078a63          	beqz	a5,80005c6a <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005b7a:	100017b7          	lui	a5,0x10001
    80005b7e:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005b82:	43fc                	lw	a5,68(a5)
    80005b84:	2781                	sext.w	a5,a5
    80005b86:	0e079863          	bnez	a5,80005c76 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005b8a:	100017b7          	lui	a5,0x10001
    80005b8e:	5bdc                	lw	a5,52(a5)
    80005b90:	2781                	sext.w	a5,a5
  if (max == 0)
    80005b92:	0e078863          	beqz	a5,80005c82 <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005b96:	471d                	li	a4,7
    80005b98:	0ef77b63          	bgeu	a4,a5,80005c8e <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005b9c:	fb3fa0ef          	jal	80000b4e <kalloc>
    80005ba0:	0001e497          	auipc	s1,0x1e
    80005ba4:	f4048493          	addi	s1,s1,-192 # 80023ae0 <disk>
    80005ba8:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005baa:	fa5fa0ef          	jal	80000b4e <kalloc>
    80005bae:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005bb0:	f9ffa0ef          	jal	80000b4e <kalloc>
    80005bb4:	87aa                	mv	a5,a0
    80005bb6:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005bb8:	6088                	ld	a0,0(s1)
    80005bba:	0e050063          	beqz	a0,80005c9a <virtio_disk_init+0x1bc>
    80005bbe:	0001e717          	auipc	a4,0x1e
    80005bc2:	f2a73703          	ld	a4,-214(a4) # 80023ae8 <disk+0x8>
    80005bc6:	cb71                	beqz	a4,80005c9a <virtio_disk_init+0x1bc>
    80005bc8:	cbe9                	beqz	a5,80005c9a <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005bca:	6605                	lui	a2,0x1
    80005bcc:	4581                	li	a1,0
    80005bce:	91afb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005bd2:	0001e497          	auipc	s1,0x1e
    80005bd6:	f0e48493          	addi	s1,s1,-242 # 80023ae0 <disk>
    80005bda:	6605                	lui	a2,0x1
    80005bdc:	4581                	li	a1,0
    80005bde:	6488                	ld	a0,8(s1)
    80005be0:	908fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005be4:	6605                	lui	a2,0x1
    80005be6:	4581                	li	a1,0
    80005be8:	6888                	ld	a0,16(s1)
    80005bea:	8fefb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005bee:	100017b7          	lui	a5,0x10001
    80005bf2:	4721                	li	a4,8
    80005bf4:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005bf6:	4098                	lw	a4,0(s1)
    80005bf8:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005bfc:	40d8                	lw	a4,4(s1)
    80005bfe:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005c02:	649c                	ld	a5,8(s1)
    80005c04:	0007869b          	sext.w	a3,a5
    80005c08:	10001737          	lui	a4,0x10001
    80005c0c:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005c10:	9781                	srai	a5,a5,0x20
    80005c12:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005c16:	689c                	ld	a5,16(s1)
    80005c18:	0007869b          	sext.w	a3,a5
    80005c1c:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005c20:	9781                	srai	a5,a5,0x20
    80005c22:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005c26:	4785                	li	a5,1
    80005c28:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005c2a:	00f48c23          	sb	a5,24(s1)
    80005c2e:	00f48ca3          	sb	a5,25(s1)
    80005c32:	00f48d23          	sb	a5,26(s1)
    80005c36:	00f48da3          	sb	a5,27(s1)
    80005c3a:	00f48e23          	sb	a5,28(s1)
    80005c3e:	00f48ea3          	sb	a5,29(s1)
    80005c42:	00f48f23          	sb	a5,30(s1)
    80005c46:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005c4a:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c4e:	07272823          	sw	s2,112(a4)
}
    80005c52:	60e2                	ld	ra,24(sp)
    80005c54:	6442                	ld	s0,16(sp)
    80005c56:	64a2                	ld	s1,8(sp)
    80005c58:	6902                	ld	s2,0(sp)
    80005c5a:	6105                	addi	sp,sp,32
    80005c5c:	8082                	ret
    panic("could not find virtio disk");
    80005c5e:	00002517          	auipc	a0,0x2
    80005c62:	a1250513          	addi	a0,a0,-1518 # 80007670 <etext+0x670>
    80005c66:	bcffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005c6a:	00002517          	auipc	a0,0x2
    80005c6e:	a2650513          	addi	a0,a0,-1498 # 80007690 <etext+0x690>
    80005c72:	bc3fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005c76:	00002517          	auipc	a0,0x2
    80005c7a:	a3a50513          	addi	a0,a0,-1478 # 800076b0 <etext+0x6b0>
    80005c7e:	bb7fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005c82:	00002517          	auipc	a0,0x2
    80005c86:	a4e50513          	addi	a0,a0,-1458 # 800076d0 <etext+0x6d0>
    80005c8a:	babfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005c8e:	00002517          	auipc	a0,0x2
    80005c92:	a6250513          	addi	a0,a0,-1438 # 800076f0 <etext+0x6f0>
    80005c96:	b9ffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005c9a:	00002517          	auipc	a0,0x2
    80005c9e:	a7650513          	addi	a0,a0,-1418 # 80007710 <etext+0x710>
    80005ca2:	b93fa0ef          	jal	80000834 <panic>

0000000080005ca6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ca6:	711d                	addi	sp,sp,-96
    80005ca8:	ec86                	sd	ra,88(sp)
    80005caa:	e8a2                	sd	s0,80(sp)
    80005cac:	e4a6                	sd	s1,72(sp)
    80005cae:	e0ca                	sd	s2,64(sp)
    80005cb0:	fc4e                	sd	s3,56(sp)
    80005cb2:	f852                	sd	s4,48(sp)
    80005cb4:	f456                	sd	s5,40(sp)
    80005cb6:	f05a                	sd	s6,32(sp)
    80005cb8:	ec5e                	sd	s7,24(sp)
    80005cba:	e862                	sd	s8,16(sp)
    80005cbc:	1080                	addi	s0,sp,96
    80005cbe:	89aa                	mv	s3,a0
    80005cc0:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005cc2:	00c52b83          	lw	s7,12(a0)
    80005cc6:	001b9b9b          	slliw	s7,s7,0x1
    80005cca:	1b82                	slli	s7,s7,0x20
    80005ccc:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005cd0:	0001e517          	auipc	a0,0x1e
    80005cd4:	f3850513          	addi	a0,a0,-200 # 80023c08 <disk+0x128>
    80005cd8:	f51fa0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005cdc:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005cde:	0001ea97          	auipc	s5,0x1e
    80005ce2:	e02a8a93          	addi	s5,s5,-510 # 80023ae0 <disk>
  for (int i = 0; i < 3; i++) {
    80005ce6:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005ce8:	5c7d                	li	s8,-1
    80005cea:	a8a5                	j	80005d62 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005cec:	00fa8733          	add	a4,s5,a5
    80005cf0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005cf4:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005cf6:	0207c563          	bltz	a5,80005d20 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005cfa:	2905                	addiw	s2,s2,1
    80005cfc:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005cfe:	07490663          	beq	s2,s4,80005d6a <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005d02:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005d04:	0001e717          	auipc	a4,0x1e
    80005d08:	ddc70713          	addi	a4,a4,-548 # 80023ae0 <disk>
    80005d0c:	4781                	li	a5,0
    if (disk.free[i]) {
    80005d0e:	01874683          	lbu	a3,24(a4)
    80005d12:	fee9                	bnez	a3,80005cec <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005d14:	2785                	addiw	a5,a5,1
    80005d16:	0705                	addi	a4,a4,1
    80005d18:	fe979be3          	bne	a5,s1,80005d0e <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005d1c:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005d20:	01205d63          	blez	s2,80005d3a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005d24:	fa042503          	lw	a0,-96(s0)
    80005d28:	d41ff0ef          	jal	80005a68 <free_desc>
      for (int j = 0; j < i; j++)
    80005d2c:	4785                	li	a5,1
    80005d2e:	0127d663          	bge	a5,s2,80005d3a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005d32:	fa442503          	lw	a0,-92(s0)
    80005d36:	d33ff0ef          	jal	80005a68 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005d3a:	0001e517          	auipc	a0,0x1e
    80005d3e:	dbe50513          	addi	a0,a0,-578 # 80023af8 <disk+0x18>
    80005d42:	a76fc0ef          	jal	80001fb8 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005d46:	0001e517          	auipc	a0,0x1e
    80005d4a:	ec250513          	addi	a0,a0,-318 # 80023c08 <disk+0x128>
    80005d4e:	f63fa0ef          	jal	80000cb0 <release>
    sleep();
    80005d52:	aa2fc0ef          	jal	80001ff4 <sleep>
    acquire(&disk.vdisk_lock);
    80005d56:	0001e517          	auipc	a0,0x1e
    80005d5a:	eb250513          	addi	a0,a0,-334 # 80023c08 <disk+0x128>
    80005d5e:	ecbfa0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005d62:	fa040613          	addi	a2,s0,-96
    80005d66:	4901                	li	s2,0
    80005d68:	bf69                	j	80005d02 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d6a:	fa042503          	lw	a0,-96(s0)
    80005d6e:	00451693          	slli	a3,a0,0x4

  if (write)
    80005d72:	0001e797          	auipc	a5,0x1e
    80005d76:	d6e78793          	addi	a5,a5,-658 # 80023ae0 <disk>
    80005d7a:	00451713          	slli	a4,a0,0x4
    80005d7e:	0a070713          	addi	a4,a4,160
    80005d82:	973e                	add	a4,a4,a5
    80005d84:	01603633          	snez	a2,s6
    80005d88:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005d8a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005d8e:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005d92:	6398                	ld	a4,0(a5)
    80005d94:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d96:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005d9a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005d9c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005d9e:	6390                	ld	a2,0(a5)
    80005da0:	00d60833          	add	a6,a2,a3
    80005da4:	4741                	li	a4,16
    80005da6:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005daa:	4585                	li	a1,1
    80005dac:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005db0:	fa442703          	lw	a4,-92(s0)
    80005db4:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005db8:	0712                	slli	a4,a4,0x4
    80005dba:	963a                	add	a2,a2,a4
    80005dbc:	05898813          	addi	a6,s3,88
    80005dc0:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005dc4:	0007b883          	ld	a7,0(a5)
    80005dc8:	9746                	add	a4,a4,a7
    80005dca:	40000613          	li	a2,1024
    80005dce:	c710                	sw	a2,8(a4)
  if (write)
    80005dd0:	001b3613          	seqz	a2,s6
    80005dd4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005dd8:	8e4d                	or	a2,a2,a1
    80005dda:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005dde:	fa842603          	lw	a2,-88(s0)
    80005de2:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005de6:	00451813          	slli	a6,a0,0x4
    80005dea:	02080813          	addi	a6,a6,32
    80005dee:	983e                	add	a6,a6,a5
    80005df0:	577d                	li	a4,-1
    80005df2:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005df6:	0612                	slli	a2,a2,0x4
    80005df8:	98b2                	add	a7,a7,a2
    80005dfa:	03068713          	addi	a4,a3,48
    80005dfe:	973e                	add	a4,a4,a5
    80005e00:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005e04:	6398                	ld	a4,0(a5)
    80005e06:	9732                	add	a4,a4,a2
    80005e08:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005e0a:	4689                	li	a3,2
    80005e0c:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005e10:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005e14:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005e18:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005e1c:	6794                	ld	a3,8(a5)
    80005e1e:	0026d703          	lhu	a4,2(a3)
    80005e22:	8b1d                	andi	a4,a4,7
    80005e24:	0706                	slli	a4,a4,0x1
    80005e26:	96ba                	add	a3,a3,a4
    80005e28:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005e2c:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005e30:	6798                	ld	a4,8(a5)
    80005e32:	00275783          	lhu	a5,2(a4)
    80005e36:	2785                	addiw	a5,a5,1
    80005e38:	00f71123          	sh	a5,2(a4)
    80005e3c:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005e40:	100017b7          	lui	a5,0x10001
    80005e44:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005e48:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005e4c:	0001e497          	auipc	s1,0x1e
    80005e50:	dbc48493          	addi	s1,s1,-580 # 80023c08 <disk+0x128>
  while (b->disk == 1) {
    80005e54:	892e                	mv	s2,a1
    80005e56:	02b79163          	bne	a5,a1,80005e78 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005e5a:	854e                	mv	a0,s3
    80005e5c:	95cfc0ef          	jal	80001fb8 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005e60:	8526                	mv	a0,s1
    80005e62:	e4ffa0ef          	jal	80000cb0 <release>
    sleep();
    80005e66:	98efc0ef          	jal	80001ff4 <sleep>
    acquire(&disk.vdisk_lock);
    80005e6a:	8526                	mv	a0,s1
    80005e6c:	dbdfa0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005e70:	0049a783          	lw	a5,4(s3)
    80005e74:	ff2783e3          	beq	a5,s2,80005e5a <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005e78:	fa042903          	lw	s2,-96(s0)
    80005e7c:	00491713          	slli	a4,s2,0x4
    80005e80:	02070713          	addi	a4,a4,32
    80005e84:	0001e797          	auipc	a5,0x1e
    80005e88:	c5c78793          	addi	a5,a5,-932 # 80023ae0 <disk>
    80005e8c:	97ba                	add	a5,a5,a4
    80005e8e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005e92:	0001e997          	auipc	s3,0x1e
    80005e96:	c4e98993          	addi	s3,s3,-946 # 80023ae0 <disk>
    80005e9a:	00491713          	slli	a4,s2,0x4
    80005e9e:	0009b783          	ld	a5,0(s3)
    80005ea2:	97ba                	add	a5,a5,a4
    80005ea4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005ea8:	854a                	mv	a0,s2
    80005eaa:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005eae:	bbbff0ef          	jal	80005a68 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005eb2:	8885                	andi	s1,s1,1
    80005eb4:	f0fd                	bnez	s1,80005e9a <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005eb6:	0001e517          	auipc	a0,0x1e
    80005eba:	d5250513          	addi	a0,a0,-686 # 80023c08 <disk+0x128>
    80005ebe:	df3fa0ef          	jal	80000cb0 <release>
}
    80005ec2:	60e6                	ld	ra,88(sp)
    80005ec4:	6446                	ld	s0,80(sp)
    80005ec6:	64a6                	ld	s1,72(sp)
    80005ec8:	6906                	ld	s2,64(sp)
    80005eca:	79e2                	ld	s3,56(sp)
    80005ecc:	7a42                	ld	s4,48(sp)
    80005ece:	7aa2                	ld	s5,40(sp)
    80005ed0:	7b02                	ld	s6,32(sp)
    80005ed2:	6be2                	ld	s7,24(sp)
    80005ed4:	6c42                	ld	s8,16(sp)
    80005ed6:	6125                	addi	sp,sp,96
    80005ed8:	8082                	ret

0000000080005eda <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005eda:	1101                	addi	sp,sp,-32
    80005edc:	ec06                	sd	ra,24(sp)
    80005ede:	e822                	sd	s0,16(sp)
    80005ee0:	e426                	sd	s1,8(sp)
    80005ee2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005ee4:	0001e497          	auipc	s1,0x1e
    80005ee8:	bfc48493          	addi	s1,s1,-1028 # 80023ae0 <disk>
    80005eec:	0001e517          	auipc	a0,0x1e
    80005ef0:	d1c50513          	addi	a0,a0,-740 # 80023c08 <disk+0x128>
    80005ef4:	d35fa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005ef8:	100017b7          	lui	a5,0x10001
    80005efc:	53bc                	lw	a5,96(a5)
    80005efe:	8b8d                	andi	a5,a5,3
    80005f00:	10001737          	lui	a4,0x10001
    80005f04:	d37c                	sw	a5,100(a4)
    80005f06:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005f0a:	689c                	ld	a5,16(s1)
    80005f0c:	0204d703          	lhu	a4,32(s1)
    80005f10:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005f14:	04f70863          	beq	a4,a5,80005f64 <virtio_disk_intr+0x8a>
    80005f18:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005f1c:	6898                	ld	a4,16(s1)
    80005f1e:	0204d783          	lhu	a5,32(s1)
    80005f22:	8b9d                	andi	a5,a5,7
    80005f24:	078e                	slli	a5,a5,0x3
    80005f26:	97ba                	add	a5,a5,a4
    80005f28:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005f2a:	00479713          	slli	a4,a5,0x4
    80005f2e:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005f32:	9726                	add	a4,a4,s1
    80005f34:	01074703          	lbu	a4,16(a4)
    80005f38:	e329                	bnez	a4,80005f7a <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005f3a:	0792                	slli	a5,a5,0x4
    80005f3c:	02078793          	addi	a5,a5,32
    80005f40:	97a6                	add	a5,a5,s1
    80005f42:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005f44:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005f48:	8dcfc0ef          	jal	80002024 <wakeup>

    disk.used_idx += 1;
    80005f4c:	0204d783          	lhu	a5,32(s1)
    80005f50:	2785                	addiw	a5,a5,1
    80005f52:	17c2                	slli	a5,a5,0x30
    80005f54:	93c1                	srli	a5,a5,0x30
    80005f56:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005f5a:	6898                	ld	a4,16(s1)
    80005f5c:	00275703          	lhu	a4,2(a4)
    80005f60:	faf71ce3          	bne	a4,a5,80005f18 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005f64:	0001e517          	auipc	a0,0x1e
    80005f68:	ca450513          	addi	a0,a0,-860 # 80023c08 <disk+0x128>
    80005f6c:	d45fa0ef          	jal	80000cb0 <release>
}
    80005f70:	60e2                	ld	ra,24(sp)
    80005f72:	6442                	ld	s0,16(sp)
    80005f74:	64a2                	ld	s1,8(sp)
    80005f76:	6105                	addi	sp,sp,32
    80005f78:	8082                	ret
      panic("virtio_disk_intr status");
    80005f7a:	00001517          	auipc	a0,0x1
    80005f7e:	7ae50513          	addi	a0,a0,1966 # 80007728 <etext+0x728>
    80005f82:	8b3fa0ef          	jal	80000834 <panic>
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
