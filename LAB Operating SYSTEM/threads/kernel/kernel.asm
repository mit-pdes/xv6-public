
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
    80000004:	3c813103          	ld	sp,968(sp) # 8000a3c8 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdaee7>
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
    8000011c:	4d4020ef          	jal	800025f0 <either_copyin>
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
    80000198:	27c50513          	addi	a0,a0,636 # 80012410 <cons>
    8000019c:	28d000ef          	jal	80000c28 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	27048493          	addi	s1,s1,624 # 80012410 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	30090913          	addi	s2,s2,768 # 800124a8 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	788010ef          	jal	80001948 <myproc>
    800001c4:	1d2020ef          	jal	80002396 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	76d010ef          	jal	80002138 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	79f010ef          	jal	80002174 <sleep>
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
    800001f2:	22270713          	addi	a4,a4,546 # 80012410 <cons>
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
    80000220:	384020ef          	jal	800025a4 <either_copyout>
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
    8000023c:	1d850513          	addi	a0,a0,472 # 80012410 <cons>
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
    80000262:	24f72523          	sw	a5,586(a4) # 800124a8 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	19c50513          	addi	a0,a0,412 # 80012410 <cons>
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
    800002cc:	14850513          	addi	a0,a0,328 # 80012410 <cons>
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
    800002ea:	352020ef          	jal	8000263c <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	12250513          	addi	a0,a0,290 # 80012410 <cons>
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
    80000310:	10470713          	addi	a4,a4,260 # 80012410 <cons>
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
    80000336:	0de70713          	addi	a4,a4,222 # 80012410 <cons>
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
    80000360:	14c72703          	lw	a4,332(a4) # 800124a8 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	09e70713          	addi	a4,a4,158 # 80012410 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	08e48493          	addi	s1,s1,142 # 80012410 <cons>
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
    800003c8:	04c70713          	addi	a4,a4,76 # 80012410 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	0cf72b23          	sw	a5,214(a4) # 800124b0 <cons+0xa0>
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
    800003fc:	01878793          	addi	a5,a5,24 # 80012410 <cons>
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
    8000041e:	08c7a923          	sw	a2,146(a5) # 800124ac <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	08650513          	addi	a0,a0,134 # 800124a8 <cons+0x98>
    8000042a:	57b010ef          	jal	800021a4 <wakeup>
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
    80000444:	fd050513          	addi	a0,a0,-48 # 80012410 <cons>
    80000448:	760000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	33078793          	addi	a5,a5,816 # 80022780 <devsw>
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
    8000052c:	ebc7a783          	lw	a5,-324(a5) # 8000a3e4 <panicking>
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
    80000572:	f4a50513          	addi	a0,a0,-182 # 800124b8 <pr>
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
    8000076e:	c7a7a783          	lw	a5,-902(a5) # 8000a3e4 <panicking>
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
    80000798:	d2450513          	addi	a0,a0,-732 # 800124b8 <pr>
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
    80000848:	ba97a023          	sw	s1,-1120(a5) # 8000a3e4 <panicking>
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
    8000086a:	b697ad23          	sw	s1,-1158(a5) # 8000a3e0 <panicked>
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
    80000884:	c3850513          	addi	a0,a0,-968 # 800124b8 <pr>
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
    800008da:	bfa50513          	addi	a0,a0,-1030 # 800124d0 <tx_lock>
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
    800008fe:	bd650513          	addi	a0,a0,-1066 # 800124d0 <tx_lock>
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
    8000091c:	ad490913          	addi	s2,s2,-1324 # 8000a3ec <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	ac898993          	addi	s3,s3,-1336 # 8000a3e8 <tx_chan>
      release(&tx_lock);
    80000928:	00012497          	auipc	s1,0x12
    8000092c:	ba848493          	addi	s1,s1,-1112 # 800124d0 <tx_lock>
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
    8000093a:	7fe010ef          	jal	80002138 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	031010ef          	jal	80002174 <sleep>
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
    8000097c:	b5850513          	addi	a0,a0,-1192 # 800124d0 <tx_lock>
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
    800009a0:	a487a783          	lw	a5,-1464(a5) # 8000a3e4 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	a3a7a783          	lw	a5,-1478(a5) # 8000a3e0 <panicked>
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
    800009d0:	a187a783          	lw	a5,-1512(a5) # 8000a3e4 <panicking>
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
    80000a06:	ace50513          	addi	a0,a0,-1330 # 800124d0 <tx_lock>
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
    80000a20:	ab450513          	addi	a0,a0,-1356 # 800124d0 <tx_lock>
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
    80000a48:	9a07a423          	sw	zero,-1624(a5) # 8000a3ec <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	99c50513          	addi	a0,a0,-1636 # 8000a3e8 <tx_chan>
    80000a54:	750010ef          	jal	800021a4 <wakeup>
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
    80000a76:	ea678793          	addi	a5,a5,-346 # 80023918 <end>
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
    80000aa0:	a4c90913          	addi	s2,s2,-1460 # 800124e8 <kmem>
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
    80000b2e:	9be50513          	addi	a0,a0,-1602 # 800124e8 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00023517          	auipc	a0,0x23
    80000b3e:	dde50513          	addi	a0,a0,-546 # 80023918 <end>
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
    80000b5c:	99050513          	addi	a0,a0,-1648 # 800124e8 <kmem>
    80000b60:	0c8000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b64:	00012497          	auipc	s1,0x12
    80000b68:	99c4b483          	ld	s1,-1636(s1) # 80012500 <kmem+0x18>
  if (r)
    80000b6c:	c49d                	beqz	s1,80000b9a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00012717          	auipc	a4,0x12
    80000b74:	98f73823          	sd	a5,-1648(a4) # 80012500 <kmem+0x18>
  release(&kmem.lock);
    80000b78:	00012517          	auipc	a0,0x12
    80000b7c:	97050513          	addi	a0,a0,-1680 # 800124e8 <kmem>
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
    80000b9e:	94e50513          	addi	a0,a0,-1714 # 800124e8 <kmem>
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
    80000eae:	54670713          	addi	a4,a4,1350 # 8000a3f0 <started>
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
    80000ed4:	09b010ef          	jal	8000276e <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	2e1040ef          	jal	800059b8 <plicinithart>
  }

  scheduler();
    80000edc:	0c0010ef          	jal	80001f9c <scheduler>
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
    80000f1c:	02f010ef          	jal	8000274a <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	04f010ef          	jal	8000276e <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	27b040ef          	jal	8000599e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	291040ef          	jal	800059b8 <plicinithart>
    binit();            // buffer cache
    80000f2c:	733010ef          	jal	80002e5e <binit>
    iinit();            // inode table
    80000f30:	484020ef          	jal	800033b4 <iinit>
    fileinit();         // file table
    80000f34:	4b2030ef          	jal	800043e6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	377040ef          	jal	80005aae <virtio_disk_init>
    userinit();         // first user process
    80000f3c:	521000ef          	jal	80001c5c <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f40:	00009797          	auipc	a5,0x9
    80000f44:	4b078793          	addi	a5,a5,1200 # 8000a3f0 <started>
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
    80000f62:	49a7b783          	ld	a5,1178(a5) # 8000a3f8 <kernel_pagetable>
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
    800011ee:	20a7b723          	sd	a0,526(a5) # 8000a3f8 <kernel_pagetable>
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
    80001724:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb6e8>
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
    800017d8:	16448493          	addi	s1,s1,356 # 80012938 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017dc:	8c26                	mv	s8,s1
    800017de:	ff4df937          	lui	s2,0xff4df
    800017e2:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb0a5>
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
    80001808:	d34a8a93          	addi	s5,s5,-716 # 80018538 <tickslock>
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
    8000187e:	c8e50513          	addi	a0,a0,-882 # 80012508 <pid_lock>
    80001882:	b26ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001886:	00006597          	auipc	a1,0x6
    8000188a:	8e258593          	addi	a1,a1,-1822 # 80007168 <etext+0x168>
    8000188e:	00011517          	auipc	a0,0x11
    80001892:	c9250513          	addi	a0,a0,-878 # 80012520 <wait_lock>
    80001896:	b12ff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000189a:	00011497          	auipc	s1,0x11
    8000189e:	09e48493          	addi	s1,s1,158 # 80012938 <proc>
    initlock(&p->lock, "proc");
    800018a2:	00006b17          	auipc	s6,0x6
    800018a6:	8d6b0b13          	addi	s6,s6,-1834 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018aa:	8aa6                	mv	s5,s1
    800018ac:	ff4df937          	lui	s2,0xff4df
    800018b0:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb0a5>
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
    800018d2:	c6aa0a13          	addi	s4,s4,-918 # 80018538 <tickslock>
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
    8000193a:	c0250513          	addi	a0,a0,-1022 # 80012538 <cpus>
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
    80001960:	bac70713          	addi	a4,a4,-1108 # 80012508 <pid_lock>
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
    80001992:	a227a783          	lw	a5,-1502(a5) # 8000a3b0 <first.1>
    80001996:	cf85                	beqz	a5,800019ce <forkret+0x54>
    first = 0;
    80001998:	00009797          	auipc	a5,0x9
    8000199c:	a007ac23          	sw	zero,-1512(a5) # 8000a3b0 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019a0:	4505                	li	a0,1
    800019a2:	717010ef          	jal	800038b8 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019a6:	00005797          	auipc	a5,0x5
    800019aa:	7da78793          	addi	a5,a5,2010 # 80007180 <etext+0x180>
    800019ae:	fcf43823          	sd	a5,-48(s0)
    800019b2:	fc043c23          	sd	zero,-40(s0)
    800019b6:	fd040593          	addi	a1,s0,-48
    800019ba:	853e                	mv	a0,a5
    800019bc:	1b0030ef          	jal	80004b6c <kexec>
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
    800019ce:	5bd000ef          	jal	8000278a <prepare_return>
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
    80001a1e:	aee50513          	addi	a0,a0,-1298 # 80012508 <pid_lock>
    80001a22:	a06ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a26:	00009797          	auipc	a5,0x9
    80001a2a:	98e78793          	addi	a5,a5,-1650 # 8000a3b4 <nextpid>
    80001a2e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a30:	0014871b          	addiw	a4,s1,1
    80001a34:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a36:	00011517          	auipc	a0,0x11
    80001a3a:	ad250513          	addi	a0,a0,-1326 # 80012508 <pid_lock>
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
  if (p->pagetable) {
    80001b30:	68a8                	ld	a0,80(s1)
    80001b32:	cd05                	beqz	a0,80001b6a <freeproc+0x52>
    if (p->is_thread) {
    80001b34:	1684a783          	lw	a5,360(s1)
    80001b38:	cbad                	beqz	a5,80001baa <freeproc+0x92>
      if (p->sz > 0)
    80001b3a:	64b0                	ld	a2,72(s1)
    80001b3c:	ee31                	bnez	a2,80001b98 <freeproc+0x80>
      uvmunmap(p->pagetable, TRAMPOLINE, 1, 0);
    80001b3e:	4681                	li	a3,0
    80001b40:	4605                	li	a2,1
    80001b42:	040005b7          	lui	a1,0x4000
    80001b46:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b48:	05b2                	slli	a1,a1,0xc
    80001b4a:	68a8                	ld	a0,80(s1)
    80001b4c:	ed4ff0ef          	jal	80001220 <uvmunmap>
      uvmunmap(p->pagetable, TRAPFRAME, 1, 0);
    80001b50:	4681                	li	a3,0
    80001b52:	4605                	li	a2,1
    80001b54:	020005b7          	lui	a1,0x2000
    80001b58:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b5a:	05b6                	slli	a1,a1,0xd
    80001b5c:	68a8                	ld	a0,80(s1)
    80001b5e:	ec2ff0ef          	jal	80001220 <uvmunmap>
      uvmfree(p->pagetable, 0);
    80001b62:	4581                	li	a1,0
    80001b64:	68a8                	ld	a0,80(s1)
    80001b66:	88fff0ef          	jal	800013f4 <uvmfree>
  p->pagetable = 0;
    80001b6a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b6e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b72:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001b76:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b7a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b7e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b82:	0204a623          	sw	zero,44(s1)
  p->is_thread = 0;
    80001b86:	1604a423          	sw	zero,360(s1)
  p->state = UNUSED;
    80001b8a:	0004ac23          	sw	zero,24(s1)
}
    80001b8e:	60e2                	ld	ra,24(sp)
    80001b90:	6442                	ld	s0,16(sp)
    80001b92:	64a2                	ld	s1,8(sp)
    80001b94:	6105                	addi	sp,sp,32
    80001b96:	8082                	ret
        uvmunmap(p->pagetable, 0, PGROUNDUP(p->sz) / PGSIZE, 0);
    80001b98:	6785                	lui	a5,0x1
    80001b9a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001b9c:	963e                	add	a2,a2,a5
    80001b9e:	4681                	li	a3,0
    80001ba0:	8231                	srli	a2,a2,0xc
    80001ba2:	4581                	li	a1,0
    80001ba4:	e7cff0ef          	jal	80001220 <uvmunmap>
    80001ba8:	bf59                	j	80001b3e <freeproc+0x26>
      proc_freepagetable(p->pagetable, p->sz);
    80001baa:	64ac                	ld	a1,72(s1)
    80001bac:	f27ff0ef          	jal	80001ad2 <proc_freepagetable>
    80001bb0:	bf6d                	j	80001b6a <freeproc+0x52>

0000000080001bb2 <allocproc>:
{
    80001bb2:	1101                	addi	sp,sp,-32
    80001bb4:	ec06                	sd	ra,24(sp)
    80001bb6:	e822                	sd	s0,16(sp)
    80001bb8:	e426                	sd	s1,8(sp)
    80001bba:	e04a                	sd	s2,0(sp)
    80001bbc:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bbe:	00011497          	auipc	s1,0x11
    80001bc2:	d7a48493          	addi	s1,s1,-646 # 80012938 <proc>
    80001bc6:	00017917          	auipc	s2,0x17
    80001bca:	97290913          	addi	s2,s2,-1678 # 80018538 <tickslock>
    acquire(&p->lock);
    80001bce:	8526                	mv	a0,s1
    80001bd0:	858ff0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001bd4:	4c9c                	lw	a5,24(s1)
    80001bd6:	cb91                	beqz	a5,80001bea <allocproc+0x38>
      release(&p->lock);
    80001bd8:	8526                	mv	a0,s1
    80001bda:	8d6ff0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bde:	17048493          	addi	s1,s1,368
    80001be2:	ff2496e3          	bne	s1,s2,80001bce <allocproc+0x1c>
  return 0;
    80001be6:	4481                	li	s1,0
    80001be8:	a099                	j	80001c2e <allocproc+0x7c>
  p->pid = allocpid();
    80001bea:	e27ff0ef          	jal	80001a10 <allocpid>
    80001bee:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bf0:	4785                	li	a5,1
    80001bf2:	cc9c                	sw	a5,24(s1)
  p->is_thread = 0;
    80001bf4:	1604a423          	sw	zero,360(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bf8:	f57fe0ef          	jal	80000b4e <kalloc>
    80001bfc:	892a                	mv	s2,a0
    80001bfe:	eca8                	sd	a0,88(s1)
    80001c00:	cd15                	beqz	a0,80001c3c <allocproc+0x8a>
  p->pagetable = proc_pagetable(p);
    80001c02:	8526                	mv	a0,s1
    80001c04:	e4bff0ef          	jal	80001a4e <proc_pagetable>
    80001c08:	892a                	mv	s2,a0
    80001c0a:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001c0c:	c121                	beqz	a0,80001c4c <allocproc+0x9a>
  memset(&p->context, 0, sizeof(p->context));
    80001c0e:	07000613          	li	a2,112
    80001c12:	4581                	li	a1,0
    80001c14:	06048513          	addi	a0,s1,96
    80001c18:	8d0ff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001c1c:	00000797          	auipc	a5,0x0
    80001c20:	d5e78793          	addi	a5,a5,-674 # 8000197a <forkret>
    80001c24:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c26:	60bc                	ld	a5,64(s1)
    80001c28:	6705                	lui	a4,0x1
    80001c2a:	97ba                	add	a5,a5,a4
    80001c2c:	f4bc                	sd	a5,104(s1)
}
    80001c2e:	8526                	mv	a0,s1
    80001c30:	60e2                	ld	ra,24(sp)
    80001c32:	6442                	ld	s0,16(sp)
    80001c34:	64a2                	ld	s1,8(sp)
    80001c36:	6902                	ld	s2,0(sp)
    80001c38:	6105                	addi	sp,sp,32
    80001c3a:	8082                	ret
    freeproc(p);
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	edbff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001c42:	8526                	mv	a0,s1
    80001c44:	86cff0ef          	jal	80000cb0 <release>
    return 0;
    80001c48:	84ca                	mv	s1,s2
    80001c4a:	b7d5                	j	80001c2e <allocproc+0x7c>
    freeproc(p);
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	ecbff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001c52:	8526                	mv	a0,s1
    80001c54:	85cff0ef          	jal	80000cb0 <release>
    return 0;
    80001c58:	84ca                	mv	s1,s2
    80001c5a:	bfd1                	j	80001c2e <allocproc+0x7c>

0000000080001c5c <userinit>:
{
    80001c5c:	1101                	addi	sp,sp,-32
    80001c5e:	ec06                	sd	ra,24(sp)
    80001c60:	e822                	sd	s0,16(sp)
    80001c62:	e426                	sd	s1,8(sp)
    80001c64:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c66:	f4dff0ef          	jal	80001bb2 <allocproc>
    80001c6a:	84aa                	mv	s1,a0
  initproc = p;
    80001c6c:	00008797          	auipc	a5,0x8
    80001c70:	78a7ba23          	sd	a0,1940(a5) # 8000a400 <initproc>
  p->cwd = namei("/");
    80001c74:	00005517          	auipc	a0,0x5
    80001c78:	51c50513          	addi	a0,a0,1308 # 80007190 <etext+0x190>
    80001c7c:	19a020ef          	jal	80003e16 <namei>
    80001c80:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c84:	478d                	li	a5,3
    80001c86:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c88:	8526                	mv	a0,s1
    80001c8a:	826ff0ef          	jal	80000cb0 <release>
}
    80001c8e:	60e2                	ld	ra,24(sp)
    80001c90:	6442                	ld	s0,16(sp)
    80001c92:	64a2                	ld	s1,8(sp)
    80001c94:	6105                	addi	sp,sp,32
    80001c96:	8082                	ret

0000000080001c98 <growproc>:
{
    80001c98:	1101                	addi	sp,sp,-32
    80001c9a:	ec06                	sd	ra,24(sp)
    80001c9c:	e822                	sd	s0,16(sp)
    80001c9e:	e426                	sd	s1,8(sp)
    80001ca0:	e04a                	sd	s2,0(sp)
    80001ca2:	1000                	addi	s0,sp,32
    80001ca4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ca6:	ca3ff0ef          	jal	80001948 <myproc>
    80001caa:	892a                	mv	s2,a0
  sz = p->sz;
    80001cac:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001cae:	02905963          	blez	s1,80001ce0 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001cb2:	00b48633          	add	a2,s1,a1
    80001cb6:	020007b7          	lui	a5,0x2000
    80001cba:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001cbc:	07b6                	slli	a5,a5,0xd
    80001cbe:	02c7ea63          	bltu	a5,a2,80001cf2 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001cc2:	4691                	li	a3,4
    80001cc4:	6928                	ld	a0,80(a0)
    80001cc6:	e28ff0ef          	jal	800012ee <uvmalloc>
    80001cca:	85aa                	mv	a1,a0
    80001ccc:	c50d                	beqz	a0,80001cf6 <growproc+0x5e>
  p->sz = sz;
    80001cce:	04b93423          	sd	a1,72(s2)
  return 0;
    80001cd2:	4501                	li	a0,0
}
    80001cd4:	60e2                	ld	ra,24(sp)
    80001cd6:	6442                	ld	s0,16(sp)
    80001cd8:	64a2                	ld	s1,8(sp)
    80001cda:	6902                	ld	s2,0(sp)
    80001cdc:	6105                	addi	sp,sp,32
    80001cde:	8082                	ret
  } else if (n < 0) {
    80001ce0:	fe04d7e3          	bgez	s1,80001cce <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ce4:	00b48633          	add	a2,s1,a1
    80001ce8:	6928                	ld	a0,80(a0)
    80001cea:	dc0ff0ef          	jal	800012aa <uvmdealloc>
    80001cee:	85aa                	mv	a1,a0
    80001cf0:	bff9                	j	80001cce <growproc+0x36>
      return -1;
    80001cf2:	557d                	li	a0,-1
    80001cf4:	b7c5                	j	80001cd4 <growproc+0x3c>
      return -1;
    80001cf6:	557d                	li	a0,-1
    80001cf8:	bff1                	j	80001cd4 <growproc+0x3c>

0000000080001cfa <kfork>:
{
    80001cfa:	7139                	addi	sp,sp,-64
    80001cfc:	fc06                	sd	ra,56(sp)
    80001cfe:	f822                	sd	s0,48(sp)
    80001d00:	f426                	sd	s1,40(sp)
    80001d02:	e456                	sd	s5,8(sp)
    80001d04:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d06:	c43ff0ef          	jal	80001948 <myproc>
    80001d0a:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001d0c:	ea7ff0ef          	jal	80001bb2 <allocproc>
    80001d10:	0e050a63          	beqz	a0,80001e04 <kfork+0x10a>
    80001d14:	e852                	sd	s4,16(sp)
    80001d16:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001d18:	048ab603          	ld	a2,72(s5)
    80001d1c:	692c                	ld	a1,80(a0)
    80001d1e:	050ab503          	ld	a0,80(s5)
    80001d22:	f04ff0ef          	jal	80001426 <uvmcopy>
    80001d26:	04054863          	bltz	a0,80001d76 <kfork+0x7c>
    80001d2a:	f04a                	sd	s2,32(sp)
    80001d2c:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d2e:	048ab783          	ld	a5,72(s5)
    80001d32:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d36:	058ab683          	ld	a3,88(s5)
    80001d3a:	87b6                	mv	a5,a3
    80001d3c:	058a3703          	ld	a4,88(s4)
    80001d40:	12068693          	addi	a3,a3,288
    80001d44:	6388                	ld	a0,0(a5)
    80001d46:	678c                	ld	a1,8(a5)
    80001d48:	6b90                	ld	a2,16(a5)
    80001d4a:	e308                	sd	a0,0(a4)
    80001d4c:	e70c                	sd	a1,8(a4)
    80001d4e:	eb10                	sd	a2,16(a4)
    80001d50:	6f90                	ld	a2,24(a5)
    80001d52:	ef10                	sd	a2,24(a4)
    80001d54:	02078793          	addi	a5,a5,32
    80001d58:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d5c:	fed794e3          	bne	a5,a3,80001d44 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d60:	058a3783          	ld	a5,88(s4)
    80001d64:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d68:	0d0a8493          	addi	s1,s5,208
    80001d6c:	0d0a0913          	addi	s2,s4,208
    80001d70:	150a8993          	addi	s3,s5,336
    80001d74:	a831                	j	80001d90 <kfork+0x96>
    freeproc(np);
    80001d76:	8552                	mv	a0,s4
    80001d78:	da1ff0ef          	jal	80001b18 <freeproc>
    release(&np->lock);
    80001d7c:	8552                	mv	a0,s4
    80001d7e:	f33fe0ef          	jal	80000cb0 <release>
    return -1;
    80001d82:	54fd                	li	s1,-1
    80001d84:	6a42                	ld	s4,16(sp)
    80001d86:	a885                	j	80001df6 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d88:	04a1                	addi	s1,s1,8
    80001d8a:	0921                	addi	s2,s2,8
    80001d8c:	01348963          	beq	s1,s3,80001d9e <kfork+0xa4>
    if (p->ofile[i])
    80001d90:	6088                	ld	a0,0(s1)
    80001d92:	d97d                	beqz	a0,80001d88 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d94:	6d4020ef          	jal	80004468 <filedup>
    80001d98:	00a93023          	sd	a0,0(s2)
    80001d9c:	b7f5                	j	80001d88 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d9e:	150ab503          	ld	a0,336(s5)
    80001da2:	7a4010ef          	jal	80003546 <idup>
    80001da6:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001daa:	4641                	li	a2,16
    80001dac:	158a8593          	addi	a1,s5,344
    80001db0:	158a0513          	addi	a0,s4,344
    80001db4:	888ff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001db8:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001dbc:	8552                	mv	a0,s4
    80001dbe:	ef3fe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001dc2:	00010517          	auipc	a0,0x10
    80001dc6:	75e50513          	addi	a0,a0,1886 # 80012520 <wait_lock>
    80001dca:	e5ffe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001dce:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001dd2:	00010517          	auipc	a0,0x10
    80001dd6:	74e50513          	addi	a0,a0,1870 # 80012520 <wait_lock>
    80001dda:	ed7fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001dde:	8552                	mv	a0,s4
    80001de0:	e49fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001de4:	478d                	li	a5,3
    80001de6:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001dea:	8552                	mv	a0,s4
    80001dec:	ec5fe0ef          	jal	80000cb0 <release>
  return pid;
    80001df0:	7902                	ld	s2,32(sp)
    80001df2:	69e2                	ld	s3,24(sp)
    80001df4:	6a42                	ld	s4,16(sp)
}
    80001df6:	8526                	mv	a0,s1
    80001df8:	70e2                	ld	ra,56(sp)
    80001dfa:	7442                	ld	s0,48(sp)
    80001dfc:	74a2                	ld	s1,40(sp)
    80001dfe:	6aa2                	ld	s5,8(sp)
    80001e00:	6121                	addi	sp,sp,64
    80001e02:	8082                	ret
    return -1;
    80001e04:	54fd                	li	s1,-1
    80001e06:	bfc5                	j	80001df6 <kfork+0xfc>

0000000080001e08 <kclone>:
{
    80001e08:	711d                	addi	sp,sp,-96
    80001e0a:	ec86                	sd	ra,88(sp)
    80001e0c:	e8a2                	sd	s0,80(sp)
    80001e0e:	e4a6                	sd	s1,72(sp)
    80001e10:	f05a                	sd	s6,32(sp)
    80001e12:	e862                	sd	s8,16(sp)
    80001e14:	e466                	sd	s9,8(sp)
    80001e16:	e06a                	sd	s10,0(sp)
    80001e18:	1080                	addi	s0,sp,96
    80001e1a:	8c2a                	mv	s8,a0
    80001e1c:	8cae                	mv	s9,a1
    80001e1e:	8d32                	mv	s10,a2
  struct proc *p = myproc();
    80001e20:	b29ff0ef          	jal	80001948 <myproc>
    80001e24:	8b2a                	mv	s6,a0
  if ((np = allocproc()) == 0) {
    80001e26:	d8dff0ef          	jal	80001bb2 <allocproc>
    80001e2a:	16050763          	beqz	a0,80001f98 <kclone+0x190>
    80001e2e:	e0ca                	sd	s2,64(sp)
    80001e30:	fc4e                	sd	s3,56(sp)
    80001e32:	f852                	sd	s4,48(sp)
    80001e34:	89aa                	mv	s3,a0
  if (uvmshare(p->pagetable, np->pagetable, p->sz) < 0) {
    80001e36:	048b3a03          	ld	s4,72(s6)
  for (i = 0; i < sz; i += PGSIZE) {
    80001e3a:	060a0963          	beqz	s4,80001eac <kclone+0xa4>
    80001e3e:	f456                	sd	s5,40(sp)
    80001e40:	ec5e                	sd	s7,24(sp)
  if (uvmshare(p->pagetable, np->pagetable, p->sz) < 0) {
    80001e42:	050b3a83          	ld	s5,80(s6)
    80001e46:	05053b83          	ld	s7,80(a0)
  for (i = 0; i < sz; i += PGSIZE) {
    80001e4a:	4481                	li	s1,0
    if (mappages(new, i, PGSIZE, pa, flags) != 0) {
    80001e4c:	6905                	lui	s2,0x1
    80001e4e:	a021                	j	80001e56 <kclone+0x4e>
  for (i = 0; i < sz; i += PGSIZE) {
    80001e50:	94ca                	add	s1,s1,s2
    80001e52:	0544fb63          	bgeu	s1,s4,80001ea8 <kclone+0xa0>
    if ((pte = walk(old, i, 0)) == 0)
    80001e56:	4601                	li	a2,0
    80001e58:	85a6                	mv	a1,s1
    80001e5a:	8556                	mv	a0,s5
    80001e5c:	922ff0ef          	jal	80000f7e <walk>
    80001e60:	d965                	beqz	a0,80001e50 <kclone+0x48>
    if ((*pte & PTE_V) == 0)
    80001e62:	6118                	ld	a4,0(a0)
    80001e64:	00177793          	andi	a5,a4,1
    80001e68:	d7e5                	beqz	a5,80001e50 <kclone+0x48>
    pa = PTE2PA(*pte);
    80001e6a:	00a75693          	srli	a3,a4,0xa
    if (mappages(new, i, PGSIZE, pa, flags) != 0) {
    80001e6e:	3ff77713          	andi	a4,a4,1023
    80001e72:	06b2                	slli	a3,a3,0xc
    80001e74:	864a                	mv	a2,s2
    80001e76:	85a6                	mv	a1,s1
    80001e78:	855e                	mv	a0,s7
    80001e7a:	9d8ff0ef          	jal	80001052 <mappages>
    80001e7e:	d969                	beqz	a0,80001e50 <kclone+0x48>
      uvmunmap(new, 0, i / PGSIZE, 0);
    80001e80:	4681                	li	a3,0
    80001e82:	00c4d613          	srli	a2,s1,0xc
    80001e86:	4581                	li	a1,0
    80001e88:	855e                	mv	a0,s7
    80001e8a:	b96ff0ef          	jal	80001220 <uvmunmap>
    freeproc(np);
    80001e8e:	854e                	mv	a0,s3
    80001e90:	c89ff0ef          	jal	80001b18 <freeproc>
    release(&np->lock);
    80001e94:	854e                	mv	a0,s3
    80001e96:	e1bfe0ef          	jal	80000cb0 <release>
    return -1;
    80001e9a:	54fd                	li	s1,-1
    80001e9c:	6906                	ld	s2,64(sp)
    80001e9e:	79e2                	ld	s3,56(sp)
    80001ea0:	7a42                	ld	s4,48(sp)
    80001ea2:	7aa2                	ld	s5,40(sp)
    80001ea4:	6be2                	ld	s7,24(sp)
    80001ea6:	a8f9                	j	80001f84 <kclone+0x17c>
    80001ea8:	7aa2                	ld	s5,40(sp)
    80001eaa:	6be2                	ld	s7,24(sp)
  np->sz = p->sz;
    80001eac:	048b3783          	ld	a5,72(s6)
    80001eb0:	04f9b423          	sd	a5,72(s3)
  np->is_thread = 1;
    80001eb4:	4785                	li	a5,1
    80001eb6:	16f9a423          	sw	a5,360(s3)
  *(np->trapframe) = *(p->trapframe);
    80001eba:	058b3683          	ld	a3,88(s6)
    80001ebe:	87b6                	mv	a5,a3
    80001ec0:	0589b703          	ld	a4,88(s3)
    80001ec4:	12068693          	addi	a3,a3,288
    80001ec8:	6388                	ld	a0,0(a5)
    80001eca:	678c                	ld	a1,8(a5)
    80001ecc:	6b90                	ld	a2,16(a5)
    80001ece:	e308                	sd	a0,0(a4)
    80001ed0:	e70c                	sd	a1,8(a4)
    80001ed2:	eb10                	sd	a2,16(a4)
    80001ed4:	6f90                	ld	a2,24(a5)
    80001ed6:	ef10                	sd	a2,24(a4)
    80001ed8:	02078793          	addi	a5,a5,32
    80001edc:	02070713          	addi	a4,a4,32
    80001ee0:	fed794e3          	bne	a5,a3,80001ec8 <kclone+0xc0>
  np->trapframe->epc = fcn;
    80001ee4:	0589b783          	ld	a5,88(s3)
    80001ee8:	0187bc23          	sd	s8,24(a5)
  np->trapframe->a0 = arg;
    80001eec:	0589b783          	ld	a5,88(s3)
    80001ef0:	0797b823          	sd	s9,112(a5)
  np->trapframe->sp = stack + PGSIZE;
    80001ef4:	0589b703          	ld	a4,88(s3)
    80001ef8:	6785                	lui	a5,0x1
    80001efa:	97ea                	add	a5,a5,s10
    80001efc:	fb1c                	sd	a5,48(a4)
  np->trapframe->sp -= (np->trapframe->sp % 16); // 16-byte alignment
    80001efe:	0589b703          	ld	a4,88(s3)
    80001f02:	7b1c                	ld	a5,48(a4)
    80001f04:	9bc1                	andi	a5,a5,-16
    80001f06:	fb1c                	sd	a5,48(a4)
  for (i = 0; i < NOFILE; i++)
    80001f08:	0d0b0493          	addi	s1,s6,208
    80001f0c:	0d098913          	addi	s2,s3,208
    80001f10:	150b0a13          	addi	s4,s6,336
    80001f14:	a029                	j	80001f1e <kclone+0x116>
    80001f16:	04a1                	addi	s1,s1,8
    80001f18:	0921                	addi	s2,s2,8 # 1008 <_entry-0x7fffeff8>
    80001f1a:	01448963          	beq	s1,s4,80001f2c <kclone+0x124>
    if (p->ofile[i])
    80001f1e:	6088                	ld	a0,0(s1)
    80001f20:	d97d                	beqz	a0,80001f16 <kclone+0x10e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f22:	546020ef          	jal	80004468 <filedup>
    80001f26:	00a93023          	sd	a0,0(s2)
    80001f2a:	b7f5                	j	80001f16 <kclone+0x10e>
  np->cwd = idup(p->cwd);
    80001f2c:	150b3503          	ld	a0,336(s6)
    80001f30:	616010ef          	jal	80003546 <idup>
    80001f34:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f38:	4641                	li	a2,16
    80001f3a:	158b0593          	addi	a1,s6,344
    80001f3e:	15898513          	addi	a0,s3,344
    80001f42:	efbfe0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001f46:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    80001f4a:	854e                	mv	a0,s3
    80001f4c:	d65fe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001f50:	00010517          	auipc	a0,0x10
    80001f54:	5d050513          	addi	a0,a0,1488 # 80012520 <wait_lock>
    80001f58:	cd1fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001f5c:	0369bc23          	sd	s6,56(s3)
  release(&wait_lock);
    80001f60:	00010517          	auipc	a0,0x10
    80001f64:	5c050513          	addi	a0,a0,1472 # 80012520 <wait_lock>
    80001f68:	d49fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001f6c:	854e                	mv	a0,s3
    80001f6e:	cbbfe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001f72:	478d                	li	a5,3
    80001f74:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f78:	854e                	mv	a0,s3
    80001f7a:	d37fe0ef          	jal	80000cb0 <release>
  return pid;
    80001f7e:	6906                	ld	s2,64(sp)
    80001f80:	79e2                	ld	s3,56(sp)
    80001f82:	7a42                	ld	s4,48(sp)
}
    80001f84:	8526                	mv	a0,s1
    80001f86:	60e6                	ld	ra,88(sp)
    80001f88:	6446                	ld	s0,80(sp)
    80001f8a:	64a6                	ld	s1,72(sp)
    80001f8c:	7b02                	ld	s6,32(sp)
    80001f8e:	6c42                	ld	s8,16(sp)
    80001f90:	6ca2                	ld	s9,8(sp)
    80001f92:	6d02                	ld	s10,0(sp)
    80001f94:	6125                	addi	sp,sp,96
    80001f96:	8082                	ret
    return -1;
    80001f98:	54fd                	li	s1,-1
    80001f9a:	b7ed                	j	80001f84 <kclone+0x17c>

0000000080001f9c <scheduler>:
{
    80001f9c:	711d                	addi	sp,sp,-96
    80001f9e:	ec86                	sd	ra,88(sp)
    80001fa0:	e8a2                	sd	s0,80(sp)
    80001fa2:	e4a6                	sd	s1,72(sp)
    80001fa4:	e0ca                	sd	s2,64(sp)
    80001fa6:	fc4e                	sd	s3,56(sp)
    80001fa8:	f852                	sd	s4,48(sp)
    80001faa:	f456                	sd	s5,40(sp)
    80001fac:	f05a                	sd	s6,32(sp)
    80001fae:	ec5e                	sd	s7,24(sp)
    80001fb0:	e862                	sd	s8,16(sp)
    80001fb2:	e466                	sd	s9,8(sp)
    80001fb4:	1080                	addi	s0,sp,96
    80001fb6:	8792                	mv	a5,tp
  int id = r_tp();
    80001fb8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fba:	00779a93          	slli	s5,a5,0x7
    80001fbe:	00010717          	auipc	a4,0x10
    80001fc2:	54a70713          	addi	a4,a4,1354 # 80012508 <pid_lock>
    80001fc6:	9756                	add	a4,a4,s5
    80001fc8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001fcc:	00010717          	auipc	a4,0x10
    80001fd0:	57470713          	addi	a4,a4,1396 # 80012540 <cpus+0x8>
    80001fd4:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001fd6:	4c11                	li	s8,4
        c->proc = p;
    80001fd8:	00010b17          	auipc	s6,0x10
    80001fdc:	530b0b13          	addi	s6,s6,1328 # 80012508 <pid_lock>
    80001fe0:	079e                	slli	a5,a5,0x7
    80001fe2:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001fe6:	4b85                	li	s7,1
    80001fe8:	a0a9                	j	80002032 <scheduler+0x96>
      release(&p->lock);
    80001fea:	8526                	mv	a0,s1
    80001fec:	cc5fe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001ff0:	17048493          	addi	s1,s1,368
    80001ff4:	03248b63          	beq	s1,s2,8000202a <scheduler+0x8e>
      acquire(&p->lock);
    80001ff8:	8526                	mv	a0,s1
    80001ffa:	c2ffe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001ffe:	4c9c                	lw	a5,24(s1)
    80002000:	ff3795e3          	bne	a5,s3,80001fea <scheduler+0x4e>
        p->state = RUNNING;
    80002004:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80002008:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000200c:	06048593          	addi	a1,s1,96
    80002010:	8556                	mv	a0,s5
    80002012:	6ce000ef          	jal	800026e0 <swtch>
    80002016:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80002018:	2781                	sext.w	a5,a5
    8000201a:	079e                	slli	a5,a5,0x7
    8000201c:	97da                	add	a5,a5,s6
    8000201e:	0a07a623          	sw	zero,172(a5) # 10ac <_entry-0x7fffef54>
        c->proc = 0;
    80002022:	020a3823          	sd	zero,48(s4)
        found = 1;
    80002026:	8cde                	mv	s9,s7
    80002028:	b7c9                	j	80001fea <scheduler+0x4e>
    if (found == 0) {
    8000202a:	000c9463          	bnez	s9,80002032 <scheduler+0x96>
      asm volatile("wfi");
    8000202e:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002032:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002036:	10017073          	csrci	sstatus,2
    int found = 0;
    8000203a:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    8000203c:	00011497          	auipc	s1,0x11
    80002040:	8fc48493          	addi	s1,s1,-1796 # 80012938 <proc>
      if (p->state == RUNNABLE) {
    80002044:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80002046:	00016917          	auipc	s2,0x16
    8000204a:	4f290913          	addi	s2,s2,1266 # 80018538 <tickslock>
    8000204e:	b76d                	j	80001ff8 <scheduler+0x5c>

0000000080002050 <sched>:
{
    80002050:	7179                	addi	sp,sp,-48
    80002052:	f406                	sd	ra,40(sp)
    80002054:	f022                	sd	s0,32(sp)
    80002056:	ec26                	sd	s1,24(sp)
    80002058:	e84a                	sd	s2,16(sp)
    8000205a:	e44e                	sd	s3,8(sp)
    8000205c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000205e:	8ebff0ef          	jal	80001948 <myproc>
    80002062:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002064:	b5ffe0ef          	jal	80000bc2 <holding>
    80002068:	c935                	beqz	a0,800020dc <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    8000206a:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000206c:	2781                	sext.w	a5,a5
    8000206e:	079e                	slli	a5,a5,0x7
    80002070:	00010717          	auipc	a4,0x10
    80002074:	49870713          	addi	a4,a4,1176 # 80012508 <pid_lock>
    80002078:	97ba                	add	a5,a5,a4
    8000207a:	0a87a703          	lw	a4,168(a5)
    8000207e:	4785                	li	a5,1
    80002080:	06f71463          	bne	a4,a5,800020e8 <sched+0x98>
  if (p->state == RUNNING)
    80002084:	4c98                	lw	a4,24(s1)
    80002086:	4791                	li	a5,4
    80002088:	06f70663          	beq	a4,a5,800020f4 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000208c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002090:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002092:	e7bd                	bnez	a5,80002100 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80002094:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002096:	00010917          	auipc	s2,0x10
    8000209a:	47290913          	addi	s2,s2,1138 # 80012508 <pid_lock>
    8000209e:	2781                	sext.w	a5,a5
    800020a0:	079e                	slli	a5,a5,0x7
    800020a2:	97ca                	add	a5,a5,s2
    800020a4:	0ac7a983          	lw	s3,172(a5)
    800020a8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020aa:	2781                	sext.w	a5,a5
    800020ac:	079e                	slli	a5,a5,0x7
    800020ae:	07a1                	addi	a5,a5,8
    800020b0:	00010597          	auipc	a1,0x10
    800020b4:	48858593          	addi	a1,a1,1160 # 80012538 <cpus>
    800020b8:	95be                	add	a1,a1,a5
    800020ba:	06048513          	addi	a0,s1,96
    800020be:	622000ef          	jal	800026e0 <swtch>
    800020c2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020c4:	2781                	sext.w	a5,a5
    800020c6:	079e                	slli	a5,a5,0x7
    800020c8:	993e                	add	s2,s2,a5
    800020ca:	0b392623          	sw	s3,172(s2)
}
    800020ce:	70a2                	ld	ra,40(sp)
    800020d0:	7402                	ld	s0,32(sp)
    800020d2:	64e2                	ld	s1,24(sp)
    800020d4:	6942                	ld	s2,16(sp)
    800020d6:	69a2                	ld	s3,8(sp)
    800020d8:	6145                	addi	sp,sp,48
    800020da:	8082                	ret
    panic("sched p->lock");
    800020dc:	00005517          	auipc	a0,0x5
    800020e0:	0bc50513          	addi	a0,a0,188 # 80007198 <etext+0x198>
    800020e4:	f50fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    800020e8:	00005517          	auipc	a0,0x5
    800020ec:	0c050513          	addi	a0,a0,192 # 800071a8 <etext+0x1a8>
    800020f0:	f44fe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    800020f4:	00005517          	auipc	a0,0x5
    800020f8:	0c450513          	addi	a0,a0,196 # 800071b8 <etext+0x1b8>
    800020fc:	f38fe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80002100:	00005517          	auipc	a0,0x5
    80002104:	0c850513          	addi	a0,a0,200 # 800071c8 <etext+0x1c8>
    80002108:	f2cfe0ef          	jal	80000834 <panic>

000000008000210c <yield>:
{
    8000210c:	1101                	addi	sp,sp,-32
    8000210e:	ec06                	sd	ra,24(sp)
    80002110:	e822                	sd	s0,16(sp)
    80002112:	e426                	sd	s1,8(sp)
    80002114:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002116:	833ff0ef          	jal	80001948 <myproc>
    8000211a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000211c:	b0dfe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80002120:	478d                	li	a5,3
    80002122:	cc9c                	sw	a5,24(s1)
  sched();
    80002124:	f2dff0ef          	jal	80002050 <sched>
  release(&p->lock);
    80002128:	8526                	mv	a0,s1
    8000212a:	b87fe0ef          	jal	80000cb0 <release>
}
    8000212e:	60e2                	ld	ra,24(sp)
    80002130:	6442                	ld	s0,16(sp)
    80002132:	64a2                	ld	s1,8(sp)
    80002134:	6105                	addi	sp,sp,32
    80002136:	8082                	ret

0000000080002138 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80002138:	1101                	addi	sp,sp,-32
    8000213a:	ec06                	sd	ra,24(sp)
    8000213c:	e822                	sd	s0,16(sp)
    8000213e:	e426                	sd	s1,8(sp)
    80002140:	e04a                	sd	s2,0(sp)
    80002142:	1000                	addi	s0,sp,32
    80002144:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002146:	803ff0ef          	jal	80001948 <myproc>
    8000214a:	892a                	mv	s2,a0

  acquire(&p->lock);
    8000214c:	addfe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    80002150:	cc81                	beqz	s1,80002168 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80002152:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80002156:	854a                	mv	a0,s2
    80002158:	b59fe0ef          	jal	80000cb0 <release>
}
    8000215c:	60e2                	ld	ra,24(sp)
    8000215e:	6442                	ld	s0,16(sp)
    80002160:	64a2                	ld	s1,8(sp)
    80002162:	6902                	ld	s2,0(sp)
    80002164:	6105                	addi	sp,sp,32
    80002166:	8082                	ret
    panic("sleep_prepare: zero chan");
    80002168:	00005517          	auipc	a0,0x5
    8000216c:	07850513          	addi	a0,a0,120 # 800071e0 <etext+0x1e0>
    80002170:	ec4fe0ef          	jal	80000834 <panic>

0000000080002174 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80002174:	1101                	addi	sp,sp,-32
    80002176:	ec06                	sd	ra,24(sp)
    80002178:	e822                	sd	s0,16(sp)
    8000217a:	e426                	sd	s1,8(sp)
    8000217c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000217e:	fcaff0ef          	jal	80001948 <myproc>
    80002182:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80002184:	aa5fe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    80002188:	709c                	ld	a5,32(s1)
    8000218a:	c789                	beqz	a5,80002194 <sleep+0x20>
    p->state = SLEEPING;
    8000218c:	4789                	li	a5,2
    8000218e:	cc9c                	sw	a5,24(s1)
    sched();
    80002190:	ec1ff0ef          	jal	80002050 <sched>
  }
  release(&p->lock);
    80002194:	8526                	mv	a0,s1
    80002196:	b1bfe0ef          	jal	80000cb0 <release>
}
    8000219a:	60e2                	ld	ra,24(sp)
    8000219c:	6442                	ld	s0,16(sp)
    8000219e:	64a2                	ld	s1,8(sp)
    800021a0:	6105                	addi	sp,sp,32
    800021a2:	8082                	ret

00000000800021a4 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    800021a4:	7139                	addi	sp,sp,-64
    800021a6:	fc06                	sd	ra,56(sp)
    800021a8:	f822                	sd	s0,48(sp)
    800021aa:	f426                	sd	s1,40(sp)
    800021ac:	f04a                	sd	s2,32(sp)
    800021ae:	ec4e                	sd	s3,24(sp)
    800021b0:	e852                	sd	s4,16(sp)
    800021b2:	e456                	sd	s5,8(sp)
    800021b4:	0080                	addi	s0,sp,64
    800021b6:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800021b8:	00010497          	auipc	s1,0x10
    800021bc:	78048493          	addi	s1,s1,1920 # 80012938 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    800021c0:	4a09                	li	s4,2
        p->state = RUNNABLE;
    800021c2:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    800021c4:	00016997          	auipc	s3,0x16
    800021c8:	37498993          	addi	s3,s3,884 # 80018538 <tickslock>
    800021cc:	a801                	j	800021dc <wakeup+0x38>
      }
    }
    release(&p->lock);
    800021ce:	8526                	mv	a0,s1
    800021d0:	ae1fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800021d4:	17048493          	addi	s1,s1,368
    800021d8:	03348063          	beq	s1,s3,800021f8 <wakeup+0x54>
    acquire(&p->lock);
    800021dc:	8526                	mv	a0,s1
    800021de:	a4bfe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    800021e2:	709c                	ld	a5,32(s1)
    800021e4:	ff2795e3          	bne	a5,s2,800021ce <wakeup+0x2a>
      p->chan = 0;
    800021e8:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    800021ec:	4c9c                	lw	a5,24(s1)
    800021ee:	ff4790e3          	bne	a5,s4,800021ce <wakeup+0x2a>
        p->state = RUNNABLE;
    800021f2:	0154ac23          	sw	s5,24(s1)
    800021f6:	bfe1                	j	800021ce <wakeup+0x2a>
  }
}
    800021f8:	70e2                	ld	ra,56(sp)
    800021fa:	7442                	ld	s0,48(sp)
    800021fc:	74a2                	ld	s1,40(sp)
    800021fe:	7902                	ld	s2,32(sp)
    80002200:	69e2                	ld	s3,24(sp)
    80002202:	6a42                	ld	s4,16(sp)
    80002204:	6aa2                	ld	s5,8(sp)
    80002206:	6121                	addi	sp,sp,64
    80002208:	8082                	ret

000000008000220a <reparent>:
{
    8000220a:	7179                	addi	sp,sp,-48
    8000220c:	f406                	sd	ra,40(sp)
    8000220e:	f022                	sd	s0,32(sp)
    80002210:	ec26                	sd	s1,24(sp)
    80002212:	e84a                	sd	s2,16(sp)
    80002214:	e44e                	sd	s3,8(sp)
    80002216:	e052                	sd	s4,0(sp)
    80002218:	1800                	addi	s0,sp,48
    8000221a:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000221c:	00010497          	auipc	s1,0x10
    80002220:	71c48493          	addi	s1,s1,1820 # 80012938 <proc>
      pp->parent = initproc;
    80002224:	00008a17          	auipc	s4,0x8
    80002228:	1dca0a13          	addi	s4,s4,476 # 8000a400 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000222c:	00016997          	auipc	s3,0x16
    80002230:	30c98993          	addi	s3,s3,780 # 80018538 <tickslock>
    80002234:	a029                	j	8000223e <reparent+0x34>
    80002236:	17048493          	addi	s1,s1,368
    8000223a:	01348b63          	beq	s1,s3,80002250 <reparent+0x46>
    if (pp->parent == p) {
    8000223e:	7c9c                	ld	a5,56(s1)
    80002240:	ff279be3          	bne	a5,s2,80002236 <reparent+0x2c>
      pp->parent = initproc;
    80002244:	000a3503          	ld	a0,0(s4)
    80002248:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000224a:	f5bff0ef          	jal	800021a4 <wakeup>
    8000224e:	b7e5                	j	80002236 <reparent+0x2c>
}
    80002250:	70a2                	ld	ra,40(sp)
    80002252:	7402                	ld	s0,32(sp)
    80002254:	64e2                	ld	s1,24(sp)
    80002256:	6942                	ld	s2,16(sp)
    80002258:	69a2                	ld	s3,8(sp)
    8000225a:	6a02                	ld	s4,0(sp)
    8000225c:	6145                	addi	sp,sp,48
    8000225e:	8082                	ret

0000000080002260 <kexit>:
{
    80002260:	7179                	addi	sp,sp,-48
    80002262:	f406                	sd	ra,40(sp)
    80002264:	f022                	sd	s0,32(sp)
    80002266:	ec26                	sd	s1,24(sp)
    80002268:	e84a                	sd	s2,16(sp)
    8000226a:	e44e                	sd	s3,8(sp)
    8000226c:	e052                	sd	s4,0(sp)
    8000226e:	1800                	addi	s0,sp,48
    80002270:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002272:	ed6ff0ef          	jal	80001948 <myproc>
    80002276:	89aa                	mv	s3,a0
  if (p == initproc)
    80002278:	00008797          	auipc	a5,0x8
    8000227c:	1887b783          	ld	a5,392(a5) # 8000a400 <initproc>
    80002280:	0d050493          	addi	s1,a0,208
    80002284:	15050913          	addi	s2,a0,336
    80002288:	00a79b63          	bne	a5,a0,8000229e <kexit+0x3e>
    panic("init exiting");
    8000228c:	00005517          	auipc	a0,0x5
    80002290:	f7450513          	addi	a0,a0,-140 # 80007200 <etext+0x200>
    80002294:	da0fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002298:	04a1                	addi	s1,s1,8
    8000229a:	01248963          	beq	s1,s2,800022ac <kexit+0x4c>
    if (p->ofile[fd]) {
    8000229e:	6088                	ld	a0,0(s1)
    800022a0:	dd65                	beqz	a0,80002298 <kexit+0x38>
      fileclose(f);
    800022a2:	20c020ef          	jal	800044ae <fileclose>
      p->ofile[fd] = 0;
    800022a6:	0004b023          	sd	zero,0(s1)
    800022aa:	b7fd                	j	80002298 <kexit+0x38>
  begin_op();
    800022ac:	549010ef          	jal	80003ff4 <begin_op>
  iput(p->cwd);
    800022b0:	1509b503          	ld	a0,336(s3)
    800022b4:	44a010ef          	jal	800036fe <iput>
  end_op();
    800022b8:	5c9010ef          	jal	80004080 <end_op>
  p->cwd = 0;
    800022bc:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022c0:	00010517          	auipc	a0,0x10
    800022c4:	26050513          	addi	a0,a0,608 # 80012520 <wait_lock>
    800022c8:	961fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    800022cc:	854e                	mv	a0,s3
    800022ce:	f3dff0ef          	jal	8000220a <reparent>
  wakeup(p->parent);
    800022d2:	0389b503          	ld	a0,56(s3)
    800022d6:	ecfff0ef          	jal	800021a4 <wakeup>
  acquire(&p->lock);
    800022da:	854e                	mv	a0,s3
    800022dc:	94dfe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    800022e0:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022e4:	4795                	li	a5,5
    800022e6:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022ea:	00010517          	auipc	a0,0x10
    800022ee:	23650513          	addi	a0,a0,566 # 80012520 <wait_lock>
    800022f2:	9bffe0ef          	jal	80000cb0 <release>
  sched();
    800022f6:	d5bff0ef          	jal	80002050 <sched>
  panic("zombie exit");
    800022fa:	00005517          	auipc	a0,0x5
    800022fe:	f1650513          	addi	a0,a0,-234 # 80007210 <etext+0x210>
    80002302:	d32fe0ef          	jal	80000834 <panic>

0000000080002306 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    80002306:	c525                	beqz	a0,8000236e <kkill+0x68>
{
    80002308:	7179                	addi	sp,sp,-48
    8000230a:	f406                	sd	ra,40(sp)
    8000230c:	f022                	sd	s0,32(sp)
    8000230e:	ec26                	sd	s1,24(sp)
    80002310:	e84a                	sd	s2,16(sp)
    80002312:	e44e                	sd	s3,8(sp)
    80002314:	1800                	addi	s0,sp,48
    80002316:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002318:	00010497          	auipc	s1,0x10
    8000231c:	62048493          	addi	s1,s1,1568 # 80012938 <proc>
    80002320:	00016997          	auipc	s3,0x16
    80002324:	21898993          	addi	s3,s3,536 # 80018538 <tickslock>
    acquire(&p->lock);
    80002328:	8526                	mv	a0,s1
    8000232a:	8fffe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    8000232e:	589c                	lw	a5,48(s1)
    80002330:	01278b63          	beq	a5,s2,80002346 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002334:	8526                	mv	a0,s1
    80002336:	97bfe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000233a:	17048493          	addi	s1,s1,368
    8000233e:	ff3495e3          	bne	s1,s3,80002328 <kkill+0x22>
  }
  return -1;
    80002342:	557d                	li	a0,-1
    80002344:	a819                	j	8000235a <kkill+0x54>
      p->killed = 1;
    80002346:	4785                	li	a5,1
    80002348:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    8000234a:	4c98                	lw	a4,24(s1)
    8000234c:	4789                	li	a5,2
    8000234e:	00f70d63          	beq	a4,a5,80002368 <kkill+0x62>
      release(&p->lock);
    80002352:	8526                	mv	a0,s1
    80002354:	95dfe0ef          	jal	80000cb0 <release>
      return 0;
    80002358:	4501                	li	a0,0
}
    8000235a:	70a2                	ld	ra,40(sp)
    8000235c:	7402                	ld	s0,32(sp)
    8000235e:	64e2                	ld	s1,24(sp)
    80002360:	6942                	ld	s2,16(sp)
    80002362:	69a2                	ld	s3,8(sp)
    80002364:	6145                	addi	sp,sp,48
    80002366:	8082                	ret
        p->state = RUNNABLE;
    80002368:	478d                	li	a5,3
    8000236a:	cc9c                	sw	a5,24(s1)
    8000236c:	b7dd                	j	80002352 <kkill+0x4c>
    return -1;
    8000236e:	557d                	li	a0,-1
}
    80002370:	8082                	ret

0000000080002372 <setkilled>:

void
setkilled(struct proc *p)
{
    80002372:	1101                	addi	sp,sp,-32
    80002374:	ec06                	sd	ra,24(sp)
    80002376:	e822                	sd	s0,16(sp)
    80002378:	e426                	sd	s1,8(sp)
    8000237a:	1000                	addi	s0,sp,32
    8000237c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000237e:	8abfe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002382:	4785                	li	a5,1
    80002384:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002386:	8526                	mv	a0,s1
    80002388:	929fe0ef          	jal	80000cb0 <release>
}
    8000238c:	60e2                	ld	ra,24(sp)
    8000238e:	6442                	ld	s0,16(sp)
    80002390:	64a2                	ld	s1,8(sp)
    80002392:	6105                	addi	sp,sp,32
    80002394:	8082                	ret

0000000080002396 <killed>:

int
killed(struct proc *p)
{
    80002396:	1101                	addi	sp,sp,-32
    80002398:	ec06                	sd	ra,24(sp)
    8000239a:	e822                	sd	s0,16(sp)
    8000239c:	e426                	sd	s1,8(sp)
    8000239e:	e04a                	sd	s2,0(sp)
    800023a0:	1000                	addi	s0,sp,32
    800023a2:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800023a4:	885fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    800023a8:	549c                	lw	a5,40(s1)
    800023aa:	893e                	mv	s2,a5
  release(&p->lock);
    800023ac:	8526                	mv	a0,s1
    800023ae:	903fe0ef          	jal	80000cb0 <release>
  return k;
}
    800023b2:	854a                	mv	a0,s2
    800023b4:	60e2                	ld	ra,24(sp)
    800023b6:	6442                	ld	s0,16(sp)
    800023b8:	64a2                	ld	s1,8(sp)
    800023ba:	6902                	ld	s2,0(sp)
    800023bc:	6105                	addi	sp,sp,32
    800023be:	8082                	ret

00000000800023c0 <kwait>:
{
    800023c0:	715d                	addi	sp,sp,-80
    800023c2:	e486                	sd	ra,72(sp)
    800023c4:	e0a2                	sd	s0,64(sp)
    800023c6:	fc26                	sd	s1,56(sp)
    800023c8:	f84a                	sd	s2,48(sp)
    800023ca:	f44e                	sd	s3,40(sp)
    800023cc:	f052                	sd	s4,32(sp)
    800023ce:	ec56                	sd	s5,24(sp)
    800023d0:	e85a                	sd	s6,16(sp)
    800023d2:	e45e                	sd	s7,8(sp)
    800023d4:	0880                	addi	s0,sp,80
    800023d6:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800023d8:	d70ff0ef          	jal	80001948 <myproc>
    800023dc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023de:	00010517          	auipc	a0,0x10
    800023e2:	14250513          	addi	a0,a0,322 # 80012520 <wait_lock>
    800023e6:	843fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800023ea:	4a15                	li	s4,5
        havekids = 1;
    800023ec:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800023ee:	00016997          	auipc	s3,0x16
    800023f2:	14a98993          	addi	s3,s3,330 # 80018538 <tickslock>
    release(&wait_lock);
    800023f6:	00010b17          	auipc	s6,0x10
    800023fa:	12ab0b13          	addi	s6,s6,298 # 80012520 <wait_lock>
    800023fe:	a855                	j	800024b2 <kwait+0xf2>
            release(&pp->lock);
    80002400:	8526                	mv	a0,s1
    80002402:	8affe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    80002406:	00010517          	auipc	a0,0x10
    8000240a:	11a50513          	addi	a0,a0,282 # 80012520 <wait_lock>
    8000240e:	8a3fe0ef          	jal	80000cb0 <release>
            return -1;
    80002412:	59fd                	li	s3,-1
    80002414:	a09d                	j	8000247a <kwait+0xba>
        release(&pp->lock);
    80002416:	8526                	mv	a0,s1
    80002418:	899fe0ef          	jal	80000cb0 <release>
        havekids = 1;
    8000241c:	8756                	mv	a4,s5
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000241e:	17048493          	addi	s1,s1,368
    80002422:	07348863          	beq	s1,s3,80002492 <kwait+0xd2>
      if (pp->parent == p && !pp->is_thread) {
    80002426:	7c9c                	ld	a5,56(s1)
    80002428:	ff279be3          	bne	a5,s2,8000241e <kwait+0x5e>
    8000242c:	1684a783          	lw	a5,360(s1)
    80002430:	f7fd                	bnez	a5,8000241e <kwait+0x5e>
        acquire(&pp->lock);
    80002432:	8526                	mv	a0,s1
    80002434:	ff4fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002438:	4c9c                	lw	a5,24(s1)
    8000243a:	fd479ee3          	bne	a5,s4,80002416 <kwait+0x56>
          pid = pp->pid;
    8000243e:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    80002442:	000b8e63          	beqz	s7,8000245e <kwait+0x9e>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    80002446:	4711                	li	a4,4
    80002448:	02c48693          	addi	a3,s1,44
    8000244c:	865e                	mv	a2,s7
    8000244e:	04893583          	ld	a1,72(s2)
    80002452:	05093503          	ld	a0,80(s2)
    80002456:	92cff0ef          	jal	80001582 <copyout>
          if (addr != 0 &&
    8000245a:	fa0543e3          	bltz	a0,80002400 <kwait+0x40>
          pp->parent = 0;
    8000245e:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    80002462:	8526                	mv	a0,s1
    80002464:	eb4ff0ef          	jal	80001b18 <freeproc>
          release(&pp->lock);
    80002468:	8526                	mv	a0,s1
    8000246a:	847fe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    8000246e:	00010517          	auipc	a0,0x10
    80002472:	0b250513          	addi	a0,a0,178 # 80012520 <wait_lock>
    80002476:	83bfe0ef          	jal	80000cb0 <release>
}
    8000247a:	854e                	mv	a0,s3
    8000247c:	60a6                	ld	ra,72(sp)
    8000247e:	6406                	ld	s0,64(sp)
    80002480:	74e2                	ld	s1,56(sp)
    80002482:	7942                	ld	s2,48(sp)
    80002484:	79a2                	ld	s3,40(sp)
    80002486:	7a02                	ld	s4,32(sp)
    80002488:	6ae2                	ld	s5,24(sp)
    8000248a:	6b42                	ld	s6,16(sp)
    8000248c:	6ba2                	ld	s7,8(sp)
    8000248e:	6161                	addi	sp,sp,80
    80002490:	8082                	ret
    if (!havekids || killed(p)) {
    80002492:	c715                	beqz	a4,800024be <kwait+0xfe>
    80002494:	854a                	mv	a0,s2
    80002496:	f01ff0ef          	jal	80002396 <killed>
    8000249a:	e115                	bnez	a0,800024be <kwait+0xfe>
    sleep_prepare(p); //DOC: wait-sleep
    8000249c:	854a                	mv	a0,s2
    8000249e:	c9bff0ef          	jal	80002138 <sleep_prepare>
    release(&wait_lock);
    800024a2:	855a                	mv	a0,s6
    800024a4:	80dfe0ef          	jal	80000cb0 <release>
    sleep();
    800024a8:	ccdff0ef          	jal	80002174 <sleep>
    acquire(&wait_lock);
    800024ac:	855a                	mv	a0,s6
    800024ae:	f7afe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    800024b2:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800024b4:	00010497          	auipc	s1,0x10
    800024b8:	48448493          	addi	s1,s1,1156 # 80012938 <proc>
    800024bc:	b7ad                	j	80002426 <kwait+0x66>
      release(&wait_lock);
    800024be:	00010517          	auipc	a0,0x10
    800024c2:	06250513          	addi	a0,a0,98 # 80012520 <wait_lock>
    800024c6:	feafe0ef          	jal	80000cb0 <release>
      return -1;
    800024ca:	59fd                	li	s3,-1
    800024cc:	b77d                	j	8000247a <kwait+0xba>

00000000800024ce <kjoin>:
{
    800024ce:	7139                	addi	sp,sp,-64
    800024d0:	fc06                	sd	ra,56(sp)
    800024d2:	f822                	sd	s0,48(sp)
    800024d4:	f426                	sd	s1,40(sp)
    800024d6:	f04a                	sd	s2,32(sp)
    800024d8:	ec4e                	sd	s3,24(sp)
    800024da:	e852                	sd	s4,16(sp)
    800024dc:	e456                	sd	s5,8(sp)
    800024de:	e05a                	sd	s6,0(sp)
    800024e0:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800024e2:	c66ff0ef          	jal	80001948 <myproc>
    800024e6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024e8:	00010517          	auipc	a0,0x10
    800024ec:	03850513          	addi	a0,a0,56 # 80012520 <wait_lock>
    800024f0:	f38fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800024f4:	4a15                	li	s4,5
        havethreads = 1;
    800024f6:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800024f8:	00016997          	auipc	s3,0x16
    800024fc:	04098993          	addi	s3,s3,64 # 80018538 <tickslock>
    release(&wait_lock);
    80002500:	00010b17          	auipc	s6,0x10
    80002504:	020b0b13          	addi	s6,s6,32 # 80012520 <wait_lock>
    80002508:	a041                	j	80002588 <kjoin+0xba>
        release(&pp->lock);
    8000250a:	8526                	mv	a0,s1
    8000250c:	fa4fe0ef          	jal	80000cb0 <release>
        havethreads = 1;
    80002510:	8756                	mv	a4,s5
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002512:	17048493          	addi	s1,s1,368
    80002516:	05348963          	beq	s1,s3,80002568 <kjoin+0x9a>
      if (pp->parent == p && pp->is_thread) {
    8000251a:	7c9c                	ld	a5,56(s1)
    8000251c:	ff279be3          	bne	a5,s2,80002512 <kjoin+0x44>
    80002520:	1684a783          	lw	a5,360(s1)
    80002524:	d7fd                	beqz	a5,80002512 <kjoin+0x44>
        acquire(&pp->lock);
    80002526:	8526                	mv	a0,s1
    80002528:	f00fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    8000252c:	4c9c                	lw	a5,24(s1)
    8000252e:	fd479ee3          	bne	a5,s4,8000250a <kjoin+0x3c>
          pid = pp->pid;
    80002532:	0304a903          	lw	s2,48(s1)
          pp->parent = 0;
    80002536:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    8000253a:	8526                	mv	a0,s1
    8000253c:	ddcff0ef          	jal	80001b18 <freeproc>
          release(&pp->lock);
    80002540:	8526                	mv	a0,s1
    80002542:	f6efe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    80002546:	00010517          	auipc	a0,0x10
    8000254a:	fda50513          	addi	a0,a0,-38 # 80012520 <wait_lock>
    8000254e:	f62fe0ef          	jal	80000cb0 <release>
}
    80002552:	854a                	mv	a0,s2
    80002554:	70e2                	ld	ra,56(sp)
    80002556:	7442                	ld	s0,48(sp)
    80002558:	74a2                	ld	s1,40(sp)
    8000255a:	7902                	ld	s2,32(sp)
    8000255c:	69e2                	ld	s3,24(sp)
    8000255e:	6a42                	ld	s4,16(sp)
    80002560:	6aa2                	ld	s5,8(sp)
    80002562:	6b02                	ld	s6,0(sp)
    80002564:	6121                	addi	sp,sp,64
    80002566:	8082                	ret
    if (!havethreads || killed(p)) {
    80002568:	c715                	beqz	a4,80002594 <kjoin+0xc6>
    8000256a:	854a                	mv	a0,s2
    8000256c:	e2bff0ef          	jal	80002396 <killed>
    80002570:	e115                	bnez	a0,80002594 <kjoin+0xc6>
    sleep_prepare(p);
    80002572:	854a                	mv	a0,s2
    80002574:	bc5ff0ef          	jal	80002138 <sleep_prepare>
    release(&wait_lock);
    80002578:	855a                	mv	a0,s6
    8000257a:	f36fe0ef          	jal	80000cb0 <release>
    sleep();
    8000257e:	bf7ff0ef          	jal	80002174 <sleep>
    acquire(&wait_lock);
    80002582:	855a                	mv	a0,s6
    80002584:	ea4fe0ef          	jal	80000c28 <acquire>
    havethreads = 0;
    80002588:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000258a:	00010497          	auipc	s1,0x10
    8000258e:	3ae48493          	addi	s1,s1,942 # 80012938 <proc>
    80002592:	b761                	j	8000251a <kjoin+0x4c>
      release(&wait_lock);
    80002594:	00010517          	auipc	a0,0x10
    80002598:	f8c50513          	addi	a0,a0,-116 # 80012520 <wait_lock>
    8000259c:	f14fe0ef          	jal	80000cb0 <release>
      return -1;
    800025a0:	597d                	li	s2,-1
    800025a2:	bf45                	j	80002552 <kjoin+0x84>

00000000800025a4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025a4:	7179                	addi	sp,sp,-48
    800025a6:	f406                	sd	ra,40(sp)
    800025a8:	f022                	sd	s0,32(sp)
    800025aa:	ec26                	sd	s1,24(sp)
    800025ac:	e84a                	sd	s2,16(sp)
    800025ae:	e44e                	sd	s3,8(sp)
    800025b0:	e052                	sd	s4,0(sp)
    800025b2:	1800                	addi	s0,sp,48
    800025b4:	84aa                	mv	s1,a0
    800025b6:	8a2e                	mv	s4,a1
    800025b8:	89b2                	mv	s3,a2
    800025ba:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800025bc:	b8cff0ef          	jal	80001948 <myproc>
  if (user_dst) {
    800025c0:	c085                	beqz	s1,800025e0 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    800025c2:	874a                	mv	a4,s2
    800025c4:	86ce                	mv	a3,s3
    800025c6:	8652                	mv	a2,s4
    800025c8:	652c                	ld	a1,72(a0)
    800025ca:	6928                	ld	a0,80(a0)
    800025cc:	fb7fe0ef          	jal	80001582 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025d0:	70a2                	ld	ra,40(sp)
    800025d2:	7402                	ld	s0,32(sp)
    800025d4:	64e2                	ld	s1,24(sp)
    800025d6:	6942                	ld	s2,16(sp)
    800025d8:	69a2                	ld	s3,8(sp)
    800025da:	6a02                	ld	s4,0(sp)
    800025dc:	6145                	addi	sp,sp,48
    800025de:	8082                	ret
    memmove((char *)dst, src, len);
    800025e0:	0009061b          	sext.w	a2,s2
    800025e4:	85ce                	mv	a1,s3
    800025e6:	8552                	mv	a0,s4
    800025e8:	f60fe0ef          	jal	80000d48 <memmove>
    return 0;
    800025ec:	8526                	mv	a0,s1
    800025ee:	b7cd                	j	800025d0 <either_copyout+0x2c>

00000000800025f0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025f0:	7179                	addi	sp,sp,-48
    800025f2:	f406                	sd	ra,40(sp)
    800025f4:	f022                	sd	s0,32(sp)
    800025f6:	ec26                	sd	s1,24(sp)
    800025f8:	e84a                	sd	s2,16(sp)
    800025fa:	e44e                	sd	s3,8(sp)
    800025fc:	e052                	sd	s4,0(sp)
    800025fe:	1800                	addi	s0,sp,48
    80002600:	8a2a                	mv	s4,a0
    80002602:	84ae                	mv	s1,a1
    80002604:	89b2                	mv	s3,a2
    80002606:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002608:	b40ff0ef          	jal	80001948 <myproc>
  if (user_src) {
    8000260c:	c085                	beqz	s1,8000262c <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    8000260e:	874a                	mv	a4,s2
    80002610:	86ce                	mv	a3,s3
    80002612:	8652                	mv	a2,s4
    80002614:	652c                	ld	a1,72(a0)
    80002616:	6928                	ld	a0,80(a0)
    80002618:	830ff0ef          	jal	80001648 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000261c:	70a2                	ld	ra,40(sp)
    8000261e:	7402                	ld	s0,32(sp)
    80002620:	64e2                	ld	s1,24(sp)
    80002622:	6942                	ld	s2,16(sp)
    80002624:	69a2                	ld	s3,8(sp)
    80002626:	6a02                	ld	s4,0(sp)
    80002628:	6145                	addi	sp,sp,48
    8000262a:	8082                	ret
    memmove(dst, (char *)src, len);
    8000262c:	0009061b          	sext.w	a2,s2
    80002630:	85ce                	mv	a1,s3
    80002632:	8552                	mv	a0,s4
    80002634:	f14fe0ef          	jal	80000d48 <memmove>
    return 0;
    80002638:	8526                	mv	a0,s1
    8000263a:	b7cd                	j	8000261c <either_copyin+0x2c>

000000008000263c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000263c:	715d                	addi	sp,sp,-80
    8000263e:	e486                	sd	ra,72(sp)
    80002640:	e0a2                	sd	s0,64(sp)
    80002642:	fc26                	sd	s1,56(sp)
    80002644:	f84a                	sd	s2,48(sp)
    80002646:	f44e                	sd	s3,40(sp)
    80002648:	f052                	sd	s4,32(sp)
    8000264a:	ec56                	sd	s5,24(sp)
    8000264c:	e85a                	sd	s6,16(sp)
    8000264e:	e45e                	sd	s7,8(sp)
    80002650:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002652:	00005517          	auipc	a0,0x5
    80002656:	a2650513          	addi	a0,a0,-1498 # 80007078 <etext+0x78>
    8000265a:	eb1fd0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000265e:	00010497          	auipc	s1,0x10
    80002662:	43248493          	addi	s1,s1,1074 # 80012a90 <proc+0x158>
    80002666:	00016917          	auipc	s2,0x16
    8000266a:	02a90913          	addi	s2,s2,42 # 80018690 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000266e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002670:	00005997          	auipc	s3,0x5
    80002674:	bb098993          	addi	s3,s3,-1104 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    80002678:	00005a97          	auipc	s5,0x5
    8000267c:	bb0a8a93          	addi	s5,s5,-1104 # 80007228 <etext+0x228>
    printk("\n");
    80002680:	00005a17          	auipc	s4,0x5
    80002684:	9f8a0a13          	addi	s4,s4,-1544 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002688:	00005b97          	auipc	s7,0x5
    8000268c:	0c0b8b93          	addi	s7,s7,192 # 80007748 <states.0>
    80002690:	a829                	j	800026aa <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002692:	ed86a583          	lw	a1,-296(a3)
    80002696:	8556                	mv	a0,s5
    80002698:	e73fd0ef          	jal	8000050a <printk>
    printk("\n");
    8000269c:	8552                	mv	a0,s4
    8000269e:	e6dfd0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800026a2:	17048493          	addi	s1,s1,368
    800026a6:	03248263          	beq	s1,s2,800026ca <procdump+0x8e>
    if (p->state == UNUSED)
    800026aa:	86a6                	mv	a3,s1
    800026ac:	ec04a783          	lw	a5,-320(s1)
    800026b0:	dbed                	beqz	a5,800026a2 <procdump+0x66>
      state = "???";
    800026b2:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b4:	fcfb6fe3          	bltu	s6,a5,80002692 <procdump+0x56>
    800026b8:	02079713          	slli	a4,a5,0x20
    800026bc:	01d75793          	srli	a5,a4,0x1d
    800026c0:	97de                	add	a5,a5,s7
    800026c2:	6390                	ld	a2,0(a5)
    800026c4:	f679                	bnez	a2,80002692 <procdump+0x56>
      state = "???";
    800026c6:	864e                	mv	a2,s3
    800026c8:	b7e9                	j	80002692 <procdump+0x56>
  }
}
    800026ca:	60a6                	ld	ra,72(sp)
    800026cc:	6406                	ld	s0,64(sp)
    800026ce:	74e2                	ld	s1,56(sp)
    800026d0:	7942                	ld	s2,48(sp)
    800026d2:	79a2                	ld	s3,40(sp)
    800026d4:	7a02                	ld	s4,32(sp)
    800026d6:	6ae2                	ld	s5,24(sp)
    800026d8:	6b42                	ld	s6,16(sp)
    800026da:	6ba2                	ld	s7,8(sp)
    800026dc:	6161                	addi	sp,sp,80
    800026de:	8082                	ret

00000000800026e0 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800026e0:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800026e4:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800026e8:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800026ea:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800026ec:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800026f0:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800026f4:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800026f8:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800026fc:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002700:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002704:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002708:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000270c:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002710:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002714:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002718:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000271c:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000271e:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002720:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002724:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002728:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000272c:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002730:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002734:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002738:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000273c:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002740:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002744:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002748:	8082                	ret

000000008000274a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000274a:	1141                	addi	sp,sp,-16
    8000274c:	e406                	sd	ra,8(sp)
    8000274e:	e022                	sd	s0,0(sp)
    80002750:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002752:	00005597          	auipc	a1,0x5
    80002756:	b1658593          	addi	a1,a1,-1258 # 80007268 <etext+0x268>
    8000275a:	00016517          	auipc	a0,0x16
    8000275e:	dde50513          	addi	a0,a0,-546 # 80018538 <tickslock>
    80002762:	c46fe0ef          	jal	80000ba8 <initlock>
}
    80002766:	60a2                	ld	ra,8(sp)
    80002768:	6402                	ld	s0,0(sp)
    8000276a:	0141                	addi	sp,sp,16
    8000276c:	8082                	ret

000000008000276e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000276e:	1141                	addi	sp,sp,-16
    80002770:	e406                	sd	ra,8(sp)
    80002772:	e022                	sd	s0,0(sp)
    80002774:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002776:	00003797          	auipc	a5,0x3
    8000277a:	1ca78793          	addi	a5,a5,458 # 80005940 <kernelvec>
    8000277e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002782:	60a2                	ld	ra,8(sp)
    80002784:	6402                	ld	s0,0(sp)
    80002786:	0141                	addi	sp,sp,16
    80002788:	8082                	ret

000000008000278a <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000278a:	1141                	addi	sp,sp,-16
    8000278c:	e406                	sd	ra,8(sp)
    8000278e:	e022                	sd	s0,0(sp)
    80002790:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002792:	9b6ff0ef          	jal	80001948 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002796:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000279a:	04000737          	lui	a4,0x4000
    8000279e:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800027a0:	0732                	slli	a4,a4,0xc
    800027a2:	00004797          	auipc	a5,0x4
    800027a6:	85e78793          	addi	a5,a5,-1954 # 80006000 <_trampoline>
    800027aa:	00004697          	auipc	a3,0x4
    800027ae:	85668693          	addi	a3,a3,-1962 # 80006000 <_trampoline>
    800027b2:	8f95                	sub	a5,a5,a3
    800027b4:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    800027b6:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027ba:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    800027bc:	18002773          	csrr	a4,satp
    800027c0:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027c2:	6d38                	ld	a4,88(a0)
    800027c4:	613c                	ld	a5,64(a0)
    800027c6:	6685                	lui	a3,0x1
    800027c8:	97b6                	add	a5,a5,a3
    800027ca:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027cc:	6d3c                	ld	a5,88(a0)
    800027ce:	00000717          	auipc	a4,0x0
    800027d2:	0fc70713          	addi	a4,a4,252 # 800028ca <usertrap>
    800027d6:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800027d8:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    800027da:	8712                	mv	a4,tp
    800027dc:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027de:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027e2:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027e6:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800027ea:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027ee:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800027f0:	6f9c                	ld	a5,24(a5)
    800027f2:	14179073          	csrw	sepc,a5
}
    800027f6:	60a2                	ld	ra,8(sp)
    800027f8:	6402                	ld	s0,0(sp)
    800027fa:	0141                	addi	sp,sp,16
    800027fc:	8082                	ret

00000000800027fe <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027fe:	1141                	addi	sp,sp,-16
    80002800:	e406                	sd	ra,8(sp)
    80002802:	e022                	sd	s0,0(sp)
    80002804:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80002806:	90eff0ef          	jal	80001914 <cpuid>
    8000280a:	cd11                	beqz	a0,80002826 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    8000280c:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002810:	000f4737          	lui	a4,0xf4
    80002814:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002818:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000281a:	14d79073          	csrw	stimecmp,a5
}
    8000281e:	60a2                	ld	ra,8(sp)
    80002820:	6402                	ld	s0,0(sp)
    80002822:	0141                	addi	sp,sp,16
    80002824:	8082                	ret
    acquire(&tickslock);
    80002826:	00016517          	auipc	a0,0x16
    8000282a:	d1250513          	addi	a0,a0,-750 # 80018538 <tickslock>
    8000282e:	bfafe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002832:	00008717          	auipc	a4,0x8
    80002836:	bd670713          	addi	a4,a4,-1066 # 8000a408 <ticks>
    8000283a:	431c                	lw	a5,0(a4)
    8000283c:	2785                	addiw	a5,a5,1
    8000283e:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002840:	853a                	mv	a0,a4
    80002842:	963ff0ef          	jal	800021a4 <wakeup>
    release(&tickslock);
    80002846:	00016517          	auipc	a0,0x16
    8000284a:	cf250513          	addi	a0,a0,-782 # 80018538 <tickslock>
    8000284e:	c62fe0ef          	jal	80000cb0 <release>
    80002852:	bf6d                	j	8000280c <clockintr+0xe>

0000000080002854 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002854:	1101                	addi	sp,sp,-32
    80002856:	ec06                	sd	ra,24(sp)
    80002858:	e822                	sd	s0,16(sp)
    8000285a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    8000285c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002860:	57fd                	li	a5,-1
    80002862:	17fe                	slli	a5,a5,0x3f
    80002864:	07a5                	addi	a5,a5,9
    80002866:	00f70c63          	beq	a4,a5,8000287e <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    8000286a:	57fd                	li	a5,-1
    8000286c:	17fe                	slli	a5,a5,0x3f
    8000286e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002870:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002872:	04f70863          	beq	a4,a5,800028c2 <devintr+0x6e>
  }
}
    80002876:	60e2                	ld	ra,24(sp)
    80002878:	6442                	ld	s0,16(sp)
    8000287a:	6105                	addi	sp,sp,32
    8000287c:	8082                	ret
    8000287e:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002880:	16e030ef          	jal	800059ee <plic_claim>
    80002884:	872a                	mv	a4,a0
    80002886:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002888:	47a9                	li	a5,10
    8000288a:	00f50963          	beq	a0,a5,8000289c <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    8000288e:	4785                	li	a5,1
    80002890:	00f50963          	beq	a0,a5,800028a2 <devintr+0x4e>
    return 1;
    80002894:	4505                	li	a0,1
    } else if (irq) {
    80002896:	eb09                	bnez	a4,800028a8 <devintr+0x54>
    80002898:	64a2                	ld	s1,8(sp)
    8000289a:	bff1                	j	80002876 <devintr+0x22>
      uartintr();
    8000289c:	952fe0ef          	jal	800009ee <uartintr>
    if (irq)
    800028a0:	a819                	j	800028b6 <devintr+0x62>
      virtio_disk_intr();
    800028a2:	608030ef          	jal	80005eaa <virtio_disk_intr>
    if (irq)
    800028a6:	a801                	j	800028b6 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    800028a8:	85ba                	mv	a1,a4
    800028aa:	00005517          	auipc	a0,0x5
    800028ae:	9c650513          	addi	a0,a0,-1594 # 80007270 <etext+0x270>
    800028b2:	c59fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    800028b6:	8526                	mv	a0,s1
    800028b8:	158030ef          	jal	80005a10 <plic_complete>
    return 1;
    800028bc:	4505                	li	a0,1
    800028be:	64a2                	ld	s1,8(sp)
    800028c0:	bf5d                	j	80002876 <devintr+0x22>
    clockintr();
    800028c2:	f3dff0ef          	jal	800027fe <clockintr>
    return 2;
    800028c6:	4509                	li	a0,2
    800028c8:	b77d                	j	80002876 <devintr+0x22>

00000000800028ca <usertrap>:
{
    800028ca:	1101                	addi	sp,sp,-32
    800028cc:	ec06                	sd	ra,24(sp)
    800028ce:	e822                	sd	s0,16(sp)
    800028d0:	e426                	sd	s1,8(sp)
    800028d2:	e04a                	sd	s2,0(sp)
    800028d4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800028d6:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800028da:	1007f793          	andi	a5,a5,256
    800028de:	eba5                	bnez	a5,8000294e <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800028e0:	00003797          	auipc	a5,0x3
    800028e4:	06078793          	addi	a5,a5,96 # 80005940 <kernelvec>
    800028e8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028ec:	85cff0ef          	jal	80001948 <myproc>
    800028f0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800028f2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800028f4:	14102773          	csrr	a4,sepc
    800028f8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800028fa:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800028fe:	47a1                	li	a5,8
    80002900:	04f70d63          	beq	a4,a5,8000295a <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    80002904:	f51ff0ef          	jal	80002854 <devintr>
    80002908:	892a                	mv	s2,a0
    8000290a:	e54d                	bnez	a0,800029b4 <usertrap+0xea>
    8000290c:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002910:	47bd                	li	a5,15
    80002912:	08f70463          	beq	a4,a5,8000299a <usertrap+0xd0>
    80002916:	14202773          	csrr	a4,scause
    8000291a:	47b5                	li	a5,13
    8000291c:	06f70f63          	beq	a4,a5,8000299a <usertrap+0xd0>
    80002920:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002924:	5890                	lw	a2,48(s1)
    80002926:	00005517          	auipc	a0,0x5
    8000292a:	98a50513          	addi	a0,a0,-1654 # 800072b0 <etext+0x2b0>
    8000292e:	bddfd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002932:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002936:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000293a:	00005517          	auipc	a0,0x5
    8000293e:	9a650513          	addi	a0,a0,-1626 # 800072e0 <etext+0x2e0>
    80002942:	bc9fd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002946:	8526                	mv	a0,s1
    80002948:	a2bff0ef          	jal	80002372 <setkilled>
    8000294c:	a015                	j	80002970 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    8000294e:	00005517          	auipc	a0,0x5
    80002952:	94250513          	addi	a0,a0,-1726 # 80007290 <etext+0x290>
    80002956:	edffd0ef          	jal	80000834 <panic>
    if (killed(p))
    8000295a:	a3dff0ef          	jal	80002396 <killed>
    8000295e:	e915                	bnez	a0,80002992 <usertrap+0xc8>
    p->trapframe->epc += 4;
    80002960:	6cb8                	ld	a4,88(s1)
    80002962:	6f1c                	ld	a5,24(a4)
    80002964:	0791                	addi	a5,a5,4
    80002966:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002968:	10016073          	csrsi	sstatus,2
    syscall();
    8000296c:	244000ef          	jal	80002bb0 <syscall>
  if (killed(p))
    80002970:	8526                	mv	a0,s1
    80002972:	a25ff0ef          	jal	80002396 <killed>
    80002976:	e521                	bnez	a0,800029be <usertrap+0xf4>
  prepare_return();
    80002978:	e13ff0ef          	jal	8000278a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000297c:	68a8                	ld	a0,80(s1)
    8000297e:	8131                	srli	a0,a0,0xc
    80002980:	57fd                	li	a5,-1
    80002982:	17fe                	slli	a5,a5,0x3f
    80002984:	8d5d                	or	a0,a0,a5
}
    80002986:	60e2                	ld	ra,24(sp)
    80002988:	6442                	ld	s0,16(sp)
    8000298a:	64a2                	ld	s1,8(sp)
    8000298c:	6902                	ld	s2,0(sp)
    8000298e:	6105                	addi	sp,sp,32
    80002990:	8082                	ret
      kexit(-1);
    80002992:	557d                	li	a0,-1
    80002994:	8cdff0ef          	jal	80002260 <kexit>
    80002998:	b7e1                	j	80002960 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    8000299a:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    8000299e:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    800029a2:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    800029a4:	0016b693          	seqz	a3,a3
    800029a8:	64ac                	ld	a1,72(s1)
    800029aa:	68a8                	ld	a0,80(s1)
    800029ac:	b5bfe0ef          	jal	80001506 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800029b0:	f161                	bnez	a0,80002970 <usertrap+0xa6>
    800029b2:	b7bd                	j	80002920 <usertrap+0x56>
  if (killed(p))
    800029b4:	8526                	mv	a0,s1
    800029b6:	9e1ff0ef          	jal	80002396 <killed>
    800029ba:	c511                	beqz	a0,800029c6 <usertrap+0xfc>
    800029bc:	a011                	j	800029c0 <usertrap+0xf6>
    800029be:	4901                	li	s2,0
    kexit(-1);
    800029c0:	557d                	li	a0,-1
    800029c2:	89fff0ef          	jal	80002260 <kexit>
  if (which_dev == 2)
    800029c6:	4789                	li	a5,2
    800029c8:	faf918e3          	bne	s2,a5,80002978 <usertrap+0xae>
    yield();
    800029cc:	f40ff0ef          	jal	8000210c <yield>
    800029d0:	b765                	j	80002978 <usertrap+0xae>

00000000800029d2 <kerneltrap>:
{
    800029d2:	7179                	addi	sp,sp,-48
    800029d4:	f406                	sd	ra,40(sp)
    800029d6:	f022                	sd	s0,32(sp)
    800029d8:	ec26                	sd	s1,24(sp)
    800029da:	e84a                	sd	s2,16(sp)
    800029dc:	e44e                	sd	s3,8(sp)
    800029de:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    800029e0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800029e4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800029e8:	142027f3          	csrr	a5,scause
    800029ec:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    800029ee:	1004f793          	andi	a5,s1,256
    800029f2:	c795                	beqz	a5,80002a1e <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800029f4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029f8:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800029fa:	eb85                	bnez	a5,80002a2a <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    800029fc:	e59ff0ef          	jal	80002854 <devintr>
    80002a00:	c91d                	beqz	a0,80002a36 <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    80002a02:	4789                	li	a5,2
    80002a04:	04f50a63          	beq	a0,a5,80002a58 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002a08:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002a0c:	10049073          	csrw	sstatus,s1
}
    80002a10:	70a2                	ld	ra,40(sp)
    80002a12:	7402                	ld	s0,32(sp)
    80002a14:	64e2                	ld	s1,24(sp)
    80002a16:	6942                	ld	s2,16(sp)
    80002a18:	69a2                	ld	s3,8(sp)
    80002a1a:	6145                	addi	sp,sp,48
    80002a1c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a1e:	00005517          	auipc	a0,0x5
    80002a22:	8ea50513          	addi	a0,a0,-1814 # 80007308 <etext+0x308>
    80002a26:	e0ffd0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a2a:	00005517          	auipc	a0,0x5
    80002a2e:	90650513          	addi	a0,a0,-1786 # 80007330 <etext+0x330>
    80002a32:	e03fd0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002a36:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002a3a:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    80002a3e:	85ce                	mv	a1,s3
    80002a40:	00005517          	auipc	a0,0x5
    80002a44:	91050513          	addi	a0,a0,-1776 # 80007350 <etext+0x350>
    80002a48:	ac3fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    80002a4c:	00005517          	auipc	a0,0x5
    80002a50:	92c50513          	addi	a0,a0,-1748 # 80007378 <etext+0x378>
    80002a54:	de1fd0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    80002a58:	ef1fe0ef          	jal	80001948 <myproc>
    80002a5c:	d555                	beqz	a0,80002a08 <kerneltrap+0x36>
    yield();
    80002a5e:	eaeff0ef          	jal	8000210c <yield>
    80002a62:	b75d                	j	80002a08 <kerneltrap+0x36>

0000000080002a64 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a64:	1101                	addi	sp,sp,-32
    80002a66:	ec06                	sd	ra,24(sp)
    80002a68:	e822                	sd	s0,16(sp)
    80002a6a:	e426                	sd	s1,8(sp)
    80002a6c:	1000                	addi	s0,sp,32
    80002a6e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a70:	ed9fe0ef          	jal	80001948 <myproc>
  switch (n) {
    80002a74:	4795                	li	a5,5
    80002a76:	0497e163          	bltu	a5,s1,80002ab8 <argraw+0x54>
    80002a7a:	048a                	slli	s1,s1,0x2
    80002a7c:	00005717          	auipc	a4,0x5
    80002a80:	cfc70713          	addi	a4,a4,-772 # 80007778 <states.0+0x30>
    80002a84:	94ba                	add	s1,s1,a4
    80002a86:	409c                	lw	a5,0(s1)
    80002a88:	97ba                	add	a5,a5,a4
    80002a8a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a8c:	6d3c                	ld	a5,88(a0)
    80002a8e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a90:	60e2                	ld	ra,24(sp)
    80002a92:	6442                	ld	s0,16(sp)
    80002a94:	64a2                	ld	s1,8(sp)
    80002a96:	6105                	addi	sp,sp,32
    80002a98:	8082                	ret
    return p->trapframe->a1;
    80002a9a:	6d3c                	ld	a5,88(a0)
    80002a9c:	7fa8                	ld	a0,120(a5)
    80002a9e:	bfcd                	j	80002a90 <argraw+0x2c>
    return p->trapframe->a2;
    80002aa0:	6d3c                	ld	a5,88(a0)
    80002aa2:	63c8                	ld	a0,128(a5)
    80002aa4:	b7f5                	j	80002a90 <argraw+0x2c>
    return p->trapframe->a3;
    80002aa6:	6d3c                	ld	a5,88(a0)
    80002aa8:	67c8                	ld	a0,136(a5)
    80002aaa:	b7dd                	j	80002a90 <argraw+0x2c>
    return p->trapframe->a4;
    80002aac:	6d3c                	ld	a5,88(a0)
    80002aae:	6bc8                	ld	a0,144(a5)
    80002ab0:	b7c5                	j	80002a90 <argraw+0x2c>
    return p->trapframe->a5;
    80002ab2:	6d3c                	ld	a5,88(a0)
    80002ab4:	6fc8                	ld	a0,152(a5)
    80002ab6:	bfe9                	j	80002a90 <argraw+0x2c>
  panic("argraw");
    80002ab8:	00005517          	auipc	a0,0x5
    80002abc:	8d050513          	addi	a0,a0,-1840 # 80007388 <etext+0x388>
    80002ac0:	d75fd0ef          	jal	80000834 <panic>

0000000080002ac4 <fetchaddr>:
{
    80002ac4:	1101                	addi	sp,sp,-32
    80002ac6:	ec06                	sd	ra,24(sp)
    80002ac8:	e822                	sd	s0,16(sp)
    80002aca:	e426                	sd	s1,8(sp)
    80002acc:	e04a                	sd	s2,0(sp)
    80002ace:	1000                	addi	s0,sp,32
    80002ad0:	84aa                	mv	s1,a0
    80002ad2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ad4:	e75fe0ef          	jal	80001948 <myproc>
  if (addr >= p->sz ||
    80002ad8:	652c                	ld	a1,72(a0)
    80002ada:	02b4f663          	bgeu	s1,a1,80002b06 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ade:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002ae2:	02f5e463          	bltu	a1,a5,80002b0a <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ae6:	4721                	li	a4,8
    80002ae8:	86a6                	mv	a3,s1
    80002aea:	864a                	mv	a2,s2
    80002aec:	6928                	ld	a0,80(a0)
    80002aee:	b5bfe0ef          	jal	80001648 <copyin>
    80002af2:	00a03533          	snez	a0,a0
    80002af6:	40a0053b          	negw	a0,a0
}
    80002afa:	60e2                	ld	ra,24(sp)
    80002afc:	6442                	ld	s0,16(sp)
    80002afe:	64a2                	ld	s1,8(sp)
    80002b00:	6902                	ld	s2,0(sp)
    80002b02:	6105                	addi	sp,sp,32
    80002b04:	8082                	ret
    return -1;
    80002b06:	557d                	li	a0,-1
    80002b08:	bfcd                	j	80002afa <fetchaddr+0x36>
    80002b0a:	557d                	li	a0,-1
    80002b0c:	b7fd                	j	80002afa <fetchaddr+0x36>

0000000080002b0e <fetchstr>:
{
    80002b0e:	7179                	addi	sp,sp,-48
    80002b10:	f406                	sd	ra,40(sp)
    80002b12:	f022                	sd	s0,32(sp)
    80002b14:	ec26                	sd	s1,24(sp)
    80002b16:	e84a                	sd	s2,16(sp)
    80002b18:	e44e                	sd	s3,8(sp)
    80002b1a:	1800                	addi	s0,sp,48
    80002b1c:	89aa                	mv	s3,a0
    80002b1e:	84ae                	mv	s1,a1
    80002b20:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002b22:	e27fe0ef          	jal	80001948 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002b26:	874a                	mv	a4,s2
    80002b28:	86ce                	mv	a3,s3
    80002b2a:	8626                	mv	a2,s1
    80002b2c:	652c                	ld	a1,72(a0)
    80002b2e:	6928                	ld	a0,80(a0)
    80002b30:	bb5fe0ef          	jal	800016e4 <copyinstr>
    80002b34:	00054c63          	bltz	a0,80002b4c <fetchstr+0x3e>
  return strlen(buf);
    80002b38:	8526                	mv	a0,s1
    80002b3a:	b38fe0ef          	jal	80000e72 <strlen>
}
    80002b3e:	70a2                	ld	ra,40(sp)
    80002b40:	7402                	ld	s0,32(sp)
    80002b42:	64e2                	ld	s1,24(sp)
    80002b44:	6942                	ld	s2,16(sp)
    80002b46:	69a2                	ld	s3,8(sp)
    80002b48:	6145                	addi	sp,sp,48
    80002b4a:	8082                	ret
    return -1;
    80002b4c:	557d                	li	a0,-1
    80002b4e:	bfc5                	j	80002b3e <fetchstr+0x30>

0000000080002b50 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b50:	1101                	addi	sp,sp,-32
    80002b52:	ec06                	sd	ra,24(sp)
    80002b54:	e822                	sd	s0,16(sp)
    80002b56:	e426                	sd	s1,8(sp)
    80002b58:	1000                	addi	s0,sp,32
    80002b5a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b5c:	f09ff0ef          	jal	80002a64 <argraw>
    80002b60:	c088                	sw	a0,0(s1)
}
    80002b62:	60e2                	ld	ra,24(sp)
    80002b64:	6442                	ld	s0,16(sp)
    80002b66:	64a2                	ld	s1,8(sp)
    80002b68:	6105                	addi	sp,sp,32
    80002b6a:	8082                	ret

0000000080002b6c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b6c:	1101                	addi	sp,sp,-32
    80002b6e:	ec06                	sd	ra,24(sp)
    80002b70:	e822                	sd	s0,16(sp)
    80002b72:	e426                	sd	s1,8(sp)
    80002b74:	1000                	addi	s0,sp,32
    80002b76:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b78:	eedff0ef          	jal	80002a64 <argraw>
    80002b7c:	e088                	sd	a0,0(s1)
}
    80002b7e:	60e2                	ld	ra,24(sp)
    80002b80:	6442                	ld	s0,16(sp)
    80002b82:	64a2                	ld	s1,8(sp)
    80002b84:	6105                	addi	sp,sp,32
    80002b86:	8082                	ret

0000000080002b88 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b88:	1101                	addi	sp,sp,-32
    80002b8a:	ec06                	sd	ra,24(sp)
    80002b8c:	e822                	sd	s0,16(sp)
    80002b8e:	e426                	sd	s1,8(sp)
    80002b90:	e04a                	sd	s2,0(sp)
    80002b92:	1000                	addi	s0,sp,32
    80002b94:	892e                	mv	s2,a1
    80002b96:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002b98:	ecdff0ef          	jal	80002a64 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002b9c:	8626                	mv	a2,s1
    80002b9e:	85ca                	mv	a1,s2
    80002ba0:	f6fff0ef          	jal	80002b0e <fetchstr>
}
    80002ba4:	60e2                	ld	ra,24(sp)
    80002ba6:	6442                	ld	s0,16(sp)
    80002ba8:	64a2                	ld	s1,8(sp)
    80002baa:	6902                	ld	s2,0(sp)
    80002bac:	6105                	addi	sp,sp,32
    80002bae:	8082                	ret

0000000080002bb0 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002bb0:	1101                	addi	sp,sp,-32
    80002bb2:	ec06                	sd	ra,24(sp)
    80002bb4:	e822                	sd	s0,16(sp)
    80002bb6:	e426                	sd	s1,8(sp)
    80002bb8:	e04a                	sd	s2,0(sp)
    80002bba:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bbc:	d8dfe0ef          	jal	80001948 <myproc>
    80002bc0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002bc2:	05853903          	ld	s2,88(a0)
    80002bc6:	0a893783          	ld	a5,168(s2)
    80002bca:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bce:	37fd                	addiw	a5,a5,-1
    80002bd0:	475d                	li	a4,23
    80002bd2:	00f76f63          	bltu	a4,a5,80002bf0 <syscall+0x40>
    80002bd6:	00369713          	slli	a4,a3,0x3
    80002bda:	00005797          	auipc	a5,0x5
    80002bde:	bb678793          	addi	a5,a5,-1098 # 80007790 <syscalls>
    80002be2:	97ba                	add	a5,a5,a4
    80002be4:	639c                	ld	a5,0(a5)
    80002be6:	c789                	beqz	a5,80002bf0 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002be8:	9782                	jalr	a5
    80002bea:	06a93823          	sd	a0,112(s2)
    80002bee:	a829                	j	80002c08 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002bf0:	15848613          	addi	a2,s1,344
    80002bf4:	588c                	lw	a1,48(s1)
    80002bf6:	00004517          	auipc	a0,0x4
    80002bfa:	79a50513          	addi	a0,a0,1946 # 80007390 <etext+0x390>
    80002bfe:	90dfd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002c02:	6cbc                	ld	a5,88(s1)
    80002c04:	577d                	li	a4,-1
    80002c06:	fbb8                	sd	a4,112(a5)
  }
}
    80002c08:	60e2                	ld	ra,24(sp)
    80002c0a:	6442                	ld	s0,16(sp)
    80002c0c:	64a2                	ld	s1,8(sp)
    80002c0e:	6902                	ld	s2,0(sp)
    80002c10:	6105                	addi	sp,sp,32
    80002c12:	8082                	ret

0000000080002c14 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002c14:	1101                	addi	sp,sp,-32
    80002c16:	ec06                	sd	ra,24(sp)
    80002c18:	e822                	sd	s0,16(sp)
    80002c1a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c1c:	fec40593          	addi	a1,s0,-20
    80002c20:	4501                	li	a0,0
    80002c22:	f2fff0ef          	jal	80002b50 <argint>
  kexit(n);
    80002c26:	fec42503          	lw	a0,-20(s0)
    80002c2a:	e36ff0ef          	jal	80002260 <kexit>
  return 0; // not reached
}
    80002c2e:	4501                	li	a0,0
    80002c30:	60e2                	ld	ra,24(sp)
    80002c32:	6442                	ld	s0,16(sp)
    80002c34:	6105                	addi	sp,sp,32
    80002c36:	8082                	ret

0000000080002c38 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c38:	1141                	addi	sp,sp,-16
    80002c3a:	e406                	sd	ra,8(sp)
    80002c3c:	e022                	sd	s0,0(sp)
    80002c3e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c40:	d09fe0ef          	jal	80001948 <myproc>
}
    80002c44:	5908                	lw	a0,48(a0)
    80002c46:	60a2                	ld	ra,8(sp)
    80002c48:	6402                	ld	s0,0(sp)
    80002c4a:	0141                	addi	sp,sp,16
    80002c4c:	8082                	ret

0000000080002c4e <sys_fork>:

uint64
sys_fork(void)
{
    80002c4e:	1141                	addi	sp,sp,-16
    80002c50:	e406                	sd	ra,8(sp)
    80002c52:	e022                	sd	s0,0(sp)
    80002c54:	0800                	addi	s0,sp,16
  return kfork();
    80002c56:	8a4ff0ef          	jal	80001cfa <kfork>
}
    80002c5a:	60a2                	ld	ra,8(sp)
    80002c5c:	6402                	ld	s0,0(sp)
    80002c5e:	0141                	addi	sp,sp,16
    80002c60:	8082                	ret

0000000080002c62 <sys_wait>:

uint64
sys_wait(void)
{
    80002c62:	1101                	addi	sp,sp,-32
    80002c64:	ec06                	sd	ra,24(sp)
    80002c66:	e822                	sd	s0,16(sp)
    80002c68:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c6a:	fe840593          	addi	a1,s0,-24
    80002c6e:	4501                	li	a0,0
    80002c70:	efdff0ef          	jal	80002b6c <argaddr>
  return kwait(p);
    80002c74:	fe843503          	ld	a0,-24(s0)
    80002c78:	f48ff0ef          	jal	800023c0 <kwait>
}
    80002c7c:	60e2                	ld	ra,24(sp)
    80002c7e:	6442                	ld	s0,16(sp)
    80002c80:	6105                	addi	sp,sp,32
    80002c82:	8082                	ret

0000000080002c84 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c84:	7179                	addi	sp,sp,-48
    80002c86:	f406                	sd	ra,40(sp)
    80002c88:	f022                	sd	s0,32(sp)
    80002c8a:	ec26                	sd	s1,24(sp)
    80002c8c:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002c8e:	fd840593          	addi	a1,s0,-40
    80002c92:	4501                	li	a0,0
    80002c94:	ebdff0ef          	jal	80002b50 <argint>
  argint(1, &t);
    80002c98:	fdc40593          	addi	a1,s0,-36
    80002c9c:	4505                	li	a0,1
    80002c9e:	eb3ff0ef          	jal	80002b50 <argint>
  addr = myproc()->sz;
    80002ca2:	ca7fe0ef          	jal	80001948 <myproc>
    80002ca6:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002ca8:	fdc42703          	lw	a4,-36(s0)
    80002cac:	4785                	li	a5,1
    80002cae:	02f70763          	beq	a4,a5,80002cdc <sys_sbrk+0x58>
    80002cb2:	fd842783          	lw	a5,-40(s0)
    80002cb6:	0207c363          	bltz	a5,80002cdc <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002cba:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002cbc:	02000737          	lui	a4,0x2000
    80002cc0:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002cc2:	0736                	slli	a4,a4,0xd
    80002cc4:	02f76a63          	bltu	a4,a5,80002cf8 <sys_sbrk+0x74>
    80002cc8:	0297e863          	bltu	a5,s1,80002cf8 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002ccc:	c7dfe0ef          	jal	80001948 <myproc>
    80002cd0:	fd842703          	lw	a4,-40(s0)
    80002cd4:	653c                	ld	a5,72(a0)
    80002cd6:	97ba                	add	a5,a5,a4
    80002cd8:	e53c                	sd	a5,72(a0)
    80002cda:	a039                	j	80002ce8 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002cdc:	fd842503          	lw	a0,-40(s0)
    80002ce0:	fb9fe0ef          	jal	80001c98 <growproc>
    80002ce4:	00054863          	bltz	a0,80002cf4 <sys_sbrk+0x70>
  }
  return addr;
}
    80002ce8:	8526                	mv	a0,s1
    80002cea:	70a2                	ld	ra,40(sp)
    80002cec:	7402                	ld	s0,32(sp)
    80002cee:	64e2                	ld	s1,24(sp)
    80002cf0:	6145                	addi	sp,sp,48
    80002cf2:	8082                	ret
      return -1;
    80002cf4:	54fd                	li	s1,-1
    80002cf6:	bfcd                	j	80002ce8 <sys_sbrk+0x64>
      return -1;
    80002cf8:	54fd                	li	s1,-1
    80002cfa:	b7fd                	j	80002ce8 <sys_sbrk+0x64>

0000000080002cfc <sys_pause>:

uint64
sys_pause(void)
{
    80002cfc:	7139                	addi	sp,sp,-64
    80002cfe:	fc06                	sd	ra,56(sp)
    80002d00:	f822                	sd	s0,48(sp)
    80002d02:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d04:	fcc40593          	addi	a1,s0,-52
    80002d08:	4501                	li	a0,0
    80002d0a:	e47ff0ef          	jal	80002b50 <argint>
  if (n < 0)
    80002d0e:	fcc42783          	lw	a5,-52(s0)
    80002d12:	0807c063          	bltz	a5,80002d92 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002d16:	00016517          	auipc	a0,0x16
    80002d1a:	82250513          	addi	a0,a0,-2014 # 80018538 <tickslock>
    80002d1e:	f0bfd0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002d22:	fcc42783          	lw	a5,-52(s0)
    80002d26:	cbb9                	beqz	a5,80002d7c <sys_pause+0x80>
    80002d28:	f426                	sd	s1,40(sp)
    80002d2a:	f04a                	sd	s2,32(sp)
    80002d2c:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002d2e:	00007997          	auipc	s3,0x7
    80002d32:	6da9a983          	lw	s3,1754(s3) # 8000a408 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002d36:	00007917          	auipc	s2,0x7
    80002d3a:	6d290913          	addi	s2,s2,1746 # 8000a408 <ticks>
    release(&tickslock);
    80002d3e:	00015497          	auipc	s1,0x15
    80002d42:	7fa48493          	addi	s1,s1,2042 # 80018538 <tickslock>
    if (killed(myproc())) {
    80002d46:	c03fe0ef          	jal	80001948 <myproc>
    80002d4a:	e4cff0ef          	jal	80002396 <killed>
    80002d4e:	e529                	bnez	a0,80002d98 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002d50:	854a                	mv	a0,s2
    80002d52:	be6ff0ef          	jal	80002138 <sleep_prepare>
    release(&tickslock);
    80002d56:	8526                	mv	a0,s1
    80002d58:	f59fd0ef          	jal	80000cb0 <release>
    sleep();
    80002d5c:	c18ff0ef          	jal	80002174 <sleep>
    acquire(&tickslock);
    80002d60:	8526                	mv	a0,s1
    80002d62:	ec7fd0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002d66:	00092783          	lw	a5,0(s2)
    80002d6a:	413787bb          	subw	a5,a5,s3
    80002d6e:	fcc42703          	lw	a4,-52(s0)
    80002d72:	fce7eae3          	bltu	a5,a4,80002d46 <sys_pause+0x4a>
    80002d76:	74a2                	ld	s1,40(sp)
    80002d78:	7902                	ld	s2,32(sp)
    80002d7a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002d7c:	00015517          	auipc	a0,0x15
    80002d80:	7bc50513          	addi	a0,a0,1980 # 80018538 <tickslock>
    80002d84:	f2dfd0ef          	jal	80000cb0 <release>
  return 0;
    80002d88:	4501                	li	a0,0
}
    80002d8a:	70e2                	ld	ra,56(sp)
    80002d8c:	7442                	ld	s0,48(sp)
    80002d8e:	6121                	addi	sp,sp,64
    80002d90:	8082                	ret
    n = 0;
    80002d92:	fc042623          	sw	zero,-52(s0)
    80002d96:	b741                	j	80002d16 <sys_pause+0x1a>
      release(&tickslock);
    80002d98:	00015517          	auipc	a0,0x15
    80002d9c:	7a050513          	addi	a0,a0,1952 # 80018538 <tickslock>
    80002da0:	f11fd0ef          	jal	80000cb0 <release>
      return -1;
    80002da4:	557d                	li	a0,-1
    80002da6:	74a2                	ld	s1,40(sp)
    80002da8:	7902                	ld	s2,32(sp)
    80002daa:	69e2                	ld	s3,24(sp)
    80002dac:	bff9                	j	80002d8a <sys_pause+0x8e>

0000000080002dae <sys_kill>:

uint64
sys_kill(void)
{
    80002dae:	1101                	addi	sp,sp,-32
    80002db0:	ec06                	sd	ra,24(sp)
    80002db2:	e822                	sd	s0,16(sp)
    80002db4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002db6:	fec40593          	addi	a1,s0,-20
    80002dba:	4501                	li	a0,0
    80002dbc:	d95ff0ef          	jal	80002b50 <argint>
  return kkill(pid);
    80002dc0:	fec42503          	lw	a0,-20(s0)
    80002dc4:	d42ff0ef          	jal	80002306 <kkill>
}
    80002dc8:	60e2                	ld	ra,24(sp)
    80002dca:	6442                	ld	s0,16(sp)
    80002dcc:	6105                	addi	sp,sp,32
    80002dce:	8082                	ret

0000000080002dd0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002dd0:	1101                	addi	sp,sp,-32
    80002dd2:	ec06                	sd	ra,24(sp)
    80002dd4:	e822                	sd	s0,16(sp)
    80002dd6:	e426                	sd	s1,8(sp)
    80002dd8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dda:	00015517          	auipc	a0,0x15
    80002dde:	75e50513          	addi	a0,a0,1886 # 80018538 <tickslock>
    80002de2:	e47fd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002de6:	00007797          	auipc	a5,0x7
    80002dea:	6227a783          	lw	a5,1570(a5) # 8000a408 <ticks>
    80002dee:	84be                	mv	s1,a5
  release(&tickslock);
    80002df0:	00015517          	auipc	a0,0x15
    80002df4:	74850513          	addi	a0,a0,1864 # 80018538 <tickslock>
    80002df8:	eb9fd0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002dfc:	02049513          	slli	a0,s1,0x20
    80002e00:	9101                	srli	a0,a0,0x20
    80002e02:	60e2                	ld	ra,24(sp)
    80002e04:	6442                	ld	s0,16(sp)
    80002e06:	64a2                	ld	s1,8(sp)
    80002e08:	6105                	addi	sp,sp,32
    80002e0a:	8082                	ret

0000000080002e0c <sys_clone>:

uint64
sys_clone(void)
{
    80002e0c:	7179                	addi	sp,sp,-48
    80002e0e:	f406                	sd	ra,40(sp)
    80002e10:	f022                	sd	s0,32(sp)
    80002e12:	1800                	addi	s0,sp,48
  uint64 fcn, arg, stack;
  argaddr(0, &fcn);
    80002e14:	fe840593          	addi	a1,s0,-24
    80002e18:	4501                	li	a0,0
    80002e1a:	d53ff0ef          	jal	80002b6c <argaddr>
  argaddr(1, &arg);
    80002e1e:	fe040593          	addi	a1,s0,-32
    80002e22:	4505                	li	a0,1
    80002e24:	d49ff0ef          	jal	80002b6c <argaddr>
  argaddr(2, &stack);
    80002e28:	fd840593          	addi	a1,s0,-40
    80002e2c:	4509                	li	a0,2
    80002e2e:	d3fff0ef          	jal	80002b6c <argaddr>
  return kclone(fcn, arg, stack);
    80002e32:	fd843603          	ld	a2,-40(s0)
    80002e36:	fe043583          	ld	a1,-32(s0)
    80002e3a:	fe843503          	ld	a0,-24(s0)
    80002e3e:	fcbfe0ef          	jal	80001e08 <kclone>
}
    80002e42:	70a2                	ld	ra,40(sp)
    80002e44:	7402                	ld	s0,32(sp)
    80002e46:	6145                	addi	sp,sp,48
    80002e48:	8082                	ret

0000000080002e4a <sys_join>:

uint64
sys_join(void)
{
    80002e4a:	1141                	addi	sp,sp,-16
    80002e4c:	e406                	sd	ra,8(sp)
    80002e4e:	e022                	sd	s0,0(sp)
    80002e50:	0800                	addi	s0,sp,16
  return kjoin();
    80002e52:	e7cff0ef          	jal	800024ce <kjoin>
}
    80002e56:	60a2                	ld	ra,8(sp)
    80002e58:	6402                	ld	s0,0(sp)
    80002e5a:	0141                	addi	sp,sp,16
    80002e5c:	8082                	ret

0000000080002e5e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e5e:	7179                	addi	sp,sp,-48
    80002e60:	f406                	sd	ra,40(sp)
    80002e62:	f022                	sd	s0,32(sp)
    80002e64:	ec26                	sd	s1,24(sp)
    80002e66:	e84a                	sd	s2,16(sp)
    80002e68:	e44e                	sd	s3,8(sp)
    80002e6a:	e052                	sd	s4,0(sp)
    80002e6c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e6e:	00004597          	auipc	a1,0x4
    80002e72:	54258593          	addi	a1,a1,1346 # 800073b0 <etext+0x3b0>
    80002e76:	00015517          	auipc	a0,0x15
    80002e7a:	6da50513          	addi	a0,a0,1754 # 80018550 <bcache>
    80002e7e:	d2bfd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e82:	0001d797          	auipc	a5,0x1d
    80002e86:	6ce78793          	addi	a5,a5,1742 # 80020550 <bcache+0x8000>
    80002e8a:	0001e717          	auipc	a4,0x1e
    80002e8e:	92e70713          	addi	a4,a4,-1746 # 800207b8 <bcache+0x8268>
    80002e92:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e96:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002e9a:	00015497          	auipc	s1,0x15
    80002e9e:	6ce48493          	addi	s1,s1,1742 # 80018568 <bcache+0x18>
    b->next = bcache.head.next;
    80002ea2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ea4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ea6:	00004a17          	auipc	s4,0x4
    80002eaa:	512a0a13          	addi	s4,s4,1298 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002eae:	2b893783          	ld	a5,696(s2)
    80002eb2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002eb4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002eb8:	85d2                	mv	a1,s4
    80002eba:	01048513          	addi	a0,s1,16
    80002ebe:	41c010ef          	jal	800042da <initsleeplock>
    bcache.head.next->prev = b;
    80002ec2:	2b893783          	ld	a5,696(s2)
    80002ec6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002ec8:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002ecc:	45848493          	addi	s1,s1,1112
    80002ed0:	fd349fe3          	bne	s1,s3,80002eae <binit+0x50>
  }
}
    80002ed4:	70a2                	ld	ra,40(sp)
    80002ed6:	7402                	ld	s0,32(sp)
    80002ed8:	64e2                	ld	s1,24(sp)
    80002eda:	6942                	ld	s2,16(sp)
    80002edc:	69a2                	ld	s3,8(sp)
    80002ede:	6a02                	ld	s4,0(sp)
    80002ee0:	6145                	addi	sp,sp,48
    80002ee2:	8082                	ret

0000000080002ee4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002ee4:	7179                	addi	sp,sp,-48
    80002ee6:	f406                	sd	ra,40(sp)
    80002ee8:	f022                	sd	s0,32(sp)
    80002eea:	ec26                	sd	s1,24(sp)
    80002eec:	e84a                	sd	s2,16(sp)
    80002eee:	e44e                	sd	s3,8(sp)
    80002ef0:	1800                	addi	s0,sp,48
    80002ef2:	892a                	mv	s2,a0
    80002ef4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ef6:	00015517          	auipc	a0,0x15
    80002efa:	65a50513          	addi	a0,a0,1626 # 80018550 <bcache>
    80002efe:	d2bfd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002f02:	0001e497          	auipc	s1,0x1e
    80002f06:	9064b483          	ld	s1,-1786(s1) # 80020808 <bcache+0x82b8>
    80002f0a:	0001e797          	auipc	a5,0x1e
    80002f0e:	8ae78793          	addi	a5,a5,-1874 # 800207b8 <bcache+0x8268>
    80002f12:	02f48b63          	beq	s1,a5,80002f48 <bread+0x64>
    80002f16:	873e                	mv	a4,a5
    80002f18:	a021                	j	80002f20 <bread+0x3c>
    80002f1a:	68a4                	ld	s1,80(s1)
    80002f1c:	02e48663          	beq	s1,a4,80002f48 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002f20:	449c                	lw	a5,8(s1)
    80002f22:	ff279ce3          	bne	a5,s2,80002f1a <bread+0x36>
    80002f26:	44dc                	lw	a5,12(s1)
    80002f28:	ff3799e3          	bne	a5,s3,80002f1a <bread+0x36>
      b->refcnt++;
    80002f2c:	40bc                	lw	a5,64(s1)
    80002f2e:	2785                	addiw	a5,a5,1
    80002f30:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f32:	00015517          	auipc	a0,0x15
    80002f36:	61e50513          	addi	a0,a0,1566 # 80018550 <bcache>
    80002f3a:	d77fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002f3e:	01048513          	addi	a0,s1,16
    80002f42:	3ce010ef          	jal	80004310 <acquiresleep>
      return b;
    80002f46:	a889                	j	80002f98 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002f48:	0001e497          	auipc	s1,0x1e
    80002f4c:	8b84b483          	ld	s1,-1864(s1) # 80020800 <bcache+0x82b0>
    80002f50:	0001e797          	auipc	a5,0x1e
    80002f54:	86878793          	addi	a5,a5,-1944 # 800207b8 <bcache+0x8268>
    80002f58:	00f48863          	beq	s1,a5,80002f68 <bread+0x84>
    80002f5c:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002f5e:	40bc                	lw	a5,64(s1)
    80002f60:	cb91                	beqz	a5,80002f74 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002f62:	64a4                	ld	s1,72(s1)
    80002f64:	fee49de3          	bne	s1,a4,80002f5e <bread+0x7a>
  panic("bget: no buffers");
    80002f68:	00004517          	auipc	a0,0x4
    80002f6c:	45850513          	addi	a0,a0,1112 # 800073c0 <etext+0x3c0>
    80002f70:	8c5fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002f74:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f78:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f7c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f80:	4785                	li	a5,1
    80002f82:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f84:	00015517          	auipc	a0,0x15
    80002f88:	5cc50513          	addi	a0,a0,1484 # 80018550 <bcache>
    80002f8c:	d25fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002f90:	01048513          	addi	a0,s1,16
    80002f94:	37c010ef          	jal	80004310 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002f98:	409c                	lw	a5,0(s1)
    80002f9a:	cb89                	beqz	a5,80002fac <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f9c:	8526                	mv	a0,s1
    80002f9e:	70a2                	ld	ra,40(sp)
    80002fa0:	7402                	ld	s0,32(sp)
    80002fa2:	64e2                	ld	s1,24(sp)
    80002fa4:	6942                	ld	s2,16(sp)
    80002fa6:	69a2                	ld	s3,8(sp)
    80002fa8:	6145                	addi	sp,sp,48
    80002faa:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fac:	4581                	li	a1,0
    80002fae:	8526                	mv	a0,s1
    80002fb0:	4c7020ef          	jal	80005c76 <virtio_disk_rw>
    b->valid = 1;
    80002fb4:	4785                	li	a5,1
    80002fb6:	c09c                	sw	a5,0(s1)
  return b;
    80002fb8:	b7d5                	j	80002f9c <bread+0xb8>

0000000080002fba <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002fba:	1101                	addi	sp,sp,-32
    80002fbc:	ec06                	sd	ra,24(sp)
    80002fbe:	e822                	sd	s0,16(sp)
    80002fc0:	e426                	sd	s1,8(sp)
    80002fc2:	1000                	addi	s0,sp,32
    80002fc4:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002fc6:	0541                	addi	a0,a0,16
    80002fc8:	3d4010ef          	jal	8000439c <holdingsleep>
    80002fcc:	c911                	beqz	a0,80002fe0 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002fce:	4585                	li	a1,1
    80002fd0:	8526                	mv	a0,s1
    80002fd2:	4a5020ef          	jal	80005c76 <virtio_disk_rw>
}
    80002fd6:	60e2                	ld	ra,24(sp)
    80002fd8:	6442                	ld	s0,16(sp)
    80002fda:	64a2                	ld	s1,8(sp)
    80002fdc:	6105                	addi	sp,sp,32
    80002fde:	8082                	ret
    panic("bwrite");
    80002fe0:	00004517          	auipc	a0,0x4
    80002fe4:	3f850513          	addi	a0,a0,1016 # 800073d8 <etext+0x3d8>
    80002fe8:	84dfd0ef          	jal	80000834 <panic>

0000000080002fec <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002fec:	1101                	addi	sp,sp,-32
    80002fee:	ec06                	sd	ra,24(sp)
    80002ff0:	e822                	sd	s0,16(sp)
    80002ff2:	e426                	sd	s1,8(sp)
    80002ff4:	e04a                	sd	s2,0(sp)
    80002ff6:	1000                	addi	s0,sp,32
    80002ff8:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002ffa:	01050913          	addi	s2,a0,16
    80002ffe:	854a                	mv	a0,s2
    80003000:	39c010ef          	jal	8000439c <holdingsleep>
    80003004:	c125                	beqz	a0,80003064 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80003006:	854a                	mv	a0,s2
    80003008:	35c010ef          	jal	80004364 <releasesleep>

  acquire(&bcache.lock);
    8000300c:	00015517          	auipc	a0,0x15
    80003010:	54450513          	addi	a0,a0,1348 # 80018550 <bcache>
    80003014:	c15fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80003018:	40bc                	lw	a5,64(s1)
    8000301a:	37fd                	addiw	a5,a5,-1
    8000301c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000301e:	e79d                	bnez	a5,8000304c <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003020:	68b8                	ld	a4,80(s1)
    80003022:	64bc                	ld	a5,72(s1)
    80003024:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003026:	68b8                	ld	a4,80(s1)
    80003028:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000302a:	0001d797          	auipc	a5,0x1d
    8000302e:	52678793          	addi	a5,a5,1318 # 80020550 <bcache+0x8000>
    80003032:	2b87b703          	ld	a4,696(a5)
    80003036:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003038:	0001d717          	auipc	a4,0x1d
    8000303c:	78070713          	addi	a4,a4,1920 # 800207b8 <bcache+0x8268>
    80003040:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003042:	2b87b703          	ld	a4,696(a5)
    80003046:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003048:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    8000304c:	00015517          	auipc	a0,0x15
    80003050:	50450513          	addi	a0,a0,1284 # 80018550 <bcache>
    80003054:	c5dfd0ef          	jal	80000cb0 <release>
}
    80003058:	60e2                	ld	ra,24(sp)
    8000305a:	6442                	ld	s0,16(sp)
    8000305c:	64a2                	ld	s1,8(sp)
    8000305e:	6902                	ld	s2,0(sp)
    80003060:	6105                	addi	sp,sp,32
    80003062:	8082                	ret
    panic("brelse");
    80003064:	00004517          	auipc	a0,0x4
    80003068:	37c50513          	addi	a0,a0,892 # 800073e0 <etext+0x3e0>
    8000306c:	fc8fd0ef          	jal	80000834 <panic>

0000000080003070 <bpin>:

void
bpin(struct buf *b)
{
    80003070:	1101                	addi	sp,sp,-32
    80003072:	ec06                	sd	ra,24(sp)
    80003074:	e822                	sd	s0,16(sp)
    80003076:	e426                	sd	s1,8(sp)
    80003078:	1000                	addi	s0,sp,32
    8000307a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000307c:	00015517          	auipc	a0,0x15
    80003080:	4d450513          	addi	a0,a0,1236 # 80018550 <bcache>
    80003084:	ba5fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80003088:	40bc                	lw	a5,64(s1)
    8000308a:	2785                	addiw	a5,a5,1
    8000308c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000308e:	00015517          	auipc	a0,0x15
    80003092:	4c250513          	addi	a0,a0,1218 # 80018550 <bcache>
    80003096:	c1bfd0ef          	jal	80000cb0 <release>
}
    8000309a:	60e2                	ld	ra,24(sp)
    8000309c:	6442                	ld	s0,16(sp)
    8000309e:	64a2                	ld	s1,8(sp)
    800030a0:	6105                	addi	sp,sp,32
    800030a2:	8082                	ret

00000000800030a4 <bunpin>:

void
bunpin(struct buf *b)
{
    800030a4:	1101                	addi	sp,sp,-32
    800030a6:	ec06                	sd	ra,24(sp)
    800030a8:	e822                	sd	s0,16(sp)
    800030aa:	e426                	sd	s1,8(sp)
    800030ac:	1000                	addi	s0,sp,32
    800030ae:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030b0:	00015517          	auipc	a0,0x15
    800030b4:	4a050513          	addi	a0,a0,1184 # 80018550 <bcache>
    800030b8:	b71fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    800030bc:	40bc                	lw	a5,64(s1)
    800030be:	37fd                	addiw	a5,a5,-1
    800030c0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030c2:	00015517          	auipc	a0,0x15
    800030c6:	48e50513          	addi	a0,a0,1166 # 80018550 <bcache>
    800030ca:	be7fd0ef          	jal	80000cb0 <release>
}
    800030ce:	60e2                	ld	ra,24(sp)
    800030d0:	6442                	ld	s0,16(sp)
    800030d2:	64a2                	ld	s1,8(sp)
    800030d4:	6105                	addi	sp,sp,32
    800030d6:	8082                	ret

00000000800030d8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030d8:	1101                	addi	sp,sp,-32
    800030da:	ec06                	sd	ra,24(sp)
    800030dc:	e822                	sd	s0,16(sp)
    800030de:	e426                	sd	s1,8(sp)
    800030e0:	e04a                	sd	s2,0(sp)
    800030e2:	1000                	addi	s0,sp,32
    800030e4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030e6:	00d5d79b          	srliw	a5,a1,0xd
    800030ea:	0001e597          	auipc	a1,0x1e
    800030ee:	b425a583          	lw	a1,-1214(a1) # 80020c2c <sb+0x1c>
    800030f2:	9dbd                	addw	a1,a1,a5
    800030f4:	df1ff0ef          	jal	80002ee4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030f8:	0074f713          	andi	a4,s1,7
    800030fc:	4785                	li	a5,1
    800030fe:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80003102:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80003104:	90d9                	srli	s1,s1,0x36
    80003106:	00950733          	add	a4,a0,s1
    8000310a:	05874703          	lbu	a4,88(a4)
    8000310e:	00e7f6b3          	and	a3,a5,a4
    80003112:	c29d                	beqz	a3,80003138 <bfree+0x60>
    80003114:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80003116:	94aa                	add	s1,s1,a0
    80003118:	fff7c793          	not	a5,a5
    8000311c:	8f7d                	and	a4,a4,a5
    8000311e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003122:	080010ef          	jal	800041a2 <log_write>
  brelse(bp);
    80003126:	854a                	mv	a0,s2
    80003128:	ec5ff0ef          	jal	80002fec <brelse>
}
    8000312c:	60e2                	ld	ra,24(sp)
    8000312e:	6442                	ld	s0,16(sp)
    80003130:	64a2                	ld	s1,8(sp)
    80003132:	6902                	ld	s2,0(sp)
    80003134:	6105                	addi	sp,sp,32
    80003136:	8082                	ret
    panic("freeing free block");
    80003138:	00004517          	auipc	a0,0x4
    8000313c:	2b050513          	addi	a0,a0,688 # 800073e8 <etext+0x3e8>
    80003140:	ef4fd0ef          	jal	80000834 <panic>

0000000080003144 <balloc>:
{
    80003144:	715d                	addi	sp,sp,-80
    80003146:	e486                	sd	ra,72(sp)
    80003148:	e0a2                	sd	s0,64(sp)
    8000314a:	fc26                	sd	s1,56(sp)
    8000314c:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    8000314e:	0001e797          	auipc	a5,0x1e
    80003152:	ac67a783          	lw	a5,-1338(a5) # 80020c14 <sb+0x4>
    80003156:	0e078263          	beqz	a5,8000323a <balloc+0xf6>
    8000315a:	f84a                	sd	s2,48(sp)
    8000315c:	f44e                	sd	s3,40(sp)
    8000315e:	f052                	sd	s4,32(sp)
    80003160:	ec56                	sd	s5,24(sp)
    80003162:	e85a                	sd	s6,16(sp)
    80003164:	e45e                	sd	s7,8(sp)
    80003166:	e062                	sd	s8,0(sp)
    80003168:	8baa                	mv	s7,a0
    8000316a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000316c:	0001eb17          	auipc	s6,0x1e
    80003170:	aa4b0b13          	addi	s6,s6,-1372 # 80020c10 <sb>
      m = 1 << (bi % 8);
    80003174:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003176:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80003178:	6c09                	lui	s8,0x2
    8000317a:	a09d                	j	800031e0 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    8000317c:	97ca                	add	a5,a5,s2
    8000317e:	8e55                	or	a2,a2,a3
    80003180:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003184:	854a                	mv	a0,s2
    80003186:	01c010ef          	jal	800041a2 <log_write>
        brelse(bp);
    8000318a:	854a                	mv	a0,s2
    8000318c:	e61ff0ef          	jal	80002fec <brelse>
  bp = bread(dev, bno);
    80003190:	85a6                	mv	a1,s1
    80003192:	855e                	mv	a0,s7
    80003194:	d51ff0ef          	jal	80002ee4 <bread>
    80003198:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000319a:	40000613          	li	a2,1024
    8000319e:	4581                	li	a1,0
    800031a0:	05850513          	addi	a0,a0,88
    800031a4:	b45fd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    800031a8:	854a                	mv	a0,s2
    800031aa:	7f9000ef          	jal	800041a2 <log_write>
  brelse(bp);
    800031ae:	854a                	mv	a0,s2
    800031b0:	e3dff0ef          	jal	80002fec <brelse>
}
    800031b4:	7942                	ld	s2,48(sp)
    800031b6:	79a2                	ld	s3,40(sp)
    800031b8:	7a02                	ld	s4,32(sp)
    800031ba:	6ae2                	ld	s5,24(sp)
    800031bc:	6b42                	ld	s6,16(sp)
    800031be:	6ba2                	ld	s7,8(sp)
    800031c0:	6c02                	ld	s8,0(sp)
}
    800031c2:	8526                	mv	a0,s1
    800031c4:	60a6                	ld	ra,72(sp)
    800031c6:	6406                	ld	s0,64(sp)
    800031c8:	74e2                	ld	s1,56(sp)
    800031ca:	6161                	addi	sp,sp,80
    800031cc:	8082                	ret
    brelse(bp);
    800031ce:	854a                	mv	a0,s2
    800031d0:	e1dff0ef          	jal	80002fec <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    800031d4:	015c0abb          	addw	s5,s8,s5
    800031d8:	004b2783          	lw	a5,4(s6)
    800031dc:	04faf863          	bgeu	s5,a5,8000322c <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    800031e0:	40dad59b          	sraiw	a1,s5,0xd
    800031e4:	01cb2783          	lw	a5,28(s6)
    800031e8:	9dbd                	addw	a1,a1,a5
    800031ea:	855e                	mv	a0,s7
    800031ec:	cf9ff0ef          	jal	80002ee4 <bread>
    800031f0:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    800031f2:	004b2503          	lw	a0,4(s6)
    800031f6:	84d6                	mv	s1,s5
    800031f8:	4701                	li	a4,0
    800031fa:	fca4fae3          	bgeu	s1,a0,800031ce <balloc+0x8a>
      m = 1 << (bi % 8);
    800031fe:	00777693          	andi	a3,a4,7
    80003202:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80003206:	41f7579b          	sraiw	a5,a4,0x1f
    8000320a:	01d7d79b          	srliw	a5,a5,0x1d
    8000320e:	9fb9                	addw	a5,a5,a4
    80003210:	4037d79b          	sraiw	a5,a5,0x3
    80003214:	00f90633          	add	a2,s2,a5
    80003218:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000321c:	00c6f5b3          	and	a1,a3,a2
    80003220:	ddb1                	beqz	a1,8000317c <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003222:	2705                	addiw	a4,a4,1
    80003224:	2485                	addiw	s1,s1,1
    80003226:	fd471ae3          	bne	a4,s4,800031fa <balloc+0xb6>
    8000322a:	b755                	j	800031ce <balloc+0x8a>
    8000322c:	7942                	ld	s2,48(sp)
    8000322e:	79a2                	ld	s3,40(sp)
    80003230:	7a02                	ld	s4,32(sp)
    80003232:	6ae2                	ld	s5,24(sp)
    80003234:	6b42                	ld	s6,16(sp)
    80003236:	6ba2                	ld	s7,8(sp)
    80003238:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    8000323a:	00004517          	auipc	a0,0x4
    8000323e:	1c650513          	addi	a0,a0,454 # 80007400 <etext+0x400>
    80003242:	ac8fd0ef          	jal	8000050a <printk>
  return 0;
    80003246:	4481                	li	s1,0
    80003248:	bfad                	j	800031c2 <balloc+0x7e>

000000008000324a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000324a:	7179                	addi	sp,sp,-48
    8000324c:	f406                	sd	ra,40(sp)
    8000324e:	f022                	sd	s0,32(sp)
    80003250:	ec26                	sd	s1,24(sp)
    80003252:	e84a                	sd	s2,16(sp)
    80003254:	e44e                	sd	s3,8(sp)
    80003256:	1800                	addi	s0,sp,48
    80003258:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    8000325a:	47ad                	li	a5,11
    8000325c:	02b7e363          	bltu	a5,a1,80003282 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80003260:	02059793          	slli	a5,a1,0x20
    80003264:	01e7d593          	srli	a1,a5,0x1e
    80003268:	00b509b3          	add	s3,a0,a1
    8000326c:	0509a483          	lw	s1,80(s3)
    80003270:	e0b5                	bnez	s1,800032d4 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003272:	4108                	lw	a0,0(a0)
    80003274:	ed1ff0ef          	jal	80003144 <balloc>
    80003278:	84aa                	mv	s1,a0
      if (addr == 0)
    8000327a:	cd29                	beqz	a0,800032d4 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    8000327c:	04a9a823          	sw	a0,80(s3)
    80003280:	a891                	j	800032d4 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003282:	ff45879b          	addiw	a5,a1,-12
    80003286:	873e                	mv	a4,a5
    80003288:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    8000328a:	0ff00793          	li	a5,255
    8000328e:	06e7e763          	bltu	a5,a4,800032fc <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80003292:	08052483          	lw	s1,128(a0)
    80003296:	e891                	bnez	s1,800032aa <bmap+0x60>
      addr = balloc(ip->dev);
    80003298:	4108                	lw	a0,0(a0)
    8000329a:	eabff0ef          	jal	80003144 <balloc>
    8000329e:	84aa                	mv	s1,a0
      if (addr == 0)
    800032a0:	c915                	beqz	a0,800032d4 <bmap+0x8a>
    800032a2:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800032a4:	08a92023          	sw	a0,128(s2)
    800032a8:	a011                	j	800032ac <bmap+0x62>
    800032aa:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800032ac:	85a6                	mv	a1,s1
    800032ae:	00092503          	lw	a0,0(s2)
    800032b2:	c33ff0ef          	jal	80002ee4 <bread>
    800032b6:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    800032b8:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    800032bc:	02099713          	slli	a4,s3,0x20
    800032c0:	01e75593          	srli	a1,a4,0x1e
    800032c4:	97ae                	add	a5,a5,a1
    800032c6:	89be                	mv	s3,a5
    800032c8:	4384                	lw	s1,0(a5)
    800032ca:	cc89                	beqz	s1,800032e4 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800032cc:	8552                	mv	a0,s4
    800032ce:	d1fff0ef          	jal	80002fec <brelse>
    return addr;
    800032d2:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800032d4:	8526                	mv	a0,s1
    800032d6:	70a2                	ld	ra,40(sp)
    800032d8:	7402                	ld	s0,32(sp)
    800032da:	64e2                	ld	s1,24(sp)
    800032dc:	6942                	ld	s2,16(sp)
    800032de:	69a2                	ld	s3,8(sp)
    800032e0:	6145                	addi	sp,sp,48
    800032e2:	8082                	ret
      addr = balloc(ip->dev);
    800032e4:	00092503          	lw	a0,0(s2)
    800032e8:	e5dff0ef          	jal	80003144 <balloc>
    800032ec:	84aa                	mv	s1,a0
      if (addr) {
    800032ee:	dd79                	beqz	a0,800032cc <bmap+0x82>
        a[bn] = addr;
    800032f0:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800032f4:	8552                	mv	a0,s4
    800032f6:	6ad000ef          	jal	800041a2 <log_write>
    800032fa:	bfc9                	j	800032cc <bmap+0x82>
    800032fc:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800032fe:	00004517          	auipc	a0,0x4
    80003302:	11a50513          	addi	a0,a0,282 # 80007418 <etext+0x418>
    80003306:	d2efd0ef          	jal	80000834 <panic>

000000008000330a <iget>:
{
    8000330a:	7179                	addi	sp,sp,-48
    8000330c:	f406                	sd	ra,40(sp)
    8000330e:	f022                	sd	s0,32(sp)
    80003310:	ec26                	sd	s1,24(sp)
    80003312:	e84a                	sd	s2,16(sp)
    80003314:	e44e                	sd	s3,8(sp)
    80003316:	e052                	sd	s4,0(sp)
    80003318:	1800                	addi	s0,sp,48
    8000331a:	892a                	mv	s2,a0
    8000331c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000331e:	0001e517          	auipc	a0,0x1e
    80003322:	91250513          	addi	a0,a0,-1774 # 80020c30 <itable>
    80003326:	903fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    8000332a:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000332c:	0001e497          	auipc	s1,0x1e
    80003330:	91c48493          	addi	s1,s1,-1764 # 80020c48 <itable+0x18>
    80003334:	0001f697          	auipc	a3,0x1f
    80003338:	3a468693          	addi	a3,a3,932 # 800226d8 <log>
    8000333c:	a809                	j	8000334e <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    8000333e:	e781                	bnez	a5,80003346 <iget+0x3c>
    80003340:	00099363          	bnez	s3,80003346 <iget+0x3c>
      empty = ip;
    80003344:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003346:	08848493          	addi	s1,s1,136
    8000334a:	02d48563          	beq	s1,a3,80003374 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    8000334e:	449c                	lw	a5,8(s1)
    80003350:	fef057e3          	blez	a5,8000333e <iget+0x34>
    80003354:	4098                	lw	a4,0(s1)
    80003356:	ff2718e3          	bne	a4,s2,80003346 <iget+0x3c>
    8000335a:	40d8                	lw	a4,4(s1)
    8000335c:	ff4715e3          	bne	a4,s4,80003346 <iget+0x3c>
      ip->ref++;
    80003360:	2785                	addiw	a5,a5,1
    80003362:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003364:	0001e517          	auipc	a0,0x1e
    80003368:	8cc50513          	addi	a0,a0,-1844 # 80020c30 <itable>
    8000336c:	945fd0ef          	jal	80000cb0 <release>
      return ip;
    80003370:	89a6                	mv	s3,s1
    80003372:	a015                	j	80003396 <iget+0x8c>
  if (empty == 0)
    80003374:	02098a63          	beqz	s3,800033a8 <iget+0x9e>
  ip->dev = dev;
    80003378:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000337c:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003380:	4785                	li	a5,1
    80003382:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003386:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000338a:	0001e517          	auipc	a0,0x1e
    8000338e:	8a650513          	addi	a0,a0,-1882 # 80020c30 <itable>
    80003392:	91ffd0ef          	jal	80000cb0 <release>
}
    80003396:	854e                	mv	a0,s3
    80003398:	70a2                	ld	ra,40(sp)
    8000339a:	7402                	ld	s0,32(sp)
    8000339c:	64e2                	ld	s1,24(sp)
    8000339e:	6942                	ld	s2,16(sp)
    800033a0:	69a2                	ld	s3,8(sp)
    800033a2:	6a02                	ld	s4,0(sp)
    800033a4:	6145                	addi	sp,sp,48
    800033a6:	8082                	ret
    panic("iget: no inodes");
    800033a8:	00004517          	auipc	a0,0x4
    800033ac:	08850513          	addi	a0,a0,136 # 80007430 <etext+0x430>
    800033b0:	c84fd0ef          	jal	80000834 <panic>

00000000800033b4 <iinit>:
{
    800033b4:	7179                	addi	sp,sp,-48
    800033b6:	f406                	sd	ra,40(sp)
    800033b8:	f022                	sd	s0,32(sp)
    800033ba:	ec26                	sd	s1,24(sp)
    800033bc:	e84a                	sd	s2,16(sp)
    800033be:	e44e                	sd	s3,8(sp)
    800033c0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800033c2:	00004597          	auipc	a1,0x4
    800033c6:	07e58593          	addi	a1,a1,126 # 80007440 <etext+0x440>
    800033ca:	0001e517          	auipc	a0,0x1e
    800033ce:	86650513          	addi	a0,a0,-1946 # 80020c30 <itable>
    800033d2:	fd6fd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    800033d6:	0001e497          	auipc	s1,0x1e
    800033da:	88248493          	addi	s1,s1,-1918 # 80020c58 <itable+0x28>
    800033de:	0001f997          	auipc	s3,0x1f
    800033e2:	30a98993          	addi	s3,s3,778 # 800226e8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800033e6:	00004917          	auipc	s2,0x4
    800033ea:	06290913          	addi	s2,s2,98 # 80007448 <etext+0x448>
    800033ee:	85ca                	mv	a1,s2
    800033f0:	8526                	mv	a0,s1
    800033f2:	6e9000ef          	jal	800042da <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    800033f6:	08848493          	addi	s1,s1,136
    800033fa:	ff349ae3          	bne	s1,s3,800033ee <iinit+0x3a>
}
    800033fe:	70a2                	ld	ra,40(sp)
    80003400:	7402                	ld	s0,32(sp)
    80003402:	64e2                	ld	s1,24(sp)
    80003404:	6942                	ld	s2,16(sp)
    80003406:	69a2                	ld	s3,8(sp)
    80003408:	6145                	addi	sp,sp,48
    8000340a:	8082                	ret

000000008000340c <ialloc>:
{
    8000340c:	7139                	addi	sp,sp,-64
    8000340e:	fc06                	sd	ra,56(sp)
    80003410:	f822                	sd	s0,48(sp)
    80003412:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003414:	0001e717          	auipc	a4,0x1e
    80003418:	80872703          	lw	a4,-2040(a4) # 80020c1c <sb+0xc>
    8000341c:	4785                	li	a5,1
    8000341e:	06e7f063          	bgeu	a5,a4,8000347e <ialloc+0x72>
    80003422:	f426                	sd	s1,40(sp)
    80003424:	f04a                	sd	s2,32(sp)
    80003426:	ec4e                	sd	s3,24(sp)
    80003428:	e852                	sd	s4,16(sp)
    8000342a:	e456                	sd	s5,8(sp)
    8000342c:	e05a                	sd	s6,0(sp)
    8000342e:	8aaa                	mv	s5,a0
    80003430:	8b2e                	mv	s6,a1
    80003432:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003434:	0001da17          	auipc	s4,0x1d
    80003438:	7dca0a13          	addi	s4,s4,2012 # 80020c10 <sb>
    8000343c:	00495593          	srli	a1,s2,0x4
    80003440:	018a2783          	lw	a5,24(s4)
    80003444:	9dbd                	addw	a1,a1,a5
    80003446:	8556                	mv	a0,s5
    80003448:	a9dff0ef          	jal	80002ee4 <bread>
    8000344c:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    8000344e:	05850993          	addi	s3,a0,88
    80003452:	00f97793          	andi	a5,s2,15
    80003456:	079a                	slli	a5,a5,0x6
    80003458:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    8000345a:	00099783          	lh	a5,0(s3)
    8000345e:	cb9d                	beqz	a5,80003494 <ialloc+0x88>
    brelse(bp);
    80003460:	b8dff0ef          	jal	80002fec <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003464:	0905                	addi	s2,s2,1
    80003466:	00ca2703          	lw	a4,12(s4)
    8000346a:	0009079b          	sext.w	a5,s2
    8000346e:	fce7e7e3          	bltu	a5,a4,8000343c <ialloc+0x30>
    80003472:	74a2                	ld	s1,40(sp)
    80003474:	7902                	ld	s2,32(sp)
    80003476:	69e2                	ld	s3,24(sp)
    80003478:	6a42                	ld	s4,16(sp)
    8000347a:	6aa2                	ld	s5,8(sp)
    8000347c:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    8000347e:	00004517          	auipc	a0,0x4
    80003482:	fd250513          	addi	a0,a0,-46 # 80007450 <etext+0x450>
    80003486:	884fd0ef          	jal	8000050a <printk>
  return 0;
    8000348a:	4501                	li	a0,0
}
    8000348c:	70e2                	ld	ra,56(sp)
    8000348e:	7442                	ld	s0,48(sp)
    80003490:	6121                	addi	sp,sp,64
    80003492:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003494:	04000613          	li	a2,64
    80003498:	4581                	li	a1,0
    8000349a:	854e                	mv	a0,s3
    8000349c:	84dfd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    800034a0:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800034a4:	8526                	mv	a0,s1
    800034a6:	4fd000ef          	jal	800041a2 <log_write>
      brelse(bp);
    800034aa:	8526                	mv	a0,s1
    800034ac:	b41ff0ef          	jal	80002fec <brelse>
      return iget(dev, inum);
    800034b0:	0009059b          	sext.w	a1,s2
    800034b4:	8556                	mv	a0,s5
    800034b6:	e55ff0ef          	jal	8000330a <iget>
    800034ba:	74a2                	ld	s1,40(sp)
    800034bc:	7902                	ld	s2,32(sp)
    800034be:	69e2                	ld	s3,24(sp)
    800034c0:	6a42                	ld	s4,16(sp)
    800034c2:	6aa2                	ld	s5,8(sp)
    800034c4:	6b02                	ld	s6,0(sp)
    800034c6:	b7d9                	j	8000348c <ialloc+0x80>

00000000800034c8 <iupdate>:
{
    800034c8:	1101                	addi	sp,sp,-32
    800034ca:	ec06                	sd	ra,24(sp)
    800034cc:	e822                	sd	s0,16(sp)
    800034ce:	e426                	sd	s1,8(sp)
    800034d0:	e04a                	sd	s2,0(sp)
    800034d2:	1000                	addi	s0,sp,32
    800034d4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800034d6:	415c                	lw	a5,4(a0)
    800034d8:	0047d79b          	srliw	a5,a5,0x4
    800034dc:	0001d597          	auipc	a1,0x1d
    800034e0:	74c5a583          	lw	a1,1868(a1) # 80020c28 <sb+0x18>
    800034e4:	9dbd                	addw	a1,a1,a5
    800034e6:	4108                	lw	a0,0(a0)
    800034e8:	9fdff0ef          	jal	80002ee4 <bread>
    800034ec:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    800034ee:	05850793          	addi	a5,a0,88
    800034f2:	40d8                	lw	a4,4(s1)
    800034f4:	8b3d                	andi	a4,a4,15
    800034f6:	071a                	slli	a4,a4,0x6
    800034f8:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800034fa:	04449703          	lh	a4,68(s1)
    800034fe:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003502:	04649703          	lh	a4,70(s1)
    80003506:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000350a:	04849703          	lh	a4,72(s1)
    8000350e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003512:	04a49703          	lh	a4,74(s1)
    80003516:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000351a:	44f8                	lw	a4,76(s1)
    8000351c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000351e:	03400613          	li	a2,52
    80003522:	05048593          	addi	a1,s1,80
    80003526:	00c78513          	addi	a0,a5,12
    8000352a:	81ffd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    8000352e:	854a                	mv	a0,s2
    80003530:	473000ef          	jal	800041a2 <log_write>
  brelse(bp);
    80003534:	854a                	mv	a0,s2
    80003536:	ab7ff0ef          	jal	80002fec <brelse>
}
    8000353a:	60e2                	ld	ra,24(sp)
    8000353c:	6442                	ld	s0,16(sp)
    8000353e:	64a2                	ld	s1,8(sp)
    80003540:	6902                	ld	s2,0(sp)
    80003542:	6105                	addi	sp,sp,32
    80003544:	8082                	ret

0000000080003546 <idup>:
{
    80003546:	1101                	addi	sp,sp,-32
    80003548:	ec06                	sd	ra,24(sp)
    8000354a:	e822                	sd	s0,16(sp)
    8000354c:	e426                	sd	s1,8(sp)
    8000354e:	1000                	addi	s0,sp,32
    80003550:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003552:	0001d517          	auipc	a0,0x1d
    80003556:	6de50513          	addi	a0,a0,1758 # 80020c30 <itable>
    8000355a:	ecefd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    8000355e:	449c                	lw	a5,8(s1)
    80003560:	2785                	addiw	a5,a5,1
    80003562:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003564:	0001d517          	auipc	a0,0x1d
    80003568:	6cc50513          	addi	a0,a0,1740 # 80020c30 <itable>
    8000356c:	f44fd0ef          	jal	80000cb0 <release>
}
    80003570:	8526                	mv	a0,s1
    80003572:	60e2                	ld	ra,24(sp)
    80003574:	6442                	ld	s0,16(sp)
    80003576:	64a2                	ld	s1,8(sp)
    80003578:	6105                	addi	sp,sp,32
    8000357a:	8082                	ret

000000008000357c <ilock>:
{
    8000357c:	1101                	addi	sp,sp,-32
    8000357e:	ec06                	sd	ra,24(sp)
    80003580:	e822                	sd	s0,16(sp)
    80003582:	e426                	sd	s1,8(sp)
    80003584:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003586:	cd19                	beqz	a0,800035a4 <ilock+0x28>
    80003588:	84aa                	mv	s1,a0
    8000358a:	451c                	lw	a5,8(a0)
    8000358c:	00f05c63          	blez	a5,800035a4 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003590:	0541                	addi	a0,a0,16
    80003592:	57f000ef          	jal	80004310 <acquiresleep>
  if (ip->valid == 0) {
    80003596:	40bc                	lw	a5,64(s1)
    80003598:	cf89                	beqz	a5,800035b2 <ilock+0x36>
}
    8000359a:	60e2                	ld	ra,24(sp)
    8000359c:	6442                	ld	s0,16(sp)
    8000359e:	64a2                	ld	s1,8(sp)
    800035a0:	6105                	addi	sp,sp,32
    800035a2:	8082                	ret
    800035a4:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800035a6:	00004517          	auipc	a0,0x4
    800035aa:	ec250513          	addi	a0,a0,-318 # 80007468 <etext+0x468>
    800035ae:	a86fd0ef          	jal	80000834 <panic>
    800035b2:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035b4:	40dc                	lw	a5,4(s1)
    800035b6:	0047d79b          	srliw	a5,a5,0x4
    800035ba:	0001d597          	auipc	a1,0x1d
    800035be:	66e5a583          	lw	a1,1646(a1) # 80020c28 <sb+0x18>
    800035c2:	9dbd                	addw	a1,a1,a5
    800035c4:	4088                	lw	a0,0(s1)
    800035c6:	91fff0ef          	jal	80002ee4 <bread>
    800035ca:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    800035cc:	05850593          	addi	a1,a0,88
    800035d0:	40dc                	lw	a5,4(s1)
    800035d2:	8bbd                	andi	a5,a5,15
    800035d4:	079a                	slli	a5,a5,0x6
    800035d6:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800035d8:	00059783          	lh	a5,0(a1)
    800035dc:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800035e0:	00259783          	lh	a5,2(a1)
    800035e4:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800035e8:	00459783          	lh	a5,4(a1)
    800035ec:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800035f0:	00659783          	lh	a5,6(a1)
    800035f4:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800035f8:	459c                	lw	a5,8(a1)
    800035fa:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800035fc:	03400613          	li	a2,52
    80003600:	05b1                	addi	a1,a1,12
    80003602:	05048513          	addi	a0,s1,80
    80003606:	f42fd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    8000360a:	854a                	mv	a0,s2
    8000360c:	9e1ff0ef          	jal	80002fec <brelse>
    ip->valid = 1;
    80003610:	4785                	li	a5,1
    80003612:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003614:	04449783          	lh	a5,68(s1)
    80003618:	c399                	beqz	a5,8000361e <ilock+0xa2>
    8000361a:	6902                	ld	s2,0(sp)
    8000361c:	bfbd                	j	8000359a <ilock+0x1e>
      panic("ilock: no type");
    8000361e:	00004517          	auipc	a0,0x4
    80003622:	e5250513          	addi	a0,a0,-430 # 80007470 <etext+0x470>
    80003626:	a0efd0ef          	jal	80000834 <panic>

000000008000362a <iunlock>:
{
    8000362a:	1101                	addi	sp,sp,-32
    8000362c:	ec06                	sd	ra,24(sp)
    8000362e:	e822                	sd	s0,16(sp)
    80003630:	e426                	sd	s1,8(sp)
    80003632:	e04a                	sd	s2,0(sp)
    80003634:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003636:	c505                	beqz	a0,8000365e <iunlock+0x34>
    80003638:	84aa                	mv	s1,a0
    8000363a:	01050913          	addi	s2,a0,16
    8000363e:	854a                	mv	a0,s2
    80003640:	55d000ef          	jal	8000439c <holdingsleep>
    80003644:	cd09                	beqz	a0,8000365e <iunlock+0x34>
    80003646:	449c                	lw	a5,8(s1)
    80003648:	00f05b63          	blez	a5,8000365e <iunlock+0x34>
  releasesleep(&ip->lock);
    8000364c:	854a                	mv	a0,s2
    8000364e:	517000ef          	jal	80004364 <releasesleep>
}
    80003652:	60e2                	ld	ra,24(sp)
    80003654:	6442                	ld	s0,16(sp)
    80003656:	64a2                	ld	s1,8(sp)
    80003658:	6902                	ld	s2,0(sp)
    8000365a:	6105                	addi	sp,sp,32
    8000365c:	8082                	ret
    panic("iunlock");
    8000365e:	00004517          	auipc	a0,0x4
    80003662:	e2250513          	addi	a0,a0,-478 # 80007480 <etext+0x480>
    80003666:	9cefd0ef          	jal	80000834 <panic>

000000008000366a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000366a:	7179                	addi	sp,sp,-48
    8000366c:	f406                	sd	ra,40(sp)
    8000366e:	f022                	sd	s0,32(sp)
    80003670:	ec26                	sd	s1,24(sp)
    80003672:	e84a                	sd	s2,16(sp)
    80003674:	e44e                	sd	s3,8(sp)
    80003676:	1800                	addi	s0,sp,48
    80003678:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    8000367a:	05050493          	addi	s1,a0,80
    8000367e:	08050913          	addi	s2,a0,128
    80003682:	a021                	j	8000368a <itrunc+0x20>
    80003684:	0491                	addi	s1,s1,4
    80003686:	01248b63          	beq	s1,s2,8000369c <itrunc+0x32>
    if (ip->addrs[i]) {
    8000368a:	408c                	lw	a1,0(s1)
    8000368c:	dde5                	beqz	a1,80003684 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000368e:	0009a503          	lw	a0,0(s3)
    80003692:	a47ff0ef          	jal	800030d8 <bfree>
      ip->addrs[i] = 0;
    80003696:	0004a023          	sw	zero,0(s1)
    8000369a:	b7ed                	j	80003684 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    8000369c:	0809a583          	lw	a1,128(s3)
    800036a0:	ed89                	bnez	a1,800036ba <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800036a2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800036a6:	854e                	mv	a0,s3
    800036a8:	e21ff0ef          	jal	800034c8 <iupdate>
}
    800036ac:	70a2                	ld	ra,40(sp)
    800036ae:	7402                	ld	s0,32(sp)
    800036b0:	64e2                	ld	s1,24(sp)
    800036b2:	6942                	ld	s2,16(sp)
    800036b4:	69a2                	ld	s3,8(sp)
    800036b6:	6145                	addi	sp,sp,48
    800036b8:	8082                	ret
    800036ba:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800036bc:	0009a503          	lw	a0,0(s3)
    800036c0:	825ff0ef          	jal	80002ee4 <bread>
    800036c4:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    800036c6:	05850493          	addi	s1,a0,88
    800036ca:	45850913          	addi	s2,a0,1112
    800036ce:	a021                	j	800036d6 <itrunc+0x6c>
    800036d0:	0491                	addi	s1,s1,4
    800036d2:	01248963          	beq	s1,s2,800036e4 <itrunc+0x7a>
      if (a[j])
    800036d6:	408c                	lw	a1,0(s1)
    800036d8:	dde5                	beqz	a1,800036d0 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800036da:	0009a503          	lw	a0,0(s3)
    800036de:	9fbff0ef          	jal	800030d8 <bfree>
    800036e2:	b7fd                	j	800036d0 <itrunc+0x66>
    brelse(bp);
    800036e4:	8552                	mv	a0,s4
    800036e6:	907ff0ef          	jal	80002fec <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800036ea:	0809a583          	lw	a1,128(s3)
    800036ee:	0009a503          	lw	a0,0(s3)
    800036f2:	9e7ff0ef          	jal	800030d8 <bfree>
    ip->addrs[NDIRECT] = 0;
    800036f6:	0809a023          	sw	zero,128(s3)
    800036fa:	6a02                	ld	s4,0(sp)
    800036fc:	b75d                	j	800036a2 <itrunc+0x38>

00000000800036fe <iput>:
{
    800036fe:	7179                	addi	sp,sp,-48
    80003700:	f406                	sd	ra,40(sp)
    80003702:	f022                	sd	s0,32(sp)
    80003704:	ec26                	sd	s1,24(sp)
    80003706:	1800                	addi	s0,sp,48
    80003708:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000370a:	0001d517          	auipc	a0,0x1d
    8000370e:	52650513          	addi	a0,a0,1318 # 80020c30 <itable>
    80003712:	d16fd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003716:	449c                	lw	a5,8(s1)
    80003718:	4705                	li	a4,1
    8000371a:	00e78f63          	beq	a5,a4,80003738 <iput+0x3a>
  ip->ref--;
    8000371e:	37fd                	addiw	a5,a5,-1
    80003720:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003722:	0001d517          	auipc	a0,0x1d
    80003726:	50e50513          	addi	a0,a0,1294 # 80020c30 <itable>
    8000372a:	d86fd0ef          	jal	80000cb0 <release>
}
    8000372e:	70a2                	ld	ra,40(sp)
    80003730:	7402                	ld	s0,32(sp)
    80003732:	64e2                	ld	s1,24(sp)
    80003734:	6145                	addi	sp,sp,48
    80003736:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003738:	40b8                	lw	a4,64(s1)
    8000373a:	d375                	beqz	a4,8000371e <iput+0x20>
    8000373c:	e84a                	sd	s2,16(sp)
    8000373e:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    80003740:	0004aa03          	lw	s4,0(s1)
    80003744:	0044a903          	lw	s2,4(s1)
  if (last) {
    80003748:	04a49703          	lh	a4,74(s1)
    8000374c:	ef3d                	bnez	a4,800037ca <iput+0xcc>
    8000374e:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    80003750:	01048793          	addi	a5,s1,16
    80003754:	89be                	mv	s3,a5
    80003756:	853e                	mv	a0,a5
    80003758:	3b9000ef          	jal	80004310 <acquiresleep>
    release(&itable.lock);
    8000375c:	0001d517          	auipc	a0,0x1d
    80003760:	4d450513          	addi	a0,a0,1236 # 80020c30 <itable>
    80003764:	d4cfd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    80003768:	8526                	mv	a0,s1
    8000376a:	f01ff0ef          	jal	8000366a <itrunc>
    ip->valid = 0;
    8000376e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003772:	854e                	mv	a0,s3
    80003774:	3f1000ef          	jal	80004364 <releasesleep>
    acquire(&itable.lock);
    80003778:	0001d517          	auipc	a0,0x1d
    8000377c:	4b850513          	addi	a0,a0,1208 # 80020c30 <itable>
    80003780:	ca8fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    80003784:	449c                	lw	a5,8(s1)
    80003786:	37fd                	addiw	a5,a5,-1
    80003788:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000378a:	0001d517          	auipc	a0,0x1d
    8000378e:	4a650513          	addi	a0,a0,1190 # 80020c30 <itable>
    80003792:	d1efd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003796:	0049579b          	srliw	a5,s2,0x4
    8000379a:	0001d597          	auipc	a1,0x1d
    8000379e:	48e5a583          	lw	a1,1166(a1) # 80020c28 <sb+0x18>
    800037a2:	9dbd                	addw	a1,a1,a5
    800037a4:	8552                	mv	a0,s4
    800037a6:	f3eff0ef          	jal	80002ee4 <bread>
    800037aa:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800037ac:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    800037b0:	079a                	slli	a5,a5,0x6
    800037b2:	97aa                	add	a5,a5,a0
    800037b4:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    800037b8:	1eb000ef          	jal	800041a2 <log_write>
  brelse(bp);
    800037bc:	8526                	mv	a0,s1
    800037be:	82fff0ef          	jal	80002fec <brelse>
}
    800037c2:	6942                	ld	s2,16(sp)
    800037c4:	69a2                	ld	s3,8(sp)
    800037c6:	6a02                	ld	s4,0(sp)
    800037c8:	b79d                	j	8000372e <iput+0x30>
    800037ca:	6942                	ld	s2,16(sp)
    800037cc:	6a02                	ld	s4,0(sp)
    800037ce:	bf81                	j	8000371e <iput+0x20>

00000000800037d0 <iunlockput>:
{
    800037d0:	1101                	addi	sp,sp,-32
    800037d2:	ec06                	sd	ra,24(sp)
    800037d4:	e822                	sd	s0,16(sp)
    800037d6:	e426                	sd	s1,8(sp)
    800037d8:	1000                	addi	s0,sp,32
    800037da:	84aa                	mv	s1,a0
  iunlock(ip);
    800037dc:	e4fff0ef          	jal	8000362a <iunlock>
  iput(ip);
    800037e0:	8526                	mv	a0,s1
    800037e2:	f1dff0ef          	jal	800036fe <iput>
}
    800037e6:	60e2                	ld	ra,24(sp)
    800037e8:	6442                	ld	s0,16(sp)
    800037ea:	64a2                	ld	s1,8(sp)
    800037ec:	6105                	addi	sp,sp,32
    800037ee:	8082                	ret

00000000800037f0 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800037f0:	0001d717          	auipc	a4,0x1d
    800037f4:	42c72703          	lw	a4,1068(a4) # 80020c1c <sb+0xc>
    800037f8:	4785                	li	a5,1
    800037fa:	0ae7fe63          	bgeu	a5,a4,800038b6 <ireclaim+0xc6>
{
    800037fe:	7139                	addi	sp,sp,-64
    80003800:	fc06                	sd	ra,56(sp)
    80003802:	f822                	sd	s0,48(sp)
    80003804:	f426                	sd	s1,40(sp)
    80003806:	f04a                	sd	s2,32(sp)
    80003808:	ec4e                	sd	s3,24(sp)
    8000380a:	e852                	sd	s4,16(sp)
    8000380c:	e456                	sd	s5,8(sp)
    8000380e:	e05a                	sd	s6,0(sp)
    80003810:	0080                	addi	s0,sp,64
    80003812:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003814:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003816:	0001da17          	auipc	s4,0x1d
    8000381a:	3faa0a13          	addi	s4,s4,1018 # 80020c10 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    8000381e:	00004b17          	auipc	s6,0x4
    80003822:	c6ab0b13          	addi	s6,s6,-918 # 80007488 <etext+0x488>
    80003826:	a099                	j	8000386c <ireclaim+0x7c>
    80003828:	85ce                	mv	a1,s3
    8000382a:	855a                	mv	a0,s6
    8000382c:	cdffc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    80003830:	85ce                	mv	a1,s3
    80003832:	8556                	mv	a0,s5
    80003834:	ad7ff0ef          	jal	8000330a <iget>
    80003838:	89aa                	mv	s3,a0
    brelse(bp);
    8000383a:	854a                	mv	a0,s2
    8000383c:	fb0ff0ef          	jal	80002fec <brelse>
    if (ip) {
    80003840:	00098f63          	beqz	s3,8000385e <ireclaim+0x6e>
      begin_op();
    80003844:	7b0000ef          	jal	80003ff4 <begin_op>
      ilock(ip);
    80003848:	854e                	mv	a0,s3
    8000384a:	d33ff0ef          	jal	8000357c <ilock>
      iunlock(ip);
    8000384e:	854e                	mv	a0,s3
    80003850:	ddbff0ef          	jal	8000362a <iunlock>
      iput(ip);
    80003854:	854e                	mv	a0,s3
    80003856:	ea9ff0ef          	jal	800036fe <iput>
      end_op();
    8000385a:	027000ef          	jal	80004080 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000385e:	0485                	addi	s1,s1,1
    80003860:	00ca2703          	lw	a4,12(s4)
    80003864:	0004879b          	sext.w	a5,s1
    80003868:	02e7fd63          	bgeu	a5,a4,800038a2 <ireclaim+0xb2>
    8000386c:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003870:	0044d593          	srli	a1,s1,0x4
    80003874:	018a2783          	lw	a5,24(s4)
    80003878:	9dbd                	addw	a1,a1,a5
    8000387a:	8556                	mv	a0,s5
    8000387c:	e68ff0ef          	jal	80002ee4 <bread>
    80003880:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003882:	05850793          	addi	a5,a0,88
    80003886:	00f9f713          	andi	a4,s3,15
    8000388a:	071a                	slli	a4,a4,0x6
    8000388c:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    8000388e:	00079703          	lh	a4,0(a5)
    80003892:	c701                	beqz	a4,8000389a <ireclaim+0xaa>
    80003894:	00679783          	lh	a5,6(a5)
    80003898:	dbc1                	beqz	a5,80003828 <ireclaim+0x38>
    brelse(bp);
    8000389a:	854a                	mv	a0,s2
    8000389c:	f50ff0ef          	jal	80002fec <brelse>
    if (ip) {
    800038a0:	bf7d                	j	8000385e <ireclaim+0x6e>
}
    800038a2:	70e2                	ld	ra,56(sp)
    800038a4:	7442                	ld	s0,48(sp)
    800038a6:	74a2                	ld	s1,40(sp)
    800038a8:	7902                	ld	s2,32(sp)
    800038aa:	69e2                	ld	s3,24(sp)
    800038ac:	6a42                	ld	s4,16(sp)
    800038ae:	6aa2                	ld	s5,8(sp)
    800038b0:	6b02                	ld	s6,0(sp)
    800038b2:	6121                	addi	sp,sp,64
    800038b4:	8082                	ret
    800038b6:	8082                	ret

00000000800038b8 <fsinit>:
{
    800038b8:	1101                	addi	sp,sp,-32
    800038ba:	ec06                	sd	ra,24(sp)
    800038bc:	e822                	sd	s0,16(sp)
    800038be:	e426                	sd	s1,8(sp)
    800038c0:	e04a                	sd	s2,0(sp)
    800038c2:	1000                	addi	s0,sp,32
    800038c4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800038c6:	4585                	li	a1,1
    800038c8:	e1cff0ef          	jal	80002ee4 <bread>
    800038cc:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800038ce:	02000613          	li	a2,32
    800038d2:	05850593          	addi	a1,a0,88
    800038d6:	0001d517          	auipc	a0,0x1d
    800038da:	33a50513          	addi	a0,a0,826 # 80020c10 <sb>
    800038de:	c6afd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    800038e2:	8526                	mv	a0,s1
    800038e4:	f08ff0ef          	jal	80002fec <brelse>
  if (sb.magic != FSMAGIC)
    800038e8:	0001d717          	auipc	a4,0x1d
    800038ec:	32872703          	lw	a4,808(a4) # 80020c10 <sb>
    800038f0:	102037b7          	lui	a5,0x10203
    800038f4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800038f8:	02f71263          	bne	a4,a5,8000391c <fsinit+0x64>
  initlog(dev, &sb);
    800038fc:	0001d597          	auipc	a1,0x1d
    80003900:	31458593          	addi	a1,a1,788 # 80020c10 <sb>
    80003904:	854a                	mv	a0,s2
    80003906:	66c000ef          	jal	80003f72 <initlog>
  ireclaim(dev);
    8000390a:	854a                	mv	a0,s2
    8000390c:	ee5ff0ef          	jal	800037f0 <ireclaim>
}
    80003910:	60e2                	ld	ra,24(sp)
    80003912:	6442                	ld	s0,16(sp)
    80003914:	64a2                	ld	s1,8(sp)
    80003916:	6902                	ld	s2,0(sp)
    80003918:	6105                	addi	sp,sp,32
    8000391a:	8082                	ret
    panic("invalid file system");
    8000391c:	00004517          	auipc	a0,0x4
    80003920:	b8c50513          	addi	a0,a0,-1140 # 800074a8 <etext+0x4a8>
    80003924:	f11fc0ef          	jal	80000834 <panic>

0000000080003928 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003928:	1141                	addi	sp,sp,-16
    8000392a:	e406                	sd	ra,8(sp)
    8000392c:	e022                	sd	s0,0(sp)
    8000392e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003930:	411c                	lw	a5,0(a0)
    80003932:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003934:	415c                	lw	a5,4(a0)
    80003936:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003938:	04451783          	lh	a5,68(a0)
    8000393c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003940:	04a51783          	lh	a5,74(a0)
    80003944:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003948:	04c56783          	lwu	a5,76(a0)
    8000394c:	e99c                	sd	a5,16(a1)
}
    8000394e:	60a2                	ld	ra,8(sp)
    80003950:	6402                	ld	s0,0(sp)
    80003952:	0141                	addi	sp,sp,16
    80003954:	8082                	ret

0000000080003956 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003956:	457c                	lw	a5,76(a0)
    80003958:	0ed7e663          	bltu	a5,a3,80003a44 <readi+0xee>
{
    8000395c:	7159                	addi	sp,sp,-112
    8000395e:	f486                	sd	ra,104(sp)
    80003960:	f0a2                	sd	s0,96(sp)
    80003962:	eca6                	sd	s1,88(sp)
    80003964:	e0d2                	sd	s4,64(sp)
    80003966:	fc56                	sd	s5,56(sp)
    80003968:	f85a                	sd	s6,48(sp)
    8000396a:	f45e                	sd	s7,40(sp)
    8000396c:	1880                	addi	s0,sp,112
    8000396e:	8b2a                	mv	s6,a0
    80003970:	8bae                	mv	s7,a1
    80003972:	8a32                	mv	s4,a2
    80003974:	84b6                	mv	s1,a3
    80003976:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003978:	9f35                	addw	a4,a4,a3
    return 0;
    8000397a:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    8000397c:	0ad76b63          	bltu	a4,a3,80003a32 <readi+0xdc>
    80003980:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003982:	00e7f463          	bgeu	a5,a4,8000398a <readi+0x34>
    n = ip->size - off;
    80003986:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000398a:	080a8b63          	beqz	s5,80003a20 <readi+0xca>
    8000398e:	e8ca                	sd	s2,80(sp)
    80003990:	f062                	sd	s8,32(sp)
    80003992:	ec66                	sd	s9,24(sp)
    80003994:	e86a                	sd	s10,16(sp)
    80003996:	e46e                	sd	s11,8(sp)
    80003998:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000399a:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000399e:	5c7d                	li	s8,-1
    800039a0:	a80d                	j	800039d2 <readi+0x7c>
    800039a2:	020d1d93          	slli	s11,s10,0x20
    800039a6:	020ddd93          	srli	s11,s11,0x20
    800039aa:	05890613          	addi	a2,s2,88
    800039ae:	86ee                	mv	a3,s11
    800039b0:	963e                	add	a2,a2,a5
    800039b2:	85d2                	mv	a1,s4
    800039b4:	855e                	mv	a0,s7
    800039b6:	beffe0ef          	jal	800025a4 <either_copyout>
    800039ba:	05850363          	beq	a0,s8,80003a00 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039be:	854a                	mv	a0,s2
    800039c0:	e2cff0ef          	jal	80002fec <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800039c4:	013d09bb          	addw	s3,s10,s3
    800039c8:	009d04bb          	addw	s1,s10,s1
    800039cc:	9a6e                	add	s4,s4,s11
    800039ce:	0559f363          	bgeu	s3,s5,80003a14 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    800039d2:	00a4d59b          	srliw	a1,s1,0xa
    800039d6:	855a                	mv	a0,s6
    800039d8:	873ff0ef          	jal	8000324a <bmap>
    800039dc:	85aa                	mv	a1,a0
    if (addr == 0)
    800039de:	c139                	beqz	a0,80003a24 <readi+0xce>
    bp = bread(ip->dev, addr);
    800039e0:	000b2503          	lw	a0,0(s6)
    800039e4:	d00ff0ef          	jal	80002ee4 <bread>
    800039e8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800039ea:	3ff4f793          	andi	a5,s1,1023
    800039ee:	40fc873b          	subw	a4,s9,a5
    800039f2:	413a86bb          	subw	a3,s5,s3
    800039f6:	8d3a                	mv	s10,a4
    800039f8:	fae6f5e3          	bgeu	a3,a4,800039a2 <readi+0x4c>
    800039fc:	8d36                	mv	s10,a3
    800039fe:	b755                	j	800039a2 <readi+0x4c>
      brelse(bp);
    80003a00:	854a                	mv	a0,s2
    80003a02:	deaff0ef          	jal	80002fec <brelse>
      tot = -1;
    80003a06:	59fd                	li	s3,-1
      break;
    80003a08:	6946                	ld	s2,80(sp)
    80003a0a:	7c02                	ld	s8,32(sp)
    80003a0c:	6ce2                	ld	s9,24(sp)
    80003a0e:	6d42                	ld	s10,16(sp)
    80003a10:	6da2                	ld	s11,8(sp)
    80003a12:	a831                	j	80003a2e <readi+0xd8>
    80003a14:	6946                	ld	s2,80(sp)
    80003a16:	7c02                	ld	s8,32(sp)
    80003a18:	6ce2                	ld	s9,24(sp)
    80003a1a:	6d42                	ld	s10,16(sp)
    80003a1c:	6da2                	ld	s11,8(sp)
    80003a1e:	a801                	j	80003a2e <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003a20:	89d6                	mv	s3,s5
    80003a22:	a031                	j	80003a2e <readi+0xd8>
    80003a24:	6946                	ld	s2,80(sp)
    80003a26:	7c02                	ld	s8,32(sp)
    80003a28:	6ce2                	ld	s9,24(sp)
    80003a2a:	6d42                	ld	s10,16(sp)
    80003a2c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003a2e:	854e                	mv	a0,s3
    80003a30:	69a6                	ld	s3,72(sp)
}
    80003a32:	70a6                	ld	ra,104(sp)
    80003a34:	7406                	ld	s0,96(sp)
    80003a36:	64e6                	ld	s1,88(sp)
    80003a38:	6a06                	ld	s4,64(sp)
    80003a3a:	7ae2                	ld	s5,56(sp)
    80003a3c:	7b42                	ld	s6,48(sp)
    80003a3e:	7ba2                	ld	s7,40(sp)
    80003a40:	6165                	addi	sp,sp,112
    80003a42:	8082                	ret
    return 0;
    80003a44:	4501                	li	a0,0
}
    80003a46:	8082                	ret

0000000080003a48 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003a48:	457c                	lw	a5,76(a0)
    80003a4a:	0ed7ee63          	bltu	a5,a3,80003b46 <writei+0xfe>
{
    80003a4e:	7159                	addi	sp,sp,-112
    80003a50:	f486                	sd	ra,104(sp)
    80003a52:	f0a2                	sd	s0,96(sp)
    80003a54:	e8ca                	sd	s2,80(sp)
    80003a56:	e0d2                	sd	s4,64(sp)
    80003a58:	fc56                	sd	s5,56(sp)
    80003a5a:	f85a                	sd	s6,48(sp)
    80003a5c:	f45e                	sd	s7,40(sp)
    80003a5e:	1880                	addi	s0,sp,112
    80003a60:	8aaa                	mv	s5,a0
    80003a62:	8bae                	mv	s7,a1
    80003a64:	8a32                	mv	s4,a2
    80003a66:	8936                	mv	s2,a3
    80003a68:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003a6a:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003a6e:	00043737          	lui	a4,0x43
    80003a72:	0cf76c63          	bltu	a4,a5,80003b4a <writei+0x102>
    80003a76:	0cd7ea63          	bltu	a5,a3,80003b4a <writei+0x102>
    80003a7a:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003a7c:	0a0b0d63          	beqz	s6,80003b36 <writei+0xee>
    80003a80:	eca6                	sd	s1,88(sp)
    80003a82:	f062                	sd	s8,32(sp)
    80003a84:	ec66                	sd	s9,24(sp)
    80003a86:	e86a                	sd	s10,16(sp)
    80003a88:	e46e                	sd	s11,8(sp)
    80003a8a:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003a8c:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a90:	5c7d                	li	s8,-1
    80003a92:	a825                	j	80003aca <writei+0x82>
    80003a94:	020d1d93          	slli	s11,s10,0x20
    80003a98:	020ddd93          	srli	s11,s11,0x20
    80003a9c:	05848513          	addi	a0,s1,88
    80003aa0:	86ee                	mv	a3,s11
    80003aa2:	8652                	mv	a2,s4
    80003aa4:	85de                	mv	a1,s7
    80003aa6:	953e                	add	a0,a0,a5
    80003aa8:	b49fe0ef          	jal	800025f0 <either_copyin>
    80003aac:	05850663          	beq	a0,s8,80003af8 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ab0:	8526                	mv	a0,s1
    80003ab2:	6f0000ef          	jal	800041a2 <log_write>
    brelse(bp);
    80003ab6:	8526                	mv	a0,s1
    80003ab8:	d34ff0ef          	jal	80002fec <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003abc:	013d09bb          	addw	s3,s10,s3
    80003ac0:	012d093b          	addw	s2,s10,s2
    80003ac4:	9a6e                	add	s4,s4,s11
    80003ac6:	0369ff63          	bgeu	s3,s6,80003b04 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    80003aca:	00a9559b          	srliw	a1,s2,0xa
    80003ace:	8556                	mv	a0,s5
    80003ad0:	f7aff0ef          	jal	8000324a <bmap>
    80003ad4:	85aa                	mv	a1,a0
    if (addr == 0)
    80003ad6:	c51d                	beqz	a0,80003b04 <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003ad8:	000aa503          	lw	a0,0(s5)
    80003adc:	c08ff0ef          	jal	80002ee4 <bread>
    80003ae0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003ae2:	3ff97793          	andi	a5,s2,1023
    80003ae6:	40fc873b          	subw	a4,s9,a5
    80003aea:	413b06bb          	subw	a3,s6,s3
    80003aee:	8d3a                	mv	s10,a4
    80003af0:	fae6f2e3          	bgeu	a3,a4,80003a94 <writei+0x4c>
    80003af4:	8d36                	mv	s10,a3
    80003af6:	bf79                	j	80003a94 <writei+0x4c>
      log_write(bp);
    80003af8:	8526                	mv	a0,s1
    80003afa:	6a8000ef          	jal	800041a2 <log_write>
      brelse(bp);
    80003afe:	8526                	mv	a0,s1
    80003b00:	cecff0ef          	jal	80002fec <brelse>
  }

  if (off > ip->size)
    80003b04:	04caa783          	lw	a5,76(s5)
    80003b08:	0327f963          	bgeu	a5,s2,80003b3a <writei+0xf2>
    ip->size = off;
    80003b0c:	052aa623          	sw	s2,76(s5)
    80003b10:	64e6                	ld	s1,88(sp)
    80003b12:	7c02                	ld	s8,32(sp)
    80003b14:	6ce2                	ld	s9,24(sp)
    80003b16:	6d42                	ld	s10,16(sp)
    80003b18:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b1a:	8556                	mv	a0,s5
    80003b1c:	9adff0ef          	jal	800034c8 <iupdate>

  return tot;
    80003b20:	854e                	mv	a0,s3
    80003b22:	69a6                	ld	s3,72(sp)
}
    80003b24:	70a6                	ld	ra,104(sp)
    80003b26:	7406                	ld	s0,96(sp)
    80003b28:	6946                	ld	s2,80(sp)
    80003b2a:	6a06                	ld	s4,64(sp)
    80003b2c:	7ae2                	ld	s5,56(sp)
    80003b2e:	7b42                	ld	s6,48(sp)
    80003b30:	7ba2                	ld	s7,40(sp)
    80003b32:	6165                	addi	sp,sp,112
    80003b34:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003b36:	89da                	mv	s3,s6
    80003b38:	b7cd                	j	80003b1a <writei+0xd2>
    80003b3a:	64e6                	ld	s1,88(sp)
    80003b3c:	7c02                	ld	s8,32(sp)
    80003b3e:	6ce2                	ld	s9,24(sp)
    80003b40:	6d42                	ld	s10,16(sp)
    80003b42:	6da2                	ld	s11,8(sp)
    80003b44:	bfd9                	j	80003b1a <writei+0xd2>
    return -1;
    80003b46:	557d                	li	a0,-1
}
    80003b48:	8082                	ret
    return -1;
    80003b4a:	557d                	li	a0,-1
    80003b4c:	bfe1                	j	80003b24 <writei+0xdc>

0000000080003b4e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b4e:	1141                	addi	sp,sp,-16
    80003b50:	e406                	sd	ra,8(sp)
    80003b52:	e022                	sd	s0,0(sp)
    80003b54:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b56:	4639                	li	a2,14
    80003b58:	a64fd0ef          	jal	80000dbc <strncmp>
}
    80003b5c:	60a2                	ld	ra,8(sp)
    80003b5e:	6402                	ld	s0,0(sp)
    80003b60:	0141                	addi	sp,sp,16
    80003b62:	8082                	ret

0000000080003b64 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b64:	711d                	addi	sp,sp,-96
    80003b66:	ec86                	sd	ra,88(sp)
    80003b68:	e8a2                	sd	s0,80(sp)
    80003b6a:	e4a6                	sd	s1,72(sp)
    80003b6c:	e0ca                	sd	s2,64(sp)
    80003b6e:	fc4e                	sd	s3,56(sp)
    80003b70:	f852                	sd	s4,48(sp)
    80003b72:	f456                	sd	s5,40(sp)
    80003b74:	f05a                	sd	s6,32(sp)
    80003b76:	ec5e                	sd	s7,24(sp)
    80003b78:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003b7a:	04451703          	lh	a4,68(a0)
    80003b7e:	4785                	li	a5,1
    80003b80:	00f71f63          	bne	a4,a5,80003b9e <dirlookup+0x3a>
    80003b84:	892a                	mv	s2,a0
    80003b86:	8aae                	mv	s5,a1
    80003b88:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003b8a:	457c                	lw	a5,76(a0)
    80003b8c:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b8e:	fa040a13          	addi	s4,s0,-96
    80003b92:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003b94:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b98:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003b9a:	e39d                	bnez	a5,80003bc0 <dirlookup+0x5c>
    80003b9c:	a8b9                	j	80003bfa <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003b9e:	00004517          	auipc	a0,0x4
    80003ba2:	92250513          	addi	a0,a0,-1758 # 800074c0 <etext+0x4c0>
    80003ba6:	c8ffc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    80003baa:	00004517          	auipc	a0,0x4
    80003bae:	92e50513          	addi	a0,a0,-1746 # 800074d8 <etext+0x4d8>
    80003bb2:	c83fc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003bb6:	24c1                	addiw	s1,s1,16
    80003bb8:	04c92783          	lw	a5,76(s2)
    80003bbc:	02f4fe63          	bgeu	s1,a5,80003bf8 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bc0:	874e                	mv	a4,s3
    80003bc2:	86a6                	mv	a3,s1
    80003bc4:	8652                	mv	a2,s4
    80003bc6:	4581                	li	a1,0
    80003bc8:	854a                	mv	a0,s2
    80003bca:	d8dff0ef          	jal	80003956 <readi>
    80003bce:	fd351ee3          	bne	a0,s3,80003baa <dirlookup+0x46>
    if (de.inum == 0)
    80003bd2:	fa045783          	lhu	a5,-96(s0)
    80003bd6:	d3e5                	beqz	a5,80003bb6 <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003bd8:	85da                	mv	a1,s6
    80003bda:	8556                	mv	a0,s5
    80003bdc:	f73ff0ef          	jal	80003b4e <namecmp>
    80003be0:	f979                	bnez	a0,80003bb6 <dirlookup+0x52>
      if (poff)
    80003be2:	000b8463          	beqz	s7,80003bea <dirlookup+0x86>
        *poff = off;
    80003be6:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003bea:	fa045583          	lhu	a1,-96(s0)
    80003bee:	00092503          	lw	a0,0(s2)
    80003bf2:	f18ff0ef          	jal	8000330a <iget>
    80003bf6:	a011                	j	80003bfa <dirlookup+0x96>
  return 0;
    80003bf8:	4501                	li	a0,0
}
    80003bfa:	60e6                	ld	ra,88(sp)
    80003bfc:	6446                	ld	s0,80(sp)
    80003bfe:	64a6                	ld	s1,72(sp)
    80003c00:	6906                	ld	s2,64(sp)
    80003c02:	79e2                	ld	s3,56(sp)
    80003c04:	7a42                	ld	s4,48(sp)
    80003c06:	7aa2                	ld	s5,40(sp)
    80003c08:	7b02                	ld	s6,32(sp)
    80003c0a:	6be2                	ld	s7,24(sp)
    80003c0c:	6125                	addi	sp,sp,96
    80003c0e:	8082                	ret

0000000080003c10 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003c10:	711d                	addi	sp,sp,-96
    80003c12:	ec86                	sd	ra,88(sp)
    80003c14:	e8a2                	sd	s0,80(sp)
    80003c16:	e4a6                	sd	s1,72(sp)
    80003c18:	e0ca                	sd	s2,64(sp)
    80003c1a:	fc4e                	sd	s3,56(sp)
    80003c1c:	f852                	sd	s4,48(sp)
    80003c1e:	f456                	sd	s5,40(sp)
    80003c20:	f05a                	sd	s6,32(sp)
    80003c22:	ec5e                	sd	s7,24(sp)
    80003c24:	e862                	sd	s8,16(sp)
    80003c26:	e466                	sd	s9,8(sp)
    80003c28:	e06a                	sd	s10,0(sp)
    80003c2a:	1080                	addi	s0,sp,96
    80003c2c:	84aa                	mv	s1,a0
    80003c2e:	8b2e                	mv	s6,a1
    80003c30:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003c32:	00054703          	lbu	a4,0(a0)
    80003c36:	02f00793          	li	a5,47
    80003c3a:	00f70f63          	beq	a4,a5,80003c58 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c3e:	d0bfd0ef          	jal	80001948 <myproc>
    80003c42:	15053503          	ld	a0,336(a0)
    80003c46:	901ff0ef          	jal	80003546 <idup>
    80003c4a:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003c4c:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003c50:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003c52:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003c54:	4b85                	li	s7,1
    80003c56:	a07d                	j	80003d04 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003c58:	4585                	li	a1,1
    80003c5a:	852e                	mv	a0,a1
    80003c5c:	eaeff0ef          	jal	8000330a <iget>
    80003c60:	8a2a                	mv	s4,a0
    80003c62:	b7ed                	j	80003c4c <namex+0x3c>
      iunlockput(ip);
    80003c64:	8552                	mv	a0,s4
    80003c66:	b6bff0ef          	jal	800037d0 <iunlockput>
      return 0;
    80003c6a:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c6c:	8552                	mv	a0,s4
    80003c6e:	60e6                	ld	ra,88(sp)
    80003c70:	6446                	ld	s0,80(sp)
    80003c72:	64a6                	ld	s1,72(sp)
    80003c74:	6906                	ld	s2,64(sp)
    80003c76:	79e2                	ld	s3,56(sp)
    80003c78:	7a42                	ld	s4,48(sp)
    80003c7a:	7aa2                	ld	s5,40(sp)
    80003c7c:	7b02                	ld	s6,32(sp)
    80003c7e:	6be2                	ld	s7,24(sp)
    80003c80:	6c42                	ld	s8,16(sp)
    80003c82:	6ca2                	ld	s9,8(sp)
    80003c84:	6d02                	ld	s10,0(sp)
    80003c86:	6125                	addi	sp,sp,96
    80003c88:	8082                	ret
      iunlockput(ip);
    80003c8a:	8552                	mv	a0,s4
    80003c8c:	b45ff0ef          	jal	800037d0 <iunlockput>
      return 0;
    80003c90:	4a01                	li	s4,0
    80003c92:	bfe9                	j	80003c6c <namex+0x5c>
      iunlock(ip);
    80003c94:	8552                	mv	a0,s4
    80003c96:	995ff0ef          	jal	8000362a <iunlock>
      return ip;
    80003c9a:	bfc9                	j	80003c6c <namex+0x5c>
      iunlockput(ip);
    80003c9c:	8552                	mv	a0,s4
    80003c9e:	b33ff0ef          	jal	800037d0 <iunlockput>
      return 0;
    80003ca2:	8a4a                	mv	s4,s2
    80003ca4:	b7e1                	j	80003c6c <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003ca6:	8926                	mv	s2,s1
  len = path - s;
    80003ca8:	4d01                	li	s10,0
    80003caa:	4601                	li	a2,0
    memmove(name, s, len);
    80003cac:	2601                	sext.w	a2,a2
    80003cae:	85a6                	mv	a1,s1
    80003cb0:	8556                	mv	a0,s5
    80003cb2:	896fd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003cb6:	9d56                	add	s10,s10,s5
    80003cb8:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb6e8>
  while (*path == '/')
    80003cbc:	00094783          	lbu	a5,0(s2)
    80003cc0:	09379b63          	bne	a5,s3,80003d56 <namex+0x146>
    80003cc4:	84ca                	mv	s1,s2
    path++;
    80003cc6:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003cc8:	0004c783          	lbu	a5,0(s1)
    80003ccc:	ff378de3          	beq	a5,s3,80003cc6 <namex+0xb6>
    ilock(ip);
    80003cd0:	8552                	mv	a0,s4
    80003cd2:	8abff0ef          	jal	8000357c <ilock>
    if (ip->type != T_DIR) {
    80003cd6:	044a1783          	lh	a5,68(s4)
    80003cda:	f97795e3          	bne	a5,s7,80003c64 <namex+0x54>
    if (ip->nlink == 0) {
    80003cde:	04aa1783          	lh	a5,74(s4)
    80003ce2:	d7c5                	beqz	a5,80003c8a <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003ce4:	000b0563          	beqz	s6,80003cee <namex+0xde>
    80003ce8:	0004c783          	lbu	a5,0(s1)
    80003cec:	d7c5                	beqz	a5,80003c94 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003cee:	4601                	li	a2,0
    80003cf0:	85d6                	mv	a1,s5
    80003cf2:	8552                	mv	a0,s4
    80003cf4:	e71ff0ef          	jal	80003b64 <dirlookup>
    80003cf8:	892a                	mv	s2,a0
    80003cfa:	d14d                	beqz	a0,80003c9c <namex+0x8c>
    iunlockput(ip);
    80003cfc:	8552                	mv	a0,s4
    80003cfe:	ad3ff0ef          	jal	800037d0 <iunlockput>
    ip = next;
    80003d02:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003d04:	0004c783          	lbu	a5,0(s1)
    80003d08:	01379763          	bne	a5,s3,80003d16 <namex+0x106>
    path++;
    80003d0c:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003d0e:	0004c783          	lbu	a5,0(s1)
    80003d12:	ff378de3          	beq	a5,s3,80003d0c <namex+0xfc>
  if (*path == 0)
    80003d16:	c7a1                	beqz	a5,80003d5e <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003d18:	0004c783          	lbu	a5,0(s1)
    80003d1c:	fd178713          	addi	a4,a5,-47
    80003d20:	d359                	beqz	a4,80003ca6 <namex+0x96>
    80003d22:	d3d1                	beqz	a5,80003ca6 <namex+0x96>
    80003d24:	8926                	mv	s2,s1
    path++;
    80003d26:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003d28:	00094783          	lbu	a5,0(s2)
    80003d2c:	fd178713          	addi	a4,a5,-47
    80003d30:	c311                	beqz	a4,80003d34 <namex+0x124>
    80003d32:	fbf5                	bnez	a5,80003d26 <namex+0x116>
  len = path - s;
    80003d34:	40990633          	sub	a2,s2,s1
    80003d38:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003d3c:	f7ac58e3          	bge	s8,s10,80003cac <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003d40:	8666                	mv	a2,s9
    80003d42:	85a6                	mv	a1,s1
    80003d44:	8556                	mv	a0,s5
    80003d46:	802fd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003d4a:	00094783          	lbu	a5,0(s2)
    80003d4e:	84ca                	mv	s1,s2
    80003d50:	f7378be3          	beq	a5,s3,80003cc6 <namex+0xb6>
    80003d54:	bfb5                	j	80003cd0 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003d56:	00090463          	beqz	s2,80003d5e <namex+0x14e>
    80003d5a:	84ca                	mv	s1,s2
    80003d5c:	bf95                	j	80003cd0 <namex+0xc0>
  if (nameiparent) {
    80003d5e:	f00b07e3          	beqz	s6,80003c6c <namex+0x5c>
    iput(ip);
    80003d62:	8552                	mv	a0,s4
    80003d64:	99bff0ef          	jal	800036fe <iput>
    return 0;
    80003d68:	4a01                	li	s4,0
    80003d6a:	b709                	j	80003c6c <namex+0x5c>

0000000080003d6c <dirlink>:
{
    80003d6c:	715d                	addi	sp,sp,-80
    80003d6e:	e486                	sd	ra,72(sp)
    80003d70:	e0a2                	sd	s0,64(sp)
    80003d72:	f84a                	sd	s2,48(sp)
    80003d74:	ec56                	sd	s5,24(sp)
    80003d76:	e85a                	sd	s6,16(sp)
    80003d78:	0880                	addi	s0,sp,80
    80003d7a:	892a                	mv	s2,a0
    80003d7c:	8aae                	mv	s5,a1
    80003d7e:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003d80:	4601                	li	a2,0
    80003d82:	de3ff0ef          	jal	80003b64 <dirlookup>
    80003d86:	ed1d                	bnez	a0,80003dc4 <dirlink+0x58>
    80003d88:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003d8a:	04c92483          	lw	s1,76(s2)
    80003d8e:	c4b9                	beqz	s1,80003ddc <dirlink+0x70>
    80003d90:	f44e                	sd	s3,40(sp)
    80003d92:	f052                	sd	s4,32(sp)
    80003d94:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d96:	fb040a13          	addi	s4,s0,-80
    80003d9a:	49c1                	li	s3,16
    80003d9c:	874e                	mv	a4,s3
    80003d9e:	86a6                	mv	a3,s1
    80003da0:	8652                	mv	a2,s4
    80003da2:	4581                	li	a1,0
    80003da4:	854a                	mv	a0,s2
    80003da6:	bb1ff0ef          	jal	80003956 <readi>
    80003daa:	03351163          	bne	a0,s3,80003dcc <dirlink+0x60>
    if (de.inum == 0)
    80003dae:	fb045783          	lhu	a5,-80(s0)
    80003db2:	c39d                	beqz	a5,80003dd8 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003db4:	24c1                	addiw	s1,s1,16
    80003db6:	04c92783          	lw	a5,76(s2)
    80003dba:	fef4e1e3          	bltu	s1,a5,80003d9c <dirlink+0x30>
    80003dbe:	79a2                	ld	s3,40(sp)
    80003dc0:	7a02                	ld	s4,32(sp)
    80003dc2:	a829                	j	80003ddc <dirlink+0x70>
    iput(ip);
    80003dc4:	93bff0ef          	jal	800036fe <iput>
    return -1;
    80003dc8:	557d                	li	a0,-1
    80003dca:	a83d                	j	80003e08 <dirlink+0x9c>
      panic("dirlink read");
    80003dcc:	00003517          	auipc	a0,0x3
    80003dd0:	71c50513          	addi	a0,a0,1820 # 800074e8 <etext+0x4e8>
    80003dd4:	a61fc0ef          	jal	80000834 <panic>
    80003dd8:	79a2                	ld	s3,40(sp)
    80003dda:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003ddc:	4639                	li	a2,14
    80003dde:	85d6                	mv	a1,s5
    80003de0:	fb240513          	addi	a0,s0,-78
    80003de4:	812fd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003de8:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dec:	4741                	li	a4,16
    80003dee:	86a6                	mv	a3,s1
    80003df0:	fb040613          	addi	a2,s0,-80
    80003df4:	4581                	li	a1,0
    80003df6:	854a                	mv	a0,s2
    80003df8:	c51ff0ef          	jal	80003a48 <writei>
    80003dfc:	1541                	addi	a0,a0,-16
    80003dfe:	00a03533          	snez	a0,a0
    80003e02:	40a0053b          	negw	a0,a0
    80003e06:	74e2                	ld	s1,56(sp)
}
    80003e08:	60a6                	ld	ra,72(sp)
    80003e0a:	6406                	ld	s0,64(sp)
    80003e0c:	7942                	ld	s2,48(sp)
    80003e0e:	6ae2                	ld	s5,24(sp)
    80003e10:	6b42                	ld	s6,16(sp)
    80003e12:	6161                	addi	sp,sp,80
    80003e14:	8082                	ret

0000000080003e16 <namei>:

struct inode *
namei(char *path)
{
    80003e16:	1101                	addi	sp,sp,-32
    80003e18:	ec06                	sd	ra,24(sp)
    80003e1a:	e822                	sd	s0,16(sp)
    80003e1c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e1e:	fe040613          	addi	a2,s0,-32
    80003e22:	4581                	li	a1,0
    80003e24:	dedff0ef          	jal	80003c10 <namex>
}
    80003e28:	60e2                	ld	ra,24(sp)
    80003e2a:	6442                	ld	s0,16(sp)
    80003e2c:	6105                	addi	sp,sp,32
    80003e2e:	8082                	ret

0000000080003e30 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003e30:	1141                	addi	sp,sp,-16
    80003e32:	e406                	sd	ra,8(sp)
    80003e34:	e022                	sd	s0,0(sp)
    80003e36:	0800                	addi	s0,sp,16
    80003e38:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e3a:	4585                	li	a1,1
    80003e3c:	dd5ff0ef          	jal	80003c10 <namex>
}
    80003e40:	60a2                	ld	ra,8(sp)
    80003e42:	6402                	ld	s0,0(sp)
    80003e44:	0141                	addi	sp,sp,16
    80003e46:	8082                	ret

0000000080003e48 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e48:	1101                	addi	sp,sp,-32
    80003e4a:	ec06                	sd	ra,24(sp)
    80003e4c:	e822                	sd	s0,16(sp)
    80003e4e:	e426                	sd	s1,8(sp)
    80003e50:	e04a                	sd	s2,0(sp)
    80003e52:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e54:	0001f917          	auipc	s2,0x1f
    80003e58:	88490913          	addi	s2,s2,-1916 # 800226d8 <log>
    80003e5c:	01892583          	lw	a1,24(s2)
    80003e60:	02492503          	lw	a0,36(s2)
    80003e64:	880ff0ef          	jal	80002ee4 <bread>
    80003e68:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003e6a:	02c92603          	lw	a2,44(s2)
    80003e6e:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e70:	00c05f63          	blez	a2,80003e8e <write_head+0x46>
    80003e74:	0001f717          	auipc	a4,0x1f
    80003e78:	89470713          	addi	a4,a4,-1900 # 80022708 <log+0x30>
    80003e7c:	87aa                	mv	a5,a0
    80003e7e:	060a                	slli	a2,a2,0x2
    80003e80:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003e82:	4314                	lw	a3,0(a4)
    80003e84:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003e86:	0711                	addi	a4,a4,4
    80003e88:	0791                	addi	a5,a5,4
    80003e8a:	fec79ce3          	bne	a5,a2,80003e82 <write_head+0x3a>
  }
  bwrite(buf);
    80003e8e:	8526                	mv	a0,s1
    80003e90:	92aff0ef          	jal	80002fba <bwrite>
  brelse(buf);
    80003e94:	8526                	mv	a0,s1
    80003e96:	956ff0ef          	jal	80002fec <brelse>
}
    80003e9a:	60e2                	ld	ra,24(sp)
    80003e9c:	6442                	ld	s0,16(sp)
    80003e9e:	64a2                	ld	s1,8(sp)
    80003ea0:	6902                	ld	s2,0(sp)
    80003ea2:	6105                	addi	sp,sp,32
    80003ea4:	8082                	ret

0000000080003ea6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ea6:	0001f797          	auipc	a5,0x1f
    80003eaa:	85e7a783          	lw	a5,-1954(a5) # 80022704 <log+0x2c>
    80003eae:	0cf05163          	blez	a5,80003f70 <install_trans+0xca>
{
    80003eb2:	715d                	addi	sp,sp,-80
    80003eb4:	e486                	sd	ra,72(sp)
    80003eb6:	e0a2                	sd	s0,64(sp)
    80003eb8:	fc26                	sd	s1,56(sp)
    80003eba:	f84a                	sd	s2,48(sp)
    80003ebc:	f44e                	sd	s3,40(sp)
    80003ebe:	f052                	sd	s4,32(sp)
    80003ec0:	ec56                	sd	s5,24(sp)
    80003ec2:	e85a                	sd	s6,16(sp)
    80003ec4:	e45e                	sd	s7,8(sp)
    80003ec6:	e062                	sd	s8,0(sp)
    80003ec8:	0880                	addi	s0,sp,80
    80003eca:	8b2a                	mv	s6,a0
    80003ecc:	0001fa97          	auipc	s5,0x1f
    80003ed0:	83ca8a93          	addi	s5,s5,-1988 # 80022708 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ed4:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003ed6:	00003c17          	auipc	s8,0x3
    80003eda:	622c0c13          	addi	s8,s8,1570 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003ede:	0001ea17          	auipc	s4,0x1e
    80003ee2:	7faa0a13          	addi	s4,s4,2042 # 800226d8 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003ee6:	40000b93          	li	s7,1024
    80003eea:	a025                	j	80003f12 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003eec:	000aa603          	lw	a2,0(s5)
    80003ef0:	85ce                	mv	a1,s3
    80003ef2:	8562                	mv	a0,s8
    80003ef4:	e16fc0ef          	jal	8000050a <printk>
    80003ef8:	a839                	j	80003f16 <install_trans+0x70>
    brelse(lbuf);
    80003efa:	854a                	mv	a0,s2
    80003efc:	8f0ff0ef          	jal	80002fec <brelse>
    brelse(dbuf);
    80003f00:	8526                	mv	a0,s1
    80003f02:	8eaff0ef          	jal	80002fec <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f06:	2985                	addiw	s3,s3,1
    80003f08:	0a91                	addi	s5,s5,4
    80003f0a:	02ca2783          	lw	a5,44(s4)
    80003f0e:	04f9d563          	bge	s3,a5,80003f58 <install_trans+0xb2>
    if (recovering) {
    80003f12:	fc0b1de3          	bnez	s6,80003eec <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003f16:	018a2583          	lw	a1,24(s4)
    80003f1a:	013585bb          	addw	a1,a1,s3
    80003f1e:	2585                	addiw	a1,a1,1
    80003f20:	024a2503          	lw	a0,36(s4)
    80003f24:	fc1fe0ef          	jal	80002ee4 <bread>
    80003f28:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003f2a:	000aa583          	lw	a1,0(s5)
    80003f2e:	024a2503          	lw	a0,36(s4)
    80003f32:	fb3fe0ef          	jal	80002ee4 <bread>
    80003f36:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003f38:	865e                	mv	a2,s7
    80003f3a:	05890593          	addi	a1,s2,88
    80003f3e:	05850513          	addi	a0,a0,88
    80003f42:	e07fc0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003f46:	8526                	mv	a0,s1
    80003f48:	872ff0ef          	jal	80002fba <bwrite>
    if (recovering == 0)
    80003f4c:	fa0b17e3          	bnez	s6,80003efa <install_trans+0x54>
      bunpin(dbuf);
    80003f50:	8526                	mv	a0,s1
    80003f52:	952ff0ef          	jal	800030a4 <bunpin>
    80003f56:	b755                	j	80003efa <install_trans+0x54>
}
    80003f58:	60a6                	ld	ra,72(sp)
    80003f5a:	6406                	ld	s0,64(sp)
    80003f5c:	74e2                	ld	s1,56(sp)
    80003f5e:	7942                	ld	s2,48(sp)
    80003f60:	79a2                	ld	s3,40(sp)
    80003f62:	7a02                	ld	s4,32(sp)
    80003f64:	6ae2                	ld	s5,24(sp)
    80003f66:	6b42                	ld	s6,16(sp)
    80003f68:	6ba2                	ld	s7,8(sp)
    80003f6a:	6c02                	ld	s8,0(sp)
    80003f6c:	6161                	addi	sp,sp,80
    80003f6e:	8082                	ret
    80003f70:	8082                	ret

0000000080003f72 <initlog>:
{
    80003f72:	7179                	addi	sp,sp,-48
    80003f74:	f406                	sd	ra,40(sp)
    80003f76:	f022                	sd	s0,32(sp)
    80003f78:	ec26                	sd	s1,24(sp)
    80003f7a:	e84a                	sd	s2,16(sp)
    80003f7c:	e44e                	sd	s3,8(sp)
    80003f7e:	1800                	addi	s0,sp,48
    80003f80:	84aa                	mv	s1,a0
    80003f82:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f84:	0001e917          	auipc	s2,0x1e
    80003f88:	75490913          	addi	s2,s2,1876 # 800226d8 <log>
    80003f8c:	00003597          	auipc	a1,0x3
    80003f90:	58c58593          	addi	a1,a1,1420 # 80007518 <etext+0x518>
    80003f94:	854a                	mv	a0,s2
    80003f96:	c13fc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003f9a:	0149a583          	lw	a1,20(s3)
    80003f9e:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003fa2:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003fa6:	8526                	mv	a0,s1
    80003fa8:	f3dfe0ef          	jal	80002ee4 <bread>
  log.lh.n = lh->n;
    80003fac:	4d30                	lw	a2,88(a0)
    80003fae:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003fb2:	00c05f63          	blez	a2,80003fd0 <initlog+0x5e>
    80003fb6:	87aa                	mv	a5,a0
    80003fb8:	0001e717          	auipc	a4,0x1e
    80003fbc:	75070713          	addi	a4,a4,1872 # 80022708 <log+0x30>
    80003fc0:	060a                	slli	a2,a2,0x2
    80003fc2:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003fc4:	4ff4                	lw	a3,92(a5)
    80003fc6:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fc8:	0791                	addi	a5,a5,4
    80003fca:	0711                	addi	a4,a4,4
    80003fcc:	fec79ce3          	bne	a5,a2,80003fc4 <initlog+0x52>
  brelse(buf);
    80003fd0:	81cff0ef          	jal	80002fec <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003fd4:	4505                	li	a0,1
    80003fd6:	ed1ff0ef          	jal	80003ea6 <install_trans>
  log.lh.n = 0;
    80003fda:	0001e797          	auipc	a5,0x1e
    80003fde:	7207a523          	sw	zero,1834(a5) # 80022704 <log+0x2c>
  write_head(); // clear the log
    80003fe2:	e67ff0ef          	jal	80003e48 <write_head>
}
    80003fe6:	70a2                	ld	ra,40(sp)
    80003fe8:	7402                	ld	s0,32(sp)
    80003fea:	64e2                	ld	s1,24(sp)
    80003fec:	6942                	ld	s2,16(sp)
    80003fee:	69a2                	ld	s3,8(sp)
    80003ff0:	6145                	addi	sp,sp,48
    80003ff2:	8082                	ret

0000000080003ff4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ff4:	1101                	addi	sp,sp,-32
    80003ff6:	ec06                	sd	ra,24(sp)
    80003ff8:	e822                	sd	s0,16(sp)
    80003ffa:	e426                	sd	s1,8(sp)
    80003ffc:	e04a                	sd	s2,0(sp)
    80003ffe:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004000:	0001e517          	auipc	a0,0x1e
    80004004:	6d850513          	addi	a0,a0,1752 # 800226d8 <log>
    80004008:	c21fc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    8000400c:	0001e497          	auipc	s1,0x1e
    80004010:	6cc48493          	addi	s1,s1,1740 # 800226d8 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80004014:	4979                	li	s2,30
    80004016:	a821                	j	8000402e <begin_op+0x3a>
      sleep_prepare(&log);
    80004018:	8526                	mv	a0,s1
    8000401a:	91efe0ef          	jal	80002138 <sleep_prepare>
      release(&log.lock);
    8000401e:	8526                	mv	a0,s1
    80004020:	c91fc0ef          	jal	80000cb0 <release>
      sleep();
    80004024:	950fe0ef          	jal	80002174 <sleep>
      acquire(&log.lock);
    80004028:	8526                	mv	a0,s1
    8000402a:	bfffc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    8000402e:	509c                	lw	a5,32(s1)
    80004030:	f7e5                	bnez	a5,80004018 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80004032:	4cd8                	lw	a4,28(s1)
    80004034:	2705                	addiw	a4,a4,1
    80004036:	0027179b          	slliw	a5,a4,0x2
    8000403a:	9fb9                	addw	a5,a5,a4
    8000403c:	0017979b          	slliw	a5,a5,0x1
    80004040:	54d4                	lw	a3,44(s1)
    80004042:	9fb5                	addw	a5,a5,a3
    80004044:	00f95e63          	bge	s2,a5,80004060 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80004048:	8526                	mv	a0,s1
    8000404a:	8eefe0ef          	jal	80002138 <sleep_prepare>
      release(&log.lock);
    8000404e:	8526                	mv	a0,s1
    80004050:	c61fc0ef          	jal	80000cb0 <release>
      sleep();
    80004054:	920fe0ef          	jal	80002174 <sleep>
      acquire(&log.lock);
    80004058:	8526                	mv	a0,s1
    8000405a:	bcffc0ef          	jal	80000c28 <acquire>
    8000405e:	bfc1                	j	8000402e <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80004060:	0001e797          	auipc	a5,0x1e
    80004064:	68e7aa23          	sw	a4,1684(a5) # 800226f4 <log+0x1c>
      release(&log.lock);
    80004068:	0001e517          	auipc	a0,0x1e
    8000406c:	67050513          	addi	a0,a0,1648 # 800226d8 <log>
    80004070:	c41fc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80004074:	60e2                	ld	ra,24(sp)
    80004076:	6442                	ld	s0,16(sp)
    80004078:	64a2                	ld	s1,8(sp)
    8000407a:	6902                	ld	s2,0(sp)
    8000407c:	6105                	addi	sp,sp,32
    8000407e:	8082                	ret

0000000080004080 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004080:	7139                	addi	sp,sp,-64
    80004082:	fc06                	sd	ra,56(sp)
    80004084:	f822                	sd	s0,48(sp)
    80004086:	f426                	sd	s1,40(sp)
    80004088:	f04a                	sd	s2,32(sp)
    8000408a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000408c:	0001e497          	auipc	s1,0x1e
    80004090:	64c48493          	addi	s1,s1,1612 # 800226d8 <log>
    80004094:	8526                	mv	a0,s1
    80004096:	b93fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    8000409a:	4cdc                	lw	a5,28(s1)
    8000409c:	37fd                	addiw	a5,a5,-1
    8000409e:	893e                	mv	s2,a5
    800040a0:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    800040a2:	509c                	lw	a5,32(s1)
    800040a4:	e3b1                	bnez	a5,800040e8 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    800040a6:	04091a63          	bnez	s2,800040fa <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    800040aa:	0001e497          	auipc	s1,0x1e
    800040ae:	62e48493          	addi	s1,s1,1582 # 800226d8 <log>
    800040b2:	4785                	li	a5,1
    800040b4:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800040b6:	8526                	mv	a0,s1
    800040b8:	bf9fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800040bc:	54dc                	lw	a5,44(s1)
    800040be:	06f04063          	bgtz	a5,8000411e <end_op+0x9e>
    acquire(&log.lock);
    800040c2:	0001e497          	auipc	s1,0x1e
    800040c6:	61648493          	addi	s1,s1,1558 # 800226d8 <log>
    800040ca:	8526                	mv	a0,s1
    800040cc:	b5dfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    800040d0:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    800040d4:	549c                	lw	a5,40(s1)
    800040d6:	2785                	addiw	a5,a5,1
    800040d8:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    800040da:	8526                	mv	a0,s1
    800040dc:	8c8fe0ef          	jal	800021a4 <wakeup>
    release(&log.lock);
    800040e0:	8526                	mv	a0,s1
    800040e2:	bcffc0ef          	jal	80000cb0 <release>
}
    800040e6:	a035                	j	80004112 <end_op+0x92>
    800040e8:	ec4e                	sd	s3,24(sp)
    800040ea:	e852                	sd	s4,16(sp)
    800040ec:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800040ee:	00003517          	auipc	a0,0x3
    800040f2:	43250513          	addi	a0,a0,1074 # 80007520 <etext+0x520>
    800040f6:	f3efc0ef          	jal	80000834 <panic>
    wakeup(&log);
    800040fa:	0001e517          	auipc	a0,0x1e
    800040fe:	5de50513          	addi	a0,a0,1502 # 800226d8 <log>
    80004102:	8a2fe0ef          	jal	800021a4 <wakeup>
  release(&log.lock);
    80004106:	0001e517          	auipc	a0,0x1e
    8000410a:	5d250513          	addi	a0,a0,1490 # 800226d8 <log>
    8000410e:	ba3fc0ef          	jal	80000cb0 <release>
}
    80004112:	70e2                	ld	ra,56(sp)
    80004114:	7442                	ld	s0,48(sp)
    80004116:	74a2                	ld	s1,40(sp)
    80004118:	7902                	ld	s2,32(sp)
    8000411a:	6121                	addi	sp,sp,64
    8000411c:	8082                	ret
    8000411e:	ec4e                	sd	s3,24(sp)
    80004120:	e852                	sd	s4,16(sp)
    80004122:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004124:	0001ea97          	auipc	s5,0x1e
    80004128:	5e4a8a93          	addi	s5,s5,1508 # 80022708 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    8000412c:	0001ea17          	auipc	s4,0x1e
    80004130:	5aca0a13          	addi	s4,s4,1452 # 800226d8 <log>
    80004134:	018a2583          	lw	a1,24(s4)
    80004138:	012585bb          	addw	a1,a1,s2
    8000413c:	2585                	addiw	a1,a1,1
    8000413e:	024a2503          	lw	a0,36(s4)
    80004142:	da3fe0ef          	jal	80002ee4 <bread>
    80004146:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004148:	000aa583          	lw	a1,0(s5)
    8000414c:	024a2503          	lw	a0,36(s4)
    80004150:	d95fe0ef          	jal	80002ee4 <bread>
    80004154:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004156:	40000613          	li	a2,1024
    8000415a:	05850593          	addi	a1,a0,88
    8000415e:	05848513          	addi	a0,s1,88
    80004162:	be7fc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    80004166:	8526                	mv	a0,s1
    80004168:	e53fe0ef          	jal	80002fba <bwrite>
    brelse(from);
    8000416c:	854e                	mv	a0,s3
    8000416e:	e7ffe0ef          	jal	80002fec <brelse>
    brelse(to);
    80004172:	8526                	mv	a0,s1
    80004174:	e79fe0ef          	jal	80002fec <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004178:	2905                	addiw	s2,s2,1
    8000417a:	0a91                	addi	s5,s5,4
    8000417c:	02ca2783          	lw	a5,44(s4)
    80004180:	faf94ae3          	blt	s2,a5,80004134 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80004184:	cc5ff0ef          	jal	80003e48 <write_head>
    install_trans(0); // Now install writes to home locations
    80004188:	4501                	li	a0,0
    8000418a:	d1dff0ef          	jal	80003ea6 <install_trans>
    log.lh.n = 0;
    8000418e:	0001e797          	auipc	a5,0x1e
    80004192:	5607ab23          	sw	zero,1398(a5) # 80022704 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80004196:	cb3ff0ef          	jal	80003e48 <write_head>
    8000419a:	69e2                	ld	s3,24(sp)
    8000419c:	6a42                	ld	s4,16(sp)
    8000419e:	6aa2                	ld	s5,8(sp)
    800041a0:	b70d                	j	800040c2 <end_op+0x42>

00000000800041a2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800041a2:	1101                	addi	sp,sp,-32
    800041a4:	ec06                	sd	ra,24(sp)
    800041a6:	e822                	sd	s0,16(sp)
    800041a8:	e426                	sd	s1,8(sp)
    800041aa:	1000                	addi	s0,sp,32
    800041ac:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800041ae:	0001e517          	auipc	a0,0x1e
    800041b2:	52a50513          	addi	a0,a0,1322 # 800226d8 <log>
    800041b6:	a73fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800041ba:	0001e617          	auipc	a2,0x1e
    800041be:	54a62603          	lw	a2,1354(a2) # 80022704 <log+0x2c>
    800041c2:	47f5                	li	a5,29
    800041c4:	04c7cd63          	blt	a5,a2,8000421e <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800041c8:	0001e797          	auipc	a5,0x1e
    800041cc:	52c7a783          	lw	a5,1324(a5) # 800226f4 <log+0x1c>
    800041d0:	04f05d63          	blez	a5,8000422a <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800041d4:	4781                	li	a5,0
    800041d6:	06c05063          	blez	a2,80004236 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    800041da:	44cc                	lw	a1,12(s1)
    800041dc:	0001e717          	auipc	a4,0x1e
    800041e0:	52c70713          	addi	a4,a4,1324 # 80022708 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800041e4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    800041e6:	4314                	lw	a3,0(a4)
    800041e8:	04b68763          	beq	a3,a1,80004236 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    800041ec:	2785                	addiw	a5,a5,1
    800041ee:	0711                	addi	a4,a4,4
    800041f0:	fef61be3          	bne	a2,a5,800041e6 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800041f4:	060a                	slli	a2,a2,0x2
    800041f6:	02060613          	addi	a2,a2,32
    800041fa:	0001e797          	auipc	a5,0x1e
    800041fe:	4de78793          	addi	a5,a5,1246 # 800226d8 <log>
    80004202:	97b2                	add	a5,a5,a2
    80004204:	44d8                	lw	a4,12(s1)
    80004206:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80004208:	8526                	mv	a0,s1
    8000420a:	e67fe0ef          	jal	80003070 <bpin>
    log.lh.n++;
    8000420e:	0001e717          	auipc	a4,0x1e
    80004212:	4ca70713          	addi	a4,a4,1226 # 800226d8 <log>
    80004216:	575c                	lw	a5,44(a4)
    80004218:	2785                	addiw	a5,a5,1
    8000421a:	d75c                	sw	a5,44(a4)
    8000421c:	a815                	j	80004250 <log_write+0xae>
    panic("too big a transaction");
    8000421e:	00003517          	auipc	a0,0x3
    80004222:	31250513          	addi	a0,a0,786 # 80007530 <etext+0x530>
    80004226:	e0efc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    8000422a:	00003517          	auipc	a0,0x3
    8000422e:	31e50513          	addi	a0,a0,798 # 80007548 <etext+0x548>
    80004232:	e02fc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    80004236:	00279693          	slli	a3,a5,0x2
    8000423a:	02068693          	addi	a3,a3,32
    8000423e:	0001e717          	auipc	a4,0x1e
    80004242:	49a70713          	addi	a4,a4,1178 # 800226d8 <log>
    80004246:	9736                	add	a4,a4,a3
    80004248:	44d4                	lw	a3,12(s1)
    8000424a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    8000424c:	faf60ee3          	beq	a2,a5,80004208 <log_write+0x66>
  }
  release(&log.lock);
    80004250:	0001e517          	auipc	a0,0x1e
    80004254:	48850513          	addi	a0,a0,1160 # 800226d8 <log>
    80004258:	a59fc0ef          	jal	80000cb0 <release>
}
    8000425c:	60e2                	ld	ra,24(sp)
    8000425e:	6442                	ld	s0,16(sp)
    80004260:	64a2                	ld	s1,8(sp)
    80004262:	6105                	addi	sp,sp,32
    80004264:	8082                	ret

0000000080004266 <sys_sync>:

uint64
sys_sync(void)
{
    80004266:	1101                	addi	sp,sp,-32
    80004268:	ec06                	sd	ra,24(sp)
    8000426a:	e822                	sd	s0,16(sp)
    8000426c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000426e:	0001e517          	auipc	a0,0x1e
    80004272:	46a50513          	addi	a0,a0,1130 # 800226d8 <log>
    80004276:	9b3fc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    8000427a:	0001e797          	auipc	a5,0x1e
    8000427e:	47e7a783          	lw	a5,1150(a5) # 800226f8 <log+0x20>
    80004282:	e799                	bnez	a5,80004290 <sys_sync+0x2a>
    80004284:	0001e797          	auipc	a5,0x1e
    80004288:	4707a783          	lw	a5,1136(a5) # 800226f4 <log+0x1c>
    8000428c:	02f05c63          	blez	a5,800042c4 <sys_sync+0x5e>
    80004290:	e426                	sd	s1,8(sp)
    80004292:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80004294:	0001e917          	auipc	s2,0x1e
    80004298:	46c92903          	lw	s2,1132(s2) # 80022700 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    8000429c:	0001e497          	auipc	s1,0x1e
    800042a0:	43c48493          	addi	s1,s1,1084 # 800226d8 <log>
    800042a4:	8526                	mv	a0,s1
    800042a6:	e93fd0ef          	jal	80002138 <sleep_prepare>
      release(&log.lock);
    800042aa:	8526                	mv	a0,s1
    800042ac:	a05fc0ef          	jal	80000cb0 <release>
      sleep();
    800042b0:	ec5fd0ef          	jal	80002174 <sleep>
      acquire(&log.lock);
    800042b4:	8526                	mv	a0,s1
    800042b6:	973fc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    800042ba:	549c                	lw	a5,40(s1)
    800042bc:	fef954e3          	bge	s2,a5,800042a4 <sys_sync+0x3e>
    800042c0:	64a2                	ld	s1,8(sp)
    800042c2:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    800042c4:	0001e517          	auipc	a0,0x1e
    800042c8:	41450513          	addi	a0,a0,1044 # 800226d8 <log>
    800042cc:	9e5fc0ef          	jal	80000cb0 <release>
  return 0;
}
    800042d0:	4501                	li	a0,0
    800042d2:	60e2                	ld	ra,24(sp)
    800042d4:	6442                	ld	s0,16(sp)
    800042d6:	6105                	addi	sp,sp,32
    800042d8:	8082                	ret

00000000800042da <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800042da:	1101                	addi	sp,sp,-32
    800042dc:	ec06                	sd	ra,24(sp)
    800042de:	e822                	sd	s0,16(sp)
    800042e0:	e426                	sd	s1,8(sp)
    800042e2:	e04a                	sd	s2,0(sp)
    800042e4:	1000                	addi	s0,sp,32
    800042e6:	84aa                	mv	s1,a0
    800042e8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800042ea:	00003597          	auipc	a1,0x3
    800042ee:	27e58593          	addi	a1,a1,638 # 80007568 <etext+0x568>
    800042f2:	0521                	addi	a0,a0,8
    800042f4:	8b5fc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    800042f8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800042fc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004300:	0204a423          	sw	zero,40(s1)
}
    80004304:	60e2                	ld	ra,24(sp)
    80004306:	6442                	ld	s0,16(sp)
    80004308:	64a2                	ld	s1,8(sp)
    8000430a:	6902                	ld	s2,0(sp)
    8000430c:	6105                	addi	sp,sp,32
    8000430e:	8082                	ret

0000000080004310 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004310:	1101                	addi	sp,sp,-32
    80004312:	ec06                	sd	ra,24(sp)
    80004314:	e822                	sd	s0,16(sp)
    80004316:	e426                	sd	s1,8(sp)
    80004318:	e04a                	sd	s2,0(sp)
    8000431a:	1000                	addi	s0,sp,32
    8000431c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000431e:	00850913          	addi	s2,a0,8
    80004322:	854a                	mv	a0,s2
    80004324:	905fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004328:	409c                	lw	a5,0(s1)
    8000432a:	cf91                	beqz	a5,80004346 <acquiresleep+0x36>
    sleep_prepare(lk);
    8000432c:	8526                	mv	a0,s1
    8000432e:	e0bfd0ef          	jal	80002138 <sleep_prepare>
    release(&lk->lk);
    80004332:	854a                	mv	a0,s2
    80004334:	97dfc0ef          	jal	80000cb0 <release>
    sleep();
    80004338:	e3dfd0ef          	jal	80002174 <sleep>
    acquire(&lk->lk);
    8000433c:	854a                	mv	a0,s2
    8000433e:	8ebfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004342:	409c                	lw	a5,0(s1)
    80004344:	f7e5                	bnez	a5,8000432c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004346:	4785                	li	a5,1
    80004348:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000434a:	dfefd0ef          	jal	80001948 <myproc>
    8000434e:	591c                	lw	a5,48(a0)
    80004350:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004352:	854a                	mv	a0,s2
    80004354:	95dfc0ef          	jal	80000cb0 <release>
}
    80004358:	60e2                	ld	ra,24(sp)
    8000435a:	6442                	ld	s0,16(sp)
    8000435c:	64a2                	ld	s1,8(sp)
    8000435e:	6902                	ld	s2,0(sp)
    80004360:	6105                	addi	sp,sp,32
    80004362:	8082                	ret

0000000080004364 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004364:	1101                	addi	sp,sp,-32
    80004366:	ec06                	sd	ra,24(sp)
    80004368:	e822                	sd	s0,16(sp)
    8000436a:	e426                	sd	s1,8(sp)
    8000436c:	e04a                	sd	s2,0(sp)
    8000436e:	1000                	addi	s0,sp,32
    80004370:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004372:	00850913          	addi	s2,a0,8
    80004376:	854a                	mv	a0,s2
    80004378:	8b1fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    8000437c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004380:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004384:	8526                	mv	a0,s1
    80004386:	e1ffd0ef          	jal	800021a4 <wakeup>
  release(&lk->lk);
    8000438a:	854a                	mv	a0,s2
    8000438c:	925fc0ef          	jal	80000cb0 <release>
}
    80004390:	60e2                	ld	ra,24(sp)
    80004392:	6442                	ld	s0,16(sp)
    80004394:	64a2                	ld	s1,8(sp)
    80004396:	6902                	ld	s2,0(sp)
    80004398:	6105                	addi	sp,sp,32
    8000439a:	8082                	ret

000000008000439c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000439c:	7179                	addi	sp,sp,-48
    8000439e:	f406                	sd	ra,40(sp)
    800043a0:	f022                	sd	s0,32(sp)
    800043a2:	ec26                	sd	s1,24(sp)
    800043a4:	e84a                	sd	s2,16(sp)
    800043a6:	1800                	addi	s0,sp,48
    800043a8:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800043aa:	00850913          	addi	s2,a0,8
    800043ae:	854a                	mv	a0,s2
    800043b0:	879fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800043b4:	409c                	lw	a5,0(s1)
    800043b6:	ef81                	bnez	a5,800043ce <holdingsleep+0x32>
    800043b8:	4481                	li	s1,0
  release(&lk->lk);
    800043ba:	854a                	mv	a0,s2
    800043bc:	8f5fc0ef          	jal	80000cb0 <release>
  return r;
}
    800043c0:	8526                	mv	a0,s1
    800043c2:	70a2                	ld	ra,40(sp)
    800043c4:	7402                	ld	s0,32(sp)
    800043c6:	64e2                	ld	s1,24(sp)
    800043c8:	6942                	ld	s2,16(sp)
    800043ca:	6145                	addi	sp,sp,48
    800043cc:	8082                	ret
    800043ce:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800043d0:	0284a983          	lw	s3,40(s1)
    800043d4:	d74fd0ef          	jal	80001948 <myproc>
    800043d8:	5904                	lw	s1,48(a0)
    800043da:	413484b3          	sub	s1,s1,s3
    800043de:	0014b493          	seqz	s1,s1
    800043e2:	69a2                	ld	s3,8(sp)
    800043e4:	bfd9                	j	800043ba <holdingsleep+0x1e>

00000000800043e6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800043e6:	1141                	addi	sp,sp,-16
    800043e8:	e406                	sd	ra,8(sp)
    800043ea:	e022                	sd	s0,0(sp)
    800043ec:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800043ee:	00003597          	auipc	a1,0x3
    800043f2:	18a58593          	addi	a1,a1,394 # 80007578 <etext+0x578>
    800043f6:	0001e517          	auipc	a0,0x1e
    800043fa:	42a50513          	addi	a0,a0,1066 # 80022820 <ftable>
    800043fe:	faafc0ef          	jal	80000ba8 <initlock>
}
    80004402:	60a2                	ld	ra,8(sp)
    80004404:	6402                	ld	s0,0(sp)
    80004406:	0141                	addi	sp,sp,16
    80004408:	8082                	ret

000000008000440a <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    8000440a:	1101                	addi	sp,sp,-32
    8000440c:	ec06                	sd	ra,24(sp)
    8000440e:	e822                	sd	s0,16(sp)
    80004410:	e426                	sd	s1,8(sp)
    80004412:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004414:	0001e517          	auipc	a0,0x1e
    80004418:	40c50513          	addi	a0,a0,1036 # 80022820 <ftable>
    8000441c:	80dfc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004420:	0001e497          	auipc	s1,0x1e
    80004424:	41848493          	addi	s1,s1,1048 # 80022838 <ftable+0x18>
    80004428:	0001f717          	auipc	a4,0x1f
    8000442c:	3b070713          	addi	a4,a4,944 # 800237d8 <disk>
    if (f->ref == 0) {
    80004430:	40dc                	lw	a5,4(s1)
    80004432:	cf89                	beqz	a5,8000444c <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004434:	02848493          	addi	s1,s1,40
    80004438:	fee49ce3          	bne	s1,a4,80004430 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000443c:	0001e517          	auipc	a0,0x1e
    80004440:	3e450513          	addi	a0,a0,996 # 80022820 <ftable>
    80004444:	86dfc0ef          	jal	80000cb0 <release>
  return 0;
    80004448:	4481                	li	s1,0
    8000444a:	a809                	j	8000445c <filealloc+0x52>
      f->ref = 1;
    8000444c:	4785                	li	a5,1
    8000444e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004450:	0001e517          	auipc	a0,0x1e
    80004454:	3d050513          	addi	a0,a0,976 # 80022820 <ftable>
    80004458:	859fc0ef          	jal	80000cb0 <release>
}
    8000445c:	8526                	mv	a0,s1
    8000445e:	60e2                	ld	ra,24(sp)
    80004460:	6442                	ld	s0,16(sp)
    80004462:	64a2                	ld	s1,8(sp)
    80004464:	6105                	addi	sp,sp,32
    80004466:	8082                	ret

0000000080004468 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004468:	1101                	addi	sp,sp,-32
    8000446a:	ec06                	sd	ra,24(sp)
    8000446c:	e822                	sd	s0,16(sp)
    8000446e:	e426                	sd	s1,8(sp)
    80004470:	1000                	addi	s0,sp,32
    80004472:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004474:	0001e517          	auipc	a0,0x1e
    80004478:	3ac50513          	addi	a0,a0,940 # 80022820 <ftable>
    8000447c:	facfc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    80004480:	40dc                	lw	a5,4(s1)
    80004482:	02f05063          	blez	a5,800044a2 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004486:	2785                	addiw	a5,a5,1
    80004488:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000448a:	0001e517          	auipc	a0,0x1e
    8000448e:	39650513          	addi	a0,a0,918 # 80022820 <ftable>
    80004492:	81ffc0ef          	jal	80000cb0 <release>
  return f;
}
    80004496:	8526                	mv	a0,s1
    80004498:	60e2                	ld	ra,24(sp)
    8000449a:	6442                	ld	s0,16(sp)
    8000449c:	64a2                	ld	s1,8(sp)
    8000449e:	6105                	addi	sp,sp,32
    800044a0:	8082                	ret
    panic("filedup");
    800044a2:	00003517          	auipc	a0,0x3
    800044a6:	0de50513          	addi	a0,a0,222 # 80007580 <etext+0x580>
    800044aa:	b8afc0ef          	jal	80000834 <panic>

00000000800044ae <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044ae:	7139                	addi	sp,sp,-64
    800044b0:	fc06                	sd	ra,56(sp)
    800044b2:	f822                	sd	s0,48(sp)
    800044b4:	f426                	sd	s1,40(sp)
    800044b6:	0080                	addi	s0,sp,64
    800044b8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044ba:	0001e517          	auipc	a0,0x1e
    800044be:	36650513          	addi	a0,a0,870 # 80022820 <ftable>
    800044c2:	f66fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800044c6:	40dc                	lw	a5,4(s1)
    800044c8:	04f05a63          	blez	a5,8000451c <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    800044cc:	37fd                	addiw	a5,a5,-1
    800044ce:	c0dc                	sw	a5,4(s1)
    800044d0:	06f04063          	bgtz	a5,80004530 <fileclose+0x82>
    800044d4:	f04a                	sd	s2,32(sp)
    800044d6:	ec4e                	sd	s3,24(sp)
    800044d8:	e852                	sd	s4,16(sp)
    800044da:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800044dc:	0004a903          	lw	s2,0(s1)
    800044e0:	0094c783          	lbu	a5,9(s1)
    800044e4:	89be                	mv	s3,a5
    800044e6:	689c                	ld	a5,16(s1)
    800044e8:	8a3e                	mv	s4,a5
    800044ea:	6c9c                	ld	a5,24(s1)
    800044ec:	8abe                	mv	s5,a5
  f->ref = 0;
    800044ee:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800044f2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800044f6:	0001e517          	auipc	a0,0x1e
    800044fa:	32a50513          	addi	a0,a0,810 # 80022820 <ftable>
    800044fe:	fb2fc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    80004502:	4785                	li	a5,1
    80004504:	04f90163          	beq	s2,a5,80004546 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    80004508:	ffe9079b          	addiw	a5,s2,-2
    8000450c:	4705                	li	a4,1
    8000450e:	04f77563          	bgeu	a4,a5,80004558 <fileclose+0xaa>
    80004512:	7902                	ld	s2,32(sp)
    80004514:	69e2                	ld	s3,24(sp)
    80004516:	6a42                	ld	s4,16(sp)
    80004518:	6aa2                	ld	s5,8(sp)
    8000451a:	a00d                	j	8000453c <fileclose+0x8e>
    8000451c:	f04a                	sd	s2,32(sp)
    8000451e:	ec4e                	sd	s3,24(sp)
    80004520:	e852                	sd	s4,16(sp)
    80004522:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004524:	00003517          	auipc	a0,0x3
    80004528:	06450513          	addi	a0,a0,100 # 80007588 <etext+0x588>
    8000452c:	b08fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    80004530:	0001e517          	auipc	a0,0x1e
    80004534:	2f050513          	addi	a0,a0,752 # 80022820 <ftable>
    80004538:	f78fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000453c:	70e2                	ld	ra,56(sp)
    8000453e:	7442                	ld	s0,48(sp)
    80004540:	74a2                	ld	s1,40(sp)
    80004542:	6121                	addi	sp,sp,64
    80004544:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004546:	85ce                	mv	a1,s3
    80004548:	8552                	mv	a0,s4
    8000454a:	36a000ef          	jal	800048b4 <pipeclose>
    8000454e:	7902                	ld	s2,32(sp)
    80004550:	69e2                	ld	s3,24(sp)
    80004552:	6a42                	ld	s4,16(sp)
    80004554:	6aa2                	ld	s5,8(sp)
    80004556:	b7dd                	j	8000453c <fileclose+0x8e>
    begin_op();
    80004558:	a9dff0ef          	jal	80003ff4 <begin_op>
    iput(ff.ip);
    8000455c:	8556                	mv	a0,s5
    8000455e:	9a0ff0ef          	jal	800036fe <iput>
    end_op();
    80004562:	b1fff0ef          	jal	80004080 <end_op>
    80004566:	7902                	ld	s2,32(sp)
    80004568:	69e2                	ld	s3,24(sp)
    8000456a:	6a42                	ld	s4,16(sp)
    8000456c:	6aa2                	ld	s5,8(sp)
    8000456e:	b7f9                	j	8000453c <fileclose+0x8e>

0000000080004570 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004570:	715d                	addi	sp,sp,-80
    80004572:	e486                	sd	ra,72(sp)
    80004574:	e0a2                	sd	s0,64(sp)
    80004576:	fc26                	sd	s1,56(sp)
    80004578:	f052                	sd	s4,32(sp)
    8000457a:	0880                	addi	s0,sp,80
    8000457c:	84aa                	mv	s1,a0
    8000457e:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004580:	bc8fd0ef          	jal	80001948 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004584:	409c                	lw	a5,0(s1)
    80004586:	37f9                	addiw	a5,a5,-2
    80004588:	4705                	li	a4,1
    8000458a:	04f76963          	bltu	a4,a5,800045dc <filestat+0x6c>
    8000458e:	f84a                	sd	s2,48(sp)
    80004590:	f44e                	sd	s3,40(sp)
    80004592:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    80004594:	fb840993          	addi	s3,s0,-72
    80004598:	4661                	li	a2,24
    8000459a:	4581                	li	a1,0
    8000459c:	854e                	mv	a0,s3
    8000459e:	f4afc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    800045a2:	6c88                	ld	a0,24(s1)
    800045a4:	fd9fe0ef          	jal	8000357c <ilock>
    stati(f->ip, &st);
    800045a8:	85ce                	mv	a1,s3
    800045aa:	6c88                	ld	a0,24(s1)
    800045ac:	b7cff0ef          	jal	80003928 <stati>
    iunlock(f->ip);
    800045b0:	6c88                	ld	a0,24(s1)
    800045b2:	878ff0ef          	jal	8000362a <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    800045b6:	4761                	li	a4,24
    800045b8:	86ce                	mv	a3,s3
    800045ba:	8652                	mv	a2,s4
    800045bc:	04893583          	ld	a1,72(s2)
    800045c0:	05093503          	ld	a0,80(s2)
    800045c4:	fbffc0ef          	jal	80001582 <copyout>
    800045c8:	41f5551b          	sraiw	a0,a0,0x1f
    800045cc:	7942                	ld	s2,48(sp)
    800045ce:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800045d0:	60a6                	ld	ra,72(sp)
    800045d2:	6406                	ld	s0,64(sp)
    800045d4:	74e2                	ld	s1,56(sp)
    800045d6:	7a02                	ld	s4,32(sp)
    800045d8:	6161                	addi	sp,sp,80
    800045da:	8082                	ret
  return -1;
    800045dc:	557d                	li	a0,-1
    800045de:	bfcd                	j	800045d0 <filestat+0x60>

00000000800045e0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800045e0:	7179                	addi	sp,sp,-48
    800045e2:	f406                	sd	ra,40(sp)
    800045e4:	f022                	sd	s0,32(sp)
    800045e6:	e84a                	sd	s2,16(sp)
    800045e8:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    800045ea:	00854783          	lbu	a5,8(a0)
    800045ee:	c3dd                	beqz	a5,80004694 <fileread+0xb4>
    800045f0:	ec26                	sd	s1,24(sp)
    800045f2:	e44e                	sd	s3,8(sp)
    800045f4:	84aa                	mv	s1,a0
    800045f6:	892e                	mv	s2,a1
    800045f8:	89b2                	mv	s3,a2
    800045fa:	01f6579b          	srliw	a5,a2,0x1f
    800045fe:	ebc9                	bnez	a5,80004690 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    80004600:	411c                	lw	a5,0(a0)
    80004602:	4705                	li	a4,1
    80004604:	04e78363          	beq	a5,a4,8000464a <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004608:	470d                	li	a4,3
    8000460a:	04e78763          	beq	a5,a4,80004658 <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    8000460e:	4709                	li	a4,2
    80004610:	06e79a63          	bne	a5,a4,80004684 <fileread+0xa4>
    ilock(f->ip);
    80004614:	6d08                	ld	a0,24(a0)
    80004616:	f67fe0ef          	jal	8000357c <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000461a:	874e                	mv	a4,s3
    8000461c:	5094                	lw	a3,32(s1)
    8000461e:	864a                	mv	a2,s2
    80004620:	4585                	li	a1,1
    80004622:	6c88                	ld	a0,24(s1)
    80004624:	b32ff0ef          	jal	80003956 <readi>
    80004628:	892a                	mv	s2,a0
    8000462a:	00a05563          	blez	a0,80004634 <fileread+0x54>
      f->off += r;
    8000462e:	509c                	lw	a5,32(s1)
    80004630:	9fa9                	addw	a5,a5,a0
    80004632:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004634:	6c88                	ld	a0,24(s1)
    80004636:	ff5fe0ef          	jal	8000362a <iunlock>
    8000463a:	64e2                	ld	s1,24(sp)
    8000463c:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000463e:	854a                	mv	a0,s2
    80004640:	70a2                	ld	ra,40(sp)
    80004642:	7402                	ld	s0,32(sp)
    80004644:	6942                	ld	s2,16(sp)
    80004646:	6145                	addi	sp,sp,48
    80004648:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000464a:	6908                	ld	a0,16(a0)
    8000464c:	3e2000ef          	jal	80004a2e <piperead>
    80004650:	892a                	mv	s2,a0
    80004652:	64e2                	ld	s1,24(sp)
    80004654:	69a2                	ld	s3,8(sp)
    80004656:	b7e5                	j	8000463e <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004658:	02451783          	lh	a5,36(a0)
    8000465c:	03079693          	slli	a3,a5,0x30
    80004660:	92c1                	srli	a3,a3,0x30
    80004662:	4725                	li	a4,9
    80004664:	02d76b63          	bltu	a4,a3,8000469a <fileread+0xba>
    80004668:	0792                	slli	a5,a5,0x4
    8000466a:	0001e717          	auipc	a4,0x1e
    8000466e:	11670713          	addi	a4,a4,278 # 80022780 <devsw>
    80004672:	97ba                	add	a5,a5,a4
    80004674:	639c                	ld	a5,0(a5)
    80004676:	c79d                	beqz	a5,800046a4 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    80004678:	4505                	li	a0,1
    8000467a:	9782                	jalr	a5
    8000467c:	892a                	mv	s2,a0
    8000467e:	64e2                	ld	s1,24(sp)
    80004680:	69a2                	ld	s3,8(sp)
    80004682:	bf75                	j	8000463e <fileread+0x5e>
    panic("fileread");
    80004684:	00003517          	auipc	a0,0x3
    80004688:	f1450513          	addi	a0,a0,-236 # 80007598 <etext+0x598>
    8000468c:	9a8fc0ef          	jal	80000834 <panic>
    80004690:	64e2                	ld	s1,24(sp)
    80004692:	69a2                	ld	s3,8(sp)
    return -1;
    80004694:	57fd                	li	a5,-1
    80004696:	893e                	mv	s2,a5
    80004698:	b75d                	j	8000463e <fileread+0x5e>
      return -1;
    8000469a:	57fd                	li	a5,-1
    8000469c:	893e                	mv	s2,a5
    8000469e:	64e2                	ld	s1,24(sp)
    800046a0:	69a2                	ld	s3,8(sp)
    800046a2:	bf71                	j	8000463e <fileread+0x5e>
    800046a4:	57fd                	li	a5,-1
    800046a6:	893e                	mv	s2,a5
    800046a8:	64e2                	ld	s1,24(sp)
    800046aa:	69a2                	ld	s3,8(sp)
    800046ac:	bf49                	j	8000463e <fileread+0x5e>

00000000800046ae <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    800046ae:	00954783          	lbu	a5,9(a0)
    800046b2:	12078b63          	beqz	a5,800047e8 <filewrite+0x13a>
{
    800046b6:	711d                	addi	sp,sp,-96
    800046b8:	ec86                	sd	ra,88(sp)
    800046ba:	e8a2                	sd	s0,80(sp)
    800046bc:	e0ca                	sd	s2,64(sp)
    800046be:	f456                	sd	s5,40(sp)
    800046c0:	f05a                	sd	s6,32(sp)
    800046c2:	1080                	addi	s0,sp,96
    800046c4:	892a                	mv	s2,a0
    800046c6:	8b2e                	mv	s6,a1
    800046c8:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    800046ca:	01f6579b          	srliw	a5,a2,0x1f
    800046ce:	0e079d63          	bnez	a5,800047c8 <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    800046d2:	411c                	lw	a5,0(a0)
    800046d4:	4705                	li	a4,1
    800046d6:	02e78a63          	beq	a5,a4,8000470a <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800046da:	470d                	li	a4,3
    800046dc:	02e78b63          	beq	a5,a4,80004712 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    800046e0:	4709                	li	a4,2
    800046e2:	0ce79763          	bne	a5,a4,800047b0 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    800046e6:	0ec05763          	blez	a2,800047d4 <filewrite+0x126>
    800046ea:	e4a6                	sd	s1,72(sp)
    800046ec:	fc4e                	sd	s3,56(sp)
    800046ee:	f852                	sd	s4,48(sp)
    800046f0:	ec5e                	sd	s7,24(sp)
    800046f2:	e862                	sd	s8,16(sp)
    800046f4:	e466                	sd	s9,8(sp)
    int i = 0;
    800046f6:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    800046f8:	6b85                	lui	s7,0x1
    800046fa:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800046fe:	6785                	lui	a5,0x1
    80004700:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004704:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004706:	4c05                	li	s8,1
    80004708:	a8ad                	j	80004782 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    8000470a:	6908                	ld	a0,16(a0)
    8000470c:	206000ef          	jal	80004912 <pipewrite>
    80004710:	a849                	j	800047a2 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004712:	02451783          	lh	a5,36(a0)
    80004716:	03079693          	slli	a3,a5,0x30
    8000471a:	92c1                	srli	a3,a3,0x30
    8000471c:	4725                	li	a4,9
    8000471e:	0ad76763          	bltu	a4,a3,800047cc <filewrite+0x11e>
    80004722:	0792                	slli	a5,a5,0x4
    80004724:	0001e717          	auipc	a4,0x1e
    80004728:	05c70713          	addi	a4,a4,92 # 80022780 <devsw>
    8000472c:	97ba                	add	a5,a5,a4
    8000472e:	679c                	ld	a5,8(a5)
    80004730:	c3c5                	beqz	a5,800047d0 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004732:	4505                	li	a0,1
    80004734:	9782                	jalr	a5
    80004736:	a0b5                	j	800047a2 <filewrite+0xf4>
      if (n1 > max)
    80004738:	2981                	sext.w	s3,s3
      begin_op();
    8000473a:	8bbff0ef          	jal	80003ff4 <begin_op>
      ilock(f->ip);
    8000473e:	01893503          	ld	a0,24(s2)
    80004742:	e3bfe0ef          	jal	8000357c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004746:	874e                	mv	a4,s3
    80004748:	02092683          	lw	a3,32(s2)
    8000474c:	016a0633          	add	a2,s4,s6
    80004750:	85e2                	mv	a1,s8
    80004752:	01893503          	ld	a0,24(s2)
    80004756:	af2ff0ef          	jal	80003a48 <writei>
    8000475a:	84aa                	mv	s1,a0
    8000475c:	00a05763          	blez	a0,8000476a <filewrite+0xbc>
        f->off += r;
    80004760:	02092783          	lw	a5,32(s2)
    80004764:	9fa9                	addw	a5,a5,a0
    80004766:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000476a:	01893503          	ld	a0,24(s2)
    8000476e:	ebdfe0ef          	jal	8000362a <iunlock>
      end_op();
    80004772:	90fff0ef          	jal	80004080 <end_op>

      if (r != n1) {
    80004776:	00999d63          	bne	s3,s1,80004790 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    8000477a:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    8000477e:	015a5963          	bge	s4,s5,80004790 <filewrite+0xe2>
      int n1 = n - i;
    80004782:	414a87bb          	subw	a5,s5,s4
    80004786:	89be                	mv	s3,a5
      if (n1 > max)
    80004788:	fafbd8e3          	bge	s7,a5,80004738 <filewrite+0x8a>
    8000478c:	89e6                	mv	s3,s9
    8000478e:	b76d                	j	80004738 <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    80004790:	054a9463          	bne	s5,s4,800047d8 <filewrite+0x12a>
    80004794:	8556                	mv	a0,s5
    80004796:	64a6                	ld	s1,72(sp)
    80004798:	79e2                	ld	s3,56(sp)
    8000479a:	7a42                	ld	s4,48(sp)
    8000479c:	6be2                	ld	s7,24(sp)
    8000479e:	6c42                	ld	s8,16(sp)
    800047a0:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800047a2:	60e6                	ld	ra,88(sp)
    800047a4:	6446                	ld	s0,80(sp)
    800047a6:	6906                	ld	s2,64(sp)
    800047a8:	7aa2                	ld	s5,40(sp)
    800047aa:	7b02                	ld	s6,32(sp)
    800047ac:	6125                	addi	sp,sp,96
    800047ae:	8082                	ret
    800047b0:	e4a6                	sd	s1,72(sp)
    800047b2:	fc4e                	sd	s3,56(sp)
    800047b4:	f852                	sd	s4,48(sp)
    800047b6:	ec5e                	sd	s7,24(sp)
    800047b8:	e862                	sd	s8,16(sp)
    800047ba:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800047bc:	00003517          	auipc	a0,0x3
    800047c0:	dec50513          	addi	a0,a0,-532 # 800075a8 <etext+0x5a8>
    800047c4:	870fc0ef          	jal	80000834 <panic>
    return -1;
    800047c8:	557d                	li	a0,-1
    800047ca:	bfe1                	j	800047a2 <filewrite+0xf4>
      return -1;
    800047cc:	557d                	li	a0,-1
    800047ce:	bfd1                	j	800047a2 <filewrite+0xf4>
    800047d0:	557d                	li	a0,-1
    800047d2:	bfc1                	j	800047a2 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    800047d4:	8532                	mv	a0,a2
    800047d6:	b7f1                	j	800047a2 <filewrite+0xf4>
    800047d8:	557d                	li	a0,-1
    800047da:	64a6                	ld	s1,72(sp)
    800047dc:	79e2                	ld	s3,56(sp)
    800047de:	7a42                	ld	s4,48(sp)
    800047e0:	6be2                	ld	s7,24(sp)
    800047e2:	6c42                	ld	s8,16(sp)
    800047e4:	6ca2                	ld	s9,8(sp)
    800047e6:	bf75                	j	800047a2 <filewrite+0xf4>
    return -1;
    800047e8:	557d                	li	a0,-1
}
    800047ea:	8082                	ret

00000000800047ec <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800047ec:	7179                	addi	sp,sp,-48
    800047ee:	f406                	sd	ra,40(sp)
    800047f0:	f022                	sd	s0,32(sp)
    800047f2:	ec26                	sd	s1,24(sp)
    800047f4:	e052                	sd	s4,0(sp)
    800047f6:	1800                	addi	s0,sp,48
    800047f8:	84aa                	mv	s1,a0
    800047fa:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800047fc:	0005b023          	sd	zero,0(a1)
    80004800:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004804:	c07ff0ef          	jal	8000440a <filealloc>
    80004808:	e088                	sd	a0,0(s1)
    8000480a:	c549                	beqz	a0,80004894 <pipealloc+0xa8>
    8000480c:	bffff0ef          	jal	8000440a <filealloc>
    80004810:	00aa3023          	sd	a0,0(s4)
    80004814:	cd25                	beqz	a0,8000488c <pipealloc+0xa0>
    80004816:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004818:	b36fc0ef          	jal	80000b4e <kalloc>
    8000481c:	892a                	mv	s2,a0
    8000481e:	c12d                	beqz	a0,80004880 <pipealloc+0x94>
    80004820:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004822:	4985                	li	s3,1
    80004824:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004828:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000482c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004830:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004834:	00003597          	auipc	a1,0x3
    80004838:	d8458593          	addi	a1,a1,-636 # 800075b8 <etext+0x5b8>
    8000483c:	b6cfc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004840:	609c                	ld	a5,0(s1)
    80004842:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004846:	609c                	ld	a5,0(s1)
    80004848:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000484c:	609c                	ld	a5,0(s1)
    8000484e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004852:	609c                	ld	a5,0(s1)
    80004854:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004858:	000a3783          	ld	a5,0(s4)
    8000485c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004860:	000a3783          	ld	a5,0(s4)
    80004864:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004868:	000a3783          	ld	a5,0(s4)
    8000486c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004870:	000a3783          	ld	a5,0(s4)
    80004874:	0127b823          	sd	s2,16(a5)
  return 0;
    80004878:	4501                	li	a0,0
    8000487a:	6942                	ld	s2,16(sp)
    8000487c:	69a2                	ld	s3,8(sp)
    8000487e:	a01d                	j	800048a4 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004880:	6088                	ld	a0,0(s1)
    80004882:	c119                	beqz	a0,80004888 <pipealloc+0x9c>
    80004884:	6942                	ld	s2,16(sp)
    80004886:	a029                	j	80004890 <pipealloc+0xa4>
    80004888:	6942                	ld	s2,16(sp)
    8000488a:	a029                	j	80004894 <pipealloc+0xa8>
    8000488c:	6088                	ld	a0,0(s1)
    8000488e:	c10d                	beqz	a0,800048b0 <pipealloc+0xc4>
    fileclose(*f0);
    80004890:	c1fff0ef          	jal	800044ae <fileclose>
  if (*f1)
    80004894:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004898:	557d                	li	a0,-1
  if (*f1)
    8000489a:	c789                	beqz	a5,800048a4 <pipealloc+0xb8>
    fileclose(*f1);
    8000489c:	853e                	mv	a0,a5
    8000489e:	c11ff0ef          	jal	800044ae <fileclose>
  return -1;
    800048a2:	557d                	li	a0,-1
}
    800048a4:	70a2                	ld	ra,40(sp)
    800048a6:	7402                	ld	s0,32(sp)
    800048a8:	64e2                	ld	s1,24(sp)
    800048aa:	6a02                	ld	s4,0(sp)
    800048ac:	6145                	addi	sp,sp,48
    800048ae:	8082                	ret
  return -1;
    800048b0:	557d                	li	a0,-1
    800048b2:	bfcd                	j	800048a4 <pipealloc+0xb8>

00000000800048b4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800048b4:	1101                	addi	sp,sp,-32
    800048b6:	ec06                	sd	ra,24(sp)
    800048b8:	e822                	sd	s0,16(sp)
    800048ba:	e426                	sd	s1,8(sp)
    800048bc:	e04a                	sd	s2,0(sp)
    800048be:	1000                	addi	s0,sp,32
    800048c0:	84aa                	mv	s1,a0
    800048c2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800048c4:	b64fc0ef          	jal	80000c28 <acquire>
  if (writable) {
    800048c8:	02090763          	beqz	s2,800048f6 <pipeclose+0x42>
    pi->writeopen = 0;
    800048cc:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800048d0:	21848513          	addi	a0,s1,536
    800048d4:	8d1fd0ef          	jal	800021a4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    800048d8:	2204a783          	lw	a5,544(s1)
    800048dc:	e781                	bnez	a5,800048e4 <pipeclose+0x30>
    800048de:	2244a783          	lw	a5,548(s1)
    800048e2:	c38d                	beqz	a5,80004904 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    800048e4:	8526                	mv	a0,s1
    800048e6:	bcafc0ef          	jal	80000cb0 <release>
}
    800048ea:	60e2                	ld	ra,24(sp)
    800048ec:	6442                	ld	s0,16(sp)
    800048ee:	64a2                	ld	s1,8(sp)
    800048f0:	6902                	ld	s2,0(sp)
    800048f2:	6105                	addi	sp,sp,32
    800048f4:	8082                	ret
    pi->readopen = 0;
    800048f6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800048fa:	21c48513          	addi	a0,s1,540
    800048fe:	8a7fd0ef          	jal	800021a4 <wakeup>
    80004902:	bfd9                	j	800048d8 <pipeclose+0x24>
    release(&pi->lock);
    80004904:	8526                	mv	a0,s1
    80004906:	baafc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    8000490a:	8526                	mv	a0,s1
    8000490c:	95afc0ef          	jal	80000a66 <kfree>
    80004910:	bfe9                	j	800048ea <pipeclose+0x36>

0000000080004912 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004912:	7159                	addi	sp,sp,-112
    80004914:	f486                	sd	ra,104(sp)
    80004916:	f0a2                	sd	s0,96(sp)
    80004918:	eca6                	sd	s1,88(sp)
    8000491a:	e8ca                	sd	s2,80(sp)
    8000491c:	e4ce                	sd	s3,72(sp)
    8000491e:	e0d2                	sd	s4,64(sp)
    80004920:	fc56                	sd	s5,56(sp)
    80004922:	1880                	addi	s0,sp,112
    80004924:	84aa                	mv	s1,a0
    80004926:	8aae                	mv	s5,a1
    80004928:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000492a:	81efd0ef          	jal	80001948 <myproc>
    8000492e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004930:	8526                	mv	a0,s1
    80004932:	af6fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    80004936:	0f405a63          	blez	s4,80004a2a <pipewrite+0x118>
    8000493a:	f85a                	sd	s6,48(sp)
    8000493c:	f45e                	sd	s7,40(sp)
    8000493e:	f062                	sd	s8,32(sp)
    80004940:	ec66                	sd	s9,24(sp)
    80004942:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004944:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004946:	f9f40c13          	addi	s8,s0,-97
    8000494a:	4b85                	li	s7,1
    8000494c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000494e:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    80004952:	21c48c93          	addi	s9,s1,540
    80004956:	a0a1                	j	8000499e <pipewrite+0x8c>
      release(&pi->lock);
    80004958:	8526                	mv	a0,s1
    8000495a:	b56fc0ef          	jal	80000cb0 <release>
      return -1;
    8000495e:	597d                	li	s2,-1
    80004960:	7b42                	ld	s6,48(sp)
    80004962:	7ba2                	ld	s7,40(sp)
    80004964:	7c02                	ld	s8,32(sp)
    80004966:	6ce2                	ld	s9,24(sp)
    80004968:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000496a:	854a                	mv	a0,s2
    8000496c:	70a6                	ld	ra,104(sp)
    8000496e:	7406                	ld	s0,96(sp)
    80004970:	64e6                	ld	s1,88(sp)
    80004972:	6946                	ld	s2,80(sp)
    80004974:	69a6                	ld	s3,72(sp)
    80004976:	6a06                	ld	s4,64(sp)
    80004978:	7ae2                	ld	s5,56(sp)
    8000497a:	6165                	addi	sp,sp,112
    8000497c:	8082                	ret
      wakeup(&pi->nread);
    8000497e:	856a                	mv	a0,s10
    80004980:	825fd0ef          	jal	800021a4 <wakeup>
      sleep_prepare(&pi->nwrite);
    80004984:	8566                	mv	a0,s9
    80004986:	fb2fd0ef          	jal	80002138 <sleep_prepare>
      release(&pi->lock);
    8000498a:	8526                	mv	a0,s1
    8000498c:	b24fc0ef          	jal	80000cb0 <release>
      sleep();
    80004990:	fe4fd0ef          	jal	80002174 <sleep>
      acquire(&pi->lock);
    80004994:	8526                	mv	a0,s1
    80004996:	a92fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    8000499a:	07495b63          	bge	s2,s4,80004a10 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    8000499e:	2204a783          	lw	a5,544(s1)
    800049a2:	dbdd                	beqz	a5,80004958 <pipewrite+0x46>
    800049a4:	854e                	mv	a0,s3
    800049a6:	9f1fd0ef          	jal	80002396 <killed>
    800049aa:	f55d                	bnez	a0,80004958 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    800049ac:	2184a783          	lw	a5,536(s1)
    800049b0:	21c4a703          	lw	a4,540(s1)
    800049b4:	2007879b          	addiw	a5,a5,512
    800049b8:	fcf703e3          	beq	a4,a5,8000497e <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800049bc:	875e                	mv	a4,s7
    800049be:	015906b3          	add	a3,s2,s5
    800049c2:	8662                	mv	a2,s8
    800049c4:	0489b583          	ld	a1,72(s3)
    800049c8:	0509b503          	ld	a0,80(s3)
    800049cc:	c7dfc0ef          	jal	80001648 <copyin>
    800049d0:	03650163          	beq	a0,s6,800049f2 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800049d4:	21c4a783          	lw	a5,540(s1)
    800049d8:	0017871b          	addiw	a4,a5,1
    800049dc:	20e4ae23          	sw	a4,540(s1)
    800049e0:	1ff7f793          	andi	a5,a5,511
    800049e4:	97a6                	add	a5,a5,s1
    800049e6:	f9f44703          	lbu	a4,-97(s0)
    800049ea:	00e78c23          	sb	a4,24(a5)
      i++;
    800049ee:	2905                	addiw	s2,s2,1
    800049f0:	b76d                	j	8000499a <pipewrite+0x88>
        if (i == 0)
    800049f2:	00090863          	beqz	s2,80004a02 <pipewrite+0xf0>
    800049f6:	7b42                	ld	s6,48(sp)
    800049f8:	7ba2                	ld	s7,40(sp)
    800049fa:	7c02                	ld	s8,32(sp)
    800049fc:	6ce2                	ld	s9,24(sp)
    800049fe:	6d42                	ld	s10,16(sp)
    80004a00:	a829                	j	80004a1a <pipewrite+0x108>
          i = -1;
    80004a02:	892a                	mv	s2,a0
        break;
    80004a04:	7b42                	ld	s6,48(sp)
    80004a06:	7ba2                	ld	s7,40(sp)
    80004a08:	7c02                	ld	s8,32(sp)
    80004a0a:	6ce2                	ld	s9,24(sp)
    80004a0c:	6d42                	ld	s10,16(sp)
    80004a0e:	a031                	j	80004a1a <pipewrite+0x108>
    80004a10:	7b42                	ld	s6,48(sp)
    80004a12:	7ba2                	ld	s7,40(sp)
    80004a14:	7c02                	ld	s8,32(sp)
    80004a16:	6ce2                	ld	s9,24(sp)
    80004a18:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004a1a:	21848513          	addi	a0,s1,536
    80004a1e:	f86fd0ef          	jal	800021a4 <wakeup>
  release(&pi->lock);
    80004a22:	8526                	mv	a0,s1
    80004a24:	a8cfc0ef          	jal	80000cb0 <release>
  return i;
    80004a28:	b789                	j	8000496a <pipewrite+0x58>
  int i = 0;
    80004a2a:	4901                	li	s2,0
    80004a2c:	b7fd                	j	80004a1a <pipewrite+0x108>

0000000080004a2e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a2e:	711d                	addi	sp,sp,-96
    80004a30:	ec86                	sd	ra,88(sp)
    80004a32:	e8a2                	sd	s0,80(sp)
    80004a34:	e4a6                	sd	s1,72(sp)
    80004a36:	e0ca                	sd	s2,64(sp)
    80004a38:	fc4e                	sd	s3,56(sp)
    80004a3a:	f852                	sd	s4,48(sp)
    80004a3c:	f456                	sd	s5,40(sp)
    80004a3e:	1080                	addi	s0,sp,96
    80004a40:	84aa                	mv	s1,a0
    80004a42:	89ae                	mv	s3,a1
    80004a44:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a46:	f03fc0ef          	jal	80001948 <myproc>
    80004a4a:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    80004a4c:	8526                	mv	a0,s1
    80004a4e:	9dafc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004a52:	0d505263          	blez	s5,80004b16 <piperead+0xe8>
    80004a56:	2184a703          	lw	a4,536(s1)
    80004a5a:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004a5e:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004a62:	02f71e63          	bne	a4,a5,80004a9e <piperead+0x70>
    80004a66:	2244a783          	lw	a5,548(s1)
    80004a6a:	c3b9                	beqz	a5,80004ab0 <piperead+0x82>
    if (killed(pr)) {
    80004a6c:	854a                	mv	a0,s2
    80004a6e:	929fd0ef          	jal	80002396 <killed>
    80004a72:	e915                	bnez	a0,80004aa6 <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004a74:	8552                	mv	a0,s4
    80004a76:	ec2fd0ef          	jal	80002138 <sleep_prepare>
    release(&pi->lock);
    80004a7a:	8526                	mv	a0,s1
    80004a7c:	a34fc0ef          	jal	80000cb0 <release>
    sleep();
    80004a80:	ef4fd0ef          	jal	80002174 <sleep>
    acquire(&pi->lock);
    80004a84:	8526                	mv	a0,s1
    80004a86:	9a2fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004a8a:	2184a703          	lw	a4,536(s1)
    80004a8e:	21c4a783          	lw	a5,540(s1)
    80004a92:	fcf70ae3          	beq	a4,a5,80004a66 <piperead+0x38>
    80004a96:	f05a                	sd	s6,32(sp)
    80004a98:	ec5e                	sd	s7,24(sp)
    80004a9a:	e862                	sd	s8,16(sp)
    80004a9c:	a829                	j	80004ab6 <piperead+0x88>
    80004a9e:	f05a                	sd	s6,32(sp)
    80004aa0:	ec5e                	sd	s7,24(sp)
    80004aa2:	e862                	sd	s8,16(sp)
    80004aa4:	a809                	j	80004ab6 <piperead+0x88>
      release(&pi->lock);
    80004aa6:	8526                	mv	a0,s1
    80004aa8:	a08fc0ef          	jal	80000cb0 <release>
      return -1;
    80004aac:	5a7d                	li	s4,-1
    80004aae:	a8a5                	j	80004b26 <piperead+0xf8>
    80004ab0:	f05a                	sd	s6,32(sp)
    80004ab2:	ec5e                	sd	s7,24(sp)
    80004ab4:	e862                	sd	s8,16(sp)
{
    80004ab6:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004ab8:	faf40c13          	addi	s8,s0,-81
    80004abc:	4b85                	li	s7,1
    80004abe:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    80004ac0:	2184a783          	lw	a5,536(s1)
    80004ac4:	21c4a703          	lw	a4,540(s1)
    80004ac8:	06f70e63          	beq	a4,a5,80004b44 <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    80004acc:	1ff7f793          	andi	a5,a5,511
    80004ad0:	97a6                	add	a5,a5,s1
    80004ad2:	0187c783          	lbu	a5,24(a5)
    80004ad6:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004ada:	875e                	mv	a4,s7
    80004adc:	86e2                	mv	a3,s8
    80004ade:	864e                	mv	a2,s3
    80004ae0:	04893583          	ld	a1,72(s2)
    80004ae4:	05093503          	ld	a0,80(s2)
    80004ae8:	a9bfc0ef          	jal	80001582 <copyout>
    80004aec:	01650f63          	beq	a0,s6,80004b0a <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004af0:	2184a783          	lw	a5,536(s1)
    80004af4:	2785                	addiw	a5,a5,1
    80004af6:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004afa:	2a05                	addiw	s4,s4,1
    80004afc:	0985                	addi	s3,s3,1
    80004afe:	fd4a91e3          	bne	s5,s4,80004ac0 <piperead+0x92>
    80004b02:	7b02                	ld	s6,32(sp)
    80004b04:	6be2                	ld	s7,24(sp)
    80004b06:	6c42                	ld	s8,16(sp)
    80004b08:	a801                	j	80004b18 <piperead+0xea>
      if (i == 0)
    80004b0a:	020a0863          	beqz	s4,80004b3a <piperead+0x10c>
    80004b0e:	7b02                	ld	s6,32(sp)
    80004b10:	6be2                	ld	s7,24(sp)
    80004b12:	6c42                	ld	s8,16(sp)
    80004b14:	a011                	j	80004b18 <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004b16:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004b18:	21c48513          	addi	a0,s1,540
    80004b1c:	e88fd0ef          	jal	800021a4 <wakeup>
  release(&pi->lock);
    80004b20:	8526                	mv	a0,s1
    80004b22:	98efc0ef          	jal	80000cb0 <release>
  return i;
}
    80004b26:	8552                	mv	a0,s4
    80004b28:	60e6                	ld	ra,88(sp)
    80004b2a:	6446                	ld	s0,80(sp)
    80004b2c:	64a6                	ld	s1,72(sp)
    80004b2e:	6906                	ld	s2,64(sp)
    80004b30:	79e2                	ld	s3,56(sp)
    80004b32:	7a42                	ld	s4,48(sp)
    80004b34:	7aa2                	ld	s5,40(sp)
    80004b36:	6125                	addi	sp,sp,96
    80004b38:	8082                	ret
        i = -1;
    80004b3a:	8a2a                	mv	s4,a0
    80004b3c:	7b02                	ld	s6,32(sp)
    80004b3e:	6be2                	ld	s7,24(sp)
    80004b40:	6c42                	ld	s8,16(sp)
    80004b42:	bfd9                	j	80004b18 <piperead+0xea>
    80004b44:	7b02                	ld	s6,32(sp)
    80004b46:	6be2                	ld	s7,24(sp)
    80004b48:	6c42                	ld	s8,16(sp)
    80004b4a:	b7f9                	j	80004b18 <piperead+0xea>

0000000080004b4c <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004b4c:	1141                	addi	sp,sp,-16
    80004b4e:	e406                	sd	ra,8(sp)
    80004b50:	e022                	sd	s0,0(sp)
    80004b52:	0800                	addi	s0,sp,16
    80004b54:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004b56:	0035151b          	slliw	a0,a0,0x3
    80004b5a:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    80004b5c:	8b89                	andi	a5,a5,2
    80004b5e:	c399                	beqz	a5,80004b64 <flags2perm+0x18>
    perm |= PTE_W;
    80004b60:	00456513          	ori	a0,a0,4
  return perm;
}
    80004b64:	60a2                	ld	ra,8(sp)
    80004b66:	6402                	ld	s0,0(sp)
    80004b68:	0141                	addi	sp,sp,16
    80004b6a:	8082                	ret

0000000080004b6c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004b6c:	de010113          	addi	sp,sp,-544
    80004b70:	20113c23          	sd	ra,536(sp)
    80004b74:	20813823          	sd	s0,528(sp)
    80004b78:	20913423          	sd	s1,520(sp)
    80004b7c:	21213023          	sd	s2,512(sp)
    80004b80:	1400                	addi	s0,sp,544
    80004b82:	892a                	mv	s2,a0
    80004b84:	dea43823          	sd	a0,-528(s0)
    80004b88:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b8c:	dbdfc0ef          	jal	80001948 <myproc>
    80004b90:	84aa                	mv	s1,a0

  begin_op();
    80004b92:	c62ff0ef          	jal	80003ff4 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004b96:	854a                	mv	a0,s2
    80004b98:	a7eff0ef          	jal	80003e16 <namei>
    80004b9c:	cd21                	beqz	a0,80004bf4 <kexec+0x88>
    80004b9e:	fbd2                	sd	s4,496(sp)
    80004ba0:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ba2:	9dbfe0ef          	jal	8000357c <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ba6:	04000713          	li	a4,64
    80004baa:	4681                	li	a3,0
    80004bac:	e5040613          	addi	a2,s0,-432
    80004bb0:	4581                	li	a1,0
    80004bb2:	8552                	mv	a0,s4
    80004bb4:	da3fe0ef          	jal	80003956 <readi>
    80004bb8:	04000793          	li	a5,64
    80004bbc:	00f51a63          	bne	a0,a5,80004bd0 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004bc0:	e5042703          	lw	a4,-432(s0)
    80004bc4:	464c47b7          	lui	a5,0x464c4
    80004bc8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004bcc:	02f70863          	beq	a4,a5,80004bfc <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004bd0:	8552                	mv	a0,s4
    80004bd2:	bfffe0ef          	jal	800037d0 <iunlockput>
    end_op();
    80004bd6:	caaff0ef          	jal	80004080 <end_op>
  }
  return -1;
    80004bda:	557d                	li	a0,-1
    80004bdc:	7a5e                	ld	s4,496(sp)
}
    80004bde:	21813083          	ld	ra,536(sp)
    80004be2:	21013403          	ld	s0,528(sp)
    80004be6:	20813483          	ld	s1,520(sp)
    80004bea:	20013903          	ld	s2,512(sp)
    80004bee:	22010113          	addi	sp,sp,544
    80004bf2:	8082                	ret
    end_op();
    80004bf4:	c8cff0ef          	jal	80004080 <end_op>
    return -1;
    80004bf8:	557d                	li	a0,-1
    80004bfa:	b7d5                	j	80004bde <kexec+0x72>
    80004bfc:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004bfe:	8526                	mv	a0,s1
    80004c00:	e4ffc0ef          	jal	80001a4e <proc_pagetable>
    80004c04:	8b2a                	mv	s6,a0
    80004c06:	26050e63          	beqz	a0,80004e82 <kexec+0x316>
    80004c0a:	ffce                	sd	s3,504(sp)
    80004c0c:	f7d6                	sd	s5,488(sp)
    80004c0e:	efde                	sd	s7,472(sp)
    80004c10:	ebe2                	sd	s8,464(sp)
    80004c12:	e7e6                	sd	s9,456(sp)
    80004c14:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004c16:	e8845783          	lhu	a5,-376(s0)
    80004c1a:	14078263          	beqz	a5,80004d5e <kexec+0x1f2>
    80004c1e:	ff6e                	sd	s11,440(sp)
    80004c20:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c24:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004c26:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004c28:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004c2c:	6c85                	lui	s9,0x1
    80004c2e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004c32:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004c36:	6a85                	lui	s5,0x1
    80004c38:	a085                	j	80004c98 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004c3a:	00003517          	auipc	a0,0x3
    80004c3e:	98650513          	addi	a0,a0,-1658 # 800075c0 <etext+0x5c0>
    80004c42:	bf3fb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004c46:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004c48:	874a                	mv	a4,s2
    80004c4a:	009b86bb          	addw	a3,s7,s1
    80004c4e:	4581                	li	a1,0
    80004c50:	8552                	mv	a0,s4
    80004c52:	d05fe0ef          	jal	80003956 <readi>
    80004c56:	22a91a63          	bne	s2,a0,80004e8a <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004c5a:	009a84bb          	addw	s1,s5,s1
    80004c5e:	0334f263          	bgeu	s1,s3,80004c82 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004c62:	02049593          	slli	a1,s1,0x20
    80004c66:	9181                	srli	a1,a1,0x20
    80004c68:	95e2                	add	a1,a1,s8
    80004c6a:	855a                	mv	a0,s6
    80004c6c:	bacfc0ef          	jal	80001018 <walkaddr>
    80004c70:	862a                	mv	a2,a0
    if (pa == 0)
    80004c72:	d561                	beqz	a0,80004c3a <kexec+0xce>
    if (sz - i < PGSIZE)
    80004c74:	409987bb          	subw	a5,s3,s1
    80004c78:	893e                	mv	s2,a5
    80004c7a:	fcfcf6e3          	bgeu	s9,a5,80004c46 <kexec+0xda>
    80004c7e:	8956                	mv	s2,s5
    80004c80:	b7d9                	j	80004c46 <kexec+0xda>
    sz = sz1;
    80004c82:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004c86:	2d05                	addiw	s10,s10,1
    80004c88:	e0843783          	ld	a5,-504(s0)
    80004c8c:	0387869b          	addiw	a3,a5,56
    80004c90:	e8845783          	lhu	a5,-376(s0)
    80004c94:	06fd5d63          	bge	s10,a5,80004d0e <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004c98:	e0d43423          	sd	a3,-504(s0)
    80004c9c:	876e                	mv	a4,s11
    80004c9e:	e1840613          	addi	a2,s0,-488
    80004ca2:	4581                	li	a1,0
    80004ca4:	8552                	mv	a0,s4
    80004ca6:	cb1fe0ef          	jal	80003956 <readi>
    80004caa:	1db51e63          	bne	a0,s11,80004e86 <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004cae:	e1842783          	lw	a5,-488(s0)
    80004cb2:	4705                	li	a4,1
    80004cb4:	fce799e3          	bne	a5,a4,80004c86 <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004cb8:	e4043483          	ld	s1,-448(s0)
    80004cbc:	e3843783          	ld	a5,-456(s0)
    80004cc0:	1ef4e363          	bltu	s1,a5,80004ea6 <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004cc4:	e2843783          	ld	a5,-472(s0)
    80004cc8:	94be                	add	s1,s1,a5
    80004cca:	1ef4e163          	bltu	s1,a5,80004eac <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004cce:	de843703          	ld	a4,-536(s0)
    80004cd2:	8ff9                	and	a5,a5,a4
    80004cd4:	1c079f63          	bnez	a5,80004eb2 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004cd8:	e1c42503          	lw	a0,-484(s0)
    80004cdc:	e71ff0ef          	jal	80004b4c <flags2perm>
    80004ce0:	86aa                	mv	a3,a0
    80004ce2:	8626                	mv	a2,s1
    80004ce4:	85ca                	mv	a1,s2
    80004ce6:	855a                	mv	a0,s6
    80004ce8:	e06fc0ef          	jal	800012ee <uvmalloc>
    80004cec:	dea43c23          	sd	a0,-520(s0)
    80004cf0:	1c050463          	beqz	a0,80004eb8 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004cf4:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004cf8:	00098863          	beqz	s3,80004d08 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004cfc:	e2843c03          	ld	s8,-472(s0)
    80004d00:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004d04:	4481                	li	s1,0
    80004d06:	bfb1                	j	80004c62 <kexec+0xf6>
    sz = sz1;
    80004d08:	df843903          	ld	s2,-520(s0)
    80004d0c:	bfad                	j	80004c86 <kexec+0x11a>
    80004d0e:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004d10:	8552                	mv	a0,s4
    80004d12:	abffe0ef          	jal	800037d0 <iunlockput>
  end_op();
    80004d16:	b6aff0ef          	jal	80004080 <end_op>
  p = myproc();
    80004d1a:	c2ffc0ef          	jal	80001948 <myproc>
    80004d1e:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004d20:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004d24:	6c05                	lui	s8,0x1
    80004d26:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004d28:	9c4a                	add	s8,s8,s2
    80004d2a:	77fd                	lui	a5,0xfffff
    80004d2c:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004d30:	4691                	li	a3,4
    80004d32:	6609                	lui	a2,0x2
    80004d34:	9662                	add	a2,a2,s8
    80004d36:	85e2                	mv	a1,s8
    80004d38:	855a                	mv	a0,s6
    80004d3a:	db4fc0ef          	jal	800012ee <uvmalloc>
    80004d3e:	892a                	mv	s2,a0
    80004d40:	e10d                	bnez	a0,80004d62 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004d42:	85e2                	mv	a1,s8
    80004d44:	855a                	mv	a0,s6
    80004d46:	d8dfc0ef          	jal	80001ad2 <proc_freepagetable>
  return -1;
    80004d4a:	557d                	li	a0,-1
    80004d4c:	79fe                	ld	s3,504(sp)
    80004d4e:	7a5e                	ld	s4,496(sp)
    80004d50:	7abe                	ld	s5,488(sp)
    80004d52:	7b1e                	ld	s6,480(sp)
    80004d54:	6bfe                	ld	s7,472(sp)
    80004d56:	6c5e                	ld	s8,464(sp)
    80004d58:	6cbe                	ld	s9,456(sp)
    80004d5a:	6d1e                	ld	s10,448(sp)
    80004d5c:	b549                	j	80004bde <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d5e:	4901                	li	s2,0
    80004d60:	bf45                	j	80004d10 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004d62:	75f9                	lui	a1,0xffffe
    80004d64:	95aa                	add	a1,a1,a0
    80004d66:	855a                	mv	a0,s6
    80004d68:	f58fc0ef          	jal	800014c0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004d6c:	80090a13          	addi	s4,s2,-2048
    80004d70:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004d74:	e0043783          	ld	a5,-512(s0)
    80004d78:	6388                	ld	a0,0(a5)
    80004d7a:	c545                	beqz	a0,80004e22 <kexec+0x2b6>
  sp = sz;
    80004d7c:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004d7e:	4481                	li	s1,0
    ustack[argc] = sp;
    80004d80:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004d84:	8eefc0ef          	jal	80000e72 <strlen>
    80004d88:	0015079b          	addiw	a5,a0,1
    80004d8c:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d90:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004d94:	134c6563          	bltu	s8,s4,80004ebe <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d98:	e0043d03          	ld	s10,-512(s0)
    80004d9c:	000d3c83          	ld	s9,0(s10)
    80004da0:	8566                	mv	a0,s9
    80004da2:	8d0fc0ef          	jal	80000e72 <strlen>
    80004da6:	0015071b          	addiw	a4,a0,1
    80004daa:	86e6                	mv	a3,s9
    80004dac:	8662                	mv	a2,s8
    80004dae:	85ca                	mv	a1,s2
    80004db0:	855a                	mv	a0,s6
    80004db2:	fd0fc0ef          	jal	80001582 <copyout>
    80004db6:	10054663          	bltz	a0,80004ec2 <kexec+0x356>
    ustack[argc] = sp;
    80004dba:	00349793          	slli	a5,s1,0x3
    80004dbe:	97de                	add	a5,a5,s7
    80004dc0:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb6e8>
  for (argc = 0; argv[argc]; argc++) {
    80004dc4:	0485                	addi	s1,s1,1
    80004dc6:	008d0793          	addi	a5,s10,8
    80004dca:	e0f43023          	sd	a5,-512(s0)
    80004dce:	008d3503          	ld	a0,8(s10)
    80004dd2:	f94d                	bnez	a0,80004d84 <kexec+0x218>
  ustack[argc] = 0;
    80004dd4:	00349793          	slli	a5,s1,0x3
    80004dd8:	f9078793          	addi	a5,a5,-112
    80004ddc:	97a2                	add	a5,a5,s0
    80004dde:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004de2:	00349713          	slli	a4,s1,0x3
    80004de6:	0721                	addi	a4,a4,8
    80004de8:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004dec:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004df0:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004df2:	f54be8e3          	bltu	s7,s4,80004d42 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004df6:	e9040693          	addi	a3,s0,-368
    80004dfa:	865e                	mv	a2,s7
    80004dfc:	85ca                	mv	a1,s2
    80004dfe:	855a                	mv	a0,s6
    80004e00:	f82fc0ef          	jal	80001582 <copyout>
    80004e04:	f2054fe3          	bltz	a0,80004d42 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004e08:	0589b783          	ld	a5,88(s3)
    80004e0c:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004e10:	df043783          	ld	a5,-528(s0)
    80004e14:	0007c703          	lbu	a4,0(a5)
    80004e18:	c30d                	beqz	a4,80004e3a <kexec+0x2ce>
    80004e1a:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004e1c:	02f00693          	li	a3,47
    80004e20:	a801                	j	80004e30 <kexec+0x2c4>
  sp = sz;
    80004e22:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004e24:	4481                	li	s1,0
    80004e26:	b77d                	j	80004dd4 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004e28:	0785                	addi	a5,a5,1
    80004e2a:	fff7c703          	lbu	a4,-1(a5)
    80004e2e:	c711                	beqz	a4,80004e3a <kexec+0x2ce>
    if (*s == '/')
    80004e30:	fed71ce3          	bne	a4,a3,80004e28 <kexec+0x2bc>
      last = s + 1;
    80004e34:	def43823          	sd	a5,-528(s0)
    80004e38:	bfc5                	j	80004e28 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e3a:	4641                	li	a2,16
    80004e3c:	df043583          	ld	a1,-528(s0)
    80004e40:	15898513          	addi	a0,s3,344
    80004e44:	ff9fb0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004e48:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004e4c:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004e50:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004e54:	0589b783          	ld	a5,88(s3)
    80004e58:	e6843703          	ld	a4,-408(s0)
    80004e5c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004e5e:	0589b783          	ld	a5,88(s3)
    80004e62:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e66:	85d6                	mv	a1,s5
    80004e68:	c6bfc0ef          	jal	80001ad2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e6c:	0004851b          	sext.w	a0,s1
    80004e70:	79fe                	ld	s3,504(sp)
    80004e72:	7a5e                	ld	s4,496(sp)
    80004e74:	7abe                	ld	s5,488(sp)
    80004e76:	7b1e                	ld	s6,480(sp)
    80004e78:	6bfe                	ld	s7,472(sp)
    80004e7a:	6c5e                	ld	s8,464(sp)
    80004e7c:	6cbe                	ld	s9,456(sp)
    80004e7e:	6d1e                	ld	s10,448(sp)
    80004e80:	bbb9                	j	80004bde <kexec+0x72>
    80004e82:	7b1e                	ld	s6,480(sp)
    80004e84:	b3b1                	j	80004bd0 <kexec+0x64>
    80004e86:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004e8a:	df843583          	ld	a1,-520(s0)
    80004e8e:	855a                	mv	a0,s6
    80004e90:	c43fc0ef          	jal	80001ad2 <proc_freepagetable>
  if (ip) {
    80004e94:	79fe                	ld	s3,504(sp)
    80004e96:	7abe                	ld	s5,488(sp)
    80004e98:	7b1e                	ld	s6,480(sp)
    80004e9a:	6bfe                	ld	s7,472(sp)
    80004e9c:	6c5e                	ld	s8,464(sp)
    80004e9e:	6cbe                	ld	s9,456(sp)
    80004ea0:	6d1e                	ld	s10,448(sp)
    80004ea2:	7dfa                	ld	s11,440(sp)
    80004ea4:	b335                	j	80004bd0 <kexec+0x64>
    80004ea6:	df243c23          	sd	s2,-520(s0)
    80004eaa:	b7c5                	j	80004e8a <kexec+0x31e>
    80004eac:	df243c23          	sd	s2,-520(s0)
    80004eb0:	bfe9                	j	80004e8a <kexec+0x31e>
    80004eb2:	df243c23          	sd	s2,-520(s0)
    80004eb6:	bfd1                	j	80004e8a <kexec+0x31e>
    80004eb8:	df243c23          	sd	s2,-520(s0)
    80004ebc:	b7f9                	j	80004e8a <kexec+0x31e>
  sz = sz1;
    80004ebe:	8c4a                	mv	s8,s2
    80004ec0:	b549                	j	80004d42 <kexec+0x1d6>
    80004ec2:	8c4a                	mv	s8,s2
    80004ec4:	bdbd                	j	80004d42 <kexec+0x1d6>

0000000080004ec6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ec6:	7179                	addi	sp,sp,-48
    80004ec8:	f406                	sd	ra,40(sp)
    80004eca:	f022                	sd	s0,32(sp)
    80004ecc:	ec26                	sd	s1,24(sp)
    80004ece:	e84a                	sd	s2,16(sp)
    80004ed0:	1800                	addi	s0,sp,48
    80004ed2:	892e                	mv	s2,a1
    80004ed4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004ed6:	fdc40593          	addi	a1,s0,-36
    80004eda:	c77fd0ef          	jal	80002b50 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004ede:	fdc42703          	lw	a4,-36(s0)
    80004ee2:	47bd                	li	a5,15
    80004ee4:	02e7ea63          	bltu	a5,a4,80004f18 <argfd+0x52>
    80004ee8:	a61fc0ef          	jal	80001948 <myproc>
    80004eec:	fdc42703          	lw	a4,-36(s0)
    80004ef0:	00371793          	slli	a5,a4,0x3
    80004ef4:	0d078793          	addi	a5,a5,208
    80004ef8:	953e                	add	a0,a0,a5
    80004efa:	611c                	ld	a5,0(a0)
    80004efc:	c385                	beqz	a5,80004f1c <argfd+0x56>
    return -1;
  if (pfd)
    80004efe:	00090463          	beqz	s2,80004f06 <argfd+0x40>
    *pfd = fd;
    80004f02:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004f06:	4501                	li	a0,0
  if (pf)
    80004f08:	c091                	beqz	s1,80004f0c <argfd+0x46>
    *pf = f;
    80004f0a:	e09c                	sd	a5,0(s1)
}
    80004f0c:	70a2                	ld	ra,40(sp)
    80004f0e:	7402                	ld	s0,32(sp)
    80004f10:	64e2                	ld	s1,24(sp)
    80004f12:	6942                	ld	s2,16(sp)
    80004f14:	6145                	addi	sp,sp,48
    80004f16:	8082                	ret
    return -1;
    80004f18:	557d                	li	a0,-1
    80004f1a:	bfcd                	j	80004f0c <argfd+0x46>
    80004f1c:	557d                	li	a0,-1
    80004f1e:	b7fd                	j	80004f0c <argfd+0x46>

0000000080004f20 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f20:	1101                	addi	sp,sp,-32
    80004f22:	ec06                	sd	ra,24(sp)
    80004f24:	e822                	sd	s0,16(sp)
    80004f26:	e426                	sd	s1,8(sp)
    80004f28:	1000                	addi	s0,sp,32
    80004f2a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f2c:	a1dfc0ef          	jal	80001948 <myproc>
    80004f30:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004f32:	0d050793          	addi	a5,a0,208
    80004f36:	4501                	li	a0,0
    80004f38:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004f3a:	6398                	ld	a4,0(a5)
    80004f3c:	cb19                	beqz	a4,80004f52 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004f3e:	2505                	addiw	a0,a0,1
    80004f40:	07a1                	addi	a5,a5,8
    80004f42:	fed51ce3          	bne	a0,a3,80004f3a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f46:	557d                	li	a0,-1
}
    80004f48:	60e2                	ld	ra,24(sp)
    80004f4a:	6442                	ld	s0,16(sp)
    80004f4c:	64a2                	ld	s1,8(sp)
    80004f4e:	6105                	addi	sp,sp,32
    80004f50:	8082                	ret
      p->ofile[fd] = f;
    80004f52:	00351793          	slli	a5,a0,0x3
    80004f56:	0d078793          	addi	a5,a5,208
    80004f5a:	963e                	add	a2,a2,a5
    80004f5c:	e204                	sd	s1,0(a2)
      return fd;
    80004f5e:	b7ed                	j	80004f48 <fdalloc+0x28>

0000000080004f60 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004f60:	715d                	addi	sp,sp,-80
    80004f62:	e486                	sd	ra,72(sp)
    80004f64:	e0a2                	sd	s0,64(sp)
    80004f66:	fc26                	sd	s1,56(sp)
    80004f68:	f84a                	sd	s2,48(sp)
    80004f6a:	f052                	sd	s4,32(sp)
    80004f6c:	ec56                	sd	s5,24(sp)
    80004f6e:	e85a                	sd	s6,16(sp)
    80004f70:	0880                	addi	s0,sp,80
    80004f72:	8a2e                	mv	s4,a1
    80004f74:	8ab2                	mv	s5,a2
    80004f76:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004f78:	fb040593          	addi	a1,s0,-80
    80004f7c:	eb5fe0ef          	jal	80003e30 <nameiparent>
    80004f80:	84aa                	mv	s1,a0
    80004f82:	12050f63          	beqz	a0,800050c0 <create+0x160>
    return 0;

  ilock(dp);
    80004f86:	df6fe0ef          	jal	8000357c <ilock>

  if (dp->nlink == 0) {
    80004f8a:	04a49783          	lh	a5,74(s1)
    80004f8e:	cbb9                	beqz	a5,80004fe4 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004f90:	7761                	lui	a4,0xffff8
    80004f92:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd46e9>
    80004f94:	97ba                	add	a5,a5,a4
    80004f96:	e781                	bnez	a5,80004f9e <create+0x3e>
    80004f98:	fffa0793          	addi	a5,s4,-1
    80004f9c:	cba9                	beqz	a5,80004fee <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004f9e:	4601                	li	a2,0
    80004fa0:	fb040593          	addi	a1,s0,-80
    80004fa4:	8526                	mv	a0,s1
    80004fa6:	bbffe0ef          	jal	80003b64 <dirlookup>
    80004faa:	892a                	mv	s2,a0
    80004fac:	c939                	beqz	a0,80005002 <create+0xa2>
    iunlockput(dp);
    80004fae:	8526                	mv	a0,s1
    80004fb0:	821fe0ef          	jal	800037d0 <iunlockput>
    ilock(ip);
    80004fb4:	854a                	mv	a0,s2
    80004fb6:	dc6fe0ef          	jal	8000357c <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004fba:	4789                	li	a5,2
    80004fbc:	02fa1e63          	bne	s4,a5,80004ff8 <create+0x98>
    80004fc0:	04495783          	lhu	a5,68(s2)
    80004fc4:	37f9                	addiw	a5,a5,-2
    80004fc6:	17c2                	slli	a5,a5,0x30
    80004fc8:	93c1                	srli	a5,a5,0x30
    80004fca:	4705                	li	a4,1
    80004fcc:	02f76663          	bltu	a4,a5,80004ff8 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004fd0:	854a                	mv	a0,s2
    80004fd2:	60a6                	ld	ra,72(sp)
    80004fd4:	6406                	ld	s0,64(sp)
    80004fd6:	74e2                	ld	s1,56(sp)
    80004fd8:	7942                	ld	s2,48(sp)
    80004fda:	7a02                	ld	s4,32(sp)
    80004fdc:	6ae2                	ld	s5,24(sp)
    80004fde:	6b42                	ld	s6,16(sp)
    80004fe0:	6161                	addi	sp,sp,80
    80004fe2:	8082                	ret
    iunlockput(dp);
    80004fe4:	8526                	mv	a0,s1
    80004fe6:	feafe0ef          	jal	800037d0 <iunlockput>
    return 0;
    80004fea:	4901                	li	s2,0
    80004fec:	b7d5                	j	80004fd0 <create+0x70>
    iunlockput(dp);
    80004fee:	8526                	mv	a0,s1
    80004ff0:	fe0fe0ef          	jal	800037d0 <iunlockput>
    return 0;
    80004ff4:	4901                	li	s2,0
    80004ff6:	bfe9                	j	80004fd0 <create+0x70>
    iunlockput(ip);
    80004ff8:	854a                	mv	a0,s2
    80004ffa:	fd6fe0ef          	jal	800037d0 <iunlockput>
    return 0;
    80004ffe:	4901                	li	s2,0
    80005000:	bfc1                	j	80004fd0 <create+0x70>
    80005002:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80005004:	85d2                	mv	a1,s4
    80005006:	4088                	lw	a0,0(s1)
    80005008:	c04fe0ef          	jal	8000340c <ialloc>
    8000500c:	89aa                	mv	s3,a0
    8000500e:	cd1d                	beqz	a0,8000504c <create+0xec>
  ilock(ip);
    80005010:	d6cfe0ef          	jal	8000357c <ilock>
  ip->major = major;
    80005014:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80005018:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    8000501c:	4705                	li	a4,1
    8000501e:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80005022:	854e                	mv	a0,s3
    80005024:	ca4fe0ef          	jal	800034c8 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80005028:	4705                	li	a4,1
    8000502a:	02ea0763          	beq	s4,a4,80005058 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    8000502e:	0049a603          	lw	a2,4(s3)
    80005032:	fb040593          	addi	a1,s0,-80
    80005036:	8526                	mv	a0,s1
    80005038:	d35fe0ef          	jal	80003d6c <dirlink>
    8000503c:	06054563          	bltz	a0,800050a6 <create+0x146>
  iunlockput(dp);
    80005040:	8526                	mv	a0,s1
    80005042:	f8efe0ef          	jal	800037d0 <iunlockput>
  return ip;
    80005046:	894e                	mv	s2,s3
    80005048:	79a2                	ld	s3,40(sp)
    8000504a:	b759                	j	80004fd0 <create+0x70>
    iunlockput(dp);
    8000504c:	8526                	mv	a0,s1
    8000504e:	f82fe0ef          	jal	800037d0 <iunlockput>
    return 0;
    80005052:	894e                	mv	s2,s3
    80005054:	79a2                	ld	s3,40(sp)
    80005056:	bfad                	j	80004fd0 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005058:	0049a603          	lw	a2,4(s3)
    8000505c:	00002597          	auipc	a1,0x2
    80005060:	58458593          	addi	a1,a1,1412 # 800075e0 <etext+0x5e0>
    80005064:	854e                	mv	a0,s3
    80005066:	d07fe0ef          	jal	80003d6c <dirlink>
    8000506a:	02054e63          	bltz	a0,800050a6 <create+0x146>
    8000506e:	40d0                	lw	a2,4(s1)
    80005070:	00002597          	auipc	a1,0x2
    80005074:	57858593          	addi	a1,a1,1400 # 800075e8 <etext+0x5e8>
    80005078:	854e                	mv	a0,s3
    8000507a:	cf3fe0ef          	jal	80003d6c <dirlink>
    8000507e:	02054463          	bltz	a0,800050a6 <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80005082:	0049a603          	lw	a2,4(s3)
    80005086:	fb040593          	addi	a1,s0,-80
    8000508a:	8526                	mv	a0,s1
    8000508c:	ce1fe0ef          	jal	80003d6c <dirlink>
    80005090:	00054b63          	bltz	a0,800050a6 <create+0x146>
    dp->nlink++; // for ".."
    80005094:	04a4d783          	lhu	a5,74(s1)
    80005098:	2785                	addiw	a5,a5,1
    8000509a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000509e:	8526                	mv	a0,s1
    800050a0:	c28fe0ef          	jal	800034c8 <iupdate>
    800050a4:	bf71                	j	80005040 <create+0xe0>
  ip->nlink = 0;
    800050a6:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    800050aa:	854e                	mv	a0,s3
    800050ac:	c1cfe0ef          	jal	800034c8 <iupdate>
  iunlockput(ip);
    800050b0:	854e                	mv	a0,s3
    800050b2:	f1efe0ef          	jal	800037d0 <iunlockput>
  iunlockput(dp);
    800050b6:	8526                	mv	a0,s1
    800050b8:	f18fe0ef          	jal	800037d0 <iunlockput>
  return 0;
    800050bc:	79a2                	ld	s3,40(sp)
    800050be:	bf09                	j	80004fd0 <create+0x70>
    return 0;
    800050c0:	892a                	mv	s2,a0
    800050c2:	b739                	j	80004fd0 <create+0x70>

00000000800050c4 <sys_dup>:
{
    800050c4:	7179                	addi	sp,sp,-48
    800050c6:	f406                	sd	ra,40(sp)
    800050c8:	f022                	sd	s0,32(sp)
    800050ca:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    800050cc:	fd840613          	addi	a2,s0,-40
    800050d0:	4581                	li	a1,0
    800050d2:	4501                	li	a0,0
    800050d4:	df3ff0ef          	jal	80004ec6 <argfd>
    return -1;
    800050d8:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    800050da:	02054363          	bltz	a0,80005100 <sys_dup+0x3c>
    800050de:	ec26                	sd	s1,24(sp)
    800050e0:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    800050e2:	fd843483          	ld	s1,-40(s0)
    800050e6:	8526                	mv	a0,s1
    800050e8:	e39ff0ef          	jal	80004f20 <fdalloc>
    800050ec:	892a                	mv	s2,a0
    return -1;
    800050ee:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    800050f0:	00054d63          	bltz	a0,8000510a <sys_dup+0x46>
  filedup(f);
    800050f4:	8526                	mv	a0,s1
    800050f6:	b72ff0ef          	jal	80004468 <filedup>
  return fd;
    800050fa:	87ca                	mv	a5,s2
    800050fc:	64e2                	ld	s1,24(sp)
    800050fe:	6942                	ld	s2,16(sp)
}
    80005100:	853e                	mv	a0,a5
    80005102:	70a2                	ld	ra,40(sp)
    80005104:	7402                	ld	s0,32(sp)
    80005106:	6145                	addi	sp,sp,48
    80005108:	8082                	ret
    8000510a:	64e2                	ld	s1,24(sp)
    8000510c:	6942                	ld	s2,16(sp)
    8000510e:	bfcd                	j	80005100 <sys_dup+0x3c>

0000000080005110 <sys_read>:
{
    80005110:	7179                	addi	sp,sp,-48
    80005112:	f406                	sd	ra,40(sp)
    80005114:	f022                	sd	s0,32(sp)
    80005116:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005118:	fd840593          	addi	a1,s0,-40
    8000511c:	4505                	li	a0,1
    8000511e:	a4ffd0ef          	jal	80002b6c <argaddr>
  argint(2, &n);
    80005122:	fe440593          	addi	a1,s0,-28
    80005126:	4509                	li	a0,2
    80005128:	a29fd0ef          	jal	80002b50 <argint>
  if (argfd(0, 0, &f) < 0)
    8000512c:	fe840613          	addi	a2,s0,-24
    80005130:	4581                	li	a1,0
    80005132:	4501                	li	a0,0
    80005134:	d93ff0ef          	jal	80004ec6 <argfd>
    80005138:	87aa                	mv	a5,a0
    return -1;
    8000513a:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    8000513c:	0007ca63          	bltz	a5,80005150 <sys_read+0x40>
  return fileread(f, p, n);
    80005140:	fe442603          	lw	a2,-28(s0)
    80005144:	fd843583          	ld	a1,-40(s0)
    80005148:	fe843503          	ld	a0,-24(s0)
    8000514c:	c94ff0ef          	jal	800045e0 <fileread>
}
    80005150:	70a2                	ld	ra,40(sp)
    80005152:	7402                	ld	s0,32(sp)
    80005154:	6145                	addi	sp,sp,48
    80005156:	8082                	ret

0000000080005158 <sys_write>:
{
    80005158:	7179                	addi	sp,sp,-48
    8000515a:	f406                	sd	ra,40(sp)
    8000515c:	f022                	sd	s0,32(sp)
    8000515e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005160:	fd840593          	addi	a1,s0,-40
    80005164:	4505                	li	a0,1
    80005166:	a07fd0ef          	jal	80002b6c <argaddr>
  argint(2, &n);
    8000516a:	fe440593          	addi	a1,s0,-28
    8000516e:	4509                	li	a0,2
    80005170:	9e1fd0ef          	jal	80002b50 <argint>
  if (argfd(0, 0, &f) < 0)
    80005174:	fe840613          	addi	a2,s0,-24
    80005178:	4581                	li	a1,0
    8000517a:	4501                	li	a0,0
    8000517c:	d4bff0ef          	jal	80004ec6 <argfd>
    80005180:	87aa                	mv	a5,a0
    return -1;
    80005182:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005184:	0007ca63          	bltz	a5,80005198 <sys_write+0x40>
  return filewrite(f, p, n);
    80005188:	fe442603          	lw	a2,-28(s0)
    8000518c:	fd843583          	ld	a1,-40(s0)
    80005190:	fe843503          	ld	a0,-24(s0)
    80005194:	d1aff0ef          	jal	800046ae <filewrite>
}
    80005198:	70a2                	ld	ra,40(sp)
    8000519a:	7402                	ld	s0,32(sp)
    8000519c:	6145                	addi	sp,sp,48
    8000519e:	8082                	ret

00000000800051a0 <sys_close>:
{
    800051a0:	1101                	addi	sp,sp,-32
    800051a2:	ec06                	sd	ra,24(sp)
    800051a4:	e822                	sd	s0,16(sp)
    800051a6:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    800051a8:	fe040613          	addi	a2,s0,-32
    800051ac:	fec40593          	addi	a1,s0,-20
    800051b0:	4501                	li	a0,0
    800051b2:	d15ff0ef          	jal	80004ec6 <argfd>
    return -1;
    800051b6:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    800051b8:	02054163          	bltz	a0,800051da <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    800051bc:	f8cfc0ef          	jal	80001948 <myproc>
    800051c0:	fec42783          	lw	a5,-20(s0)
    800051c4:	078e                	slli	a5,a5,0x3
    800051c6:	0d078793          	addi	a5,a5,208
    800051ca:	953e                	add	a0,a0,a5
    800051cc:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800051d0:	fe043503          	ld	a0,-32(s0)
    800051d4:	adaff0ef          	jal	800044ae <fileclose>
  return 0;
    800051d8:	4781                	li	a5,0
}
    800051da:	853e                	mv	a0,a5
    800051dc:	60e2                	ld	ra,24(sp)
    800051de:	6442                	ld	s0,16(sp)
    800051e0:	6105                	addi	sp,sp,32
    800051e2:	8082                	ret

00000000800051e4 <sys_fstat>:
{
    800051e4:	1101                	addi	sp,sp,-32
    800051e6:	ec06                	sd	ra,24(sp)
    800051e8:	e822                	sd	s0,16(sp)
    800051ea:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800051ec:	fe040593          	addi	a1,s0,-32
    800051f0:	4505                	li	a0,1
    800051f2:	97bfd0ef          	jal	80002b6c <argaddr>
  if (argfd(0, 0, &f) < 0)
    800051f6:	fe840613          	addi	a2,s0,-24
    800051fa:	4581                	li	a1,0
    800051fc:	4501                	li	a0,0
    800051fe:	cc9ff0ef          	jal	80004ec6 <argfd>
    80005202:	87aa                	mv	a5,a0
    return -1;
    80005204:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005206:	0007c863          	bltz	a5,80005216 <sys_fstat+0x32>
  return filestat(f, st);
    8000520a:	fe043583          	ld	a1,-32(s0)
    8000520e:	fe843503          	ld	a0,-24(s0)
    80005212:	b5eff0ef          	jal	80004570 <filestat>
}
    80005216:	60e2                	ld	ra,24(sp)
    80005218:	6442                	ld	s0,16(sp)
    8000521a:	6105                	addi	sp,sp,32
    8000521c:	8082                	ret

000000008000521e <sys_link>:
{
    8000521e:	7169                	addi	sp,sp,-304
    80005220:	f606                	sd	ra,296(sp)
    80005222:	f222                	sd	s0,288(sp)
    80005224:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005226:	08000613          	li	a2,128
    8000522a:	ed040593          	addi	a1,s0,-304
    8000522e:	4501                	li	a0,0
    80005230:	959fd0ef          	jal	80002b88 <argstr>
    return -1;
    80005234:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005236:	10054163          	bltz	a0,80005338 <sys_link+0x11a>
    8000523a:	08000613          	li	a2,128
    8000523e:	f5040593          	addi	a1,s0,-176
    80005242:	4505                	li	a0,1
    80005244:	945fd0ef          	jal	80002b88 <argstr>
    return -1;
    80005248:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000524a:	0e054763          	bltz	a0,80005338 <sys_link+0x11a>
    8000524e:	ee26                	sd	s1,280(sp)
  begin_op();
    80005250:	da5fe0ef          	jal	80003ff4 <begin_op>
  if ((ip = namei(old)) == 0) {
    80005254:	ed040513          	addi	a0,s0,-304
    80005258:	bbffe0ef          	jal	80003e16 <namei>
    8000525c:	84aa                	mv	s1,a0
    8000525e:	cd35                	beqz	a0,800052da <sys_link+0xbc>
  ilock(ip);
    80005260:	b1cfe0ef          	jal	8000357c <ilock>
  if (ip->type == T_DIR) {
    80005264:	04449703          	lh	a4,68(s1)
    80005268:	4785                	li	a5,1
    8000526a:	06f70d63          	beq	a4,a5,800052e4 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    8000526e:	04a49783          	lh	a5,74(s1)
    80005272:	6721                	lui	a4,0x8
    80005274:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80005276:	06e78f63          	beq	a5,a4,800052f4 <sys_link+0xd6>
    8000527a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000527c:	2785                	addiw	a5,a5,1
    8000527e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005282:	8526                	mv	a0,s1
    80005284:	a44fe0ef          	jal	800034c8 <iupdate>
  iunlock(ip);
    80005288:	8526                	mv	a0,s1
    8000528a:	ba0fe0ef          	jal	8000362a <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    8000528e:	fd040593          	addi	a1,s0,-48
    80005292:	f5040513          	addi	a0,s0,-176
    80005296:	b9bfe0ef          	jal	80003e30 <nameiparent>
    8000529a:	892a                	mv	s2,a0
    8000529c:	c93d                	beqz	a0,80005312 <sys_link+0xf4>
  ilock(dp);
    8000529e:	adefe0ef          	jal	8000357c <ilock>
  if (dp->nlink == 0) {
    800052a2:	04a91783          	lh	a5,74(s2)
    800052a6:	cfb9                	beqz	a5,80005304 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    800052a8:	854a                	mv	a0,s2
    800052aa:	00092703          	lw	a4,0(s2)
    800052ae:	409c                	lw	a5,0(s1)
    800052b0:	04f71e63          	bne	a4,a5,8000530c <sys_link+0xee>
    800052b4:	40d0                	lw	a2,4(s1)
    800052b6:	fd040593          	addi	a1,s0,-48
    800052ba:	ab3fe0ef          	jal	80003d6c <dirlink>
    800052be:	04054763          	bltz	a0,8000530c <sys_link+0xee>
  iunlockput(dp);
    800052c2:	854a                	mv	a0,s2
    800052c4:	d0cfe0ef          	jal	800037d0 <iunlockput>
  iput(ip);
    800052c8:	8526                	mv	a0,s1
    800052ca:	c34fe0ef          	jal	800036fe <iput>
  end_op();
    800052ce:	db3fe0ef          	jal	80004080 <end_op>
  return 0;
    800052d2:	4781                	li	a5,0
    800052d4:	64f2                	ld	s1,280(sp)
    800052d6:	6952                	ld	s2,272(sp)
    800052d8:	a085                	j	80005338 <sys_link+0x11a>
    end_op();
    800052da:	da7fe0ef          	jal	80004080 <end_op>
    return -1;
    800052de:	57fd                	li	a5,-1
    800052e0:	64f2                	ld	s1,280(sp)
    800052e2:	a899                	j	80005338 <sys_link+0x11a>
    iunlockput(ip);
    800052e4:	8526                	mv	a0,s1
    800052e6:	ceafe0ef          	jal	800037d0 <iunlockput>
    end_op();
    800052ea:	d97fe0ef          	jal	80004080 <end_op>
    return -1;
    800052ee:	57fd                	li	a5,-1
    800052f0:	64f2                	ld	s1,280(sp)
    800052f2:	a099                	j	80005338 <sys_link+0x11a>
    iunlockput(ip);
    800052f4:	8526                	mv	a0,s1
    800052f6:	cdafe0ef          	jal	800037d0 <iunlockput>
    end_op();
    800052fa:	d87fe0ef          	jal	80004080 <end_op>
    return -1;
    800052fe:	57fd                	li	a5,-1
    80005300:	64f2                	ld	s1,280(sp)
    80005302:	a81d                	j	80005338 <sys_link+0x11a>
    iunlockput(dp);
    80005304:	854a                	mv	a0,s2
    80005306:	ccafe0ef          	jal	800037d0 <iunlockput>
    goto bad;
    8000530a:	a021                	j	80005312 <sys_link+0xf4>
    iunlockput(dp);
    8000530c:	854a                	mv	a0,s2
    8000530e:	cc2fe0ef          	jal	800037d0 <iunlockput>
  ilock(ip);
    80005312:	8526                	mv	a0,s1
    80005314:	a68fe0ef          	jal	8000357c <ilock>
  ip->nlink--;
    80005318:	04a4d783          	lhu	a5,74(s1)
    8000531c:	37fd                	addiw	a5,a5,-1
    8000531e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005322:	8526                	mv	a0,s1
    80005324:	9a4fe0ef          	jal	800034c8 <iupdate>
  iunlockput(ip);
    80005328:	8526                	mv	a0,s1
    8000532a:	ca6fe0ef          	jal	800037d0 <iunlockput>
  end_op();
    8000532e:	d53fe0ef          	jal	80004080 <end_op>
  return -1;
    80005332:	57fd                	li	a5,-1
    80005334:	64f2                	ld	s1,280(sp)
    80005336:	6952                	ld	s2,272(sp)
}
    80005338:	853e                	mv	a0,a5
    8000533a:	70b2                	ld	ra,296(sp)
    8000533c:	7412                	ld	s0,288(sp)
    8000533e:	6155                	addi	sp,sp,304
    80005340:	8082                	ret

0000000080005342 <sys_unlink>:
{
    80005342:	7151                	addi	sp,sp,-240
    80005344:	f586                	sd	ra,232(sp)
    80005346:	f1a2                	sd	s0,224(sp)
    80005348:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    8000534a:	08000613          	li	a2,128
    8000534e:	f3040593          	addi	a1,s0,-208
    80005352:	4501                	li	a0,0
    80005354:	835fd0ef          	jal	80002b88 <argstr>
    80005358:	14054d63          	bltz	a0,800054b2 <sys_unlink+0x170>
    8000535c:	eda6                	sd	s1,216(sp)
  begin_op();
    8000535e:	c97fe0ef          	jal	80003ff4 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80005362:	fb040593          	addi	a1,s0,-80
    80005366:	f3040513          	addi	a0,s0,-208
    8000536a:	ac7fe0ef          	jal	80003e30 <nameiparent>
    8000536e:	84aa                	mv	s1,a0
    80005370:	c955                	beqz	a0,80005424 <sys_unlink+0xe2>
  ilock(dp);
    80005372:	a0afe0ef          	jal	8000357c <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005376:	00002597          	auipc	a1,0x2
    8000537a:	26a58593          	addi	a1,a1,618 # 800075e0 <etext+0x5e0>
    8000537e:	fb040513          	addi	a0,s0,-80
    80005382:	fccfe0ef          	jal	80003b4e <namecmp>
    80005386:	10050b63          	beqz	a0,8000549c <sys_unlink+0x15a>
    8000538a:	00002597          	auipc	a1,0x2
    8000538e:	25e58593          	addi	a1,a1,606 # 800075e8 <etext+0x5e8>
    80005392:	fb040513          	addi	a0,s0,-80
    80005396:	fb8fe0ef          	jal	80003b4e <namecmp>
    8000539a:	10050163          	beqz	a0,8000549c <sys_unlink+0x15a>
    8000539e:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    800053a0:	f2c40613          	addi	a2,s0,-212
    800053a4:	fb040593          	addi	a1,s0,-80
    800053a8:	8526                	mv	a0,s1
    800053aa:	fbafe0ef          	jal	80003b64 <dirlookup>
    800053ae:	892a                	mv	s2,a0
    800053b0:	0e050563          	beqz	a0,8000549a <sys_unlink+0x158>
    800053b4:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800053b6:	9c6fe0ef          	jal	8000357c <ilock>
  if (ip->nlink < 1)
    800053ba:	04a91783          	lh	a5,74(s2)
    800053be:	06f05863          	blez	a5,8000542e <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    800053c2:	04491703          	lh	a4,68(s2)
    800053c6:	4785                	li	a5,1
    800053c8:	06f70963          	beq	a4,a5,8000543a <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    800053cc:	fc040993          	addi	s3,s0,-64
    800053d0:	4641                	li	a2,16
    800053d2:	4581                	li	a1,0
    800053d4:	854e                	mv	a0,s3
    800053d6:	913fb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800053da:	4741                	li	a4,16
    800053dc:	f2c42683          	lw	a3,-212(s0)
    800053e0:	864e                	mv	a2,s3
    800053e2:	4581                	li	a1,0
    800053e4:	8526                	mv	a0,s1
    800053e6:	e62fe0ef          	jal	80003a48 <writei>
    800053ea:	47c1                	li	a5,16
    800053ec:	08f51863          	bne	a0,a5,8000547c <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    800053f0:	04491703          	lh	a4,68(s2)
    800053f4:	4785                	li	a5,1
    800053f6:	08f70963          	beq	a4,a5,80005488 <sys_unlink+0x146>
  iunlockput(dp);
    800053fa:	8526                	mv	a0,s1
    800053fc:	bd4fe0ef          	jal	800037d0 <iunlockput>
  ip->nlink--;
    80005400:	04a95783          	lhu	a5,74(s2)
    80005404:	37fd                	addiw	a5,a5,-1
    80005406:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000540a:	854a                	mv	a0,s2
    8000540c:	8bcfe0ef          	jal	800034c8 <iupdate>
  iunlockput(ip);
    80005410:	854a                	mv	a0,s2
    80005412:	bbefe0ef          	jal	800037d0 <iunlockput>
  end_op();
    80005416:	c6bfe0ef          	jal	80004080 <end_op>
  return 0;
    8000541a:	4501                	li	a0,0
    8000541c:	64ee                	ld	s1,216(sp)
    8000541e:	694e                	ld	s2,208(sp)
    80005420:	69ae                	ld	s3,200(sp)
    80005422:	a061                	j	800054aa <sys_unlink+0x168>
    end_op();
    80005424:	c5dfe0ef          	jal	80004080 <end_op>
    return -1;
    80005428:	557d                	li	a0,-1
    8000542a:	64ee                	ld	s1,216(sp)
    8000542c:	a8bd                	j	800054aa <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    8000542e:	00002517          	auipc	a0,0x2
    80005432:	1c250513          	addi	a0,a0,450 # 800075f0 <etext+0x5f0>
    80005436:	bfefb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000543a:	04c92703          	lw	a4,76(s2)
    8000543e:	02000793          	li	a5,32
    80005442:	f8e7f5e3          	bgeu	a5,a4,800053cc <sys_unlink+0x8a>
    80005446:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005448:	4741                	li	a4,16
    8000544a:	86ce                	mv	a3,s3
    8000544c:	f1840613          	addi	a2,s0,-232
    80005450:	4581                	li	a1,0
    80005452:	854a                	mv	a0,s2
    80005454:	d02fe0ef          	jal	80003956 <readi>
    80005458:	47c1                	li	a5,16
    8000545a:	00f51b63          	bne	a0,a5,80005470 <sys_unlink+0x12e>
    if (de.inum != 0)
    8000545e:	f1845783          	lhu	a5,-232(s0)
    80005462:	ebb1                	bnez	a5,800054b6 <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005464:	29c1                	addiw	s3,s3,16
    80005466:	04c92783          	lw	a5,76(s2)
    8000546a:	fcf9efe3          	bltu	s3,a5,80005448 <sys_unlink+0x106>
    8000546e:	bfb9                	j	800053cc <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005470:	00002517          	auipc	a0,0x2
    80005474:	19850513          	addi	a0,a0,408 # 80007608 <etext+0x608>
    80005478:	bbcfb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    8000547c:	00002517          	auipc	a0,0x2
    80005480:	1a450513          	addi	a0,a0,420 # 80007620 <etext+0x620>
    80005484:	bb0fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    80005488:	04a4d783          	lhu	a5,74(s1)
    8000548c:	37fd                	addiw	a5,a5,-1
    8000548e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005492:	8526                	mv	a0,s1
    80005494:	834fe0ef          	jal	800034c8 <iupdate>
    80005498:	b78d                	j	800053fa <sys_unlink+0xb8>
    8000549a:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000549c:	8526                	mv	a0,s1
    8000549e:	b32fe0ef          	jal	800037d0 <iunlockput>
  end_op();
    800054a2:	bdffe0ef          	jal	80004080 <end_op>
  return -1;
    800054a6:	557d                	li	a0,-1
    800054a8:	64ee                	ld	s1,216(sp)
}
    800054aa:	70ae                	ld	ra,232(sp)
    800054ac:	740e                	ld	s0,224(sp)
    800054ae:	616d                	addi	sp,sp,240
    800054b0:	8082                	ret
    return -1;
    800054b2:	557d                	li	a0,-1
    800054b4:	bfdd                	j	800054aa <sys_unlink+0x168>
    iunlockput(ip);
    800054b6:	854a                	mv	a0,s2
    800054b8:	b18fe0ef          	jal	800037d0 <iunlockput>
    goto bad;
    800054bc:	694e                	ld	s2,208(sp)
    800054be:	69ae                	ld	s3,200(sp)
    800054c0:	bff1                	j	8000549c <sys_unlink+0x15a>

00000000800054c2 <sys_open>:

uint64
sys_open(void)
{
    800054c2:	7131                	addi	sp,sp,-192
    800054c4:	fd06                	sd	ra,184(sp)
    800054c6:	f922                	sd	s0,176(sp)
    800054c8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800054ca:	f4c40593          	addi	a1,s0,-180
    800054ce:	4505                	li	a0,1
    800054d0:	e80fd0ef          	jal	80002b50 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800054d4:	08000613          	li	a2,128
    800054d8:	f5040593          	addi	a1,s0,-176
    800054dc:	4501                	li	a0,0
    800054de:	eaafd0ef          	jal	80002b88 <argstr>
    800054e2:	87aa                	mv	a5,a0
    return -1;
    800054e4:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800054e6:	0a07c363          	bltz	a5,8000558c <sys_open+0xca>
    800054ea:	f526                	sd	s1,168(sp)

  begin_op();
    800054ec:	b09fe0ef          	jal	80003ff4 <begin_op>

  if (omode & O_CREATE) {
    800054f0:	f4c42783          	lw	a5,-180(s0)
    800054f4:	2007f793          	andi	a5,a5,512
    800054f8:	c3dd                	beqz	a5,8000559e <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800054fa:	4681                	li	a3,0
    800054fc:	4601                	li	a2,0
    800054fe:	4589                	li	a1,2
    80005500:	f5040513          	addi	a0,s0,-176
    80005504:	a5dff0ef          	jal	80004f60 <create>
    80005508:	84aa                	mv	s1,a0
    if (ip == 0) {
    8000550a:	c549                	beqz	a0,80005594 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    8000550c:	04449703          	lh	a4,68(s1)
    80005510:	478d                	li	a5,3
    80005512:	00f71763          	bne	a4,a5,80005520 <sys_open+0x5e>
    80005516:	0464d703          	lhu	a4,70(s1)
    8000551a:	47a5                	li	a5,9
    8000551c:	0ae7ee63          	bltu	a5,a4,800055d8 <sys_open+0x116>
    80005520:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    80005522:	ee9fe0ef          	jal	8000440a <filealloc>
    80005526:	892a                	mv	s2,a0
    80005528:	c561                	beqz	a0,800055f0 <sys_open+0x12e>
    8000552a:	ed4e                	sd	s3,152(sp)
    8000552c:	9f5ff0ef          	jal	80004f20 <fdalloc>
    80005530:	89aa                	mv	s3,a0
    80005532:	0a054b63          	bltz	a0,800055e8 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    80005536:	04449703          	lh	a4,68(s1)
    8000553a:	478d                	li	a5,3
    8000553c:	0cf70363          	beq	a4,a5,80005602 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005540:	4789                	li	a5,2
    80005542:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005546:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000554a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000554e:	f4c42783          	lw	a5,-180(s0)
    80005552:	0017f713          	andi	a4,a5,1
    80005556:	00174713          	xori	a4,a4,1
    8000555a:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000555e:	0037f713          	andi	a4,a5,3
    80005562:	00e03733          	snez	a4,a4
    80005566:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    8000556a:	4007f793          	andi	a5,a5,1024
    8000556e:	c791                	beqz	a5,8000557a <sys_open+0xb8>
    80005570:	04449703          	lh	a4,68(s1)
    80005574:	4789                	li	a5,2
    80005576:	08f70d63          	beq	a4,a5,80005610 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    8000557a:	8526                	mv	a0,s1
    8000557c:	8aefe0ef          	jal	8000362a <iunlock>
  end_op();
    80005580:	b01fe0ef          	jal	80004080 <end_op>

  return fd;
    80005584:	854e                	mv	a0,s3
    80005586:	74aa                	ld	s1,168(sp)
    80005588:	790a                	ld	s2,160(sp)
    8000558a:	69ea                	ld	s3,152(sp)
}
    8000558c:	70ea                	ld	ra,184(sp)
    8000558e:	744a                	ld	s0,176(sp)
    80005590:	6129                	addi	sp,sp,192
    80005592:	8082                	ret
      end_op();
    80005594:	aedfe0ef          	jal	80004080 <end_op>
      return -1;
    80005598:	557d                	li	a0,-1
    8000559a:	74aa                	ld	s1,168(sp)
    8000559c:	bfc5                	j	8000558c <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    8000559e:	f5040513          	addi	a0,s0,-176
    800055a2:	875fe0ef          	jal	80003e16 <namei>
    800055a6:	84aa                	mv	s1,a0
    800055a8:	c11d                	beqz	a0,800055ce <sys_open+0x10c>
    ilock(ip);
    800055aa:	fd3fd0ef          	jal	8000357c <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    800055ae:	04449703          	lh	a4,68(s1)
    800055b2:	4785                	li	a5,1
    800055b4:	f4f71ce3          	bne	a4,a5,8000550c <sys_open+0x4a>
    800055b8:	f4c42783          	lw	a5,-180(s0)
    800055bc:	d3b5                	beqz	a5,80005520 <sys_open+0x5e>
      iunlockput(ip);
    800055be:	8526                	mv	a0,s1
    800055c0:	a10fe0ef          	jal	800037d0 <iunlockput>
      end_op();
    800055c4:	abdfe0ef          	jal	80004080 <end_op>
      return -1;
    800055c8:	557d                	li	a0,-1
    800055ca:	74aa                	ld	s1,168(sp)
    800055cc:	b7c1                	j	8000558c <sys_open+0xca>
      end_op();
    800055ce:	ab3fe0ef          	jal	80004080 <end_op>
      return -1;
    800055d2:	557d                	li	a0,-1
    800055d4:	74aa                	ld	s1,168(sp)
    800055d6:	bf5d                	j	8000558c <sys_open+0xca>
    iunlockput(ip);
    800055d8:	8526                	mv	a0,s1
    800055da:	9f6fe0ef          	jal	800037d0 <iunlockput>
    end_op();
    800055de:	aa3fe0ef          	jal	80004080 <end_op>
    return -1;
    800055e2:	557d                	li	a0,-1
    800055e4:	74aa                	ld	s1,168(sp)
    800055e6:	b75d                	j	8000558c <sys_open+0xca>
      fileclose(f);
    800055e8:	854a                	mv	a0,s2
    800055ea:	ec5fe0ef          	jal	800044ae <fileclose>
    800055ee:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800055f0:	8526                	mv	a0,s1
    800055f2:	9defe0ef          	jal	800037d0 <iunlockput>
    end_op();
    800055f6:	a8bfe0ef          	jal	80004080 <end_op>
    return -1;
    800055fa:	557d                	li	a0,-1
    800055fc:	74aa                	ld	s1,168(sp)
    800055fe:	790a                	ld	s2,160(sp)
    80005600:	b771                	j	8000558c <sys_open+0xca>
    f->type = FD_DEVICE;
    80005602:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005606:	04649783          	lh	a5,70(s1)
    8000560a:	02f91223          	sh	a5,36(s2)
    8000560e:	bf35                	j	8000554a <sys_open+0x88>
    itrunc(ip);
    80005610:	8526                	mv	a0,s1
    80005612:	858fe0ef          	jal	8000366a <itrunc>
    80005616:	b795                	j	8000557a <sys_open+0xb8>

0000000080005618 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005618:	7175                	addi	sp,sp,-144
    8000561a:	e506                	sd	ra,136(sp)
    8000561c:	e122                	sd	s0,128(sp)
    8000561e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005620:	9d5fe0ef          	jal	80003ff4 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    80005624:	08000613          	li	a2,128
    80005628:	f7040593          	addi	a1,s0,-144
    8000562c:	4501                	li	a0,0
    8000562e:	d5afd0ef          	jal	80002b88 <argstr>
    80005632:	02054363          	bltz	a0,80005658 <sys_mkdir+0x40>
    80005636:	4681                	li	a3,0
    80005638:	4601                	li	a2,0
    8000563a:	4585                	li	a1,1
    8000563c:	f7040513          	addi	a0,s0,-144
    80005640:	921ff0ef          	jal	80004f60 <create>
    80005644:	c911                	beqz	a0,80005658 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005646:	98afe0ef          	jal	800037d0 <iunlockput>
  end_op();
    8000564a:	a37fe0ef          	jal	80004080 <end_op>
  return 0;
    8000564e:	4501                	li	a0,0
}
    80005650:	60aa                	ld	ra,136(sp)
    80005652:	640a                	ld	s0,128(sp)
    80005654:	6149                	addi	sp,sp,144
    80005656:	8082                	ret
    end_op();
    80005658:	a29fe0ef          	jal	80004080 <end_op>
    return -1;
    8000565c:	557d                	li	a0,-1
    8000565e:	bfcd                	j	80005650 <sys_mkdir+0x38>

0000000080005660 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005660:	7135                	addi	sp,sp,-160
    80005662:	ed06                	sd	ra,152(sp)
    80005664:	e922                	sd	s0,144(sp)
    80005666:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005668:	98dfe0ef          	jal	80003ff4 <begin_op>
  argint(1, &major);
    8000566c:	f6c40593          	addi	a1,s0,-148
    80005670:	4505                	li	a0,1
    80005672:	cdefd0ef          	jal	80002b50 <argint>
  argint(2, &minor);
    80005676:	f6840593          	addi	a1,s0,-152
    8000567a:	4509                	li	a0,2
    8000567c:	cd4fd0ef          	jal	80002b50 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005680:	08000613          	li	a2,128
    80005684:	f7040593          	addi	a1,s0,-144
    80005688:	4501                	li	a0,0
    8000568a:	cfefd0ef          	jal	80002b88 <argstr>
    8000568e:	02054563          	bltz	a0,800056b8 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005692:	f6841683          	lh	a3,-152(s0)
    80005696:	f6c41603          	lh	a2,-148(s0)
    8000569a:	458d                	li	a1,3
    8000569c:	f7040513          	addi	a0,s0,-144
    800056a0:	8c1ff0ef          	jal	80004f60 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800056a4:	c911                	beqz	a0,800056b8 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800056a6:	92afe0ef          	jal	800037d0 <iunlockput>
  end_op();
    800056aa:	9d7fe0ef          	jal	80004080 <end_op>
  return 0;
    800056ae:	4501                	li	a0,0
}
    800056b0:	60ea                	ld	ra,152(sp)
    800056b2:	644a                	ld	s0,144(sp)
    800056b4:	610d                	addi	sp,sp,160
    800056b6:	8082                	ret
    end_op();
    800056b8:	9c9fe0ef          	jal	80004080 <end_op>
    return -1;
    800056bc:	557d                	li	a0,-1
    800056be:	bfcd                	j	800056b0 <sys_mknod+0x50>

00000000800056c0 <sys_chdir>:

uint64
sys_chdir(void)
{
    800056c0:	7135                	addi	sp,sp,-160
    800056c2:	ed06                	sd	ra,152(sp)
    800056c4:	e922                	sd	s0,144(sp)
    800056c6:	e14a                	sd	s2,128(sp)
    800056c8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800056ca:	a7efc0ef          	jal	80001948 <myproc>
    800056ce:	892a                	mv	s2,a0

  begin_op();
    800056d0:	925fe0ef          	jal	80003ff4 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    800056d4:	08000613          	li	a2,128
    800056d8:	f6040593          	addi	a1,s0,-160
    800056dc:	4501                	li	a0,0
    800056de:	caafd0ef          	jal	80002b88 <argstr>
    800056e2:	04054363          	bltz	a0,80005728 <sys_chdir+0x68>
    800056e6:	e526                	sd	s1,136(sp)
    800056e8:	f6040513          	addi	a0,s0,-160
    800056ec:	f2afe0ef          	jal	80003e16 <namei>
    800056f0:	84aa                	mv	s1,a0
    800056f2:	c915                	beqz	a0,80005726 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800056f4:	e89fd0ef          	jal	8000357c <ilock>
  if (ip->type != T_DIR) {
    800056f8:	04449703          	lh	a4,68(s1)
    800056fc:	4785                	li	a5,1
    800056fe:	02f71963          	bne	a4,a5,80005730 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005702:	8526                	mv	a0,s1
    80005704:	f27fd0ef          	jal	8000362a <iunlock>
  iput(p->cwd);
    80005708:	15093503          	ld	a0,336(s2)
    8000570c:	ff3fd0ef          	jal	800036fe <iput>
  end_op();
    80005710:	971fe0ef          	jal	80004080 <end_op>
  p->cwd = ip;
    80005714:	14993823          	sd	s1,336(s2)
  return 0;
    80005718:	4501                	li	a0,0
    8000571a:	64aa                	ld	s1,136(sp)
}
    8000571c:	60ea                	ld	ra,152(sp)
    8000571e:	644a                	ld	s0,144(sp)
    80005720:	690a                	ld	s2,128(sp)
    80005722:	610d                	addi	sp,sp,160
    80005724:	8082                	ret
    80005726:	64aa                	ld	s1,136(sp)
    end_op();
    80005728:	959fe0ef          	jal	80004080 <end_op>
    return -1;
    8000572c:	557d                	li	a0,-1
    8000572e:	b7fd                	j	8000571c <sys_chdir+0x5c>
    iunlockput(ip);
    80005730:	8526                	mv	a0,s1
    80005732:	89efe0ef          	jal	800037d0 <iunlockput>
    end_op();
    80005736:	94bfe0ef          	jal	80004080 <end_op>
    return -1;
    8000573a:	557d                	li	a0,-1
    8000573c:	64aa                	ld	s1,136(sp)
    8000573e:	bff9                	j	8000571c <sys_chdir+0x5c>

0000000080005740 <sys_exec>:

uint64
sys_exec(void)
{
    80005740:	7105                	addi	sp,sp,-480
    80005742:	ef86                	sd	ra,472(sp)
    80005744:	eba2                	sd	s0,464(sp)
    80005746:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005748:	e2840593          	addi	a1,s0,-472
    8000574c:	4505                	li	a0,1
    8000574e:	c1efd0ef          	jal	80002b6c <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    80005752:	08000613          	li	a2,128
    80005756:	f3040593          	addi	a1,s0,-208
    8000575a:	4501                	li	a0,0
    8000575c:	c2cfd0ef          	jal	80002b88 <argstr>
    80005760:	87aa                	mv	a5,a0
    return -1;
    80005762:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005764:	0e07c063          	bltz	a5,80005844 <sys_exec+0x104>
    80005768:	e7a6                	sd	s1,456(sp)
    8000576a:	e3ca                	sd	s2,448(sp)
    8000576c:	ff4e                	sd	s3,440(sp)
    8000576e:	fb52                	sd	s4,432(sp)
    80005770:	f756                	sd	s5,424(sp)
    80005772:	f35a                	sd	s6,416(sp)
    80005774:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005776:	e3040a13          	addi	s4,s0,-464
    8000577a:	10000613          	li	a2,256
    8000577e:	4581                	li	a1,0
    80005780:	8552                	mv	a0,s4
    80005782:	d66fb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    80005786:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005788:	89d2                	mv	s3,s4
    8000578a:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000578c:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005790:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    80005792:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005796:	00391513          	slli	a0,s2,0x3
    8000579a:	85d6                	mv	a1,s5
    8000579c:	e2843783          	ld	a5,-472(s0)
    800057a0:	953e                	add	a0,a0,a5
    800057a2:	b22fd0ef          	jal	80002ac4 <fetchaddr>
    800057a6:	02054663          	bltz	a0,800057d2 <sys_exec+0x92>
    if (uarg == 0) {
    800057aa:	e2043783          	ld	a5,-480(s0)
    800057ae:	c7a1                	beqz	a5,800057f6 <sys_exec+0xb6>
    argv[i] = kalloc();
    800057b0:	b9efb0ef          	jal	80000b4e <kalloc>
    800057b4:	85aa                	mv	a1,a0
    800057b6:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    800057ba:	cd01                	beqz	a0,800057d2 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800057bc:	865a                	mv	a2,s6
    800057be:	e2043503          	ld	a0,-480(s0)
    800057c2:	b4cfd0ef          	jal	80002b0e <fetchstr>
    800057c6:	00054663          	bltz	a0,800057d2 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    800057ca:	0905                	addi	s2,s2,1
    800057cc:	09a1                	addi	s3,s3,8
    800057ce:	fd7914e3          	bne	s2,s7,80005796 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800057d2:	100a0a13          	addi	s4,s4,256
    800057d6:	6088                	ld	a0,0(s1)
    800057d8:	cd31                	beqz	a0,80005834 <sys_exec+0xf4>
    kfree(argv[i]);
    800057da:	a8cfb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800057de:	04a1                	addi	s1,s1,8
    800057e0:	ff449be3          	bne	s1,s4,800057d6 <sys_exec+0x96>
  return -1;
    800057e4:	557d                	li	a0,-1
    800057e6:	64be                	ld	s1,456(sp)
    800057e8:	691e                	ld	s2,448(sp)
    800057ea:	79fa                	ld	s3,440(sp)
    800057ec:	7a5a                	ld	s4,432(sp)
    800057ee:	7aba                	ld	s5,424(sp)
    800057f0:	7b1a                	ld	s6,416(sp)
    800057f2:	6bfa                	ld	s7,408(sp)
    800057f4:	a881                	j	80005844 <sys_exec+0x104>
      argv[i] = 0;
    800057f6:	0009079b          	sext.w	a5,s2
    800057fa:	e3040593          	addi	a1,s0,-464
    800057fe:	078e                	slli	a5,a5,0x3
    80005800:	97ae                	add	a5,a5,a1
    80005802:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005806:	f3040513          	addi	a0,s0,-208
    8000580a:	b62ff0ef          	jal	80004b6c <kexec>
    8000580e:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005810:	100a0a13          	addi	s4,s4,256
    80005814:	6088                	ld	a0,0(s1)
    80005816:	c511                	beqz	a0,80005822 <sys_exec+0xe2>
    kfree(argv[i]);
    80005818:	a4efb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000581c:	04a1                	addi	s1,s1,8
    8000581e:	ff449be3          	bne	s1,s4,80005814 <sys_exec+0xd4>
  return ret;
    80005822:	854a                	mv	a0,s2
    80005824:	64be                	ld	s1,456(sp)
    80005826:	691e                	ld	s2,448(sp)
    80005828:	79fa                	ld	s3,440(sp)
    8000582a:	7a5a                	ld	s4,432(sp)
    8000582c:	7aba                	ld	s5,424(sp)
    8000582e:	7b1a                	ld	s6,416(sp)
    80005830:	6bfa                	ld	s7,408(sp)
    80005832:	a809                	j	80005844 <sys_exec+0x104>
  return -1;
    80005834:	557d                	li	a0,-1
    80005836:	64be                	ld	s1,456(sp)
    80005838:	691e                	ld	s2,448(sp)
    8000583a:	79fa                	ld	s3,440(sp)
    8000583c:	7a5a                	ld	s4,432(sp)
    8000583e:	7aba                	ld	s5,424(sp)
    80005840:	7b1a                	ld	s6,416(sp)
    80005842:	6bfa                	ld	s7,408(sp)
}
    80005844:	60fe                	ld	ra,472(sp)
    80005846:	645e                	ld	s0,464(sp)
    80005848:	613d                	addi	sp,sp,480
    8000584a:	8082                	ret

000000008000584c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000584c:	7139                	addi	sp,sp,-64
    8000584e:	fc06                	sd	ra,56(sp)
    80005850:	f822                	sd	s0,48(sp)
    80005852:	f426                	sd	s1,40(sp)
    80005854:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005856:	8f2fc0ef          	jal	80001948 <myproc>
    8000585a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000585c:	fd840593          	addi	a1,s0,-40
    80005860:	4501                	li	a0,0
    80005862:	b0afd0ef          	jal	80002b6c <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005866:	fc840593          	addi	a1,s0,-56
    8000586a:	fd040513          	addi	a0,s0,-48
    8000586e:	f7ffe0ef          	jal	800047ec <pipealloc>
    return -1;
    80005872:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005874:	0a054963          	bltz	a0,80005926 <sys_pipe+0xda>
  fd0 = -1;
    80005878:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    8000587c:	fd043503          	ld	a0,-48(s0)
    80005880:	ea0ff0ef          	jal	80004f20 <fdalloc>
    80005884:	fca42223          	sw	a0,-60(s0)
    80005888:	08054663          	bltz	a0,80005914 <sys_pipe+0xc8>
    8000588c:	fc843503          	ld	a0,-56(s0)
    80005890:	e90ff0ef          	jal	80004f20 <fdalloc>
    80005894:	fca42023          	sw	a0,-64(s0)
    80005898:	06054463          	bltz	a0,80005900 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    8000589c:	4711                	li	a4,4
    8000589e:	fc440693          	addi	a3,s0,-60
    800058a2:	fd843603          	ld	a2,-40(s0)
    800058a6:	64ac                	ld	a1,72(s1)
    800058a8:	68a8                	ld	a0,80(s1)
    800058aa:	cd9fb0ef          	jal	80001582 <copyout>
    800058ae:	00054f63          	bltz	a0,800058cc <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    800058b2:	4711                	li	a4,4
    800058b4:	fc040693          	addi	a3,s0,-64
    800058b8:	fd843603          	ld	a2,-40(s0)
    800058bc:	963a                	add	a2,a2,a4
    800058be:	64ac                	ld	a1,72(s1)
    800058c0:	68a8                	ld	a0,80(s1)
    800058c2:	cc1fb0ef          	jal	80001582 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800058c6:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800058c8:	04055f63          	bgez	a0,80005926 <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    800058cc:	fc442783          	lw	a5,-60(s0)
    800058d0:	078e                	slli	a5,a5,0x3
    800058d2:	0d078793          	addi	a5,a5,208
    800058d6:	97a6                	add	a5,a5,s1
    800058d8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800058dc:	fc042783          	lw	a5,-64(s0)
    800058e0:	078e                	slli	a5,a5,0x3
    800058e2:	0d078793          	addi	a5,a5,208
    800058e6:	94be                	add	s1,s1,a5
    800058e8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800058ec:	fd043503          	ld	a0,-48(s0)
    800058f0:	bbffe0ef          	jal	800044ae <fileclose>
    fileclose(wf);
    800058f4:	fc843503          	ld	a0,-56(s0)
    800058f8:	bb7fe0ef          	jal	800044ae <fileclose>
    return -1;
    800058fc:	57fd                	li	a5,-1
    800058fe:	a025                	j	80005926 <sys_pipe+0xda>
    if (fd0 >= 0)
    80005900:	fc442783          	lw	a5,-60(s0)
    80005904:	0007c863          	bltz	a5,80005914 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    80005908:	078e                	slli	a5,a5,0x3
    8000590a:	0d078793          	addi	a5,a5,208
    8000590e:	97a6                	add	a5,a5,s1
    80005910:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005914:	fd043503          	ld	a0,-48(s0)
    80005918:	b97fe0ef          	jal	800044ae <fileclose>
    fileclose(wf);
    8000591c:	fc843503          	ld	a0,-56(s0)
    80005920:	b8ffe0ef          	jal	800044ae <fileclose>
    return -1;
    80005924:	57fd                	li	a5,-1
}
    80005926:	853e                	mv	a0,a5
    80005928:	70e2                	ld	ra,56(sp)
    8000592a:	7442                	ld	s0,48(sp)
    8000592c:	74a2                	ld	s1,40(sp)
    8000592e:	6121                	addi	sp,sp,64
    80005930:	8082                	ret
	...

0000000080005940 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005940:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005942:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005944:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005946:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005948:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000594a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000594c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000594e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005950:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005952:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005954:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005956:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005958:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000595a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000595c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000595e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005960:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005962:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005964:	86efd0ef          	jal	800029d2 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005968:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000596a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000596c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000596e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005970:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005972:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005974:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005976:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005978:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000597a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000597c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000597e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005980:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005982:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005984:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005986:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005988:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000598a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000598c:	10200073          	sret
    80005990:	0001                	nop
    80005992:	00000013          	nop
    80005996:	00000013          	nop
    8000599a:	00000013          	nop

000000008000599e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000599e:	1141                	addi	sp,sp,-16
    800059a0:	e406                	sd	ra,8(sp)
    800059a2:	e022                	sd	s0,0(sp)
    800059a4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    800059a6:	0c000737          	lui	a4,0xc000
    800059aa:	4785                	li	a5,1
    800059ac:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    800059ae:	c35c                	sw	a5,4(a4)
}
    800059b0:	60a2                	ld	ra,8(sp)
    800059b2:	6402                	ld	s0,0(sp)
    800059b4:	0141                	addi	sp,sp,16
    800059b6:	8082                	ret

00000000800059b8 <plicinithart>:

void
plicinithart(void)
{
    800059b8:	1141                	addi	sp,sp,-16
    800059ba:	e406                	sd	ra,8(sp)
    800059bc:	e022                	sd	s0,0(sp)
    800059be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800059c0:	f55fb0ef          	jal	80001914 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    800059c4:	0085179b          	slliw	a5,a0,0x8
    800059c8:	0c002737          	lui	a4,0xc002
    800059cc:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    800059d0:	97ba                	add	a5,a5,a4
    800059d2:	40200713          	li	a4,1026
    800059d6:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    800059d8:	00d5151b          	slliw	a0,a0,0xd
    800059dc:	0c2017b7          	lui	a5,0xc201
    800059e0:	953e                	add	a0,a0,a5
    800059e2:	00052023          	sw	zero,0(a0)
}
    800059e6:	60a2                	ld	ra,8(sp)
    800059e8:	6402                	ld	s0,0(sp)
    800059ea:	0141                	addi	sp,sp,16
    800059ec:	8082                	ret

00000000800059ee <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800059ee:	1141                	addi	sp,sp,-16
    800059f0:	e406                	sd	ra,8(sp)
    800059f2:	e022                	sd	s0,0(sp)
    800059f4:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800059f6:	f1ffb0ef          	jal	80001914 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    800059fa:	00d5151b          	slliw	a0,a0,0xd
    800059fe:	0c2017b7          	lui	a5,0xc201
    80005a02:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80005a04:	953e                	add	a0,a0,a5
    80005a06:	4108                	lw	a0,0(a0)
  return irq;
}
    80005a08:	60a2                	ld	ra,8(sp)
    80005a0a:	6402                	ld	s0,0(sp)
    80005a0c:	0141                	addi	sp,sp,16
    80005a0e:	8082                	ret

0000000080005a10 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005a10:	1101                	addi	sp,sp,-32
    80005a12:	ec06                	sd	ra,24(sp)
    80005a14:	e822                	sd	s0,16(sp)
    80005a16:	e426                	sd	s1,8(sp)
    80005a18:	1000                	addi	s0,sp,32
    80005a1a:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005a1c:	ef9fb0ef          	jal	80001914 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    80005a20:	00d5179b          	slliw	a5,a0,0xd
    80005a24:	0c201737          	lui	a4,0xc201
    80005a28:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    80005a2a:	97ba                	add	a5,a5,a4
    80005a2c:	c384                	sw	s1,0(a5)
}
    80005a2e:	60e2                	ld	ra,24(sp)
    80005a30:	6442                	ld	s0,16(sp)
    80005a32:	64a2                	ld	s1,8(sp)
    80005a34:	6105                	addi	sp,sp,32
    80005a36:	8082                	ret

0000000080005a38 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005a38:	1141                	addi	sp,sp,-16
    80005a3a:	e406                	sd	ra,8(sp)
    80005a3c:	e022                	sd	s0,0(sp)
    80005a3e:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005a40:	479d                	li	a5,7
    80005a42:	04a7ca63          	blt	a5,a0,80005a96 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005a46:	0001e797          	auipc	a5,0x1e
    80005a4a:	d9278793          	addi	a5,a5,-622 # 800237d8 <disk>
    80005a4e:	97aa                	add	a5,a5,a0
    80005a50:	0187c783          	lbu	a5,24(a5)
    80005a54:	e7b9                	bnez	a5,80005aa2 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005a56:	00451693          	slli	a3,a0,0x4
    80005a5a:	0001e797          	auipc	a5,0x1e
    80005a5e:	d7e78793          	addi	a5,a5,-642 # 800237d8 <disk>
    80005a62:	6398                	ld	a4,0(a5)
    80005a64:	9736                	add	a4,a4,a3
    80005a66:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005a6a:	6398                	ld	a4,0(a5)
    80005a6c:	9736                	add	a4,a4,a3
    80005a6e:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005a72:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005a76:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005a7a:	97aa                	add	a5,a5,a0
    80005a7c:	4705                	li	a4,1
    80005a7e:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005a82:	0001e517          	auipc	a0,0x1e
    80005a86:	d6e50513          	addi	a0,a0,-658 # 800237f0 <disk+0x18>
    80005a8a:	f1afc0ef          	jal	800021a4 <wakeup>
}
    80005a8e:	60a2                	ld	ra,8(sp)
    80005a90:	6402                	ld	s0,0(sp)
    80005a92:	0141                	addi	sp,sp,16
    80005a94:	8082                	ret
    panic("free_desc 1");
    80005a96:	00002517          	auipc	a0,0x2
    80005a9a:	b9a50513          	addi	a0,a0,-1126 # 80007630 <etext+0x630>
    80005a9e:	d97fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    80005aa2:	00002517          	auipc	a0,0x2
    80005aa6:	b9e50513          	addi	a0,a0,-1122 # 80007640 <etext+0x640>
    80005aaa:	d8bfa0ef          	jal	80000834 <panic>

0000000080005aae <virtio_disk_init>:
{
    80005aae:	1101                	addi	sp,sp,-32
    80005ab0:	ec06                	sd	ra,24(sp)
    80005ab2:	e822                	sd	s0,16(sp)
    80005ab4:	e426                	sd	s1,8(sp)
    80005ab6:	e04a                	sd	s2,0(sp)
    80005ab8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005aba:	00002597          	auipc	a1,0x2
    80005abe:	b9658593          	addi	a1,a1,-1130 # 80007650 <etext+0x650>
    80005ac2:	0001e517          	auipc	a0,0x1e
    80005ac6:	e3e50513          	addi	a0,a0,-450 # 80023900 <disk+0x128>
    80005aca:	8defb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ace:	100017b7          	lui	a5,0x10001
    80005ad2:	4398                	lw	a4,0(a5)
    80005ad4:	2701                	sext.w	a4,a4
    80005ad6:	747277b7          	lui	a5,0x74727
    80005ada:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ade:	14f71863          	bne	a4,a5,80005c2e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ae2:	100017b7          	lui	a5,0x10001
    80005ae6:	43dc                	lw	a5,4(a5)
    80005ae8:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005aea:	4709                	li	a4,2
    80005aec:	14e79163          	bne	a5,a4,80005c2e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005af0:	100017b7          	lui	a5,0x10001
    80005af4:	479c                	lw	a5,8(a5)
    80005af6:	2781                	sext.w	a5,a5
    80005af8:	12e79b63          	bne	a5,a4,80005c2e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    80005afc:	100017b7          	lui	a5,0x10001
    80005b00:	47d8                	lw	a4,12(a5)
    80005b02:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b04:	554d47b7          	lui	a5,0x554d4
    80005b08:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005b0c:	12f71163          	bne	a4,a5,80005c2e <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b10:	100017b7          	lui	a5,0x10001
    80005b14:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b18:	4705                	li	a4,1
    80005b1a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b1c:	470d                	li	a4,3
    80005b1e:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005b20:	10001737          	lui	a4,0x10001
    80005b24:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005b26:	c7ffe6b7          	lui	a3,0xc7ffe
    80005b2a:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdac47>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005b2e:	8f75                	and	a4,a4,a3
    80005b30:	100016b7          	lui	a3,0x10001
    80005b34:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b36:	472d                	li	a4,11
    80005b38:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b3a:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005b3e:	439c                	lw	a5,0(a5)
    80005b40:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005b44:	8ba1                	andi	a5,a5,8
    80005b46:	0e078a63          	beqz	a5,80005c3a <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005b4a:	100017b7          	lui	a5,0x10001
    80005b4e:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005b52:	43fc                	lw	a5,68(a5)
    80005b54:	2781                	sext.w	a5,a5
    80005b56:	0e079863          	bnez	a5,80005c46 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005b5a:	100017b7          	lui	a5,0x10001
    80005b5e:	5bdc                	lw	a5,52(a5)
    80005b60:	2781                	sext.w	a5,a5
  if (max == 0)
    80005b62:	0e078863          	beqz	a5,80005c52 <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005b66:	471d                	li	a4,7
    80005b68:	0ef77b63          	bgeu	a4,a5,80005c5e <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005b6c:	fe3fa0ef          	jal	80000b4e <kalloc>
    80005b70:	0001e497          	auipc	s1,0x1e
    80005b74:	c6848493          	addi	s1,s1,-920 # 800237d8 <disk>
    80005b78:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005b7a:	fd5fa0ef          	jal	80000b4e <kalloc>
    80005b7e:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005b80:	fcffa0ef          	jal	80000b4e <kalloc>
    80005b84:	87aa                	mv	a5,a0
    80005b86:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005b88:	6088                	ld	a0,0(s1)
    80005b8a:	0e050063          	beqz	a0,80005c6a <virtio_disk_init+0x1bc>
    80005b8e:	0001e717          	auipc	a4,0x1e
    80005b92:	c5273703          	ld	a4,-942(a4) # 800237e0 <disk+0x8>
    80005b96:	cb71                	beqz	a4,80005c6a <virtio_disk_init+0x1bc>
    80005b98:	cbe9                	beqz	a5,80005c6a <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005b9a:	6605                	lui	a2,0x1
    80005b9c:	4581                	li	a1,0
    80005b9e:	94afb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005ba2:	0001e497          	auipc	s1,0x1e
    80005ba6:	c3648493          	addi	s1,s1,-970 # 800237d8 <disk>
    80005baa:	6605                	lui	a2,0x1
    80005bac:	4581                	li	a1,0
    80005bae:	6488                	ld	a0,8(s1)
    80005bb0:	938fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005bb4:	6605                	lui	a2,0x1
    80005bb6:	4581                	li	a1,0
    80005bb8:	6888                	ld	a0,16(s1)
    80005bba:	92efb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005bbe:	100017b7          	lui	a5,0x10001
    80005bc2:	4721                	li	a4,8
    80005bc4:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005bc6:	4098                	lw	a4,0(s1)
    80005bc8:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005bcc:	40d8                	lw	a4,4(s1)
    80005bce:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005bd2:	649c                	ld	a5,8(s1)
    80005bd4:	0007869b          	sext.w	a3,a5
    80005bd8:	10001737          	lui	a4,0x10001
    80005bdc:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005be0:	9781                	srai	a5,a5,0x20
    80005be2:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005be6:	689c                	ld	a5,16(s1)
    80005be8:	0007869b          	sext.w	a3,a5
    80005bec:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005bf0:	9781                	srai	a5,a5,0x20
    80005bf2:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005bf6:	4785                	li	a5,1
    80005bf8:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005bfa:	00f48c23          	sb	a5,24(s1)
    80005bfe:	00f48ca3          	sb	a5,25(s1)
    80005c02:	00f48d23          	sb	a5,26(s1)
    80005c06:	00f48da3          	sb	a5,27(s1)
    80005c0a:	00f48e23          	sb	a5,28(s1)
    80005c0e:	00f48ea3          	sb	a5,29(s1)
    80005c12:	00f48f23          	sb	a5,30(s1)
    80005c16:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005c1a:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c1e:	07272823          	sw	s2,112(a4)
}
    80005c22:	60e2                	ld	ra,24(sp)
    80005c24:	6442                	ld	s0,16(sp)
    80005c26:	64a2                	ld	s1,8(sp)
    80005c28:	6902                	ld	s2,0(sp)
    80005c2a:	6105                	addi	sp,sp,32
    80005c2c:	8082                	ret
    panic("could not find virtio disk");
    80005c2e:	00002517          	auipc	a0,0x2
    80005c32:	a3250513          	addi	a0,a0,-1486 # 80007660 <etext+0x660>
    80005c36:	bfffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005c3a:	00002517          	auipc	a0,0x2
    80005c3e:	a4650513          	addi	a0,a0,-1466 # 80007680 <etext+0x680>
    80005c42:	bf3fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005c46:	00002517          	auipc	a0,0x2
    80005c4a:	a5a50513          	addi	a0,a0,-1446 # 800076a0 <etext+0x6a0>
    80005c4e:	be7fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005c52:	00002517          	auipc	a0,0x2
    80005c56:	a6e50513          	addi	a0,a0,-1426 # 800076c0 <etext+0x6c0>
    80005c5a:	bdbfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005c5e:	00002517          	auipc	a0,0x2
    80005c62:	a8250513          	addi	a0,a0,-1406 # 800076e0 <etext+0x6e0>
    80005c66:	bcffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005c6a:	00002517          	auipc	a0,0x2
    80005c6e:	a9650513          	addi	a0,a0,-1386 # 80007700 <etext+0x700>
    80005c72:	bc3fa0ef          	jal	80000834 <panic>

0000000080005c76 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005c76:	711d                	addi	sp,sp,-96
    80005c78:	ec86                	sd	ra,88(sp)
    80005c7a:	e8a2                	sd	s0,80(sp)
    80005c7c:	e4a6                	sd	s1,72(sp)
    80005c7e:	e0ca                	sd	s2,64(sp)
    80005c80:	fc4e                	sd	s3,56(sp)
    80005c82:	f852                	sd	s4,48(sp)
    80005c84:	f456                	sd	s5,40(sp)
    80005c86:	f05a                	sd	s6,32(sp)
    80005c88:	ec5e                	sd	s7,24(sp)
    80005c8a:	e862                	sd	s8,16(sp)
    80005c8c:	1080                	addi	s0,sp,96
    80005c8e:	89aa                	mv	s3,a0
    80005c90:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005c92:	00c52b83          	lw	s7,12(a0)
    80005c96:	001b9b9b          	slliw	s7,s7,0x1
    80005c9a:	1b82                	slli	s7,s7,0x20
    80005c9c:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005ca0:	0001e517          	auipc	a0,0x1e
    80005ca4:	c6050513          	addi	a0,a0,-928 # 80023900 <disk+0x128>
    80005ca8:	f81fa0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005cac:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005cae:	0001ea97          	auipc	s5,0x1e
    80005cb2:	b2aa8a93          	addi	s5,s5,-1238 # 800237d8 <disk>
  for (int i = 0; i < 3; i++) {
    80005cb6:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005cb8:	5c7d                	li	s8,-1
    80005cba:	a8a5                	j	80005d32 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005cbc:	00fa8733          	add	a4,s5,a5
    80005cc0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005cc4:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005cc6:	0207c563          	bltz	a5,80005cf0 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005cca:	2905                	addiw	s2,s2,1
    80005ccc:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005cce:	07490663          	beq	s2,s4,80005d3a <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005cd2:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005cd4:	0001e717          	auipc	a4,0x1e
    80005cd8:	b0470713          	addi	a4,a4,-1276 # 800237d8 <disk>
    80005cdc:	4781                	li	a5,0
    if (disk.free[i]) {
    80005cde:	01874683          	lbu	a3,24(a4)
    80005ce2:	fee9                	bnez	a3,80005cbc <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005ce4:	2785                	addiw	a5,a5,1
    80005ce6:	0705                	addi	a4,a4,1
    80005ce8:	fe979be3          	bne	a5,s1,80005cde <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005cec:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005cf0:	01205d63          	blez	s2,80005d0a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005cf4:	fa042503          	lw	a0,-96(s0)
    80005cf8:	d41ff0ef          	jal	80005a38 <free_desc>
      for (int j = 0; j < i; j++)
    80005cfc:	4785                	li	a5,1
    80005cfe:	0127d663          	bge	a5,s2,80005d0a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005d02:	fa442503          	lw	a0,-92(s0)
    80005d06:	d33ff0ef          	jal	80005a38 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005d0a:	0001e517          	auipc	a0,0x1e
    80005d0e:	ae650513          	addi	a0,a0,-1306 # 800237f0 <disk+0x18>
    80005d12:	c26fc0ef          	jal	80002138 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005d16:	0001e517          	auipc	a0,0x1e
    80005d1a:	bea50513          	addi	a0,a0,-1046 # 80023900 <disk+0x128>
    80005d1e:	f93fa0ef          	jal	80000cb0 <release>
    sleep();
    80005d22:	c52fc0ef          	jal	80002174 <sleep>
    acquire(&disk.vdisk_lock);
    80005d26:	0001e517          	auipc	a0,0x1e
    80005d2a:	bda50513          	addi	a0,a0,-1062 # 80023900 <disk+0x128>
    80005d2e:	efbfa0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005d32:	fa040613          	addi	a2,s0,-96
    80005d36:	4901                	li	s2,0
    80005d38:	bf69                	j	80005cd2 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d3a:	fa042503          	lw	a0,-96(s0)
    80005d3e:	00451693          	slli	a3,a0,0x4

  if (write)
    80005d42:	0001e797          	auipc	a5,0x1e
    80005d46:	a9678793          	addi	a5,a5,-1386 # 800237d8 <disk>
    80005d4a:	00451713          	slli	a4,a0,0x4
    80005d4e:	0a070713          	addi	a4,a4,160
    80005d52:	973e                	add	a4,a4,a5
    80005d54:	01603633          	snez	a2,s6
    80005d58:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005d5a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005d5e:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005d62:	6398                	ld	a4,0(a5)
    80005d64:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d66:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005d6a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005d6c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005d6e:	6390                	ld	a2,0(a5)
    80005d70:	00d60833          	add	a6,a2,a3
    80005d74:	4741                	li	a4,16
    80005d76:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005d7a:	4585                	li	a1,1
    80005d7c:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005d80:	fa442703          	lw	a4,-92(s0)
    80005d84:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005d88:	0712                	slli	a4,a4,0x4
    80005d8a:	963a                	add	a2,a2,a4
    80005d8c:	05898813          	addi	a6,s3,88
    80005d90:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005d94:	0007b883          	ld	a7,0(a5)
    80005d98:	9746                	add	a4,a4,a7
    80005d9a:	40000613          	li	a2,1024
    80005d9e:	c710                	sw	a2,8(a4)
  if (write)
    80005da0:	001b3613          	seqz	a2,s6
    80005da4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005da8:	8e4d                	or	a2,a2,a1
    80005daa:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005dae:	fa842603          	lw	a2,-88(s0)
    80005db2:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005db6:	00451813          	slli	a6,a0,0x4
    80005dba:	02080813          	addi	a6,a6,32
    80005dbe:	983e                	add	a6,a6,a5
    80005dc0:	577d                	li	a4,-1
    80005dc2:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005dc6:	0612                	slli	a2,a2,0x4
    80005dc8:	98b2                	add	a7,a7,a2
    80005dca:	03068713          	addi	a4,a3,48
    80005dce:	973e                	add	a4,a4,a5
    80005dd0:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005dd4:	6398                	ld	a4,0(a5)
    80005dd6:	9732                	add	a4,a4,a2
    80005dd8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005dda:	4689                	li	a3,2
    80005ddc:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005de0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005de4:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005de8:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005dec:	6794                	ld	a3,8(a5)
    80005dee:	0026d703          	lhu	a4,2(a3)
    80005df2:	8b1d                	andi	a4,a4,7
    80005df4:	0706                	slli	a4,a4,0x1
    80005df6:	96ba                	add	a3,a3,a4
    80005df8:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005dfc:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005e00:	6798                	ld	a4,8(a5)
    80005e02:	00275783          	lhu	a5,2(a4)
    80005e06:	2785                	addiw	a5,a5,1
    80005e08:	00f71123          	sh	a5,2(a4)
    80005e0c:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005e10:	100017b7          	lui	a5,0x10001
    80005e14:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005e18:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005e1c:	0001e497          	auipc	s1,0x1e
    80005e20:	ae448493          	addi	s1,s1,-1308 # 80023900 <disk+0x128>
  while (b->disk == 1) {
    80005e24:	892e                	mv	s2,a1
    80005e26:	02b79163          	bne	a5,a1,80005e48 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005e2a:	854e                	mv	a0,s3
    80005e2c:	b0cfc0ef          	jal	80002138 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005e30:	8526                	mv	a0,s1
    80005e32:	e7ffa0ef          	jal	80000cb0 <release>
    sleep();
    80005e36:	b3efc0ef          	jal	80002174 <sleep>
    acquire(&disk.vdisk_lock);
    80005e3a:	8526                	mv	a0,s1
    80005e3c:	dedfa0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005e40:	0049a783          	lw	a5,4(s3)
    80005e44:	ff2783e3          	beq	a5,s2,80005e2a <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005e48:	fa042903          	lw	s2,-96(s0)
    80005e4c:	00491713          	slli	a4,s2,0x4
    80005e50:	02070713          	addi	a4,a4,32
    80005e54:	0001e797          	auipc	a5,0x1e
    80005e58:	98478793          	addi	a5,a5,-1660 # 800237d8 <disk>
    80005e5c:	97ba                	add	a5,a5,a4
    80005e5e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005e62:	0001e997          	auipc	s3,0x1e
    80005e66:	97698993          	addi	s3,s3,-1674 # 800237d8 <disk>
    80005e6a:	00491713          	slli	a4,s2,0x4
    80005e6e:	0009b783          	ld	a5,0(s3)
    80005e72:	97ba                	add	a5,a5,a4
    80005e74:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005e78:	854a                	mv	a0,s2
    80005e7a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005e7e:	bbbff0ef          	jal	80005a38 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005e82:	8885                	andi	s1,s1,1
    80005e84:	f0fd                	bnez	s1,80005e6a <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005e86:	0001e517          	auipc	a0,0x1e
    80005e8a:	a7a50513          	addi	a0,a0,-1414 # 80023900 <disk+0x128>
    80005e8e:	e23fa0ef          	jal	80000cb0 <release>
}
    80005e92:	60e6                	ld	ra,88(sp)
    80005e94:	6446                	ld	s0,80(sp)
    80005e96:	64a6                	ld	s1,72(sp)
    80005e98:	6906                	ld	s2,64(sp)
    80005e9a:	79e2                	ld	s3,56(sp)
    80005e9c:	7a42                	ld	s4,48(sp)
    80005e9e:	7aa2                	ld	s5,40(sp)
    80005ea0:	7b02                	ld	s6,32(sp)
    80005ea2:	6be2                	ld	s7,24(sp)
    80005ea4:	6c42                	ld	s8,16(sp)
    80005ea6:	6125                	addi	sp,sp,96
    80005ea8:	8082                	ret

0000000080005eaa <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005eaa:	1101                	addi	sp,sp,-32
    80005eac:	ec06                	sd	ra,24(sp)
    80005eae:	e822                	sd	s0,16(sp)
    80005eb0:	e426                	sd	s1,8(sp)
    80005eb2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005eb4:	0001e497          	auipc	s1,0x1e
    80005eb8:	92448493          	addi	s1,s1,-1756 # 800237d8 <disk>
    80005ebc:	0001e517          	auipc	a0,0x1e
    80005ec0:	a4450513          	addi	a0,a0,-1468 # 80023900 <disk+0x128>
    80005ec4:	d65fa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005ec8:	100017b7          	lui	a5,0x10001
    80005ecc:	53bc                	lw	a5,96(a5)
    80005ece:	8b8d                	andi	a5,a5,3
    80005ed0:	10001737          	lui	a4,0x10001
    80005ed4:	d37c                	sw	a5,100(a4)
    80005ed6:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005eda:	689c                	ld	a5,16(s1)
    80005edc:	0204d703          	lhu	a4,32(s1)
    80005ee0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005ee4:	04f70863          	beq	a4,a5,80005f34 <virtio_disk_intr+0x8a>
    80005ee8:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005eec:	6898                	ld	a4,16(s1)
    80005eee:	0204d783          	lhu	a5,32(s1)
    80005ef2:	8b9d                	andi	a5,a5,7
    80005ef4:	078e                	slli	a5,a5,0x3
    80005ef6:	97ba                	add	a5,a5,a4
    80005ef8:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005efa:	00479713          	slli	a4,a5,0x4
    80005efe:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005f02:	9726                	add	a4,a4,s1
    80005f04:	01074703          	lbu	a4,16(a4)
    80005f08:	e329                	bnez	a4,80005f4a <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005f0a:	0792                	slli	a5,a5,0x4
    80005f0c:	02078793          	addi	a5,a5,32
    80005f10:	97a6                	add	a5,a5,s1
    80005f12:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005f14:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005f18:	a8cfc0ef          	jal	800021a4 <wakeup>

    disk.used_idx += 1;
    80005f1c:	0204d783          	lhu	a5,32(s1)
    80005f20:	2785                	addiw	a5,a5,1
    80005f22:	17c2                	slli	a5,a5,0x30
    80005f24:	93c1                	srli	a5,a5,0x30
    80005f26:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005f2a:	6898                	ld	a4,16(s1)
    80005f2c:	00275703          	lhu	a4,2(a4)
    80005f30:	faf71ce3          	bne	a4,a5,80005ee8 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005f34:	0001e517          	auipc	a0,0x1e
    80005f38:	9cc50513          	addi	a0,a0,-1588 # 80023900 <disk+0x128>
    80005f3c:	d75fa0ef          	jal	80000cb0 <release>
}
    80005f40:	60e2                	ld	ra,24(sp)
    80005f42:	6442                	ld	s0,16(sp)
    80005f44:	64a2                	ld	s1,8(sp)
    80005f46:	6105                	addi	sp,sp,32
    80005f48:	8082                	ret
      panic("virtio_disk_intr status");
    80005f4a:	00001517          	auipc	a0,0x1
    80005f4e:	7ce50513          	addi	a0,a0,1998 # 80007718 <etext+0x718>
    80005f52:	8e3fa0ef          	jal	80000834 <panic>
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
