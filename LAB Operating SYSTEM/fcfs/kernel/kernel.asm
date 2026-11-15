
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
    80000004:	2a813103          	ld	sp,680(sp) # 8000a2a8 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb007>
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
    8000011c:	25a020ef          	jal	80002376 <either_copyin>
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
    80000198:	15c50513          	addi	a0,a0,348 # 800122f0 <cons>
    8000019c:	28d000ef          	jal	80000c28 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	15048493          	addi	s1,s1,336 # 800122f0 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	1e090913          	addi	s2,s2,480 # 80012388 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	788010ef          	jal	80001948 <myproc>
    800001c4:	032020ef          	jal	800021f6 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	5cd010ef          	jal	80001f98 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	5ff010ef          	jal	80001fd4 <sleep>
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
    800001f2:	10270713          	addi	a4,a4,258 # 800122f0 <cons>
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
    80000220:	10a020ef          	jal	8000232a <either_copyout>
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
    8000023c:	0b850513          	addi	a0,a0,184 # 800122f0 <cons>
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
    80000262:	12f72523          	sw	a5,298(a4) # 80012388 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	07c50513          	addi	a0,a0,124 # 800122f0 <cons>
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
    800002cc:	02850513          	addi	a0,a0,40 # 800122f0 <cons>
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
    800002ea:	0d8020ef          	jal	800023c2 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	00250513          	addi	a0,a0,2 # 800122f0 <cons>
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
    80000310:	fe470713          	addi	a4,a4,-28 # 800122f0 <cons>
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
    80000336:	fbe70713          	addi	a4,a4,-66 # 800122f0 <cons>
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
    80000360:	02c72703          	lw	a4,44(a4) # 80012388 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	f7e70713          	addi	a4,a4,-130 # 800122f0 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	f6e48493          	addi	s1,s1,-146 # 800122f0 <cons>
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
    800003c8:	f2c70713          	addi	a4,a4,-212 # 800122f0 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	faf72b23          	sw	a5,-74(a4) # 80012390 <cons+0xa0>
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
    800003fc:	ef878793          	addi	a5,a5,-264 # 800122f0 <cons>
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
    8000041e:	f6c7a923          	sw	a2,-142(a5) # 8001238c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	f6650513          	addi	a0,a0,-154 # 80012388 <cons+0x98>
    8000042a:	3db010ef          	jal	80002004 <wakeup>
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
    80000444:	eb050513          	addi	a0,a0,-336 # 800122f0 <cons>
    80000448:	760000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	21078793          	addi	a5,a5,528 # 80022660 <devsw>
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
    8000052c:	d9c7a783          	lw	a5,-612(a5) # 8000a2c4 <panicking>
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
    80000572:	e2a50513          	addi	a0,a0,-470 # 80012398 <pr>
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
    8000076e:	b5a7a783          	lw	a5,-1190(a5) # 8000a2c4 <panicking>
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
    80000798:	c0450513          	addi	a0,a0,-1020 # 80012398 <pr>
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
    80000848:	a897a023          	sw	s1,-1408(a5) # 8000a2c4 <panicking>
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
    8000086a:	a497ad23          	sw	s1,-1446(a5) # 8000a2c0 <panicked>
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
    80000884:	b1850513          	addi	a0,a0,-1256 # 80012398 <pr>
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
    800008da:	ada50513          	addi	a0,a0,-1318 # 800123b0 <tx_lock>
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
    800008fe:	ab650513          	addi	a0,a0,-1354 # 800123b0 <tx_lock>
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
    8000091c:	9b490913          	addi	s2,s2,-1612 # 8000a2cc <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	9a898993          	addi	s3,s3,-1624 # 8000a2c8 <tx_chan>
      release(&tx_lock);
    80000928:	00012497          	auipc	s1,0x12
    8000092c:	a8848493          	addi	s1,s1,-1400 # 800123b0 <tx_lock>
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
    8000093a:	65e010ef          	jal	80001f98 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	690010ef          	jal	80001fd4 <sleep>
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
    8000097c:	a3850513          	addi	a0,a0,-1480 # 800123b0 <tx_lock>
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
    800009a0:	9287a783          	lw	a5,-1752(a5) # 8000a2c4 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	91a7a783          	lw	a5,-1766(a5) # 8000a2c0 <panicked>
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
    800009d0:	8f87a783          	lw	a5,-1800(a5) # 8000a2c4 <panicking>
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
    80000a06:	9ae50513          	addi	a0,a0,-1618 # 800123b0 <tx_lock>
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
    80000a20:	99450513          	addi	a0,a0,-1644 # 800123b0 <tx_lock>
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
    80000a48:	8807a423          	sw	zero,-1912(a5) # 8000a2cc <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	87c50513          	addi	a0,a0,-1924 # 8000a2c8 <tx_chan>
    80000a54:	5b0010ef          	jal	80002004 <wakeup>
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
    80000a76:	d8678793          	addi	a5,a5,-634 # 800237f8 <end>
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
    80000aa0:	92c90913          	addi	s2,s2,-1748 # 800123c8 <kmem>
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
    80000b2e:	89e50513          	addi	a0,a0,-1890 # 800123c8 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00023517          	auipc	a0,0x23
    80000b3e:	cbe50513          	addi	a0,a0,-834 # 800237f8 <end>
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
    80000b5c:	87050513          	addi	a0,a0,-1936 # 800123c8 <kmem>
    80000b60:	0c8000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b64:	00012497          	auipc	s1,0x12
    80000b68:	87c4b483          	ld	s1,-1924(s1) # 800123e0 <kmem+0x18>
  if (r)
    80000b6c:	c49d                	beqz	s1,80000b9a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00012717          	auipc	a4,0x12
    80000b74:	86f73823          	sd	a5,-1936(a4) # 800123e0 <kmem+0x18>
  release(&kmem.lock);
    80000b78:	00012517          	auipc	a0,0x12
    80000b7c:	85050513          	addi	a0,a0,-1968 # 800123c8 <kmem>
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
    80000b9e:	82e50513          	addi	a0,a0,-2002 # 800123c8 <kmem>
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
    80000eae:	42670713          	addi	a4,a4,1062 # 8000a2d0 <started>
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
    80000ed4:	620010ef          	jal	800024f4 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	7e0040ef          	jal	800056b8 <plicinithart>
  }

  scheduler();
    80000edc:	703000ef          	jal	80001dde <scheduler>
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
    80000f1c:	5b4010ef          	jal	800024d0 <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	5d4010ef          	jal	800024f4 <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	77a040ef          	jal	8000569e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	790040ef          	jal	800056b8 <plicinithart>
    binit();            // buffer cache
    80000f2c:	439010ef          	jal	80002b64 <binit>
    iinit();            // inode table
    80000f30:	18a020ef          	jal	800030ba <iinit>
    fileinit();         // file table
    80000f34:	1b8030ef          	jal	800040ec <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	077040ef          	jal	800057ae <virtio_disk_init>
    userinit();         // first user process
    80000f3c:	4f7000ef          	jal	80001c32 <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f40:	00009797          	auipc	a5,0x9
    80000f44:	39078793          	addi	a5,a5,912 # 8000a2d0 <started>
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
    80000f62:	37a7b783          	ld	a5,890(a5) # 8000a2d8 <kernel_pagetable>
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
    800011ee:	0ea7b723          	sd	a0,238(a5) # 8000a2d8 <kernel_pagetable>
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
    80001724:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb808>
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
    800017d8:	04448493          	addi	s1,s1,68 # 80012818 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017dc:	8c26                	mv	s8,s1
    800017de:	ff4df937          	lui	s2,0xff4df
    800017e2:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb1c5>
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
    80001808:	c14a8a93          	addi	s5,s5,-1004 # 80018418 <tickslock>
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
    8000187e:	b6e50513          	addi	a0,a0,-1170 # 800123e8 <pid_lock>
    80001882:	b26ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001886:	00006597          	auipc	a1,0x6
    8000188a:	8e258593          	addi	a1,a1,-1822 # 80007168 <etext+0x168>
    8000188e:	00011517          	auipc	a0,0x11
    80001892:	b7250513          	addi	a0,a0,-1166 # 80012400 <wait_lock>
    80001896:	b12ff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000189a:	00011497          	auipc	s1,0x11
    8000189e:	f7e48493          	addi	s1,s1,-130 # 80012818 <proc>
    initlock(&p->lock, "proc");
    800018a2:	00006b17          	auipc	s6,0x6
    800018a6:	8d6b0b13          	addi	s6,s6,-1834 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018aa:	8aa6                	mv	s5,s1
    800018ac:	ff4df937          	lui	s2,0xff4df
    800018b0:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb1c5>
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
    800018d2:	b4aa0a13          	addi	s4,s4,-1206 # 80018418 <tickslock>
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
    8000193a:	ae250513          	addi	a0,a0,-1310 # 80012418 <cpus>
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
    80001960:	a8c70713          	addi	a4,a4,-1396 # 800123e8 <pid_lock>
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
    80001992:	9027a783          	lw	a5,-1790(a5) # 8000a290 <first.1>
    80001996:	cf85                	beqz	a5,800019ce <forkret+0x54>
    first = 0;
    80001998:	00009797          	auipc	a5,0x9
    8000199c:	8e07ac23          	sw	zero,-1800(a5) # 8000a290 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019a0:	4505                	li	a0,1
    800019a2:	41d010ef          	jal	800035be <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019a6:	00005797          	auipc	a5,0x5
    800019aa:	7da78793          	addi	a5,a5,2010 # 80007180 <etext+0x180>
    800019ae:	fcf43823          	sd	a5,-48(s0)
    800019b2:	fc043c23          	sd	zero,-40(s0)
    800019b6:	fd040593          	addi	a1,s0,-48
    800019ba:	853e                	mv	a0,a5
    800019bc:	6b7020ef          	jal	80004872 <kexec>
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
    800019ce:	343000ef          	jal	80002510 <prepare_return>
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
    80001a1e:	9ce50513          	addi	a0,a0,-1586 # 800123e8 <pid_lock>
    80001a22:	a06ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a26:	00009797          	auipc	a5,0x9
    80001a2a:	86e78793          	addi	a5,a5,-1938 # 8000a294 <nextpid>
    80001a2e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a30:	0014871b          	addiw	a4,s1,1
    80001a34:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a36:	00011517          	auipc	a0,0x11
    80001a3a:	9b250513          	addi	a0,a0,-1614 # 800123e8 <pid_lock>
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
  p->ctime = 0;
    80001b5a:	1604a423          	sw	zero,360(s1)
}
    80001b5e:	60e2                	ld	ra,24(sp)
    80001b60:	6442                	ld	s0,16(sp)
    80001b62:	64a2                	ld	s1,8(sp)
    80001b64:	6105                	addi	sp,sp,32
    80001b66:	8082                	ret

0000000080001b68 <allocproc>:
{
    80001b68:	1101                	addi	sp,sp,-32
    80001b6a:	ec06                	sd	ra,24(sp)
    80001b6c:	e822                	sd	s0,16(sp)
    80001b6e:	e426                	sd	s1,8(sp)
    80001b70:	e04a                	sd	s2,0(sp)
    80001b72:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b74:	00011497          	auipc	s1,0x11
    80001b78:	ca448493          	addi	s1,s1,-860 # 80012818 <proc>
    80001b7c:	00017917          	auipc	s2,0x17
    80001b80:	89c90913          	addi	s2,s2,-1892 # 80018418 <tickslock>
    acquire(&p->lock);
    80001b84:	8526                	mv	a0,s1
    80001b86:	8a2ff0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001b8a:	4c9c                	lw	a5,24(s1)
    80001b8c:	cb91                	beqz	a5,80001ba0 <allocproc+0x38>
      release(&p->lock);
    80001b8e:	8526                	mv	a0,s1
    80001b90:	920ff0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b94:	17048493          	addi	s1,s1,368
    80001b98:	ff2496e3          	bne	s1,s2,80001b84 <allocproc+0x1c>
  return 0;
    80001b9c:	4481                	li	s1,0
    80001b9e:	a09d                	j	80001c04 <allocproc+0x9c>
  p->pid = allocpid();
    80001ba0:	e71ff0ef          	jal	80001a10 <allocpid>
    80001ba4:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ba6:	4785                	li	a5,1
    80001ba8:	cc9c                	sw	a5,24(s1)
  acquire(&tickslock);
    80001baa:	00017517          	auipc	a0,0x17
    80001bae:	86e50513          	addi	a0,a0,-1938 # 80018418 <tickslock>
    80001bb2:	876ff0ef          	jal	80000c28 <acquire>
  p->ctime = ticks;
    80001bb6:	00008797          	auipc	a5,0x8
    80001bba:	7327a783          	lw	a5,1842(a5) # 8000a2e8 <ticks>
    80001bbe:	16f4a423          	sw	a5,360(s1)
  release(&tickslock);
    80001bc2:	00017517          	auipc	a0,0x17
    80001bc6:	85650513          	addi	a0,a0,-1962 # 80018418 <tickslock>
    80001bca:	8e6ff0ef          	jal	80000cb0 <release>
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bce:	f81fe0ef          	jal	80000b4e <kalloc>
    80001bd2:	892a                	mv	s2,a0
    80001bd4:	eca8                	sd	a0,88(s1)
    80001bd6:	cd15                	beqz	a0,80001c12 <allocproc+0xaa>
  p->pagetable = proc_pagetable(p);
    80001bd8:	8526                	mv	a0,s1
    80001bda:	e75ff0ef          	jal	80001a4e <proc_pagetable>
    80001bde:	892a                	mv	s2,a0
    80001be0:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001be2:	c121                	beqz	a0,80001c22 <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001be4:	07000613          	li	a2,112
    80001be8:	4581                	li	a1,0
    80001bea:	06048513          	addi	a0,s1,96
    80001bee:	8faff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001bf2:	00000797          	auipc	a5,0x0
    80001bf6:	d8878793          	addi	a5,a5,-632 # 8000197a <forkret>
    80001bfa:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bfc:	60bc                	ld	a5,64(s1)
    80001bfe:	6705                	lui	a4,0x1
    80001c00:	97ba                	add	a5,a5,a4
    80001c02:	f4bc                	sd	a5,104(s1)
}
    80001c04:	8526                	mv	a0,s1
    80001c06:	60e2                	ld	ra,24(sp)
    80001c08:	6442                	ld	s0,16(sp)
    80001c0a:	64a2                	ld	s1,8(sp)
    80001c0c:	6902                	ld	s2,0(sp)
    80001c0e:	6105                	addi	sp,sp,32
    80001c10:	8082                	ret
    freeproc(p);
    80001c12:	8526                	mv	a0,s1
    80001c14:	f05ff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001c18:	8526                	mv	a0,s1
    80001c1a:	896ff0ef          	jal	80000cb0 <release>
    return 0;
    80001c1e:	84ca                	mv	s1,s2
    80001c20:	b7d5                	j	80001c04 <allocproc+0x9c>
    freeproc(p);
    80001c22:	8526                	mv	a0,s1
    80001c24:	ef5ff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001c28:	8526                	mv	a0,s1
    80001c2a:	886ff0ef          	jal	80000cb0 <release>
    return 0;
    80001c2e:	84ca                	mv	s1,s2
    80001c30:	bfd1                	j	80001c04 <allocproc+0x9c>

0000000080001c32 <userinit>:
{
    80001c32:	1101                	addi	sp,sp,-32
    80001c34:	ec06                	sd	ra,24(sp)
    80001c36:	e822                	sd	s0,16(sp)
    80001c38:	e426                	sd	s1,8(sp)
    80001c3a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c3c:	f2dff0ef          	jal	80001b68 <allocproc>
    80001c40:	84aa                	mv	s1,a0
  initproc = p;
    80001c42:	00008797          	auipc	a5,0x8
    80001c46:	68a7bf23          	sd	a0,1694(a5) # 8000a2e0 <initproc>
  p->cwd = namei("/");
    80001c4a:	00005517          	auipc	a0,0x5
    80001c4e:	54650513          	addi	a0,a0,1350 # 80007190 <etext+0x190>
    80001c52:	6cb010ef          	jal	80003b1c <namei>
    80001c56:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c5a:	478d                	li	a5,3
    80001c5c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	850ff0ef          	jal	80000cb0 <release>
}
    80001c64:	60e2                	ld	ra,24(sp)
    80001c66:	6442                	ld	s0,16(sp)
    80001c68:	64a2                	ld	s1,8(sp)
    80001c6a:	6105                	addi	sp,sp,32
    80001c6c:	8082                	ret

0000000080001c6e <growproc>:
{
    80001c6e:	1101                	addi	sp,sp,-32
    80001c70:	ec06                	sd	ra,24(sp)
    80001c72:	e822                	sd	s0,16(sp)
    80001c74:	e426                	sd	s1,8(sp)
    80001c76:	e04a                	sd	s2,0(sp)
    80001c78:	1000                	addi	s0,sp,32
    80001c7a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c7c:	ccdff0ef          	jal	80001948 <myproc>
    80001c80:	892a                	mv	s2,a0
  sz = p->sz;
    80001c82:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c84:	02905963          	blez	s1,80001cb6 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c88:	00b48633          	add	a2,s1,a1
    80001c8c:	020007b7          	lui	a5,0x2000
    80001c90:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c92:	07b6                	slli	a5,a5,0xd
    80001c94:	02c7ea63          	bltu	a5,a2,80001cc8 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c98:	4691                	li	a3,4
    80001c9a:	6928                	ld	a0,80(a0)
    80001c9c:	e52ff0ef          	jal	800012ee <uvmalloc>
    80001ca0:	85aa                	mv	a1,a0
    80001ca2:	c50d                	beqz	a0,80001ccc <growproc+0x5e>
  p->sz = sz;
    80001ca4:	04b93423          	sd	a1,72(s2)
  return 0;
    80001ca8:	4501                	li	a0,0
}
    80001caa:	60e2                	ld	ra,24(sp)
    80001cac:	6442                	ld	s0,16(sp)
    80001cae:	64a2                	ld	s1,8(sp)
    80001cb0:	6902                	ld	s2,0(sp)
    80001cb2:	6105                	addi	sp,sp,32
    80001cb4:	8082                	ret
  } else if (n < 0) {
    80001cb6:	fe04d7e3          	bgez	s1,80001ca4 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001cba:	00b48633          	add	a2,s1,a1
    80001cbe:	6928                	ld	a0,80(a0)
    80001cc0:	deaff0ef          	jal	800012aa <uvmdealloc>
    80001cc4:	85aa                	mv	a1,a0
    80001cc6:	bff9                	j	80001ca4 <growproc+0x36>
      return -1;
    80001cc8:	557d                	li	a0,-1
    80001cca:	b7c5                	j	80001caa <growproc+0x3c>
      return -1;
    80001ccc:	557d                	li	a0,-1
    80001cce:	bff1                	j	80001caa <growproc+0x3c>

0000000080001cd0 <kfork>:
{
    80001cd0:	7139                	addi	sp,sp,-64
    80001cd2:	fc06                	sd	ra,56(sp)
    80001cd4:	f822                	sd	s0,48(sp)
    80001cd6:	f426                	sd	s1,40(sp)
    80001cd8:	e456                	sd	s5,8(sp)
    80001cda:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cdc:	c6dff0ef          	jal	80001948 <myproc>
    80001ce0:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001ce2:	e87ff0ef          	jal	80001b68 <allocproc>
    80001ce6:	0e050a63          	beqz	a0,80001dda <kfork+0x10a>
    80001cea:	e852                	sd	s4,16(sp)
    80001cec:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001cee:	048ab603          	ld	a2,72(s5)
    80001cf2:	692c                	ld	a1,80(a0)
    80001cf4:	050ab503          	ld	a0,80(s5)
    80001cf8:	f2eff0ef          	jal	80001426 <uvmcopy>
    80001cfc:	04054863          	bltz	a0,80001d4c <kfork+0x7c>
    80001d00:	f04a                	sd	s2,32(sp)
    80001d02:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d04:	048ab783          	ld	a5,72(s5)
    80001d08:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d0c:	058ab683          	ld	a3,88(s5)
    80001d10:	87b6                	mv	a5,a3
    80001d12:	058a3703          	ld	a4,88(s4)
    80001d16:	12068693          	addi	a3,a3,288
    80001d1a:	6388                	ld	a0,0(a5)
    80001d1c:	678c                	ld	a1,8(a5)
    80001d1e:	6b90                	ld	a2,16(a5)
    80001d20:	e308                	sd	a0,0(a4)
    80001d22:	e70c                	sd	a1,8(a4)
    80001d24:	eb10                	sd	a2,16(a4)
    80001d26:	6f90                	ld	a2,24(a5)
    80001d28:	ef10                	sd	a2,24(a4)
    80001d2a:	02078793          	addi	a5,a5,32
    80001d2e:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d32:	fed794e3          	bne	a5,a3,80001d1a <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d36:	058a3783          	ld	a5,88(s4)
    80001d3a:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d3e:	0d0a8493          	addi	s1,s5,208
    80001d42:	0d0a0913          	addi	s2,s4,208
    80001d46:	150a8993          	addi	s3,s5,336
    80001d4a:	a831                	j	80001d66 <kfork+0x96>
    freeproc(np);
    80001d4c:	8552                	mv	a0,s4
    80001d4e:	dcbff0ef          	jal	80001b18 <freeproc>
    release(&np->lock);
    80001d52:	8552                	mv	a0,s4
    80001d54:	f5dfe0ef          	jal	80000cb0 <release>
    return -1;
    80001d58:	54fd                	li	s1,-1
    80001d5a:	6a42                	ld	s4,16(sp)
    80001d5c:	a885                	j	80001dcc <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d5e:	04a1                	addi	s1,s1,8
    80001d60:	0921                	addi	s2,s2,8
    80001d62:	01348963          	beq	s1,s3,80001d74 <kfork+0xa4>
    if (p->ofile[i])
    80001d66:	6088                	ld	a0,0(s1)
    80001d68:	d97d                	beqz	a0,80001d5e <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d6a:	404020ef          	jal	8000416e <filedup>
    80001d6e:	00a93023          	sd	a0,0(s2)
    80001d72:	b7f5                	j	80001d5e <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d74:	150ab503          	ld	a0,336(s5)
    80001d78:	4d4010ef          	jal	8000324c <idup>
    80001d7c:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d80:	4641                	li	a2,16
    80001d82:	158a8593          	addi	a1,s5,344
    80001d86:	158a0513          	addi	a0,s4,344
    80001d8a:	8b2ff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001d8e:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d92:	8552                	mv	a0,s4
    80001d94:	f1dfe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001d98:	00010517          	auipc	a0,0x10
    80001d9c:	66850513          	addi	a0,a0,1640 # 80012400 <wait_lock>
    80001da0:	e89fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001da4:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001da8:	00010517          	auipc	a0,0x10
    80001dac:	65850513          	addi	a0,a0,1624 # 80012400 <wait_lock>
    80001db0:	f01fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001db4:	8552                	mv	a0,s4
    80001db6:	e73fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001dba:	478d                	li	a5,3
    80001dbc:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001dc0:	8552                	mv	a0,s4
    80001dc2:	eeffe0ef          	jal	80000cb0 <release>
  return pid;
    80001dc6:	7902                	ld	s2,32(sp)
    80001dc8:	69e2                	ld	s3,24(sp)
    80001dca:	6a42                	ld	s4,16(sp)
}
    80001dcc:	8526                	mv	a0,s1
    80001dce:	70e2                	ld	ra,56(sp)
    80001dd0:	7442                	ld	s0,48(sp)
    80001dd2:	74a2                	ld	s1,40(sp)
    80001dd4:	6aa2                	ld	s5,8(sp)
    80001dd6:	6121                	addi	sp,sp,64
    80001dd8:	8082                	ret
    return -1;
    80001dda:	54fd                	li	s1,-1
    80001ddc:	bfc5                	j	80001dcc <kfork+0xfc>

0000000080001dde <scheduler>:
{
    80001dde:	715d                	addi	sp,sp,-80
    80001de0:	e486                	sd	ra,72(sp)
    80001de2:	e0a2                	sd	s0,64(sp)
    80001de4:	fc26                	sd	s1,56(sp)
    80001de6:	f84a                	sd	s2,48(sp)
    80001de8:	f44e                	sd	s3,40(sp)
    80001dea:	f052                	sd	s4,32(sp)
    80001dec:	ec56                	sd	s5,24(sp)
    80001dee:	e85a                	sd	s6,16(sp)
    80001df0:	e45e                	sd	s7,8(sp)
    80001df2:	e062                	sd	s8,0(sp)
    80001df4:	0880                	addi	s0,sp,80
    80001df6:	8792                	mv	a5,tp
  int id = r_tp();
    80001df8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001dfa:	00779b13          	slli	s6,a5,0x7
    80001dfe:	00010717          	auipc	a4,0x10
    80001e02:	5ea70713          	addi	a4,a4,1514 # 800123e8 <pid_lock>
    80001e06:	975a                	add	a4,a4,s6
    80001e08:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &earliest->context);
    80001e0c:	00010717          	auipc	a4,0x10
    80001e10:	61470713          	addi	a4,a4,1556 # 80012420 <cpus+0x8>
    80001e14:	9b3a                	add	s6,s6,a4
      if (p->state == RUNNABLE) {
    80001e16:	4a0d                	li	s4,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e18:	00016997          	auipc	s3,0x16
    80001e1c:	60098993          	addi	s3,s3,1536 # 80018418 <tickslock>
      earliest->state = RUNNING;
    80001e20:	4c11                	li	s8,4
      c->proc = earliest;
    80001e22:	00010b97          	auipc	s7,0x10
    80001e26:	5c6b8b93          	addi	s7,s7,1478 # 800123e8 <pid_lock>
    80001e2a:	079e                	slli	a5,a5,0x7
    80001e2c:	00fb8ab3          	add	s5,s7,a5
    80001e30:	a09d                	j	80001e96 <scheduler+0xb8>
      release(&p->lock);
    80001e32:	8526                	mv	a0,s1
    80001e34:	e7dfe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e38:	17048493          	addi	s1,s1,368
    80001e3c:	03348763          	beq	s1,s3,80001e6a <scheduler+0x8c>
      acquire(&p->lock);
    80001e40:	8526                	mv	a0,s1
    80001e42:	de7fe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001e46:	4c9c                	lw	a5,24(s1)
    80001e48:	ff4795e3          	bne	a5,s4,80001e32 <scheduler+0x54>
        if (earliest == 0 || p->ctime < earliest->ctime) {
    80001e4c:	00090d63          	beqz	s2,80001e66 <scheduler+0x88>
    80001e50:	1684a703          	lw	a4,360(s1)
    80001e54:	16892783          	lw	a5,360(s2)
    80001e58:	fcf77de3          	bgeu	a4,a5,80001e32 <scheduler+0x54>
            release(&earliest->lock);
    80001e5c:	854a                	mv	a0,s2
    80001e5e:	e53fe0ef          	jal	80000cb0 <release>
          earliest = p;
    80001e62:	8926                	mv	s2,s1
    80001e64:	bfd1                	j	80001e38 <scheduler+0x5a>
    80001e66:	8926                	mv	s2,s1
    80001e68:	bfc1                	j	80001e38 <scheduler+0x5a>
    if (earliest) {
    80001e6a:	04090063          	beqz	s2,80001eaa <scheduler+0xcc>
      earliest->state = RUNNING;
    80001e6e:	01892c23          	sw	s8,24(s2)
      c->proc = earliest;
    80001e72:	032ab823          	sd	s2,48(s5)
      swtch(&c->context, &earliest->context);
    80001e76:	06090593          	addi	a1,s2,96
    80001e7a:	855a                	mv	a0,s6
    80001e7c:	5ea000ef          	jal	80002466 <swtch>
    80001e80:	8792                	mv	a5,tp
      mycpu()->intena = 0;
    80001e82:	2781                	sext.w	a5,a5
    80001e84:	079e                	slli	a5,a5,0x7
    80001e86:	97de                	add	a5,a5,s7
    80001e88:	0a07a623          	sw	zero,172(a5)
      c->proc = 0;
    80001e8c:	020ab823          	sd	zero,48(s5)
      release(&earliest->lock);
    80001e90:	854a                	mv	a0,s2
    80001e92:	e1ffe0ef          	jal	80000cb0 <release>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001e96:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001e9a:	10017073          	csrci	sstatus,2
    struct proc *earliest = 0;
    80001e9e:	4901                	li	s2,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001ea0:	00011497          	auipc	s1,0x11
    80001ea4:	97848493          	addi	s1,s1,-1672 # 80012818 <proc>
    80001ea8:	bf61                	j	80001e40 <scheduler+0x62>
      asm volatile("wfi");
    80001eaa:	10500073          	wfi
    80001eae:	b7e5                	j	80001e96 <scheduler+0xb8>

0000000080001eb0 <sched>:
{
    80001eb0:	7179                	addi	sp,sp,-48
    80001eb2:	f406                	sd	ra,40(sp)
    80001eb4:	f022                	sd	s0,32(sp)
    80001eb6:	ec26                	sd	s1,24(sp)
    80001eb8:	e84a                	sd	s2,16(sp)
    80001eba:	e44e                	sd	s3,8(sp)
    80001ebc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ebe:	a8bff0ef          	jal	80001948 <myproc>
    80001ec2:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001ec4:	cfffe0ef          	jal	80000bc2 <holding>
    80001ec8:	c935                	beqz	a0,80001f3c <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001eca:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001ecc:	2781                	sext.w	a5,a5
    80001ece:	079e                	slli	a5,a5,0x7
    80001ed0:	00010717          	auipc	a4,0x10
    80001ed4:	51870713          	addi	a4,a4,1304 # 800123e8 <pid_lock>
    80001ed8:	97ba                	add	a5,a5,a4
    80001eda:	0a87a703          	lw	a4,168(a5)
    80001ede:	4785                	li	a5,1
    80001ee0:	06f71463          	bne	a4,a5,80001f48 <sched+0x98>
  if (p->state == RUNNING)
    80001ee4:	4c98                	lw	a4,24(s1)
    80001ee6:	4791                	li	a5,4
    80001ee8:	06f70663          	beq	a4,a5,80001f54 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001eec:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ef0:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001ef2:	e7bd                	bnez	a5,80001f60 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001ef4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001ef6:	00010917          	auipc	s2,0x10
    80001efa:	4f290913          	addi	s2,s2,1266 # 800123e8 <pid_lock>
    80001efe:	2781                	sext.w	a5,a5
    80001f00:	079e                	slli	a5,a5,0x7
    80001f02:	97ca                	add	a5,a5,s2
    80001f04:	0ac7a983          	lw	s3,172(a5)
    80001f08:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f0a:	2781                	sext.w	a5,a5
    80001f0c:	079e                	slli	a5,a5,0x7
    80001f0e:	07a1                	addi	a5,a5,8
    80001f10:	00010597          	auipc	a1,0x10
    80001f14:	50858593          	addi	a1,a1,1288 # 80012418 <cpus>
    80001f18:	95be                	add	a1,a1,a5
    80001f1a:	06048513          	addi	a0,s1,96
    80001f1e:	548000ef          	jal	80002466 <swtch>
    80001f22:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f24:	2781                	sext.w	a5,a5
    80001f26:	079e                	slli	a5,a5,0x7
    80001f28:	993e                	add	s2,s2,a5
    80001f2a:	0b392623          	sw	s3,172(s2)
}
    80001f2e:	70a2                	ld	ra,40(sp)
    80001f30:	7402                	ld	s0,32(sp)
    80001f32:	64e2                	ld	s1,24(sp)
    80001f34:	6942                	ld	s2,16(sp)
    80001f36:	69a2                	ld	s3,8(sp)
    80001f38:	6145                	addi	sp,sp,48
    80001f3a:	8082                	ret
    panic("sched p->lock");
    80001f3c:	00005517          	auipc	a0,0x5
    80001f40:	25c50513          	addi	a0,a0,604 # 80007198 <etext+0x198>
    80001f44:	8f1fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80001f48:	00005517          	auipc	a0,0x5
    80001f4c:	26050513          	addi	a0,a0,608 # 800071a8 <etext+0x1a8>
    80001f50:	8e5fe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80001f54:	00005517          	auipc	a0,0x5
    80001f58:	26450513          	addi	a0,a0,612 # 800071b8 <etext+0x1b8>
    80001f5c:	8d9fe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80001f60:	00005517          	auipc	a0,0x5
    80001f64:	26850513          	addi	a0,a0,616 # 800071c8 <etext+0x1c8>
    80001f68:	8cdfe0ef          	jal	80000834 <panic>

0000000080001f6c <yield>:
{
    80001f6c:	1101                	addi	sp,sp,-32
    80001f6e:	ec06                	sd	ra,24(sp)
    80001f70:	e822                	sd	s0,16(sp)
    80001f72:	e426                	sd	s1,8(sp)
    80001f74:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f76:	9d3ff0ef          	jal	80001948 <myproc>
    80001f7a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f7c:	cadfe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001f80:	478d                	li	a5,3
    80001f82:	cc9c                	sw	a5,24(s1)
  sched();
    80001f84:	f2dff0ef          	jal	80001eb0 <sched>
  release(&p->lock);
    80001f88:	8526                	mv	a0,s1
    80001f8a:	d27fe0ef          	jal	80000cb0 <release>
}
    80001f8e:	60e2                	ld	ra,24(sp)
    80001f90:	6442                	ld	s0,16(sp)
    80001f92:	64a2                	ld	s1,8(sp)
    80001f94:	6105                	addi	sp,sp,32
    80001f96:	8082                	ret

0000000080001f98 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001f98:	1101                	addi	sp,sp,-32
    80001f9a:	ec06                	sd	ra,24(sp)
    80001f9c:	e822                	sd	s0,16(sp)
    80001f9e:	e426                	sd	s1,8(sp)
    80001fa0:	e04a                	sd	s2,0(sp)
    80001fa2:	1000                	addi	s0,sp,32
    80001fa4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fa6:	9a3ff0ef          	jal	80001948 <myproc>
    80001faa:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001fac:	c7dfe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    80001fb0:	cc81                	beqz	s1,80001fc8 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001fb2:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001fb6:	854a                	mv	a0,s2
    80001fb8:	cf9fe0ef          	jal	80000cb0 <release>
}
    80001fbc:	60e2                	ld	ra,24(sp)
    80001fbe:	6442                	ld	s0,16(sp)
    80001fc0:	64a2                	ld	s1,8(sp)
    80001fc2:	6902                	ld	s2,0(sp)
    80001fc4:	6105                	addi	sp,sp,32
    80001fc6:	8082                	ret
    panic("sleep_prepare: zero chan");
    80001fc8:	00005517          	auipc	a0,0x5
    80001fcc:	21850513          	addi	a0,a0,536 # 800071e0 <etext+0x1e0>
    80001fd0:	865fe0ef          	jal	80000834 <panic>

0000000080001fd4 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80001fd4:	1101                	addi	sp,sp,-32
    80001fd6:	ec06                	sd	ra,24(sp)
    80001fd8:	e822                	sd	s0,16(sp)
    80001fda:	e426                	sd	s1,8(sp)
    80001fdc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fde:	96bff0ef          	jal	80001948 <myproc>
    80001fe2:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80001fe4:	c45fe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    80001fe8:	709c                	ld	a5,32(s1)
    80001fea:	c789                	beqz	a5,80001ff4 <sleep+0x20>
    p->state = SLEEPING;
    80001fec:	4789                	li	a5,2
    80001fee:	cc9c                	sw	a5,24(s1)
    sched();
    80001ff0:	ec1ff0ef          	jal	80001eb0 <sched>
  }
  release(&p->lock);
    80001ff4:	8526                	mv	a0,s1
    80001ff6:	cbbfe0ef          	jal	80000cb0 <release>
}
    80001ffa:	60e2                	ld	ra,24(sp)
    80001ffc:	6442                	ld	s0,16(sp)
    80001ffe:	64a2                	ld	s1,8(sp)
    80002000:	6105                	addi	sp,sp,32
    80002002:	8082                	ret

0000000080002004 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80002004:	7139                	addi	sp,sp,-64
    80002006:	fc06                	sd	ra,56(sp)
    80002008:	f822                	sd	s0,48(sp)
    8000200a:	f426                	sd	s1,40(sp)
    8000200c:	f04a                	sd	s2,32(sp)
    8000200e:	ec4e                	sd	s3,24(sp)
    80002010:	e852                	sd	s4,16(sp)
    80002012:	e456                	sd	s5,8(sp)
    80002014:	0080                	addi	s0,sp,64
    80002016:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002018:	00011497          	auipc	s1,0x11
    8000201c:	80048493          	addi	s1,s1,-2048 # 80012818 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80002020:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80002022:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80002024:	00016997          	auipc	s3,0x16
    80002028:	3f498993          	addi	s3,s3,1012 # 80018418 <tickslock>
    8000202c:	a801                	j	8000203c <wakeup+0x38>
      }
    }
    release(&p->lock);
    8000202e:	8526                	mv	a0,s1
    80002030:	c81fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002034:	17048493          	addi	s1,s1,368
    80002038:	03348063          	beq	s1,s3,80002058 <wakeup+0x54>
    acquire(&p->lock);
    8000203c:	8526                	mv	a0,s1
    8000203e:	bebfe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    80002042:	709c                	ld	a5,32(s1)
    80002044:	ff2795e3          	bne	a5,s2,8000202e <wakeup+0x2a>
      p->chan = 0;
    80002048:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    8000204c:	4c9c                	lw	a5,24(s1)
    8000204e:	ff4790e3          	bne	a5,s4,8000202e <wakeup+0x2a>
        p->state = RUNNABLE;
    80002052:	0154ac23          	sw	s5,24(s1)
    80002056:	bfe1                	j	8000202e <wakeup+0x2a>
  }
}
    80002058:	70e2                	ld	ra,56(sp)
    8000205a:	7442                	ld	s0,48(sp)
    8000205c:	74a2                	ld	s1,40(sp)
    8000205e:	7902                	ld	s2,32(sp)
    80002060:	69e2                	ld	s3,24(sp)
    80002062:	6a42                	ld	s4,16(sp)
    80002064:	6aa2                	ld	s5,8(sp)
    80002066:	6121                	addi	sp,sp,64
    80002068:	8082                	ret

000000008000206a <reparent>:
{
    8000206a:	7179                	addi	sp,sp,-48
    8000206c:	f406                	sd	ra,40(sp)
    8000206e:	f022                	sd	s0,32(sp)
    80002070:	ec26                	sd	s1,24(sp)
    80002072:	e84a                	sd	s2,16(sp)
    80002074:	e44e                	sd	s3,8(sp)
    80002076:	e052                	sd	s4,0(sp)
    80002078:	1800                	addi	s0,sp,48
    8000207a:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000207c:	00010497          	auipc	s1,0x10
    80002080:	79c48493          	addi	s1,s1,1948 # 80012818 <proc>
      pp->parent = initproc;
    80002084:	00008a17          	auipc	s4,0x8
    80002088:	25ca0a13          	addi	s4,s4,604 # 8000a2e0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000208c:	00016997          	auipc	s3,0x16
    80002090:	38c98993          	addi	s3,s3,908 # 80018418 <tickslock>
    80002094:	a029                	j	8000209e <reparent+0x34>
    80002096:	17048493          	addi	s1,s1,368
    8000209a:	01348b63          	beq	s1,s3,800020b0 <reparent+0x46>
    if (pp->parent == p) {
    8000209e:	7c9c                	ld	a5,56(s1)
    800020a0:	ff279be3          	bne	a5,s2,80002096 <reparent+0x2c>
      pp->parent = initproc;
    800020a4:	000a3503          	ld	a0,0(s4)
    800020a8:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800020aa:	f5bff0ef          	jal	80002004 <wakeup>
    800020ae:	b7e5                	j	80002096 <reparent+0x2c>
}
    800020b0:	70a2                	ld	ra,40(sp)
    800020b2:	7402                	ld	s0,32(sp)
    800020b4:	64e2                	ld	s1,24(sp)
    800020b6:	6942                	ld	s2,16(sp)
    800020b8:	69a2                	ld	s3,8(sp)
    800020ba:	6a02                	ld	s4,0(sp)
    800020bc:	6145                	addi	sp,sp,48
    800020be:	8082                	ret

00000000800020c0 <kexit>:
{
    800020c0:	7179                	addi	sp,sp,-48
    800020c2:	f406                	sd	ra,40(sp)
    800020c4:	f022                	sd	s0,32(sp)
    800020c6:	ec26                	sd	s1,24(sp)
    800020c8:	e84a                	sd	s2,16(sp)
    800020ca:	e44e                	sd	s3,8(sp)
    800020cc:	e052                	sd	s4,0(sp)
    800020ce:	1800                	addi	s0,sp,48
    800020d0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020d2:	877ff0ef          	jal	80001948 <myproc>
    800020d6:	89aa                	mv	s3,a0
  if (p == initproc)
    800020d8:	00008797          	auipc	a5,0x8
    800020dc:	2087b783          	ld	a5,520(a5) # 8000a2e0 <initproc>
    800020e0:	0d050493          	addi	s1,a0,208
    800020e4:	15050913          	addi	s2,a0,336
    800020e8:	00a79b63          	bne	a5,a0,800020fe <kexit+0x3e>
    panic("init exiting");
    800020ec:	00005517          	auipc	a0,0x5
    800020f0:	11450513          	addi	a0,a0,276 # 80007200 <etext+0x200>
    800020f4:	f40fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    800020f8:	04a1                	addi	s1,s1,8
    800020fa:	01248963          	beq	s1,s2,8000210c <kexit+0x4c>
    if (p->ofile[fd]) {
    800020fe:	6088                	ld	a0,0(s1)
    80002100:	dd65                	beqz	a0,800020f8 <kexit+0x38>
      fileclose(f);
    80002102:	0b2020ef          	jal	800041b4 <fileclose>
      p->ofile[fd] = 0;
    80002106:	0004b023          	sd	zero,0(s1)
    8000210a:	b7fd                	j	800020f8 <kexit+0x38>
  begin_op();
    8000210c:	3ef010ef          	jal	80003cfa <begin_op>
  iput(p->cwd);
    80002110:	1509b503          	ld	a0,336(s3)
    80002114:	2f0010ef          	jal	80003404 <iput>
  end_op();
    80002118:	46f010ef          	jal	80003d86 <end_op>
  p->cwd = 0;
    8000211c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002120:	00010517          	auipc	a0,0x10
    80002124:	2e050513          	addi	a0,a0,736 # 80012400 <wait_lock>
    80002128:	b01fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    8000212c:	854e                	mv	a0,s3
    8000212e:	f3dff0ef          	jal	8000206a <reparent>
  wakeup(p->parent);
    80002132:	0389b503          	ld	a0,56(s3)
    80002136:	ecfff0ef          	jal	80002004 <wakeup>
  acquire(&p->lock);
    8000213a:	854e                	mv	a0,s3
    8000213c:	aedfe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    80002140:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002144:	4795                	li	a5,5
    80002146:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000214a:	00010517          	auipc	a0,0x10
    8000214e:	2b650513          	addi	a0,a0,694 # 80012400 <wait_lock>
    80002152:	b5ffe0ef          	jal	80000cb0 <release>
  sched();
    80002156:	d5bff0ef          	jal	80001eb0 <sched>
  panic("zombie exit");
    8000215a:	00005517          	auipc	a0,0x5
    8000215e:	0b650513          	addi	a0,a0,182 # 80007210 <etext+0x210>
    80002162:	ed2fe0ef          	jal	80000834 <panic>

0000000080002166 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    80002166:	c525                	beqz	a0,800021ce <kkill+0x68>
{
    80002168:	7179                	addi	sp,sp,-48
    8000216a:	f406                	sd	ra,40(sp)
    8000216c:	f022                	sd	s0,32(sp)
    8000216e:	ec26                	sd	s1,24(sp)
    80002170:	e84a                	sd	s2,16(sp)
    80002172:	e44e                	sd	s3,8(sp)
    80002174:	1800                	addi	s0,sp,48
    80002176:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002178:	00010497          	auipc	s1,0x10
    8000217c:	6a048493          	addi	s1,s1,1696 # 80012818 <proc>
    80002180:	00016997          	auipc	s3,0x16
    80002184:	29898993          	addi	s3,s3,664 # 80018418 <tickslock>
    acquire(&p->lock);
    80002188:	8526                	mv	a0,s1
    8000218a:	a9ffe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    8000218e:	589c                	lw	a5,48(s1)
    80002190:	01278b63          	beq	a5,s2,800021a6 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002194:	8526                	mv	a0,s1
    80002196:	b1bfe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000219a:	17048493          	addi	s1,s1,368
    8000219e:	ff3495e3          	bne	s1,s3,80002188 <kkill+0x22>
  }
  return -1;
    800021a2:	557d                	li	a0,-1
    800021a4:	a819                	j	800021ba <kkill+0x54>
      p->killed = 1;
    800021a6:	4785                	li	a5,1
    800021a8:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800021aa:	4c98                	lw	a4,24(s1)
    800021ac:	4789                	li	a5,2
    800021ae:	00f70d63          	beq	a4,a5,800021c8 <kkill+0x62>
      release(&p->lock);
    800021b2:	8526                	mv	a0,s1
    800021b4:	afdfe0ef          	jal	80000cb0 <release>
      return 0;
    800021b8:	4501                	li	a0,0
}
    800021ba:	70a2                	ld	ra,40(sp)
    800021bc:	7402                	ld	s0,32(sp)
    800021be:	64e2                	ld	s1,24(sp)
    800021c0:	6942                	ld	s2,16(sp)
    800021c2:	69a2                	ld	s3,8(sp)
    800021c4:	6145                	addi	sp,sp,48
    800021c6:	8082                	ret
        p->state = RUNNABLE;
    800021c8:	478d                	li	a5,3
    800021ca:	cc9c                	sw	a5,24(s1)
    800021cc:	b7dd                	j	800021b2 <kkill+0x4c>
    return -1;
    800021ce:	557d                	li	a0,-1
}
    800021d0:	8082                	ret

00000000800021d2 <setkilled>:

void
setkilled(struct proc *p)
{
    800021d2:	1101                	addi	sp,sp,-32
    800021d4:	ec06                	sd	ra,24(sp)
    800021d6:	e822                	sd	s0,16(sp)
    800021d8:	e426                	sd	s1,8(sp)
    800021da:	1000                	addi	s0,sp,32
    800021dc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021de:	a4bfe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    800021e2:	4785                	li	a5,1
    800021e4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800021e6:	8526                	mv	a0,s1
    800021e8:	ac9fe0ef          	jal	80000cb0 <release>
}
    800021ec:	60e2                	ld	ra,24(sp)
    800021ee:	6442                	ld	s0,16(sp)
    800021f0:	64a2                	ld	s1,8(sp)
    800021f2:	6105                	addi	sp,sp,32
    800021f4:	8082                	ret

00000000800021f6 <killed>:

int
killed(struct proc *p)
{
    800021f6:	1101                	addi	sp,sp,-32
    800021f8:	ec06                	sd	ra,24(sp)
    800021fa:	e822                	sd	s0,16(sp)
    800021fc:	e426                	sd	s1,8(sp)
    800021fe:	e04a                	sd	s2,0(sp)
    80002200:	1000                	addi	s0,sp,32
    80002202:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002204:	a25fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80002208:	549c                	lw	a5,40(s1)
    8000220a:	893e                	mv	s2,a5
  release(&p->lock);
    8000220c:	8526                	mv	a0,s1
    8000220e:	aa3fe0ef          	jal	80000cb0 <release>
  return k;
}
    80002212:	854a                	mv	a0,s2
    80002214:	60e2                	ld	ra,24(sp)
    80002216:	6442                	ld	s0,16(sp)
    80002218:	64a2                	ld	s1,8(sp)
    8000221a:	6902                	ld	s2,0(sp)
    8000221c:	6105                	addi	sp,sp,32
    8000221e:	8082                	ret

0000000080002220 <kwait>:
{
    80002220:	715d                	addi	sp,sp,-80
    80002222:	e486                	sd	ra,72(sp)
    80002224:	e0a2                	sd	s0,64(sp)
    80002226:	fc26                	sd	s1,56(sp)
    80002228:	f84a                	sd	s2,48(sp)
    8000222a:	f44e                	sd	s3,40(sp)
    8000222c:	f052                	sd	s4,32(sp)
    8000222e:	ec56                	sd	s5,24(sp)
    80002230:	e85a                	sd	s6,16(sp)
    80002232:	e45e                	sd	s7,8(sp)
    80002234:	0880                	addi	s0,sp,80
    80002236:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002238:	f10ff0ef          	jal	80001948 <myproc>
    8000223c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000223e:	00010517          	auipc	a0,0x10
    80002242:	1c250513          	addi	a0,a0,450 # 80012400 <wait_lock>
    80002246:	9e3fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    8000224a:	4a15                	li	s4,5
        havekids = 1;
    8000224c:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000224e:	00016997          	auipc	s3,0x16
    80002252:	1ca98993          	addi	s3,s3,458 # 80018418 <tickslock>
    release(&wait_lock);
    80002256:	00010b17          	auipc	s6,0x10
    8000225a:	1aab0b13          	addi	s6,s6,426 # 80012400 <wait_lock>
    8000225e:	a845                	j	8000230e <kwait+0xee>
          pid = pp->pid;
    80002260:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    80002264:	000b8e63          	beqz	s7,80002280 <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    80002268:	4711                	li	a4,4
    8000226a:	02c48693          	addi	a3,s1,44
    8000226e:	865e                	mv	a2,s7
    80002270:	04893583          	ld	a1,72(s2)
    80002274:	05093503          	ld	a0,80(s2)
    80002278:	b0aff0ef          	jal	80001582 <copyout>
          if (addr != 0 &&
    8000227c:	02054c63          	bltz	a0,800022b4 <kwait+0x94>
          pp->parent = 0;
    80002280:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    80002284:	8526                	mv	a0,s1
    80002286:	893ff0ef          	jal	80001b18 <freeproc>
          release(&pp->lock);
    8000228a:	8526                	mv	a0,s1
    8000228c:	a25fe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    80002290:	00010517          	auipc	a0,0x10
    80002294:	17050513          	addi	a0,a0,368 # 80012400 <wait_lock>
    80002298:	a19fe0ef          	jal	80000cb0 <release>
}
    8000229c:	854e                	mv	a0,s3
    8000229e:	60a6                	ld	ra,72(sp)
    800022a0:	6406                	ld	s0,64(sp)
    800022a2:	74e2                	ld	s1,56(sp)
    800022a4:	7942                	ld	s2,48(sp)
    800022a6:	79a2                	ld	s3,40(sp)
    800022a8:	7a02                	ld	s4,32(sp)
    800022aa:	6ae2                	ld	s5,24(sp)
    800022ac:	6b42                	ld	s6,16(sp)
    800022ae:	6ba2                	ld	s7,8(sp)
    800022b0:	6161                	addi	sp,sp,80
    800022b2:	8082                	ret
            release(&pp->lock);
    800022b4:	8526                	mv	a0,s1
    800022b6:	9fbfe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    800022ba:	00010517          	auipc	a0,0x10
    800022be:	14650513          	addi	a0,a0,326 # 80012400 <wait_lock>
    800022c2:	9effe0ef          	jal	80000cb0 <release>
            return -1;
    800022c6:	59fd                	li	s3,-1
    800022c8:	bfd1                	j	8000229c <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022ca:	17048493          	addi	s1,s1,368
    800022ce:	03348063          	beq	s1,s3,800022ee <kwait+0xce>
      if (pp->parent == p) {
    800022d2:	7c9c                	ld	a5,56(s1)
    800022d4:	ff279be3          	bne	a5,s2,800022ca <kwait+0xaa>
        acquire(&pp->lock);
    800022d8:	8526                	mv	a0,s1
    800022da:	94ffe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800022de:	4c9c                	lw	a5,24(s1)
    800022e0:	f94780e3          	beq	a5,s4,80002260 <kwait+0x40>
        release(&pp->lock);
    800022e4:	8526                	mv	a0,s1
    800022e6:	9cbfe0ef          	jal	80000cb0 <release>
        havekids = 1;
    800022ea:	8756                	mv	a4,s5
    800022ec:	bff9                	j	800022ca <kwait+0xaa>
    if (!havekids || killed(p)) {
    800022ee:	c715                	beqz	a4,8000231a <kwait+0xfa>
    800022f0:	854a                	mv	a0,s2
    800022f2:	f05ff0ef          	jal	800021f6 <killed>
    800022f6:	e115                	bnez	a0,8000231a <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    800022f8:	854a                	mv	a0,s2
    800022fa:	c9fff0ef          	jal	80001f98 <sleep_prepare>
    release(&wait_lock);
    800022fe:	855a                	mv	a0,s6
    80002300:	9b1fe0ef          	jal	80000cb0 <release>
    sleep();
    80002304:	cd1ff0ef          	jal	80001fd4 <sleep>
    acquire(&wait_lock);
    80002308:	855a                	mv	a0,s6
    8000230a:	91ffe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    8000230e:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002310:	00010497          	auipc	s1,0x10
    80002314:	50848493          	addi	s1,s1,1288 # 80012818 <proc>
    80002318:	bf6d                	j	800022d2 <kwait+0xb2>
      release(&wait_lock);
    8000231a:	00010517          	auipc	a0,0x10
    8000231e:	0e650513          	addi	a0,a0,230 # 80012400 <wait_lock>
    80002322:	98ffe0ef          	jal	80000cb0 <release>
      return -1;
    80002326:	59fd                	li	s3,-1
    80002328:	bf95                	j	8000229c <kwait+0x7c>

000000008000232a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000232a:	7179                	addi	sp,sp,-48
    8000232c:	f406                	sd	ra,40(sp)
    8000232e:	f022                	sd	s0,32(sp)
    80002330:	ec26                	sd	s1,24(sp)
    80002332:	e84a                	sd	s2,16(sp)
    80002334:	e44e                	sd	s3,8(sp)
    80002336:	e052                	sd	s4,0(sp)
    80002338:	1800                	addi	s0,sp,48
    8000233a:	84aa                	mv	s1,a0
    8000233c:	8a2e                	mv	s4,a1
    8000233e:	89b2                	mv	s3,a2
    80002340:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002342:	e06ff0ef          	jal	80001948 <myproc>
  if (user_dst) {
    80002346:	c085                	beqz	s1,80002366 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    80002348:	874a                	mv	a4,s2
    8000234a:	86ce                	mv	a3,s3
    8000234c:	8652                	mv	a2,s4
    8000234e:	652c                	ld	a1,72(a0)
    80002350:	6928                	ld	a0,80(a0)
    80002352:	a30ff0ef          	jal	80001582 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002356:	70a2                	ld	ra,40(sp)
    80002358:	7402                	ld	s0,32(sp)
    8000235a:	64e2                	ld	s1,24(sp)
    8000235c:	6942                	ld	s2,16(sp)
    8000235e:	69a2                	ld	s3,8(sp)
    80002360:	6a02                	ld	s4,0(sp)
    80002362:	6145                	addi	sp,sp,48
    80002364:	8082                	ret
    memmove((char *)dst, src, len);
    80002366:	0009061b          	sext.w	a2,s2
    8000236a:	85ce                	mv	a1,s3
    8000236c:	8552                	mv	a0,s4
    8000236e:	9dbfe0ef          	jal	80000d48 <memmove>
    return 0;
    80002372:	8526                	mv	a0,s1
    80002374:	b7cd                	j	80002356 <either_copyout+0x2c>

0000000080002376 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002376:	7179                	addi	sp,sp,-48
    80002378:	f406                	sd	ra,40(sp)
    8000237a:	f022                	sd	s0,32(sp)
    8000237c:	ec26                	sd	s1,24(sp)
    8000237e:	e84a                	sd	s2,16(sp)
    80002380:	e44e                	sd	s3,8(sp)
    80002382:	e052                	sd	s4,0(sp)
    80002384:	1800                	addi	s0,sp,48
    80002386:	8a2a                	mv	s4,a0
    80002388:	84ae                	mv	s1,a1
    8000238a:	89b2                	mv	s3,a2
    8000238c:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000238e:	dbaff0ef          	jal	80001948 <myproc>
  if (user_src) {
    80002392:	c085                	beqz	s1,800023b2 <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    80002394:	874a                	mv	a4,s2
    80002396:	86ce                	mv	a3,s3
    80002398:	8652                	mv	a2,s4
    8000239a:	652c                	ld	a1,72(a0)
    8000239c:	6928                	ld	a0,80(a0)
    8000239e:	aaaff0ef          	jal	80001648 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800023a2:	70a2                	ld	ra,40(sp)
    800023a4:	7402                	ld	s0,32(sp)
    800023a6:	64e2                	ld	s1,24(sp)
    800023a8:	6942                	ld	s2,16(sp)
    800023aa:	69a2                	ld	s3,8(sp)
    800023ac:	6a02                	ld	s4,0(sp)
    800023ae:	6145                	addi	sp,sp,48
    800023b0:	8082                	ret
    memmove(dst, (char *)src, len);
    800023b2:	0009061b          	sext.w	a2,s2
    800023b6:	85ce                	mv	a1,s3
    800023b8:	8552                	mv	a0,s4
    800023ba:	98ffe0ef          	jal	80000d48 <memmove>
    return 0;
    800023be:	8526                	mv	a0,s1
    800023c0:	b7cd                	j	800023a2 <either_copyin+0x2c>

00000000800023c2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800023c2:	715d                	addi	sp,sp,-80
    800023c4:	e486                	sd	ra,72(sp)
    800023c6:	e0a2                	sd	s0,64(sp)
    800023c8:	fc26                	sd	s1,56(sp)
    800023ca:	f84a                	sd	s2,48(sp)
    800023cc:	f44e                	sd	s3,40(sp)
    800023ce:	f052                	sd	s4,32(sp)
    800023d0:	ec56                	sd	s5,24(sp)
    800023d2:	e85a                	sd	s6,16(sp)
    800023d4:	e45e                	sd	s7,8(sp)
    800023d6:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    800023d8:	00005517          	auipc	a0,0x5
    800023dc:	ca050513          	addi	a0,a0,-864 # 80007078 <etext+0x78>
    800023e0:	92afe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800023e4:	00010497          	auipc	s1,0x10
    800023e8:	58c48493          	addi	s1,s1,1420 # 80012970 <proc+0x158>
    800023ec:	00016917          	auipc	s2,0x16
    800023f0:	18490913          	addi	s2,s2,388 # 80018570 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023f4:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800023f6:	00005997          	auipc	s3,0x5
    800023fa:	e2a98993          	addi	s3,s3,-470 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    800023fe:	00005a97          	auipc	s5,0x5
    80002402:	e2aa8a93          	addi	s5,s5,-470 # 80007228 <etext+0x228>
    printk("\n");
    80002406:	00005a17          	auipc	s4,0x5
    8000240a:	c72a0a13          	addi	s4,s4,-910 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000240e:	00005b97          	auipc	s7,0x5
    80002412:	33ab8b93          	addi	s7,s7,826 # 80007748 <states.0>
    80002416:	a829                	j	80002430 <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002418:	ed86a583          	lw	a1,-296(a3)
    8000241c:	8556                	mv	a0,s5
    8000241e:	8ecfe0ef          	jal	8000050a <printk>
    printk("\n");
    80002422:	8552                	mv	a0,s4
    80002424:	8e6fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002428:	17048493          	addi	s1,s1,368
    8000242c:	03248263          	beq	s1,s2,80002450 <procdump+0x8e>
    if (p->state == UNUSED)
    80002430:	86a6                	mv	a3,s1
    80002432:	ec04a783          	lw	a5,-320(s1)
    80002436:	dbed                	beqz	a5,80002428 <procdump+0x66>
      state = "???";
    80002438:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000243a:	fcfb6fe3          	bltu	s6,a5,80002418 <procdump+0x56>
    8000243e:	02079713          	slli	a4,a5,0x20
    80002442:	01d75793          	srli	a5,a4,0x1d
    80002446:	97de                	add	a5,a5,s7
    80002448:	6390                	ld	a2,0(a5)
    8000244a:	f679                	bnez	a2,80002418 <procdump+0x56>
      state = "???";
    8000244c:	864e                	mv	a2,s3
    8000244e:	b7e9                	j	80002418 <procdump+0x56>
  }
}
    80002450:	60a6                	ld	ra,72(sp)
    80002452:	6406                	ld	s0,64(sp)
    80002454:	74e2                	ld	s1,56(sp)
    80002456:	7942                	ld	s2,48(sp)
    80002458:	79a2                	ld	s3,40(sp)
    8000245a:	7a02                	ld	s4,32(sp)
    8000245c:	6ae2                	ld	s5,24(sp)
    8000245e:	6b42                	ld	s6,16(sp)
    80002460:	6ba2                	ld	s7,8(sp)
    80002462:	6161                	addi	sp,sp,80
    80002464:	8082                	ret

0000000080002466 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002466:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000246a:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000246e:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002470:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002472:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002476:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000247a:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000247e:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002482:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002486:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000248a:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000248e:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002492:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002496:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000249a:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000249e:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800024a2:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800024a4:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800024a6:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800024aa:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800024ae:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800024b2:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800024b6:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800024ba:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800024be:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800024c2:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800024c6:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800024ca:	0685bd83          	ld	s11,104(a1)
        
        ret
    800024ce:	8082                	ret

00000000800024d0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800024d0:	1141                	addi	sp,sp,-16
    800024d2:	e406                	sd	ra,8(sp)
    800024d4:	e022                	sd	s0,0(sp)
    800024d6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800024d8:	00005597          	auipc	a1,0x5
    800024dc:	d9058593          	addi	a1,a1,-624 # 80007268 <etext+0x268>
    800024e0:	00016517          	auipc	a0,0x16
    800024e4:	f3850513          	addi	a0,a0,-200 # 80018418 <tickslock>
    800024e8:	ec0fe0ef          	jal	80000ba8 <initlock>
}
    800024ec:	60a2                	ld	ra,8(sp)
    800024ee:	6402                	ld	s0,0(sp)
    800024f0:	0141                	addi	sp,sp,16
    800024f2:	8082                	ret

00000000800024f4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024f4:	1141                	addi	sp,sp,-16
    800024f6:	e406                	sd	ra,8(sp)
    800024f8:	e022                	sd	s0,0(sp)
    800024fa:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    800024fc:	00003797          	auipc	a5,0x3
    80002500:	14478793          	addi	a5,a5,324 # 80005640 <kernelvec>
    80002504:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002508:	60a2                	ld	ra,8(sp)
    8000250a:	6402                	ld	s0,0(sp)
    8000250c:	0141                	addi	sp,sp,16
    8000250e:	8082                	ret

0000000080002510 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002510:	1141                	addi	sp,sp,-16
    80002512:	e406                	sd	ra,8(sp)
    80002514:	e022                	sd	s0,0(sp)
    80002516:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002518:	c30ff0ef          	jal	80001948 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    8000251c:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002520:	04000737          	lui	a4,0x4000
    80002524:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002526:	0732                	slli	a4,a4,0xc
    80002528:	00004797          	auipc	a5,0x4
    8000252c:	ad878793          	addi	a5,a5,-1320 # 80006000 <_trampoline>
    80002530:	00004697          	auipc	a3,0x4
    80002534:	ad068693          	addi	a3,a3,-1328 # 80006000 <_trampoline>
    80002538:	8f95                	sub	a5,a5,a3
    8000253a:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000253c:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002540:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    80002542:	18002773          	csrr	a4,satp
    80002546:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002548:	6d38                	ld	a4,88(a0)
    8000254a:	613c                	ld	a5,64(a0)
    8000254c:	6685                	lui	a3,0x1
    8000254e:	97b6                	add	a5,a5,a3
    80002550:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002552:	6d3c                	ld	a5,88(a0)
    80002554:	00000717          	auipc	a4,0x0
    80002558:	0fc70713          	addi	a4,a4,252 # 80002650 <usertrap>
    8000255c:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000255e:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    80002560:	8712                	mv	a4,tp
    80002562:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002564:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002568:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000256c:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002570:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002574:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002576:	6f9c                	ld	a5,24(a5)
    80002578:	14179073          	csrw	sepc,a5
}
    8000257c:	60a2                	ld	ra,8(sp)
    8000257e:	6402                	ld	s0,0(sp)
    80002580:	0141                	addi	sp,sp,16
    80002582:	8082                	ret

0000000080002584 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002584:	1141                	addi	sp,sp,-16
    80002586:	e406                	sd	ra,8(sp)
    80002588:	e022                	sd	s0,0(sp)
    8000258a:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    8000258c:	b88ff0ef          	jal	80001914 <cpuid>
    80002590:	cd11                	beqz	a0,800025ac <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    80002592:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002596:	000f4737          	lui	a4,0xf4
    8000259a:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000259e:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    800025a0:	14d79073          	csrw	stimecmp,a5
}
    800025a4:	60a2                	ld	ra,8(sp)
    800025a6:	6402                	ld	s0,0(sp)
    800025a8:	0141                	addi	sp,sp,16
    800025aa:	8082                	ret
    acquire(&tickslock);
    800025ac:	00016517          	auipc	a0,0x16
    800025b0:	e6c50513          	addi	a0,a0,-404 # 80018418 <tickslock>
    800025b4:	e74fe0ef          	jal	80000c28 <acquire>
    ticks++;
    800025b8:	00008717          	auipc	a4,0x8
    800025bc:	d3070713          	addi	a4,a4,-720 # 8000a2e8 <ticks>
    800025c0:	431c                	lw	a5,0(a4)
    800025c2:	2785                	addiw	a5,a5,1
    800025c4:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800025c6:	853a                	mv	a0,a4
    800025c8:	a3dff0ef          	jal	80002004 <wakeup>
    release(&tickslock);
    800025cc:	00016517          	auipc	a0,0x16
    800025d0:	e4c50513          	addi	a0,a0,-436 # 80018418 <tickslock>
    800025d4:	edcfe0ef          	jal	80000cb0 <release>
    800025d8:	bf6d                	j	80002592 <clockintr+0xe>

00000000800025da <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800025da:	1101                	addi	sp,sp,-32
    800025dc:	ec06                	sd	ra,24(sp)
    800025de:	e822                	sd	s0,16(sp)
    800025e0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    800025e2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    800025e6:	57fd                	li	a5,-1
    800025e8:	17fe                	slli	a5,a5,0x3f
    800025ea:	07a5                	addi	a5,a5,9
    800025ec:	00f70c63          	beq	a4,a5,80002604 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    800025f0:	57fd                	li	a5,-1
    800025f2:	17fe                	slli	a5,a5,0x3f
    800025f4:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025f6:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    800025f8:	04f70863          	beq	a4,a5,80002648 <devintr+0x6e>
  }
}
    800025fc:	60e2                	ld	ra,24(sp)
    800025fe:	6442                	ld	s0,16(sp)
    80002600:	6105                	addi	sp,sp,32
    80002602:	8082                	ret
    80002604:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002606:	0e8030ef          	jal	800056ee <plic_claim>
    8000260a:	872a                	mv	a4,a0
    8000260c:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    8000260e:	47a9                	li	a5,10
    80002610:	00f50963          	beq	a0,a5,80002622 <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    80002614:	4785                	li	a5,1
    80002616:	00f50963          	beq	a0,a5,80002628 <devintr+0x4e>
    return 1;
    8000261a:	4505                	li	a0,1
    } else if (irq) {
    8000261c:	eb09                	bnez	a4,8000262e <devintr+0x54>
    8000261e:	64a2                	ld	s1,8(sp)
    80002620:	bff1                	j	800025fc <devintr+0x22>
      uartintr();
    80002622:	bccfe0ef          	jal	800009ee <uartintr>
    if (irq)
    80002626:	a819                	j	8000263c <devintr+0x62>
      virtio_disk_intr();
    80002628:	582030ef          	jal	80005baa <virtio_disk_intr>
    if (irq)
    8000262c:	a801                	j	8000263c <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    8000262e:	85ba                	mv	a1,a4
    80002630:	00005517          	auipc	a0,0x5
    80002634:	c4050513          	addi	a0,a0,-960 # 80007270 <etext+0x270>
    80002638:	ed3fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    8000263c:	8526                	mv	a0,s1
    8000263e:	0d2030ef          	jal	80005710 <plic_complete>
    return 1;
    80002642:	4505                	li	a0,1
    80002644:	64a2                	ld	s1,8(sp)
    80002646:	bf5d                	j	800025fc <devintr+0x22>
    clockintr();
    80002648:	f3dff0ef          	jal	80002584 <clockintr>
    return 2;
    8000264c:	4509                	li	a0,2
    8000264e:	b77d                	j	800025fc <devintr+0x22>

0000000080002650 <usertrap>:
{
    80002650:	1101                	addi	sp,sp,-32
    80002652:	ec06                	sd	ra,24(sp)
    80002654:	e822                	sd	s0,16(sp)
    80002656:	e426                	sd	s1,8(sp)
    80002658:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000265a:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    8000265e:	1007f793          	andi	a5,a5,256
    80002662:	e7bd                	bnez	a5,800026d0 <usertrap+0x80>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002664:	00003797          	auipc	a5,0x3
    80002668:	fdc78793          	addi	a5,a5,-36 # 80005640 <kernelvec>
    8000266c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002670:	ad8ff0ef          	jal	80001948 <myproc>
    80002674:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002676:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002678:	14102773          	csrr	a4,sepc
    8000267c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    8000267e:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    80002682:	47a1                	li	a5,8
    80002684:	04f70c63          	beq	a4,a5,800026dc <usertrap+0x8c>
  } else if ((which_dev = devintr()) != 0) {
    80002688:	f53ff0ef          	jal	800025da <devintr>
    8000268c:	e13d                	bnez	a0,800026f2 <usertrap+0xa2>
    8000268e:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002692:	47bd                	li	a5,15
    80002694:	08f70363          	beq	a4,a5,8000271a <usertrap+0xca>
    80002698:	14202773          	csrr	a4,scause
    8000269c:	47b5                	li	a5,13
    8000269e:	06f70e63          	beq	a4,a5,8000271a <usertrap+0xca>
    800026a2:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800026a6:	5890                	lw	a2,48(s1)
    800026a8:	00005517          	auipc	a0,0x5
    800026ac:	c0850513          	addi	a0,a0,-1016 # 800072b0 <etext+0x2b0>
    800026b0:	e5bfd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026b4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800026b8:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800026bc:	00005517          	auipc	a0,0x5
    800026c0:	c2450513          	addi	a0,a0,-988 # 800072e0 <etext+0x2e0>
    800026c4:	e47fd0ef          	jal	8000050a <printk>
    setkilled(p);
    800026c8:	8526                	mv	a0,s1
    800026ca:	b09ff0ef          	jal	800021d2 <setkilled>
    800026ce:	a015                	j	800026f2 <usertrap+0xa2>
    panic("usertrap: not from user mode");
    800026d0:	00005517          	auipc	a0,0x5
    800026d4:	bc050513          	addi	a0,a0,-1088 # 80007290 <etext+0x290>
    800026d8:	95cfe0ef          	jal	80000834 <panic>
    if (killed(p))
    800026dc:	b1bff0ef          	jal	800021f6 <killed>
    800026e0:	e90d                	bnez	a0,80002712 <usertrap+0xc2>
    p->trapframe->epc += 4;
    800026e2:	6cb8                	ld	a4,88(s1)
    800026e4:	6f1c                	ld	a5,24(a4)
    800026e6:	0791                	addi	a5,a5,4
    800026e8:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    800026ea:	10016073          	csrsi	sstatus,2
    syscall();
    800026ee:	21a000ef          	jal	80002908 <syscall>
  if (killed(p))
    800026f2:	8526                	mv	a0,s1
    800026f4:	b03ff0ef          	jal	800021f6 <killed>
    800026f8:	ed15                	bnez	a0,80002734 <usertrap+0xe4>
  prepare_return();
    800026fa:	e17ff0ef          	jal	80002510 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800026fe:	68a8                	ld	a0,80(s1)
    80002700:	8131                	srli	a0,a0,0xc
}
    80002702:	57fd                	li	a5,-1
    80002704:	17fe                	slli	a5,a5,0x3f
    80002706:	8d5d                	or	a0,a0,a5
    80002708:	60e2                	ld	ra,24(sp)
    8000270a:	6442                	ld	s0,16(sp)
    8000270c:	64a2                	ld	s1,8(sp)
    8000270e:	6105                	addi	sp,sp,32
    80002710:	8082                	ret
      kexit(-1);
    80002712:	557d                	li	a0,-1
    80002714:	9adff0ef          	jal	800020c0 <kexit>
    80002718:	b7e9                	j	800026e2 <usertrap+0x92>
  asm volatile("csrr %0, stval" : "=r"(x));
    8000271a:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    8000271e:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002722:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    80002724:	0016b693          	seqz	a3,a3
    80002728:	64ac                	ld	a1,72(s1)
    8000272a:	68a8                	ld	a0,80(s1)
    8000272c:	ddbfe0ef          	jal	80001506 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002730:	f169                	bnez	a0,800026f2 <usertrap+0xa2>
    80002732:	bf85                	j	800026a2 <usertrap+0x52>
    kexit(-1);
    80002734:	557d                	li	a0,-1
    80002736:	98bff0ef          	jal	800020c0 <kexit>
    8000273a:	b7c1                	j	800026fa <usertrap+0xaa>

000000008000273c <kerneltrap>:
{
    8000273c:	7179                	addi	sp,sp,-48
    8000273e:	f406                	sd	ra,40(sp)
    80002740:	f022                	sd	s0,32(sp)
    80002742:	ec26                	sd	s1,24(sp)
    80002744:	e84a                	sd	s2,16(sp)
    80002746:	e44e                	sd	s3,8(sp)
    80002748:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000274a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000274e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    80002752:	142027f3          	csrr	a5,scause
    80002756:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    80002758:	1004f793          	andi	a5,s1,256
    8000275c:	c39d                	beqz	a5,80002782 <kerneltrap+0x46>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000275e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002762:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002764:	e78d                	bnez	a5,8000278e <kerneltrap+0x52>
  if ((which_dev = devintr()) == 0) {
    80002766:	e75ff0ef          	jal	800025da <devintr>
    8000276a:	c905                	beqz	a0,8000279a <kerneltrap+0x5e>
  asm volatile("csrw sepc, %0" : : "r"(x));
    8000276c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002770:	10049073          	csrw	sstatus,s1
}
    80002774:	70a2                	ld	ra,40(sp)
    80002776:	7402                	ld	s0,32(sp)
    80002778:	64e2                	ld	s1,24(sp)
    8000277a:	6942                	ld	s2,16(sp)
    8000277c:	69a2                	ld	s3,8(sp)
    8000277e:	6145                	addi	sp,sp,48
    80002780:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002782:	00005517          	auipc	a0,0x5
    80002786:	b8650513          	addi	a0,a0,-1146 # 80007308 <etext+0x308>
    8000278a:	8aafe0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    8000278e:	00005517          	auipc	a0,0x5
    80002792:	ba250513          	addi	a0,a0,-1118 # 80007330 <etext+0x330>
    80002796:	89efe0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000279a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000279e:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800027a2:	85ce                	mv	a1,s3
    800027a4:	00005517          	auipc	a0,0x5
    800027a8:	bac50513          	addi	a0,a0,-1108 # 80007350 <etext+0x350>
    800027ac:	d5ffd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    800027b0:	00005517          	auipc	a0,0x5
    800027b4:	bc850513          	addi	a0,a0,-1080 # 80007378 <etext+0x378>
    800027b8:	87cfe0ef          	jal	80000834 <panic>

00000000800027bc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800027bc:	1101                	addi	sp,sp,-32
    800027be:	ec06                	sd	ra,24(sp)
    800027c0:	e822                	sd	s0,16(sp)
    800027c2:	e426                	sd	s1,8(sp)
    800027c4:	1000                	addi	s0,sp,32
    800027c6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027c8:	980ff0ef          	jal	80001948 <myproc>
  switch (n) {
    800027cc:	4795                	li	a5,5
    800027ce:	0497e163          	bltu	a5,s1,80002810 <argraw+0x54>
    800027d2:	048a                	slli	s1,s1,0x2
    800027d4:	00005717          	auipc	a4,0x5
    800027d8:	fa470713          	addi	a4,a4,-92 # 80007778 <states.0+0x30>
    800027dc:	94ba                	add	s1,s1,a4
    800027de:	409c                	lw	a5,0(s1)
    800027e0:	97ba                	add	a5,a5,a4
    800027e2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027e4:	6d3c                	ld	a5,88(a0)
    800027e6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800027e8:	60e2                	ld	ra,24(sp)
    800027ea:	6442                	ld	s0,16(sp)
    800027ec:	64a2                	ld	s1,8(sp)
    800027ee:	6105                	addi	sp,sp,32
    800027f0:	8082                	ret
    return p->trapframe->a1;
    800027f2:	6d3c                	ld	a5,88(a0)
    800027f4:	7fa8                	ld	a0,120(a5)
    800027f6:	bfcd                	j	800027e8 <argraw+0x2c>
    return p->trapframe->a2;
    800027f8:	6d3c                	ld	a5,88(a0)
    800027fa:	63c8                	ld	a0,128(a5)
    800027fc:	b7f5                	j	800027e8 <argraw+0x2c>
    return p->trapframe->a3;
    800027fe:	6d3c                	ld	a5,88(a0)
    80002800:	67c8                	ld	a0,136(a5)
    80002802:	b7dd                	j	800027e8 <argraw+0x2c>
    return p->trapframe->a4;
    80002804:	6d3c                	ld	a5,88(a0)
    80002806:	6bc8                	ld	a0,144(a5)
    80002808:	b7c5                	j	800027e8 <argraw+0x2c>
    return p->trapframe->a5;
    8000280a:	6d3c                	ld	a5,88(a0)
    8000280c:	6fc8                	ld	a0,152(a5)
    8000280e:	bfe9                	j	800027e8 <argraw+0x2c>
  panic("argraw");
    80002810:	00005517          	auipc	a0,0x5
    80002814:	b7850513          	addi	a0,a0,-1160 # 80007388 <etext+0x388>
    80002818:	81cfe0ef          	jal	80000834 <panic>

000000008000281c <fetchaddr>:
{
    8000281c:	1101                	addi	sp,sp,-32
    8000281e:	ec06                	sd	ra,24(sp)
    80002820:	e822                	sd	s0,16(sp)
    80002822:	e426                	sd	s1,8(sp)
    80002824:	e04a                	sd	s2,0(sp)
    80002826:	1000                	addi	s0,sp,32
    80002828:	84aa                	mv	s1,a0
    8000282a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000282c:	91cff0ef          	jal	80001948 <myproc>
  if (addr >= p->sz ||
    80002830:	652c                	ld	a1,72(a0)
    80002832:	02b4f663          	bgeu	s1,a1,8000285e <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002836:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    8000283a:	02f5e463          	bltu	a1,a5,80002862 <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    8000283e:	4721                	li	a4,8
    80002840:	86a6                	mv	a3,s1
    80002842:	864a                	mv	a2,s2
    80002844:	6928                	ld	a0,80(a0)
    80002846:	e03fe0ef          	jal	80001648 <copyin>
    8000284a:	00a03533          	snez	a0,a0
    8000284e:	40a0053b          	negw	a0,a0
}
    80002852:	60e2                	ld	ra,24(sp)
    80002854:	6442                	ld	s0,16(sp)
    80002856:	64a2                	ld	s1,8(sp)
    80002858:	6902                	ld	s2,0(sp)
    8000285a:	6105                	addi	sp,sp,32
    8000285c:	8082                	ret
    return -1;
    8000285e:	557d                	li	a0,-1
    80002860:	bfcd                	j	80002852 <fetchaddr+0x36>
    80002862:	557d                	li	a0,-1
    80002864:	b7fd                	j	80002852 <fetchaddr+0x36>

0000000080002866 <fetchstr>:
{
    80002866:	7179                	addi	sp,sp,-48
    80002868:	f406                	sd	ra,40(sp)
    8000286a:	f022                	sd	s0,32(sp)
    8000286c:	ec26                	sd	s1,24(sp)
    8000286e:	e84a                	sd	s2,16(sp)
    80002870:	e44e                	sd	s3,8(sp)
    80002872:	1800                	addi	s0,sp,48
    80002874:	89aa                	mv	s3,a0
    80002876:	84ae                	mv	s1,a1
    80002878:	8932                	mv	s2,a2
  struct proc *p = myproc();
    8000287a:	8ceff0ef          	jal	80001948 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    8000287e:	874a                	mv	a4,s2
    80002880:	86ce                	mv	a3,s3
    80002882:	8626                	mv	a2,s1
    80002884:	652c                	ld	a1,72(a0)
    80002886:	6928                	ld	a0,80(a0)
    80002888:	e5dfe0ef          	jal	800016e4 <copyinstr>
    8000288c:	00054c63          	bltz	a0,800028a4 <fetchstr+0x3e>
  return strlen(buf);
    80002890:	8526                	mv	a0,s1
    80002892:	de0fe0ef          	jal	80000e72 <strlen>
}
    80002896:	70a2                	ld	ra,40(sp)
    80002898:	7402                	ld	s0,32(sp)
    8000289a:	64e2                	ld	s1,24(sp)
    8000289c:	6942                	ld	s2,16(sp)
    8000289e:	69a2                	ld	s3,8(sp)
    800028a0:	6145                	addi	sp,sp,48
    800028a2:	8082                	ret
    return -1;
    800028a4:	557d                	li	a0,-1
    800028a6:	bfc5                	j	80002896 <fetchstr+0x30>

00000000800028a8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800028a8:	1101                	addi	sp,sp,-32
    800028aa:	ec06                	sd	ra,24(sp)
    800028ac:	e822                	sd	s0,16(sp)
    800028ae:	e426                	sd	s1,8(sp)
    800028b0:	1000                	addi	s0,sp,32
    800028b2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028b4:	f09ff0ef          	jal	800027bc <argraw>
    800028b8:	c088                	sw	a0,0(s1)
}
    800028ba:	60e2                	ld	ra,24(sp)
    800028bc:	6442                	ld	s0,16(sp)
    800028be:	64a2                	ld	s1,8(sp)
    800028c0:	6105                	addi	sp,sp,32
    800028c2:	8082                	ret

00000000800028c4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800028c4:	1101                	addi	sp,sp,-32
    800028c6:	ec06                	sd	ra,24(sp)
    800028c8:	e822                	sd	s0,16(sp)
    800028ca:	e426                	sd	s1,8(sp)
    800028cc:	1000                	addi	s0,sp,32
    800028ce:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028d0:	eedff0ef          	jal	800027bc <argraw>
    800028d4:	e088                	sd	a0,0(s1)
}
    800028d6:	60e2                	ld	ra,24(sp)
    800028d8:	6442                	ld	s0,16(sp)
    800028da:	64a2                	ld	s1,8(sp)
    800028dc:	6105                	addi	sp,sp,32
    800028de:	8082                	ret

00000000800028e0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028e0:	1101                	addi	sp,sp,-32
    800028e2:	ec06                	sd	ra,24(sp)
    800028e4:	e822                	sd	s0,16(sp)
    800028e6:	e426                	sd	s1,8(sp)
    800028e8:	e04a                	sd	s2,0(sp)
    800028ea:	1000                	addi	s0,sp,32
    800028ec:	892e                	mv	s2,a1
    800028ee:	84b2                	mv	s1,a2
  *ip = argraw(n);
    800028f0:	ecdff0ef          	jal	800027bc <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800028f4:	8626                	mv	a2,s1
    800028f6:	85ca                	mv	a1,s2
    800028f8:	f6fff0ef          	jal	80002866 <fetchstr>
}
    800028fc:	60e2                	ld	ra,24(sp)
    800028fe:	6442                	ld	s0,16(sp)
    80002900:	64a2                	ld	s1,8(sp)
    80002902:	6902                	ld	s2,0(sp)
    80002904:	6105                	addi	sp,sp,32
    80002906:	8082                	ret

0000000080002908 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002908:	1101                	addi	sp,sp,-32
    8000290a:	ec06                	sd	ra,24(sp)
    8000290c:	e822                	sd	s0,16(sp)
    8000290e:	e426                	sd	s1,8(sp)
    80002910:	e04a                	sd	s2,0(sp)
    80002912:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002914:	834ff0ef          	jal	80001948 <myproc>
    80002918:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000291a:	05853903          	ld	s2,88(a0)
    8000291e:	0a893783          	ld	a5,168(s2)
    80002922:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002926:	37fd                	addiw	a5,a5,-1
    80002928:	4755                	li	a4,21
    8000292a:	00f76f63          	bltu	a4,a5,80002948 <syscall+0x40>
    8000292e:	00369713          	slli	a4,a3,0x3
    80002932:	00005797          	auipc	a5,0x5
    80002936:	e5e78793          	addi	a5,a5,-418 # 80007790 <syscalls>
    8000293a:	97ba                	add	a5,a5,a4
    8000293c:	639c                	ld	a5,0(a5)
    8000293e:	c789                	beqz	a5,80002948 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002940:	9782                	jalr	a5
    80002942:	06a93823          	sd	a0,112(s2)
    80002946:	a829                	j	80002960 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002948:	15848613          	addi	a2,s1,344
    8000294c:	588c                	lw	a1,48(s1)
    8000294e:	00005517          	auipc	a0,0x5
    80002952:	a4250513          	addi	a0,a0,-1470 # 80007390 <etext+0x390>
    80002956:	bb5fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    8000295a:	6cbc                	ld	a5,88(s1)
    8000295c:	577d                	li	a4,-1
    8000295e:	fbb8                	sd	a4,112(a5)
  }
}
    80002960:	60e2                	ld	ra,24(sp)
    80002962:	6442                	ld	s0,16(sp)
    80002964:	64a2                	ld	s1,8(sp)
    80002966:	6902                	ld	s2,0(sp)
    80002968:	6105                	addi	sp,sp,32
    8000296a:	8082                	ret

000000008000296c <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    8000296c:	1101                	addi	sp,sp,-32
    8000296e:	ec06                	sd	ra,24(sp)
    80002970:	e822                	sd	s0,16(sp)
    80002972:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002974:	fec40593          	addi	a1,s0,-20
    80002978:	4501                	li	a0,0
    8000297a:	f2fff0ef          	jal	800028a8 <argint>
  kexit(n);
    8000297e:	fec42503          	lw	a0,-20(s0)
    80002982:	f3eff0ef          	jal	800020c0 <kexit>
  return 0; // not reached
}
    80002986:	4501                	li	a0,0
    80002988:	60e2                	ld	ra,24(sp)
    8000298a:	6442                	ld	s0,16(sp)
    8000298c:	6105                	addi	sp,sp,32
    8000298e:	8082                	ret

0000000080002990 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002990:	1141                	addi	sp,sp,-16
    80002992:	e406                	sd	ra,8(sp)
    80002994:	e022                	sd	s0,0(sp)
    80002996:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002998:	fb1fe0ef          	jal	80001948 <myproc>
}
    8000299c:	5908                	lw	a0,48(a0)
    8000299e:	60a2                	ld	ra,8(sp)
    800029a0:	6402                	ld	s0,0(sp)
    800029a2:	0141                	addi	sp,sp,16
    800029a4:	8082                	ret

00000000800029a6 <sys_fork>:

uint64
sys_fork(void)
{
    800029a6:	1141                	addi	sp,sp,-16
    800029a8:	e406                	sd	ra,8(sp)
    800029aa:	e022                	sd	s0,0(sp)
    800029ac:	0800                	addi	s0,sp,16
  return kfork();
    800029ae:	b22ff0ef          	jal	80001cd0 <kfork>
}
    800029b2:	60a2                	ld	ra,8(sp)
    800029b4:	6402                	ld	s0,0(sp)
    800029b6:	0141                	addi	sp,sp,16
    800029b8:	8082                	ret

00000000800029ba <sys_wait>:

uint64
sys_wait(void)
{
    800029ba:	1101                	addi	sp,sp,-32
    800029bc:	ec06                	sd	ra,24(sp)
    800029be:	e822                	sd	s0,16(sp)
    800029c0:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029c2:	fe840593          	addi	a1,s0,-24
    800029c6:	4501                	li	a0,0
    800029c8:	efdff0ef          	jal	800028c4 <argaddr>
  return kwait(p);
    800029cc:	fe843503          	ld	a0,-24(s0)
    800029d0:	851ff0ef          	jal	80002220 <kwait>
}
    800029d4:	60e2                	ld	ra,24(sp)
    800029d6:	6442                	ld	s0,16(sp)
    800029d8:	6105                	addi	sp,sp,32
    800029da:	8082                	ret

00000000800029dc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029dc:	7179                	addi	sp,sp,-48
    800029de:	f406                	sd	ra,40(sp)
    800029e0:	f022                	sd	s0,32(sp)
    800029e2:	ec26                	sd	s1,24(sp)
    800029e4:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800029e6:	fd840593          	addi	a1,s0,-40
    800029ea:	4501                	li	a0,0
    800029ec:	ebdff0ef          	jal	800028a8 <argint>
  argint(1, &t);
    800029f0:	fdc40593          	addi	a1,s0,-36
    800029f4:	4505                	li	a0,1
    800029f6:	eb3ff0ef          	jal	800028a8 <argint>
  addr = myproc()->sz;
    800029fa:	f4ffe0ef          	jal	80001948 <myproc>
    800029fe:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002a00:	fdc42703          	lw	a4,-36(s0)
    80002a04:	4785                	li	a5,1
    80002a06:	02f70763          	beq	a4,a5,80002a34 <sys_sbrk+0x58>
    80002a0a:	fd842783          	lw	a5,-40(s0)
    80002a0e:	0207c363          	bltz	a5,80002a34 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002a12:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002a14:	02000737          	lui	a4,0x2000
    80002a18:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002a1a:	0736                	slli	a4,a4,0xd
    80002a1c:	02f76a63          	bltu	a4,a5,80002a50 <sys_sbrk+0x74>
    80002a20:	0297e863          	bltu	a5,s1,80002a50 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002a24:	f25fe0ef          	jal	80001948 <myproc>
    80002a28:	fd842703          	lw	a4,-40(s0)
    80002a2c:	653c                	ld	a5,72(a0)
    80002a2e:	97ba                	add	a5,a5,a4
    80002a30:	e53c                	sd	a5,72(a0)
    80002a32:	a039                	j	80002a40 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002a34:	fd842503          	lw	a0,-40(s0)
    80002a38:	a36ff0ef          	jal	80001c6e <growproc>
    80002a3c:	00054863          	bltz	a0,80002a4c <sys_sbrk+0x70>
  }
  return addr;
}
    80002a40:	8526                	mv	a0,s1
    80002a42:	70a2                	ld	ra,40(sp)
    80002a44:	7402                	ld	s0,32(sp)
    80002a46:	64e2                	ld	s1,24(sp)
    80002a48:	6145                	addi	sp,sp,48
    80002a4a:	8082                	ret
      return -1;
    80002a4c:	54fd                	li	s1,-1
    80002a4e:	bfcd                	j	80002a40 <sys_sbrk+0x64>
      return -1;
    80002a50:	54fd                	li	s1,-1
    80002a52:	b7fd                	j	80002a40 <sys_sbrk+0x64>

0000000080002a54 <sys_pause>:

uint64
sys_pause(void)
{
    80002a54:	7139                	addi	sp,sp,-64
    80002a56:	fc06                	sd	ra,56(sp)
    80002a58:	f822                	sd	s0,48(sp)
    80002a5a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a5c:	fcc40593          	addi	a1,s0,-52
    80002a60:	4501                	li	a0,0
    80002a62:	e47ff0ef          	jal	800028a8 <argint>
  if (n < 0)
    80002a66:	fcc42783          	lw	a5,-52(s0)
    80002a6a:	0807c063          	bltz	a5,80002aea <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002a6e:	00016517          	auipc	a0,0x16
    80002a72:	9aa50513          	addi	a0,a0,-1622 # 80018418 <tickslock>
    80002a76:	9b2fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002a7a:	fcc42783          	lw	a5,-52(s0)
    80002a7e:	cbb9                	beqz	a5,80002ad4 <sys_pause+0x80>
    80002a80:	f426                	sd	s1,40(sp)
    80002a82:	f04a                	sd	s2,32(sp)
    80002a84:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002a86:	00008997          	auipc	s3,0x8
    80002a8a:	8629a983          	lw	s3,-1950(s3) # 8000a2e8 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002a8e:	00008917          	auipc	s2,0x8
    80002a92:	85a90913          	addi	s2,s2,-1958 # 8000a2e8 <ticks>
    release(&tickslock);
    80002a96:	00016497          	auipc	s1,0x16
    80002a9a:	98248493          	addi	s1,s1,-1662 # 80018418 <tickslock>
    if (killed(myproc())) {
    80002a9e:	eabfe0ef          	jal	80001948 <myproc>
    80002aa2:	f54ff0ef          	jal	800021f6 <killed>
    80002aa6:	e529                	bnez	a0,80002af0 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002aa8:	854a                	mv	a0,s2
    80002aaa:	ceeff0ef          	jal	80001f98 <sleep_prepare>
    release(&tickslock);
    80002aae:	8526                	mv	a0,s1
    80002ab0:	a00fe0ef          	jal	80000cb0 <release>
    sleep();
    80002ab4:	d20ff0ef          	jal	80001fd4 <sleep>
    acquire(&tickslock);
    80002ab8:	8526                	mv	a0,s1
    80002aba:	96efe0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002abe:	00092783          	lw	a5,0(s2)
    80002ac2:	413787bb          	subw	a5,a5,s3
    80002ac6:	fcc42703          	lw	a4,-52(s0)
    80002aca:	fce7eae3          	bltu	a5,a4,80002a9e <sys_pause+0x4a>
    80002ace:	74a2                	ld	s1,40(sp)
    80002ad0:	7902                	ld	s2,32(sp)
    80002ad2:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002ad4:	00016517          	auipc	a0,0x16
    80002ad8:	94450513          	addi	a0,a0,-1724 # 80018418 <tickslock>
    80002adc:	9d4fe0ef          	jal	80000cb0 <release>
  return 0;
    80002ae0:	4501                	li	a0,0
}
    80002ae2:	70e2                	ld	ra,56(sp)
    80002ae4:	7442                	ld	s0,48(sp)
    80002ae6:	6121                	addi	sp,sp,64
    80002ae8:	8082                	ret
    n = 0;
    80002aea:	fc042623          	sw	zero,-52(s0)
    80002aee:	b741                	j	80002a6e <sys_pause+0x1a>
      release(&tickslock);
    80002af0:	00016517          	auipc	a0,0x16
    80002af4:	92850513          	addi	a0,a0,-1752 # 80018418 <tickslock>
    80002af8:	9b8fe0ef          	jal	80000cb0 <release>
      return -1;
    80002afc:	557d                	li	a0,-1
    80002afe:	74a2                	ld	s1,40(sp)
    80002b00:	7902                	ld	s2,32(sp)
    80002b02:	69e2                	ld	s3,24(sp)
    80002b04:	bff9                	j	80002ae2 <sys_pause+0x8e>

0000000080002b06 <sys_kill>:

uint64
sys_kill(void)
{
    80002b06:	1101                	addi	sp,sp,-32
    80002b08:	ec06                	sd	ra,24(sp)
    80002b0a:	e822                	sd	s0,16(sp)
    80002b0c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b0e:	fec40593          	addi	a1,s0,-20
    80002b12:	4501                	li	a0,0
    80002b14:	d95ff0ef          	jal	800028a8 <argint>
  return kkill(pid);
    80002b18:	fec42503          	lw	a0,-20(s0)
    80002b1c:	e4aff0ef          	jal	80002166 <kkill>
}
    80002b20:	60e2                	ld	ra,24(sp)
    80002b22:	6442                	ld	s0,16(sp)
    80002b24:	6105                	addi	sp,sp,32
    80002b26:	8082                	ret

0000000080002b28 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b28:	1101                	addi	sp,sp,-32
    80002b2a:	ec06                	sd	ra,24(sp)
    80002b2c:	e822                	sd	s0,16(sp)
    80002b2e:	e426                	sd	s1,8(sp)
    80002b30:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b32:	00016517          	auipc	a0,0x16
    80002b36:	8e650513          	addi	a0,a0,-1818 # 80018418 <tickslock>
    80002b3a:	8eefe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002b3e:	00007797          	auipc	a5,0x7
    80002b42:	7aa7a783          	lw	a5,1962(a5) # 8000a2e8 <ticks>
    80002b46:	84be                	mv	s1,a5
  release(&tickslock);
    80002b48:	00016517          	auipc	a0,0x16
    80002b4c:	8d050513          	addi	a0,a0,-1840 # 80018418 <tickslock>
    80002b50:	960fe0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002b54:	02049513          	slli	a0,s1,0x20
    80002b58:	9101                	srli	a0,a0,0x20
    80002b5a:	60e2                	ld	ra,24(sp)
    80002b5c:	6442                	ld	s0,16(sp)
    80002b5e:	64a2                	ld	s1,8(sp)
    80002b60:	6105                	addi	sp,sp,32
    80002b62:	8082                	ret

0000000080002b64 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b64:	7179                	addi	sp,sp,-48
    80002b66:	f406                	sd	ra,40(sp)
    80002b68:	f022                	sd	s0,32(sp)
    80002b6a:	ec26                	sd	s1,24(sp)
    80002b6c:	e84a                	sd	s2,16(sp)
    80002b6e:	e44e                	sd	s3,8(sp)
    80002b70:	e052                	sd	s4,0(sp)
    80002b72:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b74:	00005597          	auipc	a1,0x5
    80002b78:	83c58593          	addi	a1,a1,-1988 # 800073b0 <etext+0x3b0>
    80002b7c:	00016517          	auipc	a0,0x16
    80002b80:	8b450513          	addi	a0,a0,-1868 # 80018430 <bcache>
    80002b84:	824fe0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b88:	0001e797          	auipc	a5,0x1e
    80002b8c:	8a878793          	addi	a5,a5,-1880 # 80020430 <bcache+0x8000>
    80002b90:	0001e717          	auipc	a4,0x1e
    80002b94:	b0870713          	addi	a4,a4,-1272 # 80020698 <bcache+0x8268>
    80002b98:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b9c:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002ba0:	00016497          	auipc	s1,0x16
    80002ba4:	8a848493          	addi	s1,s1,-1880 # 80018448 <bcache+0x18>
    b->next = bcache.head.next;
    80002ba8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002baa:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002bac:	00005a17          	auipc	s4,0x5
    80002bb0:	80ca0a13          	addi	s4,s4,-2036 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002bb4:	2b893783          	ld	a5,696(s2)
    80002bb8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002bba:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002bbe:	85d2                	mv	a1,s4
    80002bc0:	01048513          	addi	a0,s1,16
    80002bc4:	41c010ef          	jal	80003fe0 <initsleeplock>
    bcache.head.next->prev = b;
    80002bc8:	2b893783          	ld	a5,696(s2)
    80002bcc:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002bce:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002bd2:	45848493          	addi	s1,s1,1112
    80002bd6:	fd349fe3          	bne	s1,s3,80002bb4 <binit+0x50>
  }
}
    80002bda:	70a2                	ld	ra,40(sp)
    80002bdc:	7402                	ld	s0,32(sp)
    80002bde:	64e2                	ld	s1,24(sp)
    80002be0:	6942                	ld	s2,16(sp)
    80002be2:	69a2                	ld	s3,8(sp)
    80002be4:	6a02                	ld	s4,0(sp)
    80002be6:	6145                	addi	sp,sp,48
    80002be8:	8082                	ret

0000000080002bea <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002bea:	7179                	addi	sp,sp,-48
    80002bec:	f406                	sd	ra,40(sp)
    80002bee:	f022                	sd	s0,32(sp)
    80002bf0:	ec26                	sd	s1,24(sp)
    80002bf2:	e84a                	sd	s2,16(sp)
    80002bf4:	e44e                	sd	s3,8(sp)
    80002bf6:	1800                	addi	s0,sp,48
    80002bf8:	892a                	mv	s2,a0
    80002bfa:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002bfc:	00016517          	auipc	a0,0x16
    80002c00:	83450513          	addi	a0,a0,-1996 # 80018430 <bcache>
    80002c04:	824fe0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002c08:	0001e497          	auipc	s1,0x1e
    80002c0c:	ae04b483          	ld	s1,-1312(s1) # 800206e8 <bcache+0x82b8>
    80002c10:	0001e797          	auipc	a5,0x1e
    80002c14:	a8878793          	addi	a5,a5,-1400 # 80020698 <bcache+0x8268>
    80002c18:	02f48b63          	beq	s1,a5,80002c4e <bread+0x64>
    80002c1c:	873e                	mv	a4,a5
    80002c1e:	a021                	j	80002c26 <bread+0x3c>
    80002c20:	68a4                	ld	s1,80(s1)
    80002c22:	02e48663          	beq	s1,a4,80002c4e <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002c26:	449c                	lw	a5,8(s1)
    80002c28:	ff279ce3          	bne	a5,s2,80002c20 <bread+0x36>
    80002c2c:	44dc                	lw	a5,12(s1)
    80002c2e:	ff3799e3          	bne	a5,s3,80002c20 <bread+0x36>
      b->refcnt++;
    80002c32:	40bc                	lw	a5,64(s1)
    80002c34:	2785                	addiw	a5,a5,1
    80002c36:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c38:	00015517          	auipc	a0,0x15
    80002c3c:	7f850513          	addi	a0,a0,2040 # 80018430 <bcache>
    80002c40:	870fe0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002c44:	01048513          	addi	a0,s1,16
    80002c48:	3ce010ef          	jal	80004016 <acquiresleep>
      return b;
    80002c4c:	a889                	j	80002c9e <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002c4e:	0001e497          	auipc	s1,0x1e
    80002c52:	a924b483          	ld	s1,-1390(s1) # 800206e0 <bcache+0x82b0>
    80002c56:	0001e797          	auipc	a5,0x1e
    80002c5a:	a4278793          	addi	a5,a5,-1470 # 80020698 <bcache+0x8268>
    80002c5e:	00f48863          	beq	s1,a5,80002c6e <bread+0x84>
    80002c62:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002c64:	40bc                	lw	a5,64(s1)
    80002c66:	cb91                	beqz	a5,80002c7a <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002c68:	64a4                	ld	s1,72(s1)
    80002c6a:	fee49de3          	bne	s1,a4,80002c64 <bread+0x7a>
  panic("bget: no buffers");
    80002c6e:	00004517          	auipc	a0,0x4
    80002c72:	75250513          	addi	a0,a0,1874 # 800073c0 <etext+0x3c0>
    80002c76:	bbffd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002c7a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c7e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c82:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c86:	4785                	li	a5,1
    80002c88:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c8a:	00015517          	auipc	a0,0x15
    80002c8e:	7a650513          	addi	a0,a0,1958 # 80018430 <bcache>
    80002c92:	81efe0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002c96:	01048513          	addi	a0,s1,16
    80002c9a:	37c010ef          	jal	80004016 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002c9e:	409c                	lw	a5,0(s1)
    80002ca0:	cb89                	beqz	a5,80002cb2 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ca2:	8526                	mv	a0,s1
    80002ca4:	70a2                	ld	ra,40(sp)
    80002ca6:	7402                	ld	s0,32(sp)
    80002ca8:	64e2                	ld	s1,24(sp)
    80002caa:	6942                	ld	s2,16(sp)
    80002cac:	69a2                	ld	s3,8(sp)
    80002cae:	6145                	addi	sp,sp,48
    80002cb0:	8082                	ret
    virtio_disk_rw(b, 0);
    80002cb2:	4581                	li	a1,0
    80002cb4:	8526                	mv	a0,s1
    80002cb6:	4c1020ef          	jal	80005976 <virtio_disk_rw>
    b->valid = 1;
    80002cba:	4785                	li	a5,1
    80002cbc:	c09c                	sw	a5,0(s1)
  return b;
    80002cbe:	b7d5                	j	80002ca2 <bread+0xb8>

0000000080002cc0 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002cc0:	1101                	addi	sp,sp,-32
    80002cc2:	ec06                	sd	ra,24(sp)
    80002cc4:	e822                	sd	s0,16(sp)
    80002cc6:	e426                	sd	s1,8(sp)
    80002cc8:	1000                	addi	s0,sp,32
    80002cca:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002ccc:	0541                	addi	a0,a0,16
    80002cce:	3d4010ef          	jal	800040a2 <holdingsleep>
    80002cd2:	c911                	beqz	a0,80002ce6 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002cd4:	4585                	li	a1,1
    80002cd6:	8526                	mv	a0,s1
    80002cd8:	49f020ef          	jal	80005976 <virtio_disk_rw>
}
    80002cdc:	60e2                	ld	ra,24(sp)
    80002cde:	6442                	ld	s0,16(sp)
    80002ce0:	64a2                	ld	s1,8(sp)
    80002ce2:	6105                	addi	sp,sp,32
    80002ce4:	8082                	ret
    panic("bwrite");
    80002ce6:	00004517          	auipc	a0,0x4
    80002cea:	6f250513          	addi	a0,a0,1778 # 800073d8 <etext+0x3d8>
    80002cee:	b47fd0ef          	jal	80000834 <panic>

0000000080002cf2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002cf2:	1101                	addi	sp,sp,-32
    80002cf4:	ec06                	sd	ra,24(sp)
    80002cf6:	e822                	sd	s0,16(sp)
    80002cf8:	e426                	sd	s1,8(sp)
    80002cfa:	e04a                	sd	s2,0(sp)
    80002cfc:	1000                	addi	s0,sp,32
    80002cfe:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002d00:	01050913          	addi	s2,a0,16
    80002d04:	854a                	mv	a0,s2
    80002d06:	39c010ef          	jal	800040a2 <holdingsleep>
    80002d0a:	c125                	beqz	a0,80002d6a <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002d0c:	854a                	mv	a0,s2
    80002d0e:	35c010ef          	jal	8000406a <releasesleep>

  acquire(&bcache.lock);
    80002d12:	00015517          	auipc	a0,0x15
    80002d16:	71e50513          	addi	a0,a0,1822 # 80018430 <bcache>
    80002d1a:	f0ffd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002d1e:	40bc                	lw	a5,64(s1)
    80002d20:	37fd                	addiw	a5,a5,-1
    80002d22:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d24:	e79d                	bnez	a5,80002d52 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d26:	68b8                	ld	a4,80(s1)
    80002d28:	64bc                	ld	a5,72(s1)
    80002d2a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d2c:	68b8                	ld	a4,80(s1)
    80002d2e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d30:	0001d797          	auipc	a5,0x1d
    80002d34:	70078793          	addi	a5,a5,1792 # 80020430 <bcache+0x8000>
    80002d38:	2b87b703          	ld	a4,696(a5)
    80002d3c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d3e:	0001e717          	auipc	a4,0x1e
    80002d42:	95a70713          	addi	a4,a4,-1702 # 80020698 <bcache+0x8268>
    80002d46:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d48:	2b87b703          	ld	a4,696(a5)
    80002d4c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d4e:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002d52:	00015517          	auipc	a0,0x15
    80002d56:	6de50513          	addi	a0,a0,1758 # 80018430 <bcache>
    80002d5a:	f57fd0ef          	jal	80000cb0 <release>
}
    80002d5e:	60e2                	ld	ra,24(sp)
    80002d60:	6442                	ld	s0,16(sp)
    80002d62:	64a2                	ld	s1,8(sp)
    80002d64:	6902                	ld	s2,0(sp)
    80002d66:	6105                	addi	sp,sp,32
    80002d68:	8082                	ret
    panic("brelse");
    80002d6a:	00004517          	auipc	a0,0x4
    80002d6e:	67650513          	addi	a0,a0,1654 # 800073e0 <etext+0x3e0>
    80002d72:	ac3fd0ef          	jal	80000834 <panic>

0000000080002d76 <bpin>:

void
bpin(struct buf *b)
{
    80002d76:	1101                	addi	sp,sp,-32
    80002d78:	ec06                	sd	ra,24(sp)
    80002d7a:	e822                	sd	s0,16(sp)
    80002d7c:	e426                	sd	s1,8(sp)
    80002d7e:	1000                	addi	s0,sp,32
    80002d80:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d82:	00015517          	auipc	a0,0x15
    80002d86:	6ae50513          	addi	a0,a0,1710 # 80018430 <bcache>
    80002d8a:	e9ffd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002d8e:	40bc                	lw	a5,64(s1)
    80002d90:	2785                	addiw	a5,a5,1
    80002d92:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d94:	00015517          	auipc	a0,0x15
    80002d98:	69c50513          	addi	a0,a0,1692 # 80018430 <bcache>
    80002d9c:	f15fd0ef          	jal	80000cb0 <release>
}
    80002da0:	60e2                	ld	ra,24(sp)
    80002da2:	6442                	ld	s0,16(sp)
    80002da4:	64a2                	ld	s1,8(sp)
    80002da6:	6105                	addi	sp,sp,32
    80002da8:	8082                	ret

0000000080002daa <bunpin>:

void
bunpin(struct buf *b)
{
    80002daa:	1101                	addi	sp,sp,-32
    80002dac:	ec06                	sd	ra,24(sp)
    80002dae:	e822                	sd	s0,16(sp)
    80002db0:	e426                	sd	s1,8(sp)
    80002db2:	1000                	addi	s0,sp,32
    80002db4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002db6:	00015517          	auipc	a0,0x15
    80002dba:	67a50513          	addi	a0,a0,1658 # 80018430 <bcache>
    80002dbe:	e6bfd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002dc2:	40bc                	lw	a5,64(s1)
    80002dc4:	37fd                	addiw	a5,a5,-1
    80002dc6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002dc8:	00015517          	auipc	a0,0x15
    80002dcc:	66850513          	addi	a0,a0,1640 # 80018430 <bcache>
    80002dd0:	ee1fd0ef          	jal	80000cb0 <release>
}
    80002dd4:	60e2                	ld	ra,24(sp)
    80002dd6:	6442                	ld	s0,16(sp)
    80002dd8:	64a2                	ld	s1,8(sp)
    80002dda:	6105                	addi	sp,sp,32
    80002ddc:	8082                	ret

0000000080002dde <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002dde:	1101                	addi	sp,sp,-32
    80002de0:	ec06                	sd	ra,24(sp)
    80002de2:	e822                	sd	s0,16(sp)
    80002de4:	e426                	sd	s1,8(sp)
    80002de6:	e04a                	sd	s2,0(sp)
    80002de8:	1000                	addi	s0,sp,32
    80002dea:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002dec:	00d5d79b          	srliw	a5,a1,0xd
    80002df0:	0001e597          	auipc	a1,0x1e
    80002df4:	d1c5a583          	lw	a1,-740(a1) # 80020b0c <sb+0x1c>
    80002df8:	9dbd                	addw	a1,a1,a5
    80002dfa:	df1ff0ef          	jal	80002bea <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002dfe:	0074f713          	andi	a4,s1,7
    80002e02:	4785                	li	a5,1
    80002e04:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002e08:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002e0a:	90d9                	srli	s1,s1,0x36
    80002e0c:	00950733          	add	a4,a0,s1
    80002e10:	05874703          	lbu	a4,88(a4)
    80002e14:	00e7f6b3          	and	a3,a5,a4
    80002e18:	c29d                	beqz	a3,80002e3e <bfree+0x60>
    80002e1a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002e1c:	94aa                	add	s1,s1,a0
    80002e1e:	fff7c793          	not	a5,a5
    80002e22:	8f7d                	and	a4,a4,a5
    80002e24:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e28:	080010ef          	jal	80003ea8 <log_write>
  brelse(bp);
    80002e2c:	854a                	mv	a0,s2
    80002e2e:	ec5ff0ef          	jal	80002cf2 <brelse>
}
    80002e32:	60e2                	ld	ra,24(sp)
    80002e34:	6442                	ld	s0,16(sp)
    80002e36:	64a2                	ld	s1,8(sp)
    80002e38:	6902                	ld	s2,0(sp)
    80002e3a:	6105                	addi	sp,sp,32
    80002e3c:	8082                	ret
    panic("freeing free block");
    80002e3e:	00004517          	auipc	a0,0x4
    80002e42:	5aa50513          	addi	a0,a0,1450 # 800073e8 <etext+0x3e8>
    80002e46:	9effd0ef          	jal	80000834 <panic>

0000000080002e4a <balloc>:
{
    80002e4a:	715d                	addi	sp,sp,-80
    80002e4c:	e486                	sd	ra,72(sp)
    80002e4e:	e0a2                	sd	s0,64(sp)
    80002e50:	fc26                	sd	s1,56(sp)
    80002e52:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002e54:	0001e797          	auipc	a5,0x1e
    80002e58:	ca07a783          	lw	a5,-864(a5) # 80020af4 <sb+0x4>
    80002e5c:	0e078263          	beqz	a5,80002f40 <balloc+0xf6>
    80002e60:	f84a                	sd	s2,48(sp)
    80002e62:	f44e                	sd	s3,40(sp)
    80002e64:	f052                	sd	s4,32(sp)
    80002e66:	ec56                	sd	s5,24(sp)
    80002e68:	e85a                	sd	s6,16(sp)
    80002e6a:	e45e                	sd	s7,8(sp)
    80002e6c:	e062                	sd	s8,0(sp)
    80002e6e:	8baa                	mv	s7,a0
    80002e70:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e72:	0001eb17          	auipc	s6,0x1e
    80002e76:	c7eb0b13          	addi	s6,s6,-898 # 80020af0 <sb>
      m = 1 << (bi % 8);
    80002e7a:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e7c:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002e7e:	6c09                	lui	s8,0x2
    80002e80:	a09d                	j	80002ee6 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002e82:	97ca                	add	a5,a5,s2
    80002e84:	8e55                	or	a2,a2,a3
    80002e86:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e8a:	854a                	mv	a0,s2
    80002e8c:	01c010ef          	jal	80003ea8 <log_write>
        brelse(bp);
    80002e90:	854a                	mv	a0,s2
    80002e92:	e61ff0ef          	jal	80002cf2 <brelse>
  bp = bread(dev, bno);
    80002e96:	85a6                	mv	a1,s1
    80002e98:	855e                	mv	a0,s7
    80002e9a:	d51ff0ef          	jal	80002bea <bread>
    80002e9e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002ea0:	40000613          	li	a2,1024
    80002ea4:	4581                	li	a1,0
    80002ea6:	05850513          	addi	a0,a0,88
    80002eaa:	e3ffd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    80002eae:	854a                	mv	a0,s2
    80002eb0:	7f9000ef          	jal	80003ea8 <log_write>
  brelse(bp);
    80002eb4:	854a                	mv	a0,s2
    80002eb6:	e3dff0ef          	jal	80002cf2 <brelse>
}
    80002eba:	7942                	ld	s2,48(sp)
    80002ebc:	79a2                	ld	s3,40(sp)
    80002ebe:	7a02                	ld	s4,32(sp)
    80002ec0:	6ae2                	ld	s5,24(sp)
    80002ec2:	6b42                	ld	s6,16(sp)
    80002ec4:	6ba2                	ld	s7,8(sp)
    80002ec6:	6c02                	ld	s8,0(sp)
}
    80002ec8:	8526                	mv	a0,s1
    80002eca:	60a6                	ld	ra,72(sp)
    80002ecc:	6406                	ld	s0,64(sp)
    80002ece:	74e2                	ld	s1,56(sp)
    80002ed0:	6161                	addi	sp,sp,80
    80002ed2:	8082                	ret
    brelse(bp);
    80002ed4:	854a                	mv	a0,s2
    80002ed6:	e1dff0ef          	jal	80002cf2 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002eda:	015c0abb          	addw	s5,s8,s5
    80002ede:	004b2783          	lw	a5,4(s6)
    80002ee2:	04faf863          	bgeu	s5,a5,80002f32 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002ee6:	40dad59b          	sraiw	a1,s5,0xd
    80002eea:	01cb2783          	lw	a5,28(s6)
    80002eee:	9dbd                	addw	a1,a1,a5
    80002ef0:	855e                	mv	a0,s7
    80002ef2:	cf9ff0ef          	jal	80002bea <bread>
    80002ef6:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002ef8:	004b2503          	lw	a0,4(s6)
    80002efc:	84d6                	mv	s1,s5
    80002efe:	4701                	li	a4,0
    80002f00:	fca4fae3          	bgeu	s1,a0,80002ed4 <balloc+0x8a>
      m = 1 << (bi % 8);
    80002f04:	00777693          	andi	a3,a4,7
    80002f08:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002f0c:	41f7579b          	sraiw	a5,a4,0x1f
    80002f10:	01d7d79b          	srliw	a5,a5,0x1d
    80002f14:	9fb9                	addw	a5,a5,a4
    80002f16:	4037d79b          	sraiw	a5,a5,0x3
    80002f1a:	00f90633          	add	a2,s2,a5
    80002f1e:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80002f22:	00c6f5b3          	and	a1,a3,a2
    80002f26:	ddb1                	beqz	a1,80002e82 <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f28:	2705                	addiw	a4,a4,1
    80002f2a:	2485                	addiw	s1,s1,1
    80002f2c:	fd471ae3          	bne	a4,s4,80002f00 <balloc+0xb6>
    80002f30:	b755                	j	80002ed4 <balloc+0x8a>
    80002f32:	7942                	ld	s2,48(sp)
    80002f34:	79a2                	ld	s3,40(sp)
    80002f36:	7a02                	ld	s4,32(sp)
    80002f38:	6ae2                	ld	s5,24(sp)
    80002f3a:	6b42                	ld	s6,16(sp)
    80002f3c:	6ba2                	ld	s7,8(sp)
    80002f3e:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    80002f40:	00004517          	auipc	a0,0x4
    80002f44:	4c050513          	addi	a0,a0,1216 # 80007400 <etext+0x400>
    80002f48:	dc2fd0ef          	jal	8000050a <printk>
  return 0;
    80002f4c:	4481                	li	s1,0
    80002f4e:	bfad                	j	80002ec8 <balloc+0x7e>

0000000080002f50 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f50:	7179                	addi	sp,sp,-48
    80002f52:	f406                	sd	ra,40(sp)
    80002f54:	f022                	sd	s0,32(sp)
    80002f56:	ec26                	sd	s1,24(sp)
    80002f58:	e84a                	sd	s2,16(sp)
    80002f5a:	e44e                	sd	s3,8(sp)
    80002f5c:	1800                	addi	s0,sp,48
    80002f5e:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80002f60:	47ad                	li	a5,11
    80002f62:	02b7e363          	bltu	a5,a1,80002f88 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80002f66:	02059793          	slli	a5,a1,0x20
    80002f6a:	01e7d593          	srli	a1,a5,0x1e
    80002f6e:	00b509b3          	add	s3,a0,a1
    80002f72:	0509a483          	lw	s1,80(s3)
    80002f76:	e0b5                	bnez	s1,80002fda <bmap+0x8a>
      addr = balloc(ip->dev);
    80002f78:	4108                	lw	a0,0(a0)
    80002f7a:	ed1ff0ef          	jal	80002e4a <balloc>
    80002f7e:	84aa                	mv	s1,a0
      if (addr == 0)
    80002f80:	cd29                	beqz	a0,80002fda <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80002f82:	04a9a823          	sw	a0,80(s3)
    80002f86:	a891                	j	80002fda <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f88:	ff45879b          	addiw	a5,a1,-12
    80002f8c:	873e                	mv	a4,a5
    80002f8e:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    80002f90:	0ff00793          	li	a5,255
    80002f94:	06e7e763          	bltu	a5,a4,80003002 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80002f98:	08052483          	lw	s1,128(a0)
    80002f9c:	e891                	bnez	s1,80002fb0 <bmap+0x60>
      addr = balloc(ip->dev);
    80002f9e:	4108                	lw	a0,0(a0)
    80002fa0:	eabff0ef          	jal	80002e4a <balloc>
    80002fa4:	84aa                	mv	s1,a0
      if (addr == 0)
    80002fa6:	c915                	beqz	a0,80002fda <bmap+0x8a>
    80002fa8:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002faa:	08a92023          	sw	a0,128(s2)
    80002fae:	a011                	j	80002fb2 <bmap+0x62>
    80002fb0:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002fb2:	85a6                	mv	a1,s1
    80002fb4:	00092503          	lw	a0,0(s2)
    80002fb8:	c33ff0ef          	jal	80002bea <bread>
    80002fbc:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80002fbe:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80002fc2:	02099713          	slli	a4,s3,0x20
    80002fc6:	01e75593          	srli	a1,a4,0x1e
    80002fca:	97ae                	add	a5,a5,a1
    80002fcc:	89be                	mv	s3,a5
    80002fce:	4384                	lw	s1,0(a5)
    80002fd0:	cc89                	beqz	s1,80002fea <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002fd2:	8552                	mv	a0,s4
    80002fd4:	d1fff0ef          	jal	80002cf2 <brelse>
    return addr;
    80002fd8:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002fda:	8526                	mv	a0,s1
    80002fdc:	70a2                	ld	ra,40(sp)
    80002fde:	7402                	ld	s0,32(sp)
    80002fe0:	64e2                	ld	s1,24(sp)
    80002fe2:	6942                	ld	s2,16(sp)
    80002fe4:	69a2                	ld	s3,8(sp)
    80002fe6:	6145                	addi	sp,sp,48
    80002fe8:	8082                	ret
      addr = balloc(ip->dev);
    80002fea:	00092503          	lw	a0,0(s2)
    80002fee:	e5dff0ef          	jal	80002e4a <balloc>
    80002ff2:	84aa                	mv	s1,a0
      if (addr) {
    80002ff4:	dd79                	beqz	a0,80002fd2 <bmap+0x82>
        a[bn] = addr;
    80002ff6:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80002ffa:	8552                	mv	a0,s4
    80002ffc:	6ad000ef          	jal	80003ea8 <log_write>
    80003000:	bfc9                	j	80002fd2 <bmap+0x82>
    80003002:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003004:	00004517          	auipc	a0,0x4
    80003008:	41450513          	addi	a0,a0,1044 # 80007418 <etext+0x418>
    8000300c:	829fd0ef          	jal	80000834 <panic>

0000000080003010 <iget>:
{
    80003010:	7179                	addi	sp,sp,-48
    80003012:	f406                	sd	ra,40(sp)
    80003014:	f022                	sd	s0,32(sp)
    80003016:	ec26                	sd	s1,24(sp)
    80003018:	e84a                	sd	s2,16(sp)
    8000301a:	e44e                	sd	s3,8(sp)
    8000301c:	e052                	sd	s4,0(sp)
    8000301e:	1800                	addi	s0,sp,48
    80003020:	892a                	mv	s2,a0
    80003022:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003024:	0001e517          	auipc	a0,0x1e
    80003028:	aec50513          	addi	a0,a0,-1300 # 80020b10 <itable>
    8000302c:	bfdfd0ef          	jal	80000c28 <acquire>
  empty = 0;
    80003030:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003032:	0001e497          	auipc	s1,0x1e
    80003036:	af648493          	addi	s1,s1,-1290 # 80020b28 <itable+0x18>
    8000303a:	0001f697          	auipc	a3,0x1f
    8000303e:	57e68693          	addi	a3,a3,1406 # 800225b8 <log>
    80003042:	a809                	j	80003054 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003044:	e781                	bnez	a5,8000304c <iget+0x3c>
    80003046:	00099363          	bnez	s3,8000304c <iget+0x3c>
      empty = ip;
    8000304a:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000304c:	08848493          	addi	s1,s1,136
    80003050:	02d48563          	beq	s1,a3,8000307a <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80003054:	449c                	lw	a5,8(s1)
    80003056:	fef057e3          	blez	a5,80003044 <iget+0x34>
    8000305a:	4098                	lw	a4,0(s1)
    8000305c:	ff2718e3          	bne	a4,s2,8000304c <iget+0x3c>
    80003060:	40d8                	lw	a4,4(s1)
    80003062:	ff4715e3          	bne	a4,s4,8000304c <iget+0x3c>
      ip->ref++;
    80003066:	2785                	addiw	a5,a5,1
    80003068:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000306a:	0001e517          	auipc	a0,0x1e
    8000306e:	aa650513          	addi	a0,a0,-1370 # 80020b10 <itable>
    80003072:	c3ffd0ef          	jal	80000cb0 <release>
      return ip;
    80003076:	89a6                	mv	s3,s1
    80003078:	a015                	j	8000309c <iget+0x8c>
  if (empty == 0)
    8000307a:	02098a63          	beqz	s3,800030ae <iget+0x9e>
  ip->dev = dev;
    8000307e:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003082:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003086:	4785                	li	a5,1
    80003088:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    8000308c:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003090:	0001e517          	auipc	a0,0x1e
    80003094:	a8050513          	addi	a0,a0,-1408 # 80020b10 <itable>
    80003098:	c19fd0ef          	jal	80000cb0 <release>
}
    8000309c:	854e                	mv	a0,s3
    8000309e:	70a2                	ld	ra,40(sp)
    800030a0:	7402                	ld	s0,32(sp)
    800030a2:	64e2                	ld	s1,24(sp)
    800030a4:	6942                	ld	s2,16(sp)
    800030a6:	69a2                	ld	s3,8(sp)
    800030a8:	6a02                	ld	s4,0(sp)
    800030aa:	6145                	addi	sp,sp,48
    800030ac:	8082                	ret
    panic("iget: no inodes");
    800030ae:	00004517          	auipc	a0,0x4
    800030b2:	38250513          	addi	a0,a0,898 # 80007430 <etext+0x430>
    800030b6:	f7efd0ef          	jal	80000834 <panic>

00000000800030ba <iinit>:
{
    800030ba:	7179                	addi	sp,sp,-48
    800030bc:	f406                	sd	ra,40(sp)
    800030be:	f022                	sd	s0,32(sp)
    800030c0:	ec26                	sd	s1,24(sp)
    800030c2:	e84a                	sd	s2,16(sp)
    800030c4:	e44e                	sd	s3,8(sp)
    800030c6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800030c8:	00004597          	auipc	a1,0x4
    800030cc:	37858593          	addi	a1,a1,888 # 80007440 <etext+0x440>
    800030d0:	0001e517          	auipc	a0,0x1e
    800030d4:	a4050513          	addi	a0,a0,-1472 # 80020b10 <itable>
    800030d8:	ad1fd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    800030dc:	0001e497          	auipc	s1,0x1e
    800030e0:	a5c48493          	addi	s1,s1,-1444 # 80020b38 <itable+0x28>
    800030e4:	0001f997          	auipc	s3,0x1f
    800030e8:	4e498993          	addi	s3,s3,1252 # 800225c8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800030ec:	00004917          	auipc	s2,0x4
    800030f0:	35c90913          	addi	s2,s2,860 # 80007448 <etext+0x448>
    800030f4:	85ca                	mv	a1,s2
    800030f6:	8526                	mv	a0,s1
    800030f8:	6e9000ef          	jal	80003fe0 <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    800030fc:	08848493          	addi	s1,s1,136
    80003100:	ff349ae3          	bne	s1,s3,800030f4 <iinit+0x3a>
}
    80003104:	70a2                	ld	ra,40(sp)
    80003106:	7402                	ld	s0,32(sp)
    80003108:	64e2                	ld	s1,24(sp)
    8000310a:	6942                	ld	s2,16(sp)
    8000310c:	69a2                	ld	s3,8(sp)
    8000310e:	6145                	addi	sp,sp,48
    80003110:	8082                	ret

0000000080003112 <ialloc>:
{
    80003112:	7139                	addi	sp,sp,-64
    80003114:	fc06                	sd	ra,56(sp)
    80003116:	f822                	sd	s0,48(sp)
    80003118:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000311a:	0001e717          	auipc	a4,0x1e
    8000311e:	9e272703          	lw	a4,-1566(a4) # 80020afc <sb+0xc>
    80003122:	4785                	li	a5,1
    80003124:	06e7f063          	bgeu	a5,a4,80003184 <ialloc+0x72>
    80003128:	f426                	sd	s1,40(sp)
    8000312a:	f04a                	sd	s2,32(sp)
    8000312c:	ec4e                	sd	s3,24(sp)
    8000312e:	e852                	sd	s4,16(sp)
    80003130:	e456                	sd	s5,8(sp)
    80003132:	e05a                	sd	s6,0(sp)
    80003134:	8aaa                	mv	s5,a0
    80003136:	8b2e                	mv	s6,a1
    80003138:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    8000313a:	0001ea17          	auipc	s4,0x1e
    8000313e:	9b6a0a13          	addi	s4,s4,-1610 # 80020af0 <sb>
    80003142:	00495593          	srli	a1,s2,0x4
    80003146:	018a2783          	lw	a5,24(s4)
    8000314a:	9dbd                	addw	a1,a1,a5
    8000314c:	8556                	mv	a0,s5
    8000314e:	a9dff0ef          	jal	80002bea <bread>
    80003152:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003154:	05850993          	addi	s3,a0,88
    80003158:	00f97793          	andi	a5,s2,15
    8000315c:	079a                	slli	a5,a5,0x6
    8000315e:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    80003160:	00099783          	lh	a5,0(s3)
    80003164:	cb9d                	beqz	a5,8000319a <ialloc+0x88>
    brelse(bp);
    80003166:	b8dff0ef          	jal	80002cf2 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000316a:	0905                	addi	s2,s2,1
    8000316c:	00ca2703          	lw	a4,12(s4)
    80003170:	0009079b          	sext.w	a5,s2
    80003174:	fce7e7e3          	bltu	a5,a4,80003142 <ialloc+0x30>
    80003178:	74a2                	ld	s1,40(sp)
    8000317a:	7902                	ld	s2,32(sp)
    8000317c:	69e2                	ld	s3,24(sp)
    8000317e:	6a42                	ld	s4,16(sp)
    80003180:	6aa2                	ld	s5,8(sp)
    80003182:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    80003184:	00004517          	auipc	a0,0x4
    80003188:	2cc50513          	addi	a0,a0,716 # 80007450 <etext+0x450>
    8000318c:	b7efd0ef          	jal	8000050a <printk>
  return 0;
    80003190:	4501                	li	a0,0
}
    80003192:	70e2                	ld	ra,56(sp)
    80003194:	7442                	ld	s0,48(sp)
    80003196:	6121                	addi	sp,sp,64
    80003198:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000319a:	04000613          	li	a2,64
    8000319e:	4581                	li	a1,0
    800031a0:	854e                	mv	a0,s3
    800031a2:	b47fd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    800031a6:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800031aa:	8526                	mv	a0,s1
    800031ac:	4fd000ef          	jal	80003ea8 <log_write>
      brelse(bp);
    800031b0:	8526                	mv	a0,s1
    800031b2:	b41ff0ef          	jal	80002cf2 <brelse>
      return iget(dev, inum);
    800031b6:	0009059b          	sext.w	a1,s2
    800031ba:	8556                	mv	a0,s5
    800031bc:	e55ff0ef          	jal	80003010 <iget>
    800031c0:	74a2                	ld	s1,40(sp)
    800031c2:	7902                	ld	s2,32(sp)
    800031c4:	69e2                	ld	s3,24(sp)
    800031c6:	6a42                	ld	s4,16(sp)
    800031c8:	6aa2                	ld	s5,8(sp)
    800031ca:	6b02                	ld	s6,0(sp)
    800031cc:	b7d9                	j	80003192 <ialloc+0x80>

00000000800031ce <iupdate>:
{
    800031ce:	1101                	addi	sp,sp,-32
    800031d0:	ec06                	sd	ra,24(sp)
    800031d2:	e822                	sd	s0,16(sp)
    800031d4:	e426                	sd	s1,8(sp)
    800031d6:	e04a                	sd	s2,0(sp)
    800031d8:	1000                	addi	s0,sp,32
    800031da:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800031dc:	415c                	lw	a5,4(a0)
    800031de:	0047d79b          	srliw	a5,a5,0x4
    800031e2:	0001e597          	auipc	a1,0x1e
    800031e6:	9265a583          	lw	a1,-1754(a1) # 80020b08 <sb+0x18>
    800031ea:	9dbd                	addw	a1,a1,a5
    800031ec:	4108                	lw	a0,0(a0)
    800031ee:	9fdff0ef          	jal	80002bea <bread>
    800031f2:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    800031f4:	05850793          	addi	a5,a0,88
    800031f8:	40d8                	lw	a4,4(s1)
    800031fa:	8b3d                	andi	a4,a4,15
    800031fc:	071a                	slli	a4,a4,0x6
    800031fe:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003200:	04449703          	lh	a4,68(s1)
    80003204:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003208:	04649703          	lh	a4,70(s1)
    8000320c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003210:	04849703          	lh	a4,72(s1)
    80003214:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003218:	04a49703          	lh	a4,74(s1)
    8000321c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003220:	44f8                	lw	a4,76(s1)
    80003222:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003224:	03400613          	li	a2,52
    80003228:	05048593          	addi	a1,s1,80
    8000322c:	00c78513          	addi	a0,a5,12
    80003230:	b19fd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    80003234:	854a                	mv	a0,s2
    80003236:	473000ef          	jal	80003ea8 <log_write>
  brelse(bp);
    8000323a:	854a                	mv	a0,s2
    8000323c:	ab7ff0ef          	jal	80002cf2 <brelse>
}
    80003240:	60e2                	ld	ra,24(sp)
    80003242:	6442                	ld	s0,16(sp)
    80003244:	64a2                	ld	s1,8(sp)
    80003246:	6902                	ld	s2,0(sp)
    80003248:	6105                	addi	sp,sp,32
    8000324a:	8082                	ret

000000008000324c <idup>:
{
    8000324c:	1101                	addi	sp,sp,-32
    8000324e:	ec06                	sd	ra,24(sp)
    80003250:	e822                	sd	s0,16(sp)
    80003252:	e426                	sd	s1,8(sp)
    80003254:	1000                	addi	s0,sp,32
    80003256:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003258:	0001e517          	auipc	a0,0x1e
    8000325c:	8b850513          	addi	a0,a0,-1864 # 80020b10 <itable>
    80003260:	9c9fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003264:	449c                	lw	a5,8(s1)
    80003266:	2785                	addiw	a5,a5,1
    80003268:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000326a:	0001e517          	auipc	a0,0x1e
    8000326e:	8a650513          	addi	a0,a0,-1882 # 80020b10 <itable>
    80003272:	a3ffd0ef          	jal	80000cb0 <release>
}
    80003276:	8526                	mv	a0,s1
    80003278:	60e2                	ld	ra,24(sp)
    8000327a:	6442                	ld	s0,16(sp)
    8000327c:	64a2                	ld	s1,8(sp)
    8000327e:	6105                	addi	sp,sp,32
    80003280:	8082                	ret

0000000080003282 <ilock>:
{
    80003282:	1101                	addi	sp,sp,-32
    80003284:	ec06                	sd	ra,24(sp)
    80003286:	e822                	sd	s0,16(sp)
    80003288:	e426                	sd	s1,8(sp)
    8000328a:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    8000328c:	cd19                	beqz	a0,800032aa <ilock+0x28>
    8000328e:	84aa                	mv	s1,a0
    80003290:	451c                	lw	a5,8(a0)
    80003292:	00f05c63          	blez	a5,800032aa <ilock+0x28>
  acquiresleep(&ip->lock);
    80003296:	0541                	addi	a0,a0,16
    80003298:	57f000ef          	jal	80004016 <acquiresleep>
  if (ip->valid == 0) {
    8000329c:	40bc                	lw	a5,64(s1)
    8000329e:	cf89                	beqz	a5,800032b8 <ilock+0x36>
}
    800032a0:	60e2                	ld	ra,24(sp)
    800032a2:	6442                	ld	s0,16(sp)
    800032a4:	64a2                	ld	s1,8(sp)
    800032a6:	6105                	addi	sp,sp,32
    800032a8:	8082                	ret
    800032aa:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800032ac:	00004517          	auipc	a0,0x4
    800032b0:	1bc50513          	addi	a0,a0,444 # 80007468 <etext+0x468>
    800032b4:	d80fd0ef          	jal	80000834 <panic>
    800032b8:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032ba:	40dc                	lw	a5,4(s1)
    800032bc:	0047d79b          	srliw	a5,a5,0x4
    800032c0:	0001e597          	auipc	a1,0x1e
    800032c4:	8485a583          	lw	a1,-1976(a1) # 80020b08 <sb+0x18>
    800032c8:	9dbd                	addw	a1,a1,a5
    800032ca:	4088                	lw	a0,0(s1)
    800032cc:	91fff0ef          	jal	80002bea <bread>
    800032d0:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    800032d2:	05850593          	addi	a1,a0,88
    800032d6:	40dc                	lw	a5,4(s1)
    800032d8:	8bbd                	andi	a5,a5,15
    800032da:	079a                	slli	a5,a5,0x6
    800032dc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800032de:	00059783          	lh	a5,0(a1)
    800032e2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800032e6:	00259783          	lh	a5,2(a1)
    800032ea:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800032ee:	00459783          	lh	a5,4(a1)
    800032f2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800032f6:	00659783          	lh	a5,6(a1)
    800032fa:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800032fe:	459c                	lw	a5,8(a1)
    80003300:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003302:	03400613          	li	a2,52
    80003306:	05b1                	addi	a1,a1,12
    80003308:	05048513          	addi	a0,s1,80
    8000330c:	a3dfd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    80003310:	854a                	mv	a0,s2
    80003312:	9e1ff0ef          	jal	80002cf2 <brelse>
    ip->valid = 1;
    80003316:	4785                	li	a5,1
    80003318:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    8000331a:	04449783          	lh	a5,68(s1)
    8000331e:	c399                	beqz	a5,80003324 <ilock+0xa2>
    80003320:	6902                	ld	s2,0(sp)
    80003322:	bfbd                	j	800032a0 <ilock+0x1e>
      panic("ilock: no type");
    80003324:	00004517          	auipc	a0,0x4
    80003328:	14c50513          	addi	a0,a0,332 # 80007470 <etext+0x470>
    8000332c:	d08fd0ef          	jal	80000834 <panic>

0000000080003330 <iunlock>:
{
    80003330:	1101                	addi	sp,sp,-32
    80003332:	ec06                	sd	ra,24(sp)
    80003334:	e822                	sd	s0,16(sp)
    80003336:	e426                	sd	s1,8(sp)
    80003338:	e04a                	sd	s2,0(sp)
    8000333a:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000333c:	c505                	beqz	a0,80003364 <iunlock+0x34>
    8000333e:	84aa                	mv	s1,a0
    80003340:	01050913          	addi	s2,a0,16
    80003344:	854a                	mv	a0,s2
    80003346:	55d000ef          	jal	800040a2 <holdingsleep>
    8000334a:	cd09                	beqz	a0,80003364 <iunlock+0x34>
    8000334c:	449c                	lw	a5,8(s1)
    8000334e:	00f05b63          	blez	a5,80003364 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003352:	854a                	mv	a0,s2
    80003354:	517000ef          	jal	8000406a <releasesleep>
}
    80003358:	60e2                	ld	ra,24(sp)
    8000335a:	6442                	ld	s0,16(sp)
    8000335c:	64a2                	ld	s1,8(sp)
    8000335e:	6902                	ld	s2,0(sp)
    80003360:	6105                	addi	sp,sp,32
    80003362:	8082                	ret
    panic("iunlock");
    80003364:	00004517          	auipc	a0,0x4
    80003368:	11c50513          	addi	a0,a0,284 # 80007480 <etext+0x480>
    8000336c:	cc8fd0ef          	jal	80000834 <panic>

0000000080003370 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003370:	7179                	addi	sp,sp,-48
    80003372:	f406                	sd	ra,40(sp)
    80003374:	f022                	sd	s0,32(sp)
    80003376:	ec26                	sd	s1,24(sp)
    80003378:	e84a                	sd	s2,16(sp)
    8000337a:	e44e                	sd	s3,8(sp)
    8000337c:	1800                	addi	s0,sp,48
    8000337e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    80003380:	05050493          	addi	s1,a0,80
    80003384:	08050913          	addi	s2,a0,128
    80003388:	a021                	j	80003390 <itrunc+0x20>
    8000338a:	0491                	addi	s1,s1,4
    8000338c:	01248b63          	beq	s1,s2,800033a2 <itrunc+0x32>
    if (ip->addrs[i]) {
    80003390:	408c                	lw	a1,0(s1)
    80003392:	dde5                	beqz	a1,8000338a <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003394:	0009a503          	lw	a0,0(s3)
    80003398:	a47ff0ef          	jal	80002dde <bfree>
      ip->addrs[i] = 0;
    8000339c:	0004a023          	sw	zero,0(s1)
    800033a0:	b7ed                	j	8000338a <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800033a2:	0809a583          	lw	a1,128(s3)
    800033a6:	ed89                	bnez	a1,800033c0 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033a8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800033ac:	854e                	mv	a0,s3
    800033ae:	e21ff0ef          	jal	800031ce <iupdate>
}
    800033b2:	70a2                	ld	ra,40(sp)
    800033b4:	7402                	ld	s0,32(sp)
    800033b6:	64e2                	ld	s1,24(sp)
    800033b8:	6942                	ld	s2,16(sp)
    800033ba:	69a2                	ld	s3,8(sp)
    800033bc:	6145                	addi	sp,sp,48
    800033be:	8082                	ret
    800033c0:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800033c2:	0009a503          	lw	a0,0(s3)
    800033c6:	825ff0ef          	jal	80002bea <bread>
    800033ca:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    800033cc:	05850493          	addi	s1,a0,88
    800033d0:	45850913          	addi	s2,a0,1112
    800033d4:	a021                	j	800033dc <itrunc+0x6c>
    800033d6:	0491                	addi	s1,s1,4
    800033d8:	01248963          	beq	s1,s2,800033ea <itrunc+0x7a>
      if (a[j])
    800033dc:	408c                	lw	a1,0(s1)
    800033de:	dde5                	beqz	a1,800033d6 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800033e0:	0009a503          	lw	a0,0(s3)
    800033e4:	9fbff0ef          	jal	80002dde <bfree>
    800033e8:	b7fd                	j	800033d6 <itrunc+0x66>
    brelse(bp);
    800033ea:	8552                	mv	a0,s4
    800033ec:	907ff0ef          	jal	80002cf2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800033f0:	0809a583          	lw	a1,128(s3)
    800033f4:	0009a503          	lw	a0,0(s3)
    800033f8:	9e7ff0ef          	jal	80002dde <bfree>
    ip->addrs[NDIRECT] = 0;
    800033fc:	0809a023          	sw	zero,128(s3)
    80003400:	6a02                	ld	s4,0(sp)
    80003402:	b75d                	j	800033a8 <itrunc+0x38>

0000000080003404 <iput>:
{
    80003404:	7179                	addi	sp,sp,-48
    80003406:	f406                	sd	ra,40(sp)
    80003408:	f022                	sd	s0,32(sp)
    8000340a:	ec26                	sd	s1,24(sp)
    8000340c:	1800                	addi	s0,sp,48
    8000340e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003410:	0001d517          	auipc	a0,0x1d
    80003414:	70050513          	addi	a0,a0,1792 # 80020b10 <itable>
    80003418:	811fd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    8000341c:	449c                	lw	a5,8(s1)
    8000341e:	4705                	li	a4,1
    80003420:	00e78f63          	beq	a5,a4,8000343e <iput+0x3a>
  ip->ref--;
    80003424:	37fd                	addiw	a5,a5,-1
    80003426:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003428:	0001d517          	auipc	a0,0x1d
    8000342c:	6e850513          	addi	a0,a0,1768 # 80020b10 <itable>
    80003430:	881fd0ef          	jal	80000cb0 <release>
}
    80003434:	70a2                	ld	ra,40(sp)
    80003436:	7402                	ld	s0,32(sp)
    80003438:	64e2                	ld	s1,24(sp)
    8000343a:	6145                	addi	sp,sp,48
    8000343c:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    8000343e:	40b8                	lw	a4,64(s1)
    80003440:	d375                	beqz	a4,80003424 <iput+0x20>
    80003442:	e84a                	sd	s2,16(sp)
    80003444:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    80003446:	0004aa03          	lw	s4,0(s1)
    8000344a:	0044a903          	lw	s2,4(s1)
  if (last) {
    8000344e:	04a49703          	lh	a4,74(s1)
    80003452:	ef3d                	bnez	a4,800034d0 <iput+0xcc>
    80003454:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    80003456:	01048793          	addi	a5,s1,16
    8000345a:	89be                	mv	s3,a5
    8000345c:	853e                	mv	a0,a5
    8000345e:	3b9000ef          	jal	80004016 <acquiresleep>
    release(&itable.lock);
    80003462:	0001d517          	auipc	a0,0x1d
    80003466:	6ae50513          	addi	a0,a0,1710 # 80020b10 <itable>
    8000346a:	847fd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    8000346e:	8526                	mv	a0,s1
    80003470:	f01ff0ef          	jal	80003370 <itrunc>
    ip->valid = 0;
    80003474:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003478:	854e                	mv	a0,s3
    8000347a:	3f1000ef          	jal	8000406a <releasesleep>
    acquire(&itable.lock);
    8000347e:	0001d517          	auipc	a0,0x1d
    80003482:	69250513          	addi	a0,a0,1682 # 80020b10 <itable>
    80003486:	fa2fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    8000348a:	449c                	lw	a5,8(s1)
    8000348c:	37fd                	addiw	a5,a5,-1
    8000348e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003490:	0001d517          	auipc	a0,0x1d
    80003494:	68050513          	addi	a0,a0,1664 # 80020b10 <itable>
    80003498:	819fd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000349c:	0049579b          	srliw	a5,s2,0x4
    800034a0:	0001d597          	auipc	a1,0x1d
    800034a4:	6685a583          	lw	a1,1640(a1) # 80020b08 <sb+0x18>
    800034a8:	9dbd                	addw	a1,a1,a5
    800034aa:	8552                	mv	a0,s4
    800034ac:	f3eff0ef          	jal	80002bea <bread>
    800034b0:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800034b2:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    800034b6:	079a                	slli	a5,a5,0x6
    800034b8:	97aa                	add	a5,a5,a0
    800034ba:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    800034be:	1eb000ef          	jal	80003ea8 <log_write>
  brelse(bp);
    800034c2:	8526                	mv	a0,s1
    800034c4:	82fff0ef          	jal	80002cf2 <brelse>
}
    800034c8:	6942                	ld	s2,16(sp)
    800034ca:	69a2                	ld	s3,8(sp)
    800034cc:	6a02                	ld	s4,0(sp)
    800034ce:	b79d                	j	80003434 <iput+0x30>
    800034d0:	6942                	ld	s2,16(sp)
    800034d2:	6a02                	ld	s4,0(sp)
    800034d4:	bf81                	j	80003424 <iput+0x20>

00000000800034d6 <iunlockput>:
{
    800034d6:	1101                	addi	sp,sp,-32
    800034d8:	ec06                	sd	ra,24(sp)
    800034da:	e822                	sd	s0,16(sp)
    800034dc:	e426                	sd	s1,8(sp)
    800034de:	1000                	addi	s0,sp,32
    800034e0:	84aa                	mv	s1,a0
  iunlock(ip);
    800034e2:	e4fff0ef          	jal	80003330 <iunlock>
  iput(ip);
    800034e6:	8526                	mv	a0,s1
    800034e8:	f1dff0ef          	jal	80003404 <iput>
}
    800034ec:	60e2                	ld	ra,24(sp)
    800034ee:	6442                	ld	s0,16(sp)
    800034f0:	64a2                	ld	s1,8(sp)
    800034f2:	6105                	addi	sp,sp,32
    800034f4:	8082                	ret

00000000800034f6 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034f6:	0001d717          	auipc	a4,0x1d
    800034fa:	60672703          	lw	a4,1542(a4) # 80020afc <sb+0xc>
    800034fe:	4785                	li	a5,1
    80003500:	0ae7fe63          	bgeu	a5,a4,800035bc <ireclaim+0xc6>
{
    80003504:	7139                	addi	sp,sp,-64
    80003506:	fc06                	sd	ra,56(sp)
    80003508:	f822                	sd	s0,48(sp)
    8000350a:	f426                	sd	s1,40(sp)
    8000350c:	f04a                	sd	s2,32(sp)
    8000350e:	ec4e                	sd	s3,24(sp)
    80003510:	e852                	sd	s4,16(sp)
    80003512:	e456                	sd	s5,8(sp)
    80003514:	e05a                	sd	s6,0(sp)
    80003516:	0080                	addi	s0,sp,64
    80003518:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000351a:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000351c:	0001da17          	auipc	s4,0x1d
    80003520:	5d4a0a13          	addi	s4,s4,1492 # 80020af0 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    80003524:	00004b17          	auipc	s6,0x4
    80003528:	f64b0b13          	addi	s6,s6,-156 # 80007488 <etext+0x488>
    8000352c:	a099                	j	80003572 <ireclaim+0x7c>
    8000352e:	85ce                	mv	a1,s3
    80003530:	855a                	mv	a0,s6
    80003532:	fd9fc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    80003536:	85ce                	mv	a1,s3
    80003538:	8556                	mv	a0,s5
    8000353a:	ad7ff0ef          	jal	80003010 <iget>
    8000353e:	89aa                	mv	s3,a0
    brelse(bp);
    80003540:	854a                	mv	a0,s2
    80003542:	fb0ff0ef          	jal	80002cf2 <brelse>
    if (ip) {
    80003546:	00098f63          	beqz	s3,80003564 <ireclaim+0x6e>
      begin_op();
    8000354a:	7b0000ef          	jal	80003cfa <begin_op>
      ilock(ip);
    8000354e:	854e                	mv	a0,s3
    80003550:	d33ff0ef          	jal	80003282 <ilock>
      iunlock(ip);
    80003554:	854e                	mv	a0,s3
    80003556:	ddbff0ef          	jal	80003330 <iunlock>
      iput(ip);
    8000355a:	854e                	mv	a0,s3
    8000355c:	ea9ff0ef          	jal	80003404 <iput>
      end_op();
    80003560:	027000ef          	jal	80003d86 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003564:	0485                	addi	s1,s1,1
    80003566:	00ca2703          	lw	a4,12(s4)
    8000356a:	0004879b          	sext.w	a5,s1
    8000356e:	02e7fd63          	bgeu	a5,a4,800035a8 <ireclaim+0xb2>
    80003572:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003576:	0044d593          	srli	a1,s1,0x4
    8000357a:	018a2783          	lw	a5,24(s4)
    8000357e:	9dbd                	addw	a1,a1,a5
    80003580:	8556                	mv	a0,s5
    80003582:	e68ff0ef          	jal	80002bea <bread>
    80003586:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003588:	05850793          	addi	a5,a0,88
    8000358c:	00f9f713          	andi	a4,s3,15
    80003590:	071a                	slli	a4,a4,0x6
    80003592:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    80003594:	00079703          	lh	a4,0(a5)
    80003598:	c701                	beqz	a4,800035a0 <ireclaim+0xaa>
    8000359a:	00679783          	lh	a5,6(a5)
    8000359e:	dbc1                	beqz	a5,8000352e <ireclaim+0x38>
    brelse(bp);
    800035a0:	854a                	mv	a0,s2
    800035a2:	f50ff0ef          	jal	80002cf2 <brelse>
    if (ip) {
    800035a6:	bf7d                	j	80003564 <ireclaim+0x6e>
}
    800035a8:	70e2                	ld	ra,56(sp)
    800035aa:	7442                	ld	s0,48(sp)
    800035ac:	74a2                	ld	s1,40(sp)
    800035ae:	7902                	ld	s2,32(sp)
    800035b0:	69e2                	ld	s3,24(sp)
    800035b2:	6a42                	ld	s4,16(sp)
    800035b4:	6aa2                	ld	s5,8(sp)
    800035b6:	6b02                	ld	s6,0(sp)
    800035b8:	6121                	addi	sp,sp,64
    800035ba:	8082                	ret
    800035bc:	8082                	ret

00000000800035be <fsinit>:
{
    800035be:	1101                	addi	sp,sp,-32
    800035c0:	ec06                	sd	ra,24(sp)
    800035c2:	e822                	sd	s0,16(sp)
    800035c4:	e426                	sd	s1,8(sp)
    800035c6:	e04a                	sd	s2,0(sp)
    800035c8:	1000                	addi	s0,sp,32
    800035ca:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800035cc:	4585                	li	a1,1
    800035ce:	e1cff0ef          	jal	80002bea <bread>
    800035d2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800035d4:	02000613          	li	a2,32
    800035d8:	05850593          	addi	a1,a0,88
    800035dc:	0001d517          	auipc	a0,0x1d
    800035e0:	51450513          	addi	a0,a0,1300 # 80020af0 <sb>
    800035e4:	f64fd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    800035e8:	8526                	mv	a0,s1
    800035ea:	f08ff0ef          	jal	80002cf2 <brelse>
  if (sb.magic != FSMAGIC)
    800035ee:	0001d717          	auipc	a4,0x1d
    800035f2:	50272703          	lw	a4,1282(a4) # 80020af0 <sb>
    800035f6:	102037b7          	lui	a5,0x10203
    800035fa:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035fe:	02f71263          	bne	a4,a5,80003622 <fsinit+0x64>
  initlog(dev, &sb);
    80003602:	0001d597          	auipc	a1,0x1d
    80003606:	4ee58593          	addi	a1,a1,1262 # 80020af0 <sb>
    8000360a:	854a                	mv	a0,s2
    8000360c:	66c000ef          	jal	80003c78 <initlog>
  ireclaim(dev);
    80003610:	854a                	mv	a0,s2
    80003612:	ee5ff0ef          	jal	800034f6 <ireclaim>
}
    80003616:	60e2                	ld	ra,24(sp)
    80003618:	6442                	ld	s0,16(sp)
    8000361a:	64a2                	ld	s1,8(sp)
    8000361c:	6902                	ld	s2,0(sp)
    8000361e:	6105                	addi	sp,sp,32
    80003620:	8082                	ret
    panic("invalid file system");
    80003622:	00004517          	auipc	a0,0x4
    80003626:	e8650513          	addi	a0,a0,-378 # 800074a8 <etext+0x4a8>
    8000362a:	a0afd0ef          	jal	80000834 <panic>

000000008000362e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000362e:	1141                	addi	sp,sp,-16
    80003630:	e406                	sd	ra,8(sp)
    80003632:	e022                	sd	s0,0(sp)
    80003634:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003636:	411c                	lw	a5,0(a0)
    80003638:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000363a:	415c                	lw	a5,4(a0)
    8000363c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000363e:	04451783          	lh	a5,68(a0)
    80003642:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003646:	04a51783          	lh	a5,74(a0)
    8000364a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000364e:	04c56783          	lwu	a5,76(a0)
    80003652:	e99c                	sd	a5,16(a1)
}
    80003654:	60a2                	ld	ra,8(sp)
    80003656:	6402                	ld	s0,0(sp)
    80003658:	0141                	addi	sp,sp,16
    8000365a:	8082                	ret

000000008000365c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    8000365c:	457c                	lw	a5,76(a0)
    8000365e:	0ed7e663          	bltu	a5,a3,8000374a <readi+0xee>
{
    80003662:	7159                	addi	sp,sp,-112
    80003664:	f486                	sd	ra,104(sp)
    80003666:	f0a2                	sd	s0,96(sp)
    80003668:	eca6                	sd	s1,88(sp)
    8000366a:	e0d2                	sd	s4,64(sp)
    8000366c:	fc56                	sd	s5,56(sp)
    8000366e:	f85a                	sd	s6,48(sp)
    80003670:	f45e                	sd	s7,40(sp)
    80003672:	1880                	addi	s0,sp,112
    80003674:	8b2a                	mv	s6,a0
    80003676:	8bae                	mv	s7,a1
    80003678:	8a32                	mv	s4,a2
    8000367a:	84b6                	mv	s1,a3
    8000367c:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    8000367e:	9f35                	addw	a4,a4,a3
    return 0;
    80003680:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003682:	0ad76b63          	bltu	a4,a3,80003738 <readi+0xdc>
    80003686:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003688:	00e7f463          	bgeu	a5,a4,80003690 <readi+0x34>
    n = ip->size - off;
    8000368c:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003690:	080a8b63          	beqz	s5,80003726 <readi+0xca>
    80003694:	e8ca                	sd	s2,80(sp)
    80003696:	f062                	sd	s8,32(sp)
    80003698:	ec66                	sd	s9,24(sp)
    8000369a:	e86a                	sd	s10,16(sp)
    8000369c:	e46e                	sd	s11,8(sp)
    8000369e:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800036a0:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800036a4:	5c7d                	li	s8,-1
    800036a6:	a80d                	j	800036d8 <readi+0x7c>
    800036a8:	020d1d93          	slli	s11,s10,0x20
    800036ac:	020ddd93          	srli	s11,s11,0x20
    800036b0:	05890613          	addi	a2,s2,88
    800036b4:	86ee                	mv	a3,s11
    800036b6:	963e                	add	a2,a2,a5
    800036b8:	85d2                	mv	a1,s4
    800036ba:	855e                	mv	a0,s7
    800036bc:	c6ffe0ef          	jal	8000232a <either_copyout>
    800036c0:	05850363          	beq	a0,s8,80003706 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800036c4:	854a                	mv	a0,s2
    800036c6:	e2cff0ef          	jal	80002cf2 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800036ca:	013d09bb          	addw	s3,s10,s3
    800036ce:	009d04bb          	addw	s1,s10,s1
    800036d2:	9a6e                	add	s4,s4,s11
    800036d4:	0559f363          	bgeu	s3,s5,8000371a <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    800036d8:	00a4d59b          	srliw	a1,s1,0xa
    800036dc:	855a                	mv	a0,s6
    800036de:	873ff0ef          	jal	80002f50 <bmap>
    800036e2:	85aa                	mv	a1,a0
    if (addr == 0)
    800036e4:	c139                	beqz	a0,8000372a <readi+0xce>
    bp = bread(ip->dev, addr);
    800036e6:	000b2503          	lw	a0,0(s6)
    800036ea:	d00ff0ef          	jal	80002bea <bread>
    800036ee:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800036f0:	3ff4f793          	andi	a5,s1,1023
    800036f4:	40fc873b          	subw	a4,s9,a5
    800036f8:	413a86bb          	subw	a3,s5,s3
    800036fc:	8d3a                	mv	s10,a4
    800036fe:	fae6f5e3          	bgeu	a3,a4,800036a8 <readi+0x4c>
    80003702:	8d36                	mv	s10,a3
    80003704:	b755                	j	800036a8 <readi+0x4c>
      brelse(bp);
    80003706:	854a                	mv	a0,s2
    80003708:	deaff0ef          	jal	80002cf2 <brelse>
      tot = -1;
    8000370c:	59fd                	li	s3,-1
      break;
    8000370e:	6946                	ld	s2,80(sp)
    80003710:	7c02                	ld	s8,32(sp)
    80003712:	6ce2                	ld	s9,24(sp)
    80003714:	6d42                	ld	s10,16(sp)
    80003716:	6da2                	ld	s11,8(sp)
    80003718:	a831                	j	80003734 <readi+0xd8>
    8000371a:	6946                	ld	s2,80(sp)
    8000371c:	7c02                	ld	s8,32(sp)
    8000371e:	6ce2                	ld	s9,24(sp)
    80003720:	6d42                	ld	s10,16(sp)
    80003722:	6da2                	ld	s11,8(sp)
    80003724:	a801                	j	80003734 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003726:	89d6                	mv	s3,s5
    80003728:	a031                	j	80003734 <readi+0xd8>
    8000372a:	6946                	ld	s2,80(sp)
    8000372c:	7c02                	ld	s8,32(sp)
    8000372e:	6ce2                	ld	s9,24(sp)
    80003730:	6d42                	ld	s10,16(sp)
    80003732:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003734:	854e                	mv	a0,s3
    80003736:	69a6                	ld	s3,72(sp)
}
    80003738:	70a6                	ld	ra,104(sp)
    8000373a:	7406                	ld	s0,96(sp)
    8000373c:	64e6                	ld	s1,88(sp)
    8000373e:	6a06                	ld	s4,64(sp)
    80003740:	7ae2                	ld	s5,56(sp)
    80003742:	7b42                	ld	s6,48(sp)
    80003744:	7ba2                	ld	s7,40(sp)
    80003746:	6165                	addi	sp,sp,112
    80003748:	8082                	ret
    return 0;
    8000374a:	4501                	li	a0,0
}
    8000374c:	8082                	ret

000000008000374e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    8000374e:	457c                	lw	a5,76(a0)
    80003750:	0ed7ee63          	bltu	a5,a3,8000384c <writei+0xfe>
{
    80003754:	7159                	addi	sp,sp,-112
    80003756:	f486                	sd	ra,104(sp)
    80003758:	f0a2                	sd	s0,96(sp)
    8000375a:	e8ca                	sd	s2,80(sp)
    8000375c:	e0d2                	sd	s4,64(sp)
    8000375e:	fc56                	sd	s5,56(sp)
    80003760:	f85a                	sd	s6,48(sp)
    80003762:	f45e                	sd	s7,40(sp)
    80003764:	1880                	addi	s0,sp,112
    80003766:	8aaa                	mv	s5,a0
    80003768:	8bae                	mv	s7,a1
    8000376a:	8a32                	mv	s4,a2
    8000376c:	8936                	mv	s2,a3
    8000376e:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003770:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003774:	00043737          	lui	a4,0x43
    80003778:	0cf76c63          	bltu	a4,a5,80003850 <writei+0x102>
    8000377c:	0cd7ea63          	bltu	a5,a3,80003850 <writei+0x102>
    80003780:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003782:	0a0b0d63          	beqz	s6,8000383c <writei+0xee>
    80003786:	eca6                	sd	s1,88(sp)
    80003788:	f062                	sd	s8,32(sp)
    8000378a:	ec66                	sd	s9,24(sp)
    8000378c:	e86a                	sd	s10,16(sp)
    8000378e:	e46e                	sd	s11,8(sp)
    80003790:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003792:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003796:	5c7d                	li	s8,-1
    80003798:	a825                	j	800037d0 <writei+0x82>
    8000379a:	020d1d93          	slli	s11,s10,0x20
    8000379e:	020ddd93          	srli	s11,s11,0x20
    800037a2:	05848513          	addi	a0,s1,88
    800037a6:	86ee                	mv	a3,s11
    800037a8:	8652                	mv	a2,s4
    800037aa:	85de                	mv	a1,s7
    800037ac:	953e                	add	a0,a0,a5
    800037ae:	bc9fe0ef          	jal	80002376 <either_copyin>
    800037b2:	05850663          	beq	a0,s8,800037fe <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    800037b6:	8526                	mv	a0,s1
    800037b8:	6f0000ef          	jal	80003ea8 <log_write>
    brelse(bp);
    800037bc:	8526                	mv	a0,s1
    800037be:	d34ff0ef          	jal	80002cf2 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800037c2:	013d09bb          	addw	s3,s10,s3
    800037c6:	012d093b          	addw	s2,s10,s2
    800037ca:	9a6e                	add	s4,s4,s11
    800037cc:	0369ff63          	bgeu	s3,s6,8000380a <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    800037d0:	00a9559b          	srliw	a1,s2,0xa
    800037d4:	8556                	mv	a0,s5
    800037d6:	f7aff0ef          	jal	80002f50 <bmap>
    800037da:	85aa                	mv	a1,a0
    if (addr == 0)
    800037dc:	c51d                	beqz	a0,8000380a <writei+0xbc>
    bp = bread(ip->dev, addr);
    800037de:	000aa503          	lw	a0,0(s5)
    800037e2:	c08ff0ef          	jal	80002bea <bread>
    800037e6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800037e8:	3ff97793          	andi	a5,s2,1023
    800037ec:	40fc873b          	subw	a4,s9,a5
    800037f0:	413b06bb          	subw	a3,s6,s3
    800037f4:	8d3a                	mv	s10,a4
    800037f6:	fae6f2e3          	bgeu	a3,a4,8000379a <writei+0x4c>
    800037fa:	8d36                	mv	s10,a3
    800037fc:	bf79                	j	8000379a <writei+0x4c>
      log_write(bp);
    800037fe:	8526                	mv	a0,s1
    80003800:	6a8000ef          	jal	80003ea8 <log_write>
      brelse(bp);
    80003804:	8526                	mv	a0,s1
    80003806:	cecff0ef          	jal	80002cf2 <brelse>
  }

  if (off > ip->size)
    8000380a:	04caa783          	lw	a5,76(s5)
    8000380e:	0327f963          	bgeu	a5,s2,80003840 <writei+0xf2>
    ip->size = off;
    80003812:	052aa623          	sw	s2,76(s5)
    80003816:	64e6                	ld	s1,88(sp)
    80003818:	7c02                	ld	s8,32(sp)
    8000381a:	6ce2                	ld	s9,24(sp)
    8000381c:	6d42                	ld	s10,16(sp)
    8000381e:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003820:	8556                	mv	a0,s5
    80003822:	9adff0ef          	jal	800031ce <iupdate>

  return tot;
    80003826:	854e                	mv	a0,s3
    80003828:	69a6                	ld	s3,72(sp)
}
    8000382a:	70a6                	ld	ra,104(sp)
    8000382c:	7406                	ld	s0,96(sp)
    8000382e:	6946                	ld	s2,80(sp)
    80003830:	6a06                	ld	s4,64(sp)
    80003832:	7ae2                	ld	s5,56(sp)
    80003834:	7b42                	ld	s6,48(sp)
    80003836:	7ba2                	ld	s7,40(sp)
    80003838:	6165                	addi	sp,sp,112
    8000383a:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000383c:	89da                	mv	s3,s6
    8000383e:	b7cd                	j	80003820 <writei+0xd2>
    80003840:	64e6                	ld	s1,88(sp)
    80003842:	7c02                	ld	s8,32(sp)
    80003844:	6ce2                	ld	s9,24(sp)
    80003846:	6d42                	ld	s10,16(sp)
    80003848:	6da2                	ld	s11,8(sp)
    8000384a:	bfd9                	j	80003820 <writei+0xd2>
    return -1;
    8000384c:	557d                	li	a0,-1
}
    8000384e:	8082                	ret
    return -1;
    80003850:	557d                	li	a0,-1
    80003852:	bfe1                	j	8000382a <writei+0xdc>

0000000080003854 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003854:	1141                	addi	sp,sp,-16
    80003856:	e406                	sd	ra,8(sp)
    80003858:	e022                	sd	s0,0(sp)
    8000385a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000385c:	4639                	li	a2,14
    8000385e:	d5efd0ef          	jal	80000dbc <strncmp>
}
    80003862:	60a2                	ld	ra,8(sp)
    80003864:	6402                	ld	s0,0(sp)
    80003866:	0141                	addi	sp,sp,16
    80003868:	8082                	ret

000000008000386a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000386a:	711d                	addi	sp,sp,-96
    8000386c:	ec86                	sd	ra,88(sp)
    8000386e:	e8a2                	sd	s0,80(sp)
    80003870:	e4a6                	sd	s1,72(sp)
    80003872:	e0ca                	sd	s2,64(sp)
    80003874:	fc4e                	sd	s3,56(sp)
    80003876:	f852                	sd	s4,48(sp)
    80003878:	f456                	sd	s5,40(sp)
    8000387a:	f05a                	sd	s6,32(sp)
    8000387c:	ec5e                	sd	s7,24(sp)
    8000387e:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003880:	04451703          	lh	a4,68(a0)
    80003884:	4785                	li	a5,1
    80003886:	00f71f63          	bne	a4,a5,800038a4 <dirlookup+0x3a>
    8000388a:	892a                	mv	s2,a0
    8000388c:	8aae                	mv	s5,a1
    8000388e:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003890:	457c                	lw	a5,76(a0)
    80003892:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003894:	fa040a13          	addi	s4,s0,-96
    80003898:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    8000389a:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000389e:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800038a0:	e39d                	bnez	a5,800038c6 <dirlookup+0x5c>
    800038a2:	a8b9                	j	80003900 <dirlookup+0x96>
    panic("dirlookup not DIR");
    800038a4:	00004517          	auipc	a0,0x4
    800038a8:	c1c50513          	addi	a0,a0,-996 # 800074c0 <etext+0x4c0>
    800038ac:	f89fc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    800038b0:	00004517          	auipc	a0,0x4
    800038b4:	c2850513          	addi	a0,a0,-984 # 800074d8 <etext+0x4d8>
    800038b8:	f7dfc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800038bc:	24c1                	addiw	s1,s1,16
    800038be:	04c92783          	lw	a5,76(s2)
    800038c2:	02f4fe63          	bgeu	s1,a5,800038fe <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038c6:	874e                	mv	a4,s3
    800038c8:	86a6                	mv	a3,s1
    800038ca:	8652                	mv	a2,s4
    800038cc:	4581                	li	a1,0
    800038ce:	854a                	mv	a0,s2
    800038d0:	d8dff0ef          	jal	8000365c <readi>
    800038d4:	fd351ee3          	bne	a0,s3,800038b0 <dirlookup+0x46>
    if (de.inum == 0)
    800038d8:	fa045783          	lhu	a5,-96(s0)
    800038dc:	d3e5                	beqz	a5,800038bc <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    800038de:	85da                	mv	a1,s6
    800038e0:	8556                	mv	a0,s5
    800038e2:	f73ff0ef          	jal	80003854 <namecmp>
    800038e6:	f979                	bnez	a0,800038bc <dirlookup+0x52>
      if (poff)
    800038e8:	000b8463          	beqz	s7,800038f0 <dirlookup+0x86>
        *poff = off;
    800038ec:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800038f0:	fa045583          	lhu	a1,-96(s0)
    800038f4:	00092503          	lw	a0,0(s2)
    800038f8:	f18ff0ef          	jal	80003010 <iget>
    800038fc:	a011                	j	80003900 <dirlookup+0x96>
  return 0;
    800038fe:	4501                	li	a0,0
}
    80003900:	60e6                	ld	ra,88(sp)
    80003902:	6446                	ld	s0,80(sp)
    80003904:	64a6                	ld	s1,72(sp)
    80003906:	6906                	ld	s2,64(sp)
    80003908:	79e2                	ld	s3,56(sp)
    8000390a:	7a42                	ld	s4,48(sp)
    8000390c:	7aa2                	ld	s5,40(sp)
    8000390e:	7b02                	ld	s6,32(sp)
    80003910:	6be2                	ld	s7,24(sp)
    80003912:	6125                	addi	sp,sp,96
    80003914:	8082                	ret

0000000080003916 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003916:	711d                	addi	sp,sp,-96
    80003918:	ec86                	sd	ra,88(sp)
    8000391a:	e8a2                	sd	s0,80(sp)
    8000391c:	e4a6                	sd	s1,72(sp)
    8000391e:	e0ca                	sd	s2,64(sp)
    80003920:	fc4e                	sd	s3,56(sp)
    80003922:	f852                	sd	s4,48(sp)
    80003924:	f456                	sd	s5,40(sp)
    80003926:	f05a                	sd	s6,32(sp)
    80003928:	ec5e                	sd	s7,24(sp)
    8000392a:	e862                	sd	s8,16(sp)
    8000392c:	e466                	sd	s9,8(sp)
    8000392e:	e06a                	sd	s10,0(sp)
    80003930:	1080                	addi	s0,sp,96
    80003932:	84aa                	mv	s1,a0
    80003934:	8b2e                	mv	s6,a1
    80003936:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003938:	00054703          	lbu	a4,0(a0)
    8000393c:	02f00793          	li	a5,47
    80003940:	00f70f63          	beq	a4,a5,8000395e <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003944:	804fe0ef          	jal	80001948 <myproc>
    80003948:	15053503          	ld	a0,336(a0)
    8000394c:	901ff0ef          	jal	8000324c <idup>
    80003950:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003952:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003956:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003958:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    8000395a:	4b85                	li	s7,1
    8000395c:	a07d                	j	80003a0a <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    8000395e:	4585                	li	a1,1
    80003960:	852e                	mv	a0,a1
    80003962:	eaeff0ef          	jal	80003010 <iget>
    80003966:	8a2a                	mv	s4,a0
    80003968:	b7ed                	j	80003952 <namex+0x3c>
      iunlockput(ip);
    8000396a:	8552                	mv	a0,s4
    8000396c:	b6bff0ef          	jal	800034d6 <iunlockput>
      return 0;
    80003970:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003972:	8552                	mv	a0,s4
    80003974:	60e6                	ld	ra,88(sp)
    80003976:	6446                	ld	s0,80(sp)
    80003978:	64a6                	ld	s1,72(sp)
    8000397a:	6906                	ld	s2,64(sp)
    8000397c:	79e2                	ld	s3,56(sp)
    8000397e:	7a42                	ld	s4,48(sp)
    80003980:	7aa2                	ld	s5,40(sp)
    80003982:	7b02                	ld	s6,32(sp)
    80003984:	6be2                	ld	s7,24(sp)
    80003986:	6c42                	ld	s8,16(sp)
    80003988:	6ca2                	ld	s9,8(sp)
    8000398a:	6d02                	ld	s10,0(sp)
    8000398c:	6125                	addi	sp,sp,96
    8000398e:	8082                	ret
      iunlockput(ip);
    80003990:	8552                	mv	a0,s4
    80003992:	b45ff0ef          	jal	800034d6 <iunlockput>
      return 0;
    80003996:	4a01                	li	s4,0
    80003998:	bfe9                	j	80003972 <namex+0x5c>
      iunlock(ip);
    8000399a:	8552                	mv	a0,s4
    8000399c:	995ff0ef          	jal	80003330 <iunlock>
      return ip;
    800039a0:	bfc9                	j	80003972 <namex+0x5c>
      iunlockput(ip);
    800039a2:	8552                	mv	a0,s4
    800039a4:	b33ff0ef          	jal	800034d6 <iunlockput>
      return 0;
    800039a8:	8a4a                	mv	s4,s2
    800039aa:	b7e1                	j	80003972 <namex+0x5c>
  while (*path != '/' && *path != 0)
    800039ac:	8926                	mv	s2,s1
  len = path - s;
    800039ae:	4d01                	li	s10,0
    800039b0:	4601                	li	a2,0
    memmove(name, s, len);
    800039b2:	2601                	sext.w	a2,a2
    800039b4:	85a6                	mv	a1,s1
    800039b6:	8556                	mv	a0,s5
    800039b8:	b90fd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    800039bc:	9d56                	add	s10,s10,s5
    800039be:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb808>
  while (*path == '/')
    800039c2:	00094783          	lbu	a5,0(s2)
    800039c6:	09379b63          	bne	a5,s3,80003a5c <namex+0x146>
    800039ca:	84ca                	mv	s1,s2
    path++;
    800039cc:	0485                	addi	s1,s1,1
  while (*path == '/')
    800039ce:	0004c783          	lbu	a5,0(s1)
    800039d2:	ff378de3          	beq	a5,s3,800039cc <namex+0xb6>
    ilock(ip);
    800039d6:	8552                	mv	a0,s4
    800039d8:	8abff0ef          	jal	80003282 <ilock>
    if (ip->type != T_DIR) {
    800039dc:	044a1783          	lh	a5,68(s4)
    800039e0:	f97795e3          	bne	a5,s7,8000396a <namex+0x54>
    if (ip->nlink == 0) {
    800039e4:	04aa1783          	lh	a5,74(s4)
    800039e8:	d7c5                	beqz	a5,80003990 <namex+0x7a>
    if (nameiparent && *path == '\0') {
    800039ea:	000b0563          	beqz	s6,800039f4 <namex+0xde>
    800039ee:	0004c783          	lbu	a5,0(s1)
    800039f2:	d7c5                	beqz	a5,8000399a <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    800039f4:	4601                	li	a2,0
    800039f6:	85d6                	mv	a1,s5
    800039f8:	8552                	mv	a0,s4
    800039fa:	e71ff0ef          	jal	8000386a <dirlookup>
    800039fe:	892a                	mv	s2,a0
    80003a00:	d14d                	beqz	a0,800039a2 <namex+0x8c>
    iunlockput(ip);
    80003a02:	8552                	mv	a0,s4
    80003a04:	ad3ff0ef          	jal	800034d6 <iunlockput>
    ip = next;
    80003a08:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003a0a:	0004c783          	lbu	a5,0(s1)
    80003a0e:	01379763          	bne	a5,s3,80003a1c <namex+0x106>
    path++;
    80003a12:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003a14:	0004c783          	lbu	a5,0(s1)
    80003a18:	ff378de3          	beq	a5,s3,80003a12 <namex+0xfc>
  if (*path == 0)
    80003a1c:	c7a1                	beqz	a5,80003a64 <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003a1e:	0004c783          	lbu	a5,0(s1)
    80003a22:	fd178713          	addi	a4,a5,-47
    80003a26:	d359                	beqz	a4,800039ac <namex+0x96>
    80003a28:	d3d1                	beqz	a5,800039ac <namex+0x96>
    80003a2a:	8926                	mv	s2,s1
    path++;
    80003a2c:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003a2e:	00094783          	lbu	a5,0(s2)
    80003a32:	fd178713          	addi	a4,a5,-47
    80003a36:	c311                	beqz	a4,80003a3a <namex+0x124>
    80003a38:	fbf5                	bnez	a5,80003a2c <namex+0x116>
  len = path - s;
    80003a3a:	40990633          	sub	a2,s2,s1
    80003a3e:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003a42:	f7ac58e3          	bge	s8,s10,800039b2 <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003a46:	8666                	mv	a2,s9
    80003a48:	85a6                	mv	a1,s1
    80003a4a:	8556                	mv	a0,s5
    80003a4c:	afcfd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003a50:	00094783          	lbu	a5,0(s2)
    80003a54:	84ca                	mv	s1,s2
    80003a56:	f7378be3          	beq	a5,s3,800039cc <namex+0xb6>
    80003a5a:	bfb5                	j	800039d6 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003a5c:	00090463          	beqz	s2,80003a64 <namex+0x14e>
    80003a60:	84ca                	mv	s1,s2
    80003a62:	bf95                	j	800039d6 <namex+0xc0>
  if (nameiparent) {
    80003a64:	f00b07e3          	beqz	s6,80003972 <namex+0x5c>
    iput(ip);
    80003a68:	8552                	mv	a0,s4
    80003a6a:	99bff0ef          	jal	80003404 <iput>
    return 0;
    80003a6e:	4a01                	li	s4,0
    80003a70:	b709                	j	80003972 <namex+0x5c>

0000000080003a72 <dirlink>:
{
    80003a72:	715d                	addi	sp,sp,-80
    80003a74:	e486                	sd	ra,72(sp)
    80003a76:	e0a2                	sd	s0,64(sp)
    80003a78:	f84a                	sd	s2,48(sp)
    80003a7a:	ec56                	sd	s5,24(sp)
    80003a7c:	e85a                	sd	s6,16(sp)
    80003a7e:	0880                	addi	s0,sp,80
    80003a80:	892a                	mv	s2,a0
    80003a82:	8aae                	mv	s5,a1
    80003a84:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003a86:	4601                	li	a2,0
    80003a88:	de3ff0ef          	jal	8000386a <dirlookup>
    80003a8c:	ed1d                	bnez	a0,80003aca <dirlink+0x58>
    80003a8e:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a90:	04c92483          	lw	s1,76(s2)
    80003a94:	c4b9                	beqz	s1,80003ae2 <dirlink+0x70>
    80003a96:	f44e                	sd	s3,40(sp)
    80003a98:	f052                	sd	s4,32(sp)
    80003a9a:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a9c:	fb040a13          	addi	s4,s0,-80
    80003aa0:	49c1                	li	s3,16
    80003aa2:	874e                	mv	a4,s3
    80003aa4:	86a6                	mv	a3,s1
    80003aa6:	8652                	mv	a2,s4
    80003aa8:	4581                	li	a1,0
    80003aaa:	854a                	mv	a0,s2
    80003aac:	bb1ff0ef          	jal	8000365c <readi>
    80003ab0:	03351163          	bne	a0,s3,80003ad2 <dirlink+0x60>
    if (de.inum == 0)
    80003ab4:	fb045783          	lhu	a5,-80(s0)
    80003ab8:	c39d                	beqz	a5,80003ade <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003aba:	24c1                	addiw	s1,s1,16
    80003abc:	04c92783          	lw	a5,76(s2)
    80003ac0:	fef4e1e3          	bltu	s1,a5,80003aa2 <dirlink+0x30>
    80003ac4:	79a2                	ld	s3,40(sp)
    80003ac6:	7a02                	ld	s4,32(sp)
    80003ac8:	a829                	j	80003ae2 <dirlink+0x70>
    iput(ip);
    80003aca:	93bff0ef          	jal	80003404 <iput>
    return -1;
    80003ace:	557d                	li	a0,-1
    80003ad0:	a83d                	j	80003b0e <dirlink+0x9c>
      panic("dirlink read");
    80003ad2:	00004517          	auipc	a0,0x4
    80003ad6:	a1650513          	addi	a0,a0,-1514 # 800074e8 <etext+0x4e8>
    80003ada:	d5bfc0ef          	jal	80000834 <panic>
    80003ade:	79a2                	ld	s3,40(sp)
    80003ae0:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003ae2:	4639                	li	a2,14
    80003ae4:	85d6                	mv	a1,s5
    80003ae6:	fb240513          	addi	a0,s0,-78
    80003aea:	b0cfd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003aee:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003af2:	4741                	li	a4,16
    80003af4:	86a6                	mv	a3,s1
    80003af6:	fb040613          	addi	a2,s0,-80
    80003afa:	4581                	li	a1,0
    80003afc:	854a                	mv	a0,s2
    80003afe:	c51ff0ef          	jal	8000374e <writei>
    80003b02:	1541                	addi	a0,a0,-16
    80003b04:	00a03533          	snez	a0,a0
    80003b08:	40a0053b          	negw	a0,a0
    80003b0c:	74e2                	ld	s1,56(sp)
}
    80003b0e:	60a6                	ld	ra,72(sp)
    80003b10:	6406                	ld	s0,64(sp)
    80003b12:	7942                	ld	s2,48(sp)
    80003b14:	6ae2                	ld	s5,24(sp)
    80003b16:	6b42                	ld	s6,16(sp)
    80003b18:	6161                	addi	sp,sp,80
    80003b1a:	8082                	ret

0000000080003b1c <namei>:

struct inode *
namei(char *path)
{
    80003b1c:	1101                	addi	sp,sp,-32
    80003b1e:	ec06                	sd	ra,24(sp)
    80003b20:	e822                	sd	s0,16(sp)
    80003b22:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b24:	fe040613          	addi	a2,s0,-32
    80003b28:	4581                	li	a1,0
    80003b2a:	dedff0ef          	jal	80003916 <namex>
}
    80003b2e:	60e2                	ld	ra,24(sp)
    80003b30:	6442                	ld	s0,16(sp)
    80003b32:	6105                	addi	sp,sp,32
    80003b34:	8082                	ret

0000000080003b36 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003b36:	1141                	addi	sp,sp,-16
    80003b38:	e406                	sd	ra,8(sp)
    80003b3a:	e022                	sd	s0,0(sp)
    80003b3c:	0800                	addi	s0,sp,16
    80003b3e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b40:	4585                	li	a1,1
    80003b42:	dd5ff0ef          	jal	80003916 <namex>
}
    80003b46:	60a2                	ld	ra,8(sp)
    80003b48:	6402                	ld	s0,0(sp)
    80003b4a:	0141                	addi	sp,sp,16
    80003b4c:	8082                	ret

0000000080003b4e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b4e:	1101                	addi	sp,sp,-32
    80003b50:	ec06                	sd	ra,24(sp)
    80003b52:	e822                	sd	s0,16(sp)
    80003b54:	e426                	sd	s1,8(sp)
    80003b56:	e04a                	sd	s2,0(sp)
    80003b58:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003b5a:	0001f917          	auipc	s2,0x1f
    80003b5e:	a5e90913          	addi	s2,s2,-1442 # 800225b8 <log>
    80003b62:	01892583          	lw	a1,24(s2)
    80003b66:	02492503          	lw	a0,36(s2)
    80003b6a:	880ff0ef          	jal	80002bea <bread>
    80003b6e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003b70:	02c92603          	lw	a2,44(s2)
    80003b74:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b76:	00c05f63          	blez	a2,80003b94 <write_head+0x46>
    80003b7a:	0001f717          	auipc	a4,0x1f
    80003b7e:	a6e70713          	addi	a4,a4,-1426 # 800225e8 <log+0x30>
    80003b82:	87aa                	mv	a5,a0
    80003b84:	060a                	slli	a2,a2,0x2
    80003b86:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b88:	4314                	lw	a3,0(a4)
    80003b8a:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b8c:	0711                	addi	a4,a4,4
    80003b8e:	0791                	addi	a5,a5,4
    80003b90:	fec79ce3          	bne	a5,a2,80003b88 <write_head+0x3a>
  }
  bwrite(buf);
    80003b94:	8526                	mv	a0,s1
    80003b96:	92aff0ef          	jal	80002cc0 <bwrite>
  brelse(buf);
    80003b9a:	8526                	mv	a0,s1
    80003b9c:	956ff0ef          	jal	80002cf2 <brelse>
}
    80003ba0:	60e2                	ld	ra,24(sp)
    80003ba2:	6442                	ld	s0,16(sp)
    80003ba4:	64a2                	ld	s1,8(sp)
    80003ba6:	6902                	ld	s2,0(sp)
    80003ba8:	6105                	addi	sp,sp,32
    80003baa:	8082                	ret

0000000080003bac <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bac:	0001f797          	auipc	a5,0x1f
    80003bb0:	a387a783          	lw	a5,-1480(a5) # 800225e4 <log+0x2c>
    80003bb4:	0cf05163          	blez	a5,80003c76 <install_trans+0xca>
{
    80003bb8:	715d                	addi	sp,sp,-80
    80003bba:	e486                	sd	ra,72(sp)
    80003bbc:	e0a2                	sd	s0,64(sp)
    80003bbe:	fc26                	sd	s1,56(sp)
    80003bc0:	f84a                	sd	s2,48(sp)
    80003bc2:	f44e                	sd	s3,40(sp)
    80003bc4:	f052                	sd	s4,32(sp)
    80003bc6:	ec56                	sd	s5,24(sp)
    80003bc8:	e85a                	sd	s6,16(sp)
    80003bca:	e45e                	sd	s7,8(sp)
    80003bcc:	e062                	sd	s8,0(sp)
    80003bce:	0880                	addi	s0,sp,80
    80003bd0:	8b2a                	mv	s6,a0
    80003bd2:	0001fa97          	auipc	s5,0x1f
    80003bd6:	a16a8a93          	addi	s5,s5,-1514 # 800225e8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bda:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003bdc:	00004c17          	auipc	s8,0x4
    80003be0:	91cc0c13          	addi	s8,s8,-1764 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003be4:	0001fa17          	auipc	s4,0x1f
    80003be8:	9d4a0a13          	addi	s4,s4,-1580 # 800225b8 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003bec:	40000b93          	li	s7,1024
    80003bf0:	a025                	j	80003c18 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003bf2:	000aa603          	lw	a2,0(s5)
    80003bf6:	85ce                	mv	a1,s3
    80003bf8:	8562                	mv	a0,s8
    80003bfa:	911fc0ef          	jal	8000050a <printk>
    80003bfe:	a839                	j	80003c1c <install_trans+0x70>
    brelse(lbuf);
    80003c00:	854a                	mv	a0,s2
    80003c02:	8f0ff0ef          	jal	80002cf2 <brelse>
    brelse(dbuf);
    80003c06:	8526                	mv	a0,s1
    80003c08:	8eaff0ef          	jal	80002cf2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c0c:	2985                	addiw	s3,s3,1
    80003c0e:	0a91                	addi	s5,s5,4
    80003c10:	02ca2783          	lw	a5,44(s4)
    80003c14:	04f9d563          	bge	s3,a5,80003c5e <install_trans+0xb2>
    if (recovering) {
    80003c18:	fc0b1de3          	bnez	s6,80003bf2 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003c1c:	018a2583          	lw	a1,24(s4)
    80003c20:	013585bb          	addw	a1,a1,s3
    80003c24:	2585                	addiw	a1,a1,1
    80003c26:	024a2503          	lw	a0,36(s4)
    80003c2a:	fc1fe0ef          	jal	80002bea <bread>
    80003c2e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003c30:	000aa583          	lw	a1,0(s5)
    80003c34:	024a2503          	lw	a0,36(s4)
    80003c38:	fb3fe0ef          	jal	80002bea <bread>
    80003c3c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003c3e:	865e                	mv	a2,s7
    80003c40:	05890593          	addi	a1,s2,88
    80003c44:	05850513          	addi	a0,a0,88
    80003c48:	900fd0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003c4c:	8526                	mv	a0,s1
    80003c4e:	872ff0ef          	jal	80002cc0 <bwrite>
    if (recovering == 0)
    80003c52:	fa0b17e3          	bnez	s6,80003c00 <install_trans+0x54>
      bunpin(dbuf);
    80003c56:	8526                	mv	a0,s1
    80003c58:	952ff0ef          	jal	80002daa <bunpin>
    80003c5c:	b755                	j	80003c00 <install_trans+0x54>
}
    80003c5e:	60a6                	ld	ra,72(sp)
    80003c60:	6406                	ld	s0,64(sp)
    80003c62:	74e2                	ld	s1,56(sp)
    80003c64:	7942                	ld	s2,48(sp)
    80003c66:	79a2                	ld	s3,40(sp)
    80003c68:	7a02                	ld	s4,32(sp)
    80003c6a:	6ae2                	ld	s5,24(sp)
    80003c6c:	6b42                	ld	s6,16(sp)
    80003c6e:	6ba2                	ld	s7,8(sp)
    80003c70:	6c02                	ld	s8,0(sp)
    80003c72:	6161                	addi	sp,sp,80
    80003c74:	8082                	ret
    80003c76:	8082                	ret

0000000080003c78 <initlog>:
{
    80003c78:	7179                	addi	sp,sp,-48
    80003c7a:	f406                	sd	ra,40(sp)
    80003c7c:	f022                	sd	s0,32(sp)
    80003c7e:	ec26                	sd	s1,24(sp)
    80003c80:	e84a                	sd	s2,16(sp)
    80003c82:	e44e                	sd	s3,8(sp)
    80003c84:	1800                	addi	s0,sp,48
    80003c86:	84aa                	mv	s1,a0
    80003c88:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c8a:	0001f917          	auipc	s2,0x1f
    80003c8e:	92e90913          	addi	s2,s2,-1746 # 800225b8 <log>
    80003c92:	00004597          	auipc	a1,0x4
    80003c96:	88658593          	addi	a1,a1,-1914 # 80007518 <etext+0x518>
    80003c9a:	854a                	mv	a0,s2
    80003c9c:	f0dfc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003ca0:	0149a583          	lw	a1,20(s3)
    80003ca4:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003ca8:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003cac:	8526                	mv	a0,s1
    80003cae:	f3dfe0ef          	jal	80002bea <bread>
  log.lh.n = lh->n;
    80003cb2:	4d30                	lw	a2,88(a0)
    80003cb4:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003cb8:	00c05f63          	blez	a2,80003cd6 <initlog+0x5e>
    80003cbc:	87aa                	mv	a5,a0
    80003cbe:	0001f717          	auipc	a4,0x1f
    80003cc2:	92a70713          	addi	a4,a4,-1750 # 800225e8 <log+0x30>
    80003cc6:	060a                	slli	a2,a2,0x2
    80003cc8:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003cca:	4ff4                	lw	a3,92(a5)
    80003ccc:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003cce:	0791                	addi	a5,a5,4
    80003cd0:	0711                	addi	a4,a4,4
    80003cd2:	fec79ce3          	bne	a5,a2,80003cca <initlog+0x52>
  brelse(buf);
    80003cd6:	81cff0ef          	jal	80002cf2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003cda:	4505                	li	a0,1
    80003cdc:	ed1ff0ef          	jal	80003bac <install_trans>
  log.lh.n = 0;
    80003ce0:	0001f797          	auipc	a5,0x1f
    80003ce4:	9007a223          	sw	zero,-1788(a5) # 800225e4 <log+0x2c>
  write_head(); // clear the log
    80003ce8:	e67ff0ef          	jal	80003b4e <write_head>
}
    80003cec:	70a2                	ld	ra,40(sp)
    80003cee:	7402                	ld	s0,32(sp)
    80003cf0:	64e2                	ld	s1,24(sp)
    80003cf2:	6942                	ld	s2,16(sp)
    80003cf4:	69a2                	ld	s3,8(sp)
    80003cf6:	6145                	addi	sp,sp,48
    80003cf8:	8082                	ret

0000000080003cfa <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003cfa:	1101                	addi	sp,sp,-32
    80003cfc:	ec06                	sd	ra,24(sp)
    80003cfe:	e822                	sd	s0,16(sp)
    80003d00:	e426                	sd	s1,8(sp)
    80003d02:	e04a                	sd	s2,0(sp)
    80003d04:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003d06:	0001f517          	auipc	a0,0x1f
    80003d0a:	8b250513          	addi	a0,a0,-1870 # 800225b8 <log>
    80003d0e:	f1bfc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80003d12:	0001f497          	auipc	s1,0x1f
    80003d16:	8a648493          	addi	s1,s1,-1882 # 800225b8 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003d1a:	4979                	li	s2,30
    80003d1c:	a821                	j	80003d34 <begin_op+0x3a>
      sleep_prepare(&log);
    80003d1e:	8526                	mv	a0,s1
    80003d20:	a78fe0ef          	jal	80001f98 <sleep_prepare>
      release(&log.lock);
    80003d24:	8526                	mv	a0,s1
    80003d26:	f8bfc0ef          	jal	80000cb0 <release>
      sleep();
    80003d2a:	aaafe0ef          	jal	80001fd4 <sleep>
      acquire(&log.lock);
    80003d2e:	8526                	mv	a0,s1
    80003d30:	ef9fc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80003d34:	509c                	lw	a5,32(s1)
    80003d36:	f7e5                	bnez	a5,80003d1e <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003d38:	4cd8                	lw	a4,28(s1)
    80003d3a:	2705                	addiw	a4,a4,1
    80003d3c:	0027179b          	slliw	a5,a4,0x2
    80003d40:	9fb9                	addw	a5,a5,a4
    80003d42:	0017979b          	slliw	a5,a5,0x1
    80003d46:	54d4                	lw	a3,44(s1)
    80003d48:	9fb5                	addw	a5,a5,a3
    80003d4a:	00f95e63          	bge	s2,a5,80003d66 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003d4e:	8526                	mv	a0,s1
    80003d50:	a48fe0ef          	jal	80001f98 <sleep_prepare>
      release(&log.lock);
    80003d54:	8526                	mv	a0,s1
    80003d56:	f5bfc0ef          	jal	80000cb0 <release>
      sleep();
    80003d5a:	a7afe0ef          	jal	80001fd4 <sleep>
      acquire(&log.lock);
    80003d5e:	8526                	mv	a0,s1
    80003d60:	ec9fc0ef          	jal	80000c28 <acquire>
    80003d64:	bfc1                	j	80003d34 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003d66:	0001f797          	auipc	a5,0x1f
    80003d6a:	86e7a723          	sw	a4,-1938(a5) # 800225d4 <log+0x1c>
      release(&log.lock);
    80003d6e:	0001f517          	auipc	a0,0x1f
    80003d72:	84a50513          	addi	a0,a0,-1974 # 800225b8 <log>
    80003d76:	f3bfc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80003d7a:	60e2                	ld	ra,24(sp)
    80003d7c:	6442                	ld	s0,16(sp)
    80003d7e:	64a2                	ld	s1,8(sp)
    80003d80:	6902                	ld	s2,0(sp)
    80003d82:	6105                	addi	sp,sp,32
    80003d84:	8082                	ret

0000000080003d86 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d86:	7139                	addi	sp,sp,-64
    80003d88:	fc06                	sd	ra,56(sp)
    80003d8a:	f822                	sd	s0,48(sp)
    80003d8c:	f426                	sd	s1,40(sp)
    80003d8e:	f04a                	sd	s2,32(sp)
    80003d90:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d92:	0001f497          	auipc	s1,0x1f
    80003d96:	82648493          	addi	s1,s1,-2010 # 800225b8 <log>
    80003d9a:	8526                	mv	a0,s1
    80003d9c:	e8dfc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003da0:	4cdc                	lw	a5,28(s1)
    80003da2:	37fd                	addiw	a5,a5,-1
    80003da4:	893e                	mv	s2,a5
    80003da6:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003da8:	509c                	lw	a5,32(s1)
    80003daa:	e3b1                	bnez	a5,80003dee <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003dac:	04091a63          	bnez	s2,80003e00 <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003db0:	0001f497          	auipc	s1,0x1f
    80003db4:	80848493          	addi	s1,s1,-2040 # 800225b8 <log>
    80003db8:	4785                	li	a5,1
    80003dba:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003dbc:	8526                	mv	a0,s1
    80003dbe:	ef3fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003dc2:	54dc                	lw	a5,44(s1)
    80003dc4:	06f04063          	bgtz	a5,80003e24 <end_op+0x9e>
    acquire(&log.lock);
    80003dc8:	0001e497          	auipc	s1,0x1e
    80003dcc:	7f048493          	addi	s1,s1,2032 # 800225b8 <log>
    80003dd0:	8526                	mv	a0,s1
    80003dd2:	e57fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003dd6:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003dda:	549c                	lw	a5,40(s1)
    80003ddc:	2785                	addiw	a5,a5,1
    80003dde:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003de0:	8526                	mv	a0,s1
    80003de2:	a22fe0ef          	jal	80002004 <wakeup>
    release(&log.lock);
    80003de6:	8526                	mv	a0,s1
    80003de8:	ec9fc0ef          	jal	80000cb0 <release>
}
    80003dec:	a035                	j	80003e18 <end_op+0x92>
    80003dee:	ec4e                	sd	s3,24(sp)
    80003df0:	e852                	sd	s4,16(sp)
    80003df2:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003df4:	00003517          	auipc	a0,0x3
    80003df8:	72c50513          	addi	a0,a0,1836 # 80007520 <etext+0x520>
    80003dfc:	a39fc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003e00:	0001e517          	auipc	a0,0x1e
    80003e04:	7b850513          	addi	a0,a0,1976 # 800225b8 <log>
    80003e08:	9fcfe0ef          	jal	80002004 <wakeup>
  release(&log.lock);
    80003e0c:	0001e517          	auipc	a0,0x1e
    80003e10:	7ac50513          	addi	a0,a0,1964 # 800225b8 <log>
    80003e14:	e9dfc0ef          	jal	80000cb0 <release>
}
    80003e18:	70e2                	ld	ra,56(sp)
    80003e1a:	7442                	ld	s0,48(sp)
    80003e1c:	74a2                	ld	s1,40(sp)
    80003e1e:	7902                	ld	s2,32(sp)
    80003e20:	6121                	addi	sp,sp,64
    80003e22:	8082                	ret
    80003e24:	ec4e                	sd	s3,24(sp)
    80003e26:	e852                	sd	s4,16(sp)
    80003e28:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e2a:	0001ea97          	auipc	s5,0x1e
    80003e2e:	7bea8a93          	addi	s5,s5,1982 # 800225e8 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003e32:	0001ea17          	auipc	s4,0x1e
    80003e36:	786a0a13          	addi	s4,s4,1926 # 800225b8 <log>
    80003e3a:	018a2583          	lw	a1,24(s4)
    80003e3e:	012585bb          	addw	a1,a1,s2
    80003e42:	2585                	addiw	a1,a1,1
    80003e44:	024a2503          	lw	a0,36(s4)
    80003e48:	da3fe0ef          	jal	80002bea <bread>
    80003e4c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003e4e:	000aa583          	lw	a1,0(s5)
    80003e52:	024a2503          	lw	a0,36(s4)
    80003e56:	d95fe0ef          	jal	80002bea <bread>
    80003e5a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e5c:	40000613          	li	a2,1024
    80003e60:	05850593          	addi	a1,a0,88
    80003e64:	05848513          	addi	a0,s1,88
    80003e68:	ee1fc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    80003e6c:	8526                	mv	a0,s1
    80003e6e:	e53fe0ef          	jal	80002cc0 <bwrite>
    brelse(from);
    80003e72:	854e                	mv	a0,s3
    80003e74:	e7ffe0ef          	jal	80002cf2 <brelse>
    brelse(to);
    80003e78:	8526                	mv	a0,s1
    80003e7a:	e79fe0ef          	jal	80002cf2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e7e:	2905                	addiw	s2,s2,1
    80003e80:	0a91                	addi	s5,s5,4
    80003e82:	02ca2783          	lw	a5,44(s4)
    80003e86:	faf94ae3          	blt	s2,a5,80003e3a <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003e8a:	cc5ff0ef          	jal	80003b4e <write_head>
    install_trans(0); // Now install writes to home locations
    80003e8e:	4501                	li	a0,0
    80003e90:	d1dff0ef          	jal	80003bac <install_trans>
    log.lh.n = 0;
    80003e94:	0001e797          	auipc	a5,0x1e
    80003e98:	7407a823          	sw	zero,1872(a5) # 800225e4 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003e9c:	cb3ff0ef          	jal	80003b4e <write_head>
    80003ea0:	69e2                	ld	s3,24(sp)
    80003ea2:	6a42                	ld	s4,16(sp)
    80003ea4:	6aa2                	ld	s5,8(sp)
    80003ea6:	b70d                	j	80003dc8 <end_op+0x42>

0000000080003ea8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003ea8:	1101                	addi	sp,sp,-32
    80003eaa:	ec06                	sd	ra,24(sp)
    80003eac:	e822                	sd	s0,16(sp)
    80003eae:	e426                	sd	s1,8(sp)
    80003eb0:	1000                	addi	s0,sp,32
    80003eb2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003eb4:	0001e517          	auipc	a0,0x1e
    80003eb8:	70450513          	addi	a0,a0,1796 # 800225b8 <log>
    80003ebc:	d6dfc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003ec0:	0001e617          	auipc	a2,0x1e
    80003ec4:	72462603          	lw	a2,1828(a2) # 800225e4 <log+0x2c>
    80003ec8:	47f5                	li	a5,29
    80003eca:	04c7cd63          	blt	a5,a2,80003f24 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003ece:	0001e797          	auipc	a5,0x1e
    80003ed2:	7067a783          	lw	a5,1798(a5) # 800225d4 <log+0x1c>
    80003ed6:	04f05d63          	blez	a5,80003f30 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003eda:	4781                	li	a5,0
    80003edc:	06c05063          	blez	a2,80003f3c <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003ee0:	44cc                	lw	a1,12(s1)
    80003ee2:	0001e717          	auipc	a4,0x1e
    80003ee6:	70670713          	addi	a4,a4,1798 # 800225e8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003eea:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003eec:	4314                	lw	a3,0(a4)
    80003eee:	04b68763          	beq	a3,a1,80003f3c <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003ef2:	2785                	addiw	a5,a5,1
    80003ef4:	0711                	addi	a4,a4,4
    80003ef6:	fef61be3          	bne	a2,a5,80003eec <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003efa:	060a                	slli	a2,a2,0x2
    80003efc:	02060613          	addi	a2,a2,32
    80003f00:	0001e797          	auipc	a5,0x1e
    80003f04:	6b878793          	addi	a5,a5,1720 # 800225b8 <log>
    80003f08:	97b2                	add	a5,a5,a2
    80003f0a:	44d8                	lw	a4,12(s1)
    80003f0c:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003f0e:	8526                	mv	a0,s1
    80003f10:	e67fe0ef          	jal	80002d76 <bpin>
    log.lh.n++;
    80003f14:	0001e717          	auipc	a4,0x1e
    80003f18:	6a470713          	addi	a4,a4,1700 # 800225b8 <log>
    80003f1c:	575c                	lw	a5,44(a4)
    80003f1e:	2785                	addiw	a5,a5,1
    80003f20:	d75c                	sw	a5,44(a4)
    80003f22:	a815                	j	80003f56 <log_write+0xae>
    panic("too big a transaction");
    80003f24:	00003517          	auipc	a0,0x3
    80003f28:	60c50513          	addi	a0,a0,1548 # 80007530 <etext+0x530>
    80003f2c:	909fc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    80003f30:	00003517          	auipc	a0,0x3
    80003f34:	61850513          	addi	a0,a0,1560 # 80007548 <etext+0x548>
    80003f38:	8fdfc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    80003f3c:	00279693          	slli	a3,a5,0x2
    80003f40:	02068693          	addi	a3,a3,32
    80003f44:	0001e717          	auipc	a4,0x1e
    80003f48:	67470713          	addi	a4,a4,1652 # 800225b8 <log>
    80003f4c:	9736                	add	a4,a4,a3
    80003f4e:	44d4                	lw	a3,12(s1)
    80003f50:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80003f52:	faf60ee3          	beq	a2,a5,80003f0e <log_write+0x66>
  }
  release(&log.lock);
    80003f56:	0001e517          	auipc	a0,0x1e
    80003f5a:	66250513          	addi	a0,a0,1634 # 800225b8 <log>
    80003f5e:	d53fc0ef          	jal	80000cb0 <release>
}
    80003f62:	60e2                	ld	ra,24(sp)
    80003f64:	6442                	ld	s0,16(sp)
    80003f66:	64a2                	ld	s1,8(sp)
    80003f68:	6105                	addi	sp,sp,32
    80003f6a:	8082                	ret

0000000080003f6c <sys_sync>:

uint64
sys_sync(void)
{
    80003f6c:	1101                	addi	sp,sp,-32
    80003f6e:	ec06                	sd	ra,24(sp)
    80003f70:	e822                	sd	s0,16(sp)
    80003f72:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003f74:	0001e517          	auipc	a0,0x1e
    80003f78:	64450513          	addi	a0,a0,1604 # 800225b8 <log>
    80003f7c:	cadfc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    80003f80:	0001e797          	auipc	a5,0x1e
    80003f84:	6587a783          	lw	a5,1624(a5) # 800225d8 <log+0x20>
    80003f88:	e799                	bnez	a5,80003f96 <sys_sync+0x2a>
    80003f8a:	0001e797          	auipc	a5,0x1e
    80003f8e:	64a7a783          	lw	a5,1610(a5) # 800225d4 <log+0x1c>
    80003f92:	02f05c63          	blez	a5,80003fca <sys_sync+0x5e>
    80003f96:	e426                	sd	s1,8(sp)
    80003f98:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80003f9a:	0001e917          	auipc	s2,0x1e
    80003f9e:	64692903          	lw	s2,1606(s2) # 800225e0 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80003fa2:	0001e497          	auipc	s1,0x1e
    80003fa6:	61648493          	addi	s1,s1,1558 # 800225b8 <log>
    80003faa:	8526                	mv	a0,s1
    80003fac:	fedfd0ef          	jal	80001f98 <sleep_prepare>
      release(&log.lock);
    80003fb0:	8526                	mv	a0,s1
    80003fb2:	cfffc0ef          	jal	80000cb0 <release>
      sleep();
    80003fb6:	81efe0ef          	jal	80001fd4 <sleep>
      acquire(&log.lock);
    80003fba:	8526                	mv	a0,s1
    80003fbc:	c6dfc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    80003fc0:	549c                	lw	a5,40(s1)
    80003fc2:	fef954e3          	bge	s2,a5,80003faa <sys_sync+0x3e>
    80003fc6:	64a2                	ld	s1,8(sp)
    80003fc8:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80003fca:	0001e517          	auipc	a0,0x1e
    80003fce:	5ee50513          	addi	a0,a0,1518 # 800225b8 <log>
    80003fd2:	cdffc0ef          	jal	80000cb0 <release>
  return 0;
}
    80003fd6:	4501                	li	a0,0
    80003fd8:	60e2                	ld	ra,24(sp)
    80003fda:	6442                	ld	s0,16(sp)
    80003fdc:	6105                	addi	sp,sp,32
    80003fde:	8082                	ret

0000000080003fe0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003fe0:	1101                	addi	sp,sp,-32
    80003fe2:	ec06                	sd	ra,24(sp)
    80003fe4:	e822                	sd	s0,16(sp)
    80003fe6:	e426                	sd	s1,8(sp)
    80003fe8:	e04a                	sd	s2,0(sp)
    80003fea:	1000                	addi	s0,sp,32
    80003fec:	84aa                	mv	s1,a0
    80003fee:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003ff0:	00003597          	auipc	a1,0x3
    80003ff4:	57858593          	addi	a1,a1,1400 # 80007568 <etext+0x568>
    80003ff8:	0521                	addi	a0,a0,8
    80003ffa:	baffc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    80003ffe:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004002:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004006:	0204a423          	sw	zero,40(s1)
}
    8000400a:	60e2                	ld	ra,24(sp)
    8000400c:	6442                	ld	s0,16(sp)
    8000400e:	64a2                	ld	s1,8(sp)
    80004010:	6902                	ld	s2,0(sp)
    80004012:	6105                	addi	sp,sp,32
    80004014:	8082                	ret

0000000080004016 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004016:	1101                	addi	sp,sp,-32
    80004018:	ec06                	sd	ra,24(sp)
    8000401a:	e822                	sd	s0,16(sp)
    8000401c:	e426                	sd	s1,8(sp)
    8000401e:	e04a                	sd	s2,0(sp)
    80004020:	1000                	addi	s0,sp,32
    80004022:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004024:	00850913          	addi	s2,a0,8
    80004028:	854a                	mv	a0,s2
    8000402a:	bfffc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    8000402e:	409c                	lw	a5,0(s1)
    80004030:	cf91                	beqz	a5,8000404c <acquiresleep+0x36>
    sleep_prepare(lk);
    80004032:	8526                	mv	a0,s1
    80004034:	f65fd0ef          	jal	80001f98 <sleep_prepare>
    release(&lk->lk);
    80004038:	854a                	mv	a0,s2
    8000403a:	c77fc0ef          	jal	80000cb0 <release>
    sleep();
    8000403e:	f97fd0ef          	jal	80001fd4 <sleep>
    acquire(&lk->lk);
    80004042:	854a                	mv	a0,s2
    80004044:	be5fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004048:	409c                	lw	a5,0(s1)
    8000404a:	f7e5                	bnez	a5,80004032 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000404c:	4785                	li	a5,1
    8000404e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004050:	8f9fd0ef          	jal	80001948 <myproc>
    80004054:	591c                	lw	a5,48(a0)
    80004056:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004058:	854a                	mv	a0,s2
    8000405a:	c57fc0ef          	jal	80000cb0 <release>
}
    8000405e:	60e2                	ld	ra,24(sp)
    80004060:	6442                	ld	s0,16(sp)
    80004062:	64a2                	ld	s1,8(sp)
    80004064:	6902                	ld	s2,0(sp)
    80004066:	6105                	addi	sp,sp,32
    80004068:	8082                	ret

000000008000406a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000406a:	1101                	addi	sp,sp,-32
    8000406c:	ec06                	sd	ra,24(sp)
    8000406e:	e822                	sd	s0,16(sp)
    80004070:	e426                	sd	s1,8(sp)
    80004072:	e04a                	sd	s2,0(sp)
    80004074:	1000                	addi	s0,sp,32
    80004076:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004078:	00850913          	addi	s2,a0,8
    8000407c:	854a                	mv	a0,s2
    8000407e:	babfc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    80004082:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004086:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000408a:	8526                	mv	a0,s1
    8000408c:	f79fd0ef          	jal	80002004 <wakeup>
  release(&lk->lk);
    80004090:	854a                	mv	a0,s2
    80004092:	c1ffc0ef          	jal	80000cb0 <release>
}
    80004096:	60e2                	ld	ra,24(sp)
    80004098:	6442                	ld	s0,16(sp)
    8000409a:	64a2                	ld	s1,8(sp)
    8000409c:	6902                	ld	s2,0(sp)
    8000409e:	6105                	addi	sp,sp,32
    800040a0:	8082                	ret

00000000800040a2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800040a2:	7179                	addi	sp,sp,-48
    800040a4:	f406                	sd	ra,40(sp)
    800040a6:	f022                	sd	s0,32(sp)
    800040a8:	ec26                	sd	s1,24(sp)
    800040aa:	e84a                	sd	s2,16(sp)
    800040ac:	1800                	addi	s0,sp,48
    800040ae:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800040b0:	00850913          	addi	s2,a0,8
    800040b4:	854a                	mv	a0,s2
    800040b6:	b73fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800040ba:	409c                	lw	a5,0(s1)
    800040bc:	ef81                	bnez	a5,800040d4 <holdingsleep+0x32>
    800040be:	4481                	li	s1,0
  release(&lk->lk);
    800040c0:	854a                	mv	a0,s2
    800040c2:	beffc0ef          	jal	80000cb0 <release>
  return r;
}
    800040c6:	8526                	mv	a0,s1
    800040c8:	70a2                	ld	ra,40(sp)
    800040ca:	7402                	ld	s0,32(sp)
    800040cc:	64e2                	ld	s1,24(sp)
    800040ce:	6942                	ld	s2,16(sp)
    800040d0:	6145                	addi	sp,sp,48
    800040d2:	8082                	ret
    800040d4:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800040d6:	0284a983          	lw	s3,40(s1)
    800040da:	86ffd0ef          	jal	80001948 <myproc>
    800040de:	5904                	lw	s1,48(a0)
    800040e0:	413484b3          	sub	s1,s1,s3
    800040e4:	0014b493          	seqz	s1,s1
    800040e8:	69a2                	ld	s3,8(sp)
    800040ea:	bfd9                	j	800040c0 <holdingsleep+0x1e>

00000000800040ec <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800040ec:	1141                	addi	sp,sp,-16
    800040ee:	e406                	sd	ra,8(sp)
    800040f0:	e022                	sd	s0,0(sp)
    800040f2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800040f4:	00003597          	auipc	a1,0x3
    800040f8:	48458593          	addi	a1,a1,1156 # 80007578 <etext+0x578>
    800040fc:	0001e517          	auipc	a0,0x1e
    80004100:	60450513          	addi	a0,a0,1540 # 80022700 <ftable>
    80004104:	aa5fc0ef          	jal	80000ba8 <initlock>
}
    80004108:	60a2                	ld	ra,8(sp)
    8000410a:	6402                	ld	s0,0(sp)
    8000410c:	0141                	addi	sp,sp,16
    8000410e:	8082                	ret

0000000080004110 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80004110:	1101                	addi	sp,sp,-32
    80004112:	ec06                	sd	ra,24(sp)
    80004114:	e822                	sd	s0,16(sp)
    80004116:	e426                	sd	s1,8(sp)
    80004118:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000411a:	0001e517          	auipc	a0,0x1e
    8000411e:	5e650513          	addi	a0,a0,1510 # 80022700 <ftable>
    80004122:	b07fc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004126:	0001e497          	auipc	s1,0x1e
    8000412a:	5f248493          	addi	s1,s1,1522 # 80022718 <ftable+0x18>
    8000412e:	0001f717          	auipc	a4,0x1f
    80004132:	58a70713          	addi	a4,a4,1418 # 800236b8 <disk>
    if (f->ref == 0) {
    80004136:	40dc                	lw	a5,4(s1)
    80004138:	cf89                	beqz	a5,80004152 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    8000413a:	02848493          	addi	s1,s1,40
    8000413e:	fee49ce3          	bne	s1,a4,80004136 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004142:	0001e517          	auipc	a0,0x1e
    80004146:	5be50513          	addi	a0,a0,1470 # 80022700 <ftable>
    8000414a:	b67fc0ef          	jal	80000cb0 <release>
  return 0;
    8000414e:	4481                	li	s1,0
    80004150:	a809                	j	80004162 <filealloc+0x52>
      f->ref = 1;
    80004152:	4785                	li	a5,1
    80004154:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004156:	0001e517          	auipc	a0,0x1e
    8000415a:	5aa50513          	addi	a0,a0,1450 # 80022700 <ftable>
    8000415e:	b53fc0ef          	jal	80000cb0 <release>
}
    80004162:	8526                	mv	a0,s1
    80004164:	60e2                	ld	ra,24(sp)
    80004166:	6442                	ld	s0,16(sp)
    80004168:	64a2                	ld	s1,8(sp)
    8000416a:	6105                	addi	sp,sp,32
    8000416c:	8082                	ret

000000008000416e <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    8000416e:	1101                	addi	sp,sp,-32
    80004170:	ec06                	sd	ra,24(sp)
    80004172:	e822                	sd	s0,16(sp)
    80004174:	e426                	sd	s1,8(sp)
    80004176:	1000                	addi	s0,sp,32
    80004178:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000417a:	0001e517          	auipc	a0,0x1e
    8000417e:	58650513          	addi	a0,a0,1414 # 80022700 <ftable>
    80004182:	aa7fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    80004186:	40dc                	lw	a5,4(s1)
    80004188:	02f05063          	blez	a5,800041a8 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000418c:	2785                	addiw	a5,a5,1
    8000418e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004190:	0001e517          	auipc	a0,0x1e
    80004194:	57050513          	addi	a0,a0,1392 # 80022700 <ftable>
    80004198:	b19fc0ef          	jal	80000cb0 <release>
  return f;
}
    8000419c:	8526                	mv	a0,s1
    8000419e:	60e2                	ld	ra,24(sp)
    800041a0:	6442                	ld	s0,16(sp)
    800041a2:	64a2                	ld	s1,8(sp)
    800041a4:	6105                	addi	sp,sp,32
    800041a6:	8082                	ret
    panic("filedup");
    800041a8:	00003517          	auipc	a0,0x3
    800041ac:	3d850513          	addi	a0,a0,984 # 80007580 <etext+0x580>
    800041b0:	e84fc0ef          	jal	80000834 <panic>

00000000800041b4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800041b4:	7139                	addi	sp,sp,-64
    800041b6:	fc06                	sd	ra,56(sp)
    800041b8:	f822                	sd	s0,48(sp)
    800041ba:	f426                	sd	s1,40(sp)
    800041bc:	0080                	addi	s0,sp,64
    800041be:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800041c0:	0001e517          	auipc	a0,0x1e
    800041c4:	54050513          	addi	a0,a0,1344 # 80022700 <ftable>
    800041c8:	a61fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800041cc:	40dc                	lw	a5,4(s1)
    800041ce:	04f05a63          	blez	a5,80004222 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    800041d2:	37fd                	addiw	a5,a5,-1
    800041d4:	c0dc                	sw	a5,4(s1)
    800041d6:	06f04063          	bgtz	a5,80004236 <fileclose+0x82>
    800041da:	f04a                	sd	s2,32(sp)
    800041dc:	ec4e                	sd	s3,24(sp)
    800041de:	e852                	sd	s4,16(sp)
    800041e0:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800041e2:	0004a903          	lw	s2,0(s1)
    800041e6:	0094c783          	lbu	a5,9(s1)
    800041ea:	89be                	mv	s3,a5
    800041ec:	689c                	ld	a5,16(s1)
    800041ee:	8a3e                	mv	s4,a5
    800041f0:	6c9c                	ld	a5,24(s1)
    800041f2:	8abe                	mv	s5,a5
  f->ref = 0;
    800041f4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800041f8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800041fc:	0001e517          	auipc	a0,0x1e
    80004200:	50450513          	addi	a0,a0,1284 # 80022700 <ftable>
    80004204:	aadfc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    80004208:	4785                	li	a5,1
    8000420a:	04f90163          	beq	s2,a5,8000424c <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    8000420e:	ffe9079b          	addiw	a5,s2,-2
    80004212:	4705                	li	a4,1
    80004214:	04f77563          	bgeu	a4,a5,8000425e <fileclose+0xaa>
    80004218:	7902                	ld	s2,32(sp)
    8000421a:	69e2                	ld	s3,24(sp)
    8000421c:	6a42                	ld	s4,16(sp)
    8000421e:	6aa2                	ld	s5,8(sp)
    80004220:	a00d                	j	80004242 <fileclose+0x8e>
    80004222:	f04a                	sd	s2,32(sp)
    80004224:	ec4e                	sd	s3,24(sp)
    80004226:	e852                	sd	s4,16(sp)
    80004228:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000422a:	00003517          	auipc	a0,0x3
    8000422e:	35e50513          	addi	a0,a0,862 # 80007588 <etext+0x588>
    80004232:	e02fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    80004236:	0001e517          	auipc	a0,0x1e
    8000423a:	4ca50513          	addi	a0,a0,1226 # 80022700 <ftable>
    8000423e:	a73fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004242:	70e2                	ld	ra,56(sp)
    80004244:	7442                	ld	s0,48(sp)
    80004246:	74a2                	ld	s1,40(sp)
    80004248:	6121                	addi	sp,sp,64
    8000424a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000424c:	85ce                	mv	a1,s3
    8000424e:	8552                	mv	a0,s4
    80004250:	36a000ef          	jal	800045ba <pipeclose>
    80004254:	7902                	ld	s2,32(sp)
    80004256:	69e2                	ld	s3,24(sp)
    80004258:	6a42                	ld	s4,16(sp)
    8000425a:	6aa2                	ld	s5,8(sp)
    8000425c:	b7dd                	j	80004242 <fileclose+0x8e>
    begin_op();
    8000425e:	a9dff0ef          	jal	80003cfa <begin_op>
    iput(ff.ip);
    80004262:	8556                	mv	a0,s5
    80004264:	9a0ff0ef          	jal	80003404 <iput>
    end_op();
    80004268:	b1fff0ef          	jal	80003d86 <end_op>
    8000426c:	7902                	ld	s2,32(sp)
    8000426e:	69e2                	ld	s3,24(sp)
    80004270:	6a42                	ld	s4,16(sp)
    80004272:	6aa2                	ld	s5,8(sp)
    80004274:	b7f9                	j	80004242 <fileclose+0x8e>

0000000080004276 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004276:	715d                	addi	sp,sp,-80
    80004278:	e486                	sd	ra,72(sp)
    8000427a:	e0a2                	sd	s0,64(sp)
    8000427c:	fc26                	sd	s1,56(sp)
    8000427e:	f052                	sd	s4,32(sp)
    80004280:	0880                	addi	s0,sp,80
    80004282:	84aa                	mv	s1,a0
    80004284:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004286:	ec2fd0ef          	jal	80001948 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    8000428a:	409c                	lw	a5,0(s1)
    8000428c:	37f9                	addiw	a5,a5,-2
    8000428e:	4705                	li	a4,1
    80004290:	04f76963          	bltu	a4,a5,800042e2 <filestat+0x6c>
    80004294:	f84a                	sd	s2,48(sp)
    80004296:	f44e                	sd	s3,40(sp)
    80004298:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    8000429a:	fb840993          	addi	s3,s0,-72
    8000429e:	4661                	li	a2,24
    800042a0:	4581                	li	a1,0
    800042a2:	854e                	mv	a0,s3
    800042a4:	a45fc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    800042a8:	6c88                	ld	a0,24(s1)
    800042aa:	fd9fe0ef          	jal	80003282 <ilock>
    stati(f->ip, &st);
    800042ae:	85ce                	mv	a1,s3
    800042b0:	6c88                	ld	a0,24(s1)
    800042b2:	b7cff0ef          	jal	8000362e <stati>
    iunlock(f->ip);
    800042b6:	6c88                	ld	a0,24(s1)
    800042b8:	878ff0ef          	jal	80003330 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    800042bc:	4761                	li	a4,24
    800042be:	86ce                	mv	a3,s3
    800042c0:	8652                	mv	a2,s4
    800042c2:	04893583          	ld	a1,72(s2)
    800042c6:	05093503          	ld	a0,80(s2)
    800042ca:	ab8fd0ef          	jal	80001582 <copyout>
    800042ce:	41f5551b          	sraiw	a0,a0,0x1f
    800042d2:	7942                	ld	s2,48(sp)
    800042d4:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800042d6:	60a6                	ld	ra,72(sp)
    800042d8:	6406                	ld	s0,64(sp)
    800042da:	74e2                	ld	s1,56(sp)
    800042dc:	7a02                	ld	s4,32(sp)
    800042de:	6161                	addi	sp,sp,80
    800042e0:	8082                	ret
  return -1;
    800042e2:	557d                	li	a0,-1
    800042e4:	bfcd                	j	800042d6 <filestat+0x60>

00000000800042e6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800042e6:	7179                	addi	sp,sp,-48
    800042e8:	f406                	sd	ra,40(sp)
    800042ea:	f022                	sd	s0,32(sp)
    800042ec:	e84a                	sd	s2,16(sp)
    800042ee:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    800042f0:	00854783          	lbu	a5,8(a0)
    800042f4:	c3dd                	beqz	a5,8000439a <fileread+0xb4>
    800042f6:	ec26                	sd	s1,24(sp)
    800042f8:	e44e                	sd	s3,8(sp)
    800042fa:	84aa                	mv	s1,a0
    800042fc:	892e                	mv	s2,a1
    800042fe:	89b2                	mv	s3,a2
    80004300:	01f6579b          	srliw	a5,a2,0x1f
    80004304:	ebc9                	bnez	a5,80004396 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    80004306:	411c                	lw	a5,0(a0)
    80004308:	4705                	li	a4,1
    8000430a:	04e78363          	beq	a5,a4,80004350 <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000430e:	470d                	li	a4,3
    80004310:	04e78763          	beq	a5,a4,8000435e <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004314:	4709                	li	a4,2
    80004316:	06e79a63          	bne	a5,a4,8000438a <fileread+0xa4>
    ilock(f->ip);
    8000431a:	6d08                	ld	a0,24(a0)
    8000431c:	f67fe0ef          	jal	80003282 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004320:	874e                	mv	a4,s3
    80004322:	5094                	lw	a3,32(s1)
    80004324:	864a                	mv	a2,s2
    80004326:	4585                	li	a1,1
    80004328:	6c88                	ld	a0,24(s1)
    8000432a:	b32ff0ef          	jal	8000365c <readi>
    8000432e:	892a                	mv	s2,a0
    80004330:	00a05563          	blez	a0,8000433a <fileread+0x54>
      f->off += r;
    80004334:	509c                	lw	a5,32(s1)
    80004336:	9fa9                	addw	a5,a5,a0
    80004338:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000433a:	6c88                	ld	a0,24(s1)
    8000433c:	ff5fe0ef          	jal	80003330 <iunlock>
    80004340:	64e2                	ld	s1,24(sp)
    80004342:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004344:	854a                	mv	a0,s2
    80004346:	70a2                	ld	ra,40(sp)
    80004348:	7402                	ld	s0,32(sp)
    8000434a:	6942                	ld	s2,16(sp)
    8000434c:	6145                	addi	sp,sp,48
    8000434e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004350:	6908                	ld	a0,16(a0)
    80004352:	3e2000ef          	jal	80004734 <piperead>
    80004356:	892a                	mv	s2,a0
    80004358:	64e2                	ld	s1,24(sp)
    8000435a:	69a2                	ld	s3,8(sp)
    8000435c:	b7e5                	j	80004344 <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000435e:	02451783          	lh	a5,36(a0)
    80004362:	03079693          	slli	a3,a5,0x30
    80004366:	92c1                	srli	a3,a3,0x30
    80004368:	4725                	li	a4,9
    8000436a:	02d76b63          	bltu	a4,a3,800043a0 <fileread+0xba>
    8000436e:	0792                	slli	a5,a5,0x4
    80004370:	0001e717          	auipc	a4,0x1e
    80004374:	2f070713          	addi	a4,a4,752 # 80022660 <devsw>
    80004378:	97ba                	add	a5,a5,a4
    8000437a:	639c                	ld	a5,0(a5)
    8000437c:	c79d                	beqz	a5,800043aa <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    8000437e:	4505                	li	a0,1
    80004380:	9782                	jalr	a5
    80004382:	892a                	mv	s2,a0
    80004384:	64e2                	ld	s1,24(sp)
    80004386:	69a2                	ld	s3,8(sp)
    80004388:	bf75                	j	80004344 <fileread+0x5e>
    panic("fileread");
    8000438a:	00003517          	auipc	a0,0x3
    8000438e:	20e50513          	addi	a0,a0,526 # 80007598 <etext+0x598>
    80004392:	ca2fc0ef          	jal	80000834 <panic>
    80004396:	64e2                	ld	s1,24(sp)
    80004398:	69a2                	ld	s3,8(sp)
    return -1;
    8000439a:	57fd                	li	a5,-1
    8000439c:	893e                	mv	s2,a5
    8000439e:	b75d                	j	80004344 <fileread+0x5e>
      return -1;
    800043a0:	57fd                	li	a5,-1
    800043a2:	893e                	mv	s2,a5
    800043a4:	64e2                	ld	s1,24(sp)
    800043a6:	69a2                	ld	s3,8(sp)
    800043a8:	bf71                	j	80004344 <fileread+0x5e>
    800043aa:	57fd                	li	a5,-1
    800043ac:	893e                	mv	s2,a5
    800043ae:	64e2                	ld	s1,24(sp)
    800043b0:	69a2                	ld	s3,8(sp)
    800043b2:	bf49                	j	80004344 <fileread+0x5e>

00000000800043b4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    800043b4:	00954783          	lbu	a5,9(a0)
    800043b8:	12078b63          	beqz	a5,800044ee <filewrite+0x13a>
{
    800043bc:	711d                	addi	sp,sp,-96
    800043be:	ec86                	sd	ra,88(sp)
    800043c0:	e8a2                	sd	s0,80(sp)
    800043c2:	e0ca                	sd	s2,64(sp)
    800043c4:	f456                	sd	s5,40(sp)
    800043c6:	f05a                	sd	s6,32(sp)
    800043c8:	1080                	addi	s0,sp,96
    800043ca:	892a                	mv	s2,a0
    800043cc:	8b2e                	mv	s6,a1
    800043ce:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    800043d0:	01f6579b          	srliw	a5,a2,0x1f
    800043d4:	0e079d63          	bnez	a5,800044ce <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    800043d8:	411c                	lw	a5,0(a0)
    800043da:	4705                	li	a4,1
    800043dc:	02e78a63          	beq	a5,a4,80004410 <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800043e0:	470d                	li	a4,3
    800043e2:	02e78b63          	beq	a5,a4,80004418 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    800043e6:	4709                	li	a4,2
    800043e8:	0ce79763          	bne	a5,a4,800044b6 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    800043ec:	0ec05763          	blez	a2,800044da <filewrite+0x126>
    800043f0:	e4a6                	sd	s1,72(sp)
    800043f2:	fc4e                	sd	s3,56(sp)
    800043f4:	f852                	sd	s4,48(sp)
    800043f6:	ec5e                	sd	s7,24(sp)
    800043f8:	e862                	sd	s8,16(sp)
    800043fa:	e466                	sd	s9,8(sp)
    int i = 0;
    800043fc:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    800043fe:	6b85                	lui	s7,0x1
    80004400:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004404:	6785                	lui	a5,0x1
    80004406:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    8000440a:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000440c:	4c05                	li	s8,1
    8000440e:	a8ad                	j	80004488 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    80004410:	6908                	ld	a0,16(a0)
    80004412:	206000ef          	jal	80004618 <pipewrite>
    80004416:	a849                	j	800044a8 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004418:	02451783          	lh	a5,36(a0)
    8000441c:	03079693          	slli	a3,a5,0x30
    80004420:	92c1                	srli	a3,a3,0x30
    80004422:	4725                	li	a4,9
    80004424:	0ad76763          	bltu	a4,a3,800044d2 <filewrite+0x11e>
    80004428:	0792                	slli	a5,a5,0x4
    8000442a:	0001e717          	auipc	a4,0x1e
    8000442e:	23670713          	addi	a4,a4,566 # 80022660 <devsw>
    80004432:	97ba                	add	a5,a5,a4
    80004434:	679c                	ld	a5,8(a5)
    80004436:	c3c5                	beqz	a5,800044d6 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004438:	4505                	li	a0,1
    8000443a:	9782                	jalr	a5
    8000443c:	a0b5                	j	800044a8 <filewrite+0xf4>
      if (n1 > max)
    8000443e:	2981                	sext.w	s3,s3
      begin_op();
    80004440:	8bbff0ef          	jal	80003cfa <begin_op>
      ilock(f->ip);
    80004444:	01893503          	ld	a0,24(s2)
    80004448:	e3bfe0ef          	jal	80003282 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000444c:	874e                	mv	a4,s3
    8000444e:	02092683          	lw	a3,32(s2)
    80004452:	016a0633          	add	a2,s4,s6
    80004456:	85e2                	mv	a1,s8
    80004458:	01893503          	ld	a0,24(s2)
    8000445c:	af2ff0ef          	jal	8000374e <writei>
    80004460:	84aa                	mv	s1,a0
    80004462:	00a05763          	blez	a0,80004470 <filewrite+0xbc>
        f->off += r;
    80004466:	02092783          	lw	a5,32(s2)
    8000446a:	9fa9                	addw	a5,a5,a0
    8000446c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004470:	01893503          	ld	a0,24(s2)
    80004474:	ebdfe0ef          	jal	80003330 <iunlock>
      end_op();
    80004478:	90fff0ef          	jal	80003d86 <end_op>

      if (r != n1) {
    8000447c:	00999d63          	bne	s3,s1,80004496 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    80004480:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    80004484:	015a5963          	bge	s4,s5,80004496 <filewrite+0xe2>
      int n1 = n - i;
    80004488:	414a87bb          	subw	a5,s5,s4
    8000448c:	89be                	mv	s3,a5
      if (n1 > max)
    8000448e:	fafbd8e3          	bge	s7,a5,8000443e <filewrite+0x8a>
    80004492:	89e6                	mv	s3,s9
    80004494:	b76d                	j	8000443e <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    80004496:	054a9463          	bne	s5,s4,800044de <filewrite+0x12a>
    8000449a:	8556                	mv	a0,s5
    8000449c:	64a6                	ld	s1,72(sp)
    8000449e:	79e2                	ld	s3,56(sp)
    800044a0:	7a42                	ld	s4,48(sp)
    800044a2:	6be2                	ld	s7,24(sp)
    800044a4:	6c42                	ld	s8,16(sp)
    800044a6:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800044a8:	60e6                	ld	ra,88(sp)
    800044aa:	6446                	ld	s0,80(sp)
    800044ac:	6906                	ld	s2,64(sp)
    800044ae:	7aa2                	ld	s5,40(sp)
    800044b0:	7b02                	ld	s6,32(sp)
    800044b2:	6125                	addi	sp,sp,96
    800044b4:	8082                	ret
    800044b6:	e4a6                	sd	s1,72(sp)
    800044b8:	fc4e                	sd	s3,56(sp)
    800044ba:	f852                	sd	s4,48(sp)
    800044bc:	ec5e                	sd	s7,24(sp)
    800044be:	e862                	sd	s8,16(sp)
    800044c0:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800044c2:	00003517          	auipc	a0,0x3
    800044c6:	0e650513          	addi	a0,a0,230 # 800075a8 <etext+0x5a8>
    800044ca:	b6afc0ef          	jal	80000834 <panic>
    return -1;
    800044ce:	557d                	li	a0,-1
    800044d0:	bfe1                	j	800044a8 <filewrite+0xf4>
      return -1;
    800044d2:	557d                	li	a0,-1
    800044d4:	bfd1                	j	800044a8 <filewrite+0xf4>
    800044d6:	557d                	li	a0,-1
    800044d8:	bfc1                	j	800044a8 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    800044da:	8532                	mv	a0,a2
    800044dc:	b7f1                	j	800044a8 <filewrite+0xf4>
    800044de:	557d                	li	a0,-1
    800044e0:	64a6                	ld	s1,72(sp)
    800044e2:	79e2                	ld	s3,56(sp)
    800044e4:	7a42                	ld	s4,48(sp)
    800044e6:	6be2                	ld	s7,24(sp)
    800044e8:	6c42                	ld	s8,16(sp)
    800044ea:	6ca2                	ld	s9,8(sp)
    800044ec:	bf75                	j	800044a8 <filewrite+0xf4>
    return -1;
    800044ee:	557d                	li	a0,-1
}
    800044f0:	8082                	ret

00000000800044f2 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800044f2:	7179                	addi	sp,sp,-48
    800044f4:	f406                	sd	ra,40(sp)
    800044f6:	f022                	sd	s0,32(sp)
    800044f8:	ec26                	sd	s1,24(sp)
    800044fa:	e052                	sd	s4,0(sp)
    800044fc:	1800                	addi	s0,sp,48
    800044fe:	84aa                	mv	s1,a0
    80004500:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004502:	0005b023          	sd	zero,0(a1)
    80004506:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000450a:	c07ff0ef          	jal	80004110 <filealloc>
    8000450e:	e088                	sd	a0,0(s1)
    80004510:	c549                	beqz	a0,8000459a <pipealloc+0xa8>
    80004512:	bffff0ef          	jal	80004110 <filealloc>
    80004516:	00aa3023          	sd	a0,0(s4)
    8000451a:	cd25                	beqz	a0,80004592 <pipealloc+0xa0>
    8000451c:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    8000451e:	e30fc0ef          	jal	80000b4e <kalloc>
    80004522:	892a                	mv	s2,a0
    80004524:	c12d                	beqz	a0,80004586 <pipealloc+0x94>
    80004526:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004528:	4985                	li	s3,1
    8000452a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000452e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004532:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004536:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000453a:	00003597          	auipc	a1,0x3
    8000453e:	07e58593          	addi	a1,a1,126 # 800075b8 <etext+0x5b8>
    80004542:	e66fc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004546:	609c                	ld	a5,0(s1)
    80004548:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000454c:	609c                	ld	a5,0(s1)
    8000454e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004552:	609c                	ld	a5,0(s1)
    80004554:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004558:	609c                	ld	a5,0(s1)
    8000455a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000455e:	000a3783          	ld	a5,0(s4)
    80004562:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004566:	000a3783          	ld	a5,0(s4)
    8000456a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000456e:	000a3783          	ld	a5,0(s4)
    80004572:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004576:	000a3783          	ld	a5,0(s4)
    8000457a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000457e:	4501                	li	a0,0
    80004580:	6942                	ld	s2,16(sp)
    80004582:	69a2                	ld	s3,8(sp)
    80004584:	a01d                	j	800045aa <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004586:	6088                	ld	a0,0(s1)
    80004588:	c119                	beqz	a0,8000458e <pipealloc+0x9c>
    8000458a:	6942                	ld	s2,16(sp)
    8000458c:	a029                	j	80004596 <pipealloc+0xa4>
    8000458e:	6942                	ld	s2,16(sp)
    80004590:	a029                	j	8000459a <pipealloc+0xa8>
    80004592:	6088                	ld	a0,0(s1)
    80004594:	c10d                	beqz	a0,800045b6 <pipealloc+0xc4>
    fileclose(*f0);
    80004596:	c1fff0ef          	jal	800041b4 <fileclose>
  if (*f1)
    8000459a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000459e:	557d                	li	a0,-1
  if (*f1)
    800045a0:	c789                	beqz	a5,800045aa <pipealloc+0xb8>
    fileclose(*f1);
    800045a2:	853e                	mv	a0,a5
    800045a4:	c11ff0ef          	jal	800041b4 <fileclose>
  return -1;
    800045a8:	557d                	li	a0,-1
}
    800045aa:	70a2                	ld	ra,40(sp)
    800045ac:	7402                	ld	s0,32(sp)
    800045ae:	64e2                	ld	s1,24(sp)
    800045b0:	6a02                	ld	s4,0(sp)
    800045b2:	6145                	addi	sp,sp,48
    800045b4:	8082                	ret
  return -1;
    800045b6:	557d                	li	a0,-1
    800045b8:	bfcd                	j	800045aa <pipealloc+0xb8>

00000000800045ba <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800045ba:	1101                	addi	sp,sp,-32
    800045bc:	ec06                	sd	ra,24(sp)
    800045be:	e822                	sd	s0,16(sp)
    800045c0:	e426                	sd	s1,8(sp)
    800045c2:	e04a                	sd	s2,0(sp)
    800045c4:	1000                	addi	s0,sp,32
    800045c6:	84aa                	mv	s1,a0
    800045c8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800045ca:	e5efc0ef          	jal	80000c28 <acquire>
  if (writable) {
    800045ce:	02090763          	beqz	s2,800045fc <pipeclose+0x42>
    pi->writeopen = 0;
    800045d2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800045d6:	21848513          	addi	a0,s1,536
    800045da:	a2bfd0ef          	jal	80002004 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    800045de:	2204a783          	lw	a5,544(s1)
    800045e2:	e781                	bnez	a5,800045ea <pipeclose+0x30>
    800045e4:	2244a783          	lw	a5,548(s1)
    800045e8:	c38d                	beqz	a5,8000460a <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    800045ea:	8526                	mv	a0,s1
    800045ec:	ec4fc0ef          	jal	80000cb0 <release>
}
    800045f0:	60e2                	ld	ra,24(sp)
    800045f2:	6442                	ld	s0,16(sp)
    800045f4:	64a2                	ld	s1,8(sp)
    800045f6:	6902                	ld	s2,0(sp)
    800045f8:	6105                	addi	sp,sp,32
    800045fa:	8082                	ret
    pi->readopen = 0;
    800045fc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004600:	21c48513          	addi	a0,s1,540
    80004604:	a01fd0ef          	jal	80002004 <wakeup>
    80004608:	bfd9                	j	800045de <pipeclose+0x24>
    release(&pi->lock);
    8000460a:	8526                	mv	a0,s1
    8000460c:	ea4fc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    80004610:	8526                	mv	a0,s1
    80004612:	c54fc0ef          	jal	80000a66 <kfree>
    80004616:	bfe9                	j	800045f0 <pipeclose+0x36>

0000000080004618 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004618:	7159                	addi	sp,sp,-112
    8000461a:	f486                	sd	ra,104(sp)
    8000461c:	f0a2                	sd	s0,96(sp)
    8000461e:	eca6                	sd	s1,88(sp)
    80004620:	e8ca                	sd	s2,80(sp)
    80004622:	e4ce                	sd	s3,72(sp)
    80004624:	e0d2                	sd	s4,64(sp)
    80004626:	fc56                	sd	s5,56(sp)
    80004628:	1880                	addi	s0,sp,112
    8000462a:	84aa                	mv	s1,a0
    8000462c:	8aae                	mv	s5,a1
    8000462e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004630:	b18fd0ef          	jal	80001948 <myproc>
    80004634:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004636:	8526                	mv	a0,s1
    80004638:	df0fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    8000463c:	0f405a63          	blez	s4,80004730 <pipewrite+0x118>
    80004640:	f85a                	sd	s6,48(sp)
    80004642:	f45e                	sd	s7,40(sp)
    80004644:	f062                	sd	s8,32(sp)
    80004646:	ec66                	sd	s9,24(sp)
    80004648:	e86a                	sd	s10,16(sp)
  int i = 0;
    8000464a:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    8000464c:	f9f40c13          	addi	s8,s0,-97
    80004650:	4b85                	li	s7,1
    80004652:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004654:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    80004658:	21c48c93          	addi	s9,s1,540
    8000465c:	a0a1                	j	800046a4 <pipewrite+0x8c>
      release(&pi->lock);
    8000465e:	8526                	mv	a0,s1
    80004660:	e50fc0ef          	jal	80000cb0 <release>
      return -1;
    80004664:	597d                	li	s2,-1
    80004666:	7b42                	ld	s6,48(sp)
    80004668:	7ba2                	ld	s7,40(sp)
    8000466a:	7c02                	ld	s8,32(sp)
    8000466c:	6ce2                	ld	s9,24(sp)
    8000466e:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004670:	854a                	mv	a0,s2
    80004672:	70a6                	ld	ra,104(sp)
    80004674:	7406                	ld	s0,96(sp)
    80004676:	64e6                	ld	s1,88(sp)
    80004678:	6946                	ld	s2,80(sp)
    8000467a:	69a6                	ld	s3,72(sp)
    8000467c:	6a06                	ld	s4,64(sp)
    8000467e:	7ae2                	ld	s5,56(sp)
    80004680:	6165                	addi	sp,sp,112
    80004682:	8082                	ret
      wakeup(&pi->nread);
    80004684:	856a                	mv	a0,s10
    80004686:	97ffd0ef          	jal	80002004 <wakeup>
      sleep_prepare(&pi->nwrite);
    8000468a:	8566                	mv	a0,s9
    8000468c:	90dfd0ef          	jal	80001f98 <sleep_prepare>
      release(&pi->lock);
    80004690:	8526                	mv	a0,s1
    80004692:	e1efc0ef          	jal	80000cb0 <release>
      sleep();
    80004696:	93ffd0ef          	jal	80001fd4 <sleep>
      acquire(&pi->lock);
    8000469a:	8526                	mv	a0,s1
    8000469c:	d8cfc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    800046a0:	07495b63          	bge	s2,s4,80004716 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    800046a4:	2204a783          	lw	a5,544(s1)
    800046a8:	dbdd                	beqz	a5,8000465e <pipewrite+0x46>
    800046aa:	854e                	mv	a0,s3
    800046ac:	b4bfd0ef          	jal	800021f6 <killed>
    800046b0:	f55d                	bnez	a0,8000465e <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    800046b2:	2184a783          	lw	a5,536(s1)
    800046b6:	21c4a703          	lw	a4,540(s1)
    800046ba:	2007879b          	addiw	a5,a5,512
    800046be:	fcf703e3          	beq	a4,a5,80004684 <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800046c2:	875e                	mv	a4,s7
    800046c4:	015906b3          	add	a3,s2,s5
    800046c8:	8662                	mv	a2,s8
    800046ca:	0489b583          	ld	a1,72(s3)
    800046ce:	0509b503          	ld	a0,80(s3)
    800046d2:	f77fc0ef          	jal	80001648 <copyin>
    800046d6:	03650163          	beq	a0,s6,800046f8 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800046da:	21c4a783          	lw	a5,540(s1)
    800046de:	0017871b          	addiw	a4,a5,1
    800046e2:	20e4ae23          	sw	a4,540(s1)
    800046e6:	1ff7f793          	andi	a5,a5,511
    800046ea:	97a6                	add	a5,a5,s1
    800046ec:	f9f44703          	lbu	a4,-97(s0)
    800046f0:	00e78c23          	sb	a4,24(a5)
      i++;
    800046f4:	2905                	addiw	s2,s2,1
    800046f6:	b76d                	j	800046a0 <pipewrite+0x88>
        if (i == 0)
    800046f8:	00090863          	beqz	s2,80004708 <pipewrite+0xf0>
    800046fc:	7b42                	ld	s6,48(sp)
    800046fe:	7ba2                	ld	s7,40(sp)
    80004700:	7c02                	ld	s8,32(sp)
    80004702:	6ce2                	ld	s9,24(sp)
    80004704:	6d42                	ld	s10,16(sp)
    80004706:	a829                	j	80004720 <pipewrite+0x108>
          i = -1;
    80004708:	892a                	mv	s2,a0
        break;
    8000470a:	7b42                	ld	s6,48(sp)
    8000470c:	7ba2                	ld	s7,40(sp)
    8000470e:	7c02                	ld	s8,32(sp)
    80004710:	6ce2                	ld	s9,24(sp)
    80004712:	6d42                	ld	s10,16(sp)
    80004714:	a031                	j	80004720 <pipewrite+0x108>
    80004716:	7b42                	ld	s6,48(sp)
    80004718:	7ba2                	ld	s7,40(sp)
    8000471a:	7c02                	ld	s8,32(sp)
    8000471c:	6ce2                	ld	s9,24(sp)
    8000471e:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004720:	21848513          	addi	a0,s1,536
    80004724:	8e1fd0ef          	jal	80002004 <wakeup>
  release(&pi->lock);
    80004728:	8526                	mv	a0,s1
    8000472a:	d86fc0ef          	jal	80000cb0 <release>
  return i;
    8000472e:	b789                	j	80004670 <pipewrite+0x58>
  int i = 0;
    80004730:	4901                	li	s2,0
    80004732:	b7fd                	j	80004720 <pipewrite+0x108>

0000000080004734 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004734:	711d                	addi	sp,sp,-96
    80004736:	ec86                	sd	ra,88(sp)
    80004738:	e8a2                	sd	s0,80(sp)
    8000473a:	e4a6                	sd	s1,72(sp)
    8000473c:	e0ca                	sd	s2,64(sp)
    8000473e:	fc4e                	sd	s3,56(sp)
    80004740:	f852                	sd	s4,48(sp)
    80004742:	f456                	sd	s5,40(sp)
    80004744:	1080                	addi	s0,sp,96
    80004746:	84aa                	mv	s1,a0
    80004748:	89ae                	mv	s3,a1
    8000474a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000474c:	9fcfd0ef          	jal	80001948 <myproc>
    80004750:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    80004752:	8526                	mv	a0,s1
    80004754:	cd4fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004758:	0d505263          	blez	s5,8000481c <piperead+0xe8>
    8000475c:	2184a703          	lw	a4,536(s1)
    80004760:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004764:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004768:	02f71e63          	bne	a4,a5,800047a4 <piperead+0x70>
    8000476c:	2244a783          	lw	a5,548(s1)
    80004770:	c3b9                	beqz	a5,800047b6 <piperead+0x82>
    if (killed(pr)) {
    80004772:	854a                	mv	a0,s2
    80004774:	a83fd0ef          	jal	800021f6 <killed>
    80004778:	e915                	bnez	a0,800047ac <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    8000477a:	8552                	mv	a0,s4
    8000477c:	81dfd0ef          	jal	80001f98 <sleep_prepare>
    release(&pi->lock);
    80004780:	8526                	mv	a0,s1
    80004782:	d2efc0ef          	jal	80000cb0 <release>
    sleep();
    80004786:	84ffd0ef          	jal	80001fd4 <sleep>
    acquire(&pi->lock);
    8000478a:	8526                	mv	a0,s1
    8000478c:	c9cfc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004790:	2184a703          	lw	a4,536(s1)
    80004794:	21c4a783          	lw	a5,540(s1)
    80004798:	fcf70ae3          	beq	a4,a5,8000476c <piperead+0x38>
    8000479c:	f05a                	sd	s6,32(sp)
    8000479e:	ec5e                	sd	s7,24(sp)
    800047a0:	e862                	sd	s8,16(sp)
    800047a2:	a829                	j	800047bc <piperead+0x88>
    800047a4:	f05a                	sd	s6,32(sp)
    800047a6:	ec5e                	sd	s7,24(sp)
    800047a8:	e862                	sd	s8,16(sp)
    800047aa:	a809                	j	800047bc <piperead+0x88>
      release(&pi->lock);
    800047ac:	8526                	mv	a0,s1
    800047ae:	d02fc0ef          	jal	80000cb0 <release>
      return -1;
    800047b2:	5a7d                	li	s4,-1
    800047b4:	a8a5                	j	8000482c <piperead+0xf8>
    800047b6:	f05a                	sd	s6,32(sp)
    800047b8:	ec5e                	sd	s7,24(sp)
    800047ba:	e862                	sd	s8,16(sp)
{
    800047bc:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    800047be:	faf40c13          	addi	s8,s0,-81
    800047c2:	4b85                	li	s7,1
    800047c4:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    800047c6:	2184a783          	lw	a5,536(s1)
    800047ca:	21c4a703          	lw	a4,540(s1)
    800047ce:	06f70e63          	beq	a4,a5,8000484a <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    800047d2:	1ff7f793          	andi	a5,a5,511
    800047d6:	97a6                	add	a5,a5,s1
    800047d8:	0187c783          	lbu	a5,24(a5)
    800047dc:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    800047e0:	875e                	mv	a4,s7
    800047e2:	86e2                	mv	a3,s8
    800047e4:	864e                	mv	a2,s3
    800047e6:	04893583          	ld	a1,72(s2)
    800047ea:	05093503          	ld	a0,80(s2)
    800047ee:	d95fc0ef          	jal	80001582 <copyout>
    800047f2:	01650f63          	beq	a0,s6,80004810 <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800047f6:	2184a783          	lw	a5,536(s1)
    800047fa:	2785                	addiw	a5,a5,1
    800047fc:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004800:	2a05                	addiw	s4,s4,1
    80004802:	0985                	addi	s3,s3,1
    80004804:	fd4a91e3          	bne	s5,s4,800047c6 <piperead+0x92>
    80004808:	7b02                	ld	s6,32(sp)
    8000480a:	6be2                	ld	s7,24(sp)
    8000480c:	6c42                	ld	s8,16(sp)
    8000480e:	a801                	j	8000481e <piperead+0xea>
      if (i == 0)
    80004810:	020a0863          	beqz	s4,80004840 <piperead+0x10c>
    80004814:	7b02                	ld	s6,32(sp)
    80004816:	6be2                	ld	s7,24(sp)
    80004818:	6c42                	ld	s8,16(sp)
    8000481a:	a011                	j	8000481e <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000481c:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    8000481e:	21c48513          	addi	a0,s1,540
    80004822:	fe2fd0ef          	jal	80002004 <wakeup>
  release(&pi->lock);
    80004826:	8526                	mv	a0,s1
    80004828:	c88fc0ef          	jal	80000cb0 <release>
  return i;
}
    8000482c:	8552                	mv	a0,s4
    8000482e:	60e6                	ld	ra,88(sp)
    80004830:	6446                	ld	s0,80(sp)
    80004832:	64a6                	ld	s1,72(sp)
    80004834:	6906                	ld	s2,64(sp)
    80004836:	79e2                	ld	s3,56(sp)
    80004838:	7a42                	ld	s4,48(sp)
    8000483a:	7aa2                	ld	s5,40(sp)
    8000483c:	6125                	addi	sp,sp,96
    8000483e:	8082                	ret
        i = -1;
    80004840:	8a2a                	mv	s4,a0
    80004842:	7b02                	ld	s6,32(sp)
    80004844:	6be2                	ld	s7,24(sp)
    80004846:	6c42                	ld	s8,16(sp)
    80004848:	bfd9                	j	8000481e <piperead+0xea>
    8000484a:	7b02                	ld	s6,32(sp)
    8000484c:	6be2                	ld	s7,24(sp)
    8000484e:	6c42                	ld	s8,16(sp)
    80004850:	b7f9                	j	8000481e <piperead+0xea>

0000000080004852 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004852:	1141                	addi	sp,sp,-16
    80004854:	e406                	sd	ra,8(sp)
    80004856:	e022                	sd	s0,0(sp)
    80004858:	0800                	addi	s0,sp,16
    8000485a:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    8000485c:	0035151b          	slliw	a0,a0,0x3
    80004860:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    80004862:	8b89                	andi	a5,a5,2
    80004864:	c399                	beqz	a5,8000486a <flags2perm+0x18>
    perm |= PTE_W;
    80004866:	00456513          	ori	a0,a0,4
  return perm;
}
    8000486a:	60a2                	ld	ra,8(sp)
    8000486c:	6402                	ld	s0,0(sp)
    8000486e:	0141                	addi	sp,sp,16
    80004870:	8082                	ret

0000000080004872 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004872:	de010113          	addi	sp,sp,-544
    80004876:	20113c23          	sd	ra,536(sp)
    8000487a:	20813823          	sd	s0,528(sp)
    8000487e:	20913423          	sd	s1,520(sp)
    80004882:	21213023          	sd	s2,512(sp)
    80004886:	1400                	addi	s0,sp,544
    80004888:	892a                	mv	s2,a0
    8000488a:	dea43823          	sd	a0,-528(s0)
    8000488e:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004892:	8b6fd0ef          	jal	80001948 <myproc>
    80004896:	84aa                	mv	s1,a0

  begin_op();
    80004898:	c62ff0ef          	jal	80003cfa <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    8000489c:	854a                	mv	a0,s2
    8000489e:	a7eff0ef          	jal	80003b1c <namei>
    800048a2:	cd21                	beqz	a0,800048fa <kexec+0x88>
    800048a4:	fbd2                	sd	s4,496(sp)
    800048a6:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800048a8:	9dbfe0ef          	jal	80003282 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800048ac:	04000713          	li	a4,64
    800048b0:	4681                	li	a3,0
    800048b2:	e5040613          	addi	a2,s0,-432
    800048b6:	4581                	li	a1,0
    800048b8:	8552                	mv	a0,s4
    800048ba:	da3fe0ef          	jal	8000365c <readi>
    800048be:	04000793          	li	a5,64
    800048c2:	00f51a63          	bne	a0,a5,800048d6 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    800048c6:	e5042703          	lw	a4,-432(s0)
    800048ca:	464c47b7          	lui	a5,0x464c4
    800048ce:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800048d2:	02f70863          	beq	a4,a5,80004902 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    800048d6:	8552                	mv	a0,s4
    800048d8:	bfffe0ef          	jal	800034d6 <iunlockput>
    end_op();
    800048dc:	caaff0ef          	jal	80003d86 <end_op>
  }
  return -1;
    800048e0:	557d                	li	a0,-1
    800048e2:	7a5e                	ld	s4,496(sp)
}
    800048e4:	21813083          	ld	ra,536(sp)
    800048e8:	21013403          	ld	s0,528(sp)
    800048ec:	20813483          	ld	s1,520(sp)
    800048f0:	20013903          	ld	s2,512(sp)
    800048f4:	22010113          	addi	sp,sp,544
    800048f8:	8082                	ret
    end_op();
    800048fa:	c8cff0ef          	jal	80003d86 <end_op>
    return -1;
    800048fe:	557d                	li	a0,-1
    80004900:	b7d5                	j	800048e4 <kexec+0x72>
    80004902:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004904:	8526                	mv	a0,s1
    80004906:	948fd0ef          	jal	80001a4e <proc_pagetable>
    8000490a:	8b2a                	mv	s6,a0
    8000490c:	26050e63          	beqz	a0,80004b88 <kexec+0x316>
    80004910:	ffce                	sd	s3,504(sp)
    80004912:	f7d6                	sd	s5,488(sp)
    80004914:	efde                	sd	s7,472(sp)
    80004916:	ebe2                	sd	s8,464(sp)
    80004918:	e7e6                	sd	s9,456(sp)
    8000491a:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    8000491c:	e8845783          	lhu	a5,-376(s0)
    80004920:	14078263          	beqz	a5,80004a64 <kexec+0x1f2>
    80004924:	ff6e                	sd	s11,440(sp)
    80004926:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000492a:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    8000492c:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000492e:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004932:	6c85                	lui	s9,0x1
    80004934:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004938:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    8000493c:	6a85                	lui	s5,0x1
    8000493e:	a085                	j	8000499e <kexec+0x12c>
      panic("loadseg: address should exist");
    80004940:	00003517          	auipc	a0,0x3
    80004944:	c8050513          	addi	a0,a0,-896 # 800075c0 <etext+0x5c0>
    80004948:	eedfb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    8000494c:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    8000494e:	874a                	mv	a4,s2
    80004950:	009b86bb          	addw	a3,s7,s1
    80004954:	4581                	li	a1,0
    80004956:	8552                	mv	a0,s4
    80004958:	d05fe0ef          	jal	8000365c <readi>
    8000495c:	22a91a63          	bne	s2,a0,80004b90 <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004960:	009a84bb          	addw	s1,s5,s1
    80004964:	0334f263          	bgeu	s1,s3,80004988 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004968:	02049593          	slli	a1,s1,0x20
    8000496c:	9181                	srli	a1,a1,0x20
    8000496e:	95e2                	add	a1,a1,s8
    80004970:	855a                	mv	a0,s6
    80004972:	ea6fc0ef          	jal	80001018 <walkaddr>
    80004976:	862a                	mv	a2,a0
    if (pa == 0)
    80004978:	d561                	beqz	a0,80004940 <kexec+0xce>
    if (sz - i < PGSIZE)
    8000497a:	409987bb          	subw	a5,s3,s1
    8000497e:	893e                	mv	s2,a5
    80004980:	fcfcf6e3          	bgeu	s9,a5,8000494c <kexec+0xda>
    80004984:	8956                	mv	s2,s5
    80004986:	b7d9                	j	8000494c <kexec+0xda>
    sz = sz1;
    80004988:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    8000498c:	2d05                	addiw	s10,s10,1
    8000498e:	e0843783          	ld	a5,-504(s0)
    80004992:	0387869b          	addiw	a3,a5,56
    80004996:	e8845783          	lhu	a5,-376(s0)
    8000499a:	06fd5d63          	bge	s10,a5,80004a14 <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000499e:	e0d43423          	sd	a3,-504(s0)
    800049a2:	876e                	mv	a4,s11
    800049a4:	e1840613          	addi	a2,s0,-488
    800049a8:	4581                	li	a1,0
    800049aa:	8552                	mv	a0,s4
    800049ac:	cb1fe0ef          	jal	8000365c <readi>
    800049b0:	1db51e63          	bne	a0,s11,80004b8c <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    800049b4:	e1842783          	lw	a5,-488(s0)
    800049b8:	4705                	li	a4,1
    800049ba:	fce799e3          	bne	a5,a4,8000498c <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    800049be:	e4043483          	ld	s1,-448(s0)
    800049c2:	e3843783          	ld	a5,-456(s0)
    800049c6:	1ef4e363          	bltu	s1,a5,80004bac <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    800049ca:	e2843783          	ld	a5,-472(s0)
    800049ce:	94be                	add	s1,s1,a5
    800049d0:	1ef4e163          	bltu	s1,a5,80004bb2 <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    800049d4:	de843703          	ld	a4,-536(s0)
    800049d8:	8ff9                	and	a5,a5,a4
    800049da:	1c079f63          	bnez	a5,80004bb8 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    800049de:	e1c42503          	lw	a0,-484(s0)
    800049e2:	e71ff0ef          	jal	80004852 <flags2perm>
    800049e6:	86aa                	mv	a3,a0
    800049e8:	8626                	mv	a2,s1
    800049ea:	85ca                	mv	a1,s2
    800049ec:	855a                	mv	a0,s6
    800049ee:	901fc0ef          	jal	800012ee <uvmalloc>
    800049f2:	dea43c23          	sd	a0,-520(s0)
    800049f6:	1c050463          	beqz	a0,80004bbe <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800049fa:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    800049fe:	00098863          	beqz	s3,80004a0e <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a02:	e2843c03          	ld	s8,-472(s0)
    80004a06:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004a0a:	4481                	li	s1,0
    80004a0c:	bfb1                	j	80004968 <kexec+0xf6>
    sz = sz1;
    80004a0e:	df843903          	ld	s2,-520(s0)
    80004a12:	bfad                	j	8000498c <kexec+0x11a>
    80004a14:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004a16:	8552                	mv	a0,s4
    80004a18:	abffe0ef          	jal	800034d6 <iunlockput>
  end_op();
    80004a1c:	b6aff0ef          	jal	80003d86 <end_op>
  p = myproc();
    80004a20:	f29fc0ef          	jal	80001948 <myproc>
    80004a24:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004a26:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004a2a:	6c05                	lui	s8,0x1
    80004a2c:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004a2e:	9c4a                	add	s8,s8,s2
    80004a30:	77fd                	lui	a5,0xfffff
    80004a32:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004a36:	4691                	li	a3,4
    80004a38:	6609                	lui	a2,0x2
    80004a3a:	9662                	add	a2,a2,s8
    80004a3c:	85e2                	mv	a1,s8
    80004a3e:	855a                	mv	a0,s6
    80004a40:	8affc0ef          	jal	800012ee <uvmalloc>
    80004a44:	892a                	mv	s2,a0
    80004a46:	e10d                	bnez	a0,80004a68 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004a48:	85e2                	mv	a1,s8
    80004a4a:	855a                	mv	a0,s6
    80004a4c:	886fd0ef          	jal	80001ad2 <proc_freepagetable>
  return -1;
    80004a50:	557d                	li	a0,-1
    80004a52:	79fe                	ld	s3,504(sp)
    80004a54:	7a5e                	ld	s4,496(sp)
    80004a56:	7abe                	ld	s5,488(sp)
    80004a58:	7b1e                	ld	s6,480(sp)
    80004a5a:	6bfe                	ld	s7,472(sp)
    80004a5c:	6c5e                	ld	s8,464(sp)
    80004a5e:	6cbe                	ld	s9,456(sp)
    80004a60:	6d1e                	ld	s10,448(sp)
    80004a62:	b549                	j	800048e4 <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a64:	4901                	li	s2,0
    80004a66:	bf45                	j	80004a16 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004a68:	75f9                	lui	a1,0xffffe
    80004a6a:	95aa                	add	a1,a1,a0
    80004a6c:	855a                	mv	a0,s6
    80004a6e:	a53fc0ef          	jal	800014c0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004a72:	80090a13          	addi	s4,s2,-2048
    80004a76:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004a7a:	e0043783          	ld	a5,-512(s0)
    80004a7e:	6388                	ld	a0,0(a5)
    80004a80:	c545                	beqz	a0,80004b28 <kexec+0x2b6>
  sp = sz;
    80004a82:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004a84:	4481                	li	s1,0
    ustack[argc] = sp;
    80004a86:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004a8a:	be8fc0ef          	jal	80000e72 <strlen>
    80004a8e:	0015079b          	addiw	a5,a0,1
    80004a92:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004a96:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004a9a:	134c6563          	bltu	s8,s4,80004bc4 <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004a9e:	e0043d03          	ld	s10,-512(s0)
    80004aa2:	000d3c83          	ld	s9,0(s10)
    80004aa6:	8566                	mv	a0,s9
    80004aa8:	bcafc0ef          	jal	80000e72 <strlen>
    80004aac:	0015071b          	addiw	a4,a0,1
    80004ab0:	86e6                	mv	a3,s9
    80004ab2:	8662                	mv	a2,s8
    80004ab4:	85ca                	mv	a1,s2
    80004ab6:	855a                	mv	a0,s6
    80004ab8:	acbfc0ef          	jal	80001582 <copyout>
    80004abc:	10054663          	bltz	a0,80004bc8 <kexec+0x356>
    ustack[argc] = sp;
    80004ac0:	00349793          	slli	a5,s1,0x3
    80004ac4:	97de                	add	a5,a5,s7
    80004ac6:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb808>
  for (argc = 0; argv[argc]; argc++) {
    80004aca:	0485                	addi	s1,s1,1
    80004acc:	008d0793          	addi	a5,s10,8
    80004ad0:	e0f43023          	sd	a5,-512(s0)
    80004ad4:	008d3503          	ld	a0,8(s10)
    80004ad8:	f94d                	bnez	a0,80004a8a <kexec+0x218>
  ustack[argc] = 0;
    80004ada:	00349793          	slli	a5,s1,0x3
    80004ade:	f9078793          	addi	a5,a5,-112
    80004ae2:	97a2                	add	a5,a5,s0
    80004ae4:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004ae8:	00349713          	slli	a4,s1,0x3
    80004aec:	0721                	addi	a4,a4,8
    80004aee:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004af2:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004af6:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004af8:	f54be8e3          	bltu	s7,s4,80004a48 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004afc:	e9040693          	addi	a3,s0,-368
    80004b00:	865e                	mv	a2,s7
    80004b02:	85ca                	mv	a1,s2
    80004b04:	855a                	mv	a0,s6
    80004b06:	a7dfc0ef          	jal	80001582 <copyout>
    80004b0a:	f2054fe3          	bltz	a0,80004a48 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004b0e:	0589b783          	ld	a5,88(s3)
    80004b12:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004b16:	df043783          	ld	a5,-528(s0)
    80004b1a:	0007c703          	lbu	a4,0(a5)
    80004b1e:	c30d                	beqz	a4,80004b40 <kexec+0x2ce>
    80004b20:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004b22:	02f00693          	li	a3,47
    80004b26:	a801                	j	80004b36 <kexec+0x2c4>
  sp = sz;
    80004b28:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004b2a:	4481                	li	s1,0
    80004b2c:	b77d                	j	80004ada <kexec+0x268>
  for (last = s = path; *s; s++)
    80004b2e:	0785                	addi	a5,a5,1
    80004b30:	fff7c703          	lbu	a4,-1(a5)
    80004b34:	c711                	beqz	a4,80004b40 <kexec+0x2ce>
    if (*s == '/')
    80004b36:	fed71ce3          	bne	a4,a3,80004b2e <kexec+0x2bc>
      last = s + 1;
    80004b3a:	def43823          	sd	a5,-528(s0)
    80004b3e:	bfc5                	j	80004b2e <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004b40:	4641                	li	a2,16
    80004b42:	df043583          	ld	a1,-528(s0)
    80004b46:	15898513          	addi	a0,s3,344
    80004b4a:	af2fc0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004b4e:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004b52:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004b56:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004b5a:	0589b783          	ld	a5,88(s3)
    80004b5e:	e6843703          	ld	a4,-408(s0)
    80004b62:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004b64:	0589b783          	ld	a5,88(s3)
    80004b68:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004b6c:	85d6                	mv	a1,s5
    80004b6e:	f65fc0ef          	jal	80001ad2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004b72:	0004851b          	sext.w	a0,s1
    80004b76:	79fe                	ld	s3,504(sp)
    80004b78:	7a5e                	ld	s4,496(sp)
    80004b7a:	7abe                	ld	s5,488(sp)
    80004b7c:	7b1e                	ld	s6,480(sp)
    80004b7e:	6bfe                	ld	s7,472(sp)
    80004b80:	6c5e                	ld	s8,464(sp)
    80004b82:	6cbe                	ld	s9,456(sp)
    80004b84:	6d1e                	ld	s10,448(sp)
    80004b86:	bbb9                	j	800048e4 <kexec+0x72>
    80004b88:	7b1e                	ld	s6,480(sp)
    80004b8a:	b3b1                	j	800048d6 <kexec+0x64>
    80004b8c:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004b90:	df843583          	ld	a1,-520(s0)
    80004b94:	855a                	mv	a0,s6
    80004b96:	f3dfc0ef          	jal	80001ad2 <proc_freepagetable>
  if (ip) {
    80004b9a:	79fe                	ld	s3,504(sp)
    80004b9c:	7abe                	ld	s5,488(sp)
    80004b9e:	7b1e                	ld	s6,480(sp)
    80004ba0:	6bfe                	ld	s7,472(sp)
    80004ba2:	6c5e                	ld	s8,464(sp)
    80004ba4:	6cbe                	ld	s9,456(sp)
    80004ba6:	6d1e                	ld	s10,448(sp)
    80004ba8:	7dfa                	ld	s11,440(sp)
    80004baa:	b335                	j	800048d6 <kexec+0x64>
    80004bac:	df243c23          	sd	s2,-520(s0)
    80004bb0:	b7c5                	j	80004b90 <kexec+0x31e>
    80004bb2:	df243c23          	sd	s2,-520(s0)
    80004bb6:	bfe9                	j	80004b90 <kexec+0x31e>
    80004bb8:	df243c23          	sd	s2,-520(s0)
    80004bbc:	bfd1                	j	80004b90 <kexec+0x31e>
    80004bbe:	df243c23          	sd	s2,-520(s0)
    80004bc2:	b7f9                	j	80004b90 <kexec+0x31e>
  sz = sz1;
    80004bc4:	8c4a                	mv	s8,s2
    80004bc6:	b549                	j	80004a48 <kexec+0x1d6>
    80004bc8:	8c4a                	mv	s8,s2
    80004bca:	bdbd                	j	80004a48 <kexec+0x1d6>

0000000080004bcc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004bcc:	7179                	addi	sp,sp,-48
    80004bce:	f406                	sd	ra,40(sp)
    80004bd0:	f022                	sd	s0,32(sp)
    80004bd2:	ec26                	sd	s1,24(sp)
    80004bd4:	e84a                	sd	s2,16(sp)
    80004bd6:	1800                	addi	s0,sp,48
    80004bd8:	892e                	mv	s2,a1
    80004bda:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004bdc:	fdc40593          	addi	a1,s0,-36
    80004be0:	cc9fd0ef          	jal	800028a8 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004be4:	fdc42703          	lw	a4,-36(s0)
    80004be8:	47bd                	li	a5,15
    80004bea:	02e7ea63          	bltu	a5,a4,80004c1e <argfd+0x52>
    80004bee:	d5bfc0ef          	jal	80001948 <myproc>
    80004bf2:	fdc42703          	lw	a4,-36(s0)
    80004bf6:	00371793          	slli	a5,a4,0x3
    80004bfa:	0d078793          	addi	a5,a5,208
    80004bfe:	953e                	add	a0,a0,a5
    80004c00:	611c                	ld	a5,0(a0)
    80004c02:	c385                	beqz	a5,80004c22 <argfd+0x56>
    return -1;
  if (pfd)
    80004c04:	00090463          	beqz	s2,80004c0c <argfd+0x40>
    *pfd = fd;
    80004c08:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004c0c:	4501                	li	a0,0
  if (pf)
    80004c0e:	c091                	beqz	s1,80004c12 <argfd+0x46>
    *pf = f;
    80004c10:	e09c                	sd	a5,0(s1)
}
    80004c12:	70a2                	ld	ra,40(sp)
    80004c14:	7402                	ld	s0,32(sp)
    80004c16:	64e2                	ld	s1,24(sp)
    80004c18:	6942                	ld	s2,16(sp)
    80004c1a:	6145                	addi	sp,sp,48
    80004c1c:	8082                	ret
    return -1;
    80004c1e:	557d                	li	a0,-1
    80004c20:	bfcd                	j	80004c12 <argfd+0x46>
    80004c22:	557d                	li	a0,-1
    80004c24:	b7fd                	j	80004c12 <argfd+0x46>

0000000080004c26 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c26:	1101                	addi	sp,sp,-32
    80004c28:	ec06                	sd	ra,24(sp)
    80004c2a:	e822                	sd	s0,16(sp)
    80004c2c:	e426                	sd	s1,8(sp)
    80004c2e:	1000                	addi	s0,sp,32
    80004c30:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004c32:	d17fc0ef          	jal	80001948 <myproc>
    80004c36:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004c38:	0d050793          	addi	a5,a0,208
    80004c3c:	4501                	li	a0,0
    80004c3e:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004c40:	6398                	ld	a4,0(a5)
    80004c42:	cb19                	beqz	a4,80004c58 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004c44:	2505                	addiw	a0,a0,1
    80004c46:	07a1                	addi	a5,a5,8
    80004c48:	fed51ce3          	bne	a0,a3,80004c40 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004c4c:	557d                	li	a0,-1
}
    80004c4e:	60e2                	ld	ra,24(sp)
    80004c50:	6442                	ld	s0,16(sp)
    80004c52:	64a2                	ld	s1,8(sp)
    80004c54:	6105                	addi	sp,sp,32
    80004c56:	8082                	ret
      p->ofile[fd] = f;
    80004c58:	00351793          	slli	a5,a0,0x3
    80004c5c:	0d078793          	addi	a5,a5,208
    80004c60:	963e                	add	a2,a2,a5
    80004c62:	e204                	sd	s1,0(a2)
      return fd;
    80004c64:	b7ed                	j	80004c4e <fdalloc+0x28>

0000000080004c66 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004c66:	715d                	addi	sp,sp,-80
    80004c68:	e486                	sd	ra,72(sp)
    80004c6a:	e0a2                	sd	s0,64(sp)
    80004c6c:	fc26                	sd	s1,56(sp)
    80004c6e:	f84a                	sd	s2,48(sp)
    80004c70:	f052                	sd	s4,32(sp)
    80004c72:	ec56                	sd	s5,24(sp)
    80004c74:	e85a                	sd	s6,16(sp)
    80004c76:	0880                	addi	s0,sp,80
    80004c78:	8a2e                	mv	s4,a1
    80004c7a:	8ab2                	mv	s5,a2
    80004c7c:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004c7e:	fb040593          	addi	a1,s0,-80
    80004c82:	eb5fe0ef          	jal	80003b36 <nameiparent>
    80004c86:	84aa                	mv	s1,a0
    80004c88:	12050f63          	beqz	a0,80004dc6 <create+0x160>
    return 0;

  ilock(dp);
    80004c8c:	df6fe0ef          	jal	80003282 <ilock>

  if (dp->nlink == 0) {
    80004c90:	04a49783          	lh	a5,74(s1)
    80004c94:	cbb9                	beqz	a5,80004cea <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004c96:	7761                	lui	a4,0xffff8
    80004c98:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd4809>
    80004c9a:	97ba                	add	a5,a5,a4
    80004c9c:	e781                	bnez	a5,80004ca4 <create+0x3e>
    80004c9e:	fffa0793          	addi	a5,s4,-1
    80004ca2:	cba9                	beqz	a5,80004cf4 <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004ca4:	4601                	li	a2,0
    80004ca6:	fb040593          	addi	a1,s0,-80
    80004caa:	8526                	mv	a0,s1
    80004cac:	bbffe0ef          	jal	8000386a <dirlookup>
    80004cb0:	892a                	mv	s2,a0
    80004cb2:	c939                	beqz	a0,80004d08 <create+0xa2>
    iunlockput(dp);
    80004cb4:	8526                	mv	a0,s1
    80004cb6:	821fe0ef          	jal	800034d6 <iunlockput>
    ilock(ip);
    80004cba:	854a                	mv	a0,s2
    80004cbc:	dc6fe0ef          	jal	80003282 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004cc0:	4789                	li	a5,2
    80004cc2:	02fa1e63          	bne	s4,a5,80004cfe <create+0x98>
    80004cc6:	04495783          	lhu	a5,68(s2)
    80004cca:	37f9                	addiw	a5,a5,-2
    80004ccc:	17c2                	slli	a5,a5,0x30
    80004cce:	93c1                	srli	a5,a5,0x30
    80004cd0:	4705                	li	a4,1
    80004cd2:	02f76663          	bltu	a4,a5,80004cfe <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004cd6:	854a                	mv	a0,s2
    80004cd8:	60a6                	ld	ra,72(sp)
    80004cda:	6406                	ld	s0,64(sp)
    80004cdc:	74e2                	ld	s1,56(sp)
    80004cde:	7942                	ld	s2,48(sp)
    80004ce0:	7a02                	ld	s4,32(sp)
    80004ce2:	6ae2                	ld	s5,24(sp)
    80004ce4:	6b42                	ld	s6,16(sp)
    80004ce6:	6161                	addi	sp,sp,80
    80004ce8:	8082                	ret
    iunlockput(dp);
    80004cea:	8526                	mv	a0,s1
    80004cec:	feafe0ef          	jal	800034d6 <iunlockput>
    return 0;
    80004cf0:	4901                	li	s2,0
    80004cf2:	b7d5                	j	80004cd6 <create+0x70>
    iunlockput(dp);
    80004cf4:	8526                	mv	a0,s1
    80004cf6:	fe0fe0ef          	jal	800034d6 <iunlockput>
    return 0;
    80004cfa:	4901                	li	s2,0
    80004cfc:	bfe9                	j	80004cd6 <create+0x70>
    iunlockput(ip);
    80004cfe:	854a                	mv	a0,s2
    80004d00:	fd6fe0ef          	jal	800034d6 <iunlockput>
    return 0;
    80004d04:	4901                	li	s2,0
    80004d06:	bfc1                	j	80004cd6 <create+0x70>
    80004d08:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004d0a:	85d2                	mv	a1,s4
    80004d0c:	4088                	lw	a0,0(s1)
    80004d0e:	c04fe0ef          	jal	80003112 <ialloc>
    80004d12:	89aa                	mv	s3,a0
    80004d14:	cd1d                	beqz	a0,80004d52 <create+0xec>
  ilock(ip);
    80004d16:	d6cfe0ef          	jal	80003282 <ilock>
  ip->major = major;
    80004d1a:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004d1e:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004d22:	4705                	li	a4,1
    80004d24:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004d28:	854e                	mv	a0,s3
    80004d2a:	ca4fe0ef          	jal	800031ce <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004d2e:	4705                	li	a4,1
    80004d30:	02ea0763          	beq	s4,a4,80004d5e <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004d34:	0049a603          	lw	a2,4(s3)
    80004d38:	fb040593          	addi	a1,s0,-80
    80004d3c:	8526                	mv	a0,s1
    80004d3e:	d35fe0ef          	jal	80003a72 <dirlink>
    80004d42:	06054563          	bltz	a0,80004dac <create+0x146>
  iunlockput(dp);
    80004d46:	8526                	mv	a0,s1
    80004d48:	f8efe0ef          	jal	800034d6 <iunlockput>
  return ip;
    80004d4c:	894e                	mv	s2,s3
    80004d4e:	79a2                	ld	s3,40(sp)
    80004d50:	b759                	j	80004cd6 <create+0x70>
    iunlockput(dp);
    80004d52:	8526                	mv	a0,s1
    80004d54:	f82fe0ef          	jal	800034d6 <iunlockput>
    return 0;
    80004d58:	894e                	mv	s2,s3
    80004d5a:	79a2                	ld	s3,40(sp)
    80004d5c:	bfad                	j	80004cd6 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004d5e:	0049a603          	lw	a2,4(s3)
    80004d62:	00003597          	auipc	a1,0x3
    80004d66:	87e58593          	addi	a1,a1,-1922 # 800075e0 <etext+0x5e0>
    80004d6a:	854e                	mv	a0,s3
    80004d6c:	d07fe0ef          	jal	80003a72 <dirlink>
    80004d70:	02054e63          	bltz	a0,80004dac <create+0x146>
    80004d74:	40d0                	lw	a2,4(s1)
    80004d76:	00003597          	auipc	a1,0x3
    80004d7a:	87258593          	addi	a1,a1,-1934 # 800075e8 <etext+0x5e8>
    80004d7e:	854e                	mv	a0,s3
    80004d80:	cf3fe0ef          	jal	80003a72 <dirlink>
    80004d84:	02054463          	bltz	a0,80004dac <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004d88:	0049a603          	lw	a2,4(s3)
    80004d8c:	fb040593          	addi	a1,s0,-80
    80004d90:	8526                	mv	a0,s1
    80004d92:	ce1fe0ef          	jal	80003a72 <dirlink>
    80004d96:	00054b63          	bltz	a0,80004dac <create+0x146>
    dp->nlink++; // for ".."
    80004d9a:	04a4d783          	lhu	a5,74(s1)
    80004d9e:	2785                	addiw	a5,a5,1
    80004da0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004da4:	8526                	mv	a0,s1
    80004da6:	c28fe0ef          	jal	800031ce <iupdate>
    80004daa:	bf71                	j	80004d46 <create+0xe0>
  ip->nlink = 0;
    80004dac:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004db0:	854e                	mv	a0,s3
    80004db2:	c1cfe0ef          	jal	800031ce <iupdate>
  iunlockput(ip);
    80004db6:	854e                	mv	a0,s3
    80004db8:	f1efe0ef          	jal	800034d6 <iunlockput>
  iunlockput(dp);
    80004dbc:	8526                	mv	a0,s1
    80004dbe:	f18fe0ef          	jal	800034d6 <iunlockput>
  return 0;
    80004dc2:	79a2                	ld	s3,40(sp)
    80004dc4:	bf09                	j	80004cd6 <create+0x70>
    return 0;
    80004dc6:	892a                	mv	s2,a0
    80004dc8:	b739                	j	80004cd6 <create+0x70>

0000000080004dca <sys_dup>:
{
    80004dca:	7179                	addi	sp,sp,-48
    80004dcc:	f406                	sd	ra,40(sp)
    80004dce:	f022                	sd	s0,32(sp)
    80004dd0:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004dd2:	fd840613          	addi	a2,s0,-40
    80004dd6:	4581                	li	a1,0
    80004dd8:	4501                	li	a0,0
    80004dda:	df3ff0ef          	jal	80004bcc <argfd>
    return -1;
    80004dde:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004de0:	02054363          	bltz	a0,80004e06 <sys_dup+0x3c>
    80004de4:	ec26                	sd	s1,24(sp)
    80004de6:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004de8:	fd843483          	ld	s1,-40(s0)
    80004dec:	8526                	mv	a0,s1
    80004dee:	e39ff0ef          	jal	80004c26 <fdalloc>
    80004df2:	892a                	mv	s2,a0
    return -1;
    80004df4:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004df6:	00054d63          	bltz	a0,80004e10 <sys_dup+0x46>
  filedup(f);
    80004dfa:	8526                	mv	a0,s1
    80004dfc:	b72ff0ef          	jal	8000416e <filedup>
  return fd;
    80004e00:	87ca                	mv	a5,s2
    80004e02:	64e2                	ld	s1,24(sp)
    80004e04:	6942                	ld	s2,16(sp)
}
    80004e06:	853e                	mv	a0,a5
    80004e08:	70a2                	ld	ra,40(sp)
    80004e0a:	7402                	ld	s0,32(sp)
    80004e0c:	6145                	addi	sp,sp,48
    80004e0e:	8082                	ret
    80004e10:	64e2                	ld	s1,24(sp)
    80004e12:	6942                	ld	s2,16(sp)
    80004e14:	bfcd                	j	80004e06 <sys_dup+0x3c>

0000000080004e16 <sys_read>:
{
    80004e16:	7179                	addi	sp,sp,-48
    80004e18:	f406                	sd	ra,40(sp)
    80004e1a:	f022                	sd	s0,32(sp)
    80004e1c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e1e:	fd840593          	addi	a1,s0,-40
    80004e22:	4505                	li	a0,1
    80004e24:	aa1fd0ef          	jal	800028c4 <argaddr>
  argint(2, &n);
    80004e28:	fe440593          	addi	a1,s0,-28
    80004e2c:	4509                	li	a0,2
    80004e2e:	a7bfd0ef          	jal	800028a8 <argint>
  if (argfd(0, 0, &f) < 0)
    80004e32:	fe840613          	addi	a2,s0,-24
    80004e36:	4581                	li	a1,0
    80004e38:	4501                	li	a0,0
    80004e3a:	d93ff0ef          	jal	80004bcc <argfd>
    80004e3e:	87aa                	mv	a5,a0
    return -1;
    80004e40:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004e42:	0007ca63          	bltz	a5,80004e56 <sys_read+0x40>
  return fileread(f, p, n);
    80004e46:	fe442603          	lw	a2,-28(s0)
    80004e4a:	fd843583          	ld	a1,-40(s0)
    80004e4e:	fe843503          	ld	a0,-24(s0)
    80004e52:	c94ff0ef          	jal	800042e6 <fileread>
}
    80004e56:	70a2                	ld	ra,40(sp)
    80004e58:	7402                	ld	s0,32(sp)
    80004e5a:	6145                	addi	sp,sp,48
    80004e5c:	8082                	ret

0000000080004e5e <sys_write>:
{
    80004e5e:	7179                	addi	sp,sp,-48
    80004e60:	f406                	sd	ra,40(sp)
    80004e62:	f022                	sd	s0,32(sp)
    80004e64:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e66:	fd840593          	addi	a1,s0,-40
    80004e6a:	4505                	li	a0,1
    80004e6c:	a59fd0ef          	jal	800028c4 <argaddr>
  argint(2, &n);
    80004e70:	fe440593          	addi	a1,s0,-28
    80004e74:	4509                	li	a0,2
    80004e76:	a33fd0ef          	jal	800028a8 <argint>
  if (argfd(0, 0, &f) < 0)
    80004e7a:	fe840613          	addi	a2,s0,-24
    80004e7e:	4581                	li	a1,0
    80004e80:	4501                	li	a0,0
    80004e82:	d4bff0ef          	jal	80004bcc <argfd>
    80004e86:	87aa                	mv	a5,a0
    return -1;
    80004e88:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004e8a:	0007ca63          	bltz	a5,80004e9e <sys_write+0x40>
  return filewrite(f, p, n);
    80004e8e:	fe442603          	lw	a2,-28(s0)
    80004e92:	fd843583          	ld	a1,-40(s0)
    80004e96:	fe843503          	ld	a0,-24(s0)
    80004e9a:	d1aff0ef          	jal	800043b4 <filewrite>
}
    80004e9e:	70a2                	ld	ra,40(sp)
    80004ea0:	7402                	ld	s0,32(sp)
    80004ea2:	6145                	addi	sp,sp,48
    80004ea4:	8082                	ret

0000000080004ea6 <sys_close>:
{
    80004ea6:	1101                	addi	sp,sp,-32
    80004ea8:	ec06                	sd	ra,24(sp)
    80004eaa:	e822                	sd	s0,16(sp)
    80004eac:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004eae:	fe040613          	addi	a2,s0,-32
    80004eb2:	fec40593          	addi	a1,s0,-20
    80004eb6:	4501                	li	a0,0
    80004eb8:	d15ff0ef          	jal	80004bcc <argfd>
    return -1;
    80004ebc:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004ebe:	02054163          	bltz	a0,80004ee0 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004ec2:	a87fc0ef          	jal	80001948 <myproc>
    80004ec6:	fec42783          	lw	a5,-20(s0)
    80004eca:	078e                	slli	a5,a5,0x3
    80004ecc:	0d078793          	addi	a5,a5,208
    80004ed0:	953e                	add	a0,a0,a5
    80004ed2:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004ed6:	fe043503          	ld	a0,-32(s0)
    80004eda:	adaff0ef          	jal	800041b4 <fileclose>
  return 0;
    80004ede:	4781                	li	a5,0
}
    80004ee0:	853e                	mv	a0,a5
    80004ee2:	60e2                	ld	ra,24(sp)
    80004ee4:	6442                	ld	s0,16(sp)
    80004ee6:	6105                	addi	sp,sp,32
    80004ee8:	8082                	ret

0000000080004eea <sys_fstat>:
{
    80004eea:	1101                	addi	sp,sp,-32
    80004eec:	ec06                	sd	ra,24(sp)
    80004eee:	e822                	sd	s0,16(sp)
    80004ef0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004ef2:	fe040593          	addi	a1,s0,-32
    80004ef6:	4505                	li	a0,1
    80004ef8:	9cdfd0ef          	jal	800028c4 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004efc:	fe840613          	addi	a2,s0,-24
    80004f00:	4581                	li	a1,0
    80004f02:	4501                	li	a0,0
    80004f04:	cc9ff0ef          	jal	80004bcc <argfd>
    80004f08:	87aa                	mv	a5,a0
    return -1;
    80004f0a:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004f0c:	0007c863          	bltz	a5,80004f1c <sys_fstat+0x32>
  return filestat(f, st);
    80004f10:	fe043583          	ld	a1,-32(s0)
    80004f14:	fe843503          	ld	a0,-24(s0)
    80004f18:	b5eff0ef          	jal	80004276 <filestat>
}
    80004f1c:	60e2                	ld	ra,24(sp)
    80004f1e:	6442                	ld	s0,16(sp)
    80004f20:	6105                	addi	sp,sp,32
    80004f22:	8082                	ret

0000000080004f24 <sys_link>:
{
    80004f24:	7169                	addi	sp,sp,-304
    80004f26:	f606                	sd	ra,296(sp)
    80004f28:	f222                	sd	s0,288(sp)
    80004f2a:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f2c:	08000613          	li	a2,128
    80004f30:	ed040593          	addi	a1,s0,-304
    80004f34:	4501                	li	a0,0
    80004f36:	9abfd0ef          	jal	800028e0 <argstr>
    return -1;
    80004f3a:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f3c:	10054163          	bltz	a0,8000503e <sys_link+0x11a>
    80004f40:	08000613          	li	a2,128
    80004f44:	f5040593          	addi	a1,s0,-176
    80004f48:	4505                	li	a0,1
    80004f4a:	997fd0ef          	jal	800028e0 <argstr>
    return -1;
    80004f4e:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f50:	0e054763          	bltz	a0,8000503e <sys_link+0x11a>
    80004f54:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f56:	da5fe0ef          	jal	80003cfa <begin_op>
  if ((ip = namei(old)) == 0) {
    80004f5a:	ed040513          	addi	a0,s0,-304
    80004f5e:	bbffe0ef          	jal	80003b1c <namei>
    80004f62:	84aa                	mv	s1,a0
    80004f64:	cd35                	beqz	a0,80004fe0 <sys_link+0xbc>
  ilock(ip);
    80004f66:	b1cfe0ef          	jal	80003282 <ilock>
  if (ip->type == T_DIR) {
    80004f6a:	04449703          	lh	a4,68(s1)
    80004f6e:	4785                	li	a5,1
    80004f70:	06f70d63          	beq	a4,a5,80004fea <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80004f74:	04a49783          	lh	a5,74(s1)
    80004f78:	6721                	lui	a4,0x8
    80004f7a:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004f7c:	06e78f63          	beq	a5,a4,80004ffa <sys_link+0xd6>
    80004f80:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004f82:	2785                	addiw	a5,a5,1
    80004f84:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f88:	8526                	mv	a0,s1
    80004f8a:	a44fe0ef          	jal	800031ce <iupdate>
  iunlock(ip);
    80004f8e:	8526                	mv	a0,s1
    80004f90:	ba0fe0ef          	jal	80003330 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80004f94:	fd040593          	addi	a1,s0,-48
    80004f98:	f5040513          	addi	a0,s0,-176
    80004f9c:	b9bfe0ef          	jal	80003b36 <nameiparent>
    80004fa0:	892a                	mv	s2,a0
    80004fa2:	c93d                	beqz	a0,80005018 <sys_link+0xf4>
  ilock(dp);
    80004fa4:	adefe0ef          	jal	80003282 <ilock>
  if (dp->nlink == 0) {
    80004fa8:	04a91783          	lh	a5,74(s2)
    80004fac:	cfb9                	beqz	a5,8000500a <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80004fae:	854a                	mv	a0,s2
    80004fb0:	00092703          	lw	a4,0(s2)
    80004fb4:	409c                	lw	a5,0(s1)
    80004fb6:	04f71e63          	bne	a4,a5,80005012 <sys_link+0xee>
    80004fba:	40d0                	lw	a2,4(s1)
    80004fbc:	fd040593          	addi	a1,s0,-48
    80004fc0:	ab3fe0ef          	jal	80003a72 <dirlink>
    80004fc4:	04054763          	bltz	a0,80005012 <sys_link+0xee>
  iunlockput(dp);
    80004fc8:	854a                	mv	a0,s2
    80004fca:	d0cfe0ef          	jal	800034d6 <iunlockput>
  iput(ip);
    80004fce:	8526                	mv	a0,s1
    80004fd0:	c34fe0ef          	jal	80003404 <iput>
  end_op();
    80004fd4:	db3fe0ef          	jal	80003d86 <end_op>
  return 0;
    80004fd8:	4781                	li	a5,0
    80004fda:	64f2                	ld	s1,280(sp)
    80004fdc:	6952                	ld	s2,272(sp)
    80004fde:	a085                	j	8000503e <sys_link+0x11a>
    end_op();
    80004fe0:	da7fe0ef          	jal	80003d86 <end_op>
    return -1;
    80004fe4:	57fd                	li	a5,-1
    80004fe6:	64f2                	ld	s1,280(sp)
    80004fe8:	a899                	j	8000503e <sys_link+0x11a>
    iunlockput(ip);
    80004fea:	8526                	mv	a0,s1
    80004fec:	ceafe0ef          	jal	800034d6 <iunlockput>
    end_op();
    80004ff0:	d97fe0ef          	jal	80003d86 <end_op>
    return -1;
    80004ff4:	57fd                	li	a5,-1
    80004ff6:	64f2                	ld	s1,280(sp)
    80004ff8:	a099                	j	8000503e <sys_link+0x11a>
    iunlockput(ip);
    80004ffa:	8526                	mv	a0,s1
    80004ffc:	cdafe0ef          	jal	800034d6 <iunlockput>
    end_op();
    80005000:	d87fe0ef          	jal	80003d86 <end_op>
    return -1;
    80005004:	57fd                	li	a5,-1
    80005006:	64f2                	ld	s1,280(sp)
    80005008:	a81d                	j	8000503e <sys_link+0x11a>
    iunlockput(dp);
    8000500a:	854a                	mv	a0,s2
    8000500c:	ccafe0ef          	jal	800034d6 <iunlockput>
    goto bad;
    80005010:	a021                	j	80005018 <sys_link+0xf4>
    iunlockput(dp);
    80005012:	854a                	mv	a0,s2
    80005014:	cc2fe0ef          	jal	800034d6 <iunlockput>
  ilock(ip);
    80005018:	8526                	mv	a0,s1
    8000501a:	a68fe0ef          	jal	80003282 <ilock>
  ip->nlink--;
    8000501e:	04a4d783          	lhu	a5,74(s1)
    80005022:	37fd                	addiw	a5,a5,-1
    80005024:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005028:	8526                	mv	a0,s1
    8000502a:	9a4fe0ef          	jal	800031ce <iupdate>
  iunlockput(ip);
    8000502e:	8526                	mv	a0,s1
    80005030:	ca6fe0ef          	jal	800034d6 <iunlockput>
  end_op();
    80005034:	d53fe0ef          	jal	80003d86 <end_op>
  return -1;
    80005038:	57fd                	li	a5,-1
    8000503a:	64f2                	ld	s1,280(sp)
    8000503c:	6952                	ld	s2,272(sp)
}
    8000503e:	853e                	mv	a0,a5
    80005040:	70b2                	ld	ra,296(sp)
    80005042:	7412                	ld	s0,288(sp)
    80005044:	6155                	addi	sp,sp,304
    80005046:	8082                	ret

0000000080005048 <sys_unlink>:
{
    80005048:	7151                	addi	sp,sp,-240
    8000504a:	f586                	sd	ra,232(sp)
    8000504c:	f1a2                	sd	s0,224(sp)
    8000504e:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005050:	08000613          	li	a2,128
    80005054:	f3040593          	addi	a1,s0,-208
    80005058:	4501                	li	a0,0
    8000505a:	887fd0ef          	jal	800028e0 <argstr>
    8000505e:	14054d63          	bltz	a0,800051b8 <sys_unlink+0x170>
    80005062:	eda6                	sd	s1,216(sp)
  begin_op();
    80005064:	c97fe0ef          	jal	80003cfa <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80005068:	fb040593          	addi	a1,s0,-80
    8000506c:	f3040513          	addi	a0,s0,-208
    80005070:	ac7fe0ef          	jal	80003b36 <nameiparent>
    80005074:	84aa                	mv	s1,a0
    80005076:	c955                	beqz	a0,8000512a <sys_unlink+0xe2>
  ilock(dp);
    80005078:	a0afe0ef          	jal	80003282 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000507c:	00002597          	auipc	a1,0x2
    80005080:	56458593          	addi	a1,a1,1380 # 800075e0 <etext+0x5e0>
    80005084:	fb040513          	addi	a0,s0,-80
    80005088:	fccfe0ef          	jal	80003854 <namecmp>
    8000508c:	10050b63          	beqz	a0,800051a2 <sys_unlink+0x15a>
    80005090:	00002597          	auipc	a1,0x2
    80005094:	55858593          	addi	a1,a1,1368 # 800075e8 <etext+0x5e8>
    80005098:	fb040513          	addi	a0,s0,-80
    8000509c:	fb8fe0ef          	jal	80003854 <namecmp>
    800050a0:	10050163          	beqz	a0,800051a2 <sys_unlink+0x15a>
    800050a4:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    800050a6:	f2c40613          	addi	a2,s0,-212
    800050aa:	fb040593          	addi	a1,s0,-80
    800050ae:	8526                	mv	a0,s1
    800050b0:	fbafe0ef          	jal	8000386a <dirlookup>
    800050b4:	892a                	mv	s2,a0
    800050b6:	0e050563          	beqz	a0,800051a0 <sys_unlink+0x158>
    800050ba:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800050bc:	9c6fe0ef          	jal	80003282 <ilock>
  if (ip->nlink < 1)
    800050c0:	04a91783          	lh	a5,74(s2)
    800050c4:	06f05863          	blez	a5,80005134 <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    800050c8:	04491703          	lh	a4,68(s2)
    800050cc:	4785                	li	a5,1
    800050ce:	06f70963          	beq	a4,a5,80005140 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    800050d2:	fc040993          	addi	s3,s0,-64
    800050d6:	4641                	li	a2,16
    800050d8:	4581                	li	a1,0
    800050da:	854e                	mv	a0,s3
    800050dc:	c0dfb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050e0:	4741                	li	a4,16
    800050e2:	f2c42683          	lw	a3,-212(s0)
    800050e6:	864e                	mv	a2,s3
    800050e8:	4581                	li	a1,0
    800050ea:	8526                	mv	a0,s1
    800050ec:	e62fe0ef          	jal	8000374e <writei>
    800050f0:	47c1                	li	a5,16
    800050f2:	08f51863          	bne	a0,a5,80005182 <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    800050f6:	04491703          	lh	a4,68(s2)
    800050fa:	4785                	li	a5,1
    800050fc:	08f70963          	beq	a4,a5,8000518e <sys_unlink+0x146>
  iunlockput(dp);
    80005100:	8526                	mv	a0,s1
    80005102:	bd4fe0ef          	jal	800034d6 <iunlockput>
  ip->nlink--;
    80005106:	04a95783          	lhu	a5,74(s2)
    8000510a:	37fd                	addiw	a5,a5,-1
    8000510c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005110:	854a                	mv	a0,s2
    80005112:	8bcfe0ef          	jal	800031ce <iupdate>
  iunlockput(ip);
    80005116:	854a                	mv	a0,s2
    80005118:	bbefe0ef          	jal	800034d6 <iunlockput>
  end_op();
    8000511c:	c6bfe0ef          	jal	80003d86 <end_op>
  return 0;
    80005120:	4501                	li	a0,0
    80005122:	64ee                	ld	s1,216(sp)
    80005124:	694e                	ld	s2,208(sp)
    80005126:	69ae                	ld	s3,200(sp)
    80005128:	a061                	j	800051b0 <sys_unlink+0x168>
    end_op();
    8000512a:	c5dfe0ef          	jal	80003d86 <end_op>
    return -1;
    8000512e:	557d                	li	a0,-1
    80005130:	64ee                	ld	s1,216(sp)
    80005132:	a8bd                	j	800051b0 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005134:	00002517          	auipc	a0,0x2
    80005138:	4bc50513          	addi	a0,a0,1212 # 800075f0 <etext+0x5f0>
    8000513c:	ef8fb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005140:	04c92703          	lw	a4,76(s2)
    80005144:	02000793          	li	a5,32
    80005148:	f8e7f5e3          	bgeu	a5,a4,800050d2 <sys_unlink+0x8a>
    8000514c:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000514e:	4741                	li	a4,16
    80005150:	86ce                	mv	a3,s3
    80005152:	f1840613          	addi	a2,s0,-232
    80005156:	4581                	li	a1,0
    80005158:	854a                	mv	a0,s2
    8000515a:	d02fe0ef          	jal	8000365c <readi>
    8000515e:	47c1                	li	a5,16
    80005160:	00f51b63          	bne	a0,a5,80005176 <sys_unlink+0x12e>
    if (de.inum != 0)
    80005164:	f1845783          	lhu	a5,-232(s0)
    80005168:	ebb1                	bnez	a5,800051bc <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000516a:	29c1                	addiw	s3,s3,16
    8000516c:	04c92783          	lw	a5,76(s2)
    80005170:	fcf9efe3          	bltu	s3,a5,8000514e <sys_unlink+0x106>
    80005174:	bfb9                	j	800050d2 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005176:	00002517          	auipc	a0,0x2
    8000517a:	49250513          	addi	a0,a0,1170 # 80007608 <etext+0x608>
    8000517e:	eb6fb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    80005182:	00002517          	auipc	a0,0x2
    80005186:	49e50513          	addi	a0,a0,1182 # 80007620 <etext+0x620>
    8000518a:	eaafb0ef          	jal	80000834 <panic>
    dp->nlink--;
    8000518e:	04a4d783          	lhu	a5,74(s1)
    80005192:	37fd                	addiw	a5,a5,-1
    80005194:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005198:	8526                	mv	a0,s1
    8000519a:	834fe0ef          	jal	800031ce <iupdate>
    8000519e:	b78d                	j	80005100 <sys_unlink+0xb8>
    800051a0:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800051a2:	8526                	mv	a0,s1
    800051a4:	b32fe0ef          	jal	800034d6 <iunlockput>
  end_op();
    800051a8:	bdffe0ef          	jal	80003d86 <end_op>
  return -1;
    800051ac:	557d                	li	a0,-1
    800051ae:	64ee                	ld	s1,216(sp)
}
    800051b0:	70ae                	ld	ra,232(sp)
    800051b2:	740e                	ld	s0,224(sp)
    800051b4:	616d                	addi	sp,sp,240
    800051b6:	8082                	ret
    return -1;
    800051b8:	557d                	li	a0,-1
    800051ba:	bfdd                	j	800051b0 <sys_unlink+0x168>
    iunlockput(ip);
    800051bc:	854a                	mv	a0,s2
    800051be:	b18fe0ef          	jal	800034d6 <iunlockput>
    goto bad;
    800051c2:	694e                	ld	s2,208(sp)
    800051c4:	69ae                	ld	s3,200(sp)
    800051c6:	bff1                	j	800051a2 <sys_unlink+0x15a>

00000000800051c8 <sys_open>:

uint64
sys_open(void)
{
    800051c8:	7131                	addi	sp,sp,-192
    800051ca:	fd06                	sd	ra,184(sp)
    800051cc:	f922                	sd	s0,176(sp)
    800051ce:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800051d0:	f4c40593          	addi	a1,s0,-180
    800051d4:	4505                	li	a0,1
    800051d6:	ed2fd0ef          	jal	800028a8 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800051da:	08000613          	li	a2,128
    800051de:	f5040593          	addi	a1,s0,-176
    800051e2:	4501                	li	a0,0
    800051e4:	efcfd0ef          	jal	800028e0 <argstr>
    800051e8:	87aa                	mv	a5,a0
    return -1;
    800051ea:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800051ec:	0a07c363          	bltz	a5,80005292 <sys_open+0xca>
    800051f0:	f526                	sd	s1,168(sp)

  begin_op();
    800051f2:	b09fe0ef          	jal	80003cfa <begin_op>

  if (omode & O_CREATE) {
    800051f6:	f4c42783          	lw	a5,-180(s0)
    800051fa:	2007f793          	andi	a5,a5,512
    800051fe:	c3dd                	beqz	a5,800052a4 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005200:	4681                	li	a3,0
    80005202:	4601                	li	a2,0
    80005204:	4589                	li	a1,2
    80005206:	f5040513          	addi	a0,s0,-176
    8000520a:	a5dff0ef          	jal	80004c66 <create>
    8000520e:	84aa                	mv	s1,a0
    if (ip == 0) {
    80005210:	c549                	beqz	a0,8000529a <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    80005212:	04449703          	lh	a4,68(s1)
    80005216:	478d                	li	a5,3
    80005218:	00f71763          	bne	a4,a5,80005226 <sys_open+0x5e>
    8000521c:	0464d703          	lhu	a4,70(s1)
    80005220:	47a5                	li	a5,9
    80005222:	0ae7ee63          	bltu	a5,a4,800052de <sys_open+0x116>
    80005226:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    80005228:	ee9fe0ef          	jal	80004110 <filealloc>
    8000522c:	892a                	mv	s2,a0
    8000522e:	c561                	beqz	a0,800052f6 <sys_open+0x12e>
    80005230:	ed4e                	sd	s3,152(sp)
    80005232:	9f5ff0ef          	jal	80004c26 <fdalloc>
    80005236:	89aa                	mv	s3,a0
    80005238:	0a054b63          	bltz	a0,800052ee <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    8000523c:	04449703          	lh	a4,68(s1)
    80005240:	478d                	li	a5,3
    80005242:	0cf70363          	beq	a4,a5,80005308 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005246:	4789                	li	a5,2
    80005248:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000524c:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005250:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005254:	f4c42783          	lw	a5,-180(s0)
    80005258:	0017f713          	andi	a4,a5,1
    8000525c:	00174713          	xori	a4,a4,1
    80005260:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005264:	0037f713          	andi	a4,a5,3
    80005268:	00e03733          	snez	a4,a4
    8000526c:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80005270:	4007f793          	andi	a5,a5,1024
    80005274:	c791                	beqz	a5,80005280 <sys_open+0xb8>
    80005276:	04449703          	lh	a4,68(s1)
    8000527a:	4789                	li	a5,2
    8000527c:	08f70d63          	beq	a4,a5,80005316 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005280:	8526                	mv	a0,s1
    80005282:	8aefe0ef          	jal	80003330 <iunlock>
  end_op();
    80005286:	b01fe0ef          	jal	80003d86 <end_op>

  return fd;
    8000528a:	854e                	mv	a0,s3
    8000528c:	74aa                	ld	s1,168(sp)
    8000528e:	790a                	ld	s2,160(sp)
    80005290:	69ea                	ld	s3,152(sp)
}
    80005292:	70ea                	ld	ra,184(sp)
    80005294:	744a                	ld	s0,176(sp)
    80005296:	6129                	addi	sp,sp,192
    80005298:	8082                	ret
      end_op();
    8000529a:	aedfe0ef          	jal	80003d86 <end_op>
      return -1;
    8000529e:	557d                	li	a0,-1
    800052a0:	74aa                	ld	s1,168(sp)
    800052a2:	bfc5                	j	80005292 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    800052a4:	f5040513          	addi	a0,s0,-176
    800052a8:	875fe0ef          	jal	80003b1c <namei>
    800052ac:	84aa                	mv	s1,a0
    800052ae:	c11d                	beqz	a0,800052d4 <sys_open+0x10c>
    ilock(ip);
    800052b0:	fd3fd0ef          	jal	80003282 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    800052b4:	04449703          	lh	a4,68(s1)
    800052b8:	4785                	li	a5,1
    800052ba:	f4f71ce3          	bne	a4,a5,80005212 <sys_open+0x4a>
    800052be:	f4c42783          	lw	a5,-180(s0)
    800052c2:	d3b5                	beqz	a5,80005226 <sys_open+0x5e>
      iunlockput(ip);
    800052c4:	8526                	mv	a0,s1
    800052c6:	a10fe0ef          	jal	800034d6 <iunlockput>
      end_op();
    800052ca:	abdfe0ef          	jal	80003d86 <end_op>
      return -1;
    800052ce:	557d                	li	a0,-1
    800052d0:	74aa                	ld	s1,168(sp)
    800052d2:	b7c1                	j	80005292 <sys_open+0xca>
      end_op();
    800052d4:	ab3fe0ef          	jal	80003d86 <end_op>
      return -1;
    800052d8:	557d                	li	a0,-1
    800052da:	74aa                	ld	s1,168(sp)
    800052dc:	bf5d                	j	80005292 <sys_open+0xca>
    iunlockput(ip);
    800052de:	8526                	mv	a0,s1
    800052e0:	9f6fe0ef          	jal	800034d6 <iunlockput>
    end_op();
    800052e4:	aa3fe0ef          	jal	80003d86 <end_op>
    return -1;
    800052e8:	557d                	li	a0,-1
    800052ea:	74aa                	ld	s1,168(sp)
    800052ec:	b75d                	j	80005292 <sys_open+0xca>
      fileclose(f);
    800052ee:	854a                	mv	a0,s2
    800052f0:	ec5fe0ef          	jal	800041b4 <fileclose>
    800052f4:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800052f6:	8526                	mv	a0,s1
    800052f8:	9defe0ef          	jal	800034d6 <iunlockput>
    end_op();
    800052fc:	a8bfe0ef          	jal	80003d86 <end_op>
    return -1;
    80005300:	557d                	li	a0,-1
    80005302:	74aa                	ld	s1,168(sp)
    80005304:	790a                	ld	s2,160(sp)
    80005306:	b771                	j	80005292 <sys_open+0xca>
    f->type = FD_DEVICE;
    80005308:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    8000530c:	04649783          	lh	a5,70(s1)
    80005310:	02f91223          	sh	a5,36(s2)
    80005314:	bf35                	j	80005250 <sys_open+0x88>
    itrunc(ip);
    80005316:	8526                	mv	a0,s1
    80005318:	858fe0ef          	jal	80003370 <itrunc>
    8000531c:	b795                	j	80005280 <sys_open+0xb8>

000000008000531e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000531e:	7175                	addi	sp,sp,-144
    80005320:	e506                	sd	ra,136(sp)
    80005322:	e122                	sd	s0,128(sp)
    80005324:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005326:	9d5fe0ef          	jal	80003cfa <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    8000532a:	08000613          	li	a2,128
    8000532e:	f7040593          	addi	a1,s0,-144
    80005332:	4501                	li	a0,0
    80005334:	dacfd0ef          	jal	800028e0 <argstr>
    80005338:	02054363          	bltz	a0,8000535e <sys_mkdir+0x40>
    8000533c:	4681                	li	a3,0
    8000533e:	4601                	li	a2,0
    80005340:	4585                	li	a1,1
    80005342:	f7040513          	addi	a0,s0,-144
    80005346:	921ff0ef          	jal	80004c66 <create>
    8000534a:	c911                	beqz	a0,8000535e <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000534c:	98afe0ef          	jal	800034d6 <iunlockput>
  end_op();
    80005350:	a37fe0ef          	jal	80003d86 <end_op>
  return 0;
    80005354:	4501                	li	a0,0
}
    80005356:	60aa                	ld	ra,136(sp)
    80005358:	640a                	ld	s0,128(sp)
    8000535a:	6149                	addi	sp,sp,144
    8000535c:	8082                	ret
    end_op();
    8000535e:	a29fe0ef          	jal	80003d86 <end_op>
    return -1;
    80005362:	557d                	li	a0,-1
    80005364:	bfcd                	j	80005356 <sys_mkdir+0x38>

0000000080005366 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005366:	7135                	addi	sp,sp,-160
    80005368:	ed06                	sd	ra,152(sp)
    8000536a:	e922                	sd	s0,144(sp)
    8000536c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000536e:	98dfe0ef          	jal	80003cfa <begin_op>
  argint(1, &major);
    80005372:	f6c40593          	addi	a1,s0,-148
    80005376:	4505                	li	a0,1
    80005378:	d30fd0ef          	jal	800028a8 <argint>
  argint(2, &minor);
    8000537c:	f6840593          	addi	a1,s0,-152
    80005380:	4509                	li	a0,2
    80005382:	d26fd0ef          	jal	800028a8 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005386:	08000613          	li	a2,128
    8000538a:	f7040593          	addi	a1,s0,-144
    8000538e:	4501                	li	a0,0
    80005390:	d50fd0ef          	jal	800028e0 <argstr>
    80005394:	02054563          	bltz	a0,800053be <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005398:	f6841683          	lh	a3,-152(s0)
    8000539c:	f6c41603          	lh	a2,-148(s0)
    800053a0:	458d                	li	a1,3
    800053a2:	f7040513          	addi	a0,s0,-144
    800053a6:	8c1ff0ef          	jal	80004c66 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800053aa:	c911                	beqz	a0,800053be <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053ac:	92afe0ef          	jal	800034d6 <iunlockput>
  end_op();
    800053b0:	9d7fe0ef          	jal	80003d86 <end_op>
  return 0;
    800053b4:	4501                	li	a0,0
}
    800053b6:	60ea                	ld	ra,152(sp)
    800053b8:	644a                	ld	s0,144(sp)
    800053ba:	610d                	addi	sp,sp,160
    800053bc:	8082                	ret
    end_op();
    800053be:	9c9fe0ef          	jal	80003d86 <end_op>
    return -1;
    800053c2:	557d                	li	a0,-1
    800053c4:	bfcd                	j	800053b6 <sys_mknod+0x50>

00000000800053c6 <sys_chdir>:

uint64
sys_chdir(void)
{
    800053c6:	7135                	addi	sp,sp,-160
    800053c8:	ed06                	sd	ra,152(sp)
    800053ca:	e922                	sd	s0,144(sp)
    800053cc:	e14a                	sd	s2,128(sp)
    800053ce:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800053d0:	d78fc0ef          	jal	80001948 <myproc>
    800053d4:	892a                	mv	s2,a0

  begin_op();
    800053d6:	925fe0ef          	jal	80003cfa <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    800053da:	08000613          	li	a2,128
    800053de:	f6040593          	addi	a1,s0,-160
    800053e2:	4501                	li	a0,0
    800053e4:	cfcfd0ef          	jal	800028e0 <argstr>
    800053e8:	04054363          	bltz	a0,8000542e <sys_chdir+0x68>
    800053ec:	e526                	sd	s1,136(sp)
    800053ee:	f6040513          	addi	a0,s0,-160
    800053f2:	f2afe0ef          	jal	80003b1c <namei>
    800053f6:	84aa                	mv	s1,a0
    800053f8:	c915                	beqz	a0,8000542c <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800053fa:	e89fd0ef          	jal	80003282 <ilock>
  if (ip->type != T_DIR) {
    800053fe:	04449703          	lh	a4,68(s1)
    80005402:	4785                	li	a5,1
    80005404:	02f71963          	bne	a4,a5,80005436 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005408:	8526                	mv	a0,s1
    8000540a:	f27fd0ef          	jal	80003330 <iunlock>
  iput(p->cwd);
    8000540e:	15093503          	ld	a0,336(s2)
    80005412:	ff3fd0ef          	jal	80003404 <iput>
  end_op();
    80005416:	971fe0ef          	jal	80003d86 <end_op>
  p->cwd = ip;
    8000541a:	14993823          	sd	s1,336(s2)
  return 0;
    8000541e:	4501                	li	a0,0
    80005420:	64aa                	ld	s1,136(sp)
}
    80005422:	60ea                	ld	ra,152(sp)
    80005424:	644a                	ld	s0,144(sp)
    80005426:	690a                	ld	s2,128(sp)
    80005428:	610d                	addi	sp,sp,160
    8000542a:	8082                	ret
    8000542c:	64aa                	ld	s1,136(sp)
    end_op();
    8000542e:	959fe0ef          	jal	80003d86 <end_op>
    return -1;
    80005432:	557d                	li	a0,-1
    80005434:	b7fd                	j	80005422 <sys_chdir+0x5c>
    iunlockput(ip);
    80005436:	8526                	mv	a0,s1
    80005438:	89efe0ef          	jal	800034d6 <iunlockput>
    end_op();
    8000543c:	94bfe0ef          	jal	80003d86 <end_op>
    return -1;
    80005440:	557d                	li	a0,-1
    80005442:	64aa                	ld	s1,136(sp)
    80005444:	bff9                	j	80005422 <sys_chdir+0x5c>

0000000080005446 <sys_exec>:

uint64
sys_exec(void)
{
    80005446:	7105                	addi	sp,sp,-480
    80005448:	ef86                	sd	ra,472(sp)
    8000544a:	eba2                	sd	s0,464(sp)
    8000544c:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000544e:	e2840593          	addi	a1,s0,-472
    80005452:	4505                	li	a0,1
    80005454:	c70fd0ef          	jal	800028c4 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    80005458:	08000613          	li	a2,128
    8000545c:	f3040593          	addi	a1,s0,-208
    80005460:	4501                	li	a0,0
    80005462:	c7efd0ef          	jal	800028e0 <argstr>
    80005466:	87aa                	mv	a5,a0
    return -1;
    80005468:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    8000546a:	0e07c063          	bltz	a5,8000554a <sys_exec+0x104>
    8000546e:	e7a6                	sd	s1,456(sp)
    80005470:	e3ca                	sd	s2,448(sp)
    80005472:	ff4e                	sd	s3,440(sp)
    80005474:	fb52                	sd	s4,432(sp)
    80005476:	f756                	sd	s5,424(sp)
    80005478:	f35a                	sd	s6,416(sp)
    8000547a:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000547c:	e3040a13          	addi	s4,s0,-464
    80005480:	10000613          	li	a2,256
    80005484:	4581                	li	a1,0
    80005486:	8552                	mv	a0,s4
    80005488:	861fb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    8000548c:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    8000548e:	89d2                	mv	s3,s4
    80005490:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005492:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005496:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    80005498:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000549c:	00391513          	slli	a0,s2,0x3
    800054a0:	85d6                	mv	a1,s5
    800054a2:	e2843783          	ld	a5,-472(s0)
    800054a6:	953e                	add	a0,a0,a5
    800054a8:	b74fd0ef          	jal	8000281c <fetchaddr>
    800054ac:	02054663          	bltz	a0,800054d8 <sys_exec+0x92>
    if (uarg == 0) {
    800054b0:	e2043783          	ld	a5,-480(s0)
    800054b4:	c7a1                	beqz	a5,800054fc <sys_exec+0xb6>
    argv[i] = kalloc();
    800054b6:	e98fb0ef          	jal	80000b4e <kalloc>
    800054ba:	85aa                	mv	a1,a0
    800054bc:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    800054c0:	cd01                	beqz	a0,800054d8 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800054c2:	865a                	mv	a2,s6
    800054c4:	e2043503          	ld	a0,-480(s0)
    800054c8:	b9efd0ef          	jal	80002866 <fetchstr>
    800054cc:	00054663          	bltz	a0,800054d8 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    800054d0:	0905                	addi	s2,s2,1
    800054d2:	09a1                	addi	s3,s3,8
    800054d4:	fd7914e3          	bne	s2,s7,8000549c <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054d8:	100a0a13          	addi	s4,s4,256
    800054dc:	6088                	ld	a0,0(s1)
    800054de:	cd31                	beqz	a0,8000553a <sys_exec+0xf4>
    kfree(argv[i]);
    800054e0:	d86fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054e4:	04a1                	addi	s1,s1,8
    800054e6:	ff449be3          	bne	s1,s4,800054dc <sys_exec+0x96>
  return -1;
    800054ea:	557d                	li	a0,-1
    800054ec:	64be                	ld	s1,456(sp)
    800054ee:	691e                	ld	s2,448(sp)
    800054f0:	79fa                	ld	s3,440(sp)
    800054f2:	7a5a                	ld	s4,432(sp)
    800054f4:	7aba                	ld	s5,424(sp)
    800054f6:	7b1a                	ld	s6,416(sp)
    800054f8:	6bfa                	ld	s7,408(sp)
    800054fa:	a881                	j	8000554a <sys_exec+0x104>
      argv[i] = 0;
    800054fc:	0009079b          	sext.w	a5,s2
    80005500:	e3040593          	addi	a1,s0,-464
    80005504:	078e                	slli	a5,a5,0x3
    80005506:	97ae                	add	a5,a5,a1
    80005508:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000550c:	f3040513          	addi	a0,s0,-208
    80005510:	b62ff0ef          	jal	80004872 <kexec>
    80005514:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005516:	100a0a13          	addi	s4,s4,256
    8000551a:	6088                	ld	a0,0(s1)
    8000551c:	c511                	beqz	a0,80005528 <sys_exec+0xe2>
    kfree(argv[i]);
    8000551e:	d48fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005522:	04a1                	addi	s1,s1,8
    80005524:	ff449be3          	bne	s1,s4,8000551a <sys_exec+0xd4>
  return ret;
    80005528:	854a                	mv	a0,s2
    8000552a:	64be                	ld	s1,456(sp)
    8000552c:	691e                	ld	s2,448(sp)
    8000552e:	79fa                	ld	s3,440(sp)
    80005530:	7a5a                	ld	s4,432(sp)
    80005532:	7aba                	ld	s5,424(sp)
    80005534:	7b1a                	ld	s6,416(sp)
    80005536:	6bfa                	ld	s7,408(sp)
    80005538:	a809                	j	8000554a <sys_exec+0x104>
  return -1;
    8000553a:	557d                	li	a0,-1
    8000553c:	64be                	ld	s1,456(sp)
    8000553e:	691e                	ld	s2,448(sp)
    80005540:	79fa                	ld	s3,440(sp)
    80005542:	7a5a                	ld	s4,432(sp)
    80005544:	7aba                	ld	s5,424(sp)
    80005546:	7b1a                	ld	s6,416(sp)
    80005548:	6bfa                	ld	s7,408(sp)
}
    8000554a:	60fe                	ld	ra,472(sp)
    8000554c:	645e                	ld	s0,464(sp)
    8000554e:	613d                	addi	sp,sp,480
    80005550:	8082                	ret

0000000080005552 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005552:	7139                	addi	sp,sp,-64
    80005554:	fc06                	sd	ra,56(sp)
    80005556:	f822                	sd	s0,48(sp)
    80005558:	f426                	sd	s1,40(sp)
    8000555a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000555c:	becfc0ef          	jal	80001948 <myproc>
    80005560:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005562:	fd840593          	addi	a1,s0,-40
    80005566:	4501                	li	a0,0
    80005568:	b5cfd0ef          	jal	800028c4 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    8000556c:	fc840593          	addi	a1,s0,-56
    80005570:	fd040513          	addi	a0,s0,-48
    80005574:	f7ffe0ef          	jal	800044f2 <pipealloc>
    return -1;
    80005578:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    8000557a:	0a054963          	bltz	a0,8000562c <sys_pipe+0xda>
  fd0 = -1;
    8000557e:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    80005582:	fd043503          	ld	a0,-48(s0)
    80005586:	ea0ff0ef          	jal	80004c26 <fdalloc>
    8000558a:	fca42223          	sw	a0,-60(s0)
    8000558e:	08054663          	bltz	a0,8000561a <sys_pipe+0xc8>
    80005592:	fc843503          	ld	a0,-56(s0)
    80005596:	e90ff0ef          	jal	80004c26 <fdalloc>
    8000559a:	fca42023          	sw	a0,-64(s0)
    8000559e:	06054463          	bltz	a0,80005606 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800055a2:	4711                	li	a4,4
    800055a4:	fc440693          	addi	a3,s0,-60
    800055a8:	fd843603          	ld	a2,-40(s0)
    800055ac:	64ac                	ld	a1,72(s1)
    800055ae:	68a8                	ld	a0,80(s1)
    800055b0:	fd3fb0ef          	jal	80001582 <copyout>
    800055b4:	00054f63          	bltz	a0,800055d2 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    800055b8:	4711                	li	a4,4
    800055ba:	fc040693          	addi	a3,s0,-64
    800055be:	fd843603          	ld	a2,-40(s0)
    800055c2:	963a                	add	a2,a2,a4
    800055c4:	64ac                	ld	a1,72(s1)
    800055c6:	68a8                	ld	a0,80(s1)
    800055c8:	fbbfb0ef          	jal	80001582 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800055cc:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800055ce:	04055f63          	bgez	a0,8000562c <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    800055d2:	fc442783          	lw	a5,-60(s0)
    800055d6:	078e                	slli	a5,a5,0x3
    800055d8:	0d078793          	addi	a5,a5,208
    800055dc:	97a6                	add	a5,a5,s1
    800055de:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800055e2:	fc042783          	lw	a5,-64(s0)
    800055e6:	078e                	slli	a5,a5,0x3
    800055e8:	0d078793          	addi	a5,a5,208
    800055ec:	94be                	add	s1,s1,a5
    800055ee:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800055f2:	fd043503          	ld	a0,-48(s0)
    800055f6:	bbffe0ef          	jal	800041b4 <fileclose>
    fileclose(wf);
    800055fa:	fc843503          	ld	a0,-56(s0)
    800055fe:	bb7fe0ef          	jal	800041b4 <fileclose>
    return -1;
    80005602:	57fd                	li	a5,-1
    80005604:	a025                	j	8000562c <sys_pipe+0xda>
    if (fd0 >= 0)
    80005606:	fc442783          	lw	a5,-60(s0)
    8000560a:	0007c863          	bltz	a5,8000561a <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    8000560e:	078e                	slli	a5,a5,0x3
    80005610:	0d078793          	addi	a5,a5,208
    80005614:	97a6                	add	a5,a5,s1
    80005616:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000561a:	fd043503          	ld	a0,-48(s0)
    8000561e:	b97fe0ef          	jal	800041b4 <fileclose>
    fileclose(wf);
    80005622:	fc843503          	ld	a0,-56(s0)
    80005626:	b8ffe0ef          	jal	800041b4 <fileclose>
    return -1;
    8000562a:	57fd                	li	a5,-1
}
    8000562c:	853e                	mv	a0,a5
    8000562e:	70e2                	ld	ra,56(sp)
    80005630:	7442                	ld	s0,48(sp)
    80005632:	74a2                	ld	s1,40(sp)
    80005634:	6121                	addi	sp,sp,64
    80005636:	8082                	ret
	...

0000000080005640 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005640:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005642:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005644:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005646:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005648:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000564a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000564c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000564e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005650:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005652:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005654:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005656:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005658:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000565a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000565c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000565e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005660:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005662:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005664:	8d8fd0ef          	jal	8000273c <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005668:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000566a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000566c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000566e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005670:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005672:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005674:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005676:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005678:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000567a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000567c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000567e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005680:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005682:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005684:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005686:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005688:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000568a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000568c:	10200073          	sret
    80005690:	0001                	nop
    80005692:	00000013          	nop
    80005696:	00000013          	nop
    8000569a:	00000013          	nop

000000008000569e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000569e:	1141                	addi	sp,sp,-16
    800056a0:	e406                	sd	ra,8(sp)
    800056a2:	e022                	sd	s0,0(sp)
    800056a4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    800056a6:	0c000737          	lui	a4,0xc000
    800056aa:	4785                	li	a5,1
    800056ac:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    800056ae:	c35c                	sw	a5,4(a4)
}
    800056b0:	60a2                	ld	ra,8(sp)
    800056b2:	6402                	ld	s0,0(sp)
    800056b4:	0141                	addi	sp,sp,16
    800056b6:	8082                	ret

00000000800056b8 <plicinithart>:

void
plicinithart(void)
{
    800056b8:	1141                	addi	sp,sp,-16
    800056ba:	e406                	sd	ra,8(sp)
    800056bc:	e022                	sd	s0,0(sp)
    800056be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056c0:	a54fc0ef          	jal	80001914 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    800056c4:	0085179b          	slliw	a5,a0,0x8
    800056c8:	0c002737          	lui	a4,0xc002
    800056cc:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    800056d0:	97ba                	add	a5,a5,a4
    800056d2:	40200713          	li	a4,1026
    800056d6:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    800056d8:	00d5151b          	slliw	a0,a0,0xd
    800056dc:	0c2017b7          	lui	a5,0xc201
    800056e0:	953e                	add	a0,a0,a5
    800056e2:	00052023          	sw	zero,0(a0)
}
    800056e6:	60a2                	ld	ra,8(sp)
    800056e8:	6402                	ld	s0,0(sp)
    800056ea:	0141                	addi	sp,sp,16
    800056ec:	8082                	ret

00000000800056ee <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800056ee:	1141                	addi	sp,sp,-16
    800056f0:	e406                	sd	ra,8(sp)
    800056f2:	e022                	sd	s0,0(sp)
    800056f4:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056f6:	a1efc0ef          	jal	80001914 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    800056fa:	00d5151b          	slliw	a0,a0,0xd
    800056fe:	0c2017b7          	lui	a5,0xc201
    80005702:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80005704:	953e                	add	a0,a0,a5
    80005706:	4108                	lw	a0,0(a0)
  return irq;
}
    80005708:	60a2                	ld	ra,8(sp)
    8000570a:	6402                	ld	s0,0(sp)
    8000570c:	0141                	addi	sp,sp,16
    8000570e:	8082                	ret

0000000080005710 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005710:	1101                	addi	sp,sp,-32
    80005712:	ec06                	sd	ra,24(sp)
    80005714:	e822                	sd	s0,16(sp)
    80005716:	e426                	sd	s1,8(sp)
    80005718:	1000                	addi	s0,sp,32
    8000571a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000571c:	9f8fc0ef          	jal	80001914 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    80005720:	00d5179b          	slliw	a5,a0,0xd
    80005724:	0c201737          	lui	a4,0xc201
    80005728:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    8000572a:	97ba                	add	a5,a5,a4
    8000572c:	c384                	sw	s1,0(a5)
}
    8000572e:	60e2                	ld	ra,24(sp)
    80005730:	6442                	ld	s0,16(sp)
    80005732:	64a2                	ld	s1,8(sp)
    80005734:	6105                	addi	sp,sp,32
    80005736:	8082                	ret

0000000080005738 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005738:	1141                	addi	sp,sp,-16
    8000573a:	e406                	sd	ra,8(sp)
    8000573c:	e022                	sd	s0,0(sp)
    8000573e:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005740:	479d                	li	a5,7
    80005742:	04a7ca63          	blt	a5,a0,80005796 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005746:	0001e797          	auipc	a5,0x1e
    8000574a:	f7278793          	addi	a5,a5,-142 # 800236b8 <disk>
    8000574e:	97aa                	add	a5,a5,a0
    80005750:	0187c783          	lbu	a5,24(a5)
    80005754:	e7b9                	bnez	a5,800057a2 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005756:	00451693          	slli	a3,a0,0x4
    8000575a:	0001e797          	auipc	a5,0x1e
    8000575e:	f5e78793          	addi	a5,a5,-162 # 800236b8 <disk>
    80005762:	6398                	ld	a4,0(a5)
    80005764:	9736                	add	a4,a4,a3
    80005766:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000576a:	6398                	ld	a4,0(a5)
    8000576c:	9736                	add	a4,a4,a3
    8000576e:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005772:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005776:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000577a:	97aa                	add	a5,a5,a0
    8000577c:	4705                	li	a4,1
    8000577e:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005782:	0001e517          	auipc	a0,0x1e
    80005786:	f4e50513          	addi	a0,a0,-178 # 800236d0 <disk+0x18>
    8000578a:	87bfc0ef          	jal	80002004 <wakeup>
}
    8000578e:	60a2                	ld	ra,8(sp)
    80005790:	6402                	ld	s0,0(sp)
    80005792:	0141                	addi	sp,sp,16
    80005794:	8082                	ret
    panic("free_desc 1");
    80005796:	00002517          	auipc	a0,0x2
    8000579a:	e9a50513          	addi	a0,a0,-358 # 80007630 <etext+0x630>
    8000579e:	896fb0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    800057a2:	00002517          	auipc	a0,0x2
    800057a6:	e9e50513          	addi	a0,a0,-354 # 80007640 <etext+0x640>
    800057aa:	88afb0ef          	jal	80000834 <panic>

00000000800057ae <virtio_disk_init>:
{
    800057ae:	1101                	addi	sp,sp,-32
    800057b0:	ec06                	sd	ra,24(sp)
    800057b2:	e822                	sd	s0,16(sp)
    800057b4:	e426                	sd	s1,8(sp)
    800057b6:	e04a                	sd	s2,0(sp)
    800057b8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800057ba:	00002597          	auipc	a1,0x2
    800057be:	e9658593          	addi	a1,a1,-362 # 80007650 <etext+0x650>
    800057c2:	0001e517          	auipc	a0,0x1e
    800057c6:	01e50513          	addi	a0,a0,30 # 800237e0 <disk+0x128>
    800057ca:	bdefb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057ce:	100017b7          	lui	a5,0x10001
    800057d2:	4398                	lw	a4,0(a5)
    800057d4:	2701                	sext.w	a4,a4
    800057d6:	747277b7          	lui	a5,0x74727
    800057da:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800057de:	14f71863          	bne	a4,a5,8000592e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057e2:	100017b7          	lui	a5,0x10001
    800057e6:	43dc                	lw	a5,4(a5)
    800057e8:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057ea:	4709                	li	a4,2
    800057ec:	14e79163          	bne	a5,a4,8000592e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057f0:	100017b7          	lui	a5,0x10001
    800057f4:	479c                	lw	a5,8(a5)
    800057f6:	2781                	sext.w	a5,a5
    800057f8:	12e79b63          	bne	a5,a4,8000592e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    800057fc:	100017b7          	lui	a5,0x10001
    80005800:	47d8                	lw	a4,12(a5)
    80005802:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005804:	554d47b7          	lui	a5,0x554d4
    80005808:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000580c:	12f71163          	bne	a4,a5,8000592e <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005810:	100017b7          	lui	a5,0x10001
    80005814:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005818:	4705                	li	a4,1
    8000581a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000581c:	470d                	li	a4,3
    8000581e:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005820:	10001737          	lui	a4,0x10001
    80005824:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005826:	c7ffe6b7          	lui	a3,0xc7ffe
    8000582a:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdad67>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000582e:	8f75                	and	a4,a4,a3
    80005830:	100016b7          	lui	a3,0x10001
    80005834:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005836:	472d                	li	a4,11
    80005838:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000583a:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000583e:	439c                	lw	a5,0(a5)
    80005840:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005844:	8ba1                	andi	a5,a5,8
    80005846:	0e078a63          	beqz	a5,8000593a <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000584a:	100017b7          	lui	a5,0x10001
    8000584e:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005852:	43fc                	lw	a5,68(a5)
    80005854:	2781                	sext.w	a5,a5
    80005856:	0e079863          	bnez	a5,80005946 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000585a:	100017b7          	lui	a5,0x10001
    8000585e:	5bdc                	lw	a5,52(a5)
    80005860:	2781                	sext.w	a5,a5
  if (max == 0)
    80005862:	0e078863          	beqz	a5,80005952 <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005866:	471d                	li	a4,7
    80005868:	0ef77b63          	bgeu	a4,a5,8000595e <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    8000586c:	ae2fb0ef          	jal	80000b4e <kalloc>
    80005870:	0001e497          	auipc	s1,0x1e
    80005874:	e4848493          	addi	s1,s1,-440 # 800236b8 <disk>
    80005878:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    8000587a:	ad4fb0ef          	jal	80000b4e <kalloc>
    8000587e:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005880:	acefb0ef          	jal	80000b4e <kalloc>
    80005884:	87aa                	mv	a5,a0
    80005886:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005888:	6088                	ld	a0,0(s1)
    8000588a:	0e050063          	beqz	a0,8000596a <virtio_disk_init+0x1bc>
    8000588e:	0001e717          	auipc	a4,0x1e
    80005892:	e3273703          	ld	a4,-462(a4) # 800236c0 <disk+0x8>
    80005896:	cb71                	beqz	a4,8000596a <virtio_disk_init+0x1bc>
    80005898:	cbe9                	beqz	a5,8000596a <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    8000589a:	6605                	lui	a2,0x1
    8000589c:	4581                	li	a1,0
    8000589e:	c4afb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800058a2:	0001e497          	auipc	s1,0x1e
    800058a6:	e1648493          	addi	s1,s1,-490 # 800236b8 <disk>
    800058aa:	6605                	lui	a2,0x1
    800058ac:	4581                	li	a1,0
    800058ae:	6488                	ld	a0,8(s1)
    800058b0:	c38fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    800058b4:	6605                	lui	a2,0x1
    800058b6:	4581                	li	a1,0
    800058b8:	6888                	ld	a0,16(s1)
    800058ba:	c2efb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800058be:	100017b7          	lui	a5,0x10001
    800058c2:	4721                	li	a4,8
    800058c4:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800058c6:	4098                	lw	a4,0(s1)
    800058c8:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800058cc:	40d8                	lw	a4,4(s1)
    800058ce:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800058d2:	649c                	ld	a5,8(s1)
    800058d4:	0007869b          	sext.w	a3,a5
    800058d8:	10001737          	lui	a4,0x10001
    800058dc:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800058e0:	9781                	srai	a5,a5,0x20
    800058e2:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800058e6:	689c                	ld	a5,16(s1)
    800058e8:	0007869b          	sext.w	a3,a5
    800058ec:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800058f0:	9781                	srai	a5,a5,0x20
    800058f2:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800058f6:	4785                	li	a5,1
    800058f8:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800058fa:	00f48c23          	sb	a5,24(s1)
    800058fe:	00f48ca3          	sb	a5,25(s1)
    80005902:	00f48d23          	sb	a5,26(s1)
    80005906:	00f48da3          	sb	a5,27(s1)
    8000590a:	00f48e23          	sb	a5,28(s1)
    8000590e:	00f48ea3          	sb	a5,29(s1)
    80005912:	00f48f23          	sb	a5,30(s1)
    80005916:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000591a:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    8000591e:	07272823          	sw	s2,112(a4)
}
    80005922:	60e2                	ld	ra,24(sp)
    80005924:	6442                	ld	s0,16(sp)
    80005926:	64a2                	ld	s1,8(sp)
    80005928:	6902                	ld	s2,0(sp)
    8000592a:	6105                	addi	sp,sp,32
    8000592c:	8082                	ret
    panic("could not find virtio disk");
    8000592e:	00002517          	auipc	a0,0x2
    80005932:	d3250513          	addi	a0,a0,-718 # 80007660 <etext+0x660>
    80005936:	efffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000593a:	00002517          	auipc	a0,0x2
    8000593e:	d4650513          	addi	a0,a0,-698 # 80007680 <etext+0x680>
    80005942:	ef3fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005946:	00002517          	auipc	a0,0x2
    8000594a:	d5a50513          	addi	a0,a0,-678 # 800076a0 <etext+0x6a0>
    8000594e:	ee7fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005952:	00002517          	auipc	a0,0x2
    80005956:	d6e50513          	addi	a0,a0,-658 # 800076c0 <etext+0x6c0>
    8000595a:	edbfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    8000595e:	00002517          	auipc	a0,0x2
    80005962:	d8250513          	addi	a0,a0,-638 # 800076e0 <etext+0x6e0>
    80005966:	ecffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    8000596a:	00002517          	auipc	a0,0x2
    8000596e:	d9650513          	addi	a0,a0,-618 # 80007700 <etext+0x700>
    80005972:	ec3fa0ef          	jal	80000834 <panic>

0000000080005976 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005976:	711d                	addi	sp,sp,-96
    80005978:	ec86                	sd	ra,88(sp)
    8000597a:	e8a2                	sd	s0,80(sp)
    8000597c:	e4a6                	sd	s1,72(sp)
    8000597e:	e0ca                	sd	s2,64(sp)
    80005980:	fc4e                	sd	s3,56(sp)
    80005982:	f852                	sd	s4,48(sp)
    80005984:	f456                	sd	s5,40(sp)
    80005986:	f05a                	sd	s6,32(sp)
    80005988:	ec5e                	sd	s7,24(sp)
    8000598a:	e862                	sd	s8,16(sp)
    8000598c:	1080                	addi	s0,sp,96
    8000598e:	89aa                	mv	s3,a0
    80005990:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005992:	00c52b83          	lw	s7,12(a0)
    80005996:	001b9b9b          	slliw	s7,s7,0x1
    8000599a:	1b82                	slli	s7,s7,0x20
    8000599c:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800059a0:	0001e517          	auipc	a0,0x1e
    800059a4:	e4050513          	addi	a0,a0,-448 # 800237e0 <disk+0x128>
    800059a8:	a80fb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    800059ac:	44a1                	li	s1,8
      disk.free[i] = 0;
    800059ae:	0001ea97          	auipc	s5,0x1e
    800059b2:	d0aa8a93          	addi	s5,s5,-758 # 800236b8 <disk>
  for (int i = 0; i < 3; i++) {
    800059b6:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800059b8:	5c7d                	li	s8,-1
    800059ba:	a8a5                	j	80005a32 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    800059bc:	00fa8733          	add	a4,s5,a5
    800059c0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800059c4:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    800059c6:	0207c563          	bltz	a5,800059f0 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    800059ca:	2905                	addiw	s2,s2,1
    800059cc:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800059ce:	07490663          	beq	s2,s4,80005a3a <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    800059d2:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    800059d4:	0001e717          	auipc	a4,0x1e
    800059d8:	ce470713          	addi	a4,a4,-796 # 800236b8 <disk>
    800059dc:	4781                	li	a5,0
    if (disk.free[i]) {
    800059de:	01874683          	lbu	a3,24(a4)
    800059e2:	fee9                	bnez	a3,800059bc <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    800059e4:	2785                	addiw	a5,a5,1
    800059e6:	0705                	addi	a4,a4,1
    800059e8:	fe979be3          	bne	a5,s1,800059de <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    800059ec:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    800059f0:	01205d63          	blez	s2,80005a0a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    800059f4:	fa042503          	lw	a0,-96(s0)
    800059f8:	d41ff0ef          	jal	80005738 <free_desc>
      for (int j = 0; j < i; j++)
    800059fc:	4785                	li	a5,1
    800059fe:	0127d663          	bge	a5,s2,80005a0a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005a02:	fa442503          	lw	a0,-92(s0)
    80005a06:	d33ff0ef          	jal	80005738 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005a0a:	0001e517          	auipc	a0,0x1e
    80005a0e:	cc650513          	addi	a0,a0,-826 # 800236d0 <disk+0x18>
    80005a12:	d86fc0ef          	jal	80001f98 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005a16:	0001e517          	auipc	a0,0x1e
    80005a1a:	dca50513          	addi	a0,a0,-566 # 800237e0 <disk+0x128>
    80005a1e:	a92fb0ef          	jal	80000cb0 <release>
    sleep();
    80005a22:	db2fc0ef          	jal	80001fd4 <sleep>
    acquire(&disk.vdisk_lock);
    80005a26:	0001e517          	auipc	a0,0x1e
    80005a2a:	dba50513          	addi	a0,a0,-582 # 800237e0 <disk+0x128>
    80005a2e:	9fafb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005a32:	fa040613          	addi	a2,s0,-96
    80005a36:	4901                	li	s2,0
    80005a38:	bf69                	j	800059d2 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a3a:	fa042503          	lw	a0,-96(s0)
    80005a3e:	00451693          	slli	a3,a0,0x4

  if (write)
    80005a42:	0001e797          	auipc	a5,0x1e
    80005a46:	c7678793          	addi	a5,a5,-906 # 800236b8 <disk>
    80005a4a:	00451713          	slli	a4,a0,0x4
    80005a4e:	0a070713          	addi	a4,a4,160
    80005a52:	973e                	add	a4,a4,a5
    80005a54:	01603633          	snez	a2,s6
    80005a58:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005a5a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005a5e:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005a62:	6398                	ld	a4,0(a5)
    80005a64:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a66:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005a6a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005a6c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005a6e:	6390                	ld	a2,0(a5)
    80005a70:	00d60833          	add	a6,a2,a3
    80005a74:	4741                	li	a4,16
    80005a76:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005a7a:	4585                	li	a1,1
    80005a7c:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005a80:	fa442703          	lw	a4,-92(s0)
    80005a84:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005a88:	0712                	slli	a4,a4,0x4
    80005a8a:	963a                	add	a2,a2,a4
    80005a8c:	05898813          	addi	a6,s3,88
    80005a90:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005a94:	0007b883          	ld	a7,0(a5)
    80005a98:	9746                	add	a4,a4,a7
    80005a9a:	40000613          	li	a2,1024
    80005a9e:	c710                	sw	a2,8(a4)
  if (write)
    80005aa0:	001b3613          	seqz	a2,s6
    80005aa4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005aa8:	8e4d                	or	a2,a2,a1
    80005aaa:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005aae:	fa842603          	lw	a2,-88(s0)
    80005ab2:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005ab6:	00451813          	slli	a6,a0,0x4
    80005aba:	02080813          	addi	a6,a6,32
    80005abe:	983e                	add	a6,a6,a5
    80005ac0:	577d                	li	a4,-1
    80005ac2:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005ac6:	0612                	slli	a2,a2,0x4
    80005ac8:	98b2                	add	a7,a7,a2
    80005aca:	03068713          	addi	a4,a3,48
    80005ace:	973e                	add	a4,a4,a5
    80005ad0:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005ad4:	6398                	ld	a4,0(a5)
    80005ad6:	9732                	add	a4,a4,a2
    80005ad8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005ada:	4689                	li	a3,2
    80005adc:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005ae0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005ae4:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005ae8:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005aec:	6794                	ld	a3,8(a5)
    80005aee:	0026d703          	lhu	a4,2(a3)
    80005af2:	8b1d                	andi	a4,a4,7
    80005af4:	0706                	slli	a4,a4,0x1
    80005af6:	96ba                	add	a3,a3,a4
    80005af8:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005afc:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005b00:	6798                	ld	a4,8(a5)
    80005b02:	00275783          	lhu	a5,2(a4)
    80005b06:	2785                	addiw	a5,a5,1
    80005b08:	00f71123          	sh	a5,2(a4)
    80005b0c:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005b10:	100017b7          	lui	a5,0x10001
    80005b14:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005b18:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005b1c:	0001e497          	auipc	s1,0x1e
    80005b20:	cc448493          	addi	s1,s1,-828 # 800237e0 <disk+0x128>
  while (b->disk == 1) {
    80005b24:	892e                	mv	s2,a1
    80005b26:	02b79163          	bne	a5,a1,80005b48 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005b2a:	854e                	mv	a0,s3
    80005b2c:	c6cfc0ef          	jal	80001f98 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005b30:	8526                	mv	a0,s1
    80005b32:	97efb0ef          	jal	80000cb0 <release>
    sleep();
    80005b36:	c9efc0ef          	jal	80001fd4 <sleep>
    acquire(&disk.vdisk_lock);
    80005b3a:	8526                	mv	a0,s1
    80005b3c:	8ecfb0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005b40:	0049a783          	lw	a5,4(s3)
    80005b44:	ff2783e3          	beq	a5,s2,80005b2a <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005b48:	fa042903          	lw	s2,-96(s0)
    80005b4c:	00491713          	slli	a4,s2,0x4
    80005b50:	02070713          	addi	a4,a4,32
    80005b54:	0001e797          	auipc	a5,0x1e
    80005b58:	b6478793          	addi	a5,a5,-1180 # 800236b8 <disk>
    80005b5c:	97ba                	add	a5,a5,a4
    80005b5e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005b62:	0001e997          	auipc	s3,0x1e
    80005b66:	b5698993          	addi	s3,s3,-1194 # 800236b8 <disk>
    80005b6a:	00491713          	slli	a4,s2,0x4
    80005b6e:	0009b783          	ld	a5,0(s3)
    80005b72:	97ba                	add	a5,a5,a4
    80005b74:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005b78:	854a                	mv	a0,s2
    80005b7a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005b7e:	bbbff0ef          	jal	80005738 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005b82:	8885                	andi	s1,s1,1
    80005b84:	f0fd                	bnez	s1,80005b6a <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005b86:	0001e517          	auipc	a0,0x1e
    80005b8a:	c5a50513          	addi	a0,a0,-934 # 800237e0 <disk+0x128>
    80005b8e:	922fb0ef          	jal	80000cb0 <release>
}
    80005b92:	60e6                	ld	ra,88(sp)
    80005b94:	6446                	ld	s0,80(sp)
    80005b96:	64a6                	ld	s1,72(sp)
    80005b98:	6906                	ld	s2,64(sp)
    80005b9a:	79e2                	ld	s3,56(sp)
    80005b9c:	7a42                	ld	s4,48(sp)
    80005b9e:	7aa2                	ld	s5,40(sp)
    80005ba0:	7b02                	ld	s6,32(sp)
    80005ba2:	6be2                	ld	s7,24(sp)
    80005ba4:	6c42                	ld	s8,16(sp)
    80005ba6:	6125                	addi	sp,sp,96
    80005ba8:	8082                	ret

0000000080005baa <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005baa:	1101                	addi	sp,sp,-32
    80005bac:	ec06                	sd	ra,24(sp)
    80005bae:	e822                	sd	s0,16(sp)
    80005bb0:	e426                	sd	s1,8(sp)
    80005bb2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005bb4:	0001e497          	auipc	s1,0x1e
    80005bb8:	b0448493          	addi	s1,s1,-1276 # 800236b8 <disk>
    80005bbc:	0001e517          	auipc	a0,0x1e
    80005bc0:	c2450513          	addi	a0,a0,-988 # 800237e0 <disk+0x128>
    80005bc4:	864fb0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005bc8:	100017b7          	lui	a5,0x10001
    80005bcc:	53bc                	lw	a5,96(a5)
    80005bce:	8b8d                	andi	a5,a5,3
    80005bd0:	10001737          	lui	a4,0x10001
    80005bd4:	d37c                	sw	a5,100(a4)
    80005bd6:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005bda:	689c                	ld	a5,16(s1)
    80005bdc:	0204d703          	lhu	a4,32(s1)
    80005be0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005be4:	04f70863          	beq	a4,a5,80005c34 <virtio_disk_intr+0x8a>
    80005be8:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005bec:	6898                	ld	a4,16(s1)
    80005bee:	0204d783          	lhu	a5,32(s1)
    80005bf2:	8b9d                	andi	a5,a5,7
    80005bf4:	078e                	slli	a5,a5,0x3
    80005bf6:	97ba                	add	a5,a5,a4
    80005bf8:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005bfa:	00479713          	slli	a4,a5,0x4
    80005bfe:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005c02:	9726                	add	a4,a4,s1
    80005c04:	01074703          	lbu	a4,16(a4)
    80005c08:	e329                	bnez	a4,80005c4a <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005c0a:	0792                	slli	a5,a5,0x4
    80005c0c:	02078793          	addi	a5,a5,32
    80005c10:	97a6                	add	a5,a5,s1
    80005c12:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005c14:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005c18:	becfc0ef          	jal	80002004 <wakeup>

    disk.used_idx += 1;
    80005c1c:	0204d783          	lhu	a5,32(s1)
    80005c20:	2785                	addiw	a5,a5,1
    80005c22:	17c2                	slli	a5,a5,0x30
    80005c24:	93c1                	srli	a5,a5,0x30
    80005c26:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005c2a:	6898                	ld	a4,16(s1)
    80005c2c:	00275703          	lhu	a4,2(a4)
    80005c30:	faf71ce3          	bne	a4,a5,80005be8 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005c34:	0001e517          	auipc	a0,0x1e
    80005c38:	bac50513          	addi	a0,a0,-1108 # 800237e0 <disk+0x128>
    80005c3c:	874fb0ef          	jal	80000cb0 <release>
}
    80005c40:	60e2                	ld	ra,24(sp)
    80005c42:	6442                	ld	s0,16(sp)
    80005c44:	64a2                	ld	s1,8(sp)
    80005c46:	6105                	addi	sp,sp,32
    80005c48:	8082                	ret
      panic("virtio_disk_intr status");
    80005c4a:	00002517          	auipc	a0,0x2
    80005c4e:	ace50513          	addi	a0,a0,-1330 # 80007718 <etext+0x718>
    80005c52:	be3fa0ef          	jal	80000834 <panic>
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
