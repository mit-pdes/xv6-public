
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	51813103          	ld	sp,1304(sp) # 8000b518 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd9b97>
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
    8000011c:	4d8020ef          	jal	800025f4 <either_copyin>
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
    80000194:	00013517          	auipc	a0,0x13
    80000198:	3cc50513          	addi	a0,a0,972 # 80013560 <cons>
    8000019c:	28d000ef          	jal	80000c28 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00013497          	auipc	s1,0x13
    800001a4:	3c048493          	addi	s1,s1,960 # 80013560 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00013917          	auipc	s2,0x13
    800001ac:	45090913          	addi	s2,s2,1104 # 800135f8 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	78c010ef          	jal	8000194c <myproc>
    800001c4:	1d6020ef          	jal	8000239a <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	771010ef          	jal	8000213c <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	7a3010ef          	jal	80002178 <sleep>
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
    800001ee:	00013717          	auipc	a4,0x13
    800001f2:	37270713          	addi	a4,a4,882 # 80013560 <cons>
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
    80000220:	388020ef          	jal	800025a8 <either_copyout>
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
    80000238:	00013517          	auipc	a0,0x13
    8000023c:	32850513          	addi	a0,a0,808 # 80013560 <cons>
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
    8000025e:	00013717          	auipc	a4,0x13
    80000262:	38f72d23          	sw	a5,922(a4) # 800135f8 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00013517          	auipc	a0,0x13
    80000278:	2ec50513          	addi	a0,a0,748 # 80013560 <cons>
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
    800002c8:	00013517          	auipc	a0,0x13
    800002cc:	29850513          	addi	a0,a0,664 # 80013560 <cons>
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
    800002ea:	356020ef          	jal	80002640 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00013517          	auipc	a0,0x13
    800002f2:	27250513          	addi	a0,a0,626 # 80013560 <cons>
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
    8000030c:	00013717          	auipc	a4,0x13
    80000310:	25470713          	addi	a4,a4,596 # 80013560 <cons>
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
    80000332:	00013717          	auipc	a4,0x13
    80000336:	22e70713          	addi	a4,a4,558 # 80013560 <cons>
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
    8000035c:	00013717          	auipc	a4,0x13
    80000360:	29c72703          	lw	a4,668(a4) # 800135f8 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00013717          	auipc	a4,0x13
    80000376:	1ee70713          	addi	a4,a4,494 # 80013560 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00013497          	auipc	s1,0x13
    80000386:	1de48493          	addi	s1,s1,478 # 80013560 <cons>
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
    800003c4:	00013717          	auipc	a4,0x13
    800003c8:	19c70713          	addi	a4,a4,412 # 80013560 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00013717          	auipc	a4,0x13
    800003de:	22f72323          	sw	a5,550(a4) # 80013600 <cons+0xa0>
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
    800003f8:	00013797          	auipc	a5,0x13
    800003fc:	16878793          	addi	a5,a5,360 # 80013560 <cons>
    80000400:	0a07a703          	lw	a4,160(a5)
    80000404:	0017069b          	addiw	a3,a4,1
    80000408:	8636                	mv	a2,a3
    8000040a:	0ad7a023          	sw	a3,160(a5)
    8000040e:	07f77713          	andi	a4,a4,127
    80000412:	97ba                	add	a5,a5,a4
    80000414:	4729                	li	a4,10
    80000416:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000041a:	00013797          	auipc	a5,0x13
    8000041e:	1ec7a123          	sw	a2,482(a5) # 800135fc <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00013517          	auipc	a0,0x13
    80000426:	1d650513          	addi	a0,a0,470 # 800135f8 <cons+0x98>
    8000042a:	57f010ef          	jal	800021a8 <wakeup>
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
    80000438:	00008597          	auipc	a1,0x8
    8000043c:	bc858593          	addi	a1,a1,-1080 # 80008000 <etext>
    80000440:	00013517          	auipc	a0,0x13
    80000444:	12050513          	addi	a0,a0,288 # 80013560 <cons>
    80000448:	760000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00023797          	auipc	a5,0x23
    80000454:	68078793          	addi	a5,a5,1664 # 80023ad0 <devsw>
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
    8000048e:	00008817          	auipc	a6,0x8
    80000492:	2aa80813          	addi	a6,a6,682 # 80008738 <digits>
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
    80000528:	0000b797          	auipc	a5,0xb
    8000052c:	00c7a783          	lw	a5,12(a5) # 8000b534 <panicking>
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
    8000056e:	00013517          	auipc	a0,0x13
    80000572:	09a50513          	addi	a0,a0,154 # 80013608 <pr>
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
    800006e2:	00008c97          	auipc	s9,0x8
    800006e6:	056c8c93          	addi	s9,s9,86 # 80008738 <digits>
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
    80000742:	00008a17          	auipc	s4,0x8
    80000746:	8c6a0a13          	addi	s4,s4,-1850 # 80008008 <etext+0x8>
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
    8000076a:	0000b797          	auipc	a5,0xb
    8000076e:	dca7a783          	lw	a5,-566(a5) # 8000b534 <panicking>
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
    80000794:	00013517          	auipc	a0,0x13
    80000798:	e7450513          	addi	a0,a0,-396 # 80013608 <pr>
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
    80000844:	0000b797          	auipc	a5,0xb
    80000848:	ce97a823          	sw	s1,-784(a5) # 8000b534 <panicking>
  printk("panic: ");
    8000084c:	00007517          	auipc	a0,0x7
    80000850:	7cc50513          	addi	a0,a0,1996 # 80008018 <etext+0x18>
    80000854:	cb7ff0ef          	jal	8000050a <printk>
  printk("%s\n", s);
    80000858:	85ca                	mv	a1,s2
    8000085a:	00007517          	auipc	a0,0x7
    8000085e:	7c650513          	addi	a0,a0,1990 # 80008020 <etext+0x20>
    80000862:	ca9ff0ef          	jal	8000050a <printk>
  panicked = 1; // freeze uart output from other CPUs
    80000866:	0000b797          	auipc	a5,0xb
    8000086a:	cc97a523          	sw	s1,-822(a5) # 8000b530 <panicked>
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
    80000878:	00007597          	auipc	a1,0x7
    8000087c:	7b058593          	addi	a1,a1,1968 # 80008028 <etext+0x28>
    80000880:	00013517          	auipc	a0,0x13
    80000884:	d8850513          	addi	a0,a0,-632 # 80013608 <pr>
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
    800008ce:	00007597          	auipc	a1,0x7
    800008d2:	76258593          	addi	a1,a1,1890 # 80008030 <etext+0x30>
    800008d6:	00013517          	auipc	a0,0x13
    800008da:	d4a50513          	addi	a0,a0,-694 # 80013620 <tx_lock>
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
    800008fa:	00013517          	auipc	a0,0x13
    800008fe:	d2650513          	addi	a0,a0,-730 # 80013620 <tx_lock>
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
    80000918:	0000b917          	auipc	s2,0xb
    8000091c:	c2490913          	addi	s2,s2,-988 # 8000b53c <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000b997          	auipc	s3,0xb
    80000924:	c1898993          	addi	s3,s3,-1000 # 8000b538 <tx_chan>
      release(&tx_lock);
    80000928:	00013497          	auipc	s1,0x13
    8000092c:	cf848493          	addi	s1,s1,-776 # 80013620 <tx_lock>
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
    8000093a:	003010ef          	jal	8000213c <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	035010ef          	jal	80002178 <sleep>
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
    80000978:	00013517          	auipc	a0,0x13
    8000097c:	ca850513          	addi	a0,a0,-856 # 80013620 <tx_lock>
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
    8000099c:	0000b797          	auipc	a5,0xb
    800009a0:	b987a783          	lw	a5,-1128(a5) # 8000b534 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000b797          	auipc	a5,0xb
    800009aa:	b8a7a783          	lw	a5,-1142(a5) # 8000b530 <panicked>
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
    800009cc:	0000b797          	auipc	a5,0xb
    800009d0:	b687a783          	lw	a5,-1176(a5) # 8000b534 <panicking>
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
    80000a02:	00013517          	auipc	a0,0x13
    80000a06:	c1e50513          	addi	a0,a0,-994 # 80013620 <tx_lock>
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
    80000a1c:	00013517          	auipc	a0,0x13
    80000a20:	c0450513          	addi	a0,a0,-1020 # 80013620 <tx_lock>
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
    80000a44:	0000b797          	auipc	a5,0xb
    80000a48:	ae07ac23          	sw	zero,-1288(a5) # 8000b53c <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000b517          	auipc	a0,0xb
    80000a50:	aec50513          	addi	a0,a0,-1300 # 8000b538 <tx_chan>
    80000a54:	754010ef          	jal	800021a8 <wakeup>
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
    80000a72:	00024797          	auipc	a5,0x24
    80000a76:	1f678793          	addi	a5,a5,502 # 80024c68 <end>
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
    80000a9c:	00013917          	auipc	s2,0x13
    80000aa0:	b9c90913          	addi	s2,s2,-1124 # 80013638 <kmem>
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
    80000ac6:	00007517          	auipc	a0,0x7
    80000aca:	57250513          	addi	a0,a0,1394 # 80008038 <etext+0x38>
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
    80000b22:	00007597          	auipc	a1,0x7
    80000b26:	51e58593          	addi	a1,a1,1310 # 80008040 <etext+0x40>
    80000b2a:	00013517          	auipc	a0,0x13
    80000b2e:	b0e50513          	addi	a0,a0,-1266 # 80013638 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00024517          	auipc	a0,0x24
    80000b3e:	12e50513          	addi	a0,a0,302 # 80024c68 <end>
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
    80000b58:	00013517          	auipc	a0,0x13
    80000b5c:	ae050513          	addi	a0,a0,-1312 # 80013638 <kmem>
    80000b60:	0c8000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b64:	00013497          	auipc	s1,0x13
    80000b68:	aec4b483          	ld	s1,-1300(s1) # 80013650 <kmem+0x18>
  if (r)
    80000b6c:	c49d                	beqz	s1,80000b9a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00013717          	auipc	a4,0x13
    80000b74:	aef73023          	sd	a5,-1312(a4) # 80013650 <kmem+0x18>
  release(&kmem.lock);
    80000b78:	00013517          	auipc	a0,0x13
    80000b7c:	ac050513          	addi	a0,a0,-1344 # 80013638 <kmem>
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
    80000b9a:	00013517          	auipc	a0,0x13
    80000b9e:	a9e50513          	addi	a0,a0,-1378 # 80013638 <kmem>
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
    80000bd8:	555000ef          	jal	8000192c <mycpu>
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
    80000bfe:	52f000ef          	jal	8000192c <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x2c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	527000ef          	jal	8000192c <mycpu>
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
    80000c1a:	513000ef          	jal	8000192c <mycpu>
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
    80000c4c:	4e1000ef          	jal	8000192c <mycpu>
    80000c50:	e888                	sd	a0,16(s1)
}
    80000c52:	60e2                	ld	ra,24(sp)
    80000c54:	6442                	ld	s0,16(sp)
    80000c56:	64a2                	ld	s1,8(sp)
    80000c58:	6105                	addi	sp,sp,32
    80000c5a:	8082                	ret
    panic("acquire");
    80000c5c:	00007517          	auipc	a0,0x7
    80000c60:	3ec50513          	addi	a0,a0,1004 # 80008048 <etext+0x48>
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
    80000c70:	4bd000ef          	jal	8000192c <mycpu>
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
    80000c98:	00007517          	auipc	a0,0x7
    80000c9c:	3b850513          	addi	a0,a0,952 # 80008050 <etext+0x50>
    80000ca0:	b95ff0ef          	jal	80000834 <panic>
    panic("pop_off");
    80000ca4:	00007517          	auipc	a0,0x7
    80000ca8:	3c450513          	addi	a0,a0,964 # 80008068 <etext+0x68>
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
    80000cdc:	00007517          	auipc	a0,0x7
    80000ce0:	39450513          	addi	a0,a0,916 # 80008070 <etext+0x70>
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
    80000ea6:	273000ef          	jal	80001918 <cpuid>
    seminit();          // semaphores
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eaa:	0000a717          	auipc	a4,0xa
    80000eae:	69670713          	addi	a4,a4,1686 # 8000b540 <started>
  if (cpuid() == 0) {
    80000eb2:	c51d                	beqz	a0,80000ee0 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eb4:	431c                	lw	a5,0(a4)
    80000eb6:	0230000f          	fence	r,rw
    80000eba:	2781                	sext.w	a5,a5
    80000ebc:	dfe5                	beqz	a5,80000eb4 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000ebe:	25b000ef          	jal	80001918 <cpuid>
    80000ec2:	85aa                	mv	a1,a0
    80000ec4:	00007517          	auipc	a0,0x7
    80000ec8:	1d450513          	addi	a0,a0,468 # 80008098 <etext+0x98>
    80000ecc:	e3eff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000ed0:	086000ef          	jal	80000f56 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000ed4:	09f010ef          	jal	80002772 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	4a1040ef          	jal	80005b78 <plicinithart>
  }

  scheduler();
    80000edc:	0c4010ef          	jal	80001fa0 <scheduler>
    consoleinit();
    80000ee0:	d50ff0ef          	jal	80000430 <consoleinit>
    printkinit();
    80000ee4:	98dff0ef          	jal	80000870 <printkinit>
    printk("\n");
    80000ee8:	00007517          	auipc	a0,0x7
    80000eec:	19050513          	addi	a0,a0,400 # 80008078 <etext+0x78>
    80000ef0:	e1aff0ef          	jal	8000050a <printk>
    printk("xv6 kernel is booting\n");
    80000ef4:	00007517          	auipc	a0,0x7
    80000ef8:	18c50513          	addi	a0,a0,396 # 80008080 <etext+0x80>
    80000efc:	e0eff0ef          	jal	8000050a <printk>
    printk("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	17850513          	addi	a0,a0,376 # 80008078 <etext+0x78>
    80000f08:	e02ff0ef          	jal	8000050a <printk>
    kinit();            // physical page allocator
    80000f0c:	c0fff0ef          	jal	80000b1a <kinit>
    kvminit();          // create kernel page table
    80000f10:	2d2000ef          	jal	800011e2 <kvminit>
    kvminithart();      // turn on paging
    80000f14:	042000ef          	jal	80000f56 <kvminithart>
    procinit();         // process table
    80000f18:	14b000ef          	jal	80001862 <procinit>
    trapinit();         // trap vectors
    80000f1c:	033010ef          	jal	8000274e <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	053010ef          	jal	80002772 <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	43b040ef          	jal	80005b5e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	451040ef          	jal	80005b78 <plicinithart>
    binit();            // buffer cache
    80000f2c:	0fa020ef          	jal	80003026 <binit>
    iinit();            // inode table
    80000f30:	64c020ef          	jal	8000357c <iinit>
    fileinit();         // file table
    80000f34:	67a030ef          	jal	800045ae <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	537040ef          	jal	80005c6e <virtio_disk_init>
    seminit();          // semaphores
    80000f3c:	6d5010ef          	jal	80002e10 <seminit>
    userinit();         // first user process
    80000f40:	521000ef          	jal	80001c60 <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f44:	0000a797          	auipc	a5,0xa
    80000f48:	5fc78793          	addi	a5,a5,1532 # 8000b540 <started>
    80000f4c:	4705                	li	a4,1
    80000f4e:	0310000f          	fence	rw,w
    80000f52:	c398                	sw	a4,0(a5)
    80000f54:	b761                	j	80000edc <main+0x3e>

0000000080000f56 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f56:	1141                	addi	sp,sp,-16
    80000f58:	e406                	sd	ra,8(sp)
    80000f5a:	e022                	sd	s0,0(sp)
    80000f5c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f5e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f62:	0000a797          	auipc	a5,0xa
    80000f66:	5e67b783          	ld	a5,1510(a5) # 8000b548 <kernel_pagetable>
    80000f6a:	83b1                	srli	a5,a5,0xc
    80000f6c:	577d                	li	a4,-1
    80000f6e:	177e                	slli	a4,a4,0x3f
    80000f70:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000f72:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f76:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f7a:	60a2                	ld	ra,8(sp)
    80000f7c:	6402                	ld	s0,0(sp)
    80000f7e:	0141                	addi	sp,sp,16
    80000f80:	8082                	ret

0000000080000f82 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f82:	7139                	addi	sp,sp,-64
    80000f84:	fc06                	sd	ra,56(sp)
    80000f86:	f822                	sd	s0,48(sp)
    80000f88:	f426                	sd	s1,40(sp)
    80000f8a:	f04a                	sd	s2,32(sp)
    80000f8c:	ec4e                	sd	s3,24(sp)
    80000f8e:	e852                	sd	s4,16(sp)
    80000f90:	e456                	sd	s5,8(sp)
    80000f92:	e05a                	sd	s6,0(sp)
    80000f94:	0080                	addi	s0,sp,64
    80000f96:	84aa                	mv	s1,a0
    80000f98:	89ae                	mv	s3,a1
    80000f9a:	8b32                	mv	s6,a2
  if (va >= MAXVA)
    80000f9c:	57fd                	li	a5,-1
    80000f9e:	83e9                	srli	a5,a5,0x1a
    80000fa0:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000fa2:	4ab1                	li	s5,12
  if (va >= MAXVA)
    80000fa4:	04b7e263          	bltu	a5,a1,80000fe8 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fa8:	0149d933          	srl	s2,s3,s4
    80000fac:	1ff97913          	andi	s2,s2,511
    80000fb0:	090e                	slli	s2,s2,0x3
    80000fb2:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000fb4:	00093483          	ld	s1,0(s2)
    80000fb8:	0014f793          	andi	a5,s1,1
    80000fbc:	cf85                	beqz	a5,80000ff4 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fbe:	80a9                	srli	s1,s1,0xa
    80000fc0:	04b2                	slli	s1,s1,0xc
  for (int level = 2; level > 0; level--) {
    80000fc2:	3a5d                	addiw	s4,s4,-9
    80000fc4:	ff5a12e3          	bne	s4,s5,80000fa8 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fc8:	00c9d513          	srli	a0,s3,0xc
    80000fcc:	1ff57513          	andi	a0,a0,511
    80000fd0:	050e                	slli	a0,a0,0x3
    80000fd2:	9526                	add	a0,a0,s1
}
    80000fd4:	70e2                	ld	ra,56(sp)
    80000fd6:	7442                	ld	s0,48(sp)
    80000fd8:	74a2                	ld	s1,40(sp)
    80000fda:	7902                	ld	s2,32(sp)
    80000fdc:	69e2                	ld	s3,24(sp)
    80000fde:	6a42                	ld	s4,16(sp)
    80000fe0:	6aa2                	ld	s5,8(sp)
    80000fe2:	6b02                	ld	s6,0(sp)
    80000fe4:	6121                	addi	sp,sp,64
    80000fe6:	8082                	ret
    panic("walk");
    80000fe8:	00007517          	auipc	a0,0x7
    80000fec:	0c850513          	addi	a0,a0,200 # 800080b0 <etext+0xb0>
    80000ff0:	845ff0ef          	jal	80000834 <panic>
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000ff4:	020b0263          	beqz	s6,80001018 <walk+0x96>
    80000ff8:	b57ff0ef          	jal	80000b4e <kalloc>
    80000ffc:	84aa                	mv	s1,a0
    80000ffe:	d979                	beqz	a0,80000fd4 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80001000:	6605                	lui	a2,0x1
    80001002:	4581                	li	a1,0
    80001004:	ce5ff0ef          	jal	80000ce8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
    80001016:	b775                	j	80000fc2 <walk+0x40>
        return 0;
    80001018:	4501                	li	a0,0
    8000101a:	bf6d                	j	80000fd4 <walk+0x52>

000000008000101c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    8000101c:	57fd                	li	a5,-1
    8000101e:	83e9                	srli	a5,a5,0x1a
    80001020:	00b7f463          	bgeu	a5,a1,80001028 <walkaddr+0xc>
    return 0;
    80001024:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001026:	8082                	ret
{
    80001028:	1141                	addi	sp,sp,-16
    8000102a:	e406                	sd	ra,8(sp)
    8000102c:	e022                	sd	s0,0(sp)
    8000102e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001030:	4601                	li	a2,0
    80001032:	f51ff0ef          	jal	80000f82 <walk>
  if (pte == 0)
    80001036:	c901                	beqz	a0,80001046 <walkaddr+0x2a>
  if ((*pte & PTE_V) == 0)
    80001038:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    8000103a:	0117f693          	andi	a3,a5,17
    8000103e:	4745                	li	a4,17
    return 0;
    80001040:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80001042:	00e68663          	beq	a3,a4,8000104e <walkaddr+0x32>
}
    80001046:	60a2                	ld	ra,8(sp)
    80001048:	6402                	ld	s0,0(sp)
    8000104a:	0141                	addi	sp,sp,16
    8000104c:	8082                	ret
  pa = PTE2PA(*pte);
    8000104e:	83a9                	srli	a5,a5,0xa
    80001050:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001054:	bfcd                	j	80001046 <walkaddr+0x2a>

0000000080001056 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001056:	715d                	addi	sp,sp,-80
    80001058:	e486                	sd	ra,72(sp)
    8000105a:	e0a2                	sd	s0,64(sp)
    8000105c:	fc26                	sd	s1,56(sp)
    8000105e:	f84a                	sd	s2,48(sp)
    80001060:	f44e                	sd	s3,40(sp)
    80001062:	f052                	sd	s4,32(sp)
    80001064:	ec56                	sd	s5,24(sp)
    80001066:	e85a                	sd	s6,16(sp)
    80001068:	e45e                	sd	s7,8(sp)
    8000106a:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    8000106c:	03459793          	slli	a5,a1,0x34
    80001070:	eba1                	bnez	a5,800010c0 <mappages+0x6a>
    80001072:	8a2a                	mv	s4,a0
    80001074:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80001076:	03461793          	slli	a5,a2,0x34
    8000107a:	eba9                	bnez	a5,800010cc <mappages+0x76>
    panic("mappages: size not aligned");

  if (size == 0)
    8000107c:	ce31                	beqz	a2,800010d8 <mappages+0x82>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    8000107e:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    80001082:	80060613          	addi	a2,a2,-2048
    80001086:	00b60933          	add	s2,a2,a1
  a = va;
    8000108a:	84ae                	mv	s1,a1
  for (;;) {
    if ((pte = walk(pagetable, a, 1)) == 0)
    8000108c:	4b05                	li	s6,1
    8000108e:	40b689b3          	sub	s3,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    80001092:	6b85                	lui	s7,0x1
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001094:	865a                	mv	a2,s6
    80001096:	85a6                	mv	a1,s1
    80001098:	8552                	mv	a0,s4
    8000109a:	ee9ff0ef          	jal	80000f82 <walk>
    8000109e:	c929                	beqz	a0,800010f0 <mappages+0x9a>
    if (*pte & PTE_V)
    800010a0:	611c                	ld	a5,0(a0)
    800010a2:	8b85                	andi	a5,a5,1
    800010a4:	e3a1                	bnez	a5,800010e4 <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010a6:	013487b3          	add	a5,s1,s3
    800010aa:	83b1                	srli	a5,a5,0xc
    800010ac:	07aa                	slli	a5,a5,0xa
    800010ae:	0157e7b3          	or	a5,a5,s5
    800010b2:	0017e793          	ori	a5,a5,1
    800010b6:	e11c                	sd	a5,0(a0)
    if (a == last)
    800010b8:	05248863          	beq	s1,s2,80001108 <mappages+0xb2>
    a += PGSIZE;
    800010bc:	94de                	add	s1,s1,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010be:	bfd9                	j	80001094 <mappages+0x3e>
    panic("mappages: va not aligned");
    800010c0:	00007517          	auipc	a0,0x7
    800010c4:	ff850513          	addi	a0,a0,-8 # 800080b8 <etext+0xb8>
    800010c8:	f6cff0ef          	jal	80000834 <panic>
    panic("mappages: size not aligned");
    800010cc:	00007517          	auipc	a0,0x7
    800010d0:	00c50513          	addi	a0,a0,12 # 800080d8 <etext+0xd8>
    800010d4:	f60ff0ef          	jal	80000834 <panic>
    panic("mappages: size");
    800010d8:	00007517          	auipc	a0,0x7
    800010dc:	02050513          	addi	a0,a0,32 # 800080f8 <etext+0xf8>
    800010e0:	f54ff0ef          	jal	80000834 <panic>
      panic("mappages: remap");
    800010e4:	00007517          	auipc	a0,0x7
    800010e8:	02450513          	addi	a0,a0,36 # 80008108 <etext+0x108>
    800010ec:	f48ff0ef          	jal	80000834 <panic>
      return -1;
    800010f0:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010f2:	60a6                	ld	ra,72(sp)
    800010f4:	6406                	ld	s0,64(sp)
    800010f6:	74e2                	ld	s1,56(sp)
    800010f8:	7942                	ld	s2,48(sp)
    800010fa:	79a2                	ld	s3,40(sp)
    800010fc:	7a02                	ld	s4,32(sp)
    800010fe:	6ae2                	ld	s5,24(sp)
    80001100:	6b42                	ld	s6,16(sp)
    80001102:	6ba2                	ld	s7,8(sp)
    80001104:	6161                	addi	sp,sp,80
    80001106:	8082                	ret
  return 0;
    80001108:	4501                	li	a0,0
    8000110a:	b7e5                	j	800010f2 <mappages+0x9c>

000000008000110c <kvmmap>:
{
    8000110c:	1141                	addi	sp,sp,-16
    8000110e:	e406                	sd	ra,8(sp)
    80001110:	e022                	sd	s0,0(sp)
    80001112:	0800                	addi	s0,sp,16
    80001114:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001116:	86b2                	mv	a3,a2
    80001118:	863e                	mv	a2,a5
    8000111a:	f3dff0ef          	jal	80001056 <mappages>
    8000111e:	e509                	bnez	a0,80001128 <kvmmap+0x1c>
}
    80001120:	60a2                	ld	ra,8(sp)
    80001122:	6402                	ld	s0,0(sp)
    80001124:	0141                	addi	sp,sp,16
    80001126:	8082                	ret
    panic("kvmmap");
    80001128:	00007517          	auipc	a0,0x7
    8000112c:	ff050513          	addi	a0,a0,-16 # 80008118 <etext+0x118>
    80001130:	f04ff0ef          	jal	80000834 <panic>

0000000080001134 <kvmmake>:
{
    80001134:	1101                	addi	sp,sp,-32
    80001136:	ec06                	sd	ra,24(sp)
    80001138:	e822                	sd	s0,16(sp)
    8000113a:	e426                	sd	s1,8(sp)
    8000113c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    8000113e:	a11ff0ef          	jal	80000b4e <kalloc>
    80001142:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001144:	6605                	lui	a2,0x1
    80001146:	4581                	li	a1,0
    80001148:	ba1ff0ef          	jal	80000ce8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000114c:	4719                	li	a4,6
    8000114e:	6685                	lui	a3,0x1
    80001150:	10000637          	lui	a2,0x10000
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	fb5ff0ef          	jal	8000110c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000115c:	4719                	li	a4,6
    8000115e:	6685                	lui	a3,0x1
    80001160:	10001637          	lui	a2,0x10001
    80001164:	85b2                	mv	a1,a2
    80001166:	8526                	mv	a0,s1
    80001168:	fa5ff0ef          	jal	8000110c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000116c:	4719                	li	a4,6
    8000116e:	040006b7          	lui	a3,0x4000
    80001172:	0c000637          	lui	a2,0xc000
    80001176:	85b2                	mv	a1,a2
    80001178:	8526                	mv	a0,s1
    8000117a:	f93ff0ef          	jal	8000110c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    8000117e:	4729                	li	a4,10
    80001180:	80007697          	auipc	a3,0x80007
    80001184:	e8068693          	addi	a3,a3,-384 # 8000 <_entry-0x7fff8000>
    80001188:	4605                	li	a2,1
    8000118a:	067e                	slli	a2,a2,0x1f
    8000118c:	85b2                	mv	a1,a2
    8000118e:	8526                	mv	a0,s1
    80001190:	f7dff0ef          	jal	8000110c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    80001194:	4719                	li	a4,6
    80001196:	00007697          	auipc	a3,0x7
    8000119a:	e6a68693          	addi	a3,a3,-406 # 80008000 <etext>
    8000119e:	47c5                	li	a5,17
    800011a0:	07ee                	slli	a5,a5,0x1b
    800011a2:	40d786b3          	sub	a3,a5,a3
    800011a6:	00007617          	auipc	a2,0x7
    800011aa:	e5a60613          	addi	a2,a2,-422 # 80008000 <etext>
    800011ae:	85b2                	mv	a1,a2
    800011b0:	8526                	mv	a0,s1
    800011b2:	f5bff0ef          	jal	8000110c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011b6:	4729                	li	a4,10
    800011b8:	6685                	lui	a3,0x1
    800011ba:	00006617          	auipc	a2,0x6
    800011be:	e4660613          	addi	a2,a2,-442 # 80007000 <_trampoline>
    800011c2:	040005b7          	lui	a1,0x4000
    800011c6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011c8:	05b2                	slli	a1,a1,0xc
    800011ca:	8526                	mv	a0,s1
    800011cc:	f41ff0ef          	jal	8000110c <kvmmap>
  proc_mapstacks(kpgtbl);
    800011d0:	8526                	mv	a0,s1
    800011d2:	5ec000ef          	jal	800017be <proc_mapstacks>
}
    800011d6:	8526                	mv	a0,s1
    800011d8:	60e2                	ld	ra,24(sp)
    800011da:	6442                	ld	s0,16(sp)
    800011dc:	64a2                	ld	s1,8(sp)
    800011de:	6105                	addi	sp,sp,32
    800011e0:	8082                	ret

00000000800011e2 <kvminit>:
{
    800011e2:	1141                	addi	sp,sp,-16
    800011e4:	e406                	sd	ra,8(sp)
    800011e6:	e022                	sd	s0,0(sp)
    800011e8:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011ea:	f4bff0ef          	jal	80001134 <kvmmake>
    800011ee:	0000a797          	auipc	a5,0xa
    800011f2:	34a7bd23          	sd	a0,858(a5) # 8000b548 <kernel_pagetable>
}
    800011f6:	60a2                	ld	ra,8(sp)
    800011f8:	6402                	ld	s0,0(sp)
    800011fa:	0141                	addi	sp,sp,16
    800011fc:	8082                	ret

00000000800011fe <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800011fe:	1101                	addi	sp,sp,-32
    80001200:	ec06                	sd	ra,24(sp)
    80001202:	e822                	sd	s0,16(sp)
    80001204:	e426                	sd	s1,8(sp)
    80001206:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80001208:	947ff0ef          	jal	80000b4e <kalloc>
    8000120c:	84aa                	mv	s1,a0
  if (pagetable == 0)
    8000120e:	c509                	beqz	a0,80001218 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001210:	6605                	lui	a2,0x1
    80001212:	4581                	li	a1,0
    80001214:	ad5ff0ef          	jal	80000ce8 <memset>
  return pagetable;
}
    80001218:	8526                	mv	a0,s1
    8000121a:	60e2                	ld	ra,24(sp)
    8000121c:	6442                	ld	s0,16(sp)
    8000121e:	64a2                	ld	s1,8(sp)
    80001220:	6105                	addi	sp,sp,32
    80001222:	8082                	ret

0000000080001224 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001224:	7139                	addi	sp,sp,-64
    80001226:	fc06                	sd	ra,56(sp)
    80001228:	f822                	sd	s0,48(sp)
    8000122a:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    8000122c:	03459793          	slli	a5,a1,0x34
    80001230:	e38d                	bnez	a5,80001252 <uvmunmap+0x2e>
    80001232:	f04a                	sd	s2,32(sp)
    80001234:	ec4e                	sd	s3,24(sp)
    80001236:	e852                	sd	s4,16(sp)
    80001238:	e456                	sd	s5,8(sp)
    8000123a:	e05a                	sd	s6,0(sp)
    8000123c:	8a2a                	mv	s4,a0
    8000123e:	892e                	mv	s2,a1
    80001240:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    80001242:	0632                	slli	a2,a2,0xc
    80001244:	00b609b3          	add	s3,a2,a1
    80001248:	6b05                	lui	s6,0x1
    8000124a:	0535f963          	bgeu	a1,s3,8000129c <uvmunmap+0x78>
    8000124e:	f426                	sd	s1,40(sp)
    80001250:	a015                	j	80001274 <uvmunmap+0x50>
    80001252:	f426                	sd	s1,40(sp)
    80001254:	f04a                	sd	s2,32(sp)
    80001256:	ec4e                	sd	s3,24(sp)
    80001258:	e852                	sd	s4,16(sp)
    8000125a:	e456                	sd	s5,8(sp)
    8000125c:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000125e:	00007517          	auipc	a0,0x7
    80001262:	ec250513          	addi	a0,a0,-318 # 80008120 <etext+0x120>
    80001266:	dceff0ef          	jal	80000834 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    8000126a:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    8000126e:	995a                	add	s2,s2,s6
    80001270:	03397563          	bgeu	s2,s3,8000129a <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001274:	4601                	li	a2,0
    80001276:	85ca                	mv	a1,s2
    80001278:	8552                	mv	a0,s4
    8000127a:	d09ff0ef          	jal	80000f82 <walk>
    8000127e:	84aa                	mv	s1,a0
    80001280:	d57d                	beqz	a0,8000126e <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    80001282:	611c                	ld	a5,0(a0)
    80001284:	0017f713          	andi	a4,a5,1
    80001288:	d37d                	beqz	a4,8000126e <uvmunmap+0x4a>
    if (do_free) {
    8000128a:	fe0a80e3          	beqz	s5,8000126a <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    8000128e:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    80001290:	00c79513          	slli	a0,a5,0xc
    80001294:	fd2ff0ef          	jal	80000a66 <kfree>
    80001298:	bfc9                	j	8000126a <uvmunmap+0x46>
    8000129a:	74a2                	ld	s1,40(sp)
    8000129c:	7902                	ld	s2,32(sp)
    8000129e:	69e2                	ld	s3,24(sp)
    800012a0:	6a42                	ld	s4,16(sp)
    800012a2:	6aa2                	ld	s5,8(sp)
    800012a4:	6b02                	ld	s6,0(sp)
  }
}
    800012a6:	70e2                	ld	ra,56(sp)
    800012a8:	7442                	ld	s0,48(sp)
    800012aa:	6121                	addi	sp,sp,64
    800012ac:	8082                	ret

00000000800012ae <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012ae:	1101                	addi	sp,sp,-32
    800012b0:	ec06                	sd	ra,24(sp)
    800012b2:	e822                	sd	s0,16(sp)
    800012b4:	e426                	sd	s1,8(sp)
    800012b6:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    800012b8:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    800012ba:	00b67d63          	bgeu	a2,a1,800012d4 <uvmdealloc+0x26>
    800012be:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    800012c0:	6785                	lui	a5,0x1
    800012c2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012c4:	00f60733          	add	a4,a2,a5
    800012c8:	76fd                	lui	a3,0xfffff
    800012ca:	8f75                	and	a4,a4,a3
    800012cc:	97ae                	add	a5,a5,a1
    800012ce:	8ff5                	and	a5,a5,a3
    800012d0:	00f76863          	bltu	a4,a5,800012e0 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012d4:	8526                	mv	a0,s1
    800012d6:	60e2                	ld	ra,24(sp)
    800012d8:	6442                	ld	s0,16(sp)
    800012da:	64a2                	ld	s1,8(sp)
    800012dc:	6105                	addi	sp,sp,32
    800012de:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012e0:	8f99                	sub	a5,a5,a4
    800012e2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012e4:	4685                	li	a3,1
    800012e6:	0007861b          	sext.w	a2,a5
    800012ea:	85ba                	mv	a1,a4
    800012ec:	f39ff0ef          	jal	80001224 <uvmunmap>
    800012f0:	b7d5                	j	800012d4 <uvmdealloc+0x26>

00000000800012f2 <uvmalloc>:
  if (newsz < oldsz)
    800012f2:	0ab66163          	bltu	a2,a1,80001394 <uvmalloc+0xa2>
{
    800012f6:	715d                	addi	sp,sp,-80
    800012f8:	e486                	sd	ra,72(sp)
    800012fa:	e0a2                	sd	s0,64(sp)
    800012fc:	f84a                	sd	s2,48(sp)
    800012fe:	f052                	sd	s4,32(sp)
    80001300:	ec56                	sd	s5,24(sp)
    80001302:	e45e                	sd	s7,8(sp)
    80001304:	0880                	addi	s0,sp,80
    80001306:	8aaa                	mv	s5,a0
    80001308:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000130a:	6785                	lui	a5,0x1
    8000130c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000130e:	95be                	add	a1,a1,a5
    80001310:	77fd                	lui	a5,0xfffff
    80001312:	00f5f933          	and	s2,a1,a5
    80001316:	8bca                	mv	s7,s2
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001318:	08c97063          	bgeu	s2,a2,80001398 <uvmalloc+0xa6>
    8000131c:	fc26                	sd	s1,56(sp)
    8000131e:	f44e                	sd	s3,40(sp)
    80001320:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    80001322:	6985                	lui	s3,0x1
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001324:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001328:	827ff0ef          	jal	80000b4e <kalloc>
    8000132c:	84aa                	mv	s1,a0
    if (mem == 0) {
    8000132e:	c50d                	beqz	a0,80001358 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    80001330:	864e                	mv	a2,s3
    80001332:	4581                	li	a1,0
    80001334:	9b5ff0ef          	jal	80000ce8 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001338:	875a                	mv	a4,s6
    8000133a:	86a6                	mv	a3,s1
    8000133c:	864e                	mv	a2,s3
    8000133e:	85ca                	mv	a1,s2
    80001340:	8556                	mv	a0,s5
    80001342:	d15ff0ef          	jal	80001056 <mappages>
    80001346:	e915                	bnez	a0,8000137a <uvmalloc+0x88>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001348:	994e                	add	s2,s2,s3
    8000134a:	fd496fe3          	bltu	s2,s4,80001328 <uvmalloc+0x36>
  return newsz;
    8000134e:	8552                	mv	a0,s4
    80001350:	74e2                	ld	s1,56(sp)
    80001352:	79a2                	ld	s3,40(sp)
    80001354:	6b42                	ld	s6,16(sp)
    80001356:	a811                	j	8000136a <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001358:	865e                	mv	a2,s7
    8000135a:	85ca                	mv	a1,s2
    8000135c:	8556                	mv	a0,s5
    8000135e:	f51ff0ef          	jal	800012ae <uvmdealloc>
      return 0;
    80001362:	4501                	li	a0,0
    80001364:	74e2                	ld	s1,56(sp)
    80001366:	79a2                	ld	s3,40(sp)
    80001368:	6b42                	ld	s6,16(sp)
}
    8000136a:	60a6                	ld	ra,72(sp)
    8000136c:	6406                	ld	s0,64(sp)
    8000136e:	7942                	ld	s2,48(sp)
    80001370:	7a02                	ld	s4,32(sp)
    80001372:	6ae2                	ld	s5,24(sp)
    80001374:	6ba2                	ld	s7,8(sp)
    80001376:	6161                	addi	sp,sp,80
    80001378:	8082                	ret
      kfree(mem);
    8000137a:	8526                	mv	a0,s1
    8000137c:	eeaff0ef          	jal	80000a66 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001380:	865e                	mv	a2,s7
    80001382:	85ca                	mv	a1,s2
    80001384:	8556                	mv	a0,s5
    80001386:	f29ff0ef          	jal	800012ae <uvmdealloc>
      return 0;
    8000138a:	4501                	li	a0,0
    8000138c:	74e2                	ld	s1,56(sp)
    8000138e:	79a2                	ld	s3,40(sp)
    80001390:	6b42                	ld	s6,16(sp)
    80001392:	bfe1                	j	8000136a <uvmalloc+0x78>
    return oldsz;
    80001394:	852e                	mv	a0,a1
}
    80001396:	8082                	ret
  return newsz;
    80001398:	8532                	mv	a0,a2
    8000139a:	bfc1                	j	8000136a <uvmalloc+0x78>

000000008000139c <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000139c:	7179                	addi	sp,sp,-48
    8000139e:	f406                	sd	ra,40(sp)
    800013a0:	f022                	sd	s0,32(sp)
    800013a2:	ec26                	sd	s1,24(sp)
    800013a4:	e84a                	sd	s2,16(sp)
    800013a6:	e44e                	sd	s3,8(sp)
    800013a8:	1800                	addi	s0,sp,48
    800013aa:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    800013ac:	84aa                	mv	s1,a0
    800013ae:	6905                	lui	s2,0x1
    800013b0:	992a                	add	s2,s2,a0
    800013b2:	a811                	j	800013c6 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if (pte & PTE_V) {
      panic("freewalk: leaf");
    800013b4:	00007517          	auipc	a0,0x7
    800013b8:	d8450513          	addi	a0,a0,-636 # 80008138 <etext+0x138>
    800013bc:	c78ff0ef          	jal	80000834 <panic>
  for (int i = 0; i < 512; i++) {
    800013c0:	04a1                	addi	s1,s1,8
    800013c2:	03248163          	beq	s1,s2,800013e4 <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013c6:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013c8:	0017f713          	andi	a4,a5,1
    800013cc:	db75                	beqz	a4,800013c0 <freewalk+0x24>
    800013ce:	00e7f713          	andi	a4,a5,14
    800013d2:	f36d                	bnez	a4,800013b4 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800013d4:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013d6:	00c79513          	slli	a0,a5,0xc
    800013da:	fc3ff0ef          	jal	8000139c <freewalk>
      pagetable[i] = 0;
    800013de:	0004b023          	sd	zero,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013e2:	bff9                	j	800013c0 <freewalk+0x24>
    }
  }
  kfree((void *)pagetable);
    800013e4:	854e                	mv	a0,s3
    800013e6:	e80ff0ef          	jal	80000a66 <kfree>
}
    800013ea:	70a2                	ld	ra,40(sp)
    800013ec:	7402                	ld	s0,32(sp)
    800013ee:	64e2                	ld	s1,24(sp)
    800013f0:	6942                	ld	s2,16(sp)
    800013f2:	69a2                	ld	s3,8(sp)
    800013f4:	6145                	addi	sp,sp,48
    800013f6:	8082                	ret

00000000800013f8 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013f8:	1101                	addi	sp,sp,-32
    800013fa:	ec06                	sd	ra,24(sp)
    800013fc:	e822                	sd	s0,16(sp)
    800013fe:	e426                	sd	s1,8(sp)
    80001400:	1000                	addi	s0,sp,32
    80001402:	84aa                	mv	s1,a0
  if (sz > 0)
    80001404:	e989                	bnez	a1,80001416 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80001406:	8526                	mv	a0,s1
    80001408:	f95ff0ef          	jal	8000139c <freewalk>
}
    8000140c:	60e2                	ld	ra,24(sp)
    8000140e:	6442                	ld	s0,16(sp)
    80001410:	64a2                	ld	s1,8(sp)
    80001412:	6105                	addi	sp,sp,32
    80001414:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001416:	6785                	lui	a5,0x1
    80001418:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000141a:	95be                	add	a1,a1,a5
    8000141c:	4685                	li	a3,1
    8000141e:	00c5d613          	srli	a2,a1,0xc
    80001422:	4581                	li	a1,0
    80001424:	e01ff0ef          	jal	80001224 <uvmunmap>
    80001428:	bff9                	j	80001406 <uvmfree+0xe>

000000008000142a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    8000142a:	ca59                	beqz	a2,800014c0 <uvmcopy+0x96>
{
    8000142c:	715d                	addi	sp,sp,-80
    8000142e:	e486                	sd	ra,72(sp)
    80001430:	e0a2                	sd	s0,64(sp)
    80001432:	fc26                	sd	s1,56(sp)
    80001434:	f84a                	sd	s2,48(sp)
    80001436:	f44e                	sd	s3,40(sp)
    80001438:	f052                	sd	s4,32(sp)
    8000143a:	ec56                	sd	s5,24(sp)
    8000143c:	e85a                	sd	s6,16(sp)
    8000143e:	e45e                	sd	s7,8(sp)
    80001440:	0880                	addi	s0,sp,80
    80001442:	8b2a                	mv	s6,a0
    80001444:	8bae                	mv	s7,a1
    80001446:	8ab2                	mv	s5,a2
  for (i = 0; i < sz; i += PGSIZE) {
    80001448:	4481                	li	s1,0
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if ((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    8000144a:	6a05                	lui	s4,0x1
    8000144c:	a021                	j	80001454 <uvmcopy+0x2a>
  for (i = 0; i < sz; i += PGSIZE) {
    8000144e:	94d2                	add	s1,s1,s4
    80001450:	0554fc63          	bgeu	s1,s5,800014a8 <uvmcopy+0x7e>
    if ((pte = walk(old, i, 0)) == 0)
    80001454:	4601                	li	a2,0
    80001456:	85a6                	mv	a1,s1
    80001458:	855a                	mv	a0,s6
    8000145a:	b29ff0ef          	jal	80000f82 <walk>
    8000145e:	d965                	beqz	a0,8000144e <uvmcopy+0x24>
    if ((*pte & PTE_V) == 0)
    80001460:	00053983          	ld	s3,0(a0)
    80001464:	0019f793          	andi	a5,s3,1
    80001468:	d3fd                	beqz	a5,8000144e <uvmcopy+0x24>
    if ((mem = kalloc()) == 0)
    8000146a:	ee4ff0ef          	jal	80000b4e <kalloc>
    8000146e:	892a                	mv	s2,a0
    80001470:	c11d                	beqz	a0,80001496 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    80001472:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char *)pa, PGSIZE);
    80001476:	8652                	mv	a2,s4
    80001478:	05b2                	slli	a1,a1,0xc
    8000147a:	8cfff0ef          	jal	80000d48 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    8000147e:	3ff9f713          	andi	a4,s3,1023
    80001482:	86ca                	mv	a3,s2
    80001484:	8652                	mv	a2,s4
    80001486:	85a6                	mv	a1,s1
    80001488:	855e                	mv	a0,s7
    8000148a:	bcdff0ef          	jal	80001056 <mappages>
    8000148e:	d161                	beqz	a0,8000144e <uvmcopy+0x24>
      kfree(mem);
    80001490:	854a                	mv	a0,s2
    80001492:	dd4ff0ef          	jal	80000a66 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001496:	4685                	li	a3,1
    80001498:	00c4d613          	srli	a2,s1,0xc
    8000149c:	4581                	li	a1,0
    8000149e:	855e                	mv	a0,s7
    800014a0:	d85ff0ef          	jal	80001224 <uvmunmap>
  return -1;
    800014a4:	557d                	li	a0,-1
    800014a6:	a011                	j	800014aa <uvmcopy+0x80>
  return 0;
    800014a8:	4501                	li	a0,0
}
    800014aa:	60a6                	ld	ra,72(sp)
    800014ac:	6406                	ld	s0,64(sp)
    800014ae:	74e2                	ld	s1,56(sp)
    800014b0:	7942                	ld	s2,48(sp)
    800014b2:	79a2                	ld	s3,40(sp)
    800014b4:	7a02                	ld	s4,32(sp)
    800014b6:	6ae2                	ld	s5,24(sp)
    800014b8:	6b42                	ld	s6,16(sp)
    800014ba:	6ba2                	ld	s7,8(sp)
    800014bc:	6161                	addi	sp,sp,80
    800014be:	8082                	ret
  return 0;
    800014c0:	4501                	li	a0,0
}
    800014c2:	8082                	ret

00000000800014c4 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014c4:	1141                	addi	sp,sp,-16
    800014c6:	e406                	sd	ra,8(sp)
    800014c8:	e022                	sd	s0,0(sp)
    800014ca:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    800014cc:	4601                	li	a2,0
    800014ce:	ab5ff0ef          	jal	80000f82 <walk>
  if (pte == 0)
    800014d2:	c901                	beqz	a0,800014e2 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014d4:	611c                	ld	a5,0(a0)
    800014d6:	9bbd                	andi	a5,a5,-17
    800014d8:	e11c                	sd	a5,0(a0)
}
    800014da:	60a2                	ld	ra,8(sp)
    800014dc:	6402                	ld	s0,0(sp)
    800014de:	0141                	addi	sp,sp,16
    800014e0:	8082                	ret
    panic("uvmclear");
    800014e2:	00007517          	auipc	a0,0x7
    800014e6:	c6650513          	addi	a0,a0,-922 # 80008148 <etext+0x148>
    800014ea:	b4aff0ef          	jal	80000834 <panic>

00000000800014ee <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800014ee:	1141                	addi	sp,sp,-16
    800014f0:	e406                	sd	ra,8(sp)
    800014f2:	e022                	sd	s0,0(sp)
    800014f4:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800014f6:	4601                	li	a2,0
    800014f8:	a8bff0ef          	jal	80000f82 <walk>
  if (pte == 0) {
    800014fc:	c119                	beqz	a0,80001502 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V) {
    800014fe:	6108                	ld	a0,0(a0)
    80001500:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001502:	60a2                	ld	ra,8(sp)
    80001504:	6402                	ld	s0,0(sp)
    80001506:	0141                	addi	sp,sp,16
    80001508:	8082                	ret

000000008000150a <vmfault>:
{
    8000150a:	7179                	addi	sp,sp,-48
    8000150c:	f406                	sd	ra,40(sp)
    8000150e:	f022                	sd	s0,32(sp)
    80001510:	e052                	sd	s4,0(sp)
    80001512:	1800                	addi	s0,sp,48
    return 0;
    80001514:	4a01                	li	s4,0
  if (va >= psz)
    80001516:	00b66863          	bltu	a2,a1,80001526 <vmfault+0x1c>
}
    8000151a:	8552                	mv	a0,s4
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	6a02                	ld	s4,0(sp)
    80001522:	6145                	addi	sp,sp,48
    80001524:	8082                	ret
    80001526:	ec26                	sd	s1,24(sp)
    80001528:	e44e                	sd	s3,8(sp)
    8000152a:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    8000152c:	77fd                	lui	a5,0xfffff
    8000152e:	00f679b3          	and	s3,a2,a5
  if (ismapped(pagetable, va)) {
    80001532:	85ce                	mv	a1,s3
    80001534:	fbbff0ef          	jal	800014ee <ismapped>
    return 0;
    80001538:	4a01                	li	s4,0
  if (ismapped(pagetable, va)) {
    8000153a:	c501                	beqz	a0,80001542 <vmfault+0x38>
    8000153c:	64e2                	ld	s1,24(sp)
    8000153e:	69a2                	ld	s3,8(sp)
    80001540:	bfe9                	j	8000151a <vmfault+0x10>
    80001542:	e84a                	sd	s2,16(sp)
  mem = (uint64)kalloc();
    80001544:	e0aff0ef          	jal	80000b4e <kalloc>
    80001548:	892a                	mv	s2,a0
  if (mem == 0)
    8000154a:	c915                	beqz	a0,8000157e <vmfault+0x74>
  mem = (uint64)kalloc();
    8000154c:	8a2a                	mv	s4,a0
  memset((void *)mem, 0, PGSIZE);
    8000154e:	6605                	lui	a2,0x1
    80001550:	4581                	li	a1,0
    80001552:	f96ff0ef          	jal	80000ce8 <memset>
  if (mappages(pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    80001556:	4759                	li	a4,22
    80001558:	86ca                	mv	a3,s2
    8000155a:	6605                	lui	a2,0x1
    8000155c:	85ce                	mv	a1,s3
    8000155e:	8526                	mv	a0,s1
    80001560:	af7ff0ef          	jal	80001056 <mappages>
    80001564:	e509                	bnez	a0,8000156e <vmfault+0x64>
    80001566:	64e2                	ld	s1,24(sp)
    80001568:	6942                	ld	s2,16(sp)
    8000156a:	69a2                	ld	s3,8(sp)
    8000156c:	b77d                	j	8000151a <vmfault+0x10>
    kfree((void *)mem);
    8000156e:	854a                	mv	a0,s2
    80001570:	cf6ff0ef          	jal	80000a66 <kfree>
    return 0;
    80001574:	4a01                	li	s4,0
    80001576:	64e2                	ld	s1,24(sp)
    80001578:	6942                	ld	s2,16(sp)
    8000157a:	69a2                	ld	s3,8(sp)
    8000157c:	bf79                	j	8000151a <vmfault+0x10>
    8000157e:	64e2                	ld	s1,24(sp)
    80001580:	6942                	ld	s2,16(sp)
    80001582:	69a2                	ld	s3,8(sp)
    80001584:	bf59                	j	8000151a <vmfault+0x10>

0000000080001586 <copyout>:
  while (len > 0) {
    80001586:	cf49                	beqz	a4,80001620 <copyout+0x9a>
{
    80001588:	7159                	addi	sp,sp,-112
    8000158a:	f486                	sd	ra,104(sp)
    8000158c:	f0a2                	sd	s0,96(sp)
    8000158e:	eca6                	sd	s1,88(sp)
    80001590:	e8ca                	sd	s2,80(sp)
    80001592:	e4ce                	sd	s3,72(sp)
    80001594:	e0d2                	sd	s4,64(sp)
    80001596:	fc56                	sd	s5,56(sp)
    80001598:	f85a                	sd	s6,48(sp)
    8000159a:	f45e                	sd	s7,40(sp)
    8000159c:	f062                	sd	s8,32(sp)
    8000159e:	ec66                	sd	s9,24(sp)
    800015a0:	e86a                	sd	s10,16(sp)
    800015a2:	e46e                	sd	s11,8(sp)
    800015a4:	1880                	addi	s0,sp,112
    800015a6:	8baa                	mv	s7,a0
    800015a8:	8dae                	mv	s11,a1
    800015aa:	8a32                	mv	s4,a2
    800015ac:	8b36                	mv	s6,a3
    800015ae:	8aba                	mv	s5,a4
    va0 = PGROUNDDOWN(dstva);
    800015b0:	7d7d                	lui	s10,0xfffff
    if (va0 >= MAXVA)
    800015b2:	5cfd                	li	s9,-1
    800015b4:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    800015b8:	6c05                	lui	s8,0x1
    800015ba:	a005                	j	800015da <copyout+0x54>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015bc:	409a0533          	sub	a0,s4,s1
    800015c0:	0009061b          	sext.w	a2,s2
    800015c4:	85da                	mv	a1,s6
    800015c6:	954e                	add	a0,a0,s3
    800015c8:	f80ff0ef          	jal	80000d48 <memmove>
    len -= n;
    800015cc:	412a8ab3          	sub	s5,s5,s2
    src += n;
    800015d0:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    800015d2:	01848a33          	add	s4,s1,s8
  while (len > 0) {
    800015d6:	040a8363          	beqz	s5,8000161c <copyout+0x96>
    va0 = PGROUNDDOWN(dstva);
    800015da:	01aa74b3          	and	s1,s4,s10
    if (va0 >= MAXVA)
    800015de:	049ce363          	bltu	s9,s1,80001624 <copyout+0x9e>
    pa0 = walkaddr(pagetable, va0);
    800015e2:	85a6                	mv	a1,s1
    800015e4:	855e                	mv	a0,s7
    800015e6:	a37ff0ef          	jal	8000101c <walkaddr>
    800015ea:	89aa                	mv	s3,a0
    if (pa0 == 0) {
    800015ec:	e909                	bnez	a0,800015fe <copyout+0x78>
      if ((pa0 = vmfault(pagetable, psz, va0, 0)) == 0) {
    800015ee:	4681                	li	a3,0
    800015f0:	8626                	mv	a2,s1
    800015f2:	85ee                	mv	a1,s11
    800015f4:	855e                	mv	a0,s7
    800015f6:	f15ff0ef          	jal	8000150a <vmfault>
    800015fa:	89aa                	mv	s3,a0
    800015fc:	c521                	beqz	a0,80001644 <copyout+0xbe>
    pte = walk(pagetable, va0, 0);
    800015fe:	4601                	li	a2,0
    80001600:	85a6                	mv	a1,s1
    80001602:	855e                	mv	a0,s7
    80001604:	97fff0ef          	jal	80000f82 <walk>
    if ((*pte & PTE_W) == 0)
    80001608:	611c                	ld	a5,0(a0)
    8000160a:	8b91                	andi	a5,a5,4
    8000160c:	cf95                	beqz	a5,80001648 <copyout+0xc2>
    n = PGSIZE - (dstva - va0);
    8000160e:	41448933          	sub	s2,s1,s4
    80001612:	9962                	add	s2,s2,s8
    if (n > len)
    80001614:	fb2af4e3          	bgeu	s5,s2,800015bc <copyout+0x36>
    80001618:	8956                	mv	s2,s5
    8000161a:	b74d                	j	800015bc <copyout+0x36>
  return 0;
    8000161c:	4501                	li	a0,0
    8000161e:	a021                	j	80001626 <copyout+0xa0>
    80001620:	4501                	li	a0,0
}
    80001622:	8082                	ret
      return -1;
    80001624:	557d                	li	a0,-1
}
    80001626:	70a6                	ld	ra,104(sp)
    80001628:	7406                	ld	s0,96(sp)
    8000162a:	64e6                	ld	s1,88(sp)
    8000162c:	6946                	ld	s2,80(sp)
    8000162e:	69a6                	ld	s3,72(sp)
    80001630:	6a06                	ld	s4,64(sp)
    80001632:	7ae2                	ld	s5,56(sp)
    80001634:	7b42                	ld	s6,48(sp)
    80001636:	7ba2                	ld	s7,40(sp)
    80001638:	7c02                	ld	s8,32(sp)
    8000163a:	6ce2                	ld	s9,24(sp)
    8000163c:	6d42                	ld	s10,16(sp)
    8000163e:	6da2                	ld	s11,8(sp)
    80001640:	6165                	addi	sp,sp,112
    80001642:	8082                	ret
        return -1;
    80001644:	557d                	li	a0,-1
    80001646:	b7c5                	j	80001626 <copyout+0xa0>
      return -1;
    80001648:	557d                	li	a0,-1
    8000164a:	bff1                	j	80001626 <copyout+0xa0>

000000008000164c <copyin>:
  while (len > 0) {
    8000164c:	cf41                	beqz	a4,800016e4 <copyin+0x98>
{
    8000164e:	711d                	addi	sp,sp,-96
    80001650:	ec86                	sd	ra,88(sp)
    80001652:	e8a2                	sd	s0,80(sp)
    80001654:	e4a6                	sd	s1,72(sp)
    80001656:	e0ca                	sd	s2,64(sp)
    80001658:	fc4e                	sd	s3,56(sp)
    8000165a:	f852                	sd	s4,48(sp)
    8000165c:	f456                	sd	s5,40(sp)
    8000165e:	f05a                	sd	s6,32(sp)
    80001660:	ec5e                	sd	s7,24(sp)
    80001662:	e862                	sd	s8,16(sp)
    80001664:	e466                	sd	s9,8(sp)
    80001666:	e06a                	sd	s10,0(sp)
    80001668:	1080                	addi	s0,sp,96
    8000166a:	8baa                	mv	s7,a0
    8000166c:	8cae                	mv	s9,a1
    8000166e:	8ab2                	mv	s5,a2
    80001670:	8936                	mv	s2,a3
    80001672:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    80001674:	7c7d                	lui	s8,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001676:	4d05                	li	s10,1
    n = PGSIZE - (srcva - va0);
    80001678:	6b05                	lui	s6,0x1
    8000167a:	a035                	j	800016a6 <copyin+0x5a>
    8000167c:	412984b3          	sub	s1,s3,s2
    80001680:	94da                	add	s1,s1,s6
    if (n > len)
    80001682:	009a7363          	bgeu	s4,s1,80001688 <copyin+0x3c>
    80001686:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001688:	413905b3          	sub	a1,s2,s3
    8000168c:	0004861b          	sext.w	a2,s1
    80001690:	95aa                	add	a1,a1,a0
    80001692:	8556                	mv	a0,s5
    80001694:	eb4ff0ef          	jal	80000d48 <memmove>
    len -= n;
    80001698:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000169c:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000169e:	01698933          	add	s2,s3,s6
  while (len > 0) {
    800016a2:	020a0263          	beqz	s4,800016c6 <copyin+0x7a>
    va0 = PGROUNDDOWN(srcva);
    800016a6:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    800016aa:	85ce                	mv	a1,s3
    800016ac:	855e                	mv	a0,s7
    800016ae:	96fff0ef          	jal	8000101c <walkaddr>
    if (pa0 == 0) {
    800016b2:	f569                	bnez	a0,8000167c <copyin+0x30>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800016b4:	86ea                	mv	a3,s10
    800016b6:	864e                	mv	a2,s3
    800016b8:	85e6                	mv	a1,s9
    800016ba:	855e                	mv	a0,s7
    800016bc:	e4fff0ef          	jal	8000150a <vmfault>
    800016c0:	fd55                	bnez	a0,8000167c <copyin+0x30>
        return -1;
    800016c2:	557d                	li	a0,-1
    800016c4:	a011                	j	800016c8 <copyin+0x7c>
  return 0;
    800016c6:	4501                	li	a0,0
}
    800016c8:	60e6                	ld	ra,88(sp)
    800016ca:	6446                	ld	s0,80(sp)
    800016cc:	64a6                	ld	s1,72(sp)
    800016ce:	6906                	ld	s2,64(sp)
    800016d0:	79e2                	ld	s3,56(sp)
    800016d2:	7a42                	ld	s4,48(sp)
    800016d4:	7aa2                	ld	s5,40(sp)
    800016d6:	7b02                	ld	s6,32(sp)
    800016d8:	6be2                	ld	s7,24(sp)
    800016da:	6c42                	ld	s8,16(sp)
    800016dc:	6ca2                	ld	s9,8(sp)
    800016de:	6d02                	ld	s10,0(sp)
    800016e0:	6125                	addi	sp,sp,96
    800016e2:	8082                	ret
  return 0;
    800016e4:	4501                	li	a0,0
}
    800016e6:	8082                	ret

00000000800016e8 <copyinstr>:
  while (got_null == 0 && max > 0) {
    800016e8:	c769                	beqz	a4,800017b2 <copyinstr+0xca>
{
    800016ea:	711d                	addi	sp,sp,-96
    800016ec:	ec86                	sd	ra,88(sp)
    800016ee:	e8a2                	sd	s0,80(sp)
    800016f0:	e4a6                	sd	s1,72(sp)
    800016f2:	e0ca                	sd	s2,64(sp)
    800016f4:	fc4e                	sd	s3,56(sp)
    800016f6:	f852                	sd	s4,48(sp)
    800016f8:	f456                	sd	s5,40(sp)
    800016fa:	f05a                	sd	s6,32(sp)
    800016fc:	ec5e                	sd	s7,24(sp)
    800016fe:	e862                	sd	s8,16(sp)
    80001700:	e466                	sd	s9,8(sp)
    80001702:	1080                	addi	s0,sp,96
    80001704:	8b2a                	mv	s6,a0
    80001706:	8c2e                	mv	s8,a1
    80001708:	89b2                	mv	s3,a2
    8000170a:	84b6                	mv	s1,a3
    8000170c:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    8000170e:	7bfd                	lui	s7,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001710:	4c85                	li	s9,1
    n = PGSIZE - (srcva - va0);
    80001712:	6a85                	lui	s5,0x1
    80001714:	a881                	j	80001764 <copyinstr+0x7c>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001716:	86e6                	mv	a3,s9
    80001718:	864a                	mv	a2,s2
    8000171a:	85e2                	mv	a1,s8
    8000171c:	855a                	mv	a0,s6
    8000171e:	dedff0ef          	jal	8000150a <vmfault>
    80001722:	e921                	bnez	a0,80001772 <copyinstr+0x8a>
        return -1;
    80001724:	557d                	li	a0,-1
    80001726:	a801                	j	80001736 <copyinstr+0x4e>
        *dst = '\0';
    80001728:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffda398>
        got_null = 1;
    8000172c:	4785                	li	a5,1
  if (got_null) {
    8000172e:	0017c793          	xori	a5,a5,1
    80001732:	40f0053b          	negw	a0,a5
}
    80001736:	60e6                	ld	ra,88(sp)
    80001738:	6446                	ld	s0,80(sp)
    8000173a:	64a6                	ld	s1,72(sp)
    8000173c:	6906                	ld	s2,64(sp)
    8000173e:	79e2                	ld	s3,56(sp)
    80001740:	7a42                	ld	s4,48(sp)
    80001742:	7aa2                	ld	s5,40(sp)
    80001744:	7b02                	ld	s6,32(sp)
    80001746:	6be2                	ld	s7,24(sp)
    80001748:	6c42                	ld	s8,16(sp)
    8000174a:	6ca2                	ld	s9,8(sp)
    8000174c:	6125                	addi	sp,sp,96
    8000174e:	8082                	ret
    80001750:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80001754:	974e                	add	a4,a4,s3
      --max;
    80001756:	40b70a33          	sub	s4,a4,a1
    srcva = va0 + PGSIZE;
    8000175a:	015904b3          	add	s1,s2,s5
  while (got_null == 0 && max > 0) {
    8000175e:	04e58463          	beq	a1,a4,800017a6 <copyinstr+0xbe>
{
    80001762:	89be                	mv	s3,a5
    va0 = PGROUNDDOWN(srcva);
    80001764:	0174f933          	and	s2,s1,s7
    pa0 = walkaddr(pagetable, va0);
    80001768:	85ca                	mv	a1,s2
    8000176a:	855a                	mv	a0,s6
    8000176c:	8b1ff0ef          	jal	8000101c <walkaddr>
    if (pa0 == 0) {
    80001770:	d15d                	beqz	a0,80001716 <copyinstr+0x2e>
    n = PGSIZE - (srcva - va0);
    80001772:	40990633          	sub	a2,s2,s1
    80001776:	9656                	add	a2,a2,s5
    if (n > max)
    80001778:	00ca7363          	bgeu	s4,a2,8000177e <copyinstr+0x96>
    8000177c:	8652                	mv	a2,s4
    while (n > 0) {
    8000177e:	c615                	beqz	a2,800017aa <copyinstr+0xc2>
    char *p = (char *)(pa0 + (srcva - va0));
    80001780:	412484b3          	sub	s1,s1,s2
    80001784:	94aa                	add	s1,s1,a0
    80001786:	87ce                	mv	a5,s3
      if (*p == '\0') {
    80001788:	413484b3          	sub	s1,s1,s3
    while (n > 0) {
    8000178c:	964e                	add	a2,a2,s3
    8000178e:	85be                	mv	a1,a5
      if (*p == '\0') {
    80001790:	00f48733          	add	a4,s1,a5
    80001794:	00074683          	lbu	a3,0(a4)
    80001798:	dac1                	beqz	a3,80001728 <copyinstr+0x40>
        *dst = *p;
    8000179a:	00d78023          	sb	a3,0(a5)
      dst++;
    8000179e:	0785                	addi	a5,a5,1
    while (n > 0) {
    800017a0:	fec797e3          	bne	a5,a2,8000178e <copyinstr+0xa6>
    800017a4:	b775                	j	80001750 <copyinstr+0x68>
    800017a6:	4781                	li	a5,0
    800017a8:	b759                	j	8000172e <copyinstr+0x46>
    srcva = va0 + PGSIZE;
    800017aa:	6485                	lui	s1,0x1
    800017ac:	94ca                	add	s1,s1,s2
    800017ae:	87ce                	mv	a5,s3
    800017b0:	bf4d                	j	80001762 <copyinstr+0x7a>
  int got_null = 0;
    800017b2:	4781                	li	a5,0
  if (got_null) {
    800017b4:	0017c793          	xori	a5,a5,1
    800017b8:	40f0053b          	negw	a0,a5
}
    800017bc:	8082                	ret

00000000800017be <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017be:	715d                	addi	sp,sp,-80
    800017c0:	e486                	sd	ra,72(sp)
    800017c2:	e0a2                	sd	s0,64(sp)
    800017c4:	fc26                	sd	s1,56(sp)
    800017c6:	f84a                	sd	s2,48(sp)
    800017c8:	f44e                	sd	s3,40(sp)
    800017ca:	f052                	sd	s4,32(sp)
    800017cc:	ec56                	sd	s5,24(sp)
    800017ce:	e85a                	sd	s6,16(sp)
    800017d0:	e45e                	sd	s7,8(sp)
    800017d2:	e062                	sd	s8,0(sp)
    800017d4:	0880                	addi	s0,sp,80
    800017d6:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800017d8:	00012497          	auipc	s1,0x12
    800017dc:	2b048493          	addi	s1,s1,688 # 80013a88 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017e0:	8c26                	mv	s8,s1
    800017e2:	ff4df937          	lui	s2,0xff4df
    800017e6:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b9d55>
    800017ea:	0936                	slli	s2,s2,0xd
    800017ec:	6f590913          	addi	s2,s2,1781
    800017f0:	0936                	slli	s2,s2,0xd
    800017f2:	bd390913          	addi	s2,s2,-1069
    800017f6:	0932                	slli	s2,s2,0xc
    800017f8:	7a790913          	addi	s2,s2,1959
    800017fc:	040009b7          	lui	s3,0x4000
    80001800:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001802:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001804:	4b99                	li	s7,6
    80001806:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001808:	00018a97          	auipc	s5,0x18
    8000180c:	e80a8a93          	addi	s5,s5,-384 # 80019688 <tickslock>
    char *pa = kalloc();
    80001810:	b3eff0ef          	jal	80000b4e <kalloc>
    80001814:	862a                	mv	a2,a0
    if (pa == 0)
    80001816:	c121                	beqz	a0,80001856 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    80001818:	418485b3          	sub	a1,s1,s8
    8000181c:	8591                	srai	a1,a1,0x4
    8000181e:	032585b3          	mul	a1,a1,s2
    80001822:	05b6                	slli	a1,a1,0xd
    80001824:	6789                	lui	a5,0x2
    80001826:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001828:	875e                	mv	a4,s7
    8000182a:	86da                	mv	a3,s6
    8000182c:	40b985b3          	sub	a1,s3,a1
    80001830:	8552                	mv	a0,s4
    80001832:	8dbff0ef          	jal	8000110c <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001836:	17048493          	addi	s1,s1,368
    8000183a:	fd549be3          	bne	s1,s5,80001810 <proc_mapstacks+0x52>
  }
}
    8000183e:	60a6                	ld	ra,72(sp)
    80001840:	6406                	ld	s0,64(sp)
    80001842:	74e2                	ld	s1,56(sp)
    80001844:	7942                	ld	s2,48(sp)
    80001846:	79a2                	ld	s3,40(sp)
    80001848:	7a02                	ld	s4,32(sp)
    8000184a:	6ae2                	ld	s5,24(sp)
    8000184c:	6b42                	ld	s6,16(sp)
    8000184e:	6ba2                	ld	s7,8(sp)
    80001850:	6c02                	ld	s8,0(sp)
    80001852:	6161                	addi	sp,sp,80
    80001854:	8082                	ret
      panic("kalloc");
    80001856:	00007517          	auipc	a0,0x7
    8000185a:	90250513          	addi	a0,a0,-1790 # 80008158 <etext+0x158>
    8000185e:	fd7fe0ef          	jal	80000834 <panic>

0000000080001862 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001862:	7139                	addi	sp,sp,-64
    80001864:	fc06                	sd	ra,56(sp)
    80001866:	f822                	sd	s0,48(sp)
    80001868:	f426                	sd	s1,40(sp)
    8000186a:	f04a                	sd	s2,32(sp)
    8000186c:	ec4e                	sd	s3,24(sp)
    8000186e:	e852                	sd	s4,16(sp)
    80001870:	e456                	sd	s5,8(sp)
    80001872:	e05a                	sd	s6,0(sp)
    80001874:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001876:	00007597          	auipc	a1,0x7
    8000187a:	8ea58593          	addi	a1,a1,-1814 # 80008160 <etext+0x160>
    8000187e:	00012517          	auipc	a0,0x12
    80001882:	dda50513          	addi	a0,a0,-550 # 80013658 <pid_lock>
    80001886:	b22ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000188a:	00007597          	auipc	a1,0x7
    8000188e:	8de58593          	addi	a1,a1,-1826 # 80008168 <etext+0x168>
    80001892:	00012517          	auipc	a0,0x12
    80001896:	dde50513          	addi	a0,a0,-546 # 80013670 <wait_lock>
    8000189a:	b0eff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000189e:	00012497          	auipc	s1,0x12
    800018a2:	1ea48493          	addi	s1,s1,490 # 80013a88 <proc>
    initlock(&p->lock, "proc");
    800018a6:	00007b17          	auipc	s6,0x7
    800018aa:	8d2b0b13          	addi	s6,s6,-1838 # 80008178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018ae:	8aa6                	mv	s5,s1
    800018b0:	ff4df937          	lui	s2,0xff4df
    800018b4:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b9d55>
    800018b8:	0936                	slli	s2,s2,0xd
    800018ba:	6f590913          	addi	s2,s2,1781
    800018be:	0936                	slli	s2,s2,0xd
    800018c0:	bd390913          	addi	s2,s2,-1069
    800018c4:	0932                	slli	s2,s2,0xc
    800018c6:	7a790913          	addi	s2,s2,1959
    800018ca:	040009b7          	lui	s3,0x4000
    800018ce:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018d0:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    800018d2:	00018a17          	auipc	s4,0x18
    800018d6:	db6a0a13          	addi	s4,s4,-586 # 80019688 <tickslock>
    initlock(&p->lock, "proc");
    800018da:	85da                	mv	a1,s6
    800018dc:	8526                	mv	a0,s1
    800018de:	acaff0ef          	jal	80000ba8 <initlock>
    p->state = UNUSED;
    800018e2:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800018e6:	415487b3          	sub	a5,s1,s5
    800018ea:	8791                	srai	a5,a5,0x4
    800018ec:	032787b3          	mul	a5,a5,s2
    800018f0:	07b6                	slli	a5,a5,0xd
    800018f2:	6709                	lui	a4,0x2
    800018f4:	9fb9                	addw	a5,a5,a4
    800018f6:	40f987b3          	sub	a5,s3,a5
    800018fa:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    800018fc:	17048493          	addi	s1,s1,368
    80001900:	fd449de3          	bne	s1,s4,800018da <procinit+0x78>
  }
}
    80001904:	70e2                	ld	ra,56(sp)
    80001906:	7442                	ld	s0,48(sp)
    80001908:	74a2                	ld	s1,40(sp)
    8000190a:	7902                	ld	s2,32(sp)
    8000190c:	69e2                	ld	s3,24(sp)
    8000190e:	6a42                	ld	s4,16(sp)
    80001910:	6aa2                	ld	s5,8(sp)
    80001912:	6b02                	ld	s6,0(sp)
    80001914:	6121                	addi	sp,sp,64
    80001916:	8082                	ret

0000000080001918 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001918:	1141                	addi	sp,sp,-16
    8000191a:	e406                	sd	ra,8(sp)
    8000191c:	e022                	sd	s0,0(sp)
    8000191e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    80001920:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001922:	2501                	sext.w	a0,a0
    80001924:	60a2                	ld	ra,8(sp)
    80001926:	6402                	ld	s0,0(sp)
    80001928:	0141                	addi	sp,sp,16
    8000192a:	8082                	ret

000000008000192c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    8000192c:	1141                	addi	sp,sp,-16
    8000192e:	e406                	sd	ra,8(sp)
    80001930:	e022                	sd	s0,0(sp)
    80001932:	0800                	addi	s0,sp,16
    80001934:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001936:	2781                	sext.w	a5,a5
    80001938:	079e                	slli	a5,a5,0x7
  return c;
}
    8000193a:	00012517          	auipc	a0,0x12
    8000193e:	d4e50513          	addi	a0,a0,-690 # 80013688 <cpus>
    80001942:	953e                	add	a0,a0,a5
    80001944:	60a2                	ld	ra,8(sp)
    80001946:	6402                	ld	s0,0(sp)
    80001948:	0141                	addi	sp,sp,16
    8000194a:	8082                	ret

000000008000194c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    8000194c:	1101                	addi	sp,sp,-32
    8000194e:	ec06                	sd	ra,24(sp)
    80001950:	e822                	sd	s0,16(sp)
    80001952:	e426                	sd	s1,8(sp)
    80001954:	1000                	addi	s0,sp,32
  push_off();
    80001956:	a98ff0ef          	jal	80000bee <push_off>
    8000195a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    8000195c:	2781                	sext.w	a5,a5
    8000195e:	079e                	slli	a5,a5,0x7
    80001960:	00012717          	auipc	a4,0x12
    80001964:	cf870713          	addi	a4,a4,-776 # 80013658 <pid_lock>
    80001968:	97ba                	add	a5,a5,a4
    8000196a:	7b9c                	ld	a5,48(a5)
    8000196c:	84be                	mv	s1,a5
  pop_off();
    8000196e:	afaff0ef          	jal	80000c68 <pop_off>
  return p;
}
    80001972:	8526                	mv	a0,s1
    80001974:	60e2                	ld	ra,24(sp)
    80001976:	6442                	ld	s0,16(sp)
    80001978:	64a2                	ld	s1,8(sp)
    8000197a:	6105                	addi	sp,sp,32
    8000197c:	8082                	ret

000000008000197e <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000197e:	7179                	addi	sp,sp,-48
    80001980:	f406                	sd	ra,40(sp)
    80001982:	f022                	sd	s0,32(sp)
    80001984:	ec26                	sd	s1,24(sp)
    80001986:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001988:	fc5ff0ef          	jal	8000194c <myproc>
    8000198c:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    8000198e:	b22ff0ef          	jal	80000cb0 <release>

  if (first) {
    80001992:	0000a797          	auipc	a5,0xa
    80001996:	b6e7a783          	lw	a5,-1170(a5) # 8000b500 <first.1>
    8000199a:	cf85                	beqz	a5,800019d2 <forkret+0x54>
    first = 0;
    8000199c:	0000a797          	auipc	a5,0xa
    800019a0:	b607a223          	sw	zero,-1180(a5) # 8000b500 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019a4:	4505                	li	a0,1
    800019a6:	0da020ef          	jal	80003a80 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019aa:	00006797          	auipc	a5,0x6
    800019ae:	7d678793          	addi	a5,a5,2006 # 80008180 <etext+0x180>
    800019b2:	fcf43823          	sd	a5,-48(s0)
    800019b6:	fc043c23          	sd	zero,-40(s0)
    800019ba:	fd040593          	addi	a1,s0,-48
    800019be:	853e                	mv	a0,a5
    800019c0:	374030ef          	jal	80004d34 <kexec>
    800019c4:	6cbc                	ld	a5,88(s1)
    800019c6:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019c8:	6cbc                	ld	a5,88(s1)
    800019ca:	7bb8                	ld	a4,112(a5)
    800019cc:	57fd                	li	a5,-1
    800019ce:	02f70d63          	beq	a4,a5,80001a08 <forkret+0x8a>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019d2:	5bd000ef          	jal	8000278e <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019d6:	68a8                	ld	a0,80(s1)
    800019d8:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019da:	04000737          	lui	a4,0x4000
    800019de:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019e0:	0732                	slli	a4,a4,0xc
    800019e2:	00005797          	auipc	a5,0x5
    800019e6:	6ba78793          	addi	a5,a5,1722 # 8000709c <userret>
    800019ea:	00005697          	auipc	a3,0x5
    800019ee:	61668693          	addi	a3,a3,1558 # 80007000 <_trampoline>
    800019f2:	8f95                	sub	a5,a5,a3
    800019f4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019f6:	577d                	li	a4,-1
    800019f8:	177e                	slli	a4,a4,0x3f
    800019fa:	8d59                	or	a0,a0,a4
    800019fc:	9782                	jalr	a5
}
    800019fe:	70a2                	ld	ra,40(sp)
    80001a00:	7402                	ld	s0,32(sp)
    80001a02:	64e2                	ld	s1,24(sp)
    80001a04:	6145                	addi	sp,sp,48
    80001a06:	8082                	ret
      panic("exec");
    80001a08:	00006517          	auipc	a0,0x6
    80001a0c:	78050513          	addi	a0,a0,1920 # 80008188 <etext+0x188>
    80001a10:	e25fe0ef          	jal	80000834 <panic>

0000000080001a14 <allocpid>:
{
    80001a14:	1101                	addi	sp,sp,-32
    80001a16:	ec06                	sd	ra,24(sp)
    80001a18:	e822                	sd	s0,16(sp)
    80001a1a:	e426                	sd	s1,8(sp)
    80001a1c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a1e:	00012517          	auipc	a0,0x12
    80001a22:	c3a50513          	addi	a0,a0,-966 # 80013658 <pid_lock>
    80001a26:	a02ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a2a:	0000a797          	auipc	a5,0xa
    80001a2e:	ada78793          	addi	a5,a5,-1318 # 8000b504 <nextpid>
    80001a32:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a34:	0014871b          	addiw	a4,s1,1
    80001a38:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a3a:	00012517          	auipc	a0,0x12
    80001a3e:	c1e50513          	addi	a0,a0,-994 # 80013658 <pid_lock>
    80001a42:	a6eff0ef          	jal	80000cb0 <release>
}
    80001a46:	8526                	mv	a0,s1
    80001a48:	60e2                	ld	ra,24(sp)
    80001a4a:	6442                	ld	s0,16(sp)
    80001a4c:	64a2                	ld	s1,8(sp)
    80001a4e:	6105                	addi	sp,sp,32
    80001a50:	8082                	ret

0000000080001a52 <proc_pagetable>:
{
    80001a52:	1101                	addi	sp,sp,-32
    80001a54:	ec06                	sd	ra,24(sp)
    80001a56:	e822                	sd	s0,16(sp)
    80001a58:	e426                	sd	s1,8(sp)
    80001a5a:	e04a                	sd	s2,0(sp)
    80001a5c:	1000                	addi	s0,sp,32
    80001a5e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a60:	f9eff0ef          	jal	800011fe <uvmcreate>
    80001a64:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a66:	cd05                	beqz	a0,80001a9e <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a68:	4729                	li	a4,10
    80001a6a:	00005697          	auipc	a3,0x5
    80001a6e:	59668693          	addi	a3,a3,1430 # 80007000 <_trampoline>
    80001a72:	6605                	lui	a2,0x1
    80001a74:	040005b7          	lui	a1,0x4000
    80001a78:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a7a:	05b2                	slli	a1,a1,0xc
    80001a7c:	ddaff0ef          	jal	80001056 <mappages>
    80001a80:	02054663          	bltz	a0,80001aac <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001a84:	4719                	li	a4,6
    80001a86:	05893683          	ld	a3,88(s2)
    80001a8a:	6605                	lui	a2,0x1
    80001a8c:	020005b7          	lui	a1,0x2000
    80001a90:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a92:	05b6                	slli	a1,a1,0xd
    80001a94:	8526                	mv	a0,s1
    80001a96:	dc0ff0ef          	jal	80001056 <mappages>
    80001a9a:	00054f63          	bltz	a0,80001ab8 <proc_pagetable+0x66>
}
    80001a9e:	8526                	mv	a0,s1
    80001aa0:	60e2                	ld	ra,24(sp)
    80001aa2:	6442                	ld	s0,16(sp)
    80001aa4:	64a2                	ld	s1,8(sp)
    80001aa6:	6902                	ld	s2,0(sp)
    80001aa8:	6105                	addi	sp,sp,32
    80001aaa:	8082                	ret
    uvmfree(pagetable, 0);
    80001aac:	4581                	li	a1,0
    80001aae:	8526                	mv	a0,s1
    80001ab0:	949ff0ef          	jal	800013f8 <uvmfree>
    return 0;
    80001ab4:	4481                	li	s1,0
    80001ab6:	b7e5                	j	80001a9e <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ab8:	4681                	li	a3,0
    80001aba:	4605                	li	a2,1
    80001abc:	040005b7          	lui	a1,0x4000
    80001ac0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ac2:	05b2                	slli	a1,a1,0xc
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	f5eff0ef          	jal	80001224 <uvmunmap>
    uvmfree(pagetable, 0);
    80001aca:	4581                	li	a1,0
    80001acc:	8526                	mv	a0,s1
    80001ace:	92bff0ef          	jal	800013f8 <uvmfree>
    return 0;
    80001ad2:	4481                	li	s1,0
    80001ad4:	b7e9                	j	80001a9e <proc_pagetable+0x4c>

0000000080001ad6 <proc_freepagetable>:
{
    80001ad6:	1101                	addi	sp,sp,-32
    80001ad8:	ec06                	sd	ra,24(sp)
    80001ada:	e822                	sd	s0,16(sp)
    80001adc:	e426                	sd	s1,8(sp)
    80001ade:	e04a                	sd	s2,0(sp)
    80001ae0:	1000                	addi	s0,sp,32
    80001ae2:	84aa                	mv	s1,a0
    80001ae4:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae6:	4681                	li	a3,0
    80001ae8:	4605                	li	a2,1
    80001aea:	040005b7          	lui	a1,0x4000
    80001aee:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001af0:	05b2                	slli	a1,a1,0xc
    80001af2:	f32ff0ef          	jal	80001224 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001af6:	4681                	li	a3,0
    80001af8:	4605                	li	a2,1
    80001afa:	020005b7          	lui	a1,0x2000
    80001afe:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b00:	05b6                	slli	a1,a1,0xd
    80001b02:	8526                	mv	a0,s1
    80001b04:	f20ff0ef          	jal	80001224 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b08:	85ca                	mv	a1,s2
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	8edff0ef          	jal	800013f8 <uvmfree>
}
    80001b10:	60e2                	ld	ra,24(sp)
    80001b12:	6442                	ld	s0,16(sp)
    80001b14:	64a2                	ld	s1,8(sp)
    80001b16:	6902                	ld	s2,0(sp)
    80001b18:	6105                	addi	sp,sp,32
    80001b1a:	8082                	ret

0000000080001b1c <freeproc>:
{
    80001b1c:	1101                	addi	sp,sp,-32
    80001b1e:	ec06                	sd	ra,24(sp)
    80001b20:	e822                	sd	s0,16(sp)
    80001b22:	e426                	sd	s1,8(sp)
    80001b24:	1000                	addi	s0,sp,32
    80001b26:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b28:	6d28                	ld	a0,88(a0)
    80001b2a:	c119                	beqz	a0,80001b30 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001b2c:	f3bfe0ef          	jal	80000a66 <kfree>
  p->trapframe = 0;
    80001b30:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable) {
    80001b34:	68a8                	ld	a0,80(s1)
    80001b36:	cd05                	beqz	a0,80001b6e <freeproc+0x52>
    if (p->is_thread) {
    80001b38:	1684a783          	lw	a5,360(s1)
    80001b3c:	cbad                	beqz	a5,80001bae <freeproc+0x92>
      if (p->sz > 0)
    80001b3e:	64b0                	ld	a2,72(s1)
    80001b40:	ee31                	bnez	a2,80001b9c <freeproc+0x80>
      uvmunmap(p->pagetable, TRAMPOLINE, 1, 0);
    80001b42:	4681                	li	a3,0
    80001b44:	4605                	li	a2,1
    80001b46:	040005b7          	lui	a1,0x4000
    80001b4a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b4c:	05b2                	slli	a1,a1,0xc
    80001b4e:	68a8                	ld	a0,80(s1)
    80001b50:	ed4ff0ef          	jal	80001224 <uvmunmap>
      uvmunmap(p->pagetable, TRAPFRAME, 1, 0);
    80001b54:	4681                	li	a3,0
    80001b56:	4605                	li	a2,1
    80001b58:	020005b7          	lui	a1,0x2000
    80001b5c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b5e:	05b6                	slli	a1,a1,0xd
    80001b60:	68a8                	ld	a0,80(s1)
    80001b62:	ec2ff0ef          	jal	80001224 <uvmunmap>
      uvmfree(p->pagetable, 0);
    80001b66:	4581                	li	a1,0
    80001b68:	68a8                	ld	a0,80(s1)
    80001b6a:	88fff0ef          	jal	800013f8 <uvmfree>
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
  p->is_thread = 0;
    80001b8a:	1604a423          	sw	zero,360(s1)
  p->state = UNUSED;
    80001b8e:	0004ac23          	sw	zero,24(s1)
}
    80001b92:	60e2                	ld	ra,24(sp)
    80001b94:	6442                	ld	s0,16(sp)
    80001b96:	64a2                	ld	s1,8(sp)
    80001b98:	6105                	addi	sp,sp,32
    80001b9a:	8082                	ret
        uvmunmap(p->pagetable, 0, PGROUNDUP(p->sz) / PGSIZE, 0);
    80001b9c:	6785                	lui	a5,0x1
    80001b9e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001ba0:	963e                	add	a2,a2,a5
    80001ba2:	4681                	li	a3,0
    80001ba4:	8231                	srli	a2,a2,0xc
    80001ba6:	4581                	li	a1,0
    80001ba8:	e7cff0ef          	jal	80001224 <uvmunmap>
    80001bac:	bf59                	j	80001b42 <freeproc+0x26>
      proc_freepagetable(p->pagetable, p->sz);
    80001bae:	64ac                	ld	a1,72(s1)
    80001bb0:	f27ff0ef          	jal	80001ad6 <proc_freepagetable>
    80001bb4:	bf6d                	j	80001b6e <freeproc+0x52>

0000000080001bb6 <allocproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bc2:	00012497          	auipc	s1,0x12
    80001bc6:	ec648493          	addi	s1,s1,-314 # 80013a88 <proc>
    80001bca:	00018917          	auipc	s2,0x18
    80001bce:	abe90913          	addi	s2,s2,-1346 # 80019688 <tickslock>
    acquire(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	854ff0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001bd8:	4c9c                	lw	a5,24(s1)
    80001bda:	cb91                	beqz	a5,80001bee <allocproc+0x38>
      release(&p->lock);
    80001bdc:	8526                	mv	a0,s1
    80001bde:	8d2ff0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001be2:	17048493          	addi	s1,s1,368
    80001be6:	ff2496e3          	bne	s1,s2,80001bd2 <allocproc+0x1c>
  return 0;
    80001bea:	4481                	li	s1,0
    80001bec:	a099                	j	80001c32 <allocproc+0x7c>
  p->pid = allocpid();
    80001bee:	e27ff0ef          	jal	80001a14 <allocpid>
    80001bf2:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bf4:	4785                	li	a5,1
    80001bf6:	cc9c                	sw	a5,24(s1)
  p->is_thread = 0;
    80001bf8:	1604a423          	sw	zero,360(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bfc:	f53fe0ef          	jal	80000b4e <kalloc>
    80001c00:	892a                	mv	s2,a0
    80001c02:	eca8                	sd	a0,88(s1)
    80001c04:	cd15                	beqz	a0,80001c40 <allocproc+0x8a>
  p->pagetable = proc_pagetable(p);
    80001c06:	8526                	mv	a0,s1
    80001c08:	e4bff0ef          	jal	80001a52 <proc_pagetable>
    80001c0c:	892a                	mv	s2,a0
    80001c0e:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001c10:	c121                	beqz	a0,80001c50 <allocproc+0x9a>
  memset(&p->context, 0, sizeof(p->context));
    80001c12:	07000613          	li	a2,112
    80001c16:	4581                	li	a1,0
    80001c18:	06048513          	addi	a0,s1,96
    80001c1c:	8ccff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001c20:	00000797          	auipc	a5,0x0
    80001c24:	d5e78793          	addi	a5,a5,-674 # 8000197e <forkret>
    80001c28:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c2a:	60bc                	ld	a5,64(s1)
    80001c2c:	6705                	lui	a4,0x1
    80001c2e:	97ba                	add	a5,a5,a4
    80001c30:	f4bc                	sd	a5,104(s1)
}
    80001c32:	8526                	mv	a0,s1
    80001c34:	60e2                	ld	ra,24(sp)
    80001c36:	6442                	ld	s0,16(sp)
    80001c38:	64a2                	ld	s1,8(sp)
    80001c3a:	6902                	ld	s2,0(sp)
    80001c3c:	6105                	addi	sp,sp,32
    80001c3e:	8082                	ret
    freeproc(p);
    80001c40:	8526                	mv	a0,s1
    80001c42:	edbff0ef          	jal	80001b1c <freeproc>
    release(&p->lock);
    80001c46:	8526                	mv	a0,s1
    80001c48:	868ff0ef          	jal	80000cb0 <release>
    return 0;
    80001c4c:	84ca                	mv	s1,s2
    80001c4e:	b7d5                	j	80001c32 <allocproc+0x7c>
    freeproc(p);
    80001c50:	8526                	mv	a0,s1
    80001c52:	ecbff0ef          	jal	80001b1c <freeproc>
    release(&p->lock);
    80001c56:	8526                	mv	a0,s1
    80001c58:	858ff0ef          	jal	80000cb0 <release>
    return 0;
    80001c5c:	84ca                	mv	s1,s2
    80001c5e:	bfd1                	j	80001c32 <allocproc+0x7c>

0000000080001c60 <userinit>:
{
    80001c60:	1101                	addi	sp,sp,-32
    80001c62:	ec06                	sd	ra,24(sp)
    80001c64:	e822                	sd	s0,16(sp)
    80001c66:	e426                	sd	s1,8(sp)
    80001c68:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c6a:	f4dff0ef          	jal	80001bb6 <allocproc>
    80001c6e:	84aa                	mv	s1,a0
  initproc = p;
    80001c70:	0000a797          	auipc	a5,0xa
    80001c74:	8ea7b023          	sd	a0,-1824(a5) # 8000b550 <initproc>
  p->cwd = namei("/");
    80001c78:	00006517          	auipc	a0,0x6
    80001c7c:	51850513          	addi	a0,a0,1304 # 80008190 <etext+0x190>
    80001c80:	35e020ef          	jal	80003fde <namei>
    80001c84:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c88:	478d                	li	a5,3
    80001c8a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c8c:	8526                	mv	a0,s1
    80001c8e:	822ff0ef          	jal	80000cb0 <release>
}
    80001c92:	60e2                	ld	ra,24(sp)
    80001c94:	6442                	ld	s0,16(sp)
    80001c96:	64a2                	ld	s1,8(sp)
    80001c98:	6105                	addi	sp,sp,32
    80001c9a:	8082                	ret

0000000080001c9c <growproc>:
{
    80001c9c:	1101                	addi	sp,sp,-32
    80001c9e:	ec06                	sd	ra,24(sp)
    80001ca0:	e822                	sd	s0,16(sp)
    80001ca2:	e426                	sd	s1,8(sp)
    80001ca4:	e04a                	sd	s2,0(sp)
    80001ca6:	1000                	addi	s0,sp,32
    80001ca8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001caa:	ca3ff0ef          	jal	8000194c <myproc>
    80001cae:	892a                	mv	s2,a0
  sz = p->sz;
    80001cb0:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001cb2:	02905963          	blez	s1,80001ce4 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001cb6:	00b48633          	add	a2,s1,a1
    80001cba:	020007b7          	lui	a5,0x2000
    80001cbe:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001cc0:	07b6                	slli	a5,a5,0xd
    80001cc2:	02c7ea63          	bltu	a5,a2,80001cf6 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001cc6:	4691                	li	a3,4
    80001cc8:	6928                	ld	a0,80(a0)
    80001cca:	e28ff0ef          	jal	800012f2 <uvmalloc>
    80001cce:	85aa                	mv	a1,a0
    80001cd0:	c50d                	beqz	a0,80001cfa <growproc+0x5e>
  p->sz = sz;
    80001cd2:	04b93423          	sd	a1,72(s2)
  return 0;
    80001cd6:	4501                	li	a0,0
}
    80001cd8:	60e2                	ld	ra,24(sp)
    80001cda:	6442                	ld	s0,16(sp)
    80001cdc:	64a2                	ld	s1,8(sp)
    80001cde:	6902                	ld	s2,0(sp)
    80001ce0:	6105                	addi	sp,sp,32
    80001ce2:	8082                	ret
  } else if (n < 0) {
    80001ce4:	fe04d7e3          	bgez	s1,80001cd2 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ce8:	00b48633          	add	a2,s1,a1
    80001cec:	6928                	ld	a0,80(a0)
    80001cee:	dc0ff0ef          	jal	800012ae <uvmdealloc>
    80001cf2:	85aa                	mv	a1,a0
    80001cf4:	bff9                	j	80001cd2 <growproc+0x36>
      return -1;
    80001cf6:	557d                	li	a0,-1
    80001cf8:	b7c5                	j	80001cd8 <growproc+0x3c>
      return -1;
    80001cfa:	557d                	li	a0,-1
    80001cfc:	bff1                	j	80001cd8 <growproc+0x3c>

0000000080001cfe <kfork>:
{
    80001cfe:	7139                	addi	sp,sp,-64
    80001d00:	fc06                	sd	ra,56(sp)
    80001d02:	f822                	sd	s0,48(sp)
    80001d04:	f426                	sd	s1,40(sp)
    80001d06:	e456                	sd	s5,8(sp)
    80001d08:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d0a:	c43ff0ef          	jal	8000194c <myproc>
    80001d0e:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001d10:	ea7ff0ef          	jal	80001bb6 <allocproc>
    80001d14:	0e050a63          	beqz	a0,80001e08 <kfork+0x10a>
    80001d18:	e852                	sd	s4,16(sp)
    80001d1a:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001d1c:	048ab603          	ld	a2,72(s5)
    80001d20:	692c                	ld	a1,80(a0)
    80001d22:	050ab503          	ld	a0,80(s5)
    80001d26:	f04ff0ef          	jal	8000142a <uvmcopy>
    80001d2a:	04054863          	bltz	a0,80001d7a <kfork+0x7c>
    80001d2e:	f04a                	sd	s2,32(sp)
    80001d30:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d32:	048ab783          	ld	a5,72(s5)
    80001d36:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d3a:	058ab683          	ld	a3,88(s5)
    80001d3e:	87b6                	mv	a5,a3
    80001d40:	058a3703          	ld	a4,88(s4)
    80001d44:	12068693          	addi	a3,a3,288
    80001d48:	6388                	ld	a0,0(a5)
    80001d4a:	678c                	ld	a1,8(a5)
    80001d4c:	6b90                	ld	a2,16(a5)
    80001d4e:	e308                	sd	a0,0(a4)
    80001d50:	e70c                	sd	a1,8(a4)
    80001d52:	eb10                	sd	a2,16(a4)
    80001d54:	6f90                	ld	a2,24(a5)
    80001d56:	ef10                	sd	a2,24(a4)
    80001d58:	02078793          	addi	a5,a5,32
    80001d5c:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d60:	fed794e3          	bne	a5,a3,80001d48 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d64:	058a3783          	ld	a5,88(s4)
    80001d68:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d6c:	0d0a8493          	addi	s1,s5,208
    80001d70:	0d0a0913          	addi	s2,s4,208
    80001d74:	150a8993          	addi	s3,s5,336
    80001d78:	a831                	j	80001d94 <kfork+0x96>
    freeproc(np);
    80001d7a:	8552                	mv	a0,s4
    80001d7c:	da1ff0ef          	jal	80001b1c <freeproc>
    release(&np->lock);
    80001d80:	8552                	mv	a0,s4
    80001d82:	f2ffe0ef          	jal	80000cb0 <release>
    return -1;
    80001d86:	54fd                	li	s1,-1
    80001d88:	6a42                	ld	s4,16(sp)
    80001d8a:	a885                	j	80001dfa <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d8c:	04a1                	addi	s1,s1,8
    80001d8e:	0921                	addi	s2,s2,8
    80001d90:	01348963          	beq	s1,s3,80001da2 <kfork+0xa4>
    if (p->ofile[i])
    80001d94:	6088                	ld	a0,0(s1)
    80001d96:	d97d                	beqz	a0,80001d8c <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d98:	099020ef          	jal	80004630 <filedup>
    80001d9c:	00a93023          	sd	a0,0(s2)
    80001da0:	b7f5                	j	80001d8c <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001da2:	150ab503          	ld	a0,336(s5)
    80001da6:	169010ef          	jal	8000370e <idup>
    80001daa:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001dae:	4641                	li	a2,16
    80001db0:	158a8593          	addi	a1,s5,344
    80001db4:	158a0513          	addi	a0,s4,344
    80001db8:	884ff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001dbc:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001dc0:	8552                	mv	a0,s4
    80001dc2:	eeffe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001dc6:	00012517          	auipc	a0,0x12
    80001dca:	8aa50513          	addi	a0,a0,-1878 # 80013670 <wait_lock>
    80001dce:	e5bfe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001dd2:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001dd6:	00012517          	auipc	a0,0x12
    80001dda:	89a50513          	addi	a0,a0,-1894 # 80013670 <wait_lock>
    80001dde:	ed3fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001de2:	8552                	mv	a0,s4
    80001de4:	e45fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001de8:	478d                	li	a5,3
    80001dea:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001dee:	8552                	mv	a0,s4
    80001df0:	ec1fe0ef          	jal	80000cb0 <release>
  return pid;
    80001df4:	7902                	ld	s2,32(sp)
    80001df6:	69e2                	ld	s3,24(sp)
    80001df8:	6a42                	ld	s4,16(sp)
}
    80001dfa:	8526                	mv	a0,s1
    80001dfc:	70e2                	ld	ra,56(sp)
    80001dfe:	7442                	ld	s0,48(sp)
    80001e00:	74a2                	ld	s1,40(sp)
    80001e02:	6aa2                	ld	s5,8(sp)
    80001e04:	6121                	addi	sp,sp,64
    80001e06:	8082                	ret
    return -1;
    80001e08:	54fd                	li	s1,-1
    80001e0a:	bfc5                	j	80001dfa <kfork+0xfc>

0000000080001e0c <kclone>:
{
    80001e0c:	711d                	addi	sp,sp,-96
    80001e0e:	ec86                	sd	ra,88(sp)
    80001e10:	e8a2                	sd	s0,80(sp)
    80001e12:	e4a6                	sd	s1,72(sp)
    80001e14:	f05a                	sd	s6,32(sp)
    80001e16:	e862                	sd	s8,16(sp)
    80001e18:	e466                	sd	s9,8(sp)
    80001e1a:	e06a                	sd	s10,0(sp)
    80001e1c:	1080                	addi	s0,sp,96
    80001e1e:	8c2a                	mv	s8,a0
    80001e20:	8cae                	mv	s9,a1
    80001e22:	8d32                	mv	s10,a2
  struct proc *p = myproc();
    80001e24:	b29ff0ef          	jal	8000194c <myproc>
    80001e28:	8b2a                	mv	s6,a0
  if ((np = allocproc()) == 0) {
    80001e2a:	d8dff0ef          	jal	80001bb6 <allocproc>
    80001e2e:	16050763          	beqz	a0,80001f9c <kclone+0x190>
    80001e32:	e0ca                	sd	s2,64(sp)
    80001e34:	fc4e                	sd	s3,56(sp)
    80001e36:	f852                	sd	s4,48(sp)
    80001e38:	89aa                	mv	s3,a0
  if (uvmshare(p->pagetable, np->pagetable, p->sz) < 0) {
    80001e3a:	048b3a03          	ld	s4,72(s6)
  for (i = 0; i < sz; i += PGSIZE) {
    80001e3e:	060a0963          	beqz	s4,80001eb0 <kclone+0xa4>
    80001e42:	f456                	sd	s5,40(sp)
    80001e44:	ec5e                	sd	s7,24(sp)
  if (uvmshare(p->pagetable, np->pagetable, p->sz) < 0) {
    80001e46:	050b3a83          	ld	s5,80(s6)
    80001e4a:	05053b83          	ld	s7,80(a0)
  for (i = 0; i < sz; i += PGSIZE) {
    80001e4e:	4481                	li	s1,0
    if (mappages(new, i, PGSIZE, pa, flags) != 0) {
    80001e50:	6905                	lui	s2,0x1
    80001e52:	a021                	j	80001e5a <kclone+0x4e>
  for (i = 0; i < sz; i += PGSIZE) {
    80001e54:	94ca                	add	s1,s1,s2
    80001e56:	0544fb63          	bgeu	s1,s4,80001eac <kclone+0xa0>
    if ((pte = walk(old, i, 0)) == 0)
    80001e5a:	4601                	li	a2,0
    80001e5c:	85a6                	mv	a1,s1
    80001e5e:	8556                	mv	a0,s5
    80001e60:	922ff0ef          	jal	80000f82 <walk>
    80001e64:	d965                	beqz	a0,80001e54 <kclone+0x48>
    if ((*pte & PTE_V) == 0)
    80001e66:	6118                	ld	a4,0(a0)
    80001e68:	00177793          	andi	a5,a4,1
    80001e6c:	d7e5                	beqz	a5,80001e54 <kclone+0x48>
    pa = PTE2PA(*pte);
    80001e6e:	00a75693          	srli	a3,a4,0xa
    if (mappages(new, i, PGSIZE, pa, flags) != 0) {
    80001e72:	3ff77713          	andi	a4,a4,1023
    80001e76:	06b2                	slli	a3,a3,0xc
    80001e78:	864a                	mv	a2,s2
    80001e7a:	85a6                	mv	a1,s1
    80001e7c:	855e                	mv	a0,s7
    80001e7e:	9d8ff0ef          	jal	80001056 <mappages>
    80001e82:	d969                	beqz	a0,80001e54 <kclone+0x48>
      uvmunmap(new, 0, i / PGSIZE, 0);
    80001e84:	4681                	li	a3,0
    80001e86:	00c4d613          	srli	a2,s1,0xc
    80001e8a:	4581                	li	a1,0
    80001e8c:	855e                	mv	a0,s7
    80001e8e:	b96ff0ef          	jal	80001224 <uvmunmap>
    freeproc(np);
    80001e92:	854e                	mv	a0,s3
    80001e94:	c89ff0ef          	jal	80001b1c <freeproc>
    release(&np->lock);
    80001e98:	854e                	mv	a0,s3
    80001e9a:	e17fe0ef          	jal	80000cb0 <release>
    return -1;
    80001e9e:	54fd                	li	s1,-1
    80001ea0:	6906                	ld	s2,64(sp)
    80001ea2:	79e2                	ld	s3,56(sp)
    80001ea4:	7a42                	ld	s4,48(sp)
    80001ea6:	7aa2                	ld	s5,40(sp)
    80001ea8:	6be2                	ld	s7,24(sp)
    80001eaa:	a8f9                	j	80001f88 <kclone+0x17c>
    80001eac:	7aa2                	ld	s5,40(sp)
    80001eae:	6be2                	ld	s7,24(sp)
  np->sz = p->sz;
    80001eb0:	048b3783          	ld	a5,72(s6)
    80001eb4:	04f9b423          	sd	a5,72(s3)
  np->is_thread = 1;
    80001eb8:	4785                	li	a5,1
    80001eba:	16f9a423          	sw	a5,360(s3)
  *(np->trapframe) = *(p->trapframe);
    80001ebe:	058b3683          	ld	a3,88(s6)
    80001ec2:	87b6                	mv	a5,a3
    80001ec4:	0589b703          	ld	a4,88(s3)
    80001ec8:	12068693          	addi	a3,a3,288
    80001ecc:	6388                	ld	a0,0(a5)
    80001ece:	678c                	ld	a1,8(a5)
    80001ed0:	6b90                	ld	a2,16(a5)
    80001ed2:	e308                	sd	a0,0(a4)
    80001ed4:	e70c                	sd	a1,8(a4)
    80001ed6:	eb10                	sd	a2,16(a4)
    80001ed8:	6f90                	ld	a2,24(a5)
    80001eda:	ef10                	sd	a2,24(a4)
    80001edc:	02078793          	addi	a5,a5,32
    80001ee0:	02070713          	addi	a4,a4,32
    80001ee4:	fed794e3          	bne	a5,a3,80001ecc <kclone+0xc0>
  np->trapframe->epc = fcn;
    80001ee8:	0589b783          	ld	a5,88(s3)
    80001eec:	0187bc23          	sd	s8,24(a5)
  np->trapframe->a0 = arg;
    80001ef0:	0589b783          	ld	a5,88(s3)
    80001ef4:	0797b823          	sd	s9,112(a5)
  np->trapframe->sp = stack + PGSIZE;
    80001ef8:	0589b703          	ld	a4,88(s3)
    80001efc:	6785                	lui	a5,0x1
    80001efe:	97ea                	add	a5,a5,s10
    80001f00:	fb1c                	sd	a5,48(a4)
  np->trapframe->sp -= (np->trapframe->sp % 16); // 16-byte alignment
    80001f02:	0589b703          	ld	a4,88(s3)
    80001f06:	7b1c                	ld	a5,48(a4)
    80001f08:	9bc1                	andi	a5,a5,-16
    80001f0a:	fb1c                	sd	a5,48(a4)
  for (i = 0; i < NOFILE; i++)
    80001f0c:	0d0b0493          	addi	s1,s6,208
    80001f10:	0d098913          	addi	s2,s3,208
    80001f14:	150b0a13          	addi	s4,s6,336
    80001f18:	a029                	j	80001f22 <kclone+0x116>
    80001f1a:	04a1                	addi	s1,s1,8
    80001f1c:	0921                	addi	s2,s2,8 # 1008 <_entry-0x7fffeff8>
    80001f1e:	01448963          	beq	s1,s4,80001f30 <kclone+0x124>
    if (p->ofile[i])
    80001f22:	6088                	ld	a0,0(s1)
    80001f24:	d97d                	beqz	a0,80001f1a <kclone+0x10e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f26:	70a020ef          	jal	80004630 <filedup>
    80001f2a:	00a93023          	sd	a0,0(s2)
    80001f2e:	b7f5                	j	80001f1a <kclone+0x10e>
  np->cwd = idup(p->cwd);
    80001f30:	150b3503          	ld	a0,336(s6)
    80001f34:	7da010ef          	jal	8000370e <idup>
    80001f38:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f3c:	4641                	li	a2,16
    80001f3e:	158b0593          	addi	a1,s6,344
    80001f42:	15898513          	addi	a0,s3,344
    80001f46:	ef7fe0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001f4a:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    80001f4e:	854e                	mv	a0,s3
    80001f50:	d61fe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001f54:	00011517          	auipc	a0,0x11
    80001f58:	71c50513          	addi	a0,a0,1820 # 80013670 <wait_lock>
    80001f5c:	ccdfe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001f60:	0369bc23          	sd	s6,56(s3)
  release(&wait_lock);
    80001f64:	00011517          	auipc	a0,0x11
    80001f68:	70c50513          	addi	a0,a0,1804 # 80013670 <wait_lock>
    80001f6c:	d45fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001f70:	854e                	mv	a0,s3
    80001f72:	cb7fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001f76:	478d                	li	a5,3
    80001f78:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f7c:	854e                	mv	a0,s3
    80001f7e:	d33fe0ef          	jal	80000cb0 <release>
  return pid;
    80001f82:	6906                	ld	s2,64(sp)
    80001f84:	79e2                	ld	s3,56(sp)
    80001f86:	7a42                	ld	s4,48(sp)
}
    80001f88:	8526                	mv	a0,s1
    80001f8a:	60e6                	ld	ra,88(sp)
    80001f8c:	6446                	ld	s0,80(sp)
    80001f8e:	64a6                	ld	s1,72(sp)
    80001f90:	7b02                	ld	s6,32(sp)
    80001f92:	6c42                	ld	s8,16(sp)
    80001f94:	6ca2                	ld	s9,8(sp)
    80001f96:	6d02                	ld	s10,0(sp)
    80001f98:	6125                	addi	sp,sp,96
    80001f9a:	8082                	ret
    return -1;
    80001f9c:	54fd                	li	s1,-1
    80001f9e:	b7ed                	j	80001f88 <kclone+0x17c>

0000000080001fa0 <scheduler>:
{
    80001fa0:	711d                	addi	sp,sp,-96
    80001fa2:	ec86                	sd	ra,88(sp)
    80001fa4:	e8a2                	sd	s0,80(sp)
    80001fa6:	e4a6                	sd	s1,72(sp)
    80001fa8:	e0ca                	sd	s2,64(sp)
    80001faa:	fc4e                	sd	s3,56(sp)
    80001fac:	f852                	sd	s4,48(sp)
    80001fae:	f456                	sd	s5,40(sp)
    80001fb0:	f05a                	sd	s6,32(sp)
    80001fb2:	ec5e                	sd	s7,24(sp)
    80001fb4:	e862                	sd	s8,16(sp)
    80001fb6:	e466                	sd	s9,8(sp)
    80001fb8:	1080                	addi	s0,sp,96
    80001fba:	8792                	mv	a5,tp
  int id = r_tp();
    80001fbc:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fbe:	00779a93          	slli	s5,a5,0x7
    80001fc2:	00011717          	auipc	a4,0x11
    80001fc6:	69670713          	addi	a4,a4,1686 # 80013658 <pid_lock>
    80001fca:	9756                	add	a4,a4,s5
    80001fcc:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001fd0:	00011717          	auipc	a4,0x11
    80001fd4:	6c070713          	addi	a4,a4,1728 # 80013690 <cpus+0x8>
    80001fd8:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001fda:	4c11                	li	s8,4
        c->proc = p;
    80001fdc:	00011b17          	auipc	s6,0x11
    80001fe0:	67cb0b13          	addi	s6,s6,1660 # 80013658 <pid_lock>
    80001fe4:	079e                	slli	a5,a5,0x7
    80001fe6:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001fea:	4b85                	li	s7,1
    80001fec:	a0a9                	j	80002036 <scheduler+0x96>
      release(&p->lock);
    80001fee:	8526                	mv	a0,s1
    80001ff0:	cc1fe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001ff4:	17048493          	addi	s1,s1,368
    80001ff8:	03248b63          	beq	s1,s2,8000202e <scheduler+0x8e>
      acquire(&p->lock);
    80001ffc:	8526                	mv	a0,s1
    80001ffe:	c2bfe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80002002:	4c9c                	lw	a5,24(s1)
    80002004:	ff3795e3          	bne	a5,s3,80001fee <scheduler+0x4e>
        p->state = RUNNING;
    80002008:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000200c:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002010:	06048593          	addi	a1,s1,96
    80002014:	8556                	mv	a0,s5
    80002016:	6ce000ef          	jal	800026e4 <swtch>
    8000201a:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    8000201c:	2781                	sext.w	a5,a5
    8000201e:	079e                	slli	a5,a5,0x7
    80002020:	97da                	add	a5,a5,s6
    80002022:	0a07a623          	sw	zero,172(a5) # 10ac <_entry-0x7fffef54>
        c->proc = 0;
    80002026:	020a3823          	sd	zero,48(s4)
        found = 1;
    8000202a:	8cde                	mv	s9,s7
    8000202c:	b7c9                	j	80001fee <scheduler+0x4e>
    if (found == 0) {
    8000202e:	000c9463          	bnez	s9,80002036 <scheduler+0x96>
      asm volatile("wfi");
    80002032:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002036:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    8000203a:	10017073          	csrci	sstatus,2
    int found = 0;
    8000203e:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80002040:	00012497          	auipc	s1,0x12
    80002044:	a4848493          	addi	s1,s1,-1464 # 80013a88 <proc>
      if (p->state == RUNNABLE) {
    80002048:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    8000204a:	00017917          	auipc	s2,0x17
    8000204e:	63e90913          	addi	s2,s2,1598 # 80019688 <tickslock>
    80002052:	b76d                	j	80001ffc <scheduler+0x5c>

0000000080002054 <sched>:
{
    80002054:	7179                	addi	sp,sp,-48
    80002056:	f406                	sd	ra,40(sp)
    80002058:	f022                	sd	s0,32(sp)
    8000205a:	ec26                	sd	s1,24(sp)
    8000205c:	e84a                	sd	s2,16(sp)
    8000205e:	e44e                	sd	s3,8(sp)
    80002060:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002062:	8ebff0ef          	jal	8000194c <myproc>
    80002066:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002068:	b5bfe0ef          	jal	80000bc2 <holding>
    8000206c:	c935                	beqz	a0,800020e0 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    8000206e:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002070:	2781                	sext.w	a5,a5
    80002072:	079e                	slli	a5,a5,0x7
    80002074:	00011717          	auipc	a4,0x11
    80002078:	5e470713          	addi	a4,a4,1508 # 80013658 <pid_lock>
    8000207c:	97ba                	add	a5,a5,a4
    8000207e:	0a87a703          	lw	a4,168(a5)
    80002082:	4785                	li	a5,1
    80002084:	06f71463          	bne	a4,a5,800020ec <sched+0x98>
  if (p->state == RUNNING)
    80002088:	4c98                	lw	a4,24(s1)
    8000208a:	4791                	li	a5,4
    8000208c:	06f70663          	beq	a4,a5,800020f8 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002090:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002094:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002096:	e7bd                	bnez	a5,80002104 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80002098:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000209a:	00011917          	auipc	s2,0x11
    8000209e:	5be90913          	addi	s2,s2,1470 # 80013658 <pid_lock>
    800020a2:	2781                	sext.w	a5,a5
    800020a4:	079e                	slli	a5,a5,0x7
    800020a6:	97ca                	add	a5,a5,s2
    800020a8:	0ac7a983          	lw	s3,172(a5)
    800020ac:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020ae:	2781                	sext.w	a5,a5
    800020b0:	079e                	slli	a5,a5,0x7
    800020b2:	07a1                	addi	a5,a5,8
    800020b4:	00011597          	auipc	a1,0x11
    800020b8:	5d458593          	addi	a1,a1,1492 # 80013688 <cpus>
    800020bc:	95be                	add	a1,a1,a5
    800020be:	06048513          	addi	a0,s1,96
    800020c2:	622000ef          	jal	800026e4 <swtch>
    800020c6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020c8:	2781                	sext.w	a5,a5
    800020ca:	079e                	slli	a5,a5,0x7
    800020cc:	993e                	add	s2,s2,a5
    800020ce:	0b392623          	sw	s3,172(s2)
}
    800020d2:	70a2                	ld	ra,40(sp)
    800020d4:	7402                	ld	s0,32(sp)
    800020d6:	64e2                	ld	s1,24(sp)
    800020d8:	6942                	ld	s2,16(sp)
    800020da:	69a2                	ld	s3,8(sp)
    800020dc:	6145                	addi	sp,sp,48
    800020de:	8082                	ret
    panic("sched p->lock");
    800020e0:	00006517          	auipc	a0,0x6
    800020e4:	0b850513          	addi	a0,a0,184 # 80008198 <etext+0x198>
    800020e8:	f4cfe0ef          	jal	80000834 <panic>
    panic("sched locks");
    800020ec:	00006517          	auipc	a0,0x6
    800020f0:	0bc50513          	addi	a0,a0,188 # 800081a8 <etext+0x1a8>
    800020f4:	f40fe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    800020f8:	00006517          	auipc	a0,0x6
    800020fc:	0c050513          	addi	a0,a0,192 # 800081b8 <etext+0x1b8>
    80002100:	f34fe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80002104:	00006517          	auipc	a0,0x6
    80002108:	0c450513          	addi	a0,a0,196 # 800081c8 <etext+0x1c8>
    8000210c:	f28fe0ef          	jal	80000834 <panic>

0000000080002110 <yield>:
{
    80002110:	1101                	addi	sp,sp,-32
    80002112:	ec06                	sd	ra,24(sp)
    80002114:	e822                	sd	s0,16(sp)
    80002116:	e426                	sd	s1,8(sp)
    80002118:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000211a:	833ff0ef          	jal	8000194c <myproc>
    8000211e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002120:	b09fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80002124:	478d                	li	a5,3
    80002126:	cc9c                	sw	a5,24(s1)
  sched();
    80002128:	f2dff0ef          	jal	80002054 <sched>
  release(&p->lock);
    8000212c:	8526                	mv	a0,s1
    8000212e:	b83fe0ef          	jal	80000cb0 <release>
}
    80002132:	60e2                	ld	ra,24(sp)
    80002134:	6442                	ld	s0,16(sp)
    80002136:	64a2                	ld	s1,8(sp)
    80002138:	6105                	addi	sp,sp,32
    8000213a:	8082                	ret

000000008000213c <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    8000213c:	1101                	addi	sp,sp,-32
    8000213e:	ec06                	sd	ra,24(sp)
    80002140:	e822                	sd	s0,16(sp)
    80002142:	e426                	sd	s1,8(sp)
    80002144:	e04a                	sd	s2,0(sp)
    80002146:	1000                	addi	s0,sp,32
    80002148:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000214a:	803ff0ef          	jal	8000194c <myproc>
    8000214e:	892a                	mv	s2,a0

  acquire(&p->lock);
    80002150:	ad9fe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    80002154:	cc81                	beqz	s1,8000216c <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80002156:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    8000215a:	854a                	mv	a0,s2
    8000215c:	b55fe0ef          	jal	80000cb0 <release>
}
    80002160:	60e2                	ld	ra,24(sp)
    80002162:	6442                	ld	s0,16(sp)
    80002164:	64a2                	ld	s1,8(sp)
    80002166:	6902                	ld	s2,0(sp)
    80002168:	6105                	addi	sp,sp,32
    8000216a:	8082                	ret
    panic("sleep_prepare: zero chan");
    8000216c:	00006517          	auipc	a0,0x6
    80002170:	07450513          	addi	a0,a0,116 # 800081e0 <etext+0x1e0>
    80002174:	ec0fe0ef          	jal	80000834 <panic>

0000000080002178 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80002178:	1101                	addi	sp,sp,-32
    8000217a:	ec06                	sd	ra,24(sp)
    8000217c:	e822                	sd	s0,16(sp)
    8000217e:	e426                	sd	s1,8(sp)
    80002180:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002182:	fcaff0ef          	jal	8000194c <myproc>
    80002186:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80002188:	aa1fe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    8000218c:	709c                	ld	a5,32(s1)
    8000218e:	c789                	beqz	a5,80002198 <sleep+0x20>
    p->state = SLEEPING;
    80002190:	4789                	li	a5,2
    80002192:	cc9c                	sw	a5,24(s1)
    sched();
    80002194:	ec1ff0ef          	jal	80002054 <sched>
  }
  release(&p->lock);
    80002198:	8526                	mv	a0,s1
    8000219a:	b17fe0ef          	jal	80000cb0 <release>
}
    8000219e:	60e2                	ld	ra,24(sp)
    800021a0:	6442                	ld	s0,16(sp)
    800021a2:	64a2                	ld	s1,8(sp)
    800021a4:	6105                	addi	sp,sp,32
    800021a6:	8082                	ret

00000000800021a8 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    800021a8:	7139                	addi	sp,sp,-64
    800021aa:	fc06                	sd	ra,56(sp)
    800021ac:	f822                	sd	s0,48(sp)
    800021ae:	f426                	sd	s1,40(sp)
    800021b0:	f04a                	sd	s2,32(sp)
    800021b2:	ec4e                	sd	s3,24(sp)
    800021b4:	e852                	sd	s4,16(sp)
    800021b6:	e456                	sd	s5,8(sp)
    800021b8:	0080                	addi	s0,sp,64
    800021ba:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800021bc:	00012497          	auipc	s1,0x12
    800021c0:	8cc48493          	addi	s1,s1,-1844 # 80013a88 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    800021c4:	4a09                	li	s4,2
        p->state = RUNNABLE;
    800021c6:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    800021c8:	00017997          	auipc	s3,0x17
    800021cc:	4c098993          	addi	s3,s3,1216 # 80019688 <tickslock>
    800021d0:	a801                	j	800021e0 <wakeup+0x38>
      }
    }
    release(&p->lock);
    800021d2:	8526                	mv	a0,s1
    800021d4:	addfe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800021d8:	17048493          	addi	s1,s1,368
    800021dc:	03348063          	beq	s1,s3,800021fc <wakeup+0x54>
    acquire(&p->lock);
    800021e0:	8526                	mv	a0,s1
    800021e2:	a47fe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    800021e6:	709c                	ld	a5,32(s1)
    800021e8:	ff2795e3          	bne	a5,s2,800021d2 <wakeup+0x2a>
      p->chan = 0;
    800021ec:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    800021f0:	4c9c                	lw	a5,24(s1)
    800021f2:	ff4790e3          	bne	a5,s4,800021d2 <wakeup+0x2a>
        p->state = RUNNABLE;
    800021f6:	0154ac23          	sw	s5,24(s1)
    800021fa:	bfe1                	j	800021d2 <wakeup+0x2a>
  }
}
    800021fc:	70e2                	ld	ra,56(sp)
    800021fe:	7442                	ld	s0,48(sp)
    80002200:	74a2                	ld	s1,40(sp)
    80002202:	7902                	ld	s2,32(sp)
    80002204:	69e2                	ld	s3,24(sp)
    80002206:	6a42                	ld	s4,16(sp)
    80002208:	6aa2                	ld	s5,8(sp)
    8000220a:	6121                	addi	sp,sp,64
    8000220c:	8082                	ret

000000008000220e <reparent>:
{
    8000220e:	7179                	addi	sp,sp,-48
    80002210:	f406                	sd	ra,40(sp)
    80002212:	f022                	sd	s0,32(sp)
    80002214:	ec26                	sd	s1,24(sp)
    80002216:	e84a                	sd	s2,16(sp)
    80002218:	e44e                	sd	s3,8(sp)
    8000221a:	e052                	sd	s4,0(sp)
    8000221c:	1800                	addi	s0,sp,48
    8000221e:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002220:	00012497          	auipc	s1,0x12
    80002224:	86848493          	addi	s1,s1,-1944 # 80013a88 <proc>
      pp->parent = initproc;
    80002228:	00009a17          	auipc	s4,0x9
    8000222c:	328a0a13          	addi	s4,s4,808 # 8000b550 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002230:	00017997          	auipc	s3,0x17
    80002234:	45898993          	addi	s3,s3,1112 # 80019688 <tickslock>
    80002238:	a029                	j	80002242 <reparent+0x34>
    8000223a:	17048493          	addi	s1,s1,368
    8000223e:	01348b63          	beq	s1,s3,80002254 <reparent+0x46>
    if (pp->parent == p) {
    80002242:	7c9c                	ld	a5,56(s1)
    80002244:	ff279be3          	bne	a5,s2,8000223a <reparent+0x2c>
      pp->parent = initproc;
    80002248:	000a3503          	ld	a0,0(s4)
    8000224c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000224e:	f5bff0ef          	jal	800021a8 <wakeup>
    80002252:	b7e5                	j	8000223a <reparent+0x2c>
}
    80002254:	70a2                	ld	ra,40(sp)
    80002256:	7402                	ld	s0,32(sp)
    80002258:	64e2                	ld	s1,24(sp)
    8000225a:	6942                	ld	s2,16(sp)
    8000225c:	69a2                	ld	s3,8(sp)
    8000225e:	6a02                	ld	s4,0(sp)
    80002260:	6145                	addi	sp,sp,48
    80002262:	8082                	ret

0000000080002264 <kexit>:
{
    80002264:	7179                	addi	sp,sp,-48
    80002266:	f406                	sd	ra,40(sp)
    80002268:	f022                	sd	s0,32(sp)
    8000226a:	ec26                	sd	s1,24(sp)
    8000226c:	e84a                	sd	s2,16(sp)
    8000226e:	e44e                	sd	s3,8(sp)
    80002270:	e052                	sd	s4,0(sp)
    80002272:	1800                	addi	s0,sp,48
    80002274:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002276:	ed6ff0ef          	jal	8000194c <myproc>
    8000227a:	89aa                	mv	s3,a0
  if (p == initproc)
    8000227c:	00009797          	auipc	a5,0x9
    80002280:	2d47b783          	ld	a5,724(a5) # 8000b550 <initproc>
    80002284:	0d050493          	addi	s1,a0,208
    80002288:	15050913          	addi	s2,a0,336
    8000228c:	00a79b63          	bne	a5,a0,800022a2 <kexit+0x3e>
    panic("init exiting");
    80002290:	00006517          	auipc	a0,0x6
    80002294:	f7050513          	addi	a0,a0,-144 # 80008200 <etext+0x200>
    80002298:	d9cfe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    8000229c:	04a1                	addi	s1,s1,8
    8000229e:	01248963          	beq	s1,s2,800022b0 <kexit+0x4c>
    if (p->ofile[fd]) {
    800022a2:	6088                	ld	a0,0(s1)
    800022a4:	dd65                	beqz	a0,8000229c <kexit+0x38>
      fileclose(f);
    800022a6:	3d0020ef          	jal	80004676 <fileclose>
      p->ofile[fd] = 0;
    800022aa:	0004b023          	sd	zero,0(s1)
    800022ae:	b7fd                	j	8000229c <kexit+0x38>
  begin_op();
    800022b0:	70d010ef          	jal	800041bc <begin_op>
  iput(p->cwd);
    800022b4:	1509b503          	ld	a0,336(s3)
    800022b8:	60e010ef          	jal	800038c6 <iput>
  end_op();
    800022bc:	78d010ef          	jal	80004248 <end_op>
  p->cwd = 0;
    800022c0:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022c4:	00011517          	auipc	a0,0x11
    800022c8:	3ac50513          	addi	a0,a0,940 # 80013670 <wait_lock>
    800022cc:	95dfe0ef          	jal	80000c28 <acquire>
  reparent(p);
    800022d0:	854e                	mv	a0,s3
    800022d2:	f3dff0ef          	jal	8000220e <reparent>
  wakeup(p->parent);
    800022d6:	0389b503          	ld	a0,56(s3)
    800022da:	ecfff0ef          	jal	800021a8 <wakeup>
  acquire(&p->lock);
    800022de:	854e                	mv	a0,s3
    800022e0:	949fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    800022e4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022e8:	4795                	li	a5,5
    800022ea:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022ee:	00011517          	auipc	a0,0x11
    800022f2:	38250513          	addi	a0,a0,898 # 80013670 <wait_lock>
    800022f6:	9bbfe0ef          	jal	80000cb0 <release>
  sched();
    800022fa:	d5bff0ef          	jal	80002054 <sched>
  panic("zombie exit");
    800022fe:	00006517          	auipc	a0,0x6
    80002302:	f1250513          	addi	a0,a0,-238 # 80008210 <etext+0x210>
    80002306:	d2efe0ef          	jal	80000834 <panic>

000000008000230a <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    8000230a:	c525                	beqz	a0,80002372 <kkill+0x68>
{
    8000230c:	7179                	addi	sp,sp,-48
    8000230e:	f406                	sd	ra,40(sp)
    80002310:	f022                	sd	s0,32(sp)
    80002312:	ec26                	sd	s1,24(sp)
    80002314:	e84a                	sd	s2,16(sp)
    80002316:	e44e                	sd	s3,8(sp)
    80002318:	1800                	addi	s0,sp,48
    8000231a:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000231c:	00011497          	auipc	s1,0x11
    80002320:	76c48493          	addi	s1,s1,1900 # 80013a88 <proc>
    80002324:	00017997          	auipc	s3,0x17
    80002328:	36498993          	addi	s3,s3,868 # 80019688 <tickslock>
    acquire(&p->lock);
    8000232c:	8526                	mv	a0,s1
    8000232e:	8fbfe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    80002332:	589c                	lw	a5,48(s1)
    80002334:	01278b63          	beq	a5,s2,8000234a <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002338:	8526                	mv	a0,s1
    8000233a:	977fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000233e:	17048493          	addi	s1,s1,368
    80002342:	ff3495e3          	bne	s1,s3,8000232c <kkill+0x22>
  }
  return -1;
    80002346:	557d                	li	a0,-1
    80002348:	a819                	j	8000235e <kkill+0x54>
      p->killed = 1;
    8000234a:	4785                	li	a5,1
    8000234c:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    8000234e:	4c98                	lw	a4,24(s1)
    80002350:	4789                	li	a5,2
    80002352:	00f70d63          	beq	a4,a5,8000236c <kkill+0x62>
      release(&p->lock);
    80002356:	8526                	mv	a0,s1
    80002358:	959fe0ef          	jal	80000cb0 <release>
      return 0;
    8000235c:	4501                	li	a0,0
}
    8000235e:	70a2                	ld	ra,40(sp)
    80002360:	7402                	ld	s0,32(sp)
    80002362:	64e2                	ld	s1,24(sp)
    80002364:	6942                	ld	s2,16(sp)
    80002366:	69a2                	ld	s3,8(sp)
    80002368:	6145                	addi	sp,sp,48
    8000236a:	8082                	ret
        p->state = RUNNABLE;
    8000236c:	478d                	li	a5,3
    8000236e:	cc9c                	sw	a5,24(s1)
    80002370:	b7dd                	j	80002356 <kkill+0x4c>
    return -1;
    80002372:	557d                	li	a0,-1
}
    80002374:	8082                	ret

0000000080002376 <setkilled>:

void
setkilled(struct proc *p)
{
    80002376:	1101                	addi	sp,sp,-32
    80002378:	ec06                	sd	ra,24(sp)
    8000237a:	e822                	sd	s0,16(sp)
    8000237c:	e426                	sd	s1,8(sp)
    8000237e:	1000                	addi	s0,sp,32
    80002380:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002382:	8a7fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002386:	4785                	li	a5,1
    80002388:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000238a:	8526                	mv	a0,s1
    8000238c:	925fe0ef          	jal	80000cb0 <release>
}
    80002390:	60e2                	ld	ra,24(sp)
    80002392:	6442                	ld	s0,16(sp)
    80002394:	64a2                	ld	s1,8(sp)
    80002396:	6105                	addi	sp,sp,32
    80002398:	8082                	ret

000000008000239a <killed>:

int
killed(struct proc *p)
{
    8000239a:	1101                	addi	sp,sp,-32
    8000239c:	ec06                	sd	ra,24(sp)
    8000239e:	e822                	sd	s0,16(sp)
    800023a0:	e426                	sd	s1,8(sp)
    800023a2:	e04a                	sd	s2,0(sp)
    800023a4:	1000                	addi	s0,sp,32
    800023a6:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800023a8:	881fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    800023ac:	549c                	lw	a5,40(s1)
    800023ae:	893e                	mv	s2,a5
  release(&p->lock);
    800023b0:	8526                	mv	a0,s1
    800023b2:	8fffe0ef          	jal	80000cb0 <release>
  return k;
}
    800023b6:	854a                	mv	a0,s2
    800023b8:	60e2                	ld	ra,24(sp)
    800023ba:	6442                	ld	s0,16(sp)
    800023bc:	64a2                	ld	s1,8(sp)
    800023be:	6902                	ld	s2,0(sp)
    800023c0:	6105                	addi	sp,sp,32
    800023c2:	8082                	ret

00000000800023c4 <kwait>:
{
    800023c4:	715d                	addi	sp,sp,-80
    800023c6:	e486                	sd	ra,72(sp)
    800023c8:	e0a2                	sd	s0,64(sp)
    800023ca:	fc26                	sd	s1,56(sp)
    800023cc:	f84a                	sd	s2,48(sp)
    800023ce:	f44e                	sd	s3,40(sp)
    800023d0:	f052                	sd	s4,32(sp)
    800023d2:	ec56                	sd	s5,24(sp)
    800023d4:	e85a                	sd	s6,16(sp)
    800023d6:	e45e                	sd	s7,8(sp)
    800023d8:	0880                	addi	s0,sp,80
    800023da:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800023dc:	d70ff0ef          	jal	8000194c <myproc>
    800023e0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023e2:	00011517          	auipc	a0,0x11
    800023e6:	28e50513          	addi	a0,a0,654 # 80013670 <wait_lock>
    800023ea:	83ffe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800023ee:	4a15                	li	s4,5
        havekids = 1;
    800023f0:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800023f2:	00017997          	auipc	s3,0x17
    800023f6:	29698993          	addi	s3,s3,662 # 80019688 <tickslock>
    release(&wait_lock);
    800023fa:	00011b17          	auipc	s6,0x11
    800023fe:	276b0b13          	addi	s6,s6,630 # 80013670 <wait_lock>
    80002402:	a855                	j	800024b6 <kwait+0xf2>
            release(&pp->lock);
    80002404:	8526                	mv	a0,s1
    80002406:	8abfe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    8000240a:	00011517          	auipc	a0,0x11
    8000240e:	26650513          	addi	a0,a0,614 # 80013670 <wait_lock>
    80002412:	89ffe0ef          	jal	80000cb0 <release>
            return -1;
    80002416:	59fd                	li	s3,-1
    80002418:	a09d                	j	8000247e <kwait+0xba>
        release(&pp->lock);
    8000241a:	8526                	mv	a0,s1
    8000241c:	895fe0ef          	jal	80000cb0 <release>
        havekids = 1;
    80002420:	8756                	mv	a4,s5
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002422:	17048493          	addi	s1,s1,368
    80002426:	07348863          	beq	s1,s3,80002496 <kwait+0xd2>
      if (pp->parent == p && !pp->is_thread) {
    8000242a:	7c9c                	ld	a5,56(s1)
    8000242c:	ff279be3          	bne	a5,s2,80002422 <kwait+0x5e>
    80002430:	1684a783          	lw	a5,360(s1)
    80002434:	f7fd                	bnez	a5,80002422 <kwait+0x5e>
        acquire(&pp->lock);
    80002436:	8526                	mv	a0,s1
    80002438:	ff0fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    8000243c:	4c9c                	lw	a5,24(s1)
    8000243e:	fd479ee3          	bne	a5,s4,8000241a <kwait+0x56>
          pid = pp->pid;
    80002442:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    80002446:	000b8e63          	beqz	s7,80002462 <kwait+0x9e>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    8000244a:	4711                	li	a4,4
    8000244c:	02c48693          	addi	a3,s1,44
    80002450:	865e                	mv	a2,s7
    80002452:	04893583          	ld	a1,72(s2)
    80002456:	05093503          	ld	a0,80(s2)
    8000245a:	92cff0ef          	jal	80001586 <copyout>
          if (addr != 0 &&
    8000245e:	fa0543e3          	bltz	a0,80002404 <kwait+0x40>
          pp->parent = 0;
    80002462:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    80002466:	8526                	mv	a0,s1
    80002468:	eb4ff0ef          	jal	80001b1c <freeproc>
          release(&pp->lock);
    8000246c:	8526                	mv	a0,s1
    8000246e:	843fe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    80002472:	00011517          	auipc	a0,0x11
    80002476:	1fe50513          	addi	a0,a0,510 # 80013670 <wait_lock>
    8000247a:	837fe0ef          	jal	80000cb0 <release>
}
    8000247e:	854e                	mv	a0,s3
    80002480:	60a6                	ld	ra,72(sp)
    80002482:	6406                	ld	s0,64(sp)
    80002484:	74e2                	ld	s1,56(sp)
    80002486:	7942                	ld	s2,48(sp)
    80002488:	79a2                	ld	s3,40(sp)
    8000248a:	7a02                	ld	s4,32(sp)
    8000248c:	6ae2                	ld	s5,24(sp)
    8000248e:	6b42                	ld	s6,16(sp)
    80002490:	6ba2                	ld	s7,8(sp)
    80002492:	6161                	addi	sp,sp,80
    80002494:	8082                	ret
    if (!havekids || killed(p)) {
    80002496:	c715                	beqz	a4,800024c2 <kwait+0xfe>
    80002498:	854a                	mv	a0,s2
    8000249a:	f01ff0ef          	jal	8000239a <killed>
    8000249e:	e115                	bnez	a0,800024c2 <kwait+0xfe>
    sleep_prepare(p); //DOC: wait-sleep
    800024a0:	854a                	mv	a0,s2
    800024a2:	c9bff0ef          	jal	8000213c <sleep_prepare>
    release(&wait_lock);
    800024a6:	855a                	mv	a0,s6
    800024a8:	809fe0ef          	jal	80000cb0 <release>
    sleep();
    800024ac:	ccdff0ef          	jal	80002178 <sleep>
    acquire(&wait_lock);
    800024b0:	855a                	mv	a0,s6
    800024b2:	f76fe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    800024b6:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800024b8:	00011497          	auipc	s1,0x11
    800024bc:	5d048493          	addi	s1,s1,1488 # 80013a88 <proc>
    800024c0:	b7ad                	j	8000242a <kwait+0x66>
      release(&wait_lock);
    800024c2:	00011517          	auipc	a0,0x11
    800024c6:	1ae50513          	addi	a0,a0,430 # 80013670 <wait_lock>
    800024ca:	fe6fe0ef          	jal	80000cb0 <release>
      return -1;
    800024ce:	59fd                	li	s3,-1
    800024d0:	b77d                	j	8000247e <kwait+0xba>

00000000800024d2 <kjoin>:
{
    800024d2:	7139                	addi	sp,sp,-64
    800024d4:	fc06                	sd	ra,56(sp)
    800024d6:	f822                	sd	s0,48(sp)
    800024d8:	f426                	sd	s1,40(sp)
    800024da:	f04a                	sd	s2,32(sp)
    800024dc:	ec4e                	sd	s3,24(sp)
    800024de:	e852                	sd	s4,16(sp)
    800024e0:	e456                	sd	s5,8(sp)
    800024e2:	e05a                	sd	s6,0(sp)
    800024e4:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800024e6:	c66ff0ef          	jal	8000194c <myproc>
    800024ea:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024ec:	00011517          	auipc	a0,0x11
    800024f0:	18450513          	addi	a0,a0,388 # 80013670 <wait_lock>
    800024f4:	f34fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800024f8:	4a15                	li	s4,5
        havethreads = 1;
    800024fa:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800024fc:	00017997          	auipc	s3,0x17
    80002500:	18c98993          	addi	s3,s3,396 # 80019688 <tickslock>
    release(&wait_lock);
    80002504:	00011b17          	auipc	s6,0x11
    80002508:	16cb0b13          	addi	s6,s6,364 # 80013670 <wait_lock>
    8000250c:	a041                	j	8000258c <kjoin+0xba>
        release(&pp->lock);
    8000250e:	8526                	mv	a0,s1
    80002510:	fa0fe0ef          	jal	80000cb0 <release>
        havethreads = 1;
    80002514:	8756                	mv	a4,s5
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002516:	17048493          	addi	s1,s1,368
    8000251a:	05348963          	beq	s1,s3,8000256c <kjoin+0x9a>
      if (pp->parent == p && pp->is_thread) {
    8000251e:	7c9c                	ld	a5,56(s1)
    80002520:	ff279be3          	bne	a5,s2,80002516 <kjoin+0x44>
    80002524:	1684a783          	lw	a5,360(s1)
    80002528:	d7fd                	beqz	a5,80002516 <kjoin+0x44>
        acquire(&pp->lock);
    8000252a:	8526                	mv	a0,s1
    8000252c:	efcfe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002530:	4c9c                	lw	a5,24(s1)
    80002532:	fd479ee3          	bne	a5,s4,8000250e <kjoin+0x3c>
          pid = pp->pid;
    80002536:	0304a903          	lw	s2,48(s1)
          pp->parent = 0;
    8000253a:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    8000253e:	8526                	mv	a0,s1
    80002540:	ddcff0ef          	jal	80001b1c <freeproc>
          release(&pp->lock);
    80002544:	8526                	mv	a0,s1
    80002546:	f6afe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    8000254a:	00011517          	auipc	a0,0x11
    8000254e:	12650513          	addi	a0,a0,294 # 80013670 <wait_lock>
    80002552:	f5efe0ef          	jal	80000cb0 <release>
}
    80002556:	854a                	mv	a0,s2
    80002558:	70e2                	ld	ra,56(sp)
    8000255a:	7442                	ld	s0,48(sp)
    8000255c:	74a2                	ld	s1,40(sp)
    8000255e:	7902                	ld	s2,32(sp)
    80002560:	69e2                	ld	s3,24(sp)
    80002562:	6a42                	ld	s4,16(sp)
    80002564:	6aa2                	ld	s5,8(sp)
    80002566:	6b02                	ld	s6,0(sp)
    80002568:	6121                	addi	sp,sp,64
    8000256a:	8082                	ret
    if (!havethreads || killed(p)) {
    8000256c:	c715                	beqz	a4,80002598 <kjoin+0xc6>
    8000256e:	854a                	mv	a0,s2
    80002570:	e2bff0ef          	jal	8000239a <killed>
    80002574:	e115                	bnez	a0,80002598 <kjoin+0xc6>
    sleep_prepare(p);
    80002576:	854a                	mv	a0,s2
    80002578:	bc5ff0ef          	jal	8000213c <sleep_prepare>
    release(&wait_lock);
    8000257c:	855a                	mv	a0,s6
    8000257e:	f32fe0ef          	jal	80000cb0 <release>
    sleep();
    80002582:	bf7ff0ef          	jal	80002178 <sleep>
    acquire(&wait_lock);
    80002586:	855a                	mv	a0,s6
    80002588:	ea0fe0ef          	jal	80000c28 <acquire>
    havethreads = 0;
    8000258c:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000258e:	00011497          	auipc	s1,0x11
    80002592:	4fa48493          	addi	s1,s1,1274 # 80013a88 <proc>
    80002596:	b761                	j	8000251e <kjoin+0x4c>
      release(&wait_lock);
    80002598:	00011517          	auipc	a0,0x11
    8000259c:	0d850513          	addi	a0,a0,216 # 80013670 <wait_lock>
    800025a0:	f10fe0ef          	jal	80000cb0 <release>
      return -1;
    800025a4:	597d                	li	s2,-1
    800025a6:	bf45                	j	80002556 <kjoin+0x84>

00000000800025a8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025a8:	7179                	addi	sp,sp,-48
    800025aa:	f406                	sd	ra,40(sp)
    800025ac:	f022                	sd	s0,32(sp)
    800025ae:	ec26                	sd	s1,24(sp)
    800025b0:	e84a                	sd	s2,16(sp)
    800025b2:	e44e                	sd	s3,8(sp)
    800025b4:	e052                	sd	s4,0(sp)
    800025b6:	1800                	addi	s0,sp,48
    800025b8:	84aa                	mv	s1,a0
    800025ba:	8a2e                	mv	s4,a1
    800025bc:	89b2                	mv	s3,a2
    800025be:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800025c0:	b8cff0ef          	jal	8000194c <myproc>
  if (user_dst) {
    800025c4:	c085                	beqz	s1,800025e4 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    800025c6:	874a                	mv	a4,s2
    800025c8:	86ce                	mv	a3,s3
    800025ca:	8652                	mv	a2,s4
    800025cc:	652c                	ld	a1,72(a0)
    800025ce:	6928                	ld	a0,80(a0)
    800025d0:	fb7fe0ef          	jal	80001586 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025d4:	70a2                	ld	ra,40(sp)
    800025d6:	7402                	ld	s0,32(sp)
    800025d8:	64e2                	ld	s1,24(sp)
    800025da:	6942                	ld	s2,16(sp)
    800025dc:	69a2                	ld	s3,8(sp)
    800025de:	6a02                	ld	s4,0(sp)
    800025e0:	6145                	addi	sp,sp,48
    800025e2:	8082                	ret
    memmove((char *)dst, src, len);
    800025e4:	0009061b          	sext.w	a2,s2
    800025e8:	85ce                	mv	a1,s3
    800025ea:	8552                	mv	a0,s4
    800025ec:	f5cfe0ef          	jal	80000d48 <memmove>
    return 0;
    800025f0:	8526                	mv	a0,s1
    800025f2:	b7cd                	j	800025d4 <either_copyout+0x2c>

00000000800025f4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025f4:	7179                	addi	sp,sp,-48
    800025f6:	f406                	sd	ra,40(sp)
    800025f8:	f022                	sd	s0,32(sp)
    800025fa:	ec26                	sd	s1,24(sp)
    800025fc:	e84a                	sd	s2,16(sp)
    800025fe:	e44e                	sd	s3,8(sp)
    80002600:	e052                	sd	s4,0(sp)
    80002602:	1800                	addi	s0,sp,48
    80002604:	8a2a                	mv	s4,a0
    80002606:	84ae                	mv	s1,a1
    80002608:	89b2                	mv	s3,a2
    8000260a:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000260c:	b40ff0ef          	jal	8000194c <myproc>
  if (user_src) {
    80002610:	c085                	beqz	s1,80002630 <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    80002612:	874a                	mv	a4,s2
    80002614:	86ce                	mv	a3,s3
    80002616:	8652                	mv	a2,s4
    80002618:	652c                	ld	a1,72(a0)
    8000261a:	6928                	ld	a0,80(a0)
    8000261c:	830ff0ef          	jal	8000164c <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002620:	70a2                	ld	ra,40(sp)
    80002622:	7402                	ld	s0,32(sp)
    80002624:	64e2                	ld	s1,24(sp)
    80002626:	6942                	ld	s2,16(sp)
    80002628:	69a2                	ld	s3,8(sp)
    8000262a:	6a02                	ld	s4,0(sp)
    8000262c:	6145                	addi	sp,sp,48
    8000262e:	8082                	ret
    memmove(dst, (char *)src, len);
    80002630:	0009061b          	sext.w	a2,s2
    80002634:	85ce                	mv	a1,s3
    80002636:	8552                	mv	a0,s4
    80002638:	f10fe0ef          	jal	80000d48 <memmove>
    return 0;
    8000263c:	8526                	mv	a0,s1
    8000263e:	b7cd                	j	80002620 <either_copyin+0x2c>

0000000080002640 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002640:	715d                	addi	sp,sp,-80
    80002642:	e486                	sd	ra,72(sp)
    80002644:	e0a2                	sd	s0,64(sp)
    80002646:	fc26                	sd	s1,56(sp)
    80002648:	f84a                	sd	s2,48(sp)
    8000264a:	f44e                	sd	s3,40(sp)
    8000264c:	f052                	sd	s4,32(sp)
    8000264e:	ec56                	sd	s5,24(sp)
    80002650:	e85a                	sd	s6,16(sp)
    80002652:	e45e                	sd	s7,8(sp)
    80002654:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002656:	00006517          	auipc	a0,0x6
    8000265a:	a2250513          	addi	a0,a0,-1502 # 80008078 <etext+0x78>
    8000265e:	eadfd0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002662:	00011497          	auipc	s1,0x11
    80002666:	57e48493          	addi	s1,s1,1406 # 80013be0 <proc+0x158>
    8000266a:	00017917          	auipc	s2,0x17
    8000266e:	17690913          	addi	s2,s2,374 # 800197e0 <sems+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002672:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002674:	00006997          	auipc	s3,0x6
    80002678:	bac98993          	addi	s3,s3,-1108 # 80008220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    8000267c:	00006a97          	auipc	s5,0x6
    80002680:	baca8a93          	addi	s5,s5,-1108 # 80008228 <etext+0x228>
    printk("\n");
    80002684:	00006a17          	auipc	s4,0x6
    80002688:	9f4a0a13          	addi	s4,s4,-1548 # 80008078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000268c:	00006b97          	auipc	s7,0x6
    80002690:	0c4b8b93          	addi	s7,s7,196 # 80008750 <states.0>
    80002694:	a829                	j	800026ae <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002696:	ed86a583          	lw	a1,-296(a3)
    8000269a:	8556                	mv	a0,s5
    8000269c:	e6ffd0ef          	jal	8000050a <printk>
    printk("\n");
    800026a0:	8552                	mv	a0,s4
    800026a2:	e69fd0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800026a6:	17048493          	addi	s1,s1,368
    800026aa:	03248263          	beq	s1,s2,800026ce <procdump+0x8e>
    if (p->state == UNUSED)
    800026ae:	86a6                	mv	a3,s1
    800026b0:	ec04a783          	lw	a5,-320(s1)
    800026b4:	dbed                	beqz	a5,800026a6 <procdump+0x66>
      state = "???";
    800026b6:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b8:	fcfb6fe3          	bltu	s6,a5,80002696 <procdump+0x56>
    800026bc:	02079713          	slli	a4,a5,0x20
    800026c0:	01d75793          	srli	a5,a4,0x1d
    800026c4:	97de                	add	a5,a5,s7
    800026c6:	6390                	ld	a2,0(a5)
    800026c8:	f679                	bnez	a2,80002696 <procdump+0x56>
      state = "???";
    800026ca:	864e                	mv	a2,s3
    800026cc:	b7e9                	j	80002696 <procdump+0x56>
  }
}
    800026ce:	60a6                	ld	ra,72(sp)
    800026d0:	6406                	ld	s0,64(sp)
    800026d2:	74e2                	ld	s1,56(sp)
    800026d4:	7942                	ld	s2,48(sp)
    800026d6:	79a2                	ld	s3,40(sp)
    800026d8:	7a02                	ld	s4,32(sp)
    800026da:	6ae2                	ld	s5,24(sp)
    800026dc:	6b42                	ld	s6,16(sp)
    800026de:	6ba2                	ld	s7,8(sp)
    800026e0:	6161                	addi	sp,sp,80
    800026e2:	8082                	ret

00000000800026e4 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800026e4:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800026e8:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800026ec:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800026ee:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800026f0:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800026f4:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800026f8:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800026fc:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002700:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002704:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002708:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000270c:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002710:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002714:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002718:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000271c:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002720:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002722:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002724:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002728:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000272c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002730:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002734:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002738:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000273c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002740:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002744:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002748:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000274c:	8082                	ret

000000008000274e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000274e:	1141                	addi	sp,sp,-16
    80002750:	e406                	sd	ra,8(sp)
    80002752:	e022                	sd	s0,0(sp)
    80002754:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002756:	00006597          	auipc	a1,0x6
    8000275a:	b1258593          	addi	a1,a1,-1262 # 80008268 <etext+0x268>
    8000275e:	00017517          	auipc	a0,0x17
    80002762:	f2a50513          	addi	a0,a0,-214 # 80019688 <tickslock>
    80002766:	c42fe0ef          	jal	80000ba8 <initlock>
}
    8000276a:	60a2                	ld	ra,8(sp)
    8000276c:	6402                	ld	s0,0(sp)
    8000276e:	0141                	addi	sp,sp,16
    80002770:	8082                	ret

0000000080002772 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002772:	1141                	addi	sp,sp,-16
    80002774:	e406                	sd	ra,8(sp)
    80002776:	e022                	sd	s0,0(sp)
    80002778:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000277a:	00003797          	auipc	a5,0x3
    8000277e:	38678793          	addi	a5,a5,902 # 80005b00 <kernelvec>
    80002782:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002786:	60a2                	ld	ra,8(sp)
    80002788:	6402                	ld	s0,0(sp)
    8000278a:	0141                	addi	sp,sp,16
    8000278c:	8082                	ret

000000008000278e <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000278e:	1141                	addi	sp,sp,-16
    80002790:	e406                	sd	ra,8(sp)
    80002792:	e022                	sd	s0,0(sp)
    80002794:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002796:	9b6ff0ef          	jal	8000194c <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    8000279a:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000279e:	04000737          	lui	a4,0x4000
    800027a2:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800027a4:	0732                	slli	a4,a4,0xc
    800027a6:	00005797          	auipc	a5,0x5
    800027aa:	85a78793          	addi	a5,a5,-1958 # 80007000 <_trampoline>
    800027ae:	00005697          	auipc	a3,0x5
    800027b2:	85268693          	addi	a3,a3,-1966 # 80007000 <_trampoline>
    800027b6:	8f95                	sub	a5,a5,a3
    800027b8:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    800027ba:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027be:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    800027c0:	18002773          	csrr	a4,satp
    800027c4:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027c6:	6d38                	ld	a4,88(a0)
    800027c8:	613c                	ld	a5,64(a0)
    800027ca:	6685                	lui	a3,0x1
    800027cc:	97b6                	add	a5,a5,a3
    800027ce:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027d0:	6d3c                	ld	a5,88(a0)
    800027d2:	00000717          	auipc	a4,0x0
    800027d6:	0fc70713          	addi	a4,a4,252 # 800028ce <usertrap>
    800027da:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800027dc:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    800027de:	8712                	mv	a4,tp
    800027e0:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027e2:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027e6:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027ea:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800027ee:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027f2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800027f4:	6f9c                	ld	a5,24(a5)
    800027f6:	14179073          	csrw	sepc,a5
}
    800027fa:	60a2                	ld	ra,8(sp)
    800027fc:	6402                	ld	s0,0(sp)
    800027fe:	0141                	addi	sp,sp,16
    80002800:	8082                	ret

0000000080002802 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002802:	1141                	addi	sp,sp,-16
    80002804:	e406                	sd	ra,8(sp)
    80002806:	e022                	sd	s0,0(sp)
    80002808:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    8000280a:	90eff0ef          	jal	80001918 <cpuid>
    8000280e:	cd11                	beqz	a0,8000282a <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    80002810:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002814:	000f4737          	lui	a4,0xf4
    80002818:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000281c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000281e:	14d79073          	csrw	stimecmp,a5
}
    80002822:	60a2                	ld	ra,8(sp)
    80002824:	6402                	ld	s0,0(sp)
    80002826:	0141                	addi	sp,sp,16
    80002828:	8082                	ret
    acquire(&tickslock);
    8000282a:	00017517          	auipc	a0,0x17
    8000282e:	e5e50513          	addi	a0,a0,-418 # 80019688 <tickslock>
    80002832:	bf6fe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002836:	00009717          	auipc	a4,0x9
    8000283a:	d2270713          	addi	a4,a4,-734 # 8000b558 <ticks>
    8000283e:	431c                	lw	a5,0(a4)
    80002840:	2785                	addiw	a5,a5,1
    80002842:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002844:	853a                	mv	a0,a4
    80002846:	963ff0ef          	jal	800021a8 <wakeup>
    release(&tickslock);
    8000284a:	00017517          	auipc	a0,0x17
    8000284e:	e3e50513          	addi	a0,a0,-450 # 80019688 <tickslock>
    80002852:	c5efe0ef          	jal	80000cb0 <release>
    80002856:	bf6d                	j	80002810 <clockintr+0xe>

0000000080002858 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002858:	1101                	addi	sp,sp,-32
    8000285a:	ec06                	sd	ra,24(sp)
    8000285c:	e822                	sd	s0,16(sp)
    8000285e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    80002860:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002864:	57fd                	li	a5,-1
    80002866:	17fe                	slli	a5,a5,0x3f
    80002868:	07a5                	addi	a5,a5,9
    8000286a:	00f70c63          	beq	a4,a5,80002882 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    8000286e:	57fd                	li	a5,-1
    80002870:	17fe                	slli	a5,a5,0x3f
    80002872:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002874:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002876:	04f70863          	beq	a4,a5,800028c6 <devintr+0x6e>
  }
}
    8000287a:	60e2                	ld	ra,24(sp)
    8000287c:	6442                	ld	s0,16(sp)
    8000287e:	6105                	addi	sp,sp,32
    80002880:	8082                	ret
    80002882:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002884:	32a030ef          	jal	80005bae <plic_claim>
    80002888:	872a                	mv	a4,a0
    8000288a:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    8000288c:	47a9                	li	a5,10
    8000288e:	00f50963          	beq	a0,a5,800028a0 <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    80002892:	4785                	li	a5,1
    80002894:	00f50963          	beq	a0,a5,800028a6 <devintr+0x4e>
    return 1;
    80002898:	4505                	li	a0,1
    } else if (irq) {
    8000289a:	eb09                	bnez	a4,800028ac <devintr+0x54>
    8000289c:	64a2                	ld	s1,8(sp)
    8000289e:	bff1                	j	8000287a <devintr+0x22>
      uartintr();
    800028a0:	94efe0ef          	jal	800009ee <uartintr>
    if (irq)
    800028a4:	a819                	j	800028ba <devintr+0x62>
      virtio_disk_intr();
    800028a6:	7c4030ef          	jal	8000606a <virtio_disk_intr>
    if (irq)
    800028aa:	a801                	j	800028ba <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    800028ac:	85ba                	mv	a1,a4
    800028ae:	00006517          	auipc	a0,0x6
    800028b2:	9c250513          	addi	a0,a0,-1598 # 80008270 <etext+0x270>
    800028b6:	c55fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    800028ba:	8526                	mv	a0,s1
    800028bc:	314030ef          	jal	80005bd0 <plic_complete>
    return 1;
    800028c0:	4505                	li	a0,1
    800028c2:	64a2                	ld	s1,8(sp)
    800028c4:	bf5d                	j	8000287a <devintr+0x22>
    clockintr();
    800028c6:	f3dff0ef          	jal	80002802 <clockintr>
    return 2;
    800028ca:	4509                	li	a0,2
    800028cc:	b77d                	j	8000287a <devintr+0x22>

00000000800028ce <usertrap>:
{
    800028ce:	1101                	addi	sp,sp,-32
    800028d0:	ec06                	sd	ra,24(sp)
    800028d2:	e822                	sd	s0,16(sp)
    800028d4:	e426                	sd	s1,8(sp)
    800028d6:	e04a                	sd	s2,0(sp)
    800028d8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800028da:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800028de:	1007f793          	andi	a5,a5,256
    800028e2:	eba5                	bnez	a5,80002952 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800028e4:	00003797          	auipc	a5,0x3
    800028e8:	21c78793          	addi	a5,a5,540 # 80005b00 <kernelvec>
    800028ec:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028f0:	85cff0ef          	jal	8000194c <myproc>
    800028f4:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800028f6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800028f8:	14102773          	csrr	a4,sepc
    800028fc:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800028fe:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    80002902:	47a1                	li	a5,8
    80002904:	04f70d63          	beq	a4,a5,8000295e <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    80002908:	f51ff0ef          	jal	80002858 <devintr>
    8000290c:	892a                	mv	s2,a0
    8000290e:	e54d                	bnez	a0,800029b8 <usertrap+0xea>
    80002910:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002914:	47bd                	li	a5,15
    80002916:	08f70463          	beq	a4,a5,8000299e <usertrap+0xd0>
    8000291a:	14202773          	csrr	a4,scause
    8000291e:	47b5                	li	a5,13
    80002920:	06f70f63          	beq	a4,a5,8000299e <usertrap+0xd0>
    80002924:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002928:	5890                	lw	a2,48(s1)
    8000292a:	00006517          	auipc	a0,0x6
    8000292e:	98650513          	addi	a0,a0,-1658 # 800082b0 <etext+0x2b0>
    80002932:	bd9fd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002936:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000293a:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000293e:	00006517          	auipc	a0,0x6
    80002942:	9a250513          	addi	a0,a0,-1630 # 800082e0 <etext+0x2e0>
    80002946:	bc5fd0ef          	jal	8000050a <printk>
    setkilled(p);
    8000294a:	8526                	mv	a0,s1
    8000294c:	a2bff0ef          	jal	80002376 <setkilled>
    80002950:	a015                	j	80002974 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    80002952:	00006517          	auipc	a0,0x6
    80002956:	93e50513          	addi	a0,a0,-1730 # 80008290 <etext+0x290>
    8000295a:	edbfd0ef          	jal	80000834 <panic>
    if (killed(p))
    8000295e:	a3dff0ef          	jal	8000239a <killed>
    80002962:	e915                	bnez	a0,80002996 <usertrap+0xc8>
    p->trapframe->epc += 4;
    80002964:	6cb8                	ld	a4,88(s1)
    80002966:	6f1c                	ld	a5,24(a4)
    80002968:	0791                	addi	a5,a5,4
    8000296a:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    8000296c:	10016073          	csrsi	sstatus,2
    syscall();
    80002970:	244000ef          	jal	80002bb4 <syscall>
  if (killed(p))
    80002974:	8526                	mv	a0,s1
    80002976:	a25ff0ef          	jal	8000239a <killed>
    8000297a:	e521                	bnez	a0,800029c2 <usertrap+0xf4>
  prepare_return();
    8000297c:	e13ff0ef          	jal	8000278e <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002980:	68a8                	ld	a0,80(s1)
    80002982:	8131                	srli	a0,a0,0xc
    80002984:	57fd                	li	a5,-1
    80002986:	17fe                	slli	a5,a5,0x3f
    80002988:	8d5d                	or	a0,a0,a5
}
    8000298a:	60e2                	ld	ra,24(sp)
    8000298c:	6442                	ld	s0,16(sp)
    8000298e:	64a2                	ld	s1,8(sp)
    80002990:	6902                	ld	s2,0(sp)
    80002992:	6105                	addi	sp,sp,32
    80002994:	8082                	ret
      kexit(-1);
    80002996:	557d                	li	a0,-1
    80002998:	8cdff0ef          	jal	80002264 <kexit>
    8000299c:	b7e1                	j	80002964 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    8000299e:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    800029a2:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    800029a6:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    800029a8:	0016b693          	seqz	a3,a3
    800029ac:	64ac                	ld	a1,72(s1)
    800029ae:	68a8                	ld	a0,80(s1)
    800029b0:	b5bfe0ef          	jal	8000150a <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800029b4:	f161                	bnez	a0,80002974 <usertrap+0xa6>
    800029b6:	b7bd                	j	80002924 <usertrap+0x56>
  if (killed(p))
    800029b8:	8526                	mv	a0,s1
    800029ba:	9e1ff0ef          	jal	8000239a <killed>
    800029be:	c511                	beqz	a0,800029ca <usertrap+0xfc>
    800029c0:	a011                	j	800029c4 <usertrap+0xf6>
    800029c2:	4901                	li	s2,0
    kexit(-1);
    800029c4:	557d                	li	a0,-1
    800029c6:	89fff0ef          	jal	80002264 <kexit>
  if (which_dev == 2)
    800029ca:	4789                	li	a5,2
    800029cc:	faf918e3          	bne	s2,a5,8000297c <usertrap+0xae>
    yield();
    800029d0:	f40ff0ef          	jal	80002110 <yield>
    800029d4:	b765                	j	8000297c <usertrap+0xae>

00000000800029d6 <kerneltrap>:
{
    800029d6:	7179                	addi	sp,sp,-48
    800029d8:	f406                	sd	ra,40(sp)
    800029da:	f022                	sd	s0,32(sp)
    800029dc:	ec26                	sd	s1,24(sp)
    800029de:	e84a                	sd	s2,16(sp)
    800029e0:	e44e                	sd	s3,8(sp)
    800029e2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    800029e4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800029e8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800029ec:	142027f3          	csrr	a5,scause
    800029f0:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    800029f2:	1004f793          	andi	a5,s1,256
    800029f6:	c795                	beqz	a5,80002a22 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800029f8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029fc:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800029fe:	eb85                	bnez	a5,80002a2e <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    80002a00:	e59ff0ef          	jal	80002858 <devintr>
    80002a04:	c91d                	beqz	a0,80002a3a <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    80002a06:	4789                	li	a5,2
    80002a08:	04f50a63          	beq	a0,a5,80002a5c <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002a0c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002a10:	10049073          	csrw	sstatus,s1
}
    80002a14:	70a2                	ld	ra,40(sp)
    80002a16:	7402                	ld	s0,32(sp)
    80002a18:	64e2                	ld	s1,24(sp)
    80002a1a:	6942                	ld	s2,16(sp)
    80002a1c:	69a2                	ld	s3,8(sp)
    80002a1e:	6145                	addi	sp,sp,48
    80002a20:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a22:	00006517          	auipc	a0,0x6
    80002a26:	8e650513          	addi	a0,a0,-1818 # 80008308 <etext+0x308>
    80002a2a:	e0bfd0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a2e:	00006517          	auipc	a0,0x6
    80002a32:	90250513          	addi	a0,a0,-1790 # 80008330 <etext+0x330>
    80002a36:	dfffd0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002a3a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002a3e:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    80002a42:	85ce                	mv	a1,s3
    80002a44:	00006517          	auipc	a0,0x6
    80002a48:	90c50513          	addi	a0,a0,-1780 # 80008350 <etext+0x350>
    80002a4c:	abffd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    80002a50:	00006517          	auipc	a0,0x6
    80002a54:	92850513          	addi	a0,a0,-1752 # 80008378 <etext+0x378>
    80002a58:	dddfd0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    80002a5c:	ef1fe0ef          	jal	8000194c <myproc>
    80002a60:	d555                	beqz	a0,80002a0c <kerneltrap+0x36>
    yield();
    80002a62:	eaeff0ef          	jal	80002110 <yield>
    80002a66:	b75d                	j	80002a0c <kerneltrap+0x36>

0000000080002a68 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a68:	1101                	addi	sp,sp,-32
    80002a6a:	ec06                	sd	ra,24(sp)
    80002a6c:	e822                	sd	s0,16(sp)
    80002a6e:	e426                	sd	s1,8(sp)
    80002a70:	1000                	addi	s0,sp,32
    80002a72:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a74:	ed9fe0ef          	jal	8000194c <myproc>
  switch (n) {
    80002a78:	4795                	li	a5,5
    80002a7a:	0497e163          	bltu	a5,s1,80002abc <argraw+0x54>
    80002a7e:	048a                	slli	s1,s1,0x2
    80002a80:	00006717          	auipc	a4,0x6
    80002a84:	d0070713          	addi	a4,a4,-768 # 80008780 <states.0+0x30>
    80002a88:	94ba                	add	s1,s1,a4
    80002a8a:	409c                	lw	a5,0(s1)
    80002a8c:	97ba                	add	a5,a5,a4
    80002a8e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a90:	6d3c                	ld	a5,88(a0)
    80002a92:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a94:	60e2                	ld	ra,24(sp)
    80002a96:	6442                	ld	s0,16(sp)
    80002a98:	64a2                	ld	s1,8(sp)
    80002a9a:	6105                	addi	sp,sp,32
    80002a9c:	8082                	ret
    return p->trapframe->a1;
    80002a9e:	6d3c                	ld	a5,88(a0)
    80002aa0:	7fa8                	ld	a0,120(a5)
    80002aa2:	bfcd                	j	80002a94 <argraw+0x2c>
    return p->trapframe->a2;
    80002aa4:	6d3c                	ld	a5,88(a0)
    80002aa6:	63c8                	ld	a0,128(a5)
    80002aa8:	b7f5                	j	80002a94 <argraw+0x2c>
    return p->trapframe->a3;
    80002aaa:	6d3c                	ld	a5,88(a0)
    80002aac:	67c8                	ld	a0,136(a5)
    80002aae:	b7dd                	j	80002a94 <argraw+0x2c>
    return p->trapframe->a4;
    80002ab0:	6d3c                	ld	a5,88(a0)
    80002ab2:	6bc8                	ld	a0,144(a5)
    80002ab4:	b7c5                	j	80002a94 <argraw+0x2c>
    return p->trapframe->a5;
    80002ab6:	6d3c                	ld	a5,88(a0)
    80002ab8:	6fc8                	ld	a0,152(a5)
    80002aba:	bfe9                	j	80002a94 <argraw+0x2c>
  panic("argraw");
    80002abc:	00006517          	auipc	a0,0x6
    80002ac0:	8cc50513          	addi	a0,a0,-1844 # 80008388 <etext+0x388>
    80002ac4:	d71fd0ef          	jal	80000834 <panic>

0000000080002ac8 <fetchaddr>:
{
    80002ac8:	1101                	addi	sp,sp,-32
    80002aca:	ec06                	sd	ra,24(sp)
    80002acc:	e822                	sd	s0,16(sp)
    80002ace:	e426                	sd	s1,8(sp)
    80002ad0:	e04a                	sd	s2,0(sp)
    80002ad2:	1000                	addi	s0,sp,32
    80002ad4:	84aa                	mv	s1,a0
    80002ad6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ad8:	e75fe0ef          	jal	8000194c <myproc>
  if (addr >= p->sz ||
    80002adc:	652c                	ld	a1,72(a0)
    80002ade:	02b4f663          	bgeu	s1,a1,80002b0a <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ae2:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002ae6:	02f5e463          	bltu	a1,a5,80002b0e <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    80002aea:	4721                	li	a4,8
    80002aec:	86a6                	mv	a3,s1
    80002aee:	864a                	mv	a2,s2
    80002af0:	6928                	ld	a0,80(a0)
    80002af2:	b5bfe0ef          	jal	8000164c <copyin>
    80002af6:	00a03533          	snez	a0,a0
    80002afa:	40a0053b          	negw	a0,a0
}
    80002afe:	60e2                	ld	ra,24(sp)
    80002b00:	6442                	ld	s0,16(sp)
    80002b02:	64a2                	ld	s1,8(sp)
    80002b04:	6902                	ld	s2,0(sp)
    80002b06:	6105                	addi	sp,sp,32
    80002b08:	8082                	ret
    return -1;
    80002b0a:	557d                	li	a0,-1
    80002b0c:	bfcd                	j	80002afe <fetchaddr+0x36>
    80002b0e:	557d                	li	a0,-1
    80002b10:	b7fd                	j	80002afe <fetchaddr+0x36>

0000000080002b12 <fetchstr>:
{
    80002b12:	7179                	addi	sp,sp,-48
    80002b14:	f406                	sd	ra,40(sp)
    80002b16:	f022                	sd	s0,32(sp)
    80002b18:	ec26                	sd	s1,24(sp)
    80002b1a:	e84a                	sd	s2,16(sp)
    80002b1c:	e44e                	sd	s3,8(sp)
    80002b1e:	1800                	addi	s0,sp,48
    80002b20:	89aa                	mv	s3,a0
    80002b22:	84ae                	mv	s1,a1
    80002b24:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002b26:	e27fe0ef          	jal	8000194c <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002b2a:	874a                	mv	a4,s2
    80002b2c:	86ce                	mv	a3,s3
    80002b2e:	8626                	mv	a2,s1
    80002b30:	652c                	ld	a1,72(a0)
    80002b32:	6928                	ld	a0,80(a0)
    80002b34:	bb5fe0ef          	jal	800016e8 <copyinstr>
    80002b38:	00054c63          	bltz	a0,80002b50 <fetchstr+0x3e>
  return strlen(buf);
    80002b3c:	8526                	mv	a0,s1
    80002b3e:	b34fe0ef          	jal	80000e72 <strlen>
}
    80002b42:	70a2                	ld	ra,40(sp)
    80002b44:	7402                	ld	s0,32(sp)
    80002b46:	64e2                	ld	s1,24(sp)
    80002b48:	6942                	ld	s2,16(sp)
    80002b4a:	69a2                	ld	s3,8(sp)
    80002b4c:	6145                	addi	sp,sp,48
    80002b4e:	8082                	ret
    return -1;
    80002b50:	557d                	li	a0,-1
    80002b52:	bfc5                	j	80002b42 <fetchstr+0x30>

0000000080002b54 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b54:	1101                	addi	sp,sp,-32
    80002b56:	ec06                	sd	ra,24(sp)
    80002b58:	e822                	sd	s0,16(sp)
    80002b5a:	e426                	sd	s1,8(sp)
    80002b5c:	1000                	addi	s0,sp,32
    80002b5e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b60:	f09ff0ef          	jal	80002a68 <argraw>
    80002b64:	c088                	sw	a0,0(s1)
}
    80002b66:	60e2                	ld	ra,24(sp)
    80002b68:	6442                	ld	s0,16(sp)
    80002b6a:	64a2                	ld	s1,8(sp)
    80002b6c:	6105                	addi	sp,sp,32
    80002b6e:	8082                	ret

0000000080002b70 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b70:	1101                	addi	sp,sp,-32
    80002b72:	ec06                	sd	ra,24(sp)
    80002b74:	e822                	sd	s0,16(sp)
    80002b76:	e426                	sd	s1,8(sp)
    80002b78:	1000                	addi	s0,sp,32
    80002b7a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b7c:	eedff0ef          	jal	80002a68 <argraw>
    80002b80:	e088                	sd	a0,0(s1)
}
    80002b82:	60e2                	ld	ra,24(sp)
    80002b84:	6442                	ld	s0,16(sp)
    80002b86:	64a2                	ld	s1,8(sp)
    80002b88:	6105                	addi	sp,sp,32
    80002b8a:	8082                	ret

0000000080002b8c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b8c:	1101                	addi	sp,sp,-32
    80002b8e:	ec06                	sd	ra,24(sp)
    80002b90:	e822                	sd	s0,16(sp)
    80002b92:	e426                	sd	s1,8(sp)
    80002b94:	e04a                	sd	s2,0(sp)
    80002b96:	1000                	addi	s0,sp,32
    80002b98:	892e                	mv	s2,a1
    80002b9a:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002b9c:	ecdff0ef          	jal	80002a68 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002ba0:	8626                	mv	a2,s1
    80002ba2:	85ca                	mv	a1,s2
    80002ba4:	f6fff0ef          	jal	80002b12 <fetchstr>
}
    80002ba8:	60e2                	ld	ra,24(sp)
    80002baa:	6442                	ld	s0,16(sp)
    80002bac:	64a2                	ld	s1,8(sp)
    80002bae:	6902                	ld	s2,0(sp)
    80002bb0:	6105                	addi	sp,sp,32
    80002bb2:	8082                	ret

0000000080002bb4 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002bb4:	1101                	addi	sp,sp,-32
    80002bb6:	ec06                	sd	ra,24(sp)
    80002bb8:	e822                	sd	s0,16(sp)
    80002bba:	e426                	sd	s1,8(sp)
    80002bbc:	e04a                	sd	s2,0(sp)
    80002bbe:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bc0:	d8dfe0ef          	jal	8000194c <myproc>
    80002bc4:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002bc6:	05853903          	ld	s2,88(a0)
    80002bca:	0a893783          	ld	a5,168(s2)
    80002bce:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bd2:	37fd                	addiw	a5,a5,-1
    80002bd4:	4769                	li	a4,26
    80002bd6:	00f76f63          	bltu	a4,a5,80002bf4 <syscall+0x40>
    80002bda:	00369713          	slli	a4,a3,0x3
    80002bde:	00006797          	auipc	a5,0x6
    80002be2:	bba78793          	addi	a5,a5,-1094 # 80008798 <syscalls>
    80002be6:	97ba                	add	a5,a5,a4
    80002be8:	639c                	ld	a5,0(a5)
    80002bea:	c789                	beqz	a5,80002bf4 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002bec:	9782                	jalr	a5
    80002bee:	06a93823          	sd	a0,112(s2)
    80002bf2:	a829                	j	80002c0c <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002bf4:	15848613          	addi	a2,s1,344
    80002bf8:	588c                	lw	a1,48(s1)
    80002bfa:	00005517          	auipc	a0,0x5
    80002bfe:	79650513          	addi	a0,a0,1942 # 80008390 <etext+0x390>
    80002c02:	909fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002c06:	6cbc                	ld	a5,88(s1)
    80002c08:	577d                	li	a4,-1
    80002c0a:	fbb8                	sd	a4,112(a5)
  }
}
    80002c0c:	60e2                	ld	ra,24(sp)
    80002c0e:	6442                	ld	s0,16(sp)
    80002c10:	64a2                	ld	s1,8(sp)
    80002c12:	6902                	ld	s2,0(sp)
    80002c14:	6105                	addi	sp,sp,32
    80002c16:	8082                	ret

0000000080002c18 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002c18:	1101                	addi	sp,sp,-32
    80002c1a:	ec06                	sd	ra,24(sp)
    80002c1c:	e822                	sd	s0,16(sp)
    80002c1e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c20:	fec40593          	addi	a1,s0,-20
    80002c24:	4501                	li	a0,0
    80002c26:	f2fff0ef          	jal	80002b54 <argint>
  kexit(n);
    80002c2a:	fec42503          	lw	a0,-20(s0)
    80002c2e:	e36ff0ef          	jal	80002264 <kexit>
  return 0; // not reached
}
    80002c32:	4501                	li	a0,0
    80002c34:	60e2                	ld	ra,24(sp)
    80002c36:	6442                	ld	s0,16(sp)
    80002c38:	6105                	addi	sp,sp,32
    80002c3a:	8082                	ret

0000000080002c3c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c3c:	1141                	addi	sp,sp,-16
    80002c3e:	e406                	sd	ra,8(sp)
    80002c40:	e022                	sd	s0,0(sp)
    80002c42:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c44:	d09fe0ef          	jal	8000194c <myproc>
}
    80002c48:	5908                	lw	a0,48(a0)
    80002c4a:	60a2                	ld	ra,8(sp)
    80002c4c:	6402                	ld	s0,0(sp)
    80002c4e:	0141                	addi	sp,sp,16
    80002c50:	8082                	ret

0000000080002c52 <sys_fork>:

uint64
sys_fork(void)
{
    80002c52:	1141                	addi	sp,sp,-16
    80002c54:	e406                	sd	ra,8(sp)
    80002c56:	e022                	sd	s0,0(sp)
    80002c58:	0800                	addi	s0,sp,16
  return kfork();
    80002c5a:	8a4ff0ef          	jal	80001cfe <kfork>
}
    80002c5e:	60a2                	ld	ra,8(sp)
    80002c60:	6402                	ld	s0,0(sp)
    80002c62:	0141                	addi	sp,sp,16
    80002c64:	8082                	ret

0000000080002c66 <sys_wait>:

uint64
sys_wait(void)
{
    80002c66:	1101                	addi	sp,sp,-32
    80002c68:	ec06                	sd	ra,24(sp)
    80002c6a:	e822                	sd	s0,16(sp)
    80002c6c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c6e:	fe840593          	addi	a1,s0,-24
    80002c72:	4501                	li	a0,0
    80002c74:	efdff0ef          	jal	80002b70 <argaddr>
  return kwait(p);
    80002c78:	fe843503          	ld	a0,-24(s0)
    80002c7c:	f48ff0ef          	jal	800023c4 <kwait>
}
    80002c80:	60e2                	ld	ra,24(sp)
    80002c82:	6442                	ld	s0,16(sp)
    80002c84:	6105                	addi	sp,sp,32
    80002c86:	8082                	ret

0000000080002c88 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c88:	7179                	addi	sp,sp,-48
    80002c8a:	f406                	sd	ra,40(sp)
    80002c8c:	f022                	sd	s0,32(sp)
    80002c8e:	ec26                	sd	s1,24(sp)
    80002c90:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002c92:	fd840593          	addi	a1,s0,-40
    80002c96:	4501                	li	a0,0
    80002c98:	ebdff0ef          	jal	80002b54 <argint>
  argint(1, &t);
    80002c9c:	fdc40593          	addi	a1,s0,-36
    80002ca0:	4505                	li	a0,1
    80002ca2:	eb3ff0ef          	jal	80002b54 <argint>
  addr = myproc()->sz;
    80002ca6:	ca7fe0ef          	jal	8000194c <myproc>
    80002caa:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002cac:	fdc42703          	lw	a4,-36(s0)
    80002cb0:	4785                	li	a5,1
    80002cb2:	02f70763          	beq	a4,a5,80002ce0 <sys_sbrk+0x58>
    80002cb6:	fd842783          	lw	a5,-40(s0)
    80002cba:	0207c363          	bltz	a5,80002ce0 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002cbe:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002cc0:	02000737          	lui	a4,0x2000
    80002cc4:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002cc6:	0736                	slli	a4,a4,0xd
    80002cc8:	02f76a63          	bltu	a4,a5,80002cfc <sys_sbrk+0x74>
    80002ccc:	0297e863          	bltu	a5,s1,80002cfc <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002cd0:	c7dfe0ef          	jal	8000194c <myproc>
    80002cd4:	fd842703          	lw	a4,-40(s0)
    80002cd8:	653c                	ld	a5,72(a0)
    80002cda:	97ba                	add	a5,a5,a4
    80002cdc:	e53c                	sd	a5,72(a0)
    80002cde:	a039                	j	80002cec <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002ce0:	fd842503          	lw	a0,-40(s0)
    80002ce4:	fb9fe0ef          	jal	80001c9c <growproc>
    80002ce8:	00054863          	bltz	a0,80002cf8 <sys_sbrk+0x70>
  }
  return addr;
}
    80002cec:	8526                	mv	a0,s1
    80002cee:	70a2                	ld	ra,40(sp)
    80002cf0:	7402                	ld	s0,32(sp)
    80002cf2:	64e2                	ld	s1,24(sp)
    80002cf4:	6145                	addi	sp,sp,48
    80002cf6:	8082                	ret
      return -1;
    80002cf8:	54fd                	li	s1,-1
    80002cfa:	bfcd                	j	80002cec <sys_sbrk+0x64>
      return -1;
    80002cfc:	54fd                	li	s1,-1
    80002cfe:	b7fd                	j	80002cec <sys_sbrk+0x64>

0000000080002d00 <sys_pause>:

uint64
sys_pause(void)
{
    80002d00:	7139                	addi	sp,sp,-64
    80002d02:	fc06                	sd	ra,56(sp)
    80002d04:	f822                	sd	s0,48(sp)
    80002d06:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d08:	fcc40593          	addi	a1,s0,-52
    80002d0c:	4501                	li	a0,0
    80002d0e:	e47ff0ef          	jal	80002b54 <argint>
  if (n < 0)
    80002d12:	fcc42783          	lw	a5,-52(s0)
    80002d16:	0807c063          	bltz	a5,80002d96 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002d1a:	00017517          	auipc	a0,0x17
    80002d1e:	96e50513          	addi	a0,a0,-1682 # 80019688 <tickslock>
    80002d22:	f07fd0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002d26:	fcc42783          	lw	a5,-52(s0)
    80002d2a:	cbb9                	beqz	a5,80002d80 <sys_pause+0x80>
    80002d2c:	f426                	sd	s1,40(sp)
    80002d2e:	f04a                	sd	s2,32(sp)
    80002d30:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002d32:	00009997          	auipc	s3,0x9
    80002d36:	8269a983          	lw	s3,-2010(s3) # 8000b558 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002d3a:	00009917          	auipc	s2,0x9
    80002d3e:	81e90913          	addi	s2,s2,-2018 # 8000b558 <ticks>
    release(&tickslock);
    80002d42:	00017497          	auipc	s1,0x17
    80002d46:	94648493          	addi	s1,s1,-1722 # 80019688 <tickslock>
    if (killed(myproc())) {
    80002d4a:	c03fe0ef          	jal	8000194c <myproc>
    80002d4e:	e4cff0ef          	jal	8000239a <killed>
    80002d52:	e529                	bnez	a0,80002d9c <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002d54:	854a                	mv	a0,s2
    80002d56:	be6ff0ef          	jal	8000213c <sleep_prepare>
    release(&tickslock);
    80002d5a:	8526                	mv	a0,s1
    80002d5c:	f55fd0ef          	jal	80000cb0 <release>
    sleep();
    80002d60:	c18ff0ef          	jal	80002178 <sleep>
    acquire(&tickslock);
    80002d64:	8526                	mv	a0,s1
    80002d66:	ec3fd0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002d6a:	00092783          	lw	a5,0(s2)
    80002d6e:	413787bb          	subw	a5,a5,s3
    80002d72:	fcc42703          	lw	a4,-52(s0)
    80002d76:	fce7eae3          	bltu	a5,a4,80002d4a <sys_pause+0x4a>
    80002d7a:	74a2                	ld	s1,40(sp)
    80002d7c:	7902                	ld	s2,32(sp)
    80002d7e:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002d80:	00017517          	auipc	a0,0x17
    80002d84:	90850513          	addi	a0,a0,-1784 # 80019688 <tickslock>
    80002d88:	f29fd0ef          	jal	80000cb0 <release>
  return 0;
    80002d8c:	4501                	li	a0,0
}
    80002d8e:	70e2                	ld	ra,56(sp)
    80002d90:	7442                	ld	s0,48(sp)
    80002d92:	6121                	addi	sp,sp,64
    80002d94:	8082                	ret
    n = 0;
    80002d96:	fc042623          	sw	zero,-52(s0)
    80002d9a:	b741                	j	80002d1a <sys_pause+0x1a>
      release(&tickslock);
    80002d9c:	00017517          	auipc	a0,0x17
    80002da0:	8ec50513          	addi	a0,a0,-1812 # 80019688 <tickslock>
    80002da4:	f0dfd0ef          	jal	80000cb0 <release>
      return -1;
    80002da8:	557d                	li	a0,-1
    80002daa:	74a2                	ld	s1,40(sp)
    80002dac:	7902                	ld	s2,32(sp)
    80002dae:	69e2                	ld	s3,24(sp)
    80002db0:	bff9                	j	80002d8e <sys_pause+0x8e>

0000000080002db2 <sys_kill>:

uint64
sys_kill(void)
{
    80002db2:	1101                	addi	sp,sp,-32
    80002db4:	ec06                	sd	ra,24(sp)
    80002db6:	e822                	sd	s0,16(sp)
    80002db8:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002dba:	fec40593          	addi	a1,s0,-20
    80002dbe:	4501                	li	a0,0
    80002dc0:	d95ff0ef          	jal	80002b54 <argint>
  return kkill(pid);
    80002dc4:	fec42503          	lw	a0,-20(s0)
    80002dc8:	d42ff0ef          	jal	8000230a <kkill>
}
    80002dcc:	60e2                	ld	ra,24(sp)
    80002dce:	6442                	ld	s0,16(sp)
    80002dd0:	6105                	addi	sp,sp,32
    80002dd2:	8082                	ret

0000000080002dd4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002dd4:	1101                	addi	sp,sp,-32
    80002dd6:	ec06                	sd	ra,24(sp)
    80002dd8:	e822                	sd	s0,16(sp)
    80002dda:	e426                	sd	s1,8(sp)
    80002ddc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dde:	00017517          	auipc	a0,0x17
    80002de2:	8aa50513          	addi	a0,a0,-1878 # 80019688 <tickslock>
    80002de6:	e43fd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002dea:	00008797          	auipc	a5,0x8
    80002dee:	76e7a783          	lw	a5,1902(a5) # 8000b558 <ticks>
    80002df2:	84be                	mv	s1,a5
  release(&tickslock);
    80002df4:	00017517          	auipc	a0,0x17
    80002df8:	89450513          	addi	a0,a0,-1900 # 80019688 <tickslock>
    80002dfc:	eb5fd0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002e00:	02049513          	slli	a0,s1,0x20
    80002e04:	9101                	srli	a0,a0,0x20
    80002e06:	60e2                	ld	ra,24(sp)
    80002e08:	6442                	ld	s0,16(sp)
    80002e0a:	64a2                	ld	s1,8(sp)
    80002e0c:	6105                	addi	sp,sp,32
    80002e0e:	8082                	ret

0000000080002e10 <seminit>:

static struct semaphore sems[MAX_SEM];

void
seminit(void)
{
    80002e10:	7179                	addi	sp,sp,-48
    80002e12:	f406                	sd	ra,40(sp)
    80002e14:	f022                	sd	s0,32(sp)
    80002e16:	ec26                	sd	s1,24(sp)
    80002e18:	e84a                	sd	s2,16(sp)
    80002e1a:	e44e                	sd	s3,8(sp)
    80002e1c:	1800                	addi	s0,sp,48
  for (int i = 0; i < MAX_SEM; i++) {
    80002e1e:	00017497          	auipc	s1,0x17
    80002e22:	88248493          	addi	s1,s1,-1918 # 800196a0 <sems>
    80002e26:	00017997          	auipc	s3,0x17
    80002e2a:	a7a98993          	addi	s3,s3,-1414 # 800198a0 <bcache>
    initlock(&sems[i].lk, "sem");
    80002e2e:	00005917          	auipc	s2,0x5
    80002e32:	58290913          	addi	s2,s2,1410 # 800083b0 <etext+0x3b0>
    80002e36:	85ca                	mv	a1,s2
    80002e38:	8526                	mv	a0,s1
    80002e3a:	d6ffd0ef          	jal	80000ba8 <initlock>
    sems[i].value = 0;
    80002e3e:	0004ac23          	sw	zero,24(s1)
    sems[i].active = 0;
    80002e42:	0004ae23          	sw	zero,28(s1)
  for (int i = 0; i < MAX_SEM; i++) {
    80002e46:	02048493          	addi	s1,s1,32
    80002e4a:	ff3496e3          	bne	s1,s3,80002e36 <seminit+0x26>
  }
}
    80002e4e:	70a2                	ld	ra,40(sp)
    80002e50:	7402                	ld	s0,32(sp)
    80002e52:	64e2                	ld	s1,24(sp)
    80002e54:	6942                	ld	s2,16(sp)
    80002e56:	69a2                	ld	s3,8(sp)
    80002e58:	6145                	addi	sp,sp,48
    80002e5a:	8082                	ret

0000000080002e5c <ksem_init>:

int
ksem_init(int id, int val)
{
  if (id < 0 || id >= MAX_SEM)
    80002e5c:	47bd                	li	a5,15
    80002e5e:	04a7e063          	bltu	a5,a0,80002e9e <ksem_init+0x42>
{
    80002e62:	1101                	addi	sp,sp,-32
    80002e64:	ec06                	sd	ra,24(sp)
    80002e66:	e822                	sd	s0,16(sp)
    80002e68:	e426                	sd	s1,8(sp)
    80002e6a:	e04a                	sd	s2,0(sp)
    80002e6c:	1000                	addi	s0,sp,32
    80002e6e:	892e                	mv	s2,a1
    return -1;
  acquire(&sems[id].lk);
    80002e70:	0516                	slli	a0,a0,0x5
    80002e72:	00017497          	auipc	s1,0x17
    80002e76:	82e48493          	addi	s1,s1,-2002 # 800196a0 <sems>
    80002e7a:	94aa                	add	s1,s1,a0
    80002e7c:	8526                	mv	a0,s1
    80002e7e:	dabfd0ef          	jal	80000c28 <acquire>
  sems[id].value = val;
    80002e82:	0124ac23          	sw	s2,24(s1)
  sems[id].active = 1;
    80002e86:	4785                	li	a5,1
    80002e88:	ccdc                	sw	a5,28(s1)
  release(&sems[id].lk);
    80002e8a:	8526                	mv	a0,s1
    80002e8c:	e25fd0ef          	jal	80000cb0 <release>
  return 0;
    80002e90:	4501                	li	a0,0
}
    80002e92:	60e2                	ld	ra,24(sp)
    80002e94:	6442                	ld	s0,16(sp)
    80002e96:	64a2                	ld	s1,8(sp)
    80002e98:	6902                	ld	s2,0(sp)
    80002e9a:	6105                	addi	sp,sp,32
    80002e9c:	8082                	ret
    return -1;
    80002e9e:	557d                	li	a0,-1
}
    80002ea0:	8082                	ret

0000000080002ea2 <ksem_wait>:

int
ksem_wait(int id)
{
  if (id < 0 || id >= MAX_SEM)
    80002ea2:	47bd                	li	a5,15
    80002ea4:	06a7ea63          	bltu	a5,a0,80002f18 <ksem_wait+0x76>
{
    80002ea8:	7179                	addi	sp,sp,-48
    80002eaa:	f406                	sd	ra,40(sp)
    80002eac:	f022                	sd	s0,32(sp)
    80002eae:	ec26                	sd	s1,24(sp)
    80002eb0:	e44e                	sd	s3,8(sp)
    80002eb2:	1800                	addi	s0,sp,48
    80002eb4:	89aa                	mv	s3,a0
    return -1;
  acquire(&sems[id].lk);
    80002eb6:	00551793          	slli	a5,a0,0x5
    80002eba:	00016497          	auipc	s1,0x16
    80002ebe:	7e648493          	addi	s1,s1,2022 # 800196a0 <sems>
    80002ec2:	94be                	add	s1,s1,a5
    80002ec4:	8526                	mv	a0,s1
    80002ec6:	d63fd0ef          	jal	80000c28 <acquire>
  while (sems[id].value <= 0) {
    80002eca:	4c9c                	lw	a5,24(s1)
    80002ecc:	02f04463          	bgtz	a5,80002ef4 <ksem_wait+0x52>
    80002ed0:	e84a                	sd	s2,16(sp)
    80002ed2:	8926                	mv	s2,s1
    sleep_prepare(&sems[id]);
    80002ed4:	8526                	mv	a0,s1
    80002ed6:	a66ff0ef          	jal	8000213c <sleep_prepare>
    release(&sems[id].lk);
    80002eda:	8526                	mv	a0,s1
    80002edc:	dd5fd0ef          	jal	80000cb0 <release>
    sleep();
    80002ee0:	a98ff0ef          	jal	80002178 <sleep>
    acquire(&sems[id].lk);
    80002ee4:	8526                	mv	a0,s1
    80002ee6:	d43fd0ef          	jal	80000c28 <acquire>
  while (sems[id].value <= 0) {
    80002eea:	01892783          	lw	a5,24(s2)
    80002eee:	fef053e3          	blez	a5,80002ed4 <ksem_wait+0x32>
    80002ef2:	6942                	ld	s2,16(sp)
  }
  sems[id].value--;
    80002ef4:	0996                	slli	s3,s3,0x5
    80002ef6:	00016717          	auipc	a4,0x16
    80002efa:	7aa70713          	addi	a4,a4,1962 # 800196a0 <sems>
    80002efe:	974e                	add	a4,a4,s3
    80002f00:	37fd                	addiw	a5,a5,-1
    80002f02:	cf1c                	sw	a5,24(a4)
  release(&sems[id].lk);
    80002f04:	8526                	mv	a0,s1
    80002f06:	dabfd0ef          	jal	80000cb0 <release>
  return 0;
    80002f0a:	4501                	li	a0,0
}
    80002f0c:	70a2                	ld	ra,40(sp)
    80002f0e:	7402                	ld	s0,32(sp)
    80002f10:	64e2                	ld	s1,24(sp)
    80002f12:	69a2                	ld	s3,8(sp)
    80002f14:	6145                	addi	sp,sp,48
    80002f16:	8082                	ret
    return -1;
    80002f18:	557d                	li	a0,-1
}
    80002f1a:	8082                	ret

0000000080002f1c <ksem_signal>:

int
ksem_signal(int id)
{
  if (id < 0 || id >= MAX_SEM)
    80002f1c:	47bd                	li	a5,15
    80002f1e:	02a7ef63          	bltu	a5,a0,80002f5c <ksem_signal+0x40>
{
    80002f22:	1101                	addi	sp,sp,-32
    80002f24:	ec06                	sd	ra,24(sp)
    80002f26:	e822                	sd	s0,16(sp)
    80002f28:	e426                	sd	s1,8(sp)
    80002f2a:	1000                	addi	s0,sp,32
    return -1;
  acquire(&sems[id].lk);
    80002f2c:	0516                	slli	a0,a0,0x5
    80002f2e:	00016497          	auipc	s1,0x16
    80002f32:	77248493          	addi	s1,s1,1906 # 800196a0 <sems>
    80002f36:	94aa                	add	s1,s1,a0
    80002f38:	8526                	mv	a0,s1
    80002f3a:	ceffd0ef          	jal	80000c28 <acquire>
  sems[id].value++;
    80002f3e:	4c9c                	lw	a5,24(s1)
    80002f40:	2785                	addiw	a5,a5,1
    80002f42:	cc9c                	sw	a5,24(s1)
  wakeup(&sems[id]);
    80002f44:	8526                	mv	a0,s1
    80002f46:	a62ff0ef          	jal	800021a8 <wakeup>
  release(&sems[id].lk);
    80002f4a:	8526                	mv	a0,s1
    80002f4c:	d65fd0ef          	jal	80000cb0 <release>
  return 0;
    80002f50:	4501                	li	a0,0
}
    80002f52:	60e2                	ld	ra,24(sp)
    80002f54:	6442                	ld	s0,16(sp)
    80002f56:	64a2                	ld	s1,8(sp)
    80002f58:	6105                	addi	sp,sp,32
    80002f5a:	8082                	ret
    return -1;
    80002f5c:	557d                	li	a0,-1
}
    80002f5e:	8082                	ret

0000000080002f60 <sys_clone>:

uint64
sys_clone(void)
{
    80002f60:	7179                	addi	sp,sp,-48
    80002f62:	f406                	sd	ra,40(sp)
    80002f64:	f022                	sd	s0,32(sp)
    80002f66:	1800                	addi	s0,sp,48
  uint64 fcn, arg, stack;
  argaddr(0, &fcn);
    80002f68:	fe840593          	addi	a1,s0,-24
    80002f6c:	4501                	li	a0,0
    80002f6e:	c03ff0ef          	jal	80002b70 <argaddr>
  argaddr(1, &arg);
    80002f72:	fe040593          	addi	a1,s0,-32
    80002f76:	4505                	li	a0,1
    80002f78:	bf9ff0ef          	jal	80002b70 <argaddr>
  argaddr(2, &stack);
    80002f7c:	fd840593          	addi	a1,s0,-40
    80002f80:	4509                	li	a0,2
    80002f82:	befff0ef          	jal	80002b70 <argaddr>
  return kclone(fcn, arg, stack);
    80002f86:	fd843603          	ld	a2,-40(s0)
    80002f8a:	fe043583          	ld	a1,-32(s0)
    80002f8e:	fe843503          	ld	a0,-24(s0)
    80002f92:	e7bfe0ef          	jal	80001e0c <kclone>
}
    80002f96:	70a2                	ld	ra,40(sp)
    80002f98:	7402                	ld	s0,32(sp)
    80002f9a:	6145                	addi	sp,sp,48
    80002f9c:	8082                	ret

0000000080002f9e <sys_join>:

uint64
sys_join(void)
{
    80002f9e:	1141                	addi	sp,sp,-16
    80002fa0:	e406                	sd	ra,8(sp)
    80002fa2:	e022                	sd	s0,0(sp)
    80002fa4:	0800                	addi	s0,sp,16
  return kjoin();
    80002fa6:	d2cff0ef          	jal	800024d2 <kjoin>
}
    80002faa:	60a2                	ld	ra,8(sp)
    80002fac:	6402                	ld	s0,0(sp)
    80002fae:	0141                	addi	sp,sp,16
    80002fb0:	8082                	ret

0000000080002fb2 <sys_sem_init>:

uint64
sys_sem_init(void)
{
    80002fb2:	1101                	addi	sp,sp,-32
    80002fb4:	ec06                	sd	ra,24(sp)
    80002fb6:	e822                	sd	s0,16(sp)
    80002fb8:	1000                	addi	s0,sp,32
  int id, val;
  argint(0, &id);
    80002fba:	fec40593          	addi	a1,s0,-20
    80002fbe:	4501                	li	a0,0
    80002fc0:	b95ff0ef          	jal	80002b54 <argint>
  argint(1, &val);
    80002fc4:	fe840593          	addi	a1,s0,-24
    80002fc8:	4505                	li	a0,1
    80002fca:	b8bff0ef          	jal	80002b54 <argint>
  return ksem_init(id, val);
    80002fce:	fe842583          	lw	a1,-24(s0)
    80002fd2:	fec42503          	lw	a0,-20(s0)
    80002fd6:	e87ff0ef          	jal	80002e5c <ksem_init>
}
    80002fda:	60e2                	ld	ra,24(sp)
    80002fdc:	6442                	ld	s0,16(sp)
    80002fde:	6105                	addi	sp,sp,32
    80002fe0:	8082                	ret

0000000080002fe2 <sys_sem_wait>:

uint64
sys_sem_wait(void)
{
    80002fe2:	1101                	addi	sp,sp,-32
    80002fe4:	ec06                	sd	ra,24(sp)
    80002fe6:	e822                	sd	s0,16(sp)
    80002fe8:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    80002fea:	fec40593          	addi	a1,s0,-20
    80002fee:	4501                	li	a0,0
    80002ff0:	b65ff0ef          	jal	80002b54 <argint>
  return ksem_wait(id);
    80002ff4:	fec42503          	lw	a0,-20(s0)
    80002ff8:	eabff0ef          	jal	80002ea2 <ksem_wait>
}
    80002ffc:	60e2                	ld	ra,24(sp)
    80002ffe:	6442                	ld	s0,16(sp)
    80003000:	6105                	addi	sp,sp,32
    80003002:	8082                	ret

0000000080003004 <sys_sem_signal>:

uint64
sys_sem_signal(void)
{
    80003004:	1101                	addi	sp,sp,-32
    80003006:	ec06                	sd	ra,24(sp)
    80003008:	e822                	sd	s0,16(sp)
    8000300a:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    8000300c:	fec40593          	addi	a1,s0,-20
    80003010:	4501                	li	a0,0
    80003012:	b43ff0ef          	jal	80002b54 <argint>
  return ksem_signal(id);
    80003016:	fec42503          	lw	a0,-20(s0)
    8000301a:	f03ff0ef          	jal	80002f1c <ksem_signal>
}
    8000301e:	60e2                	ld	ra,24(sp)
    80003020:	6442                	ld	s0,16(sp)
    80003022:	6105                	addi	sp,sp,32
    80003024:	8082                	ret

0000000080003026 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003026:	7179                	addi	sp,sp,-48
    80003028:	f406                	sd	ra,40(sp)
    8000302a:	f022                	sd	s0,32(sp)
    8000302c:	ec26                	sd	s1,24(sp)
    8000302e:	e84a                	sd	s2,16(sp)
    80003030:	e44e                	sd	s3,8(sp)
    80003032:	e052                	sd	s4,0(sp)
    80003034:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003036:	00005597          	auipc	a1,0x5
    8000303a:	38258593          	addi	a1,a1,898 # 800083b8 <etext+0x3b8>
    8000303e:	00017517          	auipc	a0,0x17
    80003042:	86250513          	addi	a0,a0,-1950 # 800198a0 <bcache>
    80003046:	b63fd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000304a:	0001f797          	auipc	a5,0x1f
    8000304e:	85678793          	addi	a5,a5,-1962 # 800218a0 <bcache+0x8000>
    80003052:	0001f717          	auipc	a4,0x1f
    80003056:	ab670713          	addi	a4,a4,-1354 # 80021b08 <bcache+0x8268>
    8000305a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000305e:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80003062:	00017497          	auipc	s1,0x17
    80003066:	85648493          	addi	s1,s1,-1962 # 800198b8 <bcache+0x18>
    b->next = bcache.head.next;
    8000306a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000306c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000306e:	00005a17          	auipc	s4,0x5
    80003072:	352a0a13          	addi	s4,s4,850 # 800083c0 <etext+0x3c0>
    b->next = bcache.head.next;
    80003076:	2b893783          	ld	a5,696(s2)
    8000307a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000307c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003080:	85d2                	mv	a1,s4
    80003082:	01048513          	addi	a0,s1,16
    80003086:	41c010ef          	jal	800044a2 <initsleeplock>
    bcache.head.next->prev = b;
    8000308a:	2b893783          	ld	a5,696(s2)
    8000308e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003090:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80003094:	45848493          	addi	s1,s1,1112
    80003098:	fd349fe3          	bne	s1,s3,80003076 <binit+0x50>
  }
}
    8000309c:	70a2                	ld	ra,40(sp)
    8000309e:	7402                	ld	s0,32(sp)
    800030a0:	64e2                	ld	s1,24(sp)
    800030a2:	6942                	ld	s2,16(sp)
    800030a4:	69a2                	ld	s3,8(sp)
    800030a6:	6a02                	ld	s4,0(sp)
    800030a8:	6145                	addi	sp,sp,48
    800030aa:	8082                	ret

00000000800030ac <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    800030ac:	7179                	addi	sp,sp,-48
    800030ae:	f406                	sd	ra,40(sp)
    800030b0:	f022                	sd	s0,32(sp)
    800030b2:	ec26                	sd	s1,24(sp)
    800030b4:	e84a                	sd	s2,16(sp)
    800030b6:	e44e                	sd	s3,8(sp)
    800030b8:	1800                	addi	s0,sp,48
    800030ba:	892a                	mv	s2,a0
    800030bc:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800030be:	00016517          	auipc	a0,0x16
    800030c2:	7e250513          	addi	a0,a0,2018 # 800198a0 <bcache>
    800030c6:	b63fd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    800030ca:	0001f497          	auipc	s1,0x1f
    800030ce:	a8e4b483          	ld	s1,-1394(s1) # 80021b58 <bcache+0x82b8>
    800030d2:	0001f797          	auipc	a5,0x1f
    800030d6:	a3678793          	addi	a5,a5,-1482 # 80021b08 <bcache+0x8268>
    800030da:	02f48b63          	beq	s1,a5,80003110 <bread+0x64>
    800030de:	873e                	mv	a4,a5
    800030e0:	a021                	j	800030e8 <bread+0x3c>
    800030e2:	68a4                	ld	s1,80(s1)
    800030e4:	02e48663          	beq	s1,a4,80003110 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    800030e8:	449c                	lw	a5,8(s1)
    800030ea:	ff279ce3          	bne	a5,s2,800030e2 <bread+0x36>
    800030ee:	44dc                	lw	a5,12(s1)
    800030f0:	ff3799e3          	bne	a5,s3,800030e2 <bread+0x36>
      b->refcnt++;
    800030f4:	40bc                	lw	a5,64(s1)
    800030f6:	2785                	addiw	a5,a5,1
    800030f8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030fa:	00016517          	auipc	a0,0x16
    800030fe:	7a650513          	addi	a0,a0,1958 # 800198a0 <bcache>
    80003102:	baffd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80003106:	01048513          	addi	a0,s1,16
    8000310a:	3ce010ef          	jal	800044d8 <acquiresleep>
      return b;
    8000310e:	a889                	j	80003160 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80003110:	0001f497          	auipc	s1,0x1f
    80003114:	a404b483          	ld	s1,-1472(s1) # 80021b50 <bcache+0x82b0>
    80003118:	0001f797          	auipc	a5,0x1f
    8000311c:	9f078793          	addi	a5,a5,-1552 # 80021b08 <bcache+0x8268>
    80003120:	00f48863          	beq	s1,a5,80003130 <bread+0x84>
    80003124:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80003126:	40bc                	lw	a5,64(s1)
    80003128:	cb91                	beqz	a5,8000313c <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    8000312a:	64a4                	ld	s1,72(s1)
    8000312c:	fee49de3          	bne	s1,a4,80003126 <bread+0x7a>
  panic("bget: no buffers");
    80003130:	00005517          	auipc	a0,0x5
    80003134:	29850513          	addi	a0,a0,664 # 800083c8 <etext+0x3c8>
    80003138:	efcfd0ef          	jal	80000834 <panic>
      b->dev = dev;
    8000313c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003140:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003144:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003148:	4785                	li	a5,1
    8000314a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000314c:	00016517          	auipc	a0,0x16
    80003150:	75450513          	addi	a0,a0,1876 # 800198a0 <bcache>
    80003154:	b5dfd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80003158:	01048513          	addi	a0,s1,16
    8000315c:	37c010ef          	jal	800044d8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80003160:	409c                	lw	a5,0(s1)
    80003162:	cb89                	beqz	a5,80003174 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003164:	8526                	mv	a0,s1
    80003166:	70a2                	ld	ra,40(sp)
    80003168:	7402                	ld	s0,32(sp)
    8000316a:	64e2                	ld	s1,24(sp)
    8000316c:	6942                	ld	s2,16(sp)
    8000316e:	69a2                	ld	s3,8(sp)
    80003170:	6145                	addi	sp,sp,48
    80003172:	8082                	ret
    virtio_disk_rw(b, 0);
    80003174:	4581                	li	a1,0
    80003176:	8526                	mv	a0,s1
    80003178:	4bf020ef          	jal	80005e36 <virtio_disk_rw>
    b->valid = 1;
    8000317c:	4785                	li	a5,1
    8000317e:	c09c                	sw	a5,0(s1)
  return b;
    80003180:	b7d5                	j	80003164 <bread+0xb8>

0000000080003182 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80003182:	1101                	addi	sp,sp,-32
    80003184:	ec06                	sd	ra,24(sp)
    80003186:	e822                	sd	s0,16(sp)
    80003188:	e426                	sd	s1,8(sp)
    8000318a:	1000                	addi	s0,sp,32
    8000318c:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    8000318e:	0541                	addi	a0,a0,16
    80003190:	3d4010ef          	jal	80004564 <holdingsleep>
    80003194:	c911                	beqz	a0,800031a8 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003196:	4585                	li	a1,1
    80003198:	8526                	mv	a0,s1
    8000319a:	49d020ef          	jal	80005e36 <virtio_disk_rw>
}
    8000319e:	60e2                	ld	ra,24(sp)
    800031a0:	6442                	ld	s0,16(sp)
    800031a2:	64a2                	ld	s1,8(sp)
    800031a4:	6105                	addi	sp,sp,32
    800031a6:	8082                	ret
    panic("bwrite");
    800031a8:	00005517          	auipc	a0,0x5
    800031ac:	23850513          	addi	a0,a0,568 # 800083e0 <etext+0x3e0>
    800031b0:	e84fd0ef          	jal	80000834 <panic>

00000000800031b4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031b4:	1101                	addi	sp,sp,-32
    800031b6:	ec06                	sd	ra,24(sp)
    800031b8:	e822                	sd	s0,16(sp)
    800031ba:	e426                	sd	s1,8(sp)
    800031bc:	e04a                	sd	s2,0(sp)
    800031be:	1000                	addi	s0,sp,32
    800031c0:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    800031c2:	01050913          	addi	s2,a0,16
    800031c6:	854a                	mv	a0,s2
    800031c8:	39c010ef          	jal	80004564 <holdingsleep>
    800031cc:	c125                	beqz	a0,8000322c <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    800031ce:	854a                	mv	a0,s2
    800031d0:	35c010ef          	jal	8000452c <releasesleep>

  acquire(&bcache.lock);
    800031d4:	00016517          	auipc	a0,0x16
    800031d8:	6cc50513          	addi	a0,a0,1740 # 800198a0 <bcache>
    800031dc:	a4dfd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    800031e0:	40bc                	lw	a5,64(s1)
    800031e2:	37fd                	addiw	a5,a5,-1
    800031e4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031e6:	e79d                	bnez	a5,80003214 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031e8:	68b8                	ld	a4,80(s1)
    800031ea:	64bc                	ld	a5,72(s1)
    800031ec:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800031ee:	68b8                	ld	a4,80(s1)
    800031f0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031f2:	0001e797          	auipc	a5,0x1e
    800031f6:	6ae78793          	addi	a5,a5,1710 # 800218a0 <bcache+0x8000>
    800031fa:	2b87b703          	ld	a4,696(a5)
    800031fe:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003200:	0001f717          	auipc	a4,0x1f
    80003204:	90870713          	addi	a4,a4,-1784 # 80021b08 <bcache+0x8268>
    80003208:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000320a:	2b87b703          	ld	a4,696(a5)
    8000320e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003210:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80003214:	00016517          	auipc	a0,0x16
    80003218:	68c50513          	addi	a0,a0,1676 # 800198a0 <bcache>
    8000321c:	a95fd0ef          	jal	80000cb0 <release>
}
    80003220:	60e2                	ld	ra,24(sp)
    80003222:	6442                	ld	s0,16(sp)
    80003224:	64a2                	ld	s1,8(sp)
    80003226:	6902                	ld	s2,0(sp)
    80003228:	6105                	addi	sp,sp,32
    8000322a:	8082                	ret
    panic("brelse");
    8000322c:	00005517          	auipc	a0,0x5
    80003230:	1bc50513          	addi	a0,a0,444 # 800083e8 <etext+0x3e8>
    80003234:	e00fd0ef          	jal	80000834 <panic>

0000000080003238 <bpin>:

void
bpin(struct buf *b)
{
    80003238:	1101                	addi	sp,sp,-32
    8000323a:	ec06                	sd	ra,24(sp)
    8000323c:	e822                	sd	s0,16(sp)
    8000323e:	e426                	sd	s1,8(sp)
    80003240:	1000                	addi	s0,sp,32
    80003242:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003244:	00016517          	auipc	a0,0x16
    80003248:	65c50513          	addi	a0,a0,1628 # 800198a0 <bcache>
    8000324c:	9ddfd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80003250:	40bc                	lw	a5,64(s1)
    80003252:	2785                	addiw	a5,a5,1
    80003254:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003256:	00016517          	auipc	a0,0x16
    8000325a:	64a50513          	addi	a0,a0,1610 # 800198a0 <bcache>
    8000325e:	a53fd0ef          	jal	80000cb0 <release>
}
    80003262:	60e2                	ld	ra,24(sp)
    80003264:	6442                	ld	s0,16(sp)
    80003266:	64a2                	ld	s1,8(sp)
    80003268:	6105                	addi	sp,sp,32
    8000326a:	8082                	ret

000000008000326c <bunpin>:

void
bunpin(struct buf *b)
{
    8000326c:	1101                	addi	sp,sp,-32
    8000326e:	ec06                	sd	ra,24(sp)
    80003270:	e822                	sd	s0,16(sp)
    80003272:	e426                	sd	s1,8(sp)
    80003274:	1000                	addi	s0,sp,32
    80003276:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003278:	00016517          	auipc	a0,0x16
    8000327c:	62850513          	addi	a0,a0,1576 # 800198a0 <bcache>
    80003280:	9a9fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80003284:	40bc                	lw	a5,64(s1)
    80003286:	37fd                	addiw	a5,a5,-1
    80003288:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000328a:	00016517          	auipc	a0,0x16
    8000328e:	61650513          	addi	a0,a0,1558 # 800198a0 <bcache>
    80003292:	a1ffd0ef          	jal	80000cb0 <release>
}
    80003296:	60e2                	ld	ra,24(sp)
    80003298:	6442                	ld	s0,16(sp)
    8000329a:	64a2                	ld	s1,8(sp)
    8000329c:	6105                	addi	sp,sp,32
    8000329e:	8082                	ret

00000000800032a0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032a0:	1101                	addi	sp,sp,-32
    800032a2:	ec06                	sd	ra,24(sp)
    800032a4:	e822                	sd	s0,16(sp)
    800032a6:	e426                	sd	s1,8(sp)
    800032a8:	e04a                	sd	s2,0(sp)
    800032aa:	1000                	addi	s0,sp,32
    800032ac:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032ae:	00d5d79b          	srliw	a5,a1,0xd
    800032b2:	0001f597          	auipc	a1,0x1f
    800032b6:	cca5a583          	lw	a1,-822(a1) # 80021f7c <sb+0x1c>
    800032ba:	9dbd                	addw	a1,a1,a5
    800032bc:	df1ff0ef          	jal	800030ac <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032c0:	0074f713          	andi	a4,s1,7
    800032c4:	4785                	li	a5,1
    800032c6:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    800032ca:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    800032cc:	90d9                	srli	s1,s1,0x36
    800032ce:	00950733          	add	a4,a0,s1
    800032d2:	05874703          	lbu	a4,88(a4)
    800032d6:	00e7f6b3          	and	a3,a5,a4
    800032da:	c29d                	beqz	a3,80003300 <bfree+0x60>
    800032dc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    800032de:	94aa                	add	s1,s1,a0
    800032e0:	fff7c793          	not	a5,a5
    800032e4:	8f7d                	and	a4,a4,a5
    800032e6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800032ea:	080010ef          	jal	8000436a <log_write>
  brelse(bp);
    800032ee:	854a                	mv	a0,s2
    800032f0:	ec5ff0ef          	jal	800031b4 <brelse>
}
    800032f4:	60e2                	ld	ra,24(sp)
    800032f6:	6442                	ld	s0,16(sp)
    800032f8:	64a2                	ld	s1,8(sp)
    800032fa:	6902                	ld	s2,0(sp)
    800032fc:	6105                	addi	sp,sp,32
    800032fe:	8082                	ret
    panic("freeing free block");
    80003300:	00005517          	auipc	a0,0x5
    80003304:	0f050513          	addi	a0,a0,240 # 800083f0 <etext+0x3f0>
    80003308:	d2cfd0ef          	jal	80000834 <panic>

000000008000330c <balloc>:
{
    8000330c:	715d                	addi	sp,sp,-80
    8000330e:	e486                	sd	ra,72(sp)
    80003310:	e0a2                	sd	s0,64(sp)
    80003312:	fc26                	sd	s1,56(sp)
    80003314:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80003316:	0001f797          	auipc	a5,0x1f
    8000331a:	c4e7a783          	lw	a5,-946(a5) # 80021f64 <sb+0x4>
    8000331e:	0e078263          	beqz	a5,80003402 <balloc+0xf6>
    80003322:	f84a                	sd	s2,48(sp)
    80003324:	f44e                	sd	s3,40(sp)
    80003326:	f052                	sd	s4,32(sp)
    80003328:	ec56                	sd	s5,24(sp)
    8000332a:	e85a                	sd	s6,16(sp)
    8000332c:	e45e                	sd	s7,8(sp)
    8000332e:	e062                	sd	s8,0(sp)
    80003330:	8baa                	mv	s7,a0
    80003332:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003334:	0001fb17          	auipc	s6,0x1f
    80003338:	c2cb0b13          	addi	s6,s6,-980 # 80021f60 <sb>
      m = 1 << (bi % 8);
    8000333c:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    8000333e:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80003340:	6c09                	lui	s8,0x2
    80003342:	a09d                	j	800033a8 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80003344:	97ca                	add	a5,a5,s2
    80003346:	8e55                	or	a2,a2,a3
    80003348:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000334c:	854a                	mv	a0,s2
    8000334e:	01c010ef          	jal	8000436a <log_write>
        brelse(bp);
    80003352:	854a                	mv	a0,s2
    80003354:	e61ff0ef          	jal	800031b4 <brelse>
  bp = bread(dev, bno);
    80003358:	85a6                	mv	a1,s1
    8000335a:	855e                	mv	a0,s7
    8000335c:	d51ff0ef          	jal	800030ac <bread>
    80003360:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003362:	40000613          	li	a2,1024
    80003366:	4581                	li	a1,0
    80003368:	05850513          	addi	a0,a0,88
    8000336c:	97dfd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    80003370:	854a                	mv	a0,s2
    80003372:	7f9000ef          	jal	8000436a <log_write>
  brelse(bp);
    80003376:	854a                	mv	a0,s2
    80003378:	e3dff0ef          	jal	800031b4 <brelse>
}
    8000337c:	7942                	ld	s2,48(sp)
    8000337e:	79a2                	ld	s3,40(sp)
    80003380:	7a02                	ld	s4,32(sp)
    80003382:	6ae2                	ld	s5,24(sp)
    80003384:	6b42                	ld	s6,16(sp)
    80003386:	6ba2                	ld	s7,8(sp)
    80003388:	6c02                	ld	s8,0(sp)
}
    8000338a:	8526                	mv	a0,s1
    8000338c:	60a6                	ld	ra,72(sp)
    8000338e:	6406                	ld	s0,64(sp)
    80003390:	74e2                	ld	s1,56(sp)
    80003392:	6161                	addi	sp,sp,80
    80003394:	8082                	ret
    brelse(bp);
    80003396:	854a                	mv	a0,s2
    80003398:	e1dff0ef          	jal	800031b4 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    8000339c:	015c0abb          	addw	s5,s8,s5
    800033a0:	004b2783          	lw	a5,4(s6)
    800033a4:	04faf863          	bgeu	s5,a5,800033f4 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    800033a8:	40dad59b          	sraiw	a1,s5,0xd
    800033ac:	01cb2783          	lw	a5,28(s6)
    800033b0:	9dbd                	addw	a1,a1,a5
    800033b2:	855e                	mv	a0,s7
    800033b4:	cf9ff0ef          	jal	800030ac <bread>
    800033b8:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    800033ba:	004b2503          	lw	a0,4(s6)
    800033be:	84d6                	mv	s1,s5
    800033c0:	4701                	li	a4,0
    800033c2:	fca4fae3          	bgeu	s1,a0,80003396 <balloc+0x8a>
      m = 1 << (bi % 8);
    800033c6:	00777693          	andi	a3,a4,7
    800033ca:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    800033ce:	41f7579b          	sraiw	a5,a4,0x1f
    800033d2:	01d7d79b          	srliw	a5,a5,0x1d
    800033d6:	9fb9                	addw	a5,a5,a4
    800033d8:	4037d79b          	sraiw	a5,a5,0x3
    800033dc:	00f90633          	add	a2,s2,a5
    800033e0:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800033e4:	00c6f5b3          	and	a1,a3,a2
    800033e8:	ddb1                	beqz	a1,80003344 <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    800033ea:	2705                	addiw	a4,a4,1
    800033ec:	2485                	addiw	s1,s1,1
    800033ee:	fd471ae3          	bne	a4,s4,800033c2 <balloc+0xb6>
    800033f2:	b755                	j	80003396 <balloc+0x8a>
    800033f4:	7942                	ld	s2,48(sp)
    800033f6:	79a2                	ld	s3,40(sp)
    800033f8:	7a02                	ld	s4,32(sp)
    800033fa:	6ae2                	ld	s5,24(sp)
    800033fc:	6b42                	ld	s6,16(sp)
    800033fe:	6ba2                	ld	s7,8(sp)
    80003400:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    80003402:	00005517          	auipc	a0,0x5
    80003406:	00650513          	addi	a0,a0,6 # 80008408 <etext+0x408>
    8000340a:	900fd0ef          	jal	8000050a <printk>
  return 0;
    8000340e:	4481                	li	s1,0
    80003410:	bfad                	j	8000338a <balloc+0x7e>

0000000080003412 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003412:	7179                	addi	sp,sp,-48
    80003414:	f406                	sd	ra,40(sp)
    80003416:	f022                	sd	s0,32(sp)
    80003418:	ec26                	sd	s1,24(sp)
    8000341a:	e84a                	sd	s2,16(sp)
    8000341c:	e44e                	sd	s3,8(sp)
    8000341e:	1800                	addi	s0,sp,48
    80003420:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80003422:	47ad                	li	a5,11
    80003424:	02b7e363          	bltu	a5,a1,8000344a <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80003428:	02059793          	slli	a5,a1,0x20
    8000342c:	01e7d593          	srli	a1,a5,0x1e
    80003430:	00b509b3          	add	s3,a0,a1
    80003434:	0509a483          	lw	s1,80(s3)
    80003438:	e0b5                	bnez	s1,8000349c <bmap+0x8a>
      addr = balloc(ip->dev);
    8000343a:	4108                	lw	a0,0(a0)
    8000343c:	ed1ff0ef          	jal	8000330c <balloc>
    80003440:	84aa                	mv	s1,a0
      if (addr == 0)
    80003442:	cd29                	beqz	a0,8000349c <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80003444:	04a9a823          	sw	a0,80(s3)
    80003448:	a891                	j	8000349c <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000344a:	ff45879b          	addiw	a5,a1,-12
    8000344e:	873e                	mv	a4,a5
    80003450:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    80003452:	0ff00793          	li	a5,255
    80003456:	06e7e763          	bltu	a5,a4,800034c4 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    8000345a:	08052483          	lw	s1,128(a0)
    8000345e:	e891                	bnez	s1,80003472 <bmap+0x60>
      addr = balloc(ip->dev);
    80003460:	4108                	lw	a0,0(a0)
    80003462:	eabff0ef          	jal	8000330c <balloc>
    80003466:	84aa                	mv	s1,a0
      if (addr == 0)
    80003468:	c915                	beqz	a0,8000349c <bmap+0x8a>
    8000346a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000346c:	08a92023          	sw	a0,128(s2)
    80003470:	a011                	j	80003474 <bmap+0x62>
    80003472:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003474:	85a6                	mv	a1,s1
    80003476:	00092503          	lw	a0,0(s2)
    8000347a:	c33ff0ef          	jal	800030ac <bread>
    8000347e:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80003480:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80003484:	02099713          	slli	a4,s3,0x20
    80003488:	01e75593          	srli	a1,a4,0x1e
    8000348c:	97ae                	add	a5,a5,a1
    8000348e:	89be                	mv	s3,a5
    80003490:	4384                	lw	s1,0(a5)
    80003492:	cc89                	beqz	s1,800034ac <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003494:	8552                	mv	a0,s4
    80003496:	d1fff0ef          	jal	800031b4 <brelse>
    return addr;
    8000349a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000349c:	8526                	mv	a0,s1
    8000349e:	70a2                	ld	ra,40(sp)
    800034a0:	7402                	ld	s0,32(sp)
    800034a2:	64e2                	ld	s1,24(sp)
    800034a4:	6942                	ld	s2,16(sp)
    800034a6:	69a2                	ld	s3,8(sp)
    800034a8:	6145                	addi	sp,sp,48
    800034aa:	8082                	ret
      addr = balloc(ip->dev);
    800034ac:	00092503          	lw	a0,0(s2)
    800034b0:	e5dff0ef          	jal	8000330c <balloc>
    800034b4:	84aa                	mv	s1,a0
      if (addr) {
    800034b6:	dd79                	beqz	a0,80003494 <bmap+0x82>
        a[bn] = addr;
    800034b8:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800034bc:	8552                	mv	a0,s4
    800034be:	6ad000ef          	jal	8000436a <log_write>
    800034c2:	bfc9                	j	80003494 <bmap+0x82>
    800034c4:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800034c6:	00005517          	auipc	a0,0x5
    800034ca:	f5a50513          	addi	a0,a0,-166 # 80008420 <etext+0x420>
    800034ce:	b66fd0ef          	jal	80000834 <panic>

00000000800034d2 <iget>:
{
    800034d2:	7179                	addi	sp,sp,-48
    800034d4:	f406                	sd	ra,40(sp)
    800034d6:	f022                	sd	s0,32(sp)
    800034d8:	ec26                	sd	s1,24(sp)
    800034da:	e84a                	sd	s2,16(sp)
    800034dc:	e44e                	sd	s3,8(sp)
    800034de:	e052                	sd	s4,0(sp)
    800034e0:	1800                	addi	s0,sp,48
    800034e2:	892a                	mv	s2,a0
    800034e4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800034e6:	0001f517          	auipc	a0,0x1f
    800034ea:	a9a50513          	addi	a0,a0,-1382 # 80021f80 <itable>
    800034ee:	f3afd0ef          	jal	80000c28 <acquire>
  empty = 0;
    800034f2:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800034f4:	0001f497          	auipc	s1,0x1f
    800034f8:	aa448493          	addi	s1,s1,-1372 # 80021f98 <itable+0x18>
    800034fc:	00020697          	auipc	a3,0x20
    80003500:	52c68693          	addi	a3,a3,1324 # 80023a28 <log>
    80003504:	a809                	j	80003516 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003506:	e781                	bnez	a5,8000350e <iget+0x3c>
    80003508:	00099363          	bnez	s3,8000350e <iget+0x3c>
      empty = ip;
    8000350c:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000350e:	08848493          	addi	s1,s1,136
    80003512:	02d48563          	beq	s1,a3,8000353c <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80003516:	449c                	lw	a5,8(s1)
    80003518:	fef057e3          	blez	a5,80003506 <iget+0x34>
    8000351c:	4098                	lw	a4,0(s1)
    8000351e:	ff2718e3          	bne	a4,s2,8000350e <iget+0x3c>
    80003522:	40d8                	lw	a4,4(s1)
    80003524:	ff4715e3          	bne	a4,s4,8000350e <iget+0x3c>
      ip->ref++;
    80003528:	2785                	addiw	a5,a5,1
    8000352a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000352c:	0001f517          	auipc	a0,0x1f
    80003530:	a5450513          	addi	a0,a0,-1452 # 80021f80 <itable>
    80003534:	f7cfd0ef          	jal	80000cb0 <release>
      return ip;
    80003538:	89a6                	mv	s3,s1
    8000353a:	a015                	j	8000355e <iget+0x8c>
  if (empty == 0)
    8000353c:	02098a63          	beqz	s3,80003570 <iget+0x9e>
  ip->dev = dev;
    80003540:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003544:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003548:	4785                	li	a5,1
    8000354a:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    8000354e:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003552:	0001f517          	auipc	a0,0x1f
    80003556:	a2e50513          	addi	a0,a0,-1490 # 80021f80 <itable>
    8000355a:	f56fd0ef          	jal	80000cb0 <release>
}
    8000355e:	854e                	mv	a0,s3
    80003560:	70a2                	ld	ra,40(sp)
    80003562:	7402                	ld	s0,32(sp)
    80003564:	64e2                	ld	s1,24(sp)
    80003566:	6942                	ld	s2,16(sp)
    80003568:	69a2                	ld	s3,8(sp)
    8000356a:	6a02                	ld	s4,0(sp)
    8000356c:	6145                	addi	sp,sp,48
    8000356e:	8082                	ret
    panic("iget: no inodes");
    80003570:	00005517          	auipc	a0,0x5
    80003574:	ec850513          	addi	a0,a0,-312 # 80008438 <etext+0x438>
    80003578:	abcfd0ef          	jal	80000834 <panic>

000000008000357c <iinit>:
{
    8000357c:	7179                	addi	sp,sp,-48
    8000357e:	f406                	sd	ra,40(sp)
    80003580:	f022                	sd	s0,32(sp)
    80003582:	ec26                	sd	s1,24(sp)
    80003584:	e84a                	sd	s2,16(sp)
    80003586:	e44e                	sd	s3,8(sp)
    80003588:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000358a:	00005597          	auipc	a1,0x5
    8000358e:	ebe58593          	addi	a1,a1,-322 # 80008448 <etext+0x448>
    80003592:	0001f517          	auipc	a0,0x1f
    80003596:	9ee50513          	addi	a0,a0,-1554 # 80021f80 <itable>
    8000359a:	e0efd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    8000359e:	0001f497          	auipc	s1,0x1f
    800035a2:	a0a48493          	addi	s1,s1,-1526 # 80021fa8 <itable+0x28>
    800035a6:	00020997          	auipc	s3,0x20
    800035aa:	49298993          	addi	s3,s3,1170 # 80023a38 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800035ae:	00005917          	auipc	s2,0x5
    800035b2:	ea290913          	addi	s2,s2,-350 # 80008450 <etext+0x450>
    800035b6:	85ca                	mv	a1,s2
    800035b8:	8526                	mv	a0,s1
    800035ba:	6e9000ef          	jal	800044a2 <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    800035be:	08848493          	addi	s1,s1,136
    800035c2:	ff349ae3          	bne	s1,s3,800035b6 <iinit+0x3a>
}
    800035c6:	70a2                	ld	ra,40(sp)
    800035c8:	7402                	ld	s0,32(sp)
    800035ca:	64e2                	ld	s1,24(sp)
    800035cc:	6942                	ld	s2,16(sp)
    800035ce:	69a2                	ld	s3,8(sp)
    800035d0:	6145                	addi	sp,sp,48
    800035d2:	8082                	ret

00000000800035d4 <ialloc>:
{
    800035d4:	7139                	addi	sp,sp,-64
    800035d6:	fc06                	sd	ra,56(sp)
    800035d8:	f822                	sd	s0,48(sp)
    800035da:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    800035dc:	0001f717          	auipc	a4,0x1f
    800035e0:	99072703          	lw	a4,-1648(a4) # 80021f6c <sb+0xc>
    800035e4:	4785                	li	a5,1
    800035e6:	06e7f063          	bgeu	a5,a4,80003646 <ialloc+0x72>
    800035ea:	f426                	sd	s1,40(sp)
    800035ec:	f04a                	sd	s2,32(sp)
    800035ee:	ec4e                	sd	s3,24(sp)
    800035f0:	e852                	sd	s4,16(sp)
    800035f2:	e456                	sd	s5,8(sp)
    800035f4:	e05a                	sd	s6,0(sp)
    800035f6:	8aaa                	mv	s5,a0
    800035f8:	8b2e                	mv	s6,a1
    800035fa:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800035fc:	0001fa17          	auipc	s4,0x1f
    80003600:	964a0a13          	addi	s4,s4,-1692 # 80021f60 <sb>
    80003604:	00495593          	srli	a1,s2,0x4
    80003608:	018a2783          	lw	a5,24(s4)
    8000360c:	9dbd                	addw	a1,a1,a5
    8000360e:	8556                	mv	a0,s5
    80003610:	a9dff0ef          	jal	800030ac <bread>
    80003614:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003616:	05850993          	addi	s3,a0,88
    8000361a:	00f97793          	andi	a5,s2,15
    8000361e:	079a                	slli	a5,a5,0x6
    80003620:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    80003622:	00099783          	lh	a5,0(s3)
    80003626:	cb9d                	beqz	a5,8000365c <ialloc+0x88>
    brelse(bp);
    80003628:	b8dff0ef          	jal	800031b4 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000362c:	0905                	addi	s2,s2,1
    8000362e:	00ca2703          	lw	a4,12(s4)
    80003632:	0009079b          	sext.w	a5,s2
    80003636:	fce7e7e3          	bltu	a5,a4,80003604 <ialloc+0x30>
    8000363a:	74a2                	ld	s1,40(sp)
    8000363c:	7902                	ld	s2,32(sp)
    8000363e:	69e2                	ld	s3,24(sp)
    80003640:	6a42                	ld	s4,16(sp)
    80003642:	6aa2                	ld	s5,8(sp)
    80003644:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    80003646:	00005517          	auipc	a0,0x5
    8000364a:	e1250513          	addi	a0,a0,-494 # 80008458 <etext+0x458>
    8000364e:	ebdfc0ef          	jal	8000050a <printk>
  return 0;
    80003652:	4501                	li	a0,0
}
    80003654:	70e2                	ld	ra,56(sp)
    80003656:	7442                	ld	s0,48(sp)
    80003658:	6121                	addi	sp,sp,64
    8000365a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000365c:	04000613          	li	a2,64
    80003660:	4581                	li	a1,0
    80003662:	854e                	mv	a0,s3
    80003664:	e84fd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    80003668:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    8000366c:	8526                	mv	a0,s1
    8000366e:	4fd000ef          	jal	8000436a <log_write>
      brelse(bp);
    80003672:	8526                	mv	a0,s1
    80003674:	b41ff0ef          	jal	800031b4 <brelse>
      return iget(dev, inum);
    80003678:	0009059b          	sext.w	a1,s2
    8000367c:	8556                	mv	a0,s5
    8000367e:	e55ff0ef          	jal	800034d2 <iget>
    80003682:	74a2                	ld	s1,40(sp)
    80003684:	7902                	ld	s2,32(sp)
    80003686:	69e2                	ld	s3,24(sp)
    80003688:	6a42                	ld	s4,16(sp)
    8000368a:	6aa2                	ld	s5,8(sp)
    8000368c:	6b02                	ld	s6,0(sp)
    8000368e:	b7d9                	j	80003654 <ialloc+0x80>

0000000080003690 <iupdate>:
{
    80003690:	1101                	addi	sp,sp,-32
    80003692:	ec06                	sd	ra,24(sp)
    80003694:	e822                	sd	s0,16(sp)
    80003696:	e426                	sd	s1,8(sp)
    80003698:	e04a                	sd	s2,0(sp)
    8000369a:	1000                	addi	s0,sp,32
    8000369c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000369e:	415c                	lw	a5,4(a0)
    800036a0:	0047d79b          	srliw	a5,a5,0x4
    800036a4:	0001f597          	auipc	a1,0x1f
    800036a8:	8d45a583          	lw	a1,-1836(a1) # 80021f78 <sb+0x18>
    800036ac:	9dbd                	addw	a1,a1,a5
    800036ae:	4108                	lw	a0,0(a0)
    800036b0:	9fdff0ef          	jal	800030ac <bread>
    800036b4:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    800036b6:	05850793          	addi	a5,a0,88
    800036ba:	40d8                	lw	a4,4(s1)
    800036bc:	8b3d                	andi	a4,a4,15
    800036be:	071a                	slli	a4,a4,0x6
    800036c0:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800036c2:	04449703          	lh	a4,68(s1)
    800036c6:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800036ca:	04649703          	lh	a4,70(s1)
    800036ce:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800036d2:	04849703          	lh	a4,72(s1)
    800036d6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800036da:	04a49703          	lh	a4,74(s1)
    800036de:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800036e2:	44f8                	lw	a4,76(s1)
    800036e4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036e6:	03400613          	li	a2,52
    800036ea:	05048593          	addi	a1,s1,80
    800036ee:	00c78513          	addi	a0,a5,12
    800036f2:	e56fd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    800036f6:	854a                	mv	a0,s2
    800036f8:	473000ef          	jal	8000436a <log_write>
  brelse(bp);
    800036fc:	854a                	mv	a0,s2
    800036fe:	ab7ff0ef          	jal	800031b4 <brelse>
}
    80003702:	60e2                	ld	ra,24(sp)
    80003704:	6442                	ld	s0,16(sp)
    80003706:	64a2                	ld	s1,8(sp)
    80003708:	6902                	ld	s2,0(sp)
    8000370a:	6105                	addi	sp,sp,32
    8000370c:	8082                	ret

000000008000370e <idup>:
{
    8000370e:	1101                	addi	sp,sp,-32
    80003710:	ec06                	sd	ra,24(sp)
    80003712:	e822                	sd	s0,16(sp)
    80003714:	e426                	sd	s1,8(sp)
    80003716:	1000                	addi	s0,sp,32
    80003718:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000371a:	0001f517          	auipc	a0,0x1f
    8000371e:	86650513          	addi	a0,a0,-1946 # 80021f80 <itable>
    80003722:	d06fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003726:	449c                	lw	a5,8(s1)
    80003728:	2785                	addiw	a5,a5,1
    8000372a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000372c:	0001f517          	auipc	a0,0x1f
    80003730:	85450513          	addi	a0,a0,-1964 # 80021f80 <itable>
    80003734:	d7cfd0ef          	jal	80000cb0 <release>
}
    80003738:	8526                	mv	a0,s1
    8000373a:	60e2                	ld	ra,24(sp)
    8000373c:	6442                	ld	s0,16(sp)
    8000373e:	64a2                	ld	s1,8(sp)
    80003740:	6105                	addi	sp,sp,32
    80003742:	8082                	ret

0000000080003744 <ilock>:
{
    80003744:	1101                	addi	sp,sp,-32
    80003746:	ec06                	sd	ra,24(sp)
    80003748:	e822                	sd	s0,16(sp)
    8000374a:	e426                	sd	s1,8(sp)
    8000374c:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    8000374e:	cd19                	beqz	a0,8000376c <ilock+0x28>
    80003750:	84aa                	mv	s1,a0
    80003752:	451c                	lw	a5,8(a0)
    80003754:	00f05c63          	blez	a5,8000376c <ilock+0x28>
  acquiresleep(&ip->lock);
    80003758:	0541                	addi	a0,a0,16
    8000375a:	57f000ef          	jal	800044d8 <acquiresleep>
  if (ip->valid == 0) {
    8000375e:	40bc                	lw	a5,64(s1)
    80003760:	cf89                	beqz	a5,8000377a <ilock+0x36>
}
    80003762:	60e2                	ld	ra,24(sp)
    80003764:	6442                	ld	s0,16(sp)
    80003766:	64a2                	ld	s1,8(sp)
    80003768:	6105                	addi	sp,sp,32
    8000376a:	8082                	ret
    8000376c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000376e:	00005517          	auipc	a0,0x5
    80003772:	d0250513          	addi	a0,a0,-766 # 80008470 <etext+0x470>
    80003776:	8befd0ef          	jal	80000834 <panic>
    8000377a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000377c:	40dc                	lw	a5,4(s1)
    8000377e:	0047d79b          	srliw	a5,a5,0x4
    80003782:	0001e597          	auipc	a1,0x1e
    80003786:	7f65a583          	lw	a1,2038(a1) # 80021f78 <sb+0x18>
    8000378a:	9dbd                	addw	a1,a1,a5
    8000378c:	4088                	lw	a0,0(s1)
    8000378e:	91fff0ef          	jal	800030ac <bread>
    80003792:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003794:	05850593          	addi	a1,a0,88
    80003798:	40dc                	lw	a5,4(s1)
    8000379a:	8bbd                	andi	a5,a5,15
    8000379c:	079a                	slli	a5,a5,0x6
    8000379e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037a0:	00059783          	lh	a5,0(a1)
    800037a4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037a8:	00259783          	lh	a5,2(a1)
    800037ac:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037b0:	00459783          	lh	a5,4(a1)
    800037b4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800037b8:	00659783          	lh	a5,6(a1)
    800037bc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800037c0:	459c                	lw	a5,8(a1)
    800037c2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037c4:	03400613          	li	a2,52
    800037c8:	05b1                	addi	a1,a1,12
    800037ca:	05048513          	addi	a0,s1,80
    800037ce:	d7afd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    800037d2:	854a                	mv	a0,s2
    800037d4:	9e1ff0ef          	jal	800031b4 <brelse>
    ip->valid = 1;
    800037d8:	4785                	li	a5,1
    800037da:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    800037dc:	04449783          	lh	a5,68(s1)
    800037e0:	c399                	beqz	a5,800037e6 <ilock+0xa2>
    800037e2:	6902                	ld	s2,0(sp)
    800037e4:	bfbd                	j	80003762 <ilock+0x1e>
      panic("ilock: no type");
    800037e6:	00005517          	auipc	a0,0x5
    800037ea:	c9250513          	addi	a0,a0,-878 # 80008478 <etext+0x478>
    800037ee:	846fd0ef          	jal	80000834 <panic>

00000000800037f2 <iunlock>:
{
    800037f2:	1101                	addi	sp,sp,-32
    800037f4:	ec06                	sd	ra,24(sp)
    800037f6:	e822                	sd	s0,16(sp)
    800037f8:	e426                	sd	s1,8(sp)
    800037fa:	e04a                	sd	s2,0(sp)
    800037fc:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037fe:	c505                	beqz	a0,80003826 <iunlock+0x34>
    80003800:	84aa                	mv	s1,a0
    80003802:	01050913          	addi	s2,a0,16
    80003806:	854a                	mv	a0,s2
    80003808:	55d000ef          	jal	80004564 <holdingsleep>
    8000380c:	cd09                	beqz	a0,80003826 <iunlock+0x34>
    8000380e:	449c                	lw	a5,8(s1)
    80003810:	00f05b63          	blez	a5,80003826 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003814:	854a                	mv	a0,s2
    80003816:	517000ef          	jal	8000452c <releasesleep>
}
    8000381a:	60e2                	ld	ra,24(sp)
    8000381c:	6442                	ld	s0,16(sp)
    8000381e:	64a2                	ld	s1,8(sp)
    80003820:	6902                	ld	s2,0(sp)
    80003822:	6105                	addi	sp,sp,32
    80003824:	8082                	ret
    panic("iunlock");
    80003826:	00005517          	auipc	a0,0x5
    8000382a:	c6250513          	addi	a0,a0,-926 # 80008488 <etext+0x488>
    8000382e:	806fd0ef          	jal	80000834 <panic>

0000000080003832 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003832:	7179                	addi	sp,sp,-48
    80003834:	f406                	sd	ra,40(sp)
    80003836:	f022                	sd	s0,32(sp)
    80003838:	ec26                	sd	s1,24(sp)
    8000383a:	e84a                	sd	s2,16(sp)
    8000383c:	e44e                	sd	s3,8(sp)
    8000383e:	1800                	addi	s0,sp,48
    80003840:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    80003842:	05050493          	addi	s1,a0,80
    80003846:	08050913          	addi	s2,a0,128
    8000384a:	a021                	j	80003852 <itrunc+0x20>
    8000384c:	0491                	addi	s1,s1,4
    8000384e:	01248b63          	beq	s1,s2,80003864 <itrunc+0x32>
    if (ip->addrs[i]) {
    80003852:	408c                	lw	a1,0(s1)
    80003854:	dde5                	beqz	a1,8000384c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003856:	0009a503          	lw	a0,0(s3)
    8000385a:	a47ff0ef          	jal	800032a0 <bfree>
      ip->addrs[i] = 0;
    8000385e:	0004a023          	sw	zero,0(s1)
    80003862:	b7ed                	j	8000384c <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    80003864:	0809a583          	lw	a1,128(s3)
    80003868:	ed89                	bnez	a1,80003882 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000386a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000386e:	854e                	mv	a0,s3
    80003870:	e21ff0ef          	jal	80003690 <iupdate>
}
    80003874:	70a2                	ld	ra,40(sp)
    80003876:	7402                	ld	s0,32(sp)
    80003878:	64e2                	ld	s1,24(sp)
    8000387a:	6942                	ld	s2,16(sp)
    8000387c:	69a2                	ld	s3,8(sp)
    8000387e:	6145                	addi	sp,sp,48
    80003880:	8082                	ret
    80003882:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003884:	0009a503          	lw	a0,0(s3)
    80003888:	825ff0ef          	jal	800030ac <bread>
    8000388c:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    8000388e:	05850493          	addi	s1,a0,88
    80003892:	45850913          	addi	s2,a0,1112
    80003896:	a021                	j	8000389e <itrunc+0x6c>
    80003898:	0491                	addi	s1,s1,4
    8000389a:	01248963          	beq	s1,s2,800038ac <itrunc+0x7a>
      if (a[j])
    8000389e:	408c                	lw	a1,0(s1)
    800038a0:	dde5                	beqz	a1,80003898 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800038a2:	0009a503          	lw	a0,0(s3)
    800038a6:	9fbff0ef          	jal	800032a0 <bfree>
    800038aa:	b7fd                	j	80003898 <itrunc+0x66>
    brelse(bp);
    800038ac:	8552                	mv	a0,s4
    800038ae:	907ff0ef          	jal	800031b4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800038b2:	0809a583          	lw	a1,128(s3)
    800038b6:	0009a503          	lw	a0,0(s3)
    800038ba:	9e7ff0ef          	jal	800032a0 <bfree>
    ip->addrs[NDIRECT] = 0;
    800038be:	0809a023          	sw	zero,128(s3)
    800038c2:	6a02                	ld	s4,0(sp)
    800038c4:	b75d                	j	8000386a <itrunc+0x38>

00000000800038c6 <iput>:
{
    800038c6:	7179                	addi	sp,sp,-48
    800038c8:	f406                	sd	ra,40(sp)
    800038ca:	f022                	sd	s0,32(sp)
    800038cc:	ec26                	sd	s1,24(sp)
    800038ce:	1800                	addi	s0,sp,48
    800038d0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038d2:	0001e517          	auipc	a0,0x1e
    800038d6:	6ae50513          	addi	a0,a0,1710 # 80021f80 <itable>
    800038da:	b4efd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800038de:	449c                	lw	a5,8(s1)
    800038e0:	4705                	li	a4,1
    800038e2:	00e78f63          	beq	a5,a4,80003900 <iput+0x3a>
  ip->ref--;
    800038e6:	37fd                	addiw	a5,a5,-1
    800038e8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038ea:	0001e517          	auipc	a0,0x1e
    800038ee:	69650513          	addi	a0,a0,1686 # 80021f80 <itable>
    800038f2:	bbefd0ef          	jal	80000cb0 <release>
}
    800038f6:	70a2                	ld	ra,40(sp)
    800038f8:	7402                	ld	s0,32(sp)
    800038fa:	64e2                	ld	s1,24(sp)
    800038fc:	6145                	addi	sp,sp,48
    800038fe:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003900:	40b8                	lw	a4,64(s1)
    80003902:	d375                	beqz	a4,800038e6 <iput+0x20>
    80003904:	e84a                	sd	s2,16(sp)
    80003906:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    80003908:	0004aa03          	lw	s4,0(s1)
    8000390c:	0044a903          	lw	s2,4(s1)
  if (last) {
    80003910:	04a49703          	lh	a4,74(s1)
    80003914:	ef3d                	bnez	a4,80003992 <iput+0xcc>
    80003916:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    80003918:	01048793          	addi	a5,s1,16
    8000391c:	89be                	mv	s3,a5
    8000391e:	853e                	mv	a0,a5
    80003920:	3b9000ef          	jal	800044d8 <acquiresleep>
    release(&itable.lock);
    80003924:	0001e517          	auipc	a0,0x1e
    80003928:	65c50513          	addi	a0,a0,1628 # 80021f80 <itable>
    8000392c:	b84fd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    80003930:	8526                	mv	a0,s1
    80003932:	f01ff0ef          	jal	80003832 <itrunc>
    ip->valid = 0;
    80003936:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000393a:	854e                	mv	a0,s3
    8000393c:	3f1000ef          	jal	8000452c <releasesleep>
    acquire(&itable.lock);
    80003940:	0001e517          	auipc	a0,0x1e
    80003944:	64050513          	addi	a0,a0,1600 # 80021f80 <itable>
    80003948:	ae0fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    8000394c:	449c                	lw	a5,8(s1)
    8000394e:	37fd                	addiw	a5,a5,-1
    80003950:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003952:	0001e517          	auipc	a0,0x1e
    80003956:	62e50513          	addi	a0,a0,1582 # 80021f80 <itable>
    8000395a:	b56fd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000395e:	0049579b          	srliw	a5,s2,0x4
    80003962:	0001e597          	auipc	a1,0x1e
    80003966:	6165a583          	lw	a1,1558(a1) # 80021f78 <sb+0x18>
    8000396a:	9dbd                	addw	a1,a1,a5
    8000396c:	8552                	mv	a0,s4
    8000396e:	f3eff0ef          	jal	800030ac <bread>
    80003972:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003974:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    80003978:	079a                	slli	a5,a5,0x6
    8000397a:	97aa                	add	a5,a5,a0
    8000397c:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    80003980:	1eb000ef          	jal	8000436a <log_write>
  brelse(bp);
    80003984:	8526                	mv	a0,s1
    80003986:	82fff0ef          	jal	800031b4 <brelse>
}
    8000398a:	6942                	ld	s2,16(sp)
    8000398c:	69a2                	ld	s3,8(sp)
    8000398e:	6a02                	ld	s4,0(sp)
    80003990:	b79d                	j	800038f6 <iput+0x30>
    80003992:	6942                	ld	s2,16(sp)
    80003994:	6a02                	ld	s4,0(sp)
    80003996:	bf81                	j	800038e6 <iput+0x20>

0000000080003998 <iunlockput>:
{
    80003998:	1101                	addi	sp,sp,-32
    8000399a:	ec06                	sd	ra,24(sp)
    8000399c:	e822                	sd	s0,16(sp)
    8000399e:	e426                	sd	s1,8(sp)
    800039a0:	1000                	addi	s0,sp,32
    800039a2:	84aa                	mv	s1,a0
  iunlock(ip);
    800039a4:	e4fff0ef          	jal	800037f2 <iunlock>
  iput(ip);
    800039a8:	8526                	mv	a0,s1
    800039aa:	f1dff0ef          	jal	800038c6 <iput>
}
    800039ae:	60e2                	ld	ra,24(sp)
    800039b0:	6442                	ld	s0,16(sp)
    800039b2:	64a2                	ld	s1,8(sp)
    800039b4:	6105                	addi	sp,sp,32
    800039b6:	8082                	ret

00000000800039b8 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800039b8:	0001e717          	auipc	a4,0x1e
    800039bc:	5b472703          	lw	a4,1460(a4) # 80021f6c <sb+0xc>
    800039c0:	4785                	li	a5,1
    800039c2:	0ae7fe63          	bgeu	a5,a4,80003a7e <ireclaim+0xc6>
{
    800039c6:	7139                	addi	sp,sp,-64
    800039c8:	fc06                	sd	ra,56(sp)
    800039ca:	f822                	sd	s0,48(sp)
    800039cc:	f426                	sd	s1,40(sp)
    800039ce:	f04a                	sd	s2,32(sp)
    800039d0:	ec4e                	sd	s3,24(sp)
    800039d2:	e852                	sd	s4,16(sp)
    800039d4:	e456                	sd	s5,8(sp)
    800039d6:	e05a                	sd	s6,0(sp)
    800039d8:	0080                	addi	s0,sp,64
    800039da:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800039dc:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800039de:	0001ea17          	auipc	s4,0x1e
    800039e2:	582a0a13          	addi	s4,s4,1410 # 80021f60 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    800039e6:	00005b17          	auipc	s6,0x5
    800039ea:	aaab0b13          	addi	s6,s6,-1366 # 80008490 <etext+0x490>
    800039ee:	a099                	j	80003a34 <ireclaim+0x7c>
    800039f0:	85ce                	mv	a1,s3
    800039f2:	855a                	mv	a0,s6
    800039f4:	b17fc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    800039f8:	85ce                	mv	a1,s3
    800039fa:	8556                	mv	a0,s5
    800039fc:	ad7ff0ef          	jal	800034d2 <iget>
    80003a00:	89aa                	mv	s3,a0
    brelse(bp);
    80003a02:	854a                	mv	a0,s2
    80003a04:	fb0ff0ef          	jal	800031b4 <brelse>
    if (ip) {
    80003a08:	00098f63          	beqz	s3,80003a26 <ireclaim+0x6e>
      begin_op();
    80003a0c:	7b0000ef          	jal	800041bc <begin_op>
      ilock(ip);
    80003a10:	854e                	mv	a0,s3
    80003a12:	d33ff0ef          	jal	80003744 <ilock>
      iunlock(ip);
    80003a16:	854e                	mv	a0,s3
    80003a18:	ddbff0ef          	jal	800037f2 <iunlock>
      iput(ip);
    80003a1c:	854e                	mv	a0,s3
    80003a1e:	ea9ff0ef          	jal	800038c6 <iput>
      end_op();
    80003a22:	027000ef          	jal	80004248 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a26:	0485                	addi	s1,s1,1
    80003a28:	00ca2703          	lw	a4,12(s4)
    80003a2c:	0004879b          	sext.w	a5,s1
    80003a30:	02e7fd63          	bgeu	a5,a4,80003a6a <ireclaim+0xb2>
    80003a34:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003a38:	0044d593          	srli	a1,s1,0x4
    80003a3c:	018a2783          	lw	a5,24(s4)
    80003a40:	9dbd                	addw	a1,a1,a5
    80003a42:	8556                	mv	a0,s5
    80003a44:	e68ff0ef          	jal	800030ac <bread>
    80003a48:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003a4a:	05850793          	addi	a5,a0,88
    80003a4e:	00f9f713          	andi	a4,s3,15
    80003a52:	071a                	slli	a4,a4,0x6
    80003a54:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    80003a56:	00079703          	lh	a4,0(a5)
    80003a5a:	c701                	beqz	a4,80003a62 <ireclaim+0xaa>
    80003a5c:	00679783          	lh	a5,6(a5)
    80003a60:	dbc1                	beqz	a5,800039f0 <ireclaim+0x38>
    brelse(bp);
    80003a62:	854a                	mv	a0,s2
    80003a64:	f50ff0ef          	jal	800031b4 <brelse>
    if (ip) {
    80003a68:	bf7d                	j	80003a26 <ireclaim+0x6e>
}
    80003a6a:	70e2                	ld	ra,56(sp)
    80003a6c:	7442                	ld	s0,48(sp)
    80003a6e:	74a2                	ld	s1,40(sp)
    80003a70:	7902                	ld	s2,32(sp)
    80003a72:	69e2                	ld	s3,24(sp)
    80003a74:	6a42                	ld	s4,16(sp)
    80003a76:	6aa2                	ld	s5,8(sp)
    80003a78:	6b02                	ld	s6,0(sp)
    80003a7a:	6121                	addi	sp,sp,64
    80003a7c:	8082                	ret
    80003a7e:	8082                	ret

0000000080003a80 <fsinit>:
{
    80003a80:	1101                	addi	sp,sp,-32
    80003a82:	ec06                	sd	ra,24(sp)
    80003a84:	e822                	sd	s0,16(sp)
    80003a86:	e426                	sd	s1,8(sp)
    80003a88:	e04a                	sd	s2,0(sp)
    80003a8a:	1000                	addi	s0,sp,32
    80003a8c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a8e:	4585                	li	a1,1
    80003a90:	e1cff0ef          	jal	800030ac <bread>
    80003a94:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a96:	02000613          	li	a2,32
    80003a9a:	05850593          	addi	a1,a0,88
    80003a9e:	0001e517          	auipc	a0,0x1e
    80003aa2:	4c250513          	addi	a0,a0,1218 # 80021f60 <sb>
    80003aa6:	aa2fd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    80003aaa:	8526                	mv	a0,s1
    80003aac:	f08ff0ef          	jal	800031b4 <brelse>
  if (sb.magic != FSMAGIC)
    80003ab0:	0001e717          	auipc	a4,0x1e
    80003ab4:	4b072703          	lw	a4,1200(a4) # 80021f60 <sb>
    80003ab8:	102037b7          	lui	a5,0x10203
    80003abc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ac0:	02f71263          	bne	a4,a5,80003ae4 <fsinit+0x64>
  initlog(dev, &sb);
    80003ac4:	0001e597          	auipc	a1,0x1e
    80003ac8:	49c58593          	addi	a1,a1,1180 # 80021f60 <sb>
    80003acc:	854a                	mv	a0,s2
    80003ace:	66c000ef          	jal	8000413a <initlog>
  ireclaim(dev);
    80003ad2:	854a                	mv	a0,s2
    80003ad4:	ee5ff0ef          	jal	800039b8 <ireclaim>
}
    80003ad8:	60e2                	ld	ra,24(sp)
    80003ada:	6442                	ld	s0,16(sp)
    80003adc:	64a2                	ld	s1,8(sp)
    80003ade:	6902                	ld	s2,0(sp)
    80003ae0:	6105                	addi	sp,sp,32
    80003ae2:	8082                	ret
    panic("invalid file system");
    80003ae4:	00005517          	auipc	a0,0x5
    80003ae8:	9cc50513          	addi	a0,a0,-1588 # 800084b0 <etext+0x4b0>
    80003aec:	d49fc0ef          	jal	80000834 <panic>

0000000080003af0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003af0:	1141                	addi	sp,sp,-16
    80003af2:	e406                	sd	ra,8(sp)
    80003af4:	e022                	sd	s0,0(sp)
    80003af6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003af8:	411c                	lw	a5,0(a0)
    80003afa:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003afc:	415c                	lw	a5,4(a0)
    80003afe:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b00:	04451783          	lh	a5,68(a0)
    80003b04:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b08:	04a51783          	lh	a5,74(a0)
    80003b0c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b10:	04c56783          	lwu	a5,76(a0)
    80003b14:	e99c                	sd	a5,16(a1)
}
    80003b16:	60a2                	ld	ra,8(sp)
    80003b18:	6402                	ld	s0,0(sp)
    80003b1a:	0141                	addi	sp,sp,16
    80003b1c:	8082                	ret

0000000080003b1e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003b1e:	457c                	lw	a5,76(a0)
    80003b20:	0ed7e663          	bltu	a5,a3,80003c0c <readi+0xee>
{
    80003b24:	7159                	addi	sp,sp,-112
    80003b26:	f486                	sd	ra,104(sp)
    80003b28:	f0a2                	sd	s0,96(sp)
    80003b2a:	eca6                	sd	s1,88(sp)
    80003b2c:	e0d2                	sd	s4,64(sp)
    80003b2e:	fc56                	sd	s5,56(sp)
    80003b30:	f85a                	sd	s6,48(sp)
    80003b32:	f45e                	sd	s7,40(sp)
    80003b34:	1880                	addi	s0,sp,112
    80003b36:	8b2a                	mv	s6,a0
    80003b38:	8bae                	mv	s7,a1
    80003b3a:	8a32                	mv	s4,a2
    80003b3c:	84b6                	mv	s1,a3
    80003b3e:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003b40:	9f35                	addw	a4,a4,a3
    return 0;
    80003b42:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003b44:	0ad76b63          	bltu	a4,a3,80003bfa <readi+0xdc>
    80003b48:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003b4a:	00e7f463          	bgeu	a5,a4,80003b52 <readi+0x34>
    n = ip->size - off;
    80003b4e:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003b52:	080a8b63          	beqz	s5,80003be8 <readi+0xca>
    80003b56:	e8ca                	sd	s2,80(sp)
    80003b58:	f062                	sd	s8,32(sp)
    80003b5a:	ec66                	sd	s9,24(sp)
    80003b5c:	e86a                	sd	s10,16(sp)
    80003b5e:	e46e                	sd	s11,8(sp)
    80003b60:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003b62:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b66:	5c7d                	li	s8,-1
    80003b68:	a80d                	j	80003b9a <readi+0x7c>
    80003b6a:	020d1d93          	slli	s11,s10,0x20
    80003b6e:	020ddd93          	srli	s11,s11,0x20
    80003b72:	05890613          	addi	a2,s2,88
    80003b76:	86ee                	mv	a3,s11
    80003b78:	963e                	add	a2,a2,a5
    80003b7a:	85d2                	mv	a1,s4
    80003b7c:	855e                	mv	a0,s7
    80003b7e:	a2bfe0ef          	jal	800025a8 <either_copyout>
    80003b82:	05850363          	beq	a0,s8,80003bc8 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b86:	854a                	mv	a0,s2
    80003b88:	e2cff0ef          	jal	800031b4 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003b8c:	013d09bb          	addw	s3,s10,s3
    80003b90:	009d04bb          	addw	s1,s10,s1
    80003b94:	9a6e                	add	s4,s4,s11
    80003b96:	0559f363          	bgeu	s3,s5,80003bdc <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    80003b9a:	00a4d59b          	srliw	a1,s1,0xa
    80003b9e:	855a                	mv	a0,s6
    80003ba0:	873ff0ef          	jal	80003412 <bmap>
    80003ba4:	85aa                	mv	a1,a0
    if (addr == 0)
    80003ba6:	c139                	beqz	a0,80003bec <readi+0xce>
    bp = bread(ip->dev, addr);
    80003ba8:	000b2503          	lw	a0,0(s6)
    80003bac:	d00ff0ef          	jal	800030ac <bread>
    80003bb0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003bb2:	3ff4f793          	andi	a5,s1,1023
    80003bb6:	40fc873b          	subw	a4,s9,a5
    80003bba:	413a86bb          	subw	a3,s5,s3
    80003bbe:	8d3a                	mv	s10,a4
    80003bc0:	fae6f5e3          	bgeu	a3,a4,80003b6a <readi+0x4c>
    80003bc4:	8d36                	mv	s10,a3
    80003bc6:	b755                	j	80003b6a <readi+0x4c>
      brelse(bp);
    80003bc8:	854a                	mv	a0,s2
    80003bca:	deaff0ef          	jal	800031b4 <brelse>
      tot = -1;
    80003bce:	59fd                	li	s3,-1
      break;
    80003bd0:	6946                	ld	s2,80(sp)
    80003bd2:	7c02                	ld	s8,32(sp)
    80003bd4:	6ce2                	ld	s9,24(sp)
    80003bd6:	6d42                	ld	s10,16(sp)
    80003bd8:	6da2                	ld	s11,8(sp)
    80003bda:	a831                	j	80003bf6 <readi+0xd8>
    80003bdc:	6946                	ld	s2,80(sp)
    80003bde:	7c02                	ld	s8,32(sp)
    80003be0:	6ce2                	ld	s9,24(sp)
    80003be2:	6d42                	ld	s10,16(sp)
    80003be4:	6da2                	ld	s11,8(sp)
    80003be6:	a801                	j	80003bf6 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003be8:	89d6                	mv	s3,s5
    80003bea:	a031                	j	80003bf6 <readi+0xd8>
    80003bec:	6946                	ld	s2,80(sp)
    80003bee:	7c02                	ld	s8,32(sp)
    80003bf0:	6ce2                	ld	s9,24(sp)
    80003bf2:	6d42                	ld	s10,16(sp)
    80003bf4:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003bf6:	854e                	mv	a0,s3
    80003bf8:	69a6                	ld	s3,72(sp)
}
    80003bfa:	70a6                	ld	ra,104(sp)
    80003bfc:	7406                	ld	s0,96(sp)
    80003bfe:	64e6                	ld	s1,88(sp)
    80003c00:	6a06                	ld	s4,64(sp)
    80003c02:	7ae2                	ld	s5,56(sp)
    80003c04:	7b42                	ld	s6,48(sp)
    80003c06:	7ba2                	ld	s7,40(sp)
    80003c08:	6165                	addi	sp,sp,112
    80003c0a:	8082                	ret
    return 0;
    80003c0c:	4501                	li	a0,0
}
    80003c0e:	8082                	ret

0000000080003c10 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003c10:	457c                	lw	a5,76(a0)
    80003c12:	0ed7ee63          	bltu	a5,a3,80003d0e <writei+0xfe>
{
    80003c16:	7159                	addi	sp,sp,-112
    80003c18:	f486                	sd	ra,104(sp)
    80003c1a:	f0a2                	sd	s0,96(sp)
    80003c1c:	e8ca                	sd	s2,80(sp)
    80003c1e:	e0d2                	sd	s4,64(sp)
    80003c20:	fc56                	sd	s5,56(sp)
    80003c22:	f85a                	sd	s6,48(sp)
    80003c24:	f45e                	sd	s7,40(sp)
    80003c26:	1880                	addi	s0,sp,112
    80003c28:	8aaa                	mv	s5,a0
    80003c2a:	8bae                	mv	s7,a1
    80003c2c:	8a32                	mv	s4,a2
    80003c2e:	8936                	mv	s2,a3
    80003c30:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003c32:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003c36:	00043737          	lui	a4,0x43
    80003c3a:	0cf76c63          	bltu	a4,a5,80003d12 <writei+0x102>
    80003c3e:	0cd7ea63          	bltu	a5,a3,80003d12 <writei+0x102>
    80003c42:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003c44:	0a0b0d63          	beqz	s6,80003cfe <writei+0xee>
    80003c48:	eca6                	sd	s1,88(sp)
    80003c4a:	f062                	sd	s8,32(sp)
    80003c4c:	ec66                	sd	s9,24(sp)
    80003c4e:	e86a                	sd	s10,16(sp)
    80003c50:	e46e                	sd	s11,8(sp)
    80003c52:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003c54:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c58:	5c7d                	li	s8,-1
    80003c5a:	a825                	j	80003c92 <writei+0x82>
    80003c5c:	020d1d93          	slli	s11,s10,0x20
    80003c60:	020ddd93          	srli	s11,s11,0x20
    80003c64:	05848513          	addi	a0,s1,88
    80003c68:	86ee                	mv	a3,s11
    80003c6a:	8652                	mv	a2,s4
    80003c6c:	85de                	mv	a1,s7
    80003c6e:	953e                	add	a0,a0,a5
    80003c70:	985fe0ef          	jal	800025f4 <either_copyin>
    80003c74:	05850663          	beq	a0,s8,80003cc0 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c78:	8526                	mv	a0,s1
    80003c7a:	6f0000ef          	jal	8000436a <log_write>
    brelse(bp);
    80003c7e:	8526                	mv	a0,s1
    80003c80:	d34ff0ef          	jal	800031b4 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003c84:	013d09bb          	addw	s3,s10,s3
    80003c88:	012d093b          	addw	s2,s10,s2
    80003c8c:	9a6e                	add	s4,s4,s11
    80003c8e:	0369ff63          	bgeu	s3,s6,80003ccc <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    80003c92:	00a9559b          	srliw	a1,s2,0xa
    80003c96:	8556                	mv	a0,s5
    80003c98:	f7aff0ef          	jal	80003412 <bmap>
    80003c9c:	85aa                	mv	a1,a0
    if (addr == 0)
    80003c9e:	c51d                	beqz	a0,80003ccc <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003ca0:	000aa503          	lw	a0,0(s5)
    80003ca4:	c08ff0ef          	jal	800030ac <bread>
    80003ca8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003caa:	3ff97793          	andi	a5,s2,1023
    80003cae:	40fc873b          	subw	a4,s9,a5
    80003cb2:	413b06bb          	subw	a3,s6,s3
    80003cb6:	8d3a                	mv	s10,a4
    80003cb8:	fae6f2e3          	bgeu	a3,a4,80003c5c <writei+0x4c>
    80003cbc:	8d36                	mv	s10,a3
    80003cbe:	bf79                	j	80003c5c <writei+0x4c>
      log_write(bp);
    80003cc0:	8526                	mv	a0,s1
    80003cc2:	6a8000ef          	jal	8000436a <log_write>
      brelse(bp);
    80003cc6:	8526                	mv	a0,s1
    80003cc8:	cecff0ef          	jal	800031b4 <brelse>
  }

  if (off > ip->size)
    80003ccc:	04caa783          	lw	a5,76(s5)
    80003cd0:	0327f963          	bgeu	a5,s2,80003d02 <writei+0xf2>
    ip->size = off;
    80003cd4:	052aa623          	sw	s2,76(s5)
    80003cd8:	64e6                	ld	s1,88(sp)
    80003cda:	7c02                	ld	s8,32(sp)
    80003cdc:	6ce2                	ld	s9,24(sp)
    80003cde:	6d42                	ld	s10,16(sp)
    80003ce0:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ce2:	8556                	mv	a0,s5
    80003ce4:	9adff0ef          	jal	80003690 <iupdate>

  return tot;
    80003ce8:	854e                	mv	a0,s3
    80003cea:	69a6                	ld	s3,72(sp)
}
    80003cec:	70a6                	ld	ra,104(sp)
    80003cee:	7406                	ld	s0,96(sp)
    80003cf0:	6946                	ld	s2,80(sp)
    80003cf2:	6a06                	ld	s4,64(sp)
    80003cf4:	7ae2                	ld	s5,56(sp)
    80003cf6:	7b42                	ld	s6,48(sp)
    80003cf8:	7ba2                	ld	s7,40(sp)
    80003cfa:	6165                	addi	sp,sp,112
    80003cfc:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003cfe:	89da                	mv	s3,s6
    80003d00:	b7cd                	j	80003ce2 <writei+0xd2>
    80003d02:	64e6                	ld	s1,88(sp)
    80003d04:	7c02                	ld	s8,32(sp)
    80003d06:	6ce2                	ld	s9,24(sp)
    80003d08:	6d42                	ld	s10,16(sp)
    80003d0a:	6da2                	ld	s11,8(sp)
    80003d0c:	bfd9                	j	80003ce2 <writei+0xd2>
    return -1;
    80003d0e:	557d                	li	a0,-1
}
    80003d10:	8082                	ret
    return -1;
    80003d12:	557d                	li	a0,-1
    80003d14:	bfe1                	j	80003cec <writei+0xdc>

0000000080003d16 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d16:	1141                	addi	sp,sp,-16
    80003d18:	e406                	sd	ra,8(sp)
    80003d1a:	e022                	sd	s0,0(sp)
    80003d1c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d1e:	4639                	li	a2,14
    80003d20:	89cfd0ef          	jal	80000dbc <strncmp>
}
    80003d24:	60a2                	ld	ra,8(sp)
    80003d26:	6402                	ld	s0,0(sp)
    80003d28:	0141                	addi	sp,sp,16
    80003d2a:	8082                	ret

0000000080003d2c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d2c:	711d                	addi	sp,sp,-96
    80003d2e:	ec86                	sd	ra,88(sp)
    80003d30:	e8a2                	sd	s0,80(sp)
    80003d32:	e4a6                	sd	s1,72(sp)
    80003d34:	e0ca                	sd	s2,64(sp)
    80003d36:	fc4e                	sd	s3,56(sp)
    80003d38:	f852                	sd	s4,48(sp)
    80003d3a:	f456                	sd	s5,40(sp)
    80003d3c:	f05a                	sd	s6,32(sp)
    80003d3e:	ec5e                	sd	s7,24(sp)
    80003d40:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003d42:	04451703          	lh	a4,68(a0)
    80003d46:	4785                	li	a5,1
    80003d48:	00f71f63          	bne	a4,a5,80003d66 <dirlookup+0x3a>
    80003d4c:	892a                	mv	s2,a0
    80003d4e:	8aae                	mv	s5,a1
    80003d50:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003d52:	457c                	lw	a5,76(a0)
    80003d54:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d56:	fa040a13          	addi	s4,s0,-96
    80003d5a:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003d5c:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d60:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003d62:	e39d                	bnez	a5,80003d88 <dirlookup+0x5c>
    80003d64:	a8b9                	j	80003dc2 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003d66:	00004517          	auipc	a0,0x4
    80003d6a:	76250513          	addi	a0,a0,1890 # 800084c8 <etext+0x4c8>
    80003d6e:	ac7fc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    80003d72:	00004517          	auipc	a0,0x4
    80003d76:	76e50513          	addi	a0,a0,1902 # 800084e0 <etext+0x4e0>
    80003d7a:	abbfc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003d7e:	24c1                	addiw	s1,s1,16
    80003d80:	04c92783          	lw	a5,76(s2)
    80003d84:	02f4fe63          	bgeu	s1,a5,80003dc0 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d88:	874e                	mv	a4,s3
    80003d8a:	86a6                	mv	a3,s1
    80003d8c:	8652                	mv	a2,s4
    80003d8e:	4581                	li	a1,0
    80003d90:	854a                	mv	a0,s2
    80003d92:	d8dff0ef          	jal	80003b1e <readi>
    80003d96:	fd351ee3          	bne	a0,s3,80003d72 <dirlookup+0x46>
    if (de.inum == 0)
    80003d9a:	fa045783          	lhu	a5,-96(s0)
    80003d9e:	d3e5                	beqz	a5,80003d7e <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003da0:	85da                	mv	a1,s6
    80003da2:	8556                	mv	a0,s5
    80003da4:	f73ff0ef          	jal	80003d16 <namecmp>
    80003da8:	f979                	bnez	a0,80003d7e <dirlookup+0x52>
      if (poff)
    80003daa:	000b8463          	beqz	s7,80003db2 <dirlookup+0x86>
        *poff = off;
    80003dae:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003db2:	fa045583          	lhu	a1,-96(s0)
    80003db6:	00092503          	lw	a0,0(s2)
    80003dba:	f18ff0ef          	jal	800034d2 <iget>
    80003dbe:	a011                	j	80003dc2 <dirlookup+0x96>
  return 0;
    80003dc0:	4501                	li	a0,0
}
    80003dc2:	60e6                	ld	ra,88(sp)
    80003dc4:	6446                	ld	s0,80(sp)
    80003dc6:	64a6                	ld	s1,72(sp)
    80003dc8:	6906                	ld	s2,64(sp)
    80003dca:	79e2                	ld	s3,56(sp)
    80003dcc:	7a42                	ld	s4,48(sp)
    80003dce:	7aa2                	ld	s5,40(sp)
    80003dd0:	7b02                	ld	s6,32(sp)
    80003dd2:	6be2                	ld	s7,24(sp)
    80003dd4:	6125                	addi	sp,sp,96
    80003dd6:	8082                	ret

0000000080003dd8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003dd8:	711d                	addi	sp,sp,-96
    80003dda:	ec86                	sd	ra,88(sp)
    80003ddc:	e8a2                	sd	s0,80(sp)
    80003dde:	e4a6                	sd	s1,72(sp)
    80003de0:	e0ca                	sd	s2,64(sp)
    80003de2:	fc4e                	sd	s3,56(sp)
    80003de4:	f852                	sd	s4,48(sp)
    80003de6:	f456                	sd	s5,40(sp)
    80003de8:	f05a                	sd	s6,32(sp)
    80003dea:	ec5e                	sd	s7,24(sp)
    80003dec:	e862                	sd	s8,16(sp)
    80003dee:	e466                	sd	s9,8(sp)
    80003df0:	e06a                	sd	s10,0(sp)
    80003df2:	1080                	addi	s0,sp,96
    80003df4:	84aa                	mv	s1,a0
    80003df6:	8b2e                	mv	s6,a1
    80003df8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003dfa:	00054703          	lbu	a4,0(a0)
    80003dfe:	02f00793          	li	a5,47
    80003e02:	00f70f63          	beq	a4,a5,80003e20 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e06:	b47fd0ef          	jal	8000194c <myproc>
    80003e0a:	15053503          	ld	a0,336(a0)
    80003e0e:	901ff0ef          	jal	8000370e <idup>
    80003e12:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003e14:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003e18:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003e1a:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003e1c:	4b85                	li	s7,1
    80003e1e:	a07d                	j	80003ecc <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003e20:	4585                	li	a1,1
    80003e22:	852e                	mv	a0,a1
    80003e24:	eaeff0ef          	jal	800034d2 <iget>
    80003e28:	8a2a                	mv	s4,a0
    80003e2a:	b7ed                	j	80003e14 <namex+0x3c>
      iunlockput(ip);
    80003e2c:	8552                	mv	a0,s4
    80003e2e:	b6bff0ef          	jal	80003998 <iunlockput>
      return 0;
    80003e32:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e34:	8552                	mv	a0,s4
    80003e36:	60e6                	ld	ra,88(sp)
    80003e38:	6446                	ld	s0,80(sp)
    80003e3a:	64a6                	ld	s1,72(sp)
    80003e3c:	6906                	ld	s2,64(sp)
    80003e3e:	79e2                	ld	s3,56(sp)
    80003e40:	7a42                	ld	s4,48(sp)
    80003e42:	7aa2                	ld	s5,40(sp)
    80003e44:	7b02                	ld	s6,32(sp)
    80003e46:	6be2                	ld	s7,24(sp)
    80003e48:	6c42                	ld	s8,16(sp)
    80003e4a:	6ca2                	ld	s9,8(sp)
    80003e4c:	6d02                	ld	s10,0(sp)
    80003e4e:	6125                	addi	sp,sp,96
    80003e50:	8082                	ret
      iunlockput(ip);
    80003e52:	8552                	mv	a0,s4
    80003e54:	b45ff0ef          	jal	80003998 <iunlockput>
      return 0;
    80003e58:	4a01                	li	s4,0
    80003e5a:	bfe9                	j	80003e34 <namex+0x5c>
      iunlock(ip);
    80003e5c:	8552                	mv	a0,s4
    80003e5e:	995ff0ef          	jal	800037f2 <iunlock>
      return ip;
    80003e62:	bfc9                	j	80003e34 <namex+0x5c>
      iunlockput(ip);
    80003e64:	8552                	mv	a0,s4
    80003e66:	b33ff0ef          	jal	80003998 <iunlockput>
      return 0;
    80003e6a:	8a4a                	mv	s4,s2
    80003e6c:	b7e1                	j	80003e34 <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003e6e:	8926                	mv	s2,s1
  len = path - s;
    80003e70:	4d01                	li	s10,0
    80003e72:	4601                	li	a2,0
    memmove(name, s, len);
    80003e74:	2601                	sext.w	a2,a2
    80003e76:	85a6                	mv	a1,s1
    80003e78:	8556                	mv	a0,s5
    80003e7a:	ecffc0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003e7e:	9d56                	add	s10,s10,s5
    80003e80:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffda398>
  while (*path == '/')
    80003e84:	00094783          	lbu	a5,0(s2)
    80003e88:	09379b63          	bne	a5,s3,80003f1e <namex+0x146>
    80003e8c:	84ca                	mv	s1,s2
    path++;
    80003e8e:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003e90:	0004c783          	lbu	a5,0(s1)
    80003e94:	ff378de3          	beq	a5,s3,80003e8e <namex+0xb6>
    ilock(ip);
    80003e98:	8552                	mv	a0,s4
    80003e9a:	8abff0ef          	jal	80003744 <ilock>
    if (ip->type != T_DIR) {
    80003e9e:	044a1783          	lh	a5,68(s4)
    80003ea2:	f97795e3          	bne	a5,s7,80003e2c <namex+0x54>
    if (ip->nlink == 0) {
    80003ea6:	04aa1783          	lh	a5,74(s4)
    80003eaa:	d7c5                	beqz	a5,80003e52 <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003eac:	000b0563          	beqz	s6,80003eb6 <namex+0xde>
    80003eb0:	0004c783          	lbu	a5,0(s1)
    80003eb4:	d7c5                	beqz	a5,80003e5c <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003eb6:	4601                	li	a2,0
    80003eb8:	85d6                	mv	a1,s5
    80003eba:	8552                	mv	a0,s4
    80003ebc:	e71ff0ef          	jal	80003d2c <dirlookup>
    80003ec0:	892a                	mv	s2,a0
    80003ec2:	d14d                	beqz	a0,80003e64 <namex+0x8c>
    iunlockput(ip);
    80003ec4:	8552                	mv	a0,s4
    80003ec6:	ad3ff0ef          	jal	80003998 <iunlockput>
    ip = next;
    80003eca:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003ecc:	0004c783          	lbu	a5,0(s1)
    80003ed0:	01379763          	bne	a5,s3,80003ede <namex+0x106>
    path++;
    80003ed4:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003ed6:	0004c783          	lbu	a5,0(s1)
    80003eda:	ff378de3          	beq	a5,s3,80003ed4 <namex+0xfc>
  if (*path == 0)
    80003ede:	c7a1                	beqz	a5,80003f26 <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003ee0:	0004c783          	lbu	a5,0(s1)
    80003ee4:	fd178713          	addi	a4,a5,-47
    80003ee8:	d359                	beqz	a4,80003e6e <namex+0x96>
    80003eea:	d3d1                	beqz	a5,80003e6e <namex+0x96>
    80003eec:	8926                	mv	s2,s1
    path++;
    80003eee:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003ef0:	00094783          	lbu	a5,0(s2)
    80003ef4:	fd178713          	addi	a4,a5,-47
    80003ef8:	c311                	beqz	a4,80003efc <namex+0x124>
    80003efa:	fbf5                	bnez	a5,80003eee <namex+0x116>
  len = path - s;
    80003efc:	40990633          	sub	a2,s2,s1
    80003f00:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003f04:	f7ac58e3          	bge	s8,s10,80003e74 <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003f08:	8666                	mv	a2,s9
    80003f0a:	85a6                	mv	a1,s1
    80003f0c:	8556                	mv	a0,s5
    80003f0e:	e3bfc0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003f12:	00094783          	lbu	a5,0(s2)
    80003f16:	84ca                	mv	s1,s2
    80003f18:	f7378be3          	beq	a5,s3,80003e8e <namex+0xb6>
    80003f1c:	bfb5                	j	80003e98 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003f1e:	00090463          	beqz	s2,80003f26 <namex+0x14e>
    80003f22:	84ca                	mv	s1,s2
    80003f24:	bf95                	j	80003e98 <namex+0xc0>
  if (nameiparent) {
    80003f26:	f00b07e3          	beqz	s6,80003e34 <namex+0x5c>
    iput(ip);
    80003f2a:	8552                	mv	a0,s4
    80003f2c:	99bff0ef          	jal	800038c6 <iput>
    return 0;
    80003f30:	4a01                	li	s4,0
    80003f32:	b709                	j	80003e34 <namex+0x5c>

0000000080003f34 <dirlink>:
{
    80003f34:	715d                	addi	sp,sp,-80
    80003f36:	e486                	sd	ra,72(sp)
    80003f38:	e0a2                	sd	s0,64(sp)
    80003f3a:	f84a                	sd	s2,48(sp)
    80003f3c:	ec56                	sd	s5,24(sp)
    80003f3e:	e85a                	sd	s6,16(sp)
    80003f40:	0880                	addi	s0,sp,80
    80003f42:	892a                	mv	s2,a0
    80003f44:	8aae                	mv	s5,a1
    80003f46:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003f48:	4601                	li	a2,0
    80003f4a:	de3ff0ef          	jal	80003d2c <dirlookup>
    80003f4e:	ed1d                	bnez	a0,80003f8c <dirlink+0x58>
    80003f50:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003f52:	04c92483          	lw	s1,76(s2)
    80003f56:	c4b9                	beqz	s1,80003fa4 <dirlink+0x70>
    80003f58:	f44e                	sd	s3,40(sp)
    80003f5a:	f052                	sd	s4,32(sp)
    80003f5c:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f5e:	fb040a13          	addi	s4,s0,-80
    80003f62:	49c1                	li	s3,16
    80003f64:	874e                	mv	a4,s3
    80003f66:	86a6                	mv	a3,s1
    80003f68:	8652                	mv	a2,s4
    80003f6a:	4581                	li	a1,0
    80003f6c:	854a                	mv	a0,s2
    80003f6e:	bb1ff0ef          	jal	80003b1e <readi>
    80003f72:	03351163          	bne	a0,s3,80003f94 <dirlink+0x60>
    if (de.inum == 0)
    80003f76:	fb045783          	lhu	a5,-80(s0)
    80003f7a:	c39d                	beqz	a5,80003fa0 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003f7c:	24c1                	addiw	s1,s1,16
    80003f7e:	04c92783          	lw	a5,76(s2)
    80003f82:	fef4e1e3          	bltu	s1,a5,80003f64 <dirlink+0x30>
    80003f86:	79a2                	ld	s3,40(sp)
    80003f88:	7a02                	ld	s4,32(sp)
    80003f8a:	a829                	j	80003fa4 <dirlink+0x70>
    iput(ip);
    80003f8c:	93bff0ef          	jal	800038c6 <iput>
    return -1;
    80003f90:	557d                	li	a0,-1
    80003f92:	a83d                	j	80003fd0 <dirlink+0x9c>
      panic("dirlink read");
    80003f94:	00004517          	auipc	a0,0x4
    80003f98:	55c50513          	addi	a0,a0,1372 # 800084f0 <etext+0x4f0>
    80003f9c:	899fc0ef          	jal	80000834 <panic>
    80003fa0:	79a2                	ld	s3,40(sp)
    80003fa2:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003fa4:	4639                	li	a2,14
    80003fa6:	85d6                	mv	a1,s5
    80003fa8:	fb240513          	addi	a0,s0,-78
    80003fac:	e4bfc0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003fb0:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fb4:	4741                	li	a4,16
    80003fb6:	86a6                	mv	a3,s1
    80003fb8:	fb040613          	addi	a2,s0,-80
    80003fbc:	4581                	li	a1,0
    80003fbe:	854a                	mv	a0,s2
    80003fc0:	c51ff0ef          	jal	80003c10 <writei>
    80003fc4:	1541                	addi	a0,a0,-16
    80003fc6:	00a03533          	snez	a0,a0
    80003fca:	40a0053b          	negw	a0,a0
    80003fce:	74e2                	ld	s1,56(sp)
}
    80003fd0:	60a6                	ld	ra,72(sp)
    80003fd2:	6406                	ld	s0,64(sp)
    80003fd4:	7942                	ld	s2,48(sp)
    80003fd6:	6ae2                	ld	s5,24(sp)
    80003fd8:	6b42                	ld	s6,16(sp)
    80003fda:	6161                	addi	sp,sp,80
    80003fdc:	8082                	ret

0000000080003fde <namei>:

struct inode *
namei(char *path)
{
    80003fde:	1101                	addi	sp,sp,-32
    80003fe0:	ec06                	sd	ra,24(sp)
    80003fe2:	e822                	sd	s0,16(sp)
    80003fe4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003fe6:	fe040613          	addi	a2,s0,-32
    80003fea:	4581                	li	a1,0
    80003fec:	dedff0ef          	jal	80003dd8 <namex>
}
    80003ff0:	60e2                	ld	ra,24(sp)
    80003ff2:	6442                	ld	s0,16(sp)
    80003ff4:	6105                	addi	sp,sp,32
    80003ff6:	8082                	ret

0000000080003ff8 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003ff8:	1141                	addi	sp,sp,-16
    80003ffa:	e406                	sd	ra,8(sp)
    80003ffc:	e022                	sd	s0,0(sp)
    80003ffe:	0800                	addi	s0,sp,16
    80004000:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004002:	4585                	li	a1,1
    80004004:	dd5ff0ef          	jal	80003dd8 <namex>
}
    80004008:	60a2                	ld	ra,8(sp)
    8000400a:	6402                	ld	s0,0(sp)
    8000400c:	0141                	addi	sp,sp,16
    8000400e:	8082                	ret

0000000080004010 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004010:	1101                	addi	sp,sp,-32
    80004012:	ec06                	sd	ra,24(sp)
    80004014:	e822                	sd	s0,16(sp)
    80004016:	e426                	sd	s1,8(sp)
    80004018:	e04a                	sd	s2,0(sp)
    8000401a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000401c:	00020917          	auipc	s2,0x20
    80004020:	a0c90913          	addi	s2,s2,-1524 # 80023a28 <log>
    80004024:	01892583          	lw	a1,24(s2)
    80004028:	02492503          	lw	a0,36(s2)
    8000402c:	880ff0ef          	jal	800030ac <bread>
    80004030:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80004032:	02c92603          	lw	a2,44(s2)
    80004036:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004038:	00c05f63          	blez	a2,80004056 <write_head+0x46>
    8000403c:	00020717          	auipc	a4,0x20
    80004040:	a1c70713          	addi	a4,a4,-1508 # 80023a58 <log+0x30>
    80004044:	87aa                	mv	a5,a0
    80004046:	060a                	slli	a2,a2,0x2
    80004048:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000404a:	4314                	lw	a3,0(a4)
    8000404c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000404e:	0711                	addi	a4,a4,4
    80004050:	0791                	addi	a5,a5,4
    80004052:	fec79ce3          	bne	a5,a2,8000404a <write_head+0x3a>
  }
  bwrite(buf);
    80004056:	8526                	mv	a0,s1
    80004058:	92aff0ef          	jal	80003182 <bwrite>
  brelse(buf);
    8000405c:	8526                	mv	a0,s1
    8000405e:	956ff0ef          	jal	800031b4 <brelse>
}
    80004062:	60e2                	ld	ra,24(sp)
    80004064:	6442                	ld	s0,16(sp)
    80004066:	64a2                	ld	s1,8(sp)
    80004068:	6902                	ld	s2,0(sp)
    8000406a:	6105                	addi	sp,sp,32
    8000406c:	8082                	ret

000000008000406e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000406e:	00020797          	auipc	a5,0x20
    80004072:	9e67a783          	lw	a5,-1562(a5) # 80023a54 <log+0x2c>
    80004076:	0cf05163          	blez	a5,80004138 <install_trans+0xca>
{
    8000407a:	715d                	addi	sp,sp,-80
    8000407c:	e486                	sd	ra,72(sp)
    8000407e:	e0a2                	sd	s0,64(sp)
    80004080:	fc26                	sd	s1,56(sp)
    80004082:	f84a                	sd	s2,48(sp)
    80004084:	f44e                	sd	s3,40(sp)
    80004086:	f052                	sd	s4,32(sp)
    80004088:	ec56                	sd	s5,24(sp)
    8000408a:	e85a                	sd	s6,16(sp)
    8000408c:	e45e                	sd	s7,8(sp)
    8000408e:	e062                	sd	s8,0(sp)
    80004090:	0880                	addi	s0,sp,80
    80004092:	8b2a                	mv	s6,a0
    80004094:	00020a97          	auipc	s5,0x20
    80004098:	9c4a8a93          	addi	s5,s5,-1596 # 80023a58 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000409c:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000409e:	00004c17          	auipc	s8,0x4
    800040a2:	462c0c13          	addi	s8,s8,1122 # 80008500 <etext+0x500>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    800040a6:	00020a17          	auipc	s4,0x20
    800040aa:	982a0a13          	addi	s4,s4,-1662 # 80023a28 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    800040ae:	40000b93          	li	s7,1024
    800040b2:	a025                	j	800040da <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800040b4:	000aa603          	lw	a2,0(s5)
    800040b8:	85ce                	mv	a1,s3
    800040ba:	8562                	mv	a0,s8
    800040bc:	c4efc0ef          	jal	8000050a <printk>
    800040c0:	a839                	j	800040de <install_trans+0x70>
    brelse(lbuf);
    800040c2:	854a                	mv	a0,s2
    800040c4:	8f0ff0ef          	jal	800031b4 <brelse>
    brelse(dbuf);
    800040c8:	8526                	mv	a0,s1
    800040ca:	8eaff0ef          	jal	800031b4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040ce:	2985                	addiw	s3,s3,1
    800040d0:	0a91                	addi	s5,s5,4
    800040d2:	02ca2783          	lw	a5,44(s4)
    800040d6:	04f9d563          	bge	s3,a5,80004120 <install_trans+0xb2>
    if (recovering) {
    800040da:	fc0b1de3          	bnez	s6,800040b4 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    800040de:	018a2583          	lw	a1,24(s4)
    800040e2:	013585bb          	addw	a1,a1,s3
    800040e6:	2585                	addiw	a1,a1,1
    800040e8:	024a2503          	lw	a0,36(s4)
    800040ec:	fc1fe0ef          	jal	800030ac <bread>
    800040f0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    800040f2:	000aa583          	lw	a1,0(s5)
    800040f6:	024a2503          	lw	a0,36(s4)
    800040fa:	fb3fe0ef          	jal	800030ac <bread>
    800040fe:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80004100:	865e                	mv	a2,s7
    80004102:	05890593          	addi	a1,s2,88
    80004106:	05850513          	addi	a0,a0,88
    8000410a:	c3ffc0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    8000410e:	8526                	mv	a0,s1
    80004110:	872ff0ef          	jal	80003182 <bwrite>
    if (recovering == 0)
    80004114:	fa0b17e3          	bnez	s6,800040c2 <install_trans+0x54>
      bunpin(dbuf);
    80004118:	8526                	mv	a0,s1
    8000411a:	952ff0ef          	jal	8000326c <bunpin>
    8000411e:	b755                	j	800040c2 <install_trans+0x54>
}
    80004120:	60a6                	ld	ra,72(sp)
    80004122:	6406                	ld	s0,64(sp)
    80004124:	74e2                	ld	s1,56(sp)
    80004126:	7942                	ld	s2,48(sp)
    80004128:	79a2                	ld	s3,40(sp)
    8000412a:	7a02                	ld	s4,32(sp)
    8000412c:	6ae2                	ld	s5,24(sp)
    8000412e:	6b42                	ld	s6,16(sp)
    80004130:	6ba2                	ld	s7,8(sp)
    80004132:	6c02                	ld	s8,0(sp)
    80004134:	6161                	addi	sp,sp,80
    80004136:	8082                	ret
    80004138:	8082                	ret

000000008000413a <initlog>:
{
    8000413a:	7179                	addi	sp,sp,-48
    8000413c:	f406                	sd	ra,40(sp)
    8000413e:	f022                	sd	s0,32(sp)
    80004140:	ec26                	sd	s1,24(sp)
    80004142:	e84a                	sd	s2,16(sp)
    80004144:	e44e                	sd	s3,8(sp)
    80004146:	1800                	addi	s0,sp,48
    80004148:	84aa                	mv	s1,a0
    8000414a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000414c:	00020917          	auipc	s2,0x20
    80004150:	8dc90913          	addi	s2,s2,-1828 # 80023a28 <log>
    80004154:	00004597          	auipc	a1,0x4
    80004158:	3cc58593          	addi	a1,a1,972 # 80008520 <etext+0x520>
    8000415c:	854a                	mv	a0,s2
    8000415e:	a4bfc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80004162:	0149a583          	lw	a1,20(s3)
    80004166:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    8000416a:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    8000416e:	8526                	mv	a0,s1
    80004170:	f3dfe0ef          	jal	800030ac <bread>
  log.lh.n = lh->n;
    80004174:	4d30                	lw	a2,88(a0)
    80004176:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    8000417a:	00c05f63          	blez	a2,80004198 <initlog+0x5e>
    8000417e:	87aa                	mv	a5,a0
    80004180:	00020717          	auipc	a4,0x20
    80004184:	8d870713          	addi	a4,a4,-1832 # 80023a58 <log+0x30>
    80004188:	060a                	slli	a2,a2,0x2
    8000418a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000418c:	4ff4                	lw	a3,92(a5)
    8000418e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004190:	0791                	addi	a5,a5,4
    80004192:	0711                	addi	a4,a4,4
    80004194:	fec79ce3          	bne	a5,a2,8000418c <initlog+0x52>
  brelse(buf);
    80004198:	81cff0ef          	jal	800031b4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000419c:	4505                	li	a0,1
    8000419e:	ed1ff0ef          	jal	8000406e <install_trans>
  log.lh.n = 0;
    800041a2:	00020797          	auipc	a5,0x20
    800041a6:	8a07a923          	sw	zero,-1870(a5) # 80023a54 <log+0x2c>
  write_head(); // clear the log
    800041aa:	e67ff0ef          	jal	80004010 <write_head>
}
    800041ae:	70a2                	ld	ra,40(sp)
    800041b0:	7402                	ld	s0,32(sp)
    800041b2:	64e2                	ld	s1,24(sp)
    800041b4:	6942                	ld	s2,16(sp)
    800041b6:	69a2                	ld	s3,8(sp)
    800041b8:	6145                	addi	sp,sp,48
    800041ba:	8082                	ret

00000000800041bc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800041bc:	1101                	addi	sp,sp,-32
    800041be:	ec06                	sd	ra,24(sp)
    800041c0:	e822                	sd	s0,16(sp)
    800041c2:	e426                	sd	s1,8(sp)
    800041c4:	e04a                	sd	s2,0(sp)
    800041c6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800041c8:	00020517          	auipc	a0,0x20
    800041cc:	86050513          	addi	a0,a0,-1952 # 80023a28 <log>
    800041d0:	a59fc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    800041d4:	00020497          	auipc	s1,0x20
    800041d8:	85448493          	addi	s1,s1,-1964 # 80023a28 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    800041dc:	4979                	li	s2,30
    800041de:	a821                	j	800041f6 <begin_op+0x3a>
      sleep_prepare(&log);
    800041e0:	8526                	mv	a0,s1
    800041e2:	f5bfd0ef          	jal	8000213c <sleep_prepare>
      release(&log.lock);
    800041e6:	8526                	mv	a0,s1
    800041e8:	ac9fc0ef          	jal	80000cb0 <release>
      sleep();
    800041ec:	f8dfd0ef          	jal	80002178 <sleep>
      acquire(&log.lock);
    800041f0:	8526                	mv	a0,s1
    800041f2:	a37fc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    800041f6:	509c                	lw	a5,32(s1)
    800041f8:	f7e5                	bnez	a5,800041e0 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    800041fa:	4cd8                	lw	a4,28(s1)
    800041fc:	2705                	addiw	a4,a4,1
    800041fe:	0027179b          	slliw	a5,a4,0x2
    80004202:	9fb9                	addw	a5,a5,a4
    80004204:	0017979b          	slliw	a5,a5,0x1
    80004208:	54d4                	lw	a3,44(s1)
    8000420a:	9fb5                	addw	a5,a5,a3
    8000420c:	00f95e63          	bge	s2,a5,80004228 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80004210:	8526                	mv	a0,s1
    80004212:	f2bfd0ef          	jal	8000213c <sleep_prepare>
      release(&log.lock);
    80004216:	8526                	mv	a0,s1
    80004218:	a99fc0ef          	jal	80000cb0 <release>
      sleep();
    8000421c:	f5dfd0ef          	jal	80002178 <sleep>
      acquire(&log.lock);
    80004220:	8526                	mv	a0,s1
    80004222:	a07fc0ef          	jal	80000c28 <acquire>
    80004226:	bfc1                	j	800041f6 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80004228:	00020797          	auipc	a5,0x20
    8000422c:	80e7ae23          	sw	a4,-2020(a5) # 80023a44 <log+0x1c>
      release(&log.lock);
    80004230:	0001f517          	auipc	a0,0x1f
    80004234:	7f850513          	addi	a0,a0,2040 # 80023a28 <log>
    80004238:	a79fc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    8000423c:	60e2                	ld	ra,24(sp)
    8000423e:	6442                	ld	s0,16(sp)
    80004240:	64a2                	ld	s1,8(sp)
    80004242:	6902                	ld	s2,0(sp)
    80004244:	6105                	addi	sp,sp,32
    80004246:	8082                	ret

0000000080004248 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004248:	7139                	addi	sp,sp,-64
    8000424a:	fc06                	sd	ra,56(sp)
    8000424c:	f822                	sd	s0,48(sp)
    8000424e:	f426                	sd	s1,40(sp)
    80004250:	f04a                	sd	s2,32(sp)
    80004252:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004254:	0001f497          	auipc	s1,0x1f
    80004258:	7d448493          	addi	s1,s1,2004 # 80023a28 <log>
    8000425c:	8526                	mv	a0,s1
    8000425e:	9cbfc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80004262:	4cdc                	lw	a5,28(s1)
    80004264:	37fd                	addiw	a5,a5,-1
    80004266:	893e                	mv	s2,a5
    80004268:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    8000426a:	509c                	lw	a5,32(s1)
    8000426c:	e3b1                	bnez	a5,800042b0 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    8000426e:	04091a63          	bnez	s2,800042c2 <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80004272:	0001f497          	auipc	s1,0x1f
    80004276:	7b648493          	addi	s1,s1,1974 # 80023a28 <log>
    8000427a:	4785                	li	a5,1
    8000427c:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000427e:	8526                	mv	a0,s1
    80004280:	a31fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004284:	54dc                	lw	a5,44(s1)
    80004286:	06f04063          	bgtz	a5,800042e6 <end_op+0x9e>
    acquire(&log.lock);
    8000428a:	0001f497          	auipc	s1,0x1f
    8000428e:	79e48493          	addi	s1,s1,1950 # 80023a28 <log>
    80004292:	8526                	mv	a0,s1
    80004294:	995fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80004298:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    8000429c:	549c                	lw	a5,40(s1)
    8000429e:	2785                	addiw	a5,a5,1
    800042a0:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    800042a2:	8526                	mv	a0,s1
    800042a4:	f05fd0ef          	jal	800021a8 <wakeup>
    release(&log.lock);
    800042a8:	8526                	mv	a0,s1
    800042aa:	a07fc0ef          	jal	80000cb0 <release>
}
    800042ae:	a035                	j	800042da <end_op+0x92>
    800042b0:	ec4e                	sd	s3,24(sp)
    800042b2:	e852                	sd	s4,16(sp)
    800042b4:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800042b6:	00004517          	auipc	a0,0x4
    800042ba:	27250513          	addi	a0,a0,626 # 80008528 <etext+0x528>
    800042be:	d76fc0ef          	jal	80000834 <panic>
    wakeup(&log);
    800042c2:	0001f517          	auipc	a0,0x1f
    800042c6:	76650513          	addi	a0,a0,1894 # 80023a28 <log>
    800042ca:	edffd0ef          	jal	800021a8 <wakeup>
  release(&log.lock);
    800042ce:	0001f517          	auipc	a0,0x1f
    800042d2:	75a50513          	addi	a0,a0,1882 # 80023a28 <log>
    800042d6:	9dbfc0ef          	jal	80000cb0 <release>
}
    800042da:	70e2                	ld	ra,56(sp)
    800042dc:	7442                	ld	s0,48(sp)
    800042de:	74a2                	ld	s1,40(sp)
    800042e0:	7902                	ld	s2,32(sp)
    800042e2:	6121                	addi	sp,sp,64
    800042e4:	8082                	ret
    800042e6:	ec4e                	sd	s3,24(sp)
    800042e8:	e852                	sd	s4,16(sp)
    800042ea:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800042ec:	0001fa97          	auipc	s5,0x1f
    800042f0:	76ca8a93          	addi	s5,s5,1900 # 80023a58 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    800042f4:	0001fa17          	auipc	s4,0x1f
    800042f8:	734a0a13          	addi	s4,s4,1844 # 80023a28 <log>
    800042fc:	018a2583          	lw	a1,24(s4)
    80004300:	012585bb          	addw	a1,a1,s2
    80004304:	2585                	addiw	a1,a1,1
    80004306:	024a2503          	lw	a0,36(s4)
    8000430a:	da3fe0ef          	jal	800030ac <bread>
    8000430e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004310:	000aa583          	lw	a1,0(s5)
    80004314:	024a2503          	lw	a0,36(s4)
    80004318:	d95fe0ef          	jal	800030ac <bread>
    8000431c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000431e:	40000613          	li	a2,1024
    80004322:	05850593          	addi	a1,a0,88
    80004326:	05848513          	addi	a0,s1,88
    8000432a:	a1ffc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    8000432e:	8526                	mv	a0,s1
    80004330:	e53fe0ef          	jal	80003182 <bwrite>
    brelse(from);
    80004334:	854e                	mv	a0,s3
    80004336:	e7ffe0ef          	jal	800031b4 <brelse>
    brelse(to);
    8000433a:	8526                	mv	a0,s1
    8000433c:	e79fe0ef          	jal	800031b4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004340:	2905                	addiw	s2,s2,1
    80004342:	0a91                	addi	s5,s5,4
    80004344:	02ca2783          	lw	a5,44(s4)
    80004348:	faf94ae3          	blt	s2,a5,800042fc <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    8000434c:	cc5ff0ef          	jal	80004010 <write_head>
    install_trans(0); // Now install writes to home locations
    80004350:	4501                	li	a0,0
    80004352:	d1dff0ef          	jal	8000406e <install_trans>
    log.lh.n = 0;
    80004356:	0001f797          	auipc	a5,0x1f
    8000435a:	6e07af23          	sw	zero,1790(a5) # 80023a54 <log+0x2c>
    write_head(); // Erase the transaction from the log
    8000435e:	cb3ff0ef          	jal	80004010 <write_head>
    80004362:	69e2                	ld	s3,24(sp)
    80004364:	6a42                	ld	s4,16(sp)
    80004366:	6aa2                	ld	s5,8(sp)
    80004368:	b70d                	j	8000428a <end_op+0x42>

000000008000436a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000436a:	1101                	addi	sp,sp,-32
    8000436c:	ec06                	sd	ra,24(sp)
    8000436e:	e822                	sd	s0,16(sp)
    80004370:	e426                	sd	s1,8(sp)
    80004372:	1000                	addi	s0,sp,32
    80004374:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004376:	0001f517          	auipc	a0,0x1f
    8000437a:	6b250513          	addi	a0,a0,1714 # 80023a28 <log>
    8000437e:	8abfc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004382:	0001f617          	auipc	a2,0x1f
    80004386:	6d262603          	lw	a2,1746(a2) # 80023a54 <log+0x2c>
    8000438a:	47f5                	li	a5,29
    8000438c:	04c7cd63          	blt	a5,a2,800043e6 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004390:	0001f797          	auipc	a5,0x1f
    80004394:	6b47a783          	lw	a5,1716(a5) # 80023a44 <log+0x1c>
    80004398:	04f05d63          	blez	a5,800043f2 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000439c:	4781                	li	a5,0
    8000439e:	06c05063          	blez	a2,800043fe <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    800043a2:	44cc                	lw	a1,12(s1)
    800043a4:	0001f717          	auipc	a4,0x1f
    800043a8:	6b470713          	addi	a4,a4,1716 # 80023a58 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800043ac:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    800043ae:	4314                	lw	a3,0(a4)
    800043b0:	04b68763          	beq	a3,a1,800043fe <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    800043b4:	2785                	addiw	a5,a5,1
    800043b6:	0711                	addi	a4,a4,4
    800043b8:	fef61be3          	bne	a2,a5,800043ae <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800043bc:	060a                	slli	a2,a2,0x2
    800043be:	02060613          	addi	a2,a2,32
    800043c2:	0001f797          	auipc	a5,0x1f
    800043c6:	66678793          	addi	a5,a5,1638 # 80023a28 <log>
    800043ca:	97b2                	add	a5,a5,a2
    800043cc:	44d8                	lw	a4,12(s1)
    800043ce:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    800043d0:	8526                	mv	a0,s1
    800043d2:	e67fe0ef          	jal	80003238 <bpin>
    log.lh.n++;
    800043d6:	0001f717          	auipc	a4,0x1f
    800043da:	65270713          	addi	a4,a4,1618 # 80023a28 <log>
    800043de:	575c                	lw	a5,44(a4)
    800043e0:	2785                	addiw	a5,a5,1
    800043e2:	d75c                	sw	a5,44(a4)
    800043e4:	a815                	j	80004418 <log_write+0xae>
    panic("too big a transaction");
    800043e6:	00004517          	auipc	a0,0x4
    800043ea:	15250513          	addi	a0,a0,338 # 80008538 <etext+0x538>
    800043ee:	c46fc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    800043f2:	00004517          	auipc	a0,0x4
    800043f6:	15e50513          	addi	a0,a0,350 # 80008550 <etext+0x550>
    800043fa:	c3afc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    800043fe:	00279693          	slli	a3,a5,0x2
    80004402:	02068693          	addi	a3,a3,32
    80004406:	0001f717          	auipc	a4,0x1f
    8000440a:	62270713          	addi	a4,a4,1570 # 80023a28 <log>
    8000440e:	9736                	add	a4,a4,a3
    80004410:	44d4                	lw	a3,12(s1)
    80004412:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80004414:	faf60ee3          	beq	a2,a5,800043d0 <log_write+0x66>
  }
  release(&log.lock);
    80004418:	0001f517          	auipc	a0,0x1f
    8000441c:	61050513          	addi	a0,a0,1552 # 80023a28 <log>
    80004420:	891fc0ef          	jal	80000cb0 <release>
}
    80004424:	60e2                	ld	ra,24(sp)
    80004426:	6442                	ld	s0,16(sp)
    80004428:	64a2                	ld	s1,8(sp)
    8000442a:	6105                	addi	sp,sp,32
    8000442c:	8082                	ret

000000008000442e <sys_sync>:

uint64
sys_sync(void)
{
    8000442e:	1101                	addi	sp,sp,-32
    80004430:	ec06                	sd	ra,24(sp)
    80004432:	e822                	sd	s0,16(sp)
    80004434:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004436:	0001f517          	auipc	a0,0x1f
    8000443a:	5f250513          	addi	a0,a0,1522 # 80023a28 <log>
    8000443e:	feafc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    80004442:	0001f797          	auipc	a5,0x1f
    80004446:	6067a783          	lw	a5,1542(a5) # 80023a48 <log+0x20>
    8000444a:	e799                	bnez	a5,80004458 <sys_sync+0x2a>
    8000444c:	0001f797          	auipc	a5,0x1f
    80004450:	5f87a783          	lw	a5,1528(a5) # 80023a44 <log+0x1c>
    80004454:	02f05c63          	blez	a5,8000448c <sys_sync+0x5e>
    80004458:	e426                	sd	s1,8(sp)
    8000445a:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    8000445c:	0001f917          	auipc	s2,0x1f
    80004460:	5f492903          	lw	s2,1524(s2) # 80023a50 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80004464:	0001f497          	auipc	s1,0x1f
    80004468:	5c448493          	addi	s1,s1,1476 # 80023a28 <log>
    8000446c:	8526                	mv	a0,s1
    8000446e:	ccffd0ef          	jal	8000213c <sleep_prepare>
      release(&log.lock);
    80004472:	8526                	mv	a0,s1
    80004474:	83dfc0ef          	jal	80000cb0 <release>
      sleep();
    80004478:	d01fd0ef          	jal	80002178 <sleep>
      acquire(&log.lock);
    8000447c:	8526                	mv	a0,s1
    8000447e:	faafc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    80004482:	549c                	lw	a5,40(s1)
    80004484:	fef954e3          	bge	s2,a5,8000446c <sys_sync+0x3e>
    80004488:	64a2                	ld	s1,8(sp)
    8000448a:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    8000448c:	0001f517          	auipc	a0,0x1f
    80004490:	59c50513          	addi	a0,a0,1436 # 80023a28 <log>
    80004494:	81dfc0ef          	jal	80000cb0 <release>
  return 0;
}
    80004498:	4501                	li	a0,0
    8000449a:	60e2                	ld	ra,24(sp)
    8000449c:	6442                	ld	s0,16(sp)
    8000449e:	6105                	addi	sp,sp,32
    800044a0:	8082                	ret

00000000800044a2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044a2:	1101                	addi	sp,sp,-32
    800044a4:	ec06                	sd	ra,24(sp)
    800044a6:	e822                	sd	s0,16(sp)
    800044a8:	e426                	sd	s1,8(sp)
    800044aa:	e04a                	sd	s2,0(sp)
    800044ac:	1000                	addi	s0,sp,32
    800044ae:	84aa                	mv	s1,a0
    800044b0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800044b2:	00004597          	auipc	a1,0x4
    800044b6:	0be58593          	addi	a1,a1,190 # 80008570 <etext+0x570>
    800044ba:	0521                	addi	a0,a0,8
    800044bc:	eecfc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    800044c0:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800044c4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044c8:	0204a423          	sw	zero,40(s1)
}
    800044cc:	60e2                	ld	ra,24(sp)
    800044ce:	6442                	ld	s0,16(sp)
    800044d0:	64a2                	ld	s1,8(sp)
    800044d2:	6902                	ld	s2,0(sp)
    800044d4:	6105                	addi	sp,sp,32
    800044d6:	8082                	ret

00000000800044d8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800044d8:	1101                	addi	sp,sp,-32
    800044da:	ec06                	sd	ra,24(sp)
    800044dc:	e822                	sd	s0,16(sp)
    800044de:	e426                	sd	s1,8(sp)
    800044e0:	e04a                	sd	s2,0(sp)
    800044e2:	1000                	addi	s0,sp,32
    800044e4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044e6:	00850913          	addi	s2,a0,8
    800044ea:	854a                	mv	a0,s2
    800044ec:	f3cfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800044f0:	409c                	lw	a5,0(s1)
    800044f2:	cf91                	beqz	a5,8000450e <acquiresleep+0x36>
    sleep_prepare(lk);
    800044f4:	8526                	mv	a0,s1
    800044f6:	c47fd0ef          	jal	8000213c <sleep_prepare>
    release(&lk->lk);
    800044fa:	854a                	mv	a0,s2
    800044fc:	fb4fc0ef          	jal	80000cb0 <release>
    sleep();
    80004500:	c79fd0ef          	jal	80002178 <sleep>
    acquire(&lk->lk);
    80004504:	854a                	mv	a0,s2
    80004506:	f22fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    8000450a:	409c                	lw	a5,0(s1)
    8000450c:	f7e5                	bnez	a5,800044f4 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000450e:	4785                	li	a5,1
    80004510:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004512:	c3afd0ef          	jal	8000194c <myproc>
    80004516:	591c                	lw	a5,48(a0)
    80004518:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000451a:	854a                	mv	a0,s2
    8000451c:	f94fc0ef          	jal	80000cb0 <release>
}
    80004520:	60e2                	ld	ra,24(sp)
    80004522:	6442                	ld	s0,16(sp)
    80004524:	64a2                	ld	s1,8(sp)
    80004526:	6902                	ld	s2,0(sp)
    80004528:	6105                	addi	sp,sp,32
    8000452a:	8082                	ret

000000008000452c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000452c:	1101                	addi	sp,sp,-32
    8000452e:	ec06                	sd	ra,24(sp)
    80004530:	e822                	sd	s0,16(sp)
    80004532:	e426                	sd	s1,8(sp)
    80004534:	e04a                	sd	s2,0(sp)
    80004536:	1000                	addi	s0,sp,32
    80004538:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000453a:	00850913          	addi	s2,a0,8
    8000453e:	854a                	mv	a0,s2
    80004540:	ee8fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    80004544:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004548:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000454c:	8526                	mv	a0,s1
    8000454e:	c5bfd0ef          	jal	800021a8 <wakeup>
  release(&lk->lk);
    80004552:	854a                	mv	a0,s2
    80004554:	f5cfc0ef          	jal	80000cb0 <release>
}
    80004558:	60e2                	ld	ra,24(sp)
    8000455a:	6442                	ld	s0,16(sp)
    8000455c:	64a2                	ld	s1,8(sp)
    8000455e:	6902                	ld	s2,0(sp)
    80004560:	6105                	addi	sp,sp,32
    80004562:	8082                	ret

0000000080004564 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004564:	7179                	addi	sp,sp,-48
    80004566:	f406                	sd	ra,40(sp)
    80004568:	f022                	sd	s0,32(sp)
    8000456a:	ec26                	sd	s1,24(sp)
    8000456c:	e84a                	sd	s2,16(sp)
    8000456e:	1800                	addi	s0,sp,48
    80004570:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80004572:	00850913          	addi	s2,a0,8
    80004576:	854a                	mv	a0,s2
    80004578:	eb0fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000457c:	409c                	lw	a5,0(s1)
    8000457e:	ef81                	bnez	a5,80004596 <holdingsleep+0x32>
    80004580:	4481                	li	s1,0
  release(&lk->lk);
    80004582:	854a                	mv	a0,s2
    80004584:	f2cfc0ef          	jal	80000cb0 <release>
  return r;
}
    80004588:	8526                	mv	a0,s1
    8000458a:	70a2                	ld	ra,40(sp)
    8000458c:	7402                	ld	s0,32(sp)
    8000458e:	64e2                	ld	s1,24(sp)
    80004590:	6942                	ld	s2,16(sp)
    80004592:	6145                	addi	sp,sp,48
    80004594:	8082                	ret
    80004596:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004598:	0284a983          	lw	s3,40(s1)
    8000459c:	bb0fd0ef          	jal	8000194c <myproc>
    800045a0:	5904                	lw	s1,48(a0)
    800045a2:	413484b3          	sub	s1,s1,s3
    800045a6:	0014b493          	seqz	s1,s1
    800045aa:	69a2                	ld	s3,8(sp)
    800045ac:	bfd9                	j	80004582 <holdingsleep+0x1e>

00000000800045ae <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800045ae:	1141                	addi	sp,sp,-16
    800045b0:	e406                	sd	ra,8(sp)
    800045b2:	e022                	sd	s0,0(sp)
    800045b4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800045b6:	00004597          	auipc	a1,0x4
    800045ba:	fca58593          	addi	a1,a1,-54 # 80008580 <etext+0x580>
    800045be:	0001f517          	auipc	a0,0x1f
    800045c2:	5b250513          	addi	a0,a0,1458 # 80023b70 <ftable>
    800045c6:	de2fc0ef          	jal	80000ba8 <initlock>
}
    800045ca:	60a2                	ld	ra,8(sp)
    800045cc:	6402                	ld	s0,0(sp)
    800045ce:	0141                	addi	sp,sp,16
    800045d0:	8082                	ret

00000000800045d2 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800045d2:	1101                	addi	sp,sp,-32
    800045d4:	ec06                	sd	ra,24(sp)
    800045d6:	e822                	sd	s0,16(sp)
    800045d8:	e426                	sd	s1,8(sp)
    800045da:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045dc:	0001f517          	auipc	a0,0x1f
    800045e0:	59450513          	addi	a0,a0,1428 # 80023b70 <ftable>
    800045e4:	e44fc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800045e8:	0001f497          	auipc	s1,0x1f
    800045ec:	5a048493          	addi	s1,s1,1440 # 80023b88 <ftable+0x18>
    800045f0:	00020717          	auipc	a4,0x20
    800045f4:	53870713          	addi	a4,a4,1336 # 80024b28 <disk>
    if (f->ref == 0) {
    800045f8:	40dc                	lw	a5,4(s1)
    800045fa:	cf89                	beqz	a5,80004614 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800045fc:	02848493          	addi	s1,s1,40
    80004600:	fee49ce3          	bne	s1,a4,800045f8 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004604:	0001f517          	auipc	a0,0x1f
    80004608:	56c50513          	addi	a0,a0,1388 # 80023b70 <ftable>
    8000460c:	ea4fc0ef          	jal	80000cb0 <release>
  return 0;
    80004610:	4481                	li	s1,0
    80004612:	a809                	j	80004624 <filealloc+0x52>
      f->ref = 1;
    80004614:	4785                	li	a5,1
    80004616:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004618:	0001f517          	auipc	a0,0x1f
    8000461c:	55850513          	addi	a0,a0,1368 # 80023b70 <ftable>
    80004620:	e90fc0ef          	jal	80000cb0 <release>
}
    80004624:	8526                	mv	a0,s1
    80004626:	60e2                	ld	ra,24(sp)
    80004628:	6442                	ld	s0,16(sp)
    8000462a:	64a2                	ld	s1,8(sp)
    8000462c:	6105                	addi	sp,sp,32
    8000462e:	8082                	ret

0000000080004630 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004630:	1101                	addi	sp,sp,-32
    80004632:	ec06                	sd	ra,24(sp)
    80004634:	e822                	sd	s0,16(sp)
    80004636:	e426                	sd	s1,8(sp)
    80004638:	1000                	addi	s0,sp,32
    8000463a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000463c:	0001f517          	auipc	a0,0x1f
    80004640:	53450513          	addi	a0,a0,1332 # 80023b70 <ftable>
    80004644:	de4fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    80004648:	40dc                	lw	a5,4(s1)
    8000464a:	02f05063          	blez	a5,8000466a <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000464e:	2785                	addiw	a5,a5,1
    80004650:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004652:	0001f517          	auipc	a0,0x1f
    80004656:	51e50513          	addi	a0,a0,1310 # 80023b70 <ftable>
    8000465a:	e56fc0ef          	jal	80000cb0 <release>
  return f;
}
    8000465e:	8526                	mv	a0,s1
    80004660:	60e2                	ld	ra,24(sp)
    80004662:	6442                	ld	s0,16(sp)
    80004664:	64a2                	ld	s1,8(sp)
    80004666:	6105                	addi	sp,sp,32
    80004668:	8082                	ret
    panic("filedup");
    8000466a:	00004517          	auipc	a0,0x4
    8000466e:	f1e50513          	addi	a0,a0,-226 # 80008588 <etext+0x588>
    80004672:	9c2fc0ef          	jal	80000834 <panic>

0000000080004676 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004676:	7139                	addi	sp,sp,-64
    80004678:	fc06                	sd	ra,56(sp)
    8000467a:	f822                	sd	s0,48(sp)
    8000467c:	f426                	sd	s1,40(sp)
    8000467e:	0080                	addi	s0,sp,64
    80004680:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004682:	0001f517          	auipc	a0,0x1f
    80004686:	4ee50513          	addi	a0,a0,1262 # 80023b70 <ftable>
    8000468a:	d9efc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    8000468e:	40dc                	lw	a5,4(s1)
    80004690:	04f05a63          	blez	a5,800046e4 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    80004694:	37fd                	addiw	a5,a5,-1
    80004696:	c0dc                	sw	a5,4(s1)
    80004698:	06f04063          	bgtz	a5,800046f8 <fileclose+0x82>
    8000469c:	f04a                	sd	s2,32(sp)
    8000469e:	ec4e                	sd	s3,24(sp)
    800046a0:	e852                	sd	s4,16(sp)
    800046a2:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800046a4:	0004a903          	lw	s2,0(s1)
    800046a8:	0094c783          	lbu	a5,9(s1)
    800046ac:	89be                	mv	s3,a5
    800046ae:	689c                	ld	a5,16(s1)
    800046b0:	8a3e                	mv	s4,a5
    800046b2:	6c9c                	ld	a5,24(s1)
    800046b4:	8abe                	mv	s5,a5
  f->ref = 0;
    800046b6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800046ba:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800046be:	0001f517          	auipc	a0,0x1f
    800046c2:	4b250513          	addi	a0,a0,1202 # 80023b70 <ftable>
    800046c6:	deafc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    800046ca:	4785                	li	a5,1
    800046cc:	04f90163          	beq	s2,a5,8000470e <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    800046d0:	ffe9079b          	addiw	a5,s2,-2
    800046d4:	4705                	li	a4,1
    800046d6:	04f77563          	bgeu	a4,a5,80004720 <fileclose+0xaa>
    800046da:	7902                	ld	s2,32(sp)
    800046dc:	69e2                	ld	s3,24(sp)
    800046de:	6a42                	ld	s4,16(sp)
    800046e0:	6aa2                	ld	s5,8(sp)
    800046e2:	a00d                	j	80004704 <fileclose+0x8e>
    800046e4:	f04a                	sd	s2,32(sp)
    800046e6:	ec4e                	sd	s3,24(sp)
    800046e8:	e852                	sd	s4,16(sp)
    800046ea:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800046ec:	00004517          	auipc	a0,0x4
    800046f0:	ea450513          	addi	a0,a0,-348 # 80008590 <etext+0x590>
    800046f4:	940fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    800046f8:	0001f517          	auipc	a0,0x1f
    800046fc:	47850513          	addi	a0,a0,1144 # 80023b70 <ftable>
    80004700:	db0fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004704:	70e2                	ld	ra,56(sp)
    80004706:	7442                	ld	s0,48(sp)
    80004708:	74a2                	ld	s1,40(sp)
    8000470a:	6121                	addi	sp,sp,64
    8000470c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000470e:	85ce                	mv	a1,s3
    80004710:	8552                	mv	a0,s4
    80004712:	36a000ef          	jal	80004a7c <pipeclose>
    80004716:	7902                	ld	s2,32(sp)
    80004718:	69e2                	ld	s3,24(sp)
    8000471a:	6a42                	ld	s4,16(sp)
    8000471c:	6aa2                	ld	s5,8(sp)
    8000471e:	b7dd                	j	80004704 <fileclose+0x8e>
    begin_op();
    80004720:	a9dff0ef          	jal	800041bc <begin_op>
    iput(ff.ip);
    80004724:	8556                	mv	a0,s5
    80004726:	9a0ff0ef          	jal	800038c6 <iput>
    end_op();
    8000472a:	b1fff0ef          	jal	80004248 <end_op>
    8000472e:	7902                	ld	s2,32(sp)
    80004730:	69e2                	ld	s3,24(sp)
    80004732:	6a42                	ld	s4,16(sp)
    80004734:	6aa2                	ld	s5,8(sp)
    80004736:	b7f9                	j	80004704 <fileclose+0x8e>

0000000080004738 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004738:	715d                	addi	sp,sp,-80
    8000473a:	e486                	sd	ra,72(sp)
    8000473c:	e0a2                	sd	s0,64(sp)
    8000473e:	fc26                	sd	s1,56(sp)
    80004740:	f052                	sd	s4,32(sp)
    80004742:	0880                	addi	s0,sp,80
    80004744:	84aa                	mv	s1,a0
    80004746:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004748:	a04fd0ef          	jal	8000194c <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    8000474c:	409c                	lw	a5,0(s1)
    8000474e:	37f9                	addiw	a5,a5,-2
    80004750:	4705                	li	a4,1
    80004752:	04f76963          	bltu	a4,a5,800047a4 <filestat+0x6c>
    80004756:	f84a                	sd	s2,48(sp)
    80004758:	f44e                	sd	s3,40(sp)
    8000475a:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    8000475c:	fb840993          	addi	s3,s0,-72
    80004760:	4661                	li	a2,24
    80004762:	4581                	li	a1,0
    80004764:	854e                	mv	a0,s3
    80004766:	d82fc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    8000476a:	6c88                	ld	a0,24(s1)
    8000476c:	fd9fe0ef          	jal	80003744 <ilock>
    stati(f->ip, &st);
    80004770:	85ce                	mv	a1,s3
    80004772:	6c88                	ld	a0,24(s1)
    80004774:	b7cff0ef          	jal	80003af0 <stati>
    iunlock(f->ip);
    80004778:	6c88                	ld	a0,24(s1)
    8000477a:	878ff0ef          	jal	800037f2 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    8000477e:	4761                	li	a4,24
    80004780:	86ce                	mv	a3,s3
    80004782:	8652                	mv	a2,s4
    80004784:	04893583          	ld	a1,72(s2)
    80004788:	05093503          	ld	a0,80(s2)
    8000478c:	dfbfc0ef          	jal	80001586 <copyout>
    80004790:	41f5551b          	sraiw	a0,a0,0x1f
    80004794:	7942                	ld	s2,48(sp)
    80004796:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004798:	60a6                	ld	ra,72(sp)
    8000479a:	6406                	ld	s0,64(sp)
    8000479c:	74e2                	ld	s1,56(sp)
    8000479e:	7a02                	ld	s4,32(sp)
    800047a0:	6161                	addi	sp,sp,80
    800047a2:	8082                	ret
  return -1;
    800047a4:	557d                	li	a0,-1
    800047a6:	bfcd                	j	80004798 <filestat+0x60>

00000000800047a8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800047a8:	7179                	addi	sp,sp,-48
    800047aa:	f406                	sd	ra,40(sp)
    800047ac:	f022                	sd	s0,32(sp)
    800047ae:	e84a                	sd	s2,16(sp)
    800047b0:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    800047b2:	00854783          	lbu	a5,8(a0)
    800047b6:	c3dd                	beqz	a5,8000485c <fileread+0xb4>
    800047b8:	ec26                	sd	s1,24(sp)
    800047ba:	e44e                	sd	s3,8(sp)
    800047bc:	84aa                	mv	s1,a0
    800047be:	892e                	mv	s2,a1
    800047c0:	89b2                	mv	s3,a2
    800047c2:	01f6579b          	srliw	a5,a2,0x1f
    800047c6:	ebc9                	bnez	a5,80004858 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    800047c8:	411c                	lw	a5,0(a0)
    800047ca:	4705                	li	a4,1
    800047cc:	04e78363          	beq	a5,a4,80004812 <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800047d0:	470d                	li	a4,3
    800047d2:	04e78763          	beq	a5,a4,80004820 <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    800047d6:	4709                	li	a4,2
    800047d8:	06e79a63          	bne	a5,a4,8000484c <fileread+0xa4>
    ilock(f->ip);
    800047dc:	6d08                	ld	a0,24(a0)
    800047de:	f67fe0ef          	jal	80003744 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800047e2:	874e                	mv	a4,s3
    800047e4:	5094                	lw	a3,32(s1)
    800047e6:	864a                	mv	a2,s2
    800047e8:	4585                	li	a1,1
    800047ea:	6c88                	ld	a0,24(s1)
    800047ec:	b32ff0ef          	jal	80003b1e <readi>
    800047f0:	892a                	mv	s2,a0
    800047f2:	00a05563          	blez	a0,800047fc <fileread+0x54>
      f->off += r;
    800047f6:	509c                	lw	a5,32(s1)
    800047f8:	9fa9                	addw	a5,a5,a0
    800047fa:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800047fc:	6c88                	ld	a0,24(s1)
    800047fe:	ff5fe0ef          	jal	800037f2 <iunlock>
    80004802:	64e2                	ld	s1,24(sp)
    80004804:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004806:	854a                	mv	a0,s2
    80004808:	70a2                	ld	ra,40(sp)
    8000480a:	7402                	ld	s0,32(sp)
    8000480c:	6942                	ld	s2,16(sp)
    8000480e:	6145                	addi	sp,sp,48
    80004810:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004812:	6908                	ld	a0,16(a0)
    80004814:	3e2000ef          	jal	80004bf6 <piperead>
    80004818:	892a                	mv	s2,a0
    8000481a:	64e2                	ld	s1,24(sp)
    8000481c:	69a2                	ld	s3,8(sp)
    8000481e:	b7e5                	j	80004806 <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004820:	02451783          	lh	a5,36(a0)
    80004824:	03079693          	slli	a3,a5,0x30
    80004828:	92c1                	srli	a3,a3,0x30
    8000482a:	4725                	li	a4,9
    8000482c:	02d76b63          	bltu	a4,a3,80004862 <fileread+0xba>
    80004830:	0792                	slli	a5,a5,0x4
    80004832:	0001f717          	auipc	a4,0x1f
    80004836:	29e70713          	addi	a4,a4,670 # 80023ad0 <devsw>
    8000483a:	97ba                	add	a5,a5,a4
    8000483c:	639c                	ld	a5,0(a5)
    8000483e:	c79d                	beqz	a5,8000486c <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    80004840:	4505                	li	a0,1
    80004842:	9782                	jalr	a5
    80004844:	892a                	mv	s2,a0
    80004846:	64e2                	ld	s1,24(sp)
    80004848:	69a2                	ld	s3,8(sp)
    8000484a:	bf75                	j	80004806 <fileread+0x5e>
    panic("fileread");
    8000484c:	00004517          	auipc	a0,0x4
    80004850:	d5450513          	addi	a0,a0,-684 # 800085a0 <etext+0x5a0>
    80004854:	fe1fb0ef          	jal	80000834 <panic>
    80004858:	64e2                	ld	s1,24(sp)
    8000485a:	69a2                	ld	s3,8(sp)
    return -1;
    8000485c:	57fd                	li	a5,-1
    8000485e:	893e                	mv	s2,a5
    80004860:	b75d                	j	80004806 <fileread+0x5e>
      return -1;
    80004862:	57fd                	li	a5,-1
    80004864:	893e                	mv	s2,a5
    80004866:	64e2                	ld	s1,24(sp)
    80004868:	69a2                	ld	s3,8(sp)
    8000486a:	bf71                	j	80004806 <fileread+0x5e>
    8000486c:	57fd                	li	a5,-1
    8000486e:	893e                	mv	s2,a5
    80004870:	64e2                	ld	s1,24(sp)
    80004872:	69a2                	ld	s3,8(sp)
    80004874:	bf49                	j	80004806 <fileread+0x5e>

0000000080004876 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    80004876:	00954783          	lbu	a5,9(a0)
    8000487a:	12078b63          	beqz	a5,800049b0 <filewrite+0x13a>
{
    8000487e:	711d                	addi	sp,sp,-96
    80004880:	ec86                	sd	ra,88(sp)
    80004882:	e8a2                	sd	s0,80(sp)
    80004884:	e0ca                	sd	s2,64(sp)
    80004886:	f456                	sd	s5,40(sp)
    80004888:	f05a                	sd	s6,32(sp)
    8000488a:	1080                	addi	s0,sp,96
    8000488c:	892a                	mv	s2,a0
    8000488e:	8b2e                	mv	s6,a1
    80004890:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    80004892:	01f6579b          	srliw	a5,a2,0x1f
    80004896:	0e079d63          	bnez	a5,80004990 <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    8000489a:	411c                	lw	a5,0(a0)
    8000489c:	4705                	li	a4,1
    8000489e:	02e78a63          	beq	a5,a4,800048d2 <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800048a2:	470d                	li	a4,3
    800048a4:	02e78b63          	beq	a5,a4,800048da <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    800048a8:	4709                	li	a4,2
    800048aa:	0ce79763          	bne	a5,a4,80004978 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    800048ae:	0ec05763          	blez	a2,8000499c <filewrite+0x126>
    800048b2:	e4a6                	sd	s1,72(sp)
    800048b4:	fc4e                	sd	s3,56(sp)
    800048b6:	f852                	sd	s4,48(sp)
    800048b8:	ec5e                	sd	s7,24(sp)
    800048ba:	e862                	sd	s8,16(sp)
    800048bc:	e466                	sd	s9,8(sp)
    int i = 0;
    800048be:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    800048c0:	6b85                	lui	s7,0x1
    800048c2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800048c6:	6785                	lui	a5,0x1
    800048c8:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800048cc:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800048ce:	4c05                	li	s8,1
    800048d0:	a8ad                	j	8000494a <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    800048d2:	6908                	ld	a0,16(a0)
    800048d4:	206000ef          	jal	80004ada <pipewrite>
    800048d8:	a849                	j	8000496a <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800048da:	02451783          	lh	a5,36(a0)
    800048de:	03079693          	slli	a3,a5,0x30
    800048e2:	92c1                	srli	a3,a3,0x30
    800048e4:	4725                	li	a4,9
    800048e6:	0ad76763          	bltu	a4,a3,80004994 <filewrite+0x11e>
    800048ea:	0792                	slli	a5,a5,0x4
    800048ec:	0001f717          	auipc	a4,0x1f
    800048f0:	1e470713          	addi	a4,a4,484 # 80023ad0 <devsw>
    800048f4:	97ba                	add	a5,a5,a4
    800048f6:	679c                	ld	a5,8(a5)
    800048f8:	c3c5                	beqz	a5,80004998 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800048fa:	4505                	li	a0,1
    800048fc:	9782                	jalr	a5
    800048fe:	a0b5                	j	8000496a <filewrite+0xf4>
      if (n1 > max)
    80004900:	2981                	sext.w	s3,s3
      begin_op();
    80004902:	8bbff0ef          	jal	800041bc <begin_op>
      ilock(f->ip);
    80004906:	01893503          	ld	a0,24(s2)
    8000490a:	e3bfe0ef          	jal	80003744 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000490e:	874e                	mv	a4,s3
    80004910:	02092683          	lw	a3,32(s2)
    80004914:	016a0633          	add	a2,s4,s6
    80004918:	85e2                	mv	a1,s8
    8000491a:	01893503          	ld	a0,24(s2)
    8000491e:	af2ff0ef          	jal	80003c10 <writei>
    80004922:	84aa                	mv	s1,a0
    80004924:	00a05763          	blez	a0,80004932 <filewrite+0xbc>
        f->off += r;
    80004928:	02092783          	lw	a5,32(s2)
    8000492c:	9fa9                	addw	a5,a5,a0
    8000492e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004932:	01893503          	ld	a0,24(s2)
    80004936:	ebdfe0ef          	jal	800037f2 <iunlock>
      end_op();
    8000493a:	90fff0ef          	jal	80004248 <end_op>

      if (r != n1) {
    8000493e:	00999d63          	bne	s3,s1,80004958 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    80004942:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    80004946:	015a5963          	bge	s4,s5,80004958 <filewrite+0xe2>
      int n1 = n - i;
    8000494a:	414a87bb          	subw	a5,s5,s4
    8000494e:	89be                	mv	s3,a5
      if (n1 > max)
    80004950:	fafbd8e3          	bge	s7,a5,80004900 <filewrite+0x8a>
    80004954:	89e6                	mv	s3,s9
    80004956:	b76d                	j	80004900 <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    80004958:	054a9463          	bne	s5,s4,800049a0 <filewrite+0x12a>
    8000495c:	8556                	mv	a0,s5
    8000495e:	64a6                	ld	s1,72(sp)
    80004960:	79e2                	ld	s3,56(sp)
    80004962:	7a42                	ld	s4,48(sp)
    80004964:	6be2                	ld	s7,24(sp)
    80004966:	6c42                	ld	s8,16(sp)
    80004968:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000496a:	60e6                	ld	ra,88(sp)
    8000496c:	6446                	ld	s0,80(sp)
    8000496e:	6906                	ld	s2,64(sp)
    80004970:	7aa2                	ld	s5,40(sp)
    80004972:	7b02                	ld	s6,32(sp)
    80004974:	6125                	addi	sp,sp,96
    80004976:	8082                	ret
    80004978:	e4a6                	sd	s1,72(sp)
    8000497a:	fc4e                	sd	s3,56(sp)
    8000497c:	f852                	sd	s4,48(sp)
    8000497e:	ec5e                	sd	s7,24(sp)
    80004980:	e862                	sd	s8,16(sp)
    80004982:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004984:	00004517          	auipc	a0,0x4
    80004988:	c2c50513          	addi	a0,a0,-980 # 800085b0 <etext+0x5b0>
    8000498c:	ea9fb0ef          	jal	80000834 <panic>
    return -1;
    80004990:	557d                	li	a0,-1
    80004992:	bfe1                	j	8000496a <filewrite+0xf4>
      return -1;
    80004994:	557d                	li	a0,-1
    80004996:	bfd1                	j	8000496a <filewrite+0xf4>
    80004998:	557d                	li	a0,-1
    8000499a:	bfc1                	j	8000496a <filewrite+0xf4>
    ret = (i == n ? n : -1);
    8000499c:	8532                	mv	a0,a2
    8000499e:	b7f1                	j	8000496a <filewrite+0xf4>
    800049a0:	557d                	li	a0,-1
    800049a2:	64a6                	ld	s1,72(sp)
    800049a4:	79e2                	ld	s3,56(sp)
    800049a6:	7a42                	ld	s4,48(sp)
    800049a8:	6be2                	ld	s7,24(sp)
    800049aa:	6c42                	ld	s8,16(sp)
    800049ac:	6ca2                	ld	s9,8(sp)
    800049ae:	bf75                	j	8000496a <filewrite+0xf4>
    return -1;
    800049b0:	557d                	li	a0,-1
}
    800049b2:	8082                	ret

00000000800049b4 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800049b4:	7179                	addi	sp,sp,-48
    800049b6:	f406                	sd	ra,40(sp)
    800049b8:	f022                	sd	s0,32(sp)
    800049ba:	ec26                	sd	s1,24(sp)
    800049bc:	e052                	sd	s4,0(sp)
    800049be:	1800                	addi	s0,sp,48
    800049c0:	84aa                	mv	s1,a0
    800049c2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800049c4:	0005b023          	sd	zero,0(a1)
    800049c8:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800049cc:	c07ff0ef          	jal	800045d2 <filealloc>
    800049d0:	e088                	sd	a0,0(s1)
    800049d2:	c549                	beqz	a0,80004a5c <pipealloc+0xa8>
    800049d4:	bffff0ef          	jal	800045d2 <filealloc>
    800049d8:	00aa3023          	sd	a0,0(s4)
    800049dc:	cd25                	beqz	a0,80004a54 <pipealloc+0xa0>
    800049de:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    800049e0:	96efc0ef          	jal	80000b4e <kalloc>
    800049e4:	892a                	mv	s2,a0
    800049e6:	c12d                	beqz	a0,80004a48 <pipealloc+0x94>
    800049e8:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800049ea:	4985                	li	s3,1
    800049ec:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800049f0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800049f4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800049f8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800049fc:	00004597          	auipc	a1,0x4
    80004a00:	bc458593          	addi	a1,a1,-1084 # 800085c0 <etext+0x5c0>
    80004a04:	9a4fc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004a08:	609c                	ld	a5,0(s1)
    80004a0a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a0e:	609c                	ld	a5,0(s1)
    80004a10:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a14:	609c                	ld	a5,0(s1)
    80004a16:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a1a:	609c                	ld	a5,0(s1)
    80004a1c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a20:	000a3783          	ld	a5,0(s4)
    80004a24:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a28:	000a3783          	ld	a5,0(s4)
    80004a2c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a30:	000a3783          	ld	a5,0(s4)
    80004a34:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a38:	000a3783          	ld	a5,0(s4)
    80004a3c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a40:	4501                	li	a0,0
    80004a42:	6942                	ld	s2,16(sp)
    80004a44:	69a2                	ld	s3,8(sp)
    80004a46:	a01d                	j	80004a6c <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004a48:	6088                	ld	a0,0(s1)
    80004a4a:	c119                	beqz	a0,80004a50 <pipealloc+0x9c>
    80004a4c:	6942                	ld	s2,16(sp)
    80004a4e:	a029                	j	80004a58 <pipealloc+0xa4>
    80004a50:	6942                	ld	s2,16(sp)
    80004a52:	a029                	j	80004a5c <pipealloc+0xa8>
    80004a54:	6088                	ld	a0,0(s1)
    80004a56:	c10d                	beqz	a0,80004a78 <pipealloc+0xc4>
    fileclose(*f0);
    80004a58:	c1fff0ef          	jal	80004676 <fileclose>
  if (*f1)
    80004a5c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a60:	557d                	li	a0,-1
  if (*f1)
    80004a62:	c789                	beqz	a5,80004a6c <pipealloc+0xb8>
    fileclose(*f1);
    80004a64:	853e                	mv	a0,a5
    80004a66:	c11ff0ef          	jal	80004676 <fileclose>
  return -1;
    80004a6a:	557d                	li	a0,-1
}
    80004a6c:	70a2                	ld	ra,40(sp)
    80004a6e:	7402                	ld	s0,32(sp)
    80004a70:	64e2                	ld	s1,24(sp)
    80004a72:	6a02                	ld	s4,0(sp)
    80004a74:	6145                	addi	sp,sp,48
    80004a76:	8082                	ret
  return -1;
    80004a78:	557d                	li	a0,-1
    80004a7a:	bfcd                	j	80004a6c <pipealloc+0xb8>

0000000080004a7c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a7c:	1101                	addi	sp,sp,-32
    80004a7e:	ec06                	sd	ra,24(sp)
    80004a80:	e822                	sd	s0,16(sp)
    80004a82:	e426                	sd	s1,8(sp)
    80004a84:	e04a                	sd	s2,0(sp)
    80004a86:	1000                	addi	s0,sp,32
    80004a88:	84aa                	mv	s1,a0
    80004a8a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a8c:	99cfc0ef          	jal	80000c28 <acquire>
  if (writable) {
    80004a90:	02090763          	beqz	s2,80004abe <pipeclose+0x42>
    pi->writeopen = 0;
    80004a94:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a98:	21848513          	addi	a0,s1,536
    80004a9c:	f0cfd0ef          	jal	800021a8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004aa0:	2204a783          	lw	a5,544(s1)
    80004aa4:	e781                	bnez	a5,80004aac <pipeclose+0x30>
    80004aa6:	2244a783          	lw	a5,548(s1)
    80004aaa:	c38d                	beqz	a5,80004acc <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    80004aac:	8526                	mv	a0,s1
    80004aae:	a02fc0ef          	jal	80000cb0 <release>
}
    80004ab2:	60e2                	ld	ra,24(sp)
    80004ab4:	6442                	ld	s0,16(sp)
    80004ab6:	64a2                	ld	s1,8(sp)
    80004ab8:	6902                	ld	s2,0(sp)
    80004aba:	6105                	addi	sp,sp,32
    80004abc:	8082                	ret
    pi->readopen = 0;
    80004abe:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ac2:	21c48513          	addi	a0,s1,540
    80004ac6:	ee2fd0ef          	jal	800021a8 <wakeup>
    80004aca:	bfd9                	j	80004aa0 <pipeclose+0x24>
    release(&pi->lock);
    80004acc:	8526                	mv	a0,s1
    80004ace:	9e2fc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    80004ad2:	8526                	mv	a0,s1
    80004ad4:	f93fb0ef          	jal	80000a66 <kfree>
    80004ad8:	bfe9                	j	80004ab2 <pipeclose+0x36>

0000000080004ada <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ada:	7159                	addi	sp,sp,-112
    80004adc:	f486                	sd	ra,104(sp)
    80004ade:	f0a2                	sd	s0,96(sp)
    80004ae0:	eca6                	sd	s1,88(sp)
    80004ae2:	e8ca                	sd	s2,80(sp)
    80004ae4:	e4ce                	sd	s3,72(sp)
    80004ae6:	e0d2                	sd	s4,64(sp)
    80004ae8:	fc56                	sd	s5,56(sp)
    80004aea:	1880                	addi	s0,sp,112
    80004aec:	84aa                	mv	s1,a0
    80004aee:	8aae                	mv	s5,a1
    80004af0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004af2:	e5bfc0ef          	jal	8000194c <myproc>
    80004af6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004af8:	8526                	mv	a0,s1
    80004afa:	92efc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    80004afe:	0f405a63          	blez	s4,80004bf2 <pipewrite+0x118>
    80004b02:	f85a                	sd	s6,48(sp)
    80004b04:	f45e                	sd	s7,40(sp)
    80004b06:	f062                	sd	s8,32(sp)
    80004b08:	ec66                	sd	s9,24(sp)
    80004b0a:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004b0c:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004b0e:	f9f40c13          	addi	s8,s0,-97
    80004b12:	4b85                	li	s7,1
    80004b14:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004b16:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    80004b1a:	21c48c93          	addi	s9,s1,540
    80004b1e:	a0a1                	j	80004b66 <pipewrite+0x8c>
      release(&pi->lock);
    80004b20:	8526                	mv	a0,s1
    80004b22:	98efc0ef          	jal	80000cb0 <release>
      return -1;
    80004b26:	597d                	li	s2,-1
    80004b28:	7b42                	ld	s6,48(sp)
    80004b2a:	7ba2                	ld	s7,40(sp)
    80004b2c:	7c02                	ld	s8,32(sp)
    80004b2e:	6ce2                	ld	s9,24(sp)
    80004b30:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004b32:	854a                	mv	a0,s2
    80004b34:	70a6                	ld	ra,104(sp)
    80004b36:	7406                	ld	s0,96(sp)
    80004b38:	64e6                	ld	s1,88(sp)
    80004b3a:	6946                	ld	s2,80(sp)
    80004b3c:	69a6                	ld	s3,72(sp)
    80004b3e:	6a06                	ld	s4,64(sp)
    80004b40:	7ae2                	ld	s5,56(sp)
    80004b42:	6165                	addi	sp,sp,112
    80004b44:	8082                	ret
      wakeup(&pi->nread);
    80004b46:	856a                	mv	a0,s10
    80004b48:	e60fd0ef          	jal	800021a8 <wakeup>
      sleep_prepare(&pi->nwrite);
    80004b4c:	8566                	mv	a0,s9
    80004b4e:	deefd0ef          	jal	8000213c <sleep_prepare>
      release(&pi->lock);
    80004b52:	8526                	mv	a0,s1
    80004b54:	95cfc0ef          	jal	80000cb0 <release>
      sleep();
    80004b58:	e20fd0ef          	jal	80002178 <sleep>
      acquire(&pi->lock);
    80004b5c:	8526                	mv	a0,s1
    80004b5e:	8cafc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    80004b62:	07495b63          	bge	s2,s4,80004bd8 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    80004b66:	2204a783          	lw	a5,544(s1)
    80004b6a:	dbdd                	beqz	a5,80004b20 <pipewrite+0x46>
    80004b6c:	854e                	mv	a0,s3
    80004b6e:	82dfd0ef          	jal	8000239a <killed>
    80004b72:	f55d                	bnez	a0,80004b20 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    80004b74:	2184a783          	lw	a5,536(s1)
    80004b78:	21c4a703          	lw	a4,540(s1)
    80004b7c:	2007879b          	addiw	a5,a5,512
    80004b80:	fcf703e3          	beq	a4,a5,80004b46 <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004b84:	875e                	mv	a4,s7
    80004b86:	015906b3          	add	a3,s2,s5
    80004b8a:	8662                	mv	a2,s8
    80004b8c:	0489b583          	ld	a1,72(s3)
    80004b90:	0509b503          	ld	a0,80(s3)
    80004b94:	ab9fc0ef          	jal	8000164c <copyin>
    80004b98:	03650163          	beq	a0,s6,80004bba <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b9c:	21c4a783          	lw	a5,540(s1)
    80004ba0:	0017871b          	addiw	a4,a5,1
    80004ba4:	20e4ae23          	sw	a4,540(s1)
    80004ba8:	1ff7f793          	andi	a5,a5,511
    80004bac:	97a6                	add	a5,a5,s1
    80004bae:	f9f44703          	lbu	a4,-97(s0)
    80004bb2:	00e78c23          	sb	a4,24(a5)
      i++;
    80004bb6:	2905                	addiw	s2,s2,1
    80004bb8:	b76d                	j	80004b62 <pipewrite+0x88>
        if (i == 0)
    80004bba:	00090863          	beqz	s2,80004bca <pipewrite+0xf0>
    80004bbe:	7b42                	ld	s6,48(sp)
    80004bc0:	7ba2                	ld	s7,40(sp)
    80004bc2:	7c02                	ld	s8,32(sp)
    80004bc4:	6ce2                	ld	s9,24(sp)
    80004bc6:	6d42                	ld	s10,16(sp)
    80004bc8:	a829                	j	80004be2 <pipewrite+0x108>
          i = -1;
    80004bca:	892a                	mv	s2,a0
        break;
    80004bcc:	7b42                	ld	s6,48(sp)
    80004bce:	7ba2                	ld	s7,40(sp)
    80004bd0:	7c02                	ld	s8,32(sp)
    80004bd2:	6ce2                	ld	s9,24(sp)
    80004bd4:	6d42                	ld	s10,16(sp)
    80004bd6:	a031                	j	80004be2 <pipewrite+0x108>
    80004bd8:	7b42                	ld	s6,48(sp)
    80004bda:	7ba2                	ld	s7,40(sp)
    80004bdc:	7c02                	ld	s8,32(sp)
    80004bde:	6ce2                	ld	s9,24(sp)
    80004be0:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004be2:	21848513          	addi	a0,s1,536
    80004be6:	dc2fd0ef          	jal	800021a8 <wakeup>
  release(&pi->lock);
    80004bea:	8526                	mv	a0,s1
    80004bec:	8c4fc0ef          	jal	80000cb0 <release>
  return i;
    80004bf0:	b789                	j	80004b32 <pipewrite+0x58>
  int i = 0;
    80004bf2:	4901                	li	s2,0
    80004bf4:	b7fd                	j	80004be2 <pipewrite+0x108>

0000000080004bf6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004bf6:	711d                	addi	sp,sp,-96
    80004bf8:	ec86                	sd	ra,88(sp)
    80004bfa:	e8a2                	sd	s0,80(sp)
    80004bfc:	e4a6                	sd	s1,72(sp)
    80004bfe:	e0ca                	sd	s2,64(sp)
    80004c00:	fc4e                	sd	s3,56(sp)
    80004c02:	f852                	sd	s4,48(sp)
    80004c04:	f456                	sd	s5,40(sp)
    80004c06:	1080                	addi	s0,sp,96
    80004c08:	84aa                	mv	s1,a0
    80004c0a:	89ae                	mv	s3,a1
    80004c0c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c0e:	d3ffc0ef          	jal	8000194c <myproc>
    80004c12:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    80004c14:	8526                	mv	a0,s1
    80004c16:	812fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004c1a:	0d505263          	blez	s5,80004cde <piperead+0xe8>
    80004c1e:	2184a703          	lw	a4,536(s1)
    80004c22:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004c26:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004c2a:	02f71e63          	bne	a4,a5,80004c66 <piperead+0x70>
    80004c2e:	2244a783          	lw	a5,548(s1)
    80004c32:	c3b9                	beqz	a5,80004c78 <piperead+0x82>
    if (killed(pr)) {
    80004c34:	854a                	mv	a0,s2
    80004c36:	f64fd0ef          	jal	8000239a <killed>
    80004c3a:	e915                	bnez	a0,80004c6e <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004c3c:	8552                	mv	a0,s4
    80004c3e:	cfefd0ef          	jal	8000213c <sleep_prepare>
    release(&pi->lock);
    80004c42:	8526                	mv	a0,s1
    80004c44:	86cfc0ef          	jal	80000cb0 <release>
    sleep();
    80004c48:	d30fd0ef          	jal	80002178 <sleep>
    acquire(&pi->lock);
    80004c4c:	8526                	mv	a0,s1
    80004c4e:	fdbfb0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004c52:	2184a703          	lw	a4,536(s1)
    80004c56:	21c4a783          	lw	a5,540(s1)
    80004c5a:	fcf70ae3          	beq	a4,a5,80004c2e <piperead+0x38>
    80004c5e:	f05a                	sd	s6,32(sp)
    80004c60:	ec5e                	sd	s7,24(sp)
    80004c62:	e862                	sd	s8,16(sp)
    80004c64:	a829                	j	80004c7e <piperead+0x88>
    80004c66:	f05a                	sd	s6,32(sp)
    80004c68:	ec5e                	sd	s7,24(sp)
    80004c6a:	e862                	sd	s8,16(sp)
    80004c6c:	a809                	j	80004c7e <piperead+0x88>
      release(&pi->lock);
    80004c6e:	8526                	mv	a0,s1
    80004c70:	840fc0ef          	jal	80000cb0 <release>
      return -1;
    80004c74:	5a7d                	li	s4,-1
    80004c76:	a8a5                	j	80004cee <piperead+0xf8>
    80004c78:	f05a                	sd	s6,32(sp)
    80004c7a:	ec5e                	sd	s7,24(sp)
    80004c7c:	e862                	sd	s8,16(sp)
{
    80004c7e:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004c80:	faf40c13          	addi	s8,s0,-81
    80004c84:	4b85                	li	s7,1
    80004c86:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    80004c88:	2184a783          	lw	a5,536(s1)
    80004c8c:	21c4a703          	lw	a4,540(s1)
    80004c90:	06f70e63          	beq	a4,a5,80004d0c <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    80004c94:	1ff7f793          	andi	a5,a5,511
    80004c98:	97a6                	add	a5,a5,s1
    80004c9a:	0187c783          	lbu	a5,24(a5)
    80004c9e:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004ca2:	875e                	mv	a4,s7
    80004ca4:	86e2                	mv	a3,s8
    80004ca6:	864e                	mv	a2,s3
    80004ca8:	04893583          	ld	a1,72(s2)
    80004cac:	05093503          	ld	a0,80(s2)
    80004cb0:	8d7fc0ef          	jal	80001586 <copyout>
    80004cb4:	01650f63          	beq	a0,s6,80004cd2 <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004cb8:	2184a783          	lw	a5,536(s1)
    80004cbc:	2785                	addiw	a5,a5,1
    80004cbe:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004cc2:	2a05                	addiw	s4,s4,1
    80004cc4:	0985                	addi	s3,s3,1
    80004cc6:	fd4a91e3          	bne	s5,s4,80004c88 <piperead+0x92>
    80004cca:	7b02                	ld	s6,32(sp)
    80004ccc:	6be2                	ld	s7,24(sp)
    80004cce:	6c42                	ld	s8,16(sp)
    80004cd0:	a801                	j	80004ce0 <piperead+0xea>
      if (i == 0)
    80004cd2:	020a0863          	beqz	s4,80004d02 <piperead+0x10c>
    80004cd6:	7b02                	ld	s6,32(sp)
    80004cd8:	6be2                	ld	s7,24(sp)
    80004cda:	6c42                	ld	s8,16(sp)
    80004cdc:	a011                	j	80004ce0 <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004cde:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004ce0:	21c48513          	addi	a0,s1,540
    80004ce4:	cc4fd0ef          	jal	800021a8 <wakeup>
  release(&pi->lock);
    80004ce8:	8526                	mv	a0,s1
    80004cea:	fc7fb0ef          	jal	80000cb0 <release>
  return i;
}
    80004cee:	8552                	mv	a0,s4
    80004cf0:	60e6                	ld	ra,88(sp)
    80004cf2:	6446                	ld	s0,80(sp)
    80004cf4:	64a6                	ld	s1,72(sp)
    80004cf6:	6906                	ld	s2,64(sp)
    80004cf8:	79e2                	ld	s3,56(sp)
    80004cfa:	7a42                	ld	s4,48(sp)
    80004cfc:	7aa2                	ld	s5,40(sp)
    80004cfe:	6125                	addi	sp,sp,96
    80004d00:	8082                	ret
        i = -1;
    80004d02:	8a2a                	mv	s4,a0
    80004d04:	7b02                	ld	s6,32(sp)
    80004d06:	6be2                	ld	s7,24(sp)
    80004d08:	6c42                	ld	s8,16(sp)
    80004d0a:	bfd9                	j	80004ce0 <piperead+0xea>
    80004d0c:	7b02                	ld	s6,32(sp)
    80004d0e:	6be2                	ld	s7,24(sp)
    80004d10:	6c42                	ld	s8,16(sp)
    80004d12:	b7f9                	j	80004ce0 <piperead+0xea>

0000000080004d14 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004d14:	1141                	addi	sp,sp,-16
    80004d16:	e406                	sd	ra,8(sp)
    80004d18:	e022                	sd	s0,0(sp)
    80004d1a:	0800                	addi	s0,sp,16
    80004d1c:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004d1e:	0035151b          	slliw	a0,a0,0x3
    80004d22:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    80004d24:	8b89                	andi	a5,a5,2
    80004d26:	c399                	beqz	a5,80004d2c <flags2perm+0x18>
    perm |= PTE_W;
    80004d28:	00456513          	ori	a0,a0,4
  return perm;
}
    80004d2c:	60a2                	ld	ra,8(sp)
    80004d2e:	6402                	ld	s0,0(sp)
    80004d30:	0141                	addi	sp,sp,16
    80004d32:	8082                	ret

0000000080004d34 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004d34:	de010113          	addi	sp,sp,-544
    80004d38:	20113c23          	sd	ra,536(sp)
    80004d3c:	20813823          	sd	s0,528(sp)
    80004d40:	20913423          	sd	s1,520(sp)
    80004d44:	21213023          	sd	s2,512(sp)
    80004d48:	1400                	addi	s0,sp,544
    80004d4a:	892a                	mv	s2,a0
    80004d4c:	dea43823          	sd	a0,-528(s0)
    80004d50:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d54:	bf9fc0ef          	jal	8000194c <myproc>
    80004d58:	84aa                	mv	s1,a0

  begin_op();
    80004d5a:	c62ff0ef          	jal	800041bc <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004d5e:	854a                	mv	a0,s2
    80004d60:	a7eff0ef          	jal	80003fde <namei>
    80004d64:	cd21                	beqz	a0,80004dbc <kexec+0x88>
    80004d66:	fbd2                	sd	s4,496(sp)
    80004d68:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004d6a:	9dbfe0ef          	jal	80003744 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d6e:	04000713          	li	a4,64
    80004d72:	4681                	li	a3,0
    80004d74:	e5040613          	addi	a2,s0,-432
    80004d78:	4581                	li	a1,0
    80004d7a:	8552                	mv	a0,s4
    80004d7c:	da3fe0ef          	jal	80003b1e <readi>
    80004d80:	04000793          	li	a5,64
    80004d84:	00f51a63          	bne	a0,a5,80004d98 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004d88:	e5042703          	lw	a4,-432(s0)
    80004d8c:	464c47b7          	lui	a5,0x464c4
    80004d90:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d94:	02f70863          	beq	a4,a5,80004dc4 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004d98:	8552                	mv	a0,s4
    80004d9a:	bfffe0ef          	jal	80003998 <iunlockput>
    end_op();
    80004d9e:	caaff0ef          	jal	80004248 <end_op>
  }
  return -1;
    80004da2:	557d                	li	a0,-1
    80004da4:	7a5e                	ld	s4,496(sp)
}
    80004da6:	21813083          	ld	ra,536(sp)
    80004daa:	21013403          	ld	s0,528(sp)
    80004dae:	20813483          	ld	s1,520(sp)
    80004db2:	20013903          	ld	s2,512(sp)
    80004db6:	22010113          	addi	sp,sp,544
    80004dba:	8082                	ret
    end_op();
    80004dbc:	c8cff0ef          	jal	80004248 <end_op>
    return -1;
    80004dc0:	557d                	li	a0,-1
    80004dc2:	b7d5                	j	80004da6 <kexec+0x72>
    80004dc4:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004dc6:	8526                	mv	a0,s1
    80004dc8:	c8bfc0ef          	jal	80001a52 <proc_pagetable>
    80004dcc:	8b2a                	mv	s6,a0
    80004dce:	26050e63          	beqz	a0,8000504a <kexec+0x316>
    80004dd2:	ffce                	sd	s3,504(sp)
    80004dd4:	f7d6                	sd	s5,488(sp)
    80004dd6:	efde                	sd	s7,472(sp)
    80004dd8:	ebe2                	sd	s8,464(sp)
    80004dda:	e7e6                	sd	s9,456(sp)
    80004ddc:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004dde:	e8845783          	lhu	a5,-376(s0)
    80004de2:	14078263          	beqz	a5,80004f26 <kexec+0x1f2>
    80004de6:	ff6e                	sd	s11,440(sp)
    80004de8:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004dec:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004dee:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004df0:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004df4:	6c85                	lui	s9,0x1
    80004df6:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004dfa:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004dfe:	6a85                	lui	s5,0x1
    80004e00:	a085                	j	80004e60 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004e02:	00003517          	auipc	a0,0x3
    80004e06:	7c650513          	addi	a0,a0,1990 # 800085c8 <etext+0x5c8>
    80004e0a:	a2bfb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004e0e:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004e10:	874a                	mv	a4,s2
    80004e12:	009b86bb          	addw	a3,s7,s1
    80004e16:	4581                	li	a1,0
    80004e18:	8552                	mv	a0,s4
    80004e1a:	d05fe0ef          	jal	80003b1e <readi>
    80004e1e:	22a91a63          	bne	s2,a0,80005052 <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004e22:	009a84bb          	addw	s1,s5,s1
    80004e26:	0334f263          	bgeu	s1,s3,80004e4a <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004e2a:	02049593          	slli	a1,s1,0x20
    80004e2e:	9181                	srli	a1,a1,0x20
    80004e30:	95e2                	add	a1,a1,s8
    80004e32:	855a                	mv	a0,s6
    80004e34:	9e8fc0ef          	jal	8000101c <walkaddr>
    80004e38:	862a                	mv	a2,a0
    if (pa == 0)
    80004e3a:	d561                	beqz	a0,80004e02 <kexec+0xce>
    if (sz - i < PGSIZE)
    80004e3c:	409987bb          	subw	a5,s3,s1
    80004e40:	893e                	mv	s2,a5
    80004e42:	fcfcf6e3          	bgeu	s9,a5,80004e0e <kexec+0xda>
    80004e46:	8956                	mv	s2,s5
    80004e48:	b7d9                	j	80004e0e <kexec+0xda>
    sz = sz1;
    80004e4a:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004e4e:	2d05                	addiw	s10,s10,1
    80004e50:	e0843783          	ld	a5,-504(s0)
    80004e54:	0387869b          	addiw	a3,a5,56
    80004e58:	e8845783          	lhu	a5,-376(s0)
    80004e5c:	06fd5d63          	bge	s10,a5,80004ed6 <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e60:	e0d43423          	sd	a3,-504(s0)
    80004e64:	876e                	mv	a4,s11
    80004e66:	e1840613          	addi	a2,s0,-488
    80004e6a:	4581                	li	a1,0
    80004e6c:	8552                	mv	a0,s4
    80004e6e:	cb1fe0ef          	jal	80003b1e <readi>
    80004e72:	1db51e63          	bne	a0,s11,8000504e <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004e76:	e1842783          	lw	a5,-488(s0)
    80004e7a:	4705                	li	a4,1
    80004e7c:	fce799e3          	bne	a5,a4,80004e4e <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004e80:	e4043483          	ld	s1,-448(s0)
    80004e84:	e3843783          	ld	a5,-456(s0)
    80004e88:	1ef4e363          	bltu	s1,a5,8000506e <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004e8c:	e2843783          	ld	a5,-472(s0)
    80004e90:	94be                	add	s1,s1,a5
    80004e92:	1ef4e163          	bltu	s1,a5,80005074 <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004e96:	de843703          	ld	a4,-536(s0)
    80004e9a:	8ff9                	and	a5,a5,a4
    80004e9c:	1c079f63          	bnez	a5,8000507a <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004ea0:	e1c42503          	lw	a0,-484(s0)
    80004ea4:	e71ff0ef          	jal	80004d14 <flags2perm>
    80004ea8:	86aa                	mv	a3,a0
    80004eaa:	8626                	mv	a2,s1
    80004eac:	85ca                	mv	a1,s2
    80004eae:	855a                	mv	a0,s6
    80004eb0:	c42fc0ef          	jal	800012f2 <uvmalloc>
    80004eb4:	dea43c23          	sd	a0,-520(s0)
    80004eb8:	1c050463          	beqz	a0,80005080 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ebc:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004ec0:	00098863          	beqz	s3,80004ed0 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ec4:	e2843c03          	ld	s8,-472(s0)
    80004ec8:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004ecc:	4481                	li	s1,0
    80004ece:	bfb1                	j	80004e2a <kexec+0xf6>
    sz = sz1;
    80004ed0:	df843903          	ld	s2,-520(s0)
    80004ed4:	bfad                	j	80004e4e <kexec+0x11a>
    80004ed6:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004ed8:	8552                	mv	a0,s4
    80004eda:	abffe0ef          	jal	80003998 <iunlockput>
  end_op();
    80004ede:	b6aff0ef          	jal	80004248 <end_op>
  p = myproc();
    80004ee2:	a6bfc0ef          	jal	8000194c <myproc>
    80004ee6:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004ee8:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004eec:	6c05                	lui	s8,0x1
    80004eee:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004ef0:	9c4a                	add	s8,s8,s2
    80004ef2:	77fd                	lui	a5,0xfffff
    80004ef4:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004ef8:	4691                	li	a3,4
    80004efa:	6609                	lui	a2,0x2
    80004efc:	9662                	add	a2,a2,s8
    80004efe:	85e2                	mv	a1,s8
    80004f00:	855a                	mv	a0,s6
    80004f02:	bf0fc0ef          	jal	800012f2 <uvmalloc>
    80004f06:	892a                	mv	s2,a0
    80004f08:	e10d                	bnez	a0,80004f2a <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004f0a:	85e2                	mv	a1,s8
    80004f0c:	855a                	mv	a0,s6
    80004f0e:	bc9fc0ef          	jal	80001ad6 <proc_freepagetable>
  return -1;
    80004f12:	557d                	li	a0,-1
    80004f14:	79fe                	ld	s3,504(sp)
    80004f16:	7a5e                	ld	s4,496(sp)
    80004f18:	7abe                	ld	s5,488(sp)
    80004f1a:	7b1e                	ld	s6,480(sp)
    80004f1c:	6bfe                	ld	s7,472(sp)
    80004f1e:	6c5e                	ld	s8,464(sp)
    80004f20:	6cbe                	ld	s9,456(sp)
    80004f22:	6d1e                	ld	s10,448(sp)
    80004f24:	b549                	j	80004da6 <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f26:	4901                	li	s2,0
    80004f28:	bf45                	j	80004ed8 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004f2a:	75f9                	lui	a1,0xffffe
    80004f2c:	95aa                	add	a1,a1,a0
    80004f2e:	855a                	mv	a0,s6
    80004f30:	d94fc0ef          	jal	800014c4 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004f34:	80090a13          	addi	s4,s2,-2048
    80004f38:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004f3c:	e0043783          	ld	a5,-512(s0)
    80004f40:	6388                	ld	a0,0(a5)
    80004f42:	c545                	beqz	a0,80004fea <kexec+0x2b6>
  sp = sz;
    80004f44:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004f46:	4481                	li	s1,0
    ustack[argc] = sp;
    80004f48:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004f4c:	f27fb0ef          	jal	80000e72 <strlen>
    80004f50:	0015079b          	addiw	a5,a0,1
    80004f54:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f58:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004f5c:	134c6563          	bltu	s8,s4,80005086 <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f60:	e0043d03          	ld	s10,-512(s0)
    80004f64:	000d3c83          	ld	s9,0(s10)
    80004f68:	8566                	mv	a0,s9
    80004f6a:	f09fb0ef          	jal	80000e72 <strlen>
    80004f6e:	0015071b          	addiw	a4,a0,1
    80004f72:	86e6                	mv	a3,s9
    80004f74:	8662                	mv	a2,s8
    80004f76:	85ca                	mv	a1,s2
    80004f78:	855a                	mv	a0,s6
    80004f7a:	e0cfc0ef          	jal	80001586 <copyout>
    80004f7e:	10054663          	bltz	a0,8000508a <kexec+0x356>
    ustack[argc] = sp;
    80004f82:	00349793          	slli	a5,s1,0x3
    80004f86:	97de                	add	a5,a5,s7
    80004f88:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffda398>
  for (argc = 0; argv[argc]; argc++) {
    80004f8c:	0485                	addi	s1,s1,1
    80004f8e:	008d0793          	addi	a5,s10,8
    80004f92:	e0f43023          	sd	a5,-512(s0)
    80004f96:	008d3503          	ld	a0,8(s10)
    80004f9a:	f94d                	bnez	a0,80004f4c <kexec+0x218>
  ustack[argc] = 0;
    80004f9c:	00349793          	slli	a5,s1,0x3
    80004fa0:	f9078793          	addi	a5,a5,-112
    80004fa4:	97a2                	add	a5,a5,s0
    80004fa6:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004faa:	00349713          	slli	a4,s1,0x3
    80004fae:	0721                	addi	a4,a4,8
    80004fb0:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004fb4:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004fb8:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004fba:	f54be8e3          	bltu	s7,s4,80004f0a <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004fbe:	e9040693          	addi	a3,s0,-368
    80004fc2:	865e                	mv	a2,s7
    80004fc4:	85ca                	mv	a1,s2
    80004fc6:	855a                	mv	a0,s6
    80004fc8:	dbefc0ef          	jal	80001586 <copyout>
    80004fcc:	f2054fe3          	bltz	a0,80004f0a <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004fd0:	0589b783          	ld	a5,88(s3)
    80004fd4:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004fd8:	df043783          	ld	a5,-528(s0)
    80004fdc:	0007c703          	lbu	a4,0(a5)
    80004fe0:	c30d                	beqz	a4,80005002 <kexec+0x2ce>
    80004fe2:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004fe4:	02f00693          	li	a3,47
    80004fe8:	a801                	j	80004ff8 <kexec+0x2c4>
  sp = sz;
    80004fea:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004fec:	4481                	li	s1,0
    80004fee:	b77d                	j	80004f9c <kexec+0x268>
  for (last = s = path; *s; s++)
    80004ff0:	0785                	addi	a5,a5,1
    80004ff2:	fff7c703          	lbu	a4,-1(a5)
    80004ff6:	c711                	beqz	a4,80005002 <kexec+0x2ce>
    if (*s == '/')
    80004ff8:	fed71ce3          	bne	a4,a3,80004ff0 <kexec+0x2bc>
      last = s + 1;
    80004ffc:	def43823          	sd	a5,-528(s0)
    80005000:	bfc5                	j	80004ff0 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80005002:	4641                	li	a2,16
    80005004:	df043583          	ld	a1,-528(s0)
    80005008:	15898513          	addi	a0,s3,344
    8000500c:	e31fb0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80005010:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80005014:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80005018:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    8000501c:	0589b783          	ld	a5,88(s3)
    80005020:	e6843703          	ld	a4,-408(s0)
    80005024:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80005026:	0589b783          	ld	a5,88(s3)
    8000502a:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000502e:	85d6                	mv	a1,s5
    80005030:	aa7fc0ef          	jal	80001ad6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005034:	0004851b          	sext.w	a0,s1
    80005038:	79fe                	ld	s3,504(sp)
    8000503a:	7a5e                	ld	s4,496(sp)
    8000503c:	7abe                	ld	s5,488(sp)
    8000503e:	7b1e                	ld	s6,480(sp)
    80005040:	6bfe                	ld	s7,472(sp)
    80005042:	6c5e                	ld	s8,464(sp)
    80005044:	6cbe                	ld	s9,456(sp)
    80005046:	6d1e                	ld	s10,448(sp)
    80005048:	bbb9                	j	80004da6 <kexec+0x72>
    8000504a:	7b1e                	ld	s6,480(sp)
    8000504c:	b3b1                	j	80004d98 <kexec+0x64>
    8000504e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005052:	df843583          	ld	a1,-520(s0)
    80005056:	855a                	mv	a0,s6
    80005058:	a7ffc0ef          	jal	80001ad6 <proc_freepagetable>
  if (ip) {
    8000505c:	79fe                	ld	s3,504(sp)
    8000505e:	7abe                	ld	s5,488(sp)
    80005060:	7b1e                	ld	s6,480(sp)
    80005062:	6bfe                	ld	s7,472(sp)
    80005064:	6c5e                	ld	s8,464(sp)
    80005066:	6cbe                	ld	s9,456(sp)
    80005068:	6d1e                	ld	s10,448(sp)
    8000506a:	7dfa                	ld	s11,440(sp)
    8000506c:	b335                	j	80004d98 <kexec+0x64>
    8000506e:	df243c23          	sd	s2,-520(s0)
    80005072:	b7c5                	j	80005052 <kexec+0x31e>
    80005074:	df243c23          	sd	s2,-520(s0)
    80005078:	bfe9                	j	80005052 <kexec+0x31e>
    8000507a:	df243c23          	sd	s2,-520(s0)
    8000507e:	bfd1                	j	80005052 <kexec+0x31e>
    80005080:	df243c23          	sd	s2,-520(s0)
    80005084:	b7f9                	j	80005052 <kexec+0x31e>
  sz = sz1;
    80005086:	8c4a                	mv	s8,s2
    80005088:	b549                	j	80004f0a <kexec+0x1d6>
    8000508a:	8c4a                	mv	s8,s2
    8000508c:	bdbd                	j	80004f0a <kexec+0x1d6>

000000008000508e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000508e:	7179                	addi	sp,sp,-48
    80005090:	f406                	sd	ra,40(sp)
    80005092:	f022                	sd	s0,32(sp)
    80005094:	ec26                	sd	s1,24(sp)
    80005096:	e84a                	sd	s2,16(sp)
    80005098:	1800                	addi	s0,sp,48
    8000509a:	892e                	mv	s2,a1
    8000509c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000509e:	fdc40593          	addi	a1,s0,-36
    800050a2:	ab3fd0ef          	jal	80002b54 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    800050a6:	fdc42703          	lw	a4,-36(s0)
    800050aa:	47bd                	li	a5,15
    800050ac:	02e7ea63          	bltu	a5,a4,800050e0 <argfd+0x52>
    800050b0:	89dfc0ef          	jal	8000194c <myproc>
    800050b4:	fdc42703          	lw	a4,-36(s0)
    800050b8:	00371793          	slli	a5,a4,0x3
    800050bc:	0d078793          	addi	a5,a5,208
    800050c0:	953e                	add	a0,a0,a5
    800050c2:	611c                	ld	a5,0(a0)
    800050c4:	c385                	beqz	a5,800050e4 <argfd+0x56>
    return -1;
  if (pfd)
    800050c6:	00090463          	beqz	s2,800050ce <argfd+0x40>
    *pfd = fd;
    800050ca:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    800050ce:	4501                	li	a0,0
  if (pf)
    800050d0:	c091                	beqz	s1,800050d4 <argfd+0x46>
    *pf = f;
    800050d2:	e09c                	sd	a5,0(s1)
}
    800050d4:	70a2                	ld	ra,40(sp)
    800050d6:	7402                	ld	s0,32(sp)
    800050d8:	64e2                	ld	s1,24(sp)
    800050da:	6942                	ld	s2,16(sp)
    800050dc:	6145                	addi	sp,sp,48
    800050de:	8082                	ret
    return -1;
    800050e0:	557d                	li	a0,-1
    800050e2:	bfcd                	j	800050d4 <argfd+0x46>
    800050e4:	557d                	li	a0,-1
    800050e6:	b7fd                	j	800050d4 <argfd+0x46>

00000000800050e8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800050e8:	1101                	addi	sp,sp,-32
    800050ea:	ec06                	sd	ra,24(sp)
    800050ec:	e822                	sd	s0,16(sp)
    800050ee:	e426                	sd	s1,8(sp)
    800050f0:	1000                	addi	s0,sp,32
    800050f2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800050f4:	859fc0ef          	jal	8000194c <myproc>
    800050f8:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    800050fa:	0d050793          	addi	a5,a0,208
    800050fe:	4501                	li	a0,0
    80005100:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80005102:	6398                	ld	a4,0(a5)
    80005104:	cb19                	beqz	a4,8000511a <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80005106:	2505                	addiw	a0,a0,1
    80005108:	07a1                	addi	a5,a5,8
    8000510a:	fed51ce3          	bne	a0,a3,80005102 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000510e:	557d                	li	a0,-1
}
    80005110:	60e2                	ld	ra,24(sp)
    80005112:	6442                	ld	s0,16(sp)
    80005114:	64a2                	ld	s1,8(sp)
    80005116:	6105                	addi	sp,sp,32
    80005118:	8082                	ret
      p->ofile[fd] = f;
    8000511a:	00351793          	slli	a5,a0,0x3
    8000511e:	0d078793          	addi	a5,a5,208
    80005122:	963e                	add	a2,a2,a5
    80005124:	e204                	sd	s1,0(a2)
      return fd;
    80005126:	b7ed                	j	80005110 <fdalloc+0x28>

0000000080005128 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80005128:	715d                	addi	sp,sp,-80
    8000512a:	e486                	sd	ra,72(sp)
    8000512c:	e0a2                	sd	s0,64(sp)
    8000512e:	fc26                	sd	s1,56(sp)
    80005130:	f84a                	sd	s2,48(sp)
    80005132:	f052                	sd	s4,32(sp)
    80005134:	ec56                	sd	s5,24(sp)
    80005136:	e85a                	sd	s6,16(sp)
    80005138:	0880                	addi	s0,sp,80
    8000513a:	8a2e                	mv	s4,a1
    8000513c:	8ab2                	mv	s5,a2
    8000513e:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80005140:	fb040593          	addi	a1,s0,-80
    80005144:	eb5fe0ef          	jal	80003ff8 <nameiparent>
    80005148:	84aa                	mv	s1,a0
    8000514a:	12050f63          	beqz	a0,80005288 <create+0x160>
    return 0;

  ilock(dp);
    8000514e:	df6fe0ef          	jal	80003744 <ilock>

  if (dp->nlink == 0) {
    80005152:	04a49783          	lh	a5,74(s1)
    80005156:	cbb9                	beqz	a5,800051ac <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80005158:	7761                	lui	a4,0xffff8
    8000515a:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd3399>
    8000515c:	97ba                	add	a5,a5,a4
    8000515e:	e781                	bnez	a5,80005166 <create+0x3e>
    80005160:	fffa0793          	addi	a5,s4,-1
    80005164:	cba9                	beqz	a5,800051b6 <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80005166:	4601                	li	a2,0
    80005168:	fb040593          	addi	a1,s0,-80
    8000516c:	8526                	mv	a0,s1
    8000516e:	bbffe0ef          	jal	80003d2c <dirlookup>
    80005172:	892a                	mv	s2,a0
    80005174:	c939                	beqz	a0,800051ca <create+0xa2>
    iunlockput(dp);
    80005176:	8526                	mv	a0,s1
    80005178:	821fe0ef          	jal	80003998 <iunlockput>
    ilock(ip);
    8000517c:	854a                	mv	a0,s2
    8000517e:	dc6fe0ef          	jal	80003744 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005182:	4789                	li	a5,2
    80005184:	02fa1e63          	bne	s4,a5,800051c0 <create+0x98>
    80005188:	04495783          	lhu	a5,68(s2)
    8000518c:	37f9                	addiw	a5,a5,-2
    8000518e:	17c2                	slli	a5,a5,0x30
    80005190:	93c1                	srli	a5,a5,0x30
    80005192:	4705                	li	a4,1
    80005194:	02f76663          	bltu	a4,a5,800051c0 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005198:	854a                	mv	a0,s2
    8000519a:	60a6                	ld	ra,72(sp)
    8000519c:	6406                	ld	s0,64(sp)
    8000519e:	74e2                	ld	s1,56(sp)
    800051a0:	7942                	ld	s2,48(sp)
    800051a2:	7a02                	ld	s4,32(sp)
    800051a4:	6ae2                	ld	s5,24(sp)
    800051a6:	6b42                	ld	s6,16(sp)
    800051a8:	6161                	addi	sp,sp,80
    800051aa:	8082                	ret
    iunlockput(dp);
    800051ac:	8526                	mv	a0,s1
    800051ae:	feafe0ef          	jal	80003998 <iunlockput>
    return 0;
    800051b2:	4901                	li	s2,0
    800051b4:	b7d5                	j	80005198 <create+0x70>
    iunlockput(dp);
    800051b6:	8526                	mv	a0,s1
    800051b8:	fe0fe0ef          	jal	80003998 <iunlockput>
    return 0;
    800051bc:	4901                	li	s2,0
    800051be:	bfe9                	j	80005198 <create+0x70>
    iunlockput(ip);
    800051c0:	854a                	mv	a0,s2
    800051c2:	fd6fe0ef          	jal	80003998 <iunlockput>
    return 0;
    800051c6:	4901                	li	s2,0
    800051c8:	bfc1                	j	80005198 <create+0x70>
    800051ca:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    800051cc:	85d2                	mv	a1,s4
    800051ce:	4088                	lw	a0,0(s1)
    800051d0:	c04fe0ef          	jal	800035d4 <ialloc>
    800051d4:	89aa                	mv	s3,a0
    800051d6:	cd1d                	beqz	a0,80005214 <create+0xec>
  ilock(ip);
    800051d8:	d6cfe0ef          	jal	80003744 <ilock>
  ip->major = major;
    800051dc:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    800051e0:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    800051e4:	4705                	li	a4,1
    800051e6:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    800051ea:	854e                	mv	a0,s3
    800051ec:	ca4fe0ef          	jal	80003690 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    800051f0:	4705                	li	a4,1
    800051f2:	02ea0763          	beq	s4,a4,80005220 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    800051f6:	0049a603          	lw	a2,4(s3)
    800051fa:	fb040593          	addi	a1,s0,-80
    800051fe:	8526                	mv	a0,s1
    80005200:	d35fe0ef          	jal	80003f34 <dirlink>
    80005204:	06054563          	bltz	a0,8000526e <create+0x146>
  iunlockput(dp);
    80005208:	8526                	mv	a0,s1
    8000520a:	f8efe0ef          	jal	80003998 <iunlockput>
  return ip;
    8000520e:	894e                	mv	s2,s3
    80005210:	79a2                	ld	s3,40(sp)
    80005212:	b759                	j	80005198 <create+0x70>
    iunlockput(dp);
    80005214:	8526                	mv	a0,s1
    80005216:	f82fe0ef          	jal	80003998 <iunlockput>
    return 0;
    8000521a:	894e                	mv	s2,s3
    8000521c:	79a2                	ld	s3,40(sp)
    8000521e:	bfad                	j	80005198 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005220:	0049a603          	lw	a2,4(s3)
    80005224:	00003597          	auipc	a1,0x3
    80005228:	3c458593          	addi	a1,a1,964 # 800085e8 <etext+0x5e8>
    8000522c:	854e                	mv	a0,s3
    8000522e:	d07fe0ef          	jal	80003f34 <dirlink>
    80005232:	02054e63          	bltz	a0,8000526e <create+0x146>
    80005236:	40d0                	lw	a2,4(s1)
    80005238:	00003597          	auipc	a1,0x3
    8000523c:	3b858593          	addi	a1,a1,952 # 800085f0 <etext+0x5f0>
    80005240:	854e                	mv	a0,s3
    80005242:	cf3fe0ef          	jal	80003f34 <dirlink>
    80005246:	02054463          	bltz	a0,8000526e <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    8000524a:	0049a603          	lw	a2,4(s3)
    8000524e:	fb040593          	addi	a1,s0,-80
    80005252:	8526                	mv	a0,s1
    80005254:	ce1fe0ef          	jal	80003f34 <dirlink>
    80005258:	00054b63          	bltz	a0,8000526e <create+0x146>
    dp->nlink++; // for ".."
    8000525c:	04a4d783          	lhu	a5,74(s1)
    80005260:	2785                	addiw	a5,a5,1
    80005262:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005266:	8526                	mv	a0,s1
    80005268:	c28fe0ef          	jal	80003690 <iupdate>
    8000526c:	bf71                	j	80005208 <create+0xe0>
  ip->nlink = 0;
    8000526e:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80005272:	854e                	mv	a0,s3
    80005274:	c1cfe0ef          	jal	80003690 <iupdate>
  iunlockput(ip);
    80005278:	854e                	mv	a0,s3
    8000527a:	f1efe0ef          	jal	80003998 <iunlockput>
  iunlockput(dp);
    8000527e:	8526                	mv	a0,s1
    80005280:	f18fe0ef          	jal	80003998 <iunlockput>
  return 0;
    80005284:	79a2                	ld	s3,40(sp)
    80005286:	bf09                	j	80005198 <create+0x70>
    return 0;
    80005288:	892a                	mv	s2,a0
    8000528a:	b739                	j	80005198 <create+0x70>

000000008000528c <sys_dup>:
{
    8000528c:	7179                	addi	sp,sp,-48
    8000528e:	f406                	sd	ra,40(sp)
    80005290:	f022                	sd	s0,32(sp)
    80005292:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80005294:	fd840613          	addi	a2,s0,-40
    80005298:	4581                	li	a1,0
    8000529a:	4501                	li	a0,0
    8000529c:	df3ff0ef          	jal	8000508e <argfd>
    return -1;
    800052a0:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    800052a2:	02054363          	bltz	a0,800052c8 <sys_dup+0x3c>
    800052a6:	ec26                	sd	s1,24(sp)
    800052a8:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    800052aa:	fd843483          	ld	s1,-40(s0)
    800052ae:	8526                	mv	a0,s1
    800052b0:	e39ff0ef          	jal	800050e8 <fdalloc>
    800052b4:	892a                	mv	s2,a0
    return -1;
    800052b6:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    800052b8:	00054d63          	bltz	a0,800052d2 <sys_dup+0x46>
  filedup(f);
    800052bc:	8526                	mv	a0,s1
    800052be:	b72ff0ef          	jal	80004630 <filedup>
  return fd;
    800052c2:	87ca                	mv	a5,s2
    800052c4:	64e2                	ld	s1,24(sp)
    800052c6:	6942                	ld	s2,16(sp)
}
    800052c8:	853e                	mv	a0,a5
    800052ca:	70a2                	ld	ra,40(sp)
    800052cc:	7402                	ld	s0,32(sp)
    800052ce:	6145                	addi	sp,sp,48
    800052d0:	8082                	ret
    800052d2:	64e2                	ld	s1,24(sp)
    800052d4:	6942                	ld	s2,16(sp)
    800052d6:	bfcd                	j	800052c8 <sys_dup+0x3c>

00000000800052d8 <sys_read>:
{
    800052d8:	7179                	addi	sp,sp,-48
    800052da:	f406                	sd	ra,40(sp)
    800052dc:	f022                	sd	s0,32(sp)
    800052de:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800052e0:	fd840593          	addi	a1,s0,-40
    800052e4:	4505                	li	a0,1
    800052e6:	88bfd0ef          	jal	80002b70 <argaddr>
  argint(2, &n);
    800052ea:	fe440593          	addi	a1,s0,-28
    800052ee:	4509                	li	a0,2
    800052f0:	865fd0ef          	jal	80002b54 <argint>
  if (argfd(0, 0, &f) < 0)
    800052f4:	fe840613          	addi	a2,s0,-24
    800052f8:	4581                	li	a1,0
    800052fa:	4501                	li	a0,0
    800052fc:	d93ff0ef          	jal	8000508e <argfd>
    80005300:	87aa                	mv	a5,a0
    return -1;
    80005302:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005304:	0007ca63          	bltz	a5,80005318 <sys_read+0x40>
  return fileread(f, p, n);
    80005308:	fe442603          	lw	a2,-28(s0)
    8000530c:	fd843583          	ld	a1,-40(s0)
    80005310:	fe843503          	ld	a0,-24(s0)
    80005314:	c94ff0ef          	jal	800047a8 <fileread>
}
    80005318:	70a2                	ld	ra,40(sp)
    8000531a:	7402                	ld	s0,32(sp)
    8000531c:	6145                	addi	sp,sp,48
    8000531e:	8082                	ret

0000000080005320 <sys_write>:
{
    80005320:	7179                	addi	sp,sp,-48
    80005322:	f406                	sd	ra,40(sp)
    80005324:	f022                	sd	s0,32(sp)
    80005326:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005328:	fd840593          	addi	a1,s0,-40
    8000532c:	4505                	li	a0,1
    8000532e:	843fd0ef          	jal	80002b70 <argaddr>
  argint(2, &n);
    80005332:	fe440593          	addi	a1,s0,-28
    80005336:	4509                	li	a0,2
    80005338:	81dfd0ef          	jal	80002b54 <argint>
  if (argfd(0, 0, &f) < 0)
    8000533c:	fe840613          	addi	a2,s0,-24
    80005340:	4581                	li	a1,0
    80005342:	4501                	li	a0,0
    80005344:	d4bff0ef          	jal	8000508e <argfd>
    80005348:	87aa                	mv	a5,a0
    return -1;
    8000534a:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    8000534c:	0007ca63          	bltz	a5,80005360 <sys_write+0x40>
  return filewrite(f, p, n);
    80005350:	fe442603          	lw	a2,-28(s0)
    80005354:	fd843583          	ld	a1,-40(s0)
    80005358:	fe843503          	ld	a0,-24(s0)
    8000535c:	d1aff0ef          	jal	80004876 <filewrite>
}
    80005360:	70a2                	ld	ra,40(sp)
    80005362:	7402                	ld	s0,32(sp)
    80005364:	6145                	addi	sp,sp,48
    80005366:	8082                	ret

0000000080005368 <sys_close>:
{
    80005368:	1101                	addi	sp,sp,-32
    8000536a:	ec06                	sd	ra,24(sp)
    8000536c:	e822                	sd	s0,16(sp)
    8000536e:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80005370:	fe040613          	addi	a2,s0,-32
    80005374:	fec40593          	addi	a1,s0,-20
    80005378:	4501                	li	a0,0
    8000537a:	d15ff0ef          	jal	8000508e <argfd>
    return -1;
    8000537e:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80005380:	02054163          	bltz	a0,800053a2 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80005384:	dc8fc0ef          	jal	8000194c <myproc>
    80005388:	fec42783          	lw	a5,-20(s0)
    8000538c:	078e                	slli	a5,a5,0x3
    8000538e:	0d078793          	addi	a5,a5,208
    80005392:	953e                	add	a0,a0,a5
    80005394:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005398:	fe043503          	ld	a0,-32(s0)
    8000539c:	adaff0ef          	jal	80004676 <fileclose>
  return 0;
    800053a0:	4781                	li	a5,0
}
    800053a2:	853e                	mv	a0,a5
    800053a4:	60e2                	ld	ra,24(sp)
    800053a6:	6442                	ld	s0,16(sp)
    800053a8:	6105                	addi	sp,sp,32
    800053aa:	8082                	ret

00000000800053ac <sys_fstat>:
{
    800053ac:	1101                	addi	sp,sp,-32
    800053ae:	ec06                	sd	ra,24(sp)
    800053b0:	e822                	sd	s0,16(sp)
    800053b2:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800053b4:	fe040593          	addi	a1,s0,-32
    800053b8:	4505                	li	a0,1
    800053ba:	fb6fd0ef          	jal	80002b70 <argaddr>
  if (argfd(0, 0, &f) < 0)
    800053be:	fe840613          	addi	a2,s0,-24
    800053c2:	4581                	li	a1,0
    800053c4:	4501                	li	a0,0
    800053c6:	cc9ff0ef          	jal	8000508e <argfd>
    800053ca:	87aa                	mv	a5,a0
    return -1;
    800053cc:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800053ce:	0007c863          	bltz	a5,800053de <sys_fstat+0x32>
  return filestat(f, st);
    800053d2:	fe043583          	ld	a1,-32(s0)
    800053d6:	fe843503          	ld	a0,-24(s0)
    800053da:	b5eff0ef          	jal	80004738 <filestat>
}
    800053de:	60e2                	ld	ra,24(sp)
    800053e0:	6442                	ld	s0,16(sp)
    800053e2:	6105                	addi	sp,sp,32
    800053e4:	8082                	ret

00000000800053e6 <sys_link>:
{
    800053e6:	7169                	addi	sp,sp,-304
    800053e8:	f606                	sd	ra,296(sp)
    800053ea:	f222                	sd	s0,288(sp)
    800053ec:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053ee:	08000613          	li	a2,128
    800053f2:	ed040593          	addi	a1,s0,-304
    800053f6:	4501                	li	a0,0
    800053f8:	f94fd0ef          	jal	80002b8c <argstr>
    return -1;
    800053fc:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053fe:	10054163          	bltz	a0,80005500 <sys_link+0x11a>
    80005402:	08000613          	li	a2,128
    80005406:	f5040593          	addi	a1,s0,-176
    8000540a:	4505                	li	a0,1
    8000540c:	f80fd0ef          	jal	80002b8c <argstr>
    return -1;
    80005410:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005412:	0e054763          	bltz	a0,80005500 <sys_link+0x11a>
    80005416:	ee26                	sd	s1,280(sp)
  begin_op();
    80005418:	da5fe0ef          	jal	800041bc <begin_op>
  if ((ip = namei(old)) == 0) {
    8000541c:	ed040513          	addi	a0,s0,-304
    80005420:	bbffe0ef          	jal	80003fde <namei>
    80005424:	84aa                	mv	s1,a0
    80005426:	cd35                	beqz	a0,800054a2 <sys_link+0xbc>
  ilock(ip);
    80005428:	b1cfe0ef          	jal	80003744 <ilock>
  if (ip->type == T_DIR) {
    8000542c:	04449703          	lh	a4,68(s1)
    80005430:	4785                	li	a5,1
    80005432:	06f70d63          	beq	a4,a5,800054ac <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80005436:	04a49783          	lh	a5,74(s1)
    8000543a:	6721                	lui	a4,0x8
    8000543c:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    8000543e:	06e78f63          	beq	a5,a4,800054bc <sys_link+0xd6>
    80005442:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005444:	2785                	addiw	a5,a5,1
    80005446:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000544a:	8526                	mv	a0,s1
    8000544c:	a44fe0ef          	jal	80003690 <iupdate>
  iunlock(ip);
    80005450:	8526                	mv	a0,s1
    80005452:	ba0fe0ef          	jal	800037f2 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80005456:	fd040593          	addi	a1,s0,-48
    8000545a:	f5040513          	addi	a0,s0,-176
    8000545e:	b9bfe0ef          	jal	80003ff8 <nameiparent>
    80005462:	892a                	mv	s2,a0
    80005464:	c93d                	beqz	a0,800054da <sys_link+0xf4>
  ilock(dp);
    80005466:	adefe0ef          	jal	80003744 <ilock>
  if (dp->nlink == 0) {
    8000546a:	04a91783          	lh	a5,74(s2)
    8000546e:	cfb9                	beqz	a5,800054cc <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80005470:	854a                	mv	a0,s2
    80005472:	00092703          	lw	a4,0(s2)
    80005476:	409c                	lw	a5,0(s1)
    80005478:	04f71e63          	bne	a4,a5,800054d4 <sys_link+0xee>
    8000547c:	40d0                	lw	a2,4(s1)
    8000547e:	fd040593          	addi	a1,s0,-48
    80005482:	ab3fe0ef          	jal	80003f34 <dirlink>
    80005486:	04054763          	bltz	a0,800054d4 <sys_link+0xee>
  iunlockput(dp);
    8000548a:	854a                	mv	a0,s2
    8000548c:	d0cfe0ef          	jal	80003998 <iunlockput>
  iput(ip);
    80005490:	8526                	mv	a0,s1
    80005492:	c34fe0ef          	jal	800038c6 <iput>
  end_op();
    80005496:	db3fe0ef          	jal	80004248 <end_op>
  return 0;
    8000549a:	4781                	li	a5,0
    8000549c:	64f2                	ld	s1,280(sp)
    8000549e:	6952                	ld	s2,272(sp)
    800054a0:	a085                	j	80005500 <sys_link+0x11a>
    end_op();
    800054a2:	da7fe0ef          	jal	80004248 <end_op>
    return -1;
    800054a6:	57fd                	li	a5,-1
    800054a8:	64f2                	ld	s1,280(sp)
    800054aa:	a899                	j	80005500 <sys_link+0x11a>
    iunlockput(ip);
    800054ac:	8526                	mv	a0,s1
    800054ae:	ceafe0ef          	jal	80003998 <iunlockput>
    end_op();
    800054b2:	d97fe0ef          	jal	80004248 <end_op>
    return -1;
    800054b6:	57fd                	li	a5,-1
    800054b8:	64f2                	ld	s1,280(sp)
    800054ba:	a099                	j	80005500 <sys_link+0x11a>
    iunlockput(ip);
    800054bc:	8526                	mv	a0,s1
    800054be:	cdafe0ef          	jal	80003998 <iunlockput>
    end_op();
    800054c2:	d87fe0ef          	jal	80004248 <end_op>
    return -1;
    800054c6:	57fd                	li	a5,-1
    800054c8:	64f2                	ld	s1,280(sp)
    800054ca:	a81d                	j	80005500 <sys_link+0x11a>
    iunlockput(dp);
    800054cc:	854a                	mv	a0,s2
    800054ce:	ccafe0ef          	jal	80003998 <iunlockput>
    goto bad;
    800054d2:	a021                	j	800054da <sys_link+0xf4>
    iunlockput(dp);
    800054d4:	854a                	mv	a0,s2
    800054d6:	cc2fe0ef          	jal	80003998 <iunlockput>
  ilock(ip);
    800054da:	8526                	mv	a0,s1
    800054dc:	a68fe0ef          	jal	80003744 <ilock>
  ip->nlink--;
    800054e0:	04a4d783          	lhu	a5,74(s1)
    800054e4:	37fd                	addiw	a5,a5,-1
    800054e6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054ea:	8526                	mv	a0,s1
    800054ec:	9a4fe0ef          	jal	80003690 <iupdate>
  iunlockput(ip);
    800054f0:	8526                	mv	a0,s1
    800054f2:	ca6fe0ef          	jal	80003998 <iunlockput>
  end_op();
    800054f6:	d53fe0ef          	jal	80004248 <end_op>
  return -1;
    800054fa:	57fd                	li	a5,-1
    800054fc:	64f2                	ld	s1,280(sp)
    800054fe:	6952                	ld	s2,272(sp)
}
    80005500:	853e                	mv	a0,a5
    80005502:	70b2                	ld	ra,296(sp)
    80005504:	7412                	ld	s0,288(sp)
    80005506:	6155                	addi	sp,sp,304
    80005508:	8082                	ret

000000008000550a <sys_unlink>:
{
    8000550a:	7151                	addi	sp,sp,-240
    8000550c:	f586                	sd	ra,232(sp)
    8000550e:	f1a2                	sd	s0,224(sp)
    80005510:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005512:	08000613          	li	a2,128
    80005516:	f3040593          	addi	a1,s0,-208
    8000551a:	4501                	li	a0,0
    8000551c:	e70fd0ef          	jal	80002b8c <argstr>
    80005520:	14054d63          	bltz	a0,8000567a <sys_unlink+0x170>
    80005524:	eda6                	sd	s1,216(sp)
  begin_op();
    80005526:	c97fe0ef          	jal	800041bc <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    8000552a:	fb040593          	addi	a1,s0,-80
    8000552e:	f3040513          	addi	a0,s0,-208
    80005532:	ac7fe0ef          	jal	80003ff8 <nameiparent>
    80005536:	84aa                	mv	s1,a0
    80005538:	c955                	beqz	a0,800055ec <sys_unlink+0xe2>
  ilock(dp);
    8000553a:	a0afe0ef          	jal	80003744 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000553e:	00003597          	auipc	a1,0x3
    80005542:	0aa58593          	addi	a1,a1,170 # 800085e8 <etext+0x5e8>
    80005546:	fb040513          	addi	a0,s0,-80
    8000554a:	fccfe0ef          	jal	80003d16 <namecmp>
    8000554e:	10050b63          	beqz	a0,80005664 <sys_unlink+0x15a>
    80005552:	00003597          	auipc	a1,0x3
    80005556:	09e58593          	addi	a1,a1,158 # 800085f0 <etext+0x5f0>
    8000555a:	fb040513          	addi	a0,s0,-80
    8000555e:	fb8fe0ef          	jal	80003d16 <namecmp>
    80005562:	10050163          	beqz	a0,80005664 <sys_unlink+0x15a>
    80005566:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005568:	f2c40613          	addi	a2,s0,-212
    8000556c:	fb040593          	addi	a1,s0,-80
    80005570:	8526                	mv	a0,s1
    80005572:	fbafe0ef          	jal	80003d2c <dirlookup>
    80005576:	892a                	mv	s2,a0
    80005578:	0e050563          	beqz	a0,80005662 <sys_unlink+0x158>
    8000557c:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    8000557e:	9c6fe0ef          	jal	80003744 <ilock>
  if (ip->nlink < 1)
    80005582:	04a91783          	lh	a5,74(s2)
    80005586:	06f05863          	blez	a5,800055f6 <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    8000558a:	04491703          	lh	a4,68(s2)
    8000558e:	4785                	li	a5,1
    80005590:	06f70963          	beq	a4,a5,80005602 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005594:	fc040993          	addi	s3,s0,-64
    80005598:	4641                	li	a2,16
    8000559a:	4581                	li	a1,0
    8000559c:	854e                	mv	a0,s3
    8000559e:	f4afb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055a2:	4741                	li	a4,16
    800055a4:	f2c42683          	lw	a3,-212(s0)
    800055a8:	864e                	mv	a2,s3
    800055aa:	4581                	li	a1,0
    800055ac:	8526                	mv	a0,s1
    800055ae:	e62fe0ef          	jal	80003c10 <writei>
    800055b2:	47c1                	li	a5,16
    800055b4:	08f51863          	bne	a0,a5,80005644 <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    800055b8:	04491703          	lh	a4,68(s2)
    800055bc:	4785                	li	a5,1
    800055be:	08f70963          	beq	a4,a5,80005650 <sys_unlink+0x146>
  iunlockput(dp);
    800055c2:	8526                	mv	a0,s1
    800055c4:	bd4fe0ef          	jal	80003998 <iunlockput>
  ip->nlink--;
    800055c8:	04a95783          	lhu	a5,74(s2)
    800055cc:	37fd                	addiw	a5,a5,-1
    800055ce:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055d2:	854a                	mv	a0,s2
    800055d4:	8bcfe0ef          	jal	80003690 <iupdate>
  iunlockput(ip);
    800055d8:	854a                	mv	a0,s2
    800055da:	bbefe0ef          	jal	80003998 <iunlockput>
  end_op();
    800055de:	c6bfe0ef          	jal	80004248 <end_op>
  return 0;
    800055e2:	4501                	li	a0,0
    800055e4:	64ee                	ld	s1,216(sp)
    800055e6:	694e                	ld	s2,208(sp)
    800055e8:	69ae                	ld	s3,200(sp)
    800055ea:	a061                	j	80005672 <sys_unlink+0x168>
    end_op();
    800055ec:	c5dfe0ef          	jal	80004248 <end_op>
    return -1;
    800055f0:	557d                	li	a0,-1
    800055f2:	64ee                	ld	s1,216(sp)
    800055f4:	a8bd                	j	80005672 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800055f6:	00003517          	auipc	a0,0x3
    800055fa:	00250513          	addi	a0,a0,2 # 800085f8 <etext+0x5f8>
    800055fe:	a36fb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005602:	04c92703          	lw	a4,76(s2)
    80005606:	02000793          	li	a5,32
    8000560a:	f8e7f5e3          	bgeu	a5,a4,80005594 <sys_unlink+0x8a>
    8000560e:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005610:	4741                	li	a4,16
    80005612:	86ce                	mv	a3,s3
    80005614:	f1840613          	addi	a2,s0,-232
    80005618:	4581                	li	a1,0
    8000561a:	854a                	mv	a0,s2
    8000561c:	d02fe0ef          	jal	80003b1e <readi>
    80005620:	47c1                	li	a5,16
    80005622:	00f51b63          	bne	a0,a5,80005638 <sys_unlink+0x12e>
    if (de.inum != 0)
    80005626:	f1845783          	lhu	a5,-232(s0)
    8000562a:	ebb1                	bnez	a5,8000567e <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000562c:	29c1                	addiw	s3,s3,16
    8000562e:	04c92783          	lw	a5,76(s2)
    80005632:	fcf9efe3          	bltu	s3,a5,80005610 <sys_unlink+0x106>
    80005636:	bfb9                	j	80005594 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005638:	00003517          	auipc	a0,0x3
    8000563c:	fd850513          	addi	a0,a0,-40 # 80008610 <etext+0x610>
    80005640:	9f4fb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    80005644:	00003517          	auipc	a0,0x3
    80005648:	fe450513          	addi	a0,a0,-28 # 80008628 <etext+0x628>
    8000564c:	9e8fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    80005650:	04a4d783          	lhu	a5,74(s1)
    80005654:	37fd                	addiw	a5,a5,-1
    80005656:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000565a:	8526                	mv	a0,s1
    8000565c:	834fe0ef          	jal	80003690 <iupdate>
    80005660:	b78d                	j	800055c2 <sys_unlink+0xb8>
    80005662:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005664:	8526                	mv	a0,s1
    80005666:	b32fe0ef          	jal	80003998 <iunlockput>
  end_op();
    8000566a:	bdffe0ef          	jal	80004248 <end_op>
  return -1;
    8000566e:	557d                	li	a0,-1
    80005670:	64ee                	ld	s1,216(sp)
}
    80005672:	70ae                	ld	ra,232(sp)
    80005674:	740e                	ld	s0,224(sp)
    80005676:	616d                	addi	sp,sp,240
    80005678:	8082                	ret
    return -1;
    8000567a:	557d                	li	a0,-1
    8000567c:	bfdd                	j	80005672 <sys_unlink+0x168>
    iunlockput(ip);
    8000567e:	854a                	mv	a0,s2
    80005680:	b18fe0ef          	jal	80003998 <iunlockput>
    goto bad;
    80005684:	694e                	ld	s2,208(sp)
    80005686:	69ae                	ld	s3,200(sp)
    80005688:	bff1                	j	80005664 <sys_unlink+0x15a>

000000008000568a <sys_open>:

uint64
sys_open(void)
{
    8000568a:	7131                	addi	sp,sp,-192
    8000568c:	fd06                	sd	ra,184(sp)
    8000568e:	f922                	sd	s0,176(sp)
    80005690:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005692:	f4c40593          	addi	a1,s0,-180
    80005696:	4505                	li	a0,1
    80005698:	cbcfd0ef          	jal	80002b54 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000569c:	08000613          	li	a2,128
    800056a0:	f5040593          	addi	a1,s0,-176
    800056a4:	4501                	li	a0,0
    800056a6:	ce6fd0ef          	jal	80002b8c <argstr>
    800056aa:	87aa                	mv	a5,a0
    return -1;
    800056ac:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800056ae:	0a07c363          	bltz	a5,80005754 <sys_open+0xca>
    800056b2:	f526                	sd	s1,168(sp)

  begin_op();
    800056b4:	b09fe0ef          	jal	800041bc <begin_op>

  if (omode & O_CREATE) {
    800056b8:	f4c42783          	lw	a5,-180(s0)
    800056bc:	2007f793          	andi	a5,a5,512
    800056c0:	c3dd                	beqz	a5,80005766 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800056c2:	4681                	li	a3,0
    800056c4:	4601                	li	a2,0
    800056c6:	4589                	li	a1,2
    800056c8:	f5040513          	addi	a0,s0,-176
    800056cc:	a5dff0ef          	jal	80005128 <create>
    800056d0:	84aa                	mv	s1,a0
    if (ip == 0) {
    800056d2:	c549                	beqz	a0,8000575c <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    800056d4:	04449703          	lh	a4,68(s1)
    800056d8:	478d                	li	a5,3
    800056da:	00f71763          	bne	a4,a5,800056e8 <sys_open+0x5e>
    800056de:	0464d703          	lhu	a4,70(s1)
    800056e2:	47a5                	li	a5,9
    800056e4:	0ae7ee63          	bltu	a5,a4,800057a0 <sys_open+0x116>
    800056e8:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    800056ea:	ee9fe0ef          	jal	800045d2 <filealloc>
    800056ee:	892a                	mv	s2,a0
    800056f0:	c561                	beqz	a0,800057b8 <sys_open+0x12e>
    800056f2:	ed4e                	sd	s3,152(sp)
    800056f4:	9f5ff0ef          	jal	800050e8 <fdalloc>
    800056f8:	89aa                	mv	s3,a0
    800056fa:	0a054b63          	bltz	a0,800057b0 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    800056fe:	04449703          	lh	a4,68(s1)
    80005702:	478d                	li	a5,3
    80005704:	0cf70363          	beq	a4,a5,800057ca <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005708:	4789                	li	a5,2
    8000570a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000570e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005712:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005716:	f4c42783          	lw	a5,-180(s0)
    8000571a:	0017f713          	andi	a4,a5,1
    8000571e:	00174713          	xori	a4,a4,1
    80005722:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005726:	0037f713          	andi	a4,a5,3
    8000572a:	00e03733          	snez	a4,a4
    8000572e:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80005732:	4007f793          	andi	a5,a5,1024
    80005736:	c791                	beqz	a5,80005742 <sys_open+0xb8>
    80005738:	04449703          	lh	a4,68(s1)
    8000573c:	4789                	li	a5,2
    8000573e:	08f70d63          	beq	a4,a5,800057d8 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005742:	8526                	mv	a0,s1
    80005744:	8aefe0ef          	jal	800037f2 <iunlock>
  end_op();
    80005748:	b01fe0ef          	jal	80004248 <end_op>

  return fd;
    8000574c:	854e                	mv	a0,s3
    8000574e:	74aa                	ld	s1,168(sp)
    80005750:	790a                	ld	s2,160(sp)
    80005752:	69ea                	ld	s3,152(sp)
}
    80005754:	70ea                	ld	ra,184(sp)
    80005756:	744a                	ld	s0,176(sp)
    80005758:	6129                	addi	sp,sp,192
    8000575a:	8082                	ret
      end_op();
    8000575c:	aedfe0ef          	jal	80004248 <end_op>
      return -1;
    80005760:	557d                	li	a0,-1
    80005762:	74aa                	ld	s1,168(sp)
    80005764:	bfc5                	j	80005754 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    80005766:	f5040513          	addi	a0,s0,-176
    8000576a:	875fe0ef          	jal	80003fde <namei>
    8000576e:	84aa                	mv	s1,a0
    80005770:	c11d                	beqz	a0,80005796 <sys_open+0x10c>
    ilock(ip);
    80005772:	fd3fd0ef          	jal	80003744 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    80005776:	04449703          	lh	a4,68(s1)
    8000577a:	4785                	li	a5,1
    8000577c:	f4f71ce3          	bne	a4,a5,800056d4 <sys_open+0x4a>
    80005780:	f4c42783          	lw	a5,-180(s0)
    80005784:	d3b5                	beqz	a5,800056e8 <sys_open+0x5e>
      iunlockput(ip);
    80005786:	8526                	mv	a0,s1
    80005788:	a10fe0ef          	jal	80003998 <iunlockput>
      end_op();
    8000578c:	abdfe0ef          	jal	80004248 <end_op>
      return -1;
    80005790:	557d                	li	a0,-1
    80005792:	74aa                	ld	s1,168(sp)
    80005794:	b7c1                	j	80005754 <sys_open+0xca>
      end_op();
    80005796:	ab3fe0ef          	jal	80004248 <end_op>
      return -1;
    8000579a:	557d                	li	a0,-1
    8000579c:	74aa                	ld	s1,168(sp)
    8000579e:	bf5d                	j	80005754 <sys_open+0xca>
    iunlockput(ip);
    800057a0:	8526                	mv	a0,s1
    800057a2:	9f6fe0ef          	jal	80003998 <iunlockput>
    end_op();
    800057a6:	aa3fe0ef          	jal	80004248 <end_op>
    return -1;
    800057aa:	557d                	li	a0,-1
    800057ac:	74aa                	ld	s1,168(sp)
    800057ae:	b75d                	j	80005754 <sys_open+0xca>
      fileclose(f);
    800057b0:	854a                	mv	a0,s2
    800057b2:	ec5fe0ef          	jal	80004676 <fileclose>
    800057b6:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800057b8:	8526                	mv	a0,s1
    800057ba:	9defe0ef          	jal	80003998 <iunlockput>
    end_op();
    800057be:	a8bfe0ef          	jal	80004248 <end_op>
    return -1;
    800057c2:	557d                	li	a0,-1
    800057c4:	74aa                	ld	s1,168(sp)
    800057c6:	790a                	ld	s2,160(sp)
    800057c8:	b771                	j	80005754 <sys_open+0xca>
    f->type = FD_DEVICE;
    800057ca:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800057ce:	04649783          	lh	a5,70(s1)
    800057d2:	02f91223          	sh	a5,36(s2)
    800057d6:	bf35                	j	80005712 <sys_open+0x88>
    itrunc(ip);
    800057d8:	8526                	mv	a0,s1
    800057da:	858fe0ef          	jal	80003832 <itrunc>
    800057de:	b795                	j	80005742 <sys_open+0xb8>

00000000800057e0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800057e0:	7175                	addi	sp,sp,-144
    800057e2:	e506                	sd	ra,136(sp)
    800057e4:	e122                	sd	s0,128(sp)
    800057e6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800057e8:	9d5fe0ef          	jal	800041bc <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    800057ec:	08000613          	li	a2,128
    800057f0:	f7040593          	addi	a1,s0,-144
    800057f4:	4501                	li	a0,0
    800057f6:	b96fd0ef          	jal	80002b8c <argstr>
    800057fa:	02054363          	bltz	a0,80005820 <sys_mkdir+0x40>
    800057fe:	4681                	li	a3,0
    80005800:	4601                	li	a2,0
    80005802:	4585                	li	a1,1
    80005804:	f7040513          	addi	a0,s0,-144
    80005808:	921ff0ef          	jal	80005128 <create>
    8000580c:	c911                	beqz	a0,80005820 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000580e:	98afe0ef          	jal	80003998 <iunlockput>
  end_op();
    80005812:	a37fe0ef          	jal	80004248 <end_op>
  return 0;
    80005816:	4501                	li	a0,0
}
    80005818:	60aa                	ld	ra,136(sp)
    8000581a:	640a                	ld	s0,128(sp)
    8000581c:	6149                	addi	sp,sp,144
    8000581e:	8082                	ret
    end_op();
    80005820:	a29fe0ef          	jal	80004248 <end_op>
    return -1;
    80005824:	557d                	li	a0,-1
    80005826:	bfcd                	j	80005818 <sys_mkdir+0x38>

0000000080005828 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005828:	7135                	addi	sp,sp,-160
    8000582a:	ed06                	sd	ra,152(sp)
    8000582c:	e922                	sd	s0,144(sp)
    8000582e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005830:	98dfe0ef          	jal	800041bc <begin_op>
  argint(1, &major);
    80005834:	f6c40593          	addi	a1,s0,-148
    80005838:	4505                	li	a0,1
    8000583a:	b1afd0ef          	jal	80002b54 <argint>
  argint(2, &minor);
    8000583e:	f6840593          	addi	a1,s0,-152
    80005842:	4509                	li	a0,2
    80005844:	b10fd0ef          	jal	80002b54 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005848:	08000613          	li	a2,128
    8000584c:	f7040593          	addi	a1,s0,-144
    80005850:	4501                	li	a0,0
    80005852:	b3afd0ef          	jal	80002b8c <argstr>
    80005856:	02054563          	bltz	a0,80005880 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    8000585a:	f6841683          	lh	a3,-152(s0)
    8000585e:	f6c41603          	lh	a2,-148(s0)
    80005862:	458d                	li	a1,3
    80005864:	f7040513          	addi	a0,s0,-144
    80005868:	8c1ff0ef          	jal	80005128 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    8000586c:	c911                	beqz	a0,80005880 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000586e:	92afe0ef          	jal	80003998 <iunlockput>
  end_op();
    80005872:	9d7fe0ef          	jal	80004248 <end_op>
  return 0;
    80005876:	4501                	li	a0,0
}
    80005878:	60ea                	ld	ra,152(sp)
    8000587a:	644a                	ld	s0,144(sp)
    8000587c:	610d                	addi	sp,sp,160
    8000587e:	8082                	ret
    end_op();
    80005880:	9c9fe0ef          	jal	80004248 <end_op>
    return -1;
    80005884:	557d                	li	a0,-1
    80005886:	bfcd                	j	80005878 <sys_mknod+0x50>

0000000080005888 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005888:	7135                	addi	sp,sp,-160
    8000588a:	ed06                	sd	ra,152(sp)
    8000588c:	e922                	sd	s0,144(sp)
    8000588e:	e14a                	sd	s2,128(sp)
    80005890:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005892:	8bafc0ef          	jal	8000194c <myproc>
    80005896:	892a                	mv	s2,a0

  begin_op();
    80005898:	925fe0ef          	jal	800041bc <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    8000589c:	08000613          	li	a2,128
    800058a0:	f6040593          	addi	a1,s0,-160
    800058a4:	4501                	li	a0,0
    800058a6:	ae6fd0ef          	jal	80002b8c <argstr>
    800058aa:	04054363          	bltz	a0,800058f0 <sys_chdir+0x68>
    800058ae:	e526                	sd	s1,136(sp)
    800058b0:	f6040513          	addi	a0,s0,-160
    800058b4:	f2afe0ef          	jal	80003fde <namei>
    800058b8:	84aa                	mv	s1,a0
    800058ba:	c915                	beqz	a0,800058ee <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800058bc:	e89fd0ef          	jal	80003744 <ilock>
  if (ip->type != T_DIR) {
    800058c0:	04449703          	lh	a4,68(s1)
    800058c4:	4785                	li	a5,1
    800058c6:	02f71963          	bne	a4,a5,800058f8 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800058ca:	8526                	mv	a0,s1
    800058cc:	f27fd0ef          	jal	800037f2 <iunlock>
  iput(p->cwd);
    800058d0:	15093503          	ld	a0,336(s2)
    800058d4:	ff3fd0ef          	jal	800038c6 <iput>
  end_op();
    800058d8:	971fe0ef          	jal	80004248 <end_op>
  p->cwd = ip;
    800058dc:	14993823          	sd	s1,336(s2)
  return 0;
    800058e0:	4501                	li	a0,0
    800058e2:	64aa                	ld	s1,136(sp)
}
    800058e4:	60ea                	ld	ra,152(sp)
    800058e6:	644a                	ld	s0,144(sp)
    800058e8:	690a                	ld	s2,128(sp)
    800058ea:	610d                	addi	sp,sp,160
    800058ec:	8082                	ret
    800058ee:	64aa                	ld	s1,136(sp)
    end_op();
    800058f0:	959fe0ef          	jal	80004248 <end_op>
    return -1;
    800058f4:	557d                	li	a0,-1
    800058f6:	b7fd                	j	800058e4 <sys_chdir+0x5c>
    iunlockput(ip);
    800058f8:	8526                	mv	a0,s1
    800058fa:	89efe0ef          	jal	80003998 <iunlockput>
    end_op();
    800058fe:	94bfe0ef          	jal	80004248 <end_op>
    return -1;
    80005902:	557d                	li	a0,-1
    80005904:	64aa                	ld	s1,136(sp)
    80005906:	bff9                	j	800058e4 <sys_chdir+0x5c>

0000000080005908 <sys_exec>:

uint64
sys_exec(void)
{
    80005908:	7105                	addi	sp,sp,-480
    8000590a:	ef86                	sd	ra,472(sp)
    8000590c:	eba2                	sd	s0,464(sp)
    8000590e:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005910:	e2840593          	addi	a1,s0,-472
    80005914:	4505                	li	a0,1
    80005916:	a5afd0ef          	jal	80002b70 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    8000591a:	08000613          	li	a2,128
    8000591e:	f3040593          	addi	a1,s0,-208
    80005922:	4501                	li	a0,0
    80005924:	a68fd0ef          	jal	80002b8c <argstr>
    80005928:	87aa                	mv	a5,a0
    return -1;
    8000592a:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    8000592c:	0e07c063          	bltz	a5,80005a0c <sys_exec+0x104>
    80005930:	e7a6                	sd	s1,456(sp)
    80005932:	e3ca                	sd	s2,448(sp)
    80005934:	ff4e                	sd	s3,440(sp)
    80005936:	fb52                	sd	s4,432(sp)
    80005938:	f756                	sd	s5,424(sp)
    8000593a:	f35a                	sd	s6,416(sp)
    8000593c:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000593e:	e3040a13          	addi	s4,s0,-464
    80005942:	10000613          	li	a2,256
    80005946:	4581                	li	a1,0
    80005948:	8552                	mv	a0,s4
    8000594a:	b9efb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    8000594e:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005950:	89d2                	mv	s3,s4
    80005952:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005954:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005958:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    8000595a:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000595e:	00391513          	slli	a0,s2,0x3
    80005962:	85d6                	mv	a1,s5
    80005964:	e2843783          	ld	a5,-472(s0)
    80005968:	953e                	add	a0,a0,a5
    8000596a:	95efd0ef          	jal	80002ac8 <fetchaddr>
    8000596e:	02054663          	bltz	a0,8000599a <sys_exec+0x92>
    if (uarg == 0) {
    80005972:	e2043783          	ld	a5,-480(s0)
    80005976:	c7a1                	beqz	a5,800059be <sys_exec+0xb6>
    argv[i] = kalloc();
    80005978:	9d6fb0ef          	jal	80000b4e <kalloc>
    8000597c:	85aa                	mv	a1,a0
    8000597e:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005982:	cd01                	beqz	a0,8000599a <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005984:	865a                	mv	a2,s6
    80005986:	e2043503          	ld	a0,-480(s0)
    8000598a:	988fd0ef          	jal	80002b12 <fetchstr>
    8000598e:	00054663          	bltz	a0,8000599a <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    80005992:	0905                	addi	s2,s2,1
    80005994:	09a1                	addi	s3,s3,8
    80005996:	fd7914e3          	bne	s2,s7,8000595e <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000599a:	100a0a13          	addi	s4,s4,256
    8000599e:	6088                	ld	a0,0(s1)
    800059a0:	cd31                	beqz	a0,800059fc <sys_exec+0xf4>
    kfree(argv[i]);
    800059a2:	8c4fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059a6:	04a1                	addi	s1,s1,8
    800059a8:	ff449be3          	bne	s1,s4,8000599e <sys_exec+0x96>
  return -1;
    800059ac:	557d                	li	a0,-1
    800059ae:	64be                	ld	s1,456(sp)
    800059b0:	691e                	ld	s2,448(sp)
    800059b2:	79fa                	ld	s3,440(sp)
    800059b4:	7a5a                	ld	s4,432(sp)
    800059b6:	7aba                	ld	s5,424(sp)
    800059b8:	7b1a                	ld	s6,416(sp)
    800059ba:	6bfa                	ld	s7,408(sp)
    800059bc:	a881                	j	80005a0c <sys_exec+0x104>
      argv[i] = 0;
    800059be:	0009079b          	sext.w	a5,s2
    800059c2:	e3040593          	addi	a1,s0,-464
    800059c6:	078e                	slli	a5,a5,0x3
    800059c8:	97ae                	add	a5,a5,a1
    800059ca:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    800059ce:	f3040513          	addi	a0,s0,-208
    800059d2:	b62ff0ef          	jal	80004d34 <kexec>
    800059d6:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059d8:	100a0a13          	addi	s4,s4,256
    800059dc:	6088                	ld	a0,0(s1)
    800059de:	c511                	beqz	a0,800059ea <sys_exec+0xe2>
    kfree(argv[i]);
    800059e0:	886fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059e4:	04a1                	addi	s1,s1,8
    800059e6:	ff449be3          	bne	s1,s4,800059dc <sys_exec+0xd4>
  return ret;
    800059ea:	854a                	mv	a0,s2
    800059ec:	64be                	ld	s1,456(sp)
    800059ee:	691e                	ld	s2,448(sp)
    800059f0:	79fa                	ld	s3,440(sp)
    800059f2:	7a5a                	ld	s4,432(sp)
    800059f4:	7aba                	ld	s5,424(sp)
    800059f6:	7b1a                	ld	s6,416(sp)
    800059f8:	6bfa                	ld	s7,408(sp)
    800059fa:	a809                	j	80005a0c <sys_exec+0x104>
  return -1;
    800059fc:	557d                	li	a0,-1
    800059fe:	64be                	ld	s1,456(sp)
    80005a00:	691e                	ld	s2,448(sp)
    80005a02:	79fa                	ld	s3,440(sp)
    80005a04:	7a5a                	ld	s4,432(sp)
    80005a06:	7aba                	ld	s5,424(sp)
    80005a08:	7b1a                	ld	s6,416(sp)
    80005a0a:	6bfa                	ld	s7,408(sp)
}
    80005a0c:	60fe                	ld	ra,472(sp)
    80005a0e:	645e                	ld	s0,464(sp)
    80005a10:	613d                	addi	sp,sp,480
    80005a12:	8082                	ret

0000000080005a14 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a14:	7139                	addi	sp,sp,-64
    80005a16:	fc06                	sd	ra,56(sp)
    80005a18:	f822                	sd	s0,48(sp)
    80005a1a:	f426                	sd	s1,40(sp)
    80005a1c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a1e:	f2ffb0ef          	jal	8000194c <myproc>
    80005a22:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005a24:	fd840593          	addi	a1,s0,-40
    80005a28:	4501                	li	a0,0
    80005a2a:	946fd0ef          	jal	80002b70 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005a2e:	fc840593          	addi	a1,s0,-56
    80005a32:	fd040513          	addi	a0,s0,-48
    80005a36:	f7ffe0ef          	jal	800049b4 <pipealloc>
    return -1;
    80005a3a:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005a3c:	0a054963          	bltz	a0,80005aee <sys_pipe+0xda>
  fd0 = -1;
    80005a40:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    80005a44:	fd043503          	ld	a0,-48(s0)
    80005a48:	ea0ff0ef          	jal	800050e8 <fdalloc>
    80005a4c:	fca42223          	sw	a0,-60(s0)
    80005a50:	08054663          	bltz	a0,80005adc <sys_pipe+0xc8>
    80005a54:	fc843503          	ld	a0,-56(s0)
    80005a58:	e90ff0ef          	jal	800050e8 <fdalloc>
    80005a5c:	fca42023          	sw	a0,-64(s0)
    80005a60:	06054463          	bltz	a0,80005ac8 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005a64:	4711                	li	a4,4
    80005a66:	fc440693          	addi	a3,s0,-60
    80005a6a:	fd843603          	ld	a2,-40(s0)
    80005a6e:	64ac                	ld	a1,72(s1)
    80005a70:	68a8                	ld	a0,80(s1)
    80005a72:	b15fb0ef          	jal	80001586 <copyout>
    80005a76:	00054f63          	bltz	a0,80005a94 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    80005a7a:	4711                	li	a4,4
    80005a7c:	fc040693          	addi	a3,s0,-64
    80005a80:	fd843603          	ld	a2,-40(s0)
    80005a84:	963a                	add	a2,a2,a4
    80005a86:	64ac                	ld	a1,72(s1)
    80005a88:	68a8                	ld	a0,80(s1)
    80005a8a:	afdfb0ef          	jal	80001586 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005a8e:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005a90:	04055f63          	bgez	a0,80005aee <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    80005a94:	fc442783          	lw	a5,-60(s0)
    80005a98:	078e                	slli	a5,a5,0x3
    80005a9a:	0d078793          	addi	a5,a5,208
    80005a9e:	97a6                	add	a5,a5,s1
    80005aa0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005aa4:	fc042783          	lw	a5,-64(s0)
    80005aa8:	078e                	slli	a5,a5,0x3
    80005aaa:	0d078793          	addi	a5,a5,208
    80005aae:	94be                	add	s1,s1,a5
    80005ab0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005ab4:	fd043503          	ld	a0,-48(s0)
    80005ab8:	bbffe0ef          	jal	80004676 <fileclose>
    fileclose(wf);
    80005abc:	fc843503          	ld	a0,-56(s0)
    80005ac0:	bb7fe0ef          	jal	80004676 <fileclose>
    return -1;
    80005ac4:	57fd                	li	a5,-1
    80005ac6:	a025                	j	80005aee <sys_pipe+0xda>
    if (fd0 >= 0)
    80005ac8:	fc442783          	lw	a5,-60(s0)
    80005acc:	0007c863          	bltz	a5,80005adc <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    80005ad0:	078e                	slli	a5,a5,0x3
    80005ad2:	0d078793          	addi	a5,a5,208
    80005ad6:	97a6                	add	a5,a5,s1
    80005ad8:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005adc:	fd043503          	ld	a0,-48(s0)
    80005ae0:	b97fe0ef          	jal	80004676 <fileclose>
    fileclose(wf);
    80005ae4:	fc843503          	ld	a0,-56(s0)
    80005ae8:	b8ffe0ef          	jal	80004676 <fileclose>
    return -1;
    80005aec:	57fd                	li	a5,-1
}
    80005aee:	853e                	mv	a0,a5
    80005af0:	70e2                	ld	ra,56(sp)
    80005af2:	7442                	ld	s0,48(sp)
    80005af4:	74a2                	ld	s1,40(sp)
    80005af6:	6121                	addi	sp,sp,64
    80005af8:	8082                	ret
    80005afa:	0000                	unimp
    80005afc:	0000                	unimp
	...

0000000080005b00 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005b00:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005b02:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005b04:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005b06:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005b08:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005b0a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005b0c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005b0e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005b10:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005b12:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005b14:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005b16:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005b18:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005b1a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005b1c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005b1e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005b20:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005b22:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005b24:	eb3fc0ef          	jal	800029d6 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005b28:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005b2a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005b2c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005b2e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005b30:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005b32:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005b34:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005b36:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005b38:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005b3a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005b3c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005b3e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005b40:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005b42:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005b44:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005b46:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005b48:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005b4a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005b4c:	10200073          	sret
    80005b50:	0001                	nop
    80005b52:	00000013          	nop
    80005b56:	00000013          	nop
    80005b5a:	00000013          	nop

0000000080005b5e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005b5e:	1141                	addi	sp,sp,-16
    80005b60:	e406                	sd	ra,8(sp)
    80005b62:	e022                	sd	s0,0(sp)
    80005b64:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005b66:	0c000737          	lui	a4,0xc000
    80005b6a:	4785                	li	a5,1
    80005b6c:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    80005b6e:	c35c                	sw	a5,4(a4)
}
    80005b70:	60a2                	ld	ra,8(sp)
    80005b72:	6402                	ld	s0,0(sp)
    80005b74:	0141                	addi	sp,sp,16
    80005b76:	8082                	ret

0000000080005b78 <plicinithart>:

void
plicinithart(void)
{
    80005b78:	1141                	addi	sp,sp,-16
    80005b7a:	e406                	sd	ra,8(sp)
    80005b7c:	e022                	sd	s0,0(sp)
    80005b7e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005b80:	d99fb0ef          	jal	80001918 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    80005b84:	0085179b          	slliw	a5,a0,0x8
    80005b88:	0c002737          	lui	a4,0xc002
    80005b8c:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    80005b90:	97ba                	add	a5,a5,a4
    80005b92:	40200713          	li	a4,1026
    80005b96:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005b98:	00d5151b          	slliw	a0,a0,0xd
    80005b9c:	0c2017b7          	lui	a5,0xc201
    80005ba0:	953e                	add	a0,a0,a5
    80005ba2:	00052023          	sw	zero,0(a0)
}
    80005ba6:	60a2                	ld	ra,8(sp)
    80005ba8:	6402                	ld	s0,0(sp)
    80005baa:	0141                	addi	sp,sp,16
    80005bac:	8082                	ret

0000000080005bae <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005bae:	1141                	addi	sp,sp,-16
    80005bb0:	e406                	sd	ra,8(sp)
    80005bb2:	e022                	sd	s0,0(sp)
    80005bb4:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005bb6:	d63fb0ef          	jal	80001918 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    80005bba:	00d5151b          	slliw	a0,a0,0xd
    80005bbe:	0c2017b7          	lui	a5,0xc201
    80005bc2:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80005bc4:	953e                	add	a0,a0,a5
    80005bc6:	4108                	lw	a0,0(a0)
  return irq;
}
    80005bc8:	60a2                	ld	ra,8(sp)
    80005bca:	6402                	ld	s0,0(sp)
    80005bcc:	0141                	addi	sp,sp,16
    80005bce:	8082                	ret

0000000080005bd0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005bd0:	1101                	addi	sp,sp,-32
    80005bd2:	ec06                	sd	ra,24(sp)
    80005bd4:	e822                	sd	s0,16(sp)
    80005bd6:	e426                	sd	s1,8(sp)
    80005bd8:	1000                	addi	s0,sp,32
    80005bda:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005bdc:	d3dfb0ef          	jal	80001918 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    80005be0:	00d5179b          	slliw	a5,a0,0xd
    80005be4:	0c201737          	lui	a4,0xc201
    80005be8:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    80005bea:	97ba                	add	a5,a5,a4
    80005bec:	c384                	sw	s1,0(a5)
}
    80005bee:	60e2                	ld	ra,24(sp)
    80005bf0:	6442                	ld	s0,16(sp)
    80005bf2:	64a2                	ld	s1,8(sp)
    80005bf4:	6105                	addi	sp,sp,32
    80005bf6:	8082                	ret

0000000080005bf8 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005bf8:	1141                	addi	sp,sp,-16
    80005bfa:	e406                	sd	ra,8(sp)
    80005bfc:	e022                	sd	s0,0(sp)
    80005bfe:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005c00:	479d                	li	a5,7
    80005c02:	04a7ca63          	blt	a5,a0,80005c56 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005c06:	0001f797          	auipc	a5,0x1f
    80005c0a:	f2278793          	addi	a5,a5,-222 # 80024b28 <disk>
    80005c0e:	97aa                	add	a5,a5,a0
    80005c10:	0187c783          	lbu	a5,24(a5)
    80005c14:	e7b9                	bnez	a5,80005c62 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005c16:	00451693          	slli	a3,a0,0x4
    80005c1a:	0001f797          	auipc	a5,0x1f
    80005c1e:	f0e78793          	addi	a5,a5,-242 # 80024b28 <disk>
    80005c22:	6398                	ld	a4,0(a5)
    80005c24:	9736                	add	a4,a4,a3
    80005c26:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005c2a:	6398                	ld	a4,0(a5)
    80005c2c:	9736                	add	a4,a4,a3
    80005c2e:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005c32:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005c36:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005c3a:	97aa                	add	a5,a5,a0
    80005c3c:	4705                	li	a4,1
    80005c3e:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005c42:	0001f517          	auipc	a0,0x1f
    80005c46:	efe50513          	addi	a0,a0,-258 # 80024b40 <disk+0x18>
    80005c4a:	d5efc0ef          	jal	800021a8 <wakeup>
}
    80005c4e:	60a2                	ld	ra,8(sp)
    80005c50:	6402                	ld	s0,0(sp)
    80005c52:	0141                	addi	sp,sp,16
    80005c54:	8082                	ret
    panic("free_desc 1");
    80005c56:	00003517          	auipc	a0,0x3
    80005c5a:	9e250513          	addi	a0,a0,-1566 # 80008638 <etext+0x638>
    80005c5e:	bd7fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    80005c62:	00003517          	auipc	a0,0x3
    80005c66:	9e650513          	addi	a0,a0,-1562 # 80008648 <etext+0x648>
    80005c6a:	bcbfa0ef          	jal	80000834 <panic>

0000000080005c6e <virtio_disk_init>:
{
    80005c6e:	1101                	addi	sp,sp,-32
    80005c70:	ec06                	sd	ra,24(sp)
    80005c72:	e822                	sd	s0,16(sp)
    80005c74:	e426                	sd	s1,8(sp)
    80005c76:	e04a                	sd	s2,0(sp)
    80005c78:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005c7a:	00003597          	auipc	a1,0x3
    80005c7e:	9de58593          	addi	a1,a1,-1570 # 80008658 <etext+0x658>
    80005c82:	0001f517          	auipc	a0,0x1f
    80005c86:	fce50513          	addi	a0,a0,-50 # 80024c50 <disk+0x128>
    80005c8a:	f1ffa0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005c8e:	100017b7          	lui	a5,0x10001
    80005c92:	4398                	lw	a4,0(a5)
    80005c94:	2701                	sext.w	a4,a4
    80005c96:	747277b7          	lui	a5,0x74727
    80005c9a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005c9e:	14f71863          	bne	a4,a5,80005dee <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ca2:	100017b7          	lui	a5,0x10001
    80005ca6:	43dc                	lw	a5,4(a5)
    80005ca8:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005caa:	4709                	li	a4,2
    80005cac:	14e79163          	bne	a5,a4,80005dee <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005cb0:	100017b7          	lui	a5,0x10001
    80005cb4:	479c                	lw	a5,8(a5)
    80005cb6:	2781                	sext.w	a5,a5
    80005cb8:	12e79b63          	bne	a5,a4,80005dee <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    80005cbc:	100017b7          	lui	a5,0x10001
    80005cc0:	47d8                	lw	a4,12(a5)
    80005cc2:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005cc4:	554d47b7          	lui	a5,0x554d4
    80005cc8:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005ccc:	12f71163          	bne	a4,a5,80005dee <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cd0:	100017b7          	lui	a5,0x10001
    80005cd4:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cd8:	4705                	li	a4,1
    80005cda:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cdc:	470d                	li	a4,3
    80005cde:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005ce0:	10001737          	lui	a4,0x10001
    80005ce4:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005ce6:	c7ffe6b7          	lui	a3,0xc7ffe
    80005cea:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fd98f7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005cee:	8f75                	and	a4,a4,a3
    80005cf0:	100016b7          	lui	a3,0x10001
    80005cf4:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cf6:	472d                	li	a4,11
    80005cf8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cfa:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005cfe:	439c                	lw	a5,0(a5)
    80005d00:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005d04:	8ba1                	andi	a5,a5,8
    80005d06:	0e078a63          	beqz	a5,80005dfa <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d0a:	100017b7          	lui	a5,0x10001
    80005d0e:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005d12:	43fc                	lw	a5,68(a5)
    80005d14:	2781                	sext.w	a5,a5
    80005d16:	0e079863          	bnez	a5,80005e06 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005d1a:	100017b7          	lui	a5,0x10001
    80005d1e:	5bdc                	lw	a5,52(a5)
    80005d20:	2781                	sext.w	a5,a5
  if (max == 0)
    80005d22:	0e078863          	beqz	a5,80005e12 <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005d26:	471d                	li	a4,7
    80005d28:	0ef77b63          	bgeu	a4,a5,80005e1e <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005d2c:	e23fa0ef          	jal	80000b4e <kalloc>
    80005d30:	0001f497          	auipc	s1,0x1f
    80005d34:	df848493          	addi	s1,s1,-520 # 80024b28 <disk>
    80005d38:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005d3a:	e15fa0ef          	jal	80000b4e <kalloc>
    80005d3e:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005d40:	e0ffa0ef          	jal	80000b4e <kalloc>
    80005d44:	87aa                	mv	a5,a0
    80005d46:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005d48:	6088                	ld	a0,0(s1)
    80005d4a:	0e050063          	beqz	a0,80005e2a <virtio_disk_init+0x1bc>
    80005d4e:	0001f717          	auipc	a4,0x1f
    80005d52:	de273703          	ld	a4,-542(a4) # 80024b30 <disk+0x8>
    80005d56:	cb71                	beqz	a4,80005e2a <virtio_disk_init+0x1bc>
    80005d58:	cbe9                	beqz	a5,80005e2a <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005d5a:	6605                	lui	a2,0x1
    80005d5c:	4581                	li	a1,0
    80005d5e:	f8bfa0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005d62:	0001f497          	auipc	s1,0x1f
    80005d66:	dc648493          	addi	s1,s1,-570 # 80024b28 <disk>
    80005d6a:	6605                	lui	a2,0x1
    80005d6c:	4581                	li	a1,0
    80005d6e:	6488                	ld	a0,8(s1)
    80005d70:	f79fa0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005d74:	6605                	lui	a2,0x1
    80005d76:	4581                	li	a1,0
    80005d78:	6888                	ld	a0,16(s1)
    80005d7a:	f6ffa0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005d7e:	100017b7          	lui	a5,0x10001
    80005d82:	4721                	li	a4,8
    80005d84:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005d86:	4098                	lw	a4,0(s1)
    80005d88:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005d8c:	40d8                	lw	a4,4(s1)
    80005d8e:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005d92:	649c                	ld	a5,8(s1)
    80005d94:	0007869b          	sext.w	a3,a5
    80005d98:	10001737          	lui	a4,0x10001
    80005d9c:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005da0:	9781                	srai	a5,a5,0x20
    80005da2:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005da6:	689c                	ld	a5,16(s1)
    80005da8:	0007869b          	sext.w	a3,a5
    80005dac:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005db0:	9781                	srai	a5,a5,0x20
    80005db2:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005db6:	4785                	li	a5,1
    80005db8:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005dba:	00f48c23          	sb	a5,24(s1)
    80005dbe:	00f48ca3          	sb	a5,25(s1)
    80005dc2:	00f48d23          	sb	a5,26(s1)
    80005dc6:	00f48da3          	sb	a5,27(s1)
    80005dca:	00f48e23          	sb	a5,28(s1)
    80005dce:	00f48ea3          	sb	a5,29(s1)
    80005dd2:	00f48f23          	sb	a5,30(s1)
    80005dd6:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005dda:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dde:	07272823          	sw	s2,112(a4)
}
    80005de2:	60e2                	ld	ra,24(sp)
    80005de4:	6442                	ld	s0,16(sp)
    80005de6:	64a2                	ld	s1,8(sp)
    80005de8:	6902                	ld	s2,0(sp)
    80005dea:	6105                	addi	sp,sp,32
    80005dec:	8082                	ret
    panic("could not find virtio disk");
    80005dee:	00003517          	auipc	a0,0x3
    80005df2:	87a50513          	addi	a0,a0,-1926 # 80008668 <etext+0x668>
    80005df6:	a3ffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005dfa:	00003517          	auipc	a0,0x3
    80005dfe:	88e50513          	addi	a0,a0,-1906 # 80008688 <etext+0x688>
    80005e02:	a33fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005e06:	00003517          	auipc	a0,0x3
    80005e0a:	8a250513          	addi	a0,a0,-1886 # 800086a8 <etext+0x6a8>
    80005e0e:	a27fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005e12:	00003517          	auipc	a0,0x3
    80005e16:	8b650513          	addi	a0,a0,-1866 # 800086c8 <etext+0x6c8>
    80005e1a:	a1bfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005e1e:	00003517          	auipc	a0,0x3
    80005e22:	8ca50513          	addi	a0,a0,-1846 # 800086e8 <etext+0x6e8>
    80005e26:	a0ffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005e2a:	00003517          	auipc	a0,0x3
    80005e2e:	8de50513          	addi	a0,a0,-1826 # 80008708 <etext+0x708>
    80005e32:	a03fa0ef          	jal	80000834 <panic>

0000000080005e36 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005e36:	711d                	addi	sp,sp,-96
    80005e38:	ec86                	sd	ra,88(sp)
    80005e3a:	e8a2                	sd	s0,80(sp)
    80005e3c:	e4a6                	sd	s1,72(sp)
    80005e3e:	e0ca                	sd	s2,64(sp)
    80005e40:	fc4e                	sd	s3,56(sp)
    80005e42:	f852                	sd	s4,48(sp)
    80005e44:	f456                	sd	s5,40(sp)
    80005e46:	f05a                	sd	s6,32(sp)
    80005e48:	ec5e                	sd	s7,24(sp)
    80005e4a:	e862                	sd	s8,16(sp)
    80005e4c:	1080                	addi	s0,sp,96
    80005e4e:	89aa                	mv	s3,a0
    80005e50:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005e52:	00c52b83          	lw	s7,12(a0)
    80005e56:	001b9b9b          	slliw	s7,s7,0x1
    80005e5a:	1b82                	slli	s7,s7,0x20
    80005e5c:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005e60:	0001f517          	auipc	a0,0x1f
    80005e64:	df050513          	addi	a0,a0,-528 # 80024c50 <disk+0x128>
    80005e68:	dc1fa0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005e6c:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005e6e:	0001fa97          	auipc	s5,0x1f
    80005e72:	cbaa8a93          	addi	s5,s5,-838 # 80024b28 <disk>
  for (int i = 0; i < 3; i++) {
    80005e76:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005e78:	5c7d                	li	s8,-1
    80005e7a:	a8a5                	j	80005ef2 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005e7c:	00fa8733          	add	a4,s5,a5
    80005e80:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005e84:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005e86:	0207c563          	bltz	a5,80005eb0 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005e8a:	2905                	addiw	s2,s2,1
    80005e8c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005e8e:	07490663          	beq	s2,s4,80005efa <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005e92:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005e94:	0001f717          	auipc	a4,0x1f
    80005e98:	c9470713          	addi	a4,a4,-876 # 80024b28 <disk>
    80005e9c:	4781                	li	a5,0
    if (disk.free[i]) {
    80005e9e:	01874683          	lbu	a3,24(a4)
    80005ea2:	fee9                	bnez	a3,80005e7c <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005ea4:	2785                	addiw	a5,a5,1
    80005ea6:	0705                	addi	a4,a4,1
    80005ea8:	fe979be3          	bne	a5,s1,80005e9e <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005eac:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005eb0:	01205d63          	blez	s2,80005eca <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005eb4:	fa042503          	lw	a0,-96(s0)
    80005eb8:	d41ff0ef          	jal	80005bf8 <free_desc>
      for (int j = 0; j < i; j++)
    80005ebc:	4785                	li	a5,1
    80005ebe:	0127d663          	bge	a5,s2,80005eca <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005ec2:	fa442503          	lw	a0,-92(s0)
    80005ec6:	d33ff0ef          	jal	80005bf8 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005eca:	0001f517          	auipc	a0,0x1f
    80005ece:	c7650513          	addi	a0,a0,-906 # 80024b40 <disk+0x18>
    80005ed2:	a6afc0ef          	jal	8000213c <sleep_prepare>
    release(&disk.vdisk_lock);
    80005ed6:	0001f517          	auipc	a0,0x1f
    80005eda:	d7a50513          	addi	a0,a0,-646 # 80024c50 <disk+0x128>
    80005ede:	dd3fa0ef          	jal	80000cb0 <release>
    sleep();
    80005ee2:	a96fc0ef          	jal	80002178 <sleep>
    acquire(&disk.vdisk_lock);
    80005ee6:	0001f517          	auipc	a0,0x1f
    80005eea:	d6a50513          	addi	a0,a0,-662 # 80024c50 <disk+0x128>
    80005eee:	d3bfa0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005ef2:	fa040613          	addi	a2,s0,-96
    80005ef6:	4901                	li	s2,0
    80005ef8:	bf69                	j	80005e92 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005efa:	fa042503          	lw	a0,-96(s0)
    80005efe:	00451693          	slli	a3,a0,0x4

  if (write)
    80005f02:	0001f797          	auipc	a5,0x1f
    80005f06:	c2678793          	addi	a5,a5,-986 # 80024b28 <disk>
    80005f0a:	00451713          	slli	a4,a0,0x4
    80005f0e:	0a070713          	addi	a4,a4,160
    80005f12:	973e                	add	a4,a4,a5
    80005f14:	01603633          	snez	a2,s6
    80005f18:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005f1a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005f1e:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005f22:	6398                	ld	a4,0(a5)
    80005f24:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005f26:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005f2a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005f2c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005f2e:	6390                	ld	a2,0(a5)
    80005f30:	00d60833          	add	a6,a2,a3
    80005f34:	4741                	li	a4,16
    80005f36:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005f3a:	4585                	li	a1,1
    80005f3c:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005f40:	fa442703          	lw	a4,-92(s0)
    80005f44:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005f48:	0712                	slli	a4,a4,0x4
    80005f4a:	963a                	add	a2,a2,a4
    80005f4c:	05898813          	addi	a6,s3,88
    80005f50:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005f54:	0007b883          	ld	a7,0(a5)
    80005f58:	9746                	add	a4,a4,a7
    80005f5a:	40000613          	li	a2,1024
    80005f5e:	c710                	sw	a2,8(a4)
  if (write)
    80005f60:	001b3613          	seqz	a2,s6
    80005f64:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005f68:	8e4d                	or	a2,a2,a1
    80005f6a:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005f6e:	fa842603          	lw	a2,-88(s0)
    80005f72:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005f76:	00451813          	slli	a6,a0,0x4
    80005f7a:	02080813          	addi	a6,a6,32
    80005f7e:	983e                	add	a6,a6,a5
    80005f80:	577d                	li	a4,-1
    80005f82:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005f86:	0612                	slli	a2,a2,0x4
    80005f88:	98b2                	add	a7,a7,a2
    80005f8a:	03068713          	addi	a4,a3,48
    80005f8e:	973e                	add	a4,a4,a5
    80005f90:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005f94:	6398                	ld	a4,0(a5)
    80005f96:	9732                	add	a4,a4,a2
    80005f98:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005f9a:	4689                	li	a3,2
    80005f9c:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005fa0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005fa4:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005fa8:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005fac:	6794                	ld	a3,8(a5)
    80005fae:	0026d703          	lhu	a4,2(a3)
    80005fb2:	8b1d                	andi	a4,a4,7
    80005fb4:	0706                	slli	a4,a4,0x1
    80005fb6:	96ba                	add	a3,a3,a4
    80005fb8:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005fbc:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005fc0:	6798                	ld	a4,8(a5)
    80005fc2:	00275783          	lhu	a5,2(a4)
    80005fc6:	2785                	addiw	a5,a5,1
    80005fc8:	00f71123          	sh	a5,2(a4)
    80005fcc:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005fd0:	100017b7          	lui	a5,0x10001
    80005fd4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005fd8:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005fdc:	0001f497          	auipc	s1,0x1f
    80005fe0:	c7448493          	addi	s1,s1,-908 # 80024c50 <disk+0x128>
  while (b->disk == 1) {
    80005fe4:	892e                	mv	s2,a1
    80005fe6:	02b79163          	bne	a5,a1,80006008 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005fea:	854e                	mv	a0,s3
    80005fec:	950fc0ef          	jal	8000213c <sleep_prepare>
    release(&disk.vdisk_lock);
    80005ff0:	8526                	mv	a0,s1
    80005ff2:	cbffa0ef          	jal	80000cb0 <release>
    sleep();
    80005ff6:	982fc0ef          	jal	80002178 <sleep>
    acquire(&disk.vdisk_lock);
    80005ffa:	8526                	mv	a0,s1
    80005ffc:	c2dfa0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80006000:	0049a783          	lw	a5,4(s3)
    80006004:	ff2783e3          	beq	a5,s2,80005fea <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80006008:	fa042903          	lw	s2,-96(s0)
    8000600c:	00491713          	slli	a4,s2,0x4
    80006010:	02070713          	addi	a4,a4,32
    80006014:	0001f797          	auipc	a5,0x1f
    80006018:	b1478793          	addi	a5,a5,-1260 # 80024b28 <disk>
    8000601c:	97ba                	add	a5,a5,a4
    8000601e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006022:	0001f997          	auipc	s3,0x1f
    80006026:	b0698993          	addi	s3,s3,-1274 # 80024b28 <disk>
    8000602a:	00491713          	slli	a4,s2,0x4
    8000602e:	0009b783          	ld	a5,0(s3)
    80006032:	97ba                	add	a5,a5,a4
    80006034:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006038:	854a                	mv	a0,s2
    8000603a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000603e:	bbbff0ef          	jal	80005bf8 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80006042:	8885                	andi	s1,s1,1
    80006044:	f0fd                	bnez	s1,8000602a <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006046:	0001f517          	auipc	a0,0x1f
    8000604a:	c0a50513          	addi	a0,a0,-1014 # 80024c50 <disk+0x128>
    8000604e:	c63fa0ef          	jal	80000cb0 <release>
}
    80006052:	60e6                	ld	ra,88(sp)
    80006054:	6446                	ld	s0,80(sp)
    80006056:	64a6                	ld	s1,72(sp)
    80006058:	6906                	ld	s2,64(sp)
    8000605a:	79e2                	ld	s3,56(sp)
    8000605c:	7a42                	ld	s4,48(sp)
    8000605e:	7aa2                	ld	s5,40(sp)
    80006060:	7b02                	ld	s6,32(sp)
    80006062:	6be2                	ld	s7,24(sp)
    80006064:	6c42                	ld	s8,16(sp)
    80006066:	6125                	addi	sp,sp,96
    80006068:	8082                	ret

000000008000606a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000606a:	1101                	addi	sp,sp,-32
    8000606c:	ec06                	sd	ra,24(sp)
    8000606e:	e822                	sd	s0,16(sp)
    80006070:	e426                	sd	s1,8(sp)
    80006072:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006074:	0001f497          	auipc	s1,0x1f
    80006078:	ab448493          	addi	s1,s1,-1356 # 80024b28 <disk>
    8000607c:	0001f517          	auipc	a0,0x1f
    80006080:	bd450513          	addi	a0,a0,-1068 # 80024c50 <disk+0x128>
    80006084:	ba5fa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006088:	100017b7          	lui	a5,0x10001
    8000608c:	53bc                	lw	a5,96(a5)
    8000608e:	8b8d                	andi	a5,a5,3
    80006090:	10001737          	lui	a4,0x10001
    80006094:	d37c                	sw	a5,100(a4)
    80006096:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    8000609a:	689c                	ld	a5,16(s1)
    8000609c:	0204d703          	lhu	a4,32(s1)
    800060a0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800060a4:	04f70863          	beq	a4,a5,800060f4 <virtio_disk_intr+0x8a>
    800060a8:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800060ac:	6898                	ld	a4,16(s1)
    800060ae:	0204d783          	lhu	a5,32(s1)
    800060b2:	8b9d                	andi	a5,a5,7
    800060b4:	078e                	slli	a5,a5,0x3
    800060b6:	97ba                	add	a5,a5,a4
    800060b8:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    800060ba:	00479713          	slli	a4,a5,0x4
    800060be:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    800060c2:	9726                	add	a4,a4,s1
    800060c4:	01074703          	lbu	a4,16(a4)
    800060c8:	e329                	bnez	a4,8000610a <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800060ca:	0792                	slli	a5,a5,0x4
    800060cc:	02078793          	addi	a5,a5,32
    800060d0:	97a6                	add	a5,a5,s1
    800060d2:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    800060d4:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800060d8:	8d0fc0ef          	jal	800021a8 <wakeup>

    disk.used_idx += 1;
    800060dc:	0204d783          	lhu	a5,32(s1)
    800060e0:	2785                	addiw	a5,a5,1
    800060e2:	17c2                	slli	a5,a5,0x30
    800060e4:	93c1                	srli	a5,a5,0x30
    800060e6:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    800060ea:	6898                	ld	a4,16(s1)
    800060ec:	00275703          	lhu	a4,2(a4)
    800060f0:	faf71ce3          	bne	a4,a5,800060a8 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800060f4:	0001f517          	auipc	a0,0x1f
    800060f8:	b5c50513          	addi	a0,a0,-1188 # 80024c50 <disk+0x128>
    800060fc:	bb5fa0ef          	jal	80000cb0 <release>
}
    80006100:	60e2                	ld	ra,24(sp)
    80006102:	6442                	ld	s0,16(sp)
    80006104:	64a2                	ld	s1,8(sp)
    80006106:	6105                	addi	sp,sp,32
    80006108:	8082                	ret
      panic("virtio_disk_intr status");
    8000610a:	00002517          	auipc	a0,0x2
    8000610e:	61650513          	addi	a0,a0,1558 # 80008720 <etext+0x720>
    80006112:	f22fa0ef          	jal	80000834 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	9282                	jalr	t0

000000008000709c <userret>:
    8000709c:	0000100f          	fence.i
    800070a0:	12000073          	sfence.vma
    800070a4:	18051073          	csrw	satp,a0
    800070a8:	12000073          	sfence.vma
    800070ac:	02000537          	lui	a0,0x2000
    800070b0:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070b2:	0536                	slli	a0,a0,0xd
    800070b4:	02853083          	ld	ra,40(a0)
    800070b8:	03053103          	ld	sp,48(a0)
    800070bc:	03853183          	ld	gp,56(a0)
    800070c0:	04053203          	ld	tp,64(a0)
    800070c4:	04853283          	ld	t0,72(a0)
    800070c8:	05053303          	ld	t1,80(a0)
    800070cc:	05853383          	ld	t2,88(a0)
    800070d0:	7120                	ld	s0,96(a0)
    800070d2:	7524                	ld	s1,104(a0)
    800070d4:	7d2c                	ld	a1,120(a0)
    800070d6:	6150                	ld	a2,128(a0)
    800070d8:	6554                	ld	a3,136(a0)
    800070da:	6958                	ld	a4,144(a0)
    800070dc:	6d5c                	ld	a5,152(a0)
    800070de:	0a053803          	ld	a6,160(a0)
    800070e2:	0a853883          	ld	a7,168(a0)
    800070e6:	0b053903          	ld	s2,176(a0)
    800070ea:	0b853983          	ld	s3,184(a0)
    800070ee:	0c053a03          	ld	s4,192(a0)
    800070f2:	0c853a83          	ld	s5,200(a0)
    800070f6:	0d053b03          	ld	s6,208(a0)
    800070fa:	0d853b83          	ld	s7,216(a0)
    800070fe:	0e053c03          	ld	s8,224(a0)
    80007102:	0e853c83          	ld	s9,232(a0)
    80007106:	0f053d03          	ld	s10,240(a0)
    8000710a:	0f853d83          	ld	s11,248(a0)
    8000710e:	10053e03          	ld	t3,256(a0)
    80007112:	10853e83          	ld	t4,264(a0)
    80007116:	11053f03          	ld	t5,272(a0)
    8000711a:	11853f83          	ld	t6,280(a0)
    8000711e:	7928                	ld	a0,112(a0)
    80007120:	10200073          	sret
	...
